//
//  DBController.swift
//  Broadkazt
//
//  Created by Rajamohan S, Independent Software Developer on 19/12/18.
//  Copyright (c) 2018 Rajamohan S. All rights reserved.
//
//	See https://rajamohan-s.github.io/ for author information.
//
 


import CoreData

public struct History{
    
    let date:Date
    let code:String
    let dateString:String
    let title:String
    var image:String?
    
    init(code:String,dateString:String,date:Date,title:String,image:String?) {
        
        self.date  = date
        self.code = code
        self.dateString = dateString
        self.title = title
        self.image = image
    }
    
}


public final class DBController{
    
    public static let shared  = DBController()
    
    private static let history = "HistoryBase"
    
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "db")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    public var context:NSManagedObjectContext!{
        
        if #available(iOS 10.0, *) {
            return persistentContainer.viewContext
        } else {
            return nil
        }
    }
    
    public func saveContext () {
        
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    public class func addHistory(with code:String,title:String,image:String?){
        
        self.removeHistory(with: code)
        
        let newData = NSEntityDescription.insertNewObject(forEntityName: self.history, into: DBController.shared.context)
        newData.setValue(code, forKey: "code")
        newData.setValue(Date(), forKey: "date")
        newData.setValue(title, forKey: "title")
        newData.setValue(image, forKey: "image")
        do{
            try DBController.shared.context.save()
            
        }catch{
            
            print("Error: ",error)
        }
    
    }
    
    public class func getAllHistory()->[History]{
        
        var histories = [History]()
        let request = NSFetchRequest<NSManagedObject>(entityName: self.history)
        let identifiers = try? DBController.shared.context.fetch(request)
        
        for id in identifiers!{
            
            let code = id.value(forKey: "code") as? String
            let date = id.value(forKey: "date") as? Date
            let title = id.value(forKey: "title") as? String ?? "Unknown"
            let image = id.value(forKey: "image") as? String
            
            if let c = code{
                
                if let d = date{
                    
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let dateString = formatter.string(from: d)
                    
                    let history = History(code: c, dateString: dateString, date: d, title: title,image:image)
                    histories.append(history)
                }
            }
        }
        
        histories.sort { (h1, h2) -> Bool in
            
            return h1.date < h2.date
        }
        
        return histories
    }
    
    public class func removeHistory(with code:String){
        
        let request = NSFetchRequest<NSManagedObject>(entityName: self.history)
        request.predicate = NSPredicate(format: "code = %@", code)
        let identifiers = try? DBController.shared.context.fetch(request)
        
        for idenfier in identifiers!{
            
            DBController.shared.context.delete(idenfier)
        }
        
        do{
            
            try DBController.shared.context.save()
            
            
        }catch{
            print(error)
        }
    }
    
    public class func removeAllHistory(){
        
        let request = NSFetchRequest<NSManagedObject>(entityName: self.history)
        let identifiers = try? DBController.shared.context.fetch(request)
        
        for idenfier in identifiers!{
            
            DBController.shared.context.delete(idenfier)
        }
        do{
            try DBController.shared.context.save()
        }catch{
            print(error)
        }
    }
    
}
