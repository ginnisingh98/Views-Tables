--------------------------------------------------------
--  DDL for Package Body MSC_CL_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_COLLECTION" AS -- body
/* $Header: MSCCLBAB.pls 120.86.12010000.8 2010/03/19 13:08:46 vsiyer ship $ */

  -- ========= Global Parameters ===========

   --Instace --

--   v_process_flag               NUMBER:= MSC_UTIL.SYS_NO;
-- resource start time
   v_resource_start_time                DATE;

   -- User Environment --



   -- Collection Program --

     --- PREPLACE CHANGE START ---


--agmcont:

   v_cp_enabled                  NUMBER;
    v_recalc_sh                   NUMBER;
   v_po_receipts                 NUMBER;
   v_monitor_request_id          NUMBER;
    v_req_ext_po_so_linking       BOOLEAN;


   -- collection status --
    -- Task Control --
   v_pipe_task_que               VARCHAR2(32);
   v_pipe_wm                     VARCHAR2(32);
   v_pipe_mw                     VARCHAR2(32);
   v_pipe_status                 VARCHAR2(32);

   -- Misc --
   v_sql_stmt                    VARCHAR2(32767);

   v_sourcing                    NUMBER;   /* sourcing rule flag */


   v_chr9                        VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(9);




   SUPPLIES_LOAD_FAIL            EXCEPTION;

     /* added this variable to write the debug messages */
   var_debug  number:= 0;

   -- SCE Additions --


  -- SRP Additions


   -- To collect SRP Data when this profile is set to Yes


-- agmcont
   -- forward declaration
--   v_DSMode		NUMBER := MSC_UTIL.SYS_NO;



  -- =========== Private Functions =============

FUNCTION alter_temp_table_by_monitor RETURN BOOLEAN
IS

   CURSOR c_temp_tbl IS
   SELECT meaning table_name,
          attribute1 severity,
          attribute2 severity_id
   FROM   fnd_lookup_values
   WHERE  lookup_type = 'MSC_TEMP_PARTITIONS' AND
          enabled_flag = 'Y' AND
          view_application_id = 700 AND
          language = userenv('lang');

   lv_req_id	NumTblTyp := NumTblTyp();
   lv_request_id	NUMBER;
   lv_out		NUMBER;

   lv_retval 		boolean;
   lv_dummy1 		varchar2(32);
   lv_dummy2 		varchar2(32);
   lv_msc_schema 	varchar2(30);
   lv_prod_short_name   varchar2(30);
   lv_counter		number := 1;


BEGIN
   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'alter_temp_table_by_monitor');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

   lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(724);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Product short name - ' || lv_prod_short_name);

   lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_msc_schema);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'MSC schema - ' || lv_msc_schema);

   FOR c_rec IN c_temp_tbl LOOP
      IF c_rec.table_name = 'MSC_SALES_ORDERS' AND v_is_so_complete_refresh = FALSE THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'sales orders being collected in net change, exch partition not applicable');
      ELSE
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'Launching CP to alter table - ' || c_rec.table_name);

         lv_req_id.EXTEND(1);
         lv_request_id := FND_REQUEST.SUBMIT_REQUEST
                                   (lv_msc_schema,   -- appln short name
                                    'MSCALTBL',      -- short name of conc pgm
                                    NULL,   -- description
                                    NULL,   -- start date
                                    FALSE,  -- sub request
                                    c_rec.table_name,
                                    v_instance_code,
                                    c_rec.severity_id
                                   );

         COMMIT;
         IF lv_request_id = 0 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_ALT_TMP_TABLE_LAUNCH_FAIL');
            FND_MESSAGE.SET_TOKEN('TABLE_NAME', c_rec.table_name);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);
            RETURN FALSE;
         ELSE
            lv_req_id(lv_counter) := lv_request_id;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'Submitted request ' || lv_req_id(lv_counter) || ', to alter table : ' || c_rec.table_name);
         END IF;
         lv_counter := lv_counter + 1;
      END IF;

   END LOOP;

   FOR j IN 1..lv_req_id.COUNT LOOP
      mrp_cl_refresh_snapshot.wait_for_request(lv_req_id(j), 30, lv_out);

      IF lv_out = 2 THEN
         FND_MESSAGE.SET_NAME('MSC', 'MSC_ALT_TMP_TABLE_REQ_FAIL');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID', lv_req_id(j));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);
         RETURN FALSE;
      ELSE
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'Request ' || lv_req_id(j) || ' successful');
      END IF;

   END LOOP;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,'end fn alter_temp_table_by_monitor');
   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error in altering temp table');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, sqlerrm);
      RETURN FALSE;

END alter_temp_table_by_monitor;

  /* REsource Start Time changes
     Get the refresh date from mrp_ap_apps_instances and
     update the msc_apps_instances collections_start_time*/
    PROCEDURE SET_COLLECTIONS_START_TIME(pINSTANCE_ID in number,
                                         p_resource_start_time out NOCOPY date)
    IS
       lv_sql_stmt  varchar2(32767);
       lv_dblink  varchar2(50);
       lv_resource_start_time  DATE := SYSDATE;
       lv_dest_a2m      varchar2(128);
       lv_instance_code  varchar2(10);
       lv_table_name         VARCHAR2(100);
       lv_res_avail_before_sysdate NUMBER; -- Days
       lv_collection_start_time DATE;
       lv_COLL_PULL_START_TIME  DATE;  --For Bug 6126924

     BEGIN
 	SELECT DECODE(M2A_DBLINK,
 		NULL,MSC_UTIL.NULL_DBLINK,
 		'@'||M2A_DBLINK),
 		DECODE( A2M_DBLINK,
                        NULL,MSC_UTIL.NULL_DBLINK,
                        A2M_DBLINK),
                INSTANCE_CODE
 	INTO lv_dblink,
 	     lv_dest_a2m,
 	     lv_instance_code
 	FROM MSC_APPS_INSTANCES
 	WHERE INSTANCE_ID=pINSTANCE_ID;

 	 IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN
       lv_table_name := 'MRP_AP_APPS_INSTANCES_ALL';
    ELSE
        lv_table_name := 'MRP_AP_APPS_INSTANCES';
    END IF;

 	 lv_res_avail_before_sysdate := nvl(TO_NUMBER(FND_PROFILE.VAlUE('MSC_RES_AVAIL_BEFORE_SYSDAT')),1);

 	 IF v_instance_type <> MSC_UTIL.G_INS_OTHER  THEN
         lv_sql_stmt:=   'SELECT  nvl(mar.LRD,sysdate)- '||lv_res_avail_before_sysdate
          	       ||' FROM '||lv_table_name||lv_dblink||' mar'
                       ||' WHERE INSTANCE_ID = '||pINSTANCE_ID
                       ||' AND INSTANCE_CODE = '''||lv_instance_code||''''
                       ||' AND nvl(A2M_DBLINK,'''||MSC_UTIL.NULL_DBLINK||''') = '''||lv_dest_a2m||'''' ;

		 EXECUTE IMMEDIATE lv_sql_stmt INTO lv_resource_start_time;


          SELECT  nvl(COLLECTIONS_START_TIME,sysdate)
          INTO  lv_collection_start_time
          FROM msc_coll_parameters
          where instance_id = pINSTANCE_ID;
          /* For Bug 6141966 */
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' last asl  refresh time is '|| lv_collection_start_time); --ASL
		END IF;

		 IF v_instance_type = MSC_UTIL.G_INS_OTHER  THEN
				 			lv_resource_start_time := lv_resource_start_time - nvl(lv_res_avail_before_sysdate,1);
				 			lv_collection_start_time:= SYSDATE;
		 END IF;

		 UPDATE MSC_APPS_INSTANCES
		 SET COLLECTIONS_START_TIME= lv_collection_start_time
		 where instance_id = pINSTANCE_ID;
		 /*ASL */

		 IF ((v_coll_prec.app_supp_cap_flag=MSC_UTIL.SYS_YES or v_coll_prec.app_supp_cap_flag=MSC_UTIL.ASL_YES_RETAIN_CP) AND NOT v_is_legacy_refresh) THEN
 		lv_sql_stmt := 'UPDATE MSC_INSTANCE_ORGS '
        	||' SET last_succ_asl_ref_time = :lv_collection_start_time'
		||' WHERE sr_instance_id = ' || pINSTANCE_ID
		|| ' AND ORGANIZATION_ID ' || MSC_UTIL.v_in_org_str ;

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,  'sql statement is ' || lv_sql_stmt);
		EXECUTE IMMEDIATE lv_sql_stmt USING lv_collection_start_time;
		 END IF ;

    /*IRO  Bug 6126698*/

		 IF ((v_coll_prec.internal_repair_flag=MSC_UTIL.SYS_YES ) AND NOT v_is_legacy_refresh) THEN
       		lv_sql_stmt := 'UPDATE MSC_INSTANCE_ORGS '
              	||' SET LAST_SUCC_IRO_REF_TIME = :lv_collection_start_time'
      		||' WHERE sr_instance_id = ' || pINSTANCE_ID
      		|| ' AND ORGANIZATION_ID ' || MSC_UTIL.v_depot_org_str ;

      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,  'sql statement is ' || lv_sql_stmt);
      		EXECUTE IMMEDIATE lv_sql_stmt USING lv_collection_start_time;
		 END IF ;

     /* Res Bug 6144734 */
     IF ((v_coll_prec.reserves_flag = MSC_UTIL.SYS_YES ) AND NOT v_is_legacy_refresh) THEN
       		lv_sql_stmt := 'UPDATE MSC_INSTANCE_ORGS '
              	||' SET LAST_SUCC_RES_REF_TIME = :lv_collection_start_time'
      		||' WHERE sr_instance_id = ' || pINSTANCE_ID
      		|| ' AND ORGANIZATION_ID ' || MSC_UTIL.v_in_org_str ;

      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,  'sql statement is ' || lv_sql_stmt);
      		EXECUTE IMMEDIATE lv_sql_stmt USING lv_collection_start_time;
		 END IF ;

		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,  'Item Flag  ' || v_coll_prec.Item_flag);
		  IF (v_coll_prec.Item_flag=MSC_UTIL.SYS_YES AND NOT v_is_legacy_refresh) THEN
 		lv_sql_stmt := 'UPDATE MSC_INSTANCE_ORGS '
		||' SET LAST_SUCC_ITEM_REF_TIME = :lv_collection_start_time'
		||' WHERE sr_instance_id = ' || pINSTANCE_ID
		|| ' AND ORGANIZATION_ID ' || MSC_UTIL.v_in_org_str ;
 		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,  'sql statement is ' || lv_sql_stmt);
 		EXECUTE IMMEDIATE lv_sql_stmt USING lv_collection_start_time;
		 END IF ;

		 --=============  For Bug 6126924

       SELECT PULL_WRKR_START_TIME into lv_COLL_PULL_START_TIME
        from msc_coll_parameters
        where INSTANCE_ID = pINSTANCE_ID;

       UPDATE  msc_apps_instances
        SET PULL_WRKR_START_TIME = lv_COLL_PULL_START_TIME,
            SNAP_REF_START_TIME  = lv_collection_start_time
        where instance_id = pINSTANCE_ID;

		 --=============

     /*ASL */

		 p_resource_start_time := lv_resource_start_time;
		 commit;

		 EXCEPTION
		   WHEN OTHERS THEN
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, SQLERRM);
	    END SET_COLLECTIONS_START_TIME;



	 /* removed LINK_SUPP_SO_DEMAND_EXT for bug5952569  and placed in
	    package MSC_CL_DEMAND_ODS_LOAD */
  -- ******************************

   /* removed LINK_SUPP_SO_DEMAND_110 for bug5952569  and placed in
	    package MSC_CL_DEMAND_ODS_LOAD */

	/* removed LINK_SUPP_SO_DEMAND_11I2 for bug5952569  and placed in
	    package MSC_CL_DEMAND_ODS_LOAD */



	FUNCTION PURGE_STAGING (pINSTANCE_ID in  number)
	RETURN boolean
	IS
	      lvs_request_id number;

	      l_call_status boolean;

	      l_phase            varchar2(80);
	      l_status           varchar2(80);
	      l_dev_phase        varchar2(80);
	      l_dev_status       varchar2(80);
	      l_message          varchar2(2048);
	BEGIN

		lvs_request_id := FND_REQUEST.SUBMIT_REQUEST(
				     'MSC',
				     'MSCPDCP',
				     NULL,  -- description
				     NULL,  -- start date
				     FALSE, -- not a sub request,
				     pINSTANCE_ID,
				     MSC_UTIL.SYS_YES);  -- validation=sys_yes

		COMMIT;

		IF lvs_request_id=0 THEN
		   FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_LAUNCH_PURGER_FAIL');
		   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
		   RETURN FALSE;
		ELSE
		   FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_PURGER_REQUEST_ID');
		   FND_MESSAGE.SET_TOKEN('REQUEST_ID', lvs_request_id);
		   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
		END IF;

	     LOOP
		      /* come out of function only when the MSCPDCP is complete - reqd for Collections incompatibility */

		  l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
				      ( lvs_request_id,
					NULL,
					NULL,
					l_phase,
					l_status,
					l_dev_phase,
					l_dev_status,
					l_message);

		   IF (l_call_status=FALSE) THEN
			   FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_LAUNCH_PURGER_FAIL');
			   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

			   FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUNNING');
			   FND_MESSAGE.SET_TOKEN('REQUEST_ID',lvs_request_id);
			   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

			   FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
			   FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
			   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

		      RETURN FALSE;
		   END IF;

		   EXIT WHEN l_dev_phase = 'COMPLETE';

	     END LOOP;

	 RETURN TRUE;

	EXCEPTION
	  WHEN OTHERS THEN
	       FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_LAUNCH_PURGER_FAIL');
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	       RETURN FALSE;
	END PURGE_STAGING;


/* procedure IS_SUPPLIES_LOAD_DONE has been moved to package  MSC_CL_SUPPLY_ODS_LOAD
 through bug5952569 */

/* procedure LINK_SUPPLY_TOP_LINK_IDhas been moved to package  MSC_CL_SETUP_ODS_LOAD
 through bug5952569 */

/* ds change chaneg end */

/* procedure create_supplies_tmp_ind has been moved to package  MSC_CL_SUPPLY_ODS_LOAD
 through bug5952569 */
/* procedure drop_supplies_tmp_ind has been moved to package  MSC_CL_SUPPLY_ODS_LOAD
 through bug5952569 */

/* function drop_demands_tmp_ind has been moved to package MSC_CL_DEMAND_ODS_LOAD
  (bug5952569) */

  /* function drop_sales_orders_tmp_ind has been moved to package MSC_CL_DEMAND_ODS_LOAD
  (bug5952569) */

--****************************
	   PROCEDURE LOG_MESSAGE(pSOURCE                 IN  NUMBER,
				 pID                     IN  NUMBER,
				 pCREATION_DATE          IN  DATE,
				 pMTYPE                  IN  NUMBER,
				 pERRBUF                 IN  VARCHAR2)
	   IS
	      SEQ NUMBER;
	   BEGIN

	      SELECT MSC_ERRORS_S.NEXTVAL
		INTO SEQ
		FROM DUAL;

	      IF fnd_global.conc_request_id > 0  THEN

		 FND_FILE.PUT_LINE( FND_FILE.LOG,
				    TO_CHAR(SEQ)||':'
				    ||TO_CHAR(pID)||':'
				    ||TO_CHAR(pMTYPE)||':'
				    ||pERRBUF );
                null;

	      END IF;
	   EXCEPTION
	     WHEN OTHERS THEN
		RETURN;
	   END LOG_MESSAGE;


	   PROCEDURE LOG_MESSAGE(pSOURCE                 IN  NUMBER,
				 pID                     IN  NUMBER,
				 pCREATION_DATE          IN  DATE,
				 pMTYPE                  IN  NUMBER,
				 pPROCEDURE_NAME         IN  VARCHAR2,
				 pEXCEPTION_TYPE         IN  VARCHAR2 := NULL,
				 pSEGMENT1               IN  VARCHAR2 := NULL,
				 pSEGMENT2               IN  VARCHAR2 := NULL,
				 pSEGMENT3               IN  VARCHAR2 := NULL,
				 pSEGMENT4               IN  VARCHAR2 := NULL,
				 pSEGMENT5               IN  VARCHAR2 := NULL,
				 pSEGMENT6               IN  VARCHAR2 := NULL,
				 pSEGMENT7               IN  VARCHAR2 := NULL,
				 pSEGMENT8               IN  VARCHAR2 := NULL,
				 pSEGMENT9               IN  VARCHAR2 := NULL,
				 pSEGMENT10              IN  VARCHAR2 := NULL)
	   IS
	      SEQ NUMBER;
	   BEGIN

	      SELECT MSC_ERRORS_S.NEXTVAL
		INTO SEQ
		FROM DUAL;

	      IF fnd_global.conc_request_id > 0  THEN

		FND_FILE.PUT_LINE( FND_FILE.LOG,
				   TO_CHAR(SEQ)||':'
				   ||TO_CHAR(pID)||':'
				   ||TO_CHAR(pMTYPE)||':'
				   ||pPROCEDURE_NAME||':'
				   ||pEXCEPTION_TYPE||':'
				   ||pSEGMENT1||':'
				   ||pSEGMENT2||':'
				   ||pSEGMENT3||':'
				   ||pSEGMENT4||':'
				   ||pSEGMENT5||':'
				   ||pSEGMENT6||':'
				   ||pSEGMENT7||':'
				   ||pSEGMENT8||':'
				   ||pSEGMENT9||':'
				   ||pSEGMENT10||':');
                null;
	      END IF;
	   EXCEPTION
	     WHEN OTHERS THEN
		RETURN;
	   END LOG_MESSAGE;



	   FUNCTION is_monitor_status_running RETURN NUMBER
	   IS
	      l_call_status      boolean;
	      l_phase            varchar2(80);
	      l_status           varchar2(80);
	      l_dev_phase        varchar2(80);
	      l_dev_status       varchar2(80);
	      l_message          varchar2(2048);

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
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'IS_MONITOR_STATUS_RUNNING');

		 FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUN');
		 FND_MESSAGE.SET_TOKEN('REQUEST_ID', v_monitor_request_id);
		 FND_MESSAGE.SET_TOKEN('PHASE',l_dev_phase);
		 FND_MESSAGE.SET_TOKEN('STATUS',l_dev_status);
		 --MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

		 FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
		 FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

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
	      l_message          varchar2(2048);

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
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'IS_REQUEST_STATUS_RUNNING');

		 FND_MESSAGE.SET_NAME('MSC', 'MSC_FUNC_MON_RUN');
		 FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id);
		 FND_MESSAGE.SET_TOKEN('PHASE',l_dev_phase);
		 FND_MESSAGE.SET_TOKEN('STATUS',l_dev_status);
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

		 FND_MESSAGE.SET_NAME('MSC', 'MSC_CL_CONC_MESSAGE');
		 FND_MESSAGE.SET_TOKEN('MESSAGE',l_message);
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

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
	      l_message          varchar2(2048);

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

	   FUNCTION is_msctbl_partitioned ( p_table_name                  IN  VARCHAR2)
		    RETURN BOOLEAN
	   IS

	      lv_partitioned     VARCHAR2(3);

	      CURSOR c_partitioned IS
	      SELECT tab.partitioned
		FROM ALL_TABLES tab,
		     FND_ORACLE_USERID a,
		     FND_PRODUCT_INSTALLATIONS b
	       WHERE a.oracle_id = b.oracle_id
		 AND b.application_id= 724
		 AND tab.owner= a.oracle_username
		 AND tab.table_name= p_table_name;

	   BEGIN

	      OPEN c_partitioned;
	      FETCH c_partitioned INTO lv_partitioned;
	      CLOSE c_partitioned;

	      IF lv_partitioned='YES' THEN RETURN TRUE; END IF;
	      RETURN FALSE;
	   EXCEPTION
	      WHEN OTHERS THEN
		 RETURN FALSE;
	   END is_msctbl_partitioned;

/* function LINK_PARENT_SALES_ORDERS  has been moved to package MSC_CL_DEMAND_ODS_LOAD
  through bug5952569 */

  /* function LINK_PARENT_SALES_ORDERS_MDS  has been moved to package MSC_CL_DEMAND_ODS_LOAD
  through bug5952569 */



	 /* procedure CLEANSE_DATA been moved to package  MSC_CL_SETUP_ODS_LOAD
 through bug5952569 */

	PROCEDURE TRUNCATE_MSC_TABLE( p_table_name  IN VARCHAR2) IS

	    lv_sql_stmt     VARCHAR2(2048);

    lv_task_start_time DATE;
    lv_retval boolean;
    lv_dummy1 varchar2(32);
    lv_dummy2 varchar2(32);
    lv_msc_schema varchar2(32);

BEGIN

    lv_task_start_time:= SYSDATE;

    lv_retval := FND_INSTALLATION.GET_APP_INFO (
                           'MSC', lv_dummy1, lv_dummy2, lv_msc_schema);

    FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
    FND_MESSAGE.SET_TOKEN('PROCEDURE',
               'TRUNCATE_MSC_TABLE:'||lv_msc_schema||'.'||p_table_name);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '   '||FND_MESSAGE.GET);

       lv_sql_stmt:= 'TRUNCATE TABLE '||lv_msc_schema||'.'||p_table_name;

       EXECUTE IMMEDIATE lv_sql_stmt;
       COMMIT;

       /*
       AD_DDL.DO_DDL( APPLSYS_SCHEMA => lv_msc_schema,
                      APPLICATION_SHORT_NAME => 'MSC',
                      STATEMENT_TYPE => AD_DDL.TRUNCATE_TABLE,
                      STATEMENT => lv_sql_stmt,
                      OBJECT_NAME => p_table_name);
       */


     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                 TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '   '||FND_MESSAGE.GET);

         msc_util.print_top_wait(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
         msc_util.print_cum_stat(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
         msc_util.print_bad_sqls(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
END TRUNCATE_MSC_TABLE;



PROCEDURE INITIALIZE_LOAD_GLOBALS( pINSTANCE_ID       IN NUMBER)
   IS
      lv_last_refresh_type     VARCHAR2(1);
      lv_so_last_refresh_type  VARCHAR2(1);
      lv_retval             BOOLEAN;
      lv_dummy1             VARCHAR2(32);
      lv_dummy2             VARCHAR2(32);
   BEGIN

      SELECT LRTYPE,
             SO_LRTYPE,
             APPS_VER,
             SYSDATE,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             UPPER(INSTANCE_CODE), /* Bug 2129155 */
             INSTANCE_TYPE,            -- OPM
             LR_SOURCING_FLAG          -- Sourcing Flag
        INTO lv_last_refresh_type,
             lv_so_last_refresh_type,
             v_apps_ver,
             START_TIME,
             v_current_date,
             v_current_user,
             v_current_date,
             v_current_user,
             v_instance_code,
             v_instance_type,          -- OPM
             v_sourcing_flag           -- Sourcing Flag
        FROM MSC_APPS_INSTANCES
       WHERE INSTANCE_ID= pINSTANCE_ID;

      --- PREPLACE CHANGE START ---
      /*
      IF lv_last_refresh_type= 'C' THEN
         v_is_complete_refresh    := TRUE;
         v_is_incremental_refresh := FALSE;
      ELSE
         v_is_complete_refresh    := FALSE;
         v_is_incremental_refresh := TRUE;
      END IF;
      */

--agmcont:
      v_is_cont_refresh := FALSE;
      IF lv_last_refresh_type = 'C' THEN
         v_is_complete_refresh    := TRUE;
         v_is_incremental_refresh := FALSE;
         v_is_partial_refresh     := FALSE;
      ELSIF lv_last_refresh_type = 'I' THEN
         v_is_complete_refresh    := FALSE;
         v_is_incremental_refresh := TRUE;
         v_is_partial_refresh     := FALSE;
      ELSIF lv_last_refresh_type = 'P' THEN
         v_is_complete_refresh    := FALSE;
         v_is_incremental_refresh := FALSE;
         v_is_partial_refresh     := TRUE;
      ELSIF lv_last_refresh_type = 'L' THEN   -- legacy change for L -flow
         v_is_complete_refresh    := FALSE;
         v_is_incremental_refresh := TRUE;    -- we will piggy ride on incremetal for legacy
         v_is_partial_refresh     := FALSE;
         v_is_legacy_refresh      := TRUE;
      ELSIF lv_last_refresh_type = 'T' THEN
         v_is_complete_refresh    := FALSE;
         v_is_incremental_refresh := FALSE;
         v_is_partial_refresh     := FALSE;
         v_is_cont_refresh        := TRUE;
      END IF;
      ---  PREPLACE CHANGE END  ---

--agmcont:
      -- so refresh flags for continuous refresh
      -- are set in launch_mon_partial and launch worker

      IF lv_so_last_refresh_type= 'C' THEN
         v_is_so_complete_refresh    := TRUE;
         v_is_so_incremental_refresh := FALSE;
      ELSE
         v_is_so_complete_refresh    := FALSE;
         v_is_so_incremental_refresh := TRUE;
      END IF;


      v_pipe_task_que := 'MSC_CL_TQ'||TO_CHAR(pINSTANCE_ID);
      v_pipe_wm      := 'MSC_CL_WM'||TO_CHAR(pINSTANCE_ID);
      v_pipe_mw      := 'MSC_CL_MW'||TO_CHAR(pINSTANCE_ID);
      v_pipe_status := 'MSC_CL_ST'||TO_CHAR(pINSTANCE_ID);

      v_instance_id := pINSTANCE_ID;
      PBS := TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));
   ---------------- Set Flags -----------------------------
    -- set the flags as to whether discrete and/or process
    -- manufacturing are being used in the same instance

    v_discrete_flag := MSC_UTIL.SYS_NO;
    v_process_flag  := MSC_UTIL.SYS_NO;
/************** LEGACY_CHANGE_START*************************/

    IF v_instance_type = MSC_UTIL.G_INS_DISCRETE OR
       v_instance_type = MSC_UTIL.G_INS_OTHER    OR
       v_instance_type = MSC_UTIL.G_INS_MIXED    THEN
       v_discrete_flag := MSC_UTIL.SYS_YES;
    END IF;

    IF v_instance_type = MSC_UTIL.G_INS_PROCESS OR
       v_instance_type = MSC_UTIL.G_INS_MIXED   THEN
       v_process_flag := MSC_UTIL.SYS_YES;
    END IF;
/*****************LEGACY_CHANGE_ENDS************************/

    lv_retval := FND_INSTALLATION.GET_APP_INFO(
                   'FND', lv_dummy1,lv_dummy2, v_applsys_schema);


   END INITIALIZE_LOAD_GLOBALS;


/* procedure TRANSFORM_KEYS has  been moved to package  MSC_CL_SETUP_ODS_LOAD
 through bug5952569 */

   FUNCTION SET_ST_STATUS( ERRBUF                          OUT NOCOPY VARCHAR2,
                           RETCODE                         OUT NOCOPY NUMBER,
                           pINSTANCE_ID                    IN  NUMBER,
                           pST_STATUS                      IN  NUMBER)
            RETURN BOOLEAN
   IS

      lv_staging_table_status NUMBER;

   BEGIN


---=================== COLLECTING ===========================
   IF pST_STATUS= MSC_UTIL.G_ST_COLLECTING THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'pST_STATUS = MSC_UTIL.G_ST_COLLECTING');
         SELECT mai.ST_STATUS
           INTO lv_staging_table_status
           FROM MSC_APPS_INSTANCES mai
          WHERE mai.INSTANCE_ID= pINSTANCE_ID
            FOR UPDATE;

         IF lv_staging_table_status= MSC_UTIL.G_ST_EMPTY THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'lv_staging_table_status = MSC_UTIL.G_ST_EMPTY');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_NO_DATA');
           ERRBUF:= FND_MESSAGE.GET;

           RETCODE := MSC_UTIL.G_WARNING;
           RETURN FALSE;

         ELSIF lv_staging_table_status= MSC_UTIL.G_ST_PULLING THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'lv_staging_table_status = MSC_UTIL.G_ST_PULLING');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PULLING');
           ERRBUF:= FND_MESSAGE.GET;

           RETCODE := MSC_UTIL.G_ERROR;
           RETURN FALSE;

         ELSIF lv_staging_table_status= MSC_UTIL.G_ST_COLLECTING THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'lv_staging_table_status = MSC_UTIL.G_ST_COLLECTING');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_LOADING');
           ERRBUF:= FND_MESSAGE.GET;

	   RETCODE := MSC_UTIL.G_ERROR;
           RETURN FALSE;

         ELSIF lv_staging_table_status= MSC_UTIL.G_ST_PURGING THEN
	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'lv_staging_table_status = MSC_UTIL.G_ST_PURGING');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PURGING');
           ERRBUF:= FND_MESSAGE.GET;

           RETCODE := MSC_UTIL.G_ERROR;
           RETURN FALSE;

         ELSE
	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' st status is success');
           RETCODE := MSC_UTIL.G_SUCCESS ;

           UPDATE MSC_APPS_INSTANCES
              SET ST_STATUS= MSC_UTIL.G_ST_COLLECTING,
                  LCID= MSC_COLLECTION_S.NEXTVAL,
                  LAST_UPDATE_DATE= v_current_date,
                  LAST_UPDATED_BY= v_current_user,
                  REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
            WHERE INSTANCE_ID= pINSTANCE_ID;

           SELECT MSC_COLLECTION_S.CURRVAL
             INTO v_last_collection_id
             FROM DUAL;

           RETURN TRUE;

         END IF;

---===================== PURGING ===================
   ELSIF pST_STATUS= MSC_UTIL.G_ST_PURGING THEN

	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' pST_STATUS= MSC_UTIL.G_ST_PURGING ');
         SELECT mai.ST_STATUS
           INTO lv_staging_table_status
           FROM MSC_APPS_INSTANCES mai
          WHERE mai.INSTANCE_ID= pINSTANCE_ID
            FOR UPDATE;

         IF lv_staging_table_status= MSC_UTIL.G_ST_EMPTY THEN
	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' lv_staging_table_status= MSC_UTIL.G_ST_EMPTY ');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_NO_DATA');
           ERRBUF:= FND_MESSAGE.GET;

           RETCODE := MSC_UTIL.G_WARNING;
           RETURN FALSE;

         ELSIF lv_staging_table_status= MSC_UTIL.G_ST_PULLING THEN
	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' lv_staging_table_status= MSC_UTIL.G_ST_PULLING ');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PULLING');
           ERRBUF:= FND_MESSAGE.GET;

           RETCODE := MSC_UTIL.G_ERROR;
           RETURN FALSE;

         ELSIF lv_staging_table_status= MSC_UTIL.G_ST_COLLECTING THEN
	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' lv_staging_table_status= MSC_UTIL.G_ST_COLLECTING ');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_DATA_EXIST');
           ERRBUF:= FND_MESSAGE.GET;

           RETCODE := MSC_UTIL.G_ERROR;
           RETURN FALSE;

         ELSIF lv_staging_table_status= MSC_UTIL.G_ST_PURGING THEN
	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' lv_staging_table_status= MSC_UTIL.G_ST_PURGING ');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PURGING');
           ERRBUF:= FND_MESSAGE.GET;

           RETCODE := MSC_UTIL.G_ERROR;
           RETURN FALSE;

         ELSE
           RETCODE := MSC_UTIL.G_SUCCESS ;
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' stsetup = success');
                 UPDATE MSC_APPS_INSTANCES
                    SET ST_STATUS= MSC_UTIL.G_ST_PURGING,
                        SO_TBL_STATUS= MSC_UTIL.SYS_YES,
                        LAST_UPDATE_DATE= v_current_date,
                        LAST_UPDATED_BY= v_current_user,
                        REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
                 WHERE INSTANCE_ID= pINSTANCE_ID;

         RETURN TRUE;

         END IF;

---===================== EMPTY ====================
   ELSIF pST_STATUS= MSC_UTIL.G_ST_EMPTY THEN
 	MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' pST_STATUS= MSC_UTIL.G_ST_EMPTY');
         UPDATE MSC_APPS_INSTANCES
            SET ST_STATUS= MSC_UTIL.G_ST_EMPTY,
                SO_TBL_STATUS= MSC_UTIL.SYS_YES,
                LAST_UPDATE_DATE= v_current_date,
                LAST_UPDATED_BY= v_current_user,
                REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
         WHERE INSTANCE_ID= pINSTANCE_ID;

       RETCODE:= MSC_UTIL.G_SUCCESS ;
       RETURN TRUE;

---===================== READY ====================
   ELSIF pST_STATUS= MSC_UTIL.G_ST_READY THEN
 	MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,' pST_STATUS= MSC_UTIL.G_ST_READY');
       UPDATE MSC_APPS_INSTANCES
          SET ST_STATUS= MSC_UTIL.G_ST_READY,
              LAST_UPDATE_DATE= v_current_date,
              LAST_UPDATED_BY= v_current_user,
              REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
        WHERE INSTANCE_ID= pINSTANCE_ID;

       RETCODE:= MSC_UTIL.G_SUCCESS ;
       RETURN TRUE;

   END IF;

   END SET_ST_STATUS;


   PROCEDURE INITIALIZE( pINSTANCE_ID NUMBER)
   IS
   BEGIN
       -- retaining this function as it might be called by other packages.
       INITIALIZE_LOAD_GLOBALS( pINSTANCE_ID);
   END INITIALIZE;

   PROCEDURE FINAL
   IS
   BEGIN

      UPDATE MSC_APPS_INSTANCES mai
         SET LAST_UPDATE_DATE= v_current_date,
             LAST_UPDATED_BY= v_current_user,
	     SUPPLIES_LOAD_FLAG = null,
             REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
       WHERE mai.INSTANCE_ID= v_instance_id;

     --- PREPLACE CHANGE START ---

--        DELETE FROM msc_coll_parameters
--        WHERE instance_id = v_instance_id;


     ---  PREPLACE CHANGE END  ---

   END FINAL;


PROCEDURE DELETE_MSC_TABLE( p_table_name            IN VARCHAR2,
                            p_instance_id           IN NUMBER,
                            p_plan_id               IN NUMBER:= NULL,
                            p_sub_str               IN VARCHAR2:= NULL) IS

    -- lv_cnt          NUMBER;
    lv_pbs          NUMBER;
    lv_sql_stmt     VARCHAR2(2048);

    lv_task_start_time DATE;

    lv_partition_name  VARCHAR2(30);
    lv_is_plan         NUMBER;

    lv_return_status   VARCHAR2(2048);
    lv_msg_data        VARCHAR2(2048);

BEGIN

    lv_task_start_time:= SYSDATE;

    FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
    FND_MESSAGE.SET_TOKEN('PROCEDURE', 'DELETE_MSC_TABLE:'||p_table_name);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '   '||FND_MESSAGE.GET);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, p_table_name||':'||p_sub_str);
    IF p_sub_str IS NULL AND
       is_msctbl_partitioned( p_table_name) THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug1');

       IF p_plan_id= -1 OR p_plan_id IS NULL THEN
          lv_is_plan:= MSC_UTIL.SYS_NO;
       ELSE
          lv_is_plan:= MSC_UTIL.SYS_YES;
       END IF;

       msc_manage_plan_partitions.get_partition_name
                         ( p_plan_id,
                           p_instance_id,
                           p_table_name,
                           lv_is_plan,
                           lv_partition_name,
                           lv_return_status,
                           lv_msg_data);


       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'parameters passed to get_partiton_name are');
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'p_plan_id'||p_plan_id);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'p_instance_id'||p_instance_id);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'p_table_name'||p_table_name);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'lv_is_plan'||lv_is_plan);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'lv_partition_name'||lv_partition_name);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'lv_return_status'||lv_return_status);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'lv_msg_data'||lv_msg_data);

       lv_sql_stmt:= 'ALTER TABLE '||p_table_name
                  ||' TRUNCATE PARTITION '||lv_partition_name;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,  lv_sql_stmt);

       AD_DDL.DO_DDL( APPLSYS_SCHEMA => v_applsys_schema,
                      APPLICATION_SHORT_NAME => 'MSC',
                      STATEMENT_TYPE => AD_DDL.ALTER_TABLE,
                      STATEMENT => lv_sql_stmt,
                      OBJECT_NAME => p_table_name);

    ELSE

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug2');
       lv_pbs:= TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug22:'||to_char(lv_pbs));

       IF p_plan_id IS NULL THEN

        /*  lv_sql_stmt:= 'SELECT COUNT(*)'
                   ||' FROM '||p_table_name
                   ||' WHERE SR_INSTANCE_ID= :p_instance_id '
                   ||  p_sub_str;

          EXECUTE IMMEDIATE lv_sql_stmt
                    INTO lv_cnt
                   USING p_instance_id; */


          IF lv_pbs IS NULL THEN

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug200');
             lv_sql_stmt:= 'DELETE '||p_table_name
                      ||' WHERE SR_INSTANCE_ID= :p_instance_id '
                      ||  p_sub_str;

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug3');
             EXECUTE IMMEDIATE lv_sql_stmt
                         USING p_instance_id;

             COMMIT;

          ELSE

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug4');
             lv_sql_stmt:=   'DELETE '||p_table_name
                         ||'  WHERE SR_INSTANCE_ID= :p_instance_id '
                         ||     p_sub_str
                         ||'    AND ROWNUM < :lv_pbs';

             LOOP
                EXECUTE IMMEDIATE lv_sql_stmt
                            USING p_instance_id, lv_pbs;

                EXIT WHEN SQL%ROWCOUNT= 0;
                COMMIT;

             END LOOP;
          END IF;  /* batch_size */

       ELSE  /* plan_id is not null */

        /*  lv_sql_stmt:= 'SELECT COUNT(*)'
                   ||' FROM '||p_table_name
                   ||' WHERE SR_INSTANCE_ID= :p_instance_id'
                   ||'   AND PLAN_ID= -1 '
                   ||    p_sub_str;

          EXECUTE IMMEDIATE lv_sql_stmt
                       INTO lv_cnt
                      USING p_instance_id; */

          IF lv_pbs IS NULL THEN

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug5');
             lv_sql_stmt:=  'DELETE '||p_table_name
                         ||'  WHERE SR_INSTANCE_ID= :lv_instance_id'
                         ||'    AND PLAN_ID= -1 '
                         ||   p_sub_str;

             EXECUTE IMMEDIATE lv_sql_stmt
                         USING p_instance_id;

             COMMIT;

          ELSE

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug300:'||p_sub_str);
             lv_sql_stmt:=   'DELETE '||p_table_name
                         ||'  WHERE SR_INSTANCE_ID= :p_instance_id '
                         ||'    AND PLAN_ID= -1 '
                         ||     p_sub_str
                         ||'    AND ROWNUM < :lv_pbs';

             LOOP

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug400:'||lv_sql_stmt);
                EXECUTE IMMEDIATE lv_sql_stmt
                            USING p_instance_id, lv_pbs;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug400');

                EXIT WHEN SQL%ROWCOUNT= 0;
                COMMIT;

             END LOOP;

          END IF;  /* batch_size */
        END IF;  /* plan_id */
     END IF;  /* is_msctbl_partitioned */

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                 TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '   '||FND_MESSAGE.GET);

     msc_util.print_top_wait(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
     msc_util.print_cum_stat(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
     msc_util.print_bad_sqls(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);

END DELETE_MSC_TABLE;

  -- ========== End of Private Functions ==============

  -- ========== Declare Local Procedures ==============

   PROCEDURE EXECUTE_TASK( pSTATUS                OUT NOCOPY NUMBER,
                           pTASKNUM               IN  NUMBER);

/* to delete
   PROCEDURE LOAD_NET_RESOURCE_AVAIL;
   PROCEDURE LOAD_PROCESS_EFFECTIVITY ;
   PROCEDURE LOAD_OPERATION_COMPONENTS ;
   PROCEDURE LOAD_OPERATION_NETWORKS ;
   PROCEDURE LOAD_BOR;*/

   /* CP-ACK starts */
   /* CP-ACK starts */

 /* to delete
   PROCEDURE LOAD_ITEM;
   PROCEDURE LOAD_ABC_CLASSES;

   PROCEDURE LOAD_SUB_INVENTORY;
   PROCEDURE LOAD_SOURCING;
   PROCEDURE LOAD_SUPPLIER_CAPACITY;
   PROCEDURE LOAD_CATEGORY;
   PROCEDURE LOAD_UNIT_NUMBER;
   PROCEDURE LOAD_SAFETY_STOCK;
   PROCEDURE LOAD_PROJECT;
   PROCEDURE LOAD_BIS_PFMC_MEASURES;
   PROCEDURE LOAD_BIS_TARGET_LEVELS;
   PROCEDURE LOAD_BIS_BUSINESS_PLANS;
   PROCEDURE LOAD_BIS_PERIODS;
   PROCEDURE LOAD_BIS_TARGETS;
   PROCEDURE LOAD_ATP_RULES;
   PROCEDURE LOAD_PLANNERS;
   PROCEDURE LOAD_DEMAND_CLASS;

   PROCEDURE LOAD_SALES_CHANNEL;
   PROCEDURE LOAD_FISCAL_CALENDAR;

   PROCEDURE LOAD_RES_REQ;    -- called by load_supply

   PROCEDURE LOAD_WIP_DEMAND; -- called by load_supply

   PROCEDURE LOAD_ITEM_SUBSTITUTES; --for Product substitution
   PROCEDURE LOAD_JOB_DETAILS; --for job details
   PROCEDURE LOAD_JOB_OP_NWK;
   PROCEDURE LOAD_JOB_OP;
   PROCEDURE LOAD_JOB_REQ_OP;
   PROCEDURE LOAD_JOB_OP_RES;
   PROCEDURE LOAD_TRIP;*/
   /* ds change change start */
/* to delete
   PROCEDURE LOAD_RES_INST_REQ;
   PROCEDURE LOAD_JOB_OP_RES_INSTANCE;
   PROCEDURE LOAD_RESOURCE_SETUP;
   PROCEDURE LOAD_RESOURCE_CHARGES;
   PROCEDURE LOAD_SETUP_TRANSITION;
   PROCEDURE LOAD_STD_OP_RESOURCES;*/
  /* ds change change end */

     /** PREPLACE CHANGE START **/
--agmcont:
   PROCEDURE EXECUTE_PARTIAL_TASK( pSTATUS                OUT NOCOPY NUMBER,
                                   pTASKNUM               IN  NUMBER,
                                   prec in MSC_CL_EXCHANGE_PARTTBL.CollParamRec);
            -- This procedure provides a separate flow for
            -- Partial Replacement.



     /**  PREPLACE CHANGE END  **/

-- =====Local Procedures =========

   -- ========= EXECUTE_TASK ==========

   /* LOAD_DESIGNATOR is moved to function TRANSFORM_KEYS */
   /* LOAD_UOM is moved to function TRANSFORM_KEYS */




   PROCEDURE EXECUTE_TASK( pSTATUS                OUT NOCOPY NUMBER,
                           pTASKNUM               IN  NUMBER)

   IS

   lv_task_start_time DATE;
   lv_lbj_details  NUMBER := 0;

   BEGIN


        lv_task_start_time:= SYSDATE;

         --SAVEPOINT ExecuteTask;

         pSTATUS := FAIL;

   -- ============= Execute the task according to its task number  ===========

         IF pTASKNUM= TASK_SUPPLY THEN

		  update msc_apps_instances
		  set SUPPLIES_LOAD_FLAG = G_JOB_NOT_DONE
		  where instance_id = v_instance_id;
		  commit;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY;

            IF v_is_complete_refresh AND v_exchange_mode=MSC_UTIL.SYS_NO THEN
                   -- DELETE_MSC_TABLE( 'MSC_RESOURCE_REQUIREMENTS', v_instance_id, -1);
                   -- DELETE_MSC_TABLE( 'MSC_DEMANDS', v_instance_id, -1 );

                   IF v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
                         DELETE_MSC_TABLE( 'MSC_RESOURCE_REQUIREMENTS', v_instance_id, -1);
                         DELETE_MSC_TABLE( 'MSC_DEMANDS', v_instance_id, -1 );
                   ELSE
                         v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
                         DELETE_MSC_TABLE( 'MSC_RESOURCE_REQUIREMENTS', v_instance_id, -1,v_sub_str);
                         DELETE_MSC_TABLE( 'MSC_DEMANDS', v_instance_id, -1 ,v_sub_str);
                   END IF;
			ELSIF v_is_complete_refresh AND v_exchange_mode=MSC_UTIL.SYS_YES THEN
                   IF v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
                         DELETE_MSC_TABLE( 'MSC_WO_ATTRIBUTES', v_instance_id, NULL );
                         DELETE_MSC_TABLE( 'MSC_WO_OPERATION_REL', v_instance_id, NULL );
                         DELETE_MSC_TABLE( 'MSC_WO_TASK_HIERARCHY', v_instance_id, NULL );
                   ELSE
                         v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
                         DELETE_MSC_TABLE( 'MSC_WO_ATTRIBUTES', v_instance_id, NULL ,v_sub_str);
                         DELETE_MSC_TABLE( 'MSC_WO_OPERATION_REL', v_instance_id, NULL ,v_sub_str);
                         DELETE_MSC_TABLE( 'MSC_WO_TASK_HIERARCHY', v_instance_id, NULL ,v_sub_str);

                   END IF;
            END IF;


             	IF ((v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (v_exchange_mode = MSC_UTIL.SYS_YES)) THEN
  --(irrelevant now)For Continious (as in execute_partial_task before calling LOAD_SUPPLY in Continious collections
--  exchange mode is set no) and incremental collections exchange_mode will be NO.The only left case is Complete collections.
                      FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY');
                      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                      MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY;

                END IF;

                  update msc_apps_instances
		  set SUPPLIES_LOAD_FLAG = G_JOB_DONE
		  where instance_id = v_instance_id;
		  commit;

		  MSC_CL_WIP_ODS_LOAD.LOAD_JOB_DETAILS;


         ELSIF pTASKNUM= TASK_MDS_DEMAND THEN

               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND;
	       ELSE
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading of Supplies failed.TASK_MDS_DEMAND');
		   RAISE SUPPLIES_LOAD_FAIL;
	       END IF;

         ELSIF pTASKNUM= TASK_ITEM_FORECASTS THEN

                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_ITEM_FORECASTS');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_DEMAND_ODS_LOAD.LOAD_ITEM_FORECASTS;

         ELSIF pTASKNUM= TASK_WIP_COMP_DEMAND THEN

               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_ODS_LOAD.LOAD_WIP_DEMAND');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_WIP_ODS_LOAD.LOAD_WIP_DEMAND;
	       ELSE
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading of Supplies failed.TASK_WIP_COMP_DEMAND');
		   RAISE SUPPLIES_LOAD_FAIL;
	       END IF;

	 ELSIF pTASKNUM= TASK_ODS_DEMAND THEN

              IF ((v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (v_exchange_mode = MSC_UTIL.SYS_YES)) THEN

                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_ODS_DEMAND');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
	           MSC_CL_DEMAND_ODS_LOAD.LOAD_ODS_DEMAND;
	      ELSE
	          NULL;
	      END IF;

         ELSIF pTASKNUM= TASK_RES_REQ THEN

               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_ODS_LOAD.LOAD_RES_REQ');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_WIP_ODS_LOAD.LOAD_RES_REQ;
	       ELSE
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading of Supplies failed. TASK_RES_REQ');
		   RAISE SUPPLIES_LOAD_FAIL;
	       END IF;

         ELSIF pTASKNUM= TASK_BOR THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_BOR');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_BOR;

         ELSIF pTASKNUM= TASK_CALENDAR_DATE THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_DATE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_DATE;

         ELSIF pTASKNUM= TASK_ITEM THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_ITEM');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_ODS_LOAD.LOAD_ITEM;

             /* as Supplier capacity is depenedent on item call load_supplier capacity
             after load_item  (support for net change of ASL)*/

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_SUPPLIER_CAPACITY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_ODS_LOAD.LOAD_SUPPLIER_CAPACITY;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.CLEAN_LIAB_AGREEMENT');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SETUP_ODS_LOAD.CLEAN_LIAB_AGREEMENT;

	 ELSIF pTASKNUM= TASK_ABC_CLASSES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_ABC_CLASSES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_ODS_LOAD.LOAD_ABC_CLASSES;

         ELSIF pTASKNUM= TASK_RESOURCE THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_RESOURCE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            --   BUG # 3020614
            --   The call to the procedure LOAD_RESOURCE is being
            --   moved inside the procedure LOAD_CALENDAR_DATE.

            --   LOAD_RESOURCE;

         ELSIF pTASKNUM= TASK_SALES_ORDER THEN

             IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                 FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER');
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                 MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER;

                 IF (v_is_complete_refresh  = TRUE and v_is_so_complete_refresh = FALSE) THEN
		     IF (v_apps_ver >= MSC_UTIL.G_APPS115 )  THEN
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling Linking of Sales Order for 11i source ...');
                            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_11I2');
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                            MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_11I2;
                            -- Calling the Linking of external Sales orders for the fix 2353397  --
                            -- MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_EXT;
                     ELSIF (v_apps_ver = MSC_UTIL.G_APPS110)  THEN
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling Linking of Sales Order for 110 source ...');
                            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_110');
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                            MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_110;
	             END IF;
                 END IF;

	     ELSE
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Loading of Supplies failed. sales order');
	         RAISE SUPPLIES_LOAD_FAIL;
	     END IF;

         ELSIF pTASKNUM= TASK_SUB_INVENTORY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_SUB_INVENTORY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_SUB_INVENTORY;

         ELSIF pTASKNUM= TASK_HARD_RESERVATION THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_HARD_RESERVATION');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_DEMAND_ODS_LOAD.LOAD_HARD_RESERVATION;

         ELSIF pTASKNUM= TASK_SOURCING THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_SOURCING');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_SOURCING;
            /* commented as a part of bug fix 5233688*/

         ELSIF pTASKNUM= TASK_SUPPLIER_CAPACITY THEN

         NULL;

         /*   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLIER_CAPACITY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            LOAD_SUPPLIER_CAPACITY;
            MSC_CL_SETUP_ODS_LOAD.CLEAN_LIAB_AGREEMENT ;  */

         /* SCE Change starts */
         /* ODS load for Customer cross reference Items */
         ELSIF pTASKNUM= TASK_ITEM_CUSTOMERS THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'TASK_ITEM_CUSTOMERS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SCE_COLLECTION.LOAD_ITEM_CUSTOMERS(v_instance_id);

         ELSIF pTASKNUM= TASK_COMPANY_USERS THEN

         /* Perform this task only if MSC:Configuration is set to                        'APS + SCE' or 'SCE. */
             IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
                 OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN

                 FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SCE_COLLECTION.LOAD_USER_COMPANY');
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
              MSC_CL_SCE_COLLECTION.LOAD_USER_COMPANY(v_instance_id);

             END IF;
         /* SCE Change ends */

         ELSIF pTASKNUM= TASK_CATEGORY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_CATEGORY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_ODS_LOAD.LOAD_CATEGORY;

         ELSIF pTASKNUM= TASK_BOM_COMPONENTS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_BOM_COMPONENTS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_BOM_COMPONENTS;

         ELSIF pTASKNUM= TASK_BOM THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_BOM');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_BOM;

         ELSIF pTASKNUM= TASK_COMPONENT_SUBSTITUTE THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_COMPONENT_SUBSTITUTE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_COMPONENT_SUBSTITUTE;

         ELSIF pTASKNUM= TASK_ROUTING THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_ROUTING');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_ROUTING;

         ELSIF pTASKNUM= TASK_ROUTING_OPERATIONS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_ROUTING_OPERATIONS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_ROUTING_OPERATIONS;
         ELSIF pTASKNUM= TASK_OPERATION_RESOURCES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_RESOURCES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_RESOURCES;
         ELSIF pTASKNUM= TASK_OP_RESOURCE_SEQ THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_OP_RESOURCE_SEQ');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_OP_RESOURCE_SEQ;
         ELSIF pTASKNUM= TASK_PROCESS_EFFECTIVITY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_PROCESS_EFFECTIVITY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_PROCESS_EFFECTIVITY;
         ELSIF pTASKNUM= TASK_OPERATION_COMPONENTS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_COMPONENTS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_COMPONENTS;
         ELSIF pTASKNUM= TASK_OPERATION_NETWORKS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_NETWORKS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_NETWORKS;

         ELSIF pTASKNUM= TASK_UNIT_NUMBER THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_UNIT_NUMBER');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_UNIT_NUMBER;

         ELSIF pTASKNUM= TASK_SAFETY_STOCK THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_SAFETY_STOCK');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_SAFETY_STOCK;

         ELSIF pTASKNUM= TASK_PROJECT THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_PROJECT');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_PROJECT;

         ELSIF pTASKNUM= TASK_PARAMETER THEN

           NULL;

           -- Moved to the Main ODS Load, since we need this information in the function
           -- CALC_RESOURCE_AVAILABILITY called in LOAD_CALENDAR_DATE


         ELSIF pTASKNUM= TASK_BIS_PFMC_MEASURES THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_PFMC_MEASURES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_PFMC_MEASURES;
            END IF;

         ELSIF pTASKNUM= TASK_BIS_TARGET_LEVELS THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_TARGET_LEVELS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_TARGET_LEVELS;
            END IF;

          ELSIF pTASKNUM= TASK_BIS_TARGETS THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_TARGETS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_TARGETS;
            END IF;

          ELSIF pTASKNUM= TASK_BIS_BUSINESS_PLANS THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_BUSINESS_PLANS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_BUSINESS_PLANS;
            END IF;

          ELSIF pTASKNUM= TASK_BIS_PERIODS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_PERIODS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_PERIODS;

          ELSIF pTASKNUM= TASK_ATP_RULES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_ATP_RULES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_ATP_RULES;

          ELSIF pTASKNUM= TASK_NET_RESOURCE_AVAIL THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_RESOURCE_AVAILABILITY.LOAD_NET_RESOURCE_AVAIL');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_RESOURCE_AVAILABILITY.LOAD_NET_RESOURCE_AVAIL;

          ELSIF pTASKNUM= TASK_PLANNERS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_PLANNERS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_PLANNERS;

          ELSIF pTASKNUM= TASK_DEMAND_CLASS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_DEMAND_CLASS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_DEMAND_CLASS;

          ELSIF pTASKNUM = TASK_ITEM_SUBSTITUTES THEN

            IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN

               FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_ITEM_SUBSTITUTES');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_ITEM_ODS_LOAD.LOAD_ITEM_SUBSTITUTES;

            END IF;

        ELSIF pTASKNUM= TASK_TRIP THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_TRIP');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_TRIP;

          END IF;
       /* ds change start */
       ELSIF pTASKNUM= TASK_RES_INST_REQ THEN
               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_ODS_LOAD.LOAD_RES_INST_REQ');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_WIP_ODS_LOAD.LOAD_RES_INST_REQ;
               ELSE
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading of Supplies failed.TASK_RES_INST_REQ');
                   RAISE SUPPLIES_LOAD_FAIL;
               END IF;
      ELSIF pTASKNUM= TASK_RESOURCE_SETUP THEN
          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_RESOURCE_SETUP');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_RESOURCE_SETUP;
          END IF;
       ELSIF pTASKNUM= TASK_SETUP_TRANSITION THEN
          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_SETUP_TRANSITION');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_SETUP_TRANSITION;
	  END IF;
       ELSIF pTASKNUM= TASK_STD_OP_RESOURCES THEN
          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_STD_OP_RESOURCES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_STD_OP_RESOURCES;
	  END IF;
     /* ds change end */
      ELSIF pTASKNUM= TASK_SALES_CHANNEL THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_SALES_CHANNEL');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            -- LOG_MESSAGE(FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_SALES_CHANNEL;
       ELSIF pTASKNUM= TASK_FISCAL_CALENDAR THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_FISCAL_CALENDAR');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           -- LOG_MESSAGE(FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_FISCAL_CALENDAR;

       ELSIF pTASKNUM= TASK_PAYBACK_DEMAND_SUPPLY THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_PAYBACK_DEMANDS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
            MSC_CL_DEMAND_ODS_LOAD.LOAD_PAYBACK_DEMANDS;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_PAYBACK_SUPPLIES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
	    MSC_CL_SUPPLY_ODS_LOAD.LOAD_PAYBACK_SUPPLIES;

        ELSIF pTASKNUM= TASK_CURRENCY_CONVERSION THEN          ---- for bug # 6469722
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_CURRENCY_CONVERSION');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            IF (MSC_CL_OTHER_PULL.G_MSC_HUB_CURR_CODE IS NOT NULL) AND (v_apps_ver >= MSC_UTIL.G_APPS115) THEN
    	           MSC_CL_OTHER_ODS_LOAD.LOAD_CURRENCY_CONVERSION;
            ELSE
    	           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Currency Data is not collected as MSC:Planning Hub Currency Code Profile is NULL or source is not 11i or greater.');
            END IF;

       ELSIF pTASKNUM= TASK_DELIVERY_DETAILS THEN          ---- for bug # 6730983
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_DELIVERY_DETAILS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            -- LOG_MESSAGE(FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_DELIVERY_DETAILS;

       ELSIF pTASKNUM= TASK_IRO_DEMAND THEN            -- Changed For bug 5909379 SRP Additions



         IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_RPO_ODS_LOAD.LOAD_IRO_DEMAND;');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           -- LOG_MESSAGE(FND_MESSAGE.GET);
            MSC_CL_RPO_ODS_LOAD.LOAD_IRO_DEMAND;
         END IF;



         ELSIF pTASKNUM= TASK_ERO_DEMAND THEN            -- Changed For bug 5935273 SRP Additions



         IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_RPO_ODS_LOAD.LOAD_ERO_DEMAND;');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            --LOG_MESSAGE(FND_MESSAGE.GET);
            MSC_CL_RPO_ODS_LOAD.LOAD_ERO_DEMAND;
         END IF;

        ELSIF pTASKNUM= TASK_CMRO THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS121) AND v_is_legacy_refresh THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_VISITS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_VISITS;
            MSC_CL_OTHER_ODS_LOAD.LOAD_MILESTONES;
            MSC_CL_OTHER_ODS_LOAD.LOAD_WBS;
            MSC_CL_OTHER_ODS_LOAD.LOAD_WOATTRIBUTES;
            MSC_CL_OTHER_ODS_LOAD.LOAD_WO_TASK_HIERARCHY;
            MSC_CL_OTHER_ODS_LOAD.LOAD_WO_OPERATION_REL;

         END IF;

         ELSE
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading of Supplies failed.TASK_WIP_COMP_DEMAND');
            RAISE SUPPLIES_LOAD_FAIL;

       END IF;

   -- ======== If no EXCEPTION occurs, then returns with status = OK =========

         pSTATUS := OK;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
         FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                     TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

         msc_util.print_top_wait(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
         msc_util.print_cum_stat(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
         msc_util.print_bad_sqls(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);

    EXCEPTION

         WHEN SUPPLIES_LOAD_FAIL  THEN
              ROLLBACK;
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
              RAISE;

         WHEN others THEN

   -- ============= Raise the EXCEPTION ==============
              IF SQLCODE IN (-01578,-26040) THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,SQLERRM);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'To rectify this problem -');
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Run concurrent program "Truncate Planning Staging Tables" ');
              END IF;
              --ROLLBACK WORK TO SAVEPOINT ExecuteTask;
              ROLLBACK;

              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

              RAISE;

   END EXECUTE_TASK;

   /*************** PREPLACE CHANGE START *****************/

   PROCEDURE EXECUTE_PARTIAL_TASK( pSTATUS                OUT NOCOPY NUMBER,
                                   pTASKNUM               IN  NUMBER,
                                   prec in MSC_CL_EXCHANGE_PARTTBL.CollParamRec)

   IS

   lv_task_start_time DATE;

--agmcont:
   lv_is_incremental_refresh boolean;
   lv_is_partial_refresh     boolean;
   lv_exchange_mode          number;
   lv_lbj_details            number := 0;

   BEGIN


         lv_task_start_time:= SYSDATE;

         --SAVEPOINT ExecuteTask;

         pSTATUS := FAIL;

-- agmcont
         if (v_is_cont_refresh) then
            if (MSC_CL_CONT_COLL_FW.set_cont_refresh_type_ODS(pTASKNUM, prec,
                                      lv_is_incremental_refresh,
                                      lv_is_partial_refresh,
				      lv_exchange_mode)) then

	      IF ( pTASKNUM = PTASK_SALES_ORDER) THEN
                   v_is_so_incremental_refresh := lv_is_incremental_refresh;
                   v_is_so_complete_refresh := lv_is_partial_refresh;
	           v_so_exchange_mode := lv_exchange_mode;
	      ELSE
                   v_is_incremental_refresh := lv_is_incremental_refresh;
                   v_is_partial_refresh := lv_is_partial_refresh;
	           v_exchange_mode := lv_exchange_mode;
              END IF;

               if (v_is_incremental_refresh) then
                  IF (MSC_UTIL.G_MSC_DEBUG <> 'N' ) THEN
                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Task Num : '|| pTASKNUM||'. Incr Refresh Flag= True');
        	  END IF;
               else
                  IF (MSC_UTIL.G_MSC_DEBUG <> 'N' ) THEN
                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Task Num : '|| pTASKNUM||'. Incr Refresh Flag= False');
     	          END IF;
               end if;

               if (v_is_partial_refresh) then
                IF (MSC_UTIL.G_MSC_DEBUG <> 'N' ) THEN
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Task Num : '|| pTASKNUM||'.Targeted Refresh Flag= True');
		END IF;
               else

                IF (MSC_UTIL.G_MSC_DEBUG <> 'N' ) THEN
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Task Num : '|| pTASKNUM||'.Targeted Refresh Flag= False');
	        END IF;
               end if;

            else
               pSTATUS := OK;
               v_is_incremental_refresh := FALSE;
               v_is_partial_refresh     := FALSE;
	       v_exchange_mode          := MSC_UTIL.SYS_NO;
               return;
            end if;
         end if;

   -- ====== Execute the partial task according to its task number  ==========

         IF pTASKNUM= PTASK_SUPPLIER_CAPACITY THEN
					IF(prec.item_flag=MSC_UTIL.SYS_NO) THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_SUPPLIER_CAPACITY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_ODS_LOAD.LOAD_SUPPLIER_CAPACITY;
            MSC_CL_SETUP_ODS_LOAD.CLEAN_LIAB_AGREEMENT ;
          END IF ;

         ELSIF pTASKNUM= PTASK_ITEM THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_ITEM');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_ODS_LOAD.LOAD_ITEM;

            /* for bug 5233688 */
            IF(prec.app_supp_cap_flag=MSC_UTIL.SYS_YES or prec.app_supp_cap_flag=MSC_UTIL.ASL_YES_RETAIN_CP) THEN
							 FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            	 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_SUPPLIER_CAPACITY');
           			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           		 MSC_CL_ITEM_ODS_LOAD.LOAD_SUPPLIER_CAPACITY;
               MSC_CL_SETUP_ODS_LOAD.CLEAN_LIAB_AGREEMENT ;
           END IF ;

	 ELSIF pTASKNUM= PTASK_ABC_CLASSES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_ABC_CLASSES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_ODS_LOAD.LOAD_ABC_CLASSES;

         ELSIF pTASKNUM= PTASK_CATEGORY_ITEM THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_CATEGORY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ITEM_ODS_LOAD.LOAD_CATEGORY;

         ELSIF pTASKNUM= PTASK_TRADING_PARTNER THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_TRADING_PARTNER');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SETUP_ODS_LOAD.LOAD_TRADING_PARTNER;

         ELSIF pTASKNUM= PTASK_BOM_COMPONENTS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_BOM_COMPONENTS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_BOM_COMPONENTS;

         ELSIF pTASKNUM= PTASK_BOM THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_BOM');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_BOM;

         ELSIF pTASKNUM= PTASK_COMPONENT_SUBSTITUTE THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_COMPONENT_SUBSTITUTE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_COMPONENT_SUBSTITUTE;

         ELSIF pTASKNUM= PTASK_ROUTING THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_ROUTING');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_ROUTING;

         ELSIF pTASKNUM= PTASK_ROUTING_OPERATIONS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_ROUTING_OPERATIONS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_ROUTING_OPERATIONS;

         ELSIF pTASKNUM= PTASK_OPERATION_RESOURCES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_RESOURCES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_RESOURCES;

         ELSIF pTASKNUM= PTASK_RESOURCE THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_RESOURCE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
           --   LOAD_RESOURCE;


            --   BUG # 3020614
            --   The call to the procedure LOAD_RESOURCE is being
            --   moved inside the procedure LOAD_CALENDAR_DATE.

            if (v_coll_prec.calendar_flag = MSC_UTIL.SYS_NO) then
                MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_DATE;
            end if;

         ELSIF pTASKNUM= PTASK_OP_RESOURCE_SEQ THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_OP_RESOURCE_SEQ');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_OP_RESOURCE_SEQ;

         ELSIF pTASKNUM= PTASK_PROCESS_EFFECTIVITY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_PROCESS_EFFECTIVITY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_PROCESS_EFFECTIVITY;
            -- Needs to be REVIEWED

         ELSIF pTASKNUM= PTASK_OPERATION_COMPONENTS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_COMPONENTS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_COMPONENTS;

         ELSIF pTASKNUM= PTASK_OPERATION_NETWORKS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_NETWORKS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_OPERATION_NETWORKS;

         ELSIF pTASKNUM= PTASK_HARD_RESERVATION THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_HARD_RESERVATION');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_DEMAND_ODS_LOAD.LOAD_HARD_RESERVATION;

         ELSIF pTASKNUM= PTASK_SOURCING THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_SOURCING');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_SOURCING;

         ELSIF pTASKNUM= PTASK_SAFETY_STOCK THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_SAFETY_STOCK');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_SAFETY_STOCK;

         ELSIF pTASKNUM= PTASK_MDS_DEMAND THEN

            -- If any of the supply flags are enabled then wait for the supplies to be completed
            -- no need to call the load_demand routine
            -- since the SUPPLY task will handle it.
             /* In Cont. collections cal the Load_demand here only if these conds. are satisfied:
	      1. None of  the Supplies are not collected
	      2. MDS is Targeted OR ( MDS is incremental Refresh and other Demand (forecast) is Not Targeted)
	      IF  Forecast is targeted and MDS Is incremental then, LOAD_DEMAND will be called in TASK_ODS_DEMANDS */

            IF  NOT(v_is_cont_refresh)  OR        -- Not Automatic collections i.e. Incremenatal or Targeted
	             ((v_is_cont_refresh) AND
		      ((v_coll_prec.mds_flag = MSC_UTIL.SYS_YES and v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_TGT) OR
		         ((v_coll_prec.mds_flag = MSC_UTIL.SYS_YES and v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_INCR) AND
                          (
                           (v_coll_prec.forecast_flag = MSC_UTIL.SYS_NO or
                              (v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES AND v_coll_prec.fcst_sn_flag <>MSC_UTIL.SYS_TGT)) AND
            		   (v_coll_prec.wip_flag = MSC_UTIL.SYS_NO or
                              (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag <>MSC_UTIL.SYS_TGT)) AND
	            	   (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_NO or
                               (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and v_coll_prec.udmd_sn_flag <>MSC_UTIL.SYS_TGT))
                      ))))  THEN
               IF ( (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES)  or
                    (v_coll_prec.po_flag  = MSC_UTIL.SYS_YES)  or
                    (v_coll_prec.oh_flag  = MSC_UTIL.SYS_YES)  or
                    (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES)  or
	  	    (v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES) or
	            (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES) ) THEN

                     IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                        FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                        FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND');
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND From PTASK_MDS_DEMAND -- Either MDS Is targetted');
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'or all the demands are incremental or None in this run. ');
                        MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND;
	             ELSE
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading of Supplies failed.mps etc');
			RAISE SUPPLIES_LOAD_FAIL;
	             END IF;

	      ELSE
                     FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND');
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                     MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND;
	      END IF;

           END IF;

         ELSIF  pTASKNUM =  PTASK_WIP_RES_REQ   THEN

               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_ODS_LOAD.LOAD_RES_REQ');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_WIP_ODS_LOAD.LOAD_RES_REQ;
	       ELSE
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Loading of Supplies failed. PTASK_WIP_RES_REQ');
		   RAISE SUPPLIES_LOAD_FAIL;
	       END IF;

	 ELSIF  pTASKNUM = PTASK_WIP_DEMAND THEN

            IF  NOT(v_is_cont_refresh)  OR        -- Not Automatic collections i.e. Incremenatal or Targeted
	          ((v_is_cont_refresh) AND
		    ((v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) OR
		       ((v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR) AND
                           ((v_coll_prec.forecast_flag = MSC_UTIL.SYS_NO or
                             (v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES and v_coll_prec.fcst_sn_flag <>MSC_UTIL.SYS_TGT)) AND
            		    (v_coll_prec.mds_flag = MSC_UTIL.SYS_NO or
                             (v_coll_prec.mds_flag = MSC_UTIL.SYS_YES and v_coll_prec.mds_sn_flag <>MSC_UTIL.SYS_TGT)) AND
	            	    (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_NO or
                              (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and v_coll_prec.udmd_sn_flag <>MSC_UTIL.SYS_TGT))
                     ) )))  THEN
               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_ODS_LOAD.LOAD_WIP_DEMAND');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling LOAD_WIP_DEMAND From PTASK_WIP_DEMAND -- Either WIP is Targetted ');
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'or all the demands are incremental or None in this run. ');
                   MSC_CL_WIP_ODS_LOAD.LOAD_WIP_DEMAND;
	       ELSE
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Loading of Supplies failed.LOAD_WIP_DEMAND');
		   RAISE SUPPLIES_LOAD_FAIL;
	       END IF;
            END IF;

         ELSIF pTASKNUM= PTASK_FORECAST_DEMAND THEN

            IF  NOT(v_is_cont_refresh)  OR        -- Not Automatic collections i.e. Incremenatal or Targeted
                ((v_is_cont_refresh) AND
		      ((v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES and v_coll_prec.fcst_sn_flag = MSC_UTIL.SYS_TGT) OR
		         ((v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES and v_coll_prec.fcst_sn_flag = MSC_UTIL.SYS_INCR) AND
                          ((v_coll_prec.mds_flag = MSC_UTIL.SYS_NO or
                            (v_coll_prec.mds_flag = MSC_UTIL.SYS_YES and v_coll_prec.mds_sn_flag <>MSC_UTIL.SYS_TGT)) AND
            		  (v_coll_prec.wip_flag = MSC_UTIL.SYS_NO or
                           (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag <>MSC_UTIL.SYS_TGT)) AND
	            	  (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_NO or
                           (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and v_coll_prec.udmd_sn_flag <>MSC_UTIL.SYS_TGT))
                         ))))  THEN

                       FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                       FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM_FORECAST');
                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling LOAD_ITEM_FORECAST From PTASK_FORECAST_DEMAND--  Either forecast id Targetted ');
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'or all the demands are incremental or None in this run. ');
                       MSC_CL_DEMAND_ODS_LOAD.LOAD_ITEM_FORECASTS;

	    END IF;


      /* IN Cont. Collections, This Task will do the Incremental of MDS or Forecast
	 if one of them is targeted and other is Incremental
	 This task will be called only if none of the Supplies are collected */

         ELSIF pTASKNUM= PTASK_ODS_DEMAND THEN
	   IF (v_is_cont_refresh) then
             -- Is any Demand Targetted in Continous, then modify any other incremental demand first
	     IF ( (v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES and v_coll_prec.fcst_sn_flag = MSC_UTIL.SYS_TGT) OR
	          (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) OR
          	  (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and v_coll_prec.udmd_sn_flag = MSC_UTIL.SYS_TGT) OR
                  (v_coll_prec.mds_flag = MSC_UTIL.SYS_YES and v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_TGT) ) THEN

	       IF (v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES and v_coll_prec.fcst_sn_flag = MSC_UTIL.SYS_INCR) THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM_FORECAST');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
		   v_is_incremental_refresh := TRUE;
	           v_exchange_mode          := MSC_UTIL.SYS_NO;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling Incremental MSC_CL_DEMAND_ODS_LOAD.LOAD_ITEM_FORECASTS From PTASK_ODS_DEMAND');
                   MSC_CL_DEMAND_ODS_LOAD.LOAD_ITEM_FORECASTS;
               END IF;

               IF (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR) THEN
                             IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                               FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_ODS_LOAD.LOAD_WIP_DEMAND');
                               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
	     		       v_is_incremental_refresh := TRUE;
	                       v_exchange_mode          := MSC_UTIL.SYS_NO;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling Incremental LOAD_WIP_DEMAND From PTASK_ODS_DEMAND');
                               MSC_CL_WIP_ODS_LOAD.LOAD_WIP_DEMAND;
       	                     ELSE
                               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Loading of Supplies failed.LOAD_WIP_DEMAND');
            	               RAISE SUPPLIES_LOAD_FAIL;
                             END IF;

	        END IF;        ---any supply flag is yes, no need to handle no supplies

               IF (v_coll_prec.mds_flag = MSC_UTIL.SYS_YES and v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_INCR) THEN
                     IF ( (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES)  or
                          (v_coll_prec.po_flag  = MSC_UTIL.SYS_YES)  or
                          (v_coll_prec.oh_flag  = MSC_UTIL.SYS_YES)  or
                          (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES)  or
			  (v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES) or
	                  (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES) ) THEN

                          IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                                 FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                                 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND');
                                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
				 v_is_incremental_refresh := TRUE;
	                         v_exchange_mode          := MSC_UTIL.SYS_NO;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling Incremental MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND From PTASK_ODS_DEMAND');
                                 MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND;
		          ELSE
				 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ' Loading of Supplies failed MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND');
			         RAISE SUPPLIES_LOAD_FAIL;
    		          END IF;

                     ELSE --- all the supplies flag are no
                          FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                          FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND');
                          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
			  v_is_incremental_refresh := TRUE;
	                  v_exchange_mode          := MSC_UTIL.SYS_NO;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling Incremental MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND From PTASK_ODS_DEMAND -- No Supplies are Collected in this run');
                          MSC_CL_DEMAND_ODS_LOAD.LOAD_DEMAND;
	             END IF;        ---any supply flag is yes

	       END IF;



             /* AFTER HANDLING OTHER DEMANDS INCREMENTAL PERFORM THE MSC_CL_DEMAND_ODS_LOAD.LOAD_ODS_DEMAND */
             /* -------------------------------------------------------------------- */

                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_ODS_DEMAND');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling MSC_CL_DEMAND_ODS_LOAD.LOAD_ODS_DEMAND From PTASK_ODS_DEMAND -- One of the Demands is Targetted in this run');
                   MSC_CL_DEMAND_ODS_LOAD.LOAD_ODS_DEMAND;

	       END IF;  -- Is any Demand Targetted in Continous

            elsif (v_is_partial_refresh)  THEN  -- Targeted collections

               FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_ODS_DEMAND');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
	       MSC_CL_DEMAND_ODS_LOAD.LOAD_ODS_DEMAND;
		       -- Load Demand information from ODS table into
		       -- the temp table.
	    end if;


         ELSIF pTASKNUM= PTASK_SUPPLY THEN
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'ds debug: pTASKNUM= PTASK_SUPPLY ');

			  update msc_apps_instances
			  set SUPPLIES_LOAD_FLAG = G_JOB_NOT_DONE
			  where instance_id = v_instance_id;
			  commit;

            /* AGM NCP: */

--agmcont
            IF (v_is_cont_refresh) then

               -- in continuous collections, it is possible to have
               -- a supply entity collected in net-change mode
               -- and other supply entities to be collected in targeted mode

               -- first call load_supply to handle any supply
               -- entities (po/oh/wip/mps) which are being collected
               -- net-change
			     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY: v_is_cont_refresh = true');
               if (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES and v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_INCR) or
                  (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR) or
                  (v_coll_prec.po_flag = MSC_UTIL.SYS_YES and v_coll_prec.po_sn_flag = MSC_UTIL.SYS_INCR) or
				  /* CP-AUTO */
				  (v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES and v_coll_prec.suprep_sn_flag = MSC_UTIL.SYS_INCR) or
                  (v_coll_prec.oh_flag = MSC_UTIL.SYS_YES and v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_INCR) or
                  (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_INCR) then

                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
	           v_exchange_mode          := MSC_UTIL.SYS_NO;
			     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY: before MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY ');
                   MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY;
			     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY: after MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY ');
               end if;

               -- now call load_staging_supply and load_ods_supply
               -- to collect the supply entities that are collected in
               -- targeted mode

               if (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES and v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_TGT) or
                  (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) or
                  (v_coll_prec.po_flag = MSC_UTIL.SYS_YES and v_coll_prec.po_sn_flag = MSC_UTIL.SYS_TGT) or
                  (v_coll_prec.oh_flag = MSC_UTIL.SYS_YES and v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_TGT) or
				  /* CP-AUTO */
		          (v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES and v_coll_prec.suprep_sn_flag = MSC_UTIL.SYS_TGT) or
                  (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_TGT) then
                  -- Load Supply information from staging tables
                  -- into the temp table.
                  FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                  FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_STAGING_SUPPLY');
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
		  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY: before MSC_CL_SUPPLY_ODS_LOAD.LOAD_STAGING_SUPPLY ');
                  MSC_CL_SUPPLY_ODS_LOAD.LOAD_STAGING_SUPPLY;
		  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY: after MSC_CL_SUPPLY_ODS_LOAD.LOAD_STAGING_SUPPLY ');
                  -- Load Supply information from ODS table
                  -- into the temp table.
                  FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                  FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY');
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
		  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY: befor MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY ');
                  MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY;
		  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY: after MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY ');

	          IF MSC_CL_SUPPLY_ODS_LOAD.create_supplies_tmp_ind  THEN
			     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Index creation on Temp Supplies table successful.');
		  ELSE
			     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
			     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Index creation on Temp Supplies table failed.');
			     RAISE SUPPLIES_INDEX_FAIL;
	          END IF;

               msc_analyse_tables_pk.analyse_table( 'SUPPLIES_'||v_instance_code, v_instance_id, -1);

               end if;          --- any one of the Supplies will be done Targeted

        ELSIF (v_is_incremental_refresh) then
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'ds debug: v_is_incremental_refresh MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY');
               FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY:v_is_incremental_refresh before MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY ');
               MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY;
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'PTASK_SUPPLY:v_is_incremental_refresh after MSC_CL_SUPPLY_ODS_LOAD.LOAD_SUPPLY ');
        ELSE  ---- Targeted Collections
               -- Load Supply information from staging tables
               -- into the temp table.
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ds debug: Targetted MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY');
               FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_STAGING_SUPPLY');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_SUPPLY_ODS_LOAD.LOAD_STAGING_SUPPLY;
               -- Load Supply information from ODS table
               -- into the temp table.
               FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_SUPPLY_ODS_LOAD.LOAD_ODS_SUPPLY;

            /*added by raraghav*/

            /* analyze msc_supplies here */
            /* create temporay index */

            --=============================================
            -- NCP:
            -- Create index in case of Partial refresh only
            -- ============================================
                      IF MSC_CL_SUPPLY_ODS_LOAD.create_supplies_tmp_ind  THEN
		            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Index creation on Temp Supplies table successful.');
		      ELSE
		            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
		            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Index creation on Temp Supplies table failed.');
                            RAISE SUPPLIES_INDEX_FAIL;
		      END IF;

               msc_analyse_tables_pk.analyse_table( 'SUPPLIES_'||v_instance_code, v_instance_id, -1);

         END IF;

                COMMIT;

		  update msc_apps_instances
		  set SUPPLIES_LOAD_FLAG = G_JOB_DONE
		  where instance_id = v_instance_id;
		  commit;

		  if ( v_coll_prec.wip_flag = MSC_UTIL.SYS_YES ) Then

		  if (v_is_cont_refresh) Then

		  if (v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR) then
		     		v_is_incremental_refresh := TRUE;
		     		v_is_partial_refresh     := FALSE;
		     		v_exchange_mode          := MSC_UTIL.SYS_NO;
		  elsif (v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) then
		  		v_is_incremental_refresh := FALSE;
		     		v_is_partial_refresh     := TRUE;
		     		v_exchange_mode          := MSC_UTIL.SYS_YES;
		  else
                     v_is_incremental_refresh := FALSE;
                     v_is_partial_refresh     := FALSE;
	             v_exchange_mode          := MSC_UTIL.SYS_NO;
                     pSTATUS := OK;
	             RETURN;
		  END IF;

		  END IF;

		  MSC_CL_WIP_ODS_LOAD.LOAD_JOB_DETAILS;

		  END IF;

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'after job_details.');
         ELSIF pTASKNUM= PTASK_SALES_ORDER THEN

	       IF ( (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES)  or
                    (v_coll_prec.po_flag  = MSC_UTIL.SYS_YES)  or
                    (v_coll_prec.oh_flag  = MSC_UTIL.SYS_YES)  or
                    (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES)  or
	            (v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES) or
	            (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES) ) THEN

                         -- If any of the supply flags are enabled then wait for supplies to get finished
                       IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER_2 ...');
                            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER');
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                            MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER;
	               ELSE
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Loading of Supplies failed.MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER');
			    RAISE SUPPLIES_LOAD_FAIL;
	               END IF;

	       ELSE  -- no need to wait for supplies
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER_2 ...');
                            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER');
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                            MSC_CL_DEMAND_ODS_LOAD.LOAD_SALES_ORDER;
	       END IF;

                IF ( v_is_so_incremental_refresh ) THEN
			IF  ( v_apps_ver >= MSC_UTIL.G_APPS115 ) THEN

                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling Linking of Sales Order for 11i source ...');
                            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_11I2');
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                            MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_11I2;
                            -- Calling the Linking of external Sales orders for the fix 2353397  --
                            -- MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_EXT;

		        ELSIF (	v_apps_ver = MSC_UTIL.G_APPS110) THEN

                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling Linking of Sales Order for 110 source ...');
                            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_110');
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                            MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_110;
                        END IF;
		END IF;

         ELSIF pTASKNUM= PTASK_NET_RESOURCE_AVAIL THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_RESOURCE_AVAILABILITY.LOAD_NET_RESOURCE_AVAIL');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_RESOURCE_AVAILABILITY.LOAD_NET_RESOURCE_AVAIL;

         ELSIF pTASKNUM= PTASK_UOM THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_UOM');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SETUP_ODS_LOAD.LOAD_UOM;

          ELSIF pTASKNUM= PTASK_ATP_RULES THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_ATP_RULES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_ATP_RULES;

         ELSIF pTASKNUM= PTASK_BOR THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_BOR');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_BOR;

         ELSIF pTASKNUM= PTASK_CALENDAR_DATE THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_DATE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_DATE;

          ELSIF pTASKNUM= PTASK_DEMAND_CLASS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_DEMAND_CLASS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_DEMAND_CLASS;

          ELSIF pTASKNUM= PTASK_DESIGNATOR THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_DESIGNATOR');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_DEMAND_ODS_LOAD.LOAD_DESIGNATOR;

         ELSIF pTASKNUM= PTASK_BIS_PFMC_MEASURES THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_PFMC_MEASURES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_PFMC_MEASURES;
            END IF;

         ELSIF pTASKNUM= PTASK_BIS_TARGET_LEVELS THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_TARGET_LEVELS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_TARGET_LEVELS;
            END IF;

         ELSIF pTASKNUM= PTASK_BIS_TARGETS THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_TARGETS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_TARGETS;
            END IF;

          ELSIF pTASKNUM= PTASK_BIS_BUSINESS_PLANS THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_BUSINESS_PLANS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_BUSINESS_PLANS;
            END IF;

          ELSIF pTASKNUM= PTASK_BIS_PERIODS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_PERIODS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_OTHER_ODS_LOAD.LOAD_BIS_PERIODS;

         ELSIF pTASKNUM= PTASK_PARAMETER THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_PARAMETER');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SETUP_ODS_LOAD.LOAD_PARAMETER;

          ELSIF pTASKNUM= PTASK_PLANNERS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_PLANNERS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_PLANNERS;

         ELSIF pTASKNUM= PTASK_PROJECT THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_PROJECT');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_PROJECT;

         ELSIF pTASKNUM= PTASK_SUB_INVENTORY THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_SUB_INVENTORY');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_SUB_INVENTORY;

         ELSIF pTASKNUM= PTASK_UNIT_NUMBER THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_UNIT_NUMBER');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_UNIT_NUMBER;

         ELSIF pTASKNUM = PTASK_ITEM_SUBSTITUTES THEN

            IF v_apps_ver <> MSC_UTIL.G_APPS107 THEN
               FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
               FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ITEM_ODS_LOAD.LOAD_ITEM_SUBSTITUTES');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
               MSC_CL_ITEM_ODS_LOAD.LOAD_ITEM_SUBSTITUTES;
            END IF;

         ELSIF pTASKNUM= PTASK_ITEM_CUSTOMERS THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'TASK_ITEM_CUSTOMERS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SCE_COLLECTION.LOAD_ITEM_CUSTOMERS(v_instance_id);

         ELSIF pTASKNUM= PTASK_COMPANY_USERS THEN

         /* Perform this task only if MSC:Configuration is set to
         'APS + SCE' or 'SCE. */
             IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
                 OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN

                 FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SCE_COLLECTION.LOAD_USER_COMPANY');
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                 MSC_CL_SCE_COLLECTION.LOAD_USER_COMPANY(v_instance_id);

             END IF;
         /* SCE Change ends */

        ELSIF pTASKNUM= PTASK_TRIP THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_TRIP');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_TRIP;

          END IF;

       /*ds change start */
       ELSIF  pTASKNUM =  PTASK_RES_INST_REQ   THEN
               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_WIP_ODS_LOAD.LOAD_RES_INST_REQ');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_WIP_ODS_LOAD.LOAD_RES_INST_REQ;
	       ELSE
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Loading of Supplies failed.PTASK_RES_INST_REQ');
		   RAISE SUPPLIES_LOAD_FAIL;
	       END IF;
        ELSIF pTASKNUM= PTASK_RESOURCE_SETUP THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_RESOURCE_SETUP');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_RESOURCE_SETUP;

          END IF;
        ELSIF pTASKNUM= PTASK_SETUP_TRANSITION THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_SETUP_TRANSITION');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_BOM_ODS_LOAD.LOAD_SETUP_TRANSITION;

          END IF;
        ELSIF pTASKNUM= PTASK_STD_OP_RESOURCES THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_ROUTING_ODS_LOAD.LOAD_STD_OP_RESOURCES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_ROUTING_ODS_LOAD.LOAD_STD_OP_RESOURCES;

          END IF;

       /*ds change end */

        ELSIF pTASKNUM= PTASK_SALES_CHANNEL THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN -- 7704614
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_SALES_CHANNEL');
          --  LOG_MESSAGE(FND_MESSAGE.GET);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_SALES_CHANNEL;
          END IF;
       ELSIF pTASKNUM= PTASK_FISCAL_CALENDAR THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS115) OR v_is_legacy_refresh THEN -- 7704614
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_FISCAL_CALENDAR');
           -- LOG_MESSAGE(FND_MESSAGE.GET);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_FISCAL_CALENDAR;
          END IF;
       ELSIF pTASKNUM= PTASK_PAYBACK_DEMAND_SUPPLY THEN   --bug 5861050

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_PAYBACK_DEMANDS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
            MSC_CL_DEMAND_ODS_LOAD.LOAD_PAYBACK_DEMANDS;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SUPPLY_ODS_LOAD.LOAD_PAYBACK_SUPPLIES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
	          MSC_CL_SUPPLY_ODS_LOAD.LOAD_PAYBACK_SUPPLIES;

      ELSIF pTASKNUM= PTASK_DELIVERY_DETAILS THEN
          IF (v_apps_ver >= MSC_UTIL.G_APPS120) THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_DELIVERY_DETAILS');
           -- LOG_MESSAGE(FND_MESSAGE.GET);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_DELIVERY_DETAILS;
          END IF;

       ELSIF pTASKNUM= PTASK_CURRENCY_CONVERSION THEN -- for bug # 6469722
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_CURRENCY_CONVERSION');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

       IF (MSC_CL_OTHER_PULL.G_MSC_HUB_CURR_CODE IS NOT NULL) AND (v_apps_ver >= MSC_UTIL.G_APPS115) THEN
            MSC_CL_OTHER_ODS_LOAD.LOAD_CURRENCY_CONVERSION;
	ELSE
	    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Currency Data is not collected as MSC:Planning Hub Currency Code Profile is NULL or source is not 11i or greater.');
	END IF;

        ELSIF pTASKNUM= PTASK_IRO_DEMAND THEN
           IF  NOT(v_is_cont_refresh) THEN
               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_RPO_ODS_LOAD.LOAD_IRO_DEMAND');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_RPO_ODS_LOAD.LOAD_IRO_DEMAND;
               END IF;
            END IF;
        ELSIF pTASKNUM= PTASK_ERO_DEMAND THEN
           IF  NOT(v_is_cont_refresh) THEN
               IF MSC_CL_SUPPLY_ODS_LOAD.IS_SUPPLIES_LOAD_DONE  THEN
                   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_RPO_ODS_LOAD.LOAD_ERO_DEMAND');
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                   MSC_CL_RPO_ODS_LOAD.LOAD_ERO_DEMAND;
               END IF;
           END IF;
       ELSIF pTASKNUM= PTASK_CMRO THEN

          IF (v_apps_ver >= MSC_UTIL.G_APPS121) AND v_is_legacy_refresh THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_OTHER_ODS_LOAD.LOAD_VISITS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_OTHER_ODS_LOAD.LOAD_VISITS;
            MSC_CL_OTHER_ODS_LOAD.LOAD_MILESTONES;
            MSC_CL_OTHER_ODS_LOAD.LOAD_WBS;
            MSC_CL_OTHER_ODS_LOAD.LOAD_WOATTRIBUTES;
            MSC_CL_OTHER_ODS_LOAD.LOAD_WO_TASK_HIERARCHY;
            MSC_CL_OTHER_ODS_LOAD.LOAD_WO_OPERATION_REL;

           END IF;

        ELSE
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Loading of Supplies failed.TASK_WIP_COMP_DEMAND');
                   RAISE SUPPLIES_LOAD_FAIL;
       END IF;


   -- ======== If no EXCEPTION occurs, then returns with status = OK =========
--agmcont:
         if (v_is_cont_refresh) then
            v_is_incremental_refresh := FALSE;
            v_is_partial_refresh := FALSE;
         end if;

         pSTATUS := OK;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
         FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                     TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

         msc_util.print_top_wait(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
         msc_util.print_cum_stat(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);
         msc_util.print_bad_sqls(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10);


    EXCEPTION

         WHEN SUPPLIES_LOAD_FAIL  THEN
              ROLLBACK;
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
              RAISE;

	 WHEN SUPPLIES_INDEX_FAIL THEN
	      ROLLBACK;
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
	      RAISE;

         WHEN others THEN

   -- ============= Raise the EXCEPTION ==============
               IF SQLCODE IN (-01578,-26040) THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,SQLERRM);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'To rectify this problem -');
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Run concurrent program "Truncate Planning Staging Tables" ');
              END IF;
              --ROLLBACK WORK TO SAVEPOINT ExecuteTask;
              ROLLBACK;

              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

              RAISE;

   END EXECUTE_PARTIAL_TASK;


   /***************  PREPLACE CHANGE END  *****************/




/* procedure LOAD_CALENDAR_SET_UP has  been moved to package  MSC_CL_SETUP_ODS_LOAD
 through bug5952569 */

/* procedure LOAD_CALENDAR_DATE has been moved to package  MSC_CL_SETUP_ODS_LOAD
 through bug5952569 */

/*ds change change start */



--=================== COLLECT CATEGORIES =====================================
--= 1. Category Sets are collected in the Key_Transformation Procedure



-- =========== Public Procedures ===============

   /* purge the staging tables
      it should be launched as a concurrent program */
   PROCEDURE PURGE_STAGING_TABLES( ERRBUF                   OUT NOCOPY VARCHAR2,
                                   RETCODE                  OUT NOCOPY NUMBER,
                                   pINSTANCE_ID             IN  NUMBER,
                                   pVALIDATION              IN  NUMBER)
   IS
   BEGIN

      SELECT APPS_VER,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
        INTO v_apps_ver,
             v_current_date,
             v_current_user,
             v_current_date,
             v_current_user
        FROM MSC_APPS_INSTANCES
       WHERE INSTANCE_ID= pINSTANCE_ID;

     IF pVALIDATION= MSC_UTIL.SYS_YES THEN

        IF SET_ST_STATUS( ERRBUF, RETCODE,
                          pINSTANCE_ID, MSC_UTIL.G_ST_PURGING) THEN
           COMMIT;
        ELSE
           ROLLBACK;
           RETURN;
        END IF;

     END IF;

     MSC_CL_PURGE_STAGING.PURGE_STAGING_TABLES_SUB( pINSTANCE_ID);

	     IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_EMPTY) THEN

		 COMMIT;

	     END IF;

	   END PURGE_STAGING_TABLES;

PROCEDURE PURGE_STAGING_TABLES_SUB( p_instance_id IN NUMBER)
IS
BEGIN
  MSC_CL_PURGE_STAGING.PURGE_STAGING_TABLES_SUB( p_instance_id);
END PURGE_STAGING_TABLES_SUB;


	   PROCEDURE LAUNCH_WORKER( ERRBUF				OUT NOCOPY VARCHAR2,
			     RETCODE				OUT NOCOPY NUMBER,
			     pMONITOR_REQUEST_ID                IN  NUMBER,
			     pINSTANCE_ID                       IN  NUMBER,
			     pLCID                              IN  NUMBER,
			     pTIMEOUT                           IN  NUMBER,
			     pRECALC_NRA                        IN  NUMBER,
			     pRECALC_SH                         IN  NUMBER,
			     pEXCHANGE_MODE                     IN  NUMBER,
			     pSO_EXCHANGE_MODE                  IN  NUMBER )

	   IS

	 ----- TASK CONTROL --------------------------------------------------

	   lv_task_number  PLS_INTEGER;    -- NEGATIVE: Unknown Error Occurs
					   -- 0       : All Task Is Done
					   -- POSITIVE: The Task Number

	   lv_task_status   NUMBER;    -- ::OK    : THE TASK IS Done in MSC
			      -- OTHERS  : THE TASK Fails

	   lv_process_time      NUMBER;

	   EX_PROCESS_TIME_OUT  EXCEPTION;

	  ------ PIPE CONTROL ----------------------------------------------

	   lv_pipe_ret_code  NUMBER;   -- The return value of Sending/Receiving Pipe Messages

	   EX_PIPE_RCV         EXCEPTION;
	   EX_PIPE_SND         EXCEPTION;
	   EXCHG_PRT_ERROR     EXCEPTION;


	   --Status of worker
     lv_is_waiting      boolean := TRUE;


	   BEGIN

      p_TIMEOUT := pTIMEOUT;
	      v_monitor_request_id := pMONITOR_REQUEST_ID;

	      --PBS := TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));

	      FND_MESSAGE.SET_NAME('MSC','MSC_CL_PURGE_BATCH_SIZE');
	      FND_MESSAGE.SET_TOKEN('PBS',PBS);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

	      IF fnd_global.conc_request_id > 0 THEN
		 v_cp_enabled:= MSC_UTIL.SYS_YES;
	      ELSE
		 v_cp_enabled:= MSC_UTIL.SYS_NO;
	      END IF;

	      v_recalc_nra       := pRECALC_NRA;
	      v_recalc_sh        := pRECALC_SH;
	      v_exchange_mode    := pEXCHANGE_MODE;
	      v_so_exchange_mode := pSO_EXCHANGE_MODE;

	      v_prec_defined := FALSE;

	      MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID);    /* cursor org requires the org group flag */

   --   to initialize common global variables bug#5897346
      MSC_UTIL.INITIALIZE_COMMON_GLOBALS( pINSTANCE_ID);

	  INITIALIZE_LOAD_GLOBALS( pINSTANCE_ID);

	-- agmcont:
	      if (v_is_cont_refresh ) then
		     select lcid
		     INTO   v_last_collection_id
		     from   msc_apps_instances
		     where  instance_id = pINSTANCE_ID;
	      else
		     v_last_collection_id:= pLCID;
	      end if;

	      LOOP

		  EXIT WHEN is_monitor_status_running <> MSC_UTIL.SYS_YES;

		  EXIT WHEN is_request_status_running <> MSC_UTIL.SYS_YES;

	   -- ============= Check the execution time ==============

		     select (SYSDATE- START_TIME) into lv_process_time from dual;
		     IF lv_process_time > pTIMEOUT/1440.0 THEN Raise EX_PROCESS_TIME_OUT;
		     END IF;

	   -- ============= Get the Task from Task Que ==============

		  lv_pipe_ret_code := DBMS_PIPE.RECEIVE_MESSAGE( v_pipe_task_que, PIPE_TIME_OUT);

		  FND_MESSAGE.SET_NAME('MSC','MSC_CL_WORKER_RCV_RET_CODE');
		  FND_MESSAGE.SET_TOKEN('LV_TASK_NUMBER',lv_pipe_ret_code);
		  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);


		  IF lv_pipe_ret_code<>0 THEN

		        IF lv_pipe_ret_code = 1 THEN
                IF lv_is_waiting THEN
                  lv_is_waiting := false;
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Waiting for task to arrive');
                END IF;
            ELSE
               RAISE EX_PIPE_RCV;
            END IF;

		  ELSE
		     lv_is_waiting := true;
		     DBMS_PIPE.UNPACK_MESSAGE( lv_task_number);

		     FND_MESSAGE.SET_NAME('MSC','MSC_CL_WORKER_TSK_UNPACK');
		     FND_MESSAGE.SET_TOKEN('LV_TASK_NUM',lv_task_number);
		     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

		     EXIT WHEN lv_task_number<= 0;  -- No task is left or unknown error occurs.

	   -- ============= Execute the Task =============

		     lv_task_status := FAIL;

		     /** PREPLACE CHANGE START **/

		 --=====================================
		 -- NCPerf.
		 -- Call EXECUTE_PARTIAL_TASK in case of
		 -- Partial and Net Change collections.
		 -- ====================================

	-- agmcont
		     --EXECUTE_TASK( lv_task_status, lv_task_number);
		     IF (v_is_partial_refresh or v_is_incremental_refresh or
			 v_is_cont_refresh or (v_coll_prec.ds_mode = MSC_UTIL.SYS_YES) ) THEN
			 MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID);

			 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling Execute Partial Task for task number: '||lv_task_number);
			 EXECUTE_PARTIAL_TASK( lv_task_status, lv_task_number,
					       v_coll_prec);
		     ELSE

			 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Calling Execute Task for task number: '||lv_task_number);
			 EXECUTE_TASK( lv_task_status, lv_task_number);
		     END IF;

		      /**  PREPLACE CHANGE END  **/

		     IF lv_task_status <> OK THEN
			FND_MESSAGE.SET_NAME('MSC','MSC_CL_EXECUTE_TSK_PROB');
			FND_MESSAGE.SET_TOKEN('LV_TASK_NUMBER',lv_task_number);
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

			DBMS_PIPE.PACK_MESSAGE( -lv_task_number);
			IF (MSC_UTIL.G_MSC_DEBUG <> 'N' ) THEN
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Sent status '||lv_task_number||' to the monitor.');
			END IF;
		     ELSE

			DBMS_PIPE.PACK_MESSAGE( lv_task_number);

			IF (MSC_UTIL.G_MSC_DEBUG <> 'N' ) THEN
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Sent status '||lv_task_number||' to the monitor.');
			END IF;

		     END IF;

		     IF DBMS_PIPE.SEND_MESSAGE( v_pipe_wm)<>0 THEN
			RAISE EX_PIPE_SND;
		     END IF;

		     IF lv_task_status <> OK THEN
			DBMS_LOCK.SLEEP( 2);
		     END IF;

		  END IF;

	      END LOOP;

	      IF lv_task_number = 0 THEN
		 COMMIT;

		 DBMS_PIPE.PACK_MESSAGE( MSC_UTIL.SYS_YES);

		 IF DBMS_PIPE.SEND_MESSAGE( v_pipe_status)<>0 THEN
		    RAISE EX_PIPE_SND;
		 END IF;

		 FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_SUCCEED');
		 ERRBUF:= FND_MESSAGE.GET;
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ERRBUF);

		 IF v_warning_flag=MSC_UTIL.SYS_YES THEN
		    RETCODE:= MSC_UTIL.G_WARNING;
		 ELSE
		    RETCODE := MSC_UTIL.G_SUCCESS ;
		 END IF;

	      ELSE    -- unknown error occurs
		 ROLLBACK;

		 FND_MESSAGE.SET_NAME('MSC','MSC_CL_UNKNOWN_WORKER_ERR');
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

		 DBMS_PIPE.PACK_MESSAGE( MSC_UTIL.SYS_YES);

		 IF DBMS_PIPE.SEND_MESSAGE( v_pipe_status)<>0 THEN
		    RAISE EX_PIPE_SND;
		 END IF;

		 FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_FAIL');
		 ERRBUF:= FND_MESSAGE.GET;
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);

		 RETCODE := MSC_UTIL.G_ERROR;

	      END IF;

	    EXCEPTION

	      WHEN OTHERS THEN

		 ROLLBACK;

		 ERRBUF  := SQLERRM;
		 RETCODE := MSC_UTIL.G_ERROR;

		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);


		 -- send a message of 'unresolavable error' to monitor
		 DBMS_PIPE.PACK_MESSAGE( UNRESOVLABLE_ERROR);
		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Sending message :'||UNRESOVLABLE_ERROR||' to monitor.');

		 IF DBMS_PIPE.SEND_MESSAGE( v_pipe_wm)<>0 THEN
		    FND_MESSAGE.SET_NAME('MSC', 'MSC_MSG_SEND_FAIL');
		    FND_MESSAGE.SET_TOKEN('PIPE', v_pipe_wm);
		    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
		    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'FAIL TO SEND MESSAGE!');
		 END IF;

		 -- send a message of 'the worker ends its process' to monitor
		 DBMS_PIPE.PACK_MESSAGE( MSC_UTIL.SYS_YES);

		 IF DBMS_PIPE.SEND_MESSAGE( v_pipe_status)<>0 THEN
		    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'FAIL TO SEND MESSAGE!');
		 END IF;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error_Stack...' );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, DBMS_UTILITY.FORMAT_ERROR_STACK );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error_Backtrace...' );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

	   END LAUNCH_WORKER;

	-- ===============================================================


	   PROCEDURE LAUNCH_MONITOR( ERRBUF                     OUT NOCOPY VARCHAR2,
			      RETCODE				OUT NOCOPY NUMBER,
			      pINSTANCE_ID                      IN  NUMBER,
			      pTIMEOUT                          IN  NUMBER,
			      pTotalWorkerNum                   IN  NUMBER,
			      pRECALC_NRA                       IN  NUMBER,
			      pRECALC_SH                        IN  NUMBER,
			      pPURGE_SH				IN  NUMBER, --to delete the Sourcing History, default is no
            pAPCC_refresh   IN  NUMBER DEFAULT MSC_UTIL.SYS_NO) -- to refresh APCC data

	   IS

	   lc_i                PLS_INTEGER;
	   lv_task_number          NUMBER;
	   lv_task_not_completed   NUMBER := 0;

	   lv_process_time      NUMBER;

       lv_bon_start_end     NUMBER; -- bug 9194726

	   EX_PIPE_RCV        EXCEPTION;
	   EX_PIPE_SND        EXCEPTION;
	   EX_PROCESS_TIME_OUT EXCEPTION;

	   lv_pipe_ret_code         NUMBER;

	   lv_check_point          NUMBER := 0;

	   lvs_request_id       NumTblTyp := NumTblTyp(0);

	   lv_worker_committed NUMBER;

	   lv_delete_flag	NUMBER;

	   lv_start_time   DATE;

	   lv_collection_plan_exists  NUMBER;

	   lv_total_task_number       NUMBER:= TOTAL_TASK_NUMBER;

	   lv_sql_stmt 		VARCHAR2(5000);

	   lv_dblink		VARCHAR2(128);

	   lv_ret_res_ava       NUMBER ;

	   lv_po_flag       NUMBER;

	   lv_sales_order_flag  NUMBER;

	/*ATP SUMMARY CHANGES */
	   lv_atp_request_id    number;
	   lv_atp_request_id1   number;
	   lv_atp_package_exists number;
	   lv_inv_ctp number;
	   lv_MSC_ENABLE_ATP_SUMMARY number;

	   lv_debug_ret number;

	   lv_apps_schema varchar2(32);
	   lv_read_only_flag varchar2(32);

	   lv_pRECALC_NRA_NEW                NUMBER;/*5896618*/


	    CURSOR  c_query_package is
	       SELECT 1
	       FROM ALL_SOURCE
	       WHERE NAME = 'MSC_POST_PRO'
	       AND TYPE = 'PACKAGE BODY'
               AND OWNER = lv_apps_schema
               AND ROWNUM<2;


	/* SCE change starts */
	   lv_sce_pub_req_id	NUMBER;
	   lv_process_comp_err  NUMBER;
	/* SCE change ends */
	   total_task NUMBER;
	   l_req_id NUMBER;



	   BEGIN
	     p_TIMEOUT := pTIMEOUT;
	     msc_util.print_ods_params(pRECALC_SH,pPURGE_SH);
	     /*5896618*/
	     Select decode(nra,2,2,1) into lv_pRECALC_NRA_NEW  from msc_coll_parameters
       where instance_id =  pINSTANCE_ID;
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Recalculate NRA : '||lv_pRECALC_NRA_NEW);
       /*5896618*/
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Monitor running in dsMode= '||to_char(v_DSMode));

             lv_read_only_flag:='U';
             BEGIN
             select oracle_username
	     into lv_apps_schema
	     from fnd_oracle_userid where
	     read_only_flag = lv_read_only_flag;
	     EXCEPTION
	     WHEN OTHERS THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, SQLERRM);
	     END;

	     IF fnd_global.conc_request_id > 0 THEN
		v_cp_enabled:= MSC_UTIL.SYS_YES;
	     ELSE
		v_cp_enabled:= MSC_UTIL.SYS_NO;
	     END IF;

	     v_prec_defined := FALSE;

	     MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID);    /* cursor org requires the org group flag */
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Monitor running in DSMODE = '||to_char(v_coll_prec.ds_mode));

	     --   to initialize common global variables bug#5897346
      MSC_UTIL.INITIALIZE_COMMON_GLOBALS( pINSTANCE_ID);

	  INITIALIZE_LOAD_GLOBALS( pINSTANCE_ID);

	     BEGIN
             select po, sales_order
              into lv_po_flag, lv_sales_order_flag
             from msc_coll_parameters
             where instance_id=pINSTANCE_ID;
             END;

             v_req_ext_po_so_linking := FALSE;
              IF ( lv_po_flag  = MSC_UTIL.SYS_YES OR
                NOT ((v_is_partial_refresh  and lv_sales_order_flag = MSC_UTIL.SYS_NO) OR (v_is_cont_refresh  and lv_sales_order_flag = MSC_UTIL.SYS_NO))) Then
              v_req_ext_po_so_linking := TRUE;
              END IF;

	   BEGIN
	      SELECT MSC_UTIL.SYS_YES
		INTO lv_collection_plan_exists
		FROM MSC_PLANS
	       WHERE PLAN_ID= -1;
	   EXCEPTION

	      WHEN NO_DATA_FOUND THEN

		 INSERT INTO MSC_PLANS
		   ( PLAN_ID,
		     COMPILE_DESIGNATOR,
		     SR_INSTANCE_ID,
		     CURR_APPEND_PLANNED_ORDERS,
		     CURR_CUTOFF_DATE,
		     CURR_DEMAND_TIME_FENCE_FLAG,
		     CURR_OPERATION_SCHEDULE_TYPE,
		     CURR_OVERWRITE_OPTION,
		     CURR_PLANNING_TIME_FENCE_FLAG,
		     CURR_PLAN_TYPE,
		     CURR_START_DATE,
		     DAILY_CUTOFF_BUCKET,
		     DAILY_ITEM_AGGREGATION_LEVEL,
		     DAILY_MATERIAL_CONSTRAINTS,
		     DAILY_RESOURCE_CONSTRAINTS,
		     DAILY_RES_AGGREGATION_LEVEL,
		     ORGANIZATION_ID,
		     WEEKLY_CUTOFF_BUCKET,
		     WEEKLY_ITEM_AGGREGATION_LEVEL,
		     WEEKLY_MATERIAL_CONSTRAINTS,
		     WEEKLY_RESOURCE_CONSTRAINTS,
		     WEEKLY_RES_AGGREGATION_LEVEL,
		     OPTIMIZE_FLAG,
		     SCHEDULE_FLAG,
		     CURR_ENFORCE_DEM_DUE_DATES,
		     CURR_PLANNED_RESOURCES,
		     DAILY_RTG_AGGREGATION_LEVEL,
		     WEEKLY_RTG_AGGREGATION_LEVEL,
		     PERIOD_CUTOFF_BUCKET,
		     PERIOD_MATERIAL_CONSTRAINTS,
		     PERIOD_RESOURCE_CONSTRAINTS,
		     PERIOD_ITEM_AGGREGATION_LEVEL,
		     PERIOD_RES_AGGREGATION_LEVEL,
		     LAST_UPDATE_DATE,
		     LAST_UPDATED_BY,
		     CREATION_DATE,
		     CREATED_BY )
	      VALUES
		   ( -1,
		     'Collection',
		     v_instance_id,
		     1,
		     v_current_date,
		     1,
		     1,
		     1,
		     1,
		     1,
		     v_current_date,
		     1,
		     1,
		     1,
		     1,
		     1,
		     -1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     1,
		     v_current_date,
		     v_current_user,
		     v_current_date,
		     v_current_user);

	       WHEN OTHERS THEN
		   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
		    RAISE;
	   END;

	     lv_check_point:= 1;

	     IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_COLLECTING) THEN

        	COMMIT;
        	lv_check_point:= 2;
     	     ELSE
        	ROLLBACK;
        	RETURN;
     	     END IF;

     DBMS_PIPE.PURGE( v_pipe_task_que);
     DBMS_PIPE.PURGE( v_pipe_wm);
     DBMS_PIPE.PURGE( v_pipe_mw);
     DBMS_PIPE.PURGE( v_pipe_status);

     --- PREPLACE CHANGE START ---
 IF (v_is_partial_refresh OR v_is_cont_refresh) THEN

        /* added this piece of code for Bug: 2015868, the recalculation of Resource availability and
             Sourcing history needs to be set in Planning ODS load only, for Partial Refresh
            It will behave same as in complete refresh coll*/

          update msc_coll_parameters
          set  SOURCING_HISTORY = pRECALC_SH
          where instance_id =  pINSTANCE_ID;

     --MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID);   /* calling above */
 END IF;

 /* CP changes start */
 /* Find out the MSC:Configuration profile option value. */

       MSC_UTIL.G_MSC_CONFIGURATION := nvl(fnd_profile.value('MSC_X_CONFIGURATION'), MSC_UTIL.G_CONF_APS);

 /* Put configuration related information in LOG file */

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'The MSC : Configuration profile option : '||MSC_UTIL.G_MSC_CONFIGURATION);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Responsibility_id = '||NVL(FND_GLOBAL.RESP_ID,-99));
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Application_id = '||NVL(FND_GLOBAL.RESP_APPL_ID, -99));

 /* CP changes end */

--agmcont:

     --===========================================
     -- NCPerf.
     -- Call LAUNCH_MON_PARTIAL in case of
     -- Partial and Net Change refresh collections
     -- ==========================================

     IF (v_is_partial_refresh or v_is_incremental_refresh
         or v_is_cont_refresh) THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'calling LAUNCH_MON_PARTIAL');
        LAUNCH_MON_PARTIAL(
                      ERRBUF             ,
                      RETCODE            ,
                      pINSTANCE_ID       ,
                      pTIMEOUT           ,
                      pTotalWorkerNum    ,
                      lv_pRECALC_NRA_NEW ,
                      pRECALC_SH         ,
		                  pPURGE_SH          ,
		                  pAPCC_refresh
          );
        RETURN;
     END IF;

      ---  PREPLACE CHANGE END  ---

  -- ============== Create Temproray Tables ====================
     v_exchange_mode:= MSC_UTIL.SYS_NO;
     v_so_exchange_mode:= MSC_UTIL.SYS_NO;

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'check4 ');
  IF v_is_complete_refresh AND is_msctbl_partitioned('MSC_SYSTEM_ITEMS')  THEN
     IF MSC_CL_EXCHANGE_PARTTBL.Initialize( v_instance_id,
                                            v_instance_code,
                                            v_is_so_complete_refresh) THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Initialized');
        IF MSC_CL_EXCHANGE_PARTTBL.Create_Temp_Tbl THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' CREATE TEMP TABLES DONE ');
           v_exchange_mode:= MSC_UTIL.SYS_YES;

           IF v_is_so_complete_refresh THEN
              v_so_exchange_mode:= MSC_UTIL.SYS_YES;
           END IF;
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Exchange Mode = '||v_exchange_mode);
        ELSE
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Create_Temp_Tbl failed');
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

           RETCODE := MSC_UTIL.G_ERROR;

           RETURN;

        END IF;  -- end Create_Temp_Tbl

   ELSE
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

      RETCODE := MSC_UTIL.G_ERROR;

      RETURN;

   END IF;  --  initialization

END IF; -- complete refresh and partitioned

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'CREATE PARTITIONS DONE');

/* SCE CHANGE starts*/

    -- =============================================
	-- Change the company name in msc_companies and
	-- msc_trading_partners if it is changed in
	-- MSC : Operator Company Name profile option.
    -- =============================================


	IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
		OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN
	        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'before PROCESS_COMPANY_CHANGE');
		MSC_CL_SCE_COLLECTION.PROCESS_COMPANY_CHANGE(lv_process_comp_err);

        if (lv_process_comp_err = MSC_UTIL.G_ERROR) THEN
            ROLLBACK;
            RETCODE := MSC_UTIL.G_ERROR;
            RETURN;
        end if;

       END IF;

  -- ========== Get My Company Name ============
    --IF (G_MSC_CONFIGURATION = G_CONF_APS_SCE OR G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN
        v_my_company_name := MSC_CL_SCE_COLLECTION.GET_MY_COMPANY;

        IF (v_my_company_name = null) then
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error while fetching Company Name');
            ROLLBACK;
            RETCODE := MSC_UTIL.G_ERROR;
            RETURN;
        END IF;
    --END IF;

  -- ========= Get the parameter value ========
/* SCE CHANGE ends*/

  -- =========== Data Cleansing =================

/* SCE Debug */
        FND_MESSAGE.SET_NAME('MSC', 'MSC_X_SHOW_CONFIG');
        FND_MESSAGE.SET_TOKEN('NAME', MSC_UTIL.G_MSC_CONFIGURATION);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

        FND_MESSAGE.SET_NAME('MSC', 'MSC_X_SHOW_COMPANY');
        FND_MESSAGE.SET_TOKEN('NAME', v_my_company_name);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

/*   Following step does the data cleanup in staging tables and creates
     global Ids for Trading Partner and Items.

     If MSC:Configuration = 'APS' then
         - Execute MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA (Hook for Customization)
         - TRANSFORM KEYS

     If MSC:Configuration = 'APS+SCE' or 'SCE' then
         - Execute MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA (Hook for Customization)
         - MSC_CL_SCE_COLLECTION.CLEANSE_DATA_FOR_SCE (Data cleanup for Multi Company)
		 - MSC_CL_SCE_COLLECTION.SCE_TRANSFORM_KEYS (New Companies and Sites in Collaboration area)
		 - TRANSFORM KEYS (Global Ids for Trading Partners in Planning Area)
	*/

	    /* DEBUG */
	    if v_is_incremental_refresh THEN MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Incremental Refresh'); end if;

	     IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'before MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA 1');
		 IF MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA
		     /* SCE CHANGE starts */
		     /* Data cleanup based on MSC:Configuration profile option */
			AND MSC_CL_SCE_COLLECTION.CLEANSE_DATA_FOR_SCE(v_instance_id,
								   v_my_company_name)
			AND MSC_CL_SCE_COLLECTION.SCE_TRANSFORM_KEYS(v_instance_id,
								 v_current_user,
								 v_current_date,
								 v_last_collection_id,
								 v_is_incremental_refresh,
								 v_is_complete_refresh,
								 v_is_partial_refresh,
                                 v_is_cont_refresh,
								 v_coll_prec.tp_vendor_flag,
								 v_coll_prec.tp_customer_flag)

		     /* SCE CHANGE ends */

		     AND MSC_CL_SETUP_ODS_LOAD.TRANSFORM_KEYS THEN

                COMMIT;


         ELSE

            ROLLBACK;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DC_FAIL');
            ERRBUF:= FND_MESSAGE.GET;

            IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
               COMMIT;
            END IF;

            RETCODE := MSC_UTIL.G_ERROR;

            RETURN;

         END IF;

     ELSIF MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'before MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA and MSC_CL_SETUP_ODS_LOAD.TRANSFORM_KEYS ');
         IF MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA AND MSC_CL_SETUP_ODS_LOAD.TRANSFORM_KEYS THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'after MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA and MSC_CL_SETUP_ODS_LOAD.TRANSFORM_KEYS ');
            COMMIT;
         ELSE
            FND_MESSAGE.SET_NAME('MSC','MSC_CL_TRANSFORM_KEY_ERR');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

            ROLLBACK;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DC_FAIL');
            ERRBUF:= FND_MESSAGE.GET;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

            IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
               COMMIT;
            END IF;
            RETCODE := MSC_UTIL.G_ERROR;

            RETURN;

          END IF;
      END IF; -- G_MSC_CONFIGURATION

      --bug3954345. Setting so_tbl_status to 2 so that ATP inquiry doesn't go through
      --unless all the related ATP tables are populated

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'update so_tbl status to no');
     IF (v_coll_prec.tp_vendor_flag = MSC_UTIL.SYS_YES OR v_coll_prec.tp_customer_flag = MSC_UTIL.SYS_YES OR v_coll_prec.sourcing_rule_flag=MSC_UTIL.SYS_YES OR v_coll_prec.atp_rules_flag=MSC_UTIL.SYS_YES) THEN
     UPDATE MSC_APPS_INSTANCES mai
     SET
       	so_tbl_status= MSC_UTIL.SYS_NO,
       	LAST_UPDATE_DATE= v_current_date,
        LAST_UPDATED_BY= v_current_user,
        REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
     WHERE mai.INSTANCE_ID= v_instance_id;
      commit;
     END IF;

  -- ============ Load Orgnization, Designator, UOM ==============
  /* load trading_partner first to provide organization_code information */

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_TRADING_PARTNER');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_SETUP_ODS_LOAD.LOAD_TRADING_PARTNER;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'after MSC_CL_SETUP_ODS_LOAD.LOAD_TRADING_PARTNER');

     /* SCE Change starts */
     /* By this time Trading Partners , Organizations are loaded into planning area
        as well as collaboration area.
        Now we can populate the msc_trading_partner_maps table.

        Perform this step if the profile option is 'APS + SCE' OR 'SCE'.
     */
     IF MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR
        MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SCE_COLLECTION.POPULATE_TP_MAP_TABLE');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

            MSC_CL_SCE_COLLECTION.POPULATE_TP_MAP_TABLE(v_instance_id);

     END IF;
     /* SCE Change ends */

     COMMIT;

     /*   Load parameters in the Main ODS Load so that this information is available to the function
     CALC_RESOURCE_AVAILABILITY called within LOAD_CALENDAR_DATE */

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_PARAMETER');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_SETUP_ODS_LOAD.LOAD_PARAMETER;

     COMMIT;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'after MSC_CL_SETUP_ODS_LOAD.LOAD_PARAMETER');
     /* SCE Change starts */

     /*  Populate msc_st_item_suppliers with company_id and company_site_id
         This step is required only if MSC:Configuration = 'SCE' or 'APS + SCE'
     */

     /* This is post transform keys process. */

     IF MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR
        MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE THEN

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SCE_COLLECTION.CLEANSE_TP_ITEMS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_SCE_COLLECTION.CLEANSE_TP_ITEMS(v_instance_id);

     END IF;

     /* SCE Change ends */

  /* load schedule to provide schedule designator information */

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_DESIGNATOR');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_DEMAND_ODS_LOAD.LOAD_DESIGNATOR;

     COMMIT;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'after MSC_CL_DEMAND_ODS_LOAD.LOAD_DESIGNATOR');
  /* load forecast designators */

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_FORECASTS');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_DEMAND_ODS_LOAD.LOAD_FORECASTS;

     COMMIT;

  /* load unit of measure */

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_UOM');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_SETUP_ODS_LOAD.LOAD_UOM;

     COMMIT;

  /* CP-ACK starts */
  -- ============================================================
  -- We will also load Calendar Dates as Set up entity.
  -- We need to do these changes since CP code refers to Calendar
  -- ============================================================
     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
	 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_SET_UP');
	 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
	 MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_SET_UP;

  /* CP-ACK ends */

     IF v_is_complete_refresh THEN
        msc_analyse_tables_pk.analyse_table( 'MSC_TRADING_PARTNERS');
        msc_analyse_tables_pk.analyse_table( 'MSC_DESIGNATORS');
     END IF;


     IF (v_instance_type <> MSC_UTIL.G_INS_OTHER) AND (v_is_complete_refresh OR
          (v_is_partial_refresh AND v_coll_prec.resource_nra_flag = MSC_UTIL.SYS_YES)) THEN
             -- DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1);
             -- DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1);
	  IF v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
	    DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1);
	    DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1);
	  ELSE
	    v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
	    DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1,v_sub_str);
	    DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1,v_sub_str);
	  END IF;
     END IF;
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'before launching workers');
  -- ============ Lauch the Workers here ===============

     lvs_request_id.EXTEND( pTotalWorkerNum);

     IF v_cp_enabled= MSC_UTIL.SYS_YES THEN

     FOR lc_i IN 1..pTotalWorkerNum LOOP
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'before launching worker:' || to_char(lc_i));
       lvs_request_id(lc_i) := FND_REQUEST.SUBMIT_REQUEST(
                          'MSC',
                          'MSCPDCW',
                          NULL,  -- description
                          NULL,  -- start date
                          FALSE, -- TRUE,
                          FND_GLOBAL.CONC_REQUEST_ID,
                          pINSTANCE_ID,
                          v_last_collection_id,
                          pTIMEOUT,
                          lv_pRECALC_NRA_NEW,
                          pRECALC_SH,
                          v_exchange_mode,
                          v_so_exchange_mode);

       COMMIT;

       IF lvs_request_id(lc_i)= 0 THEN

          ROLLBACK;

          IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
             COMMIT;
          END IF;

          FOR lc_i IN 1..pTotalWorkerNum LOOP

              DBMS_PIPE.PACK_MESSAGE( -1);

              IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
                 RAISE EX_PIPE_SND;
              END IF;

              FND_MESSAGE.SET_NAME('MSC','MSC_CL_SEND_WOR_END');
              FND_MESSAGE.SET_TOKEN('LCI',lc_i);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
          END LOOP;

          FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_LAUNCH_WORKER_FAIL');
          ERRBUF:= FND_MESSAGE.GET;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

          RETCODE := MSC_UTIL.G_ERROR;

          COMMIT;

          RETURN;
       ELSE
         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_WORKER_REQUEST_ID');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID', lvs_request_id(lc_i));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
       END IF;

     END LOOP;

     ELSE

          COMMIT;

     END IF;  -- DEVELOPING

     msc_util.print_trace_file_name(FND_GLOBAL.CONC_REQUEST_ID);

  -- ============ Send Tasks to Task Que 'v_pipe_task_que' =============
  --   load sales orders will be called from load_supply - link demand-supply
    /* ds change */
    if v_coll_prec.ds_mode = MSC_UTIL.SYS_YES THEN
  	total_task :=  TOTAL_PARTIAL_TASKS;
    else
	total_task := TOTAL_TASK_NUMBER;
    end if;

     FOR lc_i IN 1..total_task LOOP
--         IF v_is_so_incremental_refresh AND
--           IF lc_i = TASK_SALES_ORDER THEN
--            lv_total_task_number:= TOTAL_TASK_NUMBER-1;
 --           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Removed the task for Sales orders');
  --       ELSE
          /* ds_change start*/
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ds mode= '||to_char(v_coll_prec.ds_mode));

          IF  v_coll_prec.ds_mode = MSC_UTIL.SYS_YES THEN
            IF Q_PARTIAL_TASK (pINSTANCE_ID, lc_i) THEN
                DBMS_PIPE.PACK_MESSAGE( lc_i);
                lv_task_not_completed := lv_task_not_completed + 1;

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Sending DS task number: '||lc_i||' to the queue');

                IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que) <> 0 THEN

                   FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERROR_SEND_TSK');
                   FND_MESSAGE.SET_TOKEN('LCI',lc_i);
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

                   RAISE EX_PIPE_SND;
                END IF;
           ELSE

		 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'task: '||lc_i|| ' not loaded for worker ');
           END IF; /* Q_PARTIAL_TASK */

            /* ds_change end*/
          ELSE

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Sending task number: '||lc_i||' to the queue');
             DBMS_PIPE.PACK_MESSAGE( lc_i);
             lv_task_not_completed := lv_task_not_completed + 1;


             IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN

                 FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERROR_SEND_TSK');
                 FND_MESSAGE.SET_TOKEN('LCI',lc_i);
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

                 RAISE EX_PIPE_SND;
             END IF;
         END IF; /* v_DSMode */
     END LOOP;

     DBMS_LOCK.SLEEP( 5);   -- initial estimated sleep time

     --lv_task_not_completed := lv_total_task_number;

     lv_bon_start_end :=0;  -- bug9194726
     FND_MESSAGE.SET_NAME('MSC','MSC_CL_TOTAL_TSK_ADDED');
     FND_MESSAGE.SET_TOKEN('LV_TASK_NOT_COMPLETED',lv_task_not_completed);
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

     LOOP

         var_debug := 1;
         EXIT WHEN is_request_status_running <> MSC_UTIL.SYS_YES;

         var_debug := 2;
         EXIT WHEN is_worker_status_valid(lvs_request_id) <> MSC_UTIL.SYS_YES;

         lv_pipe_ret_code:= DBMS_PIPE.RECEIVE_MESSAGE( v_pipe_wm, PIPE_TIME_OUT);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Pipe Return code: '||lv_pipe_ret_code);

         IF lv_pipe_ret_code=0 THEN

            DBMS_PIPE.UNPACK_MESSAGE( lv_task_number);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Unpacked Task Number : '||lv_task_number);

            if lv_task_number = TASK_ATP_RULES THEN
            	G_TASK_ATP_RULES :=1;
            elsif lv_task_number = TASK_SOURCING THEN
            	G_TASK_SOURCING :=1;
            elsif lv_task_number = TASK_ROUTING THEN
               lv_bon_start_end := lv_bon_start_end + 1;
            elsif lv_task_number = TASK_OPERATION_NETWORKS THEN
               lv_bon_start_end := lv_bon_start_end + 1;
            elsif lv_task_number = TASK_ROUTING_OPERATIONS THEN
               lv_bon_start_end := lv_bon_start_end + 1;
            END if;


            if G_TASK_ATP_RULES =1 and G_TASK_SOURCING =1 then
                UPDATE MSC_APPS_INSTANCES mai
           	SET
           	so_tbl_status= MSC_UTIL.SYS_YES,
           	LAST_UPDATE_DATE= v_current_date,
                LAST_UPDATED_BY= v_current_user,
                REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
         	WHERE mai.INSTANCE_ID= v_instance_id;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'update so tbl status');
            commit;
            G_TASK_ATP_RULES :=0;
            G_TASK_SOURCING :=0;
            end if;

            IF lv_task_number>0 THEN   -- If it's ok, the vlaue is the task number

               lv_task_not_completed := lv_task_not_completed -1;
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Tasks remaining :'||lv_task_not_completed);

               IF lv_task_not_completed= 0 THEN
                  var_debug := 3;
                  EXIT;
               END IF;

            ELSE

               var_debug := 4;
               EXIT WHEN lv_task_number= UNRESOVLABLE_ERROR;

               DBMS_PIPE.PACK_MESSAGE( -lv_task_number);  -- resend the task to the task que

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Re-sending the task number: '||lv_task_number||' to the queue');

               IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
                  RAISE EX_PIPE_SND;
               END IF;

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Task number: '||lv_task_number||' re-sent to the pipe queue');
            END IF;

         ELSIF lv_pipe_ret_code<> 1 THEN
             FND_MESSAGE.SET_NAME('MSC','MSC_CL_RCV_PIPE_ERR');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

             RAISE EX_PIPE_RCV;   -- If the error is not time-out error
         END IF;

   -- ============= Check the execution time ==============

         select (SYSDATE- START_TIME) into lv_process_time from dual;

         IF lv_process_time > pTIMEOUT/1440.0 THEN Raise EX_PROCESS_TIME_OUT;
         END IF;

     END LOOP;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '----------------------------------------------------');
     FND_MESSAGE.SET_NAME('MSC','MSC_CL_TSK_NOT_COMP');
     FND_MESSAGE.SET_TOKEN('LV_TASK_NOT_COMPLETED',lv_task_not_completed);
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

     IF (var_debug = 1) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_1');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 2) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_2');
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

        lv_task_number:= -1;

        ROLLBACK;

        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_FAIL');
        ERRBUF:= FND_MESSAGE.GET;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

        RETCODE := MSC_UTIL.G_ERROR;

     ELSE

        lv_task_number:= 0;

        UPDATE MSC_APPS_INSTANCES mai
           SET LAST_UPDATE_DATE= v_current_date,
               LAST_UPDATED_BY= v_current_user,
               REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
         WHERE mai.INSTANCE_ID= v_instance_id;
        commit;

	IF (v_is_complete_refresh) THEN
	    IF MSC_CL_SUPPLY_ODS_LOAD.drop_supplies_tmp_ind THEN
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Index Dropping on Temp Supplies table successful.');
	    ELSE
	       ROLLBACK;
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'Failed in Dropping the temp Index on Supplies table.' );
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

	       RETCODE := MSC_UTIL.G_ERROR;
	       RAISE  SUPPLIES_INDEX_FAIL;
	    END IF;
	END IF;

        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_SUCCEED');
        ERRBUF:= FND_MESSAGE.GET;
        RETCODE := MSC_UTIL.G_SUCCESS ;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,  ERRBUF);

     END IF;

      lv_debug_ret := RETCODE;

     IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
         COMMIT;
     END IF;

     IF (lv_debug_ret = MSC_UTIL.G_ERROR) OR (RETCODE = MSC_UTIL.G_ERROR) THEN
         RETCODE := MSC_UTIL.G_ERROR;
     END IF;

     FOR lc_i IN 1..pTotalWorkerNum LOOP

        FND_MESSAGE.SET_NAME('MSC','MSC_CL_SEND_WOR_END');
        FND_MESSAGE.SET_TOKEN('LCI',lc_i);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

        DBMS_PIPE.PACK_MESSAGE( lv_task_number);

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Sending task number: '||lv_task_number||' to the worker '||lc_i);
        IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
            RAISE EX_PIPE_SND;
        END IF;

     END LOOP;

     lv_worker_committed:= 0;

     lv_start_time:= SYSDATE;

     LOOP

         lv_pipe_ret_code:= DBMS_PIPE.RECEIVE_MESSAGE( v_pipe_status, PIPE_TIME_OUT);

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
         --EXIT WHEN lv_process_time > 10.0/1440.0;   -- wait for 10 minutes
         IF ( lv_process_time > 3.0/1440.0) AND (lv_worker_committed <> pTotalWorkerNum) THEN
                 EXIT WHEN all_workers_completed(lvs_request_id) = MSC_UTIL.SYS_YES;
         END IF;

     END LOOP;

     IF lv_worker_committed<> pTotalWorkerNum THEN

        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_FAIL_TO_COMMIT');
        ERRBUF:= FND_MESSAGE.GET;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

        FND_MESSAGE.SET_NAME('MSC','MSC_CL_CHECK_PDC_LOG');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

        RETCODE := MSC_UTIL.G_ERROR;

     ELSE

        IF lv_task_number= 0 THEN

        IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN --Version
                /* call the function to link the Demand_id and Parent_id in MSC_DEMANDS for 11i Source instance  */

              IF  MSC_CL_DEMAND_ODS_LOAD.LINK_PARENT_SALES_ORDERS_MDS THEN
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Linking of Sales Order line in MDS to its Parent Sales orders is successful.....');
              ELSE
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error in Linking Sales order line in MDS to its parent Sales order......');
                  RETCODE := MSC_UTIL.G_WARNING;
              END IF;
        END IF;

        /* ds change  start */
        IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN
                 IF  MSC_CL_SETUP_ODS_LOAD.LINK_SUPPLY_TOP_LINK_ID THEN
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'update of msc_supplies top_transaction_id for eam is successful.....');
                  ELSE
                      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error in update of msc_supplies top_transaction_id......');
                      RETCODE := MSC_UTIL.G_WARNING;
                  END IF;
        END IF;
       /* ds change  end */
	 IF (v_is_complete_refresh) THEN
	    IF (MSC_CL_SUPPLY_ODS_LOAD.drop_supplies_tmp_ind and MSC_CL_DEMAND_ODS_LOAD.drop_demands_tmp_ind and MSC_CL_DEMAND_ODS_LOAD.drop_sales_orders_tmp_ind)  THEN
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Index Dropping on Temp Tables successful.');
	    ELSE
	       ROLLBACK;
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'Failed in Dropping the Indexes on Temp Tables.' );
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

	       RETCODE := MSC_UTIL.G_ERROR;
	       RAISE  SUPPLIES_INDEX_FAIL;
	    END IF;
	 END IF;

           IF v_exchange_mode= MSC_UTIL.SYS_YES THEN

              IF alter_temp_table_by_monitor = FALSE THEN
                 RETCODE:= MSC_UTIL.G_ERROR;
              ELSE
                 --log_message ('successfully altered phase 2 tables');
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,  'successfully altered phase 2 tables.' );
                 NULL;
              END IF;

              IF NOT MSC_CL_EXCHANGE_PARTTBL.Exchange_Partition THEN
                 RETCODE:= MSC_UTIL.G_ERROR;
              END IF;
              IF NOT MSC_CL_EXCHANGE_PARTTBL.Drop_Temp_Tbl THEN
                 v_warning_flag:=MSC_UTIL.SYS_YES;
              END IF;
           END IF;

           IF (v_req_ext_po_so_linking) Then
                    IF  ( v_apps_ver >= MSC_UTIL.G_APPS115 ) THEN
                           BEGIN
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling Linking of Sales Order for 11i source ...');
                            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_EXT');
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                            -- Calling the Linking of external Sales orders for the fix 2353397  --
                            MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_EXT;
                           END;

                    END IF;
           END IF;

	   IF ( v_coll_prec.item_flag = MSC_UTIL.SYS_YES or v_coll_prec.bom_flag = MSC_UTIL.SYS_YES ) THEN
		 MSC_CL_ITEM_ODS_LOAD.UPDATE_LEADTIME;
	   END IF;
       IF lv_bon_start_end = 3 THEN
          MSC_CL_ROUTING_ODS_LOAD.GET_START_END_OP ;
       END IF;
           UPDATE MSC_APPS_INSTANCES
              SET so_tbl_status= MSC_UTIL.SYS_YES
            WHERE instance_id= v_instance_id;
           /*Resource Start Time*/
            -- Set The collections Start Time . Get the start time in the out variable
            SET_COLLECTIONS_START_TIME(v_instance_id, v_resource_start_time);

           COMMIT;

           IF(v_coll_prec.po_receipts_flag = MSC_UTIL.SYS_YES) THEN
         v_sub_str := 'AND ORGANIZATION_ID' || MSC_UTIL.v_in_org_str;
                DELETE_MSC_TABLE('MSC_PO_RECEIPTS', v_instance_id,NULL,v_sub_str);
                --DELETE MSC_PO_RECEIPTS
                --WHERE SR_INSTANCE
                COMMIT;

         	MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Table MSC_PO_RECEIPTS Deleted');

         	MSC_CL_MISCELLANEOUS.load_po_receipts
                   ( v_instance_id,
                     MSC_UTIL.v_in_org_str,
                     v_last_collection_id,
                     v_current_date,
                     v_current_user,
                     NULL);
                COMMIT;
           END IF;

  	   IF (pPURGE_SH = MSC_UTIL.SYS_YES) THEN

	      SELECT DECODE(nvl(FND_PROFILE.VALUE('MSC_PURGE_ST_CONTROL'),'N'),'Y',1,2)
		INTO lv_delete_flag
		FROM DUAL;
                 --  If the above profile option is set then we are assuming that there is only one source
                 --   So we can safely truncate the msc_sourcing_history table to improve performance
                IF (lv_delete_flag = 2) THEN
                        DELETE MSC_SOURCING_HISTORY
                        WHERE SR_INSTANCE_ID = v_instance_id;
                ELSE
                        TRUNCATE_MSC_TABLE('MSC_SOURCING_HISTORY');
                END IF;

               COMMIT;

         	MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Table MSC_SOURCING_HISTORY Deleted');

           END IF;

           IF pRECALC_SH= MSC_UTIL.SYS_YES THEN

              MSC_CL_MISCELLANEOUS.load_sourcing_history
                   ( v_instance_id,
                     v_last_collection_id,
                     v_current_date,
                     v_current_user,
                     NULL);
           END IF;

        -- SAVEPOINT WORKERS_COMMITTED;

	-- BUG # 3020614
        -- For Partial refresh, if Both the bom_flag and calendar_flag are
        -- not set then call the procedure calc_resource_availability in
        -- serial mode if lv_pRECALC_NRA_NEW is set.
        -- Otherwise, the procedure load_calendar_date makes a call to
        -- this procedure.


           IF (v_is_partial_refresh AND
              (v_coll_prec.bom_flag = MSC_UTIL.SYS_NO) AND
              (v_coll_prec.calendar_flag = MSC_UTIL.SYS_NO)) THEN


           IF v_discrete_flag= MSC_UTIL.SYS_YES AND lv_pRECALC_NRA_NEW= MSC_UTIL.SYS_YES THEN
	      IF  v_instance_type = MSC_UTIL.G_INS_OTHER THEN
      		  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'MSC_UTIL.G_INS_OTHER: Deleting MSC_NET_RESOURCE_AVAIL...');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug-03');
                  DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1,MSC_UTIL.v_in_org_str);
                  DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1,MSC_UTIL.v_in_org_str);
              END IF;
              /* Resource Start TIme Changes */

	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'before CALC_RESOURCE_AVAILABILITY ');
	      lv_ret_res_ava:=MSC_RESOURCE_AVAILABILITY.CALC_RESOURCE_AVAILABILITY(v_resource_start_time,v_coll_prec.org_group_flag,FALSE);


	      IF lv_ret_res_ava = 2 THEN
                FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
                ERRBUF:= FND_MESSAGE.GET;
              	v_warning_flag:=MSC_UTIL.SYS_YES;
	      ELSIF lv_ret_res_ava <> 0 THEN
		 FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
                 ERRBUF:= FND_MESSAGE.GET;
                 RETCODE:= MSC_UTIL.G_ERROR;


              -- ROLLBACK WORK TO SAVEPOINT WORKERS_COMMITTED;

              END IF;

           END IF;
	   END IF;

        END IF;  -- lv_task_number= 0

     END IF;  -- commit fail?

     COMMIT;

     /*        LAUNCH DATA PURGING PROCESS         */

     IF (v_cp_enabled= MSC_UTIL.SYS_YES AND RETCODE<>MSC_UTIL.G_ERROR) THEN

         /*  added the  code so that the request - Purge Staging tables will be called via function
             purge_staging for bug:     2452183 , Planning ODS Load was always completing with warnings
              because when the sub-req MSCPDCP completes , it restarts the launch_monitor */

         IF PURGE_STAGING(pINSTANCE_ID) THEN
            COMMIT;
         ELSE
            IF RETCODE <> MSC_UTIL.G_ERROR THEN RETCODE := MSC_UTIL.G_WARNING; END IF;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, SQLERRM);
         END IF;

     END IF;

     COMMIT;

     IF ( v_is_complete_refresh ) AND ( v_coll_prec.org_group_flag=MSC_UTIL.G_ALL_ORGANIZATIONS )  THEN

       BEGIN
	SELECT DECODE(M2A_DBLINK,
		NULL,'',
		'@'||M2A_DBLINK)
	INTO lv_dblink
	FROM MSC_APPS_INSTANCES
	WHERE INSTANCE_ID=v_instance_id;
	lv_sql_stmt:=
	'BEGIN MRP_CL_REFRESH_SNAPSHOT.PURGE_OBSOLETE_DATA'||lv_dblink||';END;';

	EXECUTE IMMEDIATE lv_sql_stmt;

	COMMIT;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Truncated Source AD Tables Successfully');

	EXCEPTION
	    WHEN OTHERS THEN
		ERRBUF:=SQLERRM||' Error in Call to Purge Obsolete Data ';
                v_warning_flag := MSC_UTIL.SYS_YES;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);

       END;

  END IF; -- complete refresh is yes

  /* ATP SUMMARY CHANGES - LAUNCH CONCURENT PROGRAMS FOR ATP  */
  /* CHECK TO SEE IF THE PACKAGE EXISTS */
  BEGIN
           OPEN  c_query_package;
           FETCH c_query_package INTO lv_atp_package_exists;
           CLOSE c_query_package;
           /* CHECK TO SEE IF THE ATP PROFILE INV_CTP is set to 5 */
             SELECT nvl(fnd_profile.value('INV_CTP'),-10)
             INTO lv_inv_ctp
             FROM dual;

           /* CHECK TO SEE IF THE ATP PROFILE INV_CTP is set to 5 */
             SELECT decode(nvl(fnd_profile.value('MSC_ENABLE_ATP_SUMMARY'),'N'),'Y',1,2)
             INTO lv_MSC_ENABLE_ATP_SUMMARY
             FROM dual;

  EXCEPTION
           WHEN OTHERS THEN
             IF c_query_package%ISOPEN THEN CLOSE c_query_package; END IF;
             lv_atp_package_exists := 2;
  END;

  IF (lv_atp_package_exists = 1 AND lv_inv_ctp = 5 and lv_MSC_ENABLE_ATP_SUMMARY = 1 ) THEN
   IF v_is_complete_refresh   THEN

    BEGIN
     IF (v_cp_enabled= MSC_UTIL.SYS_YES AND v_is_so_complete_refresh ) THEN
        lv_atp_request_id := FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCCLCNC',
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- sub request,
                             pINSTANCE_ID, -- Instance Id
                             MSC_UTIL.SYS_YES,      -- Refresh type complete
                             MSC_UTIL.SYS_YES,      -- Refresh SO Complete
                             MSC_UTIL.SYS_YES);     -- Refresh Supply/Demand
     END IF;
     IF (v_cp_enabled= MSC_UTIL.SYS_YES AND v_is_so_incremental_refresh ) THEN
        lv_atp_request_id := FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCCLCNC',
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- sub request,
                             pINSTANCE_ID, -- Instance Id
                             MSC_UTIL.SYS_YES,      -- Refresh type complete
                             MSC_UTIL.SYS_NO,      -- Refresh SO Incremental
                             MSC_UTIL.SYS_YES);     -- Refresh Supply/Demand

     END IF;
     COMMIT;
     EXCEPTION
         WHEN OTHERS THEN
         ERRBUF:=SQLERRM||' Request: '||lv_atp_request_id||'  Error in Call To program MSCCLCNC ';
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
    END;

  END IF; -- Complete refresh Condition
 END IF; -- ATP Package exists or not and the profile options are set or not
 /* ATP SUMMARY CHANGES - END - LAUNCH CONCURENT PROGRAMS FOR ATP  */

 /* SCE Change Starts */
 /* If MSC:Configuration profile is set to SCE or APS+SCE then we need to publish
    ODS data to collaboration area i.e. msc_sup_dem_entries.
    The SCE program will push following order types.
    	- Purchase Order (Order_Type = 1)
    	- PO in receiving (Order Type = 8)
    	- Requisition (Order_Type = 2)
    	- Intransit Shipment (Order_Type) = 11
 */

    BEGIN
        IF MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR
           MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE THEN

		   --MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID); -- This will initialze the record v_coll_prec

            lv_sce_pub_req_id := FND_REQUEST.SUBMIT_REQUEST(
                                 'MSC',
                                 'MSCXPUBO',
                                 NULL,  -- description
                                 NULL,  -- start date
                                 FALSE, -- sub request,
                                 v_instance_id,
                                 v_current_user,
                                 MSC_UTIL.SYS_YES,
                                 MSC_UTIL.SYS_YES,
                                 MSC_UTIL.SYS_YES,
								 MSC_UTIL.SYS_YES,
								 /* CP-ACK starts */
								 MSC_UTIL.SYS_YES,
								 /* CP-ACK ends */
								 MSC_UTIL.SYS_NO, --p_po_sn_flag
								 MSC_UTIL.SYS_NO, --p_oh_sn_flag
								 MSC_UTIL.SYS_NO, --p_so_sn_flag
                                 /* CP-AUTO */
                                 MSC_UTIL.SYS_NO  --p_suprep_sn_flag
								 );

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Launched Collaboration ODS Load. Request Id = '||lv_sce_pub_req_id);
        END IF;
    EXCEPTION WHEN OTHERS THEN
           ERRBUF:=SQLERRM||' Request: '||lv_sce_pub_req_id||'  Error in Call To program MSCXPUBO ';
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
    END;

    COMMIT;
       -----Code changes for APCC refresh-----------
      BEGIN


        IF (pAPCC_refresh = MSC_UTIL.SYS_YES) THEN
            IF (v_is_partial_refresh) THEN
             		   l_req_id := fnd_request.submit_request(
                                        'MSC',
                                        'MSCHUBO',
                                        NULL,
                                        NULL,
                                        FALSE,
                                        pINSTANCE_ID,
                                        2,
                                        NULL);

            ELSIF (v_is_complete_refresh) THEN
              		   l_req_id := fnd_request.submit_request(
                                        'MSC',
                                        'MSCHUBO',
                                        NULL,
                                        NULL,
                                        FALSE,
                                        pINSTANCE_ID,
                                        1,
                                        NULL);
             END IF;

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Launched APCC refresh data collections CP. Request Id = '||l_req_id);
        END IF;
    EXCEPTION WHEN OTHERS THEN
           ERRBUF:=SQLERRM||' Request: '||l_req_id||'  Error in Call To program MSCHUBO ';
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
    END;

    COMMIT;
    -----end of changes for APCC refresh----------

 /* SCE Change Ends */

     -- DELETE SESSION INFO FROM MSC_COLL_PARAMETERS
     -- by calling the procedure FINAL

   FINAL;

   IF RETCODE= MSC_UTIL.G_ERROR THEN

            --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

         RETURN;
   END IF;

     IF v_warning_flag=MSC_UTIL.SYS_YES THEN
        RETCODE:= MSC_UTIL.G_WARNING;
     ELSE
        RETCODE := MSC_UTIL.G_SUCCESS ;
     END IF;

   COMMIT;

   EXCEPTION

      WHEN EX_PIPE_RCV THEN

         ROLLBACK;

         IF lv_check_point= 2 THEN
            IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
               NULL;
            END IF;
         END IF;

         RETCODE := MSC_UTIL.G_ERROR;
         --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

         COMMIT;

      WHEN EX_PIPE_SND THEN

         ROLLBACK;

         IF lv_check_point= 2 THEN
            IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
               NULL;
            END IF;
         END IF;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_MSG_SEND_FAIL');
         FND_MESSAGE.SET_TOKEN('PIPE', v_pipe_wm);
         ERRBUF:= FND_MESSAGE.GET;

         RETCODE := MSC_UTIL.G_ERROR;
         --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

         COMMIT;

      WHEN EX_PROCESS_TIME_OUT THEN

         ROLLBACK;

         IF lv_check_point= 2 THEN
            IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
               NULL;
            END IF;
         END IF;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_TIMEOUT');
         ERRBUF:= FND_MESSAGE.GET;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

         RETCODE := MSC_UTIL.G_ERROR;

         --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

         COMMIT;

      WHEN others THEN

         ROLLBACK;

         IF lv_check_point= 2 THEN
            IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
               NULL;
            END IF;
         END IF;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,   SQLERRM);

         ERRBUF  := SQLERRM;
         RETCODE := MSC_UTIL.G_ERROR;

         --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

         COMMIT;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error_Stack...' );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, DBMS_UTILITY.FORMAT_ERROR_STACK );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error_Backtrace...' );
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

   END LAUNCH_MONITOR;

   PROCEDURE DELETE_PROCESS(
                      ERRBUF				OUT NOCOPY VARCHAR2,
	              RETCODE				OUT NOCOPY NUMBER,
                      pINSTANCE_ID                      IN  NUMBER)
   IS
   BEGIN

	  INITIALIZE_LOAD_GLOBALS( pINSTANCE_ID);

         DBMS_PIPE.PACK_MESSAGE( UNRESOVLABLE_ERROR);

         IF DBMS_PIPE.SEND_MESSAGE( v_pipe_wm)<>0 THEN
            FND_MESSAGE.SET_NAME('MSC', 'MSC_MSG_SEND_FAIL');
            FND_MESSAGE.SET_TOKEN('PIPE', v_pipe_wm);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,   'DELETER:FAIL TO SEND MESSAGE!');
            -- should raise EXCEPTION
         END IF;

         RETCODE := MSC_UTIL.G_SUCCESS ;

   END DELETE_PROCESS;



   FUNCTION Q_PARTIAL_TASK (p_instance_id NUMBER,
                            p_task_num    NUMBER)
   RETURN BOOLEAN AS

   prec   MSC_CL_EXCHANGE_PARTTBL.CollParamREC;
   PTASK_DEMAND          NUMBER;

   BEGIN

    MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (p_instance_id);

    IF (v_coll_prec.app_supp_cap_flag = MSC_UTIL.SYS_YES or v_coll_prec.app_supp_cap_flag = MSC_UTIL.ASL_YES_RETAIN_CP) THEN
       IF (p_task_num = PTASK_SUPPLIER_CAPACITY ) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.atp_rules_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_ATP_RULES) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.bom_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_BOM_COMPONENTS)       or
           (p_task_num = PTASK_BOM)                  or
           (p_task_num = PTASK_COMPONENT_SUBSTITUTE) or
           (p_task_num = PTASK_ROUTING)              or
           (p_task_num = PTASK_ROUTING_OPERATIONS)   or
           (p_task_num = PTASK_OPERATION_RESOURCES)  or
           (p_task_num = PTASK_RESOURCE)             or
           (p_task_num = PTASK_OP_RESOURCE_SEQ)      or
           (p_task_num = PTASK_PROCESS_EFFECTIVITY)  or
           (p_task_num = PTASK_OPERATION_COMPONENTS) or
           (p_task_num = PTASK_RESOURCE_SETUP) or  /* ds change start */
           (p_task_num = PTASK_SETUP_TRANSITION) or
           (p_task_num = PTASK_STD_OP_RESOURCES) or   /* ds change end */
           (p_task_num = PTASK_OPERATION_NETWORKS))  THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.bor_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_BOR) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.calendar_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_CALENDAR_DATE) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.demand_class_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_DEMAND_CLASS) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_FORECAST_DEMAND) or
--           (p_task_num = PTASK_FORECASTS) or /*This will be done in launch_mon_partial*/
           (p_task_num = PTASK_ODS_DEMAND))    THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.item_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_ITEM) or
           (p_task_num = PTASK_CATEGORY_ITEM) or
           (p_task_num = PTASK_ABC_CLASSES)) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.kpi_bis_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_BIS_PFMC_MEASURES)  OR
           (p_task_num = PTASK_BIS_TARGET_LEVELS)  OR
           (p_task_num = PTASK_BIS_TARGETS      )  OR
           (p_task_num = PTASK_BIS_BUSINESS_PLANS) OR
           (p_task_num = PTASK_BIS_PERIODS      ) ) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.mds_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_MDS_DEMAND) or
            ---- (p_task_num = PTASK_DESIGNATOR) or
            ---- Currently LOAD_DESIGNATOR called in the LAUNCH_MONITOR itself.
           (p_task_num = PTASK_ODS_DEMAND)) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.mps_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_SUPPLY)
           --- OR (p_task_num = PTASK_DESIGNATOR)
           --- Currently LOAD_DESIGNATOR called in the LAUNCH_MONITOR itself.
                                                    ) THEN

          RETURN TRUE;
       END IF;
    END IF;

    IF ((v_coll_prec.po_flag = MSC_UTIL.SYS_YES) OR
        (v_coll_prec.oh_flag = MSC_UTIL.SYS_YES)) THEN
       IF (p_task_num = PTASK_SUPPLY) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.parameter_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_PARAMETER) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.planner_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_PLANNERS) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.project_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_PROJECT) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.reserves_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_HARD_RESERVATION) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.resource_nra_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_NET_RESOURCE_AVAIL) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.saf_stock_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_SAFETY_STOCK) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.sales_order_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_SALES_ORDER) THEN
          RETURN TRUE;
       END IF;
    END IF;

    /* NCPerf: always collect SO's in incremental collections */
    IF (p_task_num = PTASK_SALES_ORDER) and (v_is_incremental_refresh)  THEN
       RETURN TRUE;
    END IF;


    IF v_coll_prec.sourcing_rule_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_SOURCING) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.sub_inventory_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_SUB_INVENTORY) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF ((v_coll_prec.tp_vendor_flag = MSC_UTIL.SYS_YES) OR
        (v_coll_prec.tp_customer_flag = MSC_UTIL.SYS_YES)) THEN
       IF (p_task_num = PTASK_TRADING_PARTNER)  THEN
          RETURN FALSE;  -- This will be done in Launch_mon_partial
       END IF;
    END IF;

    IF v_coll_prec.unit_number_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_UNIT_NUMBER) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.uom_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_UOM) THEN
          RETURN FALSE;  -- This will be done in Launch_mon_partial
       END IF;
    END IF;

    -- added this task for collecting Prod Subst in targeted collections --
    IF v_coll_prec.item_subst_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_ITEM_SUBSTITUTES) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_SUPPLY)         or
           (p_task_num = PTASK_ODS_DEMAND)) THEN
          RETURN TRUE;
       END IF;
    END IF;

    -- QUESTION: What should be the combination of order_type
    -- and origination_type for SUPPLY and DEMAND respectively
    -- that would be pertinent for  USER SUPPLIES and DEMANDS?
    -- For example, Is supply order_type = 41  a USER_SUPPLY??
    -- or should these be dynamically determined.

    IF v_coll_prec.wip_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_SUPPLY)         or
	   (p_task_num = PTASK_WIP_RES_REQ)  or
	   (p_task_num = PTASK_RES_INST_REQ)  or     /* ds change */
	   (p_task_num = PTASK_WIP_DEMAND  )  or
           (p_task_num = PTASK_ODS_DEMAND)) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF (v_coll_prec.user_company_flag = MSC_UTIL.COMPANY_ONLY
		OR
		v_coll_prec.user_company_flag = MSC_UTIL.USER_AND_COMPANY
		) THEN
       IF (p_task_num = PTASK_COMPANY_USERS) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_SUPPLY) THEN
          RETURN TRUE;
       END IF;
    END IF;
    IF (p_task_num = PTASK_ITEM_CUSTOMERS AND v_is_legacy_refresh ) THEN
          RETURN TRUE;
    END IF;

     IF v_coll_prec.trip_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_TRIP) THEN
          RETURN TRUE;
       END IF;
    END IF;

     IF v_coll_prec.sales_channel_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_SALES_CHANNEL) THEN
          RETURN TRUE;
       END IF;
    END IF;
     IF v_coll_prec.fiscal_calendar_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_FISCAL_CALENDAR) THEN
          RETURN TRUE;
       END IF;
    END IF;
    IF v_coll_prec.payback_demand_supply_flag = SYS_YES THEN    --bug 5861050
       IF (p_task_num = PTASK_PAYBACK_DEMAND_SUPPLY) 	OR
			 		(p_task_num = PTASK_ODS_DEMAND) OR
          (p_task_num = PTASK_SUPPLY)  THEN
          RETURN TRUE;
       END IF;
    END IF;

     IF v_coll_prec.currency_conversion_flag = MSC_UTIL.SYS_YES THEN  ---- for bug # 6469722
       IF (p_task_num = PTASK_CURRENCY_CONVERSION) THEN
          RETURN TRUE;
       END IF;
    END IF;

     IF v_coll_prec.delivery_details_flag = MSC_UTIL.SYS_YES THEN  ---- for bug # 6730983
       IF (p_task_num = PTASK_DELIVERY_DETAILS) THEN
          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.internal_repair_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_SUPPLY)         or
             (p_task_num = PTASK_IRO_DEMAND  )  or
           (p_task_num = PTASK_ODS_DEMAND)) THEN  --Changed For Bug 5909379 SRP Additions

          RETURN TRUE;
       END IF;
    END IF;

    IF v_coll_prec.external_repair_flag = MSC_UTIL.SYS_YES THEN
       IF ((p_task_num = PTASK_SUPPLY)         or
             (p_task_num = PTASK_ERO_DEMAND  )  or
           (p_task_num = PTASK_ODS_DEMAND)) THEN  --Changed For Bug 5909379 SRP Additions

          RETURN TRUE;
       END IF;
    END IF;
---- CMRO

     IF v_coll_prec.CMRO_flag = MSC_UTIL.SYS_YES THEN
       IF (p_task_num = PTASK_CMRO) THEN
          RETURN TRUE;
       END IF;
    END IF;
    -- Note that there is no PTASK_STAGING_DEMAND that is
    -- used but there is PTASK_STAGING_SUPPLY task being used.
    -- since there are already several procs that load from
    -- staging to ODS demand table.
    -- PTASK_SUPPLY encompases both PTASK_STAGING_SUPPLY
    -- and PTASK_ODS_SUPPLY.

    RETURN FALSE;

   END Q_PARTIAL_TASK;


/* procedure LOAD_ODS_DEMAND has been moved to package  MSC_CL_DEMAND_ODS_LOAD
 through bug5952569 */



   PROCEDURE LAUNCH_MON_PARTIAL(
                      ERRBUF                            OUT NOCOPY VARCHAR2,
                      RETCODE                           OUT NOCOPY NUMBER,
                      pINSTANCE_ID                      IN  NUMBER,
                      pTIMEOUT                          IN  NUMBER,-- minutes
                      pTotalWorkerNum                   IN  NUMBER,
                      pRECALC_NRA                       IN  NUMBER,
		                  pRECALC_SH		                    IN  NUMBER,
                      pPURGE_SH                         IN  NUMBER, --to delete Sourcing History
                      pAPCC_refresh                     IN  NUMBER DEFAULT MSC_UTIL.SYS_NO)      IS

   lc_i                PLS_INTEGER;
   lv_task_number          NUMBER;
   lv_task_not_completed   NUMBER := 0;

   lv_process_time      NUMBER;
   lv_bon_start_end_partial  NUMBER;

   EX_PIPE_RCV        EXCEPTION;
   EX_PIPE_SND        EXCEPTION;
   EX_PROCESS_TIME_OUT EXCEPTION;

   lv_pipe_ret_code         NUMBER;

   lv_check_point          NUMBER := 0;

   lvs_request_id       NumTblTyp := NumTblTyp(0);

   lv_worker_committed NUMBER;

   lv_delete_flag		NUMBER;

   lv_start_time   DATE;

   lv_collection_plan_exists  NUMBER;

   lv_sql_stmt          VARCHAR2(5000);

   lv_dblink            VARCHAR2(128);

   lv_RECALC_NRA        NUMBER;
   lv_refresh_so number;
   lv_refresh_sd number;
   /* ATP SUMMARY CHANGES */
   lv_atp_package_exists number;
   lv_inv_ctp number;
   lv_MSC_ENABLE_ATP_SUMMARY number;
   lv_atp_request_id  number;

   lv_debug_retcode number;

   lv_ret_res_ava number;

   lv_apps_schema varchar2(32);
   lv_read_only_flag varchar2(32);


    CURSOR  c_query_package is
       SELECT 1
       FROM ALL_SOURCE
       WHERE NAME = 'MSC_POST_PRO'
       AND TYPE = 'PACKAGE BODY'
       AND OWNER = lv_apps_schema
       AND ROWNUM<2;

   /* ATP SUMMARY CHANGES END*/

/* SCE changes starts */
   lv_sce_pub_req_id	NUMBER;
   lv_process_comp_err  NUMBER;
/* SCE changes ends */
   l_req_id NUMBER;

   BEGIN

	     p_TIMEOUT := pTIMEOUT;
   lv_read_only_flag:='U';
   BEGIN
   select oracle_username
   into lv_apps_schema
   from fnd_oracle_userid where
   read_only_flag = lv_read_only_flag;
   EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
   END;


   /* Carry out things such as creating temp tables
   // Creating Unique Indexes etc.
   // Use the same methods that are used in Launch_Monitor.
   */

   /* NOTE that all temporory tables are created.
   // Only those tables that have partial replacement data
   // loaded will be exchanged.
   */

   v_prec_defined := FALSE;

   -- ============== Create Temproray Tables ====================
     v_exchange_mode:= MSC_UTIL.SYS_NO;
     v_so_exchange_mode:= MSC_UTIL.SYS_NO;

-- agmcont:
   -- move this from below
   MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID, v_coll_prec);

   if (v_is_cont_refresh) then
    -- set so refresh flags
      if (v_coll_prec.so_sn_flag = MSC_UTIL.SYS_INCR) then
         v_is_so_complete_refresh := FALSE;
         v_is_so_incremental_refresh := TRUE;
      elsif (v_coll_prec.so_sn_flag = MSC_UTIL.SYS_TGT) then
         v_is_so_complete_refresh := TRUE;
         v_is_so_incremental_refresh := FALSE;
      else
         v_is_so_complete_refresh := FALSE;
         v_is_so_incremental_refresh := FALSE;
      end if;
   end if;

     --==================================================================
     -- NCP: Temporary tables need to be created for Partial refresh only.
     -- In case of Net change, temporary tables will not be created.
     --==================================================================

     if v_is_incremental_refresh then null;
     else

-- agmcont
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' CREATE PARTITIONS ');
     IF (v_is_partial_refresh or v_is_cont_refresh) AND
        is_msctbl_partitioned('MSC_SYSTEM_ITEMS') AND
        MSC_CL_EXCHANGE_PARTTBL.Initialize( v_instance_id,
                                            v_instance_code,
                                            v_is_so_complete_refresh) THEN
        IF MSC_CL_EXCHANGE_PARTTBL.Create_Temp_Tbl THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' CREATE TEMP TABLES DONE ');
           v_exchange_mode:= MSC_UTIL.SYS_YES;

           IF v_is_so_complete_refresh THEN
              v_so_exchange_mode:= MSC_UTIL.SYS_YES;
           END IF;

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Exchange Mode = '||v_exchange_mode);

        ELSE
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ERRBUF);
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, SQLERRM);
	   IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
		COMMIT;
	   END IF;

           RETCODE := MSC_UTIL.G_ERROR;

           RETURN;
        END IF; -- end Create_Temp_Tbl

   ELSE
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ERRBUF);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, SQLERRM);
      IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
	 COMMIT;
      END IF;

      RETCODE := MSC_UTIL.G_ERROR;

      RETURN;
   END IF; -- end partial refresh ,  is_msctbl_partitioned and initialize
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' CREATE PARTITIONS DONE ');

   end if;

-- agmcont:
   -- move this above
   -- GET_COLL_PARAM (pINSTANCE_ID, v_coll_prec);

-- agmcont

   /* SCE CHANGE starts*/
    -- =============================================
    -- Change the company name in msc_companies and
    -- msc_trading_partners if it is cheanged in
    -- MSC : Operator Company Name profile option.
    -- =============================================

    IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
        OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN

        MSC_CL_SCE_COLLECTION.PROCESS_COMPANY_CHANGE(lv_process_comp_err);

        if (lv_process_comp_err = MSC_UTIL.G_ERROR) THEN
            ROLLBACK;
	    IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
		 COMMIT;
	    END IF;

            RETCODE := MSC_UTIL.G_ERROR;
            RETURN;
        end if;
    END IF;

  -- ========== Get My Company Name ============
    --IF (G_MSC_CONFIGURATION = G_CONF_APS_SCE OR G_MSC_CONFIGURATION = G_CONF_SCE) THEN
        v_my_company_name := MSC_CL_SCE_COLLECTION.GET_MY_COMPANY;

        IF (v_my_company_name = null) then
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Error while fetching Company Name');
            ROLLBACK;
	    IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
		 COMMIT;
	    END IF;
            RETCODE := MSC_UTIL.G_ERROR;
            RETURN;
        END IF;
    --END IF;
/* SCE CHANGE ends*/

  -- =========== Data Cleansing =================

/* SCE Debug */
        FND_MESSAGE.SET_NAME('MSC', 'MSC_X_SHOW_CONFIG');
        FND_MESSAGE.SET_TOKEN('NAME', MSC_UTIL.G_MSC_CONFIGURATION);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

        FND_MESSAGE.SET_NAME('MSC', 'MSC_X_SHOW_COMPANY');
        FND_MESSAGE.SET_TOKEN('NAME', v_my_company_name);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

/*   Following step does the data cleanup in staging tables and creates
     global Ids for Trading Partner and Items.

     If MSC:Configuration = 'APS' then
         - Execute MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA (Hook for Customization)
         - TRANSFORM KEYS

     If MSC:Configuration = 'APS+SCE' or 'SCE' then
         - Execute MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA (Hook for Customization)
         - MSC_CL_SCE_COLLECTION.CLEANSE_DATA_FOR_SCE (Data cleanup for Multi Company)
         - MSC_CL_SCE_COLLECTION.SCE_TRANSFORM_KEYS (New Companies and Sites in Collaboration area)
         - TRANSFORM KEYS (Global Ids for Trading Partners in Planning Area)
*/

        /* added code to call cleanse Data when Targeted Collections is running */

      IF MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA THEN

            COMMIT;

      ELSE
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_TRANSFORM_KEY_ERR');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
        ROLLBACK;

        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DC_FAIL');
        ERRBUF:= FND_MESSAGE.GET;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

        IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
           COMMIT;
        END IF;

        RETCODE := MSC_UTIL.G_ERROR;

        RETURN;

      END IF;

     -- Data Cleansing and Transform_KEYS is called in Launch_Mon_Partial
     -- only when ITEM or TRADING PARTNER information is Loaded.
     IF ((v_coll_prec.item_flag = MSC_UTIL.SYS_YES)   OR
         (v_coll_prec.tp_vendor_flag = MSC_UTIL.SYS_YES) OR
         (v_coll_prec.tp_customer_flag = MSC_UTIL.SYS_YES) OR
	 (v_coll_prec.sourcing_rule_flag = MSC_UTIL.SYS_YES AND v_is_incremental_refresh=FALSE) ) THEN

     IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN
         IF  /* SCE CHANGE starts */
             /* Data cleanup based on MSC:Configuration profile option */
                MSC_CL_SCE_COLLECTION.CLEANSE_DATA_FOR_SCE(v_instance_id,
            						   v_my_company_name)
                AND MSC_CL_SCE_COLLECTION.SCE_TRANSFORM_KEYS(v_instance_id,
            						 v_current_user,
            						 v_current_date,
            						 v_last_collection_id,
            						 v_is_incremental_refresh,
            						 v_is_complete_refresh,
    			       				 v_is_partial_refresh,
                                     v_is_cont_refresh,
    			       				 v_coll_prec.tp_vendor_flag,
    			       				 v_coll_prec.tp_customer_flag)

             /* SCE CHANGE ends */

             AND MSC_CL_SETUP_ODS_LOAD.TRANSFORM_KEYS THEN

                COMMIT;

         ELSE

            ROLLBACK;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DC_FAIL');
            ERRBUF:= FND_MESSAGE.GET;

            IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
               COMMIT;
            END IF;

            RETCODE := MSC_UTIL.G_ERROR;

            RETURN;

         END IF;


     ELSIF MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS THEN

        IF MSC_CL_SETUP_ODS_LOAD.TRANSFORM_KEYS THEN
        -- IF MSC_CL_SETUP_ODS_LOAD.CLEANSE_DATA AND MSC_CL_SETUP_ODS_LOAD.TRANSFORM_KEYS THEN
        -- Do we do the CLEANSE of DATA or not for Partial replacement.

               COMMIT;

        ELSE

           ROLLBACK;

           FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DC_FAIL');
           ERRBUF:= FND_MESSAGE.GET;

           IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
              COMMIT;
           END IF;

           RETCODE := MSC_UTIL.G_ERROR;

           RETURN;

        END IF;
      END IF;

     END IF;

  -- ============ Load Orgnization, Designator, UOM - same as in launch_monitor==============
  /* load trading_partner first to provide organization_code information */
    IF ((v_coll_prec.tp_vendor_flag = MSC_UTIL.SYS_YES) OR
        (v_coll_prec.tp_customer_flag = MSC_UTIL.SYS_YES)) THEN

--agmcont
        if (v_is_cont_refresh) then
              -- do net-change for this entity
              v_is_incremental_refresh := TRUE;
              v_is_partial_refresh     := FALSE;
        end if;

     if (v_is_partial_refresh) then
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'update so_tbl status to no');
     UPDATE MSC_APPS_INSTANCES mai
     SET
       	so_tbl_status= MSC_UTIL.SYS_NO,
       	LAST_UPDATE_DATE= v_current_date,
        LAST_UPDATED_BY= v_current_user,
        REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
     WHERE mai.INSTANCE_ID= v_instance_id;
     commit;
     end if;

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_TRADING_PARTNER');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_SETUP_ODS_LOAD.LOAD_TRADING_PARTNER;

     /* SCE Change starts */
 /* By this time Trading Partners , Organizations are loaded into planning area as well as collaboration area.  Now we can populate the
 msc_trading_partner_maps table.
 Perform this step if the profile option is 'APS + SCE' OR 'SCE'.
 */
    IF MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR
    MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE THEN
         FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
		 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SCE_COLLECTION.POPULATE_TP_MAP_TABLE');
																						MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
																						MSC_CL_SCE_COLLECTION.POPULATE_TP_MAP_TABLE(v_instance_id);
																						END IF;
    -- END IF;

    /* SCE Change ends */

    if (v_is_partial_refresh AND v_coll_prec.sourcing_rule_flag = MSC_UTIL.SYS_NO AND v_coll_prec.atp_rules_flag = MSC_UTIL.SYS_NO) then
     UPDATE MSC_APPS_INSTANCES mai
           	SET
           	so_tbl_status= MSC_UTIL.SYS_YES,
           	LAST_UPDATE_DATE= v_current_date,
                LAST_UPDATED_BY= v_current_user,
                REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
         	WHERE mai.INSTANCE_ID= v_instance_id;
       commit;
    end if;
    END IF;

     COMMIT;

      /* Load parameters in the Main ODS Load so that this information is available to the function
     CALC_RESOURCE_AVAILABILITY called within LOAD_CALENDAR_DATE */

    IF v_coll_prec.parameter_flag = MSC_UTIL.SYS_YES THEN

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_PARAMETER');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_SETUP_ODS_LOAD.LOAD_PARAMETER;
    END IF;

     COMMIT;

   /* load schedule to provide schedule designator information */
   /* NOTE However that Partial Refresh loads schedule info into
   // staging tables only for MDS and MPS cases. Alternatively
   // this can be called as a separate task through
   // EXECUTE_PARTIAL_TASK which is currently disabled.
   */
  /* load schedule to provide schedule designator information */

   IF (v_coll_prec.mds_flag = MSC_UTIL.SYS_YES) OR (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES) THEN


-- agmcont
        if (v_is_cont_refresh) then
           v_is_incremental_refresh := TRUE;
           v_is_partial_refresh     := FALSE;
        end if;

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_DESIGNATOR');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_DEMAND_ODS_LOAD.LOAD_DESIGNATOR;

     COMMIT;

   END IF;

  /* load Forecast Designator  to provide */
   IF v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES  THEN

-- agmcont
        if (v_is_cont_refresh) then
           v_is_incremental_refresh := TRUE;
           v_is_partial_refresh     := FALSE;
        end if;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LOAD_FORECASTS');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
            MSC_CL_DEMAND_ODS_LOAD.LOAD_FORECASTS;

   END IF;


  /* load unit of measure */
    IF v_coll_prec.uom_flag = MSC_UTIL.SYS_YES THEN

-- agmcont
        if (v_is_cont_refresh) then
           v_is_incremental_refresh := TRUE;
           v_is_partial_refresh     := FALSE;
        end if;

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_UOM');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
     MSC_CL_SETUP_ODS_LOAD.LOAD_UOM;

     COMMIT;

    END IF;

  /* CP-ACK starts */
  -- ============================================================
  -- We will also load Calendar Dates as Set up entity.
  -- We need to do these changes since CP code refers to Calendar
  -- ============================================================
     IF v_coll_prec.calendar_flag = MSC_UTIL.SYS_YES THEN

        if (v_is_cont_refresh) then
           v_is_incremental_refresh := TRUE;
           v_is_partial_refresh     := FALSE;
        end if;

     FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
	 FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_SET_UP');
	 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
	 MSC_CL_SETUP_ODS_LOAD.LOAD_CALENDAR_SET_UP;

	 END IF;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'LAUNCH_MON_PARTIAL: Deleting MSC_NET_RESOURCE_AVAIL...');

     IF (v_instance_type <> MSC_UTIL.G_INS_OTHER) AND (v_is_complete_refresh OR
            (v_is_partial_refresh AND v_coll_prec.resource_nra_flag = MSC_UTIL.SYS_YES)) THEN

		  IF v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug-05');
		    DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1);
		    DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1);
		  ELSE
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'debug-06');
		    v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
		    DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1,v_sub_str);
		    DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1,v_sub_str);
		  END IF;

     END IF;


IF NOT (v_is_cont_refresh) then
   -- ============ Launch the Workers here ==============

   lvs_request_id.EXTEND( pTotalWorkerNum);

   IF v_cp_enabled= MSC_UTIL.SYS_YES THEN

     FOR lc_i IN 1..pTotalWorkerNum LOOP
       lvs_request_id(lc_i) := FND_REQUEST.SUBMIT_REQUEST(
                          'MSC',
                          'MSCPDCW',
                          NULL,  -- description
                          NULL,  -- start date
                          FALSE, -- TRUE,
                          FND_GLOBAL.CONC_REQUEST_ID,
                          pINSTANCE_ID,
                          v_last_collection_id,
                          pTIMEOUT,
                          pRECALC_NRA,
                          pRECALC_SH,
                          v_exchange_mode,
                          v_so_exchange_mode);

       COMMIT;

       IF lvs_request_id(lc_i)= 0 THEN

          ROLLBACK;

          IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
             COMMIT;
          END IF;

          FOR lc_i IN 1..pTotalWorkerNum LOOP

              DBMS_PIPE.PACK_MESSAGE( -1);

              IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
                 RAISE EX_PIPE_SND;
              END IF;

            FND_MESSAGE.SET_NAME('MSC','MSC_CL_SEND_WOR_END');
            FND_MESSAGE.SET_TOKEN('LCI',lc_i);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

          END LOOP;

          FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_LAUNCH_WORKER_FAIL');
          ERRBUF:= FND_MESSAGE.GET;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);

          RETCODE := MSC_UTIL.G_ERROR;

          -- DELETE SESSION INFO FROM MSC_COLL_PARAMETERS
          -- by calling the procedure FINAL

          FINAL;

          COMMIT;

          RETURN;
       ELSE
         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_WORKER_REQUEST_ID');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID', lvs_request_id(lc_i));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
       END IF;

     END LOOP;

   ELSE
          COMMIT;

   END IF;  -- v_cp_enabled
ELSE

    NULL;
     /* for cont. collections the ODS load workers
	are launched from the MSCCLFAB.pls */

END IF;
   msc_util.print_trace_file_name(FND_GLOBAL.CONC_REQUEST_ID);

   -- ============ Send Tasks to Task Que 'v_pipe_task_que' =============
   --   load sales orders will be called from load_supply - link demand-supply

  --bug3954345. Setting so_tbl_status to 2 so that ATP inquiry dosent go through
  --unless all the related ATP tables are populated

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'update so_tbl status to no');
     if (v_is_partial_refresh AND ((v_coll_prec.sourcing_rule_flag = MSC_UTIL.SYS_YES OR v_coll_prec.atp_rules_flag = MSC_UTIL.SYS_YES)
         AND (v_coll_prec.tp_vendor_flag = MSC_UTIL.SYS_NO AND v_coll_prec.tp_customer_flag = MSC_UTIL.SYS_NO))) then
     UPDATE MSC_APPS_INSTANCES mai
     SET
       	so_tbl_status= MSC_UTIL.SYS_NO,
       	LAST_UPDATE_DATE= v_current_date,
        LAST_UPDATED_BY= v_current_user,
        REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
     WHERE mai.INSTANCE_ID= v_instance_id;
     commit;
    end if;

   FOR lc_i IN 1..TOTAL_PARTIAL_TASKS LOOP
         -- Determine whether the task has to be executed or not.

       IF Q_PARTIAL_TASK (pINSTANCE_ID, lc_i) THEN

      IF (MSC_UTIL.G_MSC_DEBUG <> 'N' ) THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'PIPE to the ODS LOAD - Task Number ' || TO_CHAR(lc_i));
      END IF;
          DBMS_PIPE.PACK_MESSAGE( lc_i);
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Sending task number: '||lc_i||' to the queue');

          IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN

               FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERROR_SEND_TSK');
               FND_MESSAGE.SET_TOKEN('LCI',lc_i);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

             RAISE EX_PIPE_SND;
          END IF;

          lv_task_not_completed := lv_task_not_completed + 1;
       END IF;
   END LOOP;

   DBMS_LOCK.SLEEP( 5);   -- initial estimated sleep time

   --lv_task_not_completed := TOTAL_PARTIAL_TASKS;

   -- Now monitor the performance of the tasks.
   lv_bon_start_end_partial :=0;

   LOOP

      var_debug := 1;
      EXIT WHEN lv_task_not_completed = 0;

      var_debug := 2;
      EXIT WHEN is_request_status_running <> MSC_UTIL.SYS_YES;

      var_debug := 3;
      EXIT WHEN is_worker_status_valid(lvs_request_id) <> MSC_UTIL.SYS_YES;

      lv_pipe_ret_code:= DBMS_PIPE.RECEIVE_MESSAGE( v_pipe_wm, PIPE_TIME_OUT);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Pipe Return code: '||lv_pipe_ret_code);

      IF lv_pipe_ret_code=0 THEN

         DBMS_PIPE.UNPACK_MESSAGE( lv_task_number);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Unpacked Task Number : '||lv_task_number);

         if lv_task_number = PTASK_ATP_RULES THEN
            	G_TASK_ATP_RULES :=1;
            elsif lv_task_number = PTASK_SOURCING THEN
            	G_TASK_SOURCING :=1;
            elsif lv_task_number = PTASK_ROUTING THEN
               lv_bon_start_end_partial := lv_bon_start_end_partial + 1;
            elsif lv_task_number = PTASK_OPERATION_NETWORKS THEN
               lv_bon_start_end_partial := lv_bon_start_end_partial + 1;
            elsif lv_task_number = PTASK_ROUTING_OPERATIONS THEN
               lv_bon_start_end_partial := lv_bon_start_end_partial + 1;
         end if;

         if v_is_partial_refresh AND (v_coll_prec.sourcing_rule_flag = MSC_UTIL.SYS_YES AND v_coll_prec.atp_rules_flag = MSC_UTIL.SYS_YES) then
              if  G_TASK_ATP_RULES =1 and G_TASK_SOURCING =1 then
                UPDATE MSC_APPS_INSTANCES mai
           	SET
           	so_tbl_status= MSC_UTIL.SYS_YES,
           	LAST_UPDATE_DATE= v_current_date,
                LAST_UPDATED_BY= v_current_user,
                REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
         	WHERE mai.INSTANCE_ID= v_instance_id;
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'update so tbl status');
              commit;
            G_TASK_ATP_RULES:=0;
            G_TASK_SOURCING :=0;
            end if;
         elsif  v_is_partial_refresh AND (v_coll_prec.sourcing_rule_flag = MSC_UTIL.SYS_YES AND v_coll_prec.atp_rules_flag = MSC_UTIL.SYS_NO) then
            if  G_TASK_SOURCING =1 then
                UPDATE MSC_APPS_INSTANCES mai
           	SET
           	so_tbl_status= MSC_UTIL.SYS_YES,
           	LAST_UPDATE_DATE= v_current_date,
                LAST_UPDATED_BY= v_current_user,
                REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
         	WHERE mai.INSTANCE_ID= v_instance_id;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'update so tbl status');
                commit;
                G_TASK_SOURCING :=0;
            end if;
          elsif  v_is_partial_refresh AND (v_coll_prec.sourcing_rule_flag = MSC_UTIL.SYS_NO AND v_coll_prec.atp_rules_flag = MSC_UTIL.SYS_YES) then
            if  G_TASK_ATP_RULES =1 then
                UPDATE MSC_APPS_INSTANCES mai
           	SET
           	so_tbl_status= MSC_UTIL.SYS_YES,
           	LAST_UPDATE_DATE= v_current_date,
                LAST_UPDATED_BY= v_current_user,
                REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
         	WHERE mai.INSTANCE_ID= v_instance_id;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'update so tbl status');
            commit;
            G_TASK_ATP_RULES :=0;
            end if;
           end if;

         IF lv_task_number>0 THEN   -- If it's ok, the vlaue is the task number

            lv_task_not_completed := lv_task_not_completed -1;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Tasks remaining :'||lv_task_not_completed);

            IF lv_task_not_completed= 0 THEN
               var_debug := 4;
               EXIT;
            END IF;

         ELSE

            var_debug := 5;
            EXIT WHEN lv_task_number= UNRESOVLABLE_ERROR;

            DBMS_PIPE.PACK_MESSAGE( -lv_task_number);
                                   -- resend the task to the task queue

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Re-sending the task number: '||-lv_task_number||' to the queue');

            IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
               RAISE EX_PIPE_SND;
            END IF;

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Task number: '||-lv_task_number||' re-sent to the pipe queue');

         END IF;

      ELSIF lv_pipe_ret_code<> 1 THEN
             FND_MESSAGE.SET_NAME('MSC','MSC_CL_RCV_PIPE_ERR');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

          RAISE EX_PIPE_RCV;   -- If the error is not time-out error
      END IF;

      -- ============= Check the execution time ==============

      select (SYSDATE- START_TIME) into lv_process_time from dual;

      IF lv_process_time > pTIMEOUT/1440.0 THEN Raise EX_PROCESS_TIME_OUT;
      END IF;

   END LOOP;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '----------------------------------------------------');
     FND_MESSAGE.SET_NAME('MSC','MSC_CL_TSK_NOT_COMP');
     FND_MESSAGE.SET_TOKEN('LV_TASK_NOT_COMPLETED',lv_task_not_completed);
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);

     IF (var_debug = 1) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_3');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 2) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_1');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 3) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_2');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 4) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_3');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
     ELSIF (var_debug = 5) THEN
        FND_MESSAGE.SET_NAME('MSC','MSC_CL_ERR_PDC_4');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

     END IF;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '----------------------------------------------------');


   IF lv_task_not_completed > 0 THEN

      DBMS_PIPE.PURGE( v_pipe_task_que);

      lv_task_number:= -1;

      ROLLBACK;

      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_FAIL');
      ERRBUF:= FND_MESSAGE.GET;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  ERRBUF);

      RETCODE := MSC_UTIL.G_ERROR;

   ELSE

      lv_task_number:= 0;

      UPDATE MSC_APPS_INSTANCES mai
         SET LAST_UPDATE_DATE= v_current_date,
             LAST_UPDATED_BY= v_current_user,
             REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
       WHERE mai.INSTANCE_ID= v_instance_id;
       commit;

       IF (v_is_partial_refresh) AND
	                       ( (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES )
                        or (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES )
                        or (v_coll_prec.po_flag = MSC_UTIL.SYS_YES )
                        or (v_coll_prec.oh_flag = MSC_UTIL.SYS_YES )
                        or (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES )
                        or (v_coll_prec.internal_repair_flag = MSC_UTIL.SYS_YES )
                        or (v_coll_prec.external_repair_flag = MSC_UTIL.SYS_YES )
                        or (v_coll_prec.payback_demand_supply_flag = MSC_UTIL.SYS_YES )) then
            IF MSC_CL_SUPPLY_ODS_LOAD.drop_supplies_tmp_ind THEN
	        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Successfully Dropped the temp Index on Supplies table.' );
            ELSE
                ROLLBACK;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'Failed in Dropping the temp Index on Supplies table.' );
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

                RETCODE := MSC_UTIL.G_ERROR;
            END IF;
       END IF;         -- partial_refresh

      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_SUCCEED');
      ERRBUF:= FND_MESSAGE.GET;
      RETCODE := MSC_UTIL.G_SUCCESS ;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,  ERRBUF);

   END IF;

     lv_debug_retcode := RETCODE;

   IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
     COMMIT;
   END IF;

    IF (lv_debug_retcode = MSC_UTIL.G_ERROR) OR (RETCODE = MSC_UTIL.G_ERROR) THEN
       RETCODE := MSC_UTIL.G_ERROR;
    END IF;

   -- Exit the workers

   FOR lc_i IN 1..pTotalWorkerNum LOOP

        FND_MESSAGE.SET_NAME('MSC','MSC_CL_SEND_WOR_END');
        FND_MESSAGE.SET_TOKEN('LCI',lc_i);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

      DBMS_PIPE.PACK_MESSAGE( lv_task_number);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Sending task number: '||lv_task_number||' to the worker '||lc_i);
      IF DBMS_PIPE.SEND_MESSAGE( v_pipe_task_que)<>0 THEN
          RAISE EX_PIPE_SND;
      END IF;

   END LOOP;

   lv_worker_committed:= 0;

   lv_start_time:= SYSDATE;

   -- Monitor the worker exits.
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
      --EXIT WHEN lv_process_time > 10.0/1440.0;   -- wait for 10 minutes

      IF (lv_process_time > 3.0/1440.0) AND (lv_worker_committed <> pTotalWorkerNum) THEN
               EXIT WHEN all_workers_completed(lvs_request_id) = MSC_UTIL.SYS_YES;
      END IF;

   END LOOP;

   IF lv_worker_committed<> pTotalWorkerNum THEN

        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_FAIL_TO_COMMIT');
        ERRBUF:= FND_MESSAGE.GET;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

        FND_MESSAGE.SET_NAME('MSC','MSC_CL_CHECK_PDC_LOG');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);

        RETCODE := MSC_UTIL.G_ERROR;
   ELSE
      IF lv_task_number= 0 THEN

      IF (v_is_partial_refresh AND v_coll_prec.po_flag = MSC_UTIL.SYS_YES AND v_coll_prec.sales_order_flag =MSC_UTIL.SYS_NO) OR
          (v_is_cont_refresh AND (v_coll_prec.po_flag = MSC_UTIL.SYS_YES and v_coll_prec.po_sn_flag = MSC_UTIL.SYS_TGT)
		         AND v_coll_prec.sales_order_flag =MSC_UTIL.SYS_NO) THEN
		  IF  ( v_apps_ver >= MSC_UTIL.G_APPS115 ) THEN
		             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling Linking of Sales Order for 11i source ...');
                     FND_MESSAGE.SET_NAME('MSC', 'MSC_DL_TASK_START_PARTIAL');
                     FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_11I2');
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                     MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_11I2;
		  END IF;
	  END IF;

      IF (v_is_cont_refresh) and (
                  (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES and v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_TGT) or
                  (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) or
                  (v_coll_prec.po_flag = MSC_UTIL.SYS_YES and v_coll_prec.po_sn_flag = MSC_UTIL.SYS_TGT) or
                  (v_coll_prec.oh_flag = MSC_UTIL.SYS_YES and v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_TGT) or
		  (v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES) or
                  (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_TGT)
				  )  then
            IF MSC_CL_SUPPLY_ODS_LOAD.drop_supplies_tmp_ind THEN
	        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Successfully Dropped the temp Index on Supplies table.' );
            ELSE
                ROLLBACK;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'Failed in Dropping the temp Index on Supplies table.' );
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

                RETCODE := MSC_UTIL.G_ERROR;
            END IF;
      END IF;

      IF (v_is_partial_refresh) AND
	  ( (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES )
    or (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES )
    or (v_coll_prec.po_flag = MSC_UTIL.SYS_YES )
    or (v_coll_prec.oh_flag = MSC_UTIL.SYS_YES )
    or (v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES)
    or (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES )
    or (v_coll_prec.internal_repair_flag = MSC_UTIL.SYS_YES )
    or (v_coll_prec.external_repair_flag = MSC_UTIL.SYS_YES )
    or (v_coll_prec.payback_demand_supply_flag = SYS_YES)) then
            IF MSC_CL_SUPPLY_ODS_LOAD.drop_supplies_tmp_ind THEN
	        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Successfully Dropped the temp Index on Supplies table.' );
            ELSE
                ROLLBACK;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'Failed in Dropping the temp Index on Supplies table.' );
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

                RETCODE := MSC_UTIL.G_ERROR;
            END IF;
       END IF;         -- partial_refresh

       /* ds change  start */
       IF v_apps_ver >= MSC_UTIL.G_APPS115 THEN
                 IF  MSC_CL_SETUP_ODS_LOAD.LINK_SUPPLY_TOP_LINK_ID THEN
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'update of msc_supplies top_transaction_id for eam is successful.....');
                  ELSE
                      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Error in update of msc_supplies top_transaction_id......');
                      RETCODE := MSC_UTIL.G_WARNING;
                  END IF;
       END IF;
       /* ds change  end */

       IF (v_apps_ver >= MSC_UTIL.G_APPS115) AND (v_coll_prec.mds_flag = MSC_UTIL.SYS_YES) THEN
                /* call the function to link the Demand_id and Parent_id in MSC_DEMANDS for 11i Source instance  */

          IF (v_is_partial_refresh)  OR              --- incremental/partial collections
		(v_is_cont_refresh AND v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_TGT) THEN -- in auto collcns if mds is targeted

	      v_exchange_mode := MSC_UTIL.SYS_YES;

              IF  MSC_CL_DEMAND_ODS_LOAD.LINK_PARENT_SALES_ORDERS_MDS THEN
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Linking of Sales Order line in MDS to its Parent Sales orders is successful.....');
              ELSE
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Error in Linking Sales order line in MDS to its parent Sales order......');
                  RETCODE := MSC_UTIL.G_WARNING;
              END IF;

              IF MSC_CL_DEMAND_ODS_LOAD.drop_demands_tmp_ind THEN
	        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Successfully Dropped the temp Index on Demands table.' );
              ELSE
                ROLLBACK;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'Failed in Dropping the temp Index on Demands table.' );
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

                RETCODE := MSC_UTIL.G_ERROR;
              END IF;       ---- call to MSC_CL_DEMAND_ODS_LOAD.drop_demands_tmp_ind

	  END IF;
        END IF;

      IF (v_coll_prec.sales_order_flag = MSC_UTIL.SYS_YES) THEN
         IF (v_is_partial_refresh) OR (v_is_cont_refresh and v_coll_prec.so_sn_flag = MSC_UTIL.SYS_TGT)  then
            IF MSC_CL_DEMAND_ODS_LOAD.drop_sales_orders_tmp_ind THEN
	        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Successfully Dropped the temp Index on Sales Orders table.' );
            ELSE
                ROLLBACK;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'Failed in Dropping the temp Index on Sales Orders table.' );
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);

                RETCODE := MSC_UTIL.G_ERROR;
            END IF;
	 END IF;
       END IF;         -- partial_refresh

       IF (v_is_cont_refresh) THEN
	  v_exchange_mode := MSC_UTIL.SYS_YES;
       END IF;

         IF v_exchange_mode= MSC_UTIL.SYS_YES THEN

            IF alter_temp_table_by_monitor = FALSE THEN
               RETCODE:= MSC_UTIL.G_ERROR;
            ELSE
               NULL;
               --log_message ('successfully altered phase 2 tables');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,  'successfully altered phase 2 tables.' );
            END IF;

            MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID, v_coll_prec);
            IF NOT MSC_CL_EXCHANGE_PARTTBL.Exchange_Partition
                                                  (v_coll_prec,
                                                   v_is_cont_refresh) THEN
                        /* Only those tables that have partial
                        // replacement data loaded will be exchanged.
                        */
               RETCODE:= MSC_UTIL.G_ERROR;
            END IF;
            IF RETCODE <> MSC_UTIL.G_ERROR THEN
               IF NOT MSC_CL_EXCHANGE_PARTTBL.Drop_Temp_Tbl THEN
                  v_warning_flag:=MSC_UTIL.SYS_YES;
               END IF;
            END IF;
         END IF;

	IF ( v_coll_prec.item_flag = MSC_UTIL.SYS_YES or v_coll_prec.bom_flag = MSC_UTIL.SYS_YES ) THEN
		MSC_CL_ITEM_ODS_LOAD.UPDATE_LEADTIME;
	END IF;

         IF (v_req_ext_po_so_linking) Then
                     IF  ( v_apps_ver >= MSC_UTIL.G_APPS115 ) THEN
                        BEGIN
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, ' Calling Linking of Sales Order for 11i source ...');
                            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
                            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_EXT');
                            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);
                            -- Calling the Linking of external Sales orders for the fix 2353397  --
                            MSC_CL_DEMAND_ODS_LOAD.LINK_SUPP_SO_DEMAND_EXT;
                        END;

                    END IF;
           END IF;
           --9194726
         IF lv_bon_start_end_partial = 3 then
               MSC_CL_ROUTING_ODS_LOAD.GET_START_END_OP_PARTIAL ;
         END IF;

         UPDATE MSC_APPS_INSTANCES
            SET so_tbl_status= MSC_UTIL.SYS_YES
          WHERE instance_id= v_instance_id;
         /* Resource Start Time*/
         -- Set The collections Start Time . Get the start time in the out variable
         SET_COLLECTIONS_START_TIME(v_instance_id, v_resource_start_time);
         COMMIT;

         /*
         // Should Loading sourcing History be done
         // during partial refreshment if the sourcing history is on in pull and ods.
         //
         */

         IF(v_coll_prec.po_receipts_flag = MSC_UTIL.SYS_YES) THEN
                       v_sub_str := 'AND ORGANIZATION_ID' || MSC_UTIL.v_in_org_str;
                DELETE_MSC_TABLE('MSC_PO_RECEIPTS', v_instance_id,NULL,v_sub_str);
                COMMIT;

         	MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Table MSC_PO_RECEIPTS Deleted');

         	MSC_CL_MISCELLANEOUS.load_po_receipts
                   ( v_instance_id,
                     MSC_UTIL.v_in_org_str,
                     v_last_collection_id,
                     v_current_date,
                     v_current_user,
                     NULL);
                 COMMIT;
           END IF;

	 IF pPURGE_SH = MSC_UTIL.SYS_YES THEN

	     	SELECT DECODE(nvl(FND_PROFILE.VALUE('MSC_PURGE_ST_CONTROL'),'N'),'Y',1,2)
                INTO lv_delete_flag
                FROM DUAL;

                IF (lv_delete_flag = 2) THEN
                        DELETE MSC_SOURCING_HISTORY
                        WHERE SR_INSTANCE_ID= v_instance_id;
                ELSE
                        TRUNCATE_MSC_TABLE('MSC_SOURCING_HISTORY');
                END IF;

		COMMIT;

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Table MSC_SOURCING_HISTORY Deleted');
         END IF;

         IF ((pRECALC_SH=MSC_UTIL.SYS_YES) AND (v_coll_prec.source_hist_flag=MSC_UTIL.SYS_YES)) THEN

            MSC_CL_MISCELLANEOUS.load_sourcing_history
               ( v_instance_id,
                 v_last_collection_id,
                 v_current_date,
                 v_current_user,
                 NULL);
         END IF;

         -- SAVEPOINT WORKERS_COMMITTED;

          lv_RECALC_NRA  := pRECALC_NRA;
          IF v_coll_prec.resource_nra_flag = MSC_UTIL.SYS_YES THEN
               lv_RECALC_NRA   := MSC_UTIL.SYS_YES;
          END IF;


	 -- BUG # 3020614
        -- For Partial refresh, if Both the bom_flag and calendar_flag are
        -- not set then call the procedure calc_resource_availability in
        -- serial mode if pRECALC_NRA is set.
        -- Otherwise, the procedure load_calendar_date makes a call to
        -- this procedure.


          IF (v_is_partial_refresh AND
             (v_coll_prec.bom_flag = MSC_UTIL.SYS_NO) AND
             (v_coll_prec.calendar_flag = MSC_UTIL.SYS_NO)) THEN


          IF v_discrete_flag= MSC_UTIL.SYS_YES AND lv_RECALC_NRA = MSC_UTIL.SYS_YES THEN
             /*Resource Start Time*/
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'before CALC_RESOURCE_AVAILABILITY ');
	     lv_ret_res_ava:=MSC_RESOURCE_AVAILABILITY.CALC_RESOURCE_AVAILABILITY(v_resource_start_time,v_coll_prec.org_group_flag,FALSE);


              IF lv_ret_res_ava = 2 THEN
                FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
                ERRBUF:= FND_MESSAGE.GET;
              	v_warning_flag:=MSC_UTIL.SYS_YES;
	      ELSIF lv_ret_res_ava <> 0 THEN
		 FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
                 ERRBUF:= FND_MESSAGE.GET;
                 RETCODE:= MSC_UTIL.G_ERROR;

             -- ROLLBACK WORK TO SAVEPOINT WORKERS_COMMITTED;
             END IF;

          END IF;
	  END IF;

        END IF;  -- lv_task_number= 0

   END IF; -- commit fail?

   COMMIT;

   /*        LAUNCH DATA PURGING PROCESS    */

-- agmcont
   IF (v_cp_enabled= MSC_UTIL.SYS_YES AND RETCODE<>MSC_UTIL.G_ERROR AND
       (v_is_cont_refresh = FALSE)) THEN

          /*   added the  code so that the request - Purge Staging tables will be called via function
             purge_staging for bug:     2452183 , Planning ODS Load was always completing with warnings
              because when the sub-req MSCPDCP completes , it restarts the launch_monitor */

         IF PURGE_STAGING(pINSTANCE_ID) THEN
            COMMIT;
         ELSE
            IF RETCODE <> MSC_UTIL.G_ERROR THEN RETCODE := MSC_UTIL.G_WARNING; END IF;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, SQLERRM);
         END IF;

   END IF;

-- agmcont
-- call purge procedure directly in case of continuous collections

   if (v_is_cont_refresh) AND (RETCODE<>MSC_UTIL.G_ERROR) then

       /* call purge staging tables */

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'launch purge staging tables');

       MSC_CL_COLLECTION.PURGE_STAGING_TABLES(  ERRBUF ,
                                                RETCODE,
                                                pINSTANCE_ID,
						MSC_UTIL.SYS_YES);


       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'done purge staging tables');

   end if;

   COMMIT;


/* ATP SUMMARY CHANGES - LAUNCH CONCURENT PROGRAMS FOR ATP in TARGETED MODE */
  /* CHECK TO SEE IF THE PACKAGE EXISTS */
  BEGIN
           OPEN  c_query_package;
           FETCH c_query_package INTO lv_atp_package_exists;
           CLOSE c_query_package;
           /* CHECK TO SEE IF THE ATP PROFILE INV_CTP is set to 5 */
             SELECT nvl(fnd_profile.value('INV_CTP'),-10)
             INTO lv_inv_ctp
             FROM dual;

           /* CHECK TO SEE IF THE ATP PROFILE INV_CTP is set to 5 */
             SELECT decode(nvl(fnd_profile.value('MSC_ENABLE_ATP_SUMMARY'),'N'),'Y',1,2)
             INTO lv_MSC_ENABLE_ATP_SUMMARY
             FROM dual;
  EXCEPTION
           WHEN OTHERS THEN
             IF c_query_package%ISOPEN THEN CLOSE c_query_package; END IF;
             lv_atp_package_exists := 2;
  END;

   IF (lv_atp_package_exists = 1 AND lv_inv_ctp = 5 and lv_MSC_ENABLE_ATP_SUMMARY = 1 ) THEN
   IF v_is_partial_refresh   THEN
    BEGIN

     IF (v_cp_enabled= MSC_UTIL.SYS_YES ) THEN

       MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID); -- This will initialze the record v_coll_prec
       IF ( (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES)  or
            (v_coll_prec.po_flag  = MSC_UTIL.SYS_YES)  or
            (v_coll_prec.oh_flag  = MSC_UTIL.SYS_YES)  or
            (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES)  or
            (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES)  or
            (v_coll_prec.forecast_flag  = MSC_UTIL.SYS_YES)  or
            (v_coll_prec.mds_flag  = MSC_UTIL.SYS_YES) ) THEN

           lv_refresh_sd := MSC_UTIL.SYS_YES;
       ELSE
           lv_refresh_sd := MSC_UTIL.SYS_NO;

       END IF;

       IF  (v_coll_prec.sales_order_flag = MSC_UTIL.SYS_YES) THEN
           lv_refresh_so := MSC_UTIL.SYS_YES;
       ELSE
           lv_refresh_so := MSC_UTIL.SYS_NO;
       END IF;

        lv_atp_request_id := FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCCLCNC',
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- sub request,
                             pINSTANCE_ID, -- Instance Id
                             3,      -- Refresh type Targeted
                             lv_refresh_so,      -- Refresh SO Incremental
                             lv_refresh_sd);     -- Refresh Supply/Demand
     END IF; -- cp enabled flag

     COMMIT;
     EXCEPTION
         WHEN OTHERS THEN
         ERRBUF:=SQLERRM||' Request: '||lv_atp_request_id||'  Error in Call To program MSCCLCNC ';
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
    END;

  ELSIF v_is_incremental_refresh  THEN -- Incremental refresh No, Sales Orders refresh No

  /* ATP SUMMARY CHANGES CALL THE PROGRAMS MSCCLCNC For Incremental refresh collections */

    BEGIN
     IF v_cp_enabled= MSC_UTIL.SYS_YES THEN
        lv_atp_request_id := FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCCLCNC',
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- sub request,
                             pINSTANCE_ID, -- Instance Id
                             MSC_UTIL.SYS_NO,      -- Refresh type Incremental
                             MSC_UTIL.SYS_NO,      -- Refresh SO Incremental
                             MSC_UTIL.SYS_NO);     -- Refresh Supply/Demand
     END IF; -- cp enabled flag
     COMMIT;
     EXCEPTION
        WHEN OTHERS THEN
           ERRBUF:=SQLERRM||' Request: '||lv_atp_request_id||'  Error in Call To program MSCCLCNC ';
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
    END;

  ELSIF v_is_cont_refresh THEN
    BEGIN
     IF (v_cp_enabled= MSC_UTIL.SYS_YES ) THEN

       MSC_CL_SETUP_ODS_LOAD.GET_COLL_PARAM (pINSTANCE_ID); -- This will initialze the record v_coll_prec
       IF ( (v_coll_prec.mps_flag = MSC_UTIL.SYS_YES and v_coll_prec.mps_sn_flag=MSC_UTIL.SYS_TGT )  or
            (v_coll_prec.po_flag  = MSC_UTIL.SYS_YES and v_coll_prec.po_sn_flag=MSC_UTIL.SYS_TGT)  or
            (v_coll_prec.oh_flag  = MSC_UTIL.SYS_YES and v_coll_prec.oh_sn_flag=MSC_UTIL.SYS_TGT)  or
            (v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and v_coll_prec.wip_sn_flag=MSC_UTIL.SYS_TGT)  or
            (v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and v_coll_prec.udmd_sn_flag=MSC_UTIL.SYS_TGT)  or
            (v_coll_prec.forecast_flag  = MSC_UTIL.SYS_YES and v_coll_prec.fcst_sn_flag=MSC_UTIL.SYS_TGT)  or
            (v_coll_prec.mds_flag  = MSC_UTIL.SYS_YES and v_coll_prec.mds_sn_flag=MSC_UTIL.SYS_TGT) ) THEN

           lv_refresh_sd := MSC_UTIL.SYS_YES;
       ELSE
           lv_refresh_sd := MSC_UTIL.SYS_NO;

       END IF;

       IF  (v_coll_prec.sales_order_flag = MSC_UTIL.SYS_YES and v_coll_prec.so_sn_flag=MSC_UTIL.SYS_TGT ) THEN
           lv_refresh_so := MSC_UTIL.SYS_YES;
       ELSE
           lv_refresh_so := MSC_UTIL.SYS_NO;
       END IF;

        IF (lv_refresh_sd = MSC_UTIL.SYS_YES OR lv_refresh_so = MSC_UTIL.SYS_YES ) THEN

         lv_atp_request_id := FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCCLCNC',
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- sub request,
                             pINSTANCE_ID, -- Instance Id
                             3,                  -- Refresh type Targeted
                             lv_refresh_so,      -- Refresh SO Incremental
                             lv_refresh_sd);     -- Refresh Supply/Demand

         ELSE

          lv_atp_request_id := FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCCLCNC',
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- sub request,
                             pINSTANCE_ID, -- Instance Id
                             2,                  -- Refresh type Incremental
                             lv_refresh_so,      -- Refresh SO Incremental
                             lv_refresh_sd);     -- Refresh Supply/Demand
         END IF;


     END IF; -- cp enabled flag

     COMMIT;
     EXCEPTION
         WHEN OTHERS THEN
         ERRBUF:=SQLERRM||' Request: '||lv_atp_request_id||'  Error in Call To program MSCCLCNC ';
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
    END;
  END IF; -- Partial refresh Condition
 END IF; -- ATP Package exists or not and the profile options are set or not


  /* ATP SUMMARY CHANGES - END - LAUNCH CONCURENT PROGRAMS FOR ATP in TARGETED MODE */


   COMMIT;
 /* SCE Change Starts */
 /* If MSC:Configuration profile is set to SCE or APS+SCE then we need to publish
    ODS data to collaboration area i.e. msc_sup_dem_entries.
    The SCE program will push following order types.
    	- Purchase Order (Order_Type = 1)
    	- PO in receiving (Order Type = 8)
    	- Requisition (Order_Type = 2)
    	- Intransit Shipment (Order_Type) = 11
 */

    BEGIN
        IF MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE OR
           MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE THEN

-- agmcont
           IF (v_cp_enabled= MSC_UTIL.SYS_YES) THEN

            lv_sce_pub_req_id := FND_REQUEST.SUBMIT_REQUEST(
                                 'MSC',
                                 'MSCXPUBO',
                                 NULL,  -- description
                                 NULL,  -- start date
                                 FALSE, -- sub request,
                                 v_instance_id,
                                 v_current_user,
                                 v_coll_prec.po_flag,
                                 v_coll_prec.oh_flag,
                                 v_coll_prec.sales_order_flag,
				                 v_coll_prec.app_supp_cap_flag,
                                 /* CP-ACK starts */
                                 v_coll_prec.supplier_response_flag,
                                 /* CP-ACK ends */
								 v_coll_prec.po_sn_flag,
								 v_coll_prec.oh_sn_flag,
								 v_coll_prec.so_sn_flag,
                                 /* CP-AUTO */
                                 v_coll_prec.suprep_sn_flag
								 );


            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Launched Collaboration ODS Load. Request Id = '||lv_sce_pub_req_id);

           END IF;

        END IF;
    EXCEPTION WHEN OTHERS THEN
           ERRBUF:=SQLERRM||' Request: '||lv_sce_pub_req_id||'  Error in Call To program MSCXPUBO ';
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
    END;

    COMMIT;

 /* SCE Change Ends */

     -- DELETE SESSION INFO FROM MSC_COLL_PARAMETERS
     -- by calling the procedure FINAL

    -----Code changes for APCC refresh-----------
      BEGIN


        IF (pAPCC_refresh = MSC_UTIL.SYS_YES) THEN
            IF (v_is_partial_refresh) THEN
             		   l_req_id := fnd_request.submit_request(
                                        'MSC',
                                        'MSCHUBO',
                                        NULL,
                                        NULL,
                                        FALSE,
                                        pINSTANCE_ID,
                                        2,
                                        NULL);

            ELSIF (v_is_complete_refresh) THEN
               		   l_req_id := fnd_request.submit_request(
                                        'MSC',
                                        'MSCHUBO',
                                        NULL,
                                        NULL,
                                        FALSE,
                                        pINSTANCE_ID,
                                        1,
                                        NULL);
             END IF;

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'LAUNCH_MON_PARTIAL Launched APCC refresh data collections CP. Request Id = '||l_req_id);
        END IF;
    EXCEPTION WHEN OTHERS THEN
           ERRBUF:=SQLERRM||' Request: '||l_req_id||'  Error in Call To program MSCHUBO ';
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, ERRBUF);
    END;

    COMMIT;
    -----end of changes for APCC refresh----------

     FINAL;

     IF RETCODE= MSC_UTIL.G_ERROR THEN
    	IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
    		COMMIT;
    	END IF;
	   RETCODE:= MSC_UTIL.G_ERROR ;
	            --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

     RETURN;
     END IF;

     IF v_warning_flag=MSC_UTIL.SYS_YES THEN
        RETCODE:= MSC_UTIL.G_WARNING;
     ELSE
        RETCODE := MSC_UTIL.G_SUCCESS ;
     END IF;

   EXCEPTION

     WHEN EX_PIPE_RCV THEN

        ROLLBACK;

        IF lv_check_point= 2 THEN
           IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
              NULL;
           END IF;
        END IF;

         --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

        -- DELETE SESSION INFO FROM MSC_COLL_PARAMETERS
        -- by calling the procedure FINAL

        FINAL;
        RETCODE := MSC_UTIL.G_ERROR;

        COMMIT;

     WHEN EX_PIPE_SND THEN

        ROLLBACK;

        IF lv_check_point= 2 THEN
           IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
              NULL;
           END IF;
        END IF;

        FND_MESSAGE.SET_NAME('MSC', 'MSC_MSG_SEND_FAIL');
        FND_MESSAGE.SET_TOKEN('PIPE', v_pipe_wm);
        ERRBUF:= FND_MESSAGE.GET;

         --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

        -- DELETE SESSION INFO FROM MSC_COLL_PARAMETERS
        -- by calling the procedure FINAL

        FINAL;
        RETCODE := MSC_UTIL.G_ERROR;

        COMMIT;

     WHEN EX_PROCESS_TIME_OUT THEN

        ROLLBACK;

        IF lv_check_point= 2 THEN
           IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
              NULL;
           END IF;
        END IF;

        FND_MESSAGE.SET_NAME('MSC', 'MSC_TIMEOUT');
        ERRBUF:= FND_MESSAGE.GET;

                 --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

        -- DELETE SESSION INFO FROM MSC_COLL_PARAMETERS
        -- by calling the procedure FINAL

        FINAL;
        RETCODE := MSC_UTIL.G_ERROR;

        COMMIT;

     WHEN others THEN

        ROLLBACK;

        IF lv_check_point= 2 THEN
           IF SET_ST_STATUS( ERRBUF, RETCODE, pINSTANCE_ID, MSC_UTIL.G_ST_READY) THEN
              NULL;
           END IF;
        END IF;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,   SQLERRM);

                 --Rollback swap partitions
         IF NOT MSC_CL_EXCHANGE_PARTTBL.UNDO_STG_ODS_SWAP THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,' Exchange partition failed ');
         END IF;

        -- DELETE SESSION INFO FROM MSC_COLL_PARAMETERS
        -- by calling the procedure FINAL

        FINAL;
        ERRBUF  := SQLERRM;
        RETCODE := MSC_UTIL.G_ERROR;

        COMMIT;

   END LAUNCH_MON_PARTIAL;

-- agmcont:





   /***************  PREPLACE CHANGE END  *****************/

 /* added this procedure for the conc program - Create Instance-Org Supplier Association
   This conc program updates the Msc_trading_partners table with the Modeleed Supplier info */

PROCEDURE ENTER_MODELLED_INFO( ERRBUF               OUT NOCOPY VARCHAR2,
                                RETCODE              OUT NOCOPY NUMBER,
                                pINSTANCE_ID         IN  NUMBER,
                                pDEST_PARTNER_ORG_ID IN  NUMBER,
                                pSUPPLIER_ID         IN  NUMBER,
                                pSUPPLIER_SITE_ID   IN  NUMBER,
                                pACCEPT_DEMANDS_FROM_UNMET_PO IN NUMBER)
IS
BEGIN

IF ( (pSUPPLIER_ID IS NULL) AND (pSUPPLIER_SITE_ID IS NULL) ) THEN

  UPDATE msc_trading_partners
  SET MODELED_SUPPLIER_ID = null,
      MODELED_SUPPLIER_SITE_ID = null,
      ORG_SUPPLIER_MAPPED = 'N',
      ACCEPT_DEMANDS_FROM_UNMET_PO = null
  WHERE sr_instance_id = pINSTANCE_ID
    AND PARTNER_ID  = pDEST_PARTNER_ORG_ID
    AND PARTNER_TYPE = 3;

   COMMIT;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '================================================');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Removed the Modeled Information for Partner Id : '||pDEST_PARTNER_ORG_ID );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '================================================');

   RETCODE := MSC_UTIL.G_SUCCESS ;

ELSE

 UPDATE msc_trading_partners
 SET MODELED_SUPPLIER_ID = pSUPPLIER_ID,
     MODELED_SUPPLIER_SITE_ID = pSUPPLIER_SITE_ID,
     ORG_SUPPLIER_MAPPED = 'Y',
     ACCEPT_DEMANDS_FROM_UNMET_PO = pACCEPT_DEMANDS_FROM_UNMET_PO
 WHERE sr_instance_id = pINSTANCE_ID
   AND PARTNER_ID  = pDEST_PARTNER_ORG_ID
   AND PARTNER_TYPE = 3;

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '================================================');
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Updated the Partner Id : '||pDEST_PARTNER_ORG_ID );
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Modelled Supplier as : '||pSUPPLIER_ID);
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Modelled Supplier Site as : '||pSUPPLIER_SITE_ID);
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Accept Demands From Unmet PO  as : '||pACCEPT_DEMANDS_FROM_UNMET_PO);
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, '================================================');

 COMMIT;

 RETCODE := MSC_UTIL.G_SUCCESS ;

END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'An error has occurred.');
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, SQLERRM);
    RETCODE := MSC_UTIL.G_ERROR;

END ENTER_MODELLED_INFO;

PROCEDURE  COMPUTE_RES_AVAIL (ERRBUF               OUT NOCOPY VARCHAR2,
                              RETCODE              OUT NOCOPY NUMBER,
                              pINSTANCE_ID         IN  NUMBER,
                              pSTART_DATE          IN  VARCHAR2)
IS
BEGIN
MSC_RESOURCE_AVAILABILITY.COMPUTE_RES_AVAIL( ERRBUF     ,
                                                RETCODE    ,
                                                pINSTANCE_ID,
                                                pSTART_DATE  ) ;


END COMPUTE_RES_AVAIL;
 /* After Splitting GENERATE_ITEM_KEYS is placed in MSC_CL_ITEM_ODS_LOAD package  . This is a wrapper for the same.*/

   PROCEDURE GENERATE_ITEM_KEYS (
                                 ERRBUF				OUT NOCOPY VARCHAR2,
	                               RETCODE				OUT NOCOPY NUMBER,
     		                        pINSTANCE_ID                    IN  NUMBER) IS
   BEGIN

        MSC_CL_ITEM_ODS_LOAD.GENERATE_ITEM_KEYS (ERRBUF,RETCODE,pINSTANCE_ID);

   END GENERATE_ITEM_KEYS;

	 PROCEDURE GENERATE_TRADING_PARTNER_KEYS (ERRBUF	OUT NOCOPY VARCHAR2,
	    		     RETCODE		OUT NOCOPY NUMBER,
                              pINSTANCE_ID 	IN NUMBER) IS
	   BEGIN

	     MSC_CL_SETUP_ODS_LOAD.GENERATE_TRADING_PARTNER_KEYS (ERRBUF,RETCODE,pINSTANCE_ID);

	   END GENERATE_TRADING_PARTNER_KEYS;


 PROCEDURE LAUNCH_MONITOR_DET_SCH( ERRBUF                     OUT NOCOPY VARCHAR2,
                              RETCODE                           OUT NOCOPY NUMBER,
                              pINSTANCE_ID                      IN  NUMBER,
                              pTIMEOUT                          IN  NUMBER,
                              pTotalWorkerNum                   IN  NUMBER,
                              pRECALC_NRA                       IN  NUMBER,
                              pAPCC_refresh                     IN  NUMBER DEFAULT MSC_UTIL.SYS_NO)

           IS
  lERRBUF  VARCHAR2(240) ;
  lRETCODE	NUMBER;
 begin
     v_DSMode := MSC_UTIL.SYS_YES;
     p_TIMEOUT := pTIMEOUT;
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'calling launch monitor. recalc_nra= '||pRECALC_NRA);

      LAUNCH_MONITOR(lERRBUF,
                     lRETCODE,
                     pINSTANCE_ID,
                     pTIMEOUT,
                     pTotalWorkerNum,
                     pRECALC_NRA,        --lv_RECALC_NRA,
                     MSC_UTIL.SYS_NO,         --lv_RECALC_SH,
                     MSC_UTIL.SYS_NO,  -------lv_PURGE_SH);
                     MSC_UTIL.SYS_NO);
    ERRBUF := lERRBUF;
    RETCODE := lRETCODE ;
   END LAUNCH_MONITOR_DET_SCH;
/* procedure CLEAN_LIAB_AGREEMENT has  been moved to package  MSC_CL_SETUP_ODS_LOAD
 through bug5952569 */

PROCEDURE alter_temp_table (ERRBUF		OUT NOCOPY VARCHAR2,
			     RETCODE		OUT NOCOPY NUMBER,
                             p_part_table 	IN VARCHAR2,
                             p_instance_code 	IN VARCHAR2,
                             p_severity_level	IN NUMBER
                            )
IS
   lv_crt_ind_status	NUMBER;
   INDEX_CREATION_ERROR	EXCEPTION;
   lv_errbuf		VARCHAR2(240);
   lv_retcode		NUMBER := MSC_UTIL.G_SUCCESS ;
   lv_instance_id	NUMBER;
   lv_is_plan		NUMBER := MSC_UTIL.SYS_NO;
   lv_temp_tbl_name	VARCHAR2(32);

   EXCHG_PRT_ERROR	EXCEPTION;

BEGIN

   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'alter_temp_table');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, FND_MESSAGE.GET);

   SELECT instance_id
   INTO   lv_instance_id
   FROM   msc_apps_instances
   WHERE  upper(instance_code) = p_instance_code;

   IF MSC_CL_EXCHANGE_PARTTBL.Initialize( lv_instance_id,
                                          p_instance_code,
                                          FALSE) THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'MSC_CL_EXCHANGE_PARTTBL.Initialize successful');
   ELSE
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'MSC_CL_EXCHANGE_PARTTBL.Initialize - failed');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, sqlerrm);
      RAISE EXCHG_PRT_ERROR;
   END IF;

   lv_temp_tbl_name := SUBSTR(p_part_table, 5, LENGTH(p_part_table)) || '_' || p_instance_code;

   msc_analyse_tables_pk.analyse_table(lv_temp_tbl_name);

   lv_crt_ind_status := MSC_CL_EXCHANGE_PARTTBL.create_temp_table_index
                                 ('UNIQUE',
                                  p_part_table,
                                  lv_temp_tbl_name,
                                  p_instance_code,
                                  lv_instance_id,
                                  lv_is_plan,
                                  p_severity_level
                                 );

   IF lv_crt_ind_status = MSC_UTIL.G_ERROR THEN
      FND_MESSAGE.SET_NAME('MSC', 'MSC_CRT_IND_STATUS');
      FND_MESSAGE.SET_TOKEN('UNIQUENESS', 'UNIQUE');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', lv_temp_tbl_name);
      FND_MESSAGE.SET_TOKEN('STATUS', 'ERROR');

      lv_errbuf := FND_MESSAGE.GET;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, lv_errbuf);
      RAISE INDEX_CREATION_ERROR;
   ELSE
      IF lv_crt_ind_status = MSC_UTIL.G_WARNING THEN
         FND_MESSAGE.SET_NAME('MSC', 'MSC_CRT_IND_STATUS');
         FND_MESSAGE.SET_TOKEN('UNIQUENESS', 'UNIQUE');
         FND_MESSAGE.SET_TOKEN('TABLE_NAME', lv_temp_tbl_name);
         FND_MESSAGE.SET_TOKEN('STATUS', 'WARNING');

         lv_errbuf := FND_MESSAGE.GET;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, lv_errbuf);
         lv_retcode := MSC_UTIL.G_WARNING;
      ELSE
         FND_MESSAGE.SET_NAME('MSC', 'MSC_CRT_IND_STATUS');
         FND_MESSAGE.SET_TOKEN('UNIQUENESS', 'UNIQUE');
         FND_MESSAGE.SET_TOKEN('TABLE_NAME', lv_temp_tbl_name);
         FND_MESSAGE.SET_TOKEN('STATUS', 'SUCCESS');

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
      END IF;

      lv_crt_ind_status := MSC_CL_EXCHANGE_PARTTBL.create_temp_table_index
                                 ('NONUNIQUE',
                                  p_part_table,
                                  lv_temp_tbl_name,
                                  p_instance_code,
                                  lv_instance_id,
                                  lv_is_plan,
                                  p_severity_level
                                 );
      IF lv_crt_ind_status = MSC_UTIL.G_WARNING THEN
         FND_MESSAGE.SET_NAME('MSC', 'MSC_CRT_IND_STATUS');
         FND_MESSAGE.SET_TOKEN('UNIQUENESS', 'NONUNIQUE');
         FND_MESSAGE.SET_TOKEN('TABLE_NAME', lv_temp_tbl_name);
         FND_MESSAGE.SET_TOKEN('STATUS', 'WARNING');

         lv_errbuf := FND_MESSAGE.GET;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, lv_errbuf);
         lv_retcode := MSC_UTIL.G_WARNING;
      ELSIF lv_crt_ind_status = MSC_UTIL.G_ERROR THEN
         FND_MESSAGE.SET_NAME('MSC', 'MSC_CRT_IND_STATUS');
         FND_MESSAGE.SET_TOKEN('UNIQUENESS', 'NONUNIQUE');
         FND_MESSAGE.SET_TOKEN('TABLE_NAME', lv_temp_tbl_name);
         FND_MESSAGE.SET_TOKEN('STATUS', 'ERROR');

         lv_errbuf := FND_MESSAGE.GET;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, lv_errbuf);
         RAISE INDEX_CREATION_ERROR;
      ELSE
         FND_MESSAGE.SET_NAME('MSC', 'MSC_CRT_IND_STATUS');
         FND_MESSAGE.SET_TOKEN('UNIQUENESS', 'NONUNIQUE');
         FND_MESSAGE.SET_TOKEN('TABLE_NAME', lv_temp_tbl_name);
         FND_MESSAGE.SET_TOKEN('STATUS', 'SUCCESS');

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,FND_MESSAGE.GET);
      END IF;
   END IF;

   FND_MESSAGE.SET_NAME('MSC', 'MSC_CRT_IND_STATUS');
   FND_MESSAGE.SET_TOKEN('UNIQUENESS', 'Unique and Nonunique');
   FND_MESSAGE.SET_TOKEN('TABLE_NAME', lv_temp_tbl_name);
   FND_MESSAGE.SET_TOKEN('STATUS', 'SUCCESS');

   lv_errbuf := FND_MESSAGE.GET;

   ERRBUF := lv_errbuf;
   RETCODE := lv_retcode;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'End alter_temp_table');

EXCEPTION
   WHEN INDEX_CREATION_ERROR THEN
      RAISE;
   WHEN OTHERS THEN
      ERRBUF := sqlerrm;
      RETCODE := MSC_UTIL.G_ERROR;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, sqlerrm);

      RAISE;
END alter_temp_table;

     -- ============== KEY TRANSFORMATION FOR ITEMS, CATEGORY SETS =================



     -- ============== KEY TRANSFORMATION FOR TRADING PARTNERS =================

-- need to be decided (rama)
   FUNCTION    LAUNCH_MONITOR_CONT(
                      ERRBUF                            OUT NOCOPY VARCHAR2,
                      RETCODE                           OUT NOCOPY NUMBER,
                      pINSTANCE_ID                      IN  NUMBER,
                      pTIMEOUT                          IN  NUMBER,-- minutes
                      pTotalWorkerNum                   IN  NUMBER,
		                  pDSMode				                    IN  NUMBER default MSC_UTIL.SYS_NO,
                      pAPCC_refresh                     IN  NUMBER DEFAULT MSC_UTIL.SYS_NO)

		      RETURN boolean is

      lv_RECALC_NRA  NUMBER :=2;
      lv_RECALC_SH   NUMBER :=2;
      lv_PURGE_SH    NUMBER :=2;

   begin
      v_DSMode := pDSMode;
      p_TIMEOUT := pTIMEOUT;
      LAUNCH_MONITOR(ERRBUF,
                     RETCODE,
                     pINSTANCE_ID,
                     pTIMEOUT,
                     pTotalWorkerNum,
                     MSC_UTIL.SYS_NO,        --lv_RECALC_NRA,
                     MSC_UTIL.SYS_NO,         --lv_RECALC_SH,
                     MSC_UTIL.SYS_NO,         -------lv_PURGE_SH);
                     MSC_UTIL.SYS_NO);

   IF RETCODE <> MSC_UTIL.G_ERROR THEN
	     RETURN TRUE;
   ELSE
             RETURN FALSE;
   END IF;

   END LAUNCH_MONITOR_CONT;
--


END MSC_CL_COLLECTION;

/
