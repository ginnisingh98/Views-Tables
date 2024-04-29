--------------------------------------------------------
--  DDL for Package IBC_CITEM_RUNTIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_RUNTIME_PVT" AUTHID CURRENT_USER as
/* $Header: ibcvcirs.pls 120.0 2005/05/27 14:56:47 appldev noship $ */

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Validate_Citem
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if content item is valid.
--		   1) content item id must be valid.
--		   2) wd_restricted_flag of content item must be false.
--		   3) content item status must be approved.
--    Parameters :
--		   p_init_msg_list		IN  VARCHAR2  Optional
--			Default = FND_API.G_FALSE
--                 p_content_item_id		IN  NUMBER    Required
--    OUT        : x_content_type_code		OUT VARCHAR2
--		   x_item_reference_code	OUT VARCHAR2
--		   x_live_citem_version_id	OUT NUMBER
--                 x_encrypt_flag               OUT VARCHAR2
--		   x_return_status		OUT VARCHAR2
--		   x_msg_count			OUT NUMBER
--		   x_msg_data			OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Validate_Citem (
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	x_content_type_code	OUT	NOCOPY VARCHAR2,
	x_item_reference_code	OUT	NOCOPY VARCHAR2,
	x_live_citem_version_id	OUT	NOCOPY NUMBER,
	x_encrypt_flag		OUT	NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Validate_Start_End_Date
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check sysdate against content item's start/end date. The
--                 action of validation also depends on profile options,
--                 IBC_ENFORCE_AVAILABLE_DATE and IBC_ENFORCE_EXPIRATION_DATE.
--    Parameters :
--		   p_init_msg_list		IN  VARCHAR2  Optional
--			Default = FND_API.G_FALSE
--                 p_content_item_id		IN  NUMBER    Required
--                 p_citem_version_id		IN  NUMBER    Required
--    OUT        : x_version_number		OUT NUMBER
--		   x_start_date			OUT DATE
--		   x_end_date			OUT DATE
--		   x_return_status		OUT VARCHAR2
--		   x_msg_count			OUT NUMBER
--		   x_msg_data			OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Validate_Start_End_Date (
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_citem_version_id	IN	NUMBER,
	x_version_number	OUT NOCOPY	NUMBER,
	x_start_date		OUT NOCOPY	DATE,
	x_end_date		OUT NOCOPY	DATE,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Meta
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return a content item with just the meta-data.
--    Parameters :
--		   p_init_msg_list		IN  VARCHAR2  Optional
--			Default = FND_API.G_FALSE
--                 p_content_item_id		IN  NUMBER    Required
--		   p_label_code			IN  VARCHAR2  Optional
--			Default = NULL
--    OUT        : x_content_item_meta		OUT IBC_CITEM_RUNTIME_PUB.CONTENT_ITEM_META_REC
--		   x_item_found			OUT VARCHAR2
--		   x_return_status		OUT VARCHAR2
--		   x_msg_count			OUT NUMBER
--		   x_msg_data			OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Meta (
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_content_item_meta	OUT 	NOCOPY IBC_CITEM_RUNTIME_PUB.CONTENT_ITEM_META_REC,
	x_item_found		OUT NOCOPY	VARCHAR2,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Xml
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return a content item with its data in Xml.
--    Parameters :
--		   p_init_msg_list		IN  VARCHAR2  Optional
--			Default = FND_API.G_FALSE
--                 p_content_item_id		IN  NUMBER    Required
--		   p_xml_clob_loc		IN OUT CLOB   Required
--		   p_num_levels			IN  NUMBER    Optional
--			DEFAULT = NULL
--		   p_label_code			IN  VARCHAR2  Optional
--			Default = NULL
--		   p_lang_code			IN  VARCHAR2  Optional
--			Default = NULL
--		   p_validate_dates		IN  VARCHAR2  Optional
--			Default = FND_API.G_TRUE
--    OUT        :
--		   x_return_status		OUT VARCHAR2
--		   x_msg_count			OUT NUMBER
--		   x_msg_data			OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Xml (
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_xml_clob_loc		IN OUT	NOCOPY CLOB,
	p_num_levels		IN	NUMBER DEFAULT NULL,
	p_label_code		IN	VARCHAR2 DEFAULT NULL,
	p_lang_code		IN	VARCHAR2 DEFAULT NULL,
	p_validate_dates	IN	VARCHAR2 DEFAULT FND_API.G_TRUE,
	x_num_levels_loaded	OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
);




-------------------------------------------------------------------------------
--
--   Private APIs for Runtime Cache Loading
--
-------------------------------------------------------------------------------
PROCEDURE Bulk_Load (
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	x_clobs			OUT NOCOPY	JTF_CLOB_TABLE,
	x_content_item_ids	OUT NOCOPY	JTF_NUMBER_TABLE,
	x_label_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_lang_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
);

PROCEDURE Load_Translated_Content_Items (
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_ids	IN	JTF_NUMBER_TABLE,
	p_label_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_lang_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_validate_dates	IN	VARCHAR2 DEFAULT FND_API.G_TRUE,
	x_clobs			OUT NOCOPY	JTF_CLOB_TABLE,
	x_content_item_ids	OUT NOCOPY	JTF_NUMBER_TABLE,
	x_label_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_lang_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
);

PROCEDURE Load_Citem_Version_Number (
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_version_number	OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
);

PROCEDURE Load_Associations (
	p_init_msg_list			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_association_type_code		IN    	VARCHAR2,
	p_associated_object_val1	IN	VARCHAR2,
	p_associated_object_val2	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val3	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val4	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val5	IN	VARCHAR2 DEFAULT NULL,
	x_content_item_id_tbl		OUT NOCOPY	JTF_NUMBER_TABLE,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

PROCEDURE Get_Citem_Xml (
	p_init_msg_list	IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_xml_clob_loc		IN OUT	NOCOPY CLOB,
	p_num_levels		IN	NUMBER DEFAULT NULL,
	p_citem_version_id	IN	NUMBER DEFAULT NULL,
	p_lang_code		IN	VARCHAR2 DEFAULT NULL,
	p_validate_dates	IN	VARCHAR2 DEFAULT FND_API.G_TRUE,
	x_num_levels_loaded	OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY   	VARCHAR2,
        x_msg_count		OUT NOCOPY    	NUMBER,
        x_msg_data		OUT NOCOPY   	VARCHAR2
);

END IBC_CITEM_RUNTIME_PVT;

 

/
