//
//  ViewController.swift
//  MeMe
//
//  Created by Mauricio A Cabreira on 22/05/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
// TODO: 
/*

 select the image and show it in the VC
 share button
 
 
 
 
 
 */

import UIKit



struct Meme {
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    var clearTopField = true
    var clearBottomField = true
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3]
  
    
    
    // MARK: Outlets
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var rawImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    // MARK: ViewController Events
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting delegates
        self.topText.delegate = self
        self.bottomText.delegate = self
        
        resetStatus()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        //This line does not show the tool and nav bars...
        self.toolBar.isHidden = false
        self.navigationBar.isHidden = false

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // MARK: Actions
    
    //User hit cancel, return to original state: no image, default text.
    @IBAction func cancelMeme(_ sender: Any) {
        
        resetStatus()
    
    }
    
    
    @IBAction func exportMeme(_ sender: Any) {
        
        // Create the meme
        
        //arrumar bug aqui que dá quando clica exportar sem ter carregado imagem.
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: rawImage.image!, memedImage: memedImage)
        let controller = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
            self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate =  self
        present(pickerController, animated: true, completion: nil)
        
        self.toolBar.isHidden = false
        self.navigationBar.isHidden = false

    }

    @IBAction func pickAnImageFromCamera(_ sender: Any) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    // MARK: Subscription functions
    
    //Keyboard notifications (un)subscription
    func subscribeToKeyboardNotifications() {
        
        //Keyboard will show subscription
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        //Keyboard will show subscription
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        //Keyboard will show unsubscription
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        
        //Keyboard will hide unsubscription
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: Auxiliar functions
    
    func resetStatus() {
        
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        
        topText.text = "TOP"
        //topText.placeholder = "TOP"
        bottomText.text = "BOTTOM"
        //bottomText.placeholder = "BOTTOM"

        
        let topAttrString = NSAttributedString(string: topText.text!, attributes: memeTextAttributes)
        topText.attributedText = topAttrString
        
        let bottomAttrString = NSAttributedString(string: bottomText.text!, attributes: memeTextAttributes)
        bottomText.attributedText = bottomAttrString
        
        shareButton.isEnabled = false
        rawImage.image = nil
        
        clearTopField = true
        clearBottomField = true
        
    }
    
    func keyboardWillShow(_ notification:Notification) {
        
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
        
    }
    
    func keyboardWillHide(_ notification:Notification) {
        
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    //MARK: Image related functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            rawImage.image = image
            rawImage.contentMode = UIViewContentMode.scaleAspectFit
            //the line below stratches the image, and changes its aspect
            //rawImage.contentMode = UIViewContentMode.scaleToFill
            
            dismiss(animated: true, completion: nil)
            shareButton.isEnabled = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        shareButton.isEnabled = false
        
    }
    
    
    func generateMemedImage() -> UIImage {
        
        //Hide navigation and toolbars
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
        
       
        return memedImage
    }
    
    
    // MARK: Delegates
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if topText.isFirstResponder {
            if clearTopField {
                print("about to reset top filed")
                clearTopField = false
                textField.text = ""
                print("top field reseted")
            }
        }
        if bottomText.isFirstResponder {
            if clearBottomField {
                clearBottomField = false
                textField.text = ""
            }
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }


    
}

