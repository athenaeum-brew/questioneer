package com.cthiebaud.questioneer;

import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import jakarta.websocket.Session;

public enum QuestioneerWebSockets {
    INSTANCE;

    final private Set<Session> activeWebSockets = Collections.synchronizedSet(new HashSet<>());

    public void register(Session session) {
        System.out.println("added web socket " + session.getId());
        activeWebSockets.add(session);
    }

    public void unregister(Session session) {
        System.out.println("removed web socket " + session.getId());
        activeWebSockets.remove(session);
    }

    public void broadcast(QuestioneerWebSocketMessageType type, String message) {
        System.out.println(
                "broadcasting message \"" + message + "\" to " + activeWebSockets.size() + " active web sockets");
        for (Session session : activeWebSockets) {
            try {
                session.getBasicRemote().sendText(type + ":" + message);
            } catch (IOException e) {
                // throw new RuntimeException(e);
                System.err.println("Could not send text to " + session.getId() + " - " + e.getMessage());
            }
        }
    }
}
