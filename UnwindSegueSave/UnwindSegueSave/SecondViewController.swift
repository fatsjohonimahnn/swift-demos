//
//  SecondViewController.swift
//  UnwindSegueSave
//
//  Created by Jonathon Fishman on 9/18/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // outgoing data
    var newName: String?
    var newPhoto: UIImage?
    
    // incoming data
    var currentName: String?
    var currentPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        
        // Enable the Save button only if the text field has a valid name.
        checkValidName()
        
        // Add incoming data to the refoutlets and navbar
        userImage.image = currentPhoto
        userNameTextField.placeholder = currentName
        navigationItem.title = currentName

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if saveButton === sender as! UIBarButtonItem {
            
            // nil coalescing operator returns value of an optional or a default value
            newName = userNameTextField.text ?? ""
            newPhoto = userImage.image
            
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func onImageTap(_ sender: UITapGestureRecognizer) {
        
        // ensure keyboard is dismissed
        userNameTextField.resignFirstResponder()
        
        // create UIImagePickerController
        // a VC that lets user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        // UINavigationControllerDelegate must be set
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        
        // old way
        //self.navigationController?.popViewController(animated: true)
        
        // new way
        _ = navigationController?.popViewController(animated: true)

    }
    
    
    // MARK: UIImagePickerControllerDelegate
    
    // From UIImagePickerControllerDelegate called when image picker’s Cancel button tapped
    // opportunity to dismiss the UIImagePickerController (and optionally, do any necessary cleanup)
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    // From UIImagePickerControllerDelegate called when photo selected
    // opportunity to do something with image ex: display in UI
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        userImage.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: UITextFieldDelegate methods
    
    // From UITextFieldDelegate method called when "Return" taped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // From UITextFieldDelegate called when editing session begins, or when keyboard displayed.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    // helper method to disable the Save button if the text field is empty.
    func checkValidName() {
        // Disable the Save button if the text field is empty.
        let text = userNameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // From UITextFieldDelegate called after textField resigns first responder
    func textFieldDidEndEditing(_ textField: UITextField) {
        // opportunity to read info entered in text field and do something with it... like:
        // check if the text field has text in it
        checkValidName()
        // sets the title of the scene to that text.
        navigationItem.title = textField.text
    }
    
}
