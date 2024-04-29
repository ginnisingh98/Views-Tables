--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPI_JOB_RSRC_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPI_JOB_RSRC_F_C" as
/* $Header: OPIMJRSB.pls 120.1 2005/06/07 03:28:51 appldev  $ */
 g_push_from_date          Date:=Null;
 g_push_to_date            Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_errbuf            VARCHAR2(2000):=NULL;
 g_retcode           VARCHAR2(200) :=NULL;


---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE by checking last_update_date
---------------------------------------------------
FUNCTION IDENTIFY_CHANGE( p_view_id   IN NUMBER,
			  p_count OUT NOCOPY NUMBER) RETURN NUMBER
  IS

     l_seq_id         NUMBER;
     l_opi_schema     VARCHAR2(30);
     l_status         VARCHAR2(30);
     l_industry       VARCHAR2(30);


     l_count1		NUMBER;
     l_count2		NUMBER;

BEGIN
     l_seq_id          := -1;
     l_count1	:= 0 ;
     l_count2	:= 0 ;
   p_count := 0;

   SELECT opi_edw_job_rsrc_inc_s.NEXTVAL INTO l_seq_id FROM dual;

   IF p_view_id = 1 THEN



      INSERT
	INTO opi_edw_OPI_job_rsrc_inc(primary_key1,primary_key2,primary_key3,primary_key4,primary_key5,primary_key6,seq_id,view_id)
	SELECT
	DISTINCT
		wor.organization_id,
		wor.wip_entity_id,
		wor.repetitive_schedule_id,
		wor.operation_seq_num,
		wor.resource_id,
		'OPI',
		l_seq_id,
		1
	FROM
		WIP_OPERATION_RESOURCES wor,
		WIP_OPERATIONS wo,
		/*WIP_MOVE_TRANSACTIONS wmt,WIP_MOVE_TRANSACTIONS wmt2, */
		WIP_DISCRETE_JOBS wdj,
		WIP_REPETITIVE_SCHEDULES wrs,
		WIP_ENTITIES we,
		BOM_DEPARTMENTS bd,
		HR_ORGANIZATION_INFORMATION hoi,
		GL_SETS_OF_BOOKS gsob
	WHERE
    		wor.organization_id = wo.organization_id
		and wor.wip_entity_id = wo.wip_entity_id
		and wor.operation_seq_num = wo.operation_seq_num
		and nvl(wor.repetitive_schedule_id,-99) = nvl(wo.repetitive_schedule_id,-99)
		and wo.organization_id = bd.organization_id
		and wo.department_id = bd.department_id
		and wo.organization_id = we.organization_id
		and wo.wip_entity_id = we.wip_entity_id
		and hoi.organization_id = wor.organization_id
		and to_char(gsob.set_of_books_id) =  hoi.ORG_INFORMATION1
		and hoi.ORG_INFORMATION_CONTEXT = 'Accounting Information'
		and wdj.wip_entity_id (+) = wor.wip_entity_id
		and wdj.organization_id (+) = wor.organization_id
		and wrs.repetitive_schedule_id (+)= nvl(wor.repetitive_schedule_id,-99)
		and wrs.organization_id (+) = wor.organization_id
		and (wrs.status_type in (4,5,7,12) or wdj.status_type in (4,5,7,12))
	 	and greatest(
				nvl(wor.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
				nvl(wrs.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
				nvl(wdj.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss'))
				)
	BETWEEN g_push_from_date and g_push_to_date
	UNION
	select
		distinct
        	primary_key1,
		primary_key2,
		primary_key3,
		primary_key4,
		primary_key5,
		primary_key6,
        	l_seq_id, /* NOTE : THIS IS THE NEW SEQ_ID */
        	view_id
        from
		opi_edw_opi_job_rsrc_mr_tmp
        where
		view_id = 1 ;

   ELSIF p_view_id = 2 THEN


      INSERT
	INTO opi_edw_opi_job_rsrc_inc(primary_key1,primary_key2,primary_key3,primary_key4,primary_key5,primary_key6,seq_id,view_id)
	SELECT
	DISTINCT
		wt.organization_id,
		wt.wip_entity_id,
		to_number(NULL),
		wt.operation_seq_num,
		wt.resource_id,
		'OPI',
		l_seq_id,
		2
	FROM
		WIP_ENTITIES we,
		WIP_TRANSACTIONS wt,
		WIP_TRANSACTION_ACCOUNTS wta,
		BOM_DEPARTMENTS bd,
		HR_ORGANIZATION_INFORMATION hoi,
		GL_SETS_OF_BOOKS gsob,
		BOM_OPERATIONAL_ROUTINGS bor,
		BOM_OPERATION_SEQUENCES bos,
		WIP_FLOW_SCHEDULES wfs
	WHERE
    		wt.transaction_type in (1,3)
		and wfs.status = 2
		and wt.wip_entity_id = wfs.wip_entity_id
		and wt.organization_id = wfs.organization_id
		and wt.organization_id = wta.organization_id
		and wt.wip_entity_id = wta.wip_entity_id
		and wt.transaction_id = wta.transaction_id
		and wta.accounting_line_type = 7
		and wt.wip_entity_id = we.wip_entity_id
		and wt.organization_id = we.organization_id
		and wt.organization_id = bd.organization_id
		and wt.department_id = bd.department_id
		and hoi.organization_id = wt.organization_id
		and hoi.ORG_INFORMATION_CONTEXT = 'Accounting Information'
		and to_char(gsob.set_of_books_id) =  hoi.ORG_INFORMATION1
		and wfs.organization_id = bor.organization_id
		and nvl(wfs.alternate_routing_designator,-99) = nvl(bor.alternate_routing_designator,-99)
		and wfs.primary_item_id = bor.assembly_item_id
		and bor.routing_sequence_id = bos.routing_sequence_id
		and wt.operation_seq_num = bos.operation_seq_num
		and bos.operation_type = 1
	 	and greatest(
				nvl(wt.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
				nvl(wfs.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss'))
				)
	BETWEEN g_push_from_date and g_push_to_date
	UNION
	select
        	primary_key1,
		primary_key2,
		primary_key3,
		primary_key4,
		primary_key5,
		primary_key6,
        	l_seq_id, /* NOTE : THIS IS THE NEW SEQ_ID */
        	view_id
        from
		opi_edw_opi_job_rsrc_mr_tmp
        where
		view_id = 2 ;

   	END IF;

   	l_count1 := SQL%rowcount ;


	delete
		opi_edw_opi_job_rsrc_mr_tmp
	where
		view_id = p_view_id ;

   	l_count2 := SQL%rowcount ;

	p_count := l_count1 - l_count2 ;


   COMMIT;
--dbms_output.put_line('Identified '|| p_count || ' changed records in view type '|| p_view_id);
   RETURN(l_seq_id);

 EXCEPTION
   WHEN OTHERS THEN
	-- dbms_output.put_line('Exception in identify_change') ;
	-- dbms_output.put_line(sqlcode) ;
	-- dbms_output.put_line(sqlerrm) ;
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);
END identify_change;

-----------------------------------------------------------
--FUNCTION PUSH_TO_LOCAL
-----------------------------------------------------------

FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER,
		       p_seq_id NUMBER) RETURN NUMBER IS
	  l_mau                 number:=0 ;
BEGIN

   -- ------------------------------------------------
   -- We set the COLLECTION_STATUS to 'LOCAL READY'.
   -- In case of source=target, we need to separate
   -- out the records in progress vs the records which
   -- is ready to be picked up by collection enginee.
   -- In our case, we consider the records to be in
   -- progress until all the child processes have
   -- completed successfully.
   -- ------------------------------------------------


   l_mau := nvl( edw_currency.get_mau, 0.01 );

   Insert Into opi_edw_job_rsrc_fstg
     (
	JOB_RSRC_PK,
	ACT_RSRC_COUNT,
	PLN_RSRC_COUNT,
	ACT_RSRC_QTY,
	ACT_RSRC_VAL_B,
	ACT_RSRC_VAL_G,
	PLN_RSRC_QTY,
	PLN_RSRC_VAL_B,
	PLN_RSRC_VAL_G,
	ACT_RSRC_USAGE,
	PLN_RSRC_USAGE,
	ACT_RSRC_USAGE_VAL_B,
	ACT_RSRC_USAGE_VAL_G,
	PLN_RSRC_USAGE_VAL_B,
	PLN_RSRC_USAGE_VAL_G,
	EXTD_RSRC_COST,
	STND_RSRC_USAGE,
	JOB_NO,
	OPERATION_SEQ_NO,
	DEPARTMENT,
	ACT_STRT_DATE,
	ACT_CMPL_DATE,
	PLN_STRT_DATE,
	PLN_CMPL_DATE,
	SOB_CURRENCY_FK,
	QTY_UOM_FK,
	INSTANCE_FK,
	LOCATOR_FK,
	ACTIVITY_FK,
	TRX_DATE_FK,
	OPRN_FK,
	RSRC_FK,
	ITEM_FK,
	USAGE_UOM_FK,
     	USER_ATTRIBUTE1,
     	USER_ATTRIBUTE10,
     	USER_ATTRIBUTE11,
     	USER_ATTRIBUTE12,
     	USER_ATTRIBUTE13,
     	USER_ATTRIBUTE14,
     	USER_ATTRIBUTE15,
     	USER_ATTRIBUTE2,
     	USER_ATTRIBUTE3,
     	USER_ATTRIBUTE4,
     	USER_ATTRIBUTE5,
     	USER_ATTRIBUTE6,
     	USER_ATTRIBUTE7,
     	USER_ATTRIBUTE8,
     	USER_ATTRIBUTE9,
     	USER_FK1,
     	USER_FK2,
     	USER_FK3,
     	USER_FK4,
     	USER_FK5,
     	USER_MEASURE1,
     	USER_MEASURE2,
     	USER_MEASURE3,
     	USER_MEASURE4,
     	USER_MEASURE5,
     	OPERATION_CODE,
     	COLLECTION_STATUS
	)
     SELECT /*+ ALL_ROWS */
	JOB_RSRC_PK,
	ACT_RSRC_COUNT,
	PLN_RSRC_COUNT,
	ACT_RSRC_QTY,
	ACT_RSRC_VAL_B,
	round((nvl(ACT_RSRC_VAL_B,0) * GLOBAL_CURRENCY_RATE )/l_mau)*l_mau  ACT_RSRC_VAL_G,
	PLN_RSRC_QTY,
	PLN_RSRC_VAL_B,
	round((nvl(PLN_RSRC_VAL_B,0) * GLOBAL_CURRENCY_RATE )/l_mau)*l_mau  PLN_RSRC_VAL_G,
	ACT_RSRC_USAGE,
	PLN_RSRC_USAGE,
	ACT_RSRC_USAGE_VAL_B,
	round((nvl(ACT_RSRC_USAGE_VAL_B,0) * GLOBAL_CURRENCY_RATE )/l_mau)*l_mau  ACT_RSRC_USAGE_VAL_G,
	PLN_RSRC_USAGE_VAL_B,
	round((nvl(PLN_RSRC_USAGE_VAL_B,0) * GLOBAL_CURRENCY_RATE )/l_mau)*l_mau  PLN_RSRC_USAGE_VAL_G,
	EXTD_RSRC_COST,
	STND_RSRC_USAGE,
	JOB_NO,
	OPERATION_SEQ_NO,
	DEPARTMENT,
	ACT_STRT_DATE,
	ACT_CMPL_DATE,
	PLN_STRT_DATE,
	PLN_CMPL_DATE,
	NVL(SOB_CURRENCY_FK,'NA_EDW'),
	NVL(QTY_UOM_FK,'NA_EDW'),
	NVL(INSTANCE_FK,'NA_EDW'),
	NVL(LOCATOR_FK,'NA_EDW'),
	NVL(ACTIVITY_FK,'NA_EDW'),
	NVL(TRX_DATE_FK,'NA_EDW'),
	NVL(OPRN_FK,'NA_EDW'),
	NVL(RSRC_FK,'NA_EDW'),
	NVL(ITEM_FK,'NA_EDW'),
	NVL(USAGE_UOM_FK,'NA_EDW'),
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	'NA_EDW' ,
     	'NA_EDW' ,
     	'NA_EDW' ,
     	'NA_EDW' ,
     	'NA_EDW' ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL ,
     	NULL, -- OPERATION_CODE
	DECODE(GLOBAL_CURRENCY_RATE,
                NULL, 'RATE NOT AVAILABLE',
                -1, 'RATE NOT AVAILABLE',
                -2, 'INVALID CURRENCY',
                'LOCAL READY') /* COLLECTION_STATUS */
     FROM opi_edw_opi_job_rsrc_fcv
     WHERE view_id = p_view_id
     AND seq_id = p_seq_id;

--dbms_output.put_line('Inserted ' || Nvl(SQL%rowcount,0) ||' rows into local staging table for view type ' || p_view_id || ' with seq_id ' || p_seq_id);


	COMMIT ;

   RETURN(sql%rowcount);

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      RETURN(-1);
END PUSH_TO_LOCAL;


-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------
PROCEDURE  Push(Errbuf      in OUT NOCOPY  Varchar2,
                Retcode     in OUT NOCOPY  Varchar2,
                p_from_date  IN   varchar2,
                p_to_date    IN   varchar2) IS

  l_fact_name       VARCHAR2(30)   ;
  l_staging_table   VARCHAR2(30) ;
  l_opi_schema      VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_exception_msg   VARCHAR2(2000);

  l_from_date       DATE ;
  l_to_date         DATE ;

  l_seq_id_view1    NUMBER ;
  l_seq_id_view2    NUMBER ;
  l_row_count_view1 NUMBER ;
  l_row_count_view2 NUMBER ;
  l_row_count       NUMBER ;
  l_cur_rate_count1  NUMBER ;
  l_cur_rate_count2  NUMBER ;

  l_push_local_failure      EXCEPTION;
  l_iden_change_failure EXCEPTION;

  /*
  l_date1                Date:=Null;
  l_date2                Date:=Null;
  l_temp_date                Date:=Null;
  l_rows_inserted            Number:=0;
  l_duration                 Number:=0;
*/

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------

BEGIN
  l_fact_name       :='OPI_EDW_JOB_RSRC_F'  ;
  l_staging_table  :='OPI_EDW_JOB_RSRC_FSTG';
  l_exception_msg   :=Null;

  l_from_date       := NULL;
  l_to_date         := NULL;

  l_seq_id_view1    := 0;
  l_seq_id_view2    := 0;
  l_row_count_view1 := 0;
  l_row_count_view2 := 0;
  l_row_count       := 0;
  l_cur_rate_count1  := 0;
  l_cur_rate_count2  := 0;



   Errbuf :=NULL;
   Retcode:=0;



   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name,
				     l_staging_table,
				     l_staging_table,
				     l_exception_msg)) THEN
      errbuf := fnd_message.get;
      Return;
   END IF;

   l_from_date  := To_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
   l_to_date    := To_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');


   g_push_from_date
     := nvl(l_from_date,
	    EDW_COLLECTION_UTIL.G_local_last_push_start_date
	    - EDW_COLLECTION_UTIL.g_offset);

   g_push_to_date:=  nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

--l_date1 := g_push_date_range1;
--l_date2 := g_push_date_range2;

   edw_log.put_line( 'The collection range is from '||
        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

   --  --------------------------------------------------------
   --  Identify Change for View Type 1
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Identifying change in view type 1');

   l_row_count := 0;
   l_seq_id_view1 := identify_change( p_view_id => 1,
				      p_count => l_row_count );
   IF (l_seq_id_view1 = -1 ) THEN
      RAISE l_iden_change_failure;
   END IF;

   edw_log.put_line('Identified '|| l_row_count
		    || ' changed records in view type 1. ');
   --  --------------------------------------------------------
   --  Identify Change for View Type 2
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Identifying change in view type 2');
   l_row_count := 0;
   l_seq_id_view2 := identify_change( p_view_id => 2,
				      p_count => l_row_count );
   IF (l_seq_id_view2 = -1 ) THEN
      RAISE l_iden_change_failure;
   END IF;

   edw_log.put_line('Identified '|| l_row_count
		    || ' changed records in view type 2. ');

--RAISE l_iden_change_failure;
   --  --------------------------------------------------------
   --  Analyze the incremental table
   --  --------------------------------------------------------
   IF fnd_installation.get_app_info( 'OPI', l_status,
				      l_industry, l_opi_schema) THEN
       fnd_stats.gather_table_stats(ownname=> l_opi_schema,
				    tabname=> 'OPI_EDW_OPI_JOB_RSRC_INC' );
   END IF;

   --  --------------------------------------------------------
   --  Pushing data to local staging table for view type 1
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserting into local staging table for view type 1');



   l_row_count_view1 := push_to_local( p_view_id => 1,
				       p_seq_id  => l_seq_id_view1 );
   IF l_row_count_view1 = -1 THEN
      RAISE l_push_local_failure;
   END IF;

   edw_log.put_line('Inserted ' || Nvl(l_row_count_view1,0) ||
		    ' rows into local staging table for view type 1');
     edw_log.put_line('  ');

   --

   --  --------------------------------------------------------
   --  Check for records with missing currency rates  for view type 1
   --  --------------------------------------------------------


	l_cur_rate_count1 := FIND_MISSING_RATE_RECORDS(p_view_id => 1) ;

   --  ---------------------------------------------------------------
   --  Delete local staging table records with missing currency rates
   --  for view type 1
   --  ---------------------------------------------------------------

	if (l_cur_rate_count1 > 0) then
		DELETE_STG ;
	end if ;


   --
   --  --------------------------------------------------------
   --  Pushing data to local staging table for view type 2
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserting into local staging table for view type 2');


   l_row_count_view2 := push_to_local( p_view_id => 2,
				       p_seq_id  => l_seq_id_view2 );
   IF l_row_count_view2 = -1 THEN
      RAISE l_push_local_failure;
   END IF;
   edw_log.put_line('Inserted ' || Nvl(l_row_count_view2,0) ||
		    ' rows into local staging table for view type 2');
   edw_log.put_line('  ');

   --  --------------------------------------------------------
   --  Check for records with missing currency rates
   --  for view type 2
   --  --------------------------------------------------------

	l_cur_rate_count2 := FIND_MISSING_RATE_RECORDS(p_view_id => 2) ;

   --
   g_row_count := l_row_count_view1 + l_row_count_view2 ;

   edw_log.put_line('For all view types, inserted ' || Nvl(g_row_count,0)
		    || ' rows into local staging table.');
   edw_log.put_line('  ');

   --  ---------------------------------------------------------------
   --  Delete local staging table records with missing currency rates
   --  for view type 2
   --  ---------------------------------------------------------------

	if (l_cur_rate_count2 > 0) then
		DELETE_STG ;
	end if ;




   --  --------------------------------------------------------
   --  Delete all incremental table's record
   --  --------------------------------------------------------

   -- CAN WE USE DELETE INSTEAD OF TRUNCATE, THIS WILL ENABLE US TO DELETE
   -- RECORDS SELECTIVELY

   execute immediate 'truncate table '||l_opi_schema||'.opi_edw_opi_job_rsrc_inc ';



   -- --------------------------------------------
   -- No exception raised so far. Call wrapup to transport
   -- data to target database, and insert messages into logs
   -- -----------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserted '||nvl(g_row_count,0)||
		    ' rows into the staging table');
   edw_log.put_line(' ');

   EDW_COLLECTION_UTIL.wrapup(TRUE,
			      g_row_count,
			      l_exception_msg,
			      g_push_from_date,
			      g_push_to_date);


--dbms_output.put_line( 'l_opi_schema  after wrapup true ' || l_opi_schema);


-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

	-- Generate a warning if there are any missing currency rates
	-- in the concurrent program
	if (l_cur_rate_count1 > 0 or l_cur_rate_count2 > 0) then
		Retcode := 1 ;
		g_retcode := 1 ;
	end if ;

EXCEPTION
   WHEN L_PUSH_LOCAL_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;   -- Rollback insert into local staging
      edw_log.put_line('Inserting into local staging have failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_from_date,g_push_to_date);
      raise;

   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;

      IF fnd_installation.get_app_info( 'OPI', l_status,
					l_industry, l_opi_schema) THEN
	 execute immediate 'truncate table ' || l_opi_schema
	   || '.opi_edw_opi_job_rsrc_inc ';
      END IF;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_from_date,g_push_to_date);
      raise;

   WHEN OTHERS THEN
      Errbuf:= Sqlerrm;
      Retcode:=sqlcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Other errors');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
				 g_push_from_date, g_push_to_date);
      raise;

END push;


PROCEDURE DELETE_STG IS

BEGIN

/*
We do not check if the LOCAL instance is the same as the REMOTE instance
before DELETing.
This is because we need to do ( Push_To_Local -> Delete_Stg)
for each view type instead of (Push_To_Local 1 -> Push_To_Local 2 -> Delete_Stg)
*/

		delete
		opi_edw_job_rsrc_fstg
		where
		collection_status in ('RATE NOT AVAILABLE','INVALID CURRENCY') ;

		COMMIT ;


EXCEPTION
	WHEN OTHERS THEN
		g_retcode := sqlcode ;
		g_errbuf := sqlerrm ;
		ROLLBACK ;

END DELETE_STG ;


FUNCTION FIND_MISSING_RATE_RECORDS (p_view_id NUMBER) RETURN NUMBER IS

   	l_cur_rate_count NUMBER := 0 ;
	l_view_id NUMBER := 0 ;
	l_primary_key1_pos NUMBER := 0 ;
	l_primary_key2_pos NUMBER := 0 ;
	l_primary_key3_pos NUMBER := 0 ;
	l_primary_key4_pos NUMBER := 0 ;
	l_primary_key5_pos NUMBER := 0 ;
	l_primary_key1 NUMBER := 0 ;
	l_primary_key2 NUMBER := 0 ;
	l_primary_key3 NUMBER := 0 ;
	l_primary_key4 NUMBER := 0 ;
	l_primary_key5 NUMBER := 0 ;

	/* Note that in the case of a single-instance implementation, the
	local staging table will not be purged. Hence there may be a need
	to handle the case where two consecutive pushes are made before
	a load is done */

   	CURSOR CURRENCY_CUR IS
	select
		sob_currency_fk from_currency,
		nvl(substrb(TRX_DATE_FK,1,10),CREATION_DATE) c_date,
		collection_status collection_status,
		job_rsrc_pk job_rsrc_pk
	from
		opi_edw_job_rsrc_fstg
	where
		job_rsrc_pk like '%OPI'
		and collection_status in ('RATE NOT AVAILABLE','INVALID CURRENCY')
	/*
	order by
		from_currency, c_date
	*/
	group by
		sob_currency_fk,
		nvl(substrb(TRX_DATE_FK,1,10),CREATION_DATE),
		collection_status,
		job_rsrc_pk
	;

BEGIN

   	edw_log.put_line( 'Checking for Missing Currency Rate records for view type '|| p_view_id );
   	edw_log.put_line(' ');

	fnd_file.put_line(fnd_file.output ,'Primary Key           From Currency            Currency Date               Collection Status ') ;

	for l_currency_cur in CURRENCY_CUR loop

		l_cur_rate_count := l_cur_rate_count + 1 ;

		fnd_file.put_line(fnd_file.output ,l_currency_cur.job_rsrc_pk || l_currency_cur.from_currency || l_currency_cur.c_date || l_currency_cur.collection_status) ;

		l_view_id := p_view_id ;

		l_primary_key1_pos := instrb(l_currency_cur.job_rsrc_pk, '-',1,1) ;
		l_primary_key1 := to_number(substrb(
l_currency_cur.job_rsrc_pk,1, l_primary_key1_pos - 1)) ;



		l_primary_key2_pos := instrb(l_currency_cur.job_rsrc_pk, '-',1,2) ;
		l_primary_key2 := to_number(substrb(l_currency_cur.job_rsrc_pk,l_primary_key1_pos + 1, l_primary_key2_pos - l_primary_key1_pos - 1)) ;



		l_primary_key3_pos := instrb(l_currency_cur.job_rsrc_pk, '-',1,3) ;
		l_primary_key3 := substrb(l_currency_cur.job_rsrc_pk,l_primary_key2_pos + 1, l_primary_key3_pos - l_primary_key2_pos - 1) ;



		l_primary_key4_pos := instrb(l_currency_cur.job_rsrc_pk, '-',1,4) ;
		l_primary_key4 := to_number(substrb(l_currency_cur.job_rsrc_pk,l_primary_key3_pos + 1, l_primary_key4_pos - l_primary_key3_pos - 1)) ;


		l_primary_key5_pos := instrb(l_currency_cur.job_rsrc_pk, '-',1,5) ;
		l_primary_key5 := to_number(substrb(l_currency_cur.job_rsrc_pk,l_primary_key4_pos + 1, l_primary_key5_pos - l_primary_key4_pos - 1)) ;

		-- Insert Records with seq_id = NULL

      		INSERT INTO opi_edw_opi_job_rsrc_mr_tmp
			(primary_key1,primary_key2,primary_key3,primary_key4,primary_key5,primary_key6,view_id)
		VALUES
			(l_primary_key1,l_primary_key2,l_primary_key3,l_primary_key4,l_primary_key5,'OPI',l_view_id);

	end loop ;

	COMMIT ;

   	edw_log.put_line( 'Number of Missing Currency Rate records =  '||
        l_cur_rate_count );
   	edw_log.put_line(' ');

	return (l_cur_rate_count) ;


EXCEPTION
WHEN OTHERS THEN
   		edw_log.put_line( 'Exception in MISSING_RATE_RECORDS' || sqlerrm );
		g_errbuf := sqlerrm ;
		g_retcode := sqlcode ;
		ROLLBACK ;
		return (-1) ;

END FIND_MISSING_RATE_RECORDS ;

End OPI_EDW_OPI_JOB_RSRC_F_C;

/
