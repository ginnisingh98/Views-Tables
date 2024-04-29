--------------------------------------------------------
--  DDL for Package Body FII_AP_RELEASE_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_RELEASE_M_C" AS
/* $Header: FIIAP06B.pls 120.2 2002/11/20 19:57:44 djanaswa ship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY  Varchar2,
                Retcode      in out NOCOPY  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_RELEASE_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR(-20000,'Error in SETUP: ' || errbuf);
  END IF;
  FII_AP_RELEASE_M_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  FII_AP_RELEASE_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(FII_AP_RELEASE_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(FII_AP_RELEASE_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_RLSE_RELEASE_LSTG(FII_AP_RELEASE_M_C.g_push_date_range1, FII_AP_RELEASE_M_C.g_push_date_range2);
        P_EDW_RLSE_RELEASE_TYPE_LSTG(FII_AP_RELEASE_M_C.g_push_date_range1, FII_AP_RELEASE_M_C.g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count,null,g_push_date_range1, g_push_date_range2);
commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   FII_AP_RELEASE_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, FII_AP_RELEASE_M_C.g_exception_msg,g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_RLSE_RELEASE_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_RLSE_RELEASE_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_RLSE_RELEASE_LSTG(
    CREATION_DATE,
    DESCRIPTION,
    INACTIVE_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    NAME,
    POSTABLE_FLAG,
    RELEASE_DP,
    RELEASE_NAME,
    RELEASE_PK,
    RELEASE_TYPE_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    USER_RELEASEABLE_FLAG,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
DESCRIPTION,
INACTIVE_DATE,
INSTANCE,
LAST_UPDATE_DATE,
NAME,
POSTABLE_FLAG,
RELEASE_DP,
RELEASE_NAME,
RELEASE_PK,
    NVL(RELEASE_TYPE_FK, 'NA_EDW'),
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
USER_RELEASEABLE_FLAG,
    NULL, -- OPERATION_CODE
    'READY'
   from FII_AP_RLSE_RELEASE_LCV;


   l_rows_inserted := sql%rowcount;
   g_row_count := g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_RLSE_RELEASE_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_RLSE_RELEASE_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure P_EDW_RLSE_RELEASE_TYPE_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting P_EDW_RLSE_RELEASE_TYPE_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_RLSE_RELEASE_TYPE_LSTG(
    ALL_FK,
    CREATION_DATE,
    DESCRIPTION,
    INSTANCE,
    LAST_UPDATE_DATE,
    NAME,
    RELEASE_TYPE,
    RELEASE_TYPE_DP,
    RELEASE_TYPE_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(ALL_FK, 'NA_EDW'),
CREATION_DATE,
DESCRIPTION,
INSTANCE,
LAST_UPDATE_DATE,
NAME,
RELEASE_TYPE,
RELEASE_TYPE_DP,
RELEASE_TYPE_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from FII_AP_RLSE_RELEASE_TYPE_LCV;


   edw_log.put_line('Commiting records for EDW_RLSE_RELEASE_TYPE_LSTG');
commit;

   edw_log.put_line('Completed P_EDW_RLSE_RELEASE_TYPE_LSTG');
 Exception When others then
   raise;
commit;
END;
End FII_AP_RELEASE_M_C;

/
