--------------------------------------------------------
--  DDL for Package IBC_CITEM_RUNTIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_RUNTIME_PUB" AUTHID CURRENT_USER as
/* $Header: ibcpcirs.pls 120.0 2005/05/27 14:59:00 appldev noship $ */

----------------------------------------------
-- Type Definitions
----------------------------------------------

-- Rendition table parameters
TYPE Rendition_File_Name_Tbl IS TABLE OF VARCHAR2(256);
TYPE Rendition_File_Id_Tbl IS TABLE OF NUMBER;
TYPE Rendition_Mime_Type_Tbl IS TABLE OF VARCHAR2(30);
TYPE Rendition_Name_Tbl IS TABLE OF VARCHAR2(240);
-- Component attributes table parameters
TYPE Comp_Item_Attrib_Tcode_Tbl IS TABLE OF VARCHAR2(100);
TYPE Comp_Item_Citem_Id_Tbl IS TABLE OF NUMBER;

-- Content Item Meta
TYPE Content_Item_Meta_Rec IS RECORD (
	content_item_id			NUMBER,
	version_number			NUMBER,
	available_date			DATE,
	expiration_date			DATE,
	content_type_code		VARCHAR2(100),
	item_reference_code		VARCHAR2(100),
	encrypt_flag			VARCHAR2(1),
	content_item_name		VARCHAR2(240),
	description			VARCHAR2(2000),
	attachment_file_name		VARCHAR2(256),
	attachment_file_id		NUMBER,
	default_mime_type		VARCHAR2(30),
	default_rendition_name		VARCHAR2(240)
);
TYPE Content_Item_Meta_Tbl IS TABLE OF Content_Item_Meta_Rec;

-- Content Item Basic
TYPE Content_Item_Basic_Rec IS RECORD (
	content_item_id			NUMBER,
	version_number			NUMBER,
	available_date			DATE,
	expiration_date			DATE,
	content_type_code		VARCHAR2(100),
	item_reference_code		VARCHAR2(100),
	encrypt_flag			VARCHAR2(1),
	content_item_name		VARCHAR2(240),
	description			VARCHAR2(2000),
	attachment_file_name		VARCHAR2(256),
	attachment_file_id		NUMBER,
	rendition_file_names		Rendition_File_Name_Tbl,
	rendition_file_ids		Rendition_File_Id_Tbl,
	rendition_mime_types		Rendition_Mime_Type_Tbl,
	rendition_names			Rendition_Name_Tbl,
	default_mime_type		VARCHAR2(30),
	default_rendition_name		VARCHAR2(240),
	attribute_bundle		CLOB,
	comp_item_attrib_tcodes		Comp_Item_Attrib_Tcode_Tbl,
	comp_item_citem_ids		Comp_Item_Citem_Id_Tbl
);


TYPE Content_Item_Id_Tbl IS TABLE OF NUMBER;


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citems_Meta_By_Assoc
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a list of content items with their meta-data
--		   based on association.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_association_type_code	IN  VARCHAR2  Required
--		   p_associated_object_val1	IN  VARCHAR2  Required
--		   p_associated_object_val2	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val3	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val4	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val5	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_meta_tbl	OUT CONTENT_ITEM_META_TBL
--------------------------------------------------------------------------------
PROCEDURE Get_Citems_Meta_By_Assoc (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_association_type_code		IN    	VARCHAR2,
	p_associated_object_val1	IN	VARCHAR2,
	p_associated_object_val2	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val3	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val4	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val5	IN	VARCHAR2 DEFAULT NULL,
	p_label_code			IN	VARCHAR2 DEFAULT NULL,
	x_return_status			OUT NOCOPY VARCHAR2,
        x_msg_count			OUT NOCOPY NUMBER,
        x_msg_data			OUT NOCOPY VARCHAR2,
	x_content_item_meta_tbl		OUT NOCOPY CONTENT_ITEM_META_TBL
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citems_Meta_By_Assoc_Ctyp
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a list of content items with their meta-data
--		   based on association and content type.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_association_type_code	IN  VARCHAR2  Required
--		   p_associated_object_val1	IN  VARCHAR2  Required
--		   p_associated_object_val2	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val3	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val4	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_associated_object_val5	IN  VARCHAR2  Optional
--			  Default = NULL
--		   p_content_type_code		IN  VARCHAR2  Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_meta_tbl	OUT CONTENT_ITEM_META_TBL
--------------------------------------------------------------------------------
PROCEDURE Get_Citems_Meta_By_Assoc_Ctyp (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_association_type_code		IN    	VARCHAR2,
	p_associated_object_val1	IN	VARCHAR2,
	p_associated_object_val2	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val3	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val4	IN	VARCHAR2 DEFAULT NULL,
	p_associated_object_val5	IN	VARCHAR2 DEFAULT NULL,
	p_content_type_code		IN    	VARCHAR2,
	p_label_code			IN	VARCHAR2 DEFAULT NULL,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2,
	x_content_item_meta_tbl		OUT NOCOPY CONTENT_ITEM_META_TBL
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citems_Meta
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a list of content items with their meta-data
--		   based on the given list of content item ids.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_ids		IN  CONTENT_ITEM_ID_TBL Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_meta_tbl	OUT CONTENT_ITEM_META_TBL
--------------------------------------------------------------------------------
PROCEDURE Get_Citems_Meta (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_ids	IN	CONTENT_ITEM_ID_TBL,
	p_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_return_status        	OUT NOCOPY   	VARCHAR2,
        x_msg_count            	OUT NOCOPY    	NUMBER,
        x_msg_data             	OUT NOCOPY   	VARCHAR2,
	x_content_item_meta_tbl	OUT NOCOPY CONTENT_ITEM_META_TBL
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Meta
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with just the meta-data.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_meta		OUT CONTENT_ITEM_META_REC
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Meta (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_return_status        	OUT NOCOPY   	VARCHAR2,
        x_msg_count            	OUT NOCOPY    	NUMBER,
        x_msg_data             	OUT NOCOPY   	VARCHAR2,
	x_content_item_meta	OUT NOCOPY CONTENT_ITEM_META_REC
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Basic
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with basic data.
--    Parameters :
--    IN         : p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		 IN  NUMBER    Required
--		   p_label_code			 IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--		   x_content_item_basic		 OUT CONTENT_ITEM_BASIC_REC
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Basic (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id		IN	NUMBER,
	p_label_code			IN	VARCHAR2 DEFAULT NULL,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2,
	x_content_item_basic		OUT NOCOPY CONTENT_ITEM_BASIC_REC
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Basic_Xml
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with basic data as an XML Document.
--		   The item's compounded items are returned as references in
--		   the Xml.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_xml		OUT CLOB
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Basic_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_return_status        	OUT NOCOPY   	VARCHAR2,
        x_msg_count            	OUT NOCOPY    	NUMBER,
        x_msg_data             	OUT NOCOPY   	VARCHAR2,
	x_content_item_xml	OUT NOCOPY CLOB
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Deep_Xml
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with full data as an XML Document.
--		   The item's component items are fully expanded in
--		   the Xml rather than as references. If the item's component
--		   in turn has some other components, they will be fully expanded
--		   also.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_label_code			IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_xml		OUT CLOB
--		   x_num_levels_loaded		OUT NUMBER
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Deep_Xml (
	p_api_version          	IN    	NUMBER,
        p_init_msg_list        	IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_return_status        	OUT NOCOPY VARCHAR2,
        x_msg_count            	OUT NOCOPY NUMBER,
        x_msg_data             	OUT NOCOPY VARCHAR2,
	x_content_item_xml	OUT NOCOPY CLOB,
	x_num_levels_loaded	OUT NOCOPY NUMBER
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Citem_Deep_Xml
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Return a content item with full data as an XML Document.
--                 This method returns a specific content item version
--		   The item's component items are fully expanded in
--		   the Xml rather than as references. If the item's component
--		   in turn has some other components, they will be fully expanded
--		   also.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_citem_version_id		IN  VARCHAR2  Required
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--		   x_content_item_xml		OUT CLOB
--		   x_num_levels_loaded		OUT NUMBER
--------------------------------------------------------------------------------
PROCEDURE Get_Citem_Deep_Xml (
	p_api_version          	IN    	NUMBER,
   	p_init_msg_list        	IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id	IN	NUMBER,
	p_citem_version_id	IN	NUMBER,
	x_return_status        	OUT NOCOPY VARCHAR2,
   	x_msg_count            	OUT NOCOPY NUMBER,
   	x_msg_data             	OUT NOCOPY VARCHAR2,
	x_content_item_xml	OUT NOCOPY CLOB,
	x_num_levels_loaded	OUT NOCOPY NUMBER
);


END IBC_CITEM_RUNTIME_PUB;

 

/
