--------------------------------------------------------
--  DDL for Package BSC_CALENDAR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CALENDAR_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVCALS.pls 120.1 2005/11/30 02:47:10 kyadamak noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCVCALS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private package for populating the calendar tables        |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna Created.                                          |
REM | 29-NOV-2005 Krishna Modified for enh#4711274                          |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):=  'BSC_CALENDAR_PVT';

PROCEDURE Create_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Fiscal_Change
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Id            IN          NUMBER
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_PeriodNames_In_Calendar
( p_Calendar_Id            IN  NUMBER
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

END BSC_CALENDAR_PVT;

 

/
