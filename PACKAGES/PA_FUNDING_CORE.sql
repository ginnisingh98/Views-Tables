--------------------------------------------------------
--  DDL for Package PA_FUNDING_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FUNDING_CORE" AUTHID CURRENT_USER AS
/* $Header: PAXBIPFS.pls 120.2 2007/02/07 10:44:06 rgandhi ship $ */

--  FUNCTION  check_fund_allocate will see if any funds have been allocated
--  for an agreement

	FUNCTION  check_fund_allocated
	( p_agreement_id			IN	NUMBER
 	) RETURN VARCHAR2 ;

--  FUNCTION  check_accrued_billed_baselined will ensure that the Total amount allocated is
--  not less than amount accrued or billed, as User must allocate enough funds to cover the
--  revenue which has already been accrued and/or billed against the allocated funding.

	FUNCTION  check_accrued_billed_baselined
	( p_agreement_id			IN	NUMBER
 	 ,p_project_id		                IN	NUMBER
	 ,p_task_id				IN	NUMBER
	 ,p_amount				IN	NUMBER
	) RETURN VARCHAR2 ;
/*
--  FUNCTION  chk_proj_task_lvl_funding will ensure that user cannot change to project-level
--  funding when task-level events exist, or if revenue has been distributed.

	FUNCTION  chk_proj_task_lvl_funding
	( p_agreement_id			IN	NUMBER
	) RETURN VARCHAR2 ;
*/
--  FUNCTION  check_valid_project will check for valid Project ID for given
--  Customer ID .

	FUNCTION  check_valid_project
	( p_customer_id            		IN	NUMBER,
          p_project_id				IN	NUMBER,
	  p_agreement_id                        IN      NUMBER /*Federal*/
	) RETURN VARCHAR2 ;

--  FUNCTION  get_funding_id will return the funding id for a given
--  funding reference
FUNCTION get_funding_id
	( p_funding_reference		IN 	VARCHAR2
 	) RETURN NUMBER ;

--  FUNCTION  check_project_template will check for weather the project
--  for which funding is to be created is a TEMPLATE or a PROJECT
--  In the case of TEMPLATE then the following conditions have to be met.
--  (1) It can have only customer and Cutomer_Bill_Split should be exactly 100 %
--  (2) It can be only funded by single agreement.

	FUNCTION  check_project_template
	( p_project_id            		IN	NUMBER
	) RETURN VARCHAR2 ;

--  FUNCTION  check_valid_task will check for a valid task against pa_top_tasks
--  as funding can only be entered against top tasks for given project_id.

	FUNCTION  check_valid_task
	( p_project_id 				IN 	NUMBER
 	 ,p_task_id        			IN      NUMBER
	) RETURN VARCHAR2 ;

--  FUNCTION  check_task_fund_allowed will that Project level funding is not entered when
--  task level funding exists as You must either fund at the project level or at the task level.


	FUNCTION  check_task_fund_allowed
	( p_project_id        			IN 	NUMBER
	) RETURN VARCHAR2 ;

--  FUNCTION  check_project_fund_allowed will ensure that Task funding with project level
--  events is not allowed.

	FUNCTION  check_project_fund_allowed
	( p_project_id        			IN 	NUMBER
	, p_task_id				In	NUMBER
	) RETURN VARCHAR2 ;


--  FUNCTION  validate_level_change will validate for level change in Funding
--  for eg from Project level to task level or vice-versa.

        FUNCTION validate_level_change
        ( p_project_id                          IN      NUMBER
         ,p_task_id                             IN      NUMBER
        ) RETURN VARCHAR2;


--  FUNCTION  check_level_change will check weather funding level has changed
--  for eg from Project level to task level or vice-versa if changed then will
--  call validate_level_change.

        FUNCTION check_level_change
        ( p_agreement_id                        IN      NUMBER
         ,p_project_id                          IN      NUMBER
         ,p_task_id                             IN      NUMBER
        ) RETURN VARCHAR2;

--  FUNCTION  check_proj_task_lvl_funding will check weather funding level has changed
--  by calling check_level_change and finally return "Y" if allowed to fund the projects
--  at entered level.

        FUNCTION check_proj_task_lvl_funding
        (  p_agreement_id                       IN      NUMBER
         , p_project_id                         IN      NUMBER
         , p_task_id                            IN      NUMBER
        ) RETURN VARCHAR2;

--  FUNCTION check if it is ok to fund a project from the given agreement
-- /* added function bug 2756047 */
FUNCTION  check_proj_agr_fund_ok
        (  p_agreement_id                       IN      NUMBER
          ,p_project_id                         IN      NUMBER
        ) RETURN VARCHAR2;

--  FUNCTION  check_project_type will check for the project type of project_id
--  wnd will ensure that the project is of 'CONTRACT' type.

	FUNCTION  check_project_type
	( p_project_id        			IN 	NUMBER
	) RETURN VARCHAR2 ;


  PROCEDURE create_funding(
	    p_Rowid                   IN OUT NOCOPY VARCHAR2, /*File.sql.39*/
            p_Project_Funding_Id      IN OUT NOCOPY NUMBER, /*File.sql.39*/
            p_Last_Update_Date	      IN     DATE,
            p_Last_Updated_By	      IN     NUMBER,
            p_Creation_Date	      IN     DATE,
            p_Created_By	      IN     NUMBER,
            p_Last_Update_Login	      IN     NUMBER,
            p_Agreement_Id	      IN     NUMBER,
            p_Project_Id	      IN     NUMBER,
            p_Task_id		      IN     NUMBER,
            p_Budget_Type_Code	      IN     VARCHAR2,
            p_Allocated_Amount	      IN     NUMBER,
            p_Date_Allocated	      IN     DATE,
	    p_Control_Item_ID	      IN     NUMBER DEFAULT NULL,	-- FP_M added
            p_Attribute_Category      IN     VARCHAR2,
            p_Attribute1	      IN     VARCHAR2,
            p_Attribute2	      IN     VARCHAR2,
            p_Attribute3	      IN     VARCHAR2,
            p_Attribute4	      IN     VARCHAR2,
            p_Attribute5	      IN     VARCHAR2,
            p_Attribute6	      IN     VARCHAR2,
            p_Attribute7	      IN     VARCHAR2,
            p_Attribute8	      IN     VARCHAR2,
            p_Attribute9	      IN     VARCHAR2,
            p_Attribute10	      IN     VARCHAR2,
            p_pm_funding_reference    IN     VARCHAR2,
            p_pm_product_code	      IN     VARCHAR2,
	    p_project_rate_type	      IN     VARCHAR2	DEFAULT NULL,
	    p_project_rate_date	      IN     DATE	DEFAULT NULL,
	    p_project_exchange_rate   IN     NUMBER	DEFAULT	NULL,
	    p_projfunc_rate_type      IN     VARCHAR2	DEFAULT NULL,
	    p_projfunc_rate_date      IN     DATE	DEFAULT NULL,
	    p_projfunc_exchange_rate  IN     NUMBER	DEFAULT	NULL,
            x_err_code                OUT    NOCOPY NUMBER, /*File.sql.39*/
            x_err_msg                 OUT    NOCOPY VARCHAR2, /*File.sql.39*/
            p_funding_category        IN     VARCHAR2     /* For Bug 2244796 */
	   );

  PROCEDURE Lock_funding(p_Project_Funding_Id IN NUMBER);

  PROCEDURE Update_funding(
	    p_Project_Funding_Id      IN     NUMBER,
            p_Last_Update_Date	      IN     DATE,
            p_Last_Updated_By	      IN     NUMBER,
            p_Last_Update_Login	      IN     NUMBER,
            p_Agreement_Id	      IN     NUMBER,
            p_Project_Id	      IN     NUMBER,
            p_Task_id		      IN     NUMBER,
            p_Budget_Type_Code	      IN     VARCHAR2,
            p_Allocated_Amount	      IN     NUMBER,
            p_Date_Allocated	      IN     DATE,
            p_Attribute_Category      IN     VARCHAR2,
            p_Attribute1	      IN     VARCHAR2,
            p_Attribute2	      IN     VARCHAR2,
            p_Attribute3	      IN     VARCHAR2,
            p_Attribute4	      IN     VARCHAR2,
            p_Attribute5	      IN     VARCHAR2,
            p_Attribute6	      IN     VARCHAR2,
            p_Attribute7	      IN     VARCHAR2,
            p_Attribute8	      IN     VARCHAR2,
            p_Attribute9	      IN     VARCHAR2,
            p_Attribute10	      IN     VARCHAR2,
            p_pm_funding_reference    IN     VARCHAR2,
            p_pm_product_code	      IN     VARCHAR2,
	    p_project_rate_type	      IN     VARCHAR2	DEFAULT NULL,
	    p_project_rate_date	      IN     DATE	DEFAULT NULL,
	    p_project_exchange_rate   IN     NUMBER	DEFAULT	NULL,
	    p_projfunc_rate_type      IN     VARCHAR2	DEFAULT NULL,
	    p_projfunc_rate_date      IN     DATE	DEFAULT NULL,
	    p_projfunc_exchange_rate  IN     NUMBER	DEFAULT	NULL,
            x_err_code                OUT    NOCOPY NUMBER,/*File.sql.39*/
            x_err_msg                 OUT    NOCOPY VARCHAR2,/*File.sql.39*/
            p_funding_category        IN     VARCHAR2   /* For Bug2244796 */
				);

  PROCEDURE Delete_funding(p_Project_Funding_Id  IN NUMBER);

PROCEDURE summary_funding_update_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 ,p_budget_type_code		IN	VARCHAR2
 );

PROCEDURE summary_funding_insert_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 ,p_budget_type_code		IN	VARCHAR2
 );

PROCEDURE summary_funding_delete_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 ,p_budget_type_code		IN	VARCHAR2
 );

---------------------------------------------------------------
-- This function returns Funding Amount for a project,task
---------------------------------------------------------------

FUNCTION Get_Funding(	p_project_id	IN	NUMBER,
			p_task_id	IN	NUMBER DEFAULT NULL,
			p_budget_type	IN	VARCHAR2) RETURN NUMBER;

---------------------------------------------------------------
FUNCTION check_valid_exch_rate (
         p_funding_currency_code         IN     VARCHAR2,
         p_to_currency_code              IN     VARCHAR2,
         p_exchange_rate_type            IN     VARCHAR2,
         p_exchange_rate                 IN     NUMBER,
         p_exchange_rate_date            IN     DATE) RETURN VARCHAR2;

PROCEDURE   get_MCB2_attributes (
 	    p_project_id		IN	NUMBER,
	    p_agreement_id		IN	NUMBER,
	    p_date_allocated		IN	DATE,
	    p_allocated_amount		IN	NUMBER,
            p_funding_currency_code	IN OUT  NOCOPY VARCHAR2,/*File.sql.39*/
	    p_project_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
      	    p_project_rate_type		IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_project_rate_date		IN OUT  NOCOPY DATE,/*file.sql.39*/
	    p_project_exchange_rate	IN OUT  NOCOPY NUMBER,/*file.sql.39*/
	    p_project_allocated_amount	IN OUT  NOCOPY NUMBER,/*file.sql.39*/
	    p_projfunc_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_projfunc_rate_type	IN OUT	NOCOPY VARCHAR2,     /*file.sql.39*/
	    p_projfunc_rate_date	IN OUT	NOCOPY DATE,/*file.sql.39*/
	    p_projfunc_exchange_rate	IN OUT	NOCOPY NUMBER,/*file.sql.39*/
	    p_projfunc_allocated_amount	IN OUT	NOCOPY NUMBER,/*file.sql.39*/
            p_invproc_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
            p_invproc_rate_type		IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_invproc_rate_date		IN OUT  NOCOPY DATE,/*file.sql.39*/
	    p_invproc_exchange_rate	IN OUT  NOCOPY NUMBER,/*file.sql.39*/
	    p_invproc_allocated_amount	IN OUT	NOCOPY NUMBER,/*file.sql.39*/
	    p_revproc_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
            p_revproc_rate_type		IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_revproc_rate_date		IN OUT  NOCOPY DATE,/*file.sql.39*/
	    p_revproc_exchange_rate	IN OUT  NOCOPY NUMBER,/*file.sql.39*/
	    p_revproc_allocated_amount	IN OUT	NOCOPY NUMBER,/*file.sql.39*/
            p_validate_parameters       IN      VARCHAR2 DEFAULT 'N',
            x_err_code                  OUT     NOCOPY NUMBER,/*file.sql.39*/
            x_err_msg                   OUT     NOCOPY VARCHAR2/*file.sql.39*/
	    ) ;
FUNCTION  check_proj_task_lvl_funding_fp
        (  p_agreement_id                       IN      NUMBER
          ,p_project_id                         IN      NUMBER
          ,p_task_id                            IN      NUMBER
        ) RETURN VARCHAR2;

-- Added for FP_M changes
  PROCEDURE create_funding_CO(
	    p_Rowid                   IN OUT NOCOPY VARCHAR2, /*File.sql.39*/
            p_Project_Funding_Id      IN OUT NOCOPY NUMBER, /*File.sql.39*/
            p_Last_Update_Date	      IN     DATE,
            p_Last_Updated_By	      IN     NUMBER,
            p_Creation_Date	      IN     DATE,
            p_Created_By	      IN     NUMBER,
            p_Last_Update_Login	      IN     NUMBER,
            p_Agreement_Id	      IN     NUMBER,
            p_Project_Id	      IN     NUMBER,
            p_Task_id		      IN     NUMBER,
            p_Budget_Type_Code	      IN     VARCHAR2,
            p_Allocated_Amount	      IN     NUMBER,
            p_Date_Allocated	      IN     DATE,
	    P_Funding_Currency_Code   IN     VARCHAR2,   	     -- FP_M  CI changes
	    p_Control_Item_ID	      IN     NUMBER DEFAULT NULL,    -- FP_M changes
            p_Attribute_Category      IN     VARCHAR2,
            p_Attribute1	      IN     VARCHAR2,
            p_Attribute2	      IN     VARCHAR2,
            p_Attribute3	      IN     VARCHAR2,
            p_Attribute4	      IN     VARCHAR2,
            p_Attribute5	      IN     VARCHAR2,
            p_Attribute6	      IN     VARCHAR2,
            p_Attribute7	      IN     VARCHAR2,
            p_Attribute8	      IN     VARCHAR2,
            p_Attribute9	      IN     VARCHAR2,
            p_Attribute10	      IN     VARCHAR2,
            p_pm_funding_reference    IN     VARCHAR2,
            p_pm_product_code	      IN     VARCHAR2,
	    p_Project_Allocated_Amount IN    NUMBER DEFAULT 0,  -- FP_M changes
	    p_project_rate_type	      IN     VARCHAR2	DEFAULT NULL,
	    p_project_rate_date	      IN     DATE	DEFAULT NULL,
	    p_project_exchange_rate   IN     NUMBER	DEFAULT	NULL,
	    p_Projfunc_Allocated_Amount IN    NUMBER DEFAULT 0,  -- FP_M changes
	    p_projfunc_rate_type      IN     VARCHAR2	DEFAULT NULL,
	    p_projfunc_rate_date      IN     DATE	DEFAULT NULL,
	    p_projfunc_exchange_rate  IN     NUMBER	DEFAULT	NULL,
            x_err_code                OUT    NOCOPY NUMBER,/*file.sql.39*/
            x_err_msg                 OUT    NOCOPY VARCHAR2,/*file.sql.39*/
            p_funding_category        IN     VARCHAR2   /* Bug 2244796 */
                     );

	G_FUND_BASELINE_FLAG VARCHAR2(1) := 'N';

END pa_funding_core;

/
