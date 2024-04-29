--------------------------------------------------------
--  DDL for Package AMV_CHANNEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_CHANNEL_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvchas.pls 120.1 2005/06/22 17:31:37 appldev ship $ */
--
-- NAME
--   AMV_CHANNEL_PVT
-- PURPOSE
--
-- HISTORY
--   08/04/1999        SLKRISHN        CREATED
--
--
-- This package contains the following procedures

TYPE AMV_CHAR_VARRAY_TYPE IS TABLE OF VARCHAR2(4000);

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

TYPE AMV_CHANNEL_OBJ_TYPE IS RECORD(
    channel_id				NUMBER,
    object_version_number	NUMBER,
    channel_name			VARCHAR2(80),
    description			VARCHAR2(2000),
    channel_type			VARCHAR2(30),
    channel_category_id		NUMBER,
    status				VARCHAR2(30),
    owner_user_id			NUMBER,
    default_approver_user_id NUMBER,
    effective_start_date		DATE,
    expiration_date			DATE,
    access_level_type		VARCHAR2(30),
    pub_need_approval_flag	VARCHAR2(1),
    sub_need_approval_flag	VARCHAR2(1),
    match_on_all_criteria_flag	VARCHAR2(1),
    match_on_keyword_flag	VARCHAR2(1),
    match_on_author_flag		VARCHAR2(1),
    match_on_perspective_flag	VARCHAR2(1),
    match_on_item_type_flag	VARCHAR2(1),
    match_on_content_type_flag	VARCHAR2(1),
    match_on_time_flag		VARCHAR2(1),
    application_id			NUMBER,
    external_access_flag		VARCHAR2(1),
    item_match_count		NUMBER,
    last_match_time			DATE,
    notification_interval_type	VARCHAR2(30),
    last_notification_time	DATE,
    attribute_category		VARCHAR2(30),
    attribute1				VARCHAR2(150),
    attribute2				VARCHAR2(150),
    attribute3				VARCHAR2(150),
    attribute4				VARCHAR2(150),
    attribute5				VARCHAR2(150),
    attribute6				VARCHAR2(150),
    attribute7				VARCHAR2(150),
    attribute8				VARCHAR2(150),
    attribute9				VARCHAR2(150),
    attribute10			VARCHAR2(150),
    attribute11			VARCHAR2(150),
    attribute12			VARCHAR2(150),
    attribute13			VARCHAR2(150),
    attribute14			VARCHAR2(150),
    attribute15			VARCHAR2(150)
);

TYPE AMV_CHANNEL_VARRAY_TYPE IS TABLE OF AMV_CHANNEL_OBJ_TYPE;

--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
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
);
--------------------------------------------------------------------------------
END amv_channel_pvt;

 

/
