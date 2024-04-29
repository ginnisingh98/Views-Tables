--------------------------------------------------------
--  DDL for Package Body BSC_COLOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COLOR_PKG" AS
/* $Header: BSCCPKGB.pls 120.3.12000000.1 2007/07/17 07:43:33 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCCPKGB.pls                                                    |
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
) IS
BEGIN

  INSERT INTO bsc_sys_colors_b (color_id
                               ,short_name
                               ,perf_sequence
                               ,color
                               ,user_color
                               ,forecast_color
                               ,user_forecast_color
                               ,numeric_equivalent
                               ,user_numeric_equivalent
                               ,user_image_id
                               ,creation_date
                               ,created_by
                               ,last_update_date
                               ,last_updated_by
                               ,last_update_login)
                        VALUES( p_Color_Id
                               ,p_Short_Name
                               ,p_Perf_Sequence_Id
                               ,p_System_Color
                               ,p_User_Color
                               ,p_Forecast_Color
                               ,p_User_Forecast_Color
                               ,p_Numeric_Equivalent
                               ,p_User_Numeric_Equivalent
                               ,p_Image
                               ,sysdate
                               ,p_Created_By
                               ,sysdate
                               ,p_Last_Updated_By
                               ,p_Last_Update_Login
                          );
  INSERT INTO bsc_sys_colors_tl (color_id
                               ,name
                               ,description
                               ,prototype_label
                               ,language
                               ,source_lang
                               ,creation_date
                               ,created_by
                               ,last_update_date
                               ,last_updated_by
                               ,last_update_login)
                        SELECT  p_Color_Id
                               ,p_System_Color_Name
                               ,p_System_Color_Desc
                               ,p_prototype_label
                               ,L.language_code
                               ,userenv('LANG')
                               ,sysdate
                               ,p_Created_By
                               ,sysdate
                               ,p_Last_Updated_By
                               ,p_Last_Update_Login
                        FROM  FND_LANGUAGES L
                        WHERE L.installed_flag in ('I', 'B');

EXCEPTION
  WHEN OTHERS THEN
    raise;
end INSERT_ROW;

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
) IS
BEGIN
  -- Update by id or short_name
  UPDATE bsc_sys_colors_b
  SET    perf_sequence          = p_Perf_Sequence_Id
        ,color                  = p_System_Color
        ,user_color             = p_User_Color
        ,user_forecast_color    = p_User_Forecast_Color
        ,numeric_equivalent     = p_Numeric_Equivalent
        ,user_numeric_equivalent= p_User_Numeric_Equivalent
        ,user_image_id          = p_Image
        ,creation_date =  SYSDATE
        ,created_by = NVL(p_Last_Update_Login, FND_GLOBAL.USER_ID)
        ,last_update_date = SYSDATE
        ,last_updated_by = NVL(p_Last_Updated_By, FND_GLOBAL.USER_ID)
        ,last_update_login= NVL(p_Last_Update_Login, FND_GLOBAL.LOGIN_ID)
  WHERE  color_id = p_color_Id;

  UPDATE bsc_sys_colors_tl
  SET    name            = p_System_Color_Name
        ,description     = p_System_Color_Desc
        ,prototype_label = p_prototype_label
        ,source_lang     = userenv('LANG')
  WHERE  color_id        = p_Color_Id
  AND    userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

END UPDATE_ROW;

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
) IS
BEGIN
  -- Update by id or short_name
  UPDATE bsc_sys_colors_b
  SET    perf_sequence          = p_Perf_Sequence_Id
        ,color                  = p_System_Color
        ,user_color             = p_User_Color
        ,user_forecast_color    = p_User_Forecast_Color
        ,numeric_equivalent     = p_Numeric_Equivalent
        ,user_numeric_equivalent= p_User_Numeric_Equivalent
        ,user_image_id          = p_Image
        ,last_update_date       = SYSDATE
        ,last_updated_by        = p_Last_Updated_By
        ,last_update_login      = p_Last_Update_Login
  WHERE  color_id = p_color_Id;

END UPDATE_ROW;
/************************************************************************************
************************************************************************************/
PROCEDURE DELETE_ROW(
  p_Bsc_Color_Id        IN             NUMBER
 ,p_Bsc_Color_SN        IN             NUMBER
) IS
  l_bsc_color_id      NUMBER;
BEGIN
  IF (p_Bsc_Color_Id IS NOT NULL) THEN
    DELETE BSC_SYS_COLORS_B
    WHERE  color_id = p_Bsc_Color_Id;

    DELETE bsc_sys_colors_tl
    WHERE  color_id = p_Bsc_Color_Id;
  ELSE -- Delete by short_name
    SELECT color_id
    INTO   l_bsc_color_id
    FROM bsc_sys_colors_b
    WHERE short_name=p_Bsc_Color_SN;

    DELETE BSC_SYS_COLORS_B
    WHERE  short_name = p_Bsc_Color_SN;

    DELETE bsc_sys_colors_tl
    WHERE  color_id = l_bsc_color_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE IS
BEGIN
  INSERT INTO bsc_sys_colors_tl (color_id
                                ,name
                                ,description
                                ,language
                                ,source_lang
                                ,creation_date
                                ,created_by
                                ,last_update_date
                                ,last_updated_by
                                ,last_update_login)
                        SELECT B.Color_Id
                               ,B.name
                               ,B.description
                               ,L.language_code
                              ,L.language_code
                              ,sysdate
                              ,B.Created_By
                              ,sysdate
                              ,B.Last_Updated_By
                              ,B.Last_Update_Login
                        FROM  BSC_SYS_COLORS_TL B, FND_LANGUAGES L
                        WHERE L.installed_flag in ('I', 'B')
                        AND   B.LANGUAGE = USERENV('LANG')
                        AND NOT EXISTS
                              (SELECT NULL
                               FROM BSC_SYS_COLORS_TL C
                               WHERE C.color_id = B.color_id
                               AND   C.language = L.language_code);
END ADD_LANGUAGE;

END BSC_COLOR_PKG;

/
