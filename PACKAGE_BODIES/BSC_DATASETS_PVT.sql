--------------------------------------------------------
--  DDL for Package Body BSC_DATASETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DATASETS_PVT" as
/* $Header: BSCVDTSB.pls 120.9 2007/06/28 06:53:54 ashankar ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVDTSB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 10, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |          Private Body version.                                                       |
 |          This package creates a BSC Dataset.                                         |
 |                                                                                      |
 | History:                                                                             |
 | 04-APR-03    Ashankar    fix bug # 2883880                                           |
 | 23-APR-03    mdamle      PMD - Measure Definer Support                               |
 |                      Removed all rollbacks - all rollbacks will be taken             |
 |              care of on the java side by BC4J whenever an error is                   |
 |              raised.                                                                 |
 | 07-Jul-03    mdamle      PMD - Added Y Axis Title                                    |
 | 03-Sep-03    adrao       Fixed Bug #3123509 (Update_Dataset)                         |
 | 05-Sep-03    mdamle      Fixed Bug #3123558 Added check for duplicate measure_col    |
 | 07-Sep-03    arhegde     bug# 3123901 Propogate error to outer layers.               |
 | 25-SEP-03    mdamle      Bug#3160325 - Sync up measures for all installed            |
 |                          languages                                                   |
 | 29-SEP-03    adrao       Bug#3160325 - Sync up measures for all installed            |
 |                          source languages                                            |
 | 25-SEP-03    mdamle      Bug#3170184 - Check for duplicate source column by source   |
 |                          type                                                        |
 | 28-OCT-03    PAJOHRI     Bug #3184408, removed TRIM from Create_Measures &           |
 |                                        Update_Measures API                           |
 | 27-NOV-03    adrao       Bug#3238554  - Modifed procedure Update_Measure and added   |
 |                                         condition to perform incremental changes     |
 | 02-DEC-03    ashankar    Bug#3291278 - Modifed procedure Update_Measure and created  |
 |                          cursor to get the value of the Type column from bsc_sys_meas|
 |                          ures for the measure.                                       |
 | 11-DEC-03    PAJOHRI     Bug #3309050                                                |
 | 06-JAN-04    PAJOHRI     Bug #3349897, modified procedure Update_Measures to fix     |
 |                                        record l_Dataset_Rec.Bsc_Measure_Color_Formula|
 |                                        to flag prototype_flag = 4 if value is changed|
 | 24-FEB-04    KYADAMAK    Bug #3439942  space not allowed for PMF Measures            |
 | 02-MAR-04    ANKGOEL     Bug #3464470  Forward port fix of bug#3450505       |
 | 24-MAR-04    ADRAO       Bug #3528425  Perform structural change, when Data Group is |
 |                                        changed for any measure                       |
 | 24-MAY-04    ADRAO       Bug #3628113  Removed Measure Columns based on MEASURE_ID2  |
 |                                        in Delete_Measure API                         |
 | 27-JUL-04    sawu        Added logic to set WHO columns in create/update api         |
 | 28-JUL-04    adrao       Bug#3781176  Added logic in Delete_Measures(), whenever     |
 |                                       the same source column is referenced in both   |
 |                                       BSC_SYS_DATASETS_B.MEASURE_ID1/MEASURE_ID2     |
 | 17-AUG-04    visuri      Bug#3681116   Added logic in Update_Dataset() API to ensure |
 |                                       that numeric format change of any measure also |
 |                                       updates the default format of indicators for   |
 |                                       which that measure is a default measure.       |
 | 24-AUG-2004  ashankar    Bug#3844190  Creating unique measure col across the system. |
 | 20-Dec-2004  sawu        Bug#4045278: updated update_measure and update_dataset to   |
 |                                       populate last_update_date from record structure|
 |                                       Updated create_measure and create_dataset to   |
 |                                       populate creation_date and LUD also.           |
 | 20-Sep-2005  akoduri     Bug#4613172: CDS type measures should not get populated into|
 |                                       bsc_db_measure_cols_tl                         |
 | 05-JAN-06    ppandey     Enh#4860106 Handled structureal and non-structural          |
 |                                        formula change                                |
 | 13-JAN-06    ppandey     Enh#4860106 Reverting due to open Bug #4941403 from backend.|
 | 24-JAN-06    ankgoel     Bug#4954663 Show Info text for AG to PL/SQL or VB conversion|
 | 04-AUG-06    akoduri     Enh#5416542 Cause  Effect Phase2                            |
 | 14-Feb-07    rkumar      Bug#5877454 Changed l_indicator length to 32000             |
 | 24-MAY-07    ppandey     Bug#5954147 Changing goal type will reset thresholds, as    |
 |                                      thresholds are at Kpi level with color enh.     |
 | 27-JUN-07    ashankar    Bug#6134461 Filtered out P&L objectives when GOAL type is changed |
 +======================================================================================+
*/
G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_DATASETS_PVT';
g_db_object                             varchar2(30) := null;
TYPE string_tabletype IS
        TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

--:     This procedure creates a BSC measure.  This is the entry point for the
--:     Data Set API.
--:     This procedure is part of the Data Set API.

procedure Create_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count                 number;
l_count_mescol          number;
l_color_formula         varchar2(200);
l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

begin
  l_Dataset_Rec := p_Dataset_Rec;

  -- Set who columns
  if l_Dataset_Rec.Bsc_Measure_Created_By is null then
    l_Dataset_Rec.Bsc_Measure_Created_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Last_Update_By is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Last_Update_Login is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Creation_Date is null then
    l_Dataset_Rec.Bsc_Measure_Creation_Date := sysdate;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Last_Update_Date is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_Date := sysdate;
  end if;

  -- Verify that measure id does not exist.
  select count(1)
    into l_count
    from BSC_SYS_MEASURES
   where measure_id = l_Dataset_Rec.Bsc_Measure_Id;

  -- If measure id does not exist then go ahead and create it, if it does  then raise
  -- an error.
  if l_count = 0 then

    g_db_object := 'BSC_SYS_MEASURES';

     -- Check if measure_col already exists
     select count(1) into l_count_mescol
     from BSC_DB_MEASURE_COLS_VL
     where upper(measure_col) = upper(l_Dataset_Rec.Bsc_Measure_Col);
     if (l_count_mescol > 0) then
        FND_MESSAGE.SET_NAME('BSC','BSC_MEASURE_SOURCE_NAME');
        FND_MESSAGE.SET_TOKEN('MEASURE', p_Dataset_Rec.Bsc_Dataset_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     end if;


    -- Insert pertaining values into table bsc_sys_measures.
    -- Reminder:  Some values are hard coded. Find source.
    insert into BSC_SYS_MEASURES( measure_id
                                 ,measure_col
                                 ,operation
                                 ,type
                                 ,min_actual_value
                                 ,max_actual_value
                                 ,min_budget_value
                                 ,max_budget_value
                                 ,random_style
                                 ,edw_flag
                                 ,edw_fact_id
                                 ,edw_meas_id
                                 ,short_name
                                 ,source
                                 ,s_color_formula
                                 ,created_by             -- PMD
                                 ,creation_date          -- PMD
                                 ,last_updated_by        -- PMD
                                 ,last_update_date       -- PMD
                                 ,last_update_login)     -- PMD
                          values( l_Dataset_Rec.Bsc_Measure_Id
                                 ,l_Dataset_Rec.Bsc_Measure_Col
                                 ,l_Dataset_Rec.Bsc_Measure_Operation
                                 ,l_Dataset_Rec.Bsc_Meas_Type
                                 ,l_Dataset_Rec.Bsc_Measure_Min_Act_Value
                                 ,l_Dataset_Rec.Bsc_Measure_Max_Act_Value
                                 ,l_Dataset_Rec.Bsc_Measure_Min_Bud_Value
                                 ,l_Dataset_Rec.Bsc_Measure_Max_Bud_Value
                                 ,l_Dataset_Rec.Bsc_Measure_Random_Style
                                 ,0
                                 ,null
                                 ,null
                                 ,l_Dataset_Rec.Bsc_Measure_Short_Name
                                 ,l_Dataset_Rec.Bsc_Source
                                 ,l_Dataset_Rec.Bsc_Measure_Color_Formula
                                 ,l_Dataset_Rec.Bsc_Measure_Created_By         -- PMD
                                 ,l_Dataset_Rec.Bsc_Measure_Creation_Date      -- PMD
                                 ,l_Dataset_Rec.Bsc_Measure_Last_Update_By     -- PMD
                                 ,l_Dataset_Rec.Bsc_Measure_Last_Update_Date   -- PMD
                                 ,l_Dataset_Rec.Bsc_Measure_Last_Update_Login);-- PMD

    -- Insert pertaining values into table bsc_db_measure_cols_tl.
/*
    insert into BSC_DB_MEASURE_COLS_TL( measure_col
                                       ,language
                                       ,source_lang
                                       ,help
                                       ,measure_group_id
                                       ,projection_id
                                       ,measure_type)
                                values( p_Dataset_Rec.Bsc_Measure_Col
                                       ,p_Dataset_Rec.Bsc_Language
                                       ,p_Dataset_Rec.Bsc_Source_Language
                                       ,p_Dataset_Rec.Bsc_Measure_Help
                                       ,p_Dataset_Rec.Bsc_Measure_Group_Id
                                       ,p_Dataset_Rec.Bsc_Measure_Projection_Id
                                       ,p_Dataset_Rec.Bsc_Measure_Type);
*/

    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;

  else
    FND_MESSAGE.SET_NAME('BSC','BSC_MEAS_ID_EXISTS');
    FND_MESSAGE.SET_TOKEN('BSC_MEAS', l_Dataset_Rec.Bsc_Measure_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    FND_MSG_PUB.Initialize;
    if (SQLCODE = -01400) then
      FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
      FND_MESSAGE.SET_TOKEN('BSC_OBJECT', g_db_object);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

    raise;
end Create_Measures;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY     BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  g_db_object := 'Retrieve_Measures';
 -- added measure_type for Bug #3238554
 -- added NVL, since measure_type is a nullable column.
 -- added Bsc_Measure_Group_id for Bug#3528425
  select distinct a.measure_col
                 ,a.operation
                 ,a.type
                 ,a.min_actual_value
                 ,a.max_actual_value
                 ,a.min_budget_value
                 ,a.max_budget_value
                 ,a.random_style
                 ,a.s_color_formula
     ,a.source
                 ,a.created_by             -- PMD
                 ,a.creation_date          -- PMD
                 ,a.last_updated_by        -- PMD
                 ,a.last_update_date       -- PMD
                 ,a.last_update_login      -- PMD
                 ,b.projection_id
                 ,nvl(b.measure_type, 0)
                 ,nvl(b.measure_group_id, -1)
            into x_Dataset_Rec.Bsc_Measure_Col
                ,x_Dataset_Rec.Bsc_Measure_Operation
                ,x_Dataset_Rec.Bsc_Meas_Type
                ,x_Dataset_Rec.Bsc_Measure_Min_Act_Value
                ,x_Dataset_Rec.Bsc_Measure_Max_Act_Value
                ,x_Dataset_Rec.Bsc_Measure_Min_Bud_Value
                ,x_Dataset_Rec.Bsc_Measure_Max_Bud_Value
                ,x_Dataset_Rec.Bsc_Measure_Random_Style
                ,x_Dataset_Rec.Bsc_measure_color_formula
                ,x_Dataset_Rec.Bsc_Source
                ,x_Dataset_Rec.Bsc_Measure_Created_By           -- PMD
                ,x_Dataset_Rec.Bsc_Measure_Creation_Date        -- PMD
                ,x_Dataset_Rec.Bsc_Measure_Last_Update_By       -- PMD
                ,x_Dataset_Rec.Bsc_Measure_Last_Update_Date     -- PMD
                ,x_Dataset_Rec.Bsc_Measure_Last_Update_Login    -- PMD
                ,x_Dataset_Rec.Bsc_Measure_Projection_Id
                ,x_Dataset_Rec.Bsc_Measure_Type
                ,x_Dataset_Rec.Bsc_Measure_Group_Id
            from  BSC_SYS_MEASURES a
                 ,bsc_db_measure_cols_vl b
           where a.measure_id = p_Dataset_Rec.Bsc_Measure_Id
             and a.measure_col = b.Measure_Col(+);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    FND_MSG_PUB.Initialize;
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
    FND_MESSAGE.SET_TOKEN('BSC_OBJECT', g_db_object);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Retrieve_Measures;

/************************************************************************************
************************************************************************************/
FUNCTION is_Number (
   char_in VARCHAR2
) RETURN BOOLEAN
 IS
 n  NUMBER;
 BEGIN
   n := TO_NUMBER(char_in);
   RETURN TRUE;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN FALSE;
END is_number;

FUNCTION get_Formula_Table (
  p_Formula    IN VARCHAR2
 ,x_Count      OUT NOCOPY NUMBER
) RETURN string_tabletype
IS
  l_Formula          VARCHAR2(300);
  formula_Table      string_tabletype;
  l_Formula_entity   VARCHAR2(300);
  l_Count            NUMBER;
  l_already_Exists   BOOLEAN;
  l_Is_Number        BOOLEAN;
BEGIN
  l_Formula := REPLACE (p_Formula, ' ');
  l_Formula := REPLACE (l_Formula, '(',',');
  l_Formula := REPLACE (l_Formula, ')',',');
  l_Formula := REPLACE (l_Formula, '+',',');
  l_Formula := REPLACE (l_Formula, '-',',');
  l_Formula := REPLACE (l_Formula, '*',',');
  l_Formula := REPLACE (l_Formula, '/',',');
  l_Count := 0;
  WHILE (bsc_utility.Is_More(l_Formula, l_Formula_entity)) LOOP
    l_already_Exists := FALSE;
    l_Is_Number := is_Number(l_Formula_entity);
    IF (NOT l_Is_Number) THEN
      FOR counter IN 1..l_Count LOOP
        IF (l_Formula_entity = formula_Table (counter)) THEN
          l_already_Exists := TRUE;
        END IF;
      END LOOP;
    END IF;
    IF (NOT l_Is_Number AND NOT l_already_Exists) THEN
      l_Count := l_Count + 1;
      formula_Table (l_Count) := l_Formula_entity;
    END IF;
  END LOOP;
  x_Count := l_Count;
  RETURN formula_Table;
END get_Formula_Table;


FUNCTION Is_Structure_change (
  p_old_formula         IN     varchar2
 ,p_new_formula         IN     varchar2
 ) RETURN BOOLEAN
 IS
  l_Structure_Change     BOOLEAN;
  l_Old_Formula          VARCHAR2(4000);
  l_New_Formula          VARCHAR2(4000);
  l_New_Formula_Table    string_tabletype;
  l_Old_Formula_Table    string_tabletype;
  l_Old_Measure_Count    NUMBER;
  l_New_Measure_Count    NUMBER;
  l_Found                BOOLEAN;
  l_Entity               VARCHAR2(300);
 BEGIN
    l_Structure_Change := FALSE;

    --Following code added for temporary change, it needs to be removed for Bug #4860106
    IF (p_old_formula <> p_new_formula) THEN
      l_Structure_Change := TRUE;
    END IF;

    -- Actual fix for Bug #Bug #4860106 (Pending for Bug #4941403)- Don't remove it.- ppandey
    /*IF (BSC_BIS_MEASURE_PUB.Is_Formula_Type(p_old_formula)=FND_API.G_TRUE AND BSC_BIS_MEASURE_PUB.Is_Formula_Type(p_new_formula)=FND_API.G_TRUE) THEN
      l_Old_Formula_Table := get_Formula_Table(p_old_formula, l_Old_Measure_Count);
      l_New_Formula_Table := get_Formula_Table(p_new_formula, l_New_Measure_Count);
      IF (l_Old_Measure_Count <> l_New_Measure_Count) THEN
        l_Structure_Change := TRUE;
      ELSE
        FOR counter1 IN 1..l_Old_Measure_Count LOOP
          l_Found := FALSE;
          l_Entity := l_Old_Formula_Table(counter1);
          FOR counter2 IN 1..l_New_Measure_Count LOOP
            IF (l_Entity = l_New_Formula_Table(counter2)) THEN
              l_Found := TRUE;
            END IF;
          END LOOP;
          IF (NOT l_Found) THEN
            l_Structure_Change := TRUE;
          END IF;
        END LOOP;
      END IF;
    ELSE
      l_Structure_Change := TRUE;
    END IF;*/

    RETURN l_Structure_Change;
END Is_Structure_change;


/************************************************************************************
************************************************************************************/

procedure Update_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dataset_Rec               BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

l_count                 number;
l_color_formula         varchar2(200);
l_count_mescol          number;
l_kpi_flag              number := -1;
l_indicator_table       BSC_NUM_LIST;
l_current_formula       VARCHAR2(32000);
l_prototype_flag        BSC_NUM_LIST;

CURSOR indicators_cursor is
SELECT am.indicator, kpi.prototype_flag
FROM   bsc_kpi_analysis_measures_b am,
       bsc_kpis_b kpi
WHERE  kpi.indicator = am.indicator
AND    dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

CURSOR c_measures_col IS
SELECT Type
FROM   BSC_SYS_MEASURES
WHERE  MEASURE_ID = p_Dataset_Rec.Bsc_Measure_Id;

begin

  -- Check that valid measure id was entered.
  if p_Dataset_Rec.Bsc_Measure_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_MEASURES'
                                                       ,'measure_id'
                                                       ,p_Dataset_Rec.Bsc_Measure_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MEAS_ID');
      FND_MESSAGE.SET_TOKEN('BSC_MEAS', p_Dataset_Rec.Bsc_Measure_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_MEAS_ID_ENTERED');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  SELECT MEASURE_COL
  INTO   l_current_formula
  FROM   BSC_SYS_MEASURES
  WHERE  MEASURE_ID = p_Dataset_Rec.Bsc_Measure_Id;

  IF(l_current_formula <> p_Dataset_Rec.Bsc_Measure_Col) THEN
     select count(1) into l_count_mescol
     from BSC_DB_MEASURE_COLS_VL
     where upper(measure_col) = upper(p_Dataset_Rec.Bsc_Measure_Col);
     if (l_count_mescol > 0) then
        FND_MESSAGE.SET_NAME('BSC','BSC_MEASURE_SOURCE_NAME');
        FND_MESSAGE.SET_TOKEN('MEASURE', p_Dataset_Rec.Bsc_Dataset_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     end if;
  END IF;


  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Measures( p_commit
                    ,p_Dataset_Rec
                    ,l_Dataset_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);

  -- update LOCAL language ,source language  and level Id values with PASSED values.
  l_Dataset_Rec.Bsc_Language := p_Dataset_Rec.Bsc_Language;
  l_Dataset_Rec.Bsc_Source_Language := p_Dataset_Rec.Bsc_Source_Language;
  l_Dataset_Rec.Bsc_Measure_Id := p_Dataset_Rec.Bsc_Measure_Id;

  --sawu: update WHO column info with PASSED values
  l_Dataset_Rec.Bsc_Measure_Last_Update_By := p_Dataset_Rec.Bsc_Measure_Last_Update_By;
  l_Dataset_Rec.Bsc_Measure_Last_Update_Date := p_Dataset_Rec.Bsc_Measure_Last_Update_Date;
  l_Dataset_Rec.Bsc_Measure_Last_Update_Login := p_Dataset_Rec.Bsc_Measure_Last_Update_Login;

  -- mdamle 04/23/2003 - PMD - Measure Definer - Update flag in KPI for specific updates in the dataset
  -- adrao added check for Bsc_Measure_Type for Incremental Changes to all indicators.
  --       associated with the current measure, when type is changed from Activity -> Balance
  --       and vice-versa Bug 3238554

  -- adrao added Bsc_Measure_Group_Id to make Structural Changes, when Measure Group is changed.
  -- for Bug#3528425

  -- ppandey -Set prototype flag based on formula change or column group change
  IF (p_Dataset_Rec.Bsc_Measure_Group_Id <> l_Dataset_Rec.Bsc_Measure_Group_Id) THEN
    l_kpi_flag := BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure;
  ELSIF (p_Dataset_Rec.Bsc_Measure_Col <> l_Dataset_Rec.Bsc_Measure_Col) THEN
    IF (Is_Structure_change(p_Dataset_Rec.Bsc_Measure_Col, l_Dataset_Rec.Bsc_Measure_Col)) THEN
      l_kpi_flag := BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure;
    ELSE
      l_kpi_flag := BSC_DESIGNER_PVT.G_ActionFlag.GAA_Update;
    END IF;
  END IF;

  IF (l_kpi_flag <> -1) THEN
    open indicators_cursor;
    fetch indicators_cursor bulk collect into l_indicator_table, l_prototype_flag;
    if indicators_cursor%ISOPEN THEN
        CLOSE indicators_cursor;
    end if;
    for i in 1..l_indicator_table.count loop
      BSC_DESIGNER_PVT.ActionFlag_Change(l_indicator_table(i), l_kpi_flag);
    end loop;

  ELSE
      if (p_Dataset_Rec.Bsc_Measure_Operation <> l_Dataset_Rec.Bsc_Measure_Operation or
           p_Dataset_Rec.Bsc_Measure_color_formula <> l_Dataset_Rec.Bsc_Measure_color_formula or
            p_Dataset_Rec.Bsc_Dataset_Operation <> l_Dataset_Rec.Bsc_Dataset_operation or
             p_Dataset_Rec.Bsc_Measure_Projection_Id <> l_Dataset_Rec.Bsc_Measure_Projection_Id or
              p_Dataset_Rec.Bsc_Measure_Type <> l_Dataset_Rec.Bsc_Measure_Type) then
              l_kpi_flag := BSC_DESIGNER_PVT.G_ActionFlag.GAA_Update;

              open indicators_cursor;
              fetch indicators_cursor bulk collect into l_indicator_table, l_prototype_flag;
              if indicators_cursor%ISOPEN THEN
                  CLOSE indicators_cursor;
              end if;
              for i in 1..l_indicator_table.count loop
                  BSC_DESIGNER_PVT.ActionFlag_Change(l_indicator_table(i), l_kpi_flag);
              end loop;
      end if;
  END IF;

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  -- mdamle 03/12/2003 - PMD - Measure Definer
  if p_Dataset_Rec.Bsc_Measure_Col is not null then
    l_Dataset_Rec.Bsc_Measure_Col := p_Dataset_Rec.Bsc_Measure_Col;
  end if;

  IF (p_Dataset_Rec.Bsc_Source = BSC_BIS_MEASURE_PUB.c_PMF AND l_Dataset_Rec.Bsc_Source = BSC_BIS_MEASURE_PUB.c_BSC) THEN
    l_Dataset_Rec.Bsc_Source := p_Dataset_Rec.Bsc_Source;
  END IF;

  if p_Dataset_Rec.Bsc_Measure_Short_Name is not null then
    l_Dataset_Rec.Bsc_Measure_Short_Name := p_Dataset_Rec.Bsc_Measure_Short_Name;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Operation is not null then
    l_Dataset_Rec.Bsc_Measure_Operation := p_Dataset_Rec.Bsc_Measure_Operation;
  end if;
  if p_Dataset_Rec.Bsc_Meas_Type is not null then
    l_Dataset_Rec.Bsc_Meas_Type := p_Dataset_Rec.Bsc_Meas_Type;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Min_Act_Value is not null then
    l_Dataset_Rec.Bsc_Measure_Min_Act_Value := p_Dataset_Rec.Bsc_Measure_Min_Act_Value;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Max_Act_Value is not null then
    l_Dataset_Rec.Bsc_Measure_Max_Act_Value := p_Dataset_Rec.Bsc_Measure_Max_Act_Value;
  end if;
  if p_Dataset_Rec.Bsc_Measure_color_formula is not null then
    l_Dataset_Rec.Bsc_Measure_color_formula := p_Dataset_Rec.Bsc_Measure_color_formula;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Min_Bud_Value is not null then
    l_Dataset_Rec.Bsc_Measure_Min_Bud_Value := p_Dataset_Rec.Bsc_Measure_Min_Bud_Value;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Max_Bud_Value is not null then
    l_Dataset_Rec.Bsc_Measure_Max_Bud_Value := p_Dataset_Rec.Bsc_Measure_Max_Bud_Value;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Random_Style is not null then
    l_Dataset_Rec.Bsc_Measure_Random_Style := p_Dataset_Rec.Bsc_Measure_Random_Style;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Help is not null then
    l_Dataset_Rec.Bsc_Measure_Help := p_Dataset_Rec.Bsc_Measure_Help;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Group_Id is not null then
    l_Dataset_Rec.Bsc_Measure_Group_Id := p_Dataset_Rec.Bsc_Measure_Group_Id;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Projection_Id is not null then
    l_Dataset_Rec.Bsc_Measure_Projection_Id := p_Dataset_Rec.Bsc_Measure_Projection_Id;
  end if;

  if p_Dataset_Rec.Bsc_Measure_Last_Update_By is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_By := fnd_global.USER_ID;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Last_Update_Date is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_Date := SYSDATE;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Last_Update_Login is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;
  -- PMD

/* IF(c_measures_col%ISOPEN) THEN
  CLOSE c_measures_col;
 END IF;

 OPEN c_measures_col;
 FETCH c_measures_col INTO  l_Dataset_Rec.Bsc_Measure_Type;
 IF(c_measures_col%NOTFOUND) THEN
    l_Dataset_Rec.Bsc_Measure_Type := 0;
 END IF;
 CLOSE c_measures_col;*/


  UPDATE BSC_SYS_MEASURES
     -- mdamle 03/12/2003 - PMD - Measure Definer
     -- Changed set measure_col = l_Dataset_Rec.Bsc_Measure_Short_Name
     SET measure_col        = l_Dataset_Rec.Bsc_Measure_Col
        ,operation          = l_Dataset_Rec.Bsc_Measure_Operation
        ,type               = l_Dataset_Rec.Bsc_Meas_Type
        ,min_actual_value   = l_Dataset_Rec.Bsc_Measure_Min_Act_Value
        ,max_actual_value   = l_Dataset_Rec.Bsc_Measure_Max_Act_Value
        ,min_budget_value   = l_Dataset_Rec.Bsc_Measure_Min_Bud_Value
        ,max_budget_value   = l_Dataset_Rec.Bsc_Measure_Max_Bud_Value
        ,random_style       = l_Dataset_Rec.Bsc_Measure_Random_Style
        ,s_color_formula    = l_Dataset_Rec.Bsc_Measure_color_formula
  ,source             = l_Dataset_Rec.Bsc_Source
        ,last_updated_by    = l_Dataset_Rec.Bsc_Measure_Last_Update_By       -- PMD
        ,last_update_date   = l_Dataset_Rec.Bsc_Measure_Last_Update_Date    -- PMD
        ,last_update_login  = l_Dataset_Rec.Bsc_Measure_Last_Update_Login   -- PMD
   WHERE measure_id         = l_Dataset_Rec.Bsc_Measure_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF(c_measures_col%ISOPEN) THEN
     CLOSE c_measures_col;
    END IF;
    IF indicators_cursor%ISOPEN THEN
      CLOSE indicators_cursor;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF(c_measures_col%ISOPEN) THEN
     CLOSE c_measures_col;
    END IF;
    IF indicators_cursor%ISOPEN THEN
      CLOSE indicators_cursor;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    IF(c_measures_col%ISOPEN) THEN
     CLOSE c_measures_col;
    END IF;
    IF indicators_cursor%ISOPEN THEN
      CLOSE indicators_cursor;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    IF(c_measures_col%ISOPEN) THEN
     CLOSE c_measures_col;
    END IF;
    IF indicators_cursor%ISOPEN THEN
      CLOSE indicators_cursor;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RAISE;

end Update_Measures;

/************************************************************************************
************************************************************************************/

PROCEDURE Delete_Measures(
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS

l_Count                     NUMBER;
l_Measure_Col               VARCHAR2(320);

BEGIN

  -- Check that measure is valid
  IF p_Dataset_Rec.Bsc_Measure_Id  IS NOT NULL THEN

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_MEASURES
    WHERE  MEASURE_ID = p_Dataset_Rec.Bsc_Measure_Id;

    IF l_count = 0 THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MEAS_ID');
      FND_MESSAGE.SET_TOKEN('BSC_MEAS', p_Dataset_Rec.Bsc_Measure_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- If the Meeasure_Id1 is not null (A+B Formula)
    IF p_Dataset_Rec.Bsc_Measure_Id2 IS NOT NULL THEN
        SELECT COUNT(1) INTO l_Count
        FROM   BSC_SYS_MEASURES
        WHERE  MEASURE_ID = p_Dataset_Rec.Bsc_Measure_Id2;

        IF l_count = 0 THEN
          FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MEAS_ID');
          FND_MESSAGE.SET_TOKEN('BSC_MEAS', p_Dataset_Rec.Bsc_Measure_Id2);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- Only delete base measure if there are no datasets referencing it.
    -- Delete the MEASURE_ID1 Measure
    SELECT COUNT(DATASET_ID)
    INTO   l_Count
    FROM   BSC_SYS_DATASETS_B
    WHERE  MEASURE_ID1 = p_Dataset_Rec.Bsc_Measure_Id
       OR  MEASURE_ID2 = p_Dataset_Rec.Bsc_Measure_Id;

    IF l_Count = 0 THEN
      -- mdamle 04/23/2003 - PMD - Measure Definer - Delete db column if not being used by any other measure
      SELECT MEASURE_COL INTO l_Measure_Col
      FROM   BSC_SYS_MEASURES
      WHERE  MEASURE_ID = p_Dataset_Rec.Bsc_Measure_Id;

      DELETE FROM BSC_SYS_MEASURES
      WHERE  MEASURE_ID = p_Dataset_Rec.Bsc_Measure_Id;

      -- mdamle 04/23/2003 - PMD - Measure Definer - Delete db column if not being used by any other measure
      -- Delete column if no other dataset is using it.
      SELECT COUNT(1) INTO l_count
      FROM   BSC_SYS_MEASURES
      WHERE  SOURCE = BSC_BIS_MEASURE_PUB.c_BSC
      AND    MEASURE_COL LIKE '%' || l_Measure_Col || '%';

      IF l_Count = 0 THEN
        SELECT COUNT(1) INTO l_count
        FROM   BSC_DB_MEASURE_COLS_VL
        WHERE  MEASURE_COL = l_Measure_Col;
        IF l_Count > 0 THEN
            BSC_DB_MEASURE_COLS_PKG.delete_row(l_Measure_Col);
        END IF;
      END IF;

      IF (p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
      END IF;

     -- mdamle 04/23/2003 - PMD - Measure Definer - No need to raise error, just don't delete the from bsc_sys_measures
    END IF;

    -- Delete the Formulae based MEASURE_ID2 if not used in any
    -- Dataset based formula.

    IF p_Dataset_Rec.Bsc_Measure_Id2 IS NOT NULL THEN
        SELECT COUNT(DATASET_ID)
        INTO   l_Count
        FROM   BSC_SYS_DATASETS_B
        WHERE  MEASURE_ID1 = p_Dataset_Rec.Bsc_Measure_Id2
           OR  MEASURE_ID2 = p_Dataset_Rec.Bsc_Measure_Id2;

        -- Bug#3781176
        -- We can have both Meaaure_Id1 and Measure_Id2 same, in that case measure_id1
        -- would have been delete already and the following code can give no-data-found issue
        IF ((l_Count = 0) AND (p_Dataset_Rec.Bsc_Measure_Id <> p_Dataset_Rec.Bsc_Measure_Id2)) THEN
          SELECT MEASURE_COL INTO l_Measure_Col
          FROM   BSC_SYS_MEASURES
          WHERE  MEASURE_ID = p_Dataset_Rec.Bsc_Measure_Id2;

          DELETE FROM BSC_SYS_MEASURES
          WHERE  MEASURE_ID = p_Dataset_Rec.Bsc_Measure_Id2;

          -- Delete column if no other dataset is using it.
          SELECT COUNT(1) INTO l_Count
          FROM   BSC_SYS_MEASURES
          WHERE  SOURCE = BSC_BIS_MEASURE_PUB.c_BSC
          AND    MEASURE_COL LIKE '%' || l_Measure_Col || '%';

          IF l_Count = 0 THEN
            SELECT COUNT(1) INTO l_count
            FROM   BSC_DB_MEASURE_COLS_VL
            WHERE  MEASURE_COL = l_Measure_Col;
            IF l_Count > 0 THEN
                BSC_DB_MEASURE_COLS_PKG.delete_row(l_Measure_Col);
            END IF;
          END IF;

          IF (p_Commit = FND_API.G_TRUE) THEN
            COMMIT;
          END IF;
        END IF;
    END IF;

  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_MEAS_ID_ENTERED');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RAISE;

END Delete_Measures;


/************************************************************************************
************************************************************************************/
/*

procedure Create_Formats(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Create_Formats;
*/

/************************************************************************************
************************************************************************************/
/*

procedure Delete_Formats(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Delete_Formats;
*/

/************************************************************************************
************************************************************************************/

--:     This procedure creates a dataset for the given measure.
--:     This procedure is part of the Data Set API.

procedure Create_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;
l_Dataset_Rec       BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

begin
  l_Dataset_Rec := p_Dataset_Rec;

  -- Set who columns accordingly
  if l_Dataset_Rec.Bsc_Dataset_Created_By is null then
    l_Dataset_Rec.Bsc_Dataset_Created_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Last_Update_By is null then
    l_Dataset_Rec.Bsc_Dataset_Last_Update_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Last_Update_Login is null then
    l_Dataset_Rec.Bsc_Dataset_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Creation_Date is null then
    l_Dataset_Rec.Bsc_Dataset_Creation_Date := sysdate;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Last_Update_Date is null then
    l_Dataset_Rec.Bsc_Dataset_Last_Update_Date := sysdate;
  end if;

  -- Verify that dataset does not exist.
  select count(1)
    into l_count
    from BSC_SYS_DATASETS_B
   where dataset_id = l_Dataset_Rec.Bsc_Dataset_Id;

  -- If dataset does not exist then create it, else raise an error.

  if l_count = 0 then

  -- Insert the pertaining values into table bsc_sys_datasets_b.
    insert into BSC_SYS_DATASETS_B( dataset_id
                                   ,measure_id1
                                   ,operation
                                   ,measure_id2
                                   ,format_id
                                   ,color_method
                                   ,projection_flag
                                   ,edw_flag
                                   ,autoscale_flag
                                   ,source
                                   ,created_by             -- PMD
                                   ,creation_date          -- PMD
                                   ,last_updated_by        -- PMD
                                   ,last_update_date       -- PMD
                                   ,last_update_login)     -- PMD
                            values( l_Dataset_Rec.Bsc_Dataset_Id
                                   ,l_Dataset_Rec.Bsc_Measure_Id
                   -- mdamle 03/12/2003 - PMD - Measure Definer
                   -- Changed from Measure_operation to Dataset_Operation
                                   ,l_Dataset_Rec.Bsc_Dataset_operation
                                   ,l_Dataset_Rec.Bsc_Measure_Id2
                                   ,l_Dataset_Rec.Bsc_Dataset_Format_Id
                                   ,l_Dataset_Rec.Bsc_Dataset_Color_Method
                                   ,l_Dataset_Rec.Bsc_Dataset_Projection_Flag
                                   ,0
                                   ,l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag
                                   ,l_Dataset_Rec.Bsc_Source
                                   ,l_Dataset_Rec.Bsc_Dataset_Created_By         -- PMD
                                   ,l_Dataset_Rec.Bsc_Dataset_Creation_Date      -- PMD
                                   ,l_Dataset_Rec.Bsc_Dataset_Last_Update_By     -- PMD
                                   ,l_Dataset_Rec.Bsc_Dataset_Last_Update_Date   -- PMD
                                   ,l_Dataset_Rec.Bsc_Dataset_Last_Update_Login);-- PMD


    -- Insert the pertaining values into table bsc_sys_datasets_tl.
    insert into BSC_SYS_DATASETS_TL( dataset_id
                                    ,language
                                    ,source_lang
                                    ,name
                                    ,help
                                    ,y_axis_title)
                             select  l_Dataset_Rec.Bsc_Dataset_Id
                                    ,L.LANGUAGE_CODE
                                    ,userenv('LANG')
                                    ,l_Dataset_Rec.Bsc_Dataset_Name
                                    ,l_Dataset_Rec.Bsc_Dataset_Help
                                    ,l_Dataset_Rec.Bsc_y_axis_title
                                from FND_LANGUAGES L
                               where L.INSTALLED_FLAG in ('I', 'B')
                                 and not exists
                                     (select NULL
                                        from BSC_SYS_DATASETS_TL T
                                       where T.dataset_id = l_Dataset_Rec.Bsc_Dataset_Id
                                         and T.LANGUAGE = L.LANGUAGE_CODE);

    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;

  else
    FND_MESSAGE.SET_NAME('BSC','BSC_DSET_ID_EXISTS');
    FND_MESSAGE.SET_TOKEN('BSC_DATASET', l_Dataset_Rec.Bsc_Dataset_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Create_Dataset;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY     BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  select distinct measure_id1
                 ,operation
                 ,measure_id2
                 ,format_id
                 ,color_method
                 ,projection_flag
                 ,autoscale_flag
                 ,name
                 ,help
                 ,y_axis_title
     ,source
                 ,created_by             -- PMD
                 ,creation_date          -- PMD
                 ,last_updated_by        -- PMD
                 ,last_update_date       -- PMD
                 ,last_update_login      -- PMD
            into  x_Dataset_Rec.Bsc_Measure_Id
         -- mdamle 03/12/2003 - PMD - Measure Definer
                 -- Changed from Measure_operation to Dataset_Operation
                 ,x_Dataset_Rec.Bsc_Dataset_Operation
                 ,x_Dataset_Rec.Bsc_Measure_Id2
                 ,x_Dataset_Rec.Bsc_Dataset_Format_Id
                 ,x_Dataset_Rec.Bsc_Dataset_Color_Method
                 ,x_Dataset_Rec.Bsc_Dataset_Projection_Flag
                 ,x_Dataset_Rec.Bsc_Dataset_Autoscale_Flag
                 ,x_Dataset_Rec.Bsc_Dataset_Name
                 ,x_Dataset_Rec.Bsc_Dataset_Help
                 ,x_Dataset_Rec.Bsc_y_axis_title
                 ,x_Dataset_Rec.Bsc_Source
                 ,x_Dataset_Rec.Bsc_Dataset_Created_By           -- PMD
                 ,x_Dataset_Rec.Bsc_Dataset_Creation_Date        -- PMD
                 ,x_Dataset_Rec.Bsc_Dataset_Last_Update_By       -- PMD
                 ,x_Dataset_Rec.Bsc_Dataset_Last_Update_Date     -- PMD
                 ,x_Dataset_Rec.Bsc_Dataset_Last_Update_Login    -- PMD

            from  BSC_SYS_DATASETS_VL
           where dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Retrieve_Dataset;

/************************************************************************************
************************************************************************************/

procedure Update_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
  , p_Dataset_Rec         IN          BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

    l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

l_count                 number;
l_Old_Format_id          number;
    l_indicator_table       BSC_NUM_LIST;

CURSOR c_Default_Measure_In_Indicator IS
SELECT DISTINCT INDICATOR
FROM BSC_KPI_ANALYSIS_MEASURES_b
WHERE  DATASET_ID =p_Dataset_Rec.Bsc_Dataset_Id;



CURSOR indicators_cursor IS
SELECT b.indicator
FROM   bsc_kpi_analysis_measures_b b,
       bsc_kpis_b a
WHERE  a.indicator =b.indicator
AND    a.config_type <>3
AND    b.dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

l_kpi_flag           number;
l_color_Method_flag  boolean;
l_kpi_measure_id     BSC_KPI_ANALYSIS_MEASURES_B.KPI_MEASURE_ID%TYPE;

begin

  l_color_Method_flag := false;

    -- Check that valid dataset id was entered.
  if p_Dataset_Rec.Bsc_Dataset_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_DATASETS_B'
                                                       ,'dataset_id'
                                                       ,p_Dataset_Rec.Bsc_Dataset_Id);
    if l_count = 0 then
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DTSET_ID');
            FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    end if;
  else
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_DTSET_ID_ENTERED');
        FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
  end if;


/*  commented, apparently not needed.
  -- Check that valid measure id was entered.
  if p_Dataset_Rec.Bsc_Measure_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_MEASURES'
                                                       ,'measure_id'
                                                       ,p_Dataset_Rec.Bsc_Measure_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MEAS_ID');
      FND_MESSAGE.SET_TOKEN('BSC_MEAS', p_Dataset_Rec.Bsc_Measure_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_MEAS_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_MEAS', p_Dataset_Rec.Bsc_Measure_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check that valid 2nd measure id was entered.
  if p_Dataset_Rec.Bsc_Measure_Id2 is not null and
     p_Dataset_Rec.Bsc_Measure_Id2 <> 0 then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_MEASURES'
                                                       ,'measure_id'
                                                       ,p_Dataset_Rec.Bsc_Measure_Id2);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MEAS_ID');
      FND_MESSAGE.SET_TOKEN('BSC_MEAS', p_Dataset_Rec.Bsc_Measure_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

  end if;
*/


    -- Not all values will be passed.  We need to make sure values not passed are not
    -- changed by procedure, therefore we get what is there before we do any updates.
    Retrieve_Dataset( p_commit
                   ,p_Dataset_Rec
                   ,l_Dataset_Rec
                   ,x_return_status
                   ,x_msg_count
                   ,x_msg_data);

    -- mdamle 04/23/2003 - PMD - Measure Definer - Update flag in KPI for specific updates in the dataset
  -- fix bug 4185504  - (ppandey)Reverting this bug change for 6.1
  if p_Dataset_Rec.Bsc_Dataset_Color_Method is not null then
        if l_Dataset_Rec.Bsc_Dataset_Color_Method <> p_Dataset_Rec.Bsc_Dataset_Color_Method then
            l_color_Method_flag := true;
        end if;
        l_Dataset_Rec.Bsc_Dataset_Color_Method := p_Dataset_Rec.Bsc_Dataset_Color_Method;
  end if;

   if ( p_Dataset_Rec.Bsc_Measure_Id <> l_Dataset_Rec.Bsc_Measure_Id or
       p_Dataset_Rec.Bsc_Measure_Id2 <> l_Dataset_Rec.Bsc_Measure_Id2) then
        l_kpi_flag := BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure;
   end if;

    -- update LOCAL language ,source language  and level Id values with PASSED values.
    l_Dataset_Rec.Bsc_Language := p_Dataset_Rec.Bsc_Language;

  --sawu: update WHO column info with PASSED values
  l_Dataset_Rec.Bsc_Dataset_Last_Update_By := p_Dataset_Rec.Bsc_Dataset_Last_Update_By;
  l_Dataset_Rec.Bsc_Dataset_Last_Update_Date := p_Dataset_Rec.Bsc_Dataset_Last_Update_Date;
  l_Dataset_Rec.Bsc_Dataset_Last_Update_Login := p_Dataset_Rec.Bsc_Dataset_Last_Update_Login;

  --Fix for the bug  2883880

    IF (p_Dataset_Rec.Bsc_Source_Language IS NULL)THEN
        l_Dataset_Rec.Bsc_Source_Language := USERENV('LANG');
    ELSE
        l_Dataset_Rec.Bsc_Source_Language := p_Dataset_Rec.Bsc_Source_Language;
    END IF;
    -- adrao. since we have other modules using this API, we cannot allow null Measure_Id
    l_Dataset_Rec.Bsc_Dataset_Id          := p_Dataset_Rec.Bsc_Dataset_Id;
    --l_Dataset_Rec.Bsc_Measure_Id := p_Dataset_Rec.Bsc_Measure_Id;
    --if l_color_Method_flag = false then
       l_Dataset_Rec.Bsc_Measure_Id2         := p_Dataset_Rec.Bsc_Measure_Id2;
       l_Dataset_Rec.Bsc_Dataset_Operation   := p_Dataset_Rec.Bsc_Dataset_Operation;
       l_Dataset_Rec.Bsc_Y_Axis_Title        := p_Dataset_Rec.Bsc_Y_Axis_Title;
    --end if;
    -- mdamle 04/23/2003 - PMD - Measure Definer
    -- Checking for not null will not work if the user has actually tried to blank the value in a Null allowed column
    -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
    -- which are NOT NULL.
    -- adrao fixed bug #3123509
  if p_Dataset_Rec.Bsc_Measure_Id is not null then
        l_Dataset_Rec.Bsc_Measure_Id := p_Dataset_Rec.Bsc_Measure_Id;
  end if;
    /* if p_Dataset_Rec.Bsc_Measure_Id2 is not null then

        l_Dataset_Rec.Bsc_Measure_Id2 := p_Dataset_Rec.Bsc_Measure_Id2;
    end if;
    if p_Dataset_Rec.Bsc_Dataset_Operation is not null then
        l_Dataset_Rec.Bsc_Dataset_Operation := p_Dataset_Rec.Bsc_Dataset_Operation;
  end if;
*/

  if p_Dataset_Rec.Bsc_Dataset_Format_Id is not null then

   l_Old_Format_id := l_Dataset_Rec.Bsc_Dataset_Format_Id;
        l_Dataset_Rec.Bsc_Dataset_Format_Id    := p_Dataset_Rec.Bsc_Dataset_Format_Id;
  end if;
  if p_Dataset_Rec.Bsc_Dataset_Projection_Flag is not null then
        l_Dataset_Rec.Bsc_Dataset_Projection_Flag := p_Dataset_Rec.Bsc_Dataset_Projection_Flag;
  end if;
  if p_Dataset_Rec.Bsc_Dataset_Autoscale_Flag is not null then
        l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag  := p_Dataset_Rec.Bsc_Dataset_Autoscale_Flag;
  end if;
  if p_Dataset_Rec.Bsc_Dataset_Name is not null then
        l_Dataset_Rec.Bsc_Dataset_Name  := p_Dataset_Rec.Bsc_Dataset_Name;
  end if;
  if p_Dataset_Rec.Bsc_Dataset_Help is not null then
        l_Dataset_Rec.Bsc_Dataset_Help  := p_Dataset_Rec.Bsc_Dataset_Help;
  end if;
  if p_Dataset_Rec.Bsc_Measure_Long_Name is not null then
        l_Dataset_Rec.Bsc_Measure_Long_Name := p_Dataset_Rec.Bsc_Measure_Long_Name;
  end if;
    -- PMD
  if p_Dataset_Rec.Bsc_Dataset_Last_Update_By is null then
        l_Dataset_Rec.Bsc_Dataset_Last_Update_By := fnd_global.USER_ID;
  end if;
  if p_Dataset_Rec.Bsc_Dataset_Last_Update_Date is null then
        l_Dataset_Rec.Bsc_Dataset_Last_Update_Date := SYSDATE;
  end if;
  if p_Dataset_Rec.Bsc_Dataset_Last_Update_Login is null then
        l_Dataset_Rec.Bsc_Dataset_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;

  IF (p_Dataset_Rec.Bsc_Source = BSC_BIS_MEASURE_PUB.c_PMF AND l_Dataset_Rec.Bsc_Source = BSC_BIS_MEASURE_PUB.c_BSC) THEN
    l_Dataset_Rec.Bsc_Source := p_Dataset_Rec.Bsc_Source;
  END IF;

    -- PMD
    -- mdamle 03/12/2003 - PMD - Measure Definer
    -- Changed from Measure_operation to Dataset_Operation
    -- Added Measure_id1 and Measure_Id2
  update BSC_SYS_DATASETS_B
     set operation = l_Dataset_Rec.Bsc_Dataset_Operation
        ,format_id = l_Dataset_Rec.Bsc_Dataset_Format_Id
        ,color_method = l_Dataset_Rec.Bsc_Dataset_Color_Method
        ,projection_flag = l_Dataset_Rec.Bsc_Dataset_Projection_Flag
        ,autoscale_flag = l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag
        ,measure_id1 = l_Dataset_Rec.Bsc_Measure_Id
        ,measure_id2 = l_Dataset_Rec.Bsc_Measure_Id2
  ,source = l_Dataset_Rec.Bsc_Source
        ,last_updated_by  = l_Dataset_Rec.Bsc_Dataset_Last_Update_By       -- PMD
        ,last_update_date = l_Dataset_Rec.Bsc_Dataset_Last_Update_Date     -- PMD
        ,last_update_login = l_Dataset_Rec.Bsc_Dataset_Last_Update_Login   -- PMD
   where dataset_id = l_Dataset_Rec.Bsc_Dataset_Id;

   ----Fix for the bug  2883880

  update BSC_SYS_DATASETS_TL
     set name = l_Dataset_Rec.Bsc_Dataset_Name
        ,help = l_Dataset_Rec.Bsc_Dataset_Help
    ,y_axis_title = l_Dataset_Rec.Bsc_y_axis_title
        ,source_lang = l_Dataset_Rec.Bsc_Source_Language
   where dataset_id = l_Dataset_Rec.Bsc_Dataset_Id
     and l_Dataset_Rec.Bsc_Source_Language in (LANGUAGE, SOURCE_LANG);

  -- Following logic brings code dependency from BSC
  --   But this is acceptable as with R12 BIS/BSC will always go together.
  IF (l_kpi_flag IS NOT NULL OR l_color_Method_flag) THEN
    OPEN indicators_cursor;
    FETCH indicators_cursor BULK COLLECT INTO l_indicator_table;
    IF indicators_cursor%ISOPEN THEN CLOSE indicators_cursor; END IF;

    FOR i IN 1..l_indicator_table.COUNT LOOP
      IF (l_kpi_flag IS NOT NULL) THEN
        BSC_DESIGNER_PVT.ActionFlag_Change(l_indicator_table(i), l_kpi_flag);
      END IF;
      IF (l_color_Method_flag) THEN
        SELECT kpi_measure_id
        INTO   l_kpi_measure_id
        FROM   bsc_kpi_analysis_measures_b
        WHERE  indicator = l_indicator_table(i)
        AND    dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

        BSC_COLOR_RANGES_PUB.Delete_Color_Prop_Ranges (p_objective_id   => l_indicator_table(i)
                                                      ,p_kpi_measure_id => l_kpi_measure_id
                                                      ,p_cascade_shared => TRUE
                                                      ,x_return_status  => x_return_status
                                                      ,x_msg_count      => x_msg_count
                                                      ,x_msg_data       => x_msg_data);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        BSC_COLOR_RANGES_PUB.Create_Def_Color_Prop_Ranges(p_objective_id   => l_indicator_table(i)
                                                         ,p_kpi_measure_id => l_kpi_measure_id
                                                         ,p_cascade_shared => TRUE
                                                         ,x_return_status  => x_return_status
                                                         ,x_msg_count      => x_msg_count
                                                         ,x_msg_data       => x_msg_data);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;

 if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


-- visuri fixed bug 3681116
-- Update of Numeric Format of measure will change the default numeric format of all Indicators for which
-- that measure is a default measure. This update will take place in BSC_KPI_DEFAULTS_B table

if ( l_Old_Format_id <> p_Dataset_Rec.Bsc_Dataset_Format_Id and p_Dataset_Rec.Bsc_Dataset_Format_Id is not null ) then

  FOR cd IN c_Default_Measure_In_Indicator LOOP
   BSC_DESIGNER_PVT.Deflt_RefreshKpi(cd.INDICATOR);

   END LOOP;

  end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Update_Dataset;

/************************************************************************************
************************************************************************************/

procedure Delete_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

cursor indicators_cursor IS
select distinct k.name
from  bsc_kpi_analysis_measures_vl am, bsc_kpis_vl k
where am.indicator = k.indicator
and dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

l_short_name bis_indicators.short_name%TYPE;
CURSOR c_short_name(l_dataset_id NUMBER)
IS
SELECT
  short_name
FROM
  bis_indicators
WHERE dataset_id =  l_dataset_id;

l_indicators            varchar2(32000);

l_count             number;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check that a valid dataset id was entered.
  if p_Dataset_Rec.Bsc_Dataset_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_DATASETS_B'
                                                       ,'dataset_id'
                                                       ,p_Dataset_Rec.Bsc_Dataset_Id);
    if l_count = 0 then
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DTSET_ID');
            FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    end if;

        -- mdamle 04/23/2003 - PMD - Measure Definer - Check if assigned to indicator
    for cr in indicators_cursor loop
        if (l_indicators is null) then
                l_indicators := cr.name;
        else
                l_indicators := l_indicators || ', ' || cr.name;
        end if;
    end loop;

    if indicators_cursor%ISOPEN THEN
        CLOSE indicators_cursor;
    end if;

        if l_indicators is not null then
          FND_MESSAGE.SET_NAME('BSC','BSC_DELETE_MEASURE_IND_ERR_TXT');
          FND_MESSAGE.SET_TOKEN('BSC_INDICATORS', l_indicators);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
  else
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_DTSET_ID_ENTERED');
        FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
  end if;

  OPEN c_short_name(p_Dataset_Rec.Bsc_Dataset_Id);
  FETCH c_short_name INTO l_short_name;
  CLOSE c_short_name;

  DELETE FROM bis_custom_cause_effect_rels
    WHERE cause_short_name = l_short_name OR effect_short_name = l_short_name;

  -- mdamle 04/23/2003 - PMD - Measure Definer - Delete Cause and Effect relationships
  BSC_CAUSE_EFFECT_REL_PUB.Delete_All_Cause_Effect_Rels(
         p_commit => p_commit
        ,p_indicator => p_Dataset_Rec.Bsc_Dataset_Id
        ,p_level => BSC_BIS_MEASURE_PUB.c_LEVEL
        ,x_return_status => x_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data);

  delete from BSC_SYS_DATASETS_B
   where dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

  delete from BSC_SYS_DATASETS_TL
   where dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded =>  FND_API.G_FALSE
                              ,p_count   =>  x_msg_count
                              ,p_data    =>  x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded =>  FND_API.G_FALSE
                              ,p_count  =>  x_msg_count
                              ,p_data   =>  x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded =>  FND_API.G_FALSE
                              ,p_count   =>  x_msg_count
                              ,p_data    =>  x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded =>  FND_API.G_FALSE
                              ,p_count   =>  x_msg_count
                              ,p_data    =>  x_msg_data);
    raise;

end Delete_Dataset;

/************************************************************************************
************************************************************************************/

--:     This procedure creates the necessary values for the disabled calc id
--:     for the given dimension.
--:     This procedure is part of the Data Set API.

procedure Create_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin


  -- Check that valid dataset id was entered.
  if p_Dataset_Rec.Bsc_Dataset_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_DATASETS_B'
                                                       ,'dataset_id'
                                                       ,p_Dataset_Rec.Bsc_Dataset_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DTSET_ID');
      FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    else -- Check that combination dataset id and calc id does not exist.
      select count(1)
        into l_count
        from BSC_SYS_DATASET_CALC
       where dataset_id = p_Dataset_Rec.Bsc_Dataset_Id
         and disabled_calc_id = p_Dataset_Rec.Bsc_Disabled_Calc_Id;
      if l_count <> 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_DTSET_CALC_EXISTSD');
        FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Disabled_Calc_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;

    end if;

  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_DTSET_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Insert pertaining values into table bsc_sys_dataset_calc.
  insert into BSC_SYS_DATASET_CALC( dataset_id
                                   ,disabled_calc_id)
                            values( p_Dataset_Rec.Bsc_Dataset_Id
                                   ,p_Dataset_Rec.Bsc_Disabled_Calc_Id);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Create_Dataset_Calc;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  select distinct disabled_calc_id
             into x_Dataset_Rec.Bsc_Disabled_Calc_Id
             from BSC_SYS_DATASET_CALC
            where dataset_id = x_Dataset_Rec.Bsc_Dataset_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Retrieve_Dataset_Calc;

/************************************************************************************
************************************************************************************/

procedure Update_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count                 number;

begin

  -- Check that valid dataset id was entered.
  if p_Dataset_Rec.Bsc_Dataset_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_DATASETS_B'
                                                       ,'dataset_id'
                                                       ,p_Dataset_Rec.Bsc_Dataset_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DTSET_ID');
      FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_DTSET_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  update BSC_SYS_DATASET_CALC
     set disabled_calc_id = p_Dataset_Rec.Bsc_Disabled_Calc_Id
   where dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Update_Dataset_Calc;

/************************************************************************************
************************************************************************************/

procedure Delete_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin

    -- Check that valid dataset id was entered.
  if p_Dataset_Rec.Bsc_Dataset_Id is not null then

    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_DATASETS_B'
                                                       ,'dataset_id'
                                                       ,p_Dataset_Rec.Bsc_Dataset_Id);

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DTSET_ID');
      FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_DTSET_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_DATASET', p_Dataset_Rec.Bsc_Dataset_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  delete from BSC_SYS_DATASET_CALC
   where dataset_id = p_Dataset_Rec.Bsc_Dataset_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN null;
/*
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
*/
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Delete_Dataset_Calc;

/************************************************************************************
************************************************************************************/

--: This function gets the count of rows for the name for the given measure.
--: This function is used as a validation method.

function Validate_Measure(
  p_Measure_Name                varchar2
) return number is

l_count                         number;

begin
  -- mdamle 04/23/2003 - PMD - Measure Definer - short_name not used, instead dataset_id added to bis_indicators
  select count(1)
    into l_count
--    from BSC_SYS_MEASURES
    from bis_indicators i, bsc_sys_datasets_vl d
   where short_name = p_Measure_Name
   and i.dataset_id = d.dataset_id;

  return l_count;

EXCEPTION
  when NO_DATA_FOUND then
    null;
end Validate_Measure;


/************************************************************************************
************************************************************************************/
--=============================================================================
PROCEDURE Translate_Measure
( p_commit IN VARCHAR2
, p_Measure_Rec IN BIS_MEASURE_PUB.Measure_Rec_Type
, p_Dataset_Rec IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
)
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Initialize;

  UPDATE bsc_sys_datasets_tl
  SET    name = p_Dataset_Rec.Bsc_Dataset_Name
        ,help = p_Dataset_Rec.Bsc_Dataset_Help
    ,y_axis_title = p_Dataset_Rec.Bsc_y_axis_title
        ,source_lang = userenv('LANG')
  WHERE dataset_id = p_Dataset_Rec.Bsc_Dataset_Id
  AND   userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;

END Translate_Measure;
--=============================================================================

-- mdamle 09/25/2003 - Sync up measures for all installed languages
PROCEDURE Translate_Measure_By_lang
( p_commit          IN VARCHAR2
, p_Dataset_Rec     IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, p_lang            IN VARCHAR2
, p_source_lang     IN VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
)
IS

BEGIN
  SAVEPOINT  TransMeasByLangBsc;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Initialize;

  UPDATE BSC_SYS_DATASETS_TL
  SET    name = p_Dataset_Rec.Bsc_Dataset_Name
        ,help = p_Dataset_Rec.Bsc_Dataset_Help
        ,y_axis_title = p_Dataset_Rec.Bsc_y_axis_title
        ,source_lang = p_source_lang
  WHERE dataset_id = p_Dataset_Rec.Bsc_Dataset_Id
  and LANGUAGE = p_lang;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO TransMeasByLangBsc;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO TransMeasByLangBsc;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO TransMeasByLangBsc;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO TransMeasByLangBsc;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);

END Translate_Measure_By_Lang;
--=============================================================================

end BSC_DATASETS_PVT;

/
