package model;

import java.util.List;
import implementors.CargoOperationImplementor;

public class CargoPojo {
	private int cargoId;
	private int containerId;
	private String description;
	private double weight;
	private String status;

	public CargoPojo() {
	}
	
	public CargoPojo(int carogId, int containerId, String description, double weight, String status) {
		this.cargoId = carogId;
		this.containerId = containerId;
		this.description = description;
		this.status = status;
		this.status = status;
	}
	
	public int getCargoId() {
		return cargoId;
	}

	public void setCargoId(int cargoId) {
		this.cargoId = cargoId;
	}

	public int getContainerId() {
		return containerId;
	}

	public void setContainerId(int containerId) {
		this.containerId = containerId;
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

	public void setWeight(Double weight) {
		this.weight = weight;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}
 
	private CargoOperationImplementor getImpl() {
		return new CargoOperationImplementor();
	}

	public String addCargo(CargoPojo cargo, UserPojo user) {
		return getImpl().addCargo(cargo, user);
	}

	public String updateCargo(CargoPojo cargo, UserPojo user) {
		return getImpl().updateCargo(cargo, user);
	}

	public String deleteCargo(CargoPojo cargo, UserPojo user) {
		return getImpl().deleteCargo(cargo, user);
	}

	public List<CargoPojo> getAllCargo(UserPojo user) {
		return getImpl().getAllCargo(user);
	}

	public List<CargoPojo> searchCargo(String query, UserPojo user) {
	    return getImpl().searchCargo(query, user);
	}
}