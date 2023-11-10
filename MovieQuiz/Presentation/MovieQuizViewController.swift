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
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    /// приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
      imageView.image = step.image
      textLabel.text = step.question
      counterLabel.text = step.questionNumber
    }
    
    @IBOutlet weak var yesButtonAnswer: UIButton!
    @IBOutlet weak var noButtonAnswer: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Bundle.main.bundlePath)
        statisticService = StatisticServiceImp()
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory.delegate = self
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        
        questionFactory.requestNextQuestion()
        imageView.layer.cornerRadius = 20 /// радиус скругления углов рамки
        
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
    
    /// приватный метод, который меняет цвет рамки
    /// принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
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
        
    }
    

    /// приватный метод, который содержит логику перехода в один из сценариев
    /// метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0

        if currentQuestionIndex == questionsAmount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
            noButtonAnswer.isEnabled = true
            yesButtonAnswer.isEnabled = true
        }
    
    }
    
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        guard let bestGame = statisticService?.bestGame else {
            assertionFailure("Error message")
            return
        }
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: makeResultMessage(),
                                    buttonText: "Сыграть ещё раз",
                                    buttonAction: { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
            
            noButtonAnswer.isEnabled = true
            yesButtonAnswer.isEnabled = true
        }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func makeResultMessage () -> String {
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

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
