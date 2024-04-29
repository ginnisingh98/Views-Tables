--------------------------------------------------------
--  DDL for Package DPP_ITEMCOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_ITEMCOST_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvcsts.pls 120.2.12010000.3 2009/08/25 14:52:48 rvkondur ship $ */

TYPE dpp_cst_hdr_rec_type IS RECORD
(
    Transaction_Header_ID   NUMBER,
    Transaction_Number			VARCHAR2(40),
    Org_ID                  NUMBER,
    Execution_Detail_ID         NUMBER,
		Provider_Process_Id         VARCHAR2(240),
	  Provider_Process_Instance_id VARCHAR2(240),
    Last_Updated_By              NUMBER,
    Cost_Adjustment_Account		NUMBER,
    Attribute_Category      VARCHAR2(30),
    Attribute1              VARCHAR2(150),
    Attribute2              VARCHAR2(150),
    Attribute3              VARCHAR2(150),
    Attribute4              VARCHAR2(150),
    Attribute5              VARCHAR2(150),
    Attribute6              VARCHAR2(150),
    Attribute7              VARCHAR2(150),
    Attribute8              VARCHAR2(150),
    Attribute9              VARCHAR2(150),
    Attribute10             VARCHAR2(150),
    Attribute11             VARCHAR2(150),
    Attribute12             VARCHAR2(150),
    Attribute13             VARCHAR2(150),
    Attribute14             VARCHAR2(150),
    Attribute15             VARCHAR2(150)
);

TYPE dpp_txn_line_rec_type IS RECORD
(
	  Transaction_Line_ID     NUMBER,
    Inventory_Item_Id       NUMBER,
    Item_Number				VARCHAR2(240),
    New_Price               NUMBER,
    Currency                VARCHAR2(30),
    UOM                     VARCHAR2(30),
    price_change						NUMBER,
    Attribute_Category      VARCHAR2(30),
    Attribute1              VARCHAR2(150),
    Attribute2              VARCHAR2(150),
    Attribute3              VARCHAR2(150),
    Attribute4              VARCHAR2(150),
    Attribute5              VARCHAR2(150),
    Attribute6              VARCHAR2(150),
    Attribute7              VARCHAR2(150),
    Attribute8              VARCHAR2(150),
    Attribute9              VARCHAR2(150),
    Attribute10             VARCHAR2(150),
    Attribute11             VARCHAR2(150),
    Attribute12             VARCHAR2(150),
    Attribute13             VARCHAR2(150),
    Attribute14             VARCHAR2(150),
    Attribute15             VARCHAR2(150),
    Update_Status           VARCHAR2(30),
    Reason_For_Failure		VARCHAR2(240),
    inv_org_details_tbl		DPP_ITEMCOST_PVT.inv_org_details_tbl_type
);
G_dpp_txn_line_rec    dpp_txn_line_rec_type;
TYPE  dpp_txn_line_tbl_type      IS TABLE OF dpp_txn_line_rec_type INDEX BY BINARY_INTEGER;
g_dpp_txn_line_tbl          dpp_txn_line_tbl_type;

TYPE inv_org_details_rec_type IS RECORD
(
    Inventory_Org_Name				VARCHAR2(240),
    Prior_Cost								NUMBER
);

TYPE  inv_org_details_tbl_type      IS TABLE OF inv_org_details_rec_type INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_ItemCost
--
-- PURPOSE
--    Update item cost.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_ItemCost(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_txn_hdr_rec	     IN    dpp_cst_hdr_rec_type
   ,p_item_cost_tbl	   IN    dpp_txn_line_tbl_type
);

END DPP_ITEMCOST_PVT;

/
