//
//  VenueDetailViewController.swift
//  FourSquareExample
//
//  Created by Jesus Jaime Cano Terrazas on 28/08/21.
//

import UIKit
import MapKit

class VenueDetailViewController: UIViewController {
    
    var venueAnnotation: MKAnnotation!
    var userAnnotation: MKAnnotation!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.mapView.addAnnotations([venueAnnotation, userAnnotation]) // Add the annotations on the map
        self.mapView.showAnnotations([venueAnnotation, userAnnotation], animated: true) // Center the map focus on those annotations
        self.titleLabel.text = self.venueAnnotation.title ?? ""
        self.loadRoute()
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
    
    private func loadRoute() {
        
        let placeMark = MKPlacemark(coordinate: self.venueAnnotation.coordinate)
        let destinationMapItem = MKMapItem(placemark: placeMark)
        
        let request = MKDirections.Request()
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destinationMapItem
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            if let errorResponse = error {
                print("There is an error calculating the route: \(errorResponse.localizedDescription)")
            } else {
                if let routes = response?.routes {
                    for route in routes {
                        var stepStr = ""
                        for step in route.steps {
                            print("Step: \(step.instructions)")
                            
                            stepStr += "- \(step.instructions) \n"
                        }
                        
                        self.stepsLabel.text = stepStr
                        self.mapView.addOverlay(route.polyline, level: .aboveLabels)
                    }
                }
            }
        }
    }
    
}

// MARK: -MKMapViewDelegate

extension VenueDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .blue
        render.lineWidth = 4
        render.alpha = 0.75
        
        return render
    }
}
