--------------------------------------------------------
--  DDL for Package BSC_COLOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COLOR_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCCPKGS.pls 120.1.12000000.1 2007/07/17 07:43:36 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCCPKGS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 26, 2006                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Package Body version.                                           |
 |                      This package is CRUD for System level Color properties          |
 |                      provide CRUD APIs for BSC_SYS_COLORS_B and related table        |
 |                                                                                      |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_COLOR_PKG';


/************************************************************************************
 ************************************************************************************/
PROCEDURE INSERT_ROW(
  p_Color_Id                  IN    NUMBER
 ,p_Short_Name                IN    VARCHAR2
 ,p_System_Color_Name         IN    VARCHAR2
 ,p_System_Color_Desc         IN    VARCHAR2
 ,p_prototype_label           IN    VARCHAR2
 ,p_Perf_Sequence_Id          IN    NUMBER
 ,p_System_Color              IN    NUMBER
 ,p_User_Color                IN    NUMBER
 ,p_Forecast_Color            IN    NUMBER
 ,p_User_Forecast_Color       IN    NUMBER
 ,p_Numeric_Equivalent        IN    NUMBER
 ,p_User_Numeric_Equivalent   IN    NUMBER
 ,p_Image                     IN    NUMBER
 ,p_Created_By                IN    NUMBER
 ,p_Last_Updated_By           IN    NUMBER
 ,p_Last_Update_Login         IN    NUMBER
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE UPDATE_ROW (
  p_Color_Id                  IN    NUMBER
 ,p_System_Color_Name         IN    VARCHAR2
 ,p_System_Color_Desc         IN    VARCHAR2
 ,p_prototype_label           IN    VARCHAR2
 ,p_Perf_Sequence_Id          IN    NUMBER
 ,p_System_Color              IN    NUMBER
 ,p_User_Color                IN    NUMBER
 ,p_User_Forecast_Color       IN    NUMBER
 ,p_Numeric_Equivalent        IN    NUMBER
 ,p_User_Numeric_Equivalent   IN    NUMBER
 ,p_Image                     IN    NUMBER
 ,p_Last_Updated_By           IN    NUMBER
 ,p_Last_Update_Login         IN    NUMBER
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE UPDATE_ROW (
  p_Color_Id                  IN    NUMBER
 ,p_Perf_Sequence_Id          IN    NUMBER
 ,p_System_Color              IN    NUMBER
 ,p_User_Color                IN    NUMBER
 ,p_User_Forecast_Color       IN    NUMBER
 ,p_Numeric_Equivalent        IN    NUMBER
 ,p_User_Numeric_Equivalent   IN    NUMBER
 ,p_Image                     IN    NUMBER
 ,p_Last_Updated_By           IN    NUMBER
 ,p_Last_Update_Login         IN    NUMBER
);

/************************************************************************************
************************************************************************************/
PROCEDURE DELETE_ROW(
  p_Bsc_Color_Id        IN             NUMBER
 ,p_Bsc_Color_SN        IN             NUMBER
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE ADD_LANGUAGE;

END BSC_COLOR_PKG;

 

/
