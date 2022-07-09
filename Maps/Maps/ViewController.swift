//
//  ViewController.swift
//  Maps
//
//  Created by Ganesh Galla on 22/12/21.
//
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import FloatingPanel

class ViewController: UIViewController,CLLocationManagerDelegate,GMSAutocompleteResultsViewControllerDelegate,FloatingPanelControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource{
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapTypeButton: UIButton!
    @IBOutlet weak var showRouteButton: UIButton!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    let API_Key = "AIzaSyBi49oRoTH4HTttcAtbwn88chu5MsB-bSA"
    let source = CLLocationCoordinate2D(latitude: 28.628151, longitude: 77.367783)
    let destination = CLLocationCoordinate2D(latitude: 16.9338442, longitude: 81.9562001)
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    let floatingPanelController = FloatingPanelController()
    var menuArray = ["Restaurants","Shopping","Petrol","Hotels","Coffee","Hospitals & Clinics","Clothing","... More"]
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        //Mapping
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        mapView.isMyLocationEnabled = true
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //Menu Collection Delegate
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.register(UINib(nibName: "MenuCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MenuCollectionViewCell")
        menuCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        let marker = GMSMarker()
        marker.position = source
        marker.appearAnimation = .pop
        marker.icon = UIImage(named: "Person")
        marker.map = self.mapView
        //calling SetupSearch Controller Function
        setupSearchController()
        //Bringing Subviews To Main View
        mapView.addSubview(mapTypeButton)
        mapView.addSubview(showRouteButton)
        mapView.addSubview(menuCollectionView)
        //FloatingPanel code
        floatingPanelController.delegate = self
        guard let ContentVc = storyboard?.instantiateViewController(identifier: "FloatingViewController") as? FloatingViewController else {
            return
        }
        floatingPanelController.set(contentViewController: ContentVc)
        floatingPanelController.addPanel(toParent: self)
    }
    // MARK:- Function To Setup The Search Controller
    func setupSearchController() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        let micImage = UIImage(systemName: "mic.fill")
        searchController?.searchBar.setImage(micImage, for: .bookmark, state: .normal)
        searchController?.searchBar.showsBookmarkButton = true
    }
    //MARK:- Location Manager Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        self.mapView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name ?? "placenameNil")")
        print("Place ID: \(place.placeID ?? "placeIdNil")")
        print("Place attributions: \(place.attributions)")
        print("place cordinate: \(place.coordinate.latitude) \(place.coordinate.longitude)")
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    //MARK:- Function to get Dircetion From Source To Destination
    func getRouteSteps(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
           let session = URLSession.shared
           let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(API_Key)")!
           let task = session.dataTask(with: url, completionHandler: {
               (data, response, error) in
               guard error == nil else {
                   print(error!.localizedDescription)
                   return
               }
               guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                   print("error in JSONSerialization")
                   return
               }
               guard let routes = jsonResult["routes"] as? [Any] else {
                   return
               }
               guard let route = routes[0] as? [String: Any] else { return
               }
               guard let legs = route["legs"] as? [Any] else {
                   return
               }
               guard let leg = legs[0] as? [String: Any] else {
                   return
               }
               guard let steps = leg["steps"] as? [Any] else {
                   return
               }
               for item in steps {
                   guard let step = item as? [String: Any] else {
                       return
                   }
                   guard let polyline = step["polyline"] as? [String: Any] else {
                       return
                   }
                   guard let polyLineString = polyline["points"] as? String else {
                       return
                   }
                   DispatchQueue.main.async {
                       self.drawPath(from: polyLineString)
                   }
               }
           })
           task.resume()
       }
       //MARK:- Function to Draw Polyline From Source To Destination
       func drawPath(from polyStr: String){
           let path = GMSPath(fromEncodedPath: polyStr)
           let polyline = GMSPolyline(path: path)
           polyline.strokeColor = .systemBlue
           polyline.strokeWidth = 5.0
           polyline.map = mapView
           let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: source, coordinate: destination))
           mapView.moveCamera(cameraUpdate)
           let currentZoom = mapView.camera.zoom
           mapView.animate(toZoom: currentZoom - 1)
           let marker = GMSMarker()
           marker.position = destination
           marker.icon = UIImage(named: "Home")
           marker.map = self.mapView
    }
    //MARK:- Menu CollectionView Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
        cell.menuButton.setTitle(menuArray[indexPath.row], for: .normal)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100.0, height: 30.0)
    }
    //MARK:- Button To Autocomplete
    @IBAction func showRouteButtonTapped(_ sender: Any) {
        getRouteSteps(from: source, to: destination)
    }
    //MARK:- Button to Appear ActionSheet For Different MapTypes
    @IBAction func mapType(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Normal", style: .default, handler: {_ in
            self.mapView?.mapType = .normal
        }))
        actionSheet.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: {_ in
            self.mapView?.mapType = .hybrid
        }))
        actionSheet.addAction(UIAlertAction(title: "Satellite", style: .default, handler: {_ in
            self.mapView?.mapType = .satellite
        }))
        actionSheet.addAction(UIAlertAction(title: "Terrain", style: .default, handler: {_ in
            self.mapView?.mapType = .terrain
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true, completion: nil)
    }
}



