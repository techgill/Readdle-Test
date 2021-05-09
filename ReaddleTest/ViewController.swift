//
//  ViewController.swift
//  ReaddleTest
//
//  Created by Gill Hardeep on 01/05/21.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import SwiftyJSON

var sheetData = [sheetDataModel]()
var token = ""
let sheetId = "1etiP3xd4X19gguazWnxNU8maBobvz1ADToj8wUkBZkk"

class ViewController: UIViewController {
    
//    var sheetData = [sheetDataModel]()
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.borderWidth = 1.1
        signInButton.layer.borderColor = UIColor.link.cgColor
        signInButton.layer.cornerRadius = 6
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.clientID = "359098432892-oi97su2mi6v7ssj3f2p613uh1vl152n2.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/drive")
        GIDSignIn.sharedInstance()?.scopes.append("https://www.googleapis.com/auth/drive.file")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/spreadsheets")
    }
    
    @IBAction func didTapOnSignInButton(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func callGetFiles(token: String){
        var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetId)/values/Sheet1!A1:Z")!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else{
                print(String(describing: error))
                return
            }
//            print(String(data: data, encoding: .utf8)!)
            let json = try! JSON(data: data)
            DispatchQueue.main.async {
                for item in json["values"].arrayValue{
                    if item[0].stringValue != ""{
                        sheetData.append(sheetDataModel(json: item))
                    }
                }
                guard let vc = self.storyboard?.instantiateViewController(identifier: "ListViewController") as? RootListViewController else{ return}
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
        task.resume()
    }

}

extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue{
                print("new or signed out")
            }else{
                print(error.localizedDescription)
            }
            return
        }
        if let userToken = user.authentication.accessToken{
            token = userToken
        }
        callGetFiles(token: token)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //
    }
}

struct sheetDataModel: Equatable {
    var itemUUID = ""
    var itemParentUUID = ""
    var itemType = ""
    var itemName = ""
    
    init(json: JSON) {
        self.itemUUID = json[0].stringValue
        self.itemParentUUID = json[1].stringValue
        self.itemType = json[2].stringValue
        self.itemName = json[3].stringValue
    }
    
    init() {
    }
}







//    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
//    private let service = GTLRSheetsService()



//    func getData() {
//        let spreadsheetId = "1nZ3nqazaCVcgQuuoIc1hTbfqu6MoW_9BIAKxhURZaYk" // Portfolio
//        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:"A1:Z")
//        service.executeQuery(query, delegate: self, didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
//    }
//
//    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
//                                           finishedWithObject result : GTLRSheets_ValueRange,
//                                           error : NSError?) {
//        if let error = error{
//            print(error.localizedDescription)
//        }else{
//            print(result)
//        }
//    }


//        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
//        self.service.apiKey = "AIzaSyDu3l8U9SQvhq5-GcTgBXcbjUwX9AODVZg"
