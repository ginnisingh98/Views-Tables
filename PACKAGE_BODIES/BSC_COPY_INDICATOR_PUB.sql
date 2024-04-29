--------------------------------------------------------
--  DDL for Package Body BSC_COPY_INDICATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COPY_INDICATOR_PUB" AS
/* $Header: BSCPCINB.pls 120.7.12000000.1 2007/07/17 07:43:41 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |                      BSCPCINB.pls                                     |
 |                                                                       |
 | Creation Date:                                                        |
 |                      March 21, 2007                                   |
 |                                                                       |
 | Creator:                                                              |
 |                      Ajitha Koduri                                    |
 |                                                                       |
 | Description:                                                          |
 |          Public Body version.                                         |
 |          This package contains all the APIs related to copy and move  |
 |          indicators                                                   |
 |                                                                       |
 | History:                                                              |
 |          21-MAR-2007 akoduri Copy Indicator Enh#5943238               |
 |          11-APR-2007 akoduri Bug 5982764 Move of Indicator is not     |
 |                      the new group to scorecard                       |
 |          12-APR-2007 akoduri Bug 5982815 Key items are not retained   |
 |                      in incremental migration                         |
 |          16-MAR-2007 akoduri Bug 5988082 Issue with incremental       |
 |                      migration when objectives with common measures   |
 |                      are chosen                                       |
 |          05-JUN-2007 akoduri Bug 5982136 Default Periodicity property |
 |                      is not retained                                  |
 |          06-JUN-2007 akoduri Bug 5958688 Enable YTD as default at KPI |
 |          14-JUN-2007 akoduri Bug 6129225 viewport_flag (Number of     |
 |                      periods is getting reset for custom periodicities|
 *=======================================================================*/

g_base_message VARCHAR2(4000);
g_message VARCHAR2(4000);

/************************************************************************************
--	API name 	: Get_Ind_Group_Id
--	Type		: Public
--	Function	:
--      This API retrieves the old Objective Group Id to which the indicator is
--      attached
--
************************************************************************************/

FUNCTION Get_Ind_Group_Id(
  p_Indicator IN NUMBER
)
RETURN NUMBER IS

  l_Group_Id    bsc_kpis_b.ind_group_id%TYPE;

  CURSOR c_Ind_Group_Id IS
  SELECT
    a.ind_group_id
  FROM
    bsc_kpis_b a
  WHERE
    a.indicator = p_Indicator;
BEGIN
   OPEN c_Ind_Group_Id;
   FETCH c_Ind_Group_Id INTO l_Group_Id;
   CLOSE c_Ind_Group_Id;

   RETURN l_group_id;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Ind_Group_Id;

/************************************************************************************
--	API name 	: Assign_Ind_Group_To_Tab
--	Type		: Public
--	Function	:
--      This API will check whether the indicator group is already attached to the
--      scorecard. If it is attached then the new group will be attached
************************************************************************************/
PROCEDURE Assign_Ind_Group_To_Tab (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Indicator                IN    NUMBER
, p_New_Indicator_Group      IN    NUMBER
, p_Old_Indicator_Group      IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)
IS
  l_Tab_Id bsc_tabs_b.tab_id%TYPE;
  l_Check_Association NUMBER := 0;
  l_Indicator_Count   NUMBER := 0;
  l_Bsc_Kpi_Group_Rec  BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;
  CURSOR c_Tab_Id IS
  SELECT
    tab_id
  FROM
    bsc_tab_indicators
  WHERE
    indicator = p_Indicator;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscAssignIndGroupTab;

  OPEN c_Tab_Id;
  FETCH c_Tab_Id INTO l_Tab_Id;
  CLOSE c_Tab_Id;

  IF l_Tab_Id IS NOT NULL THEN
    SELECT
      COUNT(1)
    INTO
      l_Check_Association
    FROM
      bsc_tab_ind_groups_vl
    WHERE
      tab_id = p_Indicator
      AND ind_group_id = p_New_Indicator_Group;

    IF l_Check_Association IS NOT NULL AND l_Check_Association = 0 THEN
      l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_New_Indicator_Group;
      l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := l_Tab_Id;
     BSC_KPI_GROUP_PVT.Update_Kpi_Group(
        p_commit             => FND_API.G_FALSE
       ,p_Bsc_Kpi_Group_Rec  => l_Bsc_Kpi_Group_Rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;
    END IF;

     SELECT
       COUNT(1)
     INTO
       l_Indicator_Count
     FROM
       bsc_tab_indicators ti,
       bsc_kpis_vl k
     WHERE
       ti.tab_id = l_Tab_Id
       AND ti.indicator = k.indicator
       AND k.ind_group_id = p_Old_Indicator_Group;

     IF l_Indicator_Count = 0 THEN
       l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_Old_Indicator_Group;
       l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := l_Tab_Id;
       BSC_KPI_GROUP_PVT.Delete_Kpi_Group(
         p_commit             => FND_API.G_FALSE
        ,p_Bsc_Kpi_Group_Rec  => l_Bsc_Kpi_Group_Rec
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_ERROR;
       END IF;
     END IF;

  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscAssignIndGroupTab;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscAssignIndGroupTab;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscAssignIndGroupTab;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' ->BSC_COPY_INDICATOR_PUB.Assign_Ind_Group_To_Tab ';
    ELSE
      x_msg_data := SQLERRM || 'at BSC_COPY_INDICATOR_PUB.Assign_Ind_Group_To_Tab ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscAssignIndGroupTab;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' ->BSC_COPY_INDICATOR_PUB.Assign_Ind_Group_To_Tab ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Assign_Ind_Group_To_Tab ';
    END IF;
END Assign_Ind_Group_To_Tab;

/************************************************************************************
--	API name 	: Update_Kpi_Group_Properties
--	Type		: Public
--	Function	:
--      This API will update the indicator group type in the following scenarios
--      1. If the group type is 1 and if it has already 1 kpi attached then
--         the group type will be updated to 0
--      Add any cases if required
************************************************************************************/
PROCEDURE Update_Kpi_Group_Properties (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_New_Indicator_Group      IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)
IS
  l_Bsc_Kpi_Group_Rec        BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;
  l_Kpi_Count                NUMBER := 0;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscUpdateKpiGroupProperties;

  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_New_Indicator_Group;

  BSC_KPI_GROUP_PUB.Retrieve_Kpi_Group(
    p_commit            => FND_API.G_FALSE
   ,p_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
   ,x_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
   ,x_return_status     => x_return_status
   ,x_msg_count         => x_msg_count
   ,x_msg_data          => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  SELECT COUNT(1)
  INTO
    l_Kpi_Count
  FROM
    bsc_kpis_b
  WHERE
    ind_group_id = p_New_Indicator_Group
    AND prototype_flag <> -2
    AND share_flag <> 2;

  IF l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type = BSC_COPY_INDICATOR_PUB.INDICATOR_BELOW_NAME
    AND l_Kpi_Count >= 1 THEN
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type := BSC_COPY_INDICATOR_PUB.INDICATOR_BESIDE_NAME;
  END IF;

  BSC_KPI_GROUP_PUB.Update_Kpi_Group(
    p_commit            => FND_API.G_FALSE
   ,p_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
   ,x_return_status     => x_return_status
   ,x_msg_count         => x_msg_count
   ,x_msg_data          => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscUpdateKpiGroupProperties;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscUpdateKpiGroupProperties;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscUpdateKpiGroupProperties;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Update_Kpi_Group_Properties ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Update_Kpi_Group_Properties ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscUpdateKpiGroupProperties;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Update_Kpi_Group_Properties ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Update_Kpi_Group_Properties ';
    END IF;
END Update_Kpi_Group_Properties;
/************************************************************************************
--	API name 	: Move_Indicator
--	Type		: Public
--	Function	:
--      This API is used to move an indicator from one indicator group to another
--      This can also be used to reposition the indicator with the same group
--      1. Update Group properties if earlier group type is 1
--         (Color Box above objective label) and the kpi count in the objective
--         is already 1
--      2. Update the Ind_Group_Id to the new group
************************************************************************************/
PROCEDURE Move_Indicator (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Indicator                IN    NUMBER
, p_New_Indicator_Group      IN    NUMBER
, p_Assign_Group_To_Tab      IN    VARCHAR2 := FND_API.G_TRUE
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
) IS
  l_Bsc_Kpi_Entity_Rec BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Old_Indicator_Group bsc_tab_ind_groups_b.ind_group_id%TYPE;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscMovIndicatorSavePnt;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Indicator;
  BSC_KPI_PVT.Retrieve_Kpi(
    p_commit             => FND_API.G_FALSE
   ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
   ,x_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
   ,x_return_status      => x_return_status
   ,x_msg_count          => x_msg_count
   ,x_msg_data           => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_Old_Indicator_Group := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id := p_New_Indicator_Group;
  BSC_KPI_PVT.Update_Kpi(
    p_commit             => FND_API.G_FALSE
   ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
   ,x_return_status      => x_return_status
   ,x_msg_count          => x_msg_count
   ,x_msg_data           => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_Assign_Group_To_Tab = FND_API.G_TRUE THEN
    Assign_Ind_Group_To_Tab (
      p_commit              => FND_API.G_FALSE
     ,p_Indicator           => p_Indicator
     ,p_New_Indicator_Group => p_New_Indicator_Group
     ,p_Old_Indicator_Group => l_Old_Indicator_Group
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscMovIndicatorSavePnt;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscMovIndicatorSavePnt;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscMovIndicatorSavePnt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Move_Indicator ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Move_Indicator ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscMovIndicatorSavePnt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Move_Indicator ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Move_Indicator ';
    END IF;
END Move_Indicator;

/************************************************************************************
--	API name 	: Reposition_Indicator
--	Type		: Public
--	Function	:
--      This API is used to reposition the indicators in a group
************************************************************************************/
PROCEDURE Reposition_Indicator (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Indicator                IN    NUMBER
, p_New_Indicator_Group      IN    NUMBER
, p_New_Position             IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
) IS
  l_Bsc_Kpi_Entity_Rec BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Display_Order bsc_kpis_b.disp_order%TYPE := 1;
  l_Current_Disp_Order  bsc_kpis_b.disp_order%TYPE := 1;
  CURSOR c_Group_Indicators IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    ind_group_id = p_New_Indicator_Group
    AND prototype_flag <> 2
    AND share_flag <> 2
    AND BSC_BIS_KPI_CRUD_PUB.is_KPI_EndToEnd_KPI(short_name) <> 'T'
  ORDER BY
    disp_order,indicator;

  CURSOR c_shared_obj(p_Indicator_id NUMBER) IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    source_indicator = p_Indicator_id
    AND share_flag = 2
    AND prototype_flag <> 2;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscRepositionIndicatorSavePnt;

  IF l_Display_Order = p_New_Position THEN
    l_Display_Order := l_Display_Order + 1;
  END IF;

  FOR cInd IN  c_Group_Indicators LOOP
    IF p_Indicator = cInd.indicator THEN
      l_Current_Disp_Order := p_New_Position;
    ELSE
      l_Current_Disp_Order := l_Display_Order;
      l_Display_Order := l_Display_Order + 1;
      IF l_Display_Order = p_New_Position THEN
        l_Display_Order := l_Display_Order + 1;
      END IF;
    END IF;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id :=  cInd.Indicator;
    BSC_KPI_PVT.Retrieve_Kpi(
      p_commit             => FND_API.G_FALSE
     ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
     ,x_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
     ,x_return_status      => x_return_status
     ,x_msg_count          => x_msg_count
     ,x_msg_data           => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order := l_Current_Disp_Order;
    BSC_KPI_PVT.Update_Kpi(
      p_commit             => FND_API.G_FALSE
     ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
     ,x_return_status      => x_return_status
     ,x_msg_count          => x_msg_count
     ,x_msg_data           => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    FOR cd IN c_shared_obj(cInd.indicator) LOOP
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id :=  cd.Indicator;
      BSC_KPI_PVT.Retrieve_Kpi(
        p_commit             => FND_API.G_FALSE
       ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
       ,x_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order := l_Current_Disp_Order;
      BSC_KPI_PVT.Update_Kpi(
        p_commit             => FND_API.G_FALSE
       ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscRepositionIndicatorSavePnt;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscRepositionIndicatorSavePnt;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscRepositionIndicatorSavePnt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Reposition_Indicator ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Reposition_Indicator ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscRepositionIndicatorSavePnt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Reposition_Indicator ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Reposition_Indicator ';
    END IF;
END Reposition_Indicator;

/************************************************************************************
--	API name 	: Move_Indicator_UI_Wrap
--	Type		: Public
--	Function	:
--      This API is used to move an indicator from one indicator group to another
--      This can also be used to reposition the indicator with the same group
--      1. Update Group properties if earlier group type is 1
--         (Color Box above objective label) and the kpi count in the objective
--         is already 1
--      2. Update the Ind_Group_Id to the new group
************************************************************************************/
PROCEDURE Move_Indicator_UI_Wrap (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Indicator                IN    NUMBER
, p_New_Indicator_Group      IN    NUMBER
, p_New_Position             IN    NUMBER
, p_Time_Stamp               IN    VARCHAR2 := NULL
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)
IS
  l_old_group_id bsc_kpis_b.ind_group_id%TYPE;
  l_Bsc_Kpi_Entity_Rec BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  CURSOR c_shared_obj IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    source_indicator = p_Indicator
    AND share_flag = 2
    AND prototype_flag <> 2;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscMovIndicatorUIWrap;

  BSC_BIS_LOCKS_PUB.Lock_Kpi
  (      p_Kpi_Id             =>  p_Indicator
     ,   p_time_stamp         =>  p_time_stamp
     ,   p_Full_Lock_Flag     =>  FND_API.G_FALSE
     ,   x_return_status      =>  x_return_status
     ,   x_msg_count          =>  x_msg_count
     ,   x_msg_data           =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_old_group_id := Get_Ind_Group_Id(p_Indicator);
  IF l_old_group_id <> p_New_Indicator_Group THEN
    -- A warning should be displayed in the UI
    Update_Kpi_Group_Properties (
      p_commit              => FND_API.G_FALSE
     ,p_New_Indicator_Group => p_New_Indicator_Group
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    Move_Indicator (
      p_commit              => FND_API.G_FALSE
     ,p_Indicator           => p_Indicator
     ,p_New_Indicator_Group => p_New_Indicator_Group
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    FOR cd in c_shared_obj LOOP
      Move_Indicator (
        p_commit              => FND_API.G_FALSE
       ,p_Indicator           => cd.indicator
       ,p_New_Indicator_Group => p_New_Indicator_Group
       ,x_return_status       => x_return_status
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF;

  Reposition_Indicator (
    p_commit              => FND_API.G_FALSE
   ,p_Indicator           => p_Indicator
   ,p_New_Indicator_Group => p_New_Indicator_Group
   ,p_New_Position        => p_New_Position
   ,x_return_status       => x_return_status
   ,x_msg_count           => x_msg_count
   ,x_msg_data            => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Indicator;
  BSC_KPI_PUB.Update_Kpi_Time_Stamp (
    p_commit              => FND_API.G_FALSE
   ,p_Bsc_Kpi_Entity_Rec  => l_Bsc_Kpi_Entity_Rec
   ,x_return_status       => x_return_status
   ,x_msg_count           => x_msg_count
   ,x_msg_data            => x_msg_data
  );
  FOR cd in c_shared_obj LOOP
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.Indicator;
    BSC_KPI_PUB.Update_Kpi_Time_Stamp (
      p_commit              => FND_API.G_FALSE
     ,p_Bsc_Kpi_Entity_Rec  => l_Bsc_Kpi_Entity_Rec
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
    );
  END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscMovIndicatorUIWrap;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscMovIndicatorUIWrap;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscMovIndicatorUIWrap;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Move_Indicator_UI_Wrap ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Move_Indicator_UI_Wrap ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscMovIndicatorUIWrap;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Move_Indicator_UI_Wrap ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Move_Indicator_UI_Wrap ';
    END IF;
END Move_Indicator_UI_Wrap;


/************************************************************************************
--	API name 	: Validate_Indicator_Copy
--	Type		: Public
--	Function	:
--      This API is used to validate whether copy is allowed or not
--      Will check the following conditions
--      1. Whether the indicator is an EDW type
--      2. Whether the indicator has PMF measures attached
--      Both the above conditions will be invalid if the copy is across systems
************************************************************************************/
PROCEDURE Validate_Indicator_Copy (
  p_Source_Indicator         IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
) IS

l_EDW_Flag bsc_kpis_b.edw_flag%TYPE;
l_PMF_Meas_Cnt NUMBER := 0;
l_sql VARCHAR2(32000);
TYPE c_cur_type IS REF CURSOR;
c_cursor c_cur_type;
l_indicator_type bsc_kpis_b.indicator_type%TYPE;
l_config_type bsc_kpis_b.config_type%TYPE;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscValIndCopyUIWrap;

  IF BSC_DESIGNER_PVT.g_DbLink_Name IS NOT NULL THEN

    l_sql := BSC_DESIGNER_PVT.Format_DbLink_String(' SELECT NVL(edw_flag,0) FROM bsc_kpis_b');
    l_sql := l_sql || ' WHERE indicator = :1';
    OPEN c_cursor FOR l_sql USING p_Source_Indicator;
    FETCH c_cursor INTO l_EDW_Flag;
    CLOSE c_cursor;
    IF l_EDW_Flag <> 0 THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CAN_NOT_COPY_EDW_KPI');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT indicator_type,config_type FROM bsc_kpis_b');
    l_sql := l_sql || ' WHERE indicator = :1';
    OPEN c_cursor FOR l_sql USING p_Source_Indicator;
    FETCH c_cursor INTO l_indicator_type,l_config_type;
    CLOSE c_cursor;

    IF NOT (l_indicator_type = 1 AND l_config_type = 7) THEN
      l_sql := BSC_DESIGNER_PVT.Format_DbLink_String(' SELECT COUNT(1) FROM bsc_kpi_analysis_measures_b');
      l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' km ,bsc_sys_datasets_b');
      l_sql := l_sql || ' ds WHERE km.indicator = :1 AND ds.dataset_id = km.dataset_id AND ds.source = :2';
      OPEN c_cursor FOR l_sql USING p_Source_Indicator, 'PMF';
      FETCH c_cursor INTO l_PMF_Meas_Cnt;
      CLOSE c_cursor;
      IF l_PMF_Meas_Cnt > 0 THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_CAN_NOT_COPY_PMF_KPI');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscValIndCopyUIWrap;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscValIndCopyUIWrap;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscValIndCopyUIWrap;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Validate_Indicator_Copy ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Validate_Indicator_Copy ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscValIndCopyUIWrap;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Validate_Indicator_Copy ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Validate_Indicator_Copy ';
    END IF;
END Validate_Indicator_Copy;

/************************************************************************************
--	API name 	: Lock_Target_Entities
--	Type		: Private
--	Function	:
--      All the measures, dimension objects, dimensions , periodicities, calendars
--      that will be used have to be locked
************************************************************************************/
PROCEDURE Lock_Target_Entities (
  p_DataSet_Map      IN    FND_TABLE_OF_NUMBER
, p_DimLevel_Map     IN    FND_TABLE_OF_NUMBER
, p_DimGroup_Map     IN    FND_TABLE_OF_NUMBER
, p_Periodicity_Map  IN    FND_TABLE_OF_NUMBER
, p_Calendar         IN    NUMBER
, p_Time_Stamp       IN    VARCHAR2 := NULL
, x_return_status    OUT   NOCOPY  VARCHAR2
, x_msg_count        OUT   NOCOPY  NUMBER
, x_msg_data         OUT   NOCOPY  VARCHAR2
) IS
  i NUMBER;
  l_sql VARCHAR2(32000);
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_DataSet_Map.COUNT LOOP
    BSC_BIS_LOCKS_PUB.Lock_Dataset (
      p_dataset_id     => p_DataSet_Map(i)
     ,p_time_stamp     => p_Time_Stamp
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END LOOP;

 FOR i IN 1..p_DimLevel_Map.COUNT LOOP
    BSC_BIS_LOCKS_PUB.Lock_Dim_Level (
      p_dim_level_id   => p_DimLevel_Map(i)
     ,p_time_stamp     => p_Time_Stamp
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END LOOP;

 FOR i IN 1..p_DimGroup_Map.COUNT LOOP
    BSC_BIS_LOCKS_PUB.Lock_Dim_Group (
      p_dim_group_id   => p_DimGroup_Map(i)
     ,p_time_stamp     => p_Time_Stamp
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END LOOP;

 FOR i IN 1..p_Periodicity_Map.COUNT LOOP
    BSC_BIS_LOCKS_PUB.Lock_Periodicity (
      p_Periodicity_Id     => p_Periodicity_Map(i)
     ,p_time_stamp     => p_Time_Stamp
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END LOOP;

 BSC_BIS_LOCKS_PUB.Lock_Calendar (
   p_Calendar_Id     => p_Calendar
  ,p_time_stamp     => p_Time_Stamp
  ,x_return_status  => x_return_status
  ,x_msg_count      => x_msg_count
  ,x_msg_data       => x_msg_data
 );
 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.Lock_Target_Entities ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.Lock_Target_Entities ';
    END IF;
END Lock_Target_Entities;

/************************************************************************************
 Function    :   Create_Kpi_Access_For_Resp
 Description :   This function will assign a objectitve to a given responsibility
***********************************************************************************/
PROCEDURE Create_Kpi_Access_Wrap(
  p_commit                       IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Comma_Sep_Resposibility_Key  IN          VARCHAR2
 ,p_Indicator_Id                 IN          NUMBER
 ,x_return_status                OUT NOCOPY  VARCHAR2
 ,x_msg_count                    OUT NOCOPY  NUMBER
 ,x_msg_data                     OUT NOCOPY  VARCHAR2
)IS
l_Bsc_Kpi_Entity_Rec  BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Indicator_Id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id := FND_GLOBAL.RESP_ID;
  l_Bsc_Kpi_Entity_Rec.Created_By := FND_GLOBAL.USER_ID;
  l_Bsc_Kpi_Entity_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
  l_Bsc_Kpi_Entity_Rec.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
  l_Bsc_Kpi_Entity_Rec.Bsc_Resp_Start_Date := SYSDATE;
  l_Bsc_Kpi_Entity_Rec.Bsc_Resp_End_Date := NULL;

  BSC_KPI_PUB.Create_Kpi_Access_For_Resp
  ( p_commit              => p_commit
  , p_Comma_Sep_Resposibility_Key => p_Comma_Sep_Resposibility_Key
  , p_Bsc_Kpi_Entity_Rec  => l_Bsc_Kpi_Entity_Rec
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
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
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Create_Kpi_Access_Wrap ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Create_Kpi_Access_Wrap ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Create_Kpi_Access_Wrap ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Create_Kpi_Access_Wrap ';
    END IF;
END Create_Kpi_Access_Wrap;


/************************************************************************************
--	API name 	: Copy_Analysis_Measures
--	Type		: Private
--	Function	:
--      Maps the datasets to the analysis measures of the target indicator
************************************************************************************/

PROCEDURE Copy_Analysis_Measures(
  p_commit                   IN          VARCHAR2 := FND_API.G_FALSE
, p_Source_Indicator         IN    NUMBER
, p_Target_Indicator         IN    NUMBER
, p_Old_DataSet_Map          IN    FND_TABLE_OF_NUMBER
, p_New_DataSet_Map          IN    FND_TABLE_OF_NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
TYPE c_cur_type IS REF CURSOR;
c_Ana_Meas c_cur_type;
l_analysis_option0 bsc_kpi_analysis_measures_b.analysis_option0%TYPE;
l_analysis_option1 bsc_kpi_analysis_measures_b.analysis_option1%TYPE;
l_analysis_option2 bsc_kpi_analysis_measures_b.analysis_option2%TYPE;
l_series_id bsc_kpi_analysis_measures_b.series_id%TYPE;
l_dataset_id bsc_kpi_analysis_measures_b.dataset_id%TYPE;

l_sql VARCHAR2(32000);

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscCopyIndicAnaMeasPub;

  l_sql := 'SELECT analysis_option0 ,analysis_option1 ,analysis_option2,series_id';
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(',dataset_id FROM  bsc_kpi_analysis_measures_b');
  l_sql := l_sql || 'WHERE indicator = :1 ORDER BY analysis_option0';
  l_sql := l_sql || ',analysis_option1 ,analysis_option2 ,series_id';
  OPEN c_Ana_Meas FOR l_sql USING p_Source_Indicator;
  LOOP
    FETCH c_Ana_Meas INTO l_analysis_option0,l_analysis_option1, l_analysis_option2, l_series_id,l_dataset_id;
    EXIT WHEN c_Ana_Meas%NOTFOUND;
    FOR i IN 1..p_Old_DataSet_Map.COUNT LOOP
      IF p_Old_DataSet_Map(i) = l_dataset_id THEN
        UPDATE
          bsc_kpi_analysis_measures_b
        SET
          dataset_id = p_New_DataSet_Map(i)
        WHERE
          indicator = p_Target_Indicator
          AND analysis_option0 =  l_analysis_option0
          AND analysis_option1 =  l_analysis_option1
          AND analysis_option2 =  l_analysis_option2
          AND series_id = l_series_id;

        IF p_Old_DataSet_Map(i) <> p_New_DataSet_Map(i) AND
           BSC_DESIGNER_PVT.g_DbLink_Name IS NULL THEN
          UPDATE bsc_kpi_analysis_measures_tl km
          SET name = (SELECT d.name FROM bsc_sys_datasets_tl d WHERE
                      d.dataset_id = p_New_DataSet_Map(i) AND d.language = km.language),
          help = (SELECT d.help FROM bsc_sys_datasets_tl d WHERE
                      d.dataset_id = p_New_DataSet_Map(i) AND d.language = km.language)
          WHERE indicator = p_Target_Indicator;
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;
  CLOSE c_Ana_Meas;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyIndicAnaMeasPub;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyIndicAnaMeasPub;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyIndicAnaMeasPub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Copy_Analysis_Measures ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Copy_Analysis_Measures ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyIndicAnaMeasPub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Copy_Analysis_Measures ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Copy_Analysis_Measures ';
    END IF;
END Copy_Analysis_Measures;

/************************************************************************************
--	API name 	: Update_Annual_Current_Period
--	Type		: Private
--	Function	:
--      This checks whether there is any annual periodicity in the objective.
--      It will check the current period for the new periodicity and
************************************************************************************/

PROCEDURE Update_Annual_Current_Period(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Target_Indicator         IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS

CURSOR c_Periodicity IS
SELECT
  sp.periodicity_id ,
  sc.fiscal_year
FROM
  bsc_kpi_periodicities kp,
  bsc_sys_periodicities_vl sp,
  bsc_sys_calendars_vl sc
WHERE
  kp.indicator = p_Target_Indicator AND
  sp.periodicity_id = kp.periodicity_id AND
  sp.periodicity_type = 1 AND
  sc.calendar_id = sp.calendar_id ;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscUpdAnnCurPeriod;

  FOR cd IN c_Periodicity LOOP
    UPDATE
      bsc_kpi_periodicities
    SET
      current_period = cd.fiscal_year
    WHERE
      indicator = p_Target_Indicator AND
      periodicity_id = cd.periodicity_id ;
  END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscUpdAnnCurPeriod;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscUpdAnnCurPeriod;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscUpdAnnCurPeriod;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Update_Annual_Current_Period ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Update_Annual_Current_Period ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscUpdAnnCurPeriod;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Update_Annual_Current_Period ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Update_Annual_Current_Period ';
    END IF;
END Update_Annual_Current_Period;

/************************************************************************************
--	API name 	: Copy_Periodicities
--	Type		: Private
--	Function	:
--      Maps the periodicities from the source objective to periodicities in target
--      system
************************************************************************************/

PROCEDURE Copy_Periodicities(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Source_Indicator         IN    NUMBER
, p_Target_Indicator         IN    NUMBER
, p_Target_Calendar          IN    NUMBER
, p_Old_Periodicities        IN    FND_TABLE_OF_NUMBER
, p_New_Periodicities        IN    FND_TABLE_OF_NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
l_Source_Per_Type bsc_sys_periodicities.periodicity_type%TYPE;
l_Target_Per_Type bsc_sys_periodicities.periodicity_type%TYPE;
l_sql VARCHAR2(32000);
TYPE c_cur_type IS REF CURSOR;
c_cursor c_cur_type;
l_Source_Calendar bsc_kpis_b.calendar_id%TYPE;
l_Default_Periodicity bsc_kpis_b.periodicity_id%TYPE;
l_New_Periodicity     bsc_kpis_b.periodicity_id%TYPE := NULL;
l_Count NUMBER := 0;
l_Deleted_Periodicities    FND_TABLE_OF_NUMBER;
l_Periodicity_Id bsc_sys_periodicities.periodicity_id%TYPE;
l_Found BOOLEAN := FALSE;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscCopyIndicPeriodsPub;

  IF p_New_Periodicities.COUNT = 0 THEN
    Update_Annual_Current_Period (
      p_commit           => FND_API.G_FALSE
     ,p_Target_Indicator => p_Target_Indicator
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    RETURN;
  END IF;

  l_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT periodicity_id FROM bsc_kpi_periodicities');
  l_sql := l_sql || 'WHERE indicator = :1';
  l_Deleted_Periodicities := FND_TABLE_OF_NUMBER();
  OPEN c_cursor FOR l_sql USING p_Source_Indicator;
  LOOP
    FETCH c_cursor INTO l_Periodicity_Id;
    EXIT WHEN c_cursor%NOTFOUND;
    l_Found := FALSE;
    FOR i IN 1..p_Old_Periodicities.COUNT LOOP
      IF p_Old_Periodicities(i) = l_Periodicity_Id THEN
        l_Found := TRUE;
      END IF;
    END LOOP;
    IF NOT l_Found THEN
      l_Deleted_Periodicities.EXTEND(1);
      l_Deleted_Periodicities(l_Deleted_Periodicities.LAST) := l_Periodicity_Id;
    END IF;
  END LOOP;
  CLOSE c_cursor;

  IF l_Deleted_Periodicities.COUNT > 0 THEN
    l_sql := ' DELETE FROM bsc_kpi_periodicities';
    l_sql := l_sql || ' WHERE indicator = :1 AND periodicity_id IN (' ;
    FOR i IN 1..l_Deleted_Periodicities.COUNT LOOP
      l_sql := l_sql || l_Deleted_Periodicities(i) || ',';
    END LOOP;
    l_sql := SUBSTR(l_sql, 0, LENGTH(l_sql) - 1);
    l_sql := l_sql || ')';
   EXECUTE IMMEDIATE l_sql USING p_Target_Indicator;
  END IF;

  FOR i IN 1..p_Old_Periodicities.COUNT LOOP
    -- If it is mapped to some other periodicity
    IF p_Old_Periodicities(i) <> p_New_Periodicities(i) THEN
      UPDATE
        bsc_kpi_periodicities
      SET
        periodicity_id = p_New_Periodicities(i) ,
        display_order = (i - 1)
      WHERE
        indicator = p_Target_Indicator AND
        periodicity_id = p_Old_Periodicities(i);
    END IF;

    l_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT calendar_id FROM bsc_kpis_b');
    l_sql := l_sql || 'WHERE indicator = :1';

    OPEN c_cursor FOR l_sql USING p_Source_Indicator;
    FETCH c_cursor INTO l_Source_Calendar;
    CLOSE c_cursor;

    l_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT periodicity_type FROM bsc_sys_periodicities');
    l_sql := l_sql || 'WHERE calendar_id = :1 AND periodicity_id = :2 ';

    OPEN c_cursor FOR l_sql USING l_Source_Calendar, p_Old_Periodicities(i);
    FETCH c_cursor INTO l_Source_Per_Type;
    CLOSE c_cursor;

    SELECT
      periodicity_type
    INTO
      l_Target_Per_Type
    FROM
      bsc_sys_periodicities
    WHERE
      calendar_id = p_Target_Calendar AND
      periodicity_id = p_New_Periodicities(i);


    IF l_Source_Per_Type <> l_Target_Per_Type THEN
      l_sql := ' UPDATE bsc_kpi_periodicities';
      l_sql := l_sql || ' SET viewport_flag = 0';
      IF l_Target_Per_Type = 1  THEN
        l_sql := l_sql || ' , num_of_years = 2 , previous_years = 1 ';
      ELSE
        l_sql := l_sql || ' , current_period = 1';
        IF l_Source_Per_Type = 1 THEN
          l_sql := l_sql || ' , num_of_years = 0 , previous_years = 0 ';
        END IF;
      END IF;
      l_sql := l_sql || 'WHERE indicator = :1 AND periodicity_id = :2';

      EXECUTE IMMEDIATE l_sql USING p_Target_Indicator,p_New_Periodicities(i);
    END IF;
  END LOOP;

  Update_Annual_Current_Period(
    p_commit           => FND_API.G_FALSE
   ,p_Target_Indicator => p_Target_Indicator
   ,x_return_status    => x_return_status
   ,x_msg_count        => x_msg_count
   ,x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  SELECT
    periodicity_id
  INTO
    l_Default_Periodicity
  FROM
    bsc_kpis_b
  WHERE
    indicator = p_Target_Indicator;

  FOR i IN 1..p_Old_Periodicities.COUNT LOOP
    IF p_Old_Periodicities(i) = l_Default_Periodicity THEN
      l_New_Periodicity := p_New_Periodicities(i);
    END IF;
  END LOOP;

  IF l_New_Periodicity IS NULL THEN
    SELECT
      periodicity_id
    INTO
      l_New_Periodicity
    FROM
      bsc_kpi_periodicities
    WHERE
      indicator = p_Target_Indicator AND
      ROWNUM < 2
    ORDER BY
      display_order;
  END IF;

  UPDATE
    bsc_kpis_b
  SET
    periodicity_id = l_New_Periodicity ,
    calendar_id = p_Target_Calendar
  WHERE
    indicator = p_Target_Indicator;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyIndicPeriodsPub;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyIndicPeriodsPub;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyIndicPeriodsPub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Copy_Periodicities ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Copy_Periodicities ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyIndicPeriodsPub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Copy_Periodicities ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Copy_Periodicities ';
    END IF;
END Copy_Periodicities;


/************************************************************************************
--	API name 	: Update_Bsc_Kpi_Props
--	Type		: Private
--	Function	:
--
************************************************************************************/

PROCEDURE Update_Bsc_Kpi_Props(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Target_Indicator         IN    NUMBER
, p_Property_code            IN    VARCHAR2
, p_Property_value           IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
l_Count NUMBER := 0;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscCopyUpdKpiProps;

  l_Count := 0;
  SELECT
    COUNT(1)
  INTO
    l_Count
  FROM
    bsc_kpi_properties
  WHERE
    indicator = p_Target_Indicator AND
    UPPER(property_code) = p_Property_code ;

  IF l_Count = 0 THEN
    INSERT INTO bsc_kpi_properties (
      indicator
     ,property_code
     ,property_value)
    VALUES
      (p_Target_Indicator
      ,p_Property_code
      ,p_Property_value);
  ELSE
    UPDATE
      bsc_kpi_properties
    SET
      property_value = p_Property_value
    WHERE
      indicator = p_Target_Indicator AND
      property_code = p_Property_code;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyUpdKpiProps;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyUpdKpiProps;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyUpdKpiProps;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Update_Bsc_Kpi_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Update_Bsc_Kpi_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyUpdKpiProps;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Update_Bsc_Kpi_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Update_Bsc_Kpi_Props ';
    END IF;
END Update_Bsc_Kpi_Props;

/************************************************************************************
--	API name 	: Copy_Dim_Level_Props
--	Type		: Private
--	Function	:
--      Creates the entries in bsc_kpi_dim_level_properties
************************************************************************************/

PROCEDURE Copy_Dim_Level_Props(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Source_Indicator         IN    NUMBER
, p_Target_Indicator         IN    NUMBER
, p_Old_Dim_Levels           IN    FND_TABLE_OF_NUMBER
, p_New_Dim_Levels           IN    FND_TABLE_OF_NUMBER
, p_Old_Dim_Groups           IN    FND_TABLE_OF_NUMBER
, p_New_Dim_Groups           IN    FND_TABLE_OF_NUMBER
, p_Region_Code              IN    VARCHAR2
, p_Old_Region_Code          IN    VARCHAR2
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
l_sql VARCHAR2(32000);
TYPE c_cur_type IS REF CURSOR;
c_Dim_Group_Info c_cur_type;
l_Short_Name bsc_sys_dim_groups_vl.short_name%TYPE;

l_dim_set_id bsc_kpi_dim_groups.dim_set_id%TYPE;
l_dim_group_id bsc_kpi_dim_groups.dim_group_id%TYPE;
l_dim_group_index bsc_kpi_dim_groups.dim_group_index%TYPE;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscCopyDimLevProps;
  IF p_Region_Code IS NOT NULL THEN -- Simulation tree
     BSC_SIMULATION_VIEW_PVT.Copy_Dimension_Group (
        p_commit           =>  FND_API.G_FALSE
       ,p_Indicator        =>  p_Target_Indicator
       ,p_Region_Code      =>  p_Region_Code
       ,p_Old_Region_Code  =>  p_Old_Region_Code
       ,p_New_Dim_Levels   =>  p_New_Dim_Levels
       ,p_DbLink_Name      =>  BSC_DESIGNER_PVT.g_DbLink_Name
       ,x_return_status    =>  x_return_status
       ,x_msg_count        =>  x_msg_count
       ,x_msg_data         =>  x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions(
       p_commit             => FND_API.G_FALSE
      ,p_kpi_id             => p_Target_Indicator
      ,p_dim_set_id         => 0
      ,p_assign_dim_names   => p_Region_Code
      ,p_unassign_dim_names => NULL
      ,p_time_stamp         => NULL
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  ELSE
    l_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT dim_set_id,dim_group_id,dim_group_index FROM bsc_kpi_dim_groups');
    l_sql := l_sql || 'WHERE indicator = :1 ORDER BY dim_set_id,dim_group_index';
    OPEN c_Dim_Group_Info FOR l_sql USING p_Source_Indicator;
    LOOP
      FETCH c_Dim_Group_Info INTO l_dim_set_id, l_dim_group_id, l_dim_group_index;
      EXIT WHEN c_Dim_Group_Info%NOTFOUND;
      l_Short_Name := NULL;
      FOR i IN 1..p_Old_Dim_Groups.COUNT LOOP
        IF p_Old_Dim_Groups(i) = l_dim_group_id THEN
          SELECT
            short_name
          INTO
            l_Short_Name
          FROM
            bsc_sys_dim_groups_vl
          WHERE
            dim_group_id = p_New_Dim_Groups(i);
          EXIT;
        END IF;
      END LOOP;
      IF l_Short_Name IS NOT NULL THEN
        BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions(
          p_commit             =>  FND_API.G_FALSE
         ,p_kpi_id             =>  p_Target_Indicator
         ,p_dim_set_id         => l_dim_set_id
         ,p_assign_dim_names   => l_Short_Name
         ,p_unassign_dim_names => NULL
         ,p_time_stamp         => NULL
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
    CLOSE c_Dim_Group_Info;

    l_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT distinct dim_set_id FROM bsc_kpi_dim_levels_vl');
    l_sql := l_sql || 'WHERE indicator = :1 MINUS SELECT distinct dim_set_id FROM bsc_kpi_dim_levels_vl';
    l_sql := l_sql || ' WHERE indicator = :2';
    OPEN c_Dim_Group_Info FOR l_sql USING p_Source_Indicator,p_Target_Indicator;
    LOOP
      FETCH c_Dim_Group_Info INTO l_dim_set_Id;
      EXIT WHEN c_Dim_Group_Info%NOTFOUND;
      IF l_dim_set_Id IS NOT NULL THEN
        BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions(
          p_commit             =>  FND_API.G_FALSE
         ,p_kpi_id             =>  p_Target_Indicator
         ,p_dim_set_id         => l_dim_set_id
         ,p_assign_dim_names   => NULL
         ,p_unassign_dim_names => NULL
         ,p_time_stamp         => NULL
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
    CLOSE c_Dim_Group_Info;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyDimLevProps;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyDimLevProps;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyDimLevProps;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Copy_Dim_Level_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Copy_Dim_Level_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyDimLevProps;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Copy_Dim_Level_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Copy_Dim_Level_Props ';
    END IF;
END Copy_Dim_Level_Props;

/************************************************************************************
--	API name 	: Is_Numeric_Field_Equal
--	Type		: Private
--	Function	:
--
************************************************************************************/

FUNCTION Is_Numeric_Field_Equal(
 p_Old_Value NUMBER
,p_New_Value NUMBER
) RETURN BOOLEAN IS

BEGIN

  IF (p_Old_Value IS NULL AND p_New_Value IS NOT NULL) OR
     (p_Old_Value IS NOT NULL AND p_New_Value IS  NULL) OR
     (p_New_Value <> p_Old_Value) THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN TRUE;
END Is_Numeric_Field_Equal;

/************************************************************************************
--	API name 	: Is_Varchar2_Field_Equal
--	Type		: Private
--	Function	:
--
************************************************************************************/

FUNCTION Is_Varchar2_Field_Equal(
 p_Old_Value VARCHAR2
,p_New_Value VARCHAR2
) RETURN BOOLEAN IS

BEGIN

  IF (p_Old_Value IS NULL AND p_New_Value IS NOT NULL) OR
     (p_Old_Value IS NOT NULL AND p_New_Value IS  NULL) OR
     (p_New_Value <> p_Old_Value) THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN TRUE;
END Is_Varchar2_Field_Equal;


/************************************************************************************
--	API name 	: Check_Key_Item_Props
--	Type		: Private
--	Function	:
--      Creates the entries in bsc_kpi_dim_level_properties
************************************************************************************/

PROCEDURE Check_Key_Item_Props(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Source_Indicator         IN    NUMBER
, p_Target_Indicator         IN    NUMBER
, p_Old_Dim_Levels           IN    FND_TABLE_OF_NUMBER
, p_New_Dim_Levels           IN    FND_TABLE_OF_NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
l_sql VARCHAR2(32000);
TYPE c_cur_type IS REF CURSOR;
c_cursor c_cur_type;
l_config_change BOOLEAN := FALSE;
i NUMBER;
l_Old_Dim_Level_Id bsc_sys_dim_levels_b.dim_level_id%TYPE;

CURSOR c_Check_Config_Change IS
SELECT
  kl.dim_set_id,dim_level_index,kl.level_table_name,kl.level_pk_col,dl.dim_level_id,
  parent_level_index,parent_level_rel,table_relation,
  parent_level_index2,parent_level_rel2
FROM
  bsc_kpi_dim_levels_b kl,
  bsc_sys_dim_levels_b dl
WHERE
  kl.indicator = p_Target_Indicator  AND
  kl.level_table_name = dl.level_Table_name
ORDER BY
  dim_set_id,dim_level_index;
l_rec c_Check_Config_Change%ROWTYPE;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscChkKeyItemProps;

  l_sql := 'SELECT kl.dim_set_id,dim_level_index,kl.level_table_name,kl.level_pk_col,dl.dim_level_id,';
  l_sql := l_sql || 'parent_level_index,parent_level_rel,table_relation,';
  l_sql := l_sql || 'parent_level_index2,parent_level_rel2 ';
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String('FROM bsc_kpi_dim_levels_b');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' kl ,bsc_sys_dim_levels_b');
  l_sql := l_sql || ' dl WHERE kl.indicator = :1 AND dl.dim_level_id = :2 AND kl.dim_set_id = :3 AND ';
  l_sql := l_sql || ' kl.level_table_name = dl.level_Table_name ORDER BY dim_set_id,dim_level_index ';

  FOR cd IN c_Check_Config_Change LOOP
    l_Old_Dim_Level_Id := NULL;
    FOR i IN 1..p_New_Dim_Levels.COUNT LOOP
      IF p_New_Dim_Levels(i) = cd.dim_level_id THEN
        l_Old_Dim_Level_Id := p_Old_Dim_Levels(i);
      END IF;
    END LOOP;
    IF l_Old_Dim_Level_Id IS NOT NULL THEN
      OPEN c_cursor FOR l_sql USING p_Source_Indicator, l_Old_Dim_Level_Id , cd.dim_set_id;
      LOOP
        FETCH c_cursor INTO l_rec;
        EXIT WHEN c_cursor%notfound;
        IF NOT Is_Varchar2_Field_Equal(l_rec.level_table_name,cd.level_table_name) OR
           NOT Is_Varchar2_Field_Equal(l_rec.level_pk_col,cd.level_pk_col) OR
           NOT Is_Varchar2_Field_Equal(l_rec.parent_level_rel,cd.parent_level_rel) OR
           NOT Is_Varchar2_Field_Equal(l_rec.table_relation,cd.table_relation) OR
           NOT Is_Varchar2_Field_Equal(l_rec.parent_level_rel2,cd.parent_level_rel2) OR
           NOT Is_Numeric_Field_Equal(l_rec.parent_level_index,cd.parent_level_index) OR
           NOT Is_Numeric_Field_Equal(l_rec.parent_level_index2,cd.parent_level_index2) THEN

          l_config_change := TRUE ;

        END IF;
     END LOOP;
     CLOSE c_cursor;
   END IF;
  END LOOP;

  IF l_config_change THEN
    UPDATE
      bsc_kpi_dim_level_properties
    SET
      default_key_value = NULL
     ,target_level=1
    WHERE
      indicator = p_Target_Indicator;

    UPDATE
      bsc_kpi_dim_levels_b
    SET
      default_key_value = NULL
     ,target_level=1
    WHERE
      indicator = p_Target_Indicator;

/*    Update_Bsc_Kpi_Props (
       p_commit             =>  FND_API.G_FALSE
      ,p_Target_Indicator   =>  p_Target_Indicator
      ,p_Property_code      =>  'DB_TRANSFORM'
      ,p_Property_value      => 2
      ,x_return_status      =>  x_return_status
      ,x_msg_count          =>  x_msg_count
      ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;*/

    BSC_DESIGNER_PVT.ActionFlag_Change( p_Target_Indicator, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
  ELSE
    l_sql := 'UPDATE bsc_kpi_dim_levels_b tar SET tar.default_key_value = (SELECT src.default_key_value ';
    l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String('FROM bsc_kpi_dim_levels_b');
    l_sql := l_sql || '  src WHERE src.indicator = :1 AND src.dim_set_id = tar.dim_set_id AND';
    l_sql := l_sql || ' src.dim_level_index = tar.dim_level_index) WHERE indicator = :2';
    EXECUTE IMMEDIATE l_sql USING p_Source_Indicator,p_Target_Indicator;

    l_sql := 'UPDATE bsc_kpi_dim_level_properties tar SET tar.default_key_value = (SELECT src.default_key_value ';
    l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String('FROM bsc_kpi_dim_level_properties');
    l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' src, bsc_sys_dim_levels_b');
    l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' sys, bsc_kpi_dim_levels_b');
    l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' dl WHERE src.indicator = dl.indicator ');
    l_sql := l_sql || ' AND src.dim_level_id = sys.dim_level_id AND sys.level_table_name = dl.level_table_name AND ';
    l_sql := l_sql || ' src.dim_set_id = dl.dim_set_id AND src.indicator = :1 AND src.dim_set_id = tar.dim_set_id AND';
    l_sql := l_sql || ' sys.dim_level_id = tar.dim_level_id) WHERE tar.indicator = :2';
    EXECUTE IMMEDIATE l_sql USING p_Source_Indicator,p_Target_Indicator;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscChkKeyItemProps;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscChkKeyItemProps;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscChkKeyItemProps;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_Key_Item_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Check_Key_Item_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscChkKeyItemProps;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_Key_Item_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Check_Key_Item_Props ';
    END IF;
END Check_Key_Item_Props;


/************************************************************************************
--	API name 	: Check_Color_By_Total_Props
--	Type		: Private
--	Function	:
--      Creates the entries in bsc_kpi_dim_level_properties
************************************************************************************/

PROCEDURE Check_Color_By_Total_Props(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Target_Indicator         IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
l_dim_set_id bsc_kpi_dim_sets_vl.dim_set_id%TYPE;
l_count NUMBER := 0;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscChkColorByTotal;

  SELECT
    dim_set_id
  INTO
    l_dim_set_id
  FROM
    bsc_oaf_analysys_opt_comb_v da,
    bsc_db_basic_dim_sets_v ds
  WHERE
    ds.indicator = da.indicator AND
    ds.a0 = da.analysis_option0 AND
    ds.a1 = da.analysis_option1 AND
    ds.a2 = da.analysis_option2 AND
    ds.series_id = da.series_id AND
    da.default_flag = 1 AND
    ds.indicator = p_Target_Indicator;


  IF l_dim_set_id IS NOT NULL THEN
    SELECT
      COUNT(1)
    INTO
      l_count
    FROM
      bsc_kpi_dim_levels_b
    WHERE
      indicator = p_Target_Indicator AND
      dim_set_id = l_dim_set_id AND
      default_key_value IS NULL AND UPPER(default_value)= 'C';

    IF l_count > 0 THEN
      Update_Bsc_Kpi_Props (
         p_commit             =>  FND_API.G_FALSE
        ,p_Target_Indicator   =>  p_Target_Indicator
        ,p_Property_code      =>  'COLOR_BY_TOTAL'
        ,p_Property_value      => 0
        ,x_return_status      =>  x_return_status
        ,x_msg_count          =>  x_msg_count
        ,x_msg_data           =>  x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscChkColorByTotal;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscChkColorByTotal;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscChkColorByTotal;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_Color_By_Total_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Check_Color_By_Total_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscChkColorByTotal;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_Color_By_Total_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Check_Color_By_Total_Props ';
    END IF;
END Check_Color_By_Total_Props;

/************************************************************************************
--	API name 	: Check_Profit_Loss_Properties
--	Type		: Private
--	Function	:
--
************************************************************************************/

PROCEDURE Check_Profit_Loss_Properties(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Target_Indicator         IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
l_sql VARCHAR2(32000);
l_Indic_Type bsc_kpis_b.indicator_type%TYPE;
l_Config_Type bsc_kpis_b.config_type%TYPE;
TYPE c_cur_type IS REF CURSOR;
c_cursor c_cur_type;

CURSOR c_Indic IS
SELECT
  indicator_type,config_type
FROM
  bsc_kpis_vl
WHERE
  indicator = p_Target_Indicator;
l_Count NUMBER := 0;
l_Drill_Flag NUMBER := 0;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscCopyIndicPLUpd;

  OPEN c_Indic;
  FETCH c_Indic INTO l_Indic_Type, l_Config_Type;
  CLOSE c_Indic;

  IF l_Indic_Type = 1 AND l_Config_Type = 3 THEN
    SELECT
      COUNT(1)
    INTO
      l_Count
    FROM
      bsc_kpi_dim_levels_b
    WHERE
      indicator = p_Target_Indicator;

    IF l_Count > 3 THEN
      l_Drill_Flag := 1;
    END IF;

    Update_Bsc_Kpi_Props (
       p_commit             =>  FND_API.G_FALSE
      ,p_Target_Indicator   =>  p_Target_Indicator
      ,p_Property_code      =>  'PL_DRILL_FLAG'
      ,p_Property_value      => l_Drill_Flag
      ,x_return_status      =>  x_return_status
      ,x_msg_count          =>  x_msg_count
      ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyIndicPLUpd;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyIndicPLUpd;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyIndicPLUpd;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_Profit_Loss_Properties ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Check_Profit_Loss_Properties ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyIndicPLUpd;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_Profit_Loss_Properties ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Check_Profit_Loss_Properties ';
    END IF;
END Check_Profit_Loss_Properties;

/************************************************************************************
--	API name 	: Check_Default_Record_Data_Tbls
--	Type		: Private
--	Function	:
--
************************************************************************************/

PROCEDURE Check_Default_Record_Data_Tbls(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Target_Indicator         IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
l_sql VARCHAR2(32000);
TYPE c_cur_type IS REF CURSOR;
c_cursor c_cur_type;

l_Count NUMBER := 0;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscCopyDfltDataTbl;

  SELECT
    COUNT(1)
  INTO
    l_Count
  FROM
    bsc_kpi_data_tables
  WHERE
    indicator = p_Target_Indicator;

  IF l_Count = 0 THEN
   INSERT INTO bsc_kpi_data_tables (
     indicator
    ,periodicity_id
    ,dim_set_id
    ,level_comb
    ,table_name
    ,filter_condition)
   (SELECT
     indicator indicator
    ,periodicity_id periodicity_id
    ,0 dim_set_id
    ,'?' level_comb
    ,NULL table_name
    ,NULL filter_condition
    FROM
      bsc_kpi_periodicities
    WHERE
      INDICATOR = p_Target_Indicator);
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyDfltDataTbl;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyDfltDataTbl;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyDfltDataTbl;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_Default_Record_Data_Tbls ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Check_Default_Record_Data_Tbls ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyDfltDataTbl;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_Default_Record_Data_Tbls ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Check_Default_Record_Data_Tbls ';
    END IF;
END Check_Default_Record_Data_Tbls;

/************************************************************************************
--	API name 	: Check_KPI_Name
--	Type		: Private
--	Function	:
--
************************************************************************************/

PROCEDURE Check_KPI_Name(
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_Target_Indicator         IN    NUMBER
, p_Name                     IN    VARCHAR2
, p_Description              IN    VARCHAR2
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
)IS
CURSOR c_Kpi_Lang IS
SELECT
  distinct source_lang
 ,name
FROM
  bsc_kpis_tl
WHERE indicator = p_Target_Indicator;


l_Count NUMBER := 0;
l_source_lang bsc_kpis_tl.source_lang%TYPE;
l_name bsc_kpis_tl.name%TYPE;
l_new_name bsc_kpis_tl.name%TYPE;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscCopyIndicChkKpiName;

  l_new_name := p_Name;
  FOR cd IN c_Kpi_Lang LOOP
    SELECT
      COUNT(1)
    INTO
      l_Count
    FROM
      bsc_kpis_vl
    WHERE
      UPPER(name) = UPPER(cd.Name);

    IF l_Count > 0 THEN
      --l_new_name := SUBSTR(cd.Name, 0, (LENGTH(cd.Name) -3)) || ' ' || l_Count;
      IF p_Name IS NULL THEN
        l_new_name := BSC_UTILITY.get_Next_Name(
                      p_Name        => cd.Name
                     ,p_Max_Count   => 150
                     ,p_Table_Name  => 'BSC_KPIS_TL'
                     ,p_Column_Name => 'NAME'
                     ,p_Character   => ' '
                    );
      END IF;
      UPDATE
        bsc_kpis_tl
      SET
        name = l_new_name
      WHERE
        indicator = p_Target_Indicator AND
        source_lang = cd.source_lang;
      IF p_Description IS NOT NULL THEN
        UPDATE
          bsc_kpis_tl
        SET
          help = p_Description
        WHERE
          indicator = p_Target_Indicator AND
          source_lang = cd.source_lang;
      END IF;
    END IF;

  END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyIndicChkKpiName;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyIndicChkKpiName;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyIndicChkKpiName;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_KPI_Name ';
    ELSE
      x_msg_data      :=  SQLERRM||' at  BSC_COPY_INDICATOR_PUB.Check_KPI_Name ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyIndicChkKpiName;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->  BSC_COPY_INDICATOR_PUB.Check_KPI_Name ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT  BSC_COPY_INDICATOR_PUB.Check_KPI_Name ';
    END IF;
END Check_KPI_Name;

/************************************************************************************
--	API name 	: CopyNew_Indicator_UI_Wrap
--	Type		: Public
--	Function	:
--      This API is used to copy an indicator from one indicator group to another
************************************************************************************/
PROCEDURE CopyNew_Indicator_UI_Wrap (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_DbLink_Name              IN    VARCHAR2
, p_Name                     IN    VARCHAR2 := NULL
, p_Description              IN    VARCHAR2 := NULL
, p_Source_Indicator         IN    NUMBER
, p_Target_Group             IN    NUMBER
, p_New_Position             IN    NUMBER
, p_Old_Dim_Levels           IN    FND_TABLE_OF_NUMBER
, p_New_Dim_Levels           IN    FND_TABLE_OF_NUMBER
, p_Old_Dim_Groups           IN    FND_TABLE_OF_NUMBER
, p_New_Dim_Groups           IN    FND_TABLE_OF_NUMBER
, p_Old_DataSet_Map          IN    FND_TABLE_OF_NUMBER
, p_New_DataSet_Map          IN    FND_TABLE_OF_NUMBER
, p_Target_Calendar          IN    NUMBER
, p_Old_Periodicities        IN    FND_TABLE_OF_NUMBER
, p_New_Periodicities        IN    FND_TABLE_OF_NUMBER
, p_Time_Stamp               IN    VARCHAR2 := NULL
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
) IS
  l_Bsc_Kpi_Entity_Rec  BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Target_Indicator    bsc_kpis_b.indicator%TYPE;
  l_sql VARCHAR2(32000);
  l_Responsibility_Key_List VARCHAR2(200);
  l_Short_Name bsc_kpis_b.short_name%TYPE;
  l_Region_Code ak_regions.region_code%TYPE;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscCopyIndicatorUIWrap;

  BSC_DESIGNER_PVT.g_DbLink_Name := p_DbLink_Name;
  Validate_Indicator_Copy (
     p_Source_Indicator   =>  p_Source_Indicator
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    BSC_APPS.Write_Line_Log('Validation of objective copy failed : Objective [ ' ||p_Source_Indicator||'] ' , BSC_APPS.OUTPUT_FILE);
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_DbLink_Name IS NULL THEN
    --l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Source_Indicator;
    BSC_BIS_LOCKS_PUB.Lock_Kpi (
      p_kpi_Id               => p_Source_Indicator
     ,p_time_stamp           => p_Time_Stamp
     ,p_full_lock_flag       => FND_API.G_FALSE
     ,x_return_status        => x_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

/*
  --Remove this p_Db_LInk Name .Even the datasets,dimsets in the source have to be locked
  --IF p_DbLink_Name IS NOT NULL THEN -- Only if the target is different than source
  Lock_Target_Entities (
    p_DataSet_Map      => p_New_DataSet_Map
    p_DimLevel_Map     => p_New_Dim_Levels
    p_DimGroup_Map     => p_New_Dim_Groups
    p_Periodicity_Map  => p_New_Periodicities
    p_Calendar         => p_Target_Calendar
   ,p_time_stamp       => p_Time_Stamp
   ,x_return_status    => x_return_status
   ,x_msg_count        => x_msg_count
   ,x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --END IF;*/

  BSC_DESIGNER_PVT.Copy_Kpi_Metadata(
     p_commit           =>  FND_API.G_FALSE
    ,p_DbLink_Name      =>  p_DbLink_Name
    ,p_Source_Indicator =>  p_Source_Indicator
    ,x_Target_Indicator =>  l_Target_Indicator
    ,x_return_status    =>  x_return_status
    ,x_msg_count        =>  x_msg_count
    ,x_msg_data         =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SELECT
    short_name
  INTO
    l_Short_Name
  FROM
    bsc_kpis_b
  WHERE
    indicator = l_Target_Indicator;

  Move_Indicator (
    p_commit              => FND_API.G_FALSE
   ,p_Indicator           => l_Target_Indicator
   ,p_New_Indicator_Group => p_Target_Group
   ,p_Assign_Group_To_Tab => FND_API.G_FALSE
   ,x_return_status       => x_return_status
   ,x_msg_count           => x_msg_count
   ,x_msg_data            => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_Responsibility_Key_List := 'BSC_Manager,BSC_DESIGNER,BSC_PMD_USER';
  Create_Kpi_Access_Wrap (
    p_commit              => FND_API.G_FALSE
   ,p_Comma_Sep_Resposibility_Key => l_Responsibility_Key_List
   ,p_Indicator_Id        => l_Target_Indicator
   ,x_return_status       => x_return_status
   ,x_msg_count           => x_msg_count
   ,x_msg_data            => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  BSC_DESIGNER_PVT.ActionFlag_Change(
    x_indicator => l_Target_Indicator
   ,x_newflag   => 1 );

  Check_KPI_Name (
     p_commit                =>  FND_API.G_FALSE
    ,p_Target_Indicator      =>  l_Target_Indicator
    ,p_Name                  =>  p_Name
    ,p_Description           =>  p_Description
    ,x_return_status         =>  x_return_status
    ,x_msg_count             =>  x_msg_count
    ,x_msg_data              =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_Short_Name IS NOT NULL THEN
     l_Region_Code := BSC_UTILITY.get_Next_Name(
                        p_Name        => l_short_name
                       ,p_Max_Count   => 30
                       ,p_Table_Name  => 'AK_REGIONS'
                       ,p_Column_Name => 'REGION_CODE'
                       ,p_Character   => '_'
                      );
  END IF;
  IF p_New_Dim_Levels.COUNT > 0 OR p_New_Dim_Groups.COUNT > 0
     OR p_Old_DataSet_Map.COUNT > 0 OR p_New_Periodicities.COUNT > 0 THEN

--    IF p_New_Dim_Groups.COUNT > 0 THEN
      Copy_Dim_Level_Props (
         p_commit            =>  FND_API.G_FALSE
        ,p_Source_Indicator  =>  p_Source_Indicator
        ,p_Target_Indicator  =>  l_Target_Indicator
        ,p_Old_Dim_Levels    =>  p_Old_Dim_Levels
        ,p_New_Dim_Levels    =>  p_New_Dim_Levels
        ,p_Old_Dim_Groups    =>  p_Old_Dim_Groups
        ,p_New_Dim_Groups    =>  p_New_Dim_Groups
        ,p_Region_Code       =>  l_Region_Code
        ,p_Old_Region_Code   =>  l_Short_Name
        ,x_return_status     =>  x_return_status
        ,x_msg_count         =>  x_msg_count
        ,x_msg_data          =>  x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      Check_Key_Item_Props (
         p_commit            =>  FND_API.G_FALSE
        ,p_Source_Indicator  =>  p_Source_Indicator
        ,p_Target_Indicator  =>  l_Target_Indicator
        ,p_Old_Dim_Levels    =>  p_Old_Dim_Levels
        ,p_New_Dim_Levels    =>  p_New_Dim_Levels
        ,x_return_status     =>  x_return_status
        ,x_msg_count         =>  x_msg_count
        ,x_msg_data          =>  x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      BSC_DESIGNER_PVT.Deflt_Update_Dim_Values (
        x_indicator => l_Target_Indicator
      );

      BSC_DESIGNER_PVT.Deflt_Update_Dim_Names (
        x_indicator => l_Target_Indicator
      );

--    END IF;

    Copy_Analysis_Measures (
       p_commit           =>  FND_API.G_FALSE
      ,p_Source_Indicator =>  p_Source_Indicator
      ,p_Target_Indicator =>  l_Target_Indicator
      ,p_Old_DataSet_Map  =>  p_Old_DataSet_Map
      ,p_New_DataSet_Map  =>  p_New_DataSet_Map
      ,x_return_status    =>  x_return_status
      ,x_msg_count        =>  x_msg_count
      ,x_msg_data         =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_YTD_Apply (
       p_commit           =>  FND_API.G_FALSE
      ,p_Indicator        =>  l_Target_Indicator
      ,x_return_status    =>  x_return_status
      ,x_msg_count        =>  x_msg_count
      ,x_msg_data         =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_DESIGNER_PVT.Deflt_Update_SN_FM_CM (
      x_indicator => l_Target_Indicator
    );

    Copy_Periodicities (
       p_commit                =>  FND_API.G_FALSE
      ,p_Source_Indicator      =>  p_Source_Indicator
      ,p_Target_Indicator      =>  l_Target_Indicator
      ,p_Target_Calendar       =>  p_Target_Calendar
      ,p_Old_Periodicities     =>  p_Old_Periodicities
      ,p_New_Periodicities     =>  p_New_Periodicities
      ,x_return_status         =>  x_return_status
      ,x_msg_count             =>  x_msg_count
      ,x_msg_data              =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Check_Default_Record_Data_Tbls (
       p_commit            =>  FND_API.G_FALSE
      ,p_Target_Indicator  =>  l_Target_Indicator
      ,x_return_status     =>  x_return_status
      ,x_msg_count         =>  x_msg_count
      ,x_msg_data          =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Check_Profit_Loss_Properties (
       p_commit            =>  FND_API.G_FALSE
      ,p_Target_Indicator  =>  l_Target_Indicator
      ,x_return_status     =>  x_return_status
      ,x_msg_count         =>  x_msg_count
      ,x_msg_data          =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF l_Short_Name IS NOT NULL THEN
      BSC_MIGRATION.Migrate_Sim_Data (
         p_commit            =>  FND_API.G_FALSE
        ,p_Src_indicator     =>  p_Source_Indicator
        ,p_Trg_indicator     =>  l_Target_Indicator
        ,p_Region_Code       =>  l_Region_Code
        ,p_Old_Region_Code   =>  l_Short_Name
        ,p_Old_Dim_Levels    =>  p_Old_Dim_Levels
        ,p_New_Dim_Levels    =>  p_New_Dim_Levels
        ,p_Old_Dim_Groups    =>  p_Old_Dim_Groups
        ,p_New_Dim_Groups    =>  p_New_Dim_Groups
        ,p_Old_DataSet_Map   =>  p_Old_DataSet_Map
        ,p_New_DataSet_Map   =>  p_New_DataSet_Map
        ,p_Target_Calendar   =>  p_Target_Calendar
        ,p_Old_Periodicities =>  p_Old_Periodicities
        ,p_New_Periodicities =>  p_New_Periodicities
        ,x_return_status     =>  x_return_status
        ,x_msg_count         =>  x_msg_count
        ,x_msg_data          =>  x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;

  Reposition_Indicator (
     p_commit                =>  FND_API.G_FALSE
    ,p_Indicator             =>  l_Target_Indicator
    ,p_New_Indicator_Group   =>  p_Target_Group
    ,p_New_Position          =>  p_New_Position
    ,x_return_status         =>  x_return_status
    ,x_msg_count             =>  x_msg_count
    ,x_msg_data              =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_Target_Indicator;

  BSC_KPI_PUB.Update_Kpi_Time_Stamp
  ( p_commit              => FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  => l_Bsc_Kpi_Entity_Rec
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyIndicatorUIWrap;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyIndicatorUIWrap;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyIndicatorUIWrap;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.CopyNew_Indicator_UI_Wrap ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.CopyNew_Indicator_UI_Wrap ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyIndicatorUIWrap;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_COPY_INDICATOR_PUB.CopyNew_Indicator_UI_Wrap ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_COPY_INDICATOR_PUB.CopyNew_Indicator_UI_Wrap ';
    END IF;
END CopyNew_Indicator_UI_Wrap;


END BSC_COPY_INDICATOR_PUB;

/
