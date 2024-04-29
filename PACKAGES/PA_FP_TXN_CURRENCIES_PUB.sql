--------------------------------------------------------
--  DDL for Package PA_FP_TXN_CURRENCIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_TXN_CURRENCIES_PUB" AUTHID CURRENT_USER AS
/* $Header: PAFPTXCS.pls 120.1 2005/08/19 16:30:43 mwasowic noship $ */


PROCEDURE Copy_Fp_Txn_Currencies (
          p_source_fp_option_id           IN  NUMBER
          ,p_target_fp_option_id          IN  NUMBER
          ,p_target_fp_preference_code    IN  VARCHAR2
          ,p_plan_in_multi_curr_flag      IN  VARCHAR2
          ,p_approved_rev_plan_type_flag  IN  VARCHAR2  default null--For Bug 2998696
          ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                     OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Insert_Default_Currencies(
         p_project_id                   IN NUMBER
         ,p_fin_plan_type_id            IN NUMBER
         ,p_fin_plan_preference_code    IN VARCHAR2
         ,p_fin_plan_version_id         IN NUMBER
         ,p_project_currency_code       IN VARCHAR2
         ,p_projfunc_currency_code      IN VARCHAR2
         ,p_approved_rev_plan_type_flag IN VARCHAR2
         ,p_target_fp_option_id         IN NUMBER   );

PROCEDURE  Set_Default_Currencies(
      p_target_fp_option_id            IN NUMBER
      ,p_target_preference_code        IN VARCHAR2
      ,p_approved_rev_plan_type_flag   IN VARCHAR2
      ,p_srce_all_default_curr_code    IN VARCHAR2
      ,p_srce_rev_default_curr_code    IN VARCHAR2
      ,p_srce_cost_default_curr_code   IN VARCHAR2
      ,p_project_currency_code         IN VARCHAR2
      ,p_projfunc_currency_code        IN VARCHAR2 );

PROCEDURE enter_agreement_curr_for_ci
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_version_id     IN      pa_budget_versions.budget_Version_id%TYPE
     ,p_ci_id                   IN      pa_budget_Versions.ci_id%TYPE
     ,p_project_currency_code   IN      pa_projects.project_currency_code%TYPE
     ,p_projfunc_currency_code  IN      pa_projects.projfunc_currency_code%TYPE
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Added for bug #2632410. */
FUNCTION Insert_Only_Projfunc_Curr( p_proj_fp_options_id          pa_proj_fp_options.proj_fp_options_id%TYPE
                                   ,p_approved_rev_plan_type_flag pa_proj_fp_options.approved_rev_plan_type_flag%TYPE default null)--for bug 2998696
RETURN  BOOLEAN;

END pa_fp_txn_currencies_pub;
 

/
