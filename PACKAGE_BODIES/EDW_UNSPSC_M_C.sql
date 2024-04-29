--------------------------------------------------------
--  DDL for Package Body EDW_UNSPSC_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_UNSPSC_M_C" AS
/* $Header: poaphunb.pls 115.16 2004/02/26 13:55:46 apalorka ship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_UNSPSC_M'  ;
 l_temp_date                Date:=Null;
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

  EDW_UNSPSC_M_C.g_push_date_range1 := nvl(l_from_date,
                EDW_COLLECTION_UTIL.G_local_last_push_start_date -
                EDW_COLLECTION_UTIL.g_offset);

  EDW_UNSPSC_M_C.g_push_date_range2 := nvl(l_to_date,
                           EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

  edw_log.put_line( 'The collection range is from '||
        to_char(EDW_UNSPSC_M_C.g_push_date_range1,
                'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_UNSPSC_M_C.g_push_date_range2,
                'MM/DD/YYYY HH24:MI:SS'));

  edw_log.put_line(' ');
  edw_log.put_line('Pushing data');

  Push_EDW_DNB_POA_ITEMS();
  Push_EDW_UNSPSC_CLASS_LSTG(EDW_UNSPSC_M_C.g_push_date_range1,
                             EDW_UNSPSC_M_C.g_push_date_range2);

  Push_EDW_UNSPSC_COMMODITY_LSTG(EDW_UNSPSC_M_C.g_push_date_range1,
                             EDW_UNSPSC_M_C.g_push_date_range2);

  Push_EDW_UNSPSC_FAMILY_LSTG(EDW_UNSPSC_M_C.g_push_date_range1,
                             EDW_UNSPSC_M_C.g_push_date_range2);

  Push_EDW_UNSPSC_FUNCTION_LSTG(EDW_UNSPSC_M_C.g_push_date_range1,
                             EDW_UNSPSC_M_C.g_push_date_range2);

  Push_EDW_UNSPSC_SEGMENT_LSTG(EDW_UNSPSC_M_C.g_push_date_range1,
                             EDW_UNSPSC_M_C.g_push_date_range2);

   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, EDW_UNSPSC_M_C.g_exception_msg,
                             g_push_date_range1, g_push_date_range2);

commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_UNSPSC_M_C.g_exception_msg  := l_exception_msg;
   rollback;

   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_UNSPSC_M_C.g_exception_msg,
                              g_push_date_range1, g_push_date_range2);

commit;
End Push;

Procedure Push_EDW_DNB_POA_ITEMS IS
BEGIN
  -- Fill up the Blank Columns from UNSPSC Code
  Update POA_UNSPSC_INTERFACE
  set Segment = UNSPSC,
      Segment_Description = UNSPSC_DESCRIPTION
  where (Segment IS NULL);

  Update POA_UNSPSC_INTERFACE
  set Family = UNSPSC,
      Family_Description = UNSPSC_DESCRIPTION
  where (Family IS NULL);

  Update POA_UNSPSC_INTERFACE
  set Class = UNSPSC,
      Class_Description = UNSPSC_DESCRIPTION
  where (Class IS NULL);

  Update POA_UNSPSC_INTERFACE
  set Commodity = UNSPSC,
      Commodity_Description = UNSPSC_DESCRIPTION
  where (Commodity IS NULL);

  Update POA_DNB_ITEMS poa
  set (Item_PK, Item_Name, Function, DNB_Update_Date) =
      (select Item_PK, Item_Name, UNSPSC || '-' || Function,
       sysdate from POA_UNSPSC_INTERFACE dnb
       where poa.Item_PK = dnb.Item_PK)
  where Item_PK IN
        (select Item_PK from POA_UNSPSC_INTERFACE dnb
         where ((poa.Item_PK = dnb.Item_PK) and
                 (poa.Function <> dnb.Function)));

  insert into POA_DNB_ITEMS poa
 (Item_PK, Item_Name, Function, DNB_Update_Date)
  (select Item_PK, Item_Name, UNSPSC || '-' || Function,
   sysdate from POA_UNSPSC_INTERFACE dnb
   where dnb.Item_PK NOT IN (select Item_PK
                             from POA_DNB_ITEMS));

END Push_EDW_DNB_POA_ITEMS;

Procedure Push_EDW_UNSPSC_CLASS_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_UNSPSC_CLASS_LSTG');
   l_date1 := p_from_date;
   l_date2 := p_to_date;
   Insert Into
   EDW_SPSC_CLASS_LSTG(
       NAME,
       CLASS_PK,
       CLASS_DP,
       CLASS_CODE,
       FAMILY_FK,
       INSTANCE,
       LAST_UPDATE_DATE,
       COLLECTION_STATUS)
   select
       distinct dnb.Class_Description,
       dnb.Class,
       dnb.Class_Description,
       dnb.Class,
       NVL(dnb.Family, 'NA_EDW'),
       NULL,
       sysdate,
       'READY'
   from POA_UNSPSC_INTERFACE dnb;

   l_rows_inserted := sql%rowcount;
   EDW_UNSPSC_M_C.g_row_count := EDW_UNSPSC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_SPSC_CLASS_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_UNSPSC_CLASS_LSTG');
 Exception When others then
   raise;
commit;
END Push_EDW_UNSPSC_CLASS_LSTG;



Procedure Push_EDW_UNSPSC_COMMODITY_LSTG(p_from_date IN date,
                                         p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_UNSPSC_COMMODITY_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
   EDW_SPSC_COMMODITY_LSTG(
      NAME,
      COMMODITY_PK,
      COMMODITY_CODE,
      COMMODITY_DP,
      UNSPSC,
      UNSPSC_DESCRIPTION,
      CLASS_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS)
   select
       distinct Commodity_Description,
       dnb.Commodity,
       dnb.Commodity,
       dnb.Commodity_Description,
       dnb.UNSPSC,
       dnb.UNSPSC_Description,
       NVL(dnb.Class, 'NA_EDW'),
       NULL,
       sysdate,
       'READY'
   from POA_UNSPSC_INTERFACE dnb;

   l_rows_inserted := sql%rowcount;
   EDW_UNSPSC_M_C.g_row_count := EDW_UNSPSC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_SPSC_COMMODITY_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_UNSPSC_COMMODITY_LSTG');
 Exception When others then
   raise;
   commit;
END Push_EDW_UNSPSC_COMMODITY_LSTG;




Procedure Push_EDW_UNSPSC_FAMILY_LSTG(p_from_date IN date,
                                      p_to_date IN DATE) IS

    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_UNSPSC_FAMILY_LSTG');
   l_date1 := p_from_date;
   l_date2 := p_to_date;
   Insert Into
   EDW_SPSC_FAMILY_LSTG(
       NAME,
       FAMILY_PK,
       FAMILY_DP,
       FAMILY_CODE,
       SEGMENT_FK,
       INSTANCE,
       LAST_UPDATE_DATE,
       COLLECTION_STATUS)
   select
       distinct Family_Description,
       dnb.Family,
       dnb.Family_Description,
       dnb.Family,
       NVL(Segment, 'NA_EDW'),
       NULL,
       sysdate,
       'READY'
   from POA_UNSPSC_INTERFACE dnb;

   l_rows_inserted := sql%rowcount;
   EDW_UNSPSC_M_C.g_row_count := EDW_UNSPSC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_SPSC_FAMILY_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_UNSPSC_FAMILY_LSTG');
 Exception When others then
   raise;
commit;
END Push_EDW_UNSPSC_FAMILY_LSTG;


Procedure Push_EDW_UNSPSC_FUNCTION_LSTG(p_from_date IN date,
                                         p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_UNSPSC_FUNCTION_LSTG_LSTG');
   l_date1 := p_from_date;
   l_date2 := p_to_date;

   -- Set the Update Fact Flag
   Update POA_UNSPSC_INTERFACE
   set Update_Fact_Flag = 'N';

   Update POA_UNSPSC_INTERFACE
   set Update_Fact_Flag = 'Y'
   where Item_PK IN (select Item_PK
                     from  POA_DNB_ITEMS poa
                     where poa.DNB_Update_Date between
                     l_date1 and l_date2);


   Insert Into
   EDW_SPSC_FUNCTION_LSTG(
       NAME,
       FUNCTION_PK,
       FUNCTION_DP,
       FUNCTION_CODE,
       COMMODITY_FK,
       INSTANCE,
       LAST_UPDATE_DATE,
       COLLECTION_STATUS,
       UPDATE_FACT_FLAG)
   select
       distinct NVL(ltrim(dnb.Function_Description), dnb.UNSPSC_Description),
       dnb.UNSPSC || '-' || dnb.Function,
       NVL(ltrim(dnb.Function_Description), dnb.UNSPSC_Description),
       dnb.UNSPSC || '-' || dnb.Function,
       NVL(Commodity, 'NA_EDW'),
       NULL,
       sysdate,
       'READY',
       dnb.Update_Fact_Flag
   from POA_UNSPSC_INTERFACE dnb,
        POA_DNB_ITEMS poa
   where (dnb.Item_PK = poa.Item_PK);

   l_rows_inserted := sql%rowcount;
   EDW_UNSPSC_M_C.g_row_count := EDW_UNSPSC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_SPSC_FUNCTION_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_UNSPSC_FUNCTION_LSTG');
 Exception When others then
   raise;
commit;
END Push_EDW_UNSPSC_FUNCTION_LSTG;




Procedure Push_EDW_UNSPSC_SEGMENT_LSTG(p_from_date IN date,
                                       p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_UNSPSC_SEGMENT_LSTG');
   l_date1 := p_from_date;
   l_date2 := p_to_date;

   Insert Into
   EDW_SPSC_SEGMENT_LSTG(
       NAME,
       SEGMENT_PK,
       SEGMENT_DP,
       SEGMENT_CODE,
       ALL_FK,
       INSTANCE,
       LAST_UPDATE_DATE,
       COLLECTION_STATUS)
   select
       distinct dnb.Segment_Description,
       dnb.Segment,
       dnb.Segment_Description,
       dnb.Segment,
       'ALL',
       NULL,
       sysdate,
       'READY'
   from POA_UNSPSC_INTERFACE dnb;

   l_rows_inserted := sql%rowcount;
   EDW_UNSPSC_M_C.g_row_count := EDW_UNSPSC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_SPSC_SEGMENT_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_UNSPSC_SEGMENT_LSTG');
 Exception When others then
   raise;
END Push_EDW_UNSPSC_SEGMENT_LSTG;

End EDW_UNSPSC_M_C;

/
