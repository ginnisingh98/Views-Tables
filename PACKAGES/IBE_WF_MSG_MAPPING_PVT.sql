--------------------------------------------------------
--  DDL for Package IBE_WF_MSG_MAPPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_WF_MSG_MAPPING_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVWMMS.pls 120.0 2005/05/30 02:52:09 appldev noship $ */

    TYPE t_genref IS REF CURSOR;

    G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBE_WF_MSG_MAPPING_PVT';

    TYPE WFMSG_REC_TYPE IS RECORD(
	notif_msg_map_ID 	NUMBER := FND_API.G_MISS_NUM,
	notif_setup_id		NUMBER := FND_API.G_MISS_NUM,
	message_name		VARCHAR2(30) := FND_API.G_MISS_CHAR,
	enabled_flag		VARCHAR2(1),
	msite_id		NUMBER,
	org_id			NUMBER,
	user_type		VARCHAR2(30),
	all_msite_flag		VARCHAR2(1),
	all_org_flag		VARCHAR2(1),
	all_user_type_flag	VARCHAR2(1)
    );

    Type WFMSG_TBL_TYPE IS TABLE of WFMSG_REC_TYPE INDEX BY BINARY_INTEGER;

-- Start of comments
--    API name   : Retrieve_Msg_Mapping
--    Type       : Private.
--    Function   : Get the message mapping for the specified parameters
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_org_id                            IN NUMBER
--                 p_msite_id                          IN Number
--		   p_user_type		               IN VARCHAR2
--		   p_enabled_flag		       IN VARCHAR2
--		   p_notif_setup_id		       IN NUMBER
--
--    OUT        : x_msg_map_name           	       OUT VARCHAR2
--               : x_msg_data           	       OUT VARCHAR2
--               : x_msg_count           	       OUT VARCHAR2
--               : x_return_status           	       OUT VARCHAR2

--
--    Version    : Current version      1.0
--                 previous version     None
--                 Initial version      1.0
--    Notes      : Note text
--
-- End of comments
    procedure Retrieve_Msg_Mapping
    (
	p_org_id		IN  NUMBER,
	p_msite_id		IN  NUMBER,
	p_user_type		IN  VARCHAR2,
	x_enabled_flag  	OUT NOCOPY VARCHAR2,
	p_notif_name		IN  VARCHAR2,
	x_wf_message_name	OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER
    );


        procedure Get_Notif_Metadata
        (
	    x_msg_count		OUT NOCOPY NUMBER,
	    x_msg_data		OUT NOCOPY VARCHAR2,
	    x_return_status	OUT NOCOPY VARCHAR2,
            x_notif_setup_id	OUT NOCOPY NUMBER,
            p_notification_name IN  VARCHAR2,
            x_org_id_flag       OUT NOCOPY VARCHAR2,
            x_msite_id_flag     OUT NOCOPY VARCHAR2,
            x_user_type_flag    OUT NOCOPY VARCHAR2,
            x_enabled_flag      OUT NOCOPY VARCHAR2
        );

end IBE_WF_MSG_MAPPING_PVT;

 

/
