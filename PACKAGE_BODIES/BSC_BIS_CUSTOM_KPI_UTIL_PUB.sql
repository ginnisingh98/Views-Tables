--------------------------------------------------------
--  DDL for Package Body BSC_BIS_CUSTOM_KPI_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_CUSTOM_KPI_UTIL_PUB" AS
/* $Header: BSCCSUBB.pls 120.9 2007/10/10 06:42:39 bijain ship $ */

/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCCSUBB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper API for Configure KPI List Page                   |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     13-Aug-04    rpenneru   Created.                                  |
REM |     17-AUG-04    adrao      Modified API SetGlobalFlag and added API  |
REM |                             Is_BSC52_Applied for Bug@3836170          |
REM |     05-OCT-04    ankgoel    Bug#3933075 Moved Get_Pmf_Metadata_By_Objective
REM |                             and get_Region_Code here from BSCCRUDB.pls|
REM |     11-Feb-05    sawu       Bug#4057761: added get_Next_Alias and     |
REM |                             Get_Unqiue_Tab_Name, Get_Unqiue_Tab_Group_Name|
REM |     30-Mar-05    wleung     hardcode Get_Max_Tab_Name_Length() and     |
REM |                             Get_Max_Tab_Grp_Name_Length                |
REM |     27-MAR-05    adrao      Modified API is_Report_S2E for Bug#4331964|
REM |     29-APR-05    ankagarw   Modified API Is_Short_Name_Available for Bug#4336571|
REM |                             Made it public.                           |
REM |     09-MAY-05    adrao      Added API is_Objective_Report_Type        |
REM |                             and is_Objective_Page_Type                |
REM |     26-SEP-2005 arhegde bug# 4624100 Moved get_format_mask code to    |
REM |          BSC_BIS_CUSTOM_KPI_UTIL_PUB from BSC_BIS_KPI_CRUD_PUB since  |
REM |          pure BIS can use it too.                                     |
REM |     10-MAY-2006 visuri  bug#5130750 Data Corruption issue             |
REM |     09-FEB-1007 ashankar Simulation ER 5386112                        |
REM |     03-APR-2007 amitgupt    modified for bug 5959433                  |
REM |     02-Oct-2007 bijain   Bug#6327035  Changing the display name of a  |
REM |                 DashBord for End to End Kpi should update BSC MetaData|
REM +=======================================================================+
*/

-- changed to use BSC_KPI_ANALYSIS_OPTIONS_B
-- BSC_KPIS_B.SHORT_NAME and BSC_TABS_B.SHORT_NAME have existed before Start-to-End KPI.


PROCEDURE SetGlobalFlag
IS

 TYPE Ref_Cur IS REF CURSOR;
 Flag_Cur   Ref_Cur;
 sql_query      VARCHAR2(2000);
 rec_count      NUMBER;
 BEGIN

  IF(Flag_Cur%ISOPEN) THEN
    CLOSE Flag_Cur;
  END IF;

  sql_query := 'select count(1) from sys.all_tab_columns where table_name = ''BSC_DB_MEASURE_GROUPS_TL'' and COLUMN_NAME  = ''SHORT_NAME'' ';
  OPEN Flag_Cur FOR sql_query;
    FETCH Flag_Cur INTO rec_count;
  CLOSE Flag_Cur;

  IF (rec_count > 0) THEN
    BSC_BIS_CUSTOM_KPI_UTIL_PUB.G_MDDD_52 := BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_BSC_PATCH_LEVEL_52;
  ELSE
    BSC_BIS_CUSTOM_KPI_UTIL_PUB.G_MDDD_52 := BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_BSC_PATCH_LEVEL_511;
  END IF;
 EXCEPTION
  WHEN OTHERS THEN
  BSC_BIS_CUSTOM_KPI_UTIL_PUB.G_MDDD_52 := BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_BSC_PATCH_LEVEL_511;
END SetGlobalFlag;


FUNCTION IS_NOT_NULL(p_name VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
    IF (p_name IS NULL) THEN
      RETURN FND_API.G_FALSE;
    END IF;
    RETURN FND_API.G_TRUE;
END IS_NOT_NULL;


/*this function will return 'T' (FND_API.G_TRUE) if the passed short_name of Measure
  is created through KPI End to End module otherwise 'F' (FND_API.G_FALSE)

  This function assumes the Short_Name passed is valid and exists in
  BSC Metadata. It will not be checked from BSC tables due to performance reasons.

  p_Short_Name Corresponds to BSC_SYS_MEASURES.Short_Name
*/
FUNCTION is_KPI_EndToEnd_Measure(p_Short_Name VARCHAR2)
RETURN VARCHAR2 IS
  l_Count NUMBER;
BEGIN
    IF (p_Short_Name IS NULL) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    l_Count := 0;

    SELECT COUNT(1) INTO l_Count
    FROM   bis_indicators
    WHERE  short_name         = p_Short_Name
    AND    actual_data_source IS NOT NULL
    AND    actual_data_source_type = 'AK';

    IF (l_Count = 0) THEN
        RETURN FND_API.G_FALSE;
    ELSE
        RETURN FND_API.G_TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_Measure;

procedure update_kpi_End_To_End_Name(
  p_Commit                       IN         VARCHAR2 := FND_API.G_FALSE
  ,p_Name                        IN         VARCHAR2
  ,p_Short_Name                  IN         VARCHAR2
  ,x_Return_Status               OUT NOCOPY VARCHAR2
  ,x_Msg_Count                   OUT NOCOPY NUMBER
  ,x_Msg_Data                    OUT NOCOPY VARCHAR2
) IS

  l_tab_id                       BSC_TABS_B.TAB_ID%TYPE;
  l_kpi_group_id                 BSC_TAB_IND_GROUPS_B.IND_GROUP_ID%TYPE;
  l_kpi_id                       BSC_KPIS_B.INDICATOR%TYPE;
  l_tab_name                     BSC_TABS_VL.NAME%TYPE;
  l_tab_ind_group_name           BSC_TAB_IND_GROUPS_VL.NAME%TYPE;
  not_S_To_E_Kpi                 EXCEPTION;

BEGIN
  SAVEPOINT UpdateEndToEndKPIName;
  FND_MSG_PUB.Initialize;
  x_Return_Status :=  FND_API.G_RET_STS_SUCCESS;

  l_tab_id        := BSC_BIS_KPI_CRUD_PUB.Get_Tab_Id(p_Short_Name);
  l_kpi_group_id  := BSC_BIS_KPI_CRUD_PUB.Get_Group_Id(p_Short_Name);
  l_kpi_id        := BSC_BIS_KPI_CRUD_PUB.Get_Kpi_Id(p_Short_Name);

  IF(BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY <> l_tab_id) THEN
      l_tab_name := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Unqiue_Tab_Name(p_Name, l_tab_id);
      BSC_PMF_UI_WRAPPER.Update_Tab(
      p_commit          =>  p_Commit
      ,p_tab_id         =>  l_tab_id
      ,p_tab_name       =>  l_tab_name
      ,p_tab_help       =>  l_tab_name
      ,x_return_status  =>  x_Return_Status
      ,x_msg_count      =>  x_Msg_Count
      ,x_msg_data       =>  x_Msg_Data
    );
  ELSE
    RAISE not_S_To_E_Kpi;
  END IF;

  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF(BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY <> l_kpi_group_id) THEN
    l_tab_ind_group_name := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Unqiue_Tab_Group_Name(p_Name,l_kpi_group_id);
    BSC_PMF_UI_WRAPPER.Update_Kpi_Group(
      p_commit          =>  p_Commit
      ,p_kpi_group_id   =>  l_kpi_group_id
      ,p_kpi_group_name =>  l_tab_ind_group_name
      ,p_kpi_group_help =>  l_tab_ind_group_name
      ,x_return_status  =>  x_Return_Status
      ,x_msg_count      =>  x_Msg_Count
      ,x_msg_data       =>  x_Msg_Data
    );
  ELSE
    RAISE not_S_To_E_Kpi;
  END IF;

  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF(-1000 <> l_kpi_id) THEN
    BSC_PMF_UI_WRAPPER.Update_Kpi(
      p_commit          =>  p_Commit
      ,p_kpi_id         =>  l_kpi_id
      ,p_kpi_name       =>  p_Name
      ,p_kpi_help       =>  p_Name
      ,x_return_status  =>  x_Return_Status
      ,x_msg_count      =>  x_Msg_Count
      ,x_msg_data       =>  x_Msg_Data
    );
  ELSE
    RAISE not_S_To_E_Kpi;
  END IF;

  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_Commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN not_S_To_E_Kpi THEN
    ROLLBACK TO UpdateEndToEndKPIName;
  WHEN OTHERS THEN
    x_Return_Status  := FND_API.G_RET_STS_ERROR;
    ROLLBACK TO UpdateEndToEndKPIName;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_CUSTOM_KPI_UTIL_PUB.update_kpi_End_To_End_Name ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_CUSTOM_KPI_UTIL_PUB.update_kpi_End_To_End_Name ';
    END IF;
END update_kpi_End_To_End_Name;
FUNCTION is_KPI_EndToEnd_Measure(p_Measure_Id NUMBER)
  RETURN VARCHAR2 IS
    TYPE Ref_Cur IS REF CURSOR;
    Flag_Cur    Ref_Cur;
    sql_query       VARCHAR2(2000);
    l_count NUMBER :=0;

  BEGIN

    IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.Is_Short_Name_Available = FND_API.G_FALSE) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    IF(Flag_Cur%ISOPEN) THEN
      CLOSE Flag_Cur;
    END IF;

    sql_query := 'SELECT count(1) FROM  BSC_SYS_MEASURES a,BSC_DB_MEASURE_COLS_VL b '
                 ||'  , BSC_DB_MEASURE_GROUPS_VL c '
                 ||'  WHERE a.measure_col = b.measure_col '
                 ||' AND a.measure_id = :p_measure_id'
                         ||' AND b.measure_group_id = c.measure_group_id '
                 ||' AND c.short_name IS NOT NULL ';
    OPEN Flag_Cur FOR sql_query USING p_Measure_Id;
      FETCH Flag_Cur INTO l_count;
    CLOSE Flag_Cur;
    IF (l_count > 0) THEN
      RETURN FND_API.G_TRUE;
    END IF;
    RETURN FND_API.G_FALSE;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_Measure;


FUNCTION is_KPI_EndToEnd_MeasureGroup(p_Short_Name VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
    RETURN IS_NOT_NULL(p_Short_Name);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_MeasureGroup;


FUNCTION is_KPI_EndToEnd_MeasureGroup(p_Measure_Group_Id NUMBER)
  RETURN VARCHAR2 IS
  TYPE Ref_Cur IS REF CURSOR;
  Flag_Cur  Ref_Cur;
  sql_query         VARCHAR2(2000);
  rec_count     NUMBER;

  BEGIN

    IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.Is_Short_Name_Available = FND_API.G_FALSE) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    IF(Flag_Cur%ISOPEN) THEN
      CLOSE Flag_Cur;
    END IF;

    sql_query := 'select count(1) from bsc_db_measure_groups_vl where short_name is not null and measure_group_id = :p_measure_group_id';
    OPEN Flag_Cur FOR sql_query USING p_Measure_Group_Id;
      FETCH Flag_Cur INTO rec_count;
    CLOSE Flag_Cur;

    IF (rec_count > 0) THEN
      RETURN FND_API.G_TRUE;
    END IF;
    RETURN FND_API.G_FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_MeasureGroup;


FUNCTION is_KPI_EndToEnd_MeasureCol(p_Measure_Col VARCHAR2,p_MesGrp_Short_Name VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
    RETURN BSC_BIS_CUSTOM_KPI_UTIL_PUB.is_KPI_EndToEnd_MeasureGroup(p_MesGrp_Short_Name);
  EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_MeasureCol;


FUNCTION is_KPI_EndToEnd_MeasureCol(p_Measure_Col VARCHAR2)
  RETURN VARCHAR2
  IS
  CURSOR c_MeasureGrp IS
    SELECT measure_group_id FROM BSC_DB_MEASURE_COLS_VL
    WHERE measure_col = p_Measure_Col;

  l_Measure_Group_Id BSC_DB_MEASURE_COLS_VL.MEASURE_GROUP_ID%TYPE;

  BEGIN
    IF(c_MeasureGrp%ISOPEN) THEN
      CLOSE c_MeasureGrp;
    END IF;

    OPEN c_MeasureGrp;
    FETCH c_MeasureGrp INTO l_Measure_Group_Id;
    CLOSE c_MeasureGrp;
    RETURN BSC_BIS_CUSTOM_KPI_UTIL_PUB.is_KPI_EndToEnd_MeasureGroup(l_Measure_Group_Id);

  EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_MeasureCol;


/*this function will return 'T' (FND_API.G_TRUE) if the passed short_name of scorecard
  is created through KPI End to End module otherwise 'F' (FND_API.G_FALSE).

  This function assumes the Short_Name passed is valid and exists in
  BSC Metadata. It will not be checked from BSC tables due to performance reasons.

  p_Short_Name Corresponds to BSC_TABS_B.Short_Name
*/
FUNCTION is_KPI_EndToEnd_Scorecard(p_Short_Name VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
     RETURN IS_NOT_NULL(p_Short_Name);
  EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_Scorecard;


FUNCTION Get_User_Function_Name(p_function_name VARCHAR2) RETURN VARCHAR2
IS
  l_user_function_name   VARCHAR2(100);
BEGIN
  l_user_function_name := p_function_name;
  SELECT a.user_function_name
  INTO l_user_function_name
  FROM fnd_form_functions_vl a
  WHERE a.function_name = p_function_name;

  IF (l_user_function_name IS NULL) THEN
    l_user_function_name := p_function_name;
  END IF;

  RETURN l_user_function_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN p_function_name;
   WHEN OTHERS THEN RETURN p_function_name;
END Get_User_Function_Name;


-- Check if ODF with short_names has been applied or not
FUNCTION enableVarchar2Implementation
RETURN VARCHAR2 IS
BEGIN
    IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.Is_Short_Name_Available = FND_API.G_FALSE) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    RETURN FND_API.G_TRUE;
EXCEPTION
  WHEN OTHERS THEN
     RETURN FND_API.G_FALSE;
END enableVarchar2Implementation;


-- Returns/Inits if SHORT_NAME is available via ODF or not.
FUNCTION Is_Short_Name_Available
RETURN VARCHAR2 IS
BEGIN

    IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.G_MDDD_52 = BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_BSC_PATCH_LEVEL_UNINIT) THEN
      BSC_BIS_CUSTOM_KPI_UTIL_PUB.setGlobalFlag;
    END IF;

    IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.G_MDDD_52 = BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_BSC_PATCH_LEVEL_511) THEN
        RETURN FND_API.G_FALSE;
    ELSIF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.G_MDDD_52 = BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_BSC_PATCH_LEVEL_52) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;
EXCEPTION
  WHEN OTHERS THEN
     RETURN FND_API.G_FALSE;
END Is_Short_Name_Available;

/*
  PL/SQL API to return region_code
*/

FUNCTION get_Region_Code (
            p_Kpi_Id NUMBER
          , p_AO_Id NUMBER := NULL
) RETURN VARCHAR2 IS
  l_Region_Code  VARCHAR2(80);
BEGIN

   IF (p_Kpi_Id IS NULL) THEN
     RETURN NULL;
   END IF;

   IF ((p_AO_Id IS NOT NULL) AND (p_AO_Id <> -1)) THEN
     l_Region_Code := BSC_UTILITY.C_BSC_UNDERSCORE || p_Kpi_Id || '_' || p_AO_Id;
   ELSE
     l_Region_Code := BSC_UTILITY.C_BSC_UNDERSCORE || p_Kpi_Id ;
   END IF;

   RETURN l_Region_Code;

END get_Region_Code;


-- ankgoel: bug#3759819
-- This API assumes that the Input parameters are not NULL
PROCEDURE Get_Pmf_Metadata_By_Objective(
  p_Dataset_Id         IN         NUMBER
, p_Measure_Short_Name IN         VARCHAR2
, x_Actual_Source_Type OUT NOCOPY VARCHAR2
, x_Actual_Source      OUT NOCOPY VARCHAR2
, x_Function_Name      OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_KpiAo IS
    SELECT indicator kpiId, analysis_option0 aoId
    FROM bsc_kpi_analysis_measures_b
    WHERE dataset_id = p_Dataset_Id;

  l_Analysis_Option  NUMBER;
  l_Region_Code      VARCHAR2(30);
  l_Kpi_Id           NUMBER;
BEGIN

  FOR Kpi_Ao IN c_KpiAo LOOP
    l_Kpi_Id := Kpi_Ao.kpiId;
    l_Analysis_Option := Kpi_Ao.aoId;
  END LOOP;

  l_Region_Code        := Get_Region_Code (l_Kpi_Id, l_Analysis_Option);
  x_Actual_Source_Type := BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_AK_DATASOURCE;

  IF (l_Region_Code IS NOT NULL) THEN
    x_Actual_Source      := l_Region_Code || '.' || p_Measure_Short_Name;
  ELSE
    x_Actual_Source      := NULL;
  END IF;

  x_Function_Name      := l_Region_Code;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Get_Pmf_Metadata_By_Objective;

--added for bug#4057761
FUNCTION get_Next_Alias(
 p_Alias        IN   VARCHAR2
) RETURN VARCHAR2
IS
  l_alias     VARCHAR2(5);
  l_return    VARCHAR2(5);
  l_count     NUMBER;
BEGIN
  IF (p_Alias IS NULL) THEN
    l_return :=  'A';
  ELSE
    l_count := LENGTH(p_Alias);
    IF (l_count = 1) THEN
      l_return   := 'A0';
    ELSIF (l_count > 1) THEN
      l_alias     :=  SUBSTR(p_Alias, 2);
      l_count     :=  TO_NUMBER(l_alias)+1;
      l_return    :=  'A'||TO_CHAR(l_count);
    END IF;
  END IF;
  RETURN l_return;
END get_Next_Alias;

FUNCTION Get_Max_Tab_Name_Length
RETURN NUMBER IS
  l_fnd_length             NUMBER;
  l_tab_length             NUMBER;
BEGIN
/*
  SELECT data_length INTO l_fnd_length
  FROM SYS.ALL_TAB_COLUMNS
  WHERE table_name = 'FND_FORM_FUNCTIONS_TL'
  AND column_name = 'USER_FUNCTION_NAME';

  SELECT data_length INTO l_tab_length
  FROM SYS.ALL_TAB_COLUMNS
  WHERE table_name = 'BSC_TABS_TL'
  AND column_name = 'NAME';

  --return the min of these two
  IF (l_fnd_length > l_tab_length) THEN
    RETURN l_tab_length;
  ELSE
    RETURN l_fnd_length;
  END IF;
  */
  RETURN 80;
END Get_Max_Tab_Name_Length;

FUNCTION Get_Max_Tab_Grp_Name_Length
RETURN NUMBER IS
  l_fnd_length             NUMBER;
  l_tab_group_length       NUMBER;
BEGIN
/*
  SELECT data_length INTO l_fnd_length
  FROM SYS.ALL_TAB_COLUMNS
  WHERE table_name = 'FND_FORM_FUNCTIONS_TL'
  AND column_name = 'USER_FUNCTION_NAME';

  SELECT data_length INTO l_tab_group_length
  FROM SYS.ALL_TAB_COLUMNS
  WHERE table_name = 'BSC_TAB_IND_GROUPS_TL'
  AND column_name = 'NAME';

  --return the min of these two
  IF (l_fnd_length > l_tab_group_length) THEN
    RETURN l_tab_group_length;
  ELSE
    RETURN l_fnd_length;
  END IF;
  */
  RETURN 80;
END Get_Max_Tab_Grp_Name_Length;

FUNCTION Get_Unqiue_Tab_Name(
 p_tab_name        BSC_TABS_TL.NAME%TYPE
) RETURN BSC_TABS_TL.NAME%TYPE IS
 l_tab_name        BSC_TABS_TL.NAME%TYPE;
 l_flag            BOOLEAN := TRUE;
 l_count           NUMBER;
 l_loop_count      NUMBER := 0;
 l_alias           VARCHAR2(5) := NULL;
 l_max_tab_length  NUMBER;
 l_overflow        NUMBER;
BEGIN
 IF (p_tab_name IS NULL) THEN
  l_tab_name := 'A'; --extended alias
 ELSE
  l_tab_name := trim(p_tab_name);
 END IF;

 l_max_tab_length := Get_Max_Tab_Name_Length;

 WHILE ((l_flag) AND (l_loop_count < BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_MAX_LOOP_COUNT)) LOOP
   SELECT count(1) INTO l_count
   FROM BSC_TABS_VL
   WHERE UPPER(trim(name)) = UPPER(l_tab_name);

   IF (l_count = 0) THEN
    l_flag := FALSE;
   ELSE
    l_alias      := get_Next_Alias(l_alias);
    l_loop_count := l_loop_count + 1;    --prevent infinite loop should alias exhausted
    --prevent overflow
    l_overflow := LENGTH(p_tab_name) + LENGTH(l_alias) - l_max_tab_length;
    IF (l_overflow > 0) THEN
      l_tab_name := SUBSTR(p_tab_name, 1, LENGTH(p_tab_name)-l_overflow) || l_alias;
    ELSE
      l_tab_name := p_tab_name || l_alias;
    END IF;
   END IF;
 END LOOP;

 RETURN l_tab_name;

EXCEPTION
 WHEN OTHERS THEN
  RETURN p_tab_name;
END Get_Unqiue_Tab_Name;

FUNCTION Get_Unqiue_Tab_Name(
 p_tab_name        BSC_TABS_TL.NAME%TYPE,
 p_tab_id          BSC_TABS_TL.TAB_ID%TYPE
) RETURN BSC_TABS_TL.NAME%TYPE IS
 l_tab_name        BSC_TABS_TL.NAME%TYPE;
 l_flag            BOOLEAN := TRUE;
 l_count           NUMBER;
 l_loop_count      NUMBER := 0;
 l_alias           VARCHAR2(5) := NULL;
 l_max_tab_length  NUMBER;
 l_overflow        NUMBER;
BEGIN
 IF (p_tab_name IS NULL) THEN
  l_tab_name := 'A'; --extended alias
 ELSE
  l_tab_name := trim(p_tab_name);
 END IF;

 l_max_tab_length := Get_Max_Tab_Name_Length;

 WHILE ((l_flag) AND (l_loop_count < BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_MAX_LOOP_COUNT)) LOOP
   SELECT count(1) INTO l_count
   FROM BSC_TABS_VL
   WHERE UPPER(trim(name)) = UPPER(l_tab_name)
         AND tab_id <> p_tab_id;

   IF (l_count = 0) THEN
    l_flag := FALSE;
   ELSE
    l_alias      := get_Next_Alias(l_alias);
    l_loop_count := l_loop_count + 1;    --prevent infinite loop should alias exhausted
    --prevent overflow
    l_overflow := LENGTH(p_tab_name) + LENGTH(l_alias) - l_max_tab_length;
    IF (l_overflow > 0) THEN
      l_tab_name := SUBSTR(p_tab_name, 1, LENGTH(p_tab_name)-l_overflow) || l_alias;
    ELSE
      l_tab_name := p_tab_name || l_alias;
    END IF;
   END IF;
 END LOOP;

 RETURN l_tab_name;

EXCEPTION
 WHEN OTHERS THEN
  RETURN p_tab_name;
END Get_Unqiue_Tab_Name;

FUNCTION Get_Unqiue_Tab_Group_Name(
 p_tab_grp_name        BSC_TAB_IND_GROUPS_TL.NAME%TYPE
) RETURN BSC_TAB_IND_GROUPS_TL.NAME%TYPE IS
 l_tab_grp_name         BSC_TAB_IND_GROUPS_TL.NAME%TYPE;
 l_flag                 BOOLEAN := TRUE;
 l_count                NUMBER;
 l_loop_count      NUMBER := 0;
 l_alias                VARCHAR2(5) := NULL;
 l_max_tab_grp_length   NUMBER;
 l_overflow             NUMBER;
BEGIN
 IF (p_tab_grp_name IS NULL) THEN
  l_tab_grp_name := 'A'; --extended alias
 ELSE
  l_tab_grp_name := trim(p_tab_grp_name);
 END IF;

 l_max_tab_grp_length := Get_Max_Tab_Grp_Name_Length;

 WHILE ((l_flag) AND (l_loop_count < BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_MAX_LOOP_COUNT)) LOOP
   SELECT count(1) INTO l_count
   FROM BSC_TAB_IND_GROUPS_VL
   WHERE UPPER(trim(name)) = UPPER(l_tab_grp_name);

   IF (l_count = 0) THEN
    l_flag := FALSE;
   ELSE
    l_alias      := get_Next_Alias(l_alias);
    l_loop_count := l_loop_count + 1;    --prevent infinite loop should alias exhausted
    --prevent overflow
    l_overflow := LENGTH(p_tab_grp_name) + LENGTH(l_alias) - l_max_tab_grp_length;
    IF (l_overflow > 0) THEN
      l_tab_grp_name := SUBSTR(p_tab_grp_name, 1, LENGTH(p_tab_grp_name)-l_overflow) || l_alias;
    ELSE
      l_tab_grp_name := p_tab_grp_name || l_alias;
    END IF;
   END IF;
 END LOOP;

 RETURN l_tab_grp_name;

EXCEPTION
 WHEN OTHERS THEN
  RETURN p_tab_grp_name;
END Get_Unqiue_Tab_Group_Name;

FUNCTION Get_Unqiue_Tab_Group_Name(
 p_tab_grp_name        BSC_TAB_IND_GROUPS_TL.NAME%TYPE,
 p_tab_grp_id          BSC_TAB_IND_GROUPS_TL.IND_GROUP_ID%TYPE
) RETURN BSC_TAB_IND_GROUPS_TL.NAME%TYPE IS
 l_tab_grp_name         BSC_TAB_IND_GROUPS_TL.NAME%TYPE;
 l_flag                 BOOLEAN := TRUE;
 l_count                NUMBER;
 l_loop_count      NUMBER := 0;
 l_alias                VARCHAR2(5) := NULL;
 l_max_tab_grp_length   NUMBER;
 l_overflow             NUMBER;
BEGIN
 IF (p_tab_grp_name IS NULL) THEN
  l_tab_grp_name := 'A'; --extended alias
 ELSE
  l_tab_grp_name := trim(p_tab_grp_name);
 END IF;

 l_max_tab_grp_length := Get_Max_Tab_Grp_Name_Length;

 WHILE ((l_flag) AND (l_loop_count < BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_MAX_LOOP_COUNT)) LOOP
   SELECT count(1) INTO l_count
   FROM BSC_TAB_IND_GROUPS_VL
   WHERE UPPER(trim(name)) = UPPER(l_tab_grp_name)
         AND IND_GROUP_ID <> p_tab_grp_id;

   IF (l_count = 0) THEN
    l_flag := FALSE;
   ELSE
    l_alias      := get_Next_Alias(l_alias);
    l_loop_count := l_loop_count + 1;    --prevent infinite loop should alias exhausted
    --prevent overflow
    l_overflow := LENGTH(p_tab_grp_name) + LENGTH(l_alias) - l_max_tab_grp_length;
    IF (l_overflow > 0) THEN
      l_tab_grp_name := SUBSTR(p_tab_grp_name, 1, LENGTH(p_tab_grp_name)-l_overflow) || l_alias;
    ELSE
      l_tab_grp_name := p_tab_grp_name || l_alias;
    END IF;
   END IF;
 END LOOP;

 RETURN l_tab_grp_name;

EXCEPTION
 WHEN OTHERS THEN
  RETURN p_tab_grp_name;
END Get_Unqiue_Tab_Group_Name;

-- API to check if the report is S2E or AG Report.

FUNCTION is_Report_S2E(
   p_Region_Function_Name IN VARCHAR2
) RETURN VARCHAR2
IS
  l_Count  NUMBER;
BEGIN

  l_Count  := 0;

  SELECT COUNT(1) INTO l_Count
  FROM   BSC_KPIS_B K
  WHERE  K.SHORT_NAME = p_Region_Function_Name;

  IF l_Count <> 0 THEN
    RETURN 'N';
  END IF;

  RETURN 'Y';

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'N';
END is_Report_S2E;


-- given the objective short_name, tells us if the
-- the Objective was created form Report Designer.
FUNCTION is_Objective_Report_Type (
    p_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
    l_Count  NUMBER;
BEGIN

    IF(p_Short_Name IS NULL) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    SELECT COUNT(1) INTO l_Count
    FROM   BIS_DISPLAY_FORM_FUNC_V B
    WHERE  B.FUNCTION_NAME = p_Short_Name
    AND    B.OBJECT_TYPE   = BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_OBJECT_TYPE_REPORT;
    --//For Simulation Objectives we are creating AG Reports but we don't want it to be projected as
    --//as the report.thats why we are checking the condition that even if form function exists
    --//and the objective config_type is 7then it should be treated as an objective not as a report.

    IF (l_Count <> 0) THEN
        SELECT COUNT(0)
        INTO   l_Count
        FROM   bsc_kpis_b
        WHERE  short_name = p_Short_Name
        AND    config_Type =7;
        IF(l_Count <> 0) THEN
          RETURN FND_API.G_FALSE;
        ELSE
         RETURN FND_API.G_TRUE;
        END IF;
    ELSE -- Bug#4476730
        SELECT COUNT(1) INTO l_Count
        FROM   BSC_KPIS_B
        WHERE  SHORT_NAME     = p_Short_Name
        AND    PROTOTYPE_FLAG = BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_DELETED_OBJECTIVE_FLAG; -- deleted flag
        -- bug 5959433 we don't need following condition here
        -- in simulation flow code won't come here
        --AND    config_type =7;

        IF (l_Count <> 0) THEN
            RETURN FND_API.G_TRUE;
        ELSE
            RETURN FND_API.G_FALSE;
        END IF;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_Objective_Report_Type;


-- given the objective short_name, tells us if the
-- the Objective was created from Page Designer/Configure.
FUNCTION is_Objective_Page_Type (
    p_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
    l_Count  NUMBER;
BEGIN
    SELECT COUNT(1) INTO l_Count
    FROM   BIS_DISPLAY_FORM_FUNC_V B
    WHERE  B.FUNCTION_NAME = p_Short_Name
    AND    B.OBJECT_TYPE   = BSC_BIS_CUSTOM_KPI_UTIL_PUB.C_OBJECT_TYPE_PAGE;

    IF (l_Count <> 0) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_Objective_Page_Type;


-- Added for Bug#4369210
FUNCTION Is_Objective_AutoGen_Type (
    p_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
    l_Count          NUMBER;
    l_Region_Code    AK_REGIONS.REGION_CODE%TYPE;
    l_Source_Type    AK_REGIONS.ATTRIBUTE10%TYPE;
BEGIN

    IF (p_Short_Name IS NULL) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    -- we populate the Objective with FUNCTION_NAME of the report.
    l_Region_Code := BIS_PMV_UTIL.GetReportRegion(p_Short_Name);

    SELECT R.ATTRIBUTE10 INTO l_Source_Type
    FROM   AK_REGIONS R
    WHERE  R.REGION_CODE = l_Region_Code;

    IF (l_Source_Type = C_BSC_DATA_SOURCE) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Objective_AutoGen_Type;

/*
 * Moved from BSC_BIS_KPI_CRUD_PUB since it is used by non-BSC too
 * WAM KPI shows the formats in the drop-down from this table.
 */
FUNCTION Get_Format_Mask (
  p_Format_Id NUMBER
) RETURN VARCHAR2 IS

  l_Format_Mask  VARCHAR2(15);
  l_Format_Id    NUMBER;

BEGIN

  l_Format_Id := p_Format_Id;

  -- Check for standard format ids
  IF (p_Format_Id NOT IN (0, 1, 2, 5, 6, 7)) THEN
    l_Format_Id := 0;
  END IF;

  -- Changed the Format Mask to use 0
  SELECT REPLACE(FORMAT,'#','9') FORMAT
    INTO   l_Format_Mask
    FROM   BSC_SYS_FORMATS
    WHERE  FORMAT_ID = l_Format_Id;

  RETURN l_Format_Mask;
END Get_Format_Mask;


END BSC_BIS_CUSTOM_KPI_UTIL_PUB;

/
