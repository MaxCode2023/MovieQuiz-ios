//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by macOS on 31.10.2022.
//

import Foundation

protocol MovieQuizViewControllerProtocol : AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func showAnswerResult(isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
