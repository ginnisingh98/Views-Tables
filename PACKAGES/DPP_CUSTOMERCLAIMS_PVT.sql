--------------------------------------------------------
--  DDL for Package DPP_CUSTOMERCLAIMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_CUSTOMERCLAIMS_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvcuss.pls 120.3 2008/02/08 05:00:23 sdasan noship $ */

TYPE dpp_cust_hdr_rec_type IS RECORD
(
    Transaction_Header_ID   	NUMBER,
    Effective_Start_Date			DATE,
    Effective_End_Date				DATE,
    Org_ID                  	VARCHAR2(15),
    Execution_Detail_ID				NUMBER,
    Output_XML								CLOB,
		Provider_Process_Id 			VARCHAR2(240),
		Provider_Process_Instance_id VARCHAR2(240),
		Last_Updated_By 					NUMBER,
    Currency_code							VARCHAR2(15)
);

TYPE dpp_customer_price_rec_type IS RECORD
(
cust_account_id				NUMBER,
last_price						NUMBER,
invoice_currency_code	VARCHAR2(15)
);

TYPE dpp_customer_price_tbl_type IS TABLE OF dpp_customer_price_rec_type INDEX BY BINARY_INTEGER;

TYPE dpp_customer_rec_type IS RECORD
(
    Transaction_Line_Id			NUMBER,
    Inventory_ITem_ID					VARCHAR2(42),
    UOM_Code									VARCHAR2(3),
    Customer_price_Tbl        dpp_customer_price_tbl_type
);

G_MISS_dpp_customer_rec     dpp_customer_rec_type;
TYPE dpp_customer_tbl_type IS TABLE OF dpp_customer_rec_type INDEX BY BINARY_INTEGER;
G_MISS_dpp_customer_tbl     dpp_customer_tbl_type;

---------------------------------------------------------------------
-- PROCEDURE
--    Select_CustomerPrice
--
-- PURPOSE
--    Select Customer and Price
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Select_CustomerPrice(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT NOCOPY	  VARCHAR2
   ,p_cust_hdr_rec	 IN    dpp_cust_hdr_rec_type
   ,p_customer_tbl	     IN OUT NOCOPY  dpp_customer_tbl_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Populate_CustomerPrice
--
-- PURPOSE
--    Populate Customer and Price
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Populate_CustomerPrice(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_TRUE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_cust_hdr_rec	 IN    dpp_cust_hdr_rec_type
   ,p_customer_tbl	     IN    dpp_customer_tbl_type
);

END DPP_CUSTOMERCLAIMS_PVT;

/
