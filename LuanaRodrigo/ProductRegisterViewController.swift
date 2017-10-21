//
//  ProductRegisterViewController.swift
//  LuanaRodrigo
//
//  Created by Rodrigo Luiz Cocate on 12/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit
import CoreData

class ProductRegisterViewController: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivProductImage: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var swCard: UISwitch!
    @IBOutlet weak var btSave: UIButton!
    
    var product: Product!
    var statePicker: [State] = []
    
    var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getPickerStates ()
        
        if product != nil {
            tfName.text = product.name!
            if let states = product.states { tfState.text = states.name }
            print(tfState.text ?? "nada")
            tfValue.text = "\(product.value)"
            swCard.isOn = product.cardPayment
            if let image = product.image as? UIImage {
                ivProductImage.image = image
            }
            
            btSave.setTitle("ATUALIZAR", for: .normal)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProductRegisterViewController.tappedMe))
        ivProductImage.addGestureRecognizer(tap)
    }
    
    @objc func cancel() {
        tfState.resignFirstResponder()
    }
    
    @objc func done() {
        tfState.text = statePicker[pickerView.selectedRow(inComponent: 0)].name
        
        //Agora, gravamos esta escolha no UserDefaults
        //UserDefaults.standard.set(tfState.text!, forKey: "state")
        cancel()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if product != nil {
            if let states = product.states {
                tfState.text = states.name!
                
            }
        }
        //tfState.text = UserDefaults.standard.string(forKey: "state")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if product == nil {
            product = Product(context: context)
        }
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
    
    func close(_ sender: UIButton?) {
        if product != nil && product.name == nil {
            context.delete(product)
        }
        dismiss(animated: true, completion: nil)
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
            return
        }
        
        if product == nil {
            product = Product(context: context)
        }
        
        product.name = tfName.text
        product.states = statePicker[pickerView.selectedRow(inComponent: 0)]
        product.cardPayment = swCard.isOn
        product.value = Double(tfValue.text!)!
        if ivProductImage != nil {
            product.image = ivProductImage.image
        }
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

        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tappedMe()
    {
        let alert = UIAlertController(title: "Selecionar produto", message: "De onde você quer escolher o produto?", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default, handler: { (actions) in
            self.selectPicture(sourceType: .photoLibrary)
        })
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default, handler: { (actions) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        })
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func getPickerStates () {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "State")
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            statePicker = try managedContext.fetch(fetchRequest) as! [State]
        } catch {
            print("Fetching State Failed")
        }
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfState.inputView = pickerView
        tfState.inputAccessoryView = toolbar
    }

}

extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        ivProductImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
}

extension ProductRegisterViewController: UIPickerViewDelegate {
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let states = statePicker[row]
        return states.name
    }

}

extension ProductRegisterViewController: UIPickerViewDataSource {
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    //Usaremos apenas 1 coluna (component) em nosso pickerView
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statePicker.count //O total de linhas será o total de itens em nosso dataSource
    }
}

