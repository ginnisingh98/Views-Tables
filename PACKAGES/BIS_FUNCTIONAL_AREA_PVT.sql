--------------------------------------------------------
--  DDL for Package BIS_FUNCTIONAL_AREA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_FUNCTIONAL_AREA_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVFASS.pls 120.0 2005/06/01 14:43:48 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVFASS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private  for populating the table BIS_FUNCTIONAL_AREAS_TL |
REM |             and relationship with FND_APPLICATIONS table              |
REM | NOTES                                                                 |
REM | 24-NOV-2004 Aditya Rao  Created.                                      |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_FUNCTIONAL_AREA_PVT';


PROCEDURE Create_Functional_Area(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);


PROCEDURE Update_Functional_Area(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);


PROCEDURE Translate_Functional_Area(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Functional_Area(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Create_Func_Area_Apps_Dep (
  p_Api_Version         IN           NUMBER
 ,p_Commit              IN           VARCHAR2 := FND_API.G_FALSE
 ,p_Functional_Area_Id  IN           NUMBER
 ,p_Application_Id      IN           NUMBER
 ,x_Return_Status       OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT  NOCOPY  NUMBER
 ,x_Msg_Data            OUT  NOCOPY  VARCHAR2
);


PROCEDURE Update_Func_Area_Apps_Dep (
  p_Api_Version         IN           NUMBER
 ,p_Commit              IN           VARCHAR2 := FND_API.G_FALSE
 ,p_Functional_Area_Id  IN           NUMBER
 ,p_Application_Id      IN           NUMBER
 ,x_Return_Status       OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT  NOCOPY  NUMBER
 ,x_Msg_Data            OUT  NOCOPY  VARCHAR2
);


PROCEDURE Remove_Func_Area_Apps_Dep (
  p_Api_Version         IN           NUMBER
 ,p_Commit              IN           VARCHAR2 := FND_API.G_FALSE
 ,p_Functional_Area_Id  IN           NUMBER
 ,p_Application_Id      IN           NUMBER
 ,x_Return_Status       OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT  NOCOPY  NUMBER
 ,x_Msg_Data            OUT  NOCOPY  VARCHAR2
);

PROCEDURE Retrieve_Functional_Area(
  p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Func_Area_Rec       OUT NOCOPY  BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Add_Language;

END BIS_FUNCTIONAL_AREA_PVT;

 

/
