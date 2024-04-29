--------------------------------------------------------
--  DDL for Package PA_TASK_ASSIGNMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_ASSIGNMENTS_PUB" AUTHID CURRENT_USER AS
-- $Header: PATAPUBS.pls 120.5.12010000.2 2009/07/15 08:43:56 kkorrapo ship $
/*#
 * This package contains the public APIs for project task resource information.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Task Assignments API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_TASK_RESOURCE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

TYPE assignment_in_rec_type IS RECORD
(  -- All parameters listed initially are used in creation and updation
   --Either project reference or id is required
   pm_project_reference       VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,pa_project_id              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  --Structure version id is required currently
  ,pa_structure_version_id    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  --Task reference or id is required
  ,pm_task_reference          VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,pa_task_id                 NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,pa_task_element_version_id NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   -- Task Asgmt. Reference is required for creation. Asgmt. Id or reference required for determination of updation.
   -- Task Assignment Reference can be created but not updated.
  ,pm_task_asgmt_reference    VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,pa_task_assignment_id      NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,resource_alias             VARCHAR2(80)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- Planning resource list member id required for creation
  ,resource_list_member_id    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,start_date                 DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,end_date                   DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,planned_quantity           NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,planned_total_raw_cost     NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,planned_total_bur_cost     NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,currency_code              VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  --This attribute is added for Bug 3948128: TA Delay CR by DHI
  ,scheduled_delay            NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  --Following are flexfield parameters
  ,attribute_category         VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute1                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute2                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute3                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute4                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute5                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute6                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute7                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute8                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute9                 VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute10                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute11                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute12                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute13                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute14                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute15                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute16                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute17                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute18                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute19                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute20                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute21                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute22                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute23                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute24                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute25                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute26                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute27                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute28                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute29                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,attribute30                VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   -- Following parameters used  for update process only..........
   --=============================================================
  ,description                VARCHAR2(240)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,use_task_schedule_flag     VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  --Rate Overrides.
  ,raw_cost_rate_override     NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,burd_cost_rate_override    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,billable_work_percent      NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  --Mfg cost type is converted to id if mfg cost type id is not provided
  ,mfg_cost_type              VARCHAR2(10)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,mfg_cost_type_id           NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   -- Above parameters for update only..........
   --===============================================================
   --Pass in p_context of 'D' for explicit deletion
   --Pass in p_context of 'F' for implicit deletion based on task assignments not passed on tasks.
  ,p_context                  VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,spread_curve_id            NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM			--Bug#8646853
  ,spread_curve_name          varchar2(240)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR		--Bug#8646853
  ,fixed_date                   DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE         --Bug#8646853
);



TYPE assignment_out_rec_type IS RECORD
(  pa_task_id                 NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,resource_alias             VARCHAR2(80) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,resource_list_member_id    NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,pa_task_assignment_id      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,return_status              VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);



TYPE assignment_in_tbl_type IS TABLE OF assignment_in_rec_type
      INDEX BY BINARY_INTEGER;

TYPE assignment_out_tbl_type IS TABLE OF assignment_out_rec_type
      INDEX BY BINARY_INTEGER;


TYPE ta_del_rec_type IS RECORD
(  pa_task_assignment_id         NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   pa_task_elem_version_id       NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   del_ta_flag                   VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

TYPE assignment_del_tbl_type IS TABLE OF ta_del_rec_type
      INDEX BY BINARY_INTEGER;

TYPE task_asgmt_del_type IS RECORD
(  pa_task_id                 NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   start_del_index            NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   end_del_index              NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   del_flag                   VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);
TYPE task_asgmt_del_tbl_type IS TABLE OF task_asgmt_del_type
      INDEX BY BINARY_INTEGER;


TYPE assignment_periods_type IS RECORD
(  -- All parameters  are used after a task assignment is created for periodic data creation/updation.
   pm_product_code                VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR --SAME
   --Either project reference or id is required
  ,pm_project_reference       VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,pa_project_id              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  --Structure version id is required currently
  ,pa_structure_version_id    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  --Task reference or id is required
  ,pm_task_reference          VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,pa_task_id                 NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,pa_task_element_version_id NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- Task Asgmt. Reference is required for creation. Asgmt. Id or reference required for updation.
  ,pm_task_asgmt_reference    VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,pa_task_assignment_id      NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,resource_alias             VARCHAR2(80)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- Planning resource list member id required for creation
  ,resource_list_member_id    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  --Name of the period if available
  ,period_name                VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  --Start date of the period
  ,start_date                 DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  --End date of the period
  ,end_date                   DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,quantity                   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,txn_raw_cost               NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,txn_burdened_cost          NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,txn_currency_code          VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

);


TYPE assignment_periods_tbl_type IS TABLE OF assignment_periods_type
      INDEX BY BINARY_INTEGER;

--Temporary table below will be reinitialized at the end of every load cycle.
g_asgmts_periods_tbl  assignment_periods_tbl_type;
g_asgmts_periods_out_tbl  assignment_out_tbl_type;
g_asgmts_periods_tbl_count NUMBER;

empty_asgmts_periods_tbl assignment_periods_tbl_type;

--All type contained in paxdty01.sql , paxdty03.sql


-- global plsql tables of assignment records
g_task_asgmts_in_tbl assignment_in_tbl_type;
g_task_asgmts_out_tbl assignment_out_tbl_type;

g_task_asgmts_tbl_count NUMBER;

empty_task_asgmts_in_tbl assignment_in_tbl_type;
empty_task_asgmts_out_tbl assignment_out_tbl_type;

/*#
 * This API is used to load project task resources to a global PL/SQL table.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @param p_pm_task_reference External task reference
 * @param p_pa_task_id Identifier of the task in the Oracle Projects
 * @param p_pa_task_element_version_id Identifier of the task version in the Oracle Projects
 * @param p_pm_task_asgmt_reference External task resource reference
 * @param p_pa_task_assignment_id Identifier of the task resource in Oracle Projects
 * @param p_resource_alias Planning resource alias
 * @param p_resource_list_member_id Identifier of the planning resource
 * @param p_start_date Start date of the task resource assignment
 * @param p_end_date End date of the task resource assignment
 * @param p_planned_quantity Planned effort or quantity
 * @param p_planned_total_raw_cost Planned row cost
 * @param p_planned_total_bur_cost Planned burdened cost
 * @param p_currency_code Currency code
 * @param p_scheduled_delay Task Resource scheduled delay
 * @param p_attribute_category Descriptive flexfield category
 * @param p_attribute1 Descriptive flexfield attribute
 * @param p_attribute2 Descriptive flexfield attribute
 * @param p_attribute3 Descriptive flexfield attribute
 * @param p_attribute4 Descriptive flexfield attribute
 * @param p_attribute5 Descriptive flexfield attribute
 * @param p_attribute6 Descriptive flexfield attribute
 * @param p_attribute7 Descriptive flexfield attribute
 * @param p_attribute8 Descriptive flexfield attribute
 * @param p_attribute9 Descriptive flexfield attribute
 * @param p_attribute10 Descriptive flexfield attribute
 * @param p_attribute11 Descriptive flexfield attribute
 * @param p_attribute12 Descriptive flexfield attribute
 * @param p_attribute13 Descriptive flexfield attribute
 * @param p_attribute14 Descriptive flexfield attribute
 * @param p_attribute15 Descriptive flexfield attribute
 * @param p_attribute16 Descriptive flexfield attribute
 * @param p_attribute17 Descriptive flexfield attribute
 * @param p_attribute18 Descriptive flexfield attribute
 * @param p_attribute19 Descriptive flexfield attribute
 * @param p_attribute20 Descriptive flexfield attribute
 * @param p_attribute21 Descriptive flexfield attribute
 * @param p_attribute22 Descriptive flexfield attribute
 * @param p_attribute23 Descriptive flexfield attribute
 * @param p_attribute24 Descriptive flexfield attribute
 * @param p_attribute25 Descriptive flexfield attribute
 * @param p_attribute26 Descriptive flexfield attribute
 * @param p_attribute27 Descriptive flexfield attribute
 * @param p_attribute28 Descriptive flexfield attribute
 * @param p_attribute29 Descriptive flexfield attribute
 * @param p_attribute30 Descriptive flexfield attribute
 * @param up_description Description of the assignment (used only in update mode)
 * @param up_use_task_schedule_flag Flag indicating whether the assignment dates and the task scheduled dates are the same (used only in update mode)
 * @param up_raw_cost_rate_override Override raw cost rate (used only in update mode)
 * @param up_burd_cost_rate_override Override burdened cost rate (used only in update mode)
 * @param up_billable_work_percent Billable percent (used only in update mode)
 * @param up_mfg_cost_type Manufacturing cost type (used only in update mode)
 * @param up_mfg_cost_type_id Identifier of the manufacturing cost type (used only in update mode)
 * @param p_context_flag Flag indicating whether the task assignments that are not passed on the tasks will be deleted
 * @rep:paraminfo {@rep:precision 1}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Project Task Resources
 * @rep:compatibility S
*/
-- All parameters mentioned as p_ are for both create and update
-- All parameters mentioned as up_ are meant for updation.
PROCEDURE Load_Task_Assignments
( p_api_version_number       IN NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                               IN VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list                IN VARCHAR2          := FND_API.G_FALSE
 ,p_pm_project_reference     IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_pa_project_id                IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_structure_version_id      IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_reference        IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_pa_task_id               IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_task_element_version_id IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_asgmt_reference  IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_pa_task_assignment_id    IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_resource_alias           IN PA_VC_1000_80     := PA_VC_1000_80(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_resource_list_member_id  IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_start_date               IN PA_date_1000_date := PA_date_1000_date(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_end_date                 IN PA_date_1000_date := PA_date_1000_date(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_planned_quantity         IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_planned_total_raw_cost   IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_planned_total_bur_cost   IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_currency_code            IN PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 --This parameter is added for Bug 3948128: TA Delay CR by DHI
 ,p_scheduled_delay          IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_attribute_category       IN PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute1               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute2               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute3               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute4               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute5               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute6               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute7               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute8               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute9               IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute10              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute11              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute12              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute13              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute14              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute15              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute16              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute17              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute18              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute19              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute20              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute21              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute22              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute23              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute24              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute25              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute26              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute27              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute28              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute29              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_attribute30              IN PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,up_description             IN PA_VC_1000_240    := PA_VC_1000_240(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,up_use_task_schedule_flag  IN PA_VC_1000_1      := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,up_raw_cost_rate_override  IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,up_burd_cost_rate_override IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,up_billable_work_percent   IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,up_mfg_cost_type           IN PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,up_mfg_cost_type_id        IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_context_flag             IN PA_VC_1000_1      := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,x_return_status                    OUT NOCOPY VARCHAR2
) ;

/*#
 * This API is used to load periodic data of project task resources to a global PL/SQL table.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @param p_pm_task_reference External task reference
 * @param p_pa_task_id Identifier of the task in the Oracle Projects
 * @param p_pa_task_element_version_id Identifier of the task version in the Oracle Projects
 * @param p_pm_task_asgmt_reference External task resource reference
 * @param p_pa_task_assignment_id Identifier of the task resource in Oracle Projects
 * @param p_resource_alias Planning resource alias
 * @param p_resource_list_member_id Identifier of the planning resource
 * @param p_period_name Name of the period
 * @param p_start_date Start date of the period
 * @param p_end_date End date of the period
 * @param p_txn_quantity Planned effort or quantity for the period
 * @param p_txn_raw_cost Planned raw cost for the period
 * @param p_txn_bur_cost Planned burdened cost for the period
 * @param p_currency_code Currency code
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Periodic Data of Project Task Resources
 * @rep:compatibility S
*/
PROCEDURE Load_Task_Asgmt_Periods
( p_api_version_number       IN NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                               IN VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list                IN VARCHAR2          := FND_API.G_FALSE
 ,p_pm_project_reference     IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_project_id                IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_structure_version_id      IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_reference        IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_task_id               IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_task_element_version_id IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_asgmt_reference  IN PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_pa_task_assignment_id    IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_resource_alias           IN PA_VC_1000_80     := PA_VC_1000_80(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_resource_list_member_id  IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 --Name of the period if available
 ,p_period_name              IN PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 --Start date of the period
 ,p_start_date               IN PA_date_1000_date := PA_date_1000_date(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 --End date of the period
 ,p_end_date                 IN PA_date_1000_date := PA_date_1000_date(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_txn_quantity             IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_txn_raw_cost             IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_txn_bur_cost             IN PA_num_1000_num   := PA_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_currency_code            IN PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,x_return_status                    OUT NOCOPY VARCHAR2
);

/*#
 * This API is used to create project task resources using the data stored in the global tables.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Execute Create Project Task Resources
 * @rep:compatibility S
*/
PROCEDURE Execute_Create_Task_Asgmts
( p_api_version_number        IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN  VARCHAR2     := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2     := FND_API.G_FALSE
-- Product Code is a required parameter
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Either project reference or project id is required
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Structure version id is required
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
 ,x_return_status                     OUT NOCOPY VARCHAR2
);

/*#
 * This API is used to update project task resources using the data stored in the global tables.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Execute Update Project Task Resources
 * @rep:compatibility S
*/
PROCEDURE Execute_Update_Task_Asgmts
( p_api_version_number        IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN  VARCHAR2     := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2     := FND_API.G_FALSE
 -- Product Code is a required parameter
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Either project reference or project id is required
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Structure version id is required
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
 ,x_return_status                     OUT NOCOPY VARCHAR2
);

/*#
 * This API is used to create project task resources using a table of task resource records.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * Oracle Projects
 * @param p_task_assignments_in Input table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignments_out Output table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Task Resources
 * @rep:compatibility S
*/
PROCEDURE Create_Task_Assignments
( p_api_version_number        IN   NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN   VARCHAR2      := FND_API.G_FALSE
 ,p_init_msg_list                 IN   VARCHAR2      := FND_API.G_FALSE
 -- Product Code is a required parameter
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Either project reference or project id is required
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Structure version id is required
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignments_in       IN   ASSIGNMENT_IN_TBL_TYPE
 ,p_task_assignments_out      OUT  NOCOPY ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count                     OUT  NOCOPY NUMBER
 ,x_msg_data                      OUT  NOCOPY VARCHAR2
 ,x_return_status                     OUT  NOCOPY VARCHAR2
);


/*#
 * This API is used to create project task resources and periodic data using a table of task resource records
 * and a table of periodic data.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @param p_task_assignments_in Input table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignments_out Output table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignment_periods_in Input table of task resource periodic data detail records
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignment_periods_out Output table of task resource periodic data detail records
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Task Resource and Periodic Data
 * @rep:compatibility S
*/
PROCEDURE Create_Task_Assignment_Periods
( p_api_version_number          IN   NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                  IN   VARCHAR2            := FND_API.G_FALSE
 ,p_init_msg_list                   IN   VARCHAR2            := FND_API.G_FALSE
-- Product Code is a required parameter
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Either project reference or project id is required
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Structure version id is required
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignments_in         IN   ASSIGNMENT_IN_TBL_TYPE
 ,p_task_assignment_periods_in  IN   PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_PERIODS_TBL_TYPE
 ,p_task_assignments_out        OUT  NOCOPY ASSIGNMENT_OUT_TBL_TYPE
 ,p_task_assignment_periods_out OUT  NOCOPY PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count                       OUT  NOCOPY NUMBER
 ,x_msg_data                        OUT  NOCOPY VARCHAR2
 ,x_return_status                       OUT  NOCOPY VARCHAR2
);

/*#
 * This API is used to update project task resources using a table of task resource records.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @param p_task_assignments_in Input table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignments_out Output table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Project Task Resources
 * @rep:compatibility S
*/
PROCEDURE Update_Task_Assignments
( p_api_version_number        IN  NUMBER           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN  VARCHAR2     := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2     := FND_API.G_FALSE
 -- Product Code is a required parameter
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Either project reference or project id is required
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Structure version id is required
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignments_in       IN  ASSIGNMENT_IN_TBL_TYPE
 ,p_task_assignments_out      OUT NOCOPY ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
 ,x_return_status                     OUT NOCOPY VARCHAR2
);

/*#
 * This API is used to delete project task resources using a table of task resource records.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @param p_task_assignments_in Input table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Project Task Resources
 * @rep:compatibility S
*/
PROCEDURE Delete_Task_Assignments
( p_api_version_number        IN  NUMBER           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                IN  VARCHAR2     := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2     := FND_API.G_FALSE
 --Either project reference or project id is required
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Structure version id is required
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Pass in list of task assignment id's or references as information at a minimum
 ,p_task_assignments_in       IN  ASSIGNMENT_IN_TBL_TYPE
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
 ,x_return_status                     OUT NOCOPY VARCHAR2
);

/*#
 * This API is used to update project task resources and periodic data using a table of task resource records
 * and a table of periodic data.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference Reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @param p_task_assignments_in Input table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignments_out Output table of task resource detail records
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignment_periods_in Input table of task resource periodic data detail records
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignment_periods_out Output table of task resource periodic data detail records
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Project Task Resource and Periodic Data
 * @rep:compatibility S
*/
PROCEDURE Update_Task_Assignment_Periods
( p_api_version_number          IN   NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                                  IN   VARCHAR2            := FND_API.G_FALSE
 ,p_init_msg_list                   IN   VARCHAR2            := FND_API.G_FALSE
 -- Product Code is a required parameter
 ,p_pm_product_code               IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Either project reference or project id is required
 ,p_pm_project_reference      IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Structure version id is required
 ,p_pa_structure_version_id   IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignments_in         IN   ASSIGNMENT_IN_TBL_TYPE
 ,p_task_assignment_periods_in  IN   PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_PERIODS_TBL_TYPE
 ,p_task_assignments_out        OUT  NOCOPY ASSIGNMENT_OUT_TBL_TYPE
 ,p_task_assignment_periods_out OUT  NOCOPY PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count                       OUT  NOCOPY NUMBER
 ,x_msg_data                        OUT  NOCOPY VARCHAR2
 ,x_return_status                       OUT  NOCOPY VARCHAR2
);

/*#
 * This API is used to fetch output parameters related to project task resources.
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @param p_task_asgmt_index Index of task resources to be retrieved
 * @param p_pm_task_asgmt_reference External task resource reference
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_assignment_id Identifier of the task resource in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_reference External task reference
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id Identifier of the task in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_resource_alias Alias of the planning resource
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_member_id Identifier of the planning resource
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Project Task Resources
 * @rep:compatibility S
*/
PROCEDURE Fetch_Task_Assignments
( p_api_version_number      IN    NUMBER           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list                   IN    VARCHAR2         := FND_API.G_FALSE
 ,p_task_asgmt_index        IN    pa_num_1000_num  := pa_num_1000_num(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pm_task_asgmt_reference     OUT       NOCOPY pa_vc_1000_30
 ,p_pa_task_assignment_id       OUT       NOCOPY pa_num_1000_num
 ,p_pm_task_reference       OUT   NOCOPY pa_vc_1000_30
 ,p_pa_task_id              OUT   NOCOPY pa_num_1000_num
 ,p_resource_alias          OUT   NOCOPY pa_vc_1000_80
 ,p_resource_list_member_id OUT   NOCOPY pa_num_1000_num
 ,x_return_status                   OUT   NOCOPY VARCHAR2
);

/*#
 * This API is used to convert project task resource reference of external system to a task resource identifier of
 * Oracle Projects.
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id Identifier of the project in the Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pa_structure_version_id Identifier of the structure version in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id Identifier of the task in the Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_elem_ver_id Identifier of the task version in the Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_asgmt_reference External task resource reference
 * @param p_pa_task_assignment_id Identifier of the task resource in Oracle Projects
 * @param p_resource_alias Alias of the planning resource
 * @param p_resource_list_member_id Identifier of the planning resource
 * @param p_add_error_msg_flag API standard Flag to add error messages
 * @param p_published_version_flag Published Version Flag
 * @param x_pa_task_assignment_id Identifier of the task resource in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard Return of the API success / failure / unexpected error
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Convert Project Task Resource Reference to Id
 * @rep:compatibility S
*/
PROCEDURE Convert_PM_TARef_To_ID
( p_pm_product_code               IN VARCHAR2
 ,p_pa_project_id             IN NUMBER
 ,p_pa_structure_version_id   IN NUMBER
 ,p_pa_task_id                IN NUMBER
 ,p_pa_task_elem_ver_id       IN NUMBER
 ,p_pm_task_asgmt_reference   IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_assignment_id     IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_resource_alias            IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id   IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 -- Bug 3937017 Added a new parameter p_add_error_msg_flag
 ,p_add_error_msg_flag        IN VARCHAR2     DEFAULT 'Y'
 -- Bug 3872176 Added a new parameter p_published_version_flag
 ,p_published_version_flag     IN VARCHAR2     DEFAULT 'N'
 ,x_pa_task_assignment_id     OUT  NOCOPY NUMBER
 ,x_return_status                     OUT  NOCOPY VARCHAR2
) ;


/*#
 * This API procedure is used to initialize the project task resources global tables prior to
 * Load-Execute-Fetch cycle.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initialize Project Task Resources
 * @rep:compatibility S
*/
PROCEDURE Init_Task_Assignments;


end PA_TASK_ASSIGNMENTS_PUB;

/
