--------------------------------------------------------
--  DDL for Package BSC_PERIODICITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PERIODICITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVPERS.pls 120.0 2005/07/21 23:35:23 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCVPERS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: PRIVATE specification to manage periodicities             |
REM | NOTES                                                                 |
REM | 14-JUL-2005 Aditya Rao  Created.                                      |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODICITIES_PVT';

/*
Procedure Name
Parameters

*/

PROCEDURE Create_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);


PROCEDURE Retrieve_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Periodicities_Rec_Type  OUT NOCOPY  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);


PROCEDURE Update_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Structural_Flag         OUT NOCOPY  VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);


PROCEDURE Incr_Refresh_Objectives(
  p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

--PROCEDURE Delete_Periodicity
PROCEDURE Delete_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);


END BSC_PERIODICITIES_PVT;

 

/
