--------------------------------------------------------
--  DDL for Package PA_PROGRESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROGRESS_PUB" AUTHID CURRENT_USER as
/* $Header: PAPCPUBS.pls 120.3.12010000.3 2009/06/25 13:58:48 atshukla ship $ */

g_wbs_apply_prog      number := null;
--  Bug 3606627 : Changed Defaulting to g_miss_xxx instead of null
TYPE PA_TASK_PROGRESS_LIST_REC_TYPE IS RECORD
(
TASK_ID				NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
TASK_NAME			VARCHAR2(20)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
TASK_NUMBER			VARCHAR2(25)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
PM_TASK_REFERENCE		VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
PERCENT_COMPLETE		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
DESCRIPTION			VARCHAR2(250)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
OBJECT_ID			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
OBJECT_VERSION_ID		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
OBJECT_TYPE			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
PROGRESS_STATUS_CODE		VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
PROGRESS_COMMENT		VARCHAR2(4000)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
ACTUAL_START_DATE		Date		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
ACTUAL_FINISH_DATE		Date		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
ESTIMATED_START_DATE		Date		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
ESTIMATED_FINISH_DATE		Date		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
SCHEDULED_START_DATE		Date		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
SCHEDULED_FINISH_DATE		Date		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
TASK_STATUS			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
EST_REMAINING_EFFORT		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
ACTUAL_WORK_QUANTITY		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
LOWEST_LEVEL_TASK		VARCHAR2(1)	:= 'N',
LATEST_AS_OF_DATE		Date		:= NULL,
PROGRESS_MODE			VARCHAR2(30)	:= 'N',
ETC_COST			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,   /* FP M task progress bug 3420093 */
PM_DELIVERABLE_REFERENCE	VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 3606627
PM_TASK_ASSGN_REFERENCE		VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 3606627
ACTUAL_COST_TO_DATE		NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,  -- Bug 3606627
ACTUAL_EFFORT_TO_DATE		NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  -- Bug 3606627
);

TYPE PA_TASK_PROGRESS_LIST_TBL_TYPE IS TABLE OF PA_TASK_PROGRESS_LIST_REC_TYPE
   INDEX BY BINARY_INTEGER;

-- Progress Management Change for bug # 3420093.

TYPE PA_NUM_1000_NUM IS VARRAY(1000) OF NUMBER;

PROCEDURE UPDATE_TASK_PROGRESS(
 p_api_version                  IN      NUMBER          :=1.0                                   ,
 p_init_msg_list                IN      VARCHAR2        :=FND_API.G_TRUE                        ,
 p_commit                       IN      VARCHAR2        :=FND_API.G_FALSE                       ,
 p_validate_only                IN      VARCHAR2        :=FND_API.G_TRUE                        ,
 p_validation_level             IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL            ,
 p_calling_module               IN      VARCHAR2        :='SELF_SERVICE'                        ,
 p_calling_mode			IN      VARCHAR2	:= null					,
 p_debug_mode                   IN      VARCHAR2        :='N'                                   ,
 p_max_msg_count                IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_action                       IN      VARCHAR2        default 'SAVE'                          ,
 p_bulk_load_flag               IN      VARCHAR2        default 'N'                             ,
 p_progress_mode                IN      VARCHAR2        default 'FUTURE'                        ,
 p_percent_complete_id          IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_project_id                   IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_object_id                    IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_object_version_id            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_object_type                  IN      Varchar2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_as_of_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_percent_complete             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_progress_status_code         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_progress_comment             IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_brief_overview               IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_actual_start_date            IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_finish_date           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimated_start_date         IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimated_finish_date        IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_start_date         IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_finish_date        IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_record_version_number        IN      NUMBER                                                  ,
 p_task_status                  IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_est_remaining_effort         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_actual_work_quantity         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_pm_product_code              IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_structure_type               IN      VARCHAR2        := 'WORKPLAN'                           ,
 p_actual_effort                IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_actual_effort_this_period    IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  ,
 p_prog_fom_wp_flag             IN      VARCHAR2        := 'N'                                  ,
 p_planned_cost                 IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_planned_effort               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_structure_version_id         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_eff_rollup_percent_complete  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM , --    3910193
 x_resource_list_member_id      OUT    NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
 x_return_status                OUT    NOCOPY VARCHAR2                                                 , --File.Sql.39 bug 4440895
 x_msg_count                    OUT    NOCOPY NUMBER                                                   , --File.Sql.39 bug 4440895
 x_msg_data                     OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
;

-- Start of comments
--      API name        : ROLLUP_PROGRESS_PVT
--      Type            : Public
--      Pre-reqs        : For Program Rollup, the sub project buckets should be populated.
--      Purpose         : Rolls up the structure
--      Parameters Desc :
--              P_OBJECT_TYPE                   Possible values PA_ASSIGNMENTS, PA_DELIVERABLES, PA_TASKS
--              P_OBJECT_ID                     For assignments, pass resource_assignment_id, otherwise
--                                              proj_element_id of the deliverable and task
--              p_object_version_id             For Assignments, pass task_version_id, otherwise
--                                              element_version_id of the deliverable and task
--              p_task_version_id               For tasks, assignments, deliverables pass the task version id
--                                              , for struture pass null
--              p_lowest_level_task             Does not seem to be required
--              p_process_whole_tree            To indicate if whole tree rollup is not required. It will
--                                              do just 2 level rollup if N
--              p_structure_version_id          Structure version id of the publsihed or working structure version
--              p_structure_type                Possible values WORKPLAN, FINANCIAL
--              p_fin_rollup_method             Possible values are COST, EFFORT
--              p_wp_rollup_method              Possible values are COST, EFFORT, MANUAL, DURATION
--              p_rollup_entire_wbs             To indicate if it requires the whole structure rollup, in this
--                                              case it will ignore the passed object and starts with the lowest
--                                              task
--      History         : 17-MAR-04  amksingh   Rewritten For FPM Development Tracking Bug 3420093
-- End of comments

PROCEDURE ROLLUP_PROGRESS_PVT(
 p_api_version                          IN      NUMBER          :=1.0
,p_init_msg_list                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_commit                               IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level                     IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module                       IN      VARCHAR2        :='SELF_SERVICE'
,p_debug_mode                           IN      VARCHAR2        :='N'
,p_max_msg_count                        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_progress_mode                        IN      VARCHAR2        := 'FUTURE'
,p_project_id                           IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_object_type                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_object_id                            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_object_version_id			IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_task_version_id                      IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_as_of_date                           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,p_lowest_level_task			IN      VARCHAR2        := 'N'
,p_process_whole_tree			IN      VARCHAR2        := 'Y'
,p_structure_version_id			IN      NUMBER
,p_structure_type                       IN      VARCHAR2        := 'WORKPLAN'
,p_fin_rollup_method			IN      VARCHAR2        := 'COST'
,p_wp_rollup_method                     IN      VARCHAR2        := 'COST'
,p_rollup_entire_wbs			IN      VARCHAR2        := 'N'
,p_working_wp_prog_flag                 IN      VARCHAR2        := 'N'  --maansari7/18  to be passed form apply lp progress to select regular planned amounts to send to schduling api for percent comnplete and earned value calculations.
,p_upd_new_elem_ver_id_flag             IN      VARCHAR2        := 'Y'  -- rtarway, for BUG 3951024
,x_return_status                        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Start of comments
--      API name        : UPDATE_ROLLUP_PROGRESS_PVT
--      Type            : Private
--      Pre-reqs        : ROLLUP_PROGRESS_PVT shd have been called.
--      Purpose         : Updates the Rolled up data
--      Parameters Desc :
--              P_OBJECT_TYPE                   Possible values PA_ASSIGNMENTS, PA_DELIVERABLES, PA_TASKS
--              P_OBJECT_ID                     For assignments, pass resource_assignment_id, otherwise
--                                              proj_element_id of the deliverable and task
--              p_object_version_id             For Assignments, pass task_version_id, otherwise
--                                              element_version_id of the deliverable and task
--              p_task_version_id               For tasks, assignments, deliverables pass the task version id
--                                              , for struture pass null
--              p_lowest_level_task             Does not seem to be required
--              p_structure_version_id		Structure version id of the publsihed or working structure version
--              p_structure_type                Possible values WORKPLAN, FINANCIAL
--              p_fin_rollup_method             Possible values are COST, EFFORT
--              p_wp_rollup_method              Possible values are COST, EFFORT, MANUAL, DURATION
--              p_published_structure		To indicate if the passed structure version is published
--      History         : 17-MAR-04  amksingh   Rewritten For FPM Development Tracking Bug 3420093
-- End of comments

PROCEDURE UPDATE_ROLLUP_PROGRESS_PVT(
  p_api_version				IN      NUMBER			:=1.0
 ,p_init_msg_list                       IN      VARCHAR2                :=FND_API.G_TRUE
 ,p_commit                              IN      VARCHAR2                :=FND_API.G_FALSE
 ,p_validate_only                       IN      VARCHAR2                :=FND_API.G_TRUE
 ,p_validation_level			IN      NUMBER			:=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                      IN      VARCHAR2                :='SELF_SERVICE'
 ,p_debug_mode                          IN      VARCHAR2                :='N'
 ,p_max_msg_count                       IN      NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id				IN      NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id			IN      NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date                          IN      DATE                    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_rollup_table                        IN      PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE
 ,p_lowest_level_task			IN      VARCHAR2                := 'N'
 ,p_task_version_id			IN      NUMBER
 ,p_structure_version_id                IN      NUMBER
 ,p_structure_type                      IN      VARCHAR2                := 'WORKPLAN'
 ,p_fin_rollup_method			IN      VARCHAR2                := 'COST'
 ,p_wp_rollup_method			IN      VARCHAR2                := 'COST'
 ,p_published_structure			IN      VARCHAR2
 ,p_rollup_entire_wbs                   IN      VARCHAR2		:= 'N' -- FPM Dev CR 7
 ,p_working_wp_prog_flag                 IN      VARCHAR2        := 'N'  --bug 3829341
 ,p_upd_new_elem_ver_id_flag             IN      VARCHAR2        := 'Y'  -- rtarway, for BUG 3951024
 ,p_progress_mode			IN	VARCHAR2        := 'FUTURE'  -- 4091457
 ,x_return_status                       OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                           OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE CREATE_PROJ_PROG_ATTR(
  p_api_version	      IN	NUMBER	:=1.0
 ,p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE
 ,p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE
 ,p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE
 ,p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE'
 ,p_debug_mode	      IN	VARCHAR2	:='N'
 ,p_max_msg_count	      IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_OBJECT_TYPE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_OBJECT_ID                       IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_PROGRESS_CYCLE_ID               IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_WQ_ENABLE_FLAG                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_REMAIN_EFFORT_ENABLE_FLAG       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PERCENT_COMP_ENABLE_FLAG        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_NEXT_PROGRESS_UPDATE_DATE       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_action_set_id                   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_TASK_WEIGHT_BASIS_CODE          IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,X_PROJ_PROGRESS_ATTR_ID           IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,P_ALLOW_COLLAB_PROG_ENTRY         IN VARCHAR2 := 'N'
 ,P_ALLW_PHY_PRCNT_CMP_OVERRIDES    IN VARCHAR2 := 'N'
 ,P_STRUCTURE_TYPE                  IN VARCHAR2 := 'WORKPLAN'
 ,x_return_status	      OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count	      OUT 	NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data	            OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

);

PROCEDURE UPDATE_PROJ_PROG_ATTR(
  p_api_version	      IN	NUMBER	:=1.0
 ,p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE
 ,p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE
 ,p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE
 ,p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE'
 ,p_debug_mode	      IN	VARCHAR2	:='N'
 ,p_max_msg_count	      IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_OBJECT_TYPE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_OBJECT_ID                       IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_PROGRESS_CYCLE_ID               IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_WQ_ENABLE_FLAG                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_REMAIN_EFFORT_ENABLE_FLAG       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PERCENT_COMP_ENABLE_FLAG        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_NEXT_PROGRESS_UPDATE_DATE       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_action_set_id                   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_TASK_WEIGHT_BASIS_CODE          IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PROJ_PROGRESS_ATTR_ID           IN NUMBER
 ,p_record_version_number           IN NUMBER
 ,p_allow_collab_prog_entry     IN      VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_allw_phy_prcnt_cmp_overrides IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_structure_type		IN	VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,x_return_status	      OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count	      OUT 	NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data	            OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE DELETE_PROJ_PROG_ATTR(
  p_api_version	      IN	NUMBER	:=1.0
 ,p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE
 ,p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE
 ,p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE
 ,p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE'
 ,p_debug_mode	      IN	VARCHAR2	:='N'
 ,p_max_msg_count	      IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_OBJECT_TYPE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_OBJECT_ID                       IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_type                  IN VARCHAR2 := 'WORKPLAN' -- Amit
 ,x_return_status	      OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count	      OUT 	NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data	            OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE delete_progress_record(
  p_api_version	      IN	NUMBER	:=1.0
 ,p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE
 ,p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE
 ,p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE
 ,p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE'
 ,p_debug_mode	      IN	VARCHAR2	:='N'
 ,p_max_msg_count	      IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id         IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_version_id              IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_return_status	      OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count	      OUT 	NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data	            OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE push_down_task_status(
  p_api_version       IN        NUMBER  :=1.0
 ,p_init_msg_list             IN        VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                  IN  VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only             IN        VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level    IN      NUMBER  :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module            IN        VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode        IN        VARCHAR2        :='N'
 ,p_max_msg_count             IN        NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_status         IN    VARCHAR2
 ,p_project_id                IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_id         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id    IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_type       IN Varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_as_of_date          IN DATE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_actual_finish_date  IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_structure_type      IN VARCHAR2 := 'WORKPLAN'
 ,x_return_status             OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count         OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE ROLLUP_FUTURE_PROGRESS_PVT(
 p_project_id              IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_OBJECT_TYPE            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_OBJECT_ID              IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_lowest_level_task      IN VARCHAR2 := 'N'
 ,p_calling_module	   IN VARCHAR2	:='SELF_SERVICE'
 ,p_structure_type         IN   VARCHAR2        := 'WORKPLAN'
 ,p_structure_version_id   IN   NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_rollup_method      IN   VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_wp_rollup_method       IN   VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_rollup_entire_wbs      IN   VARCHAR2        := 'N' -- Bug 3606627
 ,x_return_status           OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Update_PC_PARTY_MAERGE (PUBLIC)
--   This is the procedure being called during the Party Merge.
--   The input/output arguments format matches the document PartyMergeDD.doc.
--   The goal is to fix the PUBLISHED_BY_PARTY_ID in pa_percent_completes table to point to the
--   same party when two similar parties are begin merged.
--
-- Usage example in pl/sql
--   This procedure should only be called from the PartyMerge utility.
--
procedure Update_PC_PARTY_MERGE(p_entity_name in varchar2,
                                p_from_id in number,
                        p_to_id in out nocopy number,
                        p_from_fk_id in number,
                        p_to_fk_id in number,
                        p_parent_entity_name in varchar2,
                        p_batch_id in number,
                        p_batch_party_id in number,
                        p_return_status in out nocopy varchar2);

-- Progress Management Changes. Bug # 3420093.

PROCEDURE apply_lp_prog_on_cwv(
  p_api_version       		IN      NUMBER  	:=1.0
 ,p_init_msg_list       	IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit              	IN  	VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only       	IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level    	IN      NUMBER  	:=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module      	IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode          	IN      VARCHAR2        :='N'
 ,p_max_msg_count       	IN      NUMBER  	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id			IN	NUMBER
 ,p_working_str_version_id	IN	NUMBER
 ,x_return_status     		OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count         		OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data            	OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Progress Management Changes. Bug # 3420093.

PROCEDURE delete_working_wp_progress(
  p_api_version       		IN      NUMBER  	:=1.0
 ,p_init_msg_list       	IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit              	IN  	VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only       	IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level    	IN      NUMBER  	:=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module      	IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode          	IN      VARCHAR2        :='N'
 ,p_max_msg_count       	IN      NUMBER  	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_version_id             IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type()
 ,p_calling_context             IN      VARCHAR2        := 'STRUCTURE_VERSION'
 ,x_return_status     		OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count         		OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data            	OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Progress Management Changes. Bug # 3420093.

Procedure PULL_SUMMARIZED_ACTUALS (
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,P_Project_ID        IN  NUMBER
   ,P_Calling_Mode      IN  VARCHAR2
   ,x_return_status     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- Progress Management Changes. Bug # 3420093.

PROCEDURE update_progress(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_action			IN	VARCHAR2	:='SAVE'
 ,P_rollup_entire_wbs_flag	IN	VARCHAR2	:='N'
 ,p_progress_mode		IN	VARCHAR2	:='FUTURE'
 ,p_percent_complete_id		IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id			IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_id			IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id		IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_type			IN	VARCHAR2	:='PA_TASKS'
 ,p_as_of_date			IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_percent_complete		IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_progress_status_code	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_progress_comment		IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_brief_overview		IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_actual_start_date		IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_actual_finish_date		IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_estimated_start_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_estimated_finish_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_scheduled_start_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_scheduled_finish_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_record_version_number	IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_status			    IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_est_remaining_effort	IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_ETC_cost                IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_actual_work_quantity	IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_product_code		    IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_structure_type		    IN	VARCHAR2	:='WORKPLAN'
 ,p_actual_effort		IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_actual_cost			IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_actual_effort_this_period   IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_actual_cost_this_period     IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_sub_type		IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_task_id			IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id	IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_prog_fom_wp_flag		IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_rollup_reporting_lines_flag	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_planned_cost                IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_planned_effort              IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_rate_based_flag             IN      VARCHAR         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_class_code         IN      VARCHAR         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_transfer_wp_pc_flag         IN      VARCHAR         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_txn_currency_code           IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_rbs_element_id              IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- ,p_resource_list_member_id     IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- Bug 3764224
 ,p_resource_assignment_id    IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  -- Bug 3764224
 ,p_eff_rollup_percent_complete  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  --    3910193
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Progress Management Changes. Bug # 3420093.

PROCEDURE populate_pji_tab_for_plan(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
,p_project_element_id           IN      NUMBER   DEFAULT NULL  --bug 4183307
,p_structure_version_id         IN      NUMBER   DEFAULT NULL
,p_baselined_str_ver_id         IN      NUMBER   DEFAULT NULL
,p_structure_type               IN      VARCHAR2        := 'WORKPLAN' -- Bug 3627315
,p_populate_tmp_tab_flag        IN      VARCHAR2        := 'Y'   --bug 4290593
,p_program_rollup_flag		IN      VARCHAR2        := 'Y'   --bug 4392189
,p_calling_context		IN      VARCHAR2        := 'ROLLUP'  -- bug 4392189 , Possible values are ROLLUP and SUMMARIZE
,p_as_of_date			IN      DATE		:= null  -- bug 4392189
,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE push_workplan_actuals(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_Id				NUMBER
 ,p_structure_version_id		NUMBER
 ,p_proj_element_id			NUMBER
 ,p_object_id				NUMBER
 ,p_object_type				VARCHAR2
 ,p_as_of_date				DATE
 ,p_resource_assignment_id		NUMBER		:=null -- Bug 4186007
 ,p_resource_list_member_id		NUMBER		:=null-- Bug 4186007
 ,p_rbs_element_id			NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_rate_based_flag			VARCHAR2	:= 'Y' -- Default for Task
 ,p_resource_class_code			VARCHAR2	:='PEOPLE' -- Default for Task
-- ,p_TXN_CURRENCY_CODE			VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Bug 3595585 Removed not needed
 ,p_act_TXN_COST_this_period		NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_act_PRJ_COST_this_period		NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_act_POU_COST_this_period		NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_act_effort_this_period		NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_etc_TXN_COST_this_period		NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM-- Bug 3595585
 ,p_etc_PRJ_COST_this_period		NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM-- Bug 3595585
 ,p_etc_POU_COST_this_period		NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM-- Bug 3595585
 ,p_etc_effort_this_period		NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM-- Bug 3595585
 ,p_call_pji_apis_flag          	VARCHAR2 	:= 'Y'
 ,p_act_TXN_raw_COST_this_period	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- Bug 3621404
 ,p_act_PRJ_raw_COST_this_period	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- Bug 3621404
 ,p_act_POU_raw_COST_this_period	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- Bug 3621404
 ,p_etc_TXN_raw_COST_this_period	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- Bug 3621404
 ,p_etc_PRJ_raw_COST_this_period	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- Bug 3621404
 ,p_etc_POU_raw_COST_this_period	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- Bug 3621404
 -- BUG # 3659659.
 ,p_txn_currency_code                   VARCHAR2        := null
 ,p_prj_currency_code                   VARCHAR2        := null
 ,p_pfn_currency_code                   VARCHAR2        := null
 -- BUG # 3659659.
--bug3675107
 ,p_pa_period_name                      VARCHAR2    :=null
 ,p_gl_period_name                      VARCHAR2    :=null
--bug3675107
 ,x_return_status		OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count			OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data			OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Progress Management Change for bug # 3420093.

PROCEDURE program_rollup_pvt(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_structure_type              IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_structure_ver_id            IN      NUMBER	        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE transfer_wp_percent_to_fin(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE publish_progress(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
 ,p_working_str_ver_id          IN      NUMBER    -- Bug 4190086
 ,p_pub_structure_version_id    IN      NUMBER          -- Bug 3839288
 ,x_upd_new_elem_ver_id_flag    OUT     NOCOPY VARCHAR2    -- BUG 3951024, rtarway --File.Sql.39 bug 4440895
 ,x_as_of_date			       OUT     NOCOPY DATE		-- Bug 3839288	 --File.Sql.39 bug 4440895
 ,x_task_weight_basis_code      OUT     NOCOPY VARCHAR2	-- Bug 3839288	 --File.Sql.39 bug 4440895
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE GET_SUMMARIZED_ACTUALS(p_project_id_list   IN  SYSTEM.pa_num_tbl_type,
                                 p_extraction_type   IN  VARCHAR2,
                                 p_plan_res_level    IN  VARCHAR2,
                                 p_proj_pgm_level    IN  SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type(),
                                 x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data          OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
-- Start of comments
--      API name        : UPDATE_FINANCIAL_TASK_PROGRESS
--      Type            : Public
--      Purpose         : Updates Financial Percent Complete
--      Parameters Desc :
--	p_object_type			PA_TASKS
--	p_as_of_date			The as_of_date for which progress to be entered
--	p_object_version_id		The task version id
--	p_structure_version_id	        Structure version id of the publsihed or working structure version
--      p_progress_comment              Progress comment
--      p_brief_overview		Brief Overview
--	p_structure_type		FINANCIAL
--	p_rollup_entire_wbs		To indicate if it requires the whole structure rollup, in this
--					case it will ignore the passed object and starts with the lowest
--					task
--      History         : 29-MAR-04  sdnambia   Written For FPM Development Tracking Bug 3420093
-- End of comments

-- FPM Dev CR 1 : Added Following Procedure
PROCEDURE UPDATE_FINANCIAL_TASK_PROGRESS(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_action                      IN      VARCHAR2        :='SAVE'
 ,P_rollup_entire_wbs_flag      IN      VARCHAR2        :='N'
 ,p_progress_mode               IN      VARCHAR2        :='FUTURE'
 ,p_percent_complete_id         IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_id                   IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id           IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_type                 IN      VARCHAR2        :='PA_TASKS'
 ,p_as_of_date                  IN      DATE            :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_percent_complete            IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_progress_status_code        IN      VARCHAR2        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_progress_comment            IN      VARCHAR2        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_brief_overview              IN      VARCHAR2        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_record_version_number       IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_product_code             IN      VARCHAR2        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_structure_type              IN      VARCHAR2        :='FINANCIAL'
 ,p_task_id                     IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id        IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Progress Management Changes. Bug # 3420093.

PROCEDURE re_rollup_progress(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
 ,p_structure_version_id      	IN      NUMBER
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Bug 3633293 : Added populate_bulk_pji_tab_for_plan
PROCEDURE populate_bulk_pji_tab_for_plan(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_person_id				NUMBER
 ,x_return_status		OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count			OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data			OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Start of comments
--      API name        : ASGN_DLV_TO_TASK_ROLLUP_PVT
--      Type            : Private
--      Pre-reqs        : None.
--      Purpose         : This API is intdended to be called for Assignment, Deliverables in Task Progress Details page when user clicks Recalculate button
--                      : This does partial rollup of working progress records
--      History         : 15-JUNE-04  amksingh   Rewritten For FPM Development Bug 3614828
-- End of comments

PROCEDURE ASGN_DLV_TO_TASK_ROLLUP_PVT(
 p_api_version                          IN      NUMBER          :=1.0
,p_init_msg_list                        IN      VARCHAR2        :=FND_API.G_FALSE -- Since it is a private API so false
,p_commit                               IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level                     IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module                       IN      VARCHAR2        :='SELF_SERVICE'
,p_debug_mode                           IN      VARCHAR2        :='N'
,p_max_msg_count                        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id                           IN      NUMBER
,p_task_id				IN      NUMBER
,p_task_version_id                      IN      NUMBER
,p_as_of_date                           IN      DATE
,p_structure_version_id                 IN      NUMBER
,p_wp_rollup_method                     IN      VARCHAR2        := 'COST'
,x_return_status                        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Start of comments
--      API name        : COPY_PROGRESS_ACT_ETC
--      Type            : Private
--      Pre-reqs        : None.
--      Purpose         : This API is intdended to be used for copying actuals and etc from one structure
--                        version to another. If there is no progress records exists then the api pass null
--                        for act and etc.
--      History         : 30-JUNE-04  Rakesh Raghavan  Rewritten For FPM Development Bug
--                        28-JUL-2004 Rakesh Raghavan  Added parameter: p_last_pub_str_version_id.
-- End of comments

PROCEDURE COPY_PROGRESS_ACT_ETC(
 p_api_version              IN      NUMBER          :=1.0
,p_init_msg_list            IN      VARCHAR2        :=FND_API.G_FALSE -- FALSE for private API.
,p_commit                   IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only            IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level         IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module           IN      VARCHAR2        :='SELF_SERVICE'
,p_debug_mode               IN      VARCHAR2        :='N'
,p_max_msg_count            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id               IN      NUMBER
,p_src_str_ver_id           IN      NUMBER
,p_dst_str_ver_id           IN      NUMBER
,p_pub_wp_with_prog_flag    IN      VARCHAR2        := 'Y'
,p_calling_context          IN      VARCHAR2        := 'PUBLISH'
,p_last_pub_str_version_id  IN	    NUMBER	    := NULL
,p_copy_actuals_flag        IN      VARCHAR2        := 'Y'
,p_copy_ETC_flag            IN      VARCHAR2        := 'Y'
,p_pji_conc_prog_context    IN	    VARCHAR2	    := 'N' -- Fix for Bug # 3996159.
,x_return_status            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Bug 3807299 : new API which will be called from update_progress and AMG pa_status_pub.update_progress
PROCEDURE update_link_proj_rollup_dates(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_project_id                  IN      NUMBER
 ,p_task_id			IN      NUMBER
 ,p_task_version_id		IN      NUMBER
 ,p_as_of_date                  IN      DATE
 ,p_structure_version_id        IN      NUMBER
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE UPDATE_PROGRESS_BULK(
  p_api_version				IN      NUMBER					:=1.0
 ,p_init_msg_list			IN      VARCHAR2				:=FND_API.G_TRUE
 ,p_commit				IN      VARCHAR2				:=FND_API.G_FALSE
 ,p_validate_only			IN      VARCHAR2				:=FND_API.G_TRUE
 ,p_validation_level			IN      NUMBER					:=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module			IN      VARCHAR2				:='SELF_SERVICE'
 ,p_calling_mode			IN      VARCHAR2				:= null
 ,p_debug_mode				IN      VARCHAR2				:='N'
 ,p_max_msg_count			IN      NUMBER					:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_action				IN      VARCHAR2				:='SAVE'
 ,p_rollup_entire_wbs_flag		IN      VARCHAR2				:='N'
 ,p_progress_mode			IN      VARCHAR2				:='FUTURE'
 ,p_pm_product_code			IN      VARCHAR2				:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_structure_type			IN      VARCHAR2				:= 'WORKPLAN'
 ,p_project_id_tbl			IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_object_id_tbl			IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_object_version_id_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_object_type_tbl			IN      SYSTEM.pa_varchar2_30_tbl_type		:= SYSTEM.pa_varchar2_30_tbl_type()
 ,p_task_id_tbl				IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_structure_version_id_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_as_of_date_tbl			IN      SYSTEM.pa_date_tbl_type			:= SYSTEM.pa_date_tbl_type()
 ,p_rbs_element_id_tbl            	IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_resource_assignment_id_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_rate_based_flag_tbl        		IN      SYSTEM.pa_varchar2_1_tbl_type		:= SYSTEM.pa_varchar2_1_tbl_type()
 ,p_resource_class_code_tbl 		IN      SYSTEM.pa_varchar2_30_tbl_type		:= SYSTEM.pa_varchar2_30_tbl_type()
 ,p_txn_currency_code_tbl      		IN      SYSTEM.pa_varchar2_30_tbl_type		:= SYSTEM.pa_varchar2_30_tbl_type()
 ,p_percent_complete_id_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_record_version_number_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_percent_complete_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_eff_rup_percent_complete_tbl	IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_task_status_tbl			IN      SYSTEM.pa_varchar2_150_tbl_type		:= SYSTEM.pa_varchar2_150_tbl_type()
 ,p_progress_status_code_tbl		IN      SYSTEM.pa_varchar2_30_tbl_type		:= SYSTEM.pa_varchar2_30_tbl_type()
 ,p_progress_comment_tbl		IN      SYSTEM.pa_varchar2_2000_tbl_type	:= SYSTEM.pa_varchar2_2000_tbl_type()
 ,p_brief_overview_tbl			IN      SYSTEM.pa_varchar2_250_tbl_type		:= SYSTEM.pa_varchar2_250_tbl_type()
 ,p_actual_start_date_tbl		IN      SYSTEM.pa_date_tbl_type			:= SYSTEM.pa_date_tbl_type()
 ,p_actual_finish_date_tbl		IN      SYSTEM.pa_date_tbl_type			:= SYSTEM.pa_date_tbl_type()
 ,p_estimated_start_date_tbl		IN      SYSTEM.pa_date_tbl_type			:= SYSTEM.pa_date_tbl_type()
 ,p_estimated_finish_date_tbl		IN      SYSTEM.pa_date_tbl_type			:= SYSTEM.pa_date_tbl_type()
 ,p_scheduled_start_date_tbl		IN      SYSTEM.pa_date_tbl_type			:= SYSTEM.pa_date_tbl_type()
 ,p_scheduled_finish_date_tbl		IN      SYSTEM.pa_date_tbl_type			:= SYSTEM.pa_date_tbl_type()
 ,p_est_remaining_effort_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_etc_cost_tbl			IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_actual_work_quantity_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_actual_effort_tbl			IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_actual_cost_tbl			IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_act_eff_this_period_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_actual_cost_this_period_tbl		IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_planned_cost_tbl			IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,p_planned_effort_tbl			IN      SYSTEM.pa_num_tbl_type			:= SYSTEM.pa_num_tbl_type()
 ,x_return_status			OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count				OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data				OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Begin fix for Bug # 4262985.

PROCEDURE apply_lp_prog_on_cwv_wrp(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER
 ,p_working_str_version_id      IN      NUMBER
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- End fix for Bug # 4262985.

end PA_PROGRESS_PUB;

/
