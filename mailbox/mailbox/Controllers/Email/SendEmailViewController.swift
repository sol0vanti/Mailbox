import UIKit
import Firebase
import PhotosUI
import FirebaseStorage

class SendEmailViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var addFileButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var attachedFilesLabel: UILabel!
    @IBOutlet weak var toTextField: UITextField!
    
    let defaults = UserDefaults.standard
    var images: [UIImage] = []
    
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
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    self.images.append(image)
                    DispatchQueue.main.async {
                        guard self.images.count != 0 else { return }
                        self.attachedFilesLabel.isHidden = false
                        if self.images.count == 1 {
                            self.attachedFilesLabel.text = "\(self.images.count) file attached"
                        } else {
                            self.attachedFilesLabel.text = "\(self.images.count) files attached"
                        }
                    }
                }
            }
        }
    }
    
    func uploadImagesToFirebase() {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle the case where the user is not authenticated
            return
        }
        
        let storage = Storage.storage()
        
        for (index, image) in images.enumerated() {
            // Convert the image to Data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                // Handle the case where the image data couldn't be generated
                continue
            }
            
            // Check if to text field is not equal nil
            guard toTextField != nil else { return }
            
            // Create a unique name for each image using a timestamp
            let imageName = "image_\(index)_\(toTextField.text!).jpg"
            
            // Create a reference to the Firebase Storage location
            let storageRef = storage.reference().child("images").child(currentUser.uid).child(imageName)
            
            // Upload the image to Firebase Storage
            let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    // Handle the error during the upload
                    print("Error uploading image: \(error.localizedDescription)")
                } else {
                    // Image uploaded successfully, get the download URL
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            // Handle the error while getting the download URL
                            print("Error getting download URL: \(error.localizedDescription)")
                        } else {
                            // Use the download URL as needed
                            if let downloadURL = url {
                                print("Download URL for image \(index): \(downloadURL.absoluteString)")
                            }
                        }
                    }
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
            
            db.collection("emails").addDocument(data: ["email": self.toTextField.text!, "message": self.textView.text!, "title": self.titleTextField.text!, "user": self.defaults.string(forKey: "email")!]) { (error) in
                if error != nil {
                    Helping.showError(text: "Error saving user data", label: self.errorLabel, textFields: [])
                }
            }
            
            self.uploadImagesToFirebase()
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(ac, animated: true)
    }
}
