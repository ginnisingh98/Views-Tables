--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_TYPES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_TYPES_UTILS" AUTHID CURRENT_USER as
/* $Header: PAFTYPUS.pls 120.1 2005/08/19 16:32:33 mwasowic noship $ */

procedure name_val
    (p_name                           IN     pa_fin_plan_types_tl.name%TYPE,
     p_fin_plan_type_id               IN     pa_fin_plan_types_tl.fin_plan_type_id%TYPE,
     x_return_status                  OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                      OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/****************************************************************************************
 * Dusan changes. Moved this api to pa_fin_plan_utils
procedure end_date_active_val
    (p_start_date_active              IN     pa_fin_plan_types_b.start_date_active%type,
     p_end_date_active                IN     pa_fin_plan_types_b.end_date_active%type,
     x_return_status                OUT    VARCHAR2,
     x_msg_count                    OUT    NUMBER,
     x_msg_data                       OUT    VARCHAR2);
*****************************************************************************************/

/***********************************************************************
Commented since generated_flag and used_in_billing_flag
are obsolete after change in functionality

procedure generated_flag_val
    (p_fin_plan_type_id               IN     pa_fin_plan_types_b.fin_plan_type_id%type,
     p_generated_flag                 IN     pa_fin_plan_types_b.generated_flag%type,
     p_pre_defined_flag               IN     pa_fin_plan_types_b.pre_defined_flag%type,
     p_fin_plan_type_code             IN     pa_fin_plan_types_b.fin_plan_type_code%type,
     p_name                           IN     pa_fin_plan_types_tl.name%type,
     x_return_status                  OUT    VARCHAR2,
     x_msg_count                      OUT    NUMBER,
     x_msg_data                       OUT    VARCHAR2);

procedure used_in_billing_flag_val
    (p_fin_plan_type_id               IN     pa_fin_plan_types_b.fin_plan_type_id%type,
     p_used_in_billing_flag           IN     pa_fin_plan_types_b.used_in_billing_flag%type,
     x_return_status                OUT    VARCHAR2,
     x_msg_count                    OUT    NUMBER,
     x_msg_data                       OUT    VARCHAR2);

**************************************************************************/
procedure delete_val
    (p_fin_plan_type_id               IN     pa_fin_plan_types_b.fin_plan_type_id%type,
     x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                       OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure validate
    (p_fin_plan_type_id               IN     pa_fin_plan_types_b.fin_plan_type_id%type,
     p_name                           IN     pa_fin_plan_types_tl.name%type,
     p_start_date_active              IN     pa_fin_plan_types_b.start_date_active%type,
     p_end_date_active                IN     pa_fin_plan_types_b.end_date_active%type,
     p_generated_flag                 IN     pa_fin_plan_types_b.generated_flag%type,
     p_used_in_billing_flag           IN     pa_fin_plan_types_b.used_in_billing_flag%type,
     p_record_version_number          IN     pa_fin_plan_types_b.record_version_number%type,
     p_fin_plan_type_code             IN     pa_fin_plan_types_b.fin_plan_type_code%type,
     p_pre_defined_flag               IN     pa_fin_plan_types_b.pre_defined_flag%type,
     x_return_status                  OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                      OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                       OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

function isfptypeused
     (p_fin_plan_type_id              IN     pa_fin_plan_types_b.fin_plan_type_id%type)
     return VARCHAR2;

/* FP M - dbora Additional FUNCTIONS and PROCEDURE
*/
FUNCTION PARTIALLY_IMPL_COS_EXIST
      (p_fin_plan_type_id             IN     pa_fin_plan_types_b.fin_plan_type_id%TYPE,
       p_ci_type_id                   IN     pa_control_items.ci_type_id%TYPE )
      RETURN VARCHAR2;

FUNCTION GET_CONCAT_STATUSES
      (p_fin_plan_type_id             IN     pa_fin_plan_types_b.fin_plan_type_id%TYPE,
       p_ci_type_id                   IN     pa_pt_co_impl_statuses.ci_type_id%TYPE,
       p_impact_type_code             IN     pa_pt_co_impl_statuses.version_type%TYPE)
      RETURN VARCHAR2;

PROCEDURE GET_WORKPLAN_PT_DETAILS
      (x_workplan_pt_id               OUT    NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
       x_w_pt_attached_to_proj        OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_msg_data                     OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION Is_Rev_Impl_Partially
         (p_ci_id                IN        pa_budget_versions.ci_id%TYPE,
          p_project_id           IN        pa_budget_versions.project_id%TYPE)
         RETURN VARCHAR2;

END pa_fin_plan_types_utils;

 

/
