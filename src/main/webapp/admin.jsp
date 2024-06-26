<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cthiebaud.questioneer.PartialAnswerServlet" %>
<%@ page import="com.cthiebaud.questioneer.QuestioneerWebSocketMessageType" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.stream.Stream" %>
<!DOCTYPE html>
<html>

<head>
    <%@ include file="header.jspf" %>    

    <title>Dashboard</title>
</head>

<body>
    <main class="container my-3">
        <a href="${normalizedContextPath}" style="float:right; text-decoration: none; font-size: 32px;">⌂</a>
        <h1>Dashboard</h1>
    
        <!-- Active Sessions Card -->
        <div class="card mb-3">
            <div class="card-body">
                <h2 class="card-title">Active Sessions:
                    <span id="activeSessions">
                        <%= application.getAttribute("counter") %>
                    </span>
                </h2>
                <button id="fetchButton" class="btn btn-secondary">Fetch Anything from Server</button>
            </div>
        </div>
    
        <!-- Quiz Response Tally Card -->
        <div class="card">
            <div class="card-body">
                <h2 class="card-title">Quiz Responses Tally<sup>*</sup></h2>
                <table class="table mt-2">
                    <thead>
                        <tr>
                            <th scope="col">✅</th>
                            <th scope="col" style="text-align: end;">❌</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>
                                <div id="goodAnswers"><%= PartialAnswerServlet.goods.get() %></div>
                            </td>
                            <td>
                                <div id="badAnswers" style="text-align: end;"> <%= PartialAnswerServlet.bads.get() %></div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <div class="progress my-3" style="height: 30px;">
                    <div id="progressBar" class="progress-bar custom-progress-bar" role="progressbar"
                    aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"
                    style="width: 0%;background-color: #28a745 !important" ></div>
                </div>                
                <button id="resetButton" class="btn btn-secondary">Reset ✅ and ❌ Counters</button>
            </div>
        </div>
    </main>

    <!-- Fixed bottom footer -->
    <footer class="footer fixed-bottom ">
        <div class="container">
            <span>(*) Tally: a record or count of a number of items (<a href="https://dictionary.cambridge.org/dictionary/english/tally">dictionary.cambridge.org</a>)</span>
        </div>
    </footer>    
    
    <script type="module">
        // Define JavaScript array with enum values received from the server
        // Perhaps one of the most horrible code I have ever seen
        const typePrefixes = ['<%= String.join(":', '", Arrays.stream(QuestioneerWebSocketMessageType.values()).map(Enum::name).toArray(String[]::new)) %>:'];

        // Determine the WebSocket protocol based on the current page's protocol
        const protocol = window.location.protocol === "https:" ? "wss:" : "ws:"
        // Check if the current URL contains "/questioneer"
        const path = "${normalizedContextPath}ws"
        const socket = new WebSocket(protocol + "//" + window.location.host + path)
        const activeSessionsElement = document.getElementById("activeSessions")
        const goodAnswersElement = document.getElementById("goodAnswers")
        const badAnswersElement = document.getElementById("badAnswers")
        socket.onmessage = function (event) {
            const data = event.data.trim(); // Trim any leading or trailing whitespace

            // Check if the data starts with any of the prefixes
            const matchedPrefix = typePrefixes.find(prefix => data.startsWith(prefix));

            if (matchedPrefix) {
                // Extract the actual data after removing the prefix
                const trimmedData = data.substring(matchedPrefix.length).trim();

                // Update corresponding element based on prefix
                switch (matchedPrefix) {
                    case 'COUNTER:':
                        activeSessionsElement.textContent = trimmedData;
                        break;
                    case 'GOOD:':
                        goodAnswersElement.textContent = trimmedData;
                        updateProgressBar();
                        break;
                    case 'BAD:':
                        badAnswersElement.textContent = trimmedData;
                        updateProgressBar();
                        break;
                    default:
                        break;
                }
            }
        };

        function updateProgressBar() {
            const goodAnswers = parseInt(goodAnswersElement.textContent);
            const badAnswers = parseInt(badAnswersElement.textContent);
            const totalAnswers = goodAnswers + badAnswers;
            const percentage = totalAnswers === 0 ? 0 : (goodAnswers / totalAnswers) * 100;

            progressBar.style.width = percentage + '%';
            progressBar.setAttribute('aria-valuenow', percentage);

            if (totalAnswers !== 0) {
                progressBar.innerText = percentage.toFixed(0) + '% of ' + totalAnswers;
            } else {
                progressBar.innerText = '';
            }            
        }        
        updateProgressBar();

        // Add event listener to the button
        document.getElementById("resetButton").addEventListener("click", function () {
            fetch('partial', {
                method: 'DELETE'
            }).then(response => response.text())
                .then(result => console.log(result))
                .catch(error => console.error('Error:', error));
        });

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