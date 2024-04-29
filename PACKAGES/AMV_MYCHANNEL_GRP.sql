--------------------------------------------------------
--  DDL for Package AMV_MYCHANNEL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_MYCHANNEL_GRP" AUTHID CURRENT_USER AS
/* $Header: amvgmycs.pls 120.1 2005/06/22 16:28:30 appldev ship $ */
--
--
-- NAME
--   AMV_MYCHANNEL_GRP
-- PURPOSE
--
-- HISTORY
--   01/29/2000        SLKRISHN        CREATED
--
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
     x_mychannel_array 	OUT NOCOPY  AMV_MYCHANNEL_PVT.AMV_MY_CHANNEL_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
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
	 p_request_obj			IN  AMV_MYCHANNEL_PVT.AMV_REQUEST_OBJ_TYPE,
	 x_return_obj			OUT NOCOPY  AMV_MYCHANNEL_PVT.AMV_RETURN_OBJ_TYPE,
      x_items_array 		OUT NOCOPY  AMV_MYCHANNEL_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_mychannel_grp;

 

/
