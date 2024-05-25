package com.cthiebaud.questioneer;

import java.io.IOException;
import java.util.Set;

import jakarta.websocket.Session;
import java.util.concurrent.ConcurrentHashMap;

public enum QuestioneerWebSockets {
    INSTANCE;

    final private Set<Session> activeWebSockets = ConcurrentHashMap.newKeySet();

    public void register(Session session) {
        System.out.println("added web socket " + session.getId());
        activeWebSockets.add(session);
    }

    public void unregister(Session session) {
        System.out.println("removed web socket " + session.getId());
        activeWebSockets.remove(session);
    }

    public void broadcast(QuestioneerWebSocketMessageType type, String message) {
        if (activeWebSockets.size() == 0) {
            return;
        }
        System.out.println(
                String.format("broadcasting message %s:%s to %d active web sockets",
                        type,
                        message,
                        activeWebSockets.size()));

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
