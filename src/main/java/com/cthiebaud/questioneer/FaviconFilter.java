package com.cthiebaud.questioneer;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;

@WebFilter("*.jsp")
public class FaviconFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code here, if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Inject HTML fragments here
        String faviconHtml = "<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/favicon/apple-touch-icon.png\">\n"
                + "<link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"/favicon/favicon-32x32.png\">\n"
                + "<link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"/favicon/favicon-16x16.png\">\n"
                + "<link rel=\"manifest\" href=\"/favicon/site.webmanifest\">\n"
                + "<link rel=\"mask-icon\" href=\"/favicon/safari-pinned-tab.svg\" color=\"#1cb261\">\n"
                + "<link rel=\"shortcut icon\" href=\"/favicon/favicon.ico\">\n"
                + "<meta name=\"msapplication-TileColor\" content=\"#2b5797\">\n"
                + "<meta name=\"msapplication-config\" content=\"/favicon/browserconfig.xml\">\n"
                + "<meta name=\"theme-color\" content=\"#ffffff\">\n";

        // Write the favicon HTML to the response
        response.getWriter().write(faviconHtml);

        // Continue with the filter chain
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup code here, if needed
    }
}
