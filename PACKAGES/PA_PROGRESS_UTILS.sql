--------------------------------------------------------
--  DDL for Package PA_PROGRESS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROGRESS_UTILS" AUTHID CURRENT_USER as
/* $Header: PAPCUTLS.pls 120.12.12010000.5 2008/12/17 20:32:16 bifernan ship $ */

--The following global varables are added for as_of_date APIs
  previous_record_count  NUMBER(15) := 0;
  next_record_count      NUMBER(15) := 0;
  record_count           NUMBER(15) := 0;
  x_bill_thru_date       DATE;
  project_id             NUMBER := 0;
  previous_record_index  NUMBER := 0;
  current_index          NUMBER := 0;
  previous_return_date   DATE   := sysdate - 10;
  l_last_progress_date DATE;
  l_Last_Bill_Thru_Date DATE;
  l_return_date     PA_VC_1000_10 := PA_VC_1000_10(1000);
  i                      NUMBER := 0;

  X_project_start_date   DATE;
  X_project_finish_date  DATE;
  G_prog_as_of_date      DATE := sysdate;
  G_bac_value_project_id NUMBER := 0; -- FPM Dev CR 3

  -- 4535784 Begin
  j_task                 NUMBER := 0;
  g_task_id      NUMBER := 0;
  g_max_rollup_dt    DATE;
  -- 4535784 End
--

  -- Bug 7633088
  g_override_as_of_date    DATE := NULL;

FUNCTION GET_LATEST_TASK_VER_ID (p_project_id      IN  NUMBER,
                                 p_task_id         IN  NUMBER) return NUMBER;

FUNCTION PROGRESS_RECORD_EXISTS (p_element_version_id   IN  NUMBER,
                                 p_object_type          IN  VARCHAR2
                 ,p_project_id      IN  NUMBER -- Fixed bug # 3688901.
                ) return VARCHAR2;

FUNCTION GET_LATEST_STRUCTURE_VER_ID (p_project_id IN  NUMBER) return NUMBER;

FUNCTION isUserProjectManager(p_user_id       IN   NUMBER,
                              p_project_id    IN   NUMBER) return VARCHAR2;

FUNCTION Get_Working_Progress_Id(p_project_id    IN   NUMBER,
                                 p_task_id       IN   NUMBER) return NUMBER;

PROCEDURE UPDATE_TASK_PROG_REQ_DATE(p_commit         in varchar2 := FND_API.G_TRUE,
                                  p_object_id      in number,
                                  p_object_type    in varchar2,
                                  x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                  x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_msg_data       out NOCOPY varchar2); --File.Sql.39 bug 4440895
PROCEDURE adjust_reminder_date(
        p_commit                         IN VARCHAR2 := FND_API.G_TRUE
       ,p_project_id                     IN  NUMBER
       ,x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count                      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data                       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION PROJ_TASK_PROG_EXISTS(p_project_id IN  NUMBER,
                          p_task_id    IN  NUMBER) return VARCHAR2;

FUNCTION GET_PRIOR_PERCENT_COMPLETE(p_project_id IN  NUMBER,
                                    p_task_id    IN  NUMBER,
                                    p_as_of_date IN  DATE) return NUMBER;


FUNCTION GET_LATEST_AS_OF_DATE(
    p_task_id      NUMBER
    ,p_project_id   NUMBER := null -- FPM Development Bug 3420093
    ,p_object_id   NUMBER := null -- FPM Development Bug 3420093
    ,p_object_type VARCHAR2 := 'PA_TASKS'-- FPM Development Bug 3420093
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
    ) RETURN DATE;




function Get_AS_OF_DATE (
           X_Project_ID                 IN      Number,
                X_project_start_date            IN      Date    default NULL,
                                X_Billing_Cycle_ID              IN      Number  default NULL,
                                X_Billing_Offset_Days   IN      Number  default NULL,
                                X_Bill_Thru_Date                IN      Date    default NULL,
                                X_Last_Bill_Thru_Date   IN      Date    default NULL
                                        )       RETURN DATE;


FUNCTION as_of_date(
        X_Project_ID                    IN      NUMBER                          ,
        x_object_id                     IN      NUMBER                          ,
        X_Billing_Cycle_ID              IN      NUMBER  DEFAULT NULL            ,
        X_Object_type                   IN      VARCHAR2  DEFAULT 'PA_TASKS'    , -- FPM Development Bug 3420093
        X_structure_type                IN      VARCHAR2  DEFAULT 'WORKPLAN'    ,-- FPM Development Bug 3420093
    X_proj_element_id               IN      NUMBER    := null   /* Amit : Modified for IB4 Progress CR. */
          ) RETURN DATE;

FUNCTION get_next_ppc_id RETURN NUMBER;

-- FPM Development Bug 3420093 : Added p_object_type
FUNCTION CHECK_VALID_AS_OF_DATE(p_as_of_date IN DATE, p_project_id IN NUMBER, p_object_id NUMBER, p_object_type VARCHAR2 := 'PA_TASKS', p_proj_element_id  IN      NUMBER    := null    /* Amit : Modified for IB4 Progress CR. */  )
RETURN VARCHAR2;

FUNCTION Calc_base_percent(
 p_task_id     NUMBER,
 p_incr_work_qty NUMBER,
 p_cuml_work_qty NUMBER,
 p_est_remaining_effort NUMBER
) RETURN NUMBER;

-- 4392189 Phase 2: This method is not used anywhere
/*
PROCEDURE get_rollup_attrs(
 p_task_id                           NUMBER,
 p_as_of_date                        DATE,
 x_EFF_ROLLUP_PROG_STAT_CODE         OUT VARCHAR2,
 x_EFF_ROLLUP_PROG_STAT_NAME         OUT VARCHAR2,
 x_ESTIMATED_REMAINING_EFFORT        OUT NUMBER,
 x_BASE_PERCENT_COMPLETE             OUT NUMBER,
 x_EFF_ROLLUP_PERCENT_COMP           OUT NUMBER,
 x_ESTIMATED_START_DATE              OUT DATE,
 x_ESTIMATED_FINISH_DATE             OUT DATE,
 x_ACTUAL_START_DATE                 OUT DATE,
 x_ACTUAL_FINISH_DATE                OUT DATE,
 x_status_icon_ind                   OUT VARCHAR2,
 x_status_icon_active_ind            OUT VARCHAR2
);
*/

FUNCTION get_next_progress_cycle(
 p_project_id NUMBER,
 p_task_id NUMBER,
 p_object_id NUMBER := null, -- FPM Development Bug 3420093
 p_object_type VARCHAR2 := 'PA_TASKS', -- FPM Development Bug 3420093
 p_structure_type VARCHAR2 := 'WORKPLAN', -- FPM Development Bug 3420093
 p_start_date DATE := to_date(null) -- FPM Development Bug 3420093
)  RETURN DATE;

FUNCTION get_prog_dt_closest_to_sys_dt(
 p_project_id NUMBER,
 p_task_id NUMBER,
 p_object_id NUMBER := null, -- FPM Development Bug 3420093
 p_object_type VARCHAR2 := 'PA_TASKS', -- FPM Development Bug 3420093
 p_structure_type VARCHAR2 := 'WORKPLAN'
) RETURN DATE ;

FUNCTION check_prog_exists_on_aod(
 p_project_id       NUMBER,
 p_object_type      VARCHAR2,
 p_object_version_id NUMBER,
 p_task_id NUMBER := null/* Amit : Modified for IB4 Progress CR. */     ,
 p_as_of_date DATE,
 p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
 ,p_object_id   NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN VARCHAR2;

FUNCTION get_ppc_id(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_type   VARCHAR2
,p_object_version_id  NUMBER
,p_as_of_date    DATE
,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
,p_task_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER;

FUNCTION get_prog_rollup_id(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_type   VARCHAR2
,p_object_version_id NUMBER
,p_as_of_date    DATE
,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
,p_structure_version_id NUMBER := null -- FPM Development Bug 3420093
,x_record_version_number OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
,p_action          VARCHAR2 := 'PUBLISH' -- Bug 3879461
 ) RETURN NUMBER;

FUNCTION check_task_has_progress(
p_task_id    NUMBER ) RETURN VARCHAR2;

FUNCTION get_last_cumulative(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_type   VARCHAR2
,p_as_of_date    DATE ) RETURN NUMBER;


FUNCTION get_planned_wq(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_version_id NUMBER ) RETURN NUMBER;

PROCEDURE clear_prog_outdated_flag(
 p_project_id    NUMBER
,p_object_id     NUMBER
,p_object_type   VARCHAR2
,p_structure_version_id   NUMBER   default null    --bug 3851528
,x_return_status              OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count          OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                 OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- FPM Development Bug 3420093
PROCEDURE get_project_progress_defaults(
 p_project_id                   NUMBER
,p_structure_type               IN VARCHAR2
,x_WQ_ENABLED_FLAG              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_EFFORT_ENABLED_FLAG          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_PERCENT_COMP_ENABLED_FLAG    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_task_weight_basis_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_ALLOW_COLLAB_PROG_ENTRY      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
,X_ALLW_PHY_PRCNT_CMP_OVERRIDES OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

PROCEDURE get_progress_defaults(
 p_project_id                   NUMBER
,p_object_version_id            NUMBER
,p_object_type                  VARCHAR2
,p_object_id                  NUMBER
,p_as_of_date                   DATE
,p_structure_type               VARCHAR2 := 'WORKPLAN'  -- FPM Development Bug 3420093
,x_WQ_ACTUAL_ENTRY_CODE         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_WQ_ENABLED_FLAG              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_EFFORT_ENABLED_FLAG          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_BASE_PERCENT_COMP_DERIV_CODE OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_PERCENT_COMP_ENABLED_FLAG    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_PROGRESS_ENTRY_ENABLE_FLAG    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_ALLOW_COLLAB_PROG_ENTRY      OUT NOCOPY VARCHAR2 -- FPM Development Bug 3420093 --File.Sql.39 bug 4440895
,X_ALLW_PHY_PRCNT_CMP_OVERRIDES OUT NOCOPY VARCHAR2 -- FPM Development Bug 3420093 --File.Sql.39 bug 4440895
,x_task_weight_basis_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

FUNCTION chk_prg_since_last_prg(
 p_project_id                   NUMBER
,p_percent_complete_id          NUMBER
,p_object_type                  VARCHAR2
,p_object_id                    NUMBER
,p_task_id                      NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN VARCHAR2;

FUNCTION check_project_has_progress(
p_project_id    NUMBER,
p_object_id     NUMBER,
p_structure_type VARCHAR2 := null ) RETURN VARCHAR2;       -- added by kmaddi for bug 6914708

FUNCTION get_task_prog_profile(
p_profile_name    VARCHAR2 ) RETURN VARCHAR2;

FUNCTION Working_version_exist(
     p_task_id          NUMBER  := null /* Amit : Modified for IB4 Progress CR. */
    ,p_project_id       NUMBER
    ,p_object_type      VARCHAR2
    ,p_object_id        NUMBER := null /* Modified for IB4 Progress CR. */
    ,p_as_of_date       DATE := null  -- bug 4185364
    ) RETURN DATE;

FUNCTION check_status_referenced(
      p_status_code    VARCHAR2 ) RETURN BOOLEAN;

FUNCTION GET_LATEST_AS_OF_DATE2(
    p_task_id      NUMBER
   ,p_as_of_date  DATE ) RETURN DATE;

FUNCTION is_parent_on_hold(
   p_object_version_id     NUMBER
) RETURN VARCHAR2;

FUNCTION get_task_status(
  p_project_id     NUMBER
 ,p_object_id     NUMBER
 , p_object_type  VARCHAR2 := 'PA_TASKS' -- FPM Development Bug 3420093
 ) RETURN VARCHAR2;

 FUNCTION get_system_task_status(
 p_status_code   VARCHAR2
 ,p_object_type   VARCHAR2 := 'PA_TASKS'
 ) RETURN VARCHAR2;

Function is_cycle_ok_to_delete(p_progress_cycle_id  IN  NUMBER) return VARCHAR2;

function get_max_ppc_id(p_project_id   IN  NUMBER,
                        p_object_id    IN  NUMBER,
                        p_object_type  IN  VARCHAR2,
                        p_as_of_date   IN  DATE) return number;

function get_max_rollup_asofdate(p_project_id           IN  NUMBER,
                                 p_object_id            IN  NUMBER,
                                 p_object_type          IN  VARCHAR2,
                                 p_as_of_date           IN  DATE,
                                 p_object_version_id    IN  NUMBER,
                 p_structure_type IN VARCHAR2 := 'WORKPLAN', -- FPM Dev CR 3
                 p_structure_version_id NUMBER := NULL -- FPM Dev CR 4
                 ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
                 ) return date;

function get_project_wq_flag(p_project_id  IN  NUMBER) return varchar2;

PROCEDURE copy_attachments (
  p_project_id                  IN NUMBER,
  p_object_id                   IN NUMBER,
  p_object_type                 IN VARCHAR2,
  p_from_pc_id                  IN NUMBER,
  p_to_pc_id                    IN NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

function is_task_manager (p_task_id           IN  NUMBER,
                          p_project_id        IN  NUMBER,
                          p_user_id           IN  NUMBER) return varchar2;

--Bug 3010538 : New API for the Task Weighting Enhancement.
FUNCTION GET_TASK_WEIGHTING_BASIS(
    p_project_id  IN  pa_projects_all.project_id%TYPE
    , p_structure_type IN VARCHAR2 := 'WORKPLAN' -- FPM Dev CR 3
)
return VARCHAR2;

-- Progress Management Changes. Bug # 3420093.

FUNCTION is_object_progressable(p_project_id            IN              NUMBER
                                ,p_proj_element_id      IN              NUMBER
                                ,p_object_id            IN              NUMBER
                                ,p_object_type          IN              VARCHAR2) return VARCHAR2;

FUNCTION check_wp_working_prog_exists(p_project_id            IN              NUMBER
                                ,p_structure_version_id      IN              NUMBER
                ) return VARCHAR2;

FUNCTION is_pc_override_allowed(p_project_id            IN              NUMBER
                                ,p_structure_type        IN              VARCHAR2 := 'WORKPLAN'
                ) return VARCHAR2;


FUNCTION calculate_percentage( p_actual_value   NUMBER
                               ,p_planned_value  NUMBER ) return NUMBER;


FUNCTION GET_EARLIEST_AS_OF_DATE(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
    ,p_task_id     NUMBER  := null /* Modified for IB4 Progress CR. */
    ) RETURN DATE;

FUNCTION check_assignment_exists(
     p_project_id   NUMBER
    ,p_object_version_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
 ) RETURN VARCHAR2;

FUNCTION get_last_effort(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_as_of_date  DATE
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
    ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER;

FUNCTION get_last_cost(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_as_of_date  DATE
    ,p_structure_type VARCHAR2 := 'WORKPLAN' -- FPM Development Bug 3420093
    ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER;


PROCEDURE convert_currency_amounts(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
 ,p_task_id                     IN      NUMBER      /* to pass to conversion api */
 ,p_as_of_date                  IN      DATE        /* to pass to conversion api */
 ,P_txn_cost                    IN      NUMBER
 ,P_txn_curr_code               IN      VARCHAR2
 ,p_structure_version_id        IN      NUMBER -- Bug 3627787
 ,p_calling_mode        IN  VARCHAR2        := 'ACTUAL_RATES' -- Bug 4372462
 ,p_budget_version_id           IN      NUMBER          := null -- Bug 4372462
 ,p_res_assignment_id           IN      NUMBER          := null -- Bug 4372462
 ,p_init_inout_vars             IN      VARCHAR2        := 'Y' -- Bug 4372462
 ,P_project_curr_code           IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_project_rate_type           IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_project_rate_date           IN OUT  NOCOPY DATE --File.Sql.39 bug 4440895
 ,P_project_exch_rate           IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,P_project_raw_cost            IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,P_projfunc_curr_code          IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_projfunc_cost_rate_type     IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_projfunc_cost_rate_date     IN OUT  NOCOPY DATE --File.Sql.39 bug 4440895
 ,P_projfunc_cost_exch_rate     IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,P_projfunc_raw_cost           IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

FUNCTION get_time_phase_period(p_structure_version_id   IN      NUMBER
                   ,p_project_id        IN      NUMBER := NULL) return VARCHAR2;

FUNCTION get_incremental_actual_cost(p_as_of_date           IN              DATE
                                    ,p_period_name          IN              VARCHAR2
                                    ,pgn_flag               IN              VARCHAR2
                                    ,p_project_id           IN              NUMBER
                                    ,p_object_id            IN              NUMBER
                                    ,p_object_version_id    IN              NUMBER
                    ,currency_flag      IN          VARCHAR2 := 'T'
                                    ,p_structure_version_id IN              NUMBER := null  --3694031
              ,p_proj_element_id      IN    NUMBER := null /* Modified for IB4 Progress CR. */
                      ) return NUMBER;

FUNCTION get_incremental_actual_rawcost(p_as_of_date           IN            DATE
                                       ,p_period_name          IN            VARCHAR2
                                       ,pgn_flag               IN            VARCHAR2
                                       ,p_project_id           IN            NUMBER
                                       ,p_object_id            IN            NUMBER
                                       ,p_object_version_id    IN            NUMBER
                                       ,currency_flag          IN            VARCHAR2 := 'T'
                                       ,p_structure_version_id IN              NUMBER := null  --3694031
                 ,p_proj_element_id      IN  NUMBER := null /* Modified for IB4 Progress CR. */
                                    ) return NUMBER;

FUNCTION get_incremental_actual_effort(p_as_of_date           IN              DATE
                                      ,p_period_name          IN              VARCHAR2
                                      ,pgn_flag               IN              VARCHAR2
                                      ,p_project_id           IN              NUMBER
                                      ,p_object_id            IN              NUMBER
                                      ,p_object_version_id    IN              NUMBER
                                      ,p_structure_version_id IN              NUMBER := null  --3694031
                ,p_proj_element_id      IN   NUMBER := null /* Modified for IB4 Progress CR. */
                                  ) return NUMBER;


FUNCTION get_act_txn_cost_this_period (p_as_of_date      IN     DATE
                                    ,p_project_id        IN     NUMBER
                                    ,p_object_id         IN     NUMBER
                                    ,p_object_version_id IN     NUMBER
    ,p_proj_element_id   IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER;

FUNCTION get_act_pfn_cost_this_period (p_as_of_date      IN     DATE
                                    ,p_project_id        IN     NUMBER
                                    ,p_object_id         IN     NUMBER
                                    ,p_object_version_id IN     NUMBER
    ,p_proj_element_id   IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER;

FUNCTION get_act_cost_this_period (p_as_of_date          IN     DATE
                                    ,p_project_id        IN     NUMBER
                                    ,p_object_id         IN     NUMBER
                                    ,p_object_version_id IN     NUMBER
    ,p_proj_element_id   IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER;


FUNCTION get_act_effort_this_period (p_as_of_date        IN     DATE
                                    ,p_project_id        IN     NUMBER
                                    ,p_object_id         IN     NUMBER
                                    ,p_object_version_id IN     NUMBER
    ,p_proj_element_id   IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER;


FUNCTION check_wwp_prog_publishing_ok(
    p_project_id              IN NUMBER
   ,p_structure_version_id    IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_BAC_Value(
    p_project_id                IN NUMBER
   ,p_task_weight_method        IN VARCHAR2
   ,p_proj_element_id           IN NUMBER
   ,p_structure_version_id      IN NUMBER
   ,p_structure_type            IN VARCHAR2
   ,p_working_wp_prog_flag      IN VARCHAR2 default 'N' --maansari7/18. To get the planned in case of apply lp flow
   ,p_program_flag              IN VARCHAR2 default 'Y' -- Bug 4493105
) RETURN NUMBER;

FUNCTION Get_LATEST_PROGRESS_ENTRY_DATE(
     p_project_id  NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2 := 'PA_TASKS'
    ,p_structure_type VARCHAR2 := 'WORKPLAN'
    ,p_task_id  NUMBER := null /* Amit : Modified for IB4 Progress CR. */
    ) RETURN DATE ;

FUNCTION Get_EARLY_PROGRESS_ENTRY_DATE(
     p_project_id  NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2 := 'PA_TASKS'
    ,p_structure_type VARCHAR2 := 'WORKPLAN'
    ,p_task_id  NUMBER := null /* Modified for IB4 Progress CR. */
    ) RETURN DATE ;

FUNCTION latest_published_progress_date(p_project_id      IN    NUMBER
                        ,p_structure_type IN    VARCHAR2 ) RETURN DATE;

FUNCTION check_object_has_prog(
    p_project_id                IN  NUMBER  -- FPM Dev CR 7 : Removed defaulting
        ,p_proj_element_id                      IN      NUMBER := null /* Modified for IB4 Progress CR. */
        ,p_object_id                            IN      NUMBER -- FPM Dev CR 7 : Removed defaulting
    ,p_object_type              IN  VARCHAR2:='PA_TASKS'
    ,p_structure_type           IN  VARCHAR2:='WORKPLAN'
        ,p_progress_status                      IN      VARCHAR2:='ANY'
    )   RETURN VARCHAR2;

--- Following APIs added by Bhumesh

Function Prog_Get_Pa_Period_Name (p_Date  IN Date
, p_org_id IN NUMBER :=null -- 4746476
) RETURN VARCHAR2 ;

Function Prog_Get_GL_Period_Name (P_Date  IN Date
, p_org_id IN NUMBER :=null -- 4746476
) RETURN VARCHAR2 ;

-- History
--  02-aug-04
--  Added two params p_structure_version_id and p_structure_status to return base percent complete
--  from a working version also.
--  This change is done for B and F.

Procedure REDEFAULT_BASE_PC    (
    p_Project_ID        IN NUMBER
   ,p_Proj_element_id       IN NUMBER
   ,p_Structure_type        IN VARCHAR2 DEFAULT 'WORKPLAN'
   ,p_object_type           IN VARCHAR2 DEFAULT 'PA_TASKS'
   ,p_As_Of_Date        IN DATE
   ,p_structure_version_id      IN NUMBER    DEFAULT null
   ,p_structure_status          IN VARCHAR2  DEFAULT null
   ,p_calling_context           IN VARCHAR2  DEFAULT 'PROGRESS'
   ,X_base_percent_complete OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

Procedure RECALCULATE_PROG_STATS (
    p_project_id        IN NUMBER
   ,p_proj_element_id       IN NUMBER
   ,p_task_version_id       IN NUMBER
   ,p_structure_type        IN VARCHAR2 DEFAULT 'WORKPLAN'
   ,p_As_Of_Date        IN DATE
   ,P_Overide_Percent_Complete  IN NUMBER
   ,p_Actual_Effort     IN NUMBER
   ,p_Actual_Cost       IN NUMBER
   ,p_Planned_Effort        IN NUMBER
   ,p_Planned_Cost      IN NUMBER
   ,p_baselined_Effort      IN NUMBER
   ,p_baselined_Cost        IN NUMBER
   ,x_BCWS          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,X_BCWP          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,X_SCH_Performance_Index OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,X_COST_Performance_Index    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_Sch_At_Completion     OUT NOCOPY DATE  --File.Sql.39 bug 4440895
   ,x_Complete_Performance_Index OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
   ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

Procedure DEF_DATES_FROM_RESOURCES (
    p_project_id        IN NUMBER
   ,p_proj_element_id       IN NUMBER
   ,p_structure_type        IN VARCHAR2 DEFAULT 'WORKPLAN'
   ,p_As_Of_Date        IN DATE
   ,x_Actual_Start_Date     OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_Actual_Finish_Date    OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_Estimated_Start_Date  OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_Estimated_Finish_Date OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

FUNCTION check_actuals_allowed (p_project_id     IN NUMBER
                               ,p_structure_type IN VARCHAR2 := 'WORKPLAN') RETURN VARCHAR2;

-- Progress Management Changes Bug # 3420093.

FUNCTION get_bcws (p_project_id                 IN NUMBER
                  ,p_object_id                  IN NUMBER
                  ,p_proj_element_id            IN NUMBER
                  ,p_as_of_date                 IN DATE
                  ,p_structure_version_id       IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                  ,p_rollup_method              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                  ,p_scheduled_start_date       IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                  ,p_scheduled_end_date         IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          ,p_prj_currency_code          IN VARCHAR2 := null           --bug 3824042
          ,p_structure_type             IN VARCHAR2 := 'WORKPLAN'   --maansari4/10
          ) RETURN NUMBER;

FUNCTION get_latest_ass_prog_date(p_project_id      IN  NUMBER
                 ,p_structure_type  IN  VARCHAR2
                 ,p_object_id       IN  NUMBER
                 ,p_object_type     IN  VARCHAR2
        ,p_task_id     IN      NUMBER := null /* Modified for IB4 Progress CR. */) RETURN DATE;

--- End of addding new APIs

FUNCTION get_resource_list_id ( p_resource_list_member_id NUMBER) RETURN NUMBER;


function get_max_rollup_asofdate2(p_project_id   IN  NUMBER,
                                 p_object_id    IN  NUMBER,
                                 p_object_type  IN  VARCHAR2,
                 p_structure_type IN VARCHAR2 := 'WORKPLAN', -- FPM Dev CR 3
                 p_structure_version_id IN NUMBER := NULL -- FPM Dev CR 4
                 ,p_proj_element_id IN NUMBER  := null /* Modified for IB4 Progress CR. */
                                 ) return date;

procedure set_prog_as_of_Date(p_project_id   IN NUMBER,
                              p_task_id      IN NUMBER,
                              p_as_of_date   IN DATE default to_date(null),
                  p_object_id    IN NUMBER := null, -- Bug 3974627
                  p_object_type  IN VARCHAR2 := 'PA_TASKS' -- Bug 3974627
                  );

function get_prog_asofdate return date;
PRAGMA RESTRICT_REFERENCES(get_prog_asofdate, WNDS, WNPS);

--The following api is used to render cost region on Task progress Details -summary page

--bug 4085786, changed the signature
--function check_workplan_cost ( p_project_id   NUMBER) RETURN VARCHAR2;
function check_workplan_cost ( p_project_id IN NUMBER,
                   p_task_id    IN NUMBER   := NULL,
                   p_object_id  IN NUMBER   := NULL,
                   p_object_type    IN VARCHAR2 := 'PA_TASKS',
                   p_structure_version_id IN NUMBER := NULL
                 )  RETURN VARCHAR2;

-- Progress Management Changes. Bug # 3420093.

procedure get_actuals_for_task(p_project_id             IN      NUMBER
                              ,p_wp_task_id             IN      NUMBER
                  ,p_res_list_mem_id    IN  NUMBER
                              ,p_as_of_date             IN      DATE
                              ,x_planned_work_qty       OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_actual_work_qty        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_cost_pc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_cost_pc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_cost_pc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_cost_fc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_cost_fc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_cost_fc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_act_labor_effort   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_act_eqpmt_effort   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_unit_of_measure        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_txn_currency_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_ppl_act_cost_tc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_cost_tc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_cost_tc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_rawcost_pc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_rawcost_pc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_rawcost_pc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_rawcost_fc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_rawcost_fc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_rawcost_fc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_ppl_act_rawcost_tc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_eqpmt_act_rawcost_tc      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_oth_act_rawcost_tc        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_oth_quantity          OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_return_status          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_msg_count              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_msg_data               OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Progress Management Changes. Bug # 3420093.

FUNCTION wp_task_ver_id_for_fin_task_id(p_project_id NUMBER, p_fin_task_id NUMBER) return NUMBER;
/* Bug 3595585 : Added the following procedure */
FUNCTION get_last_etc_effort(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_as_of_date  DATE
    ,p_structure_type VARCHAR2 := 'WORKPLAN'
    ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER;

/* Bug 3595585 : Added the following procedure */
FUNCTION get_last_etc_cost(
     p_project_id   NUMBER
    ,p_object_id   NUMBER
    ,p_object_type VARCHAR2
    ,p_as_of_date  DATE
    ,p_structure_type VARCHAR2 := 'WORKPLAN'
    ,p_proj_element_id NUMBER := null /* Modified for IB4 Progress CR. */
) RETURN NUMBER;

/* Bug 3595585 : Added the following procedure */
-- Bug 3621404 : Added burden parameters
PROCEDURE get_last_etc_all(p_project_id             IN      NUMBER
                              ,p_object_id      IN      NUMBER
                              ,p_object_type            IN      VARCHAR2
                              ,p_as_of_date     IN  DATE
                              ,p_structure_type     IN  VARCHAR2    := 'WORKPLAN'
                              ,x_etc_txn_raw_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_prj_raw_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_pfc_raw_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_txn_bur_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_prj_bur_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_pfc_bur_cost_last_subm OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_etc_effort_last_subm   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_return_status          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_msg_count              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_msg_data               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,p_proj_element_id        IN      NUMBER := null /* Modified for IB4 Progress CR. */
          ,p_resource_class_code IN VARCHAR2    := 'PEOPLE' -- Bug 3836485
            );

function sum_etc_values(
     p_planned_value        NUMBER := null
     ,p_ppl_etc_value       NUMBER := null
     ,p_eqpmt_etc_value     NUMBER := null
     ,p_oth_etc_value       NUMBER := null
     ,p_subprj_ppl_etc_value    NUMBER := null
     ,p_subprj_eqpmt_etc_value  NUMBER := null
     ,p_subprj_oth_etc_value    NUMBER := null
     ,p_oth_etc_quantity        NUMBER := null
     ,p_actual_value            NUMBER := null
     ,p_mode                    VARCHAR2 := 'PUBLISH'
)return number;


-- Progress Management Changes. Bug # 3621404.

FUNCTION get_act_rawcost_this_period (p_as_of_date        IN     DATE
                                     ,p_project_id        IN     NUMBER
                                     ,p_object_id         IN     NUMBER
                                     ,p_object_version_id IN     NUMBER
       ,p_proj_element_id      IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER;


-- Progress Management Changes. Bug # 3621404.

FUNCTION get_act_txn_rawcost_thisperiod (p_as_of_date        IN     DATE
                                        ,p_project_id        IN     NUMBER
                                        ,p_object_id         IN     NUMBER
                                        ,p_object_version_id IN     NUMBER
       ,p_proj_element_id      IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER;


-- Progress Management Changes. Bug # 3621404.

FUNCTION get_act_pfn_rawcost_thisperiod (p_as_of_date        IN     DATE
                                        ,p_project_id        IN     NUMBER
                                        ,p_object_id         IN     NUMBER
                                        ,p_object_version_id IN     NUMBER
      ,p_proj_element_id      IN     NUMBER := null /* Modified for IB4 Progress CR. */) return NUMBER;


-- Bug 3621404 : Added Get_Res_Rate_Burden_Multiplier
Procedure Get_Res_Rate_Burden_Multiplier(P_res_list_mem_id      IN  NUMBER
                                ,P_project_id           IN  NUMBER
                ,P_task_id                      IN  NUMBER := null     --bug 3860575
                                ,p_as_of_date                   IN  DATE   := null     --bug 3901289
                                --maansari6/14 bug 3686920
                                ,p_structure_version_id IN NUMBER   default null
                                ,p_currency_code        IN  VARCHAR2 default null
                                --maansari6/14 bug 3686920
                                ,p_init_msg_list        IN  VARCHAR2        := FND_API.G_FALSE
                ,p_calling_mode                 IN  VARCHAR2        := 'ACTUAL_RATES' -- Bug 3627315
            --  ,P_dummy_override_raw_cost  IN  NUMBER Bug 3632946
            --  ,P_override_txn_currency_code   IN  VARCHAR2 Bug 3632946
                ,x_resource_curr_code           OUT NOCOPY VARCHAR2
                                ,x_resource_raw_rate            OUT NOCOPY NUMBER
                                ,x_resource_burden_rate         OUT NOCOPY NUMBER
            --  ,X_dummy_burden_cost            OUT NOCOPY NUMBER Bug 3632946
                ,X_burden_multiplier            OUT NOCOPY NUMBER
                                ,x_return_status                OUT  NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
                                ,x_msg_count                    OUT  NOCOPY NUMBER         --File.Sql.39 bug 4440895
                                ,x_msg_data                     OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                       );

-- Bug 3621404 : Raw Cost Changes, Added this procedure
PROCEDURE get_all_amounts_cumulative
    (p_project_id       IN     NUMBER
    ,p_object_id        IN     NUMBER
    ,p_object_type          IN     VARCHAR2
        ,p_structure_version_id IN     NUMBER := NULL -- Do not pass if published structure version
    ,p_as_of_date           IN     DATE   := NULL -- Must pass if published structure version
    ,x_act_bur_cost_tc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_bur_cost_pc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_bur_cost_fc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_raw_cost_tc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_raw_cost_pc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_raw_cost_fc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_bur_cost_tc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_bur_cost_pc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_bur_cost_fc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_raw_cost_tc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_raw_cost_pc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_raw_cost_fc  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_act_effort       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_effort       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_return_status        OUT    NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
        ,x_msg_count            OUT    NOCOPY NUMBER         --File.Sql.39 bug 4440895
        ,x_msg_data             OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,p_proj_element_id      IN     NUMBER := null /* Modified for IB4 Progress CR. */
    );

-- Progress Management Changes. Bug # 3621404.

function derive_etc_values(
     p_planned_value        NUMBER := null
     ,p_ppl_act_value       NUMBER := null
     ,p_eqpmt_act_value     NUMBER := null
     ,p_oth_act_value       NUMBER := null
     ,p_subprj_ppl_act_value    NUMBER := null
     ,p_subprj_eqpmt_act_value  NUMBER := null
     ,p_subprj_oth_act_value    NUMBER := null
     ,p_oth_quantity_to_date    NUMBER := null
)return number;

-- Bug 3633293 : Added check_deliverable_exists
FUNCTION check_deliverable_exists(
     p_project_id   NUMBER
    ,p_object_id    NUMBER
 ) RETURN VARCHAR2 ;

-- Bug 3651781 : Added published_dlv_prog_exists
function published_dlv_prog_exists
(
 p_project_id        PA_PROJECTS_ALL.PROJECT_ID%TYPE
 ,p_dlv_proj_elt_id  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
) RETURN VARCHAR2 ;


--Added for performance improvements.
g_structure_version_id NUMBER;
procedure set_global_str_ver_id(p_structure_version_id NUMBER);
function get_global_str_ver_id RETURN NUMBER;

g_time_phase_period_name VARCHAR2(150);
procedure set_global_time_phase_period(p_period_name VARCHAR2);
function get_global_time_phase_period RETURN VARCHAR2;

-- Added following two functions for bug 3709439
FUNCTION Percent_Spent_Value
(
  p_actual_value       NUMBER
 ,p_planned_value      NUMBER
) RETURN NUMBER ;

FUNCTION Percent_Complete_Value
(
  p_actual_value       NUMBER
 ,p_etc_value          NUMBER
) RETURN NUMBER ;

-- Bug 3784324 : Added procedure convert_effort_to_cost
PROCEDURE convert_effort_to_cost
(   p_resource_list_mem_id        IN  NUMBER
    ,p_project_id                 IN  NUMBER
    ,p_structure_version_id       IN  NUMBER
    ,p_txn_currency_code              IN  VARCHAR
    ,p_planned_effort             IN  NUMBER
    ,p_planned_rawcost_tc         IN  NUMBER
    ,p_act_effort_this_period     IN  NUMBER
    ,p_act_effort                 IN  NUMBER
    ,p_etc_effort                 IN  NUMBER
    ,p_rate_based_flag            IN  VARCHAR := 'Y'
    ,p_act_rawcost_tc             IN  NUMBER
    ,x_act_rawcost_tc_this_period IN OUT NOCOPY NUMBER    --File.Sql.39 bug 4440895
    ,x_etc_rawcost_tc             IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_comp_effort          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_spent_effort         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_eac_effort                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_comp_rawcost_tc      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_spent_rawcost_tc     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_eac_rawcost_tc             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status          OUT    NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
    ,x_msg_count          OUT    NOCOPY NUMBER         --File.Sql.39 bug 4440895
    ,x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
--BUG 3815202, rtarway
FUNCTION get_last_published_perc_comp(
  p_project_id       NUMBER
 ,p_object_id        NUMBER
 ,p_as_of_date       Date
 ,p_object_type      VARCHAR2
) RETURN NUMBER ;

/* Bug # 3861344: Created API: return_start_end_date(). */

Function return_start_end_date(
p_scheduled_date        DATE            := NULL
,p_baselined_date       DATE            := NULL
,p_project_id           NUMBER
,p_proj_element_id      NUMBER
,p_object_type          VARCHAR2        := 'PA_TASKS'
,p_start_end_flag       VARCHAR2        := 'S'
) return date;

-- Procedure to be called when applying latest progress to / publishing the working workplan version.
PROCEDURE check_txn_currency_diff
(
    p_structure_version_id IN  NUMBER,
    p_context              IN  VARCHAR2 DEFAULT 'PUBLISH_STRUCTURE',
    x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Procedure to be called when updating task assignments for progress related business rules check.
PROCEDURE check_prog_for_update_asgmts
(
    p_task_assignment_tbl IN  PA_TASK_ASSIGNMENT_UTILS.l_resource_rec_tbl_type,
    x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Bug # 3910193: Created API: convert_effort_to_cost_brdn_pc().

PROCEDURE convert_effort_to_cost_brdn_pc
(   p_resource_list_mem_id        IN                      NUMBER
    ,p_project_id                     IN                      NUMBER
    ,p_task_id                IN                      NUMBER
    ,p_as_of_date             IN                      DATE
    ,p_structure_version_id           IN                      NUMBER
    ,p_txn_currency_code              IN                      VARCHAR
    ,p_planned_quantity               IN                      NUMBER
    ,p_act_quantity_this_period       IN                      NUMBER
    ,p_act_quantity                   IN                      NUMBER
    ,p_act_brdncost_pc                IN                      NUMBER
    ,p_etc_quantity                   IN                      NUMBER
    ,p_rate_based_flag                IN                      VARCHAR := 'Y'
    ,x_act_brdncost_pc_this_period    OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_etc_brdncost_pc                OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_comp_quantity            OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_spent_quantity           OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_eac_quantity                   OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_comp_brdncost_pc         OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_prcnt_spent_brdncost_pc        OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_eac_brdncost_pc                OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status              OUT                     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count              OUT                     NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data               OUT                     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

function get_actual_summ_date(p_project_id   IN  NUMBER) return date;

/* Bug # 3956235: Created API: get_cost_variance(). */

Function get_cost_variance(
        p_project_id                            NUMBER
        , p_proj_element_id                     NUMBER
        , p_structure_version_id                NUMBER
        , p_task_weight_method                  VARCHAR2
        , p_structure_type                      VARCHAR2 := 'WORKPLAN'
        , p_base_percent_complete               NUMBER
        , p_eff_rollup_percent_comp             NUMBER
        , p_earned_value                        NUMBER
        , p_oth_act_cost_to_date_pc             NUMBER
        , p_ppl_act_cost_to_date_pc             NUMBER
        , p_eqpmt_act_cost_to_date_pc           NUMBER
        , p_spj_oth_act_cost_to_date_pc         NUMBER
        , p_spj_ppl_act_cost_pc                 NUMBER
        , p_spj_eqpmt_act_cost_pc               NUMBER
) return number;

-- Begin fix for Bug # 4073659.

FUNCTION check_prog_exists_and_delete(
 p_project_id       NUMBER
 ,p_task_id         NUMBER
 ,p_object_type     VARCHAR2 := 'PA_TASKS'
 ,p_object_id       NUMBER   := null
 ,p_structure_type  VARCHAR2 := 'WORKPLAN'
 ,p_delete_progress_flag    VARCHAR2 := 'Y' -- Fix for Bug # 4140984.
) RETURN VARCHAR2;

-- End fix for Bug # 4073659.

/* Begin fix for bug # 4115607. */

FUNCTION get_app_cost_budget_cb_wor_ver(p_project_id NUMBER)
return NUMBER;

/* End fix for bug # 4115607. */
--Bug 5027965. introduced parameter p_etc_cost_calc_mode which  can be either COPY or DERIVE.
--If its COPY then
----the etc cost in the current working workplan version will returned. In this case
----the parameter p_budget_version_id will contain the budget version id corresponding to the
----current working workplan version
--If its DERIVE then
----the etc cost will be derived based on the rate setup on p_as_of_date
----p_budget_version_id will contain the budget version id corresponding to the latest published
---- workplan version
procedure get_plan_costs_for_qty
(  p_etc_cost_calc_mode         IN        VARCHAR2 DEFAULT 'DERIVE'   --Bug 5027965
  ,p_resource_list_mem_id       IN        NUMBER
  ,p_project_id                 IN        NUMBER
  ,p_task_id                    IN        NUMBER
  ,p_as_of_date                 IN        DATE
  ,p_structure_version_id       IN        NUMBER
  ,p_txn_currency_code          IN        VARCHAR
  ,p_rate_based_flag            IN        VARCHAR := 'Y'
  ,p_quantity                   IN        NUMBER
  ,p_budget_version_id          IN        NUMBER   ---4372462
  ,p_res_assignment_id          IN        NUMBER
  ,x_rawcost_tc                 OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_brdncost_tc                OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_rawcost_pc                 OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_brdncost_pc                OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_rawcost_fc                 OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_brdncost_fc                OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status              OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                  OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                   OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/* Begin Fix for Bug # 4108270.*/

FUNCTION get_pc_from_sub_tasks_assgn
(p_project_id           NUMBER
,p_proj_element_id      NUMBER
,p_structure_version_id     NUMBER
,p_include_sub_tasks_flag   VARCHAR2 := 'Y'
,p_structure_type       VARCHAR2 := 'WORKPLAN'
,p_object_type          VARCHAR2 := 'PA_TASKS'
,p_as_of_date           DATE := null
,p_program_flag                 VARCHAR2 := 'Y' -- 4392189 : Program Reporting Changes - Phase 2
)
RETURN NUMBER;

/* End Fix for Bug # 4108270.*/

/* Begin fix for Bug # 4185974. */

FUNCTION get_act_for_prev_asofdate (p_as_of_date         IN     DATE
                                ,p_project_id        IN     NUMBER
                                ,p_object_id         IN     NUMBER
                                ,p_object_version_id IN     NUMBER
                    ,p_proj_element_id   IN     NUMBER := null
                    ,p_effort_cost_flag  IN VARCHAR2 := 'C'
                                    ,p_cost_type_flag    IN     VARCHAR2 := 'B'
                                    ,p_currency_flag     IN     VARCHAR2 := 'T') return NUMBER;

/* End fix for Bug # 4185974. */

-- Begin fix for Bug # 4319171.

function calc_act(p_ppl_cost_eff                IN NUMBER := null
                  , p_eqpmt_cost_eff            IN NUMBER := null
                  , p_oth_cost_eff              IN NUMBER := null
                  , p_subprj_ppl_cost_eff       IN NUMBER := null
                  , p_subprj_eqpmt_cost_eff     IN NUMBER := null
                  , p_subprj_oth_cost_eff       IN NUMBER := null) return NUMBER;

function calc_etc(p_planned_cost_eff            IN NUMBER := null
                  , p_ppl_cost_eff              IN NUMBER := null
                  , p_eqpmt_cost_eff            IN NUMBER := null
                  , p_oth_cost_eff              IN NUMBER := null
                  , p_subprj_ppl_cost_eff       IN NUMBER := null
                  , p_subprj_eqpmt_cost_eff     IN NUMBER := null
                  , p_subprj_oth_cost_eff       IN NUMBER := null
          , p_oth_quantity      IN NUMBER := null
                  , p_act_cost_eff              IN NUMBER := null) return NUMBER;

function calc_wetc(p_planned_cost_eff           IN NUMBER := null
                  , p_ppl_cost_eff              IN NUMBER := null
                  , p_eqpmt_cost_eff            IN NUMBER := null
                  , p_oth_cost_eff              IN NUMBER := null
                  , p_subprj_ppl_cost_eff       IN NUMBER := null
                  , p_subprj_eqpmt_cost_eff     IN NUMBER := null
                  , p_subprj_oth_cost_eff       IN NUMBER := null
                  , p_oth_quantity              IN NUMBER := null) return NUMBER;

function calc_plan(p_ppl_cost_eff                IN NUMBER := null
                   , p_eqpmt_cost_eff            IN NUMBER := null
                   , p_oth_cost_eff              IN NUMBER := null) return NUMBER;

-- End fix for Bug # 4319171.

-- Bug 4490532 Begin
g_self_project_id       NUMBER;
g_self_object_version_id    NUMBER;
g_self_as_of_date       DATE;
g_self_current_flag     VARCHAR2(1);
g_self_rec_version_number   NUMBER;
g_self_act_effort       NUMBER;
g_self_act_cost         NUMBER;
g_self_etc_effort       NUMBER;
g_self_etc_cost         NUMBER;

function get_self_amounts(p_amount_type         IN VARCHAR2
                   , p_structure_sharing_code   IN VARCHAR2
                   , p_prg_group                IN NUMBER
           , p_project_id       IN NUMBER
           , p_object_version_id    IN NUMBER
           , p_proj_element_id      IN NUMBER
           , p_as_of_date       IN DATE
           , p_current_flag     IN VARCHAR2
           , p_record_version_number    IN NUMBER
           ) return NUMBER;
-- Bug 4490532 End

-- Bug 4871809, added this function for perf reasons, used in pa_progress_pvt.
function get_w_pub_prupid_asofdate(p_project_id  IN  number,
                                         p_object_id   IN  number,
                                         p_object_type IN  varchar2,
                                         p_task_id     IN  number,
                                         p_as_of_date  IN  date,
                                         p_chk_task    IN  varchar2 default 'Y') return number;

function get_w_pub_currflag(p_project_id  IN  number,
                            p_object_id   IN  number,
                            p_object_type IN  varchar2,
                            p_task_id     IN  number,
                            p_chk_task    IN  varchar2 default 'N') return varchar2;

function check_etc_overridden(p_plan_qty    IN   NUMBER,
 	                               p_actual_qty  IN   NUMBER,
 	                               p_etc_qty     IN   NUMBER) return varchar2;

function check_ta_has_prog(
                           p_project_id IN NUMBER,
                           p_proj_element_id IN NUMBER,
                           p_element_ver_id IN NUMBER ) return varchar2;


--Start changes for Bug 6664716
procedure get_plan_value
(  p_project_id                  IN        NUMBER
  ,p_structure_version_id        IN        NUMBER
  ,p_element_id                  IN        NUMBER
  ,p_as_of_date                  IN        DATE
  );

procedure clear_tmp_tables (p_task_id IN Number Default Null);
--End changes for Bug 6664716


-- Bug 7259306
FUNCTION get_def_as_of_date_prog_report(
    p_project_id        pa_progress_rollup.project_id%TYPE,
    p_proj_element_id   pa_progress_rollup.proj_element_id%TYPE,
    p_object_type       pa_progress_rollup.object_type%TYPE := 'PA_TASKS'
) RETURN DATE;

-- Bug 7633088
procedure set_override_as_of_date(p_as_of_date IN DATE DEFAULT to_date(NULL));


end PA_PROGRESS_UTILS;


/
