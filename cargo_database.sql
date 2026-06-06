DROP DATABASE IF EXISTS cargo_management;
CREATE DATABASE cargo_management;
USE cargo_management;

CREATE TABLE role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name ENUM(
        'Administrator',
        'Port Manager',
        'Ship Operator',
        'Dock Manager',
        'Cargo Handler'
    ) NOT NULL UNIQUE
);

INSERT INTO role (role_name) VALUES 
('Administrator'),
('Port Manager'),
('Ship Operator'),
('Dock Manager'),
('Cargo Handler');

DELIMITER $$

CREATE TRIGGER
prevent_role_insert
BEFORE INSERT ON role
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No new roles allowed';
END $$

DELIMITER ;

CREATE TABLE users(
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

CREATE TABLE security_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    entry_time DATETIME,
    exit_time DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

DELIMITER $$

CREATE PROCEDURE change_user_password(
    IN u_id INT,
    IN old_pass VARCHAR(255),
    IN new_pass VARCHAR(255)
)
BEGIN
    DECLARE current_pass VARCHAR(255);

    SELECT password INTO current_pass FROM users WHERE user_id = u_id;

    IF current_pass = old_pass THEN
        UPDATE users SET password = new_pass WHERE user_id = u_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Current password does not match';
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_user_name(
    IN u_id INT,
    IN new_name VARCHAR(100)
)
BEGIN
    UPDATE users SET name = new_name WHERE user_id = u_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION login_user(
    u_email VARCHAR(255),
    u_password VARCHAR(255)
)
RETURNS VARCHAR(100)
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_password VARCHAR(255);
    DECLARE v_active BOOLEAN;
    SELECT user_id, password, is_active
    INTO v_user_id, v_password, v_active
    FROM users
    WHERE email = u_email
    LIMIT 1;
    IF v_user_id IS NULL THEN
        RETURN 'Email not found ';
    END IF;
    IF v_password != SHA2(u_password,256) THEN
        RETURN 'Incorrect Password ';
    END IF;
    IF v_active = FALSE THEN
        RETURN 'User is inactive ';
    END IF;
    INSERT INTO security_log(user_id, entry_time)
    VALUES (v_user_id, NOW());
    RETURN 'Login Successful ';
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION logout_user(
    u_user_id INT
)
RETURNS VARCHAR(100)
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE v_log_id INT;
    DECLARE v_exists INT;
    SELECT COUNT(*) INTO v_exists
    FROM users
    WHERE user_id = u_user_id;
    IF v_exists = 0 THEN
        RETURN 'User not found ';
    END IF;
    SELECT log_id INTO v_log_id
    FROM security_log
    WHERE user_id = u_user_id
      AND exit_time IS NULL
    ORDER BY log_id DESC
    LIMIT 1;
    IF v_log_id IS NULL THEN
        RETURN 'No active session';
    END IF;
    UPDATE security_log
    SET exit_time = NOW()
    WHERE log_id = v_log_id;
    RETURN 'Logout Successful';
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_user_email(
    IN u_id INT,
    IN new_email VARCHAR(255)
)
BEGIN
    IF EXISTS (SELECT 1 FROM users WHERE email = new_email AND user_id != u_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already in use';
    END IF;
    UPDATE users SET email = new_email WHERE user_id = u_id;
END $$

DELIMITER ;
CREATE TABLE ship (
    ship_id INT AUTO_INCREMENT PRIMARY KEY,
    ship_name VARCHAR(120) NOT NULL UNIQUE,
    arrival_date DATETIME NOT NULL,
    departure_date DATETIME NULL,
    status ENUM('Anchored','Docked','Departed') DEFAULT 'Anchored',
    operator_id INT NOT NULL,
    CONSTRAINT fk_ship_operator
    FOREIGN KEY (operator_id) REFERENCES users(user_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
CREATE INDEX idx_ship_name ON ship(ship_name);
CREATE INDEX idx_ship_status ON ship(status);
CREATE INDEX idx_ship_operator ON ship(operator_id);

CREATE TABLE container (
    container_id INT AUTO_INCREMENT PRIMARY KEY,
    container_type ENUM('Dry','Reefer','Open Top','Tank') NOT NULL,
    status ENUM('Loaded', 'Empty', 'In Transit') NOT NULL,
    ship_id INT NULL,
    FOREIGN KEY (ship_id) REFERENCES ship(ship_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

DELIMITER $$
CREATE PROCEDURE update_container_specific(
    IN u_user_id INT,
    IN c_container_id INT,
    IN c_type ENUM('Dry','Reefer','Open Top','Tank'),
    IN c_status ENUM('Loaded', 'Empty', 'In Transit'),
    IN c_ship_id INT
)
BEGIN
    DECLARE u_role VARCHAR(50);
    SELECT r.role_name INTO u_role
    FROM users u
    JOIN role r ON u.role_id = r.role_id
    WHERE u.user_id = u_user_id;
    IF u_role NOT IN ('Administrator','Port Manager','Ship Operator') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access Denied';
    END IF;
    IF c_type IS NULL AND c_status IS NULL AND c_ship_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No values provided';
    END IF;
    UPDATE container
    SET
        container_type = COALESCE(c_type, container_type),
        status = COALESCE(c_status, status),
        ship_id = COALESCE(c_ship_id, ship_id)
    WHERE container_id = c_container_id;
END $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS view_containers $$
CREATE PROCEDURE view_containers(IN u_user_id INT)
BEGIN
    DECLARE u_role VARCHAR(50);
    SELECT r.role_name INTO u_role FROM users u JOIN role r ON u.role_id = r.role_id WHERE u.user_id = u_user_id;
    IF u_role IN ('Administrator','Port Manager','Ship Operator') THEN
        SELECT c.container_id, c.container_type, c.status, 
               IFNULL(s.ship_id, 0) AS ship_id 
        FROM container c 
        LEFT JOIN ship s ON c.ship_id = s.ship_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access Denied';
    END IF;
END $$
DELIMITER ;

CREATE TABLE cargo (
    cargo_id INT AUTO_INCREMENT PRIMARY KEY,
    container_id INT NOT NULL,
    description VARCHAR(200) NOT NULL,
    weight DECIMAL(10,2) NOT NULL,
    status ENUM('Loaded','Unloaded','In Transit') NOT NULL,
    FOREIGN KEY (container_id) REFERENCES container(container_id)
);

CREATE TABLE cargo_movement (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    cargo_id INT NOT NULL,
    movement_type ENUM('Load','Unload','Transfer') NOT NULL,
    movement_date DATETIME NOT NULL,
    handled_by INT NOT NULL,
    FOREIGN KEY (cargo_id) REFERENCES cargo(cargo_id),
    FOREIGN KEY (handled_by) REFERENCES users(user_id)
);

DELIMITER $$
CREATE TRIGGER trg_delete_cargo_movement
BEFORE DELETE ON cargo
FOR EACH ROW
BEGIN
    DELETE FROM cargo_movement
    WHERE cargo_id = OLD.cargo_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE add_cargo(
    IN c_container_id INT,
    IN c_description VARCHAR(200),
    IN c_weight DECIMAL(10,2),
    IN c_status ENUM('Loaded','Unloaded','In Transit'),
    IN u_user_id INT
)
BEGIN
    DECLARE u_role VARCHAR(50);
    SELECT r.role_name INTO u_role
    FROM users u 
    JOIN role r ON u.role_id = r.role_id
    WHERE u.user_id = u_user_id;
    IF u_role IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid User';
    END IF;
    IF u_role NOT IN ('Administrator','Port Manager','Cargo Handler') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access Denied';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM container WHERE container_id = c_container_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid container';
    END IF;
    IF c_description IS NULL OR TRIM(c_description) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Description cannot be empty';
    END IF;
    IF c_weight IS NULL OR c_weight <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid weight';
    END IF;
    INSERT INTO cargo(container_id, description, weight, status)
    VALUES (
        c_container_id,
        c_description,
        c_weight,
        COALESCE(c_status, 'In Transit') 
    );
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_cargo(
    IN c_cargo_id INT,
    IN u_user_id INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_exists INT;
    SELECT r.role_name INTO v_role
    FROM users u
    JOIN role r ON u.role_id = r.role_id
    WHERE u.user_id = u_user_id;
    IF v_role IS NULL OR v_role NOT IN ('Administrator','Port Manager','Cargo Handler') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access Denied';
    END IF;
    SELECT COUNT(*) INTO v_exists
    FROM cargo
    WHERE cargo_id = c_cargo_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cargo not found';
    END IF;
    DELETE FROM cargo
    WHERE cargo_id = c_cargo_id;
    SELECT 'Cargo deleted successfully' AS message;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_cargo(
    IN c_cargo_id INT,
    IN c_container_id INT,
    IN c_description VARCHAR(200),
    IN c_weight DECIMAL(10,2),
    IN c_status ENUM('Loaded','Unloaded','In Transit'),
    IN u_user_id INT
)
BEGIN
    DECLARE u_role VARCHAR(50);
    DECLARE rows_affected INT;
    SET @logged_in_user = u_user_id;
    SELECT r.role_name INTO u_role
    FROM users u 
    JOIN role r ON u.role_id = r.role_id
    WHERE u.user_id = u_user_id;
    IF u_role IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid User';
    END IF;
    IF u_role NOT IN ('Administrator','Port Manager','Cargo Handler') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access Denied';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM cargo WHERE cargo_id = c_cargo_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid cargo id';
    END IF;
    IF c_container_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM container WHERE container_id = c_container_id
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid container';
        END IF;
    END IF;
    IF c_description IS NOT NULL AND TRIM(c_description) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Description cannot be empty';
    END IF;
    IF c_weight IS NOT NULL AND c_weight <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Weight must be positive';
    END IF;
    IF c_container_id IS NULL 
       AND c_description IS NULL 
       AND c_weight IS NULL 
       AND c_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No fields to update';
    END IF;
    UPDATE cargo
    SET 
        container_id = COALESCE(c_container_id, container_id),
        description  = COALESCE(c_description, description),
        weight       = COALESCE(c_weight, weight),
        status       = COALESCE(c_status, status)
    WHERE cargo_id = c_cargo_id;
    SET rows_affected = ROW_COUNT();
    IF rows_affected = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Update failed';
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_all_cargo(IN u_user_id INT)
BEGIN
    DECLARE u_role VARCHAR(50);
    SELECT r.role_name INTO u_role
    FROM users u JOIN role r ON u.role_id = r.role_id
    WHERE u.user_id = u_user_id;
    IF u_role NOT IN ('Administrator','Port Manager','Cargo Handler') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access Denied';
    END IF;
    SELECT 
        c.cargo_id,
        c.container_id,
        c.description,
        c.weight,
        c.status
    FROM cargo c
    JOIN container con ON c.container_id = con.container_id
    LEFT JOIN ship s ON con.ship_id = s.ship_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_cargo_history(
    IN c_cargo_id INT,
    IN u_user_id INT
)
BEGIN
    DECLARE u_role VARCHAR(50);
    SELECT r.role_name INTO u_role
    FROM users u 
    JOIN role r ON u.role_id = r.role_id
    WHERE u.user_id = u_user_id;
    IF u_role NOT IN ('Administrator','Port Manager','Cargo Handler') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access Denied';
    END IF;
    SELECT 
        c.cargo_id,
        c.description,
        c.weight,
        c.status,
        con.container_id,
        s.ship_name
    FROM cargo c
    JOIN container con ON c.container_id = con.container_id
    JOIN ship s ON con.ship_id = s.ship_id
    WHERE c.cargo_id = c_cargo_id;
    SELECT 
		cm.cargo_id,
        cm.movement_id,
        cm.movement_type,
        cm.movement_date,
        u.name
    FROM cargo_movement cm
    JOIN users u ON cm.handled_by = u.user_id
    WHERE cm.cargo_id = c_cargo_id
    ORDER BY cm.movement_date DESC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE show_all_details(IN u_user_id INT)
BEGIN
    DECLARE u_role VARCHAR(50);
    SELECT r.role_name INTO u_role
    FROM users u JOIN role r ON u.role_id = r.role_id
    WHERE u.user_id = u_user_id;
    IF u_role NOT IN ('Administrator','Port Manager','Cargo Handler') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access Denied';
    END IF;
    SELECT 
        cm.movement_id,
        cm.cargo_id,
        c.container_id,
        con.ship_id,
        s.operator_id,
        cm.handled_by,      
        c.description,
        c.weight,
        c.status,
        cm.movement_type,
        cm.movement_date
    FROM cargo_movement cm
    LEFT JOIN cargo c ON cm.cargo_id = c.cargo_id
    LEFT JOIN container con ON c.container_id = con.container_id
    LEFT JOIN ship s ON con.ship_id = s.ship_id
    ORDER BY cm.movement_date DESC;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_after_cargo_update
AFTER UPDATE ON cargo
FOR EACH ROW
BEGIN
    DECLARE c_movement_type VARCHAR(20);
    DECLARE v_user_id INT;
    SET v_user_id = @logged_in_user;
    IF @movement_type_hint IS NOT NULL THEN
        SET c_movement_type = @movement_type_hint;
        SET @movement_type_hint = NULL;  
    ELSE
        IF NEW.status = 'Loaded' THEN
            SET c_movement_type = 'Load';
        ELSEIF NEW.status = 'Unloaded' THEN
            SET c_movement_type = 'Unload';
        ELSE
            SET c_movement_type = 'Transfer';
        END IF;
    END IF;
    INSERT INTO cargo_movement (cargo_id, movement_type, movement_date, handled_by)
    VALUES (NEW.cargo_id, c_movement_type, NOW(), v_user_id);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE add_cargo_movement(
    IN p_cargo_id       INT,
    IN p_movement_type  ENUM('Load', 'Unload', 'Transfer'),
    IN p_handled_by     INT
)
BEGIN
    DECLARE new_status VARCHAR(50);
    IF p_movement_type = 'Load' THEN
        SET new_status = 'Loaded';
    ELSEIF p_movement_type = 'Unload' THEN
        SET new_status = 'Unloaded';
    ELSE
        SET new_status = 'In Transit';
    END IF;
    SET @logged_in_user    = p_handled_by;
    SET @movement_type_hint = p_movement_type;
    UPDATE cargo
    SET    status = new_status
    WHERE  cargo_id = p_cargo_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_search_cargo(IN p_term VARCHAR(255))
BEGIN
    SELECT cargo_id, container_id, description, weight, status
    FROM   cargo
    WHERE  CAST(cargo_id      AS CHAR) LIKE CONCAT('%', p_term, '%')
        OR CAST(container_id  AS CHAR) LIKE CONCAT('%', p_term, '%')
        OR LOWER(COALESCE(description, '')) LIKE LOWER(CONCAT('%', p_term, '%'))
        OR LOWER(COALESCE(status, ''))      =    LOWER(p_term);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_search_container(IN p_term VARCHAR(255))
BEGIN
    SELECT container_id, container_type, status, ship_id
    FROM   container
    WHERE  CAST(container_id AS CHAR) LIKE CONCAT('%', p_term, '%')
        OR LOWER(COALESCE(container_type, '')) LIKE LOWER(CONCAT('%', p_term, '%'))
        OR LOWER(COALESCE(status,         '')) LIKE LOWER(CONCAT('%', p_term, '%'));
END $$
DELIMITER ;