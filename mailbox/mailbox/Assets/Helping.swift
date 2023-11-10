import UIKit

struct Helping {
    static func showError(text: String, label: UILabel, textFields: [UITextField]){
        label.isHidden = false
        label.text = text
        for textField in textFields {
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.systemPink.cgColor
        }
    }
    
    static func checkTextFields(errorLabel: UILabel, textFields: [UITextField], confirmationField: UITextField? = nil, passwordTextField: UITextField? = nil) -> String? {
        for textField in textFields {
            if textField.text!.count <= 2 {
                return "Refill the highlighted text fields."
            }
        }
        
        guard confirmationField != nil else { return nil }
        
        if confirmationField?.text != passwordTextField?.text {
            return "Your password does not match two times, please try again later"
        }
        
        return nil
    }
}
