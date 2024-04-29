--------------------------------------------------------
--  DDL for Package Body EDW_POA_SPLRITEM_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_POA_SPLRITEM_M_C" AS
/* $Header: poaphsib.pls 120.1 2005/06/13 13:10:11 sriswami noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY  Varchar2,
                Retcode      in out NOCOPY  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_POA_SPLRITEM_M'  ;
 l_temp_date                Date:=Null;
 l_date1                Date:=Null;
 l_date2                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
 l_from_date            date;
 l_to_date              date;

Begin
  Errbuf :=NULL;
   Retcode:=0;
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
  END IF;

  l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  l_to_date := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

   l_date1 := g_push_date_range1;
   l_date2 := g_push_date_range2;
   edw_log.put_line( 'The collection range is from '||
        to_char(l_date1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(l_date2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_POA_SPIM_SPLRITEM_LSTG(EDW_POA_SPLRITEM_M_C.g_push_date_range1, EDW_POA_SPLRITEM_M_C.g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, P_PERIOD_START => l_date1,
                                                 P_PERIOD_END   => l_date2);
   commit;


 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_POA_SPLRITEM_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_POA_SPLRITEM_M_C.g_exception_msg,
                              g_push_date_range1, g_push_date_range2);

End;


Procedure Push_POA_SPIM_SPLRITEM_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_POA_SPIM_SPLRITEM_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_POA_SPIM_SPLRITEM_LSTG@EDW_APPS_TO_WH(
    ALL_FK,
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    NAME,
    SUPPLIER_ITEM_DP,
    SUPPLIER_ITEM_PK,
    SUPPLIER_NAME,
    SUPPLIER_SITE_CODE,
    SUPPLIER_SITE_ITEM_DP,
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
NAME,
SUPPLIER_ITEM_DP,
SUPPLIER_ITEM_PK,
SUPPLIER_NAME,
SUPPLIER_SITE_CODE,
SUPPLIER_SITE_ITEM_DP,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_POA_SPIM_SPLRITEM_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2
      OR last_update_date is NULL;

   l_rows_inserted := sql%rowcount;
   EDW_POA_SPLRITEM_M_C.g_row_count := EDW_POA_SPLRITEM_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_POA_SPIM_SPLRITEM_LSTG');

 Exception When others then
   rollback;
   raise;
END;
End EDW_POA_SPLRITEM_M_C;

/
