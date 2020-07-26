//
//  ViewController.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
  
  /*var featuresController: UIViewController!
  var centerController: UIViewController!
  var isExpanded = false*/
  
  @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
  @IBOutlet weak var canvasView: PKCanvasView!
  
  
  let canvasWidth: CGFloat = 768
  let canvasOverscrollHeight: CGFloat = 500
  
  var drawing = PKDrawing()
  

  override func viewDidLoad() {
    super.viewDidLoad()
    canvasView?.delegate = self
    canvasView?.drawing = drawing
    //rotatedPhoto = rotatedPhoto?.imageRotatedByDegrees(90, flip: false)
    //configureHomeController()
    
    canvasView?.alwaysBounceVertical = true
    canvasView?.allowsFingerDrawing = true
    
     if let window = parent?.view.window,

        let toolPicker = PKToolPicker.shared(for: window){
         
         toolPicker.addObserver(canvasView)
         
         canvasView.becomeFirstResponder()
       }
  }
  
  /*override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }*/
  
  /*func configureHomeController() {
    let sketchController = HomeController()
    sketchController.delegate = self
    centerController = UINavigationController(rootViewController: sketchController)
    //let controller = UINavigationController(rootViewController: sketchController)
    
    view.addSubview(centerController.view)
    addChild(centerController)
    centerController.didMove(toParent: self)
  }*/
  
  /*func configureFeaturesController() {
    if featuresController == nil {
      featuresController = FeaturesController()
      view.insertSubview(featuresController.view, at: 0)
      addChild(featuresController)
      featuresController.didMove(toParent: self)
      print("Did add menu controller...")
    }
  } */
  
  /*func showFeaturesController(shouldExpand: Bool) {
    if shouldExpand {
      //show menu
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
        self.centerController.view.frame.origin.x = self.centerController.view.frame.width - 00
      }, completion: nil)
    }
    else {
      //hide menu
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
        self.centerController.view.frame.origin.x = 0
      }, completion: nil)
    }
  } */
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let canvasScale = canvasView.bounds.width / canvasWidth
    canvasView?.minimumZoomScale = canvasScale
    canvasView?.maximumZoomScale = canvasScale
    canvasView?.zoomScale = canvasScale
    
    updateContentSizeForDrawing()
    canvasView?.contentOffset = CGPoint(x:0, y: -canvasView.adjustedContentInset.top)
  }
  
  override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  @IBAction func toogleFingerOrPencil(_ sender: Any) {
    canvasView?.allowsFingerDrawing.toggle()
    pencilFingerButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
  }
  
  @IBAction func saveDrawingToCameraRoll(_ sender: Any) {
    UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
    
    canvasView?.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if image != nil {
      PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAsset(from: image!)}, completionHandler: {success, error in
        //deal with success or error
      })
    }
  }
  
  func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    updateContentSizeForDrawing()
    
  }
  
  func updateContentSizeForDrawing() {
    let drawing = canvasView.drawing
    let contentHeight: CGFloat
    
    if !drawing.bounds.isNull {
      contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHeight) * canvasView.zoomScale)
    } else {
      contentHeight = canvasView.bounds.height
    }
    canvasView?.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
  }
  
  //add image picker functions below (for importing)
  @IBAction func imagePickerBtnAction(_ sender: Any) {
    let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
        self.openCamera()
    }))

    alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
        self.openGallery()
    }))

    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

    self.present(alert, animated: true, completion: nil)
  }
  
  func openCamera()
  {
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
          let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
          imagePicker.sourceType = UIImagePickerController.SourceType.camera
          imagePicker.allowsEditing = false
          self.present(imagePicker, animated: true, completion: nil)
      }
      else
      {
          let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          self.present(alert, animated: true, completion: nil)
      }
  }
  
  func openGallery()
  {
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
          let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
          imagePicker.allowsEditing = true
          imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
          self.present(imagePicker, animated: true, completion: nil)
      }
      else
      {
          let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          self.present(alert, animated: true, completion: nil)
      }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[.originalImage] as? UIImage {
         // imageViewPic.contentMode = .scaleToFill
      let imageName = "newImage.png"
      let image = UIImage(named: imageName)
      let newImage = UIImageView(image: image)
      newImage.image = pickedImage
          //imageViewPic.image = pickedImage
      
      //let imageView = UIImageView(image: image)
      
      newImage.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
      //allow user to move image
      newImage.contentMode = .scaleToFill
      newImage.isUserInteractionEnabled = true
      newImage.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector(("handlePan:"))))
      view.addSubview(newImage)
      }
      picker.dismiss(animated: true, completion: nil)
  }
  
  //allow user to crop image
  func snapshot(in imageView: UIImageView, rect: CGRect) -> UIImage {
      return UIGraphicsImageRenderer(bounds: rect).image { _ in
          imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
      }
  }

}

//allow user to enlarge & minimize image
extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
  
   /*public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
         let radiansToDegrees: (CGFloat) -> CGFloat = {
             return $0 * (180.0 / CGFloat(M_PI))
         }
         let degreesToRadians: (CGFloat) -> CGFloat = {
             return $0 / 180.0 * CGFloat(M_PI)
         }

         // calculate the size of the rotated view's containing box for our drawing space
    let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: self.bounds.size))
    let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
         rotatedViewBox.transform = t
         let rotatedSize = rotatedViewBox.frame.size

         // Create the bitmap context
         UIGraphicsBeginImageContext(rotatedSize)
         let bitmap = UIGraphicsGetCurrentContext()

         // Move the origin to the middle of the image so we will rotate and scale around the center.
         CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);

         //   // Rotate the image context
         CGContextRotateCTM(bitmap, degreesToRadians(degrees));

         // Now, draw the rotated/scaled image into the context
         var yFlip: CGFloat

         if(flip){
             yFlip = CGFloat(-1.0)
         } else {
             yFlip = CGFloat(1.0)
         }

         CGContextScaleCTM(bitmap, yFlip, -1.0)
         CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)

         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()

         return newImage
     }*/
}

/*extension ViewController:HomeControllerDelegate{
  func handleMenuToggle() {
    //configureFeaturesController()
    
    if !isExpanded {
      configureFeaturesController()
    }
    
    isExpanded = !isExpanded
    showFeaturesController(shouldExpand: isExpanded)
  }
  
   
  
} */

