--------------------------------------------------------
--  DDL for Package CCT_MEDIA_QUEUE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_MEDIA_QUEUE_PUB" AUTHID CURRENT_USER AS
/* $Header: cctpmqs.pls 115.3 2002/12/06 01:06:42 svinamda noship $*/

-- Start of comments
--	API name 	: UPDATE_DEQUEUE_COUNT
--	Type		: Public
--	Function	: Init media dequeue counts for all media types
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_TRUE
-- 				p_media_type	IN NUMBER Required
-- 				p_dequeue_count		IN NUMBER Required
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


PROCEDURE UPDATE_DEQUEUE_COUNT
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE,
	p_root_svr_group_id IN NUMBER,
	p_media_type	IN 	NUMBER,
	p_dequeue_count IN NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
);


PROCEDURE GET_MEDIA_QUEUE_DETAILS
(
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE ,
    p_commit IN   VARCHAR2 Default FND_API.G_FALSE  ,
    p_media_item_id IN NUMBER ,  -- Required
    p_server_group_name IN VARCHAR2,   -- Required
    x_abs_pos_media_type OUT NOCOPY NUMBER,  -- absolute position of media item in the media type queue
    x_relative_pos_media_type OUT NOCOPY NUMBER, -- absolute position by media type / no of agents logged in for media type
    x_abs_pos_all_media_types OUT NOCOPY NUMBER, -- absolute position of media item for all media types
    x_relative_pos_all_media_types OUT NOCOPY NUMBER, -- absolute position of all media types / total # of agents logged in
    x_return_status OUT NOCOPY VARCHAR2 ,
    x_msg_count OUT NOCOPY NUMBER ,
    x_msg_data  OUT NOCOPY VARCHAR2
);



END CCT_MEDIA_QUEUE_PUB;

 

/
