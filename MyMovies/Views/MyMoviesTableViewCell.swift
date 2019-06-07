//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Alex on 6/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var networkMovieController = NetworkMovieController()

    // MARK: - Outlets
    
    @IBOutlet weak var movieLbl: UILabel!
    @IBOutlet weak var watchedBtn: UIButton!
    
    // MARK: - Actions
    
    @IBAction func watchBtnPressed(_ sender: UIButton) {
        guard let movie = movie else {return}
        
        let moc = CoreDataStack.shared.mainContext
        
        moc.performAndWait {
            networkMovieController.update(movie: movie, hasWatched: !movie.hasWatched)
//            do {
//                try moc.save()
//            } catch let saveError {
//                print("Error saving movie: \(saveError)")
//            }
        }
    }
    
    // MARK: - Functions
    
    func updateViews() {
        guard let movieTitle = movie?.title,
            let hasWatched = movie?.hasWatched else {return}
        
        movieLbl.text = movieTitle
        
        if hasWatched {
            watchedBtn.setTitle("Watched", for: .normal)
        } else {
            watchedBtn.setTitle("Unwatched", for: .normal)
        }
    }
}
