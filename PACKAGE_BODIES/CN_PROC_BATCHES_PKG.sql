--------------------------------------------------------
--  DDL for Package Body CN_PROC_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PROC_BATCHES_PKG" AS
  /* $Header: cnsybatb.pls 120.20.12010000.2 2008/09/26 10:07:47 venjayar ship $ */

  /*
  Date      Name          Description
  =============================================================================
  19-MAY-95 P Cook  Created
  08-JUN-95 P Cook  Only pass process_type 'CALCULATION' to message_pkg
        - previously used TRX_MAIN.., TRX_BATCH.., TRX_RUN..
  26-JUN-95 P Cook  Replaced 'payee' process with rollup and populate
  05-JUL-95 P Cook  Removed call to cn_periods_pkg.set_processing_status.
        Call is now made by the cn_srp_periods_pkg.raise_status
  14-JUL-95 P Cook  Raise exception with mesg if class pkg does not exist
        Fixed populate batch proc to prevent duplicate keys
  15-JUL-95 P Cook  Modified calls to begin batch
  01-AUG-95 P Cook  Added populate_calcsub_batches
  10-AUG-95 P Cook  Modified populate_calcsub_batches to populate
        cn_process_batches with all salesrep/periods that are
        impacted by running calc on a salesrep.
  11-AUG-95 P Cook  Revised calcsub to populate correct impacted salesreps
  14-AUG-95 P Cook  Replace hardcoded trx batch size with system_batch_size
  18-AUG-95 P Cook  Handle no_data_found in flood routine excep handlers
  30-AUG-95 P Cook  Replaced 'raise app_exception' with 'raise' in
        'when others' to show the actual exception being raised
  31-AUG-95 P Cook  Pass process_audit_id to cn_message_pkg.end_batch
        so that it can fill in the completion timestamp.
        Changed the 'no transactions to process' message from
        debug to translated.
  26-OCT-95 P Cook  Bug: 300974. Modified 'main' to give nice message if
                          cn_classification pkg body doesn't exist. Added output
                          of status so that calcsub form can give a succ/fail
        message depending on basic validation.
  21-NOV-95 P Cook  Added who column support
  19-FEB-96 P Cook  Bug:335401. Improved error handling and no longer
        re-raise server errors in calc submission form.
  08-MAR-96 P Cook  Bug:346965. Modified procedure populate_calcsub_batches
        to identify impact on parents when a subordinate is
        calculated (instead of identifying impacted
        subordinates when calcing a parent).
  12-MAR-96 P COOK  Bug: 348351. Modified calcsub to differentiate between
        impacted reps that need calc and thos that need revert.

  11-Feb-98 Achung        reference CLIENT_INFO need to use SUBSTRB

  19-Apr-99 H Chen        change parameter type x_num to varchar2 in
                          get_person_name_num
  27-Sep-00 M Blum        added check of pay group assignments before allowing
                          calculation
  17-Oct-00 M Blum        added calculation concurrent program
  13-Sep-07 achanda       fix bug # 6376880

  Purpose
   Sequentially or concurrently Process batches of transactions.

  Notes

  1. This program controls all commits during calculation. The calculation
     routine does not and should not commit.

  2. i. The physical batch cannot be smaller than a complete srp_period.
        i.e phys batch1 and physbatch2 cannot both refer to srp_period1.
     ii.The system's rollback segment must be large enough to deal with the
        maximum number of commission lines in an srp_period. See Issues.

  3. Currently the processor waits for a lock on srp periods.
     This could be improved with some kind of timeout and retry mechanism.

  Potential Issues
  1. Calling this program concurrently spawns many child processes ('runner')
     where each runner will process an individual physical batch.
     Each batch may reference more than one srp period and therefore more than
     one period.
     To maintain consistency between the srp_period and cn_period processing
     statii the child process commits after setting both the srp and cn period
     in each physical batch.
     Each child process may well be trying to set the cn_period status while
     another child process is doing the same. This contention will slow down
     concurrent execution but is preferable to locking the period up front
     which would prevent other children who referenced the same cn_period
     from executing.

  2. Commission lines are processed in groups of physical batches. After each
     physical batch is processed a commit is made.
     A physical batch represents the srp periods that can be processed before a
     commit is required. A fuller explanation is that the physical batch
     represents the srp periods whose total number of commission lines can be
     processed before a commit is required (to prevent a rollback segment error).
     Since a physical batch must represent at least on srp period, the number of
     commission lines that belong to each srp period must be handled by the
     rollback segment.
     When the system is setup the rollback segment must be large enough to
     deal with the max transactions expected in each srp period. Problem is that
     this is fairly difficult to estimate.
     Enhancements to this process could be to supplement or ditch the batch
     mechanism with a simple counting of commission lines processed. Obviously
     this means extensive modifications to all routines that are called
     (payee, calc etc) to remove any set based processing.

  3. When running concurrently the spawned runners will be executing in parallel
     thus using up the same rollback segment. So instead of requiring a rollback
     segment large enough to handle the largest phys batch you need one to
     handle the total number of comm lines in largest physical batches that may
     be processed in parallel. Parallelism is governed by the conc mgr setup.


  Baic Program Structure
  ======================

                  Main (Public)
          |
                Processor
                |
                    assign
          |
              ----------------
            online=Y       online=N
        |   |
            seq_dispatch  conc_dispatch (concurrent prog)
        |   |
        |         |
        |         |
        |     conc_submit
        |         |
        ----------------
                |
                runner (concurrent prog)


  */

  /* ----------------------------------------------------------------------------
   |                      Global Variables                                      |
   ----------------------------------------------------------------------------*/
  g_logical_process         VARCHAR2(30);
  g_logical_batch_id        NUMBER;
  g_org_id                  NUMBER;
  g_parent_proc_audit_id    NUMBER                     := NULL;
  g_unreverted     CONSTANT VARCHAR2(30)               := 'UNREVERTED';
  g_reverted       CONSTANT VARCHAR2(30)               := 'REVERTED';
  g_unclassified   CONSTANT VARCHAR2(30)               := 'UNCLASSIFIED';
  g_classified     CONSTANT VARCHAR2(30)               := 'CLASSIFIED';
  g_rolled_up      CONSTANT VARCHAR2(30)               := 'ROLLED_UP';
  g_populated      CONSTANT VARCHAR2(30)               := 'POPULATED';
  g_calculated     CONSTANT VARCHAR2(30)               := 'CALCULATED';
  g_revert         CONSTANT VARCHAR2(30)               := 'REVERT';
  g_collection     CONSTANT VARCHAR2(30)               := 'COLLECTION';
  g_load           CONSTANT VARCHAR2(30)               := 'LOAD';
  g_post           CONSTANT VARCHAR2(30)               := 'POST';
  g_classification CONSTANT VARCHAR2(30)               := 'CLASSIFICATION';
  g_calculation    CONSTANT VARCHAR2(30)               := 'CALCULATION';
  g_rollup         CONSTANT VARCHAR2(30)               := 'ROLLUP';
  g_population     CONSTANT VARCHAR2(30)               := 'POPULATION';
  g_creation_date           DATE                       := SYSDATE;
  g_created_by              NUMBER                     := fnd_global.user_id;
  g_calc_type               VARCHAR2(30);
  /* ----------------------------------------------------------------------------
   |                      Pragmas                                               |
   ----------------------------------------------------------------------------*/
  ABORT                     EXCEPTION;
  program_unit_missing      EXCEPTION;
  no_comm_lines             EXCEPTION;
  conc_fail                 EXCEPTION;
  no_one_with_complete_plan EXCEPTION;
  api_call_failed           EXCEPTION;
  PRAGMA EXCEPTION_INIT(program_unit_missing, -6508);

  /* ----------------------------------------------------------------------------
   |                      Global Cursor                                         |
   ----------------------------------------------------------------------------*/-- Get individual physical batch id's for the entire logical batch
   -- no point joining to periods for the status because it may have
   -- changed by the time we come to process the records
  CURSOR physical_batches IS
    SELECT   a.physical_batch_id
        FROM cn_process_batches_all a
           , (SELECT MAX(physical_batch_id) physical_batch_id
                   , SUM(sales_lines_total) + 1 rec_total
                FROM cn_process_batches_all
               WHERE logical_batch_id = g_logical_batch_id) b
       WHERE a.logical_batch_id = g_logical_batch_id AND a.status_code = 'IN_USE'
    GROUP BY a.physical_batch_id
    ORDER BY SUM(DECODE(a.physical_batch_id, b.physical_batch_id, b.rec_total, a.sales_lines_total)) DESC;

  CURSOR physical_batches2 IS
    SELECT   a.physical_batch_id
        FROM cn_process_batches_all a
           , (SELECT MAX(physical_batch_id) physical_batch_id
                   , SUM(commission_headers_count) + 1 rec_total
                FROM cn_process_batches_all
               WHERE logical_batch_id = g_logical_batch_id) b
       WHERE a.logical_batch_id = g_logical_batch_id AND a.status_code = 'IN_USE'
    GROUP BY a.physical_batch_id
    ORDER BY SUM(
               DECODE(
                 a.physical_batch_id
               , b.physical_batch_id, b.rec_total
               , commission_headers_count
               )
             ) DESC;

  physical_rec              physical_batches%ROWTYPE;

  /* ---------------------------------------------------------------------------
   |                      Forward Declaration for Bonus Calc                   |
   ----------------------------------------------------------------------------*/
  PROCEDURE populate_bonus_process_batch(p_calc_sub_batch_id NUMBER);

  FUNCTION check_active_plan_assign(
    p_salesrep_id       NUMBER
  , p_start_date        DATE
  , p_end_date          DATE
  , p_interval_type_id  NUMBER
  , p_calc_sub_batch_id NUMBER
  , p_org_id            NUMBER
  )
    RETURN BOOLEAN;

  /* ----------------------------------------------------------------------------
   |                      Private Routines                                      |
   ----------------------------------------------------------------------------*/-- Procedure Name
   --   Flood_rev_classes
   -- Purpose
   --   Flood the rev class hierarchy with any missing 1:1 nodes for those
   --   salesreps in the logical batch of transactions
  PROCEDURE flood_rev_classes IS
    CURSOR periods IS
      SELECT start_date
           , end_date
        FROM cn_calc_submission_batches_all
       WHERE logical_batch_id = g_logical_batch_id;

    x_dim_hierarchy   NUMBER;

    CURSOR l_dim_hierarchy_csr(l_start_date DATE, l_end_date DATE) IS
      SELECT dim_hierarchy_id
        FROM cn_dim_hierarchies_all
       WHERE header_dim_hierarchy_id = (SELECT rev_class_hierarchy_id
                                          FROM cn_repositories_all
                                         WHERE org_id = g_org_id)
         AND org_id = g_org_id
         AND (
                 (start_date < l_start_date AND(end_date IS NULL OR l_start_date <= end_date))
              OR (start_date BETWEEN l_start_date AND l_end_date)
             );

    l_user_id         NUMBER(15) := fnd_global.user_id;
    l_resp_id         NUMBER(15) := fnd_global.resp_id;
    l_login_id        NUMBER(15) := fnd_global.login_id;
    l_conc_prog_id    NUMBER(15) := fnd_global.conc_program_id;
    l_conc_request_id NUMBER(15) := fnd_global.conc_request_id;
    l_prog_appl_id    NUMBER(15) := fnd_global.prog_appl_id;
  BEGIN
    FOR per IN periods LOOP
      FOR dim IN l_dim_hierarchy_csr(per.start_date, per.end_date) LOOP
        x_dim_hierarchy  := dim.dim_hierarchy_id;

        DECLARE
          CURSOR classes IS
            SELECT revenue_class_id
                 , NAME
              FROM cn_revenue_classes_all rc
             WHERE org_id = g_org_id
               AND NOT EXISTS(
                     SELECT 1
                       FROM cn_dim_explosion_all
                      WHERE dim_hierarchy_id = x_dim_hierarchy
                        AND value_external_id = rc.revenue_class_id
                        AND ancestor_external_id = rc.revenue_class_id);
        BEGIN
          FOR CLASS IN classes LOOP
            UPDATE cn_hierarchy_nodes_all
               SET external_id = CLASS.revenue_class_id
                 , last_update_date = SYSDATE
                 , last_update_login = l_login_id
                 , last_updated_by = l_user_id
                 , request_id = l_conc_request_id
                 , program_application_id = l_prog_appl_id
                 , program_id = l_conc_prog_id
                 , program_update_date = SYSDATE
             WHERE external_id IS NULL
               AND NAME = CLASS.NAME
               AND dim_hierarchy_id = x_dim_hierarchy
               AND org_id = g_org_id;

            INSERT INTO cn_hierarchy_nodes_all
                        (
                         dim_hierarchy_id
                       , value_id
                       , external_id
                       , NAME
                       , ref_count
                       , hierarchy_level
                       , creation_date
                       , created_by
                       , last_update_date
                       , last_updated_by
                       , last_update_login
                       , request_id
                       , program_application_id
                       , program_id
                       , program_update_date
                       , org_id
                        )
              (SELECT x_dim_hierarchy
                    , cn_hierarchy_nodes_s.NEXTVAL
                    , CLASS.revenue_class_id
                    , CLASS.NAME
                    , 0
                    , 1
                    , SYSDATE
                    , l_user_id
                    , SYSDATE
                    , l_user_id
                    , l_login_id
                    , l_conc_request_id
                    , l_prog_appl_id
                    , l_conc_prog_id
                    , SYSDATE
                    , g_org_id
                 FROM SYS.DUAL
                WHERE NOT EXISTS(
                        SELECT 1
                          FROM cn_hierarchy_nodes_all
                         WHERE dim_hierarchy_id = x_dim_hierarchy
                           AND external_id = CLASS.revenue_class_id
                           AND org_id = g_org_id));

            UPDATE cn_dim_explosion_all
               SET ancestor_external_id = CLASS.revenue_class_id
             WHERE ancestor_id IN(
                     SELECT value_id
                       FROM cn_hierarchy_nodes_all
                      WHERE dim_hierarchy_id = x_dim_hierarchy
                        AND external_id = CLASS.revenue_class_id
                        AND org_id = g_org_id)
               AND dim_hierarchy_id = x_dim_hierarchy
               AND ancestor_external_id IS NULL
               AND org_id = g_org_id;

            UPDATE cn_dim_explosion_all
               SET value_external_id = CLASS.revenue_class_id
             WHERE value_id IN(
                     SELECT value_id
                       FROM cn_hierarchy_nodes_all
                      WHERE dim_hierarchy_id = x_dim_hierarchy
                        AND external_id = CLASS.revenue_class_id
                        AND org_id = g_org_id)
               AND dim_hierarchy_id = x_dim_hierarchy
               AND value_external_id IS NULL
               AND org_id = g_org_id;
          END LOOP;
        END;
      END LOOP;   -- end of dim_hierarchy_id
    END LOOP;   -- end of period
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  -- prevents no data found when a process batch period does not exist in
  -- the rev class hierarchy
  END flood_rev_classes;

  -- Procedure Name
  --   Process_status
  -- Purpose
  --   For a given physical process get the status of the periods that can be
  --   processed and the status that these periods will be set to when the
  --   process completes.
  PROCEDURE process_status(
    x_physical_process IN            VARCHAR2
  , x_curr_status      OUT NOCOPY    VARCHAR2
  , x_new_status       OUT NOCOPY    VARCHAR2
  ) IS
    newst  VARCHAR2(30);
    currst VARCHAR2(30);
  BEGIN
    IF x_physical_process = g_collection THEN
      -- If we've collected new records into the period then the period
      -- must become unclassified regardless of its current status
      currst  := NULL;
      newst   := g_unclassified;
    ELSIF x_physical_process = g_revert THEN
      currst  := g_unreverted;
      newst   := g_reverted;
    ELSIF x_physical_process = g_classification THEN
      currst  := g_reverted;
      newst   := g_classified;
    ELSIF x_physical_process = g_rollup THEN
      currst  := g_classified;
      newst   := g_rolled_up;
    ELSIF x_physical_process = g_population THEN
      currst  := g_rolled_up;
      newst   := g_populated;
    ELSIF x_physical_process = g_calculation THEN
      currst  := g_populated;
      newst   := g_calculated;
    ELSIF x_physical_process = g_load THEN
      currst  := g_load;
      newst   := g_load;
    ELSIF x_physical_process = g_post THEN
      currst  := g_post;
      newst   := g_post;
    ELSE
      cn_message_pkg.DEBUG('Invalid process code: ' || x_physical_process);
      fnd_file.put_line(fnd_file.LOG, 'Invalid process code: ' || x_physical_process);
      RAISE ABORT;
    END IF;

    x_curr_status  := currst;
    x_new_status   := newst;
  END process_status;

  -- Procedure Name
  --   next_process
  -- Purpose
  --   For given logical and physical processes get the name of the
  --   subsequent process that must be run.
  --
  PROCEDURE next_process(x_physical_process IN OUT NOCOPY VARCHAR2) IS
    newpr VARCHAR2(30);
  BEGIN
    IF g_calc_type = 'BONUS' THEN
      IF x_physical_process IS NULL THEN
        x_physical_process  := g_revert;
      ELSIF x_physical_process = g_revert THEN
        x_physical_process  := g_calculation;   --g_logical_process;
      ELSIF x_physical_process = g_calculation THEN
        x_physical_process  := NULL;
      ELSE
        cn_message_pkg.DEBUG(
             'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        fnd_file.put_line(
          fnd_file.LOG
        ,    'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        RAISE ABORT;
      END IF;

      RETURN;
    END IF;

    IF g_logical_process = g_collection THEN
      IF x_physical_process IS NULL THEN
        newpr  := g_collection;
      ELSIF x_physical_process = g_collection THEN
        newpr  := NULL;
      ELSE
        newpr  := g_collection;
      END IF;
    ELSIF g_logical_process = g_classification THEN
      IF x_physical_process IS NULL THEN
        newpr  := g_classification;
      ELSIF x_physical_process = g_classification THEN
        newpr  := NULL;
      ELSE
        cn_message_pkg.DEBUG(
             'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        fnd_file.put_line(
          fnd_file.LOG
        ,    'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        RAISE ABORT;
      END IF;
    ELSIF g_logical_process = g_rollup THEN
      IF x_physical_process IS NULL THEN
        newpr  := g_classification;
      ELSIF x_physical_process = g_classification THEN
        newpr  := g_rollup;
      ELSIF x_physical_process = g_rollup THEN
        newpr  := NULL;
      ELSE
        cn_message_pkg.DEBUG(
             'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        fnd_file.put_line(
          fnd_file.LOG
        ,    'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        RAISE ABORT;
      END IF;
    ELSIF g_logical_process = g_population THEN
      IF x_physical_process IS NULL THEN
        newpr  := g_classification;
      ELSIF x_physical_process = g_classification THEN
        newpr  := g_rollup;
      ELSIF x_physical_process = g_rollup THEN
        newpr  := g_population;
      ELSIF x_physical_process = g_population THEN
        newpr  := NULL;
      ELSE
        cn_message_pkg.DEBUG(
             'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        fnd_file.put_line(
          fnd_file.LOG
        ,    'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        RAISE ABORT;
      END IF;
    ELSIF g_logical_process = g_calculation THEN
      IF x_physical_process IS NULL THEN
        newpr  := g_revert;
      ELSIF x_physical_process = g_revert THEN
        newpr  := g_classification;
      ELSIF x_physical_process = g_classification THEN
        newpr  := g_rollup;
      ELSIF x_physical_process = g_rollup THEN
        newpr  := g_population;
      ELSIF x_physical_process = g_population THEN
        newpr  := g_calculation;
      ELSIF x_physical_process = g_calculation THEN
        newpr  := NULL;
      ELSE
        cn_message_pkg.DEBUG(
             'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        fnd_file.put_line(
          fnd_file.LOG
        ,    'Invalid process code: '
          || x_physical_process
          || ' (logical process: '
          || g_logical_process
          || ')'
        );
        RAISE ABORT;
      END IF;
    END IF;

    x_physical_process  := newpr;
  END next_process;

  -- Procedure Name
  --   Populate_calcsub_batches
  -- Purpose
  --   insert entry into cn_process_batches for this srp/period and entries of
  --   all srps below this srp depending on the value of x_entire_hierarchy
  -- Notes
  --   12-Jul-1998, Richard Jin  Created
  --   05-Jun-1999, Richard Jin  Modified 11.5
  PROCEDURE populate_calcsub_batches(
    p_salesrep_id      NUMBER
  , p_start_date       DATE
  , p_end_date         DATE
  , p_start_period_id  NUMBER
  , p_end_period_id    NUMBER
  , p_logical_batch_id NUMBER
  , p_entire_hierarchy VARCHAR2
  ) IS
    -- The cursor Impacted_Reps looks up the rollup hierarchy of the
    -- salesrep being calculated
    -- will call Ram's API to get impacted salesreps
    l_process_batch_id NUMBER;
    l_user_id          NUMBER(15)                 := fnd_global.user_id;
    l_resp_id          NUMBER(15)                 := fnd_global.resp_id;
    l_login_id         NUMBER(15)                 := fnd_global.login_id;
    l_conc_prog_id     NUMBER(15)                 := fnd_global.conc_program_id;
    l_conc_request_id  NUMBER(15)                 := fnd_global.conc_request_id;
    l_prog_appl_id     NUMBER(15)                 := fnd_global.prog_appl_id;
    l_srp_rec          cn_rollup_pvt.srp_rec_type;
    l_descendant_tbl   cn_rollup_pvt.srp_tbl_type;
    l_counter          NUMBER;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_return_status    VARCHAR2(30);
  BEGIN
    g_logical_batch_id  := p_logical_batch_id;

    SELECT org_id
      INTO g_org_id
      FROM cn_calc_submission_batches_all
     WHERE logical_batch_id = p_logical_batch_id;

    IF p_entire_hierarchy = 'Y' THEN
      l_srp_rec.salesrep_id  := p_salesrep_id;
      l_srp_rec.start_date   := p_start_date;
      l_srp_rec.end_date     := p_end_date;
      cn_rollup_pvt.get_descendant_salesrep(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_srp                        => l_srp_rec
      , x_srp                        => l_descendant_tbl
      , p_org_id                     => g_org_id
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        cn_message_pkg.DEBUG('Exception occurs in getting the descendants:');

        FOR l_counter IN 1 .. l_msg_count LOOP
          cn_message_pkg.DEBUG(fnd_msg_pub.get(p_msg_index => l_counter
            , p_encoded                    => fnd_api.g_false));
        END LOOP;

        RAISE api_call_failed;
      END IF;

      IF l_descendant_tbl.COUNT > 0 THEN
        FOR l_counter IN l_descendant_tbl.FIRST .. l_descendant_tbl.LAST LOOP
          BEGIN
            INSERT INTO cn_process_batches_all
                        (
                         process_batch_id
                       , logical_batch_id
                       , srp_period_id
                       , period_id
                       , end_period_id
                       , start_date
                       , end_date
                       , salesrep_id
                       , status_code
                       , process_batch_type
                       , creation_date
                       , created_by
                       , last_update_date
                       , last_updated_by
                       , last_update_login
                       , request_id
                       , program_application_id
                       , program_id
                       , program_update_date
                       , org_id
                        )
              SELECT cn_process_batches_s1.NEXTVAL
                   , g_logical_batch_id
                   , 1   /* use a dummy value since this is a not null column */
                   , p_start_period_id
                   , p_end_period_id
                   , p_start_date
                   , p_end_date
                   , l_descendant_tbl(l_counter).salesrep_id
                   , 'IN_USE'
                   , 'TO_REVERT_BASE_REP'
                   , SYSDATE
                   , l_user_id
                   , SYSDATE
                   , l_user_id
                   , l_login_id
                   , l_conc_request_id
                   , l_prog_appl_id
                   , l_conc_prog_id
                   , SYSDATE
                   , g_org_id
                FROM DUAL
               WHERE NOT EXISTS(
                       SELECT 1
                         FROM cn_process_batches_all
                        WHERE logical_batch_id = g_logical_batch_id
                          AND salesrep_id = l_descendant_tbl(l_counter).salesrep_id
                          AND period_id = p_start_period_id
                          AND end_period_id = p_end_period_id
                          AND start_date = p_start_date
                          AND end_date = p_end_date);
          EXCEPTION
            WHEN OTHERS THEN
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING(
                  fnd_log.level_unexpected
                , 'cn.plsql.cn_proc_batches_pkg.populate_calcsub_batches.loop'
                , SQLERRM
                );
              END IF;

              cn_message_pkg.DEBUG
                               ('Exception occurs in including the descendants in the calc process:');
              cn_message_pkg.DEBUG(SQLERRM);
              RAISE;
          END;
        END LOOP;
      END IF;   -- checking l_descendant_tbl.count > 0
    END IF;

    -- case1: not entire hierarchy
    -- only insert the base reps
    -- case2: entire hierarchy. since get_descendants does not return the base salesrep
    --        in the list, need to do the insert here.
    INSERT INTO cn_process_batches_all
                (
                 process_batch_id
               , logical_batch_id
               , srp_period_id
               , period_id
               , end_period_id
               , start_date
               , end_date
               , salesrep_id
               , status_code
               , process_batch_type
               , creation_date
               , created_by
               , last_update_date
               , last_updated_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , org_id
                )
      SELECT cn_process_batches_s1.NEXTVAL
           , g_logical_batch_id
           , 1   /* use a dummy value since this is a not null column */
           , p_start_period_id
           , p_end_period_id
           , p_start_date
           , p_end_date
           , p_salesrep_id
           , 'IN_USE'
           , 'TO_REVERT_BASE_REP'
           , SYSDATE
           , l_user_id
           , SYSDATE
           , l_user_id
           , l_login_id
           , l_conc_request_id
           , l_prog_appl_id
           , l_conc_prog_id
           , SYSDATE
           , g_org_id
        FROM DUAL
       WHERE NOT EXISTS(
               SELECT 1
                 FROM cn_process_batches_all
                WHERE logical_batch_id = g_logical_batch_id
                  AND salesrep_id = p_salesrep_id
                  AND period_id = p_start_period_id
                  AND end_period_id = p_end_period_id
                  AND start_date = p_start_date
                  AND end_date = p_end_date);

    COMMIT;
  EXCEPTION
    WHEN api_call_failed THEN
      IF (l_msg_count > 0) THEN
        FOR l_counter IN 1 .. l_msg_count LOOP
          fnd_file.put_line(fnd_file.LOG
          , fnd_msg_pub.get(p_msg_index => l_counter, p_encoded => fnd_api.g_false));
        END LOOP;
      END IF;

      cn_message_pkg.FLUSH;
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG, 'In cn_proc_batches_pkg.populate_calcsub_batch: ' || SQLERRM);
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.populate_calcsub_batch:');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);

      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.populate_calcsub_batches.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END populate_calcsub_batches;

  PROCEDURE get_calc_sub_periods(
    p_start_date                     DATE
  , p_end_date                       DATE
  , x_start_date          OUT NOCOPY DATE
  , x_end_date            OUT NOCOPY DATE
  , x_calc_from_period_id OUT NOCOPY NUMBER
  , x_calc_to_period_id   OUT NOCOPY NUMBER
  , p_org_id                         NUMBER
  ) IS
    CURSOR l_period_csr(l_date DATE) IS
      SELECT period.period_id
           , period.start_date
           , period.end_date
        FROM cn_period_statuses_all period
       WHERE l_date BETWEEN period.start_date AND period.end_date AND org_id = p_org_id;

    dummy DATE;
  BEGIN
    OPEN l_period_csr(p_start_date);
    FETCH l_period_csr INTO x_calc_from_period_id, x_start_date, dummy;
    CLOSE l_period_csr;

    OPEN l_period_csr(p_end_date);
    FETCH l_period_csr INTO x_calc_to_period_id, dummy, x_end_date;

    CLOSE l_period_csr;
  END get_calc_sub_periods;

  PROCEDURE initialize_logical_batch(p_calc_sub_batch_id NUMBER) IS
  BEGIN
    SELECT cn_process_batches_s2.NEXTVAL
      INTO g_logical_batch_id
      FROM DUAL;

    UPDATE    cn_calc_submission_batches_all
          SET logical_batch_id = g_logical_batch_id
        WHERE calc_sub_batch_id = p_calc_sub_batch_id
    RETURNING org_id
         INTO g_org_id;

    COMMIT;
  END initialize_logical_batch;

  FUNCTION find_srp_incomplete_plan(p_calc_sub_batch_id NUMBER)
    RETURN BOOLEAN IS
    l_calc_from_period_id NUMBER;
    l_calc_to_period_id   NUMBER;
    l_salesrep_option     VARCHAR2(20);
    l_org_id              NUMBER;
    l_start_date_orig     DATE;
    l_end_date_orig       DATE;
    l_start_date_adj      DATE;
    l_end_date_adj        DATE;
    l_creation_date       DATE                                := SYSDATE;
    l_created_by          NUMBER                              := fnd_global.user_id;
    l_affected_all_reps   VARCHAR2(1)                         := 'N';
    l_invalid_plans_cnt   PLS_INTEGER                         := 0;
    l_validated_plans_cnt PLS_INTEGER                         := 0;
    l_comp_plan_rec       cn_comp_plan_pvt.comp_plan_rec_type;
    l_status_code         VARCHAR2(30);
    l_return_status       VARCHAR2(30);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    CURSOR l_sub_batch_csr IS
      SELECT start_date
           , end_date
           , salesrep_option
           , org_id
        FROM cn_calc_submission_batches_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;

    CURSOR l_affected_all_csr IS
      SELECT 'Y'
        FROM cn_notify_log_all
       WHERE org_id = l_org_id
         AND salesrep_id = -1000
         AND period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
         AND status = 'INCOMPLETE'
         AND revert_state <> 'NCALC';

    CURSOR l_invalid_plans IS
      SELECT comp_plan_id
        FROM cn_calc_sub_validations_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;

    CURSOR plan_status(p_comp_plan_id NUMBER) IS
      SELECT status_code
        FROM cn_comp_plans_all
       WHERE comp_plan_id = p_comp_plan_id;
  BEGIN
    OPEN l_sub_batch_csr;
    FETCH l_sub_batch_csr INTO l_start_date_orig, l_end_date_orig, l_salesrep_option, l_org_id;
    CLOSE l_sub_batch_csr;

    get_calc_sub_periods(
      l_start_date_orig
    , l_end_date_orig
    , l_start_date_adj
    , l_end_date_adj
    , l_calc_from_period_id
    , l_calc_to_period_id
    , l_org_id
    );

    DELETE FROM cn_calc_sub_validations_all
          WHERE calc_sub_batch_id = p_calc_sub_batch_id;

    -- Get validation result if SALESREP_OPTION = 'ALL_REPS'
    IF (l_salesrep_option = 'ALL_REPS') THEN
      INSERT INTO cn_calc_sub_validations_all
                  (
                   org_id
                 , calc_sub_batch_id
                 , comp_plan_id
                 , affected_reps
                 , created_by
                 , creation_date
                  )
        SELECT l_org_id
             , p_calc_sub_batch_id
             , v.comp_plan_id
             , v.num_of_affected_reps
             , l_created_by
             , l_creation_date
          FROM (SELECT   PLAN.comp_plan_id
                       , COUNT(DISTINCT spa.salesrep_id) num_of_affected_reps
                    FROM cn_srp_plan_assigns_all spa
                       , cn_srp_role_dtls_all srd
                       , cn_comp_plans_all PLAN
                   WHERE PLAN.org_id = l_org_id
                     AND PLAN.status_code = 'INCOMPLETE'
                     AND spa.comp_plan_id = PLAN.comp_plan_id
                     AND GREATEST(spa.start_date, l_start_date_adj) <=
                                            LEAST(NVL(spa.end_date, l_end_date_adj), l_end_date_adj)
                     AND srd.srp_role_id(+) = spa.srp_role_id
                     AND (
                             srd.plan_activate_status = 'PUSHED'
                          OR srd.plan_activate_status IS NULL
                          OR srd.org_code = 'EMPTY'
                         )
                GROUP BY PLAN.comp_plan_id) v;

      IF (SQL%FOUND) THEN
        NULL;   --return true;
      END IF;
    -- Get validation result if SALESREP_OPTION = 'USER_SPECIFY'
    ELSIF(l_salesrep_option = 'USER_SPECIFY') THEN
      INSERT INTO cn_calc_sub_validations_all
                  (
                   org_id
                 , calc_sub_batch_id
                 , comp_plan_id
                 , affected_reps
                 , created_by
                 , creation_date
                  )
        SELECT l_org_id
             , p_calc_sub_batch_id
             , v.comp_plan_id
             , v.num_of_affected_reps
             , l_created_by
             , l_creation_date
          FROM (SELECT   PLAN.comp_plan_id
                       , COUNT(DISTINCT spa.salesrep_id) num_of_affected_reps
                    FROM cn_calc_submission_entries cse
                       , cn_srp_plan_assigns_all spa
                       , cn_srp_role_dtls_all srd
                       , cn_comp_plans_all PLAN
                   WHERE cse.calc_sub_batch_id = p_calc_sub_batch_id
                     AND spa.salesrep_id = cse.salesrep_id
                     AND PLAN.org_id = l_org_id
                     AND PLAN.status_code = 'INCOMPLETE'
                     AND PLAN.comp_plan_id = spa.comp_plan_id
                     AND GREATEST(spa.start_date, l_start_date_adj) <=
                                            LEAST(NVL(spa.end_date, l_end_date_adj), l_end_date_adj)
                     AND srd.srp_role_id(+) = spa.srp_role_id
                     AND (
                             srd.plan_activate_status = 'PUSHED'
                          OR srd.plan_activate_status IS NULL
                          OR srd.org_code = 'EMPTY'
                         )
                GROUP BY PLAN.comp_plan_id) v;

      IF (SQL%FOUND) THEN
        NULL;   --return true;
      END IF;
    -- Get validation result if SALESREP_OPTION = 'REPS_IN_NOTIFY_LOG'
    ELSIF(l_salesrep_option = 'REPS_IN_NOTIFY_LOG') THEN
      OPEN l_affected_all_csr;
      FETCH l_affected_all_csr INTO l_affected_all_reps;
      CLOSE l_affected_all_csr;

      IF (l_affected_all_reps = 'Y') THEN
        INSERT INTO cn_calc_sub_validations_all
                    (
                     org_id
                   , calc_sub_batch_id
                   , comp_plan_id
                   , affected_reps
                   , created_by
                   , creation_date
                    )
          SELECT l_org_id
               , p_calc_sub_batch_id
               , v.comp_plan_id
               , v.num_of_affected_reps
               , l_created_by
               , l_creation_date
            FROM (SELECT   PLAN.comp_plan_id
                         , COUNT(DISTINCT spa.salesrep_id) num_of_affected_reps
                      FROM cn_srp_plan_assigns_all spa
                         , cn_srp_role_dtls_all srd
                         , cn_comp_plans_all PLAN
                     WHERE PLAN.org_id = l_org_id
                       AND PLAN.status_code = 'INCOMPLETE'
                       AND spa.comp_plan_id = PLAN.comp_plan_id
                       AND GREATEST(spa.start_date, l_start_date_orig) <=
                                          LEAST(NVL(spa.end_date, l_end_date_orig), l_end_date_orig)
                       AND srd.srp_role_id(+) = spa.srp_role_id
                       AND (
                               srd.plan_activate_status = 'PUSHED'
                            OR srd.plan_activate_status IS NULL
                            OR srd.org_code = 'EMPTY'
                           )
                  GROUP BY PLAN.comp_plan_id) v;

        IF (SQL%FOUND) THEN
          NULL;   --return true;
        END IF;
      ELSE
        INSERT INTO cn_calc_sub_validations_all
                    (
                     org_id
                   , calc_sub_batch_id
                   , comp_plan_id
                   , affected_reps
                   , created_by
                   , creation_date
                    )
          SELECT l_org_id
               , p_calc_sub_batch_id
               , v.comp_plan_id
               , v.num_of_affected_reps
               , l_created_by
               , l_creation_date
            FROM (SELECT   PLAN.comp_plan_id
                         , COUNT(DISTINCT spa.salesrep_id) num_of_affected_reps
                      FROM cn_srp_plan_assigns_all spa
                         , cn_srp_role_dtls_all srd
                         , cn_comp_plans_all PLAN
                     WHERE PLAN.org_id = l_org_id
                       AND PLAN.status_code = 'INCOMPLETE'
                       AND spa.comp_plan_id = PLAN.comp_plan_id
                       AND GREATEST(spa.start_date, l_start_date_orig) <=
                                          LEAST(NVL(spa.end_date, l_end_date_orig), l_end_date_orig)
                       AND srd.srp_role_id(+) = spa.srp_role_id
                       AND (
                               srd.plan_activate_status = 'PUSHED'
                            OR srd.plan_activate_status IS NULL
                            OR srd.org_code = 'EMPTY'
                           )
                       AND EXISTS(
                             SELECT 1
                               FROM cn_notify_log_all
                              WHERE salesrep_id = spa.salesrep_id
                                AND org_id = l_org_id
                                AND period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                                AND status = 'INCOMPLETE'
                                AND revert_state <> 'NCALC')
                  GROUP BY PLAN.comp_plan_id) v;

        IF (SQL%FOUND) THEN
          NULL;   --return true;
        END IF;
      END IF;
    END IF;

    FOR invalid_plan IN l_invalid_plans LOOP
      l_invalid_plans_cnt           := l_invalid_plans_cnt + 1;

      IF (l_invalid_plans_cnt = 51) THEN
        EXIT;
      END IF;

      l_comp_plan_rec.comp_plan_id  := invalid_plan.comp_plan_id;
      cn_comp_plan_pvt.validate_comp_plan(
        p_api_version                => 1.0
      , p_comp_plan                  => l_comp_plan_rec
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );

      OPEN plan_status(invalid_plan.comp_plan_id);
      FETCH plan_status INTO l_status_code;
      CLOSE plan_status;

      IF (l_status_code = 'COMPLETE') THEN
        DELETE FROM cn_calc_sub_validations_all
              WHERE calc_sub_batch_id = p_calc_sub_batch_id
                AND comp_plan_id = invalid_plan.comp_plan_id;

        l_validated_plans_cnt  := l_validated_plans_cnt + 1;
      END IF;
    END LOOP;

    IF (l_invalid_plans_cnt = l_validated_plans_cnt) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.find_srp_incomplete_plan.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END find_srp_incomplete_plan;

  -- Procedure Name
  --  Populate_process_batches
  -- Purpose
  --  populate the cn_process_batches for an entry in cn_calc_submission_batches
  -- Notes
  --  12-Jul-1998, Richard Jin Created
  --  19-Sep-2002, Arvind Krishnan BUG:2509788 - Improved the performance of query in l_all_reps_csr
  PROCEDURE populate_process_batch(p_calc_sub_batch_id NUMBER) IS
    l_calc_from_period_id NUMBER;
    l_calc_to_period_id   NUMBER;
    l_intelligent_flag    VARCHAR2(1);
    l_hierarchy_flag      VARCHAR2(1);
    l_salesrep_option     VARCHAR2(20);
    l_org_id              NUMBER;
    l_counter             NUMBER;
    l_start_date_orig     DATE;
    l_end_date_orig       DATE;
    l_start_date_adj      DATE;
    l_end_date_adj        DATE;

    CURSOR l_sub_batch_csr IS
      SELECT start_date
           , end_date
           , intelligent_flag
           , NVL(hierarchy_flag, 'N')
           , salesrep_option
           , org_id
        FROM cn_calc_submission_batches_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;
  BEGIN
    l_counter  := 0;

    OPEN l_sub_batch_csr;
    FETCH l_sub_batch_csr
     INTO l_start_date_orig
        , l_end_date_orig
        , l_intelligent_flag
        , l_hierarchy_flag
        , l_salesrep_option
        , l_org_id;
    CLOSE l_sub_batch_csr;

    get_calc_sub_periods(
      l_start_date_orig
    , l_end_date_orig
    , l_start_date_adj
    , l_end_date_adj
    , l_calc_from_period_id
    , l_calc_to_period_id
    , l_org_id
    );

    IF l_salesrep_option = 'ALL_REPS' THEN
      DECLARE
        CURSOR l_all_reps_csr(l_start_date DATE, l_end_date DATE) IS
          SELECT DISTINCT intel.salesrep_id
                     FROM cn_srp_intel_periods_all intel
                    WHERE org_id = l_org_id
                      AND intel.period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                      AND (
                              EXISTS(
                                SELECT 1
                                  FROM cn_srp_plan_assigns_all spa, cn_comp_plans_all PLAN
                                 WHERE spa.salesrep_id = intel.salesrep_id
                                   AND spa.org_id = intel.org_id
                                   AND (
                                           (
                                                spa.start_date < l_start_date
                                            AND (
                                                 spa.end_date IS NULL
                                                 OR l_start_date <= spa.end_date
                                                )
                                           )
                                        OR (spa.start_date BETWEEN l_start_date AND l_end_date)
                                       )
                                   AND spa.comp_plan_id = PLAN.comp_plan_id
                                   AND PLAN.status_code = 'COMPLETE')
                           OR EXISTS(
                                SELECT 1
                                  FROM cn_commission_lines_all
                                 WHERE credited_salesrep_id = intel.salesrep_id
                                   AND processed_period_id BETWEEN l_calc_from_period_id
                                                               AND l_calc_to_period_id
                                   AND org_id = intel.org_id
                                   AND processed_date BETWEEN l_start_date AND l_end_date)
                           OR EXISTS(
                                SELECT 1
                                  FROM cn_commission_headers_all
                                 WHERE direct_salesrep_id = intel.salesrep_id
                                   AND org_id = intel.org_id
                                   AND processed_date BETWEEN l_start_date AND l_end_date)
                          );
      -- salesrep has no plan assign within the date range but has trxs
      -- since the rollup has been done in loader, we don't have to pick
      -- those salesrep any more.
      BEGIN
        IF l_intelligent_flag = 'Y' THEN
          FOR rep IN l_all_reps_csr(l_start_date_adj, l_end_date_adj) LOOP
            l_counter  := l_counter + 1;
            populate_calcsub_batches(
              rep.salesrep_id
            , l_start_date_adj
            , l_end_date_adj
            , l_calc_from_period_id
            , l_calc_to_period_id
            , g_logical_batch_id
            , l_hierarchy_flag
            );
          END LOOP;
        ELSE
          FOR rep IN l_all_reps_csr(l_start_date_orig, l_end_date_adj) LOOP
            l_counter  := l_counter + 1;
            populate_calcsub_batches(
              rep.salesrep_id
            , l_start_date_orig
            , l_end_date_adj
            , l_calc_from_period_id
            , l_calc_to_period_id
            , g_logical_batch_id
            , l_hierarchy_flag
            );
          END LOOP;
        END IF;

        IF l_counter = 0 THEN   /* no one to be calculated */
          fnd_message.set_name('CN', 'CNSBCS_NO_ONE_TO_CALCULATE');

          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
            fnd_log.MESSAGE(
              fnd_log.level_exception
            , 'cn.plsql.cn_proc_batches_pkg.populate_process_batches.all_reps'
            , FALSE
            );
          END IF;

          RAISE no_one_with_complete_plan;
        END IF;
      END;
    ELSIF l_salesrep_option = 'USER_SPECIFY' THEN
      DECLARE
        CURSOR l_reps_csr(l_start_date DATE, l_end_date DATE) IS
          SELECT cse.salesrep_id
               , NVL(cse.hierarchy_flag, 'N') hierarchy_flag
            FROM cn_calc_submission_entries_all cse
           WHERE cse.calc_sub_batch_id = p_calc_sub_batch_id
             AND (
                     (
                      EXISTS(
                        SELECT 1
                          FROM cn_notify_log_all LOG
                         WHERE LOG.period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                           AND LOG.status = 'INCOMPLETE'
                           AND LOG.org_id = cse.org_id
                           AND (LOG.salesrep_id = -1000 OR LOG.salesrep_id = cse.salesrep_id))
                     )
                  OR (
                      EXISTS(
                        SELECT 1
                          FROM cn_commission_lines_all
                         WHERE credited_salesrep_id = cse.salesrep_id
                           AND processed_period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                           AND status <> 'OBSOLETE'
                           AND org_id = cse.org_id)
                     )
                  OR (
                      EXISTS(
                        SELECT 1
                          FROM cn_commission_headers_all
                         WHERE direct_salesrep_id = cse.salesrep_id
                           AND processed_period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                           AND status <> 'OBSOLETE'
                           AND org_id = cse.org_id)
                     )
                  OR (
                      EXISTS   -- salesrep has an active complete plan within the date range
                            (
                        SELECT 1
                          FROM cn_srp_plan_assigns_all spa, cn_comp_plans_all PLAN
                         WHERE spa.salesrep_id = cse.salesrep_id
                           AND spa.org_id = cse.org_id
                           AND (
                                   (
                                        spa.start_date < l_start_date
                                    AND (spa.end_date IS NULL OR l_start_date <= spa.end_date)
                                   )
                                OR (spa.start_date BETWEEN l_start_date AND l_end_date)
                               )
                           AND spa.comp_plan_id = PLAN.comp_plan_id
                           AND PLAN.status_code = 'COMPLETE')
                     )
                 );
      BEGIN
        IF l_intelligent_flag = 'Y' THEN
          FOR rep IN l_reps_csr(l_start_date_adj, l_end_date_adj) LOOP
            l_counter  := l_counter + 1;
            populate_calcsub_batches(
              rep.salesrep_id
            , l_start_date_adj
            , l_end_date_adj
            , l_calc_from_period_id
            , l_calc_to_period_id
            , g_logical_batch_id
            , rep.hierarchy_flag
            );
          END LOOP;
        ELSE
          FOR rep IN l_reps_csr(l_start_date_orig, l_end_date_adj) LOOP
            l_counter  := l_counter + 1;
            populate_calcsub_batches(
              rep.salesrep_id
            , l_start_date_orig
            , l_end_date_adj
            , l_calc_from_period_id
            , l_calc_to_period_id
            , g_logical_batch_id
            , rep.hierarchy_flag
            );
          END LOOP;
        END IF;

        IF l_counter = 0 THEN   /* no one to be calculated */
          fnd_message.set_name('CN', 'CNSBCS_NO_ONE_TO_CALCULATE');

          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
            fnd_log.MESSAGE(
              fnd_log.level_exception
            , 'cn.plsql.cn_proc_batches_pkg.populate_process_batches.user_specify'
            , FALSE
            );
          END IF;

          RAISE no_one_with_complete_plan;
        END IF;
      END;
    ELSE   -- l_salesrep_option = 'REPS_IN_NOTIFY_LOG''
      -- only available when it's intelligent calc
      DECLARE
        -- select srp/period pair with a entry in notify_log
        -- select all srp/period if there is entry in notify log for
        -- a period and salesrep_id = -1000
        -- make sure srp has an active comp_plan in a open period  NOT ANY MORE

        -- 10/25/1999. Now as long as there is an entry in notify_log, we don't check
        -- the existence of a complete compensation plan
        l_return_status      VARCHAR2(30);
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(2000);
        l_srp                cn_rollup_pvt.srp_rec_type;
        l_active_group       cn_rollup_pvt.active_group_tbl_type;
        l_srp_group          cn_rollup_pvt.srp_group_rec_type;
        l_srp_group_ancestor cn_rollup_pvt.srp_group_tbl_type;
        l_system_rollup_flag VARCHAR2(1);

        CURSOR missed_reps IS
          SELECT DISTINCT ch.direct_salesrep_id
                        , ch.processed_period_id
                        , ch.processed_date
                        , NVL(ch.rollup_date, ch.processed_date) rollup_date
                     FROM cn_commission_headers_all ch
                    WHERE ch.direct_salesrep_id IN(
                            SELECT salesrep_id
                              FROM cn_srp_intel_periods_all
                             WHERE period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                               AND org_id = g_org_id)
                      AND ch.org_id = g_org_id
                      AND ch.processed_date BETWEEN l_start_date_adj AND l_end_date_adj
                      AND ch.status IN('COL', 'CLS');

        CURSOR missed_lines IS
          SELECT DISTINCT cl.credited_salesrep_id
                        , p.start_date
                        , p.end_date
                        , p.period_id
                     FROM cn_commission_lines_all cl, cn_period_statuses_all p
                    WHERE cl.processed_period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                      AND cl.status IN('ROLL', 'POP')
                      AND cl.org_id = g_org_id
                      AND cl.processed_period_id = p.period_id
                      AND p.org_id = g_org_id;

        CURSOR log_reps IS
          SELECT DISTINCT LOG.salesrep_id
                        , period.start_date
                        , period.end_date
                        , period.period_id
                     FROM cn_notify_log_all LOG, cn_period_statuses_all period
                    WHERE period.period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                      AND period.org_id = g_org_id
                      AND LOG.period_id = period.period_id
                      AND LOG.org_id = g_org_id
                      AND LOG.status = 'INCOMPLETE'
                      AND LOG.salesrep_id <> -1000
                      AND LOG.revert_state <> 'NCALC'
          UNION
          SELECT DISTINCT intel.salesrep_id
                        , period.start_date
                        , period.end_date
                        , period.period_id
                     FROM cn_period_statuses_all period
                        , cn_notify_log_all LOG
                        , cn_srp_intel_periods_all intel
                    WHERE period.period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                      AND period.org_id = g_org_id
                      AND LOG.period_id = period.period_id
                      AND LOG.org_id = g_org_id
                      AND LOG.salesrep_id = -1000
                      AND LOG.status = 'INCOMPLETE'
                      AND LOG.revert_state <> 'NCALC'
                      AND intel.period_id = period.period_id
                      AND intel.org_id = g_org_id;
      BEGIN
        SELECT NVL(srp_rollup_flag, 'N')
          INTO l_system_rollup_flag
          FROM cn_repositories_all
         WHERE org_id = g_org_id;

        FOR missed_line IN missed_lines LOOP
          cn_mark_events_pkg.mark_notify(
            p_salesrep_id                => missed_line.credited_salesrep_id
          , p_period_id                  => missed_line.period_id
          , p_start_date                 => missed_line.start_date
          , p_end_date                   => missed_line.end_date
          , p_quota_id                   => NULL
          , p_revert_to_state            => 'CALC'
          , p_event_log_id               => NULL
          , p_org_id                     => g_org_id
          );
        END LOOP;

        COMMIT;

        FOR missed_rep IN missed_reps LOOP
          cn_mark_events_pkg.mark_notify(
            p_salesrep_id                => missed_rep.direct_salesrep_id
          , p_period_id                  => missed_rep.processed_period_id
          , p_start_date                 => missed_rep.processed_date
          , p_end_date                   => missed_rep.processed_date
          , p_quota_id                   => NULL
          , p_revert_to_state            => 'CALC'
          , p_event_log_id               => NULL
          , p_org_id                     => g_org_id
          );

          IF (l_system_rollup_flag = 'Y') THEN
            l_srp.salesrep_id  := missed_rep.direct_salesrep_id;
            l_srp.start_date   := missed_rep.rollup_date;
            l_srp.end_date     := missed_rep.rollup_date;
            l_active_group.DELETE;
            cn_rollup_pvt.get_active_group(
              p_api_version                => 1.0
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , p_srp                        => l_srp
            , x_active_group               => l_active_group
            , p_org_id                     => g_org_id
            );

            IF (l_active_group.COUNT > 0) THEN
              FOR i IN l_active_group.FIRST .. l_active_group.LAST LOOP
                l_srp_group_ancestor.DELETE;
                l_srp_group.salesrep_id  := l_srp.salesrep_id;
                l_srp_group.GROUP_ID     := l_active_group(i).GROUP_ID;
                l_srp_group.start_date   := l_active_group(i).start_date;
                l_srp_group.end_date     := l_active_group(i).end_date;
                cn_rollup_pvt.get_ancestor_salesrep(
                  p_api_version                => 1.0
                , x_return_status              => l_return_status
                , x_msg_count                  => l_msg_count
                , x_msg_data                   => l_msg_data
                , p_srp                        => l_srp_group
                , x_srp                        => l_srp_group_ancestor
                , p_org_id                     => g_org_id
                );

                IF (l_srp_group_ancestor.COUNT > 0) THEN
                  FOR eachsrp IN l_srp_group_ancestor.FIRST .. l_srp_group_ancestor.LAST LOOP
                    cn_mark_events_pkg.mark_notify
                                       (
                      p_salesrep_id                => l_srp_group_ancestor(eachsrp).salesrep_id
                    , p_period_id                  => missed_rep.processed_period_id
                    , p_start_date                 => missed_rep.processed_date
                    , p_end_date                   => missed_rep.processed_date
                    , p_quota_id                   => NULL
                    , p_revert_to_state            => 'CALC'
                    , p_event_log_id               => NULL
                    , p_org_id                     => g_org_id
                    );
                  END LOOP;
                END IF;
              END LOOP;
            END IF;
          END IF;

          COMMIT;
        END LOOP;

        FOR rep IN log_reps LOOP
          l_counter  := 1;
          populate_calcsub_batches(
            rep.salesrep_id
          , rep.start_date
          , rep.end_date
          , rep.period_id
          , rep.period_id
          , g_logical_batch_id
          , l_hierarchy_flag
          );
        END LOOP;

        IF l_counter = 0 THEN   /* no one to be calculated */
          --fnd_message.set_name('CN', 'CNSBCS_NO_ONE_IN_NOTIFY_LOG');
             --raise no_one_with_complete_plan;
                    -- clku, bug 2783261, we won;t error out if we do not find any reps in
                   -- notify log, we just set status to complete and return
          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING
                       (
              fnd_log.level_exception
            , 'cn.plsql.cn_proc_batches_pkg.populate_process_batches.reps_in_notify_log'
            , 'No salesreps to calculate ...'
            );
          END IF;

          cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'COMPLETE');
        END IF;
      END;
    END IF;
  EXCEPTION
    WHEN no_one_with_complete_plan THEN
      fnd_file.put_line
        (
        fnd_file.LOG
      , 'Exception occurs in cn_proc_batches_pkg.populate_process_batch: No one with complete compensation plan to calculate.'
      );
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.populate_process_batch:');
      cn_message_pkg.rollback_errormsg_commit
                                             ('No one with complete compensation plan to calculate.');
      RAISE;
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG, 'In cn_proc_batches_pkg.populate_process_batch:' || SQLERRM);

      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.populate_process_batch.exception'
        , SQLERRM
        );
      END IF;

      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.populate_process_batch: ');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);
      RAISE;
  END populate_process_batch;

  -- Procedure Name
  --   calculation_submission
  -- Purpose
  --   start the calculation process when called from calc submission form
  -- Notes
  --   12-Jul-1998, Richard Jin  Created
  PROCEDURE calculation_submission(
    p_calc_sub_batch_id              NUMBER
  , x_process_audit_id    OUT NOCOPY NUMBER
  , x_process_status_code OUT NOCOPY VARCHAR2
  ) IS
    CURSOR l_calc_batch_csr IS
      SELECT status
           , concurrent_flag
           , logical_batch_id
           , calc_type
           , start_date
           , end_date
           , org_id
        FROM cn_calc_submission_batches_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;

    l_batch_rec l_calc_batch_csr%ROWTYPE;
    l_status    cn_calc_submission_batches.status%TYPE;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.calculation_submission.begin'
      , 'Beginning of calculation submission procedure ...'
      );
    END IF;

    OPEN l_calc_batch_csr;
    FETCH l_calc_batch_csr INTO l_batch_rec;
    CLOSE l_calc_batch_csr;

    g_calc_type  := l_batch_rec.calc_type;

    IF l_batch_rec.status = 'COMPLETE' THEN
      -- once completed, can not start it again
      NULL;
    ELSE
      cn_message_pkg.begin_batch(
        x_process_type               => 'CALCULATION'
      , x_parent_proc_audit_id       => NULL
      , x_process_audit_id           => x_process_audit_id
      , x_request_id                 => fnd_global.conc_request_id
      , p_org_id                     => l_batch_rec.org_id
      );

      UPDATE cn_calc_submission_batches_all
         SET process_audit_id = x_process_audit_id
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;

      IF (
             (l_batch_rec.status = 'FAILED' AND l_batch_rec.concurrent_flag = 'N')
          OR g_calc_type = 'BONUS'
         ) THEN
        -- purge the previous run from cn_process_batch before restart as a new logical batch
        DELETE      cn_process_batches_all
              WHERE logical_batch_id = l_batch_rec.logical_batch_id;
      END IF;

      IF (
             (l_batch_rec.status <> 'FAILED' OR l_batch_rec.concurrent_flag = 'N')
          OR g_calc_type = 'BONUS'
         ) THEN
        initialize_logical_batch(p_calc_sub_batch_id);
      ELSE
        g_logical_batch_id  := l_batch_rec.logical_batch_id;
        g_org_id            := l_batch_rec.org_id;
      END IF;

      IF g_calc_type = 'BONUS' THEN
        populate_bonus_process_batch(p_calc_sub_batch_id);
      ELSE
        IF (l_batch_rec.status <> 'FAILED' OR l_batch_rec.concurrent_flag = 'N') THEN
          populate_process_batch(p_calc_sub_batch_id);
        END IF;
      END IF;

      -- clku, bug 2783261, check if the status is complete before calling main
      SELECT status
        INTO l_status
        FROM cn_calc_submission_batches_all
       WHERE logical_batch_id = g_logical_batch_id;

      IF l_status <> 'COMPLETE' THEN
        cn_global_var.initialize_instance_info(l_batch_rec.org_id);
        cn_proc_batches_pkg.main(
          p_concurrent_flag            => l_batch_rec.concurrent_flag
        , p_process_name               => 'CALCULATION'
        , p_logical_batch_id           => g_logical_batch_id
        , p_start_date                 => l_batch_rec.start_date
        , p_end_date                   => l_batch_rec.end_date
        , p_salesrep_id                => NULL
        , p_comp_plan_id               => NULL
        , x_process_audit_id           => x_process_audit_id
        , x_process_status_code        => x_process_status_code
        );
      ELSE
        x_process_status_code  := 'SUCCESS';
        cn_message_pkg.set_name('CN', 'ALL_PROCESS_DONE_OK');
        cn_message_pkg.end_batch(x_process_audit_id);
      END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.calculation_submission.end'
      , 'End of calculation submission procedure.'
      );
    END IF;
  EXCEPTION
    WHEN no_one_with_complete_plan THEN
      fnd_file.put_line
               (
        fnd_file.LOG
      , 'no_one_with_complete_plan EXCEPTION in cn_proc_batches_pkg.calculation_submission'
      );
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.calculation_submission');
      cn_message_pkg.rollback_errormsg_commit
                                        ('No resource with complete compensation plan to calculate.');
      cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'FAILED');
      COMMIT;
      app_exception.raise_exception;
    WHEN OTHERS THEN
      x_process_status_code  := 'FAIL';
      fnd_file.put_line(fnd_file.LOG, 'Error in cn_proc_batches_pkg.calculation_submission.');
      fnd_file.put_line(fnd_file.LOG, SQLERRM);
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.calculation_submission:');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);
      cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'FAILED');
      COMMIT;

      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.calculation_submission.exception'
        , SQLERRM
        );
      END IF;
  END calculation_submission;

  -- Procedure Name
  --   get_physical_batch_id
  -- Purpose
  FUNCTION get_physical_batch_id
    RETURN NUMBER IS
    x_physical_batch_id NUMBER;
  BEGIN
    SELECT cn_process_batches_s3.NEXTVAL
      INTO x_physical_batch_id
      FROM SYS.DUAL;

    RETURN x_physical_batch_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.get_physical_batch_id.exception'
        , SQLERRM
        );
      END IF;

      fnd_file.put_line(fnd_file.LOG, 'In cn_proc_batches.get_physical_batch_id: ' || SQLERRM);
      RAISE;
  END get_physical_batch_id;

  -- Procedure Name
  --   void_batches
  -- Purpose
  --   VOID the batches that have successfully moved to the required status
  --   to prevent them being picked up in any retries.
  --   Unlockable batches will remain for the requred number of retries
  --   Called just before program completes to purge the table of any remaining
  --   unprocessed records that were not procesed during retries.
  PROCEDURE void_batches(x_physical_batch_id VARCHAR2) IS
    l_user_id         NUMBER(15) := fnd_global.user_id;
    l_resp_id         NUMBER(15) := fnd_global.resp_id;
    l_login_id        NUMBER(15) := fnd_global.login_id;
    l_conc_prog_id    NUMBER(15) := fnd_global.conc_program_id;
    l_conc_request_id NUMBER(15) := fnd_global.conc_request_id;
    l_prog_appl_id    NUMBER(15) := fnd_global.prog_appl_id;
  BEGIN
    IF x_physical_batch_id IS NULL THEN
      UPDATE cn_process_batches_all
         SET status_code = 'VOID'
           , last_update_date = SYSDATE
           , last_update_login = l_login_id
           , last_updated_by = l_user_id
           , request_id = l_conc_request_id
           , program_application_id = l_prog_appl_id
           , program_id = l_conc_prog_id
           , program_update_date = SYSDATE
       WHERE logical_batch_id = g_logical_batch_id;
    ELSE
      UPDATE cn_process_batches_all
         SET status_code = 'VOID'
           , last_update_date = SYSDATE
           , last_update_login = l_login_id
           , last_updated_by = l_user_id
           , request_id = l_conc_request_id
           , program_application_id = l_prog_appl_id
           , program_id = l_conc_prog_id
           , program_update_date = SYSDATE
       WHERE physical_batch_id = x_physical_batch_id;
    END IF;
  END void_batches;

  -- Procedure Name
  --   Assign
  -- Purpose
  --   Split the logical batch into smaller physical batches of N srp_periods
  -- Notes
  --   Cannot restrict by current status because we may be executing
  --   many physical processes for a logical process. If the first physical
  --   process can't find any records in it's curr state, the second process
  --   will still need the physical batch id's
  --   Unable to lock for update because runner commits after one physical
  --   batch is processed. Cannot fetch from a for update cursor after a
  --   commit since the locks are acquired when the cursor is opened and
  --   released after commit
  PROCEDURE assign IS
    TYPE num_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    reps_tbl               num_tbl_type;
    nums_tbl               num_tbl_type;
    bids_tbl               num_tbl_type;
    x_physical_batch_id    NUMBER;
    l_trx_count            NUMBER               := 0;
    l_srp_count            NUMBER               := 0;
    l_user_id              NUMBER(15)           := fnd_global.user_id;
    l_resp_id              NUMBER(15)           := fnd_global.resp_id;
    l_login_id             NUMBER(15)           := fnd_global.login_id;
    l_conc_prog_id         NUMBER(15)           := fnd_global.conc_program_id;
    l_conc_request_id      NUMBER(15)           := fnd_global.conc_request_id;
    l_prog_appl_id         NUMBER(15)           := fnd_global.prog_appl_id;
    l_pre_logical_batch_id NUMBER;
    l_srp_batch_size_flag  VARCHAR2(1);

    CURSOR batch_info IS
      SELECT NAME
           , calc_type
           , intelligent_flag
           , NVL(hierarchy_flag, 'N')
           , salesrep_option
           , start_date
           , end_date
           , org_id
        FROM cn_calc_submission_batches_all
       WHERE logical_batch_id = g_logical_batch_id;

    l_batch_info           batch_info%ROWTYPE;

    CURSOR pre_batch_info IS
      SELECT MAX(logical_batch_id)
        FROM cn_calc_submission_batches_all
       WHERE logical_batch_id >(g_logical_batch_id - 1000)
         AND logical_batch_id < g_logical_batch_id
         AND salesrep_option = 'ALL_REPS'
         AND calc_type = 'COMMISSION'
         AND NVL(hierarchy_flag, 'N') = 'N'
         AND intelligent_flag = l_batch_info.intelligent_flag
         AND start_date = l_batch_info.start_date
         AND end_date = l_batch_info.end_date
         AND org_id = l_batch_info.org_id;

    CURSOR reps IS
      SELECT   salesrep_id
             , DECODE(sales_lines_total, 0, commission_headers_count, sales_lines_total)
          FROM cn_process_batches
         WHERE logical_batch_id = g_logical_batch_id AND status_code = 'IN_USE'
      ORDER BY salesrep_id DESC;

    CURSOR rep_lines_info(p_salesrep_id NUMBER) IS
      SELECT COUNT(1)
        FROM cn_commission_lines_all line, cn_process_batches_all batch
       WHERE batch.logical_batch_id = g_logical_batch_id
         AND batch.salesrep_id = p_salesrep_id
         AND batch.status_code = 'IN_USE'
         AND line.credited_salesrep_id = p_salesrep_id
         AND line.processed_period_id BETWEEN batch.period_id AND batch.end_period_id
         AND line.processed_date BETWEEN batch.start_date AND batch.end_date
         AND line.org_id = batch.org_id;

    CURSOR action_links IS
      SELECT DISTINCT action_link_id
                 FROM cn_process_batches_all batch, cn_notify_log_all LOG
                WHERE batch.logical_batch_id = g_logical_batch_id
                  AND batch.status_code = 'IN_USE'
                  AND LOG.salesrep_id = batch.salesrep_id
                  AND LOG.period_id BETWEEN batch.period_id AND batch.end_period_id
                  AND LOG.status = 'INCOMPLETE'
                  AND LOG.action_link_id IS NOT NULL
                  AND LOG.org_id = batch.org_id;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.assign.begin'
      , 'Beginning of assigning resources to physical batches ...'
      );
    END IF;

    l_srp_batch_size_flag  := NVL(fnd_profile.VALUE('CN_SRP_ONLY_BATCH_SIZE'), 'N');

    OPEN batch_info;
    FETCH batch_info INTO l_batch_info;
    CLOSE batch_info;

    IF (
            l_batch_info.salesrep_option = 'ALL_REPS'
        AND l_batch_info.calc_type = 'COMMISSION'
        AND MOD(NVL(cn_global_var.get_srp_batch_size(l_batch_info.org_id), 0), 10) = 0
       ) THEN
      OPEN pre_batch_info;
      FETCH pre_batch_info INTO l_pre_logical_batch_id;
      CLOSE pre_batch_info;
    END IF;

    IF ((l_pre_logical_batch_id IS NOT NULL) AND(l_srp_batch_size_flag <> 'Y')) THEN
      UPDATE cn_process_batches_all a
         SET (a.sales_lines_total, a.commission_headers_count) =
               (SELECT sales_lines_total
                     , commission_headers_count
                  FROM cn_process_batches_all
                 WHERE logical_batch_id = l_pre_logical_batch_id AND salesrep_id = a.salesrep_id)
       WHERE logical_batch_id = g_logical_batch_id;

      UPDATE cn_process_batches_all a
         SET a.sales_lines_total =
               (SELECT COUNT(1)
                  FROM cn_commission_lines_all
                 WHERE credited_salesrep_id = a.salesrep_id
                   AND org_id = a.org_id
                   AND processed_period_id BETWEEN a.period_id AND a.end_period_id
                   AND processed_date BETWEEN a.start_date AND a.end_date)
           , a.commission_headers_count =
               (SELECT COUNT(1)
                  FROM cn_commission_headers_all
                 WHERE direct_salesrep_id = a.salesrep_id
                   AND org_id = a.org_id
                   AND processed_period_id BETWEEN a.period_id AND a.end_period_id
                   AND processed_date BETWEEN a.start_date AND a.end_date)
       WHERE a.logical_batch_id = g_logical_batch_id AND a.sales_lines_total IS NULL;

      OPEN reps;
      FETCH reps BULK COLLECT INTO reps_tbl, nums_tbl;
      CLOSE reps;
    ELSIF((l_batch_info.calc_type = 'COMMISSION') AND(l_srp_batch_size_flag <> 'Y')) THEN
      UPDATE cn_process_batches_all a
         SET a.sales_lines_total =
               (SELECT COUNT(1)
                  FROM cn_commission_lines_all
                 WHERE credited_salesrep_id = a.salesrep_id
                   AND org_id = a.org_id
                   AND processed_period_id BETWEEN a.period_id AND a.end_period_id
                   AND processed_date BETWEEN a.start_date AND a.end_date)
           , a.commission_headers_count =
               (SELECT COUNT(1)
                  FROM cn_commission_headers_all
                 WHERE direct_salesrep_id = a.salesrep_id
                   AND org_id = a.org_id
                   AND processed_period_id BETWEEN a.period_id AND a.end_period_id
                   AND processed_date BETWEEN a.start_date AND a.end_date)
       WHERE a.logical_batch_id = g_logical_batch_id;

      OPEN reps;
      FETCH reps BULK COLLECT INTO reps_tbl, nums_tbl;
      CLOSE reps;
    ELSE
      OPEN reps;
      FETCH reps BULK COLLECT INTO reps_tbl, nums_tbl;
      CLOSE reps;
    END IF;

    IF (reps_tbl.COUNT = 0) THEN
      cn_message_pkg.set_name('CN', 'PROC_NO_TRX_TO_PROCESS');

      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_exception
        , 'cn.plsql.cn_proc_batches_pkg.assign.reps_count'
        , 'No salesreps to process.'
        );
      END IF;

      fnd_file.put_line(fnd_file.LOG, fnd_message.get);
      RAISE no_comm_lines;
    END IF;

    -- get the first physical batch id
    x_physical_batch_id    := get_physical_batch_id;

    IF ((l_batch_info.calc_type = 'COMMISSION') AND(l_srp_batch_size_flag <> 'Y')) THEN
      FOR i IN reps_tbl.FIRST .. reps_tbl.LAST LOOP
        IF (nums_tbl(i) IS NULL) THEN
          OPEN rep_lines_info(reps_tbl(i));
          FETCH rep_lines_info INTO nums_tbl(i);
          CLOSE rep_lines_info;
        END IF;

        l_srp_count  := l_srp_count + 1;
        l_trx_count  := l_trx_count + nums_tbl(i);

        IF (l_trx_count >= cn_global_var.get_srp_batch_size(l_batch_info.org_id)) THEN
          IF (l_srp_count > 1) THEN
            -- this salesrep should go to next batch
            l_trx_count          := nums_tbl(i);
            l_srp_count          := 1;
            x_physical_batch_id  := get_physical_batch_id;
          END IF;
        ELSIF(l_srp_count > cn_global_var.get_salesrep_batch_size(l_batch_info.org_id)) THEN
          -- the current batch has enough reps, this rep needs to go to next batch
          l_trx_count          := nums_tbl(i);
          l_srp_count          := 1;
          x_physical_batch_id  := get_physical_batch_id;
        END IF;

        bids_tbl(i)  := x_physical_batch_id;
      END LOOP;
    ELSE
      FOR i IN reps_tbl.FIRST .. reps_tbl.LAST LOOP
        l_srp_count  := l_srp_count + 1;

        IF (l_srp_count > cn_global_var.get_salesrep_batch_size(l_batch_info.org_id)) THEN
          -- the current batch has enough reps, this rep needs to go to next batch
          l_srp_count          := 1;
          x_physical_batch_id  := get_physical_batch_id;
        END IF;

        bids_tbl(i)  := x_physical_batch_id;
      END LOOP;
    END IF;

    FORALL i IN reps_tbl.FIRST .. reps_tbl.LAST
      UPDATE cn_process_batches_all
         SET physical_batch_id = bids_tbl(i)
           ,
             --sales_lines_total = nums_tbl(i),
             last_update_date = SYSDATE
           , last_update_login = l_login_id
           , last_updated_by = l_user_id
           , request_id = l_conc_request_id
           , program_application_id = l_prog_appl_id
           , program_id = l_conc_prog_id
           , program_update_date = SYSDATE
       WHERE salesrep_id = reps_tbl(i) AND logical_batch_id = g_logical_batch_id;

    -- assign the last physical_batch_id to those actions
    -- generated from change_srp_hierarchy event
    IF (l_batch_info.calc_type = 'COMMISSION' AND l_batch_info.intelligent_flag = 'Y') THEN
      FOR action_link IN action_links LOOP
        UPDATE cn_notify_log_all
           SET physical_batch_id = x_physical_batch_id
         WHERE notify_log_id = action_link.action_link_id AND status = 'INCOMPLETE';

        UPDATE cn_notify_log_all
           SET physical_batch_id = x_physical_batch_id
         WHERE action_link_id = action_link.action_link_id AND status = 'INCOMPLETE';
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.assign.end'
      , 'Finish assigning resources to physical batches.'
      );
    END IF;

    cn_message_pkg.DEBUG('Finish assigning resources to physical batches.');
    cn_message_pkg.FLUSH;
    COMMIT;
  EXCEPTION
    WHEN no_comm_lines THEN
      fnd_file.put_line(fnd_file.LOG, 'no_comm_lines exception in cn_proc_batches_pkg.assign');
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.assign:');
      cn_message_pkg.DEBUG('No transactions to process.');
      RAISE;
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(fnd_log.level_unexpected, 'cn.plsql.cn_proc_batches_pkg.assign.exception'
        , SQLERRM);
      END IF;

      fnd_file.put_line(fnd_file.LOG, 'In cn_proc_batches.assign: ' || SQLERRM);
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.assign:');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);
      RAISE;
  END assign;

  PROCEDURE update_error(x_physical_batch_id NUMBER) IS
    l_user_id         NUMBER(15) := fnd_global.user_id;
    l_resp_id         NUMBER(15) := fnd_global.resp_id;
    l_login_id        NUMBER(15) := fnd_global.login_id;
    l_conc_prog_id    NUMBER(15) := fnd_global.conc_program_id;
    l_conc_request_id NUMBER(15) := fnd_global.conc_request_id;
    l_prog_appl_id    NUMBER(15) := fnd_global.prog_appl_id;
  BEGIN
    -- Giving the batch an 'ERROR' status prevents subsequent
    -- physical processes picking it up.
    UPDATE cn_process_batches_all
       SET status_code = 'ERROR'
         , last_update_date = SYSDATE
         , last_update_login = l_login_id
         , last_updated_by = l_user_id
         , request_id = l_conc_request_id
         , program_application_id = l_prog_appl_id
         , program_id = l_conc_prog_id
         , program_update_date = SYSDATE
     WHERE physical_batch_id = x_physical_batch_id;
  END update_error;

  PROCEDURE conc_submit(
    x_conc_program                       VARCHAR2
  , x_parent_proc_audit_id               NUMBER
  , x_logical_process                    VARCHAR2
  , x_physical_process                   VARCHAR2
  , x_physical_batch_id                  NUMBER
  , x_request_id           IN OUT NOCOPY NUMBER
  ) IS
  BEGIN
    fnd_request.set_org_id(g_org_id);
    x_request_id  :=
      fnd_request.submit_request(
        application                  => 'CN'
      , program                      => x_conc_program
      , description                  => NULL
      , start_time                   => NULL
      , sub_request                  => NULL
      , argument1                    => x_parent_proc_audit_id
      , argument2                    => x_logical_process
      , argument3                    => x_physical_process
      , argument4                    => x_physical_batch_id
      );

    IF (x_request_id = 0 OR x_request_id IS NULL) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_error
        , 'cn.plsql.cn_proc_batches_pkg.conc_submit.submission_status'
        , 'Submission failure for batch: ' || x_physical_batch_id
        );
      END IF;

      fnd_file.put_line(fnd_file.LOG, 'Submission failure for batch' || x_physical_batch_id);
      cn_message_pkg.DEBUG('Failed to submit concurrent request (batch ID=' || x_physical_batch_id
        || ')');
      cn_message_pkg.DEBUG(fnd_message.get);
    -- raise conc_fail;
    ELSE
      cn_message_pkg.FLUSH;
      COMMIT;
    END IF;
  END conc_submit;

  -- Procedure Name
  --   Conc_Dispatch
  -- Purpose
  --   Performs a process on all physical batches in the logical batch
  --   before moving on to the next process.
  --   e.g will classify all transactions in the logical batch and then
  --   move on to population etc

  --   Submits independent concurrent programs for each physical batch.
  --   These physical batches will be executed in parallel.
  --   A subsequent physical process cannot begin until all physical
  --   batches in its prerequisite process have completed.
  PROCEDURE conc_dispatch(x_parent_proc_audit_id NUMBER) IS
    TYPE num_tbl IS TABLE OF NUMBER(15)
      INDEX BY BINARY_INTEGER;

    TYPE str30_tbl IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

    l_primary_request_stack     num_tbl;
    l_primary_batch_stack       num_tbl;
    l_current_phase_stack       str30_tbl;
    l_process_order             num_tbl;
    n                           NUMBER         := 0;
    x_batch_total               NUMBER         := 0;
    l_temp_id                   NUMBER         := 0;
    l_new_status                VARCHAR2(30)   := NULL;
    l_curr_status               VARCHAR2(30)   := NULL;
    l_curr_process              VARCHAR2(30)   := NULL;
    l_temp_phys_batch_id        NUMBER;
    primary_ptr                 NUMBER         := 1;   -- Must start at 1
    l_dev_phase                 VARCHAR2(80);
    l_dev_status                VARCHAR2(80);
    l_request_id                NUMBER;
    l_completed_revert_count    NUMBER         := 0;
    l_completed_classify_count  NUMBER         := 0;
    l_completed_rollup_count    NUMBER         := 0;
    l_completed_populate_count  NUMBER         := 0;
    l_completed_calculate_count NUMBER         := 0;
    l_call_status               BOOLEAN;
    l_next_process              VARCHAR2(30);
    l_dummy                     VARCHAR2(2000);
    unfinished                  BOOLEAN        := TRUE;
    l_user_id                   NUMBER(15)     := fnd_global.user_id;
    l_resp_id                   NUMBER(15)     := fnd_global.resp_id;
    l_login_id                  NUMBER(15)     := fnd_global.login_id;
    l_conc_prog_id              NUMBER(15)     := fnd_global.conc_program_id;
    l_conc_request_id           NUMBER(15)     := fnd_global.conc_request_id;
    l_prog_appl_id              NUMBER(15)     := fnd_global.prog_appl_id;
    debug_v                     NUMBER;
    l_sleep_time                NUMBER         := 180;
    l_sleep_time_char           VARCHAR2(30);
    l_failed_request_id         NUMBER;
    l_intelligent_flag          VARCHAR2(1);
    l_start_date                DATE;
    l_end_date                  DATE;
    l_payee_count               NUMBER;
    l_new_request_submitted     BOOLEAN;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch.begin'
      , 'Beginning of conc_dispatch...'
      );
    END IF;

    -- Flood procedure calls
    -- flood_salesreps;
    flood_rev_classes;
    cn_message_pkg.FLUSH;
    COMMIT;

    SELECT intelligent_flag, start_date, end_date
      INTO l_intelligent_flag, l_start_date, l_end_date
      FROM cn_calc_submission_batches
     WHERE logical_batch_id = g_logical_batch_id;

    IF g_calc_type = 'BONUS' THEN
      IF l_curr_process IS NULL THEN
        l_curr_process  := g_revert;
      ELSE
        l_curr_process  := g_calculation;   --g_logical_process;
      END IF;
    ELSE
      next_process(x_physical_process => l_curr_process);
    END IF;

    l_payee_count  := 0;

    SELECT COUNT(*)
      INTO l_payee_count
      FROM cn_srp_payee_assigns a
     WHERE a.start_date <= l_end_date AND(a.end_date IS NULL OR a.end_date >= l_start_date);

    FOR physical_rec IN physical_batches LOOP
      conc_submit(
        x_conc_program               => 'BATCH_RUNNER'
      , x_parent_proc_audit_id       => x_parent_proc_audit_id
      , x_logical_process            => g_logical_process
      , x_physical_process           => l_curr_process
      , x_physical_batch_id          => physical_rec.physical_batch_id
      , x_request_id                 => l_temp_id
      );
      x_batch_total                           := x_batch_total + 1;
      l_primary_batch_stack(x_batch_total)    := physical_rec.physical_batch_id;
      l_primary_request_stack(x_batch_total)  := l_temp_id;
      l_current_phase_stack(x_batch_total)    := l_curr_process;

      cn_message_pkg.debug(
          'Submitted request for Physical Batch ' || physical_rec.physical_batch_id ||
          ' for process ' || l_curr_process || ' : Request = ' || l_temp_id
        );

      IF (l_temp_id = 0 OR l_temp_id IS NULL) THEN
        l_temp_phys_batch_id  := physical_rec.physical_batch_id;
        l_failed_request_id   := l_temp_id;
        RAISE conc_fail;
      END IF;
    END LOOP;
    l_new_request_submitted := TRUE;

    UPDATE cn_process_batches_all
       SET trx_batch_id = l_primary_batch_stack(x_batch_total)
     WHERE physical_batch_id = l_primary_batch_stack(x_batch_total);

    COMMIT;

    -- batches should be sorted by commission_headers_count in classification/rollup phase
    n              := 1;
    FOR p_rec IN physical_batches2 LOOP
      FOR i IN 1 .. x_batch_total LOOP
        IF (l_primary_batch_stack(i) = p_rec.physical_batch_id) THEN
          l_process_order(n)  := i;
          EXIT;
        END IF;
      END LOOP;

      n  := n + 1;
    END LOOP;

    l_sleep_time_char  := fnd_profile.VALUE('CN_SLEEP_TIME');
    IF l_sleep_time_char IS NOT NULL THEN
      l_sleep_time  := TO_NUMBER(l_sleep_time_char);
    END IF;

    WHILE unfinished LOOP
      /*
       * Bug#7265394 - Not sure whats been implemented here.
       * This can lead to bypassing SLEEP and calling FND_CONCURRENT.GET_REQUEST_STATUS
       * continuously. Therefore rewrote the logic in a different way.
       *
      IF (l_completed_revert_count = x_batch_total AND l_completed_classify_count = 0) THEN
        NULL;
      ELSIF(l_completed_classify_count = x_batch_total AND l_completed_rollup_count = 0) THEN
        NULL;
      ELSIF(l_completed_rollup_count = x_batch_total AND l_completed_populate_count = 0) THEN
        NULL;
      ELSIF(l_completed_populate_count = x_batch_total AND l_completed_calculate_count = 0) THEN
        NULL;
      ELSE
        DBMS_LOCK.sleep(l_sleep_time);
      END IF;
      */

      cn_message_pkg.debug(
           'Check whether we can sleep for sometime to get the requests completed...'
        || ' Batch Total = ' || x_batch_total
        || ' : Reverted = ' || l_completed_revert_count
        || ' : Classified = ' || l_completed_classify_count
        || ' : Rolled = ' || l_completed_rollup_count
        || ' : Populated = ' || l_completed_populate_count
        || ' : Calculated = ' || l_completed_calculate_count
        );

      IF l_new_request_submitted THEN
        cn_message_pkg.debug('A new request has been submitted.. Lets check once more whether any other request has completed.');
        l_new_request_submitted := FALSE;
      ELSE
        cn_message_pkg.debug('There is no change evident in this iteration. Therefore sleep for ' || l_sleep_time);
        DBMS_LOCK.sleep(l_sleep_time);
      END IF;

      FOR i IN 1 .. x_batch_total LOOP
        primary_ptr  := l_process_order(i);

        IF (l_primary_request_stack(primary_ptr) IS NOT NULL) THEN
          l_call_status  :=
            fnd_concurrent.get_request_status(
              request_id                   => l_primary_request_stack(primary_ptr)
            , phase                        => l_dummy
            , status                       => l_dummy
            , dev_phase                    => l_dev_phase
            , dev_status                   => l_dev_status
            , MESSAGE                      => l_dummy
            );

          IF (NOT l_call_status) THEN
            l_failed_request_id   := l_primary_request_stack(primary_ptr);
            l_temp_phys_batch_id  := l_primary_batch_stack(primary_ptr);

            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
              fnd_log.STRING(
                fnd_log.level_unexpected
              , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch.request_status'
              , 'Request ' || l_failed_request_id || ' failed (batch_id = ' || l_temp_phys_batch_id
              );
            END IF;

            cn_message_pkg.DEBUG('Concurrent Request#' || l_failed_request_id || ' for Physical Batch#' || l_temp_phys_batch_id || ' completed with error');
            fnd_file.put_line(fnd_file.LOG, 'Conc_dispatch: Request completed with error for ' || l_failed_request_id);
            fnd_file.put_line(fnd_file.LOG, 'Conc_dispatch: Request failed for physical batch' || l_temp_phys_batch_id);
            RAISE conc_fail;
          END IF;

          IF l_dev_phase = 'COMPLETE' THEN
            l_failed_request_id                   := l_primary_request_stack(primary_ptr);
            l_primary_request_stack(primary_ptr)  := NULL;

            IF (l_current_phase_stack(primary_ptr) = g_revert) THEN
              l_completed_revert_count  := l_completed_revert_count + 1;
            ELSIF(l_current_phase_stack(primary_ptr) = g_classification) THEN
              l_completed_classify_count  := l_completed_classify_count + 1;
            ELSIF(l_current_phase_stack(primary_ptr) = g_rollup) THEN
              l_completed_rollup_count  := l_completed_rollup_count + 1;

              -- upon completion of rollup phase, switch the processing order back to lines_total-based
              IF (l_completed_rollup_count = x_batch_total) THEN
                FOR x IN 1 .. x_batch_total LOOP
                  l_process_order(x)  := x;
                END LOOP;

                EXIT;
              END IF;
            ELSIF(l_current_phase_stack(primary_ptr) = g_population) THEN
              l_completed_populate_count  := l_completed_populate_count + 1;
            ELSIF(l_current_phase_stack(primary_ptr) = g_calculation) THEN
              l_completed_calculate_count  := l_completed_calculate_count + 1;
            END IF;

            IF l_dev_status IN('ERROR', 'TERMINATING', 'TERMINATED', 'DELETED') THEN
              l_temp_phys_batch_id  := l_primary_batch_stack(primary_ptr);

              IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING(
                  fnd_log.level_error
                , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch.request_status'
                , 'Request ' || l_failed_request_id || ' failed (batch_id = '
                  || l_temp_phys_batch_id
                );
              END IF;

              cn_message_pkg.DEBUG('Concurrent Request#' || l_failed_request_id || ' for Physical Batch#' || l_temp_phys_batch_id || ' completed with error');
              fnd_file.put_line(fnd_file.LOG, 'Conc_dispatch: Request completed with error for ' || l_failed_request_id);
              fnd_file.put_line(fnd_file.LOG, 'Conc_dispatch: Request failed for physical_batch' || l_temp_phys_batch_id);
              RAISE conc_fail;
            END IF;   -- If error
          END IF;   -- If complete
        END IF;   -- If request_id is not null

        -- if waiting to proceed, then check the conditions for moving on
        IF (l_primary_request_stack(primary_ptr) IS NULL) THEN
          l_curr_process  := NULL;

          -- check whether the current batch can start the next phase
          IF (l_current_phase_stack(primary_ptr) = g_revert) THEN
            -- go to classification phase directly
            l_curr_process  := l_current_phase_stack(primary_ptr);
            next_process(x_physical_process => l_curr_process);
          ELSIF(l_current_phase_stack(primary_ptr) = g_classification) THEN
            -- if all batches are done with revert phase, then start rollup phase
            IF (l_completed_revert_count = x_batch_total) THEN
              IF (l_intelligent_flag = 'Y') THEN
                -- for intelligent calculation, the first batch should complete rollup phase
                -- before the other batches do
                IF (l_completed_rollup_count = 0 AND primary_ptr = 1) THEN
                  l_curr_process  := l_current_phase_stack(primary_ptr);
                  next_process(x_physical_process => l_curr_process);
                ELSIF(l_completed_rollup_count > 0) THEN
                  l_curr_process  := l_current_phase_stack(primary_ptr);
                  next_process(x_physical_process => l_curr_process);
                END IF;
              ELSE
                l_curr_process  := l_current_phase_stack(primary_ptr);
                next_process(x_physical_process => l_curr_process);
              END IF;
            END IF;
          ELSIF(l_current_phase_stack(primary_ptr) = g_rollup) THEN
            -- if all batches are done with rollup phase, then start population phase
            IF (l_completed_rollup_count = x_batch_total) THEN
              l_curr_process  := l_current_phase_stack(primary_ptr);
              next_process(x_physical_process => l_curr_process);
            END IF;
          ELSIF(l_current_phase_stack(primary_ptr) = g_population) THEN
            IF l_payee_count > 0 THEN
              IF (
                     (
                          primary_ptr = x_batch_total
                      AND l_completed_calculate_count =(x_batch_total - 1)
                     )
                  OR (primary_ptr < x_batch_total)
                 ) THEN
                l_curr_process  := l_current_phase_stack(primary_ptr);
                next_process(x_physical_process => l_curr_process);
              END IF;
            ELSE
              l_curr_process  := l_current_phase_stack(primary_ptr);
              next_process(x_physical_process => l_curr_process);
            END IF;
          ELSIF(l_current_phase_stack(primary_ptr) = g_calculation) THEN
            IF (l_completed_calculate_count = x_batch_total) THEN
              cn_message_pkg.DEBUG('All concurrent requests complete phase ' || g_logical_process);
              unfinished  := FALSE;
            END IF;
          END IF;

          -- submit request for next phase if all the conditions to proceed are met
          IF (l_curr_process IS NOT NULL) THEN
            conc_submit(
              x_conc_program               => 'BATCH_RUNNER'
            , x_parent_proc_audit_id       => x_parent_proc_audit_id
            , x_logical_process            => g_logical_process
            , x_physical_process           => l_curr_process
            , x_physical_batch_id          => l_primary_batch_stack(primary_ptr)
            , x_request_id                 => l_temp_id
            );
            l_primary_request_stack(primary_ptr) := l_temp_id;
            l_current_phase_stack(primary_ptr)   := l_curr_process;
            l_new_request_submitted              := TRUE;

            cn_message_pkg.debug(
                'Moving Physical Batch#' || l_primary_batch_stack(primary_ptr) ||
                ' to next process ' || l_curr_process || ' Request = ' || l_temp_id
              );

            IF (l_temp_id = 0 OR l_temp_id IS NULL) THEN
              l_temp_phys_batch_id  := l_primary_batch_stack(primary_ptr);
              l_failed_request_id   := l_temp_id;
              RAISE conc_fail;
            END IF;
          END IF;   -- If l_curr_process is not null
        END IF;   -- If request_id is null
      END LOOP;   -- for primary_ptr in 1..x_batch_total
    END LOOP;   -- while unfinished loop

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch.end'
      , 'End of conc_dispatch.'
      );
    END IF;
  EXCEPTION
    WHEN conc_fail THEN
      fnd_file.put_line(fnd_file.LOG, 'conc_fail exception in cn_proc_batches_pkg.conc_dispatch');
      update_error(l_temp_phys_batch_id);

      -- canceling running/pending requests
      IF (l_primary_request_stack.COUNT > 0) THEN
        FOR i IN l_primary_request_stack.FIRST .. l_primary_request_stack.LAST LOOP
          IF (l_primary_request_stack(i) > 0) THEN
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
              fnd_log.STRING(
                fnd_log.level_exception
              , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch.exception'
              , 'Cancelling request: ' || l_primary_request_stack(i)
              );
            END IF;

            l_call_status  := fnd_concurrent.cancel_request(l_primary_request_stack(i), l_dummy);
            cn_message_pkg.DEBUG('Cancelling request (ID=' || l_primary_request_stack(i)
              || ' Status=' || l_dummy || ')');
          END IF;
        END LOOP;
      END IF;

      cn_message_pkg.end_batch(x_parent_proc_audit_id);
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch.exception', SQLERRM);
      END IF;

      fnd_file.put_line(fnd_file.LOG, 'unexpected exception in cn_proc_batches_pkg.conc_dispatch');
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.conc_dispatch:');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);
      RAISE;
  END conc_dispatch;

  PROCEDURE conc_dispatch2(x_parent_proc_audit_id NUMBER) IS
    TYPE requests IS TABLE OF NUMBER(15)
      INDEX BY BINARY_INTEGER;

    TYPE str30_tbl IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

    l_primary_request_stack     requests;
    l_primary_batch_stack       requests;
    l_current_phase_stack       str30_tbl;
    l_process_order             requests;
    n                           NUMBER         := 0;
    g_batch_total               NUMBER         := 0;
    l_temp_id                   NUMBER         := 0;
    l_new_status                VARCHAR2(30)   := NULL;
    l_curr_status               VARCHAR2(30)   := NULL;
    l_curr_process              VARCHAR2(30)   := NULL;
    l_temp_phys_batch_id        NUMBER;
    primary_ptr                 NUMBER         := 1;
    l_dev_phase                 VARCHAR2(80);
    l_dev_status                VARCHAR2(80);
    l_request_id                NUMBER;
    l_completed_revert_count    NUMBER         := 0;
    l_completed_classify_count  NUMBER         := 0;
    l_completed_rollup_count    NUMBER         := 0;
    l_completed_populate_count  NUMBER         := 0;
    l_completed_calculate_count NUMBER         := 0;
    l_call_status               BOOLEAN;
    l_next_process              VARCHAR2(30);
    l_dummy1                    VARCHAR2(2000);
    l_dummy2                    VARCHAR2(500);
    l_dummy3                    VARCHAR2(500);
    unfinished                  BOOLEAN        := TRUE;
    l_user_id                   NUMBER(15)     := fnd_global.user_id;
    l_resp_id                   NUMBER(15)     := fnd_global.resp_id;
    l_login_id                  NUMBER(15)     := fnd_global.login_id;
    l_conc_prog_id              NUMBER(15)     := fnd_global.conc_program_id;
    l_conc_request_id           NUMBER(15)     := fnd_global.conc_request_id;
    l_prog_appl_id              NUMBER(15)     := fnd_global.prog_appl_id;
    l_sleep_time_char           VARCHAR2(30);
    l_sleep_time                NUMBER         := 180;
    l_failed_request_id         NUMBER;
    g_first_run                 VARCHAR2(1)    := 'Y';
    l_return_status             VARCHAR2(30);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_flag                      VARCHAR2(30);
    l_intelligent_flag          VARCHAR2(1);
    l_parent_request_id         NUMBER;
    l_start_date                DATE;
    l_end_date                  DATE;
    l_payee_count               NUMBER;
    l_new_request_submitted     BOOLEAN;

    CURSOR parent_request IS
      SELECT MAX(fcr.parent_request_id)
        FROM fnd_concurrent_requests fcr
       WHERE fcr.program_application_id = 283
         AND fcr.concurrent_program_id =
                           (SELECT concurrent_program_id
                              FROM fnd_concurrent_programs
                             WHERE application_id = 283 AND concurrent_program_name = 'BATCH_RUNNER')
         AND fcr.phase_code = 'C'
         AND fcr.status_code <> 'C'
         AND EXISTS(
                   SELECT 1
                     FROM cn_process_batches
                    WHERE logical_batch_id = g_logical_batch_id
                          AND physical_batch_id = fcr.argument4);

    CURSOR success_phase(p_physical_batch_id NUMBER) IS
      SELECT   fcr.argument3 phase
          FROM fnd_concurrent_requests fcr
         WHERE fcr.parent_request_id = l_parent_request_id
           AND fcr.phase_code = 'C'
           AND fcr.status_code = 'C'
           AND argument4 = p_physical_batch_id
      ORDER BY request_id DESC;

    CURSOR physical_batches IS
      SELECT DISTINCT physical_batch_id
                 FROM cn_process_batches_all
                WHERE logical_batch_id = g_logical_batch_id
             ORDER BY physical_batch_id DESC;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch2.begin'
      , 'Beginning of conc_dispatch2...'
      );
    END IF;

    cn_message_pkg.FLUSH;
    COMMIT;

    SELECT intelligent_flag, start_date, end_date
      INTO l_intelligent_flag, l_start_date, l_end_date
      FROM cn_calc_submission_batches_all
     WHERE logical_batch_id = g_logical_batch_id;

    OPEN parent_request;
    FETCH parent_request INTO l_parent_request_id;
    CLOSE parent_request;

    l_payee_count  := 0;

    SELECT COUNT(*)
      INTO l_payee_count
      FROM cn_srp_payee_assigns a
     WHERE a.start_date <= l_end_date AND(a.end_date IS NULL OR a.end_date >= l_start_date);

    -- get highest successful phase of completion for each batch
    FOR physical_batch IN physical_batches LOOP
      l_curr_process                          := NULL;

      OPEN success_phase(physical_batch.physical_batch_id);
      FETCH success_phase INTO l_curr_process;
      CLOSE success_phase;

      g_batch_total                           := g_batch_total + 1;
      l_primary_batch_stack(g_batch_total)    := physical_batch.physical_batch_id;
      l_primary_request_stack(g_batch_total)  := NULL;
      l_current_phase_stack(g_batch_total)    := l_curr_process;

      IF (l_curr_process = g_revert) THEN
        l_completed_revert_count  := l_completed_revert_count + 1;
      ELSIF(l_curr_process = g_classification) THEN
        l_completed_revert_count    := l_completed_revert_count + 1;
        l_completed_classify_count  := l_completed_classify_count + 1;
      ELSIF(l_curr_process = g_rollup) THEN
        l_completed_revert_count    := l_completed_revert_count + 1;
        l_completed_classify_count  := l_completed_classify_count + 1;
        l_completed_rollup_count    := l_completed_rollup_count + 1;
      ELSIF(l_curr_process = g_population) THEN
        l_completed_revert_count    := l_completed_revert_count + 1;
        l_completed_classify_count  := l_completed_classify_count + 1;
        l_completed_rollup_count    := l_completed_rollup_count + 1;
        l_completed_populate_count  := l_completed_populate_count + 1;
      ELSIF(l_curr_process = g_calculation) THEN
        l_completed_revert_count     := l_completed_revert_count + 1;
        l_completed_classify_count   := l_completed_classify_count + 1;
        l_completed_rollup_count     := l_completed_rollup_count + 1;
        l_completed_populate_count   := l_completed_populate_count + 1;
        l_completed_calculate_count  := l_completed_calculate_count + 1;
      END IF;
    END LOOP;

    UPDATE cn_process_batches_all
       SET trx_batch_id = l_primary_batch_stack(g_batch_total)
     WHERE physical_batch_id = l_primary_batch_stack(g_batch_total);

    COMMIT;
    -- batches should be sorted by commission_headers_count in classification/rollup phase
    n              := 1;

    IF (l_completed_revert_count = g_batch_total AND l_completed_rollup_count < g_batch_total) THEN
      FOR p_rec IN physical_batches2 LOOP
        FOR i IN 1 .. g_batch_total LOOP
          IF (l_primary_batch_stack(i) = p_rec.physical_batch_id) THEN
            l_process_order(n)  := i;
            EXIT;
          END IF;
        END LOOP;

        n  := n + 1;
      END LOOP;
    ELSE
      FOR i IN 1 .. g_batch_total LOOP
        l_process_order(n)  := i;
        n                   := n + 1;
      END LOOP;
    END IF;

    l_sleep_time_char  := fnd_profile.VALUE('CN_SLEEP_TIME');
    IF l_sleep_time_char IS NOT NULL THEN
      l_sleep_time  := TO_NUMBER(l_sleep_time_char);
    END IF;

    l_new_request_submitted := FALSE;

    WHILE unfinished LOOP
      FOR i IN 1 .. g_batch_total LOOP
        primary_ptr  := l_process_order(i);

        IF (l_primary_request_stack(primary_ptr) IS NOT NULL) THEN
          l_call_status  :=
            fnd_concurrent.get_request_status(
              request_id                   => l_primary_request_stack(primary_ptr)
            , phase                        => l_dummy1
            , status                       => l_dummy2
            , dev_phase                    => l_dev_phase
            , dev_status                   => l_dev_status
            , MESSAGE                      => l_dummy3
            );

          IF (NOT l_call_status) THEN
            l_failed_request_id   := l_primary_request_stack(primary_ptr);
            l_temp_phys_batch_id  := l_primary_batch_stack(primary_ptr);

            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
              fnd_log.STRING(
                fnd_log.level_unexpected
              , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch2.request_status'
              , 'Request ' || l_failed_request_id || ' failed (batch_id = ' || l_temp_phys_batch_id
              );
            END IF;

            cn_message_pkg.DEBUG('Concurrent request completed with error (request ID='
              || l_failed_request_id || ')');
            cn_message_pkg.DEBUG('(physical batch ID=' || l_temp_phys_batch_id || ')');
            fnd_file.put_line(
              fnd_file.LOG
            , 'Conc_dispatch2: Request completed with error for ' || l_failed_request_id
            );
            fnd_file.put_line(
              fnd_file.LOG
            , 'Conc_dispatch2: Request failed for physical batch' || l_temp_phys_batch_id
            );
            RAISE conc_fail;
          END IF;

          IF l_dev_phase = 'COMPLETE' THEN
            l_failed_request_id                   := l_primary_request_stack(primary_ptr);
            l_primary_request_stack(primary_ptr)  := NULL;

            IF (l_current_phase_stack(primary_ptr) = g_revert) THEN
              l_completed_revert_count  := l_completed_revert_count + 1;
            ELSIF(l_current_phase_stack(primary_ptr) = g_classification) THEN
              l_completed_classify_count  := l_completed_classify_count + 1;
            ELSIF(l_current_phase_stack(primary_ptr) = g_rollup) THEN
              l_completed_rollup_count  := l_completed_rollup_count + 1;

              -- upon completion of rollup phase, swith the processing order back to lines_total-based
              IF (l_completed_rollup_count = g_batch_total) THEN
                FOR x IN 1 .. g_batch_total LOOP
                  l_process_order(x)  := x;
                END LOOP;

                EXIT;
              END IF;
            ELSIF(l_current_phase_stack(primary_ptr) = g_population) THEN
              l_completed_populate_count  := l_completed_populate_count + 1;
            ELSIF(l_current_phase_stack(primary_ptr) = g_calculation) THEN
              l_completed_calculate_count  := l_completed_calculate_count + 1;
            END IF;

            IF l_dev_status IN('ERROR', 'TERMINATING', 'TERMINATED', 'DELETED') THEN
              l_temp_phys_batch_id  := l_primary_batch_stack(primary_ptr);

              IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING(
                  fnd_log.level_error
                , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch2.request_status'
                , 'Request ' || l_failed_request_id || ' failed (batch_id = '
                  || l_temp_phys_batch_id
                );
              END IF;

              cn_message_pkg.DEBUG('Concurrent request completed with error (request ID='
                || l_failed_request_id || ')');
              cn_message_pkg.DEBUG('(physical batch ID=' || l_temp_phys_batch_id || ')');
              fnd_file.put_line(
                fnd_file.LOG
              , 'Conc_dispatch2: Request completed with error for ' || l_failed_request_id
              );
              fnd_file.put_line(
                fnd_file.LOG
              , 'Conc_dispatch2: Request failed for physical_batch' || l_temp_phys_batch_id
              );
              RAISE conc_fail;
            END IF;   -- If error
          END IF;   -- If complete
        END IF;   -- If request_id not null

        -- if waiting to proceed, then check the conditions for moving on
        IF (l_primary_request_stack(primary_ptr) IS NULL) THEN
          l_curr_process  := NULL;

          -- check whether the current batch can start the next phase
          IF (l_current_phase_stack(primary_ptr) = g_revert) THEN
            -- go to classification phase directly
            l_curr_process  := l_current_phase_stack(primary_ptr);
            next_process(x_physical_process => l_curr_process);
          ELSIF(l_current_phase_stack(primary_ptr) = g_classification) THEN
            -- if all batches are done with revert phase, then start rollup phase
            IF (l_completed_revert_count = g_batch_total) THEN
              IF (l_intelligent_flag = 'Y') THEN
                -- for intelligent calculation, the first batch should complete rollup phase
                -- before the other batches do
                IF (l_completed_rollup_count = 0 AND primary_ptr = 1) THEN
                  l_curr_process  := l_current_phase_stack(primary_ptr);
                  next_process(x_physical_process => l_curr_process);
                ELSIF(l_completed_rollup_count > 0) THEN
                  l_curr_process  := l_current_phase_stack(primary_ptr);
                  next_process(x_physical_process => l_curr_process);
                END IF;
              ELSE
                l_curr_process  := l_current_phase_stack(primary_ptr);
                next_process(x_physical_process => l_curr_process);
              END IF;
            END IF;
          ELSIF(l_current_phase_stack(primary_ptr) = g_rollup) THEN
            -- if all batches are done with rollup phase, then start population phase
            IF (l_completed_rollup_count = g_batch_total) THEN
              l_curr_process  := l_current_phase_stack(primary_ptr);
              next_process(x_physical_process => l_curr_process);
            END IF;
          ELSIF(l_current_phase_stack(primary_ptr) = g_population) THEN
            IF l_payee_count > 0 THEN
              IF (
                     (
                          primary_ptr = g_batch_total
                      AND l_completed_calculate_count =(g_batch_total - 1)
                     )
                  OR (primary_ptr < g_batch_total)
                 ) THEN
                l_curr_process  := l_current_phase_stack(primary_ptr);
                next_process(x_physical_process => l_curr_process);
              END IF;
            ELSE
              l_curr_process  := l_current_phase_stack(primary_ptr);
              next_process(x_physical_process => l_curr_process);
            END IF;
          ELSIF(l_current_phase_stack(primary_ptr) = g_calculation) THEN
            IF (l_completed_calculate_count = g_batch_total) THEN
              cn_message_pkg.DEBUG('All requests complete phase ' || g_logical_process);
              unfinished  := FALSE;
            END IF;
          END IF;

          -- submit request for next phase if all the conditions to proceed are met
          IF (l_curr_process IS NOT NULL) THEN
            conc_submit(
              x_conc_program               => 'BATCH_RUNNER'
            , x_parent_proc_audit_id       => x_parent_proc_audit_id
            , x_logical_process            => g_logical_process
            , x_physical_process           => l_curr_process
            , x_physical_batch_id          => l_primary_batch_stack(primary_ptr)
            , x_request_id                 => l_temp_id
            );
            l_primary_request_stack(primary_ptr)  := l_temp_id;
            l_current_phase_stack(primary_ptr)    := l_curr_process;
            l_new_request_submitted               := TRUE;

            cn_message_pkg.debug(
                'Moving Physical Batch#' || l_primary_batch_stack(primary_ptr) ||
                ' to next process ' || l_curr_process || ' Request = ' || l_temp_id
              );

            IF (l_temp_id = 0 OR l_temp_id IS NULL) THEN
              l_temp_phys_batch_id  := l_primary_batch_stack(primary_ptr);
              l_failed_request_id   := l_temp_id;
              RAISE conc_fail;
            END IF;
          END IF;   -- If l_curr_process is not null
        END IF;   -- If request_id is null
      END LOOP;   -- for primary_pointer in 1..g_batch_total

      /*
       * Bug#7265394 - Not sure whats been implemented here.
       * This can lead to bypassing SLEEP and calling FND_CONCURRENT.GET_REQUEST_STATUS
       * continuously. Therefore rewrote the logic in a different way.
       *
      IF (l_completed_revert_count = g_batch_total AND l_completed_classify_count = 0) THEN
        NULL;
      ELSIF(l_completed_classify_count = g_batch_total AND l_completed_rollup_count = 0) THEN
        NULL;
      ELSIF(l_completed_rollup_count = g_batch_total AND l_completed_populate_count = 0) THEN
        NULL;
      ELSIF(l_completed_populate_count = g_batch_total AND l_completed_calculate_count = 0) THEN
        NULL;
      ELSE
        DBMS_LOCK.sleep(l_sleep_time);
      END IF;
      */

      cn_message_pkg.debug(
           'Check whether we can sleep for sometime to get the requests completed...'
        || ' Batch Total = ' || g_batch_total
        || ' : Reverted = ' || l_completed_revert_count
        || ' : Classified = ' || l_completed_classify_count
        || ' : Rolled = ' || l_completed_rollup_count
        || ' : Populated = ' || l_completed_populate_count
        || ' : Calculated = ' || l_completed_calculate_count
        );

      IF l_new_request_submitted THEN
        cn_message_pkg.debug('A new request has been submitted.. Lets check once more whether any other request has completed.');
        l_new_request_submitted := FALSE;
      ELSE
        cn_message_pkg.debug('There is no change evident in this iteration. Therefore sleep for ' || l_sleep_time);
        DBMS_LOCK.sleep(l_sleep_time);
      END IF;

    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch2.end'
      , 'End of conc_dispatch.'
      );
    END IF;
  EXCEPTION
    WHEN conc_fail THEN
      fnd_file.put_line(fnd_file.LOG, 'conc_fail exception in cn_proc_batches_pkg.conc_dispatch');
      update_error(l_temp_phys_batch_id);

      -- canceling running/pending requests
      IF (l_primary_request_stack.COUNT > 0) THEN
        FOR i IN l_primary_request_stack.FIRST .. l_primary_request_stack.LAST LOOP
          IF (l_primary_request_stack(i) > 0) THEN
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
              fnd_log.STRING(
                fnd_log.level_exception
              , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch2.exception'
              , 'Cancelling request: ' || l_primary_request_stack(i)
              );
            END IF;

            l_call_status  := fnd_concurrent.cancel_request(l_primary_request_stack(i), l_dummy1);
            cn_message_pkg.DEBUG(
              'Cancelling request (ID=' || l_primary_request_stack(i) || ' Status=' || l_dummy1
              || ')'
            );
          END IF;
        END LOOP;
      END IF;

      cn_message_pkg.DEBUG('Concurrent request failed (physical batch ID=' || l_temp_phys_batch_id
        || ')');
      cn_message_pkg.end_batch(x_parent_proc_audit_id);
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.conc_dispatch2.exception'
        , SQLERRM
        );
      END IF;

      fnd_file.put_line(fnd_file.LOG, 'unexpected exception in cn_proc_batches_pkg.conc_dispatch');
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.conc_dispatch2:');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);
      RAISE;
  END conc_dispatch2;

  -- Procedure Name
  --
  -- Purpose
  --   Accept a logical process name and logical batch and execute all
  --   required physical processes.
  --
  -- Notes
  --   We must wait for a process to complete across the entire logical batch
  --   before executing the next process othwerwise we could start to
  --   calculate before classifying
  PROCEDURE seq_dispatch(x_parent_proc_audit_id NUMBER) IS
    l_dummy        VARCHAR2(80);
    finished       BOOLEAN      := FALSE;
    l_new_status   VARCHAR2(30) := NULL;
    l_curr_process VARCHAR2(30) := NULL;
    l_new_process  VARCHAR2(30) := NULL;
    l_count        NUMBER       := 0;
    g_batch_total  NUMBER;

    CURSOR bc IS
      SELECT COUNT(DISTINCT physical_batch_id)
        FROM cn_process_batches_all
       WHERE logical_batch_id = g_logical_batch_id AND status_code = 'IN_USE';
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.seq_dispatch.begin'
      , 'Beginning of seq_dispatch...'
      );
    END IF;

    OPEN bc;
    FETCH bc INTO g_batch_total;
    CLOSE bc;

    flood_rev_classes;
    cn_message_pkg.FLUSH;
    COMMIT;

    WHILE NOT finished LOOP
      IF g_calc_type = 'BONUS' THEN
        IF l_curr_process IS NULL THEN
          l_curr_process  := g_revert;
        ELSE
          l_curr_process  := g_calculation;   --g_logical_process;
        END IF;
      ELSE
        next_process(x_physical_process => l_curr_process);
      END IF;

      -- Any batch with an 'ERROR' status will not be selected
      FOR physical_rec IN physical_batches LOOP
        IF (l_curr_process = g_calculation) THEN
          l_count  := l_count + 1;

          IF (l_count = g_batch_total) THEN
            UPDATE cn_process_batches_all
               SET trx_batch_id = physical_rec.physical_batch_id
             WHERE physical_batch_id = physical_rec.physical_batch_id;

            COMMIT;
          END IF;
        END IF;

        runner(
          errbuf                       => l_dummy
        , retcode                      => l_dummy
        , p_parent_proc_audit_id       => x_parent_proc_audit_id
        , p_logical_process            => g_logical_process
        , p_physical_process           => l_curr_process
        , p_physical_batch_id          => physical_rec.physical_batch_id
        );
      END LOOP;

      IF g_logical_process = l_curr_process THEN
        finished  := TRUE;
      END IF;
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.seq_dispatch.end'
      , 'End of seq_dispatch.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.seq_dispatch.exception', SQLERRM);
      END IF;

      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches.seq_dispatch:');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);
      RAISE;
  END seq_dispatch;

  /* ----------------------------------------------------------------------------
   |                         Public Routines                                    |
   ----------------------------------------------------------------------------*/
  PROCEDURE calculate_batch(
    errbuf              OUT NOCOPY    VARCHAR2
  , retcode             OUT NOCOPY    NUMBER
  , p_calc_sub_batch_id IN            cn_calc_submission_batches.calc_sub_batch_id%TYPE
  ) IS
    l_return_status    VARCHAR2(30);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_process_audit_id NUMBER;
    l_org_id           NUMBER;
  BEGIN
    retcode  := 0;   -- success = 0, warning = 1, fail = 2

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.calculate_batch.begin'
      , 'Beginning of calculate_batch...'
      );
    END IF;

    SELECT org_id
      INTO l_org_id
      FROM cn_calc_submission_batches
     WHERE calc_sub_batch_id = p_calc_sub_batch_id;

    cn_message_pkg.begin_batch(
      x_process_type               => 'CALCULATION'
    , x_parent_proc_audit_id       => l_process_audit_id
    , x_process_audit_id           => l_process_audit_id
    , x_request_id                 => fnd_global.conc_request_id
    , p_org_id                     => l_org_id
    );
    fnd_file.put_line(fnd_file.LOG, 'Beginning of calculate_batch...');
    cn_message_pkg.DEBUG('Beginning of calculate_batch...');

    UPDATE cn_calc_submission_batches_all
       SET process_audit_id = l_process_audit_id
     WHERE calc_sub_batch_id = p_calc_sub_batch_id;

    COMMIT;
    cn_calc_submission_pvt.calculate(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_true
    , p_validation_level           => fnd_api.g_valid_level_full
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_calc_sub_batch_id          => p_calc_sub_batch_id
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      FOR l_counter IN 1 .. l_msg_count LOOP
        l_msg_data  := fnd_msg_pub.get(p_msg_index => l_counter, p_encoded => fnd_api.g_false);
        fnd_file.put_line(fnd_file.LOG, l_msg_data);
        cn_message_pkg.DEBUG(l_msg_data);
      END LOOP;

      retcode  := 2;
      errbuf   := l_msg_data;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.calculate_batch.end'
      , 'End of calculate_batch.'
      );
    END IF;

    fnd_file.put_line(fnd_file.LOG, 'End of the calculation process.');
    cn_message_pkg.DEBUG('End of the calculation process.');
    cn_message_pkg.end_batch(l_process_audit_id);
  EXCEPTION
    WHEN OTHERS THEN
      retcode  := 2;
      errbuf   := SQLERRM;

      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.calculate_batch.exception'
        , SQLERRM
        );
      END IF;

      cn_message_pkg.end_batch(l_process_audit_id);
  END calculate_batch;

  PROCEDURE calc(
    errbuf             OUT NOCOPY VARCHAR2
  , retcode            OUT NOCOPY NUMBER
  , p_batch_name                  VARCHAR2
  , p_start_date                  DATE
  , p_end_date                    DATE
  , p_calc_type                   VARCHAR2
  , p_salesrep_option             VARCHAR2
  , p_hierarchy_flag              VARCHAR2
  , p_intelligent_flag            VARCHAR2
  , p_interval_type_id            NUMBER
  , p_salesrep_id                 NUMBER
  , p_quota_id                    NUMBER
  ) IS
    l_calc_sub_batch_id   NUMBER(15);
    l_calc_sub_entry_id   NUMBER(15);
    l_process_audit_id    NUMBER(15);
    l_process_status_code VARCHAR2(30);
    l_error_message       VARCHAR2(200);
    l_counter             NUMBER;
    l_org_id              NUMBER;

    CURSOR l_chk_start_date_csr IS
      SELECT 1
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM cn_acc_period_statuses_v
                     WHERE period_status = 'O' AND org_id = l_org_id AND p_start_date >= start_date);

    CURSOR l_chk_end_date_csr IS
      SELECT 1
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM cn_acc_period_statuses_v
                     WHERE period_status = 'O' AND org_id = l_org_id AND p_end_date <= end_date);

    CURSOR l_batch_name_csr IS
      SELECT 1
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM cn_calc_submission_batches_all
                     WHERE NAME = p_batch_name AND org_id = l_org_id);

    l_incomplete_plan     BOOLEAN       := FALSE;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.calc.begin'
      , 'Beginning of concurrent program calc ...'
      );
    END IF;

    fnd_file.put_line(fnd_file.LOG, 'Beginning of concurrent program calc ... ');
    -- Concurrent Manager will call set_policy_context('S', user_selected_org)
    l_org_id             := mo_global.get_current_org_id;

    -- check uniqueness of batch name
    OPEN l_batch_name_csr;
    FETCH l_batch_name_csr INTO l_counter;

    IF l_batch_name_csr%FOUND THEN
      CLOSE l_batch_name_csr;

      fnd_message.set_name('CN', 'CN_CALC_SUB_EXISTS');
      fnd_message.set_token('BATCH_NAME'
      , cn_api.get_lkup_meaning('NAME', 'CALC_SUBMISSION_OBJECT_TYPE'));
      fnd_file.put_line(fnd_file.LOG, fnd_message.get);

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
        fnd_log.MESSAGE(fnd_log.level_error, 'cn.plsql.cn_proc_batches_pkg.calc.validation', TRUE);
      END IF;

      RAISE ABORT;
    END IF;

    CLOSE l_batch_name_csr;

    -- check the validility of p_start_date and p_end_date
    IF p_start_date > p_end_date THEN
      fnd_message.set_name('CN', 'CN_INVALID_DATE_RANGE');
      fnd_file.put_line(fnd_file.LOG, fnd_message.get);

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
        fnd_log.MESSAGE(fnd_log.level_error, 'cn.plsql.cn_proc_batches_pkg.calc.validation', TRUE);
      END IF;

      RAISE ABORT;
    ELSE
      OPEN l_chk_start_date_csr;
      FETCH l_chk_start_date_csr INTO l_counter;

      IF l_chk_start_date_csr%NOTFOUND THEN
        fnd_message.set_name('CN', 'CN_CALC_SUB_OPEN_DATE');
        fnd_message.set_token('DATE', p_start_date);
        fnd_file.put_line(fnd_file.LOG, fnd_message.get);

        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
          fnd_log.MESSAGE(fnd_log.level_error, 'cn.plsql.cn_proc_batches_pkg.calc.validation', TRUE);
        END IF;

        RAISE ABORT;
      END IF;

      CLOSE l_chk_start_date_csr;

      OPEN l_chk_end_date_csr;
      FETCH l_chk_end_date_csr INTO l_counter;

      IF l_chk_end_date_csr%NOTFOUND THEN
        fnd_message.set_name('CN', 'CN_CALC_SUB_OPEN_DATE');
        fnd_message.set_token('DATE', p_end_date);
        fnd_file.put_line(fnd_file.LOG, fnd_message.get);

        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
          fnd_log.MESSAGE(fnd_log.level_error, 'cn.plsql.cn_proc_batches_pkg.calc.validation'
          , TRUE);
        END IF;

        RAISE ABORT;
      END IF;

      CLOSE l_chk_end_date_csr;
    END IF;

    IF p_salesrep_option = 'USER_SPECIFY' AND p_salesrep_id IS NULL THEN
      fnd_message.set_name('CN', 'CN_CALC_NO_SALESREP');
      fnd_file.put_line(fnd_file.LOG, fnd_message.get);

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
        fnd_log.MESSAGE(fnd_log.level_error, 'cn.plsql.cn_proc_batches_pkg.calc.validation', TRUE);
      END IF;

      RAISE ABORT;
    END IF;

    l_calc_sub_batch_id  := cn_calc_sub_batches_pkg.get_calc_sub_batch_id;
    cn_calc_sub_batches_pkg.begin_record
                                    (
      p_operation                  => 'INSERT'
    , p_calc_sub_batch_id          => l_calc_sub_batch_id
    , p_name                       => p_batch_name
    , p_start_date                 => p_start_date
    , p_end_date                   => p_end_date
    , p_calc_type                  => p_calc_type
    , p_salesrep_option            => p_salesrep_option
    , p_hierarchy_flag             => 'N'
    ,   --p_hierarchy_flag,
      p_concurrent_flag            => 'Y'
    ,   -- always not on-line, so concurrently
      p_intelligent_flag           => p_intelligent_flag
    , p_status                     => 'INCOMPLETE'
    , p_interval_type_id           => p_interval_type_id
    , p_org_id                     => l_org_id
    );

    IF p_salesrep_option = 'USER_SPECIFY' THEN
      l_calc_sub_entry_id  := cn_calc_sub_entries_pkg.get_calc_sub_entry_id;
      cn_calc_sub_entries_pkg.begin_record(
        p_operation                  => 'INSERT'
      , p_calc_sub_batch_id          => l_calc_sub_batch_id
      , p_calc_sub_entry_id          => l_calc_sub_entry_id
      , p_salesrep_id                => p_salesrep_id
      , p_hierarchy_flag             => p_hierarchy_flag
      , p_org_id                     => l_org_id
      );
    END IF;

    COMMIT;

    IF (fnd_log.level_event >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_event
      , 'cn.plsql.cn_proc_batches_pkg.calc.submission'
      , 'Successfully created submission records.'
      );
    END IF;

    IF find_srp_incomplete_plan(l_calc_sub_batch_id) THEN
      fnd_file.put_line(fnd_file.LOG
      , 'Abort the process because there is rep with incomplete comp plans.');
      RAISE ABORT;
    ELSE
      calculation_submission(
        p_calc_sub_batch_id          => l_calc_sub_batch_id
      , x_process_audit_id           => l_process_audit_id
      , x_process_status_code        => l_process_status_code
      );
    END IF;

    IF (l_process_status_code = 'FAIL') THEN
      retcode  := 2;
      errbuf   := 'Calculation fails';
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.calc.end'
      , 'End of concurrent program calc.'
      );
    END IF;
  EXCEPTION
    WHEN fnd_file.utl_file_error THEN
      retcode  := 2;
      errbuf   := SUBSTR(fnd_message.get, 1, 254);
    WHEN ABORT THEN
      retcode  := 2;
      errbuf   := 'Please check request log file for further information. ';

      IF l_chk_start_date_csr%ISOPEN THEN
        CLOSE l_chk_start_date_csr;
      END IF;

      IF l_chk_end_date_csr%ISOPEN THEN
        CLOSE l_chk_end_date_csr;
      END IF;
    WHEN OTHERS THEN
      retcode  := 2;
      errbuf   := SQLERRM;
  END calc;

  PROCEDURE calc_curr(
    errbuf             OUT NOCOPY VARCHAR2
  , retcode            OUT NOCOPY NUMBER
  , p_batch_name                  VARCHAR2
  , p_start_date                  VARCHAR2
  , p_end_date                    VARCHAR2
  , p_calc_type                   VARCHAR2
  , p_salesrep_option             VARCHAR2
  , p_hierarchy_flag              VARCHAR2
  , p_intelligent_flag            VARCHAR2
  , p_salesrep_id                 NUMBER
  ) IS
  BEGIN
    -- this is a wrapper around the calc procedure to be called from
    -- a concurrent program.  it eliminates the obsolete variables
    -- p_interval_type_id and p_quota_id.  it also converts the dates
    -- from FND_STANDARD_DATE
    calc(
      errbuf                       => errbuf
    , retcode                      => retcode
    , p_batch_name                 => p_batch_name
    , p_start_date                 => fnd_date.canonical_to_date(p_start_date)
    , p_end_date                   => fnd_date.canonical_to_date(p_end_date)
    , p_calc_type                  => p_calc_type
    , p_salesrep_option            => p_salesrep_option
    , p_hierarchy_flag             => p_hierarchy_flag
    , p_intelligent_flag           => p_intelligent_flag
    , p_salesrep_id                => p_salesrep_id
    , p_interval_type_id           => -1000
    ,   -- means 'Period'
      p_quota_id                   => NULL
    );
  END calc_curr;

  PROCEDURE collection(
    errbuf         OUT NOCOPY VARCHAR2
  , retcode        OUT NOCOPY NUMBER
  , p_start_date              DATE
  , p_end_date                DATE
  , p_salesrep_id             NUMBER
  , p_comp_plan_id            NUMBER
  ) IS
    dummy      NUMBER;
    dummy_char VARCHAR2(30);
  BEGIN
    cn_proc_batches_pkg.main(
      p_concurrent_flag            => 'Y'
    , p_process_name               => 'COLLECTION'
    , p_logical_batch_id           => NULL
    , p_start_date                 => p_start_date
    , p_end_date                   => p_end_date
    , p_salesrep_id                => p_salesrep_id
    , p_comp_plan_id               => p_comp_plan_id
    , x_process_audit_id           => dummy
    , x_process_status_code        => dummy_char
    );
  END collection;

  -- Procedure Name
  --   Runner (PUBLIC Concurrent Program)
  -- Purpose
  --   For each distinct physical batch lock the impacted srp_periods and
  --   execute collection, classification, roll, populate or calculation
  --   on the cn_trx records identified by the physical batch.
  --   If the srp_periods cannot be locked the produre executes successfully
  --   but doesn't update the srp_period status to the new one.
  --   Commits after each batch to help control rollback segment problems
  PROCEDURE runner(
    errbuf                 OUT NOCOPY VARCHAR2
  , retcode                OUT NOCOPY NUMBER
  , p_parent_proc_audit_id            NUMBER
  , p_logical_process                 VARCHAR2
  , p_physical_process                VARCHAR2
  , p_physical_batch_id               NUMBER
  , p_salesrep_id                     NUMBER := NULL
  , p_start_date                      DATE := NULL
  , p_end_date                        DATE := NULL
  , p_cls_rol_flag                    VARCHAR2 := NULL
  ) IS
    l_curr_status         VARCHAR2(30);
    l_new_status          VARCHAR2(30);
    l_tries               NUMBER(1);
    l_request_id          NUMBER(15)     := NULL;
    l_cls_total           NUMBER;
    l_xcls_total          NUMBER;
    l_process_audit_id    NUMBER(15);
    l_org_id              NUMBER;
    dummy                 NUMBER(1);
    l_counter             NUMBER;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_return_status       VARCHAR2(30);
    l_period_set_id       NUMBER;
    l_period_type_id      NUMBER;
    l_calc_from_period_id NUMBER;
    l_calc_to_period_id   NUMBER;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.runner.begin'
      ,    'Beginning of batch runner '
        || p_physical_batch_id
        || ' in the phase of '
        || p_physical_process
        || ' at '
        || TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS')
      );
    END IF;

    fnd_file.put_line(fnd_file.LOG
    , 'Inside batch runner: ' || TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS'));

    SELECT org_id
      INTO l_org_id
      FROM cn_process_batches_all
     WHERE physical_batch_id = p_physical_batch_id AND ROWNUM = 1;

    l_request_id  := fnd_global.conc_request_id;

    IF l_request_id <> -1 THEN
      cn_message_pkg.begin_batch(
        x_process_type               => 'CALCULATION'
      , x_parent_proc_audit_id       => p_parent_proc_audit_id
      , x_process_audit_id           => l_process_audit_id
      , x_request_id                 => fnd_global.conc_request_id
      , p_org_id                     => l_org_id
      );
    END IF;

    cn_message_pkg.DEBUG(
      'Start batch runner (phase=' || p_physical_process || ', batch ID=' || p_physical_batch_id
      || ')'
    );
    cn_proc_batches_pkg.process_status(
      x_physical_process           => p_physical_process
    , x_curr_status                => l_curr_status
    , x_new_status                 => l_new_status
    );

    -- This is the hook if we need to add the collection process
    IF p_physical_process = g_collection THEN
      NULL;
    --cn_collection_pkg.collect(p_physical_batch_id);
    ELSIF p_physical_process = g_load THEN
      cn_transaction_load_pkg.load_worker(
        p_physical_batch_id          => p_physical_batch_id
      , p_salesrep_id                => p_salesrep_id
      , p_start_date                 => p_start_date
      , p_end_date                   => p_end_date
      , p_cls_rol_flag               => p_cls_rol_flag
      );
    ELSIF(p_physical_process = g_post) THEN
      cn_posting_pvt.post_worker
              (
        p_parent_proc_audit_id       => p_parent_proc_audit_id
      , p_posting_batch_id           => p_salesrep_id
      ,   -- use p_salesrep_id to pass in posting_batch_id
        p_physical_batch_id          => p_physical_batch_id
      , p_start_date                 => p_start_date
      , p_end_date                   => p_end_date
      );
    ELSIF p_physical_process = g_revert THEN
      cn_formula_common_pkg.revert_batch(p_physical_batch_id);
    ELSIF p_physical_process = g_classification THEN
      cn_calc_classify_pvt.classify_batch(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_true
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_physical_batch_id          => p_physical_batch_id
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        cn_message_pkg.DEBUG('Exception occurs in classification process:');

        FOR l_counter IN 1 .. l_msg_count LOOP
          cn_message_pkg.DEBUG(fnd_msg_pub.get(p_msg_index => l_counter
            , p_encoded                    => fnd_api.g_false));
        END LOOP;

        RAISE api_call_failed;
      END IF;
    ELSIF p_physical_process = g_rollup THEN
      cn_calc_rollup_pvt.rollup_batch(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_true
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_physical_batch_id          => p_physical_batch_id
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        cn_message_pkg.DEBUG('Exception occurs in rollup phase:');

        FOR l_counter IN 1 .. l_msg_count LOOP
          cn_message_pkg.DEBUG(fnd_msg_pub.get(p_msg_index => l_counter
            , p_encoded                    => fnd_api.g_false));
        END LOOP;

        RAISE api_call_failed;
      END IF;
    ELSIF p_physical_process = g_population THEN
      cn_calc_populate_pvt.populate_batch(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_true
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_physical_batch_id          => p_physical_batch_id
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        cn_message_pkg.DEBUG('Exception occurs in population phase:');

        FOR l_counter IN 1 .. l_msg_count LOOP
          cn_message_pkg.DEBUG(fnd_msg_pub.get(p_msg_index => l_counter
            , p_encoded                    => fnd_api.g_false));
        END LOOP;

        RAISE api_call_failed;
      END IF;
    ELSIF p_physical_process = g_calculation THEN
      cn_global_var.initialize_instance_info(l_org_id);
      cn_formula_common_pkg.calculate_batch(p_physical_batch_id);
    END IF;

    cn_message_pkg.DEBUG(
         'Complete batch runner (phase='
      || p_physical_process
      || ', batch ID='
      || p_physical_batch_id
      || ')'
    );

    IF ((p_physical_process = g_load) AND(p_cls_rol_flag = 'N' OR p_cls_rol_flag IS NULL)) THEN
      NULL;   -- do not update processing_status_code
    ELSIF(p_physical_process IN(g_revert, g_classification, g_rollup, g_population, g_calculation)) THEN
      -- raise cn_srp_intel_periods.processing_status_code from 'CLEAN' to 'NOT CLEAN'
      SELECT period_set_id
           , period_type_id
        INTO l_period_set_id
           , l_period_type_id
        FROM cn_repositories_all
       WHERE org_id = l_org_id;

      SELECT MAX(period_id)
           , MAX(end_period_id)
        INTO l_calc_from_period_id
           , l_calc_to_period_id
        FROM cn_process_batches_all
       WHERE physical_batch_id = p_physical_batch_id;

      UPDATE cn_srp_intel_periods_all
         SET processing_status_code =
               DECODE(
                 p_physical_process
               , g_revert, g_reverted
               , g_classification, g_classified
               , g_rollup, g_rolled_up
               , g_population, g_populated
               , g_calculation, g_calculated
               , g_unclassified
               )
       WHERE (salesrep_id, period_id) IN(
               SELECT batch.salesrep_id
                    , per.period_id
                 FROM cn_process_batches_all batch, cn_period_statuses_all per
                WHERE batch.physical_batch_id = p_physical_batch_id
                  AND per.period_id BETWEEN batch.period_id AND batch.end_period_id
                  AND per.org_id = batch.org_id
                  AND per.period_id BETWEEN l_calc_from_period_id AND l_calc_to_period_id
                  AND per.period_set_id = l_period_set_id
                  AND per.period_type_id = l_period_type_id);
    END IF;

    cn_message_pkg.FLUSH;
    COMMIT;

    -- If run as a conc program it will have its own process audit id
    -- and request id therefore we need to give info on the process
    IF l_request_id <> -1 THEN
      cn_message_pkg.end_batch(l_process_audit_id);
    END IF;

    retcode       := 0;
    errbuf        := 'Batch runner completes successfully.';

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.runner.end'
      ,    'End of batch runner '
        || p_physical_batch_id
        || 'at '
        || TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS')
      );
    END IF;

    cn_message_pkg.DEBUG('Time is ' || TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.LOG, 'Time is ' || TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS'));
  EXCEPTION
    WHEN api_call_failed THEN
      retcode  := 2;
      errbuf   := SUBSTR(fnd_message.get, 1, 254);

      IF (l_msg_count > 0) THEN
        FOR l_counter IN 1 .. l_msg_count LOOP
          fnd_file.put_line(fnd_file.LOG
          , fnd_msg_pub.get(p_msg_index => l_counter, p_encoded => fnd_api.g_false));
        END LOOP;
      END IF;

      cn_message_pkg.rollback_errormsg_commit('Exception occurs in batch runner (ID='
        || p_physical_batch_id || ')');
      update_error(p_physical_batch_id);

      -- if concurrent program, commit and close log file
      -- if sequential calcualtion, commit and leave log file open
      IF l_request_id <> -1 THEN
        cn_message_pkg.end_batch(l_process_audit_id);
      ELSE
        COMMIT;
      END IF;
    WHEN OTHERS THEN
      -- Return to concurrent manager with error. Xinyang Fan 4/13/98
      retcode  := 2;
      errbuf   := SQLERRM;
      -- to make sure we record the updates made by update_error
      -- we roll back first
      cn_message_pkg.DEBUG('Exception occurs in batch runner (ID=' || p_physical_batch_id || ')');
      cn_message_pkg.rollback_errormsg_commit(errbuf);
      update_error(p_physical_batch_id);

      -- if concurrent program, commit and close log file
      -- if sequential calcualtion, commit and leave log file open
      IF l_request_id <> -1 THEN
        cn_message_pkg.end_batch(l_process_audit_id);
      ELSE
        COMMIT;
      END IF;

      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(fnd_log.level_unexpected, 'cn.plsql.cn_proc_batches_pkg.runner.exception'
        , SQLERRM);
      END IF;
  END runner;

  -- Check if the period submitted for calc is covered by one or more rulesets.
  -- NOTE: it does not check for the validity of the ruleset. That is done by validate_ruleset_status
  PROCEDURE validate_ruleset_coverage(
    p_start_date            DATE
  , p_end_date              DATE
  , x_covered    OUT NOCOPY BOOLEAN
  , p_org_id                NUMBER
  ) IS
    CURSOR ruleset_cur IS
      SELECT   ruleset_id
             , start_date
             , NVL(end_date, p_end_date) end_date
          FROM cn_rulesets_all_b
         WHERE org_id = p_org_id
           AND (
                   (start_date <= p_start_date AND NVL(end_date, p_start_date) >= p_start_date)
                OR (start_date BETWEEN p_start_date AND p_end_date)
               )
      ORDER BY start_date;

    l_cur_end_date DATE := p_start_date;
  BEGIN
    x_covered  := FALSE;

    FOR ruleset IN ruleset_cur LOOP
      IF (ruleset.start_date <= l_cur_end_date) OR(ruleset.start_date =(l_cur_end_date + 1)) THEN
        l_cur_end_date  := ruleset.end_date;
      ELSE
        x_covered  := FALSE;
        EXIT;
      END IF;

      IF ruleset.end_date >= p_end_date THEN
        x_covered  := TRUE;
        EXIT;
      END IF;
    END LOOP;

    IF x_covered = FALSE THEN
      cn_message_pkg.DEBUG(
           'No classification ruleset is defined for the period from '
        || p_start_date
        || ' to '
        || p_end_date
      );
    END IF;
  END validate_ruleset_coverage;

  FUNCTION validate_ruleset_status(p_start_date DATE, p_end_date DATE, p_org_id NUMBER)
    RETURN BOOLEAN IS
    CURSOR l_rulesets_csr IS
      SELECT ruleset_id
           , NAME
           , ruleset_status
           , start_date
           , end_date
        FROM cn_rulesets_all_vl
       WHERE org_id = p_org_id
         AND start_date <= p_end_date
         AND p_start_date <= NVL(end_date, p_end_date)
         AND module_type = 'REVCLS';

    CURSOR l_chk_rule_package_csr(l_pkg_name user_objects.object_name%TYPE) IS
      SELECT COUNT(*)
        FROM user_objects ob
       WHERE ob.object_name = l_pkg_name AND ob.object_type = 'PACKAGE BODY';

    cached_org_id     INTEGER;
    cached_org_append VARCHAR2(100);
    l_cls_pkg_name    user_objects.object_name%TYPE;
    l_error_ctr       NUMBER                          := 0;
    l_counter         NUMBER                          := 0;
    x_covered         BOOLEAN                         := FALSE;
  BEGIN
    -- check to make sure the specified dates are covered by one or more rulesets
    validate_ruleset_coverage(p_start_date, p_end_date, x_covered, p_org_id);

    IF x_covered = FALSE THEN
      RETURN FALSE;
    END IF;

    cached_org_id  := p_org_id;

    IF cached_org_id = -99 THEN
      cached_org_append  := '_MINUS99';
    ELSE
      cached_org_append  := '_' || cached_org_id;
    END IF;

    FOR l_set IN l_rulesets_csr LOOP
      IF l_set.ruleset_status IN('UNSYNC', 'INSTINPG', 'INSTFAIL', 'CONCFAIL') THEN
        cn_message_pkg.DEBUG('Please synchronize ruleset (Name=' || l_set.NAME || ')');
        l_error_ctr  := 1;
      ELSE
        l_cls_pkg_name  := 'cn_clsfn_' || TO_CHAR(ABS(l_set.ruleset_id)) || cached_org_append;

        OPEN l_chk_rule_package_csr(UPPER(l_cls_pkg_name));
        FETCH l_chk_rule_package_csr INTO l_counter;
        CLOSE l_chk_rule_package_csr;

        IF l_counter = 0 THEN
          cn_message_pkg.DEBUG('Please synchronize ruleset (name=' || l_set.NAME || ')');
          cn_message_pkg.DEBUG('Classification package is missing (name=' || l_cls_pkg_name || ')');
          l_error_ctr  := 1;
        END IF;
      END IF;
    END LOOP;

    IF l_error_ctr = 1 THEN
      fnd_message.set_name('CN', 'PROC_CLS_PKG_MISSING');

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
        fnd_log.MESSAGE(
          fnd_log.level_error
        , 'cn.plsql.cn_proc_batches_pkg.validate_ruleset_status.validation'
        , TRUE
        );
      END IF;

      RETURN FALSE;
    END IF;

    RETURN TRUE;
  END validate_ruleset_status;

  -- Procedure Name
  --   Processor
  -- Purpose
  --   Called from concurrent manager or from main
  --   If called from SRS the procedure must create the logical batch from
  --   the passed parameters.
  --   If called from the commissions batch processing UI's the logical id
  --   will be present and the logical batch already exists.

  -- Notes
  --   Logical flag is null when called as a conc program
  --   Online flag allows the trx_processor to determine whether it can submit
  --   its own concurrent programs
  --
  PROCEDURE processor(
    errbuf                 OUT NOCOPY VARCHAR2
  , retcode                OUT NOCOPY NUMBER
  , p_parent_proc_audit_id            NUMBER
  , p_concurrent_flag                 VARCHAR2
  , p_process_name                    VARCHAR2
  , p_logical_batch_id                NUMBER
  , p_start_date                      DATE
  , p_end_date                        DATE
  , p_salesrep_id                     NUMBER
  , p_comp_plan_id                    NUMBER
  ) IS
    l_process_audit_id   NUMBER(15);
    l_request_id         NUMBER(15);
    l_paid               NUMBER(15);
    l_temp               NUMBER;
    l_logical_batch_id   NUMBER(15);
    l_calc_sub_batch_id  NUMBER(15);
    l_salesrep_option    VARCHAR2(30);
    -- for update payee subledger
    l_loading_status     VARCHAR2(50);
    l_return_status      VARCHAR2(50);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_ledger_je_batch    cn_calc_subledger_pvt.je_batch_rec_type;
    l_ledger_je_batch_id NUMBER(15);
  BEGIN
    l_request_id        := fnd_global.conc_request_id;
    g_logical_process   := p_process_name;
    g_logical_batch_id  := p_logical_batch_id;

    SELECT calc_type
         , org_id
      INTO g_calc_type
         , g_org_id
      FROM cn_calc_submission_batches_all
     WHERE logical_batch_id = g_logical_batch_id;

    -- Accept the current parent id and get the id for this batch if
    -- this is a concurrent request and it wasn't submitted from the
    -- calc submission form.
    -- If it is a conc request and was submitted from the form then
    -- we will already have the process audit id
    IF l_request_id <> -1 THEN
      cn_message_pkg.begin_batch(
        x_process_type               => 'CALCULATION'
      , x_parent_proc_audit_id       => p_parent_proc_audit_id
      , x_process_audit_id           => l_process_audit_id
      , x_request_id                 => fnd_global.conc_request_id
      , p_org_id                     => g_org_id
      );
    END IF;

    -- Group the srp periods into physical batches
    BEGIN
      SELECT physical_batch_id
        INTO l_temp
        FROM cn_process_batches_all
       WHERE logical_batch_id = g_logical_batch_id AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_temp  := -1;
    END;

    IF (l_temp IS NULL) THEN
      assign;
    ELSIF(l_temp = -1) THEN
      GOTO end_no_trx;
    END IF;

    -- Only pass the new one if running concurrently
    l_paid              := NVL(l_process_audit_id, p_parent_proc_audit_id);

    UPDATE cn_calc_submission_batches_all
       SET   --ledger_je_batch_id = l_ledger_je_batch_id,
          process_audit_id = l_paid
     WHERE logical_batch_id = g_logical_batch_id;

    IF p_concurrent_flag = 'N' THEN
      seq_dispatch(l_paid);
    ELSE
      IF (l_temp IS NULL) THEN
        conc_dispatch(l_paid);
      ELSE
        conc_dispatch2(l_paid);
      END IF;

      BEGIN
        SELECT 1
          INTO l_temp
          FROM SYS.DUAL
         WHERE NOT EXISTS(SELECT 1
                            FROM cn_process_batches_all
                           WHERE logical_batch_id = p_logical_batch_id AND status_code = 'ERROR');

        cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'COMPLETE');
        fnd_message.set_name('CN', 'ALL_PROCESS_DONE_OK');

        IF (fnd_log.level_event >= fnd_log.g_current_runtime_level) THEN
          fnd_log.MESSAGE(fnd_log.level_event, 'cn.plsql.cn_proc_batches_pkg.processor.event'
          , TRUE);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          retcode  := 2;
          errbuf   := 'Completed with error. Please see the log file for details.';
          cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'FAILED');
          fnd_message.set_name('CN', 'ALL_PROCESS_DONE_FAIL');

          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
            fnd_log.MESSAGE(fnd_log.level_error
            , 'cn.plsql.cn_proc_batches_pkg.processor.exception', TRUE);
          END IF;
      END;

      -- Mark the processed batches for deletion
      void_batches(NULL);
    END IF;

    <<end_no_trx>>
    cn_message_pkg.end_batch(l_paid);
  EXCEPTION
    WHEN OTHERS THEN
      retcode  := 2;
      errbuf   := SQLERRM;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected exception in cn_proc_batches_pkg.processor');
      fnd_file.put_line(fnd_file.LOG, SQLERRM);
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.processor:');
      cn_message_pkg.rollback_errormsg_commit(errbuf);
      cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'FAILED');
      cn_message_pkg.end_batch(l_paid);

      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.processor.exception', SQLERRM);
      END IF;

      RAISE;
  END processor;

  -- processor concurrent wrapper on top of processor, called by the concurrent program CN_BATPROC.
  -- Do the Canonical-to-Date conversion on the date prarmeters, bug 2610735
  PROCEDURE processor_curr(
    errbuf                 OUT NOCOPY VARCHAR2
  , retcode                OUT NOCOPY NUMBER
  , p_parent_proc_audit_id            NUMBER
  , p_concurrent_flag                 VARCHAR2
  , p_process_name                    VARCHAR2
  , p_logical_batch_id                NUMBER
  , p_start_date                      VARCHAR2
  , p_end_date                        VARCHAR2
  , p_salesrep_id                     NUMBER
  , p_comp_plan_id                    NUMBER
  ) IS
  BEGIN
    processor(
      errbuf                       => errbuf
    , retcode                      => retcode
    , p_parent_proc_audit_id       => p_parent_proc_audit_id
    , p_concurrent_flag            => p_concurrent_flag
    , p_process_name               => p_process_name
    , p_logical_batch_id           => p_logical_batch_id
    , p_start_date                 => fnd_date.canonical_to_date(p_start_date)
    , p_end_date                   => fnd_date.canonical_to_date(p_end_date)
    , p_salesrep_id                => p_salesrep_id
    , p_comp_plan_id               => p_comp_plan_id
    );
  END processor_curr;

  PROCEDURE main(
    p_concurrent_flag                   VARCHAR2 DEFAULT 'N'
  , p_process_name                      VARCHAR2 DEFAULT 'CALCULATION'
  , p_logical_batch_id                  NUMBER
  , p_start_date                        DATE
  , p_end_date                          DATE
  , p_salesrep_id                       NUMBER
  , p_comp_plan_id                      NUMBER
  , x_process_audit_id    IN OUT NOCOPY NUMBER
  , x_process_status_code OUT NOCOPY    VARCHAR2
  ) IS
    l_temp             NUMBER(1);
    l_dummy            VARCHAR2(80);
    l_request_id       NUMBER;
    l_process_audit_id NUMBER(15);
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.main.begin'
      , 'Beginning of cn_proc_batches_pkg.main...'
      );
    END IF;

    cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'PROCESSING');
    COMMIT;

    -- The process audit_id is passed in when called from the trx form.
    IF x_process_audit_id IS NULL THEN
      cn_message_pkg.begin_batch(
        x_process_type               => 'CALCULATION'
      , x_parent_proc_audit_id       => NULL
      , x_process_audit_id           => x_process_audit_id
      , x_request_id                 => fnd_global.conc_request_id
      , p_org_id                     => g_org_id
      );

      UPDATE cn_calc_submission_batches_all
         SET process_audit_id = x_process_audit_id
       WHERE logical_batch_id = p_logical_batch_id;
    END IF;

    -- Validate the process name parameter. Currently we only pass 'calculation'
    -- but in future we may call collection and other processes.
    -- And validate ruleset's status
    IF p_process_name = g_collection THEN
      NULL;
    ELSIF p_process_name IN(g_classification, g_rollup, g_population, g_calculation) THEN
      IF NOT validate_ruleset_status(p_start_date, p_end_date, g_org_id) THEN
        fnd_file.put_line(fnd_file.LOG, 'classification ruleset is not valid');
        RAISE ABORT;
      END IF;
    ELSE
      fnd_file.put_line(fnd_file.LOG
      , 'cn_proc_batches_pkg.main: bad process name: ' || p_process_name);
      cn_message_pkg.DEBUG('Invalid process code (' || p_process_name || ')');
      RAISE ABORT;
    END IF;

    IF NVL(cn_global_var.g_system_batch_size, 0) = 0 THEN
      cn_message_pkg.set_name('CN', 'PROC_BAD_BATCH_SIZE');
      fnd_file.put_line(fnd_file.LOG, fnd_message.get);
      RAISE ABORT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.main.run_processor'
      , 'Before calling procedure processor.'
      );
    END IF;

    IF (p_concurrent_flag = 'N' OR(p_concurrent_flag = 'Y' AND fnd_global.conc_program_id <> -1)) THEN
      cn_message_pkg.DEBUG('Start processing transactions (non concurrent calculation)');
      cn_proc_batches_pkg.processor(
        l_dummy
      , l_temp
      , x_process_audit_id
      , p_concurrent_flag
      , p_process_name
      , p_logical_batch_id
      , p_start_date
      , p_end_date
      , p_salesrep_id
      , p_comp_plan_id
      );
      cn_message_pkg.DEBUG('End processing transactions (non concurrent calculation)');

      IF (l_temp = 2) THEN
        x_process_status_code  := 'FAIL';
      ELSE
        BEGIN
          SELECT 1
            INTO l_temp
            FROM SYS.DUAL
           WHERE NOT EXISTS(SELECT 1
                              FROM cn_process_batches_all
                             WHERE logical_batch_id = p_logical_batch_id AND status_code = 'ERROR');

          cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'COMPLETE');
          x_process_status_code  := 'SUCCESS';
          --cn_message_pkg.set_name('CN','ALL_PROCESS_DONE_OK');
          cn_message_pkg.end_batch(x_process_audit_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'FAILED');
            x_process_status_code  := 'FAIL';
            --cn_message_pkg.set_name('CN','ALL_PROCESS_DONE_FAIL');
            cn_message_pkg.end_batch(x_process_audit_id);
        END;

        COMMIT;
      END IF;

      -- Mark the processed batches for deletion
      void_batches(NULL);
    ELSE
      fnd_request.set_org_id(g_org_id);
      l_request_id  :=
        fnd_request.submit_request(
          application                  => 'CN'
        , program                      => 'BATCH_PROCESSOR'
        , description                  => NULL
        , start_time                   => NULL
        , sub_request                  => NULL
        , argument1                    => x_process_audit_id
        , argument2                    => p_concurrent_flag
        , argument3                    => p_process_name
        , argument4                    => p_logical_batch_id
        , argument5                    => fnd_date.date_to_canonical(p_start_date)
        , argument6                    => fnd_date.date_to_canonical(p_end_date)
        , argument7                    => p_salesrep_id
        , argument8                    => p_comp_plan_id
        );

      IF l_request_id = 0 THEN
        fnd_file.put_line(fnd_file.LOG
        , 'cn_proc_batches_pkg.main: unable to submit batch_processor');
        cn_message_pkg.DEBUG('Failed to submit concurrent request (Batch Processor)');
        cn_message_pkg.DEBUG(fnd_message.get);
        x_process_status_code  := 'FAIL';

        IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
          fnd_log.STRING(
            fnd_log.level_unexpected
          , 'cn.plsql.cn_proc_batches_pkg.main.exception'
          , 'Failed to submit request for BATCH_PROCESSOR.'
          );
        END IF;

        RAISE ABORT;
      ELSE
        x_process_status_code  := 'SUCCESS';
        -- a separate process is being called so we need to wrap up this
        -- batch of messages
        cn_message_pkg.end_batch(x_process_audit_id);
        -- for concurrent request, it makes more sense to return request_id.
        -- It is better to use another parameter to return request_id.
        x_process_audit_id     := l_request_id;
        cn_message_pkg.FLUSH;
        COMMIT;
      END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.main.run_processor'
      , 'After calling procedure processor.'
      );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.main.end'
      , 'End of cn_proc_batches_pkg.main...'
      );
    END IF;
  EXCEPTION
    WHEN ABORT THEN
      cn_message_pkg.rollback_errormsg_commit('Exception occurs in cn_proc_batches_pkg.main.');
      cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'FAILED');
      COMMIT;
      x_process_status_code  := 'FAIL';
      fnd_file.put_line(fnd_file.LOG, fnd_message.get);
      cn_message_pkg.end_batch(x_process_audit_id);
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG, 'unexpected exception in cn_proc_batches_pkg.main');
      fnd_file.put_line(fnd_file.LOG, SQLERRM);
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.main: ');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);
      cn_calc_sub_batches_pkg.update_calc_sub_batch(g_logical_batch_id, 'FAILED');
      COMMIT;
      x_process_status_code  := 'FAIL';
      --cn_message_pkg.set_name('CN','ALL_PROCESS_DONE_FAIL');
      cn_message_pkg.end_batch(x_process_audit_id);

      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(fnd_log.level_unexpected, 'cn.plsql.cn_proc_batches_pkg.main.exception'
        , SQLERRM);
      END IF;
  END main;

  FUNCTION get_period_name(x_period_id IN NUMBER, p_org_id IN NUMBER)
    RETURN VARCHAR2 IS
    x_period_name VARCHAR2(30);
  BEGIN
    IF x_period_id IS NOT NULL THEN
      SELECT period_name
        INTO x_period_name
        FROM cn_period_statuses_all
       WHERE period_id = x_period_id AND org_id = p_org_id;

      RETURN x_period_name;
    END IF;

    RETURN NULL;
  END;

  PROCEDURE get_person_name_num(
    x_salesrep_id               NUMBER
  , p_org_id                    NUMBER
  , x_name        IN OUT NOCOPY VARCHAR2
  , x_num         IN OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    SELECT NAME
         , employee_number
      INTO x_name
         , x_num
      FROM cn_salesreps
     WHERE salesrep_id = x_salesrep_id AND org_id = p_org_id;
  END get_person_name_num;

  --
   -- Name
   --   check_end_of_interval
   -- Purpose
   --   Returns 1 if the specified period is the end of an interval of the
   --  type listed int he X_Interval string.
   -- History
   --  06/13/95  Created   Rjin
   --
  FUNCTION check_end_of_interval(p_period_id NUMBER, p_interval_type_id NUMBER, p_org_id NUMBER)
    RETURN BOOLEAN IS
    l_end_period_id NUMBER(15);
  BEGIN
    SELECT MAX(ps2.period_id)
      INTO l_end_period_id
      FROM cn_period_statuses_all ps1, cn_period_statuses_all ps2
     WHERE ps1.org_id = p_org_id
       AND ps1.period_id = p_period_id
       AND ps2.period_set_id = ps1.period_set_id
       AND ps2.period_type_id = ps1.period_type_id
       AND ps2.period_year = ps1.period_year
       AND ps2.org_id = ps1.org_id
       AND (
               (p_interval_type_id = -1001 AND ps2.quarter_num = ps1.quarter_num)   -- quarter interval
            OR p_interval_type_id = -1002
           );   -- year interval

    IF p_period_id = l_end_period_id THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END check_end_of_interval;

  --
  -- Name
  --   check_active_plan_assign
  -- Purpose
  --   Returns 1 if the specified period is the end of an interval of the
  --  type listed int he X_Interval string.
  -- History
  --  06/13/95  Created   Tony Lower
  --
  FUNCTION check_active_plan_assign(
    p_salesrep_id       NUMBER
  , p_start_date        DATE
  , p_end_date          DATE
  , p_interval_type_id  NUMBER
  , p_calc_sub_batch_id NUMBER
  , p_org_id            NUMBER
  )
    RETURN BOOLEAN IS
    CURSOR l_active_plan_csr IS
      SELECT 1
        FROM DUAL
       WHERE EXISTS(
               SELECT 1
                 FROM cn_srp_plan_assigns_all spa, cn_comp_plans_all PLAN
                WHERE spa.salesrep_id = p_salesrep_id
                  AND spa.org_id = p_org_id
                  AND (
                          (
                               spa.end_date IS NOT NULL
                           AND p_end_date BETWEEN spa.start_date AND spa.end_date
                          )
                       OR (p_end_date >= spa.start_date AND spa.end_date IS NULL)
                      )
                  AND spa.comp_plan_id = PLAN.comp_plan_id
                  AND PLAN.status_code = 'COMPLETE')
          OR EXISTS   -- comp_plan is active between period start and end date AND a plan element has the salesreps_enddated_flag set to "Y"
                   (
               SELECT 1
                 FROM cn_srp_plan_assigns_all spa, cn_quota_assigns_all qa, cn_quotas_all pe
                WHERE spa.salesrep_id = p_salesrep_id
                  AND spa.org_id = p_org_id
                  AND spa.end_date >= p_start_date
                  AND spa.end_date < p_end_date
                  AND qa.comp_plan_id = spa.comp_plan_id
                  AND qa.quota_id = pe.quota_id
                  AND pe.incentive_type_code = 'BONUS'
                  AND pe.salesreps_enddated_flag = 'Y'
                  AND pe.interval_type_id = p_interval_type_id
                  -- plan element is effective on spa.end_date
                  AND (
                          (
                               pe.end_date IS NOT NULL
                           AND spa.end_date BETWEEN pe.start_date AND pe.end_date
                          )
                       OR (spa.end_date >= pe.start_date AND pe.end_date IS NULL)
                      )
                  -- check if in cn_calc_sub_quotas if that exists
                  AND (
                          (0 = (SELECT COUNT(*)
                                  FROM cn_calc_sub_quotas
                                 WHERE calc_sub_batch_id = p_calc_sub_batch_id))
                       OR (pe.quota_id IN(SELECT csq.quota_id
                                            FROM cn_calc_sub_quotas csq
                                           WHERE csq.calc_sub_batch_id = p_calc_sub_batch_id))
                      ));

    dummy NUMBER := 0;
  BEGIN
    OPEN l_active_plan_csr;
    FETCH l_active_plan_csr INTO dummy;
    CLOSE l_active_plan_csr;

    IF dummy = 1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END check_active_plan_assign;

  -- Procedure Name
  --   Populate_bonus_process_batch
  -- Purpose
  --   populate the cn_process_batch for an entry in cn_calc_submission_batches
  -- Notes
  --   12-Jul-1998, Richard Jin  Created
  PROCEDURE populate_bonus_process_batch(p_calc_sub_batch_id NUMBER) IS
    l_intelligent_flag VARCHAR2(1);
    l_hierarchy_flag   VARCHAR2(1);
    l_salesrep_option  VARCHAR2(20);
    l_counter          NUMBER;
    l_interval_type_id NUMBER(15);
    l_start_date       DATE;
    l_end_date         DATE;
    l_start_period_id  NUMBER;
    l_end_period_id    NUMBER;
    l_org_id           NUMBER;

    -- cursors to select salesrep with active comp plan within the calc_submission
    -- start_date and end_date
    CURSOR l_all_reps_csr IS
      SELECT DISTINCT spa.salesrep_id
                 FROM cn_srp_plan_assigns_all spa, cn_calc_submission_batches_all bat
                WHERE bat.calc_sub_batch_id = p_calc_sub_batch_id
                  AND spa.org_id = bat.org_id
                  AND spa.start_date <= bat.end_date
                  AND (spa.end_date IS NULL OR spa.end_date >= bat.start_date)
                  --code added for forwardport bug 6600074
                  AND EXISTS(SELECT 1
                               FROM cn_comp_plans
                              WHERE comp_plan_id = spa.comp_plan_id AND status_code = 'COMPLETE')
                  AND EXISTS(
                        SELECT 1
                          FROM cn_quota_assigns a, cn_quotas b
                         WHERE a.comp_plan_id = spa.comp_plan_id
                           AND a.quota_id = b.quota_id
                           AND b.incentive_type_code = 'BONUS'
                           AND GREATEST(bat.start_date, b.start_date) <=
                                                  LEAST(bat.end_date, NVL(b.end_date, bat.end_date)))
      --end of code added for forwardport bug 6600074
      UNION
      SELECT salesrep_id
        FROM cn_srp_intel_periods_all sip
       WHERE period_id BETWEEN l_start_period_id AND l_end_period_id
         AND org_id = l_org_id
         AND processing_status_code <> 'CLEAN'
         AND NOT EXISTS(
               SELECT 1
                 FROM cn_srp_plan_assigns_all
                WHERE salesrep_id = sip.salesrep_id
                  AND org_id = sip.org_id
                  AND start_date <= sip.end_date
                  AND NVL(end_date, sip.start_date) >= sip.start_date)
         AND EXISTS(
               SELECT 1
                 FROM cn_commission_headers_all h
                WHERE h.direct_salesrep_id = sip.salesrep_id
                  AND h.org_id = sip.org_id
                  AND h.processed_date BETWEEN sip.start_date AND sip.end_date
                  AND h.trx_type = 'BONUS');

    CURSOR l_user_reps_csr IS
      SELECT cse.salesrep_id
           , NVL(cse.hierarchy_flag, 'N') hierarchy_flag
        FROM cn_calc_submission_entries_all cse
       WHERE cse.calc_sub_batch_id = p_calc_sub_batch_id
         AND (
                 EXISTS(
                   SELECT 1
                     FROM cn_srp_plan_assigns_all spa
                        , cn_calc_submission_batches_all bat
                        ,
                          --code added for forwardport bug 6600074
                          cn_comp_plans PLAN
                        , cn_quota_assigns a
                        , cn_quotas b
                    --end of code added for forwardport bug 6600074
                   WHERE  bat.calc_sub_batch_id = p_calc_sub_batch_id
                      AND spa.salesrep_id = cse.salesrep_id
                      AND spa.org_id = bat.org_id
                      AND spa.start_date <= bat.end_date
                      AND (spa.end_date IS NULL OR spa.end_date >= bat.start_date)
                      --code added for forwardport bug 6600074
                      AND spa.comp_plan_id = PLAN.comp_plan_id
                      AND PLAN.status_code = 'COMPLETE'
                      AND a.comp_plan_id = spa.comp_plan_id
                      AND a.quota_id = b.quota_id
                      AND b.incentive_type_code = 'BONUS'
                      AND GREATEST(bat.start_date, b.start_date) <=
                                                  LEAST(bat.end_date, NVL(b.end_date, bat.end_date))
                                                                                                    --end of code added for forwardport bug 6600074
                 )
              OR EXISTS(
                   SELECT 1
                     FROM cn_commission_headers_all h
                    WHERE h.direct_salesrep_id = cse.salesrep_id
                      AND h.processed_date BETWEEN l_start_date AND l_end_date
                      AND h.org_id = cse.org_id
                      AND h.trx_type = 'BONUS')
             );

    -- cursors for selecting pay period in which to calculate bonus
    CURSOR l_period_int_periods_csr(p_salesrep_id NUMBER, p_interval_type_id NUMBER) IS
      SELECT period.period_id
           , period.start_date
           , period.end_date
        FROM cn_period_statuses_all period, cn_calc_submission_batches_all bat
       WHERE bat.calc_sub_batch_id = p_calc_sub_batch_id
         AND period.org_id = bat.org_id
         AND (period.period_set_id, period.period_type_id) = (SELECT period_set_id
                                                                   , period_type_id
                                                                FROM cn_repositories_all
                                                               WHERE org_id = bat.org_id)
         AND period.end_date BETWEEN bat.start_date AND bat.end_date
         AND (
                 EXISTS   -- on period.end_date there is an active comp_plan
                       (
                   SELECT 1
                     FROM cn_srp_plan_assigns_all spa
                    WHERE spa.salesrep_id = p_salesrep_id
                      AND spa.org_id = bat.org_id
                      AND (
                              (
                                   spa.end_date IS NOT NULL
                               AND period.end_date BETWEEN spa.start_date AND spa.end_date
                              )
                           OR (period.end_date >= spa.start_date AND spa.end_date IS NULL)
                          ))
              OR EXISTS   -- comp_plan is active between period start and end date AND a plan element has the salesreps_enddated_flag set to "Y"
                       (
                   SELECT 1
                     FROM cn_srp_plan_assigns_all spa, cn_quota_assigns_all qa, cn_quotas_all pe
                    WHERE spa.salesrep_id = p_salesrep_id
                      AND spa.org_id = bat.org_id
                      AND spa.end_date >= period.start_date
                      AND spa.end_date < period.end_date
                      AND qa.comp_plan_id = spa.comp_plan_id
                      AND qa.quota_id = pe.quota_id
                      AND pe.incentive_type_code = 'BONUS'
                      AND pe.salesreps_enddated_flag = 'Y'
                      AND (
                              (p_interval_type_id = -1000 AND pe.interval_type_id = -1000)
                           OR (p_interval_type_id = -1001 AND pe.interval_type_id = -1001)
                           OR (p_interval_type_id = -1002 AND pe.interval_type_id = -1002)
                           OR (
                                   p_interval_type_id = -1003
                               AND pe.interval_type_id IN(-1000, -1001, -1002)
                              )
                          )
                      -- plan element is effective on spa.end_date
                      AND (
                              (
                                   pe.end_date IS NOT NULL
                               AND spa.end_date BETWEEN pe.start_date AND pe.end_date
                              )
                           OR (spa.end_date >= pe.start_date AND pe.end_date IS NULL)
                          )
                      -- check if in cn_calc_sub_quotas if that exists
                      AND (
                              (0 = (SELECT COUNT(*)
                                      FROM cn_calc_sub_quotas
                                     WHERE calc_sub_batch_id = p_calc_sub_batch_id))
                           OR (pe.quota_id IN(SELECT csq.quota_id
                                                FROM cn_calc_sub_quotas csq
                                               WHERE csq.calc_sub_batch_id = p_calc_sub_batch_id))
                          ))
              OR EXISTS(
                   SELECT 1
                     FROM cn_commission_headers_all
                    WHERE direct_salesrep_id = p_salesrep_id
                      AND org_id = bat.org_id
                      AND processed_date BETWEEN period.start_date AND period.end_date
                      AND trx_type = 'BONUS')
             );

    CURSOR l_quarter_int_periods_csr(l_salesrep_id NUMBER) IS
      SELECT   MIN(period.period_id) min_period_id
             , MAX(period.period_id) max_period_id
          FROM cn_period_statuses_all period, cn_calc_submission_batches_all bat
         WHERE bat.calc_sub_batch_id = p_calc_sub_batch_id
           AND period.org_id = bat.org_id
           AND period.end_date BETWEEN bat.start_date AND bat.end_date
           AND (period.period_set_id, period.period_type_id) =
                                                              (SELECT period_set_id
                                                                    , period_type_id
                                                                 FROM cn_repositories_all
                                                                WHERE org_id = bat.org_id)
      GROUP BY period.quarter_num;

    CURSOR l_year_int_periods_csr(l_salesrep_id NUMBER) IS
      SELECT   MIN(period.period_id) min_period_id
             , MAX(period.period_id) max_period_id
          FROM cn_period_statuses_all period, cn_calc_submission_batches_all bat
         WHERE bat.calc_sub_batch_id = p_calc_sub_batch_id
           AND period.org_id = bat.org_id
           AND period.end_date BETWEEN bat.start_date AND bat.end_date
           AND (period.period_set_id, period.period_type_id) =
                                                              (SELECT period_set_id
                                                                    , period_type_id
                                                                 FROM cn_repositories_all
                                                                WHERE org_id = bat.org_id)
      GROUP BY period.period_year;

    CURSOR l_period_info_csr(l_period_id NUMBER) IS
      SELECT period.period_id
           , period.start_date
           , period.end_date
           , period.period_set_id
           , period.period_type_id
           , period.period_year
           , period.quarter_num
        FROM cn_period_statuses_all period
       WHERE period.period_id = l_period_id AND org_id = g_org_id;

    l_prd              l_period_info_csr%ROWTYPE;
    l_end_prd          l_period_info_csr%ROWTYPE;
    l_start_prd        l_period_info_csr%ROWTYPE;

    CURSOR l_sub_batch_csr IS
      SELECT NVL(hierarchy_flag, 'N')
           , salesrep_option
           , interval_type_id
           , start_date
           , end_date
           , org_id
        FROM cn_calc_submission_batches_all
       WHERE calc_sub_batch_id = p_calc_sub_batch_id;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.populate_bonus_process_batch.begin'
      , 'Beginning of poulate_bonus_process_batch ...'
      );
    END IF;

    l_counter  := 0;

    OPEN l_sub_batch_csr;
    FETCH l_sub_batch_csr INTO l_hierarchy_flag, l_salesrep_option, l_interval_type_id, l_start_date, l_end_date, l_org_id;
    CLOSE l_sub_batch_csr;

    SELECT period_id
      INTO l_start_period_id
      FROM cn_period_statuses_all
     WHERE l_start_date BETWEEN start_date AND end_date
       AND org_id = l_org_id
       AND (period_set_id, period_type_id) = (SELECT period_set_id
                                                   , period_type_id
                                                FROM cn_repositories_all
                                               WHERE org_id = l_org_id);

    SELECT period_id
      INTO l_end_period_id
      FROM cn_period_statuses_all
     WHERE l_end_date BETWEEN start_date AND end_date
       AND org_id = l_org_id
       AND (period_set_id, period_type_id) = (SELECT period_set_id
                                                   , period_type_id
                                                FROM cn_repositories_all
                                               WHERE org_id = l_org_id);

    IF l_salesrep_option = 'ALL_REPS' THEN
      IF l_interval_type_id = -1000 OR l_interval_type_id = -1003 THEN
        FOR l_srp IN l_all_reps_csr LOOP
          FOR l_period IN l_period_int_periods_csr(l_srp.salesrep_id, l_interval_type_id) LOOP
            l_counter  := 1;

            OPEN l_period_info_csr(l_period.period_id);
            FETCH l_period_info_csr INTO l_prd;
            CLOSE l_period_info_csr;

            populate_calcsub_batches(
              l_srp.salesrep_id
            , l_prd.start_date
            , l_prd.end_date
            , l_prd.period_id
            , l_prd.period_id
            , g_logical_batch_id
            , l_hierarchy_flag
            );
          END LOOP;
        END LOOP;
      ELSIF l_interval_type_id = -1001 THEN
        FOR l_srp IN l_all_reps_csr LOOP
          FOR l_period IN l_quarter_int_periods_csr(l_srp.salesrep_id) LOOP
            -- then check if the period is at the end_of_interval (quarter)
            -- and there is active plan on the period.end_date
            IF check_end_of_interval(l_period.max_period_id, l_interval_type_id, g_org_id) THEN
              -- get the min start date and the max end date for period submitted
              OPEN l_period_info_csr(l_period.min_period_id);
              FETCH l_period_info_csr INTO l_start_prd;
              CLOSE l_period_info_csr;

              OPEN l_period_info_csr(l_period.max_period_id);
              FETCH l_period_info_csr INTO l_end_prd;
              CLOSE l_period_info_csr;

              IF check_active_plan_assign(
                   l_srp.salesrep_id
                 , l_start_prd.start_date
                 , l_end_prd.end_date
                 , l_interval_type_id
                 , p_calc_sub_batch_id
                 , g_org_id
                 ) THEN
                l_counter  := 1;
                populate_calcsub_batches(
                  l_srp.salesrep_id
                , l_start_prd.start_date
                , l_end_prd.end_date
                , l_end_prd.period_id
                , l_end_prd.period_id
                , g_logical_batch_id
                , l_hierarchy_flag
                );
              END IF;
            END IF;
          END LOOP;
        END LOOP;
      ELSIF l_interval_type_id = -1002 THEN
        FOR l_srp IN l_all_reps_csr LOOP
          FOR l_period IN l_year_int_periods_csr(l_srp.salesrep_id) LOOP
            --then check if the period is at the end_of_interval (quarter)
            -- and there is active plan on the period.end_date
            IF check_end_of_interval(l_period.max_period_id, l_interval_type_id, g_org_id) THEN
              -- get the min start date and the max end date for period submitted
              OPEN l_period_info_csr(l_period.min_period_id);
              FETCH l_period_info_csr INTO l_start_prd;
              CLOSE l_period_info_csr;

              OPEN l_period_info_csr(l_period.max_period_id);
              FETCH l_period_info_csr INTO l_end_prd;
              CLOSE l_period_info_csr;

              IF check_active_plan_assign(
                   l_srp.salesrep_id
                 , l_start_prd.start_date
                 , l_end_prd.end_date
                 , l_interval_type_id
                 , p_calc_sub_batch_id
                 , g_org_id
                 ) THEN
                l_counter  := 1;
                populate_calcsub_batches(
                  l_srp.salesrep_id
                , l_start_prd.start_date
                , l_end_prd.end_date
                , l_end_prd.period_id
                , l_end_prd.period_id
                , g_logical_batch_id
                , l_hierarchy_flag
                );
              END IF;
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    ELSIF l_salesrep_option = 'USER_SPECIFY' THEN
      IF l_interval_type_id = -1000 OR l_interval_type_id = -1003 THEN
        FOR l_srp IN l_user_reps_csr LOOP
          FOR l_period IN l_period_int_periods_csr(l_srp.salesrep_id, l_interval_type_id) LOOP
            l_counter  := 1;

            OPEN l_period_info_csr(l_period.period_id);
            FETCH l_period_info_csr INTO l_prd;
            CLOSE l_period_info_csr;

            populate_calcsub_batches(
              l_srp.salesrep_id
            , l_prd.start_date
            , l_prd.end_date
            , l_prd.period_id
            , l_prd.period_id
            , g_logical_batch_id
            , l_srp.hierarchy_flag
            );
          END LOOP;
        END LOOP;
      ELSIF l_interval_type_id = -1001 THEN
        FOR l_srp IN l_user_reps_csr LOOP
          FOR l_period IN l_quarter_int_periods_csr(l_srp.salesrep_id) LOOP
            --then check if the period is at the end_of_interval (quarter)
            -- and there is active plan on the period.end_date
            IF check_end_of_interval(l_period.max_period_id, l_interval_type_id, g_org_id) THEN
              -- get the min start date and the max end date for period submitted
              OPEN l_period_info_csr(l_period.min_period_id);
              FETCH l_period_info_csr INTO l_start_prd;
              CLOSE l_period_info_csr;

              OPEN l_period_info_csr(l_period.max_period_id);
              FETCH l_period_info_csr INTO l_end_prd;
              CLOSE l_period_info_csr;

              IF check_active_plan_assign(
                   l_srp.salesrep_id
                 , l_start_prd.start_date
                 , l_end_prd.end_date
                 , l_interval_type_id
                 , p_calc_sub_batch_id
                 , g_org_id
                 ) THEN
                l_counter  := 1;
                populate_calcsub_batches(
                  l_srp.salesrep_id
                , l_start_prd.start_date
                , l_end_prd.end_date
                , l_end_prd.period_id
                , l_end_prd.period_id
                , g_logical_batch_id
                , l_srp.hierarchy_flag
                );
              END IF;
            END IF;
          END LOOP;
        END LOOP;
      ELSIF l_interval_type_id = -1002 THEN
        FOR l_srp IN l_user_reps_csr LOOP
          FOR l_period IN l_year_int_periods_csr(l_srp.salesrep_id) LOOP
            --then check if the period is at the end_of_interval (quarter)
            -- and there is active plan on the period.end_date
            IF check_end_of_interval(l_period.max_period_id, l_interval_type_id, g_org_id) THEN
              -- get the min start date and the max end date for period submitted
              OPEN l_period_info_csr(l_period.min_period_id);

              FETCH l_period_info_csr
               INTO l_start_prd;

              CLOSE l_period_info_csr;

              OPEN l_period_info_csr(l_period.max_period_id);

              FETCH l_period_info_csr
               INTO l_end_prd;

              CLOSE l_period_info_csr;

              IF check_active_plan_assign(
                   l_srp.salesrep_id
                 , l_start_prd.start_date
                 , l_end_prd.end_date
                 , l_interval_type_id
                 , p_calc_sub_batch_id
                 , g_org_id
                 ) THEN
                l_counter  := 1;
                populate_calcsub_batches(
                  l_srp.salesrep_id
                , l_start_prd.start_date
                , l_end_prd.end_date
                , l_end_prd.period_id
                , l_end_prd.period_id
                , g_logical_batch_id
                , l_srp.hierarchy_flag
                );
              END IF;
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    END IF;

    IF l_counter = 0 THEN   /* no one to be calculated */
      fnd_message.set_name('CN', 'CNSBCS_NO_ONE_TO_BONUS');

      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        fnd_log.MESSAGE(
          fnd_log.level_exception
        , 'cn.plsql.cn_proc_batches_pkg.populate_bonus_process_batch.error'
        , TRUE
        );
      END IF;

      RAISE no_comm_lines;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_proc_batches_pkg.populate_bonus_process_batch.end'
      , 'Beginning of poulate_bonus_process_batch ...'
      );
    END IF;
  EXCEPTION
    WHEN no_comm_lines THEN
      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.populate_bonus_process_batch:');
      cn_message_pkg.rollback_errormsg_commit
        (
        'No one with complete compensation plan to calculate or the period specified is not at the end of the plan element interval'
      );
      fnd_file.put_line
          (
        fnd_file.LOG
      ,    'Exception in cn_proc_batches_pkg.populate_bonus_process_batch: no one with complete '
        || 'compensation plan or the period specified is not at the end of the interval'
      );
      RAISE;
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_proc_batches_pkg.populate_bonus_process_batch.exception'
        , SQLERRM
        );
      END IF;

      cn_message_pkg.DEBUG('Exception occurs in cn_proc_batches_pkg.populate_bonus_process_batch: ');
      cn_message_pkg.rollback_errormsg_commit(SQLERRM);
      fnd_file.put_line(fnd_file.LOG
      , 'Exception in cn_proc_batches_pkg.populate_bonus_process_batch: ' || SQLERRM);
      RAISE;
  END populate_bonus_process_batch;
END cn_proc_batches_pkg;

/
