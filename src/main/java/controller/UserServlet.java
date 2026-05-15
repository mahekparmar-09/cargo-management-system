package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.UserPojo;

@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        UserPojo currentUser = (UserPojo) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp?msg=Session Expired");
            return;
        }

        UserPojo pojo = new UserPojo();

        if ("updateProfile".equals(action)) {
            String newName = request.getParameter("name");
            boolean success = pojo.updateUserName(currentUser, newName);
            if (success) {
                currentUser.setName(newName);
                session.setAttribute("user", currentUser);
                session.setAttribute("profileMsg", "Profile Updated Successfully");
            } else {
                session.setAttribute("profileMsg", "Update Failed");
            }
            response.sendRedirect("profile.jsp");

        } else if ("changePassword".equals(action)) {
            String oldPass = request.getParameter("oldPassword");
            String newPass = request.getParameter("newPassword");
            String confirmPass = request.getParameter("confirmPassword");

            if (!newPass.equals(confirmPass)) {
                session.setAttribute("profileMsg", "New Passwords Do Not Match");
                response.sendRedirect("profile.jsp");
                return;
            }

            String result = pojo.changeUserPassword(currentUser, oldPass, newPass);
            session.setAttribute("profileMsg", "Success".equals(result) ? "Password Changed Successfully" : result);
            response.sendRedirect("profile.jsp");
        } else if ("updateEmail".equals(action)) {
            String newEmail = request.getParameter("newEmail");

            if (newEmail == null || newEmail.trim().isEmpty()) {
                session.setAttribute("profileMsg", "Email cannot be empty");
                response.sendRedirect("profile.jsp");
                return;
            }

            boolean success = pojo.updateUserEmail(currentUser, newEmail.trim());
            if (success) {
                currentUser.setEmail(newEmail.trim());
                session.setAttribute("user", currentUser);
                session.setAttribute("profileMsg", "Email Updated Successfully");
            } else {
                session.setAttribute("profileMsg", "Email Update Failed — Email may already be in use");
            }
            response.sendRedirect("profile.jsp");
        }
    }
}