--------------------------------------------------------
--  DDL for Package BSC_CALENDAR_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CALENDAR_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: BSCWCALS.pls 120.0 2005/07/21 23:36:57 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCWCALS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: This is Wrapper Packages which takes the Values from UI   |
REM |             and populates calendar record with these values           |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna Created.                                          |
REM | 29-JUN-2005 Aditya Rao added parameter p_Base_Per_Ids                 |
REM | 07-JUL-2005 Aditya Rao added Locking APIs                             |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):=  'BSC_CALENDAR_WRAPPER';

/***********************************************************************
     This function is called from JAVA UI Layer for creating calendar
     which populates the Calendar Record and calls create public API
/***********************************************************************/

PROCEDURE Create_Calendar_UI
( p_Api_Version           IN          NUMBER
, p_Commit                IN          VARCHAR2
, p_Calendar_Id           IN          NUMBER
, p_Edw_Flag              IN          NUMBER
, p_Edw_Calendar_Id       IN          NUMBER
, p_Edw_Calendar_Type_Id  IN          NUMBER
, p_Fiscal_Year           IN          NUMBER
, p_Fiscal_Change         IN          NUMBER
, p_Range_Yr_Mod          IN          NUMBER
, p_Current_Year          IN          NUMBER
, p_Start_Month           IN          NUMBER
, p_Start_Day             IN          NUMBER
, p_Name                  IN          VARCHAR2
, p_Help                  IN          VARCHAR2
, p_Dim_Short_Name        IN          VARCHAR2
, p_Application_Id        IN          NUMBER
, p_Base_Per_Ids          IN          VARCHAR2
, p_Created_By            IN          NUMBER
, p_Creation_Date         IN          DATE
, p_Last_Updated_By       IN          NUMBER
, p_Last_Update_Date      IN          DATE
, p_Last_Update_Login     IN          NUMBER
, x_Return_Status         OUT NOCOPY  VARCHAR2
, x_Msg_Count             OUT NOCOPY  NUMBER
, x_Msg_Data              OUT NOCOPY  VARCHAR2
);

/***********************************************************************
     This function is called from JAVA UI Layer for update calendar
     which populates the Calendar Record and calls update public API
/***********************************************************************/

PROCEDURE Update_Calendar_UI
( p_Api_Version           IN          NUMBER
, p_Commit                IN          VARCHAR2
, p_Calendar_Id           IN          NUMBER
, p_Edw_Flag              IN          NUMBER
, p_Edw_Calendar_Id       IN          NUMBER
, p_Edw_Calendar_Type_Id  IN          NUMBER
, p_Fiscal_Year           IN          NUMBER
, p_Fiscal_Change         IN          NUMBER
, p_Range_Yr_Mod          IN          NUMBER
, p_Current_Year          IN          NUMBER
, p_Start_Month           IN          NUMBER
, p_Start_Day             IN          NUMBER
, p_Name                  IN          VARCHAR2
, p_Help                  IN          VARCHAR2
, p_Dim_Short_Name        IN          VARCHAR2
, p_Application_Id        IN          NUMBER
, p_Time_Stamp            IN          VARCHAR2 := NULL
, p_Created_By            IN          NUMBER
, p_Creation_Date         IN          DATE
, p_Last_Updated_By       IN          NUMBER
, p_Last_Update_Date      IN          DATE
, p_Last_Update_Login     IN          NUMBER
, x_Return_Status         OUT NOCOPY  VARCHAR2
, x_Msg_Count             OUT NOCOPY  NUMBER
, x_Msg_Data              OUT NOCOPY  VARCHAR2
);

/***********************************************************************
     This function is called from JAVA UI Layer for Delete calendar
     which populates the Calendar Record and calls Delete public API
/***********************************************************************/

PROCEDURE Delete_Calendar_UI
( p_Api_Version           IN          NUMBER
, p_Commit                IN          VARCHAR2
, p_Calendar_Id           IN          NUMBER
, p_Time_Stamp            IN          VARCHAR2 := NULL
, x_Return_Status         OUT NOCOPY  VARCHAR2
, x_Msg_Count             OUT NOCOPY  NUMBER
, x_Msg_Data              OUT NOCOPY  VARCHAR2
);
/************************************************************************
   This function is used to check whether DBI Calendar is setup by BIA
************************************************************************/
FUNCTION Is_Dbi_Calendar_Enabled RETURN VARCHAR2;

END BSC_CALENDAR_WRAPPER;

 

/
