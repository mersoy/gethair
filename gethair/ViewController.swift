//
//  ViewController.swift
//  gethair
//
//  Created by Muge Ersoy on 25/10/2015.
//  Copyright © 2015 Muge Ersoy. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController,UIImagePickerControllerDelegate ,UINavigationControllerDelegate ,MFMailComposeViewControllerDelegate{

    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var infoText: UITextView!
    @IBOutlet weak var imageView: UIImageView!
  
    @IBOutlet weak var applyBlur: UIButton!
    @IBOutlet weak var blurImageView: UIImageView!
    var lastTouchPosition : CGPoint?

    override func viewDidLoad() {
        blurImageView.hidden = true
        applyBlur.enabled = false
        sendButton.enabled = false


    }

    @IBAction func applyBlur(sender: AnyObject) {
        blurImageView.hidden = !blurImageView.hidden
        
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        let picker = UIImagePickerController.init()
        picker.delegate = self
        picker.sourceType = .Camera
        picker.cameraDevice = .Front
        self.presentViewController(picker, animated: true, completion: nil)
        
    }

    @IBAction func selectPhoto(sender: AnyObject) {
        let picker = UIImagePickerController.init()
        picker.delegate = self
        picker.sourceType = .SavedPhotosAlbum
        self.presentViewController(picker, animated: true, completion: nil)

    }
    
    // MARK: move around the image

    @IBAction func pinchGesture(recognizer: UIPinchGestureRecognizer) {
 
        var hScale : CGFloat?
        var vScale : CGFloat?
        
        
        if recognizer.state == .Began {
            lastTouchPosition = recognizer.locationInView(self.view)
            hScale = 1.0
            vScale = 1.0
        }else if recognizer.state == .Began || recognizer.state == .Changed {
            let currentTouchLocation = recognizer.locationInView(self.view)

            let deltaMove = CGPointMake(currentTouchLocation.x - lastTouchPosition!.x, currentTouchLocation.y - lastTouchPosition!.y);
            let distance = sqrt(deltaMove.x*deltaMove.x + deltaMove.y*deltaMove.y);
                print(recognizer.scale)
            print("distance \(distance)")
          
            let deltaDistance = abs(deltaMove.x)/distance
            print("deltaDistance \(deltaDistance)")
            
            
            hScale = 1 - deltaDistance * (1 - recognizer.scale)
            vScale = 1 - abs(deltaMove.y)/distance * (1 - recognizer.scale)
            if distance == 0.0
            {
                hScale = 1.0
                vScale = 1.0
            }
            
            print(hScale,vScale)
            blurImageView.transform = CGAffineTransformScale(blurImageView.transform ,hScale!, vScale!)
            recognizer.scale = 1
            lastTouchPosition = currentTouchLocation


        }

    }
    
    @IBAction func sendImage(sender: UIBarButtonItem) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = configuredMailComposeViewController()
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    @IBAction func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let myView = recognizer.view {
            myView.center = CGPoint(x: myView.center.x + translation.x, y: myView.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
   // MARK: mage Picker Controller delegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        infoText.hidden = true
        applyBlur.enabled = true
        sendButton.enabled = true

        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = chosenImage
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        if imageView.image == nil
        {
            sendButton.enabled = false
            applyBlur.enabled = false
            blurImageView.hidden = true
            infoText.hidden = false
        }
        picker.dismissViewControllerAnimated(true, completion: nil)

    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
   
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        //mailComposerVC.setToRecipients(["muge.ersoy@gmail.com"])
        mailComposerVC.setSubject("here is my awesome results")
        mailComposerVC.setMessageBody("I grew that much hair!!", isHTML: false)
        
        
        let image = combineImages()
        let imageData = UIImagePNGRepresentation(image)
        
        mailComposerVC.addAttachmentData(imageData!, mimeType: "image/png", fileName: "ImageName")

        
        return mailComposerVC
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showSendMailErrorAlert() {
   
        
        let alertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again or you can save the image ", preferredStyle: .Alert)

        let okAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            UIImageWriteToSavedPhotosAlbum(self.combineImages(), self, "image:didFinishSavingWithError:contextInfo:", nil)

            NSLog("OK Pressed")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    
    // MARK - helper
    
    func combineImages() ->UIImage{
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0.0);
        let rec1 = CGRectMake(0,0,imageView.frame.size.width, imageView.frame.size.height)
        
        imageView.image?.drawInRect(rec1)
        
        let rec2 = CGRectMake(blurImageView.frame.origin.x , blurImageView.frame.origin.y - 64 ,(blurImageView.frame.size.width), blurImageView.frame.size.height)
        blurImageView.image?.drawInRect(rec2)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage
    }

}

