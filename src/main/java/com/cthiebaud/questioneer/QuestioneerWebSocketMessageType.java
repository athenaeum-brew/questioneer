package com.cthiebaud.questioneer;

import java.util.Arrays;

public enum QuestioneerWebSocketMessageType {
    COUNTER,
    GOOD,
    BAD;

    // Method to generate an array of type prefixes
    public static String[] getTypePrefixes() {
        return Arrays.stream(values())
                .map(type -> type.toString() + ":")
                .toArray(String[]::new);
    }
}
