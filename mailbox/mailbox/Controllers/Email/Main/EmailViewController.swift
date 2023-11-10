//
//  MailViewController.swift
//  mailbox
//
//  Created by Alex Balla on 27.10.2023.
//

import UIKit
import Firebase

class EmailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let defaults = UserDefaults.standard
    @IBOutlet weak var table: UITableView!
    var requests: [Request]!
    var indexPath: IndexPath!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        table.delegate = self
        table.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", image: UIImage(systemName: "plus.circle.fill"), target: self, action: #selector(sendButtonClicked))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", image: UIImage(systemName: "person.circle.fill"), target: self, action: #selector(profileButtonClicked))
    }
    
    func getData(){
        let database = Firestore.firestore()
        database.collection("emails").whereField("email", isEqualTo: defaults.string(forKey: "email")!).getDocuments() {(snapshot, error) in
            if error != nil {
                print(String(describing: error))
            } else {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        print(self.defaults.string(forKey: "email")!)
                        self.requests = snapshot.documents.map { d in
                            return Request(id: d.documentID, email: d["email"] as? String ?? "gg@test.com", title: d["title"] as?String ?? "title", message: d["message"] as? String ?? "message", user: d["user"] as? String ?? "user")
                        }
                        self.table.reloadData()
                        print(self.requests!)
                    }
                }
            }
        }
    }
    
    @objc func profileButtonClicked(){
        let ac = UIAlertController(title: "Profile", message: "Choose option:", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Log out", style: .destructive){ _ in
            let ac = UIAlertController(title: "Log out", message: "Are you sure you want to log out from your account? By clicking submit you will log out from your account and your data will be saved.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            ac.addAction(UIAlertAction(title: "Submit", style: .default){_ in
                let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "LogInViewController")
                self.defaults.removeObject(forKey: "email")
                self.navigationController?.setViewControllers([destVC], animated: true)
            })
            self.present(ac, animated: true)
        })
        ac.addAction(UIAlertAction(title: "Update data", style: .default){ _ in
            self.getData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func sendButtonClicked(){
        let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SendEmailViewController") as! SendEmailViewController
        self.navigationController?.pushViewController(destVC, animated: true)
        return
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard requests != nil else { return 0 }
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let request = requests[indexPath.row]
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EmailTableViewCell
        cell.email.text = request.user
        cell.title.text = request.title
        cell.message.text = request.message
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
}
