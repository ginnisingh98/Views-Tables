--------------------------------------------------------
--  DDL for Package GMS_BUDGET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BUDGET_PUB" AUTHID CURRENT_USER as
/*$Header: gmsmbups.pls 120.12 2006/07/29 12:51:44 smaroju ship $*/
/*#
 * This API provides a set of procedures to create, modify, delete, and submit a draft award budget
 * and to designate a draft award budget as the baseline budget.
 * @rep:scope public
 * @rep:product GMS
 * @rep:lifecycle active
 * @rep:displayname Budget API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMS_AWARD
 * @rep:doccd 120gmsug.pdf See the Oracle Oracle Grants Accounting User's Guide
*/
-- Global constants to be used by GMS AMG procedures
G_MISS_NUM   CONSTANT   NUMBER := 1.7E20;
G_MISS_DATE  CONSTANT   DATE   := TO_DATE('01/01/4712','DD/MM/YYYY');
G_MISS_CHAR  CONSTANT   VARCHAR2(3) := '^';
G_FALSE	     CONSTANT	VARCHAR2(1) := 'F';
G_TRUE	     CONSTANT	VARCHAR2(1) := 'T';

--Global constants to be used in error messages
G_PKG_NAME  		CONSTANT VARCHAR2(30) := 'GMS_BUDGET_PUB';
G_BUDGET_CODE		CONSTANT VARCHAR2(6)  := 'BUDGET';
G_PROJECT_CODE		CONSTANT VARCHAR2(7)  := 'PROJECT';
G_TASK_CODE		CONSTANT VARCHAR2(4)  := 'TASK';
G_RESOURCE_CODE		CONSTANT VARCHAR2(8)  := 'RESOURCE';
G_AWARD_CODE		CONSTANT VARCHAR2(5)  := 'AWARD';

--Locking exception
ROW_ALREADY_LOCKED	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

--Package constant used for package version validation

G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;

-- Added since Forms cannot call a global variable directly

FUNCTION G_PA_MISS_NUM RETURN NUMBER;
FUNCTION G_PA_MISS_CHAR RETURN VARCHAR2;
FUNCTION G_PA_MISS_DATE RETURN DATE;

FUNCTION G_GMS_TRUE RETURN VARCHAR2;
FUNCTION G_GMS_FALSE RETURN VARCHAR2;

/*
TYPE calc_budget_line_out_rec_type IS RECORD
(pa_task_id		   NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
,pm_task_reference	   VARCHAR2(30)	        := GMS_BUDGET_PUB.G_PA_MISS_CHAR
,resource_alias		   VARCHAR2(30)	        := GMS_BUDGET_PUB.G_PA_MISS_CHAR
,resource_list_member_id   NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
,budget_start_date	   DATE		        := GMS_BUDGET_PUB.G_PA_MISS_DATE
,budget_end_date	   DATE		        := GMS_BUDGET_PUB.G_PA_MISS_DATE
,period_name		   VARCHAR2(30)	        := GMS_BUDGET_PUB.G_PA_MISS_CHAR
,calculated_raw_cost       NUMBER               := GMS_BUDGET_PUB.G_PA_MISS_NUM
,calculated_burdened_cost  NUMBER               := GMS_BUDGET_PUB.G_PA_MISS_NUM
,quantity		   NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
,return_status		   VARCHAR2(1)	        := GMS_BUDGET_PUB.G_PA_MISS_CHAR
);

TYPE calc_budget_line_out_tbl_type IS TABLE OF calc_budget_line_out_rec_type
	INDEX BY BINARY_INTEGER;

--Counters
G_budget_lines_tbl_count	NUMBER:=0;
G_calc_budget_lines_tbl_count	NUMBER:=0;
*/
/*#
 * This procedure creates a draft project budget from baseline award budgets.
 * @param x_budget_version_id The reference code that uniquely identifies the budget version
 * @rep:paraminfo  {@rep:required}
 * @param x_err_code The reference code which identifies the SQL error code returned by the API
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The reference code which identifies the stage where error has occurred
 * @rep:paraminfo  {@rep:required}
 * @param x_err_stack The reference code which identifies the error message returned by the API
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Summarize Project Totals
 * @rep:compatibility S
*/
PROCEDURE summerize_project_totals
(x_budget_version_id   		IN     NUMBER,
 x_err_code            		IN OUT NOCOPY NUMBER,
 x_err_stage	    		IN OUT NOCOPY VARCHAR2,
 x_err_stack           		IN OUT NOCOPY VARCHAR2);
/*#
 * This procedure creates a draft budget version for an award and project.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The reference code which identifies the SQL error code returned by the API
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The reference code which identifies the stage where error has occurred
 * @rep:paraminfo  {@rep:required}
 * @param x_err_stack The reference code which identifies the error message returned by the API
 * @rep:paraminfo  {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_product_code Identifier of the external systems from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_budget_reference Identifier of the external systems from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_budget_version_name The reference code that identifies versionnumber of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_project_number Identifier of the project number
 * @rep:paraminfo  {@rep:required}
 * @param p_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param p_award_number Identifier of the award number
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_type_code The reference code that identifies budget type code "AC" for approved cost budget
 * @rep:paraminfo  {@rep:required}
 * @param p_change_reason_code Identifier of the change reason for the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_description  Description of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_entry_method_code The reference code that identifies budget entry method
 * @rep:paraminfo  {@rep:required}
 * @param p_resource_list_name The reference code that identifies resource list name of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_resource_list_id The reference code that identifies resource list id of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute11 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute12 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute13 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute14 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute15 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_first_budget_period The reference code that identifies the first budget period
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Draft Budget
 * @rep:compatibility S
*/
PROCEDURE create_draft_budget
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_version_name         IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_description			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_entry_method_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_name		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute1			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute2			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute3			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute4			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute5			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute6			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute7			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute8			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute9			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute10			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute11			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute12			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute13			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute14			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute15			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_first_budget_period         IN      VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR -- Bug 3104308
);
/*#
 * This procedure submits the budget baseline concurrent process, which calls the BASELINE_BUDGET procedure.
 * @param p_reqid  Request id
 * @rep:paraminfo  {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param p_mark_as_original The reference code which will mark the budget version as original.Y for yes
 * N for No
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Submit Budget
 * @rep:compatibility S
*/
PROCEDURE submit_budg_conc_process
( p_reqid			OUT NOCOPY	NUMBER,
  p_project_id			IN	NUMBER,
  p_award_id			IN	NUMBER,
  p_mark_as_original		IN	VARCHAR
);
/*#
 * This procedure submits an award budget or sets an award budget as the baseline budget.
 * @param ERRBUFF  Error message returned if any
 * @rep:paraminfo  {@rep:required}
 * @param RETCODE Return Code; S for Success, E for Error
 * @rep:paraminfo  {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_award_number Identifier of the award number
 * @rep:paraminfo  {@rep:required}
 * @param p_mark_as_original The reference code which will mark the budget version as original. The values are Y for yes
 * N for No
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Submit Or Baseline Budget
 * @rep:compatibility S
*/
PROCEDURE submit_baseline_budget
( ERRBUFF			IN OUT NOCOPY	VARCHAR2
 ,RETCODE			IN OUT NOCOPY  VARCHAR2
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN      VARCHAR2 /* bug 3651888			:= GMS_BUDGET_PUB.G_PA_MISS_NUM*/
 ,p_mark_as_original		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
);
/*#
 * This procedure sets a draft budget as the baseline budget.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The reference code which identifies the SQL error code returned by the API
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The reference code which identifies the stage where error has occurred
 * @rep:paraminfo  {@rep:required}
 * @param x_err_stack The reference code which identifies the error message returned by the API
 * @rep:paraminfo  {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_product_code Identifier of the external systems from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_workflow_started Indicates whether workflow has been started to baseline the budget; Y
 * for yes, N for no
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_project_number Identifier of the project number
 * @rep:paraminfo  {@rep:required}
 * @param p_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param p_award_number Identifier of the award number
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_type_code The reference code that identifies budget type code "AC" for approved cost budget
 * @rep:paraminfo  {@rep:required}
 * @param p_mark_as_original The reference code which will mark the budget version as original.The values are Y for yes
 * N for No
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Baseline Budget
 * @rep:compatibility S
*/
PROCEDURE baseline_budget
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_workflow_started		OUT NOCOPY	VARCHAR2
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_mark_as_original		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR	);

/*#
* This procedure adds a line to a draft or working budget.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The reference code which identifies the SQL error code returned by the API
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The reference code which identifies the stage where error has occurred
 * @rep:paraminfo  {@rep:required}
 * @param x_err_stack The reference code which identifies the error message returned by the API
 * @rep:paraminfo  {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_product_code Identifier of the external systems from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_project_number Identifier of the project number
 * @rep:paraminfo  {@rep:required}
 * @param p_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param p_award_number Identifier of the award number
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_type_code The reference code that identifies budget type code; "AC" for approved cost budget
 * @rep:paraminfo  {@rep:required}
 * @param p_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_task_number Identifier of the task number
 * @rep:paraminfo  {@rep:required}
 * @param p_resource_alias The reference code that identifies the budget resource
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_member_id The reference code that identifies the resource list member
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_start_date The reference code that identifies the budget start date
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_end_date The reference code that identifies the budget end date
 * @rep:paraminfo  {@rep:required}
 * @param p_period_name The reference code that identifies the period of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_description  Description of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_change_reason_code Identifier of the change reason for the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_raw_cost Identifier of the raw cost
 * @rep:paraminfo  {@rep:required}
 * @param p_burdened_cost Identifier of the burdened cost
 * @rep:paraminfo  {@rep:required}
 * @param p_quantity Identifier of the quantity
 * @rep:paraminfo  {@rep:required}
 * @param p_unit_of_measure Identifier of the unit of measure
 * @rep:paraminfo  {@rep:required}
 * @param p_track_as_labor_flag The reference code that identifies if the  is labor
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_budget_line_reference The reference code that identifies if external budget line reference
 * @rep:paraminfo  {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute11 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute12 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute13 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute14 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute15 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_raw_cost_source The reference code that identifies the raw cost source
 * @rep:paraminfo  {@rep:required}
 * @param p_burdened_cost_source The reference code that identifies the burdenend cost source
 * @rep:paraminfo  {@rep:required}
 * @param p_quantity_source The reference code that identifies the quantity
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Budget Line
 * @rep:compatibility S
*/
PROCEDURE add_budget_line
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_task_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_task_number			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_alias		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id	IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_budget_start_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_budget_end_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_period_name			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_description			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_burdened_cost		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_quantity			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_unit_of_measure		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_track_as_labor_flag		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_line_reference	IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute_category		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute1			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute2			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute3			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute4			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute5			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute6			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute7			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute8			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute9			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute10			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute11			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute12			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute13			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute14			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute15			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost_source		IN 	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_source	IN 	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_quantity_source		IN 	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
);
/*#
 * This procedure deletes a draft budget.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The reference code which identifies the SQL error code returned by the API
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The reference code which identifies the stage where error has occurred
 * @rep:paraminfo  {@rep:required}
 * @param x_err_stack The reference code which identifies the error message returned by the API
 * @rep:paraminfo  {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_product_code Identifier of the external systems from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_project_number Identifier of the project number
 * @rep:paraminfo  {@rep:required}
 * @param p_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param p_award_number Identifier of the award number
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_type_code The reference code that identifies budget type code; "AC" for approved cost budget
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Draft Budget
 * @rep:compatibility S
*/
 PROCEDURE delete_draft_budget
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR	);
/*#
 * This procedure deletes a budget line of a draft budget.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The reference code which identifies the SQL error code returned by the API
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The reference code which identifies the stage where error has occurred
 * @rep:paraminfo  {@rep:required}
 * @param x_err_stack The reference code which identifies the error message returned by the API
 * @rep:paraminfo  {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_product_code Identifier of the external systems from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_project_number Identifier of the project number
 * @rep:paraminfo  {@rep:required}
 * @param p_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param p_award_number Identifier of the award number
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_type_code The reference code that identifies budget type code; "AC" for approved cost budget
 * @rep:paraminfo  {@rep:required}
 * @param p_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_task_number Identifier of the task number
 * @rep:paraminfo  {@rep:required}
 * @param p_resource_alias The reference code that identifies the budget resource
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_member_id The reference code that identifies the resource list member
 * @rep:paraminfo  {@rep:required}
 * @param p_start_date The reference code that identifies the budget start date
 * @rep:paraminfo  {@rep:required}
 * @param p_period_name The reference code that identifies the period of the budget
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Budget Line
 * @rep:compatibility S
*/
PROCEDURE delete_budget_line
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_task_id			IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_task_number			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_alias		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id	IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_start_date			IN	DATE		:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_period_name			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR	);
/*#
 * This procedure updates the attributes of a budget version.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The reference code which identifies the SQL error code returned by the API
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The reference code which identifies the stage where error has occurred
 * @rep:paraminfo  {@rep:required}
 * @param x_err_stack The reference code which identifies the error message returned by the API
 * @rep:paraminfo  {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_product_code Identifier of the external systems from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_project_number Identifier of the project number
 * @rep:paraminfo  {@rep:required}
 * @param p_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param p_award_number Identifier of the award number
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_type_code The reference code that identifies budget type code; "AC" for approved cost budget
 * @rep:paraminfo  {@rep:required}
 * @param p_change_reason_code Identifier of the change reason for the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_description  Description of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_status_code The reference code that identifies budget status
 * @rep:paraminfo  {@rep:required}
 * @param p_version_number The reference code that identifies versionnumber of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_current_flag The reference code that identifies whether the budget version is the
 * current baselined budget; yes or no
 * @rep:paraminfo  {@rep:required}
 * @param p_original_flag The reference code that identifies whether the budget version was
 * an original budget at any time; yes or no
 * @rep:paraminfo  {@rep:required}
 * @param p_current_original_flag The reference code that identifies whether the budget version is the
 * current original budget; yes or no
 * @rep:paraminfo  {@rep:required}
 * @param p_resource_accumulated_flag The reference code that identifies versionnumber of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_resource_list_id The reference code that identifies resource list id of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_version_name The reference code that identifies versionnumber of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_entry_method_code The reference code that identifies budget entry method
 * @rep:paraminfo  {@rep:required}
 * @param p_baselined_by_person_id The reference code that identifies the person who has done the baseline
 * @rep:paraminfo  {@rep:required}
 * @param p_baselined_date The reference code that identifies date on which budget has been baselined
 * @rep:paraminfo  {@rep:required}
 * @param p_quantity Identifier of the quantity
 * @rep:paraminfo  {@rep:required}
 * @param p_unit_of_measure Identifier of the unit of measure
 * @rep:paraminfo  {@rep:required}
 * @param p_raw_cost Identifier of the raw cost
 * @rep:paraminfo  {@rep:required}
 * @param p_burdened_cost Identifier of the burdened cost
 * @rep:paraminfo  {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute11 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute12 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute13 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute14 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute15 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_first_budget_period The reference code that identifies the first budget period
 * @rep:paraminfo {@rep:required}
 * @param p_wf_status_code  The reference code that identifies the workflow status for the budget
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Budget
 * @rep:compatibility S
*/
PROCEDURE update_budget
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_description			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_status_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_version_number		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_current_flag		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_original_flag		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_current_original_flag	IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_accumulated_flag	IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_version_name		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_entry_method_code	IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_baselined_by_person_id	IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_baselined_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_quantity			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_unit_of_measure		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_burdened_cost		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute1			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute2			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute3			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute4			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute5			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute6			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute7			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute8			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute9			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute10			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute11			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute12			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute13			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute14			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute15			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_first_budget_period		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_wf_status_code 		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR);
/*#
* This procedure updates a budget line of draft budget.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The reference code which identifies the SQL error code returned by the API
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The reference code which identifies the stage where error has occurred
 * @rep:paraminfo  {@rep:required}
 * @param x_err_stack The reference code which identifies the error message returned by the API
 * @rep:paraminfo  {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_product_code Identifier of the external systems from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_project_number Identifier of the project number
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_type_code The reference code that identifies budget type code; "AC" for approved cost budget
 * @rep:paraminfo  {@rep:required}
 * @param p_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_task_number Identifier of the task number
 * @rep:paraminfo  {@rep:required}
 * @param p_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param p_award_number Identifier of the award number
 * @rep:paraminfo  {@rep:required}
 * @param p_resource_alias The reference code that identifies the budget resource
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_member_id The reference code that identifies the resource list member
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_start_date The reference code that identifies the budget start date
 * @rep:paraminfo  {@rep:required}
 * @param p_budget_end_date The reference code that identifies the budget end date
 * @rep:paraminfo  {@rep:required}
 * @param p_period_name The reference code that identifies the period of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_description  Description of the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_change_reason_code Identifier of the change reason for the budget
 * @rep:paraminfo  {@rep:required}
 * @param p_raw_cost Identifier of the raw cost
 * @rep:paraminfo  {@rep:required}
 * @param p_burdened_cost Identifier of the burdened cost
 * @rep:paraminfo  {@rep:required}
 * @param p_quantity Identifier of the quantity
 * @rep:paraminfo  {@rep:required}
 * @param p_unit_of_measure Identifier of the unit of measure
 * @rep:paraminfo  {@rep:required}
 * @param p_track_as_labor_flag The reference code that identifies if the  is labor
 * @rep:paraminfo  {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute11 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute12 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute13 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute14 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute15 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_raw_cost_source The reference code that identifies the raw cost source
 * @rep:paraminfo  {@rep:required}
 * @param p_burdened_cost_source The reference code that identifies the burdenend cost source
 * @rep:paraminfo  {@rep:required}
 * @param p_quantity_source The reference code that identifies the quantity
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Budget Line
 * @rep:compatibility S
*/
PROCEDURE update_budget_line
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_task_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_task_number			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_alias		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id	IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_budget_start_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_budget_end_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_period_name			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_description			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_burdened_cost		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_quantity			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_unit_of_measure		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_track_as_labor_flag		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute_category		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute1			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute2			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute3			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute4			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute5			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute6			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute7			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute8			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute9			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute10			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute11			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute12			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute13			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute14			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute15			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost_source		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_source	IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_quantity_source		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR	  );

/*#
 * This procedure validates the award budget.
 * @param x_budget_version_id The reference code that uniquely identifies the budget version
 * @rep:paraminfo  {@rep:required}
 * @param x_project_id The reference code that uniquely identifies the project
 * @rep:paraminfo  {@rep:required}
 * @param x_task_id The reference code that uniquely identifies the task within a project
 * @rep:paraminfo  {@rep:required}
 * @param x_award_id The reference code that uniquely identifies the award in Oracle Grants Accounting
 * @rep:paraminfo  {@rep:required}
 * @param x_resource_list_member_id The reference code that identifies the resource list member
 * @rep:paraminfo  {@rep:required}
 * @param x_start_date The reference code that identifies the budget start date
 * @rep:paraminfo  {@rep:required}
 * @param x_end_date The reference code that identifies the budget end date
 * @rep:paraminfo  {@rep:required}
 * @param x_return_status The return status which indicates whether budget is valid or not
 * @rep:paraminfo  {@rep:required}
 * @param x_calling_form The reference code which identifies from where this procedure is
 * called
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Budget
 * @rep:compatibility S
*/
PROCEDURE validate_budget(  x_budget_version_id in NUMBER,
			    x_award_id in NUMBER,
                            x_project_id in NUMBER,
                            x_task_id in NUMBER default NULL,
                            x_resource_list_member_id in NUMBER default NULL,
                            x_start_date in DATE,
                            x_end_date in DATE,
                            x_return_status in out NOCOPY NUMBER,
			    x_calling_form IN VARCHAR2 default NULL);  /* For Bug 4965360 */

/*
PROCEDURE Calculate_Amounts
( p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2   := GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2   := GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_msg_count			OUT NOCOPY	NUMBER
 ,p_msg_data			OUT NOCOPY	VARCHAR2
 ,p_return_status		OUT NOCOPY	VARCHAR2
 ,p_pm_product_code		IN	VARCHAR2   := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id		IN	NUMBER	   := GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_id			IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference	IN	VARCHAR2   := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2   := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_calc_raw_cost_yn            IN      VARCHAR2   := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_calc_burdened_cost_yn       IN      VARCHAR2   := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_update_db_flag              IN      VARCHAR2   := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_calc_budget_lines_out      OUT NOCOPY	calc_budget_line_out_tbl_type );

*/
end GMS_BUDGET_PUB;

 

/
