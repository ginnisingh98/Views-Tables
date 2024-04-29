--------------------------------------------------------
--  DDL for Package IBC_STYLESHEETS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_STYLESHEETS_GRP" AUTHID CURRENT_USER as
/* $Header: ibcgsshs.pls 120.2 2005/12/29 04:59:03 hsaiyed noship $ */


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Approved_Default_StyleSht
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Return the default style sheet for the input item's content type.
--		   The style sheet has to be approved and its availability date
--		   has be to valid, otherwise exception will be thrown.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_stylesheet_label_code	IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_stylesheet			OUT NOCOPY BLOB
--		   x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_Approved_Default_StyleSht (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id		IN	NUMBER,
	p_stylesheet_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_stylesheet			OUT	NOCOPY BLOB,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Apprv_Default_StyleSht_Id
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Return the stylesheet id
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_stylesheet_label_code	IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_stylesheet_id		OUT NUMBER
--		   x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_Apprv_Default_StyleSht_Id (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id		IN	NUMBER,
	p_stylesheet_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_stylesheet_id			OUT NOCOPY      NUMBER,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Approved_StyleSheet
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Return the style sheet specified by its id.
--		   The style sheet has to be approved and its availability date
--		   has be to valid, otherwise exception will be thrown.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_stylesheet_item_id		IN  NUMBER    Required
--		   p_stylesheet_label_code	IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_stylesheet			OUT NOCOPY BLOB
--		   x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_Approved_StyleSheet (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_stylesheet_item_id		IN	NUMBER,
	p_stylesheet_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_stylesheet			OUT	NOCOPY BLOB,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_Approved_StyleSheet_RC
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Return the style sheet specified by its reference code.
--		   The style sheet has to be approved and its availability date
--		   has be to valid, otherwise exception will be thrown.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_stylesheet_ref_code	IN  VARCHAR2    Required
--		   p_stylesheet_label_code	IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_stylesheet			OUT NOCOPY BLOB
--		   x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_Approved_StyleSht_RC (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_stylesheet_ref_code		IN	VARCHAR2,
	p_stylesheet_label_code		IN	VARCHAR2 DEFAULT NULL,
	x_stylesheet			OUT	NOCOPY BLOB,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);



--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_StyleSheet_Items
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Return the stylesheets associated with the content
--                 type of the given content item.
--		   A stylesheet label can be optionally provided to indicate
--                 the specific versions of the stylesheet items to be retrieved.
--                 If there is no label-version mapping for a particular stylesheet,
--                 or the stylesheet does not satisfy all the Runtimer delivery
--                 requirement, that stylesheet item will NOT be included in the list returned.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_id		IN  NUMBER    Required
--		   p_stylesheet_label_code	IN  VARCHAR2  Optional
--			  Default = NULL
--    OUT        : x_stylesheet_item_clobs	OUT NOCOPY JTF_CLOB_TABLE
--		   x_stylesheet_item_ids	OUT NOCOPY JTF_NUMBER_TABLE
--		   x_stylesheet_lang_codes	OUT NOCOPY JTF_VARCHAR2_TABLE_100
--		   x_return_status              OUT NOCOPY VARCHAR2
--                 x_msg_count                  OUT NOCOPY NUMBER
--                 x_msg_data                   OUT NOCOPY VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Get_StyleSheet_Items (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_id		IN	NUMBER,
	p_stylesheets_label_code	IN	VARCHAR2 DEFAULT NULL,
	x_stylesheet_item_clobs		OUT NOCOPY	JTF_CLOB_TABLE,
	x_stylesheet_item_ids		OUT NOCOPY	JTF_NUMBER_TABLE,
	x_stylesheet_lang_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status			OUT NOCOPY	VARCHAR2,
       	x_msg_count			OUT NOCOPY	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);



END IBC_STYLESHEETS_GRP;

 

/
