//
//  NetworkMovieController.swift
//  MyMovies
//
//  Created by Alex on 6/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class NetworkMovieController {
    
    init() {
        fetchMoviesFromServer()
    }
    
    let baseURL = URL(string: "https://coredata-283af.firebaseio.com/")!

    func saveToPersistentStore(){
        let moc = CoreDataStack.shared.mainContext
        
        do {
            try moc.save() // save to persistent store
        } catch let error {
            print("Error saving moc: \(error)")
        }
    }
    
    // MARK: - CRUD
    
    func create(title: String) {
        let movie = Movie(title: title)
        put(movie: movie)
        saveToPersistentStore()
    }
    
    func update(movie: Movie, hasWatched: Bool){
        movie.hasWatched = hasWatched
        
        put(movie: movie)
        saveToPersistentStore()
    }
    
    func delete(movie: Movie){
        CoreDataStack.shared.mainContext.delete(movie)
        // 1. Delete from CoreData
        deleteMovieFromServer(movie: movie)
        // 2. Save deletion
        saveToPersistentStore()
    }
    
    // MARK: - Firebase & Core Data
    
    typealias CompletionHandler = (Error?) -> Void
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in}) {
        let uuid = movie.identifier?.uuidString ?? UUID().uuidString
        
        let requestUrl = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie.movieRepresentation else { throw NSError()}
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding task: \(error)")
            return completion(error)
        }
        
        URLSession.shared.dataTask(with: request) {(_, _, error) in
            if let error = error {
                NSLog("Error PUTting task to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            } .resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in}) {
        let uuid = movie.identifier?.uuidString ?? UUID().uuidString

        let url = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error sending deletion request to server: \(error.localizedDescription)")
                return completion(nil)
            }
            completion(nil)
            } .resume()
    }
    
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        // 1. create fetch request from Entry
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Movie?
        
        do {
            result = try context.fetch(fetchRequest).first
        } catch let fetchError {
            print("Error fetching single entry: \(fetchError.localizedDescription)")
        }
        return result
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in}){
        let requestURL = baseURL.appendingPathExtension("json")
        let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
        
        URLSession.shared.dataTask(with: requestURL)  { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                return completion(NSError())
            }
            
            do {
                let movieRepresentationDict = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let movieRepresentation = Array(movieRepresentationDict.values)
                
                self.updateMovies(with: movieRepresentation, in: backgroundContext)
                
                // save changes to disk
                try CoreDataStack.shared.save(context: backgroundContext)
            } catch {
                NSLog("Error decoding tasks: \(error)")
                return completion(error)
            }
            completion(nil)
            }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], in context: NSManagedObjectContext) {
        context.performAndWait {
            for movieRep in representations {
                guard let identifier = movieRep.identifier?.uuidString else {continue}
                
                let movie = self.fetchSingleMovieFromPersistentStore(identifier: identifier, context: context)
                if let movie = movie { //, movie != movieRep
                    // if we have a Movie then update it
                    movie.title = movieRep.title
                    movie.identifier = movieRep.identifier
                    movie.hasWatched = movieRep.hasWatched ?? true
                } else if movie == nil {
                    // if we have no Movie then create one
                    _ = Movie(movieRepresentation: movieRep, context: context)
                }
            }
        }
    }
    
    
}
