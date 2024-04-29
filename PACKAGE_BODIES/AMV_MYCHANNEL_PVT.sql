--------------------------------------------------------
--  DDL for Package Body AMV_MYCHANNEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_MYCHANNEL_PVT" AS
/* $Header: amvvmycb.pls 120.1 2005/06/30 12:57:29 appldev ship $ */
--
--
-- NAME
--   AMV_MYCHANNEL_PVT
-- PURPOSE
--
-- HISTORY
--   08/16/1999        SLKRISHN        CREATED
--   11/09/2001	       VICHO	       UPDATED: Added a procedure to lauch channel
--                                              subscription workflow.
--   07/22/2003       SHARMA          Updated : fix for bug 2987210
--	 03/02/2004				SHARMA          Updated : bug fix 3260137
--
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMV_MYCHANNEL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'amvvmycb.pls';
--
--------------------------------------------------------------------------------
-- We use the following private utility procedures
--
----------------------------- Private Portion ---------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Validate_Subscription
(	x_return_status			OUT NOCOPY  VARCHAR2,
	p_user_or_group_id		IN  NUMBER,
	p_user_or_group_type		IN  VARCHAR2,
	p_subscribing_to_id		IN  NUMBER,
	p_subscribing_to_type		IN  VARCHAR2,
	x_valid_flag			OUT NOCOPY  VARCHAR2,
	x_mychannel_id			OUT NOCOPY  NUMBER,
	x_error_msg			OUT NOCOPY  VARCHAR2,
	x_error_token			OUT NOCOPY  VARCHAR2);
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Validate_Subscription
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if subscription parameters are valid
--    Parameters :
--                 p_user_or_group_id           IN  NUMBER    Required
--                 p_user_or_group_type        	IN  VARCHAR2  Required
--                 p_subscribing_to_id       	IN  NUMBER    Required
--                 p_subscribing_to_type       	IN  VARCHAR2  Required
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_valid_flag                 OUT VARCHAR2
--                    subscribtion parameters valid flag
--		   x_mychannel_id		OUT NUMBER,
--                 x_error_msg                  OUT VARCHAR2
--                    error message
--                 x_error_token                  OUT VARCHAR2
--                    error token
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Validate_Subscription
(	x_return_status			OUT NOCOPY  VARCHAR2,
	p_user_or_group_id		NUMBER,
	p_user_or_group_type		VARCHAR2,
	p_subscribing_to_id		NUMBER,
	p_subscribing_to_type		VARCHAR2,
	x_valid_flag			OUT NOCOPY  VARCHAR2,
	x_mychannel_id			OUT NOCOPY  NUMBER,
	x_error_msg			OUT NOCOPY  VARCHAR2,
	x_error_token			OUT NOCOPY  VARCHAR2
)
IS
--
CURSOR 	My_Channel IS
select 	my_channel_id
from		amv_u_my_channels
where	user_or_group_id = p_user_or_group_id
and		user_or_group_type = p_user_or_group_type
and		subscribing_to_id = p_subscribing_to_id
and		subscribing_to_type = p_subscribing_to_type;

BEGIN

    -- Initialize return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check if user or group is valid
    IF UPPER(p_user_or_group_type) = AMV_UTILITY_PVT.G_USER THEN
    	IF NOT AMV_UTILITY_PVT.Is_UserIdValid(p_user_or_group_id) THEN
	  x_error_msg := 'AMV_RESOURCE_ID_INVALID';
	  x_error_token := p_user_or_group_id;
	  RAISE FND_API.G_EXC_ERROR;
    	END IF;
    ELSIF UPPER(p_user_or_group_type) = AMV_UTILITY_PVT.G_GROUP THEN
    	IF NOT AMV_UTILITY_PVT.Is_GroupIdValid(p_user_or_group_id) THEN
	  x_error_msg := 'AMV_GROUP_ID_INVALID';
	  x_error_token := p_user_or_group_id;
	  RAISE FND_API.G_EXC_ERROR;
    	END IF;
    ELSE
	  x_error_msg := 'AMV_USER_OR_GROUP_TYPE_INVALID';
	  x_error_token := p_user_or_group_type;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- check if channel or category exists
    IF UPPER(p_subscribing_to_type) = AMV_UTILITY_PVT.G_CATEGORY THEN
	IF NOT AMV_UTILITY_PVT.Is_CategoryIdValid(p_subscribing_to_id) THEN
	  x_error_msg := 'AMV_CATEGORY_ID_INVALID';
	  x_error_token := p_subscribing_to_id;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
    ELSIF UPPER(p_subscribing_to_type) = AMV_UTILITY_PVT.G_CHANNEL THEN
	IF NOT AMV_UTILITY_PVT.Is_ChannelIdValid(p_subscribing_to_id) THEN
	  x_error_msg := 'AMV_CHANNEL_ID_INVALID';
	  x_error_token := p_subscribing_to_id;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
    ELSE
	  x_error_msg := 'AMV_SUB_TO_TYPE_INVALID';
	  x_error_token := p_subscribing_to_type;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN My_Channel;
	FETCH My_Channel INTO x_mychannel_id;
	IF My_Channel%NOTFOUND THEN
		x_mychannel_id := FND_API.G_MISS_NUM;
	END IF;
    CLOSE My_Channel;

    -- set validity to true
    x_valid_flag := FND_API.G_TRUE;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_valid_flag := FND_API.G_FALSE;
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_valid_flag := FND_API.G_FALSE;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_valid_flag := FND_API.G_FALSE;
       x_error_msg := 'AMV_SUB_VALIDATION_FAILED';
END Validate_Subscription;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Subscribe_Channel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Launch workflow to subscribe a channel for an user
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                     IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        	IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--		   p_check_login_user		IN  VARCHAR2  Optional
--			  Default = FND_API.G_TRUE
--                 p_channel_id                 IN  NUMBER    Required
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
PROCEDURE Subscribe_Channel
(     p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id	  IN  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Subscribe_Channel';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number := FND_API.G_MISS_NUM;
l_login_user_status     varchar2(30);
--
l_owner_name		varchar2(100);
l_owner_id		number;
--
CURSOR Get_OwnerIDAndName_csr (res_id IN NUMBER)IS
  select u.user_name, r.resource_id
  From   amv_rs_all_res_extns_vl r, fnd_user u
  where  r.resource_id = res_id
  and    u.user_id = r.user_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Subscribe_Channel_PVT;
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN  Get_OwnerIDAndName_csr (l_resource_id);
       FETCH Get_OwnerIDAndName_csr INTO l_owner_name, l_owner_id;
       IF (Get_OwnerIDAndName_csr%NOTFOUND) THEN
          CLOSE Get_OwnerIDAndName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
              FND_MESSAGE.Set_Token('ID',  to_char(nvl(l_resource_id,-1)));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    CLOSE Get_OwnerIDAndName_csr;

    -- Lauch WorkFlow Process: 'AMV_SUBSCRIPTION_APPROVAL'
    AMV_WFAPPROVAL_PVT.StartProcess (
	RequestorId	=>	l_resource_id,
	ChannelId	=>	p_channel_id,
	ProcessOwner	=>	l_owner_name,
	Workflowprocess =>	'AMV_SUBSCRIPTION_APPROVAL'
    );

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    -- Standard check of commit
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
       ROLLBACK TO  Subscribe_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Subscribe_Channel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Subscribe_Channel_PVT;
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
END Subscribe_Channel;




--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_Subscription
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Subscribe a channel/category for an user
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                     IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        	IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--		   p_check_login_user		IN VARCHAR2 Optional
--			  Default = FND_API.G_TRUE
--                 p_mychannel_obj              IN
--                                            AMV_MY_CHANNEL_OBJ_TYPE Required
--                         MyChannel data to be created.
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--                 x_mychannel_id           	OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_Subscription
(     p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
      p_mychannel_obj  	  IN  AMV_MY_CHANNEL_OBJ_TYPE,
      x_mychannel_id      OUT NOCOPY  NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Add_Subscribtion';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number := FND_API.G_MISS_NUM;
l_login_user_status     varchar2(30);
l_Error_Msg            	varchar2(2000);
l_Error_Token		varchar2(80);
l_object_version_number number := 1;
--
l_mychannel_id		number;
l_expiration_date	date;
l_order			number;
l_valid_flag		varchar2(1);
--
CURSOR MyChannelId_Seq IS
select amv_u_my_channels_s.nextval
from dual;

CURSOR MyChannelOrder IS
SELECT NVL(MAX(order_number) + 1, 1)
FROM   amv_u_my_channels
WHERE  user_or_group_id = p_mychannel_obj.user_or_group_id
and    user_or_group_type = p_mychannel_obj.user_or_group_type;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_Subscription_PVT;
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

    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
      -- Get the current (login) user id.
      AMV_UTILITY_PVT.Get_UserInfo(
			 x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --

    -- Validate the subscription
    Validate_Subscription (
	x_return_status => x_return_status,
	p_user_or_group_id => p_mychannel_obj.user_or_group_id,
	p_user_or_group_type => p_mychannel_obj.user_or_group_type,
	p_subscribing_to_id => p_mychannel_obj.subscribing_to_id,
	p_subscribing_to_type => p_mychannel_obj.subscribing_to_type,
	x_valid_flag => l_valid_flag,
	x_mychannel_id	=> l_mychannel_id,
	x_error_msg => l_Error_Msg,
	x_error_token => l_Error_Token
    );

    -- create subscription after validation
    IF l_valid_flag = FND_API.G_TRUE THEN
      IF l_mychannel_id <> FND_API.G_MISS_NUM THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_SUBSCRIPTION_EXISTS');
			 FND_MESSAGE.Set_Token('TKN',p_mychannel_obj.user_or_group_type);
                FND_MSG_PUB.Add;
       	END IF;
        RAISE  FND_API.G_EXC_ERROR;
      ELSE
    	-- set mychannel order
    	IF p_mychannel_obj.order_number = FND_API.G_MISS_NUM THEN
		OPEN MyChannelOrder;
	  		FETCH MyChannelOrder INTO l_order;
		CLOSE MyChannelOrder;
    	ELSE
		l_order := p_mychannel_obj.order_number;
    	END IF;

	-- Remove end date if already existing?
    	-- Select the channel sequence
    	OPEN MyChannelId_Seq;
         	FETCH MyChannelId_Seq INTO l_mychannel_id;
    	CLOSE MyChannelId_Seq;

    	-- Add a record in the mychannel
    	INSERT INTO amv_u_my_channels (
    		my_channel_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		user_or_group_id,
		user_or_group_type,
		subscribing_to_id,
		subscribing_to_type,
		subscription_reason_type,
		order_number,
		status,
		notify_flag,
		notification_interval_type
    	)
    	VALUES (
		l_mychannel_id,
		l_object_version_number,
        	sysdate,
        	l_user_id,
        	sysdate,
        	l_user_id,
        	l_login_user_id,
		p_mychannel_obj.user_or_group_id,
		p_mychannel_obj.user_or_group_type,
		p_mychannel_obj.subscribing_to_id,
		p_mychannel_obj.subscribing_to_type,
		p_mychannel_obj.subscription_reason_type,
		l_order,
		p_mychannel_obj.status,
		p_mychannel_obj.notify_flag,
		p_mychannel_obj.notification_interval_type
   	 );
      END IF;
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		-- NOTE change token name CATEGORY to generic name
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
       ROLLBACK TO  Add_Subscription_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_Subscription_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_Subscription_PVT;
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
END Add_Subscription;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Remove_Subscription
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete the subscription given p_mychannel_id.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                     IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user           IN VARCHAR2 Optional
--                        Default = FND_API.G_TRUE
--                 p_mychannel_id             	IN  NUMBER Required
--              	MyChannel Id
--                 p_user_or_group_id           IN  NUMBER Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_user_or_group_type         IN  VARCHAR2 Optional
--                        Default = FND_API.G_MISS_CHAR
--                 p_subscribing_to_id          IN  NUMBER Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_subscribing_to_type        IN  VARCHAR2 Optional
--                        Default = FND_API.G_MISS_CHAR
--              	Pass the user and subscription id and types
--              		instead of mychannel id.
--              	Must pass the mychannel id or the joint key of
--				above four values
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Remove_Subscription
(    p_api_version      IN  NUMBER,
     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status    OUT NOCOPY  VARCHAR2,
     x_msg_count        OUT NOCOPY  NUMBER,
     x_msg_data         OUT NOCOPY  VARCHAR2,
     p_check_login_user	IN  VARCHAR2 := FND_API.G_TRUE,
     p_mychannel_id     IN  NUMBER := FND_API.G_MISS_NUM,
     p_user_or_group_id IN  NUMBER := FND_API.G_MISS_NUM,
     p_user_or_group_type IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_subscribing_to_id IN  NUMBER := FND_API.G_MISS_NUM,
     p_subscribing_to_type IN  VARCHAR2 := FND_API.G_MISS_CHAR
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Remove_Subscription';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token		varchar2(80);
--
l_mychannel_id		number;
l_myuser_id		number;
l_myuser_type		varchar2(30) := 'USER';
l_sub_to_id		number;
l_sub_to_type		varchar2(30);
l_valid_flag		varchar2(1);
--
CURSOR MyChannel_Info IS
select user_or_group_id
,      user_or_group_type
,      subscribing_to_id
,      subscribing_to_type
from   amv_u_my_channels
where  my_channel_id = p_mychannel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Remove_Subscription_PVT;
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF p_mychannel_id = FND_API.G_MISS_NUM OR
       p_mychannel_id IS NULL
    THEN
    	-- Validate the subscription
    	Validate_Subscription (
		x_return_status => x_return_status,
		p_user_or_group_id => p_user_or_group_id,
		p_user_or_group_type => p_user_or_group_type,
		p_subscribing_to_id => p_subscribing_to_id,
		p_subscribing_to_type => p_subscribing_to_type,
		x_valid_flag => l_valid_flag,
		x_mychannel_id	=> l_mychannel_id,
		x_error_msg => l_Error_Msg,
		x_error_token => l_Error_Token
    	);
	IF l_valid_flag = FND_API.G_FALSE THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
                FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
	END IF;
	-- set to local variables
	l_myuser_id 	:= p_user_or_group_id;
	l_myuser_type 	:= p_user_or_group_type;
	l_sub_to_id 	:= p_subscribing_to_id;
	l_sub_to_type 	:= p_subscribing_to_type;
    ELSE
    	-- Get the user info for this subscription
    	OPEN MyChannel_Info;
     	FETCH MyChannel_Info INTO
		l_myuser_id, l_myuser_type, l_sub_to_id, l_sub_to_type;
    	CLOSE MyChannel_Info;
	-- assign mychannel value to local variable
	l_mychannel_id := p_mychannel_id;
    END IF;

    -- Remove subscription
    DELETE FROM amv_u_my_channels
    WHERE  my_channel_id = l_mychannel_id;
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
       ROLLBACK TO  Remove_Subscription_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Remove_Subscription_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Remove_Subscription_PVT;
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
END Remove_Subscription;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_MyChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update the mychannel given p_mychannel_id.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                     IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user           IN VARCHAR2 Optional
--                        Default = FND_API.G_TRUE
--                 p_mychannel_obj      IN  AMV_MY_CHANNEL_OBJ_TYPE Required
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_MyChannel
(    p_api_version      IN  NUMBER,
     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status    OUT NOCOPY  VARCHAR2,
     x_msg_count        OUT NOCOPY  NUMBER,
     x_msg_data         OUT NOCOPY  VARCHAR2,
     p_check_login_user IN  VARCHAR2 := FND_API.G_TRUE,
     p_mychannel_obj  	IN  AMV_MY_CHANNEL_OBJ_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_MyChannel';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token		varchar2(80);
--
l_valid_flag		varchar2(1);
l_mychannel_id		number;
l_order_number		number;
l_status		varchar2(30);
l_notify_flag		varchar2(1);
l_notif_interval_type 	varchar2(30);
--
CURSOR 	MyChannel IS
select	order_number
,		status
,		notify_flag
,		notification_interval_type
from		amv_u_my_channels
where	my_channel_id = l_mychannel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Update_MyChannel_PVT;
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF p_mychannel_obj.my_channel_id = FND_API.G_MISS_NUM OR
       p_mychannel_obj.my_channel_id IS NULL
    THEN
    	-- Validate the subscription
    	Validate_Subscription (
		x_return_status => x_return_status,
		p_user_or_group_id => p_mychannel_obj.user_or_group_id,
		p_user_or_group_type => p_mychannel_obj.user_or_group_type,
		p_subscribing_to_id => p_mychannel_obj.subscribing_to_id,
		p_subscribing_to_type => p_mychannel_obj.subscribing_to_type,
		x_valid_flag => l_valid_flag,
		x_mychannel_id	=> l_mychannel_id,
		x_error_msg => l_Error_Msg,
		x_error_token => l_Error_Token
    	);
	IF l_valid_flag = FND_API.G_TRUE THEN
	 IF l_mychannel_id = FND_API.G_MISS_NUM THEN
          	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          	THEN
          		FND_MESSAGE.Set_Name('AMV', 'AMV_SUBSCRIPTION_INVALID');
          		FND_MESSAGE.Set_Token('TKN',
							p_mychannel_obj.subscribing_to_id);
          		FND_MSG_PUB.Add;
          	END IF;
	  	RAISE  FND_API.G_EXC_ERROR;
	 END IF;
	ELSE
        	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
                	FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                	FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                	FND_MSG_PUB.Add;
        	END IF;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;
    ELSE
	-- check if my channel exists
	IF AMV_UTILITY_PVT.Is_MyChannelIdValid(p_mychannel_obj.my_channel_id)
	THEN
		l_mychannel_id := p_mychannel_obj.my_channel_id;
	END IF;
    END IF;

    -- Initialize with old values
    OPEN MyChannel;
    	FETCH MyChannel INTO 	l_order_number,
				l_status,
				l_notify_flag,
				l_notif_interval_type;
    CLOSE MyChannel;

    IF p_mychannel_obj.order_number <> FND_API.G_MISS_NUM THEN
		l_order_number := p_mychannel_obj.order_number;
    END IF;

    IF p_mychannel_obj.status <> FND_API.G_MISS_CHAR  OR
       p_mychannel_obj.status IS NOT NULL
    THEN
		l_status := p_mychannel_obj.status;
    END IF;

    IF p_mychannel_obj.notify_flag <> FND_API.G_MISS_CHAR OR
       p_mychannel_obj.notify_flag IS NOT NULL
    THEN
		l_notify_flag := p_mychannel_obj.notify_flag;
    END IF;

    IF p_mychannel_obj.notification_interval_type = FND_API.G_MISS_CHAR THEN
	l_notif_interval_type := p_mychannel_obj.notification_interval_type;
    END IF;

    UPDATE amv_u_my_channels
    SET	order_number 	= l_order_number
    ,	status 		= l_status
    ,	notify_flag 	= l_notify_flag
    ,	notification_interval_type = l_notif_interval_type
    WHERE my_channel_id = l_mychannel_id;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name) ;
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
       ROLLBACK TO  Update_MyChannel_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_MyChannel_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_MyChannel_PVT;
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
END Update_MyChannel;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_MyChannels
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all the channels for a given user (p_user_id)
--    Parameters :
--    IN           p_api_version        IN  NUMBER    	Required
--                 p_init_msg_list      IN  VARCHAR2  	Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER    	Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user   IN  VARCHAR2 	Optional
--                        Default = FND_API.G_TRUE
--                 p_user_id            IN  NUMBER    	Required
--                     the given user
--    OUT        : x_return_status   	OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_mychannel_array    OUT AMV_MY_CHANNEL_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_MyChannels
(    p_api_version      IN  NUMBER,
     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status    OUT NOCOPY  VARCHAR2,
     x_msg_count        OUT NOCOPY  NUMBER,
     x_msg_data         OUT NOCOPY  VARCHAR2,
     p_check_login_user IN  VARCHAR2 := FND_API.G_TRUE,
     p_user_id          IN  NUMBER,
     x_mychannel_array 	OUT NOCOPY  AMV_MY_CHANNEL_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_MyChannels';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token		varchar2(80);
--
l_mychannel_id		number;
l_user_or_group_id	number;
l_user_or_group_type	varchar2(30);
l_subscribing_to_id	number;
l_subscribing_to_type	varchar2(30);
l_subscription_reason_type	varchar2(30);
l_order_number		number;
l_status		varchar2(30);
l_notify_flag		varchar2(1);
l_notification_interval_type	varchar2(30);
l_record_count		number := 1;
l_channel_type	varchar2(30);
l_access_level_type	varchar2(30);
l_channel_id		number;
l_start_date		date;
l_end_date		date;
--
CURSOR 	My_Channels IS
select 	my_channel_id
,		user_or_group_id
,		user_or_group_type
,		subscribing_to_id
,		subscribing_to_type
,		subscription_reason_type
,		order_number
,		status
,		notify_flag
,		notification_interval_type
from   	amv_u_my_channels
where  	user_or_group_id = p_user_id
and    	user_or_group_type = AMV_UTILITY_PVT.G_USER
union
select 	my_channel_id
,		user_or_group_id
,		user_or_group_type
,		subscribing_to_id
,		subscribing_to_type
,		subscription_reason_type
,		order_number
,		status
,		notify_flag
,		notification_interval_type
from   	amv_u_my_channels
where  	user_or_group_id in (select 	group_id
						from   	jtf_rs_group_members
						where  	resource_id = p_user_id and
						delete_flag = 'N')
and    	user_or_group_type = AMV_UTILITY_PVT.G_GROUP;

CURSOR  Get_ChannelType_csr IS
select  channel_type
,	   access_level_type
,	   effective_start_date
,	   nvl(expiration_date,sysdate)
from	   amv_c_channels_b
where   channel_id = l_channel_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_MyChannels_PVT;
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_UserIdValid(p_user_id) THEN
      x_mychannel_array := AMV_MY_CHANNEL_VARRAY_TYPE();
	OPEN My_Channels;
	LOOP
		FETCH My_Channels INTO 	l_mychannel_id,
				l_user_or_group_id,
				l_user_or_group_type,
				l_subscribing_to_id,
				l_subscribing_to_type,
				l_subscription_reason_type,
				l_order_number,
				l_status,
				l_notify_flag,
				l_notification_interval_type;
		EXIT WHEN My_Channels%NOTFOUND;
		IF l_subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL THEN
		  l_channel_id := l_subscribing_to_id;
		  OPEN Get_ChannelType_csr;
			FETCH Get_ChannelType_csr INTO l_channel_type,
						 l_access_level_type,
						 l_start_date,
						 l_end_date;
		  CLOSE Get_ChannelType_csr;
		ELSE
			l_channel_type := null;
			l_access_level_type := null;
			l_start_date := sysdate;
			l_end_date := sysdate;
		END IF;
		IF (l_start_date <= sysdate) AND
		   (l_end_date >= sysdate)
		THEN
		  x_mychannel_array.extend;
		  x_mychannel_array(l_record_count).my_channel_id := l_mychannel_id;
		  x_mychannel_array(l_record_count).channel_type := l_channel_type;
		  x_mychannel_array(l_record_count).access_level_type :=
							l_access_level_type;
		  x_mychannel_array(l_record_count).user_or_group_id :=
							l_user_or_group_id;
		  x_mychannel_array(l_record_count).user_or_group_type :=
							l_user_or_group_type;
		  x_mychannel_array(l_record_count).subscribing_to_id :=
							l_subscribing_to_id;
		  x_mychannel_array(l_record_count).subscribing_to_type:=
		                    	l_subscribing_to_type;
		  x_mychannel_array(l_record_count).subscription_reason_type :=
		                    	l_subscription_reason_type;
		  x_mychannel_array(l_record_count).order_number := l_order_number;
		  x_mychannel_array(l_record_count).status :=l_status;
		  x_mychannel_array(l_record_count).notify_flag :=  l_notify_flag;
		  x_mychannel_array(l_record_count).notification_interval_type :=
		                    	l_notification_interval_type;
		  /*
		  x_mychannel_array(l_record_count) :=
			amv_my_channel_obj_type(
				l_mychannel_id,
				l_channel_type,
				l_access_level_type,
				l_user_or_group_id,
				l_user_or_group_type,
				l_subscribing_to_id,
				l_subscribing_to_type,
				l_subscription_reason_type,
				l_order_number,
				l_status,
				l_notify_flag,
				l_notification_interval_type);
		  */
	  	  l_record_count := l_record_count + 1;
		END IF;
	END LOOP;
	CLOSE My_Channels;

    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_RESOURCE_ID_INVALID');
                FND_MESSAGE.Set_Token('TKN',p_user_id);
                FND_MSG_PUB.Add;
        END IF;
       	RAISE  FND_API.G_EXC_ERROR;
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
       ROLLBACK TO  Get_MyChannels_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_MyChannels_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_MyChannels_PVT;
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
END Get_MyChannels;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_MyChannelsPerCategory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all channels in a category which an user has access to
--    Parameters :
--    IN           p_api_version        IN  NUMBER      Required
--                 p_init_msg_list      IN  VARCHAR2    Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER      Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user   IN  VARCHAR2    Optional
--                        Default = FND_API.G_TRUE
--                 p_user_id            IN  NUMBER      Required
--                     the given user
--                 p_category_id        IN  NUMBER      Required
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_channel_array      OUT AMV_NUMBER_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_MyChannelsPerCategory
(    p_api_version      IN  NUMBER,
     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status    OUT NOCOPY  VARCHAR2,
     x_msg_count        OUT NOCOPY  NUMBER,
     x_msg_data         OUT NOCOPY  VARCHAR2,
     p_check_login_user IN  VARCHAR2 := FND_API.G_TRUE,
     p_user_id          IN  NUMBER,
     p_category_id      IN  NUMBER,
     x_channel_array    OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_MyChannelsPerCategory';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token		varchar2(80);
--
l_channel_id		number;
l_record_count		number;
--
-- NOTE Channels should be based on user privilege
CURSOR Get_CategoryChannels IS
select channel_id
from   amv_c_channels_b
where  channel_category_id in (
                select b1.channel_category_id
                from   amv_c_categories_b b1
                where  b1.channel_category_id = p_category_id
                or     b1.channel_category_id in (
                        select b2.channel_category_id
                        from   amv_c_categories_b b2
                        where  b2.parent_channel_category_id = p_category_id))
and	channel_type = AMV_UTILITY_PVT.G_CONTENT
and	access_level_type = AMV_UTILITY_PVT.G_PUBLIC;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_MyChannelsPerCategory_PVT;
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    OPEN Get_CategoryChannels;
    x_channel_array := AMV_NUMBER_VARRAY_TYPE();
    LOOP
        FETCH Get_CategoryChannels INTO l_channel_id;
        EXIT WHEN Get_CategoryChannels%NOTFOUND;
                x_channel_array.extend;
                x_channel_array(l_record_count) := l_channel_id;
                l_record_count := l_record_count + 1;
    END LOOP;
    CLOSE Get_CategoryChannels;
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
       ROLLBACK TO  Get_MyChannelsPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_MyChannelsPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_MyChannelsPerCategory_PVT;
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
END  Get_MyChannelsPerCategory;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_MyNotifications
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all channels in a category which an user has access to
--    Parameters :
--    IN           p_api_version        IN  NUMBER      Required
--                 p_init_msg_list      IN  VARCHAR2    Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER      Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user   IN  VARCHAR2    Optional
--                        Default = FND_API.G_TRUE
--                 p_resource_id        IN  NUMBER      Optional
--                        Default = FND_API.G_MISS_NUM
--                     resource manager user id
--                 p_user_id            IN  NUMBER      Optional
--                        Default = FND_API.G_MISS_NUM
--                     fnd user id
--                 p_user_name          IN  VARCHAR2    Optional
--                        Default = FND_API.G_MISS_CHAR
--                     fnd user name
--                 p_notification_type  IN  VARCHAR2    Optional
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_notifications_array OUT AMV_WF_NOTIF_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_MyNotifications
(    p_api_version      IN  NUMBER,
     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status    OUT NOCOPY  VARCHAR2,
     x_msg_count        OUT NOCOPY  NUMBER,
     x_msg_data         OUT NOCOPY  VARCHAR2,
     p_check_login_user IN  VARCHAR2 := FND_API.G_TRUE,
     p_resource_id      IN  NUMBER := FND_API.G_MISS_NUM,
     p_user_id          IN  NUMBER := FND_API.G_MISS_NUM,
     p_user_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_notification_type IN  VARCHAR2 := FND_API.G_MISS_CHAR,
	x_notification_url    OUT NOCOPY   VARCHAR2,
     x_notifications_array OUT NOCOPY  AMV_WF_NOTIF_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_MyNotifications';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token		varchar2(80);
--
l_notification_id	number;
l_subject			varchar2(4000);
l_begin_date		date;
l_end_date		date;
l_due_date		date;
l_status			varchar2(30);
l_priority		number;
l_type			varchar2(30);
l_recipient_role	varchar2(30);
l_ntf_type		varchar2(8);
l_msg1_type		varchar2(30);
l_msg2_type		varchar2(30);
l_rec_num			number := 1;
--
CURSOR Get_Approvals IS
 SELECT N.NOTIFICATION_ID
 FROM WF_NOTIFICATIONS N
 WHERE N.RECIPIENT_ROLE = l_recipient_role
 AND N.MESSAGE_TYPE = 'AMV_APPR'
 AND N.STATUS = l_status
 AND EXISTS
 (SELECT NULL
        FROM WF_MESSAGE_ATTRIBUTES MA
        WHERE N.MESSAGE_TYPE = MA.MESSAGE_TYPE
        AND N.MESSAGE_NAME = MA.MESSAGE_NAME
        AND MA.SUBTYPE = 'RESPOND');

CURSOR Get_Notifications IS
select DISTINCT N.NOTIFICATION_ID
FROM   WF_NOTIFICATIONS_VIEW N
,      WF_MESSAGE_ATTRIBUTES_VL MA
WHERE  N.RECIPIENT_ROLE = l_recipient_role
AND    N.MESSAGE_TYPE = MA.MESSAGE_TYPE
AND    N.MESSAGE_NAME = MA.MESSAGE_NAME
AND	  MA.MESSAGE_NAME IN (
				select x.message_name
				from wf_message_attributes_vl x
				where x.subtype = 'SEND'
				and NOT EXISTS(
					select '1'
					from wf_message_attributes_vl b
					where b.subtype = 'RESPOND'
					and b.message_name = MA.MESSAGE_NAME)
				)
AND    N.MESSAGE_TYPE = 'AMV_APPR'
AND    N.STATUS = l_status;

CURSOR Get_NotifDetails IS
select SUBJECT
,	  BEGIN_DATE
,	  END_DATE
,	  DUE_DATE
,	  STATUS
,	  PRIORITY
FROM   WF_NOTIFICATIONS_VIEW
WHERE  NOTIFICATION_ID = l_notification_id
AND    RECIPIENT_ROLE = l_recipient_role
AND    STATUS = l_status
ORDER BY BEGIN_DATE;

CURSOR Get_ResourceUserName IS
select FND.USER_NAME
from	 JTF_RS_RESOURCE_EXTNS RD
,	 FND_USER FND
where RD.USER_ID = FND.USER_ID
and	 RD.RESOURCE_ID = p_resource_id;

CURSOR Get_FndUserName IS
select USER_NAME
from	  FND_USER
where  USER_ID = p_user_id;

-- Getting workflow web agent
CURSOR Get_WebAgent IS
select text from wf_resources
where name = 'WF_WEB_AGENT'
and language = 'US';

--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_MyNotifications;
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_notification_url := wf_core.translate('WF_WEB_AGENT');
    --
    IF p_user_id = FND_API.G_MISS_NUM OR
	  p_user_id is null
    THEN
	IF  p_resource_id = FND_API.G_MISS_NUM OR
	    p_resource_id is null
	THEN
	 IF p_user_name is not null THEN
		l_recipient_role := p_user_name;
	 ELSE
        	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	 THEN
                	FND_MESSAGE.Set_Name('AMV', 'AMV_NOTIF_NO_VALS');
                	FND_MSG_PUB.Add;
        	 END IF;
        	 RAISE  FND_API.G_EXC_ERROR;
	 END IF;
	ELSE
		OPEN Get_ResourceUserName;
			FETCH Get_ResourceUserName INTO l_recipient_role;
		CLOSE Get_ResourceUserName;
		IF l_recipient_role is null THEN
        	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        	 THEN
		  	-- NOTE change token name CATEGORY to generic name
             	FND_MESSAGE.Set_Name('AMV', 'AMV_RESOURCE_ID_INVALID');
              	FND_MESSAGE.Set_Token('TKN',p_resource_id);
              	FND_MSG_PUB.Add;
        	 END IF;
        	 RAISE  FND_API.G_EXC_ERROR;
		END IF;
	END IF;
    ELSE
	OPEN Get_FndUserName;
		FETCH Get_FndUserName INTO l_recipient_role;
	CLOSE Get_FndUserName;
	IF l_recipient_role is null THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
	  -- NOTE change token name CATEGORY to generic name
       	FND_MESSAGE.Set_Name('AMV', 'AMV_INVALID_USER_ID');
          FND_MESSAGE.Set_Token('TKN',p_user_id);
          FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    IF p_notification_type = 'NOTIFICATION' THEN
	l_status   := 'OPEN';
     x_notifications_array := AMV_WF_NOTIF_VARRAY_TYPE();
     OPEN Get_Notifications;
	 LOOP
		FETCH Get_Notifications INTO l_notification_id;
		EXIT WHEN Get_Notifications%NOTFOUND;

		OPEN Get_NotifDetails;
			FETCH Get_NotifDetails INTO
						l_subject,
						l_begin_date,
						l_end_date,
						l_due_date,
						l_status,
						l_priority;
		CLOSE Get_NotifDetails;
		x_notifications_array.extend;
		x_notifications_array(l_rec_num).notification_id := l_notification_id;
		x_notifications_array(l_rec_num).subject := l_subject;
		x_notifications_array(l_rec_num).begin_date := l_begin_date;
		x_notifications_array(l_rec_num).end_date := l_end_date;
		x_notifications_array(l_rec_num).due_date := l_due_date;
		x_notifications_array(l_rec_num).status := l_status;
		x_notifications_array(l_rec_num).priority := l_priority;
		x_notifications_array(l_rec_num).type := p_notification_type;
		/*
		x_notifications_array(l_rec_num) :=
					amv_wf_notif_obj_type(
							l_notification_id,
						    	l_subject,
							l_begin_date,
							l_end_date,
							l_due_date,
							l_status,
							l_priority,
							p_notification_type );
		*/
		l_rec_num := l_rec_num + 1;
	 END LOOP;
     CLOSE Get_Notifications;
    ELSIF p_notification_type = 'APPROVAL' THEN
	l_status   := 'OPEN';
     x_notifications_array := AMV_WF_NOTIF_VARRAY_TYPE();
     OPEN Get_Approvals;
	 LOOP
		FETCH Get_Approvals INTO l_notification_id;
		EXIT WHEN Get_Approvals%NOTFOUND;

		OPEN Get_NotifDetails;
			FETCH Get_NotifDetails INTO
						l_subject,
						l_begin_date,
						l_end_date,
						l_due_date,
						l_status,
						l_priority;
		CLOSE Get_NotifDetails;
		x_notifications_array.extend;
		x_notifications_array(l_rec_num).notification_id := l_notification_id;
		x_notifications_array(l_rec_num).subject := l_subject;
		x_notifications_array(l_rec_num).begin_date := l_begin_date;
		x_notifications_array(l_rec_num).end_date := l_end_date;
		x_notifications_array(l_rec_num).due_date := l_due_date;
		x_notifications_array(l_rec_num).status := l_status;
		x_notifications_array(l_rec_num).priority := l_priority;
		x_notifications_array(l_rec_num).type := p_notification_type;
		/*
		x_notifications_array(l_rec_num) :=
						amv_wf_notif_obj_type(
							l_notification_id,
							l_subject,
							l_begin_date,
							l_end_date,
							l_due_date,
							l_status,
							l_priority,
							p_notification_type );
		 */
		l_rec_num := l_rec_num + 1;
	 END LOOP;
     CLOSE Get_Approvals;
    END IF;
    --
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
       ROLLBACK TO  Get_MyNotifications;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_MyNotifications;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_MyNotifications;
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
END  Get_MyNotifications;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemsPerUser
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all items a user can access based channel/cat access
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Required
--                 p_include_subcats             IN  VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--                 x_items_array          	 OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemsPerUser
(     p_api_version      	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_user_id      		IN  NUMBER,
	 p_request_obj			IN  AMV_REQUEST_OBJ_TYPE,
	 x_return_obj			OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
      x_items_array 		OUT NOCOPY  AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
l_api_name         	CONSTANT VARCHAR2(30) := 'Get_ItemsPerUser';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           	number;
l_user_id     			number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number;
l_application_id	number;
--
l_record_count		NUMBER := 0;
l_total_count		NUMBER := 0;
l_temp_total		NUMBER := 0;
l_counter 		NUMBER := 1;
l_channel_id		number;
l_category_level	number := 1;
l_category_hr		amv_cat_hierarchy_varray_type;
l_item_id			number;
l_item_name		varchar2(240);

-- NOTE not used now reason bug fix 3260137
CURSOR 	Get_MyChannels IS
select 	subscribing_to_id
from   	amv_u_my_channels
where  	user_or_group_id in (select 	group_id
						from   	jtf_rs_group_members
						where  	resource_id = p_user_id)
and    	user_or_group_type = AMV_UTILITY_PVT.G_GROUP
and		subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL
union
select 	subscribing_to_id
from		amv_u_my_channels
where	user_or_group_id = p_user_id
and		user_or_group_type = AMV_UTILITY_PVT.G_USER
and		subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL;

-- NOTE currently not used
CURSOR 	Get_MyCategories IS
select 	subscribing_to_id
from   	amv_u_my_channels
where  	user_or_group_id in (select 	group_id
						from   	jtf_rs_group_members
						where  	resource_id = p_user_id
						and  	delete_flag <> 'Y')
and    	user_or_group_type = AMV_UTILITY_PVT.G_GROUP
and		subscribing_to_type = AMV_UTILITY_PVT.G_CATEGORY
union
select 	subscribing_to_id
from		amv_u_my_channels
where	user_or_group_id = p_user_id
and		user_or_group_type = AMV_UTILITY_PVT.G_USER
and		subscribing_to_type = AMV_UTILITY_PVT.G_CATEGORY;

CURSOR Get_CategoryItems_csr IS
select ib.item_id
,      ib.item_name
,			 cim.channel_id
from   amv_c_chl_item_match cim
,      jtf_amv_items_vl ib
where  cim.channel_id in (select 	subscribing_to_id
from   	amv_u_my_channels
where  	user_or_group_id in (select 	group_id
						from   	jtf_rs_group_members
						where  	resource_id = p_user_id)
and    	user_or_group_type = AMV_UTILITY_PVT.G_GROUP
and		subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL
union
select 	subscribing_to_id
from		amv_u_my_channels
where	user_or_group_id = p_user_id
and		user_or_group_type = AMV_UTILITY_PVT.G_USER
and		subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL )
and    cim.approval_status_type = AMV_UTILITY_PVT.G_APPROVED
and    cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and    cim.available_for_channel_date <= sysdate
and    cim.item_id = ib.item_id
and    nvl(ib.effective_start_date, sysdate) <= sysdate + 1
and    nvl(ib.expiration_date, sysdate) >= sysdate
order by ib.effective_start_date desc;

CURSOR Get_ItemsTotal_csr IS
select count(cim.item_id)
from   amv_c_chl_item_match cim
,      jtf_amv_items_vl ib
where  cim.channel_id in (select 	subscribing_to_id
from   	amv_u_my_channels
where  	user_or_group_id in (select 	group_id
						from   	jtf_rs_group_members
						where  	resource_id = p_user_id)
and    	user_or_group_type = AMV_UTILITY_PVT.G_GROUP
and		subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL
union
select 	subscribing_to_id
from		amv_u_my_channels
where	user_or_group_id = p_user_id
and		user_or_group_type = AMV_UTILITY_PVT.G_USER
and		subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL )
and    cim.approval_status_type = AMV_UTILITY_PVT.G_APPROVED
and    cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and    cim.available_for_channel_date <= sysdate
and    cim.item_id = ib.item_id
and    nvl(ib.effective_start_date, sysdate) <= sysdate + 1
and    nvl(ib.expiration_date, sysdate) >= sysdate;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ItemsPerUser;
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    x_items_array := AMV_CAT_HIERARCHY_VARRAY_TYPE();



   -- get the total number of items in category
	 OPEN Get_ItemsTotal_csr;
		FETCH Get_ItemsTotal_csr INTO l_total_count;
	 CLOSE Get_ItemsTotal_csr;

	 IF l_total_count < p_request_obj.start_record_position THEN
		l_counter := l_total_count + 1;
	 ELSE
		OPEN Get_CategoryItems_csr;
	  LOOP
			FETCH Get_CategoryItems_csr INTO l_item_id, l_item_name, l_channel_id;
    	EXIT WHEN Get_CategoryItems_csr%NOTFOUND;

	  	IF (l_counter >= p_request_obj.start_record_position) AND
	        (l_record_count <= p_request_obj.records_requested)
	  	THEN
	  		l_record_count := l_record_count + 1;
	  		x_items_array.extend;
				x_items_array(l_record_count).hierarchy_level := l_channel_id;
				x_items_array(l_record_count).id := l_item_id;
				x_items_array(l_record_count).name := l_item_name;
				/*
	  		x_items_array(l_record_count) :=
				amv_cat_hierarchy_obj_type( l_channel_id,
									   l_item_id,
									   l_item_name);
				*/
	  	END IF;
	  	EXIT WHEN l_record_count = p_request_obj.records_requested;
	  	l_counter := l_counter + 1;
	    END LOOP;
       CLOSE Get_CategoryItems_csr;
	 END IF;
		x_return_obj.returned_record_count := l_record_count;
    x_return_obj.next_record_position :=
         p_request_obj.start_record_position + l_record_count;
    x_return_obj.total_record_count := l_total_count;
    /*
    x_return_obj := amv_return_obj_type(
					l_record_count,
					p_request_obj.start_record_position + l_record_count,
					l_total_count);
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
       ROLLBACK TO  Get_ItemsPerUser;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ItemsPerUser;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ItemsPerUser;
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
END Get_ItemsPerUser;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserItems
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all items user owns
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Required
--                 p_include_subcats             IN  VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--                 x_items_array          	 OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_UserItems
(     p_api_version      	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
	 p_application_id		IN  NUMBER,
      p_user_id      		IN  NUMBER,
	 p_request_obj			IN  AMV_REQUEST_OBJ_TYPE,
	 x_return_obj			OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
      x_items_array 		OUT NOCOPY  AMV_ITEMDISPLAY_VARRAY_TYPE
)
IS
l_api_name         	CONSTANT VARCHAR2(30) := 'Get_UserItems';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           	number;
l_user_id     			number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number;
l_application_id	number;
--
l_record_count		NUMBER := 0;
l_total_count		NUMBER := 0;
l_counter 		NUMBER := 1;
l_channel_id		number;
l_item_id			number;
l_item_name		varchar2(240);
l_description		varchar2(2000);
l_item_type		varchar2(30);

-- fixed bug 3415777
CURSOR Get_MyItems_csr IS
select item_id
,      item_name
,	  description
,	  item_type
from   jtf_amv_items_vl
where  owner_id = p_user_id
and	  application_id = p_application_id
and  nvl( expiration_date, sysdate ) >= sysdate
and   nvl(effective_start_date, sysdate) <= sysdate
order by item_name;

CURSOR Get_ItemsTotal_csr IS
select count(item_id)
from   jtf_amv_items_vl
where  owner_id = p_user_id
and  nvl( expiration_date, sysdate ) >= sysdate
and   nvl(effective_start_date, sysdate) <= sysdate
and	  application_id = p_application_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_UserItems;
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    x_items_array := AMV_ITEMDISPLAY_VARRAY_TYPE();

    -- get the total number of items in category
    OPEN Get_ItemsTotal_csr;
		FETCH Get_ItemsTotal_csr INTO l_total_count;
    CLOSE Get_ItemsTotal_csr;

    IF l_total_count < p_request_obj.start_record_position THEN
		l_counter := l_total_count;
    ELSE
    	  OPEN Get_MyItems_csr;
	   LOOP
    	  	FETCH Get_MyItems_csr INTO l_item_id,l_item_name,l_description,l_item_type;
    	  	EXIT WHEN Get_MyItems_csr%NOTFOUND;
	  	IF (l_counter >= p_request_obj.start_record_position) AND
	        (l_record_count <= p_request_obj.records_requested)
	  	THEN
	  		l_record_count := l_record_count + 1;
	  		x_items_array.extend;
			x_items_array(l_record_count).id := l_item_id;
			x_items_array(l_record_count).name := l_item_name;
			x_items_array(l_record_count).description := l_description;
			x_items_array(l_record_count).type := l_item_type;
	  	END IF;
	  	EXIT WHEN l_record_count = p_request_obj.records_requested;
	  	l_counter := l_counter + 1;
	    END LOOP;
       CLOSE Get_MyItems_csr;
    END IF;

    x_return_obj.returned_record_count := l_record_count;
    x_return_obj.next_record_position :=
         p_request_obj.start_record_position + l_record_count;
    x_return_obj.total_record_count := l_total_count;
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
       ROLLBACK TO  Get_UserItems;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_UserItems;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_UserItems;
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
END Get_UserItems;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Can_UserMaintainChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all items  published by the user
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_user_id                     IN  NUMBER    Required
--                 p_include_subcats             IN  VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--                 x_items_array              OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Can_UserMaintainChannel
(     p_api_version           IN  NUMBER,
	 p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	 x_return_status         OUT NOCOPY  VARCHAR2,
	 x_msg_count             OUT NOCOPY  NUMBER,
	 x_msg_data              OUT NOCOPY  VARCHAR2,
	 p_check_login_user      IN  VARCHAR2 := FND_API.G_TRUE,
	 p_user_id               IN  NUMBER,
	 p_channel_id            IN  NUMBER,
	 x_maintain_flag		OUT NOCOPY  VARCHAR2
)
IS
l_api_name         	CONSTANT VARCHAR2(30) := 'Can_UserMaintainChannel';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           	number;
l_user_id     			number;
l_login_user_id     	number;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
l_object_version_number	number;
l_application_id		number;
--
l_owner_id			number;
l_approver_id			number;
l_approver_flag		varchar2(1);

CURSOR Get_OwnerAppr_csr IS
select owner_user_id
,      default_approver_user_id
from   amv_c_channels_vl
where  channel_id = p_channel_id;

CURSOR Get_SecAppr_csr IS
select chl_approver_flag
from   amv_u_access
where  access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
and    access_to_table_record_id = p_channel_id
and    user_or_group_type = AMV_UTILITY_PVT.G_USER
and    user_or_group_id = p_user_id
and	  effective_start_date <= sysdate
and	  nvl(expiration_date, sysdate) >= sysdate;

BEGIN
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
		l_login_user_id := -1;
		l_user_id  := -1;
		l_resource_id := -1;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    OPEN Get_OwnerAppr_csr;
	    FETCH Get_OwnerAppr_csr INTO l_approver_id, l_owner_id;
    CLOSE Get_OwnerAppr_csr;

    IF l_approver_id = p_user_id THEN
		x_maintain_flag := FND_API.G_TRUE;
    ELSIF l_owner_id = p_user_id THEN
		x_maintain_flag := FND_API.G_TRUE;
    ELSE
    		OPEN Get_SecAppr_csr;
	    		FETCH Get_SecAppr_csr INTO x_maintain_flag;
    		CLOSE Get_SecAppr_csr;

    		IF x_maintain_flag <> FND_API.G_TRUE THEN
		    	x_maintain_flag := FND_API.G_FALSE;
    		END IF;
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
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
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
END Can_UserMaintainChannel;
--------------------------------------------------------------------------------
--
END amv_mychannel_pvt;

/
