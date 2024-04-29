--------------------------------------------------------
--  DDL for Package Body MSC_CL_SETUP_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_SETUP_PULL" AS -- body
/* $Header:*/



   v_union_sql              varchar2(32767);
   v_temp_tp_sql            VARCHAR2(100);
   v_sql_stmt                    VARCHAR2(32767);
   v_temp_sql                    VARCHAR2(15000);
   v_temp_sql1                   VARCHAR2(1000);
   v_temp_sql2                   VARCHAR2(1000);
   v_temp_sql3                   VARCHAR2(1000);
   v_temp_sql4                   VARCHAR2(1000);
   v_temp_sql5                   VARCHAR2(1000);
   v_rounding_Sql                varchar2(1000);

  -- NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
--   NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;
   v_gmp_routine_name       VARCHAR2(50);
   GMP_ERROR                EXCEPTION;

--==================================================================

   PROCEDURE LOAD_CALENDAR_DATE IS
   BEGIN

--=================== Net Change Mode: Delete ==================

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_CHANGES';
MSC_CL_PULL.v_view_name := 'MRP_AD_RESOURCE_CHANGES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_RESOURCE_CHANGES'
||' ( DEPARTMENT_ID,'
||'   RESOURCE_ID,'
||'   SHIFT_NUM,'
||'   FROM_DATE,'
||'   TO_DATE,'
||'   FROM_TIME,'
||'   TO_TIME,'
||'   SIMULATION_SET,'
||'   ACTION_TYPE,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.DEPARTMENT_ID,'
||'   x.RESOURCE_ID,'
||'   x.SHIFT_NUM,'
||'   x.FROM_DATE,'
||'   x.TO_DATE,'
||'   x.FROM_TIME,'
||'   x.TO_TIME,'
||'   x.SIMULATION_SET,'
||'   x.ACTION_TYPE,'
||'   1,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AD_RESOURCE_CHANGES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;



IF MSC_CL_PULL.v_lrnn= -1 AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN --when not net collection


	MSC_CL_PULL.v_table_name:= 'MSC_ST_CALENDAR_ASSIGNMENTS';
	MSC_CL_PULL.v_view_name := 'MRP_AP_CAL_ASSIGNMENTS_V';

	v_sql_stmt:=
	' INSERT INTO MSC_ST_CALENDAR_ASSIGNMENTS'
	||' ( ASSOCIATION_TYPE,'
	||'   CALENDAR_CODE,'
	||'   CALENDAR_TYPE,'
	||'   PARTNER_ID,'
	||'   PARTNER_SITE_ID,'
	||'   ORGANIZATION_ID,'
	||'   SR_INSTANCE_ID,'
	||'   CARRIER_PARTNER_ID,'
	||'   PARTNER_TYPE,'
	||'   ASSOCIATION_LEVEL,'
	||'   SHIP_METHOD_CODE,'
	||'   REFRESH_ID)'
	||' SELECT'
	||'   x.ASSOCIATION_TYPE,'
	||'   :V_ICODE||x.CALENDAR_CODE,'
	||'   x.CALENDAR_TYPE,'
	||'   x.PARTNER_ID,'
	||'   x.PARTNER_SITE_ID,'
	||'   x.ORGANIZATION_ID,'
	||'   :v_instance_id,'
	||'   x.CARRIER_ID,'
	||'   x.PARTNER_TYPE,'
	||'   decode(x.ASSOCIATION_TYPE,11,1,10,1,9,3,8,3,7,3,6,2,5,2,4,4,3,4,2,4,1,4),'
	||'   x.SHIP_METHOD_CODE,'
	||'   :v_refresh_id'
	||' FROM MRP_AP_CAL_ASSIGNMENTS_V'||MSC_CL_PULL.v_dblink||' x';

	EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.V_ICODE,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_refresh_id;

	COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_CALENDAR_DATES';
MSC_CL_PULL.v_view_name := 'MRP_AP_CALENDAR_DATES_V';
v_sql_stmt:=
'insert into MSC_ST_CALENDAR_DATES'
||'  ( CALENDAR_DATE,'
||'    CALENDAR_CODE,'
||'    EXCEPTION_SET_ID,'
||'    SEQ_NUM,'
||'    NEXT_SEQ_NUM,'
||'    PRIOR_SEQ_NUM,'
||'    NEXT_DATE,'
||'    PRIOR_DATE,'
||'    CALENDAR_START_DATE,'
||'    CALENDAR_END_DATE,'
||'    DESCRIPTION,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.CALENDAR_DATE,'
||'    :V_ICODE||x.CALENDAR_CODE,'
||'    x.EXCEPTION_SET_ID,'
||'    x.SEQ_NUM,'
||'    x.NEXT_SEQ_NUM,'
||'    x.PRIOR_SEQ_NUM,'
||'    x.NEXT_DATE,'
||'    x.PRIOR_DATE,'
||'    x.CALENDAR_START_DATE,'
||'    x.CALENDAR_END_DATE,'
||'    x.DESCRIPTION,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_CALENDAR_DATES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
||'    OR x.RN4>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_PERIOD_START_DATES';
MSC_CL_PULL.v_view_name := 'MRP_AP_PERIOD_START_DATES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_PERIOD_START_DATES'
||' ( CALENDAR_CODE,'
||'   EXCEPTION_SET_ID,'
||'   PERIOD_START_DATE,'
||'   PERIOD_SEQUENCE_NUM,'
||'   PERIOD_NAME,'
||'   NEXT_DATE,'
||'   PRIOR_DATE,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   :V_ICODE||x.CALENDAR_CODE,'
||'   x.EXCEPTION_SET_ID,'
||'   x.PERIOD_START_DATE,'
||'   x.PERIOD_SEQUENCE_NUM,'
||'   x.PERIOD_NAME,'
||'   x.NEXT_DATE,'
||'   x.PRIOR_DATE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_PERIOD_START_DATES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_CAL_YEAR_START_DATES';
MSC_CL_PULL.v_view_name := 'MRP_AP_CAL_YEAR_START_DATES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_CAL_YEAR_START_DATES'
||' ( CALENDAR_CODE,'
||'   EXCEPTION_SET_ID,'
||'   YEAR_START_DATE,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   :V_ICODE||x.CALENDAR_CODE,'
||'   x.EXCEPTION_SET_ID,'
||'   x.YEAR_START_DATE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_CAL_YEAR_START_DATES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_CAL_WEEK_START_DATES';
MSC_CL_PULL.v_view_name := 'MRP_AP_CAL_WEEK_START_DATES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_CAL_WEEK_START_DATES'
||' ( CALENDAR_CODE,'
||'   EXCEPTION_SET_ID,'
||'   WEEK_START_DATE,'
||'   NEXT_DATE,'
||'   PRIOR_DATE,'
||'   SEQ_NUM,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   :V_ICODE||x.CALENDAR_CODE,'
||'   x.EXCEPTION_SET_ID,'
||'   x.WEEK_START_DATE,'
||'   x.NEXT_DATE,'
||'   x.PRIOR_DATE,'
||'   x.SEQ_NUM,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_CAL_WEEK_START_DATES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_SHIFTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_RESOURCE_SHIFTS_V';

Begin


IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
  v_temp_sql:= 'x.capacity_units , ' ;
ELSE
  v_temp_sql:=' NULL, ' ;
END IF ;


End;

v_sql_stmt:=
' INSERT INTO MSC_ST_RESOURCE_SHIFTS'
||' ( DEPARTMENT_ID,'
||'   RESOURCE_ID,'
||'   SHIFT_NUM,'
||'   DELETED_FLAG,'
||'   CAPACITY_UNITS,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.DEPARTMENT_ID,'
||'   x.RESOURCE_ID,'
||'   x.SHIFT_NUM,'
||'   2,'
||    v_temp_sql
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_RESOURCE_SHIFTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_all_org_str
||'   AND ( x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_CALENDAR_SHIFTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_CALENDAR_SHIFTS_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_CALENDAR_SHIFTS'
||' ( CALENDAR_CODE,'
||'   SHIFT_NUM,'
||'   DAYS_ON,'
||'   DAYS_OFF,'
||'   DESCRIPTION,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   :V_ICODE||x.CALENDAR_CODE,'
||'   x.SHIFT_NUM,'
||'   x.DAYS_ON,'
||'   x.DAYS_OFF,'
||'   x.DESCRIPTION,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_CALENDAR_SHIFTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SHIFT_DATES';
MSC_CL_PULL.v_view_name := 'MRP_AP_SHIFT_DATES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_SHIFT_DATES'
||' ( CALENDAR_CODE,'
||'   EXCEPTION_SET_ID,'
||'   SHIFT_NUM,'
||'   SHIFT_DATE,'
||'   SEQ_NUM,'
||'   NEXT_SEQ_NUM,'
||'   PRIOR_SEQ_NUM,'
||'   NEXT_DATE,'
||'   PRIOR_DATE,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   :V_ICODE||x.CALENDAR_CODE,'
||'   x.EXCEPTION_SET_ID,'
||'   x.SHIFT_NUM,'
||'   x.SHIFT_DATE,'
||'   x.SEQ_NUM,'
||'   x.NEXT_SEQ_NUM,'
||'   x.PRIOR_SEQ_NUM,'
||'   x.NEXT_DATE,'
||'   x.PRIOR_DATE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_SHIFT_DATES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_CHANGES';
MSC_CL_PULL.v_view_name := 'MRP_AP_RESOURCE_CHANGES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_RESOURCE_CHANGES'
||' ( DEPARTMENT_ID,'
||'   RESOURCE_ID,'
||'   SHIFT_NUM,'
||'   FROM_DATE,'
||'   TO_DATE,'
||'   FROM_TIME,'
||'   TO_TIME,'
||'   CAPACITY_CHANGE,'
||'   SIMULATION_SET,'
||'   ACTION_TYPE,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.DEPARTMENT_ID,'
||'   x.RESOURCE_ID,'
||'   x.SHIFT_NUM,'
||'   x.FROM_DATE,'
||'   x.TO_DATE,'
||'   x.FROM_TIME,'
||'   x.TO_TIME,'
||'   x.CAPACITY_CHANGE,'
||'   x.SIMULATION_SET,'
||'   x.ACTION_TYPE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_RESOURCE_CHANGES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SHIFT_TIMES';
MSC_CL_PULL.v_view_name := 'MRP_AP_SHIFT_TIMES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_SHIFT_TIMES'
||' ( CALENDAR_CODE,'
||'   SHIFT_NUM,'
||'   FROM_TIME,'
||'   TO_TIME,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   :V_ICODE||x.CALENDAR_CODE,'
||'   x.SHIFT_NUM,'
||'   x.FROM_TIME,'
||'   x.TO_TIME,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_SHIFT_TIMES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SHIFT_EXCEPTIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_SHIFT_EXCEPTIONS_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_SHIFT_EXCEPTIONS'
||' ( CALENDAR_CODE,'
||'   SHIFT_NUM,'
||'   EXCEPTION_SET_ID,'
||'   EXCEPTION_DATE,'
||'   EXCEPTION_TYPE,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   :V_ICODE||x.CALENDAR_CODE,'
||'   x.SHIFT_NUM,'
||'   x.EXCEPTION_SET_ID,'
||'   x.EXCEPTION_DATE,'
||'   x.EXCEPTION_TYPE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_SHIFT_EXCEPTIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

-- =============================== NETCHAGE OF DELETE ======================

/* ds change start */

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
  IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
   MSC_CL_PULL.v_table_name:= 'MSC_ST_RES_INSTANCE_CHANGES';
   MSC_CL_PULL.v_view_name := 'MRP_AD_RES_INST_CHANGES_V';
   v_sql_stmt:=
    ' INSERT INTO MSC_ST_RES_INSTANCE_CHANGES'
     ||' ( DEPARTMENT_ID,'
     ||'   RESOURCE_ID,'
     ||'   RES_INSTANCE_ID,'
     ||'   SERIAL_NUMBER,'
     ||'   SHIFT_NUM,'
     ||'   FROM_DATE,'
     ||'   TO_DATE,'
     ||'   FROM_TIME,'
     ||'   TO_TIME,'
     ||'   SIMULATION_SET,'
     ||'   ACTION_TYPE,'
     ||'   DELETED_FLAG,'
     ||'   REFRESH_ID,'
     ||'   SR_INSTANCE_ID)'
     ||' SELECT'
     ||'   x.DEPARTMENT_ID,'
     ||'   x.RESOURCE_ID,'
     ||'   x.RES_INSTANCE_ID,'
     ||'   x.SERIAL_NUMBER,'
     ||'   x.SHIFT_NUM,'
     ||'   x.FROM_DATE,'
     ||'   x.TO_DATE,'
     ||'   x.FROM_TIME,'
     ||'   x.TO_TIME,'
     ||'   x.SIMULATION_SET,'
     ||'   x.ACTION_TYPE,'
     ||'   1,'
     ||'   :v_refresh_id,'
     ||'   :v_instance_id'
     ||' FROM MRP_AD_RES_INST_CHANGES_V'||MSC_CL_PULL.v_dblink||' x'
     ||'   WHERE x.RN >'     ||MSC_CL_PULL.v_lrn;

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Ds debug:  res_instance change sql = '||v_sql_stmt);
     EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

      COMMIT;

  END IF;  /*  MSC_CL_PULL.v_lrnn<> -1 */

  IF MSC_CL_PULL.v_lrnn= -1 THEN  /* if it i not net change */
    MSC_CL_PULL.v_table_name:= 'MSC_ST_RES_INSTANCE_CHANGES';
    MSC_CL_PULL.v_view_name := 'MRP_AP_RES_INST_CHANGES_V';

    v_sql_stmt:=
     ' INSERT INTO MSC_ST_RES_INSTANCE_CHANGES'
    ||' ( DEPARTMENT_ID,'
    ||'   RESOURCE_ID,'
    ||'   RES_INSTANCE_ID,'
    ||'   SERIAL_NUMBER,'
    /*||'   EQUIPMENT_ITEM_ID,'*/
    ||'   SHIFT_NUM,'
    ||'   FROM_DATE,'
    ||'   TO_DATE,'
    ||'   FROM_TIME,'
    ||'   TO_TIME,'
    ||'   CAPACITY_CHANGE,'
    ||'   SIMULATION_SET,'
    ||'   ACTION_TYPE,'
    ||'   DELETED_FLAG,'
    ||'   REFRESH_ID,'
    ||'   SR_INSTANCE_ID)'
    ||' SELECT'
    ||'   x.DEPARTMENT_ID,'
    ||'   x.RESOURCE_ID,'
    ||'   x.RES_INSTANCE_ID,'
    ||'   x.SERIAL_NUMBER,'
    /*||'   x.EQUIPMENT_ITEM_ID,'*/
    ||'   x.SHIFT_NUM,'
    ||'   x.FROM_DATE,'
    ||'   x.TO_DATE,'
    ||'   x.FROM_TIME,'
    ||'   x.TO_TIME,'
    ||'   x.CAPACITY_CHANGE,'
    ||'   x.SIMULATION_SET,'
    ||'   x.ACTION_TYPE,'
    ||'   2,'
    ||'  :v_refresh_id,'
    ||'   :v_instance_id'
    ||' FROM MRP_AP_RES_INST_CHANGES_V'  ||MSC_CL_PULL.v_dblink  ||' x'
    ||' WHERE x.RN1>'  ||MSC_CL_PULL.v_lrn
    ||'    OR x.RN2>'  ||MSC_CL_PULL.v_lrn;

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'to be removed: Ds debug:  res_instance changes sql = '||v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_RES_INST_CHANGES_V='|| SQL%ROWCOUNT);

    COMMIT;
  END IF; /*  MSC_CL_PULL.v_lrnn= -1 */

END IF;  /* MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 */

END LOAD_CALENDAR_DATE;


--==================================================================

   PROCEDURE LOAD_BUYER_CONTACT IS

   BEGIN


IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh
--IF MSC_CL_PULL.ITEM_ENABLED= MSC_UTIL.SYS_YES THEN   /* PREPLACE START */

MSC_CL_PULL.v_table_name:= 'MSC_ST_PARTNER_CONTACTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_BUYER_CONTACTS_V';

v_sql_stmt :=
   'INSERT INTO MSC_ST_PARTNER_CONTACTS'
||' ( NAME,'
||'   DISPLAY_NAME,'
||'   EMAIL,'
||'   FAX,'
||'   PARTNER_ID,'
||'   PARTNER_SITE_ID,'
||'   PARTNER_TYPE,'
||'   ENABLED_FLAG,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT DISTINCT'
||'   x.NAME,'
||'   x.DISPLAY_NAME,'
||'   x.EMAIL,'
||'   x.FAX,'
||'   x.PARTNER_ID,'
||'   x.PARTNER_SITE_ID,'
||'   4,'
||'   ENABLED_FLAG,'
||'   2,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_BUYER_CONTACTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_all_org_str;

EXECUTE IMMEDIATE v_sql_stmt
            USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;


END IF;  -- complete refresh
--END IF;  -- MSC_CL_PULL.ITEM_ENABLED   /* PREPLACE END */

   END LOAD_BUYER_CONTACT;


--==================================================================

PROCEDURE LOAD_TRADING_PARTNER IS

lv_profile_inherit_op_seq     NUMBER;
 BEGIN


 -- select the  in INHERIT_OPTION_CLASS_OP_SEQ profile option in source instance

 BEGIN
      v_sql_stmt :=   ' select  nvl(FND_PROFILE.VALUE'||MSC_CL_PULL.v_dblink||'(''BOM:CONFIG_INHERIT_OP_SEQ''),2) '
                    ||'   from  dual';
      execute immediate v_sql_stmt into lv_profile_inherit_op_seq;
 EXCEPTION
        WHEN OTHERS THEN
          lv_profile_inherit_op_seq := 2;

 END ;

IF MSC_UTIL.v_msc_tp_coll_window = 0 THEN
   v_temp_tp_sql := NULL;
ELSE
   v_temp_tp_sql := ' AND x.LAST_UPDATE_DATE > SYSDATE - :v_msc_tp_coll_window';
END IF;

IF MSC_CL_PULL.VENDOR_ENABLED= MSC_UTIL.SYS_YES THEN

MSC_CL_PULL.v_table_name:= 'MSC_ST_TRADING_PARTNERS';
MSC_CL_PULL.v_view_name := 'MRP_AP_VENDORS_V';

v_sql_stmt:=
'insert into MSC_ST_TRADING_PARTNERS'
||'  ( SR_TP_ID,'
||'    DISABLE_DATE,'
||'    PARTNER_TYPE,'
||'    PARTNER_NAME,'
||'    PARTNER_NUMBER,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.SR_TP_ID,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    x.PARTNER_TYPE,'
||'    x.PARTNER_NAME,'
||'    x.PARTNER_NUMBER,'
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_VENDORS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||v_temp_tp_sql;

IF MSC_UTIL.v_msc_tp_coll_window = 0 THEN
 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
ELSE
 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,MSC_UTIL.v_msc_tp_coll_window;
END IF;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_TRADING_PARTNER_SITES';
MSC_CL_PULL.v_view_name := 'MRP_AP_VENDOR_SITES_V';

 /* for bug: 2459612, added code to collect OPERATING_UNIT from Vendor sites for 11i source instance */
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
    v_temp_sql := ' x.OPERATING_UNIT,x.shipping_control, ';
ELSE
    v_temp_sql := ' NULL,NULL,';
END IF;

v_sql_stmt:=
'insert into MSC_ST_TRADING_PARTNER_SITES'
||'  ( TP_SITE_CODE,'
||'    SR_TP_ID,'
||'    SR_TP_SITE_ID,'
||'    PARTNER_ADDRESS,'
||'    LOCATION_ID,'
||'    OPERATING_UNIT_NAME,'
||'    OPERATING_UNIT ,'
||'    shipping_control ,'
||'    PARTNER_TYPE,'
||'    LONGITUDE,'
||'    LATITUDE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
/* SCE Change starts */
/* We need to capture address information in staging tables for SCE purpose */
||'   ADDRESS1,'
||'   ADDRESS2,'
||'   ADDRESS3,'
||'   ADDRESS4,'
||'   CITY,'
||'   STATE,'
||'   COUNTY,'
||'   PROVINCE,'
||'   COUNTRY,'
/* SCE Change ends */
||'    SR_INSTANCE_ID)'
||'  select'
||'     x.TP_SITE_CODE,'
||'     x.SR_TP_ID,'
||'     x.SR_TP_SITE_ID,'
||'     x.PARTNER_ADDRESS,'
||'     x.LOCATION_ID,'
||'     x.OPERATING_UNIT_NAME,'
||    v_temp_sql
||'     x.PARTNER_TYPE,'
||'     x.LONGITUDE,'
||'     x.LATITUDE,'
||'     2,'
||'  :v_refresh_id,'
/* SCE Change Starts */
||'     x.ADDRESS_LINE1,'
||'     x.ADDRESS_LINE2,'
||'     x.ADDRESS_LINE3,'
||'     x.ADDRESS_LINE4,'
||'     x.CITY,'
||'     x.STATE,'
||'     x.COUNTY,'
||'     x.PROVINCE,'
||'     x.COUNTRY,'
/* SCE Change Ends */
||'     :v_instance_id'
||'  from MRP_AP_VENDOR_SITES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn||')'
||v_temp_tp_sql;

IF MSC_UTIL.v_msc_tp_coll_window = 0 THEN
 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
ELSE
 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,MSC_UTIL.v_msc_tp_coll_window;
END IF;

COMMIT;

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql := 'x.ORGANIZATION_ID, ';
ELSE
     v_temp_sql := ' NULL, ';
END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_LOCATION_ASSOCIATIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_LOCATION_ASSOCIATIONS_V';

v_sql_stmt:=
   'INSERT INTO MSC_ST_LOCATION_ASSOCIATIONS'
||' ( LOCATION_ID,'
||'   LOCATION_CODE,'
||'   SR_TP_ID,'
||'   SR_TP_SITE_ID,'
||'   PARTNER_TYPE,'
||'   ORGANIZATION_ID,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.LOCATION_ID,'
||'   x.LOCATION_CODE,'
||'   x.TRADING_PARTNER_ID,'
||'   x.TRADING_PARTNER_SITE_ID,'
||'   1,'
||    v_temp_sql
||'   :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_LOCATION_ASSOCIATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.PARTNER_TYPE= 1';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_PARTNER_CONTACTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_VENDOR_CONTACTS_V';

v_sql_stmt:=
   'INSERT INTO MSC_ST_PARTNER_CONTACTS'
||' ( NAME,'
||'   DISPLAY_NAME,'
||'   EMAIL,'
||'   FAX,'
||'   PARTNER_ID,'
||'   PARTNER_SITE_ID,'
||'   PARTNER_TYPE,'
||'   ENABLED_FLAG,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.NAME,'
||'   x.DISPLAY_NAME,'
||'   x.EMAIL,'
||'   x.FAX,'
||'   x.PARTNER_ID,'
||'   x.PARTNER_SITE_ID,'
||'   1,'
||'   ENABLED_FLAG,'
||'   2,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_VENDOR_CONTACTS_V'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;  -- complete refresh

END IF;  -- MSC_CL_PULL.VENDOR_ENABLED


IF MSC_CL_PULL.CUSTOMER_ENABLED= MSC_UTIL.SYS_YES THEN

MSC_CL_PULL.v_table_name:= 'MSC_ST_TRADING_PARTNERS';
MSC_CL_PULL.v_view_name := 'MRP_AP_CUSTOMERS_V';

BEGIN

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
    v_temp_sql2 := ' x.AGGREGATE_DEMAND_FLAG, ';
ELSE
    v_temp_sql2 := ' NULL,';
END IF;
IF MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS107 THEN
    v_temp_sql1 :=  ' NULL,';
ELSE
    v_temp_sql1 := ' x.CUSTOMER_CLASS_CODE,';
END IF;

------ ===== # SRP Changes ======
 IF  (MSC_UTIL.G_COLLECT_SRP_DATA = 'Y') THEN
  v_temp_sql2 := v_temp_sql2||' x.RESOURCE_TYPE, ';
 ELSE
 v_temp_sql2 := v_temp_sql2||' NULL,';
 END IF;

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql2 := v_temp_sql2 || ' x.customer_type, x.CUST_ACCOUNT_NUMBER, ';
ELSE
     v_temp_sql2 := v_temp_sql2 || ' NULL, NULL, ';
END IF;

END;

v_sql_stmt:=
'insert into MSC_ST_TRADING_PARTNERS'
||'  ( SR_TP_ID,'
||'    STATUS,'
||'    PARTNER_TYPE,'
||'    PARTNER_NAME,'
||'    PARTNER_NUMBER,'
||'    CUSTOMER_CLASS_CODE,'
||'    AGGREGATE_DEMAND_FLAG,'
||'    RESOURCE_TYPE,'      --SRP Changes
||'    CUSTOMER_TYPE,'
||'    CUST_ACCOUNT_NUMBER,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.SR_TP_ID,'
||'    x.STATUS,'
||'    x.PARTNER_TYPE,'
||'    x.PARTNER_NAME,'
||'    x.PARTNER_NUMBER,'
||     v_temp_sql1
||     v_temp_sql2
||'    2,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  from MRP_AP_CUSTOMERS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||v_temp_tp_sql;

IF MSC_UTIL.v_msc_tp_coll_window = 0 THEN
 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
ELSE
 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,MSC_UTIL.v_msc_tp_coll_window;
END IF;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_TRADING_PARTNER_SITES';
MSC_CL_PULL.v_view_name := 'MRP_AP_CUSTOMER_SITES_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
    v_temp_sql := ' x.POSTAL_CODE, x.CITY, x.STATE, x.COUNTRY,x.LOCATION_ID,x.SHIPPING_CONTROL, ';
ELSE
    v_temp_sql := ' NULL,NULL,NULL,NULL,NULL,NULL, ';
END IF;

/* For bug: 2564735 , added substr for 30 chars on the column partner_site_number */
v_sql_stmt:=
'insert into MSC_ST_TRADING_PARTNER_SITES'
||'  ( TP_SITE_CODE,'
||'    SR_TP_ID,'
||'    SR_TP_SITE_ID,'
||'    LOCATION,'
||'    OPERATING_UNIT_NAME,'
||'    PARTNER_ADDRESS,'
||'    LONGITUDE,'
||'    LATITUDE,'
||'    PARTNER_TYPE,'
||'    POSTAL_CODE,'
||'    CITY,'
||'    STATE,'
||'    COUNTRY,'
||'    LOCATION_ID, '
||'    SHIPPING_CONTROL,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
/* SCE Change Starts */
||'    ADDRESS1,'
||'    ADDRESS2,'
||'    ADDRESS3,'
||'    ADDRESS4,'
||'    PROVINCE,'
||'    COUNTY,'
||'    PARTNER_SITE_NUMBER,'
/* SCE Change Ends */
||'    SR_INSTANCE_ID)'
||'  select'
||'     x.TP_SITE_CODE,'
||'     x.SR_TP_ID,'
||'     x.SR_TP_SITE_ID,'
||'     x.LOCATION,'
||'     x.OPERATING_UNIT_NAME,'
||'     x.PARTNER_ADDRESS,'
||'     x.LONGITUDE,'
||'     x.LATITUDE,'
||'     x.PARTNER_TYPE,'
||  v_temp_sql
||'     2,'
||'  :v_refresh_id,'
/* SCE Change Starts */
||'     x.ADDRESS1,'
||'     x.ADDRESS2,'
||'     x.ADDRESS3,'
||'     x.ADDRESS4,'
||'     x.PROVINCE,'
||'     x.COUNTY,'
||'     substr(x.PARTNER_SITE_NUMBER,1,30), '
/* SCE Change Ends */
||'     :v_instance_id'
||'  from MRP_AP_CUSTOMER_SITES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn||')'
||v_temp_tp_sql;

IF MSC_UTIL.v_msc_tp_coll_window = 0 THEN
 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
ELSE
 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,MSC_UTIL.v_msc_tp_coll_window;
END IF;

COMMIT;

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql := 'x.ORGANIZATION_ID, ';
ELSE
     v_temp_sql := ' NULL, ';
END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_LOCATION_ASSOCIATIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_LOCATION_ASSOCIATIONS_V';

v_sql_stmt:=
   'INSERT INTO MSC_ST_LOCATION_ASSOCIATIONS'
||' ( LOCATION_ID,'
||'   LOCATION_CODE,'
||'   SR_TP_ID,'
||'   SR_TP_SITE_ID,'
||'   PARTNER_TYPE,'
||'   ORGANIZATION_ID,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.LOCATION_ID,'
||'   x.LOCATION_CODE,'
||'   x.TRADING_PARTNER_ID,'
||'   x.TRADING_PARTNER_SITE_ID,'
||'   2,'
||    v_temp_sql
||'   :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_LOCATION_ASSOCIATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.PARTNER_TYPE= 2';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_PARTNER_CONTACTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_CUSTOMER_CONTACTS_V';

v_sql_stmt:=
   'INSERT INTO MSC_ST_PARTNER_CONTACTS'
||' ( NAME,'
||'   DISPLAY_NAME,'
||'   EMAIL,'
||'   FAX,'
||'   PARTNER_ID,'
||'   PARTNER_SITE_ID,'
||'   PARTNER_TYPE,'
||'   ENABLED_FLAG,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.NAME,'
||'   x.DISPLAY_NAME,'
||'   x.EMAIL,'
||'   x.FAX,'
||'   x.PARTNER_ID,'
||'   x.PARTNER_SITE_ID,'
||'   2,'
||'   ENABLED_FLAG,'
||'   2,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_CUSTOMER_CONTACTS_V'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;  -- complete refresh

END IF;  -- CUSTOMER ENABLED

MSC_CL_PULL.v_table_name:= 'MSC_ST_TRADING_PARTNERS';
MSC_CL_PULL.v_view_name := 'MRP_AP_ORGANIZATIONS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql:= 'x.BUSINESS_GROUP_ID,x.LEGAL_ENTITY, x.SET_OF_BOOKS_ID, x.CHART_OF_ACCOUNTS_ID, x.BUSINESS_GROUP_NAME,x.LEGAL_ENTITY_NAME, x.OPERATING_UNIT_NAME, ';
ELSE
     v_temp_sql := 'NULL,NULL,NULL,NULL,NULL,NULL,NULL,';
END IF;


IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS121 THEN
     v_temp_sql5 := 'x.SUBCONTRACTING_SOURCE_ORG, ';
ELSE
     v_temp_sql5 := 'NULL,';
END IF;

v_sql_stmt:=
'insert into MSC_ST_TRADING_PARTNERS'
||'  ( ORGANIZATION_CODE,'
||'    ORGANIZATION_TYPE,'
||'    SR_TP_ID,'
||'    MASTER_ORGANIZATION,'
||'    SOURCE_ORG_ID,'
||'    PARTNER_TYPE,'
||'    PARTNER_NAME,'
||'    CALENDAR_CODE,'
||'    CURRENCY_CODE,'
||'    CALENDAR_EXCEPTION_SET_ID,'
||'    OPERATING_UNIT,'
||'    MAXIMUM_WEIGHT,'
||'    MAXIMUM_VOLUME,'
||'    WEIGHT_UOM,'
||'    VOLUME_UOM,'
||'    PROJECT_REFERENCE_ENABLED,'
||'    PROJECT_CONTROL_LEVEL,'
||'    MODELED_CUSTOMER_ID,'
||'    MODELED_CUSTOMER_SITE_ID,'
||'    MODELED_SUPPLIER_ID,'
||'    MODELED_SUPPLIER_SITE_ID,'
||'    USE_PHANTOM_ROUTINGS,'
||'    INHERIT_PHANTOM_OP_SEQ,'
||'    DEFAULT_ATP_RULE_ID,'
||'    DEFAULT_DEMAND_CLASS,'
||'    MATERIAL_ACCOUNT,'
||'    EXPENSE_ACCOUNT,'
||'    DEMAND_LATENESS_COST,'
||'    SUPPLIER_CAP_OVERUTIL_COST,'
||'    RESOURCE_CAP_OVERUTIL_COST,'
||'    TRANSPORT_CAP_OVER_UTIL_COST,'
||'    BUSINESS_GROUP_ID, '
||'    LEGAL_ENTITY, '
||'    SET_OF_BOOKS_ID, '
||'    CHART_OF_ACCOUNTS_ID,'
||'    BUSINESS_GROUP_NAME, '
||'    LEGAL_ENTITY_NAME, '
||'    OPERATING_UNIT_NAME,'
||'    SUBCONTRACTING_SOURCE_ORG,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID,'
||'    INHERIT_OC_OP_SEQ_NUM)'
||'  select'
||'    :V_ICODE||x.ORGANIZATION_CODE,'
||'    1,'           -- set to discrete as the default value.
||'    x.SR_TP_ID,'
||'    x.MASTER_ORGANIZATION,'
||'    x.SOURCE_ORG_ID,'
||'    x.PARTNER_TYPE,'
||'    :V_ICODE||x.PARTNER_NAME,'
||'    :V_ICODE||x.CALENDAR_CODE,'
||'    x.CURRENCY_CODE,'
||'    x.CALENDAR_EXCEPTION_SET_ID,'
||'    x.OPERATING_UNIT,'
||'    x.MAXIMUM_WEIGHT,'
||'    x.MAXIMUM_VOLUME,'
||'    x.WEIGHT_UOM,'
||'    x.VOLUME_UOM,'
||'    x.PROJECT_REFERENCE_ENABLED,'
||'    x.PROJECT_CONTROL_LEVEL,'
||'    x.MODELED_CUSTOMER_ID,'
||'    x.MODELED_CUSTOMER_SITE_ID,'
||'    x.MODELED_SUPPLIER_ID,'
||'    x.MODELED_SUPPLIER_SITE_ID,'
||'    x.USE_PHANTOM_ROUTINGS,'
||'    x.INHERIT_PHANTOM_OP_SEQ,'
||'    x.DEFAULT_ATP_RULE_ID,'
||'    x.DEFAULT_DEMAND_CLASS,'
||'    x.MATERIAL_ACCOUNT,'
||'    x.EXPENSE_ACCOUNT,'
||'    TO_NUMBER(DECODE( :v_mso_org_dmd_penalty,'
||'            1, x.Attribute1,'
||'            2, x.Attribute2,'
||'            3, x.Attribute3,'
||'            4, x.Attribute4,'
||'            5, x.Attribute5,'
||'            6, x.Attribute6,'
||'            7, x.Attribute7,'
||'            8, x.Attribute8,'
||'            9, x.Attribute9,'
||'            10, x.Attribute10,'
||'            11, x.Attribute11,'
||'            12, x.Attribute12,'
||'            13, x.Attribute13,'
||'            14, x.Attribute14,'
||'            15, x.Attribute15)),'
||'    TO_NUMBER(DECODE( :v_mso_org_item_penalty,'
||'            1, x.Attribute1,'
||'            2, x.Attribute2,'
||'            3, x.Attribute3,'
||'            4, x.Attribute4,'
||'            5, x.Attribute5,'
||'            6, x.Attribute6,'
||'            7, x.Attribute7,'
||'            8, x.Attribute8,'
||'            9, x.Attribute9,'
||'            10, x.Attribute10,'
||'            11, x.Attribute11,'
||'            12, x.Attribute12,'
||'            13, x.Attribute13,'
||'            14, x.Attribute14,'
||'            15, x.Attribute15)),'
||'    TO_NUMBER(DECODE( :v_mso_org_res_penalty,'
||'            1, x.Attribute1,'
||'            2, x.Attribute2,'
||'            3, x.Attribute3,'
||'            4, x.Attribute4,'
||'            5, x.Attribute5,'
||'            6, x.Attribute6,'
||'            7, x.Attribute7,'
||'            8, x.Attribute8,'
||'            9, x.Attribute9,'
||'            10, x.Attribute10,'
||'            11, x.Attribute11,'
||'            12, x.Attribute12,'
||'            13, x.Attribute13,'
||'            14, x.Attribute14,'
||'            15, x.Attribute15)),'
||'    TO_NUMBER(DECODE( :v_mso_org_trsp_penalty,'
||'            1, x.Attribute1,'
||'            2, x.Attribute2,'
||'            3, x.Attribute3,'
||'            4, x.Attribute4,'
||'            5, x.Attribute5,'
||'            6, x.Attribute6,'
||'            7, x.Attribute7,'
||'            8, x.Attribute8,'
||'            9, x.Attribute9,'
||'            10, x.Attribute10,'
||'            11, x.Attribute11,'
||'            12, x.Attribute12,'
||'            13, x.Attribute13,'
||'            14, x.Attribute14,'
||'            15, x.Attribute15)),'
||     v_temp_sql
||     v_temp_sql5
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id,'
||'    :lv_profile_inherit_op_seq'
||'  from MRP_AP_ORGANIZATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||'  where NVL( x.LANGUAGE, :v_lang)= :v_lang'
||'   AND x.SR_TP_ID'||MSC_UTIL.v_in_all_org_str
||'   AND ( x.RN1>'||MSC_CL_PULL.v_lrn
||'         OR x.RN2>'||MSC_CL_PULL.v_lrn
||'         OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE,
                                   MSC_CL_PULL.V_ICODE,
                                   MSC_CL_PULL.V_ICODE,
                                   MSC_CL_PULL.v_mso_org_dmd_penalty,
                                   MSC_CL_PULL.v_mso_org_item_penalty,
                                   MSC_CL_PULL.v_mso_org_res_penalty,
                                   MSC_CL_PULL.v_mso_org_trsp_penalty,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
				   lv_profile_inherit_op_seq,
                                   MSC_CL_PULL.v_lang,
                                   MSC_CL_PULL.v_lang;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_TRADING_PARTNER_SITES';
MSC_CL_PULL.v_view_name := 'MRP_AP_ORGANIZATION_SITES_V';

/* For bug: 2564735 , added substr for 60 chars on the columns COUNTY and STATE  becos these columns
  are of higher size in the views */
v_sql_stmt:=
'insert into MSC_ST_TRADING_PARTNER_SITES'
||'  ( SR_TP_ID,'
||'    SR_TP_SITE_ID,'
||'    LOCATION,'
||'    PARTNER_ADDRESS,'
/* SCE Changes start  */
||'    ADDRESS1,'
||'    ADDRESS2,'
||'    ADDRESS3,'
||'    CITY,'
||'    COUNTY,'
||'    STATE,'
||'    POSTAL_CODE,'
||'    COUNTRY,'
/* SCE Changes end */
||'    LONGITUDE,'
||'    LATITUDE,'
||'    PARTNER_TYPE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'     x.SR_TP_ID,'
||'     x.SR_TP_SITE_ID,'
||'     x.LOCATION,'
||'     x.PARTNER_ADDRESS,'
/* SCE Changes start  */
||'    x.ADDRESS_LINE_1,'
||'    x.ADDRESS_LINE_2,'
||'    x.ADDRESS_LINE_3,'
||'    x.CITY,'
||'    substr(x.COUNTY,1,60),'
||'    substr(x.STATE,1,60),'
||'    x.POSTAL_CODE,'
||'    x.COUNTRY,'
/* SCE Changes end */
||'     x.LONGITUDE,'
||'     x.LATITUDE,'
||'     x.PARTNER_TYPE,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_ORGANIZATION_SITES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.SR_TP_ID'||MSC_UTIL.v_in_all_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

/* added this fix for bug #     2198339 to collect location associations for the Orgs */
IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete,targeted refresh

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql := 'x.ORGANIZATION_ID, ';
ELSE
     v_temp_sql := ' NULL, ';
END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_LOCATION_ASSOCIATIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_LOCATION_ASSOCIATIONS_V';

v_sql_stmt:=
   'INSERT INTO MSC_ST_LOCATION_ASSOCIATIONS'
||' ( LOCATION_ID,'
||'   LOCATION_CODE,'
||'   SR_TP_ID,'
||'   SR_TP_SITE_ID,'
||'   PARTNER_TYPE,'
||'   ORGANIZATION_ID,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.LOCATION_ID,'
||'   x.LOCATION_CODE,'
||'   x.TRADING_PARTNER_ID,'
||'   x.TRADING_PARTNER_SITE_ID,'
||'   3,'
||    v_temp_sql
||'   :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_LOCATION_ASSOCIATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.PARTNER_TYPE= 3';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

END IF;  -- complete refresh

COMMIT;

   END LOAD_TRADING_PARTNER;


--==================================================================

   PROCEDURE LOAD_PARAMETER IS
   BEGIN

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_PARAMETERS';
MSC_CL_PULL.v_view_name := 'MRP_AP_PARAMETERS_V';

v_sql_stmt:=
' insert into MSC_ST_PARAMETERS'
||'   ( ORGANIZATION_ID,'
||'     DEMAND_TIME_FENCE_FLAG,'
||'     PLANNING_TIME_FENCE_FLAG,'
||'     OPERATION_SCHEDULE_TYPE,'
||'     CONSIDER_WIP,'
||'     CONSIDER_PO,'
||'     SNAPSHOT_LOCK,'
||'     PLAN_SAFETY_STOCK,'
||'     CONSIDER_RESERVATIONS,'
||'     PART_INCLUDE_TYPE,'
||'     DEFAULT_ABC_ASSIGNMENT_GROUP,'
||'     PERIOD_TYPE,'
||'     RESCHED_ASSUMPTION,'
||'     PLAN_DATE_DEFAULT_TYPE,'
||'     INCLUDE_REP_SUPPLY_DAYS,'
||'     INCLUDE_MDS_DAYS,'
||'     REPETITIVE_HORIZON1,'
||'     REPETITIVE_HORIZON2,'
||'     REPETITIVE_BUCKET_SIZE1,'
||'     REPETITIVE_BUCKET_SIZE2,'
||'     REPETITIVE_BUCKET_SIZE3,'
||'     REPETITIVE_ANCHOR_DATE,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.ORGANIZATION_ID,'
||'     x.DEMAND_TIME_FENCE_FLAG,'
||'     x.PLANNING_TIME_FENCE_FLAG,'
||'     x.OPERATION_SCHEDULE_TYPE,'
||'     x.CONSIDER_WIP,'
||'     x.CONSIDER_PO,'
||'     x.SNAPSHOT_LOCK,'
||'     x.PLAN_SAFETY_STOCK,'
||'     x.CONSIDER_RESERVATIONS,'
||'     x.PART_INCLUDE_TYPE,'
||'     x.DEFAULT_ABC_ASSIGNMENT_GROUP,'
||'     x.PERIOD_TYPE,'
||'     x.RESCHED_ASSUMPTION,'
||'     x.PLAN_DATE_DEFAULT_TYPE,'
||'     x.INCLUDE_REP_SUPPLY_DAYS,'
||'     x.INCLUDE_MDS_DAYS,'
||'     x.REPETITIVE_HORIZON1,'
||'     x.REPETITIVE_HORIZON2,'
||'     x.REPETITIVE_BUCKET_SIZE1,'
||'     x.REPETITIVE_BUCKET_SIZE2,'
||'     x.REPETITIVE_BUCKET_SIZE3,'
||'     x.REPETITIVE_ANCHOR_DATE,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_PARAMETERS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

   END LOAD_PARAMETER;

--==================================================================

   PROCEDURE LOAD_UOM IS
   BEGIN

IF MSC_CL_PULL.UOM_ENABLED= MSC_UTIL.SYS_YES THEN

MSC_CL_PULL.v_table_name:= 'MSC_ST_UNITS_OF_MEASURE';
MSC_CL_PULL.v_view_name := 'MRP_AP_UNITS_OF_MEASURE_V';

v_sql_stmt:=
' insert into MSC_ST_UNITS_OF_MEASURE'
||'   ( UNIT_OF_MEASURE,'
||'     UOM_CODE,'
||'     UOM_CLASS,'
||'     BASE_UOM_FLAG,'
||'     DISABLE_DATE,'
||'     DESCRIPTION,'
||'     DELETED_FLAG,'
||'   REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.UNIT_OF_MEASURE,'
||'     x.UOM_CODE,'
||'     x.UOM_CLASS,'
||'     x.BASE_UOM_FLAG,'
||'     x.DISABLE_DATE- :v_dgmt,'
||'     x.DESCRIPTION,'
||'     2,'
||'  :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_UNITS_OF_MEASURE_V'||MSC_CL_PULL.v_dblink||' x'
||'  where NVL(x.LANGUAGE, :v_lang)= :v_lang'
||'  AND x.RN1>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lang, MSC_CL_PULL.v_lang;

/* Removed the forked code for 11i source as the column LANGUAGE is again added in
   the view mtl_units_of_measures_vl by the Oracle Inventory team
*/

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_UOM_CLASS_CONVERSIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_UOM_CLASS_CONVERSIONS_V';

v_sql_stmt:=
' insert into MSC_ST_UOM_CLASS_CONVERSIONS'
||'   ( INVENTORY_ITEM_ID,'
||'     FROM_UNIT_OF_MEASURE,'
||'     FROM_UOM_CODE,'
||'     FROM_UOM_CLASS,'
||'     TO_UNIT_OF_MEASURE,'
||'     TO_UOM_CODE,'
||'     TO_UOM_CLASS,'
||'     CONVERSION_RATE,'
||'     DISABLE_DATE,'
||'     DELETED_FLAG,'
||'   REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.INVENTORY_ITEM_ID,'
||'     x.FROM_UNIT_OF_MEASURE,'
||'     x.FROM_UOM_CODE,'
||'     x.FROM_UOM_CLASS,'
||'     x.TO_UNIT_OF_MEASURE,'
||'     x.TO_UOM_CODE,'
||'     x.TO_UOM_CLASS,'
||'     x.CONVERSION_RATE,'
||'     x.DISABLE_DATE- :v_dgmt,'
||'     2,'
||'  :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_UOM_CLASS_CONVERSIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_UOM_CONVERSIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_UOM_CONVERSIONS_V';

v_sql_stmt:=
' insert into MSC_ST_UOM_CONVERSIONS'
||'   ( UNIT_OF_MEASURE,'
||'     UOM_CODE,'
||'     UOM_CLASS,'
||'     INVENTORY_ITEM_ID,'
||'     CONVERSION_RATE,'
||'     DEFAULT_CONVERSION_FLAG,'
||'     DISABLE_DATE,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     UNIT_OF_MEASURE,'
||'     UOM_CODE,'
||'     UOM_CLASS,'
||'     INVENTORY_ITEM_ID,'
||'     CONVERSION_RATE,'
||'     DEFAULT_CONVERSION_FLAG,'
||'     DISABLE_DATE,'
||'     2,'
||'  :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_UOM_CONVERSIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

   END LOAD_UOM;


END MSC_CL_SETUP_PULL;

/
