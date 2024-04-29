--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_ITEM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_ITEM_GRP" AUTHID CURRENT_USER AS
/* $Header: ICXGPPIS.pls 120.1 2005/10/19 10:54:37 sbgeorge noship $*/

-- Start of comments
--      API name        : populateVendorNameChanges
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of re-populating the vendor name changes in
--                        intermedia index for ip catalog search.  This procedure is
--                        called by purchasing when a vendor name is changed in
--                        PO_VENDORS
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_vendor_id                     IN NUMBER       Required
--                                      Corresponds to the column VENDOR_ID in
--                                      the table PO_VENDORS, and identifies the
--                                      vendor whose name has changed.
--                              p_vendor_name                   IN VARCHAR2     Required
--                                      Corresponds to the column VENDOR_NAME in
--                                      the table PO_VENDORS.  This is the changed
--                                      vendor name.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE populateVendorNameChanges
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_vendor_id             IN              NUMBER                                  ,
        p_vendor_name           IN              VARCHAR2
);

-- Start of comments
--      API name        : populateVendorMerge
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of re-populating the vendor merge changes in
--                        intermedia index for ip catalog search.  This procedure is
--                        called by purchasing when a vendors are merged.
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_from_vendor_id                IN NUMBER       Required
--                                      Corresponds to the VENDOR_ID of the vendor that has
--                                      been merged
--                              p_from_site_id                  IN NUMBER       Required
--                                      Corresponds to the VENDOR_SITE_ID of the vendor
--                                      that has been merged
--                              p_to_vendor_id                  IN NUMBER       Required
--                                      Corresponds to the VENDOR_ID of the vendor that has
--                                      been merged to
--                              p_to_site_id                    IN NUMBER       Required
--                                      Corresponds to the VENDOR_SITE_ID of the vendor
--                                      that has been merged to
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE populateVendorMerge
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_from_vendor_id        IN              NUMBER                                  ,
        p_from_site_id          IN              NUMBER                                  ,
        p_to_vendor_id          IN              NUMBER                                  ,
        p_to_site_id            IN              NUMBER
);

-- Start of comments
--      API name        : rebuildIPIntermediaIndex
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of re-building the intermedia index for ip catalog search.
--                        This procedure is called by Inventory, iSP and Purchasing teams
--                        in addition to the main ip APIs, if the main APIs are called
--                        with p_commit = false.  This API will be called after teh commit is done
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_TRUE
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE rebuildIPIntermediaIndex
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_TRUE              ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2
);

END ICX_CAT_POPULATE_ITEM_GRP;

 

/
