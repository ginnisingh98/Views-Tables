--------------------------------------------------------
--  DDL for Package Body FII_PROJECT_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PROJECT_M_C" AS
/* $Header: FIICMPJB.pls 120.2 2005/06/07 14:59:07 pschandr ship $ */

  g_debug_flag  VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

  G_PUSH_DATE_RANGE1         Date := Null;
  G_PUSH_DATE_RANGE2         Date := Null;
  g_row_count                Number := 0;
  g_exception_msg            varchar2(2000) := Null;


Procedure Push(Errbuf       in out nocopy Varchar2,
               Retcode      in out nocopy Varchar2,
               p_from_date  IN   Varchar2,
               p_to_date    IN   Varchar2) IS

  l_dimension_name           Varchar2(30) :='EDW_PROJECT_M'  ;
  l_temp_date                Date:=Null;
  l_rows_inserted            Number:=0;
  l_duration                 Number:=0;
  l_exception_msg            Varchar2(2000):=Null;
  l_from_date                Date:=Null;
  l_to_date                  Date:=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------

Begin

  Errbuf :=NULL;
  Retcode:=0;

  l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    raise_application_error(-20000,'Error in SETUP: ' || errbuf);
  END IF;

  FII_PROJECT_M_C.g_push_date_range1 := nvl(l_from_date,EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  FII_PROJECT_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

  if g_debug_flag = 'Y' then
    edw_log.put_line( 'The collection range is from '||
      to_char(FII_PROJECT_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
      to_char(FII_PROJECT_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
    edw_log.put_line(' ');
  end if;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  if g_debug_flag = 'Y' then
    edw_log.put_line(' ');
    edw_log.put_line('Pushing data');
  end if;

  l_temp_date := sysdate;

  Push_EDW_PROJ_TASK_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_TOP_TASK_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_PROJECT_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_PRJ_TYP_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CLS1_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CLS2_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CLS3_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CLS4_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CLS5_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CLS6_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CLS7_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CATEG1_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CATEG2_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CATEG3_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CATEG4_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CATEG5_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CATEG6_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);
  Push_EDW_PROJ_CATEG7_LSTG(FII_PROJECT_M_C.g_push_date_range1, FII_PROJECT_M_C.g_push_date_range2);

  l_duration := sysdate - l_temp_date;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
    edw_log.put_line(' ');
  end if;

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

  EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, g_push_date_range1, g_push_date_range2);

  commit;

Exception

  When others then

    Errbuf:=sqlerrm;
    Retcode:=sqlcode;
    l_exception_msg  := Retcode || ':' || Errbuf;
    FII_PROJECT_M_C.g_exception_msg  := l_exception_msg;

    rollback;

    EDW_COLLECTION_UTIL.wrapup(FALSE, 0, FII_PROJECT_M_C.g_exception_msg, g_push_date_range1, g_push_date_range2);

    commit;

End;


Procedure Push_EDW_PROJ_TASK_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1            DATE;
  l_date2            DATE;
  l_rows_inserted    NUMBER := 0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_TASK_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_TASK_LSTG
  (
    TASK_PK,
    TOP_TASK_FK,
    NAME,
    TASK,
    TASK_NUMBER,
    TASK_START_DATE,
    TASK_END_DATE,
    LABOR_COST_MULT,
    SERVICE_TYPE_CODE,
    DENORM_TASK_ORG_FK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    INSTANCE,
    DELETION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    EDW_RECORD_TYPE
  )
  select
    TASK_PK,
    NVL(TOP_TASK_FK, 'NA_EDW'),
    NAME,
    TASK,
    TASK_NUMBER,
    TASK_START_DATE,
    TASK_END_DATE,
    LABOR_COST_MULT,
    SERVICE_TYPE_CODE,
    NVL(DENORM_TASK_ORG_FK,'NA_EDW'),
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    INSTANCE,
    to_date(NULL),
    NULL,
    'READY',
    SYSDATE,
    SYSDATE,
    'ORACLE'
  from
    FII_PROJ_TASK_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  g_row_count     := g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_TASK_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_TASK_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_TOP_TASK_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1             DATE;
  l_date2             DATE;
  l_rows_inserted     NUMBER := 0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_TOP_TASK_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_TOP_TASK_LSTG
  (
    TOP_TASK_PK,
    PROJECT_FK,
    NAME,
    TOP_TASK,
    TASK_NUMBER,
    TASK_START_DATE,
    TASK_END_DATE,
    LABOR_COST_MULT,
    SERVICE_TYPE_CODE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    INSTANCE,
    DELETION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    TOP_TASK_PK,
    NVL(PROJECT_FK, 'NA_EDW'),
    NAME,
    TOP_TASK,
    TASK_NUMBER,
    TASK_START_DATE,
    TASK_END_DATE,
    LABOR_COST_MULT,
    SERVICE_TYPE_CODE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    INSTANCE,
    to_date(NULL),
    NULL,
    'READY'
  from
    FII_PROJ_TOP_TASK_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --g_row_count     := g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_TOP_TASK_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_TOP_TASK_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_PROJECT_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1            DATE;
  l_date2            DATE;
  l_rows_inserted    NUMBER := 0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_PROJECT_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_PROJECT_LSTG
  (
    PROJECT_PK,
    PRJ_TYP_FK,
    PROJ_CLS1_FK,
    PROJ_CLS2_FK,
    PROJ_CLS3_FK,
    PROJ_CLS4_FK,
    PROJ_CLS5_FK,
    PROJ_CLS6_FK,
    PROJ_CLS7_FK,
    NAME,
    PROJECT,
    PROJECT_NUMBER,
    PROJECT_MANAGER,
    DISTRIBUTION_RULE,
    PROJECT_STATUS_CODE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    INSTANCE,
    DELETION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    PROJECT_PK,
    NVL(PRJ_TYP_FK, 'NA_EDW'),
    NVL(PROJ_CLS1_FK, 'NA_EDW'),
    NVL(PROJ_CLS2_FK, 'NA_EDW'),
    NVL(PROJ_CLS3_FK, 'NA_EDW'),
    NVL(PROJ_CLS4_FK, 'NA_EDW'),
    NVL(PROJ_CLS5_FK, 'NA_EDW'),
    NVL(PROJ_CLS6_FK, 'NA_EDW'),
    NVL(PROJ_CLS7_FK, 'NA_EDW'),
    NAME,
    PROJECT,
    PROJECT_NUMBER,
    PROJECT_MANAGER,
    DISTRIBUTION_RULE,
    PROJECT_STATUS_CODE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    INSTANCE,
    to_date(NULL),
    NULL,
    'READY'
  from
    FII_PROJ_PROJECT_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_PROJECT_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_PROJECT_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_PRJ_TYP_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1                    DATE;
  l_date2                    DATE;
  l_rows_inserted            NUMBER :=0;
  l_seiban_project_type      VARCHAR2(240);
  l_instance                 VARCHAR2(30);

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_PRJ_TYP_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_PRJ_TYP_LSTG
  (
    PRJ_TYP_PK,
    ALL_FK,
    NAME,
    PROJECT_TYPE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    INSTANCE,
    DELETION_DATE,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    PRJ_TYP_PK,
    NVL(ALL_FK, 'NA_EDW'),
    NAME,
    PROJECT_TYPE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    INSTANCE,
    to_date(NULL),
    NULL,
    'READY'
  from
    FII_PROJ_PRJ_TYP_LCV
  where
    last_update_date between l_date1 and l_date2;

    l_rows_inserted := sql%rowcount;

    -- Create record for the Seiban Project Type.
    -- Seiban Project Type was created to group projects
    -- defined in Oracle Project Manufacturing.
    --
    -- All Projects pushed from Oracle Project Manufacturing
    -- (table PJM_SEIBAN_NUMBERS) will be assigned  project type "Seiban".
    --
    -- Note that the NAME and PROJECT_TYPE columns use
    -- FII_PA_SEIBAN_PROJECT_TYPE message as a data source. This was
    -- done to enable translation of the word "Seiban" into different
    -- languages.

    l_seiban_project_type := fnd_message.get_string( 'FII', 'FII_PA_SEIBAN_PROJECT_TYPE' );

    if nvl( l_seiban_project_type, 'FII_PA_SEIBAN_PROJECT_TYPE' ) <> 'FII_PA_SEIBAN_PROJECT_TYPE' then
    -- we have chacked that fnd_message returned a meaningful result;
    -- insert record into the staging table.

      l_instance := edw_instance.get_code;

      Insert Into EDW_PROJ_PRJ_TYP_LSTG
      (
        PRJ_TYP_PK,
        ALL_FK,
        NAME,
        PROJECT_TYPE,
        USER_ATTRIBUTE1,
        USER_ATTRIBUTE2,
        USER_ATTRIBUTE3,
        USER_ATTRIBUTE4,
        USER_ATTRIBUTE5,
        INSTANCE,
        DELETION_DATE,
        OPERATION_CODE,
        COLLECTION_STATUS
      )
      values
      (
        'FII_PJM_SEIBAN_PROJECT_TYPE-' || l_instance,
        'ALL',
        l_seiban_project_type || ', ' || l_instance,
        l_seiban_project_type,
        null,
        null,
        null,
        null,
        null,
        l_instance,
        to_date( null ),
        null,
        'READY'
      );

    l_rows_inserted := l_rows_inserted + 1;

  end if;

  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_PRJ_TYP_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_PRJ_TYP_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CLS1_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1                DATE;
  l_date2                DATE;
  l_rows_inserted        NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CLS1_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CLS1_LSTG
  (
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CLASS1,
    PROJ_CATEG1_FK,
    PROJ_CLS1_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CLASS1,
    NVL(PROJ_CATEG1_FK, 'NA_EDW'),
    PROJ_CLS1_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CLS1_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CLS1_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CLS1_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CLS2_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1              DATE;
  l_date2              DATE;
  l_rows_inserted      NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CLS2_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CLS2_LSTG
  (
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CLASS2,
    PROJ_CATEG2_FK,
    PROJ_CLS2_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CLASS2,
    NVL(PROJ_CATEG2_FK, 'NA_EDW'),
    PROJ_CLS2_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CLS2_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CLS2_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CLS2_LSTG');
  end if;

 Exception

   When others then
     raise;
     commit;

END;


Procedure Push_EDW_PROJ_CLS3_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1           DATE;
  l_date2           DATE;
  l_rows_inserted   NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CLS3_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CLS3_LSTG
  (
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CLASS3,
    PROJ_CATEG3_FK,
    PROJ_CLS3_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CLASS3,
    NVL(PROJ_CATEG3_FK, 'NA_EDW'),
    PROJ_CLS3_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CLS3_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CLS3_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CLS3_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CLS4_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1              DATE;
  l_date2              DATE;
  l_rows_inserted      NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CLS4_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CLS4_LSTG
  (
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CLASS4,
    PROJ_CATEG4_FK,
    PROJ_CLS4_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CLASS4,
    NVL(PROJ_CATEG4_FK, 'NA_EDW'),
    PROJ_CLS4_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CLS4_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CLS4_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CLS4_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CLS5_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1                  DATE;
  l_date2                  DATE;
  l_rows_inserted          NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CLS5_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CLS5_LSTG
  (
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CLASS5,
    PROJ_CATEG5_FK,
    PROJ_CLS5_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CLASS5,
    NVL(PROJ_CATEG5_FK, 'NA_EDW'),
    PROJ_CLS5_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CLS5_LCV
   where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CLS5_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CLS5_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CLS6_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1            DATE;
  l_date2            DATE;
  l_rows_inserted    NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CLS6_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CLS6_LSTG
  (
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CLASS6,
    PROJ_CATEG6_FK,
    PROJ_CLS6_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CLASS6,
    NVL(PROJ_CATEG6_FK, 'NA_EDW'),
    PROJ_CLS6_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CLS6_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
 --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CLS6_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CLS6_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CLS7_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1             DATE;
  l_date2             DATE;
  l_rows_inserted     NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CLS7_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CLS7_LSTG
  (
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CLASS7,
    PROJ_CATEG7_FK,
    PROJ_CLS7_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CLASS7,
    NVL(PROJ_CATEG7_FK, 'NA_EDW'),
    PROJ_CLS7_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
  from
    FII_PROJ_CLS7_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CLS7_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CLS7_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CATEG1_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1              DATE;
  l_date2              DATE;
  l_rows_inserted      NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CATEG1_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CATEG1_LSTG
  (
    ALL_FK,
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CATEGORY1,
    PROJ_CATEG1_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    NVL(ALL_FK, 'NA_EDW'),
    to_date(NULL), -- DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CATEGORY1,
    PROJ_CATEG1_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CATEG1_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CATEG1_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CATEG1_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CATEG2_LSTG(p_from_date IN date, p_to_date IN DATE) IS

    l_date1             DATE;
    l_date2             DATE;
    l_rows_inserted     NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CATEG2_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CATEG2_LSTG
  (
    ALL_FK,
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CATEGORY2,
    PROJ_CATEG2_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    NVL(ALL_FK, 'NA_EDW'),
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CATEGORY2,
    PROJ_CATEG2_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CATEG2_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CATEG2_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CATEG2_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;

Procedure Push_EDW_PROJ_CATEG3_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1              DATE;
  l_date2              DATE;
  l_rows_inserted      NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CATEG3_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CATEG3_LSTG
  (
    ALL_FK,
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CATEGORY3,
    PROJ_CATEG3_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    NVL(ALL_FK, 'NA_EDW'),
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CATEGORY3,
    PROJ_CATEG3_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CATEG3_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CATEG3_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CATEG3_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CATEG4_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1             DATE;
  l_date2             DATE;
  l_rows_inserted     NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CATEG4_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CATEG4_LSTG
  (
    ALL_FK,
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CATEGORY4,
    PROJ_CATEG4_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    NVL(ALL_FK, 'NA_EDW'),
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CATEGORY4,
    PROJ_CATEG4_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CATEG4_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CATEG4_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CATEG4_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CATEG5_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1              DATE;
  l_date2              DATE;
  l_rows_inserted      NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CATEG5_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CATEG5_LSTG
  (
    ALL_FK,
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CATEGORY5,
    PROJ_CATEG5_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    NVL(ALL_FK, 'NA_EDW'),
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CATEGORY5,
    PROJ_CATEG5_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CATEG5_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CATEG5_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CATEG5_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CATEG6_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1               DATE;
  l_date2               DATE;
  l_rows_inserted       NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CATEG6_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CATEG6_LSTG
  (
    ALL_FK,
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CATEGORY6,
    PROJ_CATEG6_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    NVL(ALL_FK, 'NA_EDW'),
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CATEGORY6,
    PROJ_CATEG6_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CATEG6_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CATEG6_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CATEG6_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;


Procedure Push_EDW_PROJ_CATEG7_LSTG(p_from_date IN date, p_to_date IN DATE) IS

  l_date1                DATE;
  l_date2                DATE;
  l_rows_inserted        NUMBER :=0;

BEGIN

  if g_debug_flag = 'Y' then
    edw_log.put_line('Starting Push_EDW_PROJ_CATEG7_LSTG');
  end if;

  l_date1 := p_from_date;
  l_date2 := p_to_date;

  Insert Into EDW_PROJ_CATEG7_LSTG
  (
    ALL_FK,
    DELETION_DATE,
    INSTANCE,
    NAME,
    PROJECT_CATEGORY7,
    PROJ_CATEG7_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS
  )
  select
    NVL(ALL_FK, 'NA_EDW'),
    to_date(NULL),
    INSTANCE,
    NAME,
    PROJECT_CATEGORY7,
    PROJ_CATEG7_PK,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL,
    'READY'
  from
    FII_PROJ_CATEG7_LCV
  where
    last_update_date between l_date1 and l_date2;

  l_rows_inserted := sql%rowcount;
  --FII_PROJECT_M_C.g_row_count := FII_PROJECT_M_C.g_row_count + l_rows_inserted ;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Commiting records for EDW_PROJ_CATEG7_LSTG');
  end if;

  commit;

  if g_debug_flag = 'Y' then
    edw_log.put_line('Completed Push_EDW_PROJ_CATEG7_LSTG');
  end if;

Exception

  When others then
    raise;
    commit;

END;

End FII_PROJECT_M_C;

/
