--------------------------------------------------------
--  DDL for Package Body EDW_MTL_INVENTORY_LOC_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MTL_INVENTORY_LOC_M_C" AS
/* $Header: OPIINVDB.pls 120.1 2005/06/08 01:10:03 appldev  $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_lowest_level_count       NUMBER := 0;
 g_exception_msg     varchar2(2000):=Null;
 Procedure Push(Errbuf       in out  NOCOPY Varchar2,
                Retcode      in out  NOCOPY Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_dimension_name   Varchar2(30) :='EDW_MTL_INVENTORY_LOC_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;
 l_temp_date_char           Varchar2(35);
   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
    Return;
  END IF;
  IF (p_from_date IS NULL) THEN
    EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date -
    EDW_COLLECTION_UTIL.g_offset;
  ELSE
    EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;
  IF (p_to_date IS NULL) THEN
    EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
    EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;
   edw_log.put_line( 'The collection range is from '||
        to_char(EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');
   l_temp_date := sysdate;
        Push_EDW_MTL_ILDM_LOCATOR_LSTG(EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1, EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2);
        Push_EDW_MTL_ILDM_SUB_INV_LSTG(EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1, EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2);
        Push_EDW_MTL_ILDM_PLANT_LSTG(EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1, EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2);
        Push_EDW_MTL_ILDM_OU_LSTG(EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1, EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2);
        Push_EDW_MTL_ILDM_PORG_LSTG(EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1, EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2);
        Push_EDW_MTL_ILDM_PCMP_LSTG(EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1, EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2);
   l_duration := sysdate - l_temp_date;
   edw_log.put_line('Total rows inserted : '||g_row_count);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_lowest_level_count,
			      EDW_MTL_INVENTORY_LOC_M_C.g_exception_msg,
			      EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1,
			      EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2);
commit;
 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_MTL_INVENTORY_LOC_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_MTL_INVENTORY_LOC_M_C.g_exception_msg,
			      EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range1,
			      EDW_MTL_INVENTORY_LOC_M_C.g_push_date_range2);
commit;
End;
Procedure Push_EDW_MTL_ILDM_LOCATOR_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_MTL_ILDM_LOCATOR_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_MTL_ILDM_LOCATOR_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    DESCRIPTION,
    ENABLED_FLAG,
    INSTANCE_CODE,
    LAST_UPDATE_DATE,
    LOCATOR_DP,
    LOCATOR_NAME,
    LOCATOR_PK,
    NAME,
    STOCK_ROOM_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
DESCRIPTION,
ENABLED_FLAG,
INSTANCE_CODE,
LAST_UPDATE_DATE,
LOCATOR_DP,
LOCATOR_NAME,
LOCATOR_PK,
NAME,
    NVL(STOCK_ROOM_FK, 'NA_EDW'),
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_MTL_ILDM_LOCATOR_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;

   EDW_MTL_INVENTORY_LOC_M_C.g_lowest_level_count := l_rows_inserted;

   EDW_MTL_INVENTORY_LOC_M_C.g_row_count := EDW_MTL_INVENTORY_LOC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_MTL_ILDM_LOCATOR_LSTG');
commit;
   edw_log.put_line('Completed Push_EDW_MTL_ILDM_LOCATOR_LSTG');
 Exception When others then
   raise;
commit;
END;
Procedure Push_EDW_MTL_ILDM_SUB_INV_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_MTL_ILDM_SUB_INV_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_MTL_ILDM_SUB_INV_LSTG@EDW_APPS_TO_WH(
    CREATION_DATE,
    DESCRIPTION,
    INSTANCE_CODE,
    LAST_UPDATE_DATE,
    NAME,
    PLANT_FK,
    STOCK_ROOM,
    STOCK_ROOM_DP,
    STOCK_ROOM_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CREATION_DATE,
DESCRIPTION,
INSTANCE_CODE,
LAST_UPDATE_DATE,
NAME,
    NVL(PLANT_FK, 'NA_EDW'),
STOCK_ROOM,
STOCK_ROOM_DP,
STOCK_ROOM_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_MTL_ILDM_SUB_INV_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   EDW_MTL_INVENTORY_LOC_M_C.g_row_count := EDW_MTL_INVENTORY_LOC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_MTL_ILDM_SUB_INV_LSTG');
commit;
   edw_log.put_line('Completed Push_EDW_MTL_ILDM_SUB_INV_LSTG');
 Exception When others then
   raise;
commit;
END;
Procedure Push_EDW_MTL_ILDM_PLANT_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_MTL_ILDM_PLANT_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_MTL_ILDM_PLANT_LSTG@EDW_APPS_TO_WH(
    OPERATING_UNIT_FK,
    CREATION_DATE,
    DESCRIPTION,
    INSTANCE_CODE,
    LAST_UPDATE_DATE,
    NAME,
    ORGANIZATION_CODE,
    ORGANIZATION_NAME,
    PLANT_DP,
    PLANT_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPM_ORGANIZATION_FK,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(Operating_Unit_FK, 'NA_EDW'),
CREATION_DATE,
DESCRIPTION,
INSTANCE_CODE,
LAST_UPDATE_DATE,
NAME,
ORGANIZATION_CODE,
ORGANIZATION_NAME,
PLANT_DP,
PLANT_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NVL(OPM_Organization_FK, 'NA_EDW'),
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_MTL_ILDM_PLANT_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   EDW_MTL_INVENTORY_LOC_M_C.g_row_count := EDW_MTL_INVENTORY_LOC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_MTL_ILDM_PLANT_LSTG');
commit;
   edw_log.put_line('Completed Push_EDW_MTL_ILDM_PLANT_LSTG');
 Exception When others then
   raise;
commit;
END;
Procedure Push_EDW_MTL_ILDM_OU_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_MTL_ILDM_OU_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_MTL_ILDM_OU_LSTG@EDW_APPS_TO_WH(
    OPERATING_UNIT_PK,
    OPERATING_UNIT_DP,
    NAME,
    BUSINESS_GROUP,
    DATE_FROM,
    DATE_TO,
    INT_EXT_FLAG,
    ORG_TYPE,
    ORG_CODE,
    PRIMARY_CST_MTHD,
    INSTANCE,
    ALL_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select OPERATING_UNIT_PK,
OPERATING_UNIT_DP,
NAME,
BUSINESS_GROUP,
DATE_FROM,
DATE_TO,
INT_EXT_FLAG,
ORG_TYPE,
ORG_CODE,
PRIMARY_CST_MTHD,
INSTANCE,
    NVL(ALL_FK, 'NA_EDW'),
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
CREATION_DATE,
LAST_UPDATE_DATE,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_MTL_ILDM_OU_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   EDW_MTL_INVENTORY_LOC_M_C.g_row_count := EDW_MTL_INVENTORY_LOC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_MTL_ILDM_OU_LSTG');
commit;
   edw_log.put_line('Completed Push_EDW_MTL_ILDM_OU_LSTG');
 Exception When others then
   raise;
commit;
END;
Procedure Push_EDW_MTL_ILDM_PORG_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_MTL_ILDM_PORG_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_MTL_ILDM_PORG_LSTG@EDW_APPS_TO_WH(
    OPM_COMPANY_FK,
    CREATION_DATE,
    DESCRIPTION,
    INSTANCE_CODE,
    LAST_UPDATE_DATE,
    NAME,
    OPM_ORGANIZATION_CODE,
    OPM_ORGANIZATION_NAME,
    OPM_ORGANIZATION_DP,
    OPM_ORGANIZATION_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(OPM_COMPANY_FK, 'NA_EDW'),
CREATION_DATE,
DESCRIPTION,
INSTANCE_CODE,
LAST_UPDATE_DATE,
NAME,
OPM_ORGANIZATION_CODE,
OPM_ORGANIZATION_NAME,
OPM_ORGANIZATION_DP,
OPM_ORGANIZATION_PK,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_MTL_ILDM_PORG_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   EDW_MTL_INVENTORY_LOC_M_C.g_row_count := EDW_MTL_INVENTORY_LOC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_MTL_ILDM_PORG_LSTG');
commit;
   edw_log.put_line('Completed Push_EDW_MTL_ILDM_PORG_LSTG');
 Exception When others then
   raise;
commit;
END;
Procedure Push_EDW_MTL_ILDM_PCMP_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_MTL_ILDM_PCMP_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_MTL_ILDM_PCMP_LSTG@EDW_APPS_TO_WH(
    OPERATING_UNIT_FK,
    OPM_COMPANY_NAME,
    OPM_COMPANY_DP,
    OPM_COMPANY_PK,
    CREATION_DATE,
    DESCRIPTION,
    INSTANCE_CODE,
    LAST_UPDATE_DATE,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPM_COMPANY_CODE,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(OPERATING_UNIT_FK, 'NA_EDW'),
OPM_COMPANY_NAME,
OPM_COMPANY_DP,
OPM_COMPANY_PK,
CREATION_DATE,
DESCRIPTION,
INSTANCE_CODE,
LAST_UPDATE_DATE,
NAME,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
OPM_COMPANY_CODE,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_MTL_ILDM_PCMP_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   EDW_MTL_INVENTORY_LOC_M_C.g_row_count := EDW_MTL_INVENTORY_LOC_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Commiting records for EDW_MTL_ILDM_PCMP_LSTG');
commit;
   edw_log.put_line('Completed Push_EDW_MTL_ILDM_PCMP_LSTG');
 Exception When others then
   raise;
commit;
END;
End EDW_MTL_INVENTORY_LOC_M_C;

/
