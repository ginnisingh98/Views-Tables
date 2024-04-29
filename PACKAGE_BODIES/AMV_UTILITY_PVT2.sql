--------------------------------------------------------
--  DDL for Package Body AMV_UTILITY_PVT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_UTILITY_PVT2" AS
/* $Header: amvvutcb.pls 115.3 2000/02/02 17:25:02 pkm ship      $ */
--
-- NAME
--   AMV_UTILITY_PVT2
--
-- HISTORY
--   08/30/1999        SLKRISHN        CREATED
--
--
G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'AMV_UTILITY_PVT2';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'amvvutlb.pls';
--
G_VALID_LEVEL_LOGIN CONSTANT    NUMBER := FND_API.G_VALID_LEVEL_FULL;
--
----------------------------- Private Portion ---------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Is_CategoryIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if category id is valid and return a boolean value.
--    Parameters :
--            IN : p_category_id    	IN  NUMBER  Required
--			(sub)category id
--	     OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Is_CategoryIdValid (
  p_category_id IN NUMBER
)
RETURN Boolean
IS
l_valid_flag	number;
CURSOR
Check_CategoryId_csr IS
select count(*)
from   amv_c_categories_b
where  channel_category_id = p_category_id;
BEGIN
 OPEN Check_CategoryId_csr;
  FETCH Check_CategoryId_csr INTO l_valid_flag;
 CLOSE Check_CategoryId_csr;
 IF l_valid_flag > 0 THEN
	return TRUE;
 ELSE
	return FALSE;
 END IF;
END Is_CategoryIdValid;
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
where  access_to_table_code = AMV_UTILITY_PVT2.G_CHANNEL
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
where  access_to_table_code = AMV_UTILITY_PVT2.G_CHANNEL
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
where  access_to_table_code = AMV_UTILITY_PVT2.G_CATEGORY
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
where  access_to_table_code = AMV_UTILITY_PVT2.G_CATEGORY
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
--------------------------------------------------------------------------------

END amv_utility_pvt2;

/
