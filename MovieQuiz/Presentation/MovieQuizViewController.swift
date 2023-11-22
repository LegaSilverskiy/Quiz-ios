import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    /// hide image, buttons and text before load data
    private func hideUI () {
        imageView.isHidden = true
        yesButtonAnswer.isHidden = true
        noButtonAnswer.isHidden = true
        textLabel.isHidden = true
        counterLabel.isHidden = true
    }
    /// show image, buttons and text after load data
    private func showUI () {
        imageView.isHidden = false
        yesButtonAnswer.isHidden = false
        noButtonAnswer.isHidden = false
        textLabel.isHidden = false
        counterLabel.isHidden = false
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yesButtonAnswer: UIButton!
    @IBOutlet weak var noButtonAnswer: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactory?
    var alertPresenter: AlertPresenter?
    var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideUI()
        print(Bundle.main.bundlePath)
        activityIndicator.hidesWhenStopped = true
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImp()
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory?.delegate = self
        presenter.viewController = self
        self.presenter.resetQuestionIndex()
        presenter.correctAnswers = 0
        
        
        showLoadingIndicator()
        questionFactory?.loadData()
        imageView.layer.cornerRadius = 20
        
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        makeButtonsEnabled(true)
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        hideLoadingIndicator()
        if isCorrect {
            presenter.correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.correctAnswers = presenter.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
            imageView.layer.borderColor = UIColor.clear.cgColor
        }
        noButtonAnswer.isEnabled = false
        yesButtonAnswer.isEnabled = false
        showLoadingIndicator()
        
    }
    
    
    private func showNextQuestionOrResults() {
        showLoadingIndicator()
        if presenter.isLastQuesiton() {
            hideLoadingIndicator()
            presenter.showFinalResults()
        } else {
            hideLoadingIndicator()
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
            noButtonAnswer.isEnabled = true
            yesButtonAnswer.isEnabled = true
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertNetworkError = AlertModel(title: "Ошибка",
                                           message: "Что-то пошло не так",
                                           buttonText: "Попробовать ещё раз",
                                           buttonAction: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.presenter.correctAnswers = 0
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
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
}
