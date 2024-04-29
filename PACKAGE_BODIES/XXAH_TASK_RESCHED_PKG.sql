--------------------------------------------------------
--  DDL for Package Body XXAH_TASK_RESCHED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_TASK_RESCHED_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_TASK_RESCHED_PKG.plb 32 2013-04-18 06:57:09Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Wrapper package
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 08-OCT-2007 Milco Numan       Genesis.
 *************************************************************************/

  -- ----------------------------------------------------------------------
  -- Private types
  -- ----------------------------------------------------------------------


  -- ----------------------------------------------------------------------
  -- Private constants
  -- ----------------------------------------------------------------------
  gc_log_prefix  CONSTANT  fnd_log_messages.module%TYPE :=
    'xxx.plsql.xxah_task_resched_pkg.';
  gc_level_statement  CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  gc_level_procedure  CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  gc_level_event      CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  gc_level_exception  CONSTANT  NUMBER := FND_LOG.LEVEL_EXCEPTION;

  gc_date_format  CONSTANT  VARCHAR2(30) := 'DD-MM-YYYY';
  gc_task_object  CONSTANT
    pa_structures_tasks_tmp.object_type%TYPE:= 'PA_TASKS';

  -- self service page supposedly calling the API
  gc_calling_page  CONSTANT  VARCHAR2(30) := 'WP_UPD_TASKS';
  gc_wbs_display_depth  CONSTANT  NUMBER := 100; -- max diepte WBS
  gc_manual_task_weighting  CONSTANT  VARCHAR2(30) := 'MANUAL';

  -- ----------------------------------------------------------------------
  -- Private variables
  -- ----------------------------------------------------------------------
  g_log_threshold  NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- check for expensive logging actions before actually logging
  g_log_statement  BOOLEAN;
  g_log_procedure  BOOLEAN;
  g_log_event  BOOLEAN;


  -- ----------------------------------------------------------------------
  -- Private cursors
  -- ----------------------------------------------------------------------


  -- ----------------------------------------------------------------------
  -- Private exceptions
  -- ----------------------------------------------------------------------
  e_task_reschedule_exception  EXCEPTION;
  e_task_pop_temp_tab_exc  EXCEPTION;
  e_task_rollup_exception  EXCEPTION;

  -- ----------------------------------------------------------------------
  -- Forward declarations
  -- ----------------------------------------------------------------------


  -- ----------------------------------------------------------------------
  -- Private subprograms
  -- ----------------------------------------------------------------------

  -- -----------------------------------------------------------------
  -- Verify whether message needs to be propagated
  -- -----------------------------------------------------------------
  FUNCTION dbg( p_level IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN NVL( p_level, 99) >= g_log_threshold;
  END dbg;

  -- -----------------------------------------------------------------
  -- Propagate log message to logging framework
  -- -----------------------------------------------------------------
  PROCEDURE do_log
  ( p_level  IN  NUMBER
  , p_subprog  IN  VARCHAR2
  , p_message  IN  VARCHAR2
  ) IS
  BEGIN
    IF dbg( p_level) THEN
      fnd_log.STRING( log_level => p_level
                    , module => gc_log_prefix || p_subprog
                    , message => p_message
                    );
    END IF;
  END do_log;

  -- dump messages to the OA Logging Framework
  PROCEDURE dump_messages( p_subprog_name  IN  VARCHAR2)
  IS
  BEGIN
    IF g_log_statement THEN
      FOR idx IN 1..fnd_msg_pub.count_msg
      LOOP
        do_log
        ( p_level => gc_level_statement
        , p_subprog => p_subprog_name
        , p_message => 'Idx=' || TO_CHAR( idx)
                       || ', msg='
                       || fnd_msg_pub.get( idx, fnd_api.g_false)
        );
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END  dump_messages;

  PROCEDURE select_and_reschedule
  ( p_project_id  IN  NUMBER
  , p_parent_structure_version_id  NUMBER
  , p_number_of_days  IN  NUMBER
  , p_task_weight_method  IN  VARCHAR2
  ) IS
    -- -----------------------------------------------------------------
    -- Cursor to select the tasks to be rescheduled; tasks must have
    -- been selected by the user (or be a child task of a selected
    -- task) and must be BOTTOM-LEVEL tasks
    -- DISTINCT is used to force uniqueness of the rows, since both a
    -- child and a parent record may have been selected resulting in the
    -- row occuring twice without the DISTINCT operator ...
    -- -----------------------------------------------------------------
    CURSOR cur_task_to_reschedule
    ( b_project_id  NUMBER
    , b_parent_structure_version_id  NUMBER
    ) IS
      SELECT DISTINCT
             xth.scheduled_start_date
      ,      xth.scheduled_finish_date
      ,      xth.elem_ver_sch_rec_ver_number -- record version number
      ,      xth.pev_schedule_id
      ,      xth.milestone_flag
      ,      xth.critical_flag
      ,      xth.wq_planned_quantity
      ,      xth.early_start_date
      ,      xth.early_finish_date
      ,      xth.late_start_date
      ,      xth.late_finish_date
      ,      xth.constraint_date
      ,      xth.constraint_type_code
      -- roll-up tasks
      ,      xth.element_version_id
      FROM   ( SELECT *
               FROM   pa_structures_tasks_tmp pst
               CONNECT BY PRIOR proj_element_id =  parent_element_id
               START WITH proj_element_id IN ( SELECT xar.TASK_ID
                                               FROM   xxah_tasks_resched_tmp xar
                                             )
              ) xth
      WHERE   xth.project_id = b_project_id
      AND     xth.parent_structure_version_id = b_parent_structure_version_id
      AND     xth.object_type = gc_task_object
      AND     xth.summary_element_flag = 'N'
      ;

    r_task_to_reschedule  cur_task_to_reschedule%ROWTYPE;

    l_return_status  VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data  VARCHAR2(4000);

    l_update_task_weighting  BOOLEAN :=
      (NVL(p_task_weight_method,'~') = gc_manual_task_weighting);

    -- VARRAY to hold tasks (element_version_id) to be rolled_up
    l_structure_versions  pa_num_1000_num := pa_num_1000_num();

    c_subprog_name  CONSTANT  VARCHAR2(80) := 'select_and_reschedule';
    -- ----------------------------
    -- L o c a l   M o d u l e s --
    -- ----------------------------
    PROCEDURE task_reschedule IS
      c_subprog_name  CONSTANT  VARCHAR2(80) := 'select_and_reschedule.task_reschedule';
      l_new_scheduled_start_date  DATE;
      l_new_scheduled_finish_date  DATE;
    BEGIN
      l_new_scheduled_start_date :=
        TRUNC( r_task_to_reschedule.scheduled_start_date + p_number_of_days);
      l_new_scheduled_finish_date  :=
        TRUNC( r_task_to_reschedule.scheduled_finish_date + p_number_of_days);

      IF g_log_statement THEN
        do_log( gc_level_statement
              , c_subprog_name
              , 'pev_schedule_id='
                || TO_CHAR( r_task_to_reschedule.pev_schedule_id)
                || ', orig_scheduled_start_date='
                || TO_CHAR( r_task_to_reschedule.scheduled_start_date
                          , gc_date_format
                          )
                || ', orig_scheduled_finish_date='
                || TO_CHAR( r_task_to_reschedule.scheduled_finish_date
                          , gc_date_format
                          )
                || ', new_scheduled_start_date='
                || TO_CHAR( l_new_scheduled_start_date
                          , gc_date_format
                          )
                || ', new_scheduled_finish_date='
                || TO_CHAR( l_new_scheduled_finish_date
                          , gc_date_format
                          )
              );
      END IF;
      -- CALL API to do rescheduling for single task
      PA_TASK_PUB1.Update_Schedule_Version
      ( p_scheduled_start_date  => l_new_scheduled_start_date
      , p_scheduled_end_date    => l_new_scheduled_finish_date
      , p_record_version_number => r_task_to_reschedule.elem_ver_sch_rec_ver_number
      , p_pev_schedule_id       => r_task_to_reschedule.pev_schedule_id
      , P_MILESTONE_FLAG        => r_task_to_reschedule.milestone_flag
      , P_CRITICAL_FLAG         => r_task_to_reschedule.critical_flag
      , p_WQ_PLANNED_QUANTITY   => r_task_to_reschedule.wq_planned_quantity
      , p_early_start_date      => r_task_to_reschedule.early_start_date
      , p_early_end_date        => r_task_to_reschedule.early_finish_date
      , p_late_start_date       => r_task_to_reschedule.late_start_date
      , p_late_end_date         => r_task_to_reschedule.late_finish_date
      , p_constraint_date       => r_task_to_reschedule.constraint_date
      , p_constraint_type_code  => r_task_to_reschedule.constraint_type_code
      , x_return_status         => l_return_status
      , x_msg_count             => l_msg_count
      , x_msg_data              => l_msg_data
      );
      --
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF g_log_event THEN
          do_log( gc_level_event
                , c_subprog_name
                , 'Return status ' || l_return_status
                  || ' on p_pev_schedule_id='
                  || TO_CHAR( r_task_to_reschedule.pev_schedule_id)
                );
        END IF;
      ELSE
        IF g_log_event THEN
          do_log( gc_level_event
                , c_subprog_name
                , 'Return status ' || l_return_status
                  || ' on p_pev_schedule_id='
                  || TO_CHAR( r_task_to_reschedule.pev_schedule_id)
                );
        END IF;
        dump_messages( c_subprog_name);
        RAISE e_task_reschedule_exception;
      END IF;
    END task_reschedule;


    PROCEDURE roll_up_rescheduled_tasks IS
      c_subprog_name  CONSTANT  VARCHAR2(80) := 'select_and_reschedule.roll_up_rescheduled_tasks';
      l_count  PLS_INTEGER;
    BEGIN
      l_count := l_structure_versions.COUNT;
      IF g_log_statement THEN
        do_log( gc_level_statement
              , c_subprog_name
              , '# elements in l_structure_versions ' || TO_CHAR( l_count)
              );
      END IF;

      -- invoke when there are elements to process
      IF l_count > 0 THEN
        PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup
        ( p_api_version => 1.0
        , p_init_msg_list => FND_API.G_TRUE
        , p_commit => FND_API.G_FALSE
        , p_validate_only => FND_API.G_TRUE
        , p_validation_level => 100
        , p_calling_module => 'SELF_SERVICE'
        , p_debug_mode => 'N'
        , p_element_versions  => l_structure_versions
        , x_return_status => l_return_status
        , x_msg_count => l_msg_count
        , x_msg_data => l_msg_data
        );
        --
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          IF g_log_event THEN
            do_log( gc_level_event
                  , c_subprog_name
                  , 'Return status ' || l_return_status
                  );
          END IF;
        ELSE
          IF g_log_event THEN
            do_log( gc_level_event
                   , c_subprog_name
                  , 'Return status ' || l_return_status
                  );
          END IF;
          dump_messages( c_subprog_name);
          RAISE e_task_rollup_exception;
        END IF; -- end return status

      END IF; -- elements to process
    END roll_up_rescheduled_tasks;

  BEGIN
    IF g_log_procedure THEN
      do_log( gc_level_procedure
            , c_subprog_name
            , 'Entering (+), p_project_id=' || TO_CHAR( p_project_id)
              || ', p_parent_structure_id='
              || TO_CHAR( p_parent_structure_version_id)
            );
    END IF;
    --
    OPEN cur_task_to_reschedule( p_project_id, p_parent_structure_version_id);
    LOOP
      FETCH cur_task_to_reschedule INTO r_task_to_reschedule;
      EXIT WHEN cur_task_to_reschedule%NOTFOUND;
      --
      task_reschedule;
      -- add this task to be ROLLED up later on
      l_structure_versions.extend;
      l_structure_versions( l_structure_versions.LAST) :=
        r_task_to_reschedule.element_version_id;

    END LOOP;
    CLOSE cur_task_to_reschedule;
    roll_up_rescheduled_tasks;
    --
    IF g_log_procedure THEN
      do_log( gc_level_procedure
            , c_subprog_name
            , 'Exiting (-)'
            );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      do_log( gc_level_exception
            , c_subprog_name
            , 'EXCEPTION: ' || SQLCODE || ' ==> ' || SQLERRM
            );
      RAISE;

  END select_and_reschedule;


  PROCEDURE do_reschedule
  ( p_number_of_days IN  NUMBER
  , p_task_id_tbl  IN  SYSTEM.PA_NUM_TBL_TYPE
  , p_reschedule_flag_tbl  IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE
  , p_project_id  IN  NUMBER
  , p_structure_version_id  IN  NUMBER
  , p_task_weight_method  IN  VARCHAR2
  , x_return_status  OUT     NOCOPY VARCHAR2
  , x_msg_count  OUT     NOCOPY NUMBER
  , x_msg_data  OUT     NOCOPY VARCHAR2
  ) IS
    c_subprog_name  CONSTANT  VARCHAR2(80) := 'do_reschedule';
    -- ----------------------------
    -- L o c a l   M o d u l e s --
    -- ----------------------------

    -- This procedure will populate the temporary table pa_structure_tasks_tmp
    -- with ALL detail information in order to process all child tasks for
    -- rescheduling ...
    -- This table will be rebuilt upon COMMITTING the transaction by
    -- the VO/CO ...
    PROCEDURE rebuild_temp_table IS
      c_subprog_name  CONSTANT
        VARCHAR2(80) := 'do_reschedule.rebuild_temp_table';
    BEGIN
      IF g_log_procedure THEN
        do_log( gc_level_procedure
              , c_subprog_name
              , 'Entering (+)'
              );
      END IF;
      --
      pa_proj_structure_pub.populate_structures_tmp_tab
      ( p_api_version => 1.0
      , p_init_msg_list => FND_API.G_FALSE
      , p_commit => FND_API.G_FALSE
      , p_validate_only => FND_API.G_TRUE
      , p_debug_mode => 'N'
      , p_project_id => p_project_id
      , p_structure_version_id => p_structure_version_id
      , p_task_version_id => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      , p_calling_page_name => gc_calling_page
      , p_populate_tmp_tab_flag => 'Y'
      , p_parent_project_id => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      , p_sequence_offset => 0
      , p_wbs_display_depth => gc_wbs_display_depth
      , x_return_status => x_return_status
      , x_msg_count => x_msg_count
      , x_msg_data => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF g_log_statement THEN
          do_log( gc_level_statement
                , c_subprog_name
                , 'Exiting, status = ' || x_return_status
                  || ', msg_count = ' || TO_CHAR( x_msg_count)
                );
        END IF;
      ELSE
        dump_messages( c_subprog_name);
        RAISE e_task_pop_temp_tab_exc;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        do_log( gc_level_exception
              , c_subprog_name
              , 'EXCEPTION: ' || SQLCODE || ' ==> ' || SQLERRM
              );
        RAISE;
    END rebuild_temp_table;

    -- This procedure inserts the BASE tasks that have been
    -- selected for rescheduling INTO a temporary table
    -- in order to be joined to the temporary task structure
    -- table: this allows for selection of all (child) tasks
    -- to be rescheduled.
    PROCEDURE build_local_resched_task_table IS
      idx  PLS_INTEGER;
      c_subprog_name  CONSTANT
        VARCHAR2(80) := 'do_reschedule.build_local_resched_task_table';
    BEGIN
      IF g_log_procedure THEN
        do_log( gc_level_procedure
              , c_subprog_name
              , 'Entering (+), p_project_id=' || TO_CHAR( p_project_id)
                 || ', p_structure_version_id='
                 || TO_CHAR(p_structure_version_id)
              );
      END IF;
      --
      IF p_task_id_tbl.COUNT > 0 THEN
        idx := p_task_id_tbl.FIRST;
        LOOP
          EXIT WHEN idx IS NULL;
          --
          IF g_log_statement THEN
            do_log( gc_level_statement
                  , c_subprog_name
                  , 'Idx = ' || to_char( idx)
                    || ', task_id = ' || p_task_id_tbl( idx)
                    || ', reschedule_flag = ' || p_reschedule_flag_tbl(idx)
                  );
          END IF;
          --
          IF  p_reschedule_flag_tbl(idx) = 'Y' THEN
            INSERT INTO XXAH_TASKS_RESCHED_TMP(TASK_ID)
            VALUES( p_task_id_tbl( idx));
          END IF;
          idx := p_task_id_tbl.NEXT( idx);
        END LOOP;
      END IF;
      --
      IF g_log_procedure THEN
        do_log( gc_level_procedure
              , c_subprog_name
              , 'Exiting (-)'
              );
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        do_log( gc_level_exception
              , c_subprog_name
              , 'EXCEPTION: ' || SQLCODE || ' ==> ' || SQLERRM
              );
        RAISE;
    END build_local_resched_task_table;

  BEGIN

    IF g_log_procedure THEN
      do_log( gc_level_procedure
            , c_subprog_name
            , 'Entering (+), p_task_weight_method=' || p_task_weight_method
            );
    END IF;
    -- generate task structure in temp table
    rebuild_temp_table;
    -- generate yet another temp table with task_id for rescheduling
    build_local_resched_task_table;
    -- perform actual rescheduling
    select_and_reschedule
    ( p_project_id => p_project_id
    , p_parent_structure_version_id => p_structure_version_id
    , p_number_of_days => p_number_of_days
    , p_task_weight_method => p_task_weight_method
    );

    --
    IF g_log_procedure THEN
      do_log( gc_level_procedure
            , c_subprog_name
            , 'Exiting (-)'
            );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      do_log( gc_level_exception
            , c_subprog_name
            , 'EXCEPTION: ' || SQLCODE || ' ==> ' || SQLERRM
            );
      RAISE;
  END do_reschedule;

  -- ----------------------------------------------------------------------
  -- Public subprograms
  -- ----------------------------------------------------------------------
  PROCEDURE Update_Task_All_Info
  ( p_api_version                      IN      NUMBER      :=1.0
  , p_init_msg_list                    IN      VARCHAR2    :=FND_API.G_TRUE
  , p_commit                           IN      VARCHAR2    :=FND_API.G_FALSE
  , p_validate_only                    IN      VARCHAR2    :=FND_API.G_TRUE
  , p_validation_level                 IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL
  , p_calling_module                   IN      VARCHAR2    :='SELF_SERVICE'
  , p_debug_mode                       IN      VARCHAR2    :='N'
  , p_max_msg_count                    IN      NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_task_id_tbl                      IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_task_number_tbl                  IN      SYSTEM.PA_VARCHAR2_100_TBL_TYPE  := SYSTEM.PA_VARCHAR2_100_TBL_TYPE()
  , p_task_name_tbl                    IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
  , p_task_description_tbl             IN      SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
  , p_task_manager_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_task_manager_name_tbl            IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
  , p_carrying_out_org_id_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_carrying_out_org_name_tbl        IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
  , p_priority_code_tbl                IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
  , p_TYPE_ID_tbl                      IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_status_code_tbl                  IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
  , p_inc_proj_progress_flag_tbl       IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
  , p_transaction_start_date_tbl       IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_transaction_finish_date_tbl      IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_work_type_id_tbl                 IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_service_type_code_tbl            IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
  , p_work_item_code_tbl               IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
  , p_uom_code_tbl                     IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
  , p_record_version_number_tbl        IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  -- Update_Schedule_Version
  , p_scheduled_start_date_tbl         IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_scheduled_end_date_tbl           IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_pev_schedule_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_milestone_flag_tbl               IN      SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
  , p_critical_flag_tbl                IN      SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
  , p_WQ_PLANNED_QUANTITY_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_early_start_date_tbl             IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_early_end_date_tbl               IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_late_start_date_tbl              IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_late_end_date_tbl                IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_constraint_type_code_tbl         IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
  , p_constraint_date_tbl              IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
  , p_sch_rec_ver_num_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  -- update_task_det_sch_info
  , p_task_version_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_percent_complete_tbl             IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_ETC_effort_tbl                   IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_structure_version_id_tbl         IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_project_id_tbl                   IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_planned_effort_tbl               IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_actual_effort_tbl                IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  -- Update_Task_Weighting
  , p_object_relationship_id_tbl       IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_weighting_percentage_tbl         IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_obj_rec_ver_num_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
  , p_task_weight_method               IN      VARCHAR2
  -- common
  , x_return_status                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count                        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data                         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  -- additional parameters for rescheduling
  , p_reschedule_flag_tbl              IN      SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
  , p_number_of_days                   IN      NUMBER := 0
  ) IS
    idx  PLS_INTEGER;
    l_log_msg  VARCHAR2(4000);
    l_project_id  NUMBER;
    l_structure_version_id  NUMBER;

    c_subprog_name  CONSTANT  VARCHAR2(80) := 'update_task_all_info';
  BEGIN
    IF g_log_procedure THEN
      do_log( gc_level_procedure
            , c_subprog_name
            , 'Entering (+)'
            );
    END IF;
    --
    IF g_log_statement THEN
      do_log( gc_level_statement
            , c_subprog_name
            , 'Calling PA_TASK_PUB1.UPDATE_TASK_ALL_INFO'
            );
    END IF;
    --
    PA_TASK_PUB1.update_task_all_info
    ( p_api_version => 1.0
    , p_init_msg_list  => p_init_msg_list
    , p_commit  => p_commit
    , p_validate_only  => p_validate_only
    , p_validation_level  => p_validation_level
    , p_calling_module  => p_calling_module
    , p_debug_mode  => p_debug_mode
    , p_max_msg_count  => p_max_msg_count
    , p_task_id_tbl  => p_task_id_tbl
    , p_task_number_tbl  => p_task_number_tbl
    , p_task_name_tbl  => p_task_name_tbl
    , p_task_description_tbl  => p_task_description_tbl
    , p_task_manager_id_tbl  => p_task_manager_id_tbl
    , p_task_manager_name_tbl  => p_task_manager_name_tbl
    , p_carrying_out_org_id_tbl  => p_carrying_out_org_id_tbl
    , p_carrying_out_org_name_tbl  => p_carrying_out_org_name_tbl
    , p_priority_code_tbl  => p_priority_code_tbl
    , p_TYPE_ID_tbl  => p_TYPE_ID_tbl
    , p_status_code_tbl  => p_status_code_tbl
    , p_inc_proj_progress_flag_tbl  => p_inc_proj_progress_flag_tbl
    , p_transaction_start_date_tbl  => p_transaction_start_date_tbl
    , p_transaction_finish_date_tbl  => p_transaction_finish_date_tbl
    , p_work_type_id_tbl  => p_work_type_id_tbl
    , p_service_type_code_tbl  => p_service_type_code_tbl
    , p_work_item_code_tbl  => p_work_item_code_tbl
    , p_uom_code_tbl  => p_uom_code_tbl
    , p_record_version_number_tbl  => p_record_version_number_tbl
    -- Update_Schedule_Version
    , p_scheduled_start_date_tbl  => p_scheduled_start_date_tbl
    , p_scheduled_end_date_tbl  => p_scheduled_end_date_tbl
    , p_pev_schedule_id_tbl  => p_pev_schedule_id_tbl
    , p_milestone_flag_tbl  => p_milestone_flag_tbl
    , p_critical_flag_tbl  => p_critical_flag_tbl
    , p_WQ_PLANNED_QUANTITY_tbl  => p_WQ_PLANNED_QUANTITY_tbl
    , p_early_start_date_tbl  => p_early_start_date_tbl
    , p_early_end_date_tbl  => p_early_end_date_tbl
    , p_late_start_date_tbl  => p_late_start_date_tbl
    , p_late_end_date_tbl  => p_late_end_date_tbl
    , p_constraint_type_code_tbl  => p_constraint_type_code_tbl
    , p_constraint_date_tbl  => p_constraint_date_tbl
    , p_sch_rec_ver_num_tbl  => p_sch_rec_ver_num_tbl
    -- update_task_det_sch_info
    , p_task_version_id_tbl  => p_task_version_id_tbl
    , p_percent_complete_tbl  => p_percent_complete_tbl
    , p_ETC_effort_tbl  => p_ETC_effort_tbl
    , p_structure_version_id_tbl  => p_structure_version_id_tbl
    , p_project_id_tbl  => p_project_id_tbl
    , p_planned_effort_tbl  => p_planned_effort_tbl
    , p_actual_effort_tbl  => p_actual_effort_tbl
    -- Update_Task_Weighting
    , p_object_relationship_id_tbl  => p_object_relationship_id_tbl
    , p_weighting_percentage_tbl  => p_weighting_percentage_tbl
    , p_obj_rec_ver_num_tbl  => p_obj_rec_ver_num_tbl
    , p_task_weight_method  => p_task_weight_method
    -- common
    , x_return_status  => x_return_status
    , x_msg_count  => x_msg_count
    , x_msg_data  => x_msg_data
    );
    --
    IF g_log_statement THEN
      do_log( gc_level_statement
            , c_subprog_name
            , 'PA_TASK_PUB1.update_task_all_info returned status = ' || x_return_status
            );
    END IF;

    -- only prepare rescheduling arguments when previous call was successful
    -- and the # days has been entered by the user
    IF x_return_status = FND_API.g_ret_sts_success THEN
      IF p_number_of_days <> 0 THEN
        IF p_project_id_tbl.COUNT > 0 THEN
          l_project_id := p_project_id_tbl(p_project_id_tbl.FIRST);
        END IF;
        IF p_structure_version_id_tbl.COUNT > 0 THEN
          l_structure_version_id :=
            p_structure_version_id_tbl(p_structure_version_id_tbl.FIRST);
        END IF;
        do_reschedule( p_number_of_days => p_number_of_days
                     , p_task_id_tbl => p_task_id_tbl
                     , p_reschedule_flag_tbl => p_reschedule_flag_tbl
                     , p_project_id => l_project_id
                     , p_structure_version_id => l_structure_version_id
                     , p_task_weight_method => p_task_weight_method
                     , x_return_status => x_return_status
                     , x_msg_count => x_msg_count
                     , x_msg_data => x_msg_data
                     );
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          IF g_log_statement THEN
            do_log( gc_level_statement
                  , c_subprog_name
                  , 'Exiting, status = ' || x_return_status
                    || ', msg_count = ' || TO_CHAR( x_msg_count)
                  );
          END IF;
        ELSE
          dump_messages( c_subprog_name);
          RAISE e_task_pop_temp_tab_exc;
        END IF;

      ELSE
        IF g_log_statement THEN
          do_log( gc_level_statement
                , c_subprog_name
                , 'No need to reschedule, p_number_of_days is 0'
                );
        END IF;
      END IF;
    END IF;
    --

    IF g_log_procedure THEN
      do_log( gc_level_procedure
            , c_subprog_name
            , 'Exiting (-)'
            );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
      do_log( gc_level_exception
            , c_subprog_name
            , 'EXCEPTION: ' || SQLCODE || ' ==> ' || SQLERRM
            );
  END Update_Task_All_Info;

BEGIN
  g_log_statement := dbg( gc_level_statement);
  g_log_procedure := dbg( gc_level_procedure);
  g_log_event := dbg( gc_level_event);
END XXAH_TASK_RESCHED_PKG ;

/
