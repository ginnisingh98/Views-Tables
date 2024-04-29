--------------------------------------------------------
--  DDL for Package Body MSC_CL_OTHER_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_OTHER_PULL" AS -- body
/* $Header:*/



   v_union_sql              varchar2(32767);
   v_temp_tp_sql            VARCHAR2(100);
   v_sql_stmt                    VARCHAR2(32767);
   v_temp_sql                    VARCHAR2(15000);
   v_temp_sql1                   VARCHAR2(1000);
   v_temp_sql2                   VARCHAR2(1000);
   v_temp_sql3                   VARCHAR2(1000);
   v_temp_sql4                   VARCHAR2(1000);
   v_schedule_sql                 VARCHAR2(1000); /* Bug 2634435 */

   --NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
--   NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;

   PROCEDURE LOAD_SAFETY_STOCK IS
   BEGIN

IF MSC_CL_PULL.SS_ENABLED= MSC_UTIL.SYS_YES THEN

   /* Added this piece of code for Safety stocks by Project/Task */
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
    v_temp_sql := 'x.PROJECT_ID,x.TASK_ID,x.PLANNING_GROUP,';
ELSE
    v_temp_sql := ' NULL ,NULL,NULL ,';
END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SAFETY_STOCKS';
MSC_CL_PULL.v_view_name := 'MRP_AP_SAFETY_STOCKS_V';

v_sql_stmt:=
' insert into MSC_ST_SAFETY_STOCKS'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    PERIOD_START_DATE,'
||'    SAFETY_STOCK_QUANTITY,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select '
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.EFFECTIVITY_DATE- :v_dgmt,'
||'    x.SAFETY_STOCK_QUANTITY,'
||     v_temp_sql
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_SAFETY_STOCKS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN2>'||MSC_CL_PULL.v_lrn||')';
/*
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn||')';
*/

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

   END LOAD_SAFETY_STOCK;

--==================================================================

   PROCEDURE LOAD_SCHEDULE IS
   BEGIN

MSC_CL_PULL.v_table_name:= 'MSC_ST_DESIGNATORS';
MSC_CL_PULL.v_view_name := 'MRP_AP_DESIGNATORS_V';

/* Bug 2634435 */

IF (MSC_CL_PULL.v_schedule_flag = MSC_UTIL.G_MDS) THEN
   v_schedule_sql := '  AND x.SCHEDULE_TYPE = 1 ';
ELSIF (MSC_CL_PULL.v_schedule_flag = MSC_UTIL.G_MPS) THEN
   v_schedule_sql := '  AND x.SCHEDULE_TYPE = 2 ';
ELSIF (MSC_CL_PULL.v_schedule_flag = MSC_UTIL.G_BOTH) THEN
   v_schedule_sql := '   ';
END IF;

v_sql_stmt:=
'insert into MSC_ST_DESIGNATORS'
||'  ( DESIGNATOR,'
||'    ORGANIZATION_ID,'
||'    MPS_RELIEF,'
||'    INVENTORY_ATP_FLAG,'
||'    DESCRIPTION,'
||'    DISABLE_DATE,'
||'    DEMAND_CLASS,'
||'    ORGANIZATION_SELECTION,'
||'    PRODUCTION,'
||'    DESIGNATOR_TYPE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select '
||'    x.DESIGNATOR,'
||'    x.ORGANIZATION_ID,'
||'    x.MPS_RELIEF,'
||'    x.INVENTORY_ATP_FLAG,'
||'    x.DESCRIPTION,'
||'    x.DISABLE_DATE- :v_dgmt,'
--||'    DECODE( x.DEMAND_CLASS, NULL, NULL, :V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.ORGANIZATION_SELECTION,'
||'    x.PRODUCTION,'
||'    x.SCHEDULE_TYPE,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_DESIGNATORS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str||v_schedule_sql;

--||'   AND x.RN1>'||MSC_CL_PULL.v_lrn;

--EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

   END LOAD_SCHEDULE;

--==================================================================

   PROCEDURE LOAD_SOURCING IS
   BEGIN

IF MSC_CL_PULL.SOURCING_ENABLED= MSC_UTIL.SYS_YES THEN

MSC_CL_PULL.v_table_name:= 'MSC_ST_ASSIGNMENT_SETS';
MSC_CL_PULL.v_view_name := 'MRP_AP_ASSIGNMENT_SETS_V';

v_sql_stmt:=
' insert into MSC_ST_ASSIGNMENT_SETS'
||'  ( SR_ASSIGNMENT_SET_ID,'
||'    ASSIGNMENT_SET_NAME,'
||'    DESCRIPTION,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.ASSIGNMENT_SET_ID,'
||'    :V_ICODE||x.ASSIGNMENT_SET_NAME,'
||'    x.DESCRIPTION,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_ASSIGNMENT_SETS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN1>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SR_ASSIGNMENTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_SR_ASSIGNMENTS_V';

v_sql_stmt:=
'insert into MSC_ST_SR_ASSIGNMENTS'
||'  ( SR_ASSIGNMENT_ID,'
||'    ASSIGNMENT_TYPE,'
||'    SOURCING_RULE_ID,'
||'    SOURCING_RULE_TYPE,'
||'    ASSIGNMENT_SET_ID,'
||'    INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    SR_INSTANCE_ID,'
||'    PARTNER_ID,'
||'    SHIP_TO_SITE_ID,'
||'    Category_Name,'
||'    Category_Set_Identifier,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_ASSIGNMENT_INSTANCE_ID)'
||'  select'
||'    x.ASSIGNMENT_ID,'
||'    x.ASSIGNMENT_TYPE,'
||'    x.SOURCING_RULE_ID,'
||'    x.SOURCING_RULE_TYPE,'
||'    x.ASSIGNMENT_SET_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    :v_instance_id,'
||'    x.Customer_ID,'
||'    x.Ship_To_Site_ID,'
||'    x.Category_Name,'
||'    x.Category_Set_ID,'
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_SR_ASSIGNMENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE (x.ORGANIZATION_ID'||MSC_UTIL.v_in_all_org_str
    ||'   OR x.ORGANIZATION_ID IS NULL OR decode(x.assignment_type,3,x.organization_id,-1)=x.organization_id) '
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
    ||'    OR x.RN2>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SOURCING_RULES';
MSC_CL_PULL.v_view_name := 'MRP_AP_SOURCING_RULES_V';

v_sql_stmt:=
'insert into MSC_ST_SOURCING_RULES'
||'  ( SR_SOURCING_RULE_ID,'
||'    SOURCING_RULE_NAME,'
||'    ORGANIZATION_ID,'
||'    DESCRIPTION,'
||'    STATUS,'
||'    SOURCING_RULE_TYPE,'
||'    PLANNING_ACTIVE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.SOURCING_RULE_ID,'
||'    x.SOURCING_RULE_NAME,'
||'    x.ORGANIZATION_ID,'
||'    x.DESCRIPTION,'
||'    x.STATUS,'
||'    x.SOURCING_RULE_TYPE,'
||'    x.PLANNING_ACTIVE,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_SOURCING_RULES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE (x.ORGANIZATION_ID'||MSC_UTIL.v_in_all_org_str
    ||'    OR x.ORGANIZATION_ID IS NULL)'
||'   AND x.RN1>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SR_RECEIPT_ORG';
MSC_CL_PULL.v_view_name := 'MRP_AP_SR_RECEIPT_ORG_V';

v_sql_stmt:=
'insert into MSC_ST_SR_RECEIPT_ORG'
||'  ( SR_RECEIPT_ID,'
||'    SR_SR_RECEIPT_ORG,'
||'    RECEIPT_ORG_INSTANCE_ID,'
||'    SOURCING_RULE_ID,'
||'    EFFECTIVE_DATE,'
||'    DISABLE_DATE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.SR_RECEIPT_ID,'
||'    x.RECEIPT_ORGANIZATION_ID,'
||'    :v_instance_id,'
||'    x.SOURCING_RULE_ID,'
||'    x.EFFECTIVE_DATE- :v_dgmt,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_SR_RECEIPT_ORG_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE (x.RECEIPT_ORGANIZATION_ID'||MSC_UTIL.v_in_all_org_str
    ||'    OR x.RECEIPT_ORGANIZATION_ID IS NULL)'
||'   AND x.RN1>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SR_SOURCE_ORG';
MSC_CL_PULL.v_view_name := 'MRP_AP_SR_SOURCE_ORG_V';

v_sql_stmt:=
'insert into MSC_ST_SR_SOURCE_ORG'
||'  ( SR_SR_SOURCE_ID,'
||'    SR_RECEIPT_ID,'
||'    SOURCE_ORGANIZATION_ID,'
||'    SOURCE_ORG_INSTANCE_ID,'
||'    SECONDARY_INVENTORY,'
||'    SOURCE_TYPE,'
||'    ALLOCATION_PERCENT,'
||'    RANK,'
||'    SOURCE_PARTNER_ID,'
||'    SOURCE_PARTNER_SITE_ID,'
||'    SHIP_METHOD,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.SR_SOURCE_ID,'
||'    x.SR_RECEIPT_ID,'
||'    x.SOURCE_ORGANIZATION_ID,'
||'    :v_instance_id,'
||'    x.SECONDARY_INVENTORY,'
||'    x.SOURCE_TYPE,'
||'    x.ALLOCATION_PERCENT,'
||'    x.RANK,'
||'    x.VENDOR_ID,'
||'    x.VENDOR_SITE_ID,'
||'    x.SHIP_METHOD,'
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_SR_SOURCE_ORG_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE (x.SOURCE_ORGANIZATION_ID'||MSC_UTIL.v_in_all_org_str
    ||'    OR x.SOURCE_ORGANIZATION_ID IS NULL)'
||'   AND x.RN1>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_INTERORG_SHIP_METHODS';
MSC_CL_PULL.v_view_name := 'MRP_AP_INTERORG_SHIP_METHODS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
v_temp_sql := ' x.TO_REGION_ID,x.FROM_REGION_ID,x.CURRENCY_CODE,x.SHIP_METHOD_TEXT,';
ELSE
v_temp_sql := 'NULL,NULL,NULL,';
END IF;

v_sql_stmt:=
'Insert into MSC_ST_INTERORG_SHIP_METHODS'
||'  ( FROM_ORGANIZATION_ID,'
||'    TO_ORGANIZATION_ID,'
||'    SHIP_METHOD,'
||'    TIME_UOM_CODE,'
||'    DEFAULT_FLAG,'
||'    FROM_LOCATION_ID,'
||'    TO_LOCATION_ID,'
||'    WEIGHT_CAPACITY,'
||'    WEIGHT_UOM,'
||'    VOLUME_CAPACITY,'
||'    VOLUME_UOM,'
||'    COST_PER_WEIGHT_UNIT,'
||'    COST_PER_VOLUME_UNIT,'
||'    INTRANSIT_TIME,'
||'    TO_REGION_ID,'
||'    FROM_REGION_ID,'
||'    CURRENCY,'
||'    SHIP_METHOD_TEXT,'
||'    TRANSPORT_CAP_OVER_UTIL_COST,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID,'    -- from_org
||'    SR_INSTANCE_ID2)'   -- to_org
||'  SELECT'
||'    x.FROM_ORGANIZATION_ID,'
||'    x.TO_ORGANIZATION_ID,'
||'    x.SHIP_METHOD,'
||'    x.TIME_UOM_CODE,'
||'    x.DEFAULT_FLAG,'
||'    x.FROM_LOCATION_ID,'
||'    x.TO_LOCATION_ID,'
||'    x.DAILY_LOAD_WEIGHT_CAPACITY,'
||'    x.LOAD_WEIGHT_UOM_CODE,'
||'    x.DAILY_VOLUME_CAPACITY,'
||'    x.VOLUME_UOM_CODE,'
||'    x.COST_PER_UNIT_LOAD_WEIGHT,'
||'    x.COST_PER_UNIT_LOAD_VOLUME,'
||'    x.INTRANSIT_TIME,'
||  v_temp_sql
||'    TO_NUMBER(DECODE( :v_mso_trsp_penalty,'
          ||'  1, x.Attribute1,'
          ||'  2, x.Attribute2,'
          ||'  3, x.Attribute3,'
          ||'  4, x.Attribute4,'
          ||'  5, x.Attribute5,'
          ||'  6, x.Attribute6,'
          ||'  7, x.Attribute7,'
          ||'  8, x.Attribute8,'
          ||'  9, x.Attribute9,'
          ||'  10, x.Attribute10,'
          ||'  11, x.Attribute11,'
          ||'  12, x.Attribute12,'
          ||'  13, x.Attribute13,'
          ||'  14, x.Attribute14,'
          ||'  15, x.Attribute15)),'
||'    2,'
||'   :v_refresh_id,'
||'   :v_instance_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_INTERORG_SHIP_METHODS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE (x.FROM_ORGANIZATION_ID'||MSC_UTIL.v_in_all_org_str
    ||'    OR x.FROM_ORGANIZATION_ID IS NULL)'
||'   AND (x.TO_ORGANIZATION_ID'||MSC_UTIL.v_in_all_org_str
    ||'    OR x.TO_ORGANIZATION_ID IS NULL)';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_mso_trsp_penalty,
                                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_instance_id;

COMMIT;


IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN

IF MSC_UTIL.v_msc_tp_coll_window = 0 THEN
   v_temp_tp_sql := NULL;
ELSE
   v_temp_tp_sql := ' WHERE x.LAST_UPDATE_DATE > SYSDATE - :v_msc_tp_coll_window';
END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_REGIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_WSH_REGIONS_V';

 BEGIN

      v_sql_stmt :=
      ' select decode (application_column_name, ''ATTRIBUTE1'',''to_number(x.ATTRIBUTE1)'',
                                       ''ATTRIBUTE2'',''to_number(x.ATTRIBUTE2)'',
                                       ''ATTRIBUTE3'',''to_number(x.ATTRIBUTE3)'',
                                       ''ATTRIBUTE4'',''to_number(x.ATTRIBUTE4)'',
                                       ''ATTRIBUTE5'',''to_number(x.ATTRIBUTE5)'',
                                       ''ATTRIBUTE6'',''to_number(x.ATTRIBUTE6)'',
                                       ''ATTRIBUTE7'',''to_number(x.ATTRIBUTE7)'',
                                       ''ATTRIBUTE8'',''to_number(x.ATTRIBUTE8)'',
                                       ''ATTRIBUTE9'',''to_number(x.ATTRIBUTE9)'',
                                       ''ATTRIBUTE10'',''to_number(x.ATTRIBUTE10)'',
                                       ''ATTRIBUTE11'',''to_number(x.ATTRIBUTE11)'',
                                       ''ATTRIBUTE12'',''to_number(x.ATTRIBUTE12)'',
                                       ''ATTRIBUTE13'',''to_number(x.ATTRIBUTE13)'',
                                       ''ATTRIBUTE14'',''to_number(x.ATTRIBUTE14)'',
                                       ''ATTRIBUTE15'',''to_number(x.ATTRIBUTE15)'',''to_number(NULL)'')'
      ||' from fnd_descr_flex_column_usages'||MSC_CL_PULL.v_dblink
      ||' where end_user_column_name  =  ''Zone Usage'' and   '
      ||' descriptive_flexfield_name = ''WSH_REGIONS''' ;

     execute immediate v_sql_stmt into v_temp_sql;

  EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_temp_sql := 'to_number(NULL) ';
        WHEN OTHERS THEN
          v_temp_sql := 'to_number(NULL) ';

   END ;
/* Changed Rehresh_id to Refresh_number */
v_sql_stmt:=
'Insert into MSC_ST_REGIONS'
||'  ( REGION_ID,'
||'    REGION_TYPE,'
||'    PARENT_REGION_ID,'
||'    COUNTRY_CODE,'
||'    COUNTRY_REGION_CODE,'
||'    STATE_CODE,'
||'    CITY_CODE,'
||'    PORT_FLAG,'
||'    AIRPORT_FLAG,'
||'    ROAD_TERMINAL_FLAG,'
||'    RAIL_TERMINAL_FLAG,'
||'    LONGITUDE,'
||'    LATITUDE,'
||'    TIMEZONE,'
||'    CREATED_BY,'
||'    CREATION_DATE,'
||'    LAST_UPDATED_BY,'
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATE_LOGIN,'
||'    CONTINENT,'
||'    COUNTRY,'
||'    COUNTRY_REGION,'
||'    STATE,'
||'    CITY,'
||'    ZONE,'
||'    ZONE_LEVEL,'
||'    POSTAL_CODE_FROM,'
||'    POSTAL_CODE_TO,'
||'    ALTERNATE_NAME,'
||'    COUNTY,'
||'    REFRESH_NUMBER,'
||'    SR_INSTANCE_ID,'
||'    ZONE_USAGE)'
||'  SELECT'
||'   x.REGION_ID,'
||'   x.REGION_TYPE,'
||'   x.PARENT_REGION_ID,'
||'   x.COUNTRY_CODE,'
||'   x.COUNTRY_REGION_CODE,'
||'   x.STATE_CODE,'
||'   x.CITY_CODE,'
||'   x.PORT_FLAG,'
||'   x.AIRPORT_FLAG,'
||'   x.ROAD_TERMINAL_FLAG,'
||'   x.RAIL_TERMINAL_FLAG,'
||'   x.LONGITUDE,'
||'   x.LATITUDE,'
||'   x.TIMEZONE,'
||'   x.CREATED_BY,'
||'   x.CREATION_DATE,'
||'   x.LAST_UPDATED_BY,'
||'   x.LAST_UPDATE_DATE,'
||'   x.LAST_UPDATE_LOGIN,'
||'   x.CONTINENT,'
||'   x.COUNTRY,'
||'   x.COUNTRY_REGION,'
||'   x.STATE,'
||'   x.CITY,'
||'   x.ZONE,'
||'   x.ZONE_LEVEL,'
||'   x.POSTAL_CODE_FROM,'
||'   x.POSTAL_CODE_TO,'
||'   x.ALTERNATE_NAME,'
||'   x.COUNTY,'
||'   :v_refresh_id,'
||'   :v_instance_id,'
||    v_temp_sql
||'  FROM MRP_AP_WSH_REGIONS_V'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;
COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_ZONE_REGIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_ZONE_REGIONS_V';
/* Changed Refresh_id to Refresh_NUmber */
 v_sql_stmt:=
'Insert into MSC_ST_ZONE_REGIONS'
||'  (ZONE_REGION_ID,'
||'    REGION_ID,'
||'    PARENT_REGION_ID,'
||'    PARTY_ID,'
||'    CREATED_BY,'
||'    CREATION_DATE,'
||'    LAST_UPDATED_BY,'
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATE_LOGIN,'
||'    REFRESH_NUMBER,'
||'    SR_INSTANCE_ID)'
||'  SELECT'
||'   x.ZONE_REGION_ID,'
||'   x.REGION_ID,'
||'   x.PARENT_REGION_ID,'
||'   x.PARTY_ID,'
||'   x.CREATED_BY,'
||'   x.CREATION_DATE,'
||'   x.LAST_UPDATED_BY,'
||'   x.LAST_UPDATE_DATE,'
||'   x.LAST_UPDATE_LOGIN,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_WSH_ZONE_REGIONS_V'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_REGION_SITES';
MSC_CL_PULL.v_view_name := 'MRP_AP_REGION_SITES_V';

 v_sql_stmt:=
'Insert into MSC_ST_REGION_SITES'
||'  ( REGION_ID,'
||'    VENDOR_SITE_ID,'
||'    REGION_TYPE,'
||'    ZONE_LEVEL,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  SELECT'
||'   x.REGION_ID,'
||'   x.VENDOR_SITE_ID,'
||'   x.REGION_TYPE,'
||'   x.ZONE_LEVEL,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_REGION_SITES_V'||MSC_CL_PULL.v_dblink||' x';


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_REGION_LOCATIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_WSH_REGION_LOCATIONS_V';
/* Changed refresh_id to Refresh_Number */
 v_sql_stmt:=
'Insert into MSC_ST_REGION_LOCATIONS'
||'  ( REGION_ID,'
||'    LOCATION_ID,'
||'    REGION_TYPE,'
||'    PARENT_REGION_FLAG,'
||'    EXCEPTION_TYPE,'
||'    LOCATION_SOURCE,'
||'    CREATED_BY,'
||'    CREATION_DATE,'
||'    LAST_UPDATED_BY,'
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATE_LOGIN,'
||'    REFRESH_NUMBER,'
||'    SR_INSTANCE_ID)'
||'  SELECT'
||'   x.REGION_ID,'
||'   x.LOCATION_ID,'
||'   x.REGION_TYPE,'
||'   x.PARENT_REGION_FLAG,'
||'   x.EXCEPTION_TYPE,'
||'   x.LOCATION_SOURCE,'
||'   x.CREATED_BY,'
||'   x.CREATION_DATE,'
||'   x.LAST_UPDATED_BY,'
||'   x.LAST_UPDATE_DATE,'
||'   x.LAST_UPDATE_LOGIN,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_WSH_REGION_LOCATIONS_V'||MSC_CL_PULL.v_dblink||' x' || v_temp_tp_sql;

IF MSC_UTIL.v_msc_tp_coll_window = 0 THEN
   EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id;
ELSE
   EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_UTIL.v_msc_tp_coll_window;
END IF;

COMMIT;

--collecting the carriers

MSC_CL_PULL.v_table_name:= 'MSC_ST_TRADING_PARTNERS';
MSC_CL_PULL.v_view_name := 'MRP_AP_CARRIERS_V';

v_sql_stmt:=
'insert into MSC_ST_TRADING_PARTNERS'
||'  ( SR_TP_ID,'
||'    PARTNER_TYPE,'
||'    PARTNER_NAME,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.CARRIER_ID,'
||'    4,'
||'    x.FREIGHT_CODE,'
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from  MRP_AP_CARRIERS_V'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id;

COMMIT;

-- Pulling Carrier Services for Deployment Planning Changes

MSC_CL_PULL.v_table_name:= 'MSC_ST_CARRIER_SERVICES';
MSC_CL_PULL.v_view_name := 'MRP_AP_CARRIER_SERVICES_V';

 v_sql_stmt:=
'INSERT INTO MSC_ST_CARRIER_SERVICES'
||'  ( 	SHIP_METHOD_CODE,'
||'	    CARRIER_ID,'
||'    	SERVICE_LEVEL,'
||'    	MODE_OF_TRANSPORT,'
||'    	REFRESH_ID,'
||'    	SR_INSTANCE_ID)'
||'  SELECT'
||'    	x.SHIP_METHOD_CODE,'
||'	    x.CARRIER_ID,'
||'    	x.SERVICE_LEVEL,'
||'    	x.MODE_OF_TRANSPORT,'
||'   	:v_refresh_id,'
||'   	:v_instance_id'
||'  FROM MRP_AP_CARRIER_SERVICES_V'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;

COMMIT;


  END IF;  -- APPS version = 115

END IF;  -- complete refresh

END IF;  -- MSC_CL_PULL.SOURCING_ENABLED

   END LOAD_SOURCING;

--==================================================================

   PROCEDURE LOAD_SUB_INVENTORY IS
   BEGIN

MSC_CL_PULL.v_view_name := 'MRP_AP_SUB_INVENTORIES_V';

 IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y') THEN
  IF (MSC_CL_PULL.v_apps_ver > MSC_UTIL.G_APPS115) THEN
   MSC_CL_PULL.v_view_name := 'MRP_AP_SUB_INVENTORIES_NEW_V';
  END IF;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'MSC_UTIL.G_COLLECT_SRP_DATA  = Yes');
MSC_CL_PULL.v_table_name:= 'MSC_ST_SUB_INVENTORIES';
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SRP VIew is  ' ||  MSC_CL_PULL.v_view_name);

       v_sql_stmt:=
                  ' insert into MSC_ST_SUB_INVENTORIES'
                  ||'  (  ORGANIZATION_ID,'
                  ||'     SUB_INVENTORY_CODE,'
                  ||'     DESCRIPTION,'
                  ||'     DISABLE_DATE,'
                  ||'     NETTING_TYPE,'
                  ||'     INVENTORY_ATP_CODE,'
                  ||'     DEMAND_CLASS,'
                  ||'     PROJECT_ID,'
                  ||'     TASK_ID,'
                  ||'     DELETED_FLAG,'
                  ||'     REFRESH_ID,'
                  ||'     SR_INSTANCE_ID,'
                  ||'     condition_type,'
                  ||'     SR_RESOURCE_NAME,'
                  ||'     SR_CUSTOMER_ACCT_ID)'
                  ||'  select'
                  ||'     x.ORGANIZATION_ID,'
                  ||'     x.SECONDARY_INVENTORY_NAME,'
                  ||'     x.DESCRIPTION,'
                  ||'     x.DISABLE_DATE- :v_dgmt,'
                  ||'     x.NETTING_TYPE,'
                  ||'     x.INVENTORY_ATP_CODE,'
                --||'     DECODE( x.DEMAND_CLASS, NULL, NULL, :V_ICODE||x.DEMAND_CLASS),'
                  ||'     x.DEMAND_CLASS,'
                  ||'     x.PROJECT_ID,'
                  ||'     x.TASK_ID,'
                  ||'     2,'
                  ||'     :v_refresh_id,'
                  ||'     :v_instance_id,'
                  ||'     x.condition_type,'
                  ||'     x.SR_RESOURCE_NAME,'
                  ||'     x.SR_CUSTOMER_ACCT_ID'
                  ||'  from ' ||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
                  ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
                  ||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
                  ||'    OR x.RN2>'||MSC_CL_PULL.v_lrn||')';
 else

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUB_INVENTORIES';

v_sql_stmt:=
' insert into MSC_ST_SUB_INVENTORIES'
||'  (  ORGANIZATION_ID,'
||'     SUB_INVENTORY_CODE,'
||'     DESCRIPTION,'
||'     DISABLE_DATE,'
||'     NETTING_TYPE,'
||'     INVENTORY_ATP_CODE,'
||'     DEMAND_CLASS,'
||'     PROJECT_ID,'
||'     TASK_ID,'
||'     DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'     x.ORGANIZATION_ID,'
||'     x.SECONDARY_INVENTORY_NAME,'
||'     x.DESCRIPTION,'
||'     x.DISABLE_DATE- :v_dgmt,'
||'     x.NETTING_TYPE,'
||'     x.INVENTORY_ATP_CODE,'
--||'     DECODE( x.DEMAND_CLASS, NULL, NULL, :V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'     x.PROJECT_ID,'
||'     x.TASK_ID,'
||'     2,'
||'  :v_refresh_id,'
||'     :v_instance_id'
||'  from  MRP_AP_SUB_INVENTORIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn||')';

end if;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SRP SQL stmt is  ' ||  v_sql_stmt);
--EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

   END LOAD_SUB_INVENTORY;


--==================================================================

   PROCEDURE LOAD_UNIT_NUMBER IS
   BEGIN

IF MSC_CL_PULL.v_apps_ver<> MSC_UTIL.G_APPS107 AND MSC_CL_PULL.v_apps_ver<> MSC_UTIL.G_APPS110 THEN

MSC_CL_PULL.v_table_name:= 'MSC_ST_UNIT_NUMBERS';
MSC_CL_PULL.v_view_name := 'MRP_AP_UNIT_NUMBERS_V';

v_sql_stmt:=
' insert into MSC_ST_Unit_Numbers'
||'   ( UNIT_NUMBER,'
||'     END_ITEM_ID,'
||'     MASTER_ORGANIZATION_ID,'
||'     COMMENTS,'
||'     DELETED_FLAG,'
||'   REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.UNIT_NUMBER,'
||'     x.END_ITEM_ID,'
||'     x.MASTER_ORGANIZATION_ID,'
||'     x.COMMENTS,'
||'     2,'
||'  :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_Unit_Numbers_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.MASTER_ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (' --x.RN1>'||MSC_CL_PULL.v_lrn
||'    x.RN2>'||MSC_CL_PULL.v_lrn||')';
--||'    OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;  -- MSC_CL_PULL.v_apps_ver

   END LOAD_UNIT_NUMBER;

--==================================================================

   PROCEDURE LOAD_PROJECT IS
   BEGIN

MSC_CL_PULL.v_table_name:= 'MSC_ST_PROJECTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_PROJECTS_V';

v_sql_stmt:=
' insert into MSC_ST_PROJECTS'
||'   ( PROJECT_ID,'
||'     ORGANIZATION_ID,'
||'     PLANNING_GROUP,'
||'     COSTING_GROUP_ID,'
||'     MATERIAL_ACCOUNT,'
||'     WIP_ACCT_CLASS_CODE,'
||'     SEIBAN_NUMBER_FLAG,'
||'     PROJECT_NAME,'
||'     PROJECT_NUMBER,'
||'     PROJECT_NUMBER_SORT_ORDER,'
||'     PROJECT_DESCRIPTION,'
||'     START_DATE,'
||'     COMPLETION_DATE,'
||'     OPERATING_UNIT,'
||'     MANAGER_CONTACT,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.PROJECT_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.PLANNING_GROUP,'
||'     x.COSTING_GROUP_ID,'
||'     x.MATERIAL_ACCOUNT,'
||'     x.WIP_ACCT_CLASS_CODE,'
||'     x.SEIBAN_NUMBER_FLAG,'
||'     x.PROJECT_NAME,'
||'     x.PROJECT_NUMBER,'
||'     x.PROJECT_NUMBER_SORT_ORDER,'
||'     x.PROJECT_DESCRIPTION,'
||'     x.START_DATE- :v_dgmt,'
||'     x.COMPLETION_DATE- :v_dgmt,'
||'     x.OPERATING_UNIT,'
||'     x.MANAGER_CONTACT,'
||'     2,'
||'  :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_PROJECTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_PROJECT_TASKS';
MSC_CL_PULL.v_view_name := 'MRP_AP_PROJECT_TASKS_V';

v_sql_stmt:=
'insert into MSC_ST_PROJECT_TASKS'
||'   ( ORGANIZATION_ID,'
||'     PROJECT_ID,'
||'     TASK_ID,'
||'     TASK_NUMBER,'
||'     TASK_NAME,'
||'     DESCRIPTION,'
||'     MANAGER,'
||'     START_DATE,'
||'     END_DATE,'
||'     MANAGER_CONTACT,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.ORGANIZATION_ID,'
||'     x.PROJECT_ID,'
||'     x.TASK_ID,'
||'     x.TASK_NUMBER,'
||'     x.TASK_NAME,'
||'     x.DESCRIPTION,'
||'     x.MANAGER,'
||'     x.START_DATE- :v_dgmt,'
||'     x.END_DATE- :v_dgmt,'
||'     x.MANAGER_CONTACT,'
||'     2,'
||'  :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_PROJECT_TASKS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

   END LOAD_PROJECT;


--==================================================================


   PROCEDURE LOAD_BIS107 IS
   BEGIN

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_PERIODS';
MSC_CL_PULL.v_view_name := 'MRP_AP_BIS_PERIODS_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_PERIODS'
||' ( ORGANIZATION_ID,'
||'   PERIOD_SET_NAME,'
||'   PERIOD_NAME,'
||'   START_DATE,'
||'   END_DATE,'
||'   PERIOD_TYPE,'
||'   PERIOD_YEAR,'
||'   PERIOD_NUM,'
||'   QUARTER_NUM,'
||'   ENTERED_PERIOD_NAME,'
||'   ADJUSTMENT_PERIOD_FLAG,'
||'   DESCRIPTION,'
||'   CONTEXT,'
||'   YEAR_START_DATE,'
||'   QUARTER_START_DATE,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.ORGANIZATION_ID,'
||'   x.PERIOD_SET_NAME,'
||'   x.PERIOD_NAME,'
||'   x.START_DATE,'
||'   x.END_DATE,'
||'   x.PERIOD_TYPE,'
||'   x.PERIOD_YEAR,'
||'   x.PERIOD_NUM,'
||'   x.QUARTER_NUM,'
||'   x.ENTERED_PERIOD_NAME,'
||'   x.ADJUSTMENT_PERIOD_FLAG,'
||'   x.DESCRIPTION,'
||'   x.CONTEXT,'
||'   x.YEAR_START_DATE,'
||'   x.QUARTER_START_DATE,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_BIS_PERIODS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||' AND x.ADJUSTMENT_PERIOD_FLAG = ''N'' ';  --svikas


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

END LOAD_BIS107;

   PROCEDURE LOAD_BIS110 IS
   BEGIN

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_PERIODS';
MSC_CL_PULL.v_view_name := 'MRP_AP_BIS_PERIODS_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_PERIODS'
||' ( ORGANIZATION_ID,'
||'   PERIOD_SET_NAME,'
||'   PERIOD_NAME,'
||'   START_DATE,'
||'   END_DATE,'
||'   PERIOD_TYPE,'
||'   PERIOD_YEAR,'
||'   PERIOD_NUM,'
||'   QUARTER_NUM,'
||'   ENTERED_PERIOD_NAME,'
||'   ADJUSTMENT_PERIOD_FLAG,'
||'   DESCRIPTION,'
||'   CONTEXT,'
||'   YEAR_START_DATE,'
||'   QUARTER_START_DATE,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.ORGANIZATION_ID,'
||'   x.PERIOD_SET_NAME,'
||'   x.PERIOD_NAME,'
||'   x.START_DATE,'
||'   x.END_DATE,'
||'   x.PERIOD_TYPE,'
||'   x.PERIOD_YEAR,'
||'   x.PERIOD_NUM,'
||'   x.QUARTER_NUM,'
||'   x.ENTERED_PERIOD_NAME,'
||'   x.ADJUSTMENT_PERIOD_FLAG,'
||'   x.DESCRIPTION,'
||'   x.CONTEXT,'
||'   x.YEAR_START_DATE,'
||'   x.QUARTER_START_DATE,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_BIS_PERIODS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||' AND x.ADJUSTMENT_PERIOD_FLAG = ''N'' ';  --svikas

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

BEGIN

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_PFMC_MEASURES';
MSC_CL_PULL.v_view_name := 'BIS_INDICATORS_VL';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_PFMC_MEASURES'
||' ( MEASURE_ID,'
||'   MEASURE_SHORT_NAME,'
||'   MEASURE_NAME,'
||'   DESCRIPTION,'
||'   ORG_DIMENSION_ID,'
||'   TIME_DIMENSION_ID,'
||'   DIMENSION1_ID,'
||'   DIMENSION2_ID,'
||'   DIMENSION3_ID,'
||'   DIMENSION4_ID,'
||'   DIMENSION5_ID,'
||'   UNIT_OF_MEASURE_CLASS,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.INDICATOR_ID,'
||'   x.SHORT_NAME,'
||'   x.NAME,'
||'   x.DESCRIPTION,'
||'   NULL ORG_DIMENSION_ID,'  --
||'   NULL TIME_DIMENSION_ID,' --
||'   NULL DIMENSION1_ID,'   --
||'   NULL DIMENSION2_ID,' --
||'   NULL DIMENSION3_ID,' --
||'   NULL DIMENSION4_ID,'--
||'   NULL DIMENSION5_ID,'--
||'   NULL UNIT_OF_MEASURE_CLASS,' --
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM BIS_INDICATORS_VL'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_TARGET_LEVELS';
MSC_CL_PULL.v_view_name := 'BIS_TARGET_LEVELS_VL';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_TARGET_LEVELS'
||' ( TARGET_LEVEL_ID,'
||'   TARGET_LEVEL_SHORT_NAME,'
||'   TARGET_LEVEL_NAME,'
||'   DESCRIPTION,'
||'   MEASURE_ID,'
||'   ORG_LEVEL_ID,'
||'   TIME_LEVEL_ID,'
||'   DIMENSION1_LEVEL_ID,'
||'   DIMENSION2_LEVEL_ID,'
||'   DIMENSION3_LEVEL_ID,'
||'   DIMENSION4_LEVEL_ID,'
||'   DIMENSION5_LEVEL_ID,'
||'   WORKFLOW_ITEM_TYPE,'
||'   WORKFLOW_PROCESS_SHORT_NAME,'
||'   DEFAULT_NOTIFY_RESP_ID,'
||'   DEFAULT_NOTIFY_RESP_SHORT_NAME,'
||'   COMPUTING_FUNCTION_ID,'
||'   REPORT_FUNCTION_ID,'
||'   UNIT_OF_MEASURE,'
||'   SYSTEM_FLAG,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.TARGET_LEVEL_ID,'
||'   x.SHORT_NAME,'
||'   x.NAME,'
||'   x.DESCRIPTION,'
||'   x.INDICATOR_ID MEASURE_ID,'     --
||'   x.ORG_LEVEL_ID,'
||'   x.TIME_LEVEL_ID,'
||'   x.DIMENSION1_LEVEL_ID,'
||'   x.DIMENSION2_LEVEL_ID,'
||'   x.DIMENSION3_LEVEL_ID,'
||'   x.DIMENSION4_LEVEL_ID,'
||'   x.DIMENSION5_LEVEL_ID,'
||'   NULL WORKFLOW_ITEM_TYPE,'--
||'   x.WF_PROCESS,'
||'   x.DEFAULT_ROLE_ID,'
||'   x.DEFAULT_ROLE,'
||'   NULL COMPUTING_FUNCTION_ID,' --
||'   NULL REPORT_FUNCTION_ID,' --
||'   NULL UNIT_OF_MEASURE,' --
||'   x.SYSTEM_FLAG,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM BIS_TARGET_LEVELS_VL'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_TARGETS';
MSC_CL_PULL.v_view_name := 'BIS_TARGET_VALUES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_TARGETS'
||' ( TARGET_ID,'
||'   TARGET_LEVEL_ID,'
||'   BUSINESS_PLAN_ID,'
||'   ORG_LEVEL_VALUE_ID,'
||'   TIME_LEVEL_VALUE_ID,'
||'   DIM1_LEVEL_VALUE_ID,'
||'   DIM2_LEVEL_VALUE_ID,'
||'   DIM3_LEVEL_VALUE_ID,'
||'   DIM4_LEVEL_VALUE_ID,'
||'   DIM5_LEVEL_VALUE_ID,'
||'   TARGET,'
||'   RANGE1_LOW,'
||'   RANGE1_HIGH,'
||'   RANGE2_LOW,'
||'   RANGE2_HIGH,'
||'   RANGE3_LOW,'
||'   RANGE3_HIGH,'
||'   NOTIFY_RESP1_ID,'
||'   NOTIFY_RESP1_SHORT_NAME,'
||'   NOTIFY_RESP2_ID,'
||'   NOTIFY_RESP2_SHORT_NAME,'
||'   NOTIFY_RESP3_ID,'
||'   NOTIFY_RESP3_SHORT_NAME,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.TARGET_ID,'
||'   x.TARGET_LEVEL_ID,'
||'   x.PLAN_ID,'
||'   x.ORG_LEVEL_VALUE,'
||'   x.TIME_LEVEL_VALUE,'
||'   x.DIMENSION1_LEVEL_VALUE,'
||'   x.DIMENSION2_LEVEL_VALUE,'
||'   x.DIMENSION3_LEVEL_VALUE,'
||'   x.DIMENSION4_LEVEL_VALUE,'
||'   x.DIMENSION5_LEVEL_VALUE,'
||'   x.TARGET,'
||'   x.RANGE1_LOW,'
||'   x.RANGE1_HIGH,'
||'   x.RANGE2_LOW,'
||'   x.RANGE2_HIGH,'
||'   x.RANGE3_LOW,'
||'   x.RANGE3_HIGH,'
||'   x.ROLE1_ID,'
||'   x.ROLE1,'
||'   x.ROLE2_ID,'
||'   x.ROLE2,'
||'   x.ROLE3_ID,'
||'   x.ROLE3,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM BIS_TARGET_VALUES_V'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_BUSINESS_PLANS';
MSC_CL_PULL.v_view_name := 'BIS_BUSINESS_PLANS_VL';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_BUSINESS_PLANS'
||' ( BUSINESS_PLAN_ID,'
||'   SHORT_NAME,'
||'   NAME,'
||'   DESCRIPTION,'
||'   VERSION_NO,'
||'   CURRENT_PLAN_FLAG,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.PLAN_ID,'
||'   x.SHORT_NAME,'
||'   x.NAME,'
||'   x.DESCRIPTION,'
||'   x.VERSION_NO,'
||'   x.CURRENT_PLAN_FLAG,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM BIS_BUSINESS_PLANS_VL'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

EXCEPTION

   WHEN OTHERS THEN

        ROLLBACK;

        IF SQLCODE<> -942 THEN
           RAISE;
        END IF;
END;

END IF;

   END LOAD_BIS110;


   PROCEDURE LOAD_BIS115 IS
   BEGIN

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_PERIODS';
MSC_CL_PULL.v_view_name := 'MRP_AP_BIS_PERIODS_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_PERIODS'
||' ( ORGANIZATION_ID,'
||'   PERIOD_SET_NAME,'
||'   PERIOD_NAME,'
||'   START_DATE,'
||'   END_DATE,'
||'   PERIOD_TYPE,'
||'   PERIOD_YEAR,'
||'   PERIOD_NUM,'
||'   QUARTER_NUM,'
||'   ENTERED_PERIOD_NAME,'
||'   ADJUSTMENT_PERIOD_FLAG,'
||'   DESCRIPTION,'
||'   CONTEXT,'
||'   YEAR_START_DATE,'
||'   QUARTER_START_DATE,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.ORGANIZATION_ID,'
||'   x.PERIOD_SET_NAME,'
||'   x.PERIOD_NAME,'
||'   x.START_DATE,'
||'   x.END_DATE,'
||'   x.PERIOD_TYPE,'
||'   x.PERIOD_YEAR,'
||'   x.PERIOD_NUM,'
||'   x.QUARTER_NUM,'
||'   x.ENTERED_PERIOD_NAME,'
||'   x.ADJUSTMENT_PERIOD_FLAG,'
||'   x.DESCRIPTION,'
||'   x.CONTEXT,'
||'   x.YEAR_START_DATE,'
||'   x.QUARTER_START_DATE,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM MRP_AP_BIS_PERIODS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||' AND x.ADJUSTMENT_PERIOD_FLAG = ''N'' ';  --svikas

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_PFMC_MEASURES';
MSC_CL_PULL.v_view_name := 'BISBV_PERFORMANCE_MEASURES';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_PFMC_MEASURES'
||' ( MEASURE_ID,'
||'   MEASURE_SHORT_NAME,'
||'   MEASURE_NAME,'
||'   DESCRIPTION,'
||'   ORG_DIMENSION_ID,'
||'   TIME_DIMENSION_ID,'
||'   DIMENSION1_ID,'
||'   DIMENSION2_ID,'
||'   DIMENSION3_ID,'
||'   DIMENSION4_ID,'
||'   DIMENSION5_ID,'
||'   UNIT_OF_MEASURE_CLASS,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.MEASURE_ID,'
||'   x.MEASURE_SHORT_NAME,'
||'   x.MEASURE_NAME,'
||'   x.DESCRIPTION,'
--||'   x.ORG_DIMENSION_ID,'    -- Old values as of version 115.92
--||'   x.TIME_DIMENSION_ID,'   -- Old values as of version 115.92
||'   NULL ORG_DIMENSION_ID,'
||'   NULL TIME_DIMENSION_ID,'
||'   x.DIMENSION1_ID,'
||'   x.DIMENSION2_ID,'
||'   x.DIMENSION3_ID,'
||'   x.DIMENSION4_ID,'
||'   x.DIMENSION5_ID,'
||'   x.UNIT_OF_MEASURE_CLASS,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM BISBV_PERFORMANCE_MEASURES'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_TARGET_LEVELS';
MSC_CL_PULL.v_view_name := 'BISBV_TARGET_LEVELS';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_TARGET_LEVELS'
||' ( TARGET_LEVEL_ID,'
||'   TARGET_LEVEL_SHORT_NAME,'
||'   TARGET_LEVEL_NAME,'
||'   DESCRIPTION,'
||'   MEASURE_ID,'
||'   ORG_LEVEL_ID,'
||'   TIME_LEVEL_ID,'
||'   DIMENSION1_LEVEL_ID,'
||'   DIMENSION2_LEVEL_ID,'
||'   DIMENSION3_LEVEL_ID,'
||'   DIMENSION4_LEVEL_ID,'
||'   DIMENSION5_LEVEL_ID,'
||'   WORKFLOW_ITEM_TYPE,'
||'   WORKFLOW_PROCESS_SHORT_NAME,'
||'   DEFAULT_NOTIFY_RESP_ID,'
||'   DEFAULT_NOTIFY_RESP_SHORT_NAME,'
||'   COMPUTING_FUNCTION_ID,'
||'   REPORT_FUNCTION_ID,'
||'   UNIT_OF_MEASURE,'
||'   SYSTEM_FLAG,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.TARGET_LEVEL_ID,'
||'   x.TARGET_LEVEL_SHORT_NAME,'
||'   x.TARGET_LEVEL_NAME,'
||'   x.DESCRIPTION,'
||'   x.MEASURE_ID,'
||'   x.ORG_LEVEL_ID,'
||'   x.TIME_LEVEL_ID,'
||'   x.DIMENSION1_LEVEL_ID,'
||'   x.DIMENSION2_LEVEL_ID,'
||'   x.DIMENSION3_LEVEL_ID,'
||'   x.DIMENSION4_LEVEL_ID,'
||'   x.DIMENSION5_LEVEL_ID,'
||'   x.WORKFLOW_ITEM_TYPE,'
||'   x.WORKFLOW_PROCESS_SHORT_NAME,'
||'   x.DEFAULT_NOTIFY_RESP_ID,'
||'   x.DEFAULT_NOTIFY_RESP_SHORT_NAME,'
||'   x.COMPUTING_FUNCTION_ID,'
||'   x.REPORT_FUNCTION_ID,'
||'   x.UNIT_OF_MEASURE,'
||'   x.SYSTEM_FLAG,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM BISBV_TARGET_LEVELS'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_TARGETS';
MSC_CL_PULL.v_view_name := 'BISBV_TARGETS';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_TARGETS'
||' ( TARGET_ID,'
||'   TARGET_LEVEL_ID,'
||'   BUSINESS_PLAN_ID,'
||'   ORG_LEVEL_VALUE_ID,'
||'   TIME_LEVEL_VALUE_ID,'
||'   DIM1_LEVEL_VALUE_ID,'
||'   DIM2_LEVEL_VALUE_ID,'
||'   DIM3_LEVEL_VALUE_ID,'
||'   DIM4_LEVEL_VALUE_ID,'
||'   DIM5_LEVEL_VALUE_ID,'
||'   TARGET,'
||'   RANGE1_LOW,'
||'   RANGE1_HIGH,'
||'   RANGE2_LOW,'
||'   RANGE2_HIGH,'
||'   RANGE3_LOW,'
||'   RANGE3_HIGH,'
||'   NOTIFY_RESP1_ID,'
||'   NOTIFY_RESP1_SHORT_NAME,'
||'   NOTIFY_RESP2_ID,'
||'   NOTIFY_RESP2_SHORT_NAME,'
||'   NOTIFY_RESP3_ID,'
||'   NOTIFY_RESP3_SHORT_NAME,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.TARGET_ID,'
||'   x.TARGET_LEVEL_ID,'
||'   x.PLAN_ID,'
||'   x.ORG_LEVEL_VALUE_ID,'
||'   x.TIME_LEVEL_VALUE_ID,'
||'   x.DIM1_LEVEL_VALUE_ID,'
||'   x.DIM2_LEVEL_VALUE_ID,'
||'   x.DIM3_LEVEL_VALUE_ID,'
||'   x.DIM4_LEVEL_VALUE_ID,'
||'   x.DIM5_LEVEL_VALUE_ID,'
||'   x.TARGET,'
||'   x.RANGE1_LOW,'
||'   x.RANGE1_HIGH,'
||'   x.RANGE2_LOW,'
||'   x.RANGE2_HIGH,'
||'   x.RANGE3_LOW,'
||'   x.RANGE3_HIGH,'
||'   x.NOTIFY_RESP1_ID,'
||'   x.NOTIFY_RESP1_SHORT_NAME,'
||'   x.NOTIFY_RESP2_ID,'
||'   x.NOTIFY_RESP2_SHORT_NAME,'
||'   x.NOTIFY_RESP3_ID,'
||'   x.NOTIFY_RESP3_SHORT_NAME,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM BISBV_TARGETS'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BIS_BUSINESS_PLANS';
MSC_CL_PULL.v_view_name := 'BISBV_BUSINESS_PLANS';

v_sql_stmt:=
' INSERT INTO MSC_ST_BIS_BUSINESS_PLANS'
||' ( BUSINESS_PLAN_ID,'
||'   SHORT_NAME,'
||'   NAME,'
||'   DESCRIPTION,'
||'   VERSION_NO,'
||'   CURRENT_PLAN_FLAG,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.PLAN_ID,'
||'   x.SHORT_NAME,'
||'   x.NAME,'
||'   x.DESCRIPTION,'
||'   x.VERSION_NO,'
||'   x.CURRENT_PLAN_FLAG,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||' FROM BISBV_BUSINESS_PLANS'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

   END LOAD_BIS115;

--================ LOAD_ATP_RULES ====================================

   PROCEDURE LOAD_ATP_RULES IS
   BEGIN

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_ATP_RULES';
MSC_CL_PULL.v_view_name := 'MRP_AP_ATP_RULES_V';

v_sql_stmt:=
   'INSERT INTO MSC_ST_ATP_RULES'
||' (  RULE_ID,'
||'    RULE_NAME,'
||'    DESCRIPTION,'
||'    ACCUMULATE_AVAILABLE_FLAG,'
||'    BACKWARD_CONSUMPTION_FLAG,'
||'    FORWARD_CONSUMPTION_FLAG,'
||'    PAST_DUE_DEMAND_CUTOFF_FENCE,'
||'    PAST_DUE_SUPPLY_CUTOFF_FENCE,'
||'    INFINITE_SUPPLY_FENCE_CODE,'
||'    INFINITE_SUPPLY_TIME_FENCE,'
||'    ACCEPTABLE_EARLY_FENCE,'
||'    ACCEPTABLE_LATE_FENCE,'
||'    DEFAULT_ATP_SOURCES,'
||'    DEMAND_CLASS_ATP_FLAG,'
||'    INCLUDE_SALES_ORDERS,'
||'    INCLUDE_DISCRETE_WIP_DEMAND,'
||'    INCLUDE_REP_WIP_DEMAND,'
||'    INCLUDE_NONSTD_WIP_DEMAND,'
||'    INCLUDE_DISCRETE_MPS,'
||'    INCLUDE_USER_DEFINED_DEMAND,'
||'    INCLUDE_PURCHASE_ORDERS,'
||'    INCLUDE_DISCRETE_WIP_RECEIPTS,'
||'    INCLUDE_REP_WIP_RECEIPTS,'
||'    INCLUDE_NONSTD_WIP_RECEIPTS,'
||'    INCLUDE_INTERORG_TRANSFERS,'
||'    INCLUDE_ONHAND_AVAILABLE,'
||'    INCLUDE_USER_DEFINED_SUPPLY,'
||'    ACCUMULATION_WINDOW,'
||'    INCLUDE_REP_MPS,'
||'    INCLUDE_INTERNAL_REQS,'
||'    INCLUDE_SUPPLIER_REQS,'
||'    INCLUDE_INTERNAL_ORDERS,'
||'    INCLUDE_FLOW_SCHEDULE_DEMAND,'
||'    INCLUDE_FLOW_SCHEDULE_RECEIPTS,'
||'    USER_ATP_SUPPLY_TABLE_NAME,'
||'    USER_ATP_DEMAND_TABLE_NAME,'
||'    MPS_DESIGNATOR,'
||'    AGGREGATE_TIME_FENCE_CODE,'
||'    AGGREGATE_TIME_FENCE,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||' SELECT'
||'    RULE_ID,'
||'    RULE_NAME,'
||'    DESCRIPTION,'
||'    ACCUMULATE_AVAILABLE_FLAG,'
||'    BACKWARD_CONSUMPTION_FLAG,'
||'    FORWARD_CONSUMPTION_FLAG,'
||'    PAST_DUE_DEMAND_CUTOFF_FENCE,'
||'    PAST_DUE_SUPPLY_CUTOFF_FENCE,'
||'    INFINITE_SUPPLY_FENCE_CODE,'
||'    INFINITE_SUPPLY_TIME_FENCE,'
||'    ACCEPTABLE_EARLY_FENCE,'
||'    ACCEPTABLE_LATE_FENCE,'
||'    DEFAULT_ATP_SOURCES,'
||'    DEMAND_CLASS_ATP_FLAG,'
||'    INCLUDE_SALES_ORDERS,'
||'    INCLUDE_DISCRETE_WIP_DEMAND,'
||'    INCLUDE_REP_WIP_DEMAND,'
||'    INCLUDE_NONSTD_WIP_DEMAND,'
||'    INCLUDE_DISCRETE_MPS,'
||'    INCLUDE_USER_DEFINED_DEMAND,'
||'    INCLUDE_PURCHASE_ORDERS,'
||'    INCLUDE_DISCRETE_WIP_RECEIPTS,'
||'    INCLUDE_REP_WIP_RECEIPTS,'
||'    INCLUDE_NONSTD_WIP_RECEIPTS,'
||'    INCLUDE_INTERORG_TRANSFERS,'
||'    INCLUDE_ONHAND_AVAILABLE,'
||'    INCLUDE_USER_DEFINED_SUPPLY,'
||'    ACCUMULATION_WINDOW,'
||'    INCLUDE_REP_MPS,'
||'    INCLUDE_INTERNAL_REQS,'
||'    INCLUDE_SUPPLIER_REQS,'
||'    INCLUDE_INTERNAL_ORDERS,'
||'    INCLUDE_FLOW_SCHEDULE_DEMAND,'
||'    INCLUDE_FLOW_SCHEDULE_RECEIPTS,'
||'    USER_ATP_SUPPLY_TABLE_NAME,'
||'    USER_ATP_DEMAND_TABLE_NAME,'
||'    MPS_DESIGNATOR,'
||'    AGGREGATE_TIME_FENCE_CODE,'
||'    AGGREGATE_TIME_FENCE,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||' FROM MRP_AP_ATP_RULES_V'||MSC_CL_PULL.v_dblink||' x';

   EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

   COMMIT;

END IF;

   END LOAD_ATP_RULES;


-- ================= LOAD PLANNERS ================
   PROCEDURE LOAD_PLANNERS IS
   BEGIN

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_PLANNERS';
MSC_CL_PULL.v_view_name := 'MRP_AP_PLANNERS_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_PLANNERS'
||'( PLANNER_CODE,'
||'  ORGANIZATION_ID,'
||'  DESCRIPTION,'
||'  DISABLE_DATE,'
||'  ELECTRONIC_MAIL_ADDRESS,'
||'  EMPLOYEE_ID,'
||'  CURRENT_EMPLOYEE_FLAG,'
||'  USER_NAME,'
||'  DELETED_FLAG,'
||'  REFRESH_ID,'
||'  SR_INSTANCE_ID)'
||' SELECT'
||'  x.PLANNER_CODE,'
||'  x.ORGANIZATION_ID,'
||'  x.DESCRIPTION,'
||'  x.DISABLE_DATE,'
||'  x.ELECTRONIC_MAIL_ADDRESS,'
||'  x.EMPLOYEE_ID,'
||'  x.CURRENT_EMPLOYEE_FLAG,'
||'  x.USER_NAME,'
||'  2,'
||'  :v_refresh_id,'
||'  :v_instance_id'
||' FROM MRP_AP_PLANNERS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

  END LOAD_PLANNERS;


-- ================= LOAD DEMAND_CLASS ================
   PROCEDURE LOAD_DEMAND_CLASS IS
   BEGIN

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMAND_CLASSES';
MSC_CL_PULL.v_view_name := 'MRP_AP_DEMAND_CLASSES_V';

v_sql_stmt:=
'insert into MSC_ST_DEMAND_CLASSES'
||'   ( DEMAND_CLASS,'
||'     MEANING,'
||'     DESCRIPTION,'
||'     FROM_DATE,'
||'     TO_DATE,'
||'     ENABLED_FLAG,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select '
--||'     :V_ICODE||x.DEMAND_CLASS,'
||'     x.DEMAND_CLASS,'
||'     x.MEANING,'
||'     x.DESCRIPTION,'
||'     x.FROM_DATE,'
||'     x.TO_DATE,'
||'     DECODE( x.ENABLED_FLAG, ''Y'', 1 , 2),'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_DEMAND_CLASSES_V'||MSC_CL_PULL.v_dblink||' x';

--EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

  END LOAD_DEMAND_CLASS;

  /* LOAD_TRIP added for Pulling Trips and Trip Stops for Deployment Planning Project */

 PROCEDURE LOAD_TRIP IS
   BEGIN

    IF MSC_CL_PULL.TRIP_ENABLED= MSC_UTIL.SYS_YES AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN

      IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

        MSC_CL_PULL.v_table_name:= 'MSC_ST_TRIPS';
        MSC_CL_PULL.v_view_name := 'MRP_AD_TRIPS_V';

        v_sql_stmt:=
	  ' INSERT INTO MSC_ST_TRIPS'
	||' ( TRIP_ID,'
	||'   DELETED_FLAG,'
	||'   REFRESH_ID,'
	||'   SR_INSTANCE_ID)'
	||' SELECT '
	||'   x.TRIP_ID,'
	||'   1,'
	||'   :v_refresh_id,'
	||'   :v_instance_id'
	||'  FROM MRP_AD_TRIPS_V'||MSC_CL_PULL.v_dblink||' x'
	||' WHERE x.RN>'||MSC_CL_PULL.v_lrn ;

	EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

	COMMIT;

	MSC_CL_PULL.v_table_name:= 'MSC_ST_TRIP_STOPS';
        MSC_CL_PULL.v_view_name := 'MRP_AD_TRIP_STOPS_V';

        v_sql_stmt:=
	  ' INSERT INTO MSC_ST_TRIP_STOPS'
	||' ( STOP_ID,'
	||'   DELETED_FLAG,'
	||'   REFRESH_ID,'
	||'   SR_INSTANCE_ID)'
	||' SELECT '
	||'   x.STOP_ID,'
	||'   1,'
	||'   :v_refresh_id,'
	||'   :v_instance_id'
	||'  FROM MRP_AD_TRIP_STOPS_V'||MSC_CL_PULL.v_dblink||' x'
	||' WHERE x.RN>'||MSC_CL_PULL.v_lrn ;

	EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

	COMMIT;

      END IF;

      MSC_CL_PULL.v_table_name:= 'MSC_ST_TRIPS';
      MSC_CL_PULL.v_view_name := 'MRP_AP_TRIPS_V';

      v_sql_stmt:=
	  ' INSERT INTO MSC_ST_TRIPS'
	||' ( TRIP_ID,'
	||'   NAME,'
	||'   SHIP_METHOD_CODE,'
	||'   PLANNED_FLAG,'
	||'   STATUS_CODE,'
	||'   WEIGHT_CAPACITY,'
	||'   WEIGHT_UOM,'
	||'   VOLUME_CAPACITY,'
	||'   VOLUME_UOM,'
	||'   DELETED_FLAG,'
	||'   REFRESH_ID,'
	||'   SR_INSTANCE_ID)'
	||' SELECT '
	||'   x.TRIP_ID,'
	||'   x.NAME,'
	||'   x.SHIP_METHOD_CODE,'
	||'   x.PLANNED_FLAG,'
	||'   x.STATUS_CODE,'
	||'   x.WEIGHT_CAPACITY,'
	||'   x.WEIGHT_UOM,'
	||'   x.VOLUME_CAPACITY,'
	||'   x.VOLUME_UOM,'
	||'   2,'
	||'   :v_refresh_id,'
	||'   :v_instance_id'
	||'  FROM MRP_AP_TRIPS_V'||MSC_CL_PULL.v_dblink||' x'
	||' WHERE x.RN>'||MSC_CL_PULL.v_lrn ;

      EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

      COMMIT;

      MSC_CL_PULL.v_table_name:= 'MSC_ST_TRIP_STOPS';
      MSC_CL_PULL.v_view_name := 'MRP_AP_TRIP_STOPS_V';

      v_sql_stmt:=
	  ' INSERT INTO MSC_ST_TRIP_STOPS'
	||' ( STOP_ID,'
	||'   STOP_LOCATION_ID,'
	||'   STATUS_CODE,'
	||'   STOP_SEQUENCE_NUMBER,'
	||'   PLANNED_ARRIVAL_DATE,'
	||'   PLANNED_DEPARTURE_DATE,'
	||'   TRIP_ID,'
	||'   DELETED_FLAG,'
	||'   REFRESH_ID,'
	||'   SR_INSTANCE_ID)'
	||' SELECT '
	||'   x.STOP_ID,'
	||'   x.STOP_LOCATION_ID,'
	||'   x.STATUS_CODE,'
	||'   x.STOP_SEQUENCE_NUMBER,'
	||'   x.PLANNED_ARRIVAL_DATE,'
	||'   x.PLANNED_DEPARTURE_DATE,'
	||'   x.TRIP_ID,'
	||'   2,'
	||'   :v_refresh_id,'
	||'   :v_instance_id'
	||'  FROM MRP_AP_TRIP_STOPS_V'||MSC_CL_PULL.v_dblink||' x'
	||' WHERE x.RN>'||MSC_CL_PULL.v_lrn ;

      EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

      COMMIT;

    END IF;  -- MSC_CL_PULL.TRIP_ENABLED

  END LOAD_TRIP;

PROCEDURE LOAD_SALES_CHANNEL IS
BEGIN

  IF MSC_CL_PULL.v_lrnn= -1 AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN     -- complete refresh
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loading Sales Channel');

  MSC_CL_PULL.v_table_name:= 'MSC_ST_SR_LOOKUPS';
  MSC_CL_PULL.v_view_name := 'MRP_AP_SALES_CHANNEL_V';

  v_sql_stmt:=
  'INSERT INTO MSC_ST_SR_LOOKUPS'
  ||'   ( LOOKUP_TYPE,'
  ||'   LOOKUP_CODE,'
  ||'     MEANING,'
  ||'     DESCRIPTION,'
  ||'     FROM_DATE,'
  ||'     TO_DATE,'
  ||'     ENABLED_FLAG,'
  ||'     DELETED_FLAG,'
  ||'     REFRESH_ID,'
  ||'     SR_INSTANCE_ID)'
  ||'  SELECT '
  ||'     ''SALES_CHANNEL'','
  ||'     X. LOOKUP_CODE,'
  ||'     X.MEANING,'
  ||'     X.DESCRIPTION,'
  ||'     X.FROM_DATE,'
  ||'     X.TO_DATE,'
  ||'     DECODE( X.ENABLED_FLAG, ''Y'', 1 , 2),'
  ||'     2,'
  ||'     :v_refresh_id,'
  ||'     :v_instance_id'
  ||'  FROM MRP_AP_SALES_CHANNEL_V'||MSC_CL_PULL.v_dblink||' X';

  EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

  COMMIT;

  END IF;
END LOAD_SALES_CHANNEL;


PROCEDURE LOAD_FISCAL_CALENDAR IS
BEGIN

  IF MSC_CL_PULL.v_lrnn= -1 AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN     -- complete refresh
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loading Fiscal Calendar');

  MSC_CL_PULL.v_table_name:= 'MSC_ST_CALENDAR_MONTHS';
  MSC_CL_PULL.v_view_name := 'MRP_AP_FISCAL_TIME_V';

 v_sql_stmt:=
'INSERT INTO MSC_ST_CALENDAR_MONTHS'
||'   (CALENDAR_CODE,'
||'    CALENDAR_TYPE,'
||'   YEAR,'
||'     YEAR_DESCRIPTION,'
||'     YEAR_START_DATE,'
||'     YEAR_END_DATE,'
||'     QUARTER,'
||'     QUARTER_DESCRIPTION,'
||'     QUARTER_START_DATE  ,'
||'     QUARTER_END_DATE,'
||'     MONTH,'
||'     MONTH_DESCRIPTION,'
||'     MONTH_START_DATE,'
||'     MONTH_END_DATE,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  SELECT '
||'     :V_ICODE||CALENDAR_CODE,'
||'     ''FISCAL'','
||'     X. YEAR,'
||'     X. YEAR_DESCRIPTION,'
||'     X. YEAR_START_DATE,'
||'     X. YEAR_END_DATE  ,'
||'     X. QUARTER,'
||'     X. QUARTER_DESCRIPTION,'
||'     X. QUARTER_START_DATE,'
||'     X. QUARTER_END_DATE  ,'
||'     X. MONTH,'
||'     X. MONTH_DESCRIPTION,'
||'     X. MONTH_START_DATE,'
||'     X. MONTH_END_DATE,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  FROM MRP_AP_FISCAL_TIME_V'||MSC_CL_PULL.v_dblink||' X';

EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.V_ICODE,MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

  COMMIT;

  END IF;
END LOAD_FISCAL_CALENDAR;

-- for bug # 6469722
PROCEDURE LOAD_CURRENCY_CONVERSION IS
BEGIN

  IF MSC_CL_PULL.v_lrnn= -1 AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN     -- complete refresh
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loading Currency Conversion');

  MSC_CL_PULL.v_table_name:= 'MSC_ST_CURRENCY_CONVERSIONS';
  MSC_CL_PULL.v_view_name := 'MRP_AP_CURRENCY_CONV_V';

 v_sql_stmt:=
'INSERT INTO MSC_ST_CURRENCY_CONVERSIONS'
||'   ( SR_INSTANCE_ID,'
||'     FROM_CURRENCY,'
||'     TO_CURRENCY,'
||'     CONV_DATE,'
||'     CONV_TYPE,'
||'     CONV_RATE,'
||'     CREATION_DATE,'
||'     RN,'
||'     CREATED_BY,'
||'     LAST_UPDATE_DATE,'
||'     LAST_UPDATED_BY,'
||'     LAST_UPDATE_LOGIN,'
||'     DELETED_FLAG)'
||'  SELECT '
||'     :v_instance_id,'
||'     XY.FROM_CURRENCY,'
||'     XY.TO_CURRENCY,'
||'     XY.CONVERSION_DATE,'
||'     XY.CONVERSION_TYPE,'
||'     XY.CONVERSION_RATE,'
||'     XY.CREATION_DATE,'
||'     :v_refresh_id,'
||'     XY.CREATED_BY,'
||'     XY.LAST_UPDATE_DATE,'
||'     XY.LAST_UPDATED_BY,'
||'     XY.LAST_UPDATE_LOGIN,'
||'     2'
||'  FROM MRP_AP_CURRENCY_CONV_V' ||MSC_CL_PULL.v_dblink||' XY'
||'  WHERE   CONVERSION_DATE >=  sysdate - :v_msc_past_days AND'
||'  CONVERSION_DATE <= sysdate + :v_msc_future_days   AND'
||'  TO_CURRENCY = :v_msc_hub_curr_code AND'
||'  CONVERSION_TYPE = :v_msc_curr_conv_type';


EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id, MSC_CL_OTHER_PULL.G_MSC_PAST_DAYS, MSC_CL_OTHER_PULL.G_MSC_FUTURE_DAYS, MSC_CL_OTHER_PULL.G_MSC_HUB_CURR_CODE, MSC_CL_OTHER_PULL.G_MSC_CURR_CONV_TYPE;

  COMMIT;

  END IF;
END LOAD_CURRENCY_CONVERSION;

PROCEDURE LOAD_DELIVERY_DETAILS IS
BEGIN

  IF MSC_CL_PULL.v_lrnn= -1 AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120 THEN     -- complete refresh
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loading Delivery Details');

  MSC_CL_PULL.v_table_name:= 'MSC_ST_DELIVERY_DETAILS';
  MSC_CL_PULL.v_view_name := 'MRP_AP_DELIVERY_DETAILS_V';

 v_sql_stmt:=
'INSERT INTO MSC_ST_DELIVERY_DETAILS'
||'   (   SR_INSTANCE_ID,'
||'       DELIVERY_DETAIL_ID,'
||'       SOURCE_CODE ,'
||'       SOURCE_HEADER_ID ,'
||'       SOURCE_LINE_ID ,'
||'       SOURCE_HEADER_NUMBER,'
||'       SHIP_SET_ID,'
||'       ARRIVAL_SET_ID,'
||'       SHIP_FROM_LOCATION_ID,'
||'       ORGANIZATION_ID,'
||'       SHIP_TO_LOCATION_ID,'
||'       SHIP_TO_SITE_USE_ID,'
||'       DELIVER_TO_LOCATION_ID,'
||'       DELIVER_TO_SITE_USE_ID,'
||'       CANCELLED_QUANTITY,'
||'       REQUESTED_QUANTITY,'
||'       REQUESTED_QUANTITY_UOM,'
||'       SHIPPED_QUANTITY,'
||'       DELIVERED_QUANTITY,'
||'       DATE_REQUESTED,'
||'       DATE_SCHEDULED,'
||'       OPERATING_UNIT,'
||'       INV_INTERFACED_FLAG,'
||'       EARLIEST_PICKUP_DATE,'
||'       LATEST_PICKUP_DATE,'
||'       EARLIEST_DROPOFF_DATE,'
||'       LATEST_DROPOFF_DATE,'
||'       REFRESH_NUMBER,'
||'       LAST_UPDATE_DATE,'
||'       LAST_UPDATED_BY,'
||'       CREATION_DATE,'
||'       CREATED_BY,'
||'       LAST_UPDATE_LOGIN'
||'       )'
||'  SELECT '
||'     :v_instance_id,'
||'     XY.DELIVERY_DETAIL_ID,'
||'     XY.SOURCE_CODE,'
||'     XY.SOURCE_HEADER_ID,'
||'     XY.SOURCE_LINE_ID,'
||'     XY.SOURCE_HEADER_NUMBER,'
||'     XY.SHIP_SET_ID,'
||'     XY.ARRIVAL_SET_ID,'
||'     XY.SHIP_FROM_LOCATION_ID,'
||'     XY.ORGANIZATION_ID,'
||'     XY.SHIP_TO_LOCATION_ID,'
||'     XY.SHIP_TO_SITE_USE_ID,'
||'     XY.DELIVER_TO_LOCATION_ID,'
||'     XY.DELIVER_TO_SITE_USE_ID,'
||'     XY.CANCELLED_QUANTITY,'
||'     XY.REQUESTED_QUANTITY,'
||'     XY.REQUESTED_QUANTITY_UOM,'
||'     XY.SHIPPED_QUANTITY,'
||'     XY.DELIVERED_QUANTITY,'
||'     XY.DATE_REQUESTED,'
||'     XY.DATE_SCHEDULED,'
||'     XY.ORG_ID,'
||'     XY.INV_INTERFACED_FLAG,'
||'     XY.EARLIEST_PICKUP_DATE,'
||'     XY.LATEST_PICKUP_DATE,'
||'     XY.EARLIEST_DROPOFF_DATE,'
||'     XY.LATEST_DROPOFF_DATE,'
||'     :v_refresh_id,'
||'     XY.LAST_UPDATE_DATE,'
||'     XY.LAST_UPDATED_BY,'
||'     XY.CREATION_DATE,'
||'     XY.CREATED_BY,'
||'     nvl(XY.LAST_UPDATE_LOGIN,1)'
||'  FROM MRP_AP_DELIVERY_DETAILS_V' ||MSC_CL_PULL.v_dblink||' XY'
||'  WHERE   XY.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;


EXECUTE IMMEDIATE v_sql_stmt
USING  MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id;

  COMMIT;

  END IF;
END LOAD_DELIVERY_DETAILS;

END MSC_CL_OTHER_PULL;

/
