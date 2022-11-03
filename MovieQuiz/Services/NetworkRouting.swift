//
//  NetworkRouting.swift
//  MovieQuiz
//
//  Created by macOS on 28.10.2022.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
