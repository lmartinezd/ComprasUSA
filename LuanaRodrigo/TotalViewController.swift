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
    
    var products: [Product] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tfTotDolar.text = "0.0"
        tfTotReal.text = "0.0"
        getProducts()
        if products.count > 0 {
            calcular()
        }
    }

    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func getProducts() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            self.products = try managedContext.fetch(fetchRequest) as! [Product]
        } catch {
            print(error.localizedDescription)
        }
    }
    
    internal func calcular(){
        let cotacaoD = Double(UserDefaults.standard.string(forKey: "dolar") ?? "3.2")!
        let iof = Double(UserDefaults.standard.string(forKey: "iof") ?? "6.38")!
        
        var totDolar: Double = 0.0
        var totDolarPlusTax: Double = 0.0
        var iofProd: Double = 0.0
        var taxProd: Double = 0.0
        var totReal: Double = 0.0
        
        for product in products {

            // total em dolar a exibir.
            totDolar += product.value
            
            // calcula taxa do estado para o produto
            taxProd = (product.value * (Double((product.states?.tax)!) / 100))
            
            // verifica se é cartão para acrescentar taxa IOF.
            if product.cardPayment {
                iofProd = (product.value * (iof / 100))
            }
            
            // faz a soma do valor do produto + taxas.
            totDolarPlusTax += (product.value + taxProd + iofProd)

            // resseta variaveis de IOF e Tax para calculo do próximo produto
            iofProd = 0.0
            taxProd = 0.0
        }

        // calcula total em reais (valor de todos os produtos e respectivas taxas * cotação do dólar).
        totReal = totDolarPlusTax * cotacaoD

        // formata totais com duas casas decimais.
        tfTotDolar.text = String(format: "%.2f", totDolar)
        tfTotReal.text = String(format: "%.2f", totReal)
    }
}

