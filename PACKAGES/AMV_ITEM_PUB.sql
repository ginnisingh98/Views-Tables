--------------------------------------------------------
--  DDL for Package AMV_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_ITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: amvpitms.pls 120.1 2005/06/22 16:41:29 appldev ship $ */
-- Start of Comments
--
-- NAME
--   AMV_ITEM_PUB
--
-- PURPOSE
--   This package is a public API managing MES items (contents) and
--   their related attributes.  It also define global variables.
--
--   PROCEDURES:
--      Item:
--            Creat_Item;
--            Delete_Item;
--            Update_Item;
--            Get_Item;
--            Find_Item;
--
--     Handle file:
--            Add_ItemFile
--            Delete_ItemFile
--            Update_ItemFile
--            Get_ItemFile
--
--     Handle keywords:
--            Add_ItemKeyword
--            Delete_ItemKeyword
--            Replace_ItemKeyword
--            Get_ItemKeyword
--
--     Handle authors:
--            Add_ItemAuthor
--            Delete_ItemAuthor
--            Replace_ItemAuthor
--            Get_ItemAuthor
--
-- NOTES
--
--     The API to handle item's perspective and content type are in separated
--     package (amv_perspective_pvt and amv_contenttype_pvt).
--     The API for item's author and keywords are also in jtf_item_pub.
--     Here we add checking user privileges.
--
-- HISTORY
--   08/30/1999        PWU            created
--   12/03/1999        PWU            modify to call jtf amv item api
-- End of Comments
--

TYPE AMV_CHAR_VARRAY_TYPE IS TABLE OF VARCHAR2(4000);

TYPE AMV_NUMBER_VARRAY_TYPE IS TABLE OF NUMBER;

TYPE amv_return_obj_type IS RECORD(
      returned_record_count           NUMBER,
      next_record_position            NUMBER,
      total_record_count              NUMBER
);

TYPE amv_request_obj_type IS RECORD(
      records_requested               NUMBER,
      start_record_position           NUMBER,
      return_total_count_flag         VARCHAR2(1)
);

TYPE amv_item_obj_type IS RECORD(
      item_id                   NUMBER,
      object_version_number     NUMBER,
      creation_date             DATE,
      created_by                NUMBER,
      last_update_date          DATE,
      last_updated_by           NUMBER,
      last_update_login         NUMBER,
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
      item_destination_type     VARCHAR2(240)
);

TYPE amv_simple_item_obj_type IS RECORD(
      item_id                   NUMBER,
      object_version_number     NUMBER,
      creation_date             DATE,
      created_by                NUMBER,
      last_update_date          DATE,
      last_updated_by           NUMBER,
      last_update_login         NUMBER,
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
      file_id_list              VARCHAR2(2000),
      persp_id_list             VARCHAR2(2000),
      persp_name_list           VARCHAR2(2000),
      author_list               VARCHAR2(2000),
      keyword_list              VARCHAR2(2000)
);

TYPE amv_simple_item_obj_varray IS TABLE of amv_simple_item_obj_type;

TYPE amv_nameid_obj_type IS RECORD(
     id           NUMBER,
     name         VARCHAR2(240)
);

TYPE amv_nameid_varray_type IS TABLE OF amv_nameid_obj_type;

--
-- The following constants are to be finalized.
--
G_VERSION CONSTANT    NUMBER    :=  1.0;
G_PUSH  	CONSTANT	 VARCHAR2(30) := AMV_UTILITY_PVT.G_PUSH;
G_MATCH  	CONSTANT	 VARCHAR2(30) := AMV_UTILITY_PVT.G_MATCH;
--
--
-- This package contains the following procedure
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Creat_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Create a new item in MES,
--                 given the item information.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_channel_id_array                 AMV_NUMBER_VARRAY_TYPE
--                        Default = NULL.                       Optional
--                 p_item_obj                         AMV_ITEM_OBJ_TYPE
--                                                              Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_item_id                          NUMBER
--                 item_id will be generated from sequence number.
--    Notes      :
--
-- End of comments
--
PROCEDURE Create_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id_array  IN  AMV_NUMBER_VARRAY_TYPE := NULL,
    p_item_obj          IN  AMV_ITEM_OBJ_TYPE,
    p_file_array        IN  AMV_NUMBER_VARRAY_TYPE,
    p_persp_array       IN  AMV_NAMEID_VARRAY_TYPE,
    p_author_array      IN  AMV_CHAR_VARRAY_TYPE,
    p_keyword_array     IN  AMV_CHAR_VARRAY_TYPE,
    x_item_id           OUT NOCOPY  NUMBER
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--         Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--         Return error 'Administrative privileges required to perform'
--     ENDIF
--     Set rollback SAVEPOINT
--     Ensure that the passed item object has basic right information.
--     insert a new item with row = p_obj_type to
--     item table(ams_deliverables_all_b).
--     insert (via api) the item's attributes authors, keywords, files,
--        perspectives into the database.
--     Commit transaction if requested
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Delete an item from MES given the item id.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--         Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--         Return error 'Administrative privileges required to perform'
--     ENDIF
--       Set rollback SAVEPOINT
--       Get the item with item_id = p_item_id
--       Delete the item's attributes
--       Delete the item itself
--       (the file associated with the item will be deleted by batched job)
--       Commit transaction if requested
--     ENDIF
--   END
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Update the item based on the passed item object information.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_obj                         AMV_ITEM_OBJ_TYPE
--                                                              Required
--                 The object for the new data of the item
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id_array  IN  AMV_NUMBER_VARRAY_TYPE := NULL,
    p_item_obj          IN  AMV_ITEM_OBJ_TYPE,
    p_file_array        IN  AMV_NUMBER_VARRAY_TYPE,
    p_persp_array       IN  AMV_NAMEID_VARRAY_TYPE,
    p_author_array      IN  AMV_CHAR_VARRAY_TYPE,
    p_keyword_array     IN  AMV_CHAR_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--         Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--         Return error 'Administrative privileges required to perform'
--     ENDIF
--     Set rollback SAVEPOINT
--     Ensure that the passed item object has basic right information.
--     update the item with row = p_obj_type to
--     item table(ams_deliverables_all_b).
--     update (via api) the item's attributes authors, keywords, files,
--        perspectives on the database.
--     Commit transaction if requested
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Get an item information from MES given the item id.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_item_obj                         AMV_ITEM_OBJ_TYPE
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    x_item_obj          OUT NOCOPY  AMV_ITEM_OBJ_TYPE,
    x_file_array        OUT NOCOPY   AMV_NUMBER_VARRAY_TYPE,
    x_persp_array       OUT NOCOPY   AMV_NAMEID_VARRAY_TYPE,
    x_author_array      OUT NOCOPY   AMV_CHAR_VARRAY_TYPE,
    x_keyword_array     OUT NOCOPY   AMV_CHAR_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--         Return error 'user account currently suspended'
--     ENDIF
--     Base on the given item id, query and get the item and its attributes.
--   END
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Item
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Query and return items from MES based on the passed criteria.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_name                        VARCHAR2  Optional
--                     search criterion on item name
--                     default to FND_API.G_MISS_CHAR
--                 p_description                      VARCHAR2  Optional
--                     search criterion on item description
--                     default to FND_API.G_MISS_CHAR
--                 p_item_type                        VARCHAR2  Optional
--                     search criterion on item type
--                     default to FND_API.G_MISS_CHAR
--                 p_subset_request_obj               AMV_REQUEST_OBJ_TYPE,
--                                                              Required.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_subset_return_obj                AMV_RETURN_OBJ_TYPE,
--                 x_item_obj_array                   AMV_SIMPLE_ITEM_OBJ_VARRAY
--    Notes      : For more sophisticated search, check with the search engine.
--
-- End of comments
--
PROCEDURE Find_Item
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_description         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_item_type           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj  IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj   OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_item_obj_array      OUT NOCOPY  AMV_SIMPLE_ITEM_OBJ_VARRAY
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--         Return error 'user account currently suspended'
--     ENDIF
--     Base on the given item name, description, and item type,
--       query and get the item and its attributes.
--   END
--------------------------------------------------------------------------------
------------------------------ ITEM_KEYWORD ------------------------------------
-- Start of comments
--    API name   : Add_ItemKeyword
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Add the keywords passed in the array to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the keywords.
--                 p_keyword_varray                   AMV_CHAR_VARRAY_TYPE
--                                                              Required
--                    The keywords array
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword_varray    IN  AMV_CHAR_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--       Loop for each keyword in the passed array
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
--    Function   : Add the specified keywords to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the keywords.
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword           IN  VARCHAR2
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--     check if the keyword is in the item.
--     If so, don't add it.
--     otherwise, add the keyword to the item.
--     Commit transaction if requested
--
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemKeyword
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Remove the keywords passed in the array
--                 from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the keywords.
--                 p_keyword_varray                   AMV_CHAR_VARRAY_TYPE
--                                                              Required
--                    The keywords array
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword_varray    IN  AMV_CHAR_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
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
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword           IN  VARCHAR2
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
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
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the keywords.
--                 p_keyword_varray                   AMV_CHAR_VARRAY_TYPE
--                                                              Required
--                    The keywords array
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword_varray    IN  AMV_CHAR_VARRAY_TYPE
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
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the keywords.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_keyword_varray                   AMV_CHAR_VARRAY_TYPE
--                    All the keywords of the item.
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    x_keyword_varray    OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Query all the keywords belonged to the specified item
--     And return the results in the output array.
--
--------------------------------------------------------------------------------
------------------------------ ITEM_AUTHOR -------------------------------------
-- Start of comments
--    API name   : Add_ItemAuthor
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Add the authors passed in the array to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the authors.
--                 p_author_varray                    AMV_CHAR_VARRAY_TYPE
--                                                              Required
--                    The authors array
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author_varray     IN  AMV_CHAR_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--       Loop for each author in the passed array
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
--    Function   : Add the specified author to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the authors.
--                 p_author                          VARCHAR2  Required
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author            IN  VARCHAR2
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
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
--    Function   : Remove the authors passed in the array
--                 from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the authors.
--                 p_author_varray                    AMV_CHAR_VARRAY_TYPE
--                                                              Required
--                    The authors array
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author_varray     IN  AMV_CHAR_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
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
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the author.
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author            IN  VARCHAR2
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
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
--                 to the authors passed in the array
--                 Effectively, this delete all the orignal authors
--                 and add the passed authors to the item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the authors.
--                 p_author_varray                    AMV_CHAR_VARRAY_TYPE
--                                                              Required
--                    The authors array
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author_varray     IN  AMV_CHAR_VARRAY_TYPE
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
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the authors.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_author_varray                    AMV_CHAR_VARRAY_TYPE
--                    All the authors of the item.
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    x_author_varray     OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Query all the authors belonged to the specified item
--     And return the results in the output array.
--
--------------------------------------------------------------------------------
--------------------------------- ITEM_FILE ------------------------------------
-- Start of comments
--    API name   : Add_ItemFile
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Add the files passed in the id array to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_application_id                   NUMBER    Optional
--                    The id of application that attaches the file to item.
--                     Default to AMV_UTILITY_PVT.G_AMV_APP_ID (520)
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the files.
--                 p_file_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                                                              Required
--                    The file ids array
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
    p_item_id           IN  NUMBER,
    p_file_id_varray    IN  AMV_NUMBER_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--       Loop for each file id in the passed array
--           check if the file id is already in the item.
--           If so, don't add it.
--           otherwise, add the file to the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ItemFile
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Add the specified file to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_application_id                   NUMBER    Optional
--                    The id of application that attaches the file to item.
--                     Default to AMV_UTILITY_PVT.G_AMV_APP_ID (520)
--                 p_item_id                          NUMBER    Required
--                    The id of the item to be add the file to.
--                 p_file_id                          NUMBER    Required
--                    The id of the file to be added to the item.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
    p_item_id           IN  NUMBER,
    p_file_id           IN  NUMBER
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--     check if the file is in the item.
--     If so, don't add it.
--     otherwise, add the file to the item.
--     Commit transaction if requested
--
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemFile
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Remove the files passed in the array
--                 from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The id of the item to be add the files to.
--                 p_file_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                                                              Required
--                    The file id array
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_file_id_varray    IN  AMV_NUMBER_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--       Loop for each file id in the passed array
--           remove the file from the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemFile
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Remove the passed file from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The id of item to remove the file from.
--                 p_file_id                          NUMBER    Required
--                    The file to be removed.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_file_id           IN  NUMBER
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'Administrative privileges required to perform'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Set rollback SAVEPOINT
--     remove the file from the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Replace_ItemFile
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Set the files of the specified item
--                 to the files passed in the array
--                 Effectively, this delete all the orignal files
--                 and add the passed files to the item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The id of item to remove the file from.
--                 p_file_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                                                              Required
--                    The files id array which will replace the original files.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Replace_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_file_id_varray    IN  AMV_NUMBER_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--     Call delete_ItemFile to delete all the original files
--     Then call Add_ItemFile to add the files to the item.
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemFile
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Query and return all the files of the specified item
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the files.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_file_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                    file id array for all the files of the item.
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    x_file_id_varray    OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     check if this item id is in MES
--     IF not THEN
--         return error 'invalid item id';
--     END IF
--     Query all the files belonged to the specified item
--     And return the results in the output array.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserMessage
--    Type       : Public
--    Pre-reqs   : None
--    Function   : return all the messages(id and name) for the specified user.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_user_id                          NUMBER    Required
--                    The should be the resource id.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_item_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                 x_message_varray                   AMV_CHAR_VARRAY_TYPE
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_UserMessage
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_id           IN  NUMBER,
    x_item_id_varray    OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE,
    x_message_varray    OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserMessage2
--    Type       : Public
--    Pre-reqs   : None
--    Function   : return all the messages(all info) for the specified user.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_user_id                          NUMBER    Required
--                    The should be the resource id.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_item_varray                      AMV_SIMPLE_ITEM_OBJ_VARRAY
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_UserMessage2
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_id           IN  NUMBER,
    x_item_varray       OUT NOCOPY  AMV_SIMPLE_ITEM_OBJ_VARRAY
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelsPerItem
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Query and return all the channels matched the specified item
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--			    p_match_type				    VARCHAR2  Optional
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the files.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_channel_array                    AMV_NAMEID_VARRAY_TYPE
--                    file id array for all the files of the item.
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelsPerItem
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_match_type	    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_channel_array     OUT NOCOPY  AMV_NAMEID_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_item_pub;

 

/
