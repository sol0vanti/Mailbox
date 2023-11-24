import UIKit
import Firebase
import FirebaseStorage

class EmailDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var fromLabel: UILabel!
    let defaults = UserDefaults.standard
    var images: [UIImage] = []
    var emailFrom: String = ""
    var emailText: String = ""
    var emailTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.title = emailTitle
        textView.text = emailText
        fromLabel.text = "From: \(emailFrom)"
        getImages()
    }
    
    func getImages(){
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference().child("images").child(defaults.string(forKey: "email")!).child(emailTitle)
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing items: \(error.localizedDescription)")
                return
        }
            for item in result!.items {
                item.getData(maxSize: 1 * 4048 * 4048) { (data, error) in
                    if let error = error {
                        print("Error downloading data: \(error.localizedDescription)")
                        return
                    }
                    if let data = data, let image = UIImage(data: data) {
                        self.images.append(image)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? EmailDetailCollectionViewCell else {
                    fatalError("unable to dequeue a reusable cell")
        }
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
