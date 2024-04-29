--------------------------------------------------------
--  DDL for Package Body BSC_METADATA_DESC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_METADATA_DESC" as
/* $Header: BSCMDDB.pls 120.0 2005/05/31 18:53 appldev noship $ */

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_METADATA_DESC';
g_db_object                             varchar2(30) := null;

 TYPE Analysis_Group_Rec_Type IS RECORD (
   dependency_flag     BSC_KPI_ANALYSIS_GROUPS.dependency_flag%TYPE
   ,change_dim_set      BSC_KPI_ANALYSIS_GROUPS.change_dim_set%TYPE
 );

TYPE t_Analysis_Group_Rec_tbl IS TABLE OF Analysis_Group_Rec_Type
    INDEX BY BINARY_INTEGER;

g_margin  number;
g_desc_db_flag boolean;
g_row_num  number; -- count the sequence of each row in the metadata description

------------------------------------------------------------------------------
-- SaveText:  This procedure store a log line into the table
------------------------------------------------------------------------------
PROCEDURE SaveText(
 p_Text        IN      varchar2
) IS
  l_source  varchar2(30);
  l_session_id  number;
BEGIN

 l_source := G_PKG_NAME;
 l_session_id := userenv('SESSIONID');
 if g_row_num is null then
    g_row_num := 0;
 end if;
 g_row_num := g_row_num + 1 ;

 INSERT INTO  BSC_MESSAGE_LOGS  (
    SOURCE,
    TYPE,
    MESSAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES(
        l_source,
        0,
        p_Text,
        sysdate,
        l_session_id,
        sysdate,
        l_session_id,
        g_row_num
  );
 commit;

EXCEPTION
  WHEN OTHERS THEN
     raise;

END SaveText;

-- ------------------------------------------------------------------
-- Name: put_line
-- Desc: For now, just a wrapper on top of fnd_file
-- -----------------------------------------------------------------
PROCEDURE put_line(
                p_text			VARCHAR2) IS
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
BEGIN
 if p_text is null or p_text='' then
   return;
 end if;
 l_len:=nvl(length(p_text),0);
 if l_len <=0 then
   return;
 end if;
 while true loop
    l_end:=l_start+250;
   if l_end >= l_len then
     l_end:=l_len;
     last_reached:=true;
   end if;
   /*---------------------------------------------*/
    -- Select Here the Output:
   FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_text, l_start, 250));

   if g_desc_db_flag = true then
      SaveText(substr(p_text, l_start, 250));
   end if;
   -- DBMS_OUTPUT.PUT_LINE(substr(p_text, l_start, 250));
   /*---------------------------------------------*/
   l_start:=l_start+250;
   if last_reached then
     exit;
   end if;
 end loop;
END put_line;

FUNCTION getMargin(margenCharacter VARCHAR2
                , numCharacters NUMBER
) RETURN VARCHAR2 IS
 L_margen   VARCHAR2(20);
 L_index    NUMBER;
BEGIN

 FOR L_index IN 1.. numCharacters -1  LOOP
    L_margen:=L_margen || margenCharacter;
 END LOOP;
 IF margenCharacter = '-' THEN
    L_margen:=L_margen || '> ';
 ELSE
    L_margen:=L_margen || margenCharacter || ' ';
 END IF;
 RETURN L_margen;

 EXCEPTION
    WHEN OTHERS THEN
        put_line(' Error Running BSC_METADATA_DESC.getMargin ');
        put_line(SQLERRM||' ');
        raise;
END getMargin ;

/*--------------------------------------------------------------------------------------*/

PROCEDURE Describe_kpi_DataSeries (
 p_kpi_id              IN      NUMBER
 ,p_Anaysis_option0     IN      NUMBER
 ,p_Anaysis_option1     IN      NUMBER
 ,p_Anaysis_option2     IN      NUMBER
) IS
    l_not_found_msg              VARCHAR2(2000);
    l_not_found_msg2             VARCHAR2(2000);
    l_not_found_msg3             VARCHAR2(2000);

    l_kpi_id              NUMBER;
    l_Anaysis_option0     NUMBER;
    l_Anaysis_option1     NUMBER ;
    l_Anaysis_option2     NUMBER ;
    l_Dataset_id          NUMBER ;
    l_Measure_id          NUMBER ;

    -------------------------------------
     -- show the relation between Analysis options, Data Series,
     -- Datasets and Dimension Sets
     CURSOR  c_KPI_Data_Series IS
     SELECT A.series_id, A.Name, A.default_value
            ,A.dataset_id, E.dim_set_id
     FROM BSC_KPI_ANALYSIS_MEASURES_VL  A
          , bsc_db_dataset_dim_sets_v     E
     WHERE  E.INDICATOR         =  A.INDICATOR
        AND E.A0                = A.Analysis_Option0
        AND E.A1                = A.Analysis_Option1
        AND E.A2                = A.Analysis_Option2
        AND E.Series_Id         = A.Series_Id
        AND A.INDICATOR         = l_Kpi_Id
        AND A.Analysis_Option0  = l_Anaysis_option0
        AND A.Analysis_Option1  = l_Anaysis_option1
        AND A.Analysis_Option2 =  l_Anaysis_option2;
    -------------------------------------
     -- Show DataSets and Measure Information
     CURSOR  c_Data_Set IS
     SELECT  A.dataset_id,  A.Name, A.COLOR_METHOD
           ,A.SOURCE ,A.Measure_Id1,
            B.Measure_ID M_FLAG,  B.Short_Name Short_Name1, B.MEASURE_COL, B.SOURCE SOURCE1
           ,A.Measure_Id2
      FROM   BSC_SYS_DATASETS_VL           A
           , BSC_SYS_MEASURES              B
      WHERE B.Measure_ID   (+) = A.Measure_ID1
       AND  A.dataset_id       = l_Dataset_id;
    -------------------------------------
     -- Show Measure Information
     -- Used to show information in the secod measure of the dataset
     CURSOR  c_measure IS
     SELECT Short_Name, MEASURE_COL, SOURCE
     FROM BSC_SYS_MEASURES
     WHERE Measure_ID      = l_Measure_id;

BEGIN
    l_Kpi_Id             :=  p_Kpi_Id;
    l_Anaysis_option0    :=  p_Anaysis_option0;
    l_Anaysis_option1    :=  p_Anaysis_option1;
    l_Anaysis_option2    :=  p_Anaysis_option2;
    if g_margin is null then
        g_margin := 0;
    end if;
    -------------- kpi Data Series
    l_not_found_msg := getMargin('-', g_margin)||'Objective ID <'||l_Kpi_Id
        || '>. There is any Data Series defined in table BSC_KPI_ANALYSIS_MEASURES_VL  for analysis combination <' || l_Anaysis_option0 || '-'
        || l_Anaysis_option1 || '-' || l_Anaysis_option2 || '> in the table BSC_KPI_ANALYSIS_MEASURES_VL ' ;
    FOR bsc_cd IN c_KPI_Data_Series  LOOP
      l_not_found_msg := NULL;
      put_line(getMargin('-', g_margin)||  'SERIES_ID is      <'||bsc_cd.SERIES_ID ||'> ' );
      put_line(getMargin('.', g_margin+2)||'NAME is           <'||bsc_cd.NAME ||'> ' );
      put_line(getMargin('.', g_margin+2)||'DEFAULT_VALUE is  <'||bsc_cd.DEFAULT_VALUE ||'> ' );
      put_line(getMargin('.', g_margin+2)||'DIM_SET_ID is     <'||bsc_cd.DIM_SET_ID ||'> ' );
      put_line(getMargin('.', g_margin+2)||'DATASET_ID is     <'||bsc_cd.DATASET_ID ||'> ' );
    -------------- Sys Data sets
      l_not_found_msg2 := getMargin('-', g_margin+4)||'ERROR. Objective ID <' ||l_Kpi_Id
         || '> assigned to invalid Data Set Id in table BSC_KPI_ANALYSIS_MEASURES_VL.  Dataset Id <'||bsc_cd.DATASET_ID||'> not exitst in table BSC_SYS_DATASETS_VL.' ;
      l_Dataset_id := bsc_cd.DATASET_ID;
      FOR bsc_dset_cd IN c_Data_Set    LOOP
        l_not_found_msg2 := NULL;
        put_line(getMargin('.', g_margin+4)||'NAME (Data set Name)is <'||bsc_dset_cd.NAME ||'> ' );
        put_line(getMargin('.', g_margin+4)||'SOURCE is              <'||bsc_dset_cd.SOURCE ||'> ' );
        put_line(getMargin('.', g_margin+4)||'COLOR_METHOD is        <'||bsc_dset_cd.COLOR_METHOD ||'> ' );
        put_line(getMargin('.', g_margin+4)||'MEASURE_ID1 is         <'||bsc_dset_cd.MEASURE_ID1  ||'> ' );
        put_line(getMargin('.', g_margin+6)||'SHORT_NAME is          <'||bsc_dset_cd.SHORT_NAME1  ||'> ' );
        put_line(getMargin('.', g_margin+6)||'SOURCE is              <'||bsc_dset_cd.SOURCE1  ||'> ' );
        IF bsc_dset_cd.M_FLAG IS NULL THEN
         put_line(getMargin('.', g_margin+6)||'ERROR. Measuare Id     <'||bsc_dset_cd.MEASURE_ID1 ||'> is invalid. I does not exists in BSC_SYS_MEASURES .' );
        END IF;
        IF bsc_dset_cd.MEASURE_ID2 IS NOT NULL THEN
         put_line(getMargin('.', g_margin+6)||'MEASURE_ID2 is         <'||bsc_dset_cd.MEASURE_ID2  ||'> ' );
          l_not_found_msg3  := getMargin('.', g_margin+8)||'ERROR. Measuare Id <'||bsc_dset_cd.MEASURE_ID2 ||'> is invalid. I does not exists in BSC_SYS_MEASURES .' ;
          FOR bsc_m_cd IN c_measure    LOOP
            l_not_found_msg3 := NULL;
            put_line(getMargin('.', g_margin+8)||'SHORT_NAME is          <'||bsc_m_cd.SHORT_NAME  ||'> ' );
            put_line(getMargin('.', g_margin+8)||'MEASURE_COL is         <'||bsc_m_cd.MEASURE_COL  ||'> ' );
            put_line(getMargin('.', g_margin+8)||'SOURCE is              <'||bsc_m_cd.SOURCE  ||'> ' );
          END LOOP;
          IF (l_not_found_msg3 IS NOT NULL) THEN
            put_line(l_not_found_msg3);
          END IF;
        END IF;
      END LOOP;
      IF (l_not_found_msg2 IS NOT NULL) THEN
          put_line(l_not_found_msg2);
      END IF;
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        put_line(' Error Running BSC_METADATA_DESC.Describe_kpi_DataSeries ');
        put_line(SQLERRM||' ');
        raise;

END Describe_kpi_DataSeries;

PROCEDURE Describe_kpi(
 p_kpi_id              IN      NUMBER
) IS
-- DECLARE
    l_KPI_Exception              EXCEPTION;
    l_error_msg                  VARCHAR2(32000);
    l_not_found_msg              VARCHAR2(2000);
    l_not_found_msg2             VARCHAR2(2000);
    l_not_found_msg3             VARCHAR2(2000);

    l_not_Analysis_Options0_msg   VARCHAR2(2000);
    l_not_Analysis_Options1_msg   VARCHAR2(2000);
    l_not_Analysis_Options2_msg   VARCHAR2(2000);
    l_not_Data_Series_msg        VARCHAR2(2000);
    l_not_DataSets_msg           VARCHAR2(2000);
    l_not_Measures_msg           VARCHAR2(2000);

    l_database            VARCHAR2(100);
    l_Kpi_Id              NUMBER;
    l_kpi_group_id        NUMBER;
    l_Dim_set_Id          NUMBER;
    l_Dim_Id              NUMBER;
    l_Dim_Obj_Id          NUMBER;
    l_Analysis_Group_Id   NUMBER;
    l_Parent_Option_Id    NUMBER;
    l_Grandparent_Option  NUMBER;
    l_periodicity_id      NUMBER;
    l_Dim_combination     VARCHAR2(100);

    l_Analysis_Group_Rec_tbl    t_Analysis_Group_Rec_tbl;
    l_Analysis_Group_Rec_Type   Analysis_Group_Rec_Type;
    l_index                         NUMBER;

    -------------------------------------
    CURSOR c_KPI_Info IS
    SELECT Indicator
         , Name
         , Ind_Group_ID
         , Prototype_Flag
         , Indicator_Type
         , Share_Flag
         , Short_Name
         , Source_Indicator
    FROM   BSC_KPIS_VL
    WHERE  Indicator = l_Kpi_Id;
    -------------------------------------
    CURSOR  c_Share_Kpi_Ids IS
    SELECT  indicator
          , Name
          , Short_Name
    FROM    BSC_KPIS_VL
    WHERE   Source_Indicator  =  l_Kpi_Id;
    -------------------------------------
    CURSOR  c_Tab_Ids IS
    SELECT TI.TAB_ID, T.NAME
    FROM  BSC_TAB_INDICATORS TI
      ,BSC_TABS_VL T
    WHERE  TI.INDICATOR = l_Kpi_Id
      AND  T.TAB_ID (+) = TI.TAB_ID;
    -------------------------------------
    CURSOR  c_KPI_Group IS
    SELECT IND_GROUP_ID, NAME, TAB_ID
     FROM BSC_TAB_IND_GROUPS_VL
    WHERE IND_GROUP_ID = l_kpi_group_id
      AND ( TAB_ID = -1 OR TAB_ID IN
       (SELECT TAB_ID FROM BSC_TAB_INDICATORS  WHERE INDICATOR = l_Kpi_Id));
    -------------------------------------
    CURSOR  c_KPI_Responsibilities IS
    SELECT K.RESPONSIBILITY_ID, R.RESPONSIBILITY_NAME
     FROM BSC_USER_KPI_ACCESS K,
          BSC_RESPONSIBILITY_VL R
     WHERE K.INDICATOR = l_Kpi_Id
          AND K.RESPONSIBILITY_ID =  R.RESPONSIBILITY_ID (+);
    -------------------------------------
    CURSOR  c_KPI_Dim_sets IS
     SELECT  DIM_SET_ID, NAME
     FROM BSC_KPI_DIM_SETS_VL
     WHERE INDICATOR = l_Kpi_Id;
    -------------------------------------
    CURSOR  c_KPI_Dimensions IS
     SELECT A.Name, A.Short_Name, B.Dim_Group_Id
        FROM   BSC_SYS_DIM_GROUPS_VL A
            ,  BSC_KPI_DIM_GROUPS    B
        WHERE  A.Dim_Group_Id   (+) = B.Dim_Group_Id
        AND    B.Indicator          = l_Kpi_Id
        AND    B.Dim_Set_Id         = l_Dim_set_Id;
    -------------------------------------
     CURSOR  c_KPI_Dim_obj IS
     SELECT * FROM (
      SELECT A.Name, A.Short_Name, A.Dim_Level_Id, A.Source, B.Level_Table_Name
         ,B.LEVEL_VIEW_NAME, B.LEVEL_PK_COL, B.DIM_LEVEL_INDEX
      FROM   BSC_SYS_DIM_LEVELS_VL  A
         ,  BSC_KPI_DIM_LEVELS_VL  B
         ,  BSC_SYS_DIM_LEVELS_BY_GROUP C
      WHERE  A.Level_Table_Name (+) = B.Level_Table_Name
      AND    C.dim_level_id = nvl(A.dim_level_id, C.dim_level_id)
      AND    B.Indicator            = l_Kpi_Id
      AND    B.Dim_Set_Id           = l_Dim_set_Id
      AND    nvl(C.Dim_Group_Id, l_dim_id )  = l_dim_id
     )
     ORDER BY DIM_LEVEL_INDEX;
    -------------------------------------
     CURSOR  c_KPI_Analysis_Groups IS
     SELECT ANALYSIS_GROUP_ID, DEPENDENCY_FLAG, CHANGE_DIM_SET
     FROM BSC_KPI_ANALYSIS_GROUPS
     WHERE INDICATOR = l_Kpi_Id;
    -------------------------------------
     CURSOR  c_KPI_Analysis_Options0 IS
     SELECT A.ANALYSIS_GROUP_ID, A.OPTION_ID, A.NAME, A.DIM_SET_ID
     FROM BSC_KPI_ANALYSIS_OPTIONS_VL A
     WHERE A.INDICATOR            = l_Kpi_Id
     AND A.ANALYSIS_GROUP_ID      = 0
     AND A.PARENT_OPTION_ID       = 0
     AND A.GRANDPARENT_OPTION_ID  = 0
     ORDER BY OPTION_ID;

     CURSOR  c_KPI_Analysis_Options1 IS
     SELECT A.ANALYSIS_GROUP_ID, A.OPTION_ID, A.NAME, A.DIM_SET_ID
     FROM BSC_KPI_ANALYSIS_OPTIONS_VL A
     WHERE A.INDICATOR            = l_Kpi_Id
     AND A.ANALYSIS_GROUP_ID      = 1
     AND A.PARENT_OPTION_ID       = l_Parent_Option_Id
     AND A.GRANDPARENT_OPTION_ID  = 0
     ORDER BY OPTION_ID;

     CURSOR  c_KPI_Analysis_Options2 IS
     SELECT A.ANALYSIS_GROUP_ID, A.OPTION_ID, A.NAME, A.DIM_SET_ID
     FROM BSC_KPI_ANALYSIS_OPTIONS_VL A
     WHERE A.INDICATOR            = l_Kpi_Id
     AND A.ANALYSIS_GROUP_ID      = 2
     AND A.PARENT_OPTION_ID       = l_Parent_Option_Id
     AND A.GRANDPARENT_OPTION_ID  = l_Grandparent_Option
     ORDER BY OPTION_ID;
    ------------------------------------
/*   data series, Data sets, Measures see procedure
     Describe_kpi_Dataseries
*/
    -------------------------------------
     CURSOR  c_KPI_Periodicities IS
     SELECT PERIODICITY_ID, DISPLAY_ORDER, CURRENT_PERIOD, TARGET_LEVEL
     FROM BSC_KPI_PERIODICITIES A
     WHERE INDICATOR =  l_Kpi_Id;

     CURSOR  c_SYS_Periodicity IS
     SELECT A.NAME, A.PERIODICITY_TYPE, A.PERIOD_TYPE_ID, A.RECORD_TYPE_ID
      ,  A.CALENDAR_ID
      ,  B.NAME CALENDAR_NAME , B.FISCAL_YEAR
     FROM BSC_SYS_PERIODICITIES_VL  A
        , BSC_SYS_CALENDARS_VL     B
     WHERE  A.CALENDAR_ID (+)  = B.CALENDAR_ID
       AND A.PERIODICITY_ID =  l_periodicity_id;

    -------------------------------------
     CURSOR  c_KPI_Calculations IS
     SELECT A.CALCULATION_ID, B.MEANING AS NAME
            ,A.USER_LEVEL0, A.USER_LEVEL1, A.DEFAULT_VALUE
     FROM BSC_LOOKUPS B
         ,BSC_KPI_CALCULATIONS A
     WHERE B.LOOKUP_TYPE = 'BSC_CALCULATION'
       AND A.INDICATOR = l_Kpi_Id
       AND NVL(TO_NUMBER(B.LOOKUP_CODE), A.CALCULATION_ID )  = A.CALCULATION_ID;
    -------------------------------------
     CURSOR  c_KPI_Properties IS
     SELECT PROPERTY_CODE, PROPERTY_VALUE, SECONDARY_VALUE
     FROM BSC_KPI_PROPERTIES
     WHERE INDICATOR = l_Kpi_Id;
    -------------------------------------
     CURSOR  c_KPI_Data_Tables IS
     SELECT PERIODICITY_ID, DIM_SET_ID, LEVEL_COMB
      ,TABLE_NAME, FILTER_CONDITION, MV_NAME, PROJECTION_SOURCE
      ,DATA_SOURCE, SQL_STMT,PROJECTION_DATA
     FROM BSC_KPI_DATA_TABLES
     WHERE INDICATOR =  l_Kpi_Id
     ORDER BY PERIODICITY_ID, DIM_SET_ID, LEVEL_COMB ;
    -------------------------------------

     -- invalide DIM Set ids in table BSC_KPI_DIM_GROUPS
     CURSOR  c_invalide_dim_sets1 IS
     SELECT DISTINCT K.DIM_SET_ID
        FROM   BSC_KPI_DIM_GROUPS K
        WHERE  K.Indicator          = l_Kpi_Id
          AND  K.Dim_Set_Id         NOT IN (
             SELECT  DIM_SET_ID
             FROM BSC_KPI_DIM_SETS_VL
             WHERE INDICATOR = l_Kpi_Id
          );

BEGIN
    l_Kpi_Id  := p_kpi_id;
    put_line('****  METADATA DESCRIPTION OBJECTIVE <'||l_Kpi_Id||'> BEGIN HERE  ****');
    SELECT Name INTO l_database FROM V$DATABASE;
    l_error_msg := '  Objective ID <'||l_Kpi_Id||'> does not exists in '||l_database||' envionment';
    --PART 1 OF INFORMATION, get general information from BSC_KPIS_VL table
    put_line('---------------------------------------------------------------------------');
    put_line('General Objective Information from BSC_KPIS_VL table');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_KPI_Info LOOP
        l_error_msg := NULL;
        put_line('-> INDICATOR (Objective Id) is   <'||bsc_cd.INDICATOR||'>');
        put_line('.... NAME (Objective Name) is    <'||bsc_cd.NAME||'>');
        put_line('.... IND_GROUP_ID is             <'||bsc_cd.IND_GROUP_ID||'>');
        put_line('.... PROTOTYPE_FLAG is           <'||bsc_cd.PROTOTYPE_FLAG||'>');
        put_line('.... INDICATOR_TYPE is           <'||bsc_cd.INDICATOR_TYPE||'>');
        IF (bsc_cd.Share_Flag = 1) THEN
         put_line('.... SHARE_FLAG is           <'||bsc_cd.SHARE_FLAG||'>' ||' <- (This is a Master KPI)' );
        ELSE
         put_line('.... SHARE_FLAG is           <'||bsc_cd.SHARE_FLAG||'>' ||' <- (This is a Shared KPI)' );
         put_line('.... SOURCE_INDICATOR is     <'||bsc_cd.SOURCE_INDICATOR||'>'  );
        END IF;
        put_line('.... SHORT_NAME is           <'||bsc_cd.SHORT_NAME||'>');
        l_kpi_group_id :=bsc_cd.Ind_Group_ID;
    END LOOP;
    IF (l_error_msg IS NOT NULL) THEN
        RAISE l_KPI_Exception;
    END IF;

    l_not_found_msg := '  There is not any Shared Objective';
    put_line('---------------------------------------------------------------------------');
    put_line('Shared Objectives Associated with Objective <'|| l_Kpi_Id||'> :');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd1 IN c_Share_Kpi_Ids LOOP
        l_not_found_msg := null;
        put_line('-> INDICATOR <'||TO_CHAR(bsc_cd1.Indicator)||'>  NAME <'||bsc_cd1.Name||'>  Short Name <'||bsc_cd1.Short_Name||'>');
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    l_not_found_msg := '   Objective <'||l_Kpi_Id||'>  is not associated to any Scorecard ';
    put_line('---------------------------------------------------------------------------');
    put_line('Scorecard Information from BSC_TAB_INDICATORS and BSC_TABS_VL table');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_Tab_Ids LOOP
        l_not_found_msg := NULL;
        put_line('-> TAB_ID (Scorecard Id) is <'||bsc_cd.TAB_ID||'>');
        put_line('.... NAME <'||bsc_cd.NAME||'>');
        IF bsc_cd.NAME IS NULL THEN
           put_line('.... ERROR. Objective assigned to a not existing Scorecard. TAB_ID <'||bsc_cd.TAB_ID||'> does not exist ' );
        END IF;
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    l_not_found_msg := 'ERROR. Objective Id <'||l_Kpi_Id||'> is assigned to a not existing Objective Group ID (IND_GROUP_ID)in table BSC_KPIS_B. Objective Group Id does not exist in BSC_TAB_IND_GROUPS_VL ';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective Group Information from BSC_TAB_IND_GROUPS_VL table:');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_KPI_Group LOOP
        l_not_found_msg := NULL;
        put_line('-> IND_GROUP_ID (Objective Group ID) is <'||bsc_cd.IND_GROUP_ID||'>');
        put_line('.... NAME is                            <'||bsc_cd.NAME||'>');
        put_line('.... TAB_ID (Scorecard ID) is            <'||bsc_cd.TAB_ID||'>');
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    l_not_found_msg := '  ERROR. Objective ID <'||l_Kpi_Id||'> is not assigned to any Responsibility';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective Responsibilities from BSC_USER_KPI_ACCESS table: ');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_KPI_Responsibilities LOOP
        l_not_found_msg := NULL;
        put_line('-> RESPONSIBILITY_ID is <'||bsc_cd.RESPONSIBILITY_ID||'>');
        IF bsc_cd.RESPONSIBILITY_NAME IS NOT NULL THEN
           put_line('.... RESPONSIBILITY_NAME  <'||bsc_cd.RESPONSIBILITY_NAME||'>');
        ELSE
           put_line('.... ERROR. Objective Responsibility ID <'||bsc_cd.RESPONSIBILITY_ID||'> is invalide. Not found in BSC_RESPONSIBILITY_VL.' );
        END IF;
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    --PART 2 OF INFORMATION, get information about dimension sets from BSC_KPI_DIM_SETS_VL table
    l_not_found_msg := ' There is not Dimension Sets defined in  BSC_KPI_DIM_SETS_VL table ';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective Dimension Sets Information from BSC_KPI_DIM_SETS_VL table:');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_KPI_Dim_sets LOOP
      l_not_found_msg := NULL;
      put_line('-> DIM_SET_ID (Dimension Set Id) is    <'||bsc_cd.DIM_SET_ID||'>');
      put_line('.... NAME (Dimension Set Name) is      <'||bsc_cd.NAME||'>');
      --PART 3 OF INFORMATION, get information about dimensions within KPI's Dimension Set in table BSC_KPI_DIM_GROUPS
      l_dim_set_id := bsc_cd.DIM_SET_ID;
      FOR bsc_dim_cd IN c_KPI_Dimensions LOOP
        IF bsc_dim_cd.Name IS NOT NULL THEN
          put_line('---> DIM_GROUP_ID (Dimension Id) is   <'||bsc_dim_cd.DIM_GROUP_ID||'> ');
          put_line('...... NAME (Dimension Name) is       <'||bsc_dim_cd.NAME||'>');
          put_line('...... SHORT_NAME           is        <'||bsc_dim_cd.SHORT_NAME||'>');
          --PART 4 OF INFORMATION, get information about dimension objects within KPI's Dimension Set in table BSC_KPI_DIM_LEVELS_VL
          l_dim_id := bsc_dim_cd.Dim_Group_Id;
          FOR bsc_dim_obj_cd IN c_KPI_Dim_obj LOOP
            IF bsc_dim_obj_cd.Dim_Level_Id IS NOT NULL THEN
              put_line('-----> DIM_LEVEL_ID (Dim. Object Id)is  <'||bsc_dim_obj_cd.DIM_LEVEL_ID||'> ');
              put_line('........ NAME (Dim. Object Name) is     <'||bsc_dim_obj_cd.NAME||'>');
              put_line('........ SHORT_NAME is                  <'||bsc_dim_obj_cd.SHORT_NAME||'>');
              put_line('........ LEVEL_TABLE_NAME is            <'||bsc_dim_obj_cd.LEVEL_TABLE_NAME||'>');
              put_line('........ LEVEL_VIEW_NAME is             <'||bsc_dim_obj_cd.LEVEL_VIEW_NAME||'>');
              put_line('........ LEVEL_PK_COL is                <'||bsc_dim_obj_cd.LEVEL_PK_COL||'>');
              put_line('........ DIM_LEVEL_INDEX is             <'||bsc_dim_obj_cd.DIM_LEVEL_INDEX||'>');
            ELSE
              put_line('-----> DIM_LEVEL_INDEX is               <'||bsc_dim_obj_cd.DIM_LEVEL_INDEX||'>');
              put_line('........ LEVEL_TABLE_NAME is            <'||bsc_dim_obj_cd.LEVEL_TABLE_NAME||'>');
              put_line('........ Error. LEVEL_TABLE_NAME <'||bsc_dim_obj_cd.Level_Table_Name||'> is invalide in table BSC_KPI_DIM_LEVELS_VL'  );
            END IF;
          END LOOP;
        ELSE
          put_line('---> DIM_GROUP_ID (Dimension Id) is  <'||bsc_dim_cd.DIM_GROUP_ID||'> ');
          put_line('....... Error: Invalid Dimension Id  <'||bsc_dim_cd.Dim_Group_Id||'> found in table BSC_KPI_DIM_GROUPS'  );
        END IF;
      END LOOP;
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;
    --PART 5 OF INFORMATION

    l_Analysis_Group_Rec_Type.DEPENDENCY_FLAG := 0;
    l_Analysis_Group_Rec_Type.CHANGE_DIM_SET := NULL;
    l_Analysis_Group_Rec_tbl(0) := l_Analysis_Group_Rec_Type;
    l_Analysis_Group_Rec_tbl(1) := l_Analysis_Group_Rec_Type;
    l_Analysis_Group_Rec_tbl(2) := l_Analysis_Group_Rec_Type;

    -------------- Analsysis Groups General Information.
    l_not_found_msg := '  There is not any Analysis Group defined in table BSC_KPI_ANALYSIS_GROUPS';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective Id <'||l_Kpi_Id||'> Analysis Groups (KPI Groups) Definition:');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_AG_cd IN c_KPI_Analysis_Groups  LOOP
      l_not_found_msg := NULL;
      put_line('-> ANALYSIS_GROUP_ID is  <'||bsc_AG_cd.ANALYSIS_GROUP_ID ||'> ' );
      put_line('... DEPENDENCY_FLAG is  <'||bsc_AG_cd.DEPENDENCY_FLAG ||'> ' );
      put_line('... CHANGE_DIM_SET is   <'||bsc_AG_cd.CHANGE_DIM_SET ||'> ' );

      l_Analysis_Group_Rec_Type.DEPENDENCY_FLAG := bsc_AG_cd.DEPENDENCY_FLAG;
      l_Analysis_Group_Rec_Type.CHANGE_DIM_SET := bsc_AG_cd.CHANGE_DIM_SET;
       l_Analysis_Group_Rec_tbl(bsc_AG_cd.ANALYSIS_GROUP_ID) := l_Analysis_Group_Rec_Type;

    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    -----------Analysis Options Structur
    put_line('---------------------------------------------------------------------------');
    put_line('Objective ID <'||l_Kpi_Id||'> Analysis Options (KPIs) - Datasets - Measures - Dim. Sets ');
    put_line('---------------------------------------------------------------------------');
    l_not_Analysis_Options0_msg := 'Objective Id <'||l_Kpi_Id||'> does not have any Analysis Option Defined for Group ID <0>  IN Table BSC_KPI_ANALYSIS_OPTIONS_VL';
    FOR bsc_AO0_cd IN c_KPI_Analysis_Options0   LOOP
      l_not_Analysis_Options0_msg := NULL;
      put_line('-> ANALYSIS_GROUP_ID <'||bsc_AO0_cd.ANALYSIS_GROUP_ID ||'> - OPTION_ID <'||bsc_AO0_cd.OPTION_ID ||'> '  );
      put_line('.... NAME is  <'||bsc_AO0_cd.NAME ||'> ' );
      IF l_Analysis_Group_Rec_tbl(0).CHANGE_DIM_SET = 1 THEN
       put_line('.... DIM_SET_ID is   <'||bsc_AO0_cd.DIM_SET_ID ||'> ' );
      END IF;
      -----------Analysis Options 1
      l_not_Analysis_Options1_msg := 'Objective Id <'||l_Kpi_Id||'> does not have any Analysis Option Defined for Group ID <1>  IN Table BSC_KPI_ANALYSIS_OPTIONS_VL';
      IF l_Analysis_Group_Rec_tbl(1).DEPENDENCY_FLAG = 1  THEN
          l_Parent_Option_Id :=  bsc_AO0_cd.OPTION_ID;
      ELSE
          l_Parent_Option_Id :=  0;
      END IF;
      FOR bsc_AO1_cd IN c_KPI_Analysis_Options1   LOOP
        l_not_Analysis_Options1_msg := NULL;
        put_line('---> ANALYSIS_GROUP_ID <'||bsc_AO1_cd.ANALYSIS_GROUP_ID ||'> - OPTION_ID <'||bsc_AO1_cd.OPTION_ID ||'> '  );
        put_line('...... NAME is  <'||bsc_AO1_cd.NAME ||'> ' );
        IF l_Analysis_Group_Rec_tbl(1).CHANGE_DIM_SET = 1 THEN
         put_line('..... DIM_SET_ID is   <'||bsc_AO1_cd.DIM_SET_ID ||'> ' );
        END IF;
        -----------Analysis Options 2
        l_not_Analysis_Options2_msg := 'Objective Id <'||l_Kpi_Id||'> does not have any Analysis Option Defined for Group ID <2>  IN Table BSC_KPI_ANALYSIS_OPTIONS_VL';
        IF l_Analysis_Group_Rec_tbl(2).DEPENDENCY_FLAG = 1  THEN
           l_Parent_Option_Id :=  bsc_AO1_cd.OPTION_ID;
        ELSE
           l_Parent_Option_Id :=  0;
        END IF;
        IF l_Analysis_Group_Rec_tbl(1).DEPENDENCY_FLAG = 1  THEN
           l_Grandparent_Option :=  bsc_AO0_cd.OPTION_ID;
        ELSE
           l_Grandparent_Option :=  0;
        END IF;
        FOR bsc_AO2_cd IN c_KPI_Analysis_Options2   LOOP
          l_not_Analysis_Options2_msg := NULL;
          put_line('-----> ANALYSIS_GROUP_ID <'||bsc_AO2_cd.ANALYSIS_GROUP_ID ||'> - OPTION_ID <'||bsc_AO2_cd.OPTION_ID ||'> '  );
          put_line('........ NAME is  <'||bsc_AO2_cd.NAME ||'> ' );
          IF l_Analysis_Group_Rec_tbl(2).CHANGE_DIM_SET = 1 THEN
           put_line('........ DIM_SET_ID is   <'||bsc_AO2_cd.DIM_SET_ID ||'> ' );
          END IF;
          g_margin := 8;
          Describe_kpi_DataSeries (
               p_kpi_id               => l_kpi_id
               ,p_Anaysis_option0     => bsc_AO0_cd.OPTION_ID
               ,p_Anaysis_option1     => bsc_AO1_cd.OPTION_ID
               ,p_Anaysis_option2     => bsc_AO2_cd.OPTION_ID
          );
        END LOOP;
        IF (l_not_Analysis_Options2_msg IS NOT NULL) THEN
           -- put_line(l_not_Analysis_Options1_msg);
          g_margin := 6;
          Describe_kpi_DataSeries (
               p_kpi_id               => l_kpi_id
               ,p_Anaysis_option0     => bsc_AO0_cd.OPTION_ID
               ,p_Anaysis_option1     => bsc_AO1_cd.OPTION_ID
               ,p_Anaysis_option2     => 0
          );
         END IF;
      END LOOP;
      IF (l_not_Analysis_Options1_msg IS NOT NULL) THEN
        --put_line(l_not_Analysis_Options1_msg);
        g_margin := 4;
        Describe_kpi_DataSeries (
             p_kpi_id               => l_kpi_id
             ,p_Anaysis_option0     => bsc_AO0_cd.OPTION_ID
             ,p_Anaysis_option1     => 0
             ,p_Anaysis_option2     => 0
        );
     END IF;
    END LOOP;
    IF (l_not_Analysis_Options0_msg IS NOT NULL) THEN
      put_line(l_not_Analysis_Options0_msg);
    END IF;

    -------------- kpi Periodicites Information.
    l_not_found_msg := '  There is not any Periodicity defined in table BSC_KPI_PERIODICITIES ';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective ID <'||l_Kpi_Id||'> Periodicities: ');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_KPI_Periodicities   LOOP
      l_not_found_msg := NULL;
      put_line('-> PERIODICITY_ID is  <'||bsc_cd.PERIODICITY_ID ||'> ' );
    -------------- Sys Periodicites Information.
      l_periodicity_id := bsc_cd.PERIODICITY_ID;
      l_not_found_msg2 := '--> ERROR. Objective ID <' ||l_Kpi_Id || '> assigned to invalide periodicity in table BSC_KPI_PERIODICITIES.  Periodicity Id <' ||l_periodicity_id  || '> not exitst in table BSC_SYS_PERIODICITIES_VL' ;
      FOR bsc_Per_cd IN c_SYS_Periodicity   LOOP
        l_not_found_msg2 := NULL;
        put_line('.... PERIODICITY_NAME is  <'||bsc_Per_cd.NAME ||'> ' );
        put_line('.... PERIODICITY_TYPE is  <'||bsc_Per_cd.PERIODICITY_TYPE ||'> ' );
        put_line('.... PERIOD_TYPE_ID is  <'||bsc_Per_cd.PERIOD_TYPE_ID  ||'> ' );
        put_line('.... RECORD_TYPE_ID is  <'||bsc_Per_cd.RECORD_TYPE_ID ||'> ' );
        put_line('.... CALENDAR_ID is  <'||bsc_Per_cd.CALENDAR_ID ||'> ' );
        IF bsc_Per_cd.CALENDAR_NAME IS NOT NULL THEN
           put_line('...... CALENDAR_NAME is  <'||bsc_Per_cd.CALENDAR_NAME  ||'> ' );
           put_line('...... FISCAL_YEAR is  <'||bsc_Per_cd.FISCAL_YEAR  ||'> ' );
        ELSE
           put_line('...... ERROR. Periodicity Id <'||l_periodicity_id||'> assigned to a invalide Calendar Id in table BSC_SYS_PERIODICITIES_VL . Calendar Id <' ||  bsc_Per_cd.CALENDAR_ID || '> does not exists IN TABLE BSC_SYS_CALENDARS_VL. ' );
        END IF;
      END LOOP;
      IF (l_not_found_msg2 IS NOT NULL) THEN
          put_line(l_not_found_msg2);
      END IF;
      put_line('.. CURRENT_PERIOD,  is  <'||bsc_cd.CURRENT_PERIOD  ||'> ' );
      put_line('.. TARGET_LEVEL is   <'||bsc_cd.TARGET_LEVEL ||'> ' );
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    --- kpi Calculations ------------------------------------------------------------
    l_not_found_msg := '  There is not any Calculations Metadata defined in table BSC_KPI_CALCULATIONS';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective ID <'||l_Kpi_Id||'> Calculations Definition: ');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_KPI_Calculations LOOP
        l_not_found_msg := NULL;
        put_line('-> CALCULATION_ID is      <'||bsc_cd.CALCULATION_ID||'>' );
        put_line('.... NAME is              <'||bsc_cd.NAME|| '>' );
        put_line('.... DEFAULT_VALUE is     <'||bsc_cd.DEFAULT_VALUE|| '>' );

    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    --- kpi Properties -------------------------------------------------------
    l_not_found_msg := '  There is not any KPI Properties defined in table BSC_KPI_PROPERTIES';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective ID <'||l_Kpi_Id||'> Properties from table BSC_KPI_PROPERTIES ');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_KPI_Properties LOOP
        l_not_found_msg := NULL;
        put_line('-> PROPERTY_CODE is       <'||bsc_cd.PROPERTY_CODE||'>' );
        put_line('.... PROPERTY_VALUE is    <'||bsc_cd.PROPERTY_VALUE||'>' );
        put_line('.... SECONDARY_VALUE is   <'||bsc_cd.SECONDARY_VALUE||'>' );
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    --- kpi Data Tables Definition--------------------------------------------
    l_not_found_msg := '  There is not any Data Table Defined in table c_KPI_Data_Tables';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective ID <'||l_Kpi_Id||'>  Data Tables Definition: ');
    put_line('---------------------------------------------------------------------------');

    l_periodicity_id := -999;
    FOR bsc_cd IN c_KPI_Data_Tables LOOP
        l_not_found_msg := NULL;
        IF  bsc_cd.PERIODICITY_ID <> l_periodicity_id then
         put_line('-> PERIODICITY_ID is       <'||bsc_cd.PERIODICITY_ID||'>' );
         l_periodicity_id :=  bsc_cd.PERIODICITY_ID;
         l_Dim_set_Id  := -999;
        END IF;
        IF bsc_cd.DIM_SET_ID <> l_Dim_set_Id then
         put_line('--> DIM_SET_ID is          <'||bsc_cd.DIM_SET_ID||'>' );
         l_Dim_set_Id := bsc_cd.DIM_SET_ID;
         l_Dim_combination := '-999';
        END IF;
        IF  bsc_cd.LEVEL_COMB <> l_Dim_combination then
         put_line('-----> LEVEL_COMB is       <'||bsc_cd.LEVEL_COMB||'>' );
         l_Dim_combination := bsc_cd.LEVEL_COMB;
        END IF;
        put_line('........ TABLE_NAME is        <'||bsc_cd.TABLE_NAME||'>' );
        put_line('........ MV_NAME is           <'||bsc_cd.MV_NAME||'>' );
        put_line('........ FILTER_CONDITION is  <'||bsc_cd.FILTER_CONDITION||'>' );
        put_line('........ PROJECTION_SOURCE is <'||bsc_cd.PROJECTION_SOURCE||'>' );
        put_line('........ DATA_SOURCE is       <'||bsc_cd.DATA_SOURCE||'>' );
        put_line('........ SQL_STMT is          <'||bsc_cd.SQL_STMT||'>' );
        put_line('........ PROJECTION_DATA is   <'||bsc_cd.PROJECTION_DATA||'>' );
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    --PART 6 OF INFORMATION INVALIDE METADATA
    l_not_found_msg := '  Invalide Metadata not found.';
    put_line('---------------------------------------------------------------------------');
    put_line('Objective ID <'||l_Kpi_Id||'> Additional Invalide KPI Metadata: ');
    put_line('---------------------------------------------------------------------------');
    FOR bsc_cd IN c_invalide_dim_sets1 LOOP
        l_not_found_msg := NULL;
        put_line('  Invalide Dimension Set ID <'||bsc_cd.DIM_SET_ID||'> in BSC_KPI_DIM_GROUPS table ' );
    END LOOP;
    IF (l_not_found_msg IS NOT NULL) THEN
        put_line(l_not_found_msg);
    END IF;

    put_line('****  METADATA DESCRIPTION OBJECTIVE <'||l_Kpi_Id||'> END  HERE  ****');


EXCEPTION
    WHEN l_KPI_Exception THEN
        put_line('Error Running BSC_METADATA_DESC.Describe_kpi');
        put_line(l_error_msg);
        put_line('**** INDICATOR DETAILS ENDS HERE ****');
    WHEN OTHERS THEN
        put_line('Error Running BSC_METADATA_DESC.Describe_kpi');
        put_line(SQLERRM||' <'||l_error_msg||'>');
        put_line('**** INDICATOR DETAILS ENDS HERE ****');
--END;
--/
END Describe_kpi;

/*===========================================================================+
| PROCEDURE Run_Concurrent_ARU_Files
+============================================================================*/
PROCEDURE Run_Concurrent_Describe_kpi (
    ERRBUF     OUT NOCOPY VARCHAR2
	,RETCODE    OUT NOCOPY VARCHAR2
    ,p_kpi_id   IN         NUMBER
) IS

BEGIN

  Describe_kpi(p_kpi_id);

EXCEPTION
    WHEN OTHERS THEN
        put_line('Error at BSC_METADATA_DESC.Run_Concurrent_Describe_kpi');
        put_line('ERRBUF: ' || SQLERRM);
        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors

END Run_Concurrent_Describe_kpi;

/*------------------------------------------------------------------------------------------
-- ClearMessages:  This procedure delete all row of metadata description from
    the table BSC_MESSAGE_LOGS that had been created by the currrent session.
    Additional delete all metadata description not created in the current day
-------------------------------------------------------------------------------------------*/
PROCEDURE ClearText IS
  l_session_id  number;
BEGIN

   l_session_id := userenv('SESSIONID');

   DELETE FROM BSC_MESSAGE_LOGS
   WHERE SOURCE = G_PKG_NAME
   AND ( CREATED_BY  = l_session_id
         OR CREATION_DATE <= (SYSDATE -1)
        );

   g_row_num := 0;

EXCEPTION
  WHEN OTHERS THEN
    raise;
END ClearText;

/*------------------------------------------------------------------------------
 getQuery:  This procedure store a row of metadata description the table
            BSC_MESSAGE_LOGS
------------------------------------------------------------------------------*/
FUNCTION getQuery RETURN varchar2 is
  l_sql varchar2(500);
  l_session_id  number;
BEGIN
 l_session_id := userenv('SESSIONID');


l_sql := '
   SELECT MESSAGE FROM BSC_MESSAGE_LOGS
   WHERE SOURCE = ''' || G_PKG_NAME || '''
      AND CREATED_BY = ' || l_session_id || '
   ORDER BY LAST_UPDATE_LOGIN ';

return l_sql;

EXCEPTION
  WHEN OTHERS THEN
     raise;

END getQuery;
/*-------------------------------------------------------------------------------
  Describe_kpi
       Get the KPI (objective) information from the me metadata tables and made
       a description of the objective metadat which is stored temporaty in
       the database.
       It return the query needed to get the metadata description
-------------------------------------------------------------------------------*/
PROCEDURE Describe_kpi(
  p_kpi_id              IN             NUMBER
 ,x_query               OUT NOCOPY     varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) IS
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;
 g_desc_db_flag := true;
 -- Clear Previous Metadata Description from the database
 ClearText;
 -- Process the Kpi Metadata
 Describe_kpi( p_kpi_id => p_kpi_id);
 -- Build the query to get the metadata description
 x_query := getQuery;
 g_desc_db_flag := false;

 EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_METADATA_DESC.Describe_kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_METADATA_DESC.Describe_kpi ';
        END IF;

END Describe_kpi ;

End BSC_METADATA_DESC;

/
