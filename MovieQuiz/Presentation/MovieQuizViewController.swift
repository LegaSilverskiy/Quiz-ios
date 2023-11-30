import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var yesButtonAnswer: UIButton!
    @IBOutlet weak var noButtonAnswer: UIButton!
    
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
        
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    // MARK: - Private functions
    func changeStateUI (isHidden: Bool) {
        imageView.isHidden = isHidden
        yesButtonAnswer.isHidden = isHidden
        noButtonAnswer.isHidden = isHidden
        textLabel.isHidden = isHidden
        counterLabel.isHidden = isHidden
        questionLabel.isHidden = isHidden
    }
    
    
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
       let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in

           alertModel.buttonAction()
       }
       
       alert.addAction(action)
       
        present(alert, animated: true)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter?.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter?.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    func changeStateButton(isEnabled: Bool) {
        yesButtonAnswer.isEnabled = isEnabled
        noButtonAnswer.isEnabled = isEnabled
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertNetworkError = AlertModel(
            title: "Ошибка",
            message: "Что-то пошло не так",
            buttonText: "Попробовать ещё раз",
            buttonAction: { [weak self] in
                guard let self = self else { return }
                self.presenter?.restartGame()
            }
        )
        show(alertModel: alertNetworkError)
    }
}
