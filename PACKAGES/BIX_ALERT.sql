--------------------------------------------------------
--  DDL for Package BIX_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_ALERT" AUTHID CURRENT_USER AS
/* $Header: BIXPALRS.pls 115.5 2003/01/10 00:31:20 achanda ship $ */

PROCEDURE BIX_AVGANS_ALERT
( p_target_Level_Short_Name VARCHAR2
);
PROCEDURE BIX_SERLVL_ALERT
( p_target_Level_Short_Name VARCHAR2
);
PROCEDURE BIX_ABANDON_ALERT
( p_target_Level_Short_Name VARCHAR2
);
PROCEDURE BIX_OCCRATE_ALERT
( p_target_Level_Short_Name VARCHAR2
);
PROCEDURE BIX_AVGTALK_ALERT
( p_target_Level_Short_Name VARCHAR2
);
PROCEDURE BIX_AVGWAIT_ALERT
( p_target_Level_Short_Name VARCHAR2
);
PROCEDURE BIX_UTLRATE_ALERT
( p_target_Level_Short_Name VARCHAR2
);
PROCEDURE BIX_CALLSANS_ALERT
( p_target_Level_Short_Name VARCHAR2
);

FUNCTION Calculate_Actual
( p_Organization_ID   NUMBER
, p_period_set_Name   VARCHAR2
, p_time_period       VARCHAR2
)
RETURN NUMBER;
END BIX_ALERT;

 

/
