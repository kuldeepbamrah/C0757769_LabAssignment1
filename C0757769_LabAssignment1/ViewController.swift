//
//  ViewController.swift
//  C0757769_LabAssignment1
//
//  Created by MacStudent on 2020-01-14.
//  Copyright © 2020 MacStudent. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate{
      var locationManager = CLLocationManager()

    @IBOutlet weak var zoomStepper: UIStepper!
    var userLocation = [CLLocation]()
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomStepper.value = 0
        zoomStepper.minimumValue = -5
        zoomStepper.maximumValue = 5
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
         
        locationManager.startUpdatingLocation()
        
        let gestureDoubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(gestureRecognizer:)))
        gestureDoubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(gestureDoubleTap)
    }


    
    @objc func doubleTap(gestureRecognizer : UILongPressGestureRecognizer)
    {
        //remove overlays
        let count = mapView.overlays.count
        if count != 0
        {
            mapView.removeOverlay(mapView.overlays[0])
        }
        //remove annotations
        let i = mapView.annotations.count
        if i != 0
        {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Latitude:\(coordinate.latitude)"
        annotation.subtitle = "Longitude:\(coordinate.longitude)"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            //grab user location
           
            
            let userLocation : CLLocation = locations[0]
            let lat = userLocation.coordinate.latitude
           let long = userLocation.coordinate.longitude
            //define delta (difference) of lat and long
            let latDelta : CLLocationDegrees = 0.05
           let longDelta : CLLocationDegrees = 0.05

    //        //define span
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
    //
    //
    //        //define location
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
    //
    //        //define region
            let region = MKCoordinateRegion(center: location, span: span)
    //
    //        // set the region on the map
           mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
        
            let annotation = MKPointAnnotation()
            annotation.title = "You are here"
           annotation.coordinate = userLocation.coordinate
            mapView.addAnnotation(annotation)
            
           
            
            
            //find the user address from his location
            //CLGeocoder().reverseGeocodeLocation()
        }
    
    @IBAction func findMyWayBtn(_ sender: Any)
    {
        let userLocationCoordinates = mapView.userLocation
        let userLocation  = CLLocationCoordinate2D(latitude: userLocationCoordinates.coordinate.latitude, longitude: userLocationCoordinates.coordinate.longitude)
        let annotation = mapView.annotations
        let pointToTravel = CLLocationCoordinate2D(latitude: annotation[0].coordinate.latitude, longitude: annotation[0].coordinate.longitude)
        print("wdasd \(userLocation)")
        print(pointToTravel)
        route(point1: userLocation, point2: pointToTravel)
        //getDirections(loc1: userLocation, loc2: pointToTravel)
        //getDirections(loc1: userLocation, loc2:)
        
        
    }
    
    func getDirections(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D) {
       let source = MKMapItem(placemark: MKPlacemark(coordinate: loc1))
       source.name = "Your Location"
       let destination = MKMapItem(placemark: MKPlacemark(coordinate: loc2))
       destination.name = "Destination"
       MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    
    func route(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D)
    {
        print(point1)
        print(point2)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: point1, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: point2, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .walking

        let directions = MKDirections(request: request)

       directions.calculate { [unowned self] response, error in
          guard let unwrappedResponse = response else { return }
           for route in unwrappedResponse.routes {
                
            self.mapView.addOverlay(route.polyline)
                self.mapView.delegate=self
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    
    
    @IBAction func zoomStepperPressed(_ sender: UIStepper)
    {
        if sender.value < 0
        {
            var region: MKCoordinateRegion = mapView.region
            region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
            region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
            mapView.setRegion(region, animated: true)
            zoomStepper.value = 0
        }
        else
        {
            var region: MKCoordinateRegion = mapView.region
            region.span.latitudeDelta /= 2.0
            region.span.longitudeDelta /= 2.0
            mapView.setRegion(region, animated: true)
            zoomStepper.value = 0
        }
    }
    
   
}
    


extension ViewController: MKMapViewDelegate
{

func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
    renderer.strokeColor = UIColor.green
    return renderer
}
    
    
    
}

