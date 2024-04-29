--------------------------------------------------------
--  DDL for Package Body BSC_COLOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COLOR_PVT" as
/* $Header: BSCVCOLB.pls 120.3.12000000.1 2007/07/17 07:44:36 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVCOLB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 26, 2006                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Private Body version.                                           |
 |                      This package is to manage System level Color properties         |
 |                      and provide CRUD APIs for BSC_SYS_COLORS_B and related table    |
 |                                                                                      |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_COLOR_PVT';

PROCEDURE Retrieve_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Id        IN             NUMBER
 ,p_Bsc_Color_SN        IN             VARCHAR2
 ,x_Bsc_Color_Rec       OUT NOCOPY     BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Color_Rec       IN            BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

    l_Count                     NUMBER;
    l_forecast_color            NUMBER;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPvt_CrtColor;

  IF(p_Bsc_Color_Rec.Color_id IS NOT NULL) THEN
    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_COLORS_B
    WHERE  COLOR_ID = p_Bsc_Color_Rec.Color_id;

    IF (l_Count > 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_COLOR_ID_EXISTS');
      FND_MESSAGE.SET_TOKEN('BSC_COLOR_ID', p_Bsc_Color_Rec.Color_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_COLOR_ID');
    FND_MESSAGE.SET_TOKEN('BSC_COLOR_ID', p_Bsc_Color_Rec.Color_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (p_Bsc_Color_Rec.Short_Name IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_COLOR_SN');
    FND_MESSAGE.SET_TOKEN('BSC_COLOR_SN', p_Bsc_Color_Rec.short_name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  BSC_COLOR_PKG.INSERT_ROW(p_Bsc_Color_Rec.color_id
                          ,p_Bsc_Color_Rec.Short_Name
                          ,p_Bsc_Color_Rec.name
                          ,p_Bsc_Color_Rec.description
                          ,p_Bsc_Color_Rec.prototype_label
                          ,p_Bsc_Color_Rec.Perf_Sequence
                          ,p_Bsc_Color_Rec.color
                          ,p_Bsc_Color_Rec.User_Color
                          ,p_Bsc_Color_Rec.forecast_color
                          ,p_Bsc_Color_Rec.User_Forecast_Color
                          ,p_Bsc_Color_Rec.Numeric_Equivalent
                          ,p_Bsc_Color_Rec.User_Numeric_Equivalent
                          ,p_Bsc_Color_Rec.Image
                          ,p_Bsc_Color_Rec.Created_By
                          ,p_Bsc_Color_Rec.Last_Updated_By
                          ,p_Bsc_Color_Rec.Last_Update_Login
                           );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            ROLLBACK TO BscColorPvt_CrtColor;
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Color with parameter x_Bsc_Kpi_Entity_Rec ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Color with parameter x_Bsc_Kpi_Entity_Rec ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Color with parameter x_Bsc_Kpi_Entity_Rec ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Color with parameter x_Bsc_Kpi_Entity_Rec ';
        END IF;
END Create_Color;

/************************************************************************************
 ************************************************************************************/
-- API To be called from UI.
PROCEDURE Update_Color(
  p_commit             IN             VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Color_Rec      IN             BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_color_id         NUMBER;
  l_Bsc_Color_Rec       BSC_COLOR_PUB.Bsc_Color_Rec;

  l_user_id             NUMBER;
  l_login_id            NUMBER;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPvt_UpdColor;
  /*BSC_COLOR_PKG.UPDATE_ROW(p_Bsc_Color_Rec.color_id
                          ,p_Bsc_Color_Rec.Perf_Sequence
                          ,p_Bsc_Color_Rec.color
                          ,p_Bsc_Color_Rec.user_color
                          ,p_Bsc_Color_Rec.User_Forecast_Color
                          ,p_Bsc_Color_Rec.Numeric_Equivalent
                          ,p_Bsc_Color_Rec.User_Numeric_Equivalent
                          ,p_Bsc_Color_Rec.Image
                          ,p_Bsc_Color_Rec.Last_Updated_By
                          ,p_Bsc_Color_Rec.last_update_login);*/
  Retrieve_Color(p_Bsc_Color_Id   =>  p_Bsc_Color_Rec.color_id
               , p_Bsc_Color_SN   =>  p_Bsc_Color_Rec.short_name
                ,x_Bsc_Color_Rec  =>  l_Bsc_Color_Rec
                ,x_return_status  =>  x_return_status
                ,x_msg_count      =>  x_msg_count
                ,x_msg_data       =>  x_msg_data);
  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*IF(p_Bsc_Color_Rec.name IS NOT NULL) THEN
    l_Bsc_Color_Rec.name := p_Bsc_Color_Rec.name;
  END IF;
  IF(p_Bsc_Color_Rec.description IS NOT NULL) THEN
    l_Bsc_Color_Rec.description := p_Bsc_Color_Rec.description;
  END IF;
  IF(p_Bsc_Color_Rec.prototype_label IS NOT NULL) THEN
    l_Bsc_Color_Rec.prototype_label := p_Bsc_Color_Rec.prototype_label;
  END IF;*/
  IF(p_Bsc_Color_Rec.perf_sequence IS NOT NULL) THEN
    l_Bsc_Color_Rec.perf_sequence := p_Bsc_Color_Rec.perf_sequence;
  END IF;
  IF(p_Bsc_Color_Rec.color IS NOT NULL) THEN
    l_Bsc_Color_Rec.color := p_Bsc_Color_Rec.color;
  END IF;
  IF(p_Bsc_Color_Rec.forecast_color IS NOT NULL) THEN
    l_Bsc_Color_Rec.forecast_color := p_Bsc_Color_Rec.forecast_color;
  END IF;
  IF(p_Bsc_Color_Rec.user_forecast_color IS NOT NULL) THEN
    l_Bsc_Color_Rec.user_forecast_color := p_Bsc_Color_Rec.user_forecast_color;
  END IF;
  IF(p_Bsc_Color_Rec.user_color IS NOT NULL) THEN
    l_Bsc_Color_Rec.user_color := p_Bsc_Color_Rec.user_color;
  END IF;
  IF(p_Bsc_Color_Rec.user_numeric_equivalent IS NOT NULL) THEN
    l_Bsc_Color_Rec.user_numeric_equivalent := p_Bsc_Color_Rec.user_numeric_equivalent;
  END IF;
  IF(p_Bsc_Color_Rec.numeric_equivalent IS NOT NULL) THEN
    l_Bsc_Color_Rec.numeric_equivalent := p_Bsc_Color_Rec.numeric_equivalent;
  END IF;

  l_user_id := fnd_global.USER_ID;
  l_login_id := fnd_global.LOGIN_ID;

  BSC_COLOR_PKG.UPDATE_ROW(p_Color_Id               =>   l_Bsc_Color_Rec.color_id
                          ,p_Perf_Sequence_Id       =>   l_Bsc_Color_Rec.Perf_Sequence
                          ,p_System_Color           =>   l_Bsc_Color_Rec.color
                          ,p_User_Color             =>   l_Bsc_Color_Rec.user_color
                          ,p_User_Forecast_Color    =>   l_Bsc_Color_Rec.User_Forecast_Color
                          ,p_Numeric_Equivalent     =>   l_Bsc_Color_Rec.Numeric_Equivalent
                          ,p_User_Numeric_Equivalent=>   l_Bsc_Color_Rec.User_Numeric_Equivalent
                          ,p_Image                  =>   l_Bsc_Color_Rec.Image
                          ,p_Last_Updated_By        =>   nvl(l_Bsc_Color_Rec.Last_Updated_By, l_user_id)
                          ,p_Last_Update_Login      =>   nvl(l_Bsc_Color_Rec.last_update_login, l_login_id));
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO BscColorPvt_UpdColor;
    raise;
END Update_Color;
/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Id        IN             NUMBER
 ,p_Bsc_Color_SN        IN             NUMBER
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPvt_DelColor;

  IF(p_Bsc_Color_Id IS NULL AND p_Bsc_Color_SN IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_COLOR_ID_SN');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  BSC_COLOR_PKG.DELETE_ROW(p_Bsc_Color_Id
                          ,p_Bsc_Color_SN);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    ROLLBACK TO BscColorPvt_DelColor;
END Delete_Color;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Translate_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Rec       IN             BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_Bsc_Color_Rec       BSC_COLOR_PUB.Bsc_Color_Rec;
  l_user_id             NUMBER;
  l_login_id            NUMBER;
BEGIN
  SAVEPOINT BscColorPvt_TrnsColor;

  Retrieve_Color(p_Bsc_Color_Id   =>  p_Bsc_Color_Rec.color_id
               , p_Bsc_Color_SN   =>  p_Bsc_Color_Rec.short_name
                ,x_Bsc_Color_Rec  =>  l_Bsc_Color_Rec
                ,x_return_status  =>  x_return_status
                ,x_msg_count      =>  x_msg_count
                ,x_msg_data       =>  x_msg_data);
  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(p_Bsc_Color_Rec.name IS NOT NULL) THEN
    l_Bsc_Color_Rec.name := p_Bsc_Color_Rec.name;
  END IF;
  IF(p_Bsc_Color_Rec.description IS NOT NULL) THEN
    l_Bsc_Color_Rec.description := p_Bsc_Color_Rec.description;
  END IF;
  IF(p_Bsc_Color_Rec.prototype_label IS NOT NULL) THEN
    l_Bsc_Color_Rec.prototype_label := p_Bsc_Color_Rec.prototype_label;
  END IF;
  IF(p_Bsc_Color_Rec.perf_sequence IS NOT NULL) THEN
    l_Bsc_Color_Rec.perf_sequence := p_Bsc_Color_Rec.perf_sequence;
  END IF;
  IF(p_Bsc_Color_Rec.color IS NOT NULL) THEN
    l_Bsc_Color_Rec.color := p_Bsc_Color_Rec.color;
  END IF;
  IF(p_Bsc_Color_Rec.forecast_color IS NOT NULL) THEN
    l_Bsc_Color_Rec.forecast_color := p_Bsc_Color_Rec.forecast_color;
  END IF;
  IF(p_Bsc_Color_Rec.numeric_equivalent IS NOT NULL) THEN
    l_Bsc_Color_Rec.numeric_equivalent := p_Bsc_Color_Rec.numeric_equivalent;
  END IF;

  IF(l_Bsc_Color_Rec.user_color IS NULL) THEN
    l_Bsc_Color_Rec.user_color := l_Bsc_Color_Rec.color;
  END IF;
  IF(l_Bsc_Color_Rec.User_Numeric_Equivalent IS NULL) THEN
    l_Bsc_Color_Rec.User_Numeric_Equivalent := l_Bsc_Color_Rec.numeric_equivalent;
  END IF;
  IF(l_Bsc_Color_Rec.User_Forecast_Color IS NULL) THEN
    l_Bsc_Color_Rec.User_Forecast_Color := l_Bsc_Color_Rec.forecast_color;
  END IF;


  l_user_id := fnd_global.USER_ID;
  l_login_id := fnd_global.LOGIN_ID;

  BSC_COLOR_PKG.UPDATE_ROW(p_Color_Id               =>   l_Bsc_Color_Rec.color_id
                          ,p_System_Color_Name      =>   l_Bsc_Color_Rec.name
                          ,p_System_Color_Desc      =>   l_Bsc_Color_Rec.description
                          ,p_prototype_label        =>   l_Bsc_Color_Rec.prototype_label
                          ,p_Perf_Sequence_Id       =>   l_Bsc_Color_Rec.Perf_Sequence
                          ,p_System_Color           =>   l_Bsc_Color_Rec.color
                          ,p_User_Color             =>   l_Bsc_Color_Rec.user_color
                          ,p_User_Forecast_Color    =>   l_Bsc_Color_Rec.User_Forecast_Color
                          ,p_Numeric_Equivalent     =>   l_Bsc_Color_Rec.Numeric_Equivalent
                          ,p_User_Numeric_Equivalent=>   l_Bsc_Color_Rec.User_Numeric_Equivalent
                          ,p_Image                  =>   l_Bsc_Color_Rec.Image
                          ,p_Last_Updated_By        =>   l_Bsc_Color_Rec.Last_Updated_By
                          ,p_Last_Update_Login      =>   l_Bsc_Color_Rec.last_update_login);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    ROLLBACK TO BscColorPvt_TrnsColor;
END Translate_Color;
/************************************************************************************
 ************************************************************************************/
PROCEDURE Load_Translated_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Rec       IN             BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_Bsc_Color_Rec       BSC_COLOR_PUB.Bsc_Color_Rec;
  l_user_id             NUMBER;
  l_login_id            NUMBER;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPvt_LdTrnsColor;

  Retrieve_Color(p_Bsc_Color_Id   =>  p_Bsc_Color_Rec.color_id
               , p_Bsc_Color_SN   =>  p_Bsc_Color_Rec.short_name
                ,x_Bsc_Color_Rec  =>  l_Bsc_Color_Rec
                ,x_return_status  =>  x_return_status
                ,x_msg_count      =>  x_msg_count
                ,x_msg_data       =>  x_msg_data);
  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(p_Bsc_Color_Rec.name IS NOT NULL) THEN
    l_Bsc_Color_Rec.name := p_Bsc_Color_Rec.name;
  END IF;
  IF(p_Bsc_Color_Rec.description IS NOT NULL) THEN
    l_Bsc_Color_Rec.description := p_Bsc_Color_Rec.description;
  END IF;
  IF(p_Bsc_Color_Rec.prototype_label IS NOT NULL) THEN
    l_Bsc_Color_Rec.prototype_label := p_Bsc_Color_Rec.prototype_label;
  END IF;
  IF(p_Bsc_Color_Rec.perf_sequence IS NOT NULL) THEN
    l_Bsc_Color_Rec.perf_sequence := p_Bsc_Color_Rec.perf_sequence;
  END IF;
  IF(p_Bsc_Color_Rec.color IS NOT NULL) THEN
    l_Bsc_Color_Rec.color := p_Bsc_Color_Rec.color;
  END IF;
  IF(p_Bsc_Color_Rec.forecast_color IS NOT NULL) THEN
    l_Bsc_Color_Rec.forecast_color := p_Bsc_Color_Rec.forecast_color;
  END IF;
  IF(p_Bsc_Color_Rec.numeric_equivalent IS NOT NULL) THEN
    l_Bsc_Color_Rec.numeric_equivalent := p_Bsc_Color_Rec.numeric_equivalent;
  END IF;

  l_user_id := fnd_global.USER_ID;
  l_login_id := fnd_global.LOGIN_ID;

  UPDATE bsc_sys_colors_tl
  SET    name = l_Bsc_Color_Rec.name
        ,description = l_Bsc_Color_Rec.description
        ,prototype_label = l_Bsc_Color_Rec.prototype_label
        ,source_lang = userenv('LANG')
        ,last_update_date = l_Bsc_Color_Rec.last_update_date
        ,last_updated_by  = l_user_id
        ,last_update_login= l_login_id
  WHERE color_id= l_Bsc_Color_Rec.color_id
  AND   userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  UPDATE bsc_sys_colors_b
  SET    perf_sequence      = l_Bsc_Color_Rec.perf_sequence
        ,color              = l_Bsc_Color_Rec.color
        ,forecast_color     = l_Bsc_Color_Rec.forecast_color
        ,numeric_equivalent = l_Bsc_Color_Rec.numeric_equivalent
        ,last_update_date   = l_Bsc_Color_Rec.last_update_date
        ,last_updated_by    = l_user_id
        ,last_update_login  = l_login_id
   WHERE color_id= l_Bsc_Color_Rec.color_id;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    ROLLBACK TO BscColorPvt_LdTrnsColor;
END Load_Translated_Color;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Retrieve_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Id        IN             NUMBER
 ,p_Bsc_Color_SN        IN             VARCHAR2
 ,x_Bsc_Color_Rec       OUT NOCOPY     BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  CURSOR c_sys_colors_id IS
    SELECT color_id, short_name, name, description, prototype_label, perf_sequence,
           color, user_color, forecast_color, user_forecast_color, numeric_equivalent, user_numeric_equivalent, last_update_date
    FROM   bsc_sys_colors_vl
    WHERE  color_id = p_Bsc_Color_Id;

  CURSOR c_sys_colors_sn IS
    SELECT color_id, short_name, name, description, prototype_label, perf_sequence,
           color, user_color, forecast_color, user_forecast_color, numeric_equivalent, user_numeric_equivalent, last_update_date
    FROM   bsc_sys_colors_vl
    WHERE  short_name = p_Bsc_Color_SN;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPvt_RetColor;

  IF(p_Bsc_Color_Id IS NULL AND p_Bsc_Color_SN IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_COLOR_ID_SN');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(p_Bsc_Color_Id IS NOT NULL) THEN
    OPEN c_sys_colors_id;
    FETCH c_sys_colors_id
    INTO  x_Bsc_Color_Rec.color_id
         ,x_Bsc_Color_Rec.short_name
         ,x_Bsc_Color_Rec.name
         ,x_Bsc_Color_Rec.description
         ,x_Bsc_Color_Rec.prototype_label
         ,x_Bsc_Color_Rec.perf_sequence
         ,x_Bsc_Color_Rec.color
         ,x_Bsc_Color_Rec.user_color
         ,x_Bsc_Color_Rec.forecast_color
         ,x_Bsc_Color_Rec.user_forecast_color
         ,x_Bsc_Color_Rec.numeric_equivalent
         ,x_Bsc_Color_Rec.user_numeric_equivalent
         ,x_Bsc_Color_Rec.last_update_date;

    IF c_sys_colors_id%ROWCOUNT = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_sys_colors_id;
  ELSE
    OPEN c_sys_colors_sn;
    FETCH c_sys_colors_sn
    INTO  x_Bsc_Color_Rec.color_id
         ,x_Bsc_Color_Rec.short_name
         ,x_Bsc_Color_Rec.name
         ,x_Bsc_Color_Rec.description
         ,x_Bsc_Color_Rec.prototype_label
         ,x_Bsc_Color_Rec.perf_sequence
         ,x_Bsc_Color_Rec.color
         ,x_Bsc_Color_Rec.user_color
         ,x_Bsc_Color_Rec.forecast_color
         ,x_Bsc_Color_Rec.user_forecast_color
         ,x_Bsc_Color_Rec.numeric_equivalent
         ,x_Bsc_Color_Rec.user_numeric_equivalent
         ,x_Bsc_Color_Rec.last_update_date;

    IF c_sys_colors_sn%ROWCOUNT = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_sys_colors_sn;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    ROLLBACK TO BscColorPvt_RetColor;
END  Retrieve_Color;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Load_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Rec       IN             BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_Bsc_Color_Rec       BSC_COLOR_PUB.Bsc_Color_Rec;
  l_user_id             NUMBER;
  l_login_id            NUMBER;
  l_count               NUMBER;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPvt_LoadColor;

  SELECT COUNT(1)
  INTO   l_count
  FROM   bsc_sys_colors_b
  WHERE  short_name = p_Bsc_Color_Rec.short_name;

  IF (l_count > 0) THEN
    Load_Translated_Color(p_Bsc_Color_Rec   => p_Bsc_Color_Rec
                         ,x_return_status   => x_return_status
                         ,x_msg_count       => x_msg_count
                         ,x_msg_data        => x_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE

    l_Bsc_Color_Rec := p_Bsc_Color_Rec;

    IF (l_Bsc_Color_Rec.user_color IS NULL) THEN
      l_Bsc_Color_Rec.user_color := p_Bsc_Color_Rec.color;
    END IF;
    IF (l_Bsc_Color_Rec.user_forecast_color IS NULL) THEN
      l_Bsc_Color_Rec.user_forecast_color := p_Bsc_Color_Rec.forecast_color;
    END IF;
    IF (l_Bsc_Color_Rec.user_numeric_equivalent IS NULL) THEN
      l_Bsc_Color_Rec.user_numeric_equivalent := p_Bsc_Color_Rec.numeric_equivalent;
    END IF;

    Create_Color( p_Bsc_Color_Rec       => l_Bsc_Color_Rec
                 ,x_return_status       => x_return_status
                 ,x_msg_count           => x_msg_count
                 ,x_msg_data            => x_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    ROLLBACK TO BscColorPvt_LoadColor;
END Load_Color;

END BSC_COLOR_PVT;

/
