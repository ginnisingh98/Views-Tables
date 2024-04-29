--------------------------------------------------------
--  DDL for Package Body BSC_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_TEMPLATE" AS
/* $Header: BSCUTMPB.pls 120.1 2006/02/07 12:19:15 hcamacho noship $ */


/*===========================================================================+
|
|   Name:          Create_Template
|
|   Description:   Main entry from KPI designer
|
|   Parameters:
|	x_template_name	   template name
|	x_template_type	   template type, 6 for Tab and 1 for Cross
|	x_sys_name	   OBSC system name
|	x_sys_desc	   OBSC system description
|	x_sys_help	   Help text
|	x_debug_flag	   debug_flag, default is 'NO'
|
+============================================================================*/
Procedure Create_Template (
 		x_template_name		IN	Varchar2,
		x_template_type		IN	Number,
		x_sys_name		IN	Varchar2,
		x_sys_desc		IN	Varchar2,
		x_sys_help		IN	Varchar2,
		x_debug_flag		IN	Varchar2 := 'NO'
) Is
	l_sys_type	Varchar2(60);
        l_message	Varchar2(200);
Begin

  BSC_MESSAGE.Init(X_Debug_Flag => X_Debug_Flag);

  -- Init app varaibles
  bsc_apps.init_bsc_apps;

  -- Init lookup table names, remove personal option
  -- Apps
   LOOKUP_VALUES_TABLE := 'FND_LOOKUP_VALUES';

  Select PROPERTY_VALUE
  Into l_sys_type
  From BSC_SYS_INIT
  Where PROPERTY_CODE = 'MODEL_TYPE';

  -- DBMS_OUTPUT.PUT_LINE('sys_type=' || l_sys_type);

  if (l_sys_type <> '-1') then
      l_message := bsc_apps.get_message('BSC_TEMPLATE_EXIST');
      Raise BSC_DEF_ERROR;
  end if;

  -- set system name

  Update BSC_SYS_INIT
  Set    PROPERTY_VALUE = x_sys_name  , LAST_UPDATED_BY =2,LAST_UPDATE_DATE=SYSDATE
  Where  PROPERTY_CODE = 'SYSTEM_NAME';

  Update BSC_SYS_INIT
  Set    PROPERTY_VALUE = to_char(x_template_type),LAST_UPDATED_BY =2,LAST_UPDATE_DATE=SYSDATE
  Where  PROPERTY_CODE = 'MODEL_TYPE';


  if (x_template_type = 6) then

      if (NOT BSC_Tab_Tplate.Create_Tab_Template) then
          l_message := 'System Error: BSC_Tab_Tplate.Create_Tab_Template()';
	  Raise BSC_SYS_ERROR;
      end if;
  else
      l_message := bsc_apps.get_message('BSC_INVALID_TEMPLATE');
      l_message := bsc_apps.replace_token(l_message,'TEMPLATE_TYPE', to_char(x_template_type));
      Raise BSC_DEF_ERROR;
  end if;

Exception
    When BSC_DEF_ERROR Then
	BSC_MESSAGE.Add(
		X_Message => l_message,
		X_Source => 'bsc_template.create_template',
		X_Mode => 'I');

    When BSC_SYS_ERROR Then
	BSC_MESSAGE.Add(
		X_Message => l_message,
		X_Source  => 'bsc_template.create_template',
		X_Mode    => 'I');

    When OTHERS Then
	BSC_MESSAGE.Add(
		X_Message => SQLERRM,
		X_Source => 'bsc_template.create_template',
		X_Mode => 'I');

End Create_Template;


/*===========================================================================+
|
|   Name:          Restore_Init_Layout
|
|   Description:   Rollback changes if error occurs during template creation
|
|   Parameters:
|	x_template_name	   template name
|	x_template_type	   template type, 6 for Tab and 1 for Cross
|	x_debug_flag	   debug_flag, default is 'NO'
|
|	HCC 12/21/99 	   Data model 4.0
+============================================================================*/
Procedure  Restore_Init_Layout(
 		x_template_name		IN	Varchar2,
		x_template_type		IN	Number,
		x_debug_flag		IN	Varchar2 := 'NO'
) Is
	l_count			number;
	l_cursor 		number;
    	l_ignore 		number;
	l_sql_stmt		varchar2(2000);
	l_debug_stmt		varchar2(2000);
        l_message		Varchar2(200);
	l_panel0_count		number := 0;
        l_panel1_count		number := 0;
	l_project_count		number := 0;

Begin

  l_debug_stmt := 'Deleting from BSC_SYS_DATASET_CALC table';
  Delete From BSC_SYS_DATASET_CALC Where DATASET_ID <> -1;

  l_debug_stmt := 'Deleting from BSC_SYS_DATASETS_TL table';
  Delete From BSC_SYS_DATASETS_TL  Where DATASET_ID <> -1;

  l_debug_stmt := 'Deleting from BSC_SYS_DATASETS_B table';
  Delete From BSC_SYS_DATASETS_B Where DATASET_ID <> -1;

  l_debug_stmt := 'Deleting from BSC_DB_MEASURE_COLS_TL table';
  Delete From BSC_DB_MEASURE_COLS_TL where MEASURE_COL <> 'Default_Field';

  l_debug_stmt := 'Deleting from BSC_SYS_MEASURES table';
  Delete From BSC_SYS_MEASURES where MEASURE_ID <> -1;

  l_debug_stmt := 'Deleting from BSC_SYS_DIM_LEVELS_BY_GROUP table';
  Delete From BSC_SYS_DIM_LEVELS_BY_GROUP;

  l_debug_stmt := 'Deleting from BSC_SYS_DIM_GROUPS_TL table';
  Delete From BSC_SYS_DIM_GROUPS_TL;

--*  l_debug_stmt := 'Deleting from MPROJ_DRILLS_FAMILIES table';
--*  Delete From MPROJ_DRILLS_FAMILIES;

  l_debug_stmt := 'Deleting from BSC_SYS_DIM_LEVEL_RELS';
  Delete From BSC_SYS_DIM_LEVEL_RELS;

  l_debug_stmt := 'Deleting from BSC_SYS_DIM_LEVELS_TL table';
  Delete From BSC_SYS_DIM_LEVELS_TL;

  l_debug_stmt := 'Deleting from BSC_SYS_DIM_LEVELS_B table';
  Delete From BSC_SYS_DIM_LEVELS_B;

  l_debug_stmt := 'Deleting from BSC_SYS_DIM_LEVEL_COLS table';
  Delete From BSC_SYS_DIM_LEVEL_COLS;

  l_debug_stmt := 'Deleting from BSC_KPI_DIM_GROUPS table';
  Delete From BSC_KPI_DIM_GROUPS;

  l_debug_stmt := 'Deleting from BSC_KPI_DIM_LEVEL_PROPERTIES table';
  Delete From BSC_KPI_DIM_LEVEL_PROPERTIES;

  -- for Tab only
  l_debug_stmt := 'Deleting from BSC_TAB_INDICATORS table';
  Delete From  BSC_TAB_INDICATORS;

  l_debug_stmt := 'Deleting from BSC_KPI_DATA_TABLES table';
  Delete From  BSC_KPI_DATA_TABLES ;

  l_debug_stmt := 'Deleting from BSC_KPI_PERIODICITIES table';
  Delete From  BSC_KPI_PERIODICITIES ;

  l_debug_stmt := 'Deleting from BSC_KPI_ANALYSIS_OPTIONS_B table';
  Delete From  BSC_KPI_ANALYSIS_OPTIONS_B ;

  l_debug_stmt := 'Deleting from BSC_KPI_ANALYSIS_OPTIONS_TL table';
  Delete From  BSC_KPI_ANALYSIS_OPTIONS_TL ;

  l_debug_stmt := 'Deleting from BSC_KPI_DIM_LEVELS_TL table';
  Delete From  BSC_KPI_DIM_LEVELS_TL ;

  l_debug_stmt := 'Deleting from BSC_KPI_DIM_LEVELS_B table';
  Delete From  BSC_KPI_DIM_LEVELS_B ;

  l_debug_stmt := 'Deleting from BSC_KPI_DIM_SETS_TL table';
  Delete From  BSC_KPI_DIM_SETS_TL ;

  l_debug_stmt := 'Deleting from BSC_KPI_ANALYSIS_MEASURES_B table';
  Delete From  BSC_KPI_ANALYSIS_MEASURES_B;

  l_debug_stmt := 'Deleting from BSC_KPI_ANALYSIS_MEASURES_TL table';
  Delete From  BSC_KPI_ANALYSIS_MEASURES_TL;

  l_debug_stmt := 'Deleting from BSC_KPI_CALCULATIONS table';
  Delete From  BSC_KPI_CALCULATIONS ;

  l_debug_stmt := 'Deleting from BSC_KPI_ANALYSIS_GROUPS table';
  Delete From  BSC_KPI_ANALYSIS_GROUPS;

  l_debug_stmt := 'Deleting from BSC_KPI_DEFAULTS_TL table';
  Delete From  BSC_KPI_DEFAULTS_TL ;

  l_debug_stmt := 'Deleting from BSC_KPI_DEFAULTS_B table';
  Delete From  BSC_KPI_DEFAULTS_B ;

  l_debug_stmt := 'Deleting from BSC_KPIS_TL table';
  Delete From  BSC_KPIS_TL;

  l_debug_stmt := 'Deleting from BSC_KPI_PROPERTIES table';
  Delete From  BSC_KPI_PROPERTIES;

  l_debug_stmt := 'Deleting from BSC_KPIS_B table';
  Delete From  BSC_KPIS_B ;


  -- for Tab only
  l_debug_stmt := 'Deleting from BSC_SYS_LINES table';
  Delete From  BSC_SYS_LINES ;

  l_debug_stmt := 'Deleting from BSC_SYS_USER_OPTIONS table';
  Delete From  BSC_SYS_USER_OPTIONS;

  l_debug_stmt := 'Deleting from BSC_TAB_IND_GROUPS_B table';
  Delete From  BSC_TAB_IND_GROUPS_B;

  l_debug_stmt := 'Deleting from BSC_TAB_IND_GROUPS_TL table';
  Delete From  BSC_TAB_IND_GROUPS_TL;


  l_debug_stmt := 'Deleting from BSC_TAB_CSF_B table';
  Delete From  BSC_TAB_CSF_B;

  l_debug_stmt := 'Deleting from BSC_TAB_CSF_TL table';
  Delete From  BSC_TAB_CSF_TL;

  l_debug_stmt := 'Deleting from BSC_TABS_B table';
  Delete From  BSC_TABS_B;

  l_debug_stmt := 'Deleting from BSC_TABS_TL table';
  Delete From  BSC_TABS_TL;


  l_debug_stmt := 'Updating BSC_SYS_INIT.MODEL_TYPE';
  Update BSC_SYS_INIT Set PROPERTY_VALUE= '-1',LAST_UPDATED_BY =2,LAST_UPDATE_DATE=SYSDATE
  Where  PROPERTY_CODE= 'MODEL_TYPE';


  l_debug_stmt := 'Updating BSC_SYS_INIT.SYSTEM_NAME';
  Update BSC_SYS_INIT Set PROPERTY_VALUE= 'NoSystem',LAST_UPDATED_BY =2,LAST_UPDATE_DATE=SYSDATE
  Where  PROPERTY_CODE= 'SYSTEM_NAME';


  Select count(*)
  Into   l_count
  From   User_Tables
  Where  table_name = 'BSC_D_TYPE_OF_ACCOUNT';

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_D_TYPE_OF_ACCOUNT';
      l_debug_stmt := l_sql_stmt;

      l_cursor := DBMS_SQL.Open_Cursor;
      DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
      l_ignore := DBMS_SQL.Execute(l_cursor);
      DBMS_SQL.Close_Cursor(l_cursor);
  end if;

  Select count(*)
  Into   l_count
  From   User_Tables
  Where  table_name = 'BSC_D_ACCOUNT';

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_D_ACCOUNT';
      l_debug_stmt := l_sql_stmt;

      l_cursor := DBMS_SQL.Open_Cursor;
      DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
      l_ignore := DBMS_SQL.Execute(l_cursor);
      DBMS_SQL.Close_Cursor(l_cursor);
  end if;

  Select count(*)
  Into   l_count
  From   User_Tables
  Where  table_name = 'BSC_D_SUBACCOUNT';

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_D_SUBACCOUNT';
      l_debug_stmt := l_sql_stmt;

      l_cursor := DBMS_SQL.Open_Cursor;
      DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
      l_ignore := DBMS_SQL.Execute(l_cursor);
      DBMS_SQL.Close_Cursor(l_cursor);
  end if;

  if (x_template_type = 1) then  -- Cross system

      Select count(*)
      Into   l_project_count
      From   User_Tables
      Where  table_name = 'BSC_D_PROJECT';

      if (l_project_count <> 0) then

          l_sql_stmt := 'Drop Table BSC_D_PROJECT';
          l_debug_stmt := l_sql_stmt;

     	  l_cursor := DBMS_SQL.Open_Cursor;
          DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
          l_ignore := DBMS_SQL.Execute(l_cursor);
          DBMS_SQL.Close_Cursor(l_cursor);

      end if;

  END IF;


Exception
    When BSC_DEF_ERROR Then
	BSC_MESSAGE.Add(
		X_Message => l_message,
		X_Source => 'bsc_template.restore_init_layout',
		X_Mode => 'I');

    When OTHERS Then
	BSC_MESSAGE.Add(
		X_Message => SQLERRM,
		X_Source => 'bsc_template.restore_init_layout',
		X_Mode => 'I');

End Restore_Init_Layout;


END BSC_TEMPLATE;

/
