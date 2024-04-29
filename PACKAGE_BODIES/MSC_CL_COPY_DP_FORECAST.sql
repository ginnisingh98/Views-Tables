--------------------------------------------------------
--  DDL for Package Body MSC_CL_COPY_DP_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_COPY_DP_FORECAST" AS -- body
/* $Header: MSCDPCPB.pls 120.6.12010000.1 2009/08/28 18:00:20 schaudha noship $ */

 -- Global variable Definition

 v_aps_dblink VARCHAR2(100);
 v_src_dblink VARCHAR2(100);
 v_src_instance_id NUMBER;
 v_rp_instance_id NUMBER;
 v_instance_id NUMBER;
 lv_random_number number;
 v_last_update_date DATE;
 v_last_updated_by NUMBER;
 v_creation_date DATE;
 v_created_by NUMBER;


PROCEDURE GET_SOURCE_INSTANCE_ID (SOURCE_ID_INDICATOR IN NUMBER,
                                  DB_LINK            IN VARCHAR,
                                  SOURCE_INSTANCE_ID OUT NOCOPY NUMBER) IS

lv_src_sql_stmt varchar2(2000);
lv_sql_stmt VARCHAR2 (1000);
lv_src_cent_stmt VARCHAR2 (1000);
m2a_dblink      varchar2(100);
lv_instance_id number;
lv_found_source NUMBER := 0;

TYPE CurTyp IS REF CURSOR; -- Cursor variable
c1   CurTyp;

BEGIN

lv_src_sql_stmt := 'SELECT m2a_dblink, instance_id
                    FROM msc_apps_instances' || DB_LINK || '
                    WHERE m2a_dblink IS NOT NULL';

  OPEN  c1 FOR lv_src_sql_stmt;        -- open the REF cursor
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQL stmt in GET_SOURCE_INSTANCE_ID is : ' ||lv_src_sql_stmt);
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The value of lv_found_source is : ' ||lv_found_source);
 LOOP
  FETCH c1 INTO
         m2a_dblink,lv_instance_id;

     EXIT WHEN c1%NOTFOUND;

                   BEGIN

                     lv_found_source := 0;
                     lv_sql_stmt :=
                       'SELECT 1 FROM MRP_AP_APPS_INSTANCES_ALL@' || m2a_dblink ||
                       ' WHERE ' ||
                       'RP_SOURCE_IND = '|| to_char(SOURCE_ID_INDICATOR);

                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The formed SQL to get the source instance: ' ||
                                       lv_sql_stmt);
                     EXECUTE IMMEDIATE lv_sql_stmt INTO lv_found_source;

                     IF (lv_found_source = 1 ) THEN

                         SOURCE_INSTANCE_ID := lv_instance_id;
                         EXIT;

                     END IF;


                   EXCEPTION
                     WHEN OTHERS THEN
                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, sqlerrm);
                   END;
  END LOOP;


  Begin
                    --- for self instance
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'For self instance. Value of lv_found_source is :'||lv_found_source);
                    IF (v_rp_instance_id =v_src_instance_id) THEN

                        lv_src_cent_stmt := 'SELECT  instance_id
                                            FROM msc_apps_instances' || DB_LINK || '
                                            WHERE m2a_dblink IS NULL
                                            AND a2m_dblink is NULL
                                            AND INSTANCE_TYPE <> 3';

                         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQL to get the source instance in case of centralised inst : ' ||lv_src_cent_stmt);
                         EXECUTE IMMEDIATE lv_src_cent_stmt INTO lv_instance_id;
                         SOURCE_INSTANCE_ID := lv_instance_id;
                         lv_found_source := 1;

                     END IF;
  EXCEPTION
                     WHEN OTHERS THEN
                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, sqlerrm);
  END;

  IF (lv_found_source = 0) THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'No Common Source found for APS and  RP servers');
    SOURCE_INSTANCE_ID := -23453;
  ELSE
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Source Instance ID : ' ||to_char (SOURCE_INSTANCE_ID));
  END IF;

END GET_SOURCE_INSTANCE_ID;

PROCEDURE LAUNCH_MONITOR( ERRBUF       OUT NOCOPY VARCHAR2,
			      RETCODE			   OUT NOCOPY NUMBER,
			      pINSTANCE_ID         IN  NUMBER,
            pSource_instance_id  IN NUMBER)

IS

     lv_sql_stmt       varchar2(8000);
     v_aps_dblink1    varchar2(128);


BEGIN
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'APS Instance Id: '|| pINSTANCE_ID); -- Instance ID of the APS server
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Source Instance Id: '|| pSource_instance_id);  -- Instance ID of the RP instance
  -- Initialize Global Variables
  v_src_instance_id := pSource_instance_id;
  v_rp_instance_id  := pINSTANCE_ID;

--derive original source instance id
  BEGIN
      SELECT    DECODE(M2A_DBLINK,
                    NULL,'',
                    M2A_DBLINK) ,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY
  	  INTO v_src_dblink ,v_last_update_date ,v_last_updated_by,v_creation_date ,v_created_by
  	  FROM MSC_APPS_INSTANCES
  	  WHERE INSTANCE_ID=pSource_instance_id;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'SRC DB Link- v_src_dblink is: '|| v_src_dblink );

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Source Instance Not defined for instance_id:' || to_char(pSource_instance_id));
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := 'Source Instance Not defined for instance_id';
      RETURN;
    WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := SQLERRM;
      RETURN;
  END;

   select dbms_random.random
   into lv_random_number
   from dual;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' Generated random number:  ' || lv_random_number);
   lv_sql_stmt := 'Update '
                  || ' mrp_ap_apps_instances_all'||'@'|| v_src_dblink
                  || ' set    rp_source_ind = '|| to_char(lv_random_number)
                  || ' where instance_id = '|| pSource_instance_id ;

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Update SQL stmt is:  '|| lv_sql_stmt );
 EXECUTE IMMEDIATE lv_sql_stmt;

--derive aps instance_id
  BEGIN
      SELECT DECODE(M2A_DBLINK,
                    NULL,'',
                    '@'||M2A_DBLINK)
  	  INTO v_aps_dblink
  	  FROM MSC_APPS_INSTANCES
  	  WHERE INSTANCE_ID=pINSTANCE_ID;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'APS DB Link- v_aps_dblink is: '|| v_aps_dblink);

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'APS Instance Not defined for instance_id:' || to_char(pINSTANCE_ID));
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := 'Aps Instance Not defined for instance_id';
      RETURN;
    WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := SQLERRM;
      RETURN;
  END;

 GET_SOURCE_INSTANCE_ID(lv_random_number,v_aps_dblink ,v_instance_id);

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'v_instance_id :  '|| v_instance_id );

-- Call the PROCEDURE to copy forecast data and other related tables
  COPY_DP_SCENARIOS ;
  COPY_DP_SCENARIO_REVISIONS;
  COPY_DP_FORECAST;
  COPY_DP_DEMAND_PLANS;
  COPY_MSD_DP_SCENARIO_OP_LEVELS ;

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error in copy- No records found ' );
	    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := 'No data found';
      RETURN;
    WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := SQLERRM;
      ROLLBACK;
      RETURN;

Commit;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'End of CP ');

END LAUNCH_MONITOR;


PROCEDURE COPY_DP_FORECAST IS

   lv_sql_stmt     VARCHAR2(2000);
   lv_scenario_id  NUMBER;
   lv_creation_date date;


BEGIN

     DELETE FROM MSD_DP_SCN_ENTRIES_DENORM
     WHERE SR_INSTANCE_ID = v_src_instance_id;
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The number of rows deleted from MSD_DP_SCN_ENTRIES_DENORM '|| SQL%ROWCOUNT);

v_sql_stmt:=
'INSERT INTO MSD_DP_SCN_ENTRIES_DENORM ('
||      'DEMAND_PLAN_ID,'
||      'SCENARIO_ID,'
||      'DEMAND_ID,'
||      'BUCKET_TYPE,'
||      'START_TIME,'
||      'END_TIME,'
||      'QUANTITY,'
||      'SR_ORGANIZATION_ID,'
||      'SR_INSTANCE_ID,'
||      'SR_INVENTORY_ITEM_ID,'
||      'ERROR_TYPE,'
||      'FORECAST_ERROR,'
||      'INVENTORY_ITEM_ID,'
||      'SR_SHIP_TO_LOC_ID,'
||      'SR_CUSTOMER_ID,'
||      'SR_ZONE_ID,'
||      'PRIORITY,'
||      'DP_UOM_CODE,'
||      'ASCP_UOM_CODE,'
||      'DEMAND_CLASS,'
||      'UNIT_PRICE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE'
||     ')'
||'SELECT '
||      'APS.DEMAND_PLAN_ID,'
||      'APS.SCENARIO_ID,'
||      'APS.DEMAND_ID,'
||      'APS.BUCKET_TYPE,'
||      'APS.START_TIME,'
||      'APS.END_TIME,'
||      'APS.QUANTITY,'
||      'APS.SR_ORGANIZATION_ID,'
||      ':v_src_instance_id,'
||      'APS.SR_INVENTORY_ITEM_ID,'
||      'APS.ERROR_TYPE,'
||      'APS.FORECAST_ERROR,'
||      'RP_lid.INVENTORY_ITEM_ID,'
||      'APS.SR_SHIP_TO_LOC_ID,'
||      'APS.SR_CUSTOMER_ID,'
||      'APS.SR_ZONE_ID,'
||      'APS.PRIORITY,'
||      'APS.DP_UOM_CODE,'
||      'APS.ASCP_UOM_CODE,'
||      'APS.DEMAND_CLASS,'
||      'APS.UNIT_PRICE,'
||      'APS.CREATION_DATE,'
||      'APS.CREATED_BY,'
||      'APS.LAST_UPDATE_LOGIN,'
||      'APS.REQUEST_ID,'
||      'APS.PROGRAM_APPLICATION_ID,'
||      'APS.PROGRAM_ID,'
||      'APS.PROGRAM_UPDATE_DATE'
||' FROM MSD_DP_SCN_ENTRIES_DENORM'|| v_aps_dblink || ' APS, msc_item_id_lid RP_lid'
||' WHERE RP_lid.sr_inventory_item_id = APS.sr_inventory_item_id'
||' AND APS.SR_INSTANCE_ID = '||v_instance_id
||' AND RP_lid.sr_instance_id = '|| v_src_instance_id;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQL for Insert into denorm table is :- '||v_sql_stmt);

EXECUTE IMMEDIATE v_sql_stmt USING v_src_instance_id;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Records inserted into MSD_DP_SCN_ENTRIES_DENORM is :- '||sql%rowcount);

Commit;

END COPY_DP_FORECAST;


PROCEDURE COPY_DP_SCENARIOS IS

BEGIN

  Delete from  MSD_DP_SCENARIOS;-- commit;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The number of rows deleted from MSD_DP_SCENARIOS '|| SQL%ROWCOUNT);

v_sql_stmt:=
'INSERT INTO MSD_DP_SCENARIOS ('
||    'DEMAND_PLAN_ID,'
||    'SCENARIO_ID,'
||    'SCENARIO_NAME,'
||    'DESCRIPTION,'
||    'OUTPUT_PERIOD_TYPE,'
||    'HORIZON_START_DATE,'
||    'HORIZON_END_DATE,'
||    'FORECAST_DATE_USED,'
||    'FORECAST_BASED_ON,'
||    'LAST_UPDATE_DATE,'
||    'LAST_UPDATED_BY,'
||    'CREATION_DATE,'
||    'CREATED_BY,'
||    'LAST_UPDATE_LOGIN,'
||    'REQUEST_ID,'
||    'PROGRAM_APPLICATION_ID,'
||    'PROGRAM_ID,'
||    'PROGRAM_UPDATE_DATE,'
||    'ATTRIBUTE_CATEGORY,'
||    'ATTRIBUTE1,'
||    'ATTRIBUTE2,'
||    'ATTRIBUTE3,'
||    'ATTRIBUTE4,'
||    'ATTRIBUTE5,'
||    'ATTRIBUTE6,'
||    'ATTRIBUTE7,'
||    'ATTRIBUTE8,'
||    'ATTRIBUTE9,'
||    'ATTRIBUTE10,'
||    'ATTRIBUTE11,'
||    'ATTRIBUTE12,'
||    'ATTRIBUTE13,'
||    'ATTRIBUTE14,'
||    'ATTRIBUTE15,'
||    'SCENARIO_TYPE,'
||    'STATUS,'
||    'HISTORY_START_DATE,'
||    'HISTORY_END_DATE,'
||    'PUBLISH_FLAG,'
||    'ENABLE_FLAG,'
||    'PRICE_LIST_NAME,'
||    'LAST_REVISION,'
||    'PARAMETER_NAME,'
||    'CONSUME_FLAG,'
||    'ERROR_TYPE,'
||    'DMD_PRIORITY_SCENARIO_ID,'
||    'SC_TYPE,'
||    'ASSOCIATE_PARAMETER'
|| ')'
|| ' select '
||    'DEMAND_PLAN_ID,'
||    'SCENARIO_ID,'
||    'SCENARIO_NAME,'
||    'DESCRIPTION,'
||    'OUTPUT_PERIOD_TYPE,'
||    'HORIZON_START_DATE,'
||    'HORIZON_END_DATE,'
||    'FORECAST_DATE_USED,'
||    'FORECAST_BASED_ON,'
||    'LAST_UPDATE_DATE,'
||    'LAST_UPDATED_BY,'
||    'CREATION_DATE,'
||    'CREATED_BY,'
||    'LAST_UPDATE_LOGIN,'
||    'REQUEST_ID,'
||    'PROGRAM_APPLICATION_ID,'
||    'PROGRAM_ID,'
||    'PROGRAM_UPDATE_DATE,'
||    'ATTRIBUTE_CATEGORY,'
||    'ATTRIBUTE1,'
||    'ATTRIBUTE2,'
||    'ATTRIBUTE3,'
||    'ATTRIBUTE4,'
||    'ATTRIBUTE5,'
||    'ATTRIBUTE6,'
||    'ATTRIBUTE7,'
||    'ATTRIBUTE8,'
||    'ATTRIBUTE9,'
||    'ATTRIBUTE10,'
||    'ATTRIBUTE11,'
||    'ATTRIBUTE12,'
||    'ATTRIBUTE13,'
||    'ATTRIBUTE14,'
||    'ATTRIBUTE15,'
||    'SCENARIO_TYPE,'
||    'STATUS,'
||    'HISTORY_START_DATE,'
||    'HISTORY_END_DATE,'
||    'PUBLISH_FLAG,'
||    'ENABLE_FLAG,'
||    'PRICE_LIST_NAME,'
||    'LAST_REVISION,'
||    'PARAMETER_NAME,'
||    'CONSUME_FLAG,'
||    'ERROR_TYPE,'
||    'DMD_PRIORITY_SCENARIO_ID,'
||    'SC_TYPE,'
||    'ASSOCIATE_PARAMETER'
|| ' from MSD_DP_SCENARIOS'|| v_aps_dblink;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQL for Insert into MSD_DP_SCENARIOS table is :- '||v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Records inserted into MSD_DP_SCENARIOS is :- '||sql%rowcount);

Commit;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Copy MSD_DP_SCENARIOS for Demantra' );
v_sql_stmt:=
 'INSERT INTO MSD_DP_SCENARIOS ('
||    'DEMAND_PLAN_ID,'
||    'SCENARIO_ID,'
||    'SCENARIO_NAME,'
||    'LAST_REVISION,'
||    'CONSUME_FLAG,'
||    'LAST_UPDATE_DATE,'
||    'LAST_UPDATED_BY,'
||    'CREATION_DATE,'
||    'CREATED_BY'
|| ')'
|| ' select '
||    'DEMAND_PLAN_ID,'
||    'SCENARIO_ID,'
||    'SCENARIO_NAME,'
||    'LAST_REVISION,'
||    'CONSUME_FLAG,'
||    ':v_last_update_date,'
||    ':v_last_updated_by ,'
||    ':v_creation_date ,'
||    ':v_created_by '
|| ' from msd_dp_ascp_scenarios_v'|| v_aps_dblink || ' APS'
|| ' where DEMAND_PLAN_ID = ' ||5555555
|| ' and not exists (select 1 from MSD_DP_SCENARIOS RP '
||'                  where RP.scenario_id = APS.SCENARIO_ID)';

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQL for Demantra insert into MSD_DP_SCENARIOS table is :- '||v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING v_last_update_date,v_last_updated_by,v_creation_date,v_created_by;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Records inserted into MSD_DP_SCENARIOS  for demantra is :- '||sql%rowcount);

Commit;

END COPY_DP_SCENARIOS;

PROCEDURE COPY_DP_SCENARIO_REVISIONS IS

BEGIN

         Delete from MSD_DP_SCENARIO_REVISIONS; --commit;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The number of rows deleted from MSD_DP_SCENARIO_REVISIONS '|| SQL%ROWCOUNT);

v_sql_stmt:=
'Insert into MSD_DP_SCENARIO_REVISIONS ('
||      'DEMAND_PLAN_ID,'
||      'SCENARIO_ID,'
||      'REVISION,'
||      'REVISION_NAME,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'ERROR_TYPE'
||      ')'
||   'select '
||      'DEMAND_PLAN_ID,'
||      'SCENARIO_ID,'
||      'REVISION,'
||      'REVISION_NAME,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'ERROR_TYPE'
|| ' from MSD_DP_SCENARIO_REVISIONS'|| v_aps_dblink;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQL for Insert into MSD_DP_SCENARIO_REVISIONS table is :- '||v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt ;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Records inserted into MSD_DP_SCENARIO_REVISIONS is :- '||sql%rowcount);

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No records in MSD_DP_SCENARIO_REVISIONS ' );
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
      --RETCODE := MSC_UTIL.G_ERROR;
      --ERRBUF := 'No data found';
      RETURN;
    WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
    --  RETCODE := MSC_UTIL.G_ERROR;
     -- ERRBUF := SQLERRM;
      ROLLBACK;
      RETURN;

END COPY_DP_SCENARIO_REVISIONS;

PROCEDURE COPY_DP_DEMAND_PLANS IS

BEGIN

         Delete from MSD_DEMAND_PLANS; -- commit;
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The number of rows deleted from MSD_DEMAND_PLANS '|| SQL%ROWCOUNT);
v_sql_stmt:=
'Insert into MSD_DEMAND_PLANS ('
||      'DEMAND_PLAN_ID,'
||      'ORGANIZATION_ID,'
||      'SR_INSTANCE_ID,'
||      'DEMAND_PLAN_NAME,'
||      'DESCRIPTION,'
||      'CALENDAR_TYPE,'
||      'CALENDAR_CODE,'
||      'PERIOD_SET_NAME,'
||      'BASE_UOM,'
||      'AVERAGE_DISCOUNT,'
||      'CATEGORY_SET_ID,'
||      'LOWEST_PERIOD_TYPE,'
||      'HISTORY_START_DATE,'
||      'VALID_FLAG,'
||      'ENABLE_FCST_EXPLOSION,'
||      'DELETE_PLAN_FLAG,'
||      'ROUNDOFF_THREASHOLD,'
||      'ROUNDOFF_DECIMAL_PLACES,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ATTRIBUTE_CATEGORY,'
||      'ATTRIBUTE1,'
||      'ATTRIBUTE2,'
||      'ATTRIBUTE3,'
||      'ATTRIBUTE4,'
||      'ATTRIBUTE5,'
||      'ATTRIBUTE6,'
||      'ATTRIBUTE7,'
||      'ATTRIBUTE8,'
||      'ATTRIBUTE9,'
||      'ATTRIBUTE10,'
||      'ATTRIBUTE11,'
||      'ATTRIBUTE12,'
||      'ATTRIBUTE13,'
||      'ATTRIBUTE14,'
||      'ATTRIBUTE15,'
||      'AMT_THRESHOLD,'
||      'AMT_DECIMAL_PLACES,'
||      'DP_BUILD_ERROR_FLAG,'
||      'DP_BUILD_REFRESH_NUM,'
||      'G_MIN_TIM_LVL_ID,'
||      'M_MIN_TIM_LVL_ID,'
||      'F_MIN_TIM_LVL_ID,'
||      'C_MIN_TIM_LVL_ID,'
||      'STRIPE_INSTANCE,'
||      'STRIPE_LEVEL_ID,'
||      'STRIPE_SR_LEVEL_PK,'
||      'BUILD_STRIPE_LEVEL_PK,'
||      'ROUNDING_LEVEL_ID,'
||      'STRIPE_STREAM_NAME,'
||      'STRIPE_STREAM_DESIG,'
||      'BUILD_STRIPE_STREAM_NAME,'
||      'BUILD_STRIPE_STREAM_DESIG,'
||      'BUILD_STRIPE_STREAM_REF_NUM,'
||      'USE_ORG_SPECIFIC_BOM_FLAG,'
||      'DELETE_REQUEST_ID'
||      ')'
||   ' select '
||      'DEMAND_PLAN_ID,'
||      'ORGANIZATION_ID,'
||      ':v_src_instance_id,'
||      'DEMAND_PLAN_NAME,'
||      'DESCRIPTION,'
||      'CALENDAR_TYPE,'
||      'CALENDAR_CODE,'
||      'PERIOD_SET_NAME,'
||      'BASE_UOM,'
||      'AVERAGE_DISCOUNT,'
||      'CATEGORY_SET_ID,'
||      'LOWEST_PERIOD_TYPE,'
||      'HISTORY_START_DATE,'
||      'VALID_FLAG,'
||      'ENABLE_FCST_EXPLOSION,'
||      'DELETE_PLAN_FLAG,'
||      'ROUNDOFF_THREASHOLD,'
||      'ROUNDOFF_DECIMAL_PLACES,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ATTRIBUTE_CATEGORY,'
||      'ATTRIBUTE1,'
||      'ATTRIBUTE2,'
||      'ATTRIBUTE3,'
||      'ATTRIBUTE4,'
||      'ATTRIBUTE5,'
||      'ATTRIBUTE6,'
||      'ATTRIBUTE7,'
||      'ATTRIBUTE8,'
||      'ATTRIBUTE9,'
||      'ATTRIBUTE10,'
||      'ATTRIBUTE11,'
||      'ATTRIBUTE12,'
||      'ATTRIBUTE13,'
||      'ATTRIBUTE14,'
||      'ATTRIBUTE15,'
||      'AMT_THRESHOLD,'
||      'AMT_DECIMAL_PLACES,'
||      'DP_BUILD_ERROR_FLAG,'
||      'DP_BUILD_REFRESH_NUM,'
||      'G_MIN_TIM_LVL_ID,'
||      'M_MIN_TIM_LVL_ID,'
||      'F_MIN_TIM_LVL_ID,'
||      'C_MIN_TIM_LVL_ID,'
||      'STRIPE_INSTANCE,'
||      'STRIPE_LEVEL_ID,'
||      'STRIPE_SR_LEVEL_PK,'
||      'BUILD_STRIPE_LEVEL_PK,'
||      'ROUNDING_LEVEL_ID,'
||      'STRIPE_STREAM_NAME,'
||      'STRIPE_STREAM_DESIG,'
||      'BUILD_STRIPE_STREAM_NAME,'
||      'BUILD_STRIPE_STREAM_DESIG,'
||      'BUILD_STRIPE_STREAM_REF_NUM,'
||      'USE_ORG_SPECIFIC_BOM_FLAG,'
||      'DELETE_REQUEST_ID'
|| ' from MSD_DEMAND_PLANS'|| v_aps_dblink
|| ' where sr_instance_id = '|| v_instance_id;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQL for Insert into MSD_DEMAND_PLANS table is :- '||v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING v_src_instance_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Records inserted into MSD_DEMAND_PLANS is :- '||sql%rowcount);

Commit;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Demantra Insert into MSD_DEMAND_PLANS table');
v_sql_stmt:=
'Insert into MSD_DEMAND_PLANS ('
||      'DEMAND_PLAN_ID,'
||      'DEMAND_PLAN_NAME,'
||      'ORGANIZATION_ID,'
||      'SR_INSTANCE_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'USE_ORG_SPECIFIC_BOM_FLAG'
|| ')'
|| 'Values (5555555,'
|| '''Demantra Plan'','
|| '''-23453'','
|| ':v_src_instance_id,'
|| ':v_last_update_date,'
|| ':v_last_updated_by,'
|| ':v_creation_date,'
|| ':v_created_by,'
|| 'NULL)';

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQL for Demantra Insert into MSD_DEMAND_PLANS table is :- '||v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING v_src_instance_id,v_last_update_date,v_last_updated_by,v_creation_date,v_created_by;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Records inserted for demantra into MSD_DEMAND_PLANS is :- '||sql%rowcount);

Commit;

END COPY_DP_DEMAND_PLANS;

PROCEDURE COPY_MSD_DP_SCENARIO_OP_LEVELS IS

BEGIN

         Delete from MSD_DP_SCENARIO_OUTPUT_LEVELS;-- Commit;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The number of rows deleted from MSD_DP_SCENARIO_OUTPUT_LEVELS '|| SQL%ROWCOUNT);

v_sql_stmt:=
'Insert into MSD_DP_SCENARIO_OUTPUT_LEVELS ('
|| ' DEMAND_PLAN_ID, '
|| ' SCENARIO_ID, '
|| ' LEVEL_ID, '
|| ' LAST_UPDATE_DATE, '
|| ' LAST_UPDATED_BY, '
|| ' CREATION_DATE,  '
|| ' CREATED_BY ,  '
|| ' LAST_UPDATE_LOGIN, '
|| ' REQUEST_ID,    '
|| ' PROGRAM_APPLICATION_ID, '
|| ' PROGRAM_ID, '
|| ' PROGRAM_UPDATE_DATE '
|| ' )'
|| ' Select '
|| ' DEMAND_PLAN_ID, '
|| ' SCENARIO_ID, '
|| ' LEVEL_ID,   '
|| ' LAST_UPDATE_DATE,'
|| ' LAST_UPDATED_BY,'
|| ' CREATION_DATE,'
|| ' CREATED_BY ,  '
|| ' LAST_UPDATE_LOGIN, '
|| ' REQUEST_ID, '
|| ' PROGRAM_APPLICATION_ID,'
|| ' PROGRAM_ID, '
|| ' PROGRAM_UPDATE_DATE  '
|| ' from MSD_DP_SCENARIO_OUTPUT_LEVELS'|| v_aps_dblink;


MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'SQL for insert into MSD_DP_SCENARIO_OUTPUT_LEVELS is :- '|| v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt ;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Records inserted into MSD_DP_SCENARIO_OUTPUT_LEVELS is :- '|| sql%rowcount);

Commit;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Demantra insert into MSD_DP_SCENARIO_OUTPUT_LEVELS  ');
v_sql_stmt:=
'Insert into MSD_DP_SCENARIO_OUTPUT_LEVELS ('
|| ' DEMAND_PLAN_ID, '
|| ' SCENARIO_ID, '
|| ' LEVEL_ID, '
|| ' LAST_UPDATE_DATE, '
|| ' LAST_UPDATED_BY, '
|| ' CREATION_DATE,  '
|| ' CREATED_BY ,  '
|| ' LAST_UPDATE_LOGIN, '
|| ' REQUEST_ID,    '
|| ' PROGRAM_APPLICATION_ID, '
|| ' PROGRAM_ID, '
|| ' PROGRAM_UPDATE_DATE '
|| ' )'
|| ' Select '
|| ' DEMAND_PLAN_ID, '
|| ' SCENARIO_ID, '
|| ' LEVEL_ID,   '
|| ' :v_last_update_date,'
|| ' :v_last_updated_by,'
|| ' :v_creation_date,'
|| ' :v_created_by,'
|| ' LAST_UPDATE_LOGIN, '
|| ' REQUEST_ID, '
|| ' PROGRAM_APPLICATION_ID,'
|| ' PROGRAM_ID, '
|| ' PROGRAM_UPDATE_DATE  '
|| ' from msd_dp_scn_output_levels_v'|| v_aps_dblink
|| ' where DEMAND_PLAN_ID = '|| 5555555;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'SQL for Demantra insert into MSD_DP_SCENARIO_OUTPUT_LEVELS is :- '|| v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING v_last_update_date,v_last_updated_by,v_creation_date,v_created_by;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Records inserted for demantra into MSD_DP_SCENARIO_OUTPUT_LEVELS is :- '|| sql%rowcount);

Commit;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Demantra insert into MSD_DP_SCENARIO_OUTPUT_LEVELS for level_id 7  ');
v_sql_stmt:=
'Insert into MSD_DP_SCENARIO_OUTPUT_LEVELS ('
|| ' DEMAND_PLAN_ID, '
|| ' SCENARIO_ID, '
|| ' LEVEL_ID, '
|| ' LAST_UPDATE_DATE, '
|| ' LAST_UPDATED_BY, '
|| ' CREATION_DATE,  '
|| ' CREATED_BY  '
|| ' )'
|| ' Select '
|| ' DEMAND_PLAN_ID, '
|| ' SCENARIO_ID, '
|| ' 7, '
|| ' :v_last_update_date,'
|| ' :v_last_updated_by,'
|| ' :v_creation_date,'
|| ' :v_created_by'
|| ' from msd_dp_ascp_scenarios_v'|| v_aps_dblink ||' APS'
|| ' where global_scenario_flag = ''N'''
|| ' and DEMAND_PLAN_ID = '|| 5555555
|| ' and not exists (select 1 from MSD_DP_SCENARIO_OUTPUT_LEVELS RP '
||'                  where RP.scenario_id = APS.SCENARIO_ID'
||'                  and RP.DEMAND_PLAN_ID = APS.DEMAND_PLAN_ID'
||'                  and RP.level_id = 7)';

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'SQL for level_id Insert is :- '|| v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING v_last_update_date,v_last_updated_by,v_creation_date,v_created_by;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'SQL for level_id Insert is :- '|| sql%rowcount);

Commit;
END COPY_MSD_DP_SCENARIO_OP_LEVELS;

END MSC_CL_COPY_DP_FORECAST;

/
