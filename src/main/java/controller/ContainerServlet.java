package controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.ContainerPojo;
import model.UserPojo;

@WebServlet("/ContainerServlet")
public class ContainerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public ContainerServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserPojo currentUser = (UserPojo) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp?msg=Please Login First");
            return;
        }

        ContainerPojo containerModel = new ContainerPojo();
        List<ContainerPojo> list;

        @SuppressWarnings("unchecked")
        List<ContainerPojo> searchFlash = (List<ContainerPojo>) session.getAttribute("containerSearchResults");
        if (searchFlash != null) {
            session.removeAttribute("containerSearchResults");
            list = searchFlash;
        } else {
            list = containerModel.viewContainers(currentUser);
        }

        String sessionMsg = (String) session.getAttribute("msg");
        if (sessionMsg != null) {
            request.setAttribute("msg", sessionMsg);
            session.removeAttribute("msg");
        }

        request.setAttribute("containerList", list);
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserPojo currentUser = (UserPojo) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp?msg=Please Login First");
            return;
        }

        String action = request.getParameter("action");
        String query = request.getParameter("query");
        ContainerPojo containerModel = new ContainerPojo();

        if ("searchContainer".equals(action)) {
            List<ContainerPojo> results = (query != null && !query.trim().isEmpty())
                    ? containerModel.searchContainer(query, currentUser)
                    : containerModel.viewContainers(currentUser);
            session.setAttribute("containerSearchResults", results);
        }

        response.sendRedirect("ContainerServlet");
    }
}