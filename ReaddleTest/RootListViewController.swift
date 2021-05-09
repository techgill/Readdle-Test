//
//  ListViewController.swift
//  ReaddleTest
//
//  Created by Tech Gill on 06/05/21.
//

import UIKit
import SwiftyJSON

class RootListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mainData = [sheetDataModel]()
    var createNewFileButton: UIBarButtonItem!
    var createNewDirectoryButton: UIBarButtonItem!
    var listViewButton: UIBarButtonItem!
    var gridViewButton: UIBarButtonItem!
    var isTableViewShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        updateNavBar()
        getArrays()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func updateNavBar(){
        title = "Sample"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: #selector(didTapOnProfileImage))
        createNewFileButton = UIBarButtonItem(image: UIImage(systemName: "note.text.badge.plus"), style: .plain, target: self, action: #selector(didTapOncreateNewFileButton))
        createNewDirectoryButton = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(didTapOncreateNewDirectoryButton))
        listViewButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(didTapOnswitchViewButton))
        gridViewButton = UIBarButtonItem(image: UIImage(systemName: "square.grid.2x2"), style: .plain, target: self, action: #selector(didTapOnswitchViewButton))
        navigationItem.rightBarButtonItems = [listViewButton, createNewDirectoryButton, createNewFileButton]
    }
    
    @objc func didTapOnProfileImage(_ sender: UIBarButtonItem){
        
    }
    
    @objc func didTapOncreateNewFileButton(_ sender: UIBarButtonItem){
        let alert = UIAlertController(title: "Create new file", message: nil, preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter file name here"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            let textField = alert.textFields![0] as UITextField
            guard textField.text != "" else{return}
            var newEntry = sheetDataModel()
            newEntry.itemName = textField.text!
            newEntry.itemType = "f"
            newEntry.itemUUID = UUID().uuidString
            newEntry.itemParentUUID = ""
            self.updateData(entry: newEntry)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapOncreateNewDirectoryButton(_ sender: UIBarButtonItem){
        let alert = UIAlertController(title: "Create new directory", message: nil, preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter file name here"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            let textField = alert.textFields![0] as UITextField
            guard textField.text != "" else{return}
            var newEntry = sheetDataModel()
            newEntry.itemName = textField.text!
            newEntry.itemType = "d"
            newEntry.itemUUID = UUID().uuidString
            newEntry.itemParentUUID = ""
            self.updateData(entry: newEntry)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapOnswitchViewButton(_ sender: UIBarButtonItem){
        if !isTableViewShowing{
            navigationItem.rightBarButtonItems = [gridViewButton, createNewDirectoryButton, createNewFileButton]
            collectionView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }else{
            navigationItem.rightBarButtonItems = [listViewButton, createNewDirectoryButton, createNewFileButton]
            collectionView.isHidden = false
            tableView.isHidden = true
            collectionView.reloadData()
        }
        isTableViewShowing.toggle()
    }
    
    func getArrays(){
        mainData = sheetData
        let new = sheetData.filter({
            $0.itemParentUUID == "" && $0.itemUUID != ""
        })
        mainData = new
        if isTableViewShowing{
            tableView.reloadData()
        }else{
            collectionView.reloadData()
        }
    }
    
    func updateData(entry: sheetDataModel){
        callUpdateFiles(entry: entry)
    }
    
    func callUpdateFiles(entry: sheetDataModel){
        let range = "Sheet1!A\(sheetData.count + 1):D\(sheetData.count + 1)"
        let parameters = ["valueInputOption": "USER_ENTERED", "data": [["majorDimension": "Rows", "range": "\(range)", "values":[[entry.itemUUID, entry.itemParentUUID, entry.itemType, entry.itemName]]]]] as [String : Any]
        var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetId)/values:batchUpdate")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else{
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            let json = try! JSON(data: data)
            DispatchQueue.main.async {
                if json["responses"].arrayValue.count != 0{
                    sheetData.append(entry)
                    self.getArrays()
                }
            }
        }
        task.resume()
    }
    
    func callDeleteFiles(index: Int){
        let range = "Sheet1!A\(index + 1):D\(index + 1)"
        var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetId)/values/\(range):clear")!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else{
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            DispatchQueue.main.async {
//                sheetData.remove(at: index)
                sheetData[index]  = sheetDataModel()
                self.getArrays()
            }
        }
        task.resume()
    }

}

extension RootListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RootListTableViewCell", for: indexPath) as? RootListTableViewCell else{return UITableViewCell()}
        cell.fillDetails(details: mainData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard mainData[indexPath.row].itemType == "d" else{return}
//        let new = sheetData.filter({
//            $0.itemParentUUID == mainData[indexPath.row].itemUUID
//        })
        guard let vc = self.storyboard?.instantiateViewController(identifier: "ChildListViewController") as? ChildListViewController else{return}
//        vc.childData = new
        vc.itemUUID = mainData[indexPath.row].itemUUID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
      let index = indexPath.row
      let identifier = "\(index)" as NSString
      
      return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { (_) in
            print("delete")
            if let index = sheetData.firstIndex(of: self.mainData[indexPath.row]) {
                print("Found peaches at index \(index)")
                self.callDeleteFiles(index: index)
            }
        }
          return UIMenu(title: "", image: nil, children: [deleteAction])
      }
    }
}

extension RootListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((self.collectionView.frame.width - 42) / 3), height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RootListCollectionViewCell", for: indexPath) as? RootListCollectionViewCell else{return UICollectionViewCell()}
        cell.fillDetails(details: mainData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard mainData[indexPath.row].itemType == "d" else{return}
//        let new = sheetData.filter({
//            $0.itemParentUUID == mainData[indexPath.row].itemUUID
//        })
        guard let vc = self.storyboard?.instantiateViewController(identifier: "ChildListViewController") as? ChildListViewController else{return}
//        vc.childData = new
        vc.itemUUID = mainData[indexPath.row].itemUUID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?{
        let index = indexPath.row
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
          let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { (_) in
              print("delete")
              if let index = sheetData.firstIndex(of: self.mainData[indexPath.row]) {
                  print("Found peaches at index \(index)")
                  self.callDeleteFiles(index: index)
              }
          }
            return UIMenu(title: "", image: nil, children: [deleteAction])
        }
    }
    
}

extension RootListViewController: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    return nil
  }
}
