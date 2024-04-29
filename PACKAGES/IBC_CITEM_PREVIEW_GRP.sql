--------------------------------------------------------
--  DDL for Package IBC_CITEM_PREVIEW_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_PREVIEW_GRP" AUTHID CURRENT_USER as
/* $Header: ibcgcips.pls 115.4 2003/11/13 21:07:32 vicho ship $ */

-----------------------------------------
-- Global Variables
-----------------------------------------
-- The latest versions of the item's components will be retrieved, even
-- if they are not yet approved, for preview purposes.
G_LATEST_COMP_VERSIONS	CONSTANT CHAR(20) := 'LATEST_COMP_VERSIONS';

-- The live versions of the item's components will be retrieved for
-- preview purposes.
G_LIVE_COMP_VERSIONS	CONSTANT CHAR(18) := 'LIVE_COMP_VERSIONS';

-- The default versions of the item's components.
G_DEFAULT_COMP_VERSIONS	CONSTANT CHAR(21) := 'DEFAULT_COMP_VERSIONS';


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Preview_Citem_Basic_Xml
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Return a particular version of a content item with
--		   basic data as an XML Document for preview purposes.
--		   The item's compounded items are returned as references
--		   in the Xml.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_citem_version_id		IN  NUMBER    Required
--		   p_lang_code			IN  VARCHAR2  Optional
--                        DEFAULT NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_xml		OUT CLOB
--------------------------------------------------------------------------------
PROCEDURE Preview_Citem_Basic_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_citem_version_id	IN	NUMBER,
	p_lang_code		IN	VARCHAR2 DEFAULT NULL,
	x_return_status        	OUT NOCOPY   	VARCHAR2,
        x_msg_count            	OUT NOCOPY    	NUMBER,
        x_msg_data             	OUT NOCOPY   	VARCHAR2,
	x_content_item_xml	OUT NOCOPY	CLOB
);


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Preview_Citem_Deep_Xml
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Return a particular version of a content item with
--		   full data as an XML Document for preview purposes.
--		   The latest versions or the live versions of the item's
--		   components are retrieved, depending on the value of p_preview_mode.
--		   The item's component items are fully expanded in
--		   the Xml rather than as references. If the item's component
--		   in turn has some other components, they will be fully expanded
--		   also.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_citem_version_id		IN  NUMBER    Required
--		   p_lang_code			IN  VARCHAR2  Optional
--                        DEFAULT NULL
--		   p_preview_mode		IN  VARCHAR2  Optional
--			  Default = G_LATEST_COMP_VERSIONS
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_xml		OUT CLOB
--	           x_num_levels_loaded		OUT NUMBER
--------------------------------------------------------------------------------
PROCEDURE Preview_Citem_Deep_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_citem_version_id	IN	NUMBER,
	p_lang_code		IN	VARCHAR2 DEFAULT NULL,
	p_preview_mode		IN	VARCHAR2 DEFAULT G_LATEST_COMP_VERSIONS,
	x_return_status        	OUT NOCOPY   	VARCHAR2,
        x_msg_count            	OUT NOCOPY    	NUMBER,
        x_msg_data             	OUT NOCOPY   	VARCHAR2,
	x_content_item_xml	OUT NOCOPY	CLOB,
	x_num_levels_loaded	OUT NOCOPY	NUMBER
);


END IBC_CITEM_PREVIEW_GRP;

 

/
