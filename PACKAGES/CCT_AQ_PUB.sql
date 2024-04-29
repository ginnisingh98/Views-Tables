--------------------------------------------------------
--  DDL for Package CCT_AQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_AQ_PUB" AUTHID CURRENT_USER AS
/* $Header: cctpaqs.pls 115.29 2003/03/14 20:00:57 svinamda noship $*/

G_ABANDON_MEDIA 	CONSTANT VARCHAR2(40) := 'AbandonMedia';
G_TIMEOUT        	CONSTANT VARCHAR2(8) := 'TIMEOUT';


G_BASIC_SDK_GROUP_NAME CONSTANT VARCHAR2(30) := 'BASIC_SDK';
G_KEY_COUNTRY_CODE CONSTANT VARCHAR2(30) := 'CountryCode';
G_KEY_AREA_CODE CONSTANT VARCHAR2(30) := 'AreaCode';
G_KEY_PHONE_NUMBER CONSTANT VARCHAR2(30) := 'PhoneNumber';
--G_KEY_LSERVER_GROUP_NAME CONSTANT VARCHAR2(30) := 'occtServerGroupName';
G_KEY_MEETING_URL CONSTANT VARCHAR2(30) := 'occtURL';
G_KEY_WITH_CALLBACK CONSTANT VARCHAR2(30) := 'occtWithCallback';
G_KEY_MEDIA_ITEM_ID CONSTANT VARCHAR2(30) := 'occtMediaItemID';
G_KEY_LOCAL_SERVER_GROUP_NAME CONSTANT VARCHAR2(30) := 'occtLocalServerGroupName';
G_KEY_LOCAL_SERVER_GROUP_ID CONSTANT VARCHAR2(30) := 'occtLocalServerGroupId';
G_KEY_SUPER_SERVER_GROUP_NAME CONSTANT VARCHAR2(30) := 'occtSuperServerGroupName';
G_KEY_SUPER_SERVER_GROUP_ID CONSTANT VARCHAR2(30) := 'occtSuperServerGroupId';


FUNCTION IS_SERVER_UP (l_server_id IN NUMBER) RETURN NUMBER ;

-- Start of comments
--	API name 	: ENQUEUE_ITEM
--	Type		: Public
--	Function	: Enqueue an item into the database.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--  				p_server_group_name	IN VARCHAR2 Required
--  				p_app_id		IN NUMBER Optional
--  				p_xml_data1		IN VARCHAR2 Required
--				p_media_type		IN VARCHAR2 Required
--					Default = FND_API.G_MISS_NUM;

--	OUT		:	x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--				.
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda 22 MAR 2001 Created
--
-- End of comments


PROCEDURE ENQUEUE_ITEM
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE	,
	p_server_group_name	IN 	VARCHAR2,
	p_app_id		IN   	NUMBER Default -1,
 	p_xml_data1		IN   	VARCHAR2 ,
	p_media_type		IN	NUMBER,
    p_delay         IN NUMBER Default -1,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
);


-- Start of comments
--	API name 	: DEQUEUE_ITEM
--	Type		: Public
--	Function	: Dequeue an item from the database.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--
--	OUT		:	x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--				p_server_group_name	OUT VARCHAR2 Required
--  				p_xml_data1		OUT VARCHAR2 Required
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda 22 MAR 2001 Created
--
-- End of comments

PROCEDURE DEQUEUE_ITEM
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE	,
	p_server_group_id IN NUMBER ,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	x_server_group_name	OUT NOCOPY 	VARCHAR2 ,
 	x_xml_data1		OUT NOCOPY   	VARCHAR2
);



-- Start of comments
--	API name 	: ENQUEUE_WEB_CALLBACK_ITEM
--	Type		: Public
--	Function	: Enqueue a web callback item into the database.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--  				p_server_group_name	IN VARCHAR2 Required
--  				p_app_id		IN NUMBER Optional
--				p_country_code		IN NUMBER Required
--				p_area_code		IN NUMBER Required
--				p_phone_number		IN NUMBER Required
--				p_delay			IN VARCHAR2 Optional
--				p_key1			IN VARCHAR2 Optional
--				p_value1		IN VARCHAR2 Optional
--				p_key2			IN VARCHAR2 Optional
--				p_value2		IN VARCHAR2 Optional
--				p_key3			IN VARCHAR2 Optional
--				p_value3		IN VARCHAR2 Optional
--				p_key4 			IN VARCHAR2 Optional
-- 				p_value4		IN VARCHAR2 Optional
--				p_key5			IN VARCHAR2 Optional
--				p_value5		IN VARCHAR2 Optional
--				p_key6			IN VARCHAR2 Optional
--				p_value6		IN VARCHAR2 Optional
--				p_key7			IN VARCHAR2 Optional
--				p_value7		IN VARCHAR2 Optional
--				p_key8 			IN VARCHAR2 Optional
-- 				p_value8		IN VARCHAR2 Optional
--				p_key9			IN VARCHAR2 Optional
--				p_value9		IN VARCHAR2 Optional
--				p_key10			IN VARCHAR2 Optional
--				p_value10		IN VARCHAR2 Optional

--
--
--	OUT		:	x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--				.
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda 06 APR 2001 Created
--
-- End of comments


PROCEDURE ENQUEUE_WEB_CALLBACK_ITEM
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE	,
	p_server_group_name	IN 	VARCHAR2,
	p_app_id		IN   	NUMBER Default -1,
	p_country_code		IN	NUMBER,
	p_area_code		IN	NUMBER,
	p_phone_number		IN	NUMBER,
	p_delay			IN 	NUMBER Default -1,
	p_key1			IN 	VARCHAR2 Default null,
	p_value1		IN 	VARCHAR2 Default null,
	p_key2			IN 	VARCHAR2 Default null,
	p_value2		IN 	VARCHAR2 Default null,
	p_key3			IN 	VARCHAR2 Default null,
	p_value3		IN 	VARCHAR2 Default null,
	p_key4 			IN 	VARCHAR2 Default null,
	p_value4		IN 	VARCHAR2 Default null,
	p_key5			IN 	VARCHAR2 Default null,
	p_value5		IN 	VARCHAR2 Default null,
	p_key6			IN 	VARCHAR2 Default null,
	p_value6		IN 	VARCHAR2 Default null,
	p_key7			IN 	VARCHAR2 Default null,
	p_value7		IN 	VARCHAR2 Default null,
	p_key8 			IN 	VARCHAR2 Default null,
	p_value8		IN 	VARCHAR2 Default null,
	p_key9			IN 	VARCHAR2 Default null,
	p_value9		IN 	VARCHAR2 Default null,
	p_key10			IN 	VARCHAR2 Default null,
	p_value10		IN 	VARCHAR2 Default null,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);


-- Start of comments
--	API name 	: GET_ROOT_GROUP_NAME
--	Type		: Public
--	Function	: Returns the root server group name.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--  				p_server_group_name	IN VARCHAR2 Required
--
--	OUT		:	x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--				x_root_server_group_name OUT VARCHAR2(256)
--				.
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda 06 APR 2001 Created
--
-- End of comments


PROCEDURE GET_ROOT_GROUP_NAME
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list			IN	VARCHAR2 Default FND_API.G_FALSE,
  	p_server_group_name 		IN 	VARCHAR2,
 	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	x_root_server_group_name	OUT NOCOPY	VARCHAR2
);


-- Start of comments
--	API name 	: ENQUEUE_WEB_COLLABORATION_ITEM
--	Type		: Public
--	Function	: Enqueue a web collaboration item into the database.
--	Pre-reqs	: None.
--	Parameters	:



--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional, Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional, Default = FND_API.G_FALSE
--  			p_server_group_name	IN VARCHAR2 Required
--              p_server_group_id  IN  NUMBER Default null
--  			p_app_id		IN NUMBER Default = -1
--              p_meeting_URL IN  VARCHAR2
--              p_with_callback IN  VARCHAR2 Default  FND_API.G_TRUE
--              p_ih_media_item_id IN NUMBER  Default -1
--				p_country_code		IN NUMBER Optional
--				p_area_code		IN NUMBER Optional
--				p_phone_number		IN NUMBER Required
--				p_key1			IN VARCHAR2 Optional
--				p_value1		IN VARCHAR2 Optional
--				p_key2			IN VARCHAR2 Optional
--				p_value2		IN VARCHAR2 Optional
--				p_key3			IN VARCHAR2 Optional
--				p_value3		IN VARCHAR2 Optional
--				p_key4 			IN VARCHAR2 Optional
-- 				p_value4		IN VARCHAR2 Optional
--				p_key5			IN VARCHAR2 Optional
--				p_value5		IN VARCHAR2 Optional
--				p_key6			IN VARCHAR2 Optional
--				p_value6		IN VARCHAR2 Optional
--				p_key7			IN VARCHAR2 Optional
--				p_value7		IN VARCHAR2 Optional
--				p_key8 			IN VARCHAR2 Optional
-- 				p_value8		IN VARCHAR2 Optional
--				p_key9			IN VARCHAR2 Optional
--				p_value9		IN VARCHAR2 Optional
--				p_key10			IN VARCHAR2 Optional
--				p_value10		IN VARCHAR2 Optional

--
--
--	OUT		:	x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--				.
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda 14 SEPT 2001 Created
--
-- End of comments



PROCEDURE ENQUEUE_WEB_COLLAB_ITEM
(
    p_api_version IN NUMBER  ,
    p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE ,
    p_commit IN   VARCHAR2 Default FND_API.G_FALSE  ,
    p_server_group_id  IN  NUMBER Default null ,
    p_server_group_name  IN  VARCHAR2 Default null ,
    p_app_id IN NUMBER Default -1,
    p_meeting_URL IN  VARCHAR2 ,
    p_with_callback IN  VARCHAR2 Default FND_API.G_TRUE ,
    p_ih_media_item_id IN NUMBER  Default -1   ,
    p_country_code IN NUMBER Default null ,
    p_area_code  IN NUMBER Default null ,
    p_phone_number IN NUMBER Default null,
    p_key1  IN  VARCHAR2 Default null ,
    p_value1 IN  VARCHAR2 Default null ,
    p_key2 IN  VARCHAR2 Default null ,
    p_value2 IN  VARCHAR2 Default null,
    p_key3 IN  VARCHAR2 Default null ,
    p_value3 IN  VARCHAR2 Default null,
    p_key4 IN  VARCHAR2 Default null ,
    p_value4 IN  VARCHAR2 Default null,
    p_key5 IN  VARCHAR2 Default null ,
    p_value5 IN  VARCHAR2 Default null,
    p_key6 IN  VARCHAR2 Default null ,
    p_value6 IN  VARCHAR2 Default null,
    p_key7 IN  VARCHAR2 Default null ,
    p_value7 IN  VARCHAR2 Default null,
    p_key8 IN  VARCHAR2 Default null ,
    p_value8 IN  VARCHAR2 Default null,
    p_key9 IN  VARCHAR2 Default null ,
    p_value9 IN  VARCHAR2 Default null,
    p_key10 IN  VARCHAR2 Default null ,
    p_value10 IN  VARCHAR2 Default null,
    x_return_status OUT NOCOPY VARCHAR2 ,
    x_msg_count OUT NOCOPY NUMBER ,
    x_msg_data  OUT NOCOPY VARCHAR2
);





-- Start of comments
--	API name 	: ABANDON_MEDIA
--	Type		: Public
--	Function	: Cancel a media item request if it has not already been processed.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--  				p_server_group_name	IN VARCHAR2 Required
--  				p_app_id		IN NUMBER Optional
--  				p_media_item_id		IN VARCHAR2 Required

--	OUT		:	x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--				.
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda 22 MAY 2002 Created
--
-- End of comments


PROCEDURE ABANDON_MEDIA
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE	,
	p_server_group_name	IN 	VARCHAR2,
	p_app_id		IN   	NUMBER Default -1,
    p_media_item_id IN NUMBER ,  -- Required
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
);


END CCT_AQ_PUB;

 

/
