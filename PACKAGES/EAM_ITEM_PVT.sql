--------------------------------------------------------
--  DDL for Package EAM_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMPITMS.pls 120.2 2006/06/13 22:40:57 hkarmach noship $ */

-- Start of comments
--	API name 	: EAM_ITEM_PVT
--	Type		: Public
--	Function	: insert_item, update_item
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	x.x
--				Changed....
--			  previous version	y.y
--				Changed....
--			  .
--			  .
--			  previous version	2.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments


PROCEDURE insert_item
(
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE
	, x_return_status		OUT NOCOPY VARCHAR2
	, x_msg_count			OUT NOCOPY NUMBER
	, x_msg_data	    	OUT NOCOPY VARCHAR2
	, X_ITEM_ID			OUT NOCOPY NUMBER
	, p_asset_group		    IN	VARCHAR2
	, p_segment1			IN	VARCHAR2
	, p_segment2			IN	VARCHAR2
	, p_segment3			IN	VARCHAR2
	, p_segment4			IN	VARCHAR2
	, p_segment5			IN	VARCHAR2
	, p_segment6			IN	VARCHAR2
	, p_segment7			IN	VARCHAR2
	, p_segment8			IN	VARCHAR2
	, p_segment9			IN	VARCHAR2
	, p_segment10			IN	VARCHAR2
	, p_segment11			IN	VARCHAR2
	, p_segment12			IN	VARCHAR2
	, p_segment13			IN	VARCHAR2
	, p_segment14			IN	VARCHAR2
	, p_segment15			IN	VARCHAR2
	, p_segment16			IN	VARCHAR2
	, p_segment17			IN	VARCHAR2
	, p_segment18			IN	VARCHAR2
	, p_segment19			IN	VARCHAR2
	, p_segment20			IN	VARCHAR2
	, P_SOURCE_TMPL_ID		IN	NUMBER
    , p_template_name       IN  VARCHAR2
    , p_organization_id     IN  NUMBER
    , p_description         IN  VARCHAR2
    , p_serial_generation   IN  NUMBER
    , p_prefix_text         IN  VARCHAR2
    , p_prefix_number       IN  VARCHAR2
    , p_eam_item_type       IN  NUMBER
);

PROCEDURE update_item
(
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE
	, x_return_status		OUT NOCOPY VARCHAR2
	, x_msg_count			OUT NOCOPY NUMBER
	, x_msg_data	    	OUT NOCOPY VARCHAR2
    , p_inventory_item_id     IN NUMBER
    , P_SOURCE_TMPL_ID		IN	NUMBER
    , p_template_name       IN  VARCHAR2
    , p_organization_id     IN NUMBER
    , p_description         IN  VARCHAR2
    , p_serial_generation   IN  NUMBER
    , p_prefix_text         IN  VARCHAR2
    , p_prefix_number       IN  VARCHAR2
);

PROCEDURE Lock_Item(
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE
	, x_return_status		OUT NOCOPY VARCHAR2
	, x_msg_count			OUT NOCOPY NUMBER
	, x_msg_data	    	OUT NOCOPY VARCHAR2
    , p_inventory_item_id     IN NUMBER
    , p_organization_id     IN NUMBER
);

END;

 

/
