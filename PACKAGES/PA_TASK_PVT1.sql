--------------------------------------------------------
--  DDL for Package PA_TASK_PVT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_PVT1" AUTHID CURRENT_USER AS
/* $Header: PATSK1VS.pls 120.1.12010000.2 2009/07/21 14:31:52 anuragar ship $ */

-- API name                      : Create_Task
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	      IN	NUMBER	N	Not Null	1.0
-- p_init_msg_list	IN	VARCHAR2	N	Not Null	FND_API.TRUE
-- p_commit	            IN	VARCHAR2	N	Not Null	FND_API.G_FALSE
-- p_validate_only	IN	VARCHAR2	N	Not Null	FND_API.G_TRUE
-- p_validation_level	IN	NUMBER	N	Null	FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	IN	VARCHAR2	N	Null	SELF_SERVICE
-- p_debug_mode	      IN	VARCHAR2	N	Null	N
-- p_max_msg_count	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_object_type	      IN	VARCHAR2	N	Not Null
-- p_project_id	      IN	NUMBER	N	Not Null
-- p_task_number	      IN	VARCHAR2	N	Not Null
-- p_task_name	      IN	VARCHAR2	N	Not Null
-- p_task_description	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_location_id	      IN	NUMBER	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_country	      IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_territory_code	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_state_region  	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_city	            IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_task_manager_id	IN	NUMBER	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_carrying_out_org_id	IN	NUMBER	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_priority_code	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_TYPE_ID  	      IN	NUMBER	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_status_code	      IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_inc_proj_progress_flag	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_product_code	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_task_reference	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_closed_date	      IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- x_task_id	      OUT	NUMBER	N	Not Null
-- x_return_status	OUT 	VARCHAR2	N	Null
-- x_msg_count	      OUT 	NUMBER	N	Null
-- x_msg_data	      OUT 	VARCHAR2	N	Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--
G_CHG_DOC_CNTXT NUMBER := 0; --Changes for 8566495 anuragag

PROCEDURE Create_Task(
 p_api_version	      IN	NUMBER	:=1.0,
 p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE',
 p_debug_mode	      IN	VARCHAR2	:='N',
 p_max_msg_count	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_object_type	      IN	VARCHAR2,
 p_project_id	      IN	NUMBER,
 p_structure_id         IN    NUMBER,
 p_structure_version_id IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_number	      IN	VARCHAR2,
 p_task_name	      IN	VARCHAR2,
 p_ref_task_id          IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_peer_or_sub          IN    VARCHAR2    :='PEER',
 p_task_description	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_location_id	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_country	            IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_territory_code	      IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_state_region  	      IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_city	            IN	VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_manager_id	IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_carrying_out_org_id	IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_priority_code	      IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_TYPE_ID  	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_status_code	      IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_inc_proj_progress_flag	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_product_code	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_task_reference	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_closed_date	      IN	DATE	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_start_date IN    DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_finish_date IN   DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_link_task_flag        IN   VARCHAR2 := 'N',
 p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_address_id    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_address1      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_type_id  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_service_type_code IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_chargeable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_billable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_receive_project_invoice_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_task_weighting_deriv_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_item_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_uom_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wq_actual_entry_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_progress_entry_page_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_progress_entry_page IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_phase_version_id        IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_phase_code              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_parent_structure_id      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 -- xxlu added task DFF attributes
 p_tk_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- end xxlu changes
 --FP M development bug 330119
  p_structure_type        IN      VARCHAR2 := 'WORKPLAN',
  p_financial_flag        IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --End FPM changes bug 330119
 p_Base_Perc_Comp_Deriv_Code    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    -- This param added for FP_M changes 3305199
-- Bug#3491609 : Workflow Chanegs FP M
 p_wf_item_type          IN    pa_proj_elements.wf_item_type%TYPE       :=NULL,
 p_wf_process            IN    pa_proj_elements.wf_process%TYPE         :=NULL,
 p_wf_lead_days          IN    pa_proj_elements.wf_start_lead_days%TYPE :=NULL,
 p_wf_enabled_flag       IN    pa_proj_elements.enable_wf_flag%TYPE     :=NULL,
 -- Bug#3491609 : Workflow Chanegs FP M
 x_task_id	            IN OUT	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_return_status	      OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count	      OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data	            OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
);

-- API name                      : Update_Task
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	      IN	NUMBER	N	Not Null	1.0
-- p_init_msg_list	IN	VARCHAR2	N	Not Null	FND_API.TRUE
-- p_commit	            IN	VARCHAR2	N	Not Null	FND_API.G_FALSE
-- p_validate_only	IN	VARCHAR2	N	Not Null	FND_API.G_TRUE
-- p_validation_level	IN	NUMBER	N	Null	FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	IN	VARCHAR2	N	Null	SELF_SERVICE
-- p_debug_mode	      IN	VARCHAR2	N	Null	N
-- p_max_msg_count	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_id	      IN	NUMBER	N	Not Null
-- p_task_number	      IN	VARCHAR2	N	Not Null
-- p_task_name	      IN	VARCHAR2	N	Not Null
-- p_task_description	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_location_id	      IN	NUMBER	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_country	      IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_territory_code	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_state_region  	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_city	            IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_task_manager_id	IN	NUMBER	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_carrying_out_org_id	IN	NUMBER	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_priority_code	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_TYPE_ID  	      IN	NUMBER	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_status_code	      IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_inc_proj_progress_flag	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_product_code	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_task_reference	IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_closed_date	      IN	VARCHAR2	N	Null	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_transaction_start_date IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_transaction_finish_date IN   DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_record_version_number	IN	NUMBER	N	Not Null
-- x_return_status	OUT 	VARCHAR2	N	Null
-- x_msg_count	      OUT 	NUMBER	N	Null
-- x_msg_data	      OUT 	VARCHAR2	N	Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--  31-JUL-02   H Siu                    -Added transaction dates
--
--

PROCEDURE Update_Task(
 p_api_version	      IN	NUMBER	:=1.0,
 p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE',
 p_debug_mode	      IN	VARCHAR2	:='N',
 p_max_msg_count	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_id          IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_peer_or_sub          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_id              IN	NUMBER,
 p_task_number	      IN	VARCHAR2,
 p_task_name	      IN	VARCHAR2,
 p_task_description	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_location_id	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_country	            IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_territory_code	      IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_state_region  	      IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_city	            IN	VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_manager_id	IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_carrying_out_org_id	IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_priority_code	      IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_TYPE_ID  	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_status_code	      IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_inc_proj_progress_flag	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_product_code	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_task_reference	IN	VARCHAR2	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_closed_date	      IN	DATE	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_transaction_start_date IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_transaction_finish_date IN   DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_address_id    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_address1      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_type_id  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_service_type_code IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_chargeable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_billable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_receive_project_invoice_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_task_weighting_deriv_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_item_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_uom_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wq_actual_entry_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_progress_entry_page_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_progress_entry_page IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_phase_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_parent_structure_id  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_phase_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_record_version_number	IN	NUMBER,
 -- xxlu added task DFF attributes
 p_tk_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- end xxlu changes
 p_Base_Perc_Comp_Deriv_Code    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_gen_etc_src_code      IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    -- This param added for FP_M changes 3305199
-- Bug#3491609 : Workflow Chanegs FP M
 p_wf_item_type          IN    pa_proj_elements.wf_item_type%TYPE       :=NULL,
 p_wf_process            IN    pa_proj_elements.wf_process%TYPE         :=NULL,
 p_wf_lead_days          IN    pa_proj_elements.wf_start_lead_days%TYPE :=NULL,
 p_wf_enabled_flag       IN    pa_proj_elements.enable_wf_flag%TYPE     :=NULL,
 -- Bug#3491609 : Workflow Chanegs FP M
 x_return_status	      OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count	      OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data	            OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 p_shared                IN      VARCHAR2 := 'X' -- Added for Bug 3451073
);

-- API name                      : Create_Task_version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	      IN	NUMBER	N	Not Null	1.0
-- p_init_msg_list	IN	VARCHAR2	N	Not Null	FND_API.TRUE
-- p_commit	            IN	VARCHAR2	N	Not Null	FND_API.G_FALSE
-- p_validate_only	IN	VARCHAR2	N	Not Null	FND_API.G_TRUE
-- p_validation_level	IN	NUMBER	N	Null	FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	IN	VARCHAR2	N	Null	SELF_SERVICE
-- p_debug_mode	      IN	VARCHAR2	N	Null	N
-- p_max_msg_count	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_ref_task_version_id	IN	NUMBER	N	Not Null
-- p_peer_or_sub	IN	VARCHAR2	N	Not Null
-- p_task_id	IN	NUMBER	N	Not Null
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- x_task_version_id	OUT	NUMBER	N	Null
-- x_return_status	OUT 	VARCHAR2	N	Null
-- x_msg_count	      OUT 	NUMBER	N	Null
-- x_msg_data	      OUT 	VARCHAR2	N	Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Create_Task_Version(
 p_api_version	      IN	NUMBER	:=1.0,
 p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE',
 p_debug_mode	      IN	VARCHAR2	:='N',
 p_max_msg_count	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_version_id	IN	NUMBER,
 p_peer_or_sub	      IN	VARCHAR2,
 p_task_id	            IN	NUMBER,
 p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_WEIGHTING_PERCENTAGE IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_TASK_UNPUB_VER_STATUS_CODE IN VARCHAR2 := NULL,
--bug 3301192
 p_financial_task_flag                IN VARCHAR2 := 'N',
--bug 3301192
 x_task_version_id	OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	      OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count	      OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data	            OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
);

-- API name                      : Update_Task_version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	      IN	NUMBER	N	Not Null	1.0
-- p_init_msg_list	IN	VARCHAR2	N	Not Null	FND_API.TRUE
-- p_commit	            IN	VARCHAR2	N	Not Null	FND_API.G_FALSE
-- p_validate_only	IN	VARCHAR2	N	Not Null	FND_API.G_TRUE
-- p_validation_level	IN	NUMBER	N	Null	FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	IN	VARCHAR2	N	Null	SELF_SERVICE
-- p_debug_mode	      IN	VARCHAR2	N	Null	N
-- p_max_msg_count	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_version_id	IN	NUMBER	N	Null
-- p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_record_version_number	IN	NUMBER
-- x_return_status	OUT 	VARCHAR2	N	Null
-- x_msg_count	      OUT 	NUMBER	N	Null
-- x_msg_data	      OUT 	VARCHAR2	N	Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Update_Task_Version(
 p_api_version	      IN	NUMBER	:=1.0,
 p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE',
 p_debug_mode	      IN	VARCHAR2	:='N',
 p_max_msg_count	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_version_id	IN	NUMBER,
 p_peer_or_sub	      IN	VARCHAR2,
 p_task_version_id	IN	NUMBER,
 p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_record_version_number	IN	NUMBER,
 p_action          IN    VARCHAR2 := 'NULL',

 p_WEIGHTING_PERCENTAGE IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_TASK_UNPUB_VER_STATUS_CODE IN VARCHAR2 := NULL,

 x_return_status	      OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count	      OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data	            OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
);

-- API name                      : Delete_Task_version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	      IN	NUMBER	N	Not Null	1.0
-- p_init_msg_list	IN	VARCHAR2	N	Not Null	FND_API.TRUE
-- p_commit	            IN	VARCHAR2	N	Not Null	FND_API.G_FALSE
-- p_validate_only	IN	VARCHAR2	N	Not Null	FND_API.G_TRUE
-- p_validation_level	IN	NUMBER	N	Null	FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	IN	VARCHAR2	N	Null	SELF_SERVICE
-- p_debug_mode	      IN	VARCHAR2	N	Null	N
-- p_max_msg_count	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_version_id	IN	NUMBER	N	Null
-- p_record_version_number	IN	NUMBER
-- x_return_status	OUT 	VARCHAR2	N	Null
-- x_msg_count	      OUT 	NUMBER	N	Null
-- x_msg_data	      OUT 	VARCHAR2	N	Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Delete_Task_Version(
 p_api_version	      IN	NUMBER	:=1.0,
 p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE',
 p_debug_mode	      IN	VARCHAR2	:='N',
 p_max_msg_count	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id	IN	NUMBER,
 p_record_version_number	IN	NUMBER,
 p_called_from_api      IN    VARCHAR2    := 'ABCD',
 p_structure_type       IN VARCHAR2       := 'WORKPLAN', --bug 3301192
 x_return_status	      OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count	      OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data	            OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
);

-- API name                      : Create_Schedule_Version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	      IN	NUMBER	N	Not Null	1.0
-- p_init_msg_list	IN	VARCHAR2	N	Not Null	FND_API.TRUE
-- p_commit	            IN	VARCHAR2	N	Not Null	FND_API.G_FALSE
-- p_validate_only	IN	VARCHAR2	N	Not Null	FND_API.G_TRUE
-- p_validation_level	IN	NUMBER	N	Null	FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	IN	VARCHAR2	N	Null	SELF_SERVICE
-- p_debug_mode	      IN	VARCHAR2	N	Null	N
-- p_max_msg_count	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_version_id	IN	NUMBER	N	Not Null
-- p_calendar_id	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_scheduled_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_scheduled_end_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_end_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_finish_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_finish_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_duration	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_early_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_early_end_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_end_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_milestone_flag	IN	VARCHAR2	N	NULL	N
-- p_critical_flag	IN	VARCHAR2	N	NULL	N
-- x_pev_schedule_id	OUT	NUMBER	N	NULL
-- x_return_status	OUT 	VARCHAR2	N	Null
-- x_msg_count	      OUT 	NUMBER	N	Null
-- x_msg_data	      OUT 	VARCHAR2	N	Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Create_Schedule_Version(
 p_api_version	      IN	NUMBER	:=1.0,
 p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE',
 p_debug_mode	      IN	VARCHAR2	:='N',
 p_max_msg_count	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_element_version_id	IN	NUMBER,
 p_calendar_id	      IN	NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_scheduled_start_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_end_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_start_date IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_end_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_start_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_finish_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_start_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_finish_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_duration	            IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_early_start_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_early_end_date	      IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_start_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_end_date 	      IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_milestone_flag	      IN	VARCHAR2	:='N',
 p_critical_flag	      IN	VARCHAR2	:='N',
 p_WQ_PLANNED_QUANTITY        IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EFFORT             IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EQUIP_EFFORT       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,   --bug 3305199
 p_ext_act_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_remain_duration         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_sch_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_attribute_category     IN    pa_proj_elem_ver_schedule.attribute_category%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1             IN    pa_proj_elem_ver_schedule.attribute1%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2             IN    pa_proj_elem_ver_schedule.attribute2%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3             IN    pa_proj_elem_ver_schedule.attribute3%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4             IN    pa_proj_elem_ver_schedule.attribute4%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5             IN    pa_proj_elem_ver_schedule.attribute5%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6             IN    pa_proj_elem_ver_schedule.attribute6%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7             IN    pa_proj_elem_ver_schedule.attribute7%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8             IN    pa_proj_elem_ver_schedule.attribute8%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9             IN    pa_proj_elem_ver_schedule.attribute9%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10            IN    pa_proj_elem_ver_schedule.attribute10%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11            IN    pa_proj_elem_ver_schedule.attribute11%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12            IN    pa_proj_elem_ver_schedule.attribute12%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13            IN    pa_proj_elem_ver_schedule.attribute13%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14            IN    pa_proj_elem_ver_schedule.attribute14%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15            IN    pa_proj_elem_ver_schedule.attribute15%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 --bug 3305199 schedule options
 p_def_sch_tool_tsk_type_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_type_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_free_slack                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_total_slack                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_effort_driven_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_level_assignments_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --end bug 3305199

 x_pev_schedule_id	OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	      OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count	      OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data	            OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
);


-- API name                      : Update_Schedule_Version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	      IN	NUMBER	N	Not Null	1.0
-- p_init_msg_list	IN	VARCHAR2	N	Not Null	FND_API.TRUE
-- p_commit	            IN	VARCHAR2	N	Not Null	FND_API.G_FALSE
-- p_validate_only	IN	VARCHAR2	N	Not Null	FND_API.G_TRUE
-- p_validation_level	IN	NUMBER	N	Null	FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	IN	VARCHAR2	N	Null	SELF_SERVICE
-- p_debug_mode	      IN	VARCHAR2	N	Null	N
-- p_max_msg_count	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_version_id	IN	NUMBER	N	Not Null
-- p_calendar_id	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_scheduled_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_scheduled_end_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_end_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_finish_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_finish_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_duration	IN	NUMBER	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_early_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_early_end_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_start_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_end_date	IN	DATE	N	NULL	PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_milestone_flag	IN	VARCHAR2	N	NULL	N
-- p_critical_flag	IN	VARCHAR2	N	NULL	N
-- x_pev_schedule_id	OUT	NUMBER	N	NULL
-- x_return_status	OUT 	VARCHAR2	N	Null
-- x_msg_count	      OUT 	NUMBER	N	Null
-- x_msg_data	      OUT 	VARCHAR2	N	Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Update_Schedule_Version(
 p_api_version	      IN	NUMBER	:=1.0,
 p_init_msg_list	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_commit	            IN	VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only	      IN	VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level	IN	NUMBER	:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	      IN	VARCHAR2	:='SELF_SERVICE',
 p_debug_mode	      IN	VARCHAR2	:='N',
 p_max_msg_count	      IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_pev_schedule_id	IN	NUMBER,
 p_calendar_id	      IN	NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_scheduled_start_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_end_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_start_date IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_end_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_start_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_finish_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_start_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_finish_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_duration	            IN	NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_early_start_date	IN	DATE		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_early_end_date	      IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_start_date	IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_end_date 	      IN	DATE	      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_milestone_flag	      IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 2791410
 p_critical_flag	      IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 2791410
 p_WQ_PLANNED_QUANTITY        IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EFFORT             IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EQUIP_EFFORT       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,   --bug 3305199
 --bug 3305199 schedule options
 p_def_sch_tool_tsk_type_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_type_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_free_slack                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_total_slack                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_effort_driven_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_level_assignments_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --end bug 3305199
 p_record_version_number IN   NUMBER,
 p_ext_act_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_remain_duration         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_sch_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_attribute_category     IN    pa_proj_elem_ver_schedule.attribute_category%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1             IN    pa_proj_elem_ver_schedule.attribute1%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2             IN    pa_proj_elem_ver_schedule.attribute2%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3             IN    pa_proj_elem_ver_schedule.attribute3%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4             IN    pa_proj_elem_ver_schedule.attribute4%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5             IN    pa_proj_elem_ver_schedule.attribute5%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6             IN    pa_proj_elem_ver_schedule.attribute6%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7             IN    pa_proj_elem_ver_schedule.attribute7%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8             IN    pa_proj_elem_ver_schedule.attribute8%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9             IN    pa_proj_elem_ver_schedule.attribute9%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10            IN    pa_proj_elem_ver_schedule.attribute10%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11            IN    pa_proj_elem_ver_schedule.attribute11%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12            IN    pa_proj_elem_ver_schedule.attribute12%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13            IN    pa_proj_elem_ver_schedule.attribute13%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14            IN    pa_proj_elem_ver_schedule.attribute14%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15            IN    pa_proj_elem_ver_schedule.attribute15%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 x_return_status	      OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count	      OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data	            OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
);

PROCEDURE Inherit_task_type_attr(
 p_api_version            IN NUMBER	:=1.0,
 p_init_msg_list          IN VARCHAR2	:=FND_API.G_TRUE,
 p_commit                 IN VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only          IN VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level       IN NUMBER	:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN VARCHAR2	:='SELF_SERVICE',
 p_debug_mode             IN VARCHAR2	:='N',
 p_max_msg_count          IN NUMBER	:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_id                IN NUMBER,
 p_task_version_id        IN NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count              OUT NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data               OUT NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
);

--   API name                      : Update_Task_Weighting
--   Type                          : Private Procedure
--   Pre-reqs                      : None
--   Return Value                  : N/A
--   Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_object_relationship_id            IN  NUMBER
--   p_weighting_percentage              IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  20-SEP-02   hyau             -Created
--
--

  procedure Update_Task_Weighting
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER
   ,p_weighting_percentage              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE RECALC_TASKS_WEIGHTING(
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id                   IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE update_task_ver_delete_status(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id                   IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure delete_task_ver_wo_val
  (
    p_api_version           IN  NUMBER  :=1.0,
    p_init_msg_list         IN  VARCHAR2:=FND_API.G_TRUE,
    p_commit                IN  VARCHAR2:=FND_API.G_FALSE,
    p_validate_only         IN  VARCHAR2:=FND_API.G_TRUE,
    p_validation_level      IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
    p_calling_module        IN  VARCHAR2:='SELF_SERVICE',
    p_debug_mode            IN  VARCHAR2:='N',
    p_max_msg_count         IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_structure_version_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_task_version_id	    IN  NUMBER,
    p_record_version_number IN	NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
    x_msg_count	            OUT NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
    x_msg_data	            OUT NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
  );

  procedure UPDATE_WORKING_VER_WEIGHT(
    p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_id                           IN  NUMBER
   ,p_weighting                         IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

 procedure set_new_tasks_to_TBD(
    p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_task_id                           IN  NUMBER
   ,p_task_status                       IN  VARCHAR2
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

-- Bug 2812855 : Added following procedure to populate actual and estimated dates to all the task versions

PROCEDURE Update_Dates_To_All_Versions(
 p_api_version			IN	NUMBER		:=1.0,
 p_init_msg_list	        IN	VARCHAR2	:=FND_API.G_TRUE,
 p_commit		        IN	VARCHAR2	:=FND_API.G_FALSE,
 p_validate_only	        IN	VARCHAR2	:=FND_API.G_TRUE,
 p_validation_level	        IN	NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	        IN	VARCHAR2	:='SELF_SERVICE',
 p_debug_mode			IN	VARCHAR2	:='N',
 p_max_msg_count	        IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id                   IN      NUMBER,
 p_element_version_id		IN	NUMBER,
 x_return_status		OUT 	NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
 x_msg_count			OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
 x_msg_data			OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
);

END PA_TASK_PVT1;

/
