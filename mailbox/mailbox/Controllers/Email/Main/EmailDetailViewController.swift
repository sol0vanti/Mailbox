import UIKit

class EmailDetailViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var fromLabel: UILabel!
    
    var emailFrom: String = ""
    var emailText: String = ""
    var emailTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.title = emailTitle
        textView.text = emailText
        fromLabel.text = "From: \(emailFrom)"
    }
}
