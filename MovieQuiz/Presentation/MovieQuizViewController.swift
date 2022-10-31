import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.restartGame()
            }
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Что-то пошло не так(",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.loadMovies()
        }
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter?.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        presenter?.asyncWaitSecond { [weak self] in
            guard let self = self else { return }
            
            self.presenter?.proceedToNextQuestionOrResults()
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
}
