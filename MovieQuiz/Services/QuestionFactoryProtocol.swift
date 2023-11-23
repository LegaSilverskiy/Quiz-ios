//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Олег Серебрянский on 25.10.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func loadData()
    func requestNextQuestion()
    var delegate: QuestionFactoryDelegate? { get set }
}
