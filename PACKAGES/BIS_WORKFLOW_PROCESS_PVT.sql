--------------------------------------------------------
--  DDL for Package BIS_WORKFLOW_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_WORKFLOW_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVWFPS.pls 115.3 99/09/19 11:20:53 porting ship  $ */

-- Data Types: Records

TYPE WORKFLOW_PROCESS_Rec_Type IS RECORD (
  Item_Type              VARCHAR2(8) ,
  Process_Short_Name     VARCHAR2(30),
  Process_Name           VARCHAR2(80));

TYPE WORKFLOW_PROCESS_Tbl_Type IS TABLE of WORKFLOW_PROCESS_Rec_Type
        INDEX BY BINARY_INTEGER;

TYPE WORKFLOW_Rec_Type IS RECORD (
  Item_Type              VARCHAR2(8) ,
  Display_Name           VARCHAR2(80));

TYPE WORKFLOW_Tbl_Type IS TABLE of WORKFLOW_Rec_Type
        INDEX BY BINARY_INTEGER;

PROCEDURE Retrieve_WorkFlows
( p_api_version   IN  number
, x_WORKFLOW_Tbl  out WORKFLOW_Tbl_Type
, x_return_status OUT VARCHAR2
, x_error_tbl     OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Retrieve_WorkFlow_Processes
( p_api_version          IN  number
, x_WORKFLOW_PROCESS_Tbl out WORKFLOW_PROCESS_Tbl_Type
, x_return_status        OUT VARCHAR2
, x_error_tbl            OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Retrieve_WF_Process_Name
( p_api_version          IN  number
, p_wf_process_short_name IN  VARCHAR2
, x_wf_process_name       OUT VARCHAR2
, x_return_status         OUT VARCHAR2
, x_error_tbl             OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_WF_Process_Short_Name
( p_api_version           IN  NUMBER
, p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_wf_process_short_name IN  VARCHAR2
, x_return_status         OUT VARCHAR2
, x_error_Tbl             OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN NUMBER
, p_wf_process_Name            IN VARCHAR2
, x_wf_process_short_name      OUT VARCHAR2
, x_return_status              OUT VARCHAR2
, x_error_Tbl                  OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
END BIS_WORKFLOW_PROCESS_PVT;

 

/
