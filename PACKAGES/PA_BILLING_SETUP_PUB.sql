--------------------------------------------------------
--  DDL for Package PA_BILLING_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_SETUP_PUB" AUTHID CURRENT_USER AS
/* $Header: PABLSTPS.pls 120.3 2005/08/19 16:16:48 mwasowic noship $ */


-- API name                      : update_revenue_and_billing
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
-- p_distribution_rule         IN    VARCHAR2   REQUIRED
-- p_billing_cycle_id          IN    NUMBER   REQUIRED
-- p_first_bill_offset         IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_next_billing_date         OUT   DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_output_tax_code           IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_billing_job_group_id      IN    NUMBER   REQUIRED
-- p_invoice_comment           IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_labor_id                  IN    NUMBER   REQUIRED
-- p_non_labor_id              IN    NUMBER   OPTIONAL
-- p_retention_inv_format_id   IN    VARCHAR2   OPTIONAL
-- p_retention_inv_format_name IN    VARCHAR2   OPTIONAL
-- p_retention_percent         IN    NUMBER     OPTIONAL
-- p_retention_output_tax_code IN    VARCHAR2   OPTIONAL
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  update_revenue_and_billing(
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_distribution_rule         IN    VARCHAR2   ,
 p_billing_cycle_id          IN    NUMBER   ,
 p_first_bill_offset         IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_next_billing_date         OUT    NOCOPY DATE      , --File.Sql.39 bug 4440895
 p_output_tax_code           IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_billing_job_group_id      IN    NUMBER   ,
 p_invoice_comment           IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_labor_id                  IN    NUMBER   ,
 p_non_labor_id              IN    NUMBER   ,
 p_retention_inv_format_id   IN    VARCHAR2   ,
 p_retention_inv_format_name IN    VARCHAR2   ,
 p_retention_percent         IN    NUMBER     ,
 p_retention_output_tax_code IN    VARCHAR2   ,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );


-- API name                      : create_credit_receivers
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
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_person_name               IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CAHR
-- p_emp_number                IN    VARCHAR2     OPTIONAL DEFAULT FND_API.G_MISS_CHAR,
-- p_credit_percentage         IN    NUMBER   REQUIRED
-- p_transfer_to_AR            IN    VARCHAR2   REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_effective_to_date         IN    DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- x_credit_receiver_id        OUT   NUMBER   REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  create_credit_receivers(
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type               IN    VARCHAR2   ,
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name               IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_credit_percentage         IN    NUMBER   ,
 p_transfer_to_AR            IN    VARCHAR2   ,
 p_effective_from_date         IN    DATE       ,
 p_effective_to_date           IN    DATE        DEFAULT FND_API.G_MISS_DATE,
 x_credit_receiver_id          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

-- API name                      : update_credit_receivers
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
-- p_credit_receiver_id        IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_person_name               IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CAHR
-- p_emp_number                IN    VARCHAR2     OPTIONAL DEFAULT FND_API.G_MISS_CHAR,
-- p_credit_percentage         IN    NUMBER   REQUIRED
-- p_transfer_to_AR            IN    VARCHAR2   REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_effective_to_date         IN    DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  update_credit_receivers(
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_receiver_id        IN    NUMBER ,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type               IN    VARCHAR2   ,
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name               IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_credit_percentage         IN    NUMBER   DEFAULT FND_API.G_MISS_NUM,
 p_transfer_to_AR            IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_effective_from_date         IN    DATE       ,
 p_effective_to_date           IN    DATE        DEFAULT FND_API.G_MISS_DATE,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );


-- API name                      : delete_credit_receivers
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
-- p_credit_receiver_id        IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_person_name               IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CAHR
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  delete_credit_receivers(
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_receiver_id        IN    NUMBER,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type               IN    VARCHAR2   ,
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name               IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_effective_from_date         IN    DATE       ,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

-- API name                      : create_billing_assignments
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
-- p_billing_extension_id    IN    NUMBER   REQUIRED
-- p_amount                    IN    NUMBER     REQUIRED
-- p_percent                   IN    NUMBER     REQUIRED
-- p_active                    IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- x_billing_assignment_id     OUT   NUMBER     REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  create_billing_assignments(
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id    IN    NUMBER   ,
 p_amount                    IN    NUMBER   DEFAULT FND_API.G_MISS_NUM,
 p_percent                   IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_active                    IN    VARCHAR2    DEFAULT FND_API.G_MISS_CHAR,
 x_billing_assignment_id     OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );


-- API name                      : update_billing_assignments
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
-- p_billing_extension_id    IN    NUMBER   REQUIRED
-- p_billing_assignment_id    IN    NUMBER   ,
-- p_amount                    IN    NUMBER     REQUIRED
-- p_percent                   IN    NUMBER     REQUIRED
-- p_active                    IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  update_billing_assignments(
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id    IN    NUMBER   ,
 p_billing_assignment_id    IN    NUMBER   ,
 p_amount                    IN    NUMBER     ,
 p_percent                   IN    NUMBER     ,
 p_active                    IN    VARCHAR2    DEFAULT FND_API.G_MISS_CHAR,
 p_record_version_number	 IN	 NUMBER    DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );


-- API name                      : delete_billing_assignments
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
-- p_billing_extension_id    IN    NUMBER   REQUIRED
-- p_billing_assignment_id    IN    NUMBER   ,
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  delete_billing_assignments(
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id    IN    NUMBER   ,
 p_billing_assignment_id    IN    NUMBER   ,
 p_record_version_number	 IN	 NUMBER    DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );



END PA_BILLING_SETUP_PUB;

 

/
