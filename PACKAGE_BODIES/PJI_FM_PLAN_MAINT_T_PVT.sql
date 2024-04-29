--------------------------------------------------------
--  DDL for Package Body PJI_FM_PLAN_MAINT_T_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_PLAN_MAINT_T_PVT" AS
/* $Header: PJIPP03B.pls 120.19.12010000.5 2010/01/27 06:50:16 paljain ship $ */


  g_package_name VARCHAR2(100) := 'PJI_FM_PLAN_MAINT_T_PVT';

  g_prorating_format            VARCHAR2(30) := 'S';
                                -- S Start date, E End date, D (daily) Period.
                                -- Based on plan version.

  g_currency_conversion_rule   VARCHAR2(30) := 'S';
                                -- S Start date, E End date.
                                -- Based on plan version.

  g_global_curr_1_enabled       VARCHAR2(30) := 'T';
  g_global_curr_2_enabled       VARCHAR2(30) := 'T';

  g_global1_currency_code       VARCHAR2(30) := NULL; -- g_global1_currency_code;
  g_global2_currency_code       VARCHAR2(30) := NULL; -- 'CAD';

  g_global1_currency_mau        NUMBER := NULL; -- 0.01;
  g_global2_currency_mau        NUMBER := NULL; -- 0.01;

  g_labor_mau                   NUMBER := 0.01;

  g_ent_start_period_id         NUMBER        := NULL;
  g_ent_start_period_name       VARCHAR2(100) := NULL;
  g_ent_start_date              date := NULL;
  g_ent_END_date                date := NULL;
  g_global_start_date           date := NULL;

  g_global_start_J              NUMBER := NULL;
  g_ent_start_J                 NUMBER := NULL;
  g_ent_END_J                   NUMBER := NULL;

  g_worker_id                   NUMBER := 1; -- NULL;
  g_default_prg_level           NUMBER := 0;

  g_people_resclass_code        VARCHAR2(6) := 'PEOPLE';
  g_equip_resclass_code         VARCHAR2(9) := 'EQUIPMENT';

  g_start_str                   VARCHAR2(1) := 'S';
  g_end_str                     VARCHAR2(1) := 'E';
  g_pa_cal_str                  VARCHAR2(1) := 'P';
  g_gl_cal_str                  VARCHAR2(1) := 'G';
  -- 'N'ntimeph_str               VARCHAR2(1) := 'N';
  g_ent_cal_str                 VARCHAR2(1) := 'E';

  g_yes                         VARCHAR2(1) := 'Y';
  g_no                          VARCHAR2(1) := 'N';  -- Same as g_nontimeph_str.
  g_all                         VARCHAR2(1) := 'A';
  g_lowest_level                VARCHAR2(1) := 'L';
  g_top_level                   VARCHAR2(1) := 'T';
  g_rolled_up                   VARCHAR2(1) := 'R';

  g_all_timeph_code             VARCHAR2(3) := 'ALL';
  g_cost_timeph_code            VARCHAR2(4) := 'COST';
  g_rev_timeph_code             VARCHAR2(7) := 'REVENUE';

  g_ntp_period_name             VARCHAR2(10) := 'XXX';

------------------------------------------------------------------
------------------------------------------------------------------
--              Helper  Apis Specification                      --
------------------------------------------------------------------
------------------------------------------------------------------

PROCEDURE UPDATE_TPFG1_CURR_RCDS;

PROCEDURE CLEANUP_FP_RMAP_FPR;

PROCEDURE CLEANUP_AC_RMAP_FPR;

PROCEDURE PRINT_TIME (p_tag IN VARCHAR2);

PROCEDURE PRINT_NUM_WBSRLPRCDS_INPJP1;

PROCEDURE INSERT_NTP_CAL_RECORD ( x_max_plnver_id OUT NOCOPY  NUMBER );

PROCEDURE DELETE_NTP_CAL_RECORD ( p_max_plnver_id IN NUMBER );

------------------------------------------------------------------
------------------------------------------------------------------
--              Helper  Apis Implementation                     --
------------------------------------------------------------------
------------------------------------------------------------------

PROCEDURE COPY_PRIMARY
(
  p_source_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_dest_fp_version_ids      IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_source_fp_version_status IN   SYSTEM.pa_VARCHAR2_30_tbl_type := pji_empty_VARCHAR2_30_tbl
, p_dest_fp_version_status   IN   SYSTEM.pa_VARCHAR2_30_tbl_type := pji_empty_VARCHAR2_30_tbl
, p_commit                   IN   VARCHAR2 := 'F'
) IS

    l_dest_plan_type_ids   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl;
    l_dest_project_ids     SYSTEM.pa_num_tbl_type := pji_empty_num_tbl;
    l_src_count            NUMBER;
    l_dest_count           NUMBER;
    l_src_project_ids      SYSTEM.pa_num_tbl_type := pji_empty_num_tbl;

BEGIN

  l_src_count  := p_source_fp_version_ids.COUNT;
  l_dest_count := p_dest_fp_version_ids.COUNT;

  print_time ( ' l_src_count ' || l_src_count  || ' l_dest_count ' || l_dest_count );

  IF (l_src_count <> l_dest_count) THEN
    print_time(' l_src_count <> l_dest_count, returning. ');
    RETURN;
  ELSIF (l_src_count = 0 OR l_dest_count = 0) THEN
    print_time('Either or both of l_src_count or l_src_count are null, returning. ');
    RETURN;
  END IF;

  l_dest_project_ids.EXTEND(l_src_count);
  l_dest_plan_type_ids.EXTEND(l_src_count);
  l_src_project_ids.EXTEND(l_src_count);

    FOR i IN 1..l_src_count LOOP

      SELECT   fin_plan_type_id, project_id
          INTO   l_dest_plan_type_ids(i)
              ,l_dest_project_ids(i)
          FROM   pa_budget_versions
          WHERE  budget_version_id = p_dest_fp_version_ids(i);

      SELECT   project_id
        INTO   l_src_project_ids(i)
          FROM   pa_budget_versions
          WHERE  budget_version_id = p_source_fp_version_ids(i);

      print_time ( ' i = ' || i ) ;
      print_time ( 'Spvi= ' || p_source_fp_version_ids(i));
      print_time ( 'Dpvi= ' || p_dest_fp_version_ids(i));
      print_time ( 'Dpti= ' || l_dest_plan_type_ids(i));
      print_time ( 'Dpti= ' || l_src_project_ids(i));

    END LOOP;


    PJI_FM_PLAN_MAINT.DELETE_ALL_PVT (
      p_fp_version_ids    => p_dest_fp_version_ids
    , p_commit            => 'F');
    print_time('Deleted the fact data and related metadata for destination plan versions.');

    CLEANUP_INTERIM_TABLES;
    print_time(' Interim tables cleaned up. 0.01 .. ');

    EXTRACT_FIN_PLAN_VERSIONS(
      p_fp_version_ids    => p_dest_fp_version_ids
    , p_slice_type        => 'PRI'
    );
    print_time('Populated ver3 table.');


    FORALL I IN 1..p_source_fp_version_ids.COUNT
    INSERT INTO pji_fp_aggr_pjp1_t
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
         , CUSTOM1
         , CUSTOM2
         , CUSTOM3
         , CUSTOM4
         , CUSTOM5
         , CUSTOM6
         , CUSTOM7
         , CUSTOM8
         , CUSTOM9
         , CUSTOM10
         , CUSTOM11
         , CUSTOM12
         , CUSTOM13
         , CUSTOM14
         , CUSTOM15
         , PLAN_TYPE_CODE           /* 4471527 */
    )
    (  SELECT
           g_worker_id
         , l_dest_project_ids(i)
         , rl.PROJECT_ORG_ID
         , rl.PROJECT_ORGANIZATION_ID
         , rl.PROJECT_ELEMENT_ID
         , rl.TIME_ID
         , rl.PERIOD_TYPE_ID
         , rl.CALENDAR_TYPE
         , rl.RBS_AGGR_LEVEL
         , rl.WBS_ROLLUP_FLAG
         , rl.PRG_ROLLUP_FLAG
         , BITAND(rl.CURR_RECORD_TYPE_ID, 28)
         , rl.CURRENCY_CODE
         , rl.RBS_ELEMENT_ID
         , rl.RBS_VERSION_ID
         , p_dest_fp_version_ids(i)
         , l_dest_plan_type_ids(i)
         , rl.RAW_COST
         , rl.BRDN_COST
         , rl.REVENUE
         , rl.BILL_RAW_COST
         , rl.BILL_BRDN_COST
         , rl.BILL_LABOR_RAW_COST
         , rl.BILL_LABOR_BRDN_COST
         , rl.BILL_LABOR_HRS
         , rl.EQUIPMENT_RAW_COST
         , rl.EQUIPMENT_BRDN_COST
         , rl.CAPITALIZABLE_RAW_COST
         , rl.CAPITALIZABLE_BRDN_COST
         , rl.LABOR_RAW_COST
         , rl.LABOR_BRDN_COST
         , rl.LABOR_HRS
         , rl.LABOR_REVENUE
         , rl.EQUIPMENT_HOURS
         , rl.BILLABLE_EQUIPMENT_HOURS
         , rl.SUP_INV_COMMITTED_COST
         , rl.PO_COMMITTED_COST
         , rl.PR_COMMITTED_COST
         , rl.OTH_COMMITTED_COST
         , rl.ACT_LABOR_HRS
           , rl.ACT_EQUIP_HRS
           , rl.ACT_LABOR_BRDN_COST
           , rl.ACT_EQUIP_BRDN_COST
           , rl.ACT_BRDN_COST
           , rl.ACT_RAW_COST
           , rl.ACT_REVENUE
         , rl.ACT_LABOR_RAW_COST
         , rl.ACT_EQUIP_RAW_COST
           , rl.ETC_LABOR_HRS
           , rl.ETC_EQUIP_HRS
           , rl.ETC_LABOR_BRDN_COST
           , rl.ETC_EQUIP_BRDN_COST
           , rl.ETC_BRDN_COST
         , rl.ETC_RAW_COST
         , rl.ETC_LABOR_RAW_COST
         , rl.ETC_EQUIP_RAW_COST
         , rl.CUSTOM1
         , rl.CUSTOM2
         , rl.CUSTOM3
         , rl.CUSTOM4
         , rl.CUSTOM5
         , rl.CUSTOM6
         , rl.CUSTOM7
         , rl.CUSTOM8
         , rl.CUSTOM9
         , rl.CUSTOM10
         , rl.CUSTOM11
         , rl.CUSTOM12
         , rl.CUSTOM13
         , rl.CUSTOM14
         , rl.CUSTOM15
         , rl.PLAN_TYPE_CODE       /* 4471527 */
      FROM
           pji_fp_xbs_accum_f rl
         , pji_fm_extr_plnver3_t ver3
      WHERE 1=1
            AND rl.project_id            = l_src_project_ids(i)
            AND rl.plan_version_id       = p_source_fp_version_ids(i)
                AND rl.plan_type_code = ver3.plan_type_code    /* 4471527 */
          AND ( (rl.rbs_aggr_level     = 'T')
           OR (rl.rbs_aggr_level       = 'L' AND wbs_rollup_flag = 'N' ))
          AND BITAND(rl.CURR_RECORD_TYPE_ID, 28) > 0
          AND rl.calendar_type in (ver3.time_phased_type_code, 'A')
            AND ver3.plan_version_id     = p_dest_fp_version_ids(i)
        );

    print_time('# records in pjp1_t are ' || SQL%ROWCOUNT);

    POPULATE_WBS_HDR;          print_time(' 2.1 .. ');

    UPDATE_WBS_HDR;            print_time(' 2.11 .. ');

    POPULATE_RBS_HDR;          print_time(' 2.2 .. ');

    MERGE_INTO_FP_FACT;        print_time(' 2.01 .. ');

    CLEANUP_INTERIM_TABLES;    print_time(' 2.3 .. ');


    IF (p_commit = 'T') THEN
      COMMIT;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'COPY_PRIMARY');
    RAISE;
END;



PROCEDURE COPY_PLANS
(
  p_source_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_dest_fp_version_ids      IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_source_fp_version_status IN   SYSTEM.pa_VARCHAR2_30_tbl_type := pji_empty_VARCHAR2_30_tbl
, p_dest_fp_version_status   IN   SYSTEM.pa_VARCHAR2_30_tbl_type := pji_empty_VARCHAR2_30_tbl
, p_commit                   IN   VARCHAR2 := 'F'
) IS

    l_dest_plan_type_ids   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl;
    l_dest_project_ids     SYSTEM.pa_num_tbl_type := pji_empty_num_tbl;
    l_src_count            NUMBER;
    l_dest_count           NUMBER;

BEGIN

  l_src_count  := p_source_fp_version_ids.COUNT;
  l_dest_count := p_dest_fp_version_ids.COUNT;

  print_time ( ' l_src_count ' || l_src_count  || ' l_dest_count ' || l_dest_count );

  IF (l_src_count <> l_dest_count) THEN
    print_time(' l_src_count <> l_dest_count, returning. ');
    RETURN;
  ELSIF (l_src_count = 0 OR l_dest_count = 0) THEN
    print_time('Either or both of l_src_count or l_src_count are null, returning. ');
    RETURN;
  END IF;

  l_dest_project_ids.EXTEND(l_src_count);
  l_dest_plan_type_ids.EXTEND(l_dest_count);


  FOR i IN 1..p_source_fp_version_ids.COUNT LOOP
    SELECT fin_plan_type_id, project_id
    INTO   l_dest_plan_type_ids(i)
         , l_dest_project_ids(i)
    FROM   pa_budget_versions
    WHERE  budget_version_id = p_dest_fp_version_ids(i);

    print_time ( ' i = ' || i ) ;
    print_time ( 'Spvi= ' || p_source_fp_version_ids(i));
    print_time ( 'Dpvi= ' || p_dest_fp_version_ids(i));
    print_time ( 'Dpti= ' || l_dest_plan_type_ids(i));

  END LOOP;

  FORALL i IN 1..p_dest_fp_version_ids.COUNT
    DELETE FROM PJI_FP_XBS_ACCUM_F
    WHERE plan_version_id  = p_dest_fp_version_ids(i)
      AND project_id       = l_dest_project_ids(i);

  FORALL i IN 1..p_dest_fp_version_ids.COUNT
    DELETE FROM pji_rollup_level_status
    WHERE plan_version_id = p_dest_fp_version_ids(i);

  CLEANUP_INTERIM_TABLES;    print_time(' 2.3 .. ');

  FORALL I IN 1..p_source_fp_version_ids.COUNT
    INSERT INTO pji_fp_aggr_pjp1_t
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PLAN_TYPE_CODE        /* 4471527 */
    )
    (
     SELECT
       g_worker_id
         , rl.PROJECT_ID
     , rl.PROJECT_ORG_ID
     , rl.PROJECT_ORGANIZATION_ID
     , rl.PROJECT_ELEMENT_ID
     , rl.TIME_ID
     , rl.PERIOD_TYPE_ID
     , rl.CALENDAR_TYPE
     , rl.RBS_AGGR_LEVEL
     , rl.WBS_ROLLUP_FLAG
     , rl.PRG_ROLLUP_FLAG
     , rl.CURR_RECORD_TYPE_ID
     , rl.CURRENCY_CODE
     , rl.RBS_ELEMENT_ID
     , rl.RBS_VERSION_ID
     , p_dest_fp_version_ids(i)
     , l_dest_plan_type_ids(i)
     , rl.RAW_COST
     , rl.BRDN_COST
     , rl.REVENUE
     , rl.BILL_RAW_COST
     , rl.BILL_BRDN_COST
     , rl.BILL_LABOR_RAW_COST
     , rl.BILL_LABOR_BRDN_COST
     , rl.BILL_LABOR_HRS
     , rl.EQUIPMENT_RAW_COST
     , rl.EQUIPMENT_BRDN_COST
     , rl.CAPITALIZABLE_RAW_COST
     , rl.CAPITALIZABLE_BRDN_COST
     , rl.LABOR_RAW_COST
     , rl.LABOR_BRDN_COST
     , rl.LABOR_HRS
     , rl.LABOR_REVENUE
     , rl.EQUIPMENT_HOURS
     , rl.BILLABLE_EQUIPMENT_HOURS
     , rl.SUP_INV_COMMITTED_COST
     , rl.PO_COMMITTED_COST
     , rl.PR_COMMITTED_COST
     , rl.OTH_COMMITTED_COST
       , rl.ACT_LABOR_HRS
           , rl.ACT_EQUIP_HRS
           , rl.ACT_LABOR_BRDN_COST
           , rl.ACT_EQUIP_BRDN_COST
           , rl.ACT_BRDN_COST
           , rl.ACT_RAW_COST
           , rl.ACT_REVENUE
         , rl.ACT_LABOR_RAW_COST
         , rl.ACT_EQUIP_RAW_COST
           , rl.ETC_LABOR_HRS
           , rl.ETC_EQUIP_HRS
           , rl.ETC_LABOR_BRDN_COST
           , rl.ETC_EQUIP_BRDN_COST
           , rl.ETC_BRDN_COST
         , rl.ETC_RAW_COST
         , rl.ETC_LABOR_RAW_COST
         , rl.ETC_EQUIP_RAW_COST
     , rl.CUSTOM1
     , rl.CUSTOM2
     , rl.CUSTOM3
     , rl.CUSTOM4
     , rl.CUSTOM5
     , rl.CUSTOM6
     , rl.CUSTOM7
     , rl.CUSTOM8
     , rl.CUSTOM9
     , rl.CUSTOM10
     , rl.CUSTOM11
     , rl.CUSTOM12
     , rl.CUSTOM13
     , rl.CUSTOM14
     , rl.CUSTOM15
     , rl.PLAN_TYPE_CODE        /* 4471527 */
    FROM
         pji_fp_xbs_accum_f rl
    WHERE 1=1
         AND ( (rl.rbs_aggr_level = g_top_level) OR (rl.rbs_aggr_level = g_lowest_level AND wbs_rollup_flag = 'N' ))
       AND rl.plan_version_id = p_source_fp_version_ids(i));

    EXTRACT_FIN_PLAN_VERSIONS(
      p_fp_version_ids    => p_dest_fp_version_ids
    , p_slice_type        => 'PRI'
    );                        print_time(' 2.01 .. ');

    POPULATE_WBS_HDR;          print_time(' 2.1 .. ');

    UPDATE_WBS_HDR;            print_time(' 2.11 .. ');

    POPULATE_RBS_HDR;          print_time(' 2.2 .. ');

    MERGE_INTO_FP_FACT;

    CLEANUP_INTERIM_TABLES;    print_time(' 2.3 .. ');


    IF (p_commit = 'T') THEN
      COMMIT;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'COPY_PLANS');
    RAISE;
END;


PROCEDURE COPY_PRIMARY_SINGLE
(
  p_source_plan_ver_id  IN NUMBER := NULL
, p_target_plan_ver_id  IN NUMBER := NULL
, p_commit              IN VARCHAR2 := 'F') IS

    l_dest_fp_version_ids  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    l_dest_plan_type_id     NUMBER := NULL;
    l_dest_project_id       NUMBER := NULL;

BEGIN

    print_time ( ' COPY_PRIMARY_SINGLE api 001 ' || p_source_plan_ver_id || ' ' || p_target_plan_ver_id );

    SELECT fin_plan_type_id, project_id
    INTO   l_dest_plan_type_id, l_dest_project_id
    FROM   pa_budget_versions
    WHERE  budget_version_id = p_target_plan_ver_id;

    DELETE FROM PJI_FP_XBS_ACCUM_F
    WHERE plan_version_id  = p_target_plan_ver_id
      AND project_id       = l_dest_project_id;

    DELETE FROM pji_rollup_level_status
    WHERE plan_version_id = p_target_plan_ver_id;

    CLEANUP_INTERIM_TABLES;
    print_time(' 1.9 .. ');

    INSERT INTO pji_fp_aggr_pjp1_t
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PLAN_TYPE_CODE      /* 4471527 */
    )
    (
     SELECT
       g_worker_id
         , rl.PROJECT_ID
     , rl.PROJECT_ORG_ID
     , rl.PROJECT_ORGANIZATION_ID
     -- , rl.PARTITION_ID
     , rl.PROJECT_ELEMENT_ID
     , rl.TIME_ID
     , rl.PERIOD_TYPE_ID
     , rl.CALENDAR_TYPE
     , rl.RBS_AGGR_LEVEL
     , rl.WBS_ROLLUP_FLAG
     , rl.PRG_ROLLUP_FLAG
     , rl.CURR_RECORD_TYPE_ID
     , rl.CURRENCY_CODE
     , rl.RBS_ELEMENT_ID
     , rl.RBS_VERSION_ID
     , p_target_plan_ver_id
     , l_dest_plan_type_id plan_type_id
     , rl.RAW_COST
     , rl.BRDN_COST
     , rl.REVENUE
     , rl.BILL_RAW_COST
     , rl.BILL_BRDN_COST
     , rl.BILL_LABOR_RAW_COST
     , rl.BILL_LABOR_BRDN_COST
     , rl.BILL_LABOR_HRS
     , rl.EQUIPMENT_RAW_COST
     , rl.EQUIPMENT_BRDN_COST
     , rl.CAPITALIZABLE_RAW_COST
     , rl.CAPITALIZABLE_BRDN_COST
     , rl.LABOR_RAW_COST
     , rl.LABOR_BRDN_COST
     , rl.LABOR_HRS
     , rl.LABOR_REVENUE
     , rl.EQUIPMENT_HOURS
     , rl.BILLABLE_EQUIPMENT_HOURS
     , rl.SUP_INV_COMMITTED_COST
     , rl.PO_COMMITTED_COST
     , rl.PR_COMMITTED_COST
     , rl.OTH_COMMITTED_COST
       , rl.ACT_LABOR_HRS
           , rl.ACT_EQUIP_HRS
           , rl.ACT_LABOR_BRDN_COST
           , rl.ACT_EQUIP_BRDN_COST
           , rl.ACT_BRDN_COST
           , rl.ACT_RAW_COST
           , rl.ACT_REVENUE
         , rl.ACT_LABOR_RAW_COST
         , rl.ACT_EQUIP_RAW_COST
           , rl.ETC_LABOR_HRS
           , rl.ETC_EQUIP_HRS
           , rl.ETC_LABOR_BRDN_COST
           , rl.ETC_EQUIP_BRDN_COST
           , rl.ETC_BRDN_COST
         , rl.ETC_RAW_COST
         , rl.ETC_LABOR_RAW_COST
         , rl.ETC_EQUIP_RAW_COST
     , rl.CUSTOM1
     , rl.CUSTOM2
     , rl.CUSTOM3
     , rl.CUSTOM4
     , rl.CUSTOM5
     , rl.CUSTOM6
     , rl.CUSTOM7
     , rl.CUSTOM8
     , rl.CUSTOM9
     , rl.CUSTOM10
     , rl.CUSTOM11
     , rl.CUSTOM12
     , rl.CUSTOM13
     , rl.CUSTOM14
     , rl.CUSTOM15
     , rl.PLAN_TYPE_CODE     /* 4471527 */
    FROM pji_fp_xbs_accum_f rl
    WHERE 1=1
     AND rl.plan_version_id = p_source_plan_ver_id
     AND ( (rl.rbs_aggr_level = g_top_level) OR (rl.rbs_aggr_level = g_lowest_level AND wbs_rollup_flag = 'N' ))
     ) ;

    print_time ( ' COPY_PRIMARY_SINGLE api 002 ' );


    l_dest_fp_version_ids := SYSTEM.pa_num_tbl_type(p_target_plan_ver_id);

    EXTRACT_FIN_PLAN_VERSIONS(
      p_fp_version_ids    => l_dest_fp_version_ids
    , p_slice_type        => 'PRI'
    );                                      print_time ( ' COPY_PRIMARY_SINGLE api 003 ' );

    POPULATE_WBS_HDR;          print_time(' 2.1 .. ');

    UPDATE_WBS_HDR;            print_time(' 2.11 .. ');

    POPULATE_RBS_HDR;          print_time(' 2.2 .. ');

    MERGE_INTO_FP_FACT;

    CLEANUP_INTERIM_TABLES;    print_time(' 2.3 .. ');

    print_time ( ' COPY_PRIMARY_SINGLE api 004 ' || sql%rowcount);


    IF (p_commit = 'T') THEN
      COMMIT;
    END IF;

    print_time ( ' COPY_PRIMARY_SINGLE api 005 ');

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'COPY_PRIMARY_SINGLE');
    RAISE;
END;


--
-- Get the budget versions that need to be extracted INTO a temp table.
-- This is to set scope for extraction as well as track time/curr dangling records
--  in the case of secondary slice creation.
--
PROCEDURE EXTRACT_FIN_PLAN_VERS_BULK(
  p_slice_type        IN   VARCHAR2 := NULL  -- 'PRI' or 'SEC' or 'SECRBS'
) IS
BEGIN

  print_time('EXTRACT_FIN_PLAN_VERS_BULK : Begin ' );

  IF ( p_slice_type NOT IN ('PRI', 'SEC', 'SECRBS') ) THEN
    print_time('EXTRACT_FIN_PLAN_VERSIONS : Invalid slice type. Exitting. ' );
    RETURN;
  END IF;


  IF ( p_slice_type = 'PRI') THEN

    INSERT INTO PJI_FM_EXTR_PLNVER3_T
    (
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,          /* 4471527 */
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
        CURRENT_FLAG             ,
        ORIGINAL_FLAG            ,
        CURRENT_ORIGINAL_FLAG    ,
        BASELINED_FLAG           ,
      SECONDARY_RBS_FLAG
    )
      SELECT
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                           , 'Y', bv.project_structure_version_id
                           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
                                   )                           wbs_struct_version_id
          , fpo.rbs_version_id                 rbs_struct_version_id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , g_all_timeph_code,     fpo.all_time_phased_code
                      , g_cost_timeph_code,    fpo.cost_time_phased_code
                      , g_rev_timeph_code, fpo.revenue_time_phased_code
                     )                       time_phased_type_code
          , NULL                             time_dangling_flag   -- to be used for dangling check.
          , NULL                             rate_dangling_flag   -- to be used for dangling check.
          , NULL                             PROJECT_TYPE_CLASS
                  , NVL(bv.wp_version_flag, 'N') is_wp_flag
                  , bv.current_flag                  current_flag
                  , bv.original_flag                 original_flag
                  , bv.current_original_flag         current_original_flag
                  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
                , 'N'                                SECONDARY_RBS_FLAG
      FROM
           pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , pa_projects_all  ppa -- @pjdev115    ppa
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( g_all_timeph_code , g_cost_timeph_code , g_rev_timeph_code) -- Eg of other version type is ORG_FORECAST.
          -- AND bv.pji_summarized_flag = 'N'
          ;

  ELSIF ( p_slice_type = 'SEC') THEN

    INSERT INTO PJI_FM_EXTR_PLNVER3_T
    (
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
        CURRENT_FLAG             ,
        ORIGINAL_FLAG            ,
        CURRENT_ORIGINAL_FLAG    ,
        BASELINED_FLAG           ,
      SECONDARY_RBS_FLAG
    )
      SELECT
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                           , 'Y', bv.project_structure_version_id
                           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
                                   )                           wbs_struct_version_id
          , fpo.rbs_version_id                 rbs_struct_version_id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , g_all_timeph_code,     fpo.all_time_phased_code
                      , g_cost_timeph_code,    fpo.cost_time_phased_code
                      , g_rev_timeph_code, fpo.revenue_time_phased_code
                     )                       time_phased_type_code
          , NULL                             time_dangling_flag   -- to be used for dangling check.
          , NULL                             rate_dangling_flag   -- to be used for dangling check.
          , NULL                             PROJECT_TYPE_CLASS
                  , NVL(bv.wp_version_flag, 'N') is_wp_flag
                  , bv.current_flag                  current_flag
                  , bv.original_flag                 original_flag
                  , bv.current_original_flag         current_original_flag
                  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
              , 'N'                                  SECONDARY_RBS_FLAG
      FROM
           pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo  -- is there a work plan options table?
         , pa_projects_all  ppa -- @pjdev115    ppa
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( g_all_timeph_code , g_cost_timeph_code , g_rev_timeph_code) -- Eg of other version type is ORG_FORECAST.
          -- AND bv.pji_summarized_flag = 'P' -- For plan baselining, don't check for summarized flag.
          -- Temporarily taking this condition out for global currency conversion.
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N') = 'N';


  ELSIF ( p_slice_type = 'SECRBS') THEN

    INSERT INTO PJI_FM_EXTR_PLNVER3_T
    (
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
        CURRENT_FLAG             ,
        ORIGINAL_FLAG            ,
        CURRENT_ORIGINAL_FLAG    ,
        BASELINED_FLAG           ,
      SECONDARY_RBS_FLAG
    )
      SELECT
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                           , 'Y', bv.project_structure_version_id
                           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
                                   )                           wbs_struct_version_id
                  , rpa.rbs_version_id                 rbs_struct_version_id
          -- , fpo.rbs_version_id                 rbs_struct_version_id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , g_all_timeph_code,     fpo.all_time_phased_code
                      , g_cost_timeph_code,    fpo.cost_time_phased_code
                      , g_rev_timeph_code, fpo.revenue_time_phased_code
                     )                       time_phased_type_code
          , NULL                             time_dangling_flag   -- to be used for dangling check.
          , NULL                             rate_dangling_flag   -- to be used for dangling check.
          , NULL                             PROJECT_TYPE_CLASS
                  , NVL(bv.wp_version_flag, 'N') is_wp_flag
                  , bv.current_flag                  current_flag
                  , bv.original_flag                 original_flag
                  , bv.current_original_flag         current_original_flag
                  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
                  , 'Y'                                          SECONDARY_RBS_FLAG
      FROM
           pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo  -- is there a work plan options table?
         , pa_projects_all  ppa -- @pjdev115    ppa
                 , PA_RBS_PRJ_ASSIGNMENTS rpa
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( g_all_timeph_code , g_cost_timeph_code , g_rev_timeph_code) -- Eg of other version type is ORG_FORECAST.
          -- AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          -- Temporarily taking this condition out for global currency conversion.
          AND bv.budget_status_code = 'B'
            AND rpa.project_id = bv.project_id
            -- AND DECODE ( rpa.wp_usage_flag, 'Y', 'Y', 'X') = NVL(bv.wp_version_flag, 'N')
            -- AND DECODE ( rpa.fp_usage_flag, 'Y', 'N', 'X') = NVL(bv.wp_version_flag, 'N')
            AND rpa.assignment_status = 'ACTIVE'
            AND rpa.rbs_version_id <> NVL(fpo.rbs_version_id, -1)
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
            AND rpa.reporting_usage_flag = 'Y';

  END IF;


  print_time('EXTRACT_FIN_PLAN_VERS_BULK : End .. rows processed ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_FIN_PLAN_VERS_BULK');
    print_time('EXTRACT_FIN_PLAN_VERS_BULK : Exception: ' || sqlerrm );
    RAISE;
END;


--
-- Get the budget versions that need to be extracted INTO a temp table.
-- This is to set scope for extraction as well as track time/curr dangling records
--  in the case of secondary slice creation.
--
PROCEDURE EXTRACT_FIN_PLAN_VERSIONS(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_slice_type        IN   VARCHAR2 := NULL -- 'PRI' or 'SEC' or 'SECRBS'
) IS
  l_count NUMBER;
BEGIN

  print_time('EXTRACT_FIN_PLAN_VERSIONS : Begin ' );

  IF (p_slice_type NOT IN ( 'PRI', 'SEC', 'SECRBS' )) THEN
    print_time('EXTRACT_FIN_PLAN_VERSIONS : Invalid slice type. Exitting. ' );
    RETURN;
  END IF;

  print_time('EXTRACT_FIN_PLAN_VERSIONS : l_count is ... ' || p_fp_version_ids.COUNT );

  IF (p_slice_type = 'PRI') THEN

    FOR I IN 1..p_fp_version_ids.COUNT LOOP

          INSERT INTO PJI_FM_EXTR_PLNVER3_T ver3
          (
            PROJECT_ID               ,
            PLAN_VERSION_ID          ,
            WBS_STRUCT_VERSION_ID    ,
            RBS_STRUCT_VERSION_ID    ,
            PLAN_TYPE_CODE           ,
            PLAN_TYPE_ID             ,
            TIME_PHASED_TYPE_CODE    ,
            TIME_DANGLING_FLAG       ,
            RATE_DANGLING_FLAG       ,
            PROJECT_TYPE_CLASS       ,
            WP_FLAG                  ,
            CURRENT_FLAG             ,
            ORIGINAL_FLAG            ,
            CURRENT_ORIGINAL_FLAG    ,
            BASELINED_FLAG           ,
              SECONDARY_RBS_FLAG
          )
            SELECT
                  bv.project_id                      project_id
                , bv.budget_version_id               plan_version_id
                , DECODE ( NVL(bv.wp_version_flag, 'N')
                           , 'Y', bv.project_structure_version_id
                           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
                                   )                           wbs_struct_version_id
                , fpo.rbs_version_id                 rbs_struct_version_id
--                , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
                , fpo.fin_plan_type_id               plan_type_id
                , DECODE(bv.version_type
                            , g_all_timeph_code,     fpo.all_time_phased_code
                            , g_cost_timeph_code,    fpo.cost_time_phased_code
                            , g_rev_timeph_code, fpo.revenue_time_phased_code
                           )                       time_phased_type_code
                , NULL                             time_dangling_flag   -- to be used for dangling check.
                , NULL                             rate_dangling_flag   -- to be used for dangling check.
                , NULL                             PROJECT_TYPE_CLASS
                , NVL(bv.wp_version_flag, 'N') is_wp_flag
                , bv.current_flag                  current_flag
                , bv.original_flag                 original_flag
                , bv.current_original_flag         current_original_flag
                , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
                    , 'N'                                    SECONDARY_RBS_FLAG
            FROM
                 pa_budget_versions bv -- @pjdev115  bv
               , pa_proj_fp_options  fpo -- @pjdev115  fpo
               , pa_projects_all  ppa -- @pjdev115    ppa
            WHERE 1=1
                AND ppa.project_id = bv.project_id
                AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
                AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
                                                    -- Ask VR: How about WP version.. are they picked up with this condition??
                AND fpo.project_id = bv.project_id
                AND bv.fin_plan_type_id = fpo.fin_plan_type_id
                AND bv.budget_version_id = fpo.fin_plan_version_id
                AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
                AND bv.version_type IN ( g_all_timeph_code , g_cost_timeph_code , g_rev_timeph_code) -- Eg of other version type is ORG_FORECAST.
                -- AND bv.pji_summarized_flag = 'N'
                AND bv.budget_version_id = p_fp_version_ids(i) ;

    END LOOP;

  ELSIF (p_slice_type = 'SEC') THEN

    FOR I IN 1..p_fp_version_ids.COUNT LOOP

          INSERT INTO PJI_FM_EXTR_PLNVER3_T ver3
          (
            PROJECT_ID               ,
            PLAN_VERSION_ID          ,
            WBS_STRUCT_VERSION_ID    ,
            RBS_STRUCT_VERSION_ID    ,
            PLAN_TYPE_CODE           ,
            PLAN_TYPE_ID             ,
            TIME_PHASED_TYPE_CODE    ,
            TIME_DANGLING_FLAG       ,
            RATE_DANGLING_FLAG       ,
            PROJECT_TYPE_CLASS       ,
            WP_FLAG                  ,
            CURRENT_FLAG             ,
            ORIGINAL_FLAG            ,
            CURRENT_ORIGINAL_FLAG    ,
            BASELINED_FLAG           ,
              SECONDARY_RBS_FLAG
          )
            SELECT
                  bv.project_id                      project_id
                , bv.budget_version_id               plan_version_id
                , DECODE ( NVL(bv.wp_version_flag, 'N')
                           , 'Y', bv.project_structure_version_id
                           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
                                   )                           wbs_struct_version_id
                , fpo.rbs_version_id                 rbs_struct_version_id
--                , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
                , fpo.fin_plan_type_id               plan_type_id
                , DECODE(bv.version_type
                            , g_all_timeph_code,     fpo.all_time_phased_code
                            , g_cost_timeph_code,    fpo.cost_time_phased_code
                            , g_rev_timeph_code, fpo.revenue_time_phased_code
                           )                       time_phased_type_code
                , NULL                             time_dangling_flag   -- to be used for dangling check.
                , NULL                             rate_dangling_flag   -- to be used for dangling check.
                , NULL                             PROJECT_TYPE_CLASS
                , NVL(bv.wp_version_flag, 'N') is_wp_flag
                , bv.current_flag                  current_flag
                , bv.original_flag                 original_flag
                , bv.current_original_flag         current_original_flag
                , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
                    , 'N'                                    SECONDARY_RBS_FLAG
            FROM
                 pa_budget_versions bv -- @pjdev115  bv
               , pa_proj_fp_options  fpo -- @pjdev115  fpo
               , pa_projects_all  ppa -- @pjdev115    ppa
            WHERE 1=1
                AND ppa.project_id = bv.project_id
                AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
                AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
                                                    -- Ask VR: How about WP version.. are they picked up with this condition??
                AND fpo.project_id = bv.project_id
                AND bv.fin_plan_type_id = fpo.fin_plan_type_id
                AND bv.budget_version_id = fpo.fin_plan_version_id
                AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
                AND bv.version_type IN ( g_all_timeph_code , g_cost_timeph_code , g_rev_timeph_code) -- Eg of other version type is ORG_FORECAST.
                -- AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
                -- Temporarily taking this condition out for global currency conversion.
                AND bv.budget_status_code = 'B'
                AND NVL(bv.wp_version_flag, 'N') = 'N'
                AND bv.budget_version_id = p_fp_version_ids(i) ;

    END LOOP;


  ELSIF (p_slice_type = 'SECRBS') THEN

    FOR I IN 1..p_fp_version_ids.COUNT LOOP

          INSERT INTO PJI_FM_EXTR_PLNVER3_T ver3
          (
            PROJECT_ID               ,
            PLAN_VERSION_ID          ,
            WBS_STRUCT_VERSION_ID    ,
            RBS_STRUCT_VERSION_ID    ,
            PLAN_TYPE_CODE           ,
            PLAN_TYPE_ID             ,
            TIME_PHASED_TYPE_CODE    ,
            TIME_DANGLING_FLAG       ,
            RATE_DANGLING_FLAG       ,
            PROJECT_TYPE_CLASS       ,
            WP_FLAG                  ,
            CURRENT_FLAG             ,
            ORIGINAL_FLAG            ,
            CURRENT_ORIGINAL_FLAG    ,
            BASELINED_FLAG           ,
            SECONDARY_RBS_FLAG
          )
      SELECT
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                           , 'Y', bv.project_structure_version_id
                           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
                                   )                           wbs_struct_version_id
                  , rpa.rbs_version_id                 rbs_struct_version_id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , g_all_timeph_code,     fpo.all_time_phased_code
                      , g_cost_timeph_code,    fpo.cost_time_phased_code
                      , g_rev_timeph_code, fpo.revenue_time_phased_code
                     )                       time_phased_type_code
          , NULL                             time_dangling_flag   -- to be used for dangling check.
          , NULL                             rate_dangling_flag   -- to be used for dangling check.
          , NULL                             PROJECT_TYPE_CLASS
                  , NVL(bv.wp_version_flag, 'N') is_wp_flag
                  , bv.current_flag                  current_flag
                  , bv.original_flag                 original_flag
                  , bv.current_original_flag         current_original_flag
                  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
                  , 'Y'                                          SECONDARY_RBS_FLAG
      FROM
           pa_budget_versions bv -- @pjdev115  bv
               , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , pa_projects_all  ppa -- @pjdev115    ppa
                 , PA_RBS_PRJ_ASSIGNMENTS rpa
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
                                              -- Ask VR: How about WP version.. are they picked up with this condition??
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( g_all_timeph_code , g_cost_timeph_code , g_rev_timeph_code) -- Eg of other version type is ORG_FORECAST.
          -- AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          -- Temporarily taking this condition out for global currency conversion.
          AND bv.budget_status_code = 'B'
            AND rpa.project_id = bv.project_id
            AND rpa.assignment_status = 'ACTIVE'
            AND rpa.rbs_version_id <> NVL(fpo.rbs_version_id, -1)
            AND rpa.reporting_usage_flag = 'Y'
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
                AND bv.budget_version_id = p_fp_version_ids(i)
                  AND bv.project_id = rpa.project_id;

    END LOOP;

  END IF;

  print_time('EXTRACT_FIN_PLAN_VERSIONS : l_count is ... ' || SQL%ROWCOUNT );

  print_time('EXTRACT_FIN_PLAN_VERSIONS : End' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_FIN_PLAN_VERSIONS : Exception: ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_FIN_PLAN_VERSIONS');
    RAISE;
END;


--
-- Insert -3, -4 versions into ver3.
--
PROCEDURE EXTRACT_CB_CO_PLAN_VERSIONS IS
BEGIN

  INSERT INTO pji_fm_extr_plnver3_t
  (
        project_id
        , plan_version_id
        , wbs_struct_version_id
        , rbs_struct_version_id
        , plan_type_id
        , plan_type_code
        , time_phased_type_code
        , time_dangling_flag
        , rate_dangling_flag
        , project_type_class
        , wp_flag
        , current_flag
        , original_flag
        , current_original_flag
        , baselined_flag
        , secondary_rbs_flag
        , lp_flag
  )
  SELECT DISTINCT
         project_id
       , -3 -- plan_version_id
           , wbs_struct_version_id
           , rbs_struct_version_id
           , plan_type_id
           , plan_type_code          /* 4471527 */
           , time_phased_type_code
           , NULL -- time dangling flag
           , NULL -- rate dangling flag
           , NULL -- project type class
           , wp_flag -- wp flag
           , current_flag -- curr flag
           , 'N' -- original_flag -- orig flag
           , 'N' -- current_original_flag -- corr orig flag
           , baselined_flag -- baselined flag
           , secondary_rbs_flag -- sec rbs flag
           , lp_flag -- lp flag
  FROM pji_fm_extr_plnver3_t
  WHERE wp_flag = 'N'
    AND baselined_flag = 'Y'
        AND current_flag = 'Y'
        AND plan_version_id > 0
        AND rate_dangling_flag IS NULL
        AND time_dangling_flag IS NULL
  UNION ALL
  SELECT DISTINCT
         project_id
       , -4 -- plan_version_id
           , wbs_struct_version_id
           , rbs_struct_version_id
           , plan_type_id
           , plan_type_code       /* 4471527 */
           , time_phased_type_code
           , NULL -- time dangling flag
           , NULL -- rate dangling flag
           , NULL -- project type class
           , wp_flag -- wp flag
           , current_flag -- curr flag
           , original_flag -- orig flag
           , current_original_flag -- corr orig flag
           , 'N' -- baselined_flag -- baselined flag
           , secondary_rbs_flag -- sec rbs flag
           , lp_flag -- lp flag
  FROM pji_fm_extr_plnver3_t
  WHERE wp_flag = 'N'
    AND baselined_flag = 'Y'
        AND current_original_flag = 'Y'
        AND plan_version_id > 0
        AND rate_dangling_flag IS NULL
        AND time_dangling_flag IS NULL;

   print_time ( ' # -3, -4 records inserted into ver3 is ' || SQL%ROWCOUNT );

END;


--
-- Extract the period level plan amounts for PA/GL/non time phased entries from budget lines
--  for the primary RBS for this plan version into pji_fp_aggr_pjp1_t.
-- EXTRACT_PLAN_AMOUNTS_PRIRBS
PROCEDURE EXTRACT_PLAN_AMOUNTS_PRIRBS IS
  l_count NUMBER;
  l_max_plnver_id NUMBER := NULL;
  l_per_analysis_flag  varchar2(2);   /* Added for bug 8708651 */
BEGIN

  print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : Begin' );
  print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : Begin worker id is ... ' || 1);

   /* Added for bug 8708651 */
  l_per_analysis_flag := PJI_UTILS.GET_SETUP_PARAMETER('PER_ANALYSIS_FLAG');

  INSERT_NTP_CAL_RECORD ( x_max_plnver_id => l_max_plnver_id );

  IF (l_max_plnver_id IS NULL) THEN
    RETURN;
  END IF;

    INSERT INTO PJI_FP_AGGR_PJP1_T
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       -- , START_DATE
       -- , END_DATE
       , PRG_LEVEL
       , PLAN_TYPE_CODE    /* 4471527 */
        )
       SELECT
         g_worker_id  WORKER_ID
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(l_per_analysis_flag,'Y',
              decode(vers.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id),-1)  time_id /* Added for bug 8947586 */
       , DECODE(l_per_analysis_flag,'Y',
               decode(vers.time_phased_type_code
               , g_pa_cal_str, 32
               , g_gl_cal_str, 32
               , 'N', 2048
               , -1),2048) /* Added for bug 8708651 */
       , DECODE(l_per_analysis_flag,'Y',
               decode(vers.time_phased_type_code
               , g_pa_cal_str, g_pa_cal_str
               , g_gl_cal_str, g_gl_cal_str
               , 'N', g_all
               , 'X'),g_all)    /* Added for bug 8708651 */
       , g_lowest_level RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE  -- curr code missing.
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
       , plr.plan_type_id
       , SUM(plr.RAW_COST)
       , SUM(plr.BRDN_COST)
       , SUM(plr.REVENUE)
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )  BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )   BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code, plr.raw_cost, 0 ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code , plr.BRDN_COST, 0 ) )   BILL_LABOR_BRDN_COST
--       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code, plr.quantity, 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code,
                                                                  DECODE ( plr.billable_flag,'Y',plr.quantity,0) , 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.raw_cost, 0 ) )  EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.BRDN_COST, 0 ) )   EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )      CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )      CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.raw_cost, 0 ) )  LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.BRDN_COST, 0 ) )   LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                                    0 ) )   labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, DECODE(plr.billable_flag,'Y',
                                                                           DECODE ( vers.wp_flag, 'N',
                                                                                    DECODE ( plr.billable_flag, 'Y', plr.quantity, 0 ),
                                                                   plr.quantity),
						    0 ),
                                                    0 ) )   labor_hrs  -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.revenue, 0 ) )  LABOR_REVENUE
       /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),

                                            0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code, DECODE(plr.billable_flag,'Y',
                                                                          DECODE ( vers.wp_flag, 'N',
                                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
						    0 ),
                                                    0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT', plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT',
                                                                 DECODE ( plr.billable_flag,'Y',plr.quantity,0), 0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , NULL  SUP_INV_COMMITTED_COST
       , NULL  PO_COMMITTED_COST
       , NULL  PR_COMMITTED_COST
       , NULL  OTH_COMMITTED_COST
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
										0 ),
                                                                                0 ) ) ) ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
										0 ),
                                                                                0 ) ) ) ACT_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_BRDN_COST, 0 ) ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_BRDN_COST, 0 ) ) ) ACT_EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_brdn_cost ) ) ACT_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_raw_cost ) ) ACT_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_revenue ) ) ACT_REVENUE
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_RAW_COST, 0 ) ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_RAW_COST, 0 ) ) ) ACT_EQUIPMENT_RAW_COST
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_BRDN_COST, 0 ) ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_BRDN_COST, 0 ) ) ) ETC_EQUIP_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.etc_brdn_cost ) ) ETC_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.etc_raw_cost ) ) ETC_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_raw_COST, 0 ) ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_raw_COST, 0 ) ) ) ETC_EQUIP_raw_COST
       , NULL CUSTOM1
       , NULL CUSTOM2
       , NULL CUSTOM3
       , NULL CUSTOM4
       , NULL CUSTOM5
       , NULL CUSTOM6
       , NULL CUSTOM7
       , NULL CUSTOM8
       , NULL CUSTOM9
       , NULL CUSTOM10
       , NULL CUSTOM11
       , NULL CUSTOM12
       , NULL CUSTOM13
       , NULL CUSTOM14
       , NULL CUSTOM15
       , DECODE(vers.time_phased_type_code, g_pa_cal_str, 'OF', g_gl_cal_str, 'OF', 'N', 'NTP', 'X') -- LINE_TYPE
       , NULL time_dangling_flag
       , NULL rate_dangling_flag
       -- , plr.start_date
           -- , plr.end_date
       , g_default_prg_level prg_level
       , plr.plan_type_code /* 4471527 */
       FROM
       (          ----- First inline view plr .............
            select
              collapse_bl.PROJECT_ID      -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID  -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                    , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , max(collapse_bl.raw_cost) raw_cost
            , max(collapse_bl.BRDN_COST) BRDN_COST
            , max(collapse_bl.revenue) revenue
            , max(collapse_bl.actual_raw_cost) actual_raw_cost
            , max(collapse_bl.actual_BRDN_COST) actual_BRDN_COST
            , max(collapse_bl.actual_revenue) actual_revenue
            , max(collapse_bl.etc_raw_cost) etc_raw_cost
            , max(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , max(collapse_bl.etc_revenue) etc_revenue
            , max(collapse_bl.quantity) quantity
            , max(collapse_bl.actual_quantity) actual_quantity
            , max(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.start_date start_date
            , collapse_bl.end_date   end_date
            , collapse_bl.period_name period_name  -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
            , collapse_bl.row_id
            , collapse_bl.plan_type_code   plan_type_code       /* 4471527 */
            from
              (                  ----- Second inline view 'collapse_bl' begin .............
               select
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID
                , spread_bl.RESOURCE_ASSIGNMENT_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
                        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS  -- , spread_bl.CALENDAR_TYPE  -- , pji_time.CALENDAR_ID
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , spread_bl.TIME_PHASED_TYPE_CODE
                , DECODE( invert.INVERT_ID
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
                                , DECODE ( invert.INVERT_ID
                                         , 4, spread_bl.func_actual_raw_cost
                                                 , 8, spread_bl.prj_actual_raw_cost
                                                 , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
                                , DECODE ( invert.INVERT_ID
                                         , 4, spread_bl.func_actual_brdn_cost
                                                 , 8, spread_bl.prj_actual_brdn_cost
                                                 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
                                , DECODE ( invert.INVERT_ID
                                         , 4, spread_bl.func_actual_revenue
                                                 , 8, spread_bl.prj_actual_revenue
                                                 , 16, spread_bl.txn_actual_revenue ) actual_revenue
                                , DECODE ( invert.INVERT_ID
                                         , 4, spread_bl.func_etc_raw_cost
                                                 , 8, spread_bl.prj_etc_raw_cost
                                                 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
                                , DECODE ( invert.INVERT_ID
                                         , 4, spread_bl.func_etc_brdn_cost
                                                 , 8, spread_bl.prj_etc_brdn_cost
                                                 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
                                , DECODE ( invert.INVERT_ID
                                         , 4, spread_bl.func_etc_revenue
                                                 , 8, spread_bl.prj_etc_revenue
                                                 , 16, spread_bl.txn_etc_revenue ) etc_revenue
                , spread_bl.quantity quantity
                , spread_bl.actual_quantity actual_quantity
                , spread_bl.etc_quantity etc_quantity
                , spread_bl.start_date start_date
                , spread_bl.end_date   end_date
                , spread_bl.period_name period_name
                -- , spread_bl.TRACK_AS_LABOR_FLAG track_as_labor_flag
                , spread_bl.plan_type_code     /* 4471527 */
                from
                  (     ----- Third inline view 'spread_bl'  .............
                        -- Added HINT For bug 3828698
                    SELECT  /*+ LEADING(VER) USE_NL(VER,PPA,PEVS,RA,BL)*/
                          ra.project_id
                        , bl.rowid row_id
                        , ra.budget_version_id
                        , bl.resource_asSIGNment_id
                        , DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                        , NVL(ra.rbs_element_id, -1)              rbs_element_id
                        , ver.wbs_struct_version_id      wbs_struct_version_id
                        , NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id
                        , ver.plan_type_id               plan_type_id
                        , ra.rate_based_flag             billable_flag
                        , ra.resource_class_code         resource_class
                        , bl.txn_currency_code           txn_currency_code
                        , bl.txn_raw_cost                txn_raw_cost
                        , bl.txn_burdened_COST           txn_brdn_COST
                        , bl.txn_revenue                 txn_revenue
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_raw_cost, NULL)                txn_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_burdened_cost, NULL)             txn_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_revenue, NULL)                   txn_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), NULL) txn_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), NULL) txn_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), NULL) txn_etc_revenue     -- new
                        , bl.project_currency_code          prj_currency_code
                        , bl.project_raw_cost               prj_raw_cost
                        , bl.project_burdened_COST          prj_BRDN_COST
                        , bl.project_revenue                prj_revenue
                        , DECODE(ver.wp_flag, 'N', bl.project_init_raw_cost, NULL)          prj_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.project_init_burdened_cost, NULL)     prj_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.project_init_revenue, NULL)           prj_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), NULL) prj_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), NULL) prj_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_revenue - NVL(bl.project_init_revenue, 0)), NULL) prj_etc_revenue     -- new
                        , bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                        , bl.burdened_COST                  func_BRDN_COST
                        , bl.revenue                        func_revenue
                        , DECODE(ver.wp_flag, 'N', bl.init_raw_cost , NULL)                 func_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.init_burdened_cost , NULL)            func_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.init_revenue , NULL)                  func_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.raw_cost - NVL(bl.init_raw_cost, 0)), NULL) func_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), NULL) func_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.revenue - NVL(bl.init_revenue, 0)), NULL) func_etc_revenue     -- new
                        , g_global1_currency_code        glb1_currency_code
                  , NULL                           glb1_raw_cost
                        , NULL                           glb1_BRDN_COST
                        , NULL                           glb1_revenue
                        , g_global2_currency_code        glb2_currency_code
                  , NULL                           glb2_raw_cost
                        , NULL                           glb1_BRDN_COST
                        , NULL                           glb1_revenue
                  , bl.quantity                    quantity
                        , DECODE(ver.wp_flag, 'N', bl.init_quantity, NULL)                  actual_quantity  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.quantity - NVL(bl.init_quantity, 0)), NULL) etc_quantity  -- new
                        , DECODE(ver.time_phased_type_code, 'N', bl.start_date, NULL) start_date
                        , DECODE(ver.time_phased_type_code, 'N', bl.end_date, NULL) end_date
                        , nvl(bl.period_name,g_ntp_period_name) period_name /* Added nvl for 4174366*/
                        , ver.time_phased_type_code time_phased_type_code
                        , ppa.org_id project_org_id
                        , ppa.carrying_out_organization_id project_organization_id
                        , ver.plan_type_code      plan_type_code  /* 4471527 */
                 FROM
                       PA_BUDGET_LINES               bl
                     , pa_resource_asSIGNments       ra
                     , PJI_FM_EXTR_PLNVER3_T           ver
                         , pa_projects_all               ppa
                           , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE
                         ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
                           AND pevs.element_version_id = ver.wbs_struct_version_id
                           AND ver.project_id = pevs.project_id  -- fix for bug 4149422 in EXTRACT_PLAN_AMOUNTS_PRIRBS
                           AND ver.secondary_rbs_flag = 'N'
                                  ) spread_bl
                                   ---- end of third inline view 'spread_bl'...........
                  ,
                    (
                      select 4   INVERT_ID from dual union all
                      select 8   INVERT_ID from dual union all
                      select 16  INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
                                )  collapse_bl
                                ----  End of second inline view 'collapse_bl' ..........
                        GROUP BY
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                        , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.start_date
            , collapse_bl.end_date
            , collapse_bl.period_name
            , collapse_bl.row_id
            , collapse_bl.plan_type_code        /* 4471527 */
       ) plr
                                ----  End of first inline view plr ..........
       , PJI_ORG_EXTR_INFO            orginfo
       , PJI_FM_EXTR_PLNVER3_T      vers
       , pji_time_cal_period_v        pji_time
         WHERE  1=1
           -- AND    orginfo.projfunc_currency_mau is not NULL
           AND    plr.project_org_id         = orginfo.org_id
           AND    plr.project_id             = vers.project_id
           AND    plr.budget_version_id      = vers.plan_version_id
           AND    plr.plan_type_code         = vers.plan_type_code    /*4471527 */
           AND    DECODE(vers.time_phased_type_code
                   , g_pa_cal_str, orginfo.pa_calendar_id
                   , g_gl_cal_str, orginfo.gl_calendar_id
                   , -l_max_plnver_id ) = pji_time.calendar_id
           AND    plr.period_name = pji_time.name
           AND vers.time_phased_type_code IN (g_pa_cal_str, g_gl_cal_str, 'N')
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(l_per_analysis_flag,'Y',
              decode(vers.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id),-1) /* Added for bug 8947586 */
    --bug# 3886087 (put the below two decodes in sync with the ones in select stmt)
       , DECODE(l_per_analysis_flag,'Y',
               decode(vers.time_phased_type_code
               , g_pa_cal_str, 32
               , g_gl_cal_str, 32
               , 'N', 2048
               , -1),2048) /* Added for bug 8708651 */
       , DECODE(l_per_analysis_flag,'Y',
               decode(vers.time_phased_type_code
               , g_pa_cal_str, g_pa_cal_str
               , g_gl_cal_str, g_gl_cal_str
               , 'N', g_all
               , 'X'),g_all)     --   CALENDAR_TYPE  /* Added for bug 8708651 */
       , plr.CURR_RECORD_TYPE  -- curr code missing.
           , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
         , plr.plan_type_id
       , DECODE(vers.time_phased_type_code, g_pa_cal_str, 'OF', g_gl_cal_str, 'OF', 'N', 'NTP', 'X')
       , plr.plan_type_code;         /* 4471527 */

  print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : l_count ' || SQL%ROWCOUNT);

  DELETE_NTP_CAL_RECORD ( p_max_plnver_id => l_max_plnver_id );

  print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : End' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : Exception ' || SQLERRM );
    print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : Begin worker id is ... ' || 1);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_PLAN_AMOUNTS_PRIRBS');
    RAISE;
END;


--
-- Extract the period level plan amounts for PA/GL/non time phased entries from budget lines
--  for the secondary RBS for this plan version into pji_fp_aggr_pjp1_t.
-- EXTRACT_PLAN_AMOUNTS_SECRBS
PROCEDURE EXTRACT_PLAN_AMOUNTS_SECRBS IS
BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_PLAN_AMOUNTS_SECRBS : Exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_PLAN_AMOUNTS_SECRBS');
    RAISE;
END;

--EXTRACT_PLAN_AMTS_SECRBS_GLC12

PROCEDURE EXTRACT_PLAN_AMTS_SECRBS_GLC12 IS
BEGIN

    print_time ( ' EXTRACT_PLAN_AMTS_SECRBS_GLC12 begin. Inserted rows # is: ' || SQL%ROWCOUNT );

    PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
      x_currency_conversion_rule => g_currency_conversion_rule
    , x_prorating_format         => g_prorating_format
    , x_global1_currency_code    => g_global1_currency_code
    , x_global2_currency_code    => g_global2_currency_code
    , x_global1_currency_mau     => g_global1_currency_mau
    , x_global2_currency_mau     => g_global2_currency_mau ) ;


  print_time(' Got global currency settings. ');
  print_time(' g_currency_conversion_rule ' || g_currency_conversion_rule || ' g_prorating_format ' ||  g_prorating_format );
  print_time(' g_global1_currency_code ' || g_global1_currency_code || ' g_global2_currency_code ' || g_global2_currency_code );
  print_time(' g_global1_currency_mau ' || g_global1_currency_mau || ' g_global2_currency_mau ' || g_global2_currency_mau ) ;

    INSERT INTO PJI_FP_AGGR_PJP1_T
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , TIME_DANGLING_FLAG
       , RATE_DANGLING_FLAG
       , START_DATE
       , END_DATE
       , PRG_LEVEL
       , PLAN_TYPE_CODE
        )
       SELECT
         g_worker_id WORKER_ID
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , plr.time_id
       , plr.period_type_id -- period type id...
       , plr.CALENDAR_TYPE
       , g_lowest_level RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.plan_version_id
       , plr.plan_type_id
       , SUM(plr.RAW_COST)
       , SUM(plr.BRDN_COST)
       , SUM(plr.REVENUE)
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )  BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )   BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code, plr.raw_cost, 0 ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code , plr.BRDN_COST, 0 ) )   BILL_LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code, plr.quantity, 0 ) )  BILL_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code,
                                                                  DECODE(plr.billable_flag,'Y',plr.quantity,0) , 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.raw_cost, 0 ) )  EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.BRDN_COST, 0 ) )   EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )      CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )      CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.raw_cost, 0 ) )  LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.BRDN_COST, 0 ) )   LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                                    0 ) )   labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, DECODE(plr.billable_flag,'Y',
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
						    0 ),
                                                    0 ) )   labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.revenue, 0 ) )  LABOR_REVENUE
      /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),

                                            0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
      , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code, DECODE(plr.billable_flag,'Y',
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
						    0 ),
                                                    0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_equip_resclass_code, plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_equip_resclass_code,
                                                                 DECODE(plr.billable_flag,'Y',plr.quantity,0) , 0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , TO_NUMBER(NULL)  SUP_INV_COMMITTED_COST
       , TO_NUMBER(NULL)  PO_COMMITTED_COST
       , TO_NUMBER(NULL)  PR_COMMITTED_COST
       , TO_NUMBER(NULL)  OTH_COMMITTED_COST
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
										0 ),
                                                                                0 ) ) ) ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
										0 ),
                                                                                0 ) ) ) ACT_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_BRDN_COST, 0 ) ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_BRDN_COST, 0 ) ) ) ACT_EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_brdn_cost ) ) ACT_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_raw_cost ) ) ACT_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_revenue ) ) ACT_REVENUE
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_RAW_COST, 0 ) ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_RAW_COST, 0 ) ) ) ACT_EQUIPMENT_RAW_COST
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_BRDN_COST, 0 ) ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_BRDN_COST, 0 ) ) ) ETC_EQUIP_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.etc_brdn_cost ) ) ETC_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.etc_raw_cost ) ) ETC_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_raw_COST, 0 ) ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_raw_COST, 0 ) ) ) ETC_EQUIP_raw_COST
       , TO_NUMBER(NULL) CUSTOM1
       , TO_NUMBER(NULL) CUSTOM2
       , TO_NUMBER(NULL) CUSTOM3
       , TO_NUMBER(NULL) CUSTOM4
       , TO_NUMBER(NULL) CUSTOM5
       , TO_NUMBER(NULL) CUSTOM6
       , TO_NUMBER(NULL) CUSTOM7
       , TO_NUMBER(NULL) CUSTOM8
       , TO_NUMBER(NULL) CUSTOM9
       , TO_NUMBER(NULL) CUSTOM10
       , TO_NUMBER(NULL) CUSTOM11
       , TO_NUMBER(NULL) CUSTOM12
       , TO_NUMBER(NULL) CUSTOM13
       , TO_NUMBER(NULL) CUSTOM14
       , TO_NUMBER(NULL) CUSTOM15
       , plr.LINE_TYPE
       , NULL time_dangling_flag
       , decode(sign(plr.rate),-1,'Y',NULL) ||decode(sign(plr.rate2),-1,'Y',NULL) rate_dangling_flag
       , plr.start_date
         , plr.end_date
       , g_default_prg_level prg_level
       , plr.plan_type_code    plan_type_code    /* 4471527 */
       FROM
       (          ----- First inline view plr .............
            select
              collapse_bl.PROJECT_ID      -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID  -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                    , collapse_bl.plan_type_id
            , collapse_bl.plan_version_id
                        , collapse_bl.time_id
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.raw_cost))) raw_cost
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.BRDN_COST))) BRDN_COST
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.revenue))) revenue
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.actual_raw_cost))) actual_raw_cost
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.actual_BRDN_COST))) actual_BRDN_COST
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.actual_revenue))) actual_revenue
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.etc_raw_cost))) etc_raw_cost
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.etc_BRDN_COST))) etc_BRDN_COST
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.etc_revenue))) etc_revenue
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.quantity))) quantity
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.actual_quantity))) actual_quantity
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.etc_quantity))) etc_quantity
            , collapse_bl.start_date start_date
            , collapse_bl.end_date   end_date
            -- , collapse_bl.period_name period_name  -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
                        , collapse_bl.line_type
                        , collapse_bl.calendar_type
                        , collapse_bl.period_type_id
            , collapse_bl.row_id
            ,collapse_bl.rate rate
            ,collapse_bl.rate2 rate2
            , collapse_bl.plan_type_code  plan_type_code /* 4471527 */
            from
              (                  ----- Second inline view 'collapse_bl' begin .............
               select
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID plan_version_id
                                , spread_bl.time_id
                , spread_bl.RESOURCE_ASSIGNMENT_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
                        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , spread_bl.TIME_PHASED_TYPE_CODE
                , DECODE( invert.INVERT_ID
                        , 1, spread_bl.glb1_CURRENCY_CODE
                        , 2, spread_bl.glb2_CURRENCY_CODE
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_raw_cost
                         , 2, spread_bl.glb2_raw_cost
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_brdn_cost
                         , 2, spread_bl.glb2_brdn_cost
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_revenue
                         , 2, spread_bl.glb2_revenue
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
                                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_actual_raw_cost
                         , 2, spread_bl.glb2_actual_raw_cost
                                         , 4, spread_bl.func_actual_raw_cost
                                                 , 8, spread_bl.prj_actual_raw_cost
                                                 , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_actual_brdn_cost
                                                 , 2, spread_bl.glb2_actual_brdn_cost
                                         , 4, spread_bl.func_actual_brdn_cost
                                                 , 8, spread_bl.prj_actual_brdn_cost
                                                 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_actual_revenue
                                                 , 2, spread_bl.glb2_actual_revenue
                                         , 4, spread_bl.func_actual_revenue
                                                 , 8, spread_bl.prj_actual_revenue
                                                 , 16, spread_bl.txn_actual_revenue ) actual_revenue
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_etc_raw_cost
                                                 , 2, spread_bl.glb2_etc_raw_cost
                                         , 4, spread_bl.func_etc_raw_cost
                                                 , 8, spread_bl.prj_etc_raw_cost
                                                 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_etc_brdn_cost
                                                 , 2, spread_bl.glb2_etc_brdn_cost
                                         , 4, spread_bl.func_etc_brdn_cost
                                                 , 8, spread_bl.prj_etc_brdn_cost
                                                 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_etc_revenue
                                                 , 2, spread_bl.glb2_etc_revenue
                                         , 4, spread_bl.func_etc_revenue
                                                 , 8, spread_bl.prj_etc_revenue
                                                 , 16, spread_bl.txn_etc_revenue ) etc_revenue
                , spread_bl.quantity quantity
                , spread_bl.actual_quantity actual_quantity
                , spread_bl.etc_quantity etc_quantity
                , spread_bl.start_date start_date
                , spread_bl.end_date   end_date
                , spread_bl.line_type line_type
                                , spread_bl.period_type_id
                                , spread_bl.calendar_type
                ,decode(invert.invert_id,1,spread_bl.rate,1) rate
                ,decode(invert.invert_id,2,spread_bl.rate2,1) rate2
                ,spread_bl.plan_type_code plan_type_code /* 4471527 */
                from
                  (     ----- Third inline view 'spread_bl'  .............
                    SELECT
                          ra.project_id
                        , bl.rowid row_id
                        , ra.budget_version_id
                                        , prd.cal_period_id time_id
                        , bl.resource_asSIGNment_id
                        , DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                        , NVL(map.element_id, -1)              rbs_element_id  -- !! changed.
                        , ver.wbs_struct_version_id      wbs_struct_version_id
                        , NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id  -- !! changed.
                        , ver.plan_type_id               plan_type_id
                        , ra.rate_based_flag             billable_flag
                        , ra.resource_class_code         resource_class
                        , DECODE(ver.time_phased_type_code
                         , g_pa_cal_str, 32
                         , g_gl_cal_str, 32
                         , 'N', 2048
                         , -1) period_type_id
                           , DECODE(ver.time_phased_type_code
                            , g_pa_cal_str, g_pa_cal_str
                            , g_gl_cal_str, g_gl_cal_str
                            , 'N', g_all
                            , 'X')  CALENDAR_TYPE
                        , bl.txn_currency_code           txn_currency_code
                        , bl.txn_raw_cost                txn_raw_cost
                        , bl.txn_burdened_COST           txn_brdn_COST
                        , bl.txn_revenue                 txn_revenue
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_raw_cost, TO_NUMBER(NULL))                txn_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_burdened_cost, TO_NUMBER(NULL))             txn_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_revenue, TO_NUMBER(NULL))                   txn_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), TO_NUMBER(NULL)) txn_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), TO_NUMBER(NULL)) txn_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), TO_NUMBER(NULL)) txn_etc_revenue     -- new
                        , bl.project_currency_code          prj_currency_code
                        , bl.project_raw_cost               prj_raw_cost
                        , bl.project_burdened_COST          prj_BRDN_COST
                        , bl.project_revenue                prj_revenue
                        , DECODE(ver.wp_flag, 'N', bl.project_init_raw_cost, TO_NUMBER(NULL))          prj_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.project_init_burdened_cost, TO_NUMBER(NULL))     prj_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.project_init_revenue, TO_NUMBER(NULL))           prj_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), TO_NUMBER(NULL)) prj_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), TO_NUMBER(NULL)) prj_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_revenue - NVL(bl.project_init_revenue, 0)), TO_NUMBER(NULL)) prj_etc_revenue     -- new
                        , bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                        , bl.burdened_COST                  func_BRDN_COST
                        , bl.revenue                        func_revenue
                        , DECODE(ver.wp_flag, 'N', bl.init_raw_cost , TO_NUMBER(NULL))                 func_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.init_burdened_cost , TO_NUMBER(NULL))            func_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.init_revenue , TO_NUMBER(NULL))                  func_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.raw_cost - NVL(bl.init_raw_cost, 0)), TO_NUMBER(NULL)) func_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), TO_NUMBER(NULL)) func_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.revenue - NVL(bl.init_revenue, 0)), TO_NUMBER(NULL)) func_etc_revenue     -- new
                        , g_global1_currency_code  glb1_currency_code -- g_global1_currency_code        glb1_currency_code
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_raw_cost
                                                  , bl.project_currency_code
                                                  , bl.project_raw_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.raw_cost
                                                  , ROUND((rates.rate * raw_cost )/rates.mau)*rates.mau
                                        ) glb1_raw_cost
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_burdened_cost
                                                  , bl.project_currency_code
                                                  , bl.project_burdened_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.burdened_cost
                                                  , ROUND((rates.rate * burdened_cost )/rates.mau)*rates.mau
                                        ) glb1_BRDN_COST
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_revenue
                                                  , bl.project_currency_code
                                                  , bl.project_revenue
                                                  , bl.projfunc_currency_code
                                                  , bl.revenue
                                                  , ROUND((rates.rate * revenue )/rates.mau)*rates.mau
                                        )  glb1_revenue
                              , DECODE(ver.wp_flag
                                     , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_raw_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_raw_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_raw_cost
                                                         , ROUND((rates.rate * bl.init_raw_cost )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))                 glb1_actual_raw_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_burdened_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_burdened_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_burdened_cost
                                                         , ROUND((rates.rate * bl.init_burdened_cost )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))            glb1_actual_brdn_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_revenue
                                                         , bl.project_currency_code
                                                         , bl.project_init_revenue
                                                         , bl.projfunc_currency_code
                                                         , bl.init_revenue
                                                         , ROUND((rates.rate * bl.init_revenue )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))                  glb1_actual_revenue
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
                                                         , ROUND((rates.rate * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))                glb1_etc_raw_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
                                                         , ROUND((rates.rate * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))    glb1_etc_brdn_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.revenue - NVL(bl.init_revenue, 0))
                                                         , ROUND((rates.rate * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))    glb1_etc_revenue
                        , g_global2_currency_code  glb2_currency_code -- g_global2_currency_code        glb2_currency_code
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_raw_cost
                                                  , bl.project_currency_code
                                                  , bl.project_raw_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.raw_cost
                                                  , ROUND((rates.rate2 * raw_cost )/rates.mau2)*rates.mau2
                                        ) glb2_raw_cost
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_burdened_cost
                                                  , bl.project_currency_code
                                                  , bl.project_burdened_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.burdened_cost
                                                  , ROUND((rates.rate2 * burdened_cost )/rates.mau2)*rates.mau2
                                        ) glb2_BRDN_COST
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_revenue
                                                  , bl.project_currency_code
                                                  , bl.project_revenue
                                                  , bl.projfunc_currency_code
                                                  , bl.revenue
                                                  , ROUND((rates.rate2 * revenue )/rates.mau2)*rates.mau2
                                        )  glb2_revenue
                              , DECODE(ver.wp_flag
                                     , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_raw_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_raw_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_raw_cost
                                                         , ROUND((rates.rate2 * bl.init_raw_cost )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                 glb2_actual_raw_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_burdened_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_burdened_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_burdened_cost
                                                         , ROUND((rates.rate2 * bl.init_burdened_cost )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))            glb2_actual_brdn_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_revenue
                                                         , bl.project_currency_code
                                                         , bl.project_init_revenue
                                                         , bl.projfunc_currency_code
                                                         , bl.init_revenue
                                                         , ROUND((rates.rate2 * bl.init_revenue )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                  glb2_actual_revenue
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
                                                         , ROUND((rates.rate2 * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                glb2_etc_raw_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
                                                         , ROUND((rates.rate2 * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))    glb2_etc_brdn_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.revenue - NVL(bl.init_revenue, 0))
                                                         , ROUND((rates.rate2 * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))    glb2_etc_revenue
                                     , bl.quantity                    quantity
                                           , DECODE(ver.wp_flag, 'N', bl.init_quantity, TO_NUMBER(NULL))                  actual_quantity  -- new
                                           , DECODE(ver.wp_flag, 'N', (bl.quantity - NVL(bl.init_quantity, 0)), TO_NUMBER(NULL)) etc_quantity  -- new
                                           , TO_DATE(NULL) START_DATE
                                           , TO_DATE(NULL) END_date
                                           , ver.time_phased_type_code time_phased_type_code
                                           , ppa.org_id project_org_id
                                           , ppa.carrying_out_organization_id project_organization_id
                                               , DECODE(ver.time_phased_type_code, g_pa_cal_str, 'OF', g_gl_cal_str, 'OF', 'N', 'NTP', 'X') line_type
                        ,decode(ver.rate_dangling_flag,'Y',-1,1) rate
                        ,decode(ver.rate_dangling_flag,'Y',-1,1) rate2
                        , ver.plan_type_code  plan_type_code /* 4471527 */
                                 FROM
                                 PA_BUDGET_LINES               bl
                               , pa_resource_asSIGNments       ra
                               , PJI_FM_EXTR_PLNVER3_T           ver
                                   , pa_projects_all               ppa
                                     , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                                         , PJI_FM_AGGR_DLY_RATES_T           rates
                                         , pji_time_cal_period_v           prd
                                         , PJI_ORG_EXTR_INFO             oei
                                         , pji_fp_txn_accum_header       hdr
                                         , pa_rbs_txn_accum_map          map
                                         , pji_pjp_rbs_header            rhdr
                 WHERE 1=1
                                     AND ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                             AND ra.project_id = ver.PROJECT_ID
                             AND ra.budget_version_id = ver.plan_version_id
                             AND ver.project_id = ppa.project_id
                             AND txn_currency_code IS NOT NULL
                             AND bl.project_currency_code IS NOT NULL
                             AND bl.projfunc_currency_code IS NOT NULL
                                 AND pevs.element_version_id = ver.wbs_struct_version_id
                                 AND ver.secondary_rbs_flag = 'Y'
                                         AND ver.wp_flag = 'N'
                                         AND oei.org_id = ppa.org_id
                                         AND ver.time_phased_type_code IN (g_pa_cal_str, g_gl_cal_str)
                                         AND DECODE ( ver.time_phased_type_code
                                                    , g_pa_cal_str, oei.pa_calendar_id
                                                                , g_gl_cal_str, oei.gl_calendar_id) = prd.calendar_id
                                         AND bl.period_name = prd.name
                                         AND rates.time_id = prd.cal_period_id
                                          AND ra.txn_accum_header_id = hdr.txn_accum_header_id
                                          AND ra.txn_accum_header_id = map.txn_accum_header_id
                                          AND map.struct_version_id = rhdr.rbs_version_id
                                          AND ra.budget_version_id = rhdr.plan_version_id
                                          AND ppa.project_id = ra.project_id
                                AND ver.rbs_struct_version_id = rhdr.rbs_version_id
                                AND ver.project_id = pevs.project_id -- Fix for bug: 4149422  in EXTRACT_PLAN_AMTS_SECRBS_GLC12
             UNION ALL
             SELECT
                          ra.project_id
                        , bl.rowid row_id
                        , ra.budget_version_id
                                        , -1 time_id
                        , bl.resource_asSIGNment_id
                        , DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                        , NVL(map.element_id, -1)              rbs_element_id  -- !! changed.
                        , ver.wbs_struct_version_id      wbs_struct_version_id
                        , NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id  -- !! changed.
                        , ver.plan_type_id               plan_type_id
                        , ra.rate_based_flag             billable_flag
                        , ra.resource_class_code         resource_class
                        , DECODE(ver.time_phased_type_code
                         , g_pa_cal_str, 32
                         , g_gl_cal_str, 32
                         , 'N', 2048
                         , -1) period_type_id
                     , DECODE(ver.time_phased_type_code
                         , g_pa_cal_str, g_pa_cal_str
                         , g_gl_cal_str, g_gl_cal_str
                         , 'N', g_all
                         , 'X')  CALENDAR_TYPE
                        , bl.txn_currency_code           txn_currency_code
                        , bl.txn_raw_cost                txn_raw_cost
                        , bl.txn_burdened_COST           txn_brdn_COST
                        , bl.txn_revenue                 txn_revenue
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_raw_cost, TO_NUMBER(NULL))                txn_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_burdened_cost, TO_NUMBER(NULL))             txn_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_revenue, TO_NUMBER(NULL))                   txn_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), TO_NUMBER(NULL)) txn_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), TO_NUMBER(NULL)) txn_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), TO_NUMBER(NULL)) txn_etc_revenue     -- new
                        , bl.project_currency_code          prj_currency_code
                        , bl.project_raw_cost               prj_raw_cost
                        , bl.project_burdened_COST          prj_BRDN_COST
                        , bl.project_revenue                prj_revenue
                        , DECODE(ver.wp_flag, 'N', bl.project_init_raw_cost, TO_NUMBER(NULL))          prj_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.project_init_burdened_cost, TO_NUMBER(NULL))     prj_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.project_init_revenue, TO_NUMBER(NULL))           prj_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), TO_NUMBER(NULL)) prj_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), TO_NUMBER(NULL)) prj_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_revenue - NVL(bl.project_init_revenue, 0)), TO_NUMBER(NULL)) prj_etc_revenue     -- new
                        , bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                        , bl.burdened_COST                  func_BRDN_COST
                        , bl.revenue                        func_revenue
                        , DECODE(ver.wp_flag, 'N', bl.init_raw_cost , TO_NUMBER(NULL))                 func_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.init_burdened_cost , TO_NUMBER(NULL))            func_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.init_revenue , TO_NUMBER(NULL))                  func_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.raw_cost - NVL(bl.init_raw_cost, 0)), TO_NUMBER(NULL)) func_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), TO_NUMBER(NULL)) func_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.revenue - NVL(bl.init_revenue, 0)), TO_NUMBER(NULL)) func_etc_revenue     -- new
                        , g_global1_currency_code   glb1_currency_code -- g_global1_currency_code         glb1_currency_code
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_raw_cost
                                                  , bl.project_currency_code
                                                  , bl.project_raw_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.raw_cost
                                                  , ROUND((rates.rate * raw_cost )/rates.mau)*rates.mau
                                        ) glb1_raw_cost
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_burdened_cost
                                                  , bl.project_currency_code
                                                  , bl.project_burdened_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.burdened_cost
                                                  , ROUND((rates.rate * burdened_cost )/rates.mau)*rates.mau
                                        ) glb1_BRDN_COST
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_revenue
                                                  , bl.project_currency_code
                                                  , bl.project_revenue
                                                  , bl.projfunc_currency_code
                                                  , bl.revenue
                                                  , ROUND((rates.rate * revenue )/rates.mau)*rates.mau
                                        )  glb1_revenue
                              , DECODE(ver.wp_flag
                                     , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_raw_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_raw_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_raw_cost
                                                         , ROUND((rates.rate * bl.init_raw_cost )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))                 glb1_actual_raw_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_burdened_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_burdened_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_burdened_cost
                                                         , ROUND((rates.rate * bl.init_burdened_cost )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))            glb1_actual_brdn_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_revenue
                                                         , bl.project_currency_code
                                                         , bl.project_init_revenue
                                                         , bl.projfunc_currency_code
                                                         , bl.init_revenue
                                                         , ROUND((rates.rate * bl.init_revenue )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))                  glb1_actual_revenue
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
                                                         , ROUND((rates.rate * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))                glb1_etc_raw_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
                                                         , ROUND((rates.rate * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))    glb1_etc_brdn_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.revenue - NVL(bl.init_revenue, 0))
                                                         , ROUND((rates.rate * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , TO_NUMBER(NULL))    glb1_etc_revenue
                        , g_global2_currency_code   glb2_currency_code -- g_global2_currency_code         glb2_currency_code
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_raw_cost
                                                  , bl.project_currency_code
                                                  , bl.project_raw_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.raw_cost
                                                  , ROUND((rates.rate2 * raw_cost )/rates.mau2)*rates.mau2
                                        ) glb2_raw_cost
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_burdened_cost
                                                  , bl.project_currency_code
                                                  , bl.project_burdened_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.burdened_cost
                                                  , ROUND((rates.rate2 * burdened_cost )/rates.mau2)*rates.mau2
                                        ) glb2_BRDN_COST
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_revenue
                                                  , bl.project_currency_code
                                                  , bl.project_revenue
                                                  , bl.projfunc_currency_code
                                                  , bl.revenue
                                                  , ROUND((rates.rate2 * revenue )/rates.mau2)*rates.mau2
                                        )  glb2_revenue
                              , DECODE(ver.wp_flag
                                     , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_raw_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_raw_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_raw_cost
                                                         , ROUND((rates.rate2 * bl.init_raw_cost )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                 glb2_actual_raw_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_burdened_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_burdened_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_burdened_cost
                                                         , ROUND((rates.rate2 * bl.init_burdened_cost )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))            glb2_actual_brdn_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_revenue
                                                         , bl.project_currency_code
                                                         , bl.project_init_revenue
                                                         , bl.projfunc_currency_code
                                                         , bl.init_revenue
                                                         , ROUND((rates.rate2 * bl.init_revenue )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                  glb2_actual_revenue
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
                                                         , ROUND((rates.rate2 * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                glb2_etc_raw_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
                                                         , ROUND((rates.rate2 * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))    glb2_etc_brdn_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.revenue - NVL(bl.init_revenue, 0))
                                                         , ROUND((rates.rate2 * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))    glb2_etc_revenue
                          , bl.quantity                    quantity
                                , DECODE(ver.wp_flag, 'N', bl.init_quantity, TO_NUMBER(NULL))                  actual_quantity  -- new
                                , DECODE(ver.wp_flag, 'N', (bl.quantity - NVL(bl.init_quantity, 0)), TO_NUMBER(NULL)) etc_quantity  -- new
                                , ra.planning_start_date  start_date
                                , ra.planning_END_date    end_date
                                , ver.time_phased_type_code time_phased_type_code
                                , ppa.org_id project_org_id
                                , ppa.carrying_out_organization_id project_organization_id
                                  , 'NTP' line_type
                        ,decode(ver.rate_dangling_flag,'Y',-1,1) rate
                        ,decode(ver.rate_dangling_flag,'Y',-1,1) rate2
                        , ver.plan_type_code plan_type_code  /* 4471527 */
                        FROM
                       PA_BUDGET_LINES               bl
                     , pa_resource_asSIGNments       ra
                     , PJI_FM_EXTR_PLNVER3_T           ver
                         , pa_projects_all               ppa
                           , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                           , PJI_FM_AGGR_DLY_RATES_T         rates
                           -- , pji_time_cal_period           prd
                           -- , PJI_ORG_EXTR_INFO             oei
                           , pji_fp_txn_accum_header       hdr
                           , pa_rbs_txn_accum_map          map
                           , pji_pjp_rbs_header            rhdr
                 WHERE 1=1
                           AND ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
                     AND ver.project_id = pevs.project_id -- Fix for bug : 4149422 in EXTRACT_PLAN_AMTS_SECRBS_GLC12
                                 AND pevs.element_version_id = ver.wbs_struct_version_id
                                 AND ver.secondary_rbs_flag = 'Y'
                                         AND ver.wp_flag = 'N'
                                         -- AND oei.org_id = ppa.org_id
                                         AND ver.time_phased_type_code = 'N' -- IN (g_pa_cal_str, g_gl_cal_str)
                                         AND rates.time_id = DECODE ( g_currency_conversion_rule
                               , g_start_str
                                         , TO_NUMBER(to_CHAR(ra.planning_start_date, 'J'))
                                         , g_end_str
                                         , TO_NUMBER(to_CHAR(ra.planning_end_date, 'J')) )
                                          AND ra.txn_accum_header_id = hdr.txn_accum_header_id
                                          AND ra.txn_accum_header_id = map.txn_accum_header_id
                                          AND map.struct_version_id = rhdr.rbs_version_id
                                          AND ra.budget_version_id = rhdr.plan_version_id
                                          AND ppa.project_id = ra.project_id
                                AND ver.rbs_struct_version_id = rhdr.rbs_version_id
                                  ) spread_bl
                                   ---- end of third inline view 'spread_bl'...........
                  ,
                    (
                      select 1   INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR1_FLAG') = 'Y' union all /* Added for bug 8708651 */
                      select 2   INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR2_FLAG') = 'Y' union all
                      select 4   INVERT_ID from dual union all
                      select 8   INVERT_ID from dual union all
                      select 16  INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
                                )  collapse_bl
                                ----  End of second inline view 'collapse_bl' ..........
                        GROUP BY
              collapse_bl.PROJECT_ID
                        , collapse_bl.time_id
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                        , collapse_bl.plan_type_id
            , collapse_bl.plan_version_id
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.start_date
            , collapse_bl.end_date
            , collapse_bl.row_id
                        , collapse_bl.line_type
                        , collapse_bl.calendar_type
                        , collapse_bl.period_type_id
            ,collapse_bl.rate
             ,collapse_bl.rate2
            , collapse_bl.plan_type_code   /* 4471527 */
       ) plr
                                ----  End of first inline view plr ..........
           , pji_fm_extr_plnver3_t vers
          WHERE 1=1
            AND vers.plan_version_id = plr.plan_version_id
                 AND vers.plan_type_code = plr.plan_type_code   /*4471527 */
          -- AND plr.CURR_RECORD_TYPE IS NOT NULL
          AND vers.rbs_struct_version_id = plr.rbs_struct_version_id
          AND plr.currency_code IS NOT NULL
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , plr.time_id
       , plr.period_type_id
       , plr.CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
           , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.plan_version_id
         , plr.plan_type_id
       , plr.start_date
         , plr.end_date
         , plr.line_type
         ,decode(sign(plr.rate),-1,'Y',NULL) ||decode(sign(plr.rate2),-1,'Y',NULL)
         , plr.plan_type_code ;    /* 4471527 */


  print_time ( ' EXTRACT_PLAN_AMTS_SECRBS_GLC12 end. Inserted rows # is: ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_PLAN_AMOUNTS_SECRBS : Exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_PLAN_AMTS_SECRBS_GLC12');
    RAISE;
END;

--EXTRACT_PLAN_AMTS_PRIRBS_GLC12

PROCEDURE EXTRACT_PLAN_AMTS_PRIRBS_GLC12 IS
BEGIN

    print_time ( ' EXTRACT_PLAN_AMTS_PRIRBS_GLC12 begin. Inserted rows # is: ' || SQL%ROWCOUNT );

    PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
      x_currency_conversion_rule => g_currency_conversion_rule
    , x_prorating_format         => g_prorating_format
    , x_global1_currency_code    => g_global1_currency_code
    , x_global2_currency_code    => g_global2_currency_code
    , x_global1_currency_mau     => g_global1_currency_mau
    , x_global2_currency_mau     => g_global2_currency_mau ) ;


  print_time(' Got global currency settings. ');
  print_time(' g_currency_conversion_rule ' || g_currency_conversion_rule || ' g_prorating_format ' ||  g_prorating_format );
  print_time(' g_global1_currency_code ' || g_global1_currency_code || ' g_global2_currency_code ' || g_global2_currency_code );
  print_time(' g_global1_currency_mau ' || g_global1_currency_mau || ' g_global2_currency_mau ' || g_global2_currency_mau ) ;

    INSERT INTO PJI_FP_AGGR_PJP1_T
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       , START_DATE
       , END_DATE
       , PRG_LEVEL
       , PLAN_TYPE_CODE
        )
       SELECT
         g_worker_id WORKER_ID
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , plr.time_id
       , plr.period_type_id -- period type id...
       , plr.CALENDAR_TYPE
       , g_lowest_level RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.plan_version_id
       , plr.plan_type_id
       , SUM(plr.RAW_COST)
       , SUM(plr.BRDN_COST)
       , SUM(plr.REVENUE)
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )  BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )   BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code, plr.raw_cost, 0 ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code , plr.BRDN_COST, 0 ) )   BILL_LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code, plr.quantity, 0 ) )  BILL_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code,
                                                                  DECODE(plr.billable_flag,'Y',plr.quantity,0), 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.raw_cost, 0 ) )  EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.BRDN_COST, 0 ) )   EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )      CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )      CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.raw_cost, 0 ) )  LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.BRDN_COST, 0 ) )   LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                                    0 ) )   labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, DECODE(plr.billable_flag ,'Y',
                                                                    DECODE ( vers.wp_flag, 'N',
                                                                             DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
						                   0 ),
                                                    0 ) )   labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.revenue, 0 ) )  LABOR_REVENUE
       /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),

                                            0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code, DECODE(plr.billable_flag ,'Y',
                                                                   DECODE ( vers.wp_flag, 'N',
                                                                            DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
						                   0 ),
                                            0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_equip_resclass_code, plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_equip_resclass_code,
                                                                 DECODE(plr.billable_flag,'Y',plr.quantity,0), 0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , TO_NUMBER(NULL)  SUP_INV_COMMITTED_COST
       , TO_NUMBER(NULL)  PO_COMMITTED_COST
       , TO_NUMBER(NULL)  PR_COMMITTED_COST
       , TO_NUMBER(NULL)  OTH_COMMITTED_COST
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_BRDN_COST, 0 ) ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_BRDN_COST, 0 ) ) ) ACT_EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_brdn_cost ) ) ACT_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_raw_cost ) ) ACT_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.actual_revenue ) ) ACT_REVENUE
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_RAW_COST, 0 ) ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_RAW_COST, 0 ) ) ) ACT_EQUIPMENT_RAW_COST
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_BRDN_COST, 0 ) ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_BRDN_COST, 0 ) ) ) ETC_EQUIP_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.etc_brdn_cost ) ) ETC_BRDN_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, plr.etc_raw_cost ) ) ETC_RAW_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_raw_COST, 0 ) ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( vers.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_raw_COST, 0 ) ) ) ETC_EQUIP_raw_COST
       , TO_NUMBER(NULL) CUSTOM1
       , TO_NUMBER(NULL) CUSTOM2
       , TO_NUMBER(NULL) CUSTOM3
       , TO_NUMBER(NULL) CUSTOM4
       , TO_NUMBER(NULL) CUSTOM5
       , TO_NUMBER(NULL) CUSTOM6
       , TO_NUMBER(NULL) CUSTOM7
       , TO_NUMBER(NULL) CUSTOM8
       , TO_NUMBER(NULL) CUSTOM9
       , TO_NUMBER(NULL) CUSTOM10
       , TO_NUMBER(NULL) CUSTOM11
       , TO_NUMBER(NULL) CUSTOM12
       , TO_NUMBER(NULL) CUSTOM13
       , TO_NUMBER(NULL) CUSTOM14
       , TO_NUMBER(NULL) CUSTOM15
       , plr.LINE_TYPE
       , NULL time_dangling_flag
        , decode(sign(plr.rate),-1,'Y',NULL) ||decode(sign(plr.rate2),-1,'Y',NULL) rate_dangling_flag
       , plr.start_date
         , plr.end_date
       , g_default_prg_level prg_level
       , plr.plan_type_code  plan_type_code  /* 4471527 */
       FROM
       (          ----- First inline view plr .............
            select
              collapse_bl.PROJECT_ID      -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID  -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                    , collapse_bl.plan_type_id
            , collapse_bl.plan_version_id
                        , collapse_bl.time_id
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.raw_cost))) raw_cost
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.BRDN_COST))) BRDN_COST
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.revenue))) revenue
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.actual_raw_cost))) actual_raw_cost
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.actual_BRDN_COST))) actual_BRDN_COST
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.actual_revenue))) actual_revenue
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.etc_raw_cost))) etc_raw_cost
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.etc_BRDN_COST))) etc_BRDN_COST
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.etc_revenue))) etc_revenue
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.quantity))) quantity
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.actual_quantity))) actual_quantity
            , decode(sign(collapse_bl.rate),-1,0,decode(sign(collapse_bl.rate2),-1,0,max(collapse_bl.etc_quantity))) etc_quantity
            , collapse_bl.start_date start_date
            , collapse_bl.end_date   end_date
            -- , collapse_bl.period_name period_name  -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
                        , collapse_bl.line_type
                        , collapse_bl.calendar_type
                        , collapse_bl.period_type_id
            , collapse_bl.row_id
            ,collapse_bl.rate rate
            ,collapse_bl.rate2 rate2
            ,collapse_bl.plan_type_code plan_type_code  /* 4471527 */
            from
              (                  ----- Second inline view 'collapse_bl' begin .............
               select
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID plan_version_id
                                , spread_bl.time_id
                , spread_bl.RESOURCE_ASSIGNMENT_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
                        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , spread_bl.TIME_PHASED_TYPE_CODE
                , DECODE( invert.INVERT_ID
                        , 1, spread_bl.glb1_CURRENCY_CODE
                        , 2, spread_bl.glb2_CURRENCY_CODE
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_raw_cost
                         , 2, spread_bl.glb2_raw_cost
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_brdn_cost
                         , 2, spread_bl.glb2_brdn_cost
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_revenue
                         , 2, spread_bl.glb2_revenue
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
                                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_actual_raw_cost
                         , 2, spread_bl.glb2_actual_raw_cost
                                         , 4, spread_bl.func_actual_raw_cost
                                                 , 8, spread_bl.prj_actual_raw_cost
                                                 , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_actual_brdn_cost
                                                 , 2, spread_bl.glb2_actual_brdn_cost
                                         , 4, spread_bl.func_actual_brdn_cost
                                                 , 8, spread_bl.prj_actual_brdn_cost
                                                 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_actual_revenue
                                                 , 2, spread_bl.glb2_actual_revenue
                                         , 4, spread_bl.func_actual_revenue
                                                 , 8, spread_bl.prj_actual_revenue
                                                 , 16, spread_bl.txn_actual_revenue ) actual_revenue
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_etc_raw_cost
                                                 , 2, spread_bl.glb2_etc_raw_cost
                                         , 4, spread_bl.func_etc_raw_cost
                                                 , 8, spread_bl.prj_etc_raw_cost
                                                 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_etc_brdn_cost
                                                 , 2, spread_bl.glb2_etc_brdn_cost
                                         , 4, spread_bl.func_etc_brdn_cost
                                                 , 8, spread_bl.prj_etc_brdn_cost
                                                 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
                                , DECODE ( invert.INVERT_ID
                                         , 1, spread_bl.glb1_etc_revenue
                                                 , 2, spread_bl.glb2_etc_revenue
                                         , 4, spread_bl.func_etc_revenue
                                                 , 8, spread_bl.prj_etc_revenue
                                                 , 16, spread_bl.txn_etc_revenue ) etc_revenue
                , spread_bl.quantity quantity
                , spread_bl.actual_quantity actual_quantity
                , spread_bl.etc_quantity etc_quantity
                , spread_bl.start_date start_date
                , spread_bl.end_date   end_date
                , spread_bl.line_type line_type
                                , spread_bl.period_type_id
                                , spread_bl.calendar_type
                ,decode(invert.invert_id,1,spread_bl.rate,1) rate
                ,decode(invert.invert_id,2,spread_bl.rate2,1) rate2
                , spread_bl.plan_type_code plan_type_code /* 4471527 */
                from
                  (     ----- Third inline view 'spread_bl'  .............
                    SELECT
                          ra.project_id
                        , bl.rowid row_id
                        , ra.budget_version_id
                                        , prd.cal_period_id time_id
                        , bl.resource_asSIGNment_id
                        , DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                        , NVL(ra.rbs_element_id, -1)              rbs_element_id
                        , ver.wbs_struct_version_id      wbs_struct_version_id
                        , NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id
                        , ver.plan_type_id               plan_type_id
                        , ra.rate_based_flag             billable_flag
                        , ra.resource_class_code         resource_class
                        , DECODE(ver.time_phased_type_code
               , g_pa_cal_str, 32
               , g_gl_cal_str, 32
               , 'N', 2048
               , -1) period_type_id
                           , DECODE(ver.time_phased_type_code
               , g_pa_cal_str, g_pa_cal_str
               , g_gl_cal_str, g_gl_cal_str
               , 'N', g_all
               , 'X')  CALENDAR_TYPE
                        , bl.txn_currency_code           txn_currency_code
                        , bl.txn_raw_cost                txn_raw_cost
                        , bl.txn_burdened_COST           txn_brdn_COST
                        , bl.txn_revenue                 txn_revenue
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_raw_cost, TO_NUMBER(NULL))                txn_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_burdened_cost, TO_NUMBER(NULL))             txn_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.txn_init_revenue, TO_NUMBER(NULL))                   txn_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), TO_NUMBER(NULL)) txn_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), TO_NUMBER(NULL)) txn_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), TO_NUMBER(NULL)) txn_etc_revenue     -- new
                        , bl.project_currency_code          prj_currency_code
                        , bl.project_raw_cost               prj_raw_cost
                        , bl.project_burdened_COST          prj_BRDN_COST
                        , bl.project_revenue                prj_revenue
                        , DECODE(ver.wp_flag, 'N', bl.project_init_raw_cost, TO_NUMBER(NULL))          prj_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.project_init_burdened_cost, TO_NUMBER(NULL))     prj_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.project_init_revenue, TO_NUMBER(NULL))           prj_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), TO_NUMBER(NULL)) prj_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), TO_NUMBER(NULL)) prj_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.project_revenue - NVL(bl.project_init_revenue, 0)), TO_NUMBER(NULL)) prj_etc_revenue     -- new
                        , bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                        , bl.burdened_COST                  func_BRDN_COST
                        , bl.revenue                        func_revenue
                        , DECODE(ver.wp_flag, 'N', bl.init_raw_cost , TO_NUMBER(NULL))                 func_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.init_burdened_cost , TO_NUMBER(NULL))            func_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N', bl.init_revenue , TO_NUMBER(NULL))                  func_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.raw_cost - NVL(bl.init_raw_cost, 0)), TO_NUMBER(NULL)) func_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), TO_NUMBER(NULL)) func_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N', (bl.revenue - NVL(bl.init_revenue, 0)), TO_NUMBER(NULL)) func_etc_revenue     -- new
                        , g_global1_currency_code  glb1_currency_code -- g_global1_currency_code        glb1_currency_code
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_raw_cost
                                                  , bl.project_currency_code
                                                  , bl.project_raw_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.raw_cost
                                                  , ROUND((rates.rate * raw_cost )/rates.mau)*rates.mau
                                        ) glb1_raw_cost
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_burdened_cost
                                                  , bl.project_currency_code
                                                  , bl.project_burdened_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.burdened_cost
                                                  , ROUND((rates.rate * burdened_cost )/rates.mau)*rates.mau
                                        ) glb1_BRDN_COST
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_revenue
                                                  , bl.project_currency_code
                                                  , bl.project_revenue
                                                  , bl.projfunc_currency_code
                                                  , bl.revenue
                                                  , ROUND((rates.rate * revenue )/rates.mau)*rates.mau
                                        )  glb1_revenue
                              , DECODE(ver.wp_flag
                                     , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_raw_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_raw_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_raw_cost
                                                         , ROUND((rates.rate * bl.init_raw_cost )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)                 glb1_actual_raw_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_burdened_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_burdened_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_burdened_cost
                                                         , ROUND((rates.rate * bl.init_burdened_cost )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)            glb1_actual_brdn_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_revenue
                                                         , bl.project_currency_code
                                                         , bl.project_init_revenue
                                                         , bl.projfunc_currency_code
                                                         , bl.init_revenue
                                                         , ROUND((rates.rate * bl.init_revenue )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)                  glb1_actual_revenue
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
                                                         , ROUND((rates.rate * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)                glb1_etc_raw_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
                                                         , ROUND((rates.rate * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)    glb1_etc_brdn_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.revenue - NVL(bl.init_revenue, 0))
                                                         , ROUND((rates.rate * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)    glb1_etc_revenue
                        , g_global2_currency_code  glb2_currency_code -- g_global2_currency_code        glb2_currency_code
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_raw_cost
                                                  , bl.project_currency_code
                                                  , bl.project_raw_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.raw_cost
                                                  , ROUND((rates.rate2 * raw_cost )/rates.mau2)*rates.mau2
                                        ) glb2_raw_cost
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_burdened_cost
                                                  , bl.project_currency_code
                                                  , bl.project_burdened_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.burdened_cost
                                                  , ROUND((rates.rate2 * burdened_cost )/rates.mau2)*rates.mau2
                                        ) glb2_BRDN_COST
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_revenue
                                                  , bl.project_currency_code
                                                  , bl.project_revenue
                                                  , bl.projfunc_currency_code
                                                  , bl.revenue
                                                  , ROUND((rates.rate2 * revenue )/rates.mau2)*rates.mau2
                                        )  glb2_revenue
                              , DECODE(ver.wp_flag
                                     , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_raw_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_raw_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_raw_cost
                                                         , ROUND((rates.rate2 * bl.init_raw_cost )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                 glb2_actual_raw_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_burdened_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_burdened_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_burdened_cost
                                                         , ROUND((rates.rate2 * bl.init_burdened_cost )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))            glb2_actual_brdn_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_revenue
                                                         , bl.project_currency_code
                                                         , bl.project_init_revenue
                                                         , bl.projfunc_currency_code
                                                         , bl.init_revenue
                                                         , ROUND((rates.rate2 * bl.init_revenue )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                  glb2_actual_revenue
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
                                                         , ROUND((rates.rate2 * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                glb2_etc_raw_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
                                                         , ROUND((rates.rate2 * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))    glb2_etc_brdn_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.revenue - NVL(bl.init_revenue, 0))
                                                         , ROUND((rates.rate2 * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))    glb2_etc_revenue
                  , bl.quantity                    quantity
                        , DECODE(ver.wp_flag, 'N', bl.init_quantity, TO_NUMBER(NULL))                  actual_quantity  -- new
                        , DECODE(ver.wp_flag, 'N', (bl.quantity - NVL(bl.init_quantity, 0)), TO_NUMBER(NULL)) etc_quantity  -- new
                        , TO_DATE(NULL) start_date -- bl.start_date
                        , TO_DATE(NULL) end_date -- bl.END_date
                        , ver.time_phased_type_code time_phased_type_code
                        , ppa.org_id project_org_id
                        , ppa.carrying_out_organization_id project_organization_id
                                        , DECODE(ver.time_phased_type_code, g_pa_cal_str, 'OF', g_gl_cal_str, 'OF', 'N', 'NTP', 'X') line_type
                        ,decode(ver.rate_dangling_flag,'Y',-1,1) rate
                        ,decode(ver.rate_dangling_flag,'Y',-1,1) rate2
                        , ver.plan_type_code plan_type_code  /* 4471527 */
                                 FROM
                       PA_BUDGET_LINES               bl
                     , pa_resource_asSIGNments       ra
                     , PJI_FM_EXTR_PLNVER3_T           ver
                             , pa_projects_all               ppa
                                 , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                                         , PJI_FM_AGGR_DLY_RATES_T           rates
                                         , pji_time_cal_period_v           prd
                                         , PJI_ORG_EXTR_INFO             oei
                 WHERE 1=1
                                     AND ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
                                 AND pevs.element_version_id = ver.wbs_struct_version_id
                                 AND ver.secondary_rbs_flag = 'N'
                                         AND ver.wp_flag = 'N'
                                         AND oei.org_id = ppa.org_id
                                         AND ver.time_phased_type_code IN (g_pa_cal_str, g_gl_cal_str)
                                         AND DECODE ( ver.time_phased_type_code
                                                    , g_pa_cal_str, oei.pa_calendar_id
                                                                , g_gl_cal_str, oei.gl_calendar_id) = prd.calendar_id
                                         AND bl.period_name = prd.name
                                         AND rates.time_id = prd.cal_period_id
-- AND DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) = 7474
 --                                          AND ra.rbs_element_id = 10266
 --                                        AND ver.plan_version_id = 2909
                     AND ver.project_id = pevs.project_id -- Fix for bug : 4149422 in EXTRACT_PLAN_AMTS_PRIRBS_GLC12
                UNION ALL
                    SELECT
                          ra.project_id
                        , bl.rowid row_id
                        , ra.budget_version_id
                                        , -1 time_id
                        , bl.resource_asSIGNment_id
                        , DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                        , NVL(ra.rbs_element_id, -1)              rbs_element_id
                        , ver.wbs_struct_version_id      wbs_struct_version_id
                        , NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id
                        , ver.plan_type_id               plan_type_id
                        , ra.rate_based_flag             billable_flag
                        , ra.resource_class_code         resource_class
                        , 2048 period_type_id
                           , g_all CALENDAR_TYPE
                        , bl.txn_currency_code           txn_currency_code
                        , bl.txn_raw_cost                txn_raw_cost
                        , bl.txn_burdened_COST           txn_brdn_COST
                        , bl.txn_revenue                 txn_revenue
                        , DECODE(ver.wp_flag, 'N' , bl.txn_init_raw_cost, TO_NUMBER(NULL))                txn_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N' , bl.txn_init_burdened_cost, TO_NUMBER(NULL))             txn_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N' , bl.txn_init_revenue, TO_NUMBER(NULL))                   txn_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), TO_NUMBER(NULL)) txn_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), TO_NUMBER(NULL)) txn_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), TO_NUMBER(NULL)) txn_etc_revenue     -- new
                        , bl.project_currency_code          prj_currency_code
                        , bl.project_raw_cost               prj_raw_cost
                        , bl.project_burdened_COST          prj_BRDN_COST
                        , bl.project_revenue                prj_revenue
                        , DECODE(ver.wp_flag, 'N' , bl.project_init_raw_cost, TO_NUMBER(NULL))          prj_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N' , bl.project_init_burdened_cost, TO_NUMBER(NULL))     prj_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N' , bl.project_init_revenue, TO_NUMBER(NULL))           prj_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), TO_NUMBER(NULL)) prj_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), TO_NUMBER(NULL)) prj_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.project_revenue - NVL(bl.project_init_revenue, 0)), TO_NUMBER(NULL)) prj_etc_revenue     -- new
                        , bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                        , bl.burdened_COST                  func_BRDN_COST
                        , bl.revenue                        func_revenue
                        , DECODE(ver.wp_flag, 'N' , bl.init_raw_cost , TO_NUMBER(NULL))                 func_actual_raw_cost  -- new
                        , DECODE(ver.wp_flag, 'N' , bl.init_burdened_cost , TO_NUMBER(NULL))            func_actual_brdn_cost  -- new
                        , DECODE(ver.wp_flag, 'N' , bl.init_revenue , TO_NUMBER(NULL))                  func_actual_revenue  -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.raw_cost - NVL(bl.init_raw_cost, 0)), TO_NUMBER(NULL)) func_etc_raw_cost     -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), TO_NUMBER(NULL)) func_etc_brdn_cost     -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.revenue - NVL(bl.init_revenue, 0)), TO_NUMBER(NULL)) func_etc_revenue     -- new
                        , g_global1_currency_code   glb1_currency_code -- g_global1_currency_code         glb1_currency_code
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_raw_cost
                                                  , bl.project_currency_code
                                                  , bl.project_raw_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.raw_cost
                                                  , ROUND((rates.rate * raw_cost )/rates.mau)*rates.mau
                                        ) glb1_raw_cost
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_burdened_cost
                                                  , bl.project_currency_code
                                                  , bl.project_burdened_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.burdened_cost
                                                  , ROUND((rates.rate * burdened_cost )/rates.mau)*rates.mau
                                        ) glb1_BRDN_COST
                  , DECODE (g_global1_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_revenue
                                                  , bl.project_currency_code
                                                  , bl.project_revenue
                                                  , bl.projfunc_currency_code
                                                  , bl.revenue
                                                  , ROUND((rates.rate * revenue )/rates.mau)*rates.mau
                                        )  glb1_revenue
                              , DECODE(ver.wp_flag
                                     , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_raw_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_raw_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_raw_cost
                                                         , ROUND((rates.rate * bl.init_raw_cost )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)                 glb1_actual_raw_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_burdened_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_burdened_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_burdened_cost
                                                         , ROUND((rates.rate * bl.init_burdened_cost )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)            glb1_actual_brdn_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_revenue
                                                         , bl.project_currency_code
                                                         , bl.project_init_revenue
                                                         , bl.projfunc_currency_code
                                                         , bl.init_revenue
                                                         , ROUND((rates.rate * bl.init_revenue )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)                  glb1_actual_revenue
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
                                                         , ROUND((rates.rate * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)                glb1_etc_raw_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
                                                         , ROUND((rates.rate * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)    glb1_etc_brdn_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global1_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.revenue - NVL(bl.init_revenue, 0))
                                                         , ROUND((rates.rate * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau)*rates.mau
                                                      )
                                                 , NULL)    glb1_etc_revenue
                        , g_global2_currency_code   glb2_currency_code -- g_global2_currency_code         glb2_currency_code
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_raw_cost
                                                  , bl.project_currency_code
                                                  , bl.project_raw_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.raw_cost
                                                  , ROUND((rates.rate2 * raw_cost )/rates.mau2)*rates.mau2
                                        ) glb2_raw_cost
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_burdened_cost
                                                  , bl.project_currency_code
                                                  , bl.project_burdened_cost
                                                  , bl.projfunc_currency_code
                                                  , bl.burdened_cost
                                                  , ROUND((rates.rate2 * burdened_cost )/rates.mau2)*rates.mau2
                                        ) glb2_BRDN_COST
                  , DECODE (g_global2_currency_code
                                          , bl.txn_currency_code
                                                  , bl.txn_revenue
                                                  , bl.project_currency_code
                                                  , bl.project_revenue
                                                  , bl.projfunc_currency_code
                                                  , bl.revenue
                                                  , ROUND((rates.rate2 * revenue )/rates.mau2)*rates.mau2
                                        )  glb2_revenue
                              , DECODE(ver.wp_flag
                                     , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_raw_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_raw_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_raw_cost
                                                         , ROUND((rates.rate2 * bl.init_raw_cost )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                 glb2_actual_raw_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_burdened_cost
                                                         , bl.project_currency_code
                                                         , bl.project_init_burdened_cost
                                                         , bl.projfunc_currency_code
                                                         , bl.init_burdened_cost
                                                         , ROUND((rates.rate2 * bl.init_burdened_cost )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))            glb2_actual_brdn_cost
                              , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , bl.txn_init_revenue
                                                         , bl.project_currency_code
                                                         , bl.project_init_revenue
                                                         , bl.projfunc_currency_code
                                                         , bl.init_revenue
                                                         , ROUND((rates.rate2 * bl.init_revenue )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                  glb2_actual_revenue
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
                                                         , ROUND((rates.rate2 * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))                glb2_etc_raw_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
                                                         , ROUND((rates.rate2 * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))    glb2_etc_brdn_cost
                                  , DECODE(ver.wp_flag
                                         , 'N'
                                                 , DECODE (g_global2_currency_code
                                                 , bl.txn_currency_code
                                                         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
                                                         , bl.project_currency_code
                                                         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
                                                         , bl.projfunc_currency_code
                                                         , (bl.revenue - NVL(bl.init_revenue, 0))
                                                         , ROUND((rates.rate2 * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau2)*rates.mau2
                                                      )
                                                 , TO_NUMBER(NULL))    glb2_etc_revenue
                  , bl.quantity                    quantity
                        , DECODE(ver.wp_flag, 'N' , bl.init_quantity, TO_NUMBER(NULL))                  actual_quantity  -- new
                        , DECODE(ver.wp_flag, 'N' , (bl.quantity - NVL(bl.init_quantity, 0)), TO_NUMBER(NULL)) etc_quantity  -- new
                        , ra.planning_start_date
                        , ra.planning_END_date
                        , ver.time_phased_type_code time_phased_type_code
                        , ppa.org_id project_org_id
                        , ppa.carrying_out_organization_id project_organization_id
                                        , 'NTP' line_type
                        ,decode(ver.rate_dangling_flag,'Y',-1,1) rate
                        ,decode(ver.rate_dangling_flag,'Y',-1,1) rate2
                        , ver.plan_type_code  plan_type_code   /* 4471527 */
                                 FROM
                       PA_BUDGET_LINES               bl
                     , pa_resource_asSIGNments       ra
                     , PJI_FM_EXTR_PLNVER3_T           ver
                             , pa_projects_all               ppa
                                 , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                                         , PJI_FM_AGGR_DLY_RATES_T           rates
                 WHERE 1=1
                                     AND ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
                     AND ver.project_id = pevs.project_id -- Fix for bug : 4149422 in EXTRACT_PLAN_AMTS_PRIRBS_GLC12
                                 AND pevs.element_version_id = ver.wbs_struct_version_id
                                 AND ver.secondary_rbs_flag = 'N'
                                         AND ver.wp_flag = 'N'
                                         AND ver.time_phased_type_code = 'N'
                                         AND rates.time_id = DECODE ( g_currency_conversion_rule
                               , 'S'
                                         , TO_NUMBER(to_CHAR(ra.planning_start_date, 'J'))
                                         , 'E'
                                         , TO_NUMBER(to_CHAR(ra.planning_end_date, 'J')) )
                                  ) spread_bl
                                   ---- end of third inline view 'spread_bl'...........
                  ,
                    (
                      select 1   INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR1_FLAG') = 'Y' union all /* Added for bug 8708651 */
                      select 2   INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR2_FLAG') = 'Y' union all
                      select 4   INVERT_ID from dual union all
                      select 8   INVERT_ID from dual union all
                      select 16  INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
                                )  collapse_bl  -- WHERE wbs_element_id = 7474 -- and rbs_element_id = 10266 -- and budget_version_id = 2909
                                ----  End of second inline view 'collapse_bl' ..........
                        GROUP BY
              collapse_bl.PROJECT_ID
                        , collapse_bl.time_id
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                        , collapse_bl.plan_type_id
            , collapse_bl.plan_version_id
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.start_date
            , collapse_bl.end_date
            , collapse_bl.row_id
                        , collapse_bl.line_type
                        , collapse_bl.calendar_type
                        , collapse_bl.period_type_id
            ,collapse_bl.rate
            ,collapse_bl.rate2
            ,collapse_bl.plan_type_code   /* 4471527 */
       ) plr
                                ----  End of first inline view plr ..........
           , pji_fm_extr_plnver3_t vers
          WHERE 1=1
            AND vers.plan_version_id = plr.plan_version_id
                 AND vers.plan_type_code = plr.plan_type_code  /*4471527 */
                AND NVL(vers.rbs_struct_version_id, -1) = plr.rbs_struct_version_id
          -- AND plr.CURR_RECORD_TYPE IS NOT NULL
          AND plr.currency_code IS NOT NULL
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , plr.time_id
       , plr.period_type_id
       , plr.CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
           , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.plan_version_id
         , plr.plan_type_id
       , plr.start_date
         , plr.end_date
        , plr.line_type
        ,decode(sign(plr.rate),-1,'Y',NULL) ||decode(sign(plr.rate2),-1,'Y',NULL)
        , plr.plan_type_code;   /* 4471527 */

  print_time ( ' EXTRACT_PLAN_AMTS_PRIRBS_GLC12 end. Inserted rows # is: ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_PLAN_AMTS_PRIRBS_GLC12 : Exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_PLAN_AMTS_PRIRBS_GLC12');
    RAISE;
END;


PROCEDURE REVERSE_PLAN_AMTS IS
BEGIN

  print_time ( '.....Begin REVERSE_PLAN_AMTS. ' );

  INSERT INTO pji_fp_aggr_pjp1_t  fact
  (
       WORKER_ID
     , PRG_LEVEL
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
         , LINE_TYPE
     , PLAN_TYPE_CODE
  )
   SELECT  -- Reversal from fact for primary slice.
       g_worker_id
     , g_default_prg_level
     , fact.PROJECT_ID
     , fact.PROJECT_ORG_ID
     , fact.PROJECT_ORGANIZATION_ID
     , fact.PROJECT_ELEMENT_ID
     , fact.TIME_ID
     , fact.PERIOD_TYPE_ID
     , fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID  CURR_RECORD_TYPE_ID
     , fact.CURRENCY_CODE
     , fact.RBS_ELEMENT_ID
     , fact.RBS_VERSION_ID
     , fact.PLAN_VERSION_ID
     , fact.PLAN_TYPE_ID
    , -fact.RAW_COST
    , -fact.BRDN_COST
    , -fact.REVENUE
    , -fact.BILL_RAW_COST
    , -fact.BILL_BRDN_COST
    , -fact.BILL_LABOR_RAW_COST
    , -fact.BILL_LABOR_BRDN_COST
    , -fact.BILL_LABOR_HRS
    , -fact.EQUIPMENT_RAW_COST
    , -fact.EQUIPMENT_BRDN_COST
    , -fact.CAPITALIZABLE_RAW_COST
    , -fact.CAPITALIZABLE_BRDN_COST
    , -fact.LABOR_RAW_COST
    , -fact.LABOR_BRDN_COST
    , -fact.LABOR_HRS
    , -fact.LABOR_REVENUE
    , -fact.EQUIPMENT_HOURS
    , -fact.BILLABLE_EQUIPMENT_HOURS
    , -fact.SUP_INV_COMMITTED_COST
    , -fact.PO_COMMITTED_COST
    , -fact.PR_COMMITTED_COST
    , -fact.OTH_COMMITTED_COST
     , - fact.ACT_LABOR_HRS
         , -fact.ACT_EQUIP_HRS
         , -fact.ACT_LABOR_BRDN_COST
         , -fact.ACT_EQUIP_BRDN_COST
         , -fact.ACT_BRDN_COST
         , -fact.ACT_RAW_COST
         , -fact.ACT_REVENUE
       , -fact.ACT_LABOR_RAW_COST
       , -fact.ACT_EQUIP_RAW_COST
         , -fact.ETC_LABOR_HRS
         , -fact.ETC_EQUIP_HRS
         , -fact.ETC_LABOR_BRDN_COST
         , -fact.ETC_EQUIP_BRDN_COST
         , -fact.ETC_BRDN_COST
       , -fact.ETC_RAW_COST
       , -fact.ETC_LABOR_RAW_COST
       , -fact.ETC_EQUIP_RAW_COST
    , -fact.CUSTOM1
    , -fact.CUSTOM2
    , -fact.CUSTOM3
    , -fact.CUSTOM4
    , -fact.CUSTOM5
    , -fact.CUSTOM6
    , -fact.CUSTOM7
    , -fact.CUSTOM8
    , -fact.CUSTOM9
    , -fact.CUSTOM10
    , -fact.CUSTOM11
    , -fact.CUSTOM12
    , -fact.CUSTOM13
    , -fact.CUSTOM14
    , -fact.CUSTOM15
    , g_ntp_period_name
    , fact.plan_type_code   /* 4471527 */
    FROM
      pji_fp_xbs_accum_f fact
    , pji_fm_extr_plnver3_t ver
    WHERE 1=1
      AND fact.plan_version_id = ver.plan_version_id
      AND fact.plan_type_code = ver.plan_type_code  /* 4471527 */
      AND fact.project_id = ver.project_id
      AND fact.rbs_aggr_level = g_lowest_level
      AND fact.wbs_rollup_flag = 'N'
      AND ver.secondary_rbs_flag = 'N'
      AND (
               ((ver.time_phased_type_code IN ('P', 'G')) AND (fact.period_type_id = 32))
            OR ((ver.time_phased_type_code = 'N') AND (fact.period_type_id = 2048))
          );

    print_time ( '.....End REVERSE_PLAN_AMTS. # rows = ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time('REVERSE_PLAN_AMTS : Exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'REVERSE_PLAN_AMTS');
    RAISE;
END;


PROCEDURE DELETE_PRI_NONTIMEPH_ENTDAMTS IS
BEGIN

  DELETE FROM pji_fp_aggr_pjp1_t
  WHERE 1=1
    AND period_type_id = 32
    AND time_id = -1
    AND worker_id = g_worker_id;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'RETRIEVE_RL_SECSLC_TIMEPH');
    RAISE;
END;


--
-- Inserts into FP reporting lines fact the data in the interim pjp1 table.
--
PROCEDURE INSERT_INTO_FP_FACT ( p_slice_type IN VARCHAR2 := NULL) IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN

  IF ( (p_slice_type = 'PRI') OR (p_slice_type IS NULL) ) THEN

    MERGE_INTO_FP_FACT;

  ELSIF (p_slice_type = 'SEC') THEN

    DELETE FROM pji_fp_aggr_pjp1_t
    WHERE line_type = 'OF'
      AND worker_id = g_worker_id;  -- Data in entered calendar should not be rolled up.

    MERGE_INTO_FP_FACT;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_INTO_FP_FACT');
    RAISE;
END;


PROCEDURE GET_PRI_SLICE_DATA(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F') IS
BEGIN

  FORALL I IN p_fp_version_ids.FIRST..p_fp_version_ids.LAST
    INSERT INTO PJI_FP_AGGR_PJP1_T
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
     , PLAN_TYPE_CODE         /* 4471527 */
    )
    (
     SELECT
       g_worker_id
     , rl.PROJECT_ID
     , rl.PROJECT_ORG_ID
     , rl.PROJECT_ORGANIZATION_ID
     -- , rl.PARTITION_ID
     , rl.PROJECT_ELEMENT_ID
     , rl.TIME_ID
     , rl.PERIOD_TYPE_ID
     , rl.CALENDAR_TYPE
     , rl.RBS_AGGR_LEVEL
     , rl.WBS_ROLLUP_FLAG
     , rl.PRG_ROLLUP_FLAG
     , rl.CURR_RECORD_TYPE_ID
     , rl.CURRENCY_CODE
     , rl.RBS_ELEMENT_ID
     , rl.RBS_VERSION_ID
     , rl.PLAN_VERSION_ID
     , rl.PLAN_TYPE_ID
     , rl.RAW_COST
     , rl.BRDN_COST
     , rl.REVENUE
     , rl.BILL_RAW_COST
     , rl.BILL_BRDN_COST
     , rl.BILL_LABOR_RAW_COST
     , rl.BILL_LABOR_BRDN_COST
     , rl.BILL_LABOR_HRS
     , rl.EQUIPMENT_RAW_COST
     , rl.EQUIPMENT_BRDN_COST
     , rl.CAPITALIZABLE_RAW_COST
     , rl.CAPITALIZABLE_BRDN_COST
     , rl.LABOR_RAW_COST
     , rl.LABOR_BRDN_COST
     , rl.LABOR_HRS
     , rl.LABOR_REVENUE
     , rl.EQUIPMENT_HOURS
     , rl.BILLABLE_EQUIPMENT_HOURS
     , rl.SUP_INV_COMMITTED_COST
     , rl.PO_COMMITTED_COST
     , rl.PR_COMMITTED_COST
     , rl.OTH_COMMITTED_COST
       , rl.ACT_LABOR_HRS
           , rl.ACT_EQUIP_HRS
           , rl.ACT_LABOR_BRDN_COST
           , rl.ACT_EQUIP_BRDN_COST
           , rl.ACT_BRDN_COST
           , rl.ACT_RAW_COST
           , rl.ACT_REVENUE
         , rl.ACT_LABOR_RAW_COST
         , rl.ACT_EQUIP_RAW_COST
           , rl.ETC_LABOR_HRS
           , rl.ETC_EQUIP_HRS
           , rl.ETC_LABOR_BRDN_COST
           , rl.ETC_EQUIP_BRDN_COST
           , rl.ETC_BRDN_COST
         , rl.ETC_RAW_COST
         , rl.ETC_LABOR_RAW_COST
         , rl.ETC_EQUIP_RAW_COST
     , rl.CUSTOM1
     , rl.CUSTOM2
     , rl.CUSTOM3
     , rl.CUSTOM4
     , rl.CUSTOM5
     , rl.CUSTOM6
     , rl.CUSTOM7
     , rl.CUSTOM8
     , rl.CUSTOM9
     , rl.CUSTOM10
     , rl.CUSTOM11
     , rl.CUSTOM12
     , rl.CUSTOM13
     , rl.CUSTOM14
     , rl.CUSTOM15
     , g_default_prg_level
     , rl.PLAN_TYPE_CODE        /* 4471527 */
    FROM
         pji_fp_xbs_accum_f rl
       , pa_budget_versions bv -- @pjdev115 bv
         , pa_proj_fp_options fpo -- @pjdev115 fpo
    WHERE
         rl.project_id = bv.project_id
     AND bv.version_type IS NOT NULL
     AND bv.fin_plan_type_id IS NOT NULL
     AND fpo.project_id = bv.project_id
     AND bv.fin_plan_type_id = fpo.fin_plan_type_id
     AND bv.budget_version_id = fpo.fin_plan_version_id
     AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
     AND rl.calendar_type =
                DECODE( bv.version_type
                      , g_all_timeph_code,     fpo.all_time_phased_code
                      , g_cost_timeph_code,    fpo.cost_time_phased_code
                      , g_rev_timeph_code, fpo.revenue_time_phased_code
                     )
     AND rl.plan_version_id = p_fp_version_ids(i));


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_PRI_SLICE_DATA');
    RAISE;
END;


PROCEDURE INSERT_ACTUALS_FROM_PREVPLAN IS
BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_PRI_SLICE_DATA');
    RAISE;
END;


PROCEDURE UPDATE_ACTUALS_TO_NULL IS
BEGIN

  UPDATE PJI_FM_EXTR_PLAN_LINES        bl
  SET
                          bl.act_txn_raw_cost      = NULL
                        , bl.act_txn_burdened_cost = NULL
                        , bl.act_txn_revenue       = NULL
                        , bl.act_prj_raw_cost      = NULL
                        , bl.act_prj_burdened_cost = NULL
                        , bl.act_prj_revenue       = NULL
                        , bl.act_pfc_raw_cost      = NULL
                        , bl.act_pfc_burdened_cost = NULL
                        , bl.act_pfc_revenue       = NULL
                        , bl.act_quantity          = NULL
  WHERE 1=1
   AND bl.rowid IN ( SELECT extr_lines_rowid FROM pji_fp_rmap_fpr_update_t);

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'UPDATE_ACTUALS_TO_NULL');
    RAISE;
END;

-- RETRIEVE_DELTA_SLICE
PROCEDURE RETRIEVE_DELTA_SLICE IS
  l_count NUMBER := NULL;

  l_count_temp  NUMBER := NULL;
  l_max_plnver_id  NUMBER := NULL;
  l_per_analysis_flag  varchar2(2);   /* Added for bug 8708651 */

  CURSOR c_struct_ver_ids IS
  SELECT wbs_struct_version_id
  FROM   PJI_FM_EXTR_PLNVER3_T;

BEGIN

l_per_analysis_flag := PJI_UTILS.GET_SETUP_PARAMETER('PER_ANALYSIS_FLAG');  /* Added for bug 8708651 */

    print_time('........RETRIEVE_DELTA_SLICE : Begin.' );

    INSERT_NTP_CAL_RECORD ( x_max_plnver_id => l_max_plnver_id );

    IF (l_max_plnver_id IS NULL) THEN
      RETURN;
    END IF;

    INSERT INTO PJI_FP_AGGR_PJP1_T
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       -- , START_DATE
       -- , END_DATE
       , PRG_LEVEL
       , PLAN_TYPE_CODE      /* 4471527 */
        )
       SELECT
         g_worker_id
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(l_per_analysis_flag,'Y',
              decode(plr.time_phased_type_code          -- change from vers to plr for bug 4604617
              , 'N', -1
              , pji_time.cal_period_id),-1)  time_id /* Added for bug 8947586 */
       , DECODE(l_per_analysis_flag,'Y',
               decode(vers.time_phased_type_code
               , g_pa_cal_str, 32
               , g_gl_cal_str, 32
               , 'N', 2048
               , -1),2048) period_type_id /* Added for bug 8708651 */
       , DECODE(l_per_analysis_flag,'Y',
               decode(vers.time_phased_type_code
               , g_pa_cal_str, g_pa_cal_str
               , g_gl_cal_str, g_gl_cal_str
               , 'N', g_all
               , 'X'),g_all)     /* Added for bug 8708651 */
       , g_lowest_level RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE  -- curr code missing.
           , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
           , plr.plan_type_id
       , SUM(plr.RAW_COST)
       , SUM(plr.BRDN_COST)
       , SUM(plr.REVENUE)
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) ) -- BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) ) --  BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code, plr.raw_cost, 0 ) ) -- BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code , plr.BRDN_COST, 0 ) ) --  BILL_LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code, plr.quantity, 0 ) ) -- BILL_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code,
                                                                  DECODE(plr.billable_flag,'Y',plr.quantity,0) , 0 ) ) -- BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.raw_cost, 0 ) ) -- EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.BRDN_COST, 0 ) ) --  EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )    --   CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) ) --     CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.raw_cost, 0 ) ) -- LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.BRDN_COST, 0 ) ) -- LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                                    0 ) )  --  labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, DECODE(plr.billable_flag,'Y',
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
						    0 ),
                                                    0 ) )  --  labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.revenue, 0 ) ) -- LABOR_REVENUE
       /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                            0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                            0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT', plr.quantity, 0 ) ) */ -- BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT',
                                                                 DECODE(plr.billable_flag,'Y',plr.quantity,0), 0 ) ) -- BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , NULL -- SUP_INV_COMMITTED_COST
       , NULL -- PO_COMMITTED_COST
       , NULL -- PR_COMMITTED_COST
       , NULL -- OTH_COMMITTED_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                   plr.actual_quantity),
                                                    0 ) )  ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE (plr.billable_flag ,'Y',
                                                    DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                   plr.actual_quantity),
  				             0 ),
                                                    0 ) )  ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                           DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                   plr.actual_quantity),
                                                    0 ) ) ACT_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                           DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                   plr.actual_quantity),
                                                    0 ) ) ACT_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_BRDN_COST, 0 ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_BRDN_COST, 0 ) ) ACT_EQUIPMENT_BRDN_COST
       , SUM ( plr.actual_brdn_cost ) ACT_BRDN_COST
       , SUM ( plr.actual_raw_cost ) ACT_RAW_COST
       , SUM ( plr.actual_revenue ) ACT_REVENUE
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_RAW_COST, 0 ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_RAW_COST, 0 ) ) ACT_EQUIPMENT_RAW_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                   plr.ETC_quantity),
                                             g_equip_resclass_code, decode(plr.etc_quantity, null, null,0), NULL ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE (plr.billable_flag ,'Y',
                                                    DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                   plr.ETC_quantity),
					    0),
                                             g_equip_resclass_code, decode(plr.etc_quantity, null, null,0), NULL ) ) ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                   plr.ETC_quantity),
                                            g_people_resclass_code, decode(plr.etc_quantity, null, null, 0), NULL ) ) ETC_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE (plr.billable_flag ,'Y', -- Bug 6348091
                                                DECODE ( vers.wp_flag, 'N',
                                                --DECODE (plr.billable_flag ,'Y', --Bug 6348091
                                                                   DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                   plr.ETC_quantity),
					    0),
                                            g_people_resclass_code, decode(plr.etc_quantity, null, null, 0), NULL ) ) ETC_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_BRDN_COST, g_equip_resclass_code, decode(plr.etc_BRDN_COST, null, null, 0), NULL ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code, plr.etc_BRDN_COST, g_people_resclass_code, decode(plr.etc_BRDN_COST, null, null, 0), NULL ) ) ETC_EQUIP_BRDN_COST
       , SUM ( plr.etc_brdn_cost ) ETC_BRDN_COST
       , SUM ( plr.etc_raw_cost ) ETC_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_raw_COST, g_equip_resclass_code, decode(plr.etc_RAW_COST, null, null, 0), NULL ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code, plr.etc_raw_COST, g_people_resclass_code, decode(plr.etc_RAW_COST, null, null, 0), NULL ) ) ETC_EQUIP_raw_COST
       , NULL CUSTOM1
       , NULL CUSTOM2
       , NULL CUSTOM3
       , NULL CUSTOM4
       , NULL CUSTOM5
       , NULL CUSTOM6
       , NULL CUSTOM7
       , NULL CUSTOM8
       , NULL CUSTOM9
       , NULL CUSTOM10
       , NULL CUSTOM11
       , NULL CUSTOM12
       , NULL CUSTOM13
       , NULL CUSTOM14
           , NULL CUSTOM15
       , 'OF' -- LINE_TYPE
       , NULL                            -- rate_dangling_flag
       , NULL --     time_dangling_flag
       , g_default_prg_level
       , plr.plan_type_code  plan_type_code  /* 4471527 */
       FROM
       (          ----- First inline view plr .............
            select
              collapse_bl.PROJECT_ID
            -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                        , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , max(collapse_bl.raw_cost) raw_cost
            , max(collapse_bl.BRDN_COST) BRDN_COST
            , max(collapse_bl.revenue) revenue
            , max(collapse_bl.act_raw_cost) actual_raw_cost
            , max(collapse_bl.act_BRDN_COST) actual_BRDN_COST
            , max(collapse_bl.act_revenue) actual_revenue
            , max(collapse_bl.etc_BRDN_COST) etc_raw_COST
            , max(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , max(collapse_bl.quantity) quantity
            , max(collapse_bl.act_quantity) actual_quantity
            , max(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.start_date start_date
            , collapse_bl.end_date   end_date
            , collapse_bl.period_name period_name
            -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
            , collapse_bl.row_id
            , collapse_bl.plan_type_code  plan_type_code   /* 4471527 */
            from
              (                  ----- Second inline view 'collapse_bl' begin .............
                select
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID
                -- , spread_bl.RESOURCE_ASSIGNMENT_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
                                , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS
                -- , spread_bl.CALENDAR_TYPE
                -- , pji_time.CALENDAR_ID
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , spread_bl.TIME_PHASED_TYPE_CODE
                , DECODE( invert.INVERT_ID
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.act_func_raw_cost
                         , 8, spread_bl.act_PRJ_raw_cost
                         , 16, spread_bl.act_TXN_raw_cost) act_raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.act_func_BRDN_COST
                         , 8, spread_bl.act_PRJ_BRDN_COST
                         , 16, spread_bl.act_TXN_BRDN_COST ) act_BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.act_func_revenue
                         , 8, spread_bl.act_PRJ_revenue
                         , 16, spread_bl.act_TXN_revenue ) act_revenue
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.etc_func_brdn_cost
                         , 8, spread_bl.etc_PRJ_brdn_cost
                         , 16, spread_bl.etc_TXN_brdn_cost ) etc_brdn_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.etc_pfc_raw_cost
                         , 8, spread_bl.etc_PRJ_raw_cost
                         , 16, spread_bl.etc_TXN_raw_cost) etc_raw_cost
                , spread_bl.quantity quantity
                                , spread_bl.act_quantity act_quantity
                                , spread_bl.etc_quantity etc_quantity
                , spread_bl.start_date start_date
                , spread_bl.end_date   end_date
                , spread_bl.period_name period_name
                -- , spread_bl.TRACK_AS_LABOR_FLAG track_as_labor_flag
                , spread_bl.plan_type_code  plan_type_code   /* 4471527 */
                from
                  (     ----- Third inline view 'spread_bl'  .............
                        -- Added hint for bug 3828698
                    SELECT
                          bl.project_id
                        , bl.rowid row_id
                        , bl.plan_version_id budget_version_id
                        -- , bl.resource_asSIGNment_id
                        , DECODE(bl.project_element_id, 0, pevs.proj_element_id, bl.project_element_id) wbs_element_id
                        , NVL(bl.rbs_element_id, -1)   rbs_element_id
                        , bl.struct_ver_id             wbs_struct_version_id
                  , DECODE( bl.rbs_element_id
                          , NULL
                          , -1
                          , NVL(ver.rbs_struct_version_id, -1)
                          )                       rbs_struct_version_id
                  , bl.plan_type_id               plan_type_id -- ver.plan_type_id
                  , bl.rate_based_flag            billable_flag -- ra.rate_based_flag             billable_flag
                  , bl.resource_class_code        resource_class -- ra.resource_class_code         resource_class
                        , bl.txn_currency_code          txn_currency_code
                        , bl.txn_raw_cost               txn_raw_cost
                        , bl.txn_burdened_COST          txn_BRDN_COST
                        , bl.txn_revenue                txn_revenue
                        , bl.act_txn_raw_cost           act_txn_raw_cost
                        , bl.act_txn_burdened_cost      act_txn_brdn_cost
                        , bl.act_txn_revenue            act_txn_revenue
                        , bl.etc_txn_burdened_cost      etc_txn_brdn_cost
                        , bl.prj_currency_code          prj_currency_code
                        , bl.prj_raw_cost               prj_raw_cost
                        , bl.prj_burdened_COST          prj_BRDN_COST
                        , bl.prj_revenue                prj_revenue
                        , bl.act_prj_raw_cost           act_prj_raw_cost
                        , bl.act_prj_burdened_cost      act_prj_brdn_cost
                        , bl.act_prj_revenue            act_prj_revenue
                        , bl.etc_prj_burdened_cost      etc_prj_brdn_cost
                        , bl.pfc_currency_code         func_currency_code
                  , bl.pfc_raw_cost                       func_raw_cost
                        , bl.pfc_burdened_COST                  func_BRDN_COST
                        , bl.pfc_revenue                     func_revenue
                        , bl.act_pfc_raw_cost           act_func_raw_cost
                        , bl.act_pfc_burdened_cost      act_func_brdn_cost
                        , bl.act_pfc_revenue            act_func_revenue
                        , bl.etc_pfc_burdened_cost      etc_func_brdn_cost
                        , bl.ETC_TXN_RAW_COST           ETC_TXN_RAW_COST
                        , bl.ETC_PRJ_RAW_COST           ETC_PRJ_RAW_COST
                        , bl.ETC_PFC_RAW_COST           ETC_PFC_RAW_COST
                        , 'DEF'                   glb1_currency_code
                  , NULL                           glb1_raw_cost
                        , NULL                           glb1_BRDN_COST
                        , NULL                           glb1_revenue
                        , 'ACB'        glb2_currency_code
                  , NULL                           glb2_raw_cost
                        , NULL                           glb1_BRDN_COST
                        , NULL                           glb1_revenue
                        , bl.quantity                       quantity
                        , bl.act_quantity                  act_quantity
                        , bl.etc_quantity                  etc_quantity
                        , DECODE(ver.time_phased_type_code, 'N', bl.start_date, NULL) start_date
                        , DECODE(ver.time_phased_type_code, 'N', bl.end_date, NULL) end_date
                        , NVL(bl.period_name, g_ntp_period_name)       period_name
                        , NVL(bl.calendar_type, ver.time_phased_type_code) time_phased_type_code
                        , bl.project_org_id                       project_org_id
                        , ppa.carrying_out_organization_id  project_organization_id
                        , ver.plan_type_code   plan_type_code  /* 4471527 */
                    FROM
                       PJI_FM_EXTR_PLAN_LINES        bl
                     , PJI_FM_EXTR_PLNVER3_T         ver
                                 , pa_projects_all               ppa
                                 , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                                 , pji_fp_rmap_fpr_update_t      rwid
                    WHERE 1=1
                                         AND bl.project_id = ver.project_id
                                         AND bl.plan_version_id = ver.plan_version_id
                                         AND bl.plan_type_id = ver.plan_type_id
                                         AND ppa.project_id = ver.project_id
                     AND bl.project_id = ppa.project_id -- Added for bug 3828698
                     AND ppa.project_id = pevs.project_id -- Added for bug 3838698
                                         AND bl.TXN_CURRENCY_CODE IS NOT NULL
                                         AND bl.prj_currency_code IS NOT NULL
                                         AND bl.pfc_currency_code IS NOT NULL
                                     AND pevs.element_version_id = ver.wbs_struct_version_id
                                         AND pevs.project_id = ver.project_id  -- Fix for bug : 4149422 in RETRIEVE_DELTA_SLICE
                               AND bl.ROWID = rwid.extr_lines_rowid
                                  ) spread_bl
                                   ---- end of third inline view 'spread_bl'...........
                  ,
                    (
                      select 4   INVERT_ID from dual union all
                      select 8   INVERT_ID from dual union all
                      select 16  INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
                                )  collapse_bl
                                ----  End of second inline view 'collapse_bl' ..........
                        GROUP BY
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                        , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.start_date
            , collapse_bl.end_date
            , collapse_bl.period_name
            , collapse_bl.row_id
            , collapse_bl.plan_type_code    /* 4471527 */
       ) plr
                                ----  End of first inline view plr ..........
       , PJI_ORG_EXTR_INFO            orginfo
       , PJI_FM_EXTR_PLNVER3_T     vers
       , pji_time_cal_period_v       pji_time
         WHERE  1=1
           AND    plr.project_org_id       = orginfo.org_id
           AND    plr.project_id             = vers.project_id
           AND    plr.budget_version_id      = vers.plan_version_id
           AND    plr.plan_type_code         = vers.plan_type_code    /*4471527 */
           AND    DECODE(plr.time_phased_type_code                       -- change from vers to plr for bug 4604617
                   , g_pa_cal_str, orginfo.pa_calendar_id
                   , g_gl_cal_str, orginfo.gl_calendar_id
                   , -l_max_plnver_id  ) = pji_time.calendar_id
           AND    plr.period_name = pji_time.name
           AND plr.time_phased_type_code IN (g_pa_cal_str, g_gl_cal_str, 'N')
       GROUP BY
         plr.PROJECT_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(l_per_analysis_flag,'Y',
              decode(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id),-1) /* Added for bug 8947586 */
       , DECODE(l_per_analysis_flag,'Y',
               decode(vers.time_phased_type_code
               , g_pa_cal_str, 32
               , g_gl_cal_str, 32
               , 'N', 2048
               , -1), 2048) /* Added for bug 8708651 */
       , DECODE(l_per_analysis_flag,'Y',
               decode(vers.time_phased_type_code
               , g_pa_cal_str, g_pa_cal_str
               , g_gl_cal_str, g_gl_cal_str
               , 'N', g_all
               , 'X'), g_all)    /* Added for bug 8708651 */
       , plr.CURR_RECORD_TYPE  -- curr code missing.
           , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
           , plr.plan_type_id
       , plr.BUDGET_VERSION_ID
       , plr.project_ORGANIZATION_ID
       , plr.project_ORG_ID
       , plr.plan_type_code ;   /* 4471527 */

  print_time('count is ... ' || SQL%ROWCOUNT );

  DELETE_NTP_CAL_RECORD ( p_max_plnver_id => l_max_plnver_id );

  print_time('........RETRIEVE_DELTA_SLICE : End.' );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'RETRIEVE_DELTA_SLICE');
    print_time('........RETRIEVE_DELTA_SLICE : Exception ' || sqlerrm );
    RAISE;
END;


PROCEDURE POPULATE_PLN_VER_TABLE IS
  l_count NUMBER := 0;
BEGIN

  print_time('........POPULATE_PLN_VER_TABLE : Begin.' );

    INSERT INTO PJI_FM_EXTR_PLNVER3_T
    (
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
        CURRENT_FLAG             ,
        ORIGINAL_FLAG            ,
        CURRENT_ORIGINAL_FLAG    ,
        BASELINED_FLAG           ,
      SECONDARY_RBS_FLAG
    )
  SELECT DISTINCT
          epl.project_id
          , epl.plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                   , 'Y', bv.project_structure_version_id
                     , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
                     )                           wbs_struct_version_id
          -- , epl.struct_ver_id
          , fpo.rbs_version_id -- epl.rbs_version_id
         -- , to_char(epl.plan_type_id) -- pln type code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
          , epl.plan_type_id
        , DECODE(bv.version_type
                  , g_all_timeph_code,     fpo.all_time_phased_code
                  , g_cost_timeph_code,    fpo.cost_time_phased_code
                  , g_rev_timeph_code, fpo.revenue_time_phased_code
                 )                       time_phased_type_code
          , null -- time dangling..
          , null -- time dangling..
          , null -- project type class is not used currently..
        , DECODE(bv.wp_version_flag, 'Y', 'Y', 'N') is_wp_flag
          , bv.current_flag                  current_flag
          , bv.original_flag                 original_flag
          , bv.current_original_flag         current_original_flag
          , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
        , 'N'
  FROM PJI_FM_EXTR_PLAN_LINES epl
     , pa_budget_versions bv
     , pa_proj_fp_options fpo
  WHERE
        epl.plan_version_id = bv.budget_version_id
    AND fpo.project_id = bv.project_id
    AND bv.fin_plan_type_id = fpo.fin_plan_type_id
    AND bv.budget_version_id = fpo.fin_plan_version_id
    AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
    AND epl.rowid IN ( SELECT extr_lines_rowid FROM pji_fp_rmap_fpr_update_t);


  print_time('count is ... ' || SQL%ROWCOUNT );

  print_time('........POPULATE_PLN_VER_TABLE : End.' );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_PLN_VER_TABLE');
    print_time('........POPULATE_PLN_VER_TABLE : Exception: ' || sqlerrm );
    RAISE;
END;


PROCEDURE GET_GLOBAL_EXCHANGE_RATES IS

  l_gl1_cur_code  VARCHAR2(15) := g_global1_currency_code;
  l_gl2_cur_code  VARCHAR2(15) := g_global2_currency_code;
  l_gl1_mau       NUMBER := g_global1_currency_mau;
  l_gl2_mau       NUMBER := g_global2_currency_mau;

BEGIN

  print_time('........GET_GLOBAL_EXCHANGE_RATES: Begin. ' );

    PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
      x_currency_conversion_rule => g_currency_conversion_rule
    , x_prorating_format         => g_prorating_format
    , x_global1_currency_code    => g_global1_currency_code
    , x_global2_currency_code    => g_global2_currency_code
    , x_global1_currency_mau     => g_global1_currency_mau
    , x_global2_currency_mau     => g_global2_currency_mau ) ;

  l_gl1_cur_code  := g_global1_currency_code;
  l_gl2_cur_code  := g_global2_currency_code;
  l_gl1_mau       := g_global1_currency_mau;
  l_gl2_mau       := g_global2_currency_mau;

  print_time(' Got global currency settings. ');
  print_time(' g_currency_conversion_rule ' || g_currency_conversion_rule || ' g_prorating_format ' ||  g_prorating_format );
  print_time(' g_global1_currency_code ' || g_global1_currency_code || ' g_global2_currency_code ' || g_global2_currency_code );
  print_time(' g_global1_currency_mau ' || g_global1_currency_mau || ' g_global2_currency_mau ' || g_global2_currency_mau ) ;


   DELETE FROM PJI_FM_AGGR_DLY_RATES_T
   WHERE worker_id = g_worker_id;
     -- Removed pa_resource_assignments join and Added joins with pji_org_extr_info
     -- for bug 4149422
      -- SQL for getting rates for time phased budgets.
      PJI_UTILS.g_max_roll_days := 1500;  /*5155692 */

  INSERT INTO PJI_FM_AGGR_DLY_RATES_T (
                WORKER_ID       ,
                PF_CURRENCY_CODE ,
                TIME_ID ,
                RATE    ,
                MAU     ,
                RATE2   ,
                MAU2)
   SELECT worker_id,
       projfunc_currency_code,
       time_id,
       PJI_UTILS.GET_GLOBAL_RATE_PRIMARY (temp.projfunc_currency_code
                      , DECODE ( g_currency_conversion_rule
                      , 'S'
                      , temp.start_date
                      , 'E'
                      , temp.end_date ))
       rate1,
       l_gl1_mau mau1,
       DECODE ( PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR2_FLAG'),
                'Y',
                PJI_UTILS.GET_GLOBAL_RATE_SECONDARY (temp.projfunc_currency_code,
                DECODE ( g_currency_conversion_rule
                       , 'S'
                       , temp.start_date
                       , 'E'
                       , temp.end_date ) ),
               NULL
              )
        rate2,
        l_gl2_mau mau2
   FROM (
          SELECT DISTINCT
                 g_worker_id worker_id
               , ppa.projfunc_currency_code
               , cal_period_id time_id
               , DECODE( g_currency_conversion_rule
                       , 'S'
                       , prd.start_date
                       , TO_DATE(NULL)
                       ) start_date
               , DECODE( g_currency_conversion_rule
                       , 'E'
                       , prd.end_date
                       , TO_DATE(NULL)
                       ) end_date
               , l_gl1_mau mau1
               , l_gl2_mau mau2
          FROM pa_budget_lines  bl
           , pa_budget_versions bv                           -- added for bug 5842896
           , pji_time_cal_period_v  prd
           , PJI_FM_EXTR_PLNVER3_T  ver
           , pa_projects_all ppa
           ,PJI_ORG_EXTR_INFO inf
         WHERE  bl.budget_version_id = ver.plan_version_id
            AND bl.budget_version_id = bv.budget_version_id  -- added for bug 5842896
            AND bv.project_id = ppa.project_id               -- added for bug 5842896
            AND ver.time_phased_type_code IN ('P', 'G')
            AND bl.period_name = prd.name
            AND ver.wp_flag = 'N'
            AND ver.baselined_flag = 'Y'
            AND ver.project_id = ppa.project_id
            --  Fix for bug : 4149422
            AND ppa.org_id = inf.org_id
            AND DECODE (ver.time_phased_type_code
                      , 'P'
                      , inf.pa_calendar_id
                      , 'G'
                      , inf.gl_calendar_id) = prd.calendar_id
            and budget_type_code is null --25-JUN-2009 cklee    fixed bug:6915879
      UNION ALL
          SELECT DISTINCT
                   g_worker_id worker_id
                 , ppa.projfunc_currency_code
                 , DECODE ( g_currency_conversion_rule
                          , 'S'
                          , TO_NUMBER(to_CHAR(ra.planning_start_date, 'J'))
                          , 'E'
                          , TO_NUMBER(to_CHAR(ra.planning_end_date, 'J')) ) time_id
                 , DECODE( g_currency_conversion_rule
                         , 'S'
                         , ra.planning_start_date
                         , TO_DATE(NULL)
                         ) start_date
                 , DECODE( g_currency_conversion_rule
                         , 'E'
                         , ra.planning_end_date
                         , TO_DATE(NULL)
                         ) end_date
                 , l_gl1_mau mau1
                 , l_gl2_mau mau2
          FROM pa_resource_assignments ra
             , PJI_FM_EXTR_PLNVER3_T  ver
             , pa_projects_all ppa
          WHERE ra.budget_version_id = ver.plan_version_id
            AND ver.wp_flag = 'N'
            AND ver.baselined_flag = 'Y'
            AND ver.time_phased_type_code = 'N'
            AND ver.project_id = ppa.project_id
         ) temp;

PJI_UTILS.g_max_roll_days := NULL;  /*5155692 */

/*  See if any line with negative rate was derived. If so then update the
    corresponding line in ver3 as rate dangling*/

        UPDATE PJI_FM_EXTR_PLNVER3_T ver
           SET rate_dangling_flag = 'Y'
          WHERE (project_id,plan_version_id)  IN
                        (    SELECT project_id,budget_version_id
                               FROM PA_BUDGET_LINES bl,
                                    pji_time_cal_period_v  prd,
                                    PJI_FM_AGGR_DLY_RATES_T rates
                              WHERE rates.time_id=prd.cal_period_id
                                AND bl.period_name = prd.name
                                AND (sign(rates.rate)=-1 OR sign(rates.rate2) = -1)
                                AND ver.time_phased_type_code IN ('P', 'G')
                          UNION ALL
                             SELECT project_id,budget_version_id
                               FROM pa_resource_assignments ra,
                                    PJI_FM_AGGR_DLY_RATES_T rates
                              WHERE rates.time_id= DECODE ( g_currency_conversion_rule
                                                                , 'S'
                                                                        , TO_NUMBER(to_CHAR(ra.planning_start_date, 'J'))
                                                                 , 'E'
                                                                         , TO_NUMBER(to_CHAR(ra.planning_end_date, 'J')) )
                                AND (sign(rates.rate)=-1 OR sign(rates.rate2) = -1)
                                AND ver.time_phased_type_code = 'N'
                        )
            AND ver.wp_flag = 'N'
            AND ver.baselined_flag = 'Y';


  print_time('........GET_GLOBAL_EXCHANGE_RATES: End. ' );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_GLOBAL_EXCHANGE_RATES');
    print_time('........GET_GLOBAL_EXCHANGE_RATES: Exception: ' || sqlerrm );
    RAISE;
END;


PROCEDURE DELETE_GLOBAL_EXCHANGE_RATES IS
BEGIN

  print_time('........DELETE_GLOBAL_EXCHANGE_RATES: Begin. ' );

  DELETE FROM PJI_FM_AGGR_DLY_RATES_T
  WHERE  worker_id = g_worker_id;

  print_time('........DELETE_GLOBAL_EXCHANGE_RATES: End. # rows is.. ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DELETE_GLOBAL_EXCHANGE_RATES');
    print_time('........DELETE_GLOBAL_EXCHANGE_RATES: Exception: ' || sqlerrm );
    RAISE;
END;


/*
PROCEDURE UPDATE_CURR_RCD_TYPES_GL1_GL2
IS BEGIN

   -- Algorithm is as follows:
   -- ------------------------
   -- 1. Get all relevant rows from rpting lines into tmp1 table (GET_PRI_SLICE_DATA already did this).
   -- 2. Create/Update records as needed based on exchange rates as follows.
   --     SQL 1: Update existing rcds for TXN if GL1/GL2 are equal to TXN.
   --     SQL 2: Update existing rcds for PRJ if GL1/GL2 are equal to PRJ and PRJ<>TXN.
   --     SQL 3: Update existing rcds for FUNC if GL1/GL2 are equal to FUNC and FUNC<> TXN/PRJ and PRJ<>TXN and 1, 2 don't hold true.
   --     SQL 4: Create new rcds using existing records for TXN if GL1/GL2 are not in (TXN, PRJ, FUNC).
   --     SQL 5: Update existing rcds for GL1 if GL2 is equal to GL1, etc.
   --     SQL 6: Create new rcds using existing records for TXN if GL2 is not in (TXN, PRJ, FUNC, GL1).
   --3. Merge the new records into rpting lines.

   PJI_FM_PLAN_MAINT_T_PVT.GET_GLOBAL_EXCHANGE_RATES;

   PJI_FM_PLAN_MAINT_T_PVT.CONV_TO_GLOBAL_CURRENCIES;

   -- This wont work!!!
   -- PJI_FM_PLAN_MAINT.MERGE_INTO_REPORTING_LNS_FACT;
   -- This wont work!!!

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'UPDATE_CURR_RCD_TYPES_GL1_GL2');
    RAISE;
END;
*/


--
-- Stubbed api.
--
/*
PROCEDURE CONV_TO_GLOBAL_CURRENCIES IS
  l_return_status VARCHAR2(1);
  l_ver3_is_empty VARCHAR2(1);
BEGIN

  print_time('........CONV_TO_GLOBAL_CURRENCIES: Begin. ' );

  --
  -- IF ver3 is empty, return.
  --
  l_ver3_is_empty := PJI_FM_PLAN_MAINT.CHECK_VER3_NOT_EMPTY ( p_online => 'T');
  IF (l_ver3_is_empty = 'T') THEN
    print_time ( ' ver3 is empty, nothing to process. Returning. ');
    RETURN;
  END IF;

  --
  -- Get currency conversion rules, global currency codes and gl maus.
  --
  PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
    x_currency_conversion_rule => g_currency_conversion_rule
  , x_prorating_format         => g_prorating_format
  , x_global1_currency_code    => g_global1_currency_code
  , x_global2_currency_code    => g_global2_currency_code
  , x_global1_currency_mau     => g_global1_currency_mau
  , x_global2_currency_mau     => g_global2_currency_mau ) ;

  --
  -- Todo: Remove hardcoded currency codes after making code work if one of the global currencies is null.
  --
  SELECT DECODE(g_global1_currency_code, NULL, 'USD', g_global1_currency_code)
  INTO g_global1_currency_code
  FROM DUAL;

  SELECT DECODE(g_global2_currency_code, NULL, 'USD', g_global2_currency_code)
  INTO g_global2_currency_code
  FROM DUAL;

  print_time(' Got global currency settings. ');
  print_time(' g_currency_conversion_rule ' || g_currency_conversion_rule || ' g_prorating_format ' ||  g_prorating_format );
  print_time(' g_global1_currency_code ' || g_global1_currency_code || ' g_global1_currency_code ' || g_global1_currency_code );
  print_time(' g_global1_currency_mau ' || g_global1_currency_mau || ' g_global1_currency_mau ' || g_global1_currency_mau ) ;


  --
  -- IF GL1 and GL2 currencies are not setup correctly, then return.
  --
  IF (g_global1_currency_code IS NULL AND g_global2_currency_code IS NULL) THEN
    print_time('Both global 1 currency and global 2 currency are not defined. Returning from conversion to Global currencies.');
    -- MARK_DANGLING_PLAN_VERSIONS;  -- !!! Todo. Mark dangling versions.
    RETURN;
  END IF;

  --
  -- Delete Smart Slice.
  --
  PJI_FM_XBS_ACCUM_MAINT.DELETE_SMART_SLICE (
      p_online_flag          => 'Y'
    , x_return_status        => l_return_status ) ;
  print_time(' Deleted smart slice rollups. # rows deleted is.. ' || SQL%ROWCOUNT);


  --
  -- Gets exchange rates for entries in fact for all those rows in fact and pjp1 based on
  --  if the currency code is same as functional currency code. Rates are based on start/end
  --  dates based on plan amt conversion. For non time phased amounts, it is based on
  --  start end dates for that period.
  --
  GET_GLOBAL_EXCHANGE_RATES;
  print_time(' Got exchange rates for global currencies. ');


  --
-- Inserts rows present in fact and pjp1 into pjp1 with inserted row worker id as
--  g_worker_id.
-- Logic is as follows:
--
--  SQL1: Reverse primary slice from fact for only those rows whose crti can be updated.
--  SQL2: Insert pri slice LNN from fact where CRTI can simply be updated.
--  SQL3: Insert GL1/2 currency record into pjp1 from fact whose crti cannot be updated
--          (meaning, whose func curr <> gl1, gl2).
--
--  SQL4: Insert primary slice from pjp0 for only those rows whose crti cannot be updated.
--  SQL5: Insert pri slice LNN from pjp0 whose CRTI can simply be updated with updated crti.
--  SQL6: Insert GL1/2 currency record into pjp1 from pjp0 whose crti cannot be updated
--          (meaning, whose func curr <> gl1, gl2).
--
  CREATE_GL1_GL2_CURR_RCDS;
  print_time(' Converted functional currency amounts to global 1, 2 currency amounts. ');


  --
  -- Proration to other calendars.
  --
  PRORATE_TO_ALL_CALENDARS;
  print_time(' Prorated to all other calendars. ');


  --
  -- RBS rollup.
  --
  PJI_FM_PLAN_MAINT_T_PVT.ROLLUP_FPR_RBS_T_SLICE;
  print_time(' Created RBS rollup slice. ');


  --
  -- WBS rollup.
  --
  PJI_FM_PLAN_MAINT_T_PVT.CREATE_WBSRLP;
  print_time(' Created WBS rollup slice. ');


  --
  -- Calendar rollup.
  --
  PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_PA_PRI_ROLLUP;
  print_time(' PA calendar rollup. ');

  PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_GL_PRI_ROLLUP;
  print_time(' GL calendar rollup. ');

  PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_ALLT_PRI_AGGREGATE;
  print_time(' All time slice rollup. ');

  PJI_FM_PLAN_CAL_RLPS_T.CREATE_FP_ENT_ROLLUP;
  print_time(' Enterprise calendar rollup. ');

  --
  -- Mark pji summarized flag in pa budget versions table.
  -- If rates are missing or GL1/GL2 definitions are missing, then mark those plans as 'P'
  --
  MARK_DANGLING_PLAN_VERSIONS;

  print_time('........CONV_TO_GLOBAL_CURRENCIES: End. ' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('........CONV_TO_GLOBAL_CURRENCIES: Exception ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CONV_TO_GLOBAL_CURRENCIES');
    RAISE;
END;
*/


PROCEDURE DELETE_DNGLRATE_PLNVER_DATA IS
BEGIN

  DELETE FROM pji_fp_aggr_pjp1_t
  WHERE plan_version_id IN
    (
          SELECT DISTINCT plan_version_id
          FROM   pji_fp_aggr_pjp1_t
          WHERE  worker_id = g_worker_id
        AND  rate_dangling_flag IS NOT NULL )
    AND worker_id = g_worker_id;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DELETE_DNGLRATE_PLNVER_DATA');
    RAISE;
END;


/*
--
-- Inserts rows present in fact and pjp1 into pjp1 with inserted row worker id as
--  g_worker_id.
-- Logic is as follows:
--
--  SQL1: Reverse primary slice from fact for only those rows whose crti can be updated.
--  SQL2: Insert pri slice LNN from fact where CRTI can simply be updated.
--  SQL3: Insert GL1/2 currency record into pjp1 from fact whose crti cannot be updated
--          (meaning, whose func curr <> gl1, gl2).
--
--  SQL4: Insert primary slice from pjp0 for only those rows whose crti cannot be updated.
--  SQL5: Insert pri slice LNN from pjp0 whose CRTI can simply be updated with updated crti.
--  SQL6: Insert GL1/2 currency record into pjp1 from pjp0 whose crti cannot be updated
--          (meaning, whose func curr <> gl1, gl2).
--
PROCEDURE CREATE_GL1_GL2_CURR_RCDS IS
BEGIN

  print_time('........CREATE_GL1_GL2_CURR_RCDS: Begin. ' );



    INSERT INTO PJI_FP_AGGR_PJP1_T
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       -- , START_DATE
       -- , END_DATE
       , PRG_LEVEL
       , PLAN_TYPE_CODE    -- 4471527
           )
          SELECT
         g_worker_id WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , SUM(CURR_RECORD_TYPE_ID)
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , max(RAW_COST)
       , max(BRDN_COST)
       , max(REVENUE)
       , max(BILL_RAW_COST)
       , max(BILL_BRDN_COST)
       , max(BILL_LABOR_RAW_COST)
       , max(BILL_LABOR_BRDN_COST)
       , max(BILL_LABOR_HRS)
       , max(EQUIPMENT_RAW_COST)
       , max(EQUIPMENT_BRDN_COST)
       , max(CAPITALIZABLE_RAW_COST)
       , max(CAPITALIZABLE_BRDN_COST)
       , max(LABOR_RAW_COST)
       , max(LABOR_BRDN_COST)
       , max(LABOR_HRS)
       , max(LABOR_REVENUE)
       , max(EQUIPMENT_HOURS)
       , max(BILLABLE_EQUIPMENT_HOURS)
       , max(SUP_INV_COMMITTED_COST)
       , max(PO_COMMITTED_COST)
       , max(PR_COMMITTED_COST)
       , max(OTH_COMMITTED_COST)
       , max(ACT_LABOR_HRS)
           , max(ACT_EQUIP_HRS)
           , max(ACT_LABOR_BRDN_COST)
           , max(ACT_EQUIP_BRDN_COST)
           , max(ACT_BRDN_COST)
           , max(ACT_RAW_COST)
           , max(ACT_REVENUE)
         , max(ACT_LABOR_RAW_COST)
         , max(ACT_EQUIP_RAW_COST)
           , max(ETC_LABOR_HRS)
           , max(ETC_EQUIP_HRS)
           , max(ETC_LABOR_BRDN_COST)
           , max(ETC_EQUIP_BRDN_COST)
           , max(ETC_BRDN_COST)
         , max(ETC_RAW_COST)
         , max(ETC_LABOR_RAW_COST)
         , max(ETC_EQUIP_RAW_COST)
       , max(CUSTOM1)
       , max(CUSTOM2)
       , max(CUSTOM3)
       , max(CUSTOM4)
       , max(CUSTOM5)
       , max(CUSTOM6)
       , max(CUSTOM7)
       , max(CUSTOM8)
       , max(CUSTOM9)
       , max(CUSTOM10)
       , max(CUSTOM11)
       , max(CUSTOM12)
       , max(CUSTOM13)
       , max(CUSTOM14)
       , max(CUSTOM15)
       , 'CF' LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       -- , START_DATE
       -- , END_DATE
       , g_default_prg_level PRG_LEVEL
       , PLAN_TYPE_CODE      -- 4471527
           FROM
           (
           SELECT    -- SQL1: Reversal of LNN Slice data in fact
         fact.PROJECT_ID
       , fact.PROJECT_ORG_ID
       , fact.PROJECT_ORGANIZATION_ID
       , fact.PROJECT_ELEMENT_ID
       , fact.TIME_ID
       , fact.PERIOD_TYPE_ID
       , fact.CALENDAR_TYPE
       , fact.RBS_AGGR_LEVEL
       , fact.WBS_ROLLUP_FLAG
       , fact.PRG_ROLLUP_FLAG
       , fact.CURR_RECORD_TYPE_ID
       , fact.CURRENCY_CODE
       , fact.RBS_ELEMENT_ID
       , fact.RBS_VERSION_ID
       , fact.PLAN_VERSION_ID
       , fact.PLAN_TYPE_ID
       , - RAW_COST RAW_COST
       , - BRDN_COST BRDN_COST
       , - REVENUE REVENUE
       , - BILL_RAW_COST BILL_RAW_COST
       , - BILL_BRDN_COST BILL_BRDN_COST
       , - BILL_LABOR_RAW_COST BILL_LABOR_RAW_COST
       , - BILL_LABOR_BRDN_COST BILL_LABOR_BRDN_COST
       , - BILL_LABOR_HRS BILL_LABOR_HRS
       , - EQUIPMENT_RAW_COST EQUIPMENT_RAW_COST
       , - EQUIPMENT_BRDN_COST EQUIPMENT_BRDN_COST
       , - CAPITALIZABLE_RAW_COST CAPITALIZABLE_RAW_COST
       , - CAPITALIZABLE_BRDN_COST CAPITALIZABLE_BRDN_COST
       , - LABOR_RAW_COST LABOR_RAW_COST
       , - LABOR_BRDN_COST LABOR_BRDN_COST
       , - LABOR_HRS LABOR_HRS
       , - LABOR_REVENUE LABOR_REVENUE
       , - EQUIPMENT_HOURS EQUIPMENT_HOURS
       , - BILLABLE_EQUIPMENT_HOURS BILLABLE_EQUIPMENT_HOURS
       , - SUP_INV_COMMITTED_COST SUP_INV_COMMITTED_COST
       , - PO_COMMITTED_COST PO_COMMITTED_COST
       , - PR_COMMITTED_COST PR_COMMITTED_COST
       , - OTH_COMMITTED_COST OTH_COMMITTED_COST
       , - ACT_LABOR_HRS ACT_LABOR_HRS
           , - ACT_EQUIP_HRS ACT_EQUIP_HRS
           , - ACT_LABOR_BRDN_COST ACT_LABOR_BRDN_COST
           , - ACT_EQUIP_BRDN_COST ACT_EQUIP_BRDN_COST
           , - ACT_BRDN_COST ACT_BRDN_COST
           , - ACT_RAW_COST ACT_RAW_COST
           , - ACT_REVENUE ACT_REVENUE
         , - ACT_LABOR_RAW_COST ACT_LABOR_RAW_COST
         , - ACT_EQUIP_RAW_COST ACT_EQUIP_RAW_COST
           , - ETC_LABOR_HRS ETC_LABOR_HRS
           , - ETC_EQUIP_HRS ETC_EQUIP_HRS
           , - ETC_LABOR_BRDN_COST ETC_LABOR_BRDN_COST
           , - ETC_EQUIP_BRDN_COST ETC_EQUIP_BRDN_COST
           , - ETC_BRDN_COST ETC_BRDN_COST
         , - ETC_RAW_COST ETC_RAW_COST
         , - ETC_LABOR_RAW_COST ETC_LABOR_RAW_COST
         , - ETC_EQUIP_RAW_COST ETC_EQUIP_RAW_COST
       , - CUSTOM1 CUSTOM1
       , - CUSTOM2 CUSTOM2
       , - CUSTOM3 CUSTOM3
       , - CUSTOM4 CUSTOM4
       , - CUSTOM5 CUSTOM5
       , - CUSTOM6 CUSTOM6
       , - CUSTOM7 CUSTOM7
       , - CUSTOM8 CUSTOM8
       , - CUSTOM9 CUSTOM9
       , - CUSTOM10 CUSTOM10
       , - CUSTOM11 CUSTOM11
       , - CUSTOM12 CUSTOM12
       , - CUSTOM13 CUSTOM13
       , - CUSTOM14 CUSTOM14
       , - CUSTOM15 CUSTOM15
       -- , 'OF' LINE_TYPE
       , null RATE_DANGLING_FLAG
       , null TIME_DANGLING_FLAG
       -- , 0 prg_level
          , fact.plan_type_code plan_type_code  -- 4471527
           FROM pji_fp_xbs_accum_f fact
              , pji_fm_extr_plnver3_t ver3
           WHERE 1=1
                 AND rbs_aggr_level = g_lowest_level
                 AND wbs_rollup_flag = 'N'
                 AND prg_rollup_flag = 'N'
                 AND fact.project_id = ver3.project_id
                 AND fact.plan_version_id = ver3.plan_version_id
                           AND fact.plan_type_code = ver3.plan_type_code   --4471527
             AND fact.currency_code IN (g_global1_currency_code, g_global2_currency_code)
    UNION ALL
    SELECT   --  SQL4: Insert GL1/2 currency record into pjp1 from pjp0 where func curr <> gl1, gl2.
       fact.PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , fact.TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , DECODE ( curr.curr_code
              , g_global1_currency_code, 2 + DECODE ( g_global1_currency_code, g_global2_currency_code, 1, 0)
              , g_global2_currency_code, 1 ) CURR_RECORD_TYPE_ID
     , curr.curr_code CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , fact.PLAN_VERSION_ID
     , fact.PLAN_TYPE_ID
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) *RAW_COST/curr.mau )*curr.mau  RAW_COST -- curr.mau  -- rates.mau   rates.mau2
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) *BRDN_COST/curr.mau )*curr.mau   BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 )  *REVENUE/curr.mau )*curr.mau   REVENUE
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 )  *BILL_RAW_COST/curr.mau )*curr.mau   BILL_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 )  *BILL_BRDN_COST/curr.mau )*curr.mau   BILL_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) *BILL_LABOR_RAW_COST/curr.mau )*curr.mau    BILL_LABOR_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) *BILL_LABOR_BRDN_COST/curr.mau )*curr.mau   BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * EQUIPMENT_RAW_COST/curr.mau )*curr.mau    EQUIPMENT_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * EQUIPMENT_BRDN_COST/curr.mau )*curr.mau   EQUIPMENT_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * CAPITALIZABLE_RAW_COST/curr.mau )*curr.mau   CAPITALIZABLE_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * CAPITALIZABLE_BRDN_COST/curr.mau )*curr.mau   CAPITALIZABLE_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * LABOR_RAW_COST/curr.mau )*curr.mau   LABOR_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * LABOR_BRDN_COST/curr.mau )*curr.mau   LABOR_BRDN_COST
     , LABOR_HRS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * LABOR_REVENUE/curr.mau )*curr.mau   LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * SUP_INV_COMMITTED_COST/curr.mau )*curr.mau   SUP_INV_COMMITTED_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * PO_COMMITTED_COST/curr.mau )*curr.mau    PO_COMMITTED_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * PR_COMMITTED_COST/curr.mau )*curr.mau    PR_COMMITTED_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * OTH_COMMITTED_COST/curr.mau )*curr.mau   OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_LABOR_BRDN_COST/curr.mau )*curr.mau    ACT_LABOR_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_EQUIP_BRDN_COST/curr.mau )*curr.mau    ACT_EQUIP_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_BRDN_COST/curr.mau )*curr.mau    ACT_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_RAW_COST/curr.mau )*curr.mau    ACT_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_REVENUE/curr.mau )*curr.mau   ACT_REVENUE
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_LABOR_RAW_COST/curr.mau )*curr.mau    ACT_LABOR_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_EQUIP_RAW_COST/curr.mau )*curr.mau    ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_LABOR_BRDN_COST/curr.mau )*curr.mau   ETC_LABOR_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_EQUIP_BRDN_COST/curr.mau )*curr.mau   ETC_EQUIP_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_BRDN_COST/curr.mau )*curr.mau    ETC_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_RAW_COST/curr.mau )*curr.mau    ETC_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_LABOR_RAW_COST/curr.mau )*curr.mau   ETC_LABOR_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_EQUIP_RAW_COST/curr.mau )*curr.mau   ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
         -- , 'OG' LINE_TYPE
     , DECODE ( DECODE (curr.curr_code
                             , g_global1_currency_code, rates.rate
                             , g_global2_currency_code, rates.rate2 )
                          , NULL, curr.curr_code
                          , NULL) rate_dangling_flag
       , null TIME_DANGLING_FLAG
       -- , 0 prg_level
      , fact.plan_type_code  plan_type_code      -- 4471527
  FROM pji_fp_aggr_pjp1_t fact
     , pa_projects_all ppa
         , ( SELECT g_global1_currency_code curr_code, 0.01 mau FROM DUAL
             UNION
                 SELECT g_global2_currency_code curr_code, 0.01 mau FROM DUAL
           ) curr
   , PJI_FM_AGGR_DLY_RATES_T    rates
   , ( SELECT cal_period_id period_id, start_date, end_date FROM pji_time_cal_period_v
       UNION ALL
       SELECT ent_period_id, start_date, end_date FROM pji_time_ent_period_v
         ) dates
   , pji_fm_extr_plnver3_t  ver
  WHERE 1=1
   AND fact.project_id = ver.project_id -- new
   AND fact.plan_version_id = ver.plan_version_id
   AND fact.plan_type_code = ver.plan_type_code   -- 4471527
   AND ver.wp_flag = 'N'
   AND ver.baselined_flag = 'Y'
   AND fact.project_id = ppa.project_id
   AND fact.time_id = dates.period_id
   AND fact.worker_id = -1
   AND ( ppa.projfunc_currency_code <> g_global1_currency_code
          OR ppa.projfunc_currency_code <> g_global2_currency_code )
   AND BITAND ( fact.curr_record_type_id, 4) = 4   -- 00100: Converting from Proj Func Currency.
   AND fact.currency_code = ppa.projfunc_currency_code
   AND rates.time_id = fact.time_id
   AND rates.pf_currency_code = ppa.projfunc_currency_code
   AND fact.calendar_type IN (g_gl_cal_str, g_pa_cal_str)
  UNION ALL
    SELECT   --  SQL3: Insert GL1/2 currency record into pjp1 from fact where func curr <> gl1, gl2.
       fact.PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , fact.TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , DECODE ( curr.curr_code
              , g_global1_currency_code, 2 + DECODE ( g_global1_currency_code, g_global2_currency_code, 1, 0)
              , g_global2_currency_code, 1 ) CURR_RECORD_TYPE_ID
     , curr.curr_code CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , fact.PLAN_VERSION_ID
     , fact.PLAN_TYPE_ID
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) *RAW_COST/curr.mau )*curr.mau  RAW_COST -- curr.mau  -- rates.mau   rates.mau2
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) *BRDN_COST/curr.mau )*curr.mau   BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 )  *REVENUE/curr.mau )*curr.mau   REVENUE
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 )  *BILL_RAW_COST/curr.mau )*curr.mau   BILL_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 )  *BILL_BRDN_COST/curr.mau )*curr.mau   BILL_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) *BILL_LABOR_RAW_COST/curr.mau )*curr.mau    BILL_LABOR_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) *BILL_LABOR_BRDN_COST/curr.mau )*curr.mau   BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * EQUIPMENT_RAW_COST/curr.mau )*curr.mau    EQUIPMENT_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * EQUIPMENT_BRDN_COST/curr.mau )*curr.mau   EQUIPMENT_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * CAPITALIZABLE_RAW_COST/curr.mau )*curr.mau   CAPITALIZABLE_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * CAPITALIZABLE_BRDN_COST/curr.mau )*curr.mau   CAPITALIZABLE_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * LABOR_RAW_COST/curr.mau )*curr.mau   LABOR_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * LABOR_BRDN_COST/curr.mau )*curr.mau   LABOR_BRDN_COST
     , LABOR_HRS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * LABOR_REVENUE/curr.mau )*curr.mau   LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * SUP_INV_COMMITTED_COST/curr.mau )*curr.mau   SUP_INV_COMMITTED_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * PO_COMMITTED_COST/curr.mau )*curr.mau    PO_COMMITTED_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * PR_COMMITTED_COST/curr.mau )*curr.mau    PR_COMMITTED_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * OTH_COMMITTED_COST/curr.mau )*curr.mau   OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_LABOR_BRDN_COST/curr.mau )*curr.mau    ACT_LABOR_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_EQUIP_BRDN_COST/curr.mau )*curr.mau    ACT_EQUIP_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_BRDN_COST/curr.mau )*curr.mau    ACT_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_RAW_COST/curr.mau )*curr.mau    ACT_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_REVENUE/curr.mau )*curr.mau   ACT_REVENUE
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_LABOR_RAW_COST/curr.mau )*curr.mau    ACT_LABOR_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ACT_EQUIP_RAW_COST/curr.mau )*curr.mau    ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_LABOR_BRDN_COST/curr.mau )*curr.mau   ETC_LABOR_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_EQUIP_BRDN_COST/curr.mau )*curr.mau   ETC_EQUIP_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_BRDN_COST/curr.mau )*curr.mau    ETC_BRDN_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_RAW_COST/curr.mau )*curr.mau    ETC_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_LABOR_RAW_COST/curr.mau )*curr.mau   ETC_LABOR_RAW_COST
     , ROUND(decode (curr.curr_code, g_global1_currency_code, rates.rate, g_global2_currency_code, rates.rate2 ) * ETC_EQUIP_RAW_COST/curr.mau )*curr.mau   ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
         -- , 'OG' LINE_TYPE
     , DECODE ( DECODE (curr.curr_code
                             , g_global1_currency_code, rates.rate
                             , g_global2_currency_code, rates.rate2 )
                          , NULL, curr.curr_code
                          , NULL) rate_dangling_flag
       , null TIME_DANGLING_FLAG
       -- , 0 prg_level
       , fact.plan_type_code plan_type_code    -- 4471527
  FROM pji_fp_xbs_accum_f fact
     , pa_projects_all ppa
         , ( SELECT g_global1_currency_code curr_code, 0.01 mau FROM DUAL
             UNION
                 SELECT g_global2_currency_code curr_code, 0.01 mau FROM DUAL
           ) curr
   , PJI_FM_AGGR_DLY_RATES_T    rates
   , ( SELECT cal_period_id period_id, start_date, end_date FROM pji_time_cal_period_v
       UNION ALL
       SELECT ent_period_id, start_date, end_date FROM pji_time_ent_period_v
         ) dates
   , pji_fm_extr_plnver3_t  ver
  WHERE 1=1
   AND fact.project_id = ver.project_id -- new
   AND fact.plan_version_id = ver.plan_version_id
   ANd fact.plan_type_code = ver.plan_type_code   -- 4471527
   AND ver.wp_flag = 'N'
   AND ver.baselined_flag = 'Y'
   AND fact.project_id = ppa.project_id
   AND fact.time_id = dates.period_id
   AND ( ppa.projfunc_currency_code <> g_global1_currency_code
          OR ppa.projfunc_currency_code <> g_global2_currency_code )
      AND BITAND ( fact.curr_record_type_id, 4) = 4   -- 00100: Converting from Proj Func Currency.
      AND fact.currency_code = ppa.projfunc_currency_code
          AND rates.time_id = fact.time_id
          AND rates.pf_currency_code = ppa.projfunc_currency_code
      AND fact.calendar_type IN (g_gl_cal_str, g_pa_cal_str)
          AND fact.rbs_aggr_level = g_lowest_level
          AND fact.wbs_rollup_flag = 'N'
          AND fact.prg_rollup_flag = 'N'
 UNION ALL
           SELECT    --  SQL 5: Insert pri slice LNN from pjp0 where CRTI can simply be updated.
         fact.PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
                          + DECODE (currency_code, g_global1_currency_code
                                                    , DECODE(BITAND(fact.curr_record_type_id, 2), 0, 2, 0)
                                                                , 0) -- 000.000.010 = 2
                          + DECODE (currency_code, g_global2_currency_code
                                                    , DECODE(BITAND(fact.curr_record_type_id, 1), 0, 1, 0)
                                                                , 0) -- 000.000.010 = 2
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , fact.PLAN_VERSION_ID
       , fact.PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       -- , LINE_TYPE
       , fact.RATE_DANGLING_FLAG
       , fact.TIME_DANGLING_FLAG
       -- , 0
       , fact.plan_type_code plan_type_code   --  4471527
           FROM pji_fp_aggr_pjp1_t fact
              , pji_fm_extr_plnver3_t ver
           WHERE 1=1
                 AND fact.worker_id = -1
             AND fact.project_id = ver.project_id
                 AND fact.plan_version_id = ver.plan_version_id
                           ANd fact.plan_type_code = ver.plan_type_code   -- 4471527
                 AND rbs_aggr_level = g_lowest_level
                 AND wbs_rollup_flag = 'N'
                 AND prg_rollup_flag = 'N'
                 AND ver.wp_flag = 'N'
                 AND ver.baselined_flag = 'Y'
                 AND BITAND(curr_record_type_id, 7) IN (4, 5, 6)
                 AND currency_code in ( g_global1_currency_code, g_global2_currency_code )
           UNION ALL
           SELECT    --  SQL 5: Insert pri slice LNN from fact where CRTI can simply be updated.
         fact.PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
                          + DECODE (currency_code, g_global1_currency_code
                                                    , DECODE(BITAND(fact.curr_record_type_id, 2), 0, 2, 0)
                                                                , 0) -- 000.000.010 = 2
                          + DECODE (currency_code, g_global2_currency_code
                                                    , DECODE(BITAND(fact.curr_record_type_id, 1), 0, 1, 0)
                                                                , 0) -- 000.000.010 = 2
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , fact.PLAN_VERSION_ID
       , fact.PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       -- , 'CF'
       , NULL
       , NULL
       -- , START_DATE
       -- , END_DATE
       -- , 0
          , fact.plan_type_code  plan_type_code  --  4471527
           FROM pji_fp_xbs_accum_f fact
              , pji_fm_extr_plnver3_t ver
           WHERE 1=1
             AND fact.project_id = ver.project_id
                 AND fact.plan_version_id = ver.plan_version_id
                          AND  fact.plan_type_code = ver.plan_type_code   -- 4471527
                 AND rbs_aggr_level = g_lowest_level
                 AND wbs_rollup_flag = 'N'
                 AND prg_rollup_flag = 'N'
                 AND ver.wp_flag = 'N'
                 AND ver.baselined_flag = 'Y'
                 AND BITAND(curr_record_type_id, 7) IN (4, 5, 6)
                 AND currency_code in ( g_global1_currency_code, g_global2_currency_code )
                 ) fact
                 GROUP BY
         PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
           , RATE_DANGLING_FLAG
           , TIME_DANGLING_FLAG
           , PLAN_TYPE_CODE ;    --- 4471527


  print_time('........CREATE_GL1_GL2_CURR_RCDS: End. ' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('........CREATE_GL1_GL2_CURR_RCDS: Exception. ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_GL1_GL2_CURR_RCDS');
    RAISE;
END;
*/


PROCEDURE UPDATE_TPFG1_CURR_RCDS
IS BEGIN

  print_time('........UPDATE_TPFG1_CURR_RCDS: Begin. ' );

  UPDATE pji_fp_xbs_accum_f
  SET CURR_RECORD_TYPE_ID = CURR_RECORD_TYPE_ID +
                       DECODE (currency_code, g_global1_currency_code, 2, 0) -- 000.000.010 = 2
                           + DECODE (currency_code, g_global2_currency_code, 1, 0) -- 000.000.001 = 1
  WHERE BITAND(curr_record_type_id, 28) >= 4   --  000.011.110 = 16 + 8 + 4  = 28
    AND (currency_code  IN (g_global1_currency_code, g_global2_currency_code))
    AND plan_version_id IN
         (SELECT DISTINCT plan_version_id
          FROM   PJI_FM_EXTR_PLNVER3_T
          WHERE  1=1
            AND  baselined_flag = 'Y'
            AND  wp_flag = 'N');

  UPDATE pji_fp_aggr_pjp1_t
  SET CURR_RECORD_TYPE_ID = CURR_RECORD_TYPE_ID +
                       DECODE (currency_code, g_global1_currency_code, 2, 0) -- 000.000.010 = 2
                           + DECODE (currency_code, g_global2_currency_code, 1, 0) -- 000.000.001 = 1
  WHERE BITAND(curr_record_type_id, 28) >= 4   --  000.011.110 = 16 + 8 + 4  = 28
    AND (currency_code  IN (g_global1_currency_code, g_global2_currency_code))
    AND worker_id = g_worker_id
    AND plan_version_id IN
         (SELECT DISTINCT plan_version_id
          FROM   PJI_FM_EXTR_PLNVER3_T
          WHERE  1=1
            AND  baselined_flag = 'Y'
            AND  wp_flag = 'N');

  print_time('........UPDATE_TPFG1_CURR_RCDS: End. ' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('........UPDATE_TPFG1_CURR_RCDS: Exception: ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'UPDATE_TPFG1_CURR_RCDS');
    RAISE;
END;


PROCEDURE DO_CURRENCY_DANGLING_CHECK
IS BEGIN

  UPDATE PJI_FM_EXTR_PLNVER3_T
  SET rate_dangling_flag = 'Y'
  WHERE plan_version_id IN (
     SELECT
          fact.PLAN_VERSION_ID
     FROM pji_fp_aggr_pjp1_t fact
      , PJI_FM_AGGR_DLY_RATES_T rates
      , ( SELECT cal_period_id period_id, start_date, end_date FROM pji_time_cal_period_v
             UNION ALL
             SELECT cal_qtr_id, start_date, end_date FROM pji_time_cal_qtr_v
             UNION ALL
             SELECT cal_year_id, start_date, end_date FROM pji_time_cal_year_v
             UNION ALL
             SELECT ent_period_id, start_date, end_date FROM pji_time_ent_period_v
             UNION ALL
             SELECT ent_qtr_id, start_date, end_date FROM pji_time_ent_qtr
             UNION ALL
             SELECT ent_year_id, start_date, end_date FROM pji_time_ent_year
             UNION ALL
             SELECT week_id, start_date, end_date FROM pji_time_week
         ) dates
     WHERE 1=1
       AND fact.worker_id = g_worker_id
       AND dates.period_id = fact.time_id
           AND rates.time_id = DECODE ( g_start_str
                                      , g_start_str, TO_CHAR(dates.start_date, 'J')
                                  , g_end_str, TO_CHAR(dates.end_date, 'J') )
           AND ( rates.rate IS NULL or rates.rate2 IS NULL )
          );


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DO_CURRENCY_DANGLING_CHECK');
    RAISE;
END;


PROCEDURE GET_PRORATE_FORMAT
IS BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_PRORATE_FORMAT');
    RAISE;
END;


PROCEDURE GET_SPREAD_DATE_RANGE_AMOUNTS
IS BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_SPREAD_DATE_RANGE_AMOUNTS');
    RAISE;
END;


PROCEDURE SPREAD_NON_TIME_PHASE_AMOUNTS
IS BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'SPREAD_NON_TIME_PHASE_AMOUNTS');
    RAISE;
END;


PROCEDURE PRORATE_NON_TIME_PHASED_AMTS(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
) IS BEGIN

  -- What slices will be prorated to PA.
  -- Primary slice entries in GL calendar.
  -- How to identify? Programming construct OP.

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_NON_TIME_PHASED_AMTS');
    RAISE;
END;


PROCEDURE PRORATE_TO_OTHER_CALENDAR(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
) IS
BEGIN

  --
  -- Logic to identify the records that are 'original'/'converted' format
  --   etc is similar to that for PJI. This is to make it easy for dev working
  --   on one module (PJI/PRP) to understand the other with minimum effort.
  --
  -- Logic is as follows:
  -------------------------------------------------------------------------
  -- 1. All 'entered' amounts (from pri slice) will have a line type *tag* 'OF'
  --     if calendar type is PA/GL. If no calendar type is mentioned,
  --     then, it will be 'F1'. Tag == line type column in tmp table.
  -- 2. Non time phased amounts if prorated to ENT cal will be tagged 'OF'.
  --     This has not been decided yet.
  -- 3. Amounts from PA/GL cal entries that have been converted to global will
  --     have a tag 'OG'.
  -- 4. Non PA calendar entries of OF/OG when converted to PA calendar will have
  --     a tag 'CF/CG' respectively.
  -- 5. Non GL calendar entries of OF/OG when converted to GL calendar will have
  --     a tag 'CF/CG' respectively.
  -- 6. Non ENT calendar entries of OF/OG when converted to ENT calendar will have
  --     a tag 'CF/CG' respectively.
  -- 7. Non ENTW calendar entries of OF/OG when converted to ENTW calendar will have
  --     a tag 'CF/CG' respectively.
  --

  IF (p_calENDar_type = 'PA') THEN
    PRORATE('PA');
  ELSIF (p_calENDar_type = 'GL') THEN
    PRORATE('GL');
  ELSIF (p_calENDar_type = 'ENT') THEN
    PRORATE_TO_ENT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_OTHER_CALENDAR');
    RAISE;
END;


--
-- Prorate entries in RL fact and pjp1 table in
--  1. GL and Non time phased into PA.
--  2. PA into GL.
--  3. PA and GL into Ent.
--
PROCEDURE PRORATE_TO_ALL_CALENDARS IS
BEGIN

   print_time('PRORATE_TO_ALL_CALENDARS: Begin.. ');

   PRORATE_TO_OTHER_CALENDAR('PA');  -- Prorate entries in Non time phased and GL cal entries into PA cal.
   PRORATE_TO_OTHER_CALENDAR('GL');  -- Prorate entries in PA cal into GL cal.
   PRORATE_TO_OTHER_CALENDAR('ENT'); -- Prorate entries in PA and GL cals into ENT cal.

   print_time('PRORATE_TO_ALL_CALENDARS: End.. ');

EXCEPTION
  WHEN NO_DATA_FOUND THEN

        /* This issue will come only when PJI_PJP_FP_CURR_WRAP.get_ent_dates_info gives a no_data_found error.
           updating the plan versions as time dangling so that the plan will be marked as dangling. Not updating
           the existing records so that data for the primary calendar is not impacted because of issue in proration to
           other calendars */

         UPDATE PJI_FM_EXTR_PLNVER3_T
            SET time_dangling_flag='Y'
            WHERE wp_flag='N'
            AND baselined_flag = 'Y' ;
                         -- Not raising any exception as we want the processing to happen properly.
                                 -- The where condition is added to make sure that workplan versions are not marked as dangling.
  WHEN OTHERS THEN
    print_time('PRORATE_TO_ALL_CALENDARS: Exception.. ' || sqlerrm);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_ALL_CALENDARS');
    RAISE;
END;


PROCEDURE PRORATE_TO_ENT IS
    l_calendar_type  VARCHAR2(15) := g_ent_cal_str;
BEGIN

   PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
     x_currency_conversion_rule => g_currency_conversion_rule
   , x_prorating_format         => g_prorating_format
   , x_global1_currency_code    => g_global1_currency_code
   , x_global2_currency_code    => g_global2_currency_code
   , x_global1_currency_mau     => g_global1_currency_mau
   , x_global2_currency_mau     => g_global2_currency_mau ) ;


   PJI_PJP_FP_CURR_WRAP.get_ent_dates_info (
     x_global_start_date      => g_global_start_date
   , x_ent_start_period_id    => g_ent_start_period_id
   , x_ent_start_period_name  => g_ent_start_period_name
   , x_ent_start_date         => g_ent_start_date
   , x_ent_END_date           => g_ent_END_date
   , x_global_start_J         => g_global_start_J
   , x_ent_start_J            => g_ent_start_J
   , x_ent_END_J              => g_ent_END_J
  ) ;

  -- Refer to prorating logic in 'PRORATE_TO_OTHER_CALENDAR' proc.
  -- PRORATE('ENT');

  IF (g_prorating_format = 'D') THEN

    PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_ENT_PG_PJP1_D;
    -- PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_ENT_PG_FPRL_D;
    PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_ENT_N_PJP1_D;

  ELSIF (g_prorating_format IN ( g_end_str, g_start_str ) ) THEN

    /*Added parameter g_prorating_format for bug 4005006*/
    PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_ENT_PG_PJP1_SE(g_prorating_format);
    -- PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_ENT_PG_FPRL_SE;
    PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_ENT_N_PJP1_SE(g_prorating_format);

  ELSE
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_ENT');
    RAISE;
END;


/*
PROCEDURE PRORATE_TO_ENT_NONTIMEPH IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

    l_calendar_type  VARCHAR2(15) := 'ENT';
BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
*/


PROCEDURE PRORATE(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
) IS
    l_calendar_type        VARCHAR2(15);

BEGIN

  IF (p_calENDar_type NOT IN ('PA', 'GL')) THEN RETURN; END IF;

  IF (p_calENDar_type = 'PA') THEN l_calENDar_type := g_pa_cal_str;
  ELSIF (p_calENDar_type = 'GL') THEN l_calENDar_type := g_gl_cal_str;
  ELSE RETURN;
  END IF;


   PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
     x_currency_conversion_rule => g_currency_conversion_rule
   , x_prorating_format         => g_prorating_format
   , x_global1_currency_code    => g_global1_currency_code
   , x_global2_currency_code    => g_global2_currency_code
   , x_global1_currency_mau     => g_global1_currency_mau
   , x_global2_currency_mau     => g_global2_currency_mau ) ;


   PJI_PJP_FP_CURR_WRAP.get_ent_dates_info (
     x_global_start_date      => g_global_start_date
   , x_ent_start_period_id    => g_ent_start_period_id
   , x_ent_start_period_name  => g_ent_start_period_name
   , x_ent_start_date         => g_ent_start_date
   , x_ent_END_date           => g_ent_END_date
   , x_global_start_J         => g_global_start_J
   , x_ent_start_J            => g_ent_start_J
   , x_ent_END_J              => g_ent_END_J
  ) ;

  print_time ( ' Prorating format is .. ' || g_prorating_format ) ;

  IF (g_prorating_format = 'D') THEN

    PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_PAGL_PGE_PJP1_D( p_calendar_type => l_calendar_type );
    PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_PAGL_N_PJP1_D( p_calendar_type => l_calendar_type );

  ELSIF (g_prorating_format IN ( g_end_str, g_start_str ) ) THEN

    -- Changed for bug 4005006
    PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_PAGL_PGE_PJP1_SE( p_calendar_type => l_calendar_type ,
                                                        p_prorating_format => g_prorating_format);

    -- Commenting out the following call for 4252205.
    -- PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_PAGL_PGE_FPRL_SE( p_calendar_type => l_calendar_type );

    -- Added for bug 4005006
    PJI_FM_PLAN_CAL_RLPS_T.PRORATE_TO_PAGL_N_PJP1_SE( p_calendar_type => l_calendar_type ,
                                                      p_prorating_format => g_prorating_format);

  ELSE
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE');
    RAISE;
END;


PROCEDURE MERGE_INTO_FP_FACT IS
BEGIN

  print_time ( ' MERGE_INTO_FP_FACT 1 ' ) ;
  CLEANUP_FP_RMAP_FPR;
  print_time ( ' MERGE_INTO_FP_FACT 2 ' ) ;
  GET_FP_ROW_IDS;
  print_time ( ' MERGE_INTO_FP_FACT 3 ' ) ;
  UPDATE_FP_ROWS;
  print_time ( ' MERGE_INTO_FP_FACT 4 ' ) ;
  INSERT_FP_ROWS;
  print_time ( ' MERGE_INTO_FP_FACT 5 ' ) ;

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' MERGE_INTO_FP_FACT 6 ' ) ;
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MERGE_INTO_FP_FACT');
    RAISE;
END;


PROCEDURE CLEANUP_FP_RMAP_FPR IS
BEGIN

  print_time ( 'CLEANUP_FP_RMAP_FPR begin..');

  DELETE FROM PJI_FP_RMAP_FPR_T
  WHERE worker_id = g_worker_id;

  print_time ( 'CLEANUP_FP_RMAP_FPR end.' || g_worker_id );

EXCEPTION
  WHEN OTHERS THEN
    print_time ( 'ccc' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CLEANUP_FP_RMAP_FPR');
    RAISE;
END;


PROCEDURE GET_FP_ROW_IDS IS
BEGIN

  INSERT INTO PJI_FP_RMAP_FPR_T
  (
     worker_id
   , pjp1_rowid
   , fpr_rowid
  )
  SELECT /*+ full(tmp) index(rl, PJI_FP_XBS_ACCUM_F_N1) use_nl(rl) */
    g_worker_id WORKER_ID
  , tmp.ROWID pjp1_rowid
  , rl.ROWID fpr_ROWID
  FROM
    pji_fp_aggr_pjp1_t          tmp
  , pji_fp_xbs_accum_f          rl
  WHERE 1 = 1
   AND tmp.WORKER_ID = g_worker_id
   AND tmp.PROJECT_ID = rl.PROJECT_ID (+)
   AND tmp.PLAN_VERSION_ID = rl.PLAN_VERSION_ID (+)
   AND tmp.PLAN_TYPE_ID = rl.PLAN_TYPE_ID (+)
   AND tmp.PROJECT_ORG_ID = rl.PROJECT_ORG_ID (+)
   AND tmp.PROJECT_ORGANIZATION_ID = rl.PROJECT_ORGANIZATION_ID (+)
   AND tmp.PROJECT_ELEMENT_ID = rl.PROJECT_ELEMENT_ID (+)
   AND tmp.TIME_ID = rl.TIME_ID (+)
   AND tmp.PERIOD_TYPE_ID = rl.PERIOD_TYPE_ID (+)
   AND tmp.CALENDAR_TYPE = rl.CALENDAR_TYPE (+)
   AND tmp.RBS_AGGR_LEVEL = rl.RBS_AGGR_LEVEL (+)
   AND tmp.WBS_ROLLUP_FLAG = rl.WBS_ROLLUP_FLAG (+)
   AND tmp.PRG_ROLLUP_FLAG = rl.PRG_ROLLUP_FLAG (+)
   AND tmp.CURR_RECORD_TYPE_ID = rl.CURR_RECORD_TYPE_ID (+)
   AND tmp.CURRENCY_CODE = rl.CURRENCY_CODE (+)
   AND tmp.RBS_ELEMENT_ID = rl.RBS_ELEMENT_ID (+)
   AND tmp.RBS_VERSION_ID = rl.RBS_VERSION_ID (+)
   AND tmp.PLAN_TYPE_CODE = rl.PLAN_TYPE_CODE (+)      /* 4471527 */
   AND tmp.RATE_DANGLING_FLAG IS NULL
   AND tmp.TIME_DANGLING_FLAG IS NULL;

  print_time ( ' MERGE_INTO_FP_FACT 1.1 ' || SQL%ROWCOUNT ) ;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_FP_ROW_IDS');
    RAISE;
END;


PROCEDURE GET_ACTUALS (
   p_new_pub_version_id  IN NUMBER
 , p_prev_pub_version_id IN  NUMBER := NULL  ) IS

BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_ACTUALS');
    RAISE;
END;


PROCEDURE REVERSE_ETC (
   p_new_pub_version_id  IN NUMBER
 , p_prev_pub_version_id IN  NUMBER := NULL  ) IS

  l_project_id             NUMBER;
  l_struct_sharing_code    pa_projects_all.structure_sharing_code%TYPE;
  l_prev_pub_version_id    NUMBER;
  l_curr_wking_version_id  NUMBER;
  l_actual_plan_version_id NUMBER;
  l_copied_from_version_id NUMBER;
  l_new_plan_type_id       NUMBER;
  /*
  l_last_update_date     DATE   := SYSDATE;
  l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
  l_creation_date        DATE   := SYSDATE;
  l_created_by           NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
  */
  l_max_plnver_id        NUMBER := NULL;

BEGIN

  print_time ( ' REVERSE_ETC BEGIN' ) ;
  print_time ( ' REVERSE_ETC p_new_pub_version_id = ' ||p_new_pub_version_id  || ' p_prev_pub_version_id ' || p_prev_pub_version_id ) ;

  INSERT_NTP_CAL_RECORD ( x_max_plnver_id => l_max_plnver_id );

  IF (l_max_plnver_id IS NULL) THEN
    RETURN;
  END IF;

  SELECT project_id, fin_plan_type_id
  INTO   l_project_id, l_new_plan_type_id
  FROM   pa_budget_versions
  WHERE  budget_version_id = p_new_pub_version_id ;

  SELECT structure_sharing_code
  INTO l_struct_sharing_code
  FROM pa_projects_all
  WHERE project_id = l_project_id;

  l_prev_pub_version_id := p_prev_pub_version_id;

 -- Fix for bug : 4213245
/*
  delete from pji_fm_extr_plan_lines
  where
    PLAN_VERSION_ID = p_new_pub_version_id and
    ETC_QUANTITY    is null                and
    ETC_TXN_BURDENED_COST is null          and
    ETC_PRJ_BURDENED_COST is null          and
    ETC_PFC_BURDENED_COST is null          and
    ETC_TXN_RAW_COST is null               and
    ETC_PRJ_RAW_COST is null               and
    ETC_PFC_RAW_COST is null               and
    RBS_VERSION_ID   is null;
*/

  print_time ( ' REVERSE_ETC l_prev_pub_version_id ' || l_prev_pub_version_id || ' l_actual_plan_version_id ' || l_actual_plan_version_id || ' l_project_id ' || l_project_id ) ;


 INSERT INTO PJI_FP_AGGR_PJP1_T
    (
         WORKER_ID
       , PRG_LEVEL
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , PLAN_TYPE_CODE     /* 4471527 */
        )
     SELECT
             g_worker_id WORKER_ID
           , g_default_prg_level PRG_LEVEL
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID project_element_id
       , DECODE(vers.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)  time_id
       , DECODE(vers.time_phased_type_code
              , 'P', 32
              , 'G', 32
              , 'N', 2048)  period_type_id -- period type id...
       , DECODE(vers.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
                           , 'X')     CALENDAR_TYPE
       , 'L' RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE  CURR_RECORD_TYPE_ID
           , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID rbs_version_id
       , plr.BUDGET_VERSION_ID PLAN_VERSION_ID
           , plr.plan_type_id
       , SUM(plr.RAW_COST) RAW_COST
       , SUM(plr.BRDN_COST) BRDN_COST
       , SUM(plr.REVENUE) REVENUE
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, TO_NUMBER(NULL) ) ) BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, TO_NUMBER(NULL) ) ) BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || 'PEOPLE', plr.raw_cost, TO_NUMBER(NULL) ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || 'PEOPLE' , plr.BRDN_COST, TO_NUMBER(NULL) ) )  BILL_LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || 'PEOPLE', plr.quantity, TO_NUMBER(NULL) ) )  BILL_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || 'PEOPLE',
                                                                         decode(plr.billable_flag,'Y', plr.quantity, TO_NUMBER(NULL)),
					    TO_NUMBER(NULL) ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.raw_cost, TO_NUMBER(NULL) ) ) EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.BRDN_COST, TO_NUMBER(NULL) ) ) EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, TO_NUMBER(NULL) ) )   CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, TO_NUMBER(NULL) ) )  CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.raw_cost, TO_NUMBER(NULL) ) ) LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.BRDN_COST, TO_NUMBER(NULL) ) ) LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, 'PEOPLE',
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.quantity,0),
                                                                   plr.quantity),
                                                    TO_NUMBER(NULL) ) )  labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE',
                                            DECODE(plr.billable_flag,'Y',
                                                   DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.quantity,0),
                                                                   plr.quantity)
					    , TO_NUMBER(NULL) ),
                                                    TO_NUMBER(NULL) ) )  labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.revenue, TO_NUMBER(NULL) ) ) LABOR_REVENUE
       /* , SUM ( -- s
               DECODE ( plr.resource_class -- d1
                  , 'EQUIPMENT'
                                  , DECODE ( vers.wp_flag -- d2
                           , 'N'
                           , DECODE ( plr.billable_flag -- d3
                                                            , 'Y'
                                                                        , plr.quantity
                                                                        , TO_NUMBER(NULL)
                                                                        )  -- d3
                           , plr.quantity
                                                   )  -- d2
                  , TO_NUMBER(NULL)
                                  ) -- d1
                                )  EQUIPMENT_HRS -- s */ -- bug 6039785
       , SUM ( -- s
               DECODE ( plr.resource_class -- d1
                  , 'EQUIPMENT' , DECODE(plr.billable_flag,'Y'
                                  , DECODE ( vers.wp_flag -- d2
                           , 'N'
                           , DECODE ( plr.billable_flag -- d3
                                                            , 'Y'
                                                                        , plr.quantity
                                                                        , TO_NUMBER(NULL)
                                                                        )  -- d3
                           , plr.quantity
                                                   )  -- d2
	             , TO_NUMBER(NULL) ),
                             TO_NUMBER(NULL)
                                  ) -- d1
                                )  EQUIPMENT_HRS -- s -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT', plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT',
                                                                 DECODE(plr.billable_flag,'Y',plr.quantity,0 ) , 0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , TO_NUMBER(NULL) SUP_INV_COMMITTED_COST
       , TO_NUMBER(NULL) PO_COMMITTED_COST
       , TO_NUMBER(NULL) PR_COMMITTED_COST
       , TO_NUMBER(NULL) OTH_COMMITTED_COST
       /* , SUM ( DECODE ( plr.resource_class, 'PEOPLE',
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.actual_quantity,0),
                                                                   plr.actual_quantity),
                                                    TO_NUMBER(NULL) ) )  ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE',
                                            DECODE (plr.billable_flag ,'Y',
                                                    DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.actual_quantity,0),
                                                                   plr.actual_quantity),
					    TO_NUMBER(NULL) ),
                                                    TO_NUMBER(NULL) ) )  ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT',
                                           DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.actual_quantity,0),
                                                                   plr.actual_quantity),
                                                    TO_NUMBER(NULL) ) ) ACT_EQUIP_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT',
                                            DECODE (plr.billable_flag ,'Y',
                                                    DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.actual_quantity,0),
                                                                   plr.actual_quantity),
					    TO_NUMBER(NULL) ),
                                                    TO_NUMBER(NULL) ) ) ACT_EQUIP_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_BRDN_COST, TO_NUMBER(NULL) ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.actual_BRDN_COST, TO_NUMBER(NULL) ) ) ACT_EQUIP_BRDN_COST
       , SUM ( plr.actual_brdn_cost ) ACT_BRDN_COST
       , SUM ( plr.actual_raw_cost ) ACT_RAW_COST
       , SUM ( plr.actual_revenue ) ACT_REVENUE
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_RAW_COST, TO_NUMBER(NULL) ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.actual_RAW_COST, TO_NUMBER(NULL) ) ) ACT_EQUIP_RAW_COST
       /* , SUM ( DECODE ( plr.resource_class, 'PEOPLE',
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.ETC_quantity,TO_NUMBER(NULL)),
                                                                   plr.ETC_quantity),
                                             'EQUIPMENT', TO_NUMBER(NULL) ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE',
                                            DECODE (plr.billable_flag ,'Y',
                                                    DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.ETC_quantity,TO_NUMBER(NULL)),
                                                                   plr.ETC_quantity), TO_NUMBER(NULL) ),
                                             'EQUIPMENT', TO_NUMBER(NULL) ) ) ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT',
                                            DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.ETC_quantity,TO_NUMBER(NULL)),
                                                                   plr.ETC_quantity),
                                            'PEOPLE', TO_NUMBER(NULL) ) ) ETC_EQUIP_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT',
                                            DECODE (plr.billable_flag ,'Y',
                                                    DECODE ( vers.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag,  'Y',plr.ETC_quantity,TO_NUMBER(NULL)),
                                                                   plr.ETC_quantity), TO_NUMBER(NULL) ),
                                            'PEOPLE', TO_NUMBER(NULL) ) ) ETC_EQUIP_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.etc_BRDN_COST, TO_NUMBER(NULL) ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.etc_BRDN_COST, TO_NUMBER(NULL) ) ) ETC_EQUIP_BRDN_COST
       , SUM ( plr.etc_brdn_cost ) ETC_BRDN_COST
       , SUM ( plr.etc_raw_cost ) ETC_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.etc_raw_COST, TO_NUMBER(NULL) ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.etc_raw_COST, TO_NUMBER(NULL) ) ) ETC_EQUIP_raw_COST
       , TO_NUMBER(NULL) CUSTOM1
       , TO_NUMBER(NULL) CUSTOM2
       , TO_NUMBER(NULL) CUSTOM3
       , TO_NUMBER(NULL) CUSTOM4
       , TO_NUMBER(NULL) CUSTOM5
       , TO_NUMBER(NULL) CUSTOM6
       , TO_NUMBER(NULL) CUSTOM7
       , TO_NUMBER(NULL) CUSTOM8
       , TO_NUMBER(NULL) CUSTOM9
       , TO_NUMBER(NULL) CUSTOM10
       , TO_NUMBER(NULL) CUSTOM11
       , TO_NUMBER(NULL) CUSTOM12
       , TO_NUMBER(NULL) CUSTOM13
       , TO_NUMBER(NULL) CUSTOM14
           , TO_NUMBER(NULL) CUSTOM15
       , plr.plan_type_code  plan_type_code  /* 4471527 */
       FROM
       (          ----- First inline view plr .............
            SELECT
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.CURRENCY_CODE
            , MAX(collapse_bl.raw_cost) raw_cost
            , MAX(collapse_bl.BRDN_COST) BRDN_COST
            , MAX(collapse_bl.revenue) revenue
            , MAX(collapse_bl.act_raw_cost) actual_raw_cost
            , MAX(collapse_bl.act_BRDN_COST) actual_BRDN_COST
            , MAX(collapse_bl.act_revenue) actual_revenue
            , MAX(collapse_bl.etc_RAW_COST) etc_raw_COST
            , MAX(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , MAX(collapse_bl.quantity) quantity
            , MAX(collapse_bl.act_quantity) actual_quantity
            , MAX(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.period_name period_name
            , collapse_bl.row_id
            , collapse_bl.plan_type_code plan_type_code   /* 4471527 */
            FROM
              (                  ----- Second inline view 'collapse_bl' begin .............
                SELECT
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
                                , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , DECODE( invert.INVERT_ID
                        , 4, spread_bl.pfc_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.pfc_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.pfc_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.pfc_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.act_pfc_raw_cost
                         , 8, spread_bl.act_PRJ_raw_cost
                         , 16, spread_bl.act_TXN_raw_cost) act_raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.act_pfc_BRDN_COST
                         , 8, spread_bl.act_PRJ_BRDN_COST
                         , 16, spread_bl.act_TXN_BRDN_COST ) act_BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.act_pfc_revenue
                         , 8, spread_bl.act_PRJ_revenue
                         , 16, spread_bl.act_TXN_revenue ) act_revenue
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.etc_pfc_brdn_cost
                         , 8, spread_bl.etc_PRJ_brdn_cost
                         , 16, spread_bl.etc_TXN_brdn_cost ) etc_brdn_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.etc_pfc_raw_cost
                         , 8, spread_bl.etc_PRJ_raw_cost
                         , 16, spread_bl.etc_TXN_raw_cost) etc_raw_cost
                , spread_bl.quantity quantity
                                , spread_bl.act_quantity act_quantity
                                , spread_bl.etc_quantity etc_quantity
                , spread_bl.period_name period_name
                , spread_bl.plan_type_code plan_type_code   /* 4471527 */
                FROM
                  (
                    SELECT
                          bl.project_id
                        , bl.ROWID row_id
                        , bl.plan_version_id budget_version_id
                        , DECODE(bl.project_element_id, 0, pevs.proj_element_id, bl.project_element_id)  wbs_element_id
                        , NVL( bl.rbs_element_id, -1)   rbs_element_id
                        , bl.struct_ver_id             wbs_struct_version_id
                    , DECODE( bl.rbs_element_id
                            , NULL
                            , -1
                            , NVL(ver.rbs_struct_version_id, -1)
                            )                       rbs_struct_version_id
                        , bl.plan_type_id              plan_type_id -- ver.plan_type_id
                  , bl.rate_based_flag           billable_flag -- ra.rate_based_flag             billable_flag
                  , bl.resource_class_code       resource_class -- ra.resource_class_code          resource_class
                        , bl.txn_currency_code         txn_currency_code
                        , bl.txn_raw_cost                            txn_raw_cost
                        , bl.txn_burdened_cost                            txn_BRDN_COST
                        , bl.txn_revenue                            txn_revenue
                        , TO_NUMBER(NULL)                             act_txn_raw_cost
                        , TO_NUMBER(NULL)                             act_txn_brdn_cost
                        , TO_NUMBER(NULL)                             act_txn_revenue
                        , NVL(bl.txn_raw_cost, 0)+NVL(bl.etc_txn_raw_cost, 0)      etc_txn_raw_cost
                        , NVL(bl.txn_burdened_cost, 0)+NVL(bl.etc_txn_burdened_cost, 0)      etc_txn_brdn_cost
                        , bl.prj_currency_code          prj_currency_code
                        , bl.prj_raw_cost                             prj_raw_cost
                        , bl.prj_burdened_cost                             prj_BRDN_COST
                        , bl.prj_revenue                             prj_revenue
                        , TO_NUMBER(NULL)                             act_prj_raw_cost
                        , TO_NUMBER(NULL)                             act_prj_brdn_cost
                        , TO_NUMBER(NULL)                             act_prj_revenue
                        , NVL(bl.prj_raw_cost, 0)+NVL(bl.etc_prj_raw_cost, 0)      etc_prj_raw_cost
                        , NVL(bl.prj_burdened_cost, 0)+NVL(bl.etc_prj_burdened_cost, 0)      etc_prj_brdn_cost
                        , bl.pfc_currency_code          pfc_currency_code
                  , bl.pfc_raw_cost                             pfc_raw_cost
                        , bl.pfc_burdened_cost                             pfc_BRDN_COST
                        , bl.pfc_revenue                             pfc_revenue
                        , TO_NUMBER(NULL)                             act_pfc_raw_cost
                        , TO_NUMBER(NULL)                             act_pfc_brdn_cost
                        , TO_NUMBER(NULL)                             act_pfc_revenue
                        , NVL(bl.pfc_raw_cost, 0)+NVL(bl.etc_pfc_raw_cost, 0)      etc_pfc_raw_cost
                        , NVL(bl.pfc_burdened_cost, 0)+NVL(bl.etc_pfc_burdened_cost, 0)      etc_pfc_brdn_cost
                        , bl.quantity                              quantity
                        , TO_NUMBER(NULL)                                 act_quantity
                        , NVL(bl.quantity, 0)+NVL(bl.etc_quantity, 0)                etc_quantity
                        , NVL(bl.period_name, 'XXX')       period_name
                        , bl.project_org_id                       project_org_id
                        , ppa.carrying_out_organization_id  project_organization_id
                        , ver.plan_type_code  plan_type_code /* 4471527 */
                    FROM
                       PJI_FM_EXTR_PLAN_LINES        bl
                     , PJI_FM_EXTR_PLNVER3_T         ver
                           , PA_PROJECTS_ALL               ppa
                           , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                           , pji_fp_rmap_fpr_update_t      rwid
                    WHERE 1=1
                                         AND bl.project_id = ver.project_id
                                         AND bl.plan_version_id = ver.plan_version_id
                                         AND bl.plan_type_id = ver.plan_type_id
                                         AND ppa.project_id = ver.project_id
                               AND bl.project_id = ppa.project_id -- Added for bug 3828698
                               AND ppa.project_id = pevs.project_id -- Added for bug 3838698
                                         AND bl.TXN_CURRENCY_CODE IS NOT NULL
                                         AND bl.prj_currency_code IS NOT NULL
                                         AND bl.pfc_currency_code IS NOT NULL
                                     AND pevs.element_version_id = ver.wbs_struct_version_id
                                         AND pevs.project_id = ver.project_id -- Fix for bug : 4149422 in REVERSE_ETC
                               AND bl.ROWID = rwid.extr_lines_rowid
                                        UNION ALL
                    SELECT  /*+ LEADING(VER) USE_NL(VER,PPA,PEVS,RA,BL)*/
                          ra.project_id
                        , bl.ROWID row_id
                        , ra.budget_version_id
                        , DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                        , NVL(ra.rbs_element_id, -1)              rbs_element_id
                        , ver.wbs_struct_version_id      wbs_struct_version_id
                        , NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id
                        , ver.plan_type_id               plan_type_id
                        , ra.rate_based_flag             billable_flag
                        , ra.resource_class_code         resource_class
                        , bl.txn_currency_code           txn_currency_code
                        , TO_NUMBER(NULL)                txn_raw_cost
                        , TO_NUMBER(NULL)           txn_brdn_COST
                        , TO_NUMBER(NULL)                 txn_revenue
                        , bl.txn_init_raw_cost                txn_actual_raw_cost  -- new
                        , bl.txn_init_burdened_cost             txn_actual_brdn_cost  -- new
                        , bl.txn_init_revenue                   txn_actual_revenue  -- new
                        , TO_NUMBER(NULL)                txn_etc_raw_cost     -- new
                        , TO_NUMBER(NULL)                txn_etc_brdn_cost     -- new
                        , bl.project_currency_code          prj_currency_code
                        , TO_NUMBER(NULL)               prj_raw_cost
                        , TO_NUMBER(NULL)          prj_BRDN_COST
                        , TO_NUMBER(NULL)                prj_revenue
                        , bl.project_init_raw_cost           prj_actual_raw_cost  -- new
                        , bl.project_init_burdened_cost     prj_actual_brdn_cost  -- new
                        , bl.project_init_revenue           prj_actual_revenue  -- new
                        , TO_NUMBER(NULL)                prj_etc_raw_cost     -- new
                        , TO_NUMBER(NULL)                prj_etc_brdn_cost     -- new
                        , bl.projfunc_currency_code         func_currency_code
                  , TO_NUMBER(NULL)                        func_raw_cost
                        , TO_NUMBER(NULL)                        func_BRDN_COST
                        , TO_NUMBER(NULL)                      func_revenue
                        , bl.init_raw_cost                  func_actual_raw_cost  -- new
                        , bl.init_burdened_cost             func_actual_brdn_cost  -- new
                        , bl.init_revenue                   func_actual_revenue  -- new
                        , TO_NUMBER(NULL)                 func_etc_raw_cost     -- new
                        , TO_NUMBER(NULL)                 func_etc_brdn_cost     -- new
                  , TO_NUMBER(NULL)                   quantity
                        , bl.init_quantity               actual_quantity  -- new
                        , TO_NUMBER(NULL)                etc_quantity  -- new
                        , NVL(bl.period_name, 'XXX') period_name
                        , ppa.org_id project_org_id
                        , ppa.carrying_out_organization_id project_organization_id
                        , ver.plan_type_code plan_type_code  /* 4471527 */
                 FROM
                       PA_BUDGET_LINES               bl
                     , PA_RESOURCE_ASSIGNMENTS       ra
                     , PJI_FM_EXTR_PLNVER3_T           ver
                         , PA_PROJECTS_ALL               ppa
                           , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE
                         ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
                     AND pevs.project_id = ver.project_id -- Fix for bug : 4149422 in REVERSE_ETC
                           AND pevs.element_version_id = ver.wbs_struct_version_id
                           AND ver.secondary_rbs_flag = 'N'
                                  ) spread_bl
                                   ---- end of third inline view 'spread_bl'...........
                  ,
                    (
                      SELECT 4   INVERT_ID FROM dual UNION ALL
                      SELECT 8   INVERT_ID FROM dual UNION ALL
                      SELECT 16  INVERT_ID FROM dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
                                )  collapse_bl
                                ----  End of second inline view 'collapse_bl' ..........
                        GROUP BY
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
                        , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.period_name
            , collapse_bl.row_id
            , collapse_bl.plan_type_code
       ) plr
                                ----  End of first inline view plr ..........
       , PJI_ORG_EXTR_INFO            orginfo
       , PJI_FM_EXTR_PLNVER3_T     vers
       , pji_time_cal_period_v       pji_time
         WHERE  1=1
           AND    plr.project_org_id       = orginfo.org_id
           AND    plr.project_id             = vers.project_id
           AND    plr.budget_version_id      = vers.plan_version_id
           AND    plr.plan_type_code = vers.plan_type_code   /* 4471527 */
           AND    DECODE(vers.time_phased_type_code
                   , 'P', orginfo.pa_calendar_id
                   , 'G', orginfo.gl_calendar_id
                   , - l_max_plnver_id )
                                     = pji_time.calendar_id
           AND    plr.period_name = pji_time.name
           AND vers.time_phased_type_code IN ('P', 'G', 'N')
       GROUP BY
         plr.PROJECT_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(vers.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)
       , DECODE(vers.time_phased_type_code
              , 'P', 32
              , 'G', 32
              , 'N', 2048)   -- period type id...
       , DECODE(vers.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
                           , 'X')     --   CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
           , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
           , plr.plan_type_id
       , plr.BUDGET_VERSION_ID
       , plr.project_ORGANIZATION_ID
       , plr.project_ORG_ID
       , plr.plan_type_code ;       /* 4471527 */


  print_time ( ' REVERSE_ETC END, # Processed rows is ' || SQL%ROWCOUNT ) ;

  DELETE_NTP_CAL_RECORD ( p_max_plnver_id => l_max_plnver_id );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'REVERSE_ETC');
    RAISE;
END;


PROCEDURE UPDATE_FP_ROWS IS

  l_last_update_date  DATE   := SYSDATE;
  l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

    UPDATE /*+ ordered use_nl(rl) rowid(rl) */
      pji_fp_xbs_accum_f rl
    SET (
      rl.RAW_COST
    , rl.BRDN_COST
    , rl.REVENUE
    , rl.BILL_RAW_COST
    , rl.BILL_BRDN_COST
    , rl.BILL_LABOR_RAW_COST
    , rl.BILL_LABOR_BRDN_COST
    , rl.BILL_LABOR_HRS
    , rl.EQUIPMENT_RAW_COST
    , rl.EQUIPMENT_BRDN_COST
    , rl.CAPITALIZABLE_RAW_COST
    , rl.CAPITALIZABLE_BRDN_COST
    , rl.LABOR_RAW_COST
    , rl.LABOR_BRDN_COST
    , rl.LABOR_HRS
    , rl.LABOR_REVENUE
    , rl.EQUIPMENT_HOURS
    , rl.BILLABLE_EQUIPMENT_HOURS
    , rl.SUP_INV_COMMITTED_COST
    , rl.PO_COMMITTED_COST
    , rl.PR_COMMITTED_COST
    , rl.OTH_COMMITTED_COST
    , rl.ACT_LABOR_HRS
   , rl.ACT_EQUIP_HRS
   , rl.ACT_LABOR_BRDN_COST
   , rl.ACT_EQUIP_BRDN_COST
   , rl.ACT_BRDN_COST
   , rl.ACT_RAW_COST
   , rl.ACT_REVENUE
   , rl.ACT_LABOR_RAW_COST
    , rl.ACT_EQUIP_RAW_COST
   , rl.ETC_LABOR_HRS
   , rl.ETC_EQUIP_HRS
   , rl.ETC_LABOR_BRDN_COST
   , rl.ETC_EQUIP_BRDN_COST
   , rl.ETC_BRDN_COST
    , rl.ETC_RAW_COST
    , rl.ETC_LABOR_RAW_COST
    , rl.ETC_EQUIP_RAW_COST
    , rl.CUSTOM1
    , rl.CUSTOM2
    , rl.CUSTOM3
    , rl.CUSTOM4
    , rl.CUSTOM5
    , rl.CUSTOM6
    , rl.CUSTOM7
    , rl.CUSTOM8
    , rl.CUSTOM9
    , rl.CUSTOM10
    , rl.CUSTOM11
    , rl.CUSTOM12
    , rl.CUSTOM13
    , rl.CUSTOM14
    , rl.CUSTOM15
    , rl.last_update_date
    , rl.last_updated_by
    , rl.last_update_login
        ) =
    (
      SELECT  /*+  ORDERED ROWID(TMP) index(rwid,PJI_FP_RMAP_FPR_T_N1) */
         NVL(rl.RAW_COST, 0) + NVL(tmp.RAW_COST, 0)
       , NVL(rl.BRDN_COST, 0) + NVL(tmp.BRDN_COST, 0)
       , NVL(rl.REVENUE, 0) + NVL(tmp.REVENUE, 0)
       , NVL(rl.BILL_RAW_COST, 0) + NVL(tmp.BILL_RAW_COST, 0)
       , NVL(rl.BILL_BRDN_COST, 0) + NVL(tmp.BILL_BRDN_COST, 0)
       , NVL(rl.BILL_LABOR_RAW_COST, 0) + NVL(tmp.BILL_LABOR_RAW_COST, 0)
       , NVL(rl.BILL_LABOR_BRDN_COST, 0) + NVL(tmp.BILL_LABOR_BRDN_COST, 0)
       , NVL(rl.BILL_LABOR_HRS, 0) + NVL(tmp.BILL_LABOR_HRS, 0)
       , NVL(rl.EQUIPMENT_RAW_COST, 0) + NVL(tmp.EQUIPMENT_RAW_COST, 0)
       , NVL(rl.EQUIPMENT_BRDN_COST, 0) + NVL(tmp.EQUIPMENT_BRDN_COST, 0)
       , NVL(rl.CAPITALIZABLE_RAW_COST, 0) + NVL(tmp.CAPITALIZABLE_RAW_COST  , 0)
       , NVL(rl.CAPITALIZABLE_BRDN_COST, 0) + NVL(tmp.CAPITALIZABLE_BRDN_COST    , 0)
       , NVL(rl.LABOR_RAW_COST, 0) + NVL(tmp.LABOR_RAW_COST, 0)
       , NVL(rl.LABOR_BRDN_COST, 0) + NVL(tmp.LABOR_BRDN_COST, 0)
       , NVL(rl.LABOR_HRS, 0) + NVL(tmp.LABOR_HRS, 0)
       , NVL(rl.LABOR_REVENUE, 0) + NVL(tmp.LABOR_REVENUE, 0)
       , NVL(rl.EQUIPMENT_HOURS, 0) + NVL(tmp.EQUIPMENT_HOURS, 0)
       , NVL(rl.BILLABLE_EQUIPMENT_HOURS, 0) + NVL(tmp.BILLABLE_EQUIPMENT_HOURS, 0)
       , NVL(rl.SUP_INV_COMMITTED_COST, 0) + NVL(tmp.SUP_INV_COMMITTED_COST, 0)
       , NVL(rl.PO_COMMITTED_COST, 0) + NVL(tmp.PO_COMMITTED_COST, 0)
       , NVL(rl.PR_COMMITTED_COST, 0) + NVL(tmp.PR_COMMITTED_COST, 0)
       , NVL(rl.OTH_COMMITTED_COST, 0) + NVL(tmp.OTH_COMMITTED_COST, 0)
       , NVL(rl.ACT_LABOR_HRS, 0) + NVL(tmp.ACT_LABOR_HRS, 0)
           , NVL(rl.ACT_EQUIP_HRS, 0) + NVL(tmp.ACT_EQUIP_HRS, 0)
           , NVL(rl.ACT_LABOR_BRDN_COST, 0) + NVL(tmp.ACT_LABOR_BRDN_COST, 0)
           , NVL(rl.ACT_EQUIP_BRDN_COST, 0) + NVL(tmp.ACT_EQUIP_BRDN_COST, 0)
           , NVL(rl.ACT_BRDN_COST, 0) + NVL(tmp.ACT_BRDN_COST, 0)
           , NVL(rl.ACT_RAW_COST, 0) + NVL(tmp.ACT_RAW_COST, 0)
           , NVL(rl.ACT_REVENUE, 0) + NVL(tmp.ACT_REVENUE, 0)
         , NVL(rl.ACT_LABOR_RAW_COST, 0) + NVL(tmp.ACT_LABOR_RAW_COST, 0)
         , NVL(rl.ACT_EQUIP_RAW_COST, 0) + NVL(tmp.ACT_EQUIP_RAW_COST, 0)
           , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_HRS)
                                 , NULL
                             , NVL(rl.etc_labor_hrs, 0) + NVL(tmp.labor_hrs, 0)
                                         , NVL(rl.ETC_LABOR_HRS, 0) + tmp.ETC_LABOR_HRS
                                  )
                            , NVL(rl.ETC_LABOR_HRS, 0) + NVL(tmp.ETC_LABOR_HRS, 0)
                      ) ETC_LABOR_HRS
         , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_EQUIP_HRS)
                                     , NULL
                             , NVL(rl.ETC_EQUIP_HRS, 0) + NVL(tmp.EQUIPMENT_hours, 0)
                                             , NVL(rl.ETC_EQUIP_HRS, 0) + tmp.ETC_EQUIP_HRS
                                            )
                              , NVL(rl.ETC_EQUIP_HRS, 0) + NVL(tmp.ETC_EQUIP_HRS, 0)
                            ) ETC_EQUIP_HRS
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_BRDN_COST)
                             , NULL
                             , NVL(rl.ETC_LABOR_BRDN_COST, 0) + NVL(tmp.labor_BRDN_COST, 0)
                             , NVL(rl.ETC_LABOR_BRDN_COST, 0) + tmp.ETC_LABOR_BRDN_COST
                                                 )
                                , NVL(rl.ETC_LABOR_BRDN_COST, 0) + NVL(tmp.ETC_LABOR_BRDN_COST, 0)
                                  ) ETC_LABOR_BRDN_COST
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_EQUIP_BRDN_COST)
                                     , NULL
                      , NVL(rl.ETC_equip_BRDN_COST, 0) + NVL(tmp.EQUIPment_BRDN_COST, 0)
                              , NVL(rl.ETC_equip_BRDN_COST, 0) + tmp.ETC_equip_BRDN_COST
                                      )
                            , NVL(rl.ETC_EQUIP_BRDN_COST, 0) + NVL(tmp.ETC_EQUIP_BRDN_COST, 0)
                                  ) ETC_EQUIP_BRDN_COST
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_BRDN_COST)
                                     , NULL
                             , NVL(rl.ETC_BRDN_COST, 0) + NVL(tmp.BRDN_COST, 0)
                             , NVL(rl.ETC_BRDN_COST, 0) + tmp.ETC_BRDN_COST

                                               )
                                          , NVL(rl.ETC_BRDN_COST, 0) + NVL(tmp.ETC_BRDN_COST, 0)
                                  ) ETC_BRDN_COST
                 , DECODE ( ver3.wp_flag
                     , 'Y'
                     , DECODE(TO_CHAR(tmp.ETC_raw_COST)
                             , NULL
                     , NVL(rl.ETC_raw_COST, 0) + NVL(tmp.raw_COST, 0)
                     , NVL(rl.ETC_raw_COST, 0) + tmp.ETC_raw_COST
                                     )
                           , NVL(rl.ETC_raw_COST, 0) + NVL(tmp.ETC_raw_COST, 0)
                                  ) ETC_RAW_COST
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_labor_raw_COST)
                                     , NULL
                             , NVL(rl.ETC_labor_raw_COST, 0) + NVL(tmp.labor_raw_COST, 0)
                                             , NVL(rl.ETC_labor_raw_COST, 0) + tmp.ETC_labor_raw_COST
                                      )
                                 , NVL(rl.ETC_labor_raw_COST, 0) + NVL(tmp.ETC_labor_raw_COST, 0)
                                  ) ETC_LABOR_RAW_COST
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_equip_raw_COST)
                                     , NULL
                             , NVL(rl.ETC_equip_raw_COST, 0) + NVL(tmp.equipment_raw_COST, 0)
                             , NVL(rl.ETC_equip_raw_COST, 0) + tmp.ETC_equip_raw_COST
                                      )
                                   , NVL(rl.ETC_equip_raw_COST, 0) + NVL(tmp.ETC_equip_raw_COST, 0)
                            ) ETC_EQUIP_RAW_COST
       , NVL(rl.CUSTOM1, 0) + NVL(tmp.CUSTOM1, 0)
       , NVL(rl.CUSTOM2, 0) + NVL(tmp.CUSTOM2, 0)
       , NVL(rl.CUSTOM3, 0) + NVL(tmp.CUSTOM3, 0)
       , NVL(rl.CUSTOM4, 0) + NVL(tmp.CUSTOM4, 0)
       , NVL(rl.CUSTOM5, 0) + NVL(tmp.CUSTOM5, 0)
       , NVL(rl.CUSTOM6, 0) + NVL(tmp.CUSTOM6, 0)
       , NVL(rl.CUSTOM7, 0) + NVL(tmp.CUSTOM7, 0)
       , NVL(rl.CUSTOM8, 0) + NVL(tmp.CUSTOM8, 0)
       , NVL(rl.CUSTOM9, 0) + NVL(tmp.CUSTOM9, 0)
       , NVL(rl.CUSTOM10, 0) + NVL(tmp.CUSTOM10, 0)
       , NVL(rl.CUSTOM11, 0) + NVL(tmp.CUSTOM11, 0)
       , NVL(rl.CUSTOM12, 0) + NVL(tmp.CUSTOM12, 0)
       , NVL(rl.CUSTOM13, 0) + NVL(tmp.CUSTOM13, 0)
       , NVL(rl.CUSTOM14, 0) + NVL(tmp.CUSTOM14, 0)
       , NVL(rl.CUSTOM15, 0) + NVL(tmp.CUSTOM15, 0)
       , SYSDATE
       , l_last_updated_by
       , l_last_update_login
     FROM
       PJI_FP_RMAP_FPR_T           rwid
     , pji_fp_aggr_pjp1_t          tmp
     , pji_pjp_wbs_header          ver3
     WHERE  1 = 1
          AND tmp.rowid = rwid.pjp1_rowid
          AND rl.rowid = rwid.fpr_rowid
          AND rwid.fpr_rowid IS NOT NULL
          AND ver3.plan_version_id = tmp.plan_version_id
              AND ver3.plan_type_code = tmp.plan_type_code   /* 4471527 */
        AND rwid.worker_id = g_worker_id
        AND tmp.worker_id = g_worker_id
        -- AND ver3.worker_id = g_worker_id
        AND tmp.project_id = ver3.project_id
        AND tmp.plan_type_id = NVL(ver3.plan_type_id, -1) -- each plan type can have a different -3, -4 slice.
        )
     WHERE rl.rowid IN
             (
                   SELECT rwid.fpr_rowid
                   FROM PJI_FP_RMAP_FPR_T rwid
                   WHERE rwid.fpr_rowid IS NOT NULL
                 AND rwid.worker_id = g_worker_id
                   );

  print_time ( ' MERGE_INTO_FP_FACT 2.1 ' || sql%rowcount ) ;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'UPDATE_FP_ROWS');
    RAISE;
END;


PROCEDURE INSERT_FP_ROWS IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  INSERT INTO pji_fp_xbs_accum_f  fact
  (
       PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PLAN_TYPE_CODE     /* 4471527 */
  )
  SELECT /*+ ordered full(rwid) rowid(tmp) */
       tmp.PROJECT_ID
     , tmp.PROJECT_ORG_ID
     , tmp.PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , tmp.PROJECT_ELEMENT_ID
     , tmp.TIME_ID
     , tmp.PERIOD_TYPE_ID
     , tmp.CALENDAR_TYPE
     , tmp.RBS_AGGR_LEVEL
     , tmp.WBS_ROLLUP_FLAG
     , tmp.PRG_ROLLUP_FLAG
     , tmp.CURR_RECORD_TYPE_ID
     , tmp.CURRENCY_CODE
     , tmp.RBS_ELEMENT_ID
     , tmp.RBS_VERSION_ID
     , ver3.PLAN_VERSION_ID
     , tmp.PLAN_TYPE_ID
     , l_last_update_date
     , l_last_updated_by
     , l_creation_date
     , l_created_by
     , l_last_update_login
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_HRS)  -- For Workplan
                                 , NULL
                             , NVL(tmp.labor_hrs, 0)
                             , NVL(tmp.ETC_LABOR_HRS, 0)
                              )
                                      , NVL(tmp.ETC_LABOR_HRS, 0)
                       ) ETC_LABOR_HRS
                 , DECODE ( ver3.wp_flag
                          , 'Y'
                          , DECODE(TO_CHAR(tmp.ETC_EQUIP_HRS)
                                         , NULL
                                 , NVL(tmp.EQUIPMENT_hours, 0)
                                                     , NVL(tmp.ETC_EQUIP_HRS, 0)
                                            )
                               , NVL(tmp.ETC_EQUIP_HRS, 0)
                            ) ETC_EQUIP_HRS
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_BRDN_COST)
                                     , NULL
                             , NVL(tmp.labor_BRDN_COST, 0)
                                             , NVL(tmp.ETC_LABOR_BRDN_COST, 0)
                                         )
                                 , NVL(tmp.ETC_LABOR_BRDN_COST, 0)
                           ) ETC_LABOR_BRDN_COST
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_EQUIP_BRDN_COST)
                                     , NULL
                             , NVL(tmp.EQUIPment_BRDN_COST, 0)
                                 , NVL(tmp.ETC_equip_BRDN_COST, 0)
                                      )
                                  , NVL(tmp.ETC_EQUIP_BRDN_COST, 0)
                                  ) ETC_equip_BRDN_COST
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_BRDN_COST)
                                     , NULL
                             , NVL(tmp.BRDN_COST, 0)
                                             , NVL(tmp.ETC_BRDN_COST, 0)
                                      )
                                , NVL(tmp.ETC_BRDN_COST, 0)
                                  ) ETC_BRDN_COST
                 , DECODE ( ver3.wp_flag
                     , 'Y'
                     , DECODE(TO_CHAR(tmp.ETC_raw_COST)
                                    , NULL
                            , NVL(tmp.raw_COST, 0)
                                            , NVL(tmp.ETC_raw_COST, 0)
                                     )
                               , NVL(tmp.ETC_raw_COST, 0)
                                  ) ETC_raw_COST
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_labor_raw_COST)
                                     , NULL
                             , NVL(tmp.labor_raw_COST, 0)
                                             , NVL(tmp.ETC_labor_raw_COST, 0)
                                      )
                                , NVL(tmp.ETC_labor_raw_COST, 0)
                                  ) ETC_labor_raw_COST
                 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_equip_raw_COST)
                                     , NULL
                             , NVL(tmp.equipment_raw_COST, 0)
                             ,  NVL(tmp.ETC_equip_raw_COST, 0)
                                      )
                                , NVL(tmp.ETC_equip_raw_COST, 0)
                            ) ETC_equip_raw_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , tmp.plan_type_code     /* 4471527 */
  FROM PJI_FP_RMAP_FPR_T  rwid
     , pji_fp_aggr_pjp1_t tmp
     , pji_pjp_wbs_header ver3  -- replaced ver3 with wbs header for project-to-program association event.
  WHERE 1 = 1
   AND tmp.worker_id = g_worker_id
   AND rwid.worker_id = g_worker_id
   AND tmp.rowid = rwid.pjp1_rowid
   AND rwid.fpr_rowid IS NULL
   AND ver3.plan_version_id = tmp.plan_version_id
   AND ver3.plan_type_code = tmp.plan_type_code    /* 4471527 */
   AND tmp.project_id = ver3.project_id -- use index.
   AND tmp.plan_type_id = NVL(ver3.plan_type_id, -1) -- each plan type can have a different -3, -4 slice.
  ORDER BY
    tmp.PROJECT_ID
  , ver3.PLAN_VERSION_ID
  , tmp.PROJECT_ELEMENT_ID
  , tmp.TIME_ID
  , tmp.RBS_VERSION_ID;

  print_time ( ' MERGE_INTO_FP_FACT 3.1 worker id..' || g_worker_id || 'row count '  || SQL%ROWCOUNT) ;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_FP_ROWS');
    RAISE;
END;


PROCEDURE INSERT_INTO_AC_FACT IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN

  INSERT INTO PJI_AC_XBS_ACCUM_F
  (
     PROJECT_ID
   , PROJECT_ORG_ID
   , PROJECT_ORGANIZATION_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , PERIOD_TYPE_ID
   , CALENDAR_TYPE
   , WBS_ROLLUP_FLAG
   , PRG_ROLLUP_FLAG
   , CURR_RECORD_TYPE_ID
   , CURRENCY_CODE
   , REVENUE
   , INITIAL_FUNDING_AMOUNT
   , INITIAL_FUNDING_COUNT
   , ADDITIONAL_FUNDING_AMOUNT
   , ADDITIONAL_FUNDING_COUNT
   , CANCELLED_FUNDING_AMOUNT
   , CANCELLED_FUNDING_COUNT
   , FUNDING_ADJUSTMENT_AMOUNT
   , FUNDING_ADJUSTMENT_COUNT
   , REVENUE_WRITEOFF
   , AR_INVOICE_AMOUNT
   , AR_INVOICE_COUNT
   , AR_CASH_APPLIED_AMOUNT
   , AR_INVOICE_WRITE_OFF_AMOUNT
   , AR_INVOICE_WRITEOFF_COUNT
   , AR_CREDIT_MEMO_AMOUNT
   , AR_CREDIT_MEMO_COUNT
   , UNBILLED_RECEIVABLES
   , UNEARNED_REVENUE
   , AR_UNAPPR_INVOICE_AMOUNT
   , AR_UNAPPR_INVOICE_COUNT
   , AR_APPR_INVOICE_AMOUNT
   , AR_APPR_INVOICE_COUNT
   , AR_AMOUNT_DUE
   , AR_COUNT_DUE
   , AR_AMOUNT_OVERDUE
   , AR_COUNT_OVERDUE
   , DORMANT_BACKLOG_INACTIV
   , DORMANT_BACKLOG_START
   , LOST_BACKLOG
   , ACTIVE_BACKLOG
   , REVENUE_AT_RISK
   , LAST_UPDATE_DATE
   , LAST_UPDATED_BY
   , CREATION_DATE
   , CREATED_BY
   , LAST_UPDATE_LOGIN
   , CUSTOM1
   , CUSTOM2
   , CUSTOM3
   , CUSTOM4
   , CUSTOM5
   , CUSTOM6
   , CUSTOM7
   , CUSTOM8
   , CUSTOM9
   , CUSTOM10
   , CUSTOM11
   , CUSTOM12
   , CUSTOM13
   , CUSTOM14
   , CUSTOM15
  )
  SELECT
     PROJECT_ID
   , PROJECT_ORG_ID
   , PROJECT_ORGANIZATION_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , PERIOD_TYPE_ID
   , CALENDAR_TYPE
   , WBS_ROLLUP_FLAG
   , PRG_ROLLUP_FLAG
   , CURR_RECORD_TYPE_ID
   , CURRENCY_CODE
   , REVENUE
   , INITIAL_FUNDING_AMOUNT
   , INITIAL_FUNDING_COUNT
   , ADDITIONAL_FUNDING_AMOUNT
   , ADDITIONAL_FUNDING_COUNT
   , CANCELLED_FUNDING_AMOUNT
   , CANCELLED_FUNDING_COUNT
   , FUNDING_ADJUSTMENT_AMOUNT
   , FUNDING_ADJUSTMENT_COUNT
   , REVENUE_WRITEOFF
   , AR_INVOICE_AMOUNT
   , AR_INVOICE_COUNT
   , AR_CASH_APPLIED_AMOUNT
   , AR_INVOICE_WRITE_OFF_AMOUNT
   , AR_INVOICE_WRITEOFF_COUNT
   , AR_CREDIT_MEMO_AMOUNT
   , AR_CREDIT_MEMO_COUNT
   , UNBILLED_RECEIVABLES
   , UNEARNED_REVENUE
   , AR_UNAPPR_INVOICE_AMOUNT
   , AR_UNAPPR_INVOICE_COUNT
   , AR_APPR_INVOICE_AMOUNT
   , AR_APPR_INVOICE_COUNT
   , AR_AMOUNT_DUE
   , AR_COUNT_DUE
   , AR_AMOUNT_OVERDUE
   , AR_COUNT_OVERDUE
   , DORMANT_BACKLOG_INACTIV
   , DORMANT_BACKLOG_START
   , LOST_BACKLOG
   , ACTIVE_BACKLOG
   , REVENUE_AT_RISK
   , l_last_update_date
   , l_last_updated_by
   , l_creation_date
   , l_created_by
   , l_last_update_login
   , CUSTOM1
   , CUSTOM2
   , CUSTOM3
   , CUSTOM4
   , CUSTOM5
   , CUSTOM6
   , CUSTOM7
   , CUSTOM8
   , CUSTOM9
   , CUSTOM10
   , CUSTOM11
   , CUSTOM12
   , CUSTOM13
   , CUSTOM14
   , CUSTOM15
  FROM PJI_AC_AGGR_PJP1_T
  WHERE worker_id = g_worker_id
  ORDER BY
     PROJECT_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , CURRENCY_CODE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_INTO_AC_FACT');
    RAISE;
END;


PROCEDURE MERGE_INTO_AC_FACT IS
BEGIN

  CLEANUP_AC_RMAP_FPR;

  GET_AC_ROW_IDS;

  UPDATE_AC_ROWS;

  INSERT_AC_ROWS;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MERGE_INTO_AC_FACT');
    RAISE;
END;


PROCEDURE CLEANUP_AC_RMAP_FPR IS
BEGIN

  DELETE FROM PJI_ac_RMAP_acR_T
  WHERE worker_id = g_worker_id;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CLEANUP_AC_RMAP_FPR');
    RAISE;
END;


PROCEDURE GET_AC_ROW_IDS IS
BEGIN

  INSERT INTO PJI_ac_RMAP_acR_T
  (
     worker_id
   , pjp1_rowid
   , fpr_rowid
  )
  SELECT
    g_worker_id WORKER_ID
  , tmp.ROWID   PJP1_ROWID
  , rl.ROWID    FPR_ROWID
  FROM
    PJI_AC_AGGR_PJP1_T            tmp
  , PJI_AC_XBS_ACCUM_F          rl
  WHERE 1 = 1
   AND tmp.worker_id = g_worker_id
   AND tmp.PROJECT_ID = rl.PROJECT_ID (+)
   AND tmp.PROJECT_ORG_ID = rl.PROJECT_ORG_ID (+)
   AND tmp.PROJECT_ORGANIZATION_ID = rl.PROJECT_ORGANIZATION_ID (+)
   AND tmp.PROJECT_ELEMENT_ID = rl.PROJECT_ELEMENT_ID (+)
   AND tmp.TIME_ID = rl.TIME_ID (+)
   AND tmp.PERIOD_TYPE_ID = rl.PERIOD_TYPE_ID (+)
   AND tmp.CALENDAR_TYPE = rl.CALENDAR_TYPE (+)
   AND tmp.WBS_ROLLUP_FLAG = rl.WBS_ROLLUP_FLAG (+)
   AND tmp.PRG_ROLLUP_FLAG = rl.PRG_ROLLUP_FLAG (+)
   AND tmp.CURR_RECORD_TYPE_ID = rl.CURR_RECORD_TYPE_ID (+)
   AND tmp.CURRENCY_CODE = rl.CURRENCY_CODE (+) ;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_AC_ROW_IDS');
    RAISE;
END;


PROCEDURE UPDATE_AC_ROWS IS

  l_last_update_date  DATE   := SYSDATE;
  l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

    UPDATE /*+ ordered use_nl(rl) rowid(rl) */
      PJI_AC_XBS_ACCUM_F rl
    SET (
      rl.REVENUE
    , rl.INITIAL_FUNDING_AMOUNT
    , rl.INITIAL_FUNDING_COUNT
    , rl.ADDITIONAL_FUNDING_AMOUNT
    , rl.ADDITIONAL_FUNDING_COUNT
    , rl.CANCELLED_FUNDING_AMOUNT
    , rl.CANCELLED_FUNDING_COUNT
    , rl.FUNDING_ADJUSTMENT_AMOUNT
    , rl.FUNDING_ADJUSTMENT_COUNT
    , rl.REVENUE_WRITEOFF
    , rl.AR_INVOICE_AMOUNT
    , rl.AR_INVOICE_COUNT
    , rl.AR_CASH_APPLIED_AMOUNT
    , rl.AR_INVOICE_WRITE_OFF_AMOUNT
    , rl.AR_INVOICE_WRITEOFF_COUNT
    , rl.AR_CREDIT_MEMO_AMOUNT
    , rl.AR_CREDIT_MEMO_COUNT
    , rl.UNBILLED_RECEIVABLES
    , rl.UNEARNED_REVENUE
    , rl.AR_UNAPPR_INVOICE_AMOUNT
    , rl.AR_UNAPPR_INVOICE_COUNT
    , rl.AR_APPR_INVOICE_AMOUNT
    , rl.AR_APPR_INVOICE_COUNT
    , rl.AR_AMOUNT_DUE
    , rl.AR_COUNT_DUE
    , rl.AR_AMOUNT_OVERDUE
    , rl.AR_COUNT_OVERDUE
    , rl.DORMANT_BACKLOG_INACTIV
    , rl.DORMANT_BACKLOG_START
    , rl.LOST_BACKLOG
    , rl.ACTIVE_BACKLOG
    , rl.REVENUE_AT_RISK
    , rl.CUSTOM1
    , rl.CUSTOM2
    , rl.CUSTOM3
    , rl.CUSTOM4
    , rl.CUSTOM5
    , rl.CUSTOM6
    , rl.CUSTOM7
    , rl.CUSTOM8
    , rl.CUSTOM9
    , rl.CUSTOM10
    , rl.CUSTOM11
    , rl.CUSTOM12
    , rl.CUSTOM13
    , rl.CUSTOM14
    , rl.CUSTOM15
    , rl.LAST_UPDATE_DATE
    , rl.LAST_UPDATED_BY
    , rl.LAST_UPDATE_LOGIN
        ) =
    (
      SELECT  /*+  ORDERED ROWID(TMP) index(rwid,PJI_AC_RMAP_ACR_T_N1) */
         NVL(rl.REVENUE, 0) + NVL(tmp.REVENUE, 0)
       , NVL(rl.INITIAL_FUNDING_AMOUNT, 0) + NVL(tmp.INITIAL_FUNDING_AMOUNT, 0)
       , NVL(rl.INITIAL_FUNDING_COUNT, 0) + NVL(tmp.INITIAL_FUNDING_COUNT, 0)
       , NVL(rl.ADDITIONAL_FUNDING_AMOUNT, 0) + NVL(tmp.ADDITIONAL_FUNDING_AMOUNT, 0)
       , NVL(rl.ADDITIONAL_FUNDING_COUNT, 0) + NVL(tmp.ADDITIONAL_FUNDING_COUNT, 0)
       , NVL(rl.CANCELLED_FUNDING_AMOUNT, 0) + NVL(tmp.CANCELLED_FUNDING_AMOUNT, 0)
       , NVL(rl.CANCELLED_FUNDING_COUNT, 0) + NVL(tmp.CANCELLED_FUNDING_COUNT, 0)
       , NVL(rl.FUNDING_ADJUSTMENT_AMOUNT, 0) + NVL(tmp.FUNDING_ADJUSTMENT_AMOUNT, 0)
       , NVL(rl.FUNDING_ADJUSTMENT_COUNT, 0) + NVL(tmp.FUNDING_ADJUSTMENT_COUNT, 0)
       , NVL(rl.REVENUE_WRITEOFF, 0) + NVL(tmp.REVENUE_WRITEOFF, 0)
       , NVL(rl.AR_INVOICE_AMOUNT, 0) + NVL(tmp.AR_INVOICE_AMOUNT, 0)
       , NVL(rl.AR_INVOICE_COUNT, 0) + NVL(tmp.AR_INVOICE_COUNT, 0)
       , NVL(rl.AR_CASH_APPLIED_AMOUNT, 0) + NVL(tmp.AR_CASH_APPLIED_AMOUNT, 0)
       , NVL(rl.AR_INVOICE_WRITE_OFF_AMOUNT, 0) + NVL(tmp.AR_INVOICE_WRITE_OFF_AMOUNT, 0)
       , NVL(rl.AR_INVOICE_WRITEOFF_COUNT, 0) + NVL(tmp.AR_INVOICE_WRITEOFF_COUNT, 0)
       , NVL(rl.AR_CREDIT_MEMO_AMOUNT, 0) + NVL(tmp.AR_CREDIT_MEMO_AMOUNT, 0)
       , NVL(rl.AR_CREDIT_MEMO_COUNT, 0) + NVL(tmp.AR_CREDIT_MEMO_COUNT, 0)
       , NVL(rl.UNBILLED_RECEIVABLES, 0) + NVL(tmp.UNBILLED_RECEIVABLES, 0)
       , NVL(rl.UNEARNED_REVENUE, 0) + NVL(tmp.UNEARNED_REVENUE, 0)
       , NVL(rl.AR_UNAPPR_INVOICE_AMOUNT, 0) + NVL(tmp.AR_UNAPPR_INVOICE_AMOUNT, 0)
       , NVL(rl.AR_UNAPPR_INVOICE_COUNT, 0) + NVL(tmp.AR_UNAPPR_INVOICE_COUNT, 0)
       , NVL(rl.AR_APPR_INVOICE_AMOUNT, 0) + NVL(tmp.AR_APPR_INVOICE_AMOUNT, 0)
       , NVL(rl.AR_APPR_INVOICE_COUNT, 0) + NVL(tmp.AR_APPR_INVOICE_COUNT, 0)
       , NVL(rl.AR_AMOUNT_DUE, 0) + NVL(tmp.AR_AMOUNT_DUE, 0)
       , NVL(rl.AR_COUNT_DUE, 0) + NVL(tmp.AR_COUNT_DUE, 0)
       , NVL(rl.AR_AMOUNT_OVERDUE, 0) + NVL(tmp.AR_AMOUNT_OVERDUE, 0)
       , NVL(rl.AR_COUNT_OVERDUE, 0) + NVL(tmp.AR_COUNT_OVERDUE, 0)
       , NVL(rl.DORMANT_BACKLOG_INACTIV, 0) + NVL(tmp.DORMANT_BACKLOG_INACTIV, 0)
       , NVL(rl.DORMANT_BACKLOG_START, 0) + NVL(tmp.DORMANT_BACKLOG_START, 0)
       , NVL(rl.LOST_BACKLOG, 0) + NVL(tmp.LOST_BACKLOG, 0)
       , NVL(rl.ACTIVE_BACKLOG, 0) + NVL(tmp.ACTIVE_BACKLOG, 0)
       , NVL(rl.REVENUE_AT_RISK, 0) + NVL(tmp.REVENUE_AT_RISK, 0)
       , NVL(rl.CUSTOM1, 0) + NVL(tmp.CUSTOM1, 0)
       , NVL(rl.CUSTOM2, 0) + NVL(tmp.CUSTOM2, 0)
       , NVL(rl.CUSTOM3, 0) + NVL(tmp.CUSTOM3, 0)
       , NVL(rl.CUSTOM4, 0) + NVL(tmp.CUSTOM4, 0)
       , NVL(rl.CUSTOM5, 0) + NVL(tmp.CUSTOM5, 0)
       , NVL(rl.CUSTOM6, 0) + NVL(tmp.CUSTOM6, 0)
       , NVL(rl.CUSTOM7, 0) + NVL(tmp.CUSTOM7, 0)
       , NVL(rl.CUSTOM8, 0) + NVL(tmp.CUSTOM8, 0)
       , NVL(rl.CUSTOM9, 0) + NVL(tmp.CUSTOM9, 0)
       , NVL(rl.CUSTOM10, 0) + NVL(tmp.CUSTOM10, 0)
       , NVL(rl.CUSTOM11, 0) + NVL(tmp.CUSTOM11, 0)
       , NVL(rl.CUSTOM12, 0) + NVL(tmp.CUSTOM12, 0)
       , NVL(rl.CUSTOM13, 0) + NVL(tmp.CUSTOM13, 0)
       , NVL(rl.CUSTOM14, 0) + NVL(tmp.CUSTOM14, 0)
       , NVL(rl.CUSTOM15, 0) + NVL(tmp.CUSTOM15, 0)
       , l_last_update_date
       , l_last_updated_by
       , l_last_update_login
     FROM
       PJI_AC_RMAP_ACR_T rwid
     , PJI_AC_AGGR_PJP1_T tmp
     WHERE  1 = 1
        AND tmp.worker_id = g_worker_id
        AND rwid.worker_id = g_worker_id
          AND tmp.rowid = rwid.pjp1_rowid
          AND rl.rowid = rwid.fpr_rowid
          AND rwid.fpr_rowid IS NOT NULL
        )
     WHERE rl.rowid IN
             ( SELECT fpr_rowid
                   FROM PJI_ac_RMAP_acR_T rwid
                     WHERE 1=1
                   AND rwid.fpr_rowid IS NOT NULL
                   AND rwid.worker_id = g_worker_id);

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'UPDATE_AC_ROWS');
    RAISE;
END;


PROCEDURE INSERT_AC_ROWS IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN

  INSERT INTO PJI_AC_XBS_ACCUM_F
  (
     PROJECT_ID
   , PROJECT_ORG_ID
   , PROJECT_ORGANIZATION_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , PERIOD_TYPE_ID
   , CALENDAR_TYPE
   , WBS_ROLLUP_FLAG
   , PRG_ROLLUP_FLAG
   , CURR_RECORD_TYPE_ID
   , CURRENCY_CODE
   , REVENUE
   , INITIAL_FUNDING_AMOUNT
   , INITIAL_FUNDING_COUNT
   , ADDITIONAL_FUNDING_AMOUNT
   , ADDITIONAL_FUNDING_COUNT
   , CANCELLED_FUNDING_AMOUNT
   , CANCELLED_FUNDING_COUNT
   , FUNDING_ADJUSTMENT_AMOUNT
   , FUNDING_ADJUSTMENT_COUNT
   , REVENUE_WRITEOFF
   , AR_INVOICE_AMOUNT
   , AR_INVOICE_COUNT
   , AR_CASH_APPLIED_AMOUNT
   , AR_INVOICE_WRITE_OFF_AMOUNT
   , AR_INVOICE_WRITEOFF_COUNT
   , AR_CREDIT_MEMO_AMOUNT
   , AR_CREDIT_MEMO_COUNT
   , UNBILLED_RECEIVABLES
   , UNEARNED_REVENUE
   , AR_UNAPPR_INVOICE_AMOUNT
   , AR_UNAPPR_INVOICE_COUNT
   , AR_APPR_INVOICE_AMOUNT
   , AR_APPR_INVOICE_COUNT
   , AR_AMOUNT_DUE
   , AR_COUNT_DUE
   , AR_AMOUNT_OVERDUE
   , AR_COUNT_OVERDUE
   , DORMANT_BACKLOG_INACTIV
   , DORMANT_BACKLOG_START
   , LOST_BACKLOG
   , ACTIVE_BACKLOG
   , REVENUE_AT_RISK
   , LAST_UPDATE_DATE
   , LAST_UPDATED_BY
   , CREATION_DATE
   , CREATED_BY
   , LAST_UPDATE_LOGIN
   , CUSTOM1
   , CUSTOM2
   , CUSTOM3
   , CUSTOM4
   , CUSTOM5
   , CUSTOM6
   , CUSTOM7
   , CUSTOM8
   , CUSTOM9
   , CUSTOM10
   , CUSTOM11
   , CUSTOM12
   , CUSTOM13
   , CUSTOM14
   , CUSTOM15
  )
  SELECT
     PROJECT_ID
   , PROJECT_ORG_ID
   , PROJECT_ORGANIZATION_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , PERIOD_TYPE_ID
   , CALENDAR_TYPE
   , WBS_ROLLUP_FLAG
   , PRG_ROLLUP_FLAG
   , CURR_RECORD_TYPE_ID
   , CURRENCY_CODE
   , REVENUE
   , INITIAL_FUNDING_AMOUNT
   , INITIAL_FUNDING_COUNT
   , ADDITIONAL_FUNDING_AMOUNT
   , ADDITIONAL_FUNDING_COUNT
   , CANCELLED_FUNDING_AMOUNT
   , CANCELLED_FUNDING_COUNT
   , FUNDING_ADJUSTMENT_AMOUNT
   , FUNDING_ADJUSTMENT_COUNT
   , REVENUE_WRITEOFF
   , AR_INVOICE_AMOUNT
   , AR_INVOICE_COUNT
   , AR_CASH_APPLIED_AMOUNT
   , AR_INVOICE_WRITE_OFF_AMOUNT
   , AR_INVOICE_WRITEOFF_COUNT
   , AR_CREDIT_MEMO_AMOUNT
   , AR_CREDIT_MEMO_COUNT
   , UNBILLED_RECEIVABLES
   , UNEARNED_REVENUE
   , AR_UNAPPR_INVOICE_AMOUNT
   , AR_UNAPPR_INVOICE_COUNT
   , AR_APPR_INVOICE_AMOUNT
   , AR_APPR_INVOICE_COUNT
   , AR_AMOUNT_DUE
   , AR_COUNT_DUE
   , AR_AMOUNT_OVERDUE
   , AR_COUNT_OVERDUE
   , DORMANT_BACKLOG_INACTIV
   , DORMANT_BACKLOG_START
   , LOST_BACKLOG
   , ACTIVE_BACKLOG
   , REVENUE_AT_RISK
   , l_last_update_date
   , l_last_updated_by
   , l_creation_date
   , l_created_by
   , l_last_update_login
   , CUSTOM1
   , CUSTOM2
   , CUSTOM3
   , CUSTOM4
   , CUSTOM5
   , CUSTOM6
   , CUSTOM7
   , CUSTOM8
   , CUSTOM9
   , CUSTOM10
   , CUSTOM11
   , CUSTOM12
   , CUSTOM13
   , CUSTOM14
   , CUSTOM15
  FROM PJI_AC_AGGR_PJP1_T tmp
     , PJI_ac_RMAP_acR_T rwid
  WHERE 1 = 1
   AND tmp.worker_id = g_worker_id
   AND rwid.worker_id = g_worker_id
   AND tmp.rowid = rwid.pjp1_rowid
   AND rwid.fpr_rowid IS NULL
  ORDER BY
     PROJECT_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , CURRENCY_CODE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_AC_ROWS');
    RAISE;
END;

PROCEDURE MARK_DANGLING_PLAN_VERSIONS IS
BEGIN

  -- Added INDEX for bug 3828698
  UPDATE /*+ INDEX(bv,PA_BUDGET_VERSIONS_U1)*/ pa_budget_versions bv
  SET    pji_summarized_flag = 'P',
         record_version_number = nvl(record_version_number,0)+1
  WHERE  budget_version_id IN (
              SELECT plan_version_id
                FROM
              (
                  SELECT plan_version_id
                   , (   COUNT(DISTINCT time_dangling_flag)
                       + COUNT(DISTINCT rate_dangling_flag)
                     ) dangling
              FROM   pji_fp_aggr_pjp1_t
              WHERE worker_id = g_worker_id
          GROUP BY plan_version_id
                ) b
                WHERE dangling > 2
           );

  UPDATE   /*+ INDEX(bv,PA_BUDGET_VERSIONS_U1)*/ pa_budget_versions bv
  SET    pji_summarized_flag = 'Y',
         record_version_number = nvl(record_version_number,0)+1
  WHERE  budget_version_id IN (
              SELECT plan_version_id
                FROM
              (
                  SELECT plan_version_id
                   , (   COUNT(DISTINCT time_dangling_flag)
                       + COUNT(DISTINCT rate_dangling_flag)
                     ) dangling
              FROM   pji_fp_aggr_pjp1_t
              WHERE worker_id = g_worker_id
          GROUP BY plan_version_id
                ) b
                WHERE dangling = 2
           );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MARK_DANGLING_PLAN_VERSIONS');
    RAISE;
END;


--
-- 0. Plans cannot have time / rate dangling records for primary slice.
-- 1. Work plans have primary slice only.
-- 2. Financial plans can have secondary slices only if the plan is baselined.
-- 3. Only baselined financial plans can have time/rate dangling records.
-- 4. Four states of pji_summarized_flag are N, Y, P, NULL.
--      N - Not summarized..
--      P - Have rate/time dangling records..
--      Y - Project performance summaries fully created.
--      NULL - PJI summaries fully created.
--
-- This api processes plans with pji_summarized_flag = N, i.e., secondary slice
--  for dangling baselined financial plans.
--
PROCEDURE PULL_DANGLING_PLANS IS

  l_fp_wp_version_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_fp_version_ids      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

/*
  CURSOR c_dangling_vers_cur IS
  SELECT budget_version_id
  FROM   pa_budget_versions bv
  WHERE  pji_summarized_flag = 'P';
*/

BEGIN

  CLEANUP_INTERIM_TABLES;

--  FOR c_dangling IN c_dangling_vers_cur LOOP

--    print_time ( ' plan version id is ... ' || c_dangling.budget_version_id ) ;
--    l_fp_wp_version_ids := SYSTEM.pa_num_tbl_type (c_dangling.budget_version_id);

    PJI_FM_PLAN_MAINT.CREATE_SECONDARY_T_PVT(
      p_fp_version_ids    => l_fp_wp_version_ids
    , p_process_all       => 'T'
    , p_commit            => 'F');

--  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PULL_DANGLING_PLANS');
    RAISE;
END;


PROCEDURE RETRIEVE_ENTERED_SLICE (
  p_pln_ver_id IN NUMBER := NULL ) IS
BEGIN

    INSERT INTO pji_fp_aggr_pjp1_t
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
     , PLAN_TYPE_CODE
    )
    (
     SELECT
       g_worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , g_default_prg_level
     , plan_type_code
     FROM pji_fp_xbs_accum_f
     WHERE plan_version_id = p_pln_ver_id
    );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'RETRIEVE_ENTERED_SLICE');
    RAISE;
END;




PROCEDURE ROLLUP_FPR_RBS IS
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    -- l_worker_id            NUMBER := 1;

BEGIN

     INSERT INTO  pji_fp_aggr_pjp1_t
     (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE
    )
     SELECT
        g_worker_id WORKER_ID
      , fact1.PROJECT_ID
        , fact1.PROJECT_ORG_ID
        , fact1.PROJECT_ORGANIZATION_ID
      , fact1.project_element_id
        , fact1.TIME_ID
      , fact1.PERIOD_TYPE_ID
      , fact1.CALENDAR_TYPE
        , g_rolled_up
        , fact1.WBS_ROLLUP_FLAG
        , fact1.PRG_ROLLUP_FLAG
      , fact1.CURR_RECORD_TYPE_ID
      , fact1.CURRENCY_CODE
      , rbs.sup_id
      , fact1.RBS_VERSION_ID
      , fact1.PLAN_VERSION_ID
        , fact1.PLAN_TYPE_ID
      , SUM(fact1.RAW_COST)
      , SUM(fact1.BRDN_COST)
      , SUM(fact1.REVENUE)
      , SUM(fact1.BILL_RAW_COST)
      , SUM(fact1.BILL_BRDN_COST )
      , SUM(fact1.BILL_LABOR_RAW_COST)
      , SUM(fact1.BILL_LABOR_BRDN_COST )
      , SUM(fact1.BILL_LABOR_HRS )
      , SUM(fact1.EQUIPMENT_RAW_COST )
      , SUM(fact1.EQUIPMENT_BRDN_COST )
      , SUM(fact1.CAPITALIZABLE_RAW_COST )
      , SUM(fact1.CAPITALIZABLE_BRDN_COST )
      , SUM(fact1.LABOR_RAW_COST )
      , SUM(fact1.LABOR_BRDN_COST )
      , SUM(fact1.LABOR_HRS)
      , SUM(fact1.LABOR_REVENUE)
      , SUM(fact1.EQUIPMENT_HOURS)
      , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)
      , SUM(fact1.SUP_INV_COMMITTED_COST)
      , SUM(fact1.PO_COMMITTED_COST   )
      , SUM(fact1.PR_COMMITTED_COST  )
      , SUM(fact1.OTH_COMMITTED_COST)
       , SUM(fact1.ACT_LABOR_HRS)
         , SUM(fact1.ACT_EQUIP_HRS)
         , SUM(fact1.ACT_LABOR_BRDN_COST)
         , SUM(fact1.ACT_EQUIP_BRDN_COST)
         , SUM(fact1.ACT_BRDN_COST)
         , SUM(fact1.ACT_RAW_COST)
         , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
         , SUM(fact1.ETC_LABOR_HRS)
         , SUM(fact1.ETC_EQUIP_HRS)
         , SUM(fact1.ETC_LABOR_BRDN_COST)
         , SUM(fact1.ETC_EQUIP_BRDN_COST)
         , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
      , SUM(fact1.CUSTOM1 )
      , SUM(fact1.CUSTOM2 )
      , SUM(fact1.CUSTOM3 )
      , SUM(fact1.CUSTOM4 )
      , SUM(fact1.CUSTOM5 )
      , SUM(fact1.CUSTOM6 )
      , SUM(fact1.CUSTOM7 )
      , SUM(fact1.CUSTOM8 )
      , SUM(fact1.CUSTOM9 )
      , SUM(fact1.CUSTOM10 )
      , SUM(fact1.CUSTOM11 )
      , SUM(fact1.CUSTOM12 )
      , SUM(fact1.CUSTOM13 )
      , SUM(fact1.CUSTOM14 )
      , SUM(fact1.CUSTOM15 )
      , fact1.line_type
      , g_default_prg_level
      , fact1.plan_type_code            /* 4471527 */
    FROM pji_fp_aggr_pjp1_t       fact1
       , Pji_RBS_DENORM         rbs
         , pji_rollup_level_status smart
         , pji_pjp_rbs_header      rhdr
    WHERE 1 = 1
     AND fact1.project_id  = rhdr.project_id
     AND fact1.plan_version_id  = rhdr.plan_version_id
     AND fact1.plan_type_code = rhdr.plan_type_code     /*4471527 */
     AND rbs.struct_version_id = rhdr.rbs_version_id
     AND fact1.rbs_ELEMENT_ID = rbs.sub_id
     AND rbs.sup_level <> rbs.sub_level
     AND rbs.sup_level <> 1
     AND fact1.RBS_AGGR_LEVEL = g_lowest_level
     AND smart.rbs_version_id = rbs.struct_version_id
     AND smart.plan_version_id = fact1.plan_version_id
     AND smart.plan_type_code = fact1.plan_type_code    /*4471527 */
     AND fact1.worker_id = g_worker_id
    GROUP BY
        fact1.PROJECT_ID
        , fact1.PROJECT_ORG_ID
        , fact1.PROJECT_ORGANIZATION_ID
      , fact1.project_element_id
        , fact1.TIME_ID
      , fact1.PERIOD_TYPE_ID
      , fact1.CALENDAR_TYPE
        , fact1.WBS_ROLLUP_FLAG
        , fact1.PRG_ROLLUP_FLAG
      , fact1.CURR_RECORD_TYPE_ID
      , fact1.CURRENCY_CODE
      , rbs.sup_id
      , fact1.RBS_VERSION_ID
      , fact1.PLAN_VERSION_ID
        , fact1.PLAN_TYPE_ID
      , fact1.line_type
      , fact1.plan_type_code ;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'ROLLUP_FPR_RBS');
    RAISE;
END;


PROCEDURE ROLLUP_FPR_RBS_T_SLICE IS
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  print_time(' worker id is ... ' || 1);

     INSERT INTO  pji_fp_aggr_pjp1_t
     (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
           , ACT_EQUIP_HRS
           , ACT_LABOR_BRDN_COST
           , ACT_EQUIP_BRDN_COST
           , ACT_BRDN_COST
           , ACT_RAW_COST
           , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
           , ETC_LABOR_HRS
           , ETC_EQUIP_HRS
           , ETC_LABOR_BRDN_COST
           , ETC_EQUIP_BRDN_COST
           , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE     /* 4471527 */
    )
     SELECT
        g_worker_id WORKER_ID
      , fact1.PROJECT_ID
        , fact1.PROJECT_ORG_ID
        , fact1.PROJECT_ORGANIZATION_ID
      , fact1.project_element_id
        , fact1.TIME_ID
      , fact1.PERIOD_TYPE_ID
      , fact1.CALENDAR_TYPE
        , g_top_level
        , fact1.WBS_ROLLUP_FLAG
        , fact1.PRG_ROLLUP_FLAG
      , fact1.CURR_RECORD_TYPE_ID
      , fact1.CURRENCY_CODE
      , -1
      , -1
      , fact1.PLAN_VERSION_ID
        , fact1.PLAN_TYPE_ID
      , SUM(fact1.RAW_COST)
      , SUM(fact1.BRDN_COST)
      , SUM(fact1.REVENUE)
      , SUM(fact1.BILL_RAW_COST)
      , SUM(fact1.BILL_BRDN_COST )
      , SUM(fact1.BILL_LABOR_RAW_COST)
      , SUM(fact1.BILL_LABOR_BRDN_COST )
      , SUM(fact1.BILL_LABOR_HRS )
      , SUM(fact1.EQUIPMENT_RAW_COST )
      , SUM(fact1.EQUIPMENT_BRDN_COST )
      , SUM(fact1.CAPITALIZABLE_RAW_COST )
      , SUM(fact1.CAPITALIZABLE_BRDN_COST )
      , SUM(fact1.LABOR_RAW_COST )
      , SUM(fact1.LABOR_BRDN_COST )
      , SUM(fact1.LABOR_HRS)
      , SUM(fact1.LABOR_REVENUE)
      , SUM(fact1.EQUIPMENT_HOURS)
      , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)
      , SUM(fact1.SUP_INV_COMMITTED_COST)
      , SUM(fact1.PO_COMMITTED_COST   )
      , SUM(fact1.PR_COMMITTED_COST  )
      , SUM(fact1.OTH_COMMITTED_COST)
       , SUM(fact1.ACT_LABOR_HRS)
         , SUM(fact1.ACT_EQUIP_HRS)
         , SUM(fact1.ACT_LABOR_BRDN_COST)
         , SUM(fact1.ACT_EQUIP_BRDN_COST)
         , SUM(fact1.ACT_BRDN_COST)
         , SUM(fact1.ACT_RAW_COST)
         , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
         , SUM(fact1.ETC_LABOR_HRS)
         , SUM(fact1.ETC_EQUIP_HRS)
         , SUM(fact1.ETC_LABOR_BRDN_COST)
         , SUM(fact1.ETC_EQUIP_BRDN_COST)
         , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
      , SUM(fact1.CUSTOM1 )
      , SUM(fact1.CUSTOM2 )
      , SUM(fact1.CUSTOM3 )
      , SUM(fact1.CUSTOM4 )
      , SUM(fact1.CUSTOM5 )
      , SUM(fact1.CUSTOM6 )
      , SUM(fact1.CUSTOM7 )
      , SUM(fact1.CUSTOM8 )
      , SUM(fact1.CUSTOM9 )
      , SUM(fact1.CUSTOM10 )
      , SUM(fact1.CUSTOM11 )
      , SUM(fact1.CUSTOM12 )
      , SUM(fact1.CUSTOM13 )
      , SUM(fact1.CUSTOM14 )
      , SUM(fact1.CUSTOM15 )
      , fact1.line_type
      , g_default_prg_level
      , fact1.PLAN_TYPE_CODE     /* 4471527 */
    FROM pji_fp_aggr_pjp1_t       fact1
       , pji_fm_extr_plnver3_t    ver3
    WHERE
          fact1.RBS_AGGR_LEVEL = g_lowest_level
      AND fact1.worker_id = g_worker_id
      AND fact1.plan_version_id = ver3.plan_version_id
      AND fact1.plan_type_code = ver3.plan_type_code   /*4471527 */
      AND ( fact1.rbs_version_id = ver3.rbs_struct_version_id
         OR fact1.rbs_version_id = -1)
      AND ver3.secondary_rbs_flag = 'N'
    GROUP BY
        fact1.PROJECT_ID
        , fact1.PROJECT_ORG_ID
        , fact1.PROJECT_ORGANIZATION_ID
      , fact1.project_element_id
        , fact1.TIME_ID
      , fact1.PERIOD_TYPE_ID
      , fact1.CALENDAR_TYPE
        , fact1.WBS_ROLLUP_FLAG
        , fact1.PRG_ROLLUP_FLAG
      , fact1.CURR_RECORD_TYPE_ID
      , fact1.CURRENCY_CODE
      -- , fact1.RBS_VERSION_ID
      , fact1.PLAN_VERSION_ID
      , fact1.PLAN_TYPE_ID
      , fact1.line_type
      , fact1.plan_type_code ;    /* 4471527 */


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'ROLLUP_FPR_RBS_T_SLICE');
    RAISE;
END;


PROCEDURE COMPUTE_XBS_UPDATED_ROLLUPS IS
BEGIN
  NULL;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'COMPUTE_XBS_UPDATED_ROLLUPS');
    RAISE;
END;


PROCEDURE POPULATE_RBS_HDR IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  print_time ( ' Before update rbs header ' );

  INSERT INTO pji_pjp_rbs_header
  (
      project_id
    , plan_version_id
    , rbs_version_id
    , reporting_usage_flag
    , prog_rep_usage_flag
    , plan_usage_flag
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_LOGIN
    , PLAN_TYPE_CODE   /*4471527 */
  )
  SELECT rpa.project_id
      , bv.plan_version_id
      , rpa.rbs_version_id
      , rpa.reporting_usage_flag
      , rpa.prog_rep_usage_flag
      , DECODE(bv.wp_flag, 'Y', rpa.wp_usage_flag, rpa.fp_usage_flag)
      , l_last_update_date
      , l_last_updated_by
      , l_creation_date
      , l_created_by
      , l_last_update_login
      , bv.plan_type_code    /*4471527 */
  FROM pa_rbs_prj_assignments rpa
      , PJI_FM_EXTR_PLNVER3_T bv
      , pji_pjp_rbs_header head
  WHERE bv.project_id = rpa.project_id
    AND bv.RBS_STRUCT_VERSION_ID  = rpa.RBS_VERSION_ID
    AND bv.PROJECT_ID = head.PROJECT_ID (+)
    AND bv.PLAN_VERSION_ID = head.PLAN_VERSION_ID (+)
   AND bv.plan_type_code = head.plan_type_code (+)  /* 4471527 */
    AND bv.RBS_STRUCT_VERSION_ID = head.RBS_VERSION_ID (+)
    AND head.PROJECT_ID IS NULL
    AND bv.plan_version_id > 0;

  print_time ( ' After populate rbs header for WPs/FPs. # rows inserted = ' || SQL%ROWCOUNT );

  INSERT INTO pji_pjp_rbs_header
  (
      project_id
    , plan_version_id
    , rbs_version_id
    , reporting_usage_flag
    , prog_rep_usage_flag
    , plan_usage_flag
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_LOGIN
    ,PLAN_TYPE_CODE    /* 4471527 */
  )
  SELECT distinct bv.project_id
       , bv.plan_version_id
       , bv.rbs_struct_version_id
       , 'Y' -- rpa.reporting_usage_flag
       , 'Y' -- rpa.prog_rep_usage_flag
       , 'N' -- DECODE(bv.wp_flag, 'Y', rpa.wp_usage_flag, rpa.fp_usage_flag)
       , l_last_update_date
       , l_last_updated_by
       , l_creation_date
       , l_created_by
       , l_last_update_login
       , bv.plan_type_code    /* 4471527 */
  FROM  PJI_FM_EXTR_PLNVER3_T bv
      , pji_pjp_rbs_header head
  WHERE bv.PROJECT_ID = head.PROJECT_ID (+)
    AND bv.PLAN_VERSION_ID = head.PLAN_VERSION_ID (+)
    AND bv.plan_type_code = head.plan_type_code (+)     /* 4471527 */
    AND bv.RBS_STRUCT_VERSION_ID = head.RBS_VERSION_ID (+)
    AND head.PROJECT_ID IS NULL
    AND bv.plan_version_id in (-3, -4)
    AND bv.RBS_STRUCT_VERSION_ID is not null;  /*4882640*/

  print_time ( ' After populate rbs header for -3/-4s. # rows inserted = ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' update rbs header exception ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_RBS_HDR');
    RAISE;
END;


PROCEDURE POPULATE_WBS_HDR IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  print_time ( ' Before populate wbs header ' );

  INSERT INTO PJI_PJP_WBS_HEADER
  (
    PROJECT_ID
  , PLAN_VERSION_ID
  , WBS_VERSION_ID
  , WP_FLAG
  , CB_FLAG
  , CO_FLAG
  , LOCK_FLAG
  , PLAN_TYPE_ID
  , MIN_TXN_DATE
  , MAX_TXN_DATE
  , PLAN_TYPE_CODE       /* 4471527 */
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_LOGIN
  )
  SELECT DISTINCT
         ver.project_id
       , ver.plan_version_id
       , ver.wbs_struct_version_id
       , ver.wp_flag
       , DECODE( (ver.current_flag || ver.baselined_flag) , 'YY', 'Y', 'N')
         , ver.current_original_flag
       , null
       , ver.plan_type_id
       , to_date('3000/01/01', 'YYYY/MM/DD') MIN_TXN_DATE
       , to_date('0001/01/01', 'YYYY/MM/DD') MAX_TXN_DATE
       , ver.plan_type_code      /* 4471527 */
       , l_last_update_date
       , l_last_updated_by
       , l_creation_date
       , l_created_by
       , l_last_update_login
  FROM PJI_FM_EXTR_PLNVER3_T ver
     , PJI_PJP_WBS_HEADER  whdr
  WHERE ver.plan_version_id = whdr.plan_version_id (+)
    AND ver.project_id = whdr.project_id (+)
    -- AND ver.wbs_struct_version_id = whdr.wbs_version_id (+)
    AND ver.plan_type_id = whdr.plan_type_id (+)
    AND ver.plan_type_code = whdr.plan_type_code (+)     /* 4471527 */
    AND whdr.plan_version_id IS NULL
  ORDER BY
        ver.project_id
      , ver.plan_version_id;

  print_time ( ' After populate wbs header. # rows inserted = ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' populate wbs header exception ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_WBS_HDR');
    RAISE;
END;


PROCEDURE UPDATE_WBS_HDR  IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  print_time ( ' Before update wbs header ' );

  UPDATE /*+ index(whdr,PJI_PJP_WBS_HEADER_N1) */
         PJI_PJP_WBS_HEADER whdr
  SET ( MIN_TXN_DATE
      , MAX_TXN_DATE
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      ) = (
  SELECT MIN(LEAST(cal.start_date,  NVL(whdr.min_txn_date, cal.start_date))) start_date
       , MAX(GREATEST(cal.end_date, NVL(whdr.max_txn_date, cal.end_date))) end_date
       , l_last_update_date
       , l_last_updated_by
       , l_last_update_login
    FROM PJI_FP_AGGR_PJP1_T    pjp1
       , pji_time_cal_period_v   cal
   WHERE
         pjp1.worker_id = g_worker_id
     AND pjp1.plan_version_id = whdr.plan_version_id
     AND pjp1.project_id = whdr.project_id
     AND pjp1.plan_type_id = whdr.plan_type_id
     AND pjp1.time_id = cal.cal_period_id
     AND pjp1.calendar_type IN ('P', 'G') -- Non time ph and ent cals don't need to be considered.
                                      )
 /*
 WHERE (project_id, plan_version_id) IN
         (
          SELECT DISTINCT project_id, plan_version_id
          FROM   pji_fp_aggr_pjp1_t
         );
For bug 7192035		 */

		 WHERE exists (select 1 from  pji_fp_aggr_pjp1_t ver where worker_id = g_worker_id
 	                and ver.project_id = whdr.project_id
 	                and ver.plan_version_id = whdr.plan_version_id
 	                and ver.plan_type_id = whdr.plan_type_id);

  print_time ( ' After update wbs header. # rows updated = ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' update wbs header exception ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_WBS_HDR');
    RAISE;
END;



PROCEDURE MARK_TIME_DANGLING_VERSIONS IS
BEGIN

   UPDATE PJI_FM_EXTR_PLNVER3_T
   SET TIME_DANGLING_FLAG = 'Y'
   WHERE plan_version_id IN
    (SELECT fact.plan_version_id
     FROM pji_fp_aggr_pjp1_t fact
        , pji_time_cal_period_v  time
          , pji_org_extr_info    orginfo
     WHERE fact.period_type_id = 32
       AND fact.worker_id = g_worker_id
       AND fact.calendar_type = 'P'
       AND fact.time_id = time.cal_period_id
         AND orginfo.org_id = fact.project_org_id
         AND TO_NUMBER(TO_CHAR(time.end_date, 'J')) > gl_calendar_max_date);

   UPDATE PJI_FM_EXTR_PLNVER3_T
   SET TIME_DANGLING_FLAG = 'Y'
   WHERE plan_version_id IN
    (SELECT fact.plan_version_id
     FROM pji_fp_aggr_pjp1_t fact
        , pji_time_cal_period_v  time
          , pji_org_extr_info    orginfo
     WHERE fact.period_type_id = 32
       AND fact.worker_id = g_worker_id
       AND fact.calendar_type = 'G'
       AND fact.time_id = time.cal_period_id
         AND orginfo.org_id = fact.project_org_id
         AND TO_NUMBER(TO_CHAR(time.end_date, 'J')) > pa_calendar_max_date);

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MARK_TIME_DANGLING_VERSIONS');
    RAISE;
END;


PROCEDURE MARK_EXTRACTED_PLANS(p_slice_type IN VARCHAR2) IS
l_dangling_flag     VARCHAR2(1);
l_plan_version_id   NUMBER;

CURSOR PLANS_TO_MARK
    IS SELECT DISTINCT project_id,plan_version_id
         FROM pji_fm_extr_plnver3_t;

l_plans_to_mark  PLANS_TO_MARK%ROWTYPE;

BEGIN

  --
  -- On PA_BUDGET_VERSIONS, the PJI_SUMMARIZED_FLAG can have four values:
  --   'N' the plan version has not been summarized
  --   'P' the plan version has been partially summarized due to dangling currency or calendar records
  --   'Y' the plan version has been fully summarized in Project Performance and
  --   NULL the plan version has been fully summarized in both PJI and Project Performance.
  --
  -- Note that, in PJI data extraction, data that existed before PJI was installed
  -- has PJI_SUMMARIZED_FLAG = null and new transactions are inserted with value 'N'.
  -- A similar situation does not occur in PA_BUDGET_VERSIONS.  During the upgrade process
  -- will pull necessary data from PA_BUDGET_VERSIONS and set PJI_SUMMARIZATION_FLAG to 'P', 'N'
  -- or 'Y' accordingly.  New versions will be inserted with value 'N'.)
  --

  IF (p_slice_type = 'PRI') THEN
    /* Added index for bug 3818232 */
    UPDATE  /*+ INDEX( pa_budget_versions PA_BUDGET_VERSIONS_U1)*/
       pa_budget_versions
    SET    pji_summarized_flag =
                       DECODE(wp_version_flag
                            , 'Y', 'Y'
                            , DECODE(budget_status_code
                                   , 'B', 'P'
                                   , 'Y')
                             ),
            record_version_number=nvl(record_version_number,0)+1
    WHERE  budget_version_id IN
               ( SELECT DISTINCT plan_version_id
                 FROM   pji_fm_extr_plnver3_t );

  ELSE -- Secondary slice.
  FOR l_plans_to_mark IN PLANS_TO_MARK LOOP
           DECLARE
           BEGIN
           SELECT 'Y'
             INTO l_dangling_flag
              FROM DUAL
             WHERE EXISTS(
                           SELECT 1
                             FROM pji_fp_aggr_pjp1_t
                            WHERE (  time_dangling_flag IS NOT NULL
                                  OR rate_dangling_flag IS NOT NULL )
                              AND worker_id=g_worker_id
                              AND project_id=l_plans_to_mark.project_id
                              AND plan_version_id=l_plans_to_mark.plan_version_id
                            UNION ALL
                           SELECT 1
                             FROM PJI_FM_EXTR_PLNVER3_T
                            WHERE time_dangling_flag IS NOT NULL
                              AND project_id=l_plans_to_mark.project_id
                              AND plan_version_id=l_plans_to_mark.plan_version_id
                          );
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                    l_dangling_flag :='N';
            END;



            UPDATE pa_budget_versions
               SET pji_summarized_flag = decode(l_dangling_flag,'Y','P','Y'),
                   record_version_number=nvl(record_version_number,0)+1
             WHERE  budget_version_id IN
                      (
                             SELECT plan_version_id
                             FROM  PJI_FM_EXTR_PLNVER3_T
                      );

END LOOP;
   -- Added INDEX for bug 3828698

/*    UPDATE  pa_budget_versions
    SET    pji_summarized_flag = 'Y',
           record_version_number=nvl(record_version_number,0)+1
     WHERE  budget_version_id IN
              (
                     SELECT DISTINCT plan_version_id
                     FROM   pji_fp_aggr_pjp1_t
                     WHERE  worker_id = g_worker_id
              )
       AND  budget_version_id NOT IN
                (
                          SELECT DISTINCT plan_version_id
                          FROM   pji_fp_aggr_pjp1_t
                          WHERE worker_id = g_worker_id
                            AND (time_dangling_flag IS NOT NULL
                              OR rate_dangling_flag IS NOT NULL )
                        )
       AND  budget_version_id NOT IN
                 (        SELECT distinct plan_version_id
                            FROM PJI_FM_EXTR_PLNVER3_T
                           WHERE time_dangling_flag IS NOT NULL
                 );

    UPDATE  pa_budget_versions
    SET    pji_summarized_flag = 'P',
            record_version_number=nvl(record_version_number,0)+1
    WHERE  budget_version_id IN
                (
                          SELECT DISTINCT plan_version_id
                          FROM   pji_fp_aggr_pjp1_t
                          WHERE worker_id = g_worker_id
                            AND (time_dangling_flag IS NOT NULL
                              OR rate_dangling_flag IS NOT NULL )
                        )
      OR   budget_version_id in
                 (        SELECT distinct plan_version_id
                            FROM PJI_FM_EXTR_PLNVER3_T
                           WHERE time_dangling_flag IS NOT NULL
                 ); */

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MARK_EXTRACTED_PLANS');
    RAISE;
END;



------------------------------------------------------------------------------
---- WBS rollup api..
------------------------------------------------------------------------------

PROCEDURE CREATE_WBSRLP IS
BEGIN

  print_time('... Begin CREATE_WBSRLP ' );

  PRINT_NUM_WBSRLPRCDS_INPJP1;

  print_time('... Before call to rollup_fpr_wbs...' );

  PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_WBS;

  print_time('... after call to rollup_fpr_wbs. ' );

  PRINT_NUM_WBSRLPRCDS_INPJP1;

  print_time('... End CREATE_WBSRLP ' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('... Exception CREATE_WBSRLP ' );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_WBSRLP');
    RAISE;
END;



PROCEDURE PRINT_NUM_WBSRLPRCDS_INPJP1 IS
  l_count NUMBER;
  l_wbs_rollup_flag  VARCHAR2(1);
  l_prg_rollup_flag  VARCHAR2(1);
  l_return_status    VARCHAR2(1);

BEGIN

  l_wbs_rollup_flag  := 'N';
  l_prg_rollup_flag  := 'N';

/*
  select count(1)
  INTO   l_count
  FROM   pji_fp_aggr_pjp1_t
  WHERE  wbs_rollup_flag = l_wbs_rollup_flag
    AND  prg_rollup_flag = l_prg_rollup_flag;

  print_time ( ' l_worker_id = '|| g_worker_id || ' wbs rollup flag = ' || l_wbs_rollup_flag || ' prg rollup flag = ' || l_prg_rollup_flag || ' l_count ' || l_count);


  l_wbs_rollup_flag  := 'N';
  l_prg_rollup_flag  := 'Y';

  select count(1)
  INTO   l_count
  FROM   pji_fp_aggr_pjp1_t
  WHERE  wbs_rollup_flag = l_wbs_rollup_flag
    AND  prg_rollup_flag = l_prg_rollup_flag;

  print_time ( ' l_worker_id = '|| g_worker_id || ' wbs rollup flag = ' || l_wbs_rollup_flag || ' prg rollup flag = ' || l_prg_rollup_flag || ' l_count ' || l_count);


  l_wbs_rollup_flag  := 'Y';
  l_prg_rollup_flag  := 'N';

  select count(1)
  INTO   l_count
  FROM   pji_fp_aggr_pjp1_t
  WHERE  wbs_rollup_flag = l_wbs_rollup_flag
    AND  prg_rollup_flag = l_prg_rollup_flag;

  print_time ( ' l_worker_id = '|| g_worker_id || ' wbs rollup flag = ' || l_wbs_rollup_flag || ' prg rollup flag = ' || l_prg_rollup_flag || ' l_count ' || l_count);


  l_wbs_rollup_flag  := 'Y';
  l_prg_rollup_flag  := 'Y';

  select count(1)
  INTO   l_count
  FROM   pji_fp_aggr_pjp1_t
  WHERE  wbs_rollup_flag = l_wbs_rollup_flag
    AND  prg_rollup_flag = l_prg_rollup_flag;

  print_time ( ' l_worker_id = '|| g_worker_id || ' wbs rollup flag = ' || l_wbs_rollup_flag || ' prg rollup flag = ' || l_prg_rollup_flag || ' l_count ' || l_count);
*/

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PRINT_NUM_WBSRLPRCDS_INPJP1'
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


PROCEDURE CLEANUP_INTERIM_TABLES IS
  l_count NUMBER;
BEGIN

  print_time('.......CLEANUP_INTERIM_TABLES: Begin. ');

  DELETE FROM PJI_FM_EXTR_PLNVER3_T ; -- No worker id join needed for online case.

  print_time('.......ver3 rows deleted: #= ' || sql%rowcount);

  DELETE FROM pji_fp_aggr_pjp1_t ; -- No worker id join needed for online case.

  print_time('.......pjp1 rows deleted: #= ' || sql%rowcount);

  print_time('.......CLEANUP_INTERIM_TABLES: End. ');

EXCEPTION
  WHEN OTHERS THEN
    print_time('.......CLEANUP_INTERIM_TABLES: Exception. ' || sqlerrm);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CLEANUP_INTERIM_TABLES');
    RAISE;
END CLEANUP_INTERIM_TABLES;


PROCEDURE SET_WORKER_ID(p_worker_id IN NUMBER := NULL) IS
  l_return_status VARCHAR2(1);
BEGIN
  IF (p_worker_id IS NOT NULL) THEN
    g_worker_id := p_worker_id;
  ELSE
    g_worker_id := 1; -- PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'SET_WORKER_ID'
    , x_return_status  => l_return_status ) ;

    RAISE;
END;



--
-- Temp fix until time table will have a record for non time phasing.
--
PROCEDURE INSERT_NTP_CAL_RECORD ( x_max_plnver_id OUT NOCOPY  NUMBER ) IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

    l_start_end_date       DATE   := TRUNC(SYSDATE);

BEGIN

  BEGIN

    SELECT MAX(plan_version_id)
    INTO   x_max_plnver_id
    FROM   pji_fm_extr_plnver3_t;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END;

  IF (x_max_plnver_id IS NULL) THEN
    RETURN;
  END IF;

  print_time (' Inside INSERT_NTP_CAL_RECORD, max project_id is: ' || x_max_plnver_id);

   INSERT INTO pji_time_cal_period
  (
                CAL_PERIOD_ID,
                CAL_QTR_ID,
                CALENDAR_ID,
                SEQUENCE,
                NAME ,
                START_DATE,
                END_DATE,
                CREATION_DATE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATED_BY,
                LAST_UPDATE_LOGIN
)
  SELECT  -x_max_plnver_id   cal_period_id
        , -x_max_plnver_id   cal_qtr_id
        , -x_max_plnver_id   calendar_id
        , -x_max_plnver_id   SEQUENCE
        , g_ntp_period_name   name
        , l_start_end_date    start_date
        , l_start_end_date    end_date
        , l_creation_date     creation_date
        , l_last_update_date  last_update_date
        , l_last_updated_by   last_updated_by
        , l_created_by        created_by
        , l_last_update_login last_update_login
    FROM  DUAL;

    print_time (' INSERT_NTP_CAL_RECORD, # rows inserted is: ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_NTP_CAL_RECORD');
    RAISE;
END;


PROCEDURE DELETE_NTP_CAL_RECORD ( p_max_plnver_id IN NUMBER ) IS
BEGIN

    print_time (' DELETE_NTP_CAL_RECORD, max project_id is: ' || p_max_plnver_id);

    DELETE FROM pji_time_cal_period
    WHERE cal_period_id =  -p_max_plnver_id;

    print_time (' DELETE_NTP_CAL_RECORD, # rows deleted is: ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DELETE_NTP_CAL_RECORD');
    RAISE;
END;


--
--   MAP_ORG_CAL_INFO
-- 1. Populates/updates the org extr info table with any calendar and org information
--      that has changed from the last time this table was updated.
-- 2. Populates pa/gl/ent calendar period tables with newly opened periods.
--
PROCEDURE MAP_ORG_CAL_INFO (
  p_fpm_upgrade IN VARCHAR2 := 'Y'
) IS

  l_return_status VARCHAR2(1) := NULL;
  l_msg_count     NUMBER := NULL;
  l_msg_data      VARCHAR2(300) := NULL;

  CURSOR c_cal_attributes_cur IS
  SELECT DISTINCT
         DECODE(split_cal.cal_type
              , 1
              , sob.period_set_name -- gl cal period set name.
              , 2
              , imp.period_set_name -- pa
              ) period_set_name
       , DECODE(split_cal.cal_type
              , 1
              , sob.accounted_period_type -- gl
              , 2
              , imp.pa_period_type -- pa
              ) period_type
  FROM pa_implementations_all imp
     , gl_sets_of_books sob
     , pa_projects_all proj
     , pji_fm_extr_plnver3_t ver
     , ( SELECT 1 cal_type FROM DUAL -- 1 GL, 2 PA.
         UNION ALL
         SELECT 2 FROM DUAL
       ) split_cal
  WHERE 1=1
  AND proj.org_id=imp.org_id
  AND ver.project_id = proj.project_id
  AND imp.set_of_books_id = sob.set_of_books_id;

BEGIN

  print_time('MAP_ORG_CAL_INFO : begin calendar table updates.. ');

  IF (p_fpm_upgrade = 'Y') THEN

    NULL;

  ELSIF (p_fpm_upgrade = 'N') THEN

    FOR i IN c_cal_attributes_cur LOOP

      print_time( ' i.period_set_name = ' || i.period_set_name );
      print_time( ' i.period_type = ' || i.period_type);

      PJI_TIME_C.LOAD(
        p_period_set_name => i.period_set_name
      , p_period_type     => i.period_type
      , x_return_status   => l_return_status
      , x_msg_count       => l_msg_count
      , x_msg_data        => l_msg_data );

      print_time( ' l_return_status = ' || l_return_status );

   END LOOP;

  END IF;

  print_time(' Finished calendar table updates.. ');

  IF (p_fpm_upgrade = 'Y') THEN
    PJI_PJP_EXTRACTION_UTILS.POPULATE_ORG_EXTR_INFO;
  ELSIF (p_fpm_upgrade = 'N') THEN
    PJI_PJP_EXTRACTION_UTILS.UPDATE_ORG_EXTR_INFO;
  END IF;

  print_time(' Finished updating org extr info table. ');
  print_time(' MAP_ORG_CAL_INFO : end.. ');

EXCEPTION
  WHEN OTHERS THEN
    print_time('MAP_ORG_CAL_INFO : exception.. ');
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MAP_ORG_CAL_INFO');
    RAISE;
END;


----------
-- Print time API to measure time taken by each api. Also useful for debugging.
----------
PROCEDURE PRINT_TIME(p_tag IN VARCHAR2) IS
BEGIN
  PJI_PJP_FP_CURR_WRAP.print_time(p_tag);
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRINT_TIME');
    RAISE;
END;


BEGIN  --  this portion is executed WHENever the package is initialized

  g_worker_id  := 1; -- PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;


END PJI_FM_PLAN_MAINT_T_PVT;

/
