import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    /// метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    /// приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    /// hide image, buttons and text before load data
    private func hideUI () {
        imageView.backgroundColor = UIColor.ypBlack
        yesButtonAnswer.backgroundColor = UIColor.ypBlack
        noButtonAnswer.backgroundColor = UIColor.ypBlack
        textLabel.textColor = UIColor.ypBlack
    }
    /// show image, buttons and text after load data
    private func showUI () {
        imageView.backgroundColor = UIColor.ypGray
        yesButtonAnswer.backgroundColor = UIColor.ypGray
        noButtonAnswer.backgroundColor = UIColor.ypGray
        textLabel.textColor = UIColor.ypWhite
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yesButtonAnswer: UIButton!
    @IBOutlet weak var noButtonAnswer: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideUI()
        print(Bundle.main.bundlePath)
        activityIndicator.hidesWhenStopped = true
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImp()
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory?.delegate = self
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        
        
        showLoadingIndicator()
        questionFactory?.loadData()
        imageView.layer.cornerRadius = 20
        
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        hideLoadingIndicator()
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        }
        noButtonAnswer.isEnabled = false
        yesButtonAnswer.isEnabled = false
        showLoadingIndicator()
        
    }
    
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        showLoadingIndicator()
        if currentQuestionIndex == questionsAmount - 1 {
            hideLoadingIndicator()
            showFinalResults()
        } else {
            hideLoadingIndicator()
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
            noButtonAnswer.isEnabled = true
            yesButtonAnswer.isEnabled = true
        }
        
    }
    
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        guard let message = makeResultMessage() else {
            assertionFailure("Error message")
            return
        }
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: message,
                                    buttonText: "Сыграть ещё раз",
                                    buttonAction: { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            
            makeButtonsEnabled(true)
        }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showLoadingIndicator() {
        
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertNetworkError = AlertModel(title: "Ошибка",
                                           message: "Что-то пошло не так",
                                           buttonText: "Попробовать ещё раз",
                                           buttonAction: { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.loadData()
            
        }
        )
        alertPresenter?.show(alertModel: alertNetworkError)
    }
    
    func didLoadDataFromServer() {
        showUI()
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func makeButtonsEnabled(_ isEnabled: Bool) {
        noButtonAnswer.isEnabled = isEnabled
        yesButtonAnswer.isEnabled = isEnabled
    }
    
    private func makeResultMessage () -> String? {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыграных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + "  (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        
        let companents: [String] = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine]
        let resultMessage = companents.joined(separator: "\n")
        
        return resultMessage
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}
