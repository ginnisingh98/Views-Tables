--------------------------------------------------------
--  DDL for Package Body BSC_KPI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_PUB" as
/* $Header: BSCPKPPB.pls 120.12 2007/02/09 09:16:15 ashankar ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPKPPB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 22, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:         Public Body version.                                            |
 |                      This package Creates, Retrieve, Update, Delete                  |
 |                      for BSC KPI information.                                        |
 |                                                                                      |
 |                  Modified By: PWALI for bug #2843082     20-MAR-03                   |
 |                      13-MAY-2003 PWALI  Bug #2942895, SQL BIND COMPLIANCE            |
 |                      24-JUL-2003 Adeulgao fixed bug#3047536                          |
 |                                  Granted access of KPIS to BSC_PMD_USER              |
 |                      14-NOV-2003 ADRAO  Modified for  Bug #3248729,                  |
 |   10-MAR-04          jxyu  Modified for enhancement #3493589                         |
 |   06-MAY-04          ADRAO added code to handle BIS_DBI_ADMIN responsibility         |
 |   18-MAY-04          adrao Modified PL/SQL records and CRUD to accept SHORT_NAME     |
 |   10-JUN-04          adrao added XTD Calculation to BSC_KPI_CALCULATION              |
 |   20-JUL-04          adrao added PMU Responsibility for all S2E KPIs created from    |
 |                      Configure Region link from any responsibility. Bug#3775876      |
 |   01-SEP-04          ashankar fix for the bug #3864002.Added the method              |
 |                      Delete_Custom_View_Links within Delete_Kpi                      |
 |   10-SEP-04          adrao modified Create_Kpi_User_Access for Bug#3877636           |
 |   15-DEC-04          adrao moved API Delete_Kpi_AT to be public to all, Bug#4064587  |
 |   21-JUL-2005        ashankar Bug#4314386                                            |
 |   28-JUL-2005        ashankar Bug#4517700 for the message BSC_GROUP_BESIDES_TO_BELOW |
 |                      removed the BELOW_NAME token as it was not needed.              |
 |   22-AUG-2005        ashankar Bug#4220400 Modified the method Update_Kpi             |
 |   01-SEP-2005        adrao fixed Create_Kpi_User_Access() for Bug#4563456            |
 |   24-Jan-2006        akoduri   Bug#4958055  Dgrp dimension not getting deleted       |
 |                       while disassociating from objective                            |
 |   08-MAR-2006        adrao Bug#5081180 Modified Get_KPI_Dim_ShortNames()             |
 |                      modified the Cursor c_imported_dims                             |
 |   02-Aug-2006        ashankar bug fix#5400575 mahde changes to the method move_master|
 |                                                                           _kpi       |
 |   16-NOV-2006        ankgoel  Color By KPI enh#5244136                               |
 |   31-Jan-2007        akoduri Enh #5679096 Migration of multibar functionality from   |
 |                      VB to Html                                                      |
 |     09-feb-2007 ashankar Simulation Tree Enhacement 5386112                          |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_KPI_PUB';


--New procedure with OUT parameter
PROCEDURE Create_Kpi(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  OUT NOCOPY    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

    l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
    l_No_Ind                    NUMBER;
    l_Count                     NUMBER;
BEGIN

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
    l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- Assign certain default values if they are currently null.
    IF l_Bsc_Kpi_Entity_Rec.Bsc_Edw_Flag IS NULL THEN
        l_Bsc_Kpi_Entity_Rec.Bsc_Edw_Flag := 0;
    END IF;

    IF l_Bsc_Kpi_Entity_Rec.Bsc_Calendar_Id IS NULL THEN
        l_Bsc_Kpi_Entity_Rec.Bsc_Calendar_Id := 1;
    END IF;

  -- Get the next id available for the current Kpi.
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_KPIS_B','INDICATOR');

  -- If KPI name is null then assign default.
    IF l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name IS NOT NULL THEN
        IF l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help IS NULL THEN
            l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name;
        END IF;
    ELSE
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name := 'Indicator ' || l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name;
    END IF;

 -- Set the prototype flag according with the System Stage
    SELECT DECODE(property_value,1,1,3)
    INTO   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag
    FROM   bsc_sys_init
    WHERE  property_code = 'SYSTEM_STAGE';

      if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id is not null then

        SELECT COUNT(1) INTO l_Count
        FROM   BSC_TAB_IND_GROUPS_B
        WHERE  IND_GROUP_ID = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id;

        if l_count = 0 then
          FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KGROUP_ID');
          FND_MESSAGE.SET_TOKEN('BSC_KGROUP', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
      else
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_KGROUP_ID_ENTERED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;

      IF (l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag <> 2) THEN
          SELECT COUNT(B.Indicator)
          INTO   l_No_Ind
          FROM   BSC_TAB_IND_GROUPS_B  A
              ,  BSC_KPIS_B            B
          WHERE  A.Ind_Group_Id    =   B.Ind_Group_Id
          AND    A.Group_Type      =   1
          AND    A.Ind_Group_Id    =   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id
          AND    A.Tab_Id          =  -1
          AND    B.Prototype_Flag <>   2;
          IF (l_No_Ind > 0) THEN
              FND_MESSAGE.SET_NAME('BSC', 'BSC_GROUP_BESIDES_TO_BELOW');
              FND_MESSAGE.SET_TOKEN('BESIDES_THE_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_BUILDER', 'BESIDE_THE_NAME'), TRUE);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          END  IF;
  END IF;


  -- Call private version of procedure.
    BSC_KPI_PVT.Create_Kpi(
                       p_commit                =>  FND_API.G_FALSE
                     , p_Bsc_Kpi_Entity_Rec    =>  l_Bsc_Kpi_Entity_Rec
                     , x_return_status         =>  x_return_status
                     , x_msg_count             =>  x_msg_count
                     , x_msg_data              =>  x_msg_data
                     );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- Call procedures to populate default metadata for the KPI.
    Create_Kpi_Defaults( p_commit
                      ,l_Bsc_Kpi_Entity_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_Bsc_Kpi_Entity_Rec := l_Bsc_Kpi_Entity_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi with parameter x_Bsc_Kpi_Entity_Rec ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi with parameter x_Bsc_Kpi_Entity_Rec ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi with parameter x_Bsc_Kpi_Entity_Rec ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi with parameter x_Bsc_Kpi_Entity_Rec ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Kpi;


/************************************************************************************
************************************************************************************/
--Modified procedure without OUT parameter
/*
*** IMPORTANT ***
Please review the following document, before proceeding to use this public API

http://files.oraclecorp.com/content/MySharedFolders/BSC5.2__ext/BSC5.2_ext-Public/
4_Build/1_Code_Performance/BSC/adrao_4064587/RootCauseAnalysis_Bug4064587.html

Please review and change for BSC5.3
*/
procedure Create_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Bsc_Kpi_Entity_Rec_Out    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- Call the create kpi API with OUT parameter for kpi entity record.
  BSC_KPI_PUB.Create_Kpi( p_commit => p_commit
                         ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
                         ,x_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec_Out
                         ,x_return_status => x_return_status
                         ,x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Kpi;


/************************************************************************************
************************************************************************************/
--new procedure. Initializing the kpi entity record.
procedure Initialize_Kpi_Entity_Rec(
  p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  OUT NOCOPY    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY    varchar2
 ,x_msg_count           OUT NOCOPY    number
 ,x_msg_data            OUT NOCOPY    varchar2
) is

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- set some default values.
  x_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Bm_Group_Id := 1;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Flag := 1;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type := 1;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period := 1;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type := 1;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Level_Comb:= '?';
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := 5;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years:= 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Color:= 'G';
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag:= 3;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 1;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 1;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size:= 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Language := 'US';
  x_Bsc_Kpi_Entity_Rec.Bsc_Num_Options := 1;
  x_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id := 0;
  x_Bsc_Kpi_Entity_Rec.Bsc_Source_Language:= 'US';
  x_Bsc_Kpi_Entity_Rec.Created_By:= 0;
  x_Bsc_Kpi_Entity_Rec.Last_Updated_By:= 0;
  x_Bsc_Kpi_Entity_Rec.Last_Update_Login:= 0;
  x_Bsc_Kpi_Entity_Rec.Last_Update_Login:= 0;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data :=  x_msg_data||' -> BSC_KPI_PUB.Initialize_Kpi_Entity_Rec ';
        ELSE
            x_msg_data :=  SQLERRM||' at BSC_KPI_PUB.Initialize_Kpi_Entity_Rec ';
        END IF;
        RAISE;
end Initialize_Kpi_Entity_Rec;


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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi( p_commit
                           ,p_Bsc_Kpi_Entity_Rec
                           ,x_Bsc_Kpi_Entity_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);

  Retrieve_Kpi_Defaults( p_commit
                        ,p_Bsc_Kpi_Entity_Rec
                        ,x_Bsc_Kpi_Entity_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

TYPE Recdc_value        IS REF CURSOR;
dc_value            Recdc_value;

l_sql               varchar2(1000);

l_count             number;

CURSOR  c_Select_Indicator IS
SELECT  INDICATOR
FROM    BSC_KPIS_B
WHERE   SOURCE_INDICATOR = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
AND     PROTOTYPE_FLAG <> BSC_KPI_PUB.Delete_Kpi_Flag;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Update_Kpi( p_commit
                         ,p_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);

  Update_Kpi_Defaults( p_commit
                      ,p_Bsc_Kpi_Entity_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_ANALYSIS_OPTION_PUB.Set_Default_Analysis_Option
  (
      p_commit             =>  p_commit
    , p_obj_id             =>  p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
    , p_Anal_Opt_Comb_Tbl  =>  p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Opt_Comb_Tbl
    , p_Anal_Grp_Id        =>  p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id
    , x_return_status      =>  x_return_status
    , x_msg_count          =>  x_msg_count
    , x_msg_data           =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- if there are any shared KPIs update those also.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  FOR SrcInd IN c_Select_Indicator LOOP
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id :=  SrcInd.INDICATOR;

    BSC_KPI_PVT.Update_Kpi(
                            p_commit
                        ,   l_Bsc_Kpi_Entity_Rec
                        ,   x_return_status
                        ,   x_msg_count
                        ,   x_msg_data);
    Update_Kpi_Defaults(
                           p_commit
                        ,  l_Bsc_Kpi_Entity_Rec
                        ,  x_return_status
                        ,  x_msg_count
                        ,  x_msg_data
                       );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_ANALYSIS_OPTION_PUB.Set_Default_Analysis_Option
    (
          p_commit             =>  p_commit
        , p_obj_id             =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
        , p_Anal_Opt_Comb_Tbl  =>  p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Opt_Comb_Tbl
        , p_Anal_Grp_Id        =>  p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id
        , x_return_status      =>  x_return_status
        , x_msg_count          =>  x_msg_count
        , x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Kpi;

/************************************************************************************
Get_KPI_Dim_ShortNames: This API Retrieves all the dimension short names associated to a kpi

Modified the Cursor c_imported_dims for Bug#5081180 to ensure that the AG Report Objectives
are filtered out from the KPI Dimension SHort_Names.
************************************************************************************/

PROCEDURE Get_KPI_Dim_ShortNames (
 p_Bsc_Kpi_Entity_Rec  IN             BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_dim_list            OUT NOCOPY    BSC_UTILITY.t_array_of_varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
)
IS
CURSOR c_imported_dims IS
SELECT
 sys_dim.short_name
FROM
 bsc_kpis_b kpi,
 bsc_kpi_dim_groups kpi_dim,
 bsc_sys_dim_groups_vl sys_dim
WHERE
 kpi.indicator = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id AND
 kpi.short_name IS NULL AND
 kpi_dim.indicator = kpi.indicator AND
 sys_dim.dim_group_id = kpi_dim.dim_group_id AND
 bsc_bis_dimension_pub.get_dimension_source(sys_dim.short_name) = BSC_UTILITY.c_PMF;

l_regions VARCHAR2(32000);
l_row_count NUMBER := 0;

BEGIN
  FOR c_dim IN c_imported_dims LOOP
    l_row_count := l_row_count + 1;
    x_dim_list(l_row_count) := c_dim.short_name;
  END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Get_KPI_Dim_ShortNames ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Get_KPI_Dim_ShortNames ';
        END IF;
END Get_KPI_Dim_ShortNames;

/************************************************************************************
Delete_Unused_Imported_Dims:- This API deletes all the dimensions imported while
adding Pmf Measures to an objective (DGRP dimgroups).They will be deleted if they
are not used in any reports
************************************************************************************/

PROCEDURE Delete_Unused_Imported_Dims(
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
 ,p_dim_short_names     IN             BSC_UTILITY.t_array_of_varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) IS
l_regions  VARCHAR2(32000);
BEGIN
  FOR i in 1..p_dim_short_names.COUNT  LOOP
    l_regions := BSC_UTILITY.Is_Dim_In_AKReport(p_dim_short_names(i), BSC_UTILITY.c_DIMENSION);
    IF (l_regions IS NULL) THEN
      BSC_BIS_DIMENSION_PUB.Delete_Dimension
      (    p_commit                =>  FND_API.G_FALSE
       ,   p_dim_short_name        =>  p_dim_short_names(i)
       ,   x_return_status         =>  x_return_status
       ,   x_msg_count             =>  x_msg_count
       ,   x_msg_data              =>  x_msg_data
      );
      IF ((x_return_status IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
         RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END LOOP;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Unused_Imported_Dims ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Unused_Imported_Dims ';
        END IF;
END Delete_Unused_Imported_Dims;

/************************************************************************************
************************************************************************************/

PROCEDURE Delete_Kpi(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN          BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
) IS
CURSOR  c_Select_Indicator IS
SELECT  INDICATOR,CONFIG_TYPE
FROM    BSC_KPIS_B
WHERE   SOURCE_INDICATOR = p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
AND     PROTOTYPE_FLAG <> BSC_KPI_PUB.Delete_Kpi_Flag;

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_sql              VARCHAR2(5000);

l_share_flag       NUMBER;
l_count            NUMBER;
l_ind_tab_count    NUMBER;
l_tab_id           NUMBER;
x_dim_short_names  BSC_UTILITY.t_array_of_varchar2;
l_config_type      BSC_KPIS_B.config_type%TYPE;

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Assign all values in the passed "Record" parameter to the locally defined
    -- "Record" variable.
    l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  --Determine if Indicator assigned to a tab.
    SELECT  COUNT(indicator)
    INTO    l_ind_tab_count
    FROM    BSC_TAB_INDICATORS
    WHERE   indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


    SELECT config_type
    INTO   l_config_type
    from   bsc_kpis_b
    WHERE  indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  -- if indicator assigned to tab get indicator.
    IF(l_ind_tab_count > 0) THEN
        SELECT  tab_id
        INTO    l_tab_id
        FROM    BSC_TAB_INDICATORS
        WHERE   indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
    END IF;

    Get_KPI_Dim_ShortNames(l_Bsc_Kpi_Entity_Rec
                        ,x_dim_short_names
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);



    Delete_Kpi_Defaults( p_commit
                        ,l_Bsc_Kpi_Entity_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);


    Delete_Unused_Imported_Dims(p_commit
                        ,x_dim_short_names
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);


    IF(l_tab_id IS NOT NULL ) THEN
        BSC_CUSTOM_VIEW_PUB.Delete_Custom_View_Links
        (
                p_commit         =>  FND_API.G_FALSE
            ,   p_tab_id         =>  l_tab_id
            ,   p_obj_id         =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
            ,   x_return_status  =>  x_return_status
            ,   x_msg_count      =>  x_msg_count
            ,   x_msg_data       =>  x_msg_data
        );

        IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF(l_config_type =7) THEN

        BSC_KPI_PUB.Delete_Sim_Tree_Data
        (
            p_commit                => p_commit
          , p_Bsc_Kpi_Entity_Rec    => p_Bsc_Kpi_Entity_Rec
          , x_return_status         => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
        );

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


     END IF;

    BSC_KPI_PVT.Delete_Kpi( p_commit
                         ,l_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Need to call procedure for list button logic.
    BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels( p_commit
                                                    ,l_tab_id
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  -- Need to delete any shared KPIs.

  FOR SrcInd IN c_Select_Indicator LOOP
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id :=  SrcInd.INDICATOR;
    l_config_type := SrcInd.config_type;


    SELECT TAB_ID
    INTO   l_tab_id
    FROM   BSC_TAB_INDICATORS
    WHERE  INDICATOR = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;


    Delete_Kpi_Defaults( p_commit
                    ,l_Bsc_Kpi_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF(l_tab_id IS NOT NULL ) THEN
          BSC_CUSTOM_VIEW_PUB.Delete_Custom_View_Links
          (
                  p_commit         =>  FND_API.G_FALSE
              ,   p_tab_id         =>  l_tab_id
              ,   p_obj_id         =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
              ,   x_return_status  =>  x_return_status
              ,   x_msg_count      =>  x_msg_count
              ,   x_msg_data       =>  x_msg_data
          );

          IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

    END IF;

    IF(l_config_type =7) THEN
        BSC_KPI_PUB.Delete_Sim_Tree_Data
        (
            p_commit                => p_commit
          , p_Bsc_Kpi_Entity_Rec    => l_Bsc_Kpi_Entity_Rec
          , x_return_status         => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
        );

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;



    BSC_KPI_PVT.Delete_Kpi(  p_commit
                           , l_Bsc_Kpi_Entity_Rec
                           , x_return_status
                           , x_msg_count
                           , x_msg_data);

    -- Need to call procedure for list button logic.
    BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels( p_commit
                                                     , l_tab_id
                                                     , x_return_status
                                                     , x_msg_count
                                                     , x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_Bsc_Dim_Rec           BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- Set values needed to populate default Dimension set.
--  l_Bsc_Dim_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
--  l_Bsc_Dim_Rec.Bsc_Dim_Set_Id := 0;
--  l_Bsc_Dim_Rec.Language := p_Bsc_Kpi_Entity_Rec.Bsc_Language;
--  l_Bsc_Dim_Rec.Source_Language := p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language;

  BSC_KPI_PVT.Create_Kpi_Defaults( p_commit
                                  ,l_Bsc_Kpi_Entity_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);


  -- Call procedure to Populate Kpi Properties.
  Create_Kpi_Properties( p_commit
                        ,l_Bsc_Kpi_Entity_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to create default Analysis Group/Options.
  Create_Kpi_Analysis( p_commit
                      ,l_Bsc_Kpi_Entity_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);

  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Set some default values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := 5;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id := 0;

  -- Call procedure to create default periodicity.
  Create_Kpi_Periodicity( p_commit
                         ,l_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to create default data for data_tables.
  Create_Kpi_Data_Tables( p_commit
                         ,l_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to populate default calculations for the Kpi.
  Create_Kpi_Calculations( p_commit
                          ,l_Bsc_Kpi_Entity_Rec
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to populate default Access
  Create_Kpi_User_Access( p_commit
                         ,l_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to populate Kpi default values
  Create_Kpi_Default_Values( p_commit
                            ,l_Bsc_Kpi_Entity_Rec
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
/* The following procedure should not be called when creating a KPI.  Instead
   it should be called directly from the UI or wrapper when assigning KPI to a Tab.


  -- Call procedure to assign Kpi to a tab.
  Create_Kpi_In_Tab( p_commit
                    ,l_Bsc_Kpi_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);

*/

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_Defaults( p_commit
                                    ,p_Bsc_Kpi_Entity_Rec
                                    ,x_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

  Retrieve_Kpi_Properties( p_commit
                          ,p_Bsc_Kpi_Entity_Rec
                          ,x_Bsc_Kpi_Entity_Rec
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  Retrieve_Kpi_Periodicity( p_commit
                           ,p_Bsc_Kpi_Entity_Rec
                           ,x_Bsc_Kpi_Entity_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  Retrieve_Kpi_Data_Tables( p_commit
                           ,p_Bsc_Kpi_Entity_Rec
                           ,x_Bsc_Kpi_Entity_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  Retrieve_Kpi_Calculations( p_commit
                            ,p_Bsc_Kpi_Entity_Rec
                            ,x_Bsc_Kpi_Entity_Rec
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  Retrieve_Kpi_User_Access( p_commit
                           ,p_Bsc_Kpi_Entity_Rec
                           ,x_Bsc_Kpi_Entity_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  Retrieve_Kpi_Default_Values( p_commit
                              ,p_Bsc_Kpi_Entity_Rec
                              ,x_Bsc_Kpi_Entity_Rec
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code IS NOT NULL) THEN
      Update_Kpi_Properties( p_commit
                            ,p_Bsc_Kpi_Entity_Rec
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          -- if updation fails, create it
          BSC_KPI_PVT.Create_Kpi_Properties( p_commit
                                ,p_Bsc_Kpi_Entity_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);
          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;
  END IF;
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id IS NOT NULL) THEN
      Update_Kpi_Analysis( p_commit
                          ,p_Bsc_Kpi_Entity_Rec
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data);
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id IS NOT NULL) THEN
      Update_Kpi_Periodicity( p_commit
                             ,p_Bsc_Kpi_Entity_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;
  IF ((p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id IS NOT NULL) AND
       (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id IS NOT NULL)) THEN
      Update_Kpi_Data_Tables( p_commit
                             ,p_Bsc_Kpi_Entity_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id IS NOT NULL) THEN
    Update_Kpi_Calculations( p_commit
                            ,p_Bsc_Kpi_Entity_Rec
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id IS NOT NULL) THEN
      Update_Kpi_User_Access( p_commit
                             ,p_Bsc_Kpi_Entity_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;
  IF (p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value IS NOT NULL) THEN
      Update_Kpi_Default_Values( p_commit
                                ,p_Bsc_Kpi_Entity_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Kpi_Defaults;


PROCEDURE Delete_Obj_Kpi_Measure_Props (
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
, p_bsc_kpi_entity_rec  IN          BSC_KPI_PUB.bsc_kpi_entity_rec
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
)
IS
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Delete from BSC_KPI_MEASURE_PROPS
  BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props (
    p_commit          => p_commit
  , p_objective_id    => p_bsc_kpi_entity_rec.bsc_kpi_id
  , p_cascade_shared  => FALSE
  , x_return_status   => x_return_status
  , x_msg_count       => x_msg_count
  , x_msg_data        => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Delete from BSC_KPI_MEASURE_WEIGHTS
  BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Obj_Kpi_Measure_Weights (
    p_commit          => p_commit
  , p_objective_id    => p_bsc_kpi_entity_rec.bsc_kpi_id
  , p_cascade_shared  => FALSE
  , x_return_status   => x_return_status
  , x_msg_count       => x_msg_count
  , x_msg_data        => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Delete from BSC_COLOR_TYPE_PROPS and BSC_COLOR_RANGES
  -- TBD:ankgoel
  BSC_COLOR_RANGES_PUB.Delete_Color_Prop_Ranges (
    p_commit          => p_commit
  , p_objective_id    => p_bsc_kpi_entity_rec.bsc_kpi_id
  , p_cascade_shared  => FALSE
  , x_return_status   => x_return_status
  , x_msg_count       => x_msg_count
  , x_msg_data        => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
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
      x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Obj_Kpi_Measure_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Obj_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Obj_Kpi_Measure_Props ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Obj_Kpi_Measure_Props ';
    END IF;
END Delete_Obj_Kpi_Measure_Props;
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
  BSC_KPI_PVT.Delete_Objective_Color_Data( p_commit
                                  ,p_Bsc_Kpi_Entity_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Objective_Color_Data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Objective_Color_Data ';
        END IF;
end Delete_Objective_Color_Data;


/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Dim_Set_Rec       BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

TYPE Rec_dc_value       IS REF CURSOR;
dc_value1           Rec_dc_value;
dc_value2           Rec_dc_value;

l_sql1              varchar2(1000);
l_sql2              varchar2(1000);
begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Call procedure to Delete Dimension sets and assign appropriate values to the Record.
  l_Bsc_Dim_Set_Rec.Bsc_Kpi_Id := p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  -- Get the dimension sets for the KPI.
  l_sql1 := 'select distinct(dim_set_id) ' ||
            '  from BSC_KPI_DIM_SETS_TL ' ||
            ' where indicator = :1';

  open dc_value1 for l_sql1 using l_Bsc_Dim_Set_Rec.Bsc_Kpi_Id;
    loop
      fetch dc_value1 into l_Bsc_Dim_Set_Rec.Bsc_Dim_Set_Id;
      exit when dc_value1%NOTFOUND;

      BSC_DIMENSION_SETS_PVT.Delete_Dim_Levels( p_commit
                                               ,l_Bsc_Dim_Set_Rec
                                               ,x_return_status
                                               ,x_msg_count
                                               ,x_msg_data);

      BSC_DIMENSION_SETS_PUB.Delete_Bsc_Kpi_Dim_Sets_Tl( p_commit
                                                        ,l_Bsc_Dim_Set_Rec
                                                        ,x_return_status
                                                        ,x_msg_count
                                                        ,x_msg_data);
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Before we delete the Dimension set we need to delete the Dimension Groups associated
      -- with the dimension set.  In order to get all groups in the Dim. set we need to use
      -- a cursor to query the database.
      l_sql2 := 'select distinct(dim_group_id) ' ||
                '  from BSC_KPI_DIM_GROUPS ' ||
                ' where indicator = :1' ||
                '   and dim_set_id = :2';

      open dc_value2 for l_sql2 using l_Bsc_Dim_Set_Rec.Bsc_Kpi_Id, l_Bsc_Dim_Set_Rec.Bsc_Dim_Set_Id;
        loop
          fetch dc_value2 into l_Bsc_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;
          exit when dc_value2%NOTFOUND;
          -- call the procedure to delete dimension groups frin dimension sets;
          BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset( p_commit
                                                          ,l_Bsc_Dim_Set_Rec
                                                          ,x_return_status
                                                          ,x_msg_count
                                                          ,x_msg_data);

        end loop;
      close dc_value2;

    end loop;
    close dc_value1;

  -- Call procedure to Delete Kpi Properties.
  Delete_Kpi_Properties( p_commit
                        ,p_Bsc_Kpi_Entity_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Delete_Objective_Color_Data( p_commit
                      ,p_Bsc_Kpi_Entity_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Call procedure to delete default Analysis Group/Options.
  Delete_Kpi_Analysis( p_commit
                      ,p_Bsc_Kpi_Entity_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);

  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to delete default periodicity.
  Delete_Kpi_Periodicity( p_commit
                         ,p_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to delete default data for data_tables.
  Delete_Kpi_Data_Tables( p_commit
                         ,p_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to delete default calculations for the Kpi.
  Delete_Kpi_Calculations( p_commit
                          ,p_Bsc_Kpi_Entity_Rec
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to delete Kpi from Tab.
  Delete_Kpi_In_Tab( p_commit
                    ,p_Bsc_Kpi_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to delete default Access
  Delete_Kpi_User_Access( p_commit
                         ,p_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Call procedure to delete Kpi default values
  Delete_Kpi_Default_Values( p_commit
                            ,p_Bsc_Kpi_Entity_Rec
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Delete_Ind_Extra_Tables
  (
      p_commit             => p_commit
    , p_Bsc_Kpi_Entity_Rec => p_Bsc_Kpi_Entity_Rec
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data

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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Defaults ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_count                     NUMBER;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- Set the values for the Properties table and call the private version of the API.
  -- This has to be done numerous times.

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code := 'LOCK_INDICATOR';
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value := '';

  BSC_KPI_PVT.Create_Kpi_Properties( p_commit
                                    ,l_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code   :=  BSC_KPI_PUB.Benchmark_Kpi_Property;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value  :=  BSC_KPI_PUB.Benchmark_Kpi_Line_Graph;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value := '';

  BSC_KPI_PVT.Create_Kpi_Properties( p_commit
                                    ,l_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);


  ---We need to check if the
  IF(l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type =BSC_BIS_KPI_CRUD_PUB.C_SIM_INDICATOR_CONFIG_TYPE)THEN
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpi_properties
    WHERE  indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
    AND    property_code  =BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;

    IF(l_count=0)THEN

     l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code   :=  BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;
     l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value  :=  BSC_SIMULATION_VIEW_PUB.c_DEFAULT_DATASET_ID;
     l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value := '';

     BSC_KPI_PVT.Create_Kpi_Properties(  p_commit
                                        ,l_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);

    END IF;
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_Properties( p_commit
                                      ,p_Bsc_Kpi_Entity_Rec
                                      ,x_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Update_Kpi_Properties( p_commit
                                    ,p_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

l_count                         number;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Delete_Kpi_Properties( p_commit
                                    ,p_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Call private version of procedure.
  BSC_KPI_PVT.Create_Kpi_Analysis( p_commit
                                  ,p_Bsc_Kpi_Entity_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_Analysis( p_commit
                                    ,p_Bsc_Kpi_Entity_Rec
                                    ,x_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Update_Kpi_Analysis( p_commit
                                  ,p_Bsc_Kpi_Entity_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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
  -- Before deleting analysis Groups/Options which will delete the KPI_Measure_Id also,
  -- we need to delete from KPI Measure Properties from Props, Thresholds and Weights tables.
  Delete_Obj_Kpi_Measure_Props (
    p_commit              => p_commit
  , p_bsc_kpi_entity_rec  => p_Bsc_Kpi_Entity_Rec
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_KPI_PVT.Delete_Kpi_Analysis( p_commit
                                  ,p_Bsc_Kpi_Entity_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Analysis ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Analysis ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Kpi_Analysis;

/************************************************************************************
************************************************************************************/

procedure Create_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is


begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Create_Kpi_Periodicity( p_commit
                                     ,p_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_Periodicity( p_commit
                                       ,p_Bsc_Kpi_Entity_Rec
                                       ,x_Bsc_Kpi_Entity_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Update_Kpi_Periodicity( p_commit
                                     ,p_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Delete_Kpi_Periodicity( p_commit
                                     ,p_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Periodicity ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Create_Kpi_Data_Tables( p_commit
                                     ,p_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_Data_Tables( p_commit
                                       ,p_Bsc_Kpi_Entity_Rec
                                       ,x_Bsc_Kpi_Entity_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Update_Kpi_Data_Tables( p_commit
                                     ,p_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Delete_Kpi_Data_Tables( p_commit
                                     ,p_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Data_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Data_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- Set some defaults and call procedure several times.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 1;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 3;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 4;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 5;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 6;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 7;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 8;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 9;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 10;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 11;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);


  -- We need to make an ENTRY for XTD
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 12;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);


  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 20;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Create_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_Calculations( p_commit
                                        ,p_Bsc_Kpi_Entity_Rec
                                        ,x_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- At this point we are using default values.  This should be redone.

  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 1;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;
  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);


  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 3;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 4;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 5;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 2;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 6;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 7;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 8;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 9;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 10;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 11;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;

  BSC_KPI_PVT.Update_Kpi_Calculations( p_commit
                                      ,l_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := 20;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value := 0;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Delete_Kpi_Calculations( p_commit
                                      ,p_Bsc_Kpi_Entity_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Calculations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Delete_Kpi_Calculations;

/************************************************************************************
************************************************************************************/
/************************************************************************************
 Function    :   Create_Kpi_Access_For_Resp
 Description :   This function will assign a objectitve to a given responsibility
***********************************************************************************/
PROCEDURE Create_Kpi_Access_For_Resp(
  p_commit                       IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Comma_Sep_Resposibility_Key  IN          VARCHAR2
 ,p_Bsc_Kpi_Entity_Rec           IN          BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status                OUT NOCOPY  VARCHAR2
 ,x_msg_count                    OUT NOCOPY  NUMBER
 ,x_msg_data                     OUT NOCOPY  VARCHAR2
)IS
l_Bsc_Kpi_Entity_Rec  BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Count               NUMBER;

CURSOR c_Resp_Ids IS
SELECT responsibility_id
FROM   fnd_responsibility
WHERE  INSTR(','||p_Comma_Sep_Resposibility_Key||',',','||responsibility_key||',') > 0;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  FOR CD IN c_Resp_Ids LOOP
    SELECT COUNT(1)
    INTO   l_Count
    FROM   bsc_user_kpi_access
    WHERE  indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
    AND    responsibility_id = CD.responsibility_id;

    l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id := CD.responsibility_id;

    IF(l_Count = 0) THEN
      BSC_KPI_PVT.Create_Kpi_User_Access
      ( p_commit              => p_commit
      , p_Bsc_Kpi_Entity_Rec  => l_Bsc_Kpi_Entity_Rec
      , x_return_status       => x_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Access_For_Resp ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Access_For_Resp ';
    END IF;
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Access_For_Resp ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT BSC_KPI_PUB.Create_Kpi_Access_For_Resp ';
    END IF;
END Create_Kpi_Access_For_Resp;
/**************************************************************************************/

PROCEDURE Create_Kpi_User_Access(
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS

l_Bsc_Kpi_Entity_Rec  BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;
l_Kpi_Short_Name      BSC_KPIS_B.SHORT_NAME%TYPE;
l_Comma_Sep_Resp_Key  VARCHAR2(32000):= NULL;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  BEGIN
    SELECT K.SHORT_NAME
    INTO   l_Kpi_Short_Name
    FROM   BSC_KPIS_B K
    WHERE  K.INDICATOR = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     l_Kpi_Short_Name := NULL;
  END;

  -- added for Bug#4563456
  l_Responsibility_Key := BSC_UTILITY.Get_Responsibility_Key;

  IF (UPPER(l_Responsibility_Key) = 'BSC_DESIGNER') OR (UPPER(l_Responsibility_Key) = 'BSC_MANAGER') OR (l_Kpi_Short_Name IS NOT NULL )THEN

    l_Comma_Sep_Resp_Key := l_Comma_Sep_Resp_Key       ||','||
                            bsc_utility.c_BSC_Manager  ||','||
                            bsc_utility.c_BSC_DESIGNER ||','||
                            bsc_utility.c_BSC_PMD_USER ||','||
                            bsc_utility.c_BIS_BID_RESP ||','||
                            bsc_utility.c_BIS_DBI_ADMIN||','||
                            l_responsibility_key;
  ELSE
    l_Comma_Sep_Resp_Key := l_responsibility_key;

  END IF;

  Create_Kpi_Access_For_Resp
  ( p_commit                       => p_commit
  , p_Comma_Sep_Resposibility_Key  => l_Comma_Sep_Resp_Key
  , p_Bsc_Kpi_Entity_Rec           => l_Bsc_Kpi_Entity_Rec
  , x_return_status                => x_return_status
  , x_msg_count                    => x_msg_count
  , x_msg_data                     => x_msg_data
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_User_Access( p_commit
                                       ,p_Bsc_Kpi_Entity_Rec
                                       ,x_Bsc_Kpi_Entity_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Update_Kpi_User_Access( p_commit
                                     ,p_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Delete_Kpi_User_Access( p_commit
                                     ,p_Bsc_Kpi_Entity_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- set the local record equal to the passed record.
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  -- set some defaults if they are null.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Format_Mask is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Format_Mask := '$ #,###,##0.00';
  end if;

  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Method is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Method := 1;
  end if;

  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Value is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Value := 0;
  end if;

  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Period_Name is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Period_Name := '5-1';
  end if;

  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Series_Name is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Series_Name := 'Default 0';
  end if;

  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Text is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level1_Text := 'XXX';
  end if;

  select distinct c.source
    into l_Bsc_Kpi_Entity_Rec.Bsc_Measure_Source
    from BSC_KPI_ANALYSIS_MEASURES_B a,
         BSC_SYS_DATASETS_B b,
         BSC_SYS_MEASURES c,
         BSC_DB_COLOR_AO_DEFAULTS_V d
   where d.indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id and
         d.indicator = a.indicator and
         d.a0_default = a.analysis_option0 and
         a.analysis_option1 = 0 and
         a.analysis_option2 = 0 and
         a.dataset_id = b.dataset_id and
         b.measure_id1 = c.measure_id;


  BSC_KPI_PVT.Create_Kpi_Default_Values( p_commit
                                        ,l_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_Default_Values( p_commit
                                          ,p_Bsc_Kpi_Entity_Rec
                                          ,x_Bsc_Kpi_Entity_Rec
                                          ,x_return_status
                                          ,x_msg_count
                                          ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Update_Kpi_Default_Values( p_commit
                                        ,p_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Delete_Kpi_Default_Values( p_commit
                                        ,p_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_Default_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_Default_Values ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Delete_Kpi_Default_Values;

/************************************************************************************
************************************************************************************/

--  :- This procedure assigns a KPI to a Tab.  BSC does not allow the user to assign
--     a KPI to a Tab without assigning the Kpi Group first.  Therefore this assingns
--     the group first, if it hasn't been assigned.

procedure Create_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Create_Kpi_In_Tab( p_commit
                                ,p_Bsc_Kpi_Entity_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Retrieve_Kpi_In_Tab( p_commit
                                  ,p_Bsc_Kpi_Entity_Rec
                                  ,x_Bsc_Kpi_Entity_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Retrieve_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Retrieve_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
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

begin

/*
  -- If Dim set Id and Dim Level Id are null then assign 0 to both.
  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id is null then
   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Set_Id := 0;
  end if;

  if l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level_Id is null then
   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Dim_Level_Id := 0;
  end if;
*/
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Update_Kpi_In_Tab( p_commit
                                ,p_Bsc_Kpi_Entity_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Delete_Kpi_In_Tab( p_commit
                                ,p_Bsc_Kpi_Entity_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Kpi_In_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Kpi_In_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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
  BSC_KPI_PVT.Update_Kpi_Time_Stamp( p_commit
                                    ,p_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Update_Kpi_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Update_Kpi_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Create_Master_Kpi( p_commit
                                ,p_Bsc_Kpi_Entity_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Master_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Master_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Master_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Master_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Kpi_Entity_Rec := p_Bsc_Kpi_Entity_Rec;

  if p_Bsc_Kpi_Entity_Rec.Bsc_Language is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Language := 'US';
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Source_Language is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Source_Language := 'US';
  end if;
  if p_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id is null then
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := 5;
  end if;


  BSC_KPI_PVT.Create_Shared_Kpi( p_commit
                                ,l_Bsc_Kpi_Entity_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Shared_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Shared_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Shared_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Shared_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Shared_Kpi;

/************************************************************************************
************************************************************************************/

procedure Set_Default_Option(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
   FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PVT.Set_Default_Option( p_commit
                                 ,p_Bsc_Kpi_Entity_Rec
                                 ,x_return_status
                                 ,x_msg_count
                                 ,x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Set_Default_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Set_Default_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Set_Default_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Set_Default_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Set_Default_Option;

/************************************************************************************
************************************************************************************/

procedure Set_Default_Option_MG(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_PUB.Set_Default_Option_MG( p_commit
                                    ,p_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Set_Default_Option_MG ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Set_Default_Option_MG ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Set_Default_Option_MG ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Set_Default_Option_MG ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Set_Default_Option_MG;

/************************************************************************************
************************************************************************************/
procedure Assign_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) IS

Begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 BSC_KPI_PVT.Assign_Analysis_Option(
                         p_Bsc_kpi_Entity_Rec
             ,x_return_status
             ,x_msg_count
             ,x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Assign_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Assign_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Assign_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Assign_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

End Assign_Analysis_Option;

/************************************************************************************
************************************************************************************/

procedure Unassign_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) IS

Begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 BSC_KPI_PVT.Unassign_Analysis_Option(
                         p_Bsc_kpi_Entity_Rec
             ,x_return_status
             ,x_msg_count
             ,x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Unassign_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Unassign_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Unassign_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Unassign_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

End Unassign_Analysis_Option;


/************************************************************************************
************************************************************************************/

function Is_Analysis_Option_Selected(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) return varchar2 IS
 l_temp                         varchar2(5);
Begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 l_temp := BSC_KPI_PVT.Is_Analysis_Option_Selected(
                    p_Bsc_kpi_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data );
 return l_temp;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Is_Analysis_Option_Selected ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Is_Analysis_Option_Selected ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Is_Analysis_Option_Selected ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Is_Analysis_Option_Selected ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Is_Analysis_Option_Selected;

/************************************************************************************
************************************************************************************/

function Is_Leaf_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) return varchar2 IS
 l_temp                         varchar2(5);
Begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 --DBMS_OUTPUT.PUT_LINE('Begin BSC_KPI_PUB.Is_Leaf_Analysis_Option ');

 l_temp := BSC_KPI_PVT.Is_Leaf_Analysis_Option(
                    p_Bsc_kpi_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data );

  --DBMS_OUTPUT.PUT_LINE('End BSC_KPI_PUB.Is_Leaf_Analysis_Option  -  return ' || l_temp );

 return l_temp;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Is_Leaf_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Is_Leaf_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Is_Leaf_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Is_Leaf_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Is_Leaf_Analysis_Option;

/************************************************************************************
************************************************************************************/

function get_KPI_Time_Stamp(
  p_kpi_id              IN      number
) return date is

   l_time_stamp  date;
begin

   select last_update_date
    into l_time_stamp
    from bsc_kpis_b
    where indicator = p_kpi_id;
   return l_time_stamp;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end get_KPI_Time_Stamp;

/************************************************************************************
************************************************************************************/

/*
  This procedure get a Master KPI
  Change the Master KPI to the Tab where the only Share KPI belong
  (It care that the object already created with the share KPI in the respective
   tab don't loose;  like cause-Effect and KPI Custom Viwe Objects)
  Then Deleted the Share KPI

*/
procedure move_master_kpi(
  p_master_kpi              IN             NUMBER
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) is

l_master_kpi              NUMBER;
l_share_kpi               NUMBER;
l_master_tab              NUMBER;
l_share_tab               NUMBER;
l_commit                  varchar2(10);
l_Bsc_Kpi_Entity_Rec      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Bsc_Tab_Entity_Rec      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

  cursor c is select *
    from BSC_TABS_B
    where TAB_ID = l_share_tab
    for update of TAB_ID nowait;
  recinfo c%rowtype;

  CURSOR C_SHARE_DIM_LEVELS IS
  SELECT  dim_set_id,dim_level_index,level_table_name,level_view_name
  FROM    bsc_kpi_dim_levels_b
  WHERE   indicator = l_share_kpi;

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 l_commit := FND_API.G_TRUE;
 l_master_kpi := p_master_kpi;

 -- Get  Share KPI code and Share Tab
 select indicator, tab_id
    into l_share_kpi, l_share_tab
    from BSC_TAB_INDICATORS
    where indicator in (select indicator
                          from BSC_KPIS_B
                          where source_indicator = l_master_kpi );
 -- Get Master Tab
 select tab_id
    into l_master_tab
    from BSC_TAB_INDICATORS
    where indicator = l_master_kpi;

 -- handle Metadata object
 UPDATE BSC_TAB_INDICATORS SET TAB_ID = l_share_tab
  WHERE INDICATOR= l_master_kpi;
 UPDATE BSC_KPI_DEFAULTS_B SET TAB_ID = l_share_tab
  WHERE INDICATOR = l_master_kpi;
 UPDATE BSC_KPI_DEFAULTS_TL SET TAB_ID = l_share_tab
  WHERE INDICATOR= l_master_kpi;

 DELETE FROM BSC_TAB_VIEW_KPI_TL
  WHERE TAB_ID = l_master_tab AND INDICATOR = l_master_kpi;

 DELETE FROM BSC_KPI_CAUSE_EFFECT_RELS
  WHERE (((CAUSE_INDICATOR= l_master_kpi)) OR ((EFFECT_INDICATOR = l_master_kpi))
   AND (NVL(CAUSE_LEVEL,'KPI')= 'KPI') AND (NVL(EFFECT_LEVEL,'NVL')= 'KPI'));

 UPDATE BSC_TAB_VIEW_KPI_TL
   SET INDICATOR = l_master_kpi, LAST_UPDATE_DATE = sysdate
   WHERE TAB_ID= l_share_tab  AND INDICATOR= l_share_kpi;

 UPDATE BSC_KPI_CAUSE_EFFECT_RELS
  SET EFFECT_INDICATOR = l_master_kpi
  WHERE EFFECT_INDICATOR = l_share_kpi
   AND (NVL(CAUSE_LEVEL,'KPI')= 'KPI') AND (NVL(EFFECT_LEVEL,'NVL')= 'KPI');
 UPDATE BSC_KPI_CAUSE_EFFECT_RELS SET CAUSE_INDICATOR = l_master_kpi
  WHERE CAUSE_INDICATOR = l_share_kpi
   AND (NVL(CAUSE_LEVEL,'KPI')= 'KPI') AND (NVL(EFFECT_LEVEL,'NVL')= 'KPI');

  /*********************************************
   Shared objectives can have different filter views as compared
   to master objective.So we need to copy the filter views to master objective
   before deleting the shared objective
  /***********************************************/
  FOR cd IN C_SHARE_DIM_LEVELS LOOP

      UPDATE bsc_kpi_dim_levels_b
      SET    level_view_name  = cd.level_view_name
      WHERE  indicator        = l_master_kpi
      AND    dim_set_id       = cd.dim_set_id
      AND    dim_level_index  = cd.dim_level_index
      AND    level_table_name = cd.level_table_name;

  END LOOP;

 -- Delete the Share KPI
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_share_kpi;
  l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id := l_share_tab;
   BSC_KPI_PUB.Delete_Kpi( l_commit
                             ,l_Bsc_Kpi_Entity_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   BSC_KPI_PUB.Update_Kpi_Time_Stamp( l_commit
                                        ,l_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_master_kpi;
  l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id := l_master_tab;
  BSC_KPI_PUB.Update_Kpi_Time_Stamp( l_commit
                                        ,l_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id := l_share_tab;

  open c;
  fetch c into recinfo;
  if (c%found) then
    BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( l_commit
                                          ,l_Bsc_Tab_Entity_Rec
                                          ,x_return_status
                                          ,x_msg_count
                                          ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  end if;
  close c;

end move_master_kpi;


/***************************************************************
 Name   : Delete_Ind_Extra_Tables
 Description  : This API is used to delete the data of objectives from
                other tables which was not happening till now from PMD.
 Created by   : ashankar 21-JUL-2005
/***************************************************************/

PROCEDURE Delete_Ind_Extra_Tables
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2

)IS
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_KPI_PUB.Delete_Ind_User_Access
    (
          p_commit              =>  p_commit
        , p_Bsc_Kpi_Entity_Rec  =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status       =>  x_return_status
        , x_msg_count           =>  x_msg_count
        , x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_Tree_Nodes
    (
          p_commit              =>  p_commit
        , p_Bsc_Kpi_Entity_Rec  =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status       =>  x_return_status
        , x_msg_count           =>  x_msg_count
        , x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_Comments
    (
          p_commit              =>  p_commit
        , p_Bsc_Kpi_Entity_Rec  =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status       =>  x_return_status
        , x_msg_count           =>  x_msg_count
        , x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_Sys_Prop
    (
          p_commit              =>  p_commit
        , p_Bsc_Kpi_Entity_Rec  =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status       =>  x_return_status
        , x_msg_count           =>  x_msg_count
        , x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_Images
    (
          p_commit             =>  p_commit
        , p_Bsc_Kpi_Entity_Rec =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status      =>  x_return_status
        , x_msg_count          =>  x_msg_count
        , x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_SeriesColors
    (
          p_commit             =>  p_commit
        , p_Bsc_Kpi_Entity_Rec =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status      =>  x_return_status
        , x_msg_count          =>  x_msg_count
        , x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_Subtitles
    (
          p_commit             =>  p_commit
        , p_Bsc_Kpi_Entity_Rec =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status      =>  x_return_status
        , x_msg_count          =>  x_msg_count
        , x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_MM_Controls
    (
          p_commit              =>  p_commit
        , p_Bsc_Kpi_Entity_Rec  =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status       =>  x_return_status
        , x_msg_count           =>  x_msg_count
        , x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_Shell_Cmds
    (
          p_commit              =>  p_commit
        , p_Bsc_Kpi_Entity_Rec  =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status       =>  x_return_status
        , x_msg_count           =>  x_msg_count
        , x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Delete_Ind_Cause_Effect_Rels
    (
          p_commit              =>  p_commit
        , p_Bsc_Kpi_Entity_Rec  =>  p_Bsc_Kpi_Entity_Rec
        , x_return_status       =>  x_return_status
        , x_msg_count           =>  x_msg_count
        , x_msg_data            =>  x_msg_data
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Extra_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Extra_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Extra_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Extra_Tables ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_Extra_Tables;

/*********************************************************
 Name         : Delete_Ind_Cause_Effect_Rels
 Description  : This API deletes CAUSE and EFFECT of objectives
 created by   : ashankar 21-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Cause_Effect_Rels
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_Cause_Effect_Rels
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Cause_Effect_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Cause_Effect_Rels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Cause_Effect_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Cause_Effect_Rels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_Cause_Effect_Rels;

/*********************************************************
 Name         : Delete_Ind_Shell_Cmds
 Description  : This API deletes shell commands attached to the objective
 created by   : ashankar 21-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Shell_Cmds
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_Shell_Cmds
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Shell_Cmds ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Shell_Cmds ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Shell_Cmds ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Shell_Cmds ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_Shell_Cmds;

/*********************************************************
 Name         : Delete_Ind_MM_Controls
 Description  : This API deletes Multimedia controls attached to the objective
 created by   : ashankar 21-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_MM_Controls
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_MM_Controls
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_MM_Controls ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_MM_Controls ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_MM_Controls ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_MM_Controls ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_MM_Controls;

/*********************************************************
 Name         : Delete_Ind_Subtitles
 Description  : This API deletes subtitles attached to the objectives
 created by   : ashankar 21-JUL-2005
/********************************************************/
PROCEDURE Delete_Ind_Subtitles
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_Subtitles
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Subtitles ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Subtitles ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Subtitles ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Subtitles ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_Subtitles;

/*********************************************************
 Name         : Delete_Ind_SeriesColors
 Description  : This API deletes series colors attached to the objectives
 created by   : ashankar 21-JUL-2005
/********************************************************/
PROCEDURE Delete_Ind_SeriesColors
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_SeriesColors
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_SeriesColors ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_SeriesColors ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_SeriesColors ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_SeriesColors ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_SeriesColors;

/*********************************************************
 Name         : Delete_Ind_Images
 Description  : This API deletes objective images
 created by   : ashankar 21-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Images
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_Images
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Images ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Images ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Images ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Images ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_Images;

/*********************************************************
 Name         : Delete_Ind_Sys_Prop
 Description  : This API deletes system properties of objectives
 created by   : ashankar 21-JUL-2005
/********************************************************/
PROCEDURE Delete_Ind_Sys_Prop
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_Sys_Prop
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Sys_Prop ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Sys_Prop ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Sys_Prop ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Sys_Prop ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_Sys_Prop;

/*********************************************************
 Name         : Delete_Ind_Comments
 Description  : This API deletes comments of objectives
 created by   : ashankar 21-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Comments
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_Comments
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Comments ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Comments ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Comments ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Comments ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_Comments;

/*********************************************************
 Name         : Delete_Ind_Tree_Nodes
 Description  : This API deletes Tree nodes of the objectives
 created by   : ashankar 21-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_Tree_Nodes
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_Tree_Nodes
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Tree_Nodes ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Tree_Nodes ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_Tree_Nodes ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_Tree_Nodes ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_Tree_Nodes;

/*********************************************************
 Name         : Delete_Ind_User_Access
 Description  : This API deletes user access of the objectives
 created by   : ashankar 21-JUL-2005
/********************************************************/

PROCEDURE Delete_Ind_User_Access
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_count                NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_KPI_PVT.Delete_Ind_User_Access
  (
      p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Ind_User_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Ind_User_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ind_User_Access;


PROCEDURE Delete_Sim_Tree_Data
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
)IS

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  BSC_KPI_PVT.Delete_Sim_Tree_Data
  (
        p_commit              => p_commit
      , p_Bsc_Kpi_Entity_Rec  => p_Bsc_Kpi_Entity_Rec
      , x_return_status       => x_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
  );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Sim_Tree_Data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Sim_Tree_Data ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Delete_Sim_Tree_Data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Delete_Sim_Tree_Data ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Delete_Sim_Tree_Data;

END BSC_KPI_PUB;

/
