package com.cthiebaud.questioneer;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.ServerEndpoint;

@ServerEndpoint(value = "/ws")
public class QuestioneerWebSocket {

    @OnOpen
    public void onOpen(final Session session) {
        QuestioneerWebSockets.INSTANCE.register(session);
    }

    @OnClose
    public void onClose(Session session) {
        QuestioneerWebSockets.INSTANCE.unregister(session);
    }

}