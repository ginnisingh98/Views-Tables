--------------------------------------------------------
--  DDL for Package Body PJI_FM_PLAN_MAINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_PLAN_MAINT" AS
/* $Header: PJIPP01B.pls 120.37.12010000.7 2009/10/30 12:21:13 arbandyo ship $ */


g_package_name               VARCHAR2(100) := 'PJI_FM_PLAN_MAINT';

g_worker_id                  NUMBER := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID; -- NULL;
g_event_rec                  PA_PJI_PROJ_EVENTS_LOG%ROWTYPE;
g_process_update_wbs_flag    VARCHAR2(1) := 'N' ;


-- TYPE plan_version_id_rec IS RECORD (plan_version_id pa_budget_versions.budget_version_id%TYPE);

-- TYPE c_plnverid_cur IS REF CURSOR RETURN plan_version_id_rec;

-- FUNCTION get_plan_version_ids_cursor ( p_context VARCHAR2 ) RETURN c_plnverid_cur;

--
-- Populate wbs denorm table for plan create case.
--
PROCEDURE POPULATE_WBS_DENORM(
  p_online            IN   VARCHAR2                         := 'Y'
, p_tar_denorm_not_exists_tbl  IN   SYSTEM.pa_num_tbl_type  := pji_empty_num_tbl
, x_return_status              OUT NOCOPY   VARCHAR2
);


--
-- With data in ver3 table and pjp1 tables,
--  create rollup slices for pri slice and insert into RL fact.
--
PROCEDURE PRI_SLICE_CREATE_T;

--
-- Contains apis to set online context to perform WBS rollups
--   if WBS changes (changes to structure) have been made.
--
PROCEDURE WBSCHANGEPROC_PRERLP_SETUPS;

--
-- Contains cleanup logic after performing WBS rollups if WBS
--   changes (changes to structure) have been made.
--
PROCEDURE WBSCHANGEPROC_POSTRLP_CLEANUP;

--
-- With data in ver3 table and pjp1 tables,
--  create rollup slices for secondary slice and insert into RL fact.
--
PROCEDURE SEC_SLICE_CREATE_T;

PROCEDURE CHECK_PRIMARY_ALREADY_EXISTS (
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_is_primary_rbs    IN   VARCHAR2
, x_return_status     OUT NOCOPY   VARCHAR2 );

--
-- Performance fix: To avoid re-populating pa/pji denorm tables if
--   denorm definition already exists, function checks if denorm definition
--   exists.
--
PROCEDURE DENORM_DEFINITION_EXISTS(
  p_tar_wbs_version_id_tbl         IN         SYSTEM.pa_num_tbl_type         := pji_empty_num_tbl
, x_tar_denorm_not_exists_tbl      OUT NOCOPY SYSTEM.pa_num_tbl_type
);

--
-- Performance tuning and debug api.
--
PROCEDURE PRINT_TIME(p_tag IN VARCHAR2);

------------------------------------------------------------------
------------------------------------------------------------------
--              Private Apis Implementation                     --
------------------------------------------------------------------
------------------------------------------------------------------


PROCEDURE MAP_RESOURCE_LIST (
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_context           IN   VARCHAR2 := 'BULK') IS

  l_return_status VARCHAR2(1) := NULL;
  l_msg_count     NUMBER := NULL;
  l_msg_data      VARCHAR2(300) := NULL;

  i               NUMBER(15) := NULL;
  j               NUMBER(15) := NULL;

  CURSOR c_res_list_id_bulk_cur (p_budget_version_id IN NUMBER) IS
  SELECT rpa.rbs_version_id, bv.plan_version_id
  FROM pa_rbs_prj_assignments rpa
     , PJI_FM_EXTR_PLNVER4 bv
  WHERE 1 = 1
  AND bv.project_id = rpa.project_id
  AND bv.rbs_struct_version_id <> rpa.rbs_version_id
  AND bv.plan_version_id = p_budget_version_id
  AND bv.worker_id = g_worker_id;

  CURSOR c_res_list_id_online_cur (p_budget_version_id IN NUMBER) IS
  SELECT rpa.rbs_version_id, bv.plan_version_id
  FROM pa_rbs_prj_assignments rpa
     , PJI_FM_EXTR_PLNVER3_T bv
  WHERE 1 = 1
  AND bv.project_id = rpa.project_id
  AND bv.rbs_struct_version_id <> rpa.rbs_version_id
  AND bv.plan_version_id = p_budget_version_id;

BEGIN

  print_time(' MAP_RESOURCE_LIST : begin.. ');

  FOR i IN p_fp_version_ids.FIRST..p_fp_version_ids.LAST LOOP

   print_time( ' 1 ' );

   IF (p_context = 'ONLINE') THEN

    print_time( ' 2 ' );

    IF c_res_list_id_online_cur%ISOPEN THEN CLOSE c_res_list_id_online_cur; END IF;

    print_time( ' 3 ' );

    FOR j IN c_res_list_id_online_cur(p_fp_version_ids(i)) LOOP

      print_time( ' 4 i = ' || i );

      BEGIN

        print_time( ' 5 ' );

        PA_RLMI_RBS_MAP_PUB.populate_rbsmap_tmp
        ( p_budget_version_id    => j.plan_version_id
        , p_calling_mode         => 'BUDGET_VERSION'
        , x_return_status        => l_return_status );

        print_time( ' 6 ' );

        PA_RBS_MAPPING.map_rbs_plans (
          p_rbs_version_id   => j.rbs_version_id
        , x_return_status    => l_return_status
        , x_msg_count        => l_msg_count
        , x_msg_data         => l_msg_data
        ) ;

        print_time( ' 7 ' );

      EXCEPTION
        WHEN OTHERS THEN
          print_time( ' 8 ' );
          RAISE;
      END;

      print_time(' l_return_status ' || l_return_status || ' l_msg_count ' || l_msg_count || ' l_msg_data ' || l_msg_data);

    END LOOP;

    IF c_res_list_id_online_cur%ISOPEN THEN CLOSE c_res_list_id_online_cur; END IF;

   ELSIF (p_context = 'BULK') THEN

    IF c_res_list_id_bulk_cur%ISOPEN THEN CLOSE c_res_list_id_bulk_cur; END IF;

    FOR j IN c_res_list_id_bulk_cur(p_fp_version_ids(i)) LOOP

      BEGIN
        PA_RLMI_RBS_MAP_PUB.populate_rbsmap_tmp
        ( p_budget_version_id    => j.plan_version_id
        , p_calling_mode         => 'BUDGET_VERSION'
        , x_return_status        => l_return_status );

        PA_RBS_MAPPING.map_rbs_plans (
          p_rbs_version_id   => j.rbs_version_id
        , x_return_status    => l_return_status
        , x_msg_count        => l_msg_count
        , x_msg_data         => l_msg_data
        ) ;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE;
      END;

      print_time(' l_return_status ' || l_return_status || ' l_msg_count ' || l_msg_count || ' l_msg_data ' || l_msg_data);

    END LOOP;

    IF c_res_list_id_bulk_cur%ISOPEN THEN CLOSE c_res_list_id_bulk_cur; END IF;

   END IF;

  END LOOP;

  IF c_res_list_id_bulk_cur%ISOPEN THEN CLOSE c_res_list_id_bulk_cur; END IF;

  print_time(' MAP_RESOURCE_LIST : end.. ');

EXCEPTION
  WHEN OTHERS THEN
    IF c_res_list_id_bulk_cur%ISOPEN THEN CLOSE c_res_list_id_bulk_cur; END IF;
    IF c_res_list_id_online_cur%ISOPEN THEN CLOSE c_res_list_id_online_cur; END IF;
    print_time(' MAP_RESOURCE_LIST : exception.. ' || sqlerrm);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MAP_RESOURCE_LIST');
    RAISE;
END;





--
-- FPM Upgrade script new, using bulk apis..
-- Will create Plan data primary slice summaries for all plan data.
--
PROCEDURE CREATE_PRIMARY_UPGRD_PVT
(p_context    IN VARCHAR2 := 'FPM_UPGRADE' -- Valid values: 'FPM_UPGRADE' and 'TRUNCATE'
) IS

  c_upgr_proc_name  VARCHAR2(30) := 'PJI_FPM_UPGRADE';
  l_fpm_upgr_status VARCHAR2(100) := NULL;
  l_worker_id       NUMBER;
  l_process         VARCHAR2(30);
  l_extr_start_date DATE;
  l_count           NUMBER := 10;
  v1                VARCHAR2(80);
  v2                VARCHAR2(80);
  l_pa_schema       varchar2(30);
  l_pji_schema      varchar2(30);
  l_degree              number;

BEGIN


  l_count := 1;
  print_time('FPM Upgr x ' || l_count);


  IF (p_context NOT IN ('FPM_UPGRADE', 'TRUNCATE')) THEN
    print_time('CREATE_PRIMARY_UPGRD_PVT : Invalid p_context ' || p_context );
    RETURN;
  END IF;


  --
  -- TB deleted after testing.
  --
  -- fnd_profile.put('PJI_SUM_CLEANALL', 'Y');
  -- pji_pjp_extraction_utils.truncate_pjp_tables(v1,v2,'Y');
  -- Pji_utils.set_parameter('PJI_FPM_UPGRADE', NULL);


  --
  -- Initialize variables..
  --
  -- For FPM upgrade script process, worker id is 1.
  -- l_process value is 'PJI_EXTR1'
  -- l_extr_start_date value is based on PJI_GLOBAL_START_DATE_OVERRIDE if its
  --   profile option value is not null, else it is BIS_GLOBAL_START_DATE.
  -- Gets the FPM upgrade process status.
  -- Valid values are P (partial), C (complete).

  l_worker_id       := 1;
  l_process         := PJI_PJP_SUM_MAIN.g_process || l_worker_id;
  l_extr_start_date := PJI_UTILS.GET_EXTRACTION_START_DATE;
  l_fpm_upgr_status := Pji_utils.get_parameter(c_upgr_proc_name);
  l_count := l_count + 1;
  print_time('FPM Upgr y ' || l_count || ' l_fpm_upgr_status ' || l_fpm_upgr_status );


  --------------------------------------------------------------------------------
  -- If FPM upgrade has already been run successfully ('C'),
  --  then don't start it again.
  -- If not, mark it as partially complete ('P') during call to initialize api.
  --------------------------------------------------------------------------------

  IF (l_fpm_upgr_status = 'C') THEN
    l_count := l_count + 1;
    print_time('FPM Upgr c1 ' || l_count);
    RETURN;
  ELSIF (l_fpm_upgr_status = 'P') THEN
    l_count := l_count + 1;
    print_time('FPM Upgr c2 ' || l_count);
    NULL;
  ELSIF (l_fpm_upgr_status IS NULL) THEN
    l_count := l_count + 1;
    print_time('FPM Upgr c3 ' || l_count);
    -- Description of this api is given below.
    PJI_FM_XBS_ACCUM_UTILS.FPM_UPGRADE_INITIALIZE;
    print_time('FPM Upgr c4  ' || l_count );
  END IF;


  --
  -- PJI_FM_XBS_ACCUM_UTILS.FPM_UPGRADE_INITIALIZE;
  --
  --
  -- The call to the PJI_FM_XBS_ACCUM_UTILS.FPM_UPGRADE_INITIALIZE api below does the following:
  --
  --
  -- Update pji system settings table and system parameter CONFIG_PROJ_PERF_FLAG to 'Y'.
  -- Set parameter PJI_EXTR1$EXTRACTION_TYPE to FULL.
  -- Set parameter PJI_EXTR1$PROCESS_RUNNING to Y.
  -- Set PJI_PJP_EXTRACTION_UTILS to 1.
  -- Store PJP summarization state by
  --   a. inserting a row in PJI_SYSTEM_CONFIG_HIST with process name (PJI_EXTR1) and
  --          extraction type (FULL) with system date as start date.
  --   b. inserting rows in PJI_PJP_PROJ_BATCH_MAP with worker id and project id information.
  -- Set values of system parameters PA_CALENDAR_FLAG and GL_CALENDAR_FLAG with that in pji_system_settings table.
  -- Commit these changes.
  --


  l_count := l_count + 1;
  print_time('FPM Upgr z1 ' || l_count);


  -- Truncate PJI_MT_PRC_STEPS.
  -- Insert data into PJI_MT_PRC_STEPS with foll info.
  --   a. Step seq 10, process name 'PJI_EXTR', step name 'PJI_FM_SUM_MAIN.INIT_PROCESS', step type 'GENERIC'.
  --   b. Step seq 20, process name 'PJI_EXTR', step name 'PJI_FM_SUM_MAIN.RUN_PROCESS', step type 'GENERIC'.
  --   c. Step seq 30, process name 'PJI_EXTR', step name 'PJI_FM_SUM_MAIN.WRAPUP_PROCESS', step type 'GENERIC'.
  --   d. Step seq 40, process name 'PJI_EXTR', step name 'PJI_FM_SUM_EXTR.GET_NEXT_BATCH(p_worker_id)', step type 'GENERIC'.
  --
  --
  PJI_PROCESS_UTIL.REFRESH_STEP_TABLE;
  l_count := l_count + 1;
  print_time('FPM Upgr 1.1 ' || l_count);

  -- ... register the 14 following steps into PJI_MT_PRC_STEPS/PJI_SYSTEM_PRC_STATUS.
  PJI_PROCESS_UTIL.ADD_STEPS(l_process, 'PJI_PJP_FPM_UPGRADE', 'FULL');
  l_count := l_count + 1;
  print_time('FPM Upgr  1.2 ' || l_count);

  --
  -- 0. ... Remap txn accum headers with new rbs element ids.
  --
  IF (p_context = 'TRUNCATE') THEN
    PJI_PJP_SUM_ROLLUP.REMAP_RBS_TXN_ACCUM_HDRS(l_worker_id);
    PJI_PJP_SUM_DENORM.POPULATE_RBS_DENORM(l_worker_id, 'ALL', NULL);
    PJI_PJP_SUM_ROLLUP.UPDATE_RBS_DENORM(l_worker_id);
  END IF;

  --
  -- 1. ... populate pji_time% tables.
  --
  PJI_PJP_SUM_ROLLUP.POPULATE_TIME_DIMENSION(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr a ' || l_count);

  --
  -- populate pji org extr info table with pa/gl cal info for orgs.
  --
  PJI_PJP_EXTRACTION_UTILS.POPULATE_ORG_EXTR_INFO;
  l_count := l_count + 1;
  print_time('FPM Upgr z2 ' || l_count);


  --
  -- 2. ... populate pa xbs denorm table for wbs/programs.
  --

  l_count := l_count + 1;
  print_time('FPM Upgr b ' || l_count);

   PJI_PJP_SUM_DENORM.POPULATE_XBS_DENORM(
     p_worker_id                => l_worker_id
   , p_denorm_type      => 'ALL'
   , p_wbs_version_id   => NULL
   , p_prg_group1       => NULL
   , p_prg_group2       => NULL);

  --#bug 5356051
  l_pa_schema := PJI_UTILS.GET_PA_SCHEMA_NAME;
  l_degree := PJI_UTILS.GET_DEGREE_OF_PARALLELISM();

  FND_STATS.GATHER_TABLE_STATS(
                        ownname  =>  l_pa_schema
                      , tabname  =>  'PA_XBS_DENORM'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );

   FND_STATS.GATHER_INDEX_STATS(ownname => l_pa_schema,
                                indname => 'PA_XBS_DENORM_N1',
                                percent => 10);

   FND_STATS.GATHER_INDEX_STATS(ownname => l_pa_schema,
                                indname => 'PA_XBS_DENORM_N2',
                                percent => 10);

   FND_STATS.GATHER_INDEX_STATS(ownname => l_pa_schema,
                                indname => 'PA_XBS_DENORM_N3',
                                percent => 10);

  --#bug 5356051
  --
  -- 3. ... populate pji xbs denorm table for wbs/programs.
  --
  PJI_PJP_SUM_ROLLUP.UPDATE_XBS_DENORM_FULL(l_worker_id);
  l_count := 31;
  print_time('FPM Upgr c ' || l_count);

  --#bug 5356051
  l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

  FND_STATS.GATHER_TABLE_STATS(
                        ownname  =>  l_pji_schema
                      , tabname  =>  'PJI_XBS_DENORM'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );

   FND_STATS.GATHER_INDEX_STATS(ownname => l_pji_schema,
                                indname => 'PJI_XBS_DENORM_N1',
                                percent => 10);

   FND_STATS.GATHER_INDEX_STATS(ownname => l_pji_schema,
                                indname => 'PJI_XBS_DENORM_N2',
                                percent => 10);

   FND_STATS.GATHER_INDEX_STATS(ownname => l_pji_schema,
                                indname => 'PJI_XBS_DENORM_N3',
                                percent => 10);

  --#bug 5356051

  --
  -- 4. ... cache plan version related info like time phased code type (pa/gl cal),
  --     whether it is workplan/financial plan, is it current original/baselined
  --     baselined version, etc in ver3.
  --
  PJI_PJP_SUM_ROLLUP.EXTRACT_FIN_PLAN_VERS_BULK(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr d ' || l_count);
  -- PRINT_TBL_SIZE;

  --
  -- 5. ... populate the wbs header table.
  --
  PJI_PJP_SUM_ROLLUP.POPULATE_WBS_HDR(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr e ' || l_count);


  --
  -- 6. ... populate the rbs header table.
  --
  PJI_PJP_SUM_ROLLUP.POPULATE_RBS_HDR(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr f ' || l_count);

  --
  -- 7. ... extract the plan amounts from budget lines table into pjp1.
  --

  IF (p_context = 'TRUNCATE') THEN

    -- Extract plan lines.
       PJI_PJP_SUM_ROLLUP.RETRIEVE_OVERRIDDEN_WP_ETC(l_worker_id);
       l_count := l_count + 1;
    -- print_time('FPM Upgr g ' || l_count);

    -- Extract plans and etc (=plan).
    PJI_PJP_SUM_ROLLUP.EXTRACT_PLAN_ETC_PRIRBS(l_worker_id);
    l_count := l_count + 1;
    print_time('FPM Upgr g ' || l_count);

    -- Delete plan lines.
    -- PJI_PJP_SUM_ROLLUP.DELETE_PLAN_LINES(l_worker_id);
    -- l_count := l_count + 1;
    -- print_time('FPM Upgr g ' || l_count);

  ELSIF (p_context = 'FPM_UPGRADE') THEN

    PJI_PJP_SUM_ROLLUP.EXTRACT_PLAN_AMOUNTS_PRIRBS(l_worker_id);
    l_count := l_count + 1;
    print_time('FPM Upgr g ' || l_count);

  END IF;


  --
  -- 9. ... update the wbs header table.
  --
  PJI_PJP_SUM_ROLLUP.UPDATE_WBS_HDR(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr e ' || l_count);


  --
  -- 11. ... perform time rollup for 'PA' calendar and insert data into pjp1.
  --
  PJI_PJP_SUM_ROLLUP.CREATE_FP_PA_PRI_ROLLUP(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr k ' || l_count);

  --
  -- 12. ... perform time rollup for 'GL' calendar and insert data into pjp1.
  --
  PJI_PJP_SUM_ROLLUP.CREATE_FP_GL_PRI_ROLLUP(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr l ' || l_count);
  -- PRINT_TBL_SIZE;

  --
  -- 12.1 ... perform 2048 slice time rollup for PA and GL calendarS and insert data into pjp1.
  --
  PJI_PJP_SUM_ROLLUP.CREATE_FP_ALL_PRI_ROLLUP(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr l ' || l_count);
  -- PRINT_TBL_SIZE;


  --
  -- 10. ... perform rbs rollup for 'T' slice alone and insert data into pjp1.
  --
  PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_T_SLICE(l_worker_id);
  l_count := 50;
  l_count := l_count + 1;
  print_time('FPM Upgr j ' || l_count);

  --
  -- 9. ... perform wbs rollup and insert data into pjp1.
  --
  PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_WBS(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr i ' || l_count);
  -- PRINT_TBL_SIZE;


  --
  -- 13. ... insert data in pjp1 into pji_fp_xbs_accum_f.
  --
  PJI_PJP_SUM_ROLLUP.INSERT_INTO_FP_FACT(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr ' || l_count);

  --
  -- 14. ... mark all the extracted financial plan versions as 'P' and work plans as 'Y'.
  --
  PJI_PJP_SUM_ROLLUP.MARK_EXTRACTED_PLANS(l_worker_id);
  l_count := l_count + 1;
  print_time('FPM Upgr ' || l_count);


  --
  -- ... call the FPM upgrade script end api. This does..
  --    a0. Truncate pjp1 tables and insert rcds in PJI_SYSTEM_PRC_STATUS into
  --           PJI_SYSTEM_PRC_HIST for process PJI_EXTR1.
  --    a1. FPM upgrade script run is Complete, set system parameter PJI_FPM_UPGRADE as C.
  --    a2. Insert records existing in PJI_SYSTEM_PRC_STATUS into PJI_SYSTEM_PRC_HIST.
  --    b. Delete records in PJI_SYSTEM_PRC_STATUS for process PJI_EXTR.
  --    c. Delete records in PJI_SYSTEM_PARAMETERS for process PJI_EXTR1.
  --    d. Set end date on PJI_SYSTEM_CONFIG_HIST for this process.
  --    e. Set system parameter PJP_FPM_UPGRADE_DATE to sysdate.
  --    f. Delete data from PJI_PJP_PROJ_BATCH_MAP for worker id l_worker_id = 1.
  --

  PJI_FM_XBS_ACCUM_UTILS.FPM_UPGRADE_END;
  l_count := l_count + 1;
  print_time('FPM Upgr ' || l_count);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' FPM upgrade script... exception ' || SQLERRM);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_PRIMARY_UPGRD_PVT');
    ROLLBACK;                                         l_count := l_count + 1;  print_time('FPM Upgr ' || l_count || ' Exception happened ' || SQLERRM );
    RAISE;
    -- RAISE_APPLICATION_ERROR(-20001, SQLERRM);

END;


--
-- Will create Plan data summaries for all plan data.
--   p_is_primary_rbs = 'T' will be used when a plan is baselined.
--   Processing for this condition should be moved to another api.
--
--  CREATE_PRIMARY_PVT : ****internal only**** summarization api.
--   p_fp_version_ids -> table of destination plan version ids.
--   p_is_primary_rbs -> only 'T' is supported.
--   p_commit -> only 'F' is supported.
--   p_fp_src_version_ids -> table of source plan version ids.
--   p_copy_mode -> If NULL, denorm table is created based on task relationships
--                  If NOT NULL, denorm table is created based denorm copy of source structure
--
PROCEDURE CREATE_PRIMARY_PVT(
  p_fp_version_ids        IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_is_primary_rbs        IN   VARCHAR2 -- Valid values are T/F.
, p_commit                IN   VARCHAR2 := 'F'
, p_fp_src_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_Copy_mode             IN   VARCHAR2 :=NULL
) IS

CURSOR c_src_struct_version_id (
     c_fp_src_version_id pa_budget_versions.budget_version_id%TYPE
  ) IS
  (
    SELECT DECODE ( src.wp_version_flag
                  , 'Y'
                  , src.project_structure_version_id
                  , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(src.project_id)
                  ) src_struct_version_id
    FROM   pa_budget_versions src
    WHERE src.budget_version_id = c_fp_src_version_id
  );

CURSOR c_dest_struct_version_id (
     c_fp_tar_version_id pa_budget_versions.budget_version_id%TYPE
  ) IS
  (
    SELECT DECODE ( tar.wp_version_flag
                  , 'Y'
                  , tar.project_structure_version_id
                  , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(tar.project_id)
                  ) tar_struct_version_id
    FROM   pa_budget_versions tar
    WHERE tar.budget_version_id = c_fp_tar_version_id
  );

  l_wbs_src_struct_version_id   pa_budget_versions.project_structure_version_id%TYPE;
  l_wbs_tar_struct_version_id   pa_budget_versions.project_structure_version_id%TYPE;
  l_return_status               VARCHAR2(1) ;

  -- Avoid re-populating pa/pji denorm tables if denorm definition already exists.
  l_tar_denorm_exists_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

  l_wbs_tar_wvi_valid_tbl       SYSTEM.pa_num_tbl_type        := pji_empty_num_tbl;
  l_src_wbs_version_id_tbl      SYSTEM.pa_num_tbl_type        := pji_empty_num_tbl;
  l_tar_wbs_version_id_tbl      SYSTEM.pa_num_tbl_type        := pji_empty_num_tbl;
  l_tar_denorm_not_exists_tbl   SYSTEM.pa_num_tbl_type         := pji_empty_num_tbl;

  l_src_pln_ver_id              NUMBER;

BEGIN

   print_time('CREATE_PRIMARY_PVT 2 : begin.. ');

   FOR i IN 1..p_fp_version_ids.COUNT LOOP
     print_time ( 'p_fp_version_ids(i) ' || p_fp_version_ids(i));
   END LOOP;

   FOR i IN 1..p_fp_src_version_ids.COUNT LOOP
     print_time ( 'p_fp_src_version_ids(i) ' || p_fp_src_version_ids(i));
   END LOOP;

   print_time(' p_is_pri_rbs ' || p_is_primary_rbs);
   print_time(' p_Copy_mode ' || p_copy_mode );

   print_time('CREATE_PRIMARY_PVT 2 : l_count is ... ' || p_fp_version_ids.COUNT );

   pji_pjp_fp_curr_wrap.set_table_stats('PJI','PJI_FM_EXTR_PLNVER3_T',10,10,10);  -- Seeding the table Ver3_t

   IF (p_is_primary_rbs NOT IN ('T', 'F')) THEN
     RETURN;
   END IF;


   CHECK_PRIMARY_ALREADY_EXISTS (
     p_fp_version_ids    => p_fp_version_ids
   , p_is_primary_rbs    => p_is_primary_rbs
   , x_return_status     => l_return_status );

   -------------------------------------------------------------------------
   -- Preparing for extraction and extracting from budget lines.
   -------------------------------------------------------------------------

   PJI_FM_PLAN_MAINT_T_PVT.CLEANUP_INTERIM_TABLES;         print_time(' 3 ..1 ');


   IF (p_is_primary_rbs = 'T') THEN

     PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(
       p_fp_version_ids  => p_fp_version_ids
     , p_slice_type      => 'PRI');

   ELSE

     NULL; -- Sec RBSes are extracted in create sec pvt.

   END IF;

   IF (CHECK_VER3_NOT_EMPTY(p_online => 'T') = 'F') THEN
     RETURN;
   END IF;

   PJI_FM_PLAN_MAINT_T_PVT.MAP_ORG_CAL_INFO('N');
   print_time(' 2.. Update org/cal tables. ');


   print_time(' ************** Denorm processing begin ************** ');
   print_time(' ***************************************************** ');

   print_time(' p_Copy_mode ' || p_copy_mode );

   -- Loop for all destination versions.
   FOR i IN 1..p_fp_version_ids.COUNT LOOP

     print_time(' i loop start' || i ) ; -- : dest plan version id is.. ' || p_fp_version_ids(i));

     -- Padding source plan version id with null wbs version id for destination
     --   plans with non-existent source. For these plans wbs denorm can only be created
     --   and not copied. This is for copy=NULL mode only (create the wbs denorm using
     --   the wbs assigned to this plan version).

     IF (i > p_fp_src_version_ids.COUNT OR p_fp_src_version_ids(i) IS NULL ) THEN
       l_src_pln_ver_id := NULL;
       l_src_wbs_version_id_tbl.EXTEND;
       l_src_wbs_version_id_tbl(l_src_wbs_version_id_tbl.COUNT) := NULL;
       print_time(' There is no corresponding source WBS version id.' ) ;
     ELSE

       FOR j IN c_src_struct_version_id(p_fp_src_version_ids(i)) LOOP
         l_src_wbs_version_id_tbl.EXTEND;
         l_src_wbs_version_id_tbl(l_src_wbs_version_id_tbl.COUNT) := j.src_struct_version_id;
         print_time(' source wbs version id ' || l_src_wbs_version_id_tbl(l_src_wbs_version_id_tbl.COUNT) );
       END LOOP;

     END IF;

     FOR j IN c_dest_struct_version_id(p_fp_version_ids(i)) LOOP
       l_tar_wbs_version_id_tbl.EXTEND;
       l_tar_wbs_version_id_tbl(l_tar_wbs_version_id_tbl.COUNT) := j.tar_struct_version_id;
       print_time(' Destination wbs version id =  ' || j.tar_struct_version_id);
     END LOOP;

     print_time(' i loop end ');

   END LOOP;


   IF p_copy_mode IS NULL THEN

      DENORM_DEFINITION_EXISTS(
        p_tar_wbs_version_id_tbl       => l_tar_wbs_version_id_tbl
      , x_tar_denorm_not_exists_tbl    => l_tar_denorm_not_exists_tbl
      );

      POPULATE_WBS_DENORM(
        p_online                       => 'Y'
      , p_tar_denorm_not_exists_tbl    => l_tar_denorm_not_exists_tbl
      , x_return_status                => l_return_status );

    ELSE

      -- this will be called only if its Copy Mode is not null i,e either Project(P) or Version(V)

      FOR i IN p_fp_src_version_ids.first..p_fp_src_version_ids.last LOOP

	  print_time(' ----------- Begin denorm copy..' );

        Pji_Pjp_Sum_Denorm.copy_xbs_denorm(
          p_worker_id            => 1 ,
          p_wbs_version_id_from  => l_src_wbs_version_id_tbl(i),
          p_wbs_version_id_to    => l_tar_wbs_version_id_tbl(i),
          p_copy_mode            => p_copy_mode
        );

	  print_time(' ----------- End denorm copy..' );

      END LOOP;

    END IF;
   -- end of for Copy populate startegy change

   print_time(' ***************************************************** ');
   print_time(' ************** Denorm processing end **************** ');

   --Introduced below api call for bug 7187487
   --PJI_FM_PLAN_MAINT_T_PVT.GET_GLOBAL_EXCHANGE_RATES; -- Bug 7681331

   IF (p_is_primary_rbs = 'T') THEN
      --Introduced below api call for bug 7187487
      -- PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_PLAN_AMTS_PRIRBS_GLC12;  --Bug 7681331
      PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_PLAN_AMOUNTS_PRIRBS;
      print_time(' 5.1 .. ');

   ELSE

     MAP_RESOURCE_LIST (p_fp_version_ids);
     PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_PLAN_AMOUNTS_SECRBS;        print_time(' 5.2 .. ');

   END IF;

   -- With data in ver3 table and pjp1 tables,
   --  create rollup slices and insert into RL fact.
   -- Mark extracted versions, clean up the interim tables and insert into FP RL fact.


   PRI_SLICE_CREATE_T; print_time(' 6 .. ');
   PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES;
   PJI_FM_PLAN_MAINT_T_PVT.MERGE_INTO_FP_FACT;       print_time(' 14 .. ');

   PJI_FM_PLAN_MAINT_T_PVT.MARK_EXTRACTED_PLANS('PRI');      print_time(' 15 .. ');


   IF (p_commit = 'T') THEN
     COMMIT;
   END IF;

   print_time('CREATE_PRIMARY_PVT 2 : end.. ');

EXCEPTION
  WHEN OTHERS THEN
    IF c_src_struct_version_id%ISOPEN THEN
      CLOSE c_src_struct_version_id;
    END IF;

    IF c_dest_struct_version_id%ISOPEN THEN
      CLOSE c_dest_struct_version_id;
    END IF;

    print_time('CREATE_PRIMARY_PVT 2 : exception ' || SQLERRM);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_PRIMARY_PVT');
    RAISE;
END;


PROCEDURE CREATE_SECONDARY_PVT(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F'
, p_process_all       IN   VARCHAR2 := 'F') IS

  l_count NUMBER;
  l_return_status VARCHAR2(1);
  l_time_phase_flag varchar2(2);  /* Added for bug 8708651 */

BEGIN

   print_time('CREATE_SECONDARY_PVT: begin.. ');


   Pji_Fm_Plan_Maint_Pvt.EXTRACT_FIN_PLAN_VERS_BULK(p_slice_type => 'SEC_PROJ');
   Pji_Fm_Plan_Maint_Pvt.EXTRACT_FIN_PLAN_VERS_BULK(p_slice_type => 'SECRBS_PROJ');
   print_time(' Identified plan versions to be extracted. ');

   IF (CHECK_VER3_NOT_EMPTY(p_online => 'F') = 'F') THEN
     print_time(' No data in ver3, returning. ');
     RETURN;
   END IF;

   Pji_Fm_Plan_Maint_Pvt.GET_GLOBAL_EXCHANGE_RATES;
   print_time(' Got global exchange rates. ');

   Pji_Fm_Plan_Maint_Pvt.POPULATE_RBS_HDR;
   print_time('Populated RBS header table.');

   Pji_Fm_Plan_Maint_Pvt.POPULATE_WBS_HDR;
   print_time('Populated WBS header table.');

   Pji_Fm_Plan_Maint_Pvt.EXTRACT_PLAN_AMTS_PRIRBS_GLC12;
   print_time(' Extracted plan data for primary RBSes.');

   Pji_Fm_Plan_Maint_Pvt.EXTRACT_PLAN_AMTS_SECRBS_GLC12;
   print_time(' Extracted plan data for primary RBSes.');

   Pji_Fm_Plan_Maint_Pvt.DELETE_GLOBAL_EXCHANGE_RATES;
   print_time(' Deleted global exchange rates. ');

   /* Added for bug 8708651 */
   l_time_phase_flag := PJI_UTILS.GET_SETUP_PARAMETER('TIME_PHASE_FLAG');

   if l_time_phase_flag = 'Y' then
      null;
   else
      PJI_FM_PLAN_MAINT_T_PVT.PRORATE_TO_ALL_CALENDARS;
   end if;
   /* Added for bug 8708651 */
   print_time(' Prorated to all calendars. ');

   PJI_FM_PLAN_MAINT_PVT.UPDATE_WBS_HDR;
   print_time(' Updated the WBS header table with min max txn dates.');

   Pji_Fm_Plan_Maint_Pvt.EXTRACT_DANGL_REVERSAL;
   print_time(' Inserted Reversal records for dangling plans.');

   Pji_Fm_Plan_Maint_Pvt.MARK_EXTRACTED_PLANS('SEC');
   print_time('Marked dangling versions.. ');
   -- Back from unlock headers because at the time of dangling its not marking
   -- due to purge before unlock headers bug 5155692

   print_time('CREATE_SECONDARY_PVT: end. successful.. ');

EXCEPTION
  WHEN OTHERS THEN
    print_time('CREATE_SECONDARY_PVT: exception. '|| SQLERRM);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_SECONDARY_PVT');
    RAISE;
END;


PROCEDURE CREATE_SECONDARY_T_PVT(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F'
, p_process_all       IN   VARCHAR2 := 'F') IS

  l_return_status   VARCHAR2(1);

BEGIN

   print_time('CREATE_SECONDARY_T_PVT: begin.. ');

   -------------------------------------------------------------------------
   -- Re-extract pri/sec rbs data with amounts converted to Global1 and
   --    Global2 currencies also.
   -------------------------------------------------------------------------

   PJI_FM_PLAN_MAINT_T_PVT.CLEANUP_INTERIM_TABLES; -- Clean up interim tables.
   print_time(' Cleaned up interim tables. ');

   print_time(' !!!!!!!!!!!! Begin reextraction !!!!!!!! ');


   IF (p_process_all = 'F') THEN
     PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(p_fp_version_ids, 'PRI');
     PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(p_fp_version_ids, 'SECRBS');
     -- PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(p_fp_version_ids, '-3-4');
   ELSE
     print_time(' Incorrect parameters to CREATE_SECONDARY_T_PVT: p_process_all = ' || p_process_all );
     RETURN;
   END IF;
   print_time(' Populated ver3 table. ');

   IF (CHECK_VER3_NOT_EMPTY(p_online => 'T') = 'F') THEN
     print_time(' No data in ver3, returning. ');
     RETURN;
   END IF;

   PJI_FM_PLAN_MAINT_T_PVT.MAP_ORG_CAL_INFO('N') ;
   print_time(' Updated calendar and org tables. ');

   PJI_FM_PLAN_MAINT_T_PVT.GET_GLOBAL_EXCHANGE_RATES;
   print_time(' Got global exchange rates. ');

   SEC_SLICE_CREATE_T;
   print_time('Proration done and rollups created.');

   PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES;

   PJI_FM_PLAN_MAINT_T_PVT.MERGE_INTO_FP_FACT;
   print_time('Merged reversed data.');

   PJI_FM_PLAN_MAINT_T_PVT.MARK_EXTRACTED_PLANS('SEC');
   print_time('Marked ');

   PJI_FM_PLAN_MAINT_T_PVT.DELETE_GLOBAL_EXCHANGE_RATES;
   print_time(' Deleted global exchange rates. ');

   PJI_FM_PLAN_MAINT_T_PVT.CLEANUP_INTERIM_TABLES; -- Clean up interim tables.

   IF (p_commit = 'T') THEN
     COMMIT;
   END IF;

   print_time('CREATE_SECONDARY_T_PVT: end. successful.. ');

EXCEPTION
  WHEN OTHERS THEN
    print_time('CREATE_SECONDARY_T_PVT: exception. ');
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_SECONDARY_T_PVT');
    RAISE;
END;


PROCEDURE UPDATE_PRIMARY_PVT (
  p_plan_version_ids  IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
  -- p_plan_version_id   IN   NUMBER := NULL
, p_commit            IN   VARCHAR2 := 'F'
)
IS
  -- l_plan_version_ids  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(p_plan_version_id);
BEGIN

  print_time('UPDATE_PRIMARY_PVT: begin.. ');

  PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(
     p_fp_version_ids  => p_plan_version_ids
   , p_slice_type      => 'PRI');

  print_time ( ' 1.1 ');

  IF (CHECK_VER3_NOT_EMPTY(p_online => 'T') = 'F') THEN
    RETURN;
  END IF;

  WBSCHANGEPROC_PRERLP_SETUPS;
  print_time(' Setups before calling WBS rollup code. ');

  PJI_FM_PLAN_MAINT_T_PVT.MAP_ORG_CAL_INFO('N');
  print_time(' 1.a3 Updated org/cal tables. ');

  PJI_FM_PLAN_MAINT_T_PVT.RETRIEVE_DELTA_SLICE;           print_time ( ' 2 ');
  print_time(' 1.a4 Extracted data in plan lines. ');


  -- With data in ver3 table and pjp1 tables,
  --  create rollup slices for primary slice.
  -- Mark extracted versions, clean up the interim tables and insert into FP RL fact.

  PRI_SLICE_CREATE_T;
  print_time ( ' 3 PRI_SLICE_CREATE_T ');
  PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES;
  WBSCHANGEPROC_POSTRLP_CLEANUP;
  print_time(' Cleanup after calling WBS rollup code. ');

  PJI_FM_PLAN_MAINT_T_PVT.MERGE_INTO_FP_FACT;
  print_time(' Merged into FP fact. ');

  PJI_FM_PLAN_MAINT_T_PVT.MARK_EXTRACTED_PLANS('PRI');
  print_time(' Marked extracted plans ');

  PJI_FM_PLAN_MAINT_T_PVT.CLEANUP_INTERIM_TABLES;
  print_time(' Cleaned up interim tables.');

  print_time('UPDATE_PRIMARY_PVT: end. successful.. ');

EXCEPTION
  WHEN OTHERS THEN
    print_time('UPDATE_PRIMARY_PVT: exception.. ');
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'UPDATE_PRIMARY_PVT');
    RAISE;
END;


------------------------------------------------------------------------------------------
-- When this api is called during publish flow, budgeting api has already created plan
--  and default etc (=plan) data for new published version through update api.
--  Data exists for etc values in plan lines.
------------------------------------------------------------------------------------------
PROCEDURE UPDATE_PRIMARY_PVT_ACT_ETC (
      p_commit               IN   VARCHAR2 := 'F'
    , p_plan_version_id      IN   NUMBER := NULL
    , p_prev_pub_version_id  IN   NUMBER := NULL
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_processing_code     OUT NOCOPY VARCHAR2) IS

  l_fp_version_ids SYSTEM.pa_num_tbl_type;

BEGIN

  print_time ( 'UPDATE_PRIMARY_PVT_ACT_ETC: begin.. ');
  print_time ( 'UPDATE_PRIMARY_PVT_ACT_ETC: p_plan_version_id ' || p_plan_version_id );
  print_time ( ' p_prev_pub_version_id ' || p_prev_pub_version_id );

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );


  PJI_FM_PLAN_MAINT_T_PVT.CLEANUP_INTERIM_TABLES;               -- Clean up interim tables.

  PJI_FM_PLAN_MAINT_T_PVT.POPULATE_PLN_VER_TABLE;                 print_time ( ' 1 ');

  -- WBSCHANGEPROC_PRERLP_SETUPS;
  -- print_time(' Setups before calling WBS rollup code. ');

  PJI_FM_PLAN_MAINT_T_PVT.REVERSE_ETC(
    p_new_pub_version_id  => p_plan_version_id
  , p_prev_pub_version_id => p_prev_pub_version_id ) ;             print_time ( ' 0.2 ');

  PRI_SLICE_CREATE_T;                                    print_time ( ' 3 ');
   PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES;
  -- WBSCHANGEPROC_POSTRLP_CLEANUP;
  -- print_time(' Cleanup after calling WBS rollup code. ');

  PJI_FM_PLAN_MAINT_T_PVT.MERGE_INTO_FP_FACT;                   print_time(' 4 .. ');

  print_time('UPDATE_PRIMARY_PVT_ACT_ETC: end. successful.. ');

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'UPDATE_PRIMARY_PVT_ACT_ETC'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


PROCEDURE DELETE_ALL_PVT (
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F') IS

  l_project_ids     SYSTEM.pa_num_tbl_type := pji_empty_num_tbl;
  l_wbs_version_ids     SYSTEM.pa_num_tbl_type := pji_empty_num_tbl;
  l_wp_flags     SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();

BEGIN

  print_time('DELETE_ALL_PVT: begin.. ');

  l_project_ids.EXTEND(p_fp_version_ids.COUNT);
  l_wbs_version_ids.EXTEND(p_fp_version_ids.COUNT);
  l_wp_flags.EXTEND(p_fp_version_ids.COUNT);

  FOR i IN 1..p_fp_version_ids.COUNT LOOP
    BEGIN --bug#4100852
    SELECT /*+ index(wbs_hdr PJI_PJP_WBS_HEADER_N1) */ project_id,wbs_version_id, wp_flag
    INTO   l_project_ids(i),l_wbs_version_ids(i),l_wp_flags(i)
    FROM   PJI_PJP_WBS_HEADER wbs_hdr
    WHERE  plan_version_id = p_fp_version_ids(i);

    print_time ( ' i = ' || i || ' p_fp_version_ids(i) = ' || p_fp_version_ids(i) || ' l_project_ids(i) ' || l_project_ids(i)
    ||' l_wbs_version_id(i)= '||l_wbs_version_ids(i) ||' l_wp_flag(i) = '||l_wp_flags(i) );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END LOOP;

  /* Added for bug 8708651 */
  BEGIN
  FORALL i IN 1..p_fp_version_ids.COUNT
      DELETE FROM PJI_FP_XBS_ACCUM_F
      WHERE plan_version_id  = p_fp_version_ids(i)
        AND project_id = l_project_ids(i);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
  /* Added for bug 8708651 */

  print_time ( 'deleted from fact. # rows =  ' || SQL%ROWCOUNT ) ;

  FORALL i IN 1..p_fp_version_ids.COUNT
      DELETE FROM PJI_PJP_WBS_HEADER
      WHERE plan_version_id  = p_fp_version_ids(i)
        AND project_id = l_project_ids(i);

  print_time ( 'deleted from wbs hdr table. # rows =  ' || SQL%ROWCOUNT ) ;

  FORALL i IN 1..p_fp_version_ids.COUNT
      DELETE FROM PJI_PJP_RBS_HEADER
      WHERE plan_version_id  = p_fp_version_ids(i)
        AND project_id = l_project_ids(i);

  print_time ( 'deleted from rbs header. # rows =  ' || SQL%ROWCOUNT ) ;

  FORALL i IN 1..p_fp_version_ids.COUNT
      DELETE FROM PJI_ROLLUP_LEVEL_STATUS
      WHERE plan_version_id  = p_fp_version_ids(i);

  print_time ( 'deleted from rollup level status. # rows =  ' || SQL%ROWCOUNT ) ;

FORALL i IN 1..p_fp_version_ids.COUNT
      DELETE FROM PA_XBS_DENORM
      WHERE sup_project_id = l_project_ids(i)
      AND l_wp_flags(i) = 'Y'
      AND ( struct_version_id = l_wbs_version_ids(i)
      OR (struct_type = 'PRG' AND sup_id = l_wbs_version_ids(i) AND sub_id = l_wbs_version_ids(i)));

  print_time ( 'deleted from pa_xbs_denorm table. # rows =  ' || SQL%ROWCOUNT ) ;

  FORALL i IN 1..p_fp_version_ids.COUNT
      DELETE FROM PJI_XBS_DENORM
      WHERE sup_project_id = l_project_ids(i)
      AND l_wp_flags(i) = 'Y'
      AND ( struct_version_id = l_wbs_version_ids(i)
      OR (struct_type = 'PRG' AND sup_id = l_wbs_version_ids(i) AND sub_id = l_wbs_version_ids(i)));

  print_time ( 'deleted from pji_xbs_denorm table. # rows =  ' || SQL%ROWCOUNT ) ;

  IF (p_commit = 'T') THEN COMMIT; END IF;

  print_time('DELETE_ALL_PVT: end.. successful.. ');

EXCEPTION
  WHEN OTHERS THEN
    print_time('DELETE_ALL_PVT: exception.. ');
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DELETE_ALL_PVT');
    RAISE;
END;


--
-- Summarization API for common processing between various online flows.
-- With data in ver3 table and pjp1 tables,
--  create rollup slices and insert into RL fact.
--
PROCEDURE PRI_SLICE_CREATE_T IS
BEGIN

   --------------------------------
   -- Header table population.
   --------------------------------
   PJI_FM_PLAN_MAINT_T_PVT.POPULATE_RBS_HDR;
   print_time('Populated new records into RBS Header Table.');

   PJI_FM_PLAN_MAINT_T_PVT.POPULATE_WBS_HDR;
   print_time('Populated new records into WBS Header Table.');

   --------------------------------
   -- Time rollups.
   --------------------------------

   PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_PA_PRI_ROLLUP(p_honor_rbs => 'N');
   print_time('PA calendar rollups done.');

   PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_GL_PRI_ROLLUP(p_honor_rbs => 'N');
   print_time('GL calendar rollups done.');

  -- PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_ALL_T_PRI_ROLLUP(p_honor_rbs => 'N');   /* Bug 4604617 */
   print_time('All time calendar rollups done 1.');

   PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_ALL_T_PRI_ROLLUP(
     p_honor_rbs     => 'N'
   , p_calendar_type => 'C');    /* For Time phase None Bug 4604617 */
   print_time('All time calendar rollups done 2.'); /* Added for bug 3871783 */

   --------------------------------
   -- RBS/WBS/Program rollups.
   --------------------------------

   PJI_FM_PLAN_MAINT_T_PVT.ROLLUP_FPR_RBS_T_SLICE;
   print_time('RBS rollup done.');

   PJI_FM_PLAN_MAINT_T_PVT.CREATE_WBSRLP;
   print_time('WBS rollup done.');

   PJI_FM_PLAN_MAINT_T_PVT.UPDATE_WBS_HDR;
   print_time('Updated the WBS header table with min max txn dates.');

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRI_SLICE_CREATE_T');
    RAISE;
END;



--
-- With data in ver3 table and pjp1 tables,
--  create rollup slices and insert into RL fact.
--
PROCEDURE SEC_SLICE_CREATE_T IS

l_time_phase_flag varchar2(2);  /* Added for bug 8708651 */

BEGIN

   --------------------------------
   -- Header table population.
   --------------------------------

   PJI_FM_PLAN_MAINT_T_PVT.POPULATE_RBS_HDR;
   print_time('Populated new records into RBS Header Table.');

   PJI_FM_PLAN_MAINT_T_PVT.POPULATE_WBS_HDR;
   print_time('Populated new records into WBS Header Table.');

   PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_PLAN_AMTS_PRIRBS_GLC12;
   print_time(' Extracted plan data for primary RBSes.');

   PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_PLAN_AMTS_SECRBS_GLC12;
   print_time(' Extracted plan data for secondary RBSes.');

   --
   -- Prorate
   --  1. GL cal and Non time phased entries into PA cal.
   --  2. PA cal and Non time phased entries into GL cal.
   --  3. PA, GL cals and Non time phased entries into Ent cal.
   --
   /* Added for bug 8708651 */
   l_time_phase_flag := PJI_UTILS.GET_SETUP_PARAMETER('TIME_PHASE_FLAG');

   if l_time_phase_flag = 'Y' then
      null;
   else
      PJI_FM_PLAN_MAINT_T_PVT.PRORATE_TO_ALL_CALENDARS;
      print_time(' Prorated to all calendars. ');
   end if;
   /* Added for bug 8708651 */

   --------------------------------
   -- Time rollups.
   --------------------------------

   PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_PA_PRI_ROLLUP;
   PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_GL_PRI_ROLLUP;
   PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_ENT_ROLLUP;
   PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_ALL_T_PRI_ROLLUP(p_calendar_type => NULL); /* Modified for bug 9067086 */
   print_time(' Time rollups done. ');


   --------------------------------
   -- RBS/WBS/Program rollups.
   --------------------------------

   PJI_FM_PLAN_MAINT_T_PVT.ROLLUP_FPR_RBS_T_SLICE;
   print_time(' RBS rollups done. ');

   PJI_FM_PLAN_MAINT_T_PVT.CREATE_WBSRLP;
   print_time(' WBS rollups done. ');

   PJI_FM_PLAN_MAINT_T_PVT.UPDATE_WBS_HDR;
   print_time('Updated the WBS header table with min max txn dates.');

EXCEPTION
  WHEN OTHERS THEN
    print_time(' SEC_SLICE_CREATE_T  exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'SEC_SLICE_CREATE_T');
    RAISE;
END;


PROCEDURE CHECK_PRIMARY_ALREADY_EXISTS (
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_is_primary_rbs    IN   VARCHAR2
, x_return_status     OUT NOCOPY   VARCHAR2 ) IS
  i             NUMBER;
  l_project_id  NUMBER;
  excp_plan_already_summarized EXCEPTION;
  PRAGMA EXCEPTION_INIT(excp_plan_already_summarized, -1422);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN p_fp_version_ids.FIRST..p_fp_version_ids.LAST LOOP

      print_time('plan version id.. ' || p_fp_version_ids(i) );

        BEGIN

        SELECT /*+ index_ffs(wbs_hdr PJI_PJP_WBS_HEADER_N1) */
               DISTINCT PROJECT_ID
        INTO l_project_id
        FROM pji_pjp_wbs_header wbs_hdr
        WHERE plan_version_id = p_fp_version_ids(i);

          IF (p_is_primary_rbs = 'T') THEN
          RAISE excp_plan_already_summarized;
        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND
            THEN NULL;
        END;

  END LOOP;

EXCEPTION
  WHEN excp_plan_already_summarized THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    print_time(' CHECK_PRIMARY_ALREADY_EXISTS exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CHECK_PRIMARY_ALREADY_EXISTS');
    RAISE;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    print_time(' SEC_SLICE_CREATE_T  exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CHECK_PRIMARY_ALREADY_EXISTS');
    RAISE;
END;

--
-- Performance fix: To avoid re-populating pa/pji denorm tables if
--   denorm definition already exists, function checks if denorm definition
--   exists.
--
PROCEDURE DENORM_DEFINITION_EXISTS(
  p_tar_wbs_version_id_tbl         IN          SYSTEM.pa_num_tbl_type         := pji_empty_num_tbl
, x_tar_denorm_not_exists_tbl      OUT NOCOPY  SYSTEM.pa_num_tbl_type
) IS

  CURSOR c_wbs_vers_exist IS
  SELECT DISTINCT wbs_struct_version_id
  FROM pji_fm_extr_plnver3_t ver3
  WHERE EXISTS (
    SELECT /*+ no_unnest */ 1 -- bug 7607077 asahoo - replaced index hint
    FROM pa_xbs_denorm pxd
    WHERE 1=1
      AND struct_version_id IS NULL
      AND sup_id = ver3.wbs_struct_version_id
      );

  l_tar_wbs_ver_id_tbl        SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_tar_denorm_not_exists_tbl SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_tar_wbs_ver_id1           NUMBER;
  l_tar_wbs_ver_id2           NUMBER;

BEGIN

  print_time(' begin list of all dest wbs version ids.. ' );
  FOR i IN 1..p_tar_wbs_version_id_tbl.COUNT LOOP
    print_time(' i = ' || i || ' ' || p_tar_wbs_version_id_tbl(i));
  END LOOP;
  print_time(' end list of all dest wbs version ids.. ' );


  IF (c_wbs_vers_exist%isopen) THEN
    CLOSE c_wbs_vers_exist;
  END IF;

  -- l_tar_wbs_ver_id_tbl.EXTEND(p_tar_wbs_version_id_tbl.COUNT);

  OPEN c_wbs_vers_exist;
  FETCH c_wbs_vers_exist
  BULK COLLECT
  INTO l_tar_wbs_ver_id_tbl;
  CLOSE c_wbs_vers_exist;

  print_time(' begin list of wbs version ids with denorm already populated.. ' );
  FOR i IN 1..l_tar_wbs_ver_id_tbl.COUNT LOOP
    print_time(' i = ' || i || ' ' || l_tar_wbs_ver_id_tbl(i));
  END LOOP;
  print_time(' end list of wbs version ids with denorm already populated.. ' );

  print_time( ' p_tar_wbs_version_id_tbl.COUNT ' || p_tar_wbs_version_id_tbl.COUNT );
  print_time( ' l_tar_wbs_ver_id_tbl.COUNT ' || l_tar_wbs_ver_id_tbl.COUNT );

  <<i_loop>>
  FOR i IN 1..p_tar_wbs_version_id_tbl.COUNT LOOP
    -- print_time( ' p_tar_wbs_version_id_tbl.(i) ' || p_tar_wbs_version_id_tbl(i) );

    l_tar_wbs_ver_id1 := p_tar_wbs_version_id_tbl(i);
    l_tar_wbs_ver_id2 := -99999999;

    <<j_loop>>
    FOR j IN 1..l_tar_wbs_ver_id_tbl.COUNT LOOP

	  l_tar_wbs_ver_id2 := l_tar_wbs_ver_id_tbl(j);
      -- print_time( ' p_tar_wbs_version_id_tbl(i) ' || p_tar_wbs_version_id_tbl(i) );
      -- print_time( ' l_tar_wbs_ver_id_tbl(j) ' || l_tar_wbs_ver_id_tbl(j) );
      -- print_time( ' l_tar_wbs_ver_id1 ' || l_tar_wbs_ver_id1 );
      -- print_time( ' l_tar_wbs_ver_id2 ' || l_tar_wbs_ver_id2 );

      IF ( l_tar_wbs_ver_id1 = l_tar_wbs_ver_id2 ) THEN
        EXIT j_loop;
      END IF;
    END LOOP;

    IF (  l_tar_wbs_ver_id1 <> l_tar_wbs_ver_id2 ) THEN
      l_tar_denorm_not_exists_tbl.EXTEND;
      l_tar_denorm_not_exists_tbl(l_tar_denorm_not_exists_tbl.COUNT) := l_tar_wbs_ver_id1;
    END IF;

  END LOOP;

  print_time(' begin list of wbs version ids without denorm populated ' );
  FOR i IN 1..l_tar_denorm_not_exists_tbl.COUNT LOOP
    print_time(' i = ' || i || ' ' || l_tar_denorm_not_exists_tbl(i));
  END LOOP;
  print_time(' end list of wbs version ids without denorm populated ' );

  x_tar_denorm_not_exists_tbl := l_tar_denorm_not_exists_tbl;

EXCEPTION
  WHEN OTHERS THEN
    print_time(' DENORM_DEFINITION_EXISTS  exception ' || SQLERRM );
    IF (c_wbs_vers_exist%isopen) THEN
      CLOSE c_wbs_vers_exist;
    END IF;
    Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DENORM_DEFINITION_EXISTS');
    RAISE;
END;
--
-- Populate wbs denorm table for plan create case.
--
PROCEDURE POPULATE_WBS_DENORM(
  p_online            IN   VARCHAR2 := 'Y'
, p_tar_denorm_not_exists_tbl  IN   SYSTEM.pa_num_tbl_type  := pji_empty_num_tbl
, x_return_status              OUT NOCOPY   VARCHAR2
) IS

  CURSOR c_wbs_struct_ver_id_online (
    p_wbs_version_id NUMBER
  ) IS
  SELECT DISTINCT wbs_struct_version_id, project_id
  FROM   pji_fm_extr_plnver3_t
  WHERE  wbs_struct_version_id = p_wbs_version_id;

  -- CURSOR c_wbs_struct_ver_id_bulk IS
  -- SELECT wbs_struct_version_id, project_id
  -- FROM   pji_fm_extr_plnver4
  -- WHERE  worker_id = g_worker_id;

BEGIN

  x_return_status := 'S';

  IF (p_online = 'Y') THEN

    ------------------------------------------------------------------
    --Below code is commented out for publish performance fixes
    -------------------------------------------------------------------
    /*
    Bug 4075697:
       Below code is added to avoid changes to PA/PJI xbs denorm tables
       during copy/move/indent/outdent flows during plan update
       Structure changes will get processed in process updates flow
    IF NVL(Pa_Task_Pub1.G_CALL_PJI_ROLLUP, 'Y') = 'N' THEN
      Pa_Task_Pub1.G_CALL_PJI_ROLLUP := NULL;
      RETURN;
    END IF;
    */

    IF (p_tar_denorm_not_exists_tbl.COUNT = 0) THEN
	  print_time(' All denorm definitions alreadey exist, need not be created again.' );
	  RETURN;
    ELSE
	  print_time(' ----------- Begin denorm population..' );
    END IF;

    --IF c_wbs_struct_ver_id_online%ISOPEN THEN CLOSE c_wbs_struct_ver_id_online; END IF;

    --FOR j IN c_wbs_struct_ver_id_online LOOP
    FOR i IN 1..p_tar_denorm_not_exists_tbl.COUNT LOOP

      print_time(' i = ' || i || ' wbs_version_id = ' || p_tar_denorm_not_exists_tbl(i));

      FOR j IN c_wbs_struct_ver_id_online(
	             p_wbs_version_id => p_tar_denorm_not_exists_tbl(i)
			   ) LOOP

        print_time('project_id = ' || j.project_id);
        print_time('wbs_version_id = ' || j.wbs_struct_version_id);

        Pji_Pjp_Sum_Rollup.set_online_context (
         p_event_id              => NULL,
         p_project_id            => j.project_id,
         p_plan_type_id          => NULL,
         p_old_baselined_version => NULL,
         p_new_baselined_version => NULL,
         p_old_original_version  => NULL,
         p_new_original_version  => NULL,
         p_old_struct_version    => NULL,
         p_new_struct_version    => j.wbs_struct_version_id );

        print_time(' row cnt after online context setting ' || SQL%ROWCOUNT );

        Pji_Pjp_Sum_Denorm.populate_xbs_denorm(
          p_worker_id      => 1,
          p_denorm_type    => 'WBS',
          p_wbs_version_id => j.wbs_struct_version_id,
          p_prg_group1     => NULL,
          p_prg_group2     => NULL
          );

        print_time(' row cnt after populating xbs denorm ' || SQL%ROWCOUNT );

        Pji_Pjp_Sum_Rollup.update_xbs_denorm;

        print_time(' row cnt after updating xbs denorm ' || SQL%ROWCOUNT );

        Pji_Pjp_Sum_Denorm.cleanup_xbs_denorm(
            p_worker_id                 => 1
        , p_extraction_type     => 'ONLINE');

        print_time(' row cnt after cleaning up xbs denorm ' || SQL%ROWCOUNT );

      END LOOP;

    END LOOP;

  print_time(' ----------- End denorm population..' );

  ELSE
    RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_wbs_struct_ver_id_online%ISOPEN THEN CLOSE c_wbs_struct_ver_id_online; END IF;
    --IF c_wbs_struct_ver_id_bulk%ISOPEN THEN CLOSE c_wbs_struct_ver_id_bulk; END IF;
    x_return_status := 'F';
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_WBS_DENORM');
    RAISE;

END;


-----------------------------------------------------------------------
----- Partial refresh of plan data...                                           -----
-- PR can be either for a given plan type or a given rbs version id.
-----------------------------------------------------------------------
PROCEDURE PULL_PLANS_FOR_PR (
  p_rbs_version_id  IN NUMBER
, p_plan_type_id    IN NUMBER
, p_context         IN VARCHAR2      -- Valid values are 'RBS' or 'PLANTYPE'.
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_code        OUT NOCOPY  VARCHAR2 ) IS
  l_count      NUMBER;
  l_num_rows   NUMBER := 0;
  l_time_phase_flag varchar2(2);  /* Added for bug 8708651 */
BEGIN

  print_time(' PULL_PLANS_FOR_PR : begin.. ');


  PJI_PJP_FP_CURR_WRAP.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  print_time(' PULL_PLANS_FOR_PR value of p_plan_type_id is ' || p_plan_type_id || ' and p_rbs_version_id is ' || p_rbs_version_id );


  PJI_FM_PLAN_MAINT_PVT.VALIDATE_SET_PR_PARAMS(
    p_rbs_version_id  => p_rbs_version_id
  , p_plan_type_id    => p_plan_type_id
  , p_context         => p_context
  , x_num_rows        => l_num_rows
  , x_return_status   => x_return_status
  , x_msg_code        => x_msg_code) ;

  IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    print_time(' PULL_PLANS_FOR_PR input parameters did not validate. Exitting.');
    RETURN;
  ELSIF (l_num_rows = 0) THEN
    print_time ( 'GET_ACTUALS_SUMM : no rows in ver3 to process, RETURNING.' );
    RETURN;
  END IF;


  Pji_Fm_Plan_Maint_Pvt.POPULATE_RBS_HDR;
  print_time('Populated new records into RBS Header Table.');

  -- Retrieve overridden ETC values for latest published WP structures in budget lines table.
  -- PJI_FM_PLAN_MAINT_PVT.RETRIEVE_OVERRIDDEN_WP_ETC;
  print_time('Retrieved overridden ETC values.');

  -- Pull primary slice for workplans and relevant fin plans.
  -- Do not pull actuals/overriddend ETC values, they are extracted in "get plan res actuals" flow.
  PJI_FM_PLAN_MAINT_PVT.EXTRACT_PLAN_ETC_PRIRBS ;
  print_time('Extracted workplan data.');

  -- Plan lines for ETCs are populated in get plan res actuals flow.
  --  PJI_FM_PLAN_MAINT_PVT.DELETE_PLAN_LINES ( x_return_status => x_return_status );
  -- print_time('Delete processed plan lines.');

  PJI_FM_PLAN_MAINT_PVT.GET_GLOBAL_EXCHANGE_RATES;
  print_time(' Got global exchange rates. ');

  PJI_FM_PLAN_MAINT_PVT.EXTRACT_PLAN_AMTS_PRIRBS_GLC12
  (p_pull_dangling_flag => 'N');
  print_time('Extracted finplan data for pri RBS for secondary currencies as well.');

  PJI_FM_PLAN_MAINT_PVT.EXTRACT_PLAN_AMTS_SECRBS_GLC12
  (p_pull_dangling_flag => 'N');
  print_time('Extracted finplan data for Secondary RBS for secondary currencies as well.');

   /* Added for bug 8708651 */
   l_time_phase_flag := PJI_UTILS.GET_SETUP_PARAMETER('TIME_PHASE_FLAG');

   if l_time_phase_flag = 'Y' then
      null;
   else
      PJI_FM_PLAN_MAINT_PVT.PRORATE_TO_ALL_CALENDARS ;
      print_time('Prorated Fin plan data to all calendars.');
   end if;
   /* Added for bug 8708651 */
  --
  -- All rollups are done for plans along with actuals from the calling
  --   concurrent program in the following steps.
  --

  print_time('CREATE_PRIMARY_PVT 2 : end.. ');

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => ' PULL_PLANS_FOR_PR '
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


---------------------------------------------------------
----- Full and Incr summarization of actuals ...    -----
---------------------------------------------------------

PROCEDURE GET_ACTUALS_SUMM (
  p_extr_type       IN VARCHAR2    -- Valid values are 'FULL' and 'INCREMENTAL'.
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_code        OUT NOCOPY  VARCHAR2 ) IS

  l_num_rows   NUMBER := 0;

BEGIN

  print_time('GET_ACTUALS_SUMM : start.. ');

  print_time ( 'GET_ACTUALS_SUMM : extrn type is: ' || NVL(p_extr_type, 'AA'));

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status ) ;

  g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  print_time ( ' p_extr_type = ' || p_extr_type || ' g_worker_id = ' || g_worker_id );

  IF (p_extr_type NOT IN ('FULL', 'INCREMENTAL')) THEN
    print_time ( ' p_extr_type value ' || p_extr_type || ' is not valid. ');
    RETURN;
  END IF;


  -- Record plan lines into debug tables.
  Pji_Fm_Xbs_Accum_Maint.debug_plan_lines;


  -- Populate ver3 table.
  PJI_FM_PLAN_MAINT_PVT.VALIDATE_SET_PR_PARAMS(
    p_rbs_version_id  => NULL
  , p_plan_type_id    => NULL
  , p_context         => p_extr_type
  , x_num_rows        => l_num_rows
  , x_return_status   => x_return_status
  , x_msg_code        => x_msg_code) ;


  IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    print_time(' PULL_PLANS_FOR_PR input parameters did not validate. Exitting.');
    RETURN;
  ELSIF (l_num_rows = 0) THEN
    print_time ( 'GET_ACTUALS_SUMM : no rows in ver3 to process, RETURNING.' );
    RETURN;
  END IF;


  Pji_Fm_Plan_Maint_Pvt.POPULATE_RBS_HDR;
  print_time('Populated new records into RBS Header Table.');


  -- Extract actuals from budget lines for FULL summarization.
  pji_fm_plan_maint_pvt.EXTRACT_ACTUALS(
    p_extrn_type => p_extr_type
  );
  print_time('Actuals/etc extraction.');

  --
  -- WBS and RBS headers will be populated in PROCESS_PENDING_PLAN_UPDATES
  --

  --PJI_FM_PLAN_MAINT_PVT.DELETE_PLAN_LINES ( x_return_status => x_return_status );
  --print_time('Delete processed plan lines for this worker id.');

  --
  -- All rollups are done for plans along with actuals from the calling
  --   concurrent program in the following steps.
  --

  print_time('GET_ACTUALS_SUMM : end.. ');

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'GET_ACTUALS_SUMM'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


FUNCTION CHECK_VER3_NOT_EMPTY ( p_online IN VARCHAR2 := 'T')  -- Valid values T/F
RETURN VARCHAR2 IS
  l_count NUMBER;
  l_return_status VARCHAR2(1);
BEGIN

  IF (p_online = 'T') THEN
    SELECT COUNT(1)
    INTO   l_count
    FROM   pji_fm_extr_plnver3_t;
  ELSE
    SELECT COUNT(1)
    INTO   l_count
    FROM   pji_fm_extr_plnver4
    WHERE  worker_id = g_worker_id;
  END IF;

  print_time ( ' ver3 table has ' || l_count || ' records. ');

  IF (l_count > 0) THEN
    RETURN 'T';
  ELSE
    print_time ( ' # rcds in ver3 is 0, returning from this procedure.... ' );
    RETURN 'F';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'CHECK_VER3_NOT_EMPTY'
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


--
-- Contains apis to set online context to perform WBS rollups
--   if WBS changes (changes to structure) have been made.
--
PROCEDURE WBSCHANGEPROC_PRERLP_SETUPS IS

  l_project_id              NUMBER;
  l_plan_version_id         NUMBER;
  l_wbs_version_id          NUMBER;
  l_request_id              pa_proj_elem_ver_structure.conc_request_id%TYPE;

BEGIN

  -- Fix for bug : 4027718
  BEGIN

    SELECT a.process_update_wbs_flag, a.element_version_id
         , a.project_id, b.plan_version_id
    INTO   g_process_update_wbs_flag, l_wbs_version_id
         , l_project_id, l_plan_version_id
    FROM pa_proj_elem_ver_structure a ,
         PJI_FM_EXTR_PLNVER3_T b
    WHERE a.element_version_id = b.wbs_struct_version_id
      AND a.project_id = b.project_id -- 4902584
      AND ROWNUM <= 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE ;
  END ;

  --
  -- Process structure changes if dirty flag is set to 'Y'.
  --
  IF g_process_update_wbs_flag = 'Y' THEN

    --
    -- Create an event..
    --
    g_event_rec.event_type := 'WBS_CHANGE';
    g_event_rec.event_object := l_wbs_version_id;
    g_event_rec.operation_type := 'I';
    g_event_rec.status := 'X';
    g_event_rec.attribute1 := l_project_id;
    g_event_rec.attribute2 := l_wbs_version_id;
    g_event_rec.attribute3 := l_plan_version_id;

    PJI_FM_XBS_ACCUM_MAINT.CREATE_EVENT(g_event_rec);

    Pji_Pjp_Sum_Denorm.populate_xbs_denorm(
     p_worker_id      => 1,
     p_denorm_type    => 'WBS',
     p_wbs_version_id => l_wbs_version_id,
     p_prg_group1     => NULL,
     p_prg_group2     => NULL
    );
    print_time(' PA denorm table data created. ');

    Pji_Pjp_Sum_Rollup.set_online_context (
     p_event_id              => g_event_rec.event_id,
     p_project_id            => l_project_id,
     p_plan_type_id          => NULL,
     p_old_baselined_version => NULL,
     p_new_baselined_version => NULL,
     p_old_original_version  => NULL,
     p_new_original_version  => NULL,
     p_old_struct_version    => l_wbs_version_id,
     p_new_struct_version    => l_wbs_version_id
    );

    Pji_Pjp_Sum_Rollup.populate_xbs_denorm_delta;
    print_time(' PA denorm delta table data created. ');

  END IF;

END;


--
-- Contains cleanup logic after performing WBS rollups if WBS
--   changes (changes to structure) have been made.
--
PROCEDURE WBSCHANGEPROC_POSTRLP_CLEANUP IS
  l_return_status           VARCHAR2(300);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(100);
BEGIN

  IF g_process_update_wbs_flag = 'Y' THEN

    Pji_Pjp_Sum_Rollup.rollup_acr_wbs;
    print_time(' Did AC lines rollup. ');

    Pji_Pjp_Sum_Rollup.update_xbs_denorm;
    print_time(' Updated PJI xbs denorm. ');

    Pji_Pjp_Sum_Denorm.cleanup_xbs_denorm(
      p_worker_id          => 1
    , p_extraction_type    => 'ONLINE');
    print_time(' Cleaned up xbs delta denorm. ');

    Pji_Fm_Plan_Maint_T_Pvt.MERGE_INTO_AC_FACT;
    print_time(' Merged into AC fact. ');


    /*
    Pa_Proj_Task_Struc_Pub.set_update_wbs_flag (
      p_project_id            => TO_NUMBER(g_event_rec.attribute1),
      p_structure_version_id  => TO_NUMBER(g_event_rec.attribute2),
      p_update_wbs_flag       => 'N',
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data );
    print_time(' Reset dirty flag to No. ');
    */
/* 	5138049 as update by MAANSARI
    Pa_Proj_Task_Struc_Pub.process_task_weightage (
      p_project_id            => TO_NUMBER(g_event_rec.attribute1),
      p_structure_version_id  => TO_NUMBER(g_event_rec.attribute2),
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data );
*/
    DELETE FROM PA_PJI_PROJ_EVENTS_LOG
    WHERE EVENT_ID = g_event_rec.event_id;

  END IF;

END;

  -- -----------------------------------------------------
  -- procedure POPULATE_FIN8
  --
  --   History
  --   16-JUN-2005  ANAGARAT  Created
  --
  --    This procedure populates PJI_FM_AGGR_FIN8 table
  --    for PJI_FM_XBA_ACCUM_UTILS.get_summarized_data () api
  -- -----------------------------------------------------

PROCEDURE POPULATE_FIN8 (p_worker_id IN NUMBER
	    , p_extraction_type     IN	VARCHAR2
            ,x_return_status OUT NOCOPY VARCHAR2
            ,x_msg_data      OUT NOCOPY VARCHAR2 ) IS
  BEGIN

        print_time('POPULATE_FIN8 : start.. ');

          Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
          ( p_package_name   => g_package_name
          , x_return_status  => x_return_status ) ;


 IF (p_worker_id IS NOT NULL) THEN

	IF ( p_extraction_type='INCREMENTAL' ) THEN

        INSERT INTO  pji_fm_aggr_fin8
(
        WORKER_ID                  ,    RECORD_TYPE                ,    TXN_ACCUM_HEADER_ID        ,
        RESOURCE_CLASS_ID          ,    PROJECT_ID                 ,    PROJECT_ORG_ID             ,
        PROJECT_ORGANIZATION_ID    ,    PROJECT_TYPE_CLASS         ,    TASK_ID                    ,
        RECVR_PERIOD_TYPE          ,    RECVR_PERIOD_ID            ,    TXN_CURRENCY_CODE          ,
        TXN_REVENUE                ,    TXN_RAW_COST               ,    TXN_BRDN_COST              ,
        TXN_BILL_RAW_COST          ,    TXN_BILL_BRDN_COST         ,    TXN_SUP_INV_COMMITTED_COST ,
        TXN_PO_COMMITTED_COST      ,    TXN_PR_COMMITTED_COST      ,    TXN_OTH_COMMITTED_COST     ,
        PRJ_REVENUE                ,    PRJ_RAW_COST               ,    PRJ_BRDN_COST              ,
        PRJ_BILL_RAW_COST          ,    PRJ_BILL_BRDN_COST         ,    PRJ_REVENUE_WRITEOFF       ,
        PRJ_SUP_INV_COMMITTED_COST ,    PRJ_PO_COMMITTED_COST      ,    PRJ_PR_COMMITTED_COST      ,
        PRJ_OTH_COMMITTED_COST     ,    POU_REVENUE                ,    POU_RAW_COST               ,
        POU_BRDN_COST              ,    POU_BILL_RAW_COST          ,    POU_BILL_BRDN_COST         ,
        POU_REVENUE_WRITEOFF       ,    POU_SUP_INV_COMMITTED_COST ,    POU_PO_COMMITTED_COST      ,
        POU_PR_COMMITTED_COST      ,    POU_OTH_COMMITTED_COST     ,    EOU_REVENUE                ,
        EOU_RAW_COST               ,    EOU_BRDN_COST              ,    EOU_BILL_RAW_COST          ,
        EOU_BILL_BRDN_COST         ,    EOU_SUP_INV_COMMITTED_COST ,    EOU_PO_COMMITTED_COST      ,
        EOU_PR_COMMITTED_COST      ,    EOU_OTH_COMMITTED_COST     ,    QUANTITY                   ,
        BILL_QUANTITY              ,    G1_REVENUE                 ,    G1_RAW_COST                ,
        G1_BRDN_COST               ,    G1_BILL_RAW_COST           ,    G1_BILL_BRDN_COST          ,
        G1_REVENUE_WRITEOFF        ,    G1_SUP_INV_COMMITTED_COST  ,    G1_PO_COMMITTED_COST       ,
        G1_PR_COMMITTED_COST       ,    G1_OTH_COMMITTED_COST      ,    G2_REVENUE                 ,
        G2_RAW_COST                ,    G2_BRDN_COST               ,    G2_BILL_RAW_COST           ,
        G2_BILL_BRDN_COST          ,    G2_REVENUE_WRITEOFF        ,    G2_SUP_INV_COMMITTED_COST  ,
        G2_PO_COMMITTED_COST       ,    G2_PR_COMMITTED_COST       ,    G2_OTH_COMMITTED_COST      ,
        ASSIGNMENT_ID,	NAMED_ROLE		--Bug#4590810
)
SELECT
        tmp.WORKER_ID                  ,        RECORD_TYPE                ,    TXN_ACCUM_HEADER_ID        ,
        RESOURCE_CLASS_ID          ,    tmp.PROJECT_ID                 ,        tmp.PROJECT_ORG_ID             ,
        tmp.PROJECT_ORGANIZATION_ID    ,        tmp.PROJECT_TYPE_CLASS         ,        TASK_ID                    ,
        RECVR_PERIOD_TYPE          ,    RECVR_PERIOD_ID            ,    TXN_CURRENCY_CODE          ,
        TXN_REVENUE                ,    TXN_RAW_COST               ,    TXN_BRDN_COST              ,
        TXN_BILL_RAW_COST          ,    TXN_BILL_BRDN_COST         ,    TXN_SUP_INV_COMMITTED_COST ,
        TXN_PO_COMMITTED_COST      ,    TXN_PR_COMMITTED_COST      ,    TXN_OTH_COMMITTED_COST     ,
        PRJ_REVENUE                ,    PRJ_RAW_COST               ,    PRJ_BRDN_COST              ,
        PRJ_BILL_RAW_COST          ,    PRJ_BILL_BRDN_COST         ,    PRJ_REVENUE_WRITEOFF       ,
        PRJ_SUP_INV_COMMITTED_COST ,    PRJ_PO_COMMITTED_COST      ,    PRJ_PR_COMMITTED_COST      ,
        PRJ_OTH_COMMITTED_COST     ,    POU_REVENUE                ,    POU_RAW_COST               ,
        POU_BRDN_COST              ,    POU_BILL_RAW_COST          ,    POU_BILL_BRDN_COST         ,
        POU_REVENUE_WRITEOFF       ,    POU_SUP_INV_COMMITTED_COST ,    POU_PO_COMMITTED_COST      ,
        POU_PR_COMMITTED_COST      ,    POU_OTH_COMMITTED_COST     ,    EOU_REVENUE                ,
        EOU_RAW_COST               ,    EOU_BRDN_COST              ,    EOU_BILL_RAW_COST          ,
        EOU_BILL_BRDN_COST         ,    EOU_SUP_INV_COMMITTED_COST ,    EOU_PO_COMMITTED_COST      ,
        EOU_PR_COMMITTED_COST      ,    EOU_OTH_COMMITTED_COST     ,    QUANTITY                   ,
        BILL_QUANTITY              ,    G1_REVENUE                 ,    G1_RAW_COST                ,
        G1_BRDN_COST               ,    G1_BILL_RAW_COST           ,    G1_BILL_BRDN_COST          ,
        G1_REVENUE_WRITEOFF        ,    G1_SUP_INV_COMMITTED_COST  ,    G1_PO_COMMITTED_COST       ,
        G1_PR_COMMITTED_COST       ,    G1_OTH_COMMITTED_COST      ,    G2_REVENUE                 ,
        G2_RAW_COST                ,    G2_BRDN_COST               ,    G2_BILL_RAW_COST           ,
        G2_BILL_BRDN_COST          ,    G2_REVENUE_WRITEOFF        ,    G2_SUP_INV_COMMITTED_COST  ,
        G2_PO_COMMITTED_COST       ,    G2_PR_COMMITTED_COST       ,    G2_OTH_COMMITTED_COST      ,
        ASSIGNMENT_ID	,	NAMED_ROLE		--Bug#4590810
FROM          pji_fm_aggr_fin7 tmp
             ,PJI_PJP_PROJ_BATCH_MAP map
	     ,pa_proj_fp_options ppfo
WHERE
                tmp.PROJECT_ID=map.PROJECT_ID AND
                map.WORKER_ID =  p_worker_id AND
                map.PJI_PROJECT_STATUS = 'Y' AND
		ppfo.PROJECT_ID=tmp.PROJECT_ID AND
		SUBSTR(tmp.RECVR_PERIOD_TYPE,1,1) = DECODE (ppfo.COST_TIME_PHASED_CODE,'N','G',ppfo.COST_TIME_PHASED_CODE) AND
		ppfo.FIN_PLAN_TYPE_ID = (
			SELECT fin_plan_type_id
			FROM pa_fin_plan_types_b
			WHERE use_for_workplan_flag = 'Y'
  					) AND
		ppfo.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_TYPE';

	ELSE

	INSERT INTO  pji_fm_aggr_fin8
(
        TXN_ACCUM_HEADER_ID        ,    RESOURCE_CLASS_ID          ,    PROJECT_ID                 ,
	PROJECT_ORG_ID             ,    PROJECT_ORGANIZATION_ID    ,    PROJECT_TYPE_CLASS         ,
	TASK_ID                    ,    RECVR_PERIOD_TYPE          ,    RECVR_PERIOD_ID            ,
	TXN_CURRENCY_CODE          ,    TXN_REVENUE                ,    TXN_RAW_COST               ,
	TXN_BRDN_COST              ,    TXN_BILL_RAW_COST          ,    TXN_BILL_BRDN_COST         ,
        PRJ_REVENUE                ,    PRJ_RAW_COST               ,    PRJ_BRDN_COST              ,
        PRJ_BILL_RAW_COST          ,    PRJ_BILL_BRDN_COST         ,    POU_REVENUE                ,
	POU_RAW_COST               ,    POU_BRDN_COST              ,    POU_BILL_RAW_COST          ,
	POU_BILL_BRDN_COST         ,    EOU_RAW_COST               ,    EOU_BRDN_COST              ,
	EOU_BILL_RAW_COST          ,    EOU_BILL_BRDN_COST         ,    QUANTITY                   ,
        BILL_QUANTITY              ,    G1_REVENUE                 ,    G1_RAW_COST                ,
        G1_BRDN_COST               ,    G1_BILL_RAW_COST           ,    G1_BILL_BRDN_COST          ,
        G2_REVENUE                 ,    G2_RAW_COST                ,    G2_BRDN_COST               ,
	G2_BILL_RAW_COST           ,    G2_BILL_BRDN_COST          ,    ASSIGNMENT_ID		   ,
	WORKER_ID		   ,	RECORD_TYPE,		NAMED_ROLE		--Bug#4590810
)
SELECT
        TXN_ACCUM_HEADER_ID        ,    RESOURCE_CLASS_ID          ,    tmp.PROJECT_ID              ,
	tmp.PROJECT_ORG_ID         ,    tmp.PROJECT_ORGANIZATION_ID  ,        tmp.PROJECT_TYPE_CLASS         ,
	TASK_ID                    ,    RECVR_PERIOD_TYPE          ,    RECVR_PERIOD_ID            ,
	TXN_CURRENCY_CODE          ,    TXN_REVENUE                ,    TXN_RAW_COST               ,
	TXN_BRDN_COST              ,    TXN_BILL_RAW_COST          ,    TXN_BILL_BRDN_COST         ,
        PRJ_REVENUE                ,    PRJ_RAW_COST               ,    PRJ_BRDN_COST              ,
        PRJ_BILL_RAW_COST          ,    PRJ_BILL_BRDN_COST         ,    POU_REVENUE                ,
	POU_RAW_COST               ,    POU_BRDN_COST              ,    POU_BILL_RAW_COST          ,
	POU_BILL_BRDN_COST         ,    EOU_RAW_COST               ,    EOU_BRDN_COST              ,
	EOU_BILL_RAW_COST          ,    EOU_BILL_BRDN_COST         ,    QUANTITY                   ,
        BILL_QUANTITY              ,    G1_REVENUE                 ,    G1_RAW_COST                ,
        G1_BRDN_COST               ,    G1_BILL_RAW_COST           ,    G1_BILL_BRDN_COST          ,
        G2_REVENUE                 ,    G2_RAW_COST                ,    G2_BRDN_COST               ,
	G2_BILL_RAW_COST           ,    G2_BILL_BRDN_COST          ,    ASSIGNMENT_ID		   ,
	p_worker_id		   ,	'A'	,	NAMED_ROLE		--Bug#4590810
FROM          pji_fp_txn_accum tmp
             ,PJI_PJP_PROJ_BATCH_MAP map
	     ,pa_proj_fp_options ppfo
WHERE
                tmp.PROJECT_ID=map.PROJECT_ID AND
                map.WORKER_ID =  p_worker_id AND
                map.PJI_PROJECT_STATUS = 'Y' AND
		ppfo.PROJECT_ID=tmp.PROJECT_ID AND
		SUBSTR(tmp.RECVR_PERIOD_TYPE,1,1) = DECODE (ppfo.COST_TIME_PHASED_CODE,'N','G',ppfo.COST_TIME_PHASED_CODE) AND
		ppfo.FIN_PLAN_TYPE_ID = (
			SELECT fin_plan_type_id
			FROM pa_fin_plan_types_b
			WHERE use_for_workplan_flag = 'Y'
  					) AND
		ppfo.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_TYPE';


	END IF;
 END IF;

        print_time('POPULATE_FIN8 : end.. ');

 EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'POPULATE_FIN8'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;

----------
-- Print time API to measure time taken by each api. Also useful for debugging.
----------
PROCEDURE PRINT_TIME(
  p_tag                 IN   VARCHAR2
) IS
BEGIN
  PJI_PJP_FP_CURR_WRAP.print_time(p_tag);
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRINT_TIME');
    RAISE;
END;


END PJI_FM_PLAN_MAINT;

/
