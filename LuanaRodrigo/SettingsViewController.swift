//
//  SettingsViewController.swift
//  LuanaRodrigo
//
//  Created by Rodrigo Luiz Cocate on 17/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tvStates: UITableView!
    @IBOutlet weak var tfDolar: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    
    var states: [State] = []
    var product: Product!
    var state: State!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tvStates.delegate = self
        tvStates.dataSource = self
        
        tfDolar.text = UserDefaults.standard.string(forKey: "dolar")
        tfIOF.text = UserDefaults.standard.string(forKey: "tax")
        
        loadStates()
    }
    
    func loadStates() {
        
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            states = try context.fetch(fetchRequest)
            tvStates.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let state = fetchedResultController.object(at: indexPath)
//            context.delete(movie)
//            do {
//                try context.save()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let state = fetchRequest.object(at: indexPath)
//            context.delete(state)
//            do {
//                try context.save()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
    func showAlert(state: State?) {
        
        let alert = UIAlertController(title: "Adicionar Estado", message: nil, preferredStyle: .alert)
        
        alert.addTextField {(textField: UITextField) in
            textField.placeholder = "nome do estado"
            if let name = state?.name { textField.text = name }
        }
        
        alert.addTextField {(textField: UITextField) in
            textField.placeholder = "valor do imposto"
            if let tax = state?.tax { textField.text = "\(tax)" }
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(
            title: alert.title, style: .default, handler: { (action: UIAlertAction) in
                
                let state = state ?? State(context: self.context)
                
                state.name = alert.textFields?.first?.text
                state.tax = Double((alert.textFields?.last?.text)!)!
                
                do {
                    try self.context.save()
                    self.loadStates()
                } catch {
                    print(error.localizedDescription)
                }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func btAddState(_ sender: UIButton) {
        showAlert(state: state)
    }
    
    @IBAction func changeDolar(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey: "dolar")
    }
    
    @IBAction func changeIOF(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey: "tax")
    }
}

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let state = states[indexPath.row]
        let cell = tvStates.cellForRow(at: indexPath)!
        //
        //            if cell.accessoryType == .none {
        //                cell.accessoryType = .checkmark
        //                movie.addToCategories(state)
        //            } else {
        //                cell.accessoryType = .none
        //                movie.removeFromCategories(category)
        //            }
        tvStates.deselectRow(at: indexPath, animated: false)
        
    }

    private func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> UITableViewRowAction? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir")
        { (action: UITableViewRowAction, indexPath: IndexPath) in
            
            let state = self.states[indexPath.row]
            
            self.context.delete(state)
            
            do {
                
                try self.context.save()
                self.states.remove(at: indexPath.row)
                self.tvStates.deleteRows(at: [indexPath], with: .fade)
                self.tvStates.reloadData()
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        //        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (action: UITableViewRowAction, indexPath: IndexPath) in
        //            let category = self.states[indexPath.row]
        //            tableView.setEditing(false, animated: true)
        //            self.showAlert(type: .edit, category: category)
        //        }
        //        editAction.backgroundColor = .blue
        //        return [editAction, deleteAction]
        return deleteAction
    }
}


// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let state = states[indexPath.row]
        print(state.name!)
        print("\(String(describing: state.tax))")
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(String(describing: state.tax))"
        cell.detailTextLabel?.textColor = .red
        return cell
    }
}
