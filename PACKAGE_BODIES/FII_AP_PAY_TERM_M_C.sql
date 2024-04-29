--------------------------------------------------------
--  DDL for Package Body FII_AP_PAY_TERM_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_PAY_TERM_M_C" AS
/* $Header: FIICMPTB.pls 120.2 2002/11/20 20:14:01 djanaswa ship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY  Varchar2,
                Retcode      in out NOCOPY  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_AP_PAY_TERM_M'  ;
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
  FII_AP_PAY_TERM_M_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  FII_AP_PAY_TERM_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(FII_AP_PAY_TERM_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(FII_AP_PAY_TERM_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_AP_PTRM_PAY_TERM_LSTG(FII_AP_PAY_TERM_M_C.g_push_date_range1, FII_AP_PAY_TERM_M_C.g_push_date_range2);


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
   FII_AP_PAY_TERM_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, FII_AP_PAY_TERM_M_C.g_exception_msg,g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_AP_PTRM_PAY_TERM_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_AP_PTRM_PAY_TERM_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_AP_PTRM_PAY_TERM_LSTG(
    ALL_FK,
    DELETION_DATE,
    DESCRIPTION,
    ENABLED_FLAG,
    END_DATE_ACTIVE,
    INSTANCE,
    NAME,
    PAYMENT_TERM,
    PAY_TERM_PK,
    RANK,
    START_DATE_ACTIVE,
    TERM_TYPE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(ALL_FK, 'NA_EDW'),
to_date(NULL), -- DELETION_DATE,
DESCRIPTION,
ENABLED_FLAG,
END_DATE_ACTIVE,
INSTANCE,
NAME,
PAYMENT_TERM,
PAY_TERM_PK,
RANK,
START_DATE_ACTIVE,
TERM_TYPE,
NULL, --USER_ATTRIBUTE1,
NULL, --USER_ATTRIBUTE2,
NULL, --USER_ATTRIBUTE3,
NULL, --USER_ATTRIBUTE4,
NULL, --USER_ATTRIBUTE5,
NULL, -- OPERATION_CODE
    'READY'
   from FII_AP_PTRM_PAY_TERM_LCV
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   g_row_count := g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_AP_PTRM_PAY_TERM_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_AP_PTRM_PAY_TERM_LSTG');
 Exception When others then
   raise;
commit;
END;
End FII_AP_PAY_TERM_M_C;

/
