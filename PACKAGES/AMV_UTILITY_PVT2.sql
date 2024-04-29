--------------------------------------------------------
--  DDL for Package AMV_UTILITY_PVT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_UTILITY_PVT2" AUTHID CURRENT_USER AS
/* $Header: amvvutcs.pls 115.3 2000/02/02 17:25:06 pkm ship      $ */
--
-- NAME
--   AMV_UTILITY_PVT2
--
-- HISTORY
--   08/30/1999        SLKRISHN        CREATED
--
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
G_DEFAULT		CONSTANT VARCHAR2(30) := 'DEFAULT';
G_OWNER		CONSTANT VARCHAR2(30) := 'OWNER';
G_SECONDARY	CONSTANT VARCHAR2(30) := 'SECONDARY';
G_DONE		CONSTANT VARCHAR2(30) := 'DONE';
--
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
RETURN Boolean;
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
--------------------------------------------------------------------------------
END amv_utility_pvt2;

 

/
