--------------------------------------------------------
--  DDL for Package Body EDW_POA_LN_TYPE_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_POA_LN_TYPE_M_C" AS
  /* $Header: poappltb.pls 120.1 2005/06/13 13:15:32 sriswami noship $ */

g_row_count  Number:= 0;
g_exception_message        Varchar2(2000) := Null;

Procedure Push(Errbuf  in out NOCOPY Varchar2,
                        Retcode  in out NOCOPY Varchar2,
                        p_from_date Varchar2,
                        p_to_date   Varchar2) IS

l_dimension_name   Varchar2(30) := 'EDW_POA_LN_TYPE_M';
l_push_date_range1 Date:= Null;
l_push_date_range2 Date:= Null;

 l_from_date            date;
 l_to_date              date;

BEGIN
   Errbuf := NULL;
   Retcode := 0;

   If (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) Then
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
   End If;

  l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  l_to_date := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

l_push_date_range1 := nvl(l_from_date,
    EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
   l_push_date_range2 := nvl(l_to_date, EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(l_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(l_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

   Edw_POA_LN_TYPE_M_C.Push_LN_TYPE(Errbuf, Retcode, L_push_date_range1,l_push_date_range2);


  EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count,
                                   P_PERIOD_START => l_push_date_range1,
                                   P_PERIOD_END   => l_push_date_range2);
  commit;

Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_POA_LN_TYPE_M_C.g_exception_message := EDW_POA_LN_TYPE_M_C.g_exception_message||'<>
'||Retcode || ':' || Errbuf;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_POA_LN_TYPE_M_C.g_exception_message,
                              l_push_date_range1, l_push_date_range2);
   rollback;
   raise;

End Push;

Procedure Push_LN_TYPE(Errbuf            in out NOCOPY Varchar2,
               Retcode           in out NOCOPY Varchar2,
               p_from_date          Date,
               p_to_date            Date) IS
 l_push_date_range1     Date := NULL;
 l_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------

Begin
   Errbuf :=NULL;
   Retcode:=0;

   l_push_date_range1 :=p_from_date;
   l_push_date_range2:=p_to_date;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;

   Insert Into EDW_POA_LNTP_LN_TYPE_LSTG@EDW_APPS_TO_WH(
     ALL_FK,
     ALL_FK_KEY,
     ROW_ID,
     LINE_TYPE_DP,
--     DELETION_DATE,
     DESCRIPTION,
     INACTIVE_DATE,
     INSTANCE,
     NAME,
     LINE_TYPE_PK,
     ORDER_TYPE,
     OUTSIDE_OP_FLAG,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     REQUEST_ID,
     OPERATION_CODE,
     ERROR_CODE,
     COLLECTION_STATUS)
   select
     'ALL',
     NULL,  		    -- ALL_FK_KEY,
     NULL,                  -- ROW_ID,
     LINE_TYPE_PK,          -- LINE_TYPE_DP,
--     NULL,		    DELETION_DATE,
     DESCRIPTION,
     INACTIVE_DATE,
     INSTANCE,
     LINE_TYPE_PK,	    --LINE_TYPE_NAME,
     LINE_TYPE_PK,
     ORDER_TYPE,
     OUTSIDE_OP_FLAG,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL,                  --REQUEST_ID,
     NULL,		    --OPERATION_CODE,
     NULL,                  --ERROR_CODE
     'READY'
   from EDW_POA_LN_TYPE_lCV@apps_to_apps
   where last_update_date between l_push_date_range1 and l_push_date_range2
      OR last_update_date is NULL;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted,0))||
         ' rows into the staging table');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_POA_LN_TYPE_M_C.g_row_count :=EDW_POA_LN_TYPE_M_C.g_row_count +l_rows_inserted;

 Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_POA_LN_TYPE_M_C.g_exception_message :=  Retcode || ':' || Errbuf;
   rollback;

   raise;

End Push_ln_type;

End EDW_POA_LN_TYPE_M_C;

/
