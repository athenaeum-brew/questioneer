package com.cthiebaud.questioneer;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebListener
public class QuestioneerContextListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        String jspDir = "/"; // directory containing JSP files
        String realPath = context.getRealPath(jspDir);
        List<String> jspFiles = new ArrayList<>();

        if (realPath != null) {
            File dir = new File(realPath);
            if (dir.exists() && dir.isDirectory()) {
                File[] files = dir.listFiles((d, name) -> name.endsWith(".jsp") && name.startsWith("m"));
                if (files != null) {
                    for (File file : files) {
                        System.out.println(file);
                        jspFiles.add(context.getContextPath() + jspDir + file.getName());
                    }
                }
            }
        }

        // Sort the list alphabetically
        Collections.sort(jspFiles);

        context.setAttribute("jspFiles", jspFiles);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        context.removeAttribute("jspFiles");
    }
}
