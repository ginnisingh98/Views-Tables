--------------------------------------------------------
--  DDL for Package AMV_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_USER_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvusrs.pls 120.1 2005/06/30 13:27:27 appldev ship $ */
-- Start of Comments
--
-- NAME
--   AMV_USER_PVT
--
-- PURPOSE
--   This package is a private user API in AMV.
--   It is the main part of user profile block API.
--   All the procedures are used to handle users (resources)
--   and their profile (privileges, access, etc).
--
-- This package contains the following procedures
--
--      Resource
--            --Add_Resource;
--            --Delete_Resource;
--            --Update_Resource;
--            --Get_Resource;
--            Get_ResourceId;
--            Find_Resource;
--      Resource Roles
--            Add_ResourceRole;
--            Remove_ResourceRole;
--            Replace_ResourceRole;
--            Get_ResourceRoles;
--            Check_ResourceRole;
--            Is_Administrator;
--            Can_PublishContent;
--            Can_ApproveContent;
--            Can_SetupChannel;
--            Can_SetupCategory;
--            Can_SetupDistRule;
--
--      Group Roles
--            Add_GroupRole;
--            Remove_GroupRole;
--            Replace_GroupRole;
--            Check_GroupRole;
--            Get_GroupRoles;
--
--      Groups
--            Add_Group
--            Update_Group
--            Delete_Group
--            Get_Group
--            Find_Group
--
--      Group Membership
--            Add_GroupMember;
--            Remove_GroupMember;
--            Check_GroupMember;
--            --Get_AllGroupMember;
--
--      Resource and Group Access
--            Update_Access;
--
--            Update_ResourceApplAccess;
--            Update_ResourceChanAccess;
--            Update_ResourceCateAccess;
--            Update_ResourceItemAccess;
--            Update_GroupApplAccess;
--            Update_GroupChanAccess;
--            Update_GroupCateAccess;
--            Update_GroupItemAccess;
--
--            Get_ResourceApplAccess;
--            Get_ResourceChanAccess;
--            Get_ResourceCateAccess;
--            Get_ResourceItemAccess;
--            Get_GroupApplAccess;
--            Get_GroupChanAccess;
--            Get_GroupCateAccess;
--            Get_GroupItemAccess;
--            Get_ChannelsAccess;
--            --Check_ResourceViewCategory;
--            --Check_ResourceViewChannel;
--            --Check_ResourceViewItem;
--
-- NOTES
--
--
-- HISTORY
--   11/01/1999        PWU            created
--
--   06/30/2000        SHITIJ VATSA   UPDATED
--                     (svatsa)       Made the follwoing changes for Territory Privilege Integration
--                                    Created the following three global variables
--                                    1. G_CAN_SETUP_TERRITORY_NAME
--                                    2. G_CAN_SETUP_TERRITORY_CODE
--                                    3. G_CAN_SETUP_TERRITORY_ID
--
--                                    Modified the API Get_RoleIDArray to support Territory Intg
-- End of Comments
--
--
G_VERSION               CONSTANT    NUMBER    :=  1.0;
--
G_MES_ROLE_TYPE_NAME    CONSTANT    VARCHAR2(30) := 'MES';
G_MES_GROUP_USAGE       CONSTANT    VARCHAR2(30) := 'MES_GROUP';
G_RESOURCE_CATEGORY     CONSTANT    VARCHAR2(30) := 'EMPLOYEE';

G_ADMINISTRTOR_NAME     CONSTANT    VARCHAR2(30) := 'MES Administrator';
G_ADMINISTRTOR_CODE     CONSTANT    VARCHAR2(30) := 'MES_ADMIN';
G_ADMINISTRTOR_ID       NUMBER                   := FND_API.G_MISS_NUM;

G_CAN_PUBLISH_NAME      CONSTANT    VARCHAR2(30) := 'MES publish content';
G_CAN_PUBLISH_CODE      CONSTANT    VARCHAR2(30) := 'MES_PUBLISH';
G_CAN_PUBLISH_ID        NUMBER                   := FND_API.G_MISS_NUM;

G_CAN_APPROVE_NAME      CONSTANT    VARCHAR2(30) := 'MES approve content';
G_CAN_APPROVE_CODE      CONSTANT    VARCHAR2(30) := 'MES_APPROVE';
G_CAN_APPROVE_ID        NUMBER                   := FND_API.G_MISS_NUM;

G_CAN_SETUP_CHANNEL_NAME CONSTANT   VARCHAR2(30) := 'MES setup channel';
G_CAN_SETUP_CHANNEL_CODE CONSTANT   VARCHAR2(30) := 'MES_SETUP_CHANNEL';
G_CAN_SETUP_CHANNEL_ID  NUMBER                   := FND_API.G_MISS_NUM;

G_CAN_SETUP_CATEGORY_NAME CONSTANT  VARCHAR2(30) := 'MES setup category';
G_CAN_SETUP_CATEGORY_CODE CONSTANT  VARCHAR2(30) := 'MES_SETUP_CATEGORY';
G_CAN_SETUP_CATEGORY_ID NUMBER                   := FND_API.G_MISS_NUM;

G_CAN_SETUP_DIST_NAME   CONSTANT  VARCHAR2(30) := 'MES setup distribution rule';
G_CAN_SETUP_DIST_CODE   CONSTANT  VARCHAR2(30) := 'MES_SETUP_DIST_RULE';
G_CAN_SETUP_DIST_ID     NUMBER                   := FND_API.G_MISS_NUM;

-- Begin : Territory Integration
-- 06/30/2000 svatsa
G_CAN_SETUP_TERRITORY_NAME   CONSTANT  VARCHAR2(30) := 'MES publish territory';
G_CAN_SETUP_TERRITORY_CODE   CONSTANT  VARCHAR2(30) := 'MES_PUBLISH_TERRITORY';
G_CAN_SETUP_TERRITORY_ID     NUMBER                 := FND_API.G_MISS_NUM;
-- End : Territory Integration
--
G_GROUP_ARC_TYPE        CONSTANT VARCHAR2(30) := 'GROUP';
G_USER_ARC_TYPE         CONSTANT VARCHAR2(30) := 'USER';
G_ITEM_ARC_TYPE         CONSTANT VARCHAR2(30) := 'ITEM';
G_APPL_ARC_TYPE         CONSTANT VARCHAR2(30) := 'APPLICATION';
G_CHAN_ARC_TYPE         CONSTANT VARCHAR2(30) := 'CHANNEL';
G_CATE_ARC_TYPE         CONSTANT VARCHAR2(30) := 'CATEGORY';

--Type definitions

TYPE AMV_CHAR_VARRAY_TYPE IS TABLE OF VARCHAR2(4000);
	--INDEX BY BINARY_INTEGER;

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

TYPE amv_resource_obj_type IS RECORD(
      resource_id                  NUMBER,
      person_id                    NUMBER,
      user_name                    VARCHAR2(100),
      first_name                   VARCHAR2(40),
      last_name                    VARCHAR2(40)
);

TYPE amv_resource_obj_varray IS TABLE of amv_resource_obj_type;
	--INDEX BY BINARY_INTEGER;

TYPE amv_group_obj_type IS RECORD(
      group_id                  NUMBER,
      group_name                VARCHAR2(80),
      object_version_number     NUMBER,
      email_address             VARCHAR2(240),
      description               VARCHAR2(2000),
      effective_start_date      DATE,
      expiration_date           DATE
);

TYPE amv_group_obj_varray IS TABLE of amv_group_obj_type;
	--INDEX BY BINARY_INTEGER;

TYPE amv_access_obj_type IS RECORD(
      ACCESS_ID                     NUMBER,
      OBJECT_VERSION_NUMBER         NUMBER(9),
      ACCESS_TO_TABLE_CODE          VARCHAR2(30),
      ACCESS_TO_TABLE_RECORD_ID     NUMBER,
      USER_OR_GROUP_ID              NUMBER,
      USER_OR_GROUP_TYPE            VARCHAR2(30),
      EFFECTIVE_START_DATE          DATE,
      EXPIRATION_DATE               DATE,
      CAN_VIEW_FLAG                 VARCHAR2(1),
      CAN_CREATE_FLAG               VARCHAR2(1),
      CAN_DELETE_FLAG               VARCHAR2(1),
      CAN_UPDATE_FLAG               VARCHAR2(1),
      CAN_CREATE_DIST_RULE_FLAG     VARCHAR2(1),
      CHL_APPROVER_FLAG             VARCHAR2(1),
      CHL_REQUIRED_FLAG             VARCHAR2(1),
      CHL_REQUIRED_NEED_NOTIF_FLAG  VARCHAR2(1)
);

TYPE amv_access_obj_varray IS TABLE of amv_access_obj_type;
	--INDEX BY BINARY_INTEGER;

TYPE amv_access_flag_obj_type IS RECORD(
       CAN_VIEW_FLAG                 VARCHAR2(1),
       CAN_CREATE_FLAG               VARCHAR2(1),
       CAN_DELETE_FLAG               VARCHAR2(1),
       CAN_UPDATE_FLAG               VARCHAR2(1),
       CAN_CREATE_DIST_RULE_FLAG     VARCHAR2(1),
       CHL_APPROVER_FLAG             VARCHAR2(1),
       CHL_REQUIRED_FLAG             VARCHAR2(1),
       CHL_REQUIRED_NEED_NOTIF_FLAG  VARCHAR2(1)
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ResourceId
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get the resource id based on the passed user id.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_user_id                          NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 If default, use the current(login) user id
--    OUT          : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_resource_id                      NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--------------------------------------------------------------------------------
PROCEDURE Get_ResourceId
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    x_resource_id         OUT NOCOPY  NUMBER
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Resource
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Find resource given the search criteria.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Optional
--                       default FND_API.G_MISS_NUM
--                 p_check_effective_date             VARCHAR2  Optional
--                       default FND_API.G_TRUE
--                 p_user_name                        VARCHAR2  Optional
--                    default = FND_API.G_MISS_CHAR
--                 p_last_name                        VARCHAR2  Optional
--                    default = FND_API.G_MISS_CHAR
--                 p_first_name                       VARCHAR2  Optional
--                    default = FND_API.G_MISS_CHAR
--                 p_subset_request_obj               AMV_REQUEST_OBJ_TYPE
--                                                              Required.
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_subset_return_obj                AMV_RETURN_OBJ_TYPE
--                 x_resource_obj_array               AMV_RESOURCE_OBJ_VARRAY
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Find_Resource
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_last_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_first_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj   IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj    OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_resource_obj_array   OUT NOCOPY  AMV_RESOURCE_OBJ_VARRAY
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Resource
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Find resource given the search criteria.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Optional
--                       default FND_API.G_MISS_NUM
--                 p_check_effective_date             VARCHAR2  Optional
--                       default FND_API.G_TRUE
--                 p_user_name                        VARCHAR2  Optional
--                    default = FND_API.G_MISS_CHAR
--                 p_last_name                        VARCHAR2  Optional
--                    default = FND_API.G_MISS_CHAR
--                 p_first_name                       VARCHAR2  Optional
--                    default = FND_API.G_MISS_CHAR
--                 p_subset_request_obj               AMV_REQUEST_OBJ_TYPE
--                                                              Required.
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_subset_return_obj                AMV_RETURN_OBJ_TYPE
--                 x_resource_obj_array               AMV_RESOURCE_OBJ_VARRAY
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Find_Resource
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id          IN  NUMBER   := FND_API.G_MISS_NUM,
    p_resource_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj   IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj    OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_resource_obj_array   OUT NOCOPY  AMV_RESOURCE_OBJ_VARRAY,
    x_role_code_varray     OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ResourceRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Add a role to resource.
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
--                 p_resource_id                      NUMBER    Required
--                    the id of the resource
--                 p_role_id                          NUMBER    Optional
--                        Default  FND_API.G_MISS_NUM
--                 p_role_code                        VARCHAR2  Optional
--                        Default  FND_API.G_MISS_CHAR
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Add_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ResourceRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Add several roles to a resource.
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
--                 p_resource_id                      NUMBER    Required
--                 p_role_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                   array of role ids.                         Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Add_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Remove_ResourceRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Remove a role from a resource.
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
--                 p_resource_id                      NUMBER    Required
--                 p_role_id                          NUMBER    Optional
--                        Default  FND_API.G_MISS_NUM
--                 p_role_code                        VARCHAR2  Optional
--                        Default  FND_API.G_MISS_CHAR
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Remove_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Remove_ResourceRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Remove several roles from a resource.
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
--                        Default = null
--                 p_resource_id                      NUMBER    Required
--                 p_role_id_varray                   AMV_NUMBER_VARRAY_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Remove_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE := NULL
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Replace_ResourceRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Replace all the roles of a resource.
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
--                 p_resource_id                      NUMBER    Required
--                 p_role_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                   array of new role ids                      Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Replace_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
);
PROCEDURE Replace_ResourceRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_role_code           IN  VARCHAR2
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ResourceRoles
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the roles of a resource.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--                 p_check_effective_date             VARCHAR2  Optional
--                       default FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_role_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                 x_role_code_varray                 AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_ResourceRoles
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id          IN  NUMBER   := FND_API.G_MISS_NUM,
    x_role_id_varray       OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE,
    x_role_code_varray     OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Check_ResourceRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed resource has the passed role.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--                    If MISS, check the current (login) resource).
--                 p_role_id                          NUMBER    Required
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--                 p_check_effective_date             VARCHAR2  Optional
--                       default FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Check_ResourceRole
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id          IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_id              IN  NUMBER,
    p_group_usage          IN  VARCHAR2 := G_MES_GROUP_USAGE,
    p_include_group_flag   IN  VARCHAR2 := FND_API.G_TRUE,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag          OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_Administrator
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the resource is a administrator
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Is_Administrator
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Can_PublishContent
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the resource has publish content privelege.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Can_PublishContent
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Can_ApproveContent
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the resource has approve content privelege.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Can_ApproveContent
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Can_SetupChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the resource has setup channel privelege.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Can_SetupChannel
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Can_SetupCategory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the resource has setup category privelege.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Can_SetupCategory
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Can_SetupDistRule
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the resource has setup distribution privelege.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Can_SetupDistRule
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag         OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
----------------------------- GROUP PRIVELEGES ---------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_GroupRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Add a role to a group.
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
--                 p_group_id                         NUMBER    Required
--                    the id of the group
--                 p_role_id                          NUMBER    Optional
--                        Default  FND_API.G_MISS_NUM
--                 p_role_code                        VARCHAR2  Optional
--                        Default  FND_API.G_MISS_CHAR
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Add_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_GroupRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Add several roles to a group.
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
--                 p_group_id                         NUMBER    Required
--                    the id of the group
--                 p_role_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                   array of role ids.                         Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Add_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Remove_GroupRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Remove a role from a group.
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
--                 p_group_id                         NUMBER    Required
--                 p_role_id                          NUMBER    Optional
--                        Default  FND_API.G_MISS_NUM
--                 p_role_code                        VARCHAR2  Optional
--                        Default  FND_API.G_MISS_CHAR
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Remove_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id             IN  NUMBER   := FND_API.G_MISS_NUM,
    p_role_code           IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Remove_GroupRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Remove several roles from a group.
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
--                 p_group_id                         NUMBER    Required
--                 p_role_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                   array of role ids.                         Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Remove_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Replace_GroupRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Replace all the roles of a group.
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
--                 p_group_id                         NUMBER    Required
--                 p_role_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                   array of role ids.                         Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Replace_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_id_varray      IN  AMV_NUMBER_VARRAY_TYPE
);
PROCEDURE Replace_GroupRole
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_role_code           IN  VARCHAR2
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_GroupRoles
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the roles of a group.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Required
--                 p_check_effective_date             VARCHAR2  Optional
--                       default FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_role_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                 x_role_code_varray                 AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_GroupRoles
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id             IN  NUMBER,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    x_role_id_varray       OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE,
    x_role_code_varray     OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Check_GroupRole
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed group has the passed role.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Required
--                 p_role_id                          NUMBER    Required
--                 p_check_effective_date             VARCHAR2  Optional
--                       default FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Check_GroupRole
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id             IN  NUMBER,
    p_role_id              IN  NUMBER,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    x_result_flag          OUT NOCOPY  VARCHAR2
);
--------------------------------------------------------------------------------
---------------------------------- GROUP ---------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_Group
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create a resource group
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
--                 p_group_name                       VARCHAR2  Required
--                    group name are unique
--                 p_group_desc                       VARCHAR2  Optional
--                   default null
--                 p_start_date                       DATE      Optional
--                   default  null
--                 p_end_date                         DATE      Optional
--                  default   null
--                 p_owner_id                         NUMBER    Optional
--                  default   null
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_group_id                         NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Add_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_name          IN  VARCHAR2,
    p_group_desc          IN  VARCHAR2 := NULL,
    p_group_usage         IN  VARCHAR2,
    p_email_address       IN  VARCHAR2 := NULL,
    p_start_date          IN  DATE     := NULL,
    p_end_date            IN  DATE     := NULL,
    x_group_id            OUT NOCOPY  NUMBER
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Group
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update a resource group
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
--                 p_group_id                         NUMBER    Required
--                 p_new_group_name                   VARCHAR2  Optional
--                   default FND_API.G_MISS_CHAR
--                 p_new_group_desc                   VARCHAR2  Optional
--                   default FND_API.G_MISS_CHAR
--                 p_new_start_date                   DATE      Optional
--                   default  FND_API.G_MISS_DATE
--                 p_new_end_date                     DATE      Optional
--                  default   FND_API.G_MISS_DATE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_new_group_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_new_group_desc      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_usage         IN  VARCHAR2 := G_MES_GROUP_USAGE,
    p_email_address       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_new_start_date      IN  DATE     := FND_API.G_MISS_DATE,
    p_new_end_date        IN  DATE     := FND_API.G_MISS_DATE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Group
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete a resource group
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
--                 p_group_name                       VARCHAR2  Optional
--                   default FND_API.G_MISS_CHAR
--                 p_group_id                         NUMBER    Optional
--                   default FND_API.G_MISS_NUM
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Delete_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER   := FND_API.G_MISS_NUM,
    p_group_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Group
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get a resource group information based on the passed id.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_group_obj                        AMV_GROUP2_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    x_group_obj           OUT NOCOPY  AMV_GROUP_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Group
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Query for resource groups
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                       default FND_API.G_MISS_NUM,
--                 p_group_name                       VARCHAR2  Optional
--                   default FND_API.G_MISS_CHAR
--                 p_group_desc                       VARCHAR2  Optional
--                   default FND_API.G_MISS_CHAR
--                 p_owner_id                         NUMBER    Optional
--                  default   FND_API.G_MISS_NUM
--                 p_subset_request_obj               AMV_REQUEST_OBJ_TYPE
--                                                              Required.
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_subset_return_obj                AMV_RETURN_OBJ_TYPE
--                 x_resource_obj_array               AMV_RESOURCE_OBJ_VARRAY
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Find_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER   := FND_API.G_MISS_NUM,
    p_group_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_desc          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_email         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_usage         IN VARCHAR2,
    p_subset_request_obj  IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj   OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_group_obj_array     OUT NOCOPY  AMV_GROUP_OBJ_VARRAY
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Group
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Query for resource groups
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                      NUMBER    Optional
--                       default FND_API.G_MISS_NUM,
--                 p_group_name                       VARCHAR2  Optional
--                   default FND_API.G_MISS_CHAR
--                 p_group_desc                       VARCHAR2  Optional
--                   default FND_API.G_MISS_CHAR
--                 p_owner_id                         NUMBER    Optional
--                  default   FND_API.G_MISS_NUM
--                 p_subset_request_obj               AMV_REQUEST_OBJ_TYPE
--                                                              Required.
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_subset_return_obj                AMV_RETURN_OBJ_TYPE
--                 x_resource_obj_array               AMV_RESOURCE_OBJ_VARRAY
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Find_Group
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER   := FND_API.G_MISS_NUM,
    p_group_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_group_usage         IN VARCHAR2,
    p_subset_request_obj  IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj   OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_group_obj_array     OUT NOCOPY  AMV_GROUP_OBJ_VARRAY,
    x_role_code_varray     OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
);
--------------------------------------------------------------------------------
--------------------------- GROUP MEMBERSHIP  ----------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_GroupMember
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Add a resource to a group.
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
--                 p_group_id                         NUMBER    Required
--                    the id of the group
--                 p_resource_id                      NUMBER    Required
--                 p_start_date                       DATE      Optional
--                    default   NULL
--                 p_end_date                         DATE      Optional
--                    default   NULL
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Add_GroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_resource_id         IN  NUMBER
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_GroupMember
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Add a few resources to a group.
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
--                 p_group_id                         NUMBER    Required
--                 p_resource_id_varray               AMV_NUMBER_VARRAY_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Add_GroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_resource_id_varray  IN  AMV_NUMBER_VARRAY_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Remove_GroupMember
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Remove a resource from a group.
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
--                 p_group_id                         NUMBER    Required
--                    the id of the group
--                 p_resource_id                      NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Remove_GroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_resource_id         IN  NUMBER
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Remove_GroupMember
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Remove a few resources from a group.
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
--                 p_group_id                         NUMBER    Required
--                 p_resource_id_varray               AMV_NUMBER_VARRAY_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Remove_GroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_resource_id_varray  IN  AMV_NUMBER_VARRAY_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Check_GroupMember
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if a resource belong to a group.
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
--                 p_group_id                         NUMBER    Required
--                 p_resource_id                      NUMBER    Required
--                 p_check_effective_date             VARCHAR2  Optional
--                       default FND_API.G_TRUE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_result_flag                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Check_GroupMember
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id             IN  NUMBER,
    p_resource_id          IN  NUMBER,
    x_result_flag          OUT NOCOPY  VARCHAR2
);
/*
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_AllGroupMember
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all the group resources given the group.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Optional
--                       default FND_API.G_MISS_NUM,
--                 p_subset_request_obj               AMV_REQUEST_OBJ_TYPE
--                                                              Required.
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_subset_return_obj                AMV_RETURN_OBJ_TYPE
--                 x_resource_obj_array               AMV_RESOURCE_OBJ_VARRAY
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_AllGroupMember
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER   := FND_API.G_MISS_NUM,
    p_subset_request_obj  IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj   OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_resource_obj_array  OUT NOCOPY  AMV_RESOURCE_OBJ_VARRAY
);
*/
--------------------------------------------------------------------------------
--------------------------- RESOURCE  ACCESS  ----------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Access
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update the resource or group object access.
--                 Object can be application, channel, category, or item
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
--                 p_access_obj                       AMV_ACCESS_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_Access
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_access_obj          IN  AMV_ACCESS_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Access
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update the resource or group object access.
--                 Object can be application, channel, category, or item
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
--                 p_access_obj                       AMV_ACCESS_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_Access
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_access_obj_array    IN  AMV_ACCESS_OBJ_VARRAY
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_ResourceApplAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update all the accesses of a resource with an application
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
--                 p_resource_id                      NUMBER    Required
--                 p_application_id                   NUMBER    Required
--                 p_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_ResourceApplAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_application_id      IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_ResourceChanAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update all the accesses of a resource with a channel
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
--                 p_resource_id                      NUMBER    Required
--                 p_channel_id                       NUMBER    Required
--                 p_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_ResourceChanAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_channel_id          IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_ResourceCateAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update all the accesses of a resource with a category
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
--                 p_resource_id                      NUMBER    Required
--                 p_category_id                      NUMBER    Required
--                 p_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_ResourceCateAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_ResourceItemAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update all the accesses of a resource with a item
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
--                 p_resource_id                      NUMBER    Required
--                 p_item_id                          NUMBER    Required
--                 p_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_ResourceItemAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_item_id             IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_GroupApplAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update all the accesses of a group with an application
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
--                 p_group_id                         NUMBER    Required
--                 p_application_id                   NUMBER    Required
--                 p_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_GroupApplAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_group_id            IN  NUMBER,
    p_application_id      IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_GroupChanAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update all the accesses of a group with a channel
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
--                 p_group_id                         NUMBER    Required
--                 p_channel_id                       NUMBER    Required
--                 p_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_GroupChanAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_channel_id          IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_GroupCateAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update all the accesses of a group with a category
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
--                 p_group_id                         NUMBER    Required
--                 p_category_id                      NUMBER    Required
--                 p_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_GroupCateAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_GroupItemAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update all the accesses of a group with a item
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
--                 p_group_id                         NUMBER    Required
--                 p_item_id                          NUMBER    Required
--                 p_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :  This overloaded version is for (user/group) administrator
--                  page to use.
-- End of comments
--
PROCEDURE Update_GroupItemAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_item_id             IN  NUMBER,
    p_access_flag_obj     IN  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_BusinessObjectAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a resource/group
--                 with a business object
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_user_or_group_id                 NUMBER    Required
--                 p_user_or_group_type               VARCHAR2  Required
--                 p_business_object_id               NUMBER    Required
--                 p_business_object_type             VARCHAR2  Required
--                    here business object can be item, channel, category,
--                    and application
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_obj                       AMV_ACCESS_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_BusinessObjectAccess
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_or_group_id     IN  NUMBER,
    p_user_or_group_type   IN  VARCHAR2,
    p_business_object_id   IN  NUMBER,
    p_business_object_type IN  VARCHAR2,
    x_access_obj           OUT NOCOPY  AMV_ACCESS_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the channel access of a resource/group
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_user_or_group_id                 NUMBER    Required
--                 p_user_or_group_type               VARCHAR2  Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_channel_name_varray              AMV_CHAR_VARRAY_TYPE,
--                 x_access_obj_varray                AMV_ACCESS_OBJ_VARRAY
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_ChannelAccess
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_or_group_id     IN  NUMBER,
    p_user_or_group_type   IN  VARCHAR2,
    x_channel_name_varray  OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,
    x_access_obj_varray    OUT NOCOPY  AMV_ACCESS_OBJ_VARRAY
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_AccessPerChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the channel user/group access of a fixed channel
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_channel_id                       NUMBER    Required
--                 p_user_or_group_type               VARCHAR2  Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_name_varray                      AMV_CHAR_VARRAY_TYPE,
--                 x_access_obj_varray                AMV_ACCESS_OBJ_VARRAY
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_AccessPerChannel
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id           IN  NUMBER,
    p_user_or_group_type   IN  VARCHAR2,
    x_name_varray          OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,
    x_access_obj_varray    OUT NOCOPY  AMV_ACCESS_OBJ_VARRAY
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_BusinessObjectAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a resource/group
--                 with a business object
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_include_group_flag               VARCHAR2  Optional
--                    it is ignored for the resource. Only check for group.
--                         Default = FND_API.G_TRUE
--                 p_check_effective_date             VARCHAR2  Optional
--                       default FND_API.G_TRUE
--                 p_user_or_group_id                 NUMBER    Required
--                 p_user_or_group_type               VARCHAR2  Required
--                 p_business_object_id               NUMBER    Required
--                 p_business_object_type             VARCHAR2  Required
--                    here business object can be item, channel, category,
--                    and application
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_BusinessObjectAccess
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag   IN  VARCHAR2 := FND_API.G_TRUE,
    p_check_effective_date IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_or_group_id     IN  NUMBER,
    p_user_or_group_type   IN  VARCHAR2,
    p_business_object_id   IN  NUMBER,
    p_business_object_type IN  VARCHAR2,
    x_access_flag_obj      OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ResourceApplAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a resource with an application
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--                 p_resource_id                      NUMBER    Required
--                 p_application_id                   NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_ResourceApplAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_application_id      IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ResourceChanAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a resource with an channel
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--                 p_resource_id                      NUMBER    Required
--                 p_channel_id                       NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_ResourceChanAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_channel_id          IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ResourceCateAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a resource with an category
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--                 p_resource_id                      NUMBER    Required
--                 p_category_id                      NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_ResourceCateAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_category_id         IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ResourceItemAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a resource with an item
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_include_group_flag               VARCHAR2  Optional
--                         Default = FND_API.G_TRUE
--                 p_resource_id                      NUMBER    Required
--                 p_item_id                          NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_ResourceItemAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_include_group_flag  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id         IN  NUMBER,
    p_item_id             IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_GroupApplAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a group with an application
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Required
--                 p_application_id                   NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_GroupApplAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_application_id      IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_GroupChanAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a group with an channel
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Required
--                 p_channel_id                       NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_GroupChanAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_channel_id          IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_GroupCateAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a group with an category
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Required
--                 p_category_id                      NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_GroupCateAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_category_id         IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_GroupItemAccess
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Retrieve all the access of a group with an item
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_group_id                         NUMBER    Required
--                 p_item_id                          NUMBER    Required
--    OUT         : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_access_flag_obj                  AMV_ACCESS_FLAG_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_ResourceItemAccess
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_group_id            IN  NUMBER,
    p_item_id             IN  NUMBER,
    x_access_flag_obj     OUT NOCOPY  AMV_ACCESS_FLAG_OBJ_TYPE
);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_user_pvt;

 

/
