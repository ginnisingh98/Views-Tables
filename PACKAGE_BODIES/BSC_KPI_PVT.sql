--------------------------------------------------------
--  DDL for Package Body BSC_KPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_PVT" as
/* $Header: BSCVKPPB.pls 120.7 2007/03/20 06:38:30 vtulasi ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVKPPB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 22, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |                      Private Body version.                                           |
 |                      This package Creates, Retrieve, Update, Delete                  |
 |                      for BSC KPI information.                                        |
 |                                                                                      |
 | History:                                                                             |
 |                                                                                      |
 | 04-MAR-2003 PAJOHRI  MLS Bug #2721899                                                |
 |                        1. Modified Update Query for  BSC_KPIS_TL, BSC_KPI_DEFAULTS_TL|
 |                        2. Modified Insert Query for  BSC_KPI_DEFAULTS_TL.            |
 |                        3. Changed nvl(<record_name>.Bsc_Language, userenv('LANG'))   |
 |                           to userenv('LANG')                                         |
 | 20-MAR-03 PWALI for bug #2843082                                                     |
 |                      13-MAY-2003 PWALI  Bug #2942895, SQL BIND COMPLIANCE            |
 |                      24-JUL-2003 Adeulgao fixed bug#3047536                          |
 |                                  Granted access of KPIS to BSC_PMD_USER              |
 |                      14-NOV-2003 ADRAO  Modified for  Bug #3248729,                  |
 |                      02-MAR-2004 WLEUNG Modified for  Bug #3476004                   |
 |                                        new procedure Set_Default_Value_By_Option_ID  |
 |                      06-MAR-2004 kyadamak for the bug#3439029                        |
 |                      11-MAR-2004 PAJOHRI Bug #3500012                                |
 | 30-MAR-2003 PAJOHRI  Bug #3539639, modified closing of cursor c_old_option_id        |
 |   18-MAY-04          adrao Modified PL/SQL records and CRUD to accept SHORT_NAME     |
 |   18-JUN-04          adrao added BSC_KPI_ANALYSIS_GROUP.SHORT_NAME to PL/SQL APIs    |
 |                            Bug#3691035                                               |
 |   21-JUL-04          adrao made short_name nonunique. prototype_flag =2 Bug#3781764  |
 |   11-APR-05          adrao fixed API Create_Kpi_Analysis to pass appropriate name    |
 |                            for Bug#4294920                                           |
 |   27-APR-05          adrao Fixed Bug#4331964                                         |
 |   21-JUL-2005        ashankar Bug#4314386                                            |
 |   16-NOV-2006        ankgoel  Color By KPI enh#5244136                               |
 |   16-NOV-2006        vtulasi  Color By KPI enh#5244136                               |
 |     09-feb-2007 ashankar Simulation Tree Enhacement 5386112                          |
 +======================================================================================+
*/
G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_KPI_PVT';

procedure Create_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_db_object         VARCHAR2(30);
l_count             NUMBER;
l_No_Ind            NUMBER;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPI;
 --DBMS_OUTPUT.PUT_LINE(' -- Begin   Create_Kpi ');

  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;


  -- Check that KPI Id does not exist yet.
  IF l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  IS NOT NULL THEN

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_KPIS_B
    WHERE  INDICATOR = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF l_count <> 0 THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_KPI_ID_EXISTS');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


 --DBMS_OUTPUT.PUT_LINE(' Create_Kpi - Flag 1');

  -- Check that a valid KPI group id has been entered.


  -- Fixed for Bug#3781764 added PROTOTYPE_FLAG
  IF l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name IS NOT NULL THEN
     SELECT COUNT(1) INTO l_Count
     FROM   BSC_KPIS_B
     WHERE  SHORT_NAME = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name
     AND    PROTOTYPE_FLAG <> BSC_KPI_PUB.DELETE_KPI_FLAG;

     IF l_Count <> 0 THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
       FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_BUILDER', 'MEASURE_SHORT_NAME'));
       FND_MESSAGE.SET_TOKEN('NAME_VALUE', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;


 -- If display order value for KPI is null assign next value within Kpi group.
--  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order is null then
    select count(1) + 1
      into l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order
      from BSC_KPIS_B
     where ind_group_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id;
--  end if;

  -- Set some null values to defaults, such as dates.
  if l_Bsc_Kpi_Entity_Rec.Creation_Date is null then
    l_Bsc_Kpi_Entity_Rec.Creation_Date := sysdate;
  end if;

  if l_Bsc_Kpi_Entity_Rec.Last_Update_Date is null then
    l_Bsc_Kpi_Entity_Rec.Last_Update_Date := sysdate;
  end if;

  l_db_object := 'BSC_KPIS_B';
  l_Bsc_Kpi_Entity_Rec.Bsc_Color_Rollup_Type := BSC_COLOR_CALC_UTIL.DEFAULT_KPI;
  l_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Color_Id := BSC_COLOR_REPOSITORY.EXCELLENT_COLOR;
  l_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Trend_Id := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Weighted_Color_Method := 1;

  insert into BSC_KPIS_B( INDICATOR
                         ,CSF_ID
                         ,IND_GROUP_ID
                         ,DISP_ORDER
                         ,PROTOTYPE_FLAG
                         ,INDICATOR_TYPE
                         ,CONFIG_TYPE
                         ,PERIODICITY_ID
                         ,BM_GROUP_ID
                         ,APPLY_COLOR_FLAG
                         ,PROTOTYPE_COLOR
                         ,SHARE_FLAG
                         ,SOURCE_INDICATOR
                         ,PUBLISH_FLAG
                         ,CREATED_BY
                         ,CREATION_DATE
                         ,LAST_UPDATED_BY
                         ,LAST_UPDATE_DATE
                         ,LAST_UPDATE_LOGIN
                         ,EDW_FLAG
                         ,CALENDAR_ID
                         ,SHORT_NAME
                         ,COLOR_ROLLUP_TYPE
                         ,PROTOTYPE_COLOR_ID
                         ,PROTOTYPE_TREND_ID
                         ,WEIGHTED_COLOR_METHOD)
                  values( l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Bm_Group_Id
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Flag
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Color
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Publish_Flag
                         ,l_Bsc_Kpi_Entity_Rec.Created_By
                         ,sysdate
                         ,l_Bsc_Kpi_Entity_Rec.Last_Updated_By
                         ,sysdate
                         ,l_Bsc_Kpi_Entity_Rec.Last_Update_Login
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Edw_Flag
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Calendar_Id
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Color_Rollup_Type
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Color_Id
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Trend_Id
                         ,l_Bsc_Kpi_Entity_Rec.Bsc_Weighted_Color_Method);

  l_db_object := 'BSC_KPIS_TL';

  -- Fixed bug 2635468  ISSUE FIFTH
  insert into BSC_KPIS_TL (
    INDICATOR,
    LANGUAGE,
    SOURCE_LANG,
    NAME,
    HELP
  ) select
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id,
      L.LANGUAGE_CODE,
      userenv('LANG'),
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name,
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
   and not exists
    (select NULL
       from BSC_KPIS_TL T
       where T.INDICATOR = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
       and T.LANGUAGE = L.LANGUAGE_CODE);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

  select count(indicator)
    into  l_count
    from bsc_kpis_b
    where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id ;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;

        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi;

/************************************************************************************
************************************************************************************/


procedure Retrieve_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi';

  SELECT DISTINCT  A.CSF_ID
                  ,A.IND_GROUP_ID
                  ,A.DISP_ORDER
                  ,A.PROTOTYPE_FLAG
                  ,A.INDICATOR_TYPE
                  ,A.CONFIG_TYPE
                  ,A.PERIODICITY_ID
                  ,A.BM_GROUP_ID
                  ,A.APPLY_COLOR_FLAG
                  ,A.PROTOTYPE_COLOR
                  ,A.SHARE_FLAG
                  ,A.SOURCE_INDICATOR
                  ,A.PUBLISH_FLAG
                  ,A.CREATED_BY
                  ,A.CREATION_DATE
                  ,A.LAST_UPDATED_BY
                  ,A.LAST_UPDATE_DATE
                  ,A.LAST_UPDATE_LOGIN
                  ,A.EDW_FLAG
                  ,A.CALENDAR_ID
                  ,A.SHORT_NAME
                  ,A.COLOR_ROLLUP_TYPE
                  ,A.PROTOTYPE_COLOR_ID
                  ,A.PROTOTYPE_TREND_ID
                  ,A.WEIGHTED_COLOR_METHOD
                  ,B.NAME
                  ,B.HELP
                  ,B.SOURCE_LANG
             INTO  x_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Bm_Group_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Flag
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Color
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Publish_Flag
                  ,x_Bsc_Kpi_Entity_Rec.Created_By
                  ,x_Bsc_Kpi_Entity_Rec.Creation_Date
                  ,x_Bsc_Kpi_Entity_Rec.Last_Updated_By
                  ,x_Bsc_Kpi_Entity_Rec.Last_Update_Date
                  ,x_Bsc_Kpi_Entity_Rec.Last_Update_Login
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Edw_Flag
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Calendar_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Color_Rollup_Type
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Color_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Trend_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Weighted_Color_Method
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Source_Language
             FROM  BSC_KPIS_B A
                  ,BSC_KPIS_TL B
            WHERE A.INDICATOR = B.INDICATOR
              AND A.INDICATOR = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              AND B.LANGUAGE =  USERENV('LANG');
              -- Fixed Third issue in bug 2635468

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi ';
        END IF;
        RAISE;
end Retrieve_Kpi;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UptKPI;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;


  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi( p_commit
               ,p_Bsc_Kpi_Entity_Rec
               ,l_Bsc_Kpi_Entity_Rec
               ,x_return_status
               ,x_msg_count
               ,x_msg_data);

  -- update LOCAL language ,source language  and KPI Id values with PASSED values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Language;
  l_Bsc_Kpi_Entity_Rec.Bsc_Source_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Bm_Group_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Bm_Group_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Bm_Group_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Flag is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Flag := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Flag;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Color is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Color := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Color;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Publish_Flag is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Publish_Flag := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Publish_Flag;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Created_By is not null then
    l_Bsc_Kpi_Entity_Rec.Created_By := p_Bsc_Kpi_Entity_Rec.Created_By;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Creation_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Creation_Date := p_Bsc_Kpi_Entity_Rec.Creation_Date;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Updated_By is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Updated_By := p_Bsc_Kpi_Entity_Rec.Last_Updated_By;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Update_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Update_Date := p_Bsc_Kpi_Entity_Rec.Last_Update_Date;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Update_Login is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Update_Login := p_Bsc_Kpi_Entity_Rec.Last_Update_Login;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Edw_Flag is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Edw_Flag := p_Bsc_Kpi_Entity_Rec.Bsc_Edw_Flag;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Calendar_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Calendar_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Calendar_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Color_Rollup_Type is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Color_Rollup_Type := p_Bsc_Kpi_Entity_Rec.Bsc_Color_Rollup_Type;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Color_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Color_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Color_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Trend_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Trend_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Trend_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Weighted_Color_Method is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Weighted_Color_Method := p_Bsc_Kpi_Entity_Rec.Bsc_Weighted_Color_Method;
  end if;


  update BSC_KPIS_B
     set  csf_id = l_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id
         ,ind_group_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id
         ,disp_order = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order
         ,prototype_flag = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag
         ,indicator_type = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type
         ,config_type = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type
         ,periodicity_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id
         ,bm_group_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Bm_Group_Id
         ,apply_color_flag = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Flag
         ,prototype_color = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Color
         ,share_flag = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag
         ,source_indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind
         ,publish_flag = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Publish_Flag
         ,created_by = l_Bsc_Kpi_Entity_Rec.Created_By
         ,creation_date = l_Bsc_Kpi_Entity_Rec.Creation_Date
         ,last_updated_by = l_Bsc_Kpi_Entity_Rec.Last_Updated_By
         ,last_update_date = l_Bsc_Kpi_Entity_Rec.Last_Update_Date
         ,last_update_login = l_Bsc_Kpi_Entity_Rec.Last_Update_Login
         ,edw_flag = l_Bsc_Kpi_Entity_Rec.Bsc_Edw_Flag
         ,calendar_id = l_Bsc_Kpi_Entity_Rec.Bsc_Calendar_Id
         ,color_rollup_type = l_Bsc_Kpi_Entity_Rec.Bsc_Color_Rollup_Type
         ,prototype_color_id = l_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Color_Id
         ,prototype_trend_id = l_Bsc_Kpi_Entity_Rec.Bsc_Prototype_Trend_Id
         ,weighted_color_method = l_Bsc_Kpi_Entity_Rec.Bsc_Weighted_Color_Method
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  update BSC_KPIS_TL
     set  name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name
         ,help = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help
         ,SOURCE_LANG       = userenv('LANG')
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  BscKpiPvt_UptKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  BscKpiPvt_UptKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO  BscKpiPvt_UptKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO  BscKpiPvt_UptKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count              number;
l_Delete_Kpi_b       BOOLEAN := TRUE;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPI;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;


  -- Added for Bug #3248729
  IF BSC_UTILITY.isBscInProductionMode THEN
     -- Validate Records in BSC_KPI_DATA_TABLES
     SELECT COUNT(INDICATOR)
     INTO   l_count
     FROM   BSC_KPI_DATA_TABLES
     WHERE  INDICATOR =  p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     AND    TABLE_NAME IS NOT NULL; -- need to check if actual KPI Tables are there

     IF l_count > 0 THEN
        l_Delete_Kpi_b := FALSE;
     END IF;
  END IF;
  IF l_Delete_Kpi_b THEN
       DELETE FROM BSC_KPIS_B
       WHERE  INDICATOR = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

       DELETE FROM BSC_KPIS_TL
       WHERE  INDICATOR = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  ELSE
       UPDATE   BSC_KPIS_B
       SET      PROTOTYPE_FLAG = BSC_KPI_PUB.DELETE_KPI_FLAG
       WHERE    INDICATOR      = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  END IF;

  -- Added for Bug #3248729

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  BscKpiPvt_DelKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  BscKpiPvt_DelKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO  BscKpiPvt_DelKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO  BscKpiPvt_DelKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Kpi;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_Bsc_Dim_Rec                   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_db_object         varchar2(30);

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPIDef;
--BSC_DEBUG.PUT_LINE('-- Begin Create_Kpi_Defaults');
--BSC_DEBUG.PUT_LINE(' Create_Kpi_Defaults -  p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id = ' || p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);


  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- Check that valid id was entered.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then

    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then

    --DBMS_OUTPUT.PUT_LINE(' Create_Kpi_Defaults -  BSC_INVALID_KPI_ID');
    --DBMS_OUTPUT.PUT_LINE(' Create_Kpi_Defaults -  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id = ' || l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);

      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
--DBMS_OUTPUT.PUT_LINE(' Create_Kpi_Defaults -  BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

--DBMS_OUTPUT.PUT_LINE(' Create_Kpi_Defaults -  Flag 1');

  -- Set values needed to populate default Dimension set.
  l_Bsc_Dim_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_Bsc_Dim_Rec.Bsc_Dim_Set_Id := 0;
  l_Bsc_Dim_Rec.Bsc_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Language;
  l_Bsc_Dim_Rec.Bsc_Source_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;

  l_db_object := 'Create_Bsc_Kpi_Dim_Sets_Tl';

 --DBMS_OUTPUT.PUT_LINE(' Create_Kpi_Defaults -  Flag 2');

  -- Call procedure to Populate Dimension sets.
  BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl( p_commit
                                                    ,l_Bsc_Dim_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

--DBMS_OUTPUT.PUT_LINE(' Create_Kpi_Defaults -  Flag 3');

  -- Set values needed to populate default Dimension Levels for the Kpi.
  l_Bsc_Dim_Rec.Bsc_Dset_Dim_Level_Index := 1; -- This is set to one because the API
                                               -- that actually sets this value subtracts 1
                                               -- from the value passed, thus making the value 0.
  l_Bsc_Dim_Rec.Bsc_Level_Name := 'XXX';
  l_Bsc_Dim_Rec.Bsc_Pk_Col := 'XXX';
  l_Bsc_Dim_Rec.Bsc_Dim_Level_Long_Name := 'XXX';
  l_Bsc_Dim_Rec.Bsc_Dim_Level_Help := 'XXX';
  l_Bsc_Dim_Rec.Bsc_Dset_Value_Order := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_Comp_Order := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_Parent_Level_Rel := 'XXX';
  l_Bsc_Dim_Rec.Bsc_Dset_Status := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_Position := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_User_Level0 := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_User_Level1 := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_User_Level1_Default := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_User_Level2 := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_User_Level2_Default := 0;
  l_Bsc_Dim_Rec.Bsc_Dset_Target_Level := 1;
  l_Bsc_Dim_Rec.Bsc_Dim_Tot_Disp_Name := 'XXX';
  l_Bsc_Dim_Rec.Bsc_Dim_Comp_Disp_Name := 'XXX';

  l_db_object := 'Create_Dim_Levels';

--DBMS_OUTPUT.PUT_LINE(' Create_Kpi_Defaults -  Flag 4');

  BSC_DIMENSION_SETS_PUB.Create_Dim_Levels( p_commit
                                       ,l_Bsc_Dim_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

--DBMS_OUTPUT.PUT_LINE('-- Ene Create_Kpi_Defaults');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDef;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDef;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDef;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDef;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_Defaults;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Dim_Rec                   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
x_Bsc_Dim_Rec                   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_db_object         varchar2(30);

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi_Defaults';

  -- Set values needed to retrieve default Dimension set.
  l_Bsc_Dim_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_Bsc_Dim_Rec.Bsc_Dim_Set_Id := 0;
  l_Bsc_Dim_Rec.Bsc_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Language;
  l_Bsc_Dim_Rec.Bsc_Source_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;

  BSC_DIMENSION_SETS_PUB.Retrieve_Bsc_Kpi_Dim_Sets_Tl( p_commit
                                                      ,l_Bsc_Dim_Rec
                                                      ,x_Bsc_Dim_Rec
                                                      ,x_return_status
                                                      ,x_msg_count
                                                      ,x_msg_data);

  -- Set values needed to retrieve default Dimension set.
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id :=  x_Bsc_Dim_Rec.Bsc_Kpi_Id;
  x_Bsc_Kpi_Entity_Rec.Bsc_Dim_Set_Id := x_Bsc_Dim_Rec.Bsc_Dim_Set_Id;
  x_Bsc_Kpi_Entity_Rec.Bsc_Language := x_Bsc_Dim_Rec.Bsc_Language;
  x_Bsc_Kpi_Entity_Rec.Bsc_Source_Language := x_Bsc_Dim_Rec.Bsc_Source_Language;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_Defaults;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is


begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- This procedure does not really update anything.  Public version handles the calls
  -- to the other procedures.

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Defaults;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Kpi_Defaults;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPIProp;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_db_object := 'BSC_KPI_PROPERTIES';

  insert into BSC_KPI_PROPERTIES( indicator
                                 ,property_code
                                 ,property_value
                                 ,secondary_value)
                          values( p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code
                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value
                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIProp;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIProp;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPIProp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPIProp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_Properties;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

l_db_object         varchar2(30);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi_Properties';

  select distinct  property_value
                  ,secondary_value
             into  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value
             from  BSC_KPI_PROPERTIES
            where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              and property_code = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_Properties;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UptKPIProp;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi_Properties( p_commit
                          ,p_Bsc_Kpi_Entity_Rec
                          ,l_Bsc_Kpi_Entity_Rec
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data);

  -- update LOCAL Kpi Id values with PASSED values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code;


  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value  is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value  is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value;
  end if;

  update BSC_KPI_PROPERTIES
     set  property_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value
         ,secondary_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     and property_code = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPIProp;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPIProp;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UptKPIProp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UptKPIProp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Properties;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPIProp;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;


  delete from BSC_KPI_PROPERTIES
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIProp;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIProp;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelKPIProp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelKPIProp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Kpi_Properties;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_Analysis(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Rec                   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;

l_db_object         varchar2(30);

l_count             number;

no_kpi_id           exception;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPIAnal;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_db_object := 'BSC_KPI_ANALYSIS_GROUPS';

  insert into BSC_KPI_ANALYSIS_GROUPS( INDICATOR
                                      ,ANALYSIS_GROUP_ID
                                      ,NUM_OF_OPTIONS
                                      ,DEPENDENCY_FLAG
                                      ,PARENT_ANALYSIS_ID
                                      ,CHANGE_DIM_SET
                                      ,DEFAULT_VALUE
                                      ,SHORT_NAME)
                               values( p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                      ,p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id
                                      ,p_Bsc_Kpi_Entity_Rec.Bsc_Num_Options
                                      ,p_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag
                                      ,p_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id
                                      ,p_Bsc_Kpi_Entity_Rec.Bsc_Change_Dim_Set
                                      ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value
                                      ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Ana_Group_Short_Name);

  -- Set the necessary values to create the Default Analysis Option.
  l_Bsc_Kpi_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_Bsc_Kpi_Rec.Bsc_Analysis_Group_Id := 0;
  l_Bsc_Kpi_Rec.Bsc_Parent_Option_Id := 0;
  l_Bsc_Kpi_Rec.Bsc_Grandparent_Option_Id := 0;
  l_Bsc_Kpi_Rec.Bsc_Dim_Set_Id := 0;
  l_Bsc_Kpi_Rec.Bsc_Analysis_Option_Id :=  0;
  l_Bsc_Kpi_Rec.Bsc_New_Kpi :=  'Y';
  l_Bsc_Kpi_Rec.Bsc_Option_Group0 := 0;
  l_Bsc_Kpi_Rec.Bsc_Option_Group1 := 0;
  l_Bsc_Kpi_Rec.Bsc_Option_Group2 := 0;
  l_Bsc_Kpi_Rec.Bsc_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Language;
  l_Bsc_Kpi_Rec.Bsc_Source_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;

  -- fixed  Bug#4294920 for AG Report Designer
  -- NOTE: Need to review "Option 0" being hardcoded, which incidently is being
  -- used in Objective designer to maintain references.
  -- An ideal fix would be to get this Option 0 from a lookup so that it is
  -- clearly translatable.

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name IS NOT NULL) THEN
    l_Bsc_Kpi_Rec.Bsc_Option_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name;
    l_Bsc_Kpi_Rec.Bsc_Option_Help := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help;
    l_Bsc_Kpi_Rec.Bsc_Measure_Long_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name;
    l_Bsc_Kpi_Rec.Bsc_Measure_Help := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help;

    --added for Bug#4331964
    l_Bsc_Kpi_Rec.Bsc_Option_Short_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name;
  ELSE
    l_Bsc_Kpi_Rec.Bsc_Option_Name := 'Option 0';
    l_Bsc_Kpi_Rec.Bsc_Option_Help := 'Option 0';
    l_Bsc_Kpi_Rec.Bsc_Measure_Long_Name := 'Default 0';
    l_Bsc_Kpi_Rec.Bsc_Measure_Help := 'Default 0';
  END IF;


  l_Bsc_Kpi_Rec.Bsc_User_Level0 := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0;
  l_Bsc_Kpi_Rec.Bsc_User_Level1 := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1;

  l_db_object := 'Create_Analysis_Options';

  BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options( p_commit
                                                  ,l_Bsc_Kpi_Rec
                                                  ,x_return_status
                                                  ,x_msg_count
                                                  ,x_msg_data);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIAnal;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIAnal;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPIAnal;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPIAnal;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_Analysis;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Analysis(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

l_db_object         varchar2(30);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi_Analysis';
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id IS NOT NULL) THEN
    select distinct  analysis_group_id
                    ,num_of_options
                    ,dependency_flag
                    ,parent_analysis_id
                    ,change_dim_set
                    ,default_value
                    ,short_name
               into  x_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Num_Options
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Change_Dim_Set
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Ana_Group_Short_Name
               from  BSC_KPI_ANALYSIS_GROUPS
              where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              and   analysis_group_id = p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id;
  ELSE
    select distinct  analysis_group_id
                    ,num_of_options
                    ,dependency_flag
                    ,parent_analysis_id
                    ,change_dim_set
                    ,default_value
                    ,short_name
               into  x_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Num_Options
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Change_Dim_Set
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value
                    ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Ana_Group_Short_Name
               from  BSC_KPI_ANALYSIS_GROUPS
              where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  END IF;
  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_Analysis;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Analysis(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UpdKPIAnal;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi_Analysis( p_commit
                        ,p_Bsc_Kpi_Entity_Rec
                        ,l_Bsc_Kpi_Entity_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);

  -- update LOCAL language ,source language  and level Id values with PASSED values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Num_Options is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Num_Options := p_Bsc_Kpi_Entity_Rec.Bsc_Num_Options;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag := p_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Change_Dim_Set is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Change_Dim_Set := p_Bsc_Kpi_Entity_Rec.Bsc_Change_Dim_Set;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value;
  end if;

  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Ana_Group_Short_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Ana_Group_Short_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Ana_Group_Short_Name;
  end if;


  IF (l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id IS NOT NULL) THEN
    IF (l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value IS NOT NULL) THEN
        Set_Default_Value_By_Option_ID
        (       p_Kpi_Id                  =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                , p_group_id                =>  l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id
                , p_parent_option_Id        =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Analysis_Option1
                , p_grand_parent_option_Id  =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Analysis_Option0
                , p_option_Id               =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value
        );
    END IF;
    update BSC_KPI_ANALYSIS_GROUPS
       set  analysis_group_id   = l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id
           ,num_of_options      = l_Bsc_Kpi_Entity_Rec.Bsc_Num_Options
           ,dependency_flag     = l_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag
           ,parent_analysis_id  = l_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id
           ,change_dim_set      = l_Bsc_Kpi_Entity_Rec.Bsc_Change_Dim_Set
           ,default_value       = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value
           ,short_name          = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Ana_Group_Short_Name
     where indicator            = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     AND   analysis_group_id    = l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id;
  ELSE
    update BSC_KPI_ANALYSIS_GROUPS
       set  analysis_group_id   = l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id
           ,num_of_options      = l_Bsc_Kpi_Entity_Rec.Bsc_Num_Options
           ,dependency_flag     = l_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag
           ,parent_analysis_id  = l_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id
           ,change_dim_set      = l_Bsc_Kpi_Entity_Rec.Bsc_Change_Dim_Set
           ,default_value       = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value
           ,short_name          = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Ana_Group_Short_Name
     where indicator            = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  END IF;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UpdKPIAnal;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UpdKPIAnal;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UpdKPIAnal;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UpdKPIAnal;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Analysis;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Analysis(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count                         number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPIAnal;
  -- Check that valid id was entered.
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  IS NOT NULL) THEN
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    IF(l_count = 0 )THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_analysis_groups
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_analysis_options_b
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_analysis_options_tl
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_analysis_measures_b
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_analysis_measures_tl
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_analysis_opt_user
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIAnal;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIAnal;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelKPIAnal;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelKPIAnal;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Kpi_Analysis;

/************************************************************************************
************************************************************************************/

procedure Delete_Objective_Color_Data(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count                         number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelObjColo;
  -- Check that valid id was entered.
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  IS NOT NULL) THEN
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    IF(l_count = 0 )THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

    bsc_kpi_measure_props_pub.Delete_Obj_Kpi_Measure_Props (
       p_commit          =>   FND_API.G_FALSE
      ,p_objective_id    =>   p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
      ,p_cascade_shared  =>   FALSE
      ,x_return_status   =>   x_return_status
      ,x_msg_count       =>   x_msg_count
      ,x_msg_data        =>   x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    bsc_color_ranges_pub.Delete_Color_Prop_Ranges (
       p_commit          =>   FND_API.G_FALSE
      ,p_objective_id    =>   p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
      ,p_kpi_measure_id  =>   NULL
      ,p_cascade_shared  =>   FALSE
      ,x_return_status   =>   x_return_status
      ,x_msg_count       =>   x_msg_count
      ,x_msg_data        =>   x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    bsc_kpi_measure_weights_pub.Del_Obj_Kpi_Measure_Weights (
       p_commit          =>   FND_API.G_FALSE
      ,p_objective_id    =>   p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
      ,x_return_status   =>   x_return_status
      ,x_msg_count       =>   x_msg_count
      ,x_msg_data        =>   x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelObjColo;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelObjColo;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelObjColo;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Objective_Color_Data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Objective_Color_Data ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelObjColo;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Objective_Color_Data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Objective_Color_Data ';
        END IF;
        RAISE;
end Delete_Objective_Color_Data;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_db_object         varchar2(30);

l_count                         number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPIPerid;
  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- Check that valid id was entered.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check that periodicity is valid.  If periodicity is null then make it 5, default
  -- periodicity.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_PERIODICITIES'
                                                 ,'periodicity_id'
                                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_PERIODICITY_ID');
      FND_MESSAGE.SET_TOKEN('BSC_PERIODICITY', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := 5;
  end if;

  -- set value for display order.
  select count(display_order)
    into l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Display
    from BSC_KPI_PERIODICITIES
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  l_db_object := 'BSC_KPI_PERIODICITIES';

  insert into BSC_KPI_PERIODICITIES( indicator
                                    ,periodicity_id
                                    ,display_order
                                    ,previous_years
                                    ,num_of_years
                                    ,viewport_flag
                                    ,viewport_default_size
                                    ,user_level0
                                    ,user_level1
                                    ,user_level1_default
                                    ,user_level2
                                    ,user_level2_default
                                    ,current_period
                                    ,last_update_date)
                             values( l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Display
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default
                                    ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period
                                    ,sysdate);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIPerid;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIPerid;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPIPerid;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPIPerid;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_Periodicity;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_db_object := 'Retrieve_Kpi_Periodicity';

  select distinct  display_order
                  ,previous_years
                  ,num_of_years
                  ,viewport_flag
                  ,viewport_default_size
                  ,user_level0
                  ,user_level1
                  ,user_level1_default
                  ,user_level2
                  ,user_level2_default
                  ,current_period
                  ,last_update_date
             into  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Display
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period
                  ,x_Bsc_Kpi_Entity_Rec.Last_Update_Date
             from  BSC_KPI_PERIODICITIES
            where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              and periodicity_id = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_Periodicity;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UptKPIPerid;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                 ,'indicator'
                                                 ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi_Periodicity( p_commit
                           ,p_Bsc_Kpi_Entity_Rec
                           ,l_Bsc_Kpi_Entity_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);

  -- update LOCAL language ,source language  and Kpi Id values with PASSED values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id;


  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Display is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Display := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Display;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2 is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2 := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Update_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Update_Date := p_Bsc_Kpi_Entity_Rec.Last_Update_Date;
  end if;

  update BSC_KPI_PERIODICITIES
     set  display_order = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Display
         ,previous_years = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years
         ,num_of_years = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years
         ,viewport_flag = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag
         ,viewport_default_size = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size
         ,user_level0 = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0
         ,user_level1 = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1
         ,user_level1_default = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default
         ,user_level2 = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2
         ,user_level2_default = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default
         ,current_period = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period
         ,last_update_date = l_Bsc_Kpi_Entity_Rec.Last_Update_Date
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     and periodicity_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPIPerid;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPIPerid;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UptKPIPerid;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UptKPIPerid;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Periodicity;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count                         number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPIPerid;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  delete from BSC_KPI_PERIODICITIES
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIPerid;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIPerid;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelKPIPerid;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelKPIPerid;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Delete_Kpi_Periodicity;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_Data_Tables(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPIDaTab;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_db_object := 'BSC_KPI_DATA_TABLES';

  insert into BSC_KPI_DATA_TABLES( indicator
                                  ,periodicity_id
                                  ,dim_set_id
                                  ,level_comb
                                  ,table_name
                                  ,filter_condition)
                           values( p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                  ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id
                                  ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id
                                  ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Level_Comb
                                  ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Table_Name
                                  ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Filter_Condition);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDaTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDaTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDaTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDaTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_Data_Tables;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Data_Tables(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi_Data_Tables';

  select distinct  level_comb
                  ,table_name
                  ,filter_condition
            into   x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Level_Comb
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Table_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Filter_Condition
            from   BSC_KPI_DATA_TABLES
           where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
             and dim_set_id = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id
             and periodicity_id = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_Data_Tables;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Data_Tables(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UptKPIDaTab;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi_Data_Tables( p_commit
                           ,p_Bsc_Kpi_Entity_Rec
                           ,l_Bsc_Kpi_Entity_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);

  -- update LOCAL language ,source language  and Kpi Id values with PASSED values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id;


  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Level_Comb is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Level_Comb := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Level_Comb;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Table_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Table_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Table_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Filter_Condition is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Filter_Condition := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Filter_Condition;
  end if;

  update BSC_KPI_DATA_TABLES
     set level_comb = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Level_Comb
        ,table_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Table_Name
        ,filter_condition = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Filter_Condition
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     and dim_set_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id
     and periodicity_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPIDaTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPIDaTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UptKPIDaTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UptKPIDaTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Data_Tables;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Data_Tables(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;
l_Delete_Kpi_Data   BOOLEAN := TRUE;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPIDaTab;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Added for Bug #3248729
  IF BSC_UTILITY.isBscInProductionMode THEN

     SELECT COUNT(INDICATOR)
     INTO   l_count
     FROM   BSC_KPI_DATA_TABLES
     WHERE  INDICATOR = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     AND TABLE_NAME IS NOT NULL; -- need to check if actual KPI Tables are there

     IF l_count > 0 THEN
        l_Delete_Kpi_Data := FALSE;
     END IF;

  END IF;


  IF (l_Delete_Kpi_Data) THEN

     DELETE FROM BSC_KPI_DATA_TABLES
     WHERE  INDICATOR = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  END IF;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;
  -- Added for Bug #3248729

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIDaTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIDaTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelKPIDaTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelKPIDaTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Kpi_Data_Tables;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_Calculations(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPICalc;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_db_object := 'BSC_KPI_CALCULATIONS';

  insert into BSC_KPI_CALCULATIONS( indicator
                                   ,calculation_id
                                   ,user_level0
                                   ,user_level1
                                   ,user_level1_default
                                   ,user_level2
                                   ,user_level2_default
                                   ,default_value)
                            values( p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                   ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id
                                   ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0
                                   ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1
                                   ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default
                                   ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2
                                   ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default
                                   ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPICalc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPICalc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPICalc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPICalc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_Calculations;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Calculations(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi_Calculations';

  select distinct  user_level0
                  ,user_level1
                  ,user_level1_default
                  ,user_level2
                  ,user_level2_default
                  ,default_value
             into  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value
             from  BSC_KPI_CALCULATIONS
            where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              and calculation_id = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_Calculations;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Calculations(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UptKPICalc;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPI_CALCULATIONS'
                                                       ,'calculation_id'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_CALCULATION_ID');
      FND_MESSAGE.SET_TOKEN('BSC_CALCULATION', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_CALCULATION_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_CALCULATION', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi_Calculations( p_commit
                            ,p_Bsc_Kpi_Entity_Rec
                            ,l_Bsc_Kpi_Entity_Rec
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);

  -- update LOCAL Kpi Id values with PASSED values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id;

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2 is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2 := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value;
  end if;

  update BSC_KPI_CALCULATIONS
     set  user_level0 = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0
         ,user_level1 = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1
         ,user_level1_default = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1_Default
         ,user_level2 = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2
         ,user_level2_default = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level2_Default
         ,default_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     and calculation_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPICalc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPICalc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UptKPICalc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UptKPICalc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Calculations;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Calculations(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPICalc;
  -- Check that valid id was entered.
  IF(p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  IS NOT NULL) THEN
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_calculations
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_calculations_user
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPICalc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPICalc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelKPICalc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelKPICalc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Kpi_Calculations;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_User_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPIUsrAcc;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_db_object := 'BSC_USER_KPI_ACCESS';


  insert into BSC_USER_KPI_ACCESS( responsibility_id
                                  ,indicator
                                  ,creation_date
                                  ,created_by
                                  ,last_update_date
                                  ,last_updated_by
                                  ,last_update_login
                                  ,start_date
                                  ,end_date)
                           values( p_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id
                                  ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                  ,sysdate
                                  ,p_Bsc_Kpi_Entity_Rec.Created_By
                                  ,sysdate
                                  ,p_Bsc_Kpi_Entity_Rec.Last_Updated_By
                                  ,p_Bsc_Kpi_Entity_Rec.Last_Update_Login
                                  ,p_Bsc_Kpi_Entity_Rec.Bsc_Resp_Start_Date
                                  ,p_Bsc_Kpi_Entity_Rec.Bsc_Resp_End_Date);




  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIUsrAcc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIUsrAcc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPIUsrAcc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPIUsrAcc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_User_Access;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_User_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi_User_Access';

  select distinct  responsibility_id
                  ,creation_date
                  ,created_by
                  ,last_update_date
                  ,last_updated_by
                  ,last_update_login
                  ,start_date
                  ,end_date
             into  x_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id
                  ,x_Bsc_Kpi_Entity_Rec.Creation_Date
                  ,x_Bsc_Kpi_Entity_Rec.Created_By
                  ,x_Bsc_Kpi_Entity_Rec.Last_Update_Date
                  ,x_Bsc_Kpi_Entity_Rec.Last_Updated_By
                  ,x_Bsc_Kpi_Entity_Rec.Last_Update_Login
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Resp_Start_Date
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Resp_End_Date
             from  BSC_USER_KPI_ACCESS
            where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              and responsibility_id = p_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id;


  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_User_Access;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_User_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UptKPIUsrAcc;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi_User_Access( p_commit
                           ,p_Bsc_Kpi_Entity_Rec
                           ,l_Bsc_Kpi_Entity_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);

  -- update LOCAL language ,source language  and Kpi Id values with PASSED values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Creation_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Creation_Date := p_Bsc_Kpi_Entity_Rec.Creation_Date;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Created_By is not null then
    l_Bsc_Kpi_Entity_Rec.Created_By := p_Bsc_Kpi_Entity_Rec.Created_By;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Update_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Update_Date := p_Bsc_Kpi_Entity_Rec.Last_Update_Date;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Updated_By is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Updated_By := p_Bsc_Kpi_Entity_Rec.Last_Updated_By;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Update_Login is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Update_Login := p_Bsc_Kpi_Entity_Rec.Last_Update_Login;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Resp_Start_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Resp_Start_Date := p_Bsc_Kpi_Entity_Rec.Bsc_Resp_Start_Date;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Resp_End_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Resp_End_Date := p_Bsc_Kpi_Entity_Rec.Bsc_Resp_End_Date;
  end if;

  update BSC_USER_KPI_ACCESS
     set  responsibility_id = l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id
         ,creation_date = l_Bsc_Kpi_Entity_Rec.Creation_Date
         ,created_by = l_Bsc_Kpi_Entity_Rec.Created_By
         ,last_update_date = l_Bsc_Kpi_Entity_Rec.Last_Update_Date
         ,last_updated_by = l_Bsc_Kpi_Entity_Rec.Last_Updated_By
         ,last_update_login = l_Bsc_Kpi_Entity_Rec.Last_Update_Login
         ,start_date = l_Bsc_Kpi_Entity_Rec.Bsc_Resp_Start_Date
         ,end_date = l_Bsc_Kpi_Entity_Rec.Bsc_Resp_End_Date
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPIUsrAcc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPIUsrAcc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UptKPIUsrAcc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UptKPIUsrAcc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_User_Access;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_User_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPIUsrAcc;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  delete from BSC_USER_KPI_ACCESS
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIUsrAcc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIUsrAcc;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelKPIUsrAcc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelKPIUsrAcc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Kpi_User_Access;

/************************************************************************************
************************************************************************************/
procedure Create_Kpi_Default_Values(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_db_object         varchar2(30);

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPIDefVals;
  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- Check that valid id was entered.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- If Analysis Option 0 name is null assign default.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt0_Name is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt0_Name := 'Option ' || to_char(l_Bsc_Kpi_Entity_Rec.Bsc_Num_Options - 1);
  end if;

  l_db_object := 'BSC_KPI_DEFAULTS_B';

  insert into BSC_KPI_DEFAULTS_B( tab_id
                               ,indicator
                               ,format_mask
                               ,color_method
                               ,dim_set_id
                               ,dim_level1_value
                               ,dim_level2_value
                               ,dim_level3_value
                               ,dim_level4_value
                               ,dim_level5_value
                               ,dim_level6_value
                               ,dim_level7_value
                               ,dim_level8_value
                               ,last_update_date
                               ,last_updated_by
                               ,creation_date
                               ,created_by
                               ,last_update_login
                               ,measure_source)
                        values( -1
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Format_Mask
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Method
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Value
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Value
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Value
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Value
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Value
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Value
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Value
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Value
                               ,sysdate
                               ,l_Bsc_Kpi_Entity_Rec.Last_Updated_By
                               ,sysdate
                               ,l_Bsc_Kpi_Entity_Rec.Created_By
                               ,l_Bsc_Kpi_Entity_Rec.Last_Update_Login
                               ,l_Bsc_Kpi_Entity_Rec.Bsc_Measure_Source);

  l_db_object := 'BSC_KPI_DEFAULTS_TL';

  insert into BSC_KPI_DEFAULTS_TL( tab_id
                                  ,indicator
                                  ,language
                                  ,source_lang
                                  ,analysis_option0_name
                                  ,analysis_option1_name
                                  ,analysis_option2_name
                                  ,period_name
                                  ,series_name
                                  ,dim_level1_name
                                  ,dim_level2_name
                                  ,dim_level3_name
                                  ,dim_level4_name
                                  ,dim_level5_name
                                  ,dim_level6_name
                                  ,dim_level7_name
                                  ,dim_level8_name
                                  ,dim_level1_text
                                  ,dim_level2_text
                                  ,dim_level3_text
                                  ,dim_level4_text
                                  ,dim_level5_text
                                  ,dim_level6_text
                                  ,dim_level7_text
                                  ,dim_level8_text)
                             SELECT     -1
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                    ,   L.LANGUAGE_CODE
                                    ,   USERENV('LANG')
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt0_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt1_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt2_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Period_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Series_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Name
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Text
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Text
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Text
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Text
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Text
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Text
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Text
                                    ,   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Text
                                  FROM  FND_LANGUAGES L
                                  WHERE L.INSTALLED_FLAG IN ('I', 'B')
                                  AND   NOT EXISTS
                                  ( SELECT NULL
                                    FROM   BSC_KPI_DEFAULTS_TL T
                                    WHERE  T.indicator =  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                    AND    T.LANGUAGE  = L.LANGUAGE_CODE);


  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDefVals;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDefVals;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDefVals;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPIDefVals;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_Default_Values;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Default_Values(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi_Default_Values';

  select distinct  a.tab_id
                  ,a.format_mask
                  ,a.color_method
                  ,a.dim_set_id
                  ,a.dim_level1_value
                  ,a.dim_level2_value
                  ,a.dim_level3_value
                  ,a.dim_level4_value
                  ,a.dim_level5_value
                  ,a.dim_level6_value
                  ,a.dim_level7_value
                  ,a.dim_level8_value
                  ,a.last_update_date
                  ,a.last_updated_by
                  ,a.creation_date
                  ,a.created_by
                  ,a.last_update_login
                  ,a.measure_source
                  ,b.analysis_option0_name
                  ,b.analysis_option1_name
                  ,b.analysis_option2_name
                  ,b.period_name
                  ,b.series_name
                  ,b.dim_level1_name
                  ,b.dim_level2_name
                  ,b.dim_level3_name
                  ,b.dim_level4_name
                  ,b.dim_level5_name
                  ,b.dim_level6_name
                  ,b.dim_level7_name
                  ,b.dim_level8_name
                  ,b.dim_level1_text
                  ,b.dim_level2_text
                  ,b.dim_level3_text
                  ,b.dim_level4_text
                  ,b.dim_level5_text
                  ,b.dim_level6_text
                  ,b.dim_level7_text
                  ,b.dim_level8_text
             into  x_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Format_Mask
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Method
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Value
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Value
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Value
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Value
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Value
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Value
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Value
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Value
                  ,x_Bsc_Kpi_Entity_Rec.Last_Update_Date
                  ,x_Bsc_Kpi_Entity_Rec.Last_Updated_By
                  ,x_Bsc_Kpi_Entity_Rec.Creation_Date
                  ,x_Bsc_Kpi_Entity_Rec.Created_By
                  ,x_Bsc_Kpi_Entity_Rec.Last_Update_Login
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Measure_Source
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt0_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt1_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt2_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Period_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Series_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Name
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Text
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Text
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Text
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Text
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Text
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Text
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Text
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Text
             from  BSC_KPI_DEFAULTS_B a
                   ,BSC_KPI_DEFAULTS_TL b
            where a.indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              and a.indicator = b.indicator
              and b.language = USERENV('LANG');

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_Default_Values;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Default_Values(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UpdKPIDefVals;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi_Default_Values( p_commit
                              ,p_Bsc_Kpi_Entity_Rec
                              ,l_Bsc_Kpi_Entity_Rec
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data);

  -- update LOCAL language ,source language  and Kpi Id values with PASSED values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Format_Mask is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Format_Mask := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Format_Mask;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Method is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Method := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Method;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Value is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Value := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Value;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Update_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Update_Date := p_Bsc_Kpi_Entity_Rec.Last_Update_Date;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Updated_By is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Updated_By := p_Bsc_Kpi_Entity_Rec.Last_Updated_By;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Creation_Date is not null then
    l_Bsc_Kpi_Entity_Rec.Creation_Date := p_Bsc_Kpi_Entity_Rec.Creation_Date;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Created_By is not null then
    l_Bsc_Kpi_Entity_Rec.Created_By := p_Bsc_Kpi_Entity_Rec.Created_By;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Last_Update_Login is not null then
    l_Bsc_Kpi_Entity_Rec.Last_Update_Login := p_Bsc_Kpi_Entity_Rec.Last_Update_Login;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Measure_Source is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Measure_Source := p_Bsc_Kpi_Entity_Rec.Bsc_Measure_Source;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt0_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt0_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt0_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt1_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt1_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt1_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt2_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt2_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt2_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Period_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Period_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Period_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Series_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Series_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Series_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Name is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Name := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Name;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Text is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Text := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Text;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Text is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Text := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Text;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Text is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Text := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Text;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Text is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Text := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Text;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Text is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Text := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Text;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Text is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Text := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Text;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Text is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Text := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Text;
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Text is not null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Text := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Text;
  end if;

  update BSC_KPI_DEFAULTS_B
     set  tab_id = l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
         ,format_mask = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Format_Mask
         ,color_method = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Method
         ,dim_set_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id
         ,dim_level1_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Value
         ,dim_level2_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Value
         ,dim_level3_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Value
         ,dim_level4_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Value
         ,dim_level5_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Value
         ,dim_level6_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Value
         ,dim_level7_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Value
         ,dim_level8_value = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Value
         ,last_update_date = l_Bsc_Kpi_Entity_Rec.Last_Update_Date
         ,last_updated_by = l_Bsc_Kpi_Entity_Rec.Last_Updated_By
         ,creation_date = l_Bsc_Kpi_Entity_Rec.Creation_Date
         ,created_by = l_Bsc_Kpi_Entity_Rec.Created_By
         ,last_update_login = l_Bsc_Kpi_Entity_Rec.Last_Update_Login
         ,measure_source = l_Bsc_Kpi_Entity_Rec.Bsc_Measure_Source
  where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  update BSC_KPI_DEFAULTS_TL
     set  analysis_option0_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt0_Name
         ,analysis_option1_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt1_Name
         ,analysis_option2_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Anal_Opt2_Name
         ,period_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Period_Name
         ,series_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Series_Name
         ,dim_level1_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Name
         ,dim_level2_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Name
         ,dim_level3_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Name
         ,dim_level4_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Name
         ,dim_level5_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Name
         ,dim_level6_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Name
         ,dim_level7_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Name
         ,dim_level8_name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Name
         ,dim_level1_text = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Text
         ,dim_level2_text = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level2_Text
         ,dim_level3_text = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level3_Text
         ,dim_level4_text = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level4_Text
         ,dim_level5_text = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level5_Text
         ,dim_level6_text = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level6_Text
         ,dim_level7_text = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level7_Text
         ,dim_level8_text = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level8_Text
         ,SOURCE_LANG     = userenv('LANG')
  where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
  and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UpdKPIDefVals;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UpdKPIDefVals;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UpdKPIDefVals;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UpdKPIDefVals;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Update_Kpi_Default_Values;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Default_Values(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPIDefVals;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  delete from BSC_KPI_DEFAULTS_B
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  delete from BSC_KPI_DEFAULTS_TL
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIDefVals;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIDefVals;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelKPIDefVals;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelKPIDefVals;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Kpi_Default_Values;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Bsc_Kpi_Group_Rec     BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;

l_db_object         varchar2(30);

l_count                         number;

begin
  --DBMS_OUTPUT.PUT_LINE('-- Begin BSC_KPI_PVT.Create_Kpi_In_Tab');
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtKPIInTab;
  -- Assign passed records to local record.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;
  --DBMS_OUTPUT.PUT_LINE('l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag = ' || l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag);

  -- Check that valid id was entered.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 1');

  -- Check that valid id was entered.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id  is not null then
    --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 2');

    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_TABS_B'
                                                       ,'tab_id'
                                                       ,l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id);
    --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 3');

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_TAB', l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;
  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 4');


  -- Check that this Group has not been assigned to the tab yet.
  select count(*)
    into l_count
    from BSC_TAB_IND_GROUPS_B
   where tab_id = l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
     and ind_group_id = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id;

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 5');

  -- if group and tab combination does not exist then assign group to Tab.
  if l_count < 1 then

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 6');
--DBMS_OUTPUT.PUT_LINE(' l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id = ' || l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id);

    --populate appropriate values into Record.
    l_Bsc_Kpi_Group_Rec.Bsc_Csf_Id := l_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id;
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id;
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Type;
    l_Bsc_Kpi_Group_Rec.Bsc_Name_Pos_In_Tab := l_Bsc_Kpi_Entity_Rec.Bsc_Name_Pos_In_Tab;
    l_Bsc_Kpi_Group_Rec.Bsc_Name_Justif_In_Tab := l_Bsc_Kpi_Entity_Rec.Bsc_Name_Justif_In_Tab;
    --- Bad logic comment to fixed bug 2650624 -  Possition an size it is getting from tab -1
    --l_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab := l_Bsc_Kpi_Entity_Rec.Bsc_Left_Position_In_Tab;
    --l_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab := l_Bsc_Kpi_Entity_Rec.Bsc_Top_Position_In_Tab;
    --l_Bsc_Kpi_Group_Rec.Bsc_Group_Width := l_Bsc_Kpi_Entity_Rec.Bsc_Group_Width;
    --l_Bsc_Kpi_Group_Rec.Bsc_Group_Height := l_Bsc_Kpi_Entity_Rec.Bsc_Group_Height;
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Name;
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Help;
    l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id;
    l_Bsc_Kpi_Group_Rec.Bsc_Language := l_Bsc_Kpi_Entity_Rec.Bsc_Language;
    l_Bsc_Kpi_Group_Rec.Bsc_Source_Language := l_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;

    l_db_object := 'Update_Kpi_Group';

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 7');
--DBMS_OUTPUT.PUT_LINE(' l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id = ' || l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id);
--DBMS_OUTPUT.PUT_LINE(' l_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab = ' || l_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab);
--DBMS_OUTPUT.PUT_LINE(' l_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab = ' || l_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab);
--DBMS_OUTPUT.PUT_LINE(' l_Bsc_Kpi_Group_Rec.Bsc_Group_Width = ' || l_Bsc_Kpi_Group_Rec.Bsc_Group_Width);
--DBMS_OUTPUT.PUT_LINE(' l_Bsc_Kpi_Group_Rec.Bsc_Group_Height = ' || l_Bsc_Kpi_Group_Rec.Bsc_Group_Height);

    BSC_KPI_GROUP_PUB.Update_Kpi_Group( p_commit
                                       ,l_Bsc_Kpi_Group_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

  end if;

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 8');


  -- Call procedure to update KPI with tab information.  Set some values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Model_Flag := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Left_Position_In_Tab := null;
  l_Bsc_Kpi_Entity_Rec.Bsc_Top_Position_In_Tab := null;
  l_Bsc_Kpi_Entity_Rec.Bsc_Group_Width := null;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Backcolor := null;

  l_db_object := 'BSC_TAB_INDICATORS';

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 9');

  insert into BSC_TAB_INDICATORS( tab_id
                                 ,indicator
                                 ,bsc_model_flag
                                 ,left_position
                                 ,top_position
                                 ,width
                                 ,height
                                 ,backcolor)
                          values( l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Model_Flag
                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Left_Position_In_Tab
                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Top_Position_In_Tab
                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Group_Width
                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Group_Height
                                 ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Backcolor);

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Kpi_In_Tab -  Flag 10');

  Update_Kpi_In_Tab( p_commit
                    ,l_Bsc_Kpi_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);


  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

  --DBMS_OUTPUT.PUT_LINE(' -- End   BSC_KPI_PVT.Create_Kpi_In_Tab');


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIInTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtKPIInTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtKPIInTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtKPIInTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_In_Tab;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_db_object         varchar2(30);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_db_object := 'Retrieve_Kpi_In_Tab';

  select distinct  tab_id
                  ,bsc_model_flag
                  ,left_position
                  ,top_position
                  ,width
                  ,height
                  ,backcolor
             into  x_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Model_Flag
                  -- This is not KPI Group position and size
                  -- It is KPI position and Size for Stratege Map View
                  -- Not use yet it I-Builder
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Left_Position_In_Tab
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Top_Position_In_Tab
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Group_Width
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Group_Height
                  ,x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Backcolor
             from  BSC_TAB_INDICATORS
            where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', l_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Retrieve_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Retrieve_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_In_Tab;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UpdKPIInTab;
   --DBMS_OUTPUT.PUT_LINE(' -- Begin   BSC_KPI_PVT.Update_Kpi_In_Tab');

  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

   --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Update_Kpi_In_Tab -  Flag 1');
   --DBMS_OUTPUT.PUT_LINE(' p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag = ' || p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag);

  -- Update prototype flag.

  update BSC_KPIS_B
     set prototype_flag = nvl(p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag,7)
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
     and decode(prototype_flag, 0, 8, prototype_flag) > 7;

   --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Update_Kpi_In_Tab -  Flag 2');

  -- Update Kpi defaults.
  update BSC_KPI_DEFAULTS_B
     set tab_id = p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

   --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Update_Kpi_In_Tab -  Flag 3');

  update BSC_KPI_DEFAULTS_TL
     set tab_id = p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

   --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Update_Kpi_In_Tab -  Flag 4');

  -- Update Kpi Dim Level Information
  update BSC_KPI_DIM_LEVELS_B
     set default_value = 'T'
   where (default_value like 'D%')
     and indicator =  p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

   --DBMS_OUTPUT.PUT_LINE(' -- End BSC_KPI_PVT.Update_Kpi_In_Tab ');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UpdKPIInTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UpdKPIInTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UpdKPIInTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UpdKPIInTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_In_Tab;


/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_DelKPIInTab;
  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  delete from BSC_TAB_INDICATORS
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
   -- Reminder:  Check to see if tab id needs to be specified.
   -- and tab_id = p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIInTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_DelKPIInTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_DelKPIInTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_DelKPIInTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Delete_Kpi_In_Tab;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Time_Stamp(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UptKPITimSta;
  update BSC_KPIS_B
     set last_update_date = sysdate
   where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPITimSta;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UptKPITimSta;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UptKPITimSta;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UptKPITimSta;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Update_Kpi_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Update_Kpi_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Time_Stamp;

/************************************************************************************
************************************************************************************/

procedure Create_Master_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_count             number;

--The following variables are needed as temporary holders.
l_option_ids                            varchar2(100);
l_occur                                 number;
l_beg_str                               number;
l_end_str                               number;
l_opt_id                                varchar2(5);


begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtMastKPI;
  --DBMS_OUTPUT.PUT_LINE('-- Begin BSC_KPI_PVT.Create_Master_Kpi');

  -- Check that valid id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Master_Kpi  Flag 1');

  -- Check that valid tab id was entered.
  if p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id is not null then
    --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Master_Kpi  Flag 2');

    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_TABS_B'
                                                       ,'tab_id'
                                                       ,p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id);
    --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Master_Kpi  Flag 3');

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;
  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Master_Kpi  Flag 4');


  -- set all values of the local record equal to the record passed.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- set entry for shared flag equal to 1.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag := 1;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind := null;

  -- Call update procedure (this will update the shared flag).

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Master_Kpi  Flag 5');

  Update_Kpi( p_commit
             ,l_Bsc_Kpi_Entity_Rec
             ,x_return_status
             ,x_msg_count
             ,x_msg_data);

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Master_Kpi  Flag 6');

  --DBMS_OUTPUT.PUT_LINE(' l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag  = ' || l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag );


  -- Now assign this KPI to the tab.

  Create_Kpi_In_Tab( p_commit
                    ,l_Bsc_Kpi_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Master_Kpi  Flag 7');

  -- show All the analysis options.
  update BSC_KPI_ANALYSIS_OPTIONS_B
    set USER_LEVEL1 = USER_LEVEL0
    where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  --DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Master_Kpi  Flag 10');

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

    --DBMS_OUTPUT.PUT_LINE('-- End BSC_KPI_PVT.Create_Master_Kpi');


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtMastKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtMastKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtMastKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Master_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Master_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtMastKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Master_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Master_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Master_Kpi;

/************************************************************************************
************************************************************************************/
procedure Create_Shared_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

TYPE Recdc_value        IS REF CURSOR;
dc_value            Recdc_value;

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec; -- local Record.
l_x_Bsc_Kpi_Entity_Rec      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec; -- to keep values
                                                                -- from retrieve procedures.

l_Bsc_Dim_Set_Rec       BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
l_x_Bsc_Dim_Set_Rec     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_Bsc_Option_Rec        BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
l_x_Bsc_Option_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;

l_sql                   VARCHAR2(2000);
l_count                 NUMBER;
l_kpi_id                NUMBER;

--The following variableS ARE NEEDED AS TEMPORARy holders.
l_Dim_Set_Id            NUMBER;
l_Dset_Dim_Level_Index  NUMBER;
l_Level_Name            VARCHAR2(30);
l_option_id             NUMBER;

l_option_ids            VARCHAR2(100);
l_occur                 NUMBER;
l_beg_str               NUMBER;
l_end_str               NUMBER;

l_opt_id                VARCHAR2(5);

l_kpi_source            NUMBER;
l_master_opt_default    NUMBER;
l_def_opt               NUMBER;
l_prototype_flag        NUMBER;
l_temp                  VARCHAR2(2000);
l_config_type           BSC_KPIS_B.config_type%TYPE;
l_short_name            BSC_KPIS_B.short_name%TYPE;


begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_CrtShaKPI;
  --DBMS_OUTPUT.PUT_LINE('-- Begin BSC_KPI_PVT.Create_Shared_Kpi');

  -- set the local RECORD equal to the passed RECORD.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- In order to create a shared KPI we will use a Function (create by hcamacho)
  -- which copies all necessary data from a source Indicator to a Target Indicator.
  -- After we will change necessary values to make the new Indicator a shared
  -- Indicator.

  -- Get the next id available for the current Kpi.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_KPIS_B'
                                                                             ,'indicator');
--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 1');
--DBMS_OUTPUT.PUT_LINE(' New KPI code := ' || l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);

  Retrieve_Kpi( p_commit
               ,p_Bsc_Kpi_Entity_Rec
               ,l_x_Bsc_Kpi_Entity_Rec
               ,x_return_status
               ,x_msg_count
               ,x_msg_data);

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 2');

  l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Language;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Source_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name :=NULL;

   if l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id is not null then

      SELECT COUNT(1) INTO l_Count
      FROM   BSC_TAB_IND_GROUPS_B
      WHERE  IND_GROUP_ID = l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id;

      if l_count = 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KGROUP_ID');
        FND_MESSAGE.SET_TOKEN('BSC_KGROUP',l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    else
      FND_MESSAGE.SET_NAME('BSC','BSC_NO_KGROUP_ID_ENTERED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  end if;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag  :=   2;
  Create_Kpi( p_commit
             ,l_x_Bsc_Kpi_Entity_Rec
             ,x_return_status
             ,x_msg_count
             ,x_msg_data);

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 3');
--DBMS_OUTPUT.PUT_LINE(' p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := ' || p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);

  /*Retrieve_Kpi_Defaults( p_commit
                        ,p_Bsc_Kpi_Entity_Rec
                        ,l_x_Bsc_Kpi_Entity_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);


  l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id := l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Language;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Source_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 4');
--DBMS_OUTPUT.PUT_LINE('l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := ' || l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);

  Create_Kpi_Defaults( p_commit
                      ,l_x_Bsc_Kpi_Entity_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 5');*/

  Retrieve_Kpi_In_Tab( p_commit
                      ,p_Bsc_Kpi_Entity_Rec
                      ,l_x_Bsc_Kpi_Entity_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 6');

  l_x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id := l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Language;
  l_x_Bsc_Kpi_Entity_Rec.Bsc_Source_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;


  Create_Kpi_In_Tab( p_commit
                    ,l_x_Bsc_Kpi_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 7');

  BSC_DESIGNER_PVT.Duplicate_KPI_Metadata( p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                          ,l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                                          ,0
                                          ,'');

  --For Simulation type of  objectives we need to copy
  -- data from ak_regions and tab_view_labels also
  SELECT config_type,short_name
  INTO   l_config_type,l_short_name
  FROM   bsc_kpis_vl
  WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  IF(l_config_type =BSC_SIMULATION_VIEW_PUB.c_TYPE AND l_short_name IS NOT NULL) THEN

    BSC_SIMULATION_VIEW_PUB.copy_sim_metadata
    (
       p_source_kpi      =>  p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
      ,p_target_kpi      =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
      ,x_return_status   =>  x_return_status
      ,x_msg_count       =>  x_msg_count
      ,x_msg_data        =>  x_msg_data
    );
     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;


--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 8');

  select decode(property_value,1,1,3)
         into l_prototype_flag
    from bsc_sys_init
   where property_code = 'SYSTEM_STAGE';

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 9');

  -- Set shared flag values.
  update BSC_KPIS_B
     set  share_flag = 2
         ,prototype_flag = l_prototype_flag
         ,source_indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 10');

  BSC_DESIGNER_PVT.ActionFlag_Change(l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id, BSC_DESIGNER_PVT.G_ActionFlag.Prototype);

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 11');

  -- show All the analysis options.
  update BSC_KPI_ANALYSIS_OPTIONS_B
    set USER_LEVEL1 = USER_LEVEL0
    where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  --  Fix issue in bug 3248729
  /* Delete Rows in BSC_KPI_DATA_TABLES for the Share KPI
    We can not use procedure Delete_Kpi_Data_tables because of the
    validation added when the KPI is deleting */

   DELETE FROM BSC_KPI_DATA_TABLES
   WHERE  INDICATOR = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  --  Fix issue in bug 3248729


--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 12');

  -- Get a responsibility id for BSC_MANAGER
  select responsibility_id
      into l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id
      from FND_RESPONSIBILITY
     where responsibility_key = 'BSC_Manager';

  -- set some values
  l_Bsc_Kpi_Entity_Rec.Created_By:= 0;
  l_Bsc_Kpi_Entity_Rec.Last_Updated_By:= 0;
  l_Bsc_Kpi_Entity_Rec.Last_Update_Login:= 0;
  l_Bsc_Kpi_Entity_Rec.Last_Update_Login:= 0;

--DBMS_OUTPUT.PUT_LINE(' BSC_KPI_PVT.Create_Shared_Kpi - Flag 13');

  -- Grant access
  BSC_KPI_PUB.Create_Kpi_User_Access( p_commit
                                     ,l_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);


  -- Get a responsibility id for BSC_PMD_USER

  /*select responsibility_id
      into l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id
      from FND_RESPONSIBILITY
     where responsibility_key = 'BSC_PMD_USER';

  BSC_KPI_PUB.Create_Kpi_User_Access( p_commit
                                     ,l_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);*/



  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

--DBMS_OUTPUT.PUT_LINE('-- End BSC_KPI_PVT.Create_Shared_Kpi');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtShaKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_CrtShaKPI;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_CrtShaKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Shared_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Shared_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_CrtShaKPI;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Create_Shared_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Create_Shared_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Shared_Kpi;

/************************************************************************************
************************************************************************************/

procedure Move_Tab(
  p_tab_id          number
 ,p_tab_index           number
 ,x_return_status   OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Tbl        BSC_SCORECARD_PUB.Bsc_Tab_Entity_Tbl;

TYPE Recdc_value                IS REF CURSOR;
dc_value                        Recdc_value;

l_cnt               number;

l_sql               varchar2(2000);

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_MoveTab;
  -- Check that valid id was entered.
  if p_tab_id is not null then
    l_cnt := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_TABS_B'
                                                     ,'tab_id'
                                                     ,p_tab_id);
    if l_cnt = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', p_tab_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_TAB', p_tab_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_sql := 'select distinct tab_id, tab_index ' ||
           '  from BSC_TABS_B ' ||
           ' where tab_index >= :1' ||
           '   and tab_id !=  :2' ||
           ' order by tab_index asc';

  l_cnt := 0;
  open dc_value for l_sql using p_tab_index, p_tab_id ;
    loop
      fetch dc_value into l_Bsc_Kpi_Entity_Tbl(l_cnt + 1).Bsc_Tab_Id,
                          l_Bsc_Kpi_Entity_Tbl(l_cnt + 1).Bsc_Tab_Index;
      exit when dc_value%NOTFOUND;
      l_cnt := l_cnt + 1;
    end loop;
  close dc_value;

  for i in 1..l_Bsc_Kpi_Entity_Tbl.count loop
    update BSC_TABS_B
       set tab_index = l_Bsc_Kpi_Entity_Tbl(i).Bsc_Tab_Index + 1
     where tab_id = l_Bsc_Kpi_Entity_Tbl(i).Bsc_Tab_Id;
  end loop;

--  commit;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_MoveTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_MoveTab;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_MoveTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Move_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Move_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_MoveTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Move_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Move_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Move_Tab;

/************************************************************************************
************************************************************************************/

function Validate_Tab(
  p_Tab_Name        IN  varchar2
) return number is

l_count         number;

begin

  select count(*)
    into l_count
    from BSC_TABS_TL
   where upper(name) = upper(p_Tab_Name);

  return l_count;

EXCEPTION
  when others then
    null;

end Validate_Tab;

/************************************************************************************
************************************************************************************/

function Validate_Kpi_Group(
  p_Kpi_Group_Name      IN  varchar2
) return number is

l_count         number;

begin

  select count(*)
    into l_count
    from BSC_TAB_IND_GROUPS_TL
   where upper(name) = upper(p_Kpi_Group_Name);

  return l_count;

EXCEPTION
  when others then
    null;

end Validate_Kpi_Group;

/************************************************************************************
************************************************************************************/

function Validate_Kpi(
  p_Kpi_Name                  IN      varchar2
) return number is

l_count                 number;

begin

  select count(*)
    into l_count
    from BSC_KPIS_TL
   where upper(name) = upper(p_Kpi_Name);

  return l_count;

EXCEPTION
  when others then
    null;

end Validate_Kpi;

/************************************************************************************
************************************************************************************/

procedure Set_Default_Option(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

TYPE Recdc_value                        IS REF CURSOR;
dc_value                                Recdc_value;

l_sql                                   varchar2(5000);

l_count                                 number;
l_share_flag                            number;
l_proto_flag                            number;
l_shared_kpi                            number;
l_def_option                            number;

CURSOR  c_Select_Indicator IS
SELECT  INDICATOR
FROM    BSC_KPIS_B
WHERE   SOURCE_INDICATOR = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id
AND     PROTOTYPE_FLAG <> BSC_KPI_PUB.Delete_Kpi_Flag;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;
  SAVEPOINT BscKpiPvt_SetDefOption;
  -- First step is to see if the default has been deselected. If it has, set another
  -- default if it is the Master KPI, if it is not the Master KPI, then reselect the
  -- default from the Master.
  select count(*)
    into l_count
    from BSC_KPI_ANALYSIS_OPTIONS_B
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id
     and analysis_group_id = 0
     and user_level1 = 1;

  if l_count = 0 then

    -- Check if this is the Master KPI.
     SELECT SHARE_FLAG, PROTOTYPE_FLAG
     INTO   l_share_flag, l_proto_flag
     FROM   BSC_KPIS_B
     WHERE  INDICATOR = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id;

    if ((l_share_flag = 1) and (l_proto_flag <> BSC_KPI_PUB.DELETE_KPI_FLAG)) then

      -- Second step is to set the default option (1) by selecting the first displayed
      -- option.  At this point all displayed options are flagged with 2.
      update BSC_KPI_ANALYSIS_OPTIONS_B
         set user_level1 = 1
       where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id
         and analysis_group_id = 0
         and option_id = (select option_id
                            from BSC_KPI_ANALYSIS_OPTIONS_B
                           where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id
                             and user_level1 = 2
                             and rownum < 2);

      -- store the default option.
      select option_id
        into l_def_option
        from BSC_KPI_ANALYSIS_OPTIONS_B
       where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id
         and analysis_group_id = 0
         and user_level1 = 1;

      -- update the Default option in KPI ANALYSIS GROUPS
      update BSC_KPI_ANALYSIS_GROUPS
         set default_value = l_def_option
       where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id;


      -- Now all shared Kpis need to be updated.  Get these shared Indicators.

      FOR SrcInd IN c_Select_Indicator LOOP
          l_shared_kpi := SrcInd.INDICATOR;

          UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
          SET    USER_LEVEL1 = 2
          WHERE  INDICATOR = l_shared_kpi
          AND    ANALYSIS_GROUP_ID = 0
          AND    USER_LEVEL1 = 1;

                    -- then set the default option.
          UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
          SET    USER_LEVEL1 = 1
          WHERE  INDICATOR = l_shared_kpi
          AND    ANALYSIS_GROUP_ID = 0
          AND    OPTION_ID = L_DEF_OPTION;

                    -- update the Default option in KPI ANALYSIS GROUPS
          UPDATE BSC_KPI_ANALYSIS_GROUPS
          SET    DEFAULT_VALUE = l_def_option
          WHERE  INDICATOR = l_shared_kpi;

      END LOOP;

    elsif ((l_share_flag = 2) and (l_proto_flag <> BSC_KPI_PUB.DELETE_KPI_FLAG)) then-- this is a shared indicator.

      -- Get the source indicator for this shared indicator.
      select source_indicator
        into l_shared_kpi
        from BSC_KPIS_B
       where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id;

      -- Get the default analysis option id.
      select default_value
        into l_def_option
        from BSC_KPI_ANALYSIS_GROUPS
       where indicator = l_shared_kpi
         and analysis_group_id = 0;

      update BSC_KPI_ANALYSIS_OPTIONS_B
         set user_level1 = 1
       where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id
         and analysis_group_id = 0
         and option_id = l_def_option;

    end if; -- l_share_flag


  end if; -- l_count

  -- Block for Force Default Option ends here.

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_SetDefOption;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_SetDefOption;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_SetDefOption;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Set_Default_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Set_Default_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_SetDefOption;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Set_Default_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Set_Default_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Set_Default_Option;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Set_Default_Value_By_Option_ID
(    p_Kpi_Id                  NUMBER
   , p_group_Id                NUMBER
   , p_parent_option_Id        NUMBER
   , p_grand_parent_option_Id  NUMBER
   , p_option_Id               NUMBER
) IS
    l_Dependency_Flag          NUMBER  := 0;
    l_old_option_id            NUMBER  := 0;
    l_old_parent_option_Id     NUMBER  := 0;
    l_old_grandparent_option_Id       NUMBER  := 0;
    l_Default_Value            NUMBER  := 0;
    l_count                    NUMBER  := 0;

    CURSOR  c_old_option_id IS
    SELECT  Option_Id, Parent_Option_Id, Grandparent_Option_Id
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Indicator         = p_Kpi_Id
    AND     Analysis_Group_ID = p_group_Id
    AND     User_Level0 =  1;
BEGIN
    SAVEPOINT BSCSeefaulValPVT;
    SELECT  Dependency_Flag, Default_Value
    INTO    l_Dependency_Flag, l_Default_Value
    FROM    BSC_KPI_ANALYSIS_GROUPS
    WHERE   Indicator         = p_Kpi_Id
    AND     Analysis_Group_Id = p_group_Id;

    -- find current default options
    IF (c_old_option_id%ISOPEN) THEN
        CLOSE c_old_option_id;
    END IF;
    OPEN c_old_option_id;
        FETCH c_old_option_id
        INTO  l_old_option_id
            , l_old_parent_option_Id
            , l_old_grandparent_option_Id;
    CLOSE c_old_option_id;

    IF (l_Dependency_Flag = 0) THEN -- for indenpendent

         IF (l_old_option_id <> p_option_Id) THEN
            UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
            SET     User_Level0        =  1
                 ,  User_Level1        =  1
            WHERE   Indicator          =  p_Kpi_Id
            AND     Analysis_Group_Id  =  p_group_Id
            AND     Option_Id          =  p_option_Id;

            UPDATE  BSC_KPI_ANALYSIS_GROUPS
            SET     Default_Value     =   p_option_Id
            WHERE   Indicator         =   p_Kpi_Id
            AND     Analysis_Group_Id =   p_group_Id;

            -- change previous default option id back to normal
            UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
            SET     User_Level0        =  2
                 ,  User_Level1        =  2
            WHERE   Indicator          =  p_Kpi_Id
            AND     Analysis_Group_Id  =  p_group_Id
            AND     Option_Id          =  l_old_option_id;

         END IF;

    ELSE -- for dependent
         IF (p_group_Id = 0) THEN

             IF (l_old_option_id <> p_option_Id) THEN

                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0        =  1
                     ,  User_Level1        =  1
                WHERE   Indicator          =  p_Kpi_Id
                AND     Analysis_Group_Id  =  p_group_Id
                AND     Option_Id          =  p_option_Id;

                UPDATE  BSC_KPI_ANALYSIS_GROUPS
                SET     Default_Value     =   p_option_Id
                WHERE   Indicator         =   p_Kpi_Id
                AND     Analysis_Group_Id =   p_group_Id;

                -- change previous default option id back to normal
                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0        =  2
                 ,  User_Level1            =  2
                WHERE   Indicator          =  p_Kpi_Id
                AND     Analysis_Group_Id  =  p_group_Id
                AND     Option_Id          =  l_old_option_id;

             END IF;
         ELSIF (p_group_Id = 1) THEN

             IF (l_old_option_id <> p_option_Id ) OR (l_old_parent_option_Id <> p_Parent_Option_Id) THEN

                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0        =  1
                     ,  User_Level1        =  1
                WHERE   Indicator          =  p_Kpi_Id
                AND     Analysis_Group_Id  =  p_group_Id
                AND     Option_Id          =  p_option_Id
                AND     Parent_Option_Id   =  p_Parent_Option_Id;

                UPDATE  BSC_KPI_ANALYSIS_GROUPS
                SET     Default_Value     =   p_option_Id
                WHERE   Indicator         =   p_Kpi_Id
                AND     Analysis_Group_Id =   p_group_Id;

                -- change previous default option id back to normal
                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0        =  2
                     ,  User_Level1        =  2
                WHERE   Indicator          =  p_Kpi_Id
                AND     Analysis_Group_Id  =  p_group_Id
                AND     Option_Id          =  l_old_option_Id
                AND     Parent_Option_Id   =  l_old_parent_option_Id;

             END IF;
         ELSIF (p_group_Id = 2) THEN

             IF (l_old_option_id <> p_option_Id ) OR (l_old_parent_option_Id <> p_Parent_Option_Id)
                                                  OR (l_old_grandparent_option_Id <> p_Grand_Parent_Option_Id) THEN

                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0            =  1
                     ,  User_Level1            =  1
                WHERE   Indicator              =  p_Kpi_Id
                AND     Analysis_Group_Id      =  p_group_Id
                AND     Option_Id              =  p_option_Id
                AND     Parent_Option_Id       =  p_Parent_Option_Id
                AND     Grandparent_Option_Id  =  p_Grand_Parent_Option_Id;

                UPDATE  BSC_KPI_ANALYSIS_GROUPS
                SET     Default_Value     =   p_option_Id
                WHERE   Indicator         =   p_Kpi_Id
                AND     Analysis_Group_Id =   p_group_Id;

                -- change previous default option id back to normal
                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0            =  2
                     ,  User_Level1            =  2
                WHERE   Indicator              =  p_Kpi_Id
                AND     Analysis_Group_Id      =  p_group_Id
                AND     Option_Id              =  l_old_option_Id
                AND     Parent_Option_Id       =  l_old_parent_option_Id
                AND     Grandparent_Option_Id  =  l_old_grandparent_option_Id;

             END IF;
           END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO BSCSeefaulValPVT;
        IF (c_old_option_id%ISOPEN) THEN
            CLOSE c_old_option_id;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS at Set_Default_Value_By_ID '||SQLERRM);
        RAISE;
END Set_Default_Value_By_Option_ID;

/************************************************************************************
************************************************************************************/

procedure Set_Default_Option_MG(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_source_kpi            number;
l_proto_flag            number;
l_default_option        number;
l_default_parent_option     number;
l_default_grandparent_option    number;
l_group_count           number;
l_dependency1_flag      number;
l_dependency2_flag      number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_SetDefOptionMG;
  -- Get the source indicator for this shared kpi.
  SELECT Source_Indicator, Prototype_Flag
  INTO   l_source_kpi, l_proto_flag
  FROM   BSC_KPIS_B
  WHERE  INDICATOR = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  IF (l_proto_flag <> BSC_KPI_PUB.Delete_Kpi_Flag) THEN
      -- Get the number of analysis groups in this or in source kpi.
      select max(analysis_group_id)
        into l_group_count
        from BSC_KPI_ANALYSIS_GROUPS
       where indicator = l_source_kpi;

      -- Get the default option id for the first analysis groups.
      select default_value
        into l_default_option
        from BSC_KPI_ANALYSIS_GROUPS
       where indicator = l_source_kpi
         and analysis_group_id = 0;

      -- Set this default option for the display flag
      update BSC_KPI_ANALYSIS_OPTIONS_B
         set user_level1 = 1
       where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
         and analysis_group_id = 0
         and option_id = l_default_option;

      -- The fact that we are in this procedure implies this is a multi group
      -- indicator.

      -- Determine if there is a dependency between groups 1 and 0, and get the
      -- default option id.
      select dependency_flag, default_value
        into l_dependency1_flag, l_default_option
        from BSC_KPI_ANALYSIS_GROUPS
       where indicator = l_source_kpi
         and analysis_group_id = 1;

      -- If there is no dependency apply This flag without filtering on parent id.
      if l_dependency1_flag <> 1 then

        update BSC_KPI_ANALYSIS_OPTIONS_B
           set user_level1 = 1
         where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
           and analysis_group_id = 1
           and option_id = l_default_option;

      else

        select default_value
          into l_default_parent_option
          from BSC_KPI_ANALYSIS_GROUPS
         where indicator = l_source_kpi
           and analysis_group_id = 0;

        update BSC_KPI_ANALYSIS_OPTIONS_B
           set user_level1 = 1
         where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
           and analysis_group_id = 1
           and option_id = l_default_option
           and parent_option_id = l_default_parent_option;


      end if;

      -- check if this kpi has more than two analysis groups.
      if l_group_count > 1 then

        -- Determine if there is a dependency between groups 2 and 1.
        select dependency_flag, default_value
          into l_dependency2_flag, l_default_option
          from BSC_KPI_ANALYSIS_GROUPS
         where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
           and analysis_group_id = 2;

        -- if there is no dependency between groups 1 and 0, and 2 and 1 apply flag
        if l_dependency1_flag <> 1  and l_dependency2_flag <> 1 then

          update BSC_KPI_ANALYSIS_OPTIONS_B
              set user_level1 = 1
            where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              and analysis_group_id = 2
              and option_id = l_default_option;

        elsif l_dependency1_flag <> 1 then

          select default_value
            into l_default_parent_option
            from BSC_KPI_ANALYSIS_GROUPS
           where indicator = l_source_kpi
             and analysis_group_id = 1;

           update BSC_KPI_ANALYSIS_OPTIONS_B
              set user_level1 = 1
            where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              and analysis_group_id = 2
              and option_id = l_default_option
              and parent_option_id = l_default_parent_option;

        else -- dependency between groups 0 and 1

          -- If there is no dependency flag between 2 an 1 then do not filter.
          if l_dependency2_flag <> 1 then

            update BSC_KPI_ANALYSIS_OPTIONS_B
               set user_level1 = 1
             where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
               and analysis_group_id = 2
               and option_id = l_default_option;

          else

            select default_value
              into l_default_parent_option
              from BSC_KPI_ANALYSIS_GROUPS
             where indicator = l_source_kpi
               and analysis_group_id = 1;

            select default_value
              into l_default_grandparent_option
              from BSC_KPI_ANALYSIS_GROUPS
             where indicator = l_source_kpi
               and analysis_group_id = 0;

            update BSC_KPI_ANALYSIS_OPTIONS_B
               set user_level1 = 1
             where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
               and analysis_group_id = 2
               and option_id = l_default_option
               and parent_option_id = l_default_parent_option
               and grandparent_option_id = l_default_grandparent_option;

          end if;

        end if;

      end if;

  END IF;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_SetDefOptionMG;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_SetDefOptionMG;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_SetDefOptionMG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Set_Default_Option_MG ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Set_Default_Option_MG ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_SetDefOptionMG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Set_Default_Option_MG ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Set_Default_Option_MG ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Set_Default_Option_MG;

/************************************************************************************
************************************************************************************/

procedure Assign_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) IS

 l_option_id            number;
 l_parent_option_id         number;
 l_grandparent_option_id    number;
 l_Bsc_kpi_Entity_Rec           BSC_KPI_PUB.Bsc_kpi_Entity_Rec;

Begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_AssAnaOpts;
  --DBMS_OUTPUT.PUT_LINE('Begin BSC_KPI_PVT.Assign_Analysis_Option');

  l_parent_option_id := 0;
  l_grandparent_option_id := 0;

  if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 0 then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  elsif p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 1 then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1;
    l_parent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  else -- if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 2  then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2;
    l_parent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1;
    l_grandparent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  end if;

  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id = '  || p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = '  || p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  l_option_id = '  || l_option_id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  l_parent_option_id = '  || l_parent_option_id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  l_grandparent_option_id = '  || l_grandparent_option_id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag = '  || p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag);


  -- Update the Analysis Option Set the option visible
  update BSC_KPI_ANALYSIS_OPTIONS_B
     set user_level1 = user_level0
     where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
       and analysis_group_id = p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id
       and option_id = l_option_id
       and parent_option_id = l_parent_option_id
       and grandparent_option_id = l_grandparent_option_id;

  -- Set Visible the Parent Option if it apply
  if p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag <> 0 and p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id > 0 then

    l_Bsc_kpi_Entity_Rec := p_Bsc_kpi_Entity_Rec;
    if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id =  2 then
        l_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id := 1;
        l_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag := l_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag;
    else
        l_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id := 0;
        l_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag := 0;
    end if;
    l_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag := 0;

    Assign_Analysis_Option(l_Bsc_kpi_Entity_Rec
                ,x_return_status
                ,x_msg_count
                ,x_msg_data);
  end if;

  --DBMS_OUTPUT.PUT_LINE('End BSC_KPI_PVT.Assign_Analysis_Option');


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_AssAnaOpts;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_AssAnaOpts;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_AssAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Assign_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Assign_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_AssAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Assign_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Assign_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
End Assign_Analysis_Option;

/************************************************************************************
************************************************************************************/

procedure Unassign_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) IS
 l_option_id            number;
 l_parent_option_id         number;
 l_grandparent_option_id    number;
 l_count            number;
 l_Bsc_kpi_Entity_Rec           BSC_KPI_PUB.Bsc_kpi_Entity_Rec;
Begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT BscKpiPvt_UnAssAnaOpts;
  --DBMS_OUTPUT.PUT_LINE('Begin BSC_KPI_PVT.Unassign_Analysis_Option');

  l_parent_option_id := 0;
  l_grandparent_option_id := 0;

  if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 0 then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  elsif p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 1 then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1;
    l_parent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  else -- if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 2  then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2;
    l_parent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1;
    l_grandparent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  end if;

  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id = '  || p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = '  || p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  l_option_id = '  || l_option_id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  l_parent_option_id = '  || l_parent_option_id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  l_grandparent_option_id = '  || l_grandparent_option_id);
  --DBMS_OUTPUT.PUT_LINE('--BSC_KPI_PVT.Assign_Analysis_Option -  p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag = '  || p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag);

  -- Update the Analysis Option to hide the option
  update BSC_KPI_ANALYSIS_OPTIONS_B
     set user_level1 = 0
     where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
       and analysis_group_id = p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id
       and option_id = l_option_id
       and parent_option_id = l_parent_option_id
       and grandparent_option_id = l_grandparent_option_id
       and user_level0 > 1;

  -- Hide the Parent Option if all the child Analysis Options are hide
  if p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag <> 0 and p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id > 0 then

    -- count the option visible under the parent
    select count(option_id)
      into l_count
      from BSC_KPI_ANALYSIS_OPTIONS_B
      where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
        and analysis_group_id = p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id
        and parent_option_id = l_parent_option_id
        and grandparent_option_id = l_grandparent_option_id
        and user_level1 > 0;

    -- l_count = 0 means there is not more option under parent
    -- then the parent option must to be hide too
    if l_count = 0 then

      l_Bsc_kpi_Entity_Rec := p_Bsc_kpi_Entity_Rec;
      l_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag := 0;

      if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 2 then
        l_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id := 1;
        l_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag := p_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag;
      else
        l_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id := 0;
        l_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag := 0;
      end if;

      Unassign_Analysis_Option(l_Bsc_kpi_Entity_Rec
                ,x_return_status
                ,x_msg_count
                ,x_msg_data);
    end if;

  end if;

  --DBMS_OUTPUT.PUT_LINE('End BSC_KPI_PVT.Unassign_Analysis_Option');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscKpiPvt_UnAssAnaOpts;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscKpiPvt_UnAssAnaOpts;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BscKpiPvt_UnAssAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Unassign_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Unassign_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BscKpiPvt_UnAssAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Unassign_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Unassign_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
End Unassign_Analysis_Option;


/************************************************************************************
************************************************************************************/

function Is_Analysis_Option_Selected(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) return varchar2 IS

 l_option_id            number;
 l_parent_option_id         number;
 l_grandparent_option_id    number;
 l_count            number;
 l_Bsc_kpi_Entity_Rec           BSC_KPI_PUB.Bsc_kpi_Entity_Rec;
 l_temp                         varchar2(5);
Begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- p_Bsc_kpi_Entity_Rec.Bsc_kpi_Id
  -- p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id
  -- p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag
  -- p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0
  -- p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1
  -- p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2


  --DBMS_OUTPUT.PUT_LINE('Begin  BSC_KPI_PVT.Is_Analysis_Option_Selected ');

  l_parent_option_id := 0;
  l_grandparent_option_id := 0;

  if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 0 then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  elsif p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 1 then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1;
    l_parent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  else -- if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 2  then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2;
    l_parent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1;
    l_grandparent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  end if;

  -- see if the option is selected
  Select count(indicator)
     into l_count
     from BSC_KPI_ANALYSIS_OPTIONS_B
     where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
       and analysis_group_id = p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id
       and option_id = l_option_id
       and parent_option_id = l_parent_option_id
       and grandparent_option_id = l_grandparent_option_id
       and user_level1 <> 0;

  l_temp := FND_API.G_FALSE;

  -- count > 0 means the option is selected
  if l_count > 0 then

    if p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag = 0 or p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 0 then
      -- when option is not dependent
      l_temp := FND_API.G_TRUE;
    else
      -- Evalute if parent Parent Option is selected
      l_Bsc_kpi_Entity_Rec := p_Bsc_kpi_Entity_Rec;
      if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 2 then
          l_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id := 1;
          l_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag := l_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag;
      else
          l_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id := 0;
          l_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag := 0;
      end if;
      l_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag := 0;

      l_temp := Is_Analysis_Option_Selected(l_Bsc_kpi_Entity_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);
    end if;

  end if;

  --DBMS_OUTPUT.PUT_LINE('End BSC_KPI_PVT.Is_Analysis_Option_Selected  -  return ' || l_temp   );

  return l_temp ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Is_Analysis_Option_Selected ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Is_Analysis_Option_Selected ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Is_Analysis_Option_Selected ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Is_Analysis_Option_Selected ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Is_Analysis_Option_Selected;

/************************************************************************************
************************************************************************************/

function Is_Leaf_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) return varchar2 IS

 l_option_id            number;
 l_parent_option_id     number;
 l_grandparent_option_id    number;
 l_count            number;
 l_count_child_options      number;
 l_child_analysis_group     number;
 l_temp             varchar2(5);

Begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --DBMS_OUTPUT.PUT_LINE('Begin BSC_KPI_PVT.Is_Leaf_Analysis_Option ');

  -- Get the paramters :

  l_parent_option_id := 0;
  l_grandparent_option_id := 0;

  if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 0 then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  elsif p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 1 then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1;
    l_parent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  else -- if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 2  then
    l_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2;
    l_parent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1;
    l_grandparent_option_id := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0;
  end if;

  --DBMS_OUTPUT.PUT_LINE('  BSC_KPI_PVT.Is_Leaf_Analysis_Option -  l_option_id = ' || l_option_id );
  --DBMS_OUTPUT.PUT_LINE('  BSC_KPI_PVT.Is_Leaf_Analysis_Option -  l_parent_option_id = ' || l_parent_option_id );
  --DBMS_OUTPUT.PUT_LINE('  BSC_KPI_PVT.Is_Leaf_Analysis_Option -  l_grandparent_option_id = ' || l_grandparent_option_id );
  --DBMS_OUTPUT.PUT_LINE('  BSC_KPI_PVT.Is_Leaf_Analysis_Option -  p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = ' || p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id );

  -- Evaluate the parameter to know if the option is a leaf :

  if p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id = 2 then
     -- a Option from the Analysis Group 2 always is a Leaf
     l_temp := FND_API.G_TRUE;
  else
    -- See if there is some Analysis Group that depend of the current one
    select count(ANALYSIS_GROUP_ID)
      into  l_count
      from BSC_KPI_ANALYSIS_GROUPS
        where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
          and PARENT_ANALYSIS_ID = p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id;

    if l_count = 0 then
    -- l_count = 0 means there is not any dependency group from the current one
    -- then the current Option  is a Leaf
      --DBMS_OUTPUT.PUT_LINE('  BSC_KPI_PVT.Is_Leaf_Analysis_Option -  NO Child Group ' );
      l_temp := FND_API.G_TRUE;
    else
     -- if l_count <> 0 means there is a dependency group
      --DBMS_OUTPUT.PUT_LINE('  BSC_KPI_PVT.Is_Leaf_Analysis_Option -  Child Group ' );

        -- get the dependency group which is the next one
        l_child_analysis_group := p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id + 1 ;

       -- Count the option which one depending of the current one
       select count(option_id)
         into l_count_child_options
     from BSC_KPI_ANALYSIS_OPTIONS_B
     where indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
           and analysis_group_id = l_child_analysis_Group
       and parent_option_id = l_option_id
       and grandparent_option_id = l_parent_option_id;

       if l_count_child_options = 0 then
       -- l_count_child_options = 0 means there is not dependency option from
       -- the current one, then current option is a leaft
         --DBMS_OUTPUT.PUT_LINE('  BSC_KPI_PVT.Is_Leaf_Analysis_Option -  NO Child Options ' );

         l_temp := FND_API.G_TRUE;
       else
       -- l_count_child_options > 0 means there are dependency option from
       -- the current one then the current option is not a leaft
         --DBMS_OUTPUT.PUT_LINE('  BSC_KPI_PVT.Is_Leaf_Analysis_Option -  Child Options ' );

         l_temp := FND_API.G_FALSE;
       end if;
    end if;

  end if;

  --DBMS_OUTPUT.PUT_LINE('End BSC_KPI_PVT.Is_Leaf_Analysis_Option  -  return ' || l_temp   );

  return l_temp ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Is_Leaf_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Is_Leaf_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Is_Leaf_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Is_Leaf_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Is_Leaf_Analysis_Option;

/*********************************************************
 Name : Delete_Ind_Cause_Effect_Rels
 Description : This API deletes the cause and effect relationship
                of the current indicator.
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Cause_Effect_Rels(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DelIndCauseEffectRels;
  -- Check that valid id was entered.
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_cause_effect_rels
  WHERE cause_indicator =p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
  AND   NVL(cause_level,BSC_KPI_PUB.c_IND_LEVEL)=BSC_KPI_PUB.c_IND_LEVEL
  AND   NVL(effect_level,BSC_KPI_PUB.c_IND_LEVEL)=BSC_KPI_PUB.c_IND_LEVEL;

  DELETE
  FROM  bsc_kpi_cause_effect_rels
  WHERE effect_indicator =p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
  AND   NVL(cause_level,BSC_KPI_PUB.c_IND_LEVEL)=BSC_KPI_PUB.c_IND_LEVEL
  AND   NVL(effect_level,BSC_KPI_PUB.c_IND_LEVEL)=BSC_KPI_PUB.c_IND_LEVEL;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DelIndCauseEffectRels;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DelIndCauseEffectRels;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DelIndCauseEffectRels;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Cause_Effect_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Cause_Effect_Rels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DelIndCauseEffectRels;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Cause_Effect_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Cause_Effect_Rels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_Cause_Effect_Rels;


/*********************************************************
 Name : Delete_Ind_Shell_Cmds
 Description : This API deletes shell cammand entries
               of the current indicator.
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Shell_Cmds
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndShellCmds;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_shell_cmds_tl
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_shell_cmds_user
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndShellCmds;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndShellCmds;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndShellCmds;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Shell_Cmds ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Shell_Cmds ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndShellCmds;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Shell_Cmds ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Shell_Cmds ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_Shell_Cmds;


/*********************************************************
 Name : Delete_Ind_MM_Controls
 Description : This API deletes multimedia entries
               of the current indicator.
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_MM_Controls
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndMMControls;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_mm_controls
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndMMControls;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndMMControls;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndMMControls;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_MM_Controls ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_MM_Controls ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndMMControls;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_MM_Controls ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_MM_Controls ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_MM_Controls;

/*********************************************************
 Name : Delete_Ind_Subtitles
 Description : This API deletes subtitle entries of the current indicator.
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Subtitles
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndSubtitles;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_subtitles_tl
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndSubtitles;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndSubtitles;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndSubtitles;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Subtitles ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Subtitles ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndSubtitles;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Subtitles ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Subtitles ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_Subtitles;


/*********************************************************
 Name : Delete_Ind_SeriesColors
 Description : This API deletes series colors of the current indicator.
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_SeriesColors
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndSeriesColors;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_series_colors
  WHERE indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndSeriesColors;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndSeriesColors;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndSeriesColors;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_SeriesColors ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_SeriesColors ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndSeriesColors;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_SeriesColors ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_SeriesColors ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_SeriesColors;


/*********************************************************
 Name : DeleteIndImages
 Description : This API deletes all the images attached with the objective.
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Images
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndImages;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_sys_images
  WHERE image_id IN (
                     SELECT image_id
                     FROM   bsc_kpi_graphs
                     WHERE  indicator =p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
                    );

  DELETE
  FROM  bsc_kpi_graphs
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_user_kpigraph_plugs
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndImages;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndImages;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndImages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Images ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Images ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndImages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Images ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Images ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_Images;


/*********************************************************
 Name : Delete_Ind_Sys_Prop
 Description : This API deletes all the system level proeprties attached to the objective
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Sys_Prop
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndSysProp;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_sys_files
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  DELETE
  FROM  bsc_sys_kpi_colors
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_sys_objective_colors
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_sys_labels_b
  WHERE source_type = BSC_KPI_PUB.c_IND_TYPE
  AND   source_code = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_sys_labels_tl
  WHERE source_type = BSC_KPI_PUB.c_IND_TYPE
  AND   source_code = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_sys_lines
  WHERE source_type = BSC_KPI_PUB.c_IND_TYPE
  AND   source_code = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_sys_user_options
  WHERE source_type = BSC_KPI_PUB.c_IND_TYPE
  AND   source_code = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndSysProp;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndSysProp;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndSysProp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Sys_Prop ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Sys_Prop ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndSysProp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Sys_Prop ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Sys_Prop ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_Sys_Prop;


/*********************************************************
 Name : Delete_Ind_Sys_Prop
 Description : This API deletes objective comments
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Comments
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndComments;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_comments
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndComments;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndComments;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndComments;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Comments ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Comments ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndComments;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Comments ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Comments ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_Comments;

/*********************************************************
 Name : Delete_Ind_Tree_Nodes
 Description : This API deletes nodes of the objectives
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Tree_Nodes
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndTreeNodes;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_kpi_tree_nodes_b
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_tree_nodes_tl
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndTreeNodes;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndTreeNodes;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndTreeNodes;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Tree_Nodes ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Tree_Nodes ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndTreeNodes;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_Tree_Nodes ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_Tree_Nodes ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_Tree_Nodes;


/*********************************************************
 Name : Delete_Ind_User_Access
 Description : This API deletes nodes of the objectives
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_User_Access
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteIndUserAccess;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE
  FROM  bsc_user_kpi_access
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteIndUserAccess;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteIndUserAccess;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteIndUserAccess;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteIndUserAccess;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ind_User_Access;



/*********************************************************
 Name : Delete_Sim_Tree_Data
 Description : This API deletes Simulation Tree Data
 created by  : ashankar 20-JUL-2005
/********************************************************/

PROCEDURE Delete_Sim_Tree_Data
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

l_count                NUMBER;
l_CustView_Rec         BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
l_short_name           BSC_KPIS_VL.short_name%TYPE;

CURSOR  c_sys_images IS
SELECT  image_id
FROM    BSC_SYS_IMAGES
WHERE   image_id NOT IN
        (  SELECT DISTINCT(image_id)
           FROM   BSC_SYS_IMAGES_MAP_TL
        );

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT DeleteSimTreeData;

  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id IS NOT NULL)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpis_b
    WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

    IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  SELECT short_name
  INTO   l_short_name
  FROM   bsc_kpis_vl
  WHERE  indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  DELETE
  FROM  bsc_kpi_tree_nodes_b
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM  bsc_kpi_tree_nodes_tl
  WHERE indicator=p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  DELETE
  FROM    BSC_TAB_VIEW_LABELS_B
  WHERE   tab_id =BSC_KPI_PVT.c_SIM_TAB_ID
  AND     tab_view_id = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  DELETE
  FROM    BSC_TAB_VIEW_LABELS_TL
  WHERE   tab_id =BSC_KPI_PVT.c_SIM_TAB_ID
  AND     tab_view_id = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


  DELETE
  FROM    BSC_SYS_IMAGES_MAP_TL
  WHERE   SOURCE_TYPE =   2
  AND     SOURCE_CODE =   p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
  AND     TYPE        =   BSC_SIMULATION_VIEW_PUB.c_TYPE;

  -- now check if there are any unwanted images in the system and not being
  -- used by any of the scorecard then delete them

  FOR cd IN c_sys_images LOOP
    l_CustView_Rec.Bsc_Image_Id   :=  cd.image_id;

    DELETE
    FROM   BSC_SYS_IMAGES
    WHERE  IMAGE_ID   = l_CustView_Rec.Bsc_Image_Id;

  END LOOP;



  --Here delete from ak_Regions also
  --first we check if there exists any record in ak_Region then we will delete from the following tables
  SELECT COUNT(0)
  INTO   l_count
  FROM   ak_regions
  WHERE  region_code =l_short_name;


  IF(l_count>0)THEN

   BIS_FORM_FUNCTIONS_PUB.DELETE_FUNCTION_AND_MENU_ENT
   (
       p_function_name   => l_short_name
      ,x_return_status   => x_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
    );
   IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   BIS_AK_REGION_PUB.DELETE_REGION_AND_REGION_ITEMS
   (
      p_REGION_CODE            => l_short_name
     ,p_REGION_APPLICATION_ID  => 271
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data
   );

   IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  END IF;



  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteSimTreeData;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteSimTreeData;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteSimTreeData;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteSimTreeData;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PVT.Delete_Ind_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PVT.Delete_Ind_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Sim_Tree_Data;

END BSC_KPI_PVT;

/
