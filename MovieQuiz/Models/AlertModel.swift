//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Олег Серебрянский on 27.10.2023.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    let buttonAction: () -> Void
}
