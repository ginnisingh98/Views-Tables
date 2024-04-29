--------------------------------------------------------
--  DDL for Package Body PJI_PJ_PROJ_CLASS_EXTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PJ_PROJ_CLASS_EXTR" AS
  /* $Header: PJISF10B.pls 120.3.12010000.3 2009/07/16 08:46:45 dbudhwar ship $ */

  -- variables ------------------------------------

  g_worker_id                  NUMBER;
  g_process                    VARCHAR2(30) := Pji_Rm_Sum_Main.g_process;
  l_last_update_date           DATE         := SYSDATE;
  l_last_updated_by            NUMBER       := Fnd_Global.USER_ID;
  l_creation_date              DATE         := l_last_update_date;
  l_created_by                 NUMBER       := l_last_updated_by;
  l_last_update_login          NUMBER       := Fnd_Global.LOGIN_ID;
  l_last_run_lang	           fnd_lookup_values.language%TYPE;
  l_current_run_lang           fnd_lookup_values.language%TYPE;
  -- private code ---------------------------------

Procedure extr_class_codes_pvt IS
BEGIN

  -- This is a private procedure.
  --
  -- Procedure updates project classification dimension tables
  -- PJI_CLASS_CODES and PJI_CLASS_CATEGORIES. Data extraction is
  -- always incremental.
  --
  -- Procedure runs unconditionally, i.e. without a call to
  -- PJI_PROCESS_UTIL.NEED_TO_RUN_STEP. First of all, data extraction
  -- is incremental so that an extra run of this code does not cause
  -- any problems. Second, this procedure can be invoked from project
  -- class mapping extraction code so that we want this code to
  -- run unconditionally.
  --
  -- This procedure may be executed from multiple parallel workers that
  -- have detected dangling classification records. In order to serialize
  -- access to classification dimension tables we use LOCK TABLE statement
  -- below.

  Pji_Utils.write2log('Entering PJI_PJ_PROJ_CLASS_EXTR.EXTR_CLASS_CODES_PVT',TRUE,2);

  LOCK TABLE pji_class_categories IN EXCLUSIVE MODE;

  Pji_Utils.write2log('Locked table PJI_CLASS_CATEGORIES in exclusive mode',TRUE,2);

  select USERENV('LANG') into l_current_run_lang from dual ;
  l_last_run_lang := PJI_UTILS.GET_PARAMETER('LAST_REQUEST_LANG');
  if(nvl(l_last_run_lang,'-99') <> nvl(l_current_run_lang,'-99'))  then
      delete from pji_class_categories;
      PJI_UTILS.SET_PARAMETER('LAST_REQUEST_LANG',l_current_run_lang); -- Bug 4736331 : set the value of LAST_REQUEST_LANG in pji_system_parameters.
  end if;
  -- Extract class categories

  -- We use column record_type is used in the following way:
  --
  --   "C" means that this record comes from PA_CLASS_CATEGORIES
  --   "T" means this is one of the three project type
  --       categories: contract, capital or indirect.
  --   "A" means that this is the fourth project type
  --       category - category "All" - that includes all
  --       project types.
  --
  -- We use value "A" to provide a workaround for a many-to-many
  -- relationship between project types in pji_class_codes and
  -- project type categories in pji_class_categories. For example, a
  -- contract project type belongs to both "Contract Project Types"
  -- class category and "All Project Types". pji_class_codes will
  -- store only one relationship with "Contract Project Types". For
  -- reporting purposes the list of project types for classification
  -- "All Project Types" will be derived by PJI code that parses
  -- PMV parameters based on record_type column.

  insert into PJI_CLASS_CATEGORIES
  (
    CLASS_CATEGORY,
    NAME,
    RECORD_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  )
  select
    new.CLASS_CATEGORY,
    new.NAME,
    new.RECORD_TYPE,
    l_last_update_date,
    l_last_updated_by,
    l_creation_date,
    l_created_by,
    l_last_update_login
  from
    (
    select
      CLASS_CATEGORY                                     CLASS_CATEGORY,
      CLASS_CATEGORY                                     NAME,
      'C'                                                RECORD_TYPE
    from
      PA_CLASS_CATEGORIES
    where
      INCLUDE_IN_PJI_FLAG = 'Y'
    union all
    select
      LOOKUP_CODE                                        CLASS_CATEGORY,
      MEANING                                            NAME,
      decode(LOOKUP_CODE, '$PROJECT_TYPE$ALL', 'A', 'T') RECORD_TYPE
    from
      PJI_LOOKUPS
    where
      LOOKUP_TYPE = 'PJI_PROJ_TYPE_CATEGORIES'
    ) new,
    PJI_CLASS_CATEGORIES old
  where
    new.CLASS_CATEGORY = old.CLASS_CATEGORY (+) and
    old.CLASS_CATEGORY is null;

  Pji_Utils.write2log('Inserted ' || SQL%ROWCOUNT || ' record(s) ' ||
                           'into PJI_CLASS_CATEGORIES',TRUE,2);

  -- Extract class codes

  INSERT INTO pji_class_codes
  (
    class_id
  , class_code
  , class_category
  , record_type
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , last_update_login
  )
  SELECT
    pji_class_codes_s.NEXTVAL
  , class_code
  , class_category
  , record_type
  , l_last_update_date
  , l_last_updated_by
  , l_creation_date
  , l_created_by
  , l_last_update_login
  FROM
  (
        (
        SELECT
                class_code           class_code
                , class_category     class_category
                , 'C'                record_type
        FROM
                pa_class_codes
        WHERE
                class_category IN
                (
                  SELECT class_category
                  FROM   pji_class_categories
                  WHERE  record_type = 'C'
                )
        UNION ALL
        SELECT
                project_type         class_code
                , DECODE(project_type_class_code
                         , 'CAPITAL',  '$PROJECT_TYPE$CAPITAL'
                         , 'CONTRACT', '$PROJECT_TYPE$CONTRACT'
                         , 'INDIRECT', '$PROJECT_TYPE$INDIRECT'
                        )            class_category
                , 'T'                record_type
        FROM
                pa_project_types_all    pt
        WHERE   project_type_class_code IS NOT NULL
        )
        MINUS
        SELECT
                class_code           class_code
                , class_category     class_category
                , record_type        record_type
        FROM
                pji_class_codes
  )
;

  Pji_Utils.write2log('Inserted ' || SQL%ROWCOUNT || ' record(s) ' ||
                           'into PJI_CLASS_CODES',TRUE,2);

  -- Note that we do not commit. This procedure can
  -- be called from other program units so that we do
  -- not want to commit in the middle of somebody else's
  -- transaction.

  Pji_Utils.write2log('Completed PJI_PJ_PROJ_CLASS_EXTR.EXTR_CLASS_CODES_PVT',TRUE,2);

END;


  -- public code ---------------------------------

-- ------------------------------------------------
-- procedure EXTR_CLASS_CODES
-- ------------------------------------------------

Procedure extr_class_codes IS
BEGIN

  extr_class_codes_pvt;

  commit;

END extr_class_codes;


-- ------------------------------------------------
-- procedure EXTR_PROJECT_CLASSES
-- ------------------------------------------------

Procedure extr_project_classes( p_worker_id NUMBER ) IS

  l_dangling_rowcount    NUMBER;
  l_process              VARCHAR2(30);
  l_schema               VARCHAR2(30);
  l_extraction_type      VARCHAR2(30);

BEGIN

  g_worker_id := p_worker_id;

  l_process   := g_process || TO_CHAR(g_worker_id);

  IF (NOT Pji_Process_Util.NEED_TO_RUN_STEP(l_process,
            'PJI_PJ_PROJ_CLASS_EXTR.EXTR_PROJECT_CLASSES(p_worker_id);')) THEN
    RETURN;
  END IF;

  l_extraction_type := Pji_Process_Util.Get_Process_Parameter
                       (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

  -- Project class map extraction does not support partial refresh.
  -- If extraction mode is set to partial refresh
  -- we use the same logic as for incremental update.
  --
  -- If extraction type is full then we use data only from
  -- PA_PROJECT_CLASSES and delete all log table records.
  -- If extraction type is incremental (or partial) then we extract
  -- records from PA_PROJECT_CLASSES that have corresponding log
  -- records plus log records themselves with reverse sign.

  Pji_Utils.write2log('Entering PJI_PJ_PROJ_CLASS_EXTR.EXTR_PROJECT_CLASSES',TRUE,2);

  /*
  ** Extract all the change records from event log
  ** to pji_pj_extr_prjcls to create a snapshot of
  ** data which needed to be deleted once the extract
  ** is done.
  */

  if (l_extraction_type <> 'FULL') then

  INSERT INTO pji_pj_extr_prjcls
  (
    ROW_ID,
    WORKER_ID,
    PROJECT_ID,
    CLASS_CODE,
    CLASS_CATEGORY,
    CODE_PERCENTAGE,
    EVENT_ID,
    RECORD_TYPE,
    PROJECT_CLASS_ID,
    EXTRACTION_TYPE,
    LOG_OPERATION_TYPE
  )
  SELECT
  evt.ROWID                              row_id
  , g_worker_id                          worker_id
  , TO_NUMBER(evt.event_object)          project_id
  , evt.attribute1                       class_code
  , evt.attribute2                       class_category
  , TO_NUMBER(NVL(evt.attribute3,'100')) code_percentage
  , evt.event_id                         event_id
  , 'E'                                  record_type
  , NULL                                 class_id
  , bat.extraction_type                  extraction_type
  , evt.operation_type                   log_operation_type
  FROM
  pji_pji_proj_batch_map bat
  , pa_pji_proj_events_log evt
  WHERE 1=1
  AND evt.event_type = 'Classifications'
  AND evt.event_object = to_char(bat.project_id) /* Added for bug 7517578 */
  AND bat.worker_id = p_worker_id;

  end if;

/* Bug 7517578 replaced join with pji_pj_extr_prjcls by exists clause. */

  INSERT INTO pji_pj_extr_prjcls
  (
    ROW_ID
  , WORKER_ID
  , PROJECT_ID
  , CLASS_CODE
  , CLASS_CATEGORY
  , CODE_PERCENTAGE
  , EVENT_ID
  , RECORD_TYPE
  , PROJECT_CLASS_ID
  , EXTRACTION_TYPE
  , LOG_OPERATION_TYPE
  )
  /*
  ** Extract all the latest mapping information from
  ** pa_project_classes for full and partial refresh mode.
  */
  SELECT /*+ full(log)  use_hash(prj)
             full(cls)  use_hash(bat)
             full(bat)  use_hash(cls)
         */ -- bug 3092751: changes in hints
  NULL                              row_id
  , g_worker_id                     worker_id
  , prj.project_id                  project_id
  , prj.class_code                  class_code
  , prj.class_category              class_category
  , NVL(prj.code_percentage,100)    code_percentage
  , NULL                            event_id
  , 'C'                             record_type
  , cls.class_id                    class_id
  , bat.extraction_type             extraction_type
  , NULL                            log_operation_type
  FROM
  pa_project_classes       prj
  , pji_pji_proj_batch_map bat
  , pji_class_codes        cls
  WHERE 1=1
  AND bat.extraction_type <> 'I'
  AND bat.project_id = prj.project_id
  AND bat.worker_id = p_worker_id
  AND cls.class_category (+) = prj.class_category
  AND cls.class_code(+) = prj.class_code
  UNION ALL
  /*
  ** Extract the latest mapping information from
  ** pa_project_classes for new changes in an
  ** incremental run.
  */
  SELECT
  NULL                              row_id
  , g_worker_id                     worker_id
  , prj.project_id                  project_id
  , prj.class_code                  class_code
  , prj.class_category              class_category
  , NVL(prj.code_percentage,100)    code_percentage
  , NULL                            event_id
  , 'C'                             record_type
  , cls.class_id                    class_id
  , bat.extraction_type             extraction_type
  , NULL                            log_operation_type
  FROM
   pji_pji_proj_batch_map bat
  , pa_project_classes    prj
  , pji_class_codes       cls
  WHERE 1=1
  AND l_extraction_type = 'INCREMENTAL'
  AND bat.extraction_type = 'I'
  AND bat.project_id = prj.project_id
  AND bat.worker_id = p_worker_id
  AND cls.class_category (+) = prj.class_category
  AND cls.class_code(+) = prj.class_code
  AND exists
  (  select 1
     FROM pji_pj_extr_prjcls ext
     WHERE ext.record_type = 'E'
  AND ext.project_id = bat.project_id
  AND ext.class_category = prj.class_category
  AND ext.class_code = prj.class_code)
  UNION ALL
  /*
  ** Generate the reversals entries for the changed
  ** records.
  */
  SELECT
  NULL                              row_id
  , g_worker_id                     worker_id
  , cls.project_id                  project_id
  , cls.class_code                  class_code
  , cls.class_category              class_category
  , -NVL(cls.code_percentage,100)   code_percentage
  , NULL                            event_id
  , 'C'                             record_type
  , cls.project_class_id            class_id
  , bat.extraction_type             extraction_type
  , NULL                            log_operation_type
  FROM
  pji_project_classes cls
  , pji_pji_proj_batch_map bat
  WHERE 1=1
  AND l_extraction_type <> 'FULL'
  AND bat.project_id = cls.project_id
  AND bat.worker_id = p_worker_id
  AND Exists
  (  SELECT 1
     FROM pji_pj_extr_prjcls ext
     WHERE ext.record_type = 'E'
  AND ext.project_id = bat.project_id
  AND ext.class_category = cls.class_category
  AND ext.class_code = cls.class_code )
  UNION ALL
  SELECT /*+ full(pt)   use_hash(pt)
             full(prj)  use_hash(prj)
             full(bat)  use_hash(bat)
             full(cls)  use_hash(cls)
         */ -- bug 3092751: changes in hints
    -- Extract data for project types
    NULL                           row_id
  , g_worker_id                    worker_id
  , prj.project_id                 project_id
  , prj.project_type               class_code
  , DECODE(
             pt.project_type_class_code,
             'CAPITAL',  '$PROJECT_TYPE$CAPITAL',
             'CONTRACT', '$PROJECT_TYPE$CONTRACT',
             'INDIRECT', '$PROJECT_TYPE$INDIRECT'
          )                        class_category
  , 100                            code_percentage
  , NULL                           event_id
  , 'T'                            record_type
  , cls.class_id                   project_class_id
  , bat.extraction_type            extraction_type
  , NULL                           log_operation_type
  FROM
    pa_project_types_all           pt,
    pa_projects_all                prj,
    pji_pji_proj_batch_map         bat,
    pji_class_codes                cls
  WHERE
        prj.project_id = bat.project_id
    AND pt.project_type_class_code IS NOT NULL -- bug 3082170
    AND prj.project_type = pt.project_type
    AND NVL(prj.org_id,-99) = NVL(pt.org_id, -99)
    AND bat.worker_id = p_worker_id
    AND bat.extraction_type <> 'I'
    AND cls.class_code (+) = pt.project_type
    AND cls.class_category (+) =
          DECODE(
             pt.project_type_class_code,
             'CAPITAL',  '$PROJECT_TYPE$CAPITAL',
             'CONTRACT', '$PROJECT_TYPE$CONTRACT',
             'INDIRECT', '$PROJECT_TYPE$INDIRECT'
          )
  UNION ALL
  SELECT /*+ full(cls)   use_hash(cls)
               full(bat)   use_hash(bat)
               full(ext)   use_hash(ext)
           */ -- bug 3092751: changes in hints
      -- Put reversals for partial refresh
  NULL                             row_id
  , g_worker_id                    worker_id
  , cls.project_id                 project_id
  , cls.class_code                 class_code
  , cls.class_category             class_category
  , -code_percentage               code_percentage
  , NULL                           event_id
  , cls.record_type                record_type
  , cls.project_class_id           project_class_id
  , bat.extraction_type            extraction_type
  , NULL                           log_operation_type
  FROM
    pji_project_classes       cls
  , pji_pji_proj_batch_map    bat
  WHERE
      l_extraction_type = 'PARTIAL'
  AND cls.project_id = bat.project_id
  AND bat.worker_id = p_worker_id
  AND  not exists
  (
     SELECT 1
     FROM pji_pj_extr_prjcls ext WHERE ext.record_type = 'E'
  AND ext.project_id  = bat.project_id
  AND ext.class_category  = cls.class_category
  AND ext.class_code  = cls.class_code
   )
  AND bat.extraction_type = 'P';

  Pji_Utils.write2log('Inserted ' || SQL%ROWCOUNT || ' record(s) into PJI_PJ_EXTR_PRJCLS',TRUE,2);

  -- Delete the temporary entries.

  DELETE pji_pj_extr_prjcls
  WHERE  worker_id = g_worker_id
  AND  record_type = 'E';

  Pji_Utils.write2log('Deleted ' || SQL%ROWCOUNT || ' temporary record(s) from PJI_PJ_EXTR_PRJCLS',TRUE,2);

  -- Delete records for class categories that are not
  -- included into PJI summaries

  DELETE FROM PJI_PJ_EXTR_PRJCLS
  WHERE worker_id = g_worker_id
    AND class_category IN (
          SELECT class_category
          FROM pa_class_categories
          WHERE NVL(include_in_pji_flag,'N') = 'N'
    );

  Pji_Utils.write2log('Deleted ' || SQL%ROWCOUNT ||
     ' dangling record(s) from PJI_PJ_EXTR_PRJCLS - first delete',TRUE,2);

  DELETE pji_pj_extr_prjcls extr
  WHERE  worker_id = g_worker_id
	AND  record_type = 'C'
    AND  NOT EXISTS (
           SELECT 1 FROM pa_class_codes cls
           WHERE extr.class_code = cls.class_code
             AND extr.class_category = cls.class_category
          );

  Pji_Utils.write2log('Deleted ' || SQL%ROWCOUNT ||
     ' dangling record(s) from PJI_PJ_EXTR_PRJCLS - second delete',TRUE,2);


  DELETE pji_pj_extr_prjcls extr
  WHERE  worker_id = g_worker_id
    AND  record_type = 'C'
    AND  NOT EXISTS (
           SELECT 1 FROM pa_class_categories cat
           WHERE extr.class_category = cat.class_category
          );

  Pji_Utils.write2log('Deleted ' || SQL%ROWCOUNT ||
     ' dangling record(s) from PJI_PJ_EXTR_PRJCLS - third delete',TRUE,2);



  -- Check for dangling records

  SELECT COUNT(*)
  INTO l_dangling_rowcount
  FROM PJI_PJ_EXTR_PRJCLS
  WHERE project_class_id IS NULL
    AND worker_id = g_worker_id;

  Pji_Utils.write2log('Count of dangling records: ' || l_dangling_rowcount,TRUE,2);

  -- Process dangling records

  IF NVL(l_dangling_rowcount,-1) <> 0 THEN

    -- Update classification dimension. The fact that we run this procedure
    -- after we extracted project classification data should guarantee that
    -- we do not have dangling recrods. If such records still exist
    -- this must be a data corruption issue, we throw an exception.

    extr_class_codes_pvt;

    -- Try to map class_code, class_category to updated classification
    -- dimension.

    UPDATE PJI_PJ_EXTR_PRJCLS   extr
    SET project_class_id = (
          SELECT cls.class_id
          FROM pji_class_codes   cls
          WHERE cls.class_code = extr.class_code
            AND cls.class_category = extr.class_category
        )
    WHERE project_class_id IS NULL
      AND worker_id = g_worker_id;

    Pji_Utils.write2log('Updated ' || SQL%ROWCOUNT || ' dangling record(s)',TRUE,2);

    -- Check if dangling records still exist.

    SELECT COUNT(*)
    INTO l_dangling_rowcount
    FROM PJI_PJ_EXTR_PRJCLS
    WHERE project_class_id IS NULL
      AND worker_id = g_worker_id;

    Pji_Utils.write2log('Identified ' || l_dangling_rowcount || ' record(s) that remain dangling',TRUE,2);

    -- If dangling records still exist then source data is
    -- corrupted. Throw an exception and exit.
    -- This is a public exception, it should be handled by
    -- the calling procedure.

    IF NVL(l_dangling_rowcount,-1) <> 0 THEN
      ROLLBACK;
      Pji_Utils.write2log('Performing rollback and raising an exception',TRUE,2);
	  COMMIT;
      RAISE e_dangling_class_fk;
    END IF;

  END IF;

  -- Clean up log table - delete all log records that
  -- we have extracted.

  delete pa_pji_proj_events_log
  where  event_type = 'Classifications' and
         event_object in (select to_char(project_id) /* to_char added for bug 7517578 */
                                     from   pji_pji_proj_batch_map
                                     where  worker_id = p_worker_id);

  Pji_Utils.write2log('Deleted ' || SQL%ROWCOUNT || ' record(s) from PA_PJI_PROJ_EVENTS_LOG',TRUE,2);

  -- Update project classification map table

  merge INTO pji_project_classes   cls
  USING (
    SELECT
      project_id
    , project_class_id
    , class_code
    , class_category
    , record_type
    , code_percentage
    FROM
      (
      SELECT
        project_id
      , project_class_id
      , class_code
      , class_category
      , record_type
      , SUM(code_percentage)  code_percentage
      FROM
        PJI_PJ_EXTR_PRJCLS
      WHERE
        worker_id = g_worker_id
      GROUP BY
        project_id
      , project_class_id
      , class_code
      , class_category
      , record_type
      )
    WHERE
      code_percentage <> 0
  ) nc
  ON (
        cls.project_id = nc.project_id
    AND cls.project_class_id = nc.project_class_id
  )
  WHEN matched THEN
    UPDATE SET cls.code_percentage = (CASE WHEN cls.code_percentage + nc.code_percentage < 100
                                                THEN cls.code_percentage +nc.code_percentage
                                           WHEN cls.code_percentage + nc.code_percentage = 100
                                                THEN 100
                                           ELSE 100
                                      END) /* Added for bug 8690468  */
  WHEN NOT matched THEN
    INSERT (
      cls.project_id
    , cls.project_class_id
    , cls.code_percentage
    , cls.class_category
    , cls.class_code
    , cls.record_type
    )
    VALUES
    (
      nc.project_id
    , nc.project_class_id
    , nc.code_percentage
    , nc.class_category
    , nc.class_code
    , nc.record_type
    );


  Pji_Utils.write2log('Merged ' || SQL%ROWCOUNT ||
                      ' record(s) into pji_project_classes',TRUE,2);

  Pji_Process_Util.REGISTER_STEP_COMPLETION(l_process,'PJI_PJ_PROJ_CLASS_EXTR.EXTR_PROJECT_CLASSES(p_worker_id);');

    -- truncate intermediate tables no longer required
    l_schema := Pji_Utils.GET_PJI_SCHEMA_NAME;
    --Pji_Process_Util.TRUNC_INT_TABLE( l_schema , 'PJI_PJ_EXTR_PRJCLS' , 'NORMAL',NULL);

  COMMIT;

  Pji_Utils.write2log('Completed PJI_PJ_PROJ_CLASS_EXTR.EXTR_PROJECT_CLASSES',TRUE,2);

END extr_project_classes;

-- ------------------------------------------------
-- procedure CLEANUP
-- ------------------------------------------------

Procedure cleanup( p_worker_id NUMBER ) IS
  l_pji_schema    VARCHAR2(30);
  l_process       VARCHAR2(30);

BEGIN

  g_worker_id := p_worker_id;
  l_process   := g_process || TO_CHAR(g_worker_id);

--  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
--            'PJI_PJ_PROJ_CLASS_EXTR.CLEANUP(p_worker_id);')) then
--    return;
--  end if;


  Pji_Utils.write2log('Entering PJI_PJ_PROJ_CLASS_EXTR.TRUNCATE_INTERIM_TABLES',TRUE,2);

  l_pji_schema := Pji_Utils.get_pji_schema_name;

    Pji_Process_Util.TRUNC_INT_TABLE( l_pji_schema , 'PJI_PJ_EXTR_PRJCLS', 'NORMAL',NULL);

--  PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,'PJI_PJ_PROJ_CLASS_EXTR.CLEANUP(p_worker_id)');

  COMMIT;

  Pji_Utils.write2log('Completed PJI_PJ_PROJ_CLASS_EXTR.TRUNCATE_INTERIM_TABLES',TRUE,2);

END;

END Pji_Pj_Proj_Class_Extr;

/
