//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Олег Серебрянский on 06.11.2023.
//

import Foundation


final class StatisticServiceImp {
    
        private enum Keys: String {
            case correct, total, bestGame, gamesCount
            }
    
    private let userDefaults: UserDefaults
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let dateProvider: () -> Date
    
    init(
        userDefaults: UserDefaults = .standard,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        dateProvider: @escaping () -> Date = { Date() }
    ) {
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
        self.dateProvider = dateProvider
    }
}


extension StatisticServiceImp: StatisticService {
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        Double(correct) / Double(total) * 100
    }
    
    var bestGame: GameRecord? {
        get {
            guard
                let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let bestGame = try? decoder.decode(GameRecord.self, from: data) else {
                return nil
                
            }
            return bestGame
        }
        set {
            let data = try? encoder.encode(newValue)
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct: Int, total: Int) {
        self.correct += correct
        self.total += total
        self.gamesCount += 1
        
        let date = dateProvider()
        let currentBestGame = GameRecord(correct: correct, total: total, date: date)
        if let previousBestGame = bestGame {
            if currentBestGame > previousBestGame {
                bestGame = currentBestGame
            }
        } else {
            bestGame = currentBestGame
        }
    }
}
    
//    private let userDefaults: UserDefaults
//    private let decoder: JSONDecoder
//    private let encoder: JSONEncoder
//    
//    init(userDefaults: UserDefaults = .standard,
//         decoder: JSONDecoder = JSONDecoder(),
//         encoder: JSONEncoder = JSONEncoder()) 
//    {
//        self.userDefaults = userDefaults
//        self.decoder = decoder
//        self.encoder = encoder
//    }
//    var totalAccuracy: Int {
//        get {
//            userDefaults.integer(forKey: Keys.total.rawValue)
//        }
//        set {
//            userDefaults.set(newValue, forKey: Keys.total.rawValue)
//        }
//    }
//    var gamesCount: Int {
//        get {
//            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
//        }
//        set {
//            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
//        }
//    }
//    var correct: Int {
//        get {
//            userDefaults.integer(forKey: Keys.correct.rawValue)
//        }
//        set {
//            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
//        }
//    }
//     
//
//    
//    
//    var bestGame: GameRecord {
//        get {
//            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
//            let record = try? decoder.decode(GameRecord.self, from: data) else {
//                return .init(correct: 0, total: 0, date: Date())
//            }
//
//            return record
//        }
//
//        set {
//            guard let data = try? encoder.encode(newValue) else {
//                print("Невозможно сохранить результат")
//                return
//            }
//
//            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
//        }
//    }
//    
//    func store(correct count: Int, total amount: Int) {
//        self.correct += 1
//        self.totalAccuracy += totalAccuracy
//        self.gamesCount += 1
//        
//        
//    }
//    
//}
