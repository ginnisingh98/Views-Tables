--------------------------------------------------------
--  DDL for Package XXAH_TASK_RESCHED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_TASK_RESCHED_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_TASK_RESCHED_PKG.pls 32 2013-04-18 06:57:09Z marc.smeenge@oracle.com $
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
  -- Global types
  -- ----------------------------------------------------------------------


  -- ----------------------------------------------------------------------
  -- Global constants
  -- ----------------------------------------------------------------------

  -- ----------------------------------------------------------------------
  -- Global variables
  -- ----------------------------------------------------------------------

  -- ----------------------------------------------------------------------
  -- Global cursors
  -- ----------------------------------------------------------------------

  -- ----------------------------------------------------------------------
  -- Global exceptions
  -- ----------------------------------------------------------------------

  /**************************************************************************
   *
   * PROCEDURE
   *   Update_Task_All_Info
   *
   * DESCRIPTION
   *   This procedure is the wrapper procedure for rescheduling and
   *   updating the tasks.
   *   The parameter list is taken from PA_TASK1_PUB.update_tasl_all_info
   *   and has been augmented with the arguments required for the
   *   rescheduling, e.g. a table of rescheduling flags and the days offset.
   *
   *
   * PARAMETERS: taken from PA_TASK1_PUB.update_tasl_all_info
   * ==========
   *
   * CALLED BY
   *   Called from OAF Application Module
   *
   *************************************************************************/
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
  );
  END XXAH_TASK_RESCHED_PKG;

/
