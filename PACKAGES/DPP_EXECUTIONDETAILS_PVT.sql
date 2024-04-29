--------------------------------------------------------
--  DDL for Package DPP_EXECUTIONDETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_EXECUTIONDETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvexes.pls 120.3 2008/04/03 10:30:50 sdasan noship $ */

  TYPE DPP_EXE_UPDATE_REC_TYPE IS RECORD(TRANSACTION_HEADER_ID NUMBER,
                                          ORG_ID NUMBER,
                                          EXECUTION_DETAIL_ID NUMBER,
                                          OUTPUT_XML CLOB,
                                          EXECUTION_STATUS VARCHAR2(10),
                                          EXECUTION_END_DATE DATE,
                                          PROVIDER_PROCESS_ID VARCHAR2(240),
                                          PROVIDER_PROCESS_INSTANCE_ID VARCHAR2(240),
                                          LAST_UPDATED_BY NUMBER,
                                          LAST_UPDATE_LOGIN NUMBER);

  G_DPP_EXE_UPDATE_REC  DPP_EXE_UPDATE_REC_TYPE;

  TYPE DPP_STATUS_UPDATE_REC_TYPE IS RECORD(TRANSACTION_LINE_ID NUMBER,
                                             UPDATE_STATUS VARCHAR2(30));

  G_DPP_STATUS_UPDATE_REC  DPP_STATUS_UPDATE_REC_TYPE;

  TYPE DPP_STATUS_UPDATE_TBL_TYPE IS TABLE OF DPP_STATUS_UPDATE_REC_TYPE INDEX BY BINARY_INTEGER ;

  G_DPP_STATUS_UPDATE_TBL  DPP_STATUS_UPDATE_TBL_TYPE;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_ExecutionDetails
--
-- PURPOSE
--    Update Execution Details
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_ExecutionDetails(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_EXE_UPDATE_rec	 IN OUT NOCOPY    DPP_EXE_UPDATE_REC_TYPE
   ,p_status_Update_tbl	 IN OUT NOCOPY    dpp_status_Update_tbl_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_ESB_InstanceID
--
-- PURPOSE
--    Update ESB Instance ID
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_ESB_InstanceID(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	   IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	   OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	       OUT 	NOCOPY  NUMBER
   ,x_msg_data	       OUT 	NOCOPY  VARCHAR2
   ,p_execution_detail_id	 IN NUMBER
   ,p_esb_instance_id		   IN VARCHAR2
);

END DPP_ExecutionDetails_PVT;

/
