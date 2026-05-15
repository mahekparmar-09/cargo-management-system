package operations;

import java.util.List;

import model.CargoMovementPojo;
import model.CargoPojo;
import model.ContainerPojo;
import model.UserPojo;

public interface CargoOperations {
	String addCargo(CargoPojo cargo, UserPojo user);

	String updateCargo(CargoPojo cargo, UserPojo user);

	String deleteCargo(CargoPojo cargo, UserPojo user);

	List<CargoPojo> getAllCargo(UserPojo user);

	String addCargoMovement(CargoMovementPojo movement);

	List<ContainerPojo> viewContainers(UserPojo user);

	List<CargoMovementPojo> getCargoHistory(CargoPojo cargo, UserPojo user);

	List<CargoMovementPojo> showAllDetails(UserPojo user);

	UserPojo loginUser(String email, String password);

	String logoutUser(UserPojo user);

	String changeUserPassword(UserPojo user, String oldPass, String newPass);

	boolean updateUserName(UserPojo user, String name);
	
	List<CargoPojo> searchCargo(String query, UserPojo user);

	List<ContainerPojo> searchContainer(String query, UserPojo user);
	
	boolean updateUserEmail(UserPojo user, String newEmail);
}