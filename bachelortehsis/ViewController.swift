//
//  ViewController.swift
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 27.02.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import CoreLocation
import AssetsLibrary
import ImageIO
import MapKit

/**
    This class reprezent root view controller. 
    Provides to user the possibility to choose photo from library and start navigation.
*/
@objc class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NavigationViewControllerDelegate {

/******************* Class variables *********************/
    
    /**
        The UIImagePickerController class manages taking photos and videos.
    */
    var imagePicker = UIImagePickerController()

/******************* UI components *********************/
    
    /**
        This object show choosen image from library.
    */
    @IBOutlet weak var imageView: UIImageView!
    
    /**
        Start navigation of choosen image.
    */
    @IBOutlet weak var startNavigationBtn: UIButton!
    
    /**
        Warning text
    */
    @IBOutlet weak var warning: UILabel!
    
    private var gpsInformation: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startNavigationBtn.backgroundColor = UIColor.orangeColor()
        self.startNavigationBtn.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes =  [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor.orangeColor()
        self.startNavigationBtn.alpha = 0.0
        self.warning.alpha = 0.0
        self.warning.numberOfLines = 0;
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "navigation" {
            var destinationVC = segue.destinationViewController as! NavigationViewController
            destinationVC.delegate = self
            destinationVC.image = imageView.image
        }
    }

    func finishNavigation(image: UIImage) {
        self.navigationController?.popToRootViewControllerAnimated(true)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    

    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var info = NSDictionary(dictionary: info)
        var image = info.objectForKey(UIImagePickerControllerOriginalImage) as! UIImage
        let bounds = CGRectMake(0, 0, 1024, 768);
        
        UIGraphicsBeginImageContext(bounds.size);
        image.drawInRect(CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height))
        var scaled: UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        
        //Check if image is Portrait because portratit image are not supported yet.
        if image.size.width < image.size.height {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.warning.text = "Vyberte prosím širokoúhlou fotografii."
            self.warning.alpha = 1
        } else {
            self.warning.text = ""
            self.dismissViewControllerAnimated(true, completion: {
                UIView.animateWithDuration(0.3, animations: {
                    self.warning.alpha = 1
                    self.startNavigationBtn.alpha = 1
                })
            })
            self.imageView.image = scaled
            self.checkGPSCoordinatesInImageAndAsk(info)
        }
    }
    
    private func checkGPSCoordinatesInImageAndAsk(info: NSDictionary) {
        var referenceURL = info.objectForKey(UIImagePickerControllerReferenceURL) as! NSURL;
        var library = ALAssetsLibrary()
        
        library.assetForURL(referenceURL, resultBlock: { (asset: ALAsset!) in
            var rep = asset.defaultRepresentation()
            var metadata: Dictionary = rep.metadata()
            
            self.gpsInformation = metadata[kCGImagePropertyGPSDictionary] as? NSDictionary
            
            if self.gpsInformation != nil {
                
                let gpsConfirm = UIAlertController(title: "GPS", message: "Přejete si navigovat na místo pořízení fotografie", preferredStyle: UIAlertControllerStyle.Alert)
                
                gpsConfirm.addAction(UIAlertAction(title: "NE", style: UIAlertActionStyle.Cancel, handler: nil))
                
                gpsConfirm.addAction(UIAlertAction(title: "ANO", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    let latitude = self.gpsInformation?.objectForKey("Latitude") as! CLLocationDegrees
                    let longitude = self.gpsInformation?.objectForKey("Longitude") as! CLLocationDegrees
                    
                    self.openMapApp(latitude, longitute: longitude)
                    
                }))
                
                self.presentViewController(gpsConfirm, animated: true, completion: nil)
                
            }
            }, failureBlock: { (error: NSError!) in })
        
        
    }
    
    
    private func openMapApp(latitute: CLLocationDegrees, longitute: CLLocationDegrees) {
        let regionDistance:CLLocationDistance = 500
        var coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        var options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        var mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Místo pořízení"
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    
    @IBAction func choosePhotoFromLibrary(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
}