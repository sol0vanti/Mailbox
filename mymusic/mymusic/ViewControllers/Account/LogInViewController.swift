import UIKit
import FirebaseAuth
import Firebase
import Network

class LogInViewController: UIViewController {
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let defaults = UserDefaults.standard
    static var logInError: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard defaults.string(forKey: "email") == nil else {
            let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
            self.navigationController?.setViewControllers([destVC], animated: true)
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard NetworkMonitor.shared.isConnected else {
            let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "NetworkViewController") as! NetworkViewController
            self.navigationController?.setViewControllers([destVC], animated: true)
            return
        }
    }
    
    @IBAction func logButtonClicked(_ sender: UIButton) {
        let error = Helping.checkTextFields(errorLabel: errorLabel, textFields: [emailTextField, passwordTextField])
         
        guard error == nil else {
            Helping.showError(text: error!, label: errorLabel, textFields: [emailTextField,passwordTextField])
            return
        }
         
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
        if error != nil {
            Helping.showError(text: error!.localizedDescription, label: self.errorLabel, textFields: [self.emailTextField, self.passwordTextField])
        }
        else {
            let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "EmailViewController")
            self.defaults.set(self.emailTextField.text!, forKey: "email")
            self.navigationController?.setViewControllers([destVC], animated: true)
            }
        }
    }
    @IBAction func signButtonClicked(_ sender: UIButton) {
        let signUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController")
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
}
