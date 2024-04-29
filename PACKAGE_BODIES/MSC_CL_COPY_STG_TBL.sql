--------------------------------------------------------
--  DDL for Package Body MSC_CL_COPY_STG_TBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_COPY_STG_TBL" AS -- body
/* $Header: MSCCOPYB.pls 120.4.12010000.4 2010/01/29 11:33:22 vsiyer noship $ */

 -- Global variable Definition
  v_dblink  VARCHAR2(100); -- DB Link for APS server.
  v_instance_id NUMBER;
  v_inst_rp_src_id NUMBER;
  v_ascp_inst VARCHAR2(10);
  v_src_instance_id NUMBER;
  v_icode     VARCHAR2(10);
  v_retcode   NUMBER;   --to keep track of warnings returned by copy procedures
  v_apps_ver Number; /*9327355*/
  v_temp_sql1 varchar2(30);  /*9327355*/

PROCEDURE MSC_INITIALIZE(lv_user_id        IN NUMBER,
                         lv_resp_id        IN NUMBER,
                         lv_application_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
      FND_GLOBAL.APPS_INITIALIZE
                            ( lv_user_id,
                              lv_resp_id,
                              lv_application_id);
COMMIT;
END;

PROCEDURE GET_SOURCE_INSTANCE_ID (
               SOURCE_ID_INDICATOR IN NUMBER,
               SOURCE_INSTANCE_CODE OUT NOCOPY VARCHAR2,
               SOURCE_INSTANCE_ID OUT NOCOPY NUMBER ) IS

CURSOR source_instances IS
       SELECT m2a_dblink
              , instance_id
              , instance_code
       FROM msc_apps_instances
       WHERE
            m2a_dblink IS NOT NULL;

lv_sql_stmt VARCHAR2 (1000);
lv_found_source NUMBER;
BEGIN

  FOR c_rec in source_instances LOOP
   BEGIN

     lv_found_source := 0;
     lv_sql_stmt :=
       'SELECT 1 FROM MRP_AP_APPS_INSTANCES_ALL@' || c_rec.m2a_dblink ||
       ' WHERE ' ||
       '  RP_SOURCE_IND = '|| to_char(SOURCE_ID_INDICATOR);

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The formed SQL to get the source instance: ' ||
                       lv_sql_stmt);
     EXECUTE IMMEDIATE lv_sql_stmt INTO lv_found_source;

     IF (lv_found_source = 1) THEN

       SOURCE_INSTANCE_ID := c_rec.instance_id;
       SOURCE_INSTANCE_CODE := c_rec.instance_code||':';
       EXIT;

     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Skipping Source: ' ||
                        c_rec.instance_code);
   END;
  END LOOP;

  IF (lv_found_source = 0) THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,
                     'No Common Source found for APS and  RP servers');
    SOURCE_INSTANCE_ID := -23453;
  ELSE
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Source Instance ID : ' ||
                      to_char (SOURCE_INSTANCE_ID));
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Source Instance Code : ' ||
                      SOURCE_INSTANCE_CODE);

  END IF;

END GET_SOURCE_INSTANCE_ID;

PROCEDURE SUBMIT_COPY_REQUEST(instance_id in NUMBER
							 ,sr_instance_id in NUMBER,
                 rp_source_ind in NUMBER,
                p_request_id   OUT NOCOPY  NUMBER)
IS
  lv_request_id  NUMBER;
  lv_timeout NUMBER := 180;
BEGIN
  lv_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          'MSC',
                          'MSCCPYST',
                          NULL,  -- description
                          NULL,  -- start date
                          FALSE,
                          instance_id,
                          sr_instance_id,
                          lv_timeout,
						  3,    --Hardcode value for number of workers
                          rp_source_ind
                          );
  p_request_id  := lv_request_id;

END SUBMIT_COPY_REQUEST;


PROCEDURE RP_INITIALIZE_AND_LAUNCH(p_user_name        IN  VARCHAR2,
                     p_resp_name        IN  VARCHAR2,
                     p_application_name IN  VARCHAR2,
                     p_sr_instance_id   IN  NUMBER,
                     p_instance_id      IN  NUMBER,
                     p_RP_source_ind    IN  NUMBER,
                     p_request_id       OUT NOCOPY  NUMBER)
IS
    l_user_id         NUMBER;
    l_application_id  NUMBER;
    l_resp_id         NUMBER;
    l_trace1          varchar2(500);
    l_trace2          varchar2(500);

BEGIN
 l_trace1 := 'ALTER SESSION SET TRACEFILE_IDENTIFIER = ''copyb_fn''';
      execute immediate l_trace1;
 l_trace2 := 'ALTER SESSION SET EVENTS=''10046 TRACE NAME CONTEXT  FOREVER, LEVEL 4''';
      execute immediate l_trace2;

       BEGIN

	          SELECT USER_ID
   	          INTO l_user_id
              FROM FND_USER
           	  WHERE USER_NAME = p_user_name;
	       BEGIN
   	           SELECT APPLICATION_ID
   	           INTO l_application_id
   	           FROM FND_APPLICATION_VL
   	           WHERE APPLICATION_NAME = p_application_name;
	       	   EXCEPTION
   	           WHEN NO_DATA_FOUND THEN
                if p_application_name = 'Advanced Supply Chain Planning' then
                  l_application_id := 724;
                end if;
	       END;

       SELECT responsibility_id
       INTO l_resp_id
       FROM FND_responsibility_vl
       WHERE responsibility_name = p_resp_name
       AND application_Id = l_application_id;

       EXCEPTION

           WHEN NO_DATA_FOUND THEN  RAISE;
           WHEN OTHERS THEN RAISE;

       END;

	   MSC_INITIALIZE( l_user_id,
                       l_resp_id,
                       l_application_id);

    /*
    *  Now call the function to submit the request
    *
    */
    SUBMIT_COPY_REQUEST(p_instance_id,p_sr_instance_id,p_RP_source_ind,p_request_id);

END RP_INITIALIZE_AND_LAUNCH;

PROCEDURE LAUNCH_MONITOR( ERRBUF       OUT NOCOPY VARCHAR2,
			      RETCODE			   OUT NOCOPY NUMBER,
			      pINSTANCE_ID         IN  NUMBER,
                  pSRC_INSTANCE_ID     IN  NUMBER,
			      pTIMEOUT             IN  NUMBER,
			      pTotalWorkerNum      IN  NUMBER,
                  RP_Source_Indicator  IN NUMBER)
IS

lv_coll_start_time DATE;
lv_so_tbl_status NUMBER;
lv_so_lrtype VARCHAR2(1);
lv_lrtype VARCHAR2(1);
lv_sql_stmt VARCHAR2 (1000);
lv_request_id  NUMBER;
lv_errbuf           VARCHAR2(2048);
lv_retcode          NUMBER;

BEGIN

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'pInstance Id: '|| pINSTANCE_ID);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'pSRC_Instance Id: '|| pSRC_INSTANCE_ID);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'pTimeout : '|| pTIMEOUT);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'pTotalWorkerNum Id: '|| pTotalWorkerNum);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'RP_Source_Indicator : '|| RP_Source_Indicator);
-- Initialize Global Variables
  v_instance_id := pSRC_INSTANCE_ID;
  -- v_dblink := '@ma0yd101';
  BEGIN
    SELECT DECODE(M2A_DBLINK,
                  NULL,'',
                  '@'||M2A_DBLINK)
           , INSTANCE_CODE||':',APPS_VER /*9327355*/
	INTO v_dblink, v_icode,v_apps_ver /*9327355*/
	FROM MSC_APPS_INSTANCES
	WHERE
         INSTANCE_ID=v_instance_id;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'DB Link 1 : '|| v_dblink ||':'|| v_icode);
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,
                       'Source Instance Not defined for instance_id:' ||
                       to_char(v_instance_id));
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := 'Source Instance Not defined for instance_id';
      RETURN;
    WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := SQLERRM;
      RETURN;
  END;

-- Now get the parameters from msc_apps_instances of the source ASCP
-- instance

  BEGIN
    v_sql_stmt:=
      'SELECT ' ||
      'INSTANCE_CODE, ' ||
      'COLLECTIONS_START_TIME, ' ||
      'SO_TBL_STATUS, ' ||
	  'SO_LRTYPE,'||
      'LRTYPE  '||
      'FROM MSC_APPS_INSTANCES'||v_dblink ||
      ' WHERE ' ||
	  ' ST_STATUS IN (' || to_char(MSC_UTIL.G_ST_READY)||','||to_char(MSC_UTIL.G_ST_COLLECTING)||')'||
      ' AND instance_id = ' || to_char(pINSTANCE_ID);

    EXECUTE IMMEDIATE v_sql_stmt INTO v_ascp_inst,
                                      lv_coll_start_time,
                                      lv_so_tbl_status,
                                      lv_so_lrtype,
                                      lv_lrtype;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'DB Link 2 : '|| v_dblink);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Formed SQL : '|| v_sql_stmt);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,
                       'Data Not Collected Into Staging table on APS server Select stmt:' ||
                       to_char(v_instance_id));
        RETCODE := MSC_UTIL.G_ERROR;
        ERRBUF := 'Data Not Collected Into Staging table on APS server';
        RETURN;
    END;
    -- Append a ':' to the instance code.
    v_ascp_inst := v_ascp_inst||':';

    GET_SOURCE_INSTANCE_ID (
               RP_Source_Indicator,
               v_icode,
               v_inst_rp_src_id) ;
    IF (v_inst_rp_src_id = -23453) THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'In Launch Monitor 121' );
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := 'No Common Source found for APS and RP servers';
      RETURN;

    END IF;
  BEGIN
    -- Now update msc_apps_instances
    UPDATE MSC_APPS_INSTANCES
    SET
       COLLECTIONS_START_TIME = lv_coll_start_time,
       SO_TBL_STATUS = lv_so_tbl_status,
       LRTYPE   =lv_lrtype,
	   SO_LRTYPE = lv_so_lrtype,
       ST_STATUS = MSC_UTIL.G_ST_READY
    WHERE
         INSTANCE_ID=v_inst_rp_src_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,
                       'Data Not Collected Into Staging table on APS server:' ||
                       to_char(v_instance_id));
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := 'Data Not Collected Into Staging table on APS server';
      RETURN;

    WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
      RETCODE := MSC_UTIL.G_ERROR;
      ERRBUF := SQLERRM;
      RETURN;

  END;
 v_src_instance_id := pINSTANCE_ID;
-- Now call the procedures to copy the staging table data.
 v_retcode := 0;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Update statement is '||lv_lrtype);
/*
--harshit - This code has been commented out since we achieve the same in the previous update of msc_apps_instances
lv_sql_stmt := 'update msc_apps_instances set lrtype = (select lrtype from msc_apps_instances'||
  v_dblink||'where instance_id = '||v_src_instance_id||') where  instance_id = '||v_inst_rp_src_id;

EXECUTE IMMEDIATE lv_sql_stmt;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Update statement is '||lv_sql_stmt);*/

  COPY_CALENDAR_ASSIGNMENTS;
  COPY_JOB_OPERATION_NETWORKS;
  COPY_JOB_OPERATIONS;
  COPY_JOB_REQUIREMENT_OPS;
  COPY_JOB_OP_RESOURCES;
  COPY_APPS_INSTANCES;
  COPY_REGION_SITES;
  COPY_TRIPS;
  COPY_TRIP_STOPS;
  COPY_CARRIER_SERVICES;
  COPY_ASSIGNMENT_SETS;
  COPY_ATP_RULES;
  COPY_BILL_OF_RESOURCES;
  COPY_BIS_BUSINESS_PLANS;
  COPY_BIS_PERIODS;
  COPY_BIS_PFMC_MEASURES;
  COPY_BIS_TARGETS;
  COPY_BIS_TARGET_LEVELS;
  COPY_BOMS;
  COPY_BOM_COMPONENTS;
  COPY_BOR_REQUIREMENTS;
  COPY_CALENDARS;
  COPY_CALENDAR_DATES;
  COPY_CALENDAR_EXCEPTIONS;
  COPY_CALENDAR_SHIFTS;
  COPY_CAL_WEEK_START_DATES;
  COPY_CAL_YEAR_START_DATES;
  COPY_CATEGORY_SETS;
  COPY_COMPANY_USERS;
  COPY_COMPONENT_SUBSTITUTES;
  COPY_CO_PRODUCTS;
  COPY_DEMANDS;
  COPY_DEMAND_CLASSES;
  COPY_DEPARTMENT_RESOURCES;
  COPY_DESIGNATORS;
  COPY_GROUPS;
  COPY_GROUP_COMPANIES;
  COPY_INTERORG_SHIP_METHODS;
  COPY_ITEM_CATEGORIES;
  COPY_ITEM_CUSTOMERS;
  COPY_ITEM_SOURCING;
  COPY_ITEM_SUBSTITUTES;
  COPY_ITEM_SUPPLIERS;
  COPY_LOCATION_ASSOCIATIONS;
  COPY_NET_RESOURCE_AVAIL;
  COPY_OPERATION_COMPONENTS;
  COPY_OPERATION_NETWORKS;
  COPY_OPERATION_RESOURCES;
  COPY_OPERATION_RESOURCE_SEQS;
  COPY_PARAMETERS;
  COPY_PARTNER_CONTACTS;
  COPY_PERIOD_START_DATES;
  COPY_PLANNERS;
  COPY_PROCESS_EFFECTIVITY;
  COPY_PROJECTS;
  COPY_PROJECT_TASKS;
  COPY_REGIONS;
  COPY_REGION_LOCATIONS;
  COPY_RESERVATIONS;
  COPY_RESOURCE_CHANGES;
  COPY_RESOURCE_GROUPS;
  COPY_RESOURCE_REQUIREMENTS;
  COPY_RESOURCE_SHIFTS;
  COPY_ROUTINGS;
  COPY_ROUTING_OPERATIONS;
  COPY_SAFETY_STOCKS;
  COPY_SALES_ORDERS;
  COPY_SHIFT_DATES;
  COPY_SHIFT_EXCEPTIONS;
  COPY_SHIFT_TIMES;
  COPY_SIMULATION_SETS;
  COPY_SOURCING_HISTORY;
  COPY_SOURCING_RULES;
  COPY_SR_ASSIGNMENTS;
  COPY_SR_RECEIPT_ORG;
  COPY_SR_SOURCE_ORG;
  COPY_SUB_INVENTORIES;
  COPY_SUPPLIER_CAPACITIES;
  COPY_SUPPLIER_FLEX_FENCES;
  COPY_SUPPLIES;
  COPY_SYSTEM_ITEMS;
  COPY_TRADING_PARTNERS;
  COPY_TRADING_PARTNER_SITES;
  COPY_UNITS_OF_MEASURE;
  COPY_UNIT_NUMBERS;
  COPY_UOM_CLASS_CONVERSIONS;
  COPY_UOM_CONVERSIONS;
  COPY_WORKDAY_PATTERNS;
  COPY_ZONE_REGIONS;
  COPY_SR_LOOKUPS;
  COPY_DEPT_RES_INSTANCES;
  COPY_NET_RES_INST_AVAIL;
  COPY_JOB_OP_RES_INSTANCES;
  COPY_RESOURCE_INSTANCE_REQS;
  COPY_RESOURCE_SETUPS;
  COPY_SETUP_TRANSITIONS;
  COPY_RES_INSTANCE_CHANGES;
  COPY_STD_OP_RESOURCES;
  COPY_RESOURCE_CHARGES;
  COPY_CALENDAR_MONTHS;
  COPY_OPEN_PAYBACKS;
  COPY_COLL_PARAMETERS (pINSTANCE_ID);

  IF MSC_CL_PULL.SET_ST_STATUS( lv_errbuf, lv_retcode,
                                       v_inst_rp_src_id, G_ST_READY) THEN
  COMMIT;
  END IF;



    IF (v_retcode > 0)
    THEN
	RETCODE := v_retcode;
	ELSE
	RETCODE := 0;
 	END IF;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'The instance_id passed to planning ODS load is  '|| v_inst_rp_src_id);
    lv_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          'MSC',
                          'MSCPDC',
                          NULL,  -- description
                          NULL,  -- start date
                          FALSE, -- TRUE,
               --           pINSTANCE_ID,
                          v_inst_rp_src_id,
                          pTIMEOUT,
						  4,
                          MSC_UTIL.SYS_NO,              --- Recalc NRA
                          MSC_UTIL.SYS_NO,              -- Recalc sourcing history
						  MSC_UTIL.SYS_NO,
                          MSC_UTIL.SYS_NO             -- APCC Repository
           );


--Do an fnd_request (submit_request) to launch ods load instead of this
/*  MSC_CL_COLLECTION.LAUNCH_MONITOR(
                     ERRBUF,
                 	 RETCODE,
                     pINSTANCE_ID,
                     pTIMEOUT,
                     MSC_UTIL.SYS_NO,              --- Recalc NRA
                     MSC_UTIL.SYS_NO,              -- Recalc sourcing history
                     MSC_UTIL.SYS_YES, 			   --exchange_mode
                     MSC_UTIL.SYS_YES);
  RETCODE := MSC_UTIL.G_SUCCESS;
*/

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Reaches after Copy,Value of v_retcode = '|| v_retcode);
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Reaches after Copy,Value of RETCODE = '|| RETCODE);
lv_sql_stmt := 'update msc_apps_instances'||v_dblink||
				' set staging_copy_complete = 1 '||
				' where  instance_id = '||pINSTANCE_ID;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Update statement is '||lv_sql_stmt);

EXECUTE IMMEDIATE lv_sql_stmt;
--USING v_instance_id;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Reaches after update,Value of v_dblink = '|| v_dblink);
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Reaches after update of msc_apps_instances');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'An Error was encountered during the copy');
	retcode := MSC_UTIL.G_ERROR;
END LAUNCH_MONITOR;


PROCEDURE COPY_COLL_PARAMETERS (
                  pINSTANCE_ID IN NUMBER) IS
BEGIN

-- First delete the existing record for that instance from
-- msc_coll_parameters

DELETE FROM MSC_COLL_PARAMETERS
WHERE
INSTANCE_ID = v_inst_rp_src_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_COLL_PARAMETERS');
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'pInstance Id: '|| pINSTANCE_ID);
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'db link: '|| v_dblink);
v_sql_stmt:=
'INSERT INTO MSC_COLL_PARAMETERS ('
||      'INSTANCE_ID,'
||      'DELETE_ODS_DATA,'
||      'SUPPLIER_CAPACITY,'
||      'ATP_RULES,'
||      'BOM,'
||      'BOR,'
||      'CALENDAR_CHECK,'
||      'DEMAND_CLASS,'
||      'FORECAST,'
||      'ITEM,'
||      'KPI_TARGETS_BIS,'
||      'MDS,'
||      'MPS,'
||      'OH,'
||      'PARAMETER,'
||      'PLANNERS,'
||      'PROJECTS,'
||      'PO,'
||      'RESERVATIONS,'
||      'NRA,'
||      'SAFETY_STOCK,'
||      'SALES_ORDER,'
||      'SOURCING_HISTORY,'
||      'SOURCING,'
||      'SUB_INVENTORIES,'
||      'CUSTOMER,'
||      'SUPPLIER,'
||      'UNIT_NUMBERS,'
||      'UOM,'
||      'USER_SUPPLY_DEMAND,'
||      'WIP,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'ITEM_SUBSTITUTES,'
||      'USER_COMP_ASSOCIATION,'
||      'BOM_SN_FLAG,'
||      'BOR_SN_FLAG,'
||      'ITEM_SN_FLAG,'
||      'OH_SN_FLAG,'
||      'USUP_SN_FLAG,'
||      'UDMD_SN_FLAG,'
||      'SO_SN_FLAG,'
||      'FCST_SN_FLAG,'
||      'WIP_SN_FLAG,'
||      'SUPCAP_SN_FLAG,'
||      'PO_SN_FLAG,'
||      'MDS_SN_FLAG,'
||      'MPS_SN_FLAG,'
||      'NOSNAP_FLAG,'
||      'SUPPLIER_RESPONSE,'
||      'SUPREP_SN_FLAG,'
||      'ORG_GROUP,'
||      'THRESHOLD,'
||      'TRIP,'
||      'TRIP_SN_FLAG,'
||      'SALES_CHANNEL,'
||      'FISCAL_CALENDAR,'
||      'PAYBACK_DEMAND_SUPPLY '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
--||      '34064,'
||      'DELETE_ODS_DATA,'
||      'SUPPLIER_CAPACITY,'
||      'ATP_RULES,'
||      'BOM,'
||      'BOR,'
||      'CALENDAR_CHECK,'
||      'DEMAND_CLASS,'
||      'FORECAST,'
||      'ITEM,'
||      'KPI_TARGETS_BIS,'
||      'MDS,'
||      'MPS,'
||      'OH,'
||      'PARAMETER,'
||      'PLANNERS,'
||      'PROJECTS,'
||      'PO,'
||      'RESERVATIONS,'
||      'NRA,'
||      'SAFETY_STOCK,'
||      'SALES_ORDER,'
||      'SOURCING_HISTORY,'
||      'SOURCING,'
||      'SUB_INVENTORIES,'
||      'CUSTOMER,'
||      'SUPPLIER,'
||      'UNIT_NUMBERS,'
||      'UOM,'
||      'USER_SUPPLY_DEMAND,'
||      'WIP,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'ITEM_SUBSTITUTES,'
||      'USER_COMP_ASSOCIATION,'
||      'BOM_SN_FLAG,'
||      'BOR_SN_FLAG,'
||      'ITEM_SN_FLAG,'
||      'OH_SN_FLAG,'
||      'USUP_SN_FLAG,'
||      'UDMD_SN_FLAG,'
||      'SO_SN_FLAG,'
||      'FCST_SN_FLAG,'
||      'WIP_SN_FLAG,'
||      'SUPCAP_SN_FLAG,'
||      'PO_SN_FLAG,'
||      'MDS_SN_FLAG,'
||      'MPS_SN_FLAG,'
||      'NOSNAP_FLAG,'
||      'SUPPLIER_RESPONSE,'
||      'SUPREP_SN_FLAG,'
||      'ORG_GROUP,'
||      'THRESHOLD,'
||      'TRIP,'
||      'TRIP_SN_FLAG,'
||      'SALES_CHANNEL,'
||      'FISCAL_CALENDAR,'
||      'PAYBACK_DEMAND_SUPPLY '
||'FROM MSC_COLL_PARAMETERS'|| v_dblink
||' WHERE '
||' instance_id = ' || to_char(pINSTANCE_ID);

EXECUTE IMMEDIATE v_sql_stmt USING v_inst_rp_src_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
--EXECUTE IMMEDIATE v_sql_stmt;
COMMIT;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying msc_coll_parameters');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying msc_coll_parameters');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;

END COPY_COLL_PARAMETERS;
PROCEDURE COPY_CALENDAR_ASSIGNMENTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'MSC_ST_CALENDAR_ASSIGNMENTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_CALENDAR_ASSIGNMENTS ('
||      'ASSOCIATION_TYPE,'
||      'CALENDAR_CODE,'
||      'CALENDAR_TYPE,'
||      'PARTNER_ID,'
||      'PARTNER_SITE_ID,'
||      'ORGANIZATION_ID,'
||      'SR_INSTANCE_ID,'
||      'CARRIER_PARTNER_ID,'
||      'PARTNER_TYPE,'
||      'ASSOCIATION_LEVEL,'
||      'SHIP_METHOD_CODE,'
||      'REFRESH_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'PARTNER_NAME,'
||      'PARTNER_SITE_CODE,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'COMPANY_NAME,'
||      'BATCH_ID,'
||      'PROCESS_FLAG,'
||      'ST_TRANSACTION_ID,'
||      'DATA_SOURCE_TYPE,'
||      'DELETED_FLAG,'
||      'CARRIER_PARTNER_CODE,'
||      'MESSAGE_ID,'
||      'REQUEST_ID,'
||      'ERROR_TEXT,'
||      'PROGRAM_UPDATE_DATE,'
||      'PROGRAM_ID,'
||      'PROGRAM_APPLICATION_ID '
||     ')'
||'SELECT '
||      'ASSOCIATION_TYPE,'
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'CALENDAR_TYPE,'
||      'PARTNER_ID,'
||      'PARTNER_SITE_ID,'
||      'ORGANIZATION_ID,'
||      ':v_inst_rp_src_id,'
||      'CARRIER_PARTNER_ID,'
||      'PARTNER_TYPE,'
||      'ASSOCIATION_LEVEL,'
||      'SHIP_METHOD_CODE,'
||      'REFRESH_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REPLACE(PARTNER_NAME,:v_ascp_inst,:v_icode),'
||      'PARTNER_SITE_CODE,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'COMPANY_NAME,'
||      'BATCH_ID,'
||      'PROCESS_FLAG,'
||      'ST_TRANSACTION_ID,'
||      'DATA_SOURCE_TYPE,'
||      'DELETED_FLAG,'
||      'CARRIER_PARTNER_CODE,'
||      'MESSAGE_ID,'
||      'REQUEST_ID,'
||      'ERROR_TEXT,'
||      'PROGRAM_UPDATE_DATE,'
||      'PROGRAM_ID,'
||      'PROGRAM_APPLICATION_ID '
||'FROM MSC_ST_CALENDAR_ASSIGNMENTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CALENDAR_ASSIGNMENTS');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CALENDAR_ASSIGNMENTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;

END COPY_CALENDAR_ASSIGNMENTS;
PROCEDURE COPY_JOB_OPERATION_NETWORKS IS

BEGIN
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_JOB_OPERATION_NETWORKS');
v_sql_stmt:=
'INSERT INTO MSC_ST_JOB_OPERATION_NETWORKS ('
||      'WIP_ENTITY_ID,'
||      'SR_INSTANCE_ID,'
||      'ORGANIZATION_ID,'
||      'FROM_OP_SEQ_NUM,'
||      'TO_OP_SEQ_NUM,'
||      'FROM_OP_SEQ_ID,'
||      'TO_OP_SEQ_ID,'
||      'RECOMMENDED,'
||      'TRANSITION_TYPE,'
||      'PLANNING_PCT,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'WIP_ENTITY_NAME,'
||      'ORGANIZATION_CODE,'
||      'FROM_OPERATION_SEQ_CODE,'
||      'TO_OPERATION_SEQ_CODE,'
||      'FROM_OP_EFFECTIVITY_DATE,'
||      'TO_OP_EFFECTIVITY_DATE,'
||      'ROUTING_NAME,'
||      'ASSEMBLY_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'ROUTING_SEQUENCE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'PROCESS_FLAG,'
||      'TO_WIP_ENTITY_ID,'
||      'TRANSFER_QTY,'
||      'TRANSFER_UOM,'
||      'TRANSFER_PCT,'
||      'FROM_ITEM_ID,'
||      'MINIMUM_TRANSFER_QTY,'
||      'MINIMUM_TIME_OFFSET,'
||      'MAXIMUM_TIME_OFFSET,'
||      'APPLY_TO_CHARGES,'
||      'DEPENDENCY_TYPE '
||     ')'
||'SELECT '
||      'WIP_ENTITY_ID,'
||      ':v_inst_rp_src_id,'
||      'ORGANIZATION_ID,'
||      'FROM_OP_SEQ_NUM,'
||      'TO_OP_SEQ_NUM,'
||      'FROM_OP_SEQ_ID,'
||      'TO_OP_SEQ_ID,'
||      'RECOMMENDED,'
||      'TRANSITION_TYPE,'
||      'PLANNING_PCT,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'WIP_ENTITY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'FROM_OPERATION_SEQ_CODE,'
||      'TO_OPERATION_SEQ_CODE,'
||      'FROM_OP_EFFECTIVITY_DATE,'
||      'TO_OP_EFFECTIVITY_DATE,'
||      'ROUTING_NAME,'
||      'ASSEMBLY_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'ROUTING_SEQUENCE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'PROCESS_FLAG,'
||      'TO_WIP_ENTITY_ID,'
||      'TRANSFER_QTY,'
||      'TRANSFER_UOM,'
||      'TRANSFER_PCT,'
||      'FROM_ITEM_ID,'
||      'MINIMUM_TRANSFER_QTY,'
||      'MINIMUM_TIME_OFFSET,'
||      'MAXIMUM_TIME_OFFSET,'
||      'APPLY_TO_CHARGES,'
||      'DEPENDENCY_TYPE '
||'FROM MSC_ST_JOB_OPERATION_NETWORKS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');

COMMIT;
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_JOB_OPERATION_NETWORKS');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_JOB_OPERATION_NETWORKS');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;

END COPY_JOB_OPERATION_NETWORKS;
PROCEDURE COPY_JOB_OPERATIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_JOB_OPERATIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_JOB_OPERATIONS ('
||      'WIP_ENTITY_ID,'
||      'SR_INSTANCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'RECOMMENDED,'
||      'NETWORK_START_END,'
||      'RECO_START_DATE,'
||      'RECO_COMPLETION_DATE,'
||      'OPERATION_SEQUENCE_ID,'
||      'ORGANIZATION_ID,'
||      'STANDARD_OPERATION_CODE,'
||      'DEPARTMENT_ID,'
||      'OPERATION_LEAD_TIME_PERCENT,'
||      'MINIMUM_TRANSFER_QUANTITY,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'OPERATION_TYPE,'
||      'YIELD,'
||      'CUMULATIVE_YIELD,'
||      'REVERSE_CUMULATIVE_YIELD,'
||      'NET_PLANNING_PERCENT,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'WIP_ENTITY_NAME,'
||      'ORGANIZATION_CODE,'
||      'OPERATION_SEQ_CODE,'
||      'ROUTING_NAME,'
||      'ASSEMBLY_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'DEPARTMENT_CODE,'
||      'ROUTING_SEQUENCE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT '
||     ')'
||'SELECT '
||      'WIP_ENTITY_ID,'
||      ':v_inst_rp_src_id,'
||      'OPERATION_SEQ_NUM,'
||      'RECOMMENDED,'
||      'NETWORK_START_END,'
||      'RECO_START_DATE,'
||      'RECO_COMPLETION_DATE,'
||      'OPERATION_SEQUENCE_ID,'
||      'ORGANIZATION_ID,'
||      'STANDARD_OPERATION_CODE,'
||      'DEPARTMENT_ID,'
||      'OPERATION_LEAD_TIME_PERCENT,'
||      'MINIMUM_TRANSFER_QUANTITY,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'OPERATION_TYPE,'
||      'YIELD,'
||      'CUMULATIVE_YIELD,'
||      'REVERSE_CUMULATIVE_YIELD,'
||      'NET_PLANNING_PERCENT,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'WIP_ENTITY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'OPERATION_SEQ_CODE,'
||      'ROUTING_NAME,'
||      'ASSEMBLY_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'DEPARTMENT_CODE,'
||      'ROUTING_SEQUENCE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT '
||'FROM MSC_ST_JOB_OPERATIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_JOB_OPERATIONS');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_JOB_OPERATIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;


END COPY_JOB_OPERATIONS;
PROCEDURE COPY_JOB_REQUIREMENT_OPS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_JOB_REQUIREMENT_OPS');
v_sql_stmt:=
'INSERT INTO MSC_ST_JOB_REQUIREMENT_OPS ('
||      'WIP_ENTITY_ID,'
||      'SR_INSTANCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'COMPONENT_ITEM_ID,'
||      'PRIMARY_COMPONENT_ID,'
||      'SOURCE_PHANTOM_ID,'
||      'RECOMMENDED,'
||      'RECO_DATE_REQUIRED,'
||      'ORGANIZATION_ID,'
||      'COMPONENT_SEQUENCE_ID,'
||      'COMPONENT_PRIORITY,'
||      'DEPARTMENT_ID,'
||      'QUANTITY_PER_ASSEMBLY,'
||      'COMPONENT_YIELD_FACTOR,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'PLANNING_FACTOR,'
||      'LOW_QUANTITY,'
||      'HIGH_QUANTITY,'
||      'OPERATION_LEAD_TIME_PERCENT,'
||      'WIP_SUPPLY_TYPE,'
||      'FROM_END_ITEM_UNIT_NUMBER,'
||      'TO_END_ITEM_UNIT_NUMBER,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'SR_INSTANCE_CODE,'
||      'COMPANY_NAME,'
||      'WIP_ENTITY_NAME,'
||      'ORGANIZATION_CODE,'
||      'OPERATION_SEQ_CODE,'
||      'ROUTING_NAME,'
||      'COMPONENT_NAME,'
||      'ASSEMBLY_ITEM_NAME,'
||      'PRIMARY_COMPONENT_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'ROUTING_SEQUENCE_ID,'
||      'DEPARTMENT_CODE,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'PROCESS_FLAG,'
||      'OP_EFFECTIVITY_DATE,'
||      'SOURCE_PHANTOM_NAME '
||     ')'
||'SELECT '
||      'WIP_ENTITY_ID,'
||      ':v_inst_rp_src_id,'
||      'OPERATION_SEQ_NUM,'
||      'COMPONENT_ITEM_ID,'
||      'PRIMARY_COMPONENT_ID,'
||      'SOURCE_PHANTOM_ID,'
||      'RECOMMENDED,'
||      'RECO_DATE_REQUIRED,'
||      'ORGANIZATION_ID,'
||      'COMPONENT_SEQUENCE_ID,'
||      'COMPONENT_PRIORITY,'
||      'DEPARTMENT_ID,'
||      'QUANTITY_PER_ASSEMBLY,'
||      'COMPONENT_YIELD_FACTOR,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'PLANNING_FACTOR,'
||      'LOW_QUANTITY,'
||      'HIGH_QUANTITY,'
||      'OPERATION_LEAD_TIME_PERCENT,'
||      'WIP_SUPPLY_TYPE,'
||      'FROM_END_ITEM_UNIT_NUMBER,'
||      'TO_END_ITEM_UNIT_NUMBER,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'COMPANY_NAME,'
||      'WIP_ENTITY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'OPERATION_SEQ_CODE,'
||      'ROUTING_NAME,'
||      'COMPONENT_NAME,'
||      'ASSEMBLY_ITEM_NAME,'
||      'PRIMARY_COMPONENT_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'ROUTING_SEQUENCE_ID,'
||      'DEPARTMENT_CODE,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'PROCESS_FLAG,'
||      'OP_EFFECTIVITY_DATE,'
||      'SOURCE_PHANTOM_NAME '
||'FROM MSC_ST_JOB_REQUIREMENT_OPS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
 				   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_JOB_REQUIREMENT_OPS');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_JOB_REQUIREMENT_OPS');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;

END COPY_JOB_REQUIREMENT_OPS;
PROCEDURE COPY_JOB_OP_RESOURCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_JOB_OP_RESOURCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_JOB_OP_RESOURCES ('
||      'WIP_ENTITY_ID,'
||      'SR_INSTANCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'RESOURCE_SEQ_NUM,'
||      'ORGANIZATION_ID,'
||      'ALTERNATE_NUM,'
||      'RECOMMENDED,'
||      'RECO_START_DATE,'
||      'RECO_COMPLETION_DATE,'
||      'RESOURCE_ID,'
||      'ASSIGNED_UNITS,'
||      'USAGE_RATE_OR_AMOUNT,'
||      'UOM_CODE,'
||      'BASIS_TYPE,'
||      'SCHEDULE_FLAG,'
||      'RESOURCE_OFFSET_PERCENT,'
||      'SCHEDULE_SEQ_NUM,'
||      'PRINCIPAL_FLAG,'
||      'DEPARTMENT_ID,'
||      'ACTIVITY_GROUP_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'SR_INSTANCE_CODE,'
||      'COMPANY_NAME,'
||      'WIP_ENTITY_NAME,'
||      'ORGANIZATION_CODE,'
||      'OPERATION_SEQ_CODE,'
||      'ROUTING_SEQUENCE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'PROCESS_FLAG,'
||      'RESOURCE_SEQ_CODE,'
||      'OPERATION_EFFECTIVITY_DATE,'
||      'DEPARTMENT_CODE,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'ITEM_NAME,'
||      'ROUTING_NAME,'
||      'RESOURCE_CODE,'
||      'SETUP_ID,'
||      'GROUP_SEQUENCE_ID,'
||      'GROUP_SEQUENCE_NUMBER,'
||      'MAXIMUM_ASSIGNED_UNITS,'
||      'BATCH_NUMBER,'
||      'PARENT_SEQ_NUM,'
||      'FIRM_FLAG '
||     ')'
||'SELECT '
||      'WIP_ENTITY_ID,'
||      ':v_inst_rp_src_id,'
||      'OPERATION_SEQ_NUM,'
||      'RESOURCE_SEQ_NUM,'
||      'ORGANIZATION_ID,'
||      'ALTERNATE_NUM,'
||      'RECOMMENDED,'
||      'RECO_START_DATE,'
||      'RECO_COMPLETION_DATE,'
||      'RESOURCE_ID,'
||      'ASSIGNED_UNITS,'
||      'USAGE_RATE_OR_AMOUNT,'
||      'UOM_CODE,'
||      'BASIS_TYPE,'
||      'SCHEDULE_FLAG,'
||      'RESOURCE_OFFSET_PERCENT,'
||      'SCHEDULE_SEQ_NUM,'
||      'PRINCIPAL_FLAG,'
||      'DEPARTMENT_ID,'
||      'ACTIVITY_GROUP_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'COMPANY_NAME,'
||      'WIP_ENTITY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'OPERATION_SEQ_CODE,'
||      'ROUTING_SEQUENCE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'PROCESS_FLAG,'
||      'RESOURCE_SEQ_CODE,'
||      'OPERATION_EFFECTIVITY_DATE,'
||      'DEPARTMENT_CODE,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'ITEM_NAME,'
||      'ROUTING_NAME,'
||      'RESOURCE_CODE,'
||      'SETUP_ID,'
||      'GROUP_SEQUENCE_ID,'
||      'GROUP_SEQUENCE_NUMBER,'
||      'MAXIMUM_ASSIGNED_UNITS,'
||      'BATCH_NUMBER,'
||      'PARENT_SEQ_NUM,'
||      'FIRM_FLAG '
||'FROM MSC_ST_JOB_OP_RESOURCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_JOB_OP_RESOURCES');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_JOB_OP_RESOURCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;


END COPY_JOB_OP_RESOURCES;
PROCEDURE COPY_APPS_INSTANCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_APPS_INSTANCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_APPS_INSTANCES ('
||      'MSC_ORG_FOR_BOM_EXPLOSION,'
||      'WSM_CREATE_LBJ_COPY_ROUTING,'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_LOGIN,'
||      'LAST_UPDATE_DATE,'
||      'CREATION_DATE,'
||      'ST_TRANSACTION_ID,'
||      'REFRESH_ID,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'CREATED_BY,'
||      'SR_INSTANCE_CODE,'
||      'SR_INSTANCE_ID,'
||      'LAST_UPDATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'PROGRAM_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'VALIDATION_ORG_ID '
||     ')'
||'SELECT '
||      'MSC_ORG_FOR_BOM_EXPLOSION,'
||      'WSM_CREATE_LBJ_COPY_ROUTING,'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_LOGIN,'
||      'LAST_UPDATE_DATE,'
||      'CREATION_DATE,'
||      'ST_TRANSACTION_ID,'
||      'REFRESH_ID,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'CREATED_BY,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      ':v_inst_rp_src_id,'
||      'LAST_UPDATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'PROGRAM_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'VALIDATION_ORG_ID '
||'FROM MSC_ST_APPS_INSTANCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_APPS_INSTANCES');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_APPS_INSTANCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;

END COPY_APPS_INSTANCES;
PROCEDURE COPY_REGION_SITES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_REGION_SITES');
v_sql_stmt:=
'INSERT INTO MSC_ST_REGION_SITES ('
||      'REGION_ID,'
||      'VENDOR_SITE_ID,'
||      'REGION_TYPE,'
||      'ZONE_LEVEL,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'SR_INSTANCE_CODE,'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'MESSAGE_ID,'
||      'COMPANY_NAME,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'COUNTRY,'
||      'COUNTRY_CODE,'
||      'STATE,'
||      'STATE_CODE,'
||      'CITY,'
||      'CITY_CODE,'
||      'ZONE,'
||      'POSTAL_CODE_FROM,'
||      'POSTAL_CODE_TO,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN '
||     ')'
||'SELECT '
||      'REGION_ID,'
||      'VENDOR_SITE_ID,'
||      'REGION_TYPE,'
||      'ZONE_LEVEL,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'MESSAGE_ID,'
||      'COMPANY_NAME,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'COUNTRY,'
||      'COUNTRY_CODE,'
||      'STATE,'
||      'STATE_CODE,'
||      'CITY,'
||      'CITY_CODE,'
||      'ZONE,'
||      'POSTAL_CODE_FROM,'
||      'POSTAL_CODE_TO,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN '
||'FROM MSC_ST_REGION_SITES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
                ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');

COMMIT;
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_REGION_SITES');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_REGION_SITES');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;


END COPY_REGION_SITES;
PROCEDURE COPY_TRIPS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_TRIPS');
v_sql_stmt:=
'INSERT INTO MSC_ST_TRIPS ('
||      'TRIP_ID,'
||      'NAME,'
||      'SHIP_METHOD_CODE,'
||      'PLANNED_FLAG,'
||      'STATUS_CODE,'
||      'WEIGHT_CAPACITY,'
||      'WEIGHT_UOM,'
||      'VOLUME_CAPACITY,'
||      'VOLUME_UOM,'
||      'SR_INSTANCE_ID,'
||      'DELETED_FLAG,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'TRIP_ID,'
||      'NAME,'
||      'SHIP_METHOD_CODE,'
||      'PLANNED_FLAG,'
||      'STATUS_CODE,'
||      'WEIGHT_CAPACITY,'
||      'WEIGHT_UOM,'
||      'VOLUME_CAPACITY,'
||      'VOLUME_UOM,'
||      ':v_inst_rp_src_id,'
||      'DELETED_FLAG,'
||      'REFRESH_ID '
||'FROM MSC_ST_TRIPS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
			      v_inst_rp_src_id
;


MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_TRIPS');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_TRIPS');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;
END COPY_TRIPS;
PROCEDURE COPY_TRIP_STOPS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_TRIP_STOPS');
v_sql_stmt:=
'INSERT INTO MSC_ST_TRIP_STOPS ('
||      'STOP_ID,'
||      'STOP_LOCATION_ID,'
||      'STATUS_CODE,'
||      'STOP_SEQUENCE_NUMBER,'
||      'PLANNED_ARRIVAL_DATE,'
||      'PLANNED_DEPARTURE_DATE,'
||      'TRIP_ID,'
||      'SR_INSTANCE_ID,'
||      'DELETED_FLAG,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'STOP_ID,'
||      'STOP_LOCATION_ID,'
||      'STATUS_CODE,'
||      'STOP_SEQUENCE_NUMBER,'
||      'PLANNED_ARRIVAL_DATE,'
||      'PLANNED_DEPARTURE_DATE,'
||      'TRIP_ID,'
||      ':v_inst_rp_src_id,'
||      'DELETED_FLAG,'
||      'REFRESH_ID '
||'FROM MSC_ST_TRIP_STOPS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_TRIP_STOPS');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_TRIPS_STOPS');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;
END COPY_TRIP_STOPS;
PROCEDURE COPY_CARRIER_SERVICES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CARRIER_SERVICES');
v_sql_stmt:=
'INSERT INTO MSC_ST_CARRIER_SERVICES ('
||      'SHIP_METHOD_CODE,'
||      'CARRIER_ID,'
||      'SERVICE_LEVEL,'
||      'MODE_OF_TRANSPORT,'
||      'SR_INSTANCE_ID,'
||      'DELETED_FLAG,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'SHIP_METHOD_CODE,'
||      'CARRIER_ID,'
||      'SERVICE_LEVEL,'
||      'MODE_OF_TRANSPORT,'
||      ':v_inst_rp_src_id,'
||      'DELETED_FLAG,'
||      'REFRESH_ID '
||'FROM MSC_ST_CARRIER_SERVICES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
   				  v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CARRIER_SERVICES');
	  v_retcode := 2;
      RAISE;
    ELSE
      IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
 	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CARRIER_SERVICES');
	  v_retcode := 1;
	  END IF;
	RETURN;
    END IF;
END COPY_CARRIER_SERVICES;
PROCEDURE COPY_ASSIGNMENT_SETS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ASSIGNMENT_SETS');
v_sql_stmt:=
'INSERT INTO MSC_ST_ASSIGNMENT_SETS ('
||      'SR_ASSIGNMENT_SET_ID,'
||      'ASSIGNMENT_SET_NAME,'
||      'DESCRIPTION,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'SR_ASSIGNMENT_SET_ID,'
||      'REPLACE(ASSIGNMENT_SET_NAME,:v_ascp_inst,:v_icode),'
||      'DESCRIPTION,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID '
||'FROM MSC_ST_ASSIGNMENT_SETS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ASSIGNMENT_SETS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ASSIGNMENT_SETS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_ASSIGNMENT_SETS;
PROCEDURE COPY_ATP_RULES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ATP_RULES');
v_sql_stmt:=
'INSERT INTO MSC_ST_ATP_RULES ('
||      'RULE_ID,'
||      'SR_INSTANCE_ID,'
||      'RULE_NAME,'
||      'DESCRIPTION,'
||      'ACCUMULATE_AVAILABLE_FLAG,'
||      'BACKWARD_CONSUMPTION_FLAG,'
||      'FORWARD_CONSUMPTION_FLAG,'
||      'PAST_DUE_DEMAND_CUTOFF_FENCE,'
||      'PAST_DUE_SUPPLY_CUTOFF_FENCE,'
||      'INFINITE_SUPPLY_FENCE_CODE,'
||      'INFINITE_SUPPLY_TIME_FENCE,'
||      'ACCEPTABLE_EARLY_FENCE,'
||      'ACCEPTABLE_LATE_FENCE,'
||      'DEFAULT_ATP_SOURCES,'
||      'INCLUDE_SALES_ORDERS,'
||      'INCLUDE_DISCRETE_WIP_DEMAND,'
||      'INCLUDE_REP_WIP_DEMAND,'
||      'INCLUDE_NONSTD_WIP_DEMAND,'
||      'INCLUDE_DISCRETE_MPS,'
||      'INCLUDE_USER_DEFINED_DEMAND,'
||      'INCLUDE_PURCHASE_ORDERS,'
||      'INCLUDE_DISCRETE_WIP_RECEIPTS,'
||      'INCLUDE_REP_WIP_RECEIPTS,'
||      'INCLUDE_NONSTD_WIP_RECEIPTS,'
||      'INCLUDE_INTERORG_TRANSFERS,'
||      'INCLUDE_ONHAND_AVAILABLE,'
||      'INCLUDE_USER_DEFINED_SUPPLY,'
||      'ACCUMULATION_WINDOW,'
||      'INCLUDE_REP_MPS,'
||      'INCLUDE_INTERNAL_REQS,'
||      'INCLUDE_SUPPLIER_REQS,'
||      'INCLUDE_INTERNAL_ORDERS,'
||      'INCLUDE_FLOW_SCHEDULE_DEMAND,'
||      'USER_ATP_SUPPLY_TABLE_NAME,'
||      'USER_ATP_DEMAND_TABLE_NAME,'
||      'MPS_DESIGNATOR,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'DEMAND_CLASS_ATP_FLAG,'
||      'INCLUDE_FLOW_SCHEDULE_RECEIPTS,'
||      'AGGREGATE_TIME_FENCE_CODE,'
||      'AGGREGATE_TIME_FENCE '
||     ')'
||'SELECT '
||      'RULE_ID,'
||      ':v_inst_rp_src_id,'
||      'RULE_NAME,'
||      'DESCRIPTION,'
||      'ACCUMULATE_AVAILABLE_FLAG,'
||      'BACKWARD_CONSUMPTION_FLAG,'
||      'FORWARD_CONSUMPTION_FLAG,'
||      'PAST_DUE_DEMAND_CUTOFF_FENCE,'
||      'PAST_DUE_SUPPLY_CUTOFF_FENCE,'
||      'INFINITE_SUPPLY_FENCE_CODE,'
||      'INFINITE_SUPPLY_TIME_FENCE,'
||      'ACCEPTABLE_EARLY_FENCE,'
||      'ACCEPTABLE_LATE_FENCE,'
||      'DEFAULT_ATP_SOURCES,'
||      'INCLUDE_SALES_ORDERS,'
||      'INCLUDE_DISCRETE_WIP_DEMAND,'
||      'INCLUDE_REP_WIP_DEMAND,'
||      'INCLUDE_NONSTD_WIP_DEMAND,'
||      'INCLUDE_DISCRETE_MPS,'
||      'INCLUDE_USER_DEFINED_DEMAND,'
||      'INCLUDE_PURCHASE_ORDERS,'
||      'INCLUDE_DISCRETE_WIP_RECEIPTS,'
||      'INCLUDE_REP_WIP_RECEIPTS,'
||      'INCLUDE_NONSTD_WIP_RECEIPTS,'
||      'INCLUDE_INTERORG_TRANSFERS,'
||      'INCLUDE_ONHAND_AVAILABLE,'
||      'INCLUDE_USER_DEFINED_SUPPLY,'
||      'ACCUMULATION_WINDOW,'
||      'INCLUDE_REP_MPS,'
||      'INCLUDE_INTERNAL_REQS,'
||      'INCLUDE_SUPPLIER_REQS,'
||      'INCLUDE_INTERNAL_ORDERS,'
||      'INCLUDE_FLOW_SCHEDULE_DEMAND,'
||      'USER_ATP_SUPPLY_TABLE_NAME,'
||      'USER_ATP_DEMAND_TABLE_NAME,'
||      'MPS_DESIGNATOR,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'DEMAND_CLASS_ATP_FLAG,'
||      'INCLUDE_FLOW_SCHEDULE_RECEIPTS,'
||      'AGGREGATE_TIME_FENCE_CODE,'
||      'AGGREGATE_TIME_FENCE '
||'FROM MSC_ST_ATP_RULES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ATP_RULES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ATP_RULES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_ATP_RULES;
PROCEDURE COPY_BILL_OF_RESOURCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BILL_OF_RESOURCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_BILL_OF_RESOURCES ('
||      'ORGANIZATION_ID,'
||      'BILL_OF_RESOURCES,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
||      'ROLLUP_START_DATE,'
||      'ROLLUP_COMPLETION_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'BILL_OF_RESOURCES,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
||      'ROLLUP_START_DATE,'
||      'ROLLUP_COMPLETION_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID '
||'FROM MSC_ST_BILL_OF_RESOURCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				 v_inst_rp_src_id

;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BILL_OF_RESOURCES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BILL_OF_RESOURCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_BILL_OF_RESOURCES;
PROCEDURE COPY_BIS_BUSINESS_PLANS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BIS_BUSINESS_PLANS');
v_sql_stmt:=
'INSERT INTO MSC_ST_BIS_BUSINESS_PLANS ('
||      'BUSINESS_PLAN_ID,'
||      'SHORT_NAME,'
||      'NAME,'
||      'DESCRIPTION,'
||      'VERSION_NO,'
||      'CURRENT_PLAN_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'BUSINESS_PLAN_ID,'
||      'SHORT_NAME,'
||      'NAME,'
||      'DESCRIPTION,'
||      'VERSION_NO,'
||      'CURRENT_PLAN_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_BIS_BUSINESS_PLANS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;


EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BIS_BUSINESS_PLANS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BIS_BUSINESS_PLANS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_BIS_BUSINESS_PLANS;
PROCEDURE COPY_BIS_PERIODS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BIS_PERIODS');
v_sql_stmt:=
'INSERT INTO MSC_ST_BIS_PERIODS ('
||      'ORGANIZATION_ID,'
||      'PERIOD_SET_NAME,'
||      'PERIOD_NAME,'
||      'START_DATE,'
||      'END_DATE,'
||      'PERIOD_TYPE,'
||      'PERIOD_YEAR,'
||      'PERIOD_NUM,'
||      'QUARTER_NUM,'
||      'ENTERED_PERIOD_NAME,'
||      'ADJUSTMENT_PERIOD_FLAG,'
||      'DESCRIPTION,'
||      'CONTEXT,'
||      'YEAR_START_DATE,'
||      'QUARTER_START_DATE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'PERIOD_SET_NAME,'
||      'PERIOD_NAME,'
||      'START_DATE,'
||      'END_DATE,'
||      'PERIOD_TYPE,'
||      'PERIOD_YEAR,'
||      'PERIOD_NUM,'
||      'QUARTER_NUM,'
||      'ENTERED_PERIOD_NAME,'
||      'ADJUSTMENT_PERIOD_FLAG,'
||      'DESCRIPTION,'
||      'CONTEXT,'
||      'YEAR_START_DATE,'
||      'QUARTER_START_DATE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_BIS_PERIODS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BIS_PERIODS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BIS_PERIODS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_BIS_PERIODS;
PROCEDURE COPY_BIS_PFMC_MEASURES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BIS_PFMC_MEASURES');
v_sql_stmt:=
'INSERT INTO MSC_ST_BIS_PFMC_MEASURES ('
||      'MEASURE_ID,'
||      'MEASURE_SHORT_NAME,'
||      'MEASURE_NAME,'
||      'DESCRIPTION,'
||      'ORG_DIMENSION_ID,'
||      'TIME_DIMENSION_ID,'
||      'DIMENSION1_ID,'
||      'DIMENSION2_ID,'
||      'DIMENSION3_ID,'
||      'DIMENSION4_ID,'
||      'DIMENSION5_ID,'
||      'UNIT_OF_MEASURE_CLASS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'MEASURE_ID,'
||      'MEASURE_SHORT_NAME,'
||      'MEASURE_NAME,'
||      'DESCRIPTION,'
||      'ORG_DIMENSION_ID,'
||      'TIME_DIMENSION_ID,'
||      'DIMENSION1_ID,'
||      'DIMENSION2_ID,'
||      'DIMENSION3_ID,'
||      'DIMENSION4_ID,'
||      'DIMENSION5_ID,'
||      'UNIT_OF_MEASURE_CLASS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_BIS_PFMC_MEASURES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BIS_PFMC_MEASURES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BIS_PFMC_MEASURES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_BIS_PFMC_MEASURES;
PROCEDURE COPY_BIS_TARGETS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BIS_TARGETS');
v_sql_stmt:=
'INSERT INTO MSC_ST_BIS_TARGETS ('
||      'TARGET_ID,'
||      'TARGET_LEVEL_ID,'
||      'BUSINESS_PLAN_ID,'
||      'ORG_LEVEL_VALUE_ID,'
||      'TIME_LEVEL_VALUE_ID,'
||      'DIM1_LEVEL_VALUE_ID,'
||      'DIM2_LEVEL_VALUE_ID,'
||      'DIM3_LEVEL_VALUE_ID,'
||      'DIM4_LEVEL_VALUE_ID,'
||      'DIM5_LEVEL_VALUE_ID,'
||      'TARGET,'
||      'RANGE1_LOW,'
||      'RANGE1_HIGH,'
||      'RANGE2_LOW,'
||      'RANGE2_HIGH,'
||      'RANGE3_LOW,'
||      'RANGE3_HIGH,'
||      'NOTIFY_RESP1_ID,'
||      'NOTIFY_RESP1_SHORT_NAME,'
||      'NOTIFY_RESP2_ID,'
||      'NOTIFY_RESP2_SHORT_NAME,'
||      'NOTIFY_RESP3_ID,'
||      'NOTIFY_RESP3_SHORT_NAME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'TARGET_ID,'
||      'TARGET_LEVEL_ID,'
||      'BUSINESS_PLAN_ID,'
||      'ORG_LEVEL_VALUE_ID,'
||      'TIME_LEVEL_VALUE_ID,'
||      'DIM1_LEVEL_VALUE_ID,'
||      'DIM2_LEVEL_VALUE_ID,'
||      'DIM3_LEVEL_VALUE_ID,'
||      'DIM4_LEVEL_VALUE_ID,'
||      'DIM5_LEVEL_VALUE_ID,'
||      'TARGET,'
||      'RANGE1_LOW,'
||      'RANGE1_HIGH,'
||      'RANGE2_LOW,'
||      'RANGE2_HIGH,'
||      'RANGE3_LOW,'
||      'RANGE3_HIGH,'
||      'NOTIFY_RESP1_ID,'
||      'NOTIFY_RESP1_SHORT_NAME,'
||      'NOTIFY_RESP2_ID,'
||      'NOTIFY_RESP2_SHORT_NAME,'
||      'NOTIFY_RESP3_ID,'
||      'NOTIFY_RESP3_SHORT_NAME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_BIS_TARGETS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
  				  v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;


EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BIS_TARGETS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BIS_TARGETS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_BIS_TARGETS;
PROCEDURE COPY_BIS_TARGET_LEVELS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BIS_TARGET_LEVELS');
v_sql_stmt:=
'INSERT INTO MSC_ST_BIS_TARGET_LEVELS ('
||      'TARGET_LEVEL_ID,'
||      'TARGET_LEVEL_SHORT_NAME,'
||      'TARGET_LEVEL_NAME,'
||      'DESCRIPTION,'
||      'MEASURE_ID,'
||      'ORG_LEVEL_ID,'
||      'TIME_LEVEL_ID,'
||      'DIMENSION1_LEVEL_ID,'
||      'DIMENSION2_LEVEL_ID,'
||      'DIMENSION3_LEVEL_ID,'
||      'DIMENSION4_LEVEL_ID,'
||      'DIMENSION5_LEVEL_ID,'
||      'WORKFLOW_ITEM_TYPE,'
||      'WORKFLOW_PROCESS_SHORT_NAME,'
||      'DEFAULT_NOTIFY_RESP_ID,'
||      'DEFAULT_NOTIFY_RESP_SHORT_NAME,'
||      'COMPUTING_FUNCTION_ID,'
||      'REPORT_FUNCTION_ID,'
||      'UNIT_OF_MEASURE,'
||      'SYSTEM_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'TARGET_LEVEL_ID,'
||      'TARGET_LEVEL_SHORT_NAME,'
||      'TARGET_LEVEL_NAME,'
||      'DESCRIPTION,'
||      'MEASURE_ID,'
||      'ORG_LEVEL_ID,'
||      'TIME_LEVEL_ID,'
||      'DIMENSION1_LEVEL_ID,'
||      'DIMENSION2_LEVEL_ID,'
||      'DIMENSION3_LEVEL_ID,'
||      'DIMENSION4_LEVEL_ID,'
||      'DIMENSION5_LEVEL_ID,'
||      'WORKFLOW_ITEM_TYPE,'
||      'WORKFLOW_PROCESS_SHORT_NAME,'
||      'DEFAULT_NOTIFY_RESP_ID,'
||      'DEFAULT_NOTIFY_RESP_SHORT_NAME,'
||      'COMPUTING_FUNCTION_ID,'
||      'REPORT_FUNCTION_ID,'
||      'UNIT_OF_MEASURE,'
||      'SYSTEM_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_BIS_TARGET_LEVELS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id

;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BIS_TARGET_LEVELS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BIS_TARGET_LEVELS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_BIS_TARGET_LEVELS;
PROCEDURE COPY_BOMS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BOMS');
v_sql_stmt:=
'INSERT INTO MSC_ST_BOMS ('
||      'BILL_SEQUENCE_ID,'
||      'ORGANIZATION_ID,'
||      'ASSEMBLY_ITEM_ID,'
||      'ASSEMBLY_TYPE,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'SPECIFIC_ASSEMBLY_COMMENT,'
||      'PENDING_FROM_ECN,'
||      'COMMON_BILL_SEQUENCE_ID,'
||      'SCALING_TYPE,'
||      'BOM_SCALING_TYPE,'
||      'ASSEMBLY_QUANTITY,'
||      'UOM,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'BOM_NAME,'
||      'ORGANIZATION_CODE,'
||      'ASSEMBLY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ITEM_PROCESS_COST,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_BILL_SEQUENCE_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'OPERATION_SEQ_NUM '
||     ')'
||'SELECT '
||      'BILL_SEQUENCE_ID,'
||      'ORGANIZATION_ID,'
||      'ASSEMBLY_ITEM_ID,'
||      'ASSEMBLY_TYPE,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'SPECIFIC_ASSEMBLY_COMMENT,'
||      'PENDING_FROM_ECN,'
||      'COMMON_BILL_SEQUENCE_ID,'
||      'SCALING_TYPE,'
||      'BOM_SCALING_TYPE,'
||      'ASSEMBLY_QUANTITY,'
||      'UOM,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'BOM_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'ASSEMBLY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ITEM_PROCESS_COST,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_BILL_SEQUENCE_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'OPERATION_SEQ_NUM '
||'FROM MSC_ST_BOMS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BOMS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BOMS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_BOMS;
PROCEDURE COPY_BOM_COMPONENTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BOM_COMPONENTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_BOM_COMPONENTS ('
||      'COMPONENT_SEQUENCE_ID,'
||      'ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'USING_ASSEMBLY_ID,'
||      'BILL_SEQUENCE_ID,'
||      'COMPONENT_TYPE,'
||      'SCALING_TYPE,'
||      'CHANGE_NOTICE,'
||      'REVISION,'
||      'UOM_CODE,'
||      'USAGE_QUANTITY,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'FROM_UNIT_NUMBER,'
||      'TO_UNIT_NUMBER,'
||      'USE_UP_CODE,'
||      'SUGGESTED_EFFECTIVITY_DATE,'
||      'DRIVING_ITEM_ID,'
||      'OPERATION_OFFSET_PERCENT,'
||      'OPTIONAL_COMPONENT,'
||      'OLD_EFFECTIVITY_DATE,'
||      'WIP_SUPPLY_TYPE,'
||      'PLANNING_FACTOR,'
||      'ATP_FLAG,'
||      'COMPONENT_YIELD_FACTOR,'
||      'REVISED_ITEM_SEQUENCE_ID,'
||      'STATUS_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'BOM_NAME,'
||      'ORGANIZATION_CODE,'
||      'ASSEMBLY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'COMPONENT_NAME,'
||      'OPERATION_SEQ_CODE,'
||      'DRIVING_ITEM_NAME,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'SCALE_MULTIPLE,'
||      'SCALE_ROUNDING_VARIANCE,'
||      'ROUNDING_DIRECTION,'
||      'PRIMARY_FLAG,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_BILL_SEQUENCE_ID,'
||      'SOURCE_COMPONENT_SEQUENCE_ID,'
||      'SOURCE_USING_ASSEMBLY_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_DRIVING_ITEM_ID,'
||      'CONTRIBUTE_TO_STEP_QTY '
||     ')'
||'SELECT '
||      'COMPONENT_SEQUENCE_ID,'
||      'ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'USING_ASSEMBLY_ID,'
||      'BILL_SEQUENCE_ID,'
||      'COMPONENT_TYPE,'
||      'SCALING_TYPE,'
||      'CHANGE_NOTICE,'
||      'REVISION,'
||      'UOM_CODE,'
||      'USAGE_QUANTITY,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'FROM_UNIT_NUMBER,'
||      'TO_UNIT_NUMBER,'
||      'USE_UP_CODE,'
||      'SUGGESTED_EFFECTIVITY_DATE,'
||      'DRIVING_ITEM_ID,'
||      'OPERATION_OFFSET_PERCENT,'
||      'OPTIONAL_COMPONENT,'
||      'OLD_EFFECTIVITY_DATE,'
||      'WIP_SUPPLY_TYPE,'
||      'PLANNING_FACTOR,'
||      'ATP_FLAG,'
||      'COMPONENT_YIELD_FACTOR,'
||      'REVISED_ITEM_SEQUENCE_ID,'
||      'STATUS_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'BOM_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'ASSEMBLY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'COMPONENT_NAME,'
||      'OPERATION_SEQ_CODE,'
||      'DRIVING_ITEM_NAME,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'SCALE_MULTIPLE,'
||      'SCALE_ROUNDING_VARIANCE,'
||      'ROUNDING_DIRECTION,'
||      'PRIMARY_FLAG,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_BILL_SEQUENCE_ID,'
||      'SOURCE_COMPONENT_SEQUENCE_ID,'
||      'SOURCE_USING_ASSEMBLY_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_DRIVING_ITEM_ID,'
||      'CONTRIBUTE_TO_STEP_QTY '
||'FROM MSC_ST_BOM_COMPONENTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
				   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BOM_COMPONENTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BOM_COMPONENTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_BOM_COMPONENTS;
PROCEDURE COPY_BOR_REQUIREMENTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_BOR_REQUIREMENTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_BOR_REQUIREMENTS ('
||      'BILL_OF_RESOURCES,'
||      'ORGANIZATION_ID,'
||      'ASSEMBLY_ITEM_ID,'
||      'SR_TRANSACTION_ID,'
||      'SOURCE_ITEM_ID,'
||      'RESOURCE_ID,'
||      'RESOURCE_DEPARTMENT_HOURS,'
||      'OPERATION_SEQUENCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'RESOURCE_SEQ_NUM,'
||      'SETBACK_DAYS,'
||      'DEPARTMENT_ID,'
||      'LINE_ID,'
||      'ASSEMBLY_USAGE,'
||      'ORIGINATION_TYPE,'
||      'RESOURCE_UNITS,'
||      'BASIS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'BILL_OF_RESOURCES,'
||      'ORGANIZATION_ID,'
||      'ASSEMBLY_ITEM_ID,'
||      'SR_TRANSACTION_ID,'
||      'SOURCE_ITEM_ID,'
||      'RESOURCE_ID,'
||      'RESOURCE_DEPARTMENT_HOURS,'
||      'OPERATION_SEQUENCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'RESOURCE_SEQ_NUM,'
||      'SETBACK_DAYS,'
||      'DEPARTMENT_ID,'
||      'LINE_ID,'
||      'ASSEMBLY_USAGE,'
||      'ORIGINATION_TYPE,'
||      'RESOURCE_UNITS,'
||      'BASIS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID '
||'FROM MSC_ST_BOR_REQUIREMENTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
    		      v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_BOR_REQUIREMENTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_BOR_REQUIREMENTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_BOR_REQUIREMENTS;
PROCEDURE COPY_CALENDARS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CALENDARS');
v_sql_stmt:=
'INSERT INTO MSC_ST_CALENDARS ('
||      'CALENDAR_CODE,'
||      'DESCRIPTION,'
||      'DAYS_ON,'
||      'DAYS_OFF,'
||      'CALENDAR_START_DATE,'
||      'CALENDAR_END_DATE,'
||      'QUARTERLY_CALENDAR_TYPE,'
||      'SR_INSTANCE_CODE,'
||      'SR_INSTANCE_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'OVERWRITE_FLAG,'
||      'WEEK_START_DAY,'
||      'COMPANY_NAME,'
||      'COMPANY_ID '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'DESCRIPTION,'
||      'DAYS_ON,'
||      'DAYS_OFF,'
||      'CALENDAR_START_DATE,'
||      'CALENDAR_END_DATE,'
||      'QUARTERLY_CALENDAR_TYPE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      ':v_inst_rp_src_id,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'OVERWRITE_FLAG,'
||      'WEEK_START_DAY,'
||      'COMPANY_NAME,'
||      'COMPANY_ID '
||'FROM MSC_ST_CALENDARS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CALENDARS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CALENDARS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_CALENDARS;
PROCEDURE COPY_CALENDAR_DATES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CALENDAR_DATES');
v_sql_stmt:=
'INSERT INTO MSC_ST_CALENDAR_DATES ('
||      'CALENDAR_DATE,'
||      'CALENDAR_CODE,'
||      'EXCEPTION_SET_ID,'
||      'SEQ_NUM,'
||      'NEXT_SEQ_NUM,'
||      'PRIOR_SEQ_NUM,'
||      'NEXT_DATE,'
||      'PRIOR_DATE,'
||      'CALENDAR_START_DATE,'
||      'CALENDAR_END_DATE,'
||      'DESCRIPTION,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'CALENDAR_DATE,'
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'EXCEPTION_SET_ID,'
||      'SEQ_NUM,'
||      'NEXT_SEQ_NUM,'
||      'PRIOR_SEQ_NUM,'
||      'NEXT_DATE,'
||      'PRIOR_DATE,'
||      'CALENDAR_START_DATE,'
||      'CALENDAR_END_DATE,'
||      'DESCRIPTION,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID '
||'FROM MSC_ST_CALENDAR_DATES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CALENDAR_DATES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CALENDAR_DATES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_CALENDAR_DATES;
PROCEDURE COPY_CALENDAR_EXCEPTIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CALENDAR_EXCEPTIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_CALENDAR_EXCEPTIONS ('
||      'CALENDAR_CODE,'
||      'EXCEPTION_DATE,'
||      'EXCEPTION_TYPE,'
||      'SR_INSTANCE_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'EXCEPTION_SET_ID,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMPANY_NAME,'
||      'COMPANY_ID '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'EXCEPTION_DATE,'
||      'EXCEPTION_TYPE,'
||      ':v_inst_rp_src_id,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'EXCEPTION_SET_ID,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMPANY_NAME,'
||      'COMPANY_ID '
||'FROM MSC_ST_CALENDAR_EXCEPTIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CALENDAR_EXCEPTIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CALENDAR_EXCEPTIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_CALENDAR_EXCEPTIONS;
PROCEDURE COPY_CALENDAR_SHIFTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CALENDAR_SHIFTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_CALENDAR_SHIFTS ('
||      'CALENDAR_CODE,'
||      'SHIFT_NUM,'
||      'DAYS_ON,'
||      'DAYS_OFF,'
||      'DESCRIPTION,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SHIFT_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'SHIFT_NUM,'
||      'DAYS_ON,'
||      'DAYS_OFF,'
||      'DESCRIPTION,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SHIFT_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT '
||'FROM MSC_ST_CALENDAR_SHIFTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CALENDAR_SHIFTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CALENDAR_SHIFTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_CALENDAR_SHIFTS;
PROCEDURE COPY_CAL_WEEK_START_DATES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CAL_WEEK_START_DATES');
v_sql_stmt:=
'INSERT INTO MSC_ST_CAL_WEEK_START_DATES ('
||      'CALENDAR_CODE,'
||      'EXCEPTION_SET_ID,'
||      'WEEK_START_DATE,'
||      'NEXT_DATE,'
||      'PRIOR_DATE,'
||      'SEQ_NUM,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'EXCEPTION_SET_ID,'
||      'WEEK_START_DATE,'
||      'NEXT_DATE,'
||      'PRIOR_DATE,'
||      'SEQ_NUM,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_CAL_WEEK_START_DATES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CAL_WEEK_START_DATES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CAL_WEEK_START_DATES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_CAL_WEEK_START_DATES;
PROCEDURE COPY_CAL_YEAR_START_DATES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CAL_YEAR_START_DATES');
v_sql_stmt:=
'INSERT INTO MSC_ST_CAL_YEAR_START_DATES ('
||      'CALENDAR_CODE,'
||      'EXCEPTION_SET_ID,'
||      'YEAR_START_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'EXCEPTION_SET_ID,'
||      'YEAR_START_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_CAL_YEAR_START_DATES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);

EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CAL_YEAR_START_DATES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CAL_YEAR_START_DATES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_CAL_YEAR_START_DATES;
PROCEDURE COPY_CATEGORY_SETS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CATEGORY_SETS');
v_sql_stmt:=
'INSERT INTO MSC_ST_CATEGORY_SETS ('
||      'CATEGORY_SET_ID,'
||      'SR_CATEGORY_SET_ID,'
||      'CATEGORY_SET_NAME,'
||      'DESCRIPTION,'
||      'CONTROL_LEVEL,'
||      'DEFAULT_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'SOURCE_SR_CATEGORY_SET_ID '
||     ')'
||'SELECT '
||      'CATEGORY_SET_ID,'
||      'SR_CATEGORY_SET_ID,'
||      'CATEGORY_SET_NAME,'
||      'DESCRIPTION,'
||      'CONTROL_LEVEL,'
||      'DEFAULT_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'SOURCE_SR_CATEGORY_SET_ID '
||'FROM MSC_ST_CATEGORY_SETS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;
EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CATEGORY_SETS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CATEGORY_SETS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_CATEGORY_SETS;
PROCEDURE COPY_COMPANY_USERS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_COMPANY_USERS');
v_sql_stmt:=
'INSERT INTO MSC_ST_COMPANY_USERS ('
||      'USER_NAME,'
||      'SR_COMPANY_ID,'
||      'SR_INSTANCE_ID,'
||      'PARTNER_TYPE,'
||      'START_DATE,'
||      'END_DATE,'
||      'DESCRIPTION,'
||      'EMAIL_ADDRESS,'
||      'FAX,'
||      'COMPANY_NAME,'
||      'LAST_UPDATE_LOGIN,'
||      'LAST_UPDATE_DATE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'REFRESH_ID,'
||      'REQUEST_ID,'
||      'LAST_UPDATED_BY,'
||      'COLLECTION_PARAMETER '
||     ')'
||'SELECT '
||      'USER_NAME,'
||      'SR_COMPANY_ID,'
||      ':v_inst_rp_src_id,'
||      'PARTNER_TYPE,'
||      'START_DATE,'
||      'END_DATE,'
||      'DESCRIPTION,'
||      'EMAIL_ADDRESS,'
||      'FAX,'
||      'COMPANY_NAME,'
||      'LAST_UPDATE_LOGIN,'
||      'LAST_UPDATE_DATE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'REFRESH_ID,'
||      'REQUEST_ID,'
||      'LAST_UPDATED_BY,'
||      'COLLECTION_PARAMETER '
||'FROM MSC_ST_COMPANY_USERS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
    				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_COMPANY_USERS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_COMPANY_USERS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_COMPANY_USERS;
PROCEDURE COPY_COMPONENT_SUBSTITUTES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_COMPONENT_SUBSTITUTES');
v_sql_stmt:=
'INSERT INTO MSC_ST_COMPONENT_SUBSTITUTES ('
||      'COMPONENT_SEQUENCE_ID,'
||      'SUBSTITUTE_ITEM_ID,'
||      'USAGE_QUANTITY,'
||      'ORGANIZATION_ID,'
||      'PRIORITY,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'BILL_SEQUENCE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'BOM_NAME,'
||      'ORGANIZATION_CODE,'
||      'ASSEMBLY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'COMPONENT_NAME,'
||      'OPERATION_SEQ_CODE,'
||      'EFFECTIVITY_DATE,'
||      'SUB_ITEM_NAME,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ROUNDING_DIRECTION '
||     ')'
||'SELECT '
||      'COMPONENT_SEQUENCE_ID,'
||      'SUBSTITUTE_ITEM_ID,'
||      'USAGE_QUANTITY,'
||      'ORGANIZATION_ID,'
||      'PRIORITY,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'BILL_SEQUENCE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'BOM_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'ASSEMBLY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'COMPONENT_NAME,'
||      'OPERATION_SEQ_CODE,'
||      'EFFECTIVITY_DATE,'
||      'SUB_ITEM_NAME,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ROUNDING_DIRECTION '
||'FROM MSC_ST_COMPONENT_SUBSTITUTES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_COMPONENT_SUBSTITUTES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_COMPONENT_SUBSTITUTES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_COMPONENT_SUBSTITUTES;
PROCEDURE COPY_CO_PRODUCTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CO_PRODUCTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_CO_PRODUCTS ('
||      'COMPONENT_NAME,'
||      'COMPONENT_ID,'
||      'CO_PRODUCT_NAME,'
||      'CO_PRODUCT_ID,'
||      'SPLIT,'
||      'PRIMARY_FLAG,'
||      'ORGANIZATION_CODE,'
||      'DELETED_FLAG,'
||      'SR_INSTANCE_ID,'
||      'COMPANY_NAME,'
||      'LAST_UPDATE_LOGIN,'
||      'LAST_UPDATE_DATE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'REFRESH_ID,'
||      'LAST_UPDATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'CO_PRODUCT_GROUP_ID,'
||      'SOURCE_COMPONENT_ID,'
||      'SOURCE_CO_PRODUCT_ID,'
||      'SOURCE_CO_PRODUCT_GROUP_ID '
||     ')'
||'SELECT '
||      'COMPONENT_NAME,'
||      'COMPONENT_ID,'
||      'CO_PRODUCT_NAME,'
||      'CO_PRODUCT_ID,'
||      'SPLIT,'
||      'PRIMARY_FLAG,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'DELETED_FLAG,'
||      ':v_inst_rp_src_id,'
||      'COMPANY_NAME,'
||      'LAST_UPDATE_LOGIN,'
||      'LAST_UPDATE_DATE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'REFRESH_ID,'
||      'LAST_UPDATED_BY,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'CO_PRODUCT_GROUP_ID,'
||      'SOURCE_COMPONENT_ID,'
||      'SOURCE_CO_PRODUCT_ID,'
||      'SOURCE_CO_PRODUCT_GROUP_ID '
||'FROM MSC_ST_CO_PRODUCTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CO_PRODUCTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CO_PRODUCTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_CO_PRODUCTS;
PROCEDURE COPY_DEMANDS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_DEMANDS');
v_sql_stmt:=
'INSERT INTO MSC_ST_DEMANDS ('
||      'ORDER_PRIORITY,'
||      'DEMAND_ID,'
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'USING_ASSEMBLY_ITEM_ID,'
||      'USING_ASSEMBLY_DEMAND_DATE,'
||      'USING_REQUIREMENT_QUANTITY,'
||      'ASSEMBLY_DEMAND_COMP_DATE,'
||      'DEMAND_TYPE,'
||      'DAILY_DEMAND_RATE,'
||      'ORIGINATION_TYPE,'
||      'SOURCE_ORGANIZATION_ID,'
||      'DISPOSITION_ID,'
||      'RESERVATION_ID,'
||      'DEMAND_SCHEDULE_NAME,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'END_ITEM_UNIT_NUMBER,'
||      'SCHEDULE_DATE,'
||      'OPERATION_SEQ_NUM,'
||      'QUANTITY_ISSUED,'
||      'DEMAND_CLASS,'
||      'SALES_ORDER_NUMBER,'
||      'SALES_ORDER_PRIORITY,'
||      'FORECAST_PRIORITY,'
||      'MPS_DATE_REQUIRED,'
||      'PO_NUMBER,'
||      'WIP_ENTITY_NAME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'REPETITIVE_SCHEDULE_ID,'
||      'WIP_ENTITY_ID,'
||      'SELLING_PRICE,'
||      'DMD_LATENESS_COST,'
||      'DMD_SATISFIED_DATE,'
||      'DMD_SPLIT_FLAG,'
||      'REQUEST_DATE,'
||      'ORDER_NUMBER,'
||      'WIP_STATUS_CODE,'
||      'WIP_SUPPLY_TYPE,'
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
||      'SALES_ORDER_LINE_ID,'
||      'CONFIDENCE_PERCENTAGE,'
||      'BUCKET_TYPE,'
||      'BILL_ID,'
||      'CUSTOMER_ID,'
||      'PROBABILITY,'
||      'SERVICE_LEVEL,'
||      'FORECAST_MAD,'
||      'FORECAST_DESIGNATOR,'
||      'ORIGINAL_SYSTEM_REFERENCE,'
||      'ORIGINAL_SYSTEM_LINE_REFERENCE,'
||      'DEMAND_SOURCE_TYPE,'
||      'SHIP_TO_SITE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'CUSTOMER_NAME,'
||      'CUSTOMER_SITE_ID,'
||      'CUSTOMER_SITE_CODE,'
||      'BILL_CODE,'
||      'ITEM_NAME,'
||      'ROUTING_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'OPERATION_EFFECTIVITY_DATE,'
||      'USING_ASSEMBLY_ITEM_NAME,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'SCHEDULE_LINE_NUM,'
||      'OPERATION_SEQ_CODE,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMMENTS,'
||      'PROMISE_DATE,'
||      'LINK_TO_LINE_ID,'
||      'QUANTITY_PER_ASSEMBLY,'
||      'ORDER_DATE_TYPE_CODE,'
||      'LATEST_ACCEPTABLE_DATE,'
||      'SHIPPING_METHOD_CODE,'
||      'SCHEDULE_SHIP_DATE,'
||      'SCHEDULE_ARRIVAL_DATE,'
||      'REQUEST_SHIP_DATE,'
||      'PROMISE_SHIP_DATE,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_USING_ASSEMBLY_ITEM_ID,'
||      'SOURCE_SALES_ORDER_LINE_ID,'
||      'SOURCE_PROJECT_ID,'
||      'SOURCE_TASK_ID,'
||      'SOURCE_CUSTOMER_SITE_ID,'
||      'SOURCE_BILL_ID,'
||      'SOURCE_DISPOSITION_ID,'
||      'SOURCE_CUSTOMER_ID,'
||      'SOURCE_OPERATION_SEQ_NUM,'
||      'SOURCE_WIP_ENTITY_ID,'
||      'ROUTING_SEQUENCE_ID '
||     ')'
||'SELECT '
||      'ORDER_PRIORITY,'
||      'DEMAND_ID,'
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'USING_ASSEMBLY_ITEM_ID,'
||      'USING_ASSEMBLY_DEMAND_DATE,'
||      'USING_REQUIREMENT_QUANTITY,'
||      'ASSEMBLY_DEMAND_COMP_DATE,'
||      'DEMAND_TYPE,'
||      'DAILY_DEMAND_RATE,'
||      'ORIGINATION_TYPE,'
||      'SOURCE_ORGANIZATION_ID,'
||      'DISPOSITION_ID,'
||      'RESERVATION_ID,'
||      'DEMAND_SCHEDULE_NAME,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'END_ITEM_UNIT_NUMBER,'
||      'SCHEDULE_DATE,'
||      'OPERATION_SEQ_NUM,'
||      'QUANTITY_ISSUED,'
||      'DEMAND_CLASS,'
||      'SALES_ORDER_NUMBER,'
||      'SALES_ORDER_PRIORITY,'
||      'FORECAST_PRIORITY,'
||      'MPS_DATE_REQUIRED,'
||      'PO_NUMBER,'
||      'WIP_ENTITY_NAME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'REPETITIVE_SCHEDULE_ID,'
||      'WIP_ENTITY_ID,'
||      'SELLING_PRICE,'
||      'DMD_LATENESS_COST,'
||      'DMD_SATISFIED_DATE,'
||      'DMD_SPLIT_FLAG,'
||      'REQUEST_DATE,'
||      'ORDER_NUMBER,'
||      'WIP_STATUS_CODE,'
||      'WIP_SUPPLY_TYPE,'
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
||      'SALES_ORDER_LINE_ID,'
||      'CONFIDENCE_PERCENTAGE,'
||      'BUCKET_TYPE,'
||      'BILL_ID,'
||      'CUSTOMER_ID,'
||      'PROBABILITY,'
||      'SERVICE_LEVEL,'
||      'FORECAST_MAD,'
||      'FORECAST_DESIGNATOR,'
||      'ORIGINAL_SYSTEM_REFERENCE,'
||      'ORIGINAL_SYSTEM_LINE_REFERENCE,'
||      'DEMAND_SOURCE_TYPE,'
||      'SHIP_TO_SITE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'CUSTOMER_NAME,'
||      'CUSTOMER_SITE_ID,'
||      'CUSTOMER_SITE_CODE,'
||      'BILL_CODE,'
||      'ITEM_NAME,'
||      'ROUTING_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'OPERATION_EFFECTIVITY_DATE,'
||      'USING_ASSEMBLY_ITEM_NAME,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'SCHEDULE_LINE_NUM,'
||      'OPERATION_SEQ_CODE,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMMENTS,'
||      'PROMISE_DATE,'
||      'LINK_TO_LINE_ID,'
||      'QUANTITY_PER_ASSEMBLY,'
||      'ORDER_DATE_TYPE_CODE,'
||      'LATEST_ACCEPTABLE_DATE,'
||      'SHIPPING_METHOD_CODE,'
||      'SCHEDULE_SHIP_DATE,'
||      'SCHEDULE_ARRIVAL_DATE,'
||      'REQUEST_SHIP_DATE,'
||      'PROMISE_SHIP_DATE,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_USING_ASSEMBLY_ITEM_ID,'
||      'SOURCE_SALES_ORDER_LINE_ID,'
||      'SOURCE_PROJECT_ID,'
||      'SOURCE_TASK_ID,'
||      'SOURCE_CUSTOMER_SITE_ID,'
||      'SOURCE_BILL_ID,'
||      'SOURCE_DISPOSITION_ID,'
||      'SOURCE_CUSTOMER_ID,'
||      'SOURCE_OPERATION_SEQ_NUM,'
||      'SOURCE_WIP_ENTITY_ID,'
||      'ROUTING_SEQUENCE_ID '
||'FROM MSC_ST_DEMANDS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                  v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_DEMANDS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_DEMANDS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_DEMANDS;
PROCEDURE COPY_DEMAND_CLASSES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_DEMAND_CLASSES');
v_sql_stmt:=
'INSERT INTO MSC_ST_DEMAND_CLASSES ('
||      'DEMAND_CLASS,'
||      'MEANING,'
||      'DESCRIPTION,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'ENABLED_FLAG,'
||      'SR_INSTANCE_ID,'
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
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME '
||     ')'
||'SELECT '
||      'DEMAND_CLASS,'
||      'MEANING,'
||      'DESCRIPTION,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'ENABLED_FLAG,'
||      ':v_inst_rp_src_id,'
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
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME '
||'FROM MSC_ST_DEMAND_CLASSES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_DEMAND_CLASSES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_DEMAND_CLASSES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_DEMAND_CLASSES;
PROCEDURE COPY_DEPARTMENT_RESOURCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_DEPARTMENT_RESOURCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_DEPARTMENT_RESOURCES ('
||      'ORGANIZATION_ID,'
||      'RESOURCE_ID,'
||      'RESOURCE_CODE,'
||      'DEPARTMENT_ID,'
||      'DEPARTMENT_CODE,'
||      'DEPARTMENT_CLASS,'
||      'LINE_FLAG,'
||      'OWNING_DEPARTMENT_ID,'
||      'CAPACITY_UNITS,'
||      'MAX_RATE,'
||      'MIN_RATE,'
||      'AGGREGATED_RESOURCE_ID,'
||      'AGGREGATED_RESOURCE_FLAG,'
||      'RESOURCE_GROUP_NAME,'
||      'RESOURCE_GROUP_CODE,'
||      'RESOURCE_BALANCE_FLAG,'
||      'BOTTLENECK_FLAG,'
||      'START_TIME,'
||      'STOP_TIME,'
||      'DEPARTMENT_DESCRIPTION,'
||      'RESOURCE_DESCRIPTION,'
||      'OVER_UTILIZED_PERCENT,'
||      'UNDER_UTILIZED_PERCENT,'
||      'RESOURCE_SHORTAGE_TYPE,'
||      'RESOURCE_EXCESS_TYPE,'
||      'USER_TIME_FENCE,'
||      'UTILIZATION,'
||      'EFFICIENCY,'
||      'RESOURCE_INCLUDE_FLAG,'
||      'CRITICAL_RESOURCE_FLAG,'
||      'RESOURCE_TYPE,'
||      'DISABLE_DATE,'
||      'LINE_DISABLE_DATE,'
||      'AVAILABLE_24_HOURS_FLAG,'
||      'CTP_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'DEPT_OVERHEAD_COST,'
||      'RESOURCE_COST,'
||      'RESOURCE_OVER_UTIL_COST,'
||      'PLANNING_EXCEPTION_SET,'
||      'BATCHABLE_FLAG,'
||      'BATCHING_WINDOW,'
||      'MIN_CAPACITY,'
||      'MAX_CAPACITY,'
||      'UNIT_OF_MEASURE,'
||      'UOM_CLASS_TYPE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'OWNING_DEPARTMENT_CODE,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ATP_RULE_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_DEPARTMENT_ID,'
||      'SOURCE_RESOURCE_ID,'
||      'SOURCE_OWNING_DEPARTMENT_ID,'
||      'CAPACITY_TOLERANCE,'
||      'CHARGEABLE_FLAG,'
||      'IDLE_TIME_TOLERANCE,'
||      'BATCHING_PENALTY,'
||      'LAST_KNOWN_SETUP,'
||      'SCHEDULE_TO_INSTANCE,'
||      'SDS_SCHEDULING_WINDOW,'
||      'SETUP_TIME_PERCENT,'
||      'UTILIZATION_CHANGE_PERCENT,'
||      'SETUP_TIME_TYPE,'
||      'UTILIZATION_CHANGE_TYPE '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'RESOURCE_ID,'
||      'RESOURCE_CODE,'
||      'DEPARTMENT_ID,'
||      'DEPARTMENT_CODE,'
||      'DEPARTMENT_CLASS,'
||      'LINE_FLAG,'
||      'OWNING_DEPARTMENT_ID,'
||      'CAPACITY_UNITS,'
||      'MAX_RATE,'
||      'MIN_RATE,'
||      'AGGREGATED_RESOURCE_ID,'
||      'AGGREGATED_RESOURCE_FLAG,'
||      'RESOURCE_GROUP_NAME,'
||      'RESOURCE_GROUP_CODE,'
||      'RESOURCE_BALANCE_FLAG,'
||      'BOTTLENECK_FLAG,'
||      'START_TIME,'
||      'STOP_TIME,'
||      'DEPARTMENT_DESCRIPTION,'
||      'RESOURCE_DESCRIPTION,'
||      'OVER_UTILIZED_PERCENT,'
||      'UNDER_UTILIZED_PERCENT,'
||      'RESOURCE_SHORTAGE_TYPE,'
||      'RESOURCE_EXCESS_TYPE,'
||      'USER_TIME_FENCE,'
||      'UTILIZATION,'
||      'EFFICIENCY,'
||      'RESOURCE_INCLUDE_FLAG,'
||      'CRITICAL_RESOURCE_FLAG,'
||      'RESOURCE_TYPE,'
||      'DISABLE_DATE,'
||      'LINE_DISABLE_DATE,'
||      'AVAILABLE_24_HOURS_FLAG,'
||      'CTP_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'DEPT_OVERHEAD_COST,'
||      'RESOURCE_COST,'
||      'RESOURCE_OVER_UTIL_COST,'
||      'PLANNING_EXCEPTION_SET,'
||      'BATCHABLE_FLAG,'
||      'BATCHING_WINDOW,'
||      'MIN_CAPACITY,'
||      'MAX_CAPACITY,'
||      'UNIT_OF_MEASURE,'
||      'UOM_CLASS_TYPE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'OWNING_DEPARTMENT_CODE,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ATP_RULE_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_DEPARTMENT_ID,'
||      'SOURCE_RESOURCE_ID,'
||      'SOURCE_OWNING_DEPARTMENT_ID,'
||      'CAPACITY_TOLERANCE,'
||      'CHARGEABLE_FLAG,'
||      'IDLE_TIME_TOLERANCE,'
||      'BATCHING_PENALTY,'
||      'LAST_KNOWN_SETUP,'
||      'SCHEDULE_TO_INSTANCE,'
||      'SDS_SCHEDULING_WINDOW,'
||      'SETUP_TIME_PERCENT,'
||      'UTILIZATION_CHANGE_PERCENT,'
||      'SETUP_TIME_TYPE,'
||      'UTILIZATION_CHANGE_TYPE '
||'FROM MSC_ST_DEPARTMENT_RESOURCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				    v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_DEPARTMENT_RESOURCES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_DEPARTMENT_RESOURCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_DEPARTMENT_RESOURCES;
PROCEDURE COPY_DESIGNATORS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'MSC_ST_DESIGNATORS');
v_sql_stmt:=
'INSERT INTO MSC_ST_DESIGNATORS ('
||      'DESIGNATOR_ID,'
||      'DESIGNATOR,'
||      'SR_DESIGNATOR,'
||      'ORGANIZATION_ID,'
||      'SR_ORGANIZATION_ID,'
||      'MPS_RELIEF,'
||      'INVENTORY_ATP_FLAG,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
||      'DEMAND_CLASS,'
||      'ORGANIZATION_SELECTION,'
||      'PRODUCTION,'
||      'RECOMMENDATION_RELEASE,'
||      'DESIGNATOR_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'CONSUME_FORECAST,'
||      'UPDATE_TYPE,'
||      'FORWARD_UPDATE_TIME_FENCE,'
||      'BACKWARD_UPDATE_TIME_FENCE,'
||      'OUTLIER_UPDATE_PERCENTAGE,'
||      'FORECAST_SET_ID,'
||      'CUSTOMER_ID,'
||      'SHIP_ID,'
||      'BILL_ID,'
||      'BUCKET_TYPE,'
||      'PROBABILITY,'
||      'FORECAST_SET,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ORGANIZATION_CODE,'
||      'CUSTOMER_NAME,'
||      'SHIP_TO_SITE_CODE,'
||      'BILL_TO_SITE_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'SELLER_FLAG '
||     ')'
||'SELECT '
||      'DESIGNATOR_ID,'
||      'DESIGNATOR,'
||      'SR_DESIGNATOR,'
||      'ORGANIZATION_ID,'
||      'SR_ORGANIZATION_ID,'
||      'MPS_RELIEF,'
||      'INVENTORY_ATP_FLAG,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
||      'DEMAND_CLASS,'
||      'ORGANIZATION_SELECTION,'
||      'PRODUCTION,'
||      'RECOMMENDATION_RELEASE,'
||      'DESIGNATOR_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'CONSUME_FORECAST,'
||      'UPDATE_TYPE,'
||      'FORWARD_UPDATE_TIME_FENCE,'
||      'BACKWARD_UPDATE_TIME_FENCE,'
||      'OUTLIER_UPDATE_PERCENTAGE,'
||      'FORECAST_SET_ID,'
||      'CUSTOMER_ID,'
||      'SHIP_ID,'
||      'BILL_ID,'
||      'BUCKET_TYPE,'
||      'PROBABILITY,'
||      'FORECAST_SET,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'CUSTOMER_NAME,'
||      'SHIP_TO_SITE_CODE,'
||      'BILL_TO_SITE_CODE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'SELLER_FLAG '
||'FROM MSC_ST_DESIGNATORS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_DESIGNATORS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_DESIGNATORS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_DESIGNATORS;
PROCEDURE COPY_GROUPS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_GROUPS');
v_sql_stmt:=
'INSERT INTO MSC_ST_GROUPS ('
||      'GROUP_ID,'
||      'GROUP_NAME,'
||      'DESCRIPTION,'
||      'GROUP_TYPE,'
||      'GROUP_OWNER_ID,'
||      'CONTACT_USER_NAME,'
||      'CONTACT_USER_ID,'
||      'CONTRACT_DOC_URL,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CONTEXT,'
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
||      'SR_INSTANCE_CODE,'
||      'SR_INSTANCE_ID,'
||      'BATCH_ID,'
||      'REQUEST_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DELETED_FLAG,'
||      'MESSAGE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      'GROUP_ID,'
||      'GROUP_NAME,'
||      'DESCRIPTION,'
||      'GROUP_TYPE,'
||      'GROUP_OWNER_ID,'
||      'CONTACT_USER_NAME,'
||      'CONTACT_USER_ID,'
||      'CONTRACT_DOC_URL,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CONTEXT,'
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
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      ':v_inst_rp_src_id,'
||      'BATCH_ID,'
||      'REQUEST_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DELETED_FLAG,'
||      'MESSAGE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_GROUPS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_GROUPS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_GROUPS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_GROUPS;
PROCEDURE COPY_GROUP_COMPANIES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_GROUP_COMPANIES');
v_sql_stmt:=
'INSERT INTO MSC_ST_GROUP_COMPANIES ('
||      'GROUP_ID,'
||      'GROUP_NAME,'
||      'COMPANY_NAME,'
||      'COMPANY_ID,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'CONTACT_USER_NAME,'
||      'CONTACT_USER_ID,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CONTEXT,'
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
||      'SR_INSTANCE_CODE,'
||      'SR_INSTANCE_ID,'
||      'BATCH_ID,'
||      'REQUEST_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DELETED_FLAG,'
||      'MESSAGE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'POSTING_PARTY_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      'GROUP_ID,'
||      'GROUP_NAME,'
||      'COMPANY_NAME,'
||      'COMPANY_ID,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'CONTACT_USER_NAME,'
||      'CONTACT_USER_ID,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CONTEXT,'
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
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      ':v_inst_rp_src_id,'
||      'BATCH_ID,'
||      'REQUEST_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DELETED_FLAG,'
||      'MESSAGE_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'POSTING_PARTY_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_GROUP_COMPANIES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_GROUP_COMPANIES');

	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_GROUP_COMPANIES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_GROUP_COMPANIES;
PROCEDURE COPY_INTERORG_SHIP_METHODS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_INTERORG_SHIP_METHODS');
v_sql_stmt:=
'INSERT INTO MSC_ST_INTERORG_SHIP_METHODS ('
||      'FROM_ORGANIZATION_ID,'
||      'TO_ORGANIZATION_ID,'
||      'SHIP_METHOD,'
||      'TIME_UOM_CODE,'
||      'INSTRANSIT_TIME,'
||      'DEFAULT_FLAG,'
||      'FROM_LOCATION_ID,'
||      'TO_LOCATION_ID,'
||      'AVAILABILITY_DATE,'
||      'WEIGHT_CAPACITY,'
||      'WEIGHT_UOM,'
||      'VOLUME_CAPACITY,'
||      'VOLUME_UOM,'
||      'COST_PER_WEIGHT_UNIT,'
||      'COST_PER_VOLUME_UNIT,'
||      'INTRANSIT_TIME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'TRANSPORT_CAP_OVER_UTIL_COST,'
||      'SR_INSTANCE_ID2,'
||      'TO_REGION_ID,'
||      'FROM_ORGANIZATION_CODE,'
||      'TO_ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME,'
||      'FROM_LOCATION_CODE,'
||      'TO_LOCATION_CODE,'
||      'FROM_REGION_ID,'
||      'CURRENCY,'
||      'TO_REGION_TYPE,'
||      'TO_COUNTRY,'
||      'TO_COUNTRY_CODE,'
||      'TO_STATE,'
||      'TO_STATE_CODE,'
||      'TO_CITY,'
||      'TO_CITY_CODE,'
||      'TO_POSTAL_CODE_FROM,'
||      'TO_POSTAL_CODE_TO,'
||      'TO_ZONE,'
||      'FROM_REGION_TYPE,'
||      'FROM_COUNTRY,'
||      'FROM_COUNTRY_CODE,'
||      'FROM_STATE,'
||      'FROM_STATE_CODE,'
||      'FROM_CITY,'
||      'FROM_CITY_CODE,'
||      'FROM_POSTAL_CODE_FROM,'
||      'FROM_POSTAL_CODE_TO,'
||      'FROM_ZONE,'
||      'SHIP_METHOD_TEXT '
||     ')'
||'SELECT '
||      'FROM_ORGANIZATION_ID,'
||      'TO_ORGANIZATION_ID,'
||      'SHIP_METHOD,'
||      'TIME_UOM_CODE,'
||      'INSTRANSIT_TIME,'
||      'DEFAULT_FLAG,'
||      'FROM_LOCATION_ID,'
||      'TO_LOCATION_ID,'
||      'AVAILABILITY_DATE,'
||      'WEIGHT_CAPACITY,'
||      'WEIGHT_UOM,'
||      'VOLUME_CAPACITY,'
||      'VOLUME_UOM,'
||      'COST_PER_WEIGHT_UNIT,'
||      'COST_PER_VOLUME_UNIT,'
||      'INTRANSIT_TIME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'TRANSPORT_CAP_OVER_UTIL_COST,'
||      ':v_inst_rp_src_id,'
||      'TO_REGION_ID,'
||      'FROM_ORGANIZATION_CODE,'
||      'TO_ORGANIZATION_CODE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME,'
||      'FROM_LOCATION_CODE,'
||      'TO_LOCATION_CODE,'
||      'FROM_REGION_ID,'
||      'CURRENCY,'
||      'TO_REGION_TYPE,'
||      'TO_COUNTRY,'
||      'TO_COUNTRY_CODE,'
||      'TO_STATE,'
||      'TO_STATE_CODE,'
||      'TO_CITY,'
||      'TO_CITY_CODE,'
||      'TO_POSTAL_CODE_FROM,'
||      'TO_POSTAL_CODE_TO,'
||      'TO_ZONE,'
||      'FROM_REGION_TYPE,'
||      'FROM_COUNTRY,'
||      'FROM_COUNTRY_CODE,'
||      'FROM_STATE,'
||      'FROM_STATE_CODE,'
||      'FROM_CITY,'
||      'FROM_CITY_CODE,'
||      'FROM_POSTAL_CODE_FROM,'
||      'FROM_POSTAL_CODE_TO,'
||      'FROM_ZONE,'
||      'SHIP_METHOD_TEXT '
||'FROM MSC_ST_INTERORG_SHIP_METHODS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
					,v_inst_rp_src_id
                    ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_INTERORG_SHIP_METHODS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_INTERORG_SHIP_METHODS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_INTERORG_SHIP_METHODS;
PROCEDURE COPY_ITEM_CATEGORIES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ITEM_CATEGORIES');
v_sql_stmt:=
'INSERT INTO MSC_ST_ITEM_CATEGORIES ('
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'SR_CATEGORY_SET_ID,'
||      'SR_CATEGORY_ID,'
||      'CATEGORY_NAME,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
||      'SUMMARY_FLAG,'
||      'ENABLED_FLAG,'
||      'START_DATE_ACTIVE,'
||      'END_DATE_ACTIVE,'
||      'CATEGORY_SET_NAME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_SR_CATEGORY_SET_ID,'
||      'SOURCE_SR_CATEGORY_ID '
||     ')'
||'SELECT '
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'SR_CATEGORY_SET_ID,'
||      'SR_CATEGORY_ID,'
||      'CATEGORY_NAME,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
||      'SUMMARY_FLAG,'
||      'ENABLED_FLAG,'
||      'START_DATE_ACTIVE,'
||      'END_DATE_ACTIVE,'
||      'CATEGORY_SET_NAME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_SR_CATEGORY_SET_ID,'
||      'SOURCE_SR_CATEGORY_ID '
||'FROM MSC_ST_ITEM_CATEGORIES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ITEM_CATEGORIES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ITEM_CATEGORIES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_ITEM_CATEGORIES;
PROCEDURE COPY_ITEM_CUSTOMERS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ITEM_CUSTOMERS');
v_sql_stmt:=
'INSERT INTO MSC_ST_ITEM_CUSTOMERS ('
||      'INVENTORY_ITEM_ID,'
||      'SR_INSTANCE_ID,'
||      'CUSTOMER_ID,'
||      'CUSTOMER_NAME,'
||      'CUSTOMER_SITE_ID,'
||      'CUSTOMER_SITE_NAME,'
||      'ITEM_NAME,'
||      'CUSTOMER_ITEM_NAME,'
||      'DESCRIPTION,'
||      'LEAD_TIME,'
||      'UOM_CODE,'
||      'LIST_PRICE,'
||      'PLANNER_CODE,'
||      'REFRESH_NUMBER,'
||      'PROCESS_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'COMPANY_ID,'
||      'REQUEST_ID,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'DELETED_FLAG,'
||      'COMPANY_NAME,'
||      'PROGRAM_UPDATE_DATE,'
||      'PROGRAM_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'INVENTORY_ITEM_ID,'
||      ':v_inst_rp_src_id,'
||      'CUSTOMER_ID,'
||      'CUSTOMER_NAME,'
||      'CUSTOMER_SITE_ID,'
||      'CUSTOMER_SITE_NAME,'
||      'ITEM_NAME,'
||      'CUSTOMER_ITEM_NAME,'
||      'DESCRIPTION,'
||      'LEAD_TIME,'
||      'UOM_CODE,'
||      'LIST_PRICE,'
||      'PLANNER_CODE,'
||      'REFRESH_NUMBER,'
||      'PROCESS_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'COMPANY_ID,'
||      'REQUEST_ID,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'DELETED_FLAG,'
||      'COMPANY_NAME,'
||      'PROGRAM_UPDATE_DATE,'
||      'PROGRAM_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'REFRESH_ID '
||'FROM MSC_ST_ITEM_CUSTOMERS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ITEM_CUSTOMERS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ITEM_CUSTOMERS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_ITEM_CUSTOMERS;
PROCEDURE COPY_ITEM_SOURCING IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ITEM_SOURCING');
v_sql_stmt:=
'INSERT INTO MSC_ST_ITEM_SOURCING ('
||      'SR_SOURCE_ID,'
||      'SR_RECEIPT_ID,'
||      'REFRESH_ID,'
||      'ASSIGNMENT_ID,'
||      'SOURCING_RULE_ID,'
||      'ASSIGNMENT_SET_ID,'
||      'CATEGORY_ID,'
||      'CATEGORY_SET_ID,'
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'SR_INSTANCE_ID,'
||      'RECEIPT_ORGANIZATION_ID,'
||      'RECEIPT_ORG_INSTANCE_ID,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_ORG_INSTANCE_ID,'
||      'SOURCE_PARTNER_ID,'
||      'SOURCE_PARTNER_SITE_ID,'
||      'ALLOCATION_PERCENT,'
||      'RANK,'
||      'SOURCE_TYPE,'
||      'DESCRIPTION,'
||      'PLANNING_ACTIVE,'
||      'SHIP_METHOD,'
||      'ASSIGNMENT_TYPE,'
||      'ITEM_NAME,'
||      'CATEGORY_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'RECEIPT_ORGANIZATION_CODE,'
||      'RECEIPT_ORG_INSTANCE_CODE,'
||      'SOURCE_ORGANIZATION_CODE,'
||      'SOURCE_ORG_INSTANCE_CODE,'
||      'SOURCE_PARTNER_NAME,'
||      'SOURCE_PARTNER_SITE_CODE,'
||      'SOURCING_RULE_NAME,'
||      'ASSIGNMENT_SET_NAME,'
||      'DELETED_FLAG,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'COMPANY_NAME,'
||      'COMPANY_ID,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_RECEIPT_ORGANIZATION_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_CATEGORY_SET_ID,'
||      'SOURCE_CATEGORY_ID,'
||      'SOURCE_SOURCE_PARTNER_ID,'
||      'SOURCE_SOURCE_PARTNER_SITE_ID,'
||      'SOURCE_SOURCE_ORGANIZATION_ID,'
||      'SOURCE_SOURCING_RULE_ID,'
||      'SOURCE_ASSIGNMENT_SET_ID,'
||      'SOURCE_SR_RECEIPT_ID,'
||      'SOURCE_SR_SOURCE_ID,'
||      'SOURCE_ASSIGNMENT_ID '
||     ')'
||'SELECT '
||      'SR_SOURCE_ID,'
||      'SR_RECEIPT_ID,'
||      'REFRESH_ID,'
||      'ASSIGNMENT_ID,'
||      'SOURCING_RULE_ID,'
||      'ASSIGNMENT_SET_ID,'
||      'CATEGORY_ID,'
||      'CATEGORY_SET_ID,'
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      ':v_inst_rp_src_id,'
||      'RECEIPT_ORGANIZATION_ID,'
||      'RECEIPT_ORG_INSTANCE_ID,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_ORG_INSTANCE_ID,'
||      'SOURCE_PARTNER_ID,'
||      'SOURCE_PARTNER_SITE_ID,'
||      'ALLOCATION_PERCENT,'
||      'RANK,'
||      'SOURCE_TYPE,'
||      'DESCRIPTION,'
||      'PLANNING_ACTIVE,'
||      'SHIP_METHOD,'
||      'ASSIGNMENT_TYPE,'
||      'ITEM_NAME,'
||      'CATEGORY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'RECEIPT_ORGANIZATION_CODE,'
||      'REPLACE(RECEIPT_ORG_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'SOURCE_ORGANIZATION_CODE,'
||      'REPLACE(SOURCE_ORG_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'SOURCE_PARTNER_NAME,'
||      'SOURCE_PARTNER_SITE_CODE,'
||      'SOURCING_RULE_NAME,'
||      'REPLACE(ASSIGNMENT_SET_NAME,:v_ascp_inst,:v_icode),'
||      'DELETED_FLAG,'
||      'MESSAGE_ID,'
||      'ERROR_TEXT,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'COMPANY_NAME,'
||      'COMPANY_ID,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_RECEIPT_ORGANIZATION_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_CATEGORY_SET_ID,'
||      'SOURCE_CATEGORY_ID,'
||      'SOURCE_SOURCE_PARTNER_ID,'
||      'SOURCE_SOURCE_PARTNER_SITE_ID,'
||      'SOURCE_SOURCE_ORGANIZATION_ID,'
||      'SOURCE_SOURCING_RULE_ID,'
||      'SOURCE_ASSIGNMENT_SET_ID,'
||      'SOURCE_SR_RECEIPT_ID,'
||      'SOURCE_SR_SOURCE_ID,'
||      'SOURCE_ASSIGNMENT_ID '
||'FROM MSC_ST_ITEM_SOURCING'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ITEM_SOURCING');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ITEM_SOURCING');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_ITEM_SOURCING;
PROCEDURE COPY_ITEM_SUBSTITUTES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ITEM_SUBSTITUTES');
v_sql_stmt:=
'INSERT INTO MSC_ST_ITEM_SUBSTITUTES ('
||      'SR_INSTANCE_ID,'
||      'LOWER_ITEM_ID,'
||      'HIGHER_ITEM_ID,'
||      'HIGHEST_ITEM_ID,'
||      'CUSTOMER_ID,'
||      'CUSTOMER_SITE_ID,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'RELATIONSHIP_TYPE,'
||      'RECIPROCAL_FLAG,'
||      'SUBSTITUTION_SET,'
||      'PARTIAL_FULFILLMENT_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'SUBSTITUTE_ITEM_NAME,'
||      'ITEM_NAME,'
||      'CUSTOMER_NAME,'
||      'CUSTOMER_SITE_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'DELETED_FLAG,'
||      'COMPANY_NAME,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ORGANIZATION_ID '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'LOWER_ITEM_ID,'
||      'HIGHER_ITEM_ID,'
||      'HIGHEST_ITEM_ID,'
||      'CUSTOMER_ID,'
||      'CUSTOMER_SITE_ID,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'RELATIONSHIP_TYPE,'
||      'RECIPROCAL_FLAG,'
||      'SUBSTITUTION_SET,'
||      'PARTIAL_FULFILLMENT_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'SUBSTITUTE_ITEM_NAME,'
||      'ITEM_NAME,'
||      'CUSTOMER_NAME,'
||      'CUSTOMER_SITE_CODE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'DELETED_FLAG,'
||      'COMPANY_NAME,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ORGANIZATION_ID '
||'FROM MSC_ST_ITEM_SUBSTITUTES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ITEM_SUBSTITUTES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ITEM_SUBSTITUTES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_ITEM_SUBSTITUTES;
PROCEDURE COPY_ITEM_SUPPLIERS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ITEM_SUPPLIERS');
v_sql_stmt:=
'INSERT INTO MSC_ST_ITEM_SUPPLIERS ('
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'SUPPLIER_ID,'
||      'SUPPLIER_SITE_ID,'
||      'USING_ORGANIZATION_ID,'
||      'ASL_ID,'
||      'PROCESSING_LEAD_TIME,'
||      'MINIMUM_ORDER_QUANTITY,'
||      'FIXED_LOT_MULTIPLE,'
||      'DELIVERY_CALENDAR_CODE,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'SUPPLIER_CAP_OVER_UTIL_COST,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'SR_INSTANCE_ID2,'
||      'REFRESH_ID,'
||      'PURCHASING_UNIT_OF_MEASURE,'
||      'ITEM_PRICE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'SUPPLIER_ITEM_NAME,'
||      'PLANNER_CODE,'
||      'SUPPLIER_COMPANY_ID,'
||      'SUPPLIER_COMPANY_SITE_ID,'
||      'VMI_FLAG,'
||      'MIN_MINMAX_QUANTITY,'
||      'MAX_MINMAX_QUANTITY,'
||      'MAXIMUM_ORDER_QUANTITY,'
||      'VMI_REPLENISHMENT_APPROVAL,'
||      'ENABLE_VMI_AUTO_REPLENISH_FLAG,'
||      'ASL_LEVEL,'
||      'USING_ORGANIZATION_CODE,'
||      'MIN_MINMAX_DAYS,'
||      'MAX_MINMAX_DAYS,'
||      'FIXED_ORDER_QUANTITY,'
||      'FORECAST_HORIZON,'
||      'REPLENISHMENT_METHOD,'
||      'ASL_ATTRIBUTE_CREATION_DATE '
||     ')'
||'SELECT '
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'SUPPLIER_ID,'
||      'SUPPLIER_SITE_ID,'
||      'USING_ORGANIZATION_ID,'
||      'ASL_ID,'
||      'PROCESSING_LEAD_TIME,'
||      'MINIMUM_ORDER_QUANTITY,'
||      'FIXED_LOT_MULTIPLE,'
||      'REPLACE(DELIVERY_CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'SUPPLIER_CAP_OVER_UTIL_COST,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'PURCHASING_UNIT_OF_MEASURE,'
||      'ITEM_PRICE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'SUPPLIER_ITEM_NAME,'
||      'PLANNER_CODE,'
||      'SUPPLIER_COMPANY_ID,'
||      'SUPPLIER_COMPANY_SITE_ID,'
||      'VMI_FLAG,'
||      'MIN_MINMAX_QUANTITY,'
||      'MAX_MINMAX_QUANTITY,'
||      'MAXIMUM_ORDER_QUANTITY,'
||      'VMI_REPLENISHMENT_APPROVAL,'
||      'ENABLE_VMI_AUTO_REPLENISH_FLAG,'
||      'ASL_LEVEL,'
||      'USING_ORGANIZATION_CODE,'
||      'MIN_MINMAX_DAYS,'
||      'MAX_MINMAX_DAYS,'
||      'FIXED_ORDER_QUANTITY,'
||      'FORECAST_HORIZON,'
||      'REPLENISHMENT_METHOD,'
||      'ASL_ATTRIBUTE_CREATION_DATE '
||'FROM MSC_ST_ITEM_SUPPLIERS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ITEM_SUPPLIERS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ITEM_SUPPLIERS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_ITEM_SUPPLIERS;
PROCEDURE COPY_LOCATION_ASSOCIATIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_LOCATION_ASSOCIATIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_LOCATION_ASSOCIATIONS ('
||      'LOCATION_ID,'
||      'SR_INSTANCE_ID,'
||      'LOCATION_CODE,'
||      'ORGANIZATON_ID,'
||      'PARTNER_ID,'
||      'PARTNER_SITE_ID,'
||      'SR_TP_ID,'
||      'SR_TP_SITE_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ORGANIZATION_ID,'
||      'REFRESH_ID,'
||      'PARTNER_TYPE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'PARTNER_NAME,'
||      'ORGANIZATION_CODE,'
||      'TP_SITE_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DELETED_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT,'
||      'SOURCE_SR_TP_ID,'
||      'SOURCE_SR_TP_SITE_ID,'
||      'SOURCE_LOCATION_ID '
||     ')'
||'SELECT '
||      'LOCATION_ID,'
||      ':v_inst_rp_src_id,'
||      'LOCATION_CODE,'
||      'ORGANIZATON_ID,'
||      'PARTNER_ID,'
||      'PARTNER_SITE_ID,'
||      'SR_TP_ID,'
||      'SR_TP_SITE_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ORGANIZATION_ID,'
||      'REFRESH_ID,'
||      'PARTNER_TYPE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(PARTNER_NAME,:v_ascp_inst,:v_icode),'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'TP_SITE_CODE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DELETED_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT,'
||      'SOURCE_SR_TP_ID,'
||      'SOURCE_SR_TP_SITE_ID,'
||      'SOURCE_LOCATION_ID '
||'FROM MSC_ST_LOCATION_ASSOCIATIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
     				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_LOCATION_ASSOCIATIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_LOCATION_ASSOCIATIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_LOCATION_ASSOCIATIONS;
PROCEDURE COPY_NET_RESOURCE_AVAIL IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_NET_RESOURCE_AVAIL');
v_sql_stmt:=
'INSERT INTO MSC_ST_NET_RESOURCE_AVAIL ('
||      'ORGANIZATION_ID,'
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'SHIFT_NUM,'
||      'SHIFT_DATE,'
||      'FROM_TIME,'
||      'TO_TIME,'
||      'CAPACITY_UNITS,'
||      'SIMULATION_SET,'
||      'AGGREGATE_RESOURCE_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'SHIFT_NUM,'
||      'SHIFT_DATE,'
||      'FROM_TIME,'
||      'TO_TIME,'
||      'CAPACITY_UNITS,'
||      'SIMULATION_SET,'
||      'AGGREGATE_RESOURCE_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID '
||'FROM MSC_ST_NET_RESOURCE_AVAIL'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_NET_RESOURCE_AVAIL');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_NET_RESOURCE_AVAIL');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_NET_RESOURCE_AVAIL;
PROCEDURE COPY_OPERATION_COMPONENTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_OPERATION_COMPONENTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_OPERATION_COMPONENTS ('
||      'ORGANIZATION_ID,'
||      'OPERATION_SEQUENCE_ID,'
||      'COMPONENT_SEQUENCE_ID,'
||      'BILL_SEQUENCE_ID,'
||      'ROUTING_SEQUENCE_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'OPERATION_SEQUENCE_ID,'
||      'COMPONENT_SEQUENCE_ID,'
||      'BILL_SEQUENCE_ID,'
||      'ROUTING_SEQUENCE_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_OPERATION_COMPONENTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_OPERATION_COMPONENTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_OPERATION_COMPONENTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_OPERATION_COMPONENTS;
PROCEDURE COPY_OPERATION_NETWORKS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_OPERATION_NETWORKS:');
v_sql_stmt:=
'INSERT INTO MSC_ST_OPERATION_NETWORKS ('
||      'FROM_OP_SEQ_ID,'
||      'TO_OP_SEQ_ID,'
||      'TRANSITION_TYPE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'ORIGINAL_SYSTEM_REFERENCE,'
||      'PLANNING_PCT,'
||      'CUMMULATIVE_PCT,'
||      'EFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'PLAN_ID,'
||      'SR_INSTANCE_ID,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN,'
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
||      'ROUTING_SEQUENCE_ID,'
||      'FROM_OP_SEQ_NUM,'
||      'TO_OP_SEQ_NUM,'
||      'FROM_OPERATION_SEQ_CODE,'
||      'FROM_OP_EFFECTIVITY_DATE,'
||      'FROM_OP_DISABLE_DATE,'
||      'TO_OPERATION_SEQ_CODE,'
||      'TO_OP_EFFECTIVITY_DATE,'
||      'TO_OP_DISABLE_DATE,'
||      'ROUTING_NAME,'
||      'ASSEMBLY_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'COMPANY_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ERROR_TEXT,'
||      'PROGRAM_APPLICATION_ID,'
||      'REQUEST_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ST_TRANSACTION_ID,'
||      'TO_ROUTING_SEQUENCE_ID,'
||      'FROM_ITEM_ID,'
||      'MINIMUM_TRANSFER_QTY,'
||      'MINIMUM_TIME_OFFSET,'
||      'MAXIMUM_TIME_OFFSET,'
||      'TO_ALT_ROUTING_DESIGNATOR,'
||      'APPLY_TO_CHARGES,'
||      'TRANSFER_QTY,'
||      'TRANSFER_UOM,'
||      'TRANSFER_PCT,'
||      'DEPENDENCY_TYPE,'
||      'ORGANIZATION_ID '
||     ')'
||'SELECT '
||      'FROM_OP_SEQ_ID,'
||      'TO_OP_SEQ_ID,'
||      'TRANSITION_TYPE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'ORIGINAL_SYSTEM_REFERENCE,'
||      'PLANNING_PCT,'
||      'CUMMULATIVE_PCT,'
||      'EFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'PLAN_ID,'
||      ':v_inst_rp_src_id,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN,'
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
||      'ROUTING_SEQUENCE_ID,'
||      'FROM_OP_SEQ_NUM,'
||      'TO_OP_SEQ_NUM,'
||      'FROM_OPERATION_SEQ_CODE,'
||      'FROM_OP_EFFECTIVITY_DATE,'
||      'FROM_OP_DISABLE_DATE,'
||      'TO_OPERATION_SEQ_CODE,'
||      'TO_OP_EFFECTIVITY_DATE,'
||      'TO_OP_DISABLE_DATE,'
||      'ROUTING_NAME,'
||      'ASSEMBLY_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'COMPANY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'BATCH_ID,'
||      'ERROR_TEXT,'
||      'PROGRAM_APPLICATION_ID,'
||      'REQUEST_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ST_TRANSACTION_ID,'
||      'TO_ROUTING_SEQUENCE_ID,'
||      'FROM_ITEM_ID,'
||      'MINIMUM_TRANSFER_QTY,'
||      'MINIMUM_TIME_OFFSET,'
||      'MAXIMUM_TIME_OFFSET,'
||      'TO_ALT_ROUTING_DESIGNATOR,'
||      'APPLY_TO_CHARGES,'
||      'TRANSFER_QTY,'
||      'TRANSFER_UOM,'
||      'TRANSFER_PCT,'
||      'DEPENDENCY_TYPE,'
||      'ORGANIZATION_ID '
||'FROM MSC_ST_OPERATION_NETWORKS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_OPERATION_NETWORKS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_OPERATION_NETWORKS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_OPERATION_NETWORKS;
PROCEDURE COPY_OPERATION_RESOURCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_OPERATION_RESOURCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_OPERATION_RESOURCES ('
||      'ROUTING_SEQUENCE_ID,'
||      'RESOURCE_TYPE,'
||      'OPERATION_SEQUENCE_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'RESOURCE_ID,'
||      'ALTERNATE_NUMBER,'
||      'PRINCIPAL_FLAG,'
||      'BASIS_TYPE,'
||      'RESOURCE_USAGE,'
||      'MAX_RESOURCE_UNITS,'
||      'RESOURCE_UNITS,'
||      'UOM_CODE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ROUTING_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'ORGANIZATION_CODE,'
||      'ASSEMBLY_NAME,'
||      'OPERATION_EFFECTIVITY_DATE,'
||      'SR_INSTANCE_CODE,'
||      'OPERATION_SEQ_CODE,'
||      'RESOURCE_SEQ_CODE,'
||      'DEPARTMENT_ID,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ACTIVITY_GROUP_ID,'
||      'SCHEDULE_FLAG,'
||      'ORGANIZATION_ID,'
||      'RESOURCE_OFFSET_PERCENT,'
||      'SOURCE_ROUTING_SEQUENCE_ID,'
||      'SOURCE_OPERATION_SEQUENCE_ID,'
||      'SOURCE_RESOURCE_SEQ_NUM,'
||      'SOURCE_RESOURCE_ID,'
||      'SOURCE_DEPARTMENT_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SETUP_ID,'
||      'MINIMUM_CAPACITY,'
||      'MAXIMUM_CAPACITY,'
||      'ORIG_RESOURCE_SEQ_NUM,'
||      'BREAKABLE_ACTIVITY_FLAG '
||     ')'
||'SELECT '
||      'ROUTING_SEQUENCE_ID,'
||      'RESOURCE_TYPE,'
||      'OPERATION_SEQUENCE_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'RESOURCE_ID,'
||      'ALTERNATE_NUMBER,'
||      'PRINCIPAL_FLAG,'
||      'BASIS_TYPE,'
||      'RESOURCE_USAGE,'
||      'MAX_RESOURCE_UNITS,'
||      'RESOURCE_UNITS,'
||      'UOM_CODE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ROUTING_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'ASSEMBLY_NAME,'
||      'OPERATION_EFFECTIVITY_DATE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'OPERATION_SEQ_CODE,'
||      'RESOURCE_SEQ_CODE,'
||      'DEPARTMENT_ID,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ACTIVITY_GROUP_ID,'
||      'SCHEDULE_FLAG,'
||      'ORGANIZATION_ID,'
||      'RESOURCE_OFFSET_PERCENT,'
||      'SOURCE_ROUTING_SEQUENCE_ID,'
||      'SOURCE_OPERATION_SEQUENCE_ID,'
||      'SOURCE_RESOURCE_SEQ_NUM,'
||      'SOURCE_RESOURCE_ID,'
||      'SOURCE_DEPARTMENT_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SETUP_ID,'
||      'MINIMUM_CAPACITY,'
||      'MAXIMUM_CAPACITY,'
||      'ORIG_RESOURCE_SEQ_NUM,'
||      'BREAKABLE_ACTIVITY_FLAG '
||'FROM MSC_ST_OPERATION_RESOURCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_OPERATION_RESOURCES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_OPERATION_RESOURCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_OPERATION_RESOURCES;
PROCEDURE COPY_OPERATION_RESOURCE_SEQS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_OPERATION_RESOURCE_SEQS');
v_sql_stmt:=
'INSERT INTO MSC_ST_OPERATION_RESOURCE_SEQS ('
||      'ROUTING_SEQUENCE_ID,'
||      'OPERATION_SEQUENCE_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'SCHEDULE_FLAG,'
||      'RESOURCE_OFFSET_PERCENT,'
||      'DEPARTMENT_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'CUMMULATIVE_PCT,'
||      'ACTIVITY_GROUP_ID,'
||      'ORGANIZATION_ID '
||     ')'
||'SELECT '
||      'ROUTING_SEQUENCE_ID,'
||      'OPERATION_SEQUENCE_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'SCHEDULE_FLAG,'
||      'RESOURCE_OFFSET_PERCENT,'
||      'DEPARTMENT_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'CUMMULATIVE_PCT,'
||      'ACTIVITY_GROUP_ID,'
||      'ORGANIZATION_ID '
||'FROM MSC_ST_OPERATION_RESOURCE_SEQS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_OPERATION_RESOURCE_SEQS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_OPERATION_RESOURCE_SEQS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_OPERATION_RESOURCE_SEQS;
PROCEDURE COPY_PARAMETERS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_PARAMETERS');
v_sql_stmt:=
'INSERT INTO MSC_ST_PARAMETERS ('
||      'ORGANIZATION_ID,'
||      'DEMAND_TIME_FENCE_FLAG,'
||      'PLANNING_TIME_FENCE_FLAG,'
||      'OPERATION_SCHEDULE_TYPE,'
||      'CONSIDER_WIP,'
||      'CONSIDER_PO,'
||      'SNAPSHOT_LOCK,'
||      'PLAN_SAFETY_STOCK,'
||      'CONSIDER_RESERVATIONS,'
||      'PART_INCLUDE_TYPE,'
||      'DEFAULT_ABC_ASSIGNMENT_GROUP,'
||      'PERIOD_TYPE,'
||      'RESCHED_ASSUMPTION,'
||      'PLAN_DATE_DEFAULT_TYPE,'
||      'INCLUDE_REP_SUPPLY_DAYS,'
||      'INCLUDE_MDS_DAYS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'REPETITIVE_HORIZON1,'
||      'REPETITIVE_HORIZON2,'
||      'REPETITIVE_BUCKET_SIZE1,'
||      'REPETITIVE_BUCKET_SIZE2,'
||      'REPETITIVE_BUCKET_SIZE3,'
||      'REPETITIVE_ANCHOR_DATE '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'DEMAND_TIME_FENCE_FLAG,'
||      'PLANNING_TIME_FENCE_FLAG,'
||      'OPERATION_SCHEDULE_TYPE,'
||      'CONSIDER_WIP,'
||      'CONSIDER_PO,'
||      'SNAPSHOT_LOCK,'
||      'PLAN_SAFETY_STOCK,'
||      'CONSIDER_RESERVATIONS,'
||      'PART_INCLUDE_TYPE,'
||      'DEFAULT_ABC_ASSIGNMENT_GROUP,'
||      'PERIOD_TYPE,'
||      'RESCHED_ASSUMPTION,'
||      'PLAN_DATE_DEFAULT_TYPE,'
||      'INCLUDE_REP_SUPPLY_DAYS,'
||      'INCLUDE_MDS_DAYS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'REPETITIVE_HORIZON1,'
||      'REPETITIVE_HORIZON2,'
||      'REPETITIVE_BUCKET_SIZE1,'
||      'REPETITIVE_BUCKET_SIZE2,'
||      'REPETITIVE_BUCKET_SIZE3,'
||      'REPETITIVE_ANCHOR_DATE '
||'FROM MSC_ST_PARAMETERS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_PARAMETERS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_PARAMETERS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_PARAMETERS;
PROCEDURE COPY_PARTNER_CONTACTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_PARTNER_CONTACTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_PARTNER_CONTACTS ('
||      'NAME,'
||      'DISPLAY_NAME,'
||      'PARTNER_ID,'
||      'PARTNER_SITE_ID,'
||      'PARTNER_TYPE,'
||      'EMAIL,'
||      'FAX,'
||      'ENABLED_FLAG,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'TP_SITE_CODE,'
||      'PARTNER_NAME,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT '
||     ')'
||'SELECT '
||      'NAME,'
||      'DISPLAY_NAME,'
||      'PARTNER_ID,'
||      'PARTNER_SITE_ID,'
||      'PARTNER_TYPE,'
||      'EMAIL,'
||      'FAX,'
||      'ENABLED_FLAG,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'TP_SITE_CODE,'
||      'REPLACE(PARTNER_NAME,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT '
||'FROM MSC_ST_PARTNER_CONTACTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_PARTNER_CONTACTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_PARTNER_CONTACTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_PARTNER_CONTACTS;
PROCEDURE COPY_PERIOD_START_DATES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_PERIOD_START_DATES');
v_sql_stmt:=
'INSERT INTO MSC_ST_PERIOD_START_DATES ('
||      'CALENDAR_CODE,'
||      'EXCEPTION_SET_ID,'
||      'PERIOD_START_DATE,'
||      'PERIOD_SEQUENCE_NUM,'
||      'PERIOD_NAME,'
||      'NEXT_DATE,'
||      'PRIOR_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'EXCEPTION_SET_ID,'
||      'PERIOD_START_DATE,'
||      'PERIOD_SEQUENCE_NUM,'
||      'PERIOD_NAME,'
||      'NEXT_DATE,'
||      'PRIOR_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_PERIOD_START_DATES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_PERIOD_START_DATES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_PERIOD_START_DATES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_PERIOD_START_DATES;
PROCEDURE COPY_PLANNERS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_PLANNERS');
v_sql_stmt:=
'INSERT INTO MSC_ST_PLANNERS ('
||      'PLANNER_CODE,'
||      'ORGANIZATION_ID,'
||      'SR_INSTANCE_ID,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
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
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ELECTRONIC_MAIL_ADDRESS,'
||      'EMPLOYEE_ID,'
||      'CURRENT_EMPLOYEE_FLAG,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'USER_NAME,'
||      'ORGANIZATION_CODE,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||     ')'
||'SELECT '
||      'PLANNER_CODE,'
||      'ORGANIZATION_ID,'
||      ':v_inst_rp_src_id,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
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
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'ELECTRONIC_MAIL_ADDRESS,'
||      'EMPLOYEE_ID,'
||      'CURRENT_EMPLOYEE_FLAG,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'USER_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||'FROM MSC_ST_PLANNERS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_PLANNERS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_PLANNERS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_PLANNERS;
PROCEDURE COPY_PROCESS_EFFECTIVITY IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_PROCESS_EFFECTIVITY');
v_sql_stmt:=
'INSERT INTO MSC_ST_PROCESS_EFFECTIVITY ('
||      'PROCESS_SEQUENCE_ID,'
||      'ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'MINIMUM_QUANTITY,'
||      'MAXIMUM_QUANTITY,'
||      'PREFERENCE,'
||      'ROUTING_SEQUENCE_ID,'
||      'BILL_SEQUENCE_ID,'
||      'TOTAL_PRODUCT_CYCLE_TIME,'
||      'ITEM_PROCESS_COST,'
||      'LINE_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'PRIMARY_LINE_FLAG,'
||      'PRODUCTION_LINE_RATE,'
||      'LOAD_DISTRIBUTION_PRIORITY '
||     ')'
||'SELECT '
||      'PROCESS_SEQUENCE_ID,'
||      'ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'MINIMUM_QUANTITY,'
||      'MAXIMUM_QUANTITY,'
||      'PREFERENCE,'
||      'ROUTING_SEQUENCE_ID,'
||      'BILL_SEQUENCE_ID,'
||      'TOTAL_PRODUCT_CYCLE_TIME,'
||      'ITEM_PROCESS_COST,'
||      'LINE_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'PRIMARY_LINE_FLAG,'
||      'PRODUCTION_LINE_RATE,'
||      'LOAD_DISTRIBUTION_PRIORITY '
||'FROM MSC_ST_PROCESS_EFFECTIVITY'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_PROCESS_EFFECTIVITY');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_PROCESS_EFFECTIVITY');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_PROCESS_EFFECTIVITY;
PROCEDURE COPY_PROJECTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_PROJECTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_PROJECTS ('
||      'PROJECT_ID,'
||      'ORGANIZATION_ID,'
||      'PLANNING_GROUP,'
||      'COSTING_GROUP_ID,'
||      'WIP_ACCT_CLASS_CODE,'
||      'SEIBAN_NUMBER_FLAG,'
||      'PROJECT_NAME,'
||      'PROJECT_NUMBER,'
||      'PROJECT_NUMBER_SORT_ORDER,'
||      'PROJECT_DESCRIPTION,'
||      'START_DATE,'
||      'COMPLETION_DATE,'
||      'OPERATING_UNIT,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'MATERIAL_ACCOUNT,'
||      'MANAGER_CONTACT '
||     ')'
||'SELECT '
||      'PROJECT_ID,'
||      'ORGANIZATION_ID,'
||      'PLANNING_GROUP,'
||      'COSTING_GROUP_ID,'
||      'WIP_ACCT_CLASS_CODE,'
||      'SEIBAN_NUMBER_FLAG,'
||      'PROJECT_NAME,'
||      'PROJECT_NUMBER,'
||      'PROJECT_NUMBER_SORT_ORDER,'
||      'PROJECT_DESCRIPTION,'
||      'START_DATE,'
||      'COMPLETION_DATE,'
||      'OPERATING_UNIT,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'MATERIAL_ACCOUNT,'
||      'MANAGER_CONTACT '
||'FROM MSC_ST_PROJECTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_PROJECTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_PROJECTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_PROJECTS;
PROCEDURE COPY_PROJECT_TASKS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_PROJECT_TASKS');
v_sql_stmt:=
'INSERT INTO MSC_ST_PROJECT_TASKS ('
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'ORGANIZATION_ID,'
||      'TASK_NUMBER,'
||      'TASK_NAME,'
||      'DESCRIPTION,'
||      'MANAGER,'
||      'START_DATE,'
||      'END_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'MANAGER_CONTACT,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'PROJECT_NUMBER,'
||      'COSTING_GROUP_ID,'
||      'COSTING_GROUP_CODE,'
||      'SEIBAN_NUMBER_FLAG,'
||      'PROJECT_DESCRIPTION,'
||      'PLANNING_GROUP,'
||      'WIP_ACCT_CLASS_CODE,'
||      'PROJECT_START_DATE,'
||      'PROJECT_COMPLETION_DATE,'
||      'MATERIAL_ACCOUNT,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_PROJECT_ID,'
||      'SOURCE_TASK_ID,'
||      'SOURCE_COSTING_GROUP_ID '
||     ')'
||'SELECT '
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'ORGANIZATION_ID,'
||      'TASK_NUMBER,'
||      'TASK_NAME,'
||      'DESCRIPTION,'
||      'MANAGER,'
||      'START_DATE,'
||      'END_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'MANAGER_CONTACT,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'PROJECT_NUMBER,'
||      'COSTING_GROUP_ID,'
||      'COSTING_GROUP_CODE,'
||      'SEIBAN_NUMBER_FLAG,'
||      'PROJECT_DESCRIPTION,'
||      'PLANNING_GROUP,'
||      'WIP_ACCT_CLASS_CODE,'
||      'PROJECT_START_DATE,'
||      'PROJECT_COMPLETION_DATE,'
||      'MATERIAL_ACCOUNT,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_PROJECT_ID,'
||      'SOURCE_TASK_ID,'
||      'SOURCE_COSTING_GROUP_ID '
||'FROM MSC_ST_PROJECT_TASKS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_PROJECT_TASKS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_PROJECT_TASKS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_PROJECT_TASKS;
PROCEDURE COPY_REGIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_REGIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_REGIONS ('
||      'REGION_ID,'
||      'REGION_TYPE,'
||      'PARENT_REGION_ID,'
||      'COUNTRY_CODE,'
||      'COUNTRY_REGION_CODE,'
||      'STATE_CODE,'
||      'CITY_CODE,'
||      'PORT_FLAG,'
||      'AIRPORT_FLAG,'
||      'ROAD_TERMINAL_FLAG,'
||      'RAIL_TERMINAL_FLAG,'
||      'LONGITUDE,'
||      'TIMEZONE,'
||      'SR_INSTANCE_ID,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'LATITUDE,'
||      'CONTINENT,'
||      'COUNTRY,'
||      'COUNTRY_REGION,'
||      'STATE,'
||      'CITY,'
||      'ZONE,'
||      'ZONE_LEVEL,'
||      'POSTAL_CODE_FROM,'
||      'POSTAL_CODE_TO,'
||      'ALTERNATE_NAME,'
||      'COUNTY,'
||      'ZONE_USAGE,'
||      'SR_INSTANCE_CODE,'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'MESSAGE_ID,'
||      'COMPANY_NAME '
||     ')'
||'SELECT '
||      'REGION_ID,'
||      'REGION_TYPE,'
||      'PARENT_REGION_ID,'
||      'COUNTRY_CODE,'
||      'COUNTRY_REGION_CODE,'
||      'STATE_CODE,'
||      'CITY_CODE,'
||      'PORT_FLAG,'
||      'AIRPORT_FLAG,'
||      'ROAD_TERMINAL_FLAG,'
||      'RAIL_TERMINAL_FLAG,'
||      'LONGITUDE,'
||      'TIMEZONE,'
||      ':v_inst_rp_src_id,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'LATITUDE,'
||      'CONTINENT,'
||      'COUNTRY,'
||      'COUNTRY_REGION,'
||      'STATE,'
||      'CITY,'
||      'ZONE,'
||      'ZONE_LEVEL,'
||      'POSTAL_CODE_FROM,'
||      'POSTAL_CODE_TO,'
||      'ALTERNATE_NAME,'
||      'COUNTY,'
||      'ZONE_USAGE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'MESSAGE_ID,'
||      'COMPANY_NAME '
||'FROM MSC_ST_REGIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_REGIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_REGIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;
END COPY_REGIONS;
PROCEDURE COPY_REGION_LOCATIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_REGION_LOCATIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_REGION_LOCATIONS ('
||      'REGION_ID,'
||      'LOCATION_ID,'
||      'LOCATION_SOURCE,'
||      'REGION_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'PARENT_REGION_FLAG,'
||      'EXCEPTION_TYPE,'
||      'SR_INSTANCE_ID,'
||      'SR_INSTANCE_CODE,'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'MESSAGE_ID,'
||      'COMPANY_NAME,'
||      'LOCATION_CODE,'
||      'COUNTRY,'
||      'COUNTRY_CODE,'
||      'STATE,'
||      'STATE_CODE,'
||      'CITY,'
||      'CITY_CODE,'
||      'POSTAL_CODE_FROM,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'POSTAL_CODE_TO '
||     ')'
||'SELECT '
||      'REGION_ID,'
||      'LOCATION_ID,'
||      'LOCATION_SOURCE,'
||      'REGION_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'PARENT_REGION_FLAG,'
||      'EXCEPTION_TYPE,'
||      ':v_inst_rp_src_id,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'MESSAGE_ID,'
||      'COMPANY_NAME,'
||      'LOCATION_CODE,'
||      'COUNTRY,'
||      'COUNTRY_CODE,'
||      'STATE,'
||      'STATE_CODE,'
||      'CITY,'
||      'CITY_CODE,'
||      'POSTAL_CODE_FROM,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'POSTAL_CODE_TO '
||'FROM MSC_ST_REGION_LOCATIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
     				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_REGION_LOCATIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_REGION_LOCATIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_REGION_LOCATIONS;
PROCEDURE COPY_RESERVATIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RESERVATIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_RESERVATIONS ('
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'TRANSACTION_ID,'
||      'PARENT_DEMAND_ID,'
||      'DISPOSITION_ID,'
||      'REQUIREMENT_DATE,'
||      'REVISION,'
||      'RESERVED_QUANTITY,'
||      'DISPOSITION_TYPE,'
||      'SUBINVENTORY,'
||      'RESERVATION_TYPE,'
||      'DEMAND_CLASS,'
||      'AVAILABLE_TO_MRP,'
||      'RESERVATION_FLAG,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'ORGANIZATION_CODE,'
||      'ITEM_NAME,'
||      'SALES_ORDER_NUMBER,'
||      'LINE_NUM,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER '
||     ')'
||'SELECT '
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'TRANSACTION_ID,'
||      'PARENT_DEMAND_ID,'
||      'DISPOSITION_ID,'
||      'REQUIREMENT_DATE,'
||      'REVISION,'
||      'RESERVED_QUANTITY,'
||      'DISPOSITION_TYPE,'
||      'SUBINVENTORY,'
||      'RESERVATION_TYPE,'
||      'DEMAND_CLASS,'
||      'AVAILABLE_TO_MRP,'
||      'RESERVATION_FLAG,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'ITEM_NAME,'
||      'SALES_ORDER_NUMBER,'
||      'LINE_NUM,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER '
||'FROM MSC_ST_RESERVATIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RESERVATIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RESERVATIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RESERVATIONS;
PROCEDURE COPY_RESOURCE_CHANGES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RESOURCE_CHANGES');
v_sql_stmt:=
'INSERT INTO MSC_ST_RESOURCE_CHANGES ('
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'SHIFT_NUM,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'FROM_TIME,'
||      'TO_TIME,'
||      'CAPACITY_CHANGE,'
||      'SIMULATION_SET,'
||      'ACTION_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'ORGANIZATION_CODE,'
||      'SHIFT_NAME,'
||      'SR_INSTANCE_CODE,'
||      'ORGANIZATION_ID,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE '
||     ')'
||'SELECT '
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'SHIFT_NUM,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'FROM_TIME,'
||      'TO_TIME,'
||      'CAPACITY_CHANGE,'
||      'SIMULATION_SET,'
||      'ACTION_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'SHIFT_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'ORGANIZATION_ID,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE '
||'FROM MSC_ST_RESOURCE_CHANGES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RESOURCE_CHANGES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RESOURCE_CHANGES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RESOURCE_CHANGES;
PROCEDURE COPY_RESOURCE_GROUPS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RESOURCE_GROUPS');
v_sql_stmt:=
'INSERT INTO MSC_ST_RESOURCE_GROUPS ('
||      'GROUP_CODE,'
||      'MEANING,'
||      'DESCRIPTION,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'ENABLED_FLAG,'
||      'SR_INSTANCE_ID,'
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
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME '
||     ')'
||'SELECT '
||      'GROUP_CODE,'
||      'MEANING,'
||      'DESCRIPTION,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'ENABLED_FLAG,'
||      ':v_inst_rp_src_id,'
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
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME '
||'FROM MSC_ST_RESOURCE_GROUPS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RESOURCE_GROUPS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RESOURCE_GROUPS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RESOURCE_GROUPS;
PROCEDURE COPY_RESOURCE_REQUIREMENTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RESOURCE_REQUIREMENTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_RESOURCE_REQUIREMENTS ('
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'SUPPLY_ID,'
||      'OPERATION_SEQ_NUM,'
||      'OPERATION_SEQUENCE_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'START_DATE,'
||      'OPERATION_HOURS_REQUIRED,'
||      'HOURS_EXPENDED,'
||      'DEMAND_CLASS,'
||      'BASIS_TYPE,'
||      'ASSIGNED_UNITS,'
||      'END_DATE,'
||      'WIP_JOB_TYPE,'
||      'SCHEDULED_COMPLETION_DATE,'
||      'SCHEDULED_QUANTITY,'
||      'QUANTITY_COMPLETED,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'WIP_ENTITY_ID,'
||      'STD_OP_CODE,'
||      'SUPPLY_TYPE,'
||      'CUMMULATIVE_QAUNTITY,'
||      'MINIMUM_TRANSFER_QUANTITY,'
||      'FIRM_FLAG,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'WIP_ENTITY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'OPERATION_SEQ_CODE,'
||      'RESOURCE_SEQ_CODE,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'ROUTING_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'OPERATION_EFFECTIVITY_DATE,'
||      'ALTERNATE_NUMBER,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'PARENT_SEQ_NUM,'
||      'SETUP_ID,'
||      'SCHEDULE_FLAG,'
||      'QUANTITY_IN_QUEUE,'
||      'QUANTITY_RUNNING,'
||      'QUANTITY_WAITING_TO_MOVE,'
||      'YIELD,'
||      'USAGE_RATE,'
||      'ACTIVITY_GROUP_ID,'
||      'PRINCIPAL_FLAG,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_DEPARTMENT_ID,'
||      'SOURCE_RESOURCE_ID,'
||      'SOURCE_RESOURCE_SEQ_NUM,'
||      'SOURCE_OPERATION_SEQUENCE_ID,'
||      'SOURCE_WIP_ENTITY_ID,'
||      'SOURCE_OPERATION_SEQ_NUM,'
||      'ORIG_RESOURCE_SEQ_NUM,'
||      'ROUTING_SEQUENCE_ID,'
||      'GROUP_SEQUENCE_ID,'
||      'GROUP_SEQUENCE_NUMBER,'
||      'BATCH_NUMBER,'
||      'MAXIMUM_ASSIGNED_UNITS,'
||      'MINIMUM_CAPACITY,'
||      'MAXIMUM_CAPACITY,'
||      'BREAKABLE_ACTIVITY_FLAG,'
||      'STEP_QUANTITY,'
||      'STEP_QUANTITY_UOM,'
||      'UNADJUSTED_RESOURCE_HOURS,'
||      'TOUCH_TIME '
||     ')'
||'SELECT '
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'SUPPLY_ID,'
||      'OPERATION_SEQ_NUM,'
||      'OPERATION_SEQUENCE_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'START_DATE,'
||      'OPERATION_HOURS_REQUIRED,'
||      'HOURS_EXPENDED,'
||      'DEMAND_CLASS,'
||      'BASIS_TYPE,'
||      'ASSIGNED_UNITS,'
||      'END_DATE,'
||      'WIP_JOB_TYPE,'
||      'SCHEDULED_COMPLETION_DATE,'
||      'SCHEDULED_QUANTITY,'
||      'QUANTITY_COMPLETED,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'WIP_ENTITY_ID,'
||      'STD_OP_CODE,'
||      'SUPPLY_TYPE,'
||      'CUMMULATIVE_QAUNTITY,'
||      'MINIMUM_TRANSFER_QUANTITY,'
||      'FIRM_FLAG,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'WIP_ENTITY_NAME,'
||      'ITEM_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'OPERATION_SEQ_CODE,'
||      'RESOURCE_SEQ_CODE,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'ROUTING_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'OPERATION_EFFECTIVITY_DATE,'
||      'ALTERNATE_NUMBER,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'PARENT_SEQ_NUM,'
||      'SETUP_ID,'
||      'SCHEDULE_FLAG,'
||      'QUANTITY_IN_QUEUE,'
||      'QUANTITY_RUNNING,'
||      'QUANTITY_WAITING_TO_MOVE,'
||      'YIELD,'
||      'USAGE_RATE,'
||      'ACTIVITY_GROUP_ID,'
||      'PRINCIPAL_FLAG,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_DEPARTMENT_ID,'
||      'SOURCE_RESOURCE_ID,'
||      'SOURCE_RESOURCE_SEQ_NUM,'
||      'SOURCE_OPERATION_SEQUENCE_ID,'
||      'SOURCE_WIP_ENTITY_ID,'
||      'SOURCE_OPERATION_SEQ_NUM,'
||      'ORIG_RESOURCE_SEQ_NUM,'
||      'ROUTING_SEQUENCE_ID,'
||      'GROUP_SEQUENCE_ID,'
||      'GROUP_SEQUENCE_NUMBER,'
||      'BATCH_NUMBER,'
||      'MAXIMUM_ASSIGNED_UNITS,'
||      'MINIMUM_CAPACITY,'
||      'MAXIMUM_CAPACITY,'
||      'BREAKABLE_ACTIVITY_FLAG,'
||      'STEP_QUANTITY,'
||      'STEP_QUANTITY_UOM,'
||      'UNADJUSTED_RESOURCE_HOURS,'
||      'TOUCH_TIME '
||'FROM MSC_ST_RESOURCE_REQUIREMENTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
     				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RESOURCE_REQUIREMENTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RESOURCE_REQUIREMENTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RESOURCE_REQUIREMENTS;
PROCEDURE COPY_RESOURCE_SHIFTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RESOURCE_SHIFTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_RESOURCE_SHIFTS ('
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'SHIFT_NUM,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'SHIFT_NAME,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'CAPACITY_UNITS '
||     ')'
||'SELECT '
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'SHIFT_NUM,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'SHIFT_NAME,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'CAPACITY_UNITS '
||'FROM MSC_ST_RESOURCE_SHIFTS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RESOURCE_SHIFTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RESOURCE_SHIFTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RESOURCE_SHIFTS;
PROCEDURE COPY_ROUTINGS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ROUTINGS');
v_sql_stmt:=
'INSERT INTO MSC_ST_ROUTINGS ('
||      'ROUTING_SEQUENCE_ID,'
||      'ASSEMBLY_ITEM_ID,'
||      'ROUTING_TYPE,'
||      'ROUTING_COMMENT,'
||      'PRIORITY,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'LINE_ID,'
||      'UOM_CODE,'
||      'CFM_ROUTING_FLAG,'
||      'CTP_FLAG,'
||      'ROUTING_QUANTITY,'
||      'COMPLETION_SUBINVENTORY,'
||      'COMPLETION_LOCATOR_ID,'
||      'COMMON_ROUTING_SEQUENCE_ID,'
||      'MIXED_MODEL_MAP_FLAG,'
||      'TOTAL_PRODUCT_CYCLE_TIME,'
||      'ORGANIZATION_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'FIRST_OP_SEQ_NUM,'
||      'LAST_OP_SEQ_NUM,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'BOM_NAME,'
||      'ROUTING_NAME,'
||      'BILL_SEQUENCE_ID,'
||      'ORGANIZATION_CODE,'
||      'ASSEMBLY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'LINE_CODE,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'FIRST_OPERATION_SEQ_CODE,'
||      'LAST_OPERATION_SEQ_CODE,'
||      'COMMON_ROUTING_NAME,'
||      'ITEM_PROCESS_COST,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_ASSEMBLY_ITEM_ID,'
||      'SOURCE_ROUTING_SEQUENCE_ID,'
||      'SOURCE_TASK_ID,'
||      'SOURCE_PROJECT_ID,'
||      'SOURCE_BILL_SEQUENCE_ID,'
||      'SOURCE_COMMON_ROUTING_SEQ_ID,'
||      'SOURCE_LINE_ID,'
||      'AUTO_STEP_QTY_FLAG '
||     ')'
||'SELECT '
||      'ROUTING_SEQUENCE_ID,'
||      'ASSEMBLY_ITEM_ID,'
||      'ROUTING_TYPE,'
||      'ROUTING_COMMENT,'
||      'PRIORITY,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'LINE_ID,'
||      'UOM_CODE,'
||      'CFM_ROUTING_FLAG,'
||      'CTP_FLAG,'
||      'ROUTING_QUANTITY,'
||      'COMPLETION_SUBINVENTORY,'
||      'COMPLETION_LOCATOR_ID,'
||      'COMMON_ROUTING_SEQUENCE_ID,'
||      'MIXED_MODEL_MAP_FLAG,'
||      'TOTAL_PRODUCT_CYCLE_TIME,'
||      'ORGANIZATION_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'FIRST_OP_SEQ_NUM,'
||      'LAST_OP_SEQ_NUM,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'BOM_NAME,'
||      'ROUTING_NAME,'
||      'BILL_SEQUENCE_ID,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'ASSEMBLY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'LINE_CODE,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'FIRST_OPERATION_SEQ_CODE,'
||      'LAST_OPERATION_SEQ_CODE,'
||      'COMMON_ROUTING_NAME,'
||      'ITEM_PROCESS_COST,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_ASSEMBLY_ITEM_ID,'
||      'SOURCE_ROUTING_SEQUENCE_ID,'
||      'SOURCE_TASK_ID,'
||      'SOURCE_PROJECT_ID,'
||      'SOURCE_BILL_SEQUENCE_ID,'
||      'SOURCE_COMMON_ROUTING_SEQ_ID,'
||      'SOURCE_LINE_ID,'
||      'AUTO_STEP_QTY_FLAG '
||'FROM MSC_ST_ROUTINGS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ROUTINGS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ROUTINGS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_ROUTINGS;
PROCEDURE COPY_ROUTING_OPERATIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ROUTING_OPERATIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_ROUTING_OPERATIONS ('
||      'OPERATION_SEQUENCE_ID,'
||      'ROUTING_SEQUENCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'OPERATION_DESCRIPTION,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'FROM_UNIT_NUMBER,'
||      'TO_UNIT_NUMBER,'
||      'OPTION_DEPENDENT_FLAG,'
||      'OPERATION_TYPE,'
||      'MINIMUM_TRANSFER_QUANTITY,'
||      'YIELD,'
||      'DEPARTMENT_ID,'
||      'DEPARTMENT_CODE,'
||      'OPERATION_LEAD_TIME_PERCENT,'
||      'CUMULATIVE_YIELD,'
||      'REVERSE_CUMULATIVE_YIELD,'
||      'NET_PLANNING_PERCENT,'
||      'TEAR_DOWN_DURATION,'
||      'SETUP_DURATION,'
||      'UOM_CODE,'
||      'STANDARD_OPERATION_CODE,'
||      'ORGANIZATION_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ROUTING_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'ORGANIZATION_CODE,'
||      'ASSEMBLY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'OPERATION_SEQ_CODE,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_OPERATION_SEQUENCE_ID,'
||      'SOURCE_OPERATION_SEQ_NUM,'
||      'SOURCE_DEPARTMENT_ID,'
||      'STEP_QUANTITY,'
||      'STEP_QUANTITY_UOM '
||     ')'
||'SELECT '
||      'OPERATION_SEQUENCE_ID,'
||      'ROUTING_SEQUENCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'OPERATION_DESCRIPTION,'
||      'EFFECTIVITY_DATE,'
||      'DISABLE_DATE,'
||      'FROM_UNIT_NUMBER,'
||      'TO_UNIT_NUMBER,'
||      'OPTION_DEPENDENT_FLAG,'
||      'OPERATION_TYPE,'
||      'MINIMUM_TRANSFER_QUANTITY,'
||      'YIELD,'
||      'DEPARTMENT_ID,'
||      'DEPARTMENT_CODE,'
||      'OPERATION_LEAD_TIME_PERCENT,'
||      'CUMULATIVE_YIELD,'
||      'REVERSE_CUMULATIVE_YIELD,'
||      'NET_PLANNING_PERCENT,'
||      'TEAR_DOWN_DURATION,'
||      'SETUP_DURATION,'
||      'UOM_CODE,'
||      'STANDARD_OPERATION_CODE,'
||      'ORGANIZATION_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ROUTING_NAME,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'ASSEMBLY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'OPERATION_SEQ_CODE,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_OPERATION_SEQUENCE_ID,'
||      'SOURCE_OPERATION_SEQ_NUM,'
||      'SOURCE_DEPARTMENT_ID,'
||      'STEP_QUANTITY,'
||      'STEP_QUANTITY_UOM '
||'FROM MSC_ST_ROUTING_OPERATIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
    				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ROUTING_OPERATIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ROUTING_OPERATIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_ROUTING_OPERATIONS;
PROCEDURE COPY_SAFETY_STOCKS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SAFETY_STOCKS');
v_sql_stmt:=
'INSERT INTO MSC_ST_SAFETY_STOCKS ('
||      'ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'PERIOD_START_DATE,'
||      'SAFETY_STOCK_QUANTITY,'
||      'UPDATED,'
||      'STATUS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'ORGANIZATION_CODE,'
||      'ITEM_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'PERIOD_START_DATE,'
||      'SAFETY_STOCK_QUANTITY,'
||      'UPDATED,'
||      'STATUS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'ITEM_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER '
||'FROM MSC_ST_SAFETY_STOCKS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SAFETY_STOCKS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SAFETY_STOCKS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SAFETY_STOCKS;
PROCEDURE COPY_SALES_ORDERS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SALES_ORDERS');
v_sql_stmt:=
'INSERT INTO MSC_ST_SALES_ORDERS ('
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'DEMAND_ID,'
||      'PRIMARY_UOM_QUANTITY,'
||      'RESERVATION_TYPE,'
||      'RESERVATION_QUANTITY,'
||      'DEMAND_SOURCE_TYPE,'
||      'DEMAND_SOURCE_HEADER_ID,'
||      'COMPLETED_QUANTITY,'
||      'SUBINVENTORY,'
||      'DEMAND_CLASS,'
||      'REQUIREMENT_DATE,'
||      'DEMAND_SOURCE_LINE,'
||      'DEMAND_SOURCE_DELIVERY,'
||      'DEMAND_SOURCE_NAME,'
||      'PARENT_DEMAND_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'SALES_ORDER_NUMBER,'
||      'SALESREP_CONTACT,'
||      'ORDERED_ITEM_ID,'
||      'AVAILABLE_TO_MRP,'
||      'CUSTOMER_ID,'
||      'SHIP_TO_SITE_USE_ID,'
||      'BILL_TO_SITE_USE_ID,'
||      'LINE_NUM,'
||      'TERRITORY_ID,'
||      'UPDATE_SEQ_NUM,'
||      'DEMAND_TYPE,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'END_ITEM_UNIT_NUMBER,'
||      'DEMAND_PRIORITY,'
||      'ATP_REFRESH_NUMBER,'
||      'REQUEST_DATE,'
||      'SELLING_PRICE,'
||      'DEMAND_VISIBLE,'
||      'FORECAST_VISIBLE,'
||      'CTO_FLAG,'
||      'ORIGINAL_SYSTEM_REFERENCE,'
||      'ORIGINAL_SYSTEM_LINE_REFERENCE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORDERED_ITEM_NAME,'
||      'CUSTOMER_NAME,'
||      'SHIP_TO_SITE_CODE,'
||      'BILL_TO_SITE_CODE,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMMENTS,'
||      'ORDER_RELEASE_NUMBER,'
||      'END_ORDER_NUMBER,'
||      'END_ORDER_RELEASE_NUMBER,'
||      'END_ORDER_LINE_NUMBER,'
||      'END_ORDER_TYPE,'
||      'NEW_ORDER_PLACEMENT_DATE,'
||      'ORIGINAL_ITEM_ID,'
||      'PROMISE_DATE,'
||      'ORIGINAL_ITEM_NAME,'
||      'LINK_TO_LINE_ID,'
||      'CUST_PO_NUMBER,'
||      'CUSTOMER_LINE_NUMBER,'
||      'MFG_LEAD_TIME,'
||      'ORDER_DATE_TYPE_CODE,'
||      'LATEST_ACCEPTABLE_DATE,'
||      'SHIPPING_METHOD_CODE,'
||      'SCHEDULE_ARRIVAL_DATE,'
||      'ORG_FIRM_FLAG,'
||      'SHIP_SET_ID,'
||      'ARRIVAL_SET_ID,'
||      'SOURCE_DEMAND_SOURCE_HEADER_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_ORIGINAL_ITEM_ID,'
||      'SOURCE_DEMAND_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_CUSTOMER_ID,'
||      'SOURCE_BILL_TO_SITE_USE_ID,'
||      'SOURCE_SHIP_TO_SITE_USE_ID,'
||      'ATO_LINE_ID,'
||      'SHIP_SET_NAME,'
||      'ARRIVAL_SET_NAME,'
||      'SALESREP_ID,'
||      'INTRANSIT_LEAD_TIME,'
||      'SOURCE_DEMAND_SOURCE_LINE, '
||      'ROW_TYPE '
||     ')'
||'SELECT '
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'DEMAND_ID,'
||      'PRIMARY_UOM_QUANTITY,'
||      'RESERVATION_TYPE,'
||      'RESERVATION_QUANTITY,'
||      'DEMAND_SOURCE_TYPE,'
||      'DEMAND_SOURCE_HEADER_ID,'
||      'COMPLETED_QUANTITY,'
||      'SUBINVENTORY,'
||      'DEMAND_CLASS,'
||      'REQUIREMENT_DATE,'
||      'DEMAND_SOURCE_LINE,'
||      'DEMAND_SOURCE_DELIVERY,'
||      'DEMAND_SOURCE_NAME,'
||      'PARENT_DEMAND_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'SALES_ORDER_NUMBER,'
||      'SALESREP_CONTACT,'
||      'ORDERED_ITEM_ID,'
||      'AVAILABLE_TO_MRP,'
||      'CUSTOMER_ID,'
||      'SHIP_TO_SITE_USE_ID,'
||      'BILL_TO_SITE_USE_ID,'
||      'LINE_NUM,'
||      'TERRITORY_ID,'
||      'UPDATE_SEQ_NUM,'
||      'DEMAND_TYPE,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'END_ITEM_UNIT_NUMBER,'
||      'DEMAND_PRIORITY,'
||      'ATP_REFRESH_NUMBER,'
||      'REQUEST_DATE,'
||      'SELLING_PRICE,'
||      'DEMAND_VISIBLE,'
||      'FORECAST_VISIBLE,'
||      'CTO_FLAG,'
||      'ORIGINAL_SYSTEM_REFERENCE,'
||      'ORIGINAL_SYSTEM_LINE_REFERENCE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORDERED_ITEM_NAME,'
||      'CUSTOMER_NAME,'
||      'SHIP_TO_SITE_CODE,'
||      'BILL_TO_SITE_CODE,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMMENTS,'
||      'ORDER_RELEASE_NUMBER,'
||      'END_ORDER_NUMBER,'
||      'END_ORDER_RELEASE_NUMBER,'
||      'END_ORDER_LINE_NUMBER,'
||      'END_ORDER_TYPE,'
||      'NEW_ORDER_PLACEMENT_DATE,'
||      'ORIGINAL_ITEM_ID,'
||      'PROMISE_DATE,'
||      'ORIGINAL_ITEM_NAME,'
||      'LINK_TO_LINE_ID,'
||      'CUST_PO_NUMBER,'
||      'CUSTOMER_LINE_NUMBER,'
||      'MFG_LEAD_TIME,'
||      'ORDER_DATE_TYPE_CODE,'
||      'LATEST_ACCEPTABLE_DATE,'
||      'SHIPPING_METHOD_CODE,'
||      'SCHEDULE_ARRIVAL_DATE,'
||      'ORG_FIRM_FLAG,'
||      'SHIP_SET_ID,'
||      'ARRIVAL_SET_ID,'
||      'SOURCE_DEMAND_SOURCE_HEADER_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_ORIGINAL_ITEM_ID,'
||      'SOURCE_DEMAND_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_CUSTOMER_ID,'
||      'SOURCE_BILL_TO_SITE_USE_ID,'
||      'SOURCE_SHIP_TO_SITE_USE_ID,'
||      'ATO_LINE_ID,'
||      'SHIP_SET_NAME,'
||      'ARRIVAL_SET_NAME,'
||      'SALESREP_ID,'
||      'INTRANSIT_LEAD_TIME,'
||      'SOURCE_DEMAND_SOURCE_LINE, '
||      'DECODE (RESERVATION_TYPE, '
||      '                       1, DECODE(DEMAND_SOURCE_TYPE, '
||      '                                 100, 4,'
||      '                                 DECODE(AVAILABLE_TO_MRP, '
||      '                                        1, 2,'
||      '                                        3)),'
||      '                       1) '
||' FROM MSC_ST_SALES_ORDERS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SALES_ORDERS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SALES_ORDERS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SALES_ORDERS;
PROCEDURE COPY_SHIFT_DATES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SHIFT_DATES');
v_sql_stmt:=
'INSERT INTO MSC_ST_SHIFT_DATES ('
||      'CALENDAR_CODE,'
||      'EXCEPTION_SET_ID,'
||      'SHIFT_NUM,'
||      'SHIFT_DATE,'
||      'SEQ_NUM,'
||      'NEXT_SEQ_NUM,'
||      'PRIOR_SEQ_NUM,'
||      'NEXT_DATE,'
||      'PRIOR_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'EXCEPTION_SET_ID,'
||      'SHIFT_NUM,'
||      'SHIFT_DATE,'
||      'SEQ_NUM,'
||      'NEXT_SEQ_NUM,'
||      'PRIOR_SEQ_NUM,'
||      'NEXT_DATE,'
||      'PRIOR_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id '
||'FROM MSC_ST_SHIFT_DATES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SHIFT_DATES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SHIFT_DATES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SHIFT_DATES;
PROCEDURE COPY_SHIFT_EXCEPTIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SHIFT_EXCEPTIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_SHIFT_EXCEPTIONS ('
||      'CALENDAR_CODE,'
||      'SHIFT_NUM,'
||      'EXCEPTION_SET_ID,'
||      'EXCEPTION_DATE,'
||      'EXCEPTION_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SHIFT_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'SHIFT_NUM,'
||      'EXCEPTION_SET_ID,'
||      'EXCEPTION_DATE,'
||      'EXCEPTION_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SHIFT_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT '
||'FROM MSC_ST_SHIFT_EXCEPTIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SHIFT_EXCEPTIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SHIFT_EXCEPTIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SHIFT_EXCEPTIONS;
PROCEDURE COPY_SHIFT_TIMES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SHIFT_TIMES');
v_sql_stmt:=
'INSERT INTO MSC_ST_SHIFT_TIMES ('
||      'CALENDAR_CODE,'
||      'SHIFT_NUM,'
||      'FROM_TIME,'
||      'TO_TIME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SHIFT_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'SHIFT_NUM,'
||      'FROM_TIME,'
||      'TO_TIME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      ':v_inst_rp_src_id,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SHIFT_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT '
||'FROM MSC_ST_SHIFT_TIMES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SHIFT_EXCEPTIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SHIFT_EXCEPTIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SHIFT_TIMES;
PROCEDURE COPY_SIMULATION_SETS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SIMULATION_SETS');
v_sql_stmt:=
'INSERT INTO MSC_ST_SIMULATION_SETS ('
||      'ORGANIZATION_ID,'
||      'SIMULATION_SET,'
||      'DESCRIPTION,'
||      'USE_IN_WIP_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'SIMULATION_SET,'
||      'DESCRIPTION,'
||      'USE_IN_WIP_FLAG,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID '
||'FROM MSC_ST_SIMULATION_SETS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SIMULATION_SETS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SIMULATION_SETS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SIMULATION_SETS;
PROCEDURE COPY_SOURCING_HISTORY IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SOURCING_HISTORY');
v_sql_stmt:=
'INSERT INTO MSC_ST_SOURCING_HISTORY ('
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'SR_INSTANCE_ID,'
||      'SOURCING_RULE_ID,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_SR_INSTANCE_ID,'
||      'SUPPLIER_ID,'
||      'SUPPLIER_SITE_ID,'
||      'HISTORICAL_ALLOCATION,'
||      'REFRESH_NUMBER,'
||      'LAST_CALCULATED_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      ':v_inst_rp_src_id,'
||      'SOURCING_RULE_ID,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_SR_INSTANCE_ID,'
||      'SUPPLIER_ID,'
||      'SUPPLIER_SITE_ID,'
||      'HISTORICAL_ALLOCATION,'
||      'REFRESH_NUMBER,'
||      'LAST_CALCULATED_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_SOURCING_HISTORY'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SOURCING_HISTORY');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SOURCING_HISTORY');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SOURCING_HISTORY;
PROCEDURE COPY_SOURCING_RULES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SOURCING_RULES');
v_sql_stmt:=
'INSERT INTO MSC_ST_SOURCING_RULES ('
||      'SOURCING_RULE_ID,'
||      'SR_SOURCING_RULE_ID,'
||      'SOURCING_RULE_NAME,'
||      'ORGANIZATION_ID,'
||      'DESCRIPTION,'
||      'STATUS,'
||      'SOURCING_RULE_TYPE,'
||      'PLANNING_ACTIVE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'SOURCING_RULE_ID,'
||      'SR_SOURCING_RULE_ID,'
||      'SOURCING_RULE_NAME,'
||      'ORGANIZATION_ID,'
||      'DESCRIPTION,'
||      'STATUS,'
||      'SOURCING_RULE_TYPE,'
||      'PLANNING_ACTIVE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID '
||'FROM MSC_ST_SOURCING_RULES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SOURCING_RULES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SOURCING_RULES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SOURCING_RULES;
PROCEDURE COPY_SR_ASSIGNMENTS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SR_ASSIGNMENTS');
v_sql_stmt:=
'INSERT INTO MSC_ST_SR_ASSIGNMENTS ('
||      'ASSIGNMENT_ID,'
||      'SR_ASSIGNMENT_ID,'
||      'ASSIGNMENT_SET_ID,'
||      'ASSIGNMENT_TYPE,'
||      'SOURCING_RULE_ID,'
||      'SOURCING_RULE_TYPE,'
||      'INVENTORY_ITEM_ID,'
||      'PARTNER_ID,'
||      'SHIP_TO_SITE_ID,'
||      'CUSTOMER_NAME,'
||      'SITE_USE_CODE,'
||      'LOCATION,'
||      'ORGANIZATION_ID,'
||      'CATEGORY_ID,'
||      'CATEGORY_NAME,'
||      'CATEGORY_SET_IDENTIFIER,'
||      'CATEGORY_SET_NAME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'SR_ASSIGNMENT_INSTANCE_ID,'
||      'REGION_ID '
||     ')'
||'SELECT '
||      'ASSIGNMENT_ID,'
||      'SR_ASSIGNMENT_ID,'
||      'ASSIGNMENT_SET_ID,'
||      'ASSIGNMENT_TYPE,'
||      'SOURCING_RULE_ID,'
||      'SOURCING_RULE_TYPE,'
||      'INVENTORY_ITEM_ID,'
||      'PARTNER_ID,'
||      'SHIP_TO_SITE_ID,'
||      'CUSTOMER_NAME,'
||      'SITE_USE_CODE,'
||      'LOCATION,'
||      'ORGANIZATION_ID,'
||      'CATEGORY_ID,'
||      'CATEGORY_NAME,'
||      'CATEGORY_SET_IDENTIFIER,'
||      'CATEGORY_SET_NAME,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'SR_ASSIGNMENT_INSTANCE_ID,'
||      'REGION_ID '
||'FROM MSC_ST_SR_ASSIGNMENTS'|| v_dblink;

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SR_ASSIGNMENTS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SR_ASSIGNMENTS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SR_ASSIGNMENTS;
PROCEDURE COPY_SR_RECEIPT_ORG IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SR_RECEIPT_ORG');
v_sql_stmt:=
'INSERT INTO MSC_ST_SR_RECEIPT_ORG ('
||      'SR_RECEIPT_ID,'
||      'SR_SR_RECEIPT_ORG,'
||      'SOURCING_RULE_ID,'
||      'RECEIPT_PARTNER_ID,'
||      'RECEIPT_PARTNER_SITE_ID,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'RECEIPT_ORG_INSTANCE_ID '
||     ')'
||'SELECT '
||      'SR_RECEIPT_ID,'
||      'SR_SR_RECEIPT_ORG,'
||      'SOURCING_RULE_ID,'
||      'RECEIPT_PARTNER_ID,'
||      'RECEIPT_PARTNER_SITE_ID,'
||      'EFFECTIVE_DATE,'
||      'DISABLE_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'RECEIPT_ORG_INSTANCE_ID '
||'FROM MSC_ST_SR_RECEIPT_ORG'|| v_dblink;

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SR_RECEIPT_ORG');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SR_RECEIPT_ORG');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SR_RECEIPT_ORG;
PROCEDURE COPY_SR_SOURCE_ORG IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SR_SOURCE_ORG');
v_sql_stmt:=
'INSERT INTO MSC_ST_SR_SOURCE_ORG ('
||      'SR_SOURCE_ID,'
||      'SR_SR_SOURCE_ID,'
||      'SR_RECEIPT_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_PARTNER_ID,'
||      'SOURCE_PARTNER_SITE_ID,'
||      'SECONDARY_INVENTORY,'
||      'SOURCE_TYPE,'
||      'ALLOCATION_PERCENT,'
||      'RANK,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'SHIP_METHOD,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'SOURCE_ORG_INSTANCE_ID '
||     ')'
||'SELECT '
||      'SR_SOURCE_ID,'
||      'SR_SR_SOURCE_ID,'
||      'SR_RECEIPT_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_PARTNER_ID,'
||      'SOURCE_PARTNER_SITE_ID,'
||      'SECONDARY_INVENTORY,'
||      'SOURCE_TYPE,'
||      'ALLOCATION_PERCENT,'
||      'RANK,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'SHIP_METHOD,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'SOURCE_ORG_INSTANCE_ID '
||'FROM MSC_ST_SR_SOURCE_ORG'|| v_dblink;

EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SR_SOURCE_ORG');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SR_SOURCE_ORG');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SR_SOURCE_ORG;
PROCEDURE COPY_SUB_INVENTORIES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SUB_INVENTORIES');
v_sql_stmt:=
'INSERT INTO MSC_ST_SUB_INVENTORIES ('
||      'ORGANIZATION_ID,'
||      'SUB_INVENTORY_CODE,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
||      'NETTING_TYPE,'
||      'DEMAND_CLASS,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'INVENTORY_ATP_CODE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'SUB_INVENTORY_CODE,'
||      'DESCRIPTION,'
||      'DISABLE_DATE,'
||      'NETTING_TYPE,'
||      'DEMAND_CLASS,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'INVENTORY_ATP_CODE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT '
||'FROM MSC_ST_SUB_INVENTORIES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
                   v_inst_rp_src_id
				  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SUB_INVENTORIES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SUB_INVENTORIES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;


END COPY_SUB_INVENTORIES;
PROCEDURE COPY_SUPPLIER_CAPACITIES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SUPPLIER_CAPACITIES');
v_sql_stmt:=
'INSERT INTO MSC_ST_SUPPLIER_CAPACITIES ('
||      'SUPPLIER_ID,'
||      'SUPPLIER_SITE_ID,'
||      'ORGANIZATION_ID,'
||      'USING_ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'CAPACITY,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'ITEM_NAME,'
||      'BUCKET_TYPE,'
||      'ROW_STATUS,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||     ')'
||'SELECT '
||      'SUPPLIER_ID,'
||      'SUPPLIER_SITE_ID,'
||      'ORGANIZATION_ID,'
||      'USING_ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'CAPACITY,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'ITEM_NAME,'
||      'BUCKET_TYPE,'
||      'ROW_STATUS,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||'FROM MSC_ST_SUPPLIER_CAPACITIES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                   v_inst_rp_src_id
				  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SUPPLIER_CAPACITIES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SUPPLIER_CAPACITIES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SUPPLIER_CAPACITIES;
PROCEDURE COPY_SUPPLIER_FLEX_FENCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SUPPLIER_FLEX_FENCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_SUPPLIER_FLEX_FENCES ('
||      'SUPPLIER_ID,'
||      'SUPPLIER_SITE_ID,'
||      'ORGANIZATION_ID,'
||      'USING_ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'FENCE_DAYS,'
||      'TOLERANCE_PERCENTAGE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||     ')'
||'SELECT '
||      'SUPPLIER_ID,'
||      'SUPPLIER_SITE_ID,'
||      'ORGANIZATION_ID,'
||      'USING_ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'FENCE_DAYS,'
||      'TOLERANCE_PERCENTAGE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||'FROM MSC_ST_SUPPLIER_FLEX_FENCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SUPPLIER_FLEX_FENCES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SUPPLIER_FLEX_FENCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SUPPLIER_FLEX_FENCES;
PROCEDURE COPY_SUPPLIES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SUPPLIES');
v_sql_stmt:=
'INSERT INTO MSC_ST_SUPPLIES ('
||      'PLAN_ID,'
||      'TRANSACTION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'SCHEDULE_DESIGNATOR_ID,'
||      'SOURCE_SCHEDULE_NAME,'
||      'REVISION,'
||      'UNIT_NUMBER,'
||      'NEW_SCHEDULE_DATE,'
||      'OLD_SCHEDULE_DATE,'
||      'NEW_WIP_START_DATE,'
||      'OLD_WIP_START_DATE,'
||      'FIRST_UNIT_COMPLETION_DATE,'
||      'LAST_UNIT_COMPLETION_DATE,'
||      'FIRST_UNIT_START_DATE,'
||      'LAST_UNIT_START_DATE,'
||      'DISPOSITION_ID,'
||      'DISPOSITION_STATUS_TYPE,'
||      'ORDER_TYPE,'
||      'SUPPLIER_ID,'
||      'NEW_ORDER_QUANTITY,'
||      'OLD_ORDER_QUANTITY,'
||      'NEW_ORDER_PLACEMENT_DATE,'
||      'OLD_ORDER_PLACEMENT_DATE,'
||      'RESCHEDULE_DAYS,'
||      'RESCHEDULE_FLAG,'
||      'SCHEDULE_COMPRESS_DAYS,'
||      'NEW_PROCESSING_DAYS,'
||      'PURCH_LINE_NUM,'
||      'QUANTITY_IN_PROCESS,'
||      'IMPLEMENTED_QUANTITY,'
||      'FIRM_PLANNED_TYPE,'
||      'FIRM_QUANTITY,'
||      'FIRM_DATE,'
||      'IMPLEMENT_DEMAND_CLASS,'
||      'IMPLEMENT_DATE,'
||      'IMPLEMENT_QUANTITY,'
||      'IMPLEMENT_FIRM,'
||      'IMPLEMENT_WIP_CLASS_CODE,'
||      'IMPLEMENT_JOB_NAME,'
||      'IMPLEMENT_DOCK_DATE,'
||      'IMPLEMENT_STATUS_CODE,'
||      'IMPLEMENT_UOM_CODE,'
||      'IMPLEMENT_LOCATION_ID,'
||      'IMPLEMENT_SOURCE_ORG_ID,'
||      'IMPLEMENT_SUPPLIER_ID,'
||      'IMPLEMENT_SUPPLIER_SITE_ID,'
||      'IMPLEMENT_AS,'
||      'RELEASE_STATUS,'
||      'LOAD_TYPE,'
||      'PROCESS_SEQ_ID,'
||      'SCO_SUPPLY_FLAG,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'OPERATION_SEQ_NUM,'
||      'SOURCE,'
||      'BY_PRODUCT_USING_ASSY_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_SR_INSTANCE_ID,'
||      'SOURCE_SUPPLIER_SITE_ID,'
||      'SOURCE_SUPPLIER_ID,'
||      'SHIP_METHOD,'
||      'WEIGHT_CAPACITY_USED,'
||      'VOLUME_CAPACITY_USED,'
||      'SOURCE_SUPPLY_SCHEDULE_NAME,'
||      'NEW_SHIP_DATE,'
||      'NEW_DOCK_DATE,'
||      'LINE_ID,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'IMPLEMENT_PROJECT_ID,'
||      'IMPLEMENT_TASK_ID,'
||      'IMPLEMENT_SCHEDULE_GROUP_ID,'
||      'IMPLEMENT_BUILD_SEQUENCE,'
||      'IMPLEMENT_ALTERNATE_BOM,'
||      'IMPLEMENT_ALTERNATE_ROUTING,'
||      'IMPLEMENT_UNIT_NUMBER,'
||      'IMPLEMENT_LINE_ID,'
||      'RELEASE_ERRORS,'
||      'NUMBER1,'
||      'SOURCE_ITEM_ID,'
||      'ORDER_NUMBER,'
||      'SCHEDULE_GROUP_ID,'
||      'SCHEDULE_GROUP_NAME,'
||      'BUILD_SEQUENCE,'
||      'WIP_ENTITY_ID,'
||      'WIP_ENTITY_NAME,'
||      'WO_LATENESS_COST,'
||      'IMPLEMENT_PROCESSING_DAYS,'
||      'DELIVERY_PRICE,'
||      'LATE_SUPPLY_DATE,'
||      'LATE_SUPPLY_QTY,'
||      'SUBINVENTORY_CODE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'SCHEDULE_DESIGNATOR,'
||      'VENDOR_ID,'
||      'VENDOR_SITE_ID,'
||      'SUPPLIER_SITE_ID,'
||      'PURCH_ORDER_ID,'
||      'EXPECTED_SCRAP_QTY,'
||      'QTY_SCRAPPED,'
||      'QTY_COMPLETED,'
||      'LOT_NUMBER,'
||      'EXPIRATION_DATE,'
||      'WIP_STATUS_CODE,'
||      'DAILY_RATE,'
||      'LOCATOR_ID,'
||      'SERIAL_NUMBER,'
||      'REFRESH_ID,'
||      'LOCATOR_NAME,'
||      'ONHAND_SOURCE_TYPE,'
||      'SR_MTL_SUPPLY_ID,'
||      'DEMAND_CLASS,'
||      'FROM_ORGANIZATION_ID,'
||      'WIP_SUPPLY_TYPE,'
||      'PO_LINE_ID,'
||      'BILL_SEQUENCE_ID,'
||      'ROUTING_SEQUENCE_ID,'
||      'COPRODUCTS_SUPPLY,'
||      'CFM_ROUTING_FLAG,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_CODE,'
||      'FROM_ORGANIZATION_CODE,'
||      'SUPPLIER_NAME,'
||      'SOURCE_SR_INSTANCE_CODE,'
||      'SOURCE_SUPPLIER_SITE_CODE,'
||      'SOURCE_SUPPLIER_NAME,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'SR_INSTANCE_CODE,'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'SUPPLIER_SITE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'SCHEDULE_LINE_NUM,'
||      'ERROR_TEXT,'
||      'OPERATION_SEQ_CODE,'
||      'BATCH_ID,'
||      'BILL_NAME,'
||      'ROUTING_NAME,'
||      'CURR_OP_SEQ_ID,'
||      'LINE_CODE,'
||      'EFFECTIVITY_DATE,'
||      'SHIP_FROM_PARTY_NAME,'
||      'SHIP_FROM_SITE_CODE,'
||      'END_ORDER_NUMBER,'
||      'END_ORDER_RELEASE_NUMBER,'
||      'END_ORDER_LINE_NUMBER,'
||      'ORDER_RELEASE_NUMBER,'
||      'COMMENTS,'
||      'SHIP_TO_PARTY_NAME,'
||      'SHIP_TO_SITE_CODE,'
||      'PLANNING_PARTNER_SITE_ID,'
||      'PLANNING_TP_TYPE,'
||      'OWNING_PARTNER_SITE_ID,'
||      'OWNING_TP_TYPE,'
||      'VMI_FLAG,'
||      'NON_NETTABLE_QTY,'
||      'ORIGINAL_NEED_BY_DATE,'
||      'ORIGINAL_QUANTITY,'
||      'PROMISED_DATE,'
||      'NEED_BY_DATE,'
||      'ACCEPTANCE_REQUIRED_FLAG,'
||      'END_ORDER_SHIPMENT_NUMBER,'
||      'POSTPROCESSING_LEAD_TIME,'
||      'WIP_START_QUANTITY,'
||      'ORDER_LINE_NUMBER,'
||      'UOM_CODE,'
||      'QUANTITY_PER_ASSEMBLY,'
||      'QUANTITY_ISSUED,'
||      'ACK_REFERENCE_NUMBER,'
||      'JOB_OP_SEQ_NUM,'
||      'JUMP_OP_SEQ_NUM,'
||      'JOB_OP_SEQ_CODE,'
||      'JUMP_OP_SEQ_CODE,'
||      'JUMP_OP_EFFECTIVITY_DATE,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_VENDOR_ID,'
||      'SOURCE_VENDOR_SITE_ID,'
||      'SOURCE_TASK_ID,'
||      'SOURCE_PROJECT_ID,'
||      'SOURCE_FROM_ORGANIZATION_ID,'
||      'SOURCE_SR_MTL_SUPPLY_ID,'
||      'SOURCE_DISPOSITION_ID,'
||      'SOURCE_BILL_SEQUENCE_ID,'
||      'SOURCE_ROUTING_SEQUENCE_ID,'
||      'SOURCE_SCHEDULE_GROUP_ID,'
||      'SOURCE_WIP_ENTITY_ID,'
||      'PO_LINE_LOCATION_ID,'
||      'PO_DISTRIBUTION_ID,'
||      'REQUESTED_START_DATE,'
||      'REQUESTED_COMPLETION_DATE,'
||      'SCHEDULE_PRIORITY,'
||      'SCHEDULE_ORIGINATION_TYPE '
||     ')'
||'SELECT '
||      'PLAN_ID,'
||      'TRANSACTION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'ORGANIZATION_ID,'
||      'SCHEDULE_DESIGNATOR_ID,'
||      'SOURCE_SCHEDULE_NAME,'
||      'REVISION,'
||      'UNIT_NUMBER,'
||      'NEW_SCHEDULE_DATE,'
||      'OLD_SCHEDULE_DATE,'
||      'NEW_WIP_START_DATE,'
||      'OLD_WIP_START_DATE,'
||      'FIRST_UNIT_COMPLETION_DATE,'
||      'LAST_UNIT_COMPLETION_DATE,'
||      'FIRST_UNIT_START_DATE,'
||      'LAST_UNIT_START_DATE,'
||      'DISPOSITION_ID,'
||      'DISPOSITION_STATUS_TYPE,'
||      'ORDER_TYPE,'
||      'SUPPLIER_ID,'
||      'NEW_ORDER_QUANTITY,'
||      'OLD_ORDER_QUANTITY,'
||      'NEW_ORDER_PLACEMENT_DATE,'
||      'OLD_ORDER_PLACEMENT_DATE,'
||      'RESCHEDULE_DAYS,'
||      'RESCHEDULE_FLAG,'
||      'SCHEDULE_COMPRESS_DAYS,'
||      'NEW_PROCESSING_DAYS,'
||      'PURCH_LINE_NUM,'
||      'QUANTITY_IN_PROCESS,'
||      'IMPLEMENTED_QUANTITY,'
||      'FIRM_PLANNED_TYPE,'
||      'FIRM_QUANTITY,'
||      'FIRM_DATE,'
||      'IMPLEMENT_DEMAND_CLASS,'
||      'IMPLEMENT_DATE,'
||      'IMPLEMENT_QUANTITY,'
||      'IMPLEMENT_FIRM,'
||      'IMPLEMENT_WIP_CLASS_CODE,'
||      'IMPLEMENT_JOB_NAME,'
||      'IMPLEMENT_DOCK_DATE,'
||      'IMPLEMENT_STATUS_CODE,'
||      'IMPLEMENT_UOM_CODE,'
||      'IMPLEMENT_LOCATION_ID,'
||      'IMPLEMENT_SOURCE_ORG_ID,'
||      'IMPLEMENT_SUPPLIER_ID,'
||      'IMPLEMENT_SUPPLIER_SITE_ID,'
||      'IMPLEMENT_AS,'
||      'RELEASE_STATUS,'
||      'LOAD_TYPE,'
||      'PROCESS_SEQ_ID,'
||      'SCO_SUPPLY_FLAG,'
||      'ALTERNATE_BOM_DESIGNATOR,'
||      'ALTERNATE_ROUTING_DESIGNATOR,'
||      'OPERATION_SEQ_NUM,'
||      'SOURCE,'
||      'BY_PRODUCT_USING_ASSY_ID,'
||      'SOURCE_ORGANIZATION_ID,'
||      'SOURCE_SR_INSTANCE_ID,'
||      'SOURCE_SUPPLIER_SITE_ID,'
||      'SOURCE_SUPPLIER_ID,'
||      'SHIP_METHOD,'
||      'WEIGHT_CAPACITY_USED,'
||      'VOLUME_CAPACITY_USED,'
||      'SOURCE_SUPPLY_SCHEDULE_NAME,'
||      'NEW_SHIP_DATE,'
||      'NEW_DOCK_DATE,'
||      'LINE_ID,'
||      'PROJECT_ID,'
||      'TASK_ID,'
||      'PLANNING_GROUP,'
||      'IMPLEMENT_PROJECT_ID,'
||      'IMPLEMENT_TASK_ID,'
||      'IMPLEMENT_SCHEDULE_GROUP_ID,'
||      'IMPLEMENT_BUILD_SEQUENCE,'
||      'IMPLEMENT_ALTERNATE_BOM,'
||      'IMPLEMENT_ALTERNATE_ROUTING,'
||      'IMPLEMENT_UNIT_NUMBER,'
||      'IMPLEMENT_LINE_ID,'
||      'RELEASE_ERRORS,'
||      'NUMBER1,'
||      'SOURCE_ITEM_ID,'
||      'ORDER_NUMBER,'
||      'SCHEDULE_GROUP_ID,'
||      'SCHEDULE_GROUP_NAME,'
||      'BUILD_SEQUENCE,'
||      'WIP_ENTITY_ID,'
||      'WIP_ENTITY_NAME,'
||      'WO_LATENESS_COST,'
||      'IMPLEMENT_PROCESSING_DAYS,'
||      'DELIVERY_PRICE,'
||      'LATE_SUPPLY_DATE,'
||      'LATE_SUPPLY_QTY,'
||      'SUBINVENTORY_CODE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'SCHEDULE_DESIGNATOR,'
||      'VENDOR_ID,'
||      'VENDOR_SITE_ID,'
||      'SUPPLIER_SITE_ID,'
||      'PURCH_ORDER_ID,'
||      'EXPECTED_SCRAP_QTY,'
||      'QTY_SCRAPPED,'
||      'QTY_COMPLETED,'
||      'LOT_NUMBER,'
||      'EXPIRATION_DATE,'
||      'WIP_STATUS_CODE,'
||      'DAILY_RATE,'
||      'LOCATOR_ID,'
||      'SERIAL_NUMBER,'
||      'REFRESH_ID,'
||      'LOCATOR_NAME,'
||      'ONHAND_SOURCE_TYPE,'
||      'SR_MTL_SUPPLY_ID,'
||      'DEMAND_CLASS,'
||      'FROM_ORGANIZATION_ID,'
||      'WIP_SUPPLY_TYPE,'
||      'PO_LINE_ID,'
||      'BILL_SEQUENCE_ID,'
||      'ROUTING_SEQUENCE_ID,'
||      'COPRODUCTS_SUPPLY,'
||      'CFM_ROUTING_FLAG,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'FROM_ORGANIZATION_CODE,'
||      'SUPPLIER_NAME,'
||      'REPLACE(SOURCE_SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'SOURCE_SUPPLIER_SITE_CODE,'
||      'SOURCE_SUPPLIER_NAME,'
||      'PROJECT_NUMBER,'
||      'TASK_NUMBER,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'VENDOR_NAME,'
||      'VENDOR_SITE_CODE,'
||      'SUPPLIER_SITE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'SCHEDULE_LINE_NUM,'
||      'ERROR_TEXT,'
||      'OPERATION_SEQ_CODE,'
||      'BATCH_ID,'
||      'BILL_NAME,'
||      'ROUTING_NAME,'
||      'CURR_OP_SEQ_ID,'
||      'LINE_CODE,'
||      'EFFECTIVITY_DATE,'
||      'SHIP_FROM_PARTY_NAME,'
||      'SHIP_FROM_SITE_CODE,'
||      'END_ORDER_NUMBER,'
||      'END_ORDER_RELEASE_NUMBER,'
||      'END_ORDER_LINE_NUMBER,'
||      'ORDER_RELEASE_NUMBER,'
||      'COMMENTS,'
||      'SHIP_TO_PARTY_NAME,'
||      'SHIP_TO_SITE_CODE,'
||      'PLANNING_PARTNER_SITE_ID,'
||      'PLANNING_TP_TYPE,'
||      'OWNING_PARTNER_SITE_ID,'
||      'OWNING_TP_TYPE,'
||      'VMI_FLAG,'
||      'NON_NETTABLE_QTY,'
||      'ORIGINAL_NEED_BY_DATE,'
||      'ORIGINAL_QUANTITY,'
||      'PROMISED_DATE,'
||      'NEED_BY_DATE,'
||      'ACCEPTANCE_REQUIRED_FLAG,'
||      'END_ORDER_SHIPMENT_NUMBER,'
||      'POSTPROCESSING_LEAD_TIME,'
||      'WIP_START_QUANTITY,'
||      'ORDER_LINE_NUMBER,'
||      'UOM_CODE,'
||      'QUANTITY_PER_ASSEMBLY,'
||      'QUANTITY_ISSUED,'
||      'ACK_REFERENCE_NUMBER,'
||      'JOB_OP_SEQ_NUM,'
||      'JUMP_OP_SEQ_NUM,'
||      'JOB_OP_SEQ_CODE,'
||      'JUMP_OP_SEQ_CODE,'
||      'JUMP_OP_EFFECTIVITY_DATE,'
||      'SOURCE_ORG_ID,'
||      'SOURCE_INVENTORY_ITEM_ID,'
||      'SOURCE_VENDOR_ID,'
||      'SOURCE_VENDOR_SITE_ID,'
||      'SOURCE_TASK_ID,'
||      'SOURCE_PROJECT_ID,'
||      'SOURCE_FROM_ORGANIZATION_ID,'
||      'SOURCE_SR_MTL_SUPPLY_ID,'
||      'SOURCE_DISPOSITION_ID,'
||      'SOURCE_BILL_SEQUENCE_ID,'
||      'SOURCE_ROUTING_SEQUENCE_ID,'
||      'SOURCE_SCHEDULE_GROUP_ID,'
||      'SOURCE_WIP_ENTITY_ID,'
||      'PO_LINE_LOCATION_ID,'
||      'PO_DISTRIBUTION_ID,'
||      'REQUESTED_START_DATE,'
||      'REQUESTED_COMPLETION_DATE,'
||      'SCHEDULE_PRIORITY,'
||      'SCHEDULE_ORIGINATION_TYPE '
||'FROM MSC_ST_SUPPLIES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                   v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SUPPLIES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SUPPLIES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SUPPLIES;
PROCEDURE COPY_SYSTEM_ITEMS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SYSTEM_ITEMS');
v_sql_stmt:=
'INSERT INTO MSC_ST_SYSTEM_ITEMS ('
||      'ORGANIZATION_ID,'
||      'SR_ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'SR_INVENTORY_ITEM_ID,'
||      'ITEM_NAME,'
||      'LOTS_EXPIRATION,'
||      'LOT_CONTROL_CODE,'
||      'SHRINKAGE_RATE,'
||      'FIXED_DAYS_SUPPLY,'
||      'FIXED_ORDER_QUANTITY,'
||      'FIXED_LOT_MULTIPLIER,'
||      'MINIMUM_ORDER_QUANTITY,'
||      'MAXIMUM_ORDER_QUANTITY,'
||      'ROUNDING_CONTROL_TYPE,'
||      'PLANNING_TIME_FENCE_DAYS,'
||      'DEMAND_TIME_FENCE_DAYS,'
||      'RELEASE_TIME_FENCE_CODE,'
||      'RELEASE_TIME_FENCE_DAYS,'
||      'DESCRIPTION,'
||      'IN_SOURCE_PLAN,'
||      'REVISION,'
||      'SR_CATEGORY_ID,'
||      'CATEGORY_NAME,'
||      'ABC_CLASS_ID,'
||      'ABC_CLASS_NAME,'
||      'MRP_PLANNING_CODE,'
||      'FIXED_LEAD_TIME,'
||      'VARIABLE_LEAD_TIME,'
||      'PREPROCESSING_LEAD_TIME,'
||      'POSTPROCESSING_LEAD_TIME,'
||      'FULL_LEAD_TIME,'
||      'CUMULATIVE_TOTAL_LEAD_TIME,'
||      'CUM_MANUFACTURING_LEAD_TIME,'
||      'UOM_CODE,'
||      'UNIT_WEIGHT,'
||      'UNIT_VOLUME,'
||      'WEIGHT_UOM,'
||      'VOLUME_UOM,'
||      'PRODUCT_FAMILY_ID,'
||      'ATP_RULE_ID,'
||      'MRP_CALCULATE_ATP_FLAG,'
||      'ATP_COMPONENTS_FLAG,'
||      'BUILT_IN_WIP_FLAG,'
||      'PURCHASING_ENABLED_FLAG,'
||      'PLANNING_MAKE_BUY_CODE,'
||      'REPETITIVE_TYPE,'
||      'STANDARD_COST,'
||      'CARRYING_COST,'
||      'ORDER_COST,'
||      'DMD_LATENESS_COST,'
||      'SS_PENALTY_COST,'
||      'SUPPLIER_CAP_OVERUTIL_COST,'
||      'LIST_PRICE,'
||      'AVERAGE_DISCOUNT,'
||      'END_ASSEMBLY_PEGGING_FLAG,'
||      'END_ASSEMBLY_PEGGING,'
||      'FULL_PEGGING,'
||      'ENGINEERING_ITEM_FLAG,'
||      'WIP_SUPPLY_TYPE,'
||      'MRP_SAFETY_STOCK_CODE,'
||      'MRP_SAFETY_STOCK_PERCENT,'
||      'SAFETY_STOCK_BUCKET_DAYS,'
||      'INVENTORY_USE_UP_DATE,'
||      'BUYER_NAME,'
||      'PLANNER_CODE,'
||      'PLANNING_EXCEPTION_SET,'
||      'EXCESS_QUANTITY,'
||      'EXCEPTION_SHORTAGE_DAYS,'
||      'EXCEPTION_EXCESS_DAYS,'
||      'EXCEPTION_OVERPROMISED_DAYS,'
||      'REPETITIVE_VARIANCE_DAYS,'
||      'BASE_ITEM_ID,'
||      'BOM_ITEM_TYPE,'
||      'ATO_FORECAST_CONTROL,'
||      'ORGANIZATION_CODE,'
||      'EFFECTIVITY_CONTROL,'
||      'ACCEPTABLE_EARLY_DELIVERY,'
||      'INVENTORY_PLANNING_CODE,'
||      'INVENTORY_TYPE,'
||      'ACCEPTABLE_RATE_INCREASE,'
||      'ACCEPTABLE_RATE_DECREASE,'
||      'PRIMARY_SUPPLIER_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'ATP_FLAG,'
||      'INVENTORY_ITEM_FLAG,'
||      'REVISION_QTY_CONTROL_CODE,'
||      'EXPENSE_ACCOUNT,'
||      'INVENTORY_ASSET_FLAG,'
||      'BUYER_ID,'
||      'MATERIAL_COST,'
||      'RESOURCE_COST,'
||      'SOURCE_ORG_ID,'
||      'PICK_COMPONENTS_FLAG,'
||      'ALLOWED_UNITS_LOOKUP_CODE,'
||      'SERVICE_LEVEL,'
||      'REPLENISH_TO_ORDER_FLAG,'
||      'PIP_FLAG,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'ATP_RULE_CODE,'
||      'BASE_ITEM_NAME,'
||      'PRIMARY_SUPPLIER_NAME,'
||      'SOURCE_ORG_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'MIN_MINMAX_QUANTITY,'
||      'MAX_MINMAX_QUANTITY,'
||      'YIELD_CONV_FACTOR,'
||      'SOURCE_TYPE,'
||      'SUBSTITUTION_WINDOW,'
||      'CREATE_SUPPLY_FLAG,'
||      'SERIAL_NUMBER_CONTROL_CODE,'
||      'CRITICAL_COMPONENT_FLAG,'
||      'REDUCE_MPS,'
||      'SOURCE_SR_INVENTORY_ITEM_ID,'
||      'SOURCE_SOURCE_ORG_ID,'
||      'SOURCE_PRIMARY_SUPPLIER_ID,'
||      'SOURCE_BASE_ITEM_ID,'
||      'SOURCE_ABC_CLASS_ID,'
||      'VMI_MINIMUM_UNITS,'
||      'VMI_MINIMUM_DAYS,'
||      'VMI_MAXIMUM_UNITS,'
||      'VMI_MAXIMUM_DAYS,'
||      'VMI_FIXED_ORDER_QUANTITY,'
||      'SO_AUTHORIZATION_FLAG,'
||      'CONSIGNED_FLAG,'
||      'ASN_AUTOEXPIRE_FLAG,'
||      'VMI_FORECAST_TYPE,'
||      'FORECAST_HORIZON,'
||      'BUDGET_CONSTRAINED,'
||      'DAYS_TGT_INV_SUPPLY,'
||      'DAYS_TGT_INV_WINDOW,'
||      'DAYS_MAX_INV_SUPPLY,'
||      'DAYS_MAX_INV_WINDOW,'
||      'DRP_PLANNED,'
||      'CONTINOUS_TRANSFER,'
||      'CONVERGENCE,'
||      'DIVERGENCE,'
||      'PRODUCT_FAMILY_ITEM_NAME,'
||      'ITEM_CREATION_DATE,'
||      'SHORTAGE_TYPE,'
||      'EXCESS_TYPE,'
||      'PLANNING_TIME_FENCE_CODE,'
||      'PEGGING_DEMAND_WINDOW_DAYS,'
||      'PEGGING_SUPPLY_WINDOW_DAYS '
||     ')'
||'SELECT '
||      'ORGANIZATION_ID,'
||      'SR_ORGANIZATION_ID,'
||      'INVENTORY_ITEM_ID,'
||      'SR_INVENTORY_ITEM_ID,'
||      'ITEM_NAME,'
||      'LOTS_EXPIRATION,'
||      'LOT_CONTROL_CODE,'
||      'SHRINKAGE_RATE,'
||      'FIXED_DAYS_SUPPLY,'
||      'FIXED_ORDER_QUANTITY,'
||      'FIXED_LOT_MULTIPLIER,'
||      'MINIMUM_ORDER_QUANTITY,'
||      'MAXIMUM_ORDER_QUANTITY,'
||      'ROUNDING_CONTROL_TYPE,'
||      'PLANNING_TIME_FENCE_DAYS,'
||      'DEMAND_TIME_FENCE_DAYS,'
||      'RELEASE_TIME_FENCE_CODE,'
||      'RELEASE_TIME_FENCE_DAYS,'
||      'DESCRIPTION,'
||      'IN_SOURCE_PLAN,'
||      'REVISION,'
||      'SR_CATEGORY_ID,'
||      'CATEGORY_NAME,'
||      'ABC_CLASS_ID,'
||      'ABC_CLASS_NAME,'
||      'MRP_PLANNING_CODE,'
||      'FIXED_LEAD_TIME,'
||      'VARIABLE_LEAD_TIME,'
||      'PREPROCESSING_LEAD_TIME,'
||      'POSTPROCESSING_LEAD_TIME,'
||      'FULL_LEAD_TIME,'
||      'CUMULATIVE_TOTAL_LEAD_TIME,'
||      'CUM_MANUFACTURING_LEAD_TIME,'
||      'UOM_CODE,'
||      'UNIT_WEIGHT,'
||      'UNIT_VOLUME,'
||      'WEIGHT_UOM,'
||      'VOLUME_UOM,'
||      'PRODUCT_FAMILY_ID,'
||      'ATP_RULE_ID,'
||      'MRP_CALCULATE_ATP_FLAG,'
||      'ATP_COMPONENTS_FLAG,'
||      'BUILT_IN_WIP_FLAG,'
||      'PURCHASING_ENABLED_FLAG,'
||      'PLANNING_MAKE_BUY_CODE,'
||      'REPETITIVE_TYPE,'
||      'STANDARD_COST,'
||      'CARRYING_COST,'
||      'ORDER_COST,'
||      'DMD_LATENESS_COST,'
||      'SS_PENALTY_COST,'
||      'SUPPLIER_CAP_OVERUTIL_COST,'
||      'LIST_PRICE,'
||      'AVERAGE_DISCOUNT,'
||      'END_ASSEMBLY_PEGGING_FLAG,'
||      'END_ASSEMBLY_PEGGING,'
||      'FULL_PEGGING,'
||      'ENGINEERING_ITEM_FLAG,'
||      'WIP_SUPPLY_TYPE,'
||      'MRP_SAFETY_STOCK_CODE,'
||      'MRP_SAFETY_STOCK_PERCENT,'
||      'SAFETY_STOCK_BUCKET_DAYS,'
||      'INVENTORY_USE_UP_DATE,'
||      'BUYER_NAME,'
||      'PLANNER_CODE,'
||      'PLANNING_EXCEPTION_SET,'
||      'EXCESS_QUANTITY,'
||      'EXCEPTION_SHORTAGE_DAYS,'
||      'EXCEPTION_EXCESS_DAYS,'
||      'EXCEPTION_OVERPROMISED_DAYS,'
||      'REPETITIVE_VARIANCE_DAYS,'
||      'BASE_ITEM_ID,'
||      'BOM_ITEM_TYPE,'
||      'ATO_FORECAST_CONTROL,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'EFFECTIVITY_CONTROL,'
||      'ACCEPTABLE_EARLY_DELIVERY,'
||      'INVENTORY_PLANNING_CODE,'
||      'INVENTORY_TYPE,'
||      'ACCEPTABLE_RATE_INCREASE,'
||      'ACCEPTABLE_RATE_DECREASE,'
||      'PRIMARY_SUPPLIER_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'ATP_FLAG,'
||      'INVENTORY_ITEM_FLAG,'
||      'REVISION_QTY_CONTROL_CODE,'
||      'EXPENSE_ACCOUNT,'
||      'INVENTORY_ASSET_FLAG,'
||      'BUYER_ID,'
||      'MATERIAL_COST,'
||      'RESOURCE_COST,'
||      'SOURCE_ORG_ID,'
||      'PICK_COMPONENTS_FLAG,'
||      'ALLOWED_UNITS_LOOKUP_CODE,'
||      'SERVICE_LEVEL,'
||      'REPLENISH_TO_ORDER_FLAG,'
||      'PIP_FLAG,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'ATP_RULE_CODE,'
||      'BASE_ITEM_NAME,'
||      'PRIMARY_SUPPLIER_NAME,'
||      'SOURCE_ORG_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'MIN_MINMAX_QUANTITY,'
||      'MAX_MINMAX_QUANTITY,'
||      'YIELD_CONV_FACTOR,'
||      'SOURCE_TYPE,'
||      'SUBSTITUTION_WINDOW,'
||      'CREATE_SUPPLY_FLAG,'
||      'SERIAL_NUMBER_CONTROL_CODE,'
||      'CRITICAL_COMPONENT_FLAG,'
||      'REDUCE_MPS,'
||      'SOURCE_SR_INVENTORY_ITEM_ID,'
||      'SOURCE_SOURCE_ORG_ID,'
||      'SOURCE_PRIMARY_SUPPLIER_ID,'
||      'SOURCE_BASE_ITEM_ID,'
||      'SOURCE_ABC_CLASS_ID,'
||      'VMI_MINIMUM_UNITS,'
||      'VMI_MINIMUM_DAYS,'
||      'VMI_MAXIMUM_UNITS,'
||      'VMI_MAXIMUM_DAYS,'
||      'VMI_FIXED_ORDER_QUANTITY,'
||      'SO_AUTHORIZATION_FLAG,'
||      'CONSIGNED_FLAG,'
||      'ASN_AUTOEXPIRE_FLAG,'
||      'VMI_FORECAST_TYPE,'
||      'FORECAST_HORIZON,'
||      'BUDGET_CONSTRAINED,'
||      'DAYS_TGT_INV_SUPPLY,'
||      'DAYS_TGT_INV_WINDOW,'
||      'DAYS_MAX_INV_SUPPLY,'
||      'DAYS_MAX_INV_WINDOW,'
||      'DRP_PLANNED,'
||      'CONTINOUS_TRANSFER,'
||      'CONVERGENCE,'
||      'DIVERGENCE,'
||      'PRODUCT_FAMILY_ITEM_NAME,'
||      'ITEM_CREATION_DATE,'
||      'SHORTAGE_TYPE,'
||      'EXCESS_TYPE,'
||      'PLANNING_TIME_FENCE_CODE,'
||      'PEGGING_DEMAND_WINDOW_DAYS,'
||      'PEGGING_SUPPLY_WINDOW_DAYS '
||'FROM MSC_ST_SYSTEM_ITEMS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SYSTEM_ITEMS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SYSTEM_ITEMS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SYSTEM_ITEMS;
PROCEDURE COPY_TRADING_PARTNERS IS


BEGIN
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_TRADING_PARTNERS');
/*9327355*/
If v_apps_ver = MSC_UTIL.G_APPS120 Then
v_temp_sql1 := 'NULL';
Else
v_temp_sql1 := 'CURRENCY_CODE';
End if;
/*9327355*/

v_sql_stmt:=
'INSERT INTO MSC_ST_TRADING_PARTNERS ('
||      'PARTNER_ID,'
||      'ORGANIZATION_CODE,'
||      'SR_TP_ID,'
||      'DISABLE_DATE,'
||      'STATUS,'
||      'MASTER_ORGANIZATION,'
||      'PARTNER_TYPE,'
||      'PARTNER_NAME,'
||      'PARTNER_NUMBER,'
||      'CALENDAR_CODE,'
||      'CALENDAR_EXCEPTION_SET_ID,'
||      'OPERATING_UNIT,'
||      'MAXIMUM_WEIGHT,'
||      'MAXIMUM_VOLUME,'
||      'WEIGHT_UOM,'
||      'VOLUME_UOM,'
||      'PROJECT_REFERENCE_ENABLED,'
||      'PROJECT_CONTROL_LEVEL,'
||      'DEMAND_LATENESS_COST,'
||      'SUPPLIER_CAP_OVERUTIL_COST,'
||      'RESOURCE_CAP_OVERUTIL_COST,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'MODELED_CUSTOMER_ID,'
||      'MODELED_CUSTOMER_SITE_ID,'
||      'MODELED_SUPPLIER_ID,'
||      'MODELED_SUPPLIER_SITE_ID,'
||      'TRANSPORT_CAP_OVER_UTIL_COST,'
||      'USE_PHANTOM_ROUTINGS,'
||      'INHERIT_PHANTOM_OP_SEQ,'
||      'DEFAULT_ATP_RULE_ID,'
||      'DEFAULT_DEMAND_CLASS,'
||      'MATERIAL_ACCOUNT,'
||      'EXPENSE_ACCOUNT,'
||      'SOURCE_ORG_ID,'
||      'ORGANIZATION_TYPE,'
||      'SERVICE_LEVEL,'
||      'CUSTOMER_CLASS_CODE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'DEFAULT_ATP_RULE_NAME,'
||      'SOURCE_ORG_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'PLANNING_ENABLED_FLAG,'
||      'MODELED_CUSTOMER_NAME,'
||      'MODELED_SUPPLIER_NAME,'
||      'MODELED_CUSTOMER_SITE_CODE,'
||      'MODELED_SUPPLIER_SITE_CODE,'
||      'MASTER_ORGANIZATION_CODE,'
||      'INHERIT_OC_OP_SEQ_NUM,'
||      'AGGREGATE_DEMAND_FLAG,'
||      'SOURCE_SOURCE_ORG_ID,'
||      'SOURCE_SR_TP_ID,'
||      'BUSINESS_GROUP_ID,'
||      'LEGAL_ENTITY,'
||      'SET_OF_BOOKS_ID,'
||      'CHART_OF_ACCOUNTS_ID,'
||      'BUSINESS_GROUP_NAME,'
||      'LEGAL_ENTITY_NAME,'
||      'OPERATING_UNIT_NAME,'
||      'CUSTOMER_TYPE,'
||      'CUST_ACCOUNT_NUMBER,'
||      'CURRENCY_CODE '
||     ')'
||'SELECT '
||      'PARTNER_ID,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'SR_TP_ID,'
||      'DISABLE_DATE,'
||      'STATUS,'
||      'MASTER_ORGANIZATION,'
||      'PARTNER_TYPE,'
||      'REPLACE(PARTNER_NAME,:v_ascp_inst,:v_icode),'
||      'PARTNER_NUMBER,'
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'CALENDAR_EXCEPTION_SET_ID,'
||      'OPERATING_UNIT,'
||      'MAXIMUM_WEIGHT,'
||      'MAXIMUM_VOLUME,'
||      'WEIGHT_UOM,'
||      'VOLUME_UOM,'
||      'PROJECT_REFERENCE_ENABLED,'
||      'PROJECT_CONTROL_LEVEL,'
||      'DEMAND_LATENESS_COST,'
||      'SUPPLIER_CAP_OVERUTIL_COST,'
||      'RESOURCE_CAP_OVERUTIL_COST,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'MODELED_CUSTOMER_ID,'
||      'MODELED_CUSTOMER_SITE_ID,'
||      'MODELED_SUPPLIER_ID,'
||      'MODELED_SUPPLIER_SITE_ID,'
||      'TRANSPORT_CAP_OVER_UTIL_COST,'
||      'USE_PHANTOM_ROUTINGS,'
||      'INHERIT_PHANTOM_OP_SEQ,'
||      'DEFAULT_ATP_RULE_ID,'
||      'DEFAULT_DEMAND_CLASS,'
||      'MATERIAL_ACCOUNT,'
||      'EXPENSE_ACCOUNT,'
||      'SOURCE_ORG_ID,'
||      'ORGANIZATION_TYPE,'
||      'SERVICE_LEVEL,'
||      'CUSTOMER_CLASS_CODE,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'DEFAULT_ATP_RULE_NAME,'
||      'SOURCE_ORG_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'PLANNING_ENABLED_FLAG,'
||      'MODELED_CUSTOMER_NAME,'
||      'MODELED_SUPPLIER_NAME,'
||      'MODELED_CUSTOMER_SITE_CODE,'
||      'MODELED_SUPPLIER_SITE_CODE,'
||      'MASTER_ORGANIZATION_CODE,'
||      'INHERIT_OC_OP_SEQ_NUM,'
||      'AGGREGATE_DEMAND_FLAG,'
||      'SOURCE_SOURCE_ORG_ID,'
||      'SOURCE_SR_TP_ID,'
||      'BUSINESS_GROUP_ID,'
||      'LEGAL_ENTITY,'
||      'SET_OF_BOOKS_ID,'
||      'CHART_OF_ACCOUNTS_ID,'
||      'BUSINESS_GROUP_NAME,'
||      'LEGAL_ENTITY_NAME,'
||      'OPERATING_UNIT_NAME,'
||      'CUSTOMER_TYPE,'
||      'CUST_ACCOUNT_NUMBER,'
||     v_temp_sql1
||' FROM MSC_ST_TRADING_PARTNERS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id)
||' and company_id is NULL';

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'The formed SQL is'||v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_TRADING_PARTNERS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_TRADING_PARTNERS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_TRADING_PARTNERS;
PROCEDURE COPY_TRADING_PARTNER_SITES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_TRADING_PARTNER_SITES');
v_sql_stmt:=
'INSERT INTO MSC_ST_TRADING_PARTNER_SITES ('
||      'PARTNER_ID,'
||      'PARTNER_SITE_ID,'
||      'PARTNER_ADDRESS,'
||      'SR_TP_ID,'
||      'SR_TP_SITE_ID,'
||      'TP_SITE_CODE,'
||      'LOCATION,'
||      'PARTNER_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'LONGITUDE,'
||      'LATITUDE,'
||      'OPERATING_UNIT_NAME,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'PARTNER_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT,'
||      'COUNTRY,'
||      'STATE,'
||      'CITY,'
||      'POSTAL_CODE,'
||      'ORGANIZATION_CODE,'
||      'PARTNER_SITE_NUMBER,'
||      'ADDRESS1,'
||      'ADDRESS2,'
||      'ADDRESS3,'
||      'ADDRESS4,'
||      'PROVINCE,'
||      'COUNTY,'
||      'OPERATING_UNIT,'
||      'LOCATION_ID,'
||      'SHIPPING_CONTROL,'
||      'SOURCE_SR_TP_ID,'
||      'SOURCE_SR_TP_SITE_ID '
||     ')'
||'SELECT '
||      'PARTNER_ID,'
||      'PARTNER_SITE_ID,'
||      'PARTNER_ADDRESS,'
||      'SR_TP_ID,'
||      'SR_TP_SITE_ID,'
||      'TP_SITE_CODE,'
||      'LOCATION,'
||      'PARTNER_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'LONGITUDE,'
||      'LATITUDE,'
||      'OPERATING_UNIT_NAME,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(PARTNER_NAME,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'ERROR_TEXT,'
||      'COUNTRY,'
||      'STATE,'
||      'CITY,'
||      'POSTAL_CODE,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'PARTNER_SITE_NUMBER,'
||      'ADDRESS1,'
||      'ADDRESS2,'
||      'ADDRESS3,'
||      'ADDRESS4,'
||      'PROVINCE,'
||      'COUNTY,'
||      'OPERATING_UNIT,'
||      'LOCATION_ID,'
||      'SHIPPING_CONTROL,'
||      'SOURCE_SR_TP_ID,'
||      'SOURCE_SR_TP_SITE_ID '
||'FROM MSC_ST_TRADING_PARTNER_SITES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);



EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_TRADING_PARTNER_SITES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_TRADING_PARTNER_SITES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_TRADING_PARTNER_SITES;
PROCEDURE COPY_UNITS_OF_MEASURE IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_UNITS_OF_MEASURE');
v_sql_stmt:=
'INSERT INTO MSC_ST_UNITS_OF_MEASURE ('
||      'UNIT_OF_MEASURE,'
||      'UOM_CODE,'
||      'UOM_CLASS,'
||      'BASE_UOM_FLAG,'
||      'DISABLE_DATE,'
||      'DESCRIPTION,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||     ')'
||'SELECT '
||      'UNIT_OF_MEASURE,'
||      'UOM_CODE,'
||      'UOM_CLASS,'
||      'BASE_UOM_FLAG,'
||      'DISABLE_DATE,'
||      'DESCRIPTION,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||'FROM MSC_ST_UNITS_OF_MEASURE'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_UNITS_OF_MEASURE');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_UNITS_OF_MEASURE');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_UNITS_OF_MEASURE;
PROCEDURE COPY_UNIT_NUMBERS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_UNITS_OF_MEASURE');
v_sql_stmt:=
'INSERT INTO MSC_ST_UNIT_NUMBERS ('
||      'UNIT_NUMBER,'
||      'END_ITEM_ID,'
||      'MASTER_ORGANIZATION_ID,'
||      'COMMENTS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID '
||     ')'
||'SELECT '
||      'UNIT_NUMBER,'
||      'END_ITEM_ID,'
||      'MASTER_ORGANIZATION_ID,'
||      'COMMENTS,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID '
||'FROM MSC_ST_UNIT_NUMBERS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_UNIT_NUMBERS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_UNIT_NUMBERS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_UNIT_NUMBERS;
PROCEDURE COPY_UOM_CLASS_CONVERSIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_UOM_CLASS_CONVERSIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_UOM_CLASS_CONVERSIONS ('
||      'INVENTORY_ITEM_ID,'
||      'FROM_UNIT_OF_MEASURE,'
||      'FROM_UOM_CODE,'
||      'FROM_UOM_CLASS,'
||      'TO_UNIT_OF_MEASURE,'
||      'TO_UOM_CODE,'
||      'TO_UOM_CLASS,'
||      'CONVERSION_RATE,'
||      'DISABLE_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_ID,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||     ')'
||'SELECT '
||      'INVENTORY_ITEM_ID,'
||      'FROM_UNIT_OF_MEASURE,'
||      'FROM_UOM_CODE,'
||      'FROM_UOM_CLASS,'
||      'TO_UNIT_OF_MEASURE,'
||      'TO_UOM_CODE,'
||      'TO_UOM_CLASS,'
||      'CONVERSION_RATE,'
||      'DISABLE_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_ID,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||'FROM MSC_ST_UOM_CLASS_CONVERSIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_UOM_CLASS_CONVERSIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_UOM_CLASS_CONVERSIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_UOM_CLASS_CONVERSIONS;
PROCEDURE COPY_UOM_CONVERSIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_UOM_CONVERSIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_UOM_CONVERSIONS ('
||      'UNIT_OF_MEASURE,'
||      'UOM_CODE,'
||      'UOM_CLASS,'
||      'INVENTORY_ITEM_ID,'
||      'CONVERSION_RATE,'
||      'DEFAULT_CONVERSION_FLAG,'
||      'DISABLE_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_ID,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_ID,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||     ')'
||'SELECT '
||      'UNIT_OF_MEASURE,'
||      'UOM_CODE,'
||      'UOM_CLASS,'
||      'INVENTORY_ITEM_ID,'
||      'CONVERSION_RATE,'
||      'DEFAULT_CONVERSION_FLAG,'
||      'DISABLE_DATE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      ':v_inst_rp_src_id,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ITEM_NAME,'
||      'ORGANIZATION_ID,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID '
||'FROM MSC_ST_UOM_CONVERSIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_UOM_CONVERSIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_UOM_CONVERSIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_UOM_CONVERSIONS;
PROCEDURE COPY_WORKDAY_PATTERNS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_WORKDAY_PATTERNS');
v_sql_stmt:=
'INSERT INTO MSC_ST_WORKDAY_PATTERNS ('
||      'CALENDAR_CODE,'
||      'DESCRIPTION,'
||      'SR_INSTANCE_CODE,'
||      'SR_INSTANCE_ID,'
||      'DELETED_FLAG,'
||      'SHIFT_NAME,'
||      'SHIFT_NUM,'
||      'SEQ_NUM,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'DAYS_ON,'
||      'DAYS_OFF,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMPANY_NAME,'
||      'COMPANY_ID '
||     ')'
||'SELECT '
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'DESCRIPTION,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      ':v_inst_rp_src_id,'
||      'DELETED_FLAG,'
||      'SHIFT_NAME,'
||      'SHIFT_NUM,'
||      'SEQ_NUM,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'DAYS_ON,'
||      'DAYS_OFF,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMPANY_NAME,'
||      'COMPANY_ID '
||'FROM MSC_ST_WORKDAY_PATTERNS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                  v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
                  ,v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_WORKDAY_PATTERNS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_WORKDAY_PATTERNS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_WORKDAY_PATTERNS;
PROCEDURE COPY_ZONE_REGIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_ZONE_REGIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_ZONE_REGIONS ('
||      'ZONE_REGION_ID,'
||      'REGION_ID,'
||      'PARENT_REGION_ID,'
||      'PARTY_ID,'
||      'SR_INSTANCE_ID,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_CODE,'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'MESSAGE_ID,'
||      'COMPANY_NAME,'
||      'ZONE,'
||      'REGION_TYPE,'
||      'COUNTRY,'
||      'COUNTRY_CODE,'
||      'STATE,'
||      'STATE_CODE,'
||      'CITY,'
||      'CITY_CODE,'
||      'POSTAL_CODE_FROM,'
||      'POSTAL_CODE_TO '
||     ')'
||'SELECT '
||      'ZONE_REGION_ID,'
||      'REGION_ID,'
||      'PARENT_REGION_ID,'
||      'PARTY_ID,'
||      ':v_inst_rp_src_id,'
||      'CREATED_BY,'
||      'CREATION_DATE,'
||      'LAST_UPDATED_BY,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'DELETED_FLAG,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'MESSAGE_ID,'
||      'COMPANY_NAME,'
||      'ZONE,'
||      'REGION_TYPE,'
||      'COUNTRY,'
||      'COUNTRY_CODE,'
||      'STATE,'
||      'STATE_CODE,'
||      'CITY,'
||      'CITY_CODE,'
||      'POSTAL_CODE_FROM,'
||      'POSTAL_CODE_TO '
||'FROM MSC_ST_ZONE_REGIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_ZONE_REGIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_ZONE_REGIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_ZONE_REGIONS;
PROCEDURE COPY_SR_LOOKUPS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SR_LOOKUPS');
v_sql_stmt:=
'INSERT INTO MSC_ST_SR_LOOKUPS ('
||      'LOOKUP_CODE,'
||      'LOOKUP_TYPE,'
||      'MEANING,'
||      'DESCRIPTION,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'ENABLED_FLAG,'
||      'SR_INSTANCE_ID,'
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
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME '
||     ')'
||'SELECT '
||      'LOOKUP_CODE,'
||      'LOOKUP_TYPE,'
||      'MEANING,'
||      'DESCRIPTION,'
||      'FROM_DATE,'
||      'TO_DATE,'
||      'ENABLED_FLAG,'
||      ':v_inst_rp_src_id,'
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
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'COMPANY_NAME '
||'FROM MSC_ST_SR_LOOKUPS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
				v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SR_LOOKUPS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SR_LOOKUPS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SR_LOOKUPS;
PROCEDURE COPY_DEPT_RES_INSTANCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_DEPT_RES_INSTANCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_DEPT_RES_INSTANCES ('
||      'SR_INSTANCE_ID,'
||      'RES_INSTANCE_ID,'
||      'RESOURCE_ID,'
||      'DEPARTMENT_ID,'
||      'ORGANIZATION_ID,'
||      'SERIAL_NUMBER,'
||      'EQUIPMENT_ITEM_ID,'
||      'EFFECTIVE_START_DATE,'
||      'EFFECTIVE_END_DATE,'
||      'LAST_KNOWN_SETUP,'
||      'LAST_KNOWN_SETUP_CODE,'
||      'ORGAINZATION_CODE,'
||      'RESOURCE_CODE,'
||      'DEPARTMENT_CODE,'
||      'DEPARTMENT_CLASS,'
||      'EQUIPMENT_ITEM_NAME,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ORGANIZATION_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'RES_INSTANCE_ID,'
||      'RESOURCE_ID,'
||      'DEPARTMENT_ID,'
||      'ORGANIZATION_ID,'
||      'SERIAL_NUMBER,'
||      'EQUIPMENT_ITEM_ID,'
||      'EFFECTIVE_START_DATE,'
||      'EFFECTIVE_END_DATE,'
||      'LAST_KNOWN_SETUP,'
||      'LAST_KNOWN_SETUP_CODE,'
||      'ORGAINZATION_CODE,'
||      'RESOURCE_CODE,'
||      'DEPARTMENT_CODE,'
||      'DEPARTMENT_CLASS,'
||      'EQUIPMENT_ITEM_NAME,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_DEPT_RES_INSTANCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_DEPT_RES_INSTANCES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_DEPT_RES_INSTANCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_DEPT_RES_INSTANCES;
PROCEDURE COPY_NET_RES_INST_AVAIL IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_NET_RES_INST_AVAIL');
v_sql_stmt:=
'INSERT INTO MSC_ST_NET_RES_INST_AVAIL ('
||      'SR_INSTANCE_ID,'
||      'RES_INSTANCE_ID,'
||      'RESOURCE_ID,'
||      'DEPARTMENT_ID,'
||      'ORGANIZATION_ID,'
||      'SERIAL_NUMBER,'
||      'EQUIPMENT_ITEM_ID,'
||      'SIMULATION_SET,'
||      'SHIFT_NUM,'
||      'SHIFT_DATE,'
||      'FROM_TIME,'
||      'TO_TIME,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'RES_INSTANCE_ID,'
||      'RESOURCE_ID,'
||      'DEPARTMENT_ID,'
||      'ORGANIZATION_ID,'
||      'SERIAL_NUMBER,'
||      'EQUIPMENT_ITEM_ID,'
||      'SIMULATION_SET,'
||      'SHIFT_NUM,'
||      'SHIFT_DATE,'
||      'FROM_TIME,'
||      'TO_TIME,'
||      'REFRESH_ID,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_NET_RES_INST_AVAIL'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_NET_RES_INST_AVAIL');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_NET_RES_INST_AVAIL');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_NET_RES_INST_AVAIL;
PROCEDURE COPY_JOB_OP_RES_INSTANCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_JOB_OP_RES_INSTANCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_JOB_OP_RES_INSTANCES ('
||      'WIP_ENTITY_ID,'
||      'OPERATION_SEQ_NUM,'
||      'OPERATION_SEQUENCE_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'RESOURCE_ID,'
||      'RES_INSTANCE_ID,'
||      'SERIAL_NUMBER,'
||      'EQUIPMENT_ITEM_ID,'
||      'START_DATE,'
||      'COMPLETION_DATE,'
||      'ORGANIZATION_ID,'
||      'SR_INSTANCE_ID,'
||      'BATCH_NUMBER,'
||      'DELETED_FLAG,'
||      'WIP_ENTITY_NAME,'
||      'OPERATION_SEQ_CODE,'
||      'ORGAINZATION_CODE,'
||      'RESOURCE_CODE,'
||      'RES_INSTANCE_CODE,'
||      'DEPARTMENT_ID,'
||      'PARENT_SEQ_NUM,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      'WIP_ENTITY_ID,'
||      'OPERATION_SEQ_NUM,'
||      'OPERATION_SEQUENCE_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'RESOURCE_ID,'
||      'RES_INSTANCE_ID,'
||      'SERIAL_NUMBER,'
||      'EQUIPMENT_ITEM_ID,'
||      'START_DATE,'
||      'COMPLETION_DATE,'
||      'ORGANIZATION_ID,'
||      ':v_inst_rp_src_id,'
||      'BATCH_NUMBER,'
||      'DELETED_FLAG,'
||      'WIP_ENTITY_NAME,'
||      'OPERATION_SEQ_CODE,'
||      'ORGAINZATION_CODE,'
||      'RESOURCE_CODE,'
||      'REPLACE(RES_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'DEPARTMENT_ID,'
||      'PARENT_SEQ_NUM,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_JOB_OP_RES_INSTANCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_JOB_OP_RES_INSTANCES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_JOB_OP_RES_INSTANCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_JOB_OP_RES_INSTANCES;
PROCEDURE COPY_RESOURCE_INSTANCE_REQS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RESOURCE_INSTANCE_REQS');
v_sql_stmt:=
'INSERT INTO MSC_ST_RESOURCE_INSTANCE_REQS ('
||      'RESOURCE_ID,'
||      'RES_INSTANCE_ID,'
||      'ORGANIZATION_ID,'
||      'DEPARTMENT_ID,'
||      'SUPPLY_ID,'
||      'OPERATION_SEQ_NUM,'
||      'RESOURCE_SEQ_NUM,'
||      'WIP_ENTITY_ID,'
||      'SR_INSTANCE_ID,'
||      'START_DATE,'
||      'END_DATE,'
||      'SERIAL_NUMBER,'
||      'EQUIPMENT_ITEM_ID,'
||      'ORIG_RESOURCE_SEQ_NUM,'
||      'PARENT_ID,'
||      'RESOURCE_INSTANCE_HOURS,'
||      'BATCH_NUMBER,'
||      'PARENT_SEQ_NUM,'
||      'SETUP_SEQUENCE_NUM,'
||      'DELETED_FLAG,'
||      'WIP_ENTITY_NAME,'
||      'OPERATION_SEQ_CODE,'
||      'ORGAINZATION_CODE,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'RES_INSTANCE_CODE,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      'RESOURCE_ID,'
||      'RES_INSTANCE_ID,'
||      'ORGANIZATION_ID,'
||      'DEPARTMENT_ID,'
||      'SUPPLY_ID,'
||      'OPERATION_SEQ_NUM,'
||      'RESOURCE_SEQ_NUM,'
||      'WIP_ENTITY_ID,'
||      ':v_inst_rp_src_id,'
||      'START_DATE,'
||      'END_DATE,'
||      'SERIAL_NUMBER,'
||      'EQUIPMENT_ITEM_ID,'
||      'ORIG_RESOURCE_SEQ_NUM,'
||      'PARENT_ID,'
||      'RESOURCE_INSTANCE_HOURS,'
||      'BATCH_NUMBER,'
||      'PARENT_SEQ_NUM,'
||      'SETUP_SEQUENCE_NUM,'
||      'DELETED_FLAG,'
||      'WIP_ENTITY_NAME,'
||      'OPERATION_SEQ_CODE,'
||      'ORGAINZATION_CODE,'
||      'DEPARTMENT_CODE,'
||      'RESOURCE_CODE,'
||      'REPLACE(RES_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_RESOURCE_INSTANCE_REQS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RESOURCE_INSTANCE_REQS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RESOURCE_INSTANCE_REQS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RESOURCE_INSTANCE_REQS;
PROCEDURE COPY_RESOURCE_SETUPS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RESOURCE_SETUPS');
v_sql_stmt:=
'INSERT INTO MSC_ST_RESOURCE_SETUPS ('
||      'SR_INSTANCE_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'SETUP_ID,'
||      'SETUP_CODE,'
||      'SETUP_DESCRIPTION,'
||      'ORGANIZATION_CODE,'
||      'RESOURCE_CODE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'SETUP_ID,'
||      'SETUP_CODE,'
||      'SETUP_DESCRIPTION,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'RESOURCE_CODE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_RESOURCE_SETUPS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RESOURCE_SETUPS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RESOURCE_SETUPS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RESOURCE_SETUPS;
PROCEDURE COPY_SETUP_TRANSITIONS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_SETUP_TRANSITIONS');
v_sql_stmt:=
'INSERT INTO MSC_ST_SETUP_TRANSITIONS ('
||      'SR_INSTANCE_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'FROM_SETUP_ID,'
||      'TO_SETUP_ID,'
||      'STANDARD_OPERATION_CODE,'
||      'FROM_SETUP_CODE,'
||      'TO_SETUP_CODE,'
||      'TRANSITION_TIME,'
||      'TRANSITION_UOM,'
||      'TRANSITION_PENALTY,'
||      'ORGANIZATION_CODE,'
||      'RESOURCE_CODE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'STANDARD_OPERATION_ID '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'FROM_SETUP_ID,'
||      'TO_SETUP_ID,'
||      'STANDARD_OPERATION_CODE,'
||      'FROM_SETUP_CODE,'
||      'TO_SETUP_CODE,'
||      'TRANSITION_TIME,'
||      'TRANSITION_UOM,'
||      'TRANSITION_PENALTY,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'RESOURCE_CODE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'STANDARD_OPERATION_ID '
||'FROM MSC_ST_SETUP_TRANSITIONS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_SETUP_TRANSITIONS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_SETUP_TRANSITIONS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_SETUP_TRANSITIONS;
PROCEDURE COPY_RES_INSTANCE_CHANGES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RES_INSTANCE_CHANGES');
v_sql_stmt:=
'INSERT INTO MSC_ST_RES_INSTANCE_CHANGES ('
||      'SR_INSTANCE_ID,'
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'RES_INSTANCE_ID,'
||      'SERIAL_NUMBER,'
||      'SHIFT_NUM,'
||      'FROM_DATE,'
||      'FROM_TIME,'
||      'TO_DATE,'
||      'TO_TIME,'
||      'SIMULATION_SET,'
||      'CAPACITY_CHANGE,'
||      'ORGAINZATION_CODE,'
||      'RESOURCE_CODE,'
||      'RES_INSTANCE_CODE,'
||      'DEPARTMENT_CODE,'
||      'ACTION_TYPE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'DEPARTMENT_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'RES_INSTANCE_ID,'
||      'SERIAL_NUMBER,'
||      'SHIFT_NUM,'
||      'FROM_DATE,'
||      'FROM_TIME,'
||      'TO_DATE,'
||      'TO_TIME,'
||      'SIMULATION_SET,'
||      'CAPACITY_CHANGE,'
||      'ORGAINZATION_CODE,'
||      'RESOURCE_CODE,'
||      'REPLACE(RES_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'DEPARTMENT_CODE,'
||      'ACTION_TYPE,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_RES_INSTANCE_CHANGES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
					v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RES_INSTANCE_CHANGES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RES_INSTANCE_CHANGES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RES_INSTANCE_CHANGES;
PROCEDURE COPY_STD_OP_RESOURCES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_STD_OP_RESOURCES');
v_sql_stmt:=
'INSERT INTO MSC_ST_STD_OP_RESOURCES ('
||      'SR_INSTANCE_ID,'
||      'STANDARD_OPERATION_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'DEPARTMENT_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'RESOURCE_USAGE,'
||      'BASIS_TYPE,'
||      'RESOURCE_UNITS,'
||      'SUBSTITUTE_GROUP_NUM,'
||      'UOM_CODE,'
||      'SCHEDULE_FLAG,'
||      'OPERATION_CODE,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'ORGANIZATION_CODE,'
||      'RESOURCE_CODE,'
||      'DEPARTMENT_CODE,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'STANDARD_OPERATION_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'DEPARTMENT_ID,'
||      'RESOURCE_SEQ_NUM,'
||      'RESOURCE_USAGE,'
||      'BASIS_TYPE,'
||      'RESOURCE_UNITS,'
||      'SUBSTITUTE_GROUP_NUM,'
||      'UOM_CODE,'
||      'SCHEDULE_FLAG,'
||      'OPERATION_CODE,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(ORGANIZATION_CODE,:v_ascp_inst,:v_icode),'
||      'RESOURCE_CODE,'
||      'DEPARTMENT_CODE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'DELETED_FLAG,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_STD_OP_RESOURCES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                    v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_STD_OP_RESOURCES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_STD_OP_RESOURCES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_STD_OP_RESOURCES;
PROCEDURE COPY_RESOURCE_CHARGES IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_RESOURCE_CHARGES');
v_sql_stmt:=
'INSERT INTO MSC_ST_RESOURCE_CHARGES ('
||      'SR_INSTANCE_ID,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'DEPARTMENT_ID,'
||      'ROUTING_SEQUENCE_ID,'
||      'WIP_ENTITY_ID,'
||      'OPERATION_SEQUENCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'RESOURCE_SEQ_NUM,'
||      'CHARGE_NUMBER,'
||      'CHARGE_QUANTITY,'
||      'CHARGE_START_DATETIME,'
||      'CHARGE_END_DATETIME,'
||      'ALTERNATE_NUM,'
||      'ORGAINZATION_CODE,'
||      'RESOURCE_CODE,'
||      'OPERATION_SEQ_CODE,'
||      'ROUTING_NAME,'
||      'WIP_ENTITY_NAME,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'RESOURCE_ID,'
||      'ORGANIZATION_ID,'
||      'DEPARTMENT_ID,'
||      'ROUTING_SEQUENCE_ID,'
||      'WIP_ENTITY_ID,'
||      'OPERATION_SEQUENCE_ID,'
||      'OPERATION_SEQ_NUM,'
||      'RESOURCE_SEQ_NUM,'
||      'CHARGE_NUMBER,'
||      'CHARGE_QUANTITY,'
||      'CHARGE_START_DATETIME,'
||      'CHARGE_END_DATETIME,'
||      'ALTERNATE_NUM,'
||      'ORGAINZATION_CODE,'
||      'RESOURCE_CODE,'
||      'OPERATION_SEQ_CODE,'
||      'ROUTING_NAME,'
||      'WIP_ENTITY_NAME,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
||      'COMPANY_ID,'
||      'COMPANY_NAME,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'ERROR_TEXT,'
||      'ST_TRANSACTION_ID,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE '
||'FROM MSC_ST_RESOURCE_CHARGES'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                    v_inst_rp_src_id
                  ,v_ascp_inst,v_icode ;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_RESOURCE_CHARGES');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_RESOURCE_CHARGES');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_RESOURCE_CHARGES;
PROCEDURE COPY_CALENDAR_MONTHS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_CALENDAR_MONTHS');
v_sql_stmt:=
'INSERT INTO MSC_ST_CALENDAR_MONTHS ('
||      'SR_INSTANCE_ID,'
||      'CALENDAR_CODE,'
||      'CALENDAR_TYPE,'
||      'YEAR,'
||      'YEAR_DESCRIPTION,'
||      'YEAR_START_DATE,'
||      'YEAR_END_DATE,'
||      'QUARTER,'
||      'QUARTER_DESCRIPTION,'
||      'QUARTER_START_DATE,'
||      'QUARTER_END_DATE,'
||      'MONTH,'
||      'MONTH_DESCRIPTION,'
||      'MONTH_START_DATE,'
||      'MONTH_END_DATE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'SR_INSTANCE_CODE,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
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
||      'ATTRIBUTE15 '
||     ')'
||'SELECT '
||      ':v_inst_rp_src_id,'
||      'REPLACE(CALENDAR_CODE,:v_ascp_inst,:v_icode),'
||      'CALENDAR_TYPE,'
||      'YEAR,'
||      'YEAR_DESCRIPTION,'
||      'YEAR_START_DATE,'
||      'YEAR_END_DATE,'
||      'QUARTER,'
||      'QUARTER_DESCRIPTION,'
||      'QUARTER_START_DATE,'
||      'QUARTER_END_DATE,'
||      'MONTH,'
||      'MONTH_DESCRIPTION,'
||      'MONTH_START_DATE,'
||      'MONTH_END_DATE,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'ST_TRANSACTION_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ERROR_TEXT,'
||      'MESSAGE_ID,'
||      'DELETED_FLAG,'
||      'REFRESH_ID,'
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
||      'ATTRIBUTE15 '
||'FROM MSC_ST_CALENDAR_MONTHS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                    v_inst_rp_src_id
                  ,v_ascp_inst,v_icode
                  ,v_ascp_inst,v_icode
;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_CALENDAR_MONTHS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_CALENDAR_MONTHS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_CALENDAR_MONTHS;
PROCEDURE COPY_OPEN_PAYBACKS IS

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'COPY_OPEN_PAYBACKS');
v_sql_stmt:=
'INSERT INTO MSC_ST_OPEN_PAYBACKS ('
||      'INVENTORY_ITEM_ID,'
||      'SR_INSTANCE_ID,'
||      'ORGANIZATION_ID,'
||      'SCHEDULED_PAYBACK_DATE,'
||      'QUANTITY,'
||      'LENDING_PROJECT_ID,'
||      'LENDING_TASK_ID,'
||      'BORROW_PROJECT_ID,'
||      'BORROW_TASK_ID,'
||      'PLANNING_GROUP,'
||      'LENDING_PROJ_PLANNING_GROUP,'
||      'END_ITEM_UNIT_NUMBER,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
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
||      'SR_INSTANCE_CODE,'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMMENTS '
||     ')'
||'SELECT '
||      'INVENTORY_ITEM_ID,'
||      ':v_inst_rp_src_id,'
||      'ORGANIZATION_ID,'
||      'SCHEDULED_PAYBACK_DATE,'
||      'QUANTITY,'
||      'LENDING_PROJECT_ID,'
||      'LENDING_TASK_ID,'
||      'BORROW_PROJECT_ID,'
||      'BORROW_TASK_ID,'
||      'PLANNING_GROUP,'
||      'LENDING_PROJ_PLANNING_GROUP,'
||      'END_ITEM_UNIT_NUMBER,'
||      'LAST_UPDATE_DATE,'
||      'LAST_UPDATED_BY,'
||      'CREATION_DATE,'
||      'CREATED_BY,'
||      'LAST_UPDATE_LOGIN,'
||      'REQUEST_ID,'
||      'PROGRAM_APPLICATION_ID,'
||      'PROGRAM_ID,'
||      'PROGRAM_UPDATE_DATE,'
||      'REFRESH_ID,'
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
||      'REPLACE(SR_INSTANCE_CODE,:v_ascp_inst,:v_icode),'
||      'MESSAGE_ID,'
||      'PROCESS_FLAG,'
||      'BATCH_ID,'
||      'DATA_SOURCE_TYPE,'
||      'ST_TRANSACTION_ID,'
||      'ERROR_TEXT,'
||      'COMMENTS '
||'FROM MSC_ST_OPEN_PAYBACKS'|| v_dblink
||' WHERE '
||' sr_instance_id = ' || to_char(v_src_instance_id);


EXECUTE IMMEDIATE v_sql_stmt USING
                    v_inst_rp_src_id
                  ,v_ascp_inst,v_icode ;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQL%ROWCOUNT||' row(s) copied');
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Error copying MSC_ST_OPEN_PAYBACKS');
	  v_retcode := 2;
	  RAISE;
	ELSE
	  IF v_retcode < 2 THEN
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Warning copying MSC_ST_OPEN_PAYBACKS');
	  v_retcode := 1;
	  END IF;
	RETURN;
	END IF;

END COPY_OPEN_PAYBACKS;
/*FUNCTION SUBMIT_COPY_REQUEST(instance_id in NUMBER
							 ,sr_instance_id in NUMBER)
RETURN BOOLEAN
IS
  lv_request_id  NUMBER;
  lv_timeout NUMBER := 180;
BEGIN
  lv_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          'MSC',
                          'MSCCPST',
                          NULL,  -- description
                          NULL,  -- start date
                          FALSE,
                          instance_id,
                          sr_instance_id,
                          lv_timeout,
						  3    --Hardcode value for number of workers
                          );

END SUBMIT_COPY_REQUEST;
*/
END MSC_CL_COPY_STG_TBL;

/
