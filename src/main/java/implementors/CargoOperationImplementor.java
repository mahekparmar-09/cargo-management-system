package implementors;

import java.security.MessageDigest;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import db_config.GetConnection;
import model.CargoMovementPojo;
import model.CargoPojo;
import model.ContainerPojo;
import model.UserPojo;
import operations.CargoOperations;

public class CargoOperationImplementor implements CargoOperations {

    @Override
    public String addCargo(CargoPojo cargo, UserPojo user) {
        String msg = "";
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call add_cargo(?,?,?,?,?)}")) {
            cs.setInt(1, cargo.getContainerId());
            cs.setString(2, cargo.getDescription());
            cs.setDouble(3, cargo.getWeight());
            cs.setString(4, cargo.getStatus());
            cs.setInt(5, user.getUserId());
            cs.execute();
            msg = "Cargo added successfully!";
        } catch (SQLException e) { msg = "Error: " + e.getMessage(); }
        return msg;
    }

    @Override
    public String updateCargo(CargoPojo cargo, UserPojo user) {
        String msg = "";
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call update_cargo(?,?,?,?,?,?)}")) {
            cs.setInt(1, cargo.getCargoId());
            cs.setInt(2, cargo.getContainerId());
            cs.setString(3, cargo.getDescription());
            cs.setDouble(4, cargo.getWeight());
            cs.setString(5, cargo.getStatus());
            cs.setInt(6, user.getUserId());
            cs.execute();
            msg = "Cargo updated successfully!";
        } catch (SQLException e) { msg = "Error: " + e.getMessage(); }
        return msg;
    }

    @Override
    public String deleteCargo(CargoPojo cargo, UserPojo user) {
        String msg = "";
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call delete_cargo(?,?)}")) {
            cs.setInt(1, cargo.getCargoId());
            cs.setInt(2, user.getUserId());
            cs.executeUpdate();
            msg = "Cargo deleted successfully!";
        } catch (SQLException e) { msg = "Error: " + e.getMessage(); }
        return msg;
    }

    @Override
    public List<CargoMovementPojo> getCargoHistory(CargoPojo cargo, UserPojo user) {
        List<CargoMovementPojo> history = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call get_cargo_history(?,?)}")) {
            cs.setInt(1, cargo.getCargoId());
            cs.setInt(2, user.getUserId());
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    CargoMovementPojo cmp = new CargoMovementPojo();
                    cmp.setCargoId(rs.getInt("cargo_id"));
                    cmp.setMovementType(rs.getString("movement_type"));
                    cmp.setMovementDate(rs.getTimestamp("movement_date"));
                    history.add(cmp);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return history;
    }

    @Override
    public List<CargoMovementPojo> showAllDetails(UserPojo user) {
        List<CargoMovementPojo> list = new ArrayList<>();
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall("{CALL show_all_details(?)}")) {
            cstmt.setInt(1, user.getUserId());
            try (ResultSet rs = cstmt.executeQuery()) {
                while (rs.next()) {
                    CargoMovementPojo m = new CargoMovementPojo();
                    m.setMovementId(rs.getInt("movement_id"));
                    m.setCargoId(rs.getInt("cargo_id"));
                    m.setContainerId(rs.getInt("container_id"));
                    m.setShipId(rs.getInt("ship_id"));
                    m.setOperatorId(rs.getInt("operator_id"));
                    m.setHandledBy(rs.getInt("handled_by"));
                    m.setDescription(rs.getString("description"));
                    m.setWeight(rs.getDouble("weight"));
                    m.setStatus(rs.getString("status"));
                    m.setMovementType(rs.getString("movement_type"));
                    m.setMovementDate(rs.getTimestamp("movement_date"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            System.err.println("SQL Error in showAllDetails: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public String addCargoMovement(CargoMovementPojo movement) {
        String message = "Operation Failed";
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall("{CALL add_cargo_movement(?, ?, ?)}")) {
            cstmt.setInt(1, movement.getCargoId());
            cstmt.setString(2, movement.getMovementType());
            cstmt.setInt(3, movement.getHandledBy());
            cstmt.execute();
            message = "Success: Movement logged.";
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
        }
        return message;
    }

    public List<CargoMovementPojo> getAllMovements(int userId) {
        UserPojo up = new UserPojo();
        up.setUserId(userId);
        return showAllDetails(up);
    }

    @Override
    public List<ContainerPojo> viewContainers(UserPojo user) {
        List<ContainerPojo> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL view_containers(?)}")) {
            cs.setInt(1, user.getUserId());
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ContainerPojo container = new ContainerPojo();
                    container.setContainerId(rs.getInt("container_id"));
                    container.setContainerType(rs.getString("container_type"));
                    container.setStatus(rs.getString("status"));
                    int sId = rs.getInt("ship_id");
                    if (sId != 0) container.setShipId(sId);
                    list.add(container);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public UserPojo loginUser(String email, String password) {
        UserPojo user = null;
        try (Connection con = GetConnection.getConnection()) {

            String funcSql = "SELECT login_user(?, ?)";
            PreparedStatement psFunc = con.prepareStatement(funcSql);
            psFunc.setString(1, email);
            psFunc.setString(2, password);
            ResultSet rsFunc = psFunc.executeQuery();

            if (rsFunc.next() && "Login Successful ".equals(rsFunc.getString(1))) {

                String userSql = "SELECT u.user_id, u.name, u.email, r.role_name " +
                                 "FROM users u JOIN role r ON u.role_id = r.role_id " +
                                 "WHERE u.email = ?";
                PreparedStatement psUser = con.prepareStatement(userSql);
                psUser.setString(1, email);
                ResultSet rsUser = psUser.executeQuery();

                if (rsUser.next()) {
                    user = new UserPojo();
                    user.setUserId(rsUser.getInt("user_id"));
                    user.setName(rsUser.getString("name"));
                    user.setEmail(rsUser.getString("email"));
                    user.setRoleName(rsUser.getString("role_name"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return user;
    }

    @Override
    public String logoutUser(UserPojo user) {
        String status = "Error";
        try (Connection con = GetConnection.getConnection()) {
            String sql = "SELECT logout_user(?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, user.getUserId());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                status = rs.getString(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return status;
    }

    @Override
    public String changeUserPassword(UserPojo user, String oldPass, String newPass) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call change_user_password(?, ?, ?)}")) {
            cs.setInt(1, user.getUserId());
            cs.setString(2, sha256(oldPass));
            cs.setString(3, sha256(newPass));
            cs.execute();
            return "Success";
        } catch (SQLException e) {
            if (e.getErrorCode() == 1644) return "Current Password Incorrect";
            return "Error: " + e.getMessage();
        }
    }

    @Override
    public boolean updateUserName(UserPojo user, String name) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call update_user_name(?, ?)}")) {
            cs.setInt(1, user.getUserId());
            cs.setString(2, name);
            return cs.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<CargoPojo> getAllCargo(UserPojo user) {
        List<CargoPojo> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call get_all_cargo(?)}")) {
            cs.setInt(1, user.getUserId());
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    CargoPojo cargo = new CargoPojo();
                    cargo.setCargoId(rs.getInt("cargo_id"));
                    cargo.setContainerId(rs.getInt("container_id"));
                    cargo.setDescription(rs.getString("description"));
                    cargo.setWeight(rs.getDouble("weight"));
                    cargo.setStatus(rs.getString("status"));
                    list.add(cargo);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<ContainerPojo> searchContainer(String query, UserPojo user) {
        List<ContainerPojo> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call sp_search_container(?)}")) {
            cs.setString(1, query == null ? "" : query.trim());
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ContainerPojo c = new ContainerPojo();
                    c.setContainerId(rs.getInt("container_id"));
                    c.setContainerType(rs.getString("container_type"));
                    c.setStatus(rs.getString("status"));
                    c.setShipId(rs.getInt("ship_id"));
                    list.add(c);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<CargoPojo> searchCargo(String query, UserPojo user) {
        List<CargoPojo> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call sp_search_cargo(?)}")) {
            cs.setString(1, query == null ? "" : query.trim());
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    CargoPojo cp = new CargoPojo();
                    cp.setCargoId(rs.getInt("cargo_id"));
                    cp.setContainerId(rs.getInt("container_id"));
                    cp.setDescription(rs.getString("description"));
                    cp.setWeight(rs.getDouble("weight"));
                    cp.setStatus(rs.getString("status"));
                    list.add(cp);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 hashing failed", e);
        }
    }
    
    @Override
    public boolean updateUserEmail(UserPojo user, String newEmail) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call update_user_email(?, ?)}")) {
            cs.setInt(1, user.getUserId());
            cs.setString(2, newEmail);
            return cs.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
