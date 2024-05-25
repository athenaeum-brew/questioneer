<%@ page import="org.json.simple.JSONObject, org.json.simple.parser.JSONParser" %>
<%@ page import="java.io.InputStream, java.io.InputStreamReader, java.nio.charset.StandardCharsets" %>
<%@ page import="java.net.URL, java.util.Scanner" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <%@ include file="header.jspf" %>    

    <title>Quizz</title>

    <style>
        .progress {
            height: 20px;
        }

        .progress-bar {
            width: 100%;
        }

        .wrong {
            text-decoration: line-through;
        }
    </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.7.8/handlebars.min.js"></script>
    <script id="question-summary-template" type="text/x-handlebars-template">
        <div class="card mb-3">
            <div class="card-body">
                <h5>{{index}}. {{question}} {{#if studentAnswersMatch}}✅{{else}}❌{{/if}}</h5>
                <p><strong>Correct Answer(s):</strong> 
                    <ul>
                    {{#each correctAnswersSummary}}
                        <li>{{{escapeHtml this}}}</li>
                    {{/each}}
                    </ul>
                </p>
                {{#unless studentAnswersMatch}}
                <p><strong>Your Answer(s):</strong>
                    <ul>
                    {{#each studentAnswersSummary}}
                        <li class="{{#endsWithSadFace this}}wrong{{/endsWithSadFace}}">{{{escapeHtml this}}}</li>
                    {{/each}}
                    </ul>
                </p>
                {{/unless}}
            </div>
        </div>
    </script>    

</head>

<body>
    <div class="container my-3">
        <div style="float:right;">
            <a href="<%= application.getContextPath() %>" style="text-decoration: none; font-size: 32px;">⌂</a>
            <a href="admin" target="_admin" style="text-decoration: none; font-size: 32px;">⬡</a>
        </div>
        <h1 id="questionnaire-title"></h1>
        <p id="questionnaire-comment" style="font-style: italic;"></p>
        <div id="questionnaire" class="card">
            <div class="card-body">
                <h5 id="question" class="card-title"></h5>
                <form id="answers" class="mb-3"></form>
                <div class="progress">
                    <div id="progress-bar" class="progress-bar" role="progressbar"></div>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                    <button id="next-button" class="btn btn-primary mt-3" onclick="nextQuestion()">Next</button>
                    <div>
                        <div class="font-monospace" style="text-align: end;">
                            <span id="current">current</span>/<span id="total">total</span>
                        </div>
                        <div id="results" style="text-align: end;"></div>
                    </div>
                </div>
            </div>
        </div>
        <div id="summaryContainer" style="display:none;">
            <div id="summary"></div>
            <!-- Summary content will be dynamically added here -->
            <button id="replay-button" class="btn btn-primary mt-3" onclick="replay()">Replay</button>
        </div>
        
    </div>

    <script>
        let questionnaire;
        let currentQuestionIndex = 0;
        let timer;
        let timeLeft = 60;
        let progressBar;
        let nextButton;
        let studentAnswers = [];
        let questionnaireTitle;
        let questionnaireComment;

        // https://bost.ocks.org/mike/shuffle/
        function shuffle(array) {
            var m = array.length, t, i;

            // While there remain elements to shuffle…
            while (m) {

                // Pick a remaining element…
                i = Math.floor(Math.random() * m--);

                // And swap it with the current element.
                t = array[m];
                array[m] = array[i];
                array[i] = t;
            }

            return array;
        }        

        function loadQuestionnaire() {
            const questionnaireJson = '<%= getQuestionnaireJson(request.getParameter("file")) %>';
            const quizz = JSON.parse(questionnaireJson);
            shuffle(quizz.questions);
            return quizz;
        }

        function escapeHtml(unsafe) {
            return unsafe
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }
        Handlebars.registerHelper('escapeHtml', function(unsafe) {
            return new Handlebars.SafeString(escapeHtml(unsafe));
        });        
        // Define the Handlebars helper function
        Handlebars.registerHelper('endsWithSadFace', function(string, options) {
            console.log("endsWithSadFace?", string)
            if (string.endsWith('🙁')) {
                return options.fn(this);
            } else {
                return options.inverse(this);
            }
        });        

        function showQuestionnaire() {
            clearInterval(timer);
            timeLeft = 60;
            progressBar.style.width = '100%';

            if (currentQuestionIndex >= questionnaire.questions.length) {
                submitAnswers();
                return;
            }

            document.getElementById('current').innerText = currentQuestionIndex + 1;
            document.getElementById('total').innerText = questionnaire.questions.length;

            if (currentQuestionIndex === questionnaire.questions.length - 1) {
                document.getElementById("next-button").innerText = "Submit";
            }

            const question = questionnaire.questions[currentQuestionIndex];
            document.getElementById('question').innerText = question.question;

            const answersContainer = document.getElementById('answers');
            answersContainer.innerHTML = '';

            question.answers.forEach((answer, index) => {
                const answerElement = document.createElement('div');
                answerElement.classList.add('form-check');
                const safe = escapeHtml(answer);
                answerElement.innerHTML = `
                    <input class="form-check-input" type="checkbox" value="\${index}" id="answer\${index}">
                    <label class="form-check-label" for="answer\${index}">\${safe}</label>
                `;
                answersContainer.appendChild(answerElement);
            });

            startTimer();
        }

        function startTimer() {
            timer = setInterval(() => {
                timeLeft--;
                const progress = (timeLeft / 60) * 100;
                progressBar.style.width = progress + '%';

                if (timeLeft <= 0) {
                    nextQuestion();
                }
            }, 1000);
        }

        function nextQuestion() {
            saveAnswer();
            currentQuestionIndex++;
            showQuestionnaire();
        }

        function saveAnswer() {
            const question = questionnaire.questions[currentQuestionIndex];
            const selectedAnswers = [];
            question.answers.forEach((_, index) => {
                const answerElement = document.getElementById(`answer\${index}`);
                if (answerElement.checked) {
                    selectedAnswers.push(index);
                }
            });

            const studentAnswerData = {
                question: question.question,
                selectedAnswers: selectedAnswers,
                isCorrect: checkStudentAnswers(question.correct, selectedAnswers)
            };

            document.getElementById('results').innerHTML += studentAnswerData.isCorrect ? ' ✅' : ' ❌';

            studentAnswers.push(studentAnswerData);

            // Post the answer to the server
            fetch('partial', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(studentAnswerData)
            }).then(response => response.text()).then(result => {
                console.log('Partial result:', result);
            }).catch(error => console.error('Error:', error));
        }

        function submitAnswers() {
            clearInterval(timer);
            fetch('submitAnswers', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(studentAnswers)
            }).then(response => response.text()).then(result => {
                // document.getElementById('questionnaire').innerHTML = '<h5>Thank you for completing the questionnaire!</h5>';
                document.getElementById('questionnaire').style.display = 'none'
                displaySummary(); // Display summary after submitting answers
            }).catch(error => console.error('Error:', error));
        }

        document.addEventListener('DOMContentLoaded', () => {
            progressBar = document.getElementById('progress-bar');
            nextButton = document.getElementById('next-button');
            questionnaireTitle = document.getElementById('questionnaire-title');
            questionnaireComment = document.getElementById('questionnaire-comment');
            questionnaire = loadQuestionnaire();
            showQuestionnaireTitle(questionnaire.description);
            showQuestionnaireComment(questionnaire.comment);
            showQuestionnaire();
        });

        function showQuestionnaireTitle(description) {
            questionnaireTitle.innerText = description;
        }

        function showQuestionnaireComment(comment) {
            if (comment) {
                questionnaireComment.style.display = 'block'
                questionnaireComment.innerText = comment;
            } else {
                questionnaireComment.style.display = 'none'
            } 
        }

        const questionSummaryTemplate = Handlebars.compile(document.getElementById('question-summary-template').innerHTML);

        function displaySummary() {
            const summaryContainer = document.getElementById('summaryContainer');
            summaryContainer.style.display = 'block'
            const summary = document.getElementById('summary');
            summary.innerHTML = '<h2>Questionnaire Summary</h2>';

            questionnaire.questions.forEach((question, index) => {
                const questionSummary = document.createElement('div');
                questionSummary.classList.add('question-summary');

                // Check if student's answers match correct answers
                const studentAnswer = studentAnswers[index].selectedAnswers
                const studentAnswersMatch = checkStudentAnswers(question.correct,  studentAnswer);
                
                questionSummary.innerHTML = questionSummaryTemplate({
                    index: index + 1,
                    question: question.question,
                    studentAnswersMatch: studentAnswersMatch,
                    correctAnswersSummary: getCorrectAnswersSummary(question),
                    studentAnswersSummary: getStudentAnswersSummary(question, studentAnswer)
                });
                summary.appendChild(questionSummary);
            });

            // Hide the questionnaire
            document.getElementById('questionnaire').style.display = 'none';
        }

        function checkStudentAnswers(correctAnswers, studentAnswers) {
            if (correctAnswers.length !== studentAnswers.length) {
                return false;
            }
            const correctSet = new Set(correctAnswers);
            for (const answer of studentAnswers) {
                if (!correctSet.has(answer)) {
                    return false;
                }
            }
            return true;
        }

        function getStudentAnswersSummary(question, studentAnswer) {
            if (studentAnswer.length == 0)
                return ["No Answer given."]
            const studentAnswersSum = studentAnswer.map(index => {
                if (question.correct.includes(index)) {
                    return question.answers[index]
                } else {
                    return question.answers[index] + " 🙁"
                }
            });
            return studentAnswersSum;
        }

        function getCorrectAnswersSummary(question) {
            const correctIndexes = question.correct;
            const correctAnswers = correctIndexes.map(index => question.answers[index]);
            return correctAnswers;
        }

        function replay() {
            // Clear studentAnswers array
            studentAnswers = [];
            
            // Reset currentQuestionIndex to 0
            currentQuestionIndex = 0;
            
            // Clear summary content
            document.getElementById('results').innerHTML = ""
            document.getElementById('summary').innerHTML = '';
            document.getElementById('summaryContainer').style.display = 'none'

            // Show the questionnaire
            document.getElementById('questionnaire').style.display = 'block';

            // Start showing questions from the beginning
            showQuestionnaire();
        }

    </script>
</body>

</html>

<%! 
public String getQuestionnaireJson(String file) { 
    if (file == null || file.isEmpty()) {
        return "{}";
    }
    JSONParser parser = new JSONParser();
    try {
        // Load the file from the classpath
        InputStream inputStream = getClass().getClassLoader().getResourceAsStream("/questions/" + file);
        if (inputStream == null) {
            return "{}";
        }
        
        // Convert InputStream to InputStreamReader
        InputStreamReader reader = new InputStreamReader(inputStream, StandardCharsets.UTF_8);
        
        // Parse the JSON file
        JSONObject questionnaireJson = (JSONObject) parser.parse(reader);
        
        // Close the input stream
        inputStream.close();
        
        return questionnaireJson.toJSONString();
    } catch (Exception e) {
        e.printStackTrace();
        return "{}";
    }
} 
%>