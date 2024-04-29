--------------------------------------------------------
--  DDL for Package PA_BILLING_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_SCHEDULE_PUB" AUTHID CURRENT_USER AS
/* $Header: PABLINPS.pls 120.1 2005/08/19 16:16:22 mwasowic noship $ */

-- API name                      : Update_Project_Task_Bill_Info
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_lbr_schedule_type	 	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_non_lbr_schedule_type	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_emp_bill_rate_sch_name	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_emp_bill_rate_sch_id 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_job_bill_rate_sch_name	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_job_bill_rate_sch_id   	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_lbr_sch_fxd_date	 	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_lbr_sch_discount	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_rev_schedule	         IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_rev_schedule_id	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_inv_schedule	       	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_inv_schedule_id	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_rev_ind_sch_fxd_date	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_inv_ind_sch_fxd_date 	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_nlbr_bill_rate_org	 	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_nlbr_bill_rate_org_id	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_nlbr_std_bill_rate_sch	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_nlbr_sch_fxd_date	         IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_nlbr_sch_discount	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Update_Project_Task_Bill_Info(
 p_api_version	       	         IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	         IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	                 IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	                 IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_lbr_schedule_type	         IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_non_lbr_schedule_type         IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_emp_bill_rate_sch_name        IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
 p_emp_bill_rate_sch_id          IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_job_bill_rate_sch_name        IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR   ,
 p_job_bill_rate_sch_id          IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_lbr_sch_fxd_date	         IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
 p_lbr_sch_discount	         IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_rev_schedule	                 IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
 p_rev_schedule_id	         IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_inv_schedule	                 IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
 p_inv_schedule_id	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_rev_ind_sch_fxd_date	 	 IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
 p_inv_ind_sch_fxd_date 	 IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
 p_nlbr_bill_rate_org	 	 IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
 p_nlbr_bill_rate_org_id	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_nlbr_std_bill_rate_sch	 IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
 p_nlbr_sch_fxd_date	         IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
 p_nlbr_sch_discount	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	                 OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                 OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

-- API name                      : update_billing_schedule_type
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	       IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_lbr_schedule_type   IN    VARCHAR2       REQUIRED,
-- p_non_lbr_schedule_type   IN    VARCHAR2   REQUIRED,
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  update_billing_schedule_type(
 p_api_version	                 IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_lbr_schedule_type   IN    VARCHAR2,
 p_non_lbr_schedule_type   IN    VARCHAR2,
 p_record_version_number         IN	 NUMBER     DEFAULT 1,
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	                 OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	                 OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);


-- API name                      : create_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	         IN	 NUMBER	OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	         IN	 NUMBER	REQUIRED
-- p_effective_from_date	 IN	 DATE	      REQUIRED
-- p_effective_to_date	         IN	 DATE	      OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- x_labor_multiplier_id         OUT   NUMBER   REQUIRED
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	               OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	               OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  Create_Labor_Multiplier(
 p_api_version	                 IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	         IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	                 IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	                 IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier	         IN	 NUMBER	,
 p_effective_from_date	         IN	 DATE	      ,
 p_effective_to_date	         IN	 DATE	      DEFAULT FND_API.G_MISS_DATE,
 x_labor_multiplier_id     OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	               OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

-- API name                      : update_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier_id       IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	         IN	 NUMBER	OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_effective_from_date	 IN	 DATE	      REQUIRED
-- p_effective_to_date	         IN	 DATE	      OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  Update_Labor_Multiplier(
 p_api_version	                 IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	         IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	                 IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier_id       IN    NUMBER,
 p_project_id	                 IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier	         IN	 NUMBER	,
 p_effective_from_date	         IN	 DATE	      ,
 p_effective_to_date	         IN	 DATE	      DEFAULT FND_API.G_MISS_DATE,
 p_record_version_number         IN	 NUMBER     DEFAULT 1,
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	                 OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	                 OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

-- API name                      : delete_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier_id       IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	         IN	 NUMBER	OPTIONAL
-- p_effective_from_date	 IN	 DATE	      REQUIRED
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  delete_Labor_Multiplier(
 p_api_version	                 IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier_id   IN    NUMBER,
 p_project_id	       IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier	         IN	 NUMBER	,
 p_effective_from_date	         IN	 DATE	      ,
 p_record_version_number         IN	 NUMBER     DEFAULT 1,
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	                 OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	                 OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

END PA_BILLING_SCHEDULE_PUB;

 

/
