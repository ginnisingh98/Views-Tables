--------------------------------------------------------
--  DDL for Package Body BIS_CORRECTIVE_ACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CORRECTIVE_ACTION_PUB" AS
/* $Header: BISPCACB.pls 115.14 2002/12/16 10:22:54 rchandra ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPCACB.pls                                                      |
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
G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_CORRECTIVE_ACTION_PUB';

--
-- Procedures
--

-- Starts the corrective action workflow
--
Procedure Start_Corrective_Action
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
)
IS
BEGIN

  BIS_CORRECTIVE_ACTION_PVT.Start_Corrective_Action
  ( p_measure_instance      => p_measure_instance
  , p_dim_level_value_tbl   => p_dim_level_value_tbl
  , p_comparison_result     => p_comparison_result
  );

END Start_Corrective_Action;


-- Sends the Alert notification
--
Procedure Send_Alert
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
)
IS

BEGIN

  BIS_CORRECTIVE_ACTION_PVT.Send_Alert
  ( p_measure_instance      => p_measure_instance
  , p_dim_level_value_tbl   => p_dim_level_value_tbl
  , p_comparison_result     => p_comparison_result
  );

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Start_Corrective_Action'
      );
      RETURN;

END Send_Alert;

--
-- p_notify_set is for enhencements #1270297, 1270301
-- p_message_type is for enhencement #1270318
-- p_delivery_method is for future enhencement
--
Procedure Start_Corrective_Action
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_message_type          IN VARCHAR2
, p_Delivery_Method       IN VARCHAR2
, p_Recipient_tbl	  IN Recipient_Tbl_Type
, p_notify_set	          IN VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

BEGIN

  null;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'. Start_Corrective_Action'
      );
      RETURN;

END  Start_Corrective_Action;

END BIS_CORRECTIVE_ACTION_PUB;

/
