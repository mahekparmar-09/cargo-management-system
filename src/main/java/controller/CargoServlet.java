package controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.CargoPojo;
import model.UserPojo;

@WebServlet("/CargoServlet")
public class CargoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String query = request.getParameter("query");
        HttpSession session = request.getSession();
        UserPojo user = (UserPojo) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp?msg=Session Expired");
            return;
        }

        CargoPojo pojo = new CargoPojo();
        List<CargoPojo> list = null;

        if ("delete".equals(action)) {
            String cid = request.getParameter("cargoId");
            if(cid != null) {
                CargoPojo cargoToDelete = new CargoPojo();
                cargoToDelete.setCargoId(Integer.parseInt(cid));
                String msg = pojo.deleteCargo(cargoToDelete, user);
                session.setAttribute("msg", msg);
            }
            response.sendRedirect("CargoServlet?action=viewAll");
            return;
        }

        @SuppressWarnings("unchecked")
        List<CargoPojo> searchFlash = (List<CargoPojo>) session.getAttribute("cargoSearchResults");
        if (searchFlash != null) {
            session.removeAttribute("cargoSearchResults");
            list = searchFlash;
        } else {
            list = pojo.getAllCargo(user);
        }

        String sessionMsg = (String) session.getAttribute("msg");
        if (sessionMsg != null) {
            request.setAttribute("msg", sessionMsg);
            session.removeAttribute("msg");
        }

        request.setAttribute("cargoList", list);
        request.getRequestDispatcher("viewCargo.jsp").forward(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        UserPojo user = (UserPojo) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp?msg=Session Expired");
            return;
        }

        CargoPojo pojo = new CargoPojo();
        CargoPojo cp = new CargoPojo();

        try {
            if ("add".equals(action)) {
                cp.setContainerId(Integer.parseInt(request.getParameter("containerId")));
                cp.setDescription(request.getParameter("description"));
                cp.setWeight(Double.parseDouble(request.getParameter("weight")));
                cp.setStatus(request.getParameter("status"));

                String message = pojo.addCargo(cp, user); 
                session.setAttribute("msg", message);
                response.sendRedirect("CargoServlet?action=viewAll"); 

            } else if ("update".equals(action)) {
                cp.setCargoId(Integer.parseInt(request.getParameter("cargoId")));
                cp.setContainerId(Integer.parseInt(request.getParameter("containerId")));
                cp.setDescription(request.getParameter("description"));
                cp.setWeight(Double.parseDouble(request.getParameter("weight")));
                cp.setStatus(request.getParameter("status"));

                String message = pojo.updateCargo(cp, user);
                session.setAttribute("msg", message);
                response.sendRedirect("CargoServlet?action=viewAll");

            } else if ("searchCargo".equals(action)) {
                String query = request.getParameter("query");
                List<CargoPojo> results = (query != null && !query.trim().isEmpty())
                        ? pojo.searchCargo(query, user)
                        : pojo.getAllCargo(user);
                session.setAttribute("cargoSearchResults", results);
                response.sendRedirect("CargoServlet?action=viewAll");
            }
        } catch (Exception e) {
            session.setAttribute("msg", "Error: " + e.getMessage());
            response.sendRedirect("CargoServlet?action=viewAll");
        }
    }
}