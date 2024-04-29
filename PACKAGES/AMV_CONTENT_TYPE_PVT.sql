--------------------------------------------------------
--  DDL for Package AMV_CONTENT_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_CONTENT_TYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvctps.pls 120.1 2005/06/22 17:35:14 appldev ship $ */
--
-- Start of Comments
--
-- NAME
--   AMV_CONTENT_TYPE_PVT
--
-- PURPOSE
--   This package is a private API managing content type
--   and their related attributes in AMV. It defines global variables.
--   It is part of the Item Block API
--
--   PROCEDURES:
--
--            Add_ContentType;
--            Delete_ContentType;
--            Update_ContentType;
--            Get_ContentType;
--            Find_ContentTypes;
--
-- NOTES
--
--
-- HISTORY
--   08/06/1999        PWU            created
-- End of Comments
--
--
-- The following constants are to be finalized.
--
G_VERSION               CONSTANT    NUMBER    :=  1.0;
--
--Type definitions

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

TYPE amv_content_type_obj_type IS RECORD(
      content_type_id           NUMBER,
      object_version_number     NUMBER,
      content_type_name         VARCHAR2(80),
      description               VARCHAR2(2000),
      language                  VARCHAR2(4),
      source_lang               VARCHAR2(4),
      creation_date             DATE,
      created_by                NUMBER,
      last_update_date          DATE,
      last_updated_by           NUMBER,
      last_update_login         NUMBER
);

TYPE amv_content_type_obj_varray IS TABLE of amv_content_type_obj_type;
	--INDEX BY BINARY_INTEGER;

--
-- This package contains the following procedure
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ContentType
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create a new content type in MES,
--                 given the content type record.
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
--                 p_content_type_name                VARCHAR2  Required
--                    content type name are required to be unique.
--                 p_cnt_type_description             VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_content_type_id                  NUMBER
--                    content type id will be generated from sequence number.
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ContentType
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_name    IN  VARCHAR2,
    p_cnt_type_description IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_content_type_id      OUT NOCOPY  NUMBER
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
--     check if this content type name has been used in MES
--     IF so THEN
--         return error 'duplicated content type name';
--     ELSE
--       Set rollback SAVEPOINT
--       call content type handler to insert a new content type record.
--       Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_ContentType
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete the content type specified by its id or name
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
--                 p_content_type_id                  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_content_type_name                VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    Either pass the content type id (preferred) or
--                    content type name to identify the content type.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_ContentType
(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2,
    p_check_login_user   IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_id    IN  NUMBER   := FND_API.G_MISS_NUM,
    p_content_type_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR
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
--     check if this content type id (if passed) is in MES
--     IF not THEN
--         return error 'invalid content type id';
--     END IF
--     check if this content type name (if passed) is in MES
--     IF not THEN
--         return error 'invalid content type name';
--     ELSE
--       Set rollback SAVEPOINT
--       Delete all other table records which refers this content type  record.
--       Call content type handler to delete the content type record.
--       Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_ContentType
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Change the content type name
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
--                 p_content_type_id                  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_content_type_name                VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    Either pass the content type id (preferred) or
--                    content type name to identify the content type.
--                 p_content_type_new_name            VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                 p_cnt_type_description             VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_ContentType
(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_check_login_user       IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_content_type_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_content_type_new_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_cnt_type_description   IN  VARCHAR2 := FND_API.G_MISS_CHAR
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
--     check if this content type id (if passed) is in MES
--     IF not THEN
--         return error 'invalid content type id';
--     END IF
--     check if this content type name (if passed) is in MES
--     IF not THEN
--         return error 'invalid content type name';
--     ELSE
--       Set rollback SAVEPOINT
--       Call content type handler to update the content type record.
--       Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ContentType
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get content type record based on its id (preferred) or name.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_content_type_id                  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_content_type_name                VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    Either pass the content type id (preferred) or
--                    content type name to identify the content type record.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_content_type_obj                 AMV_CONTENT_TYPE_OBJ_TYPE
--                   The requested content type obj.
--    Notes      :  Should we add an option of locking?
--
-- End of comments
--
PROCEDURE Get_ContentType
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_id     IN  NUMBER   := FND_API.G_MISS_NUM,
    p_content_type_name   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_content_type_obj    OUT NOCOPY  AMV_CONTENT_TYPE_OBJ_TYPE
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     check if this content type id (if passed) is in MES
--     IF not THEN
--         return error 'invalid content type id';
--     END IF
--     check if this content type name (if passed) is in MES
--       Query and return the content type record.
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_ContentType
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Find content type records based on its name or description.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_content_type_name                VARCHAR2  Optional
--                    The search criteria on name
--                        Default = FND_API.G_MISS_CHAR
--                 p_cnt_type_description             VARCHAR2  Optional
--                    The search criteria on description
--                        Default = FND_API.G_MISS_CHAR
--                 p_subset_request_obj               AMV_REQUEST_OBJ_TYPE,
--                                                              Required.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_subset_return_obj                AMV_RETURN_OBJ_TYPE,
--                 x_content_type_obj_varray         AMV_CONTENT_TYPE_OBJ_VARRAY
--                   The varray of found content type records.
--    Notes      :
--
-- End of comments
--
PROCEDURE Find_ContentType
(
    p_api_version             IN  NUMBER,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_name       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_cnt_type_description    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj      IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj       OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_content_type_obj_varray OUT NOCOPY  AMV_CONTENT_TYPE_OBJ_VARRAY
);
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Base on the search criteria (content type name or description),
--       create sql statement and execute it to get the results.
--   END
--
--------------------------------------------------------------------------------
--
--
END amv_content_type_pvt;

 

/
