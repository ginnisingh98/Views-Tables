--------------------------------------------------------
--  DDL for Package PA_BILLING_SETUP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_SETUP_UTILS" AUTHID CURRENT_USER AS
/* $Header: PABLSTUS.pls 120.1 2005/08/19 16:16:57 mwasowic noship $ */


-- API name                      : Validate_Retn_Inv_Format
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_retention_inv_format_id   IN    NUMBER     OPTIONAL  DEFAULT FND_API.G_MISS_NUM
-- p_retention_inv_format_name IN    VARCHAR2   OPTIONAL  DEFAULT FND_API.G_MISS_CHAR
-- p_check_id                  IN    VARCHAR2   REQUIRED  DEFAULT 'A'
-- x_retention_inv_format_id   OUT   NUMBER     REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Validate_Retn_Inv_Format(
 p_retention_inv_format_id   IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_retention_inv_format_name IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_check_id_flag                  IN    VARCHAR2   DEFAULT 'A',
 x_retention_inv_format_id   OUT   NOCOPY NUMBER     , --File.Sql.39 bug 4440895
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);


-- API name                      : Duplicate_credit_receivers
-- Type                          : Utility Function
-- Pre-reqs                      : None
-- Return Value                  : BOOLEAN
-- Prameters
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_effective_to_date           IN    DATE     REQUIRED  ,
-- p_credit_receiver_id          IN    NUMBER   REQUIRED,
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION  Duplicate_credit_receivers(
 p_project_id	         	 IN	 NUMBER     ,
 p_task_id	         	       IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type                 IN    VARCHAR2 ,
 p_person_id                   IN    NUMBER   ,
 p_effective_from_date         IN    DATE       ,
 p_effective_to_date           IN    DATE       ,
 p_credit_receiver_id          IN    NUMBER,
 x_return_status	             OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
 ) RETURN BOOLEAN;

-- API name                      : Duplicate_billing_assignments
-- Type                          : Utility Function
-- Pre-reqs                      : None
-- Return Value                  : BOOLEAN
-- Prameters
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_billing_extension_id    IN   VARCHAR2   REQUIRED
-- p_billing_assignment_id     IN    NUMBER     REQUIRED
-- p_active_flag               IN    VARCHAR2   REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION  Duplicate_billing_assignments(
 p_project_id	         	 IN	 NUMBER     ,
 p_task_id	         	       IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id      IN    NUMBER ,
 p_billing_assignment_id     IN    NUMBER  ,
 p_active_flag               IN    VARCHAR2,
 x_return_status	             OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
 ) RETURN BOOLEAN;


-- API name                      : VALIDATE_PERSON_ID_NAME
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_retention_inv_format_id   IN    NUMBER     OPTIONAL  DEFAULT FND_API.G_MISS_NUM
-- p_retention_inv_format_name IN    VARCHAR2   OPTIONAL  DEFAULT FND_API.G_MISS_CHAR
-- p_check_id                  IN    VARCHAR2   REQUIRED  DEFAULT 'A'
-- x_retention_inv_format_id   OUT   NUMBER     REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  VALIDATE_PERSON_ID_NAME(
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name               IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_check_id_flag             IN    VARCHAR2   DEFAULT 'A',
 x_person_id                 OUT   NOCOPY NUMBER     , --File.Sql.39 bug 4440895
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);


-- API name                      : Get_Next_Billing_Date
-- Type                          : Utility Function
-- Pre-reqs                      : None
-- Return Value                  : DATE
-- Prameters
-- p_project_id                IN    NUMBER
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION  Get_Next_Billing_Date(
 p_project_id                IN    NUMBER,
 x_return_status	           OUT 	 NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) RETURN DATE;

-- API name                      : REV_BILL_INF_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_type_class_code   IN    VARCHAR2   REQUIRED
-- p_distribution_rule         IN    VARCHAR2   REQUIRED
-- p_billing_cycle_id          IN    NUMBER     REQUIRED
-- p_first_bill_offset         IN    NUMBER     REQUIRED
-- p_billing_job_group_id         IN    NUMBER  REQUIRED
-- p_labor_id                    IN    NUMBER   REQUIRED
-- p_non_labor_id                 IN    NUMBER  REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  REV_BILL_INF_REQ_CHECK(
 p_project_type_class_code   IN    VARCHAR2   ,
 p_distribution_rule         IN    VARCHAR2   ,
 p_billing_cycle_id          IN    NUMBER     ,
 p_first_bill_offset         IN    NUMBER     ,
 p_billing_job_group_id      IN    NUMBER  ,
 p_labor_id                  IN    NUMBER   ,
 p_non_labor_id              IN    NUMBER  ,
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

-- API name                      : BILL_XTENSION_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_billing_extension_id      IN    NUMBER     REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  BILL_XTENSION_REQ_CHECK(
 p_billing_extension_id      IN    NUMBER    ,
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

-- API name                      : VALIDATE_EMP_NO_TO_ID
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_person_id                 IN   NUMBER     DEFAULT FND_API.G_MISS_NUM,
-- p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
-- p_check_id                  IN    VARCHAR2   REQUIRED  DEFAULT 'A'
-- x_person_id                 OUT   NUMBER     ,
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  VALIDATE_EMP_NO_TO_ID(
 p_person_id                 IN   NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_check_id_flag                  IN    VARCHAR2   DEFAULT 'A',
 x_person_id                 OUT   NOCOPY NUMBER     , --File.Sql.39 bug 4440895
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

-- API name                      : VALIDATE_EMP_NO_NAME
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_person_id                 IN   NUMBER     OPTIONAL DEFAULT FND_API.G_MISS_NUM,
-- p_person_name               IN   VARCHAR2   OPTIONAL DEFAULT FND_API.G_MISS_CHAR,
-- p_emp_number                IN   VARCHAR2    OPTIONAL DEFAULT FND_API.G_MISS_CHAR,
-- p_check_id                  IN    VARCHAR2  REQUIRED DEFAULT 'A'
-- x_person_id                 OUT   NUMBER
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  VALIDATE_EMP_NO_NAME(
 p_person_id                 IN   NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name               IN   VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_check_id                  IN    VARCHAR2   DEFAULT 'A',
 x_person_id                 OUT   NOCOPY NUMBER     , --File.Sql.39 bug 4440895
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);


-- API name                      : CREDIT_REC_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     REQUIRED
-- p_transfer_to_AR            IN    VARCHAR2   REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  CREDIT_REC_REQ_CHECK(
 p_credit_type               IN    VARCHAR2 ,
 p_person_id                 IN    NUMBER,
 p_transfer_to_AR            IN    VARCHAR2,
 p_effective_from_date       IN    DATE,
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

-- API name                      : GET_SALES_CREDIT_FLAG
-- Type                          : Utility Function
-- Pre-reqs                      : None
-- Return Value                  : VARCHAR2( 'Y', 'N' )
-- Prameters
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-JUN-01   Majid Ansari             -Created
--
--

 FUNCTION  GET_SALES_CREDIT_FLAG(
 x_return_status	           OUT 	 NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) RETURN VARCHAR2;


END PA_BILLING_SETUP_UTILS;

 

/
