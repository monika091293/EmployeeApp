//
//  ListViewController.swift
//  EmployeeApp
//
//  Created by Monika Mohan on 19/06/22.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    var tableFilterData = [Employees]()
    @IBOutlet weak var search: UITextField!
    var searchActive = false
    private let cellID = "cellID"
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: EmployeeDetails.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    var emp = [Employees]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Employee Portal"
        view.backgroundColor = .white
        search.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        updateTableContent()
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    func updateTableContent() {
        
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        let service = APIService()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! LIstTVCell
        
        if let photo = fetchedhResultController.object(at: indexPath) as? EmployeeDetails {
            cell.setListTVCellWith(emp: photo)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if var count = fetchedhResultController.fetchedObjects?.count{
            print("number of rows",count)
            if searchActive{
                count = tableFilterData.count
            }
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 //100 = sum of labels height + height of divider line
    }
    var selectedTask: Employees?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        selectedTask = emp[indexPath.row]
        self.performSegue(withIdentifier: "showDetail", sender: self)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            var detailVC: DetailViewController = segue.destination as! DetailViewController
            detailVC.empData = selectedTask
            
            
        }
        
        
    }
    
//MARK: - CoreData
    private func saveInCoreDataWith(array: [[String:AnyObject]]) {
        print(array)
        var newData = array
        
        if let item  = try? JSONSerialization.data(withJSONObject:array){
            
            let jsonDecoder = JSONDecoder()
            do{
                let secondDog = try jsonDecoder.decode([Employees].self, from: item)
                
                for each in secondDog{
                    
                    emp.append(each)
                }
                print("emp data",emp.count,emp)
                insertEmployees(emp: emp)
            }
            
            catch{
                print(error)
            }
            
        }
        
        
        
    }
    

    
    func insertEmployees(emp:[Employees]){
       
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        for user in emp {
            let newUser = NSEntityDescription.insertNewObject(forEntityName: "EmployeeDetails", into: context)
            newUser.setValue(user.id, forKey: "id")
            newUser.setValue(user.name, forKey: "name")
            newUser.setValue(user.email, forKey: "email")
            newUser.setValue(user.profile_image, forKey: "profileImage")
            newUser.setValue(user.company?.name, forKey: "companyName")
        }
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error saving: \(error)")
        }
        
        
        
        
        
    }
    
    
    
    
    
    private func clearData() {
        do {
            
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: EmployeeDetails.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func refetch(with text: String) {
        let predicate = NSPredicate(format: "firstName CONTAINS %@", text)
        fetchedhResultController.fetchRequest.predicate = predicate
        
        do {
            try self.fetchedhResultController.performFetch()
            tableView.reloadData()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
}


extension ListViewController : NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}

extension ListViewController : UITextFieldDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        searchActive = true
        tableView.reloadData()
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.description)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchActive = false
        tableView.reloadData()
    }
    
    
    
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        searchActive = true
        let searchText  = search.text! + string
        
        if searchText.count >= 3 {
            tableView.isHidden = false
            
            tableFilterData = emp.filter({ (result) -> Bool in
                return result.name!.range(of: searchText, options: .caseInsensitive) != nil
            })
            
        }
        else{
            tableFilterData = []
        }
        
        return true
    }
    
}

