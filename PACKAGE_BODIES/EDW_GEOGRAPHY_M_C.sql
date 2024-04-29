--------------------------------------------------------
--  DDL for Package Body EDW_GEOGRAPHY_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_GEOGRAPHY_M_C" AS
/* $Header: poaphge.pkb 120.1 2005/06/13 13:06:36 sriswami noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count                Number:=0;
 g_row_count_m              Number:=0;
 g_exception_msg            varchar2(2000):=Null;

  g_schema              VARCHAR2(30);
  g_stmt                VARCHAR2(200);
  g_status              VARCHAR2(30);
  g_industry            VARCHAR2(30);
  g_source_link         VARCHAR2(128);
  g_target_link         VARCHAR2(128);

 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_GEOGRAPHY_M'  ;
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

  EDW_COLLECTION_UTIL.get_dblink_names(g_source_link, g_target_link);

  fnd_date.initialize('YYYY/MM/DD', 'YYYY/MM/DD HH24:MI:SS');
  l_from_date := fnd_date.displayDT_to_date(p_from_date);
  l_to_date := fnd_date.displayDT_to_date(p_to_date);

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

   IF (NOT FND_INSTALLATION.GET_APP_INFO('POA', g_status, g_industry, g_schema)) THEN
       RAISE_APPLICATION_ERROR (-20001, '***There is not POA schema set up***');
   END IF;

        Push_GEOG_POSTCODE_CITY_LSTG(g_push_date_range1, g_push_date_range2);
        Push_EDW_GEOG_LOCATION_LSTG (g_push_date_range1, g_push_date_range2);
        Push_EDW_GEOG_CITY_LSTG     (g_push_date_range1, g_push_date_range2);
        Push_EDW_GEOG_POSTCODE_LSTG (g_push_date_range1, g_push_date_range2);
        Push_GEOG_STATE_REGION_LSTG (g_push_date_range1, g_push_date_range2);
        Push_EDW_GEOG_STATE_LSTG    (g_push_date_range1, g_push_date_range2);
        Push_EDW_GEOG_REGION_LSTG   (g_push_date_range1, g_push_date_range2);
        Push_EDW_GEOG_COUNTRY_LSTG  (g_push_date_range1, g_push_date_range2);
        Push_EDW_GEOG_AREA2_LSTG    (g_push_date_range1, g_push_date_range2);
        Push_EDW_GEOG_AREA1_LSTG    (g_push_date_range1, g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Process Time: '|| edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count_m, P_PERIOD_START => l_date1,
                                                   P_PERIOD_END   => l_date2);
   commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_GEOGRAPHY_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_GEOGRAPHY_M_C.g_exception_msg,
                              g_push_date_range1, g_push_date_range2);
End;


Procedure Push_EDW_GEOG_LOCATION_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_LOCATION_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_GEOG_LOCATION_LSTG(
    ADDRESS_LINE_1,
    ADDRESS_LINE_2,
    ADDRESS_LINE_3,
    ADDRESS_LINE_4,
    POSTCODE_CITY_FK,
    CREATION_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    LOCATION_DP,
    LOCATION_PK,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
  (select ADDRESS_LINE_1,
ADDRESS_LINE_2,
ADDRESS_LINE_3,
ADDRESS_LINE_4,
    NVL(POSTCODE_CITY_FK, 'NA_EDW'),
CREATION_DATE,
INSTANCE,
LAST_UPDATE_DATE,
LOCATION_DP,
LOCATION_PK,
NAME,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_GEOG_LOCATION_LCV
   where last_update_date between l_date1 and l_date2
   union
   select CITY_FK,
          POSTCODE_FK,
          NULL,
          NULL,
          POSTCODE_CITY_PK,
          CREATION_DATE,
          INSTANCE,
          LAST_UPDATE_DATE,
          POSTCODE_CITY_DP,
          POSTCODE_CITY_PK,
          NAME,
          USER_ATTRIBUTE1,
          USER_ATTRIBUTE2,
          USER_ATTRIBUTE3,
          USER_ATTRIBUTE4,
          USER_ATTRIBUTE5,
          NULL,
          'READY'
    from EDW_GEOG_POSTCODE_CITY_LSTG
    where collection_status='READY');

   l_rows_inserted := sql%rowcount;
   EDW_GEOGRAPHY_M_C.g_row_count := EDW_GEOGRAPHY_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_LOCATION_LSTG');

   EDW_GEOGRAPHY_M_C.g_row_count_m := l_rows_inserted;

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_GEOG_POSTCODE_CITY_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_POSTCODE_CITY_LSTG');


-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT POSTCODE_CITY_PK FROM EDW_GEOG_POSTCODE_CITY_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

   l_date1 := p_from_date;
   l_date2 := p_to_date;

   Insert Into
    EDW_GEOG_POSTCODE_CITY_LSTG(
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    POSTCODE_CITY_PK,
    CITY_FK,
    POSTCODE_FK,
    POSTCODE_CITY_DP,
    NAME,
    OPERATION_CODE,
    COLLECTION_STATUS)
select
 INSTANCE,
 USER_ATTRIBUTE1,
 USER_ATTRIBUTE2,
 USER_ATTRIBUTE3,
 USER_ATTRIBUTE4,
 USER_ATTRIBUTE5,
 LAST_UPDATE_DATE,
 CREATION_DATE,
 POSTCODE_CITY_PK,
 NVL(CITY_FK, 'NA_EDW'),
 NVL(POSTCODE_FK, 'NA_EDW'),
 POSTCODE_CITY_DP,
 NAME,
 NULL, -- OPERATION_CODE
 'READY'
from
(select
  INSTANCE,
  USER_ATTRIBUTE1,
  USER_ATTRIBUTE2,
  USER_ATTRIBUTE3,
  USER_ATTRIBUTE4,
  USER_ATTRIBUTE5,
  max(LAST_UPDATE_DATE) as LAST_UPDATE_DATE ,
  max(CREATION_DATE) as CREATION_DATE ,
  POSTCODE_CITY_PK,
  CITY_FK,
  POSTCODE_FK,
  POSTCODE_CITY_DP,
  NAME
 from EDW_GEOG_POSTCODE_CITY_LCV
 where last_update_date between l_date1 and l_date2
 group by
   postcode_city_pk, city_fk, postcode_fk, postcode_city_dp,
   name, instance, user_attribute1, user_attribute2,
   user_attribute3, user_attribute4, user_attribute5)
where
      NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where POSTCODE_CITY_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   EDW_GEOGRAPHY_M_C.g_row_count := EDW_GEOGRAPHY_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_POSTCODE_CITY_LSTG');

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_EDW_GEOG_CITY_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_CITY_LSTG');

-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT CITY_PK FROM EDW_GEOG_CITY_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_GEOG_CITY_LSTG(
    CITY_PK,
    STATE_REGION_FK,
    CITY_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS)
 select
     CITY_PK,
     NVL(STATE_REGION_FK, 'NA_EDW'),
     CITY_DP,
     NAME,
     INSTANCE,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     NULL, -- OPERATION_CODE
     'READY'
 from
  (select
     CITY_PK,
     STATE_REGION_FK,
     CITY_DP,
     NAME,
     INSTANCE,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     max(LAST_UPDATE_DATE) as LAST_UPDATE_DATE,
     max(CREATION_DATE) as CREATION_DATE
   from EDW_GEOG_CITY_LCV
   where last_update_date between l_date1 and l_date2
   GROUP BY
      city_pk, state_region_fk, city_dp, name, instance,
      user_attribute1, user_attribute2, user_attribute3,
      user_attribute4, user_attribute5)
 where
       NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where CITY_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   g_row_count     := g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_CITY_LSTG');

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_EDW_GEOG_POSTCODE_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_POSTCODE_LSTG');

-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT POSTCODE_PK FROM EDW_GEOG_POSTCODE_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_GEOG_POSTCODE_LSTG(
    STATE_REGION_FK,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    POSTCODE_DP,
    POSTCODE_PK,
    OPERATION_CODE,
    COLLECTION_STATUS)
 select
    NVL(STATE_REGION_FK, 'NA_EDW'),
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    POSTCODE_DP,
    POSTCODE_PK,
    NULL, -- OPERATION_CODE
    'READY'
 from
 (select
    STATE_REGION_FK,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    max(LAST_UPDATE_DATE) as LAST_UPDATE_DATE ,
    max(CREATION_DATE) as CREATION_DATE,
    POSTCODE_DP,
    POSTCODE_PK
  from EDW_GEOG_POSTCODE_LCV
  where last_update_date between l_date1 and l_date2
  GROUP BY
     postcode_pk, state_region_fk, postcode_dp, name, instance,
     user_attribute1, user_attribute2, user_attribute3,
     user_attribute4, user_attribute5)
 where
       NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where POSTCODE_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   EDW_GEOGRAPHY_M_C.g_row_count := EDW_GEOGRAPHY_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_POSTCODE_LSTG');

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_GEOG_STATE_REGION_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
    l_tmp_str VARCHAR2 (120);
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_STATE_REGION_LSTG');

-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT STATE_REGION_PK FROM EDW_GEOG_STATE_REGION_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

   l_date1 := p_from_date;
   l_date2 := p_to_date;

   l_tmp_str := EDW_COLLECTION_UTIL.get_lookup_value ('EDW_LEVEL_PUSH_DOWN',
                                                      'EDW_GEOGRAPHY_M_SREG');
   if(l_tmp_str is NULL) THEN
     edw_log.put_line('***Warning*** : No Look Code Found From GET_LOOKUP_VALUE in Pushing State_Region');
   end if;

   Insert Into
    EDW_GEOG_STATE_REGION_LSTG(
    STATE_FK,
    STATE_REGION_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    STATE_REGION_PK,
    OPERATION_CODE,
    COLLECTION_STATUS)
 select
    NVL(STATE_FK, 'NA_EDW'),
    l_tmp_str || ' (' || STATE_REGION_DP || ')',
    l_tmp_str || ' (' || NAME || ')', --NAME
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    STATE_REGION_PK,
    NULL, -- OPERATION_CODE
    'READY'
 from
 (select
    STATE_FK,
    STATE_REGION_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    max(LAST_UPDATE_DATE) as LAST_UPDATE_DATE,
    max(CREATION_DATE) as CREATION_DATE,
    STATE_REGION_PK
  from EDW_GEOG_STATE_REGION_LCV
  where last_update_date between l_date1 and l_date2
  GROUP BY
    state_region_pk, state_fk, state_region_dp, name, instance,
    user_attribute1, user_attribute2, user_attribute3,
    user_attribute4, user_attribute5)
 where
       NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where STATE_REGION_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   EDW_GEOGRAPHY_M_C.g_row_count := EDW_GEOGRAPHY_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_STATE_REGION_LSTG');

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_EDW_GEOG_STATE_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_STATE_LSTG');

-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT STATE_PK FROM EDW_GEOG_STATE_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

l_date1 := p_from_date;
l_date2 := p_to_date;

   Insert Into
    EDW_GEOG_STATE_LSTG(
    STATE_PK,
    REGION_FK,
    STATE_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS)
 select
    STATE_PK,
    NVL(REGION_FK, 'NA_EDW'),
    STATE_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    NULL, -- OPERATION_CODE
    'READY'
 from
 (select
    STATE_PK,
    REGION_FK,
    STATE_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    max(LAST_UPDATE_DATE) as LAST_UPDATE_DATE,
    max(CREATION_DATE) as CREATION_DATE
  from EDW_GEOG_STATE_LCV
  where last_update_date between l_date1 and l_date2
  GROUP BY
    state_pk, region_fk, state_dp, name, instance,
    user_attribute1, user_attribute2, user_attribute3,
    user_attribute4, user_attribute5)
 where
       NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where STATE_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   EDW_GEOGRAPHY_M_C.g_row_count := EDW_GEOGRAPHY_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_STATE_LSTG');

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_EDW_GEOG_REGION_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
    l_tmp_str VARCHAR2 (120);
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_REGION_LSTG');

-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT REGION_PK FROM EDW_GEOG_REGION_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

   l_date1 := p_from_date;
   l_date2 := p_to_date;

   l_tmp_str := EDW_COLLECTION_UTIL.get_lookup_value ('EDW_LEVEL_PUSH_DOWN',
                                                      'EDW_GEOGRAPHY_M_REGN');
   if(l_tmp_str is NULL) THEN
     edw_log.put_line('***Warning*** : No Look Code Found From GET_LOOKUP_VALUE in Pushing REGION');
   end if;

   Insert Into
    EDW_GEOG_REGION_LSTG(
    REGION_PK,
    COUNTRY_FK,
    REGION_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS)
 select
    REGION_PK,
    NVL(COUNTRY_FK, 'NA_EDW'),
    l_tmp_str || ' (' || REGION_DP || ')',
    l_tmp_str || ' (' || NAME || ')', --NAME
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    NULL, -- OPERATION_CODE
    'READY'
 from
 (select
    REGION_PK,
    COUNTRY_FK,
    REGION_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    max(LAST_UPDATE_DATE) as LAST_UPDATE_DATE,
    max(CREATION_DATE) as CREATION_DATE
  from EDW_GEOG_REGION_LCV
  where last_update_date between l_date1 and l_date2
  GROUP BY
    region_pk, country_fk, region_dp, name, instance,
    user_attribute1, user_attribute2, user_attribute3,
    user_attribute4, user_attribute5)
 where
       NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where REGION_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   g_row_count := g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
                    ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_REGION_LSTG');

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_EDW_GEOG_COUNTRY_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_COUNTRY_LSTG');

-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT COUNTRY_PK FROM EDW_GEOG_COUNTRY_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_GEOG_COUNTRY_LSTG(
    COUNTRY_PK,
    AREA2_FK,
    COUNTRY_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS)
 select
    COUNTRY_PK,
    NVL(AREA2_FK, 'NA_EDW'),
    COUNTRY_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    NULL, -- OPERATION_CODE
    'READY'
 from
 (select
    COUNTRY_PK,
    AREA2_FK,
    COUNTRY_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    max(LAST_UPDATE_DATE) as LAST_UPDATE_DATE,
    max(CREATION_DATE) as CREATION_DATE
  from EDW_GEOG_COUNTRY_LCV
  where last_update_date between l_date1 and l_date2
  GROUP BY
    country_pk, area2_fk, country_dp, name, instance,
    user_attribute1,  user_attribute2, user_attribute3,
    user_attribute4,  user_attribute5)
 where
       NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where COUNTRY_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   EDW_GEOGRAPHY_M_C.g_row_count := EDW_GEOGRAPHY_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_COUNTRY_LSTG');

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_EDW_GEOG_AREA2_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
    l_tmp_str1 VARCHAR2 (120);
    l_tmp_str2 VARCHAR2 (120);
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_AREA2_LSTG');

-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT AREA2_PK FROM EDW_GEOG_AREA2_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

   l_date1 := p_from_date;
   l_date2 := p_to_date;

   l_tmp_str1 := EDW_COLLECTION_UTIL.get_lookup_value ('EDW_LEVEL_PUSH_DOWN',
                                                       'EDW_GEOGRAPHY_M_ARE2');
   l_tmp_str2 := EDW_COLLECTION_UTIL.get_lookup_value ('EDW_LEVEL_PUSH_DOWN', 'EDW_ALL');
   if(l_tmp_str1 is NULL or l_tmp_str2 is NULL) THEN
     edw_log.put_line('***Warning*** : No Look Code Found From GET_LOOKUP_VALUE in Pushing AREA2');
   end if;

  Insert Into
    EDW_GEOG_AREA2_LSTG(
    AREA2_PK,
    AREA1_FK,
    AREA2_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS)
  select
    AREA2_PK,
    NVL(AREA1_FK, 'NA_EDW'),
    l_tmp_str1 || ' (' || l_tmp_str2 || ')',  --AREA2_DP
    l_tmp_str1 || ' (' || l_tmp_str2 || ')',  --NAME
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    NULL, -- OPERATION_CODE
    'READY'
  from EDW_GEOG_AREA2_LCV
  where (last_update_date between l_date1 and l_date2
         OR last_update_date is NULL)
     AND NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where AREA2_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   EDW_GEOGRAPHY_M_C.g_row_count := EDW_GEOGRAPHY_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_AREA2_LSTG');

 Exception When others then
   rollback;
   raise;

END;


Procedure Push_EDW_GEOG_AREA1_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
    l_tmp_str1 VARCHAR2 (120);
    l_tmp_str2 VARCHAR2 (120);
BEGIN
   edw_log.put_line('Starting Push_EDW_GEOG_AREA1_LSTG');

-------- To get PK info from the warehouse (bug #1757640) ------

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.POA_EDW_TEMP_GEOG';
   EXECUTE IMMEDIATE g_stmt;

   /* Insert from remote warehouse level table */
   g_stmt := 'INSERT INTO POA_EDW_TEMP_GEOG ' ||
             'SELECT AREA1_PK FROM EDW_GEOG_AREA1_LTC@' ||
             g_target_link;
   EXECUTE IMMEDIATE g_stmt;

-----------------------------------------------------------------

   l_date1 := p_from_date;
   l_date2 := p_to_date;

   l_tmp_str1 := EDW_COLLECTION_UTIL.get_lookup_value ('EDW_LEVEL_PUSH_DOWN',
                                                       'EDW_GEOGRAPHY_M_ARE1');
   l_tmp_str2 := EDW_COLLECTION_UTIL.get_lookup_value ('EDW_LEVEL_PUSH_DOWN', 'EDW_ALL');
   if(l_tmp_str1 is NULL or l_tmp_str2 is NULL) THEN
     edw_log.put_line('***Warning*** : No Look Code Found From GET_LOOKUP_VALUE in Pushing AREA1');
   end if;

   Insert Into
    EDW_GEOG_AREA1_LSTG(
    AREA1_PK,
    ALL_FK,
    AREA1_DP,
    NAME,
    INSTANCE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select AREA1_PK,
    NVL(ALL_FK, 'NA_EDW'),
l_tmp_str1 || ' (' || l_tmp_str2 || ')',     --AREA1_DP
l_tmp_str1 || ' (' || l_tmp_str2 || ')',     --NAME
INSTANCE,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
LAST_UPDATE_DATE,
CREATION_DATE,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_GEOG_AREA1_LCV
   where (last_update_date between l_date1 and l_date2
         OR last_update_date is NULL)
     AND NOT EXISTS (select 1 from POA_EDW_TEMP_GEOG where AREA1_PK = TEMP_PK);

   l_rows_inserted := sql%rowcount;
   EDW_GEOGRAPHY_M_C.g_row_count := EDW_GEOGRAPHY_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');

   edw_log.put_line('Completed Push_EDW_GEOG_AREA1_LSTG');

 Exception When others then
   rollback;
   raise;

END;
End EDW_GEOGRAPHY_M_C;

/
