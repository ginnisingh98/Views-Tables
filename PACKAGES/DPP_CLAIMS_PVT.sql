--------------------------------------------------------
--  DDL for Package DPP_CLAIMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_CLAIMS_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvclas.pls 120.2 2007/12/04 08:54:15 sdasan noship $ */

TYPE dpp_txn_hdr_rec_type IS RECORD
(
    Transaction_Header_ID   NUMBER,
    Transaction_number      VARCHAR2(240),
    Org_ID                  NUMBER,
    Vendor_ID   NUMBER,
    Vendor_site_ID          NUMBER,
    claim_ID		    NUMBER,
    claim_status_code 	    VARCHAR2(30),
    claim_amount            NUMBER,
    currency_code	    VARCHAR2(15),
    claim_type_flag         VARCHAR2(30),
    Execution_Detail_ID         NUMBER,
    Provider_Process_Id         VARCHAR2(240),
    Provider_Process_Instance_id VARCHAR2(240),
    Last_Updated_By         NUMBER,
    Last_Update_Date        DATE,
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
    Item_Number		    VARCHAR2(40),
    cust_account_id         NUMBER,
    Claim_Line_Amount       NUMBER,
    Currency                VARCHAR2(30),
    Claim_Quantity	    NUMBER,
    UOM                     VARCHAR2(30),
    claim_ID		    NUMBER,
    claim_status_code 	    VARCHAR2(30),
    claim_amount            NUMBER,
    Last_Updated_By         NUMBER,
    Last_Update_Date        DATE,
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
    Reason_For_Failure	    VARCHAR2(240)
);

G_dpp_txn_line_rec    dpp_txn_line_rec_type;
TYPE  dpp_txn_line_tbl_type      IS TABLE OF dpp_txn_line_rec_type INDEX BY BINARY_INTEGER;
g_dpp_txn_line_tbl          dpp_txn_line_tbl_type;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claims
--
-- PURPOSE
--    Create Claims
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Create_Claims(
    p_api_version   	     IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	             IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	     IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	             OUT NOCOPY	  NUMBER
   ,x_msg_data	             OUT NOCOPY	  VARCHAR2
   ,p_txn_hdr_rec	     IN           dpp_txn_hdr_rec_type
   ,p_txn_line_tbl	     IN           dpp_txn_line_tbl_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claims
--
-- PURPOSE
--    Update Claims
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_Claims(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT NOCOPY	  VARCHAR2
   ,p_txn_hdr_rec	 IN OUT  NOCOPY dpp_txn_hdr_rec_type
   ,p_txn_line_tbl	     IN OUT NOCOPY  dpp_txn_line_tbl_type
);

END DPP_CLAIMS_PVT;

/
