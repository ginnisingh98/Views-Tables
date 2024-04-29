--------------------------------------------------------
--  DDL for Package Body FII_AR_TRX_TYPE_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_TRX_TYPE_M_C" AS
/* $Header: FIIAR01B.pls 115.11 2002/01/31 16:43:26 pkm ship      $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out  Varchar2,
                Retcode      in out  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_AR_TRX_TYPE_M'  ;
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
  FII_AR_TRX_TYPE_M_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  FII_AR_TRX_TYPE_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(FII_AR_TRX_TYPE_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(FII_AR_TRX_TYPE_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_ARTT_TYPE_LSTG(FII_AR_TRX_TYPE_M_C.g_push_date_range1, FII_AR_TRX_TYPE_M_C.g_push_date_range2);
        Push_EDW_ARTT_CODE_LSTG(FII_AR_TRX_TYPE_M_C.g_push_date_range1, FII_AR_TRX_TYPE_M_C.g_push_date_range2);


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
   FII_AR_TRX_TYPE_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, FII_AR_TRX_TYPE_M_C.g_exception_msg,g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_ARTT_TYPE_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_ARTT_TYPE_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_ARTT_TYPE_LSTG(
    ALLOW_FRT_FLAG,
    ALLOW_OVAPP_FLAG,
    CM_TYPE_ID,
    CREATION_SIGN,
    DEFAULT_STATUS,
    DEFAULT_TERM,
    DESCRIPTION,
    END_DATE,
    GL_ID_CLEARING,
    GL_ID_FREIGHT,
    GL_ID_REC,
    GL_ID_REV,
    GL_ID_TAX,
    GL_ID_UNBILLED,
    GL_ID_UNEARNED,
    INSTANCE,
    NAME,
    ORG_ID,
    RULE_SET_ID,
    SET_OF_BOOKS_ID,
    START_DATE,
    STATUS,
    SUB_TRX_TYPE_ID,
    TAX_CALC_FLAG,
    TRANSACTION_TYPE,
    TRX_CODE_FK,
    TRX_TYPE_DP,
    TRX_TYPE_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select ALLOW_FRT_FLAG,
ALLOW_OVAPP_FLAG,
CM_TYPE_ID,
CREATION_SIGN,
DEFAULT_STATUS,
DEFAULT_TERM,
DESCRIPTION,
END_DATE,
GL_ID_CLEARING,
GL_ID_FREIGHT,
GL_ID_REC,
GL_ID_REV,
GL_ID_TAX,
GL_ID_UNBILLED,
GL_ID_UNEARNED,
INSTANCE,
NAME,
ORG_ID,
RULE_SET_ID,
SET_OF_BOOKS_ID,
START_DATE,
STATUS,
SUB_TRX_TYPE_ID,
TAX_CALC_FLAG,
TRANSACTION_TYPE,
    NVL(TRX_CODE_FK, 'NA_EDW'),
TRX_TYPE_DP,
TRX_TYPE_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from FII_AR_ARTT_TYPE_LCV
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   g_row_count := g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_ARTT_TYPE_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_ARTT_TYPE_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_ARTT_CODE_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_ARTT_CODE_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_ARTT_CODE_LSTG(
    ALL_FK,
    CREATION_DATE,
    DESCRIPTION,
    ENABLED_FLAG,
    END_DATE_ACTIVE,
    INSTANCE,
    NAME,
    STRT_DATE_ACTIVE,
    TRANSACTION_CODE,
    TRX_CODE_DP,
    TRX_CODE_PK,
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
ENABLED_FLAG,
END_DATE_ACTIVE,
INSTANCE,
NAME,
STRT_DATE_ACTIVE,
TRANSACTION_CODE,
TRX_CODE_DP,
TRX_CODE_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from FII_AR_ARTT_CODE_LCV
   where last_update_date between l_date1 and l_date2;


   edw_log.put_line('Commiting records for EDW_ARTT_CODE_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_ARTT_CODE_LSTG');
 Exception When others then
   raise;
commit;
END;
End FII_AR_TRX_TYPE_M_C;

/
