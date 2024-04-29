--------------------------------------------------------
--  DDL for Package PA_PLANNING_TRANSACTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLANNING_TRANSACTION_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAFPPTUS.pls 120.2.12010000.3 2009/10/09 06:40:57 rrambati ship $ */

----------------------------------
--Functions/Procedures Declaration
----------------------------------
FUNCTION Get_Wp_Budget_Version_Id (
         p_struct_elem_version_id IN pa_budget_versions.project_structure_version_id%TYPE
         )
RETURN NUMBER;


PROCEDURE Get_Res_Class_Rlm_Ids
    (p_project_id                   IN     pa_projects_all.project_id%TYPE,
     p_resource_list_id             IN     pa_resource_lists_all_bg.resource_list_id%TYPE,
     x_people_res_class_rlm_id      OUT    NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_equip_res_class_rlm_id       OUT    NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_fin_res_class_rlm_id         OUT    NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_mat_res_class_rlm_id         OUT    NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- This API will return the default planning start and end dates based on the element version
-- Depending on the existence either the txn, actual, estimated or scheduled dates of the task in the priority of
-- the order mentioned will be returned.If none of the them are there then the dates of the parent structure
-- version id will be passed. If the dates are not there for the parent version also then sysdate will be returned

-- The output tables x_planning_start_date_tbl and x_planning_end_date_tbl will have the same no of records as
-- in the table p_element_version_id_tbl. Duplicates are allowed in input and the derivation will be done for the duplicate
-- tasks also

-- Included p_project_id as parameter. For elem vers id as 0, project start and end dates are used.

-- Added New I/p params p_planning_start_date_tbl and x_planning_end_date_tbl -- 3793623
-- Dates will not be defaulted if they are passed to the API at a particular index.
PROCEDURE get_default_planning_dates
(  p_project_id                      IN    pa_projects_all.project_id%TYPE
  ,p_element_version_id_tbl          IN    SYSTEM.pa_num_tbl_type
  ,p_project_structure_version_id    IN    pa_budget_versions.project_structure_version_id%TYPE
  ,p_planning_start_date_tbl         IN    SYSTEM.pa_date_tbl_type  DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
  ,p_planning_end_date_tbl           IN    SYSTEM.pa_date_tbl_type  DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
  ,x_planning_start_date_tbl         OUT   NOCOPY SYSTEM.pa_date_tbl_type --File.Sql.39 bug 4440895
  ,x_planning_end_date_tbl           OUT   NOCOPY SYSTEM.pa_date_tbl_type --File.Sql.39 bug 4440895
  ,x_msg_data                        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                   OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--This procedure populates the tmp table PJI_FM_EXTR_PLAN_LINES  and calls the API
--PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE . The valid values for p_source are
-- 1. PA_RBS_PLANS_OUT_TMP (This is the tmp table which contains the mapped rbs elemend ids ). The PJI API will
--    be called for the rbs element ids availabe in the PA_RBS_PLANS_OUT_TMP, if the new rbs element id is different
--    from the already existing rbs element id in pa_resource_assignments
-- 2. PA_FP_RA_MAP_TMP (This is the global temporary table which contains the resouce assignments in the source that
--    should copied. This is used for copying a version fully or some of the assignments in it ). This table is used
--    as the reference for deciding the budget lines for which reporting lines should be created
-- 3. PL-SQL : The source will be pl/sql if the pl/sql tables are populated. These pl/sql tables will be used in
--    populated the tmp table for calling the PJI Update API.
PROCEDURE call_update_rep_lines_api
(
   p_source                         IN    VARCHAR2
  ,p_budget_Version_id              IN    pa_budget_Versions.budget_version_id%TYPE DEFAULT NULL--Req only when
                                                                                    --p_source is PL-SQL
  ,p_resource_assignment_id_tbl     IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_period_name_tbl                IN    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
  ,p_start_date_tbl                 IN    SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type()
  ,p_end_date_tbl                   IN    SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type()
  ,p_txn_currency_code_tbl          IN    SYSTEM.pa_varchar2_15_tbl_type   DEFAULT SYSTEM.pa_varchar2_15_tbl_type()
  ,p_txn_raw_cost_tbl               IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_txn_burdened_cost_tbl          IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_txn_revenue_tbl                IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_project_raw_cost_tbl           IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_project_burdened_cost_tbl      IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_project_revenue_tbl            IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_raw_cost_tbl                   IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_burdened_cost_tbl              IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_revenue_tbl                    IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_cost_rejection_code_tbl        IN    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
  ,p_revenue_rejection_code_tbl     IN    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
  ,p_burden_rejection_code_tbl      IN    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
  ,p_other_rejection_code           IN    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
  ,p_pc_cur_conv_rej_code_tbl       IN    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
  ,p_pfc_cur_conv_rej_code_tbl      IN    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
  ,p_quantity_tbl                   IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_rbs_element_id_tbl             IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_task_id_tbl                    IN    SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type()
  ,p_res_class_code_tbl             IN    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
  ,p_rate_based_flag_tbl            IN    SYSTEM.pa_varchar2_1_tbl_type   DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
  ,p_qty_sign                       IN    NUMBER                           DEFAULT 1 --for bug 4543744
  ,x_return_status                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                      OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                       OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


END PA_PLANNING_TRANSACTION_UTILS;

/
