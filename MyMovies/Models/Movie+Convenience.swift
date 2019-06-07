//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Alex on 6/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = true, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    // creates Movie from MovieRepresentation
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) { // optional bc it may not pull data from Firebase
        self.init(title: movieRepresentation.title,
                  identifier: movieRepresentation.identifier ?? UUID(),
                  hasWatched: movieRepresentation.hasWatched ?? true,
                  context: context)
    }
    
    // converts Movie to MovieRepresentation before going to JSON
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let identifier = identifier
            else {return nil}
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
