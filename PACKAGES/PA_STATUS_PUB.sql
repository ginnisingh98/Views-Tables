--------------------------------------------------------
--  DDL for Package PA_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STATUS_PUB" AUTHID DEFINER AS
/* $Header: PAPMSTPS.pls 120.5.12000000.2 2009/02/18 10:59:23 bifernan ship $*/
/*#
 * This package contains PL/SQL APIs that enable external project
 * management systems to maintain progress information in Oracle Projects.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Status Pub
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
 */

-- ----------------------------------------------------------------------------------------
-- 	Standard Globals
-- ----------------------------------------------------------------------------------------

-- WHO Globals

   G_LAST_UPDATED_BY	NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_DATE        	DATE       	:= SYSDATE;
   G_CREATION_DATE           	DATE       	:= SYSDATE;
   G_CREATED_BY              	NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_LOGIN       	NUMBER(15) 	:= FND_GLOBAL.LOGIN_ID;

-- Local Package Globals

   G_PKG_NAME         CONSTANT  VARCHAR2(30) := ' PA_STATUS_PUB';
   G_API_VERSION_NUMBER 	CONSTANT	NUMBER 	:= 1.0;

    ROW_ALREADY_LOCKED	EXCEPTION;
    PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

/*
TYPE PA_TASK_PROGRESS_IN_REC_TYPE IS RECORD
(
TASK_ID			NUMBER	:= NULL,
TASK_NAME		VARCHAR2(20)	:= NULL,
TASK_NUMBER		VARCHAR2(25)	:= NULL,
PM_TASK_REFERENCE	VARCHAR2(150)	:= NULL,
PERCENT_COMPLETE	NUMBER	:= NULL,
DESCRIPTION		VARCHAR2(250)	:= NULL,
OBJECT_ID		NUMBER	:= NULL,
OBJECT_VERSION_ID	NUMBER	:= NULL,
OBJECT_TYPE		VARCHAR2(30)	:= NULL,
PROGRESS_STATUS_CODE	VARCHAR2(150)	:= NULL,
PROGRESS_COMMENT	VARCHAR2(4000)	:= NULL,
ACTUAL_START_DATE	Date	:= NULL,
ACTUAL_FINISH_DATE	Date	:= NULL,
ESTIMATED_START_DATE	Date	:= NULL,
ESTIMATED_FINISH_DATE	Date	:= NULL,
SCHEDULED_START_DATE	Date	:= NULL,
SCHEDULED_FINISH_DATE	Date	:= NULL,
TASK_STATUS		VARCHAR2(150)	:= NULL,
EST_REMAINING_EFFORT	NUMBER	:= NULL,
ACTUAL_WORK_QUANTITY	NUMBER	:= NULL
);
TYPE PA_TASK_PROGRESS_IN_TBL_TYPE IS TABLE OF PA_TASK_PROGRESS_IN_REC_TYPE
   INDEX BY BINARY_INTEGER;
*/

G_TASK_PROGRESS_in_tbl		PA_PROGRESS_PUB.PA_TASK_PROGRESS_LIST_TBL_TYPE;
--G_TASK_PROGRESS_in_tbl			PA_TASK_PROGRESS_IN_TBL_TYPE;
G_TASK_PROGRESS_tbl_count		NUMBER:=0;
G_PROJECT_ID				NUMBER:=0;
G_pm_project_reference			VARCHAR2(30);
G_PM_PRODUCT_CODE			VARCHAR2(30);
G_STRUCTURE_TYPE			VARCHAR2(30);
G_AS_OF_DATE				DATE;
G_bulk_load_flag			VARCHAR2(1) :='N';

 -- -----------------------------------------------------------------------------------------
--	Procedures
-- -----------------------------------------------------------------------------------------

/*#
 * This is a PL/SQL procedure that updates progress information in the
 * PA_PERCENT_COMPLETES table as of a given date for all levels of the work
 * breakdown structure.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @param p_pm_task_reference The reference code that uniquely identifies the task in the external system
 * @param p_as_of_date As of date
 * @rep:paraminfo {@rep:required}
 * @param p_percent_complete Percent complete
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The reference code that identifies the external product
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_description The progress overview or description
 * @rep:paraminfo {@rep:precision 250}
 * @param p_object_id The project element identifier of the workplan or financial plan structure, task, or deliverable.
 * Or the resource list member identifier of the assignment in Oracle Projects.
 * @rep:paraminfo {@rep:required}
 * @param p_object_version_id The element version identifier of the task or deliverable
 * @rep:paraminfo {@rep:required}
 * @param p_object_type  The object type (PA_STRUCTURES for project progress, PA_TASKS for task
 * progress, PA_ASSIGNMENTS for assignment progress, and PA_DELIVERABLES for deliverable progress)
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_progress_status_code Project status code
 * @rep:paraminfo {@rep:precision 150} {@rep:required}
 * @param p_progress_comment Progress comments
 * @rep:paraminfo {@rep:precision 4000} {@rep:required}
 * @param p_actual_start_date Actual start date
 * @param p_actual_finish_date Actual finish date
 * @param p_estimated_start_date Estimated start date
 * @param p_estimated_finish_date Estimated finish date
 * @param p_scheduled_start_date Scheduled start date
 * @param p_scheduled_finish_date Scheduled finish date
 * @param p_task_status The task status code or deliverable status code
 * @rep:paraminfo {@rep:precision 150} {@rep:required}
 * @param p_structure_type Type of structure, such as the workplan structure or financial plan structure
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_est_remaining_effort  The estimate-to-complete effort (applies to tasks and assignments)
 * @param p_actual_work_quantity Actual work quantity (applicable only to lowest tasks)
 * @param p_etc_cost  Estimate to complete cost (applies to task assignments)
 * @param P_PM_DELIVERABLE_REFERENCE  Deliverable reference (applies to deliverables)
 * @rep:paraminfo {@rep:precision 150}
 * @param P_PM_TASK_ASSGN_REFERENCE  Task assignment reference (applies to task assignments)
 * @rep:paraminfo {@rep:precision 150}
 * @param P_ACTUAL_COST_TO_DATE  The cumulative actual cost in transaction cost in
 * transaction currency (applies to task assignments)
 * @param P_ACTUAL_EFFORT_TO_DATE  The cumulative actual effort (applies to structures, tasks, and task assignments)
 * @param p_populate_pji_tables Flag indicating whether to populate PJI tables (default = Y)
 * @param p_rollup_entire_wbs This is an internal attribute
 * @param p_txn_currency_code  Transaction currency code
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Progress
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:category BUSINESS_ENTITY PA_TASK_RESOURCE
 * @rep:compatibility S
 */
PROCEDURE Update_Progress
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_as_of_date			IN	DATE
, p_percent_complete		IN     	NUMBER
, p_pm_product_code		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_description			IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_object_id                   IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_object_version_id           IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_object_type                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_progress_status_code        IN      VARCHAR2        := 'PROGRESS_STAT_ON_TRACK'
, p_progress_comment            IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_actual_start_date           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_actual_finish_date          IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_estimated_start_date        IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_estimated_finish_date       IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_scheduled_start_date        IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_scheduled_finish_date       IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_task_status                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_structure_type              IN      VARCHAR2        := 'FINANCIAL'
, p_est_remaining_effort        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_actual_work_quantity        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_etc_cost                    IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  /* FP M Task Progress 3420093*/
, p_PM_DELIVERABLE_REFERENCE	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 3606627
, p_PM_TASK_ASSGN_REFERENCE	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 3606627
, p_ACTUAL_COST_TO_DATE		IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  -- Bug 3606627
, p_ACTUAL_EFFORT_TO_DATE	IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  -- Bug 3606627
, p_populate_pji_tables         IN      VARCHAR2        := 'Y'  -- Bug 3606627
, p_rollup_entire_wbs         IN      VARCHAR2          := 'N'  -- Bug 3606627
, p_txn_currency_code           IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                                                        -- Fix for Bug # 3988457.
);


/*#
 * This API is a PL/SQL procedure that updates earned value
 * information in the PA_EARNED_VALUES table for lowest task resource combinations.
 * You can also use this procedure to update project-task rows.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 30}
 * @param p_task_id The reference code that uniquely identifies the task in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_reference The reference code that uniquely identifies the task in the external system
 * @rep:paraminfo {@rep:precision 30}
 * @param p_resource_list_member_id The identification code of the resource list member
 * @rep:paraminfo {@rep:required}
 * @param p_resource_alias The alias of the resource
 * @rep:paraminfo {@rep:precision 30}
 * @param p_resource_list_name The name of the resource list
 * @rep:paraminfo {@rep:precision 60}
 * @param p_as_of_date As of date
 * @rep:paraminfo {@rep:required}
 * @param p_bcws_current Budget cost of work performed
 * @param p_acwp_current Actual cost of work performed
 * @param p_bcwp_current Budget cost of work performed
 * @param p_bac_current  Budget cost at completion
 * @param p_bcws_itd Inception-to-date budget cost of work performed
 * @rep:paraminfo {@rep:required}
 * @param p_acwp_itd Inception-to-date actual cost of work performed
 * @rep:paraminfo {@rep:required}
 * @param p_bcwp_itd Inception-to-date budget cost of work performed
 * @rep:paraminfo {@rep:required}
 * @param p_bac_itd Inception-to-date budget cost at completion
 * @rep:paraminfo {@rep:required}
 * @param p_bqws_current Budget quantity of work performed
 * @param p_aqwp_current Actual quantity of work performed
 * @param p_bqwp_current Budget quantity of work performed
 * @param p_baq_current Budget quantity at completion
 * @param p_bqws_itd Inception-to-date budget quantity of work performed
 * @rep:paraminfo {@rep:required}
 * @param p_aqwp_itd Inception-to-date actual quantity of work performed
 * @rep:paraminfo {@rep:required}
 * @param p_bqwp_itd Inception-to-date budget quantity of work performed
 * @rep:paraminfo {@rep:required}
 * @param p_baq_itd Inception-to-date budget quantity at completion
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Earned Value
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:category BUSINESS_ENTITY PA_TASK_RESOURCE
 * @rep:compatibility S
 */
PROCEDURE Update_Earned_Value
(p_api_version_number		IN	NUMBER
, p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_resource_list_member_id	IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_resource_alias		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_resource_list_name		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_as_of_date			IN	DATE
, p_bcws_current			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_acwp_current			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bcwp_current			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bac_current			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bcws_itd			IN	NUMBER
, p_acwp_itd			IN	NUMBER
, p_bcwp_itd			IN	NUMBER
, p_bac_itd			IN	NUMBER
, p_bqws_current			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_aqwp_current			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bqwp_current			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_baq_current			IN	NUMBER	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bqws_itd			IN	NUMBER
, p_aqwp_itd			IN	NUMBER
, p_bqwp_itd			IN	NUMBER
, p_baq_itd			IN	NUMBER);

/*#
 * This API is used to initialize internal PL/SQL tables.
 * It is recommended to call this API before every call to the
 * EXECUTE_UPDATE_TASK_PROGRESS API.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initialize Update Task Progress
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE Init_Update_Task_Progress
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



/*#
* This API is a Load-Execute-Fetch PL/SQL procedure used to load
* progress information in the PL/SQL data structures.
* @param p_api_version_number API standard: version number
* @rep:paraminfo {@rep:required}
* @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
* @rep:paraminfo {@rep:precision 1}
* @param p_commit API standard (default = F): indicates if the transaction will be committed
* @rep:paraminfo {@rep:precision 1}
* @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
* @rep:paraminfo {@rep:required}
* @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
* @rep:paraminfo {@rep:precision 30}
* @param P_PM_PRODUCT_CODE The reference code that identifies the external product
* @rep:paraminfo {@rep:precision 30} {@rep:required}
* @param P_STRUCTURE_TYPE  tThe type of structure, such as the workplan structure or financial plan structure
* @rep:paraminfo {@rep:precision 30} {@rep:required}
* @param P_AS_OF_DATE As of date
* @rep:paraminfo {@rep:required}
* @param P_TASK_ID The reference code that uniquely identifies the task in a project in Oracle Projects
* @param P_TASK_NAME Task name
* @rep:paraminfo {@rep:precision 20}
* @param P_TASK_NUMBER Task number
* @rep:paraminfo {@rep:precision 25}
* @param P_PM_TASK_REFERENCE The reference code that uniquely identifies the task in the external system
* @rep:paraminfo {@rep:precision 30}
* @param P_PERCENT_COMPLETE Percent complete
* @rep:paraminfo {@rep:required}
* @param P_DESCRIPTION The progress overview or description
* @rep:paraminfo {@rep:precision 250}
* @param P_OBJECT_ID The project element identifier of the structure, task, or deliverable. Or the
* resource list member identifier of the assignment in Oracle Projects.
* @rep:paraminfo {@rep:required}
* @param P_OBJECT_VERSION_ID The element version identifier of the task or deliverable
* @rep:paraminfo {@rep:required}
* @param P_OBJECT_TYPE The object type (PA_STRUCTURES for project progress, PA_TASKS for task progress,
* PA_ASSIGNMENTS for assignment progress, and PA_DELIVERABLES for deliverable progress)
* @rep:paraminfo {@rep:precision 30} {@rep:required}
* @param P_PROGRESS_STATUS_CODE Project status code
* @rep:paraminfo {@rep:precision 150} {@rep:required}
* @param P_PROGRESS_COMMENT Progress comments
* @rep:paraminfo {@rep:precision 4000}
* @param P_ACTUAL_START_DATE Actual start date
* @param P_ACTUAL_FINISH_DATE Actual finish date
* @param P_ESTIMATED_START_DATE Estimated start date
* @param P_ESTIMATED_FINISH_DATE Estimated finish date
* @param P_SCHEDULED_START_DATE Scheduled start date
* @param P_SCHEDULED_FINISH_DATE Scheduled finish date
* @param P_TASK_STATUS The task status code or deliverable status code
* @rep:paraminfo {@rep:precision 150} {@rep:required}
* @param P_EST_REMAINING_EFFORT The estimate-to-complete effort (applicable to  tasks and assignments)
* @param P_ACTUAL_WORK_QUANTITY The actual work quantity (applicable only for lowest tasks)
* @param P_ETC_COST The estimate-to-complete cost (applicable to task assignments)
* @param P_PM_DELIVERABLE_REFERENCE The deliverable reference (applicable to deliverables)
* @rep:paraminfo {@rep:precision 150}
* @param P_PM_TASK_ASSGN_REFERENCE  The task assignment reference (applicable to task assignments)
* @rep:paraminfo {@rep:precision 150}
* @param P_ACTUAL_COST_TO_DATE The cumulative actual cost in the transaction currency (applicable to task assignments)
* @param p_ACTUAL_EFFORT_TO_DATE The cumulative actual effort (applicable to workplan or financial plan structures, tasks, and task assignments)
* @param p_return_status API standard: return status of the API (success/failure/unexpected error)
* @rep:paraminfo {@rep:precision 1}
* @param p_msg_count API standard: number of error messages
* @param p_msg_data API standard: error message
* @rep:paraminfo {@rep:precision 2000}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Load Task Progress
* @rep:category BUSINESS_ENTITY PA_PROJECT
* @rep:category BUSINESS_ENTITY PA_TASK
* @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
* @rep:category BUSINESS_ENTITY PA_TASK_RESOURCE
* @rep:compatibility S
*/
PROCEDURE Load_Task_Progress
(p_api_version_number		IN	NUMBER
,p_init_msg_list		IN	VARCHAR2		:= FND_API.G_FALSE
,p_commit			IN	VARCHAR2		:= FND_API.G_FALSE
,p_project_id			IN	NUMBER			:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_pm_project_reference		IN	VARCHAR2		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_PM_PRODUCT_CODE		IN	VARCHAR2		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_STRUCTURE_TYPE		IN	VARCHAR2		:= 'FINANCIAL'
,P_AS_OF_DATE			IN	DATE
,P_TASK_ID			IN	PA_NUM_1000_NUM		:= PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,P_TASK_NAME			IN	PA_VC_1000_240		:= PA_VC_1000_240(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,P_TASK_NUMBER			IN	PA_VC_1000_150		:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,P_PM_TASK_REFERENCE		IN	PA_VC_1000_150		:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,P_PERCENT_COMPLETE		IN	PA_NUM_1000_NUM
,P_DESCRIPTION			IN	PA_VC_1000_2000		:= PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,P_OBJECT_ID			IN	PA_NUM_1000_NUM		:= PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,P_OBJECT_VERSION_ID		IN	PA_NUM_1000_NUM		:= PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,P_OBJECT_TYPE			IN	PA_VC_1000_150		:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,P_PROGRESS_STATUS_CODE		IN	PA_VC_1000_150		:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,P_PROGRESS_COMMENT		IN	PA_VC_1000_4000		:= PA_VC_1000_4000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,P_ACTUAL_START_DATE		IN	PA_DATE_1000_DATE	:= PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,P_ACTUAL_FINISH_DATE		IN	PA_DATE_1000_DATE	:= PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,P_ESTIMATED_START_DATE		IN	PA_DATE_1000_DATE	:= PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,P_ESTIMATED_FINISH_DATE	IN	PA_DATE_1000_DATE	:= PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,P_SCHEDULED_START_DATE		IN	PA_DATE_1000_DATE	:= PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,P_SCHEDULED_FINISH_DATE	IN	PA_DATE_1000_DATE	:= PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,P_TASK_STATUS			IN	PA_VC_1000_150		:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,P_EST_REMAINING_EFFORT		IN	PA_NUM_1000_NUM		:= PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,P_ACTUAL_WORK_QUANTITY		IN	PA_NUM_1000_NUM		:= PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,p_etc_cost                     IN      PA_NUM_1000_NUM		:= PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) /* FP M Task Progress 3420093*/
,p_PM_DELIVERABLE_REFERENCE	IN	PA_VC_1000_150		:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) -- Bug 3606627
,p_PM_TASK_ASSGN_REFERENCE 	IN	PA_VC_1000_150		:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) -- Bug 3606627
,p_ACTUAL_COST_TO_DATE		IN	PA_NUM_1000_NUM		:= PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) -- Bug 3606627
,p_ACTUAL_EFFORT_TO_DATE	IN	PA_NUM_1000_NUM		:= PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) -- Bug 3606627
,p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/*#
 * This API is a Load-Execute-Fetch PL/SQL procedure
 * used to update progress information in Oracle Projects.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Execute Update Task Progress
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:category BUSINESS_ENTITY PA_TASK_RESOURCE
 * @rep:compatibility S
 */
PROCEDURE Execute_Update_Task_Progress
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


/*#
 * This API is used to perform project level validations by validating various privileges.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_project_id_out Project identifier returned from the API
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Perform Project Level Validations
 * @rep:compatibility S
 */
PROCEDURE Project_Level_Validations
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_project_id_out		OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
);

/* Progress Management Changes. Bug # 3420093. */

PROCEDURE update_task_progress_amg
( p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_progress_mode               IN      VARCHAR2        := 'FUTURE'
 ,p_project_id                  IN      NUMBER
 ,p_structure_version_id        IN      NUMBER
 ,p_structure_type              IN      VARCHAR2
 ,p_as_of_date                  IN      DATE
 ,p_task_progress_list_table    IN      PA_PROGRESS_PUB.PA_TASK_PROGRESS_LIST_TBL_TYPE
 ,x_return_status               OUT NOCOPY      VARCHAR2
 ,x_msg_count                   OUT NOCOPY      NUMBER
 ,x_msg_data                    OUT NOCOPY      VARCHAR2
);

/* Progress Management Changes. Bug # 3420093. */

END pa_status_pub;

 

/
