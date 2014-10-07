//
//  Token.swift
//  Proto1
//
//  Created by Rich Randall on 10/3/14.
//  Copyright (c) 2014 Rich Randall. All rights reserved.
//

import Foundation

private var _tokenSingleton : Token? = nil

class Token {
    let resource = "00000002-0000-0000-c000-000000000000"
    let clientId = "e958c09a-ac37-4900-b4d7-fb3eeaf7338d"
    let startingAuthority = "https://login.windows.net/common"
    let redirectUrl = NSURL(string: "http://foobar.com")

    class var instance : Token {
        if nil != _tokenSingleton {
            return _tokenSingleton!
        }

        _tokenSingleton = Token()
        return _tokenSingleton!
    }

    var tenant : String?
    var user : String?

    private var authCtx : ADAuthenticationContext? = nil


    private init() {
        var error : ADAuthenticationError?
        self.authCtx = ADAuthenticationContext(authority: startingAuthority, error: &error)
        if nil != error {
            NSLog("Unable to create AuthContext: \(error?.description)")
        }
    }

    func getToken(closure: (Bool, String?) -> ()) {
        self.authCtx!.acquireTokenWithResource(resource, clientId: clientId, redirectUri: redirectUrl,
            completionBlock:
            {(result : ADAuthenticationResult!) -> () in
                var status : ADAuthenticationResultStatus = result.status

                NSLog("GetToken Result: \(status.value)")

                var success = false
                var token : String? = nil
                if (AD_SUCCEEDED.value == status.value) {
                    success = true
                    token = result.accessToken

                    self.user = result.tokenCacheStoreItem.userInformation.userId
                    self.tenant = result.tokenCacheStoreItem.userInformation.tenantId

                    NSLog("token: \(token!)")
                }

                closure(success, token)
            })
    }
}