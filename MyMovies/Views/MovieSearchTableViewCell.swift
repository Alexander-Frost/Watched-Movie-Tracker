//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Alex on 6/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var networkMovieController = NetworkMovieController()
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addMovieBtn: UIButton!
    
    // MARK: - Actions
    
    @IBAction func addMovieBtnPressed(_ sender: UIButton) {
        guard let movieTitle = titleLbl.text else {return}
        
        let moc = CoreDataStack.shared.mainContext
        
        moc.performAndWait {
            networkMovieController.create(title: movieTitle)
//            do {
//                try moc.save()
//            } catch let saveError {
//                print("Error saving movie: \(saveError)")
//            }
        }
        
        sender.setTitle("Added", for: .normal)
    }

}
