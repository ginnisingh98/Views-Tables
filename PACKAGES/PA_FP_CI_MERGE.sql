--------------------------------------------------------
--  DDL for Package PA_FP_CI_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CI_MERGE" AUTHID CURRENT_USER as
/* $Header: PAFPCIMS.pls 120.2.12010000.3 2010/04/23 13:01:19 rrambati ship $ */

--Copy exception
RAISE_COPY_ERROR   EXCEPTION;
PRAGMA EXCEPTION_INIT(RAISE_COPY_ERROR, -502);


PROCEDURE FP_CI_LINK_CONTROL_ITEMS
(
  p_project_id                IN  NUMBER,
  p_s_fp_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
  p_t_fp_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
  p_inclusion_method    IN  VARCHAR2 DEFAULT 'AUTOMATIC',
  p_included_by               IN  NUMBER DEFAULT NULL,
  --Added for bug 3550073
  p_version_type        IN  pa_budget_versions.version_type%TYPE,
  p_ci_id               IN  pa_control_items.ci_id%TYPE,
  p_cost_ppl_qty        IN  pa_fp_merged_ctrl_items.impl_quantity%TYPE,
  p_rev_ppl_qty         IN  pa_fp_merged_ctrl_items.impl_quantity%TYPE,
  p_cost_equip_qty      IN  pa_fp_merged_ctrl_items.impl_equipment_quantity%TYPE,
  p_rev_equip_qty       IN  pa_fp_merged_ctrl_items.impl_equipment_quantity%TYPE,
  p_impl_pfc_raw_cost   IN  pa_fp_merged_ctrl_items.impl_proj_func_raw_cost%TYPE,
  p_impl_pfc_revenue    IN  pa_fp_merged_ctrl_items.impl_proj_func_revenue%TYPE,
  p_impl_pfc_burd_cost  IN  pa_fp_merged_ctrl_items.impl_proj_func_burdened_cost%TYPE,
  p_impl_pc_raw_cost    IN  pa_fp_merged_ctrl_items.impl_proj_raw_cost%TYPE,
  p_impl_pc_revenue     IN  pa_fp_merged_ctrl_items.impl_proj_revenue%TYPE,
  p_impl_pc_burd_cost   IN  pa_fp_merged_ctrl_items.impl_proj_burdened_cost%TYPE,
  p_impl_agr_revenue    IN  pa_fp_merged_ctrl_items.impl_agr_revenue%TYPE,
  x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )  ;

PROCEDURE FP_CI_MERGE_CI_ITEMS
(
  p_project_id                IN NUMBER,
  p_s_fp_ci_id                IN pa_budget_versions.ci_id%TYPE,
  p_t_fp_ci_id                IN pa_budget_versions.ci_id%TYPE,
  p_merge_unmerge_mode        IN VARCHAR2 DEFAULT 'MERGE',
  p_commit_flag               IN VARCHAR2 DEFAULT 'N',
  p_init_msg_list       IN VARCHAR2 DEFAULT 'N',
  p_calling_context           IN VARCHAR2 DEFAULT 'COPY',
  x_warning_flag        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )  ;


PROCEDURE FP_CI_UPDATE_IMPACT
  (
    p_ci_id                     IN pa_ci_impacts.ci_id%TYPE DEFAULT NULL,
    p_status_code           IN pa_ci_impacts.status_code%TYPE DEFAULT NULL,
    p_implementation_date     IN pa_ci_impacts.implementation_date%TYPE DEFAULT NULL,
    p_implemented_by          IN pa_ci_impacts.implemented_by%TYPE DEFAULT NULL,
    p_record_version_number   IN pa_ci_impacts.record_version_number%TYPE DEFAULT NULL,
    p_impacted_task_id        IN pa_ci_impacts.impacted_task_id%TYPE DEFAULT NULL,
    p_impact_type_code      IN  pa_ci_impacts.impact_type_code%TYPE,--For bug 3550073
    p_commit_flag           IN VARCHAR2 DEFAULT 'N',
    p_init_msg_list               IN VARCHAR2 DEFAULT 'N',
    x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )  ;

--Bug 4247703. Added the parameter 4247703. The valid values are NULL or GENERATION
PROCEDURE copy_merged_ctrl_items
   (  p_project_id            IN   pa_budget_versions.project_id%TYPE
     ,p_source_version_id     IN   pa_budget_versions.budget_version_id%TYPE
     ,p_target_version_id     IN   pa_budget_versions.budget_version_id%TYPE
     ,p_calling_context       IN   VARCHAR2 DEFAULT NULL
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE FP_CI_UPDATE_EST_AMOUNTS
  (
    p_project_id        IN pa_budget_versions.project_id%TYPE,
    p_source_version_id       IN pa_budget_versions.budget_version_id%TYPE,
    p_target_version_id       IN pa_budget_versions.budget_version_id%TYPE,
    p_merge_unmerge_mode      IN VARCHAR2 DEFAULT 'MERGE',
    p_commit_flag       IN VARCHAR2 DEFAULT 'N',
    p_init_msg_list           IN VARCHAR2 DEFAULT 'N',
    p_update_agreement        IN VARCHAR2 DEFAULT 'N',
    x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )  ;

PROCEDURE FP_CI_MANUAL_MERGE
(
     p_project_id                  IN  NUMBER,
     p_ci_id                       IN  pa_ci_impacts.ci_id%TYPE,
     p_ci_cost_version_id          IN  pa_budget_versions.budget_version_id%TYPE,
     p_ci_rev_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
     p_ci_all_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
     p_t_fp_version_id             IN  pa_budget_versions.budget_version_id%TYPE,
     p_targ_version_type           IN  pa_budget_versions.version_type%TYPE,
     x_return_status               OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
     x_msg_count                   OUT NOCOPY NUMBER,  --File.Sql.39 bug 4440895
     x_msg_data                    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
----------------------------------------------------------------------------------------------------------
--1.p_context can be PARTIAL_REV( When called from implement partial revenue page )
----IMPL_FIN_IMPACT(when called from implement financial impact page)
----INCLUDE(when called from the include change documents page)
----CI_MERGE( for merging CIs into other CIs)

--2.p_ci_id_tbl, p_ci_cost_version_id_tbl, p_ci_rev_version_id_tbl and p_ci_all_version_id_tbl if passed should
----contain same number of records. p_ci_id_tbl is mandatory. The version ids for the ci_id will be derived if not
----passed. Either all the version ids for the CI should be passed or none of them should be passed

--3.p_fin_plan_type_id_tbl, p_fin_plan_type_name_tbl, p_impl_cost_flag_tbl, p_impl_rev_flag_tbl,
----p_submit_version_flag_tbl should contain same number of records as in p_budget_version_id_tbl
----p_fin_plan_type_id_tbl,p_fin_plan_type_name_tbl contains the fin plan type id and name for the
----corresponding element in p_budget_version_id_tbl
----p_impl_cost_flag_tbl, p_impl_rev_flag_tbl can have values of Y or N. They indicate whether the cost/revenue
----impact can be implemented into the corresponding element in p_budget_version_id_tbl
----p_submit_version_flag_tbl can contain Y or N, if passed. It indicates whether the target budget version id
----should be baselined after implementation or not

--4. p_partial_impl_rev_amt contains the amount that should be implemented partially. This will be passed only
----from implement partial revenue page. In this case ci_id as well as the target budget version id tbls will have
----only one record

--5.p_agreement_id, p_update_agreement_amt_flag, p_funding_category are related to the agreement chosen
--6.p_add_msg_to_stack lets the API know whether the error messages should be added to the fnd_msg_pub or not. If
----Y the messages will be added. They will not be added otherwise

--7.x_translated_msgs_tbl contains the translated error messages. x_translated_err_msg_count indicates the no. of
----elements in x_translated_err_msg_count. x_translated_err_msg_level indicates whether the level of the message is
----EXCEPTION, WARNING OR INFORMATION. They will be populated only if p_add_msg_to_stack is N

--8.p_commit_flag can be Y or N. This is defaulted to N. If passed as Y then the commit will be executed after
----every implementation/inclusion i.e. after one ci has got implemented into the target budget version.


--The processing goes like this
----Each ci_id will be implemented in every version id in p_budget_version_id_tbl. If p_impl_cost_flag_tbl is Y cost
----will be implemented. If p_impl_rev_flag_tbl is Y revenue will be implemented.

-- Bug 3934574 Oct 14 2004  Added a new parameter p_calling_context that would be populated when
-- called as part of budget/forecast generation

PROCEDURE implement_change_document
( p_context                      IN     VARCHAR2
 ,p_calling_context              IN     VARCHAR2                             DEFAULT NULL -- bug 3934574
 ,p_commit_flag                  IN     VARCHAR2                             DEFAULT 'N'
 ,p_ci_id_tbl                    IN     SYSTEM.pa_num_tbl_type
 ,p_ci_cost_version_id_tbl       IN     SYSTEM.pa_num_tbl_type               DEFAULT SYSTEM.pa_num_tbl_type()
 ,p_ci_rev_version_id_tbl        IN     SYSTEM.pa_num_tbl_type               DEFAULT SYSTEM.pa_num_tbl_type()
 ,p_ci_all_version_id_tbl        IN     SYSTEM.pa_num_tbl_type               DEFAULT SYSTEM.pa_num_tbl_type()
 ,p_fin_plan_type_id_tbl         IN     SYSTEM.pa_num_tbl_type               DEFAULT SYSTEM.pa_num_tbl_type()
 ,p_fin_plan_type_name_tbl       IN     SYSTEM.pa_varchar2_150_tbl_type      DEFAULT SYSTEM.pa_varchar2_150_tbl_type()
 ,p_budget_version_id_tbl        IN     SYSTEM.pa_num_tbl_type
 ,p_impl_cost_flag_tbl           IN     SYSTEM.pa_varchar2_1_tbl_type
 ,p_impl_rev_flag_tbl            IN     SYSTEM.pa_varchar2_1_tbl_type
 ,p_submit_version_flag_tbl      IN     SYSTEM.pa_varchar2_1_tbl_type        DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
 ,p_partial_impl_rev_amt         IN     NUMBER                               DEFAULT NULL
 ,p_agreement_id                 IN     pa_agreements_all.agreement_id%TYPE  DEFAULT NULL
 ,p_update_agreement_amt_flag    IN     VARCHAR2                             DEFAULT NULL
 ,p_funding_category             IN     VARCHAR2                             DEFAULT NULL
 ,p_raTxn_rollup_api_call_flag   IN     VARCHAR2                             DEFAULT 'Y'   --IPM Arch Enhacements Bug 4865563
 ,p_add_msg_to_stack             IN     VARCHAR2                             DEFAULT 'Y'
 ,x_translated_msgs_tbl          OUT    NOCOPY SYSTEM.pa_varchar2_2000_tbl_type      --File.Sql.39 bug 4440895
 ,x_translated_err_msg_count     OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_translated_err_msg_level_tbl OUT    NOCOPY SYSTEM.pa_varchar2_30_tbl_type  --File.Sql.39 bug 4440895
 ,x_return_status                OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT    NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

procedure copy_supplier_cost_data(
         p_ci_id_to               IN     NUMBER
        ,p_ci_id_from             IN      NUMBER
        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
		,x_msg_data             OUT    NOCOPY VARCHAR2
) ;
procedure copy_direct_cost_data(
         p_ci_id_to               IN      NUMBER
        ,p_ci_id_from             IN      NUMBER
        ,p_bv_id                  IN      pa_budget_versions.budget_version_id%TYPE
        ,p_project_id             IN      NUMBER
        ,x_return_status          OUT     NOCOPY VARCHAR2
        ,x_msg_count              OUT     NOCOPY NUMBER
		,x_msg_data               OUT     NOCOPY VARCHAR2
);
-- Start of functions internal to implement_ci_into_single_ver API
FUNCTION get_task_id(p_planning_level IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE,
                     p_task_id        IN pa_resource_assignments.task_id%TYPE)
RETURN NUMBER;

FUNCTION get_mapped_ra_id(p_task_id                IN pa_resource_assignments.task_id%TYPE,
                          p_rlm_id                 IN pa_resource_assignments.resource_list_member_id%TYPE,
                          p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE DEFAULT NULL,
                          p_fin_plan_level_code    IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE  DEFAULT NULL
                          )
RETURN NUMBER;
FUNCTION get_mapped_dml_code(p_task_id        IN pa_resource_assignments.task_id%TYPE,
                             p_rlm_id         IN pa_resource_assignments.resource_list_member_id%TYPE,
                             p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE DEFAULT NULL,
                             p_fin_plan_level_code    IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE DEFAULT NULL

                             )
RETURN VARCHAR2 ;

-- End of functions internal to implement_ci_into_single_ver API

end pa_fp_ci_merge;

/
