--------------------------------------------------------
--  DDL for Package CS_INSTALLEDBASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INSTALLEDBASE_PUB" AUTHID CURRENT_USER AS
/* $Header: cspibs.pls 120.1 2005/08/29 16:34:21 epajaril noship $ */

-- ---------------------------------------------------------
-- Declare Data Types
-- ---------------------------------------------------------
TYPE DFF_Rec_Type IS RECORD
(
	context				VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	attribute1			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute2			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute3			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute4			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute5			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute6			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute7			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute8			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute9			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute10			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute11			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute12			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute13			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute14			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	attribute15			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
);

TYPE OrderInfo_Rec_Type IS RECORD
(
	line_id				NUMBER		DEFAULT FND_API.G_MISS_NUM,
	line_service_detail_id	NUMBER		DEFAULT FND_API.G_MISS_NUM
);

TYPE PRICE_ATT_Rec_Type IS RECORD
(
	PRICING_CONTEXT      VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE1   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE2   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE3   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE4   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE5   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE6   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE7   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE8   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE9   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE10   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE11   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE12   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE13   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE14   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE15   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE16   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE17   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE18   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE19   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE20   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE21   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE22   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE23   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE24   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE25   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE26   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE27   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE28   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE29   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE30   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE31   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE32   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE33   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE34   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE35   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE36   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE37   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE38   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE39   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE40   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE41   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE42   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE43   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE44   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE45   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE46   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE47   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE48   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE49   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE50   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE51   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE52   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE53   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE54   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE55   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE56   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE57   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE58   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE59   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE60   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE61   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE62   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE63   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE64   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE65   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE66   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE67   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE68   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE69   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE70   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE71   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE72   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE73   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE74   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE75   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE76   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE77   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE78   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE79   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE80   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE81   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE82   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE83   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE84   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE85   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE86   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE87   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE88   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE89   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE90   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE91   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE92   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE93   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE94   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE95   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE96   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE97   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE98   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE99   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE100   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR
	);

TYPE ReturnInfo_Rec_Type IS RECORD
(
	return_by_date			DATE			DEFAULT FND_API.G_MISS_DATE,
	rma_line_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	actual_returned_date	DATE			DEFAULT FND_API.G_MISS_DATE
);

TYPE CP_Prod_Rec_Type IS RECORD
(
	customer_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	inv_item_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	cp_status_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	start_date_active		DATE			DEFAULT FND_API.G_MISS_DATE,
	end_date_active		DATE			DEFAULT FND_API.G_MISS_DATE,
	misc_order_info		OrderInfo_Rec_Type,
	misc_return_info		ReturnInfo_Rec_Type,
	quantity				NUMBER		DEFAULT FND_API.G_MISS_NUM,
	uom_code				VARCHAR2(25)	DEFAULT FND_API.G_MISS_CHAR,
	net_amount			NUMBER         DEFAULT FND_API.G_MISS_NUM,
	currency_code			VARCHAR2(15)	DEFAULT FND_API.G_MISS_CHAR,
	po_number				VARCHAR2(50)	DEFAULT FND_API.G_MISS_CHAR,
	delivered_flag			VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR,
	shipped_flag			VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR,
	cp_type				VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	system_id				NUMBER         DEFAULT FND_API.G_MISS_NUM,
	prod_agreement_id		NUMBER         DEFAULT FND_API.G_MISS_NUM,
	ship_to_site_use_id		NUMBER         DEFAULT FND_API.G_MISS_NUM,
	bill_to_site_use_id		NUMBER         DEFAULT FND_API.G_MISS_NUM,
	install_site_use_id		NUMBER         DEFAULT FND_API.G_MISS_NUM,
	installation_date		DATE           DEFAULT FND_API.G_MISS_DATE,
	config_type			VARCHAR2(30)   DEFAULT FND_API.G_MISS_CHAR,
	config_start_date		DATE           DEFAULT FND_API.G_MISS_DATE,
	config_parent_cp_id		NUMBER         DEFAULT FND_API.G_MISS_NUM,
	project_id			NUMBER         DEFAULT FND_API.G_MISS_NUM,
	task_id				NUMBER         DEFAULT FND_API.G_MISS_NUM,
	platform_version_id		NUMBER		DEFAULT FND_API.G_MISS_NUM,
	customer_view_flag		VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR,
	merchant_view_flag		VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR,
	desc_flex				DFF_Rec_Type,
	price_attribs			PRICE_ATT_Rec_Type,
        shipped_date			DATE			DEFAULT FND_API.G_MISS_DATE,
        ship_to_contact_id        NUMBER         DEFAULT FND_API.G_MISS_NUM,
        invoice_to_contact_id     NUMBER         DEFAULT FND_API.G_MISS_NUM,
	expired_flag             VARCHAR2(1)    DEFAULT FND_API.G_MISS_CHAR,
	customer_product_status_id     NUMBER         DEFAULT FND_API.G_MISS_NUM ,
	split_flag               VARCHAR2(1)    DEFAULT FND_API.G_MISS_CHAR,
	organization_id          NUMBER         DEFAULT FND_API.G_MISS_NUM,
        returned_quantity       NUMBER         DEFAULT FND_API.G_MISS_NUM,
        config_root_id          NUMBER         DEFAULT FND_API.G_MISS_NUM  -- Bug 1898630 srramakr
);


TYPE CP_Ship_Rec_Type IS RECORD
(
	cp_id				NUMBER		DEFAULT FND_API.G_MISS_NUM,
	cp_revision_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	order_line_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	shipped_qty			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	shipped_date			DATE			DEFAULT FND_API.G_MISS_DATE,
	ship_to_site_use_id		NUMBER		DEFAULT FND_API.G_MISS_NUM,
	serial_number			VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	lot_number			VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	revision				VARCHAR2(15)	DEFAULT FND_API.G_MISS_CHAR
);


TYPE Cascade_Upd_Flag_Rec_Type IS RECORD
(
	cp_status_id_cascade		VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	start_date_active_cascade	VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	end_date_active_cascade		VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	misc_order_info_cascade		VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	misc_return_info_cascade		VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	delivered_flag_cascade		VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	system_id_cascade			VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	prod_agreement_id_cascade	VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	ship_to_site_use_id_cascade	VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	bill_to_site_use_id_cascade	VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	install_site_use_id_cascade	VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	installation_date_cascade	VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	config_type_cascade			VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	config_start_date_cascade	VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	shipped_date_cascade		VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	project_id_cascade			VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	task_id_cascade			VARCHAR2(1)	DEFAULT FND_API.G_TRUE
);


TYPE Abort_Upd_On_Warn_Rec_Type IS RECORD
(
	srl_owned_by_diff_cust		VARCHAR2(1)	DEFAULT FND_API.G_TRUE,
	srl_exists_for_diff_item		VARCHAR2(1)	DEFAULT FND_API.G_TRUE
);


TYPE Config_Rec_Type IS RECORD
(
	config_cp_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	config_parent_cp_id		NUMBER		DEFAULT FND_API.G_MISS_NUM,
	config_type			VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	customer_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	inventory_item_id		NUMBER		DEFAULT FND_API.G_MISS_NUM,
	serial_number			VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	lot_number			VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
);

TYPE Config_Tbl_Type IS TABLE OF Config_Rec_Type
INDEX BY BINARY_INTEGER;


TYPE CP_Param_Rec_Type IS RECORD
(
	customer_product_id	NUMBER		DEFAULT FND_API.G_MISS_NUM,
	parameter_type		VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	name				VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	value			VARCHAR2(240)	DEFAULT FND_API.G_MISS_CHAR,
	status			VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	application_id		NUMBER		DEFAULT FND_API.G_MISS_NUM,
	start_date_active	DATE			DEFAULT FND_API.G_MISS_DATE,
	end_date_active	DATE			DEFAULT FND_API.G_MISS_DATE
);


TYPE CP_Query_IP_Rec_Type IS RECORD
(
	cp_rec          CP_Prod_Rec_Type,
	ship_rec        CP_Ship_Rec_Type,
	party_id        NUMBER	DEFAULT FND_API.G_MISS_NUM,
	svc_provider_id NUMBER	DEFAULT FND_API.G_MISS_NUM
);


TYPE CP_Query_OP_Rec_Type IS RECORD
(
	cp_id      	NUMBER		DEFAULT FND_API.G_MISS_NUM,
	account_id     NUMBER		DEFAULT FND_API.G_MISS_NUM,
	account_number VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	inv_item_id	NUMBER		DEFAULT FND_API.G_MISS_NUM,
	serial_number  VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	lot_number     VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	ship_date      DATE			DEFAULT FND_API.G_MISS_DATE
);


TYPE CP_Query_OP_Tbl_Type IS TABLE OF CP_Query_OP_Rec_Type
INDEX BY BINARY_INTEGER;


TYPE CP_Contact_Rec_Type IS RECORD
(
	source_object_code		VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	source_object_id		NUMBER		DEFAULT FND_API.G_MISS_NUM,
	contact_category         VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	contact_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	contact_type             VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	svc_provider_flag		VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR,
	primary_flag             VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR,
	preferred_flag           VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR,
	start_date_active        DATE			DEFAULT FND_API.G_MISS_DATE,
	end_date_active		DATE			DEFAULT FND_API.G_MISS_DATE,
	desc_flex				DFF_Rec_Type
);

																-- Added the line_inst_detail_id to this record type becoz this same record type
-- is used for getting the line installation details given an order_line_id and
-- it must return the line_inst_detail_id.
-- Also, had to remove desc_flex from this record type since a PL/SQL table
-- cannot be based on a record type that is non-scalar.


TYPE Line_Inst_Dtl_Rec_Type IS RECORD
(
	line_inst_detail_id			NUMBER		DEFAULT FND_API.G_MISS_NUM,
	order_line_id				NUMBER		DEFAULT FND_API.G_MISS_NUM,
	quote_line_shipment_id        NUMBER		DEFAULT FND_API.G_MISS_NUM,
	source_line_inst_detail_id    NUMBER		DEFAULT FND_API.G_MISS_NUM,
	transaction_type_id           NUMBER		DEFAULT FND_API.G_MISS_NUM,
	system_id                     NUMBER		DEFAULT FND_API.G_MISS_NUM,
	customer_product_id           NUMBER		DEFAULT FND_API.G_MISS_NUM,
	type_code                     VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	quantity                      NUMBER		DEFAULT FND_API.G_MISS_NUM,
	installed_at_party_site_id    NUMBER		DEFAULT FND_API.G_MISS_NUM,
	installed_cp_return_by_date   DATE			DEFAULT FND_API.G_MISS_DATE,
	installed_cp_rma_line_id      NUMBER		DEFAULT FND_API.G_MISS_NUM,
	new_cp_rma_line_id            NUMBER		DEFAULT FND_API.G_MISS_NUM,
	new_cp_return_by_date         DATE			DEFAULT FND_API.G_MISS_DATE,
	expected_installation_date    DATE			DEFAULT FND_API.G_MISS_DATE
	--desc_flex                     DFF_Rec_Type
);

TYPE Line_Inst_Dtl_Tbl_Type is TABLE OF Line_Inst_Dtl_Rec_Type
INDEX BY BINARY_INTEGER;


--------------------------------------------------------------------------

-- Start of comments
--  API name   : Create_Base_Product
--  Type       : Public
--  Function   : This API creates a product record in the installed base in the
--               absence of shipment-related information.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Create_Base_Product IN Parameters:
--   p_cp_rec            IN   CP_Prod_Rec_Type  Required
--
--  Create_Base_Product OUT NOCOPY Parameters:
--   x_cp_id                 OUT NOCOPY  NUMBER
--   x_object_version_number OUT NOCOPY  NUMBER
--
--
--  Version	:	Current version	2.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Create_Base_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_rec				IN	CP_Prod_Rec_Type,
	p_created_manually_flag	IN	VARCHAR2 DEFAULT 'N',
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	x_cp_id				OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY 	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Record_Shipment_Info
--  Type       : Public
--  Function   : This API modifies a product record already existing in the
--               installed base to record shipment-related information.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Record_Shipment_Info IN Parameters:
--   p_ship_rec          IN   CP_Ship_Rec_Type  Required
--
--
--  Record_Shipment_Info OUT NOCOPY Parameters:
--   x_new_cp_id         OUT NOCOPY  NUMBER
--
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Record_Shipment_Info
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY  	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ship_rec			IN	CP_Ship_Rec_Type,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	x_new_cp_id			OUT NOCOPY	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Replace_Product
--  Type       : Public
--  Function   : This API replaces a product in the installed base with another
--               one. It also replaces the components of the product being
--               replaced.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Replace_Product IN Parameters:
--   p_cp_id             IN   NUMBER           Required
--   p_old_cp_status_id  IN   NUMBER           Required
--   p_cp_rec            IN   CP_Prod_Rec_Type Required
--   p_inherit_contacts	IN	VARCHAR2		  Optional
--	                                          Default = FND_API.G_FALSE
--   p_upgrade	          IN	VARCHAR2		  Optional
--	                                          Default = FND_API.G_FALSE
--
--  Replace_Product OUT NOCOPY Parameters:
--   x_new_cp_id         OUT NOCOPY  NUMBER
--
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Replace_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_old_cp_status_id		IN   NUMBER,
	p_cp_rec				IN	CP_Prod_Rec_Type,
	p_inherit_contacts		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_upgrade				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	x_new_cp_id			OUT NOCOPY	NUMBER,
	p_qty_mismatch_ok		IN	VARCHAR2	DEFAULT FND_API.G_FALSE
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Update_Product
--  Type       : Public
--  Function   : This API updates product information in the installed base.
--               Depending on "cascade" parameters passed, it also replaces the
--               components of the product being updated with the same
--               information.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT OCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Update_Product IN Parameters:
--   p_cp_id               IN   NUMBER                     Required
--   p_as_of_date          IN   DATE                       Optional
--                                                         Default = SYSDATE
--   p_cp_rec              IN   CP_Prod_Rec_Type           Required
--   p_ship_rec            IN   CP_Ship_Rec_Type           Required
--   p_abort_on_warn_flag  IN   Abort_Upd_On_Warn_Rec_Type Required
--   p_cascade_updates_flagIN   Cascade_Upd_Flag_Rec_Type  Required
--   p_cascade_inst_date_change_war	IN	VARCHAR2	    Optional
--                                                       Default=FND_API.G_TRUE,
--   p_comments	       IN	VARCHAR2	    Optional
--                                                       Default=NULL,
--   p_update_by_customer_flag IN VARCHAR2               Optional
--                                                       Default=FND_API.G_TRUE
-- The last parameter indicates whether this update to the record is being made
-- by a customer (from iSupport UI) or by an agent of the merchant. A customer
-- will be able to update only those records in the customer's view but a
-- merchant will be able to update both records in the merchant's view as well
-- as customer's view.
--
--  Update_Product OUT NOCOPY Parameters:

--   None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Update_Product
(
	p_api_version					IN	NUMBER,
	p_init_msg_list				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit						IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status				OUT NOCOPY VARCHAR2,
	x_msg_count					OUT NOCOPY	NUMBER,
	x_msg_data					OUT NOCOPY	VARCHAR2,
	p_cp_id						IN	NUMBER,
	p_as_of_date					IN	DATE	DEFAULT sysdate,
	p_cp_rec						IN	CP_Prod_Rec_Type,
	p_ship_rec					IN	CP_Ship_Rec_Type,
	p_comments					IN	VARCHAR2 DEFAULT NULL,
	p_update_by_customer_flag		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_abort_on_warn_flag			IN	Abort_Upd_On_Warn_Rec_Type,
	p_cascade_updates_flag			IN	Cascade_Upd_Flag_Rec_Type,
	p_cascade_inst_date_change_war	IN	VARCHAR2	DEFAULT FND_API.G_TRUE,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM
);
--------------------------------------------------------------------------

-- Start of comments
--  API name   : Create_Revision
--  Type       : Public
--  Function   :
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Create_Revision IN Parameters:
--   p_cp_id                IN   NUMBER              Required
--   p_rev_inv_item_id      IN   NUMBER              Required
--   p_quantity             IN   NUMBER              Required
--   p_order_info           IN   OrderInfo_Rec_Type  Required
--   p_desc_flex            IN   DFF_Rec_Type        Required
--   p_start_date_active    IN   DATE                Optional
--                                                Default = FND_API.G_MISS_DATE
--   p_end_date_active      IN   DATE                Optional
--                                                Default = FND_API.G_MISS_DATE
--   p_delivered_flag       IN   VARCHAR2(1)         Optional
--                                                Default = FND_API.G_MISS_CHAR

--  Create_Revision OUT NOCOPY Parameters:
--   x_cp_rev_id 	        OUT NOCOPY  NUMBER
--   x_curr_rev_of_cp_updtd OUT NOCOPY  VARCHAR2
--   x_object_version_number OUT NOCOPY NUMBER
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Create_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY 	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_rev_inv_item_id		IN	NUMBER,
	p_order_info			IN	OrderInfo_Rec_Type,
	p_desc_flex			IN	DFF_Rec_Type,
	p_start_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_end_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_delivered_flag		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
	x_cp_rev_id			OUT NOCOPY	NUMBER,
	x_curr_rev_of_cp_updtd	OUT  NOCOPY	VARCHAR2,
	x_object_version_number	OUT  NOCOPY	NUMBER
);


PROCEDURE Update_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_rev_id			IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_start_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_end_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_desc_flex			IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	x_object_version_number	OUT NOCOPY	NUMBER
);
--------------------------------------------------------------------------

-- Start of comments
--  API name   : Specify_Contact
--  Type       : Public
--  Function   :
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Specify_Contact IN Parameters:
--   p_contact_rec 		IN	CP_Contact_Rec_Type

--  Specify_Contact OUT NOCOPY Parameters:
--   x_cs_contact_id     OUT NOCOPY  NUMBER
--   x_object_version_number OUT NOCOPY NUMBER
--
--  Version	:	Current version	2.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Specify_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY 	VARCHAR2,
	x_msg_count			OUT  NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_contact_rec			IN	CP_Contact_Rec_Type,
	x_cs_contact_id		OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);


--------------------------------------------------------------------------

-- Start of comments
--  API name   : Update_Contact
--  Type       : Public
--  Function   :
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Update_Contact IN Parameters:
--   p_cs_contact_id     IN   NUMBER       Required
--   p_contact_rec		IN	CP_Contact_Rec_Type

--  Update_Contact OUT NOCOPY Parameters:
--   None
--
--  Version	:	Current version	2.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Update_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cs_contact_id		IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_contact_rec			IN	CP_Contact_Rec_Type,
	x_object_version_number	OUT NOCOPY	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Delete_Contact
--  Type       : Public
--  Function   : Deletes a specified contact.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Delete_Contact IN Parameters:
--   p_cs_contact_id     IN   NUMBER    Required

--  Delete_Contact OUT NOCOPY Parameters:
--  None

--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Delete_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cs_contact_id		IN	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Get_CP_ID
--  Type       : Public
--  Function   : This API accepts p_reference_number and passes back the
--               Customer Product Id based on a lookup on the REFERENCE_NUMBER
--               column in CS_CUSTOMER_PRODUCTS table.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Get_CP_ID IN Parameters:
--   p_reference_number  IN   NUMBER    Required

--  Get_CP_ID OUT NOCOPY Parameters:
--   x_cp_id             OUT NOCOPY  NUMBER
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Get_CP_ID
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_reference_number		IN	NUMBER,
	x_cp_id				OUT NOCOPY	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Get_Reference_Number
--  Type       : Public
--  Function   : This API accepts p_cp_id and passes back the Reference Number
--               based on a lookup on the Customer Product Id column in
--               CS_CUSTOMER_PRODUCTS table.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Get_Reference_Number IN Parameters:
--   p_cp_id             IN   NUMBER    Required

--  Get_Reference_Number OUT NOCOPY Parameters:
--   x_reference_number  OUT NOCOPY  NUMBER
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Get_Reference_Number
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	x_reference_number		OUT NOCOPY	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Get_CP_ID (overloaded procedure)
--  Type       : Public
--  Function   : This API passes back the Customer Product Id and the Reference
--               Number based on certain lookups on the CUSTOMER_PRODUCTS table --               depending on the parameters passed.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT OCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Get_CP_ID IN Parameters:
--   p_serial_number     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_MISS_CHAR
--   p_config_type       IN   VARCHAR2  Optional
--                                      Default = FND_API.G_MISS_CHAR
--   p_as_of_date        IN   DATE      Optional
--                                      Default = FND_API.G_MISS_DATE
--   p_customer_id       IN   NUMBER    Optional
--                                      Default = FND_API.G_MISS_NUM
--   p_inv_item_id       IN   NUMBER    Optional
--                                      Default = FND_API.G_MISS_NUM

--  Get_CP_ID OUT NOCOPY Parameters:
--   x_cp_id             OUT NOCOPY  NUMBER
--   x_reference_number  OUT NOCOPY  NUMBER
--   x_unique_flag       OUT NOCOPY  VARCHAR2
--
--  Version   :     Current version     1.0
--                  Initial version     1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Get_CP_ID
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_serial_number		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
	p_config_type			IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
	p_as_of_date			IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_customer_id			IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
	p_inv_item_id			IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
	x_unique_flag			OUT NOCOPY	VARCHAR2,
	x_reference_number		OUT NOCOPY	NUMBER,
	x_cp_id				OUT NOCOPY	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Get_Configuration
--  Type       : Public
--  Function   : This API passes back the the configuration of a particular
--               product in the installed base having a certain configuration
--               type as of a given date, in the form of a table of records.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Get_Configuration IN Parameters:
--   p_cp_id             IN   NUMBER    Required
--   p_config_type       IN   VARCHAR2  Required
--   p_as_of_date        IN   DATE      Required

--  Get_Configuration OUT NOCOPY Parameters:
--   x_config_tbl        OUT NOCOPY  Config_Tbl_Type
--   x_config_tbl_count	OUT NOCOPY	NUMBER
--
--  Version   :     Current version     1.0
--                  Initial version     1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Get_Configuration
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count			OUT  NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_config_type			IN	VARCHAR2	DEFAULT NULL,
	p_as_of_date			IN	DATE	DEFAULT SYSDATE,
	x_config_tbl			OUT NOCOPY	Config_Tbl_Type,
	x_config_tbl_count		OUT NOCOPY	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Get_ProductInfo
--  Type       : Public
--  Function   : This API passes back all information abOUT NOCOPY a product in the
--               installed base
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Get_ProductInfo IN Parameters:
--  p_cp_id			IN	NUMBER   Required
--  p_as_of_date		IN	DATE     Optional default = sysdate.

--  Get_ProductInfo OUT NOCOPY Parameters:
--  x_cp_rec			OUT NOCOPY	CP_Prod_Rec_Type
--  x_ship_rec			OUT NOCOPY	CP_Ship_Rec_Type
--  x_created_manually_flag	OUT NOCOPY	VARCJAR2(1);
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Get_ProductInfo
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_as_of_date			IN	DATE		DEFAULT sysdate,
	x_cp_rec				OUT NOCOPY	CP_Prod_Rec_Type,
	x_ship_rec			OUT NOCOPY	CP_Ship_Rec_Type,
	x_created_manually_flag	OUT NOCOPY	VARCHAR2
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Split_Product
--  Type       : Public
--  Function   : This overloaded API splits a product in the Installed Base into
--               two.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Split_Product IN Parameters:
--  p_cp_id			IN	NUMBER   Required
--  p_qty1               IN   NUMBER   Required
--  p_qty2               IN   NUMBER   Required
--  p_reason_code        IN   NUMBER   Required

--  Split_Product OUT NOCOPY Parameters:
--  x_new_parent_cp_id   OUT NOCOPY  NUMBER
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Split_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_qty1				IN	NUMBER,
	p_qty2				IN	NUMBER,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_reason_code			IN	VARCHAR2,
	x_new_parent_cp_id		OUT NOCOPY	NUMBER
) ;


--------------------------------------------------------------------------

-- Start of comments
--  API name   : Split_Product
--  Type       : Public
--  Function   : This overloaded API splits a product in the Installed Base into
--               one each.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY Parameters:
--   x_return_status     OUT NOCOPY  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY  NUMBER
--   x_msg_data          OUT NOCOPY  VARCHAR2(2000)
--
--  Split_Product IN Parameters:
--  p_cp_id			IN	NUMBER   Required
--  p_reason_code        IN   NUMBER   Required

--  Split_Product OUT NOCOPY Parameters:
--  None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Split_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_reason_code			IN	VARCHAR2,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM
);


PROCEDURE Create_Product_Parameters
(
	p_api_version		IN      NUMBER,
	p_init_msg_list     IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status     OUT NOCOPY     VARCHAR2,
	x_msg_count         OUT NOCOPY     NUMBER,
	x_msg_data          OUT NOCOPY     VARCHAR2,
	p_cp_param_rec      IN      CP_Param_Rec_Type,
	x_cp_parameter_id   OUT NOCOPY     NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);


PROCEDURE Update_Product_Parameters
(
	p_api_version			IN      NUMBER,
	p_init_msg_list		IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY     VARCHAR2,
	x_msg_count			OUT NOCOPY     NUMBER,
	x_msg_data			OUT NOCOPY     VARCHAR2,
	p_cp_parameter_id		IN      NUMBER,
	p_object_version_number	IN	   NUMBER,
	p_cp_param_rec			IN      CP_Param_Rec_Type,
	x_object_version_number	OUT NOCOPY	   NUMBER
);


PROCEDURE Delete_Product_Parameters
(
	p_api_version		IN      NUMBER,
	p_init_msg_list     IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status     OUT NOCOPY     VARCHAR2,
	x_msg_count         OUT NOCOPY     NUMBER,
	x_msg_data          OUT NOCOPY     VARCHAR2,
	p_cp_parameter_id   IN      NUMBER
);

END CS_InstalledBase_PUB;

 

/
