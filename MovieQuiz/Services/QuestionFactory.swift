//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by macOS on 30.09.2022.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    private enum MoviesNotFound: Error {
        case codeError
    }
    
    func loadData() {
        moviesLoader.loadMovies { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let movies):
                    if movies.items.isEmpty {
                        self.delegate?.didFailToLoadData(with: MoviesNotFound.codeError)
                    } else {
                        self.movies = movies.items.filter({ movie in
                            !movie.rating.isEmpty
                        })
                        self.delegate?.didLoadDataFromServer()
                    }

                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageUrl)
            } catch {
                self.delegate?.didFailToLoadData(with: error)
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let ratingQuestion = Int.random(in: 6...8)
            let text = "Рейтинг этого фильма больше чем \(ratingQuestion)?"
            let correctAnswer = rating > Float(ratingQuestion)
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQestion(question: question)
            }
        }
    }
    
}
