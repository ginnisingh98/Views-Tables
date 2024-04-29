--------------------------------------------------------
--  DDL for Package BIS_OBJECT_EXTENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_OBJECT_EXTENSIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVEXTS.pls 120.0 2005/06/01 14:54:20 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVEXTS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for populating the extension tables               |
REM |             - BIS_MEASURES_EXTENSION_TL                               |
REM |             - BIS_FORM_FUNCTION_EXTENSION_TL/B                        |
REM | NOTES                                                                 |
REM | 24-NOV-2004 Krishna  Created.                                         |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):=  'BIS_OBJECT_EXTENSIONS_PVT';
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

PROCEDURE Retrieve_Form_Func_Extension(
    p_Form_Func_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  x_Form_Func_Extn_Rec       OUT NOCOPY  BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  x_Return_Status            OUT NOCOPY  VARCHAR2
 ,  x_Msg_Count                OUT NOCOPY  NUMBER
 ,  x_Msg_Data                 OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);
PROCEDURE Add_Language;

PROCEDURE Delete_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

FUNCTION Get_FA_Id_By_Short_Name (p_Functional_Area_Short_Name IN VARCHAR2)RETURN NUMBER;

END BIS_OBJECT_EXTENSIONS_PVT;

 

/
