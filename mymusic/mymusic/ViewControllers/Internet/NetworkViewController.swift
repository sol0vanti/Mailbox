//
//  NetworkViewController.swift
//  mymusic
//
//  Created by Alex Balla on 28.11.2023.
//

import UIKit
import Network

class NetworkViewController: UIViewController {
    @IBOutlet weak var networkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func networkButtonDidTapped(_ sender: UIButton) {
        if NetworkMonitor.shared.isConnected {
            let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
            self.navigationController?.setViewControllers([destVC], animated: true)
            return
        }
    }
}
