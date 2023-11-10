//
//  SendEmailViewController.swift
//  mailbox
//
//  Created by Alex Balla on 07.11.2023.
//

import UIKit
import Firebase
import PhotosUI

class SendEmailViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var addFileButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    let defaults = UserDefaults.standard
    var imagesAttached: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", image: UIImage(systemName: "paperplane"), target: self, action: #selector(sendButtonClicked))
    }
    
    @IBAction func addFileButtonClicked(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 3
        let phPickerVC = PHPickerViewController(configuration: config)
        phPickerVC.delegate = self
        self.present(phPickerVC, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self){ object, error in
                if let image = object as? UIImage {
                    print(type(of: image))
                }
            }
        }
    }
    
    @objc func sendButtonClicked(){
        let ac = UIAlertController(title: "Attention!", message: "Are you sure you want to send an email? After pressing: 'submit' button email will automaticly be sent.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        ac.addAction(UIAlertAction(title: "Submit", style: .default){_ in
            let error = Helping.checkTextFields(errorLabel: self.errorLabel, textFields: [self.toTextField, self.titleTextField])
             
            guard error == nil else {
                Helping.showError(text: error!, label: self.errorLabel, textFields: [self.toTextField, self.titleTextField])
                return
            }
            
            let db = Firestore.firestore()
            
            db.collection("emails").addDocument(data: ["email": self.toTextField.text!, "image": self.imagesAttached, "message": self.textView.text!, "title": self.titleTextField.text!, "user": self.defaults.string(forKey: "email")!]) { (error) in
                if error != nil {
                    Helping.showError(text: "Error saving user data", label: self.errorLabel, textFields: [])
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(ac, animated: true)
    }
}
