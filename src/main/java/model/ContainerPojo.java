package model;

import java.util.List;

import implementors.CargoOperationImplementor;

public class ContainerPojo {
	private int containerId;
	private String containerType;
	private String status;
	private int shipId;

	public ContainerPojo() {
	}

	public ContainerPojo(int containerId, String containerType, String status, int shipId) {
		this.containerId = containerId;
		this.containerType = containerType;
		this.status = status;
		this.shipId = shipId;
	}

	private CargoOperationImplementor getImpl() {
		return new CargoOperationImplementor();
	}

	public int getContainerId() {
		return containerId;
	}

	public void setContainerId(int containerId) {
		this.containerId = containerId;
	}

	public String getContainerType() {
		return containerType;
	}

	public void setContainerType(String containerType) {
		this.containerType = containerType;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public int getShipId() {
		return shipId;
	}

	public void setShipId(int shipId) {
		this.shipId = shipId;
	}

	public List<ContainerPojo> viewContainers(UserPojo user) {
		return getImpl().viewContainers(user);
	}

	public List<ContainerPojo> searchContainer(String query, UserPojo user) {
		return getImpl().searchContainer(query, user);
	}
}
