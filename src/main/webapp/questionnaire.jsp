<%@ page import="java.io.FileReader, java.io.File" %>
<%@ page import="org.json.simple.JSONObject, org.json.simple.parser.JSONParser" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Multiple Choice Questionnaire</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .progress {
            height: 20px;
        }

        .progress-bar {
            width: 100%;
        }
    </style>
</head>

<body>
    <div class="container mt-5">
        <h1 id="questionnaire-title"></h1>
        <div id="questionnaire" class="card">
            <div class="card-body">
                <h5 id="question" class="card-title"></h5>
                <form id="answers" class="mb-3"></form>
                <div class="progress">
                    <div id="progress-bar" class="progress-bar" role="progressbar"></div>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                    <button id="next-button" class="btn btn-primary mt-3" onclick="nextQuestion()">Next</button>
                    <div class="font-monospace">
                        <span id="current">current</span>/<span id="total">total</span>
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

        function loadQuestionnaire() {
            const questionnaireJson = '<%= getQuestionnaireJson(request.getParameter("file")) %>';
            return JSON.parse(questionnaireJson);
        }

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
                answerElement.innerHTML = `
                    <input class="form-check-input" type="checkbox" value="\${index}" id="answer\${index}">
                    <label class="form-check-label" for="answer\${index}">\${answer}</label>
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

            studentAnswers.push({
                question: question.question,
                selectedAnswers: selectedAnswers
            });
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
            questionnaire = loadQuestionnaire();
            showQuestionnaireTitle(questionnaire.description);
            showQuestionnaire();
        });

        function showQuestionnaireTitle(description) {
            questionnaireTitle.innerText = description;
        }

        function displaySummary() {
            const summaryContainer = document.getElementById('summaryContainer');
            summaryContainer.style.display = 'block'
            const summary = document.getElementById('summary');
            summary.innerHTML = '<h2>Questionnaire Summary</h2>';

            questionnaire.questions.forEach((question, index) => {
                const questionSummary = document.createElement('div');
                questionSummary.classList.add('question-summary');
                questionSummary.innerHTML = `
                    <h3>Question \${index + 1}</h3>
                    <p><strong>Question:</strong> \${question.question}</p>
                    <p><strong>Your Answer(s):</strong> \${getStudentAnswersSummary(studentAnswers[index].selectedAnswers, question.answers)}</p>
                    <p><strong>Correct Answer(s):</strong> \${getCorrectAnswersSummary(question, question.answers)}</p>
                `;
                summary.appendChild(questionSummary);
            });

            // Hide the questionnaire
            document.getElementById('questionnaire').style.display = 'none';
        }

        function getStudentAnswersSummary(selectedIndexes, answers) {
            const selectedAnswers = selectedIndexes.map(index => answers[index]);
            return selectedAnswers.join(', ');
        }

        function getCorrectAnswersSummary(question, answers) {
            const correctIndexes = question.correct;
            const correctAnswers = correctIndexes.map(index => answers[index]);
            return correctAnswers.join(', ');
        }

        function replay() {
            // Clear studentAnswers array
            studentAnswers = [];
            
            // Reset currentQuestionIndex to 0
            currentQuestionIndex = 0;

            // Clear summary content
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
        File jsonFile = new File(getServletContext().getRealPath("/questions/" + file));
        if (!jsonFile.exists()) {
            return "{}";
        }
        FileReader reader = new FileReader(jsonFile);
        JSONObject questionnaireJson = (JSONObject) parser.parse(reader);
        return questionnaireJson.toJSONString();
    } catch (Exception e) {
        e.printStackTrace();
        return "{}";
    }
} 
%>
