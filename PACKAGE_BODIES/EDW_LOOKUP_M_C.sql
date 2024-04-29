--------------------------------------------------------
--  DDL for Package Body EDW_LOOKUP_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_LOOKUP_M_C" AS
  /* $Header: poapplkb.pls 120.1 2005/06/13 13:14:05 sriswami noship $ */

g_row_count   Number :=0;
g_exception_message  varchar2(2000) :=NULL;

Procedure Push(Errbuf  in out NOCOPY Varchar2,
                        Retcode  in out NOCOPY Varchar2,
                        p_from_date in Varchar2,
                        p_to_date   in Varchar2) IS

l_dimension_name   Varchar2(30) :='EDW_LOOKUP_M';
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

  fnd_date.initialize('YYYY/MM/DD', 'YYYY/MM/DD HH24:MI:SS');
  l_from_date := fnd_date.displayDT_to_date(p_from_date);
  l_to_date := fnd_date.displayDT_to_date(p_to_date);

   l_push_date_range1 := nvl(l_from_date,
		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
   l_push_date_range2 := nvl(l_to_date, EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(l_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(l_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

   Edw_Lookup_M_C.Push_Edw_Lookups(Errbuf, Retcode, L_push_date_range1,l_push_date_range2);

  EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count,
                                   P_PERIOD_START => l_push_date_range1,
                                   P_PERIOD_END   => l_push_date_range2);
  commit;

Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_LOOKUP_M_C.g_exception_message := EDW_LOOKUP_M_C.g_exception_message||'<>'||Retcode || ':' || Errbuf;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_LOOKUP_M_C.g_exception_message,
                              l_push_date_range1, l_push_date_range2);
   rollback;
   raise;

End Push;


Procedure Push_Edw_Lookups(Errbuf   in out NOCOPY Varchar2,
               Retcode          in out NOCOPY Varchar2,
               p_from_date         in Date,
               p_to_date          in Date) IS

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

   l_push_date_range1 := p_from_date;
   l_push_date_range2 := p_to_date;
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;

   Insert Into EDW_LKUP_LOOKUP_CODE_LSTG(
     ALL_FK,
     ALL_FK_KEY,
     ROW_ID,
     DESCRIPTION,
     LOOKUP_CODE_DP,
     NAME,
     END_DATE_ACTIVE,
     INSTANCE,
     LAST_UPDATE_DATE,
     LOOKUP_CODE,
     LOOKUP_CODE_PK,
     LOOKUP_TYPE,
     START_DATE_ACTIVE,
     TABLE_CODE,
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
     'ALL', 		-- ALL_FK
     NULL,		-- ALL_FK_KEY
     NULL, 		-- ROW_ID
     DESCRIPTION,
     lookup_codes_dp, 	-- DISPLAYED_NAME,
     NAME, 		-- NAME
     NULL,
     INSTANCE, 		-- INSTANCE
     max(LAST_UPDATE_DATE), 	-- LAST_UPDATE_DATE
     LOOKUP_CODE,
     LOOKUP_CODE_PK, 	-- LOOKUP_CODE_PK
     LOOKUP_TYPE,
     NULL,
     TABLE_CODE,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- REQUEST_ID
     NULL, -- OPERATION_CODE
     NULL, -- ERROR_CODE
     'READY'
   from EDW_LOOKUP_CODES_LCV
   where last_update_date between l_push_date_range1 and
				l_push_date_range2
      OR last_update_date is NULL
   group by description, lookup_codes_dp,name, instance,
        user_attribute1, user_attribute2,
        user_attribute3, user_attribute4, user_attribute5,
   	lookup_code, lookup_code_pk, lookup_type, table_code;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted,0))||
         ' rows into the staging table');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_LOOKUP_M_C.g_row_count := EDW_LOOKUP_M_C.g_row_count + l_rows_inserted;

 Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;

   EDW_LOOKUP_M_C.g_exception_message := Retcode || ':' || Errbuf;
   rollback;

   raise;


End Push_Edw_Lookups;


End EDW_LOOKUP_M_C;

/
