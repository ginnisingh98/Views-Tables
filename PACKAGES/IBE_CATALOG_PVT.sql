--------------------------------------------------------
--  DDL for Package IBE_CATALOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_CATALOG_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVCCTS.pls 120.3 2006/01/27 12:46:50 madesai ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBE_CATALOG_PVT';

/* The values here must match the values for Item.SHALLOW,
   Item.DEEP, Item.DEEP_ONLY
*/
G_ITEM_SHALLOW		CONSTANT NUMBER := 0;
G_ITEM_DEEP		CONSTANT NUMBER := 1;
G_ITEM_DEEP_ONLY	CONSTANT NUMBER := 3;
G_ITEM_MODEL            CONSTANT VARCHAR(3) := 'MDL';
G_ITEM_SERVICEABLE      CONSTANT VARCHAR(3) := 'SVA';
G_ITEM_SERVICE          CONSTANT VARCHAR(3) := 'SRV';
G_ITEM_STANDARD         CONSTANT VARCHAR(3) := 'STD';

TYPE IBE_SECTION_REC IS RECORD
(
   section_id		NUMBER,
   access_name		VARCHAR2(240),
   display_name 	VARCHAR2(120),
   description		VARCHAR2(4000),
   object_version_num 	NUMBER,
   section_type_code	VARCHAR2(30),
   status_code		VARCHAR2(30),
   start_date_active	DATE,
   end_date_active	DATE,
   dispctx_id		NUMBER,
   template_id		NUMBER,
   long_desc		VARCHAR2(4000),
   order_by_clause	VARCHAR2(512),
   avail_all_sites	VARCHAR2(1),
   auto_placement_rule	VARCHAR2(512),
   keywords		VARCHAR2(512),
   attribute_category	VARCHAR2(30),
   attribute1		VARCHAR2(150),
   attribute2		VARCHAR2(150),
   attribute3		VARCHAR2(150),
   attribute4		VARCHAR2(150),
   attribute5		VARCHAR2(150),
   attribute6		VARCHAR2(150),
   attribute7		VARCHAR2(150),
   attribute8		VARCHAR2(150),
   attribute9		VARCHAR2(150),
   attribute10		VARCHAR2(150),
   attribute11		VARCHAR2(150),
   attribute12		VARCHAR2(150),
   attribute13		VARCHAR2(150),
   attribute14		VARCHAR2(150),
   attribute15		VARCHAR2(150)
);

type IBE_SUBSECT_REC is RECORD
(
   section_id		NUMBER,
   subsect_id		NUMBER,
   subsect_type		VARCHAR2(30)
);

type IBE_ID_REC is RECORD
(
   id			NUMBER
);

type IBE_CATEGORY_ID_REC is RECORD
(
   inventory_item_id		NUMBER,
   category_id			NUMBER
);

type IBE_ITEM_ORG_ID_REC is RECORD
(
   inventory_item_id		NUMBER,
   organization_id		NUMBER
);

type IBE_UOM_REC is RECORD
(
   inventory_item_id		NUMBER,
   uom_code			VARCHAR2(3)
);

type IBE_SHALLOW_ITEM_REC is RECORD
(
   bom_enabled_flag		VARCHAR2(1),
   orderable_on_web_flag	VARCHAR2(1),
   back_orderable_flag		VARCHAR2(1),
   primary_unit_of_measure	VARCHAR2(25),
   primary_uom_code		VARCHAR2(3),
   item_type			VARCHAR2(30),
   description			VARCHAR2(240),
   long_description		VARCHAR2(4000),
   bom_item_type		NUMBER,
   indivisible_flag		VARCHAR2(1),
   serial_control_code		NUMBER,
   web_status			VARCHAR2(30),
   concatenated_segments	VARCHAR2(40),
   inventory_item_id		NUMBER
);


type IBE_DEEP_ITEM_REC is RECORD
(
   bom_enabled_flag		VARCHAR2(1),
   orderable_on_web_flag	VARCHAR2(1),
   back_orderable_flag		VARCHAR2(1),
   primary_unit_of_measure	VARCHAR2(25),
   primary_uom_code		VARCHAR2(3),
   item_type			VARCHAR2(30),
   description			VARCHAR2(240),
   long_description		VARCHAR2(4000),
   bom_item_type		NUMBER,
   indivisible_flag		VARCHAR2(1),
   serial_control_code		NUMBER,
   web_status			VARCHAR2(30),
   concatenated_segments	VARCHAR2(40),
   inventory_item_id		NUMBER,
   taxable_flag			VARCHAR(1),
   shippable_item_flag		VARCHAR2(1),
   atp_flag			VARCHAR2(1),
   returnable_flag		VARCHAR2(1),
   service_item_flag		VARCHAR2(1),
   serviceable_flag		VARCHAR2(1),
   downloadable_flag		VARCHAR2(1),
   service_duration_period	VARCHAR2(10),
   min_order_qty		NUMBER,
   max_order_qty		NUMBER,
   fixed_order_qty		NUMBER,
   service_duration		NUMBER,
   service_starting_delay	NUMBER,
   segment1			VARCHAR2(40),
   segment2			VARCHAR2(40),
   segment3			VARCHAR2(40),
   segment4			VARCHAR2(40),
   segment5			VARCHAR2(40),
   segment6			VARCHAR2(40),
   segment7			VARCHAR2(40),
   segment8			VARCHAR2(40),
   segment9			VARCHAR2(40),
   segment10			VARCHAR2(40),
   segment11			VARCHAR2(40),
   segment12			VARCHAR2(40),
   segment13			VARCHAR2(40),
   segment14			VARCHAR2(40),
   segment15			VARCHAR2(40),
   segment16			VARCHAR2(40),
   segment17			VARCHAR2(40),
   segment18			VARCHAR2(40),
   segment19			VARCHAR2(40),
   segment20			VARCHAR2(40),
   attribute1                   VARCHAR2(150),
   attribute2			VARCHAR2(150),
   attribute3			VARCHAR2(150),
   attribute4			VARCHAR2(150),
   attribute5			VARCHAR2(150),
   attribute6			VARCHAR2(150),
   attribute7			VARCHAR2(150),
   attribute8			VARCHAR2(150),
   attribute9			VARCHAR2(150),
   attribute10			VARCHAR2(150),
   attribute11			VARCHAR2(150),
   attribute12			VARCHAR2(150),
   attribute13			VARCHAR2(150),
   attribute14			VARCHAR2(150),
   attribute15			VARCHAR2(150),
   attribute_category		VARCHAR2(30),
   coupon_exempt_flag		VARCHAR2(1),
   vol_discount_exempt_flag	VARCHAR2(1),
   electronic_flag		VARCHAR2(1),
   start_date_active		DATE,
   end_date_active		DATE,
   global_attribute_category	VARCHAR2(150),
   global_attribute1		VARCHAR2(150),
   global_attribute2            VARCHAR2(150),
   global_attribute3		VARCHAR2(150),
   global_attribute4		VARCHAR2(150),
   global_attribute5		VARCHAR2(150),
   global_attribute6		VARCHAR2(150),
   global_attribute7		VARCHAR2(150),
   global_attribute8		VARCHAR2(150),
   global_attribute9            VARCHAR2(150),
   global_attribute10		VARCHAR2(150)
);


type IBE_DEEP_ONLY_ITEM_REC is RECORD
(
   taxable_flag			VARCHAR(1),
   shippable_item_flag		VARCHAR2(1),
   atp_flag			VARCHAR2(1),
   returnable_flag		VARCHAR2(1),
   service_item_flag		VARCHAR2(1),
   serviceable_flag		VARCHAR2(1),
   downloadable_flag		VARCHAR2(1),
   service_duration_period	VARCHAR2(10),
   min_order_qty		NUMBER,
   max_order_qty		NUMBER,
   fixed_order_qty		NUMBER,
   service_duration		NUMBER,
   service_starting_delay	NUMBER,
   segment1			VARCHAR2(40),
   segment2			VARCHAR2(40),
   segment3			VARCHAR2(40),
   segment4			VARCHAR2(40),
   segment5			VARCHAR2(40),
   segment6			VARCHAR2(40),
   segment7			VARCHAR2(40),
   segment8			VARCHAR2(40),
   segment9			VARCHAR2(40),
   segment10			VARCHAR2(40),
   segment11			VARCHAR2(40),
   segment12			VARCHAR2(40),
   segment13			VARCHAR2(40),
   segment14			VARCHAR2(40),
   segment15			VARCHAR2(40),
   segment16			VARCHAR2(40),
   segment17			VARCHAR2(40),
   segment18			VARCHAR2(40),
   segment19			VARCHAR2(40),
   segment20			VARCHAR2(40),
   attribute1                   VARCHAR2(150),
   attribute2			VARCHAR2(150),
   attribute3			VARCHAR2(150),
   attribute4			VARCHAR2(150),
   attribute5			VARCHAR2(150),
   attribute6			VARCHAR2(150),
   attribute7			VARCHAR2(150),
   attribute8			VARCHAR2(150),
   attribute9			VARCHAR2(150),
   attribute10			VARCHAR2(150),
   attribute11			VARCHAR2(150),
   attribute12			VARCHAR2(150),
   attribute13			VARCHAR2(150),
   attribute14			VARCHAR2(150),
   attribute15			VARCHAR2(150),
   attribute_category		VARCHAR2(30),
   coupon_exempt_flag		VARCHAR2(1),
   vol_discount_exempt_flag	VARCHAR2(1),
   electronic_flag		VARCHAR2(1),
   start_date_active		DATE,
   end_date_active		DATE,
   global_attribute_category	VARCHAR2(150),
   global_attribute1		VARCHAR2(150),
   global_attribute2            VARCHAR2(150),
   global_attribute3		VARCHAR2(150),
   global_attribute4		VARCHAR2(150),
   global_attribute5		VARCHAR2(150),
   global_attribute6		VARCHAR2(150),
   global_attribute7		VARCHAR2(150),
   global_attribute8		VARCHAR2(150),
   global_attribute9            VARCHAR2(150),
   global_attribute10		VARCHAR2(150),
   concatenated_segments	VARCHAR2(40),
   inventory_item_id		NUMBER
);

type IBE_CATALOG_REFCURSOR_CSR_TYPE is REF CURSOR;



-------
-- (code for PROCEDURE Load_Section removed on 01/19/2005 by rgupta)
-- This procedure is no longer necessary due to a redesign of the iStore
-- Section cache.
--



-- Start of comments
--    API name   : Load_Sections
--    Type       : Private.
--    Function   : Given a list of section IDs, loads supersection and item
--                 information for each section.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version                IN NUMBER   Required
--                 p_init_msg_list              IN VARCHAR2 Optional
--                 p_validation_level           IN NUMBER   Optional
--		             p_sectid_tbl		            IN JTF_NUMBER_TABLE
--		             p_msite_id		               IN NUMBER
--
--    OUT        : x_return_status              OUT VARCHAR2(1)
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2(2000)
--		             x_supersect_sect_tbl		   OUT NOCOPY JTF_NUMBER_TABLE
--		             x_supersect_supersect_tbl	   OUT NOCOPY JTF_NUMBER_TABLE
--		             x_sctitm_sectid_tbl		      OUT NOCOPY JTF_NUMBER_TABLE
--		             x_sctitm_itmid_tbl		      OUT NOCOPY JTF_NUMBER_TABLE
--                     x_sctitm_orgid_tbl			 OUT NOCOPY JTF_NUMBER_TABLE
--		             x_sctitm_usage_tbl		      OUT NOCOPY JTF_VARCHAR2_TABLE_300
--                 x_sctitm_flags_tbl           OUT NOCOPY JTF_VARCHAR2_TABLE_300
--                 x_sctitm_startdt_tbl         OUT NOCOPY JTF_DATE_TABLE
--                 x_sctitm_enddt_tbl           OUT NOCOPY JTF_DATE_TABLE
--                 x_sctitm_assoc_startdt_tbl   OUT NOCOPY JTF_DATE_TABLE
--                 x_sctitm_assoc_enddt_tbl     OUT NOCOPY JTF_DATE_TABLE
--
--    Version    : Current version	1.0
--
--                 Previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments

  procedure Load_Sections
		(p_api_version        		   IN  NUMBER,
       p_init_msg_list      		   IN  VARCHAR2 := NULL,
       p_validation_level   		   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
       x_return_status      		   OUT NOCOPY VARCHAR2,
       x_msg_count          		   OUT NOCOPY NUMBER,
       x_msg_data           		   OUT NOCOPY VARCHAR2,
		 p_sectid_tbl 			         IN  JTF_NUMBER_TABLE,
		 p_msite_id			            IN  NUMBER,
		 x_supersect_sect_tbl		   OUT NOCOPY JTF_NUMBER_TABLE,
		 x_supersect_supersect_tbl	   OUT NOCOPY JTF_NUMBER_TABLE,
		 x_sctitm_sectid_tbl		      OUT NOCOPY JTF_NUMBER_TABLE,
		 x_sctitm_itmid_tbl		      OUT NOCOPY JTF_NUMBER_TABLE,
		 x_sctitm_orgid_tbl			 OUT NOCOPY JTF_NUMBER_TABLE,
		 x_sctitm_usage_tbl		      OUT NOCOPY JTF_VARCHAR2_TABLE_300,
       x_sctitm_flags_tbl           OUT NOCOPY JTF_VARCHAR2_TABLE_300,
       x_sctitm_startdt_tbl         OUT NOCOPY JTF_DATE_TABLE,
       x_sctitm_enddt_tbl           OUT NOCOPY JTF_DATE_TABLE,
       x_sctitm_assoc_startdt_tbl   OUT NOCOPY JTF_DATE_TABLE,
       x_sctitm_assoc_enddt_tbl     OUT NOCOPY JTF_DATE_TABLE
		);



-- Start of comments
--    API name   : GetLeafSubSectIDs
--    Type       : Private.
--    Function   : Given a section id, drills down to the
--		   leaf level and returns leaf level section ids
--		   If p_preview_flag = 'T' returns sections
--		   whose status_code is 'PUBLISHED' or 'UNPUBLISHED'.
--		   Otherwise, returns information for sections whose
--		   status_code is 'PUBLISHED'
--
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   Required
--                 p_init_msg_list      IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER   Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--                 p_preview_flag      IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--		   p_sectid 		IN NUMBER
--		   p_msite_id		IN NUMBER
--
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--		   x_leaf_subsect_ids	OUT IBE_CATALOG_REFCURSOR_CSR_TYPE
--			Record Type = (leaf_section_id NUMBER, sort_order NUMBER)
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments

  procedure GetLeafSubSectIDs
		(
		 p_api_version        	IN  NUMBER,
                 p_init_msg_list      	IN  VARCHAR2 := NULL,
                 p_validation_level   	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		 x_return_status	OUT NOCOPY VARCHAR2,
		 x_msg_count		OUT NOCOPY NUMBER,
		 x_msg_data		OUT NOCOPY VARCHAR2,

                 p_preview_flag      	IN  VARCHAR2 := NULL,
		 p_sectid 		IN  NUMBER,
		 p_msite_id		IN  NUMBER,
		 x_leafsubsectid_csr 	OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE
		);



-- Start of comments
--    API name   : GetSuperSectIDs
--    Type       : Private.
--    Function   : Given a section ID, returns the super sections up to
--		             the root of the store, ordered from the section's immediate
--		             parent to the root.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version       IN  NUMBER   Required
--                 p_init_msg_list     IN  VARCHAR2 Optional
--                      Default = FND_API.G_FALSE
--                 p_validation_level  IN  NUMBER   Optional
--                      Default = FND_API.G_VALID_LEVEL_FULL
--		             p_sectid 		      IN NUMBER    Required
--		             p_msite_id		      IN NUMBER    Required
--
--    OUT        : x_return_status     OUT VARCHAR2(1)
--                 x_msg_count         OUT NUMBER
--                 x_msg_data          OUT VARCHAR2(2000)
--		             x_supersectid_csr	OUT IBE_CATALOG_REFCURSOR_CSR_TYPE
--			               Record Type = IBE_ID_REC
--
--    Version    : Current version	1.0
--
--                 Previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments

  procedure GetSuperSectIDs
		(p_api_version        	IN  NUMBER,
       p_init_msg_list      	IN  VARCHAR2 := NULL,
       p_validation_level   	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		 x_return_status	      OUT NOCOPY VARCHAR2,
		 x_msg_count		      OUT NOCOPY NUMBER,
		 x_msg_data		         OUT NOCOPY VARCHAR2,
		 p_sectid 		         IN  NUMBER,
		 p_msite_id		         IN  NUMBER,
		 x_supersectid_csr 	   OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE
		);



--    Start of comments
--    API name   : GetAvailableServices
--    Type       : Public
--    Function   : retrieve Service Items related to this Item.
--    After a service item is set up, it is generally available to all
--    serviceable products.  OKS provides functionalites to set up exclusion
--    between serviceable product and serivce item; exclusion between customer
--    and service item.  This API will take the exclusion rules into account
--    as well.
--
--    Pre-reqs   : None.
--    Parameters :
--    IN         :
--     p_api_version        IN  NUMBER   	 Required
--     p_init_msg_list      IN  VARCHAR2 	 Optional
--                     Default = FND_API.G_FALSE
--     p_validation_level   IN  NUMBER   	 Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--		   p_preview_flag	IN  VARCHAR2       Optional
--                     Default = FND_API.G_FALSE
--		   p_originid 		IN  NUMBER         Required
--		   p_origintype		IN  VARCHAR2(240)  Required
--		   p_reltype_code	IN  VARCHAR2(30)   Required
--		   p_dest_type		IN  VARCHAR2(240)  Required
--     p_commit IN  VARCHAR2 := FND_API.G_FALSE Optional
--     p_product_item_id IN  NUMBER Required
--  	  p_customer_id     IN  NUMBER Optional,
--     p_product_revision  IN  VARCHAR2 Optional
--  	  p_request_date    IN  DATE Optional
--
--
--    OUT        :
--     x_return_status      OUT VARCHAR2(1)
--     x_msg_count          OUT NUMBER
--     x_msg_data           OUT VARCHAR2(2000)
--		   x_service_item_ids	OUT nocopy JTF_NUMBER_TABLE
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
  PROCEDURE GetAvailableServices(
	  p_api_version_number              IN  NUMBER := 1,
	  p_init_msg_list                   IN  VARCHAR2 := NULL,
	  p_commit                          IN  VARCHAR2 := NULL,
	  x_return_status                   OUT NOCOPY VARCHAR2,
	  x_msg_count                       OUT NOCOPY NUMBER,
	  x_msg_data                        OUT NOCOPY VARCHAR2,
	  p_product_item_id                 IN  NUMBER,
	  p_customer_id                     IN  NUMBER,
	  p_product_revision                IN  VARCHAR2,
	  p_request_date                    IN  DATE,
	  x_service_item_ids                OUT NOCOPY JTF_NUMBER_TABLE
	);
-- Start of comments
--    API name   : GetRelatedCatOrSectIDs
--    Type       : Private.
--    Function   : Given an origin id, origin type, relationship type code,
--		   and destination object type, returns the ids
--		   of all objects of the given type related to the
--		   section by the given relationship code.  This API
--		   should only be used for destination types 'S' (section)
--		   and 'C' (category).  The p_preview_flag is only applicable
--		   when the destination object type is 'S' (section).  If
--		   p_preview_flag is true, returns sections whose
--		   web_status is 'PUBLISHED' or 'UNPUBLISHED'.
--		   Otherwise, returns sections whose web_status is
--		   'PUBLISHED'.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   	   Required
--                 p_init_msg_list      IN  VARCHAR2 	   Optional
--                     Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER   	   Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--		   p_preview_flag	IN  VARCHAR2(1)    Optional
--                     Default = FND_API.G_FALSE
--		   p_originid 		IN  NUMBER         Required
--		   p_origintype		IN  VARCHAR2(240)  Required
--		   p_reltype_code	IN  VARCHAR2(30)   Required
--		   p_dest_type		IN  VARCHAR2(240)  Required
--
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--		   x_relatedid_tbl	OUT nocopy JTF_NUMBER_TABLE
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
  procedure GetRelatedCatOrSectIDs
		(
		 p_api_version 		IN  NUMBER,
                 p_init_msg_list      	IN  VARCHAR2 := NULL,
                 p_validation_level   	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		 x_return_status	OUT NOCOPY VARCHAR2,
		 x_msg_count		OUT NOCOPY NUMBER,
		 x_msg_data		OUT NOCOPY VARCHAR2,

		 p_preview_flag		IN  VARCHAR2 := NULL,
		 p_originid		IN  NUMBER,
		 p_origintype		IN  VARCHAR2,
		 p_reltype_code		IN  VARCHAR2,
		 p_dest_type		IN  VARCHAR2,
		 x_relatedid_tbl 	OUT nocopy JTF_NUMBER_TABLE
		);



-- Start of comments
--    API name   : Get_Basic_Item_Load_Query
--    Type       : Private.
--    Function   : Returns select and from clauses for an item load query when given
--		   the load level and category set id.
--    Pre-reqs   : None.
--    Parameters :
--    IN  	 : p_load_level			IN NUMBER
--		 	Possible Values: G_ITEM_SHALLOW, G_ITEM_DEEP, G_ITEM_DEEP_ONLY
--		   p_category_set_id		IN NUMBER
--
--    OUT        : x_basic_query
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
  procedure Get_Basic_Item_Load_Query
  (
    p_load_level	IN	NUMBER,
    x_basic_query	OUT	NOCOPY VARCHAR2
  );

-- Start of comments
--    API name   : Process_Order_By_Clause
--    Type       : Private.
--    Function   : Takes comma separated list of columns (with option asc or desc) of
--		   MTL_SYSTEM_ITEMS_VL and appends 'MSIV.' in front of each column name so
--                 it can be used in the order by clause of a query that joins with
--                 MTL_SYSTEM_ITEMS_VL.
--    Pre-reqs   : None.
--    Parameters :
--    IN  	 : p_order_by_clause			IN VARCHAR2
--
--
--    OUT        : x_order_by_clause			OUT VARCHAR2
--
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
procedure Process_Order_By_Clause
	(p_order_by_clause IN VARCHAR2,
	 x_order_by_clause OUT NOCOPY VARCHAR2
	);

-- Start of comments
--    API name   : Get_Format_Mask_and_Symbol
--    Type       : Private.
--    Function   : Given currency code and length, retrieves format mask and
--		   currency symbol.  Uses FND_CURRENCY.get_format_mask().
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        	IN  NUMBER   Required
--                 p_init_msg_list      	IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_validation_level   	IN  NUMBER   Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--		   p_currency_code		IN NUMBER
--		   p_length			IN NUMBER
--
--    OUT        : x_return_status      	OUT VARCHAR2(1)
--                 x_msg_count          	OUT NUMBER
--                 x_msg_data           	OUT VARCHAR2(2000)
--		   x_format_mask		OUT nocopy VARCHAR2
--		   x_currency_symbol		OUT nocopy VARCHAR2
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
procedure Get_Format_Mask_and_Symbol
	(p_api_version        		IN  NUMBER,
         p_init_msg_list      		IN  VARCHAR2 := NULL,
         p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	 x_return_status      		OUT NOCOPY VARCHAR2,
         x_msg_count          		OUT NOCOPY NUMBER,
         x_msg_data           		OUT NOCOPY VARCHAR2,

	 p_currency_code		IN VARCHAR2,
	 p_length			IN NUMBER,
	 x_format_mask			OUT nocopy VARCHAR2,
	 x_currency_symbol		OUT nocopy VARCHAR2
	);

procedure validate_quantity
        (p_api_version        		IN  NUMBER,
         p_init_msg_list      		IN  VARCHAR2 := NULL,
         p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
         x_return_status      		OUT NOCOPY VARCHAR2,
         x_msg_count          		OUT NOCOPY NUMBER,
         x_msg_data           		OUT NOCOPY VARCHAR2,

         p_item_id_tbl			IN  JTF_NUMBER_TABLE,
         p_organization_id_tbl		IN  JTF_NUMBER_TABLE,
         p_qty_tbl			IN  JTF_NUMBER_TABLE,
         p_uom_code_tbl			IN  JTF_VARCHAR2_TABLE_100,
         x_valid_qty_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100
        );

--Bug 3063233
procedure validate_de_qty_msite_check
        (p_api_version        		IN  NUMBER,
         p_init_msg_list      		IN  VARCHAR2 := NULL,
	    p_reqd_validation           IN  JTF_VARCHAR2_TABLE_100,
	    p_msite_id                  IN  NUMBER,
         x_return_status      		OUT NOCOPY VARCHAR2,
         x_msg_count          		OUT NOCOPY NUMBER,
         x_msg_data           		OUT NOCOPY VARCHAR2,
         p_item_id_tbl			IN  JTF_NUMBER_TABLE,
         p_organization_id_tbl		IN  JTF_NUMBER_TABLE,
         p_qty_tbl			IN  JTF_NUMBER_TABLE,
         p_uom_code_tbl			IN  JTF_VARCHAR2_TABLE_100,
         x_valid_qty_tbl                OUT NOCOPY JTF_VARCHAR2_TABLE_100
        );

procedure load_msite_languages
        (x_lang_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
         x_tran_lang_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
         x_desc_tbl			OUT NOCOPY JTF_VARCHAR2_TABLE_300 --gzhang 07/19/2002, bug#2469521
        );

procedure load_language
        (p_lang_code			IN VARCHAR2,
         x_tran_lang_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
         x_desc_tbl			OUT NOCOPY JTF_VARCHAR2_TABLE_300, --gzhang 07/19/2002, bug#2469521
         x_nls_lang			OUT NOCOPY VARCHAR2  --jqu 1/19/2005
        );

Procedure LOAD_ITEM
		(p_api_version        		IN  NUMBER,
                 p_init_msg_list      		IN  VARCHAR2 := NULL,
                 p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
                 x_msg_count          		OUT NOCOPY NUMBER,
                 x_msg_data           		OUT NOCOPY VARCHAR2,

		 p_load_level			IN  NUMBER,
		 p_preview_flag			IN  VARCHAR2,
		 p_itmid 			IN  NUMBER,
		 p_partnum			IN  VARCHAR2,
		 p_model_id			IN  NUMBER    := FND_API.G_MISS_NUM,
		 p_organization_id		IN  NUMBER,
		 p_category_set_id		IN  NUMBER,
		 p_retrieve_price		IN  VARCHAR2,

		 p_price_list_id		IN  NUMBER,
		 p_currency_code		IN  VARCHAR2,
		 p_price_request_type		IN  VARCHAR2,
		 p_price_event			IN  VARCHAR2,
	         p_minisite_id			IN  NUMBER := NULL,
		 x_item_csr			OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE,
		 x_category_id_csr		OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE,
		 x_configurable			OUT NOCOPY VARCHAR2,
		 x_model_bundle_flag		OUT NOCOPY VARCHAR2,
		 x_uom_csr			OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE,

		 x_price_csr			OUT NOCOPY IBE_PRICE_PVT.PRICE_REFCURSOR_TYPE,
	         x_line_index_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
	         x_price_status_code		OUT NOCOPY VARCHAR2,
		 x_price_status_text		OUT NOCOPY VARCHAR2
		);


Procedure Load_Items
		(p_api_version        		IN  NUMBER,
                 p_init_msg_list      		IN  VARCHAR2 := NULL,
                 p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
                 x_msg_count          		OUT NOCOPY NUMBER,
                 x_msg_data           		OUT NOCOPY VARCHAR2,

		 p_load_level			IN  NUMBER,
		 p_preview_flag			IN  VARCHAR2,
		 p_itmid_tbl 			IN  JTF_NUMBER_TABLE,
		 p_partnum_tbl			IN  JTF_VARCHAR2_TABLE_100,
		 p_model_id_tbl			IN  JTF_NUMBER_TABLE,
		 p_organization_id		IN  NUMBER,
		 p_category_set_id		IN  NUMBER,
		 p_retrieve_price		IN  VARCHAR2,
		 p_price_list_id		IN  NUMBER,
		 p_currency_code		IN  VARCHAR2,
		 p_price_request_type		IN  VARCHAR2,
		 p_price_event			IN  VARCHAR2,
	         p_minisite_id			IN  NUMBER := NULL,
		 x_category_id_tbl		OUT NOCOPY JTF_NUMBER_TABLE,
		 x_configurable_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
		 x_model_bundle_flag_tbl	OUT NOCOPY JTF_VARCHAR2_TABLE_100,
		 x_price_csr			OUT NOCOPY IBE_PRICE_PVT.PRICE_REFCURSOR_TYPE,
	         x_line_index_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
	 	 x_price_status_code		OUT NOCOPY VARCHAR2,
		 x_price_status_text		OUT NOCOPY VARCHAR2
		);

Procedure Get_Item_Type
		(
     		 p_api_version         IN  NUMBER,
     		 p_init_msg_list       IN  VARCHAR2 := NULL,
     		 p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     		 p_item_ids            IN  JTF_NUMBER_TABLE,
     		 p_organization_id     IN  NUMBER,
     		 x_item_type           OUT NOCOPY JTF_VARCHAR2_TABLE_100,
     		 x_return_status       OUT NOCOPY VARCHAR2,
     		 x_msg_count  	       OUT NOCOPY NUMBER,
     		 x_msg_data   	       OUT NOCOPY VARCHAR2
		);

PROCEDURE IS_ITEM_IN_MINISITE
(
     		p_api_version         IN  NUMBER,
     		p_init_msg_list       IN  VARCHAR2 := NULL,
     		p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     		p_item_ids            IN  JTF_NUMBER_TABLE,
     		p_minisite_id         IN  NUMBER,
     		x_minisite_item_ids   OUT NOCOPY JTF_NUMBER_TABLE,
     		x_return_status	      OUT NOCOPY VARCHAR2,
     		x_msg_count  	      OUT NOCOPY NUMBER,
     		x_msg_data   	      OUT NOCOPY VARCHAR2
		);

PROCEDURE IS_ITEM_CONFIGURABLE
(
     p_item_id            IN  NUMBER,
     p_organization_id		IN  NUMBER,
     x_configurable		OUT NOCOPY VARCHAR2
     ) ;


end IBE_CATALOG_PVT;


 

/
