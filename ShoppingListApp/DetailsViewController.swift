//
//  DetailsViewController.swift
//  ShoppingListApp
//
//  Created by Nalan Duman on 18.12.2021.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var productNameLabel: UITextField!
    @IBOutlet weak var productPriceLabel: UITextField!
    @IBOutlet weak var productSizeLabel: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedProductName = ""
    var selectedProductId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedProductName != "" {
            // Core Data seçilen ürün bilgilerini göster
            saveButton.isHidden = true
            
            if let uuidString = selectedProductId?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let name = result.value(forKey: "name") as? String {
                                productNameLabel.text = name
                            }
                            
                            if let price = result.value(forKey: "price") as? Int {
                                productPriceLabel.text = String(price)
                            }
                            
                            if let size = result.value(forKey: "size") as? String {
                                productSizeLabel.text = size
                            }
                            
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                    }
                } catch {
                    print("hata var")
                }
            }
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            productNameLabel.text = ""
            productPriceLabel.text = ""
            productSizeLabel.text = ""
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
     
        shopping.setValue(productNameLabel.text!, forKey: "name")
        shopping.setValue(productSizeLabel.text!, forKey: "size")
        
        if let price = Int(productPriceLabel.text!) {
            shopping.setValue(price, forKey: "price")
        }
        
        // universal unique id
        shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        shopping.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("kayıt edildi")
        } catch {
            print("hata var")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
