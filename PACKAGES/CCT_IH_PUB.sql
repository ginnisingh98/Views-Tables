--------------------------------------------------------
--  DDL for Package CCT_IH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_IH_PUB" AUTHID CURRENT_USER AS
/* $Header: cctpihs.pls 115.4 2003/04/18 00:18:45 svinamda noship $*/
G_IH_DIRECTION_INBOUND CONSTANT VARCHAR2(40) := 'INBOUND';
G_IH_DIRECTION_OUTBOUND CONSTANT VARCHAR2(40) := 'OUTBOUND';
G_DIRECTION_NA  CONSTANT VARCHAR2(40) := 'N/A';
G_IH_TELE_INB       CONSTANT VARCHAR2(40) := 'TELE_INB';
G_IH_TELE_DIRECT    CONSTANT VARCHAR2(40) := 'TELE_DIRECT';
G_IH_TELE_MANUAL    CONSTANT VARCHAR2(40) := 'TELE_MANUAL';
G_IH_TELE_INTERNAL  CONSTANT VARCHAR2(40) := 'TELE_INTERNAL';
G_IH_TELE_WEB_CALLBACK CONSTANT VARCHAR2(40) := 'TELE_WEB_CALLBACK';
G_IH_TELE_WEB_COLLAB CONSTANT VARCHAR2(40) := 'TELE_WEB_COLLAB';
G_IH_WEB_COLLAB      CONSTANT VARCHAR2(40) := 'WEB_COLLAB';
G_IH_UNSOLICITED    CONSTANT VARCHAR2(40) := 'UNSOLICITED';
G_IH_TELE_AO        CONSTANT VARCHAR2(40) := 'TELE_AO';
G_IH_LCS_TYPE_IVR CONSTANT NUMBER := 1 ;
G_IH_LCS_TYPE_WITH_AGENT CONSTANT NUMBER := 5 ;
G_IH_LCS_TYPE_IN_QUEUE   CONSTANT NUMBER := 3 ;
G_IH_LCS_TYPE_ROUTING    CONSTANT NUMBER := 4 ;
G_IH_TRANSFER_NONE CONSTANT VARCHAR2(1)  := 'N' ;
G_IH_TRANSFER_BOTH CONSTANT VARCHAR2(1)   := 'B' ;
G_IH_TRANSFER_TRAN CONSTANT VARCHAR2(1)   := 'T' ;
G_IH_TRANSFER_CONF CONSTANT VARCHAR2(1)   := 'C' ;
G_IH_YES CONSTANT VARCHAR2(1)             := 'Y' ;
G_IH_NO CONSTANT VARCHAR2(1)              := 'N' ;
G_IH_CCT_HANDLER_ID CONSTANT NUMBER := 172;


-- Start of comments
--	API name 	: Open_MediaItem
--	Type		: Public
--	Function	: Create a media item id.
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


PROCEDURE OPEN_MEDIA_ITEM
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE,
    p_app_id            IN  NUMBER Default -1,
    p_user_id           IN NUMBER,
    p_direction         IN VARCHAR2,
    p_start_date_time   IN DATE,
    p_source_item_create_date_time  IN DATE,
    p_media_item_type   IN VARCHAR2,
    p_server_group_id   IN NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
    x_media_id      OUT NOCOPY NUMBER

);



END CCT_IH_PUB;

 

/
