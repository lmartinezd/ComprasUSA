//
//  TotalViewController.swift
//  LuanaRodrigo
//
//  Created by Luana on 21/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController {

    @IBOutlet weak var tfTotDolar: UILabel!
    @IBOutlet weak var tfTotReal: UILabel!
    
    var fetchedProductsController: NSFetchedResultsController<Product>!
    var product: [Product] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getProducts()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedProductsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedProductsController.delegate = self
        do {
            try fetchedProductsController.performFetch()
            self.product = fetchedProductsController.fetchedObjects!
            calcular()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func calcular(){
        let cotacaoD = Double(UserDefaults.standard.string(forKey: "dolar") ?? "3.2")!
        let iof = Double(UserDefaults.standard.string(forKey: "iof") ?? "6.38")!
        
        var totDolar: Double = 0.0
        var totReal: Double = 0.0
        var sumReal: Double = 0.0
        
        for product in product {
            // total em dolar
            totDolar += product.value
            
            sumReal = product.value + (product.value * (Double((product.states?.tax)!) / 100))
            
            //total em dolar
            if product.cardPayment {
                sumReal += sumReal * (iof / 100)
                print (" iof : \(sumReal)")
            }
            totReal += sumReal
        }
        totReal = totReal * cotacaoD
        
        tfTotDolar.text = String(format: "%.2f", totDolar)
        tfTotReal.text = String(format: "%.2f", totReal)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


extension TotalViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        product = fetchedProductsController.fetchedObjects!
        calcular()
    }
}
