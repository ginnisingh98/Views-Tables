--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPM_RES_UTIL_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPM_RES_UTIL_F_C" AS
/* $Header: OPIMORUB.pls 120.1 2005/06/07 03:29:53 appldev  $ */
 g_errbuf	   	      VARCHAR2(2000) := NULL;
 g_retcode		      VARCHAR2(200) := NULL;
 g_row_count         	NUMBER:=0;
 g_push_from_date	      DATE := NULL;
 g_push_to_date		DATE := NULL;
 g_seq_id               NUMBER:=0;
-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------
-----------------------------------------------------------
--PROCEDURE PUSH_TO_LOCAL
-----------------------------------------------------------
 FUNCTION PUSH_TO_LOCAL(L_FROM_DATE DATE,L_TO_DATE DATE) RETURN NUMBER IS
   l_no_rows number;
 BEGIN
   -- ------------------------------------------------
   -- We set the COLLECTION_STATUS to 'LOCAL READY'.
   -- In case of source=target, we need to separate
   -- out the records in progress vs the records which
   -- is ready to be picked up by collection enginee.
   -- In our case, we consider the records to be in
   -- progress until the push_to_local procedure for
   -- all view types  has  completed successfully.
   -- ------------------------------------------------
     INSERT INTO OPI_EDW_RES_UTIL_FSTG(
      RES_UTIL_PK,
      LOCATOR_FK,
      RES_FK,
      TRX_DATE_FK,
      UOM_FK,
      INSTANCE_FK,
      USER_FK1,
      USER_FK2,
      USER_FK3,
      USER_FK4,
      USER_FK5,
      ACT_RES_USAGE,
      AVAIL_RES,
      DEPARTMENT,
      TRX_DATE,
      USER_MEASURE1,
      USER_MEASURE2,
      USER_MEASURE3,
      USER_MEASURE4,
      USER_MEASURE5,
      LAST_UPDATE_DATE,
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
      COLLECTION_STATUS)
  SELECT /*+ ALL_ROWS */
      RES_UTIL_PK,
      LOCATOR_FK,
      RES_FK,
      TRX_DATE_FK,
      UOM_FK,
      INSTANCE_FK,
      USER_FK1,
      USER_FK2,
      USER_FK3,
      USER_FK4,
      USER_FK5,
      ACT_RES_USAGE,
      AVAIL_RES,
      DEPARTMENT,
      TRX_DATE,
      USER_MEASURE1,
      USER_MEASURE2,
      USER_MEASURE3,
      USER_MEASURE4,
      USER_MEASURE5,
      LAST_UPDATE_DATE,
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
    FROM OPI_EDW_OPM_RES_UTIL_FCV
    WHERE LAST_UPDATE_DATE BETWEEN L_FROM_DATE AND L_TO_DATE;
    l_no_rows := sql%rowcount;
    RETURN l_no_rows;
 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);
 END;
-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------
-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------
 PROCEDURE PUSH(Errbuf      	in out NOCOPY  Varchar2,
                Retcode     	in out NOCOPY  Varchar2,
                p_from_date  	IN             Varchar2,
                p_to_date    	IN             Varchar2) IS
 l_fact_name                Varchar2(30) ;
 l_staging_table            Varchar2(30) ;
 l_exception_msg            Varchar2(2000);
 l_from_date                Date;
 l_to_date                  Date;
 l_seq_id1	                NUMBER ;
 l_seq_id2         	    NUMBER ;
 l_row_count                NUMBER ;
 l_row_count1               NUMBER ;
 l_row_count2               NUMBER ;
 l_pmi_schema          	    VARCHAR2(30);
 l_status                   VARCHAR2(30);
 l_industry                 VARCHAR2(30);
 l_push_local_failure       EXCEPTION;
 l_iden_change_failure      EXCEPTION;
   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
 BEGIN
 l_fact_name               :='OPI_EDW_RES_UTIL_F';
 l_staging_table        :='OPI_EDW_RES_UTIL_FSTG';
 l_exception_msg    :=Null;
 l_from_date              :=Null;
 l_to_date                  :=Null;
 l_seq_id1	             := -1;
 l_seq_id2         	    := -1;
 l_row_count           := 0;
 l_row_count1        := 0;
 l_row_count2        := 0;

   Errbuf :=NULL;
   Retcode:=0;
   l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_date :=to_date(p_to_date,'YYYY/MM/DD HH24:MI:SS');
   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name,l_staging_table,l_staging_table,l_exception_msg)) THEN
         errbuf := fnd_message.get;
         RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
         Return;
   END IF;
  -- --------------------------------------------
  -- Taking care of cases where the input from/to
  -- date is NULL.
  -- --------------------------------------------
   g_push_from_date := nvl(l_from_date,
          EDW_COLLECTION_UTIL.G_local_last_push_start_date -
          EDW_COLLECTION_UTIL.g_offset);
   g_push_to_date := nvl(l_to_date,
          EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');
   -- --------------------------------------------
   -- Push to local staging table
   -- --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Inserting into local staging table ');
      l_row_count1 := PUSH_TO_LOCAL(g_push_from_date,g_push_to_date);
      IF (l_row_count1 = -1) THEN RAISE L_push_local_failure; END IF;
      edw_log.put_line('Inserted '||nvl(l_row_count1,0)||
         ' rows into the local staging table ');
      edw_log.put_line(' ');
      g_row_count:= l_row_count1;
      edw_log.put_line(' ');
      edw_log.put_line('For all views types, inserted '||nvl(g_row_count,0)||
        ' rows into local staging table ');
    -- --------------------------------------------
    -- No exception raised so far. Call wrapup to transport
    -- data to target database, and insert messages into logs
    -- -----------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Inserted '||nvl(g_row_count,0)||
         ' rows into the staging table');
      edw_log.put_line(' ');
      EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, l_exception_msg,
        g_push_from_date, g_push_to_date);
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
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_from_date,g_push_to_date);
      raise;
   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_from_date,g_push_to_date);
      raise;
   WHEN OTHERS THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Other errors');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      raise;
 END;
END OPI_EDW_OPM_RES_UTIL_F_C ;

/
