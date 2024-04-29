--------------------------------------------------------
--  DDL for Package DPP_ERROR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_ERROR_PVT" AUTHID CURRENT_USER AS
/* $Header: dppverrs.pls 120.1 2007/12/13 12:21:13 sdasan noship $ */
TYPE DPP_ERROR_REC_TYPE IS RECORD
(
    Transaction_Header_ID       NUMBER,
    Org_ID                      NUMBER,
    Execution_Detail_ID         NUMBER,
    Output_XML	                CLOB, -- contains error details
    Provider_Process_Id         VARCHAR2(240),
	  Provider_Process_Instance_id VARCHAR2(240),
	  Last_Updated_By             NUMBER
);

TYPE dpp_lines_tbl_type IS TABLE OF DPP_TRANSACTION_LINES_ALL.TRANSACTION_LINE_ID%TYPE INDEX BY BINARY_INTEGER;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Error
--
-- PURPOSE
--    Update Error
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_Error(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY   NUMBER
   ,x_msg_data	         OUT 	NOCOPY   VARCHAR2
   ,p_exe_update_rec	 IN       DPP_ERROR_REC_TYPE
   ,p_lines_tbl	         IN       DPP_LINES_TBL_TYPE
);

END DPP_ERROR_PVT;

/
