--------------------------------------------------------
--  DDL for Package Body EDW_HR_REC_ACT_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_REC_ACT_M_C" AS
/* $Header: hrieprec.pkb 120.1 2005/06/07 06:02:25 anmajumd noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_dimension_name   Varchar2(30) :='EDW_HR_REC_ACT_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
  errbuf := fnd_message.get;
    Return;
  END IF;

  IF (p_from_date IS NULL) THEN
		EDW_HR_REC_ACT_M_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date -
		EDW_COLLECTION_UTIL.g_offset;
  ELSE
	EDW_HR_REC_ACT_M_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
		EDW_HR_REC_ACT_M_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
	EDW_HR_REC_ACT_M_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;


   edw_log.put_line( 'The collection range is from '||
        to_char(EDW_HR_REC_ACT_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_HR_REC_ACT_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_HR_RACT_ACTIVITY_LSTG(EDW_HR_REC_ACT_M_C.g_push_date_range1, EDW_HR_REC_ACT_M_C.g_push_date_range2);
        Push_EDW_HR_RACT_ACT_TYPE_LSTG(EDW_HR_REC_ACT_M_C.g_push_date_range1, EDW_HR_REC_ACT_M_C.g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Total rows inserted : '||g_row_count);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, g_push_date_range1, g_push_date_range2 );
commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_HR_REC_ACT_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_HR_REC_ACT_M_C.g_exception_msg, g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_HR_RACT_ACTIVITY_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_RACT_ACTIVITY_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_RACT_ACTIVITY_LSTG@EDW_APPS_TO_WH(
    ACTIVITY_TYPE_FK,
    NAME,
    EXTERNAL_CONTACT,
    INSTANCE,
    BUSINESS_GROUP_ID,
    ACTIVITY_COST,
    ACTIVITY_PLANNED_COST,
    START_DATE,
    END_DATE,
    CLOSING_DATE,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    REC_ACTIVITY_DP,
    REC_ACTIVITY_ID,
    REC_ACTIVITY_PK,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(ACTIVITY_TYPE_FK, 'NA_EDW'),
NAME,
EXTERNAL_CONTACT,
INSTANCE,
BUSINESS_GROUP_ID,
ACTIVITY_COST,
ACTIVITY_PLANNED_COST,
START_DATE,
END_DATE,
CLOSING_DATE,
LAST_UPDATE_DATE,
CREATION_DATE,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
REC_ACTIVITY_DP,
REC_ACTIVITY_ID,
REC_ACTIVITY_PK,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_RACT_ACTIVITY_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_REC_ACT_M_C.g_row_count := EDW_HR_REC_ACT_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the EDW_HR_RACT_ACTIVITY_LSTG staging table');
   edw_log.put_line('Commiting records for EDW_HR_RACT_ACTIVITY_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_RACT_ACTIVITY_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_RACT_ACT_TYPE_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_RACT_ACT_TYPE_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_RACT_ACT_TYPE_LSTG@EDW_APPS_TO_WH(
    ACTIVITY_TYPE_PK,
    ALL_FK,
    ACTIVITY_TYPE_CODE,
    NAME,
    ACTIVITY_TYPE_DP,
    INSTANCE,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select ACTIVITY_TYPE_PK,
    NVL(ALL_FK, 'NA_EDW'),
ACTIVITY_TYPE_CODE,
NAME,
ACTIVITY_TYPE_DP,
INSTANCE,
LAST_UPDATE_DATE,
CREATION_DATE,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_RACT_ACT_TYPE_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_RACT_ACT_TYPE_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_RACT_ACT_TYPE_LSTG');
 Exception When others then
   raise;
commit;
END;
End EDW_HR_REC_ACT_M_C;

/