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
            <!-- Add Bootstrap secondary button -->
            <button id="fetchButton" class="btn btn-secondary">Fetch Anything from Server</button>

        </main>

        <script>
            // Determine the WebSocket protocol based on the current page's protocol
            const protocol = window.location.protocol === "https:" ? "wss:" : "ws:"
            // Check if the current URL contains "/questioneer"
            const path = window.location.pathname.includes("/questioneer") ? "/questioneer/ws" : "/ws"
            const socket = new WebSocket(protocol + "//" + window.location.host + path)
            const activeSessionsElement = document.getElementById("activeSessions")
            socket.onmessage = function (event) {
                const activeSessions = event.data
                activeSessionsElement.textContent = activeSessions
            }

            
            // Add event listener to the button
            document.getElementById("fetchButton").addEventListener("click", function () {
                const fetchButton = document.getElementById("fetchButton");
                // Disable the button
                fetchButton.disabled = true;

                // Make a fetch request to the same URL of the page
                const fetchPromise = fetch(window.location.href)
                    .then(response => response.text())
                    .then(data => {
                        console.log("Fetch successful:", data.substring(0, 100) + " ...");
                        // Optionally, you can update the page with the fetched data
                    })
                    .catch(error => console.error("Fetch error:", error));

                // Create a promise that resolves after 1 second
                const delayPromise = new Promise(resolve => setTimeout(resolve, 1000));

                // Use Promise.all to wait for both the fetch and delay promises
                Promise.all([fetchPromise, delayPromise]).finally(() => {
                    // Re-enable the button after the response is received or 1 second has elapsed, whichever is later
                    fetchButton.disabled = false;
                });
            });
        </script>
    </body>

    </html>