package com.cthiebaud.questioneer;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;

import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

@WebListener
public class GitHubDataListener implements ServletContextListener {
    private static final String GITHUB_API_URL = "https://api.github.com/orgs/athenaeum-brew/repos";
    private static final String CONFIG_FILE_PATH = "/WEB-INF/config/_config.properties";
    private static String ACCESS_TOKEN;

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        ACCESS_TOKEN = getAccessToken(sce.getServletContext());

        Map<String, List<String>> data = new TreeMap<>();
        try {
            List<String> repos = getRepos();

            for (String repo : repos) {
                List<String> javaFiles = getJavaFiles(repo);
                data.put(repo, javaFiles);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        sce.getServletContext().setAttribute("githubData", data);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup if needed
    }

    private List<String> getRepos() throws IOException, ParseException {
        String jsonResponse = getHttpResponse(GITHUB_API_URL, ACCESS_TOKEN);
        JSONArray jsonArray = parseJsonResponse(jsonResponse);
        List<String> repos = new ArrayList<>();

        for (Object obj : jsonArray) {
            org.json.simple.JSONObject repo = (org.json.simple.JSONObject) obj;
            repos.add((String) repo.get("name"));
        }

        return repos;
    }

    private List<String> getJavaFiles(String repo) throws IOException, ParseException {
        return findJavaFiles(repo, "");
    }

    private List<String> findJavaFiles(String repo, String directory) throws IOException, ParseException {
        String contentsUrl = "https://api.github.com/repos/athenaeum-brew/" + repo + "/contents/" + directory;
        String jsonResponse = getHttpResponse(contentsUrl, ACCESS_TOKEN);
        JSONArray jsonArray = parseJsonResponse(jsonResponse);
        List<String> javaFiles = new ArrayList<>();

        for (Object obj : jsonArray) {
            org.json.simple.JSONObject file = (org.json.simple.JSONObject) obj;
            String filePath = (String) file.get("path");

            if ("dir".equals(file.get("type"))) {
                // If directory, recursively search for Java files
                List<String> subDirectoryJavaFiles = findJavaFiles(repo, filePath);
                javaFiles.addAll(subDirectoryJavaFiles);
            } else if (((String) file.get("name")).endsWith(".java")) {
                // If Java file, add to the list
                javaFiles.add(filePath);
            } else if ("pom.xml".equals(file.get("name"))) {
                // If pom.xml found, stop searching and add it to the list
                javaFiles.clear();
                javaFiles.add(filePath);
                break;
            }
        }

        return javaFiles;
    }

    private String getHttpResponse(String urlString, String accessToken) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();

        // Set request properties
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Accept", "application/json");
        connection.setRequestProperty("Authorization", "token " + accessToken);

        try {
            // Get response code
            int responseCode = connection.getResponseCode();

            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Read response
                StringBuilder response = new StringBuilder();
                int read;
                while ((read = connection.getInputStream().read()) != -1) {
                    response.append((char) read);
                }
                return response.toString();
            } else {
                // If not OK, return empty string
                return "";
            }
        } finally {
            connection.disconnect();
        }
    }

    private JSONArray parseJsonResponse(String jsonResponse) {
        try {
            return (JSONArray) new JSONParser().parse(jsonResponse);
        } catch (ParseException e) {
            e.printStackTrace(); // Log the error if needed
            return new JSONArray(); // Return an empty array in case of parsing error
        }
    }

    private static String getAccessToken(ServletContext sc) {
        Properties properties = new Properties();
        try (InputStream inputStream = sc.getResourceAsStream(CONFIG_FILE_PATH)) {
            properties.load(inputStream);
            return properties.getProperty("github.access.token");
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
