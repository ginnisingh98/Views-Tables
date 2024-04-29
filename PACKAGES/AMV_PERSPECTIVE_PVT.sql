--------------------------------------------------------
--  DDL for Package AMV_PERSPECTIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_PERSPECTIVE_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvpsps.pls 120.1 2005/06/30 13:09:01 appldev ship $ */
--
-- Start of Comments
--
-- NAME
--   AMV_PERSPECTIVE_PVT
--
-- PURPOSE
--   This package is a private API managing perspectives
--   and their related attributes in AMV. It defines global variables.
--   It is part of the Item Block API
--
--   PROCEDURES:
--
--            Add_Perspective;
--            Delete_Perspective;
--            Update_Perspective;
--            Get_Perspective;
--            Find_Perspectives;
--     --with item
--            Add_ItemPersps;
--            Delete_ItemPersps;
--            Get_ItemPersps;
--
-- NOTES
--
--
-- HISTORY
--   07/19/1999        PWU            created
-- End of Comments
--
--
-- The following constants are to be finalized.
--
G_VERSION               CONSTANT    NUMBER    :=  1.0;
--
--Type definitions

TYPE AMV_NUMBER_VARRAY_TYPE IS TABLE OF NUMBER;
	--INDEX BY BINARY_INTEGER;

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

TYPE amv_perspective_obj_type IS RECORD(
      perspective_id            NUMBER,
      object_version_number     NUMBER,
      perspective_name          VARCHAR2(80),
      description               VARCHAR2(2000),
      language                  VARCHAR2(4),
      source_lang               VARCHAR2(4),
      creation_date             DATE,
      created_by                NUMBER,
      last_update_date          DATE,
      last_updated_by           NUMBER,
      last_update_login         NUMBER
);

TYPE amv_perspective_obj_varray IS TABLE of amv_perspective_obj_type;
	--INDEX BY BINARY_INTEGER;

--
-- This package contains the following procedure
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_Perspective
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create a new perspective in MES,
--                 given the passed perspective information.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_perspective_name                 VARCHAR2  Required
--                    Perspective_name are required to be unique.
--                 p_persp_description                VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    The description of perspective
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_perspective_id                   NUMBER
--                    perspective id will be generated from sequence number.
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_Perspective
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_name  IN  VARCHAR2,
    p_persp_description IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_perspective_id    OUT NOCOPY  NUMBER
);
--
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
--     check if this perspective name has been used in MES
--     IF so THEN
--         return error 'duplicated perspective name';
--     ELSE
--       Set rollback SAVEPOINT
--       call perspective handler to insert a new perspective record.
--       Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Perspective
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete the perspective specified by its id or name
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_perspective_id                   NUMBER    Optional
--                 p_perspective_name                 VARCHAR2  Optional
--                    Either pass the perspective id (preferred) or
--                    perspective name to identify the perspective.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_Perspective
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_id    IN  NUMBER   := FND_API.G_MISS_NUM,
    p_perspective_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--
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
--     check if this perspective id (if passed) is in MES
--     IF not THEN
--         return error 'invalid perspective id';
--     END IF
--     check if this perspective name (if passed) is in MES
--     IF not THEN
--         return error 'invalid perspective name';
--     ELSE
--       Set rollback SAVEPOINT
--       Delete all other table records which refers this perspective  record.
--       Call perspective handler to delete the perspective record.
--       Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Perspective
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Change the perspective name
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_perspective_id                   NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_perspective_name                 VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    Either pass the perspective id (preferred) or
--                    perspective name to identify the perspective.
--                 p_perspective_new_name             VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                 p_persp_description                VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_Perspective
(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_check_login_user      IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_perspective_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_perspective_new_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_persp_description     IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--
--
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
--     check if this perspective id (if passed) is in MES
--     IF not THEN
--         return error 'invalid perspective id';
--     END IF
--     check if this perspective name (if passed) is in MES
--     IF not THEN
--         return error 'invalid perspective name';
--     ELSE
--       Set rollback SAVEPOINT
--       Call perspective handler to update the perspective record.
--       Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Perspective
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get perspective record based on its id (preferred) or name.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_perspective_id                   NUMBER    Optional
--                 p_perspective_name                 VARCHAR2  Optional
--                    Either pass the perspective id (preferred) or
--                    perspective name to identify the perspective.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_perspective_obj                  AMV_PERSPECTIVE_OBJ_TYPE
--                   The requested perspective obj.
--    Notes      :  Should we add an option of locking?
--
-- End of comments
--
PROCEDURE Get_Perspective
(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_check_login_user      IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_perspective_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_perspective_obj       OUT NOCOPY  AMV_PERSPECTIVE_OBJ_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     check if this perspective id (if passed) is in MES
--     IF not THEN
--         return error 'invalid perspective id';
--     END IF
--     check if this perspective name (if passed) is in MES
--       Query and return the perspective record.
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Perspective
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Find perspective records based on its id (preferred) or name.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_perspective_name                 VARCHAR2  Optional
--                    The search criteria on perspective name
--                        Default = FND_API.G_MISS_CHAR
--                 p_perspective_name                 VARCHAR2  Optional
--                    The search criteria on perspective name
--                        Default = FND_API.G_MISS_CHAR
--                 p_persp_description                VARCHAR2  Optional
--                    The search criteria on perspective description
--                        Default = FND_API.G_MISS_CHAR
--                 p_subset_request_obj               AMV_REQUEST_OBJ_TYPE,
--                                                              Required.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_subset_return_obj                AMV_RETURN_OBJ_TYPE,
--                 x_perspective_obj_varray           AMV_PERSPECTIVE_OBJ_VARRAY
--                   The varray of found perspective records.
--    Notes      :
--
-- End of comments
--
PROCEDURE Find_Perspective
(
    p_api_version             IN  NUMBER,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_persp_description       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj      IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj       OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_perspective_obj_varray  OUT NOCOPY  AMV_PERSPECTIVE_OBJ_VARRAY
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Base on the search critiria (perspective name or description),
--       create sql statement and execute it to get the results.
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ItemPersps
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Add the perspectives passed in the array to the specified
--                 item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the perspectives.
--                 p_perspective_array                AMV_NUMBER_VARRAY_TYPE
--                                                              Required
--                    The perspective id array
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_array IN  AMV_NUMBER_VARRAY_TYPE
);
--
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
--       Loop for each perspective id in the passed array
--           check if the perspective id is valid.
--           check if the perspective id is already in the item.
--           add the perspective to the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ItemPersps
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Add the specified perspective to the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the perspectives.
--                 p_perspective_id                   NUMBER    Required
--                    The perspective id.
--    OUT NOCOPY         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      : This overloaded procedures only add one perspective to
--                 an item.
--
-- End of comments
--
PROCEDURE Add_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_id    IN  NUMBER
);
--
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
--     check if the perspective id is valid.
--     IF not THEN
--         return error 'invalid perspective id';
--     END IF
--     check if the perspective id is already in the item.
--     IF so THEN
--         return error 'the item already has the perspective.';
--     END IF
--     Add the perspective to the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemPersps
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete the perspectives passed in the array
--                 from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the perspectives.
--                 p_perspective_array                AMV_NUMBER_VARRAY_TYPE
--                                                              Required
--                    The perspective id array
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      : This overloaded procedures only add one perspective to
--                 an item.
--
-- End of comments
--
PROCEDURE Delete_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_array IN  AMV_NUMBER_VARRAY_TYPE
);
--
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
--       Loop for each perspective id in the passed array
--           check if the perspective id is valid.
--          IF not THEN
--              return error 'invalid perspective id';
--          END IF
--           check if the perspective id is in the item.
--          IF not THEN
--              return error 'the item does not have the perspective.';
--          END IF
--           remove the perspective from the item.
--     Commit transaction if requested
--   END
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ItemPersps
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete the specified perspective from the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the perspectives.
--                 p_perspective_id                   NUMBER    Optional
--                    The perspective id. If missing, caller want to delete
--                    all the perspectives of the item.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_id    IN  NUMBER   := FND_API.G_MISS_NUM
);
--
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
--     check if the perspective id is valid.
--     IF not THEN
--         return error 'invalid perspective id';
--     END IF
--     check if the perspective id is in the item.
--     IF not THEN
--         return error 'the item does not have the perspective.';
--     END IF
--     Remove the perspective from the item.
--     Commit transaction if requested
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_ItemPersps
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Set the perspectives of the specified item
--                 to the perspectives  passed in the array
--                 Effectively, this delete all the orignal perspectives
--                 and add the passed perspectives to the item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the perspectives.
--                 p_perspective_array                AMV_NUMBER_VARRAY_TYPE
--                                                              Required
--                    The perspective id array
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_array IN  AMV_NUMBER_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Call delete_ItemPersp to delete all the original perspectives
--     Then call Add_ItemPersp to add the perspectives to the item.
--   END
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemPersps
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all the perspectives for the specified item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the perspectives.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_perspective_obj_varray           AMV_PERSPECTIVE_OBJ_VARRAY
--                    The returned perspective object array
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemPersps
(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_check_login_user       IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id                IN  NUMBER,
    x_perspective_obj_varray OUT NOCOPY  AMV_PERSPECTIVE_OBJ_VARRAY
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
--     Query all the perspectives belonged to the specified item
--     And return the results in the output array.
--
--------------------------------------------------------------------------------
--
END amv_perspective_pvt;

 

/
