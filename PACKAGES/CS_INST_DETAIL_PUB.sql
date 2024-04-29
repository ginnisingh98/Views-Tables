--------------------------------------------------------
--  DDL for Package CS_INST_DETAIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INST_DETAIL_PUB" AUTHID CURRENT_USER AS
/* $Header: cspinsds.pls 120.1 2006/03/27 16:12:50 epajaril noship $ */

-- ---------------------------------------------------------
-- Declare Data Types
-- ---------------------------------------------------------
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
	expected_installation_date    DATE			DEFAULT FND_API.G_MISS_DATE,
	start_date_active             DATE			DEFAULT FND_API.G_MISS_DATE,
	end_date_active               DATE			DEFAULT FND_API.G_MISS_DATE,
     rcv_transaction_id            NUMBER		DEFAULT FND_API.G_MISS_NUM -- Added shegde
	--desc_flex                     DFF_Rec_Type
);

TYPE Line_Inst_Dtl_Tbl_Type is TABLE OF Line_Inst_Dtl_Rec_Type
INDEX BY BINARY_INTEGER;


TYPE Rma_Rcpt_Rec_Type IS RECORD
(
	line_inst_detail_id           NUMBER		DEFAULT FND_API.G_MISS_NUM,
	quantity                      NUMBER		DEFAULT FND_API.G_MISS_NUM,
	rcv_transaction_id            NUMBER		DEFAULT FND_API.G_MISS_NUM
);

TYPE Rma_Rcpt_Tbl_Type is TABLE OF Rma_Rcpt_Rec_Type
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------
PROCEDURE Get_Line_Inst_Details
(
	p_api_version				IN	NUMBER,
	p_init_msg_list     		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status     		OUT NOCOPY	VARCHAR2,
	x_msg_count         		OUT NOCOPY	NUMBER,
	x_msg_data          		OUT NOCOPY	VARCHAR2,
	p_line_inst_detail_id		IN	NUMBER,
	x_line_inst_dtl_rec			OUT NOCOPY	Line_Inst_Dtl_Rec_Type,
	x_line_inst_dtl_desc_flex	OUT NOCOPY	CS_InstalledBase_PUB.DFF_Rec_Type
);

/* Over Loaded Procedure Specifications */

PROCEDURE Get_Line_Inst_Details
(
	p_api_version				IN	NUMBER,
	p_init_msg_list     		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status     		OUT NOCOPY	VARCHAR2,
	x_msg_count         		OUT NOCOPY	NUMBER,
	x_msg_data          		OUT NOCOPY	VARCHAR2,
	p_order_line_id			IN	NUMBER,
	x_line_inst_dtl_tbl			OUT NOCOPY	Line_Inst_Dtl_Tbl_Type,
	x_line_inst_dtl_tbl_count	OUT NOCOPY	NUMBER
);

/* Added for RMA Returns Bug 1500577 shegde */

PROCEDURE Get_rma_line_Inst_Details
(
	p_api_version				IN	NUMBER,
	p_init_msg_list     		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit            		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status     		OUT NOCOPY	VARCHAR2,
	x_msg_count         		OUT NOCOPY	NUMBER,
	x_msg_data          		OUT NOCOPY	VARCHAR2,
	p_rma_only            		IN	VARCHAR2  DEFAULT FND_API.G_TRUE,
	p_order_line_id			IN	NUMBER,
	x_line_inst_dtl_tbl			OUT NOCOPY	CS_INST_DETAIL_PUB.Line_Inst_Dtl_Tbl_Type,
	x_line_inst_dtl_tbl_count	OUT NOCOPY	NUMBER
);



--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- Start of comments
--  API name   : Create_Installation_Details
--  Type       : Public
--  Function   : This API is used to create Installation details records.
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
--  Create_Installation_Details IN Parameters:
--  p_line_inst_dtl_rec       Line_Inst_Dtl_Rec_Type   Required
--  p_line_inst_dtl_desc_flex DFF_Rec_Type

--  Create_Installation_Details OUT NOCOPY Parameters:
--  x_line_inst_detail_id        NUMBER
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Create_Installation_Details
(
	p_api_version           		IN	NUMBER,
	p_init_msg_list         		IN	VARCHAR2   DEFAULT FND_API.G_FALSE,
	p_commit                		IN	VARCHAR2   DEFAULT FND_API.G_FALSE,
	x_return_status         		OUT NOCOPY	VARCHAR2,
	x_msg_count             		OUT NOCOPY	NUMBER,
	x_msg_data              		OUT NOCOPY	VARCHAR2,
	p_line_inst_dtl_rec     		IN	Line_Inst_Dtl_Rec_Type,
	p_line_inst_dtl_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
    p_upgrade                       IN VARCHAR2   DEFAULT FND_API.G_FALSE,
	x_line_inst_detail_id   		OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER -- was commented
);


--------------------------------------------------------------------------

-- Start of comments
--  API name   : Update_Installation_Details
--  Type       : Public
--  Function   : This API is used to update Installation details records.
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
--  Update_Installation_Details IN Parameters:
--  p_line_inst_dtl_rec       Line_Inst_Dtl_Rec_Type   Required
--  p_line_inst_dtl_desc_flex DFF_Rec_Type

--  Update_Installation_Details OUT NOCOPY Parameters:
--  None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Update_Installation_Details
(
	p_api_version           		IN	NUMBER,
	p_init_msg_list         		IN	VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                		IN	VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status        		OUT NOCOPY	VARCHAR2,
	x_msg_count             		OUT NOCOPY	NUMBER,
	x_msg_data              		OUT NOCOPY	VARCHAR2,
	p_line_inst_dtl_rec     		IN	Line_Inst_Dtl_Rec_Type,
	p_line_inst_dtl_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	p_object_version_number		IN	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER -- was commented
);


--------------------------------------------------------------------------

-- Start of comments
--  API name   : Delete_Installation_Details
--  Type       : Public
--  Function   : This API is used to delete Installation details records.
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
--  Delete_Installation_Details IN Parameters:
--  p_line_inst_detail_id        NUMBER                   Required

--  Delete_Installation_Details OUT NOCOPY Parameters:
--  None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Delete_Installation_Details
(
	p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY     VARCHAR2,
	x_msg_count             OUT NOCOPY     NUMBER,
	x_msg_data              OUT NOCOPY     VARCHAR2,
	p_line_inst_detail_id   IN      NUMBER--,
--	p_object_version_number IN	  NUMBER
);

/* Added this Procedure for RMA Returns Bug 1500577 shegde */

PROCEDURE Update_Inst_Details_RMA_Rcpt
(
	p_api_version           		IN	NUMBER,
	p_init_msg_list         		IN	VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                		IN	VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status        		    OUT NOCOPY	VARCHAR2,
	x_msg_count             		OUT NOCOPY	NUMBER,
	x_msg_data              		OUT NOCOPY	VARCHAR2,
	p_rcpt_tbl                	    IN	RMA_RCPT_TBL_TYPE,
	p_rcpt_tbl_count             	IN	NUMBER,
	p_order_line_id           	    IN	NUMBER,
	p_cp_id                   		IN	NUMBER,
	p_serial_flag              		IN	VARCHAR2,
	p_object_version_number	        IN	NUMBER,
	x_object_version_number	        OUT NOCOPY	NUMBER
) ;

END CS_Inst_Detail_PUB;

 

/
