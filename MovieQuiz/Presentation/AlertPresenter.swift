//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Олег Серебрянский on 27.10.2023.
//

import Foundation
import UIKit


/// приватный метод для показа результатов раунда квиза
/// принимает вью модель QuizResultsViewModel и ничего не возвращает
class AlertPresenter: AlertPresenterProtocol {
    
   private weak var viewController: UIViewController?
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func show(alertModel: AlertModel) {
        
    }
}
