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
    
    private var presenter: MovieQuizPresenter!

       // MARK: - Lifecycle

       override func viewDidLoad() {
           super.viewDidLoad()

           presenter = MovieQuizPresenter(viewController: self)

           imageView.layer.cornerRadius = 20
           
       }

       // MARK: - Actions

       @IBAction private func yesButtonClicked(_ sender: UIButton) {
           presenter.yesButtonClicked()
       }

       @IBAction private func noButtonClicked(_ sender: UIButton) {
           presenter.noButtonClicked()
       }

       // MARK: - Private functions

    func hideUI () {
        imageView.isHidden = true
        yesButtonAnswer.isHidden = true
        noButtonAnswer.isHidden = true
        textLabel.isHidden = true
        counterLabel.isHidden = true
        questionLabel.isHidden = true
    }
    func showUI () {
        imageView.isHidden = false
        yesButtonAnswer.isHidden = false
        noButtonAnswer.isHidden = false
        textLabel.isHidden = false
        counterLabel.isHidden = false
        questionLabel.isHidden = false
    }
    
       func show(quiz step: QuizStepViewModel) {
           imageView.layer.borderColor = UIColor.clear.cgColor
           imageView.image = step.image
           textLabel.text = step.question
           counterLabel.text = step.questionNumber
       }

       func show(quiz result: QuizResultsViewModel) {
           let message = presenter.makeResultsMessage()

           let alert = UIAlertController(
               title: result.title,
               message: message,
               preferredStyle: .alert)

               let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                   guard let self = self else { return }

                   self.presenter.restartGame()
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

    func buttonsActive() {
        yesButtonAnswer.isEnabled = true
        noButtonAnswer.isEnabled = true
    }
    func buttonsDontActive() {
        yesButtonAnswer.isEnabled = false
        noButtonAnswer.isEnabled = false
    }
    
       func showNetworkError(message: String) {
           hideLoadingIndicator()

           let alert = UIAlertController(
               title: "Ошибка",
               message: "Что-то пошло не так",
               preferredStyle: .alert)

               let action = UIAlertAction(title: "Попробовать ещё раз",
               style: .default) { [weak self] _ in
                   guard let self = self else { return }

                   self.presenter.restartGame()
               }

           alert.addAction(action)
       }
   }
