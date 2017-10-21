//
//  SettingsViewController.swift
//  LuanaRodrigo
//
//  Created by Rodrigo Luiz Cocate on 17/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit
import CoreData

enum EventType {
    case add
    case edit
}

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
        
        tvStates.tableFooterView = UIView()
    }
    
    internal func loadStates() {
        
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
    
    internal func showAlert(type: EventType,  state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        
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
    
    @IBAction func btAddState(_ sender: UIButton) {
        showAlert(type: .add, state: state)
    }
    
    @IBAction func changeDolar(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey: "dolar")
    }
    
    @IBAction func changeIOF(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey: "tax")
    }
}

extension SettingsViewController: UITableViewDelegate {

    internal func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAct = UITableViewRowAction(style: .destructive, title: "Excluir")
        { (action: UITableViewRowAction, indexPath: IndexPath) in
            
            let state = self.states[indexPath.row]
            
            do {
                self.context.delete(state)
                try self.context.save()
                self.states.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        let editAct = UITableViewRowAction(style: .normal, title: "Editar")
        { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.states[indexPath.row]
            tableView.setEditing(false, animated: true)
            self.showAlert(type: .edit, state: state)
        }
        editAct.backgroundColor = .blue
        
        self.tvStates.reloadData()
        return [editAct, deleteAct]
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
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(String(describing: state.tax))"
        cell.detailTextLabel?.textColor = .red
        return cell
    }
}
