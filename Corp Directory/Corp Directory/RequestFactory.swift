//
//  RequestFactory.swift
//  Proto1
//
//  Created by Rich Randall on 10/3/14.
//  Copyright (c) 2014 Rich Randall. All rights reserved.
//

import Foundation

private var _requestFactory : RequestFactory?

class RequestFactory {

    class func sharedRequestFactory() -> RequestFactory? {
        return _requestFactory
    }

    class func setSharedRequestFactory(requestFactory: RequestFactory) {
        _requestFactory = requestFactory
    }

    private func createRequest(url: String, completionBlock: (NSURLRequest?)->()) {
        Token.instance.getToken({(success, token) in
            if !success {
                NSLog("Failed to acquire token")
                completionBlock(nil)
                return
            }

            NSLog("Creating request for: \(url)")
            let urlObject = NSURL(string: url)

            let request = NSMutableURLRequest(URL: urlObject)
            completionBlock(request)
        })
    }

    var managedObjectStore: RKManagedObjectStore?
    private var baseUrl: String

    init(baseUrl: String) {
        self.baseUrl = baseUrl

        setupRestKit()
        AADUser.setupObjectMapping(self.managedObjectStore!)
    }

    private func setupNSManagedObjectModel() -> NSManagedObjectModel {
        var bundle = NSBundle.mainBundle()
        var resourcePath = bundle.pathForResource("Corp_Directory", ofType: "momd")!

        var modelURL = NSURL.fileURLWithPath(resourcePath)!

        var managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL).mutableCopy() as NSManagedObjectModel
        var entities = managedObjectModel.entitiesByName
        var userEntity = entities["AADUser"] as NSEntityDescription
        var className = NSStringFromClass(AADUser)
        userEntity.managedObjectClassName = className

        return managedObjectModel
    }

    private func setupObjectManager() {
        var route = RestKitBridge.createRouteWithType(AADUser.self as NSObject.Type, pathPattern: "/:tenant/users", method: RKRequestMethod.GET)

        var objectManager = RKObjectManager(baseURL: NSURL(string: "https://graph.windows.net"))
        RKObjectManager.setSharedManager(objectManager)
        objectManager.router.routeSet.addRoute(route)
        objectManager.managedObjectStore = self.managedObjectStore
    }

    private func setupRestKit() {
        var error : NSError?

        var managedObjectModel = self.setupNSManagedObjectModel()

        self.managedObjectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel)
        self.managedObjectStore?.createPersistentStoreCoordinator()
        self.managedObjectStore?.addInMemoryPersistentStore(&error)

        self.managedObjectStore?.createManagedObjectContexts()
        self.managedObjectStore?.managedObjectCache = RKInMemoryManagedObjectCache(managedObjectContext: self.managedObjectStore?.mainQueueManagedObjectContext)
        RKManagedObjectStore.setDefaultStore(managedObjectStore)

        setupObjectManager()

    }

    func fetchObjectsAtUrl(path: String, parameters: Dictionary<String,String>) {
        var request : NSMutableURLRequest = RKObjectManager.sharedManager().requestWithObject(AADUser.self, method: RKRequestMethod.GET, path: path, parameters: parameters)

        Token.instance.getToken({(success: Bool, token: String?) in
            request.setValue(token!, forHTTPHeaderField: "Authorization")
            var operation = RKObjectManager.sharedManager().managedObjectRequestOperationWithRequest(
                request,
                managedObjectContext: self.managedObjectStore!.mainQueueManagedObjectContext,
                success: {(op: RKObjectRequestOperation?, result: RKMappingResult?) in },
                failure: {(op: RKObjectRequestOperation?, error: NSError?) in })

            NSOperationQueue.currentQueue()?.addOperation(operation)
        })
    }

    func getFetchedResultsControllerForType(type: NSObject.Type) -> NSFetchedResultsController {
        var typeName = NSStringFromClass(type)
        var entityName = typeName.componentsSeparatedByString(".")[1]

        var managedObjectContext = self.managedObjectStore!.mainQueueManagedObjectContext

        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity

        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20

        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "displayName", ascending: false)
        let sortDescriptors = [sortDescriptor]

        fetchRequest.sortDescriptors = [sortDescriptor]

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")

        return fetchedResultsController
    }

    func getThumbnail(imageView: UIImageView, objectId: String, parameters: Dictionary<String, String>, completionBlock: () -> ()) {
        Token.instance.getToken({(success: Bool, token: String?) in

            var url = NSURL(string: "https://graph.windows.net/\(Token.instance.tenant)/users/\(objectId)/thumbnailPhoto")
            var request = NSMutableURLRequest(URL: url)
            request.setValue(token!, forHTTPHeaderField: "Authorization")

            imageView.setImageWithURLRequest(
                request,
                placeholderImage: nil,
                success: {(urlRequest: NSURLRequest?, urlResponse: NSHTTPURLResponse?, image: UIImage?) in
                    NSLog("image download success")
                },
                failure: {(urlRequest: NSURLRequest?, urlResponse: NSHTTPURLResponse?, error: NSError?) in
                    NSLog("image download failure")
                }
            )
        })
    }
}