--------------------------------------------------------
--  DDL for Package Body FII_GL_BOOK_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_BOOK_M_C" AS
/* $Header: FIICMBKB.pls 120.2 2002/11/20 20:01:56 djanaswa ship $ */

 G_PUSH_DATE_RANGE1     Date		:=Null;
 G_PUSH_DATE_RANGE2     Date		:=Null;
 g_row_count         	Number		:=0;
 g_exception_msg     	varchar2(2000)	:=Null;

 Procedure Push(Errbuf       in out NOCOPY  	Varchar2,
                Retcode      in out NOCOPY  	Varchar2,
                p_from_date  IN   	Varchar2,
                p_to_date    IN   	Varchar2) IS

 l_dimension_name   	Varchar2(30) 	:='EDW_GL_BOOK_M'  ;
 l_temp_date            Date		:=Null;
 l_rows_inserted        Number		:=0;
 l_duration             Number		:=0;
 l_exception_msg        Varchar2(2000)	:=Null;
 l_from_date            Date		:=Null;
 l_to_date              Date		:=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
  Retcode:=0;

  edw_log.put_line( 'p_from_date = ' || p_from_date );
  edw_log.put_line( 'p_to_date   = ' || p_to_date );

  edw_log.put_line( 'About to set l_from_date' );
  l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');

  edw_log.put_line( 'About to set l_to_date' );
  l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  edw_log.put_line( 'Both date variables are set' );

  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR(-20000,'Error in SETUP: ' || errbuf);
  END IF;

  FII_GL_BOOK_M_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  FII_GL_BOOK_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(FII_GL_BOOK_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(FII_GL_BOOK_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_GL_BOOK_FA_BOOK_LSTG(FII_GL_BOOK_M_C.g_push_date_range1, FII_GL_BOOK_M_C.g_push_date_range2);
        Push_EDW_GL_BOOK_BOOK_LSTG(FII_GL_BOOK_M_C.g_push_date_range1, FII_GL_BOOK_M_C.g_push_date_range2);


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
   FII_GL_BOOK_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, FII_GL_BOOK_M_C.g_exception_msg,g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_GL_BOOK_FA_BOOK_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;

BEGIN
   edw_log.put_line('Starting Push_EDW_GL_BOOK_FA_BOOK_LSTG');
   l_date1 := p_from_date;
   l_date2 := p_to_date;

   Insert Into EDW_GL_BOOK_FA_BOOK_LSTG(
    BOOK_FK,
    BOOK_TYPE_NAME,
    CURRENCY_CODE,
    DELETION_DATE,
    DEPRE_CALANDAR,
    FA_BOOK,
    FA_BOOK_PK,
    INSTANCE,
    NAME,
    PRORATE_CALENDAR,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS,
    CREATION_DATE,
    LAST_UPDATE_DATE
   )
select     NVL(BOOK_FK, 'NA_EDW'),
BOOK_TYPE_NAME,
CURRENCY_CODE,
to_date(NULL), --DELETION_DATE,
DEPRE_CALANDAR,
FA_BOOK,
FA_BOOK_PK,
INSTANCE,
NAME,
PRORATE_CALENDAR,
NULL, --USER_ATTRIBUTE1,
NULL, --USER_ATTRIBUTE2,
NULL, --USER_ATTRIBUTE3,
NULL, --USER_ATTRIBUTE4,
NULL, --USER_ATTRIBUTE5,
NULL, -- OPERATION_CODE
'READY',
trunc(sysdate),
trunc(sysdate)
from FII_GL_BOOK_FA_BOOK_LCV
where last_update_date between l_date1 and l_date2;

   l_rows_inserted := sql%rowcount;
   g_row_count := g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_GL_BOOK_FA_BOOK_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_GL_BOOK_FA_BOOK_LSTG');

Exception When others then
   raise;
   commit;
END;


Procedure Push_EDW_GL_BOOK_BOOK_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;

BEGIN

   edw_log.put_line('Starting Push_EDW_GL_BOOK_BOOK_LSTG');
   l_date1 := p_from_date;
   l_date2 := p_to_date;

   Insert Into EDW_GL_BOOK_BOOK_LSTG(
    ACCT_PEIROD_TYPE,
    ALL_FK,
    BOOK_PK,
    CHART_OF_ACCTS_ID,
    CURRENCY_CODE,
    DELETION_DATE,
    GL_BOOK,
    INSTANCE,
    MRC_SOB_TYPE_CODE,
    NAME,
    PERIOD_SET_NAME,
    TRX_CALENDAR,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS,
    CREATION_DATE,
    LAST_UPDATE_DATE
   )
select ACCT_PERIOD_TYPE,
NVL(ALL_FK, 'NA_EDW'),
BOOK_PK,
CHART_OF_ACCTS_ID,
CURRENCY_CODE,
to_date(NULL), -- DELETION_DATE,
GL_BOOK,
INSTANCE,
MRC_SOB_TYPE_CODE,
NAME,
PERIOD_SET_NAME,
TRX_CALENDAR,
NULL, --USER_ATTRIBUTE1,
NULL, --USER_ATTRIBUTE2,
NULL, --USER_ATTRIBUTE3,
NULL, --USER_ATTRIBUTE4,
NULL, --USER_ATTRIBUTE5,
NULL, -- OPERATION_CODE
'READY',
trunc(sysdate),
trunc(sysdate)
from FII_GL_BOOK_BOOK_LCV
where last_update_date between l_date1 and l_date2;

   edw_log.put_line('Commiting records for EDW_GL_BOOK_BOOK_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_GL_BOOK_BOOK_LSTG');

 Exception When others then
   raise;
   commit;
END;

End FII_GL_BOOK_M_C;

/
