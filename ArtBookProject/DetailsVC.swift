//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Eren Elçi on 25.09.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var nameText: UITextField!
    
    @IBOutlet var artistText: UITextField!
    
    @IBOutlet var yearText: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            saveButton.isHidden = true
            //core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
    
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            
            do {
             let results =  try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year  = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("HATTA")
            }
            
            
            
        } else
        {
            saveButton.isHidden  = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""

        }

        
        
        // Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true // imageview tıklanabilirlik true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
       
    }
    
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // medyayala işimiz bitince yani görseli seçtik bu fonksiyon bir dictinoray döndürüyor
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }

    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        // ezber kod
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegete.persistentContainer.viewContext
        let newPaiting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        
        // Attributes
        newPaiting.setValue(nameText.text!, forKey: "name")
        newPaiting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!) {
            newPaiting.setValue(year, forKey: "year")
        }
        newPaiting.setValue(UUID(), forKey: "id")
        //image data çeviriyoruz
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPaiting.setValue(data, forKey: "image")
        
        
        do {
            try context.save()
            print("BAŞARILI")
        } catch {
            print("BİR HATA VAR")
        }
        
        //NotificationCenter ile viewcontrollara mesaj yollayabiliyoruz
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)

    }
    

}
