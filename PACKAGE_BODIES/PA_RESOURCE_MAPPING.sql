--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_MAPPING" AS
/* $Header: PARSMAPB.pls 120.6 2005/09/08 05:25:46 appldev noship $ */

  -- Global variables -----------------------------------
  g_pa_schema             VARCHAR2(30);

  --g_tmp_id is used to identify if source table is TMP1/2
  g_tmp_id                NUMBER := 1;

  --g_run_number is used to identify records in TMP4 in the
  --current run (avoids illegal ROWID deletes)
  g_run_number            NUMBER := 1;

  --The following 2 variables represent the current resource
  --list and format being processed
  g_resource_list_id      NUMBER;
  g_res_format_id         NUMBER;

  g_project_id            NUMBER; --bug#3576766

  --This flag indicates if resource list is centrally controlled
  --or not
  g_control_flag          VARCHAR2(1);


  ---------------------------------
  --Gets the Projects Schema name
  ---------------------------------
  FUNCTION get_pa_schema_name RETURN VARCHAR2 IS

    l_status            VARCHAR2(30);
    l_industry          VARCHAR2(30);
    excp_get_app_info   EXCEPTION;

  BEGIN

    IF (g_pa_schema IS NULL) THEN

      IF (NOT FND_INSTALLATION.GET_APP_INFO('PA', l_status, l_industry, g_pa_schema)) THEN
        RAISE excp_get_app_info;
      END IF;

    END IF;

    RETURN g_pa_schema;

  END GET_PA_SCHEMA_NAME; --end function get_pa_schema name

  ----------------------------------------
  --Gets the SQL tags for the resource
  --format element tokens
  --Operation types allowed - TMP3, TMP4
  ---------------------------------------
  FUNCTION get_SQL_tags (
    p_resource_token VARCHAR2,
    p_operation_type VARCHAR2, --INSERT, FROM, SELECT, WHERE1, WHERE2
    p_mode           VARCHAR2 DEFAULT 'TMP'
  ) RETURN VARCHAR2 IS

    l_str VARCHAR2(50);

  BEGIN

    --Get the resource element based on pre-defined tokens
    IF p_operation_type = 'INSERT' OR
       p_operation_type = 'SELECT' OR
       p_operation_type = 'FROM' THEN

       IF p_operation_type = 'SELECT' THEN
         l_str := 'tab1.';
       ELSE
         l_str := ' ';
       END IF;

      IF p_resource_token = 'PER' THEN
        RETURN l_str || 'PERSON_ID';
      ELSIF p_resource_token = 'FN1' THEN
        RETURN l_str || 'EXPENDITURE_TYPE ,' || l_str || 'FC_RES_TYPE_CODE'; --bug#3779049
      ELSIF p_resource_token = 'FN2' THEN
        RETURN l_str || 'EVENT_TYPE ,' || l_str || 'FC_RES_TYPE_CODE'; --bug#3779049
      ELSIF p_resource_token = 'FN3' THEN
        RETURN l_str || 'EXPENDITURE_CATEGORY ,' || l_str || 'FC_RES_TYPE_CODE'; --bug#3779049
      ELSIF p_resource_token = 'FN4' THEN
        RETURN l_str || 'REVENUE_CATEGORY ,' || l_str || 'FC_RES_TYPE_CODE'; --bug#3779049
      ELSIF p_resource_token = 'ROL' THEN
        RETURN l_str || 'PROJECT_ROLE_ID ,' || l_str || 'NAMED_ROLE';
      ELSIF p_resource_token = 'ORG' THEN
        RETURN l_str || 'ORGANIZATION_ID';
      ELSIF p_resource_token = 'BML' THEN
        RETURN l_str || 'BOM_RESOURCE_ID';
      ELSIF p_resource_token = 'BME' THEN
        RETURN l_str || 'BOM_RESOURCE_ID';
      ELSIF p_resource_token = 'JOB' THEN
        RETURN l_str || 'JOB_ID';
      ELSIF p_resource_token = 'PTP' THEN
        RETURN l_str || 'PERSON_TYPE_CODE';
      ELSIF p_resource_token = 'VND' THEN
        RETURN l_str || 'VENDOR_ID';
      ELSIF p_resource_token = 'NLB' THEN
        RETURN l_str || 'NON_LABOR_RESOURCE';
      ELSIF p_resource_token = 'ITM' THEN
        RETURN l_str || 'INVENTORY_ITEM_ID';
      ELSIF p_resource_token = 'ITC' THEN
        RETURN l_str || 'ITEM_CATEGORY_ID';
      ELSIF p_resource_token = 'IR1' THEN
        RETURN l_str || 'PERSON_ID';
      ELSIF p_resource_token = 'IR2' THEN
        RETURN l_str || 'JOB_ID';
      ELSIF p_resource_token = 'IR3' THEN
        RETURN l_str || 'PROJECT_ROLE_ID ,' || l_str || 'NAMED_ROLE';
      ELSIF p_resource_token = 'IR4' THEN
        RETURN l_str || 'PERSON_TYPE_CODE';
      -- bug#3608042 ELSIF p_resource_token = 'IR5' THEN
      -- bug#3608042  RETURN l_str || 'RESOURCE_CLASS_ID';
      ELSIF p_resource_token = 'PEP'
            OR  p_resource_token = 'EQP'
            OR  p_resource_token = 'MTL'
            OR  p_resource_token = 'FNL' THEN

        RETURN l_str || 'RESOURCE_CLASS_ID';

      END IF;

    ELSIF p_operation_type = 'WHERE1' THEN

      --Where clause for equi-joins
      IF p_resource_token = 'PER' THEN
        RETURN ' tab1.PERSON_ID = tab2.PERSON_ID';
      ELSIF p_resource_token = 'FN1' THEN
	l_str := '''EXPENDITURE_TYPE'' ';
        IF Pa_Resource_Mapping.g_called_process ='ACTUALS' THEN
	  RETURN ' tab1.EXPENDITURE_TYPE = tab2.EXPENDITURE_TYPE '; --bug#3779049
        ELSE --bug#4318046
          RETURN ' tab1.EXPENDITURE_TYPE = tab2.EXPENDITURE_TYPE AND tab1.FC_RES_TYPE_CODE = ' || l_str || ' and tab1.FC_RES_TYPE_CODE = tab2.FC_RES_TYPE_CODE '; --bug#3779049
        END IF;
      ELSIF p_resource_token = 'FN2' THEN
	l_str := '''EVENT_TYPE'' ';
        IF Pa_Resource_Mapping.g_called_process ='ACTUALS' THEN
	  RETURN ' tab1.EVENT_TYPE = tab2.EVENT_TYPE '; --bug#3779049
        ELSE --bug#4318046
          RETURN ' tab1.EVENT_TYPE = tab2.EVENT_TYPE AND tab1.FC_RES_TYPE_CODE = ' || l_str || ' and tab1.FC_RES_TYPE_CODE = tab2.FC_RES_TYPE_CODE '; --bug#3779049
        END IF;
      ELSIF p_resource_token = 'FN3' THEN
	l_str := '''EXPENDITURE_CATEGORY'' ';
        IF Pa_Resource_Mapping.g_called_process ='ACTUALS' THEN
	  RETURN ' tab1.EXPENDITURE_CATEGORY = tab2.EXPENDITURE_CATEGORY '; --bug#3779049
        ELSE --bug#4318046
          RETURN ' tab1.EXPENDITURE_CATEGORY = tab2.EXPENDITURE_CATEGORY AND tab1.FC_RES_TYPE_CODE = ' || l_str || ' and tab1.FC_RES_TYPE_CODE = tab2.FC_RES_TYPE_CODE ';
        END IF;
      ELSIF p_resource_token = 'FN4' THEN
	l_str := '''REVENUE_CATEGORY'' ';
        IF Pa_Resource_Mapping.g_called_process ='ACTUALS' THEN
		RETURN ' tab1.REVENUE_CATEGORY = tab2.REVENUE_CATEGORY '; --bug#3779049
        ELSE --bug#4318046

		RETURN ' tab1.REVENUE_CATEGORY = tab2.REVENUE_CATEGORY AND tab1.FC_RES_TYPE_CODE = ' || l_str || ' and tab1.FC_RES_TYPE_CODE = tab2.FC_RES_TYPE_CODE '; --bug#3779049
        END IF;
      ELSIF p_resource_token = 'ROL' THEN
        IF p_mode = 'TMP' THEN
          RETURN ' tab1.PROJECT_ROLE_ID = tab2.PROJECT_ROLE_ID AND tab1.NAMED_ROLE = tab2.NAMED_ROLE';
        ELSIF p_mode = 'TMP3' THEN
          RETURN ' tab1.PROJECT_ROLE_ID = tab2.PROJECT_ROLE_ID AND tab1.NAMED_ROLE = tab2.TEAM_ROLE';
        END IF;
      ELSIF p_resource_token = 'ORG' THEN
        RETURN ' tab1.ORGANIZATION_ID = tab2.ORGANIZATION_ID';
      ELSIF p_resource_token = 'BML' THEN
        IF p_mode = 'TMP' THEN
          RETURN ' tab1.BOM_RESOURCE_ID = tab2.BOM_RESOURCE_ID'; --bug#3608042
        ELSIF p_mode = 'TMP3' THEN
          RETURN ' tab1.BOM_RESOURCE_ID = tab2.BOM_RESOURCE_ID';
        END IF;
      ELSIF p_resource_token = 'BME' THEN
        IF p_mode = 'TMP' THEN
          RETURN ' tab1.BOM_RESOURCE_ID = tab2.BOM_RESOURCE_ID'; --bug#3608042
        ELSIF p_mode = 'TMP3' THEN
          RETURN ' tab1.BOM_RESOURCE_ID = tab2.BOM_RESOURCE_ID';
        END IF;
      ELSIF p_resource_token = 'JOB' THEN
        RETURN ' tab1.JOB_ID = tab2.JOB_ID';
      ELSIF p_resource_token = 'PTP' THEN
        RETURN ' tab1.PERSON_TYPE_CODE = tab2.PERSON_TYPE_CODE';
      ELSIF p_resource_token = 'VND' THEN
        RETURN ' tab1.VENDOR_ID = tab2.VENDOR_ID';
      ELSIF p_resource_token = 'NLB' THEN
        RETURN ' tab1.NON_LABOR_RESOURCE = tab2.NON_LABOR_RESOURCE';
      ELSIF p_resource_token = 'ITM' THEN
        RETURN ' tab1.INVENTORY_ITEM_ID = tab2.INVENTORY_ITEM_ID';
      ELSIF p_resource_token = 'ITC' THEN
        RETURN ' tab1.ITEM_CATEGORY_ID = tab2.ITEM_CATEGORY_ID';
      ELSIF p_resource_token = 'IR1' THEN
        RETURN ' tab1.PERSON_ID = tab2.PERSON_ID';
      ELSIF p_resource_token = 'IR2' THEN
        RETURN ' tab1.JOB_ID = tab2.JOB_ID';
      ELSIF p_resource_token = 'IR3' THEN
        IF p_mode = 'TMP' THEN
          RETURN ' tab1.PROJECT_ROLE_ID = tab2.PROJECT_ROLE_ID AND tab1.NAMED_ROLE = tab2.NAMED_ROLE';
        ELSIF p_mode = 'TMP3' THEN
          RETURN ' tab1.PROJECT_ROLE_ID = tab2.PROJECT_ROLE_ID AND tab1.NAMED_ROLE = tab2.TEAM_ROLE';
        END IF;
      ELSIF p_resource_token = 'IR4' THEN
        RETURN ' tab1.PERSON_TYPE_CODE = tab2.PERSON_TYPE_CODE';
      -- bug#3608042 ELSIF p_resource_token = 'IR5' THEN
      -- bug#3608042  RETURN ' tab1.RESOURCE_CLASS_ID = tab2.RESOURCE_CLASS_ID';
      ELSIF p_resource_token = 'PEP' THEN
        RETURN ' tab1.RESOURCE_CLASS_ID = tab2.RESOURCE_CLASS_ID';
      ELSIF p_resource_token = 'EQP' THEN
        RETURN ' tab1.RESOURCE_CLASS_ID = tab2.RESOURCE_CLASS_ID';
      ELSIF p_resource_token = 'MTL' THEN
        RETURN ' tab1.RESOURCE_CLASS_ID = tab2.RESOURCE_CLASS_ID';
      ELSIF p_resource_token = 'FNL' THEN
        RETURN ' tab1.RESOURCE_CLASS_ID = tab2.RESOURCE_CLASS_ID';
      END IF;

    ELSIF p_operation_type = 'WHERE2' THEN

      --Where clause for NOT NULLS
      IF p_resource_token = 'PER' THEN
        RETURN ' tab1.PERSON_ID IS NOT NULL';
      ELSIF p_resource_token = 'FN1' THEN
        RETURN ' tab1.EXPENDITURE_TYPE IS NOT NULL AND tab1.FC_RES_TYPE_CODE IS NOT NULL '; --bug#3779049
      ELSIF p_resource_token = 'FN2' THEN
        RETURN ' tab1.EVENT_TYPE IS NOT NULL AND tab1.FC_RES_TYPE_CODE IS NOT NULL '; --bug#3779049
      ELSIF p_resource_token = 'FN3' THEN
        RETURN ' tab1.EXPENDITURE_CATEGORY IS NOT NULL AND tab1.FC_RES_TYPE_CODE IS NOT NULL '; --bug#3779049
      ELSIF p_resource_token = 'FN4' THEN
        RETURN ' tab1.REVENUE_CATEGORY IS NOT NULL AND tab1.FC_RES_TYPE_CODE IS NOT NULL '; --bug#3779049
      ELSIF p_resource_token = 'ROL' THEN
        RETURN ' tab1.PROJECT_ROLE_ID IS NOT NULL AND tab1.NAMED_ROLE IS NOT NULL';
      ELSIF p_resource_token = 'ORG' THEN
        RETURN ' tab1.ORGANIZATION_ID IS NOT NULL';
      ELSIF p_resource_token = 'BML' THEN
        RETURN ' tab1.BOM_RESOURCE_ID IS NOT NULL';
      ELSIF p_resource_token = 'BME' THEN
        RETURN ' tab1.BOM_RESOURCE_ID IS NOT NULL';
      ELSIF p_resource_token = 'JOB' THEN
        RETURN ' tab1.JOB_ID IS NOT NULL';
      ELSIF p_resource_token = 'PTP' THEN
        RETURN ' tab1.PERSON_TYPE_CODE IS NOT NULL';
      ELSIF p_resource_token = 'VND' THEN
        RETURN ' tab1.VENDOR_ID IS NOT NULL';
      ELSIF p_resource_token = 'NLB' THEN
        RETURN ' tab1.NON_LABOR_RESOURCE IS NOT NULL';
      ELSIF p_resource_token = 'ITM' THEN
        RETURN ' tab1.INVENTORY_ITEM_ID IS NOT NULL';
      ELSIF p_resource_token = 'ITC' THEN
        RETURN ' tab1.ITEM_CATEGORY_ID IS NOT NULL';
      ELSIF p_resource_token = 'IR1' THEN
        RETURN ' tab1.PERSON_ID IS NOT NULL';
      ELSIF p_resource_token = 'IR2' THEN
        RETURN ' tab1.JOB_ID IS NOT NULL';
      ELSIF p_resource_token = 'IR3' THEN
        RETURN ' tab1.PROJECT_ROLE_ID IS NOT NULL AND tab1.NAMED_ROLE IS NOT NULL';
      ELSIF p_resource_token = 'IR4' THEN
        RETURN ' tab1.PERSON_TYPE_CODE IS NOT NULL';
      -- bug#3608042 ELSIF p_resource_token = 'IR5' THEN
      -- bug#3608042  RETURN ' tab1.RESOURCE_CLASS_ID IS NOT NULL';
      ELSIF p_resource_token = 'PEP' THEN
        RETURN ' tab1.RESOURCE_CLASS_ID = 1';
      ELSIF p_resource_token = 'EQP' THEN
        RETURN ' tab1.RESOURCE_CLASS_ID = 2';
      ELSIF p_resource_token = 'MTL' THEN
        RETURN ' tab1.RESOURCE_CLASS_ID = 3';
      ELSIF p_resource_token = 'FNL' THEN
        RETURN ' tab1.RESOURCE_CLASS_ID = 4';
      END IF; --end p_resource_token

    END IF;--end p_operation_type
  END; --end function get_SQL_tags

  -------------------------------------
  --Get token for a given format
  --Token refers to the resource type
  --identifiers which are part of the
  --format
  -------------------------------------
  FUNCTION get_format_res_tokens (
    p_resource_class_id IN NUMBER,
    p_eff_res_format_id     IN NUMBER
  ) RETURN SYSTEM.pa_varchar2_30_tbl_type IS

    l_plan_res_formats PA_RESOURCE_PREC_PUB.plan_res_formats;
    l_format           pa_plan_res_format;
    l_token_string     VARCHAR2(30);
    l_tokens SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

  BEGIN

    --Get all resource tokens for a given effective format
    IF p_resource_class_id = 1 THEN
      l_plan_res_formats := PA_RESOURCE_PREC_PUB.g_people_formats;
    ELSIF p_resource_class_id = 2 THEN
      l_plan_res_formats := PA_RESOURCE_PREC_PUB.g_equipment_formats;
    ELSIF p_resource_class_id = 3 THEN
      l_plan_res_formats := PA_RESOURCE_PREC_PUB.g_material_formats;
    ELSIF p_resource_class_id = 4 THEN
      l_plan_res_formats := PA_RESOURCE_PREC_PUB.g_fin_element_formats;
    END IF;

    l_format := l_plan_res_formats (p_eff_res_format_id);
    l_token_string := l_format.res_tokens;
    g_res_format_id := l_format.res_format_id;

    FOR i IN 0..MOD(LENGTH(l_token_string),3) LOOP

      l_tokens.EXTEND;
      l_tokens (i + 1) := SUBSTR(l_token_string, i*4 + 1, 3);

    END LOOP;

    RETURN l_tokens;

  END;--end procedure get_format_res_tokens

  ----------------------------------------------
  --Generate the INSERT clause for the current
  --format used in mapping
  --Operation types allowed - TMP3, TMP4
  ----------------------------------------------
  FUNCTION get_insert_clause (
    p_resource_class_id NUMBER,
    p_res_format_id     NUMBER,
    p_operation_type    VARCHAR2
  ) RETURN VARCHAR2 IS

    l_insert_clause VARCHAR2(4000);
    l_res_tokens SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type ();

  BEGIN

    --Generate the INSERT clause for the
    --given format and operation type
    IF p_operation_type = 'TMP3' THEN

      l_insert_clause := 'INSERT INTO pa_res_list_map_tmp3 ( RES_FORMAT_ID, RESOURCE_LIST_MEMBER_ID, RES_LIST_MEM_SEQ, ';
      l_res_tokens  := get_format_res_tokens (p_resource_class_id, p_res_format_id);

      FOR i IN 1..l_res_tokens.COUNT LOOP

        IF i <> l_res_tokens.COUNT THEN

          l_insert_clause := l_insert_clause || get_SQL_tags (l_res_tokens(i), 'INSERT') || ', ';

        ELSE

          l_insert_clause := l_insert_clause || get_SQL_tags (l_res_tokens(i), 'INSERT') || ' ';

        END IF;


      END LOOP; --end loop l_ers_tokens

      l_insert_clause := l_insert_clause || ') ';

    ELSIF  p_operation_type = 'TMP4' THEN

      --Generate insert clause
      l_insert_clause := ' INSERT INTO pa_res_list_map_tmp4 (PERSON_ID,JOB_ID,ORGANIZATION_ID,VENDOR_ID,'
       || 'EXPENDITURE_TYPE,EVENT_TYPE,NON_LABOR_RESOURCE,EXPENDITURE_CATEGORY,'
       || 'REVENUE_CATEGORY,NON_LABOR_RESOURCE_ORG_ID,EVENT_TYPE_CLASSIFICATION,'
       || 'SYSTEM_LINKAGE_FUNCTION,PROJECT_ROLE_ID,RESOURCE_TYPE_ID,'
       || 'RESOURCE_TYPE_CODE,RESOURCE_CLASS_ID,RESOURCE_CLASS_CODE,RES_FORMAT_ID,'
       || 'MFC_COST_TYPE_ID,RESOURCE_CLASS_FLAG,FC_RES_TYPE_CODE,'
       || 'BOM_LABOR_RESOURCE_ID,BOM_EQUIP_RESOURCE_ID,INVENTORY_ITEM_ID,'
       || 'ITEM_CATEGORY_ID,PERSON_TYPE_CODE,BOM_RESOURCE_ID,NAMED_ROLE,'
       || 'INCURRED_BY_RES_FLAG,TXN_COPY_FROM_RL_FLAG,TXN_SPREAD_CURVE_ID,'
       || 'TXN_ETC_METHOD_CODE,TXN_OBJECT_TYPE,TXN_OBJECT_ID,TXN_PROJECT_ID,'
       || 'TXN_BUDGET_VERSION_ID,TXN_RESOURCE_LIST_MEMBER_ID,TXN_RESOURCE_ID,'
       || 'TXN_ALIAS,TXN_TRACK_AS_LABOR_FLAG,TXN_FUNDS_CONTROL_LEVEL_CODE,'
       || 'TXN_SOURCE_ID,TXN_SOURCE_TYPE_CODE,TXN_PROCESS_CODE,TXN_ERROR_MSG_CODE,'
       || 'TXN_TASK_ID,TXN_WBS_ELEMENT_VERSION_ID,TXN_RBS_ELEMENT_ID,'
       || 'TXN_RBS_ELEMENT_VERSION_ID,TXN_PLANNING_START_DATE,TXN_PLANNING_END_DATE,'
       || 'TXN_RECORD_VERSION_NUMBER,TXN_SP_FIXED_DATE,TXN_RATE_BASED_FLAG,'
       || 'TXN_RES_CLASS_BILL_RATE_SCH_ID,TXN_RES_CLASS_COST_SCH_ID,'
       || 'TXN_USE_PLANNING_RATES_FLAG,TXN_BILL_JOB_GROUP_ID,'
       || 'TXN_PROJECT_CURRENCY_CODE,TXN_PROJFUNC_CURRENCY_CODE,'
       || 'TXN_EMP_BILL_RATE_SCHEDULE_ID,TXN_JOB_BILL_RATE_SCHEDULE_ID,'
       || 'TXN_LABOR_BILL_RATE_ORG_ID,TXN_LABOR_SCH_TYPE,TXN_LABOR_SCHEDULE_DISCOUNT,'
       || 'TXN_LABOR_SCHEDULE_FIXED_DATE,TXN_LABOR_STD_BILL_RATE_SCHDL,'
       || 'TXN_CURRENCY_CODE,TXN_PLAN_QUANTITY,RESOURCE_LIST_MEMBER_ID, TMP_ROWID) ';

    END IF;--end operation type

    RETURN l_insert_clause;

  END;--end function get_insert_clause

  ----------------------------------------------
  --Generate the SELECT clause for the current
  --format used in mapping
  --Operation types allowed - TMP3, TMP4
  --p_run_number - used to identify txns that
  --have already been moved from TMP1/2 -> TMP4
  --p_run_number along with ROWID ensures
  --uniqueness
  ----------------------------------------------
  FUNCTION get_select_clause (
    p_resource_class_id NUMBER,
    p_res_format_id     NUMBER,
    p_operation_type    VARCHAR2
  ) RETURN VARCHAR2 IS

    l_select_clause VARCHAR2(5000);
    l_res_tokens SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type ();

  BEGIN

    --Generate the SELECT clause for the
    --given format and operation type
    IF p_operation_type = 'TMP3' THEN

      l_select_clause := ' SELECT ' || g_res_format_id || ', tab2.RESOURCE_LIST_MEMBER_ID,'
                         || 'DECODE(tab2.RESOURCE_LIST_MEMBER_ID,NULL,pa_resource_list_members_s.NEXTVAL,NULL), ' ;
      l_res_tokens  := get_format_res_tokens (p_resource_class_id, p_res_format_id);

      FOR i IN 1..l_res_tokens.COUNT LOOP

        l_select_clause := l_select_clause || get_SQL_tags (l_res_tokens(i), 'SELECT');

        IF i <> l_res_tokens.COUNT THEN

          l_select_clause := l_select_clause || ', ';

        ELSE

          l_select_clause := l_select_clause || ' ';

        END IF;

      END LOOP; --end loop l_res_tokens

      RETURN l_select_clause;

    ELSIF  p_operation_type = 'TMP4' THEN

      --Generate select clause
      l_select_clause := ' SELECT tab1.PERSON_ID,tab1.JOB_ID,tab1.ORGANIZATION_ID,tab1.VENDOR_ID,';
      l_select_clause := l_select_clause || 'tab1.EXPENDITURE_TYPE,tab1.EVENT_TYPE,tab1.NON_LABOR_RESOURCE,';
      l_select_clause := l_select_clause || 'tab1.EXPENDITURE_CATEGORY,tab1.REVENUE_CATEGORY,';
      l_select_clause := l_select_clause || 'tab1.NON_LABOR_RESOURCE_ORG_ID,tab1.EVENT_TYPE_CLASSIFICATION,';
      l_select_clause := l_select_clause || 'tab1.SYSTEM_LINKAGE_FUNCTION,tab1.PROJECT_ROLE_ID,tab1.RESOURCE_TYPE_ID,';
      l_select_clause := l_select_clause || 'tab1.RESOURCE_TYPE_CODE,tab1.RESOURCE_CLASS_ID,tab1.RESOURCE_CLASS_CODE,';
      l_select_clause := l_select_clause || 'tab2.RES_FORMAT_ID,tab1.MFC_COST_TYPE_ID,tab1.RESOURCE_CLASS_FLAG,';
      l_select_clause := l_select_clause || 'tab1.FC_RES_TYPE_CODE,tab1.BOM_LABOR_RESOURCE_ID,';
      l_select_clause := l_select_clause || 'tab1.BOM_EQUIP_RESOURCE_ID,tab1.INVENTORY_ITEM_ID,tab1.ITEM_CATEGORY_ID,';
      l_select_clause := l_select_clause || 'tab1.PERSON_TYPE_CODE,tab1.BOM_RESOURCE_ID,tab1.NAMED_ROLE,';
      l_select_clause := l_select_clause || 'tab1.INCURRED_BY_RES_FLAG,tab1.TXN_COPY_FROM_RL_FLAG,';
      l_select_clause := l_select_clause || 'tab1.TXN_SPREAD_CURVE_ID,tab1.TXN_ETC_METHOD_CODE,tab1.TXN_OBJECT_TYPE,';
      l_select_clause := l_select_clause || 'tab1.TXN_OBJECT_ID,tab1.TXN_PROJECT_ID,tab1.TXN_BUDGET_VERSION_ID,';
      l_select_clause := l_select_clause || 'tab1.TXN_RESOURCE_LIST_MEMBER_ID,tab1.TXN_RESOURCE_ID,tab1.TXN_ALIAS,';
      l_select_clause := l_select_clause || 'tab1.TXN_TRACK_AS_LABOR_FLAG,tab1.TXN_FUNDS_CONTROL_LEVEL_CODE,';
      l_select_clause := l_select_clause || 'tab1.TXN_SOURCE_ID,tab1.TXN_SOURCE_TYPE_CODE,tab1.TXN_PROCESS_CODE,';
      l_select_clause := l_select_clause || 'tab1.TXN_ERROR_MSG_CODE,tab1.TXN_TASK_ID,tab1.TXN_WBS_ELEMENT_VERSION_ID,';
      l_select_clause := l_select_clause || 'tab1.TXN_RBS_ELEMENT_ID,tab1.TXN_RBS_ELEMENT_VERSION_ID,';
      l_select_clause := l_select_clause || 'tab1.TXN_PLANNING_START_DATE,tab1.TXN_PLANNING_END_DATE,';
      l_select_clause := l_select_clause || 'tab1.TXN_RECORD_VERSION_NUMBER,tab1.TXN_SP_FIXED_DATE,';
      l_select_clause := l_select_clause || 'tab1.TXN_RATE_BASED_FLAG,tab1.TXN_RES_CLASS_BILL_RATE_SCH_ID,';
      l_select_clause := l_select_clause || 'tab1.TXN_RES_CLASS_COST_SCH_ID,tab1.TXN_USE_PLANNING_RATES_FLAG,';
      l_select_clause := l_select_clause || 'tab1.TXN_BILL_JOB_GROUP_ID,tab1.TXN_PROJECT_CURRENCY_CODE,';
      l_select_clause := l_select_clause || 'tab1.TXN_PROJFUNC_CURRENCY_CODE,tab1.TXN_EMP_BILL_RATE_SCHEDULE_ID,';
      l_select_clause := l_select_clause || 'tab1.TXN_JOB_BILL_RATE_SCHEDULE_ID,tab1.TXN_LABOR_BILL_RATE_ORG_ID,';
      l_select_clause := l_select_clause || 'tab1.TXN_LABOR_SCH_TYPE,tab1.TXN_LABOR_SCHEDULE_DISCOUNT,';
      l_select_clause := l_select_clause || 'tab1.TXN_LABOR_SCHEDULE_FIXED_DATE,tab1.TXN_LABOR_STD_BILL_RATE_SCHDL,';
      l_select_clause := l_select_clause || 'tab1.TXN_CURRENCY_CODE,tab1.TXN_PLAN_QUANTITY,';
      l_select_clause := l_select_clause || 'NVL(tab2.RESOURCE_LIST_MEMBER_ID,tab2.RES_LIST_MEM_SEQ),';
      l_select_clause := l_select_clause || 'tab1.ROWID';

      RETURN l_select_clause;

    END IF;--end operation type

  END;--end function get_select_clause

  ----------------------------------------------
  --Generate the FROM clause for the current
  --format used in mapping
  --Operation types allowed - TMP3, TMP4
  ----------------------------------------------
  FUNCTION get_from_clause (
    p_resource_class_id NUMBER,
    p_res_format_id     NUMBER,
    p_operation_type    VARCHAR2,
    p_src_table         VARCHAR2
  ) RETURN VARCHAR2 IS

    l_from_clause VARCHAR2(1000);
    l_res_tokens SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type ();

  BEGIN

    --Generate the FROM clause for the
    --given format and operation type
    IF p_operation_type = 'TMP3' THEN

      l_from_clause  := ' FROM (SELECT DISTINCT tab1.RES_FORMAT_ID, ' ;
      l_res_tokens := get_format_res_tokens (p_resource_class_id, p_res_format_id);

      FOR i IN 1..l_res_tokens.COUNT LOOP

        l_from_clause := l_from_clause || get_SQL_tags (l_res_tokens(i), 'FROM');

        IF i <> l_res_tokens.COUNT THEN

          l_from_clause := l_from_clause || ', ';

        END IF;

        END LOOP; --end loop l_res_tokens

      l_from_clause := l_from_clause || ' FROM ' || p_src_table || ' tab1 where resource_class_id = ' || p_resource_class_id;
      l_from_clause := l_from_clause || ' ) tab1, pa_resource_list_members tab2 ';

      RETURN l_from_clause;

    ELSIF  p_operation_type = 'TMP4' THEN

      --Generate from clause
      l_from_clause := ' FROM ' || p_src_table || ' tab1, pa_res_list_map_tmp3 tab2';

      RETURN l_from_clause;

    END IF;--end operation type

  END;--end function get_from_clause

  ----------------------------------------------
  --Generate the WHERE clause for the current
  --format used in mapping
  --Operation types allowed - TMP3, TMP4
  ----------------------------------------------
  FUNCTION get_where_clause (
    p_resource_class_id NUMBER,
    p_res_format_id     NUMBER,
    p_operation_type    VARCHAR2
  ) RETURN VARCHAR2 IS

    l_where_clause VARCHAR2(2000);
    l_res_tokens SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type ();

    l_pos NUMBER;	 --bug#3799207

  BEGIN

    --Generate the WHERE clause for the
    --given format and operation type
    IF p_operation_type = 'TMP3' THEN

      l_where_clause := ' WHERE ';
      l_res_tokens := get_format_res_tokens (p_resource_class_id, p_res_format_id);

      FOR i IN 1..l_res_tokens.COUNT LOOP

	-- added (+) for bug#3799207, please note below condition handles only one AND in the string if we get
	-- more than one AND we need to handle by writing a function

        IF instr(get_SQL_tags (l_res_tokens(i), 'WHERE1', 'TMP3'), ' AND ') > 0 AND g_control_flag = 'N' THEN
		l_pos := instr(get_SQL_tags (l_res_tokens(i), 'WHERE1', 'TMP3'), ' AND ');
		l_where_clause := l_where_clause || substr(get_SQL_tags (l_res_tokens(i), 'WHERE1', 'TMP3'),1,l_pos) || ' (+) ' || substr(get_SQL_tags (l_res_tokens(i), 'WHERE1', 'TMP3'),l_pos); --EQUI JOIN
        --l_where_clause := l_where_clause || CHR(13)|| CHR(10);
	ELSE
		l_where_clause := l_where_clause || get_SQL_tags (l_res_tokens(i), 'WHERE1', 'TMP3'); --EQUI JOIN
        --l_where_clause := l_where_clause || CHR(13)|| CHR(10);
	END IF;

        --Outer joins are required only when new planning resources need to be
        --identified. If the resource list is centrally controlled and does not
        --allow creation of new planning resources then outer join must not be
        --used. If a planning resource does not exist for the current format
        --proceed to next format. All resource lists have the resource class
        --format and this will ensure that there are no unmapped transactions
        IF g_control_flag = 'N' THEN
          l_where_clause := l_where_clause || ' (+) AND ';
        ELSE
          l_where_clause := l_where_clause || ' AND ';
        END IF;

        l_where_clause := l_where_clause || get_SQL_tags (l_res_tokens(i), 'WHERE2', 'TMP3');--IS NOT NULL

        IF i <> l_res_tokens.COUNT THEN

          l_where_clause := l_where_clause || ' AND ';

        ELSE

          l_where_clause := l_where_clause || ' ';

        END IF;

      END LOOP; --end loop l_res_tokens

      --Below if conditions for control flag is for same reasons
      --as explained above
      l_where_clause := l_where_clause || ' AND tab2.resource_list_id ';
      IF g_control_flag = 'N' THEN
          l_where_clause := l_where_clause || ' (+) ';
      END IF;
      l_where_clause := l_where_clause || '= ' || g_resource_list_id;

      l_where_clause := l_where_clause || ' AND tab2.res_format_id ';
      IF g_control_flag = 'N' THEN
          l_where_clause := l_where_clause || ' (+) ';
      END IF;
      l_where_clause := l_where_clause || '= ' || g_res_format_id;

      --start bug#3576766, null value for g_control_flag is considered as Y

      IF g_control_flag = 'N' THEN
          l_where_clause := l_where_clause || ' AND tab2.object_id (+)  = ' || g_project_id;
      ELSE
          l_where_clause := l_where_clause || ' AND tab2.object_id  = ' || g_resource_list_id;
      END IF;

      IF g_control_flag = 'N' THEN
          l_where_clause := l_where_clause || ' AND tab2.object_type (+)  = ' || '''' || 'PROJECT'  || '''';
      ELSE
          l_where_clause := l_where_clause || ' AND tab2.object_type  = ' || '''' || 'RESOURCE_LIST' || '''';
      END IF;

      --end bug#3576766

      --start bug#3627812
      IF g_control_flag = 'N' THEN
          l_where_clause := l_where_clause || ' AND tab2.migration_code(+) is not null ' ;
      ELSE
          l_where_clause := l_where_clause || ' AND tab2.migration_code is not null ' ;
      END IF;
      --end bug#3627812

      --start bug#3665722
      IF g_control_flag = 'N' THEN
          l_where_clause := l_where_clause || ' AND tab2.enabled_flag (+) = ' || '''' || 'Y'  || '''';
      ELSE
          l_where_clause := l_where_clause || ' AND tab2.enabled_flag = ' || '''' || 'Y'  || '''';
      END IF;
      --end bug#3665722

    ELSIF  p_operation_type = 'TMP4' THEN

      --Generate where clause
      l_where_clause := ' WHERE ';
      l_res_tokens := get_format_res_tokens (p_resource_class_id, p_res_format_id);

      FOR i IN 1..l_res_tokens.COUNT LOOP

        l_where_clause := l_where_clause || get_SQL_tags (l_res_tokens(i), 'WHERE1'); --EQUI JOIN

        IF i <> l_res_tokens.COUNT THEN

          l_where_clause := l_where_clause || ' AND ';

        END IF;

      END LOOP; --end loop l_res_tokens

          l_where_clause := l_where_clause || ' AND tab1.resource_class_id = ' || p_resource_class_id;
    END IF;--end operation type

    RETURN l_where_clause;

  END;--end function get_where_clause

  ----------------------------------------
  --Step that identifies txns in TMP1/TMP2
  --that already map to existing planning
  --resources in pa_resource_list_members
  --Data is populated in TMP3 from TMP1/2
  --TMP3 contains the mapped planning
  --resource identifier or the new planning
  --resource identifier that needs to be
  --created in pa_resource_list_members
  -----------------------------------------
  FUNCTION identify_new_plan_res (
    p_resource_class_id NUMBER,
    p_format_id         NUMBER
  ) RETURN NUMBER IS

    l_SQL_statement VARCHAR2 (4000);
    l_INSERT_clause VARCHAR2 (1000);
    l_SELECT_clause VARCHAR2 (1000);
    l_FROM_clause VARCHAR2 (1000);
    l_WHERE_clause VARCHAR2 (2000);

    l_src_table VARCHAR2(20) := 'PA_RES_LIST_MAP_TMP1';

  BEGIN

    PA_DEBUG.init_err_stack('identify_new_plan_res');

    --Generate SQL statement to populate TMP3
    --This step differentiates the mapped and
    --unmapped headers

    l_INSERT_clause := get_insert_clause (p_resource_class_id, p_format_id, 'TMP3');
    l_SELECT_clause := get_select_clause (p_resource_class_id, p_format_id, 'TMP3');
    l_FROM_clause   := get_from_clause (p_resource_class_id, p_format_id, 'TMP3', l_src_table);
    l_WHERE_clause  := get_where_clause (p_resource_class_id, p_format_id, 'TMP3');
    l_SQL_statement := l_INSERT_clause || ' ' ||
                       l_SELECT_clause || ' ' ||
                       l_FROM_clause || ' ' ||
                       l_WHERE_clause || ';' ;

    EXECUTE IMMEDIATE 'BEGIN ' ||l_SQL_statement || ' END;';
    l_SQL_statement := NULL; --reset SQL statement

    pa_debug.reset_err_stack;

    RETURN 0;

  END;--end function identify_new_plan_res

  ------------------------------------
  --Verifies if unmapped txns exist
  --in TMP1 or TMP2
  ------------------------------------
  FUNCTION txns_to_map_exists
  RETURN BOOLEAN IS
    l_count NUMBER := 0;
  BEGIN

    -- Removed tmp2 as part of bug fix : 4199314
    /* SELECT count(*) into l_count
       FROM pa_res_list_map_tmp1
    IF (l_count = 0) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF; */
    -- Commented this as part of bug fix :4350603
      SELECT 1
      INTO l_count FROM dual WHERE EXISTS (SELECT 1
      FROM pa_res_list_map_tmp1);
      RETURN TRUE;
      EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
   END;--end function txns_to_map_exists

  ------------------------------------
  --Creates planning resources in
  --pa_resource_list_members
  ------------------------------------
  PROCEDURE create_planning_resources (
    p_format_id        NUMBER,
    p_resource_list_id NUMBER,
    p_resource_class_id NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2)
  IS

    CURSOR new_planning_resources (l_resource_class_id NUMBER) IS
    SELECT
      tmp3.RES_LIST_MEM_SEQ,
      tmp3.RES_FORMAT_ID,
      tmp3.BOM_LABOR_RESOURCE_ID,
      tmp3.BOM_EQUIP_RESOURCE_ID,
      tmp3.BOM_RESOURCE_ID,
      tmp3.PERSON_ID,
      tmp3.EVENT_TYPE,
      tmp3.EXPENDITURE_CATEGORY,
      tmp3.EXPENDITURE_TYPE,
      tmp3.ITEM_CATEGORY_ID,
      tmp3.INVENTORY_ITEM_ID,
      tmp3.JOB_ID,
      tmp3.ORGANIZATION_ID,
      tmp3.PERSON_TYPE_CODE,
      tmp3.NON_LABOR_RESOURCE,
      tmp3.REVENUE_CATEGORY,
      tmp3.VENDOR_ID,
      tmp3.PROJECT_ROLE_ID,
      tmp3.FC_RES_TYPE_CODE,
      tmp3.INCURRED_BY_RES_FLAG,
      tmp3.NAMED_ROLE,
      cls.RESOURCE_CLASS_ID,
      cls.RESOURCE_CLASS_CODE
    FROM
      pa_res_list_map_tmp3 tmp3,
      pa_resource_classes_b cls
    WHERE
      RESOURCE_LIST_MEMBER_ID IS NULL AND
      nvl(tmp3.resource_class_id, l_resource_class_id) = cls.resource_class_id;

 --bug#3691060 l_return_status           VARCHAR2(30);
    l_msg_data                VARCHAR2(30);
    l_msg_count               NUMBER;
    l_record_version_number   NUMBER;
    l_fin_category_name       VARCHAR2(30);
    l_rlm_id                  NUMBER;
    l_incur_by_res_code       VARCHAR2(30);
    l_incur_by_res_type       VARCHAR2(30);

  BEGIN

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    PA_DEBUG.init_err_stack('create_planning_resource');

    --Create missing planning resources in
    --PA_RESOURCE_LIST_MEMBERS
    FOR planning_res_rec IN new_planning_resources(p_resource_class_id) LOOP
      -- process data record
      --Call API to create planning resources
      --API provided by resource foundation team

      IF planning_res_rec.fc_res_type_code = 'EXPENDITURE_TYPE' THEN
        l_fin_category_name := planning_res_rec.expenditure_type;
      ELSIF planning_res_rec.fc_res_type_code = 'EVENT_TYPE' THEN
        l_fin_category_name := planning_res_rec.event_type;
      ELSIF planning_res_rec.fc_res_type_code = 'EXPENDITURE_CATEGORY' THEN
        l_fin_category_name := planning_res_rec.expenditure_category;
      ELSIF planning_res_rec.fc_res_type_code = 'REVENUE_CATEGORY' THEN
        l_fin_category_name := planning_res_rec.revenue_category;
      END IF;

     /* IF planning_res_rec.incurred_by_res_flag = 'Y' THEN   bug#3833910 */
         IF planning_res_rec.person_id IS NOT NULL THEN
            l_incur_by_res_code := planning_res_rec.person_id;
            l_incur_by_res_type := 'NAMED_PERSON';
         ELSIF planning_res_rec.job_id IS NOT NULL THEN
            l_incur_by_res_code := planning_res_rec.job_id;
            l_incur_by_res_type := 'JOB';
         ELSIF planning_res_rec.person_type_code IS NOT NULL THEN
            l_incur_by_res_code := planning_res_rec.person_type_code;
            l_incur_by_res_type := 'PERSON_TYPE';
         ELSIF planning_res_rec.project_role_id IS NOT NULL THEN
            -- Overloading columns because mapping temp tables are missing
            -- incur_by_role_id and incur_by_res_class_code columns.
            l_incur_by_res_code := planning_res_rec.project_role_id;
            l_incur_by_res_type := 'ROLE';
         ELSIF planning_res_rec.resource_class_code IS NOT NULL THEN
            -- Overloading columns because mapping temp tables are missing
            -- incur_by_role_id and incur_by_res_class_code columns.
            l_incur_by_res_code := planning_res_rec.resource_class_code;
            l_incur_by_res_type := 'RESOURCE_CLASS';
         ELSE
            l_incur_by_res_code := NULL;
            l_incur_by_res_type := NULL;
         END IF;
    /* bug#3833910 ELSE
         l_incur_by_res_code := NULL;
         l_incur_by_res_type := NULL;
      END IF;  */

     pa_planning_resource_pvt.create_planning_resource(
        p_resource_list_id     => g_resource_list_id,
        p_person_id            => planning_res_rec.person_id,
        p_job_id               => planning_res_rec.job_id,
        p_organization_id      => planning_res_rec.organization_id,
        p_vendor_id            => planning_res_rec.vendor_id,
        p_fin_category_name    => l_fin_category_name,
        p_non_labor_resource   => planning_res_rec.non_labor_resource,
        p_project_role_id      => planning_res_rec.project_role_id,
        p_resource_class_id    => planning_res_rec.resource_class_id,
        p_resource_class_code  => planning_res_rec.resource_class_code,
        p_res_format_id        => planning_res_rec.res_format_id,
        p_fc_res_type_code     => planning_res_rec.fc_res_type_code,
        p_inventory_item_id    => planning_res_rec.inventory_item_id,
        p_item_category_id     => planning_res_rec.item_category_id,
        p_person_type_code     => planning_res_rec.person_type_code,
        p_bom_resource_id      => planning_res_rec.bom_resource_id,
        --p_named_role            => planning_res_rec.named_role,
        p_team_role            => planning_res_rec.named_role,
        p_project_id           => g_project_id, /* bug#3679994 */
        --p_incurred_by_res_flag => planning_res_rec.incurred_by_res_flag,
        p_incur_by_res_code    => l_incur_by_res_code,
        p_incur_by_res_type    => l_incur_by_res_type,
        p_resource_list_member_id => planning_res_rec.res_list_mem_seq,
        x_resource_list_member_id => l_rlm_id,
        x_record_version_number   => l_record_version_number,
        x_return_status           => x_return_status,  /* bug#3691060 changed l_return_status to x_return_status */
        x_msg_count               => l_msg_count,
        x_error_msg_data          => l_msg_data );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT;
        END IF;

    END LOOP;

    pa_debug.reset_err_stack;

  END; --end procedure create_planning_resources

  -----------------------------------------------
  --Step moves mapped data from TMP3 -> TMP4
  --mapped data includes existing/new planning
  --resources for all transactions
  -----------------------------------------------
  FUNCTION process_mapped_txns (
    p_resource_class_id NUMBER,
    p_format_id         NUMBER)
  RETURN NUMBER IS

        l_SQL_statement VARCHAR2 (10000);
    l_INSERT_clause VARCHAR2 (4000);
    l_SELECT_clause VARCHAR2 (5000);
    l_FROM_clause VARCHAR2 (500);
    l_WHERE_clause VARCHAR2 (500);
    l_src_table VARCHAR2(20) := 'pa_res_list_map_tmp1';

  BEGIN

    PA_DEBUG.init_err_stack('process_mapped_txns');

    --Move mapped txns to TMP4
    --Truncate TMP3 (It will be used to
    --map remaining  txns)
    l_INSERT_clause := get_insert_clause (p_resource_class_id, p_format_id, 'TMP4');
    l_SELECT_clause := get_select_clause (p_resource_class_id, p_format_id, 'TMP4');
    l_FROM_clause   := get_from_clause (p_resource_class_id, p_format_id, 'TMP4', l_src_table);
    l_WHERE_clause  := get_where_clause (p_resource_class_id, p_format_id, 'TMP4');

    l_SQL_statement := l_INSERT_clause || ' ' ||
                       l_SELECT_clause || ' ' ||
                       l_FROM_clause || ' ' ||
                       l_WHERE_clause || ';' ;

    EXECUTE IMMEDIATE 'BEGIN ' || l_SQL_statement || ' END;';
    l_SQL_statement := NULL; --reset SQL statement

	--
	-- Replaced truncate statement with delete for resolving the auto commit issue.
    --EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || get_pa_schema_name || '.PA_RES_LIST_MAP_TMP3');
    EXECUTE IMMEDIATE ('DELETE FROM ' || get_pa_schema_name || '.PA_RES_LIST_MAP_TMP3');
    pa_debug.reset_err_stack;

    RETURN 0;

  END;--end function process_mapped_txns

  -----------------------------------------
  --Processes unmapped txns for next format
  -----------------------------------------
  FUNCTION process_txns_for_next_format  RETURN NUMBER IS
  BEGIN

    PA_DEBUG.init_err_stack('process_txns_for_next_format');

	--Move txns that did not satisfy format
    --to TMP2/TMP1 based on the run sequence
    --Truncate processed txns in TMP1/TMP2
-- commenting OUT for bug : 4199314
-- As part of bug fix we are deleting all the records from TEMP1  that exists in
-- TEMP4
      EXECUTE IMMEDIATE ('DELETE FROM ' || get_pa_schema_name || '.PA_RES_LIST_MAP_TMP1 TMP1' || ' WHERE ROWID IN ( SELECT tmp_rowid FROM pa_res_list_map_tmp4  tmp4  WHERE tmp4.tmp_rowid = tmp1.rowid ) ');

    pa_debug.reset_err_stack;

    RETURN 0;

  END;--end function process_txns_for_next_format

  ----------------------------------------------------
  --Main private procedure that maps transactions to a
  --format. Steps include the following
  --   Step 1: Identify new planning resources that
  --           need to be created
  --   Step 2: Create new planning resources
  --   Step 3: Process mapped txns (move them to
  --           destination table)
  --   Step 4: Cleanup staging tables and prepare
  --           remaining transactions for next format
  ---------------------------------------------------
  PROCEDURE map_for_format(
    p_resource_class_id IN NUMBER,
    p_format_id         IN NUMBER,
    p_resource_list_id  IN NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
  ) IS
    l_status     NUMBER := -1;
  BEGIN

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    PA_DEBUG.init_err_stack('map_for_format');

    --Identify new planning resources that need to be created
    --Generate SQL for TMP3
    l_status := identify_new_plan_res (p_resource_class_id, p_format_id);

    IF l_status <> 0 THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
    END IF;


    --Create missing planning resources identified above
    --This step involves creating new resource list members using
    --API provided by resource foundation team
    --New planning resources will be created only if the
    --resource list is not centrally controlled
    IF g_control_flag = 'N' THEN
      create_planning_resources (
          p_format_id         => p_format_id,
          p_resource_list_id  => p_resource_list_id,
          p_resource_class_id => p_resource_class_id,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
    END IF;

    --Move mapped data into TMP4
    l_status := -1;
    l_status := process_mapped_txns (p_resource_class_id, p_format_id ) ;

    IF l_status <> 0 THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
    END IF;

    --Move txns that did not map to format
    --between TMP1 and TMP2
    l_status := -1;
    l_status := process_txns_for_next_format ;

    IF l_status <> 0 THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
    END IF;

      pa_debug.reset_err_stack;

  END; --end procedure map_for_format


  /*--------------------------------------------------------------
     This API assumes that the temporary table pa_res_list_map_tmp
     has been populated with planning transactions that need to be
     mapped to a planning resource
  --------------------------------------------------------------*/
  PROCEDURE map_resource_list (
    p_resource_list_id IN NUMBER,
    p_project_id 	IN NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
  ) IS

    CURSOR resource_classes
    IS
    SELECT
      resource_class_id
    FROM
      pa_resource_classes_b;

    l_res_list_formats SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_res_class_formats PA_RESOURCE_PREC_PUB.plan_res_formats;
    l_format NUMBER;
    l_eff_formats SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    l_SQL_statement VARCHAR2 (2000);

    l_run_number NUMBER := 0;

    l_job_group_id  NUMBER ;  --added for bug#4027727

  BEGIN

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Call function to initialize format precedence
    PA_RESOURCE_PREC_PUB.format_precedence_init();

    --Update numeric identifiers for non-numeric resource types
    --update_resource_element_map;(Not required for resource list
    --mapping but is a must for RBS mapping)

    --Get all formats for the resource list passed as parameter
    BEGIN
      SELECT RES_FORMAT_ID
      BULK COLLECT
      INTO l_res_list_formats
      FROM pa_plan_rl_formats
      WHERE RESOURCE_LIST_ID = p_resource_list_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        END;

    g_resource_list_id := p_resource_list_id;

    g_project_id := p_project_id; /* bug#3576766 */

    --Identify if this resource list allows new planning resource
    --creation or is it centrally controlled
    BEGIN
      SELECT CONTROL_FLAG
      INTO   g_control_flag
      FROM pa_resource_lists_all_bg
      WHERE RESOURCE_LIST_ID = p_resource_list_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        END;


    --For every resource class the transactions have to be mapped
    --to the resource formats for the given resource list
    <<OUTER>>
    FOR res_class_rec IN resource_classes LOOP

      --Get all resource tokens for a given effective format
      IF res_class_rec.resource_class_id = 1 THEN
        l_res_class_formats := PA_RESOURCE_PREC_PUB.g_people_formats;
      ELSIF res_class_rec.resource_class_id = 2 THEN
        l_res_class_formats := PA_RESOURCE_PREC_PUB.g_equipment_formats;
      ELSIF res_class_rec.resource_class_id = 3 THEN
        l_res_class_formats := PA_RESOURCE_PREC_PUB.g_material_formats;
      ELSIF res_class_rec.resource_class_id = 4 THEN
        l_res_class_formats := PA_RESOURCE_PREC_PUB.g_fin_element_formats;
      END IF;

      --get all the effective formats for this resource class
      --filtered by the formats for the processed resource list
      FOR i IN 1..l_res_class_formats.COUNT LOOP
        FOR j IN 1..l_res_list_formats.COUNT LOOP

          IF l_res_list_formats(j) = l_res_class_formats(i).res_format_id THEN
            l_eff_formats.EXTEND;
            l_eff_formats( l_eff_formats.COUNT ) := l_res_class_formats(i).eff_res_format_id;
          END IF;

        END LOOP;--end j loop
      END LOOP; --end i loop

	-- bug#3612772 and bug#3612591
	-- update resource attributes which can be derived but are not present
	/*  split the below update into two to remove 9i dependencies
	UPDATE	pa_res_list_map_tmp1 tmp1
	SET	tmp1.EXPENDITURE_CATEGORY	= nvl(tmp1.EXPENDITURE_CATEGORY, (SELECT typ.EXPENDITURE_CATEGORY
										FROM PA_EXPENDITURE_TYPES typ
										WHERE typ.EXPENDITURE_TYPE = tmp1.EXPENDITURE_TYPE ) )
		,tmp1.ITEM_CATEGORY_ID		= nvl(tmp1.ITEM_CATEGORY_ID, (SELECT cat.CATEGORY_ID
										FROM
										  PA_RESOURCE_CLASSES_B classes,
										  PA_PLAN_RES_DEFAULTS  cls,
										  MTL_ITEM_CATEGORIES   cat
										WHERE
										  classes.RESOURCE_CLASS_CODE = 'MATERIAL_ITEMS'          and
										  cls.RESOURCE_CLASS_ID       = classes.RESOURCE_CLASS_ID and
										  cls.ITEM_CATEGORY_SET_ID    = cat.CATEGORY_SET_ID and
										  cat.INVENTORY_ITEM_ID   =  tmp1.INVENTORY_ITEM_ID  and
  cat.organization_id = tmp1.organization_id )
	      ) ;
	*/
     UPDATE	pa_res_list_map_tmp1 tmp1
	SET	tmp1.EXPENDITURE_CATEGORY	=  (SELECT typ.EXPENDITURE_CATEGORY
										FROM PA_EXPENDITURE_TYPES typ
										WHERE typ.EXPENDITURE_TYPE = tmp1.EXPENDITURE_TYPE )
	WHERE  tmp1.EXPENDITURE_CATEGORY IS NULL;
	UPDATE	pa_res_list_map_tmp1 tmp1
	SET	tmp1.ITEM_CATEGORY_ID		=  (SELECT cat.CATEGORY_ID
										FROM
										  PA_RESOURCE_CLASSES_B classes,
										  PA_PLAN_RES_DEFAULTS  cls,
										  MTL_ITEM_CATEGORIES   cat
										WHERE
										  classes.RESOURCE_CLASS_CODE = 'MATERIAL_ITEMS'          and
										  cls.RESOURCE_CLASS_ID       = classes.RESOURCE_CLASS_ID and
										  cls.ITEM_CATEGORY_SET_ID    = cat.CATEGORY_SET_ID and
										  cat.INVENTORY_ITEM_ID   =  tmp1.INVENTORY_ITEM_ID  and
										  cat.organization_id = tmp1.organization_id )
	WHERE tmp1.ITEM_CATEGORY_ID IS NULL;

       /* Added for bug 3653120 */

	UPDATE  pa_res_list_map_tmp1 tmp1
           SET tmp1.revenue_category = (SELECT evt.revenue_category_code
                                          FROM pa_event_types evt
                                         WHERE evt.event_type=tmp1.event_type)
         WHERE tmp1.revenue_category IS NULL
	   AND tmp1.event_type IS NOT NULL;

        UPDATE  pa_res_list_map_tmp1 tmp1
           SET tmp1.revenue_category = (SELECT et.revenue_category_code
                                          FROM pa_expenditure_types et
                                         WHERE et.expenditure_type=tmp1.expenditure_type)
         WHERE tmp1.revenue_category IS NULL
	   AND tmp1.expenditure_type IS NOT NULL;


     /* added for bug#4027727 */
      	BEGIN
     SELECT job_group_id INTO l_job_group_id FROM pa_resource_lists_all_bg WHERE resource_list_id = p_resource_list_id ;
     	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	NULL;
	END;
     IF l_job_group_id IS NOT NULL THEN
     UPDATE	pa_res_list_map_tmp1 tmp1
	SET	tmp1.job_id	=
	(SELECT PA_Cross_Business_Grp.IsMappedToJob(tmp1.job_id, l_job_group_id)  FROM DUAL)
	WHERE  tmp1.job_id IS NOT NULL;
     END IF;

      --Process mapping logic for every format (based on eff_res_format_id)
      --For a format there can be more than 1 effective formats
      --eg: Financial category breaks down into 4 formats

      FOR i IN 1..l_eff_formats.COUNT LOOP

        map_for_format(p_resource_class_id => res_class_rec.resource_class_id,
          p_format_id         => l_eff_formats(i),
          p_resource_list_id  => p_resource_list_id,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT OUTER;
        END IF;


        IF NOT (txns_to_map_exists) THEN
            EXIT OUTER;
        END IF;

      END LOOP; --end loop for sorted formats

      l_eff_formats.DELETE; --cleanup collection for next class

    END LOOP;--end cursor loop resource_classes


    x_msg_count := FND_MSG_PUB.Count_Msg;

  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data :=SQLERRM();

      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_RESOURCE_MAPPING'
                              , p_procedure_name => 'MAP_RESOURCE_LIST');

      x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

  END; --end procedure map_resource_list


  /* Returns the format precedence for every resource class */
  PROCEDURE get_format_precedence (
    p_resource_class_id    IN NUMBER,
    p_res_format_id        IN NUMBER,
    x_format_precedence    OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    x_msg_code             OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
  IS
    l_res_class_formats PA_RESOURCE_PREC_PUB.plan_res_formats;
  BEGIN
    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Call function to initialize format precedence
    PA_RESOURCE_PREC_PUB.format_precedence_init();

    IF p_resource_class_id = 1 THEN
      l_res_class_formats := PA_RESOURCE_PREC_PUB.g_people_formats;
    ELSIF p_resource_class_id = 2 THEN
      l_res_class_formats := PA_RESOURCE_PREC_PUB.g_equipment_formats;
    ELSIF p_resource_class_id = 3 THEN
      l_res_class_formats := PA_RESOURCE_PREC_PUB.g_material_formats;
    ELSIF p_resource_class_id = 4 THEN
      l_res_class_formats := PA_RESOURCE_PREC_PUB.g_fin_element_formats;
    END IF;

    FOR i IN 1..l_res_class_formats.COUNT LOOP

      IF p_res_format_id = l_res_class_formats(i).res_format_id THEN
        x_format_precedence := l_res_class_formats(i).eff_res_format_id;
        EXIT;
      END IF;

    END LOOP;

  END;

END; --end package pa_resource_mapping

/
