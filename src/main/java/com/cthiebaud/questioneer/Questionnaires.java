package com.cthiebaud.questioneer;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

public enum Questionnaires {
    INSTANCE;

    public final List<QuestionnaireRecord> questionnaires;

    Questionnaires() {
        String resourcePath = "/questions";

        URL url = this.getClass().getClassLoader().getResource(resourcePath);
        File directory = new File(url.getPath());
        if (!directory.isDirectory()) {
            throw new IllegalArgumentException("Resource is not a directory: " + resourcePath);
        }

        List<QuestionnaireRecord> mutableList;
        try {
            mutableList = Files.list(Paths.get(directory.toURI()))
                    .map(path -> {
                        String fileName = path.getFileName().toString();
                        String id = fileName.substring(0, fileName.lastIndexOf('.'));
                        String title = parseTitleFromFile(path);
                        String check = String.format("https://athenaeum.cthiebaud.com/slides/%s.md", id);
                        String slides = String.format("https://athenaeum.cthiebaud.com/slides/?%s.md", id);
                        if (!checkURL(check)) {
                            slides = null;
                        }
                        return new QuestionnaireRecord(id, title, slides);
                    })
                    .peek(System.out::println)
                    .collect(Collectors.toList());
        } catch (IOException e) {
            e.printStackTrace();
            mutableList = Collections.emptyList();
        }
        Collections.sort(mutableList, Comparator.comparing(QuestionnaireRecord::id));
        this.questionnaires = Collections.unmodifiableList(mutableList);
    }

    private String parseTitleFromFile(Path path) {
        JSONParser parser = new JSONParser();
        try (BufferedReader reader = Files.newBufferedReader(path)) {
            // Parse the JSON file
            JSONObject questionnaireJson = (JSONObject) parser.parse(reader);

            // Get the "description" field from the JSON object
            String description = (String) questionnaireJson.get("description");

            // Return the description
            return description;
        } catch (Exception e) {
            e.printStackTrace();
            return null; // Return null if there's an error
        }
    }

    public static boolean checkURL(String urlString) {
        try {
            URI uri = new URI(urlString);
            URL url = uri.toURL();
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("HEAD"); // Use HEAD to avoid fetching content
            connection.setConnectTimeout(5000); // Set timeout to 5 seconds
            connection.setReadTimeout(5000); // Set timeout to 5 seconds

            int responseCode = connection.getResponseCode();
            return responseCode == HttpURLConnection.HTTP_OK;
        } catch (Exception e) {
            return false;
        }
    }
}

