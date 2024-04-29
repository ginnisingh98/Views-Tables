--------------------------------------------------------
--  DDL for Package Body EDW_OE_SLCHNL_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_OE_SLCHNL_M_C" AS
/* $Header: ISCSCD3B.pls 115.8 2002/12/19 00:52:48 scheung ship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_OE_SLCHNL_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date		    Date:=Null;
 l_to_date		    Date:=Null;

/*   REM -------------------------------------------
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

   EDW_OE_SLCHNL_M_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
   EDW_OE_SLCHNL_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

   edw_log.put_line( 'The collection range is from '||
        to_char(EDW_OE_SLCHNL_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_OE_SLCHNL_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

/* REM ------------------------------------------------------------------------
REM Start of Collection , Developer Customizable Section
REM ------------------------------------------------------------------------- */

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_OE_SCHN_SCHN_LSTG(EDW_OE_SLCHNL_M_C.g_push_date_range1, EDW_OE_SLCHNL_M_C.g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
/* REM -----------------------------------------------------------------------
REM END OF Collection , Developer Customizable Section
REM ------------------------------------------------------------------------- */
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, EDW_OE_SLCHNL_M_C.g_push_date_range1, EDW_OE_SLCHNL_M_C.g_push_date_range2);
commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_OE_SLCHNL_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_OE_SLCHNL_M_C.g_exception_msg, EDW_OE_SLCHNL_M_C.g_push_date_range1, EDW_OE_SLCHNL_M_C.g_push_date_range2);

commit;
End;


Procedure Push_EDW_OE_SCHN_SCHN_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_OE_SCHN_SCHN_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_OE_SCHN_SCHN_LSTG(
    ACTIVE_FROM_DATE,
    ACTIVE_TO_DATE,
    ALL_FK,
    CREATION_DATE,
    ENABLED_FLAG,
    INSTANCE_CODE,
    LAST_UPDATE_DATE,
    NAME,
    SALES_CHANNEL_CODE,
    SALES_CHANNEL_DP,
    SALES_CHANNEL_NAME,
    SALES_CHANNEL_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select ACTIVE_FROM_DATE,
ACTIVE_TO_DATE,
    NVL(ALL_FK, 'NA_EDW'),
CREATION_DATE,
ENABLED_FLAG,
INSTANCE_CODE,
LAST_UPDATE_DATE,
NAME,
SALES_CHANNEL_CODE,
SALES_CHANNEL_DP,
SALES_CHANNEL_NAME,
SALES_CHANNEL_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_OE_SCHN_SCHN_LCV
   where last_update_date between l_date1 and l_date2;


   l_rows_inserted := sql%rowcount;
   EDW_OE_SLCHNL_M_C.g_row_count := EDW_OE_SLCHNL_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_OE_SCHN_SCHN_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_OE_SCHN_SCHN_LSTG');
 Exception When others then
   raise;
commit;
END;
End EDW_OE_SLCHNL_M_C;

/
