--------------------------------------------------------
--  DDL for Package Body EDW_OPI_OPRN_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_OPI_OPRN_M_C" AS
/* $Header: OPIOPRDB.pls 120.1 2005/06/07 02:26:54 appldev  $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 Procedure Push(Errbuf       in out  NOCOPY Varchar2,
                Retcode      in out  NOCOPY Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_dimension_name   Varchar2(30) :='EDW_OPI_OPRN_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;
 l_temp_date_char           Varchar2(35);
   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
    Return;
  END IF;
  IF (p_from_date IS NULL) THEN
    EDW_OPI_OPRN_M_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date -
    EDW_COLLECTION_UTIL.g_offset;
  ELSE
    EDW_OPI_OPRN_M_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;
  IF (p_to_date IS NULL) THEN
    EDW_OPI_OPRN_M_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
    EDW_OPI_OPRN_M_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;
   edw_log.put_line( 'The collection range is from '||
        to_char(EDW_OPI_OPRN_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_OPI_OPRN_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');
   l_temp_date := sysdate;
   Push_EDW_OPI_OPRN_OPRN_LSTG(EDW_OPI_OPRN_M_C.g_push_date_range1, EDW_OPI_OPRN_M_C.g_push_date_range2);
   Push_EDW_OPI_OPRN_OPRC_LSTG(EDW_OPI_OPRN_M_C.g_push_date_range1, EDW_OPI_OPRN_M_C.g_push_date_range2);
   l_duration := sysdate - l_temp_date;
   edw_log.put_line('Total rows inserted : '||g_row_count);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count,EDW_OPI_OPRN_M_C.g_exception_msg,
                               EDW_OPI_OPRN_M_C.g_push_date_range1,
                               EDW_OPI_OPRN_M_C.g_push_date_range2);
commit;
 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_OPI_OPRN_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_OPI_OPRN_M_C.g_exception_msg,
                               EDW_OPI_OPRN_M_C.g_push_date_range1,
                               EDW_OPI_OPRN_M_C.g_push_date_range2);
commit;
End;

Procedure Push_EDW_OPI_OPRN_OPRN_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_OPI_OPRN_OPRN_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_OPI_OPRN_OPRN_LSTG@EDW_APPS_TO_WH(
       OPRN_PK,
       OPRC_FK,
       OPRN_DP,
       NAME,
       OPRN_NAME,
       DESCRIPTION,
       ORGN_CODE,
       DEPARTMENT,
       PROCESS_QTY_UOM,
       USER_ATTRIBUTE1,
       USER_ATTRIBUTE2,
       USER_ATTRIBUTE3,
       USER_ATTRIBUTE4,
       USER_ATTRIBUTE5,
       LAST_UPDATE_DATE,
       CREATION_DATE,
       OPERATION_CODE,
       COLLECTION_STATUS)
   select
	OPRN_PK,
 	OPRC_FK,
	OPRN_DP,
 	NAME,
 	OPRN_NAME,
 	DESCRIPTION,
 	ORGN_CODE,
 	DEPARTMENT,
        PROCESS_QTY_UOM,
   	USER_ATTRIBUTE1,
 	USER_ATTRIBUTE2,
 	USER_ATTRIBUTE3,
 	USER_ATTRIBUTE4,
 	USER_ATTRIBUTE5,
 	LAST_UPDATE_DATE,
 	CREATION_DATE,
    	NULL OPERATION_CODE,
        'READY'
   from EDW_OPI_OPRN_OPRN_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   EDW_OPI_OPRN_M_C.g_row_count := EDW_OPI_OPRN_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records into EDW_OPI_OPRN_OPRN_LSTG');
commit;
   edw_log.put_line('Completed Push_EDW_OPI_OPRN_OPRN_LSTG');
 Exception When others then
   raise;
commit;
END;

Procedure Push_EDW_OPI_OPRN_OPRC_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_OPI_OPRN_OPRC_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_OPI_OPRN_OPRC_LSTG@EDW_APPS_TO_WH(
        ALL_FK,
	OPRC_PK,
	OPRC_DP,
	NAME,
	DESCRIPTION,
	USER_ATTRIBUTE1,
	USER_ATTRIBUTE2,
	USER_ATTRIBUTE3,
	USER_ATTRIBUTE4,
	USER_ATTRIBUTE5,
	LAST_UPDATE_DATE,
	CREATION_DATE,
        OPERATION_CODE,
        COLLECTION_STATUS)
   select
	ALL_FK,
	OPRC_PK,
	OPRC_DP,
	NAME,
	DESCRIPTION,
	USER_ATTRIBUTE1,
	USER_ATTRIBUTE2,
	USER_ATTRIBUTE3,
	USER_ATTRIBUTE4,
	USER_ATTRIBUTE5,
	LAST_UPDATE_DATE,
	CREATION_DATE,
    	NULL OPERATION_CODE,
        'READY'
   from EDW_OPI_OPRN_OPRC_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   EDW_OPI_OPRN_M_C.g_row_count := EDW_OPI_OPRN_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records into EDW_OPI_OPRN_OPRC_LSTG');
commit;
   edw_log.put_line('Completed Push_EDW_OPI_OPRN_OPRC_LSTG');
 Exception When others then
   raise;
commit;
END;

End EDW_OPI_OPRN_M_C;

/
