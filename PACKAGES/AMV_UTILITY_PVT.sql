--------------------------------------------------------
--  DDL for Package AMV_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvutls.pls 120.1 2005/06/30 13:34:10 appldev ship $ */
-- Start of Comments
--
-- NAME
--   AMV_UTILITY_PVT
--
-- PURPOSE
--   This package is a private utility API in AMV.  It contains helper
--   procedures which are used by several packages in MES to achiev code
--   re-usability. It contains specification for pl/sql records, array,
--   and procedures.
--
--   Procedures:
--
-- NOTES
--
--
-- HISTORY
--   06/01/1999        PWU            created
-- End of Comments
--
------------------------------
-- Global Package Variables --
------------------------------
  --G_MES_APPLICATION_ID    CONSTANT    NUMBER   := 520;
  G_MAX_VARRAY_SIZE       CONSTANT    NUMBER   := 5000;
  G_USER_NOT_EXIST        CONSTANT    VARCHAR2(30) := 'NOTEXIST';
  G_USER_NOT_LOGIN        CONSTANT    VARCHAR2(30) := 'NOTLOGIN';
  G_NO_RESOURCE           CONSTANT    VARCHAR2(30) := 'NORESOURCE';
  --G_ENABLE                CONSTANT    VARCHAR2(30) := 'ACTIVE';
  --G_DISABLE               CONSTANT    VARCHAR2(30) := 'INACTIVE';
  --G_APPROVED              CONSTANT    VARCHAR2(30) := 'APPROVED';
  --G_DISAPPROVED           CONSTANT    VARCHAR2(30) := 'REJECTED';
  --G_WAITFORAPPROVAL       CONSTANT    VARCHAR2(30) := 'NEED_APPROVAL';
  --G_NEEDREWORK            CONSTANT    VARCHAR2(30) := 'MORE_INFO';
  G_USER_ENABLE           CONSTANT    NUMBER   := 0;
  G_USER_DISABLE          CONSTANT    NUMBER   := 1;
  G_NOT_EXIST             CONSTANT    NUMBER   := 2;
  G_NOT_LOGIN             CONSTANT    NUMBER   := 3;
  G_VALID_LEVEL_LOGIN     CONSTANT    NUMBER   := 50;
  G_VALID_LEVEL_VALID_ID  CONSTANT    NUMBER   := 10;
--
G_AMV_APP_ID	CONSTANT	NUMBER := 520;
G_CONTENT	CONSTANT VARCHAR2(30) := 'CONTENT';
G_GROUP		CONSTANT VARCHAR2(30) := 'GROUP';
G_USER		CONSTANT VARCHAR2(30) := 'USER';
G_PUBLIC	CONSTANT VARCHAR2(30) := 'PUBLIC';
G_PRIVATE	CONSTANT VARCHAR2(30) := 'PRIVATE';
G_PROTECTED	CONSTANT VARCHAR2(30) := 'PROTECTED';
G_CATEGORY	CONSTANT VARCHAR2(30) := 'CATEGORY';
G_CHANNEL	CONSTANT VARCHAR2(30) := 'CHANNEL';
G_ITEM		CONSTANT VARCHAR2(30) := 'ITEM';
G_APPLICATION	CONSTANT VARCHAR2(30) := 'APPLICATION';
G_SUBSCRIBED	CONSTANT VARCHAR2(30) := 'SUBSCRIBED';
G_ENFORCED	CONSTANT VARCHAR2(30) := 'ENFORCED';
G_ACTIVE	CONSTANT VARCHAR2(30) := 'ACTIVE';
G_INACTIVE	CONSTANT VARCHAR2(30) := 'INACTIVE';
G_NEED_APPROVAL	CONSTANT VARCHAR2(30) := 'NEED_APPROVAL';
G_APPROVED	CONSTANT VARCHAR2(30) := 'APPROVED';
G_REJECTED	CONSTANT VARCHAR2(30) := 'REJECTED';
G_MORE_INFO	CONSTANT VARCHAR2(30) := 'MORE_INFO';
G_PUB_APPROVAL	CONSTANT VARCHAR2(30) := 'AMV_CONTENT_APPROVAL';
G_SUB_APPROVAL	CONSTANT VARCHAR2(30) := 'AMV_SUBSCRIPTION_APPROVAL';
G_DEFAULT	CONSTANT VARCHAR2(30) := 'DEFAULT';
G_OWNER		CONSTANT VARCHAR2(30) := 'OWNER';
G_SECONDARY	CONSTANT VARCHAR2(30) := 'SECONDARY';
G_DONE		CONSTANT VARCHAR2(30) := 'DONE';
G_PUSH 		CONSTANT    VARCHAR2(30) := 'PUSH';
G_MATCH     	CONSTANT    VARCHAR2(30) := 'MATCH';
G_TABLE_NAME_CODE  CONSTANT    VARCHAR2(30) := 'ITEM';

-----------------------------------
-- System-wide record structures --
-----------------------------------
/*
TYPE AMV_NUMBER_ARRAY_TYPE    is varray(5000) of number;
TYPE AMV_CHAR_ARRAY_TYPE      is varray(5000) of varchar2(2000);
--
TYPE record_subset_request_rec_type IS RECORD (
  records_requested               NUMBER := G_MAX_VARRAY_SIZE,
  start_record_position           NUMBER := 1,
  return_total_count_flag         VARCHAR2(1) := FND_API.G_FALSE
);
--
TYPE record_subset_return_rec_type IS RECORD
(
  returned_record_count           NUMBER,
  next_record_position            NUMBER,
  total_record_count              NUMBER
);
--
TYPE amv_perspective_rec_type IS RECORD
(
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
TYPE amv_perspective_rec_varray   is varray(5000) of amv_perspective_rec_type;
--
TYPE amv_content_type_rec_type IS RECORD
(
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
TYPE amv_content_type_rec_varray   is varray(5000) of amv_content_type_rec_type;
--
TYPE amv_item_rec_type IS RECORD
(
  item_id                   NUMBER,
  object_version_number     NUMBER,
  creation_date             DATE,
  created_by                NUMBER,
  last_update_date          DATE,
  last_updated_by           NUMBER,
  last_update_login         NUMBER,
  application_id            NUMBER,
  title                     VARCHAR2(240),
  description               VARCHAR2(2000),
  text_string               VARCHAR2(2000),
  language_code             VARCHAR2(4),
  status_code               VARCHAR2(30),
  owner_user_id             NUMBER,
  effective_start_date      DATE,
  expiration_date           DATE,
  item_type                 VARCHAR2(240),
  content_type_id           NUMBER,
  publication_date          DATE,
  priority                  VARCHAR2(30),
  default_approver_id       NUMBER,
  url_string                VARCHAR2(2000),
  item_destination_type     VARCHAR2(240),
  file_id_varray            AMV_NUMBER_VARRAY_TYPE,
  persp_id_varray           AMV_NUMBER_VARRAY_TYPE,
  persp_name_varray         AMV_CHAR_VARRAY_TYPE,  --Provide it for convenience.
  author_varray             AMV_CHAR_VARRAY_TYPE,
  keyword_varray            AMV_CHAR_VARRAY_TYPE
);
--
TYPE amv_simple_item_rec_type IS RECORD
(
  item_id                   NUMBER,
  object_version_number     NUMBER,
  creation_date             DATE,
  created_by                NUMBER,
  last_update_date          DATE,
  last_updated_by           NUMBER,
  last_update_login         NUMBER,
  application_id            NUMBER,
  title                     VARCHAR2(240),
  description               VARCHAR2(4000),
  text_string               VARCHAR2(4000),
  language_code             VARCHAR2(4),
  status_code               VARCHAR2(30),
  owner_user_id             NUMBER,
  effective_start_date      DATE,
  expiration_date           DATE,
  item_type                 VARCHAR2(240),
  content_type_id           NUMBER,
  publication_date          DATE,
  priority                  VARCHAR2(30),
  default_approver_id       NUMBER,
  url_string                VARCHAR2(2000),
  item_destination_type     VARCHAR2(240),
  file_id_list              VARCHAR2(4000),
  persp_id_list             VARCHAR2(4000),
  persp_name_list           VARCHAR2(4000),  --Provide it for convenience.
  author_list               VARCHAR2(4000),
  keyword_list              VARCHAR2(4000)
);
TYPE amv_simple_item_rec_varray  IS VARRAY(5000) of amv_simple_item_rec_type;
--
TYPE amv_group_rec_type IS RECORD
(
  group_id                  NUMBER,
  group_name                VARCHAR2(80),
  description               VARCHAR2(2000),
  owner_user_id             NUMBER,
  effective_start_date      DATE,
  expiration_date           DATE
);
TYPE amv_group_rec_varray IS VARRAY(5000) of amv_group_rec_type;
--
TYPE amv_resource_rec_type IS RECORD
(
  resource_id                  NUMBER,
  person_id                    NUMBER,
  user_name                    VARCHAR2(100),
  first_name                   VARCHAR2(40),
  last_name                    VARCHAR2(40)
);
TYPE amv_resource_rec_varray IS VARRAY(5000) of amv_resource_rec_type;
--
TYPE amv_access_flag_rec_type IS RECORD
(
   CAN_VIEW_FLAG                 VARCHAR2(1),
   CAN_CREATE_FLAG               VARCHAR2(1),
   CAN_DELETE_FLAG               VARCHAR2(1),
   CAN_UPDATE_FLAG               VARCHAR2(1),
   CAN_CREATE_DIST_RULE_FLAG     VARCHAR2(1),
   CHL_APPROVER_FLAG             VARCHAR2(1),
   CHL_REQUIRED_FLAG             VARCHAR2(1),
   CHL_REQUIRED_NEED_NOTIF_FLAG  VARCHAR2(1)
);
--
TYPE amv_access_rec_type IS RECORD
(
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
TYPE amv_access_rec_varray IS VARRAY(5000) of amv_access_rec_type;
*/
--
-------------------------------------
-- System-wide Initialized Records --
-------------------------------------
  --init_record_subset_request_rec  record_subset_request_rec_type;
  --init_record_subset_return_rec   record_subset_return_rec_type;
-----------------------------
-- System-wide collections --
-----------------------------
--
------------------------------------
-- Group Functions and Procedures --
------------------------------------
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Print_debug_message
--    Type       : Private
--    Pre-reqs   : None
--    Function   : This procedure use dbms_output.put_line
--                 to print out the passed message
--                 Reformat: each line is at most 70 characters long.
--    Parameters :
--    IN         : p_message                 VARCHAR2      REQUIRED
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This procedure  will change to do nothing in production.
-- End of comments
--
PROCEDURE Print_debug_message
(
    p_message IN  VARCHAR2
);
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserInfo
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check and return (login) user status.
--    Parameters :
--    IN         : p_user_id                          NUMBER    Optional
--                    user id. Default = FND_API.G_MISS_NUM
--                    If user id is missing, use the current (login) user id.
--    OUT        : x_resource_id                      NUMBER
--                    resource id of the user if the user exist.
--               : x_user_id                          NUMBER
--                    user id which is valid if user is exist.
--               : x_login_id                         NUMBER
--                    the current login id (unique per section) if logined.
--               : x_user_status                      VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Get_UserInfo
(
    p_user_id        IN  NUMBER := FND_API.G_MISS_NUM,
    x_resource_id    OUT NOCOPY NUMBER,
    x_user_id        OUT NOCOPY NUMBER,
    x_login_id       OUT NOCOPY NUMBER,
    x_user_status    OUT NOCOPY VARCHAR2
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ResourceId
--    Type       : Private
--    Pre-reqs   : None
--    Function   :  return the resource id associated with the user id.
--                  basically, it translates the user id into resource id.
--    Parameters :
--    IN         : p_user_id                           NUMBER   required
--    OUT        : x_resource_id                       NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Get_ResourceId
(
    p_user_id      IN  NUMBER,
    x_resource_id  OUT NOCOPY NUMBER
);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_LoginUserId
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Call Standard API to check if user is login.
--                 If so, it returns the login user id.
--                 Otherwise, it returns FND_API.G_MISS_NUM.
--    Parameters :
--    IN         : None
--    OUT        : x_current_user_id                  NUMBER
--                    the current (login) user id.
--               : x_current_login_id                 NUMBER
--                    the current login id (unique per section).
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This procedure return the global variable for currnet
--                 user id and login id.
-- End of comments
--
PROCEDURE Get_LoginUserId
(
    x_current_user_id   OUT NOCOPY NUMBER,
    x_current_login_id  OUT NOCOPY NUMBER
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check and return (login) user status.
--    Parameters :
--    IN         : p_user_id                          NUMBER    Optional
--                    user id. Default = FND_API.G_MISS_NUM
--                    If user id is missing, use the current (login) user id.
--    OUT        : x_user_id                          NUMBER
--                    user id which is valid if user is exist.
--               : x_login_id                         NUMBER
--                    the current login id (unique per section) if logined.
--               : x_user_status                      NUMBER
--                 values: G_ACTIVE, G_INACTIVE, G_NOT_EXIST.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Get_UserStatus
(
    p_user_id        IN  NUMBER := FND_API.G_MISS_NUM,
    x_user_id        OUT NOCOPY NUMBER,
    x_login_id       OUT NOCOPY NUMBER,
    x_user_status    OUT NOCOPY NUMBER
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_ItemIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed item id is valid.
--    Parameters :
--    IN         : p_item_id                          NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_ItemIdValid(p_item_id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_ChannelIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed channel id is valid.
--    Parameters :
--    IN         : p_channel_id                       NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_ChannelIdValid(p_channel_id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_CategoryIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed category id is valid.
--    Parameters :
--    IN         : p_category_id                       NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_CategoryIdValid(p_category_id IN NUMBER) RETURN Boolean;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_ApplIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed application id is valid.
--    Parameters :
--    IN         : p_application_id                   NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_ApplIdValid(p_application_id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_PerspectiveIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed perspective id is valid.
--    Parameters :
--    IN         : p_perspective_id                   NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_PerspectiveIdValid(p_perspective_id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_ContentTypeIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed content type id is valid.
--    Parameters :
--    IN         : p_content_type_id                  NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_ContentTypeIdValid(p_Content_Type_Id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_RoleIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed role id is valid.
--    Parameters :
--    IN         : p_role_id                          NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_RoleIdValid(p_role_id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_ResourceIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed resource id is valid.
--    Parameters :
--    IN         : p_resource_id                      NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_ResourceIdValid(p_resource_id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_NotificationIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed notification id is valid.
--    Parameters :
--    IN         : p_notification_id                  NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_NotificationIdValid(p_notification_id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Is_GroupIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed group id is valid.
--    Parameters :
--    IN         : p_group_id                         NUMBER   Requried
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       : This is a function returning a boolean. Not a procedure.
-- End of comments
--
FUNCTION Is_GroupIdValid(p_group_id IN NUMBER) RETURN Boolean;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Is_UserIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if user id is valid and return a boolean value.
--    Parameters :
--            IN : p_user_id    	IN  NUMBER  Required
--			user id
--	     OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Is_UserIdValid (
  p_user_id IN NUMBER
)
RETURN Boolean;
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Is_MyChannelIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if my channel id is valid and return boolean.
--    Parameters :
--            IN : p_mychannel_id  	IN  NUMBER  Required
--	     OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Is_MyChannelIdValid (
  p_mychannel_id IN NUMBER
)
RETURN Boolean;
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_DeleteChannelStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if user or group has privilege to delete a channel
--			return boolean.
--    Parameters :
--            IN : p_channel_id  	IN  NUMBER  Required
--            IN : p_user_or_group_id  	IN  NUMBER  Required
--            IN : p_user_or_group_type IN  VARCHAR2  Required
--	     OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
--
FUNCTION Get_DeleteChannelStatus
(    p_channel_id               IN      NUMBER,
     p_user_or_group_id      IN      NUMBER,
     p_user_or_group_type IN  VARCHAR2) return boolean;
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_UpdateChannelStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if user or group has privilege to update a channel
--			return boolean.
--    Parameters :
--            IN : p_channel_id  	IN  NUMBER  Required
--            IN : p_user_or_group_id  	IN  NUMBER  Required
--            IN : p_user_or_group_type IN  VARCHAR2  Required
--	     OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
FUNCTION Get_UpdateChannelStatus
(    p_channel_id               IN      NUMBER,
     p_user_or_group_id      IN      NUMBER,
     p_user_or_group_type IN  VARCHAR2) return boolean;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_DeleteCategoryStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if user or group has privilege to delete a category
--			return boolean.
--    Parameters :
--            IN : p_category_id  	IN  NUMBER  Required
--            IN : p_user_or_group_id  	IN  NUMBER  Required
--            IN : p_user_or_group_type IN  VARCHAR2  Required
--	     OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Get_DeleteCategoryStatus
(    p_category_id           	IN      NUMBER,
     p_user_or_group_id      	IN      NUMBER,
     p_user_or_group_type 	IN  VARCHAR2) return boolean;
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_UpdateCategoryStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if user or group has privilege to update a category
--			return boolean.
--    Parameters :
--            IN : p_category_id  	IN  NUMBER  Required
--            IN : p_user_or_group_id  	IN  NUMBER  Required
--            IN : p_user_or_group_type IN  VARCHAR2  Required
--	     OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
FUNCTION Get_UpdateCategoryStatus
(    p_category_id           	IN      NUMBER,
     p_user_or_group_id      	IN      NUMBER,
     p_user_or_group_type 	IN  VARCHAR2) return boolean;
--
END amv_utility_pvt;

 

/
