--------------------------------------------------------
--  DDL for Package Body MSC_CL_SETUP_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_SETUP_ODS_LOAD" AS -- specification
/* $Header: MSCLSTPB.pls 120.9.12010000.8 2010/03/24 07:15:34 vsiyer ship $ */
--  SYS_YES Number:=  MSC_UTIL.SYS_YES ;
--  SYS_NO Number:=  MSC_CL_COLLECTION.SYS_NO ;
--  G_SUCCESS  NUMBER := MSC_CL_COLLECTION.G_SUCCESS;
--  G_WARNING  NUMBER := MSC_CL_COLLECTION.G_WARNING;
--  G_ERROR    NUMBER := MSC_CL_COLLECTION.G_ERROR;
 -- G_COLLECTION_PROGRAM  NUMBER := MSC_CL_COLLECTION.G_COLLECTION_PROGRAM;
 -- SYS_TGT NUMBER:=MSC_CL_COLLECTION.SYS_TGT;
--  G_INS_OTHER NUMBER:= MSC_CL_COLLECTION.G_INS_OTHER;
--  NULL_VALUE      NUMBER:=MSC_UTIL.NULL_VALUE;
--  NULL_DATE      DATE:=MSC_CL_COLLECTION.NULL_DATE;
--  NULL_DBLINK    VARCHAR2(1):=MSC_UTIL.NULL_DBLINK;
--  G_MY_COMPANY_ID		  NUMBER := MSC_CL_COLLECTION.G_MY_COMPANY_ID;
--  G_APPS110              NUMBER := MSC_CL_COLLECTION.G_APPS110;
--  G_APPS115              NUMBER :=MSC_CL_COLLECTION.G_APPS115;
--  G_APPS107              NUMBER :=MSC_CL_COLLECTION.G_APPS107;
--  G_APPS120              NUMBER :=MSC_CL_COLLECTION.G_APPS120;
--  G_ALL_ORGANIZATIONS    VARCHAR2(6):= MSC_CL_COLLECTION.G_ALL_ORGANIZATIONS;

	FUNCTION LINK_SUPPLY_TOP_LINK_ID
	RETURN BOOLEAN
	IS
	  lv_task_start_time  DATE;
	  lv_tbl              VARCHAR2(30);
	begin

	     lv_task_start_time := SYSDATE;

	        IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
	             lv_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;

	        ELSE
	             lv_tbl:= 'MSC_SUPPLIES';
	        END IF;

	          EXECUTE IMMEDIATE
	 		   ' update ' || lv_tbl || ' s '
	                  ||' set s.top_transaction_id  = '
			  || '   ( select nwk.top_transaction_id  '
			  || '       from msc_job_operation_networks nwk '
			  || '       where nwk.to_transaction_id = s.transaction_id '
			  || '	     and nwk.plan_id = s.plan_id '
			  || '	     and nwk.sr_instance_id = s.sr_instance_id '
			  || '	     and nwk.top_transaction_id is not null '
			  || '       and nwk.plan_id = -1 '
			  || '	     and rownum = 1 )'
			  || ' WHERE s.plan_id = -1  '
			  || ' and s.sr_instance_id = '|| MSC_CL_COLLECTION.v_instance_id
			  || ' and s.order_type = 70';   /* eam supply order type */

	            COMMIT;


	     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
	     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
	                 TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '   '||FND_MESSAGE.GET);

	 RETURN TRUE;

	EXCEPTION
	   WHEN OTHERS THEN
	          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error executing MSC_CL_DEMAND_ODS_LOAD.LINK_PARENT_SALES_ORDERS_MDS......');
	          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	   RETURN FALSE;

	END LINK_SUPPLY_TOP_LINK_ID;

 -- ============== CLEANSE DATA =================

	   FUNCTION CLEANSE_DATA RETURN BOOLEAN
	   IS

	      ERRBUF  VARCHAR2(2048);
	      RETCODE NUMBER;

	      CLEANSED_FLAG NUMBER;

	   BEGIN

	      SELECT NVL( CLEANSED_FLAG, MSC_UTIL.SYS_NO)
				INTO CLEANSED_FLAG
				FROM MSC_APPS_INSTANCES mai
	       WHERE mai.INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

	      IF CLEANSED_FLAG= MSC_UTIL.SYS_NO THEN

		 		 MSC_CL_CLEANSE.CLEANSE( ERRBUF,
					  RETCODE,
					  MSC_CL_COLLECTION.v_instance_id);

		  IF RETCODE= MSC_UTIL.G_SUCCESS OR RETCODE= MSC_UTIL.G_WARNING THEN

		     UPDATE MSC_APPS_INSTANCES mai
			SET mai.CLEANSED_FLAG= MSC_UTIL.SYS_YES,
			    LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			    LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
			    REQUEST_ID= FND_GLOBAL.CONC_REQUEST_ID
		      WHERE mai.Instance_ID= MSC_CL_COLLECTION.v_instance_id;

		     COMMIT;

		  ELSE

		     ROLLBACK;

		     MSC_CL_COLLECTION.log_message( MSC_CL_COLLECTION.G_COLLECTION_PROGRAM,
					   MSC_CL_COLLECTION.v_last_collection_id,
					   MSC_CL_COLLECTION.v_current_date,
					   MSC_UTIL.G_ERROR,
					   'MSC_CL_COLLECTION.CLEANSE_DATA',
					   'UNKNOWN',
					   TO_CHAR( MSC_CL_COLLECTION.v_instance_id),
					   ERRBUF);

		     RETURN FALSE;

		  END IF;

	      END IF;

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'CLEANSE DATA... OK!');

	      RETURN TRUE;

	   EXCEPTION

	      WHEN OTHERS THEN

		     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);

		     RAISE;

		--   RETURN FALSE;

	   END CLEANSE_DATA;

	   FUNCTION TRANSFORM_KEYS RETURN BOOLEAN IS

			   lv_default_category_set_id  	NUMBER;
			   lv_control_flag 		NUMBER;
			   lv_msc_tp_coll_window 	NUMBER;
			   lvs_request_id               NumTblTyp := NumTblTyp(0);
			   lv_out 			NUMBER;
			   BEGIN

			SELECT decode(nvl(fnd_profile.value('MSC_PURGE_ST_CONTROL'),'N'),'Y',1,2)
			INTO lv_control_flag
			FROM dual;

			 /* for bug: 2605884, added this piece of code to set the so_tbl_status to NO */

			   IF (MSC_CL_COLLECTION.v_inv_ctp_val = 4) THEN         -- PDS ATP , set SO_TBL_STATUS=2 , no matter type of collections
			         UPDATE MSC_APPS_INSTANCES
			            SET so_tbl_status= MSC_UTIL.SYS_NO
			          WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			         commit;
			   ELSIF (MSC_CL_COLLECTION.v_inv_ctp_val = 5) THEN              -- ODS ATP
			        IF MSC_CL_COLLECTION.v_is_complete_refresh  THEN
			            IF (NOT MSC_CL_COLLECTION.v_is_so_complete_refresh) THEN    -- In complete refresh, if the SO flag is no
			                  UPDATE MSC_APPS_INSTANCES
			                     SET so_tbl_status= MSC_UTIL.SYS_NO
			                   WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                   commit;
			            END IF;
			        ELSIF MSC_CL_COLLECTION.v_is_partial_refresh THEN
			            IF (MSC_CL_COLLECTION.v_coll_prec.sales_order_flag <> MSC_UTIL.SYS_YES) THEN -- in partial refresh, if SO is not collected
			                UPDATE MSC_APPS_INSTANCES
			                   SET so_tbl_status= MSC_UTIL.SYS_NO
			                 WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                 commit;
			            END IF;
			        ELSIF  MSC_CL_COLLECTION.v_is_incremental_refresh THEN
			                 UPDATE MSC_APPS_INSTANCES
			                 SET so_tbl_status= MSC_UTIL.SYS_NO
			                 WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                 commit;
			        ELSIF  MSC_CL_COLLECTION.v_is_cont_refresh THEN
			             IF ( MSC_CL_COLLECTION.v_coll_prec.sales_order_flag <> MSC_UTIL.SYS_YES ) THEN
			                 UPDATE MSC_APPS_INSTANCES
			                   SET so_tbl_status= MSC_UTIL.SYS_NO
			                 WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                 commit;
			             ELSE
			                  IF ( MSC_CL_COLLECTION.v_coll_prec.so_sn_flag <> MSC_UTIL.SYS_TGT ) THEN
			                     UPDATE MSC_APPS_INSTANCES
			                     SET so_tbl_status= MSC_UTIL.SYS_NO
			                     WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                     commit;
			                  END IF;
			             END IF;
			        END IF;
			   END IF;
			lvs_request_id.EXTEND(1);

			--Submit request for Items and Category Sets Key Generation
			lvs_request_id(1) := FND_REQUEST.SUBMIT_REQUEST(
			                          'MSC',
			                          'MSCITTK',
			                          NULL,  -- description
			                          NULL,  -- start date
			                          FALSE, -- TRUE,
			                          MSC_CL_COLLECTION.v_instance_id);
			COMMIT;

			IF lvs_request_id(1) = 0 THEN
			    FND_MESSAGE.SET_NAME('MSC', 'MSC_PROGRAM_LAUNCH_FAIL');
			    FND_MESSAGE.SET_TOKEN('PROGRAM_NAME', 'MSC_CL_COLLECTION.GENERATE_ITEM_KEYS');
			    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
			    RETURN FALSE;
			ELSE
			    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Submitted request for Items and Category Sets Key Generation');
			END IF;

			--Submit request for Trading Parteners Key Generation
			lvs_request_id(2) := FND_REQUEST.SUBMIT_REQUEST(
			                          'MSC',
			                          'MSCTPTK',
			                          NULL,  -- description
			                          NULL,  -- start date
			                          FALSE, -- TRUE,
			                          MSC_CL_COLLECTION.v_instance_id);

			COMMIT;

			IF lvs_request_id(2) = 0 THEN
			    FND_MESSAGE.SET_NAME('MSC', 'MSC_PROGRAM_LAUNCH_FAIL');
			    FND_MESSAGE.SET_TOKEN('PROGRAM_NAME', 'MSC_CL_COLLECTION.GENERATE_TRADING_PARTNER_KEYS');
			    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
			    RETURN FALSE;
			ELSE
			    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Submitted request for Trading Parteners Key Generation');
			END IF;

			FOR j IN 1..lvs_request_id.COUNT LOOP
			   mrp_cl_refresh_snapshot.wait_for_request(lvs_request_id(j), 30, lv_out);

			   IF lv_out = 2 THEN
				 FND_MESSAGE.SET_NAME('MSC', 'MSC_PROGRAM_RUN_FAIL');
				 FND_MESSAGE.SET_TOKEN('REQUEST_ID', lvs_request_id(j));
				 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
				 RETURN FALSE;
			   ELSE
				 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Request ' || lvs_request_id(j) || ' successful');
			   END IF;

			END LOOP;


			 /* for bug: 2605884, added this piece of code to set the so_tbl_status to YES after the Key transformations */

			   IF (MSC_CL_COLLECTION.v_inv_ctp_val = 4) THEN        -- PDS ATP , set SO_TBL_STATUS=1
			         UPDATE MSC_APPS_INSTANCES
			            SET so_tbl_status= MSC_UTIL.SYS_YES
			          WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			         commit;
			   ELSIF (MSC_CL_COLLECTION.v_inv_ctp_val = 5) THEN              -- ODS ATP
			        IF MSC_CL_COLLECTION.v_is_complete_refresh  THEN
			            IF (NOT MSC_CL_COLLECTION.v_is_so_complete_refresh) THEN    -- In complete refresh, if the SO flag is no
			                  UPDATE MSC_APPS_INSTANCES
			                     SET so_tbl_status= MSC_UTIL.SYS_YES
			                   WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                   commit;
			            END IF;
			        ELSIF MSC_CL_COLLECTION.v_is_partial_refresh THEN
			            IF (MSC_CL_COLLECTION.v_coll_prec.sales_order_flag <> MSC_UTIL.SYS_YES) THEN -- in partial refresh, if SO is not collected
			                UPDATE MSC_APPS_INSTANCES
			                   SET so_tbl_status= MSC_UTIL.SYS_YES
			                 WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                 commit;
			            END IF;
			        ELSIF MSC_CL_COLLECTION.v_is_incremental_refresh THEN
			                 UPDATE MSC_APPS_INSTANCES
			                   SET so_tbl_status= MSC_UTIL.SYS_YES
			                 WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                 commit;
			        ELSIF MSC_CL_COLLECTION.v_is_cont_refresh THEN
			            IF ( MSC_CL_COLLECTION.v_coll_prec.sales_order_flag <> MSC_UTIL.SYS_YES ) THEN
			                 UPDATE MSC_APPS_INSTANCES
			                   SET so_tbl_status= MSC_UTIL.SYS_YES
			                 WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                 commit;
			             ELSE
			                  IF ( MSC_CL_COLLECTION.v_coll_prec.so_sn_flag <> MSC_UTIL.SYS_TGT ) THEN
			                     UPDATE MSC_APPS_INSTANCES
			                     SET so_tbl_status= MSC_UTIL.SYS_YES
			                     WHERE instance_id= MSC_CL_COLLECTION.v_instance_id;
			                     commit;
			                  END IF;
			             END IF;
			        END IF;
			   END IF;


			  RETURN TRUE;

			EXCEPTION

			  WHEN OTHERS THEN

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);

			     RETURN FALSE;

			   END TRANSFORM_KEYS;

		  /* CP-ACK starts */
   --==================================================
   -- PROCEDURE : LOAD_CALENDAR_SET_UP
   -- This procedure will load all calendar dates
   -- into MSC_CALENDAR_DATES tables.
   -- These code lines were part of LOAD_CALENDAR_DATE
   -- procedure but we are now seperating this since
   -- PO Acknowledgment collections need Calendar Dates
   -- data before processing Acknowledgment records.
   -- =================================================
   PROCEDURE LOAD_CALENDAR_SET_UP IS

--for loading in MSC_CALENDAR_ASSIGNMENTS
   CURSOR c7 IS
		SELECT distinct
		 msca.ASSOCIATION_TYPE,
			   msca.CALENDAR_CODE,
			   msca.CALENDAR_TYPE,
		      til.TP_ID PARTNER_ID,
			   tsil.TP_SITE_ID PARTNER_SITE_ID,
			   msca.ORGANIZATION_ID,
			   msca.SR_INSTANCE_ID,
			   mtil.TP_ID CARRIER_PARTNER_ID,
			   msca.PARTNER_TYPE,
			   msca.ASSOCIATION_LEVEL,
			   msca.SHIP_METHOD_CODE
		FROM MSC_TP_ID_LID til,
		     MSC_TP_SITE_ID_LID tsil,
		     MSC_ST_CALENDAR_ASSIGNMENTS  msca,
		     MSC_TP_ID_LID mtil
		WHERE til.SR_INSTANCE_ID(+)= msca.SR_INSTANCE_ID
		  AND til.SR_TP_ID(+)= msca.PARTNER_ID
		  AND til.PARTNER_TYPE(+)= msca.PARTNER_TYPE
		  AND tsil.SR_INSTANCE_ID(+)= msca.SR_INSTANCE_ID
		  AND tsil.SR_TP_SITE_ID(+)= msca.PARTNER_SITE_ID
		  AND tsil.PARTNER_TYPE(+)= msca.PARTNER_TYPE
		  AND msca.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND mtil.SR_INSTANCE_ID(+)= msca.SR_INSTANCE_ID
		  AND mtil.SR_TP_ID(+)= msca.CARRIER_PARTNER_ID
		  AND mtil.PARTNER_TYPE(+)=4;


		--If instance type is not 'others', then insert into msc_calendars those calendars present in msc_calendar_dates
		   CURSOR c5 IS
		SELECT distinct
		  mscd.CALENDAR_CODE,
		  mscd.CALENDAR_START_DATE,
		  mscd.CALENDAR_END_DATE,
		  mscd.DESCRIPTION,
		  mscd.SR_INSTANCE_ID
		FROM MSC_ST_CALENDAR_DATES mscd
		WHERE mscd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;



		--Calculate the first and last working days for each of the calendars in MSC_CALENDARS
		CURSOR c6 IS
		SELECT
		Min(CALENDAR_DATE) FIRST_WORKING_DATE,
		Max(CALENDAR_DATE) LAST_WORKING_DATE,
		CALENDAR_CODE,
		SR_INSTANCE_ID
		FROM MSC_CALENDAR_DATES mscd
		WHERE mscd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		and seq_num is not null
		GROUP BY CALENDAR_CODE, SR_INSTANCE_ID;



		   CURSOR c1 IS
		SELECT
		  mscd.CALENDAR_DATE,
		  mscd.CALENDAR_CODE,
		  mscd.SEQ_NUM,
		  mscd.NEXT_SEQ_NUM,
		  mscd.PRIOR_SEQ_NUM,
		  mscd.NEXT_DATE,
		  mscd.PRIOR_DATE,
		  mscd.CALENDAR_START_DATE,
		  mscd.CALENDAR_END_DATE,
		  mscd.DESCRIPTION,
		  mscd.EXCEPTION_SET_ID,
		  mscd.SR_INSTANCE_ID
		FROM MSC_ST_CALENDAR_DATES mscd
		WHERE mscd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

		CURSOR c2 IS
		SELECT
		  mspsd.CALENDAR_CODE,
		  mspsd.EXCEPTION_SET_ID,
		  mspsd.PERIOD_START_DATE,
		  mspsd.PERIOD_SEQUENCE_NUM,
		  substrb(mspsd.PERIOD_NAME,1,3) PERIOD_NAME, --added for the NLS bug3463401
		  mspsd.NEXT_DATE,
		  mspsd.PRIOR_DATE,
		  mspsd.SR_INSTANCE_ID
		FROM MSC_ST_PERIOD_START_DATES mspsd
		WHERE mspsd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

		   CURSOR c3 IS
		SELECT
		  mscysd.CALENDAR_CODE,
		  mscysd.EXCEPTION_SET_ID,
		  mscysd.YEAR_START_DATE,
		  mscysd.SR_INSTANCE_ID
		FROM MSC_ST_CAL_YEAR_START_DATES mscysd
		WHERE mscysd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

		   CURSOR c4 IS
		SELECT
		  mscwsd.CALENDAR_CODE,
		  mscwsd.EXCEPTION_SET_ID,
		  mscwsd.WEEK_START_DATE,
		  mscwsd.NEXT_DATE,
		  mscwsd.PRIOR_DATE,
		  mscwsd.SEQ_NUM,
		  mscwsd.SR_INSTANCE_ID
		FROM MSC_ST_CAL_WEEK_START_DATES mscwsd
		WHERE mscwsd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

		   c_count NUMBER:= 0;

		   lv_sql_stmt VARCHAR2(5000);
		   lv_sql_ins        VARCHAR2(5000);
		   lb_FetchComplete  Boolean;
		   ln_rows_to_fetch  Number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);


		  TYPE CharTblTyp IS TABLE OF VARCHAR2(250);
		  TYPE NumTblTyp  IS TABLE OF NUMBER;
		  TYPE dateTblTyp IS TABLE OF DATE;

		  lb_CALENDAR_DATE	dateTblTyp;
		  lb_CALENDAR_CODE	CharTblTyp;
		  lb_SEQ_NUM		NumTblTyp;
		  lb_NEXT_SEQ_NUM	NumTblTyp;
		  lb_PRIOR_SEQ_NUM	NumTblTyp;
		  lb_NEXT_DATE		dateTblTyp;
		  lb_PRIOR_DATE		dateTblTyp;
		  lb_CALENDAR_START_DATE dateTblTyp;
		  lb_CALENDAR_END_DATE	dateTblTyp;
		  lb_DESCRIPTION	CharTblTyp;
		  lb_EXCEPTION_SET_ID	NumTblTyp;
		  lb_SR_INSTANCE_ID	NumTblTyp;

		   BEGIN


		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

		MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PERIOD_START_DATES', MSC_CL_COLLECTION.v_instance_id, NULL);

		MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CAL_YEAR_START_DATES', MSC_CL_COLLECTION.v_instance_id, NULL);

		MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CAL_WEEK_START_DATES', MSC_CL_COLLECTION.v_instance_id, NULL);

		END IF;

		-- Calendar Dates --

		if (MSC_CL_COLLECTION.v_is_partial_refresh or MSC_CL_COLLECTION.v_is_complete_refresh ) THEN
		UPDATE MSC_CALENDAR_DATES
		   SET DELETED_FLAG= MSC_UTIL.SYS_YES,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
               WHERE
               SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
               AND exception_set_id = -1;


		COMMIT;
		 lv_sql_stmt :=
			'   INSERT INTO MSC_CALENDAR_DATES '
			||'( CALENDAR_DATE, '
			||'  CALENDAR_CODE, '
			||'  SEQ_NUM, '
			||'  NEXT_SEQ_NUM, '
			||'  PRIOR_SEQ_NUM, '
			||'  NEXT_DATE, '
			||'  PRIOR_DATE, '
			||'  CALENDAR_START_DATE, '
			||'  CALENDAR_END_DATE, '
			||'  DESCRIPTION, '
			||'  EXCEPTION_SET_ID, '
			||'  SR_INSTANCE_ID, '
			||'  REFRESH_NUMBER, '
			||'  DELETED_FLAG, '
			||'  LAST_UPDATE_DATE, '
			||'  LAST_UPDATED_BY, '
			||'  CREATION_DATE, '
			||'  CREATED_BY) '
			||' VALUES '
			||'( :CALENDAR_DATE, '
			||'  :CALENDAR_CODE, '
			||'  :SEQ_NUM, '
			||'  :NEXT_SEQ_NUM, '
			||'  :PRIOR_SEQ_NUM, '
			||'  :NEXT_DATE, '
			||'  :PRIOR_DATE, '
			||'  :CALENDAR_START_DATE, '
			||'  :CALENDAR_END_DATE, '
			||'  :DESCRIPTION, '
			||'  :EXCEPTION_SET_ID, '
			||'  :SR_INSTANCE_ID, '
			||'   :v_last_collection_id, '
			||'   :SYS_NO, '
			||'   :v_current_date, '
			||'   :v_current_user, '
			||'   :v_current_date, '
			||'   :v_current_user ) ';

		OPEN  c1;
		IF (c1%ISOPEN) THEN
		       LOOP

		         --
		         -- Retrieve the next set of rows if we are currently not in the
		         -- middle of processing a fetched set or rows.
		         --
		         IF (lb_FetchComplete) THEN
		           EXIT;
		         END IF;

		         -- Fetch the next set of rows
		FETCH c1 BULK COLLECT INTO    lb_CALENDAR_DATE	,
									  lb_CALENDAR_CODE	,
									  lb_SEQ_NUM		,
									  lb_NEXT_SEQ_NUM	,
									  lb_PRIOR_SEQ_NUM	,
									  lb_NEXT_DATE		,
									  lb_PRIOR_DATE		,
									  lb_CALENDAR_START_DATE ,
									  lb_CALENDAR_END_DATE	,
									  lb_DESCRIPTION	,
									  lb_EXCEPTION_SET_ID	,
									  lb_SR_INSTANCE_ID
		LIMIT ln_rows_to_fetch;

		         -- Since we are only fetching records if either (1) this is the first
		         -- fetch or (2) the previous fetch did not retrieve all of the
		         -- records, then at least one row should always be fetched.  But
		         -- checking just to make sure.
		         EXIT WHEN lb_CALENDAR_CODE.count = 0;

		         -- Check if all of the rows have been fetched.  If so, indicate that
		         -- the fetch is complete so that another fetch is not made.
		         -- Additional check is introduced for the following reasons
		         -- In 9i, the table of records gets modified but in 8.1.6 the table of records is
		         -- unchanged after the fetch(bug#2995144)
		         IF (c1%NOTFOUND) THEN
		           lb_FetchComplete := TRUE;
		         END IF;

		FOR j IN 1..lb_CALENDAR_CODE.COUNT LOOP

		BEGIN

		--IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

		  UPDATE MSC_CALENDAR_DATES
		SET
		 SEQ_NUM= lb_SEQ_NUM(j),
		 NEXT_SEQ_NUM= lb_NEXT_SEQ_NUM(j),
		 PRIOR_SEQ_NUM= lb_PRIOR_SEQ_NUM(j),
		 NEXT_DATE= lb_NEXT_DATE(j),
		 PRIOR_DATE= lb_PRIOR_DATE(j),
		 CALENDAR_START_DATE= lb_CALENDAR_START_DATE(j),
		 CALENDAR_END_DATE= lb_CALENDAR_END_DATE(j),
		 DESCRIPTION= lb_DESCRIPTION(j),
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 Deleted_Flag= MSC_UTIL.SYS_NO,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		WHERE CALENDAR_DATE= lb_CALENDAR_DATE(j)
		  AND CALENDAR_CODE= lb_CALENDAR_CODE(j)
		  AND EXCEPTION_SET_ID= lb_EXCEPTION_SET_ID(j)
		  AND SR_INSTANCE_ID= lb_SR_INSTANCE_ID(j);

		--END IF;

		IF SQL%NOTFOUND THEN
		EXECUTE IMMEDIATE lv_sql_stmt
		USING
			lb_CALENDAR_DATE(j),
			lb_CALENDAR_CODE(j),
			lb_SEQ_NUM(j),
			lb_NEXT_SEQ_NUM(j),
			lb_PRIOR_SEQ_NUM(j),
			lb_NEXT_DATE(j),
			lb_PRIOR_DATE(j),
			lb_CALENDAR_START_DATE(j),
			lb_CALENDAR_END_DATE(j),
			lb_DESCRIPTION(j),
			lb_EXCEPTION_SET_ID(j),
			lb_SR_INSTANCE_ID(j),
			MSC_CL_COLLECTION.v_last_collection_id,
			MSC_UTIL.SYS_NO,
			MSC_CL_COLLECTION.v_current_date,
			MSC_CL_COLLECTION.v_current_user,
			MSC_CL_COLLECTION.v_current_date,
			MSC_CL_COLLECTION.v_current_user ;

		   END IF;


		EXCEPTION
		   WHEN OTHERS THEN


		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDAR_DATES');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDAR_DATES');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'EXCEPTION_SET_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR( lb_EXCEPTION_SET_ID(j)));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_DATE');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lb_CALENDAR_DATE(j)));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE', lb_CALENDAR_CODE(j));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;
		 END LOOP;
		 END IF;
		 CLOSE c1;
		 COMMIT;


		DELETE MSC_CALENDAR_DATES
		WHERE DELETED_FLAG= MSC_UTIL.SYS_YES
		  AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND exception_set_id = -1;

		COMMIT;

		msc_analyse_tables_pk.analyse_table( 'MSC_CALENDAR_DATES');


		END IF;

		--If it is complete or partial or continuous refresh, delete existing calendars in the current instance from MSC_CALENDARS


		   IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.v_is_cont_refresh) THEN
			MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_CALENDARS', MSC_CL_COLLECTION.v_instance_id, NULL);
		   END IF;

		   FOR c_rec IN c5 LOOP

		BEGIN
		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'cal code='|| c_rec.CALENDAR_CODE);
		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.v_is_cont_refresh) THEN

		IF MSC_CL_COLLECTION.v_instance_type <> MSC_UTIL.G_INS_OTHER THEN

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'cal code='|| c_rec.CALENDAR_CODE);

		INSERT INTO MSC_CALENDARS
		( CALENDAR_CODE,
		  DESCRIPTION,
		  CALENDAR_START_DATE,
		  CALENDAR_END_DATE,
		  SR_INSTANCE_ID,
		  REFRESH_ID,
		  LAST_UPDATE_DATE,
		  LAST_UPDATED_BY,
		  CREATION_DATE,
		  CREATED_BY)
		VALUES
		( c_rec.CALENDAR_CODE,
		  c_rec.DESCRIPTION,
		  c_rec.CALENDAR_START_DATE,
		  c_rec.CALENDAR_END_DATE,
		  c_rec.SR_INSTANCE_ID,
		  MSC_CL_COLLECTION.v_last_collection_id,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user );

		END IF;

		END IF;
		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDARS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDARS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;
		END;
		END LOOP;


		FOR c_rec IN c6 LOOP

		BEGIN

		UPDATE MSC_CALENDARS
		SET
		FIRST_WORKING_DATE = c_rec.FIRST_WORKING_DATE,
		LAST_WORKING_DATE = c_rec.LAST_WORKING_DATE
		WHERE CALENDAR_CODE = c_rec.CALENDAR_CODE
		AND SR_INSTANCE_ID = c_rec. SR_INSTANCE_ID;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDARS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDARS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		   END IF;
		END;
		END LOOP;



		--Collection of Calendar Assignments in case of complete, targeted and continuous refresh modes only..

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.v_is_cont_refresh OR MSC_CL_COLLECTION.v_is_legacy_refresh) THEN

	MSC_CL_COLLECTION.DELETE_MSC_TABLE('MSC_CALENDAR_ASSIGNMENTS', MSC_CL_COLLECTION.v_instance_id, NULL);


	FOR c_rec IN c7 LOOP

	BEGIN

	INSERT INTO MSC_CALENDAR_ASSIGNMENTS
	(	ASSOCIATION_TYPE,
		   CALENDAR_CODE,
		   CALENDAR_TYPE,
		   PARTNER_ID,
		   PARTNER_SITE_ID,
		   ORGANIZATION_ID,
		   SR_INSTANCE_ID,
		   CARRIER_PARTNER_ID,
		   PARTNER_TYPE,
		   ASSOCIATION_LEVEL,
		   SHIP_METHOD_CODE,
		   REFRESH_NUMBER,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   CREATION_DATE,
		   CREATED_BY,
		   LAST_UPDATE_LOGIN)
	VALUES
	( c_rec.ASSOCIATION_TYPE,
	  c_rec.CALENDAR_CODE,
	  c_rec.CALENDAR_TYPE,
	  c_rec.PARTNER_ID,
	  c_rec.PARTNER_SITE_ID,
	  c_rec.ORGANIZATION_ID,
	  c_rec.SR_INSTANCE_ID,
	  c_rec.CARRIER_PARTNER_ID,
	  c_rec.PARTNER_TYPE,
	  c_rec.ASSOCIATION_LEVEL,
	  c_rec.SHIP_METHOD_CODE,
	  MSC_CL_COLLECTION.v_last_collection_id,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user,
	  MSC_CL_COLLECTION.v_current_user);


	EXCEPTION
	    WHEN OTHERS THEN

	    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDAR_ASSIGNMENTS');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	      RAISE;

	    ELSE
	      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDAR_ASSIGNMENTS');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	    END IF;
	END;
	END LOOP;

	COMMIT;
			END IF;

			c_count:= 0;

			FOR c_rec IN c2 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

			UPDATE MSC_PERIOD_START_DATES
			SET
			 PERIOD_SEQUENCE_NUM= c_rec.PERIOD_SEQUENCE_NUM,
			 PERIOD_NAME= c_rec.PERIOD_NAME,
			 NEXT_DATE= c_rec.NEXT_DATE,
			 PRIOR_DATE= c_rec.PRIOR_DATE,
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE CALENDAR_CODE= c_rec.CALENDAR_CODE
			  AND EXCEPTION_SET_ID= c_rec.EXCEPTION_SET_ID
			  AND PERIOD_START_DATE= c_rec.PERIOD_START_DATE
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			END IF;


			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_PERIOD_START_DATES
			( CALENDAR_CODE,
			  EXCEPTION_SET_ID,
			  PERIOD_START_DATE,
			  PERIOD_SEQUENCE_NUM,
			  PERIOD_NAME,
			  NEXT_DATE,
			  PRIOR_DATE,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.CALENDAR_CODE,
			  c_rec.EXCEPTION_SET_ID,
			  c_rec.PERIOD_START_DATE,
			  c_rec.PERIOD_SEQUENCE_NUM,
			  c_rec.PERIOD_NAME,
			  c_rec.NEXT_DATE,
			  c_rec.PRIOR_DATE,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION

			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PERIOD_START_DATES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PERIOD_START_DATES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'EXCEPTION_SET_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR( c_rec.EXCEPTION_SET_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'PERIOD_START_DATE');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.PERIOD_START_DATE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

			    END IF;
			END;

			END LOOP;

			COMMIT;

			c_count:= 0;

			FOR c_rec IN c3 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

			UPDATE MSC_CAL_YEAR_START_DATES
			SET
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE CALENDAR_CODE= c_rec.CALENDAR_CODE
			  AND EXCEPTION_SET_ID= c_rec.EXCEPTION_SET_ID
			  AND YEAR_START_DATE= c_rec.YEAR_START_DATE
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			END IF;


			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_CAL_YEAR_START_DATES
			( CALENDAR_CODE,
			  EXCEPTION_SET_ID,
			  YEAR_START_DATE,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.CALENDAR_CODE,
			  c_rec.EXCEPTION_SET_ID,
			  c_rec.YEAR_START_DATE,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION
			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CAL_YEAR_START_DATES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CAL_YEAR_START_DATES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'EXCEPTION_SET_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR( c_rec.EXCEPTION_SET_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'YEAR_START_DATE');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.YEAR_START_DATE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;

			END;

			END LOOP;

			COMMIT;

			c_count:= 0;

			FOR c_rec IN c4 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

			UPDATE MSC_CAL_WEEK_START_DATES
			SET
			 NEXT_DATE= c_rec.NEXT_DATE,
			 PRIOR_DATE= c_rec.PRIOR_DATE,
			 SEQ_NUM= c_rec.SEQ_NUM,
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE CALENDAR_CODE= c_rec.CALENDAR_CODE
			  AND EXCEPTION_SET_ID= c_rec.EXCEPTION_SET_ID
			  AND WEEK_START_DATE= c_rec.WEEK_START_DATE
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			END IF;

			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_CAL_WEEK_START_DATES
			( CALENDAR_CODE,
			  EXCEPTION_SET_ID,
			  WEEK_START_DATE,
			  NEXT_DATE,
			  PRIOR_DATE,
			  SEQ_NUM,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.CALENDAR_CODE,
			  c_rec.EXCEPTION_SET_ID,
			  c_rec.WEEK_START_DATE,
			  c_rec.NEXT_DATE,
			  c_rec.PRIOR_DATE,
			  c_rec.SEQ_NUM,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION
			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CAL_WEEK_START_DATES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_SET_UP');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CAL_WEEK_START_DATES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'EXCEPTION_SET_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR( c_rec.EXCEPTION_SET_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'WEEK_START_DATE');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.WEEK_START_DATE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;
			END;

			END LOOP;

			COMMIT;

   END LOAD_CALENDAR_SET_UP;

   /* CP-ACK ends */

--==================================================================

   PROCEDURE LOAD_CALENDAR_DATE IS

   CURSOR c5 IS
			SELECT
			  msrs.DEPARTMENT_ID,
			  msrs.RESOURCE_ID,
			  msrs.SHIFT_NUM,
			  msrs.CAPACITY_UNITS,
			  msrs.SR_INSTANCE_ID
			FROM MSC_ST_RESOURCE_SHIFTS msrs
			WHERE msrs.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

			   CURSOR c6 IS
			SELECT
			  mscs.CALENDAR_CODE,
			  mscs.SHIFT_NUM,
			  mscs.DAYS_ON,
			  mscs.DAYS_OFF,
			  mscs.DESCRIPTION,
			  mscs.SR_INSTANCE_ID
			FROM MSC_ST_CALENDAR_SHIFTS mscs
			WHERE mscs.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		        AND nvl(mscs.process_flag, -99) <> MSC_UTIL.G_ERROR;

			   CURSOR c7 IS
			SELECT
			  mssd.CALENDAR_CODE,
			  mssd.EXCEPTION_SET_ID,
			  mssd.SHIFT_NUM,
			  mssd.SHIFT_DATE,
			  mssd.SEQ_NUM,
			  mssd.NEXT_SEQ_NUM,
			  mssd.PRIOR_SEQ_NUM,
			  mssd.NEXT_DATE,
			  mssd.PRIOR_DATE,
			  mssd.SR_INSTANCE_ID
			FROM MSC_ST_SHIFT_DATES mssd
			WHERE mssd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

			   CURSOR c8 IS
			SELECT
			  msrc.DEPARTMENT_ID,
			  msrc.RESOURCE_ID,
			  msrc.SHIFT_NUM,
			  msrc.FROM_DATE,
			  msrc.TO_DATE,
			  msrc.FROM_TIME,
			  msrc.TO_TIME,
			  msrc.CAPACITY_CHANGE,
			  msrc.SIMULATION_SET,
			  msrc.ACTION_TYPE,
			  msrc.DELETED_FLAG,
			  msrc.SR_INSTANCE_ID
			FROM MSC_ST_RESOURCE_CHANGES msrc
			WHERE msrc.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
			ORDER BY
			      msrc.DELETED_FLAG;

			   CURSOR c9 IS
			SELECT
			  msst.CALENDAR_CODE,
			  msst.SHIFT_NUM,
			  msst.FROM_TIME,
			  msst.TO_TIME,
			  msst.SR_INSTANCE_ID
			FROM MSC_ST_SHIFT_TIMES msst
			WHERE msst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;


			   CURSOR c10 IS
			SELECT
			  msse.CALENDAR_CODE,
			  msse.SHIFT_NUM,
			  msse.EXCEPTION_SET_ID,
			  msse.EXCEPTION_DATE,
			  msse.EXCEPTION_TYPE,
			  msse.SR_INSTANCE_ID
			FROM MSC_ST_SHIFT_EXCEPTIONS msse
			WHERE msse.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

			   c_count NUMBER:= 0;
			   lv_sql_stmt  varchar2(500);
			   lv_dblink  varchar2(50);
			   lv_resource_start_time  DATE := SYSDATE;
			   lv_ret_res_ava       NUMBER ;
			   lv_dest_a2m      varchar2(128);
			   lv_instance_code  varchar2(10);
			   lv_res_avail_before_sysdate NUMBER; -- Days

			   ex_calc_res_avail         EXCEPTION;

			   BEGIN

			   if ((MSC_CL_COLLECTION.v_is_partial_refresh AND MSC_CL_COLLECTION.v_coll_prec.calendar_flag = MSC_UTIL.SYS_YES) OR
			    MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_incremental_refresh) then

			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

			MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_SHIFTS', MSC_CL_COLLECTION.v_instance_id, NULL);

			MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_CALENDAR_SHIFTS', MSC_CL_COLLECTION.v_instance_id, NULL);

			MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SHIFT_DATES', MSC_CL_COLLECTION.v_instance_id, NULL);

			MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESOURCE_CHANGES', MSC_CL_COLLECTION.v_instance_id, NULL);

			MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SHIFT_TIMES', MSC_CL_COLLECTION.v_instance_id, NULL);

			MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SHIFT_EXCEPTIONS', MSC_CL_COLLECTION.v_instance_id, NULL);

			END IF;

			c_count:= 0;

			FOR c_rec IN c5 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

			UPDATE MSC_RESOURCE_SHIFTS
			SET
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE DEPARTMENT_ID= c_rec.DEPARTMENT_ID
			  AND RESOURCE_ID= c_rec.RESOURCE_ID
			  AND SHIFT_NUM= c_rec.SHIFT_NUM
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			END IF;

			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_RESOURCE_SHIFTS
			( DEPARTMENT_ID,
			  RESOURCE_ID,
			  SHIFT_NUM,
			  CAPACITY_UNITS,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.DEPARTMENT_ID,
			  c_rec.RESOURCE_ID,
			  c_rec.SHIFT_NUM,
			  c_rec.CAPACITY_UNITS,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION
			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_SHIFTS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_SHIFTS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'DEPARTMENT_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR( c_rec.DEPARTMENT_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'RESOURCE_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.RESOURCE_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SHIFT_NUM');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SHIFT_NUM));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;

			END;

			END LOOP;

			COMMIT;

			c_count:= 0;

			FOR c_rec IN c6 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

			UPDATE MSC_CALENDAR_SHIFTS
			SET
			 DAYS_ON= c_rec.DAYS_ON,
			 DAYS_OFF= c_rec.DAYS_OFF,
			 DESCRIPTION= c_rec.DESCRIPTION,
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE CALENDAR_CODE= c_rec.CALENDAR_CODE
			  AND SHIFT_NUM= c_rec.SHIFT_NUM
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			END IF;

			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_CALENDAR_SHIFTS
			( CALENDAR_CODE,
			  SHIFT_NUM,
			  DAYS_ON,
			  DAYS_OFF,
			  DESCRIPTION,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.CALENDAR_CODE,
			  c_rec.SHIFT_NUM,
			  c_rec.DAYS_ON,
			  c_rec.DAYS_OFF,
			  c_rec.DESCRIPTION,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION

			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDAR_SHIFTS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_CALENDAR_SHIFTS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SHIFT_NUM');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SHIFT_NUM));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;

			END;

			END LOOP;

			COMMIT;

			c_count:= 0;

			FOR c_rec IN c7 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

			UPDATE MSC_SHIFT_DATES
			SET
			 SEQ_NUM= c_rec.SEQ_NUM,
			 NEXT_SEQ_NUM= c_rec.NEXT_SEQ_NUM,
			 PRIOR_SEQ_NUM= c_rec.PRIOR_SEQ_NUM,
			 NEXT_DATE= c_rec.NEXT_DATE,
			 PRIOR_DATE= c_rec.PRIOR_DATE,
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE CALENDAR_CODE= c_rec.CALENDAR_CODE
			  AND EXCEPTION_SET_ID= c_rec.EXCEPTION_SET_ID
			  AND SHIFT_NUM= c_rec.SHIFT_NUM
			  AND SHIFT_DATE= c_rec.SHIFT_DATE
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			END IF;

			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_SHIFT_DATES
			( CALENDAR_CODE,
			  EXCEPTION_SET_ID,
			  SHIFT_NUM,
			  SHIFT_DATE,
			  SEQ_NUM,
			  NEXT_SEQ_NUM,
			  PRIOR_SEQ_NUM,
			  NEXT_DATE,
			  PRIOR_DATE,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.CALENDAR_CODE,
			  c_rec.EXCEPTION_SET_ID,
			  c_rec.SHIFT_NUM,
			  c_rec.SHIFT_DATE,
			  c_rec.SEQ_NUM,
			  c_rec.NEXT_SEQ_NUM,
			  c_rec.PRIOR_SEQ_NUM,
			  c_rec.NEXT_DATE,
			  c_rec.PRIOR_DATE,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION
			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SHIFT_DATES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SHIFT_DATES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'EXCEPTION_SET_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.EXCEPTION_SET_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SHIFT_DATE');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SHIFT_DATE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SHIFT_NUM');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SHIFT_NUM));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;

			END;

			END LOOP;

			COMMIT;

			c_count:= 0;

			FOR c_rec IN c8 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh AND c_rec.DELETED_FLAG= MSC_UTIL.SYS_YES THEN

			  -- set SR_INSTANCE_ID to negative to indicate a SOFT delete

			DELETE MSC_RESOURCE_CHANGES
			WHERE DEPARTMENT_ID= c_rec.DEPARTMENT_ID
			  AND RESOURCE_ID= c_rec.RESOURCE_ID
			  AND SHIFT_NUM= c_rec.SHIFT_NUM
			  AND FROM_DATE= c_rec.FROM_DATE
			  AND NVL(TO_DATE,MSC_UTIL.NULL_DATE)= NVL(c_rec.TO_DATE,MSC_UTIL.NULL_DATE)
			  AND NVL(FROM_TIME,MSC_UTIL.NULL_VALUE)= NVL(c_rec.FROM_TIME,MSC_UTIL.NULL_VALUE)
			  AND NVL(TO_TIME,MSC_UTIL.NULL_VALUE)= NVL(c_rec.TO_TIME,MSC_UTIL.NULL_VALUE)
			  AND SIMULATION_SET= c_rec.SIMULATION_SET
			  AND ACTION_TYPE= c_rec.ACTION_TYPE
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			ELSE

			INSERT INTO MSC_RESOURCE_CHANGES
			( DEPARTMENT_ID,
			  RESOURCE_ID,
			  SHIFT_NUM,
			  FROM_DATE,
			  TO_DATE,
			  FROM_TIME,
			  TO_TIME,
			  CAPACITY_CHANGE,
			  SIMULATION_SET,
			  ACTION_TYPE,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.DEPARTMENT_ID,
			  c_rec.RESOURCE_ID,
			  c_rec.SHIFT_NUM,
			  c_rec.FROM_DATE,
			  c_rec.TO_DATE,
			  c_rec.FROM_TIME,
			  c_rec.TO_TIME,
			  c_rec.CAPACITY_CHANGE,
			  c_rec.SIMULATION_SET,
			  c_rec.ACTION_TYPE,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION

			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_CHANGES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_CHANGES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'DEPARTMENT_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.DEPARTMENT_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'RESOURCE_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.RESOURCE_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SHIFT_NUM');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SHIFT_NUM));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'ACTION_TYPE');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.ACTION_TYPE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SIMULATION_SET');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SIMULATION_SET);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;

			END;

			END LOOP;

			/*ds change change start */
			 MSC_CL_BOM_ODS_LOAD.LOAD_RES_INST_CHANGE;
			/*ds change change end */

			COMMIT;

			c_count:= 0;

			FOR c_rec IN c9 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

			UPDATE MSC_SHIFT_TIMES
			SET
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE CALENDAR_CODE= c_rec.CALENDAR_CODE
			  AND SHIFT_NUM= c_rec.SHIFT_NUM
			  AND FROM_TIME= c_rec.FROM_TIME
			  AND TO_TIME= c_rec.TO_TIME
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			END IF;

			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_SHIFT_TIMES
			( CALENDAR_CODE,
			  SHIFT_NUM,
			  FROM_TIME,
			  TO_TIME,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.CALENDAR_CODE,
			  c_rec.SHIFT_NUM,
			  c_rec.FROM_TIME,
			  c_rec.TO_TIME,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION
			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SHIFT_TIMES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SHIFT_TIMES');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SHIFT_NUM');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SHIFT_NUM));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_TIME');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.FROM_TIME));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_TIME');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.TO_TIME));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;

			END;

			END LOOP;

			COMMIT;

			c_count:= 0;

			FOR c_rec IN c10 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

			UPDATE MSC_SHIFT_EXCEPTIONS
			SET
			 EXCEPTION_TYPE= c_rec.EXCEPTION_TYPE,
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE CALENDAR_CODE= c_rec.CALENDAR_CODE
			  AND SHIFT_NUM= c_rec.SHIFT_NUM
			  AND EXCEPTION_SET_ID= c_rec.EXCEPTION_SET_ID
			  AND EXCEPTION_DATE= c_rec.EXCEPTION_DATE
			  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

			END IF;

			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

			INSERT INTO MSC_SHIFT_EXCEPTIONS
			( CALENDAR_CODE,
			  SHIFT_NUM,
			  EXCEPTION_SET_ID,
			  EXCEPTION_DATE,
			  EXCEPTION_TYPE,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.CALENDAR_CODE,
			  c_rec.SHIFT_NUM,
			  c_rec.EXCEPTION_SET_ID,
			  c_rec.EXCEPTION_DATE,
			  c_rec.EXCEPTION_TYPE,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION
			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SHIFT_EXCEPTIONS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SHIFT_EXCEPTIONS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'CALENDAR_CODE');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.CALENDAR_CODE);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'EXCEPTION_DATE');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.EXCEPTION_DATE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'EXCEPTION_SET_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.EXCEPTION_SET_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SHIFT_NUM');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SHIFT_NUM));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;
			END;

			END LOOP;

			COMMIT;
			end if;

			if ((MSC_CL_COLLECTION.v_is_partial_refresh AND MSC_CL_COLLECTION.v_coll_prec.bom_flag = MSC_UTIL.SYS_YES) OR
			    MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_incremental_refresh) then

			            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
			            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_BOM_ODS_LOAD.LOAD_RESOURCE');
			            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
			            if (MSC_CL_COLLECTION.v_bom_refresh_type <> 3) then
			            	MSC_CL_BOM_ODS_LOAD.LOAD_RESOURCE;
			            end if ;
			end if;
			IF MSC_CL_COLLECTION.v_recalc_nra= MSC_UTIL.SYS_YES THEN
			       IF MSC_CL_COLLECTION.v_discrete_flag= MSC_UTIL.SYS_YES  THEN
			          BEGIN
			             IF  MSC_CL_COLLECTION.v_instance_type = MSC_UTIL.G_INS_OTHER THEN
			                MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL',
			                                  MSC_CL_COLLECTION.v_instance_id, -1);
			                MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL',
			                                  MSC_CL_COLLECTION.v_instance_id, -1);
			             END IF;

			   	     SELECT DECODE(M2A_DBLINK,
			                           NULL,'',
			                           '@'||M2A_DBLINK),
			                    DECODE( A2M_DBLINK,
			                           NULL,MSC_UTIL.NULL_DBLINK,
			                           A2M_DBLINK),
			                    INSTANCE_CODE
			             INTO   lv_dblink,
			    	         lv_dest_a2m,
			    	         lv_instance_code
			             FROM   MSC_APPS_INSTANCES
			             WHERE  INSTANCE_ID=MSC_CL_COLLECTION.v_instance_id;

			             lv_res_avail_before_sysdate := nvl(TO_NUMBER(FND_PROFILE.VAlUE('MSC_RES_AVAIL_BEFORE_SYSDAT')),1);
			             IF MSC_CL_COLLECTION.v_instance_type <> MSC_UTIL.G_INS_OTHER  THEN
			                lv_sql_stmt:= 'SELECT nvl(mar.LRD,sysdate)- '||lv_res_avail_before_sysdate
			                            ||' FROM MRP_AP_APPS_INSTANCES_ALL'||lv_dblink||' mar'
			                            ||' WHERE INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id
			                            ||' AND INSTANCE_CODE = '''||lv_instance_code||''''
			                            ||' AND nvl(A2M_DBLINK,'''||MSC_UTIL.NULL_DBLINK||''') = '''||lv_dest_a2m||'''' ;
			                EXECUTE IMMEDIATE lv_sql_stmt INTO lv_resource_start_time;
			             END IF;
			             IF MSC_CL_COLLECTION.v_instance_type = MSC_UTIL.G_INS_OTHER  THEN
			   	        lv_resource_start_time := lv_resource_start_time - nvl(lv_res_avail_before_sysdate,1);
			   	     END IF;

			             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'@@before net res avai : debug 1');
			   	     lv_ret_res_ava:=MSC_RESOURCE_AVAILABILITY.CALC_RESOURCE_AVAILABILITY(lv_resource_start_time,MSC_CL_COLLECTION.v_coll_prec.org_group_flag,FALSE);

			             IF lv_ret_res_ava = 2 THEN
			                FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
			                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
			                MSC_CL_COLLECTION.v_warning_flag:=MSC_UTIL.SYS_YES;
			   	     ELSIF lv_ret_res_ava <> 0 THEN
			                FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
			                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
			                RAISE ex_calc_res_avail;

			                --  ERRBUF:= FND_MESSAGE.GET;
			                --  RETCODE:= G_ERROR;

			                -- ROLLBACK WORK TO SAVEPOINT WORKERS_COMMITTED;
			             END IF;

			          EXCEPTION
			             WHEN OTHERS THEN
			                RAISE;
			          END;
			       END IF;

			END IF;

	END LOAD_CALENDAR_DATE;

		--=============  COLLECT Trading Partners ==================================

		   PROCEDURE LOAD_TRADING_PARTNER IS

		   lv_sql_stmt       VARCHAR2(5000);

		   CURSOR c1 IS
		SELECT
		/* SCE Change starts */
		  decode(mc.COMPANY_ID, MSC_CL_COLLECTION.G_MY_COMPANY_ID, null, mc.COMPANY_ID) COMPANY_ID ,
		/* SCE change ends */
		  mst.ORGANIZATION_CODE,
		  mst.ORGANIZATION_TYPE,
		  mst.SR_TP_ID,
		  mst.DISABLE_DATE,
		  mst.STATUS,
		  mst.MASTER_ORGANIZATION,
		  mst.SOURCE_ORG_ID,
		  mst.WEIGHT_UOM,
		  mst.MAXIMUM_WEIGHT,
		  mst.VOLUME_UOM,
		  mst.MAXIMUM_VOLUME,
		  mst.PARTNER_TYPE,
		  mst.PARTNER_NAME,
		  mst.PARTNER_NUMBER,
		  mst.CALENDAR_CODE,
		  mst.CURRENCY_CODE,
		  mst.CALENDAR_EXCEPTION_SET_ID,
		  mst.OPERATING_UNIT,
		  mst.SR_INSTANCE_ID,
		  mst.PROJECT_REFERENCE_ENABLED,
		  mst.PROJECT_CONTROL_LEVEL,
		  mst.DEMAND_LATENESS_COST,
		  mst.SUPPLIER_CAP_OVERUTIL_COST,
		  mst.RESOURCE_CAP_OVERUTIL_COST,
		  mst.TRANSPORT_CAP_OVER_UTIL_COST,
		  mst.DEFAULT_ATP_RULE_ID,
		  mst.DEFAULT_DEMAND_CLASS,
		  mst.MATERIAL_ACCOUNT,
		  mst.EXPENSE_ACCOUNT,
		  tilc.TP_ID       MODELED_CUSTOMER_ID,
		  tsilc.TP_SITE_ID MODELED_CUSTOMER_SITE_ID,
		  tils.TP_ID       MODELED_SUPPLIER_ID,
		  tsils.TP_SITE_ID MODELED_SUPPLIER_SITE_ID,
		  mst.USE_PHANTOM_ROUTINGS,
		  mst.INHERIT_PHANTOM_OP_SEQ,
		  mst.INHERIT_OC_OP_SEQ_NUM,
		  mst.BUSINESS_GROUP_ID,
		  mst.LEGAL_ENTITY,
		  mst.SET_OF_BOOKS_ID,
		  mst.CHART_OF_ACCOUNTS_ID,
		  mst.BUSINESS_GROUP_NAME,
		  mst.LEGAL_ENTITY_NAME,
          mst.OPERATING_UNIT_NAME,
          mst.subcontracting_source_org
		FROM MSC_TP_ID_LID tilc,
		     MSC_TP_ID_LID tils,
		     MSC_TP_SITE_ID_LID tsilc,
		     MSC_TP_SITE_ID_LID tsils,
		     MSC_ST_TRADING_PARTNERS mst,
			 MSC_COMPANIES MC
		WHERE mst.PARTNER_TYPE= 3
		/* SCE Change starts */
		  AND nvl(mst.company_name, MSC_CL_COLLECTION.v_my_company_name) = MC.company_name
		  -- AND nvl( mst.company_id, -1) = -1 -- commented for aerox
		/* SCE Change Ends */
		  AND mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND tilc.SR_INSTANCE_ID(+)= MSC_CL_COLLECTION.v_instance_id
		  AND tilc.PARTNER_TYPE(+)= 2
		  AND tilc.SR_TP_ID(+)= mst.MODELED_CUSTOMER_ID
		  AND tils.SR_INSTANCE_ID(+)= MSC_CL_COLLECTION.v_instance_id
		  AND tils.PARTNER_TYPE(+)= 1
		  AND tils.SR_TP_ID(+)= mst.MODELED_SUPPLIER_ID
		  AND tsilc.SR_INSTANCE_ID(+)= MSC_CL_COLLECTION.v_instance_id
		  AND tsilc.PARTNER_TYPE(+)= 2
		  AND tsilc.SR_TP_SITE_ID(+)= mst.MODELED_CUSTOMER_SITE_ID
		  AND tsils.SR_INSTANCE_ID(+)= MSC_CL_COLLECTION.v_instance_id
		  AND tsils.PARTNER_TYPE(+)= 1
		  AND tsils.SR_TP_SITE_ID(+)= mst.MODELED_SUPPLIER_SITE_ID;


		   CURSOR c2 IS
		SELECT
		  mtp.PARTNER_ID,
		  substrb(msts.PARTNER_ADDRESS,1,1600) PARTNER_ADDRESS,--added for the NLS bug3463401
		  msts.SR_TP_ID,
		  msts.SR_TP_SITE_ID,
		  msts.SR_INSTANCE_ID,
		  msts.TP_SITE_CODE,
		  msts.LOCATION,
		  msts.LONGITUDE,
		  msts.LATITUDE
		FROM MSC_TRADING_PARTNERS mtp,
		     MSC_ST_TRADING_PARTNER_SITES msts
		WHERE msts.PARTNER_TYPE= 3
		  AND msts.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND mtp.SR_TP_ID= msts.SR_TP_ID
		  AND mtp.PARTNER_TYPE= 3
		  AND mtp.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

		/* For bug#2198339 modified this cursor to bring data only for Vendors-Customers */
		   CURSOR c3 IS
		SELECT DISTINCT
		   msta.LOCATION_ID,
		   msta.LOCATION_CODE,
		   til.TP_ID       PARTNER_ID,
		   tsil.TP_SITE_ID PARTNER_SITE_ID,
		   msta.organization_id,
		   msta.SR_INSTANCE_ID
		FROM MSC_TP_ID_LID til,
		     MSC_TP_SITE_ID_LID tsil,
		     MSC_ST_LOCATION_ASSOCIATIONS  msta
		WHERE til.SR_INSTANCE_ID= msta.SR_INSTANCE_ID
		  AND til.SR_TP_ID= msta.SR_TP_ID
		  AND til.PARTNER_TYPE= msta.PARTNER_TYPE
		  AND tsil.SR_INSTANCE_ID= msta.SR_INSTANCE_ID
		  AND tsil.SR_TP_SITE_ID= msta.SR_TP_SITE_ID
		  AND tsil.PARTNER_TYPE= msta.PARTNER_TYPE
		  AND msta.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND msta.PARTNER_TYPE IN (1,2);

		   CURSOR c4 IS
		SELECT
		   pc.PARTNER_TYPE,
		   DECODE( pc.PARTNER_TYPE,
		           1, til.TP_ID,
		           2, til.TP_ID,
		           4, pc.PARTNER_ID) PARTNER_ID,
		   DECODE( pc.PARTNER_TYPE,
		           1, tsil.TP_SITE_ID,
		           2, tsil.TP_SITE_ID,
		           NULL) PARTNER_SITE_ID,
		   pc.NAME,
		   pc.DISPLAY_NAME,
		   pc.EMAIL,
		   pc.FAX,
		   pc.ENABLED_FLAG,
		   pc.DELETED_FLAG
		 FROM MSC_TP_ID_LID til,
		      MSC_TP_SITE_ID_LID tsil,
		      MSC_ST_PARTNER_CONTACTS pc
		WHERE pc.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND pc.DELETED_FLAG in (1, 2)
		  AND til.sr_tp_id(+)= pc.partner_id
		  AND til.partner_type(+)= DECODE( pc.PARTNER_TYPE,1,1,2,2,NULL)
		  AND til.sr_instance_id(+)= MSC_CL_COLLECTION.v_instance_id
		  AND tsil.sr_tp_site_id(+)= pc.partner_site_id
		  AND tsil.partner_type(+)= DECODE( pc.PARTNER_TYPE,1,1,2,2,NULL)
		  AND tsil.sr_instance_id(+)= MSC_CL_COLLECTION.v_instance_id
		ORDER BY
		      1,2,3,4 ASC;

		/* For bug#2198339 added this cursor to bring Locations associations data only for Organizations */
		   CURSOR c5 IS
		SELECT
		   mtps.PARTNER_ID,
		   msta.LOCATION_ID,
		   msta.LOCATION_CODE,
		   msta.SR_TP_ID ORGANIZATION_ID,
		   msta.LOCATION_ID PARTNER_SITE_ID,
		   msta.SR_INSTANCE_ID
		FROM MSC_TRADING_PARTNERS mtps,
		     MSC_ST_LOCATION_ASSOCIATIONS  msta
		WHERE msta.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND msta.partner_type  = 3
		  AND msta.SR_INSTANCE_ID= mtps.SR_INSTANCE_ID
		  AND msta.SR_TP_ID= mtps.SR_TP_ID
		  AND msta.PARTNER_TYPE= mtps.PARTNER_TYPE;

		   lv_old_partner_type     NUMBER:=0;
		   lv_old_partner_id       NUMBER:=0;
		   lv_old_partner_site_id  NUMBER:=0;

		   c_count NUMBER:= 0;

		   TYPE OrgCurType IS REF CURSOR;
		   c_org_exist     OrgCurType;
		   lv_exist        pls_integer;

		   BEGIN

		-- Organization

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.v_is_cont_refresh) THEN

		   DELETE MSC_TRADING_PARTNERS
		    WHERE sr_instance_id= MSC_CL_COLLECTION.v_instance_id
		      AND partner_type=3
		      AND nvl(ORG_SUPPLIER_MAPPED,'N') <> 'Y';

		-- MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_TRADING_PARTNERS', MSC_CL_COLLECTION.v_instance_id, NULL,
		--                   'AND PARTNER_TYPE=3');

		END IF;

		FOR c_rec IN c1 LOOP

		BEGIN

		lv_sql_stmt :=
		'UPDATE MSC_TRADING_PARTNERS '
		||'  SET '
		||'  COMPANY_ID                  = :company_id,'
		||'  ORGANIZATION_CODE           = :ORG_CODE,'
		||'  ORGANIZATION_TYPE           = :ORG_TYPE,'
		||'  DISABLE_DATE                = :DISABLE_DATE,'
		||'  STATUS                      = :STATUS,'
		||'  MASTER_ORGANIZATION         = :MASTER_ORG,'
		||'  SOURCE_ORG_ID               = :SOURCE_ORG_ID,'
		||'  WEIGHT_UOM                  = :WEIGHT_UOM,'
		||'  MAXIMUM_WEIGHT              = :MAXIMUM_WEIGHT,'
		||'  VOLUME_UOM                  = :VOLUME_UOM,'
		||'  MAXIMUM_VOLUME              = :MAXIMUM_VOLUME,'
		||'  PARTNER_NAME                = :PARTNER_NAME,'
		||'  PARTNER_NUMBER              = :PARTNER_NUMBER,'
		||'  CALENDAR_CODE               = :CALENDAR_CODE,'
		||'  CURRENCY_CODE               = :CURRENCY_CODE,'
		||'  CALENDAR_EXCEPTION_SET_ID   = :CAL_EXP_SET_ID,'
		||'  OPERATING_UNIT              = :OPERATING_UNIT,'
		||'  PROJECT_REFERENCE_ENABLED   = :PROJ_REF_ENABLED,'
		||'  PROJECT_CONTROL_LEVEL       = :PROJ_CON_LEVEL,'
		||'  DEMAND_LATENESS_COST        = :DMD_LATE_COST,'
		||'  SUPPLIER_CAP_OVERUTIL_COST  = :SUPP_CAP_OVR_COST,'
		||'  RESOURCE_CAP_OVERUTIL_COST  = :RES_CAP_OVER_COST,'
		||'  TRANSPORT_CAP_OVER_UTIL_COST= :TR_CAP_OV_UTIL_COST,'
		||'  MODELED_CUSTOMER_ID         = decode(ORG_SUPPLIER_MAPPED,''Y'',MODELED_CUSTOMER_ID,:MOD_CUS_ID),'
		||'  MODELED_CUSTOMER_SITE_ID    = decode(ORG_SUPPLIER_MAPPED,''Y'',MODELED_CUSTOMER_SITE_ID,:MOD_CUS_SITE_ID),'
		||'  MODELED_SUPPLIER_ID         = decode(ORG_SUPPLIER_MAPPED,''Y'',MODELED_SUPPLIER_ID,:MOD_SUPP_ID),'
		||'  MODELED_SUPPLIER_SITE_ID    = decode(ORG_SUPPLIER_MAPPED,''Y'',MODELED_SUPPLIER_SITE_ID,:MOD_SUPP_SITE_ID),'
		||'  USE_PHANTOM_ROUTINGS        = :USE_PH_ROUTINGS,'
		||'  INHERIT_PHANTOM_OP_SEQ      = :INH_PH_OP_SEQ,'
		||'  INHERIT_OC_OP_SEQ_NUM       = :INH_OC_OP_SEQ_NUM,'
		||'  DEFAULT_ATP_RULE_ID         = :DEF_ATP_RULE_ID,'
		||'  DEFAULT_DEMAND_CLASS        = :DEF_DEMAND_CLASS,'
		||'  MATERIAL_ACCOUNT            = :MATERIAL_ACCOUNT,'
		||'  EXPENSE_ACCOUNT             = :EXPENSE_ACCOUNT,'
		||'  SR_BUSINESS_GROUP_ID        = :BUSINESS_GROUP_ID,'
		||'  SR_LEGAL_ENTITY             = :LEGAL_ENTITY,'
		||'  SR_SET_OF_BOOKS_ID          = :SET_OF_BOOKS_ID,'
		||'  SR_CHART_OF_ACCOUNTS_ID     = :CHART_OF_ACCOUNTS_ID,'
		||'  BUSINESS_GROUP_NAME         = :BUSINESS_GROUP_NAME,'
		||'  LEGAL_ENTITY_NAME           = :LEGAL_ENTITY_NAME,'
		||'  OPERATING_UNIT_NAME         = :OPERATING_UNIT_NAME,'
		||'  SUBCONTRACTING_SOURCE_ORG   = :SUBCONTRACTING_SOURCE_ORG,'
		||'  REFRESH_NUMBER              = :v_last_collection_id,'
		||'  LAST_UPDATE_DATE            = :v_current_date,'
		||'  LAST_UPDATED_BY             = :v_current_user'
		||' WHERE SR_TP_ID               = :SR_TP_ID'
		||'  AND SR_INSTANCE_ID          = :SR_INSTANCE_ID'
		||'  AND PARTNER_TYPE            = :PARTNER_TYPE';


		      EXECUTE IMMEDIATE lv_sql_stmt
		              USING     c_rec.company_id,
		                        c_rec.ORGANIZATION_CODE,
		                        c_rec.ORGANIZATION_TYPE,
		                        c_rec.DISABLE_DATE,
		                        c_rec.STATUS,
		                        c_rec.MASTER_ORGANIZATION,
		                        c_rec.SOURCE_ORG_ID,
		                        c_rec.WEIGHT_UOM,
		                        c_rec.MAXIMUM_WEIGHT,
		                        c_rec.VOLUME_UOM,
		                        c_rec.MAXIMUM_VOLUME,
		                        c_rec.PARTNER_NAME,
		                        c_rec.PARTNER_NUMBER,
		                        c_rec.CALENDAR_CODE,
		                        c_rec.CURRENCY_CODE,
		                        c_rec.CALENDAR_EXCEPTION_SET_ID,
		                        c_rec.OPERATING_UNIT,
		                        c_rec.PROJECT_REFERENCE_ENABLED,
		                        c_rec.PROJECT_CONTROL_LEVEL,
		                        c_rec.DEMAND_LATENESS_COST,
		                        c_rec.SUPPLIER_CAP_OVERUTIL_COST,
		                        c_rec.RESOURCE_CAP_OVERUTIL_COST,
		                        c_rec.TRANSPORT_CAP_OVER_UTIL_COST,
		                        c_rec.MODELED_CUSTOMER_ID,
		                        c_rec.MODELED_CUSTOMER_SITE_ID,
		                        c_rec.MODELED_SUPPLIER_ID,
		                        c_rec.MODELED_SUPPLIER_SITE_ID,
		                        c_rec.USE_PHANTOM_ROUTINGS,
		                        c_rec.INHERIT_PHANTOM_OP_SEQ,
				                c_rec.INHERIT_OC_OP_SEQ_NUM,
		                        c_rec.DEFAULT_ATP_RULE_ID,
		                        c_rec.DEFAULT_DEMAND_CLASS,
		                        c_rec.MATERIAL_ACCOUNT,
		                        c_rec.EXPENSE_ACCOUNT,
		                        c_rec.BUSINESS_GROUP_ID,
		                        c_rec.LEGAL_ENTITY,
		                        c_rec.SET_OF_BOOKS_ID,
		                        c_rec.CHART_OF_ACCOUNTS_ID,
		                        c_rec.BUSINESS_GROUP_NAME,
		                        c_rec.LEGAL_ENTITY_NAME,
		                        c_rec.OPERATING_UNIT_NAME,
		                        c_rec.SUBCONTRACTING_SOURCE_ORG,
		                        MSC_CL_COLLECTION.v_last_collection_id,
		                        MSC_CL_COLLECTION.v_current_date,
		                        MSC_CL_COLLECTION.v_current_user,
		                        c_rec.SR_TP_ID,
		                        c_rec.SR_INSTANCE_ID,
		                        c_rec.PARTNER_TYPE;


		IF SQL%NOTFOUND THEN

		INSERT INTO MSC_TRADING_PARTNERS
		( PARTNER_ID,
		/* SCE change starts */
		  COMPANY_ID,
		/* SCE change ends */
		  ORGANIZATION_CODE,
		  ORGANIZATION_TYPE,
		  SR_TP_ID,
		  DISABLE_DATE,
		  STATUS,
		  MASTER_ORGANIZATION,
		  SOURCE_ORG_ID,
		  WEIGHT_UOM,
		  MAXIMUM_WEIGHT,
		  VOLUME_UOM,
		  MAXIMUM_VOLUME,
		  PARTNER_TYPE,
		  PARTNER_NAME,
		  PARTNER_NUMBER,
		  CALENDAR_CODE,
		  CURRENCY_CODE,
		  CALENDAR_EXCEPTION_SET_ID,
		  OPERATING_UNIT,
		  SR_INSTANCE_ID,
		  PROJECT_REFERENCE_ENABLED,
		  PROJECT_CONTROL_LEVEL,
		  DEMAND_LATENESS_COST,
		  SUPPLIER_CAP_OVERUTIL_COST,
		  RESOURCE_CAP_OVERUTIL_COST,
		  TRANSPORT_CAP_OVER_UTIL_COST,
		  MODELED_CUSTOMER_ID,
		  MODELED_CUSTOMER_SITE_ID,
		  MODELED_SUPPLIER_ID,
		  MODELED_SUPPLIER_SITE_ID,
		  USE_PHANTOM_ROUTINGS,
		  INHERIT_PHANTOM_OP_SEQ,
		  DEFAULT_ATP_RULE_ID,
		  DEFAULT_DEMAND_CLASS,
		  MATERIAL_ACCOUNT,
		  EXPENSE_ACCOUNT,
		  SR_BUSINESS_GROUP_ID,
		  SR_LEGAL_ENTITY,
		  SR_SET_OF_BOOKS_ID,
		  SR_CHART_OF_ACCOUNTS_ID,
		  BUSINESS_GROUP_NAME,
		  LEGAL_ENTITY_NAME,
		  OPERATING_UNIT_NAME,
		  SUBCONTRACTING_SOURCE_ORG,
		  REFRESH_NUMBER,
		  INHERIT_OC_OP_SEQ_NUM,
		  LAST_UPDATE_DATE,
		  LAST_UPDATED_BY,
		  CREATION_DATE,
		  CREATED_BY)
		VALUES
		( MSC_Trading_Partners_S.NEXTVAL,
		/* SCE change starts */
		  c_rec.company_id,
		/* SCE change ends */
		  c_rec.ORGANIZATION_CODE,
		  c_rec.ORGANIZATION_TYPE,
		  c_rec.SR_TP_ID,
		  c_rec.DISABLE_DATE,
		  c_rec.STATUS,
		  c_rec.MASTER_ORGANIZATION,
		  c_rec.SOURCE_ORG_ID,
		  c_rec.WEIGHT_UOM,
		  c_rec.MAXIMUM_WEIGHT,
		  c_rec.VOLUME_UOM,
		  c_rec.MAXIMUM_VOLUME,
		  c_rec.PARTNER_TYPE,
		  c_rec.PARTNER_NAME,
		  c_rec.PARTNER_NUMBER,
		  c_rec.CALENDAR_CODE,
		  c_rec.CURRENCY_CODE,
		  c_rec.CALENDAR_EXCEPTION_SET_ID,
		  c_rec.OPERATING_UNIT,
		  c_rec.SR_INSTANCE_ID,
		  c_rec.PROJECT_REFERENCE_ENABLED,
		  c_rec.PROJECT_CONTROL_LEVEL,
		  c_rec.DEMAND_LATENESS_COST,
		  c_rec.SUPPLIER_CAP_OVERUTIL_COST,
		  c_rec.RESOURCE_CAP_OVERUTIL_COST,
		  c_rec.TRANSPORT_CAP_OVER_UTIL_COST,
		  c_rec.MODELED_CUSTOMER_ID,
		  c_rec.MODELED_CUSTOMER_SITE_ID,
		  c_rec.MODELED_SUPPLIER_ID,
		  c_rec.MODELED_SUPPLIER_SITE_ID,
		  c_rec.USE_PHANTOM_ROUTINGS,
		  c_rec.INHERIT_PHANTOM_OP_SEQ,
		  c_rec.DEFAULT_ATP_RULE_ID,
		  c_rec.DEFAULT_DEMAND_CLASS,
		  c_rec.MATERIAL_ACCOUNT,
		  c_rec.EXPENSE_ACCOUNT,
		  c_rec.BUSINESS_GROUP_ID,
		  c_rec.LEGAL_ENTITY,
		  c_rec.SET_OF_BOOKS_ID,
		  c_rec.CHART_OF_ACCOUNTS_ID,
		  c_rec.BUSINESS_GROUP_NAME,
		  c_rec.LEGAL_ENTITY_NAME,
		  c_rec.OPERATING_UNIT_NAME,
		  c_rec.SUBCONTRACTING_SOURCE_ORG,
		  MSC_CL_COLLECTION.v_last_collection_id,
		  c_rec.INHERIT_OC_OP_SEQ_NUM,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user );

		/************** LEGACY_CHANGE_START*************************/

		--  added for Legacy and Exchange

		  IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN       -- change for l-flow

		  lv_exist := 0;

		    OPEN c_org_exist FOR
		      '  select 1   from MSC_INSTANCE_ORGS '
		      ||' where ORGANIZATION_ID =  :sr_tp_id '
		      ||' and SR_INSTANCE_ID = :instance_id ' USING  c_rec.SR_TP_ID, c_rec.SR_INSTANCE_ID;

		    FETCH c_org_exist into lv_exist  ;
		    CLOSE c_org_exist;

		 IF lv_exist = 0 THEN
		  INSERT INTO MSC_INSTANCE_ORGS(
		  SR_INSTANCE_ID,
		  ORGANIZATION_ID,
		  LAST_UPDATE_DATE,
		  LAST_UPDATED_BY,
		  CREATION_DATE,
		  CREATED_BY,
		  ENABLED_FLAG)
		  VALUES
		  (c_rec.SR_INSTANCE_ID,
		  c_rec.SR_TP_ID,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  1);
		 END IF;

		   lv_exist:= 0;

		    OPEN c_org_exist FOR
		      '  select 1   from MSC_PARAMETERS '
		      ||' where ORGANIZATION_ID =  :sr_tp_id '
		      ||' and SR_INSTANCE_ID = :instance_id ' USING  c_rec.SR_TP_ID, c_rec.SR_INSTANCE_ID;

		    FETCH c_org_exist into lv_exist  ;
		    CLOSE c_org_exist;

		IF lv_exist = 0 THEN
		  INSERT INTO MSC_PARAMETERS
		 ( ORGANIZATION_ID,
		  SR_INSTANCE_ID,
		  DEMAND_TIME_FENCE_FLAG,
		  PLANNING_TIME_FENCE_FLAG,
		  OPERATION_SCHEDULE_TYPE,
		  CONSIDER_WIP,
		  CONSIDER_PO,
		  SNAPSHOT_LOCK,
		  PLAN_SAFETY_STOCK,
		  CONSIDER_RESERVATIONS,
		  PART_INCLUDE_TYPE,
		  PERIOD_TYPE,
		  NETWORK_SCHEDULING_METHOD,  /* hard coded to 1 (primary)*/
		  LAST_UPDATE_DATE,
		  LAST_UPDATED_BY,
		  CREATION_DATE,
		  CREATED_BY)
		  values
		  (c_rec.SR_TP_ID,
		  c_rec.SR_INSTANCE_ID,
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
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user );
		 END IF;

		END IF;

		/*****************LEGACY_CHANGE_ENDS************************/
		END IF;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNERS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNERS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SR_TP_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.ORGANIZATION_CODE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		COMMIT;

		-- Organization Site

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

		MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_TRADING_PARTNER_SITES', MSC_CL_COLLECTION.v_instance_id, NULL,
		                  'AND PARTNER_TYPE=3');

		END IF;

		FOR c_rec IN c2 LOOP

		BEGIN

		IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

		UPDATE MSC_TRADING_PARTNER_SITES
		SET
		 PARTNER_ADDRESS= c_rec.PARTNER_ADDRESS,
		 TP_SITE_CODE= c_rec.TP_SITE_CODE,
		 LOCATION= c_rec.LOCATION,
		 LONGITUDE= c_rec.LONGITUDE,
		 LATITUDE= c_rec.LATITUDE,
		 DELETED_FLAG= MSC_UTIL.SYS_NO,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		WHERE PARTNER_TYPE= 3
		  AND SR_TP_ID= c_rec.SR_TP_ID
		  AND SR_TP_SITE_ID= c_rec.SR_TP_SITE_ID
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID;

		END IF;

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

		INSERT INTO MSC_Trading_Partner_Sites
		( PARTNER_ID,
		  PARTNER_SITE_ID,
		  PARTNER_ADDRESS,
		  LONGITUDE,
		  LATITUDE,
		  PARTNER_TYPE,
		  SR_TP_ID,
		  SR_TP_SITE_ID,
		  SR_INSTANCE_ID,
		  TP_SITE_CODE,
		  LOCATION,
		  DELETED_FLAG,
		  REFRESH_NUMBER,
		  LAST_UPDATE_DATE,
		  LAST_UPDATED_BY,
		  CREATION_DATE,
		  CREATED_BY)
		VALUES
		( c_rec.PARTNER_ID,
		  MSC_Trading_Partner_Sites_S.NEXTVAL,
		  c_rec.PARTNER_ADDRESS,
		  c_rec.LONGITUDE,
		  c_rec.LATITUDE,
		  3,
		  c_rec.SR_TP_ID,
		  c_rec.SR_TP_SITE_ID,
		  c_rec.SR_INSTANCE_ID,
		  c_rec.TP_SITE_CODE,
		  c_rec.LOCATION,
		  MSC_UTIL.SYS_NO,
		  MSC_CL_COLLECTION.v_last_collection_id,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user );

		END IF;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNERS_SITES');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNERS_SITES');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_SITE_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SR_TP_SITE_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'LOCATION');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.LOCATION);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		COMMIT;

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.v_is_cont_refresh) THEN

		   DELETE MSC_LOCATION_ASSOCIATIONS
		    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

		-- MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_LOCATION_ASSOCIATIONS', MSC_CL_COLLECTION.v_instance_id, NULL);

		END IF;

		FOR c_rec IN c3 LOOP

		BEGIN

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.v_is_legacy_refresh OR MSC_CL_COLLECTION.v_is_cont_refresh) THEN

		INSERT INTO MSC_LOCATION_ASSOCIATIONS
		( LOCATION_ID,
		  LOCATION_CODE,
		  PARTNER_ID,
		  PARTNER_SITE_ID,
		  organization_id,
		  SR_INSTANCE_ID,
		  LAST_UPDATE_DATE,
		  LAST_UPDATED_BY,
		  CREATION_DATE,
		  CREATED_BY)
		VALUES
		( c_rec.LOCATION_ID,
		  c_rec.LOCATION_CODE,
		  c_rec.PARTNER_ID,
		  c_rec.PARTNER_SITE_ID,
		  c_rec.organization_id,
		  c_rec.SR_INSTANCE_ID,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user );

		END IF;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_LOCATION_ASSOCIATIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE

		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_LOCATION_ASSOCIATIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'LOCATION_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.LOCATION_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'LOCATION_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.LOCATION_CODE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		COMMIT;

		/*For bug# 2198339 Added this piece of code to collect location associations for Organizations */

		FOR c_rec IN c5 LOOP

		BEGIN

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.v_is_legacy_refresh OR MSC_CL_COLLECTION.v_is_cont_refresh) THEN

		INSERT INTO MSC_LOCATION_ASSOCIATIONS
		( LOCATION_ID,
		  LOCATION_CODE,
		  PARTNER_ID,
		  PARTNER_SITE_ID,
		  ORGANIZATION_ID,
		  SR_INSTANCE_ID,
		  LAST_UPDATE_DATE,
		  LAST_UPDATED_BY,
		  CREATION_DATE,
		  CREATED_BY)
		VALUES
		( c_rec.LOCATION_ID,
		  c_rec.LOCATION_CODE,
		  c_rec.PARTNER_ID,
		  c_rec.PARTNER_SITE_ID,
		  c_rec.ORGANIZATION_ID,
		  c_rec.SR_INSTANCE_ID,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user);

		END IF;

		EXCEPTION
		   WHEN OTHERS THEN
		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_LOCATION_ASSOCIATIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_LOCATION_ASSOCIATIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'LOCATION_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.LOCATION_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'LOCATION_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.LOCATION_CODE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		COMMIT;

		-- Partner Contacts

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.v_is_legacy_refresh OR MSC_CL_COLLECTION.v_is_cont_refresh) THEN

		  IF NOT MSC_CL_COLLECTION.v_is_legacy_refresh THEN
		    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_PARTNER_CONTACTS', MSC_CL_COLLECTION.v_instance_id, NULL);
		  END IF;

		FOR c_rec IN c4 LOOP

		if(MSC_CL_COLLECTION.v_is_legacy_refresh) then

		if (c_rec.DELETED_FLAG =MSC_UTIL.SYS_YES) then

			delete from MSC_PARTNER_CONTACTS where
			partner_id=c_rec.PARTNER_ID
			and nvl(partner_site_id,-99999)=nvl(c_rec.PARTNER_SITE_ID,-99999)
			and partner_type=c_rec.PARTNER_TYPE
			and SR_INSTANCE_ID =MSC_CL_COLLECTION.v_instance_id
			and c_rec.DELETED_FLAG =MSC_UTIL.SYS_YES;
		else
			UPDATE MSC_PARTNER_CONTACTS
			set Name=c_rec.NAME,
			DISPLAY_NAME =c_rec.DISPLAY_NAME,
			EMAIL = c_rec.EMAIL,
			FAX = c_rec.FAX,
			ENABLED_FLAG =c_rec.ENABLED_FLAG,
			REFRESH_NUMBER =MSC_CL_COLLECTION.v_last_collection_id,
			LAST_UPDATE_DATE = MSC_CL_COLLECTION.v_current_date,
			LAST_UPDATED_BY = MSC_CL_COLLECTION.v_current_user,
			CREATION_DATE =MSC_CL_COLLECTION.v_current_date,
			CREATED_BY =MSC_CL_COLLECTION.v_current_user
			where
			partner_id=c_rec.PARTNER_ID
			and nvl(partner_site_id,-99999)=nvl(c_rec.PARTNER_SITE_ID,-99999)
			and partner_type=c_rec.PARTNER_TYPE
			and SR_INSTANCE_ID =MSC_CL_COLLECTION.v_instance_id;
		END IF ;

		END IF ;


		IF  MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh OR  MSC_CL_COLLECTION.v_is_cont_refresh OR (SQL%NOTFOUND and c_rec.DELETED_FLAG =MSC_UTIL.SYS_NO)
		 THEN
			IF lv_old_partner_id  <> NVL(c_rec.partner_id,0)          OR
			   lv_old_partner_site_id <> NVL(c_rec.partner_site_id,0) OR
			   lv_old_partner_type <> c_rec.partner_type              THEN

			BEGIN

			INSERT INTO MSC_PARTNER_CONTACTS
			( PARTNER_ID,
			  PARTNER_SITE_ID,
			  PARTNER_TYPE,
			  NAME,
			  DISPLAY_NAME,
			  EMAIL,
			  FAX,
			  ENABLED_FLAG,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( c_rec.PARTNER_ID,
			  c_rec.PARTNER_SITE_ID,
			  c_rec.PARTNER_TYPE,
			  c_rec.NAME,
			  c_rec.DISPLAY_NAME,
			  c_rec.EMAIL,
			  c_rec.FAX,
			  c_rec.ENABLED_FLAG,
			  MSC_CL_COLLECTION.v_instance_id,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );

			EXCEPTION
			   WHEN OTHERS THEN
			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PARTNER_CONTACTS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_TRADING_PARTNER');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PARTNER_CONTACTS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.PARTNER_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_SITE_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.PARTNER_SITE_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.PARTNER_TYPE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;

			END;

		   lv_old_partner_id      :=  NVL(c_rec.partner_id,0);
		   lv_old_partner_site_id :=  NVL(c_rec.partner_site_id,0);
		   lv_old_partner_type    :=  c_rec.partner_type;

			END IF;
		END IF ;

		END LOOP;

		COMMIT;

		END IF;

		END LOAD_TRADING_PARTNER;

			--==================================================================

	   PROCEDURE LOAD_PARAMETER IS

	   CURSOR c1 IS
	SELECT
	  msp.ORGANIZATION_ID,
	  msp.DEMAND_TIME_FENCE_FLAG,
	  msp.PLANNING_TIME_FENCE_FLAG,
	  msp.OPERATION_SCHEDULE_TYPE,
	  msp.CONSIDER_WIP,
	  msp.CONSIDER_PO,
	  msp.SNAPSHOT_LOCK,
	  msp.PLAN_SAFETY_STOCK,
	  msp.CONSIDER_RESERVATIONS,
	  msp.PART_INCLUDE_TYPE,
	  msp.DEFAULT_ABC_ASSIGNMENT_GROUP,
	  msp.PERIOD_TYPE,
	  msp.RESCHED_ASSUMPTION,
	  msp.PLAN_DATE_DEFAULT_TYPE,
	  msp.INCLUDE_REP_SUPPLY_DAYS,
	  msp.INCLUDE_MDS_DAYS,
	  msp.REPETITIVE_HORIZON1,
	  msp.REPETITIVE_HORIZON2,
	  msp.REPETITIVE_BUCKET_SIZE1,
	  msp.REPETITIVE_BUCKET_SIZE2,
	  msp.REPETITIVE_BUCKET_SIZE3,
	  msp.REPETITIVE_ANCHOR_DATE,
	  msp.SR_INSTANCE_ID
	 FROM MSC_ST_PARAMETERS msp
	WHERE msp.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

	   c_count NUMBER:= 0;

	   BEGIN

	--IF MSC_CL_COLLECTION.v_is_complete_refresh THEN

	--DELETE FROM MSC_PARAMETERS
	-- WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
	--END IF;

	FOR c_rec IN c1 LOOP

	BEGIN

	UPDATE MSC_PARAMETERS
	SET
	 DEMAND_TIME_FENCE_FLAG= c_rec.DEMAND_TIME_FENCE_FLAG,
	 PLANNING_TIME_FENCE_FLAG= c_rec.PLANNING_TIME_FENCE_FLAG,
	 OPERATION_SCHEDULE_TYPE= c_rec.OPERATION_SCHEDULE_TYPE,
	 CONSIDER_WIP= c_rec.CONSIDER_WIP,
	 CONSIDER_PO= c_rec.CONSIDER_PO,
	 SNAPSHOT_LOCK= c_rec.SNAPSHOT_LOCK,
	 PLAN_SAFETY_STOCK= c_rec.PLAN_SAFETY_STOCK,
	 CONSIDER_RESERVATIONS= c_rec.CONSIDER_RESERVATIONS,
	 PART_INCLUDE_TYPE= c_rec.PART_INCLUDE_TYPE,
	 DEFAULT_ABC_ASSIGNMENT_GROUP= c_rec.DEFAULT_ABC_ASSIGNMENT_GROUP,
	 PERIOD_TYPE= c_rec.PERIOD_TYPE,
	 RESCHED_ASSUMPTION= c_rec.RESCHED_ASSUMPTION,
	 PLAN_DATE_DEFAULT_TYPE= c_rec.PLAN_DATE_DEFAULT_TYPE,
	 INCLUDE_REP_SUPPLY_DAYS= c_rec.INCLUDE_REP_SUPPLY_DAYS,
	 INCLUDE_MDS_DAYS= c_rec.INCLUDE_MDS_DAYS,
	 REPETITIVE_HORIZON1= c_rec.REPETITIVE_HORIZON1,
	 REPETITIVE_HORIZON2= c_rec.REPETITIVE_HORIZON2,
	 REPETITIVE_BUCKET_SIZE1= c_rec.REPETITIVE_BUCKET_SIZE1,
	 REPETITIVE_BUCKET_SIZE2= c_rec.REPETITIVE_BUCKET_SIZE2,
	 REPETITIVE_BUCKET_SIZE3= c_rec.REPETITIVE_BUCKET_SIZE3,
	 REPETITIVE_ANCHOR_DATE= c_rec.REPETITIVE_ANCHOR_DATE,
	 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
	 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
	WHERE SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
	  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID;
	/* Bug: 1993151 remove the collected flag from the update statement */
	--  AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

	  IF SQL%NOTFOUND THEN

	INSERT INTO MSC_PARAMETERS
	( ORGANIZATION_ID,
	  DEMAND_TIME_FENCE_FLAG,
	  PLANNING_TIME_FENCE_FLAG,
	  OPERATION_SCHEDULE_TYPE,
	  CONSIDER_WIP,
	  CONSIDER_PO,
	  SNAPSHOT_LOCK,
	  PLAN_SAFETY_STOCK,
	  CONSIDER_RESERVATIONS,
	  PART_INCLUDE_TYPE,
	  DEFAULT_ABC_ASSIGNMENT_GROUP,
	  PERIOD_TYPE,
	  RESCHED_ASSUMPTION,
	  PLAN_DATE_DEFAULT_TYPE,
	  INCLUDE_REP_SUPPLY_DAYS,
	  INCLUDE_MDS_DAYS,
	  REPETITIVE_HORIZON1,
	  REPETITIVE_HORIZON2,
	  REPETITIVE_BUCKET_SIZE1,
	  REPETITIVE_BUCKET_SIZE2,
	  REPETITIVE_BUCKET_SIZE3,
	  REPETITIVE_ANCHOR_DATE,
	  NETWORK_SCHEDULING_METHOD,  /* hard coded to 1 (primary)*/
	  COLLECTED_FLAG,
	  SR_INSTANCE_ID,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY)
	VALUES
	( c_rec.ORGANIZATION_ID,
	  c_rec.DEMAND_TIME_FENCE_FLAG,
	  c_rec.PLANNING_TIME_FENCE_FLAG,
	  c_rec.OPERATION_SCHEDULE_TYPE,
	  c_rec.CONSIDER_WIP,
	  c_rec.CONSIDER_PO,
	  c_rec.SNAPSHOT_LOCK,
	  c_rec.PLAN_SAFETY_STOCK,
	  c_rec.CONSIDER_RESERVATIONS,
	  c_rec.PART_INCLUDE_TYPE,
	  c_rec.DEFAULT_ABC_ASSIGNMENT_GROUP,
	  c_rec.PERIOD_TYPE,
	  c_rec.RESCHED_ASSUMPTION,
	  c_rec.PLAN_DATE_DEFAULT_TYPE,
	  c_rec.INCLUDE_REP_SUPPLY_DAYS,
	  c_rec.INCLUDE_MDS_DAYS,
	  c_rec.REPETITIVE_HORIZON1,
	  c_rec.REPETITIVE_HORIZON2,
	  c_rec.REPETITIVE_BUCKET_SIZE1,
	  c_rec.REPETITIVE_BUCKET_SIZE2,
	  c_rec.REPETITIVE_BUCKET_SIZE3,
	  c_rec.REPETITIVE_ANCHOR_DATE,
	  1,
	  MSC_UTIL.SYS_YES,
	  c_rec.SR_INSTANCE_ID,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user );

	  END IF;

	EXCEPTION

	   WHEN OTHERS THEN

	    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PARAMETER');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PARAMETERS');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	      RAISE;

	    ELSE

	      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PARAMETER');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_PARAMETERS');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
	      FND_MESSAGE.SET_TOKEN('VALUE',
	                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
	                                                   MSC_CL_COLLECTION.v_instance_id));
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	    END IF;

	END;

	END LOOP;

	COMMIT;

	 END LOAD_PARAMETER;


		--==================================================================

		   PROCEDURE LOAD_UOM IS

		   CURSOR c1 IS
		 select
		    msuom.UNIT_OF_MEASURE,
		    msuom.UOM_CODE,
		    msuom.UOM_CLASS,
		    msuom.BASE_UOM_FLAG,
		    msuom.DISABLE_DATE,
		    msuom.DESCRIPTION,
		    msuom.SR_INSTANCE_ID
		 from MSC_ST_UNITS_OF_MEASURE msuom
		where msuom.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		order by UNIT_OF_MEASURE;  /* use order by to avoid dead locking */

		   CURSOR c2 IS
		 select
		    NVL( t1.INVENTORY_ITEM_ID,0) INVENTORY_ITEM_ID,    -- 0 means resource
		    msucc.INVENTORY_ITEM_ID SR_INVENTORY_ITEM_ID,
		    msucc.FROM_UNIT_OF_MEASURE,
		    msucc.FROM_UOM_CODE,
		    msucc.FROM_UOM_CLASS,
		    msucc.TO_UNIT_OF_MEASURE,
		    msucc.TO_UOM_CODE,
		    msucc.TO_UOM_CLASS,
		    msucc.CONVERSION_RATE,
		    msucc.DISABLE_DATE,
		    msucc.SR_INSTANCE_ID
		 from MSC_ITEM_ID_LID t1,
		      MSC_ST_UOM_CLASS_CONVERSIONS msucc
		WHERE t1.SR_INVENTORY_ITEM_ID(+)=     msucc.Inventory_Item_ID
		  AND t1.sr_instance_id(+)= msucc.sr_instance_id
		  AND DECODE( t1.INVENTORY_ITEM_ID, NULL, msucc.Inventory_ITEM_ID,0 )= 0
		  AND msucc.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		ORDER BY
		      1,
		      msucc.FROM_UNIT_OF_MEASURE,
		      msucc.TO_UNIT_OF_MEASURE;

		   CURSOR c3 IS
		SELECT
		    msuc.UNIT_OF_MEASURE,
		    msuc.UOM_CODE,
		    msuc.UOM_CLASS,
		    NVL( t1.INVENTORY_ITEM_ID,0) Inventory_Item_ID,
		    msuc.CONVERSION_RATE,
		    msuc.DEFAULT_CONVERSION_FLAG,
		    msuc.DISABLE_DATE,
		    msuc.SR_INSTANCE_ID,
		    msuc.Inventory_Item_ID SR_Inventory_Item_ID
		 from MSC_ITEM_ID_LID t1,
		      MSC_ST_UOM_CONVERSIONS msuc
		WHERE t1.SR_INVENTORY_ITEM_ID(+)=     msuc.Inventory_Item_ID
		  AND t1.sr_instance_id(+)= msuc.sr_instance_id
		  AND DECODE( t1.INVENTORY_ITEM_ID, NULL, msuc.Inventory_ITEM_ID,0 )= 0
		  AND msuc.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		ORDER BY
		      4,1;

		   c_count NUMBER:= 0;

		   BEGIN

		/*
		IF MSC_CL_COLLECTION.v_is_complete_refresh THEN

		DELETE FROM MSC_UNITS_OF_MEASURE
		WHERE SR_INSTANCE_ID IN ( MSC_CL_COLLECTION.v_instance_id, -MSC_CL_COLLECTION.v_instance_id);

		END IF;
		*/

		c_count:= 0;

		FOR c_rec IN c1 LOOP

		BEGIN

		 UPDATE MSC_UNITS_OF_MEASURE muom
		    SET muom.UOM_CODE= c_rec.UOM_CODE,
		        muom.UOM_CLASS= c_rec.UOM_CLASS,
		        muom.BASE_UOM_FLAG= c_rec.BASE_UOM_FLAG,
		        muom.DISABLE_DATE= c_rec.DISABLE_DATE,
		        muom.DESCRIPTION= c_rec.DESCRIPTION,
		        muom.SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID,
		        muom.REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		        muom.LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		        muom.LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		  WHERE muom.UNIT_OF_MEASURE= c_rec.UNIT_OF_MEASURE;

		  IF SQL%NOTFOUND THEN

		 INSERT INTO MSC_UNITS_OF_MEASURE
		  ( UNIT_OF_MEASURE,
		    UOM_CODE,
		    UOM_CLASS,
		    BASE_UOM_FLAG,
		    DISABLE_DATE,
		    DESCRIPTION,
		    SR_INSTANCE_ID,
		    REFRESH_NUMBER,
		    LAST_UPDATE_DATE,
		    LAST_UPDATED_BY,
		    CREATION_DATE,
		    CREATED_BY)
		 VALUES
		  ( c_rec.UNIT_OF_MEASURE,
		    c_rec.UOM_CODE,
		    c_rec.UOM_CLASS,
		    c_rec.BASE_UOM_FLAG,
		    c_rec.DISABLE_DATE,
		    c_rec.DESCRIPTION,
		    c_rec.SR_INSTANCE_ID,
		    MSC_CL_COLLECTION.v_last_collection_id,
		    MSC_CL_COLLECTION.v_current_date,
		    MSC_CL_COLLECTION.v_current_user,
		    MSC_CL_COLLECTION.v_current_date,
		    MSC_CL_COLLECTION.v_current_user );

		    END IF;

		  c_count:= c_count+1;

		  IF c_count> MSC_CL_COLLECTION.PBS THEN
		     COMMIT;
		     c_count:= 0;
		  END IF;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_UOM');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_UNITS_OF_MEASURE');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE

		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_UOM');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_UNITS_OF_MEASURE');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'UOM_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.UOM_CODE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'UNIT_OF_MEASURE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.UNIT_OF_MEASURE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		 COMMIT;

		/*
		IF MSC_CL_COLLECTION.v_is_complete_refresh THEN

		DELETE FROM MSC_UOM_CLASS_CONVERSIONS
		WHERE SR_INSTANCE_ID IN ( MSC_CL_COLLECTION.v_instance_id, -MSC_CL_COLLECTION.v_instance_id);

		COMMIT;

		END IF;
		*/

		c_count:= 0;

		FOR c_rec IN c2 LOOP

		BEGIN

		   UPDATE MSC_UOM_CLASS_CONVERSIONS mucc
		      SET mucc.FROM_UOM_CODE= c_rec.FROM_UOM_CODE,
		          mucc.FROM_UOM_CLASS= c_rec.FROM_UOM_CLASS,
		          mucc.TO_UOM_CODE= c_rec.TO_UOM_CODE,
		          mucc.TO_UOM_CLASS= c_rec.TO_UOM_CLASS,
		          mucc.CONVERSION_RATE= c_rec.CONVERSION_RATE,
		          mucc.DISABLE_DATE= c_rec.DISABLE_DATE,
		          mucc.SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID,
		          mucc.REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		          mucc.LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		          mucc.LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		    WHERE mucc.INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
		      AND mucc.FROM_UNIT_OF_MEASURE= c_rec.FROM_UNIT_OF_MEASURE
		      AND mucc.TO_UNIT_OF_MEASURE= c_rec.TO_UNIT_OF_MEASURE;

		  IF SQL%NOTFOUND THEN

		 insert into MSC_UOM_CLASS_CONVERSIONS
		  ( INVENTORY_ITEM_ID,
		    FROM_UNIT_OF_MEASURE,
		    FROM_UOM_CODE,
		    FROM_UOM_CLASS,
		    TO_UNIT_OF_MEASURE,
		    TO_UOM_CODE,
		    TO_UOM_CLASS,
		    CONVERSION_RATE,
		    DISABLE_DATE,
		    SR_INSTANCE_ID,
		    REFRESH_NUMBER,
		  LAST_UPDATE_DATE,
		    LAST_UPDATED_BY,
		    CREATION_DATE,
		    CREATED_BY)
		 VALUES
		  ( c_rec.INVENTORY_ITEM_ID,
		    c_rec.FROM_UNIT_OF_MEASURE,
		    c_rec.FROM_UOM_CODE,
		    c_rec.FROM_UOM_CLASS,
		    c_rec.TO_UNIT_OF_MEASURE,
		    c_rec.TO_UOM_CODE,
		    c_rec.TO_UOM_CLASS,
		    c_rec.CONVERSION_RATE,
		    c_rec.DISABLE_DATE,
		    c_rec.SR_INSTANCE_ID,
		    MSC_CL_COLLECTION.v_last_collection_id,
		  MSC_CL_COLLECTION.v_current_date,
		    MSC_CL_COLLECTION.v_current_user,
		    MSC_CL_COLLECTION.v_current_date,
		    MSC_CL_COLLECTION.v_current_user );

		   END IF;

		  c_count:= c_count+1;

		  IF c_count> MSC_CL_COLLECTION.PBS THEN
		     COMMIT;
		     c_count:= 0;
		  END IF;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_UOM');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_UOM_CLASS_CONVERSIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE

		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_UOM');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_UOM_CLASS_CONVERSIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.item_name');
		      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.item_name( c_rec.INVENTORY_ITEM_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'FROM_UNIT_OF_MEASURE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.FROM_UNIT_OF_MEASURE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'TO_UNIT_OF_MEASURE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TO_UNIT_OF_MEASURE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		 COMMIT;

		/*
		IF MSC_CL_COLLECTION.v_is_complete_refresh THEN

		 DELETE FROM MSC_UOM_CONVERSIONS
		WHERE SR_INSTANCE_ID IN ( MSC_CL_COLLECTION.v_instance_id, -MSC_CL_COLLECTION.v_instance_id);

		COMMIT;

		END IF;
		*/

		c_count:= 0;

		FOR c_rec IN c3 LOOP

		BEGIN

		  /* changed the where cond to update the row based on UOM code as a new
		     index on MSC_UOM_CONVERSIONS(INVENTORY_ITEM_ID,UOM_CODE) is introduced */

		   UPDATE MSC_UOM_CONVERSIONS muc
		      SET UNIT_OF_MEASURE= c_rec.UNIT_OF_MEASURE,
		          UOM_CODE= c_rec.UOM_CODE,
		          UOM_CLASS= c_rec.UOM_CLASS,
		          INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID,
		          CONVERSION_RATE= c_rec.CONVERSION_RATE,
		          DEFAULT_CONVERSION_FLAGS= c_rec.DEFAULT_CONVERSION_FLAG,
		          DISABLE_DATE= c_rec.DISABLE_DATE,
		          SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID,
		          REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		          LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		          LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		    WHERE muc.INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
		      AND muc.UOM_CODE = c_rec.UOM_CODE;

		  IF SQL%NOTFOUND THEN

		insert into MSC_UOM_CONVERSIONS
		  ( UNIT_OF_MEASURE,
		    UOM_CODE,
		    UOM_CLASS,
		    INVENTORY_ITEM_ID,
		    CONVERSION_RATE,
		    DEFAULT_CONVERSION_FLAGS,
		    DISABLE_DATE,
		    SR_INSTANCE_ID,
		    REFRESH_NUMBER,
		  LAST_UPDATE_DATE,
		    LAST_UPDATED_BY,
		    CREATION_DATE,
		    CREATED_BY)
		VALUES
		  ( c_rec.UNIT_OF_MEASURE,
		    c_rec.UOM_CODE,
		    c_rec.UOM_CLASS,
		    c_rec.INVENTORY_ITEM_ID,
		    c_rec.CONVERSION_RATE,
		    c_rec.DEFAULT_CONVERSION_FLAG,
		    c_rec.DISABLE_DATE,
		    c_rec.SR_INSTANCE_ID,
		    MSC_CL_COLLECTION.v_last_collection_id,
		    MSC_CL_COLLECTION.v_current_date,
		    MSC_CL_COLLECTION.v_current_user,
		    MSC_CL_COLLECTION.v_current_date,
		    MSC_CL_COLLECTION.v_current_user);

		   END IF;

		  c_count:= c_count+1;

		  IF c_count> MSC_CL_COLLECTION.PBS THEN
		     COMMIT;
		     c_count:= 0;
		  END IF;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_UOM');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_UOM_CONVERSIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE

		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_UOM');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_UOM_CONVERSIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.item_name');
		      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.item_name( c_rec.INVENTORY_ITEM_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'UNIT_OF_MEASURE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.UNIT_OF_MEASURE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'UOM_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.UOM_CODE);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		 COMMIT;

		END LOAD_UOM;

		/* This procedure has been introduced for Liability Project */
		/* This procedure removes the ASL's from the MSC_ASL_AUTH_DETAILS if they do not exist in */
		/* MSC_ITEM_SUPPLIERS */
		PROCEDURE CLEAN_LIAB_AGREEMENT

		IS


		/* This cursor gives the set of ASL that are there in MSC_ASL_AUTH_DETAILS */
		CURSOR c_sup_item_org is
		select distinct
		SUPPLIER_ID,
		SUPPLIER_SITE_ID ,
		ORGANIZATION_ID ,
		SR_INSTANCE_ID,
		INVENTORY_ITEM_ID,
		INCLUDE_LIABILITY_AGREEMENT,
		ASL_LIABILITY_AGREEMENT_BASIS,USING_ORGANIZATION_ID
		from
		msc_asl_auth_details
		where
		plan_id = -1 and
		sr_instance_id = MSC_CL_COLLECTION.v_instance_id ;




		BEGIN

		/* This  deletes the agreements form MSC_ASL_AUTH_DETAILS that dont have parent records in  msc_item_suppliers*/
		delete msc_asl_auth_details a
		where  not exists (select 1 from msc_item_suppliers  p
		                              where p.PLAN_ID  = a.PLAN_ID  and
		                                         p.SUPPLIER_ID = a. SUPPLIER_ID and
		                                         p.SUPPLIER_SITE_ID  =  a.SUPPLIER_SITE_ID and
		                                         p.ORGANIZATION_ID =  a.ORGANIZATION_ID  and
		                                         p.SR_INSTANCE_ID  =  a.SR_INSTANCE_ID and
		                                         p.INVENTORY_ITEM_ID  =  a.INVENTORY_ITEM_ID and
		                                         p.using_organization_id  =a.using_organization_id and
		                                         p.sr_instance_id = MSC_CL_COLLECTION.v_instance_id and
		                                         p.plan_id = -1
		                               )
		     and sr_instance_id = MSC_CL_COLLECTION.v_instance_id
		     and plan_id = -1  ;
		commit ;






		/*  Updates the msc_item_supplier : include_liability_agreement , asl_liability_agreement_basis */
		FOR x_sup_item_org  in c_sup_item_org

		LOOP


		UPDATE   msc_item_suppliers
		set  INCLUDE_LIABILITY_AGREEMENT = x_sup_item_org.INCLUDE_LIABILITY_AGREEMENT ,
		ASL_LIABILITY_AGREEMENT_BASIS = x_sup_item_org.ASL_LIABILITY_AGREEMENT_BASIS
		where
		SUPPLIER_ID  = x_sup_item_org.SUPPLIER_ID and
		SUPPLIER_SITE_ID = x_sup_item_org.SUPPLIER_SITE_ID and
		ORGANIZATION_ID  = x_sup_item_org.ORGANIZATION_ID and
		SR_INSTANCE_ID = x_sup_item_org.SR_INSTANCE_ID and
		INVENTORY_ITEM_ID = x_sup_item_org.INVENTORY_ITEM_ID and
		USING_ORGANIZATION_ID = x_sup_item_org.USING_ORGANIZATION_ID and
		plan_id = -1
		 ;



		END LOOP ;
		commit ;


		END  CLEAN_LIAB_AGREEMENT ;

	   PROCEDURE GENERATE_TRADING_PARTNER_KEYS (
	                ERRBUF				OUT NOCOPY VARCHAR2,
		        RETCODE				OUT NOCOPY NUMBER,
	     		pINSTANCE_ID                    IN  NUMBER) IS

	   CURSOR c1 IS
	      SELECT mtil.TP_ID,
	             mtil.PARTNER_TYPE,
	             mst.ORGANIZATION_CODE,
	             mst.SR_TP_ID,
	             mst.DISABLE_DATE,
	             mst.STATUS,
	             mst.MASTER_ORGANIZATION,
	             mst.WEIGHT_UOM,
	             mst.MAXIMUM_WEIGHT,
	             mst.VOLUME_UOM,
	             mst.MAXIMUM_VOLUME,
	             mst.PARTNER_NUMBER,
	             mst.CALENDAR_CODE,
	             mst.CALENDAR_EXCEPTION_SET_ID,
	             mst.OPERATING_UNIT,
	             mst.SR_INSTANCE_ID,
	             mst.PROJECT_REFERENCE_ENABLED,
	             mst.PROJECT_CONTROL_LEVEL,
	             mst.CUSTOMER_CLASS_CODE,
	             mst.CUSTOMER_TYPE
	        FROM MSC_TP_ID_LID mtil,
	             MSC_ST_TRADING_PARTNERS mst
	       WHERE mtil.SR_TP_ID= mst.SR_TP_ID
	         AND mtil.SR_INSTANCE_ID= mst.SR_INSTANCE_ID
	         AND mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	         AND mtil.Partner_Type= mst.Partner_Type
	         AND mst.Partner_Type IN (1,2,4)   --Vendor/Customer/Carrier
	         /* SCE Change Starts */
	         AND nvl(mst.company_id, -1) = mtil.sr_company_id
			 AND nvl(mst.company_id, -1) = -1
	         /* SCE Change Starts */
	       ORDER BY
	             mtil.TP_ID;

	   CURSOR c2 IS
	      SELECT mtsil.TP_SITE_ID,
	             mtsil.Partner_Type,
	             substrb(msts.PARTNER_ADDRESS,1,1600) PARTNER_ADDRESS,--added for the NLS bug3463401
	             msts.POSTAL_CODE,
	             substrb(msts.CITY,1,60) CITY,--added for the NLS bug3463401
	             msts.STATE,
	             msts.COUNTRY,
	             msts.LONGITUDE,
	             msts.LATITUDE,
	             msts.SR_TP_SITE_ID,
	             msts.SR_INSTANCE_ID,
		     msts.SHIPPING_CONTROL
	        FROM MSC_TP_SITE_ID_LID mtsil,
	             MSC_ST_TRADING_PARTNER_SITES msts
	       WHERE mtsil.SR_TP_SITE_ID= msts.SR_TP_SITE_ID
	         AND mtsil.SR_INSTANCE_ID= msts.SR_INSTANCE_ID
	         AND msts.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	         AND mtsil.Partner_Type= msts.Partner_Type
	         AND msts.Partner_Type IN (1,2)   --Vendor/Customer
	         /* SCE Change Starts */
	         AND nvl(msts.company_id, -1) = mtsil.sr_company_id
	         /* SCE Change Starts */
	       ORDER BY
	             mtsil.TP_SITE_ID;

	/*
	   Cursor c5 IS
	      SELECT distinct mst.Partner_Name, mst.Partner_Type
	        FROM MSC_ST_TRADING_PARTNERS mst
	       WHERE NOT EXISTS ( select 1
	                               from MSC_TRADING_PARTNERS mtp
	                              where mtp.Partner_Name= mst.Partner_Name
	                                and mtp.Partner_Type= mst.Partner_Type)
	         AND mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	         AND mst.Partner_type IN (1,2)
	    ORDER BY mst.Partner_Type,
	             mst.Partner_Name;  -- using ORDER BY to avoid dead lock
	*/

	-- ==== New Customers and Suppliers ====
	   Cursor c5 IS
	      SELECT decode(mc.company_id, MSC_CL_COLLECTION.G_MY_COMPANY_ID, null, mc.company_id) company_id1,
	             mst.partner_name partner_name,
	             mst.partner_type partner_type
	      from   MSC_ST_TRADING_PARTNERS mst,
	             MSC_COMPANIES MC
	      where  nvl(mst.company_name, MSC_CL_COLLECTION.v_my_company_name) = mc.company_name
	      and    mst.sr_instance_id = MSC_CL_COLLECTION.v_instance_id
	      and    mst.partner_type IN (1,2,4) --Vendor/Customer/Carrier
	      /* SCE CHANGE STARTS */
		  and    nvl(mst.company_id , -1) = -1
		  /* SCE CHANGE ENDS */
	      MINUS
	      SELECT decode(mtp.company_id,null, null, mtp.company_id) company_id,
	             mtp.partner_name partner_name,
	             mtp.partner_type partner_type
	      from   msc_trading_partners mtp
	      where  mtp.partner_type IN (1,2,4) --Vendor/Customer/Carrier
	      ORDER BY partner_type,
	               company_id1,
	               partner_name ;

	  Cursor c5_tpname IS
	    SELECT distinct mst.Partner_Name, mst.sr_tp_id, mst.sr_instance_id, mst.Partner_Type,
	                    decode(mc.company_id, MSC_CL_COLLECTION.G_MY_COMPANY_ID, -1, mc.company_id) company_id1
	        FROM MSC_ST_TRADING_PARTNERS mst,
	             MSC_COMPANIES MC
	      WHERE EXISTS ( select 1
	                           from MSC_TRADING_PARTNERS mtp
	                           where mtp.sr_tp_id= mst.sr_tp_id
	                           and mtp.sr_instance_id= mst.sr_instance_id
	                           and mtp.Partner_Type= mst.Partner_Type
	                           and nvl(mtp.COMPANY_ID,MSC_CL_COLLECTION.G_MY_COMPANY_ID) = MC.COMPANY_ID
	                           and mtp.Partner_Name <> mst.Partner_Name)
	        AND mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	        AND mst.Partner_type IN (1,2)
	        AND nvl(mst.company_name, MSC_CL_COLLECTION.v_my_company_name) = mc.company_name
	        AND nvl(mst.company_id , -1) = -1
	    ORDER BY mst.Partner_Name;  -- using ORDER BY to avoid dead lock


	   Cursor c6 IS
	      SELECT distinct mtil.TP_ID, msts.tp_site_code
	           FROM MSC_ST_TRADING_PARTNER_SITES msts,
	                MSC_TP_ID_LID mtil
	          WHERE NOT EXISTS ( select 1
	                               from MSC_TRADING_PARTNER_SITES mtps
	                              where mtps.TP_Site_Code= msts.TP_Site_Code
				        and mtps.Partner_ID= mtil.tp_id)
	            AND msts.SR_Instance_ID= mtil.SR_INSTANCE_ID
	            AND msts.SR_TP_ID= mtil.SR_TP_ID

	            /* SCE CHANGE */
	            AND nvl(msts.company_id, -1) = mtil.sr_company_id

	            AND msts.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	            AND msts.Partner_Type=1
	            AND mtil.Partner_type=1
	       ORDER BY mtil.TP_ID,
	                msts.TP_Site_Code;  -- using ORDER BY to avoid dead lock

	   Cursor c7 IS
	         SELECT distinct
	                mtil.TP_ID,
	                msts.Operating_Unit_Name,
	                msts.TP_Site_Code,
	                msts.Location
	           FROM MSC_ST_TRADING_PARTNER_SITES msts,
	                MSC_TP_ID_LID mtil
	          WHERE NOT EXISTS ( select 1
	                               from MSC_TRADING_PARTNER_SITES mtps
	                              where NVL(mtps.Operating_Unit_Name, ' ')=
	                                    NVL(msts.Operating_Unit_Name, ' ')
	                                and mtps.TP_Site_Code= msts.TP_Site_Code
	                                and mtps.Location= msts.Location
	                                and mtps.Partner_ID= mtil.TP_ID)
	            AND msts.SR_Instance_ID= mtil.SR_INSTANCE_ID
	            AND msts.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	            AND msts.SR_TP_ID= mtil.SR_TP_ID
	            /* SCE CHANGE starts*/
	            AND nvl(msts.company_id, -1) = mtil.sr_company_id
		    /* SCE CHANGE ends*/
	            AND msts.Partner_Type=2
	            AND mtil.Partner_type=2
	       ORDER BY mtil.TP_ID,
	                msts.TP_Site_Code,
	                msts.Location;  -- using ORDER BY to avoid dead lock

	   Cursor c9 IS
	    SELECT distinct
	           nvl(msts.company_id, -1) SR_COMPANY_ID,
	           msts.SR_TP_SITE_ID,
	           msts.SR_INSTANCE_ID,
	           mtp.PARTNER_SITE_ID
	      FROM MSC_ST_TRADING_PARTNER_SITES msts,
	           MSC_TP_ID_LID mtil,
	           MSC_TRADING_PARTNER_SITES mtp
	     WHERE NOT EXISTS( select 1
	                         from MSC_TP_SITE_ID_LID mtsil
	                        where msts.SR_TP_SITE_ID= mtsil.SR_TP_SITE_ID
	                          and msts.SR_INSTANCE_ID= mtsil.SR_INSTANCE_ID
	                          and mtsil.Partner_Type= 1
							  and nvl(msts.company_id, -1) = mtsil.sr_company_id)
	       AND msts.TP_Site_Code= mtp.TP_Site_Code
	       AND msts.SR_TP_ID= mtil.SR_TP_ID
	       AND msts.SR_INSTANCE_ID= mtil.SR_INSTANCE_ID
	       AND msts.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	/* SCE Change starts */
	       AND nvl(msts.company_id, -1) = mtil.SR_COMPANY_ID
	/* SCE changes ends */
	       AND mtil.TP_ID= mtp.Partner_ID
	       AND mtp.partner_type = mtil.partner_type
	       AND mtil.Partner_Type= msts.partner_type
	       AND msts.Partner_Type= 1;

	 --====== Cursor for populating msc_tp_site_id_lid ====

	   Cursor c10 IS
	    SELECT distinct
	    /* SCE Change starts*/
	    /* Added sr_company_id for SCE purpose */
	           nvl(msts.company_id, -1) SR_COMPANY_ID,
	    /* SCE Change ends*/
	           msts.SR_TP_SITE_ID,
	           msts.SR_INSTANCE_ID,
	           mtp.PARTNER_SITE_ID
	      FROM MSC_ST_TRADING_PARTNER_SITES msts,
	           MSC_TP_ID_LID mtil,
	           MSC_TRADING_PARTNER_SITES mtp
	     WHERE NOT EXISTS( select 1
	                         from MSC_TP_SITE_ID_LID mtsil
	                        where msts.SR_TP_SITE_ID= mtsil.SR_TP_SITE_ID
	                          and msts.SR_INSTANCE_ID= mtsil.SR_INSTANCE_ID
	                          and mtsil.Partner_Type= 2
							  and nvl(msts.company_id, -1) = mtsil.sr_company_id)
	       AND NVL( msts.Operating_Unit_Name, ' ')=
	           NVL( mtp.Operating_Unit_Name, ' ')
	       AND msts.TP_Site_Code= mtp.TP_Site_Code
	       AND nvl(msts.Location, ' ')= nvl(mtp.Location, ' ')
	       AND msts.SR_TP_ID= mtil.SR_TP_ID
	       AND msts.SR_INSTANCE_ID= mtil.SR_INSTANCE_ID
	       AND msts.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	    /* SCE Change stars*/
	    /* Added sr_company_id for SCE purpose */
	       AND nvl(msts.company_id, -1) = mtil.SR_COMPANY_ID
	    /* SCE Change stars*/
	       AND mtil.TP_ID= mtp.Partner_ID
	       AND mtp.partner_type = mtil.partner_type
	       AND mtil.Partner_Type= msts.partner_type
	       AND msts.Partner_Type= 2;

	  -- ============ Cursor for populating msc_tp_id_lid ==================== --
	   CURSOR c12 IS
	    SELECT distinct
	    /* SCE Change starts */
	    	   nvl(mst.company_id, -1) SR_COMPANY_ID,
	    /* SCE change ends */
	           mst.SR_TP_ID,
	           mst.SR_INSTANCE_ID,
	           mst.Partner_Type,
	           mtp.PARTNER_ID
	      FROM MSC_ST_TRADING_PARTNERS mst,
	           MSC_TRADING_PARTNERS mtp,
	           /* SCE Change starts */
	           msc_companies mc
	           /* SCE Change ends */
	     WHERE NOT EXISTS( select 1
	                         from MSC_TP_ID_LID mtil
	                        where mst.SR_TP_ID= mtil.SR_TP_ID
	                          and mst.SR_INSTANCE_ID= mtil.SR_INSTANCE_ID
	                          and mst.Partner_Type= mtil.Partner_Type
	                          -- SCE Change
	                          -- Join with company_id
				              and nvl( mst.company_id, -1) = nvl(mtil.sr_company_id, -1)
							  and nvl( mst.company_id, -1) = -1)
	       AND mst.Partner_NAME= mtp.Partner_NAME
	       AND mst.Partner_Type= mtp.Partner_Type
	       AND mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	       AND mst.Partner_Type IN ( 1, 2)
	       /* SCE Change starts */
	       -- Add join with msc_companies
	       AND nvl(mst.company_name, MSC_CL_COLLECTION.v_my_company_name) = mc.company_name
	       AND mc.company_id = nvl(mtp.company_id, MSC_CL_COLLECTION.G_MY_COMPANY_ID );
		   -- AND nvl( mst.company_id, -1) = -1; -- commented for aerox
	       /* SCE Change ends */


	 -- ============ Cursor for UPDATE MSC_TP_ID_LID SRP Changes ==================== --
	   CURSOR c13 IS
	   Select  resource_type, sr_instance_id , partner_type,sr_tp_id
	   From msc_st_trading_partners
	   Where sr_instance_id = MSC_CL_COLLECTION.v_instance_id
	   And  partner_type=2;

	   lv_control_flag NUMBER;
	   lv_msc_tp_coll_window NUMBER;
	   lv_new_partner_id NUMBER;
     lv_old_partner_id NUMBER;
     lv_partner_count NUMBER;

       lv_tp_id_count NUMBER := 0;
       lv_tp_site_id_count  NUMBER := 0;
       lv_tp_stat_stale NUMBER := MSC_UTIL.SYS_NO;
       lv_tp_site_stat_stale   NUMBER := MSC_UTIL.SYS_NO;
       lv_ins_records   NUMBER := 0;

	   BEGIN


	GET_COLL_PARAM (pINSTANCE_ID);
	MSC_CL_COLLECTION.INITIALIZE( pINSTANCE_ID);
	MSC_CL_COLLECTION.v_my_company_name := MSC_CL_SCE_COLLECTION.GET_MY_COMPANY;


	   SELECT decode(nvl(fnd_profile.value('MSC_PURGE_ST_CONTROL'),'N'),'Y',1,2)
	   INTO lv_control_flag
	   FROM dual;

	   BEGIN
	   	lv_msc_tp_coll_window := NVL(TO_NUMBER(FND_PROFILE.VALUE('MSC_COLLECTION_WINDOW_FOR_TP_CHANGES')),0);
	   EXCEPTION
	   	WHEN OTHERS THEN
	   		lv_msc_tp_coll_window := 0;
	   END;

	   IF (MSC_CL_COLLECTION.v_apps_ver = MSC_UTIL.G_APPS107) OR (MSC_CL_COLLECTION.v_apps_ver = MSC_UTIL.G_APPS110) OR lv_msc_tp_coll_window IS NULL THEN
	      	lv_msc_tp_coll_window := 0;
	   END IF;

    begin
        select num_rows,decode (stale_stats,'NO', MSC_UTIL.SYS_NO, MSC_UTIL.SYS_YES )
         into  lv_tp_id_count, lv_tp_stat_stale
        from dba_TAB_STATISTICS
        where table_name =  'MSC_TP_ID_LID';
    exception when no_data_found then
              lv_tp_stat_stale := MSC_UTIL.SYS_YES ;
    end;

    begin
        select num_rows,decode (stale_stats,'NO', MSC_UTIL.SYS_NO, MSC_UTIL.SYS_YES )
         into  lv_tp_site_id_count, lv_tp_site_stat_stale
        from dba_TAB_STATISTICS
        where table_name ='MSC_TP_SITE_ID_LID';
    exception when no_data_found then
              lv_tp_site_stat_stale := MSC_UTIL.SYS_YES ;
    end;

	/* if complete refresh, regen the key mapping data */
	IF MSC_CL_COLLECTION.v_is_complete_refresh THEN

	 IF lv_control_flag = 2 THEN
	     IF lv_msc_tp_coll_window = 0 THEN
		 DELETE MSC_TP_ID_LID      WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
		 DELETE MSC_TP_SITE_ID_LID WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
		 DELETE MSC_TP_ID_LID      WHERE SR_INSTANCE_ID= -1;
		 DELETE MSC_TP_SITE_ID_LID WHERE SR_INSTANCE_ID= -1;
	     END IF;

	 ELSE
	   IF lv_msc_tp_coll_window = 0 THEN
	      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_TP_ID_LID');
	      MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_TP_SITE_ID_LID');
	   END IF;

	 END IF;
	lv_tp_stat_stale      := MSC_UTIL.SYS_YES ;
	lv_tp_site_stat_stale := MSC_UTIL.SYS_YES ;
	END IF;

	   /*************** PREPLACE CHANGE START *****************/


	--In case of continuous and targetted collections, delete carrier records from MSC_TP_ID_LID
	--when sourcing SRS launch parameter is Yes --and delete supplier and customer records
	--from MSC_TP_ID_LID when either Supplier or Customer SRS launch parameter is Yes.

	   IF (MSC_CL_COLLECTION.v_is_partial_refresh OR MSC_CL_COLLECTION.V_IS_CONT_REFRESH) THEN
	       IF (MSC_CL_COLLECTION.v_coll_prec.sourcing_rule_flag=MSC_UTIL.SYS_YES) THEN
	           DELETE MSC_TP_ID_LID    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id and partner_type=4;
		   DELETE MSC_TP_ID_LID    WHERE SR_INSTANCE_ID= -1 and partner_type=4;
		   lv_tp_stat_stale      := MSC_UTIL.SYS_YES ;
	       END IF;
	   END IF;

	   IF MSC_CL_COLLECTION.v_is_partial_refresh THEN

	      IF ((MSC_CL_COLLECTION.v_coll_prec.tp_vendor_flag = MSC_UTIL.SYS_YES) or
	          (MSC_CL_COLLECTION.v_coll_prec.tp_customer_flag = MSC_UTIL.SYS_YES)) THEN

	            -- Note now vendor or customer cannot be refreshed
	            -- separately. If that functionality needs to be provided
	            -- in future then the the ID_LID tables will have to
	            -- be partitioned, so that only either Supplier or
	            -- Customer information is replaced. The other
	            -- alternative of course is to conditionally load
	            -- data using the partner_type as a filter.
	            -- We do not delete data if the profile "MSC_COLLECTION_WINDOW_FOR_TP_CHANGES" is set to not null.

	           IF lv_msc_tp_coll_window = 0 THEN
	              IF lv_control_flag = 2 THEN
	                  DELETE MSC_TP_ID_LID      WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id and partner_type in (1,2);
	                  DELETE MSC_TP_SITE_ID_LID WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
	                  DELETE MSC_TP_ID_LID      WHERE SR_INSTANCE_ID= -1 and partner_type in (1,2);
	                  DELETE MSC_TP_SITE_ID_LID WHERE SR_INSTANCE_ID= -1;
	              ELSE
	                  MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_TP_ID_LID');
	                  MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_TP_SITE_ID_LID');
	              END IF;
	           END IF;
        	lv_tp_stat_stale      := MSC_UTIL.SYS_YES ;
        	lv_tp_site_stat_stale := MSC_UTIL.SYS_YES ;
	      END IF;

	   END IF;

	   /***************  PREPLACE CHANGE END  *****************/

	--agmcont
	   IF MSC_CL_COLLECTION.V_IS_CONT_REFRESH THEN

	      IF ((MSC_CL_COLLECTION.v_coll_prec.tp_vendor_flag = MSC_UTIL.SYS_YES) or
	          (MSC_CL_COLLECTION.v_coll_prec.tp_customer_flag = MSC_UTIL.SYS_YES)) THEN

	            -- Note now vendor or customer cannot be refreshed
	            -- separately. If that functionality needs to be provided
	            -- in future then the the ID_LID tables will have to
	            -- be partitioned, so that only either Supplier or
	            -- Customer information is replaced. The other
	            -- alternative of course is to conditionally load
	            -- data using the partner_type as a filter.
	            -- We do not delete data if the profile "MSC_COLLECTION_WINDOW_FOR_TP_CHANGES" is set to not null.
	           IF lv_msc_tp_coll_window = 0 THEN
	              IF lv_control_flag = 2 THEN
	                 DELETE MSC_TP_ID_LID      WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id and partner_type in (1,2);
	                 DELETE MSC_TP_SITE_ID_LID WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;
	                 DELETE MSC_TP_ID_LID      WHERE SR_INSTANCE_ID= -1 and partner_type in (1,2);
	                 DELETE MSC_TP_SITE_ID_LID WHERE SR_INSTANCE_ID= -1;
	              ELSE
	                 MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_TP_ID_LID');
	                 MSC_CL_COLLECTION.TRUNCATE_MSC_TABLE( 'MSC_TP_SITE_ID_LID');
	              END IF;
            	lv_tp_stat_stale      := MSC_UTIL.SYS_YES ;
            	lv_tp_site_stat_stale := MSC_UTIL.SYS_YES ;
	           END IF;
	      END IF;

	   END IF;

	COMMIT;

	   --========== Same VENDOR/CUSTOMER with Changed Name ==========
	   /*
	  Commented out this piece of code because it does not work for a case where
	   the Trading partner name is changed to a name which is already existing in
	    the msc_trading_partners. This generates a lot of unique index violation
	     of partner_name, partner_type
	     This fix will be done with the enhancement: 2700654  */

if (lv_control_flag = 1) then    /* Added For Bug 6414426 */
	FOR c_rec IN c5_tpname LOOP
	 SELECT count(*)
 	   INTO lv_partner_count
 	   FROM msc_trading_partners
 	   WHERE
 	   partner_name = c_rec.partner_name
 	   AND partner_type = c_rec.partner_type
 	   AND nvl(company_id, -1) = c_rec.company_id1;

  IF (lv_partner_count > 0) THEN

 		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Partner is being merged..');
 		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Partner name is :'|| c_rec.partner_name);

  ELSE
    BEGIN

    	UPDATE   MSC_TRADING_PARTNERS mtp
    	   SET   mtp.PARTNER_NAME= c_rec.PARTNER_NAME
    	 WHERE   mtp.SR_TP_ID= c_rec.SR_TP_ID
    	   AND   mtp.SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
    	   AND   mtp.PARTNER_TYPE= c_rec.PARTNER_TYPE
    	   AND   nvl(mtp.company_id,-1) = c_rec.company_id1;

    	EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'In DUP_VAL_ON_INDEX exception clause of c5_tpname');
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'The value of partner name is: '|| c_rec.PARTNER_NAME);
                 -- Fetch the Old Partner Id
                 SELECT partner_id
                 INTO   lv_old_partner_id
                 FROM   msc_trading_partners
                WHERE
                        sr_tp_id = c_rec.SR_TP_ID
                 AND   SR_INSTANCE_ID = c_rec.SR_INSTANCE_ID
                 AND   PARTNER_TYPE = c_rec.PARTNER_TYPE
                 AND   nvl(company_id,-1) = c_rec.company_id1;

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'The old Partner_Id IS: ' || to_number(lv_old_partner_id));
                 -- Fetch the New Partner Id
                 SELECT partner_id
                 INTO   lv_new_partner_id
                 FROM   msc_trading_partners
                 WHERE
                        partner_name= c_rec.partner_name
                 AND   SR_INSTANCE_ID = c_rec.SR_INSTANCE_ID
                 AND   PARTNER_TYPE = c_rec.PARTNER_TYPE
                AND   nvl(company_id,-1) = c_rec.company_id1;

                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'The new Partner_Id IS: ' || to_number(lv_new_partner_id));

                 /*DELETE FROM MSC_TRADING_PARTNERS
                 WHERE SR_TP_ID = c_rec.SR_TP_ID
                 AND   SR_INSTANCE_ID = c_rec.SR_INSTANCE_ID
                 AND   PARTNER_TYPE = c_rec.PARTNER_TYPE;

                 UPDATE MSC_TRADING_PARTNER_SITES
                 SET   PARTNER_ID = lv_new_partner_id,
                       LAST_UPDATE_DATE = v_current_date,
                       LAST_UPDATED_BY = v_current_user
                 WHERE PARTNER_ID = lv_old_partner_id
                  AND   SR_INSTANCE_ID = c_rec.SR_INSTANCE_ID
                  AND   PARTNER_TYPE = c_rec.PARTNER_TYPE;

                 UPDATE  MSC_TP_ID_LID
                 SET   TP_ID = lv_new_partner_id
                 WHERE SR_TP_ID = c_rec.SR_TP_ID
                 AND   SR_INSTANCE_ID = c_rec.SR_INSTANCE_ID
                 AND   PARTNER_TYPE = c_rec.PARTNER_TYPE;
                 */

    	   WHEN OTHERS THEN

    	      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

    	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
    	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
    	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'MSC_CL_SETUP_ODS_LOAD.TRANSFORM_KEYS');
    	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNERS');
    	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

    	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
    	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
    	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_TYPE);
    	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

    	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
    	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_ID');
    	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_ID);
    	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

    	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
    	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_NAME');
    	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_NAME);
    	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

    	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

    END;
	 END IF;-- IF (lv_partner_count > 0) THEN
	END LOOP;
END IF;--  if (lv_control_flag = 1) then

	COMMIT;

	  --========== VENDOR/CUSTOMER ==========

	FOR c_rec IN c5 LOOP

	BEGIN

	INSERT INTO MSC_TRADING_PARTNERS
	( /* SCE Change starts */
	  COMPANY_ID,
	  /* SCE Change ends */
	  PARTNER_NAME,
	  PARTNER_ID,
	  SR_TP_ID,
	  PARTNER_TYPE,
	  PARTNER_NUMBER,
	  MASTER_ORGANIZATION,
	  SR_INSTANCE_ID,
	  REFRESH_NUMBER,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY)
	VALUES
	( /* SCE Change starts */
	  c_rec.COMPANY_ID1,
	  /* SCE Change ends */
	  c_rec.Partner_Name,
	  MSC_Trading_Partners_S.NEXTVAL,
	  MSC_Trading_Partners_S.NEXTVAL,  -- dummy value to satisfy the unique constraint
	  c_rec.Partner_Type,
	  -1,
	  -1,
	  -1,
	  MSC_CL_COLLECTION.v_last_collection_id,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user );

	EXCEPTION

	   WHEN DUP_VAL_ON_INDEX THEN

	        NULL;

	   WHEN OTHERS THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNERS');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_NAME');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_NAME);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	END;

	END LOOP;

	COMMIT;

	lv_ins_records := 0;
	 -- ==== populate msc_tp_id_lid with newly created Suppliers / Customers ====
	IF MSC_CL_COLLECTION.v_apps_ver < MSC_UTIL.G_APPS115 AND MSC_CL_COLLECTION.v_apps_ver <> -1 THEN

	/* For 107 and 110 the vendor_id and vendor
	   site id can be duplicate, therefore we use
	   the cursors to handle such exceptions, but for 11i we can use a straight
	   Insert-as-select to improve performance */

	FOR c_rec IN c12 LOOP

	BEGIN

	INSERT INTO MSC_TP_ID_LID
	( /* SCE Change starts */
	  SR_COMPANY_ID,
	  /* SCE change ends */
	  SR_TP_ID,
	  SR_INSTANCE_ID,
	  Partner_Type,
	  TP_ID)
	VALUES
	( c_rec.SR_COMPANY_ID,
	  c_rec.SR_TP_ID,
	  c_rec.SR_INSTANCE_ID,
	  c_rec.PARTNER_TYPE,
	  c_rec.PARTNER_ID);

	EXCEPTION

	   WHEN OTHERS THEN

	    IF SQLCODE IN (-1653,-1654) THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TP_ID_LID');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_TYPE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	    ELSE

	      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TP_ID_LID');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_TYPE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_WARNING;

	    END IF;

	END;

	END LOOP;

	ELSE

	INSERT /*+ APPEND */ INTO MSC_TP_ID_LID
	( SR_COMPANY_ID,
	  SR_TP_ID,
	  SR_INSTANCE_ID,
	  Partner_Type,
	  TP_ID,
	  AGGREGATE_DEMAND_FLAG,
	  SR_CUST_ACCOUNT_NUMBER)
	SELECT distinct
	           nvl(mst.company_id, -1) SR_COMPANY_ID,
	           mst.SR_TP_ID,
	           mst.SR_INSTANCE_ID,
	           mst.Partner_Type,
	           mtp.PARTNER_ID,
	           mst.AGGREGATE_DEMAND_FLAG,
	           mst.CUST_ACCOUNT_NUMBER
	      FROM MSC_ST_TRADING_PARTNERS mst,
	           MSC_TRADING_PARTNERS mtp,
	           MSC_COMPANIES mc
	     WHERE NOT EXISTS( select 1
	                         from MSC_TP_ID_LID mtil
	                        where mst.SR_TP_ID= mtil.SR_TP_ID
	                          and mst.SR_INSTANCE_ID= mtil.SR_INSTANCE_ID
	                          and nvl( mst.company_id, -1) = nvl(mtil.sr_company_id, -1)
							  and nvl( mst.company_id, -1) = -1
	                          and mst.Partner_Type= mtil.Partner_Type)
	       AND mst.Partner_NAME= mtp.Partner_NAME
	       AND mst.Partner_Type= mtp.Partner_Type
	       AND mst.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	       AND mst.Partner_Type IN ( 1, 2,4)
	       AND nvl(mst.company_name, MSC_CL_COLLECTION.v_my_company_name) = mc.company_name
	       AND mc.company_id = nvl(mtp.company_id, MSC_CL_COLLECTION.G_MY_COMPANY_ID)
		   and nvl( mst.company_id, -1) = -1;
	lv_ins_records := SQL%ROWCOUNT;
	END IF;

	COMMIT;
	/* Bug7679044 */
	IF lv_tp_stat_stale = MSC_UTIL.SYS_YES OR lv_ins_records > lv_tp_id_count * 0.2 THEN
       msc_analyse_tables_pk.analyse_table( 'MSC_TP_ID_LID');
       lv_tp_stat_stale := MSC_UTIL.SYS_NO;
       lv_tp_id_count := lv_tp_id_count + lv_ins_records;
    END IF;

	 -- ==== Update msc_tp_id_lid with resource_type  ==== SRP Changes
	 FOR c_rec IN c13 LOOP
	BEGIN

	 UPDATE MSC_TP_ID_LID
	 set
	 resource_type = c_rec.resource_type
	 WHERE sr_tp_id= c_rec.sr_tp_id And
	       partner_type=2 And
	       sr_instance_id = MSC_CL_COLLECTION.v_instance_id;

	 END;

	 END LOOP;  --c13 crec loop

	 COMMIT;


	-- ==== Populate msc_trading_partner_sites with new Supplier Sites ====

	FOR c_rec IN c6 LOOP

	BEGIN

	INSERT INTO MSC_TRADING_PARTNER_SITES
	( TP_SITE_CODE,
	  PARTNER_ID,
	  PARTNER_SITE_ID,
	  SR_TP_SITE_ID,
	  PARTNER_TYPE,
	  SR_INSTANCE_ID,
	  REFRESH_NUMBER,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY)
	VALUES
	( c_rec.TP_Site_Code,
	  c_rec.TP_ID,
	  MSC_Trading_Partner_Sites_S.NEXTVAL,
	  MSC_Trading_Partner_Sites_S.NEXTVAL,
	  1,
	  MSC_CL_COLLECTION.v_instance_id,
	  MSC_CL_COLLECTION.v_last_collection_id,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user);

	EXCEPTION

	   WHEN DUP_VAL_ON_INDEX THEN

	        NULL;

	   WHEN OTHERS THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNER_SITES');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'TP_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TP_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'TP_SITE_CODE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TP_SITE_CODE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	END;

	END LOOP;

	COMMIT;
	lv_ins_records := 0;
	-- ==== Populate msc_tp_site_id_lid with new Supplier Sites ====
	IF MSC_CL_COLLECTION.v_apps_ver < MSC_UTIL.G_APPS115 THEN

	/* For 107 and 110 the vendor_id and vendor
	   site id can be duplicate, therefore we use
	   the cursors to handle such exceptions, but for 11i we can use a straight
	   Insert-as-select to improve performance */

	FOR c_rec IN c9 LOOP

	BEGIN

	INSERT INTO MSC_TP_SITE_ID_LID
	( /* SCE Change starts */
	  SR_COMPANY_ID,
	  /* SCE Change ends */
	  SR_TP_SITE_ID,
	  SR_INSTANCE_ID,
	  Partner_Type,
	  TP_SITE_ID)
	VALUES
	( c_rec.SR_COMPANY_ID,
	  c_rec.SR_TP_SITE_ID,
	  c_rec.SR_INSTANCE_ID,
	  1,
	  c_rec.PARTNER_SITE_ID);

	EXCEPTION

	   WHEN DUP_VAL_ON_INDEX THEN

	     MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TP_SITE_ID_LID');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', 1);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_WARNING;

	   WHEN OTHERS THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TP_SITE_ID_LID');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', 1);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	END;

	END LOOP;

	ELSE

	INSERT /*+ APPEND */ INTO MSC_TP_SITE_ID_LID
	( SR_COMPANY_ID,
	  SR_TP_SITE_ID,
	  SR_INSTANCE_ID,
	  Partner_Type,
	  location_id,
	  operating_unit,
	  TP_SITE_ID)
	SELECT distinct
	           nvl(msts.company_id, -1) SR_COMPANY_ID,
	           msts.SR_TP_SITE_ID,
	           msts.SR_INSTANCE_ID,
	           1,
	           msts.location_id,
		         msts.operating_unit,
	           mtp.PARTNER_SITE_ID
	      FROM MSC_ST_TRADING_PARTNER_SITES msts,
	           MSC_TP_ID_LID mtil,
	           MSC_TRADING_PARTNER_SITES mtp
	     WHERE NOT EXISTS( select 1
	                         from MSC_TP_SITE_ID_LID mtsil
	                        where msts.SR_TP_SITE_ID= mtsil.SR_TP_SITE_ID
	                          and msts.SR_INSTANCE_ID= mtsil.SR_INSTANCE_ID
	                          and mtsil.Partner_Type= 1
	                          and nvl(msts.company_id, -1) = mtsil.sr_company_id)
	       AND msts.TP_Site_Code= mtp.TP_Site_Code
	       AND msts.SR_TP_ID= mtil.SR_TP_ID
	       AND msts.SR_INSTANCE_ID= mtil.SR_INSTANCE_ID
	       AND msts.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	       AND nvl(msts.company_id, -1) = mtil.SR_COMPANY_ID
	       AND mtil.TP_ID= mtp.Partner_ID
	       AND mtp.partner_type = mtil.partner_type
	       AND mtil.Partner_Type= msts.partner_type
	       AND msts.Partner_Type= 1;
	lv_ins_records := SQL%ROWCOUNT;
	END IF;

	COMMIT;
	/* Bug7679044 */
	IF lv_tp_site_stat_stale = MSC_UTIL.SYS_YES OR lv_ins_records > lv_tp_site_id_count * 0.2 THEN
       msc_analyse_tables_pk.analyse_table( 'MSC_TP_SITE_ID_LID');
       lv_tp_site_stat_stale := MSC_UTIL.SYS_NO;
       lv_tp_site_id_count := lv_tp_site_id_count + lv_ins_records;
    END IF;

		  --========== CUSTOMER SITE ==========

	FOR c_rec IN c7 LOOP

	BEGIN

	INSERT INTO MSC_TRADING_PARTNER_SITES
	( TP_SITE_CODE,
	  LOCATION,
	  OPERATING_UNIT_NAME,
	  PARTNER_ID,
	  PARTNER_SITE_ID,
	  SR_TP_SITE_ID,
	  PARTNER_TYPE,
	  SR_INSTANCE_ID,
	  REFRESH_NUMBER,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY)
	VALUES
	( c_rec.TP_Site_Code,
	  c_rec.Location,
	  c_rec.OPERATING_UNIT_NAME,
	  c_rec.TP_ID,
	  MSC_Trading_Partner_Sites_S.NEXTVAL,
	  MSC_Trading_Partner_Sites_S.NEXTVAL,
	  2,
	  MSC_CL_COLLECTION.v_instance_id,
	  MSC_CL_COLLECTION.v_last_collection_id,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user,
	  MSC_CL_COLLECTION.v_current_date,
	  MSC_CL_COLLECTION.v_current_user );

	EXCEPTION

	   WHEN DUP_VAL_ON_INDEX THEN

	        NULL;

	   WHEN OTHERS THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNER_SITES');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', 1);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'TP_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TP_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'TP_SITE_CODE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.TP_SITE_CODE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'LOCATION');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.LOCATION);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	END;


	END LOOP;

	COMMIT;

	lv_ins_records := 0;
	IF MSC_CL_COLLECTION.v_apps_ver < MSC_UTIL.G_APPS115 AND MSC_CL_COLLECTION.v_apps_ver <> -1 THEN

	/* For 107 and 110 the vendor_id and vendor
	   site id can be duplicate, therefore we use
	   the cursors to handle such exceptions, but for 11i we can use a straight
	   Insert-as-select to improve performance */

	FOR c_rec IN c10 LOOP

	BEGIN

	INSERT INTO MSC_TP_SITE_ID_LID
	( /* SCE Change starts*/
	  SR_COMPANY_ID,
	  /* SCE Change ends*/
	  SR_TP_SITE_ID,
	  SR_INSTANCE_ID,
	  Partner_Type,
	  TP_SITE_ID)
	VALUES
	( c_rec.SR_COMPANY_ID,
	  c_rec.SR_TP_SITE_ID,
	  c_rec.SR_INSTANCE_ID,
	  2,
	  c_rec.PARTNER_SITE_ID);


	EXCEPTION

	   WHEN DUP_VAL_ON_INDEX THEN

	     MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TP_SITE_ID_LID');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', 2);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_WARNING;

	   WHEN OTHERS THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TP_SITE_ID_LID');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', 2);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	END;

	END LOOP;

	ELSE

	INSERT /*+ APPEND */ INTO MSC_TP_SITE_ID_LID
	( SR_COMPANY_ID,
	  SR_TP_SITE_ID,
	  SR_INSTANCE_ID,
	  Partner_Type,
	  location_id,
	  TP_SITE_ID,
	  SR_CUST_ACCT_ID)
	SELECT  distinct
	           nvl(msts.company_id, -1) SR_COMPANY_ID,
	           msts.SR_TP_SITE_ID,
	           msts.SR_INSTANCE_ID,
	           2,
	           msts.location_id,
	           mtp.PARTNER_SITE_ID,
	           msts.SR_TP_ID
	      FROM MSC_ST_TRADING_PARTNER_SITES msts,
	           MSC_TP_ID_LID mtil,
	           MSC_TRADING_PARTNER_SITES mtp
	     WHERE NOT EXISTS( select 1
	                         from MSC_TP_SITE_ID_LID mtsil
	                        where msts.SR_TP_SITE_ID= mtsil.SR_TP_SITE_ID
	                          and msts.SR_INSTANCE_ID= mtsil.SR_INSTANCE_ID
	                          and mtsil.Partner_Type= 2
	                          and nvl(msts.company_id, -1) = mtsil.sr_company_id)
	       AND NVL( msts.Operating_Unit_Name, ' ')=
	           NVL( mtp.Operating_Unit_Name, ' ')
	       AND msts.TP_Site_Code= mtp.TP_Site_Code
	       AND msts.Location= mtp.Location
	       AND msts.SR_TP_ID= mtil.SR_TP_ID
	       AND msts.SR_INSTANCE_ID= mtil.SR_INSTANCE_ID
	       AND msts.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
	       AND nvl(msts.company_id, -1) = mtil.SR_COMPANY_ID
	       AND mtil.TP_ID= mtp.Partner_ID
	       AND mtp.partner_type = mtil.partner_type
	       AND mtil.Partner_Type= msts.partner_type
	       AND msts.Partner_Type= 2;
	lv_ins_records := SQL%ROWCOUNT;
	END IF;

	COMMIT;
	/* Bug7679044 */
	IF lv_tp_site_stat_stale = MSC_UTIL.SYS_YES OR lv_ins_records > lv_tp_site_id_count * 0.2 THEN
       msc_analyse_tables_pk.analyse_table( 'MSC_TP_SITE_ID_LID');
       lv_tp_site_stat_stale := MSC_UTIL.SYS_NO;
       lv_tp_site_id_count := lv_tp_site_id_count + lv_ins_records;
    END IF;

	--================ Collect Vendor/Customer

	FOR c_rec IN c1 LOOP

	BEGIN

	UPDATE MSC_TRADING_PARTNERS mtp
	 SET ORGANIZATION_CODE= c_rec.ORGANIZATION_CODE,
	     SR_TP_ID= c_rec.SR_TP_ID,
	     DISABLE_DATE= c_rec.Disable_Date,
	     STATUS= c_rec.Status,
	     MASTER_ORGANIZATION= c_rec.Master_Organization,
	     WEIGHT_UOM= c_rec.WEIGHT_UOM,
	     MAXIMUM_WEIGHT= c_rec.MAXIMUM_WEIGHT,
	     VOLUME_UOM= c_rec.VOLUME_UOM,
	     MAXIMUM_VOLUME= c_rec.MAXIMUM_VOLUME,
	     PARTNER_NUMBER= c_rec.PARTNER_NUMBER,
	     CALENDAR_CODE= c_rec.CALENDAR_CODE,
	     CALENDAR_EXCEPTION_SET_ID= c_rec.CALENDAR_EXCEPTION_SET_ID,
	     OPERATING_UNIT= c_rec.OPERATING_UNIT,
	     SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID,
	     PROJECT_REFERENCE_ENABLED= c_rec.PROJECT_REFERENCE_ENABLED,
	     PROJECT_CONTROL_LEVEL= c_rec.PROJECT_CONTROL_LEVEL,
	     CUSTOMER_CLASS_CODE = c_rec.CUSTOMER_CLASS_CODE,
	     CUSTOMER_TYPE = c_rec.CUSTOMER_TYPE,
	     LAST_UPDATE_DATE = MSC_CL_COLLECTION.v_current_date,
	     LAST_UPDATED_BY = MSC_CL_COLLECTION.v_current_user,
	     CREATION_DATE = MSC_CL_COLLECTION.v_current_date,
	     CREATED_BY = MSC_CL_COLLECTION.v_current_user
	WHERE mtp.Partner_ID= c_rec.TP_ID;

	EXCEPTION

	   WHEN DUP_VAL_ON_INDEX  THEN

	     NULL;

	   WHEN OTHERS THEN

	    IF SQLCODE IN (-01683,-1653,-1654) THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNERS');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_TYPE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	    ELSE

	      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNERS');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_TYPE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_WARNING;

	    END IF;

	END;

	END LOOP;

	COMMIT;

	--================ Collect Vendor/Customer Sites

	FOR c_rec IN c2 LOOP

	BEGIN
	  UPDATE MSC_Trading_Partner_Sites mtps
	     SET mtps.PARTNER_ADDRESS= c_rec.PARTNER_ADDRESS,
	         mtps.LONGITUDE= NVL( c_rec.LONGITUDE, mtps.LONGITUDE),
	         mtps.LATITUDE= NVL( c_rec.LATITUDE, mtps.LATITUDE),
	         mtps.SR_TP_SITE_ID= c_rec.SR_TP_SITE_ID,
	         mtps.PARTNER_TYPE= c_rec.Partner_Type,
	         mtps.POSTAL_CODE = c_rec.POSTAL_CODE,
	         mtps.CITY = c_rec.CITY,
	         mtps.STATE = c_rec.STATE,
	         mtps.COUNTRY = c_rec.COUNTRY,
	         mtps.SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID,
	         mtps.DELETED_FLAG= MSC_UTIL.SYS_NO,
	         mtps.REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 mtps.SHIPPING_CONTROL=c_rec.SHIPPING_CONTROL,
	         mtps.LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
	         mtps.LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
	         mtps.CREATION_DATE= MSC_CL_COLLECTION.v_current_date,
	         mtps.CREATED_BY= MSC_CL_COLLECTION.v_current_user
	   WHERE mtps.PARTNER_SITE_ID= c_rec.TP_SITE_ID;

	EXCEPTION

	   WHEN OTHERS THEN

	    IF SQLCODE IN (-1653,-1654) THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNER_SITES');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_TYPE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	    ELSE

	      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
	      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
	      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'GENERATE_TRADING_PARTNER_KEYS');
	      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_TRADING_PARTNER_SITES');
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'PARTNER_TYPE');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.PARTNER_TYPE);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
	      FND_MESSAGE.SET_TOKEN('COLUMN', 'SR_TP_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SR_TP_SITE_ID);
	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_WARNING;

	    END IF;

	END;

	END LOOP;

	COMMIT;

	  /* analyse the key mapping tables */
	  IF lv_tp_stat_stale = MSC_UTIL.SYS_YES  THEN
	     msc_analyse_tables_pk.analyse_table( 'MSC_TP_ID_LID');
      END IF;
      IF lv_tp_site_stat_stale = MSC_UTIL.SYS_YES  THEN
	     msc_analyse_tables_pk.analyse_table( 'MSC_TP_SITE_ID_LID');
      END IF;

	EXCEPTION

	  WHEN OTHERS THEN

	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);

	      ERRBUF := sqlerrm;
	      RETCODE := MSC_UTIL.G_ERROR;
	      RAISE;

	   END GENERATE_TRADING_PARTNER_KEYS;

	   /*************** PREPLACE CHANGE START *****************/

   PROCEDURE GET_COLL_PARAM (p_instance_id NUMBER) AS

   BEGIN

    /* Initialize the global prec record variable */

    IF (MSC_CL_COLLECTION.v_prec_defined = FALSE) THEN
       SELECT delete_ods_data,org_group, supplier_capacity, atp_rules,
              bom, bor, calendar_check, demand_class,ITEM_SUBSTITUTES, forecast, item,
              kpi_targets_bis, mds, mps, oh, parameter, planners,
              projects, po, reservations, nra, safety_stock,
              sales_order, sourcing_history, sourcing, sub_inventories,
              customer, supplier, unit_numbers, uom, user_supply_demand, wip, user_comp_association,po_receipts,
              bom_sn_flag,  bor_sn_flag,    item_sn_flag, oh_sn_flag,
              usup_sn_flag, udmd_sn_flag,   so_sn_flag,   fcst_sn_flag,
              wip_sn_flag,  supcap_sn_flag, po_sn_flag,   mds_sn_flag,
              mps_sn_flag,  nosnap_flag
			  /* CP-ACK starts */
			  ,supplier_response
			  /* CP-ACK ends */
              /* CP-AUTO */
              ,suprep_sn_flag, trip,trip_sn_flag,ds_mode
              , sales_channel, fiscal_calendar,internal_repair,external_repair  -- changed for bug 5909379 SRP addition
              ,payback_demand_supply
	      ,currency_conversion,delivery_details,CMRO
         INTO MSC_CL_COLLECTION.v_coll_prec.purge_ods_flag,MSC_CL_COLLECTION.v_coll_prec.org_group_flag, MSC_CL_COLLECTION.v_coll_prec.app_supp_cap_flag,
              MSC_CL_COLLECTION.v_coll_prec.atp_rules_flag, MSC_CL_COLLECTION.v_coll_prec.bom_flag,
              MSC_CL_COLLECTION.v_coll_prec.bor_flag, MSC_CL_COLLECTION.v_coll_prec.calendar_flag,
              MSC_CL_COLLECTION.v_coll_prec.demand_class_flag,MSC_CL_COLLECTION.v_coll_prec.item_subst_flag, MSC_CL_COLLECTION.v_coll_prec.forecast_flag,
              MSC_CL_COLLECTION.v_coll_prec.item_flag, MSC_CL_COLLECTION.v_coll_prec.kpi_bis_flag,
              MSC_CL_COLLECTION.v_coll_prec.mds_flag, MSC_CL_COLLECTION.v_coll_prec.mps_flag,
              MSC_CL_COLLECTION.v_coll_prec.oh_flag, MSC_CL_COLLECTION.v_coll_prec.parameter_flag,
              MSC_CL_COLLECTION.v_coll_prec.planner_flag, MSC_CL_COLLECTION.v_coll_prec.project_flag,
              MSC_CL_COLLECTION.v_coll_prec.po_flag, MSC_CL_COLLECTION.v_coll_prec.reserves_flag,
              MSC_CL_COLLECTION.v_coll_prec.resource_nra_flag, MSC_CL_COLLECTION.v_coll_prec.saf_stock_flag,
              MSC_CL_COLLECTION.v_coll_prec.sales_order_flag, MSC_CL_COLLECTION.v_coll_prec.source_hist_flag,
              MSC_CL_COLLECTION.v_coll_prec.sourcing_rule_flag, MSC_CL_COLLECTION.v_coll_prec.sub_inventory_flag,
              MSC_CL_COLLECTION.v_coll_prec.tp_customer_flag, MSC_CL_COLLECTION.v_coll_prec.tp_vendor_flag,
              MSC_CL_COLLECTION.v_coll_prec.unit_number_flag, MSC_CL_COLLECTION.v_coll_prec.uom_flag,
              MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag, MSC_CL_COLLECTION.v_coll_prec.wip_flag, MSC_CL_COLLECTION.v_coll_prec.user_company_flag,
              MSC_CL_COLLECTION.v_coll_prec.po_receipts_flag,
              MSC_CL_COLLECTION.v_coll_prec.bom_sn_flag,  MSC_CL_COLLECTION.v_coll_prec.bor_sn_flag,
              MSC_CL_COLLECTION.v_coll_prec.item_sn_flag, MSC_CL_COLLECTION.v_coll_prec.oh_sn_flag,
              MSC_CL_COLLECTION.v_coll_prec.usup_sn_flag, MSC_CL_COLLECTION.v_coll_prec.udmd_sn_flag,
              MSC_CL_COLLECTION.v_coll_prec.so_sn_flag,   MSC_CL_COLLECTION.v_coll_prec.fcst_sn_flag,
              MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag,
              MSC_CL_COLLECTION.v_coll_prec.supcap_sn_flag, MSC_CL_COLLECTION.v_coll_prec.po_sn_flag,
              MSC_CL_COLLECTION.v_coll_prec.mds_sn_flag, MSC_CL_COLLECTION.v_coll_prec.mps_sn_flag,
              MSC_CL_COLLECTION.v_coll_prec.nosnap_flag
			  /* CP-ACK starts */
			  ,MSC_CL_COLLECTION.v_coll_prec.supplier_response_flag
			  /* CP-ACK ends */
              /* CP-AUTO */
              ,MSC_CL_COLLECTION.v_coll_prec.suprep_sn_flag, MSC_CL_COLLECTION.v_coll_prec.trip_flag,MSC_CL_COLLECTION.v_coll_prec.trip_sn_flag , MSC_CL_COLLECTION.v_coll_prec.ds_mode
              ,MSC_CL_COLLECTION.v_coll_prec.sales_channel_flag,MSC_CL_COLLECTION.v_coll_prec.fiscal_calendar_flag,MSC_CL_COLLECTION.v_coll_prec.internal_repair_flag,MSC_CL_COLLECTION.v_coll_prec.external_repair_flag
              ,MSC_CL_COLLECTION.v_coll_prec.payback_demand_supply_flag
	      ,MSC_CL_COLLECTION.v_coll_prec.currency_conversion_flag
	      ,MSC_CL_COLLECTION.v_coll_prec.delivery_details_flag,MSC_CL_COLLECTION.v_coll_prec.CMRO_flag
         FROM msc_coll_parameters
        WHERE instance_id = p_instance_id;
        MSC_CL_COLLECTION.v_prec_defined := TRUE;
    END IF;

   END GET_COLL_PARAM;

     PROCEDURE GET_COLL_PARAM
                   (p_instance_id IN  NUMBER,
                    v_prec        OUT NOCOPY MSC_CL_EXCHANGE_PARTTBL.CollParamREC) AS

   BEGIN

    /* Initialize the global prec record variable */

       SELECT delete_ods_data,org_group, supplier_capacity, atp_rules,
              bom, bor, calendar_check, demand_class,ITEM_SUBSTITUTES, forecast, item,
              kpi_targets_bis, mds, mps, oh, parameter, planners,
              projects, po, reservations, nra, safety_stock,
              sales_order, sourcing_history, sourcing, sub_inventories,
              customer, supplier, unit_numbers, uom, user_supply_demand, wip, user_comp_association,
              po_receipts,
              bom_sn_flag,  bor_sn_flag,    item_sn_flag, oh_sn_flag,
              usup_sn_flag, udmd_sn_flag,   so_sn_flag,   fcst_sn_flag,
              wip_sn_flag,  supcap_sn_flag, po_sn_flag,   mds_sn_flag,
              mps_sn_flag,  nosnap_flag
              /* CP-ACK starts */
              ,supplier_response
              /* CP-ACK ends */
              /* CP-AUTO */
              ,suprep_sn_flag, trip,trip_sn_flag, ds_mode
              ,sales_channel,fiscal_calendar,internal_repair,external_repair
              ,payback_demand_supply
	      ,currency_conversion,delivery_details,CMRO
         INTO v_prec.purge_ods_flag,v_prec.org_group_flag, v_prec.app_supp_cap_flag,
              v_prec.atp_rules_flag, v_prec.bom_flag,
              v_prec.bor_flag, v_prec.calendar_flag,
              v_prec.demand_class_flag, v_prec.item_subst_flag,v_prec.forecast_flag,
              v_prec.item_flag, v_prec.kpi_bis_flag,
              v_prec.mds_flag, v_prec.mps_flag,
              v_prec.oh_flag, v_prec.parameter_flag,
              v_prec.planner_flag, v_prec.project_flag,
              v_prec.po_flag, v_prec.reserves_flag,
              v_prec.resource_nra_flag, v_prec.saf_stock_flag,
              v_prec.sales_order_flag, v_prec.source_hist_flag,
              v_prec.sourcing_rule_flag, v_prec.sub_inventory_flag,
              v_prec.tp_customer_flag, v_prec.tp_vendor_flag,
              v_prec.unit_number_flag, v_prec.uom_flag,
              v_prec.user_supply_demand_flag, v_prec.wip_flag, v_prec.user_company_flag,
              v_prec.po_receipts_flag,
              v_prec.bom_sn_flag,  v_prec.bor_sn_flag,
              v_prec.item_sn_flag, v_prec.oh_sn_flag,
              v_prec.usup_sn_flag, v_prec.udmd_sn_flag,
              v_prec.so_sn_flag,   v_prec.fcst_sn_flag,
              v_prec.wip_sn_flag,
              v_prec.supcap_sn_flag, v_prec.po_sn_flag,
              v_prec.mds_sn_flag, v_prec.mps_sn_flag,
              v_prec.nosnap_flag
              /* CP-ACK starts */
              ,v_prec.supplier_response_flag
              /* CP-ACK ends */
              /* CP-AUTO */
              ,v_prec.suprep_sn_flag,v_prec.trip_flag,v_prec.trip_sn_flag,v_prec.ds_mode
              ,v_prec.sales_channel_flag,v_prec.fiscal_calendar_flag,v_prec.internal_repair_flag,v_prec.external_repair_flag
              ,v_prec.payback_demand_supply_flag
	      ,v_prec.currency_conversion_flag
	      ,v_prec.delivery_details_flag,v_prec.CMRO_flag
         FROM msc_coll_parameters
        WHERE instance_id = p_instance_id;
   END GET_COLL_PARAM;

END MSC_CL_SETUP_ODS_LOAD;

/
