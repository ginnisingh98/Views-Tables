--------------------------------------------------------
--  DDL for Package Body MSC_CL_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_PULL" AS -- body
/* $Header: MSCCLFAB.pls 120.35.12010000.12 2010/03/31 10:09:31 vsiyer ship $ */



   -- Misc --
   v_sql_stmt                   VARCHAR2(32767);

   -- included for the fix 2351297 --
   v_req_data                   varchar2(10);

   v_item_type_id   NUMBER := MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
   v_item_type_good NUMBER := MSC_UTIL.G_PARTCONDN_GOOD;
   v_item_type_bad  NUMBER := MSC_UTIL.G_PARTCONDN_BAD;

   v_cp_enabled                 NUMBER;


   v_msc_tp_coll_window  NUMBER := MSC_UTIL.v_msc_tp_coll_window;

   v_gmp_routine_name       VARCHAR2(50);
   GMP_ERROR                EXCEPTION;

   NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';

        TSK_RM_ASSIGNMENT_SETS                   NUMBER := 1;
        TSK_RM_ATP_RULES                         NUMBER := 1;
        TSK_RM_BILL_OF_RESOURCES                 NUMBER := 1;
        TSK_RM_BIS_BUSINESS_PLANS                NUMBER := 1;
        TSK_RM_BIS_PERIODS                       NUMBER := 1;
        TSK_RM_BIS_PFMC_MEASURES                 NUMBER := 1;
        TSK_RM_BIS_TARGET_LEVELS                 NUMBER := 1;
        TSK_RM_BIS_TARGETS                       NUMBER := 1;
        TSK_RM_BOM_COMPONENTS                    NUMBER := 1;
        TSK_RM_BOMS                              NUMBER := 1;
        TSK_RM_BOR_REQUIREMENTS                  NUMBER := 1;
        TSK_RM_CAL_WEEK_START_DATES              NUMBER := 1;
        TSK_RM_CAL_YEAR_START_DATES              NUMBER := 1;
        TSK_RM_CALENDAR_DATES                    NUMBER := 1;
        TSK_RM_CALENDAR_SHIFTS                   NUMBER := 1;
        TSK_RM_CALENDAR_ASSIGNMENTS              NUMBER := 1;
        TSK_RM_CATEGORY_SETS                     NUMBER := 1;
        TSK_RM_CARRIER_SERVICES                  NUMBER := 1;
        TSK_RM_COMPONENT_SUBSTITUTES             NUMBER := 1;
        TSK_RM_DEMAND_CLASSES                    NUMBER := 1;
        TSK_RM_DEMANDS                           NUMBER := 3;
        TSK_RM_DEPARTMENT_RESOURCES              NUMBER := 1;
        TSK_RM_DESIGNATORS                       NUMBER := 1;
        TSK_RM_INTERORG_SHIP_METHODS             NUMBER := 1;
        TSK_RM_ITEM_CATEGORIES                   NUMBER := 1;
        TSK_RM_ITEM_SUBSTITUTES                  NUMBER := 1;
        TSK_RM_ITEM_SUPPLIERS                    NUMBER := 1;
        TSK_RM_LOCATION_ASSOCIATIONS             NUMBER := 1;
        TSK_RM_SOURCING_RULES                    NUMBER := 1;
        TSK_RM_OPERATION_COMPONENTS              NUMBER := 1;
        TSK_RM_OPERATION_RESOURCE_SEQS           NUMBER := 1;
        TSK_RM_OPERATION_RESOURCES               NUMBER := 1;
        TSK_RM_PARAMETERS                        NUMBER := 1;
        TSK_RM_PARTNER_CONTACTS                  NUMBER := 2;
        TSK_RM_PERIOD_START_DATES                NUMBER := 1;
        TSK_RM_PLANNERS                          NUMBER := 1;
        TSK_RM_PROCESS_EFFECTIVITY               NUMBER := 1;
        TSK_RM_PROJECT_TASKS                     NUMBER := 1;
        TSK_RM_PROJECTS                          NUMBER := 1;
        TSK_RM_REGIONS                           NUMBER := 1;
        TSK_RM_REGION_SITES                      NUMBER := 1;
        TSK_RM_RESERVATIONS                      NUMBER := 1;
        TSK_RM_RESOURCE_CHANGES                  NUMBER := 1;
        TSK_RM_RESOURCE_GROUPS                   NUMBER := 1;
        TSK_RM_RESOURCE_REQUIREMENTS             NUMBER := 1;
        TSK_RM_RESOURCE_SHIFTS                   NUMBER := 1;
        TSK_RM_ROUTING_OPERATIONS                NUMBER := 1;
        TSK_RM_ROUTINGS                          NUMBER := 1;
        TSK_RM_SAFETY_STOCKS                     NUMBER := 1;
        TSK_RM_SALES_ORDERS                      NUMBER := 1;
        TSK_RM_JOB_OP_NETWORKS                   NUMBER := 1;
        TSK_RM_JOB_OPERATIONS                    NUMBER := 1;
        TSK_RM_JOB_REQUIREMENT_OPS               NUMBER := 1;
        TSK_RM_JOB_OP_RESOURCES                  NUMBER := 1;
        TSK_RM_SHIFT_DATES                       NUMBER := 1;
        TSK_RM_SHIFT_EXCEPTIONS                  NUMBER := 1;
        TSK_RM_SHIFT_TIMES                       NUMBER := 1;
        TSK_RM_SIMULATION_SETS                   NUMBER := 1;
        TSK_RM_SR_ASSIGNMENTS                    NUMBER := 1;
        TSK_RM_SR_RECEIPT_ORG                    NUMBER := 1;
        TSK_RM_SR_SOURCE_ORG                     NUMBER := 1;
        TSK_RM_SUB_INVENTORIES                   NUMBER := 1;
        TSK_RM_SUPPLIER_CAPACITIES               NUMBER := 1;
        TSK_RM_SUPPLIER_FLEX_FENCES              NUMBER := 1;
        TSK_RM_SUPPLIES                          NUMBER := 7; -- 5 changed to 7 .
        TSK_RM_SYSTEM_ITEMS                      NUMBER := 3;
        TSK_RM_TRADING_PARTNER_SITES             NUMBER := 1;
        TSK_RM_TRADING_PARTNERS                  NUMBER := 1;
        TSK_RM_TRIPS                             NUMBER := 1;
        TSK_RM_TRIP_STOPS                        NUMBER := 1;
        TSK_RM_UNIT_NUMBERS                      NUMBER := 1;
        TSK_RM_UNITS_OF_MEASURE                  NUMBER := 1;
        TSK_RM_UOM_CLASS_CONVERSIONS             NUMBER := 1;
        TSK_RM_UOM_CONVERSIONS                   NUMBER := 1;
        TSK_RM_ZONE_REGIONS                      NUMBER := 1;
        /* ds change start */
        TSK_RM_RESOURCE_SETUP                    NUMBER := 1;
        TSK_RM_RESOURCE_INSTANCE                 NUMBER := 1;
        /* ds change end */
        TSK_RM_ABC_CLASSES                       NUMBER := 1;
        TSK_RM_SALES_CHANNEL                     NUMBER := 1;
        TSK_RM_FISCAL_CALENDAR                   NUMBER := 1;
        TSK_RM_INTERNAL_REPAIR                   NUMBER := 1;
        TSK_RM_EXTERNAL_REPAIR                   NUMBER := 1;
        TSK_RM_PAYBACK_DEMAND_SUPPLY             NUMBER := 1;
        TSK_RM_CURRENCY_CONVERSION               NUMBER := 1;
        TSK_RM_DELIVERY_DETAILS                   NUMBER := 1;

/*procedure to return the org string of  Depot org */  -- needs to be changed
PROCEDURE GET_DEPOT_ORG_STRINGS(p_instance_id IN NUMBER)
 IS
lv_in_org_str VARCHAR2(32767):=NULL;
   lv_depot_org_str              VARCHAR2(32767);
   lv_non_depot_org_str          VARCHAR2(32767);   -- For Bug 590379 SRP Changes
   lv_ext_repair_org_str         VARCHAR2(32767);
   lv_ext_repair_sup_id_str       VARCHAR2(32767);
lv_sql_stmt VARCHAR2(32767);
lv_org_type NUMBER;
lv_org_id  NUMBER;
lv_count  NUMBER;
lv_sup_id  NUMBER;
type cur_type is ref cursor;
cur cur_type;
BEGIN
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'GET_DEPOT_ORG_STR value of v_instance_id: '||to_char(p_instance_id));
lv_in_org_str := GET_ORG_STR (p_instance_id,2);

lv_sql_stmt := ' Select organization_id, nvl(organization_type,1)  '
	         ||' From msc_instance_orgs mio '
	         ||' Where	sr_instance_id  = '||p_instance_id|| '  and organization_id '||lv_in_org_str
           ;

lv_count:= 0;
lv_non_depot_org_str := NULL;
lv_depot_org_str := NULL;
lv_ext_repair_org_str := NULL;
lv_ext_repair_sup_id_str := NULL;
--On error, org_str will be populated with -9998
        MSC_UTIL.v_depot_org_str     := '= -9998';
        MSC_UTIL.v_non_depot_org_str := '= -9998';

--lv_depot_org_str  :=' IN (';
--lv_non_depot_org_str :=' IN (';
--MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Opening Cursor ');
open cur for lv_sql_stmt;
--FOR Cur IN lv_sql_stmt
LOOP
fetch cur into lv_org_id,lv_org_type;
exit when cur%notfound;


       IF  lv_org_type = 3 THEN
             IF lv_depot_org_str is NULL THEN
              lv_depot_org_str:=' IN ('|| lv_org_id;
             ELSE
              lv_depot_org_str := lv_depot_org_str||','||lv_org_id;
             END IF;
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_org_id : '||lv_org_id);
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_depot_org_str : '||lv_depot_org_str);
			 ELSE
             IF lv_non_depot_org_str is NULL THEN
              lv_non_depot_org_str:=' IN ('|| lv_org_id;
             ELSE
              lv_non_depot_org_str := lv_non_depot_org_str||','||lv_org_id;
             END IF;

             IF  lv_org_type = 4 THEN
               IF lv_ext_repair_org_str is NULL THEN
                lv_ext_repair_org_str:=' IN ('|| lv_org_id;
               ELSE
                lv_ext_repair_org_str := lv_ext_repair_org_str||','||lv_org_id;
               END IF;
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_org_id : '||lv_org_id);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_ext_repair_org_str : '||lv_ext_repair_org_str);
             END IF;
       END IF;
       Lv_count:= lv_count+1;

END LOOP;
Close cur;


  IF lv_depot_org_str <>'NULL' THEN
         lv_depot_org_str:= lv_depot_org_str|| ')' ; -- Needs to be changed
  ELSE
         lv_depot_org_str:= '= -9999';
  END IF;

  IF lv_non_depot_org_str<>'NULL' THEN
         lv_non_depot_org_str:= lv_non_depot_org_str||')' ;   -- Needs to be changed
  ELSE
         lv_non_depot_org_str:= '= -9999';
  END IF;

  IF lv_ext_repair_org_str <>'NULL' THEN
         lv_ext_repair_org_str:= lv_ext_repair_org_str|| ')' ; -- Needs to be changed
         lv_sql_stmt := 'select mtil.sr_tp_id '
					|| ' from msc_trading_partners mtp, msc_tp_id_lid mtil '
					|| ' where mtp.modeled_supplier_id is not null and '
					|| ' mtp.sr_tp_id '|| lv_ext_repair_org_str || ' and '
				  || ' mtil.tp_id=mtp.modeled_supplier_id and '
				  || ' mtp.sr_instance_id = ' || p_instance_id || ' and '
					|| ' mtp.sr_instance_id = mtil.sr_instance_id and '
					|| ' mtil.partner_type = 1 and '
					|| ' mtp.partner_type = 3';
         open cur for lv_sql_stmt;
				 LOOP
				 fetch cur into lv_sup_id;
				 exit when cur%notfound;

				 IF lv_ext_repair_sup_id_str is NULL THEN
              lv_ext_repair_sup_id_str:=' IN ('|| lv_sup_id;
             ELSE
              lv_ext_repair_sup_id_str := lv_ext_repair_sup_id_str||','||lv_sup_id;
             END IF;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_org_id : '||lv_sup_id);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'lv_ext_repair_sup_id_str : '||lv_ext_repair_sup_id_str);

         END LOOP;
				 Close cur;
  ELSE
         lv_ext_repair_org_str:= '= -9999';
  END IF;

  IF lv_ext_repair_sup_id_str<>'NULL' THEN
         lv_ext_repair_sup_id_str:= lv_ext_repair_sup_id_str||')' ;   -- Needs to be changed
  ELSE
         lv_ext_repair_sup_id_str:= '= -9999';
  END IF;

   MSC_UTIL.v_depot_org_str     := lv_depot_org_str;
   MSC_UTIL.v_non_depot_org_str := lv_non_depot_org_str;
   MSC_UTIL.v_ext_repair_sup_id_str := lv_ext_repair_sup_id_str;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'GET_DEPO_ORG_STR returned  :'||MSC_UTIL.v_depot_org_str);
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'G_NON_DEPOT ORG STRING RETURNED   :'||MSC_UTIL.v_non_depot_org_str);

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'ext_repair_org_str returned  :'||lv_ext_repair_org_str);
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'ext_repair_sup_id_str RETURNED   :'||MSC_UTIL.v_ext_repair_sup_id_str);


EXCEPTION
    WHEN OTHERS THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Error: In GET_DEPOT_ORG_STR ');

END GET_DEPOT_ORG_STRINGS;   -- For Bug 5909379 SRP Changes


   FUNCTION collection_type   ( p_entity_enabled  IN NUMBER,
			     p_refresh_code    IN NUMBER)
   RETURN VARCHAR2 IS
   BEGIN

     IF (p_entity_enabled =1 or p_entity_enabled =3 ) THEN
        IF (p_refresh_code = 2) THEN
	        RETURN 'No Collection';
        ELSIF (p_refresh_code = 3) THEN
        	RETURN 'Incremental Collection';
        ELSIF (p_refresh_code = 4) OR (p_refresh_code = 1) THEN
         	RETURN 'Targeted Collection';
        END IF;
     ELSE
	RETURN 'No Collection';
     END IF;

   RETURN to_char(p_refresh_code);

   EXCEPTION
      WHEN OTHERS THEN
	RETURN to_char(p_refresh_code);
 END collection_type;

   FUNCTION is_monitor_status_running RETURN NUMBER
   IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(1024);

   BEGIN

      IF v_cp_enabled= MSC_UTIL.SYS_NO THEN
         RETURN MSC_UTIL.SYS_YES;
      END IF;

      l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( v_monitor_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

      IF l_call_status=FALSE THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'IS_MONITOR_STATUS_RUNNING');

         FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUNNING');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID',v_monitor_request_id);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         RETURN MSC_UTIL.SYS_NO;
      END IF;

      IF l_dev_phase='RUNNING' THEN
         RETURN MSC_UTIL.SYS_YES;
      ELSE
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'IS_MONITOR_STATUS_RUNNING');

         FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUN');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID', v_monitor_request_id);
         FND_MESSAGE.SET_TOKEN('PHASE',l_dev_phase);
         FND_MESSAGE.SET_TOKEN('STATUS',l_dev_status);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         RETURN MSC_UTIL.SYS_NO;
      END IF;

   END is_monitor_status_running;

   FUNCTION is_request_status_running RETURN NUMBER
   IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(1024);

      l_request_id       NUMBER;

   BEGIN

      IF v_cp_enabled= MSC_UTIL.SYS_NO THEN
         RETURN MSC_UTIL.SYS_YES;
      END IF;

      l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

      IF l_call_status=FALSE THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'IS_REQUEST_STATUS_RUNNING');

         FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUNNING');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         RETURN MSC_UTIL.SYS_NO;
      END IF;

      IF l_dev_phase='RUNNING' THEN
         RETURN MSC_UTIL.SYS_YES;
      ELSE
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'IS_REQUEST_STATUS_RUNNING');

         FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUN');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id);
         FND_MESSAGE.SET_TOKEN('PHASE',l_dev_phase);
         FND_MESSAGE.SET_TOKEN('STATUS',l_dev_status);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         RETURN MSC_UTIL.SYS_NO;
      END IF;

   END is_request_status_running;

   FUNCTION is_worker_status_valid( ps_request_id      IN NumTblTyp)
     RETURN NUMBER
   IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(1024);

      l_request_id       NUMBER;
   BEGIN

      IF v_cp_enabled= MSC_UTIL.SYS_NO THEN
         RETURN MSC_UTIL.SYS_YES;
      END IF;

      FOR lc_i IN 1..(ps_request_id.COUNT-1) LOOP

          l_request_id := ps_request_id(lc_i);

          l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

           IF l_call_status=FALSE THEN
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'IS_WORKER_STATUS_VALID');

              FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUNNING');
              FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

              FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

              RETURN MSC_UTIL.SYS_NO;
           END IF;

           IF l_dev_phase NOT IN ( 'PENDING','RUNNING') THEN
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'IS_WORKER_STATUS_VALID');

              FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUN');
              FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id);
              FND_MESSAGE.SET_TOKEN('PHASE',l_dev_phase);
              FND_MESSAGE.SET_TOKEN('STATUS',l_dev_status);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

              FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

              RETURN MSC_UTIL.SYS_NO;
           END IF;

       END LOOP;

       RETURN MSC_UTIL.SYS_YES;

   END is_worker_status_valid;

/* Added this function to verify that all the workers are completed For bug : 2210970
*/
   FUNCTION all_workers_completed( ps_request_id      IN NumTblTyp)
     RETURN NUMBER
   IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(1024);

      l_request_id       NUMBER;

      req_complete number := 0;
      total_req  number;
   BEGIN
    req_complete := 0;
    total_req := 0;

    IF v_cp_enabled= MSC_UTIL.SYS_NO THEN
         RETURN MSC_UTIL.SYS_YES;
    END IF;

     total_req := ps_request_id.COUNT - 1;
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Total requests = :' ||total_req);

      FOR lc_i IN 1..(ps_request_id.COUNT-1) LOOP

          l_request_id := ps_request_id(lc_i);

          l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Request id = '||l_request_id);

         IF l_dev_phase IN ('COMPLETE') THEN

           req_complete := req_complete + 1;

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ALL_WORKERS_COMPLETED');

           FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUN');
           FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id);
           FND_MESSAGE.SET_TOKEN('PHASE',l_dev_phase);
           FND_MESSAGE.SET_TOKEN('STATUS',l_dev_status);
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

           FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_TOTAL_REQS_COMPLETE');
           FND_MESSAGE.SET_TOKEN('REQUESTS',req_complete);
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

         END IF;

    END LOOP;

          IF total_req = req_complete THEN
             FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_ALL_WORKERS_COMP');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
             RETURN MSC_UTIL.SYS_YES;
          ELSE
             RETURN MSC_UTIL.SYS_NO;
          END IF;

 END all_workers_completed;

   PROCEDURE INITIALIZE_PULL_GLOBALS( pINSTANCE_ID       IN NUMBER)
   IS
   BEGIN

     /* initialize the database pipe name */
      v_pipe_task_que := 'MSC_CL_PULL_TQ'||TO_CHAR(pINSTANCE_ID);
      v_pipe_wm       := 'MSC_CL_PULL_WM'||TO_CHAR(pINSTANCE_ID);
      v_pipe_mw       := 'MSC_CL_PULL_MW'||TO_CHAR(pINSTANCE_ID);
      v_pipe_status   := 'MSC_CL_PULL_ST'||TO_CHAR(pINSTANCE_ID);

      -- Initializes Level 2 Global Variables used in Data Pull

   END INITIALIZE_PULL_GLOBALS;


   PROCEDURE INITIALIZE_REMOTE_INSTANCE
   IS
      lv_user_name         VARCHAR2(100):= NULL;
      lv_resp_name         VARCHAR2(100):= NULL;
      lv_application_name  VARCHAR2(240):= NULL;

      lv_user_id           NUMBER;
      lv_resp_id           NUMBER;
      lv_application_id    NUMBER;

   BEGIN

         SELECT
            FND_GLOBAL.USER_NAME,
            FND_GLOBAL.RESP_NAME,
            FND_GLOBAL.APPLICATION_NAME
          INTO  lv_user_name,
                lv_resp_name,
                lv_application_name
          FROM  dual;

          SELECT APPLICATION_ID
          INTO lv_application_id
          FROM FND_APPLICATION_VL
          WHERE APPLICATION_NAME = lv_application_name;
    v_sql_stmt:=
       'BEGIN'
     ||'  MRP_CL_FUNCTION.APPS_INITIALIZE'||v_dblink
                         ||'( :lv_user_name,'
                         ||'  :lv_resp_name,'
                         ||'  :lv_application_name,'
                         ||'  :lv_application_id);'
     ||'END;';
       EXECUTE IMMEDIATE v_sql_stmt
                   USING lv_user_name,
                         lv_resp_name,
                         lv_application_name,
                         lv_application_id;
   END INITIALIZE_REMOTE_INSTANCE;

-- ===============================================================

   FUNCTION REFRESH_SNAPSHOT( p_instance_id  IN NUMBER,pRTYPE IN NUMBER)
     RETURN BOOLEAN
   IS

     lv_errbuf            VARCHAR2(2048);
     lv_retcode           NUMBER;

     lv_request_id        NUMBER;
     lv_timeout           NUMBER:= NVL(FND_PROFILE.VALUE('MSC_REF_SNAP_PENDING_TIMEOUT'),10.0);  /* minutes */

     lv_user_name         VARCHAR2(100);
     lv_resp_name         VARCHAR2(100);
     lv_application_name  VARCHAR2(240);
     lv_refresh_type	  VARCHAR2(1);
     lv_application_id    NUMBER;

    BEGIN

    FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_RS_START');
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,  FND_MESSAGE.GET );

    savepoint start_of_submission;

   -- agmcont:

/*    SELECT FND_GLOBAL.USER_NAME,
           FND_GLOBAL.RESP_NAME,
           FND_GLOBAL.APPLICATION_NAME
      INTO lv_user_name,
           lv_resp_name,
           lv_application_name
      FROM dual;
*/

      lv_user_name := FND_GLOBAL.USER_NAME;
      lv_resp_name := FND_GLOBAL.RESP_NAME;
      lv_application_name := FND_GLOBAL.APPLICATION_NAME;

      SELECT APPLICATION_ID
      INTO lv_application_id
      FROM FND_APPLICATION_VL
      WHERE APPLICATION_NAME = lv_application_name;


	SELECT DECODE ( pRTYPE, MSC_UTIL.G_COMPLETE,    'C',
                                MSC_UTIL.G_INCREMENTAL, 'I',
                                MSC_UTIL.G_PARTIAL,     'P',
                                MSC_UTIL.G_CONT,        'T')
	INTO lv_refresh_type
  	FROM DUAL;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' before calling MRP_CL_REFRESH_SNAPSHOT.REFRESH_SNAPSHOT 1 ');
      /* submit a (remote) request */
  IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Application id: ' || lv_application_id);
   v_sql_stmt:=
     'BEGIN MRP_CL_REFRESH_SNAPSHOT.REFRESH_SNAPSHOT'||v_dblink||'('
   ||'      ERRBUF =>        :lv_errbuf,'
   ||'      RETCODE =>       :lv_retcode,'
   ||'      p_user_name =>       :lv_user_name,'
   ||'      p_resp_name =>        :lv_resp_name,'
   ||'      p_application_name =>        :lv_application_name,'
   ||'      p_refresh_type => :lv_refresh_type,'
   ||'      o_request_id =>      :lv_request_id,'
   ||'      pInstance_ID =>       :p_instance_id,'
   ||'      pInstance_Code =>        :v_instance_code,'
   ||'      pa2m_dblink =>       :v_dest_a2m );'
   ||'END;';
   /*||'      p_application_id=>       :lv_application_id );' */

   EXECUTE IMMEDIATE v_sql_stmt
           USING OUT lv_errbuf,
                 OUT lv_retcode,
                 IN  lv_user_name,
                 IN  lv_resp_name,
                 IN  lv_application_name,
                 IN  lv_refresh_type,
                 OUT lv_request_id,
                 IN  p_instance_id,
                 IN  v_instance_code,
                 IN  v_dest_a2m;
                 /*IN  lv_application_id;*/

     ELSE

     v_sql_stmt:=
     'BEGIN MRP_CL_REFRESH_SNAPSHOT.REFRESH_SNAPSHOT'||v_dblink||'('
   ||'             :lv_errbuf,'
   ||'             :lv_retcode,'
   ||'             :lv_user_name,'
   ||'             :lv_resp_name,'
   ||'             :lv_application_name,'
   ||'		   :lv_refresh_type,'
   ||'             :lv_request_id, '
   ||'             p_application_id =>:lv_application_id );'
   ||'END;';


   EXECUTE IMMEDIATE v_sql_stmt
           USING OUT lv_errbuf,
                 OUT lv_retcode,
                 IN  lv_user_name,
                 IN  lv_resp_name,
                 IN  lv_application_name,
		 IN  lv_refresh_type,
                 OUT lv_request_id,
                 IN  lv_application_id;

     END IF;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'After refresh 2');
    IF lv_retcode= MSC_UTIL.G_ERROR THEN
       ROLLBACK TO start_of_submission;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  lv_errbuf);
       FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_RS_REQ_ERROR');
       FND_MESSAGE.SET_TOKEN('REQUEST_ID', lv_request_id);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  FND_MESSAGE.GET );
       RETURN FALSE;
    END IF;

    IF lv_request_id= 0 THEN
       ROLLBACK TO start_of_submission;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  lv_errbuf);
       FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_RS_ERROR');
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  FND_MESSAGE.GET );
       RETURN FALSE;
    END IF;

    COMMIT;

    FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_RS_REQUEST_ID');
    FND_MESSAGE.SET_TOKEN('REQUEST_ID', lv_request_id);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,  FND_MESSAGE.GET );

    /* purge the staging tables
       the purpose of calling this procedure is that we do a COMMIT after
       every task is done, if the previous data pull failed we may have
       data left in the staging tables...*/
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Before PURGE_STAGING_TABLES_SUB' );
    MSC_CL_PURGE_STAGING.PURGE_STAGING_TABLES_SUB( p_instance_id);

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'After PURGE_STAGING_TABLES_SUB' );
   -- fix for 2351297 --
   -- If its a single instance set up. Refresh Snapshot is submitted as a child request
   -- and setting the parent request at a PAUSED status.
    IF(v_dblink=NULL_DBLINK) THEN

        fnd_conc_global.set_req_globals( conc_status  => 'PAUSED',
                                         request_data => to_char(lv_request_id));
   -- No need to call wait_for_request, as the parent would be resumed after the completeion of the sub request.
    RETURN TRUE;
    END IF;
    /* wait until the refresh snapshot process is completed
       lv_timeout is used as the maximum waiting time for the refresh
       snapshot process to start */

    v_sql_stmt:=
        'BEGIN MRP_CL_REFRESH_SNAPSHOT.WAIT_FOR_REQUEST'||v_dblink||'('
      ||'           :lv_timeout,'
      ||'           :lv_retcode);'
      ||'END;';

    EXECUTE IMMEDIATE v_sql_stmt
            USING IN  lv_timeout,
                  OUT lv_retcode;

    IF lv_retcode = MSC_UTIL.G_NORMAL_COMPLETION THEN
        RETURN TRUE;
    ELSE
        IF lv_retcode = MSC_UTIL.G_PENDING_INACTIVE THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_RS_TIME_OUT');
            FND_MESSAGE.SET_TOKEN('PENDING_TIMEOUT', lv_timeout);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
        ELSE
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_RS_REQ_ERROR');
            FND_MESSAGE.SET_TOKEN('REQUEST_ID', lv_request_id);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  FND_MESSAGE.GET );
        END IF;
        RETURN FALSE;
    END IF;

   END REFRESH_SNAPSHOT;

/* --------------Continuous Collections private funcs/procs----------------------------------------------- */
/*
FUNCTION get_snapshot_log( p_snap_name      IN  varchar2,
                           p_dblink         IN  varchar2,
                           lv_snap_schema   OUT NOCOPY varchar2,
                           lv_mlog_tab_name OUT NOCOPY varchar2)
RETURN boolean
IS
 lv_base_table_name   varchar2(30);

BEGIN

    EXECUTE IMMEDIATE
        ' SELECT  owner,master FROM  ALL_SNAPSHOTS'|| p_dblink || ' WHERE  name = :p_snap_name '
                    INTO  lv_snap_schema,lv_base_table_name
          USING  p_snap_name;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Snapshot Owner = '||lv_snap_schema);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Master Table   = '||lv_base_table_name);

    EXECUTE IMMEDIATE
       '  SELECT  LOG_TABLE  FROM  ALL_SNAPSHOT_LOGS'|| p_dblink
                         ||'   WHERE  MASTER   = upper(:pTABLE_NAME)
                              AND  LOG_OWNER = upper(:pSCHEMA_NAME)
                              AND  ROWNUM    = 1 '
                  INTO  lv_mlog_tab_name
                 USING  lv_base_table_name, lv_snap_schema;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Snapshot Log  = '||lv_mlog_tab_name);

  RETURN TRUE;

EXCEPTION
 WHEN OTHERS THEN
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ' Error in getting the Snapshot information ....');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
   RETURN FALSE;

END get_snapshot_log;
 */

PROCEDURE GET_COLL_PARAM
                   (p_instance_id IN  NUMBER,
                    p_prec        OUT NOCOPY MSC_UTIL.CollParamREC )
AS
BEGIN

    /* Initialize the global prec record variable */

       SELECT delete_ods_data,org_group,threshold,supplier_capacity, atp_rules,
              bom, bor, calendar_check, demand_class,ITEM_SUBSTITUTES, forecast, item,
              kpi_targets_bis, mds, mps, oh, parameter, planners,
              projects, po, reservations, nra, safety_stock,
              sales_order, sourcing_history, sourcing, sub_inventories,
              customer, supplier, unit_numbers, uom, user_supply_demand, wip, user_comp_association,
               /* CP-ACK starts */
              supplier_response,
              /* CP-ACK ends */
              trip, ds_mode, po_receipts, sales_channel,fiscal_calendar,INTERNAL_REPAIR,EXTERNAL_REPAIR,    -- For Bug 5909379
              payback_demand_supply, currency_conversion,delivery_Details
       INTO p_prec.purge_ods_flag,p_prec.org_group_flag, p_prec.threshold,p_prec.app_supp_cap_flag,
              p_prec.atp_rules_flag, p_prec.bom_flag,
              p_prec.bor_flag, p_prec.calendar_flag,
              p_prec.demand_class_flag, p_prec.item_subst_flag,p_prec.forecast_flag,
              p_prec.item_flag, p_prec.kpi_bis_flag,
              p_prec.mds_flag, p_prec.mps_flag,
              p_prec.oh_flag, p_prec.parameter_flag,
              p_prec.planner_flag, p_prec.project_flag,
              p_prec.po_flag, p_prec.reserves_flag,
              p_prec.resource_nra_flag, p_prec.saf_stock_flag,
              p_prec.sales_order_flag, p_prec.source_hist_flag,
              p_prec.sourcing_rule_flag, p_prec.sub_inventory_flag,
              p_prec.tp_customer_flag, p_prec.tp_vendor_flag,
              p_prec.unit_number_flag, p_prec.uom_flag,
              p_prec.user_supply_demand_flag, p_prec.wip_flag, p_prec.user_company_flag,
              /* CP-ACK starts */
              p_prec.supplier_response_flag,
              /* CP-ACK ends */
              p_prec.trip_flag, p_prec.ds_mode,p_prec.po_receipts_flag,
              p_prec.sales_channel_flag,p_prec.fiscal_calendar_flag,p_prec.internal_repair_flag,p_prec.external_repair_flag,   -- for bug 5909379
              p_prec.payback_demand_supply_flag, p_prec.currency_conversion_flag ,--bug # 6469722
              p_prec.delivery_details_flag
         FROM msc_coll_parameters
        WHERE instance_id = p_instance_id;

END GET_COLL_PARAM;


PROCEDURE SALES_ORDER_REFRESH_TYPE ( p_instance_id in NUMBER,
                                     so_sn_flag out NOCOPY NUMBER )
IS

   lv_bom_sn_flag        number := MSC_UTIL.SYS_NO;
   lv_bor_sn_flag        number := MSC_UTIL.SYS_NO;
   lv_item_sn_flag       number := MSC_UTIL.SYS_NO;
   lv_oh_sn_flag         number := MSC_UTIL.SYS_NO;
   lv_usup_sn_flag       number := MSC_UTIL.SYS_NO;
   lv_udmd_sn_flag       number := MSC_UTIL.SYS_NO;
   lv_so_sn_flag         number := MSC_UTIL.SYS_NO;
   lv_fcst_sn_flag       number := MSC_UTIL.SYS_NO;
   lv_wip_sn_flag        number := MSC_UTIL.SYS_NO;
   lv_supcap_sn_flag     number := MSC_UTIL.SYS_NO;
   lv_po_sn_flag         number := MSC_UTIL.SYS_NO;
   lv_mds_sn_flag        number := MSC_UTIL.SYS_NO;
   /* CP-AUTO */
   lv_suprep_sn_flag     number := MSC_UTIL.SYS_NO;
   lv_mps_sn_flag        number := MSC_UTIL.SYS_NO;
   lv_nosnap_flag        number := MSC_UTIL.SYS_NO;
   lv_trip_sn_flag       number := MSC_UTIL.SYS_NO;

   lv_last_tgt_cont_coll_time    date;

   lv_prec             MSC_UTIL.CollParamREC;

BEGIN

   BEGIN
    SELECT DECODE( M2A_DBLINK,
                        NULL, NULL_DBLINK,
                        '@'||M2A_DBLINK),
                LAST_TGT_CONT_COLL_TIME
           INTO v_dblink,
                lv_last_tgt_cont_coll_time
          FROM MSC_APPS_INSTANCES
          WHERE INSTANCE_ID= p_instance_id;

   EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INVALID_INSTANCE_ID');
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID', p_instance_id);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
            RETURN;
         WHEN OTHERS THEN

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
            RETURN;
   END;

      GET_COLL_PARAM(p_instance_id,lv_prec);

     MSC_CL_CONT_COLL_FW.INIT_ENTITY_REFRESH_TYPE (lv_prec.threshold,
             null,
             lv_last_tgt_cont_coll_time,
             v_dblink,
             p_instance_id,
	           lv_prec,
	           lv_prec.org_group_flag,
             lv_bom_sn_flag,
             lv_bor_sn_flag,
             lv_item_sn_flag,
             lv_oh_sn_flag,
             lv_usup_sn_flag,
             lv_udmd_sn_flag,
             lv_so_sn_flag,
             lv_fcst_sn_flag,
             lv_wip_sn_flag,
             lv_supcap_sn_flag,
             lv_po_sn_flag,
             lv_mds_sn_flag,
             lv_mps_sn_flag,
             lv_nosnap_flag,
            /* CP-AUTO */
             lv_suprep_sn_flag,
             lv_trip_sn_flag);

  so_sn_flag := lv_so_sn_flag;

EXCEPTION
  WHEN OTHERS THEN
         ROLLBACK;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
END SALES_ORDER_REFRESH_TYPE;


   -- ============== End of Private Functions ===================

-- ============== Public Function        =====================

FUNCTION GET_ORG_STR(p_instance_id IN NUMBER, p_type IN NUMBER)
RETURN VARCHAR2 IS

TYPE OpmOrgCurType IS REF CURSOR;
lc_opm_org OpmOrgCurType;

wrong_p_type  EXCEPTION;

lv_org_id     NUMBER;
lv_dblink     VARCHAR2(128);
lv_in_org_str VARCHAR2(32767):=NULL;
lv_sql_str    VARCHAR2(1000);

cursor org IS
     select mio.organization_id org_id
     from msc_instance_orgs mio,
          msc_coll_parameters mcp
     where mio.sr_instance_id= p_instance_id
     and mcp.instance_id = p_instance_id
     and mio.enabled_flag= 1
     and (( mcp.org_group = MSC_UTIL.G_ALL_ORGANIZATIONS ) or
(mio.org_group=mcp.org_group));

cursor all_org IS
     select organization_id org_id
     from msc_instance_orgs
     where sr_instance_id= p_instance_id
     and enabled_flag= 1;

BEGIN

--MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'GET_ORG_STR() input parameter p_type: '||to_char(p_type));
--MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'GET_ORG_STR() input parameter p_instance_id: '||to_char(p_instance_id));

IF(p_type=1 OR p_type=2)then
      FOR lc_ins_org IN org LOOP
          IF org%rowcount = 1 THEN
             lv_in_org_str:=' IN ('|| lc_ins_org.org_id;
          ELSE
             lv_in_org_str := lv_in_org_str||','||lc_ins_org.org_id;
          END IF;
      END LOOP;
      /* we want all OPM orgs in case it GMP version < = k and p_type=2 */
      IF(p_type=2 AND gmp_aps_utility.is_opm_compatible=0)then
                      --then append all the OPM orgs
                      BEGIN
                        SELECT DECODE(M2A_DBLINK,NULL,NULL_DBLINK,'@'||M2A_DBLINK)
                        INTO lv_dblink
                        FROM MSC_APPS_INSTANCES
                        WHERE INSTANCE_ID= p_instance_id;

                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            FND_MESSAGE.SET_NAME('MSC','MSC_DP_INVALID_INSTANCE_ID');
                            FND_MESSAGE.SET_TOKEN('INSTANCE_ID', p_instance_id);
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
                            RETURN '=-9999';
                         WHEN OTHERS THEN
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
                            RETURN '=-9999';
                      END;

                      BEGIN
                      lv_sql_str:=' SELECT mp.organization_id org_id'
                                ||' from mtl_parameters'||lv_dblink||' mp,'
                                ||'      msc_instance_orgs mio'
                                ||' where mio.sr_instance_id= :p_instance_id'
                                ||' and   mio.enabled_flag= 1'
                                ||' and mio.organization_id=mp.organization_id'
                                ||' and   mp.process_enabled_flag='||'''Y''';
                      OPEN lc_opm_org FOR lv_sql_str USING p_instance_id;
                      LOOP
                        FETCH lc_opm_org INTO lv_org_id;  -- fetch next row
                        EXIT WHEN lc_opm_org%NOTFOUND;  -- exit loop when last row is fetched
                        lv_in_org_str := lv_in_org_str||','||lv_org_id;
                      END LOOP;
                      CLOSE lc_opm_org;
                      EXCEPTION
                        WHEN OTHERS THEN
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
                            RETURN '=-9999';
                      END;
      END IF;
      IF lv_in_org_str<>'NULL' THEN
         lv_in_org_str:= lv_in_org_str || ')';
      ELSE
         lv_in_org_str:= '= -9999';
      END IF;
ELSIF(p_type=3)THEN
      FOR lc_ins_org IN all_org LOOP
          IF all_org%rowcount = 1 THEN
             lv_in_org_str:=' IN ('|| lc_ins_org.org_id;
          ELSE
             lv_in_org_str := lv_in_org_str||','||lc_ins_org.org_id;
          END IF;
      END LOOP;
      IF lv_in_org_str<>'NULL' THEN
         lv_in_org_str:= lv_in_org_str || ')';
      ELSE
         lv_in_org_str:= '= -9999';
      END IF;
ELSE RAISE wrong_p_type;
END IF;

--MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'GET_ORG_STR() returns  '||lv_in_org_str);
RETURN lv_in_org_str;

EXCEPTION
   WHEN wrong_p_type THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Error: Wrong value of p_type('||to_Char(p_type)||')  in GET_ORG_STR() ');
	   RETURN '=-9999';
   WHEN OTHERS THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Error: In GET_ORG_STR() ');
	   RETURN '=-9999';
END GET_ORG_STR;

/* This function is created as wrapper over GET_ORG_STR(p_instance_id IN NUMBER, p_type IN NUMBER), as OPM call is without any parameters. */
FUNCTION GET_ORG_STR
RETURN VARCHAR2 IS

lv_in_org_str VARCHAR2(32767):=NULL;

BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'GET_ORG_STR value of v_instance_id: '||to_char(v_instance_id));

lv_in_org_str := GET_ORG_STR (v_instance_id,2);

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'GET_ORG_STR returns  '||lv_in_org_str);
RETURN lv_in_org_str;

EXCEPTION
    WHEN OTHERS THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Error: In GET_ORG_STR ');
	   RETURN '=-9999';
END GET_ORG_STR;

   -- ============== End of Public  Functions ===================

   -- ============== Public Procedures        ===================
   -- LAUNCH_WORKER --
   PROCEDURE LAUNCH_WORKER(  ERRBUF			 OUT NOCOPY VARCHAR2,
	              RETCODE				 OUT NOCOPY NUMBER   ,
                      pMONITOR_REQUEST_ID                IN  NUMBER   ,
                      pINSTANCE_ID                       IN  NUMBER   ,
                      pTIMEOUT                           IN  NUMBER   ,
                      pLANG                              IN  VARCHAR2 ,
                      pRTYPE                             IN  NUMBER   ,
                      pREFRESH_ID                        IN  NUMBER   ,
 ----- FLAGS --------------------------------------------------------------
                      pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    ,
                      pATP_RULES_ENABLED                 IN  NUMBER    ,
                      pBOM_ENABLED                       IN  NUMBER    ,
                      pBOR_ENABLED                       IN  NUMBER    ,
                      pCALENDAR_ENABLED                  IN  NUMBER    ,
                      pDEMAND_CLASS_ENABLED              IN  NUMBER    ,
                      pITEM_SUBST_ENABLED                IN  NUMBER    ,
                      pFORECAST_ENABLED                  IN  NUMBER    ,
                      pITEM_ENABLED                      IN  NUMBER    ,
                      pKPI_BIS_ENABLED                   IN  NUMBER    ,
                      pMDS_ENABLED                       IN  NUMBER    ,
                      pMPS_ENABLED                       IN  NUMBER    ,
                      pOH_ENABLED                        IN  NUMBER    ,
                      pPARAMETER_ENABLED                 IN  NUMBER    ,
                      pPLANNER_ENABLED                   IN  NUMBER    ,
                      pPROJECT_ENABLED                   IN  NUMBER    ,
                      pPUR_REQ_PO_ENABLED                IN  NUMBER    ,
                      pRESERVES_HARD_ENABLED             IN  NUMBER    ,
                      pRESOURCE_NRA_ENABLED              IN  NUMBER    ,
                      pSafeStock_ENABLED                 IN  NUMBER    ,
                      pSalesOrder_RTYPE                  IN  NUMBER   ,
                      pSH_ENABLED                        IN  NUMBER    ,
                      pSOURCING_ENABLED                  IN  NUMBER    ,
                      pSUB_INV_ENABLED                   IN  NUMBER    ,
                      pTP_CUSTOMER_ENABLED               IN  NUMBER    ,
                      pTP_VENDOR_ENABLED                 IN  NUMBER    ,
                      pUNIT_NO_ENABLED                   IN  NUMBER    ,
                      pUOM_ENABLED                       IN  NUMBER    ,
                      pUSER_SUPPLY_DEMAND                IN  NUMBER    ,
                      pWIP_ENABLED                       IN  NUMBER    ,
                      pPO_RECEIPTS_ENABLED               IN  NUMBER    ,
                      pUSER_COMPANY_ENABLED              IN  NUMBER    ,
					  					/* CP-ACK starts */
					  					pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    ,
					  					/* CP-ACK ends */
					  					pTRIP_ENABLED                      IN  NUMBER
               )
   IS

   -- Profile Option --

   lv_so_ship_arrive_value         NUMBER;
   lv_mps_consume_profile_value    NUMBER;
   lv_spread_load                  NUMBER;
   lv_hour_uom                     VARCHAR2(3);

   -- MSC Profile Option --

   lv_mso_item_dmd_penalty         NUMBER;
   lv_mso_item_cap_penalty         NUMBER;
   lv_mso_org_dmd_penalty          NUMBER;
   lv_mso_org_item_penalty         NUMBER;
   lv_mso_org_res_penalty          NUMBER;
   lv_mso_org_trsp_penalty         NUMBER;
   lv_msc_aggreg_res_name          NUMBER;
   lv_mso_res_penalty              NUMBER;
   lv_mso_sup_cap_penalty          NUMBER;
   lv_msc_bom_subst_priority       NUMBER;
   lv_mso_trsp_penalty             NUMBER;
   lv_msc_alt_bom_cost             NUMBER;
   lv_mso_fcst_penalty             NUMBER;
   lv_mso_so_penalty               NUMBER;
 --  lv_msc_alt_op_res               NUMBER;
   lv_msc_alt_res_priority         NUMBER;
   lv_msc_batchable_flag               NUMBER;
   lv_msc_batching_window              NUMBER;
   lv_msc_min_capacity                 NUMBER;
   lv_msc_max_capacity                 NUMBER;
   lv_msc_unit_of_measure              NUMBER;
   lv_msc_simul_res_seq            NUMBER;
   lv_mrp_bis_av_discount          NUMBER;
   lv_mrp_bis_price_list           NUMBER;
   lv_msc_dmd_priority_flex_num    NUMBER;
   lv_msc_fcst_priority_flex_num   NUMBER;

   -- Userenv, Installation Information --
   lv_lang                         VARCHAR2(4);
   lv_oe_install                   VARCHAR2(170):= 'OE';

   -- Task Parameter --
   lv_lrn                     NUMBER;

   -- Task Control --
   lv_task_num                PLS_INTEGER;  -- NEGATIVE: Unknown Error Occurs
                                            -- 0       : All Task Is Done
                                            -- POSITIVE: The Task Number

   lv_task_status             NUMBER;    -- ::OK    : THE TASK IS Done in MSC
                                         -- OTHERS  : THE TASK Fails

   lv_start_time       DATE;
   lv_process_time     NUMBER;

   lv_apps_ver         NUMBER;

   EX_PROCESS_TIME_OUT EXCEPTION;

  -- Pipe Control --

   lv_ret_code NUMBER;   -- The return value of Sending/Receiving Pipe Messages

   EX_PIPE_RCV        EXCEPTION;
   EX_PIPE_SND        EXCEPTION;

   prec               MSC_UTIL.CollParamREC;

   --Status of worker
   lv_is_waiting      boolean := TRUE;

--agmcont:
   lv_toset_prec_flag boolean:=TRUE;


   BEGIN
     RETCODE := MSC_UTIL.G_SUCCESS;
     ERRBUF := NULL;
      v_instance_id := pINSTANCE_ID;

      v_monitor_request_id := pMONITOR_REQUEST_ID;

      -- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

      IF fnd_global.conc_request_id > 0 THEN
         v_cp_enabled:= MSC_UTIL.SYS_YES;
      ELSE
         v_cp_enabled:= MSC_UTIL.SYS_NO;
      END IF;





      BEGIN

         SELECT DECODE( M2A_DBLINK,
                        NULL, NULL_DBLINK,
                        '@'||M2A_DBLINK),
                DECODE( M2A_DBLINK,
                        NULL, MSC_UTIL.SYS_NO,
                        MSC_UTIL.SYS_YES),
                APPS_VER,
                APPS_LRN,
                APPS_LRN
           INTO v_dblink,
                v_distributed_config_flag,
                lv_apps_ver,
                v_lrnn,
                v_so_lrn
           FROM MSC_APPS_INSTANCES
          WHERE INSTANCE_ID= pINSTANCE_ID;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            RETCODE := MSC_UTIL.G_ERROR;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INVALID_INSTANCE_ID');
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID', pINSTANCE_ID);
            ERRBUF:= FND_MESSAGE.GET;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

            RETURN;

         WHEN OTHERS THEN

            RAISE;

      END;


         -- to initialize common global variables bug#5897346
      MSC_UTIL.INITIALIZE_COMMON_GLOBALS(pINSTANCE_ID);
      INITIALIZE_PULL_GLOBALS( pINSTANCE_ID);  -- Initializes Level 2 Global Variables used in Data Pull
   -- Initialize the Start Time and Pipename


   -- Initialize the remote Applications database, if it's a distributed
   -- configuration.

      IF v_distributed_config_flag = MSC_UTIL.SYS_YES THEN
         INITIALIZE_REMOTE_INSTANCE;
         COMMIT;

      END IF;

   -- Get environment parameters
   -- 1. LANG
   -- 2. PROFILE OPTIONS


      IF lv_apps_ver>= MSC_UTIL.G_APPS115 THEN
      v_sql_stmt:=
      'SELECT USERENV(''LANG''),'
    ||'   FND_PROFILE.VALUE'||v_dblink||'(''BOM:HOUR_UOM_CODE''),'
    ||'   DECODE( FND_PROFILE.VALUE'||v_dblink||'(''MRP_MPS_CONSUMPTION''),'
    ||'           ''Y'', 1,'
    ||'           ''1'', 1,'
    ||'           2),'
    ||'   DECODE( FND_PROFILE.VALUE'||v_dblink||'(''MRP_SHIP_ARRIVE_FLAG''),'
    ||'           ''Y'', 1,'
    ||'           ''1'', 1,'
    ||'           2),'
    ||'   DECODE( FND_PROFILE.VALUE'||v_dblink||'(''CRP_SPREAD_LOAD''),'
    ||'           ''Y'', 1,'
    ||'           ''1'', 1,'
    ||'           2),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_ITEM_DMD_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_ITEM_CAP_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_ORG_DMD_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_ORG_ITEM_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_ORG_RES_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_ORG_TRSP_PENALTY'')),'
    ||'              FND_PROFILE.VALUE'||v_dblink||'(''MSC_AGGREG_RES_NAME''),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_RES_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_SUP_CAP_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_BOM_SUBST_PRIORITY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_TRSP_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_ALT_BOM_COST'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_FCST_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSO_SO_PENALTY'')),'
--    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_RESOURCE_TYPE'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_ALT_RES_PRIORITY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_BATCHABLE_FLAG'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_BATCHING_WINDOW'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_MIN_CAPACITY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_MAX_CAPACITY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_UNIT_OF_MEASURE'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_SIMUL_RES_SEQ'')),'
    ||'   NVL(TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_BIS_AV_DISCOUNT'')),0),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_BIS_PRICE_LIST'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_DMD_PRIORITY_FLEX_NUM'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MSC_FCST_PRIORITY_FLEX_NUM''))'
    ||' FROM DUAL';

      ELSE
      v_sql_stmt:=
      'SELECT USERENV(''LANG''),'
    ||'   FND_PROFILE.VALUE'||v_dblink||'(''BOM:HOUR_UOM_CODE''),'
    ||'   DECODE( FND_PROFILE.VALUE'||v_dblink||'(''MRP_MPS_CONSUMPTION''),'
    ||'           ''Y'', 1,'
    ||'           ''1'', 1,'
    ||'           2),'
    ||'   DECODE( FND_PROFILE.VALUE'||v_dblink||'(''MRP_SHIP_ARRIVE_FLAG''),'
    ||'           ''Y'', 1,'
    ||'           ''1'', 1,'
    ||'           2),'
    ||'   DECODE( FND_PROFILE.VALUE'||v_dblink||'(''CRP_SPREAD_LOAD''),'
    ||'           ''Y'', 1,'
    ||'           ''1'', 1,'
    ||'           2),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_ITEM_DMD_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_ITEM_CAP_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_ORG_DMD_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_ORG_ITEM_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_ORG_RES_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_ORG_TRSP_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_AGGREG_RES_NAME'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_RES_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_SUP_CAP_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_BOM_SUBST_PRIORITY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_TRSP_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_ALT_BOM_COST'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_FCST_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_SO_PENALTY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_RESOURCE_TYPE'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_ALT_RES_PRIORITY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_BATCHABLE_FLAG'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_BATCHING_WINDOW'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_MIN_CAPACITY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_MAX_CAPACITY'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_UNIT_OF_MEASURE'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_SIMUL_RES_SEQ'')),'
    ||'   NVL(TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_BIS_AV_DISCOUNT'')),0),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_BIS_PRICE_LIST'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_DMD_PRIORITY_FLEX_NUM'')),'
    ||'   TO_NUMBER( FND_PROFILE.VALUE'||v_dblink||'(''MRP_FCST_PRIORITY_FLEX_NUM''))'
    ||' FROM DUAL';

        END IF;

        EXECUTE IMMEDIATE v_sql_stmt
           INTO lv_lang,
                lv_hour_uom,            -- used in resource required
                lv_mps_consume_profile_value,
                lv_so_ship_arrive_value,-- used in supplies
                lv_spread_load,         -- used in resource required
                lv_mso_item_dmd_penalty,
                lv_mso_item_cap_penalty,
                lv_mso_org_dmd_penalty,
                lv_mso_org_item_penalty,
                lv_mso_org_res_penalty,
                lv_mso_org_trsp_penalty,
                lv_msc_aggreg_res_name,
                lv_mso_res_penalty,
                lv_mso_sup_cap_penalty,
                lv_msc_bom_subst_priority,
                lv_mso_trsp_penalty,
                lv_msc_alt_bom_cost,
                lv_mso_fcst_penalty,
                lv_mso_so_penalty,
--                lv_msc_alt_op_res,
                lv_msc_alt_res_priority,
                lv_msc_batchable_flag               ,
                lv_msc_batching_window             ,
                lv_msc_min_capacity               ,
                lv_msc_max_capacity              ,
                lv_msc_unit_of_measure          ,
                lv_msc_simul_res_seq,
                lv_mrp_bis_av_discount,
                lv_mrp_bis_price_list,
                lv_msc_dmd_priority_flex_num,
                lv_msc_fcst_priority_flex_num;

   BEGIN

/*
     v_sql_stmt:=
         'SELECT OE_INSTALL.Get_Active_Product'||v_dblink||' FROM DUAL';

      EXECUTE IMMEDIATE v_sql_stmt
         INTO lv_oe_install;
*/

/* NCPerf */
     lv_oe_install:= OE_INSTALL.Get_Active_Product||v_dblink;

   EXCEPTION

     WHEN OTHERS THEN

        IF SQLCODE<> -904 THEN
           RAISE;
        END IF;
   END;


   -- Set the Last Refresh Number, -1: for complete refresh ------------------

      /**  PREPLACE CHANGE START **/

      --IF pRTYPE= MSC_UTIL.SYS_YES THEN
      IF ((pRTYPE = MSC_UTIL.G_COMPLETE) OR (pRTYPE = MSC_UTIL.G_PARTIAL)) THEN
         v_lrnn:= -1;

         IF pSalesOrder_RTYPE= MSC_UTIL.SYS_YES THEN
            v_so_lrn:= -1;
         END IF;
      END IF;

      /**   PREPLACE CHANGE END  **/

      lv_start_time:= SYSDATE;


   -- ============= Get the Task FROM Task Que ==============

      LOOP

   -- ============= Check the execution time ==============

          EXIT WHEN is_monitor_status_running <> MSC_UTIL.SYS_YES;

          EXIT WHEN is_request_status_running <> MSC_UTIL.SYS_YES;

          SELECT (SYSDATE- lv_start_time) INTO lv_process_time FROM dual;
          IF lv_process_time > pTIMEOUT/1440.0 THEN RAISE EX_PROCESS_TIME_OUT;
          END IF;

   -- Get the Task Number ----------------------

          lv_ret_code := DBMS_PIPE.RECEIVE_MESSAGE( v_pipe_task_que, PIPE_TIME_OUT);

--agmcont
          if (lv_toset_prec_flag) then
             lv_toset_prec_flag := FALSE;
             SELECT org_group,delete_ods_data, supplier_capacity, atp_rules,
                 bom, bor, calendar_check, demand_class,ITEM_SUBSTITUTES, forecast, item,
                 kpi_targets_bis, mds, mps, oh, parameter, planners,
                 projects, po, reservations, nra, safety_stock,
                 sales_order, sourcing_history, sourcing, sub_inventories,
                 customer, supplier, unit_numbers, uom, user_supply_demand, wip, user_comp_association,
                 po_receipts, bom_sn_flag, bor_sn_flag, item_sn_flag, oh_sn_flag,
                 usup_sn_flag, udmd_sn_flag, so_sn_flag, fcst_sn_flag,
                 wip_sn_flag, supcap_sn_flag, po_sn_flag, mds_sn_flag,
                 mps_sn_flag, nosnap_flag
				 /* CP-ACK starts */
				 ,SUPPLIER_RESPONSE
				 /* CP-ACK ends */
				 /* CP-AUTO */
				 ,SUPREP_SN_FLAG,trip,trip_sn_flag,ds_mode,sales_channel,fiscal_calendar,INTERNAL_REPAIR,EXTERNAL_REPAIR   -- for bug 5909379
				 ,payback_demand_supply, currency_conversion -- bug #6469722
				 ,delivery_Details
             INTO prec.org_group_flag, prec.purge_ods_flag, prec.app_supp_cap_flag,
                 prec.atp_rules_flag, prec.bom_flag,
                 prec.bor_flag, prec.calendar_flag,
                 prec.demand_class_flag, prec.item_subst_flag,prec.forecast_flag,
                 prec.item_flag, prec.kpi_bis_flag,
                 prec.mds_flag, prec.mps_flag,
                 prec.oh_flag, prec.parameter_flag,
                 prec.planner_flag, prec.project_flag,
                 prec.po_flag, prec.reserves_flag,
                 prec.resource_nra_flag, prec.saf_stock_flag,
                 prec.sales_order_flag, prec.source_hist_flag,
                 prec.sourcing_rule_flag, prec.sub_inventory_flag,
                 prec.tp_customer_flag, prec.tp_vendor_flag,
                 prec.unit_number_flag, prec.uom_flag,
                 prec.user_supply_demand_flag, prec.wip_flag, prec.user_company_flag,
                 prec.po_receipts_flag,
                 prec.bom_sn_flag, prec.bor_sn_flag,
                 prec.item_sn_flag, prec.oh_sn_flag,
                 prec.usup_sn_flag, prec.udmd_sn_flag,
                 prec.so_sn_flag, prec.fcst_sn_flag,
                 prec.wip_sn_flag,
                 prec.supcap_sn_flag, prec.po_sn_flag,
                 prec.mds_sn_flag, prec.mps_sn_flag,
                 prec.nosnap_flag
				 /* CP-ACK starts */
				 ,prec.supplier_response_flag
				 /* CP-ACK ends */
				 /* CP-AUTO */
				 ,prec.suprep_sn_flag,prec.trip_flag,prec.trip_sn_flag  ,
				 prec.ds_mode,
				 prec.sales_channel_flag,prec.fiscal_calendar_flag,prec.internal_repair_flag,prec.external_repair_flag -- for bug 5909379
				 ,prec.payback_demand_supply_flag, prec.currency_conversion_flag -- bug # 6469722
				 ,prec.delivery_details_flag
             FROM msc_coll_parameters
             WHERE instance_id = pINSTANCE_ID;

          end if;


          FND_MESSAGE.SET_NAME('MSC','MSC_CL_WORKER_RCV_RET_CODE');
          FND_MESSAGE.SET_TOKEN('LV_TASK_NUMBER',lv_ret_code);
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

          IF lv_ret_code<>0 THEN

             IF lv_ret_code = 1 THEN
                IF lv_is_waiting THEN
                  lv_is_waiting := false;
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Waiting for task to arrive');
                END IF;
             ELSE
                RAISE EX_PIPE_RCV;
             END IF;


          ELSE
             lv_is_waiting := true;
             DBMS_PIPE.UNPACK_MESSAGE( lv_task_num);

             FND_MESSAGE.SET_NAME('MSC','MSC_CL_WORKER_TSK_UNPACK');
             FND_MESSAGE.SET_TOKEN('LV_TASK_NUM',lv_task_num);
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

             EXIT WHEN lv_task_num<= 0;  -- No task is left or unknown error occurs.

   -- ============= Execute the Task =============

             lv_task_status := FAIL;

             IF (lv_task_num= TASK_SALES_ORDER1) OR
	               (lv_task_num= TASK_SALES_ORDER2) OR
	               (lv_task_num= TASK_SALES_ORDER3) OR
	           --    (lv_task_num= TASK_SALES_ORDER3) OR
	               (lv_task_num= TASK_AHL) THEN
                lv_lrn:= v_so_lrn;
             ELSE
                lv_lrn:= v_lrnn;
             END IF;

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Executing Task Number '|| TO_CHAR(lv_task_num));

             EXECUTE_TASK
                        ( lv_task_status,
                          lv_task_num,
                          pINSTANCE_ID,
                          lv_lrn,
                          pREFRESH_ID,
 ----- PROFILE OPTION --------------------------------------------------
                          lv_so_ship_arrive_value,
                          lv_mps_consume_profile_value,
                          lv_spread_load,
                          lv_hour_uom,
                          lv_lang,
                          lv_oe_install,
 ----- MSC PROFILE OPTION ----------------------------------------------
                          lv_mso_item_dmd_penalty,
                          lv_mso_item_cap_penalty,
                          lv_mso_org_dmd_penalty,
                          lv_mso_org_item_penalty,
                          lv_mso_org_res_penalty,
                          lv_mso_org_trsp_penalty,
                          lv_msc_aggreg_res_name,
                          lv_mso_res_penalty,
                          lv_mso_sup_cap_penalty,
                          lv_msc_bom_subst_priority,
                          lv_mso_trsp_penalty,
                          lv_msc_alt_bom_cost,
                          lv_mso_fcst_penalty,
                          lv_mso_so_penalty,
				null,
--    lv_msc_alt_op_res,
                          lv_msc_alt_res_priority,
                          lv_msc_batchable_flag               ,
                          lv_msc_batching_window             ,
                          lv_msc_min_capacity               ,
                          lv_msc_max_capacity              ,
                          lv_msc_unit_of_measure          ,
                          lv_msc_simul_res_seq,
                          lv_mrp_bis_av_discount,
                          lv_mrp_bis_price_list,
                          lv_msc_dmd_priority_flex_num,
                          lv_msc_fcst_priority_flex_num,
 ----- FLAGS -----------------------------------------------------------
                      pITEM_ENABLED,
                      pTP_VENDOR_ENABLED,
                      pTP_CUSTOMER_ENABLED,
                      pBOM_ENABLED,
                      pRESERVES_HARD_ENABLED,
                      pSOURCING_ENABLED,
                      pWIP_ENABLED,
                      pPO_RECEIPTS_ENABLED,
                      pSafeStock_ENABLED,
                      pPUR_REQ_PO_ENABLED ,
                      pITEM_SUBST_ENABLED,
                      pOH_ENABLED,
                      pAPPROV_SUPPLIER_CAP_ENABLED,
                      pUOM_ENABLED,
                      pMDS_ENABLED,
                      pFORECAST_ENABLED,
                      pMPS_ENABLED,
                      pRESOURCE_NRA_ENABLED,
                      pSH_ENABLED,
		                  pUSER_COMPANY_ENABLED,
                      /* CP-ACK change starts */
                      pSUPPLIER_RESPONSE_ENABLED,
                      /* CP-ACK change ends */
                      pTRIP_ENABLED,
                      prec);


   -- =========== Send the executed lv_task_num back to the monitor  =======
   -- =========== Positive Number means OK, Negative means FAIL  ===========

             IF lv_task_status <> OK THEN
                   FND_MESSAGE.SET_NAME('MSC','MSC_CL_EXECUTE_TSK_PROB');
                   FND_MESSAGE.SET_TOKEN('LV_TASK_NUMBER',lv_task_num);
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

                DBMS_PIPE.PACK_MESSAGE( -lv_task_num);

             ELSE

                DBMS_PIPE.PACK_MESSAGE( lv_task_num);
                COMMIT;

             END IF;

             IF DBMS_PIPE.SEND_MESSAGE( v_pipe_wm)<>0 THEN RAISE EX_PIPE_SND;
             END IF;

             IF lv_task_status <> OK THEN DBMS_LOCK.SLEEP(5);
             END IF;

          END IF;

      END LOOP;

      IF lv_task_num = 0 THEN                           -- NO TASK IS LEFT
         COMMIT;

         DBMS_PIPE.PACK_MESSAGE( MSC_UTIL.SYS_YES);

         IF DBMS_PIPE.SEND_MESSAGE( v_pipe_status)<>0 THEN
            RAISE EX_PIPE_SND;
         END IF;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_SUCCEED');
         ERRBUF:= FND_MESSAGE.GET;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ERRBUF);

         RETCODE := MSC_UTIL.G_SUCCESS;
         return;
      ELSIF (lv_task_num = START_ODS_LOAD) THEN         --- call the ODS Load worker

/* ---------------- agmcont -------------------- */

      /* --- call ods load worker --- */

      if (pRTYPE = MSC_UTIL.G_CONT) then
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Calling ODS load worker');

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '****************************************************');
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Planning ODS LOAD Worker is Started.');
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '****************************************************');


         BEGIN
         MSC_CL_COLLECTION.LAUNCH_WORKER(
                     ERRBUF				,
	             RETCODE				,
                     pMONITOR_REQUEST_ID                ,
                     pINSTANCE_ID                       ,
                     -99,                      -- last_collection_id
                     pTIMEOUT                           ,
                     MSC_UTIL.SYS_NO,              --- Recalc NRA
                     MSC_UTIL.SYS_NO,                 -- Recalc sourcing history
                     MSC_UTIL.SYS_YES,  --exchange_mode
                     MSC_UTIL.SYS_YES  );

        EXCEPTION
	      WHEN OTHERS THEN
                 ROLLBACK;
	         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
        END;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '****************************************************');
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Planning ODS LOAD Worker is Completed.');
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '****************************************************');

      end if;

/* ---------------- agmcont -------------------- */

      ELSE                                          -- Unknown Error
         ROLLBACK;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'There is an Unknown error in the Worker.');

         DBMS_PIPE.PACK_MESSAGE( MSC_UTIL.SYS_YES);

         IF DBMS_PIPE.SEND_MESSAGE( v_pipe_status)<>0 THEN
            RAISE EX_PIPE_SND;
         END IF;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_FAIL');
         ERRBUF:= FND_MESSAGE.GET;

         RETCODE := MSC_UTIL.G_ERROR;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);
      END IF;

         RETCODE := MSC_UTIL.G_SUCCESS;

    EXCEPTION

      WHEN others THEN

         ROLLBACK;             -- ROLLBACK if any exception occurs

         FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_FAIL');
         ERRBUF:= FND_MESSAGE.GET;
         RETCODE := MSC_UTIL.G_ERROR;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);

         DBMS_PIPE.PACK_MESSAGE( UNRESOLVABLE_ERROR);

         IF DBMS_PIPE.SEND_MESSAGE( v_pipe_wm)<>0 THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_MSG_SEND_FAIL');
            FND_MESSAGE.SET_TOKEN('PIPE', v_pipe_wm);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         END IF;

         DBMS_PIPE.PACK_MESSAGE( MSC_UTIL.SYS_YES);

         IF DBMS_PIPE.SEND_MESSAGE( v_pipe_status)<>0 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_MSG_SEND_FAIL');
            FND_MESSAGE.SET_TOKEN('PIPE', v_pipe_status);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
         END IF;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error_Stack...');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, DBMS_UTILITY.FORMAT_ERROR_STACK );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error_Backtrace...' );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

   END LAUNCH_WORKER;

-- ===============================================================

   PROCEDURE LAUNCH_MONITOR(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pORG_GROUP                         IN  VARCHAR2,
               pTotalWorkerNum                    IN  NUMBER,
               pTIMEOUT                           IN  NUMBER, -- min
               pLANG                              IN  VARCHAR2 ,
               pOdsPURGEoption                    IN  NUMBER   ,
               pRTYPE                             IN  NUMBER  ,
               pANATBL_ENABLED                    IN  NUMBER   ,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER   ,
               pATP_RULES_ENABLED                 IN  NUMBER   ,
               pBOM_ENABLED                       IN  NUMBER   ,
               pBOR_ENABLED                       IN  NUMBER   ,
               pCALENDAR_ENABLED                  IN  NUMBER   ,
               pDEMAND_CLASS_ENABLED              IN  NUMBER   ,
               pITEM_SUBST_ENABLED                IN  NUMBER   ,
               pFORECAST_ENABLED                  IN  NUMBER   ,
               pITEM_ENABLED                      IN  NUMBER   ,
               pKPI_BIS_ENABLED                   IN  NUMBER   ,
               pMDS_ENABLED                       IN  NUMBER   ,
               pMPS_ENABLED                       IN  NUMBER   ,
               pOH_ENABLED                        IN  NUMBER   ,
               pPARAMETER_ENABLED                 IN  NUMBER   ,
               pPLANNER_ENABLED                   IN  NUMBER   ,
               pPO_RECEIPTS_ENABLED               IN  NUMBER   ,
               pPROJECT_ENABLED                   IN  NUMBER   ,
               pPUR_REQ_PO_ENABLED                IN  NUMBER   ,
               pRESERVES_HARD_ENABLED             IN  NUMBER   ,
               pRESOURCE_NRA_ENABLED              IN  NUMBER   ,
               pSafeStock_ENABLED                 IN  NUMBER   ,
               pSalesOrder_RTYPE                  IN  NUMBER  ,
               pSH_ENABLED                        IN  NUMBER   ,
               pSOURCING_ENABLED                  IN  NUMBER   ,
               pSUB_INV_ENABLED                   IN  NUMBER   ,
               /* CP-ACK change starts */
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER   ,
               /* CP-ACK change ends */
               pTP_CUSTOMER_ENABLED               IN  NUMBER   ,
               pTP_VENDOR_ENABLED                 IN  NUMBER   ,
               pTRIP_ENABLED                      IN  NUMBER   , -- DRP
               pUNIT_NO_ENABLED                   IN  NUMBER   ,
               pUOM_ENABLED                       IN  NUMBER   ,
	             pUSER_COMPANY_ENABLED              IN  NUMBER   ,
               pUSER_SUPPLY_DEMAND                IN  NUMBER   ,
               pWIP_ENABLED                       IN  NUMBER    ,
               pSALES_CHANNEL_ENABLED             IN  NUMBER   ,
               pFISCAL_CALENDAR_ENABLED             IN  NUMBER ,
               pINTERNAL_REPAIR_ENABLED           IN  NUMBER   , -- for bug 5909379
               pEXTERNAL_REPAIR_ENABLED           IN  NUMBER   ,
               pPAYBACK_DEMAND_SUPPLY_ENABLED     IN  NUMBER   ,
               pCURRENCY_CONVERSION_ENABLED	  IN  NUMBER,   -- for bug 6469722
               pDELIVERY_DETAILS_ENABLED	  IN  NUMBER
               )

   IS

   lc_i                   PLS_INTEGER;
   lc_j                   PLS_INTEGER;

   lv_worker_committed               NUMBER;
   lv_total_task_number              NUMBER;
   lv_task_num                       NUMBER;

   lv_task_not_completed             NUMBER := 0;

   lv_start_time       DATE;
   lv_process_time     NUMBER;

   EX_PIPE_RCV         EXCEPTION;
   EX_PIPE_SND         EXCEPTION;
   EX_PROCESS_TIME_OUT EXCEPTION;

   lv_pipe_ret_code    NUMBER;


   lv_errbuf           VARCHAR2(2048);
   lv_sql_stmt         VARCHAR2(32767);
   lv_retcode          NUMBER;

   lv_check_point      NUMBER := 0;

   lvs_request_id      NumTblTyp := NumTblTyp(0);

  -- lv_instance_type    NUMBER;
   return_status       BOOLEAN;


   ----- New variables for PREPLACE ----

   lv_param_rec_count   NUMBER;
   lv_coll_stat         NUMBER;
   v_current_user       NUMBER;
   var_debug            NUMBER := 0;

   prec                 MSC_UTIL.CollParamREC;


   ---- New Variables for a2m_dblinks for the bug fix 2320600 ---

   lv_sr_a2m            VARCHAR2(128);
   lv_sr_m2a            VARCHAR2(128);

   l_call_status      boolean;
   l_phase            varchar2(80);
   l_status           varchar2(80);
   l_dev_phase        varchar2(80);
   l_dev_status       varchar2(80);
   l_message          varchar2(1024);
   lv_request_id      NUMBER;

   -- agmcont
   lv_bom_sn_flag        number := MSC_UTIL.SYS_NO;
   lv_bor_sn_flag        number := MSC_UTIL.SYS_NO;
   lv_item_sn_flag       number := MSC_UTIL.SYS_NO;
   lv_oh_sn_flag         number := MSC_UTIL.SYS_NO;
   lv_usup_sn_flag       number := MSC_UTIL.SYS_NO;
   lv_udmd_sn_flag       number := MSC_UTIL.SYS_NO;
   lv_so_sn_flag         number := MSC_UTIL.SYS_NO;
   lv_fcst_sn_flag       number := MSC_UTIL.SYS_NO;
   lv_wip_sn_flag        number := MSC_UTIL.SYS_NO;
   lv_supcap_sn_flag     number := MSC_UTIL.SYS_NO;
   lv_po_sn_flag         number := MSC_UTIL.SYS_NO;
   lv_mds_sn_flag        number := MSC_UTIL.SYS_NO;
   /* CP-AUTO */
   lv_suprep_sn_flag     number := MSC_UTIL.SYS_NO;
   lv_mps_sn_flag        number := MSC_UTIL.SYS_NO;
   lv_nosnap_flag        number := MSC_UTIL.SYS_NO;
   lv_trip_sn_flag       number := MSC_UTIL.SYS_NO; -- DRP
   lv_src_time           DATE;

   lv_so_lrtype          number;

   lv_last_tgt_cont_coll_time date;

   lv_worker_prg         VARCHAR2(30);

   lv_table_name         VARCHAR2(100);

   lv_pjm_enabled	VARCHAR2(1);

   lv_inv_ctp_val NUMBER := NVL(FND_PROFILE.Value('INV_CTP'),0);

   BEGIN

   v_instance_id := pINSTANCE_ID;
   IF fnd_global.conc_request_id > 0 THEN
         v_cp_enabled:= MSC_UTIL.SYS_YES;
   ELSE
         v_cp_enabled:= MSC_UTIL.SYS_NO;
   END IF;

   -- set the value for v_req_data. Fix for 2351297--
   v_req_data := fnd_conc_global.request_data;

   -- if Refresh Snapshot was submitted as a sub request,
   -- Planning Data Pull should continue only if the sub request
   -- completed 'NORMAL' or with a 'WARNING', else the Planning Data
   -- Pull should error out as well. ( fix for 2548643)
   IF (v_req_data is not null) THEN
      lv_request_id:= to_number(v_req_data);
      l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( lv_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

       IF l_call_status=FALSE THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  l_message);
          FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_RS_ERROR');
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  FND_MESSAGE.GET );
          RETCODE := MSC_UTIL.G_ERROR;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
          IF SET_ST_STATUS( lv_errbuf, lv_retcode,
                                              pINSTANCE_ID, MSC_UTIL.G_ST_EMPTY) THEN
             COMMIT;
          END IF;
          RETURN;
       END IF;

       IF ((l_dev_phase='COMPLETE') AND (l_dev_status IN ('NORMAL','WARNING'))) THEN
          -- the Planning Data Pull should continue
          null;
       ELSE
          -- the Planning Data Pull should error out
          FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_RS_ERROR');
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  FND_MESSAGE.GET );
          RETCODE := MSC_UTIL.G_ERROR;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
          IF SET_ST_STATUS( lv_errbuf, lv_retcode,
                                              pINSTANCE_ID, MSC_UTIL.G_ST_EMPTY) THEN
             COMMIT;
          END IF;
          RETURN;
       END IF;

   END IF;



     --- PREPLACE CHANGE START ---
     prec.purge_ods_flag          :=  pOdsPURGEoption;
     prec.app_supp_cap_flag       :=  pAPPROV_SUPPLIER_CAP_ENABLED;
     prec.atp_rules_flag          :=  pATP_RULES_ENABLED;
     prec.bom_flag                := pBOM_ENABLED;
     prec.bor_flag                :=  pBOR_ENABLED;
     prec.calendar_flag           :=  pCALENDAR_ENABLED;
     prec.demand_class_flag       :=  pDEMAND_CLASS_ENABLED;
     prec.forecast_flag           := pFORECAST_ENABLED;
     prec.item_flag               := pITEM_ENABLED;
     prec.kpi_bis_flag            :=  pKPI_BIS_ENABLED;
     prec.mds_flag                := pMDS_ENABLED;
     prec.mps_flag                := pMPS_ENABLED;
     prec.oh_flag                 := pOH_ENABLED;
     prec.parameter_flag          :=  pPARAMETER_ENABLED;
     prec.planner_flag            :=  pPLANNER_ENABLED;
     prec.item_subst_flag         :=  pITEM_SUBST_ENABLED;
     prec.project_flag            :=  pPROJECT_ENABLED;
     prec.po_flag                 := pPUR_REQ_PO_ENABLED;
     prec.reserves_flag           := pRESERVES_HARD_ENABLED;
     prec.resource_nra_flag       := pRESOURCE_NRA_ENABLED;
     prec.saf_stock_flag          := pSafeStock_ENABLED;
     prec.sales_order_flag        := pSalesOrder_RTYPE;
     prec.source_hist_flag        := pSH_ENABLED;
     prec.po_receipts_flag        := pPO_RECEIPTS_ENABLED;
     prec.sourcing_rule_flag      := pSOURCING_ENABLED;
     prec.sub_inventory_flag      :=  pSUB_INV_ENABLED;
     prec.tp_customer_flag        := pTP_CUSTOMER_ENABLED;
     prec.tp_vendor_flag          := pTP_VENDOR_ENABLED;
     prec.unit_number_flag        :=  pUNIT_NO_ENABLED;
     prec.uom_flag                := pUOM_ENABLED;
     prec.user_supply_demand_flag :=  pUSER_SUPPLY_DEMAND;
     prec.wip_flag                := pWIP_ENABLED;
     prec.user_company_flag		  := pUSER_COMPANY_ENABLED;
     /* CP-ACK change starts */
     prec.supplier_response_flag  := pSUPPLIER_RESPONSE_ENABLED;
     /* CP-ACK change starts */
     prec.trip_flag               := pTRIP_ENABLED; -- DRP
     prec.ds_mode                 := v_DSMode;

     prec.org_group_flag          := pORG_GROUP;

     prec.sales_channel_flag      := pSALES_CHANNEL_ENABLED;
     prec.fiscal_calendar_flag    := pFISCAL_CALENDAR_ENABLED;
     prec.internal_repair_flag    := pINTERNAL_REPAIR_ENABLED; -- for bug 5909379
     prec.external_repair_flag    := pEXTERNAL_REPAIR_ENABLED; -- for bug 5935273
     prec.payback_demand_supply_flag      := pPAYBACK_DEMAND_SUPPLY_ENABLED;
     prec.currency_conversion_flag := pCURRENCY_CONVERSION_ENABLED; --bug # 6469722
     prec.delivery_details_flag := pDELIVERY_DETAILS_ENABLED; --bug # 6730983

     /* In case of Trading Partners both supplier and
     // and customer information will be loaded together.
     // HARD CODED - Vendor and customer CURRENTLY cannot be
     // separately refreshed during targeted/partial refreshment.
     */

     IF pTP_VENDOR_ENABLED = MSC_UTIL.SYS_YES THEN
        prec.tp_customer_flag := MSC_UTIL.SYS_YES;
     ELSIF pTP_CUSTOMER_ENABLED = MSC_UTIL.SYS_YES THEN
        prec.tp_vendor_flag := MSC_UTIL.SYS_YES;
     END IF;

          /* In case of  MDS, MPS both need to go together as they are dependent on the same
          // snapshot mrp_schedule_dates
          */

          IF prec.mds_flag = MSC_UTIL.SYS_YES THEN
             prec.mps_flag := MSC_UTIL.SYS_YES;
          ELSIF prec.mps_flag = MSC_UTIL.SYS_YES THEN
             prec.mds_flag := MSC_UTIL.SYS_YES;
          END IF;

          --Bug 8415844 We set prec.sales_order_flag to Yes in case of net change collection

          IF (pRTYPE = MSC_UTIL.G_INCREMENTAL) THEN
             prec.sales_order_flag := MSC_UTIL.SYS_YES;
          END IF;

--agmcont
      /* select the instance_type and database link */
      BEGIN
         SELECT DECODE( M2A_DBLINK,
                        NULL, NULL_DBLINK,
                        '@'||M2A_DBLINK),
                DECODE( A2M_DBLINK,
                        NULL, NULL_DBLINK,
                        A2M_DBLINK),
                        INSTANCE_TYPE,
		                    APPS_VER,
                        LAST_TGT_CONT_COLL_TIME,
                        INSTANCE_CODE
           INTO  v_dblink,
                 v_dest_a2m, -- bug fix for 2320600
                 v_instance_type,
		             v_apps_ver,
                 lv_last_tgt_cont_coll_time,
                 v_instance_code
           FROM MSC_APPS_INSTANCES
          WHERE INSTANCE_ID= pINSTANCE_ID;

     IF (v_apps_ver = MSC_UTIL.G_APPS120) THEN  --bug#5684183 (bcaru)
         prec.payback_demand_supply_flag   := MSC_UTIL.SYS_NO;
         --prec.currency_conversion_flag     := MSC_UTIL.SYS_NO;
         --prec.delivery_details_flag        := MSC_UTIL.SYS_NO;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Entity borrow payback is not supported for this source version');
         If pITEM_SUBST_ENABLED = MSC_UTIL.SYS_YES and pRTYPE = MSC_UTIL.G_INCREMENTAL Then
            prec.item_subst_flag         :=  MSC_UTIL.SYS_NO;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Netchange of Item substitutes is not supported for this source version');
         end if;

     END IF;

         /*If the source version is 11510, PO receipts is not supported*/
     IF (v_apps_ver < MSC_UTIL.G_APPS120) THEN  --bug#5684183 (bcaru)
         prec.po_receipts_flag        := MSC_UTIL.SYS_NO;
		 prec.internal_repair_flag    := MSC_UTIL.SYS_NO;
		 prec.external_repair_flag    := MSC_UTIL.SYS_NO;
		 --prec.payback_demand_supply_flag  := MSC_UTIL.SYS_NO;
 		 --prec.currency_conversion_flag	  := MSC_UTIL.SYS_NO;
		 prec.delivery_details_flag	      := MSC_UTIL.SYS_NO;
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Entities po_receipts, IRO,ERO are not supported for this source version');
		 If pITEM_SUBST_ENABLED = MSC_UTIL.SYS_YES and pRTYPE = MSC_UTIL.G_INCREMENTAL Then
            prec.item_subst_flag         :=  MSC_UTIL.SYS_NO;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Netchange of Item substitutes is not supported for this source version');
         end if;

     END IF;

         If pRTYPE = MSC_UTIL.G_COMPLETE Then
         IF v_apps_ver >= MSC_UTIL.G_APPS115 Then
         lv_sql_stmt:= 'update msc_apps_instances set LBJ_DETAILS = (select decode(to_number(FND_PROFILE.VALUE' || v_dblink || '(''WSM_CREATE_LBJ_COPY_ROUTING'')),1,1,2) from dual' || ' ) '
                || ' where instance_id = ' || pINSTANCE_ID ;
         ELSE
         lv_sql_stmt:= 'update msc_apps_instances set LBJ_DETAILS = 2 '
                || ' where instance_id = ' || pINSTANCE_ID ;
         END IF;

         EXECUTE IMMEDIATE lv_sql_stmt;

         commit;
         END If;


       --bug#6126924 (bcaru)
         UPDATE msc_coll_parameters
           SET COLLECTIONS_START_TIME = sysdate
           WHERE INSTANCE_ID = pINSTANCE_ID;


       -- To Check if the refresh type is partial(ie Targetted)
       -- the a2m_dblink on the destination should be in sync with
       -- the a2m_dblink on the source side.
        IF pRTYPE = MSC_UTIL.G_PARTIAL THEN

         IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN
            lv_table_name := 'MRP_AP_APPS_INSTANCES_ALL';
         ELSE
            lv_table_name := 'MRP_AP_APPS_INSTANCES';
         END IF;

        v_sql_stmt:=
                    'SELECT DECODE( mar.A2M_DBLINK,NULL,'''||NULL_DBLINK||''',mar.A2M_DBLINK),'
                  ||'       DECODE( mar.M2A_DBLINK,NULL,'''||NULL_DBLINK||''',''@''||mar.M2A_DBLINK)'
                  ||'  FROM  '||lv_table_name||v_dblink||' mar'
                  ||'  WHERE mar.INSTANCE_ID =  '||pINSTANCE_ID
                  ||'  AND   mar.INSTANCE_CODE = '''||v_instance_code||''''
                  ||'  AND   nvl(mar.A2M_DBLINK,'''||NULL_DBLINK||''') = '''||v_dest_a2m||'''';

        EXECUTE IMMEDIATE v_sql_stmt  INTO lv_sr_a2m,lv_sr_m2a ;


        -- If a2m_dblink or m2a_dblink on the source and destination
        -- are out of synchronization - error out.
          IF(( lv_sr_a2m <> v_dest_a2m) OR (lv_sr_m2a <> v_dblink)) THEN

              RETCODE := MSC_UTIL.G_ERROR;
              FND_MESSAGE.SET_NAME('MSC', 'MSC_COLL_A2MDBLINK_INVALID');
              ERRBUF:= FND_MESSAGE.GET;
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
              RETURN;
          END IF;


        END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            RETCODE := MSC_UTIL.G_ERROR;
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INVALID_INSTANCE_ID');
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID', pINSTANCE_ID);
            ERRBUF:= FND_MESSAGE.GET;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
            RETURN;
         WHEN OTHERS THEN

            RETCODE := MSC_UTIL.G_ERROR;
            ERRBUF  := SQLERRM;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
            RETURN;
      END;


     SELECT FND_GLOBAL.USER_ID
        INTO v_current_user
        FROM MSC_APPS_INSTANCES
       WHERE INSTANCE_ID= pINSTANCE_ID;

     -- To be called only at the first run.
     IF (v_req_data is null) THEN -- for the fix 2351297

         BEGIN
            v_sql_stmt:=
      	'SELECT PJM_UNIT_EFF.ENABLED'||v_dblink || ' FROM DUAL';

            EXECUTE IMMEDIATE v_sql_stmt
               INTO lv_pjm_enabled;
         EXCEPTION
            WHEN OTHERS THEN
               lv_pjm_enabled := NULL;
         END;

         UPDATE msc_apps_instances
         SET lrtype = DECODE ( pRTYPE, MSC_UTIL.G_COMPLETE,    'C',
                                       MSC_UTIL.G_INCREMENTAL, 'I',
                                       MSC_UTIL.G_PARTIAL,     'P',
                                       MSC_UTIL.G_CONT,        'T'),
             pjm_enabled = lv_pjm_enabled
         WHERE instance_id = pINSTANCE_ID;

      -- Indicate the data pull type in MSC_APPS_INSTANCES

      SELECT count(*)
        INTO lv_param_rec_count
        FROM msc_coll_parameters
       WHERE instance_id = pINSTANCE_ID;


     IF lv_param_rec_count = 0 THEN

        -- Initialize session information if no records
        -- found for the particular source_instance.
--agmcont

      INSERT INTO msc_coll_parameters
             (INSTANCE_ID,org_group,threshold, delete_ods_data, supplier_capacity, atp_rules,
              bom, bor, calendar_check, demand_class, forecast, item,
              kpi_targets_bis, mds, mps, oh, parameter, planners,
              item_substitutes, projects, po, reservations, nra, safety_stock,
              sales_order, sourcing_history, sourcing, sub_inventories,
              customer, supplier, unit_numbers, uom, user_supply_demand, wip, user_comp_association,trip ,po_receipts,
              supplier_response,sales_channel,fiscal_calendar,internal_repair,external_repair,LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,  -- for bug 5909379
	            ds_mode, payback_demand_supply, currency_conversion,delivery_details) -- bug # 6469722
      VALUES (pINSTANCE_ID,prec.org_group_flag,v_cont_coll_thresh, prec.purge_ods_flag, prec.app_supp_cap_flag,
              prec.atp_rules_flag, prec.bom_flag,
              prec.bor_flag, prec.calendar_flag,
              prec.demand_class_flag, prec.forecast_flag,
              prec.item_flag, prec.kpi_bis_flag,
              prec.mds_flag, prec.mps_flag,
              prec.oh_flag, prec.parameter_flag,
              prec.planner_flag,prec.item_subst_flag, prec.project_flag,
              prec.po_flag, prec.reserves_flag,
              prec.resource_nra_flag, prec.saf_stock_flag,
              prec.sales_order_flag, prec.source_hist_flag,
              prec.sourcing_rule_flag, prec.sub_inventory_flag,
              prec.tp_customer_flag, prec.tp_vendor_flag,
              prec.unit_number_flag, prec.uom_flag,
              prec.user_supply_demand_flag, prec.wip_flag, prec.user_company_flag,prec.trip_flag, -- DRP
              prec.po_receipts_flag, prec.supplier_response_flag,prec.sales_channel_flag,prec.fiscal_calendar_flag,prec.internal_repair_flag,prec.external_repair_flag, sysdate, v_current_user, sysdate, v_current_user,
	            prec.ds_mode,
              prec.payback_demand_supply_flag, prec.currency_conversion_flag,
              prec.delivery_details_flag); --bug # 6469722
-- for bug 5909379
     ELSE

         SELECT st_status
           INTO lv_coll_stat
           FROM msc_apps_instances
          WHERE instance_id = pINSTANCE_ID;

          IF lv_coll_stat = MSC_UTIL.G_ST_EMPTY THEN

             DELETE FROM msc_coll_parameters
              WHERE instance_id = pINSTANCE_ID;

             -- If collection status is NOT in progress then
             -- delete old collection session info and insert
             -- new collection session info.

             INSERT INTO msc_coll_parameters
                 (INSTANCE_ID,org_group,threshold, delete_ods_data, supplier_capacity, atp_rules,
                  bom, bor, calendar_check, demand_class, forecast, item,
                  kpi_targets_bis, mds, mps, oh, parameter, planners,
                  item_substitutes,projects, po, reservations, nra,
                  safety_stock, sales_order, sourcing_history, sourcing,
                  sub_inventories, customer, supplier, unit_numbers,
                  uom, user_supply_demand, wip, user_comp_association,trip,po_receipts,supplier_response,
                  sales_channel,fiscal_calendar,internal_repair , external_repair , -- for bug 5909379
                  LAST_UPDATE_DATE,LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
		              ds_mode,
                  payback_demand_supply, currency_conversion,delivery_details) -- bug # 6469722
             VALUES (pINSTANCE_ID,prec.org_group_flag,v_cont_coll_thresh, prec.purge_ods_flag,
                     prec.app_supp_cap_flag, prec.atp_rules_flag,
                     prec.bom_flag, prec.bor_flag, prec.calendar_flag,
                     prec.demand_class_flag, prec.forecast_flag,
                     prec.item_flag, prec.kpi_bis_flag,
                     prec.mds_flag, prec.mps_flag,
                     prec.oh_flag, prec.parameter_flag,
                     prec.planner_flag,prec.item_subst_flag, prec.project_flag,
                     prec.po_flag, prec.reserves_flag,
                     prec.resource_nra_flag, prec.saf_stock_flag,
                     prec.sales_order_flag, prec.source_hist_flag,
                     prec.sourcing_rule_flag, prec.sub_inventory_flag,
                     prec.tp_customer_flag, prec.tp_vendor_flag,
                     prec.unit_number_flag, prec.uom_flag,
                     prec.user_supply_demand_flag, prec.wip_flag, prec.user_company_flag,prec.trip_flag, -- DRP
                     prec.po_receipts_flag, prec.supplier_response_flag,
                     prec.sales_channel_flag,prec.fiscal_calendar_flag,prec.internal_repair_flag,prec.external_repair_flag,  -- for bug 5909379
                     sysdate, v_current_user, sysdate, v_current_user,
			               prec.ds_mode,
                     prec.payback_demand_supply_flag,prec.currency_conversion_flag,
                     prec.delivery_details_flag); --bug # 6469722

          -- ELSE EXIT WITH ERROR ????

          END IF;

       END IF;

     END IF; -- End of IF (v_req_data is null)

     msc_util.print_pull_params(pINSTANCE_ID);

     ---  PREPLACE CHANGE END  ---

      /* check if this procedure is launched as a concurrent program */
     -- IF fnd_global.conc_request_id > 0 THEN
     --    v_cp_enabled:= MSC_UTIL.SYS_YES;
     -- ELSE
     --    v_cp_enabled:= MSC_UTIL.SYS_NO;
     -- END IF;

      /* select the instance_type and database link */
/* --agmcont: move code below above, since we need dblink earlier
       BEGIN
         SELECT DECODE( M2A_DBLINK,
                        NULL, NULL_DBLINK,
                        '@'||M2A_DBLINK),
                DECODE( A2M_DBLINK,
                        NULL, NULL_DBLINK,
                        A2M_DBLINK),
                INSTANCE_TYPE
           INTO v_dblink,
                lv_dest_a2m, -- bug fix for 2320600
                v_instance_type
           FROM MSC_APPS_INSTANCES
          WHERE INSTANCE_ID= pINSTANCE_ID;

     -- To Check if the refresh type is partial(ie Targetted)
     -- the a2m_dblink on the destination should be in sync with
     -- the a2m_dblink on the source side.
     IF pRTYPE = MSC_UTIL.G_PARTIAL THEN
        v_sql_stmt:=
                    'SELECT DECODE( mar.A2M_DBLINK,NULL,'''||NULL_DBLINK||''',mar.A2M_DBLINK),'
                  ||'       DECODE( mar.M2A_DBLINK,NULL,'''||NULL_DBLINK||''',''@''||mar.M2A_DBLINK)'
                  ||'  FROM MRP_AP_APPS_INSTANCES'||v_dblink||' mar';

        EXECUTE IMMEDIATE v_sql_stmt INTO lv_sr_a2m,lv_sr_m2a;

     -- If a2m_dblink or m2a_dblink on the source and destination
     -- are out of synchronization - error out.
        IF(( lv_sr_a2m <> lv_dest_a2m) OR (lv_sr_m2a <> v_dblink)) THEN

            RETCODE := MSC_UTIL.G_ERROR;
            FND_MESSAGE.SET_NAME('MSC', 'MSC_COLL_A2MDBLINK_INVALID');
            ERRBUF:= FND_MESSAGE.GET;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
            RETURN;
        END IF;

   END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETCODE := MSC_UTIL.G_ERROR;
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INVALID_INSTANCE_ID');
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID', pINSTANCE_ID);
            ERRBUF:= FND_MESSAGE.GET;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
            RETURN;
         WHEN OTHERS THEN
            RETCODE := MSC_UTIL.G_ERROR;
            ERRBUF  := SQLERRM;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
            RETURN;

      END;
*/


      -- to initialize common global variables bug#5897346
      MSC_UTIL.INITIALIZE_COMMON_GLOBALS(pINSTANCE_ID);

      INITIALIZE_PULL_GLOBALS( pINSTANCE_ID);  -- Initializes Level 2 Global Variables used in Data Pull


    DBMS_PIPE.PURGE( v_pipe_task_que);
    DBMS_PIPE.PURGE( v_pipe_wm);
    DBMS_PIPE.PURGE( v_pipe_mw);
    DBMS_PIPE.PURGE( v_pipe_status);


    -- To be called only at the first run.
    IF (v_req_data is null) THEN -- for the fix 2351297

    /* set the status of the staging table to PULLING */
     lv_check_point:= 1;

     IF SET_ST_STATUS( lv_errbuf,
                                  lv_retcode,
                                  pINSTANCE_ID,
                                  MSC_UTIL.G_ST_PULLING,
                                  pSalesOrder_RTYPE) THEN

        COMMIT;

        lv_check_point:= 2;

     ELSE

        ROLLBACK;

        ERRBUF := lv_errbuf;
        RETCODE := lv_retcode;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);

        RETURN;

     END IF;

   ELSE

    lv_check_point := 2; -- for the second run, lv_check_point would be 2.

   END IF; -- if v_req_data is null --

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' before calling REFRESH_SNAPSHOT 1 ');
    -- Code fix for 2351297--
    IF v_cp_enabled= MSC_UTIL.SYS_YES THEN
       IF v_req_data is NULL THEN -- i.e. the first run of the program.

        IF REFRESH_SNAPSHOT( pINSTANCE_ID,pRTYPE)=FALSE THEN

           RETCODE:= MSC_UTIL.G_ERROR;

            IF SET_ST_STATUS( lv_errbuf,
                                       lv_retcode,
                                       pINSTANCE_ID,
                                       MSC_UTIL.G_ST_EMPTY) THEN
              COMMIT;
            END IF;

            IF lv_check_point =2 THEN
              UPDATE MSC_APPS_INSTANCES
              SET SO_TBL_STATUS = decode(pSalesOrder_RTYPE,MSC_UTIL.SYS_YES
                                              ,decode(pRTYPE,MSC_UTIL.G_COMPLETE,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),MSC_UTIL.G_PARTIAL,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),SO_TBL_STATUS),
                                              SO_TBL_STATUS)
              WHERE INSTANCE_ID= pINSTANCE_ID;
              COMMIT;
            END IF;

            RETURN;

        END IF; -- IF REFRESH_SNAPSHOT

        -- If its a single instance set up, the program should exit as the request is PAUSED.
        IF(v_dblink=NULL_DBLINK) THEN
             RETURN;
        END IF;

       END IF; -- IF v_req_data is NULL

    END IF;


   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' after calling REFRESH_SNAPSHOT  ');
    /* get the refresh number used in the last refresh snapshot process*/

   IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN

       lv_table_name := 'MRP_AP_APPS_INSTANCES_ALL';

    v_sql_stmt:=
      'SELECT mar.LRN, mar.validation_org_id'
    ||'  FROM  '||lv_table_name||v_dblink||' mar'
    ||'  WHERE mar.INSTANCE_ID =  ' ||pINSTANCE_ID
    ||'  AND   mar.INSTANCE_CODE = '''||v_instance_code||''''
    ||'  AND   nvl(mar.A2M_DBLINK, '''||NULL_DBLINK||''' ) = '''||v_dest_a2m||'''';

      EXECUTE IMMEDIATE v_sql_stmt  INTO v_crn, v_validation_org_id;

      UPDATE MSC_APPS_INSTANCES
      SET VALIDATION_ORG_ID = v_validation_org_id
      WHERE INSTANCE_ID = pINSTANCE_ID;

   ELSE

      lv_table_name := 'MRP_AP_APPS_INSTANCES';

     v_sql_stmt:=
      'SELECT mar.LRN '
    ||'  FROM  '||lv_table_name||v_dblink||' mar'
    ||'  WHERE mar.INSTANCE_ID =  ' ||pINSTANCE_ID
    ||'  AND   mar.INSTANCE_CODE = '''||v_instance_code||''''
    ||'  AND   nvl(mar.A2M_DBLINK, '''||NULL_DBLINK||''' ) = '''||v_dest_a2m||'''';

      EXECUTE IMMEDIATE v_sql_stmt  INTO v_crn ;

  END IF;

  -- agmcont

     if (v_is_cont_refresh = MSC_UTIL.SYS_YES) then
       -- determine w hat mode each entity should be refreshed in

        MSC_CL_CONT_COLL_FW.INIT_ENTITY_REFRESH_TYPE (v_cont_coll_thresh,
             v_cont_coll_freq,
             lv_last_tgt_cont_coll_time,
             v_dblink,
             pINSTANCE_ID,
	     prec,
	     pORG_GROUP,
             lv_bom_sn_flag,
             lv_bor_sn_flag,
             lv_item_sn_flag,
             lv_oh_sn_flag,
             lv_usup_sn_flag,
             lv_udmd_sn_flag,
             lv_so_sn_flag,
             lv_fcst_sn_flag,
             lv_wip_sn_flag,
             lv_supcap_sn_flag,
             lv_po_sn_flag,
             lv_mds_sn_flag,
             lv_mps_sn_flag,
             lv_nosnap_flag,
            /* CP-AUTO */
             lv_suprep_sn_flag,
             lv_trip_sn_flag );-- DRP

    /* The following will finally determine based on user settings whether the entity really needs
          to be refreshed and this will be inserted into msc_coll_parameters*/
        IF (prec.bom_flag = MSC_UTIL.SYS_YES) THEN
                prec.bom_sn_flag        := lv_bom_sn_flag;
	ELSE
         	prec.bom_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;
        IF (prec.bor_flag = MSC_UTIL.SYS_YES) THEN
                prec.bor_sn_flag        := lv_bor_sn_flag;
	ELSE
         	prec.bor_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;
        IF (prec.item_flag = MSC_UTIL.SYS_YES) THEN
                prec.item_sn_flag        := lv_item_sn_flag;
	ELSE
         	prec.item_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;
        IF (prec.oh_flag = MSC_UTIL.SYS_YES) THEN
                prec.oh_sn_flag        := lv_oh_sn_flag;
	ELSE
         	prec.oh_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;
        IF (prec.user_supply_demand_flag = MSC_UTIL.SYS_YES) THEN
                prec.usup_sn_flag        := lv_usup_sn_flag;
                prec.udmd_sn_flag        := lv_udmd_sn_flag;
	ELSE
         	prec.usup_sn_flag        := MSC_UTIL.SYS_NO;
         	prec.udmd_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;

        /* Sales Orders will always be collected in continous*/
        -- above is no longer true . ds change

       IF (prec.sales_order_flag = MSC_UTIL.SYS_YES) THEN
        prec.so_sn_flag        := lv_so_sn_flag;
       ELSE
	    prec.so_sn_flag    := MSC_UTIL.SYS_NO;
       END IF;

        IF (prec.forecast_flag = MSC_UTIL.SYS_YES) THEN
                prec.fcst_sn_flag        := lv_fcst_sn_flag;
	ELSE
         	prec.fcst_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;
        IF (prec.wip_flag = MSC_UTIL.SYS_YES) THEN
                prec.wip_sn_flag        := lv_wip_sn_flag;
	ELSE
         	prec.wip_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;
        IF (prec.app_supp_cap_flag = MSC_UTIL.SYS_YES or prec.app_supp_cap_flag =MSC_UTIL.ASL_YES_RETAIN_CP ) THEN
                prec.supcap_sn_flag        := lv_supcap_sn_flag;
	ELSE
         	prec.supcap_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;
        IF (prec.po_flag = MSC_UTIL.SYS_YES) THEN
                prec.po_sn_flag        := lv_po_sn_flag;
	ELSE
         	prec.po_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;

	IF (prec.trip_flag = MSC_UTIL.SYS_YES) THEN
          prec.trip_sn_flag        := lv_trip_sn_flag;
	ELSE
         	prec.trip_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;

        prec.nosnap_flag        := lv_nosnap_flag;

        /* CP-AUTO */
        prec.suprep_sn_flag     := lv_suprep_sn_flag;
        /* MPS and MDS need to go hand in hand because they are based on same snapshot*/
        IF (prec.mds_flag = MSC_UTIL.SYS_YES) or (prec.mps_flag = MSC_UTIL.SYS_YES)  THEN
                prec.mds_flag := MSC_UTIL.SYS_YES;
                prec.mps_flag := MSC_UTIL.SYS_YES;
                prec.mds_sn_flag        := lv_mds_sn_flag;
                prec.mps_sn_flag        := lv_mps_sn_flag;
	ELSE
         	prec.mds_sn_flag        := MSC_UTIL.SYS_NO;
		prec.mps_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;

        /*
        IF (prec.mps_flag = MSC_UTIL.SYS_YES) THEN
                prec.mps_sn_flag        := lv_mps_sn_flag;
	ELSE
		prec.mps_sn_flag        := MSC_UTIL.SYS_NO;
	END IF;
        */


   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '*****************************************************************');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'BOM refresh type         = '|| collection_type(prec.bom_flag,prec.bom_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'BOR refresh type         = '|| collection_type(prec.bor_flag,prec.bor_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'ITEM refresh type        = '|| collection_type(prec.item_flag,prec.item_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'ONHAND refresh type      = '|| collection_type(prec.oh_flag,prec.oh_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'USER SUP refresh type    = '|| collection_type(prec.user_supply_demand_flag,prec.usup_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'USER DMD refresh type    = '|| collection_type(prec.user_supply_demand_flag,prec.udmd_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'SALES ORDER refresh type = '|| collection_type(prec.sales_order_flag,prec.so_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'FORECAST refresh type    = '|| collection_type(prec.forecast_flag,prec.fcst_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'WIP refresh type         = '|| collection_type(prec.wip_flag,prec.wip_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'SUP CAP refresh type     = '|| collection_type(prec.app_supp_cap_flag,prec.supcap_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'PO type                  = '|| collection_type(prec.po_flag,prec.po_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'MDS  refresh type        = '|| collection_type(prec.mds_flag,prec.mds_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'MPS refresh type         = '|| collection_type(prec.mps_flag,prec.mps_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'SUPP RESP refresh type   = '|| collection_type(prec.supplier_response_flag, prec.suprep_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'TRIP refresh type        = '|| collection_type(prec.trip_flag,prec.trip_sn_flag) );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '*****************************************************************');
-- agmcont:


      UPDATE msc_coll_parameters
      SET  bom_sn_flag    = prec.bom_sn_flag,
           bor_sn_flag    = prec.bor_sn_flag,
           item_sn_flag   = prec.item_sn_flag,
           oh_sn_flag     = prec.oh_sn_flag,
           usup_sn_flag   = prec.usup_sn_flag,
           udmd_sn_flag   = prec.udmd_sn_flag,
           so_sn_flag     = prec.so_sn_flag,
           fcst_sn_flag   = prec.fcst_sn_flag,
           wip_sn_flag    = prec.wip_sn_flag,
           supcap_sn_flag = prec.supcap_sn_flag,
           po_sn_flag     = prec.po_sn_flag,
           mds_sn_flag    = prec.mds_sn_flag,
           mps_sn_flag    = prec.mps_sn_flag,
           --supplier_response = prec.supplier_response_flag,
           suprep_sn_flag    = prec.suprep_sn_flag,
           nosnap_flag       = prec.nosnap_flag,
           trip_sn_flag    = prec.trip_sn_flag
      WHERE INSTANCE_ID=pINSTANCE_ID;

      UPDATE msc_apps_instances
      SET SO_TBL_STATUS = decode (prec.so_sn_flag,MSC_UTIL.SYS_TGT,MSC_UTIL.SYS_NO,SO_TBL_STATUS)
      WHERE INSTANCE_ID=pINSTANCE_ID;

      COMMIT;

      end if;

    /* initialize the MSC_CL_PULL_WORKER package */
    /* get the total task number                 */
     INITIALIZE
                          ( v_refresh_id,
                            lv_total_task_number);

  -- process mfg only. if extracting items the call to populate the item
  -- table in the procees instance must be executed before anything else
  -- the other routines use this table to extract the data
  -- since the gmp's procedure doesn't support incremental refresh, the
  -- following process is valid only if it's a complete refresh.

  -- agmcont TODO

   --- PREPLACE CHANGE START ---
    /* IF (pRTYPE = MSC_UTIL.SYS_YES) THEN  -- complete refresh */

   IF ( (pRTYPE = MSC_UTIL.G_PARTIAL) OR (pRTYPE = MSC_UTIL.G_COMPLETE) OR
        (pRTYPE = MSC_UTIL.G_CONT  AND   prec.item_sn_flag = MSC_UTIL.SYS_TGT) ) THEN
                                   -- complete refresh or Partial refresh

   ---  PREPLACE CHANGE END  ---

   IF pITEM_ENABLED = MSC_UTIL.SYS_YES  and
      ( v_instance_type =  MSC_UTIL.G_INS_PROCESS OR
        v_instance_type = MSC_UTIL.G_INS_MIXED ) THEN

      IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
        return_status := TRUE;
      ELSE
        return_status := FALSE;
      END IF;

	/* OPM Team - OPM Inventory Convergence Project
	- remove the call to extract items
        gmp_bom_routing_pkg.extract_items (v_dblink,
                                           pINSTANCE_ID,
                                           sysdate,
                                           return_status);
	*/
	--bug 7328992 11i opm coll
	IF (v_apps_ver = MSC_UTIL.G_APPS115) THEN

                MSC_CL_GMP_UTILITY.extract_items(v_dblink,
                                           pINSTANCE_ID,
                                           sysdate,
                                           return_status);

    END IF;

   END IF;

   END IF;

  -- ============ Lauch the workers here ===============

     lvs_request_id.EXTEND( pTotalWorkerNum);

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' before calling workers  ');


     IF v_cp_enabled= MSC_UTIL.SYS_YES THEN

     FOR lc_i IN 1..pTotalWorkerNum LOOP

      if (v_is_cont_refresh = MSC_UTIL.SYS_YES) then   -- if continuous refresh
	 lv_worker_prg := 'MSCAUTPW';
      else
	 lv_worker_prg := 'MSCPDPW';
      end if;

       lvs_request_id(lc_i) := FND_REQUEST.SUBMIT_REQUEST(
                          'MSC',
			  lv_worker_prg,
                          NULL,  -- description
                          NULL,  -- start date
                          FALSE, -- TRUE,
                          FND_GLOBAL.CONC_REQUEST_ID,
                          pINSTANCE_ID,
                          pTIMEOUT,
                          pLANG,
                          pRTYPE,
                          v_refresh_id,
                          pAPPROV_SUPPLIER_CAP_ENABLED ,
                          pATP_RULES_ENABLED           ,
                          pBOM_ENABLED                 ,
                          pBOR_ENABLED                 ,
                          pCALENDAR_ENABLED            ,
                          pDEMAND_CLASS_ENABLED        ,
                          pITEM_SUBST_ENABLED          ,
                          pFORECAST_ENABLED            ,
                          pITEM_ENABLED                ,
                          pKPI_BIS_ENABLED             ,
                          pMDS_ENABLED                 ,
                          pMPS_ENABLED                 ,
                          pOH_ENABLED                  ,
                          pPARAMETER_ENABLED           ,
                          pPLANNER_ENABLED             ,
                          pPROJECT_ENABLED             ,
                          pPUR_REQ_PO_ENABLED          ,
                          pRESERVES_HARD_ENABLED       ,
                          pRESOURCE_NRA_ENABLED        ,
                          pSafeStock_ENABLED           ,
                          pSalesOrder_RTYPE            ,
                          pSH_ENABLED                  ,
                          pSOURCING_ENABLED            ,
                          pSUB_INV_ENABLED             ,
                          pTP_CUSTOMER_ENABLED         ,
                          pTP_VENDOR_ENABLED           ,
                          pUNIT_NO_ENABLED             ,
                          pUOM_ENABLED                 ,
                          pUSER_SUPPLY_DEMAND          ,
                          pWIP_ENABLED                 ,
                          pPO_RECEIPTS_ENABLED         ,
						  						pUSER_COMPANY_ENABLED        ,
						  						/* CP-ACK starts */
						  						pSUPPLIER_RESPONSE_ENABLED,
						  						/* CP-ACK ends */
						  						pTRIP_ENABLED                ); -- sub request

       COMMIT;


       ---- If the request_id=0 then
       ---- 1. Restore the status of the staging table.
       ---- 2. Send termination messages to the other launched workers.
       ---- 3. Return.

       IF lvs_request_id(lc_i)= 0 THEN

          FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_LAUNCH_WORKER_FAIL');
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

          ROLLBACK;

          IF SET_ST_STATUS( lv_errbuf,
                                       lv_retcode,
                                       pINSTANCE_ID,
                                       MSC_UTIL.G_ST_EMPTY) THEN
             COMMIT;
          END IF;

            IF lv_check_point =2 THEN
              UPDATE MSC_APPS_INSTANCES
              SET SO_TBL_STATUS = decode(pSalesOrder_RTYPE,MSC_UTIL.SYS_YES
                                              ,decode(pRTYPE,MSC_UTIL.G_COMPLETE,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),MSC_UTIL.G_PARTIAL,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),SO_TBL_STATUS),
                                              SO_TBL_STATUS)
              WHERE INSTANCE_ID= pINSTANCE_ID;
            END IF;

          FOR lc_j IN 1..pTotalWorkerNum LOOP

              DBMS_PIPE.PACK_MESSAGE( -1);

              IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
                 RAISE EX_PIPE_SND;
              END IF;

              FND_MESSAGE.SET_NAME('MSC','MSC_CL_SEND_WOR_END');
              FND_MESSAGE.SET_TOKEN('LCI',lc_j);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

          END LOOP;  -- lc_j

          FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_LAUNCH_WORKER_FAIL');
          ERRBUF:= FND_MESSAGE.GET;
          RETCODE := MSC_UTIL.G_ERROR;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);

          COMMIT;

          RETURN;

       ELSE

          FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_WORKER_REQUEST_ID');
          FND_MESSAGE.SET_TOKEN('REQUEST_ID', lvs_request_id(lc_i));
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

       END IF;

     END LOOP;  -- lc_i

     END IF;   -- CP_ENABLED;
  -- Updating the timestamp of pullworker
    BEGIN    -- For Bug 6126924
     v_sql_stmt:=
      'SELECT  sysdate  FROM  DUAL'||v_dblink;

      EXECUTE IMMEDIATE v_sql_stmt  INTO lv_src_time;

      UPDATE msc_coll_parameters
      SET PULL_WRKR_START_TIME = lv_src_time
      WHERE INSTANCE_ID = pINSTANCE_ID;
    END;

    msc_util.print_trace_file_name(FND_GLOBAL.CONC_REQUEST_ID);
  -- ============ Send Tasks to Task Que 'v_pipe_task_que' =============

     FOR lc_i IN 1..lv_total_task_number LOOP


       --- PREPLACE CHANGE START ---

	   --==========================================================
	   -- Send all tasks in case of complete refresh.
	   -- In case of Partial refresh and incremental refresh
	   -- use Q_PARTIAL_TASK API to decide which
	   -- task to be sent.
	   --==========================================================

       IF (pRTYPE = MSC_UTIL.G_COMPLETE)  AND
	  (prec.ds_mode <> MSC_UTIL.SYS_YES )  THEN 	/*ds_plan: change */
             -- maintain old behaviour for complete collection

          DBMS_PIPE.PACK_MESSAGE( lc_i);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ALL:Sending task number: '||lc_i||' to the queue');

          -- Only send the message if it has been packed.
          IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
               FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERROR_SEND_TSK');
               FND_MESSAGE.SET_TOKEN('LCI',lc_i);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

               RAISE EX_PIPE_SND;
          END IF;

          lv_task_not_completed := lv_task_not_completed + 1;

              FND_MESSAGE.SET_NAME('MSC','MSC_CL_TOTAL_TSK_ADDED');
              FND_MESSAGE.SET_TOKEN('lv_task_not_completed',lv_task_not_completed);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

       ELSIF Q_PARTIAL_TASK (pINSTANCE_ID, lc_i,
			prec, pRTYPE) THEN
-- agmcont:
            -- NCPerf: Do for incremental and targeted
            -- Only carry out Data Pull for specific objects

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Partial: PIPE to the DATA PULL - Task Number ' || TO_CHAR(lc_i));
          DBMS_PIPE.PACK_MESSAGE( lc_i);

          -- Only send the message if it has been packed.
          IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
               RAISE EX_PIPE_SND;
          END IF;
          lv_task_not_completed := lv_task_not_completed + 1;

       END IF;

       ---  PREPLACE CHANGE END  ---

     END LOOP;  -- lc_i

     DBMS_LOCK.SLEEP( 5);   -- initial estimated sleep time

     --lv_task_not_completed := lv_total_task_number;

     lv_start_time:= SYSDATE;

     FND_MESSAGE.SET_NAME('MSC','MSC_CL_TOTAL_TSK_ADDED');
     FND_MESSAGE.SET_TOKEN('lv_task_not_completed',lv_task_not_completed);
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

     LOOP

          var_debug := 0;
          EXIT WHEN lv_task_not_completed = 0;

          var_debug := 1;
          EXIT WHEN is_request_status_running <> MSC_UTIL.SYS_YES;

          var_debug := 2;
          EXIT WHEN is_worker_status_valid(lvs_request_id) <> MSC_UTIL.SYS_YES;

         lv_pipe_ret_code:= DBMS_PIPE.RECEIVE_MESSAGE( v_pipe_wm, PIPE_TIME_OUT);

         IF lv_pipe_ret_code=0 THEN

            DBMS_PIPE.UNPACK_MESSAGE( lv_task_num);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Unpacked Task Number: '||lv_task_num);

            IF lv_task_num>0 THEN   -- it's ok, the vlaue is the task number

               IF pANATBL_ENABLED= MSC_UTIL.SYS_YES AND
                  v_instance_type = MSC_UTIL.G_INS_DISCRETE THEN
                  ANALYZE_ST_TABLE( lv_task_num);
               END IF;

               lv_task_not_completed := lv_task_not_completed -1;
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Tasks remaining :'||lv_task_not_completed);

               IF lv_task_not_completed= 0 THEN
                  var_debug := 3;
                  EXIT;
               END IF;

            ELSE

               var_debug := 4;
               EXIT WHEN lv_task_num= UNRESOLVABLE_ERROR;

               DBMS_PIPE.PACK_MESSAGE( -lv_task_num);
                                   -- resend the task to the task que
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Re-sending the task number: '||lv_task_num ||' to the queue');

               IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
                  RAISE EX_PIPE_SND;
               END IF;

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Task number: '||lv_task_num||' re-sent to the pipe queue');

            END IF;

         ELSIF lv_pipe_ret_code<> 1 THEN
             FND_MESSAGE.SET_NAME('MSC','MSC_CL_RCV_PIPE_ERR');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

             RAISE EX_PIPE_RCV;   -- If the error is not time-out error
         END IF;

   -- ============= Check the execution time ==============

         SELECT (SYSDATE- lv_start_time) INTO lv_process_time FROM dual;

         IF lv_process_time > pTIMEOUT/1440.0 THEN RAISE EX_PROCESS_TIME_OUT;
         END IF;

     END LOOP;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '----------------------------------------------------');
     FND_MESSAGE.SET_NAME('MSC','MSC_CL_TSK_NOT_COMP');
     FND_MESSAGE.SET_TOKEN('lv_task_not_completed',lv_task_not_completed);
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

     IF (var_debug = 0) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDP_1');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 1) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDP_2');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 2) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDP_3');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 3) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_3');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 4) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_4');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     END IF;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '----------------------------------------------------');

     IF lv_task_not_completed > 0 THEN

        DBMS_PIPE.PURGE( v_pipe_task_que);

        FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_FAIL');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

        lv_task_num:= -1;

        ROLLBACK;

        ERRBUF:= FND_MESSAGE.GET;
        RETCODE := MSC_UTIL.G_ERROR;

     ELSE

        lv_task_num:= 0;

        FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_SUCCEED');
        ERRBUF:= FND_MESSAGE.GET;
        RETCODE := MSC_UTIL.G_SUCCESS;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, SQLERRM);

        lv_so_lrtype := pSalesOrder_RTYPE;

      /* If the Sales Order is Targeted in Continuous collections ,set the so_rtype = YES */
        IF (pRTYPE = MSC_UTIL.G_CONT) AND (prec.sales_order_flag = MSC_UTIL.SYS_YES) THEN
	       IF (prec.so_sn_flag = MSC_UTIL.SYS_TGT) THEN
		   lv_so_lrtype := MSC_UTIL.SYS_YES;
               END IF;
        END IF;

        FINAL( pINSTANCE_ID,
                                  pORG_GROUP,
                                  pRTYPE,
			          lv_so_lrtype,
                                  -- pSalesOrder_RTYPE,
                                  v_crn,
                                  pSOURCING_ENABLED,
                                  prec);

        IF pANATBL_ENABLED= MSC_UTIL.SYS_YES AND
           v_instance_type <> MSC_UTIL.G_INS_DISCRETE THEN
           ANALYZE_ALL_ST_TABLE;
        END IF;

     END IF;

 IF  (pRTYPE <> MSC_UTIL.G_CONT) then

  -- ======================== Inform workers to end the process ================

     FOR lc_i IN 1..pTotalWorkerNum LOOP

        FND_MESSAGE.SET_NAME('MSC','MSC_CL_SEND_WOR_END');
        FND_MESSAGE.SET_TOKEN('LCI',lc_i);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

        DBMS_PIPE.PACK_MESSAGE( lv_task_num);

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Sending task number: '||lv_task_num|| ' to the worker '||lc_i);

        IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
            RAISE EX_PIPE_SND;
        END IF;

     END LOOP;  -- lc_i

     IF lv_task_num=0 THEN

        IF SET_ST_STATUS( lv_errbuf, lv_retcode,
                                             pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
        COMMIT;
        END IF;

     ELSE
        IF SET_ST_STATUS( lv_errbuf, lv_retcode,
                                             pINSTANCE_ID, MSC_UTIL.G_ST_EMPTY) THEN
        COMMIT;
        END IF;

     END IF;


     lv_worker_committed:= 0;

     lv_start_time:= SYSDATE;

     LOOP

         lv_pipe_ret_code:= DBMS_PIPE.RECEIVE_MESSAGE( v_pipe_status,
                                                            PIPE_TIME_OUT);

         IF lv_pipe_ret_code=0 THEN

            lv_worker_committed:= lv_worker_committed+1;

            FND_MESSAGE.SET_NAME('MSC','MSC_CL_WORKER_COMMIT');
            FND_MESSAGE.SET_TOKEN('LV_WORKER_COMMITTED',lv_worker_committed);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            EXIT WHEN lv_worker_committed= pTotalWorkerNum;

         ELSIF lv_pipe_ret_code<> 1 THEN
             RAISE EX_PIPE_RCV;   -- If the error is not time-out error
         END IF;

         SELECT (SYSDATE- lv_start_time) INTO lv_process_time FROM dual;
      -- For bug:2210970 Removed this exit and added the function all_workers_completed to exit
      --   EXIT WHEN lv_process_time > 3.0/1440.0;

         IF (lv_process_time > 3.0/1440.0) AND (lv_worker_committed <> pTotalWorkerNum) THEN
                 EXIT WHEN all_workers_completed(lvs_request_id) = MSC_UTIL.SYS_YES;
         END IF;

     END LOOP;

     IF lv_worker_committed<> pTotalWorkerNum THEN

        FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_FAIL_TO_COMMIT');
        ERRBUF:= FND_MESSAGE.GET;
        RETCODE := MSC_UTIL.G_ERROR;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

        FND_MESSAGE.SET_NAME('MSC','MSC_CL_CHECK_PDP_LOG');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

         IF lv_check_point= 2 THEN
            IF SET_ST_STATUS( lv_errbuf, lv_retcode,
                                              pINSTANCE_ID, MSC_UTIL.G_ST_EMPTY) THEN
               COMMIT;
            END IF;

            UPDATE MSC_APPS_INSTANCES
            SET SO_TBL_STATUS = decode(pSalesOrder_RTYPE,MSC_UTIL.SYS_YES
                                              ,decode(pRTYPE,MSC_UTIL.G_COMPLETE,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),MSC_UTIL.G_PARTIAL,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),SO_TBL_STATUS),
                                              SO_TBL_STATUS)
            WHERE INSTANCE_ID= pINSTANCE_ID;

         END IF;

     END IF;

     COMMIT;
ELSE

/* -------------------  agmcont  ---------------------- */

  /* call ods load monitor for continuous collections */

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'launch ods load monitor');

  lv_task_num := START_ODS_LOAD;

  -- ======================== Inform workers to start the ODS Worker ================

     FOR lc_i IN 1..pTotalWorkerNum LOOP

        FND_MESSAGE.SET_NAME('MSC','MSC_CL_SEND_WOR_END');
        FND_MESSAGE.SET_TOKEN('LCI',lc_i);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

        DBMS_PIPE.PACK_MESSAGE( lv_task_num);

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Sending task number: '||lv_task_num|| ' to the worker '||lc_i);

        IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
            RAISE EX_PIPE_SND;
        END IF;

     END LOOP;  -- lc_i

        IF SET_ST_STATUS( lv_errbuf, lv_retcode,
                                             pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
        COMMIT;
        END IF;
   BEGIN

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '****************************************************');
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Planning ODS Load Monitor is Started.');
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '****************************************************');
        /*ds change */
	  IF MSC_CL_COLLECTION.LAUNCH_MONITOR_CONT(
                      ERRBUF                            ,
                      RETCODE                           ,
                      pINSTANCE_ID                      ,
                      pTIMEOUT                          ,-- minutes
                      pTotalWorkerNum                   ,
		      prec.ds_mode			)  THEN

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '****************************************************');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Planning ODS Load Monitor is Completed.');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '****************************************************');
	  ELSE
        	MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ERRBUF);
                RETCODE := MSC_UTIL.G_ERROR;
          END IF;

    EXCEPTION
	 WHEN OTHERS THEN
            ROLLBACK;
	    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
	    RAISE;
    END;

/* -------------------  agmcont  ---------------------- */

END IF;

   EXCEPTION

      WHEN EX_PROCESS_TIME_OUT THEN

         ROLLBACK;

        DBMS_PIPE.PURGE( v_pipe_task_que);

         IF lv_check_point= 2 THEN
            IF SET_ST_STATUS( lv_errbuf, lv_retcode,
                                              pINSTANCE_ID, MSC_UTIL.G_ST_EMPTY) THEN
               COMMIT;
            END IF;

            UPDATE MSC_APPS_INSTANCES
            SET SO_TBL_STATUS = decode(pSalesOrder_RTYPE,MSC_UTIL.SYS_YES
                                              ,decode(pRTYPE,MSC_UTIL.G_COMPLETE,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),MSC_UTIL.G_PARTIAL,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),SO_TBL_STATUS),
                                              SO_TBL_STATUS)
            WHERE INSTANCE_ID= pINSTANCE_ID;

            COMMIT;

         END IF;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_TIMEOUT');
         ERRBUF:= FND_MESSAGE.GET;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

         RETCODE := MSC_UTIL.G_ERROR;

      WHEN OTHERS THEN

         ROLLBACK;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

         IF lv_check_point= 2 THEN
            IF SET_ST_STATUS( lv_errbuf, lv_retcode,
                                              pINSTANCE_ID, MSC_UTIL.G_ST_EMPTY) THEN
               COMMIT;
            END IF;

            UPDATE MSC_APPS_INSTANCES
            SET SO_TBL_STATUS = decode(pSalesOrder_RTYPE,MSC_UTIL.SYS_YES
                                              ,decode(pRTYPE,MSC_UTIL.G_COMPLETE,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),MSC_UTIL.G_PARTIAL,decode(lv_inv_ctp_val,5,MSC_UTIL.SYS_YES,SO_TBL_STATUS),SO_TBL_STATUS),
                                              SO_TBL_STATUS)
            WHERE INSTANCE_ID= pINSTANCE_ID;

            COMMIT;

         END IF;

         ERRBUF  := SQLERRM;
         RETCODE := MSC_UTIL.G_ERROR;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error_Stack...');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, DBMS_UTILITY.FORMAT_ERROR_STACK );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error_Backtrace...' );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

   END LAUNCH_MONITOR;


/* ------------------------------------------------------------- */


-- agmcont
-- Entry point for continuous collections

   PROCEDURE LAUNCH_MONITOR_CONT(
               ERRBUF				 OUT NOCOPY VARCHAR2,
	       RETCODE				 OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pORG_GROUP                         IN  VARCHAR2,
               pTotalWorkerNum                    IN  NUMBER,
               pTIMEOUT                           IN  NUMBER, -- min
               pLANG                              IN  VARCHAR2  := NULL,
--               pOdsPURGEoption                    IN  NUMBER    := SYS_NO,
--               pRTYPE                             IN  NUMBER,
               pTHRESH                            IN  NUMBER,
               pFREQ                              IN  NUMBER,
               pANATBL_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOR_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pFORECAST_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMDS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER,
               /* CP-AUTO */
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTRIP_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pATP_RULES_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_SUBST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
	       pPO_RECEIPTS_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_NO,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSOURCING_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSUB_INV_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
	             pUSER_COMPANY_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES


               )
   is

  lv_SUPPLIER_RESPONSE_ENABLED        number := MSC_UTIL.SYS_NO;

   BEGIN


      v_is_cont_refresh := MSC_UTIL.SYS_YES;
      v_cont_coll_thresh := pTHRESH;
      v_cont_coll_freq := pFREQ;
      /* just call launch_monitor */

--MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'x1');
      LAUNCH_MONITOR(ERRBUF,
                     RETCODE,
                     pINSTANCE_ID,
                     pORG_GROUP,
                     pTotalWorkerNum,
                     pTIMEOUT,
                     pLANG,
                     MSC_UTIL.SYS_NO, --pOdsPURGEoption,
                     MSC_UTIL.G_CONT,    --pRTYPE,
                     pANATBL_ENABLED,
                     pAPPROV_SUPPLIER_CAP_ENABLED,
                     pATP_RULES_ENABLED,
                     pBOM_ENABLED,
                     pBOR_ENABLED,
                     pCALENDAR_ENABLED,
                     pDEMAND_CLASS_ENABLED,
                     pITEM_SUBST_ENABLED,
                     pFORECAST_ENABLED,
                     pITEM_ENABLED,
                     pKPI_BIS_ENABLED,
                     pMDS_ENABLED,
                     pMPS_ENABLED,
                     pOH_ENABLED,
                     pPARAMETER_ENABLED,
                     pPLANNER_ENABLED,
                     pPO_RECEIPTS_ENABLED,
                     pPROJECT_ENABLED,
                     pPUR_REQ_PO_ENABLED,
                     pRESERVES_HARD_ENABLED,
                     pRESOURCE_NRA_ENABLED,
                     pSafeStock_ENABLED,
                     pSalesOrder_RTYPE,
                     pSH_ENABLED,
                     pSOURCING_ENABLED,
                     pSUB_INV_ENABLED,
                     /* CP-AUTO */
                     pSUPPLIER_RESPONSE_ENABLED,
                     pTP_CUSTOMER_ENABLED,
                     pTP_VENDOR_ENABLED,
                     pTRIP_ENABLED,
                     pUNIT_NO_ENABLED,
                     pUOM_ENABLED,
	                   pUSER_COMPANY_ENABLED,
                     pUSER_SUPPLY_DEMAND,
                     pWIP_ENABLED

                    );


   end LAUNCH_MONITOR_CONT;

   PROCEDURE LAUNCH_WORKER_CONT(
               ERRBUF				 OUT NOCOPY VARCHAR2,
	       RETCODE				 OUT NOCOPY NUMBER,
               pMONITOR_REQUEST_ID                IN  NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pTIMEOUT                           IN  NUMBER,
               pLANG                              IN  VARCHAR2 := NULL,
               pRTYPE                             IN  NUMBER,
               pREFRESH_ID                        IN  NUMBER,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pATP_RULES_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOR_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_SUBST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pFORECAST_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMDS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER,
               pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSOURCING_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSUB_INV_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
	             pUSER_COMPANY_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               /* CP-ACK starts */
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_NO,
               /* CP-ACK ends */
               pTRIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPO_RECEIPTS_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_NO
               ) is
   BEGIN

               MSC_CL_PULL.LAUNCH_WORKER(
                          ERRBUF                       ,
	                  RETCODE                      ,
                          pMONITOR_REQUEST_ID          ,
                          pINSTANCE_ID                 ,
                          pTIMEOUT                     ,
                          pLANG                        ,
                          pRTYPE                       ,
                          pREFRESH_ID                  ,
                          pAPPROV_SUPPLIER_CAP_ENABLED ,
                          pATP_RULES_ENABLED           ,
                          pBOM_ENABLED                 ,
                          pBOR_ENABLED                 ,
                          pCALENDAR_ENABLED            ,
                          pDEMAND_CLASS_ENABLED        ,
                          pITEM_SUBST_ENABLED          ,
                          pFORECAST_ENABLED            ,
                          pITEM_ENABLED                ,
                          pKPI_BIS_ENABLED             ,
                          pMDS_ENABLED                 ,
                          pMPS_ENABLED                 ,
                          pOH_ENABLED                  ,
                          pPARAMETER_ENABLED           ,
                          pPLANNER_ENABLED             ,
                          pPROJECT_ENABLED             ,
                          pPUR_REQ_PO_ENABLED          ,
                          pRESERVES_HARD_ENABLED       ,
                          pRESOURCE_NRA_ENABLED        ,
                          pSafeStock_ENABLED           ,
                          pSalesOrder_RTYPE            ,
                          pSH_ENABLED                  ,
                          pSOURCING_ENABLED            ,
                          pSUB_INV_ENABLED             ,
                          pTP_CUSTOMER_ENABLED         ,
                          pTP_VENDOR_ENABLED           ,
                          pUNIT_NO_ENABLED             ,
                          pUOM_ENABLED                 ,
                          pUSER_SUPPLY_DEMAND          ,
                          pWIP_ENABLED                 ,
                          pPO_RECEIPTS_ENABLED         ,
			                    pUSER_COMPANY_ENABLED        ,
			                    pSUPPLIER_RESPONSE_ENABLED 	 ,
			                    pTRIP_ENABLED                 	 ); -- sub request


   END LAUNCH_WORKER_CONT;

   PROCEDURE LAUNCH_MONITOR_CONT_DET_SCH(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pORG_GROUP                         IN  VARCHAR2,
               pTotalWorkerNum                    IN  NUMBER,
               pTIMEOUT                           IN  NUMBER, -- min
               pLANG                              IN  VARCHAR2  := NULL,
               pTHRESH                            IN  NUMBER,
               pFREQ                              IN  NUMBER,
               pANATBL_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pBOR_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pFORECAST_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pMDS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER	:= MSC_UTIL.SYS_YES,
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pTRIP_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pATP_RULES_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pITEM_SUBST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSOURCING_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSUB_INV_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES
               --pUSER_COMPANY_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES
               )

   is
   BEGIN

      MSC_CL_PULL.LAUNCH_MONITOR(ERRBUF,
                     RETCODE,
                     pINSTANCE_ID,
                     pORG_GROUP,
                     pTotalWorkerNum,
                     pTIMEOUT,
                     pLANG,
                     MSC_UTIL.SYS_NO, 			--pOdsPURGEoption,
                     MSC_UTIL.G_CONT,    		--pRTYPE,
                     pANATBL_ENABLED,
                     pAPPROV_SUPPLIER_CAP_ENABLED,
                     MSC_UTIL.SYS_NO,			--pATP_RULES_ENABLED,
                     pBOM_ENABLED,
                     MSC_UTIL.SYS_NO,			--pBOR_ENABLED,
                     pCALENDAR_ENABLED,
                     pDEMAND_CLASS_ENABLED,
                     MSC_UTIL.SYS_NO,                    --pITEM_SUBST_ENABLED,
    		     MSC_UTIL.SYS_NO,                    --pFORECAST_ENABLED,
                     pITEM_ENABLED,
                     pKPI_BIS_ENABLED,
                     MSC_UTIL.SYS_NO,                    --pMDS_ENABLED,
                     pMPS_ENABLED,
                     pOH_ENABLED,
                     pPARAMETER_ENABLED,
                     pPLANNER_ENABLED,
                     MSC_UTIL.SYS_NO,                            --pPO_Receipts_ENABLED,
                     pPROJECT_ENABLED,
                     pPUR_REQ_PO_ENABLED,
                     pRESERVES_HARD_ENABLED,                    --pRESERVES_HARD_ENABLED,
                     pRESOURCE_NRA_ENABLED,
                     pSafeStock_ENABLED,
                     pSalesOrder_RTYPE,                    --pSalesOrder_RTYPE,
                     MSC_UTIL.SYS_NO,                    --pSH_ENABLED,
                     MSC_UTIL.SYS_NO,                    --pSOURCING_ENABLED,
                     MSC_UTIL.SYS_NO,                    --pSUB_INV_ENABLED,
                     pSUPPLIER_RESPONSE_ENABLED,
                     pTP_CUSTOMER_ENABLED,
                     pTP_VENDOR_ENABLED,
                     MSC_UTIL.SYS_NO,                    --pTRIP_ENABLED,
   		     pUNIT_NO_ENABLED,
                     pUOM_ENABLED,
                     MSC_UTIL.SYS_NO,                    --pUSER_COMPANY_ENABLED,
                     MSC_UTIL.SYS_NO,                    --pUSER_SUPPLY_DEMAND,
                     pWIP_ENABLED
                    );


   end LAUNCH_MONITOR_CONT_DET_SCH;

-- agmcont
/* ------------------------------------------------------------- */

   PROCEDURE DELETE_PROCESS(
                      ERRBUF				 OUT NOCOPY VARCHAR2,
	              RETCODE				 OUT NOCOPY NUMBER,
                      pINSTANCE_ID                       IN  NUMBER)
   IS
   BEGIN

      INITIALIZE_PULL_GLOBALS( pINSTANCE_ID);  -- Initializes Level 2 Global Variables used in Data Pull

         RETCODE := MSC_UTIL.G_SUCCESS;

         DBMS_PIPE.PACK_MESSAGE( UNRESOLVABLE_ERROR);

         IF DBMS_PIPE.SEND_MESSAGE( v_pipe_wm)<>0 THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_MSG_SEND_FAIL');
            FND_MESSAGE.SET_TOKEN('PIPE', v_pipe_wm);
            ERRBUF:= FND_MESSAGE.GET;

            RETCODE := MSC_UTIL.G_ERROR;

         END IF;

   END DELETE_PROCESS;

/* ds_plan: change start */
PROCEDURE LAUNCH_MONITOR_DET_SCH(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pORG_GROUP                         IN  VARCHAR2,
               pTotalWorkerNum                    IN  NUMBER,
               pTIMEOUT                           IN  NUMBER,
               pLANG                              IN  VARCHAR2  := NULL,
               pOdsPURGEoption                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pRTYPE                             IN  NUMBER,
               pANATBL_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pATP_RULES_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pBOR_ENABLED                     IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pITEM_SUBST_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pFORECAST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pMDS_ENABLED                     IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER,
               --pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSOURCING_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSUB_INV_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pTRIP_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pUSER_COMPANY_ENABLED            IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pUSER_SUPPLY_DEMAND              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES
               )
   is

  lv_SUPPLIER_RESPONSE_ENABLED        number := MSC_UTIL.SYS_NO;

   BEGIN
       v_DSMode := MSC_UTIL.SYS_YES;
       LAUNCH_MONITOR(ERRBUF,
                     RETCODE,
                     pINSTANCE_ID,
                     pORG_GROUP,
                     pTotalWorkerNum,
                     pTIMEOUT,
                     pLANG,
                     pOdsPURGEoption,
                     pRTYPE,
                     pANATBL_ENABLED,
                     pAPPROV_SUPPLIER_CAP_ENABLED,
                     MSC_UTIL.SYS_NO,				--pATP_RULES_ENABLED,
                     pBOM_ENABLED,
                     MSC_UTIL.SYS_NO,				--pBOR_ENABLED,
                     pCALENDAR_ENABLED,
                     pDEMAND_CLASS_ENABLED,
                     MSC_UTIL.SYS_NO,				--pITEM_SUBST_ENABLED,
                     MSC_UTIL.SYS_NO,				--pFORECAST_ENABLED,
                     pITEM_ENABLED,
                     pKPI_BIS_ENABLED,
                     MSC_UTIL.SYS_NO,				--pMDS_ENABLED,
                     pMPS_ENABLED,
                     pOH_ENABLED,
                     pPARAMETER_ENABLED,
                     pPLANNER_ENABLED,
                     MSC_UTIL.SYS_NO,                            --PO_Receipt_ENABLED,
                     pPROJECT_ENABLED,
                     pPUR_REQ_PO_ENABLED,
                     pRESERVES_HARD_ENABLED,            --pRESERVES_HARD_ENABLED,
	             pRESOURCE_NRA_ENABLED,
                     pSafeStock_ENABLED,
                     pSalesOrder_RTYPE,                            --pSalesOrder_RTYPE,
                     MSC_UTIL.SYS_NO,                            --pSH_ENABLED,
                     MSC_UTIL.SYS_NO,                            --pSOURCING_ENABLED,
                     MSC_UTIL.SYS_NO,                            --pSUB_INV_ENABLED,
                     pSUPPLIER_RESPONSE_ENABLED,
                     pTP_CUSTOMER_ENABLED,
                     pTP_VENDOR_ENABLED,
                     MSC_UTIL.SYS_NO,                            --pTRIP_ENABLED,
                     pUNIT_NO_ENABLED,
                     pUOM_ENABLED,
                     MSC_UTIL.SYS_NO,                            --pUSER_COMPANY_ENABLED,
                     MSC_UTIL.SYS_NO,                            --pUSER_SUPPLY_DEMAND,
                     pWIP_ENABLED
                    );

   end LAUNCH_MONITOR_DET_SCH;


   FUNCTION get_entity_lrn        (p_instance_id in NUMBER,
                                   p_task_num    in NUMBER,
                                   prec          in MSC_UTIL.CollParamREC,
                                   p_lrnn        in number,
                                   p_rtype       in number,
                                   p_org_group   in varchar2,
                                   p_entity_lrnn   out NOCOPY number)

   RETURN BOOLEAN AS
     lv_sup_cap_lrn number;
     lv_bom_lrn number;
     lv_bor_lrn number;
     lv_forecast_lrn number;
     lv_item_lrn number;
     lv_mds_lrn number;
     lv_mps_lrn number;
     lv_oh_lrn number;
     lv_rsv_lrn number;
     lv_po_lrn number;
     lv_so_lrn number;
     lv_usd_lrn number;
     lv_wip_lrn number;
     lv_nra_lrn number;
     lv_saf_stock_lrn number;
     lv_unit_no_lrn number;
     lv_uom_lrn number;
     lv_calendar_lrn number;
     lv_apps_lrn number;
     lv_trip_lrn number;
     lv_ero_lrn number;
     lv_iro_lrn number;  -- For Bug 6126698
   BEGIN

/* We will pass apps_lrn for the entity lrn, if it is NULL */

      select apps_lrn
      into lv_apps_lrn
      from msc_apps_instances
      where instance_id = p_instance_id;

      select min(nvl(supplier_capacity_lrn,lv_apps_lrn)),
             min(nvl(bom_lrn,lv_apps_lrn)),
             min(nvl(bor_lrn,lv_apps_lrn)),
             min(nvl(forecast_lrn,lv_apps_lrn)),
             min(nvl(item_lrn,lv_apps_lrn)),
             min(nvl(mds_lrn,lv_apps_lrn)),
             min(nvl(mps_lrn,lv_apps_lrn)),
             min(nvl(oh_lrn,lv_apps_lrn)),
             min(nvl(reservations_lrn,lv_apps_lrn)),
             min(nvl(LAST_SUCC_RES_REF_TIME, SYSDATE-365000)),
             min(nvl(po_lrn,lv_apps_lrn)),
             min(nvl(so_lrn,lv_apps_lrn)),
             min(nvl(user_supply_demand_lrn,lv_apps_lrn)),
             min(nvl(wip_lrn,lv_apps_lrn)),
             min(nvl(nra_lrn,lv_apps_lrn)),
             min(nvl(saf_stock_lrn,lv_apps_lrn)),
             min(nvl(unit_no_lrn,lv_apps_lrn)),
             min(nvl(uom_lrn,lv_apps_lrn)),
             min(nvl(calendar_lrn,lv_apps_lrn)),
             min(nvl(trip_lrn,lv_apps_lrn))
      into
             lv_sup_cap_lrn,
             lv_bom_lrn,
             lv_bor_lrn,
             lv_forecast_lrn,
             lv_item_lrn,
             lv_mds_lrn,
             lv_mps_lrn,
             lv_oh_lrn,
             lv_rsv_lrn,
             g_LAST_SUCC_RES_REF_TIME,
             lv_po_lrn,
             lv_so_lrn,
             lv_usd_lrn,
             lv_wip_lrn,
             lv_nra_lrn,
             lv_saf_stock_lrn,
             lv_unit_no_lrn,
             lv_uom_lrn,
             lv_calendar_lrn,
             lv_trip_lrn
       from   msc_instance_orgs
       WHERE ((p_org_group =MSC_UTIL.G_ALL_ORGANIZATIONS) or (org_group=p_org_group))
       AND   sr_instance_id = p_instance_id;
         /* Earlier sales order is alwasy collected in netchange even if sales order is not selected for continuous collection
            in srs */

          select       min(nvl(IRO_LRN,lv_apps_lrn)),
                       nvl(min(LAST_SUCC_IRO_REF_TIME), SYSDATE-365000)
                into
                       lv_iro_lrn,
                       g_last_succ_iro_ref_time
                 from   msc_instance_orgs
                 WHERE organization_type = 3
                 AND   sr_instance_id = p_instance_id;


          select       min(nvl(ERO_LRN,lv_apps_lrn))
                into
                       lv_ero_lrn
                        from   msc_instance_orgs
                 WHERE organization_type <> 3
                 AND   sr_instance_id = p_instance_id;

         IF (prec.sales_order_flag = MSC_UTIL.SYS_YES ) AND
		 p_task_num in (TASK_SALES_ORDER1,TASK_SALES_ORDER2,TASK_SALES_ORDER3,TASK_AHL) THEN
            if ((p_rtype <> MSC_UTIL.G_INCREMENTAL and p_rtype <> MSC_UTIL.G_CONT) ) then
                    -- do complete/targeted for this entity
                    p_entity_lrnn := -1;
                    RETURN TRUE;
             else
                   if (p_rtype = MSC_UTIL.G_CONT and prec.so_sn_flag = MSC_UTIL.SYS_TGT ) then
                       p_entity_lrnn := -1;
                       RETURN TRUE;
                   else
                       -- do netchange for this entity
                       p_entity_lrnn := lv_so_lrn;
                       RETURN TRUE;
                    end if;
             end if;
         END IF;


     IF (p_rtype <> MSC_UTIL.G_INCREMENTAL AND p_rtype <> MSC_UTIL.G_CONT ) then  /* Non-incremental refresh or Non-Continious Refresh*/
         -- do targeted/complete for this entity
                    p_entity_lrnn := -1;
                    RETURN TRUE;
     ELSE

        IF (prec.app_supp_cap_flag = MSC_UTIL.SYS_YES OR prec.app_supp_cap_flag =MSC_UTIL.ASL_YES_RETAIN_CP) AND p_task_num = TASK_SUPPLIER_CAPACITY THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_sup_cap_lrn;
                    RETURN TRUE;
        END IF;

     IF prec.bom_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_BOM)                  or
             (p_task_num = TASK_ROUTING)              or
             (p_task_num = TASK_OPER_NETWORKS)        or
             (p_task_num = TASK_ROUTING_OPERATIONS)   or
             (p_task_num = TASK_OPERATION_RES_SEQS)   or
             (p_task_num = TASK_OPERATION_RESOURCES)  or
             (p_task_num = TASK_RESOURCE)             or
             (p_task_num = TASK_RESOURCE_SETUP)       or  /* ds change */
             (p_task_num = TASK_RESOURCE_INSTANCE)    or  /* ds change */
                  -- Load Resources Data excluding those based on WIP_FLAG
             (p_task_num = TASK_OPERATION_COMPONENTS) or
             (p_task_num = TASK_PROCESS_EFFECTIVITY) )   THEN
              -- MSC_CL_BOM_PULL.LOAD_BOM,
              -- MSC_CL_ROUTING_PULL.LOAD_ROUTING,
              -- MSC_CL_WIP_PULL.LOAD_OPER_NETWORKS
              -- MSC_CL_ROUTING_PULL.LOAD_ROUTING_OPERATIONS
              -- MSC_CL_ROUTING_PULL.LOAD_OPERATION_RES_SEQS
              -- MSC_CL_ROUTING_PULL.LOAD_OPERATION_RESOURCES
              -- MSC_CL_ROUTING_PULL.LOAD_OPERATION_COMPONENTS
              -- MSC_CL_BOM_PULL.LOAD_PROCESS_EFFECTIVITY
              -- extract effectivities are performed

                    -- do net-change for this entity
                    p_entity_lrnn := lv_bom_lrn;
                    RETURN TRUE;

         END IF;
     END IF;

         IF prec.bor_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_BOR )  THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_bor_lrn;
                    RETURN TRUE;

         END IF;

         IF prec.forecast_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_LOAD_FORECAST)  THEN
               -- both of the ones below will get executed
               -- MSC_CL_DEMAND_PULL.LOAD_FORECASTS
               -- MSC_CL_DEMAND_PULL.LOAD_ITEM_FORECASTS

                    -- do net-change for this entity
                    p_entity_lrnn := lv_forecast_lrn;
                    RETURN TRUE;
         END IF;

      IF prec.item_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_CATEGORY)  or
             (p_task_num = TASK_ITEM1)     or
             (p_task_num = TASK_ITEM2)     or
             (p_task_num = TASK_ITEM3)     ) THEN

                    -- do net-change for this entity
                    p_entity_lrnn := lv_item_lrn;
                    RETURN TRUE;
         END IF;
      END IF;


         IF prec.mds_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_MDS_DEMAND)  THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_mds_lrn;
                    RETURN TRUE;
         END IF;


         IF prec.mps_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_MPS_SUPPLY) THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_mps_lrn;
                    RETURN TRUE;
         END IF;


         IF prec.oh_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_OH_SUPPLY) THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_oh_lrn;
                    RETURN TRUE;
         END IF;


   --      IF prec.po_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_PO_SUPPLY) THEN
                    -- do net-change for this entity
           IF prec.po_flag = MSC_UTIL.SYS_YES  THEN
	    				IF ( (p_task_num = TASK_PO_SUPPLY)	    or
	         					(p_task_num = TASK_PO_PO_SUPPLY)   or
                 		(p_task_num = TASK_PO_REQ_SUPPLY) )	THEN
                    p_entity_lrnn := lv_po_lrn;
                    RETURN TRUE;
               END IF ;
         END IF;


         IF prec.user_supply_demand_flag = MSC_UTIL.SYS_YES AND ((p_task_num = TASK_USER_SUPPLY) OR (p_task_num = TASK_USER_DEMAND))  THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_usd_lrn;
                    RETURN TRUE;
         END IF;


          -- FOR MSC_CL_WIP_PULL.LOAD_WIP_SUPPLY
          -- FOR MSC_CL_WIP_PULL.LOAD_WIP_DEMAND
         IF prec.wip_flag = MSC_UTIL.SYS_YES AND ( (p_task_num = TASK_WIP_SUPPLY) OR
       	 (p_task_num = TASK_WIP_DEMAND) OR (p_task_num = TASK_RESOURCE)
		OR (p_task_num = TASK_RESOURCE_INSTANCE)  ) THEN  /* ds change */
                    -- do net-change for this entity
                    p_entity_lrnn := lv_wip_lrn;
                    RETURN TRUE;
         END IF;


         IF (prec.calendar_flag = MSC_UTIL.SYS_YES OR prec.resource_nra_flag in (1,3)) AND ( p_task_num = TASK_CALENDAR_DATE )  THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_calendar_lrn;
                    RETURN TRUE;
         END IF;


         IF prec.reserves_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_HARD_RESERVATION )  THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_rsv_lrn;
                    RETURN TRUE;
         END IF;

         IF prec.saf_stock_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_SAFETY_STOCK )  THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_saf_stock_lrn;
                    RETURN TRUE;
         END IF;


         IF prec.unit_number_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_UNIT_NUMBER )  THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_unit_no_lrn;
                    RETURN TRUE;
         END IF;

         IF prec.uom_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_UOM )  THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_uom_lrn;
                    RETURN TRUE;
         END IF;


         IF (prec.mds_flag = MSC_UTIL.SYS_YES OR prec.mps_flag = MSC_UTIL.SYS_YES) AND (p_task_num = TASK_SCHEDULE) THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF prec.atp_rules_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_ATP_RULES) THEN            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF prec.demand_class_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_DEMAND_CLASS )  THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF prec.kpi_bis_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_BIS )  THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF prec.parameter_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_PARAMETER ) THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF prec.planner_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_PLANNERS ) THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF prec.project_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_PROJECT )  THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF prec.sourcing_rule_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_SOURCING ) THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF prec.sub_inventory_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_SUB_INVENTORY )  THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF (prec.tp_customer_flag = MSC_UTIL.SYS_YES) OR (prec.tp_vendor_flag = MSC_UTIL.SYS_YES) THEN
             IF (p_task_num = TASK_TRADING_PARTNER) OR (p_task_num = TASK_BUYER_CONTACT)  THEN
                 p_entity_lrnn := p_lrnn;
                 RETURN TRUE;
             END IF;
         END IF;

         IF prec.item_subst_flag = MSC_UTIL.SYS_YES AND ( p_task_num = TASK_ITEM_SUBSTITUTES )  THEN
            p_entity_lrnn := p_lrnn;
            RETURN TRUE;
         END IF;

         IF ( p_task_num = TASK_USER_COMPANY )  THEN
            IF (prec.user_company_flag = 2) OR (prec.user_company_flag = 3) THEN
               p_entity_lrnn := p_lrnn;
               RETURN TRUE;
            END IF;
         END IF;

         IF prec.trip_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_TRIP) THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_trip_lrn;
                    RETURN TRUE;
         END IF;

         IF prec.external_repair_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_ERO) THEN
                    -- do net-change for this entity
                    p_entity_lrnn := lv_ERO_lrn;
                    RETURN TRUE;
         END IF;

         IF prec.internal_repair_flag = MSC_UTIL.SYS_YES AND (p_task_num = TASK_IRO) THEN
                    -- do net-change for this entity  Bug 6126698

                    p_entity_lrnn := lv_IRO_lrn;

                    RETURN TRUE;
         END IF;
     END IF; /* Non-incremental refresh */



      RETURN FALSE;

   END get_entity_lrn;



   FUNCTION SET_ST_STATUS( ERRBUF                          OUT NOCOPY VARCHAR2,
                           RETCODE                         OUT NOCOPY NUMBER,
                           pINSTANCE_ID                    IN  NUMBER,
                           pST_STATUS                      IN  NUMBER,
                           pSO_RTYPE                       IN  NUMBER:= NULL)
            RETURN BOOLEAN
   IS

      lv_staging_table_status NUMBER;
      lv_instance_enabled NUMBER;
      lv_refresh_type NUMBER;
      lv_cont_coll_mode msc_coll_parameters.so_sn_flag%type;
      lv_inv_ctp_val NUMBER := NVL(FND_PROFILE.Value('INV_CTP'),0);
   BEGIN

---===================== PULLING ====================

   IF pST_STATUS= MSC_UTIL.G_ST_PULLING THEN

         SELECT mai.ENABLE_FLAG,
                mai.ST_STATUS,
                DECODE(mai.LRTYPE,'C',MSC_UTIL.G_COMPLETE,'P',MSC_UTIL.G_PARTIAL,'I',MSC_UTIL.G_INCREMENTAL,'T',MSC_UTIL.G_CONT)
           INTO lv_instance_enabled, lv_staging_table_status,lv_refresh_type
           FROM MSC_APPS_INSTANCES mai
          WHERE mai.INSTANCE_ID= pINSTANCE_ID
            FOR UPDATE;

         IF lv_instance_enabled= MSC_UTIL.SYS_YES THEN

            IF lv_staging_table_status= MSC_UTIL.G_ST_EMPTY THEN
								 IF lv_refresh_type = MSC_UTIL.G_CONT THEN
		                 BEGIN
		                   SELECT so_sn_flag
		                   INTO   lv_cont_coll_mode
		                   FROM   msc_coll_parameters
		                   WHERE  instance_id = pINSTANCE_ID;
		                 EXCEPTION
		                   WHEN others THEN
		                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);
		                    RETCODE := MSC_UTIL.G_ERROR;
		                    RETURN FALSE;
		                 END;
               END IF;
                 /* for bug:2605884 ,added the decode in updating so_tbl_status=2 if ODS ATP and complete
                                         refresh of the sales orders */
               UPDATE MSC_APPS_INSTANCES
                  SET ST_STATUS= MSC_UTIL.G_ST_PULLING,
                      SO_TBL_STATUS= DECODE( pSO_RTYPE,MSC_UTIL.SYS_YES
                                               ,decode(lv_refresh_type,MSC_UTIL.G_INCREMENTAL,MSC_UTIL.SYS_YES,
                                                       decode(lv_inv_ctp_val,5,decode(lv_refresh_type,
																															MSC_UTIL.G_CONT ,decode(lv_cont_coll_mode,
																					   													MSC_UTIL.SYS_INCR,MSC_UTIL.SYS_YES,
																					   													MSC_UTIL.SYS_NO,MSC_UTIL.SYS_YES,
																					   													MSC_UTIL.SYS_NO),
																															MSC_UTIL.SYS_NO),
																														MSC_UTIL.SYS_YES)
																										)
                                                      ,MSC_UTIL.SYS_YES),
                      LAST_UPDATE_DATE= SYSDATE,
                      LAST_UPDATED_BY= FND_GLOBAL.USER_ID,
                      REQUEST_ID=  FND_GLOBAL.CONC_REQUEST_ID
                WHERE INSTANCE_ID= pINSTANCE_ID;

               RETCODE := MSC_UTIL.G_SUCCESS;

                RETURN TRUE;

            ELSIF lv_staging_table_status= MSC_UTIL.G_ST_PULLING THEN

               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PULLING');
               ERRBUF:= FND_MESSAGE.GET;

            ELSIF lv_staging_table_status= MSC_UTIL.G_ST_READY THEN

               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_DATA_EXIST');
               ERRBUF:= FND_MESSAGE.GET;

            ELSIF lv_staging_table_status= MSC_UTIL.G_ST_COLLECTING THEN

               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_LOADING');
               ERRBUF:= FND_MESSAGE.GET;

            ELSIF lv_staging_table_status= MSC_UTIL.G_ST_PURGING THEN

               FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PURGING');
               ERRBUF:= FND_MESSAGE.GET;

            END IF;

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);
            RETCODE := MSC_UTIL.G_ERROR;
            RETURN FALSE;

         ELSE
           FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INSTANCE_INACTIVE');
           ERRBUF:= FND_MESSAGE.GET;
           RETCODE := MSC_UTIL.G_ERROR;
           RETURN FALSE;
         END IF;

---===================== EMPTY ====================
   ELSIF pST_STATUS= MSC_UTIL.G_ST_EMPTY THEN

         UPDATE MSC_APPS_INSTANCES
            SET ST_STATUS= MSC_UTIL.G_ST_EMPTY,
                LAST_UPDATE_DATE= SYSDATE,
                LAST_UPDATED_BY= FND_GLOBAL.USER_ID,
                REQUEST_ID=  FND_GLOBAL.CONC_REQUEST_ID
          WHERE INSTANCE_ID= pINSTANCE_ID;

       RETCODE:= MSC_UTIL.G_SUCCESS;
       RETURN TRUE;

---===================== READY ====================
   ELSIF pST_STATUS= MSC_UTIL.G_ST_READY THEN

       UPDATE MSC_APPS_INSTANCES
          SET ST_STATUS= MSC_UTIL.G_ST_READY,
              LAST_UPDATE_DATE= SYSDATE,
              LAST_UPDATED_BY= FND_GLOBAL.USER_ID,
              REQUEST_ID=  FND_GLOBAL.CONC_REQUEST_ID
        WHERE INSTANCE_ID= pINSTANCE_ID;

       RETCODE:= MSC_UTIL.G_SUCCESS;
       RETURN TRUE;

   END IF;


   END SET_ST_STATUS;


--============= Called by the monitor to get the TOTAL_TASK_NUMBER =========

   PROCEDURE INITIALIZE( pREFRESH_ID            OUT NOCOPY NUMBER,
                         pTOTAL_TASK_NUMBER     OUT NOCOPY NUMBER)
   IS
   BEGIN

   Select MSC_CL_REFRESH_S.NEXTVAL
     into pREFRESH_ID
     from dual;

   pTOTAL_TASK_NUMBER := TOTAL_TASK_NUMBER;

   END INITIALIZE;

   PROCEDURE FINAL( pINSTANCE_ID           IN  NUMBER,
                    pORG_GROUP             IN  VARCHAR2,
                    pRTYPE                 IN  NUMBER,
                    pSO_RTYPE              IN  NUMBER,
                    pLRN                   IN  NUMBER,
                    pSOURCING_ENABLED      IN  NUMBER,
                    prec                   IN  MSC_UTIL.CollParamREC)
   IS
   BEGIN

     --- PREPLACE CHANGE START ---
   /*
   UPDATE MSC_APPS_INSTANCES
      SET APPS_LRN= pLRN,
          LRTYPE=   DECODE( pRTYPE, MSC_UTIL.SYS_YES, 'C', 'I'),
          SO_LRTYPE= DECODE( pSO_RTYPE, MSC_UTIL.SYS_YES, 'C', 'I'),
          LRID=     msc_cl_refresh_s.currval,
          CLEANSED_FLAG= MSC_UTIL.SYS_NO,
          LAST_UPDATE_DATE= SYSDATE,
          LAST_UPDATED_BY= FND_GLOBAL.USER_ID,
          REQUEST_ID=  FND_GLOBAL.CONC_REQUEST_ID,
          LR_SOURCING_FLAG = pSOURCING_ENABLED
    WHERE INSTANCE_ID= pINSTANCE_ID;
    */

   UPDATE MSC_APPS_INSTANCES
      SET APPS_LRN= pLRN,
          LRTYPE=   DECODE( pRTYPE, MSC_UTIL.G_COMPLETE,    'C',
                                    MSC_UTIL.G_INCREMENTAL, 'I',
                                    MSC_UTIL.G_PARTIAL,     'P',
                                    MSC_UTIL.G_CONT,        'T'),
          SO_LRTYPE= DECODE( pSO_RTYPE, MSC_UTIL.SYS_YES, DECODE(pRTYPE,MSC_UTIL.G_INCREMENTAL,'I', 'C'), 'I'),
          LRID=     msc_cl_refresh_s.currval,
          CLEANSED_FLAG= MSC_UTIL.SYS_NO,
          LAST_UPDATE_DATE= SYSDATE,
          LAST_UPDATED_BY= FND_GLOBAL.USER_ID,
          REQUEST_ID=  FND_GLOBAL.CONC_REQUEST_ID,
          LR_SOURCING_FLAG = pSOURCING_ENABLED
    WHERE INSTANCE_ID= pINSTANCE_ID;

      ---  PREPLACE CHANGE END  ---

       UPDATE MSC_INSTANCE_ORGS
        SET  ITEM_LRN               = decode(prec.item_flag,1,pLRN,ITEM_LRN),
             SAF_STOCK_LRN          = decode(prec.saf_stock_flag, 1, pLRN, SAF_STOCK_LRN),
             UNIT_NO_LRN            = decode(prec.unit_number_flag,1,pLRN,UNIT_NO_LRN),
             UOM_LRN                = decode(prec.uom_flag,1,pLRN,UOM_LRN),
             BOM_LRN                = decode(prec.bom_flag,1,pLRN,BOM_LRN),
             BOR_LRN                = decode(prec.bor_flag ,1,pLRN,BOR_LRN ),
             FORECAST_LRN           = decode(prec.forecast_flag ,1,pLRN,FORECAST_LRN ),
             MDS_LRN                = decode(prec.mds_flag ,1,pLRN,MDS_LRN ),
             MPS_LRN                = decode(prec.mps_flag ,1,pLRN,MPS_LRN ),
             OH_LRN                 = decode(prec.oh_flag ,1,pLRN,OH_LRN ),
             PO_LRN                 = decode(prec.po_flag ,1,pLRN,PO_LRN ),
             WIP_LRN                = decode(prec.wip_flag ,1,pLRN,WIP_LRN ),
             RESERVATIONS_LRN       = decode(prec.reserves_flag ,1,pLRN,RESERVATIONS_LRN ),
             USER_SUPPLY_DEMAND_LRN = decode(prec.user_supply_demand_flag ,1,pLRN,USER_SUPPLY_DEMAND_LRN ),
             SUPPLIER_CAPACITY_LRN  = decode(prec.app_supp_cap_flag ,1,pLRN, 3,pLRN,SUPPLIER_CAPACITY_LRN ),
             TRIP_LRN               = decode(prec.trip_flag ,1,pLRN,TRIP_LRN ),
             LAST_SUCC_RES_REF_TIME = decode(prec.reserves_flag ,1,sysdate,g_LAST_SUCC_RES_REF_TIME),
             ORG_LRN                = pLRN
        WHERE SR_INSTANCE_ID= pINSTANCE_ID
        AND (pORG_GROUP= MSC_UTIL.G_ALL_ORGANIZATIONS OR ORG_GROUP=pORG_GROUP);

        IF (prec.external_repair_flag = MSC_UTIL.SYS_YES AND MSC_UTIL.G_COLLECT_SRP_DATA = 'Y') THEN
         UPDATE MSC_INSTANCE_ORGS
                SET  ERO_LRN               = decode(prec.external_repair_flag ,1,pLRN,ERO_LRN )
                WHERE SR_INSTANCE_ID= pINSTANCE_ID
                AND organization_type <> 3;
        END IF;

        IF (prec.internal_repair_flag = MSC_UTIL.SYS_YES AND MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' ) THEN
         UPDATE MSC_INSTANCE_ORGS
                SET
                     IRO_LRN                = decode(prec.internal_repair_flag ,1,pLRN,IRO_LRN ),
                     LAST_SUCC_IRO_REF_TIME = sysdate
                WHERE SR_INSTANCE_ID= pINSTANCE_ID
                AND organization_type = 3;
        END IF;

    IF ((prec.calendar_flag = MSC_UTIL.SYS_YES) OR (prec.resource_nra_flag in (1,3))) THEN
         UPDATE MSC_INSTANCE_ORGS
         SET CALENDAR_LRN= pLRN
         WHERE SR_INSTANCE_ID= pINSTANCE_ID
         AND (pORG_GROUP= MSC_UTIL.G_ALL_ORGANIZATIONS OR ORG_GROUP=pORG_GROUP);
    END IF;

/* Sales orders are not collected during Targeted and Continious Refresh if Sales Orders = No, so we will not update SO_LRN in this case */
    IF ( (pRTYPE = MSC_UTIL.G_PARTIAL OR pRTYPE = MSC_UTIL.G_CONT) AND prec.sales_order_flag = MSC_UTIL.SYS_NO ) THEN
        NULL;
    ELSE
       UPDATE MSC_INSTANCE_ORGS
       SET SO_LRN= pLRN
       WHERE SR_INSTANCE_ID= pINSTANCE_ID
       AND (pORG_GROUP= MSC_UTIL.G_ALL_ORGANIZATIONS OR ORG_GROUP=pORG_GROUP);
    END IF;


   END;

-- ============== PARTIAL REPLACEMENT METHODS ====================

   --- PREPLACE CHANGE START ---

/* NCPerf */
   FUNCTION Q_PARTIAL_TASK (p_instance_id NUMBER,
                            p_task_num    NUMBER,
                            prec          MSC_UTIL.CollParamREC,
			    p_collection_type NUMBER)

   RETURN BOOLEAN AS

   BEGIN

      IF (prec.app_supp_cap_flag = MSC_UTIL.ASL_YES or prec.app_supp_cap_flag = MSC_UTIL.ASL_YES_RETAIN_CP ) THEN
         IF p_task_num = TASK_SUPPLIER_CAPACITY THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.atp_rules_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_ATP_RULES THEN
            if (p_collection_type = MSC_UTIL.G_INCREMENTAL) then
               return false; -- NCP: do not call TASK_ATP_RULES in net change
            else
               RETURN TRUE;
            end if;
         END IF;
      END IF;

      IF prec.bom_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_BOM)                  or
             (p_task_num = TASK_ROUTING)              or
             (p_task_num = TASK_OPER_NETWORKS)        or
             (p_task_num = TASK_ROUTING_OPERATIONS)   or
             (p_task_num = TASK_OPERATION_RES_SEQS)   or
             (p_task_num = TASK_OPERATION_RESOURCES)  or
             (p_task_num = TASK_RESOURCE)             or
             (p_task_num = TASK_RESOURCE_SETUP)       or  /* ds change */
             (p_task_num = TASK_RESOURCE_INSTANCE)    or  /* ds change */
                   -- Load Resources Data excluding those based on WIP_FLAG
             (p_task_num = TASK_OPERATION_COMPONENTS) or
             (p_task_num = TASK_PROCESS_EFFECTIVITY) )   THEN
              -- MSC_CL_BOM_PULL.LOAD_BOM,
              -- MSC_CL_ROUTING_PULL.LOAD_ROUTING,
              -- MSC_CL_WIP_PULL.LOAD_OPER_NETWORKS
              -- MSC_CL_ROUTING_PULL.LOAD_ROUTING_OPERATIONS
              -- MSC_CL_ROUTING_PULL.LOAD_OPERATION_RES_SEQS
              -- MSC_CL_ROUTING_PULL.LOAD_OPERATION_RESOURCES
              -- MSC_CL_ROUTING_PULL.LOAD_OPERATION_COMPONENTS
              -- MSC_CL_BOM_PULL.LOAD_PROCESS_EFFECTIVITY
              -- extract effectivities are performed
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.bor_flag = MSC_UTIL.SYS_YES  THEN
         IF ( p_task_num = TASK_BOR )  THEN
            if (p_collection_type = MSC_UTIL.G_INCREMENTAL) then
               return false; -- NCP: do not call TASK_BOR in net change
            else
               RETURN TRUE;
            end if;
         END IF;
      END IF;

      IF prec.calendar_flag = MSC_UTIL.SYS_YES THEN
         IF ( p_task_num = TASK_CALENDAR_DATE )  THEN
            if (p_collection_type = MSC_UTIL.G_INCREMENTAL) then
               return false; -- NCP: do not call TASK_CALENDAR_DATE in net change
            else
               RETURN TRUE;
            end if;
         END IF;
      END IF;

      IF prec.demand_class_flag = MSC_UTIL.SYS_YES THEN
         IF ( p_task_num = TASK_DEMAND_CLASS )  THEN
            if (p_collection_type = MSC_UTIL.G_INCREMENTAL) then
               return false; -- NCP: do not call TASK_DEMAND_CLASS in net change
            else
               RETURN TRUE;
            end if;
         END IF;
      END IF;

      IF prec.forecast_flag = MSC_UTIL.SYS_YES THEN
         IF (p_task_num = TASK_LOAD_FORECAST)  THEN
               -- both of the ones below will get executed
               -- MSC_CL_DEMAND_PULL.LOAD_FORECASTS
               -- MSC_CL_DEMAND_PULL.LOAD_ITEM_FORECASTS
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.item_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_CATEGORY)  or
             (p_task_num = TASK_ITEM1)     or
             (p_task_num = TASK_ITEM2)     or
             (p_task_num = TASK_ITEM3)     or
             (p_task_num = TASK_ABC_CLASSES) )THEN

            RETURN TRUE;
         END IF;
      END IF;

      -- TASK_BUYER_CONTACT now moved to combine
      -- with TRADING_PARTNER since ODS LOAD
      -- loads contact information through MSC_CL_SETUP_PULL.LOAD_TRADING_PARTNER.

      IF prec.kpi_bis_flag = MSC_UTIL.SYS_YES THEN
         IF ( p_task_num = TASK_BIS )  THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.mds_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_MDS_DEMAND) OR
             (p_task_num = TASK_SCHEDULE) ) THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.mps_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_MPS_SUPPLY) OR
             (p_task_num = TASK_SCHEDULE) ) THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.oh_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_OH_SUPPLY THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.parameter_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_PARAMETER THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.planner_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_PLANNERS THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.project_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_PROJECT THEN
            if (p_collection_type = MSC_UTIL.G_INCREMENTAL) then
               return false; -- NCP: do not call TASK_PROJECT in net change
            else
               RETURN TRUE;
            end if;
         END IF;
      END IF;

      IF prec.po_flag = MSC_UTIL.SYS_YES THEN
        -- IF p_task_num = TASK_PO_SUPPLY THEN
        IF ((p_task_num = TASK_PO_SUPPLY)	or
             (p_task_num = TASK_PO_PO_SUPPLY)   or
             (p_task_num = TASK_PO_REQ_SUPPLY))	THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.reserves_flag = MSC_UTIL.SYS_YES  THEN
         IF p_task_num = TASK_HARD_RESERVATION THEN
              -- FOR MSC_CL_DEMAND_PULL.LOAD_HARD_RESERVATION
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.resource_nra_flag in (1,3) THEN
         IF p_task_num = TASK_CALENDAR_DATE THEN
              -- Can we create another task TASK_NRA??
              -- Will call MSC_CL_SETUP_PULL.LOAD_TRADING_PARTNER
              -- and also will carry out NRA calculation
              -- using gmp_calendar_pkg.populate_rsrc_cal
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.saf_stock_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_SAFETY_STOCK THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.sales_order_flag = MSC_UTIL.SYS_YES THEN
         IF (p_task_num = TASK_SALES_ORDER1
            OR p_task_num = TASK_SALES_ORDER2
            OR p_task_num = TASK_SALES_ORDER3
            OR p_task_num = TASK_AHL) THEN
            RETURN TRUE;
         END IF;
      END IF;

      --=======================================
      -- NCPerf.
      -- Sales Orders need to be collected in
      -- case of Net change collections even if
      -- Sales Order parameter is set to NO
      -- ======================================
     -- commenting this code as above comment is no longer true
    /*
      IF ((p_task_num = TASK_SALES_ORDER1
	   OR p_task_num = TASK_SALES_ORDER2
	   OR p_task_num = TASK_SALES_ORDER3
       OR p_task_num = TASK_AHL) and
          (p_collection_type = MSC_UTIL.G_INCREMENTAL)) THEN
	     RETURN TRUE;
      END IF;
   */

      IF prec.sourcing_rule_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_SOURCING THEN
            if (p_collection_type = MSC_UTIL.G_INCREMENTAL) then
               return false; -- NCP: do not call TASK_SOURCING in net change
            else
               RETURN TRUE;
            end if;
              -- FOR MSC_CL_OTHER_PULL.LOAD_SOURCING
         END IF;
      END IF;

      -- NOTE : There is no procedure that deals
      -- with Sourcing History in Data Pull,
      -- which completely belongs to ODS Load.

      IF prec.sub_inventory_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_SUB_INVENTORY THEN
            if (p_collection_type = MSC_UTIL.G_INCREMENTAL) then
               return false; -- NCP: do not call TASK_SUB_INVENTORY in net change
            else
               RETURN TRUE;
            end if;
         END IF;
      END IF;

      -- TASK_BUYER_CONTACT now moved to combine
      -- with TRADING_PARTNER since ODS LOAD
      -- loads contact information through MSC_CL_SETUP_PULL.LOAD_TRADING_PARTNER.

      IF prec.tp_customer_flag = MSC_UTIL.SYS_YES OR prec.tp_vendor_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_TRADING_PARTNER) and
             (p_collection_type = MSC_UTIL.G_INCREMENTAL)) then
             return false;  -- NCP: do not call TASK_TRADING_PARTNER in net change
         ELSIF ((p_task_num = TASK_TRADING_PARTNER) or
                (p_task_num = TASK_BUYER_CONTACT) ) THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.unit_number_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_UNIT_NUMBER THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.uom_flag = MSC_UTIL.SYS_YES THEN
         IF p_task_num = TASK_UOM THEN
            if (p_collection_type = MSC_UTIL.G_INCREMENTAL) then
               return false; -- NCP: do not call TASK_UOM in net change
            else
               RETURN TRUE;
            end if;
         END IF;
      END IF;

       -- Added this task for Prod subst in Targeted Collections  --
      IF prec.item_subst_flag = MSC_UTIL.SYS_YES THEN
          IF p_task_num = TASK_ITEM_SUBSTITUTES THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.user_supply_demand_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_USER_SUPPLY) OR
             (p_task_num = TASK_USER_DEMAND))  THEN
            RETURN TRUE;
         END IF;
      END IF;

      IF prec.wip_flag = MSC_UTIL.SYS_YES THEN
         IF ((p_task_num = TASK_WIP_SUPPLY)   or
             (p_task_num = TASK_WIP_DEMAND)   or
             (p_task_num = TASK_RESOURCE_INSTANCE)   or  /* ds change */
             (p_task_num = TASK_RESOURCE) ) THEN
                   -- Load Resources Data excluding those based on BOM_FLAG
                   -- FOR MSC_CL_WIP_PULL.LOAD_WIP_SUPPLY
                   -- FOR MSC_CL_WIP_PULL.LOAD_WIP_DEMAND
                   -- FOR MSC_CL_BOM_PULL.LOAD_RESOURCE
            RETURN TRUE;
         END IF;
      END IF;

      /* SCE Change starts */
      IF ((prec.user_company_flag = 2) OR
		  (prec.user_company_flag = 3)) THEN
          IF p_task_num = TASK_USER_COMPANY THEN
            RETURN TRUE;
         END IF;
      END IF;
      /* SCE Change ends */

      /* CP-ACK starts */
      IF (prec.supplier_response_flag = MSC_UTIL.SYS_YES) THEN
          IF (p_task_num = TASK_SUPPLIER_RESPONSE) THEN
              RETURN TRUE;
          END IF;
      END IF;
      /* CP-ACK ends */

      IF (prec.trip_flag = MSC_UTIL.SYS_YES) THEN
          IF (p_task_num = TASK_TRIP) THEN
              RETURN TRUE;
          END IF;
      END IF;

      IF (prec.sales_channel_flag = MSC_UTIL.SYS_YES) THEN
          IF (p_task_num = TASK_SALES_CHANNEL) THEN
            RETURN TRUE;
          END IF;
      END IF;

      IF (prec.fiscal_calendar_flag = MSC_UTIL.SYS_YES) THEN
          IF (p_task_num = TASK_FISCAL_CALENDAR) THEN
            RETURN TRUE;
          END IF;
      END IF;

      IF prec.internal_repair_flag = MSC_UTIL.SYS_YES THEN
       IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y') THEN
         IF ( (p_task_num = TASK_IRO_DEMAND) or
              (p_task_num = TASK_IRO )) THEN      /*changes for executing repair order load Bug# 5909379*/
          RETURN TRUE;
         END IF;
        END IF;
      END IF;

      IF prec.external_repair_flag = MSC_UTIL.SYS_YES THEN
       IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y') THEN
         IF ( (p_task_num = TASK_ERO_DEMAND) or
              (p_task_num = TASK_ERO )) THEN      /*changes for executing repair order load Bug# 5909379*/
          RETURN TRUE;
         END IF;
        END IF;
      END IF;
      IF (prec.payback_demand_supply_flag = MSC_UTIL.SYS_YES) THEN
          IF (p_task_num = TASK_PAYBACK_DEMAND_SUPPLY) THEN
            RETURN TRUE;
          END IF;
      END IF;
      -- for bug # 6469722
      IF (prec.currency_conversion_flag = MSC_UTIL.SYS_YES) THEN
          IF (p_task_num = TASK_CURRENCY_CONVERSION) THEN
            RETURN TRUE;
          END IF;
      END IF;
 -- for bug # 6730983
      IF (prec.delivery_details_flag = MSC_UTIL.SYS_YES) THEN
          IF (p_task_num = TASK_DELIVERY_DETAILS) THEN
            RETURN TRUE;
          END IF;
      END IF;
      RETURN FALSE;

   END Q_PARTIAL_TASK;

   ---  PREPLACE CHANGE END  ---

-- agmcont


-- ===============================================================

   PROCEDURE EXECUTE_TASK(
                      pSTATUS                            OUT NOCOPY NUMBER,
                      pTASKNUM                           IN  NUMBER,
                      pIID                               IN  NUMBER,
                      pLRN                               IN  NUMBER,
                      pREFRESH_ID                        IN  NUMBER,
 ----- PROFILE OPTION, ENVIRONMENT, INSTALLATION -----------------------
                      pSO_SHIP_ARRIVE_VALUE              IN  NUMBER,
                      pMPS_CONSUME_PROFILE_VALUE         IN  NUMBER,
                      pSPREAD_LOAD                       IN  NUMBER,
                      pHOUR_UOM                          IN  VARCHAR2,
                      pLANG                              IN  VARCHAR2,
                      pOE_INSTALL                        IN  VARCHAR2,
 ----- MSC PROFILE OPTION ----------------------------------------------
                      pMSO_ITEM_DMD_PENALTY              IN  NUMBER,
                      pMSO_ITEM_CAP_PENALTY              IN  NUMBER,
                      pMSO_ORG_DMD_PENALTY               IN  NUMBER,
                      pMSO_ORG_ITEM_PENALTY              IN  NUMBER,
                      pMSO_ORG_RES_PENALTY               IN  NUMBER,
                      pMSO_ORG_TRSP_PENALTY              IN  NUMBER,
                      pMSC_AGGREG_RES_NAME               IN  NUMBER,
                      pMSO_RES_PENALTY                   IN  NUMBER,
                      pMSO_SUP_CAP_PENALTY               IN  NUMBER,
                      pMSC_BOM_SUBST_PRIORITY            IN  NUMBER,
                      pMSO_TRSP_PENALTY                  IN  NUMBER,
                      pMSC_ALT_BOM_COST                  IN  NUMBER,
                      pMSO_FCST_PENALTY                  IN  NUMBER,
                      pMSO_SO_PENALTY                    IN  NUMBER,
                      pMSC_ALT_OP_RES                    IN  NUMBER,
                      pMSC_ALT_RES_PRIORITY              IN  NUMBER,
                      pMSC_BATCHABLE_FLAG               IN  NUMBER,
                      pMSC_BATCHING_WINDOW              IN  NUMBER,
                      pMSC_MIN_CAPACITY                  IN  NUMBER,
                      pMSC_MAX_CAPACITY                  IN  NUMBER,
                      pMSC_UNIT_OF_MEASURE              IN  NUMBER,
                      pMSC_SIMUL_RES_SEQ                 IN  NUMBER,
                      pMRP_BIS_AV_DISCOUNT               IN  NUMBER,
                      pMRP_BIS_PRICE_LIST                IN  NUMBER,
                      pMSC_DMD_PRIORITY_FLEX_NUM         IN  NUMBER,
                      pMSC_FCST_PRIORITY_FLEX_NUM         IN  NUMBER,
 ----- FLAGS -----------------------------------------------------------
                      pITEM_ENABLED                      IN  NUMBER,
                      pVENDOR_ENABLED                    IN  NUMBER,
                      pCUSTOMER_ENABLED                  IN  NUMBER,
                      pBOM_ENABLED                       IN  NUMBER,
                      pHARD_RESRVS_ENABLED               IN  NUMBER,
                      pSOURCING_ENABLED                  IN  NUMBER,
                      pWIP_ENABLED                       IN  NUMBER,
                      pPO_RECEIPTS_ENABLED               IN  NUMBER,
                      pSS_ENABLED                        IN  NUMBER,
                      pPO_ENABLED                        IN  NUMBER,
                      pITEM_SUBST_ENABLED                IN  NUMBER,
                      pOH_ENABLED                        IN  NUMBER,
                      pSUPPLIER_CAP_ENABLED              IN  NUMBER,
                      pUOM_ENABLED                       IN  NUMBER,
                      pMDS_ENABLED                       IN  NUMBER,
                      pFORECAST_ENABLED                  IN  NUMBER,
                      pMPS_ENABLED                       IN  NUMBER,
                      pNRA_ENABLED                       IN  NUMBER,
                      pSH_ENABLED                        IN  NUMBER,
                      pUSER_COMPANY_ENABLED              IN  NUMBER,
                      /* CP-ACK starts */
                      pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER,
                      /* CP-ACK ends */
                      pTRIP_ENABLED                      IN  NUMBER,
                      prec                               in  MSC_UTIL.CollParamREC
                      )

   IS

   lv_task_start_time    DATE;


   -- Added for Process MFG
   lv_return_status      BOOLEAN;
   lv_refresh_type        NUMBER;
   lv_entity_lrn          NUMBER;
   lv_sql_stmt           VARCHAR2(32767);
   lv_ps_ver             NUMBER;

   lv_nra_enabled_r11             NUMBER;

   EX_SERIALIZATION_ERROR EXCEPTION;

   PRAGMA EXCEPTION_INIT(EX_SERIALIZATION_ERROR, -8177);

   -- agmcont
   lv_cont_lrn number;

   BEGIN


      IF fnd_global.conc_request_id > 0 THEN
         v_cp_enabled:= MSC_UTIL.SYS_YES;
      ELSE
         v_cp_enabled:= MSC_UTIL.SYS_NO;
      END IF;

       v_instance_id          := pIID;
       v_lrnn                 := pLRN;
       v_lrn                  := TO_CHAR(pLRN);
       v_refresh_id           := pREFRESH_ID;
       v_org_group            := prec.org_group_flag;



 ----- PROFILE OPTION --------------------------------------------------

       v_so_ship_arrive_value       := pSO_SHIP_ARRIVE_VALUE;
       v_mps_consume_profile_value  := pMPS_CONSUME_PROFILE_VALUE;
       v_spread_load                := pSPREAD_LOAD;
       v_hour_uom                   := pHOUR_UOM;
       v_lang                       := pLANG;
       v_oe_install                 := pOE_INSTALL;

       v_mso_item_dmd_penalty       := pMSO_ITEM_DMD_PENALTY;
       v_mso_item_cap_penalty       := pMSO_ITEM_CAP_PENALTY;
       v_mso_org_dmd_penalty        := pMSO_ORG_DMD_PENALTY;
       v_mso_org_item_penalty       := pMSO_ORG_ITEM_PENALTY;
       v_mso_org_res_penalty        := pMSO_ORG_RES_PENALTY;
       v_mso_org_trsp_penalty       := pMSO_ORG_TRSP_PENALTY;
       v_msc_batchable_flag         := pMSC_BATCHABLE_FLAG;
       v_msc_batching_window        := pMSC_BATCHING_WINDOW;
       v_msc_min_capacity            := pMSC_MIN_CAPACITY;
       v_msc_max_capacity           := pMSC_MAX_CAPACITY;
       v_msc_unit_of_measure       := pMSC_UNIT_OF_MEASURE;
       v_msc_aggreg_res_name        := pMSC_AGGREG_RES_NAME;
       v_mso_res_penalty            := pMSO_RES_PENALTY;
       v_mso_sup_cap_penalty        := pMSO_SUP_CAP_PENALTY;
       v_msc_bom_subst_priority     := pMSC_BOM_SUBST_PRIORITY;
       v_mso_trsp_penalty           := pMSO_TRSP_PENALTY;
       v_msc_alt_bom_cost           := pMSC_ALT_BOM_COST;
       v_mso_fcst_penalty           := pMSO_FCST_PENALTY;
       v_mso_so_penalty             := pMSO_SO_PENALTY;
       v_msc_alt_op_res             := pMSC_ALT_OP_RES;
       v_msc_alt_res_priority       := pMSC_ALT_RES_PRIORITY;
       v_msc_simul_res_seq          := pMSC_SIMUL_RES_SEQ;
       v_mrp_bis_av_discount        := pMRP_BIS_AV_DISCOUNT;
       v_mrp_bis_price_list         := pMRP_BIS_PRICE_LIST;
       v_msc_dmd_priority_flex_num  := pMSC_DMD_PRIORITY_FLEX_NUM;
       v_msc_fcst_priority_flex_num  := pMSC_FCST_PRIORITY_FLEX_NUM;

 ----- FLAGS -----------------------------------------------------------

       ITEM_ENABLED         := pITEM_ENABLED;
       FORECAST_ENABLED     := pFORECAST_ENABLED;
       VENDOR_ENABLED       := pVENDOR_ENABLED;
       CUSTOMER_ENABLED     := pCUSTOMER_ENABLED;
       BOM_ENABLED          := pBOM_ENABLED;
       HARD_RESRVS_ENABLED  := pHARD_RESRVS_ENABLED;
       SOURCING_ENABLED     := pSOURCING_ENABLED;
       WIP_ENABLED          := pWIP_ENABLED;
       SS_ENABLED           := pSS_ENABLED;
       PO_ENABLED           := pPO_ENABLED;
       ITEM_SUBST_ENABLED   := pITEM_SUBST_ENABLED;
       OH_ENABLED           := pOH_ENABLED;
       SUPPLIER_CAP_ENABLED := pSUPPLIER_CAP_ENABLED;
       UOM_ENABLED          := pUOM_ENABLED;
       MDS_ENABLED          := prec.mds_flag;
       MPS_ENABLED          := pMPS_ENABLED;
       NRA_ENABLED          := pNRA_ENABLED;
       SH_ENABLED           := pSH_ENABLED;
       PO_RECEIPTS_ENABLED  := pPO_RECEIPTS_ENABLED;
	   /* SCE Change Starts */
	   USER_COMPANY_ENABLED := pUSER_COMPANY_ENABLED;
	   /* SCE Change Ends */

       /* CP-Ack starts */
       SUPPLIER_RESPONSE_ENABLED := pSUPPLIER_RESPONSE_ENABLED;
       /* CP-Ack ends */

       TRIP_ENABLED          := pTRIP_ENABLED;
       INTERNAL_REPAIR_ENABLED := prec.internal_repair_flag;
       EXTERNAL_REPAIR_ENABLED := prec.external_repair_flag;

        IF NRA_ENABLED = 1 OR NRA_ENABLED = 3 THEN
           lv_nra_enabled_r11 := 1;
        ELSE
           lv_nra_enabled_r11 := 0;
                /*
                select decode(NRA_ENABLED,1,1,2,0,3,1,0)
                into lv_nra_enabled_r11
                from dual;
                */
        END IF;
       SELECT DECODE( M2A_DBLINK,
                      NULL, ' ',
                      '@'||M2A_DBLINK),
              INSTANCE_CODE||':',
              APPS_VER,
              GMT_DIFFERENCE/24.0,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              INSTANCE_TYPE
         INTO v_dblink,
              v_icode,
              v_apps_ver,
              v_dgmt,
              lv_task_start_time,
              v_current_user,
              v_current_date,
              v_instance_type
         FROM MSC_APPS_INSTANCES
       WHERE INSTANCE_ID= pIID;


       /* added code so that for 107/110 source this profile option = 0 */
       IF (v_apps_ver = MSC_UTIL.G_APPS107) OR (v_apps_ver = MSC_UTIL.G_APPS110) THEN
          v_msc_tp_coll_window := 0;
       ELSE
             v_msc_tp_coll_window := MSC_UTIL.v_msc_tp_coll_window;
       END IF;

       SELECT decode(NVL(FND_PROFILE.VALUE('MSC_COLLECT_COMPLETED_JOBS'),'Y'),
              'Y', 1,
              2)
       INTO v_collect_completed_jobs
       FROM DUAL;

          /* this feature is not supported yet, so set to 0 as default */
       v_dgmt:= 0;

         SAVEPOINT ExecuteTask;

         pSTATUS := FAIL;

         -- set the flags as to whether discrete and/or process
         -- manufacturing are being used in the same instance

         v_discrete_flag:= MSC_UTIL.SYS_NO;
         v_process_flag := MSC_UTIL.SYS_NO;

         IF v_instance_type = MSC_UTIL.G_INS_DISCRETE OR
            v_instance_type = MSC_UTIL.G_INS_MIXED    THEN
            v_discrete_flag := MSC_UTIL.SYS_YES;
         END IF;

  -- since the gmp's procedure doesn't support incremental refresh, the
  -- v_process_flag is set to YES only if it's a complete refresh.

         IF pLRN = -1 THEN     -- complete refresh
            IF v_instance_type = MSC_UTIL.G_INS_PROCESS OR
               v_instance_type = MSC_UTIL.G_INS_MIXED   THEN
               v_process_flag := MSC_UTIL.SYS_YES;
            END IF;
         END IF;

       --- PREPLACE CHANGE START ---


         SELECT DECODE(LRTYPE, 'P', MSC_UTIL.SYS_YES, MSC_UTIL.SYS_NO)
           INTO v_is_partial_refresh
           FROM msc_apps_instances
          WHERE instance_id = pIID;


        -- IF v_is_partial_refresh  = MSC_UTIL.SYS_YES THEN

            IF pVENDOR_ENABLED = MSC_UTIL.SYS_YES THEN
              CUSTOMER_ENABLED := MSC_UTIL.SYS_YES;
            ELSIF pCUSTOMER_ENABLED = MSC_UTIL.SYS_YES THEN
              VENDOR_ENABLED := MSC_UTIL.SYS_YES;
            END IF;

        -- END IF;

       ---  PREPLACE CHANGE END  ---
-- agmcont

         SELECT DECODE(LRTYPE,'C',MSC_UTIL.G_COMPLETE,'P',MSC_UTIL.G_PARTIAL,'I',MSC_UTIL.G_INCREMENTAL,'T',MSC_UTIL.G_CONT)
         INTO
         lv_refresh_type
         FROM msc_apps_instances
         WHERE instance_id = pIID;

          if (get_entity_lrn (pIID, pTASKNUM, prec, pLRN, lv_refresh_type,prec.org_group_flag ,lv_entity_lrn)) then
            v_lrnn := lv_entity_lrn;
            v_lrn  := TO_CHAR(v_lrnn);
          end if;

          SELECT DECODE(LRTYPE, 'T', MSC_UTIL.SYS_YES, MSC_UTIL.SYS_NO)
           INTO v_is_cont_refresh
           FROM msc_apps_instances
          WHERE instance_id = pIID;


         if (v_is_cont_refresh = MSC_UTIL.SYS_YES) then
            if (MSC_CL_CONT_COLL_FW.set_cont_refresh_type (pIID, pTASKNUM, prec, lv_entity_lrn, lv_cont_lrn)) then
               v_lrnn := lv_cont_lrn;
               v_lrn  := TO_CHAR(v_lrnn);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'LRNN=' || v_lrnn);
            else
               pSTATUS := OK;
               return;
            end if;
         end if;

         if (v_is_cont_refresh = MSC_UTIL.SYS_YES) then
            IF v_lrn = -1 THEN     -- complete refresh
             IF v_instance_type = MSC_UTIL.G_INS_PROCESS OR
               v_instance_type = MSC_UTIL.G_INS_MIXED   THEN
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'process flag is Yes');
               v_process_flag := MSC_UTIL.SYS_YES;
             END IF;
            END IF;
         end if;

   -- ============= Execute the task according to its task number  ===========

       BEGIN--LOAD_DATA

         IF prec.po_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_PO_SUPPLY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_PULL.LOAD_PO_SUPPLY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SUPPLY_PULL.LOAD_PO_SUPPLY;

         ELSIF prec.po_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_PO_PO_SUPPLY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_PULL.LOAD_PO_PO_SUPPLY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SUPPLY_PULL.LOAD_PO_PO_SUPPLY;

         ELSIF prec.po_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_PO_REQ_SUPPLY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_PULL.LOAD_PO_REQ_SUPPLY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SUPPLY_PULL.LOAD_PO_REQ_SUPPLY;

         ELSIF prec.wip_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_WIP_SUPPLY THEN

           -- call the appropriate routine for the type being used

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_PULL.LOAD_WIP_SUPPLY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
              MSC_CL_WIP_PULL.LOAD_WIP_SUPPLY;
           END IF;

           IF v_process_flag = MSC_UTIL.SYS_YES THEN

             IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               lv_return_status := TRUE;
             ELSE
               lv_return_status := FALSE;
             END IF;
              IF (v_apps_ver >= MSC_UTIL.G_APPS120) THEN  --bug#5684183 (bcaru)

                gmp_aps_ds_pull.production_orders(v_dblink,
                                                 v_instance_id,
                                                  lv_task_start_time,
                                               v_delimiter,
                                               lv_return_status);

                v_gmp_routine_name := 'GMP_APS_DS_PULL.PRODUCTION_ORDERS';

              ELSIF (v_apps_ver = MSC_UTIL.G_APPS115) THEN
                MSC_CL_GMP_UTILITY.production_orders(v_dblink,
                                                 v_instance_id,
                                                  lv_task_start_time,
                                               v_delimiter,
                                               lv_return_status);

                v_gmp_routine_name := 'MSC_CL_GMP_UTILITY.PRODUCTION_ORDERS';
              END IF;

               IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
               END IF;

           END IF;


         ELSIF prec.oh_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_OH_SUPPLY THEN

           -- call the appropriate routine for onhand inventory

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_PULL.LOAD_OH_SUPPLY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            /* OPM Team - OPM Inventory Convergence Project
               Onhand calculation has to be performed for both
               discrete/process orgs.
           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN*/
             MSC_CL_SUPPLY_PULL.LOAD_OH_SUPPLY;
--         END IF;

           IF v_process_flag = MSC_UTIL.SYS_YES THEN
             IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               lv_return_status := TRUE;
             ELSE
               lv_return_status := FALSE;
             END IF;

                    /* OPM Team - OPM Inventory Convergence Project
                   On Hand inventories to be stored in the same schema
                   as discrete mfg - the views are modified to consider
                   added functionality
               gmp_aps_ds_pull.onhand_inventory(v_dblink,
                                                v_instance_id,
                                                  lv_task_start_time,
                                                v_delimiter,
                                                lv_return_status);

               v_gmp_routine_name := 'GMP_APS_DS_PULL.ONHAND_INVENTORY';

               IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
               END IF;
               */

               IF (v_apps_ver = MSC_UTIL.G_APPS115) THEN

                 MSC_CL_GMP_UTILITY.onhand_inventory(v_dblink,
                                                  v_instance_id,
                                                    lv_task_start_time,
                                                  v_delimiter,
                                                  lv_return_status);

                 v_gmp_routine_name := 'MSC_CL_GMP_UTILITY.ONHAND_INVENTORY';

                 IF lv_return_status = FALSE THEN
                    RAISE GMP_ERROR;
                 END IF;
               END IF;
           END IF;

         ELSIF prec.mps_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_MPS_SUPPLY THEN

           -- only call if doing discrete mfg

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_PULL.LOAD_MPS_SUPPLY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_SUPPLY_PULL.LOAD_MPS_SUPPLY;
           END IF;

         ELSIF prec.bor_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_BOR THEN

           -- only call if doing discrete mfg

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_PULL.LOAD_BOR');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_BOM_PULL.LOAD_BOR;
           END IF;

         ELSIF (prec.calendar_flag = MSC_UTIL.SYS_YES OR prec.resource_nra_flag in (1,3)) AND pTASKNUM= TASK_CALENDAR_DATE THEN

           -- call the appropriate routine for calendar dates

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_PULL.LOAD_CALENDAR_DATE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            /* OPM Team - OPM Inventory Convergence Project
	      Calendar data should be populated for both discrete and process organizations.
	      So commenting the chk to discrete alone.
	           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
	              MSC_CL_SETUP_PULL.LOAD_CALENDAR_DATE;
	           END IF;
           */
           MSC_CL_SETUP_PULL.LOAD_CALENDAR_DATE;


	  IF v_process_flag = MSC_UTIL.SYS_YES THEN

             -- Process will populate the trading partners here then
             -- update the org partner for the appropriate calendars
             -- in the calendar routine. also populated is net_resource_avail
             MSC_CL_SETUP_PULL.LOAD_TRADING_PARTNER;

             IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               lv_return_status := TRUE;
             ELSE
               lv_return_status := FALSE;
             END IF;

                IF (v_apps_ver >= MSC_UTIL.G_APPS120) THEN  --bug#5684183 (bcaru)
                   gmp_calendar_pkg.populate_rsrc_cal( lv_task_start_time,
                                                     v_instance_id,
                                                     v_delimiter,
                                                     v_dblink,
                                                     NRA_ENABLED,
                                                     lv_return_status);

                 v_gmp_routine_name := 'GMP_CALENDAR_PKG.POPULATE_RSRC_CAL';
                ELSIF (v_apps_ver = MSC_UTIL.G_APPS115) THEN

                   MSC_CL_GMP_UTILITY.populate_rsrc_cal( lv_task_start_time,
                                                     v_instance_id,
                                                     v_delimiter,
                                                     v_dblink,
                                                     lv_nra_enabled_r11,
                                                     lv_return_status);

                 v_gmp_routine_name := 'MSC_CL_GMP_UTILITY.POPULATE_RSRC_CAL';
                END IF;

                 IF lv_return_status = FALSE THEN
                    RAISE GMP_ERROR;
                 END IF;

           END IF;

         ELSIF (prec.mds_flag = MSC_UTIL.SYS_YES OR prec.mps_flag = MSC_UTIL.SYS_YES) AND pTASKNUM= TASK_SCHEDULE THEN

           -- only call if doing discrete mfg, for process this is done in
           -- MDS demands

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_SCHEDULE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           IF ( v_discrete_flag = MSC_UTIL.SYS_YES ) THEN
              IF prec.mds_flag = MSC_UTIL.SYS_YES AND prec.mps_flag = MSC_UTIL.SYS_NO THEN
		  v_schedule_flag := MSC_UTIL.G_MDS;
	      ELSIF prec.mds_flag = MSC_UTIL.SYS_NO AND prec.mps_flag = MSC_UTIL.SYS_YES THEN
	          v_schedule_flag := MSC_UTIL.G_MPS;
	      ELSE
		  v_schedule_flag := MSC_UTIL.G_BOTH;
              END IF;

              MSC_CL_OTHER_PULL.LOAD_SCHEDULE;
           END IF;

         ELSIF prec.item_flag = MSC_UTIL.SYS_YES AND  pTASKNUM= TASK_ITEM1 THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_PULL.LOAD_ITEM(1)');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_PULL.LOAD_ITEM(1);
 	   /* ds change for non standard jobs and eam wo, we may not have
    	      primary item specified in wo. We are going to create
   	      two dummy item, on eofr non standard job and other for
   	      eam wo */
    	      MSC_CL_ITEM_PULL.INSERT_DUMMY_ITEMS;

         ELSIF prec.item_flag = MSC_UTIL.SYS_YES AND  pTASKNUM= TASK_ITEM2 THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_PULL.LOAD_ITEM(2)');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_PULL.LOAD_ITEM(2);

         ELSIF prec.item_flag = MSC_UTIL.SYS_YES AND  pTASKNUM= TASK_ITEM3 THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_PULL.LOAD_ITEM(0)');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_PULL.LOAD_ITEM(0);

         /*added for bug:4765403*/
         ELSIF prec.item_flag = MSC_UTIL.SYS_YES AND  pTASKNUM= TASK_ABC_CLASSES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_PULL.LOAD_ABC_CLASSES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
          IF (v_apps_ver >= MSC_UTIL.G_APPS120) THEN
            MSC_CL_ITEM_PULL.LOAD_ABC_CLASSES;
          END IF;

         ELSIF (prec.bom_flag = MSC_UTIL.SYS_YES OR prec.wip_flag = MSC_UTIL.SYS_YES) AND pTASKNUM= TASK_RESOURCE THEN

           -- call the appropriate routine for resources
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_PULL.LOAD_RESOURCE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_BOM_PULL.LOAD_RESOURCE;
           END IF;
           IF v_process_flag = MSC_UTIL.SYS_YES THEN
             IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               lv_return_status := TRUE;
             ELSE
               lv_return_status := FALSE;
             END IF;
                IF (v_apps_ver >= MSC_UTIL.G_APPS120) THEN  --bug#5684183 (bcaru)
                  gmp_calendar_pkg.rsrc_extract( v_instance_id,
                                              v_dblink ,
                                              lv_return_status);

                  v_gmp_routine_name := 'GMP_CALENDAR_PKG.RSRC_EXTRACT';
                ELSIF (v_apps_ver = MSC_UTIL.G_APPS115) THEN
                  MSC_CL_GMP_UTILITY.rsrc_extract( v_instance_id,
                                              v_dblink ,
                                              lv_return_status);

                  v_gmp_routine_name := 'MSC_CL_GMP_UTILITY.RSRC_EXTRACT';
                END IF;
               /*gmp_calendar_pkg.rsrc_extract( v_instance_id,
                                              v_dblink ,
                                              lv_return_status);

               v_gmp_routine_name := 'GMP_CALENDAR_PKG.RSRC_EXTRACT';*/

              IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
              END IF;

           END IF;

	 /*ds change start */
	 ELSIF (prec.bom_flag = MSC_UTIL.SYS_YES OR prec.wip_flag = MSC_UTIL.SYS_YES) AND
			pTASKNUM= TASK_RESOURCE_INSTANCE THEN

	    FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_PULL.LOAD_RESOURCE_INSTANCE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             	MSC_CL_BOM_PULL.LOAD_RESOURCE_INSTANCE;
            END IF;

	    -- opm populated dept resource instances in call
            -- populate_rsrc_cal

 	ELSIF (prec.bom_flag = MSC_UTIL.SYS_YES ) AND
                        pTASKNUM= TASK_RESOURCE_SETUP THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_PULL.LOAD_RESOURCE_SETUP');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
                MSC_CL_BOM_PULL.LOAD_RESOURCE_SETUP;
            END IF;

             -- opm  populates resource setups and transitions
	     -- in extract_effectivities

	 /*ds change end */

         ELSIF (prec.tp_customer_flag = MSC_UTIL.SYS_YES OR prec.tp_vendor_flag = MSC_UTIL.SYS_YES) AND  pTASKNUM= TASK_TRADING_PARTNER THEN

           -- only call if not doing process mfg. for process this is done
                   -- with calendar dates

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_PULL.LOAD_TRADING_PARTNER');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

           --- PREPLACE CHANGE START ---
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'v_process_flag is ' || v_process_flag);

           /* Even when customer_flag or vendor_flag is enabled we must not call loading
              MSC_CL_SETUP_PULL.LOAD_TRADING_PARTNER if v_process_flag is YES  and CALENDAR is Yes, beacuse
              in this case MSC_CL_SETUP_PULL.LOAD_TRADING_PARTNER would be called in CALENDAR task. */

           IF (NOT((v_process_flag = MSC_UTIL.SYS_YES) AND
                   (prec.calendar_flag = MSC_UTIL.SYS_YES OR prec.resource_nra_flag in (1,3)))) THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'LOADING TRADING PARTNERS');

           ---  PREPLACE CHANGE END  ---

             MSC_CL_SETUP_PULL.LOAD_TRADING_PARTNER;

             /* In case if process_enabled is true, it can come here only if
                calendar is not YES in which case one should call populate_rsrc_cal
                since this required for both calendar and partner sites. For process orgs
                if either calendar or customer or vendor are yes, we have to call
                populate_rsrc_cal . */

             IF v_process_flag = MSC_UTIL.SYS_YES THEN
             	IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               		lv_return_status := TRUE;
             	ELSE
               		lv_return_status := FALSE;
             	END IF;
                IF (v_apps_ver >= MSC_UTIL.G_APPS120) THEN  --bug#5684183 (bcaru)
                  gmp_calendar_pkg.populate_rsrc_cal( lv_task_start_time,
                                                     v_instance_id,
                                                     v_delimiter,
                                                     v_dblink,
                                                     NRA_ENABLED,
                                                     lv_return_status);

                  v_gmp_routine_name := 'GMP_CALENDAR_PKG.POPULATE_RSRC_CAL';
                ELSIF (v_apps_ver = MSC_UTIL.G_APPS115) THEN
                  MSC_CL_GMP_UTILITY.populate_rsrc_cal( lv_task_start_time,
                                                     v_instance_id,
                                                     v_delimiter,
                                                     v_dblink,
                                                     lv_nra_enabled_r11,
                                                     lv_return_status);

                  v_gmp_routine_name := 'MSC_CL_GMP_UTILITY.POPULATE_RSRC_CAL';
                END IF;

                 IF lv_return_status = FALSE THEN
                    RAISE GMP_ERROR;
                 END IF;
             END IF;
           END IF;

         ELSIF prec.forecast_flag = MSC_UTIL.SYS_YES AND pTASKNUM = TASK_LOAD_FORECAST THEN
             FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
             FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_FORECAST');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            IF (v_apps_ver= MSC_UTIL.G_APPS110 OR
                v_apps_ver>= MSC_UTIL.G_APPS115) THEN /*to be changed after coding for 107/11i*/

             MSC_CL_DEMAND_PULL.LOAD_FORECASTS;

            END IF;

             FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
             FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_ITEM_FORECASTS');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            IF (v_apps_ver= MSC_UTIL.G_APPS110 OR
                v_apps_ver>= MSC_UTIL.G_APPS115) THEN /*to be changed after coding for 107/11i*/

             MSC_CL_DEMAND_PULL.LOAD_ITEM_FORECASTS;

            END IF;

             IF v_process_flag = MSC_UTIL.SYS_YES THEN

             IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               lv_return_status := TRUE;
             ELSE
               lv_return_status := FALSE;
             END IF;

        /* OPM Team - OPM Inventory Convergence Project
           OPM forecast merges with discrete forecast in R12
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading SALES_FORECAST for Process Mfg');

               gmp_aps_ds_pull.sales_forecast(v_dblink,
                                              v_instance_id,
                                              lv_task_start_time,
                                              v_delimiter,
                                              lv_return_status);

               v_gmp_routine_name := 'GMP_APS_DS_PULL.SALES_FORECAST';

               IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
               END IF;
          */

         IF (v_apps_ver = MSC_UTIL.G_APPS115) THEN

             MSC_CL_GMP_UTILITY.sales_forecast(v_dblink,
                                              v_instance_id,
                                              lv_task_start_time,
                                              v_delimiter,
                                              lv_return_status);

              v_gmp_routine_name := 'MSC_CL_GMP_UTILITY.SALES_FORECAST';

               IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
               END IF;

         END IF;

           END IF;



         ELSIF  prec.mds_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_MDS_DEMAND THEN

           -- call the appropriate routine for MDS demand
	   /* how we can avoid this for  ds */
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_MDS_DEMAND');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Starting MDS LOAD');
           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_DEMAND_PULL.LOAD_MDS_DEMAND;
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'MDS LOAD COMPLETED');
           END IF;
/*
           IF v_process_flag = MSC_UTIL.SYS_YES THEN
             IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               lv_return_status := TRUE;
             ELSE
               lv_return_status := FALSE;
             END IF;

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading SALES_FORECAST for Process Mfg');

               gmp_aps_ds_pull.sales_forecast(v_dblink,
                                              v_instance_id,
                                              lv_task_start_time,
                                              v_delimiter,
                                              lv_return_status);

               v_gmp_routine_name := 'GMP_APS_DS_PULL.SALES_FORECAST';

               IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
               END IF;

           END IF;
*/
         ELSIF  prec.wip_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_WIP_DEMAND THEN

           -- only call if doing discrete mfg. process does this as part of
                   -- wip supply

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_PULL.LOAD_WIP_DEMAND');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_WIP_PULL.LOAD_WIP_DEMAND;
           END IF;
          /*  check sales order is selected */
         ELSIF prec.sales_order_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_SALES_ORDER1 THEN

           IF ( v_apps_ver>= MSC_UTIL.G_APPS115) and (v_discrete_flag = MSC_UTIL.SYS_YES) THEN  -- 11i source instance only
           -- only call if doing discrete mfg

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(1)');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(1);

	   END IF;

	ELSIF prec.sales_order_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_SALES_ORDER2 THEN

           IF ( v_apps_ver>= MSC_UTIL.G_APPS115)  AND (v_discrete_flag = MSC_UTIL.SYS_YES) THEN  -- 11i source instance only
           -- only call if doing discrete mfg

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(2)');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(2);

	   END IF;

         ELSIF prec.sales_order_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_SALES_ORDER3 THEN

           IF (v_discrete_flag = MSC_UTIL.SYS_YES) THEN
           -- only call if doing discrete mfg

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(3)');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(3);

	   END IF;
/*
         ELSIF pTASKNUM= TASK_SALES_ORDER THEN

           -- only call if doing discrete mfg

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(4)');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
               MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(4);
           END IF;
*/
         ELSIF pTASKNUM= TASK_AHL THEN

         lv_sql_stmt:=
       'BEGIN'
       ||' :lv_ps_ver := MRP_CL_FUNCTION.CHECK_AHL_VER'||v_dblink||';'
       ||'END;';

            EXECUTE IMMEDIATE lv_sql_stmt
            USING OUT lv_ps_ver;

           IF ( v_apps_ver>= MSC_UTIL.G_APPS115) and (v_discrete_flag = MSC_UTIL.SYS_YES) and (lv_ps_ver =1) THEN  -- 11i source instance only
           -- only call if doing discrete mfg, Is this a valid assumption --dsoosai 12/04/2003

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_SALES_ORDER(5:AHL)');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_DEMAND_PULL.LOAD_AHL;

    	   END IF;

         ELSIF prec.sub_inventory_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_SUB_INVENTORY THEN

           -- call the appropriate routine for sub inventory

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_SUB_INVENTORY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

           /* OPM Team - OPM Inventory Convergence Project
             Commented this has to be called for both discrete/process
           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN */
             MSC_CL_OTHER_PULL.LOAD_SUB_INVENTORY;
  --         END IF;
           IF v_process_flag = MSC_UTIL.SYS_YES and WIP_ENABLED= MSC_UTIL.SYS_YES THEN
             IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               lv_return_status := TRUE;
             ELSE
               lv_return_status := FALSE;
             END IF;


         /* OPM Team - OPM Inventory Convergence Project
            extract the process subinventories through
            modified mrp_ap_sub_inventories_v
            gmp_bom_routing_pkg.extract_sub_inventory(v_dblink,
                                                         v_instance_id,
                                                         lv_task_start_time,
                                                         lv_return_status);

              v_gmp_routine_name := 'GMP_BOM_ROUTING_PKG.EXTRACT_SUB_INVENTORY';

               IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
               END IF;
               */
           IF (v_apps_ver = MSC_UTIL.G_APPS115) THEN

             MSC_CL_GMP_UTILITY.extract_sub_inventory(v_dblink,
                                                         v_instance_id,
                                                         lv_task_start_time,
                                                         lv_return_status);

              v_gmp_routine_name := 'MSC_CL_GMP_UTILITY.EXTRACT_SUB_INVENTORY';

               IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
               END IF;

         END IF;


           END IF;

         ELSIF prec.reserves_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_HARD_RESERVATION THEN

           -- only call if doing discrete mfg

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_HARD_RESERVATION');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_DEMAND_PULL.LOAD_HARD_RESERVATION;
           END IF;

         ELSIF prec.sourcing_rule_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_SOURCING THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_SOURCING');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_OTHER_PULL.LOAD_SOURCING;

         ELSIF (prec.app_supp_cap_flag = MSC_UTIL.ASL_YES or prec.app_supp_cap_flag = MSC_UTIL.ASL_YES_RETAIN_CP ) AND pTASKNUM= TASK_SUPPLIER_CAPACITY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_PULL.LOAD_SUPPLIER_CAPACITY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_ITEM_PULL.LOAD_SUPPLIER_CAPACITY;

         ELSIF prec.item_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_CATEGORY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_PULL.LOAD_CATEGORY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_ITEM_PULL.LOAD_CATEGORY;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_PULL.INSERT_DUMMY_CATEGORIES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_ITEM_PULL.INSERT_DUMMY_CATEGORIES ;

         ELSIF  prec.bom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_BOM THEN

           -- call the appropriate routine for bom

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_PULL.LOAD_BOM');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_BOM_PULL.LOAD_BOM;
           END IF;
           IF v_process_flag = MSC_UTIL.SYS_YES and BOM_ENABLED= MSC_UTIL.SYS_YES THEN
             -- process will also extract routings here
             IF v_cp_enabled = MSC_UTIL.SYS_YES THEN
               lv_return_status := TRUE;
             ELSE
               lv_return_status := FALSE;
             END IF;
              IF (v_apps_ver >= MSC_UTIL.G_APPS120) THEN  --bug#5684183 (bcaru)
                  gmp_bom_routing_pkg.extract_effectivities(v_dblink,
                                                         v_delimiter,
                                                         v_instance_id,
                                                         lv_task_start_time,
                                                         lv_return_status);

                  v_gmp_routine_name := 'GMP_BOM_ROUTING_PKG.EXTRACT_EFFECTIVITIES';
              ELSIF (v_apps_ver = MSC_UTIL.G_APPS115) THEN
                  MSC_CL_GMP_UTILITY.extract_effectivities(v_dblink,
                                                         v_delimiter,
                                                         v_instance_id,
                                                         lv_task_start_time,
                                                         lv_return_status);

                  v_gmp_routine_name := 'MSC_CL_GMP_UTILITY.EXTRACT_EFFECTIVITIES';
              END IF;

              IF lv_return_status = FALSE THEN
                  RAISE GMP_ERROR;
              END IF;

           END IF;

         ELSIF prec.bom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_ROUTING THEN

           -- only call if doing discrete mfg. process will do this with
           -- boms

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_PULL.LOAD_ROUTING');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_ROUTING_PULL.LOAD_ROUTING;
           END IF;

         ELSIF prec.bom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_OPER_NETWORKS THEN

           -- only call if doing discrete mfg. process will do this with
           -- boms

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_PULL.LOAD_OPER_NETWORKS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_WIP_PULL.LOAD_OPER_NETWORKS;
           END IF;

         ELSIF prec.bom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_ROUTING_OPERATIONS THEN

           -- only call if doing discrete mfg. process will do this with
           -- boms

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_PULL.LOAD_ROUTING_OPERATIONS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_ROUTING_PULL.LOAD_ROUTING_OPERATIONS;
           END IF;

         ELSIF prec.bom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_OPERATION_RES_SEQS THEN

           -- only call if doing discrete mfg. process will do this with
           -- boms

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_OPERATION_RES_SEQ');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_ROUTING_PULL.LOAD_OPERATION_RES_SEQS;
           END IF;
         ELSIF prec.bom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_OPERATION_RESOURCES THEN

           -- only call if doing discrete mfg. process will do this with
           -- boms

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_PULL.LOAD_OPERATION_RESOURCES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_ROUTING_PULL.LOAD_OPERATION_RESOURCES;
           END IF;
         ELSIF prec.bom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_OPERATION_COMPONENTS THEN

           -- only call if doing discrete mfg. process will do this with
           -- boms

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_PULL.LOAD_OPERATION_COMPONENTS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_ROUTING_PULL.LOAD_OPERATION_COMPONENTS;
           END IF;
         ELSIF prec.bom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_PROCESS_EFFECTIVITY THEN

           -- only call if doing discrete mfg. process will do this with
           -- boms

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_PULL.LOAD_PROCESS_EFFECTIVITY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


           IF v_discrete_flag = MSC_UTIL.SYS_YES THEN
             MSC_CL_BOM_PULL.LOAD_PROCESS_EFFECTIVITY;
           END IF;

         ELSIF prec.unit_number_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_UNIT_NUMBER THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_UNIT_NUMBER');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_OTHER_PULL.LOAD_UNIT_NUMBER;

         ELSIF prec.saf_stock_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_SAFETY_STOCK THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_SAFETY_STOCK');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_OTHER_PULL.LOAD_SAFETY_STOCK;

         ELSIF prec.project_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_PROJECT THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_PROJECT');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_OTHER_PULL.LOAD_PROJECT;

         ELSIF prec.parameter_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_PARAMETER THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_PULL.LOAD_PARAMETER');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_SETUP_PULL.LOAD_PARAMETER;

         ELSIF prec.uom_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_UOM THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_PULL.LOAD_UOM');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_SETUP_PULL.LOAD_UOM;

         ELSIF prec.kpi_bis_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_BIS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_BIS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);


            IF v_apps_ver= MSC_UTIL.G_APPS110 THEN

               MSC_CL_OTHER_PULL.LOAD_BIS110;

            ELSIF v_apps_ver>= MSC_UTIL.G_APPS115 THEN

               MSC_CL_OTHER_PULL.LOAD_BIS115;

            ELSIF v_apps_ver= MSC_UTIL.G_APPS107 THEN

               MSC_CL_OTHER_PULL.LOAD_BIS107;

            END IF;

         ELSIF  prec.atp_rules_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_ATP_RULES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_ATP_RULES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_OTHER_PULL.LOAD_ATP_RULES;

         ELSIF prec.user_supply_demand_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_USER_SUPPLY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_PULL.LOAD_USER_SUPPLY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_SUPPLY_PULL.LOAD_USER_SUPPLY;

         ELSIF prec.user_supply_demand_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_USER_DEMAND THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_PULL.LOAD_USER_DEMAND');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_DEMAND_PULL.LOAD_USER_DEMAND;

         ELSIF prec.planner_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_PLANNERS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_PLANNERS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_OTHER_PULL.LOAD_PLANNERS;

             -- Added this new task for Prod. Subst ---
         ELSIF  prec.item_subst_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_ITEM_SUBSTITUTES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_PULL.LOAD_ITEM_SUBSTITUTES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            IF ( v_apps_ver >= MSC_UTIL.G_APPS115 ) THEN
               MSC_CL_ITEM_PULL.LOAD_ITEM_SUBSTITUTES;
            END IF;

         ELSIF prec.demand_class_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_DEMAND_CLASS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_DEMAND_CLASS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_OTHER_PULL.LOAD_DEMAND_CLASS;

         ELSIF (prec.tp_customer_flag = MSC_UTIL.SYS_YES OR prec.tp_vendor_flag = MSC_UTIL.SYS_YES)  AND pTASKNUM= TASK_BUYER_CONTACT THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_PULL.LOAD_BUYER_CONTACT');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SETUP_PULL.LOAD_BUYER_CONTACT;

         /* SCE Change starts */

         ELSIF (prec.user_company_flag <> MSC_UTIL.NO_USER_COMPANY) AND pTASKNUM = TASK_USER_COMPANY THEN

         /* Pull User Company association only if Collection mode is either complete
			refresh or targeted refresh.
			We do not collect association in net change refresh since there is
			no snapshot in the source for fnd_user*/

            IF v_lrnn = -1 THEN

		 /* Pull User Company association only if Apps version is MSC_UTIL.G_APPS115 */

				IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN

		 /* Pull User Company association only if MSC:Configuration is APS or APS+SCE  */
                    IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
                        OR
                        MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN

            		FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            		FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SCE_COLLECTION.PULL_USER_COMPANY');
            		MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Value of USER_COMPANY_ENABLED :'||USER_COMPANY_ENABLED);
                        MSC_CL_SCE_COLLECTION.PULL_USER_COMPANY(v_dblink,
                                                                v_instance_id,
                                                                lv_return_status,
							        USER_COMPANY_ENABLED);
                        IF (lv_return_status = FALSE) THEN
                            pSTATUS := FAIL;
                        END IF;
                    END IF; /* IF MSC_UTIL.G_MSC_CONFIGURATION */
                END IF;  /* IF v_apps_ver >= MSC_UTIL.G_APPS115 */
            END IF; /* IF v_lrnn */

         /* SCE Change ends */

         /* CP-ACK starts */
         ELSIF (prec.supplier_response_flag = MSC_UTIL.SYS_YES) AND  pTASKNUM = TASK_SUPPLIER_RESPONSE THEN

		 /* Pull supplier responses only if Supplier Response flag is set
			to Yes */
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Value of SUPPLIER_RESPONSE_ENABLED :'||SUPPLIER_RESPONSE_ENABLED);

          IF (SUPPLIER_RESPONSE_ENABLED = MSC_UTIL.SYS_YES) THEN

         /* Pull Supplier response only if Apps version is MSC_UTIL.G_APPS115 */

                IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN

         /* Pull Supplier Response only if MSC:Configuration is CP or APS+CP  */

                    IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
                        OR
                        MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN

                    FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                    FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLIER_RESP.PULL_SUPPLIER_RESP');
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

                         MSC_CL_SUPPLIER_RESP.PULL_SUPPLIER_RESP(v_dblink,
                                                                v_instance_id,
                                                                lv_return_status,
                                                                SUPPLIER_RESPONSE_ENABLED,
                                                                v_refresh_id,
                                                                v_lrn,
                                                                MSC_UTIL.v_in_org_str
                                                                );
                        IF (lv_return_status = FALSE) THEN
                            pSTATUS := FAIL;
                        END IF;
                    END IF; /* IF MSC_UTIL.G_MSC_CONFIGURATION */
                END IF;  /* IF v_apps_ver >= MSC_UTIL.G_APPS115 */
          END IF;
         /* CP-ACK ends */

         ELSIF prec.trip_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_TRIP THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_TRIP');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_OTHER_PULL.LOAD_TRIP;


         ELSIF prec.sales_channel_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_SALES_CHANNEL THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_SALES_CHANNEL');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);

             MSC_CL_OTHER_PULL.LOAD_SALES_CHANNEL;

         ELSIF prec.fiscal_calendar_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_FISCAL_CALENDAR THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_FISCAL_CALENDAR');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);

             MSC_CL_OTHER_PULL.LOAD_FISCAL_CALENDAR;

         ELSIF (prec.internal_repair_flag = MSC_UTIL.SYS_YES) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y') AND (pTASKNUM= TASK_IRO) THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_RPO_PULL.LOAD_IRO');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
                           /* changes for executing repair order load Bug# 5909379 */
             MSC_CL_RPO_PULL.LOAD_IRO;

         ELSIF (prec.internal_repair_flag = MSC_UTIL.SYS_YES) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y') AND (pTASKNUM= TASK_IRO_DEMAND) THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_RPO_PULL.LOAD_IRO_DEMAND');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
           /*  changes for executing repair order load Bug# 5909379 */
             MSC_CL_RPO_PULL.LOAD_IRO_DEMAND;

         ELSIF (prec.external_repair_flag = MSC_UTIL.SYS_YES) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y') AND (pTASKNUM= TASK_ERO) THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_RPO_PULL.LOAD_ERO');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
                           /* changes for executing repair order load Bug# 5935273*/
             MSC_CL_RPO_PULL.LOAD_ERO;

         ELSIF (prec.external_repair_flag = MSC_UTIL.SYS_YES) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y') AND (pTASKNUM= TASK_ERO_DEMAND) THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_RPO_PULL.LOAD_ERO_DEMAND');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
           /*  changes for executing repair order load Bug# 5935273 */
             MSC_CL_RPO_PULL.LOAD_ERO_DEMAND;


         ELSIF prec.payback_demand_supply_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_PAYBACK_DEMAND_SUPPLY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_OPEN_PAYBACKS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);

             MSC_CL_DEMAND_PULL.LOAD_OPEN_PAYBACKS;

           /* changes for currency conversion bug # 6469722 */
      	 ELSIF prec.currency_conversion_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_CURRENCY_CONVERSION THEN -- bug # 6469722
          	  IF (MSC_CL_OTHER_PULL.G_MSC_HUB_CURR_CODE IS NOT NULL) THEN
                      FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_PULL.LOAD_CURRENCY_CONVERSION');
                      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);

          	    MSC_CL_OTHER_PULL.LOAD_CURRENCY_CONVERSION;
          	  ELSE
          	    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Currency Data is not collected as MSC:Planning Hub Currency Code Profile is NULL.');
          	  END IF;
    	  ELSIF prec.delivery_details_flag = MSC_UTIL.SYS_YES AND pTASKNUM= TASK_DELIVERY_DETAILS THEN

                FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_DELIVERY_DETAILS');
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);

                 MSC_CL_OTHER_PULL.LOAD_DELIVERY_DETAILS;
         END IF;

   -- ======== If no exception occurs, then returns with status = OK ========
         pSTATUS := OK;

-- agmcont
        -- restore value of v_lrnn and v_lrn
        if (v_is_cont_refresh = MSC_UTIL.SYS_YES) then
           v_lrnn  := pLRN;
           v_lrn   := TO_CHAR(pLRN);
        end if;

       EXCEPTION--LOAD_DATA

         WHEN EX_SERIALIZATION_ERROR THEN

              ROLLBACK WORK TO SAVEPOINT ExecuteTask;

              RETURN;

         WHEN GMP_ERROR THEN

                  FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_GMP_ERR');
                  FND_MESSAGE.SET_TOKEN('ROUTINE', v_gmp_routine_name);

                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

                  RAISE;

         WHEN OTHERS THEN

              FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_ERR');
              FND_MESSAGE.SET_TOKEN('TABLE', v_table_name);
              FND_MESSAGE.SET_TOKEN('VIEW', v_view_name);

              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

              RAISE;

       END;--LOAD_DATA

         FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
         FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                     TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
         msc_util.print_top_wait(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
         msc_util.print_cum_stat(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
         msc_util.print_bad_sqls(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);


    EXCEPTION

        WHEN OTHERS THEN
              IF SQLCODE IN (-01578,-26040) THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,SQLERRM);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'To rectify this problem -');
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Run concurrent program "Truncate Planning Staging Tables" ');
              ELSE
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,SQLERRM);
              END IF;
              RAISE;

   END EXECUTE_TASK;


-- ==================================================

   PROCEDURE ANALYZE_ALL_ST_TABLE
   IS

        CURSOR tab_list(p_owner varchar) IS
        SELECT table_name
          FROM all_tables
         WHERE owner=p_owner
           AND table_name like 'MSC_ST_%'
           AND temporary <> 'Y';

       var_table_name   VARCHAR2(30);
       v_msc_schema     VARCHAR2(32);
       lv_retval        boolean;
       lv_dummy1        varchar2(32);
       lv_dummy2        varchar2(32);

   BEGIN
      lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2, v_msc_schema);
      OPEN tab_list(v_msc_schema);
      LOOP
         FETCH tab_list INTO var_table_name;

         EXIT WHEN tab_list%NOTFOUND;

         fnd_stats.gather_table_stats(v_msc_schema, var_table_name, 10, 4);

      END LOOP;

   END ANALYZE_ALL_ST_TABLE;


   PROCEDURE ANALYZE_ST_TABLE( pTASK_NUMBER           IN  NUMBER)
   IS

     lv_pctg    NUMBER:= 10;
     lv_deg     NUMBER:= 4;
     lv_owner   VARCHAR2(30);

     CURSOR tab_list is
     SELECT a.oracle_username
       FROM FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
      WHERE a.oracle_id = b.oracle_id
        and b.application_id= 724;

   BEGIN

     OPEN tab_list;
     FETCH tab_list INTO lv_owner;
     IF tab_list%NOTFOUND THEN RETURN; END IF;
     CLOSE tab_list;

   IF pTASK_NUMBER= TASK_BOM THEN

      TSK_RM_BOM_COMPONENTS:= TSK_RM_BOM_COMPONENTS - 1;
      IF TSK_RM_BOM_COMPONENTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BOM_COMPONENTS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_BOMS:= TSK_RM_BOMS - 1;
      IF TSK_RM_BOMS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BOMS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_COMPONENT_SUBSTITUTES:= TSK_RM_COMPONENT_SUBSTITUTES- 1;
      IF TSK_RM_COMPONENT_SUBSTITUTES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_COMPONENT_SUBSTITUTES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER= TASK_ROUTING THEN

      TSK_RM_ROUTINGS:= TSK_RM_ROUTINGS- 1;
      IF TSK_RM_ROUTINGS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_ROUTINGS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_ROUTING_OPERATIONS:= TSK_RM_ROUTING_OPERATIONS- 1;
      IF TSK_RM_ROUTING_OPERATIONS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_ROUTING_OPERATIONS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_OPERATION_RESOURCE_SEQS:= TSK_RM_OPERATION_RESOURCE_SEQS- 1;
      IF TSK_RM_OPERATION_RESOURCE_SEQS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_OPERATION_RESOURCE_SEQS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_OPERATION_RESOURCES:= TSK_RM_OPERATION_RESOURCES- 1;
      IF TSK_RM_OPERATION_RESOURCES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_OPERATION_RESOURCES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_OPERATION_COMPONENTS:= TSK_RM_OPERATION_COMPONENTS- 1;
      IF TSK_RM_OPERATION_COMPONENTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_OPERATION_COMPONENTS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_PROCESS_EFFECTIVITY:= TSK_RM_PROCESS_EFFECTIVITY- 1;
      IF TSK_RM_PROCESS_EFFECTIVITY=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_PROCESS_EFFECTIVITY',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER= TASK_BOR THEN

      TSK_RM_BILL_OF_RESOURCES:= TSK_RM_BILL_OF_RESOURCES- 1;
      IF TSK_RM_BILL_OF_RESOURCES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BILL_OF_RESOURCES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_BOR_REQUIREMENTS:= TSK_RM_BOR_REQUIREMENTS- 1;
      IF TSK_RM_BOR_REQUIREMENTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BOR_REQUIREMENTS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER= TASK_CALENDAR_DATE THEN

      TSK_RM_RESOURCE_CHANGES:= TSK_RM_RESOURCE_CHANGES- 1;
      IF TSK_RM_RESOURCE_CHANGES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_RESOURCE_CHANGES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_CALENDAR_DATES:= TSK_RM_CALENDAR_DATES- 1;
      IF TSK_RM_CALENDAR_DATES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CALENDAR_DATES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_PERIOD_START_DATES:= TSK_RM_PERIOD_START_DATES- 1;
      IF TSK_RM_PERIOD_START_DATES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_PERIOD_START_DATES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_CAL_YEAR_START_DATES:= TSK_RM_CAL_YEAR_START_DATES- 1;
      IF TSK_RM_CAL_YEAR_START_DATES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CAL_YEAR_START_DATES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_CAL_WEEK_START_DATES:= TSK_RM_CAL_WEEK_START_DATES- 1;
      IF TSK_RM_CAL_WEEK_START_DATES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CAL_WEEK_START_DATES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_RESOURCE_SHIFTS:= TSK_RM_RESOURCE_SHIFTS- 1;
      IF TSK_RM_RESOURCE_SHIFTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_RESOURCE_SHIFTS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_CALENDAR_SHIFTS:= TSK_RM_CALENDAR_SHIFTS- 1;
      IF TSK_RM_CALENDAR_SHIFTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CALENDAR_SHIFTS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SHIFT_DATES:= TSK_RM_SHIFT_DATES- 1;
      IF TSK_RM_SHIFT_DATES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SHIFT_DATES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SHIFT_TIMES:= TSK_RM_SHIFT_TIMES- 1;
      IF TSK_RM_SHIFT_TIMES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SHIFT_TIMES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SHIFT_EXCEPTIONS:= TSK_RM_SHIFT_EXCEPTIONS- 1;
      IF TSK_RM_SHIFT_EXCEPTIONS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SHIFT_EXCEPTIONS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_CALENDAR_ASSIGNMENTS:= TSK_RM_CALENDAR_ASSIGNMENTS- 1;
      IF TSK_RM_CALENDAR_ASSIGNMENTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CALENDAR_ASSIGNMENTS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER= TASK_CATEGORY THEN

      TSK_RM_ITEM_CATEGORIES:= TSK_RM_ITEM_CATEGORIES- 1;
      IF TSK_RM_ITEM_CATEGORIES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_ITEM_CATEGORIES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_CATEGORY_SETS:= TSK_RM_CATEGORY_SETS- 1;
      IF TSK_RM_CATEGORY_SETS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CATEGORY_SETS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER= TASK_MDS_DEMAND THEN

      TSK_RM_DEMANDS:= TSK_RM_DEMANDS- 1;
      IF TSK_RM_DEMANDS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_DEMANDS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER= TASK_WIP_DEMAND THEN

      TSK_RM_DEMANDS:= TSK_RM_DEMANDS- 1;
      IF TSK_RM_DEMANDS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_DEMANDS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER in (TASK_SALES_ORDER1,TASK_SALES_ORDER2,TASK_SALES_ORDER3,TASK_AHL) THEN

      TSK_RM_SALES_ORDERS:= TSK_RM_SALES_ORDERS- 1;
      IF TSK_RM_SALES_ORDERS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SALES_ORDERS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER= TASK_HARD_RESERVATION THEN

      TSK_RM_RESERVATIONS:= TSK_RM_RESERVATIONS- 1;
      IF TSK_RM_RESERVATIONS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_RESERVATIONS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER IN ( TASK_ITEM1, TASK_ITEM2, TASK_ITEM3) THEN

      TSK_RM_SYSTEM_ITEMS:= TSK_RM_SYSTEM_ITEMS- 1;
      IF TSK_RM_SYSTEM_ITEMS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SYSTEM_ITEMS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_BUYER_CONTACT THEN

      TSK_RM_PARTNER_CONTACTS:= TSK_RM_PARTNER_CONTACTS- 1;
      IF TSK_RM_PARTNER_CONTACTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_PARTNER_CONTACTS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_RESOURCE THEN

      TSK_RM_DEPARTMENT_RESOURCES:= TSK_RM_DEPARTMENT_RESOURCES- 1;
      IF TSK_RM_DEPARTMENT_RESOURCES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_DEPARTMENT_RESOURCES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SIMULATION_SETS:= TSK_RM_SIMULATION_SETS- 1;
      IF TSK_RM_SIMULATION_SETS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SIMULATION_SETS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_RESOURCE_GROUPS:= TSK_RM_RESOURCE_GROUPS- 1;
      IF TSK_RM_RESOURCE_GROUPS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_RESOURCE_GROUPS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_RESOURCE_REQUIREMENTS:= TSK_RM_RESOURCE_REQUIREMENTS- 1;
      IF TSK_RM_RESOURCE_REQUIREMENTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_RESOURCE_REQUIREMENTS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_SAFETY_STOCK THEN

      TSK_RM_SAFETY_STOCKS:= TSK_RM_SAFETY_STOCKS- 1;
      IF TSK_RM_SAFETY_STOCKS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SAFETY_STOCKS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_SCHEDULE THEN

      TSK_RM_DESIGNATORS:= TSK_RM_DESIGNATORS- 1;
      IF TSK_RM_DESIGNATORS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_DESIGNATORS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_SOURCING THEN

      TSK_RM_ASSIGNMENT_SETS:= TSK_RM_ASSIGNMENT_SETS- 1;
      IF TSK_RM_ASSIGNMENT_SETS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_ASSIGNMENT_SETS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SR_ASSIGNMENTS:= TSK_RM_SR_ASSIGNMENTS- 1;
      IF TSK_RM_SR_ASSIGNMENTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SR_ASSIGNMENTS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SOURCING_RULES:= TSK_RM_SOURCING_RULES- 1;
      IF TSK_RM_SOURCING_RULES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SOURCING_RULES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SR_RECEIPT_ORG:= TSK_RM_SR_RECEIPT_ORG- 1;
      IF TSK_RM_SR_RECEIPT_ORG=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SR_RECEIPT_ORG',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SR_SOURCE_ORG:= TSK_RM_SR_SOURCE_ORG- 1;
      IF TSK_RM_SR_SOURCE_ORG=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SR_SOURCE_ORG',lv_pctg,lv_deg);
      END IF;

      TSK_RM_INTERORG_SHIP_METHODS:= TSK_RM_INTERORG_SHIP_METHODS- 1;
      IF TSK_RM_INTERORG_SHIP_METHODS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_INTERORG_SHIP_METHODS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_REGIONS := TSK_RM_REGIONS - 1;
      IF TSK_RM_REGIONS = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_REGIONS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_ZONE_REGIONS := TSK_RM_ZONE_REGIONS - 1;
      IF TSK_RM_ZONE_REGIONS = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_ZONE_REGIONS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_CARRIER_SERVICES:= TSK_RM_CARRIER_SERVICES- 1;
      IF TSK_RM_CARRIER_SERVICES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CARRIER_SERVICES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_REGION_SITES:= TSK_RM_REGION_SITES- 1;
      IF TSK_RM_REGION_SITES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_REGION_SITES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_SUB_INVENTORY THEN

      TSK_RM_SUB_INVENTORIES:= TSK_RM_SUB_INVENTORIES- 1;
      IF TSK_RM_SUB_INVENTORIES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SUB_INVENTORIES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_SUPPLIER_CAPACITY THEN

      TSK_RM_ITEM_SUPPLIERS:= TSK_RM_ITEM_SUPPLIERS- 1;
      IF TSK_RM_ITEM_SUPPLIERS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_ITEM_SUPPLIERS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SUPPLIER_CAPACITIES:= TSK_RM_SUPPLIER_CAPACITIES- 1;
      IF TSK_RM_SUPPLIER_CAPACITIES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SUPPLIER_CAPACITIES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_SUPPLIER_FLEX_FENCES:= TSK_RM_SUPPLIER_FLEX_FENCES- 1;
      IF TSK_RM_SUPPLIER_FLEX_FENCES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SUPPLIER_FLEX_FENCES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER IN ( TASK_PO_SUPPLY, TASK_WIP_SUPPLY, TASK_OH_SUPPLY, TASK_MPS_SUPPLY, TASK_PO_PO_SUPPLY, TASK_PO_REQ_SUPPLY) THEN

      TSK_RM_SUPPLIES:= TSK_RM_SUPPLIES- 1;
      IF TSK_RM_SUPPLIES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SUPPLIES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_JOB_OP_NETWORKS := TSK_RM_JOB_OP_NETWORKS - 1;
      IF TSK_RM_JOB_OP_NETWORKS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_JOB_OPERATION_NETWORKS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_JOB_OPERATIONS := TSK_RM_JOB_OPERATIONS - 1;
      IF TSK_RM_JOB_OPERATIONS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_JOB_OPERATIONS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_JOB_REQUIREMENT_OPS := TSK_RM_JOB_REQUIREMENT_OPS - 1;
      IF TSK_RM_JOB_REQUIREMENT_OPS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_JOB_REQUIREMENT_OPS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_JOB_OP_RESOURCES := TSK_RM_JOB_OP_RESOURCES - 1;
      IF TSK_RM_JOB_OP_RESOURCES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_JOB_OP_RESOURCES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_TRADING_PARTNER THEN

      TSK_RM_TRADING_PARTNERS:= TSK_RM_TRADING_PARTNERS- 1;
      IF TSK_RM_TRADING_PARTNERS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_TRADING_PARTNERS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_TRADING_PARTNER_SITES:= TSK_RM_TRADING_PARTNER_SITES- 1;
      IF TSK_RM_TRADING_PARTNER_SITES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_TRADING_PARTNER_SITES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_LOCATION_ASSOCIATIONS:= TSK_RM_LOCATION_ASSOCIATIONS- 1;
      IF TSK_RM_LOCATION_ASSOCIATIONS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_LOCATION_ASSOCIATIONS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_PARTNER_CONTACTS:= TSK_RM_PARTNER_CONTACTS- 1;
      IF TSK_RM_PARTNER_CONTACTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_PARTNER_CONTACTS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_UNIT_NUMBER THEN

      TSK_RM_UNIT_NUMBERS:= TSK_RM_UNIT_NUMBERS- 1;
      IF TSK_RM_UNIT_NUMBERS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_UNIT_NUMBERS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_PROJECT THEN

      TSK_RM_PROJECTS:= TSK_RM_PROJECTS- 1;
      IF TSK_RM_PROJECTS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_PROJECTS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_PROJECT_TASKS:= TSK_RM_PROJECT_TASKS- 1;
      IF TSK_RM_PROJECT_TASKS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_PROJECT_TASKS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_PARAMETER THEN

      TSK_RM_PARAMETERS:= TSK_RM_PARAMETERS- 1;
      IF TSK_RM_PARAMETERS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_PARAMETERS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_UOM THEN

      TSK_RM_UNITS_OF_MEASURE:= TSK_RM_UNITS_OF_MEASURE- 1;
      IF TSK_RM_UNITS_OF_MEASURE=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_UNITS_OF_MEASURE',lv_pctg,lv_deg);
      END IF;

      TSK_RM_UOM_CLASS_CONVERSIONS:= TSK_RM_UOM_CLASS_CONVERSIONS- 1;
      IF TSK_RM_UOM_CLASS_CONVERSIONS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_UOM_CLASS_CONVERSIONS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_UOM_CONVERSIONS:= TSK_RM_UOM_CONVERSIONS- 1;
      IF TSK_RM_UOM_CONVERSIONS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_UOM_CONVERSIONS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_BIS THEN

      TSK_RM_BIS_PERIODS:= TSK_RM_BIS_PERIODS- 1;
      IF TSK_RM_BIS_PERIODS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BIS_PERIODS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_BIS_PFMC_MEASURES:= TSK_RM_BIS_PFMC_MEASURES- 1;
      IF TSK_RM_BIS_PFMC_MEASURES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BIS_PFMC_MEASURES',lv_pctg,lv_deg);
      END IF;

      TSK_RM_BIS_TARGET_LEVELS:= TSK_RM_BIS_TARGET_LEVELS- 1;
      IF TSK_RM_BIS_TARGET_LEVELS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BIS_TARGET_LEVELS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_BIS_TARGETS:= TSK_RM_BIS_TARGETS- 1;
      IF TSK_RM_BIS_TARGETS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BIS_TARGETS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_BIS_BUSINESS_PLANS:= TSK_RM_BIS_BUSINESS_PLANS- 1;
      IF TSK_RM_BIS_BUSINESS_PLANS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_BIS_BUSINESS_PLANS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_ATP_RULES THEN

      TSK_RM_ATP_RULES:= TSK_RM_ATP_RULES- 1;
      IF TSK_RM_ATP_RULES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_ATP_RULES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_USER_SUPPLY THEN

      TSK_RM_SUPPLIES:= TSK_RM_SUPPLIES- 1;
      IF TSK_RM_SUPPLIES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SUPPLIES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_USER_DEMAND THEN

      TSK_RM_DEMANDS:= TSK_RM_DEMANDS- 1;
      IF TSK_RM_DEMANDS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_DEMANDS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_PLANNERS THEN

      TSK_RM_PLANNERS:= TSK_RM_PLANNERS- 1;
      IF TSK_RM_PLANNERS=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_PLANNERS',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_DEMAND_CLASS THEN

      TSK_RM_DEMAND_CLASSES:= TSK_RM_DEMAND_CLASSES- 1;
      IF TSK_RM_DEMAND_CLASSES=0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_DEMAND_CLASSES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_ITEM_SUBSTITUTES THEN

      TSK_RM_ITEM_SUBSTITUTES := TSK_RM_ITEM_SUBSTITUTES - 1;
      IF TSK_RM_ITEM_SUBSTITUTES = 0 THEN
         FND_STATS.gather_table_stats(lv_owner,'MSC_ST_ITEM_SUBSTITUTES',lv_pctg,lv_deg);
      END IF;

   ELSIF pTASK_NUMBER = TASK_TRIP THEN

      TSK_RM_TRIPS := TSK_RM_TRIPS - 1;
      IF TSK_RM_TRIPS = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_TRIPS',lv_pctg,lv_deg);
      END IF;

      TSK_RM_TRIP_STOPS := TSK_RM_TRIP_STOPS - 1;
      IF TSK_RM_TRIP_STOPS = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_TRIP_STOPS',lv_pctg,lv_deg);
      END IF;
  /* ds change start */
  ELSIF pTASK_NUMBER = TASK_RESOURCE_INSTANCE THEN
    TSK_RM_RESOURCE_INSTANCE := TSK_RM_RESOURCE_INSTANCE -1;
    IF TSK_RM_RESOURCE_INSTANCE = 0 THEN
	 FND_STATS.gather_table_stats(lv_owner, 'MSC_ST_DEPT_RES_INSTANCES',lv_pctg,lv_deg);
	 FND_STATS.gather_table_stats(lv_owner, 'MSC_ST_RESOURCE_INSTANCE_REQS',lv_pctg,lv_deg);
	 FND_STATS.gather_table_stats(lv_owner, 'MSC_ST_JOB_OP_RES_INSTANCES',lv_pctg,lv_deg);
    END IF;
  ELSIF pTASK_NUMBER = TASK_RESOURCE_SETUP THEN
    TSK_RM_RESOURCE_SETUP := TSK_RM_RESOURCE_SETUP -1;
    IF TSK_RM_RESOURCE_SETUP = 0 THEN
         FND_STATS.gather_table_stats(lv_owner, 'MSC_ST_RESOURCE_SETUPS',lv_pctg,lv_deg);
         FND_STATS.gather_table_stats(lv_owner, 'MSC_ST_SETUP_TRANSITIONS',lv_pctg,lv_deg);
         FND_STATS.gather_table_stats(lv_owner, 'MSC_ST_STD_OP_RESOURCES',lv_pctg,lv_deg);
    END IF;
    /* ds change end */
   ELSIF pTASK_NUMBER = TASK_ABC_CLASSES THEN
      TSK_RM_ABC_CLASSES := TSK_RM_ABC_CLASSES - 1;
      IF TSK_RM_ABC_CLASSES =0 THEN
      FND_STATS.gather_table_stats(lv_owner, 'MSC_ST_ABC_CLASSES',lv_pctg,lv_deg);
      END IF;

  ELSIF pTASK_NUMBER = TASK_FISCAL_CALENDAR THEN
      TSK_RM_FISCAL_CALENDAR := TSK_RM_FISCAL_CALENDAR - 1;
      IF TSK_RM_FISCAL_CALENDAR = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CALENDAR_MONTHS',lv_pctg,lv_deg);
      END IF;

  ELSIF pTASK_NUMBER = TASK_SALES_CHANNEL THEN
      TSK_RM_SALES_CHANNEL := TSK_RM_SALES_CHANNEL - 1;
      IF TSK_RM_SALES_CHANNEL = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SR_LOOKUPS',lv_pctg,lv_deg);
      END IF;

  ELSIF pTASK_NUMBER = TASK_IRO THEN
      TSK_RM_INTERNAL_REPAIR  := TSK_RM_INTERNAL_REPAIR  - 1;
      IF TSK_RM_INTERNAL_REPAIR  = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_SUPPLIES',lv_pctg,lv_deg);
      END IF;

  ELSIF pTASK_NUMBER = TASK_IRO_DEMAND THEN
      TSK_RM_INTERNAL_REPAIR := TSK_RM_INTERNAL_REPAIR - 1;
      IF TSK_RM_INTERNAL_REPAIR = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_DEMANDS',lv_pctg,lv_deg);
      END IF;
  ELSIF pTASK_NUMBER = TASK_PAYBACK_DEMAND_SUPPLY THEN
      TSK_RM_PAYBACK_DEMAND_SUPPLY := TSK_RM_PAYBACK_DEMAND_SUPPLY - 1;
      IF TSK_RM_PAYBACK_DEMAND_SUPPLY = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_OPEN_PAYBACKS',lv_pctg,lv_deg);
      END IF;
  ELSIF pTASK_NUMBER = TASK_CURRENCY_CONVERSION THEN
      TSK_RM_CURRENCY_CONVERSION := TSK_RM_CURRENCY_CONVERSION - 1;
      IF TSK_RM_CURRENCY_CONVERSION = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_CURRENCY_CONVERSIONS',lv_pctg,lv_deg);
      END IF;
  ELSIF pTASK_NUMBER = TASK_DELIVERY_DETAILS THEN
      TSK_RM_DELIVERY_DETAILS := TSK_RM_DELIVERY_DETAILS - 1;
      IF TSK_RM_DELIVERY_DETAILS = 0 THEN
         FND_STATS.gather_table_stats( lv_owner,'MSC_ST_DELIVERY_DETAILS',lv_pctg,lv_deg);
      END IF;
  END IF;


   END ANALYZE_ST_TABLE;

/* ds_plan: change end */

END MSC_CL_PULL;

/
