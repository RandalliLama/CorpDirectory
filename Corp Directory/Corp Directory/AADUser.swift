//
//  AADUser.swift
//  Proto1
//
//  Created by Rich Randall on 10/3/14.
//  Copyright (c) 2014 Rich Randall. All rights reserved.
//

private let displayableAttributes = [
    "jobTitle"      : "Title",
    "department"    : "Department",
    "office"        : "Office",
    "mobileNumber"  : "Mobile",
    "email"         : "Email",
    "alias"         : "Alias",
    "city"          : "City",
    "country"       : "Country",
    "state"         : "State",
    "streetAddress" : "Address",
    "phone"         : "Phone",
    "upn"           : "UPN",
]

class AADUser: NSManagedObject {
    @NSManaged var alias: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var department: String?
    @NSManaged var displayName: String?
    @NSManaged var email: String?
    @NSManaged var givenName: String?
    @NSManaged var jobTitle: String?
    @NSManaged var mobileNumber: String?
    @NSManaged var objectId: String?
    @NSManaged var office: String?
    @NSManaged var phone: String?
    @NSManaged var state: String?
    @NSManaged var streetAddress: String?
    @NSManaged var surname: String?
    @NSManaged var tenant: String?
    @NSManaged var upn: String?

    @NSManaged var profilePic: NSData?

    class func getObjectMapping() -> Dictionary<String, String> {
        let mappingDictionary = [
            "objectId"                      : "objectId",
            "city"                          : "city",
            "country"                       : "country",
            "department"                    : "department",
            "displayName"                   : "displayName",
            "givenName"                     : "givenName",
            "jobTitle"                      : "jobTitle",
            "mail"                          : "email",
            "mailNickname"                  : "alias",
            "mobile"                        : "mobileNumber",
            "physicalDeliveryOfficeName"    : "office",
            "state"                         : "state",
            "streetAddress"                 : "streetAddress",
            "surname"                       : "surname",
            "telephoneNumber"               : "phone",
            "userPrincipalName"             : "upn",
            "tenant"                        : "tenant"
        ]
        return mappingDictionary
    }

    class func getResponseDescriptor(store : RKManagedObjectStore) -> RKResponseDescriptor {
        let mappingDictionary = AADUser.getObjectMapping()

        var userMapping = RKEntityMapping(forEntityForName: "AADUser", inManagedObjectStore: store)
        userMapping.identificationAttributes = ["objectId"]
        userMapping.addAttributeMappingsFromDictionary(mappingDictionary)

        var statusCodes = RKStatusCodeIndexSetForClass(UInt(RKStatusCodeClassSuccessful))

        return RKResponseDescriptor(mapping: userMapping, pathPattern: "/:tenant/users", keyPath: "value", statusCodes: statusCodes)
    }

    class func setupObjectMapping(store : RKManagedObjectStore) {
        var objectManager = RKObjectManager.sharedManager()
        objectManager.addResponseDescriptor(AADUser.getResponseDescriptor(store))
    }

    func getDisplayAttributes() -> Dictionary<String, String> {
        var attributes = Dictionary<String, String>()

        for key in displayableAttributes.keys {
            var value = self.valueForKey(key) as String?
            if (value != nil) {
                var displayKey = displayableAttributes[key]!
                attributes[displayKey] = value
            }
        }

        return attributes
    }

    func setImage(imageView : UIImageView) {
        GraphClient.sharedGraphClient()?.getThumbnail(imageView, objectId: self.objectId!, completionBlock: {})
    }
}

