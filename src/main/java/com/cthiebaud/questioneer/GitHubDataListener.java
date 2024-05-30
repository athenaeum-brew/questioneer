package com.cthiebaud.questioneer;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;

@WebListener
public class GitHubDataListener implements ServletContextListener {
    private static final String GITHUB_API_URL = "https://api.github.com/orgs/athenaeum-brew/repos";

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        Map<String, List<String>> data = new HashMap<>();
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

    private List<String> getRepos() throws Exception {
        String jsonResponse = getHttpResponse(GITHUB_API_URL);
        JSONArray jsonArray = (JSONArray) new JSONParser().parse(jsonResponse);
        List<String> repos = new ArrayList<>();

        for (Object obj : jsonArray) {
            org.json.simple.JSONObject repo = (org.json.simple.JSONObject) obj;
            repos.add((String) repo.get("name"));
        }

        return repos;
    }

    private List<String> getJavaFiles(String repo) throws Exception {
        String contentsUrl = "https://api.github.com/repos/athenaeum-brew/" + repo + "/contents";
        String jsonResponse = getHttpResponse(contentsUrl);
        JSONArray jsonArray = (JSONArray) new JSONParser().parse(jsonResponse);
        List<String> javaFiles = new ArrayList<>();

        for (Object obj : jsonArray) {
            org.json.simple.JSONObject file = (org.json.simple.JSONObject) obj;
            if (((String) file.get("name")).endsWith(".java")) {
                javaFiles.add((String) file.get("path"));
            }
        }

        return javaFiles;
    }

    private String getHttpResponse(String urlString) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String inputLine;
        StringBuilder content = new StringBuilder();

        while ((inputLine = in.readLine()) != null) {
            content.append(inputLine);
        }

        in.close();
        conn.disconnect();

        return content.toString();
    }
}
