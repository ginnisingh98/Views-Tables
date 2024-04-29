--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_CATG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_CATG_GRP" AUTHID CURRENT_USER AS
/* $Header: ICXGPPCS.pls 120.1 2005/11/09 10:39:57 sbgeorge noship $*/

-- Start of comments
--      API name        : populateCategoryChange
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of creating and updating the category in ip datamodel
--                        if the category belongs to purchasing category set.  This
--                        procedure is called by Inventory on category creation, updation
--                        and category translation updation in mtl_categories_b
--                        and mtl_categories_tl from forms / html interface
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
--                                      category.  The allowed values
--                                      are "CREATE/UPDATE/DELETE"
--                              p_structure_id                  IN NUMBER       Required
--                                      Corresponds to the column STRUCTURE_ID in
--                                      the table MTL_CATEGORIES_B, and identifies the
--                                      structure_id of the category.
--                              p_category_name                 IN VARCHAR2     Required
--                                      Corresponds to the column CONCATENATED_SEGMENTS in
--                                      the table MTL_CATEGORIES_KFV.
--                              p_category_id                   IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_ID in
--                                      the table MTL_CATEGORIES_B, and identifies the
--                                      category.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : 1. As per the inventory team, deleting a category is not allowed
--                           from category forms / html interface.
--                        2. No bulk operations (i.e loading data from an interface table)
--                           are allowed on category
--
-- End of comments
PROCEDURE populateCategoryChange
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_dml_type              IN              VARCHAR2                                ,
        p_structure_id          IN              NUMBER                                  ,
        p_category_name         IN              VARCHAR2                                ,
        p_category_id           IN              NUMBER
);

-- Start of comments
--      API name        : populateValidCategorySetInsert
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of creating the category in ip datamodel
--                        if the category belongs to purchasing category set.  This
--                        procedure is called by Inventory when a category is added to the
--                        valid category set (MTL_CATEGORY_SET_VALID_CATS)
--                        from forms / html interface.
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_category_set_id               IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_SET_ID in
--                                      the table MTL_CATEGORY_SET_VALID_CATS, and
--                                      identifies the category_set_id of the category.
--                              p_category_id                   IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_ID in
--                                      the table MTL_CATEGORIES_B, and identifies the
--                                      category.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : 1. As per the inventory team, No bulk operations
--                           (i.e loading data from an interface table)
--                           are allowed on valid cat sets.
--
-- End of comments
PROCEDURE populateValidCategorySetInsert
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_category_set_id       IN              NUMBER                                  ,
        p_category_id           IN              NUMBER
);

-- Start of comments
--      API name        : populateValidCategorySetUpdate
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of deleting and creating the category in ip datamodel
--                        if the category belongs to purchasing category set.  This
--                        procedure is called by Inventory when a category is updated to a
--                        new category in valid category set (MTL_CATEGORY_SET_VALID_CATS)
--                        from forms / html interface.
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_category_set_id               IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_SET_ID in
--                                      the table MTL_CATEGORY_SET_VALID_CATS, and
--                                      identifies the category_set_id of the category.
--                              p_old_category_id               IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_ID in
--                                      the table MTL_CATEGORIES_B, and identifies the
--                                      category that needs to be deleted.
--                              p_new_category_id               IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_ID in
--                                      the table MTL_CATEGORIES_B, and identifies the
--                                      category that needs to be added.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : 1. As per the inventory team, No bulk operations
--                           (i.e loading data from an interface table)
--                           are allowed on valid cat sets.
--
-- End of comments
PROCEDURE populateValidCategorySetUpdate
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_category_set_id       IN              NUMBER                                  ,
        p_old_category_id       IN              NUMBER                                  ,
        p_new_category_id       IN              NUMBER
);

-- Start of comments
--      API name        : populateValidCategorySetDelete
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of deleting the category in ip datamodel
--                        if the category belongs to purchasing category set.  This
--                        procedure is called by Inventory when a category is deleted
--                        from the valid category set (MTL_CATEGORY_SET_VALID_CATS)
--                        from forms / html interface.
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_category_set_id               IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_SET_ID in
--                                      the table MTL_CATEGORY_SET_VALID_CATS, and
--                                      identifies the category_set_id of the category.
--                              p_category_id                   IN NUMBER       Required
--                                      Corresponds to the column CATEGORY_ID in
--                                      the table MTL_CATEGORIES_B, and identifies the
--                                      category to be deleted.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : 1. As per the inventory team, No bulk operations
--                           (i.e loading data from an interface table)
--                           are allowed on valid cat sets.
--
-- End of comments
PROCEDURE populateValidCategorySetDelete
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_category_set_id       IN              NUMBER                                  ,
        p_category_id           IN              NUMBER
);

END ICX_CAT_POPULATE_CATG_GRP;

 

/
