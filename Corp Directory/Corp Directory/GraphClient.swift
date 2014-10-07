//
//  GraphClient.swift
//  Proto1
//
//  Created by Rich Randall on 10/4/14.
//  Copyright (c) 2014 Rich Randall. All rights reserved.
//

import Foundation

private var _graphClient : GraphClient?

class GraphClient {

    let graphHost = "https://graph.windows.net"
    let tenant : String
    let apiVersionParameter = "api-version"
    let apiVersion = "2013-11-08"

    class func setSharedGraphClient(graphClient: GraphClient) {
        _graphClient = graphClient
    }

    class func sharedGraphClient() -> GraphClient? {
        return _graphClient
    }

    init() {
        self.tenant = Token.instance.tenant!
        var requestFactory = RequestFactory.sharedRequestFactory()
        if nil == requestFactory {
            requestFactory = RequestFactory(baseUrl: self.graphHost)
            RequestFactory.setSharedRequestFactory(requestFactory!)
        }
    }

    func fetchUsers() {
        RequestFactory.sharedRequestFactory()?.fetchObjectsAtUrl("/\(self.tenant)/users", parameters: [ apiVersionParameter : apiVersion, "$filter" : "startswith(displayName,'Rich Randall')"])
    }

    func getFetchedResultsController() -> NSFetchedResultsController {
        return RequestFactory.sharedRequestFactory()!.getFetchedResultsControllerForType(AADUser.self as NSObject.Type)
    }

    func getThumbnail(imageView: UIImageView, objectId: String, completionBlock: () -> ()) {
        Token.instance.getToken({(success: Bool, token: String?) in
            var urlString : String = "https://graph.windows.net/\(Token.instance.tenant!)/users/\(objectId)/thumbnailPhoto?api-version=2013-11-08"
            var url : NSURL? = NSURL(string: urlString)
            if nil == url {
                NSLog("url is nil!")
            }

            var manager: SDWebImageManager = SDWebImageManager.sharedManager()
            manager.imageDownloader.setValue(token!, forHTTPHeaderField:"Authorization")

            var block : SDWebImageCompletionBlock = {(image: UIImage?, error: NSError?, cacheType: SDImageCacheType, imageUrl: NSURL?) in
                NSLog("Image download complete: \(error?)")
            }

            imageView.sd_setImageWithURL(url)
        })
    }
}