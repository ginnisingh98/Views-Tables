--------------------------------------------------------
--  DDL for Package Body MSC_CL_ITEM_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_ITEM_PULL" AS -- body
/* $Header:*/



   v_union_sql              varchar2(32767);
   v_temp_tp_sql            VARCHAR2(100);
   v_sql_stmt                    VARCHAR2(32767);
   v_temp_sql                    VARCHAR2(15000);
   v_temp_sql1                   VARCHAR2(1000);
   v_temp_sql2                   VARCHAR2(1000);
   v_temp_sql3                   VARCHAR2(1000);
   v_temp_sql4                   VARCHAR2(1000);

  -- NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
  --  NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;

   v_gmp_routine_name       VARCHAR2(50);
   GMP_ERROR                EXCEPTION;


--============================================================

   PROCEDURE LOAD_CATEGORY IS
   BEGIN

IF MSC_CL_PULL.ITEM_ENABLED= MSC_UTIL.SYS_YES THEN

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
	MSC_CL_PULL.v_table_name:= 'MSC_ST_ITEM_CATEGORIES';
	MSC_CL_PULL.v_view_name := 'MRP_AD_ITEM_CATEGORIES_V';
	v_sql_stmt:=
	' insert into MSC_ST_ITEM_CATEGORIES'
	||'( INVENTORY_ITEM_ID,'
	||'  ORGANIZATION_ID,'
	||'  SR_CATEGORY_SET_ID,'
	||'  SR_CATEGORY_ID,'
	||'  DELETED_FLAG,'
	||'  REFRESH_ID,'
	||'  SR_INSTANCE_ID)'
	||' select '
	||'  x.INVENTORY_ITEM_ID,'
	||'  x.ORGANIZATION_ID,'
	||'  x.CATEGORY_SET_ID,'
	||'  x.CATEGORY_ID,'
	||'  1,'
	||'  :v_refresh_id,'
	||'  :v_instance_id'
	||'  from MRP_AD_ITEM_CATEGORIES_V'||MSC_CL_PULL.v_dblink||' x'
	||' WHERE x.RN> :v_lrn ';

	EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

	COMMIT;
END IF;    --- Incremental refresh


MSC_CL_PULL.v_table_name:= 'MSC_ST_ITEM_CATEGORIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_ITEM_CATEGORIES_V';

/* Bug 4365337 - don't need the diff. RNs since Rn1, RN3 and RN4 are anyway 0.
We need to check only for RN2 (both in 11i and rel 11.0)
Hence commenting the entire v_union_sql. The v_sql_stmt itself can handle this
*/

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
v_union_sql :=
'   AND ( x.RN1>'||MSC_CL_PULL.v_lrn||')'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.CATEGORY_SET_ID,'
||'    x.CATEGORY_ID,'
||'    x.CATEGORY_NAME,'
||'    x.DESCRIPTION,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    x.SUMMARY_FLAG,'
||'    x.ENABLED_FLAG,'
||'    x.START_DATE_ACTIVE- :v_dgmt,'
||'    x.END_DATE_ACTIVE- :v_dgmt,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_ITEM_CATEGORIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
--||'   AND NVL(x.LANGUAGE, :v_lang)= :v_lang'
||'   AND ( x.RN2>'||MSC_CL_PULL.v_lrn||')';

/*
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.CATEGORY_SET_ID,'
||'    x.CATEGORY_ID,'
||'    x.CATEGORY_NAME,'
||'    x.DESCRIPTION,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    x.SUMMARY_FLAG,'
||'    x.ENABLED_FLAG,'
||'    x.START_DATE_ACTIVE- :v_dgmt,'
||'    x.END_DATE_ACTIVE- :v_dgmt,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_ITEM_CATEGORIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND NVL(x.LANGUAGE, :v_lang)= :v_lang'
||'   AND ( x.RN3>'||MSC_CL_PULL.v_lrn||')'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.CATEGORY_SET_ID,'
||'    x.CATEGORY_ID,'
||'    x.CATEGORY_NAME,'
||'    x.DESCRIPTION,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    x.SUMMARY_FLAG,'
||'    x.ENABLED_FLAG,'
||'    x.START_DATE_ACTIVE- :v_dgmt,'
||'    x.END_DATE_ACTIVE- :v_dgmt,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_ITEM_CATEGORIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND NVL(x.LANGUAGE, :v_lang)= :v_lang'
||'   AND ( x.RN4>'||MSC_CL_PULL.v_lrn||')' ;
*/
ELSE
/*
v_union_sql :=
'   AND ( x.RN1>'||MSC_CL_PULL.v_lrn
||'        OR x.RN2>'||MSC_CL_PULL.v_lrn
||'        OR x.RN3>'||MSC_CL_PULL.v_lrn
||'        OR x.RN4>'||MSC_CL_PULL.v_lrn||')';
*/
v_union_sql := ' ';
END IF;


v_sql_stmt:=
'insert into MSC_ST_ITEM_CATEGORIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    SR_CATEGORY_SET_ID,'
||'    SR_CATEGORY_ID,'
||'    CATEGORY_NAME,'
||'    DESCRIPTION,'
||'    DISABLE_DATE,'
||'    SUMMARY_FLAG,'
||'    ENABLED_FLAG,'
||'    START_DATE_ACTIVE,'
||'    END_DATE_ACTIVE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.CATEGORY_SET_ID,'
||'    x.CATEGORY_ID,'
||'    x.CATEGORY_NAME,'
||'    x.DESCRIPTION,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    x.SUMMARY_FLAG,'
||'    x.ENABLED_FLAG,'
||'    x.START_DATE_ACTIVE- :v_dgmt,'
||'    x.END_DATE_ACTIVE- :v_dgmt,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_ITEM_CATEGORIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
-- bug 4365337 remove lang cond ||'   AND NVL(x.LANGUAGE, :v_lang)= :v_lang'
--bug 4365337 remove v_union_sql and instead add cond. on RN2
|| v_union_sql ;
--||'        AND x.RN2 >'||MSC_CL_PULL.v_lrn;

--bug 4365337 remove MSC_CL_PULL.v_lang bind parameters since the stmt. does not have it.
/* bug 4365337 - no need to check incremental or not since it is the same stmt.
Hence commenting out the foll. stmt*/
/*  Uncommenting check for incremental refresh */

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt
            USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
--                  MSC_CL_PULL.v_lang, MSC_CL_PULL.v_lang,
                  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
/*                  MSC_CL_PULL.v_lang, MSC_CL_PULL.v_lang,
                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                  MSC_CL_PULL.v_lang, MSC_CL_PULL.v_lang,
                  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
*/
ELSE


EXECUTE IMMEDIATE v_sql_stmt
            USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

-- bug 4365337
END IF;
COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_CATEGORY_SETS';
MSC_CL_PULL.v_view_name := 'MRP_AP_CATEGORY_SETS_V';

v_sql_stmt:=
' insert into MSC_ST_CATEGORY_SETS'
||'  ( SR_CATEGORY_SET_ID,'
||'    CATEGORY_SET_NAME,'
||'    DESCRIPTION,'
||'    CONTROL_LEVEL,'
||'    DEFAULT_FLAG,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.CATEGORY_SET_ID,'
||'    x.CATEGORY_SET_NAME,'
||'    x.DESCRIPTION,'
||'    x.CONTROL_LEVEL,'
||'    x.DEFAULT_FLAG,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_CATEGORY_SETS_V'||MSC_CL_PULL.v_dblink||' x'
||'  where NVL(x.LANGUAGE, :v_lang)= :v_lang'
||'  AND x.RN1>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lang, MSC_CL_PULL.v_lang;

COMMIT;

END IF;

   END LOAD_CATEGORY;


--==================================================================

   PROCEDURE LOAD_ITEM ( p_worker_num IN NUMBER) IS

    lv_in_org_str   varchar2(10240):= NULL;
  lv_uom_code       varchar2(3);
  lv_base_lang_diff number;
  lv_item_name      varchar2(2000) := NULL;
  lv_view_name_stmt   varchar2(1000):= NULL;
  lv_icode	    varchar2(3);
  v_dblink_a2m	    VARCHAR2(128);

   cursor org IS
     select /*+ INDEX(MSC_INSTANCE_ORGS MSC_INSTANCE_ORGS_U1) */ organization_id org_id,
            DECODE( MOD(rownum,MSC_CL_PULL.TOTAL_IWN),
                    p_worker_num, MSC_UTIL.SYS_YES,
                    MSC_UTIL.SYS_NO) yes_flag
       from msc_instance_orgs
       where sr_instance_id= MSC_CL_PULL.v_instance_id
        and enabled_flag= 1
        and ((MSC_CL_PULL.v_org_group = MSC_UTIL.G_ALL_ORGANIZATIONS ) or (org_group = MSC_CL_PULL.v_org_group))
      order by
            organization_id;

   lv_org_count    NUMBER:=0;

   BEGIN

IF MSC_CL_PULL.ITEM_ENABLED= MSC_UTIL.SYS_YES THEN

   FOR lc_ins_org IN org LOOP

       IF lc_ins_org.yes_flag = MSC_UTIL.SYS_YES THEN
          lv_org_count := lv_org_count + 1;

          IF lv_org_count = 1 THEN
             lv_in_org_str:=' IN ('|| lc_ins_org.org_id;
          ELSE
             lv_in_org_str := lv_in_org_str||','||lc_ins_org.org_id;
          END IF;
       END IF;

   END LOOP;

   IF lv_org_count > 0 THEN
      lv_in_org_str:= lv_in_org_str || ')';
   ELSE
      RETURN;
   END IF;


MSC_CL_PULL.v_table_name:= 'MSC_ST_SYSTEM_ITEMS';

if (MSC_CL_PULL.G_COLLECT_ITEM_COSTS = 'N') and (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115) then
	MSC_CL_PULL.v_view_name := 'MRP_AP_NOCOST_SYSTEM_ITEMS_V';
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Debug : View name = ' || MSC_CL_PULL.v_view_name);
else
	MSC_CL_PULL.v_view_name := 'MRP_AP_SYSTEM_ITEMS_V';
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Debug : View name = ' || MSC_CL_PULL.v_view_name);
end if;

BEGIN

IF MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS107 THEN

     v_temp_sql := 'NULL, NULL, NULL, NULL, NULL, x.DESCRIPTION, x.LIST_PRICE ,x.ITEM_NAME, '
                 ||'NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL,'
                 ||' NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL,NULL,NULL, NULL,NULL,';  /* ds change added null*/

ELSIF MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS110 THEN

     v_temp_sql := 'x.REPLENISH_TO_ORDER_FLAG,x.PICK_COMPONENTS_FLAG ,NULL, NULL,NULL, '
		 ||' x.DESCRIPTION, x.LIST_PRICE , x.ITEM_NAME, NULL, NULL,NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, '
		 ||' NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL,NULL, NULL, NULL,NULL,';  /* ds change added null for eam_item_type*/

ELSIF (MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS115)  THEN

     v_temp_sql := ' x.REPLENISH_TO_ORDER_FLAG, x.PICK_COMPONENTS_FLAG ,';

     BEGIN
      -- check if the UOM class is defined for the class in profile option-FM_YIELD_TYPE in source instance
      v_sql_stmt :=   ' select  uom_code  '
                    ||'   from  mtl_units_of_measure'||MSC_CL_PULL.v_dblink
	            ||'  where  uom_class = FND_PROFILE.VALUE'||MSC_CL_PULL.v_dblink||'(''FM_YIELD_TYPE'')'
	            ||'    and  base_uom_flag = ''Y'' ';

      execute immediate v_sql_stmt into lv_uom_code;
      v_temp_sql := v_temp_sql ||' x.CONV_FACTOR, ';

      EXCEPTION
        WHEN OTHERS THEN
          lv_uom_code := NULL;
	  v_temp_sql := v_temp_sql || ' -99999, ';
      END ;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Debug Message - Base uom code : '||lv_uom_code);


     v_temp_sql := v_temp_sql || ' x.CREATE_SUPPLY_FLAG,x.SUBSTITUTION_WINDOW, ';

     BEGIN
      -- check if the base language is different than the installed lang in source instance
      -- If the base installed_flag is same as userenv lang- then dont go to TL table
      v_sql_stmt :=   ' select  1  '
                    ||'   from  fnd_languages'||MSC_CL_PULL.v_dblink
	            ||'  where  language_code = mrp_cl_function.get_userenv_lang'||MSC_CL_PULL.v_dblink
	            ||'    and  installed_flag = ''B'' ';

      execute immediate v_sql_stmt into lv_base_lang_diff;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
		-- This means that the base installed lang is different than the userenv(LANG)
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Source Environment Language is different then Base Installed Language');
          lv_base_lang_diff := 2;
        WHEN OTHERS THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Unhandled Exception when trying to identify Base Installed Language');
          lv_base_lang_diff := 1;
      END ;

      IF (lv_base_lang_diff = 1) THEN
	 v_temp_sql := v_temp_sql || ' x.DESCRIPTION, ';
      ELSE
         v_temp_sql := v_temp_sql ||' x.DESCRIPTION_TL , ';
      END IF;

      -- If Profile does not contain a Price List then for discrete list_price is null here but in ODS Load
      -- the nvl(list_price,item_cost) is performed, for process get the List Price.
      IF MSC_CL_PULL.v_mrp_bis_price_list is null THEN
	v_temp_sql := v_temp_sql ||'  x.LIST_PRICE, ';
      ELSE
	v_temp_sql := v_temp_sql ||'  x.MRP_BIS_LIST_PRICE, ';
      END IF;

      BEGIN
      -- check if the base language is different than the installed lang in source instance
      -- If the base installed_flag is same as userenv lang- then dont go to TL table

      select instance_code, DECODE(A2M_DBLINK, NULL, MSC_UTIL.NULL_DBLINK, A2M_DBLINK)
      	     into lv_icode, v_dblink_a2m
      from msc_apps_instances where instance_id = MSC_CL_PULL.v_instance_id;

      v_sql_stmt :=   ' select  item_name_from_kfv  '
		    ||' from  MRP_AP_APPS_INSTANCES_ALL'||MSC_CL_PULL.v_dblink
		    ||' WHERE INSTANCE_ID = '||MSC_CL_PULL.v_instance_id
                    ||' AND   INSTANCE_CODE= '''||lv_icode||''''
                    ||' AND   nvl(A2M_DBLINK,'||''''||MSC_UTIL.NULL_DBLINK ||''''||') = '''||v_dblink_a2m||'''';

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'item kfv v_sql_stmt - ' || v_sql_stmt);

      execute immediate v_sql_stmt into lv_item_name;

      EXCEPTION
	WHEN OTHERS THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in deriving item_name kfv...setting to segment1 - ' || sqlerrm);
	  lv_item_name := 'x.SEGMENT1';
      END ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Debug: Item Name String: '|| lv_item_name);
      v_temp_sql := v_temp_sql ||'  '|| lv_item_name ||', ';

      -- for Bugfix 3057925
        v_temp_sql := v_temp_sql ||'  x.REDUCE_MPS,x.CRITICAL_COMPONENT_FLAG,x.VMI_MINIMUM_UNITS,x.VMI_MINIMUM_DAYS,x.VMI_MAXIMUM_UNITS, '
                                 ||'  x.VMI_MAXIMUM_DAYS,x.VMI_FIXED_ORDER_QUANTITY,x.SO_AUTHORIZATION_FLAG,x.CONSIGNED_FLAG,x.ASN_AUTOEXPIRE_FLAG, '
                                 ||'  x.VMI_FORECAST_TYPE,x.FORECAST_HORIZON,x.EXCLUDE_FROM_BUDGET_FLAG,x.DAYS_TGT_INV_SUPPLY,x.DAYS_TGT_INV_WINDOW, '
                                 ||'  x.DAYS_MAX_INV_SUPPLY,x.DAYS_MAX_INV_WINDOW,x.DRP_PLANNED_FLAG,x.CONTINOUS_TRANSFER,x.CONVERGENCE,x.DIVERGENCE,'
                                 ||'  x.EAM_ITEM_TYPE, x.MSIB_CREATION_DATE, x.SHORTAGE_TYPE ,  x.EXCESS_TYPE ,x.PLANNING_TIME_FENCE_CODE,NULL,NULL,NULL,NULL,';   /* ds change eam_item_type added */



 /* # For Bug 5606037 SRP Changes NULL Colums to collect Item Attribute Data */

ELSIF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120 THEN  --# For Bug 5606037 SRP Changes

     v_temp_sql := ' x.REPLENISH_TO_ORDER_FLAG, x.PICK_COMPONENTS_FLAG ,';

     BEGIN
      -- check if the UOM class is defined for the class in profile option-FM_YIELD_TYPE in source instance
      v_sql_stmt :=   ' select  uom_code  '
                    ||'   from  mtl_units_of_measure'||MSC_CL_PULL.v_dblink
	            ||'  where  uom_class = FND_PROFILE.VALUE'||MSC_CL_PULL.v_dblink||'(''FM_YIELD_TYPE'')'
	            ||'    and  base_uom_flag = ''Y'' ';

      execute immediate v_sql_stmt into lv_uom_code;
      v_temp_sql := v_temp_sql ||' x.CONV_FACTOR, ';

      EXCEPTION
        WHEN OTHERS THEN
          lv_uom_code := NULL;
	  v_temp_sql := v_temp_sql || ' -99999, ';
      END ;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Debug Message - Base uom code : '||lv_uom_code);
      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'item kfv v_sql_stmt of MSC_UTIL.G_APPS120 - ' || v_sql_stmt);

     v_temp_sql := v_temp_sql || ' x.CREATE_SUPPLY_FLAG,x.SUBSTITUTION_WINDOW, ';

     BEGIN
      -- check if the base language is different than the installed lang in source instance
      -- If the base installed_flag is same as userenv lang- then dont go to TL table
      v_sql_stmt :=   ' select  1  '
                    ||'   from  fnd_languages'||MSC_CL_PULL.v_dblink
	            ||'  where  language_code = mrp_cl_function.get_userenv_lang'||MSC_CL_PULL.v_dblink
	            ||'    and  installed_flag = ''B'' ';

      execute immediate v_sql_stmt into lv_base_lang_diff;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
		-- This means that the base installed lang is different than the userenv(LANG)
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Source Environment Language is different then Base Installed Language');
          lv_base_lang_diff := 2;
        WHEN OTHERS THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Unhandled Exception when trying to identify Base Installed Language');
          lv_base_lang_diff := 1;
      END ;

      IF (lv_base_lang_diff = 1) THEN
	 v_temp_sql := v_temp_sql || ' x.DESCRIPTION, ';
      ELSE
         v_temp_sql := v_temp_sql ||' x.DESCRIPTION_TL , ';
      END IF;

      -- If Profile does not contain a Price List then for discrete list_price is null here but in ODS Load
      -- the nvl(list_price,item_cost) is performed, for process get the List Price.
      IF MSC_CL_PULL.v_mrp_bis_price_list is null THEN
	v_temp_sql := v_temp_sql ||'  x.LIST_PRICE, ';
      ELSE
	v_temp_sql := v_temp_sql ||'  x.MRP_BIS_LIST_PRICE, ';
      END IF;

      BEGIN
      -- check if the base language is different than the installed lang in source instance
      -- If the base installed_flag is same as userenv lang- then dont go to TL table

      select instance_code, DECODE(A2M_DBLINK, NULL, MSC_UTIL.NULL_DBLINK, A2M_DBLINK)
      	     into lv_icode, v_dblink_a2m
      from msc_apps_instances where instance_id = MSC_CL_PULL.v_instance_id;

      v_sql_stmt :=   ' select  item_name_from_kfv  '
		    ||' from  MRP_AP_APPS_INSTANCES_ALL'||MSC_CL_PULL.v_dblink
		    ||' WHERE INSTANCE_ID = '||MSC_CL_PULL.v_instance_id
                    ||' AND   INSTANCE_CODE= '''||lv_icode||''''
                    ||' AND   nvl(A2M_DBLINK,'||''''||MSC_UTIL.NULL_DBLINK ||''''||') = '''||v_dblink_a2m||'''';

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'item kfv v_sql_stmt - ' || v_sql_stmt);

      execute immediate v_sql_stmt into lv_item_name;

      EXCEPTION
	WHEN OTHERS THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in deriving item_name kfv...setting to segment1 - ' || sqlerrm);
	  lv_item_name := 'x.SEGMENT1';
      END ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Debug: Item Name String: '|| lv_item_name);
      v_temp_sql := v_temp_sql ||'  '|| lv_item_name ||', ';

      -- for Bugfix 3057925
        v_temp_sql := v_temp_sql ||'  x.REDUCE_MPS,x.CRITICAL_COMPONENT_FLAG,x.VMI_MINIMUM_UNITS,x.VMI_MINIMUM_DAYS,x.VMI_MAXIMUM_UNITS, '
                                 ||'  x.VMI_MAXIMUM_DAYS,x.VMI_FIXED_ORDER_QUANTITY,x.SO_AUTHORIZATION_FLAG,x.CONSIGNED_FLAG,x.ASN_AUTOEXPIRE_FLAG, '
                                 ||'  x.VMI_FORECAST_TYPE,x.FORECAST_HORIZON,x.EXCLUDE_FROM_BUDGET_FLAG,x.DAYS_TGT_INV_SUPPLY,x.DAYS_TGT_INV_WINDOW, '
                                 ||'  x.DAYS_MAX_INV_SUPPLY,x.DAYS_MAX_INV_WINDOW,x.DRP_PLANNED_FLAG,x.CONTINOUS_TRANSFER,x.CONVERGENCE,x.DIVERGENCE,'
                                 ||'  x.EAM_ITEM_TYPE, x.MSIB_CREATION_DATE, x.SHORTAGE_TYPE ,  x.EXCESS_TYPE ,x.PLANNING_TIME_FENCE_CODE,x.REPAIR_LEADTIME,x.preposition_point,x.REPAIR_YIELD,x.repair_program,';   /* ds change eam_item_type added */
                                                                                   --# For Bug 5606037 SRP Changes

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Debug: v_temp_sql String: '|| v_temp_sql);
END IF; --# For Bug 5606037 SRP Changes

End;


if (MSC_CL_PULL.G_COLLECT_ITEM_COSTS = 'N') and (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115) then
	lv_view_name_stmt := '  from MRP_AP_NOCOST_SYSTEM_ITEMS_V'||MSC_CL_PULL.v_dblink||' x';
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Debug : lv_view_name_stmt = ' || lv_view_name_stmt);
else
	lv_view_name_stmt := '  from MRP_AP_SYSTEM_ITEMS_V'||MSC_CL_PULL.v_dblink||' x';
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Debug : lv_view_name_stmt = ' || lv_view_name_stmt);
end if;



v_sql_stmt:=
'insert into MSC_ST_SYSTEM_ITEMS'
||' ( ORGANIZATION_ID,'
||'   SR_INVENTORY_ITEM_ID,'
||'   LOTS_EXPIRATION,'
||'   LOT_CONTROL_CODE,'
||'   SHRINKAGE_RATE,'
||'   FIXED_DAYS_SUPPLY,'
||'   FIXED_ORDER_QUANTITY,'
||'   FIXED_LOT_MULTIPLIER,'
||'   MINIMUM_ORDER_QUANTITY,'
||'   MAXIMUM_ORDER_QUANTITY,'
||'   ROUNDING_CONTROL_TYPE,'
||'   PLANNING_TIME_FENCE_DAYS,'
||'   DEMAND_TIME_FENCE_DAYS,'
||'   ABC_CLASS_ID,'
||'   ABC_CLASS_NAME,'
||'   SR_CATEGORY_ID,'
||'   CATEGORY_NAME,'
||'   MRP_PLANNING_CODE,'
||'   FIXED_LEAD_TIME,'
||'   VARIABLE_LEAD_TIME,'
||'   PREPROCESSING_LEAD_TIME,'
||'   POSTPROCESSING_LEAD_TIME,'
||'   FULL_LEAD_TIME,'
||'   CUMULATIVE_TOTAL_LEAD_TIME,'
||'   CUM_MANUFACTURING_LEAD_TIME,'
||'   UOM_CODE,'
||'   BUILT_IN_WIP_FLAG,'
||'   PURCHASING_ENABLED_FLAG,'
||'   PLANNING_MAKE_BUY_CODE,'
||'   STANDARD_COST,'
||'   CARRYING_COST,'
||'   MRP_CALCULATE_ATP_FLAG,'
||'   END_ASSEMBLY_PEGGING_FLAG,'
||'   ENGINEERING_ITEM_FLAG,'
||'   INVENTORY_ITEM_FLAG,'
||'   WIP_SUPPLY_TYPE,'
||'   MRP_SAFETY_STOCK_CODE,'
||'   MRP_SAFETY_STOCK_PERCENT,'
||'   SAFETY_STOCK_BUCKET_DAYS,'
||'   ACCEPTABLE_EARLY_DELIVERY,'
||'   BUYER_NAME,'
||'   PLANNER_CODE,'
||'   PLANNING_EXCEPTION_SET,'
||'   EXCESS_QUANTITY,'
||'   EXCEPTION_SHORTAGE_DAYS,'
||'   EXCEPTION_EXCESS_DAYS,'
||'   EXCEPTION_OVERPROMISED_DAYS,'
||'   REPETITIVE_VARIANCE_DAYS,'
||'   BASE_ITEM_ID,'
||'   BOM_ITEM_TYPE,'
||'   ATO_FORECAST_CONTROL,'
||'   EFFECTIVITY_CONTROL,'
||'   INVENTORY_PLANNING_CODE,'
||'   UNIT_WEIGHT,'
||'   UNIT_VOLUME,'
||'   WEIGHT_UOM,'
||'   VOLUME_UOM,'
||'   PRODUCT_FAMILY_ID,'
||'   RELEASE_TIME_FENCE_CODE,'
||'   RELEASE_TIME_FENCE_DAYS,'
||'   ATP_RULE_ID,'
||'   ORDER_COST,'
||'   ATP_COMPONENTS_FLAG,'
||'   REPETITIVE_TYPE,'
||'   ORGANIZATION_CODE,'
||'   INVENTORY_TYPE,'
||'   IN_SOURCE_PLAN,'
||'   ATP_FLAG,'
||'   REVISION_QTY_CONTROL_CODE,'
||'   EXPENSE_ACCOUNT,'
||'   INVENTORY_ASSET_FLAG,'
||'   ACCEPTABLE_RATE_DECREASE,'
||'   ACCEPTABLE_RATE_INCREASE,'
||'   BUYER_ID,'
||'   SOURCE_ORG_ID,'
||'   DMD_LATENESS_COST,'
||'   SUPPLIER_CAP_OVERUTIL_COST,'
||'   MATERIAL_COST,'
||'   RESOURCE_COST,'
||'   AVERAGE_DISCOUNT,'
||'   DELETED_FLAG,'
||'   PIP_FLAG,'
||'   REPLENISH_TO_ORDER_FLAG,' /* temp start */
||'   PICK_COMPONENTS_FLAG,'
||'   YIELD_CONV_FACTOR,'
||'   CREATE_SUPPLY_FLAG,'
||'   SUBSTITUTION_WINDOW,'
||'   DESCRIPTION,'
||'   LIST_PRICE,'
||'   ITEM_NAME,'
||'   REDUCE_MPS,'
||'   CRITICAL_COMPONENT_FLAG,'
||'   VMI_MINIMUM_UNITS,'
||'   VMI_MINIMUM_DAYS,'
||'   VMI_MAXIMUM_UNITS,'
||'   VMI_MAXIMUM_DAYS,'
||'   VMI_FIXED_ORDER_QUANTITY,'
||'   SO_AUTHORIZATION_FLAG,'
||'   CONSIGNED_FLAG,'
||'   ASN_AUTOEXPIRE_FLAG,'
||'   VMI_FORECAST_TYPE,'
||'   FORECAST_HORIZON,'
||'   BUDGET_CONSTRAINED,'
||'   DAYS_TGT_INV_SUPPLY,'
||'   DAYS_TGT_INV_WINDOW,'
||'   DAYS_MAX_INV_SUPPLY,'
||'   DAYS_MAX_INV_WINDOW,'
||'   DRP_PLANNED,'
||'   CONTINOUS_TRANSFER,'
||'   CONVERGENCE,'
||'   DIVERGENCE,'
||'   EAM_ITEM_TYPE,'  /* ds change */
||'   ITEM_CREATION_DATE,'
||'   SHORTAGE_TYPE,'
||'   EXCESS_TYPE,'
||'   PLANNING_TIME_FENCE_CODE,'
||'   REPAIR_LEAD_TIME,'
||'   PREPOSITION_POINT,'
||'   REPAIR_YIELD,'
||'   REPAIR_PROGRAM,'
||'   SOURCE_TYPE,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||'  select'
||'   x.ORGANIZATION_ID,'
||'   x.INVENTORY_ITEM_ID,'
||'   x.LOTS_EXPIRATION,'
||'   x.LOT_CONTROL_CODE,'
||'   x.SHRINKAGE_RATE,'
||'   x.FIXED_DAYS_SUPPLY,'
||'   x.FIXED_ORDER_QUANTITY,'
||'   x.FIXED_LOT_MULTIPLIER,'
||'   x.MINIMUM_ORDER_QUANTITY,'
||'   x.MAXIMUM_ORDER_QUANTITY,'
||'   x.ROUNDING_CONTROL_TYPE,'
||'   x.PLANNING_TIME_FENCE_DAYS,'
||'   x.DEMAND_TIME_FENCE_DAYS,'
||'   x.ABC_CLASS_ID,'
||'   x.ABC_CLASS_NAME,'
||'   x.CATEGORY_ID,'
||'   x.CATEGORY_NAME,'
||'   x.MRP_PLANNING_CODE,'
||'   x.FIXED_LEAD_TIME,'
||'   x.VARIABLE_LEAD_TIME,'
||'   x.PREPROCESSING_LEAD_TIME,'
||'   x.POSTPROCESSING_LEAD_TIME,'
||'   x.FULL_LEAD_TIME,'
||'   x.CUMULATIVE_TOTAL_LEAD_TIME,'
||'   x.CUM_MANUFACTURING_LEAD_TIME,'
||'   x.UOM_CODE,'
||'   x.BUILT_IN_WIP_FLAG,'
||'   x.PURCHASING_ENABLED_FLAG,'
||'   x.PLANNING_MAKE_BUY_CODE,'
||'   x.ITEM_COST,'
||'   x.CARRYING_COST,'
||'   x.MRP_CALCULATE_ATP_FLAG,'
||'   x.END_ASSEMBLY_PEGGING_FLAG,'
||'   x.ENG_ITEM_FLAG,'
||'   x.INVENTORY_ITEM_FLAG,'
||'   x.WIP_SUPPLY_TYPE,'
||'   x.MRP_SAFETY_STOCK_CODE,'
||'   x.MRP_SAFETY_STOCK_PERCENT,'
||'   x.SAFETY_STOCK_BUCKET_DAYS,'
||'   x.ACCEPTABLE_EARLY_DELIVERY,'
||'   x.BUYER_NAME,'
||'   x.PLANNER_CODE,'
||'   x.PLANNING_EXCEPTION_SET,'
||'   x.EXCESS_QUANTITY,'
||'   x.EXCEPTION_SHORTAGE_DAYS,'
||'   x.EXCEPTION_EXCESS_DAYS,'
||'   x.EXCEPTION_OVERPROMISED_DAYS,'
||'   x.REPETITIVE_VARIANCE_DAYS,'
||'   x.BASE_ITEM_ID,'
||'   x.BOM_ITEM_TYPE,'
||'   x.ATO_FORECAST_CONTROL,'
||'   x.EFFECTIVITY_CONTROL,'
||'   x.INVENTORY_PLANNING_CODE,'
||'   x.UNIT_WEIGHT,'
||'   x.UNIT_VOLUME,'
||'   x.WEIGHT_UOM,'
||'   x.VOLUME_UOM,'
||'   x.PRODUCT_FAMILY_ID,'
||'   x.RELEASE_TIME_FENCE_CODE,'
||'   x.RELEASE_TIME_FENCE_DAYS,'
||'   x.ATP_RULE_ID,'
||'   x.ORDER_COST,'
||'   x.ATP_COMPONENTS_FLAG,'
||'   x.REPETITIVE_TYPE,'
||'   :V_ICODE||x.ORGANIZATION_CODE,'
||'   x.INVENTORY_TYPE,'
||'   2,'
||'   x.ATP_FLAG,'
||'   x.REVISION_QTY_CONTROL_CODE,'
||'   x.EXPENSE_ACCOUNT,'
||'   x.INVENTORY_ASSET_FLAG,'
||'   x.ACCEPTABLE_RATE_DECREASE,'
||'   x.ACCEPTABLE_RATE_INCREASE,'
||'   x.BUYER_ID,'
||'   x.SOURCE_ORG_ID,'
||'    TO_NUMBER(DECODE( :v_mso_item_dmd_penalty,'
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
||'    TO_NUMBER(DECODE( :v_mso_item_cap_penalty,'
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
||'   x.MATERIAL_COST,'
||'   x.RESOURCE_COST,'
||'   :v_mrp_bis_av_discount,'
||'   2,'
||'   DECODE(x.PLANNED_INVENTORY_POINT,1,1,2) ,'
||    v_temp_sql
||'   x.SOURCE_TYPE,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||  lv_view_name_stmt
||' WHERE x.ORGANIZATION_ID'||lv_in_org_str;



IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

        --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Debug : view sql stmt = ' || v_sql_stmt);
          --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'debug: v_temp_sql ='||v_temp_sql);
                 EXECUTE IMMEDIATE v_sql_stmt
	                     USING MSC_CL_PULL.V_ICODE,
                                   MSC_CL_PULL.v_mso_item_dmd_penalty,
                                   MSC_CL_PULL.v_mso_item_cap_penalty,
                                   MSC_CL_PULL.v_mrp_bis_av_discount,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;

ELSE  -- net change

                v_sql_stmt := v_sql_stmt ||'   AND x.RN1> :v_lrn  ';

                 EXECUTE IMMEDIATE v_sql_stmt
			     USING MSC_CL_PULL.V_ICODE,
                                   MSC_CL_PULL.v_mso_item_dmd_penalty,
                                   MSC_CL_PULL.v_mso_item_cap_penalty,
                                   MSC_CL_PULL.v_mrp_bis_av_discount,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
				   MSC_CL_PULL.v_lrn;

END IF;

COMMIT;

END IF;  -- MSC_CL_PULL.ITEM_ENABLED

   END LOAD_ITEM;


--==================================================================

   PROCEDURE LOAD_SUPPLIER_CAPACITY IS
   lv_last_asl_collection_date  DATE ;
   BEGIN


IF MSC_CL_PULL.SUPPLIER_CAP_ENABLED= MSC_UTIL.ASL_YES  or  MSC_CL_PULL.SUPPLIER_CAP_ENABLED=MSC_UTIL.ASL_YES_RETAIN_CP  THEN

MSC_CL_PULL.v_table_name:= 'MSC_ST_ITEM_SUPPLIERS';

/*ASL */
IF MSC_CL_PULL.v_lrnn = -1 THEN
		MSC_CL_PULL.v_view_name := 'MRP_AP_PO_SUPPLIERS_V';
ELSIF (MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 and MSC_CL_PULL.v_lrnn <>-1) THEN   -- incremental
  MSC_CL_PULL.v_view_name := 'MRP_AN_PO_SUPPLIERS_V';
  v_sql_stmt := 'Select min (nvl(LAST_SUCC_ASL_REF_TIME,SYSDATE-365000))'
   						  ||'  From msc_instance_orgs '
   							||'  Where sr_instance_id = ' || MSC_CL_PULL.v_instance_id
  							||'  And   organization_id '|| MSC_UTIL.v_in_org_str;

 -- MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'the sql statement is ' || v_sql_stmt);

  EXECUTE IMMEDIATE v_sql_stmt  into lv_last_asl_collection_date;

  --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'the sql statement is ' || v_sql_stmt);
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'last successful ASL Collection refresh time is '||lv_last_asl_collection_date);
END IF ;
/*ASL*/

/* Added this to collect Item Price information for a supplier
from 11i/110 source */
Begin
Select decode(MSC_CL_PULL.v_apps_ver,MSC_UTIL.G_APPS107,' NULL,', ' x.ITEM_PRICE,')
into v_temp_sql
from dual;
End;

/* Added this code for VMI changes */
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql1 := ' x.ENABLE_VMI_FLAG, x.VMI_MIN_QTY, x.VMI_MAX_QTY, x.ENABLE_VMI_AUTO_REPLENISH_FLAG, x.VMI_REPLENISHMENT_APPROVAL,'
               || ' x.REPLENISHMENT_METHOD,x.MIN_MINMAX_DAYS,x.MAX_MINMAX_DAYS,x.FORECAST_HORIZON,x.FIXED_ORDER_QUANTITY, ';

ELSE
   v_temp_sql1 := 'NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL,NULL,';
END IF;


	IF MSC_CL_PULL.v_lrnn =-1 THEN  -- complete refresh

			v_sql_stmt:=
			' insert into MSC_ST_ITEM_SUPPLIERS'
			||'  ( INVENTORY_ITEM_ID,'
			||'    ORGANIZATION_ID,'
			||'    USING_ORGANIZATION_ID,'
			||'    ASL_ID,'
			||'    PROCESSING_LEAD_TIME,'
			||'    MINIMUM_ORDER_QUANTITY,'
			||'    FIXED_LOT_MULTIPLE,'
			||'    DELIVERY_CALENDAR_CODE,'
			||'    SUPPLIER_CAP_OVER_UTIL_COST,'
			||'    PURCHASING_UNIT_OF_MEASURE,'
			||'    SUPPLIER_ID,'
			||'    SUPPLIER_SITE_ID,'
			||'    ITEM_PRICE,'
			||'    VMI_FLAG, '
			||'    MIN_MINMAX_QUANTITY, '
			||'    MAX_MINMAX_QUANTITY, '
			||'    ENABLE_VMI_AUTO_REPLENISH_FLAG, '
			||'    VMI_REPLENISHMENT_APPROVAL,'
			||'    REPLENISHMENT_METHOD,'
			||'    MIN_MINMAX_DAYS,'
			||'    MAX_MINMAX_DAYS,'
			||'    FORECAST_HORIZON,'
			||'    FIXED_ORDER_QUANTITY,'
			||'    SR_INSTANCE_ID2,'
			||'    DELETED_FLAG,'
			||'    REFRESH_ID,'
			/* SCE Change start */
			/* Get partner_item_name */
			||'    SUPPLIER_ITEM_NAME,'
			/* SCE Change end */
			||'    SR_INSTANCE_ID)'
			||'  select'
			||'    x.INVENTORY_ITEM_ID,'
			||'    x.ORGANIZATION_ID,'
			||'    x.USING_ORGANIZATION_ID,'
			||'    x.ASL_ID,'
			||'    x.PROCESSING_LEAD_TIME,'
			||'    x.MINIMUM_ORDER_QUANTITY,'
			||'    x.FIXED_LOT_MULTIPLE,'
			||'    DECODE( x.DELIVERY_CALENDAR_CODE,'
			||'            NULL,NULL, :V_ICODE||x.DELIVERY_CALENDAR_CODE),'
			||'    TO_NUMBER(DECODE( :v_mso_sup_cap_penalty,'
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
			||'    x.PURCHASING_UNIT_OF_MEASURE,'
			||'    x.VENDOR_ID,'
			||'    x.VENDOR_SITE_ID,'
			||     v_temp_sql
			||     v_temp_sql1
			||'    :v_instance_id,'
			||'    2,'
			||'    :v_refresh_id,'
			/* SCE Change start */
			/* Get partner_item_name */
			||'    x.PRIMARY_VENDOR_ITEM,'
			/* SCE Change end */
			||'    :v_instance_id'
			||'  from MRP_AP_PO_SUPPLIERS_V'||MSC_CL_PULL.v_dblink||' x'
			||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

			EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE,
			                                   MSC_CL_PULL.v_mso_sup_cap_penalty,
			                                   MSC_CL_PULL.v_instance_id,
			                                   MSC_CL_PULL.v_refresh_id,
			                                   MSC_CL_PULL.v_instance_id;

	ELSIF (MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 and MSC_CL_PULL.v_lrnn <>-1) THEN   -- incremental (ASL net change )

			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'GLOBAL ASL net change ');
			v_sql_stmt:=
			' insert into MSC_ST_ITEM_SUPPLIERS'
			||'  ( INVENTORY_ITEM_ID,'
			||'    USING_ORGANIZATION_ID,'
			||'    ASL_ID,'
			||'    PROCESSING_LEAD_TIME,'
			||'    MINIMUM_ORDER_QUANTITY,'
			||'    FIXED_LOT_MULTIPLE,'
			||'    DELIVERY_CALENDAR_CODE,'
			||'    SUPPLIER_CAP_OVER_UTIL_COST,'
			||'    PURCHASING_UNIT_OF_MEASURE,'
			||'    SUPPLIER_ID,'
			||'    SUPPLIER_SITE_ID,'
			||'    ITEM_PRICE,'
			||'    VMI_FLAG, '
			||'    MIN_MINMAX_QUANTITY, '
			||'    MAX_MINMAX_QUANTITY, '
			||'    ENABLE_VMI_AUTO_REPLENISH_FLAG, '
			||'    VMI_REPLENISHMENT_APPROVAL,'
			||'    REPLENISHMENT_METHOD,'
			||'    MIN_MINMAX_DAYS,'
			||'    MAX_MINMAX_DAYS,'
			||'    FORECAST_HORIZON,'
			||'    FIXED_ORDER_QUANTITY,'
			||'    SR_INSTANCE_ID2,'
			||'    DELETED_FLAG,'
			||'		 ASL_ATTRIBUTE_CREATION_DATE,'
			||'    REFRESH_ID,'
			/* SCE Change start */
			/* Get partner_item_name */
			||'    SUPPLIER_ITEM_NAME,'
			/* SCE Change end */
			||'    SR_INSTANCE_ID)'
			||'  select'
			||'    x.ITEM_ID,'
			||'    x.USING_ORGANIZATION_ID,'
			||'    x.ASL_ID,'
			||'    x.PROCESSING_LEAD_TIME,'
			||'    x.MINIMUM_ORDER_QUANTITY,'
			||'    x.FIXED_LOT_MULTIPLE,'
			||'    DECODE( x.DELIVERY_CALENDAR_CODE,'
			||'            NULL,NULL, :V_ICODE||x.DELIVERY_CALENDAR_CODE),'
			||'    TO_NUMBER(DECODE( :v_mso_sup_cap_penalty,'
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
			||'    x.PURCHASING_UNIT_OF_MEASURE,'
			||'    x.VENDOR_ID,'
			||'    x.VENDOR_SITE_ID,'
			||     v_temp_sql
			||     v_temp_sql1
			||'    :v_instance_id,'
			||'    Decode (x.disable_flag,''N'', 2,''Y'', 1,2),'
			||'		 x.date3,'
			||'    :v_refresh_id,'
			/* SCE Change start */
			/* Get partner_item_name */
			||'    x.PRIMARY_VENDOR_ITEM,'
			/* SCE Change end */
			||'    :v_instance_id'
			||'  from MRP_AN_PO_GLOBAL_ASL_V '||MSC_CL_PULL.v_dblink||' x'
			||' WHERE (x.USING_ORGANIZATION_ID = -1 or x.USING_ORGANIZATION_ID ' || MSC_UTIL.v_in_org_str ||')'
			||' AND (x.DATE1 > :lv_last_asl_collection_date or x.DATE2 > :lv_last_asl_collection_date )';

		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'the sql statement is ' || v_sql_stmt);


			EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE,
			                                   MSC_CL_PULL.v_mso_sup_cap_penalty,
			                                   MSC_CL_PULL.v_instance_id,
			                                   MSC_CL_PULL.v_refresh_id,
			                                   MSC_CL_PULL.v_instance_id,
			                                   lv_last_asl_collection_date,
			                                   lv_last_asl_collection_date;

			-- MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'GLOBAL ASL ROW COUNT IS ' || SQL%ROWCOUNT);


	END IF ;   --end global ASL


	COMMIT;

/* 3019053 - Separated the view defn. of MRP_AP_PO_SUPPLIERS_V into 2 so that
only global ASLs are in this view and the local ASLs are in
MRP_AP_PO_LOCAL_ASL_V. Hence adding another insert stmt. to insert local ASLs.
*/

	IF  (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 )    THEN

			IF MSC_CL_PULL.v_lrnn =-1 THEN  -- COMPLETE REFRESH
				v_sql_stmt:=
				' insert into MSC_ST_ITEM_SUPPLIERS'
				||'  ( INVENTORY_ITEM_ID,'
				||'    ORGANIZATION_ID,'
				||'    USING_ORGANIZATION_ID,'
				||'    ASL_ID,'
				||'    PROCESSING_LEAD_TIME,'
				||'    MINIMUM_ORDER_QUANTITY,'
				||'    FIXED_LOT_MULTIPLE,'
				||'    DELIVERY_CALENDAR_CODE,'
				||'    SUPPLIER_CAP_OVER_UTIL_COST,'
				||'    PURCHASING_UNIT_OF_MEASURE,'
				||'    SUPPLIER_ID,'
				||'    SUPPLIER_SITE_ID,'
				||'    ITEM_PRICE,'
				||'    VMI_FLAG, '
				||'    MIN_MINMAX_QUANTITY, '
				||'    MAX_MINMAX_QUANTITY, '
				||'    ENABLE_VMI_AUTO_REPLENISH_FLAG, '
				||'    VMI_REPLENISHMENT_APPROVAL,'
				||'    REPLENISHMENT_METHOD,'
				||'    MIN_MINMAX_DAYS,'
				||'    MAX_MINMAX_DAYS,'
				||'    FORECAST_HORIZON,'
				||'    FIXED_ORDER_QUANTITY,'
				||'    SR_INSTANCE_ID2,'
				||'    DELETED_FLAG,'
				||'    REFRESH_ID,'
				/* SCE Change start */
				/* Get partner_item_name */
				||'    SUPPLIER_ITEM_NAME,'
				/* SCE Change end */
				||'    SR_INSTANCE_ID)'
				||'  select'
				||'    x.INVENTORY_ITEM_ID,'
				||'    x.ORGANIZATION_ID,'
				||'    x.USING_ORGANIZATION_ID,'
				||'    x.ASL_ID,'
				||'    x.PROCESSING_LEAD_TIME,'
				||'    x.MINIMUM_ORDER_QUANTITY,'
				||'    x.FIXED_LOT_MULTIPLE,'
				||'    DECODE( x.DELIVERY_CALENDAR_CODE,'
				||'            NULL,NULL, :V_ICODE||x.DELIVERY_CALENDAR_CODE),'
				||'    TO_NUMBER(DECODE( :v_mso_sup_cap_penalty,'
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
				||'    x.PURCHASING_UNIT_OF_MEASURE,'
				||'    x.VENDOR_ID,'
				||'    x.VENDOR_SITE_ID,'
				||     v_temp_sql
				||     v_temp_sql1
				||'    :v_instance_id,'
				||'    2,'
				||'    :v_refresh_id,'
				/* SCE Change start */
				/* Get partner_item_name */
				||'    x.PRIMARY_VENDOR_ITEM,'
				/* SCE Change end */
				||'    :v_instance_id'
				||'  from MRP_AP_PO_LOCAL_ASL_V'||MSC_CL_PULL.v_dblink||' x'
				||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

				MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Collecting from MRP_AP_PO_LOCAL_ASL_V');

				EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE,
				                                   MSC_CL_PULL.v_mso_sup_cap_penalty,
				                                   MSC_CL_PULL.v_instance_id,
				                                   MSC_CL_PULL.v_refresh_id,
				                                   MSC_CL_PULL.v_instance_id;
				COMMIT;
			ELSE  -- LOCAL ASL NET CHANGE
		 		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'LOCAL ASL net change ');
				v_sql_stmt:=
				' insert into MSC_ST_ITEM_SUPPLIERS'
				||'  ( INVENTORY_ITEM_ID,'
				||'    USING_ORGANIZATION_ID,'
				||'    ASL_ID,'
				||'    PROCESSING_LEAD_TIME,'
				||'    MINIMUM_ORDER_QUANTITY,'
				||'    FIXED_LOT_MULTIPLE,'
				||'    DELIVERY_CALENDAR_CODE,'
				||'    SUPPLIER_CAP_OVER_UTIL_COST,'
				||'    PURCHASING_UNIT_OF_MEASURE,'
				||'    SUPPLIER_ID,'
				||'    SUPPLIER_SITE_ID,'
				||'    ITEM_PRICE,'
				||'    VMI_FLAG, '
				||'    MIN_MINMAX_QUANTITY, '
				||'    MAX_MINMAX_QUANTITY, '
				||'    ENABLE_VMI_AUTO_REPLENISH_FLAG, '
				||'    VMI_REPLENISHMENT_APPROVAL,'
				||'    REPLENISHMENT_METHOD,'
				||'    MIN_MINMAX_DAYS,'
				||'    MAX_MINMAX_DAYS,'
				||'    FORECAST_HORIZON,'
				||'    FIXED_ORDER_QUANTITY,'
				||'    SR_INSTANCE_ID2,'
				||'    DELETED_FLAG,'
				||'		 ASL_ATTRIBUTE_CREATION_DATE,'
				||'    REFRESH_ID,'
				/* SCE Change start */
				/* Get partner_item_name */
				||'    SUPPLIER_ITEM_NAME,'
				/* SCE Change end */
				||'    SR_INSTANCE_ID)'
				||'  select'
				||'    x.ITEM_ID,'
				||'    x.USING_ORGANIZATION_ID,'
				||'    x.ASL_ID,'
				||'    x.PROCESSING_LEAD_TIME,'
				||'    x.MINIMUM_ORDER_QUANTITY,'
				||'    x.FIXED_LOT_MULTIPLE,'
				||'    DECODE( x.DELIVERY_CALENDAR_CODE,'
				||'            NULL,NULL, :V_ICODE||x.DELIVERY_CALENDAR_CODE),'
				||'    TO_NUMBER(DECODE( :v_mso_sup_cap_penalty,'
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
				||'    x.PURCHASING_UNIT_OF_MEASURE,'
				||'    x.VENDOR_ID,'
				||'    x.VENDOR_SITE_ID,'
				||     v_temp_sql
				||     v_temp_sql1
				||'    :v_instance_id,'
				||'    Decode (x.disable_flag,''N'', 2,''Y'', 1,2),'
				||'		 x.date3,'
				||'    :v_refresh_id,'
				/* SCE Change start */
				/* Get partner_item_name */
				||'    x.PRIMARY_VENDOR_ITEM,'
				/* SCE Change end */
				||'    :v_instance_id'
				||'  from MRP_AN_PO_LOCAL_ASL_V '||MSC_CL_PULL.v_dblink||' x'
				||' WHERE  x.USING_ORGANIZATION_ID ' || MSC_UTIL.v_in_org_str
				||' AND (x.DATE1 > :lv_last_asl_collection_date or x.DATE2 > :lv_last_asl_collection_date )';

				--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'the sql statement lcal ASL  ' || v_sql_stmt);

				EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE,
				                                   MSC_CL_PULL.v_mso_sup_cap_penalty,
				                                   MSC_CL_PULL.v_instance_id,
				                                   MSC_CL_PULL.v_refresh_id,
				                                   MSC_CL_PULL.v_instance_id,
				                                   lv_last_asl_collection_date,
				                                   lv_last_asl_collection_date;

				--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'LOCAL ASL ROW COUNT IS ' || SQL%ROWCOUNT);
				COMMIT ;
	  END IF ;
 	END IF;        ---- MSC_CL_PULL.v_apps_ver === 115

END IF;


 IF (MSC_CL_PULL.SUPPLIER_CAP_ENABLED= MSC_UTIL.ASL_YES or MSC_CL_PULL.SUPPLIER_CAP_ENABLED= MSC_UTIL.ASL_YES_RETAIN_CP) AND
    MSC_CL_PULL.v_apps_ver<> MSC_UTIL.G_APPS107        AND
    MSC_CL_PULL.v_apps_ver<> MSC_UTIL.G_APPS110        THEN

  --- LOAD NET_CHAGE for DELETE --------

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIER_CAPACITIES';
MSC_CL_PULL.v_view_name := 'MRP_AD_SUPPLIER_CAPACITIES_V';

v_sql_stmt:=
'Insert into MSC_ST_SUPPLIER_CAPACITIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    USING_ORGANIZATION_ID,'
||'    SUPPLIER_ID,'
||'    SUPPLIER_SITE_ID,'
||'    FROM_DATE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select '
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.USING_ORGANIZATION_ID,'
||'    x.VENDOR_ID,'
||'    x.VENDOR_SITE_ID,'
||'    x.FROM_DATE- :v_dgmt,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_SUPPLIER_CAPACITIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN> :v_lrn '
||' AND x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIER_CAPACITIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_SUPPLIER_CAPACITIES_V';

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1 > :v_lrn )'
||' UNION '
||'  select '
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.USING_ORGANIZATION_ID,'
||'    x.VENDOR_ID,'
||'    x.VENDOR_SITE_ID,'
||'    x.FROM_DATE- :v_dgmt,'
||'    x.TO_DATE- :v_dgmt,'
||'    x.CAPACITY,'
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_SUPPLIER_CAPACITIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN2 > :v_lrn)';

ELSE

v_union_sql := '     ';

END IF;


v_sql_stmt:=
'Insert into MSC_ST_SUPPLIER_CAPACITIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    USING_ORGANIZATION_ID,'
||'    SUPPLIER_ID,'
||'    SUPPLIER_SITE_ID,'
||'    FROM_DATE,'
||'    TO_DATE,'
||'    CAPACITY,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select '
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.USING_ORGANIZATION_ID,'
||'    x.VENDOR_ID,'
||'    x.VENDOR_SITE_ID,'
||'    x.FROM_DATE- :v_dgmt,'
||'    x.TO_DATE- :v_dgmt,'
||'    x.CAPACITY,'
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_SUPPLIER_CAPACITIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql;


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

ELSE
EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
END IF;


COMMIT;

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIER_FLEX_FENCES';
MSC_CL_PULL.v_view_name := 'MRP_AP_SUPPLIER_FLEX_FENCES_V';

v_sql_stmt:=
' insert into MSC_ST_SUPPLIER_FLEX_FENCES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    USING_ORGANIZATION_ID,'
||'    SUPPLIER_ID,'
||'    SUPPLIER_SITE_ID,'
||'    FENCE_DAYS,'
||'    TOLERANCE_PERCENTAGE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select '
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.USING_ORGANIZATION_ID,'
||'    x.VENDOR_ID,'
||'    x.VENDOR_SITE_ID,'
||'    x.FENCE_DAYS,'
||'    x.TOLERANCE_PERCENTAGE,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_SUPPLIER_FLEX_FENCES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str ;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;   -- complete refresh

END IF;  -- MSC_CL_PULL.v_apps_ver

   END LOAD_SUPPLIER_CAPACITY;


-- ================= LOAD ITEM SUBSTITUTES ================
PROCEDURE LOAD_ITEM_SUBSTITUTES IS
v_condition varchar2(1000);
 BEGIN

IF MSC_CL_PULL.ITEM_SUBST_ENABLED = MSC_UTIL.SYS_YES THEN

 -- IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

      IF  (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115  AND MSC_UTIL.G_COLLECT_SRP_DATA = 'Y') THEN   --For Bug 5632379 SRP Changes
          MSC_CL_PULL.v_table_name:= 'MSC_ST_ITEM_SUBSTITUTES';
          MSC_CL_PULL.v_view_name := 'MRP_AP_ITEM_SUPERSESSION_REL_V';
          v_sql_stmt:=
                     ' INSERT INTO MSC_ST_ITEM_SUBSTITUTES'
                       ||'( HIGHER_ITEM_ID,'
                       ||'  LOWER_ITEM_ID,'
                       ||'  RECIPROCAL_FLAG,'
                       ||'  RELATIONSHIP_TYPE,'
                       ||'  SUBSTITUTION_SET,'
                       ||'  PARTIAL_FULFILLMENT_FLAG,'
                       ||'  EFFECTIVE_DATE,'
                       ||'  DISABLE_DATE,'
                       ||'  SR_INSTANCE_ID,'
                       ||'  DELETED_FLAG,'
                       ||'  ORGANIZATION_ID)'
                       ||' SELECT'
                       ||'  x.RELATED_ITEM_ID,'
                       ||'  x.INVENTORY_ITEM_ID,'
                       ||'  x.RECIPROCAL_FLAG,'
                       ||'  x.RELATIONSHIP_TYPE_ID,'
                       ||'  x.SUBSTITUTION_SET,'
                       ||'  x.PARTIAL_FULFILLMENT_FLAG,'
                       ||'  x.EFFECTIVE_DATE,'
                       ||'  x.DISABLE_DATE,'
                       ||'  :v_instance_id,'
                       ||'  2,'
                       ||'  x.ORGANIZATION_ID'
                       ||' FROM MRP_AP_ITEM_SUPERSESSION_REL_V'||MSC_CL_PULL.v_dblink||' x'
                       ||' WHERE x.RN>'||MSC_CL_PULL.v_lrn  || ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;

                        EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id;

                        COMMIT;

         END IF;  --MSC_SRP_ENABLED THEN   For Bug 5632379 SRP Changes


MSC_CL_PULL.v_table_name:= 'MSC_ST_ITEM_SUBSTITUTES';
MSC_CL_PULL.v_view_name := 'MRP_AP_ITEM_SUBSTITUTES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_ITEM_SUBSTITUTES'
||'( HIGHER_ITEM_ID,'
||'  LOWER_ITEM_ID,'
||'  RECIPROCAL_FLAG,'
||'  SUBSTITUTION_SET,'
||'  RELATIONSHIP_TYPE,'
||'  PARTIAL_FULFILLMENT_FLAG,'
||'  CUSTOMER_ID,'
||'  CUSTOMER_SITE_ID ,'
||'  EFFECTIVE_DATE,'
||'  DISABLE_DATE,'
||'  SR_INSTANCE_ID,'
||'  DELETED_FLAG,'
||'  ORGANIZATION_ID)'
||' SELECT'
||'  x.RELATED_ITEM_ID,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.RECIPROCAL_FLAG,'
||'  x.SUBSTITUTION_SET,'
||'  x.RELATIONSHIP_TYPE_ID,'
||'  x.PARTIAL_FULFILLMENT_FLAG,'
||'  x.CUSTOMER_ID,'
||'  x.ADDRESS_ID,'
||'  x.EFFECTIVE_DATE,'
||'  x.DISABLE_DATE,'
||'  :v_instance_id,'
||'  2,'
||'  x.ORGANIZATION_ID'
||' FROM MRP_AP_ITEM_SUBSTITUTES_V'||MSC_CL_PULL.v_dblink||'  x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
||' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;


EXECUTE  IMMEDIATE  v_sql_stmt USING MSC_CL_PULL.v_instance_id;

COMMIT;

--END IF; --COMPLETE REFRESH   For Bug 5702475 SRP Changes

IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120 AND MSC_CL_PULL.v_lrnn<> -1) THEN -- incremental refresh

   MSC_CL_PULL.v_table_name:= 'MSC_ST_ITEM_SUBSTITUTES';
   MSC_CL_PULL.v_view_name := 'MRP_AD_ITEM_RELATIONSHIPS_V';
   v_condition:=null;

--For Bug 5702475 SRP Changes
  IF  (MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) THEN
	  v_condition:= ' and x.relationship_type_id in (2,5,8,18 ) ';
  else
	  v_condition:= ' and x.relationship_type_id in (2) ';
  end if;


   v_sql_stmt:=
   ' INSERT INTO MSC_ST_ITEM_SUBSTITUTES'
   ||'( LOWER_ITEM_ID,'
   ||'  HIGHER_ITEM_ID,'
   ||'  ORGANIZATION_ID,'
   ||'  RELATIONSHIP_TYPE,'
   ||'  REFRESH_ID,'
   ||'  DELETED_FLAG,'
   ||'  SR_INSTANCE_ID)'
   ||' SELECT'
   ||'  x.INVENTORY_ITEM_ID,'
   ||'  x.RELATED_ITEM_ID,'
   ||'  x.ORGANIZATION_ID,'
   ||'  x.RELATIONSHIP_TYPE_ID,'
   ||'  :v_refresh_id,'
   ||'  1,'
   ||'  :v_instance_id'
   ||' FROM MRP_AD_ITEM_RELATIONSHIPS_V'||MSC_CL_PULL.v_dblink||' x'
   ||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
   ||  v_condition
   ||' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF ;  --INCREMENTAL REFRESH

END IF;  -- MSC_CL_PULL.ITEM_SUBST_ENABLED

END LOAD_ITEM_SUBSTITUTES;


PROCEDURE INSERT_DUMMY_ITEMS is
lv_item_name	VARCHAR2(255);
BEGIN

 DELETE from MSC_ST_SYSTEM_ITEMS st_item
  where st_item.SR_INVENTORY_ITEM_ID in ( -1000,-1001) and
  st_item.sr_instance_id = MSC_CL_PULL.v_instance_id and
  st_item.organization_id in
   (  select x.organization_id
      FROM msc_instance_orgs x
      WHERE x.sr_instance_id= MSC_CL_PULL.v_instance_id
      and x.enabled_flag= 1
      and   ((MSC_CL_PULL.v_org_group = MSC_UTIL.G_ALL_ORGANIZATIONS ) or (x.org_group = MSC_CL_PULL.v_org_group))
    );
  commit;

  lv_item_name := NVL(FND_PROFILE.VALUE('MSC_EAM_NO_ACTIVITY_ITEM'),'No Activity Item');
insert into MSC_ST_SYSTEM_ITEMS (
	ORGANIZATION_ID,
  	SR_INVENTORY_ITEM_ID,
	SR_INSTANCE_ID,
  	LOT_CONTROL_CODE,
  	ROUNDING_CONTROL_TYPE,
  	IN_SOURCE_PLAN,
  	MRP_PLANNING_CODE,
  	UOM_CODE,
  	ATP_COMPONENTS_FLAG,
  	BUILT_IN_WIP_FLAG,
  	PURCHASING_ENABLED_FLAG,
  	PLANNING_MAKE_BUY_CODE,
  	REPETITIVE_TYPE,
  	ENGINEERING_ITEM_FLAG,
  	MRP_SAFETY_STOCK_CODE,
  	EFFECTIVITY_CONTROL,
  	INVENTORY_PLANNING_CODE,
  	MRP_CALCULATE_ATP_FLAG,
  	ATP_FLAG,
	eam_item_type,
	ITEM_NAME,
	ORGANIZATION_CODE)
  SELECT  /*+ INDEX(MSC_INSTANCE_ORGS MSC_INSTANCE_ORGS_U1) */
    x.ORGANIZATION_ID ,
      -1000,
      MSC_CL_PULL.v_instance_id,
      1,	--LOT_CONTROL_CODE  1 no control, 2 full control
      1,	--ROUNDING_CONTROL_TYPE  1 round order qty, 2 no
      2,	--IN_SOURCE_PLAN
      3,  	--MRP_PLANNING_CODE  3 mrp planning, 6 not planned,
      'Ea', 	--UOM_CODE
      'N',	--ATP_COMPONENTS_FLAG N no, Y material only, R Resource, C material and resource
       1,	--BUILD_IN_WIP_FLAG
      2,	--PURCHASING_ENABLED_FLAG
      1,	--PLANNING_MAKE_BUY_CODE 1 Make, 2 Buy
      1,	--REPETITIVE_TYPE
      2,	--ENGINEERING_ITEM_FLAG
      1,	--MRP_SAFETY_STOCK_CODE
      2,	--EFFECTIVITY_CONTROL
      1,	--INVENTORY_PLANNING_CODE 6 not planned, 2 min max, 1 reorder point
      2,	--CALCULATE_ATP
      2,	--ATP_FLAG
      1,	--eam_item_type
      lv_item_name ,
      org.ORGANIZATION_CODE
      FROM msc_instance_orgs x,
      MTL_PARAMETERS org
      WHERE sr_instance_id= MSC_CL_PULL.v_instance_id
      and enabled_flag= 1
      and  org.ORGANIZATION_ID = x.ORGANIZATION_ID
      and   ((MSC_CL_PULL.v_org_group = MSC_UTIL.G_ALL_ORGANIZATIONS ) or (org_group = MSC_CL_PULL.v_org_group));

   commit;
  lv_item_name := NVL(FND_PROFILE.VALUE('MSC_WIP_NONSTD_JOB_ITEM'),'Non Standard Job Item');

insert into MSC_ST_SYSTEM_ITEMS (
	ORGANIZATION_ID,
  	SR_INVENTORY_ITEM_ID,
	SR_INSTANCE_ID,
  	LOT_CONTROL_CODE,
  	ROUNDING_CONTROL_TYPE,
  	IN_SOURCE_PLAN,
  	MRP_PLANNING_CODE,
  	UOM_CODE,
  	ATP_COMPONENTS_FLAG,
  	BUILT_IN_WIP_FLAG,
  	PURCHASING_ENABLED_FLAG,
  	PLANNING_MAKE_BUY_CODE,
  	REPETITIVE_TYPE,
  	ENGINEERING_ITEM_FLAG,
  	MRP_SAFETY_STOCK_CODE,
  	EFFECTIVITY_CONTROL,
  	INVENTORY_PLANNING_CODE,
  	MRP_CALCULATE_ATP_FLAG,
  	ATP_FLAG,
	ITEM_NAME,
	ORGANIZATION_CODE)
  SELECT  /*+ INDEX(MSC_INSTANCE_ORGS MSC_INSTANCE_ORGS_U1) */
    x.ORGANIZATION_ID ,
      -1001,
      MSC_CL_PULL.v_instance_id,
      1,	--LOT_CONTROL_CODE
      1,	--ROUNDING_CONTROL_TYPE
      2,	--IN_SOURCE_PLAN
      3,  	--MRP_PLANNING_CODE
      'Ea', 	--UOM_CODE
      'N',	--ATP_COMPONENTS_FLAG
       1,	--BUILD_IN_WIP_FLAG
      2,	--PURCHASING_ENABLED_FLAG
      1,	--PLANNING_MAKE_BUY_CODE
      1,	--REPETITIVE_TYPE
      1,	--ENGINEERING_ITEM_FLAG
      1,	--MRP_SAFETY_STOCK_CODE
      2,	--EFFECTIVITY_CONTROL
      1,	--INVENTORY_PLANNING_CODE
      2,	--CALCULATE_ATP
      2,	--ATP_FLAG
      lv_item_name ,
	 org.ORGANIZATION_CODE
      FROM msc_instance_orgs x,
	 MTL_PARAMETERS org
      WHERE x.sr_instance_id= MSC_CL_PULL.v_instance_id
      and x.enabled_flag= 1
	 and  org.ORGANIZATION_ID = x.ORGANIZATION_ID
      and   ((MSC_CL_PULL.v_org_group = MSC_UTIL.G_ALL_ORGANIZATIONS ) or (x.org_group = MSC_CL_PULL.v_org_group));

   commit;

END INSERT_DUMMY_ITEMS;

PROCEDURE INSERT_DUMMY_CATEGORIES is
lv_table_name           VARCHAR2(255);
lv_sql_stmt VARCHAR2(5000);
lv_category_set_id PLS_INTEGER;
lv_category_set_name VARCHAR2(255):= 'Unspecified Items';
lv_category_set_description VARCHAR2(255):= 'Category set for no activity item ';
lv_category_name  VARCHAR2(255) :='NEW.MISC';
lv_category_id PLS_INTEGER ;
lv_category_description VARCHAR2(255):='No Activity Item Category';
lv_disable_date DATE;
lv_summary_flag VARCHAR2(1):='N';
lv_enabled_flag VARCHAR2(1):='Y';
lv_start_date_active DATE ;
lv_end_date_active DATE;
lv_deleted_flag PLS_INTEGER := 2;
BEGIN

	delete from MSC_ST_CATEGORY_SETS st_item_category_set
   	where st_item_category_set.sr_instance_id = MSC_CL_PULL.v_instance_id
   	and st_item_category_set.SR_CATEGORY_SET_ID = -5000;
      	commit;
      	lv_category_set_name := NVL(FND_PROFILE.VALUE('MSC_NO_ACTIVITY_ITEM_CATEGORY_SET'),'Unspecified Items');
	BEGIN
	        lv_table_name:= 'MRP_AP_CATEGORY_SETS_V'||MSC_CL_PULL.v_dblink;
		lv_sql_stmt:= 'SELECT category_set_id  FROM '||lv_table_name
		              ||' WHERE category_set_name = '''||lv_category_set_name
		              ||''' AND nvl(language,''' || MSC_CL_PULL.v_lang || ''')=''' || MSC_CL_PULL.v_lang || '''';

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'debug1 - ' || lv_sql_stmt);

		EXECUTE IMMEDIATE lv_sql_stmt INTO lv_category_set_id ;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			        lv_category_set_id := -5000 ;

	END ;

	IF lv_category_set_id = -5000 then
		insert into MSC_ST_CATEGORY_SETS (
		     SR_CATEGORY_SET_ID,
      	    	     CATEGORY_SET_NAME,
             	     DESCRIPTION,
             	     CONTROL_LEVEL,
                     DEFAULT_FLAG,
             	     DELETED_FLAG,
             	     SR_INSTANCE_ID)
	    	     values(
	      		 lv_category_set_id,
	     		 lv_category_set_name,
	      		lv_category_set_description ,
	     		 2,
	      		2,
	      		2,
	       		MSC_CL_PULL.v_instance_id ) ;
    		commit ;
    	END IF ;

 lv_table_name:= 'MTL_PARAMETERS'||MSC_CL_PULL.v_dblink;


 DELETE from MSC_ST_ITEM_CATEGORIES st_item_category
  where st_item_category.INVENTORY_ITEM_ID in ( -1000,-1001) and
  st_item_category.SR_CATEGORY_SET_ID in (-5000)and
  st_item_category.SR_CATEGORY_ID in (-5001) and
  st_item_category.sr_instance_id = MSC_CL_PULL.v_instance_id and
  st_item_category.organization_id in
   (  select x.organization_id
      FROM msc_instance_orgs x
      WHERE x.sr_instance_id= MSC_CL_PULL.v_instance_id
      and x.enabled_flag= 1
      and   ((MSC_CL_PULL.v_org_group = MSC_UTIL.G_ALL_ORGANIZATIONS ) or (x.org_group = MSC_CL_PULL.v_org_group))
    );
  commit;

   lv_category_name := NVL(FND_PROFILE.VALUE('MSC_NO_ACTIVITY_ITEM_CATEGORY'),'NEW.MISC');
  BEGIN
         lv_table_name:= 'MRP_AP_ITEM_CATEGORIES_V'||MSC_CL_PULL.v_dblink;
        lv_sql_stmt:= 'SELECT category_id,description FROM ' ||lv_table_name
                   || ' WHERE category_name = '''||lv_category_name
                   || ''' AND nvl(language,''' || MSC_CL_PULL.v_lang || ''')=''' || MSC_CL_PULL.v_lang || '''and rownum=1';

	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'debug2 - ' || lv_sql_stmt);

	EXECUTE IMMEDIATE lv_sql_stmt INTO lv_category_id,lv_category_description ;
	EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	 	lv_category_id := -5001;
 END ;

  lv_table_name :='MTL_PARAMETERS'||MSC_CL_PULL.v_dblink;
  lv_sql_stmt := 'insert into MSC_ST_ITEM_CATEGORIES ('
	      ||'INVENTORY_ITEM_ID,'
	      ||'ORGANIZATION_ID,'
	      ||'SR_CATEGORY_SET_ID,'
	      ||'SR_CATEGORY_ID, '
	      ||'CATEGORY_NAME, '
	   --   ||'DESCRIPTION, '
	      ||'DISABLE_DATE, '
	      ||'SUMMARY_FLAG, '
	      ||'ENABLED_FLAG, '
	      ||'START_DATE_ACTIVE, '
	      ||'END_DATE_ACTIVE, '
	      ||'DELETED_FLAG, '
	      ||'SR_INSTANCE_ID)'
	      ||' SELECT  /*+ INDEX(MSC_INSTANCE_ORGS MSC_INSTANCE_ORGS_U1)*/ '
	      ||' :lv_item_id  ,'
	     || 'x.ORGANIZATION_ID ,'
	     || lv_category_set_id ||','
	     || lv_category_id ||','
	     ||''''|| lv_category_name||'''' ||','
	   --  ||''''|| lv_category_description||'''' || ','
	     || 'null ,'
	     ||''''|| lv_summary_flag||'''' ||','
	     ||''''|| lv_enabled_flag||'''' ||','
	     || 'null,'
	     || 'null,'
	     || lv_deleted_flag ||','
	     || MSC_CL_PULL.v_instance_id
	     || ' FROM msc_instance_orgs x,'
	     || lv_table_name ||' org '
	     ||' WHERE x.sr_instance_id='|| MSC_CL_PULL.v_instance_id
	     ||' and x.enabled_flag= 1'
	     ||' and  org.ORGANIZATION_ID = x.ORGANIZATION_ID'
	     ||' and   (('''||MSC_CL_PULL.v_org_group ||'''='''|| MSC_UTIL.G_ALL_ORGANIZATIONS||''' ) or (org_group ='''|| MSC_CL_PULL.v_org_group||'''))';



  for lv_item_id in -1001..-1000 loop
        execute immediate lv_sql_stmt using lv_item_id ;

   end loop;

   update MSC_ST_ITEM_CATEGORIES set DESCRIPTION = lv_category_description
   where INVENTORY_ITEM_ID in (-1001,-1000)
   and   SR_CATEGORY_SET_ID = lv_category_set_id
   and   SR_CATEGORY_ID =  lv_category_id
   and   organization_id in
   (  select x.organization_id
      FROM msc_instance_orgs x
      WHERE x.sr_instance_id= MSC_CL_PULL.v_instance_id
      and x.enabled_flag= 1
      and   ((MSC_CL_PULL.v_org_group = MSC_UTIL.G_ALL_ORGANIZATIONS ) or (x.org_group = MSC_CL_PULL.v_org_group))
    );

   commit;

END INSERT_DUMMY_CATEGORIES;

--====================TO initialize the part condition attribute values ===========

/*added for bug:4765403*/
PROCEDURE LOAD_ABC_CLASSES IS
BEGIN
MSC_CL_PULL.v_table_name:= 'MSC_ST_ABC_CLASSES';
MSC_CL_PULL.v_view_name:= 'MRP_AP_ABC_CLASSES';

v_sql_stmt:=
'insert into MSC_ST_ABC_CLASSES'
||'  (ABC_CLASS_ID,'
||'   ABC_CLASS_NAME,'
||'   ORGANIZATION_ID,'
||'   SR_ASSIGNMENT_GROUP_ID,'
||'   SR_INSTANCE_ID)'
||'  select '
||'   x.ABC_CLASS_ID,'
||'   x.ABC_CLASS_NAME,'
||'   x.ORGANIZATION_ID,'
||'   x.ASSIGNMENT_GROUP_ID,'
||'   :v_instance_id'
||'  from MRP_AP_ABC_CLASSES_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;


  EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id;

  COMMIT;

 END LOAD_ABC_CLASSES;


END MSC_CL_ITEM_PULL;

/
