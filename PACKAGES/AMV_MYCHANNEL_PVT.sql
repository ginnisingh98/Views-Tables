--------------------------------------------------------
--  DDL for Package AMV_MYCHANNEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_MYCHANNEL_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvmycs.pls 120.1 2005/06/30 13:01:01 appldev ship $ */
--
--
-- NAME
--   AMV_MYCHANNEL_PVT
-- PURPOSE
--
-- HISTORY
--   08/16/1999        SLKRISHN        CREATED
--
--
TYPE AMV_NUMBER_VARRAY_TYPE IS TABLE OF NUMBER;

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

TYPE amv_cat_hierarchy_obj_type IS RECORD(
   hierarchy_level 	 number,
   id			 number,
   name			 varchar2(240)
);

TYPE amv_cat_hierarchy_varray_type IS TABLE of amv_cat_hierarchy_obj_type;

TYPE AMV_MY_CHANNEL_OBJ_TYPE IS RECORD(
    my_channel_id 			NUMBER,
    channel_type			VARCHAR2(30),
    access_level_type		VARCHAR2(30),
    user_or_group_id       	NUMBER,
    user_or_group_type     	VARCHAR2(30),
    subscribing_to_id    	NUMBER,
    subscribing_to_type   	VARCHAR2(30),
    subscription_reason_type 	VARCHAR2(30),
    order_number       		NUMBER,
    status				VARCHAR2(30),
    notify_flag			VARCHAR2(1),
    notification_interval_type VARCHAR2(30)
);

TYPE AMV_MY_CHANNEL_VARRAY_TYPE IS TABLE OF AMV_MY_CHANNEL_OBJ_TYPE;

TYPE AMV_WF_NOTIF_OBJ_TYPE IS RECORD(
    notification_id 	NUMBER,
    subject			VARCHAR2(4000),
    begin_date			DATE,
    end_date       		DATE,
    due_date       		DATE,
    status			VARCHAR2(30),
    priority			NUMBER,
    type				VARCHAR2(30)
);

TYPE AMV_WF_NOTIF_VARRAY_TYPE IS TABLE OF AMV_WF_NOTIF_OBJ_TYPE;

TYPE amv_itemdisplay_obj_type IS RECORD(
   id			 number,
   name			 varchar2(240),
   description 	 varchar2(2000),
   type			 varchar2(30)
);

TYPE amv_itemdisplay_varray_type IS TABLE of amv_itemdisplay_obj_type;

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
--		   p_check_login_user		IN VARCHAR2   Optional
--			  Default = FND_API.G_TRUE
--                 p_channel_id                 IN NUMBER     Required
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
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--

--
-- This package contains the following procedures
--
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
--BREAK
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
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
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
--                 p_mychannel_id             	IN  NUMBER Optional
--			  Default = FND_API.G_MISS_NUM
--			MyChannel Id
--		   p_user_or_group_id		IN  NUMBER Optional
--			  Default = FND_API.G_MISS_NUM
--		   p_user_or_group_type		IN  VARCHAR2 Optional
--			  Default = FND_API.G_MISS_CHAR
--		   p_subscribing_to_id		IN  NUMBER Optional
--			  Default = FND_API.G_MISS_NUM
--		   p_subscribing_to_type	IN  VARCHAR2 Optional
--			  Default = FND_API.G_MISS_CHAR
--			Pass the user and subscription id and types
--				instead of mychannel id.
--			Must pass the mychannel id or the joint key of
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
     p_mychannel_id  	IN  NUMBER := FND_API.G_MISS_NUM,
     p_user_or_group_id IN  NUMBER := FND_API.G_MISS_NUM,
     p_user_or_group_type IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_subscribing_to_id IN  NUMBER := FND_API.G_MISS_NUM,
     p_subscribing_to_type IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
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
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
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
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_MyChannelsPerCategory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all channels in a category which an user has access to
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
--		   	    p_category_id	IN  NUMBER	Required
--    OUT        : x_return_status   	OUT VARCHAR2
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
     p_category_id	IN  NUMBER,
     x_channel_array 	OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE
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
--    API name   : Get_MyNotifications
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Get all notifications for a user - either approval or fyi
--    Parameters :
--    IN           p_api_version        IN  NUMBER    	Required
--                 p_init_msg_list      IN  VARCHAR2  	Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER    	Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user   IN  VARCHAR2 	Optional
--                        Default = FND_API.G_TRUE
--                 p_resource_id        IN  NUMBER    	Optional
--					 Default = FND_API.G_MISS_NUM
--                     resource manager resource id
--                 p_user_id            IN  NUMBER    	Optional
--					 Default = FND_API.G_MISS_NUM
--                     fnd user id
--                 p_user_name          IN  VARCHAR2   Optional
--					 Default = FND_API.G_MISS_CHAR
--                     fnd user name
--		   	    p_notification_type	IN  VARCHAR2	Optional
--					 Default = FND_API.G_MISS_CHAR
--    OUT        : x_return_status   	OUT VARCHAR2
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
     p_notification_type	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     x_notification_url	   OUT NOCOPY   VARCHAR2,
     x_notifications_array OUT NOCOPY  AMV_WF_NOTIF_VARRAY_TYPE
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
	 p_request_obj			IN  AMV_REQUEST_OBJ_TYPE,
	 x_return_obj			OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
      x_items_array 		OUT NOCOPY  AMV_CAT_HIERARCHY_VARRAY_TYPE
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
--    API name   : Get_UserItems
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all items  published by the user
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
      x_items_array 		OUT NOCOPY  AMV_itemdisplay_VARRAY_TYPE
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
--    API name   : Can_UserMaintainChannel
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if user can maintain channel
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
--                 x_items_array          	 OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Can_UserMaintainChannel
(     p_api_version      	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_user_id      		IN  NUMBER,
	 p_channel_id			IN  NUMBER,
	 x_maintain_flag		OUT NOCOPY  VARCHAR2
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
END amv_mychannel_pvt;

 

/
