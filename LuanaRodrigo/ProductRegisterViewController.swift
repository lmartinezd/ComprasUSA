//
//  ProductRegisterViewController.swift
//  LuanaRodrigo
//
//  Created by Rodrigo Luiz Cocate on 12/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit

class ProductRegisterViewController: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var btProductPhoto: UIButton!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var swCard: UISwitch!
    @IBOutlet weak var btSave: UIButton!
    
    var product: Product!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if product != nil {
            tfName.text = product.name!
            if let image = product.image as? UIImage {
                btProductPhoto.setImage(image, for: .normal)
            }
            if let states = product.states { tfState.text = states.name }
            tfValue.text = "(product.value)"
            swCard.isOn = product.cardPayment
            btSave.setTitle("ATUALIZAR", for: .normal)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if product != nil {
            if let states = product.states {
                tfState.text = states.name!
            }
        }
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if product == nil {
            product = Product(context: context)
        }
        
        //let vc = segue.destination as! StateViewController
        //vc.product = product
    }
    
    func selectPhoto(sourceType: UIImagePickerControllerSourceType) {
        

        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self as! (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        present(imagePicker, animated: true, completion: nil)
    }

    
    @IBAction func selectImage(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Selecionar poster",
                                      message: "Onde quer selecionar a foto?",
                                      preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Biblioteca de fotos",
                                             style: .default,
                                             handler: { (action: UIAlertAction) in
                                                        self.selectPhoto(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) {
            (action: UIAlertAction) in self.selectPhoto(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) {
            (action: UIAlertAction) in self.selectPhoto(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)

    }
    
    func isValidData() -> (valid: Bool, fieldName: String) {

        if tfName.text == "" {
            return (false, "nome")
        }
        if tfState.text == "" {
            return (false, "estado da compra")
        }
        if tfValue.text == "" {
            return (false, "valor da compra")
        }
        return (true, "")
    }
    
    
    @IBAction func btSave(_ sender: UIButton) {

        let checkData = isValidData()
        
        if !checkData.0 {
            let alertCtrl = UIAlertController(
                title: "Salvar",
                message: "Favor informar " + checkData.1 + " do produto.",
                preferredStyle: .alert)
            alertCtrl.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default, handler: nil))
            
            self.present(alertCtrl, animated: true, completion: nil)
        }
        
        if product == nil {
            product = Product(context: context)
        }
        
        product.name = tfName.text
        product.value = Double(tfValue.text!)!
        
        do {
            try context.save()
        } catch  {
            let alertCtrl = UIAlertController(
                title: "Erro",
                message: "Erro ao salvar produto: " + error.localizedDescription,
                preferredStyle: .alert)
            alertCtrl.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default, handler: nil))
            
            self.present(alertCtrl, animated: true, completion: nil)
            
        }
    }
}
