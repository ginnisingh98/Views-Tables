--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPI_RES_UTIL_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPI_RES_UTIL_F_C" AS
/* $Header: OPIMRUTB.pls 120.1 2005/06/08 18:19:11 appldev  $ */

 g_push_from_date          Date:=Null;
 g_push_to_date            Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_errbuf            VARCHAR2(2000):=NULL;
 g_retcode           VARCHAR2(200) :=NULL;
-----------------------------------------------------------
--FUNCTION PUSH_TO_LOCAL
-----------------------------------------------------------

FUNCTION PUSH_TO_LOCAL(p_from_date DATE,
		       p_to_date   DATE ) RETURN NUMBER IS
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

   Insert Into opi_edw_res_util_fstg
     (res_util_pk,
      locator_fk,
      res_fk,
      trx_date_fk,
      uom_fk,
      instance_fk,
      USER_FK1,USER_FK2,USER_FK3, USER_FK4, USER_FK5,
      act_res_usage,
      avail_res,
      department,
      trx_date,
      USER_MEASURE1,USER_MEASURE2, USER_MEASURE3,
      USER_MEASURE4, USER_MEASURE5,
      last_update_date,
      creation_date,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5,
      USER_ATTRIBUTE6,
      USER_ATTRIBUTE7,
      USER_ATTRIBUTE8,
      USER_ATTRIBUTE9,
      USER_ATTRIBUTE10,
      USER_ATTRIBUTE11,
      USER_ATTRIBUTE12,
      USER_ATTRIBUTE13,
      USER_ATTRIBUTE14,
      USER_ATTRIBUTE15,
      collection_status)
     SELECT /*+ ALL_ROWS */
     Nvl(res_util_pk,'NA_EDW'),
     Nvl(locator_fk,'NA_EDW'),
     Nvl(res_fk,'NA_EDW'),
     Nvl(trx_date_fk,'NA_EDW'),
     Nvl(uom_fk,'NA_EDW'),
     Nvl(instance_fk,'NA_EDW'),
     NVL(USER_FK1,'NA_EDW'),
     NVL(USER_FK2,'NA_EDW'),
     NVL(USER_FK3,'NA_EDW'),
     NVL(USER_FK4,'NA_EDW'),
     NVL(USER_FK5,'NA_EDW'),
     act_res_usage,
     avail_res,
     department,
     trx_date,
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     Sysdate,
     Sysdate,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     'LOCAL READY'
     FROM opi_edw_opi_res_util_fcv;

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
PROCEDURE  Push(Errbuf      in out nocopy Varchar2,
                Retcode     in out nocopy Varchar2,
                p_from_date  IN   varchar2,
                p_to_date    IN   VARCHAR2    ) IS

  l_fact_name       VARCHAR2(30)  :='OPI_EDW_RES_UTIL_F'  ;
  l_staging_table   VARCHAR2(30)  :='OPI_EDW_RES_UTIL_FSTG';
  l_opi_schema      VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_exception_msg   VARCHAR2(2000):=Null;

  l_row_count       NUMBER := 0;

  l_push_local_failure      EXCEPTION;

BEGIN
   Errbuf :=NULL;
   Retcode:=0;

   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name,
				     l_staging_table,
				     l_staging_table,
				     l_exception_msg)) THEN
      errbuf := fnd_message.get;
      Return;
   END IF;

   g_push_from_date  := To_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
   g_push_to_date    := To_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');


 --  Start of code change for bug fix 2140267.
  -- --------------------------------------------
  -- Taking care of cases where the input from/to
  -- date is NULL.
  -- --------------------------------------------

   g_push_from_date := nvl(g_push_from_date,
          EDW_COLLECTION_UTIL.G_local_last_push_start_date -
          EDW_COLLECTION_UTIL.g_offset);
   g_push_to_date := nvl(g_push_to_date,
          EDW_COLLECTION_UTIL.G_local_curr_push_start_date);


  --  End of code change for bug fix 2140267.





   edw_log.put_line( 'The collection range is from '||
        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

   --  --------------------------------------------------------
   --  Delete all opi_edw_res_util_push_log records
   --  --------------------------------------------------------
   -- a). get schema name
   IF fnd_installation.get_app_info( 'OPI', l_status,
				     l_industry, l_opi_schema) THEN
      execute immediate 'truncate table '||l_opi_schema
	||'.opi_edw_res_util_push_log ';
   END IF;

   --  --------------------------------------------------------
   --  . Pushing data to local push table
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserting into local push log table ');

   opimxru.extract_opi_res_util(g_push_from_date, g_push_to_date);

   --  --------------------------------------------------------
   --  . Pushing data to local staging table
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserting into local staging table for view type 1');

   l_row_count := push_to_local(p_from_date => g_push_from_date,
				p_to_date   => g_push_to_date    );

   -- --------------------------------------------
   -- No exception raised so far. Call wrapup to transport
   -- data to target database, and insert messages into logs
   -- -----------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserted '||nvl(l_row_count,0)||
		    ' rows into the local staging table');
   edw_log.put_line( 'The system time after insert is ' ||
        to_char(sysdate,'MM/DD/YYYY HH24:MI:SS') );
   edw_log.put_line(' ');

   EDW_COLLECTION_UTIL.wrapup(TRUE,
			      g_row_count,
			      l_exception_msg,
			      g_push_from_date,
			      g_push_to_date);

   --  --------------------------------------------------------
   --  Delete all opi_edw_res_util_push_log records
   --  --------------------------------------------------------
   -- a). get schema name
   IF fnd_installation.get_app_info( 'OPI', l_status,
				     l_industry, l_opi_schema) THEN
      execute immediate 'truncate table '||l_opi_schema
	||'.opi_edw_res_util_push_log ';
   END IF;

   -- ---------------------------------------------------------------------------
   -- END OF Collection , Developer Customizable Section
   -- ---------------------------------------------------------------------------

EXCEPTION
   WHEN L_PUSH_LOCAL_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;   -- Rollback insert into local staging
      edw_log.put_line('Inserting into local staging have failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
				 g_push_from_date, g_push_to_date);
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

END OPI_EDW_OPI_RES_UTIL_F_C;

/
