--------------------------------------------------------
--  DDL for Package CCT_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: cctpus.pls 115.7 2002/12/06 01:06:45 svinamda noship $*/

-- Start of comments
--	API name 	: GET_MIDDLEWARE_ID
--	Type		: Public
--	Function	: Return middleware id for a specific agent id.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
-- 				p_agent_id	IN NUMBER Required
--	OUT		:	x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--				x_middleware_id OUT NUMBER
--				x_middleware_config_name OUT VARCHAR2
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda  FEB 25 2001 Created
--
-- End of comments


PROCEDURE GET_MIDDLEWARE_ID
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE,
	p_agent_id IN NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	x_middleware_id OUT NOCOPY NUMBER
);




PROCEDURE CLOSE_MILCS
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE,
	p_milcs_type_id IN NUMBER,
    p_media_item_id IN NUMBER,
    p_end_date_time IN DATE Default sysdate,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
);


-- return value = 0 => media item can be closed.
-- return value = 1 => media item cannot be closed.

PROCEDURE CAN_CLOSE_MEDIA_ITEM
(
 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE,
    p_media_item_id IN NUMBER,
    x_can_close_media_item OUT NOCOPY NUMBER ,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

END CCT_UTIL_PUB;

 

/
