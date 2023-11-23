//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Олег Серебрянский on 22.11.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func buttonsActive()
    func buttonsDontActive()
    
    func hideUI ()
    func showUI ()
}
