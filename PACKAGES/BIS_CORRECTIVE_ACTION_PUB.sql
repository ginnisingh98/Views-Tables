--------------------------------------------------------
--  DDL for Package BIS_CORRECTIVE_ACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CORRECTIVE_ACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPCACS.pls 115.15 2002/12/31 21:45:54 sashaik ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPCACS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for the Corrective Action
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation
REM +=======================================================================+
*/
--
-- Constants
--
G_BIS_GEN_WORKFLOW_ITEM_TYPE CONSTANT VARCHAR2(100) := 'BISBISWF';
G_BIS_GEN_WORKFLOW_PROCESS CONSTANT VARCHAR2(100) := 'BIS_SEND_NOTIFICATION';
G_BIS_ALR_WORKFLOW_PROCESS CONSTANT VARCHAR2(100) := 'BIS_ALERT_NOTIFICATION';

G_MSG_TYPE_REGULAR          CONSTANT VARCHAR2(100) := 'REGULAR';
G_MSG_TYPE_EXCEPTION_RANGE1 CONSTANT VARCHAR2(100) := 'ERROR_RANGE1';
G_MSG_TYPE_EXCEPTION_RANGE2 CONSTANT VARCHAR2(100) := 'ERROR_RANGE2';
G_MSG_TYPE_EXCEPTION_RANGE3 CONSTANT VARCHAR2(100) := 'ERROR_RANGE3';

G_DELIVERY_METHOD_WORKFLOW  CONSTANT VARCHAR2(30)  := 'WORKFLOW';
/*
-- for future enhencements
G_DELIVERY_METHOD_MOBIL  CONSTANT VARCHAR2(30)  := 'MOBIL';
G_DELIVERY_METHOD_EMAIL  CONSTANT VARCHAR2(30)  := 'EMAIL';
*/

--
-- Type: Records
--


-- Recipient must be workflow role
-- 2729637: Taking out reference to wf_roles as it is causing
--   ORA-28112: failed to execute policy function
--   while applying patch.
TYPE Recipient_Rec_Type IS RECORD (      -- 2729637
  Recipient_name           VARCHAR2(320) -- WF_ROLES.name%TYPE
, Recipient_display_name   VARCHAR2(360) -- WF_ROLES.display_name%TYPE
, Notification_Preference  VARCHAR2(240) -- WF_ROLES.notification_preference%TYPE
, ORIG_SYSTEM              VARCHAR2(30)  -- WF_ROLES.orig_system%TYPE
, ORIG_SYSTEM_ID           NUMBER        -- WF_ROLES.orig_system_id%TYPE
);


--
-- Type: Tables
--
TYPE Recipient_Tbl_Type IS TABLE OF Recipient_Rec_Type
INDEX BY BINARY_INTEGER;

G_MISS_RECIPIENT_TBL  Recipient_Tbl_Type;

--
-- Procedures
--

-- Starts the corrective action workflow
--
Procedure Start_Corrective_Action
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
);

-- Sends the Alert notification
--
Procedure Send_Alert
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
);

END BIS_CORRECTIVE_ACTION_PUB;

 

/
