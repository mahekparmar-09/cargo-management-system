package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.UserPojo;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserPojo userModel = new UserPojo();

        UserPojo user = userModel.loginUser(email, password);

        if (user != null) {
            HttpSession session = request.getSession();
            
            session.setAttribute("user", user); 
            session.setAttribute("user_id", user.getUserId());

            response.sendRedirect("ContainerServlet?action=viewAll");
        } else {
            response.sendRedirect("login.jsp?msg=Invalid Email or Password");
        }
    }
}