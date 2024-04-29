--------------------------------------------------------
--  DDL for Package Body AMV_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_UTILITY_PVT" AS
/* $Header: amvvutlb.pls 120.1 2005/06/21 16:54:22 appldev ship $ */
--
-- NAME
--   AMV_UTILITY_PVT
--
-- HISTORY
--   06/01/1999        PWU        CREATED
--
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMV_UTILITY_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amvvutlb.pls';

-- Debug mode
--g_debug boolean := FALSE;
g_debug boolean := TRUE;
G_VALID_LEVEL_LOGIN CONSTANT    NUMBER := FND_API.G_VALID_LEVEL_FULL;
--

------------------------------------
-- Functions and Procedures --
------------------------------------
---- (Real) Private Procedures ----
-- All these private procedures does not have real complete error handling.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Print_debug_message
--    Type       : Private
--    Pre-reqs   : None
--    Function   : This procedure use
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
) AS
--
l_str_length     INTEGER;
l_index          INTEGER := 1;
l_linesize       CONSTANT INTEGER := 70;
--
BEGIN
     l_str_length := LENGTH(p_message);
     FOR i in 1..l_str_length/l_linesize LOOP
       l_index := l_index + l_linesize;
     END LOOP;
--
END Print_debug_message;
--------------------------------------------------------------------------------
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
    x_resource_id  OUT NOCOPY  NUMBER
)  AS
CURSOR Get_resourceID_csr IS
Select resource_id
From jtf_rs_resource_extns
Where user_id = p_user_id
--And   u.employee_id = r.source_id
--And  r.category = 'EMPLOYEE'
;

BEGIN
     OPEN  Get_resourceID_csr;
     FETCH Get_resourceID_csr INTO x_resource_id;
     IF (Get_resourceID_csr%NOTFOUND) THEN
         x_resource_id := FND_API.G_MISS_NUM;
     END IF;
     CLOSE Get_resourceID_csr;
END Get_ResourceId;
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
--                 user id and login id.  It need further examined.
-- End of comments
--
PROCEDURE Get_LoginUserId
(
    x_current_user_id   OUT NOCOPY  NUMBER,
    x_current_login_id  OUT NOCOPY  NUMBER
) AS
BEGIN
      -- To be furhter examined.
      x_current_user_id  := FND_GLOBAL.User_Id;
      x_current_login_id := FND_GLOBAL.Login_Id;
      IF (x_current_user_id IS NULL OR x_current_user_id = -1) THEN
          x_current_user_id  := FND_API.G_MISS_NUM;
          x_current_login_id := FND_API.G_MISS_NUM;
      END IF;
END Get_LoginUserId;
--
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
    x_resource_id    OUT NOCOPY  NUMBER,
    x_user_id        OUT NOCOPY  NUMBER,
    x_login_id       OUT NOCOPY  NUMBER,
    x_user_status    OUT NOCOPY  VARCHAR2
) AS
l_user_id       NUMBER;
l_login_id      NUMBER;
--
CURSOR Fnd_User_csr (p_id in number) is
Select
    user_name
From   fnd_user
Where  user_id = p_id;
l_fnd_user_info  Fnd_User_csr%ROWTYPE;
--
BEGIN
    --Get the current login user id.
    Get_LoginUserId(l_user_id, l_login_id);
    -- If p_user_id is not the current login user.
    IF (p_user_id <> FND_API.G_MISS_NUM AND p_user_id <> l_user_id ) THEN
        OPEN  Fnd_User_csr(p_user_id);
        FETCH Fnd_User_csr into l_fnd_user_info;
        IF Fnd_User_csr%NOTFOUND THEN
            x_user_status := G_USER_NOT_EXIST;
            x_user_id     := FND_API.G_MISS_NUM;
            x_resource_id := FND_API.G_MISS_NUM;
            x_login_id    := FND_API.G_MISS_NUM;
        ELSE
            x_user_id     := p_user_id;
            x_login_id    := FND_API.G_MISS_NUM;
            x_user_status := G_USER_NOT_LOGIN;
            --Get the resource id
            Get_ResourceId ( p_user_id, x_resource_id);
            IF (x_resource_id = FND_API.G_MISS_NUM) THEN
                 x_user_status := G_NO_RESOURCE;
            END IF;
        END IF;
        CLOSE Fnd_User_csr;
    ELSE
        x_user_status := G_ACTIVE;
        x_user_id  := l_user_id;
        x_login_id := l_login_id;
        --Get the resource id
        Get_ResourceId ( l_user_id, x_resource_id);
        IF (x_resource_id = FND_API.G_MISS_NUM) THEN
            x_user_status := G_NO_RESOURCE;
        END IF;
    END IF;
EXCEPTION
   WHEN OTHERS THEN
       x_user_status := G_USER_NOT_EXIST;
       x_user_id     := FND_API.G_MISS_NUM;
       x_resource_id := FND_API.G_MISS_NUM;
       x_login_id    := FND_API.G_MISS_NUM;
END Get_UserInfo;
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
--    Note       :  If a user is in AOL (FND) but not on MES, this procedure
--                  call a user profile api to do default setup in MES.
--
-- End of comments
--
PROCEDURE Get_UserStatus
(
    p_user_id        IN  NUMBER := FND_API.G_MISS_NUM,
    x_user_id        OUT NOCOPY  NUMBER,
    x_login_id       OUT NOCOPY  NUMBER,
    x_user_status    OUT NOCOPY  NUMBER
) AS
l_user_id       NUMBER;
l_login_id      NUMBER;
--
CURSOR Fnd_User_csr (p_id in number) is
Select
    user_id, user_name
From   fnd_user
Where  user_id = p_id;
l_fnd_user_info  Fnd_User_csr%ROWTYPE;
--
BEGIN
    --Get the current login user id.
    Get_LoginUserId(l_user_id, l_login_id);
    -- If p_user_id is not the current login user.
    IF (p_user_id <> FND_API.G_MISS_NUM AND
        p_user_id <> l_user_id ) THEN
        OPEN  Fnd_User_csr(p_user_id);
        FETCH Fnd_User_csr into l_fnd_user_info;
        IF Fnd_User_csr%NOTFOUND THEN
            x_user_status := G_NOT_EXIST;
            x_user_id := FND_API.G_MISS_NUM;
            x_login_id := FND_API.G_MISS_NUM;
        ELSE
            x_user_status := G_USER_ENABLE;
            x_user_id     := p_user_id;
            x_login_id    := FND_API.G_MISS_NUM;
        END IF;
        CLOSE Fnd_User_csr;
    ELSE
        x_user_status := G_USER_ENABLE;
        x_user_id  := l_user_id;
        x_login_id := l_login_id;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_user_status := G_NOT_EXIST;
       x_user_id  := FND_API.G_MISS_NUM;
       x_login_id := FND_API.G_MISS_NUM;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_user_status := G_NOT_EXIST;
       x_user_id  := FND_API.G_MISS_NUM;
       x_login_id := FND_API.G_MISS_NUM;
   WHEN OTHERS THEN
       x_user_status := G_NOT_EXIST;
       x_user_id  := FND_API.G_MISS_NUM;
       x_login_id := FND_API.G_MISS_NUM;
END Get_UserStatus;
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
FUNCTION Is_ItemIdValid
(
    p_item_id IN NUMBER
) RETURN Boolean  AS
--
CURSOR Check_ItemID_csr is
Select item_id
From   jtf_amv_items_vl
where  item_id = p_item_id;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_ItemID_csr;
  FETCH Check_ItemID_csr INTO l_tmp_number;
  IF (Check_ItemID_csr%NOTFOUND) THEN
     l_valid_flag := FALSE;
  ELSE
     l_valid_flag := TRUE;
  END IF;
  CLOSE Check_ItemID_csr;
  return l_valid_flag;
END Is_ItemIdValid;
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
FUNCTION Is_ChannelIdValid
(
    p_channel_id IN NUMBER
) RETURN Boolean  AS
--
CURSOR Check_ChannelID_csr is
Select channel_id
From   amv_c_channels_b
where  channel_id = p_channel_id;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_ChannelID_csr;
  FETCH Check_ChannelID_csr INTO l_tmp_number;
  IF (Check_ChannelID_csr%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE Check_ChannelID_csr;
  return l_valid_flag;
END Is_ChannelIdValid;
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
FUNCTION Is_CategoryIdValid
(
   p_category_id IN NUMBER
) RETURN Boolean  AS
--
CURSOR Check_CategoryID_csr is
Select channel_category_id
From   amv_c_categories_b
where  channel_category_id = p_category_id;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_CategoryID_csr;
  FETCH Check_CategoryID_csr INTO l_tmp_number;
  IF (Check_CategoryID_csr%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE Check_CategoryID_csr;
  return l_valid_flag;
END Is_CategoryIdValid;
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
FUNCTION Is_ApplIdValid
(
    p_application_id IN NUMBER
) RETURN Boolean  AS
--
CURSOR Check_ApplicationID_csr is
Select application_id
From   fnd_application
where  application_id = p_application_id;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_ApplicationID_csr;
  FETCH Check_ApplicationID_csr INTO l_tmp_number;
  IF (Check_ApplicationID_csr%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE Check_ApplicationID_csr;
  return l_valid_flag;
END Is_ApplIdValid;
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
FUNCTION Is_PerspectiveIdValid
(
    p_perspective_id IN NUMBER
) RETURN Boolean AS
--
CURSOR Check_PerspectiveID_csr is
Select perspective_id
From   amv_i_perspectives_b
where  perspective_id = p_perspective_id;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_PerspectiveID_csr;
  FETCH Check_PerspectiveID_csr INTO l_tmp_number;
  IF (Check_PerspectiveID_csr%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE Check_PerspectiveID_csr;
  return l_valid_flag;
END Is_PerspectiveIdValid;
--
--
-----------------------------------------------------------------------------
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
FUNCTION Is_ContentTypeIdValid
(
    p_content_type_Id IN NUMBER
) RETURN Boolean AS
--
--
CURSOR Check_ContentTypeID_csr is
Select content_type_id
From   amv_i_content_types_b
where  content_type_id = p_content_type_id;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_ContentTypeID_csr;
  FETCH Check_ContentTypeID_csr INTO l_tmp_number;
  IF (Check_ContentTypeID_csr%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE Check_ContentTypeID_csr;
  return l_valid_flag;
END Is_ContentTypeIdValid;
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
FUNCTION Is_RoleIdValid
(
    p_role_id IN NUMBER
) RETURN Boolean AS
CURSOR Check_RoleID_csr is
Select role_id
From   jtf_rs_roles_vl
Where  role_id = p_role_id
; --And    role_type_id = AMV_USER_PVT.G_MES_ROLE_TYPE_ID;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_RoleID_csr;
  FETCH Check_RoleID_csr INTO l_tmp_number;
  IF (Check_RoleID_csr%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE Check_RoleID_csr;
  return l_valid_flag;
END Is_RoleIdValid;
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
FUNCTION Is_ResourceIdValid
(
    p_resource_id IN NUMBER
) RETURN Boolean AS
CURSOR Check_ResourceID_csr is
Select resource_id
From   jtf_rs_resource_extns
Where  resource_id = p_resource_id
--And    category = AMV_USER_PVT.G_RESOURCE_CATEGORY
;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_ResourceID_csr;
  FETCH Check_ResourceID_csr INTO l_tmp_number;
  IF (Check_ResourceID_csr%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE Check_ResourceID_csr;
  return l_valid_flag;
END Is_ResourceIdValid;
--
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
FUNCTION Is_NotificationIdValid
(
    p_notification_id IN NUMBER
) RETURN Boolean AS
--
BEGIN
     return TRUE;
END Is_NotificationIdValid;
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
FUNCTION Is_GroupIdValid
(
    p_group_id IN NUMBER
) RETURN Boolean  AS
--
CURSOR C_Check_Group_id is
Select group_id
From   jtf_rs_groups_vl
where  group_id = p_group_id
--And    usage = AMV_USER_PVT.G_MES_GROUP_USAGE
;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  C_Check_Group_id;
  FETCH C_Check_Group_id INTO l_tmp_number;
  IF (C_Check_Group_id%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE C_Check_Group_id;
  return l_valid_flag;
END Is_GroupIdValid;
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
RETURN Boolean
IS
l_valid_flag	number;
CURSOR
Check_UserId_csr IS
select count(*)
from   jtf_rs_resource_extns
where  resource_id = p_user_id;
BEGIN
 OPEN Check_UserId_csr;
  FETCH Check_UserId_csr INTO l_valid_flag;
 CLOSE Check_UserId_csr;
 IF l_valid_flag > 0 THEN
	return TRUE;
 ELSE
	return FALSE;
 END IF;
END Is_UserIdValid;
--
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
RETURN Boolean
IS
l_valid_flag	number := 1;
CURSOR
Check_MyChannelId_csr IS
select count(*)
from   amv_u_my_channels
where  my_channel_id = p_mychannel_id;
BEGIN
 OPEN Check_MyChannelId_csr;
  FETCH Check_MyChannelId_csr INTO l_valid_flag;
 CLOSE Check_MyChannelId_csr;
 IF l_valid_flag > 0 THEN
	return TRUE;
 ELSE
	return FALSE;
 END IF;
END Is_MyChannelIdValid;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_DeleteChannelStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if an user or group can delete a channel
--    Parameters :
--	IN
--                 p_channel_id    	IN  NUMBER    Required
--                 p_user_or_group_id  	IN  NUMBER    Required
--                 p_user_or_group_type IN  NUMBER    Required
--	OUT
--		Boolean
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
FUNCTION Get_DeleteChannelStatus
(    p_channel_id		IN  	NUMBER,
	p_user_or_group_id	IN	NUMBER,
	p_user_or_group_type IN  VARCHAR2) return boolean
IS
--
l_flag	varchar2(1);

CURSOR DelChanAccs_csr IS
select can_delete_flag
from	  amv_u_access
where  access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
and	  access_to_table_record_id = p_channel_id
and	  user_or_group_id = p_user_or_group_id
and	  user_or_group_type = p_user_or_group_type;
--
BEGIN
	--
	OPEN DelChanAccs_csr;
		FETCH DelChanAccs_csr INTO l_flag;
		IF DelChanAccs_csr%NOTFOUND THEN
			l_flag := FND_API.G_FALSE;
		END IF;
	CLOSE DelChanAccs_csr;

	IF l_flag = FND_API.G_TRUE THEN
		return TRUE;
	ELSE
		return FALSE;
	END IF;
	--
END Get_DeleteChannelStatus;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UpdateChannelStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if an user or group can update a channel
--    Parameters :
--	IN
--                 p_channel_id    	IN  NUMBER    Required
--                 p_user_or_group_id  	IN  NUMBER    Required
--                 p_user_or_group_type IN  NUMBER    Required
--	OUT
--		Boolean
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Get_UpdateChannelStatus
(    p_channel_id		IN  	NUMBER,
	p_user_or_group_id	IN	NUMBER,
	p_user_or_group_type IN  VARCHAR2) return boolean
IS
--
l_flag	varchar2(1);

CURSOR UpdChanAccs_csr IS
select can_update_flag
from	  amv_u_access
where  access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
and	  access_to_table_record_id = p_channel_id
and	  user_or_group_id = p_user_or_group_id
and	  user_or_group_type = p_user_or_group_type;
--
BEGIN
	--
	OPEN UpdChanAccs_csr;
		FETCH UpdChanAccs_csr INTO l_flag;
		IF UpdChanAccs_csr%NOTFOUND THEN
			l_flag := FND_API.G_FALSE;
		END IF;
	CLOSE UpdChanAccs_csr;

	IF l_flag = FND_API.G_TRUE THEN
		return TRUE;
	ELSE
		return FALSE;
	END IF;
	--
END Get_UpdateChannelStatus;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_DeleteCategoryStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if an user or group can delete a category
--    Parameters :
--	IN
--                 p_category_id    	IN  NUMBER    Required
--                 p_user_or_group_id  	IN  NUMBER    Required
--                 p_user_or_group_type IN  NUMBER    Required
--	OUT
--		Boolean
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
FUNCTION Get_DeleteCategoryStatus
(    p_category_id		IN  	NUMBER,
	p_user_or_group_id	IN	NUMBER,
	p_user_or_group_type IN  VARCHAR2) return boolean
IS
--
l_flag	varchar2(1);

CURSOR DelCatAccs_csr IS
select can_delete_flag
from	  amv_u_access
where  access_to_table_code = AMV_UTILITY_PVT.G_CATEGORY
and	  access_to_table_record_id = p_category_id
and	  user_or_group_id = p_user_or_group_id
and	  user_or_group_type = p_user_or_group_type;
--
BEGIN
	--
	OPEN DelCatAccs_csr;
		FETCH DelCatAccs_csr INTO l_flag;
		IF DelCatAccs_csr%NOTFOUND THEN
			l_flag := FND_API.G_FALSE;
		END IF;
	CLOSE DelCatAccs_csr;

	IF l_flag = FND_API.G_TRUE THEN
		return TRUE;
	ELSE
		return FALSE;
	END IF;
	--
END Get_DeleteCategoryStatus;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UpdateCategoryStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if an user or group can update a channel
--    Parameters :
--	IN
--                 p_category_id    	IN  NUMBER    Required
--                 p_user_or_group_id  	IN  NUMBER    Required
--                 p_user_or_group_type IN  NUMBER    Required
--	OUT
--		Boolean
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Get_UpdateCategoryStatus
(    p_category_id		IN  	NUMBER,
	p_user_or_group_id	IN	NUMBER,
	p_user_or_group_type IN  VARCHAR2) return boolean
IS
--
l_flag	varchar2(1);

CURSOR UpdCatAccs_csr IS
select can_update_flag
from	  amv_u_access
where  access_to_table_code = AMV_UTILITY_PVT.G_CATEGORY
and	  access_to_table_record_id = p_category_id
and	  user_or_group_id = p_user_or_group_id
and	  user_or_group_type = p_user_or_group_type;
--
BEGIN
	--
	OPEN UpdCatAccs_csr;
		FETCH UpdCatAccs_csr INTO l_flag;
		IF UpdCatAccs_csr%NOTFOUND THEN
			l_flag := FND_API.G_FALSE;
		END IF;
	CLOSE UpdCatAccs_csr;

	IF l_flag = FND_API.G_TRUE THEN
		return TRUE;
	ELSE
		return FALSE;
	END IF;
	--
END Get_UpdateCategoryStatus;
--
--------------------------------------------------------------------------------
END amv_utility_pvt;

/
