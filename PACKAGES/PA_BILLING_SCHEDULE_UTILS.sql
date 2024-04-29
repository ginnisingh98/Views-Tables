--------------------------------------------------------
--  DDL for Package PA_BILLING_SCHEDULE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_SCHEDULE_UTILS" AUTHID CURRENT_USER AS
/* $Header: PABLINUS.pls 120.1 2005/08/19 16:16:31 mwasowic noship $ */

-- API name                      : Emp_bill_rate_sch_name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_emp_bill_rate_id	    	IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_emp_bill_rate_name		IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_check_id_flag		IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_ emp_bill_rate_id		OUT 	NUMBER	REQUIRED
-- x_return_status		OUT	VARCHAR2	REQUIRED
-- x_error_msg_code		OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Emp_bill_rate_sch_name_To_Id(
   p_emp_bill_rate_id	    	IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_emp_bill_rate_name		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag		IN	VARCHAR2	DEFAULT 'A',
   x_emp_bill_rate_id		OUT 	NOCOPY NUMBER	, --File.Sql.39 bug 4440895
   x_return_status		OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code		OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 );

-- API name                      : Job_bill_rate_sch_name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_job_bill_rate_id	    	IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_job_bill_rate_name		IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_check_id_flag		IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- p_job_group_id	        IN	NUMBER	REQUIRED
-- x_job_bill_rate_id		OUT 	NUMBER	REQUIRED
-- x_return_status		OUT	VARCHAR2	REQUIRED
-- x_error_msg_code		OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  job_bill_rate_sch_name_To_Id(
   p_job_bill_rate_id	    	IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_job_bill_rate_name		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag		IN	VARCHAR2	DEFAULT 'A',
   p_job_group_id               IN    NUMBER ,
   x_job_bill_rate_id		OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
   x_return_status		OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code		OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 );

-- API name                      : Rev_Sch_Name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_rev_sch_id	    	      IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_rev_sch_name	      IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_check_id_flag	      IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_rev_sch_id		      OUT 	NUMBER	REQUIRED
-- x_return_status	      OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	      OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Rev_Sch_Name_To_Id(
   p_rev_sch_id	    	      IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_rev_sch_name	      IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag	      IN	VARCHAR2	DEFAULT 'A',
   x_rev_sch_id		      OUT 	NOCOPY NUMBER	, --File.Sql.39 bug 4440895
   x_return_status	      OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	      OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 );

-- API name                      : Inv_Sch_Name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_inv_sch_id	    	      IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_inv_sch_name	      IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_check_id_flag            IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_inv_sch_id		      OUT 	NUMBER	REQUIRED
-- x_return_status	      OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	      OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Inv_Sch_Name_To_Id(
   p_Inv_sch_id	    	      IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_Inv_sch_name	      IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag	      IN	VARCHAR2	DEFAULT 'A',
   x_Inv_sch_id		      OUT 	NOCOPY NUMBER	, --File.Sql.39 bug 4440895
   x_return_status	      OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	      OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 );

-- API name                      : Nlbr_schedule_name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_sch_name		IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_nlbr_org_id        IN    NUMBER      REQUIRED
-- p_check_id_flag	IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_sch_name		OUT 	NUMBER	REQUIRED
-- x_return_status	OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Nlbr_schedule_name_To_Id(
   p_sch_name		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_nlbr_org_id        IN    NUMBER,
   p_check_id_flag	IN	VARCHAR2	DEFAULT 'A',
   x_sch_name		OUT 	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_return_status	OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 );

-- API name                      : NL_org_sch_Name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_org_id	    	IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_org_name		IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_nlbr_org_id        IN    NUMBER      REQUIRED
-- p_check_id_flag	IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_org_id		OUT 	NUMBER	REQUIRED
-- x_return_status	OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  NL_org_sch_Name_To_Id(
   p_org_id	    	IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_org_name		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag	IN	VARCHAR2	DEFAULT 'A',
   x_org_id		OUT 	NOCOPY NUMBER	, --File.Sql.39 bug 4440895
   x_return_status	OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 );

-- API name                      : Duplicate_labor_Multiplier
-- Type                          : Public Function
-- Pre-reqs                      : None
-- Return Value                  : BOLLEAN
-- Prameters
-- p_project_id	          IN	NUMBER	REQUIRED
-- p_task_id	          IN	NUMBER	OPTIONAL      DEFAULT FND_API.MISS_NUM
-- p_effective_from_date  IN	DATE	      REQUIRED
-- p_effective_to_date      IN      DATE
-- p_labor_multiplier_id    IN      NUMBER
-- x_return_status	  OUT 	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION  Duplicate_labor_Multiplier(
   p_project_id	          IN	NUMBER,
   p_task_id	          IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_effective_from_date  IN	DATE	      ,
   p_effective_to_date  IN	DATE	      ,
   p_labor_multiplier_id    IN      NUMBER ,
   x_return_status	  OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) RETURN BOOLEAN;

-- API name                      : Emp_job_mandatory_validation
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_emp_bill_rate_sch_id	IN	NUMBER	OPTIONAL DEFAULT FND_API.G_MISS_NUM
-- p_job_bill_rate_sch_id	IN	VARCHAR2	OPTIONAL DEFAULT FND_API.G_MISS_NUM
-- x_return_status	        OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	        OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Emp_job_mandatory_validation(
   p_emp_bill_rate_sch_id	IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_job_bill_rate_sch_id	IN	VARCHAR2	DEFAULT FND_API.G_MISS_NUM,
   x_return_status	        OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	        OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 );

-- API name                      : Get_Job_Group_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : NUMBER
-- Prameters
-- p_project_id                 IN      NUMBER          REQUIRED
-- x_return_status              OUT     VARCHAR2        REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION Get_Job_Group_Id(
   p_project_id NUMBER ,
   x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) RETURN NUMBER;


-- API name                      : Get_Project_Type_Class
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : VARCHAR2
-- Prameters
-- p_project_id                 IN      NUMBER          REQUIRED
-- x_return_status              OUT     VARCHAR2        REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION Get_Project_Type_Class(
   p_project_id NUMBER ,
   x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) RETURN VARCHAR2;

-- API name                      : CHECK_BILL_INFO_REQ
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_type_class_code   IN    VARCHAR2    REQUIRED
-- p_lbr_schedule_type         IN    VARCHAR2    REQUIRED
-- p_non_lbr_schedule_type     IN    VARCHAR2    REQUIRED
-- p_emp_bill_rate_sch_id      IN    NUMBER      REQUIRED
-- p_job_bill_rate_sch_id      IN    NUMBER      REQUIRED
-- p_rev_schedule_id           IN    NUMBER      REQUIRED
-- p_inv_schedule_id           IN    NUMBER      REQUIRED
-- p_nlbr_bill_rate_org_id     IN    NUMBER      REQUIRED
-- p_nlbr_std_bill_rate_sch    IN    VARCHAR2    REQUIRED
-- x_error_msg_code            OUT   VARCHAR2    REQUIRED
-- x_return_status             OUT   VARCHAR2    REQUIRED
--
--  History
--
--  06-JUN-01   Majid Ansari             -Created
--
--

PROCEDURE CHECK_BILL_INFO_REQ(
   p_project_type_class_code       IN VARCHAR2,
   p_lbr_schedule_type             IN VARCHAR2,
   p_non_lbr_schedule_type         IN VARCHAR2,
   p_emp_bill_rate_sch_id          IN NUMBER,
   p_job_bill_rate_sch_id          IN NUMBER,
   p_rev_schedule_id               IN NUMBER,
   p_inv_schedule_id               IN NUMBER,
   p_nlbr_bill_rate_org_id         IN NUMBER,
   p_nlbr_std_bill_rate_sch        IN VARCHAR2,
   x_error_msg_code               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_return_status                OUT NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
 );



-- API name                      : CHECK_LABOR_MULTIPLIER_REQ
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_labor_multiplier              IN NUMBER,
-- p_effective_from_date           IN VARCHAR2,
-- x_error_msg_code                OUT   VARCHAR2    REQUIRED
-- x_return_status                 OUT   VARCHAR2    REQUIRED
--
--  History
--
--  06-JUN-01   Majid Ansari             -Created
--
--

PROCEDURE CHECK_LABOR_MULTIPLIER_REQ(
   p_labor_multiplier              IN NUMBER,
   p_effective_from_date           IN DATE,
   x_error_msg_code                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_return_status                 OUT NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
 );


-- API name                      : CHECK_START_END_DATE
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_effective_from_date           IN  DATE        REQUIRED
-- p_effective_to_date             IN  DATE        REQUIRED
-- x_msg_count                     OUT NUMBER      REQUIRED
-- x_msg_data                      OUT VARCHAR2    REQUIRED
-- x_return_status                 OUT VARCHAR2    REQUIRED
--
--  History
--
--  06-JUN-01   Majid Ansari             -Created
--
--

PROCEDURE CHECK_START_END_DATE(
   p_effective_from_date           IN DATE,
   p_effective_to_date             IN DATE,
   x_return_status                 OUT NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
   x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) ;

END PA_BILLING_SCHEDULE_UTILS;

 

/
