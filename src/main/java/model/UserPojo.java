package model;

import implementors.CargoOperationImplementor;

public class UserPojo {
	private int userId;
	private String name;
	private String email;
	private String password;
	private int roleId;
	private String roleName;

	public UserPojo() {
	}

	public UserPojo(int userId, String name, String email, String password, int roleId, String roleName) {
		this.userId = userId;
		this.name = name;
		this.email = email;
		this.password = password;
		this.roleId = roleId;
		this.roleName = roleName;
	}

	private CargoOperationImplementor getImpl() {
		return new CargoOperationImplementor();
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public int getRoleId() {
		return roleId;
	}

	public void setRoleId(int roleId) {
		this.roleId = roleId;
	}

	public String getRoleName() {
		return roleName;
	}

	public void setRoleName(String roleName) {
		this.roleName = roleName;
	}

	public UserPojo loginUser(String email, String password) {
		return getImpl().loginUser(email, password);
	}

	public String logoutUser(UserPojo user) {
		return getImpl().logoutUser(user);
	}

	public String changeUserPassword(UserPojo user, String old, String n) {
		return getImpl().changeUserPassword(user, old, n);
	}

	public boolean updateUserName(UserPojo user, String name) {
		return getImpl().updateUserName(user, name);
	}
	
	public boolean updateUserEmail(UserPojo user, String newEmail) {
	    return getImpl().updateUserEmail(user, newEmail);
	}
}
