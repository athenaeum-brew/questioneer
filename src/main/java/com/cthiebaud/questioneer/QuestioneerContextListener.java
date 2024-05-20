package com.cthiebaud.questioneer;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class QuestioneerContextListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("contextInitialized with 30 seconds session cookie");
        sce.getServletContext().getSessionCookieConfig().setMaxAge(30); // cookie timeout in seconds
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // All servlets and filters will have been destroyed before any
        // ServletContextListeners are notified of context destruction.
    }
}
