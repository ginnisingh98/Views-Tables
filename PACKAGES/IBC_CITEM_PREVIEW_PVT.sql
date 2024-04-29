--------------------------------------------------------
--  DDL for Package IBC_CITEM_PREVIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_PREVIEW_PVT" AUTHID CURRENT_USER as
/* $Header: ibcvcips.pls 115.5 2003/11/13 21:08:21 vicho ship $ */

PROCEDURE Get_Citem_Version (
	p_init_msg_list			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id		IN	NUMBER,
	p_latest_component_versions	IN	VARCHAR2 DEFAULT FND_API.G_TRUE,
	x_citem_version_id		OUT NOCOPY	NUMBER,
	x_version_number		OUT NOCOPY	NUMBER,
	x_start_date			OUT NOCOPY	DATE,
	x_end_date			OUT NOCOPY	DATE,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);



PROCEDURE Preview_Citem_Xml (
	p_init_msg_list			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id		IN	NUMBER,
	p_citem_version_id		IN	NUMBER,
        p_lang_code			IN	VARCHAR2 DEFAULT NULL,
	p_version_number		IN	NUMBER DEFAULT NULL,
        p_start_date			IN	DATE DEFAULT NULL,
	p_end_date			IN	DATE DEFAULT NULL,
	p_preview_mode			IN	VARCHAR2 DEFAULT IBC_CITEM_PREVIEW_GRP.G_DEFAULT_COMP_VERSIONS,
	p_xml_clob_loc			IN OUT	NOCOPY CLOB,
	p_num_levels			IN	NUMBER DEFAULT NULL,
	x_num_levels_loaded		OUT NOCOPY	NUMBER,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);


END IBC_CITEM_PREVIEW_PVT;

 

/
