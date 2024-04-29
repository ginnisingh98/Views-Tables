--------------------------------------------------------
--  DDL for Package DPP_PURCHASEPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_PURCHASEPRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvpops.pls 120.3.12010000.3 2009/08/25 14:56:23 rvkondur ship $ */

TYPE dpp_txn_hdr_rec_type IS RECORD
(
    Transaction_Header_ID   NUMBER,
    Transaction_Number			VARCHAR2(40),
    Org_ID                  NUMBER,
    Vendor_ID               NUMBER,
    Execution_Detail_ID     NUMBER,
    Provider_Process_Id     VARCHAR2(240),
    Provider_Process_Instance_id VARCHAR2(240),
    Last_Updated_By         NUMBER,
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
g_miss_dpp_item_price_rec          dpp_txn_hdr_rec_type;
TYPE  dpp_item_price_tbl_type      IS TABLE OF dpp_txn_hdr_rec_type INDEX BY BINARY_INTEGER;
g_miss_dpp_item_price_tbl          dpp_item_price_tbl_type;

TYPE dpp_item_cost_rec_type IS RECORD
(
    Transaction_Line_Id			NUMBER,
    Inventory_Item_Id       NUMBER,
    Item_Number							VARCHAR2(240),
    New_Price               NUMBER,
    Currency                VARCHAR2(15),
    UOM                     VARCHAR2(15),
    po_line_tbl             DPP_PURCHASEPRICE_PVT.dpp_po_line_tbl_type,
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
    Update_Status           VARCHAR2(30)
);
G_MISS_DPP_ITEM_COST_REC    dpp_item_cost_rec_type;
TYPE  dpp_item_cost_tbl_type      IS TABLE OF dpp_item_cost_rec_type INDEX BY BINARY_INTEGER;
g_miss_dpp_item_cost_tbl          dpp_item_cost_tbl_type;


TYPE dpp_po_line_rec_type IS RECORD
(
    Document_Number	    VARCHAR2(30),
    Document_Type           VARCHAR2(30),
    Line_Number             NUMBER,
    Reason_for_failure      VARCHAR2(150)
);
G_MISS_DPP_PO_LINE_REC     dpp_po_line_rec_type;
TYPE dpp_po_line_tbl_type IS TABLE OF dpp_po_line_rec_type INDEX BY BINARY_INTEGER;
G_MISS_DPP_PO_LINE_TBL     dpp_po_line_tbl_type;


TYPE dpp_po_notify_rec_type IS RECORD
(
    Org_ID                  NUMBER,
    Vendor_ID               NUMBER,
    Vendor_Site_ID	    NUMBER,
    Vendor_Number           VARCHAR2(40),
    Vendor_Name		    VARCHAR2(240),
    Vendor_Site_Code        VARCHAR2(15),
    Operating_Unit	    VARCHAR2(240)
);

g_dpp_po_notify_rec          dpp_po_notify_rec_type;

TYPE dpp_po_details_rec_type IS RECORD
(
    Document_Number	    VARCHAR2(150),
    Document_Type	    VARCHAR2(20),
    PO_Line_NUmber	    NUMBER,
    Authorization_Status    VARCHAR2(25)
);

g_dpp_po_details_rec          dpp_po_details_rec_type;
TYPE  dpp_po_details_tbl_type      IS TABLE OF dpp_po_details_rec_type INDEX BY BINARY_INTEGER;
g_dpp_po_details_tbl          dpp_po_details_tbl_type;

TYPE dpp_po_notify_item_rec_type IS RECORD
(
    Inventory_Item_ID       NUMBER,
    Item_Number	            VARCHAR2(240),
    New_Price		    NUMBER,
    Currency		    VARCHAR2(15),
  po_details_tbl	    DPP_PURCHASEPRICE_PVT.dpp_po_details_tbl_type
);

g_dpp_po_notify_item_rec          dpp_po_notify_item_rec_type;
TYPE  dpp_po_notify_item_tbl_type      IS TABLE OF dpp_po_notify_item_rec_type INDEX BY BINARY_INTEGER;
g_dpp_po_notify_item_tbl          dpp_po_notify_item_tbl_type;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_PurchasePrice
--
-- PURPOSE
--    Update purchase price.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_PurchasePrice(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT NOCOPY	  VARCHAR2
   ,p_item_price_rec	 IN    dpp_txn_hdr_rec_type
   ,p_item_cost_tbl	     IN    dpp_item_cost_tbl_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Notify_PO
--
-- PURPOSE
--    Notify_Partial Receipts
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Notify_PO(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT NOCOPY	  VARCHAR2
   ,p_po_notify_hdr_rec	 IN OUT NOCOPY  dpp_po_notify_rec_type
   ,p_po_notify_item_tbl	     IN OUT  NOCOPY dpp_po_notify_item_tbl_type
);


END DPP_PURCHASEPRICE_PVT;


/
