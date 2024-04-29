--------------------------------------------------------
--  DDL for Package PA_PROJ_TASK_STRUC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_TASK_STRUC_PUB" AUTHID DEFINER AS
/* $Header: PAPSWRPS.pls 120.2.12000000.3 2007/06/29 07:46:35 sugupta ship $ */


-- API name                      : Create_default_structure
-- Type                          : PL/SQL Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_dest_project_id            IN NUMBER
-- p_dest_project_name          IN VARCHAR2
-- p_dest_project_number        IN VARCHAR2
-- p_dest_description           IN VARCHAR2
-- p_dest_org_id                IN NUMBER
-- x_msg_count             OUT NUMBER
-- x_msg_data              OUT VARCHAR2
-- x_return_status         OUT VARCHAR2
--
--  History
--
--  14-DEC-01   MAansari             -Created
--

-- <Bug#2843596>
g_project_id  NUMBER;
g_workplan_struct_id  NUMBER;
g_financial_struct_id  NUMBER;
g_sharing_enabled  VARCHAR2(1);
-- </Bug#2843596>

PROCEDURE Create_default_structure
( p_dest_project_id            IN NUMBER
 ,p_dest_project_name          IN VARCHAR2
 ,p_dest_project_number        IN VARCHAR2
 ,p_dest_description           IN VARCHAR2
 ,p_struc_type            IN VARCHAR2 := 'WORKPLAN'
 ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


-- API name                      : create_default_task_structure
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id            IN NUMBER
-- x_msg_count             OUT NUMBER
-- x_msg_data              OUT VARCHAR2
-- x_return_status         OUT VARCHAR2
--
--  History
--
--  14-DEC-01   MAansari             -Created
--
--

PROCEDURE create_default_task_structure
( p_project_id            IN NUMBER
 ,p_struc_type            IN VARCHAR2 := 'WORKPLAN'
 ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


-- API name                      : create_task_structure
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id            IN NUMBER
--  ,p_task_id              IN NUMBER
--  ,p_parent_task_id       IN NUMBER
--  ,p_task_number          IN VARCHAR2
--  ,p_task_name            IN VARCHAR2
--  ,p_task_description     IN VARCHAR2
--  ,p_carrying_out_organization_id NUMBER
-- x_msg_count             OUT NUMBER
-- x_msg_data              OUT VARCHAR2
-- x_return_status         OUT VARCHAR2
--
--  History
--
--  14-DEC-01   MAansari             -Created
--
--

PROCEDURE create_task_structure(
   p_calling_module         IN VARCHAR2 := 'FORMS'
  ,p_project_id           IN NUMBER
  ,p_task_id              IN NUMBER
  ,p_parent_task_id       IN NUMBER
  ,p_ref_task_id          IN NUMBER   := -9999
  ,p_task_number          IN VARCHAR2
  ,p_task_name            IN VARCHAR2
  ,p_task_description     IN VARCHAR2
  ,p_carrying_out_organization_id IN NUMBER
  ,p_structure_type       IN VARCHAR2 := 'FINANCIAL'
  ,p_actual_start_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_actual_finish_date                 IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_early_start_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_early_finish_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_late_start_date                    IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_late_finish_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_scheduled_start_date               IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_scheduled_finish_date              IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_OBLIGATION_START_DATE              IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_OBLIGATION_FINISH_DATE             IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_ESTIMATED_START_DATE               IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_ESTIMATED_FINISH_DATE              IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_BASELINE_START_DATE                IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_BASELINE_FINISH_DATE               IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_CLOSED_DATE                        IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_WQ_UOM_CODE                        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_WQ_ITEM_CODE                       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_STATUS_CODE                        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_WF_STATUS_CODE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_PM_SOURCE_CODE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_PRIORITY_CODE                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_MILESTONE_FLAG                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_CRITICAL_FLAG                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_INC_PROJ_PROGRESS_FLAG             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_LINK_TASK_FLAG                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_CALENDAR_ID                        IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_PLANNED_EFFORT                     IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_DURATION                           IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_PLANNED_WORK_QUANTITY              IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_TASK_TYPE                          IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_PM_SOURCE_reference                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_location_id                        IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_manager_person_id                  IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_structure_version_id               IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_parent_structure_id                IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_phase_version_id                   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_phase_code                         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_create_task_version_only           IN VARCHAR2 := 'N'
  ,p_financial_task_flag                IN VARCHAR2 := 'Y'   --bug 3301192

-- (begin venkat) new params for bug #3450684 ----------------------------------------------
,p_ext_act_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
,p_ext_remain_duration         IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
,p_ext_sch_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
-- (end venkat) new params for bug #3450684 -------------------------------------------------

  -- (begin) add new params bug - 3654243 -----
  ,p_base_percent_comp_deriv_code	IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_sch_tool_tsk_type_code		IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_type_code		IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_date			IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_free_slack				IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_total_slack			IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_effort_driven_flag			IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_level_assignments_flag		IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_invoice_method			IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_customer_id			IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_gen_etc_source_code		IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- (end) add new params bug - 3654243 -----
--Bug 6046869
  ,p_validate_dff                  IN VARCHAR2 := 'N'
  ,p_attribute_category            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10                   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute11                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

  ,x_task_version_id                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_task_id                            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- API name                      : update_task_structure
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
--   p_calling_module                   IN VARCHAR2
--  ,p_task_id                          IN NUMBER
--  ,p_task_number                      IN VARCHAR2
--  ,p_task_name                        IN VARCHAR2
--  ,p_task_description                 IN VARCHAR2
--  ,p_carrying_out_organization_id     IN NUMBER
--  ,p_task_manager_id                  IN NUMBER
--  ,p_pm_product_code                  IN VARCHAR2
--  ,p_pm_task_reference                IN VARCHAR2
--  ,p_record_version_number           IN NUMBER
--  ,x_msg_count                        OUT NUMBER
--  ,x_msg_data                         OUT VARCHAR2
--  ,x_return_status                    OUT VARCHAR2--
--  History
--
--  25-APR-02      MAansari             -Created
--  05-APR-2004    Rakesh Raghavan      Progress Management Changes. Bug # 3420093.
--
--  Notes: This api is called from form PAXPREPR.fmb ON-UPDATE of tasks block.
--         The call is in PA_PROJECT_STRUCTURES.update_task_structure API.

PROCEDURE update_task_structure
(
   p_calling_module                   IN VARCHAR2 := 'FORMS'
  ,p_ref_task_id                      IN NUMBER
  ,p_project_id                       IN NUMBER
  ,p_task_id                          IN NUMBER
  ,p_task_number                      IN VARCHAR2
  ,p_task_name                        IN VARCHAR2
  ,p_task_description                 IN VARCHAR2
  ,p_carrying_out_organization_id     IN NUMBER
  ,p_structure_type                   IN VARCHAR2 := 'FINANCIAL'
  ,p_task_manager_id                  IN NUMBER
  ,p_pm_product_code                  IN VARCHAR2
  ,p_pm_task_reference                IN VARCHAR2
  ,p_location_id                      IN NUMBER
  ,p_actual_start_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_actual_finish_date                 IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_early_start_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_early_finish_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_late_start_date                    IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_late_finish_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_scheduled_start_date               IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_scheduled_finish_date              IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_OBLIGATION_START_DATE              IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_OBLIGATION_FINISH_DATE             IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_ESTIMATED_START_DATE               IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_ESTIMATED_FINISH_DATE              IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_BASELINE_START_DATE                IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_BASELINE_FINISH_DATE               IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_CLOSED_DATE                        IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,P_WQ_UOM_CODE                        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_WQ_ITEM_CODE                       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_STATUS_CODE                        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_WF_STATUS_CODE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_PRIORITY_CODE                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_MILESTONE_FLAG                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_CRITICAL_FLAG                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_INC_PROJ_PROGRESS_FLAG             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_LINK_TASK_FLAG                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_CALENDAR_ID                        IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_PLANNED_EFFORT                     IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_DURATION                           IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_PLANNED_WORK_QUANTITY              IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,P_TASK_TYPE                          IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_structure_version_id               IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_parent_structure_id                IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_phase_version_id                   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_phase_code                         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- (begin venkat) new params for bug #3450684 ----------------------------------------------
  ,p_ext_act_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
  ,p_ext_remain_duration         IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
  ,p_ext_sch_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
-- (end venkat) new params for bug #3450684 -------------------------------------------------
-- (begin) add new params bug - 3654243 -----
  ,p_base_percent_comp_deriv_code	IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_sch_tool_tsk_type_code		IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_type_code		IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_date			IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_free_slack				IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_total_slack			IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_effort_driven_flag			IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_level_assignments_flag		IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_invoice_method			IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_customer_id			IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_gen_etc_source_code		IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- (end) add new params bug - 3654243 -----

-- Progress Management Changes. Bug # 3420093.
  ,p_etc_effort                 IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_percent_complete           IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- Progress Management Changes. Bug # 3420093.
--rtarway, 3908013
  ,p_attribute_category               IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10                   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Bug 6046869
  ,p_attribute11                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 --end rtarway, 3908013
  ,x_msg_count                        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- API name                      : delete_task_structure
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
--   p_calling_module                   IN VARCHAR2
--  ,p_task_id                          IN NUMBER
--  ,p_record_version_number           IN NUMBER
--  ,x_msg_count                        OUT NUMBER
--  ,x_msg_data                         OUT VARCHAR2
--  ,x_return_status                    OUT VARCHAR2--
--  History
--
--  25-APR-02   MAansari             -Created
--
--  Notes: This api is called from form PAXPREPR.fmb ON-DELETE of tasks block.
--         The call is in PA_PROJECT_STRUCTURES.delete_task_structure API.

PROCEDURE delete_task_structure
(
   p_calling_module                   IN VARCHAR2
  ,p_task_id                          IN NUMBER
  ,p_task_version_id                  IN NUMBER := -9999
  ,p_project_id                  IN NUMBER := -9999      --bug 2765115
  ,p_structure_type              IN VARCHAR2 := 'FINANCIAL'   --bug 3301192
  ,x_msg_count                        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- API name                      : delete_project_structure
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
--   p_calling_module                   IN VARCHAR2
--  ,p_project_id                       IN NUMBER
--  ,x_msg_count                        OUT NUMBER
--  ,x_msg_data                         OUT VARCHAR2
--  ,x_return_status                    OUT VARCHAR2--
--  History
--
--  26-APR-02   MAansari             -Created
--
--  Notes: This api is called from form PAXPREPR.fmb ON-DELETE of tasks block.
--         The call is in PA_PROJECT_STRUCTURES.delete_task_structure API.

PROCEDURE delete_project_structure
(
   p_calling_module                   IN VARCHAR2
  ,p_project_id                          IN NUMBER
  ,x_msg_count                        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- API name                      : Published_version_exists
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                       IN NUMBER
--  History
--
--  29-APR-02   MAansari             -Created
--
--  Notes: This api is called from form PAXPREPR.fmb ON-DELETE of task block.
--         To check if there exists any published ver.

FUNCTION Published_version_exists
(
  p_project_id                       IN NUMBER
 ) RETURN VARCHAR2;

-- API name                      : approve_project
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- p_project_id                       IN NUMBER
--  History
--
--  29-APR-02   MAansari             -Created
--
--  Notes: This api is called from Pa_project_stus_utils.Handle_Project_Status_Change api
--         to check the following before changing status to APPROVE.
--         1) The project should contain one structure for Workplan and Costing
--         2) There should be a published version.

FUNCTION approve_project
(
  p_project_id                       IN NUMBER
 ) RETURN VARCHAR2;

-- API name                      : Is_PJT_Licensed
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
--  History
--
--  01-MAY-02   MAansari             -Created
--
--  Notes: This api is called from Projects form and Self Service to display SPLIT_COST_FROM_WORKPLAN_FLAG.

FUNCTION Is_PJT_Licensed RETURN VARCHAR2;

-- API name                      : Progress_rec_exists
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- p_project_id                  NUMBER
--  History
--
--  01-MAY-02   MAansari             -Created
--
--  Notes: This api is called from Projects form and Self Service to allow users to update
--  SPLIT_COST_FROM_WORKPLAN_FLAG.

FUNCTION Progress_rec_exists( p_project_id NUMBER ) RETURN VARCHAR2;

-- API name                      : create_delete_workplan_struc
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                  NUMBER
-- p_calling_module                   IN VARCHAR2
-- p_project_id                       IN NUMBER
-- p_project_number                   IN VARCHAR2 := 'JUNK_CHARS'
-- p_project_name                     IN VARCHAR2 := 'JUNK_CHARS'
-- p_project_description              IN VARCHAR2 := 'JUNK_CHARS'
-- p_split_workplan                   IN VARCHAR2
--  History
--
--  01-MAY-02   MAansari             -Created
--
--  Notes: This api is called from Projects form and Self Service when the SPLIT_COST_FROM_WORKPLAN_FLAG
--         is checked

PROCEDURE create_delete_workplan_struc(
   p_calling_module                   IN VARCHAR2
  ,p_project_id                       IN NUMBER
  ,p_project_number                   IN VARCHAR2
  ,p_project_name                     IN VARCHAR2
  ,p_project_description              IN VARCHAR2
  ,p_split_workplan                   IN VARCHAR2
  ,x_msg_count                        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

-- API name                      : Copy_Structure
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_src_project_id                  NUMBER
-- p_dest_project_id                  NUMBER
--  History
--
--  03-MAY-02   MAansari             -Created
--
--  Notes: This api is called from PA_PROJECT_CORE1.COPY_PROJECT

PROCEDURE Copy_Structure(
   p_src_project_id                       IN NUMBER
  ,p_dest_project_id                      IN NUMBER
  ,p_delta                                IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_copy_task_flag                   IN VARCHAR2 := 'Y'
  ,p_dest_template_flag            IN VARCHAR2    := 'N'     --bug 2805602
  ,p_src_template_flag            IN VARCHAR2    := 'N'   --bug 2805602
  ,p_dest_project_name             IN VARCHAR2               --bug 2805602
  ,p_target_start_date             IN DATE                --bug 2805602
  ,p_target_finish_date             IN DATE               --bug 2805602
  ,p_calendar_id                   IN NUMBER
  ,x_msg_count                        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );


-- API name                      : Clean_unwanted_tasks
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                  NUMBER
--  History
--
--  25-MAY-02   MAansari             -Created
--
--  Notes: This api is called from PA_PROJECT_PUB.CREATE_PROJECT to clean up the tasks in pa_proj_elements that were created
--         by calling copy structure api. Copy structure api copies template's tasks to pro_elements though there
--         are no pa_TASKs for the new project. However pa_tasks and pa_proj_elements must be in syn. To d this we need to firts remove
--         tasks from pa_proj_elements as they were erroneously created by COPY_STRUCTURE and then call create_default_structure
--         to syn up pa_pro_elements with pa_tasks.
--

PROCEDURE Clean_unwanted_tasks(
   p_project_id                       IN NUMBER
  ,x_msg_count                        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) ;

-- API name                      : get_task_above
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters

--  History
--
--  14-AUG-02   MAansari             -Created
--
--  Notes: This api is called from Projects form and Self Service when the SPLIT_COST_FROM_WORKPLAN_FLAG
--         is checked

/*PROCEDURE get_task_above(
   p_task_id                              IN      NUMBER
  ,p_tasks_in                             IN      pa_project_pub.task_in_tbl_type
  ,p_tasks_out                            IN      pa_project_pub.task_out_tbl_type
  ,x_task_id_above                        OUT     NUMBER
  ,x_return_status                    OUT VARCHAR2
 );*/

-- API name                      : convert_pm_parent_task_ref
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters

--  History
--
--  14-AUG-02   MAansari             -Created
--
--  Notes: This api is not included in PA_PROJECT_PVT to avoid dependency.

PROCEDURE convert_pm_parent_task_ref(
   p_pm_parent_task_reference             IN      VARCHAR2
  ,p_project_id                           IN      NUMBER
  ,x_parent_task_id                       OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : publish_structure
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters

--  History
--
--  19-AUG-02   MAansari             -Created
--
--  Notes: This api is a wrapper called from AMG

PROCEDURE publish_structure(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_responsibility_id                 IN  NUMBER      := 0
   ,p_structure_version_id              IN  NUMBER
   ,p_publish_structure_ver_name        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_ver_desc                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_original_baseline_flag            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_current_baseline_flag             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_published_struct_ver_id           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : delete_structure_version
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters

--  History
--
--  19-AUG-02   MAansari             -Created
--
--  Notes: This api is a wrapper called from AMG

PROCEDURE delete_structure_version(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : create_structure
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters

--  History
--
--  19-AUG-02   HUBERT             -Created
--
--  Notes: This api is a wrapper called from AMG

procedure create_structure(
    p_project_id             IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_type         IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_version_name IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_description            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_structure_id           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_structure_version_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : create_update_struct_ver
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters

--  History
--
--  19-AUG-02   HUBERT             -Created
--
--  Notes: This api is a wrapper called from AMG

procedure create_update_struct_ver(
    p_project_id             IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_type         IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_version_name IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_version_id   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_description            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_structure_version_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : IS_WP_SEPARATE_FROM_FN
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- p_project_id                       IN NUMBER
--  History
--
--  21-AUG-02   MAansari             -Created
--
--  Notes: This api is returns 'Y' if WORKPLAN is separate from
--         FINANCIAL structure

FUNCTION IS_WP_SEPARATE_FROM_FN
(
  p_project_id                       IN NUMBER
 ) RETURN VARCHAR2;


-- API name                      : IS_WP_VERSIONING_ENABLED
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- p_project_id                       IN NUMBER
--  History
--
--  22-AUG-02   MAansari             -Created
--
--  Notes: This api is returns 'Y' if WORKPLAN is separate from
--         FINANCIAL structure

FUNCTION IS_WP_VERSIONING_ENABLED
(
  p_project_id                       IN NUMBER
 ) RETURN VARCHAR2;

-- API name                      : get_proj_dates_delta
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : NUMBER
-- Prameters
-- p_project_id                       IN NUMBER
--  History
--
--  22-AUG-02   MAansari             -Created
--
--  Notes:

     -- get original project start and completion dates
     -- determine the shift days (delta).
     -- delta = new project start date - nvl(old project start date,
     --             earlist task start date)

   --        old project   new project
   --  case  start date    start date    new start date     new end date
   --  ----   -----------   -----------  -----------------  -----------------
   --   A     not null      not null     old start date     old end date
   --                          + delta      + delta
   --   B-1   null      not null     old start date     old end date
   --         (old task has start date)    + delta         + delta
   --   B-2   null      not null     new proj start     new proj completion
   --         (old task has no start date) date            date
   --   C     not null       null   old start date         old end date
   --   D     null      null   old start date         old end date

FUNCTION get_proj_dates_delta(
   x_orig_project_id  IN NUMBER
  ,x_start_date       IN DATE )
RETURN NUMBER;

-- API name                      : create_task_structure2
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id            IN NUMBER
--  ,p_task_id              IN NUMBER
--  ,p_parent_task_id       IN NUMBER
--  ,p_task_number          IN VARCHAR2
--  ,p_task_name            IN VARCHAR2
--  ,p_task_description     IN VARCHAR2
--  ,p_carrying_out_organization_id NUMBER
-- x_msg_count             OUT NUMBER
-- x_msg_data              OUT VARCHAR2
-- x_return_status         OUT VARCHAR2
--
--  History
--
--  22-AUG-01   MAansari             -Created
--
--  Notes : THis is API is created to avoid the Implementation level error that is thrown
--          in the forms if any parameter with default containg a remote package variable is referenced.

PROCEDURE create_task_structure2(
   p_calling_module         IN VARCHAR2 := 'FORMS'
  ,p_project_id           IN NUMBER
  ,p_task_id              IN NUMBER
  ,p_parent_task_id       IN NUMBER
  ,p_ref_task_id          IN NUMBER   := -9999
  ,p_task_number          IN VARCHAR2
  ,p_task_name            IN VARCHAR2
  ,p_task_description     IN VARCHAR2
  ,p_carrying_out_organization_id IN NUMBER
  ,p_structure_type       IN VARCHAR2 := 'FINANCIAL'
  ,P_PM_SOURCE_reference                IN VARCHAR2
  ,P_PM_SOURCE_code                     IN VARCHAR2
  ,p_task_manager_id                  IN NUMBER
  ,p_location_id                      IN NUMBER
  ,p_financial_task_flag              IN VARCHAR2 := 'Y'   --bug 3301192
  ,x_task_version_id                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_task_id                            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- API name                      : update_task_structure2
-- Type                          : PL/sql Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
--   p_calling_module                   IN VARCHAR2
--  ,p_task_id                          IN NUMBER
--  ,p_task_number                      IN VARCHAR2
--  ,p_task_name                        IN VARCHAR2
--  ,p_task_description                 IN VARCHAR2
--  ,p_carrying_out_organization_id     IN NUMBER
--  ,p_task_manager_id                  IN NUMBER
--  ,p_pm_product_code                  IN VARCHAR2
--  ,p_pm_task_reference                IN VARCHAR2
--  ,p_record_version_number           IN NUMBER
--  ,x_msg_count                        OUT NUMBER
--  ,x_msg_data                         OUT VARCHAR2
--  ,x_return_status                    OUT VARCHAR2--
--  History
--
--  22-AUG-02   MAansari             -Created
--
--  Notes : THis is API is created to avoid the Implementation level error that is thrown
--          in the forms if any parameter with default containg a remote package variable is referenced.

PROCEDURE update_task_structure2
(
   p_calling_module                   IN VARCHAR2 := 'FORMS'
  ,p_ref_task_id                      IN NUMBER
  ,p_project_id                       IN NUMBER
  ,p_task_id                          IN NUMBER
  ,p_task_number                      IN VARCHAR2
  ,p_task_name                        IN VARCHAR2
  ,p_task_description                 IN VARCHAR2
  ,p_carrying_out_organization_id     IN NUMBER
  ,p_structure_type                   IN VARCHAR2 := 'FINANCIAL'
  ,p_task_manager_id                  IN NUMBER
  ,p_pm_product_code                  IN VARCHAR2
  ,p_pm_task_reference                IN VARCHAR2
  ,p_location_id                      IN NUMBER
  ,x_msg_count                        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- API name                      : get_struc_task_ver_ids
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                       IN NUMBER
--  History
--
--  26-AUG-02   MAansari             -Created
--
--  Notes: This api returns task_version_id and parent_structure_version_id for the tasks
--         displayed in Forms.

PROCEDURE get_struc_task_ver_ids
(
  p_project_id                       IN NUMBER
  ,p_task_id                          IN NUMBER
  ,x_task_version_id                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_parent_struc_version_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 );

-- API name                      : WP_STR_EXISTS
-- Type                          : PL/sql Public Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- p_project_id                       IN NUMBER
--  History
--
--  21-AUG-02   MAansari             -Created
--
--  Notes: This api is returns 'TRUE' if WORKPLAN str exists

FUNCTION WP_STR_EXISTS
(
  p_project_id                       IN NUMBER
 ) RETURN VARCHAR2;

FUNCTION DATE_SYNC_UP_METHOD
(
  p_project_id                       IN NUMBER
 ) RETURN VARCHAR2;

PROCEDURE update_trans_dates(
   p_project_id                       IN  NUMBER
  ,x_msg_count                        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE update_wp_calendar(
    p_project_id                      IN  NUMBER
   ,p_calendar_id                     IN  NUMBER
   ,x_return_status                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );



/*
This api is created to create task versions when updating a project.
When you update a project you can create a working structure version and add
the existing tasks to the new str version. In this case the api should create task versions
but not tasks.
*/

PROCEDURE create_tasks_versions_only(
   p_calling_module       IN VARCHAR2 := 'FORMS'
  ,p_structure_type       IN VARCHAR2 := 'FINANCIAL'
  ,p_project_id           IN NUMBER
  ,p_structure_version_id IN NUMBER
  ,p_pm_product_code      IN VARCHAR2 := 'JUNK_CHARS'
  ,p_tasks_in             IN pa_project_pub.task_in_tbl_type
  ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--FUNCTION check_multiple_version

PROCEDURE recalc_task_weightings(
   p_tasks_in             IN pa_project_pub.task_out_tbl_type
  ,p_task_version_id      IN NUMBER
  ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

FUNCTION GET_MAX_LAST_UPD_DT_WRKNG_VER
  (  p_structure_version_id IN NUMBER
  ) return DATE;

PROCEDURE copy_structures_tasks_bulk
( p_api_version                  IN NUMBER      := 1.0
 ,p_commit                       IN VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list                IN VARCHAR2    := FND_API.G_TRUE
 ,p_validate_only                IN VARCHAR2    := FND_API.G_FALSE
 ,p_validation_level             IN VARCHAR2    := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module               IN VARCHAR2    := 'SELF_SERVICE'
 ,p_debug_mode                   IN VARCHAR2    := 'N'
 ,p_max_msg_count                IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_src_project_id               IN NUMBER
 ,p_dest_project_id              IN NUMBER
 ,p_delta                        IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_copy_task_flag               IN VARCHAR2    := 'Y'
 ,p_dest_template_flag           IN VARCHAR2    := 'N'     --bug 2805602
 ,p_src_template_flag            IN VARCHAR2    := 'N'     --bug 2805602
 ,p_dest_project_name            IN VARCHAR2               --bug 2805602
 ,p_target_start_date            IN DATE
 ,p_target_finish_date           IN DATE
 ,p_calendar_id                  IN NUMBER
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

FUNCTION get_adjusted_dates(
   p_target_start_date    DATE
  ,p_target_finish_date   DATE
  ,p_delta NUMBER
  ,p_scheduled_start_date  DATE
  ,p_scheduled_finish_date  DATE
 ) RETURN DATE;

PROCEDURE copy_structures_bulk
( p_commit                        IN VARCHAR2    := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2    := FND_API.G_TRUE
 ,p_validation_level              IN VARCHAR2    := 100
 ,p_calling_module                IN VARCHAR2    := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2    := 'N'
 ,p_max_msg_count                 IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_src_project_id                IN NUMBER
 ,p_dest_project_id               IN NUMBER
 ,p_delta                         IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_copy_task_flag                IN VARCHAR2    := 'Y'
 ,p_dest_template_flag            IN VARCHAR2    := 'N'     --bug 2805602
 ,p_src_template_flag            IN VARCHAR2    := 'N'   --bug 2805602
 ,p_dest_project_name             IN VARCHAR2               --bug 2805602
 ,p_target_start_date             IN DATE
 ,p_target_finish_date             IN DATE
 ,p_calendar_id                   IN NUMBER
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

FUNCTION calc_duration( p_calendar_id NUMBER, p_start_date DATE, p_finish_date DATE ) RETURN NUMBER;

PROCEDURE get_version_ids(
 p_task_id            NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_task_version_id   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id        NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,x_structure_version_id OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_task_version_id      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
);

PROCEDURE get_task_version_id(
 p_project_id        NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_structure_version_id   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_task_id            NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,x_task_version_id      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
);

PROCEDURE rollup_dates(
   p_tasks_in             IN pa_project_pub.task_out_tbl_type
  ,p_task_version_id      IN NUMBER  := null
  ,p_structure_version_id IN NUMBER
  ,p_project_id           IN NUMBER
  ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- API included for Post FP K one off Bug 2931183
PROCEDURE PROCESS_TASK_STRUCTURE_BULK
   (  p_api_version_number              IN        NUMBER         := 1.0
     ,p_commit                          IN        VARCHAR2       := FND_API.G_FALSE
     ,p_init_msg_list                   IN        VARCHAR2       := FND_API.G_FALSE
     ,p_calling_module                  IN        VARCHAR2       := 'AMG'
     ,p_project_id                      IN        pa_projects_all.project_id%TYPE
     --ADUT. The following parameter is required to identify if the source is project/template.
     --This will be passed only from create_project context.
     ,p_source_project_id               IN        pa_projects_all.project_id%TYPE  := NULL
     ,p_pm_product_code                 IN        pa_projects_all.pm_product_code%TYPE
     ,p_structure_type                  IN        pa_structure_types.structure_type_class_code%TYPE
     ,p_tasks_in_tbl                    IN        pa_project_pub.task_in_tbl_type
     ,p_create_task_version_only        IN        VARCHAR2       := 'N'
     ,p_wp_str_exists                   IN        VARCHAR2
     ,p_is_wp_separate_from_fn          IN        VARCHAR2
     ,p_is_wp_versioning_enabled        IN        VARCHAR2
     ,p_structure_version_id            IN        pa_proj_elem_ver_structure.element_version_id%TYPE --IUP: Impact of calling from Update_project
     -- Included NOCOPY for the following parameter. Bug 2931183.
     -- PA L Changes 3010538
     ,p_process_mode                    IN       VARCHAR2 := 'ONLINE'
     -- Bug 3075609. To identify create task version only context.
     ,p_create_task_versions_only       IN       VARCHAR2 := 'N'
     ,px_tasks_out_tbl                  IN OUT NOCOPY pa_project_pub.task_out_tbl_type
     ,x_return_status                   OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE delete_fin_plan_from_task(
    p_task_id                                   NUMBER
   ,p_project_id                                NUMBER
   ,p_calling_module                            VARCHAR2  := 'FORMS'
   ,x_return_status                   OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                       OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Bug 3010538 : New API for the Task Weighting Enhancement.
PROCEDURE PROCESS_WBS_UPDATES_WRP
   (  p_api_version_number    IN   NUMBER    := 1.0
     ,p_commit                IN   VARCHAR2  := FND_API.G_FALSE
     ,p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE
     ,p_calling_context       IN   VARCHAR2  := 'UPDATE'
     ,p_project_id            IN   pa_projects_all.project_id%TYPE
     ,p_structure_version_id  IN   pa_proj_element_versions.element_version_id%TYPE
     ,p_pub_struc_ver_id      IN   NUMBER    := NULL
     ,p_pub_prog_flag         IN   VARCHAR2  := 'Y' --bug 4019845
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Bug 3010538 : New API for the Task Weighting Enhancement.
PROCEDURE PROCESS_WBS_UPDATES_CONC_WRP
   (  p_api_version_number    IN   NUMBER    := 1.0
     ,p_commit                IN   VARCHAR2  := FND_API.G_FALSE
     ,p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE
     ,p_calling_context       IN   VARCHAR2  := 'UPDATE'
     ,p_project_id            IN   pa_projects_all.project_id%TYPE
     ,p_structure_version_id  IN   pa_proj_element_versions.element_version_id%TYPE
     ,p_pub_struc_ver_id      IN   NUMBER    := NULL
     ,p_pub_prog_flag         IN   VARCHAR2  := 'Y' --bug 4019845
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Bug 3010538 : New API for the Task Weighting Enhancement.
PROCEDURE PROCESS_WBS_UPDATES_CONC
   (  errbuf                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,Retcode                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,p_calling_context       IN   VARCHAR2  := 'UPDATE'
     ,p_project_id            IN   pa_projects_all.project_id%TYPE
     ,p_structure_version_id  IN   pa_proj_element_versions.element_version_id%TYPE
     ,p_pub_struc_ver_id      IN   NUMBER    := NULL
     ,p_pub_prog_flag         IN   VARCHAR2  := 'Y' --bug 4019845
     ,p_rerun_flag            IN   VARCHAR2  := null --bug 4589289
   );

--Bug 3010538 : New API for the Task Weighting Enhancement.
PROCEDURE PROCESS_WBS_UPDATES
   (  p_api_version_number    IN   NUMBER    := 1.0
     ,p_commit                IN   VARCHAR2  := FND_API.G_FALSE
     ,p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE
     ,p_calling_context       IN   VARCHAR2  := 'UPDATE'
     ,p_project_id            IN   pa_projects_all.project_id%TYPE
     ,p_structure_version_id  IN   pa_proj_element_versions.element_version_id%TYPE
     ,p_pub_struc_ver_id      IN   NUMBER    := NULL
     ,p_pub_prog_flag         IN   VARCHAR2  := 'Y' --bug 4019845
     ,p_rerun_flag            IN   VARCHAR2  := null --bug 4589289
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Bug 3010538 : New API for the Task Weighting Enhancement.
PROCEDURE PROCESS_TASK_WEIGHTAGE
   (  p_api_version_number    IN   NUMBER    := 1.0
     ,p_commit                IN   VARCHAR2  := FND_API.G_FALSE
     ,p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE
     ,p_calling_context       IN   VARCHAR2  := 'SELF_SERVICE'
     ,p_project_id            IN   pa_projects_all.project_id%TYPE
     ,p_structure_version_id  IN   pa_proj_element_versions.element_version_id%TYPE
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Bug 3010538 : New API for the Task Weighting Enhancement.
PROCEDURE SET_UPDATE_WBS_FLAG
   (  p_api_version_number    IN   NUMBER    := 1.0
     ,p_commit                IN   VARCHAR2  := FND_API.G_FALSE
     ,p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE
     ,p_calling_context       IN   VARCHAR2  := 'SELF_SERVICE'
     ,p_project_id            IN   pa_projects_all.project_id%TYPE
     ,p_structure_version_id  IN   pa_proj_element_versions.element_version_id%TYPE
     ,p_update_wbs_flag       IN   pa_proj_elem_ver_structure.process_update_wbs_flag%TYPE := 'Y'
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE PROCESS_WBS_UPDATES_WRP_FORM
   (  p_project_id            IN   pa_projects_all.project_id%TYPE
     ,p_structure_version_id  IN   pa_proj_element_versions.element_version_id%TYPE
     ,p_pub_struc_ver_id      IN   NUMBER    := NULL
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

  --bug 3035902 maansari
PROCEDURE call_process_WBS_updates(
        p_dest_project_id       IN   NUMBER
       ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

PROCEDURE Update_Current_Phase
( p_api_version_number         IN     NUMBER      := 1.0
 ,p_commit                     IN     VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list              IN     VARCHAR2    := FND_API.G_FALSE
 ,p_validate_only              IN     VARCHAR2    := FND_API.G_TRUE
 ,p_validation_level           IN     VARCHAR2    := 100
 ,p_debug_mode                 IN     VARCHAR2    := 'N'
 ,p_max_msg_count              IN     NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_user_id                    IN     NUMBER      := FND_GLOBAL.USER_ID
 ,p_project_id                 IN     NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_name               IN     VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_current_lifecycle_phase_id IN     NUMBER      := FND_API.G_MISS_NUM
 ,p_current_lifecycle_phase    IN     VARCHAR2    := FND_API.G_MISS_CHAR
 ,x_return_status              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--------------------------------- Added for FP_M changes : Bhumesh
			       -- Refer to Tracking bug 3305199 for details
  -- To import Source Ref, Sub Type and Lag days into the system from an
  -- input string parameter
  Procedure Parse_Predecessor_Import (
      P_String			IN	VARCHAR2,
      P_Delimeter		IN	VARCHAR2 DEFAULT ',',
      P_Task_Version_Id         IN      NUMBER,            --SMUKKA Added this parameter
      X_Return_Status   	OUT  	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      X_Msg_Count       	OUT  	NOCOPY NUMBER, --File.Sql.39 bug 4440895
      X_Msg_Data        	OUT  	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  -- To export Source Ref, Sub Type and Lag Types from the system to an
  -- out string parameter for a given element version ID
  Function Parse_Predecessor_Export (
      P_Element_Version_ID	IN	NUMBER,
      P_Delimeter		IN	VARCHAR2 DEFAULT ','
 ) RETURN VARCHAR2;
--------------------------------- End of FP_M changes : Bhumesh

  Function Parse_Predecessor_Export2 (
      P_Element_Version_ID	IN	NUMBER,
      P_Delimeter		IN	VARCHAR2 DEFAULT ','
 ) RETURN VARCHAR2;
--Added by rtarway FP.M Developement
Function GET_SHARE_TYPE (
    P_Project_ID      IN      NUMBER
  ) RETURN VARCHAR2;
--Added by rtarway FP.M Developement


PROCEDURE delete_intra_dependency (p_element_version_id IN  NUMBER,
                                                    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
                                                    p_debug_mode         IN  VARCHAR2 := 'N',
                                                    x_return_status      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
END PA_PROJ_TASK_STRUC_PUB;

 

/
