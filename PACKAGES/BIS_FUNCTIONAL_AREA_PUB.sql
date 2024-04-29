--------------------------------------------------------
--  DDL for Package BIS_FUNCTIONAL_AREA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_FUNCTIONAL_AREA_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPFASS.pls 120.0 2005/06/01 15:25:50 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPFASS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for populating the table BIS_FUNCTIONAL_AREAS_TL  |
REM |             and relationship with FND_APPLICATIONS table              |
REM | NOTES                                                                 |
REM | 24-NOV-2004 Aditya Rao  Created.                                      |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_FUNCTIONAL_AREA_PUB';

C_CREATE   CONSTANT VARCHAR2(30):='CREATE';
C_UPDATE   CONSTANT VARCHAR2(30):='UPDATE';
C_RETRIEVE CONSTANT VARCHAR2(30):='RETRIEVE';
C_DELETE   CONSTANT VARCHAR2(30):='DELETE';


TYPE Functional_Area_Rec_Type IS RECORD
(
   Functional_Area_Id            BIS_FUNCTIONAL_AREAS.FUNCTIONAL_AREA_ID%TYPE
 , Short_Name                    BIS_FUNCTIONAL_AREAS.SHORT_NAME%TYPE -- requirement of this field is still under discussion
 , Name                          BIS_FUNCTIONAL_AREAS_TL.NAME%TYPE
 , Description                   BIS_FUNCTIONAL_AREAS_TL.DESCRIPTION%TYPE
 , Created_By                    BIS_FUNCTIONAL_AREAS.CREATED_BY%TYPE
 , Creation_Date                 BIS_FUNCTIONAL_AREAS.CREATION_DATE%TYPE
 , Last_Updated_By               BIS_FUNCTIONAL_AREAS.LAST_UPDATED_BY%TYPE
 , Last_Update_Date              BIS_FUNCTIONAL_AREAS.LAST_UPDATE_DATE%TYPE
 , Last_Update_Login             BIS_FUNCTIONAL_AREAS.LAST_UPDATE_LOGIN%TYPE
);

TYPE Func_Area_Apps_Depend_Rec_Type IS RECORD
(
    Functional_Area_Id          BIS_FUNC_AREA_APP_DEPENDENCY.FUNCTIONAL_AREA_ID%TYPE
  , Func_Area_Short_Name        BIS_FUNCTIONAL_AREAS.SHORT_NAME%TYPE
  , Application_Id              BIS_FUNC_AREA_APP_DEPENDENCY.APPLICATION_ID%TYPE
  , Apps_Short_Name             FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE
);


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


PROCEDURE Retrieve_Functional_Area(
  p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Func_Area_Rec       OUT NOCOPY  BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
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

PROCEDURE Load_Functional_Area(
  p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
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


PROCEDURE Load_Func_Area_Apps_Dep (
  p_Commit                IN           VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_App_Dep_Rec IN           BIS_FUNCTIONAL_AREA_PUB.Func_Area_Apps_Depend_Rec_Type
 ,x_Return_Status         OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count             OUT  NOCOPY  NUMBER
 ,x_Msg_Data              OUT  NOCOPY  VARCHAR2
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


PROCEDURE ADD_LANGUAGE;

END BIS_FUNCTIONAL_AREA_PUB;

 

/
