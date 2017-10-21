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

    weak var nameAlert: UITextField?
    weak var taxAlert: UITextField?
    weak var enableSave: UIAlertAction?
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        tfDolar.text = UserDefaults.standard.string(forKey: "dolar") ?? "3.2"
        tfIOF.text = UserDefaults.standard.string(forKey: "iof") ?? "6.38"
        
        tvStates.estimatedRowHeight = 50
        tvStates.rowHeight = UITableViewAutomaticDimension
        tvStates.tableFooterView = UIView()
        tvStates.delegate = self
        tvStates.dataSource = self

        loadStates()
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
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
            if let name = state?.name { textField.text = name }
        }
        
        alert.addTextField {(textField: UITextField) in
            textField.placeholder = "valor do imposto"
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
            if let tax = state?.tax { textField.text = "\(tax)" }
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        let btSave = UIAlertAction(
            title: alert.title, style: .default, handler: { (action: UIAlertAction) in
                
                guard
                    let name = alert.textFields?.first?.text,
                    let tax = alert.textFields?.last?.text
                else {
                    return
                }
                let state = state ?? State(context: self.context)
                
                do {
                    state.name = name
                    state.tax = Double(tax)!
                    try self.context.save()
                    self.loadStates()
                } catch {
                    print(error.localizedDescription)
                }
        })
        
        btSave.isEnabled = false
        self.enableSave = btSave
        
        self.nameAlert = alert.textFields?.first
        self.taxAlert = alert.textFields?.last
        
        alert.addAction(btSave)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    internal func textChanged(_ sender: UITextField){
        guard
            let name = nameAlert?.text,
            let tax = taxAlert?.text
            else {
                self.enableSave?.isEnabled = false
                return
        }
        if (name == "")
        {
            self.enableSave?.isEnabled = false
            return
        }
        if name.characters.count == 1 {
            if (name.characters.first == " ") {
                self.enableSave?.isEnabled = false
                return
            }
        }
        if (tax == ""){
            self.enableSave?.isEnabled = false
            return
        }
        if (tax.characters.count == 1) {
            if (tax.characters.first == " ") {
                self.enableSave?.isEnabled = false
                return
            }
        }
        self.enableSave?.isEnabled = true
    }
    
    @objc func textsChanged(name: String, iof: String){
        if (name == "") || (iof == "") {
            return
        }
        self.enableSave?.isEnabled = (name != "") && (iof != "")
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
        UserDefaults.standard.set(sender.text, forKey: "iof")
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
        return [editAct, deleteAct]
    }
}

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
