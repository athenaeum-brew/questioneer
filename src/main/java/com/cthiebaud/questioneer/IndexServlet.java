package com.cthiebaud.questioneer;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/")
public class IndexServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ServletContext context = getServletContext();
        String jspDir = "/"; // directory containing JSP files
        String realPath = context.getRealPath(jspDir);
        List<String> jspFiles = new ArrayList<>();

        if (realPath != null) {
            File dir = new File(realPath);
            if (dir.exists() && dir.isDirectory()) {
                File[] files = dir.listFiles((d, name) -> name.endsWith(".jsp") && name.startsWith("m"));
                if (files != null) {
                    for (File file : files) {
                        jspFiles.add(context.getContextPath() + jspDir + file.getName());
                    }
                }
            }
        }

        request.setAttribute("jspFiles", jspFiles);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/listJspFiles.jsp");
        dispatcher.forward(request, response);
    }
}
