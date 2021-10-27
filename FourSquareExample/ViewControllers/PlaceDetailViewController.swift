//
//  PlaceDetailViewController.swift
//  FourSquareExample
//
//  Created by Jesus Jaime Cano Terrazas on 25/08/21.
//

import UIKit
import Lottie

class PlaceDetailViewController: UIViewController {
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var nameCategoryLabel: UILabel!
    @IBOutlet weak var pluralNameCategoryLabel: UILabel!
    @IBOutlet weak var shortNameCategoryLabel: UILabel!
    
    var placeDetail: VenueModel!
    private var animationView: AnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showLoader()
        self.configureView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private Methods
     
    func configureView() {
        self.nameLabel.text = self.placeDetail.name
        self.latitudeLabel.text = String(self.placeDetail.location.latitude)
        self.longitudeLabel.text = String(self.placeDetail.location.longitude)
        self.nameCategoryLabel.text = self.placeDetail.categories[0].name
        self.pluralNameCategoryLabel.text = self.placeDetail.categories[0].pluralName
        self.shortNameCategoryLabel.text = self.placeDetail.categories[0].shortName
    }
    
    private func showLoader() {
        self.animationView = .init(name: "lottie-location")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 0.5
        view.addSubview(animationView!)
        animationView!.play()
        
    }

}
