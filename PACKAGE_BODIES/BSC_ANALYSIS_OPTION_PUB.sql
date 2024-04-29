--------------------------------------------------------
--  DDL for Package Body BSC_ANALYSIS_OPTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_ANALYSIS_OPTION_PUB" as
/* $Header: BSCPANOB.pls 120.12 2007/02/08 14:00:00 akoduri ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPANOB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 10, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |          Public Body version.                                                        |
 |          This package creates a BSC Analysis Option.                                 |
 |                                                                                      |
 |          13-MAY-2003 PWALI    Bug #2942895, SQL BIND COMPLIANCE                      |
 |          14-NOV-2003 PAJOHRI  Bug #3248729                                           |
 |      02-jul-2004   rpenneru Modified for Enhancement#3532517                         |
 |         20-APR-2005  ADRAO Called APIs Cascade_Series_Default_Value                  |
 |         28-APR-2005  ADRAO Fixed Bug#4327480                                         |
 |         27-JUL-2005  ADRAO Fixed Bug#4357962                                         |
 |         16-AUG-2005  akoduri  Bug#4482355   Removing attribute_code and              |
 |                            attribute2 dependency in Report Designer                  |
 |         22-aug-2005 ashankar bug#4220400 added the following APIs                    |
 |                     1.Default_Anal_Option_Changed                                    |
 |                     2.Set_Default_Analysis_Option                                    |
 |                     3.Get_Analysis_Group_Id                                          |
 |                     4.Get_Num_Analysis_options                                       |
 |         03-jan-2006 rpenneru bug#4899020 comparison source is not updated properly   |
 |                       while Rearrange_Data_Series                                    |
 |         05-jan-2006 rpenneru bug#4683354 Modified to reset datasource both for BSC   |
 |                     and PMF type measures                                            |
 |         22-may-2006 akoduri bug#5104402 data source is getting updated wrongly for   |
 |                      PMF type measures                                               |
 |         12-Sep-2006 akoduri  Bug#5526265 Issues iwth actual_data_source and          |
 |                     function name updation                                           |
 |         11-OCT-2006 akoduri  Bug #5554168 Issue with Measures having different short |
 |                     names in bis_indicators & bsc_sys_measures                       |
 |         31-Jan-2007 akoduri  Enh #5679096 Migration of multibar functionality from   |
 |                               VB to Html                                             |
+======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_ANALYSIS_OPTION_PVT';

--: This procedure is used to create an analysis option.  This is the entry point
--: for the Analysis Option API.
--: This procedure is part of the Analysis Option API.

PROCEDURE Create_Analysis_Options
(       p_commit              IN            varchar2 -- :=  FND_API.G_FALSE
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
) IS
    l_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_share_flag        NUMBER;
    l_count             NUMBER;

    --get shared indicators
    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  l_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     Prototype_Flag   <>  2;
begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Anal_Opt_Rec := p_Anal_Opt_Rec;

  -- Assign certain default values if they are currently null.
  if l_Anal_Opt_Rec.Bsc_Dataset_Axis is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Axis := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color := 10053171;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Default_Value is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Default_Value := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Series_Color is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Color := 10053171;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Series_Id is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Series_Type is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Type := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_User_Level0 is null then
    l_Anal_Opt_Rec.Bsc_User_Level0 := 2;
  end if;
  if l_Anal_Opt_Rec.Bsc_User_Level1 is null then
    l_Anal_Opt_Rec.Bsc_User_Level1 := 2;
  end if;
  if l_Anal_Opt_Rec.Bsc_Option_Help is null then
    l_Anal_Opt_Rec.Bsc_Option_Help := l_Anal_Opt_Rec.Bsc_Option_Name;
  end if;

  -- If there is no current Data set then set the data set equal to -1, and set the name
  -- of the measure to a default name.
  if l_Anal_Opt_Rec.Bsc_Dataset_Id is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Id := -1;
    l_Anal_Opt_Rec.Bsc_Measure_Long_Name := BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_COMMON', 'DEFAULT') ||
 ' ' || BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_COMMON', 'EDW_MEASURE');

    l_Anal_Opt_Rec.Bsc_Measure_Help := l_Anal_Opt_Rec.Bsc_Measure_Long_Name;
  end if;

   -- If this is a new KPI then call private version right away with defaults passed.
  -- If it is not a new KPI then do everything else.
  if l_Anal_Opt_Rec.Bsc_New_Kpi = 'Y' then
    BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Options( p_commit
                                                    ,l_Anal_Opt_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

  else

    -- Verify that this is not a Shared KPI.
    select share_flag
      into l_share_flag
      from BSC_KPIS_B
     where indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id;

    if l_share_flag = 2 then
      FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

    -- Select the number of the last analysis option plus 1 more for the given KPI
    -- and give Analysis Group.
    select max(option_id) + 1
      into l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
      from BSC_KPI_ANALYSIS_OPTIONS_B
     where indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id
       and analysis_group_id = l_Anal_Opt_Rec.Bsc_Analysis_Group_Id;

    -- Set the value for the Bsc_Option_Group0 equal to the value for the
    -- Bsc_Analysis_Option_Id.  The Bsc_Option_Group0 holds the values for the Analysis
    -- Option IDs.
    l_Anal_Opt_Rec.Bsc_Option_Group0 := l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;

    -- Set user level access.
    l_Anal_Opt_Rec.Bsc_User_Level0 := 2;
    l_Anal_Opt_Rec.Bsc_User_Level1 := 2;


    -- Get the name for the Data Set Id given.
    select name
      into l_Anal_Opt_Rec.Bsc_Measure_Long_Name
      from BSC_SYS_DATASETS_TL
     where dataset_id = l_Anal_Opt_Rec.Bsc_Dataset_Id
       and language = USERENV('LANG');

    -- If help for the measure is null set it equal to the name.
    if l_Anal_Opt_Rec.Bsc_Measure_Help is null then
      l_Anal_Opt_Rec.Bsc_Measure_Help := l_Anal_Opt_Rec.Bsc_Measure_Long_Name;
    end if;

    -- Call private version of procedure.
    BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Options( p_commit
                                                    ,l_Anal_Opt_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

  end if;

  -- Call the following procedure.
  Create_Analysis_Measures( p_commit
                           ,l_Anal_Opt_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);

  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
    -- repeat the steps for shared indicators also
    FOR cd IN c_kpi_ids LOOP
        l_Anal_Opt_Rec.Bsc_Kpi_Id   := cd.Indicator;
        BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Options( p_commit
                                                        ,l_Anal_Opt_Rec
                                                        ,x_return_status
                                                        ,x_msg_count
                                                        ,x_msg_data);

        Create_Analysis_Measures( p_commit
                                 ,l_Anal_Opt_Rec
                                 ,x_return_status
                                 ,x_msg_count
                                 ,x_msg_data);
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Analysis_Options;


/************************************************************************************
************************************************************************************/
procedure Retrieve_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_Anal_Opt_Rec        IN OUT NOCOPY     BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Retrieve_Analysis_Options
  (
     p_commit          =>    p_commit
   , p_Anal_Opt_Rec    =>    p_Anal_Opt_Rec
   , x_Anal_Opt_Rec    =>    x_Anal_Opt_Rec
   , p_data_source     =>    NULL
   , x_return_status   =>    x_return_status
   , x_msg_count       =>    x_msg_count
   , x_msg_data        =>    x_msg_data
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Retrieve_Analysis_Options;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_Anal_Opt_Rec        IN OUT NOCOPY     BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,p_data_source         IN             VARCHAR2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_ANALYSIS_OPTION_PVT.Retrieve_Analysis_Options( p_commit
                                                    ,p_Anal_Opt_Rec
                                                    ,x_Anal_Opt_Rec
                                                    ,p_data_source
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);
  Retrieve_Analysis_Measures( p_commit
                             ,p_Anal_Opt_Rec
                             ,x_Anal_Opt_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Analysis_Options;
/************************************************************************************
************************************************************************************/

procedure Update_Analysis_Options
(       p_commit              IN            varchar2 -- :=  FND_API.G_FALSE
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   p_data_Source         IN            VARCHAR2
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
) IS
    l_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_count             NUMBER;

    --get shared indicators
    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     Prototype_Flag   <>  2;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_Anal_Opt_Rec := p_Anal_Opt_Rec;

  BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Options( p_commit
                                                  ,p_Anal_Opt_Rec
                                                  ,p_data_source
                                                  ,x_return_status
                                                  ,x_msg_count
                                                  ,x_msg_data);

  Update_Analysis_Measures( p_commit
                           ,p_Anal_Opt_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
    -- if there are any shared KPIs update those also.
    FOR cd IN c_kpi_ids LOOP
        l_Anal_Opt_Rec.Bsc_Kpi_Id   :=  cd.Indicator;
        BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Options( p_commit
                                                        ,l_Anal_Opt_Rec
                                                        ,p_data_source
                                                        ,x_return_status
                                                        ,x_msg_count
                                                        ,x_msg_data);

        Update_Analysis_Measures( p_commit
                                 ,l_Anal_Opt_Rec
                                 ,x_return_status
                                 ,x_msg_count
                                 ,x_msg_data);
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Analysis_Options;

/************************************************************************************
************************************************************************************/

procedure Update_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Update_Analysis_Options(
    p_commit              =>  p_commit
   ,p_Anal_Opt_Rec        =>  p_Anal_Opt_Rec
   ,p_data_Source         =>  NULL
   ,x_return_status       =>  x_return_status
   ,x_msg_count           =>  x_msg_count
   ,x_msg_data            =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Analysis_Options;

/************************************************************************************
************************************************************************************/


procedure Delete_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options( p_commit
                                                  ,p_Anal_Opt_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Analysis_Options;

/************************************************************************************
************************************************************************************/

--: This procedure assigns the given measure to the given analysis option.
--: This procedure is part of the Analysis Option API.

procedure Create_Analysis_Measures(
  p_commit              IN      VARCHAR2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Anal_Opt_Rec          BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
l_Kpi_Measure_Id        bsc_kpi_analysis_measures_b.Kpi_Measure_Id%TYPE;
l_Default_Value         NUMBER;
l_commit                VARCHAR2(2)  := FND_API.G_FALSE;
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT Create_Analysis_Measures_PUB;
  -- set all values of local record equal to the ones passed.
  l_Anal_Opt_Rec := p_Anal_Opt_Rec;

  SELECT BSC_KPI_MEASURE_S.nextval
  INTO   l_Kpi_Measure_Id
  FROM   SYS.DUAL;

  IF l_Anal_Opt_Rec.Bsc_Kpi_Measure_Id IS NULL THEN
     l_Anal_Opt_Rec.Bsc_Kpi_Measure_Id := l_Kpi_Measure_Id;
  END IF;

  -- Default Prototype Flag for color calculation
  IF l_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag IS NULL THEN
    l_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag := BSC_DESIGNER_PVT.C_COLOR_CHANGE;
  END IF;

   BSC_ANALYSIS_OPTION_PVT.Cascade_Series_Default_Value (
          p_Commit        => l_commit
        , p_Api_Mode      => BSC_ANALYSIS_OPTION_PVT.C_API_CREATE
        , p_Kpi_Id        => l_Anal_Opt_Rec.Bsc_Kpi_Id
        , p_Option0       => NVL(l_Anal_Opt_Rec.Bsc_Option_Group0, 0)
        , p_Option1       => NVL(l_Anal_Opt_Rec.Bsc_Option_Group1, 0)
        , p_Option2       => NVL(l_Anal_Opt_Rec.Bsc_Option_Group2, 0)
        , p_Series_Id     => NVL(l_Anal_Opt_Rec.Bsc_Dataset_Series_Id, 0)
        , p_Default_Value => NVL(l_Anal_Opt_Rec.Bsc_Dataset_Default_Value, 0)
        , x_Default_Value => l_Default_Value -- nocopied
        , x_Return_Status => x_Return_Status
        , x_Msg_Count     => x_Msg_Count
        , x_Msg_Data      => x_Msg_Data
    );

    l_Anal_Opt_Rec.Bsc_Dataset_Default_Value := l_Default_Value;


  -- Call private version of the procedure.
  BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Measures( l_commit
                                                   ,l_Anal_Opt_Rec
                                                   ,x_return_status
                                                   ,x_msg_count
                                                   ,x_msg_data);
  --Use this and populate l_Anal_Opt_Rec.Bsc_Kpi_Measure_Id

  BSC_KPI_MEASURE_PROPS_PUB.Create_Default_Kpi_Meas_Props (
     p_commit          =>   l_commit
    ,p_objective_id    =>   l_Anal_Opt_Rec.Bsc_Kpi_Id
    ,p_kpi_measure_id  =>   l_Kpi_Measure_Id
    ,p_cascade_shared  =>   FALSE
    ,x_return_status   =>   x_return_status
    ,x_msg_count       =>   x_msg_count
    ,x_msg_data        =>   x_Msg_Data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_COLOR_RANGES_PUB.Create_Def_Color_Prop_Ranges(
     p_commit          =>   l_commit
    ,p_objective_id    =>   l_Anal_Opt_Rec.Bsc_Kpi_Id
    ,p_kpi_measure_id  =>   l_Kpi_Measure_Id
    ,p_cascade_shared  =>   FALSE
    ,x_return_status   =>   x_return_status
    ,x_msg_count       =>   x_msg_count
    ,x_msg_data        =>   x_Msg_Data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF(l_commit = FND_API.G_TRUE)  THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_Analysis_Measures_PUB;
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
        ROLLBACK TO Create_Analysis_Measures_PUB;
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
        ROLLBACK TO Create_Analysis_Measures_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO Create_Analysis_Measures_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Analysis_Measures;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_Anal_Opt_Rec        IN OUT NOCOPY     BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_ANALYSIS_OPTION_PVT.Retrieve_Analysis_Measures( p_commit
                                                     ,p_Anal_Opt_Rec
                                                     ,x_Anal_Opt_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Retrieve_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Analysis_Measures;

/************************************************************************************
************************************************************************************/

procedure Update_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Anal_Opt_Rec          BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
l_Default_Value         NUMBER;

begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_Anal_Opt_Rec := p_Anal_Opt_Rec;

   BSC_ANALYSIS_OPTION_PVT.Cascade_Series_Default_Value (
          p_Commit        => p_Commit
        , p_Api_Mode      => BSC_ANALYSIS_OPTION_PVT.C_API_UPDATE
        , p_Kpi_Id        => l_Anal_Opt_Rec.Bsc_Kpi_Id
        , p_Option0       => NVL(l_Anal_Opt_Rec.Bsc_Option_Group0, 0)
        , p_Option1       => NVL(l_Anal_Opt_Rec.Bsc_Option_Group1, 0)
        , p_Option2       => NVL(l_Anal_Opt_Rec.Bsc_Option_Group2, 0)
        , p_Series_Id     => NVL(l_Anal_Opt_Rec.Bsc_Dataset_Series_Id, 0)
        , p_Default_Value => NVL(l_Anal_Opt_Rec.Bsc_Dataset_Default_Value, 0)
        , x_Default_Value => l_Default_Value
        , x_Return_Status => x_Return_Status
        , x_Msg_Count     => x_Msg_Count
        , x_Msg_Data      => x_Msg_Data
    );

    l_Anal_Opt_Rec.Bsc_Dataset_Default_Value := l_Default_Value;


    BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Measures( p_commit
                                                     ,l_Anal_Opt_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Analysis_Measures;

/************************************************************************************
--	API name 	: Cascade_Deletion_Color_Props
--	Type		: Public
--	Function	:
************************************************************************************/

PROCEDURE Cascade_Deletion_Color_Props (
  p_commit              IN      VARCHAR2  :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) IS

  CURSOR c_Removed_Kpis IS
  SELECT
    kpi_measure_id
  FROM
    bsc_kpi_measure_props
  WHERE
    indicator = p_Anal_Opt_Rec.Bsc_Kpi_id
  MINUS
  SELECT
    kpi_measure_id
  FROM
    bsc_kpi_analysis_measures_b
  WHERE
    indicator = p_Anal_Opt_Rec.Bsc_Kpi_id;
BEGIN

  FOR cd in c_Removed_Kpis LOOP
    BSC_KPI_MEASURE_PROPS_PUB.Delete_Kpi_Measure_Props (
       p_commit          =>   FND_API.G_FALSE
      ,p_objective_id    =>   p_Anal_Opt_Rec.Bsc_Kpi_Id
      ,p_kpi_measure_id  =>   cd.kpi_measure_id
      ,p_cascade_shared  =>   FALSE
      ,x_return_status   =>   x_return_status
      ,x_msg_count       =>   x_msg_count
      ,x_msg_data        =>   x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_COLOR_RANGES_PUB.Delete_Color_Prop_Ranges (
       p_commit          =>   FND_API.G_FALSE
      ,p_objective_id    =>   p_Anal_Opt_Rec.Bsc_Kpi_Id
      ,p_kpi_measure_id  =>   cd.kpi_measure_id
      ,p_cascade_shared  =>   FALSE
      ,x_return_status   =>   x_return_status
      ,x_msg_count       =>   x_msg_count
      ,x_msg_data        =>   x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Kpi_Measure_Weights (
       p_commit          =>   FND_API.G_FALSE
      ,p_objective_id    =>   p_Anal_Opt_Rec.Bsc_Kpi_Id
      ,p_kpi_measure_id  =>   cd.kpi_measure_id
      ,p_cascade_shared  =>   FALSE
      ,x_return_status   =>   x_return_status
      ,x_msg_count       =>   x_msg_count
      ,x_msg_data        =>   x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    DELETE FROM bsc_sys_kpi_colors
    WHERE indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id AND
    kpi_measure_id = cd.kpi_measure_id;

  END LOOP;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO Create_Analayis_OptionObjPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Cascade_Deletion_Color_Props ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Cascade_Deletion_Color_Props ';
        END IF;
END Cascade_Deletion_Color_Props;

/************************************************************************************
************************************************************************************/

procedure Delete_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is
begin

    x_return_status := FND_API.G_RET_STS_SUCCESS;


   BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Measures( p_commit
                                                     ,p_Anal_Opt_Rec
                                                     ,x_return_status
                                                     ,x_msg_count
                                                     ,x_msg_data);

   Cascade_Deletion_Color_Props (
     p_commit           =>  p_commit
    ,p_Anal_Opt_Rec     =>  p_Anal_Opt_Rec
    ,x_return_status    =>  x_return_status
    ,x_msg_count        =>  x_msg_count
    ,x_msg_data         =>  x_msg_data
   ) ;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Analysis_Measures;

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Ana_Opt_Mult_Groups
(       p_commit              IN            VARCHAR2:=FND_API.G_FALSE
    ,   p_Kpi_id              IN            BSC_KPIS_B.indicator%TYPE
    ,   p_Anal_Opt_Tbl        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
    ,   p_max_group_count     IN            NUMBER
    ,   p_Anal_Opt_Comb_Tbl   IN            BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
)IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   BSC_ANALYSIS_OPTION_PVT.Delete_Ana_Opt_Mult_Groups
   (       p_commit              =>  FND_API.G_FALSE
       ,   p_Kpi_id              =>  p_Kpi_id
       ,   p_Anal_Opt_Tbl        =>  p_Anal_Opt_Tbl
       ,   p_max_group_count     =>  p_max_group_count
       ,   p_Anal_Opt_Comb_Tbl   =>  p_Anal_Opt_Comb_Tbl
       ,   p_Anal_Opt_Rec        =>  p_Anal_Opt_Rec
       ,   x_return_status       =>  x_return_status
       ,   x_msg_count           =>  x_msg_count
       ,   x_msg_data            =>  x_msg_data
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
          x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       ELSE
          x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       END IF;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Ana_Opt_Mult_Groups;
/************************************************************************************
************************************************************************************/

PROCEDURE Synch_Kpi_Anal_Group
(
         p_commit              IN            VARCHAR2:=FND_API.G_FALSE
     ,   p_Kpi_Id              IN            BSC_KPIS_B.indicator%TYPE
     ,   p_Anal_Opt_Tbl        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
     ,   x_return_status       OUT NOCOPY    VARCHAR2
     ,   x_msg_count           OUT NOCOPY    NUMBER
     ,   x_msg_data            OUT NOCOPY    VARCHAR2
)IS
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        BSC_ANALYSIS_OPTION_PVT.Synch_Kpi_Anal_Group
        (       p_commit              =>    FND_API.G_FALSE
            ,   p_Kpi_Id              =>    p_Kpi_Id
            ,   p_Anal_Opt_Tbl        =>    p_Anal_Opt_Tbl
            ,   x_return_status       =>    x_return_status
            ,   x_msg_count           =>    x_msg_count
            ,   x_msg_data            =>    x_msg_data
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
          x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Synch_Kpi_Anal_Group ';
       ELSE
          x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Synch_Kpi_Anal_Group ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Synch_Kpi_Anal_Group ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Synch_Kpi_Anal_Group ';
       END IF;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END  Synch_Kpi_Anal_Group;

--ADDED BY RAVI


PROCEDURE store_anal_opt_grp_count
(     p_kpi_id        IN            NUMBER
  ,   x_Anal_Opt_Tbl  IN OUT NOCOPY BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
) IS
BEGIN

      BSC_ANALYSIS_OPTION_PVT.store_anal_opt_grp_count
      (
            p_kpi_id        =>  p_kpi_id
          , x_Anal_Opt_Tbl  =>  x_Anal_Opt_Tbl
      );

END store_anal_opt_grp_count;


/************************************************************************************
************************************************************************************/
PROCEDURE Validate_Custom_Measure
(    p_kpi_id              IN         BSC_OAF_ANALYSYS_OPT_COMB_V.INDICATOR%TYPE
    , p_option0            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION0%TYPE
    , p_option1            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION1%TYPE
    , p_option2            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION2%TYPE
    , p_series_id          IN         BSC_OAF_ANALYSYS_OPT_COMB_V.SERIES_ID%TYPE
    , x_return_status       OUT NOCOPY    VARCHAR2
    , x_msg_count           OUT NOCOPY    NUMBER
    , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
    l_Kpi_Short_Name   BSC_KPIS_B.SHORT_NAME%TYPE;
    l_Kpi_Name         BSC_KPIS_VL.NAME%TYPE;
    l_Dataseries_Name  BSC_KPI_ANALYSIS_MEASURES_VL.NAME%TYPE;

    CURSOR c_Objective_Name_Details IS
        SELECT OBJ.NAME OBJ_NAME,
               OBJ.SHORT_NAME SHORT_NAME,
               DS.NAME KPI_NAME
        FROM   BSC_KPIS_VL OBJ,
               BSC_KPI_ANALYSIS_MEASURES_VL DS
        WHERE  DS.INDICATOR        = p_kpi_id
        AND    DS.ANALYSIS_OPTION0 = p_option0
        AND    DS.ANALYSIS_OPTION1 = p_option1
        AND    DS.ANALYSIS_OPTION2 = p_option2
        AND    DS.SERIES_ID        = p_series_id
        AND    OBJ.INDICATOR       = DS.INDICATOR;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- adrao modified cursor and introduced new call to is_Objective_Report_Type, which is appropriate.
    -- Bug#4357962
    FOR cSN IN c_Objective_Name_Details LOOP
      l_Kpi_Short_Name  := cSN.SHORT_NAME;
      l_Kpi_Name        := cSN.OBJ_NAME;
      l_Dataseries_Name := cSN.KPI_NAME;

      -- Changed message for Bug#4590994
      IF (l_Kpi_Short_Name IS NOT NULL) THEN
          IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.is_Objective_Report_Type(l_Kpi_Short_Name) = FND_API.G_TRUE) THEN
             FND_MESSAGE.SET_NAME('BSC','BSC_D_DELETE_RPT_KPI_OBJ');
             FND_MESSAGE.SET_TOKEN('OBJECTIVE', l_Kpi_Name);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;
    END LOOP;

    BSC_ANALYSIS_OPTION_PVT.Validate_Custom_Measure
   (       p_Kpi_id              =>  p_Kpi_id
       ,   p_option0             =>  p_option0
       ,   p_option1             =>  p_option1
       ,   p_option2             =>  p_option2
       ,   p_series_id           =>  p_series_id
       ,   x_return_status       =>  x_return_status
       ,   x_msg_count           =>  x_msg_count
       ,   x_msg_data            =>  x_msg_data
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
          x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       ELSE
          x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       END IF;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Validate_Custom_Measure;
/************************************************************************************
************************************************************************************/

PROCEDURE delete_extra_series(
      p_Bsc_Anal_Opt_Rec    IN  BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    , x_return_status       OUT NOCOPY    VARCHAR2
    , x_msg_count           OUT NOCOPY    NUMBER
    , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Initialize;

    BSC_ANALYSIS_OPTION_PVT.delete_extra_series(
          p_Bsc_Anal_Opt_Rec    => p_Bsc_Anal_Opt_Rec
        , x_return_status       => x_return_status
        , x_msg_count           => x_msg_count
        , x_msg_data            => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
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
          x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       ELSE
          x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       END IF;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END delete_extra_series;

--------------------------------------------------------------------------------

PROCEDURE Create_Data_Series
(       p_commit              IN            VARCHAR2 -- FND_API.G_FALSE
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_Anal_Opt_Rec        OUT NOCOPY    BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
) IS
    l_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_share_flag        NUMBER;
    l_count             NUMBER;
    l_series_color      NUMBER;
    l_BM_color          NUMBER;
    l_max_series_id     NUMBER;
    l_series_id         NUMBER;

    --get shared indicators
    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  l_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     Prototype_Flag   <>  2;

    CURSOR c_Series_color IS
    SELECT SERIES_COLOR, BM_COLOR
    FROM BSC_SYS_SERIES_COLORS
    WHERE SERIES_ID =  l_series_id;

    -- Get the Data Series Ids using Default mesures
      CURSOR c_Default_Data_Series IS
      SELECT SERIES_ID
      INTO l_count
      FROM BSC_KPI_ANALYSIS_MEASURES_B
      WHERE indicator           = l_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = l_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = l_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = l_Anal_Opt_Rec.Bsc_Option_Group2
           AND dataset_id = -1
     ORDER BY SERIES_ID DESC;


begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Anal_Opt_Rec := p_Anal_Opt_Rec;

  --- Check Objective Id
  if p_Anal_Opt_Rec.Bsc_Kpi_Id is not null then
     SELECT COUNT(0)
     INTO   l_count
     FROM   BSC_KPIS_B
     WHERE INDICATOR = p_Anal_Opt_Rec.Bsc_Kpi_Id;
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

 -- Verify that this is not a Shared KPI.
  select share_flag
      into l_share_flag
      from BSC_KPIS_B
     where indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id;

    if l_share_flag = 2 then
      FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

  -- Set Default values for Anaysis options parameter
  if l_Anal_Opt_Rec.Bsc_Option_Group0 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group0 := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Option_Group1 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group1 := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Option_Group2 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group2 := 0;
  end if;

  -- If there is no current Data set then set the data set equal to -1, and set the name
  -- of the measure to a default name.
  if l_Anal_Opt_Rec.Bsc_Dataset_Id is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Id := -1;
    l_Anal_Opt_Rec.Bsc_Measure_Long_Name := BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_COMMON', 'DEFAULT') ||
 ' ' || BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_COMMON', 'EDW_MEASURE');

    l_Anal_Opt_Rec.Bsc_Measure_Help := l_Anal_Opt_Rec.Bsc_Measure_Long_Name;
  end if;

   -- Delete Default measures asociated to the Analysis Option
  if l_Anal_Opt_Rec.Bsc_Dataset_Id <> -1  then
       FOR CD IN c_Default_Data_Series LOOP
         l_Anal_Opt_Rec.Bsc_Dataset_Series_Id  := CD.SERIES_ID;
         l_Anal_Opt_Rec.Bsc_New_Kpi := 'Y';
         Delete_Data_Series(
                  p_commit            =>  p_commit
                  ,p_Anal_Opt_Rec     =>  l_Anal_Opt_Rec
                  ,x_return_status    =>  x_return_status
                  ,x_msg_count        =>  x_msg_count
                  ,x_msg_data         =>  x_msg_data
          );
       END LOOP;
   end if;
 l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

  -- set the Series Id
  if l_Anal_Opt_Rec.Bsc_Dataset_Series_Id is null then
      SELECT COUNT (SERIES_ID)
      INTO l_count
      FROM BSC_KPI_ANALYSIS_MEASURES_B
      WHERE indicator        = l_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = l_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = l_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = l_Anal_Opt_Rec.Bsc_Option_Group2;
      IF l_count <> 0 then
          SELECT MAX(SERIES_ID) + 1
          into l_Anal_Opt_Rec.Bsc_Dataset_Series_Id
          from BSC_KPI_ANALYSIS_MEASURES_B
          WHERE indicator        = l_Anal_Opt_Rec.Bsc_Kpi_Id
               AND analysis_option0 = l_Anal_Opt_Rec.Bsc_Option_Group0
               AND analysis_option1 = l_Anal_Opt_Rec.Bsc_Option_Group1
               AND analysis_option2 = l_Anal_Opt_Rec.Bsc_Option_Group2;
      ELSE
          l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := 0;
      END IF;
  end if;
  -- Check if it needs to update the Default DataSeries instead of create a New
  -- Data Series
  --- Get Default Color for the Serie:
  -- Assign certain default values if they are currently null.
  if l_Anal_Opt_Rec.Bsc_Dataset_Axis is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Axis := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Default_Value is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Default_Value := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Series_Type is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Type := 1;
  end if;
  if l_Anal_Opt_Rec.Bsc_Option_Help is null then
    l_Anal_Opt_Rec.Bsc_Option_Help := l_Anal_Opt_Rec.Bsc_Option_Name;
  end if;

  if l_Anal_Opt_Rec.Bsc_Dataset_Series_Color is null
        or l_Anal_Opt_Rec.Bsc_Dataset_Series_Color is null then
   -- Get the Default Color for the Series
     l_series_color := 10053171;
     l_BM_color     := 10053171;
     l_series_id := l_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
     SELECT MAX(SERIES_ID)
       INTO l_max_series_id
       FROM BSC_SYS_SERIES_COLORS;
     WHILE l_series_id > l_max_series_id  LOOP
      l_series_id := l_series_id - l_max_series_id -1;
     END LOOP;
    IF (c_Series_color%ISOPEN) THEN
       CLOSE c_Series_color;
    END IF;
    FOR cd IN c_Series_color LOOP
       l_series_color := cd.SERIES_COLOR;
       l_BM_color     := cd.BM_COLOR;
    END LOOP;
    --
     if l_Anal_Opt_Rec.Bsc_Dataset_Series_Color is null then
         l_Anal_Opt_Rec.Bsc_Dataset_Series_Color := l_series_color;
     end if;
     if l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color is null then
      l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color := l_BM_color;
     end if;
  end if;

  -- Get the name for the Data Set Id given.
    if l_Anal_Opt_Rec.Bsc_Measure_Long_Name is null then
      select name
      into l_Anal_Opt_Rec.Bsc_Measure_Long_Name
      from BSC_SYS_DATASETS_VL
      where dataset_id = l_Anal_Opt_Rec.Bsc_Dataset_Id;
    end if;
    -- If help for the measure is null set it equal to the name.
    if l_Anal_Opt_Rec.Bsc_Measure_Help is null then
      l_Anal_Opt_Rec.Bsc_Measure_Help := l_Anal_Opt_Rec.Bsc_Measure_Long_Name;
    end if;

   -- Call the following procedure.
   Create_Analysis_Measures( p_commit
                             ,l_Anal_Opt_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   BSC_DESIGNER_PVT.ActionFlag_Change( p_Anal_Opt_Rec.Bsc_Kpi_Id ,
                               BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure );

   x_Anal_Opt_Rec  := l_Anal_Opt_Rec;

    -- repeat the steps for shared indicators also
    FOR cd IN c_kpi_ids LOOP
        l_Anal_Opt_Rec.Bsc_Kpi_Id   := cd.Indicator;
        Create_Analysis_Measures( p_commit
                                 ,l_Anal_Opt_Rec
                                 ,x_return_status
                                 ,x_msg_count
                                 ,x_msg_data);
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_DESIGNER_PVT.ActionFlag_Change( p_Anal_Opt_Rec.Bsc_Kpi_Id ,
                               BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure );
    END LOOP;
    -----

   if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Series_color%ISOPEN) THEN
           CLOSE c_Series_color;
        END IF;
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
        IF (c_Series_color%ISOPEN) THEN
           CLOSE c_Series_color;
        END IF;
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
        IF (c_Series_color%ISOPEN) THEN
           CLOSE c_Series_color;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Create_Data_Series ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Create_Data_Series ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        IF (c_Series_color%ISOPEN) THEN
           CLOSE c_Series_color;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Create_Data_Series ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Create_Data_Series ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Data_Series;


procedure Update_Data_Series
(       p_commit              IN            VARCHAR2 -- FND_API.G_FALSE
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
) IS
    l_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_count             NUMBER;
    l_share_flag number;

    --get shared indicators
    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     Prototype_Flag   <>  2;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Anal_Opt_Rec := p_Anal_Opt_Rec;

  --- Check Objective Id
  if p_Anal_Opt_Rec.Bsc_Kpi_Id is not null then
     SELECT COUNT(0)
     INTO   l_count
     FROM   BSC_KPIS_B
     WHERE INDICATOR = p_Anal_Opt_Rec.Bsc_Kpi_Id;
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

 -- Verify that this is not a Shared KPI.
  select share_flag
      into l_share_flag
      from BSC_KPIS_B
     where indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id;

    if l_share_flag = 2 then
      FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

  -- Set Default vaues for Anaysis options parameter
  if l_Anal_Opt_Rec.Bsc_Option_Group0 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group0 := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Option_Group1 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group1 := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Option_Group2 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group2 := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Dataset_Series_Id is null then
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := 0;
    -- THROUGH ERROR
  end if;

  BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Measures( FND_API.G_FALSE
                           ,l_Anal_Opt_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- if there are any shared KPIs update those also.
    FOR cd IN c_kpi_ids LOOP
        l_Anal_Opt_Rec.Bsc_Kpi_Id   :=  cd.Indicator;
        BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Measures( FND_API.G_FALSE
                                 ,l_Anal_Opt_Rec
                                 ,x_return_status
                                 ,x_msg_count
                                 ,x_msg_data);
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Update_Data_Series ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Update_Data_Series ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Update_Data_Series ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Update_Data_Series ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Data_Series;

procedure Delete_Data_Series(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Num_Series NUMBER;
l_count NUMBER;
l_Anal_Opt_Rec BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
x_Anal_Opt_Rec  BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
l_share_flag number;

    --get shared indicators
    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  l_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     Prototype_Flag   <>  2;


BEGIN
    FND_MSG_PUB.Initialize;
    SAVEPOINT DeleteBSCDataSeriesPUB;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_Anal_Opt_Rec := p_Anal_Opt_Rec;


  --- Check Objective Id
  if p_Anal_Opt_Rec.Bsc_Kpi_Id is not null then
     SELECT COUNT(0)
     INTO   l_count
     FROM   BSC_KPIS_B
     WHERE INDICATOR = p_Anal_Opt_Rec.Bsc_Kpi_Id;
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

 -- Verify that this is not a Shared KPI.
  select share_flag
      into l_share_flag
      from BSC_KPIS_B
     where indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id;

    if l_share_flag = 2 then
      FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

  -- Set Default vaues for Anaysis options parameter
  if l_Anal_Opt_Rec.Bsc_Option_Group0 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group0 := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Option_Group1 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group1 := 0;
  end if;
  if l_Anal_Opt_Rec.Bsc_Option_Group2 is null then
    l_Anal_Opt_Rec.Bsc_Option_Group2 := 0;
  end if;

    ---Check if the number of Series before delete
    SELECT COUNT(SERIES_ID)
    INTO  l_Num_Series
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2;

    -- delete the dataseries metadata
     BSC_ANALYSIS_OPTION_PVT.delete_Data_Series(
             p_commit               => FND_API.G_FALSE
             ,p_Anal_Opt_Rec        => l_Anal_Opt_Rec
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
     );

     Cascade_Deletion_Color_Props (
       p_commit           =>  p_commit
      ,p_Anal_Opt_Rec     =>  p_Anal_Opt_Rec
      ,x_return_status    =>  x_return_status
      ,x_msg_count        =>  x_msg_count
      ,x_msg_data         =>  x_msg_data
     ) ;
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     BSC_DESIGNER_PVT.ActionFlag_Change( p_Anal_Opt_Rec.Bsc_Kpi_Id ,
                                 BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure );
      -- repeat the steps for shared indicators also

     FOR cd IN c_kpi_ids LOOP
          l_Anal_Opt_Rec.Bsc_Kpi_Id   := cd.Indicator;
          BSC_ANALYSIS_OPTION_PVT.delete_Data_Series(
             p_commit               => FND_API.G_FALSE
             ,p_Anal_Opt_Rec        => l_Anal_Opt_Rec
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
         );

         Cascade_Deletion_Color_Props (
           p_commit           =>  p_commit
          ,p_Anal_Opt_Rec     =>  l_Anal_Opt_Rec
          ,x_return_status    =>  x_return_status
          ,x_msg_count        =>  x_msg_count
          ,x_msg_data         =>  x_msg_data
         ) ;
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         BSC_DESIGNER_PVT.ActionFlag_Change( l_Anal_Opt_Rec.Bsc_Kpi_Id ,
                               BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure );
    END LOOP;

    ---Check if the number of Series is zero in order to inser the Deafault
    ---Data Serie

   IF l_Anal_Opt_Rec.Bsc_New_Kpi IS NULL THEN
      l_Anal_Opt_Rec.Bsc_New_Kpi := 'N';
   END IF;
   IF l_Num_Series = 1 and l_Anal_Opt_Rec.Bsc_New_Kpi <> 'Y' then

      SELECT COUNT(SERIES_ID)
      INTO  l_Num_Series
      FROM BSC_KPI_ANALYSIS_MEASURES_B
      WHERE indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2;
      -- Insert the Default Data Series
      IF l_Num_Series = 0 then
          l_Anal_Opt_Rec := p_Anal_Opt_Rec;
          l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := null;
          l_Anal_Opt_Rec.Bsc_Dataset_Id := null;
          l_Anal_Opt_Rec.Bsc_New_Kpi := 'Y';

          Create_Data_Series(
             p_commit               => p_commit
             ,p_Anal_Opt_Rec        => l_Anal_Opt_Rec
             ,x_Anal_Opt_Rec        => x_Anal_Opt_Rec
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
         );

      END IF;

   END IF;

   if (p_commit = FND_API.G_TRUE) then
      commit;
   end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCDataSeriesPUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCDataSeriesPUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCDataSeriesPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Data_Series ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Data_Series ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

End Delete_Data_Series;


FUNCTION Is_More
(       p_names IN  OUT NOCOPY  VARCHAR2
    ,   p_name        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_names IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_names,   ',');
        IF (l_pos_ids > 0) THEN
            p_name    :=  TRIM(SUBSTR(p_names,    1,    l_pos_ids - 1));
            p_names   :=  TRIM(SUBSTR(p_names,    l_pos_ids + 1));
        ELSE
            p_name    :=  TRIM(p_names);
            p_names   :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;

/*---------------------------------------------------------------------------
 Swap_Data_Series : Swap the Data Series Id between two DataSerid

 Use Parameters:
           p_Anal_Opt_Rec.Bsc_Kpi_Id
           p_Anal_Opt_Rec.Bsc_Option_Group0
           p_Anal_Opt_Rec.Bsc_Option_Group1
           Anal_Opt_Rec.Bsc_Option_Group2
           p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
           p_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id;
----------------------------------------------------------------------------*/
procedure Swap_Data_Series_Id(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

    l_Anal_Opt_Rec        BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    --get shared indicators
    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  l_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     Prototype_Flag   <>  2;

BEGIN
  FND_MSG_PUB.Initialize;
  SAVEPOINT SwapDataSeriesPUB;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_Anal_Opt_Rec := p_Anal_Opt_Rec;
  -- Swaping
  BSC_ANALYSIS_OPTION_PVT.Swap_Data_Series_Id(
          p_commit              =>  FND_API.G_FALSE
         ,p_Anal_Opt_Rec        =>  l_Anal_Opt_Rec
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
        );
  -- Cascading Swaping
    FOR cd IN c_kpi_ids LOOP
        l_Anal_Opt_Rec.Bsc_Kpi_Id   := cd.Indicator;
        BSC_ANALYSIS_OPTION_PVT.Swap_Data_Series_Id(
          p_commit              =>  FND_API.G_FALSE
         ,p_Anal_Opt_Rec        =>  l_Anal_Opt_Rec
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
        );
    END LOOP;

    IF p_commit = FND_API.G_TRUE THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_kpi_ids%ISOPEN) THEN
            CLOSE c_kpi_ids;
        END IF;
        ROLLBACK TO SwapDataSeriesPUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_kpi_ids%ISOPEN) THEN
            CLOSE c_kpi_ids;
        END IF;
        ROLLBACK TO SwapDataSeriesPUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Swap_Data_Series_Id ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Swap_Data_Series_Id ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        IF (c_kpi_ids%ISOPEN) THEN
            CLOSE c_kpi_ids;
        END IF;
        ROLLBACK TO SwapDataSeriesPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Swap_Data_Series_Id ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Swap_Data_Series_Id ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

End Swap_Data_Series_Id;

/*-----------------------------------------------------------------------
Rearrange_Data_Series:
    Rearrange the Data Series Id following same order that the Measure

    p_Measure_Seq : contains the sh

------------------------------------------------------------------------*/
procedure Rearrange_Data_Series(
    p_commit            IN      varchar2  -- FND_API.G_FALSE
   ,p_Kpi_Id            IN      number
   ,p_option_group0     IN      number
   ,p_option_group1     IN      number
   ,p_option_group2     IN      number
   ,p_Measure_Seq       IN      varchar2
   ,p_add_flag          IN      varchar2   -- FND_API.G_FALSE
   ,p_remove_flag       IN      varchar2   -- FND_API.G_FALSE
   ,x_return_status     OUT NOCOPY     varchar2
   ,x_msg_count         OUT NOCOPY     number
   ,x_msg_data          OUT NOCOPY     varchar2
) is

  l_short_name      VARCHAR2(100);
  l_short_names      VARCHAR2(3000);
  l_Anal_Opt_Rec    BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  x_Anal_Opt_Rec    BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_attribute_code  VARCHAR2(100);
  l_count         NUMBER;

  l_Measure_Short_Name  BIS_INDICATORS.SHORT_NAME%TYPE;
  l_Objective_Short_Name BSC_KPIS_B.SHORT_NAME%TYPE;
  l_Measure_Source BSC_SYS_DATASETS_B.SOURCE%TYPE;

  l_Comparison_Source               BIS_INDICATORS.COMPARISON_SOURCE%TYPE;
  l_Compare_Attribute_Code          AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE;

-- Cursor to get the Data Set Id correspondig to each Short_name
Cursor  c_Dataset is
  SELECT
    i.dataset_id
  FROM
    bis_indicators i
  WHERE
    i.short_name = l_short_name;

-- Cursor to get the Data Series Id correspondig each  Data Set
Cursor c_Data_Series is
    SELECT SERIES_ID, DATASET_ID
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id
           AND ANALYSIS_OPTION0 = l_Anal_Opt_Rec.Bsc_Option_Group0
           AND ANALYSIS_OPTION1 = l_Anal_Opt_Rec.Bsc_Option_Group1
           AND ANALYSIS_OPTION2 = l_Anal_Opt_Rec.Bsc_Option_Group2
           AND DATASET_ID =  l_Anal_Opt_Rec.Bsc_Dataset_Id;

-- Cursor to get the Data Series not applied any more
Cursor c_Data_Series_Remove is
    SELECT SERIES_ID, DATASET_ID
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id
           AND ANALYSIS_OPTION0 = l_Anal_Opt_Rec.Bsc_Option_Group0
           AND ANALYSIS_OPTION1 = l_Anal_Opt_Rec.Bsc_Option_Group1
           AND ANALYSIS_OPTION2 = l_Anal_Opt_Rec.Bsc_Option_Group2
           AND SERIES_ID >=  l_count
    ORDER BY SERIES_ID DESC;

BEGIN
  FND_MSG_PUB.Initialize;
  SAVEPOINT Rearrange_Data_SeriesVT;

  l_Anal_Opt_Rec.Bsc_Option_Group0 := 0;
  l_Anal_Opt_Rec.Bsc_Option_Group1 := 0;
  l_Anal_Opt_Rec.Bsc_Option_Group2 := 0;

  l_Anal_Opt_Rec.Bsc_Kpi_Id := p_Kpi_Id;
  IF p_option_group0 IS NOT NULL THEN
    l_Anal_Opt_Rec.Bsc_Option_Group0 := p_option_group0;
  END IF;
  IF p_option_group1 IS NOT NULL THEN
  l_Anal_Opt_Rec.Bsc_Option_Group1 := p_option_group1;
  END IF;
  IF p_option_group2 IS NOT NULL THEN
    l_Anal_Opt_Rec.Bsc_Option_Group2 := p_option_group2;
  END IF;
  l_count := 0;

  IF (p_Measure_Seq IS NOT NULL) THEN
     l_short_names   :=  p_Measure_Seq;
     WHILE (is_more(  p_names   =>  l_short_names
                     , p_name   =>  l_short_name))
     LOOP
       l_count := l_count + 1;
        -- Get the dataset associte the the Measure Shorename
       l_Anal_Opt_Rec.Bsc_Dataset_Id := NULL;
       l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := NULL;
       l_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id :=  NULL;
       FOR CD IN c_Dataset LOOP
          l_Anal_Opt_Rec.Bsc_Dataset_Id := CD.DATASET_ID;
       END LOOP;
       IF l_Anal_Opt_Rec.Bsc_Dataset_Id IS NOT NULL THEN
          -- Get the Series Id
          FOR CD1 IN c_Data_Series LOOP
            l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := CD1.SERIES_ID;
          END LOOP;
          IF p_add_flag = FND_API.G_TRUE
             AND l_Anal_Opt_Rec.Bsc_Dataset_Series_Id IS NULL THEN
            --- Create the Data Series for the new Data Set ID
            Create_Data_Series(
                p_commit              =>  p_commit
               ,p_Anal_Opt_Rec        =>  l_Anal_Opt_Rec
               ,x_Anal_Opt_Rec        =>  x_Anal_Opt_Rec
               ,x_return_status       =>  x_return_status
               ,x_msg_count           =>  x_msg_count
               ,x_msg_data            =>  x_msg_data
             );
             l_Anal_Opt_Rec.Bsc_Dataset_Series_Id :=
                                      x_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
          END IF;
          IF l_Anal_Opt_Rec.Bsc_Dataset_Series_Id IS NOT NULL THEN
            -- Swap the dataseries.  Set the Series_id = l_count-1
            l_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id := l_count-1;
            Swap_Data_Series_Id(
                p_commit              =>  p_commit
               ,p_Anal_Opt_Rec        =>  l_Anal_Opt_Rec
               ,x_return_status       =>  x_return_status
               ,x_msg_count           =>  x_msg_count
               ,x_msg_data            =>  x_msg_data
             );
          END IF;
       ELSE
         FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MEAS_ID');
         FND_MESSAGE.SET_TOKEN('BSC_MEAS', l_short_name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END LOOP;
  END IF;
  -- Remove the Data Series not used
  IF p_remove_flag = FND_API.G_TRUE THEN
          FOR CD IN c_Data_Series_Remove LOOP
             l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := CD.SERIES_ID;
              Delete_Data_Series(
                 p_commit              =>  p_commit
                 ,p_Anal_Opt_Rec        =>  l_Anal_Opt_Rec
                 ,x_return_status       =>  x_return_status
                 ,x_msg_count           =>  x_msg_count
                 ,x_msg_data            =>  x_msg_data
              );
              --Bug 5526265 Moved updation of the data source logic to Java Layer
          END LOOP;
   END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Data_Series%ISOPEN) THEN
            CLOSE c_Data_Series;
        END IF;
        ROLLBACK TO SwapDataSeriesPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Data_Series%ISOPEN) THEN
            CLOSE c_Data_Series;
        END IF;
        ROLLBACK TO RearrangeDataSeriesPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
    WHEN OTHERS THEN
        IF (c_Data_Series%ISOPEN) THEN
            CLOSE c_Data_Series;
        END IF;
        ROLLBACK TO RearrangeDataSeriesPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Rearrange_Data_Series ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Rearrange_Data_Series ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

End Rearrange_Data_Series;

/***********************************************************
 Name       : Get_Num_Analysis_options
 Description: This Function returns the number of analysis options in the current
              Analysis Group
 Input      : p_obj_id            --> Objective Id
              p_anal_grp_Id       --> Analysis Group Id
 Created BY : ashankar For bug 4220400
/**********************************************************/

FUNCTION Get_Num_Analysis_options
(
    p_obj_id       IN  BSC_KPIS_B.indicator%TYPE
  , p_anal_grp_Id  IN  BSC_KPI_ANALYSIS_GROUPS.analysis_group_id%TYPE
)RETURN NUMBER IS
  l_count   NUMBER;
BEGIN
   SELECT num_of_options
   INTO   l_count
   FROM   BSC_KPI_ANALYSIS_GROUPS
   WHERE  indicator =p_obj_id
   AND    analysis_group_id = p_anal_grp_Id;

   RETURN l_count;
END Get_Num_Analysis_options;


/***********************************************************
 Name       : Get_Analysis_Group_Id
 Description: This Function returns the current Analysis Group Id based on the current Analysis
              option combination.
 Input      : p_obj_id            --> Objective Id
              p_Anal_Opt_Comb_Tbl --> Analysis option combination table.
              p_max_group_count   --> Maximum analysis groups in the current objective

 Created BY : ashankar For bug 4220400
/**********************************************************/

FUNCTION Get_Analysis_Group_Id
(
   p_Anal_Opt_Comb_Tbl      IN   BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
 , p_obj_id                 IN   BSC_KPIS_B.indicator%TYPE
) RETURN NUMBER IS

   l_Anal_Opt_Tbl           BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type;
   l_Anal_Grp_Id            NUMBER;
   l_Anal_Det_Opt_Tbl       BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Det_Tbl_Type;
   l_count                  NUMBER;
   l_option_count           NUMBER;
   l_max_group_count        NUMBER;

BEGIN
     SELECT COUNT(0)
     INTO   l_max_group_count
     FROM   bsc_kpi_analysis_groups
     WHERE  indicator = p_obj_id;

     IF(l_max_group_count>1) THEN
         BSC_BIS_KPI_MEAS_PUB.store_kpi_anal_group(p_obj_id, l_Anal_Opt_Tbl);

         IF(BSC_ANALYSIS_OPTION_PVT.Validate_If_single_Anal_Opt(l_Anal_Opt_Tbl)) THEN
           l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP0;
           RETURN l_Anal_Grp_Id;
         END IF;

         BSC_ANALYSIS_OPTION_PVT.Initialize_Anal_Opt_Tbl
         (
              p_Kpi_id            =>  p_obj_id
            , p_Anal_Opt_Tbl      =>  l_Anal_Opt_Tbl
            , p_max_group_count   =>  l_max_group_count
            , p_Anal_Opt_Comb_Tbl =>  p_Anal_Opt_Comb_Tbl
            , p_Anal_Det_Opt_Tbl  =>  l_Anal_Det_Opt_Tbl
         );

         l_count := l_Anal_Det_Opt_Tbl.COUNT - 1 ;
         IF(l_count=1)THEN
           IF((l_Anal_Det_Opt_Tbl(l_count).Bsc_dependency_flag = 1)) THEN
                IF((l_Anal_Det_Opt_Tbl.EXISTS(l_count-1))AND(l_Anal_Det_Opt_Tbl(l_count-1).No_of_child=1)) THEN
                  l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP0;
                ELSE
                  l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1;
                END IF;
           ELSE
                l_option_count := Get_Num_Analysis_options
                                   (
                                      p_obj_id      => p_obj_id
                                    , p_anal_grp_Id => BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1
                                   );
                IF(l_option_count >1) THEN
                    l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1;
                ELSE
                    l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP0;
                END IF;
           END IF;
         ELSE
           IF((l_Anal_Det_Opt_Tbl(l_count).Bsc_dependency_flag = 1)) THEN
                IF((l_Anal_Det_Opt_Tbl.EXISTS(l_count-1))AND(l_Anal_Det_Opt_Tbl(l_count-1).No_of_child=1)) THEN
                    IF((l_Anal_Det_Opt_Tbl(l_count-1).Bsc_dependency_flag = 1)) THEN
                      IF((l_Anal_Det_Opt_Tbl.EXISTS(l_count-2))AND(l_Anal_Det_Opt_Tbl(l_count-2).No_of_child=1)) THEN
                         l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP0;
                      ELSE
                         l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1;
                      END IF;
                    ELSE
                      l_option_count := Get_Num_Analysis_options
                                        (
                                            p_obj_id      => p_obj_id
                                          , p_anal_grp_Id => BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1
                                        );
                     IF(l_option_count >1) THEN
                       l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1;
                     ELSE
                       l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP0;
                     END IF;
                    END IF;

                ELSE
                    l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP2;
                END IF;
           ELSE
                l_option_count := Get_Num_Analysis_options
                                  (
                                       p_obj_id      => p_obj_id
                                     , p_anal_grp_Id => BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP2
                                  );
               IF(l_option_count >1) THEN
                    l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP2;
               ELSE
                   IF((l_Anal_Det_Opt_Tbl(l_count-1).Bsc_dependency_flag = 1)) THEN
                        IF((l_Anal_Det_Opt_Tbl.EXISTS(l_count-2))AND(l_Anal_Det_Opt_Tbl(l_count-2).No_of_child=1)) THEN
                             l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP0;
                        ELSE
                             l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1;
                        END IF;
                   ELSE
                        l_option_count := Get_Num_Analysis_options
                                          (
                                              p_obj_id      => p_obj_id
                                            , p_anal_grp_Id => BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1
                                          );
                        IF(l_option_count >1) THEN
                             l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP1;
                        ELSE
                             l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP0;
                        END IF;
                   END IF;
               END IF;
           END IF;
         END IF;
     ELSE
        l_Anal_Grp_Id := BSC_ANALYSIS_OPTION_PUB.c_ANALYSIS_GROUP0;
     END IF;
    RETURN l_Anal_Grp_Id;
END Get_Analysis_Group_Id;

/***********************************************************
 Name       : Set_Default_Analysis_Option
 Description: This Function sets the default Analysis option combination for the objective.
 Input      : p_obj_id            --> Objective Id
              p_Anal_Opt_Comb_Tbl --> Analysis option combination table.
              p_Anal_Grp_Id       --> Analysis Group Id

 Created BY : ashankar For bug 4220400
/**********************************************************/
PROCEDURE Set_Default_Analysis_Option
(
      p_commit              IN             VARCHAR
    , p_obj_id              IN             BSC_KPIS_B.indicator%TYPE
    , p_Anal_Opt_Comb_Tbl   IN             BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
    , p_Anal_Grp_Id         IN             BSC_KPIS_B.ind_group_id%TYPE
    , x_return_status       OUT NOCOPY     VARCHAR2
    , x_msg_count           OUT NOCOPY     NUMBER
    , x_msg_data            OUT NOCOPY     VARCHAR2
)IS
BEGIN
   BSC_ANALYSIS_OPTION_PVT.Set_Default_Analysis_Option
   (
      p_commit              =>  p_commit
    , p_obj_id              =>  p_obj_id
    , p_Anal_Opt_Comb_Tbl   =>  p_Anal_Opt_Comb_Tbl
    , p_Anal_Grp_Id         =>  p_Anal_Grp_Id
    , x_return_status       =>  x_return_status
    , x_msg_count           =>  x_msg_count
    , x_msg_data            =>  x_msg_data
   );


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
       RAISE;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Set_Default_Analysis_Option ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Set_Default_Analysis_Option ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
      RAISE;
END Set_Default_Analysis_Option;

/***********************************************************
 Name       : Default_Anal_Option_Changed
 Description: This Function compares the old default analysis option combination
              with the one selected by the user.If it has changed then it return
              True otherwise it returns false.
 Input      : p_Anal_Num_Tbl  --> New analysis option combination table.
              p_Old_Anal_Num_Tbl --> Old Analysis option combination table.
 Output     : True --> means changed.
              False --> means not changed.
 Created BY : ashankar For bug 4220400
/**********************************************************/
FUNCTION Default_Anal_Option_Changed
(
   p_Anal_Num_Tbl           IN   BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
 , p_Old_Anal_Num_Tbl       IN   BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
)RETURN BOOLEAN IS
  l_return     BOOLEAN;
  l_count      NUMBER;
BEGIN
  l_return := FALSE;
  IF((p_Anal_Num_Tbl IS NOT NULL) AND (p_Old_Anal_Num_Tbl IS NOT NULL))THEN
     l_count := p_Anal_Num_Tbl.COUNT -1;
     FOR counter IN 0..l_count LOOP
       IF(p_Anal_Num_Tbl(counter)<>p_Old_Anal_Num_Tbl(counter))THEN
         l_return := TRUE;
         EXIT;
       END IF;
     END LOOP;
  END IF;

  RETURN l_return;
END Default_Anal_Option_Changed;



end BSC_ANALYSIS_OPTION_PUB;

/
