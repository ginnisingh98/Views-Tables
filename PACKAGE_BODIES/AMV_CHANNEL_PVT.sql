--------------------------------------------------------
--  DDL for Package Body AMV_CHANNEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CHANNEL_PVT" AS
/* $Header: amvvchab.pls 120.1 2005/06/22 17:27:27 appldev ship $ */
--
-- NAME
--   AMV_CHANNEL_PVT
--
-- HISTORY
--   08/04/1999        SLKRISHN        CREATED
--
--
--
TYPE CursorType IS REF CURSOR;
G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'AMV_CHANNEL_PVT';
G_RESOURCE_ID	CONSTANT NUMBER := -1;
G_USER_ID		CONSTANT NUMBER := -1;
G_LOGIN_USER_ID CONSTANT NUMBER := -1;
--
--
----------------------------- Private Portinon ---------------------------------
--------------------------------------------------------------------------------
-- We use the following private helper procedure
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Get_ChannelStatus
(
     x_return_status  	OUT NOCOPY  VARCHAR2,
     p_channel_id      	IN  NUMBER   := FND_API.G_MISS_NUM,
     p_channel_name    	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_category_id  	IN  NUMBER   := FND_API.G_MISS_NUM,
     x_exist_flag     	OUT NOCOPY  VARCHAR2,
     x_channel_id     	OUT NOCOPY  NUMBER,
     x_error_msg      	OUT NOCOPY  VARCHAR2,
     x_error_token	OUT NOCOPY  VARCHAR2
);
--
PROCEDURE Get_ChannelRecord
(    p_channel_id	IN  NUMBER,
     x_channel_obj 	OUT NOCOPY  AMV_CHANNEL_OBJ_TYPE
);
--
FUNCTION Get_MatchOnStatus
(    p_channel_id	IN  NUMBER ) return boolean;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_ChannelStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if channel (p_channel_id/p_channel_name) exist
--                 return the channel id if existing.
--    Parameters :
--                 p_channel_id               	IN  NUMBER    Optional
--                   channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name             	IN  VARCHAR2  Optional
--                   channel name. Default = FND_API.G_MISS_CHAR
--                   Either pass the channel id (preferred) or channel name
--                   to identify the channel. When channel name passed
--		     pass category id
--                 p_category_id            	IN  NUMBER    Optional
--                   category id. Default = FND_API.G_MISS_NUM
--    OUT        : x_return_status             	OUT VARCHAR2
--                 x_exist_flag                	OUT VARCHAR2
--                    category existent flag
--                 x_channel_id                	OUT NUMBER
--                    category id which is valid if x_exist_flag is true.
--                 x_error_msg                 	OUT VARCHAR2
--                    error message
--                 x_error_token              	OUT VARCHAR2
--                    error token
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_ChannelStatus
(
     x_return_status  	OUT NOCOPY  VARCHAR2,
     p_channel_id      	IN  NUMBER   := FND_API.G_MISS_NUM,
     p_channel_name    	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_category_id  	IN  NUMBER   := FND_API.G_MISS_NUM,
     x_exist_flag     	OUT NOCOPY  VARCHAR2,
     x_channel_id     	OUT NOCOPY  NUMBER,
     x_error_msg      	OUT NOCOPY  VARCHAR2,
     x_error_token	OUT NOCOPY  VARCHAR2
) IS
CURSOR 	Get_ChannelStatusByName is
select 	b.channel_id
from 	amv_c_channels_b b, amv_c_channels_tl tl
where 	tl.channel_name = p_channel_name
and   	tl.language = userenv('lang')
-- commented line below for bug no.2950840
--and	b.channel_category_id = p_category_id
and   	tl.channel_id = b.channel_id;
--
BEGIN

    IF (p_channel_id IS NULL OR p_channel_name IS NULL
		OR p_category_id IS NULL) THEN
        x_error_msg  := 'AMV_CHN_ID_OR_NAME_NULL';
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    IF p_channel_id = FND_API.G_MISS_NUM THEN
	 IF p_channel_name = FND_API.G_MISS_CHAR THEN
		-- Must pass either channel id or channel name to identify
         	x_error_msg  := 'AMV_CHN_ID_AND_NAME_MISS';
         	RAISE  FND_API.G_EXC_ERROR;
	 ELSE
    		IF p_category_id = FND_API.G_MISS_NUM THEN
          	-- Must pass category id to identify by channel name
          	x_error_msg  := 'AMV_CHN_CAT_ID_MISS';
          	RAISE  FND_API.G_EXC_ERROR;
        	ELSE
			IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN
          		x_return_status := FND_API.G_RET_STS_SUCCESS;
          		OPEN  Get_ChannelStatusByName;
          		 FETCH Get_ChannelStatusByName INTO x_channel_id;
          		 IF Get_ChannelStatusByName%FOUND THEN
             			x_exist_flag := FND_API.G_TRUE;
             			x_error_msg  := 'AMV_CHN_NAME_EXISTS';
             			x_error_token  := p_channel_name;
          		 ELSE
             			-- Invalid channel name
             			x_exist_flag := FND_API.G_FALSE;
             			x_channel_id := FND_API.G_MISS_NUM;
             			x_error_msg  := 'AMV_CHN_NAME_NOT_EXIST';
             			x_error_token  := p_channel_name;
          		 END IF;
          		CLOSE Get_ChannelStatusByName;
			ELSE
             		x_error_msg  := 'AMV_CAT_ID_NOT_EXIST';
             		x_error_token  := p_category_id;
          		RAISE  FND_API.G_EXC_ERROR;
			END IF;
        	END IF;
	 END IF;
    ELSE
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		IF AMV_UTILITY_PVT.Is_ChannelIdValid(p_channel_id) THEN
             x_exist_flag := FND_API.G_TRUE;
	        x_channel_id := p_channel_id;
             x_error_msg  := 'AMV_CHN_ID_EXISTS';
             x_error_token  := p_channel_id;
        	ELSE
             -- Invalid channel id
             x_exist_flag := FND_API.G_FALSE;
             x_channel_id := FND_API.G_MISS_NUM;
             x_error_msg  := 'AMV_CHN_ID_NOT_EXIST';
             x_error_token  := p_channel_id;
        	END IF;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_exist_flag := FND_API.G_FALSE;
       x_channel_id := FND_API.G_MISS_NUM;
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_exist_flag := FND_API.G_FALSE;
       x_channel_id := FND_API.G_MISS_NUM;
END Get_ChannelStatus;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_MatchOnStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : return channel match on flags status for a channel id
--    Parameters :
--	IN
--                 p_channel_id    	IN  NUMBER    Required
--	OUT
--		Boolean
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
FUNCTION Get_MatchOnStatus
(    p_channel_id	IN  NUMBER )
return boolean
IS
l_match_on_author	varchar2(1);
l_match_on_keyword	varchar2(1);
l_match_on_perspective	varchar2(1);
l_match_on_item_type	varchar2(1);
l_match_on_content_type	varchar2(1);

CURSOR 	Match_On_Flags_csr IS
select 	match_on_author_flag
,	match_on_keyword_flag
,	match_on_perspective_flag
,	match_on_item_type_flag
,	match_on_content_type_flag
from	amv_c_channels_b
where	channel_id = p_channel_id;

BEGIN

 OPEN Match_On_Flags_csr;
 	FETCH Match_On_Flags_csr INTO 	l_match_on_author,
					l_match_on_keyword,
					l_match_on_perspective,
					l_match_on_item_type,
					l_match_on_content_type;

	IF l_match_on_author = FND_API.G_TRUE THEN
		return TRUE;
	ELSIF l_match_on_keyword = FND_API.G_TRUE THEN
		return TRUE;
	ELSIF l_match_on_perspective = FND_API.G_TRUE THEN
		return TRUE;
	ELSIF l_match_on_item_type = FND_API.G_TRUE THEN
		return TRUE;
	ELSIF l_match_on_content_type = FND_API.G_TRUE THEN
		return TRUE;
	ELSE
		return FALSE;
	END IF;
 CLOSE Match_On_Flags_csr;

END;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_ChannelRecord
--    Type       : Private
--    Pre-reqs   : None
--    Function   : return channel record for an channel id
--    Parameters :
--                 p_channel_id    	IN  NUMBER    Required
--    OUT        : x_channel_obj       	OUT AMV_CHANNEL_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Get_ChannelRecord
(    p_channel_id	IN  NUMBER,
     x_channel_obj 	OUT NOCOPY  AMV_CHANNEL_OBJ_TYPE
)
IS
--
l_channel_id			NUMBER;
l_object_version_number		NUMBER;
l_channel_name			VARCHAR2(80);
l_description			VARCHAR2(2000);
l_channel_type			VARCHAR2(30);
l_channel_category_id		NUMBER;
l_status			VARCHAR2(30);
l_owner_user_id			NUMBER;
l_default_approver_user_id	NUMBER;
l_effective_start_date		DATE;
l_expiration_date		DATE;
l_access_level_type		VARCHAR2(30);
l_pub_need_approval_flag 	VARCHAR2(1);
l_sub_need_approval_flag 	VARCHAR2(1);
l_match_on_all_criteria_flag	VARCHAR2(1);
l_match_on_keyword_flag		VARCHAR2(1);
l_match_on_author_flag		VARCHAR2(1);
l_match_on_perspective_flag	VARCHAR2(1);
l_match_on_item_type_flag	VARCHAR2(1);
l_match_on_content_type_flag	VARCHAR2(1);
l_match_on_time_flag		VARCHAR2(1);
l_application_id		NUMBER;
l_external_access_flag		VARCHAR2(1);
l_item_match_count		NUMBER;
l_last_match_time		DATE;
l_notification_interval_type	VARCHAR2(30);
l_last_notification_time	DATE;
l_attribute_category		VARCHAR2(30);
l_attribute1			VARCHAR2(150);
l_attribute2			VARCHAR2(150);
l_attribute3			VARCHAR2(150);
l_attribute4			VARCHAR2(150);
l_attribute5			VARCHAR2(150);
l_attribute6			VARCHAR2(150);
l_attribute7			VARCHAR2(150);
l_attribute8			VARCHAR2(150);
l_attribute9			VARCHAR2(150);
l_attribute10			VARCHAR2(150);
l_attribute11			VARCHAR2(150);
l_attribute12			VARCHAR2(150);
l_attribute13			VARCHAR2(150);
l_attribute14			VARCHAR2(150);
l_attribute15			VARCHAR2(150);
--
CURSOR C_ChannelRecord IS
select	b.channel_id,
	b.object_version_number,
	tl.channel_name,
	tl.description,
	b.channel_type,
	b.channel_category_id,
	b.status,
	b.owner_user_id,
	b.default_approver_user_id,
	b.effective_start_date,
	b.expiration_date,
	b.access_level_type,
	b.pub_need_approval_flag,
	b.sub_need_approval_flag,
	b.match_on_all_criteria_flag,
	b.match_on_keyword_flag,
	b.match_on_author_flag,
	b.match_on_perspective_flag,
	b.match_on_item_type_flag,
	b.match_on_content_type_flag,
	b.match_on_time_flag,
	b.application_id,
	b.external_access_flag,
	b.item_match_count,
	b.last_match_time,
	b.notification_interval_type,
	b.last_notification_time,
	b.attribute_category,
	b.attribute1,
	b.attribute2,
	b.attribute3,
	b.attribute4,
	b.attribute5,
	b.attribute6,
	b.attribute7,
	b.attribute8,
	b.attribute9,
	b.attribute10,
	b.attribute11,
	b.attribute12,
	b.attribute13,
	b.attribute14,
	b.attribute15
from	amv_c_channels_b b
,	amv_c_channels_tl tl
where	b.channel_id = p_channel_id
and   	tl.language = userenv('lang')
and	tl.channel_id = b.channel_id;
--
BEGIN

 OPEN C_ChannelRecord;
   FETCH C_ChannelRecord INTO x_channel_obj;
/*
	l_channel_id,
	l_object_version_number,
	l_channel_name,
	l_description,
	l_channel_type,
	l_channel_category_id,
	l_status,
	l_owner_user_id,
	l_default_approver_user_id,
	l_effective_start_date,
	l_expiration_date,
	l_access_level_type,
	l_pub_need_approval_flag,
	l_sub_need_approval_flag,
	l_match_on_all_criteria_flag,
	l_match_on_keyword_flag,
	l_match_on_author_flag,
	l_match_on_perspective_flag,
	l_match_on_item_type_flag,
	l_match_on_content_type_flag,
	l_match_on_time_flag,
	l_application_id,
	l_external_access_flag,
	l_item_match_count,
	l_last_match_time,
	l_notification_interval_type,
	l_last_notification_time,
	l_attribute_category,
	l_attribute1,
	l_attribute2,
	l_attribute3,
	l_attribute4,
	l_attribute5,
	l_attribute6,
	l_attribute7,
	l_attribute8,
	l_attribute9,
	l_attribute10,
	l_attribute11,
	l_attribute12,
	l_attribute13,
	l_attribute14,
	l_attribute15;

	x_channel_obj := amv_channel_obj_type(
				l_channel_id,
				l_object_version_number,
				l_channel_name,
				l_description,
				l_channel_type,
				l_channel_category_id,
				l_status,
				l_owner_user_id,
				l_default_approver_user_id,
				l_effective_start_date,
				l_expiration_date,
				l_access_level_type,
				l_pub_need_approval_flag,
				l_sub_need_approval_flag,
				l_match_on_all_criteria_flag,
				l_match_on_keyword_flag,
				l_match_on_author_flag,
				l_match_on_perspective_flag,
				l_match_on_item_type_flag,
				l_match_on_content_type_flag,
				l_match_on_time_flag,
				l_application_id,
				l_external_access_flag,
				l_item_match_count,
				l_last_match_time,
				l_notification_interval_type,
				l_last_notification_time,
				l_attribute_category,
				l_attribute1,
				l_attribute2,
				l_attribute3,
				l_attribute4,
				l_attribute5,
				l_attribute6,
				l_attribute7,
				l_attribute8,
				l_attribute9,
				l_attribute10,
				l_attribute11,
				l_attribute12,
				l_attribute13,
				l_attribute14,
				l_attribute15);
*/
 CLOSE C_ChannelRecord;

END Get_ChannelRecord;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_Channel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create a new channel
--    Parameters :
--    IN           p_api_version       	IN  NUMBER    Required
--                 p_init_msg_list      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit             IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_record     IN  AMV_CHANNEL_OBJ_TYPE  Required
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_channel_id         OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_Channel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_record    	IN  AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Add_Channel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id     		number;
l_login_user_id 	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_null_value		varchar2(30) := null;
l_row_id		varchar2(30);
l_mychannel_id		number;
l_expiration_date	date;
l_channel_obj		AMV_CHANNEL_OBJ_TYPE;
l_error_flag		varchar2(1);

CURSOR ChannelId_Seq IS
select amv_c_channels_b_s.nextval
from   dual;
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_Channel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- verify channel object
    -- error causing channel columns
    IF (p_channel_record.channel_type = FND_API.G_MISS_CHAR) THEN
		l_error_flag	:= FND_API.G_TRUE;
    END IF;
    IF (p_channel_record.access_level_type = FND_API.G_MISS_CHAR) THEN
		l_error_flag	:= FND_API.G_TRUE;
    END IF;
    IF (p_channel_record.owner_user_id = FND_API.G_MISS_NUM) THEN
		l_error_flag	:= FND_API.G_TRUE;
    END IF;
    IF (p_channel_record.default_approver_user_id = FND_API.G_MISS_NUM) THEN
		l_error_flag	:= FND_API.G_TRUE;
    END IF;

    -- raise exception if null values passed
    IF l_error_flag = FND_API.G_TRUE THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
         		FND_MESSAGE.Set_Name('AMV', 'AMV_INVALID_OBJ_VALUES');
         		FND_MESSAGE.Set_Token('TKN', 'Channel');
         		FND_MSG_PUB.Add;
		END IF;
		RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- default values settings for inconsistant types
    l_channel_obj := p_channel_record;

    IF (p_channel_record.status = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.status := AMV_UTILITY_PVT.G_ACTIVE;
    END IF;

    IF (p_channel_record.effective_start_date = FND_API.G_MISS_DATE) THEN
	 l_channel_obj.effective_start_date := sysdate;
    END IF;

    IF (p_channel_record.pub_need_approval_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.pub_need_approval_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.sub_need_approval_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.sub_need_approval_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.match_on_all_criteria_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_all_criteria_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.match_on_keyword_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_keyword_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.match_on_author_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_author_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.match_on_perspective_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_perspective_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.match_on_content_type_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_content_type_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.match_on_item_type_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_item_type_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.match_on_time_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_time_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.application_id = FND_API.G_MISS_NUM) THEN
	 l_channel_obj.application_id := null;
    END IF;

    IF (p_channel_record.external_access_flag = FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.external_access_flag := FND_API.G_FALSE;
    END IF;

    IF (p_channel_record.item_match_count = FND_API.G_MISS_NUM) THEN
	 l_channel_obj.item_match_count := 0;
    END IF;

    -- Check if channel name already exists
    Get_ChannelStatus (
        x_return_status	=> x_return_status,
        p_channel_name 	=> p_channel_record.channel_name,
        p_category_id	=> p_channel_record.channel_category_id,
        x_exist_flag   	=> l_channel_exist_flag,
        x_channel_id   	=> l_channel_id,
        x_error_msg    	=> l_Error_Msg,
	   x_error_token	=> l_Error_Token
        );

    -- Add channel if it does not exist
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF (l_channel_exist_flag = FND_API.G_TRUE) THEN
        	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
                FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                FND_MSG_PUB.Add;
        	END IF;
        	RAISE  FND_API.G_EXC_ERROR;
     ELSE
	 -- set expiration date to null if none passed
	 IF p_channel_record.expiration_date = FND_API.G_MISS_DATE THEN
		l_expiration_date := null;
	 ELSE
		l_expiration_date := p_channel_record.expiration_date;
	 END IF;

    	 -- Select the channel sequence
	 OPEN ChannelId_Seq;
		FETCH ChannelId_Seq INTO l_channel_id;
	 CLOSE ChannelId_Seq;

	 -- Create a new channel
	 BEGIN
  	 AMV_C_CHANNELS_PKG.INSERT_ROW(
		X_ROWID => l_row_id,
  		X_CHANNEL_ID => l_channel_id,
		X_OBJECT_VERSION_NUMBER => l_object_version_number,
  		X_CHANNEL_TYPE =>  p_channel_record.channel_type,
  		X_CHANNEL_CATEGORY_ID => p_channel_record.channel_category_id,
  		X_STATUS => l_channel_obj.status,
  		X_OWNER_USER_ID => p_channel_record.owner_user_id,
  		X_DEFAULT_APPROVER_USER_ID =>
			p_channel_record.default_approver_user_id,
 		X_EFFECTIVE_START_DATE => l_channel_obj.effective_start_date,
  		X_EXPIRATION_DATE => l_expiration_date,
  		X_ACCESS_LEVEL_TYPE  => p_channel_record.access_level_type,
  		X_PUB_NEED_APPROVAL_FLAG =>
			l_channel_obj.pub_need_approval_flag,
  		X_SUB_NEED_APPROVAL_FLAG =>
			l_channel_obj.sub_need_approval_flag,
  		X_MATCH_ON_ALL_CRITERIA_FLAG =>
			l_channel_obj.match_on_all_criteria_flag,
  		X_MATCH_ON_KEYWORD_FLAG =>
			l_channel_obj.match_on_keyword_flag,
  		X_MATCH_ON_AUTHOR_FLAG => l_channel_obj.match_on_author_flag,
  		X_MATCH_ON_PERSPECTIVE_FLAG =>
			l_channel_obj.match_on_perspective_flag,
  		X_MATCH_ON_ITEM_TYPE_FLAG =>
			l_channel_obj.match_on_item_type_flag,
  		X_MATCH_ON_CONTENT_TYPE_FLAG =>
			l_channel_obj.match_on_content_type_flag,
  		X_MATCH_ON_TIME_FLAG => l_channel_obj.match_on_time_flag,
		X_APPLICATION_ID => l_channel_obj.application_id,
		X_EXTERNAL_ACCESS_FLAG => l_channel_obj.external_access_flag,
  		X_ITEM_MATCH_COUNT =>l_channel_obj.item_match_count,
  		X_LAST_MATCH_TIME => l_channel_obj.last_match_time,
  		X_NOTIFICATION_INTERVAL_TYPE =>
			l_channel_obj.notification_interval_type,
  		X_LAST_NOTIFICATION_TIME =>
			l_channel_obj.last_notification_time,
  		X_ATTRIBUTE_CATEGORY => l_channel_obj.attribute_category,
  		X_ATTRIBUTE1 => l_channel_obj.attribute1,
  		X_ATTRIBUTE2 => l_channel_obj.attribute2,
  		X_ATTRIBUTE3 => l_channel_obj.attribute3,
  		X_ATTRIBUTE4 => l_channel_obj.attribute4,
  		X_ATTRIBUTE5 => l_channel_obj.attribute5,
  		X_ATTRIBUTE6 => l_channel_obj.attribute6,
  		X_ATTRIBUTE7 => l_channel_obj.attribute7,
  		X_ATTRIBUTE8 => l_channel_obj.attribute8,
  		X_ATTRIBUTE9 => l_channel_obj.attribute9,
  		X_ATTRIBUTE10 => l_channel_obj.attribute10,
  		X_ATTRIBUTE11 => l_channel_obj.attribute11,
  		X_ATTRIBUTE12 => l_channel_obj.attribute12,
  		X_ATTRIBUTE13 => l_channel_obj.attribute13,
  		X_ATTRIBUTE14 => l_channel_obj.attribute14,
  		X_ATTRIBUTE15 => l_channel_obj.attribute15,
  		X_CHANNEL_NAME => l_channel_obj.channel_name,
		X_DESCRIPTION => l_channel_obj.description,
  		X_CREATION_DATE => sysdate,
  		X_CREATED_BY => l_user_id,
  		X_LAST_UPDATE_DATE => sysdate,
  		X_LAST_UPDATED_BY => l_user_id,
  		X_LAST_UPDATE_LOGIN =>  l_login_user_id
		);
	 EXCEPTION
        	WHEN OTHERS THEN
          	--will log the error
        	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
              	FND_MESSAGE.Set_Name('AMV', 'AMV_TABLE_HANDLER_ERROR');
              	FND_MESSAGE.Set_Token('ACTION', 'Adding Channel');
               FND_MESSAGE.Set_Token('TABLE', sqlerrm);
              	FND_MSG_PUB.Add;
        	END IF;
          RAISE  FND_API.G_EXC_ERROR;
	 END;
   		-- Pass the channel id created
   		x_channel_id := l_channel_id;
     END IF;
    ELSE
		-- exception errors from get_channelstatus
       	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
       	THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
       	END IF;
       	RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Add_Channel;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_PublicChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create a new content public channel
--    Parameters :
--    IN           p_api_version       	IN  NUMBER    Required
--                 p_init_msg_list      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit             IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_record     IN  AMV_CHANNEL_OBJ_TYPE  Required
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_channel_id         OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_PublicChannel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_record    	IN  AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Add_PublicChannel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id     		number;
l_login_user_id 	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_setup_result   	varchar2(1);
l_null_value		varchar2(30) := null;
l_row_id		varchar2(30);
l_mychannel_id		number;
l_expiration_date	date;
l_mychannel_obj	AMV_MYCHANNEL_PVT.AMV_MY_CHANNEL_OBJ_TYPE;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_PublicChannel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => p_channel_record.owner_user_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	IF (l_setup_result = FND_API.G_TRUE) THEN
		IF p_channel_record.channel_type = AMV_UTILITY_PVT.G_CONTENT THEN
	    	 	IF p_channel_record.access_level_type =
								AMV_UTILITY_PVT.G_PUBLIC THEN
				-- create the channel
				AMV_CHANNEL_PVT.Add_Channel (
					p_api_version => l_api_version,
					p_init_msg_list => FND_API.G_FALSE,
					p_validation_level => p_validation_level,
					x_return_status => x_return_status,
					x_msg_count => x_msg_count,
					x_msg_data => x_msg_data,
					p_check_login_user => FND_API.G_FALSE,
      				p_channel_record  => p_channel_record,
      				x_channel_id  => x_channel_id
					);
    				IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       				RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
	  			-- invoke macthing engine for populating items into channel
	  			AMV_MATCH_PVT.Request_ChannelMatch
	    			(
					p_api_version       => l_api_version,
	   				x_return_status     => x_return_status,
					x_msg_count         => x_msg_count,
					x_msg_data          => x_msg_data,
					p_check_login_user  => FND_API.G_FALSE,
					p_channel_id        => x_channel_id
				);
    				IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       				RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			ELSE
				-- Invalid channel type passed
				IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        			THEN
          			FND_MESSAGE.Set_Name('AMV','AMV_INVALID_CHAN_TYPE');
           			FND_MESSAGE.Set_Token('TKN','Content');
         	  			FND_MSG_PUB.Add;
         			END IF;
	    		END IF;
	  	ELSE
			-- Invalid channel type passed
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV','AMV_INVALID_CHAN_ACCS');
           		FND_MESSAGE.Set_Token('TKN','Public');
         	  		FND_MSG_PUB.Add;
         		END IF;
	  	END IF;
	ELSE
		-- user does not have privilege to create public channel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
	END IF;
    ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_PublicChannel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_PublicChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_PublicChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Add_PublicChannel;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_ProtectedChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create a new content protected channel
--    Parameters :
--    IN           p_api_version       	IN  NUMBER    Required
--                 p_init_msg_list      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit             IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_record     IN  AMV_CHANNEL_OBJ_TYPE  Required
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_channel_id         OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_ProtectedChannel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_record    	IN  AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Add_ProtectedChannel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id     		number;
l_login_user_id 	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_setup_result   	varchar2(1);
l_null_value		varchar2(30) := null;
l_row_id		varchar2(30);
l_mychannel_id		number;
l_expiration_date	date;
l_mychannel_obj	AMV_MYCHANNEL_PVT.AMV_MY_CHANNEL_OBJ_TYPE;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_ProtectedChannel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => p_channel_record.owner_user_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	IF (l_setup_result = FND_API.G_TRUE) THEN
		IF p_channel_record.channel_type = AMV_UTILITY_PVT.G_CONTENT THEN
	    	 	IF p_channel_record.access_level_type =
								AMV_UTILITY_PVT.G_PROTECTED THEN
				-- create the channel
				AMV_CHANNEL_PVT.Add_Channel (
					p_api_version => l_api_version,
					p_init_msg_list => FND_API.G_FALSE,
					p_validation_level => p_validation_level,
					x_return_status => x_return_status,
					x_msg_count => x_msg_count,
					x_msg_data => x_msg_data,
					p_check_login_user => FND_API.G_FALSE,
      				p_channel_record  => p_channel_record,
      				x_channel_id  => x_channel_id
					);
    				IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       				RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
	  			-- invoke macthing engine for populating items into channel
	  			AMV_MATCH_PVT.Request_ChannelMatch
	    			(
					p_api_version       => l_api_version,
	   				x_return_status     => x_return_status,
					x_msg_count         => x_msg_count,
					x_msg_data          => x_msg_data,
					p_check_login_user  => FND_API.G_FALSE,
					p_channel_id        => x_channel_id
				);
    				IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       				RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			ELSE
				-- Invalid channel type passed
				IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        			THEN
          			FND_MESSAGE.Set_Name('AMV','AMV_INVALID_CHAN_TYPE');
           			FND_MESSAGE.Set_Token('TKN','Content');
         	  			FND_MSG_PUB.Add;
         			END IF;
	    		END IF;
	  	ELSE
			-- Invalid channel type passed
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV','AMV_INVALID_CHAN_ACCS');
           		FND_MESSAGE.Set_Token('TKN','Protected');
         	  		FND_MSG_PUB.Add;
         		END IF;
	  	END IF;
	ELSE
		-- user does not have privilege to create public channel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
	END IF;
    ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_ProtectedChannel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_ProtectedChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_ProtectedChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Add_ProtectedChannel;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_PrivateChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create a new content private channel
--    Parameters :
--    IN           p_api_version       	IN  NUMBER    Required
--                 p_init_msg_list      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit             IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_record     IN  AMV_CHANNEL_OBJ_TYPE  Required
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_channel_id         OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_PrivateChannel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_record    	IN  AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Add_PrivateChannel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id     		number;
l_login_user_id 	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_null_value		varchar2(30) := null;
l_row_id		varchar2(30);
l_mychannel_id		number;
l_expiration_date	date;
l_mychannel_obj	AMV_MYCHANNEL_PVT.AMV_MY_CHANNEL_OBJ_TYPE;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_PrivateChannel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF p_channel_record.channel_type = AMV_UTILITY_PVT.G_CONTENT THEN
    	 	IF p_channel_record.access_level_type =
						AMV_UTILITY_PVT.G_PRIVATE THEN
			-- create the channel
			AMV_CHANNEL_PVT.Add_Channel (
				p_api_version => l_api_version,
				p_init_msg_list => FND_API.G_FALSE,
				p_validation_level => p_validation_level,
				x_return_status => x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data,
				p_check_login_user => FND_API.G_FALSE,
      			p_channel_record  => p_channel_record,
      			x_channel_id  => x_channel_id
				);
    			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       			RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
	  		-- create mychannel object
			l_mychannel_obj.my_channel_id := FND_API.G_MISS_NUM;
			l_mychannel_obj.channel_type := FND_API.G_MISS_CHAR;
			l_mychannel_obj.access_level_type := FND_API.G_MISS_CHAR;
			l_mychannel_obj.user_or_group_id :=
			                    p_channel_record.default_approver_user_id;
			l_mychannel_obj.user_or_group_type :=AMV_UTILITY_PVT.G_USER;
			l_mychannel_obj.subscribing_to_id := x_channel_id;
			l_mychannel_obj.subscribing_to_type :=AMV_UTILITY_PVT.G_CHANNEL;
			l_mychannel_obj.subscription_reason_type:=
							AMV_UTILITY_PVT.G_ENFORCED;
			l_mychannel_obj.order_number := FND_API.G_MISS_NUM;
			l_mychannel_obj.status := AMV_UTILITY_PVT.G_ACTIVE;
			l_mychannel_obj.notify_flag := FND_API.G_FALSE;
			l_mychannel_obj.notification_interval_type:= FND_API.G_MISS_CHAR;
			/*
	  		l_mychannel_obj := amv_my_channel_obj_type(
				FND_API.G_MISS_NUM,
				FND_API.G_MISS_CHAR,
				FND_API.G_MISS_CHAR,
				p_channel_record.default_approver_user_id,
				AMV_UTILITY_PVT.G_USER,
				x_channel_id,
				AMV_UTILITY_PVT.G_CHANNEL,
				AMV_UTILITY_PVT.G_ENFORCED,
				FND_API.G_MISS_NUM,
				AMV_UTILITY_PVT.G_ACTIVE,
				FND_API.G_FALSE,
				FND_API.G_MISS_CHAR);
			*/
	  		-- add subscription
	  		AMV_MYCHANNEL_PVT.Add_Subscription
			(
     			p_api_version => l_api_version,
      			x_return_status => x_return_status,
      			x_msg_count => x_msg_count,
      			x_msg_data => x_msg_data,
      			p_check_login_user => FND_API.G_FALSE,
      			p_mychannel_obj => l_mychannel_obj,
      			x_mychannel_id => l_mychannel_id
	   		);
    			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       			RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		ELSE
			-- Invalid channel type passed
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
    			THEN
         			FND_MESSAGE.Set_Name('AMV','AMV_INVALID_CHAN_TYPE');
        			FND_MESSAGE.Set_Token('TKN','Content');
    	  			FND_MSG_PUB.Add;
   			END IF;
    		END IF;
    ELSE
		-- Invalid channel type passed
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
    		THEN
         		FND_MESSAGE.Set_Name('AMV','AMV_INVALID_CHAN_ACCS');
         		FND_MESSAGE.Set_Token('TKN','Protected');
    	  		FND_MSG_PUB.Add;
    		END IF;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_PrivateChannel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_PrivateChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_PrivateChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Add_PrivateChannel;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_GroupChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create a new content protected channel
--    Parameters :
--    IN           p_api_version       	IN  NUMBER    Required
--                 p_init_msg_list      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit             IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_record     IN  AMV_CHANNEL_OBJ_TYPE  Required
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_channel_id         OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_GroupChannel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
	 p_group_id			IN  NUMBER,
      p_channel_record    	IN  AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Add_GroupChannel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id     		number;
l_login_user_id 	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_category_id		number;
l_group_name		varchar2(60);
l_channel_exist_flag   	varchar2(1);
l_null_value		varchar2(30) := null;
l_row_id		varchar2(30);
l_mychannel_id		number;
l_expiration_date	date;
l_mychannel_obj	AMV_MYCHANNEL_PVT.AMV_MY_CHANNEL_OBJ_TYPE;
l_channel_obj		AMV_CHANNEL_OBJ_TYPE;

CURSOR Get_GroupCategory IS
select channel_category_id
from   amv_c_categories_tl
where  channel_category_name = 'AMV_GROUP'
and    language = userenv('lang');

CURSOR Get_GroupName IS
select group_name
from  JTF_RS_GROUPS_VL
where group_id = p_group_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_GroupChannel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN Get_GroupCategory;
    	FETCH Get_GroupCategory INTO l_category_id;
    CLOSE Get_GroupCategory;
    --
    OPEN Get_GroupName;
    	FETCH Get_GroupName INTO l_group_name;
    CLOSE Get_GroupName;
    --
    IF l_group_name is null THEN
		-- Invalid channel type passed
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
    		THEN
         		FND_MESSAGE.Set_Name('AMV','AMV_INVALID_GROUP_ID');
         		FND_MESSAGE.Set_Token('TKN',p_group_id);
         		FND_MSG_PUB.Add;
         	END IF;
		RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_channel_obj := p_channel_record;
    l_channel_obj.channel_category_id := l_category_id;
    l_channel_obj.channel_name := l_group_name;
    l_channel_obj.description := 'Group Channel for '||l_group_name;

    --
    IF p_channel_record.channel_type = AMV_UTILITY_PVT.G_GROUP THEN
			-- create the channel
			AMV_CHANNEL_PVT.Add_Channel (
				p_api_version => l_api_version,
				p_init_msg_list => FND_API.G_FALSE,
				p_validation_level => p_validation_level,
				x_return_status => x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data,
				p_check_login_user => FND_API.G_FALSE,
    				p_channel_record  => l_channel_obj,
    				x_channel_id  => x_channel_id
				);
    			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       			RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
	  		-- create mychannel object
			-- NOTE check if p_group_id id null
			-- make channel name is the same as group name
			l_mychannel_obj.my_channel_id := FND_API.G_MISS_NUM;
			l_mychannel_obj.channel_type := FND_API.G_MISS_CHAR;
			l_mychannel_obj.access_level_type := FND_API.G_MISS_CHAR;
			l_mychannel_obj.user_or_group_id := p_group_id;
			l_mychannel_obj.user_or_group_type :=AMV_UTILITY_PVT.G_GROUP;
			l_mychannel_obj.subscribing_to_id := x_channel_id;
			l_mychannel_obj.subscribing_to_type :=AMV_UTILITY_PVT.G_CHANNEL;
			l_mychannel_obj.subscription_reason_type:=
								AMV_UTILITY_PVT.G_ENFORCED;
			l_mychannel_obj.order_number := FND_API.G_MISS_NUM;
			l_mychannel_obj.status := AMV_UTILITY_PVT.G_ACTIVE;
			l_mychannel_obj.notify_flag := FND_API.G_FALSE;
			l_mychannel_obj.notification_interval_type:= FND_API.G_MISS_CHAR;
			/*
	  		l_mychannel_obj := amv_my_channel_obj_type(
				FND_API.G_MISS_NUM,
				FND_API.G_MISS_CHAR,
				FND_API.G_MISS_CHAR,
				p_group_id,
				AMV_UTILITY_PVT.G_GROUP,
				x_channel_id,
				AMV_UTILITY_PVT.G_CHANNEL,
				AMV_UTILITY_PVT.G_ENFORCED,
				FND_API.G_MISS_NUM,
				AMV_UTILITY_PVT.G_ACTIVE,
				FND_API.G_FALSE,
				FND_API.G_MISS_CHAR);
			*/
	  		-- add subscription
	  		AMV_MYCHANNEL_PVT.Add_Subscription
			(
    				p_api_version => l_api_version,
    				x_return_status => x_return_status,
    				x_msg_count => x_msg_count,
    				x_msg_data => x_msg_data,
    				p_check_login_user => FND_API.G_FALSE,
    				p_mychannel_obj => l_mychannel_obj,
    				x_mychannel_id => l_mychannel_id
	   		);
    			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       			RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
    ELSE
		-- Invalid channel type passed
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
    		THEN
         		FND_MESSAGE.Set_Name('AMV','AMV_INVALID_CHAN_TYPE');
         		FND_MESSAGE.Set_Token('TKN','Group');
         		FND_MSG_PUB.Add;
         	END IF;
		RAISE FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_GroupChannel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_GroupChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_GroupChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Add_GroupChannel;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Channel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete the content channel given p_channel_id/p_channel_name
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_Channel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id        	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name      	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id       	IN  NUMBER   := FND_API.G_MISS_NUM
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Delete_Channel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id		number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_delete_channel_flag   	varchar2(1);
l_setup_result   		varchar2(1);
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Delete_Channel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
      FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check if the user has privilege to delete channel
    --
    Get_ChannelStatus (
        x_return_status  => x_return_status,
        p_channel_id     => p_channel_id,
        p_channel_name   => p_channel_name,
        p_category_id 	 => p_category_id,
        x_exist_flag     => l_channel_exist_flag,
        x_channel_id     => l_channel_id,
        x_error_msg      => l_Error_Msg,
	   x_error_token	=> l_Error_Token
        );
    -- remove channel if it exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', 'l_Error_Msg');
               	FND_MESSAGE.Set_Token('CHN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     --
     AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => l_resource_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	  IF (l_setup_result = FND_API.G_TRUE) THEN
		l_delete_channel_flag := FND_API.G_TRUE;
    	  ELSE
		IF (AMV_UTILITY_PVT.Get_DeleteChannelStatus(	l_channel_id,
								l_resource_id,
								AMV_UTILITY_PVT.G_USER) )
		THEN
			l_delete_channel_flag := FND_API.G_TRUE;
		ELSE
			-- user does not have privilege to create public channel
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           		FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  		FND_MSG_PUB.Add;
         		END IF;
	 		RAISE FND_API.G_EXC_ERROR;
		END IF;
	  END IF;
     ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    -- delete channels if user has privilege
    IF l_delete_channel_flag = FND_API.G_TRUE THEN
	 -- Remove channel from mychannels
	 DELETE 	FROM amv_u_my_channels
	 WHERE	subscribing_to_id = l_channel_id
	 AND	subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL;

	 -- Remove access given to this channel
	 DELETE 	FROM amv_u_access
	 WHERE	access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
	 AND		access_to_table_record_id = l_channel_id;

	 -- Remove channel from authors
	 DELETE 	FROM amv_c_authors
	 WHERE	channel_id = l_channel_id;
	 -- Remove channel from keywords
	 DELETE 	FROM amv_c_keywords
	 WHERE	channel_id = l_channel_id;
	 -- Remove channel from content type
	 DELETE 	FROM amv_c_content_types
	 WHERE	channel_id = l_channel_id;
	 -- Remove channel from perspectives
	 DELETE 	FROM amv_c_chl_perspectives
	 WHERE	channel_id = l_channel_id;
	 -- Remove channel from item types
	 DELETE 	FROM amv_c_item_types
	 WHERE	channel_id = l_channel_id;
	 -- Remove channel from item match
	 DELETE 	FROM amv_c_chl_item_match
	 WHERE	channel_id = l_channel_id;

	 -- Remove channel from channels
	 AMV_C_CHANNELS_PKG.DELETE_ROW (l_channel_id);

    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Delete_Channel;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Channel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Change the channel given by
--                 (channel) id or name in p_channel_record
--                 New data are specified in other members of p_channel_record
--    Parameters :
--    IN           p_api_version        IN  NUMBER    Required
--                 p_init_msg_list      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit             IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_record   	IN  AMV_CHANNEL_OBJ_TYPE  Required
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_Channel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_record    	IN  AMV_CHANNEL_OBJ_TYPE
)
IS
l_api_name         	CONSTANT VARCHAR2(30) := 'Update_Channel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number;
--
l_channel_id		number;
l_channel_id_ex		number;
l_channel_exist_flag   	varchar2(1);
l_update_channel_flag   	varchar2(1);
l_setup_result   		varchar2(1);
l_channel_obj  		AMV_CHANNEL_OBJ_TYPE;

CURSOR Get_ChnVersion_csr IS
select object_version_number
from   amv_c_channels_b
where  channel_id = l_channel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Update_Channel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
      FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_record.channel_id,
        p_channel_name  => p_channel_record.channel_name,
        p_category_id 	=> p_channel_record.channel_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	   x_error_token	=> l_Error_Token
        );
    -- check if channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', 'l_Error_Msg');
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     -- check if the user has privilege to update channel
     --
     AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => l_resource_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	 IF (l_setup_result = FND_API.G_TRUE) THEN
		l_update_channel_flag := FND_API.G_TRUE;
    	 ELSE
		IF (AMV_UTILITY_PVT.Get_UpdateChannelStatus(
								l_channel_id,
								l_resource_id,
								AMV_UTILITY_PVT.G_USER) )
		THEN
			l_update_channel_flag := FND_API.G_TRUE;
		ELSE
			-- user does not have privilege to create public channel
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           		FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  		FND_MSG_PUB.Add;
         		END IF;
	 		RAISE FND_API.G_EXC_ERROR;
		END IF;
	 END IF;
     ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    --
    IF l_update_channel_flag = FND_API.G_TRUE THEN
	-- Get the current channel record
	Get_ChannelRecord(l_channel_id, l_channel_obj);

	-- Replace with new entries
        IF (p_channel_record.channel_type <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.channel_type := p_channel_record.channel_type;
	END IF;
	-- NOTE
        IF (p_channel_record.channel_category_id <> FND_API.G_MISS_NUM) THEN
	 l_channel_obj.channel_category_id :=
				p_channel_record.channel_category_id;
	END IF;
        IF (p_channel_record.status <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.status := p_channel_record.status;
	END IF;
        IF (p_channel_record.owner_user_id <> FND_API.G_MISS_NUM) THEN
	 l_channel_obj.owner_user_id := p_channel_record.owner_user_id;
	END IF;
        IF (p_channel_record.channel_name <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.channel_name :=
				p_channel_record.channel_name;
	END IF;
        IF (p_channel_record.default_approver_user_id <>FND_API.G_MISS_NUM) THEN
	 l_channel_obj.default_approver_user_id :=
				p_channel_record.default_approver_user_id;
	END IF;
      	IF (p_channel_record.effective_start_date <> FND_API.G_MISS_DATE) THEN
	 l_channel_obj.effective_start_date :=
				p_channel_record.effective_start_date;
	END IF;
        IF (p_channel_record.access_level_type <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.access_level_type :=
				p_channel_record.access_level_type;
	END IF;
        IF (p_channel_record.pub_need_approval_flag <>
						FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.pub_need_approval_flag :=
				p_channel_record.pub_need_approval_flag;

	END IF;
        IF (p_channel_record.match_on_all_criteria_flag <>
						FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_all_criteria_flag :=
				p_channel_record.match_on_all_criteria_flag;
	END IF;
        IF (p_channel_record.match_on_keyword_flag <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_keyword_flag :=
				p_channel_record.match_on_keyword_flag;
	END IF;
        IF (p_channel_record.match_on_author_flag <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_author_flag :=
				p_channel_record.match_on_author_flag;
	END IF;
        IF (p_channel_record.match_on_perspective_flag <>
						FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_perspective_flag :=
				p_channel_record.match_on_perspective_flag;
	END IF;
        IF (p_channel_record.match_on_content_type_flag <>
						FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_content_type_flag :=
				p_channel_record.match_on_content_type_flag;
	END IF;
        IF (p_channel_record.match_on_item_type_flag <>
						FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_item_type_flag :=
				p_channel_record.match_on_item_type_flag;
	END IF;
        IF (p_channel_record.match_on_time_flag <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.match_on_time_flag :=
				p_channel_record.match_on_time_flag;
	END IF;
      	IF (p_channel_record.expiration_date <> FND_API.G_MISS_DATE) THEN
	 l_channel_obj.expiration_date :=
				p_channel_record.expiration_date;
	END IF;
        IF (p_channel_record.application_id <> FND_API.G_MISS_NUM) THEN
	 l_channel_obj.application_id := p_channel_record.application_id;
	END IF;
        IF (p_channel_record.external_access_flag <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.external_access_flag :=
			p_channel_record.external_access_flag;
	END IF;
        IF (p_channel_record.item_match_count <> FND_API.G_MISS_NUM) THEN
	 l_channel_obj.item_match_count :=
			p_channel_record.item_match_count;
	END IF;
        IF (p_channel_record.last_match_time <> FND_API.G_MISS_DATE) THEN
	 l_channel_obj.last_match_time :=
			p_channel_record.last_match_time;
	END IF;
        IF (p_channel_record.notification_interval_type <>
				FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.notification_interval_type :=
				p_channel_record.notification_interval_type;
	END IF;
        IF (p_channel_record.last_notification_time <> FND_API.G_MISS_DATE) THEN
	 l_channel_obj.last_notification_time :=
				p_channel_record.last_notification_time;
	END IF;
        IF (p_channel_record.attribute_category <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute_category :=p_channel_record.attribute_category;
	END IF;
        IF (p_channel_record.attribute1 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute1 := p_channel_record.attribute1;
	END IF;
        IF (p_channel_record.attribute2 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute2 := p_channel_record.attribute2;
	END IF;
        IF (p_channel_record.attribute3 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute3 := p_channel_record.attribute3;
	END IF;
        IF (p_channel_record.attribute4 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute4 := p_channel_record.attribute4;
	END IF;
        IF (p_channel_record.attribute5 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute5 := p_channel_record.attribute5;
	END IF;
        IF (p_channel_record.attribute6 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute6 := p_channel_record.attribute6;
	END IF;
        IF (p_channel_record.attribute7 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute7 := p_channel_record.attribute7;
	END IF;
        IF (p_channel_record.attribute8 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute8 := p_channel_record.attribute8;
	END IF;
        IF (p_channel_record.attribute9 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute9 := p_channel_record.attribute9;
	END IF;
        IF (p_channel_record.attribute10 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute10 := p_channel_record.attribute10;
	END IF;
        IF (p_channel_record.attribute11 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute11 := p_channel_record.attribute11;
	END IF;
        IF (p_channel_record.attribute12 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute12 := p_channel_record.attribute12;
	END IF;
        IF (p_channel_record.attribute13 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute13 := p_channel_record.attribute13;
	END IF;
        IF (p_channel_record.attribute14 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute14 := p_channel_record.attribute14;
	END IF;
        IF (p_channel_record.attribute15 <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.attribute15 := p_channel_record.attribute15;
	END IF;
        IF (p_channel_record.description <> FND_API.G_MISS_CHAR) THEN
	 l_channel_obj.description := p_channel_record.description;
	END IF;

	IF (p_channel_record.channel_name <> FND_API.G_MISS_CHAR) THEN
	 IF (p_channel_record.channel_name <> l_channel_obj.channel_name) THEN
    	   -- Check if channel name exists
    	   Get_ChannelStatus (
        	x_return_status => x_return_status,
        	p_channel_name  => p_channel_record.channel_name,
        	p_category_id 	=> l_channel_obj.channel_category_id,
        	x_exist_flag    => l_channel_exist_flag,
		x_channel_id	=> l_channel_id_ex,
        	x_error_msg     => l_Error_Msg,
		x_error_token	=> l_Error_Token
        	);
    	   -- Update channel name if different
      	   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     	    	IF l_channel_exist_flag = FND_API.G_FALSE THEN
	     	  -- set channel name to new value only if it does not exist
	     	  l_channel_obj.channel_name := p_channel_record.channel_name;
		ELSE
          	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          	  THEN
               	    	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	    	FND_MESSAGE.Set_Token('TKN', l_Error_Token);
               	    	FND_MSG_PUB.Add;
          	  END IF;
          	  RAISE  FND_API.G_EXC_ERROR;
	    	END IF;
	   ELSE
          	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           	THEN
               	    	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	    	FND_MESSAGE.Set_Token('TKN', l_Error_Token);
               	    	FND_MSG_PUB.Add;
            	END IF;
          	RAISE  FND_API.G_EXC_ERROR;
	   END IF;
	 END IF;
	END IF;

	OPEN Get_ChnVersion_csr;
		FETCH Get_ChnVersion_csr INTO l_object_version_number;
	CLOSE Get_ChnVersion_csr;

	IF l_channel_obj.object_version_number = l_object_version_number THEN
	 -- Update channel record
	 BEGIN
	  AMV_C_CHANNELS_PKG.UPDATE_ROW(
	   x_channel_id => l_channel_id,
	   x_object_version_number => l_object_version_number + 1,
	   x_channel_type => l_channel_obj.channel_type,
	   x_channel_category_id => l_channel_obj.channel_category_id,
	   x_status => l_channel_obj.status,
	   x_owner_user_id => l_channel_obj.owner_user_id,
	   x_default_approver_user_id =>l_channel_obj.default_approver_user_id,
	   x_effective_start_date => l_channel_obj.effective_start_date,
	   x_expiration_date => l_channel_obj.expiration_date,
	   x_access_level_type => l_channel_obj.access_level_type,
	   x_pub_need_approval_flag => l_channel_obj.pub_need_approval_flag,
	   x_sub_need_approval_flag => l_channel_obj.sub_need_approval_flag,
	   x_match_on_all_criteria_flag=>l_channel_obj.match_on_all_criteria_flag,
	   x_match_on_keyword_flag => l_channel_obj.match_on_keyword_flag,
	   x_match_on_author_flag => l_channel_obj.match_on_author_flag,
	   x_match_on_perspective_flag => l_channel_obj.match_on_perspective_flag,
	   x_match_on_item_type_flag => l_channel_obj.match_on_item_type_flag,
	   x_match_on_content_type_flag=>l_channel_obj.match_on_content_type_flag,
	   x_match_on_time_flag => l_channel_obj.match_on_time_flag,
	   x_application_id => l_channel_obj.application_id,
	   x_external_access_flag => l_channel_obj.external_access_flag,
	   x_item_match_count => l_channel_obj.item_match_count,
	   x_last_match_time => l_channel_obj.last_match_time,
	   x_notification_interval_type=>l_channel_obj.notification_interval_type,
	   x_last_notification_time => l_channel_obj.last_notification_time,
	   x_attribute_category => l_channel_obj.attribute_category,
	   x_attribute1 => l_channel_obj.attribute1,
	   x_attribute2 => l_channel_obj.attribute2,
	   x_attribute3 => l_channel_obj.attribute3,
	   x_attribute4 => l_channel_obj.attribute4,
	   x_attribute5 => l_channel_obj.attribute5,
	   x_attribute6 => l_channel_obj.attribute6,
	   x_attribute7 => l_channel_obj.attribute7,
	   x_attribute8 => l_channel_obj.attribute8,
	   x_attribute9 => l_channel_obj.attribute9,
	   x_attribute10 => l_channel_obj.attribute10,
	   x_attribute11 => l_channel_obj.attribute11,
	   x_attribute12 => l_channel_obj.attribute12,
	   x_attribute13 => l_channel_obj.attribute13,
	   x_attribute14 => l_channel_obj.attribute14,
	   x_attribute15 => l_channel_obj.attribute15,
 	   x_last_update_date => sysdate,
	   x_last_updated_by => l_user_id,
	   x_last_update_login => l_login_user_id,
	   x_channel_name => l_channel_obj.channel_name,
	   x_description => l_channel_obj.description
	  );
	 EXCEPTION
         WHEN OTHERS THEN
                --will log the error
        	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
                	FND_MESSAGE.Set_Name('AMV', 'AMV_TABLE_HANDLER_ERROR');
                        FND_MESSAGE.Set_Token('ACTION', 'Updating');
                        FND_MESSAGE.Set_Token('TABLE', 'Channel');
                	FND_MSG_PUB.Add;
        	END IF;
                RAISE  FND_API.G_EXC_ERROR;
	 END;
	 -- invoke macthing engine for populating items into channel
	 AMV_MATCH_PVT.Request_ChannelMatch
	 (
		p_api_version       => l_api_version,
		x_return_status     => x_return_status,
		x_msg_count         => x_msg_count,
		x_msg_data          => x_msg_data,
		p_check_login_user  => FND_API.G_FALSE,
		p_channel_id        => l_channel_id
	 );
	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
	ELSE
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
             	FND_MESSAGE.Set_Name('AMV', 'AMV_CHN_VERSION_CHANGE');
              	FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
	END IF;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Update_Channel;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Channel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get the channel attributes of channel given by
--                 channel id (preferred) or channel name.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_channel_record                   OUT AMV_CHANNEL_OBJ_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_Channel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id        	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name      	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id       	IN  NUMBER   := FND_API.G_MISS_NUM,
      x_channel_record    	OUT NOCOPY  AMV_CHANNEL_OBJ_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_Channel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_Channel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check and return channel id for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status  => x_return_status,
        p_channel_id     => p_channel_id,
        p_channel_name   => p_channel_name,
        p_category_id 	 => p_category_id,
        x_exist_flag     => l_channel_exist_flag,
        x_channel_id     => l_channel_id,
        x_error_msg      => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- check if channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
	Get_ChannelRecord(l_channel_id, x_channel_record);
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_Channel;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Set_ChannelContentTypes
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Change content categories of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--                 p_content_type_id_array            IN  AMV_NUMBER_VARRAY_TYPE
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Set_ChannelContentTypes
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level    	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY  VARCHAR2,
      x_msg_count               OUT NOCOPY  NUMBER,
      x_msg_data                OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id              IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id             IN  NUMBER   := FND_API.G_MISS_NUM,
      p_content_type_id_array   IN  AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Set_ChannelContentTypes';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_setup_result   		varchar2(1);
l_update_channel_flag 	Varchar2(1);
l_chl_content_type_id	number;
--
CURSOR C_ChanContentType_Seq IS
select amv_c_content_types_s.nextval
from dual;
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Set_ChannelContent_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	   x_error_token	=> l_Error_Token
        );
    -- change channel categories if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', 'l_Error_Msg');
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     --
     AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => l_resource_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	  IF (l_setup_result = FND_API.G_TRUE) THEN
		l_update_channel_flag := FND_API.G_TRUE;
    	  ELSE
		IF (AMV_UTILITY_PVT.Get_UpdateChannelStatus(
								l_channel_id,
								l_resource_id,
								AMV_UTILITY_PVT.G_USER) )
		THEN
			l_update_channel_flag := FND_API.G_TRUE;
		ELSE
			-- user does not have privilege to create public channel
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           		FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  		FND_MSG_PUB.Add;
         		END IF;
	 		RAISE FND_API.G_EXC_ERROR;
		END IF;
	  END IF;
     ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    -- update channels if user has privilege
    IF l_update_channel_flag = FND_API.G_TRUE THEN

	-- remove old categories for the channel
	DELETE FROM amv_c_content_types
	WHERE channel_id = l_channel_id;

	-- set match on flag in channel table
	IF p_content_type_id_array.count > 0 THEN
		UPDATE 	amv_c_channels_b
		set	match_on_content_type_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_content_type_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- set match on all criteria flag
	IF Get_MatchOnStatus(l_channel_id) THEN
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- insert the new category id's for the channel
	FOR i in 1..p_content_type_id_array.count LOOP

	OPEN C_ChanContentType_Seq;
	  FETCH C_ChanContentType_Seq into l_chl_content_type_id;
	CLOSE C_ChanContentType_Seq;

	INSERT INTO amv_c_content_types
	(
		channel_content_type_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		channel_id,
		content_type_id
	)
	VALUES (
		l_chl_content_type_id,
		l_object_version_number,
		sysdate,
		l_user_id,
		sysdate,
		l_user_id,
		l_login_user_id,
		l_channel_id,
		p_content_type_id_array(i)
	);
	END LOOP;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Set_ChannelContent_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Set_ChannelContent_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Set_ChannelContent_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Set_ChannelContentTypes;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelContentTypes
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get content categories of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_content_type_id_array            OUT AMV_NUMBER_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelContentTypes
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status          	OUT NOCOPY  VARCHAR2,
      x_msg_count               OUT NOCOPY  NUMBER,
      x_msg_data                OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id              IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id             IN  NUMBER   := FND_API.G_MISS_NUM,
      x_content_type_id_array   OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_ChannelContentTypes';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_record_count		number := 1;
l_content_type_id	number;
--
CURSOR Get_Categories IS
select content_type_id
from   amv_c_content_types
where  channel_id = l_channel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ChannelContent_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- get channel categories if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     OPEN Get_Categories;
     x_content_type_id_array  := AMV_NUMBER_VARRAY_TYPE();
    	LOOP
    	FETCH Get_Categories INTO l_content_type_id;
    	EXIT WHEN Get_Categories%NOTFOUND;
		x_content_type_id_array.extend;
	  	x_content_type_id_array(l_record_count) := l_content_type_id;
	  	l_record_count := l_record_count + 1;
    	END LOOP;
     CLOSE Get_Categories;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ChannelContent_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ChannelContent_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ChannelContent_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ChannelContentTypes;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Set_ChannelPerspectives
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Change perspectives of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--                 p_perspective_id_array             IN  AMV_NUMBER_VARRAY_TYPE
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Set_ChannelPerspectives
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY  VARCHAR2,
      x_msg_count               OUT NOCOPY  NUMBER,
      x_msg_data                OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id              IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name           	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id             IN  NUMBER   := FND_API.G_MISS_NUM,
      p_perspective_id_array    IN  AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Set_ChannelPerspectives';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_setup_result   		varchar2(1);
l_update_channel_flag 	Varchar2(1);
l_chl_perspective_id	number;
--
CURSOR C_ChanPerspective_Seq IS
select amv_c_chl_perspectives_s.nextval
from dual;
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Set_ChannelPerspectives_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- change perspectives if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     --
     AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => l_resource_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	  IF (l_setup_result = FND_API.G_TRUE) THEN
		l_update_channel_flag := FND_API.G_TRUE;
    	  ELSE
		IF (AMV_UTILITY_PVT.Get_UpdateChannelStatus(
								l_channel_id,
								l_resource_id,
								AMV_UTILITY_PVT.G_USER) )
		THEN
			l_update_channel_flag := FND_API.G_TRUE;
		ELSE
			-- user does not have privilege to create public channel
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           		FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  		FND_MSG_PUB.Add;
         		END IF;
	 		RAISE FND_API.G_EXC_ERROR;
		END IF;
	  END IF;
     ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    -- update channels if user has privilege
    IF l_update_channel_flag = FND_API.G_TRUE THEN
	-- remove old perspectives for the channel
	DELETE FROM amv_c_chl_perspectives
	WHERE channel_id = l_channel_id;

	-- set match on flag in channel table
	IF p_perspective_id_array.count > 0 THEN
		UPDATE 	amv_c_channels_b
		set	match_on_perspective_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_perspective_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- set match on all criteria flag
	IF Get_MatchOnStatus(l_channel_id) THEN
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- insert the new perspectives id's for the channel
	FOR i in 1..p_perspective_id_array.count LOOP

	OPEN C_ChanPerspective_Seq;
	  FETCH C_ChanPerspective_Seq INTO l_chl_perspective_id;
	CLOSE C_ChanPerspective_Seq;

	INSERT INTO amv_c_chl_perspectives
	(
		channel_perspective_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		channel_id,
		perspective_id
	)
	VALUES (
		l_chl_perspective_id,
		l_object_version_number,
		sysdate,
		l_user_id,
		sysdate,
		l_user_id,
		l_login_user_id,
		l_channel_id,
		p_perspective_id_array(i)
	);
	END LOOP;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Set_ChannelPerspectives_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Set_ChannelPerspectives_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Set_ChannelPerspectives_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Set_ChannelPerspectives;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelPerspectives
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get perspectives of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_perspective_id_array             OUT AMV_NUMBER_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelPerspectives
(     p_api_version         	IN  NUMBER,
      p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level    	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status       	OUT NOCOPY  VARCHAR2,
      x_msg_count           	OUT NOCOPY  NUMBER,
      x_msg_data            	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id          	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name        	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id         	IN  NUMBER   := FND_API.G_MISS_NUM,
      x_perspective_id_array 	OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_ChannelPerspectives';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_record_count		number := 1;
l_perspective_id	number;
--
CURSOR Get_Perspectives IS
select perspective_id
from   amv_c_chl_perspectives
where  channel_id = l_channel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ChannelPerspectives_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- get channel perspectives if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     OPEN Get_Perspectives;
     x_perspective_id_array  := AMV_NUMBER_VARRAY_TYPE();
    	LOOP
    	FETCH Get_Perspectives INTO l_perspective_id;
    	EXIT WHEN Get_Perspectives%NOTFOUND;
		x_perspective_id_array.extend;
	  	x_perspective_id_array(l_record_count) := l_perspective_id;
	  	l_record_count := l_record_count + 1;
    	END LOOP;
     CLOSE Get_Perspectives;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ChannelPerspectives_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ChannelPerspectives_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ChannelPerspectives_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ChannelPerspectives;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Set_ChannelItemTypes
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Change user groups of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--                 p_item_type_array                  IN  AMV_CHAR_VARRAY_TYPE
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Set_ChannelItemTypes
(     p_api_version           	IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY  VARCHAR2,
      x_msg_count               OUT NOCOPY  NUMBER,
      x_msg_data                OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id              IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id       	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_item_type_array     	IN  AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Set_ChannelItemTypes';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_setup_result   		varchar2(1);
l_update_channel_flag 	Varchar2(1);
l_item_type_id		number;
--
CURSOR C_ChanItemType_Seq IS
select amv_c_item_types_s.nextval
from dual;
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Set_ChannelItems_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- change usergroups if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     --
     AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => l_resource_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	  IF (l_setup_result = FND_API.G_TRUE) THEN
		l_update_channel_flag := FND_API.G_TRUE;
    	  ELSE
		IF (AMV_UTILITY_PVT.Get_UpdateChannelStatus(
								l_channel_id,
								l_resource_id,
								AMV_UTILITY_PVT.G_USER) )
		THEN
			l_update_channel_flag := FND_API.G_TRUE;
		ELSE
			-- user does not have privilege to create public channel
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           		FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  		FND_MSG_PUB.Add;
         		END IF;
	 		RAISE FND_API.G_EXC_ERROR;
		END IF;
	  END IF;
     ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    -- update channels if user has privilege
    IF l_update_channel_flag = FND_API.G_TRUE THEN
	-- remove old groups for the channel
	DELETE FROM amv_c_item_types
	WHERE channel_id = l_channel_id;

	-- set match on flag in channel table
	IF p_item_type_array.count > 0 THEN
		UPDATE 	amv_c_channels_b
		set	match_on_item_type_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_item_type_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- set match on all criteria flag
	IF Get_MatchOnStatus(l_channel_id) THEN
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- insert the new groups id's for the channel
	FOR i in 1..p_item_type_array.count LOOP
	OPEN C_ChanItemType_Seq;
	 FETCH C_ChanItemType_Seq INTO l_item_type_id;
	CLOSE C_ChanItemType_Seq;

	INSERT INTO amv_c_item_types
	(
		channel_item_type_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		channel_id,
		item_type
	)
	VALUES (
		l_item_type_id,
		l_object_version_number,
		sysdate,
		l_user_id,
		sysdate,
		l_user_id,
		l_login_user_id,
		l_channel_id,
		p_item_type_array(i)
	);
	END LOOP;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Set_ChannelItems_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Set_ChannelItems_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Set_ChannelItems_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Set_ChannelItemTypes;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelItemTypes
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get user groups of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_item_type_array                  OUT AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelItemTypes
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY  VARCHAR2,
      x_msg_count               OUT NOCOPY  NUMBER,
      x_msg_data                OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id              IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id      	IN  NUMBER   := FND_API.G_MISS_NUM,
      x_item_type_array         OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_ChannelItemTypes';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_record_count		number := 1;
l_item_type		varchar2(30);
--
CURSOR Get_ItemTypes IS
select item_type
from   amv_c_item_types
where  channel_id = l_channel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ChannelItems_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- get channel groups if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     OPEN Get_ItemTypes;
     x_item_type_array := AMV_CHAR_VARRAY_TYPE();
    	LOOP
    	FETCH Get_ItemTypes INTO l_item_type;
    	EXIT WHEN Get_ItemTypes%NOTFOUND;
		x_item_type_array.extend;
	  	x_item_type_array(l_record_count) := l_item_type;
	  	l_record_count := l_record_count + 1;
    	END LOOP;
     CLOSE Get_ItemTypes;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_Get_ChannelItems_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ChannelItems_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ChannelItems_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ChannelItemTypes;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Set_ChannelKeywords
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Change keywords of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--                 p_keywords_array                   IN  AMV_CHAR_VARRAY_TYPE
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Set_ChannelKeywords
(     p_api_version      	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id       	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name     	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id      	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_keywords_array   	IN  AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Set_ChannelKeywords';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_setup_result   		varchar2(1);
l_update_channel_flag 	Varchar2(1);
l_keyword_id		number;
--
CURSOR C_ChanKeywordId_Seq IS
select amv_c_keywords_s.nextval
from dual;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Set_ChannelKeywords_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- change channel keywords if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     --
     AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => l_resource_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	  IF (l_setup_result = FND_API.G_TRUE) THEN
		l_update_channel_flag := FND_API.G_TRUE;
    	  ELSE
		IF (AMV_UTILITY_PVT.Get_UpdateChannelStatus(
								l_channel_id,
								l_resource_id,
								AMV_UTILITY_PVT.G_USER) )
		THEN
			l_update_channel_flag := FND_API.G_TRUE;
		ELSE
			-- user does not have privilege to create public channel
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           		FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  		FND_MSG_PUB.Add;
         		END IF;
	 		RAISE FND_API.G_EXC_ERROR;
		END IF;
	  END IF;
     ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    -- update channels if user has privilege
    IF l_update_channel_flag = FND_API.G_TRUE THEN
	-- remove old keywords for the channel
	DELETE FROM amv_c_keywords
	WHERE channel_id = l_channel_id;

	-- set match on flag in channel table
	IF p_keywords_array.count > 0 THEN
		UPDATE 	amv_c_channels_b
		set	match_on_keyword_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_keyword_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- set match on all criteria flag
	IF Get_MatchOnStatus(l_channel_id) THEN
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- insert new keywords for the channel
	FOR i in 1..p_keywords_array.count LOOP
	OPEN C_ChanKeywordId_Seq;
	  FETCH C_ChanKeywordId_Seq INTO l_keyword_id;
	CLOSE C_ChanKeywordId_Seq;
	INSERT INTO amv_c_keywords
	(
		channel_keyword_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		channel_id,
		keyword
	)
	VALUES (
		l_keyword_id,
		l_object_version_number,
		sysdate,
		l_user_id,
		sysdate,
		l_user_id,
		l_login_user_id,
		l_channel_id,
		initcap(p_keywords_array(i))
	);
	END LOOP;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Set_ChannelKeywords_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Set_ChannelKeywords_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Set_ChannelKeywords_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Set_ChannelKeywords;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelKeywords
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get keywords of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_keywords_array                   OUT AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelKeywords
(     p_api_version    		IN  NUMBER,
      p_init_msg_list  		IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status  		OUT NOCOPY  VARCHAR2,
      x_msg_count      		OUT NOCOPY  NUMBER,
      x_msg_data       		OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id     		IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name   		IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id    		IN  NUMBER   := FND_API.G_MISS_NUM,
      x_keywords_array 		OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_ChannelKeywords';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_record_count		number := 1;
l_keywords		varchar2(200);
--
CURSOR Get_Keywords IS
select keyword
from   amv_c_keywords
where  channel_id = l_channel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ChannelKeywords_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- get channel keywords if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     OPEN Get_Keywords;
     x_keywords_array := AMV_CHAR_VARRAY_TYPE();
    	LOOP
    	FETCH Get_Keywords INTO l_keywords;
    	EXIT WHEN Get_Keywords%NOTFOUND;
		x_keywords_array.extend;
	  	x_keywords_array(l_record_count) := l_keywords;
	  	l_record_count := l_record_count + 1;
    	END LOOP;
     CLOSE Get_Keywords;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ChannelKeywords_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ChannelKeywords_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ChannelKeywords_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ChannelKeywords;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Set_ChannelAuthors
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Change authors of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--                 p_authors_array                    IN  AMV_CHAR_VARRAY_TYPE
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Set_ChannelAuthors
(     p_api_version      	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id       	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name     	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id      	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_authors_array    	IN  AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Set_ChannelAuthors';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number := 1;
--
l_channel_id		number;
l_setup_result   		varchar2(1);
l_update_channel_flag 	Varchar2(1);
l_channel_exist_flag   	varchar2(1);
l_author_id		number;
--
CURSOR C_ChanAuthorId_Seq IS
select amv_c_authors_s.nextval
from dual;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Set_ChannelAuthors_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- change authors if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     --
     AMV_USER_PVT.Can_SetupChannel (
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_check_login_user => FND_API.G_FALSE,
		p_resource_id => l_resource_id,
		p_include_group_flag => FND_API.G_TRUE,
		x_result_flag => l_setup_result
		);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	  IF (l_setup_result = FND_API.G_TRUE) THEN
		l_update_channel_flag := FND_API.G_TRUE;
    	  ELSE
		IF (AMV_UTILITY_PVT.Get_UpdateChannelStatus(
								l_channel_id,
								l_resource_id,
								AMV_UTILITY_PVT.G_USER) )
		THEN
			l_update_channel_flag := FND_API.G_TRUE;
		ELSE
			-- user does not have privilege to create public channel
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
          		FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
           		FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  		FND_MSG_PUB.Add;
         		END IF;
	 		RAISE FND_API.G_EXC_ERROR;
		END IF;
	  END IF;
     ELSE
		-- error while user privilege check in Can_SetupChannel
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
          	FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
           	FND_MESSAGE.Set_Token('LEVEL','Channel');
         	  	FND_MSG_PUB.Add;
         	END IF;
	 	RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    -- update channels if user has privilege
    IF l_update_channel_flag = FND_API.G_TRUE THEN
	-- remove old authors for the channel
	DELETE FROM amv_c_authors
	WHERE channel_id = l_channel_id;

	-- set match on flag in channel table
	IF p_authors_array.count > 0 THEN
		UPDATE 	amv_c_channels_b
		set	match_on_author_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_author_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- set match on all criteria flag
	IF Get_MatchOnStatus(l_channel_id) THEN
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_TRUE
		where 	channel_id = l_channel_id;
	ELSE
		UPDATE 	amv_c_channels_b
		set	match_on_all_criteria_flag = FND_API.G_FALSE
		where 	channel_id = l_channel_id;
	END IF;

	-- insert the new authors for the channel
	FOR i in 1..p_authors_array.count LOOP
	OPEN C_ChanAuthorId_Seq;
	  FETCH C_ChanAuthorId_Seq INTO l_author_id;
	CLOSE C_ChanAuthorId_Seq;
	INSERT INTO amv_c_authors
	(
		channel_author_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		channel_id,
		author
	)
	VALUES (
		l_author_id,
		l_object_version_number,
		sysdate,
		l_user_id,
		sysdate,
		l_user_id,
		l_login_user_id,
		l_channel_id,
		initcap(p_authors_array(i))
	);
	END LOOP;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Set_ChannelAuthors_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Set_ChannelAuthors_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Set_ChannelAuthors_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Set_ChannelAuthors;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelAuthors
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get authors of the content channel.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_authors_array                    OUT AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelAuthors
(     p_api_version    		IN  NUMBER,
      p_init_msg_list  		IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status  		OUT NOCOPY  VARCHAR2,
      x_msg_count      		OUT NOCOPY  NUMBER,
      x_msg_data       		OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id     		IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name   		IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id    		IN  NUMBER   := FND_API.G_MISS_NUM,
      x_authors_array  		OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_ChannelAuthors';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
l_record_count		number := 1;
l_authors		varchar2(200);
--
CURSOR Get_Authors IS
select author
from   amv_c_authors
where  channel_id = l_channel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ChannelAuthors_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- get channel authors if  the channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     OPEN Get_Authors;
     x_authors_array := AMV_CHAR_VARRAY_TYPE();
    	LOOP
    	FETCH Get_Authors INTO l_authors;
    	EXIT WHEN Get_Authors%NOTFOUND;
		x_authors_array.extend;
	  	x_authors_array(l_record_count) := l_authors;
	  	l_record_count := l_record_count + 1;
    	END LOOP;
     CLOSE Get_Authors;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ChannelAuthors_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ChannelAuthors_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ChannelAuthors_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ChannelAuthors;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemsPerChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all documents matching the content channel given by
--                 channel id (preferred) or channel name.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                      IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--	           p_subset_request_rec		      IN AMV_REQUEST_OBJ_TYPE
--								Required
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_subset_return_rec 		      OUT AMV_RETURN_OBJ_TYPE
--                 x_document_id_array                OUT AMV_NUMBER_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemsPerChannel
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id        	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name      	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id       	IN  NUMBER   := FND_API.G_MISS_NUM,
	 p_item_status			IN  VARCHAR2 := AMV_UTILITY_PVT.G_APPROVED,
      p_subset_request_rec 	IN  AMV_REQUEST_OBJ_TYPE,
      x_subset_return_rec 	OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
      x_document_id_array OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name         	CONSTANT VARCHAR2(30) := 'Get_ItemsPerChannel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id			number;
l_login_user_id    	number;
l_login_user_status varchar2(30);
l_Error_Msg		varchar2(2000);
l_Error_Token       varchar2(80);
--
l_channel_id		NUMBER;
l_channel_exist_flag   	varchar2(1);
l_document_id		NUMBER;
l_itm_count      	NUMBER := 1;
l_fetch_count      	NUMBER := 0;
l_start_with       	NUMBER := 1;
l_returned_record_count	NUMBER;
l_next_record_position	NUMBER;
l_total_record_count	NUMBER;
--
CURSOR C_PendingItmCount IS
select count(cim.item_id)
from   amv_c_chl_item_match cim
,      jtf_amv_items_vl ib
where  cim.channel_id = p_channel_id
and    cim.approval_status_type = p_item_status
and    cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and    cim.available_for_channel_date <= sysdate
and    cim.item_id = ib.item_id;

CURSOR Get_PendingItems IS
select ib.item_id
from   amv_c_chl_item_match cim
,      jtf_amv_items_vl ib
where  cim.channel_id = p_channel_id
and    cim.approval_status_type = p_item_status
and    cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and    cim.item_id = ib.item_id
order by ib.effective_start_date;

CURSOR C_TotalItmCount IS
select count(cim.item_id)
from   amv_c_chl_item_match cim
,      jtf_amv_items_vl ib
where  cim.channel_id = p_channel_id
and    cim.approval_status_type = p_item_status
and    cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and    cim.available_for_channel_date <= sysdate
and    cim.item_id = ib.item_id
and    nvl(ib.effective_start_date, sysdate) <= sysdate + 1
and    nvl(ib.expiration_date, sysdate) >= sysdate;

CURSOR Get_Items IS
select ib.item_id
from   amv_c_chl_item_match cim
,      jtf_amv_items_vl ib
where  cim.channel_id = p_channel_id
and    cim.approval_status_type = p_item_status
and    cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and    cim.available_for_channel_date <= sysdate
and    cim.item_id = ib.item_id
and    nvl(ib.effective_start_date, sysdate) <= sysdate + 1
and    nvl(ib.expiration_date, sysdate) >= sysdate
order by ib.effective_start_date desc;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ItemsPerChannel_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_channel_id IS NULL OR p_channel_name IS NULL) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AMV', 'AMV_CHN_ID_OR_NAME_NULL');
            FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	   x_error_token	=> l_Error_Token);
    -- get items if channel exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
              FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
              FND_MESSAGE.Set_Token('TKN',l_Error_Token);
              FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     x_return_status := FND_API.G_RET_STS_SUCCESS;
    	--get the total items count:
    	IF (p_subset_request_rec.return_total_count_flag = FND_API.G_TRUE) THEN
		IF p_item_status = AMV_UTILITY_PVT.G_APPROVED THEN
			OPEN C_TotalItmCount;
	 			FETCH C_TotalItmCount INTO l_total_record_count;
			CLOSE C_TotalItmCount;
		ELSE
			OPEN C_PendingItmCount;
	 			FETCH C_PendingItmCount INTO l_total_record_count;
			CLOSE C_PendingItmCount;
		END IF;
	END IF;
	-- set the starting position for return record
	IF (p_subset_request_rec.start_record_position IS NOT NULL) THEN
	   l_start_with := p_subset_request_rec.start_record_position;
	END IF;
	-- fetch approved items
	IF p_item_status = AMV_UTILITY_PVT.G_APPROVED THEN
      OPEN  Get_Items;
       x_document_id_array := AMV_NUMBER_VARRAY_TYPE();
	  LOOP
        	FETCH Get_Items INTO l_document_id;
	   	EXIT WHEN Get_Items%NOTFOUND;
          IF (l_start_with <= l_itm_count AND
              l_fetch_count < p_subset_request_rec.records_requested) THEN
           	l_fetch_count := l_fetch_count + 1;
           	x_document_id_array.extend;
           	x_document_id_array(l_fetch_count) := l_document_id;
          END IF;
          IF (l_fetch_count >= p_subset_request_rec.records_requested) THEN
           	exit;
          END IF;
          l_itm_count := l_itm_count + 1;
	  END LOOP;
      CLOSE Get_Items;
     ELSE
      OPEN  Get_PendingItems;
       x_document_id_array := AMV_NUMBER_VARRAY_TYPE();
	  LOOP
        	FETCH Get_PendingItems INTO l_document_id;
	   	EXIT WHEN Get_PendingItems%NOTFOUND;
          IF (l_start_with <= l_itm_count AND
              l_fetch_count < p_subset_request_rec.records_requested) THEN
           	l_fetch_count := l_fetch_count + 1;
           	x_document_id_array.extend;
           	x_document_id_array(l_fetch_count) := l_document_id;
          END IF;
          IF (l_fetch_count >= p_subset_request_rec.records_requested) THEN
           	exit;
          END IF;
          l_itm_count := l_itm_count + 1;
	  END LOOP;
      CLOSE Get_PendingItems;
	END IF;
	l_returned_record_count := l_fetch_count;
	l_next_record_position := l_start_with + l_fetch_count;
	x_subset_return_rec.returned_record_count := l_returned_record_count;
	x_subset_return_rec.next_record_position := l_next_record_position;
	x_subset_return_rec.total_record_count := l_total_record_count;
	/*
	x_subset_return_rec := amv_return_obj_type(
						l_returned_record_count,
						l_next_record_position,
						l_total_record_count);
	*/
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ItemsPerChannel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ItemsPerChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ItemsPerChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ItemsPerChannel;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Set_ChannelApprovalStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Set the approval status (approve, reject, need more info.)
--                 given a channel  and a document.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                       IN  NUMBER    Optional
--                      the channel id. Default = FND_API.G_MISS_NUM
--                 p_channel_name                     IN  VARCHAR2  Optional
--                      the channel name. Default = FND_API.G_MISS_CHAR
--                    Either pass the channe id (preferred) or channel name
--                    to identify the channel.
--                 p_category_id                   IN  NUMBER    Optional
--                      the category id. Default = FND_API.G_MISS_NUM
--                 p_item_id                          IN  NUMBER    Required
--                 p_approval_status                  IN  NUMBER    Required
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Set_ChannelApprovalStatus
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id        	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_channel_name      	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_id       	IN  NUMBER   := FND_API.G_MISS_NUM,
      p_item_id           	IN  NUMBER,
      p_approval_status   	IN  VARCHAR2
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Set_ChannelApprovalStatus';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_channel_id		number;
l_channel_exist_flag   	varchar2(1);
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Set_ChannelApprovalStatus_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check channel id and status for a given channel id or channel name
    Get_ChannelStatus (
        x_return_status => x_return_status,
        p_channel_id    => p_channel_id,
        p_channel_name  => p_channel_name,
        p_category_id 	=> p_category_id,
        x_exist_flag    => l_channel_exist_flag,
        x_channel_id    => l_channel_id,
        x_error_msg     => l_Error_Msg,
	x_error_token	=> l_Error_Token
        );
    -- set channel approval status if it exists
    IF (l_channel_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
               	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
               	FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
	UPDATE 	amv_c_chl_item_match
	SET	approval_status_type = p_approval_status
	,	approval_date = sysdate
	,	last_update_date = sysdate
	,	last_updated_by = l_user_id
	,	last_update_login = l_login_user_id
	WHERE	channel_id = l_channel_id
	AND	item_id = p_item_id;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Set_ChannelApprovalStatus_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Set_ChannelApprovalStatus_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Set_ChannelApprovalStatus_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Set_ChannelApprovalStatus;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Channels
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all documents matching the input criteria.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_criteria_rec                     IN
--                                        AMV_CHANNEL_OBJ_TYPE  Required
--                 p_sort_by                          IN  VARCHAR2  Optional
--                                        Default = FND_API.G_MISS_CHAR
--	           p_subset_request_rec	IN AMV_REQUEST_OBJ_TYPE
--								Required
--    OUT        : x_return_status             	OUT VARCHAR2
--                 x_msg_count                 	OUT NUMBER
--                 x_msg_data                  	OUT VARCHAR2
--                 x_subset_return_rec 		OUT AMV_RETURN_OBJ_TYPE
--                 x_content_chan_array        	OUT AMV_CHANNEL_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Find_Channels
(     p_api_version       	IN  NUMBER,
      p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     	OUT NOCOPY  VARCHAR2,
      x_msg_count         	OUT NOCOPY  NUMBER,
      x_msg_data          	OUT NOCOPY  VARCHAR2,
      p_check_login_user 	IN  VARCHAR2 := FND_API.G_TRUE,
      p_criteria_rec      	IN  AMV_CHANNEL_OBJ_TYPE,
      p_sort_by           	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_subset_request_rec 	IN  AMV_REQUEST_OBJ_TYPE,
      x_subset_return_rec  	OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
      x_content_chan_array 	OUT NOCOPY  AMV_CHANNEL_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Find_Channels';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id 		number;
l_user_id		number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_cursor           CursorType;
l_sql_statement    VARCHAR2(4000);
l_sql_statement2   VARCHAR2(4000);
l_where_clause     VARCHAR2(4000) := '';
l_keyword          VARCHAR2(10) := ' WHERE ';
l_total_count      NUMBER := 1;
l_fetch_count      NUMBER := 0;
l_start_with       NUMBER;
l_next_position    NUMBER;
l_total_record_count   	NUMBER;
l_null		varchar2(30) := null;
--
l_channel_id			NUMBER;
l_object_version_number		NUMBER;
l_channel_name			VARCHAR2(80);
l_description			VARCHAR2(2000);
l_channel_type			VARCHAR2(30);
l_channel_category_id		NUMBER;
l_status			VARCHAR2(30);
l_owner_user_id			NUMBER;
l_default_approver_user_id	NUMBER;
l_effective_start_date		DATE;
l_expiration_date		DATE;
l_access_level_type		VARCHAR2(30);
l_need_approval_flag 		VARCHAR2(1);
l_pub_need_approval_flag 	VARCHAR2(1);
l_sub_need_approval_flag 	VARCHAR2(1);
l_match_on_all_criteria_flag	VARCHAR2(1);
l_match_on_keyword_flag		VARCHAR2(1);
l_match_on_author_flag		VARCHAR2(1);
l_match_on_perspective_flag	VARCHAR2(1);
l_match_on_item_type_flag	VARCHAR2(1);
l_match_on_content_type_flag	VARCHAR2(1);
l_match_on_time_flag		VARCHAR2(1);
l_application_id		NUMBER;
l_external_access_flag		VARCHAR2(1);
l_item_match_count		NUMBER;
l_last_match_time		DATE;
l_notification_interval_type	VARCHAR2(30);
l_last_notification_time	DATE;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Find_Channels_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
			x_resource_id => l_resource_id,
       		x_user_id     => l_user_id,
       		x_login_id    => l_login_user_id,
       		x_user_status => l_login_user_status
       		);
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
	   l_login_user_id := g_login_user_id;
	   l_user_id  := g_user_id;
	   l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    --Construct dynamic SQL statement based on the parameters.
    l_sql_statement := 	'SELECT b.channel_id, ' ||
			'	b.object_version_number, ' ||
			'	tl.channel_name, ' ||
			'	tl.description, ' ||
			'	b.channel_type, ' ||
			'	b.channel_category_id, ' ||
			'	b.status, ' ||
			'	b.owner_user_id, ' ||
			'	b.default_approver_user_id, ' ||
			'	b.effective_start_date, ' ||
			'	b.expiration_date, ' ||
			'	b.access_level_type, ' ||
			'	b.pub_need_approval_flag, ' ||
			'	b.sub_need_approval_flag, ' ||
			'	b.match_on_all_criteria_flag, ' ||
			'	b.match_on_keyword_flag, ' ||
			'	b.match_on_author_flag, ' ||
			'	b.match_on_perspective_flag, ' ||
			'	b.match_on_item_type_flag, ' ||
			'	b.match_on_content_type_flag, ' ||
			'	b.match_on_time_flag, ' ||
			'	b.application_id, ' ||
			'	b.external_access_flag, ' ||
			'	b.item_match_count, ' ||
			'	b.last_match_time, ' ||
			'	b.notification_interval_type, ' ||
			'	b.last_notification_time ' ||
			'FROM 	amv_c_channels_b b  ' ||
			',    	amv_c_channels_tl tl ';
    --Construct SQL statement for getting totaL count
    l_sql_statement2 := 'Select count(*) ' ||
			'FROM 	amv_c_channels_b b  ' ||
			',    	amv_c_channels_tl tl ';
    --Construct the WHERE clause
    IF (p_criteria_rec.channel_id <> FND_API.G_MISS_NUM) THEN
    	l_where_clause := l_where_clause || l_keyword ||
			'b.channel_id = ' || p_criteria_rec.channel_id;
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.channel_name <> FND_API.G_MISS_CHAR) THEN
	IF (p_criteria_rec.channel_name = '%') THEN
    	  l_where_clause := l_where_clause || l_keyword ||
			'tl.channel_name like '''||
				p_criteria_rec.channel_name ||'''';
	ELSE
    	  l_where_clause := l_where_clause || l_keyword ||
		' contains ( tl.channel_name , '''||
					p_criteria_rec.channel_name || ''', 1) > 0 ';
	END IF;
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.description <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
			'tl.description like ''' ||
		p_criteria_rec.description||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.channel_type <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
	  'b.channel_type = '''|| p_criteria_rec.channel_type||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.channel_category_id <> FND_API.G_MISS_NUM) THEN
    	l_where_clause := l_where_clause || l_keyword ||
	      'b.channel_category_id = ' || p_criteria_rec.channel_category_id;
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.status <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
			'b.status = ''' || p_criteria_rec.status||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.owner_user_id <> FND_API.G_MISS_NUM) THEN
    	l_where_clause := l_where_clause || l_keyword ||
			'b.owner_user_id = ' || p_criteria_rec.owner_user_id;
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.default_approver_user_id <> FND_API.G_MISS_NUM) THEN
    	l_where_clause := l_where_clause || l_keyword ||
			'b.default_approver_user_id = ' ||
				p_criteria_rec.default_approver_user_id;
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.effective_start_date <> FND_API.G_MISS_DATE) THEN
    	l_where_clause := l_where_clause || l_keyword ||
	    'to_char(b.effective_start_date,'||'''DD-MON-YY'''||') = '''||
		p_criteria_rec.effective_start_date||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.expiration_date <> FND_API.G_MISS_DATE) THEN
    	l_where_clause := l_where_clause || l_keyword ||
	    'to_char(b.expiration_date,'||'''DD-MON-YY'''||') = '''||
		p_criteria_rec.expiration_date||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.access_level_type <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.access_level_type = ''' ||p_criteria_rec.access_level_type||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.pub_need_approval_flag<>FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.pub_need_approval_flag = ''' ||
			p_criteria_rec.pub_need_approval_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.sub_need_approval_flag<>FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.sub_need_approval_flag = ''' ||
		p_criteria_rec.sub_need_approval_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.match_on_all_criteria_flag<>FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.match_on_all_criteria_flag = ''' ||
		p_criteria_rec.match_on_all_criteria_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.match_on_keyword_flag <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.match_on_all_keyword_flag = ''' ||
		p_criteria_rec.match_on_keyword_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.match_on_author_flag <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.match_on_author_flag = ''' ||
	 	p_criteria_rec.match_on_author_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.match_on_perspective_flag <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.match_on_perspective_flag = ''' ||
		p_criteria_rec.match_on_perspective_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.match_on_item_type_flag <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.match_on_item_type_flag = ''' ||
		p_criteria_rec.match_on_item_type_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.match_on_content_type_flag <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.match_on_content_type_flag = ''' ||
	 	p_criteria_rec.match_on_content_type_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.match_on_time_flag <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.match_on_time_flag = ''' ||
		p_criteria_rec.match_on_time_flag||'''';
	l_keyword := ' AND ';
    END IF;
--    IF (p_criteria_rec.application_id <> FND_API.G_MISS_NUM) THEN
--    	l_where_clause := l_where_clause || l_keyword ||
--		'b.application_id = ' || p_criteria_rec.application_id;
--	l_keyword := ' AND ';
--   END IF;
    IF (p_criteria_rec.external_access_flag <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.external_access_flag = ''' ||
		p_criteria_rec.external_access_flag||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.item_match_count <> FND_API.G_MISS_NUM) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.item_match_count = ' || p_criteria_rec.item_match_count;
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.last_match_time <> FND_API.G_MISS_DATE) THEN
    	l_where_clause := l_where_clause || l_keyword ||
	    'to_char(b.last_match_time,'||'''DD-MON-YY'''||') = ''' ||
		p_criteria_rec.last_match_time||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.notification_interval_type <> FND_API.G_MISS_CHAR) THEN
    	l_where_clause := l_where_clause || l_keyword ||
		'b.notification_interval_type = ''' ||
	 	p_criteria_rec.notification_interval_type||'''';
	l_keyword := ' AND ';
    END IF;
    IF (p_criteria_rec.last_notification_time <> FND_API.G_MISS_DATE) THEN
    	l_where_clause := l_where_clause || l_keyword ||
	      'to_char(b.last_notification_time,'||'''DD-MON-YY'''||') = ''' ||
		 p_criteria_rec.last_notification_time||'''';
	l_keyword := ' AND ';
    END IF;
    	l_where_clause := l_where_clause || l_keyword ||
			'	tl.language = userenv(' || '''lang''' || ') ' ||
			'AND	b.channel_id = tl.channel_id ';
    --
    l_sql_statement  := l_sql_statement  || l_where_clause;
    l_sql_statement2 := l_sql_statement2 || l_where_clause;
    -- Construct the ORDER BY clause
    IF (p_sort_by <> FND_API.G_MISS_CHAR) THEN
        l_sql_statement := l_sql_statement || ' ORDER BY ' || p_sort_by;
    ELSE
        l_sql_statement := l_sql_statement || ' ORDER BY tl.channel_name ';
    END IF;
    --Execute the SQL statements to get the total count:
    IF (p_subset_request_rec.return_total_count_flag = FND_API.G_TRUE) THEN
        OPEN  l_cursor FOR l_sql_statement2;
        FETCH l_cursor INTO l_total_record_count;
        CLOSE l_cursor;
    END IF;
    -- Set the starting position for the record
    l_start_with := p_subset_request_rec.start_record_position;
    --Now execute the SQL statement:
    OPEN l_cursor FOR l_sql_statement;
    x_content_chan_array := AMV_CHANNEL_VARRAY_TYPE();
      -- NOTE change to fetch into obj
    LOOP
      FETCH l_cursor INTO
		l_channel_id,
		l_object_version_number,
		l_channel_name,
		l_description,
		l_channel_type,
		l_channel_category_id,
		l_status,
		l_owner_user_id,
		l_default_approver_user_id,
		l_effective_start_date,
		l_expiration_date,
		l_access_level_type,
		l_pub_need_approval_flag,
		l_sub_need_approval_flag,
		l_match_on_all_criteria_flag,
		l_match_on_keyword_flag,
		l_match_on_author_flag,
		l_match_on_perspective_flag,
		l_match_on_item_type_flag,
		l_match_on_content_type_flag,
		l_match_on_time_flag,
		l_application_id,
		l_external_access_flag,
		l_item_match_count,
		l_last_match_time,
		l_notification_interval_type,
		l_last_notification_time;
      EXIT WHEN l_cursor%NOTFOUND;
      IF (l_start_with <= l_total_count AND
          l_fetch_count < p_subset_request_rec.records_requested) THEN
         l_fetch_count := l_fetch_count + 1;
         x_content_chan_array.extend;
	    x_content_chan_array(l_fetch_count).channel_id := l_channel_id;
	    x_content_chan_array(l_fetch_count).object_version_number :=
	                             l_object_version_number;
	    x_content_chan_array(l_fetch_count).channel_name :=l_channel_name;
	    x_content_chan_array(l_fetch_count).description :=l_description;
	    x_content_chan_array(l_fetch_count).channel_type :=l_channel_type;
	    x_content_chan_array(l_fetch_count).channel_category_id:=
	                             l_channel_category_id;
	    x_content_chan_array(l_fetch_count).status :=     l_status;
	    x_content_chan_array(l_fetch_count).owner_user_id :=l_owner_user_id;
	    x_content_chan_array(l_fetch_count).default_approver_user_id :=
	                             l_default_approver_user_id;
	    x_content_chan_array(l_fetch_count).effective_start_date :=
	                             l_effective_start_date;
	    x_content_chan_array(l_fetch_count).expiration_date:=l_expiration_date;
	    x_content_chan_array(l_fetch_count).access_level_type :=
	                             l_access_level_type;
	    x_content_chan_array(l_fetch_count).pub_need_approval_flag :=
	                             l_pub_need_approval_flag;
	    x_content_chan_array(l_fetch_count).sub_need_approval_flag :=
	                             l_sub_need_approval_flag;
	    x_content_chan_array(l_fetch_count).match_on_all_criteria_flag :=
	                             l_match_on_all_criteria_flag;
	    x_content_chan_array(l_fetch_count).match_on_keyword_flag :=
	                             l_match_on_keyword_flag;
	    x_content_chan_array(l_fetch_count).match_on_author_flag :=
	                             l_match_on_author_flag;
	    x_content_chan_array(l_fetch_count).match_on_perspective_flag :=
	                             l_match_on_perspective_flag;
	    x_content_chan_array(l_fetch_count).match_on_item_type_flag :=
	                             l_match_on_item_type_flag;
	    x_content_chan_array(l_fetch_count).match_on_content_type_flag :=
	                             l_match_on_content_type_flag;
	    x_content_chan_array(l_fetch_count).match_on_time_flag :=
	                             l_match_on_time_flag;
	    x_content_chan_array(l_fetch_count).application_id :=l_application_id;
	    x_content_chan_array(l_fetch_count).external_access_flag :=
	                             l_external_access_flag;
	    x_content_chan_array(l_fetch_count).item_match_count:=
							l_item_match_count;
	    x_content_chan_array(l_fetch_count).last_match_time :=
							l_last_match_time;
	    x_content_chan_array(l_fetch_count).notification_interval_type :=
	                             l_notification_interval_type;
	    x_content_chan_array(l_fetch_count).last_notification_time :=
	                             l_last_notification_time;
	    x_content_chan_array(l_fetch_count).attribute_category :=l_null;
	    x_content_chan_array(l_fetch_count).attribute1 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute2 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute3 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute4 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute5 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute6 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute7 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute8 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute9 :=      l_null;
	    x_content_chan_array(l_fetch_count).attribute10 :=     l_null;
	    x_content_chan_array(l_fetch_count).attribute11 :=     l_null;
	    x_content_chan_array(l_fetch_count).attribute12 :=     l_null;
	    x_content_chan_array(l_fetch_count).attribute13 :=     l_null;
	    x_content_chan_array(l_fetch_count).attribute14 :=     l_null;
	    x_content_chan_array(l_fetch_count).attribute15 :=     l_null;
	    /*
         x_content_chan_array(l_fetch_count) :=
		amv_channel_obj_type(
				l_channel_id,
				l_object_version_number,
				l_channel_name,
				l_description,
				l_channel_type,
				l_channel_category_id,
				l_status,
				l_owner_user_id,
				l_default_approver_user_id,
				l_effective_start_date,
				l_expiration_date,
				l_access_level_type,
				l_pub_need_approval_flag,
				l_sub_need_approval_flag,
				l_match_on_all_criteria_flag,
				l_match_on_keyword_flag,
				l_match_on_author_flag,
				l_match_on_perspective_flag,
				l_match_on_item_type_flag,
				l_match_on_content_type_flag,
				l_match_on_time_flag,
				l_application_id,
				l_external_access_flag,
				l_item_match_count,
				l_last_match_time,
				l_notification_interval_type,
				l_last_notification_time,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null,
				l_null);
		 */
      END IF;
      IF (l_fetch_count >= p_subset_request_rec.records_requested) THEN
         exit;
      END IF;
      l_total_count := l_total_count + 1;
    END LOOP;
    CLOSE l_cursor;

    l_next_position := p_subset_request_rec.start_record_position+l_fetch_count;
    x_subset_return_rec.returned_record_count := l_fetch_count;
    x_subset_return_rec.next_record_position := l_next_position;
    x_subset_return_rec.total_record_count := l_total_record_count;
    /*
    x_subset_return_rec := amv_return_obj_type (
						l_fetch_count,
						l_next_position,
						l_total_record_count);
    */
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Find_Channels_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Find_Channels_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Find_Channels_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Find_Channels;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_channel_pvt;

/
