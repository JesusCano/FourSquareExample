//
//  SearchPlacesViewController.swift
//  FourSquareExample
//
//  Created by Jesus Jaime Cano Terrazas on 14/08/21.
//

import UIKit
import MapKit
import Alamofire
import Bagel
import Lottie

class SearchPlacesViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var sliderView: UISlider!
    
    
    private var locationManager = CLLocationManager()
    private var userLatitude = 19.595461
    private var userLongitude = -99.206678
    private var query = "coffee"
    private var venues: [VenueModel] = []
    private var animationView: AnimationView?
    private var radius = 1500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
        self.mapView.delegate = self
        
        mapView.showsUserLocation = true
        
//        locationManager.startUpdatingLocation()
        
        self.sliderView.value = 1500
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPermissions()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PlaceDetailViewController" {
            let placeDetailViewController = segue.destination as! PlaceDetailViewController
            
            if let venueToSend = sender as? VenueModel {
                placeDetailViewController.placeDetail = venueToSend
            }
        }
        
        if segue.identifier == "VenueDetailViewController" {
            let venueDetailViewController = segue.destination as! VenueDetailViewController
            
            if let venueToSend = sender as? MKAnnotation {
                venueDetailViewController.venueAnnotation = venueToSend
            }
            
            let userAnnotation = MKPointAnnotation()
            userAnnotation.title = "Me :D"
            let userCoordinate = CLLocationCoordinate2D(latitude: self.userLatitude, longitude: self.userLongitude)
            userAnnotation.coordinate = userCoordinate
            
            venueDetailViewController.userAnnotation = userAnnotation
        }
    }
    
    // MARK: - User Interactions
    
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        self.radius = Int(sender.value)
        self.distanceLabel.text = "Searching Distance: \(radius)"
    }
    
    // MARK: - Private Methods
    
    private func showLoader() {
        self.animationView = .init(name: "lottie-location")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 0.5
        view.addSubview(animationView!)
        animationView!.play()
        
    }
    
    private func checkPermissions() {
        if CLLocationManager.locationServicesEnabled() {
            let status = locationManager.authorizationStatus
            
            if status == .authorizedWhenInUse {
                print("Podemos usar el GPS")
            } else if status == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else if status == .restricted || status == .denied {
                print("No tenemos permiso de usar el GPS")
                self.locationServicesAlert()
            }
        } else {
            // TODO: Notice to the User that the locations isnt enable
            self.locationServicesAlert()
        }
    }
    
    private func locationServicesAlert() {
        let alert = UIAlertController(title: "Ups", message: "Enable your location Bitch, I cant work while this is disabled 😒", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Go to config", style: .default) { action in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(alertAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // query: String = Words that we'll search in foursquare API
    private func searchPlaces(query: String) {
        
        let params = [
            "client_id": Constants.FourSquareAPI.clientID,
            "client_secret": Constants.FourSquareAPI.clientSecret,
            "ll": "\(self.userLatitude),\(self.userLongitude)",
            "v": "20210821",
            "query": query,
            "radius": String(self.radius)
        ]
        
        AF.request(Constants.FourSquareAPI.baseURL, method: .get ,parameters: params).validate().responseData { response in
            switch response.result {
            
            case .success(let value):
                print("FourSquare Response: \(value)")
                do {
                    let fourSquareResponse = try JSONDecoder().decode(FourSquareResponseModel.self, from: value)
                    print("Places Localized: \(fourSquareResponse.response.venues.count)")
                    self.venues = fourSquareResponse.response.venues
                    self.showVenuesOnMap(venues: fourSquareResponse.response.venues)
                    
                } catch let error {
                    print("Parsing Error: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                print("FourSquare Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func showVenuesOnMap(venues: [VenueModel]) {
        
        // Annotation Example
//        let annotation = MKPointAnnotation()
//        let coordinnate = CLLocationCoordinate2D(latitude: self.userLatitude, longitude: self.userLongitude)
//        annotation.coordinate = coordinnate
//        annotation.title = "My Current Location"
//        annotation.subtitle = "HI"
//        mapView.addAnnotation(annotation)
        self.clearVenues()
        self.clearRoutes()
        
        for venue in venues {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: venue.location.latitude, longitude: venue.location.longitude)
            annotation.coordinate = coordinate
            annotation.title = venue.name
            mapView.addAnnotation(annotation)
        }
        
        let userCenter = CLLocationCoordinate2D(latitude: self.userLatitude, longitude: self.userLongitude)
        let region = MKCoordinateRegion(center: userCenter, latitudinalMeters: Double(self.radius + 400), longitudinalMeters: Double(self.radius + 200))
        mapView.setRegion(region, animated: true)
    }
    
    private func clearVenues() {
        let currentAnnotations = mapView.annotations
        mapView.removeAnnotations(currentAnnotations)
    }
    
    private func loadRouteFor(annotation: MKAnnotation) {
        self.clearRoutes()
        
        
        let placeMark = MKPlacemark(coordinate: annotation.coordinate)
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
                        
                        for step in route.steps {
                            print("Step: \(step.instructions)")
                        }
                        self.mapView.addOverlay(route.polyline, level: .aboveLabels)
                    }
                }
            }
        }
    }
    
    private func clearRoutes () {
        let currentOverlays = mapView.overlays
        mapView.removeOverlays(currentOverlays)
    }

}

// MARK: - CLLocationManagerDelegate

extension SearchPlacesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("User location got it")
        
        if let location = locations.first {
            self.userLatitude = location.coordinate.latitude
            self.userLongitude = location.coordinate.longitude
            print("User's location is: latitude: \(self.userLatitude) longitude: \(self.userLongitude)")
            self.searchPlaces(query: self.query)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager error: \(error.localizedDescription)")
    }
}

// MARK: - UITextFieldDelegate

extension SearchPlacesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Enter Pressed ...")
        if let searchQuery = textField.text {
            self.searchTextField.resignFirstResponder()
            print("Search: \(searchQuery)")
            self.query = searchQuery
            locationManager.requestLocation()
        }
        
        return true
    }
}

// MARK: - MKMapViewDelegate

extension SearchPlacesViewController: MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        if annotation is MKUserLocation {
//            return nil
//        }
//
//        let annotationIdentifier = "VenueAnnotationIdentifier"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
//
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            annotationView?.canShowCallout = true
//        } else {
//            annotationView?.annotation = annotation
//        }
//
////        annotationView?.image = UIImage(named: "mark")
//
//        return annotationView
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Selected Place")
        
        if let annotation = view.annotation {
//            self.loadRouteFor(annotation: annotation)
            performSegue(withIdentifier: "VenueDetailViewController", sender: annotation)
        }
        
//        let placeSelected = self.venues[0]
//        performSegue(withIdentifier: "PlaceDetailViewController", sender: self.venues[0])
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .black
        renderer.lineWidth = 4
        renderer.alpha = 0.75
        return renderer
    }
}
