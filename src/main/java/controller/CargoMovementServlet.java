package controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.CargoMovementPojo;
import model.UserPojo;

@WebServlet("/CargoMovementServlet")
public class CargoMovementServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserPojo currentUser = (UserPojo) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp?msg=Session Expired");
            return;
        }

        String action = request.getParameter("action");
        CargoMovementPojo pojo = new CargoMovementPojo();

        if ("viewLog".equals(action) || action == null) {
            List<CargoMovementPojo> list = pojo.showAllDetails(currentUser);
            request.setAttribute("movementList", list);

            String sessionMsg = (String) session.getAttribute("msg");
            if (sessionMsg != null) {
                request.setAttribute("msg", sessionMsg);
                session.removeAttribute("msg");
            }

            request.getRequestDispatcher("cargoMovement.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        UserPojo currentUser = (UserPojo) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp?msg=Session Expired");
            return;
        }

        if ("addCargoMovement".equals(action)) {
            try {
                CargoMovementPojo movement = new CargoMovementPojo();
                movement.setCargoId(Integer.parseInt(request.getParameter("cargo_id")));
                movement.setMovementType(request.getParameter("movement_type"));

                String handledByParam = request.getParameter("handled_by");
                int userId = (handledByParam != null) ? Integer.parseInt(handledByParam) : currentUser.getUserId();
                movement.setHandledBy(userId);

                CargoMovementPojo service = new CargoMovementPojo();
                String result = service.addCargoMovement(movement);

                session.setAttribute("msg", result);
                response.sendRedirect("CargoMovementServlet?action=viewLog");

            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("msg", "Error: " + e.getMessage());
                response.sendRedirect("CargoMovementServlet?action=viewLog");
            }
        }
    }
}