--------------------------------------------------------
--  DDL for Package BSC_PERIODICITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PERIODICITY_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVPITS.pls 120.0 2005/07/21 23:36:54 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCVPCTS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private package for populating the calendar tables        |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna Created.                                          |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):=  'BSC_PERIODICITY_PVT';

PROCEDURE Create_Periods
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Periods
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Periods
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
);

END BSC_PERIODICITY_PVT;

 

/
