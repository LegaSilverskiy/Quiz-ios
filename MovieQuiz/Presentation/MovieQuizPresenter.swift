//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Олег Серебрянский on 21.11.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactory?
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func isLastQuesiton() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuesiton() {
            viewController?.hideLoadingIndicator()
            showFinalResults()
        } else {
            viewController?.hideLoadingIndicator()
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showFinalResults() {
        viewController?.statisticService?.store(correct: correctAnswers, total: self.questionAmount)
        
        guard let message = makeResultMessage() else {
            assertionFailure("Error message")
            return
        }
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: message,
                                    buttonText: "Сыграть ещё раз",
                                    buttonAction: { [weak self] in
            guard let self = self else { return }
            restartGame()
            correctAnswers = 0
            questionFactory?.loadData()
            
            //            makeButtonsEnabled(true)
        }
        )
        viewController?.alertPresenter?.show(alertModel: alertModel)
    }
    
    private func makeResultMessage () -> String? {
        guard let statisticService = viewController?.statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыграных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(self.questionAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + "  (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        
        let companents: [String] = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine]
        let resultMessage = companents.joined(separator: "\n")
        
        return resultMessage
    }
    
}
