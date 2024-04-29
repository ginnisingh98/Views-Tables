--------------------------------------------------------
--  DDL for Package Body AMV_MYCHANNEL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_MYCHANNEL_GRP" AS
/* $Header: amvgmycb.pls 120.1 2005/06/21 17:49:21 appldev ship $ */
--
--
-- NAME
--   AMV_MYCHANNEL_GRP
-- PURPOSE
--
-- HISTORY
--   01/29/2000        SLKRISHN        CREATED
--
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AMV_MYCHANNEL_GRP';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'amvgmycb.pls';
--
--
-- This package contains the following procedures
--
--------------------------------------------------------------------------------
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
--    OUT NOCOPY         : x_return_status   	OUT NOCOPY  VARCHAR2
--                 x_msg_count          OUT NOCOPY  NUMBER
--                 x_msg_data           OUT NOCOPY  VARCHAR2
--                 x_mychannel_array    OUT NOCOPY  AMV_MY_CHANNEL_VARRAY_TYPE
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
     x_mychannel_array 	OUT NOCOPY  AMV_MYCHANNEL_PVT.AMV_MY_CHANNEL_VARRAY_TYPE
)
IS
l_api_name varchar2(30) := 'Get_MyChannels';
BEGIN

 AMV_MYCHANNEL_PVT.Get_MyChannels
    (p_api_version      =>  p_api_version,
     p_init_msg_list    =>  p_init_msg_list,
     p_validation_level =>  p_validation_level,
     x_return_status    =>  x_return_status,
     x_msg_count        =>  x_msg_count,
     x_msg_data         =>  x_msg_data,
     p_check_login_user =>  p_check_login_user,
     p_user_id          =>  p_user_id,
     x_mychannel_array  => x_mychannel_array );

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
END Get_MyChannels;
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
--    OUT NOCOPY         : x_return_status               OUT NOCOPY  VARCHAR2
--                 x_msg_count                   OUT NOCOPY  NUMBER
--                 x_msg_data                    OUT NOCOPY  VARCHAR2
--                 x_items_array          	 OUT NOCOPY  AMV_CAT_HIERARCHY_VARRAY_TYPE
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
	 p_request_obj			IN  AMV_MYCHANNEL_PVT.AMV_REQUEST_OBJ_TYPE,
	 x_return_obj			OUT NOCOPY  AMV_MYCHANNEL_PVT.AMV_RETURN_OBJ_TYPE,
      x_items_array 		OUT NOCOPY  AMV_MYCHANNEL_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
l_api_name varchar2(30) := 'Get_ItemsPerUser';
BEGIN

 AMV_MYCHANNEL_PVT.Get_ItemsPerUser
    (p_api_version      =>  p_api_version,
     p_init_msg_list    =>  p_init_msg_list,
     p_validation_level =>  p_validation_level,
     x_return_status    =>  x_return_status,
     x_msg_count        =>  x_msg_count,
     x_msg_data         =>  x_msg_data,
     p_check_login_user =>  p_check_login_user,
     p_user_id          =>  p_user_id,
	p_request_obj	    =>  p_request_obj,
	x_return_obj	    =>  x_return_obj,
     x_items_array 	    =>  x_items_array);

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
END Get_ItemsPerUser;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_mychannel_grp;

/
