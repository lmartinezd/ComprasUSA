//
//  UIViewController+CoreData.swift
//  LuanaRodrigo
//
//  Created by Rodrigo Luiz Cocate on 12/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var appDelegate: AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext{
        return appDelegate.persistentContainer.viewContext
    }
}
