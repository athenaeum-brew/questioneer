package com.cthiebaud.questioneer;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.Collections;
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
    private static final String CONFIG_FILE_PATH = "/WEB-INF/config/config.properties";
    private static String ACCESS_TOKEN;

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        ACCESS_TOKEN = getAccessToken(sce.getServletContext());

        Map<String, List<String>> data = new TreeMap<>();
        try {
            List<String> repos = getRepos();

            for (String repo : repos) {
                List<String> javaFiles = getJavaFiles(repo);
                if (javaFiles.size() > 0) {
                    data.put(repo, javaFiles);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Make the map immutable
        Map<String, List<String>> immutableData = Collections.unmodifiableMap(data);

        sce.getServletContext().setAttribute("githubData", immutableData);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup if needed
        sce.getServletContext().removeAttribute("githubData");
    }

    private List<String> getRepos() {
        JSONArray jsonArray = getJsonResponse(GITHUB_API_URL, ACCESS_TOKEN);
        if (jsonArray == null) {
            return Collections.emptyList();
        }
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
        JSONArray jsonArray = getJsonResponse(contentsUrl, ACCESS_TOKEN);
        if (jsonArray == null) {
            return Collections.emptyList();
        }
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

    public JSONArray getJsonResponse(String urlString, String accessToken) {
        try {
            URI uri = new URI(urlString.replaceAll(" ", "%20"));
            HttpClient client = HttpClient.newHttpClient();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(uri)
                    .header("Accept", "application/json")
                    .header("Authorization", "token " + accessToken)
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                try {
                    return (JSONArray) new JSONParser().parse(response.body());
                } catch (ParseException e) {
                    e.printStackTrace(); // Log the error if needed
                    return null; // Return null in case of parsing error
                }
            } else {
                return null; // Return null if the response status is not 200
            }
        } catch (IOException | URISyntaxException | InterruptedException e) {
            e.printStackTrace(); // Log any exception
            return null; // Return null in case of any exception
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
