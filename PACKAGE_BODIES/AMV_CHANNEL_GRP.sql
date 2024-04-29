--------------------------------------------------------
--  DDL for Package Body AMV_CHANNEL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CHANNEL_GRP" AS
/* $Header: amvgchab.pls 120.1 2005/06/21 17:49:54 appldev ship $ */
--
-- NAME
--   AMV_CHANNEL_GRP
-- PURPOSE
--
-- HISTORY
--   01/29/2000        SLKRISHN        CREATED
--
--
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AMV_CHANNEL_GRP';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'amvgchab.pls';
-- This package contains the following procedures
--
--------------------------------------------------------------------------------
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
      p_channel_record    	IN  AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name  varchar2(30) := 'Add_PublicChannel';
BEGIN

	AMV_CHANNEL_PVT.Add_PublicChannel
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_record    =>  p_channel_record,
      	x_channel_id        =>  x_channel_id
		);

EXCEPTION
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
END Add_PublicChannel;
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
      p_channel_record    	IN  AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name  varchar2(30) := 'Add_ProtectedChannel';
BEGIN

	AMV_CHANNEL_PVT.Add_ProtectedChannel
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_record    =>  p_channel_record,
      	x_channel_id        =>  x_channel_id
		);

EXCEPTION
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
END Add_ProtectedChannel;
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
      p_channel_record    	IN  AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name  varchar2(30) := 'Add_PrivateChannel';
BEGIN

	AMV_CHANNEL_PVT.Add_PrivateChannel
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_record    =>  p_channel_record,
      	x_channel_id        =>  x_channel_id
		);

EXCEPTION
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
END Add_PrivateChannel;
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
      p_channel_record    	IN  AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE,
      x_channel_id        	OUT NOCOPY  NUMBER
)
IS
l_api_name  varchar2(30) := 'Add_GroupChannel';
BEGIN

	AMV_CHANNEL_PVT.Add_GroupChannel
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
		p_group_id		=>  p_group_id,
      	p_channel_record    =>  p_channel_record,
      	x_channel_id        =>  x_channel_id
		);

EXCEPTION
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
END Add_GroupChannel;
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
l_api_name  varchar2(30) := 'Delete_Channel';
BEGIN

	AMV_CHANNEL_PVT.Delete_Channel
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id
		);

EXCEPTION
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
      p_channel_record    	IN  AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE
)
IS
l_api_name  varchar2(30) := 'Update_Channel';
BEGIN

	AMV_CHANNEL_PVT.Update_Channel
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_record    =>  p_channel_record
		);

EXCEPTION
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
      x_channel_record    	OUT NOCOPY  AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE
)
IS
l_api_name  varchar2(30) := 'Get_Channel';
BEGIN

	AMV_CHANNEL_PVT.Get_Channel
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
      	p_channel_name      =>  p_channel_name,
      	p_category_id       =>  p_category_id,
      	x_channel_record    =>  x_channel_record
		);

EXCEPTION
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
      p_content_type_id_array   IN  AMV_CHANNEL_PVT.AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Set_ChannelContentTypes';
BEGIN

	AMV_CHANNEL_PVT.Set_ChannelContentTypes
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	p_content_type_id_array =>  p_content_type_id_array
		);

EXCEPTION
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
      x_content_type_id_array   OUT NOCOPY  AMV_CHANNEL_PVT.AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Get_ChannelContentTypes';
BEGIN

	AMV_CHANNEL_PVT.Get_ChannelContentTypes
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	x_content_type_id_array =>  x_content_type_id_array
		);

EXCEPTION
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
      p_perspective_id_array    IN  AMV_CHANNEL_PVT.AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Set_ChannelPerspectives';
BEGIN

	AMV_CHANNEL_PVT.Set_ChannelPerspectives
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	p_perspective_id_array =>  p_perspective_id_array
		);

EXCEPTION
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
      x_perspective_id_array 	OUT NOCOPY  AMV_CHANNEL_PVT.AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Get_ChannelPerspectives';
BEGIN

	AMV_CHANNEL_PVT.Get_ChannelPerspectives
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	x_perspective_id_array => x_perspective_id_array
		);

EXCEPTION
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
      p_item_type_array     	IN  AMV_CHANNEL_PVT.AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Set_ChannelItemTypes';
BEGIN

	AMV_CHANNEL_PVT.Set_ChannelItemTypes
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	p_item_type_array   =>  p_item_type_array
		);

EXCEPTION
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
      x_item_type_array         OUT NOCOPY  AMV_CHANNEL_PVT.AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Get_ChannelItemTypes';
BEGIN

	AMV_CHANNEL_PVT.Get_ChannelItemTypes
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	x_item_type_array   =>  x_item_type_array
		);

EXCEPTION
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
      p_keywords_array   	IN  AMV_CHANNEL_PVT.AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Set_ChannelKeywords';
BEGIN

	AMV_CHANNEL_PVT.Set_ChannelKeywords
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	p_keywords_array    =>  p_keywords_array
		);

EXCEPTION
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
      x_keywords_array 		OUT NOCOPY  AMV_CHANNEL_PVT.AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Get_ChannelKeywords';
BEGIN

	AMV_CHANNEL_PVT.Get_ChannelKeywords
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	x_keywords_array    =>  x_keywords_array
		);

EXCEPTION
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
      p_authors_array    	IN  AMV_CHANNEL_PVT.AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Set_ChannelAuthors';
BEGIN

	AMV_CHANNEL_PVT.Set_ChannelAuthors
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
      	p_commit            =>  p_commit,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	p_authors_array     =>  p_authors_array
		);

EXCEPTION
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
      x_authors_array  		OUT NOCOPY  AMV_CHANNEL_PVT.AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Get_ChannelAuthors';
BEGIN

	AMV_CHANNEL_PVT.Get_ChannelAuthors
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
      	x_authors_array     =>  x_authors_array
		);

EXCEPTION
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
      p_subset_request_rec 	IN  AMV_CHANNEL_PVT.AMV_REQUEST_OBJ_TYPE,
      x_subset_return_rec 	OUT NOCOPY  AMV_CHANNEL_PVT.AMV_RETURN_OBJ_TYPE,
      x_document_id_array OUT NOCOPY  AMV_CHANNEL_PVT.AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Get_ItemsPerChannel';
BEGIN

	AMV_CHANNEL_PVT.Get_ItemsPerChannel
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_channel_id        =>  p_channel_id,
		p_channel_name		=>  p_channel_name,
		p_category_id		=>  p_category_id,
		p_subset_request_rec=> p_subset_request_rec,
		x_subset_return_rec => x_subset_return_rec,
      	x_document_id_array =>  x_document_id_array
		);

EXCEPTION
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
END Get_ItemsPerChannel;
--------------------------------------------------------------------------------
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
      p_criteria_rec      	IN  AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE,
      p_sort_by           	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_subset_request_rec 	IN  AMV_CHANNEL_PVT.AMV_REQUEST_OBJ_TYPE,
      x_subset_return_rec  	OUT NOCOPY  AMV_CHANNEL_PVT.AMV_RETURN_OBJ_TYPE,
      x_content_chan_array 	OUT NOCOPY  AMV_CHANNEL_PVT.AMV_CHANNEL_VARRAY_TYPE
)
IS
l_api_name  varchar2(30) := 'Find_Channels';
BEGIN

	AMV_CHANNEL_PVT.Find_Channels
	    (p_api_version       =>  p_api_version,
      	p_init_msg_list     =>  p_init_msg_list,
     	p_validation_level  =>  p_validation_level,
      	x_return_status     =>  x_return_status,
      	x_msg_count         =>  x_msg_count,
      	x_msg_data          =>  x_msg_data,
      	p_check_login_user 	=>  p_check_login_user,
      	p_criteria_rec      =>  p_criteria_rec,
		p_sort_by			=>  p_sort_by,
		p_subset_request_rec=> p_subset_request_rec,
		x_subset_return_rec => x_subset_return_rec,
      	x_content_chan_array=>  x_content_chan_array
		);

EXCEPTION
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
END Find_Channels;
--------------------------------------------------------------------------------
END amv_channel_grp;

/
