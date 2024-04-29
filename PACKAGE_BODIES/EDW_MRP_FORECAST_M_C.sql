--------------------------------------------------------
--  DDL for Package Body EDW_MRP_FORECAST_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MRP_FORECAST_M_C" AS
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_MRP_FORECAST_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date		    Date:=Null;
 l_to_date		    Date:=Null;

/* REM -------------------------------------------
   REM Put any additional developer variables here
   REM ------------------------------------------- */
Begin
  Errbuf :=NULL;
   Retcode:=0;
  l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
  errbuf := fnd_message.get;
    Return;
  END IF;
  EDW_MRP_FORECAST_M_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  EDW_MRP_FORECAST_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(EDW_MRP_FORECAST_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_MRP_FORECAST_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');
/* REM ---------------------------------------------------------------------
   REM Start of Collection , Developer Customizable Section
   REM --------------------------------------------------------------------- */
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_MRP_FCDM_FCS_LSTG(EDW_MRP_FORECAST_M_C.g_push_date_range1, EDW_MRP_FORECAST_M_C.g_push_date_range2);
        Push_EDW_MRP_FCDM_SET_LSTG(EDW_MRP_FORECAST_M_C.g_push_date_range1, EDW_MRP_FORECAST_M_C.g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
/*  ---------------------------------------------------------------------------
REM END OF Collection , Developer Customizable Section
REM ---------------------------------------------------------------------------
*/
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, EDW_MRP_FORECAST_M_C.g_push_date_range1, EDW_MRP_FORECAST_M_C.g_push_date_range2);

commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_MRP_FORECAST_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_MRP_FORECAST_M_C.g_exception_msg, EDW_MRP_FORECAST_M_C.g_push_date_range1, EDW_MRP_FORECAST_M_C.g_push_date_range2);

commit;
End;


Procedure Push_EDW_MRP_FCDM_FCS_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_MRP_FCDM_FCS_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_MRP_FCDM_FCS_LSTG@EDW_APPS_TO_WH(
    DESCRIPTION,
    FORECAST_DP,
    FORECAST_NAME,
    FORECAST_PK,
    FORECAST_SET_FK,
    INSTANCE_CODE,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS,
    DISABLE_DATE)
   select DESCRIPTION,
	FORECAST_DP,
	FORECAST_NAME,
	FORECAST_PK,
    	NVL(FORECAST_SET_FK, 'NA_EDW'),
	INSTANCE_CODE,
	NAME,
	USER_ATTRIBUTE1,
	USER_ATTRIBUTE2,
	USER_ATTRIBUTE3,
	USER_ATTRIBUTE4,
	USER_ATTRIBUTE5,
	NULL, -- OPERATION_CODE
    	'READY',
   	DISABLE_DATE
   from EDW_MRP_FCDM_FCS_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_MRP_FORECAST_M_C.g_row_count := l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_MRP_FCDM_FCS_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_MRP_FCDM_FCS_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_MRP_FCDM_SET_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_MRP_FCDM_SET_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_MRP_FCDM_SET_LSTG@EDW_APPS_TO_WH(
    CONSUMPTION_LEVEL,
    DESCRIPTION,
    FORECAST_SET_DP,
    FORECAST_SET_NAME,
    FORECAST_SET_PK,
    INSTANCE_CODE,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS,
    DISABLE_DATE)
   select CONSUMPTION_LEVEL,
	DESCRIPTION,
	FORECAST_SET_DP,
	FORECAST_SET_NAME,
	FORECAST_SET_PK,
	INSTANCE_CODE,
	NAME,
	USER_ATTRIBUTE1,
	USER_ATTRIBUTE2,
	USER_ATTRIBUTE3,
	USER_ATTRIBUTE4,
	USER_ATTRIBUTE5,
    	NULL, -- OPERATION_CODE
    	'READY',
	DISABLE_DATE
   from EDW_MRP_FCDM_SET_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Commiting records for EDW_MRP_FCDM_SET_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_MRP_FCDM_SET_LSTG');
 Exception When others then
   raise;
commit;
END;
End EDW_MRP_FORECAST_M_C;

/
