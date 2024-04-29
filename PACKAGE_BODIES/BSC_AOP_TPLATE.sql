--------------------------------------------------------
--  DDL for Package Body BSC_AOP_TPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AOP_TPLATE" AS
/* $Header: BSCUAOPB.pls 115.10 2003/06/20 22:24:09 meastmon ship $ */


G_PF_Tbl		BSC_TEMPLATE.Proj_Field_Tbl_Type;
G_PD_Tbl		BSC_TEMPLATE.Proj_Data_Tbl_Type;
G_Cal_Tbl		BSC_TEMPLATE.Cal_Tbl_Type;

/*===========================================================================+
|
|   Name:          Create_Analysis_Options
|
|   Description:   To create analysis options
|
|   History:
|     	02-APR-1999   Alex Yang             Created.
|    12/22/1999	  Henry Camacho	Modified to Model 4.0
+============================================================================*/

Function Create_Analysis_Options
Return Boolean
Is
	l_system_type		varchar2(60);
	is_cross_template	boolean := FALSE;

  	l_num_of_options 	number;
  	l_num_of_data    	number;

	l_debug_stmt		varchar2(2000) := 'DEBUG: ';

Begin

  -- check template type (Tab or Cross)

  Select PROPERTY_VALUE
  Into   l_system_type
  From   BSC_SYS_INIT
  Where  PROPERTY_CODE = 'MODEL_TYPE';

  if (l_system_type = '1') then
    l_num_of_options := 4;
    l_num_of_data    := 4;
  else
    l_num_of_options := 1;
    l_num_of_data    := 1;
  end if;

  G_PF_Tbl.Delete;
  G_PD_Tbl.Delete;

  G_PF_Tbl(0).Measure_id     := 1;
  G_PF_Tbl(0).Measure_col    := 'Amount';
  G_PF_Tbl(0).Operation	     := 'SUM';
  G_PF_Tbl(0).Type	     := 0;
  G_PF_Tbl(0).Min_Actual     := 1000;
  G_PF_Tbl(0).Max_Actual     := 2000;
  G_PF_Tbl(0).Min_Plan 	     := 1000;
  G_PF_Tbl(0).Max_Plan 	     := 2000;
  G_PF_Tbl(0).Style	     := 1;
  G_PF_Tbl(0).Insert_var     := TRUE;

  -- For Cross only

  G_PF_Tbl(1).Measure_id     := 2;
  G_PF_Tbl(1).Measure_col    := 'Completed';
  G_PF_Tbl(1).Operation	     := 'SUM';
  G_PF_Tbl(1).Type	     := 0;
  G_PF_Tbl(1).Min_Actual     := 0;
  G_PF_Tbl(1).Max_Actual     := 1;
  G_PF_Tbl(1).Min_Plan 	     := 0;
  G_PF_Tbl(1).Max_Plan 	     := 1;
  G_PF_Tbl(1).Style	     := 1;
  G_PF_Tbl(1).Insert_var     := TRUE;

  G_PF_Tbl(2).Measure_id     := 3;
  G_PF_Tbl(2).Measure_col    := 'Cost';
  G_PF_Tbl(2).Operation	     := 'SUM';
  G_PF_Tbl(2).Type	     := 0;
  G_PF_Tbl(2).Min_Actual     := 10000;
  G_PF_Tbl(2).Max_Actual     := 15000;
  G_PF_Tbl(2).Min_Plan 	     := 10000;
  G_PF_Tbl(2).Max_Plan 	     := 15000;
  G_PF_Tbl(2).Style	     := 1;
  G_PF_Tbl(2).Insert_var     := TRUE;

  G_PF_Tbl(3).Measure_id     := 4;
  G_PF_Tbl(3).Measure_col    := 'XXX';
  G_PF_Tbl(3).Operation	     := 'SUM';
  G_PF_Tbl(3).Type	     := 0;
  G_PF_Tbl(3).Min_Actual     := 1000;
  G_PF_Tbl(3).Max_Actual     := 2000;
  G_PF_Tbl(3).Min_Plan 	     := 1500;
  G_PF_Tbl(3).Max_Plan 	     := 2000;
  G_PF_Tbl(3).Style	     := 2;
  G_PF_Tbl(3).Insert_var     := TRUE;

  -- Define MPROJ_DATA fields

  G_PD_Tbl(0).Dataset_id   := 1;
  G_PD_Tbl(0).Measure1	   := 1;
  G_PD_Tbl(0).Operation	   := NULL;
  G_PD_Tbl(0).Measure2 	   := NULL;
  G_PD_Tbl(0).Format 	   := 5;
  G_PD_Tbl(0).Color_Method := 1;
  G_PD_Tbl(0).Proj_Flag	   := 1;
  G_PD_Tbl(0).name	   := 'Amount';
  G_PD_Tbl(0).Help	   := 'Amount';
  G_PD_Tbl(0).num_of_calc  := 11;

  -- for Cross only

  G_PD_Tbl(1).Dataset_id   := 2;
  G_PD_Tbl(1).Measure1	   := 2;
  G_PD_Tbl(1).operation	   := NULL;
  G_PD_Tbl(1).Measure2 	   := NULL;
  G_PD_Tbl(1).Format 	   := 0;
  G_PD_Tbl(1).Color_Method := 1;
  G_PD_Tbl(1).Proj_Flag	   := 1;
  G_PD_Tbl(1).name	   := 'Completed';
  G_PD_Tbl(1).Help	   := '% Completed';
  G_PD_Tbl(1).num_of_calc  := 10;

  G_PD_Tbl(2).Dataset_id   := 3;
  G_PD_Tbl(2).Measure1	   := 3;
  G_PD_Tbl(2).Operation	   := NULL;
  G_PD_Tbl(2).Measure2 	   := NULL;
  G_PD_Tbl(2).Format 	   := 5;
  G_PD_Tbl(2).Color_Method := 2;
  G_PD_Tbl(2).Proj_Flag	   := 1;
  G_PD_Tbl(2).name	   := 'Cost';
  G_PD_Tbl(2).Help	   := 'Associated Cost by Project';
  G_PD_Tbl(2).num_of_calc  := 8;

  G_PD_Tbl(3).Dataset_id   := 4;
  G_PD_Tbl(3).Measure1	   := 4;
  G_PD_Tbl(3).operation	   := NULL;
  G_PD_Tbl(3).Measure2 	   := NULL;
  G_PD_Tbl(3).Format 	   := 6;
  G_PD_Tbl(3).Color_Method := 1;
  G_PD_Tbl(3).Proj_Flag	   := 1;
  G_PD_Tbl(3).name	   := 'XXXX';
  G_PD_Tbl(3).Help	   := 'XXXX';
  G_PD_Tbl(3).num_of_calc  := 7;


  if (NOT create_option_relations(l_num_of_options, l_num_of_data)) then
	l_debug_stmt :=  bsc_apps.get_message('BSC_ERROR_CREATE_AO');
	Raise BSC_AOP_ERROR;
  end if;

  Return(TRUE);

EXCEPTION
    WHEN BSC_AOP_ERROR THEN
	BSC_MESSAGE.Add(
		X_Message => l_debug_stmt,
		X_Source  => 'bsc_aop_tplate.create_analysis_options',
		X_Mode    => 'I');

	Return(FALSE);

    WHEN OTHERS THEN
	BSC_MESSAGE.Add(
		X_Message => SQLERRM,
		X_Source => 'bsc_aop_tplate.create_analysis_options',
		X_Mode => 'I');

	BSC_MESSAGE.Add(
		X_Message => l_debug_stmt,
		X_Source  => 'bsc_aop_tplate.create_analysis_options',
		x_type    => 3,
		X_Mode    => 'I');

	Return(FALSE);

End Create_Analysis_Options;


/*===========================================================================+
|
|   Name:          Create_Option_Relations
|
|   Description:   To configue analysis options
|
|   Parameters:
|	x_num_of_options	number of analysis options
|	x_num_of_data		number of data fields
|
|   History:
|     	02-APR-1999   Alex Yang             Created.
|    12/22/1999	  Henry Camacho	Modified to Model 4.0
+============================================================================*/
Function Create_Option_Relations(
		x_num_of_options	IN	Number,
		x_num_of_data		IN	Number
) Return Boolean
Is
	l_debug_stmt		varchar2(2000);
        l_sql			varchar2(32700);
Begin

  G_Cal_Tbl(0).Calculation   := 0;		G_Cal_Tbl(0).EV0     := 2;
  G_Cal_Tbl(1).Calculation   := 1;     		G_Cal_Tbl(1).EV0     := 2;
  G_Cal_Tbl(2).Calculation   := 2;		G_Cal_Tbl(2).EV0     := 2;
  G_Cal_Tbl(3).Calculation   := 3;		G_Cal_Tbl(3).EV0     := 0;
  G_Cal_Tbl(4).Calculation   := 4;	        G_Cal_Tbl(4).EV0     := 0;
  G_Cal_Tbl(5).Calculation   := 5;	        G_Cal_Tbl(5).EV0     := 2;
  G_Cal_Tbl(6).Calculation   := 6;	        G_Cal_Tbl(6).EV0     := 0;
  G_Cal_Tbl(7).Calculation   := 7;	        G_Cal_Tbl(7).EV0     := 0;
  G_Cal_Tbl(8).Calculation   := 8;	        G_Cal_Tbl(8).EV0     := 0;
  G_Cal_Tbl(9).Calculation   := 9;	        G_Cal_Tbl(9).EV0     := 0;
  G_Cal_Tbl(10).Calculation  := 10;		G_Cal_Tbl(10).EV0    := 0;
  G_Cal_Tbl(11).Calculation  := 20;	        G_Cal_Tbl(11).EV0    := 0;



  For i_option in 0 .. (x_num_of_options -1)
  Loop
    l_debug_stmt := 'Insert Into BSC_SYS_MEASURES .. Measure_id=' ||
			to_char(G_PF_Tbl(i_option).Measure_id);
    Insert Into BSC_SYS_MEASURES (
	MEASURE_ID,
 	MEASURE_COL,
 	OPERATION,
 	TYPE,
 	MIN_ACTUAL_VALUE,
 	MAX_ACTUAL_VALUE,
 	MIN_BUDGET_VALUE,
 	MAX_BUDGET_VALUE,
 	RANDOM_STYLE,
        CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE  )
    Values (
  	G_PF_Tbl(i_option).Measure_id,
  	G_PF_Tbl(i_option).Measure_col,
  	G_PF_Tbl(i_option).Operation,
  	G_PF_Tbl(i_option).Type,
  	G_PF_Tbl(i_option).Min_Actual,
  	G_PF_Tbl(i_option).Max_Actual,
  	G_PF_Tbl(i_option).Min_Plan,
  	G_PF_Tbl(i_option).Max_Plan,
  	G_PF_Tbl(i_option).Style,
        1,SYSDATE,1,SYSDATE
    );

    -- create Data Set

    if (G_PF_Tbl(i_option).insert_var) then

	l_debug_stmt := 'Insert Into BSC_DB_MEASURE_COLS_TL .. ' ||
			'field_n=' || G_PF_Tbl(i_option).Measure_col;

	--FEM -Template Translable
    	l_sql := 'INSERT INTO  BSC_DB_MEASURE_COLS_TL '||
		 ' (MEASURE_COL,LANGUAGE,SOURCE_LANG,HELP,MEASURE_GROUP_ID,PROJECTION_ID,MEASURE_TYPE) ' ||
		 'SELECT '||
			''''||G_PF_Tbl(i_option).Measure_col||''' AS MEASURE_COL, '||
			'FEM.LANGUAGE AS LANGUAGE, '||
			'FEM.SOURCE_LANG AS SOURCE_LANG, '||
	 		'SUBSTR(FEM.MEANING,1,50) AS HELP, '||
 			'-1 AS MEASURE_GROUP_ID, '||
			'3 AS PROJECTION_ID, '||
			'NULL AS MEASURE_TYPE '||
		'FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM '||
		'WHERE FEM.LOOKUP_TYPE = ''BSC_TPLATE_TAB_DATASET_NAME'' AND '||
		      'FEM.LOOKUP_CODE = '''||G_PF_Tbl(i_option).Measure_id||'''';
        BSC_APPS.Execute_Immediate(l_sql);
    end if;
  End Loop; -- analysis option loop


  For i_data In 0 .. (x_num_of_data -1)
  Loop
    l_debug_stmt := 'Insert Into BSC_SYS_DATASETS_B .. data_code=' ||
			to_char(G_PD_Tbl(i_data).Dataset_id);

    Insert Into BSC_SYS_DATASETS_B (
	DATASET_ID,
	MEASURE_ID1,
 	OPERATION,
 	MEASURE_ID2,
 	FORMAT_ID,
 	COLOR_METHOD,
 	PROJECTION_FLAG,
        CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE )
    Values (
  	G_PD_Tbl(i_data).Dataset_id,
  	G_PD_Tbl(i_data).Measure1,
  	G_PD_Tbl(i_data).Operation,
  	G_PD_Tbl(i_data).Measure2,
  	G_PD_Tbl(i_data).Format,
  	G_PD_Tbl(i_data).Color_Method,
  	G_PD_Tbl(i_data).Proj_Flag,
        1,SYSDATE,1,SYSDATE
    );

    l_debug_stmt := 'Insert Into BSC_SYS_DATASETS_TL .. data_code=' ||
			to_char(G_PD_Tbl(i_data).Dataset_id);

    l_sql := 'INSERT INTO BSC_SYS_DATASETS_TL (DATASET_ID, LANGUAGE, SOURCE_LANG,'||
             ' NAME, HELP) '||
  	     'SELECT '||
		G_PD_Tbl(i_data).Dataset_id||' AS DATASET_ID, '||
		'FEM.LANGUAGE AS LANGUAGE, '||
		'FEM.SOURCE_LANG AS SOURCE_LANG, '||
		'SUBSTR(FEM.MEANING,1,20) AS NAME, '||
		'SUBSTR(FEM.MEANING,1,80) AS HELP '||
	     'FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM '||
	     'WHERE FEM.LOOKUP_TYPE = ''BSC_TPLATE_TAB_DATASET_NAME'' AND '||
		   'FEM.LOOKUP_CODE = '''||G_PD_Tbl(i_data).Dataset_id||'''';
    BSC_APPS.Execute_Immediate(l_sql);

    For i_proj_calc In 0 .. (G_PD_Tbl(i_data).num_of_calc -1)
    Loop

        l_debug_stmt := 'Insert Into BSC_SYS_DATASET_CALC .. data_code=' ||
			to_char(G_PD_Tbl(i_data).Dataset_id);

	IF G_Cal_Tbl(i_proj_calc).EV0 = 0  THEN
		Insert Into BSC_SYS_DATASET_CALC (
			DATASET_ID,
			DISABLED_CALC_ID
	        )
		Values (
			G_PD_Tbl(i_data).Dataset_id,
			G_Cal_Tbl(i_proj_calc).Calculation
     		);
	END IF;

    End loop; -- calculation field loop

  End Loop; -- analysis option data loop

  Return(TRUE);

EXCEPTION

    WHEN OTHERS THEN
	BSC_MESSAGE.Add(
		X_Message => SQLERRM,
		X_Source => 'bsc_aop_tplate.create_option_relations',
		X_Mode => 'I');

	BSC_MESSAGE.Add(
		X_Message => l_debug_stmt,
		X_Source  => 'bsc_template.create_crx_template',
		x_type    => 3,
		X_Mode    => 'I');

	Return(FALSE);

End Create_Option_Relations;


END BSC_AOP_TPLATE;

/
