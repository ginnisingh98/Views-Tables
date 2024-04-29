--------------------------------------------------------
--  DDL for Package BIS_OBJECT_EXTENSIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_OBJECT_EXTENSIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPEXTS.pls 120.0 2005/06/01 15:13:00 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPEXTS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Public package for populating the extension tables        |
REM |             - BIS_MEASURES_EXTENSION_TL                               |
REM |             - BIS_FORM_FUNCTION_EXTENSION_TL/B                        |
REM | NOTES                                                                 |
REM | 08-DEC-2004 Krishna Created.                                          |
REM | 27-DEC-2004 ashankar added the Procedure Object_Funct_Area_Map        |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):=  'BIS_OBJECT_EXTENSIONS_PUB';
C_CREATE   CONSTANT VARCHAR2(6) :=  'CREATE';
C_UPDATE   CONSTANT VARCHAR2(6) :=  'UPDATE';
C_DELETE   CONSTANT VARCHAR2(6) :=  'DELETE';
C_LOAD     CONSTANT VARCHAR2(4) :=  'LOAD';
C_RETRIEVE CONSTANT VARCHAR2(8) :=  'RETRIEVE';
C_TRANS    CONSTANT VARCHAR2(9) :=  'TRANSLATE';
C_INVALID  CONSTANT NUMBER      :=  -999;
C_FORCE    CONSTANT VARCHAR2(5) := 'FORCE';
C_MEASURE  CONSTANT VARCHAR2(7) := 'MEASURE';



TYPE Measure_Extension_Type IS RECORD
(
    Measure_Short_Name     BIS_MEASURES_EXTENSION.MEASURE_SHORT_NAME%TYPE
  , Name                   BIS_MEASURES_EXTENSION_TL.NAME%TYPE
  , Description            BIS_MEASURES_EXTENSION_TL.DESCRIPTION%TYPE
  , Functional_Area_Id     BIS_MEASURES_EXTENSION.FUNCTIONAL_AREA_ID%TYPE
  , Func_Area_Short_Name   BIS_FUNCTIONAL_AREAS.SHORT_NAME%TYPE
  , Created_By             BIS_MEASURES_EXTENSION_TL.CREATED_BY%TYPE
  , Creation_Date          BIS_MEASURES_EXTENSION_TL.CREATION_DATE%TYPE
  , Last_Updated_By        BIS_MEASURES_EXTENSION_TL.LAST_UPDATED_BY%TYPE
  , Last_Update_Date       BIS_MEASURES_EXTENSION_TL.LAST_UPDATE_DATE%TYPE
  , Last_Update_Login      BIS_MEASURES_EXTENSION_TL.LAST_UPDATE_LOGIN%TYPE
);



TYPE Form_Function_Extension_Type IS RECORD
(
    Object_Type            BIS_FORM_FUNCTION_EXTENSION.OBJECT_TYPE%TYPE
  , Object_Name            BIS_FORM_FUNCTION_EXTENSION.OBJECT_NAME%TYPE
  , Name                   BIS_FORM_FUNCTION_EXTENSION_TL.NAME%TYPE
  , Description            BIS_FORM_FUNCTION_EXTENSION_TL.DESCRIPTION%TYPE
  , Application_Id         BIS_FORM_FUNCTION_EXTENSION.APPLICATION_ID%TYPE
  , Func_Area_Id           BIS_FORM_FUNCTION_EXTENSION.FUNCTIONAL_AREA_ID%TYPE
  , Func_Area_short_name   BIS_FUNCTIONAL_AREAS.SHORT_NAME%TYPE
  , Language               BIS_FORM_FUNCTION_EXTENSION_TL.LANGUAGE%TYPE
  , Source_Lang            BIS_FORM_FUNCTION_EXTENSION_TL.SOURCE_LANG%TYPE
  , Created_By             BIS_FORM_FUNCTION_EXTENSION_TL.CREATED_BY%TYPE
  , Creation_Date          BIS_FORM_FUNCTION_EXTENSION_TL.CREATION_DATE%TYPE
  , Last_Updated_By        BIS_FORM_FUNCTION_EXTENSION_TL.LAST_UPDATED_BY%TYPE
  , Last_Update_Date       BIS_FORM_FUNCTION_EXTENSION_TL.LAST_UPDATE_DATE%TYPE
  , Last_Update_Login      BIS_FORM_FUNCTION_EXTENSION_TL.LAST_UPDATE_LOGIN%TYPE
);

-- APIS to manage Measure Extensions
PROCEDURE Create_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Retrieve_Measure_Extension(
  p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Meas_Extn_Rec       OUT NOCOPY  BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);


PROCEDURE Translate_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);
PROCEDURE Load_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,p_Custom_mode         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);



-- APIS to manage FORM_FUNCTION extensions
PROCEDURE Create_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);


PROCEDURE Update_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);


PROCEDURE Translate_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);
PROCEDURE Load_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,p_Custom_mode         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);
PROCEDURE Retrieve_Form_Func_Extension(
    p_Form_Func_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  x_Form_Func_Extn_Rec       OUT NOCOPY  BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  x_Return_Status            OUT NOCOPY  VARCHAR2
 ,  x_Msg_Count                OUT NOCOPY  NUMBER
 ,  x_Msg_Data                 OUT NOCOPY  VARCHAR2
);
PROCEDURE Delete_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

/***********************************************************************
                      Object Functional Area Mapping
/***********************************************************************/

PROCEDURE Object_Funct_Area_Map
(
   p_Api_Version            IN          NUMBER
 , p_Commit                 IN          VARCHAR2 := FND_API.G_FALSE
 , p_Obj_Type               IN          VARCHAR2
 , p_Obj_Name               IN          VARCHAR2
 , p_App_Id                 IN          NUMBER
 , p_Func_Area_Sht_Name     IN          VARCHAR2
 , x_Return_Status          OUT NOCOPY  VARCHAR2
 , x_Msg_Count              OUT NOCOPY  NUMBER
 , x_Msg_Data               OUT NOCOPY  VARCHAR2

);

/************************************************************************/
PROCEDURE Add_Language;

END BIS_OBJECT_EXTENSIONS_PUB;

 

/
