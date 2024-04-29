--------------------------------------------------------
--  DDL for Package PA_FP_ORG_FCST_GEN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_ORG_FCST_GEN_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPORGS.pls 120.1 2005/08/19 16:27:46 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_ORG_FCST_GEN_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

     TYPE number_data_type_table IS TABLE OF NUMBER
          INDEX BY BINARY_INTEGER;

     TYPE date_data_type_table IS TABLE OF DATE
          INDEX BY BINARY_INTEGER;

     TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
          INDEX BY BINARY_INTEGER;

     TYPE budget_lines_record IS RECORD ( quantity             number
                                         ,raw_cost             number
                                         ,burdened_cost        number
                                         ,lent_resource_cost   number
                                         ,unassigned_time_cost number
                                         ,tp_cost_in           number
                                         ,tp_cost_out          number
                                         ,revenue              number
                                         ,borrowed_revenue     number
                                         ,tp_revenue_in        number
                                         ,tp_revenue_out       number
                                         ,utilization_percent  number
                                         ,utilization_hours    number
                                         ,capacity             number
                                         ,head_count           number);

     TYPE budget_lines_record_table_type IS TABLE OF budget_lines_record
                                         INDEX BY BINARY_INTEGER;
     error_reloop EXCEPTION;
     proj_action_reloop EXCEPTION;

PROCEDURE gen_org_fcst
( errbuff                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,retcode                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_selection_criteria       IN VARCHAR2
                                := NULL
 ,p_is_org                   IN VARCHAR2
                                := NULL
 ,p_organization_id          IN hr_organization_units.organization_id%TYPE
                                := NULL
 ,p_is_start_org             IN VARCHAR2
                                := NULL
 ,p_starting_organization_id IN hr_organization_units.organization_id%TYPE
                                := NULL
 ,p_budget_version_id        IN pa_budget_versions.budget_version_id%TYPE
                                := NULL);


/*************************************************************************
sgoteti 03/03/2005.This API was previously in PAFPCPFS.pls, Copied it here as this will be used
only in Org Forecasting Context. The code is copied without any change from the version
115.36 of PAFPCPFS.pls
**************************************************************************/

PROCEDURE create_res_task_maps(
         p_source_project_id         IN      NUMBER
         ,p_target_project_id        IN      NUMBER
         ,p_source_plan_version_id   IN      NUMBER
         ,p_adj_percentage           IN      NUMBER
         ,p_copy_mode                IN      VARCHAR2 DEFAULT 'W' /* 2920954 */
         ,p_calling_module           IN      VARCHAR2 DEFAULT PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN /* 2920954 */
         ,p_shift_days               IN      NUMBER   DEFAULT NULL -- 3/28/2004 FP M Dev Phase II Effort
         ,x_return_status            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                 OUT     NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

/*************************************************************************
sgoteti 03/03/2005.This API was previously in PAFPCPFS.pls, Copied it here as this will be used
only in Org Forecasting Context. (Note: copy_resource_assignments in latest PAFPCPFB.pls will not
go thru pa_fp_ra_map_tmp). The code is copied without any change from the version 115.36 of P
PAFPCPFS.pls to reduce the impact. The parameter p_rbs_map_diff_flag can be considered as an
obsolete parameter in org forecasting flow.
**************************************************************************/
PROCEDURE copy_resource_assignments(
          p_source_plan_version_id    IN     NUMBER
          ,p_target_plan_version_id   IN     NUMBER
          ,p_adj_percentage           IN     NUMBER
          ,p_rbs_map_diff_flag        IN     VARCHAR2 DEFAULT 'N'
          ,p_calling_context          IN     VARCHAR2 DEFAULT NULL --Bug 4065314
          ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*===================================================================
sgoteti 03/03/2005.This API was previously in PAFPCPFS.pls, Copied it here as this will be used
only in Org Forecasting Context. (Note: Copy_Budget_Lines in latest PAFPCPFB.pls will not
go thru pa_fp_ra_map_tmp). The code is copied without any change from the version 115.36 of P
PAFPCPFS.pls to reduce the impact.
===================================================================*/

PROCEDURE Copy_Budget_Lines(
           p_source_plan_version_id    IN   NUMBER
           ,p_target_plan_version_id   IN   NUMBER
           ,p_adj_percentage           IN   NUMBER
           ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                 OUT  NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

END pa_fp_org_fcst_gen_pub;

 

/
