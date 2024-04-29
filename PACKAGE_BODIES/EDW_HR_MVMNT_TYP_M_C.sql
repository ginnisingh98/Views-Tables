--------------------------------------------------------
--  DDL for Package Body EDW_HR_MVMNT_TYP_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_MVMNT_TYP_M_C" AS
/* $Header: hriepmvt.pkb 120.1 2005/06/07 05:55:47 anmajumd noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_dimension_name   Varchar2(30) :='EDW_HR_MVMNT_TYP_M'  ;
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
		EDW_HR_MVMNT_TYP_M_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date -
		EDW_COLLECTION_UTIL.g_offset;
  ELSE
	EDW_HR_MVMNT_TYP_M_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
		EDW_HR_MVMNT_TYP_M_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
	EDW_HR_MVMNT_TYP_M_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;


   edw_log.put_line( 'The collection range is from '||
        to_char(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_HR_MVMNT_TYP_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_HR_MVMT_MVMNTS_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_GAIN_1_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_LOSS_1_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_RCTMNT_1_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_SPRTN_1_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_GAIN_2_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_LOSS_2_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_RCTMNT_2_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_SPRTN_2_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_GAIN_3_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_LOSS_3_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_RCTMNT_3_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);
        Push_EDW_HR_MVMT_SPRTN_3_LSTG(EDW_HR_MVMNT_TYP_M_C.g_push_date_range1, EDW_HR_MVMNT_TYP_M_C.g_push_date_range2);


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
   EDW_HR_MVMNT_TYP_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_HR_MVMNT_TYP_M_C.g_exception_msg, g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_HR_MVMT_MVMNTS_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_MVMNTS_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_MVMNTS_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    GAIN_TYPE_LVL1_FK,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOSS_TYPE_LVL1_FK,
    MOVEMENT_CMBN_ID,
    MOVEMENT_DP,
    MOVEMENT_PK,
    NAME,
    REC_TYPE_LVL1_FK,
    SEP_TYPE_LVL1_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
    NVL(GAIN_TYPE_LVL1_FK, 'NA_EDW'),
INSTANCE,
LAST_UPDATE_DATE,
    NVL(LOSS_TYPE_LVL1_FK, 'NA_EDW'),
MOVEMENT_CMBN_ID,
MOVEMENT_DP,
MOVEMENT_PK,
NAME,
    NVL(REC_TYPE_LVL1_FK, 'NA_EDW'),
    NVL(SEP_TYPE_LVL1_FK, 'NA_EDW'),
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_MVMNTS_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_MVMNTS_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_MVMNTS_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_GAIN_1_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_GAIN_1_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_GAIN_1_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    GAIN_TYPE_LVL1_DP,
    GAIN_TYPE_LVL1_ID,
    GAIN_TYPE_LVL1_PK,
    GAIN_TYPE_LVL2_FK,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
GAIN_TYPE_LVL1_DP,
GAIN_TYPE_LVL1_ID,
GAIN_TYPE_LVL1_PK,
    NVL(GAIN_TYPE_LVL2_FK, 'NA_EDW'),
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_GAIN_1_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_GAIN_1_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_GAIN_1_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_LOSS_1_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_LOSS_1_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_LOSS_1_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    LOSS_TYPE_LVL1_DP,
    LOSS_TYPE_LVL1_ID,
    LOSS_TYPE_LVL1_PK,
    LOSS_TYPE_LVL2_FK,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
LOSS_TYPE_LVL1_DP,
LOSS_TYPE_LVL1_ID,
LOSS_TYPE_LVL1_PK,
    NVL(LOSS_TYPE_LVL2_FK, 'NA_EDW'),
NAME,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_LOSS_1_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_LOSS_1_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_LOSS_1_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_RCTMNT_1_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_RCTMNT_1_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_RCTMNT_1_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    REC_TYPE_LVL1_DP,
    REC_TYPE_LVL1_ID,
    REC_TYPE_LVL1_PK,
    REC_TYPE_LVL2_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
REC_TYPE_LVL1_DP,
REC_TYPE_LVL1_ID,
REC_TYPE_LVL1_PK,
    NVL(REC_TYPE_LVL2_FK, 'NA_EDW'),
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_RCTMNT_1_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_RCTMNT_1_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_RCTMNT_1_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_SPRTN_1_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_SPRTN_1_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_SPRTN_1_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    SEP_TYPE_LVL1_DP,
    SEP_TYPE_LVL1_ID,
    SEP_TYPE_LVL1_PK,
    SEP_TYPE_LVL2_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
SEP_TYPE_LVL1_DP,
SEP_TYPE_LVL1_ID,
SEP_TYPE_LVL1_PK,
    NVL(SEP_TYPE_LVL2_FK, 'NA_EDW'),
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_SPRTN_1_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_SPRTN_1_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_SPRTN_1_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_GAIN_2_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_GAIN_2_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_GAIN_2_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    GAIN_TYPE_LVL2_DP,
    GAIN_TYPE_LVL2_ID,
    GAIN_TYPE_LVL2_PK,
    GAIN_TYPE_LVL3_FK,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
GAIN_TYPE_LVL2_DP,
GAIN_TYPE_LVL2_ID,
GAIN_TYPE_LVL2_PK,
    NVL(GAIN_TYPE_LVL3_FK, 'NA_EDW'),
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_GAIN_2_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_GAIN_2_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_GAIN_2_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_LOSS_2_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_LOSS_2_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_LOSS_2_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    LOSS_TYPE_LVL2_DP,
    LOSS_TYPE_LVL2_ID,
    LOSS_TYPE_LVL2_PK,
    LOSS_TYPE_LVL3_FK,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
LOSS_TYPE_LVL2_DP,
LOSS_TYPE_LVL2_ID,
LOSS_TYPE_LVL2_PK,
    NVL(LOSS_TYPE_LVL3_FK, 'NA_EDW'),
NAME,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_LOSS_2_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_LOSS_2_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_LOSS_2_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_RCTMNT_2_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_RCTMNT_2_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_RCTMNT_2_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    REC_TYPE_LVL2_DP,
    REC_TYPE_LVL2_ID,
    REC_TYPE_LVL2_PK,
    REC_TYPE_LVL3_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
REC_TYPE_LVL2_DP,
REC_TYPE_LVL2_ID,
REC_TYPE_LVL2_PK,
    NVL(REC_TYPE_LVL3_FK, 'NA_EDW'),
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_RCTMNT_2_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_RCTMNT_2_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_RCTMNT_2_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_SPRTN_2_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_SPRTN_2_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_SPRTN_2_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    SEP_TYPE_LVL2_DP,
    SEP_TYPE_LVL2_ID,
    SEP_TYPE_LVL2_PK,
    SEP_TYPE_LVL3_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
SEP_TYPE_LVL2_DP,
SEP_TYPE_LVL2_ID,
SEP_TYPE_LVL2_PK,
    NVL(SEP_TYPE_LVL3_FK, 'NA_EDW'),
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_SPRTN_2_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_SPRTN_2_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_SPRTN_2_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_GAIN_3_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_GAIN_3_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_GAIN_3_LSTG@EDW_APPS_TO_WH(
    ALL_FK,
    CREATION_DATE,
    GAIN_TYPE_LVL3_DP,
    GAIN_TYPE_LVL3_ID,
    GAIN_TYPE_LVL3_PK,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(ALL_FK, 'NA_EDW'),
CREATION_DATE,
GAIN_TYPE_LVL3_DP,
GAIN_TYPE_LVL3_ID,
GAIN_TYPE_LVL3_PK,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_GAIN_3_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_GAIN_3_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_GAIN_3_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_LOSS_3_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_LOSS_3_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_LOSS_3_LSTG@EDW_APPS_TO_WH(
    ALL_FK,
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    LOSS_TYPE_LVL3_DP,
    LOSS_TYPE_LVL3_ID,
    LOSS_TYPE_LVL3_PK,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(ALL_FK, 'NA_EDW'),
CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
LOSS_TYPE_LVL3_DP,
LOSS_TYPE_LVL3_ID,
LOSS_TYPE_LVL3_PK,
NAME,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_LOSS_3_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_LOSS_3_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_LOSS_3_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_RCTMNT_3_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_RCTMNT_3_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_RCTMNT_3_LSTG@EDW_APPS_TO_WH(
    ALL_FK,
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    REC_TYPE_LVL3_DP,
    REC_TYPE_LVL3_ID,
    REC_TYPE_LVL3_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(ALL_FK, 'NA_EDW'),
CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
REC_TYPE_LVL3_DP,
REC_TYPE_LVL3_ID,
REC_TYPE_LVL3_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_RCTMNT_3_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_RCTMNT_3_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_RCTMNT_3_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_HR_MVMT_SPRTN_3_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_MVMT_SPRTN_3_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_MVMT_SPRTN_3_LSTG@EDW_APPS_TO_WH(
    ALL_FK,
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOOKUP_CODE,
    NAME,
    SEP_TYPE_LVL3_DP,
    SEP_TYPE_LVL3_ID,
    SEP_TYPE_LVL3_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(ALL_FK, 'NA_EDW'),
CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOOKUP_CODE,
NAME,
SEP_TYPE_LVL3_DP,
SEP_TYPE_LVL3_ID,
SEP_TYPE_LVL3_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_MVMT_SPRTN_3_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_HR_MVMNT_TYP_M_C.g_row_count := EDW_HR_MVMNT_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_HR_MVMT_SPRTN_3_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_MVMT_SPRTN_3_LSTG');
 Exception When others then
   raise;
commit;
END;
End EDW_HR_MVMNT_TYP_M_C;

/
