--------------------------------------------------------
--  DDL for Package Body BSC_COLOR_RANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COLOR_RANGE_PVT" AS
/* $Header: BSCVCRNB.pls 120.2.12000000.1 2007/07/17 07:44:39 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVCRNB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      November 02, 2006                                               |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Private Body version.                                           |
 |                      This package is to manage Range Properties properties           |
 |                      and provide CRUD APIs for BSC_SYS_COLOR_RANGES_B and related tbl|
 |                                                                                      |
 |  26-JUN-2007 ankgoel   Bug#6132361 - Handled PL objectives                          |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_COLOR_RANGE_PVT';


/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Props (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2
 ,p_color_range_id      IN            NUMBER
 ,p_property_value      IN            VARCHAR2 := NULL
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS
  l_user_id             bsc_color_type_props.last_updated_by%TYPE;
  l_count               NUMBER;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorRangePvt_CrtColorRng;

  IF(p_objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_kpi_measure_id IS NULL) THEN
    SELECT COUNT(1)
    INTO   l_count
    FROM   bsc_color_type_props
    WHERE  indicator = p_objective_id
    AND    kpi_measure_id IS NULL;
  ELSE
    SELECT COUNT(1)
    INTO   l_count
    FROM   bsc_color_type_props
    WHERE  indicator = p_objective_id
    AND    kpi_measure_id = p_kpi_measure_id
    AND    NVL(property_value, -1) = DECODE(p_property_value, NULL, -1, p_property_value);
  END IF;

  IF(l_count > 0 ) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_RANGES_ALREADY_EXISTS');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_user_id := FND_GLOBAL.USER_ID;

  INSERT INTO bsc_color_type_props(indicator
                                  ,kpi_measure_id
                                  ,color_type
                                  ,color_range_id
                                  ,property_value
                                  ,creation_date
                                  ,created_by
                                  ,last_update_date
                                  ,last_updated_by
                                  ,last_update_login)
                            VALUES(p_objective_id
                                  ,p_kpi_measure_id
                                  ,p_color_type
                                  ,p_color_range_id
                                  ,p_property_value
                                  ,sysdate
                                  ,l_user_id
                                  ,sysdate
                                  ,l_user_id
                                  ,l_user_id);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      ROLLBACK TO BscColorRangePvt_CrtColorRng;
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
      x_msg_data      :=  x_msg_data||' -> BSC_COLOR_RANGE_PVT.Create_Color_Props';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_COLOR_RANGE_PVT.Create_Color_Props';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_COLOR_RANGE_PVT.Create_Color_Props';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_COLOR_RANGE_PVT.Create_Color_Props';
    END IF;
END Create_Color_Props;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Range (
  p_commit                      IN            VARCHAR2 := FND_API.G_FALSE
 ,p_range_id                    IN            NUMBER
 ,p_Bsc_Kpi_Color_Range_Rec     IN            BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec
 ,p_user_id                     IN            FND_USER.user_id%TYPE
 ,x_return_status               OUT NOCOPY    VARCHAR2
 ,x_msg_count                   OUT NOCOPY    NUMBER
 ,x_msg_data                    OUT NOCOPY    VARCHAR2
) IS
  l_bsc_kpi_color_range_rec     BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
  l_th_count                    NUMBER;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorRangePvt_CrtColorRng;
  l_bsc_kpi_color_range_rec := p_Bsc_Kpi_Color_Range_Rec;

  IF(p_Bsc_Kpi_Color_Range_Rec IS NOT NULL) THEN
    FOR l_th_count IN 1..p_Bsc_Kpi_Color_Range_Rec.COUNT LOOP
      INSERT INTO bsc_color_ranges(color_range_id
                                  ,color_range_sequence
                                  ,low
                                  ,high
                                  ,color_id)
                            VALUES(p_range_id
                                  ,p_Bsc_Kpi_Color_Range_Rec(l_th_count).color_range_sequence
                                  ,p_Bsc_Kpi_Color_Range_Rec(l_th_count).low
                                  ,p_Bsc_Kpi_Color_Range_Rec(l_th_count).high
                                  ,p_Bsc_Kpi_Color_Range_Rec(l_th_count).color_id);
    END LOOP;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      ROLLBACK TO BscColorRangePvt_CrtColorRng;
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
        x_msg_data      :=  x_msg_data||' -> BSC_COLOR_RANGE_PVT.Create_Color_Range';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_COLOR_RANGE_PVT.Create_Color_Range';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_COLOR_RANGE_PVT.Create_Color_Range';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_COLOR_RANGE_PVT.Create_Color_Range';
    END IF;
END Create_Color_Range;
/************************************************************************************
 ************************************************************************************/

PROCEDURE Delete_Color_Ranges (
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
 ,p_color_range_id      IN             NUMBER
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
l_color_id         NUMBER;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscCRangePvt_DelColorRng;
  -- Update by id or short_name
  IF(p_color_range_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_RANGE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE bsc_color_ranges
  WHERE  color_range_id = p_color_range_id;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO BscCRangePvt_DelColorRng;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;
    --raise;
END Delete_Color_Ranges;

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Color_Prop_Ranges (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_color_range_id      IN             NUMBER
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscCRangePvt_DelColorRngProp;

  IF(p_color_range_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_RANGE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE bsc_color_type_props
  WHERE  color_range_id = p_color_range_id;

  Delete_Color_Ranges(p_color_range_id => p_color_range_id
                     ,x_return_status  => x_return_status
                     ,x_msg_count      => x_msg_count
                     ,x_msg_data       => x_msg_data);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO BscCRangePvt_DelColorRngProp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;
END Delete_Color_Prop_Ranges;

END BSC_COLOR_RANGE_PVT;

/
