<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Active Sessions Counter</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    </head>

    <body>
        <main class="container">

            <h1>Active Sessions Counter</h1>
            <h2>Active Sessions:
                <span id="activeSessions">
                    <%= application.getAttribute("counter") %>
                </span>
            </h2>

        </main>

        <script>
            // Determine the WebSocket protocol based on the current page's protocol
            const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
            // Check if the current URL contains "/questioneer"
            const path = window.location.pathname.includes("/questioneer") ? "/questioneer/ws" : "/ws";
            const socket = new WebSocket(protocol + "//" + window.location.host + path);
            const activeSessionsElement = document.getElementById("activeSessions");
            socket.onmessage = function (event) {
                const activeSessions = event.data;
                activeSessionsElement.textContent = activeSessions;
            }; 
        </script>
    </body>

    </html>