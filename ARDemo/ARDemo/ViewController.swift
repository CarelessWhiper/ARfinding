//
//  ViewController.swift
//  ARDemo


import UIKit
import ARCL
import CoreLocation
import SceneKit

class ViewController: UIViewController {

    var sceneLocationView = SceneLocationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        ARINIT()
       
        /*
         ARKit requires iOS 11, and supports the following devices:
         
         iPhone 6S and upwards
         iPhone SE
         iPad (2017)
         All iPad Pro models
         iOS 11 can be downloaded from Apple’s Developer website.
       
         */
        
        // All credits goes to creator of this library: Copyright (c) 2017 Project Dent (https://ProjectDent.com)
        // Reference link: https://github.com/ProjectDent/ARKit-CoreLocation
        
        
        // Lets run on device
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    func ARINIT()  { // Test locations around me. you can also plot these using google place API
       
        var location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 35.706107, longitude: 139.704933), altitude: 35.0) // ISKPRO
        let image = UIImage(named: "LocationPin")!
        var annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.annotationNode.name = "Point1"
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        location  = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 34, longitude: 138), altitude: 35) // Un named next to ISKPRO
        annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.annotationNode.name = "Point2"
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        location  = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 28.6101371, longitude: 77.3433248), altitude: 100) // R Systems
        annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.annotationNode.name = "Point3"
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        location  = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 28.604624, longitude: 77.3717694), altitude: 100) // Mamura
        annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        location  = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 28.6191904, longitude: 77.4209194), altitude: 100) // Gaur City
        annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.annotationNode.name = "Point4"
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        
        annotationNode = LocationAnnotationNode(location: nil, image: image)
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode:annotationNode) // Current location
        annotationNode.annotationNode.name = "My location"
        
    }
    
    // Touch events on nodes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneLocationView)
            
            let hitResults = sceneLocationView.hitTest(touchLocation, options: [.boundingBoxOnly : true])
            for result in hitResults {
                
                print("HIT:-> Name: \(result.node.description)")
                print("HIT:-> description  \(result.node.name)")
                
            }
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: - SceneLocationViewDelegate
@available(iOS 11.0, *)
extension ViewController: SceneLocationViewDelegate {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        print("7845768")
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        print("546456")
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
    }
}
