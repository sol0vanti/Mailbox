//
//  Request.swift
//  mailbox
//
//  Created by Alex Balla on 02.11.2023.
//

import Foundation

struct Request: Identifiable {
    var id: String
    var email: String
    var title: String
    var message: String
    var user: String
}
