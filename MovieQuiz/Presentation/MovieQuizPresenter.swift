//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by macOS on 28.10.2022.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    
    private let questionsAmount = 10
    private var correctAnswers = 0
    
    private let moviesLoader: MoviesLoading = MoviesLoader()
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService = StatisticServiceImplementation()
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        loadMovies()
    }
    
    func loadMovies() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func noButtonClicked() {
        didAnswerAction(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswerAction(isYes: true)
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let alertText = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.toString())
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: alertText,
                                                 buttonText: "Сыграть еще раз")
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func asyncWaitSecond(onCompletion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onCompletion()
        }
    }
    
    private func didAnswerAction(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
