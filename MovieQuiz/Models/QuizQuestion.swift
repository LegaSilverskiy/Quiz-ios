//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Олег Серебрянский on 25.10.2023.
//

import Foundation

private struct QuizQuestion {
  /// строка с названием фильма,
  let image: String
  /// строка с вопросом о рейтинге фильма
  let text: String
  /// булевое значение (true, false), правильный ответ на вопрос
  let correctAnswer: Bool
}
