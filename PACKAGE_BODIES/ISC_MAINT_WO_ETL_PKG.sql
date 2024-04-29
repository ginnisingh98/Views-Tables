--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_WO_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_WO_ETL_PKG" AS
/*$Header: iscmaintwoetlb.pls 120.3 2006/01/03 03:04:30 nbhamidi noship $ */

g_sysdate DATE := SYSDATE;
g_user_id NUMBER := nvl(fnd_global.user_id, -1);
g_login_id NUMBER := nvl(fnd_global.login_id, -1);
g_global_start_date DATE := SYSDATE;
g_last_collection_date DATE;
g_ok NUMBER(1) := 0;
g_warning NUMBER(1) := 1;
g_error NUMBER(1) := -1;
g_program_id             NUMBER := fnd_global.CONC_PROGRAM_ID;
g_program_login_id       NUMBER := fnd_global.CONC_LOGIN_ID;
g_program_application_id NUMBER := fnd_global.PROG_APPL_ID;
g_request_id             NUMBER := fnd_global.CONC_REQUEST_ID;


FUNCTION Save_Last_Collection_Date RETURN BOOLEAN
IS

 CURSOR c_Last_Collection_Date is
 Select Last_Update_Date
 from ISC_MAINT_WORK_ORDERS_F
 WHERE Organization_id = -99 and Work_Order_id = -99 and Entity_Type = -1;

 l_last_update_date DATE;
 l_stmt_num number;
 l_err_num  NUMBER;
 l_err_msg  VARCHAR2(255);

BEGIN

 l_stmt_num := 10;
 OPEN c_Last_Collection_Date;
 FETCH c_Last_Collection_Date into l_last_update_date;
 IF c_Last_Collection_Date %notfound THEN

    l_stmt_num := 20;
    INSERT INTO ISC_MAINT_WORK_ORDERS_F
      (ORGANIZATION_ID, WORK_ORDER_ID, WORK_ORDER_NAME, ENTITY_TYPE, CREATION_DATE,
       LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	   program_id, program_login_id, program_application_id, request_id)
    VALUES(-99, -99, 'LAST COLLECTION DATE', -1, SYSDATE, SYSDATE, -1, -1, -1, -1, -1, -1, -1);

 ELSE

    l_stmt_num := 30;
    UPDATE ISC_MAINT_WORK_ORDERS_F
      SET LAST_UPDATE_DATE = SYSDATE
    WHERE Organization_id = -99 and Work_Order_id = -99 and Entity_Type = -1;

 END IF;

 commit;

 RETURN TRUE;

EXCEPTION

 WHEN OTHERS THEN
   rollback;
   l_err_num := SQLCODE;
   l_err_msg := 'ISC_MAINT_WO_ETL_PKG.Save_Last_Collection_Date ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);

   BIS_COLLECTION_UTILITIES.put_line('ISC_MAINT_WO_ETL_PKG.Save_Last_Collection_Date - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

   BIS_COLLECTION_UTILITIES.put_line('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.put_line('Error Message: ' || l_err_msg);

   return FALSE;

END Save_Last_Collection_Date;



PROCEDURE GET_WORK_ORDERS_INITIAL_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num        NUMBER;
 l_row_count   	   NUMBER;
 l_err_num 	   NUMBER;
 l_err_msg 	   VARCHAR2(255);
 l_isc_schema      VARCHAR2(30);
 l_status          VARCHAR2(30);
 l_industry        VARCHAR2(30);
 l_list dbms_sql.varchar2_table;
BEGIN

 l_list(1) := 'BIS_GLOBAL_START_DATE';

 IF (bis_common_parameters.check_global_parameters(l_list)) THEN

 IF BIS_COLLECTION_UTILITIES.SETUP( 'ISC_MAINT_WORK_ORDERS_F' ) = FALSE THEN
    RAISE_APPLICATION_ERROR(-20000, errbuf);
 End if;

 l_stmt_num := 1;
 IF fnd_installation.get_app_info( 'ISC', l_status, l_industry, l_isc_schema) THEN
    -- execute immediate 'truncate table ' || l_isc_schema || '.MLOG$_ISC_MAINT_WORK_ORDER'; -- RSG will now take care of this
    execute immediate 'truncate table ' || l_isc_schema || '.ISC_MAINT_WORK_ORDERS_F PURGE MATERIALIZED VIEW LOG';
 END IF;

 l_stmt_num := 10;
 BEGIN
  select BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE into g_global_start_date from DUAL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BIS_COLLECTION_UTILITIES.put_line('Global start date is not available. Cannot proceed.');
      BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
      retcode := SQLCODE;
      errbuf := SQLERRM;
      return;
 END;

 -- Store current sysdate as the Last Collection Date.
 l_stmt_num := 20;
 if Save_Last_Collection_Date = FALSE THEN
    BIS_COLLECTION_UTILITIES.put_line('Failed to store current sysdate as the Last Collection Date.');
    RAISE_APPLICATION_ERROR(-20000, errbuf);
 end if;


 l_stmt_num := 30;
 /* Insert into Work Orders Fact Table */

 /* EAM Work Orders master extraction into DBI EAM Work Orders Base Table */

 INSERT /*+ append parallel(ISC_MAINT_WORK_ORDERS_F) */ INTO ISC_MAINT_WORK_ORDERS_F
 (
 	 Organization_id
	,Work_Order_id
	,Work_Order_Name
	,Description
	,Entity_Type
	,Work_Order_Type
	,Status_Type
	,Department_id
	,Released_date
	,WO_Creation_date
	,WO_Creation_datetime
	,DBI_Completion_date
	,Completion_date
	,Completion_datetime
	,Closed_date
	,Scheduled_Start_date
	,DBI_Scheduled_Completion_date
	,Scheduled_Completion_date
	,Last_Estimation_Date
	,Days_Late
	,Include_WO
	,Asset_Group_id
	,Activity_id
	,instance_id             -- added as part of R12
	,user_defined_status_id  -- added as part of R12
	,Creation_Date
	,Last_Update_Date
	,Created_By
	,Last_Updated_By
	,Last_Update_Login
	,program_id
	,program_login_id
	,program_application_id
	,request_id
 )
 Select /*+ use_hash(WDJ) use_hash(WE) parallel(WDJ) parallel(WE) */
	 we.ORGANIZATION_ID Organization_ID
	,we.wip_entity_id Work_Order_id
	,we.WIP_ENTITY_NAME Work_order_name
	,wdj.Description Description
	,decode(we.ENTITY_TYPE,6,1,7,2,-1) Entity_Type
	,nvl(wdj.WORK_ORDER_TYPE, -1) Work_Order_Type
	,wdj.STATUS_TYPE Status_Type
	,nvl(wdj.owning_department,-1) department_id
	,trunc(wdj.DATE_RELEASED) Released_date
	,CASE WHEN trunc(wdj.creation_date)  < g_global_start_date THEN g_global_start_date
	      ELSE trunc(wdj.creation_date)
	 END  wo_creation_date /* To start counting work order backlog from GSD */
 	,CASE WHEN trunc(wdj.creation_date)  < g_global_start_date THEN g_global_start_date
	      ELSE wdj.creation_date
	 END  wo_creation_datetime
 	,CASE WHEN nvl(trunc(wdj.DATE_COMPLETED),trunc(wdj.DATE_CLOSED)) < g_global_start_date THEN g_global_start_date
	      ELSE nvl(trunc(wdj.DATE_COMPLETED),trunc(wdj.DATE_CLOSED))
	 END  DBI_Completion_Date
	,trunc(wdj.DATE_COMPLETED) Completion_Date
	,wdj.DATE_COMPLETED Completion_Datetime
	,trunc(wdj.DATE_CLOSED) Closed_date
	,trunc(wdj.SCHEDULED_START_DATE) Scheduled_Start_Date
	,CASE WHEN trunc(wdj.SCHEDULED_COMPLETION_DATE) < g_global_start_date THEN g_global_start_date
	      ELSE trunc(wdj.SCHEDULED_COMPLETION_DATE)
	 END  DBI_Scheduled_Completion_Date /* To start counting past due work orders from GSD */
	,trunc(wdj.SCHEDULED_COMPLETION_DATE) Scheduled_Completion_Date /* For display and conditions in drill down reports */
	,wdj.LAST_ESTIMATION_DATE /* Used by Work Order Costing ETL */
	,trunc(wdj.DATE_COMPLETED) - trunc(wdj.SCHEDULED_COMPLETION_DATE) Days_Late
	, CASE WHEN wdj.STATUS_TYPE in (14, 15, 7) THEN 0  /* Do not include Pending Close, Failed Close, Cancelled in reports */
	  	   WHEN wdj.DATE_COMPLETED is null and wdj.DATE_CLOSED is not null THEN 0 /* This WO's were Cancelled */
		   ELSE 1
	 END Include_WO
	,nvl(wdj.ASSET_GROUP_ID, wdj.REBUILD_ITEM_ID) Asset_Group_ID
	,nvl(we.PRIMARY_ITEM_ID, -1) Activity_ID
	,case wdj.maintenance_object_type
	when 2 then -1				/* to include assets and rebuilds */
	when 3 then nvl(wdj.maintenance_object_id,-1)
	end instance_id
	,ewod.user_defined_status_id user_defined_status_id
	,g_sysdate  CREATION_DATE
	,g_sysdate  LAST_UPDATE_DATE
	,g_user_id  CREATED_BY
	,g_user_id  LAST_UPDATED_BY
	,g_login_id LAST_UPDATE_LOGIN
	,g_program_id program_id
	,g_program_login_id program_login_id
	,g_program_application_id program_application_id
	,g_request_id request_id
 From
 	 WIP_DISCRETE_JOBS WDJ, WIP_ENTITIES WE , EAM_WORK_ORDER_DETAILS ewod
 WHERE
     WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
 AND ENTITY_TYPE  in (6, 7)   /* Maintenance job, Closed maintenance job */
 AND wdj.maintenance_object_source = 1  /* Work Orders created by EAM only */
 AND wdj.JOB_TYPE = 3 /* Non-standard job */
 AND nvl(wdj.DATE_CLOSED, sysdate) >= g_global_start_date
 AND WDJ.WIP_ENTITY_ID = ewod.WIP_ENTITY_ID
 AND wdj. maintenance_object_type in(2,3) ; /* change as per eam-ib change to cater to assets and rebuilds */

 l_row_count := sql%rowcount;
 commit;

 BIS_COLLECTION_UTILITIES.PUT_LINE('Finished EAM Work Orders Extraction into Base Table: '|| l_row_count || ' row(s) inserted');


 BIS_COLLECTION_UTILITIES.WRAPUP(
    p_status => TRUE,
    p_count => l_row_count,
    p_message => 'Successfully loaded EAM Work Orders Base table at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
 );

 ELSE
     retcode := g_error;
     BIS_COLLECTION_UTILITIES.PUT_LINE('Global Parameters are not setup.');
     BIS_COLLECTION_UTILITIES.PUT_LINE('Please check that the profile option BIS_GLOBAL_START_DATE is setup.');

 END IF;

EXCEPTION
 WHEN OTHERS THEN
   rollback;

   l_err_num := SQLCODE;
   l_err_msg := 'ISC_MAINT_WO_ETL_PKG.GET_WORK_ORDERS_INITIAL_LOAD ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);
   BIS_COLLECTION_UTILITIES.PUT_LINE('ISC_MAINT_WO_ETL_PKG.GET_WORK_ORDERS_INITIAL_LOAD - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
   BIS_COLLECTION_UTILITIES.WRAPUP( FALSE,
                                    l_row_count,
                                    'EXCEPTION '|| l_err_num||' : '||l_err_msg
                                  );

   retcode := SQLCODE;
   errbuf := SQLERRM;
   RAISE_APPLICATION_ERROR(-20000, errbuf);
   /*please note that this api will commit!!*/

END GET_WORK_ORDERS_INITIAL_LOAD;




PROCEDURE GET_WORK_ORDERS_INCR_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_list dbms_sql.varchar2_table;
BEGIN

 l_list(1) := 'BIS_GLOBAL_START_DATE';

 IF (bis_common_parameters.check_global_parameters(l_list)) THEN

 IF BIS_COLLECTION_UTILITIES.SETUP( 'ISC_MAINT_WORK_ORDERS_F' ) = FALSE THEN
    RAISE_APPLICATION_ERROR(-20000, errbuf);
 End if;

 l_stmt_num := 10;
 BEGIN
  select BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE into g_global_start_date from DUAL;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BIS_COLLECTION_UTILITIES.put_line('Global start date is not available. Cannot proceed.');
      BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
      retcode := SQLCODE;
      errbuf := SQLERRM;
      return;
   WHEN OTHERS then /* added as a part of standard */
   return;
 END;

 l_stmt_num := 20;
 BEGIN
   SELECT Last_Update_Date INTO g_last_collection_date FROM ISC_MAINT_WORK_ORDERS_F
   WHERE Organization_id = -99 and Work_Order_id = -99 and Entity_Type = -1;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BIS_COLLECTION_UTILITIES.put_line('Last collection date is not available. Cannot proceed.');
      BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
      retcode := SQLCODE;
      errbuf := SQLERRM;
      return;
   when OTHERS then /* added as a part of standard */
   return;
 END;


 l_stmt_num := 30;
 -- Store current sysdate as the Last Collection Date.
 if Save_Last_Collection_Date = FALSE THEN
    BIS_COLLECTION_UTILITIES.put_line('Failed to store current sysdate as the Last Collection Date.');
    RAISE_APPLICATION_ERROR(-20000, errbuf);
 end if;


 l_stmt_num := 40;
 /* EAM Work Orders extraction into Work Orders Base Table */

 MERGE INTO ISC_MAINT_WORK_ORDERS_F f USING
  (
  Select
		 Organization_id
		,Work_Order_id
		,Work_Order_Name
		,Description
		,Entity_Type
		,Work_Order_Type
		,Status_Type
		,department_id
		,Released_date
		,WO_Creation_date
		,WO_Creation_datetime
		,DBI_Completion_date
		,Completion_date
		,Completion_datetime
		,Closed_date
		,Scheduled_Start_date
		,DBI_Scheduled_Completion_date
		,Scheduled_Completion_date
		,Last_estimation_date
		,days_late
		,Include_WO
		,Asset_Group_id
		,Activity_id
		,instance_id			--added as part of R12
		,user_defined_Status_id         --added as part of R12
		,g_sysdate  CREATION_DATE
		,g_sysdate  LAST_UPDATE_DATE
		,g_user_id  CREATED_BY
		,g_user_id  LAST_UPDATED_BY
		,g_login_id LAST_UPDATE_LOGIN
		,g_program_id			program_id
		,g_program_login_id		program_login_id
		,g_program_application_id program_application_id
		,g_request_id 			  request_id
  from
  (
   Select
		 we.ORGANIZATION_ID Organization_ID
		,we.wip_entity_id Work_Order_id
		,we.WIP_ENTITY_NAME Work_order_name
		,wdj.Description Description
		,decode(we.ENTITY_TYPE,6,1,7,2,-1) Entity_Type
		,nvl(wdj.WORK_ORDER_TYPE, -1) Work_Order_Type
		,wdj.STATUS_TYPE status_Type
		,nvl(wdj.owning_department,-1) department_id
		,trunc(wdj.DATE_RELEASED) Released_date
		,CASE WHEN trunc(wdj.creation_date) < g_global_start_date THEN g_global_start_date
		      ELSE trunc(wdj.creation_date)
		 END  wo_creation_date /* To start counting work order backlog from GSD */
 		,CASE WHEN trunc(wdj.creation_date) < g_global_start_date THEN g_global_start_date
		      ELSE wdj.creation_date
		 END  wo_creation_datetime
		,CASE WHEN nvl(trunc(wdj.DATE_COMPLETED),trunc(wdj.DATE_CLOSED)) < g_global_start_date THEN g_global_start_date
			ELSE nvl(trunc(wdj.DATE_COMPLETED),trunc(wdj.DATE_CLOSED))
		 END DBI_Completion_Date /* In case a new work order is created after GSD w/o completion date and then completed before GSD */
		,trunc(wdj.DATE_COMPLETED) Completion_Date
		,wdj.DATE_COMPLETED Completion_Datetime
		,trunc(wdj.DATE_CLOSED) Closed_date
		,trunc(wdj.SCHEDULED_START_DATE) Scheduled_Start_Date
		,CASE WHEN trunc(wdj.SCHEDULED_COMPLETION_DATE) < g_global_start_date THEN g_global_start_date
		     ELSE trunc(wdj.SCHEDULED_COMPLETION_DATE)
		 END  DBI_Scheduled_Completion_Date /* In case a new work order is created after GSD with scheduled completion date before GSD */
		,trunc(wdj.SCHEDULED_COMPLETION_DATE) Scheduled_Completion_Date
		,wdj.LAST_ESTIMATION_DATE /* Used by Work Order Costing ETL */
		,trunc(wdj.DATE_COMPLETED) - trunc(wdj.SCHEDULED_COMPLETION_DATE) days_late
		, CASE WHEN wdj.STATUS_TYPE in (14, 15, 7) THEN 0  /* Do not include Pending Close, Failed Close, Cancelled in reports */
	  	   WHEN wdj.DATE_COMPLETED is null and wdj.DATE_CLOSED is not null THEN 0 /* This WO's were Cancelled */
		   ELSE 1
		 END Include_WO
		,nvl(wdj.ASSET_GROUP_ID, wdj.REBUILD_ITEM_ID) Asset_Group_ID
		,nvl(we.PRIMARY_ITEM_ID, -1) Activity_ID
		,case wdj.maintenance_object_type
		  when 2 then -1				/* to include assets and rebuilds */
		  when 3 then nvl(wdj.maintenance_object_id,-1)
		  end instance_id
		,ewod.user_defined_Status_id user_Defined_Status_id
		,wdj.last_update_date
   From
   	   	WIP_DISCRETE_JOBS WDJ, WIP_ENTITIES WE , eam_work_order_details ewod
   WHERE
        WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	AND we.ENTITY_TYPE  in (6, 7)   /* Maintenance job, Closed maintenance job */
	AND wdj.JOB_TYPE = 3 /* Non-standard job */
	AND wdj.maintenance_object_source = 1 /* Work Orders created by EAM only */
	AND nvl(wdj.date_closed, sysdate) >= g_global_start_date
	AND WDJ.WIP_ENTITY_ID = ewod.WIP_ENTITY_ID
	and wdj.maintenance_object_type in (2,3)  /* change as per eam-ib to include assets and rebuilds */
	and (
	wdj.last_update_date > g_last_collection_date
	or ewod.last_update_date > g_last_collection_date
	)
	-- New Work Orders and existing work orders that have been updated
  )) s
  ON (f.Organization_id    = s.Organization_id
     and f.Work_Order_id  = s.Work_Order_id
    )
  WHEN MATCHED THEN
     UPDATE SET
 			 f.Entity_Type = s.Entity_Type
			,f.Description = s.Description
			,f.Work_Order_Type = s.Work_Order_Type
			,f.Status_Type = s.Status_Type
			,f.department_id = s.department_id
			,f.Released_date = s.Released_date
			,f.WO_Creation_date = s.WO_Creation_date
			,f.WO_Creation_datetime = s.WO_Creation_datetime
			,f.DBI_Completion_date = s.DBI_Completion_date
			,f.Completion_date = s.Completion_date
			,f.Completion_datetime = s.Completion_datetime
			,f.Closed_date = s.Closed_date
			,f.Scheduled_Start_date = s.Scheduled_Start_date
			,f.DBI_Scheduled_Completion_date = s.DBI_Scheduled_Completion_date
			,f.Scheduled_Completion_date = s.Scheduled_Completion_date
			,f.Last_estimation_date = s.Last_estimation_date
			,f.days_late = s.days_late
			,f.Include_WO = s.Include_WO
			,f.Asset_Group_id = s.Asset_Group_id
			,f.Activity_id = s.Activity_id
			,f.instance_id = s.instance_id
			,f.user_Defined_status_id = s.user_Defined_Status_id
			,f.Last_Update_Date = s.Last_Update_Date
			,f.Last_Updated_By = s.Last_Updated_By
			,f.Last_Update_Login = s.Last_Update_Login
			,f.program_id =	s.program_id
			,f.program_login_id = s.program_login_id
			,f.program_application_id = s.program_application_id
			,f.request_id = s.request_id
  WHEN NOT MATCHED THEN
     INSERT (Organization_id, Work_Order_id, Work_Order_Name, Description, Entity_Type, Work_Order_Type, Status_Type
             ,department_id, Released_date, DBI_Completion_date, WO_Creation_date, WO_Creation_datetime, Completion_date, Completion_datetime, Closed_date
			 ,Scheduled_Start_date, DBI_Scheduled_Completion_date, Scheduled_Completion_date, Last_estimation_date
             ,days_late, Include_WO, Asset_Group_id, Activity_id,instance_id,user_Defined_Status_id, CREATION_DATE, LAST_UPDATE_DATE
             ,CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, program_id, program_login_id, program_application_id, request_id)
     VALUES (s.Organization_id, s.Work_Order_id, s.Work_Order_Name, s.Description, s.Entity_Type, s.Work_Order_Type, s.Status_Type
             ,s.department_id, s.Released_date, s.DBI_Completion_date, s.WO_Creation_date, s.WO_Creation_datetime, s.Completion_date, s.Completion_datetime, s.Closed_date
			 ,s.Scheduled_Start_date, s.DBI_Scheduled_Completion_date, s.Scheduled_Completion_date, s.Last_estimation_date
             ,s.days_late, s.Include_WO, s.Asset_Group_id, s.Activity_id, s.instance_id, s.user_Defined_Status_id, s.CREATION_DATE, s.LAST_UPDATE_DATE
             ,s.CREATED_BY, s.LAST_UPDATED_BY, s.LAST_UPDATE_LOGIN, s.program_id, s.program_login_id, s.program_application_id, s.request_id);

 l_row_count := sql%rowcount;
 commit;

 BIS_COLLECTION_UTILITIES.PUT_LINE('Finished EAM Work Orders Extraction into Base Table: '|| l_row_count || ' row(s) inserted/updated');

 BIS_COLLECTION_UTILITIES.WRAPUP(
    p_status => TRUE,
    p_count => l_row_count,
    p_message => 'Successfully loaded EAM Work Orders Base table at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
 );

 ELSE
     retcode := g_error;
     BIS_COLLECTION_UTILITIES.PUT_LINE('Global Parameters are not setup.');
     BIS_COLLECTION_UTILITIES.PUT_LINE('Please check that the profile option BIS_GLOBAL_START_DATE is setup.');

 END IF;

EXCEPTION
 WHEN OTHERS THEN
   rollback;


   l_err_num := SQLCODE;
   l_err_msg := 'ISC_MAINT_WO_ETL_PKG.GET_WORK_ORDERS_INCR_LOAD ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);
   BIS_COLLECTION_UTILITIES.PUT_LINE('ISC_MAINT_WO_ETL_PKG.GET_WORK_ORDERS_INCR_LOAD - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
   BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

   retcode := SQLCODE;
   errbuf := SQLERRM;
   RAISE_APPLICATION_ERROR(-20000, errbuf);
   /*please note that this api will commit!!*/

END GET_WORK_ORDERS_INCR_LOAD;


End ISC_MAINT_WO_ETL_PKG;

/
