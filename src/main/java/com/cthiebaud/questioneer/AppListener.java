package com.cthiebaud.questioneer;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("contextInitialized with 30 seconds session cookie");
        sce.getServletContext().getSessionCookieConfig().setMaxAge(30); // cookie timeout in seconds
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Do something when context is destroyed, if needed
    }
}
