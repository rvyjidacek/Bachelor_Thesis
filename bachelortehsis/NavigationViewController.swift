//
//  NavigationViewController.swift
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 03.03.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//
import UIKit
import AVFoundation
import ImageIO
import ObjectiveC

protocol NavigationViewControllerDelegate: class {
    func finishNavigation(image: UIImage);
}

/**
 This class navigate user to take the same photo.
*/
class NavigationViewController : UIViewController {
    
/******************* Class variables *********************/
    
    /**
        Instance of camera session is used to start or stop show live camera preview.
    */
    private var cameraSession: AVCaptureSession!
    
    /**
        Object for getting images from camera
    */
    private var cameraImageOutput: AVCaptureStillImageOutput!
    
    /**
        In this layer is situated live camera preview.
    */
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    
    /**
        Camera connection to get images from live camera preview.
    */
    private var videoConnection: AVCaptureConnection!
    
    /**
        This object provide pass taken image to root view.
    */
    weak var delegate: NavigationViewControllerDelegate?
    
    /**
        Object for comparing photos.
    */
    private var imageProcessing: ImageProcessing!
    
    
    /**
        Object NSOperationQueue for bacground tasks.
    */
    private var backgroundTask = NSOperationQueue()
    
    /**
        This variable tell if program can continue taking photos.
    */
    private var continueCompare = true;
    
    /**
        The original image chossen by user.
    */
    var image: UIImage!
    
    
    /**
        Array of taken images.
    */
    var images: Array<UIImage>!
    
    
    /***/
    private var imageCounter = 0
    
    /***/
    private let MAX_IMAGE_COUNT = 5
    
/********************** UIComponents *************************/
    
    /**
        Starts and stop taking photos.
    */
    @IBOutlet weak var startBtn: UIButton!
    
    /**
        There is situated live camera preview.
    */
    @IBOutlet weak var cameraView: UIView!
    
    
    /**
        Show image from library over live camera preview.
    */
    @IBOutlet weak var imageView: UIImageView!
    
    /**
    
    */
    @IBOutlet weak var rotateTextLabel: UILabel!
    
    
    /**

    */
    @IBOutlet weak var iphoneImage: UIImageView!
    
    /**
        Show arrow with destination which user have to move to take same image.
    */
    @IBOutlet weak var positionToMoveImageView: UIImageView!
    
    
    @IBOutlet weak var takenImageCount: UILabel!
    
    
    @IBOutlet weak var takeImageBtn: UIButton!
    
    
/***************** Override  UIViewController methods *****************/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initCamera()
        self.images = Array();
        
        backgroundTask.name = "cz.upol.vyjiro00.BackgroundTask"
        
        backgroundTask.addOperationWithBlock({
            self.imageProcessing = ImageProcessing(image: self.image)
            var image = self.imageProcessing.image.getEgdeImage()
           
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.imageView.image = image
            })
            
        })
        
        if UIDevice.currentDevice().orientation.isLandscape {
            self.showControls()
            self.cameraSession.startRunning()
            self.cameraPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        } else {
            self.cameraSession.stopRunning()
            cameraView.hidden = true
            imageView.hidden = true
            startBtn.hidden = true
            takeImageBtn.hidden = true
            takenImageCount.hidden = true
            positionToMoveImageView.hidden = false
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if UIDevice.currentDevice().orientation.isPortrait {
            self.cameraSession.stopRunning()
            self.hideControls()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.initCamera();
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        var connection = cameraPreviewLayer.connection
        
        switch toInterfaceOrientation.rawValue {
        case UIInterfaceOrientation.Portrait.rawValue :
            self.hideControls()
           
        case UIInterfaceOrientation.LandscapeLeft.rawValue :
            connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            self.showControls()
            self.cameraSession.startRunning()
        default:
            connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            self.showControls()
            self.cameraSession.startRunning()

        }
      
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gallery" {
            let destinationVC = segue.destinationViewController as! GalleryViewController
            destinationVC.imageArray = self.images
            self.images = nil
            takenImageCount.text = "0"
        }
    }
    
    
    /**
        Show camera and image view and label with information about navigation.
    */
    private func showControls() {
        cameraView.hidden = false
        imageView.hidden = false
        startBtn.hidden = false
        takeImageBtn.hidden = false
        takenImageCount.hidden = false
        positionToMoveImageView.hidden = false
        self.navigationController?.navigationBarHidden = true
        self.iphoneImage.hidden = true
        self.rotateTextLabel.hidden = true
        
    }
    
    /**
        Hide camera and image view and label with information about navigation.
    */
    private func hideControls() {
        cameraView.hidden = true
        imageView.hidden = true
        startBtn.hidden = true
        takeImageBtn.hidden = true
        positionToMoveImageView.hidden = true
        takenImageCount.hidden = true
        self.navigationController?.navigationBarHidden = false
        self.iphoneImage.hidden = false
        self.rotateTextLabel.hidden = false
    }
    
    
    /**
        Initialize live camera preview.
    */
    func initCamera() {
        //Alloc and camera session
        cameraSession = AVCaptureSession()
        cameraSession.sessionPreset = AVCaptureSessionPresetPhoto
        var error: NSErrorPointer = nil;
        
        //Set up UIView for display live camera image
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
        cameraPreviewLayer.frame = cameraView.bounds
        self.imageView.frame = cameraView.bounds
        
        
        self.cameraView.layer.addSublayer(cameraPreviewLayer)
        
        //Select device
        var cameraDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var input = AVCaptureDeviceInput.deviceInputWithDevice(cameraDevice, error: error) as! AVCaptureInput
        
        if error != nil {
            var alert = UIAlertView(title: "Video vstup", message: "Video vstup není dotupný", delegate: self, cancelButtonTitle: "OK")
        }
        
        cameraSession.addInput(input);
        self.cameraImageOutput = AVCaptureStillImageOutput()
        let stillSettings = [AVVideoCodecJPEG:AVVideoCodecKey]
        self.cameraImageOutput.outputSettings = stillSettings
        
        if(self.cameraSession.canAddOutput(self.cameraImageOutput)){
            self.cameraSession.addOutput(self.cameraImageOutput)
        }
        
    }
    
    
    private func startBackgroundCompare() {
        self.cameraImageOutput.captureStillImageAsynchronouslyFromConnection(self.cameraImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: {(buffer: CMSampleBuffer!, error: NSError!) -> Void in
            var imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var imageFromCamera = UIImage(data: imageData)
            
            self.backgroundTask.addOperationWithBlock({
                if imageFromCamera != nil {
                    self.backgroundCompare(imageFromCamera!)
                }
                
            })
            
        })
    }
    
    private func backgroundCompare(image: UIImage) {
        var rotatedImage = UIImage(CGImage: image.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)!
        
        var myImage = MyImage(image: rotatedImage)
        var positionToMove =  self.imageProcessing.compare(myImage)
        myImage.freeRawData()
        
        var arrow = self.drawArrowTo(positionToMove)
    
        NSOperationQueue.mainQueue().addOperationWithBlock({
            
            self.positionToMoveImageView.image = arrow
            
            
            if self.imageProcessing.isPointArroundCenter(positionToMove) {
                if self.imageCounter >= self.MAX_IMAGE_COUNT {
                    self.continueCompare = false
                    self.hideControls()
                    self.performSegueWithIdentifier("gallery", sender: self)
                } else {
                    self.images.append(UIImage(CGImage: image.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)!)
                    self.imageCounter++
                    self.takenImageCount.text = String(self.imageCounter)
                    self.positionToMoveImageView.image = nil
                }
            }
            
            if self.continueCompare {
                self.startBackgroundCompare();
            }
        })
    }
    
    
    private func drawArrowTo(point: CGPoint) -> UIImage {
        var imageRect = self.positionToMoveImageView.bounds
        let centerPoint = CGPoint(x: self.positionToMoveImageView.frame.size.width / 2, y: self.positionToMoveImageView.frame.size.height / 2)
        let endPoint = CGPoint(x: point.x, y: point.y)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0)
        var bezierPath = UIBezierPath.bezierPathWithArrowFromPoint(centerPoint, endPoint: endPoint, tailWidth: 10, headWidth: 20, headLength: 15)
        
        UIColor.yellowColor().setFill()
        bezierPath.fill()
        bezierPath.closePath()
        var Arrowimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return Arrowimage
    }
    
    
    @IBAction func startTakingTheSamePhoto(sender: AnyObject) {
        var btn: UIButton = sender as! UIButton
        
        
        if (sender.currentTitle == "Start") {
            sender.setTitle("Stop", forState: UIControlState.Normal)
            self.startBackgroundCompare()
        } else if (sender.currentTitle == "Stop") {
            backgroundTask.cancelAllOperations()
            self.continueCompare = false
            self.hideControls()
            self.performSegueWithIdentifier("gallery", sender: self)
            sender.setTitle("Start", forState: UIControlState.Normal)
        }
        
        
    }
    
    @IBAction func takeImage(sender: UIButton) {
        self.cameraImageOutput.captureStillImageAsynchronouslyFromConnection(self.cameraImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: {(buffer: CMSampleBuffer!, error: NSError!) -> Void in
            var imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var imageFromCamera = UIImage(data: imageData)
            var rotatedImage = UIImage(CGImage: imageFromCamera?.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)
            
            self.images.append(rotatedImage!)
            self.imageCounter++
            self.takenImageCount.text = String(self.imageCounter)
            
            if self.imageCounter >= self.MAX_IMAGE_COUNT {
                self.hideControls()
                self.performSegueWithIdentifier("gallery", sender: self)
                self.continueCompare = false
            }
        })
    }
    
    

    
    
    
    
    
    
    
    
    
    

}