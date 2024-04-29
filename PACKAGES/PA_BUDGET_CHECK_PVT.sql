--------------------------------------------------------
--  DDL for Package PA_BUDGET_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_CHECK_PVT" AUTHID CURRENT_USER as
/*$Header: PAPMBCVS.pls 120.2 2005/08/19 16:41:55 mwasowic ship $*/

--Package constant used for package version validation

--Global constants to be used in error messages
G_PKG_NAME        CONSTANT VARCHAR2(30) := 'PA_BUDGET_PUB';
G_BUDGET_CODE     CONSTANT VARCHAR2(6)  := 'BUDGET';
G_PROJECT_CODE    CONSTANT VARCHAR2(7)  := 'PROJECT';
G_TASK_CODE    CONSTANT VARCHAR2(4)  := 'TASK';
G_RESOURCE_CODE      CONSTANT VARCHAR2(8)  := 'RESOURCE';

--Locking exception
ROW_ALREADY_LOCKED   EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

--Package constant used for package version validation

G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;

PROCEDURE get_valid_period_dates_Pvt
( p_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_project_id             IN   NUMBER
 ,p_task_id                IN   NUMBER
 ,p_time_phased_type_code  IN   VARCHAR2
 ,p_entry_level_code       IN   VARCHAR2
 ,p_period_name_in         IN   VARCHAR2
 ,p_budget_start_date_in   IN   DATE
 ,p_budget_end_date_in     IN   DATE
 ,p_period_name_out        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_start_date_out  OUT  NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_budget_end_date_out    OUT  NOCOPY DATE --File.Sql.39 bug 4440895

 -- Bug 3986129: FP.M Web ADI Dev changes, new parameters
 ,p_context                IN   VARCHAR2  DEFAULT  NULL
 ,p_calling_model_context  IN   VARCHAR2 DEFAULT 'FINPLANMODEL'
 ,x_error_code             OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE check_entry_method_flags_Pvt
( p_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_amount_code        IN  VARCHAR2
 ,p_budget_entry_method_code  IN  VARCHAR2
 ,p_quantity                  IN  NUMBER
 ,p_raw_cost                  IN  NUMBER
 ,p_burdened_cost             IN  NUMBER
 ,p_revenue                   IN  NUMBER

  --Parameters for finplan model
 ,p_version_type              IN  VARCHAR2 := NULL
 ,P_allow_qty_flag            IN  VARCHAR2 := NULL
 ,P_allow_raw_cost_flag       IN  VARCHAR2 := NULL
 ,P_allow_burdened_cost_flag  IN  VARCHAR2 := NULL
 ,P_allow_revenue_flag        IN  VARCHAR2 := NULL

 -- Bug 3986129: FP.M Web ADI Dev changes, new parameters
 ,p_context                   IN  VARCHAR2   DEFAULT NULL
 ,p_raw_cost_rate             IN  NUMBER     DEFAULT NULL
 ,p_burdened_cost_rate        IN  NUMBER     DEFAULT NULL
 ,p_bill_rate                 IN  NUMBER     DEFAULT NULL
 ,p_allow_raw_cost_rate_flag  IN  VARCHAR2   DEFAULT NULL
 ,p_allow_burd_cost_rate_flag IN  VARCHAR2   DEFAULT NULL
 ,p_allow_bill_rate_flag      IN  VARCHAR2   DEFAULT NULL
 ,x_webadi_error_code         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- Bug 3986129: FP.M Web ADI Dev changes, new api
PROCEDURE validate_uom_passed
( p_context                IN        VARCHAR2    DEFAULT 'WEBADI',
  p_res_list_mem_id        IN        pa_resource_list_members.resource_list_member_id%TYPE,
  p_uom_passed             IN        pa_resource_list_members.unit_of_measure%TYPE,
  x_error_code             OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_return_status          OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data               OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT       NOCOPY NUMBER); --File.Sql.39 bug 4440895

end PA_BUDGET_CHECK_PVT;

 

/
