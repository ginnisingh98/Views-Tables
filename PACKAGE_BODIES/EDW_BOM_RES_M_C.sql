--------------------------------------------------------
--  DDL for Package Body EDW_BOM_RES_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_BOM_RES_M_C" AS
/* $Header: ENICRESB.pls 115.4 2004/01/30 20:33:58 sbag noship $ */
 l_push_date_range1 DATE := NULL;
 l_push_date_range2 DATE := NULL;
 g_row_count NUMBER := 0;
 g_exception_message VARCHAR2(10000) := null;

 Procedure Push(Errbuf       out NOCOPY Varchar2,
                Retcode      out NOCOPY Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
 l_from_date            date;
 l_to_date              date;
Begin
  Errbuf :=NULL;
  Retcode:=NULL;

   IF (Not EDW_COLLECTION_UTIL.setup('EDW_BOM_RES_M')) THEN
    	errbuf := fnd_message.get;
    	RAISE_APPLICATION_ERROR(-20000,'Error in SETUP: ' || errbuf);
    END IF;

-- Date processing

  l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  l_to_date := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

   l_push_date_range1:= nvl(l_from_date,EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
   l_push_date_range2:= nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(l_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(l_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');
   edw_log.put_line('Pushing Data');

  Push_EDW_BRES_PLANT(l_push_date_range1, l_push_date_range2);
  Push_EDW_BRES_PLANT1(l_push_date_range1, l_push_date_range2);
  Push_EDW_BRES_RESOURCE(l_push_date_range1, l_push_date_range2);
  Push_EDW_BRES_RESGROUP(l_push_date_range1, l_push_date_range2);
  Push_EDW_BRES_RESTYPE(l_push_date_range1, l_push_date_range2);
  Push_EDW_BRES_RESCAT(l_push_date_range1, l_push_date_range2);
  Push_EDW_BRES_PARENT_DEPT(l_push_date_range1, l_push_date_range2);
  Push_EDW_BRES_DEPT(l_push_date_range1, l_push_date_range2);
  Push_EDW_BRES_DEPT_CLASS(l_push_date_range1, l_push_date_range2);

  EDW_COLLECTION_UTIL.wrapup(TRUE, EDW_BOM_RES_M_C.g_row_count, null, l_push_date_range1, l_push_date_range2);
  commit;

Exception When others then
  Errbuf := sqlerrm;
  Retcode := sqlcode;
  EDW_BOM_RES_M_C.g_exception_message := EDW_BOM_RES_M_C.g_exception_message||' <> '||Retcode||' : '||Errbuf;
  Rollback;
  EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_BOM_RES_M_C.g_exception_message,l_push_date_range1, l_push_date_range2);
  commit;

End Push;

Procedure Push_EDW_BRES_PLANT(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_PLANT_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

/******************************************/

   edw_log.put_line(' ');
   edw_log.put_line('Pushing EDW_BRES_PLANT');

   Insert Into EDW_BRES_PLANT_LSTG(
     ALL_FK,
     ALL_FK_KEY,
     CREATION_DATE,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     ORGANIZATION_CODE,
     ORGANIZATION_NAME,
     PLANT_DP,
     PLANT_PK,
     REQUEST_ID,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALL_FK,
     NULL, --ALL_FK_KEY,
     CREATION_DATE,
     substrb(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     SUBSTRB(NAME,1,320),
     ORGANIZATION_CODE,
     SUBSTRB(ORGANIZATION_NAME,1,500),
     PLANT_DP,
     PLANT_PK,
     NULL, --REQUEST_ID,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_PLANT_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;
   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

 Exception When others then
    raise;
    commit;

End Push_EDW_BRES_PLANT;

Procedure Push_EDW_BRES_PLANT1(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_PLANT_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

/******************************************/

   edw_log.put_line(' ');
   edw_log.put_line('Pushing EDW_BRES_PLANT1');

   Insert Into EDW_BRES_PLANT1_LSTG(
     ALL_FK,
     ALL_FK_KEY,
     CREATION_DATE,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     ORGANIZATION_CODE,
     ORGANIZATION_NAME,
     PLANT_DP,
     PLANT_PK,
     REQUEST_ID,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALL_FK,
     NULL, --ALL_FK_KEY,
     CREATION_DATE,
     substrb(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     substrb(NAME,1,320),
     ORGANIZATION_CODE,
     SUBSTRB(ORGANIZATION_NAME,1,500),
     PLANT_DP,
     PLANT_PK,
     NULL, --REQUEST_ID,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_PLANT_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;
   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

 Exception When others then
    raise;
    commit;

End Push_EDW_BRES_PLANT1;

Procedure Push_EDW_BRES_RESOURCE(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_RESOURCE_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

   edw_log.put_line(' ');
   edw_log.put_line('Pushing EDW_BRES_RESOURCE');

   Insert Into EDW_BRES_RESOURCE_LSTG(
     AVAIL_24_HRS_FLAG,
     CREATION_DATE,
     DEPARTMENT_FK,
     DEPARTMENT_FK_KEY,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     MAXIMUM_RATE,
     MINIMUM_RATE,
     NAME,
     REQUEST_ID,
     RESOURCE_CATEGORY1_FK,
     RESOURCE_CATEGORY1_FK_KEY,
     RESOURCE_CATEGORY2_FK,
     RESOURCE_CATEGORY2_FK_KEY,
     RESOURCE_CODE,
     RESOURCE_DP,
     RESOURCE_GROUP_FK,
     RESOURCE_GROUP_FK_KEY,
     RESOURCE_PK,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     AVAIL_24_HRS_FLAG,
     CREATION_DATE,
     DEPARTMENT_FK,
     NULL, --DEPARTMENT_FK_KEY,
     substrb(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     MAXIMUM_RATE,
     MINIMUM_RATE,
     substrb(NAME,1,320),
     NULL, --REQUEST_ID,
     RESOURCE_CATEGORY1_FK,
     NULL, --RESOURCE_CATEGORY1_FK_KEY,
     RESOURCE_CATEGORY2_FK,
     NULL, --RESOURCE_CATEGORY2_FK_KEY,
     RESOURCE_CODE,
     RESOURCE_DP,
     RESOURCE_GROUP_FK,
     NULL, --RESOURCE_GROUP_FK_KEY,
     RESOURCE_PK,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_RESOURCE_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;
   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

 Exception When others then
    raise;
    commit;
End Push_EDW_BRES_RESOURCE;

Procedure Push_EDW_BRES_RESGROUP(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_RESGROUP_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

   edw_log.put_line(' ');
   edw_log.put_line('Pushing EDW_BRES_RESGROUP');

   Insert Into EDW_BRES_RESGROUP_LSTG(
     ALL_FK,
     ALL_FK_KEY,
     CREATION_DATE,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     REQUEST_ID,
     RESOURCE_GROUP,
     RESOURCE_GROUP_DP,
     RESOURCE_GROUP_PK,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALL_FK,
     NULL, --ALL_FK_KEY,
     CREATION_DATE,
     substrb(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     substrb(NAME,1,320),
     NULL, --REQUEST_ID,
     RESOURCE_GROUP,
     RESOURCE_GROUP_DP,
     RESOURCE_GROUP_PK,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_RESGROUP_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;
   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

 Exception When others then
    raise;
    commit;
End Push_EDW_BRES_RESGROUP;

Procedure Push_EDW_BRES_RESTYPE(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_RESTYPE_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

   edw_log.put_line(' ');
   edw_log.put_line('Pushing EDW_BRES_RESTYPE');

   Insert Into EDW_BRES_RESTYPE_LSTG(
     ALL_FK,
     ALL_FK_KEY,
     CREATION_DATE,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     REQUEST_ID,
     RESOURCE_TYPE,
     RESOURCE_TYPE_DP,
     RESOURCE_TYPE_PK,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALL_FK,
     NULL, --ALL_FK_KEY,
     CREATION_DATE,
     substrb(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     substrb(NAME,1,320),
     NULL, --REQUEST_ID,
     RESOURCE_TYPE,
     RESOURCE_TYPE_DP,
     RESOURCE_TYPE_PK,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_RESTYPE_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;
   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

/***************************************************/

 Exception When others then
    raise;
    commit;
End Push_EDW_BRES_RESTYPE;

Procedure Push_EDW_BRES_RESCAT(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_RESCAT_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   Insert Into EDW_BRES_RESCAT_LSTG(
     CREATION_DATE,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     PLANT_FK,
     PLANT_FK_KEY,
     REQUEST_ID,
     RESOURCE_CATEGORY,
     RESOURCE_CATEGORY_DP,
     RESOURCE_CATEGORY_PK,
     RESOURCE_TYPE_FK,
     RESOURCE_TYPE_FK_KEY,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     CREATION_DATE,
     substrb(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     substrb(NAME,1,320),
     PLANT_FK,
     NULL, --PLANT_FK_KEY,
     NULL, --REQUEST_ID,
     NULL, --RESOURCE_CATEGORY,
     RESOURCE_CATEGORY_DP,
     RESOURCE_CATEGORY_PK,
     RESOURCE_TYPE_FK,
     NULL, --RESOURCE_TYPE_FK_KEY,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_RESCAT_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;
   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

 Exception When others then
    raise;
    commit;
End Push_EDW_BRES_RESCAT;

Procedure Push_EDW_BRES_PARENT_DEPT(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_PARENT_DEPT_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

   edw_log.put_line(' ');
   edw_log.put_line('Pushing EDW_BRES_PARENT_DEPT');

   Insert Into EDW_BRES_PARENT_DEPT_LSTG(
     CREATION_DATE,
     DEPARTMENT_CLASS_FK,
     DEPARTMENT_CLASS_FK_KEY,
     DEPARTMENT_CODE,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     PARENT_DEPARTMENT_DP,
     PARENT_DEPARTMENT_PK,
     REQUEST_ID,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     CREATION_DATE,
     DEPARTMENT_CLASS_FK, --DEPARTMENT_CLASS_FK,
     NULL, --DEPARTMENT_CLASS_FK_KEY,
     SUBSTRB(DEPARTMENT_CODE,1,20),
     SUBSTRB(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     SUBSTRB(NAME,1,320),
     DEPARTMENT_DP, --PARENT_DEPARTMENT_DP,
     DEPARTMENT_PK, --PARENT_DEPARTMENT_PK,
     NULL, --REQUEST_ID,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_DEPT_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;
   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

/***************************************************/

 Exception When others then
    raise;
    commit;
End Push_EDW_BRES_PARENT_DEPT;

Procedure Push_EDW_BRES_DEPT(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_DEPT_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

   edw_log.put_line(' ');
   edw_log.put_line('Pushing EDW_BRES_DEPT');

   Insert Into EDW_BRES_DEPT_LSTG(
     CREATION_DATE,
     DEPARTMENT_CODE,
     DEPARTMENT_DP,
     DEPARTMENT_PK,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     PARENT_DEPARTMENT_FK,
     PARENT_DEPARTMENT_FK_KEY,
     REQUEST_ID,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     CREATION_DATE,
     DEPARTMENT_CODE,
     DEPARTMENT_DP,
     DEPARTMENT_PK,
     substrb(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     substrb(NAME,1,320),
     PARENT_DEPARTMENT_FK,
     NULL, --PARENT_DEPARTMENT_FK_KEY,
     NULL, --REQUEST_ID,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_DEPT_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;

   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

 Exception When others then
    raise;
    commit;


End Push_EDW_BRES_DEPT;

Procedure Push_EDW_BRES_DEPT_CLASS(
                p_from_date  IN   Date,
                p_to_date    IN   Date) IS
 l_staging_table_name   Varchar2(30) :='EDW_BRES_DEPT_CLASS_LSTG'  ;
 L_PUSH_DATE_RANGE1         Date:=Null;
 L_PUSH_DATE_RANGE2         Date:=Null;
 l_rows_inserted            Number:=0;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

   edw_log.put_line(' ');
   edw_log.put_line('Pushing EDW_BRES_DEPT_CLASS');

   Insert Into EDW_BRES_DEPT_CLASS_LSTG(
     CREATION_DATE,
     DEPARTMENT_CLASS,
     DEPARTMENT_CLASS_DP,
     DEPARTMENT_CLASS_PK,
     DESCRIPTION,
     ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     PLANT_FK,
     PLANT_FK_KEY,
     REQUEST_ID,
     ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     CREATION_DATE,
     DEPARTMENT_CLASS,
     DEPARTMENT_CLASS_DP,
     DEPARTMENT_CLASS_PK,
     substrb(DESCRIPTION,1,240),
     NULL, --ERROR_CODE,
     INSTANCE,
     LAST_UPDATE_DATE,
     substrb(NAME,1,320),
     PLANT_FK,
     NULL, --PLANT_FK_KEY,
     NULL, --REQUEST_ID,
     NULL, --ROW_ID,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_BRES_DEPT_CLASS_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;

   l_rows_inserted := sql%rowcount;

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_BOM_RES_M_C.g_row_count:=EDW_BOM_RES_M_C.g_row_count+l_rows_inserted;
   Commit;

 Exception When others then
    raise;
    commit;

End Push_EDW_BRES_DEPT_CLASS;

End EDW_BOM_RES_M_C;

/
