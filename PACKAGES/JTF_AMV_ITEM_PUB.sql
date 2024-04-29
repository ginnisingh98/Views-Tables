--------------------------------------------------------
--  DDL for Package JTF_AMV_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AMV_ITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpitms.pls 115.3 2002/11/26 19:14:33 stopiwal ship $ */
-- Start of Comments
--
-- NAME
--   JTF_AMV_ITEM_PUB
--
-- PURPOSE
--   This package is a public API managing items (contents) and their related
--   attributes in JTF.  It also defines global variables.
--
--   PROCEDURES:
--            Create_Item;
--            Delete_Item;
--            Update_Item;
--            Get_Item;
--
--     Handle file:    --This have been moved to a separated package.
--            --Add_ItemFile
--            --Delete_ItemFile
--            --Update_ItemFile
--            --Get_ItemFile
--     Handle keywords:
--            Add_ItemKeyword
--            Delete_ItemKeyword
--            Replace_ItemKeyword
--            Get_ItemKeyword
--     Handle authors:
--            Add_ItemAuthor
--            Delete_ItemAuthor
--            Update_ItemAuthor
--            Get_ItemAuthor
-- NOTES
--
--     The API to handle item's perspective and content type are in separated
--     MES package (amv_perspective_pvt and amv_contenttype_pvt). These are more
--     MES specific.
--
-- HISTORY
--   11/30/1999        PWU            created
-- End of Comments
--
--
-- The following constants are to be finalized.
--
G_VERSION               CONSTANT    NUMBER    :=  1.0;
--
TYPE number_tab_type    IS table of NUMBER;
TYPE char_tab_type      IS table of VARCHAR2(120);
--
TYPE item_rec_type IS RECORD
(
  item_id                   NUMBER,
  creation_date             DATE,
  created_by                NUMBER,
  last_update_date          DATE,
  last_updated_by           NUMBER,
  last_update_login         NUMBER,
  object_version_number     NUMBER,
  application_id            NUMBER,
  external_access_flag      VARCHAR2(1),
  item_name                 VARCHAR2(240),
  description               VARCHAR2(2000),
  text_string               VARCHAR2(2000),
  language_code             VARCHAR2(4),
  status_code               VARCHAR2(30),
  effective_start_date      DATE,
  expiration_date           DATE,
  item_type                 VARCHAR2(240),
  url_string                VARCHAR2(2000),
  publication_date          DATE,
  priority                  VARCHAR2(30),
  content_type_id           NUMBER,
  owner_id                  NUMBER,
  default_approver_id       NUMBER,
  item_destination_type     VARCHAR2(240),
  access_name               VARCHAR2(40),
  deliverable_type_code     VARCHAR2(40),
  applicable_to_code        VARCHAR2(40)
);
--
-- This package contains the following procedure
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Create_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Create a new item given the item information.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_rec                         ITEM_REC_TYPE,
--                                                              Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_item_id                          NUMBER
--                 Item id will be generated from sequence number.
--    Notes      :
--
-- End of comments
--
PROCEDURE Create_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_rec          IN  ITEM_REC_TYPE,
    x_item_id           OUT NOCOPY NUMBER
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Set rollback SAVEPOINT
--     Ensure that the passed item object has basic right information.
--     insert a new item with row = p_obj_rec to
--     item table(jtf_amv_items_b and jtf_amv_items_tl).
--     Commit transaction if requested
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Delete the item given the item id from database.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--       Set rollback SAVEPOINT
--       Get the item with item_id = p_item_id
--       Delete the item's attributes (attachment, keywords, authors)
--       Delete the item itself
--       Commit transaction if requested
--   END
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Update the item based on the passed item record information.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_rec                         ITEM_REC_TYPE
--                 The record for the new data of the item.     Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_rec          IN  ITEM_REC_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Set rollback SAVEPOINT
--     Ensure that the passed item record has basic right information.
--     update the item with row = p_item_rec to
--     item table(jtf_amv_items_b and jtf_items_tl, ...).
--     Commit transaction if requested
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Get an item information given the item id.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_item_rec                         ITEM_REC_TYPE
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    x_item_rec          OUT NOCOPY ITEM_REC_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Base on the given item id, query and get the item.
--   END
--------------------------------------------------------------------------------
------------------------------ ITEM_KEYWORD ------------------------------------
-- Start of comments
--    API name   : Add_ItemKeyword
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Add the keywords passed in the table to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the keywords.
--                 p_keyword_tab                      CHAR_TAB_TYPE
--                    The keywords table                        Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword_tab       IN  CHAR_TAB_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Set rollback SAVEPOINT
--       Loop for each keyword in the passed table
--           check if the keyword is already in the item.
--           If so, don't add it.
--           add the keyword to the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ItemKeyword
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Add the keyword to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the keyword.
--                 p_keyword                          VARCHAR2  Required
--                    The keyword to be added to the item.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword           IN  VARCHAR2
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Set rollback SAVEPOINT
--     check if the keyword is in the item.
--     If so, don't add it.
--     otherwise, add the keyword to the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemKeyword
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Remove the keywords passed in the table
--                 from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the keywords.
--                 p_keyword_tab                      CHAR_TAB_TYPE
--                    The keywords table                        Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword_tab       IN  CHAR_TAB_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Set rollback SAVEPOINT
--       Loop for each keyword in the passed array
--           remove the keyword from the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemKeyword
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Remove the passed keyword from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The id of the item to remove the keyword from.
--                 p_keyword                          VARCHAR2  Required
--                    The keyword to be removed.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword           IN  VARCHAR2
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     check if this item id is valid
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--     remove the keyword from the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Replace_ItemKeyword
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Set the keywords of the specified item
--                 to the keywords passed in the array
--                 Effectively, this delete all the orignal keywords
--                 and add the passed keywords to the item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The item id to be added the keywords.
--                 p_keyword_tab                      CHAR_TAB_TYPE
--                    The keywords table                        Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Replace_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword_tab       IN  CHAR_TAB_TYPE
);
-- Algorithm:
--   BEGIN
--     Call delete_ItemKeyword to delete all the original keywords
--     Then call Add_ItemKeyword to add the keywords to the item.
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemKeyword
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Query and return all the keywords of the specified item
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_keyword_tab                      CHAR_TAB_TYPE
--                    The retrieved keywords table
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    x_keyword_tab       OUT NOCOPY CHAR_TAB_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     check if this item id is valid
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Query all the keywords belonged to the specified item
--     And return the results in the output table.
--
--------------------------------------------------------------------------------
------------------------------ ITEM_AUTHOR -------------------------------------
-- Start of comments
--    API name   : Add_ItemAuthor
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Add the authors passed in the table to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the authors.
--                 p_author_tab                      CHAR_TAB_TYPE
--                    The authors table                        Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author_tab        IN  CHAR_TAB_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Set rollback SAVEPOINT
--       Loop for each author in the passed table
--           check if the author is already in the item.
--           If so, don't add it.
--           add the author to the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ItemAuthor
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Add the author to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the author.
--                 p_author                           VARCHAR2  Required
--                    The author to be added to the item.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author            IN  VARCHAR2
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Set rollback SAVEPOINT
--     check if the author is in the item.
--     If so, don't add it.
--     otherwise, add the author to the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemAuthor
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Remove the authors passed in the table
--                 from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the authors.
--                 p_author_tab                       CHAR_TAB_TYPE
--                    The authors table                        Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author_tab        IN  CHAR_TAB_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Set rollback SAVEPOINT
--       Loop for each author in the passed array
--           remove the author from the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemAuthor
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Remove the passed author from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The id of the item to remove the author from.
--                 p_author                           VARCHAR2  Required
--                    The author to be removed.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author            IN  VARCHAR2
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     check if this item id is valid
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--     remove the author from the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Replace_ItemAuthor
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Set the authors of the specified item
--                 to the authors passed in the table
--                 Effectively, this delete all the orignal authors
--                 and add the passed authors to the item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--                    The item id to be added the authors.
--                 p_author_tab                       CHAR_TAB_TYPE
--                    The authors table                        Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Replace_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author_tab        IN  CHAR_TAB_TYPE
);
-- Algorithm:
--   BEGIN
--     Call delete_ItemAuthor to delete all the original authors
--     Then call Add_ItemAuthor to add the authors to the item.
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemAuthor
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Query and return all the authors of the specified item
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_item_id                          NUMBER    Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_author_tab                       CHAR_TAB_TYPE
--                    The retrieved authors table
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    x_author_tab        OUT NOCOPY CHAR_TAB_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     check if this item id is valid
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Query all the authors belonged to the specified item
--     And return the results in the output table.
--
--------------------------------------------------------------------------------
--
END jtf_amv_item_pub;

 

/
