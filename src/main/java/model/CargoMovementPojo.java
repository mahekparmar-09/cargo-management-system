package model;

import java.sql.Timestamp;
import java.util.List;

import implementors.CargoOperationImplementor;

public class CargoMovementPojo {
	private int movementId; 
	private int cargoId; 
	private String movementType; 
	private Timestamp movementDate;
	private int handledBy;
	private String userName;
	private int userId;
	private int containerId;
	private int shipId;
	private int operatorId;
	private String description;
	private double weight;
	private String status;

	public CargoMovementPojo() {
	}

	public CargoMovementPojo(int movementId, int cargoId, String movementType, Timestamp movementDate, int handledBy,
			String userName, int userId, int containerId, int shipId, int operatorId, String description, double weight,
			String status) {
		
		this.movementId = movementId;
		this.cargoId = cargoId;
		this.movementType = movementType;
		this.movementDate = movementDate;
		this.handledBy = handledBy;
		this.userName = userName;
		this.userId = userId;
		this.containerId = containerId;
		this.shipId = shipId;
		this.operatorId = operatorId;
		this.description = description;
		this.weight = weight;
		this.status = status;
	}

	private CargoOperationImplementor getImpl() {
		return new CargoOperationImplementor();
	}

	public int getMovementId() {
		return movementId;
	}

	public void setMovementId(int movementId) {
		this.movementId = movementId;
	}

	public int getCargoId() {
		return cargoId;
	}

	public void setCargoId(int cargoId) {
		this.cargoId = cargoId;
	}

	public String getMovementType() {
		return movementType;
	}

	public void setMovementType(String movementType) {
		this.movementType = movementType;
	}

	public Timestamp getMovementDate() {
		return movementDate;
	}

	public void setMovementDate(Timestamp movementDate) {
		this.movementDate = movementDate;
	}

	public int getHandledBy() {
		return handledBy;
	}

	public void setHandledBy(int handledBy) {
		this.handledBy = handledBy;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public int getContainerId() {
		return containerId;
	}

	public void setContainerId(int containerId) {
		this.containerId = containerId;
	}

	public int getShipId() {
		return shipId;
	}

	public void setShipId(int shipId) {
		this.shipId = shipId;
	}

	public int getOperatorId() {
		return operatorId;
	}

	public void setOperatorId(int operatorId) {
		this.operatorId = operatorId;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public double getWeight() {
		return weight;
	}

	public void setWeight(double weight) {
		this.weight = weight;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String addCargoMovement(CargoMovementPojo movement) {
		return getImpl().addCargoMovement(movement);
	}

	public List<CargoMovementPojo> showAllDetails(UserPojo user) {
		return getImpl().showAllDetails(user);
	}

}
