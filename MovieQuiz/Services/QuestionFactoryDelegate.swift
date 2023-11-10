//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Олег Серебрянский on 27.10.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
