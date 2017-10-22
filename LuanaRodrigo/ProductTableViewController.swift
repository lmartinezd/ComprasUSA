//
//  ProductTableViewController.swift
//  LuanaRodrigo
//
//  Created by Rodrigo Luiz Cocate on 12/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit
import CoreData

class ProductTableViewController: UITableViewController {
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        label.text = "Não há produtos cadastrados!"
        label.textAlignment = .center
        label.textColor = .black
        
        loadProducts()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ProductRegisterViewController {
            if (tableView.indexPathForSelectedRow != nil){
                vc.product = fetchedResultController.object(at: tableView.indexPathForSelectedRow!)
            }
        }
    }
    
    internal func loadProducts() {
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let product = fetchedResultController.object(at: indexPath)

        if product.objectID.isTemporaryID {
            context.delete(product)
            return cell
        }
        
        cell.lbName.text = product.name!
        cell.lbState.text = product.states?.name
        cell.lbValue.text = "\(product.value)"
        
        if let image = product.image as? UIImage {
            cell.ivProductPhoto.image = image
        } else {
            cell.ivProductPhoto.image = nil
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = fetchedResultController.object(at: indexPath)
            context.delete(product)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension ProductTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}

