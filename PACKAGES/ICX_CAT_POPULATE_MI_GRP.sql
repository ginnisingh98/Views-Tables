--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_MI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_MI_GRP" AUTHID CURRENT_USER AS
/* $Header: ICXGPPMS.pls 120.1 2005/11/09 10:40:12 sbgeorge noship $*/

-- Start of comments
--      API name        : populateItemChange
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of creating, updating and deleting the inventory
--                        item in ip datamodel.  This procedure is called by Inventory on
--                        item creation, updation, deletion, item assignment to an
--                        inventory org and item translation updation in mtl_system_items_b
--                        and mtl_system_items_tl from forms, html interface.
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_dml_type                      IN VARCHAR2     Required
--                                      Corresponds to the dml action done to the
--                                      item.  The allowed values are
--                                      "CREATE/UPDATE/DELETE"
--                              p_inventory_item_id             IN NUMBER       Required
--                                      Corresponds to the column INVENTORY_ITEM_ID in
--                                      the table MTL_SYSTEM_ITEMS, and identifies the
--                                      record to be inserted, updated or deleted.
--                              p_item_number                   IN VARCHAR2     Required
--                                      Corresponds to the column CONCATENATED_SEGMENTS in
--                                      the table MTL_SYSTEM_ITEMS_KFV.
--                              p_organization_id               IN NUMBER       Required
--                                      Item organization id. Part of the unique key
--                                      that uniquely identifies an item record.
--                              p_organization_code             IN VARCHAR2     Required
--                                      Item organization code.
--                              p_master_org_flag               IN VARCHAR2     Required
--                                      Flag value: Y/N, and identifies if the organization
--                                      is the master org.  If Y then the processing is also
--                                      for all the child orgs.
--                              p_item_description              IN VARCHAR2     Required
--                                      Corresponds to the column DESCRIPTION in
--                                      the table MTL_SYSTEM_ITEMS_TL.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE populateItemChange
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_dml_type              IN              VARCHAR2                                ,
        p_inventory_item_id     IN              NUMBER                                  ,
        p_item_number           IN              VARCHAR2                                ,
        p_organization_id       IN              NUMBER                                  ,
        p_organization_code     IN              VARCHAR2                                ,
        p_master_org_flag       IN              VARCHAR2                                ,
        p_item_description      IN              VARCHAR2
);

-- Start of comments
--      API name        : populateBulkItemChange
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of creating and updating the inventory
--                        item in ip datamodel.  This procedure is called by Inventory on
--                        item creation, updation, item assignment to an
--                        inventory org and item translation updation in mtl_system_items_b
--                        and mtl_system_items_tl from Item open interface (IOI).  The
--                        procedure is also called when an items category assignment is
--                        created, updated or deleted from IOI.
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_request_id                    IN NUMBER       Required
--                                      Corresponds to the column REQUEST_ID in
--                                      the table MTL_ITEM_BULKLOAD_RECS, and identifies the
--                                      set of items that are inserted, updated or deleted
--                                      in the current IOI job.
--                              p_entity_type                   IN VARCHAR2     Required
--                                      Corresponds to the entity changed
--                                      The allowed values are "ITEM/ITEM_CATEGORY"
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE populateBulkItemChange
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_request_id            IN              NUMBER                                  ,
        p_entity_type           IN              VARCHAR2
);

-- Start of comments
--      API name        : populateItemCategoryChange
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of creating, updating and deleting the inventory
--                        item category assignment in ip datamodel if the category belong
--                        to the purchasing category set.  This procedure is called by
--                        Inventory when category assignment of an item is created,
--                        updated or deleted in MTL_ITEM_CATEGORIES from forms,
--                        and html interface.
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_dml_type                      IN VARCHAR2     Required
--                                      Corresponds to the dml action done to the
--                                      item's category.  The allowed values are
--                                      "CREATE/UPDATE/DELETE"
--                              p_inventory_item_id             IN NUMBER       Required
--                                      Corresponds to the column INVENTORY_ITEM_ID in
--                                      the table MTL_SYSTEM_ITEMS, and identifies the
--                                      item whose category assignment change is done.
--                              p_item_number                   IN VARCHAR2     Required
--                                      Corresponds to the column CONCATENATED_SEGMENTS in
--                                      the table MTL_SYSTEM_ITEMS_KFV.
--                              p_organization_id               IN NUMBER       Required
--                                      Item organization id. Part of the unique key
--                                      that uniquely identifies an item record.
--                              p_master_org_flag               IN VARCHAR2     Required
--                                      Flag value: Y/N, and identifies if the organization
--                                      is the master org.  If Y then the processing is also
--                                      for all the child orgs.
--                              p_category_set_id               IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_SET_ID in
--                                      the table MTL_ITEM_CATEGORIES.  Part of the unique
--                                      key that uniquely identifies a record.
--                              p_category_id                   IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_ID in
--                                      the table MTL_ITEM_CATEGORIES.  Part of the unique
--                                      key that uniquely identifies a record.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE populateItemCategoryChange
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_dml_type              IN              VARCHAR2                                ,
        p_inventory_item_id     IN              NUMBER                                  ,
        p_item_number           IN              VARCHAR2                                ,
        p_organization_id       IN              NUMBER                                  ,
        p_master_org_flag       IN              VARCHAR2                                ,
        p_category_set_id       IN              NUMBER                                  ,
        p_category_id           IN              NUMBER
);

END ICX_CAT_POPULATE_MI_GRP;

 

/
