--------------------------------------------------------
--  DDL for Package DPP_COVEREDINVENTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_COVEREDINVENTORY_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvcovs.pls 120.0 2007/11/28 10:13:33 sdasan noship $ */
/* Contains Procedures - Select Covered Inventory from INV, Populate Covered Inventory in DPP */
DPP_DEBUG_HIGH_ON   CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
DPP_DEBUG_LOW_ON    CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
DPP_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

TYPE dpp_inv_hdr_rec_type IS RECORD
(
    Transaction_Header_ID        NUMBER,
    Effective_Start_Date		 DATE,
    Effective_End_Date			 DATE,
    Org_ID                       NUMBER,
    Execution_Detail_ID			 NUMBER,
    Output_XML	                 CLOB,
	Provider_Process_Id          VARCHAR2(240),
	Provider_Process_Instance_id VARCHAR2(240),
	Last_Updated_By              NUMBER
);

TYPE dpp_inv_cov_rec_type IS RECORD
(
    Transaction_Line_Id			NUMBER,
    Inventory_ITem_ID           NUMBER,
    UOM_Code                    VARCHAR2(3),
    Onhand_Quantity             NUMBER,
    Covered_quantity	        NUMBER,
    wh_line_tbl                 DPP_COVEREDINVENTORY_PVT.dpp_inv_cov_wh_tbl_type
);

G_MISS_dpp_inv_cov_rec     dpp_inv_cov_rec_type;
TYPE dpp_inv_cov_tbl_type IS TABLE OF dpp_inv_cov_rec_type INDEX BY BINARY_INTEGER;
G_MISS_dpp_inv_cov_tbl     dpp_inv_cov_tbl_type;


TYPE dpp_inv_cov_wh_rec_type IS RECORD
(
    Warehouse_id			NUMBER,
    Warehouse_Name          VARCHAR2(240),
    Covered_quantity        NUMBER,
    rct_line_tbl            DPP_COVEREDINVENTORY_PVT.dpp_inv_cov_rct_tbl_type
);

G_MISS_dpp_inv_cov_wh_rec     dpp_inv_cov_wh_rec_type;
TYPE dpp_inv_cov_wh_tbl_type IS TABLE OF dpp_inv_cov_wh_rec_type INDEX BY BINARY_INTEGER;
G_MISS_dpp_inv_cov_wh_tbl     dpp_inv_cov_wh_tbl_type;


TYPE dpp_inv_cov_rct_rec_type IS RECORD
(
    Date_Received           DATE,
    Onhand_quantity	        NUMBER
);

G_MISS_dpp_inv_cov_rct_rec     dpp_inv_cov_rct_rec_type;
TYPE dpp_inv_cov_rct_tbl_type IS TABLE OF dpp_inv_cov_rct_rec_type INDEX BY BINARY_INTEGER;
G_MISS_dpp_inv_cov_rct_tbl     dpp_inv_cov_rct_tbl_type;

---------------------------------------------------------------------
-- PROCEDURE
--    Select_CoveredInventory
--
-- PURPOSE
--    Select Covered Inventory
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Select_CoveredInventory(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_inv_hdr_rec	     IN   dpp_inv_hdr_rec_type
   ,p_covered_inv_tbl	 IN OUT NOCOPY  dpp_inv_cov_tbl_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Populate_CoveredInventory
--
-- PURPOSE
--    Populate Covered Inventory
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Populate_CoveredInventory(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT NOCOPY	  VARCHAR2
   ,p_inv_hdr_rec	     IN    dpp_inv_hdr_rec_type
   ,p_covered_inv_tbl	 IN    dpp_inv_cov_tbl_type
);

PROCEDURE Update_CoveredInventory(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_inv_hdr_rec	     IN    dpp_inv_hdr_rec_type
   ,p_covered_inv_tbl	 IN    dpp_inv_cov_tbl_type
);

END DPP_COVEREDINVENTORY_PVT;

/
