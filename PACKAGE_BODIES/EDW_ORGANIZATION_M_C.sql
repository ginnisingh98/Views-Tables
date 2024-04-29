--------------------------------------------------------
--  DDL for Package Body EDW_ORGANIZATION_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ORGANIZATION_M_C" AS
/* $Header: hrieporg.pkb 120.1 2005/06/07 05:16:57 anmajumd noship $ */

g_row_count  		NUMBER:= 0;
g_exception_message     VARCHAR2(2000) := NULL;

g_number_of_levels      NUMBER := 8;  -- For Organization Hierarchies

/********************************************************************/
/* This procedure dynamically builds a sql statement to insert rows */
/* into the given org hierarchy level table from the given level    */
/* collection view                                                  */
/********************************************************************/
Procedure Do_Insert( p_tree_number  IN NUMBER,
                     p_from_level   IN NUMBER,
                     p_to_level     IN NUMBER,
                     p_from_date    IN DATE,
                     p_to_date      IN DATE)
IS

  l_sql_stmt    VARCHAR2(2000); -- Holds SQL Statement to be executed
  l_ret_code    NUMBER;         -- Keeps return code of sql execution

  l_from_view   VARCHAR2(50);  -- Name of the collection view
  l_to_table    VARCHAR2(50);  -- Name of the staging table

  l_pk_column   VARCHAR2(30);  -- Staging table pk column
  l_fk_column   VARCHAR2(30);  -- Staging table fk column
  l_pk_value    VARCHAR2(60);  -- Pk value selected from collection view
  l_fk_value    VARCHAR2(60);  -- Fk value selected from collection view

  l_push_from_level  VARCHAR2(30); -- Push from level name
  l_push_lookup      VARCHAR2(80); -- Push down lookup

  l_temp_date        DATE;         -- Keeps track of execution start time
  l_duration         NUMBER := 0;  -- Execution time
  l_rows_inserted    NUMBER := 0;  -- Number of rows inserted

BEGIN

/* Construct the table, view and level names */
/**************************************/
  l_from_view := 'EDW_ORGA_TREE' || p_tree_number || '_LVL' || p_from_level ||
                 '_LCV@APPS_TO_APPS';

  l_to_table  := 'EDW_ORGA_TREE' || p_tree_number || '_LVL' || p_to_level ||
                 '_LSTG@EDW_APPS_TO_WH';

  l_push_from_level := 'ORG_TREE' || p_tree_number || '_LVL' || p_from_level;


/* Construct the primary and foreign key names from the staging table */
/**********************************************************************/
  l_pk_column := 'ORG_TREE' || p_tree_number || '_LVL' || p_to_level || '_PK';

  /* If top level staging table then fk column is ALL */
  IF (p_to_level = g_number_of_levels) THEN
    l_fk_column := 'ALL_FK';
  ELSE
    l_fk_column := 'ORG_TREE' || to_char(p_tree_number) || '_LVL' ||
                   to_char(p_to_level+1) || '_FK';
  END IF;


/* Construct the primary and foreign key names from the collection view */
/************************************************************************/
/* If straight push, then staging table columns match collection view columns */
  IF (p_from_level = p_to_level) THEN
    l_pk_value := l_pk_column;
    l_fk_value := 'NVL(' || l_fk_column || ',''NA_EDW'')';
/* Otherwise append "-TnLm" tag for push down and get push lookup */
  ELSE
    l_pk_value := 'ORG_TREE' || p_tree_number || '_LVL' || p_from_level ||
                  '_PK || ''-T' || p_tree_number || 'L' || p_from_level || '''';
  /* If only pushing down 1 level, then point to pk of level above */
    IF (p_to_level = p_from_level - 1) THEN
      l_fk_value := 'ORG_TREE' || p_tree_number || '_LVL' ||
                    p_from_level || '_PK';
  /* Otherwise point to pk plus tag of level above */
    ELSE
      l_fk_value := l_pk_value;
    END IF;
  END IF;

/* If pushing down, fetch the push down level lookup */
/*****************************************************/
  IF (p_from_level > p_to_level) THEN
/* Get push lookup */
  l_push_lookup := EDW_COLLECTION_UTIL.get_lookup_value(
                         'EDW_LEVEL_LOOKUP', l_push_from_level);
  /* Write warning message if lookup doesn't exist */
    IF (l_push_lookup IS NULL) THEN
      edw_log.put_line('**Warning**: No Lookup Code Found in GET_LOOKUP_VALUE');
      edw_log.put_line('when Pushing Tree ' || p_tree_number || ' Level '
                       || p_from_level);
    END IF;
  END IF;


/******************************************************************************/
/* BUILD UP THE SQL STATEMENT                                                 */
/******************************************************************************/

/* Not a push down - straight insert */
/*************************************/
  IF (p_from_level = p_to_level) THEN

    l_sql_stmt := 'Insert Into ' || l_to_table || '(
      BUSINESS_GROUP,
      CREATION_DATE,
      INSTANCE,
      LAST_UPDATE_DATE,
      NAME,
      ORGANIZATION_ID,
      ' || l_pk_column || ',
      ' || l_fk_column || ',
      PRIMARY_ORG_DP,
      OPERATION_CODE,
      COLLECTION_STATUS,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5)
    select BUSINESS_GROUP,
      sysdate,
      INSTANCE,
      sysdate,
      NAME,
      ORGANIZATION_ID,
      ' || l_pk_value || ',
      ' || l_fk_value || ',
      PRIMARY_ORG_DP,
      NULL, -- OPERATION_CODE
      ''READY'',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL
     from ' || l_from_view || '
     where last_update_date between :date_from and :date_to';

/******************************************************************************/
/* Push Down from a higher level */
/*********************************/
  ELSE
    l_sql_stmt := 'Insert Into ' || l_to_table || '(
      BUSINESS_GROUP,
      CREATION_DATE,
      INSTANCE,
      LAST_UPDATE_DATE,
      NAME,
      ORGANIZATION_ID,
      ' || l_pk_column || ',
      ' || l_fk_column || ',
      PRIMARY_ORG_DP,
      OPERATION_CODE,
      COLLECTION_STATUS,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5)
    select BUSINESS_GROUP,
      sysdate,
      INSTANCE,
      sysdate,
      ''' || l_push_lookup || ''' || ''('' || NAME || '')'',
      ORGANIZATION_ID,
      ' || l_pk_value || ',
      ' || l_fk_value || ',
      ''' || l_push_lookup || ''' || ''('' || NAME || '')'',
      NULL, -- OPERATION_CODE
      ''READY'',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL
     from ' || l_from_view || '
     where last_update_date between :date_from and :date_to
     and NAME is not null';

  END IF;

  edw_log.put_line( 'Pushing Tree ' || p_tree_number || ' Level ' ||
                    p_from_level || ' to Level ' || p_to_level );

  l_temp_date := SYSDATE;
  EXECUTE IMMEDIATE l_sql_stmt USING p_from_date, p_to_date;
  l_duration := sysdate - l_temp_date;

  l_rows_inserted := sql%rowcount;
  edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
  ' rows into the ' || l_to_table || ' staging table');

  edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
  edw_log.put_line(' ');

End Do_Insert;

Procedure Push_INT_ORGANIZATION(
                Errbuf            OUT NOCOPY Varchar2
               ,Retcode           OUT NOCOPY Varchar2
               ,p_from_date       IN  Date
               ,p_to_date         IN  Date
	       ) IS

 l_staging_table_name   Varchar2(30) := 'EDW_INT_ORGANIZATION_LSTG';
 l_push_date_range1     Date := NULL;
 l_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;
 l_tmp_str              VARCHAR2 (120);

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
   edw_log.put_line('Pushing bottom-level orgs');

   l_temp_date := sysdate;

   Insert Into EDW_ORGA_ORG_LSTG@EDW_APPS_TO_WH(
     BUSINESS_GROUP,
     ORGANIZATION_DP,
     ORGANIZATION_PK,
     ROW_ID,
     DATE_FROM,
     DATE_TO,
     INSTANCE,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     NAME,
     OPERATING_UNIT_FK,
     OPERATING_UNIT_FK_KEY,
     ORG_CODE,
     ORG_INT_EXT_FLAG,
     ORG_PRIM_CST_MTHD,
     ORG_TYPE,
     LEVEL_NAME,
     PERSON_MANAGER_ID,
     PERSON_MANAGER_FK,
     PERSON_MANAGER_FK_KEY,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     REQUEST_ID,
     OPERATION_CODE,
     ERROR_CODE,
     COLLECTION_STATUS,
/* New changes by HRI */
     ORGANIZATION_ID,
     ORG_CAT1,
     ORG_CAT10,
     ORG_CAT11,
     ORG_CAT12,
     ORG_CAT13,
     ORG_CAT14,
     ORG_CAT15,
     ORG_CAT2,
     ORG_CAT3,
     ORG_CAT4,
     ORG_CAT5,
     ORG_CAT6,
     ORG_CAT7,
     ORG_CAT8,
     ORG_CAT9,
     ORG_TREE1_LVL1_FK)
   select
     BUSINESS_GROUP,
     ORGANIZATION_DP,
     ORGANIZATION_PK,
     NULL,		--ROW_ID,
     DATE_FROM,
     DATE_TO,
     INSTANCE,			--bis_edw_instance.get_code,
     sysdate,
     sysdate,			--CREATION_DATE,
     NAME,
     nvl(OPERATING_UNIT_FK, 'NA_EDW'),
     NULL,			--OPERATING_UNIT_FK_KEY
     ORG_CODE,
     ORG_INT_EXT_FLAG,
     ORG_PRIM_CST_MTHD,
     ORG_TYPE,
     LEVEL_NAME,
     PERSON_MANAGER_ID,
     PERSON_MANAGER_FK,
     PERSON_MANAGER_FK_KEY,
     NULL, --USER_ATTRIBUTE1,
     NULL, --USER_ATTRIBUTE2,
     NULL, --USER_ATTRIBUTE3,
     NULL, --USER_ATTRIBUTE4,
     NULL, --USER_ATTRIBUTE5,
     NULL,			--REQUEST_ID,
     NULL, 			--OPERATION_CODE
     NULL,			--ERROR_CODE
     'READY',
     ORGANIZATION_ID,
     ORG_CAT1,
     ORG_CAT10,
     ORG_CAT11,
     ORG_CAT12,
     ORG_CAT13,
     ORG_CAT14,
     ORG_CAT15,
     ORG_CAT2,
     ORG_CAT3,
     ORG_CAT4,
     ORG_CAT5,
     ORG_CAT6,
     ORG_CAT7,
     ORG_CAT8,
     ORG_CAT9,
     NVL(ORG_TREE1_LVL1_FK, 'NA_EDW')
   from EDW_ORGA_ORG_LCV@APPS_TO_APPS
   where last_update_date between l_push_date_range1 and l_push_date_range2
   or (last_update_date is null);

   l_rows_inserted := nvl(sql%rowcount,0);
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted ' || to_char(l_rows_inserted) ||
         ' rows into the EDW_ORGA_ORG_LSTG staging table');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

   EDW_ORGANIZATION_M_C.g_row_count := EDW_ORGANIZATION_M_C.g_row_count +
					l_rows_inserted;

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

Exception

 When others then

   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_ORGANIZATION_M_C.g_exception_message := Retcode || ':' || Errbuf;
   rollback;

   raise;

End Push_INT_ORGANIZATION;

Procedure Push_Oper_Unit(
		Errbuf           OUT NOCOPY Varchar2
               ,Retcode          OUT NOCOPY Varchar2
               ,p_from_date      IN  Date
               ,p_to_date        IN  Date
		) IS

 l_staging_table_name   Varchar2(30) := 'EDW_OPER_UNIT_LSTG';
 g_push_date_range1     Date := NULL;
 g_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;
 l_tmp_str1             VARCHAR2 (120);
 l_tmp_str2             VARCHAR2 (120);

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------

Begin
   Errbuf :=NULL;
   Retcode :=0;

   g_push_date_range1 := p_from_date;
   g_push_date_range2 := p_to_date;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing Operating Units');

   l_temp_date := sysdate;

   Insert Into EDW_ORGA_OPER_UNIT_LSTG@EDW_APPS_TO_WH(
     BUSINESS_GROUP,
     DATE_FROM,
     DATE_TO,
     INSTANCE,
     INT_EXT_FLAG,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     LEGAL_ENTITY_FK,
     LEGAL_ENTITY_FK_KEY,
     NAME,
     OPERATING_UNIT_DP,
     OPERATING_UNIT_PK,
     ROW_ID,
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     LEVEL_NAME,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     REQUEST_ID,
     OPERATION_CODE,
     ERROR_CODE,
     COLLECTION_STATUS,
/* New change by HRI */
     OPERATING_UNIT_ID)
   select
     BUSINESS_GROUP,
     DATE_FROM,
     DATE_TO,
     INSTANCE,			--bis_edw_instance.get_code,
     INT_EXT_FLAG,
     sysdate,
     sysdate,			--CREATION_DATE
     nvl(LEGAL_ENTITY_FK, 'NA_EDW'),
     NULL,			--LEGAL_ENTITY_FK_KEY,
     NAME,
     OPERATING_UNIT_DP,
     OPERATING_UNIT_PK,
     null,  ---rowid
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     LEVEL_NAME,
     NULL, --USER_ATTRIBUTE1,
     NULL, --USER_ATTRIBUTE2,
     NULL, --USER_ATTRIBUTE3,
     NULL, --USER_ATTRIBUTE4,
     NULL, --USER_ATTRIBUTE5,
     NULL,			--REQUEST_ID,
     NULL, 			--OPERATION_CODE
     NULL,			--ERROR_CODE,
     'READY',
     OPERATING_UNIT_ID
   from EDW_ORGA_OPER_UNIT_LCV@apps_to_apps
   where last_update_date between g_push_date_range1 and g_push_date_range2
   or (last_update_date is null);

   l_rows_inserted := nvl(sql%rowcount,0);
   l_duration := sysdate - l_temp_date;

   edw_log.put_line( 'Inserted ' || to_char(l_rows_inserted) ||
         ' rows into the EDW_ORGA_OPER_UNIT_LSTG staging table');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');


-- Start of change by S.Bhattal, 11-OCT-2000

   l_tmp_str1 := EDW_COLLECTION_UTIL.get_lookup_value(
			'EDW_LEVEL_LOOKUP', 'ORG_OPERATING_UNIT' );

   l_tmp_str2 := EDW_COLLECTION_UTIL.get_lookup_value(
			'EDW_LEVEL_LOOKUP', 'ORG_LEGAL_ENTITY' );

   if (l_tmp_str1 is null) or (l_tmp_str2 is null) THEN
     edw_log.put_line('***Warning*** : No Lookup Code Found in GET_LOOKUP_VALUE when Pushing Operating Unit');
   end if;

-- End of change by S.Bhattal, 11-OCT-2000

   edw_log.put_line( 'Pushing Business Groups to Operating Unit level' );

 Insert Into EDW_ORGA_OPER_UNIT_LSTG@EDW_APPS_TO_WH(
     BUSINESS_GROUP,
     DATE_FROM,
     DATE_TO,
     INSTANCE,
     INT_EXT_FLAG,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     LEGAL_ENTITY_FK,
     LEGAL_ENTITY_FK_KEY,
     NAME,
     OPERATING_UNIT_DP,
     OPERATING_UNIT_PK,
     ROW_ID,
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     LEVEL_NAME,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     REQUEST_ID,
     OPERATION_CODE,
     ERROR_CODE,
     COLLECTION_STATUS,
/* New change by HRI */
     OPERATING_UNIT_ID)
   select
     null,   -- BUSINESS_GROUP,
     DATE_FROM,
     DATE_TO,
     INSTANCE,			--bis_edw_instance.get_code,
     INT_EXT_FLAG,
     sysdate,
     sysdate,			--CREATION_DATE
     BUSINESS_GROUP_PK ||'-'||'BGRP',
     NULL,			--LEGAL_ENTITY_FK_KEY,
     l_tmp_str1 || ' (' || l_tmp_str2 || ' (' || NAME || '))',  --for: NAME
     l_tmp_str1 || ' (' || l_tmp_str2 || ' (' || NAME || '))',  --for: OPERATING_UNIT_DP
     BUSINESS_GROUP_PK ||'-'||'BGRP',
     null,   --rowid
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     'BGRP',
     NULL, --USER_ATTRIBUTE1,
     NULL, --USER_ATTRIBUTE2,
     NULL, --USER_ATTRIBUTE3,
     NULL, --USER_ATTRIBUTE4,
     NULL, --USER_ATTRIBUTE5,
     NULL,			--REQUEST_ID,
     NULL, 			--OPERATION_CODE
     NULL,			--ERROR_CODE,
     'READY',
     BUSINESS_GROUP_ID
   from EDW_ORGA_BUSINESS_GRP_LCV@apps_to_apps
   where last_update_date between g_push_date_range1 and g_push_date_range2
   or (last_update_date is null);

   l_rows_inserted := nvl(sql%rowcount,0);
   l_duration := sysdate - l_temp_date;

   edw_log.put_line( 'Inserted ' || to_char(l_rows_inserted) ||
         ' rows into the EDW_ORGA_BUSINESS_GROUP_LSTG staging table');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------


Exception

 When others then

   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_ORGANIZATION_M_C.g_exception_message := Retcode || ':' || Errbuf;
   rollback;

   raise;

End Push_Oper_Unit;

Procedure Push_Legal_Entity(
		Errbuf           OUT NOCOPY Varchar2
               ,Retcode          OUT NOCOPY Varchar2
               ,p_from_date      IN  Date
               ,p_to_date        IN  Date
		) IS

 l_staging_table_name   Varchar2(30) := 'EDW_LEGAL_ENTITY_LSTG';
 g_push_date_range1     Date := NULL;
 g_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;
 l_tmp_str              VARCHAR2 (120);

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------

Begin
   Errbuf :=NULL;
   Retcode:=0;

   g_push_date_range1 := p_from_date;
   g_push_date_range2 := p_to_date;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing Legal Entities');

   l_temp_date := sysdate;

   Insert Into EDW_ORGA_LEG_ENTITY_LSTG@EDW_APPS_TO_WH(
     BUSINESS_GROUP_FK,
     BUSINESS_GROUP_FK_KEY,
     DATE_FROM,
     DATE_TO,
     INSTANCE,
     INT_EXT_FLAG,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     LEGAL_ENTITY_DP,
     LEGAL_ENTITY_PK,
     ROW_ID,
     NAME,
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     SET_OF_BOOKS,
     LEVEL_NAME,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     REQUEST_ID,
     OPERATION_CODE,
     ERROR_CODE,
     COLLECTION_STATUS,
/* New change by HRI */
     LEGAL_ENTITY_ID)
   select
     nvl(BUSINESS_GROUP_FK, 'NA_EDW'),
     NULL,			--BUSINESS_GROUP_FK,
     DATE_FROM,
     DATE_TO,
     INSTANCE,			--bis_edw_instance.get_code,
     INT_EXT_FLAG,
     sysdate,
     sysdate,			--CREATION_DATE,
     LEGAL_ENTITY_DP,
     LEGAL_ENTITY_PK,
     NULL,			--ROW_ID,
     NAME,
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     SET_OF_BOOKS,
     LEVEL_NAME,
     NULL, --USER_ATTRIBUTE1,
     NULL, --USER_ATTRIBUTE2,
     NULL, --USER_ATTRIBUTE3,
     NULL, --USER_ATTRIBUTE4,
     NULL, --USER_ATTRIBUTE5,
     NULL,			--REQUEST_ID,
     NULL, 			--OPERATION_CODE
     NULL,			--ERROR_CODE,
     'READY',
     LEGAL_ENTITY_ID
   from EDW_ORGA_LEG_ENTITY_LCV@apps_to_apps
   where last_update_date between g_push_date_range1 and g_push_date_range2
   or (last_update_date is null);

   l_rows_inserted := nvl(sql%rowcount,0);
   l_duration := sysdate - l_temp_date;

   edw_log.put_line( 'Inserted ' || to_char(l_rows_inserted) ||
         ' rows into the EDW_ORGA_LEG_ENTITY_LSTG staging table');

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- Start of change by S.Bhattal, 11-OCT-2000

   l_tmp_str := EDW_COLLECTION_UTIL.get_lookup_value(
			'EDW_LEVEL_LOOKUP', 'ORG_LEGAL_ENTITY' );

   if(l_tmp_str is null) THEN
     edw_log.put_line('***Warning*** : No Lookup Code Found in GET_LOOKUP_VALUE when Pushing Legal Entity');
   end if;

-- End of change by S.Bhattal, 11-OCT-2000

   edw_log.put_line( 'Pushing Business Groups to Legal Entity level' );

   Insert Into EDW_ORGA_LEG_ENTITY_LSTG@EDW_APPS_TO_WH(
     BUSINESS_GROUP_FK,
     BUSINESS_GROUP_FK_KEY,
     DATE_FROM,
     DATE_TO,
     INSTANCE,
     INT_EXT_FLAG,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     LEGAL_ENTITY_DP,
     LEGAL_ENTITY_PK,
     ROW_ID,
     NAME,
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     SET_OF_BOOKS,
     LEVEL_NAME,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     REQUEST_ID,
     OPERATION_CODE,
     ERROR_CODE,
     COLLECTION_STATUS,
/* New change by HRI */
     LEGAL_ENTITY_ID)
   select
     BUSINESS_GROUP_PK,
     NULL,			--BUSINESS_GROUP_FK,
     DATE_FROM,
     DATE_TO,
     INSTANCE,			--bis_edw_instance.get_code,
     INT_EXT_FLAG,
     sysdate,
     sysdate,			--CREATION_DATE,
     l_tmp_str || ' (' || NAME || ')',  --for: BUSINESS_GROUP_DP
     BUSINESS_GROUP_PK ||'-'||'BGRP',
     NULL,			--ROW_ID,
     l_tmp_str || ' (' || NAME || ')',  --for: NAME,
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     null, ---SET_OF_BOOKS,
     'BGRP',
     NULL, --USER_ATTRIBUTE1,
     NULL, --USER_ATTRIBUTE2,
     NULL, --USER_ATTRIBUTE3,
     NULL, --USER_ATTRIBUTE4,
     NULL, --USER_ATTRIBUTE5,
     NULL,			--REQUEST_ID,
     NULL, 			--OPERATION_CODE
     NULL,			--ERROR_CODE,
     'READY',
     BUSINESS_GROUP_ID
   from EDW_ORGA_BUSINESS_GRP_LCV@apps_to_apps
   where last_update_date between g_push_date_range1 and g_push_date_range2
   or (last_update_date is null);

   l_rows_inserted := nvl(sql%rowcount,0);
   l_duration := sysdate - l_temp_date;

   edw_log.put_line( 'Inserted ' || to_char(l_rows_inserted) ||
         ' rows into the EDW_ORGA_BUSINESS_GRP_LSTG staging table');

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

Exception

 When others then

   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_ORGANIZATION_M_C.g_exception_message := Retcode || ':' || Errbuf;
   rollback;

   raise;

End Push_Legal_Entity;

Procedure Push_Business_Grp(
		Errbuf           OUT NOCOPY Varchar2
               ,Retcode          OUT NOCOPY Varchar2
               ,p_from_date      IN  Date
               ,p_to_date        IN  Date
		) IS

 l_staging_table_name   Varchar2(30) := 'EDW_BUSINESS_GRP_LSTG';
 g_push_date_range1     Date := NULL;
 g_push_date_range2     Date := NULL;
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

   g_push_date_range1 := p_from_date;
   g_push_date_range2 := p_to_date;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing Business Groups');

   l_temp_date := sysdate;

   Insert Into EDW_ORGA_BUSINESS_GRP_LSTG@EDW_APPS_TO_WH(
     ALL_FK,
     ALL_FK_KEY,
     BUSINESS_GROUP_DP,
     BUSINESS_GROUP_PK,
     ROW_ID,
     DATE_FROM,
     DATE_TO,
     INSTANCE,
     INT_EXT_FLAG,
     LAST_UPDATE_DATE,
     CREATION_DATE,
     NAME,
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     REQUEST_ID,
     OPERATION_CODE,
     ERROR_CODE,
     COLLECTION_STATUS,
/* New change by HRI */
     BUSINESS_GROUP_ID,
     COST_ALLOCATION,
     LEGISLATION)
   select
     nvl(ALL_FK, 'NA_EDW'),
     NULL,		--ALL_FK_KEY
     BUSINESS_GROUP_DP,
     BUSINESS_GROUP_PK,
     NULL,		--ROW_ID,
     DATE_FROM,
     DATE_TO,
     INSTANCE,			--bis_edw_instance.get_code,
     INT_EXT_FLAG,
     sysdate,
     sysdate,			--CREATION_DATE,
     NAME,
     ORG_CODE,
     ORG_TYPE,
     PRIMARY_CST_MTHD,
     NULL, --USER_ATTRIBUTE1,
     NULL, --USER_ATTRIBUTE2,
     NULL, --USER_ATTRIBUTE3,
     NULL, --USER_ATTRIBUTE4,
     NULL, --USER_ATTRIBUTE5,
     NULL,			--REQUEST_ID,
     NULL, 			--OPERATION_CODE
     NULL,			--ERROR_ID,
     'READY',
     BUSINESS_GROUP_ID,
     COST_ALLOCATION_FLEXFIELD,
     LEGISLATION
   from EDW_ORGA_BUSINESS_GRP_LCV@apps_to_apps
   where last_update_date between g_push_date_range1 and g_push_date_range2
   or (last_update_date is null);

   l_rows_inserted := nvl(sql%rowcount,0);
   l_duration := sysdate - l_temp_date;

   edw_log.put_line( 'Inserted ' || to_char(l_rows_inserted) ||
         ' rows into the EDW_ORGA_BUSINESS_GRP_LSTG staging table');

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

Exception

 When others then

   edw_log.put_line( 'In exception section of Push_Business_Grp' );
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_ORGANIZATION_M_C.g_exception_message := Retcode || ':' || Errbuf;
   rollback;

   raise;

End Push_Business_Grp;

/********************************************************************************/
/* New Levels inserted by HRI */
/******************************/

Procedure Push_Tree( p_from_date         IN DATE,
                     p_to_date           IN DATE,
                     p_tree              IN NUMBER )
IS
BEGIN

  FOR v_push_to_level IN 1..g_number_of_levels LOOP

    edw_log.put_line('Starting Push_EDW_ORGA_TREE' || p_tree || '_LVL' ||
                     v_push_to_level || '_LSTG');
    edw_log.put_line(' ');

    FOR v_push_from_view IN v_push_to_level..g_number_of_levels LOOP

        Do_Insert( p_tree_number  => p_tree,
                   p_from_level   => v_push_from_view,
                   p_to_level     => v_push_to_level,
                   p_from_date    => p_from_date,
                   p_to_date      => p_to_date );

    END LOOP;

  END LOOP;

END Push_Tree;

/********************************************************************************/


Procedure Push( Errbuf           OUT NOCOPY Varchar2
               ,Retcode          OUT NOCOPY Varchar2
               ,p_from_date      IN  Varchar2
               ,p_to_date        IN  Varchar2
	      ) IS

g_push_date_range1     Date:= Null;
g_push_date_range2     Date:= Null;

-- Added by S.Bhattal, AUG-2000

l_from_date            date;
l_to_date              date;

Begin

   Errbuf := NULL;
   Retcode := 0;

   If (Not EDW_COLLECTION_UTIL.setup('EDW_ORGANIZATION_M')) Then
       Return;
   End If;

-- Added by S.Bhattal, AUG-2000

  edw_log.put_line( 'About to do 1st date conversion' );
  l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  edw_log.put_line( '1st date conversion completed ok' );
  l_to_date   := to_date(p_to_date,   'YYYY/MM/DD HH24:MI:SS');
  edw_log.put_line( '2nd date conversion completed ok' );

-- End of change

   g_push_date_range1 := nvl(l_from_date,
   EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);

   g_push_date_range2 := nvl(l_to_date, EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

   edw_log.put_line( 'The collection range is from '||
        to_char(g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));

/* Call to HRI Org Hierarchy Table package */
/*******************************************/
   edw_log.put_line(' ');
   edw_log.put_line( 'Populating HRI Org Hierarchy table');
   hri_edw_dim_organization.populate_primary_org_hrchy_tab;
   edw_log.put_line( 'Finished populating HRI Org Hierarchy table');

   edw_log.put_line(' ');
   edw_log.put_line( 'About to call bottom-level orgs routine' );

   Edw_Organization_m_C.Push_INT_ORGANIZATION(
	       Errbuf,
               Retcode,
               g_push_date_range1,
               g_push_date_range2
		);

   edw_log.put_line( 'Bottom-level orgs routine completed ok' );
   edw_log.put_line( 'About to call Operating Units routine' );

   Edw_Organization_M_C.Push_Oper_Unit(
	       Errbuf,
               Retcode,
               g_push_date_range1,
               g_push_date_range2
		);

   edw_log.put_line( 'Operating Units routine completed ok' );
   edw_log.put_line( 'About to call Legal Entities routine' );

   Edw_Organization_m_C.Push_Legal_Entity(
	       Errbuf,
               Retcode,
               g_push_date_range1,
               g_push_date_range2
		);

   edw_log.put_line( 'Legal Entities routine completed ok' );
   edw_log.put_line( 'About to call Business Groups routine' );

   Edw_Organization_M_C.Push_Business_Grp(
	       Errbuf,
               Retcode,
               g_push_date_range1,
               g_push_date_range2
		);

   edw_log.put_line( 'Business Groups routine completed ok' );


/*************************************************/
/* New changes implemented by HRI                */
/* 8 Levels inserted                             */
/*************************************************/

   edw_log.put_line( 'About to call Org Tree 1 routine' );

   Edw_Organization_M_C.Push_Tree(
               p_from_date         =>  g_push_date_range1,
               p_to_date           =>  g_push_date_range2,
               p_tree              =>  1 );

   edw_log.put_line( 'Org Tree 1 routine completed ok' );

/*************************************************/

   EDW_COLLECTION_UTIL.wrapup(TRUE, EDW_ORGANIZATION_M_C.g_row_count, null, g_push_date_range1, g_push_date_range2);

Exception

 When others then

   Errbuf := sqlerrm;
   Retcode := sqlcode;

   EDW_ORGANIZATION_M_C.g_exception_message := EDW_ORGANIZATION_M_C.g_exception_message ||'<>'||Retcode || ':' || Errbuf;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_ORGANIZATION_M_C.g_exception_message, g_push_date_range1, g_push_date_range2);

   raise;

End Push;

End EDW_ORGANIZATION_M_C;

/
