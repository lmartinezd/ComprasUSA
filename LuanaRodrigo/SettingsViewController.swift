//
//  SettingsViewController.swift
//  LuanaRodrigo
//
//  Created by Rodrigo Luiz Cocate on 17/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let alertCtrl = UIAlertController(
            title: "Ajuste",
            message: "Carregando a tela de ajustes!",
            preferredStyle: .alert)
        alertCtrl.addAction(
            UIAlertAction(
                title: "OK",
                style: .default, handler: nil))
        
        self.present(alertCtrl, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
