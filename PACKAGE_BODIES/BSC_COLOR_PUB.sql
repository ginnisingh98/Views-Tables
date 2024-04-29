--------------------------------------------------------
--  DDL for Package Body BSC_COLOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COLOR_PUB" as
/* $Header: BSCPCOLB.pls 120.2.12000000.1 2007/07/17 07:43:48 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPCOLB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 26, 2006                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Public Body version.                                           |
 |                      This package is to manage System level Color properties         |
 |                      and provide CRUD APIs for BSC_SYS_COLORS_B and related table    |
 |                                                                                      |
 |       16-APR-2007    Bug #5938481 Changing the system level weight is not changing   |
 |                     the prototype flag of the objectives                             |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_COLOR_PUB';


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
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPub_CrtColor;

  BSC_COLOR_PVT.Create_Color(p_Bsc_Color_Rec => p_Bsc_Color_Rec
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data);

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            ROLLBACK TO BscColorPub_CrtColor;
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
end Create_Color;


/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Color(
  p_commit             IN             VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Color_Tbl      IN             COLOR_ARRAY
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
l_color_id         NUMBER;
l_loop_count       NUMBER;
l_color_data       VARCHAR2(100);
l_color_num_eq     NUMBER;
l_user_color       NUMBER;
l_sys_color        NUMBER;
l_Bsc_Color_Rec    BSC_COLOR_PUB.Bsc_Color_Rec;
l_token_found      BOOLEAN;
l_Weight_Reconfigured BOOLEAN;
l_User_Numeric_Equivalent_Orig bsc_sys_colors_b.user_numeric_equivalent%TYPE;

CURSOR c_Kpis IS
SELECT
  indicator
FROM
  bsc_kpis_b
WHERE
  color_rollup_type = BSC_COLOR_CALC_UTIL.WEIGHTED_AVERAGE AND
  prototype_flag = BSC_DESIGNER_PVT.C_PRODUCTION;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPvt_UpdColor;
  -- Update by id or short_name
  l_Weight_Reconfigured := FALSE;
  FOR l_loop_count IN 1..p_bsc_color_tbl.COUNT LOOP
    l_color_data := p_bsc_color_tbl(l_loop_count);
    l_token_found := BSC_COLOR_RANGES_PUB.Get_Next_Token(l_color_data, ':', l_color_id);
    l_token_found := BSC_COLOR_RANGES_PUB.Get_Next_Token(l_color_data, ':', l_Bsc_Color_Rec.User_Numeric_Equivalent);
    l_token_found := BSC_COLOR_RANGES_PUB.Get_Next_Token(l_color_data, ':', l_Bsc_Color_Rec.User_Color);
    l_token_found := BSC_COLOR_RANGES_PUB.Get_Next_Token(l_color_data, ':', l_Bsc_Color_Rec.User_forecast_color);
    l_Bsc_Color_Rec.color_id := l_color_id;

    SELECT perf_sequence
          ,color
          ,forecast_color
          ,numeric_equivalent
          ,user_numeric_equivalent
    INTO l_Bsc_Color_Rec.Perf_Sequence
        ,l_Bsc_Color_Rec.Color
        ,l_Bsc_color_rec.forecast_color
        ,l_Bsc_Color_Rec.Numeric_Equivalent
        ,l_User_Numeric_Equivalent_Orig
    FROM bsc_sys_colors_b
    WHERE color_id = l_color_id;

    IF l_User_Numeric_Equivalent_Orig <> l_Bsc_Color_Rec.User_Numeric_Equivalent THEN
      l_Weight_Reconfigured := TRUE;
    END IF;
    l_Bsc_Color_Rec.last_updated_by := FND_GLOBAL.USER_ID;
    l_Bsc_Color_Rec.last_update_login := FND_GLOBAL.USER_ID;

    BSC_COLOR_PVT.Update_Color(p_Bsc_Color_Rec   => l_Bsc_Color_Rec
                              ,x_return_status   => x_return_status
                              ,x_msg_count       => x_msg_count
                              ,x_msg_data        => x_msg_data);
  END LOOP;

  IF l_Weight_Reconfigured THEN
    FOR cd IN c_Kpis LOOP
      BSC_DESIGNER_PVT.ActionFlag_Change (
         x_indicator => cd.indicator
        ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
      );
    END LOOP;
  END IF;

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    ROLLBACK TO BscColorPvt_UpdColor;
    raise;
END Update_Color;
/************************************************************************************
************************************************************************************/
-- Currently this API will not be used anywhere, need to see if we will provide it.
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
PROCEDURE Update_Default_Color_Count(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_color_count         IN             NUMBER
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_def_color_code VARCHAR2(15):= 'DEF_COLOR_COUNT';
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE bsc_sys_init
  SET    property_value = p_color_count
  WHERE  property_code  = l_def_color_code;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
END;

END BSC_COLOR_PUB;

/
