--------------------------------------------------------
--  DDL for Package Body PA_AGREEMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AGREEMENT_UTILS" as
/*$Header: PAAFAGUB.pls 120.2 2007/02/07 10:47:24 rgandhi ship $*/

--
--Name:                 check_multi_customers
--Type:                 Function
--Description:          This function will return 'Y' IF the Project has Multiple-Customers
--                      ELSE will return 'N'
--
--
--Called subprograms:   PA_AGREEMENT_CORE.CHECK_MULTI_CUSTOMERS
--
--
--
--History:
--                      12-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION check_multi_customers
( p_project_id		                IN	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return (PA_AGREEMENT_CORE.CHECK_MULTI_CUSTOMERS(p_project_id));
END check_multi_customers;


--
--Name:                 check_contribution
--Type:                 Function
--Description:          This function will return 'Y' IF the Project has Multiple-Customers
--                      ELSE will return 'N'
--
--
--Called subprograms:   PA_AGREEMENT_CORE.CHECK_CONTRIBUTION
--
--
--
--History:
--                      12-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_contribution
( p_agreement_id			IN	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return (PA_AGREEMENT_CORE.CHECK_CONTRIBUTION(p_agreement_id));
END check_contribution;

--
--Name:			check_fund_allocated
--Type:			Function
--Description:		This function will return 'Y' IF funds have been allocated to the
--			passed agreement ELSE will return 'N'
--
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_FUND_ALLOCATED
--
--
--
--History:
--    			16-APR-2000	Created		Nikhil Mishra
--

FUNCTION check_fund_allocated
( p_agreement_id			IN	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
-- dbms_output.put_line('Inside:PA_AGREEMENT_UTILS.CHECK_FUND_ALLOCATED');
return (PA_FUNDING_CORE.CHECK_FUND_ALLOCATED (	p_agreement_id));
END check_fund_allocated;


--
--Name:                 check_accrued_billed_baselined
--Type:                 Function
--Description:          This function will return 'Y'
--			Total amount of funds allocated is less than amount accrued or billed.
--			ELSE will return 'N' for given Projet_id, agreement_id, task_id and fund amount.
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_ACCRUED_BILLED_BASELINED
--
--History:
--                      16-APR-2000     Created         Nikhil Mishra.

FUNCTION accrued_billed_baselined
( p_agreement_id			IN	NUMBER
  ,p_project_id			        IN	NUMBER
  ,p_task_id			        IN	NUMBER
  ,p_amount			        IN	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return(PA_FUNDING_CORE.CHECK_ACCRUED_BILLED_BASELINED(	p_agreement_id
							,p_project_id
							,p_task_id
							,p_amount));
END accrued_billed_baselined;


--
--Name:                 check_proj_arg_fund_ok
--Type:                 Function
--Description:          This function will return 'Y' if it is ok to fund a project from the
--                      given agreement else 'N'
--Called subprograms:   None
--
--
--History:
--                      24-JAN-2003     Created         Puneet  Rastogi.
--
/* added function Bug 2756047 */
FUNCTION  check_proj_agr_fund_ok
        (  p_agreement_id                       IN      NUMBER
          ,p_project_id                         IN      NUMBER
        ) RETURN VARCHAR2
is

    Is_agr_fund_ok  varchar2(1) := 'N';

BEGIN
   --dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_PROJ_AGR_FUND_OK');

     Is_agr_fund_ok := Pa_funding_core.check_proj_agr_fund_ok( p_agreement_id, p_project_id);

   --dbms_output.put_line('Outside: PA_AGREEMENT_UTILS.CHECK_PROJ_AGR_FUND_OK');

    RETURN Is_agr_fund_ok;

END check_proj_agr_fund_ok;


--
--Name:                 check_proj_task_lvl_funding
--Type:                 Function
--Description:          This function will return variour  values. the interpretation of those
--			is as follows
--			"A" IF user is entering Project Level Funding when task level funding exists
--			Or IF the revenue have been distributed. Message is PA_PROJ_FUND_NO_TASK_TRANS
--			"P" IF user in entering task level funding when project level funding exists
--			Message is PA_BU_PROJECT_ALLOC_ONLY
--			"T" IF user is allocating funding at Project level when Top task level
--			funding exists. Message is PA_BU_TASK_ALLOC_ONLY
--			"B" IF user change to task-level funding when project-level events exist,
--			or IF Revenue has been distributed. Message is PA_TASK_FUND_NO_PROJ_TRANS
--Called subprograms:   PA_FUNDING_CORE.CHECK_PROJ_TASK_LVL_FUNDING
--
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_proj_task_lvl_funding
(  p_project_id			 IN	NUMBER
  ,p_task_id                     IN     NUMBER
  ,p_agreement_id                IN	NUMBER
)
RETURN VARCHAR2
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_PROJ_TASK_LVL_FUNDING');
return(PA_FUNDING_CORE.CHECK_PROJ_TASK_LVL_FUNDING(p_agreement_id
							,p_project_id
							,p_task_id));
END check_proj_task_lvl_funding;

/*added for fin plan on billing*/
FUNCTION check_proj_task_lvl_funding_fp
(  p_project_id                  IN     NUMBER
  ,p_task_id                     IN     NUMBER
  ,p_agreement_id                IN     NUMBER
)
RETURN VARCHAR2
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_PROJ_TASK_LVL_FUNDING_FP');
return(PA_FUNDING_CORE.CHECK_PROJ_TASK_LVL_FUNDING_FP(p_agreement_id
                                                        ,p_project_id
                                                        ,p_task_id));
END check_proj_task_lvl_funding_fp;

--
--Name:                 Validate_Level_Change
--Type:                 Function
--Description:          This function will return 'Y' IF the funding level change is a valid one.
--                      ELSE will return 'N'
--			this can be done by checking
--			(1) Any expEND iture item is revenue distributed ?
--			(2) Any event is revenue distributed?
--			(3) Any event is billed ??
--
--Called subprograms:   PA_FUNDING_CORE.VALIDATE_LEVEL_CHANGE
--
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION validate_level_change
( p_project_id			IN	NUMBER
  ,p_task_id			IN	NUMBER
)
RETURN VARCHAR2
IS
BEGIN
return(PA_FUNDING_CORE.VALIDATE_LEVEL_CHANGE(	p_project_id
						,p_task_id));
END validate_level_change;

--
--Name:                 check_level_change
--Type:                 Function
--Description:          This function will return 'Y' IF the funding level has been changed.
--                      and the chenged level is a valis one. this can be done by
--			calling validate_level_change
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_LEVEL_CHANGE
--
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_level_change
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return(PA_FUNDING_CORE.CHECK_LEVEL_CHANGE(p_agreement_id
					    ,p_project_id
					    ,p_task_id));

END check_level_change;

--
--Name:                 check_valid_customer
--Type:                 Function
--Description:          This function will return variour  values. the interpretation of those
--                      is as follows
--                      "A" Then this user is not a registered employee and he is not allowed to
--			create agreement. Message is PA_ALL_WARN_NO_EMPL_REC
--                      "Y"  for valid customer
--Called subprograms:    PA_AGREEMENT_CORE.CHECK_VALID_CUSTOMER
--
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_valid_customer
(p_customer_id 		        IN 	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_VALID_CUSTOMER');
-- dbms_output.put_line('Customer_id: '||nvl(to_char(p_customer_id),'NULL'));
return(PA_AGREEMENT_CORE.CHECK_VALID_CUSTOMER(p_customer_id));
END check_valid_customer;

--
--Name:                 check_valid_type
--Type:                 Function
--Description:		Will return Y IF agreement type is valid ELSE return N.
--Called subprograms:   PA_AGREEMENT_CORE.CHECK_VALID_TYPE
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION check_valid_type
(p_agreement_type       IN 	VARCHAR2
 )
RETURN VARCHAR2
IS
BEGIN
return(PA_AGREEMENT_CORE.CHECK_VALID_TYPE(p_agreement_type));
END check_valid_type;

--
--Name:                 check_valid_term_id
--Type:                 Function
--Description:          This function will return 'Y' IF the Term Id is valid
--                      ELSE will return 'N'
--
--Called subprograms:   PA_AGREEMENT_CORE.CHECK_VALID_TERM_ID
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_valid_term_id
(p_term_id        		IN 	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return(PA_AGREEMENT_CORE.CHECK_VALID_TERM_ID(p_term_id));
END check_valid_term_id;

--
--Name:                 check_valid_owned_by_person_id
--Type:                 Function
--Description:          This function will return 'Y' IF the Person_id is valid
--                      ELSE will return 'N'
--
--Called subprograms:   PA_AGREEMENT_CORE.CHECK_VALID_OWNED_BY_PERSON_ID
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION check_valid_owned_by_person_id
(p_owned_by_person_id        		IN 	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return(PA_AGREEMENT_CORE.CHECK_VALID_OWNED_BY_PERSON_ID(p_owned_by_person_id));
END check_valid_owned_by_person_id;

--
--Name:                 check_unique_agreement
--Type:                 Function
--Description:          This function will return 'Y' IF the combination of
--			Agreement_Number, Agreement_type, Customer is unique
--                      ELSE will return 'N' Message is PA_BU_AGRMNT_NOT_UNIQUE
--
--Called subprograms:   PA_AGREEMENT_CORE.CHECK_UNIQUE_AGREEMENT
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_unique_agreement
(p_agreement_num        		IN 	VARCHAR2
 ,p_agreement_type                      IN      VARCHAR2
 ,p_customer_id                         IN      NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return(PA_AGREEMENT_CORE.CHECK_UNIQUE_AGREEMENT(p_agreement_num
						,p_agreement_type
						,p_customer_id ));
END check_unique_agreement;


--
--Name:                 check_valid_agreement_ref
--Type:                 Function
--Description:          This function will return 'Y' IF the Agreement_reference
--			is valid
--                      ELSE will return 'N'
--
--Called subprograms: none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra
--

FUNCTION check_valid_agreement_ref
	(p_agreement_reference           	IN	VARCHAR2
	)
RETURN VARCHAR2
IS
BEGIN
-- dbms_output.put_line('PA_AGREEMENT_UTILS.CHECK_VALID_AGREEMENT_REF');
RETURN(PA_AGREEMENT_CORE.CHECK_VALID_AGREEMENT_REF(p_agreement_reference));
END check_valid_agreement_ref;

--
--Name:                 check_valid_agreement_id
--Type:                 Function
--Description:          This function will return 'Y' IF the Agreement_Id
--			is valid
--                      ELSE will return 'N'
--
--Called subprograms: none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra
--

FUNCTION check_valid_agreement_id
	(p_agreement_id           	IN	NUMBER
	)
RETURN VARCHAR2
IS
BEGIN
RETURN(PA_AGREEMENT_CORE.CHECK_VALID_AGREEMENT_ID(p_agreement_id));
END check_valid_agreement_id;



--
--Name:                 check_valid_funding_ref
--Type:                 Function
--Description:          This function will return 'Y' IF the funding_reference
--			is valid
--                      ELSE will return 'N'
--
--Called subprograms: none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra
--

FUNCTION check_valid_funding_ref
	(p_funding_reference           		IN	VARCHAR2
	,p_agreement_id				IN	NUMBER
	)
RETURN VARCHAR2
IS

BEGIN
-- dbms_output.put_line(' Inside: PA_AGREEMENT_UTILS.CHECK_VALID_FUNDING_REF');
RETURN(PA_AGREEMENT_CORE.CHECK_VALID_FUNDING_REF(	p_funding_reference
					,p_agreement_id	));
END check_valid_funding_ref;

--
--Name:                 check_valid_funding_id
--Type:                 Function
--Description:          This function will return 'Y' IF the funding_Id
--			is valid
--                      ELSE will return 'N'
--
--Called subprograms: none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra
--

FUNCTION check_valid_funding_id
	(p_agreement_id           		IN	NUMBER
	,p_funding_id           		IN	NUMBER
	)
RETURN VARCHAR2
IS

BEGIN
RETURN(PA_AGREEMENT_CORE.CHECK_VALID_FUNDING_ID(p_agreement_id
						,p_funding_id));
END check_valid_funding_id;

--
--Name:                 validate_agreement_amount
--Type:                 Function
--Description:          This function will return 'Y' IF the Agreement amount enetered
--			is valid i.e. the amount entered should always be greater than
--			total baselined and unbaselined amount for that agreement_id;
--			IF returning 'N' indicating invalid amount then message is
--			PA_BU_AMOUNT_NOT_UPDATEABLE
--
--Called subprograms:   PA_AGREEMENT_CORE.VALIDATE_AGREEMENT_AMOUNT
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION validate_agreement_amount
(p_agreement_id        		        IN 	NUMBER
 ,p_amount                              IN      NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return(PA_AGREEMENT_CORE.VALIDATE_AGREEMENT_AMOUNT(p_agreement_id
						,p_amount));

END validate_agreement_amount;

--
--Name:                 check_add_update
--Type:                 FUNCTION
--Description:          This function will return 'U' if update is required or 'A' if insert is required .
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_add_update
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN VARCHAR2
IS
BEGIN
RETURN(PA_AGREEMENT_CORE.CHECK_ADD_UPDATE(	p_funding_id
						,p_funding_reference));

END check_add_update;

--
--Name:                 get_agreement_id
--Type:                 FUNCTION
--Description:          This function will return  the corresponding agreement_id for the funding_id or funding _reference given
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION get_agreement_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.GET_AGREEMENT_ID');
-- dbms_output.put_line(' Returning: '||to_char(PA_AGREEMENT_CORE.GET_AGREEMENT_ID(p_funding_id,p_funding_reference)));
RETURN(PA_AGREEMENT_CORE.GET_AGREEMENT_ID(p_funding_id
					,p_funding_reference));
END get_agreement_id;

--
--Name:                 get_funding_id
--Type:                 FUNCTION
--Description:          This function will return  the corresponding funding_id for the funding_id given
--			the funding _reference
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION get_funding_id
	( p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.GET_FUNDING_ID');
-- dbms_output.put_line(' Returning: '||to_char(PA_FUNDING_CORE.GET_FUNDING_ID(p_funding_reference)));
RETURN(PA_FUNDING_CORE.GET_FUNDING_ID(p_funding_reference));
END get_funding_id;

--
--Name:                 get_customer_id
--Type:                 FUNCTION
--Description:          This function will return the corresponding customer_id for the funding_id or funding_reference given
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION get_customer_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.GET_CUSTOMER_ID');
RETURN(PA_AGREEMENT_CORE.GET_CUSTOMER_ID(p_funding_id
					,p_funding_reference));
END get_customer_id;



--
--Name:                 get_project_id
--Type:                 FUNCTION
--Description:          This procedure will get the corresponding project_id for the funding_id or funding _reference given
--
--Called subprograms:   PA_AGREEMENT_CORE.GET_PROJECT_ID
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION get_project_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS

BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.GET_PROJECT_ID');
RETURN(PA_AGREEMENT_CORE.GET_PROJECT_ID(p_funding_id
					,p_funding_reference));
END get_project_id;


--
--Name:                 get_task_id
--Type:                 FUNCTION
--Description:          This function will get the corresponding task_id for the funding_id or funding _reference given
--
--Called subprograms:   PA_AGREEMENT_CORE.GET_TASK_ID
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION get_task_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS

BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.GET_TASK_ID');
RETURN(PA_AGREEMENT_CORE.GET_TASK_ID(	p_funding_id
					,p_funding_reference));
END get_task_id;
--
--Name:                 summary_funding_insert_row
--Type:                 Procedure
--Description:          This procedure inserts row(s) in to PA_SUMMARY_PROJECT_FUNDINGS.
--
--Called subprograms	PA_FUNDING_CORE.SUMMARY_FUNDING_INSERT_ROW
--
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

PROCEDURE summary_funding_insert_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 )
IS
BEGIN
PA_FUNDING_CORE.SUMMARY_FUNDING_INSERT_ROW(	p_agreement_id
 ,p_project_id
 ,p_task_id
 ,p_login_id
 ,p_user_id
 ,'DRAFT');
END summary_funding_insert_row;



--Name:                 summary_funding_update_row
--Type:                 Procedure
--Description:          This procedure updates row(s) in to PA_SUMMARY_PROJECT_FUNDINGS.
--
--Called subprograms: PA_FUNDING_CORE.SUMMARY_FUNDING_UPDATE_ROW
--
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--
PROCEDURE summary_funding_update_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 )
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.SUMMARY_FUNDING_UPDATE_ROW');
PA_FUNDING_CORE.SUMMARY_FUNDING_UPDATE_ROW(	p_agreement_id
 ,p_project_id
 ,p_task_id
 ,p_login_id
 ,p_user_id
 ,'DRAFT');
END summary_funding_update_row;

--
--Name:		summary_funding_delete_row
--Type: 		Procedure
--Description:	This procedure deletes row(s) in to PA_SUMMARY_PROJECT_FUNDINGS.
--
--Called subprograms:  PA_FUNDING_CORE.SUMMARY_FUNDING_DELETE_ROW
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--
PROCEDURE summary_funding_delete_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 )
IS
BEGIN
PA_FUNDING_CORE.SUMMARY_FUNDING_DELETE_ROW(	p_agreement_id
,p_project_id
 ,p_task_id
,p_login_id
 ,p_user_id
,'DRAFT');
END summary_funding_delete_row;
--
--Name:                 check_valid_project
--Type:                 Function
--Description:          This function will return 'Y'
--                       IF the project is a valid project ELSE will return 'N'
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_VALID_PROJECT
--
--History:
-- 10-SEP-01 : added new param project_id srividya

FUNCTION check_valid_project
   (p_customer_id  IN	NUMBER,
    p_project_id  IN	NUMBER,
    p_agreement_id IN   NUMBER) /*Federal*/
RETURN VARCHAR2 IS
BEGIN

-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_VALID_PROJECT');
-- dbms_output.put_line('Customer_id: '||nvl(to_char(p_customer_id),'NULL'));

return(PA_FUNDING_CORE.CHECK_VALID_PROJECT(
        p_customer_id => p_customer_id,
        p_project_id => p_project_id,
	p_agreement_id => p_agreement_id));

END check_valid_project;


--
--Name:                 check_valid_task
--Type:                 Function
--Description:          This function will return 'Y'
--                       IF the task is a valid task for project_id passed ELSE will return 'N'
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_VALID_TASK
--
--History:
--                      16-APR-2000     Created         Nikhil Mishra.



FUNCTION check_valid_task
(p_project_id 		 IN 	NUMBER
 ,p_task_id              IN     NUMBER
)
RETURN VARCHAR2
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_VALID_TASK');
return(PA_FUNDING_CORE.CHECK_VALID_TASK(p_project_id
					,p_task_id));

END check_valid_task;

--
--Name:                 check_project_type
--Type:                 Function
--Description:          This function will return 'Y'
--                      IF the Project Type is "CONTRACT" ELSE will return 'N'
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_PROJECT_TYPE
--
--History:
--                      16-APR-2000     Created         Nikhil Mishra.


FUNCTION check_project_type
(p_project_id 		 IN 	NUMBER
)
RETURN VARCHAR2
IS
BEGIN
return(PA_FUNDING_CORE.CHECK_PROJECT_TYPE(p_project_id));
END check_project_type;

--
--Name:                 check_funding_level
--Type:                 Function
--Description:          This function will return 'Y' IF the funding level has been changed.
--                      and the chenged level is a valis one. this can be done by
--			calling validate_level_change
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_LEVEL_CHANGE
--
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION check_funding_level
(p_agreement_id         IN	NUMBER
 ,p_project_id 		IN 	NUMBER
 ,p_task_id		IN	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
return(PA_FUNDING_CORE.CHECK_LEVEL_CHANGE(p_agreement_id
					 ,p_project_id
					 ,p_task_id));
END check_funding_level;

--
--Name:                 check_invoice_exists
--Type:                 Function
--Description:          Will return Y IF invoices exists for given agreement ELSE return N
--
--Called subprograms:   PA_AGREEMENT_CORE.CHECK_INVOICE_EXISTS
--
--
--History:
--                      05-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_invoice_exists
	( p_agreement_id        		IN 	NUMBER)
RETURN VARCHAR2
IS
BEGIN
RETURN (PA_AGREEMENT_CORE.CHECK_INVOICE_EXISTS( p_agreement_id));
END  check_invoice_exists;


--Name:                 check_budget_type
--Type:                 Function
--Description:          This function will return 'Y' IF the Project has budget_type_code as 'DRAFT'
--                      ELSE will return 'N'
--
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_BUDGET_TYPE
--
--
--
--History:
--                      12-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION check_budget_type
( p_funding_id		                IN	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_BUDGET_TYPE');
return (PA_AGREEMENT_CORE.CHECK_BUDGET_TYPE(p_funding_id));
END  check_budget_type;

--Name:                 check_revenue_type
--Type:                 Function
--Description:          This function will return 'Y' IF the revenue limit of theagreemnet is in the permissible limts
--                      ELSE will return 'N'
--
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_REVENUE_LIMIT
--
--
--
--History:
--                      12-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION check_revenue_limit
( p_agreement_id		                IN	NUMBER
 )
RETURN VARCHAR2
IS
BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_REVENUE_LIMIT');
return (PA_AGREEMENT_CORE.CHECK_REVENUE_LIMIT(p_agreement_id));
END  check_revenue_limit;


--
--Name:                 create_agreement
--Type:                 PROCEDURE
--Description:          This procedure will insert one row in to PA_AGREEMENTS_ALL
--
--Called subprograms:   PA_AGREEMENT_CORE.CREATE_AGREEMENT
--
--
--History:
--     15-MAY-2000     Created         Nikhil Mishra.
--     07-SEP-2001     Modified        Srividya
--                                     added mcb2 columns
--
PROCEDURE create_agreement(
           p_Rowid                   IN OUT NOCOPY VARCHAR2, /*File.sql.39*/
           p_Agreement_Id                   IN OUT NOCOPY NUMBER,/*File.sql.39*/
           p_Customer_Id                    IN NUMBER,
           p_Agreement_Num                  IN VARCHAR2,
           p_Agreement_Type                 IN VARCHAR2,
           p_Last_Update_Date               IN DATE,
           p_Last_Updated_By                IN NUMBER,
           p_Creation_Date                  IN DATE,
           p_Created_By                     IN NUMBER,
           p_Last_Update_Login              IN NUMBER,
           p_Owned_By_Person_Id             IN NUMBER,
           p_Term_Id                        IN NUMBER,
           p_Revenue_Limit_Flag             IN VARCHAR2,
           p_Amount                         IN NUMBER,
           p_Description                    IN VARCHAR2,
           p_Expiration_Date                IN DATE,
           p_Attribute_Category             IN VARCHAR2,
           p_Attribute1                     IN VARCHAR2,
           p_Attribute2                     IN VARCHAR2,
           p_Attribute3                     IN VARCHAR2,
           p_Attribute4                     IN VARCHAR2,
           p_Attribute5                     IN VARCHAR2,
           p_Attribute6                     IN VARCHAR2,
           p_Attribute7                     IN VARCHAR2,
           p_Attribute8                     IN VARCHAR2,
           p_Attribute9                     IN VARCHAR2,
           p_Attribute10                    IN VARCHAR2,
           p_Template_Flag                  IN VARCHAR2,
           p_pm_agreement_reference         IN VARCHAR2,
           p_pm_product_code                IN VARCHAR2,
           p_agreement_currency_code        IN VARCHAR2 DEFAULT NULL,
           p_owning_organization_id         IN NUMBER   DEFAULT NULL,
           p_invoice_limit_flag             IN VARCHAR2 DEFAULT NULL,
           p_customer_order_number          IN VARCHAR2 DEFAULT NULL,
           p_advance_required               IN VARCHAR2 DEFAULT NULL,
           p_start_date                     IN DATE     DEFAULT NULL,
           p_billing_sequence               IN NUMBER   DEFAULT NULL,
           p_line_of_account                IN VARCHAR2 DEFAULT NULL,
           p_Attribute11                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute12                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute13                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute14                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute15                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute16                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute17                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute18                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute19                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute20                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute21                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute22                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute23                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute24                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute25                    IN VARCHAR2 DEFAULT NULL)
IS
np_p_Agreement_Id Number :=p_Agreement_Id; /*file.sql.39*/
BEGIN
-- dbms_output.put_line('In UTILS - create_agreement');
PA_AGREEMENT_CORE.CREATE_AGREEMENT(
        p_rowid                         =>       p_rowid,
        p_agreement_id                  =>       p_agreement_id,
        p_customer_id                   =>       p_customer_id,
        p_agreement_num                 =>       p_agreement_num,
        p_agreement_type                =>       p_agreement_type,
        p_last_update_date              =>       p_last_update_date,
        p_last_updated_by               =>       p_last_updated_by,
        p_creation_date                 =>       p_creation_date,
        p_created_by                    =>       p_created_by,
        p_last_update_login             =>       p_last_update_login,
        p_owned_by_person_id            =>       p_owned_by_person_id,
        p_term_id                       =>       p_term_id,
        p_revenue_limit_flag            =>       p_revenue_limit_flag,
        p_amount                        =>       p_amount,
        p_description                   =>       p_description,
        p_expiration_date               =>       p_expiration_date,
        p_attribute_category            =>       p_attribute_category,
        p_attribute1                    =>       p_attribute1,
        p_attribute2                    =>       p_attribute2,
        p_attribute3                    =>       p_attribute3,
        p_attribute4                    =>       p_attribute4,
        p_attribute5                    =>       p_attribute5,
        p_attribute6                    =>       p_attribute6,
        p_attribute7                    =>       p_attribute7,
        p_attribute8                    =>       p_attribute8,
        p_attribute9                    =>       p_attribute9,
        p_attribute10                   =>       p_attribute10,
        p_template_flag                 =>       p_template_flag,
        p_pm_agreement_reference        =>       p_pm_agreement_reference,
        p_pm_product_code               =>       p_pm_product_code,
        p_owning_organization_id        =>       p_owning_organization_id,
        p_agreement_currency_code       =>       p_agreement_currency_code,
        p_invoice_limit_flag            =>       p_invoice_limit_flag,
        p_customer_order_number         =>       p_customer_order_number,
        p_advance_required              =>       p_advance_required,
        p_start_date                    =>       p_start_date,
        p_billing_sequence              =>       p_billing_sequence,
        p_line_of_account               =>       p_line_of_account,
        p_attribute11                   =>       p_attribute11,
        p_attribute12                   =>       p_attribute12,
        p_attribute13                   =>       p_attribute13,
        p_attribute14                   =>       p_attribute14,
        p_attribute15                   =>       p_attribute15,
        p_attribute16                   =>       p_attribute16,
        p_attribute17                   =>       p_attribute17,
        p_attribute18                   =>       p_attribute18,
        p_attribute19                   =>       p_attribute19,
        p_attribute20                   =>       p_attribute20,
        p_attribute21                   =>       p_attribute21,
        p_attribute22                   =>       p_attribute22,
        p_attribute23                   =>       p_attribute23,
        p_attribute24                   =>       p_attribute24,
        p_attribute25                   =>       p_attribute25
         );

/*Added EXCEPTION for file.sql.39*/
EXCEPTION
WHEN OTHERS THEN
  p_Agreement_Id := np_p_agreement_id;
  raise;

END CREATE_AGREEMENT;
--
--Name:                 lock_agreement
--Type:                 PROCEDURE
--Description:          This procedure will lock one row in to PA_AGREEMENTS_ALL
--
--Called subprograms:   PA_AGREEMENT_CORE.LOCK_AGREEMENT
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--
PROCEDURE Lock_agreement(p_Agreement_Id IN NUMBER )
IS
BEGIN
PA_AGREEMENT_CORE.LOCK_AGREEMENT(p_Agreement_Id );
END  Lock_agreement;

--
--Name:                 delete_agreement
--Type:                 PROCEDURE
--Description:          This procedure will delete one row in to PA_AGREEMENTS_ALL
--
--Called subprograms:   PA_AGREEMENT_CORE.DELETE_AGREEMENT
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

PROCEDURE Delete_agreement(p_agreement_id IN NUMBER )
IS
BEGIN
PA_AGREEMENT_CORE.DELETE_AGREEMENT(p_agreement_id);
END Delete_agreement;

--
--Name:                 update_agreement
--Type:                 PROCEDURE
--Description:          This procedure will update one row in to PA_AGREEMENTS_ALL
--
--Called subprograms:   PA_AGREEMENT_CORE.UPDATE_AGREEMENT
--
--
--History:
--   15-MAY-2000     Created         Nikhil Mishra.
--
--   07-SEP-2001     Modified        Srividya
--     Added all new columns used in MCB2

 PROCEDURE Update_agreement(
           p_Agreement_Id               IN      NUMBER,
           p_Customer_Id                IN      NUMBER,
           p_Agreement_Num              IN      VARCHAR2,
           p_Agreement_Type             IN      VARCHAR2,
           p_Last_Update_Date           IN      DATE,
           p_Last_Updated_By            IN      NUMBER,
           p_Last_Update_Login          IN      NUMBER,
           p_Owned_By_Person_Id         IN      NUMBER,
           p_Term_Id                    IN      NUMBER,
           p_Revenue_Limit_Flag         IN      VARCHAR2,
           p_Amount                     IN      NUMBER,
           p_Description                IN      VARCHAR2,
           p_Expiration_Date            IN      DATE,
           p_Attribute_Category         IN      VARCHAR2,
           p_Attribute1                 IN      VARCHAR2,
           p_Attribute2                 IN      VARCHAR2,
           p_Attribute3                 IN      VARCHAR2,
           p_Attribute4                 IN      VARCHAR2,
           p_Attribute5                 IN      VARCHAR2,
           p_Attribute6                 IN      VARCHAR2,
           p_Attribute7                 IN      VARCHAR2,
           p_Attribute8                 IN      VARCHAR2,
           p_Attribute9                 IN      VARCHAR2,
           p_Attribute10                IN      VARCHAR2,
           p_Template_Flag              IN      VARCHAR2,
           p_pm_agreement_reference     IN      VARCHAR2,
           p_pm_product_code            IN      VARCHAR2,
           p_agreement_currency_code    IN      VARCHAR2 DEFAULT NULL,
           p_owning_organization_id     IN      NUMBER  DEFAULT NULL,
           p_invoice_limit_flag         IN      VARCHAR2 DEFAULT NULL,
           p_customer_order_number          IN VARCHAR2 DEFAULT NULL,
           p_advance_required               IN VARCHAR2 DEFAULT NULL,
           p_start_date                     IN DATE     DEFAULT NULL,
           p_billing_sequence               IN NUMBER   DEFAULT NULL,
           p_line_of_account                IN VARCHAR2 DEFAULT NULL,
           p_Attribute11                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute12                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute13                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute14                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute15                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute16                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute17                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute18                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute19                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute20                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute21                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute22                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute23                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute24                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute25                    IN VARCHAR2 DEFAULT NULL)
 IS
 BEGIN
 -- dbms_output.put_line('Inside: pa_agreement_utils.update_agreement');
 PA_AGREEMENT_CORE.UPDATE_AGREEMENT(
        p_agreement_id                  =>       p_agreement_id,
        p_customer_id                   =>       p_customer_id,
        p_agreement_num                 =>       p_agreement_num,
        p_agreement_type                =>       p_agreement_type,
        p_last_update_date              =>       p_last_update_date,
        p_last_updated_by               =>       p_last_updated_by,
        p_last_update_login             =>       p_last_update_login,
        p_owned_by_person_id            =>       p_owned_by_person_id,
        p_term_id                       =>       p_term_id,
        p_revenue_limit_flag            =>       p_revenue_limit_flag,
        p_amount                        =>       p_amount,
        p_description                   =>       p_description,
        p_expiration_date               =>       p_expiration_date,
        p_attribute_category            =>       p_attribute_category,
        p_attribute1                    =>       p_attribute1,
        p_attribute2                    =>       p_attribute2,
        p_attribute3                    =>       p_attribute3,
        p_attribute4                    =>       p_attribute4,
        p_attribute5                    =>       p_attribute5,
        p_attribute6                    =>       p_attribute6,
        p_attribute7                    =>       p_attribute7,
        p_attribute8                    =>       p_attribute8,
        p_attribute9                    =>       p_attribute9,
        p_attribute10                   =>       p_attribute10,
        p_template_flag                 =>       p_template_flag,
        p_pm_agreement_reference        =>       p_pm_agreement_reference,
        p_pm_product_code               =>       p_pm_product_code,
        p_owning_organization_id        =>       p_owning_organization_id,
        p_agreement_currency_code       =>       p_agreement_currency_code,
        p_invoice_limit_flag            =>       p_invoice_limit_flag,
        p_customer_order_number         =>       p_customer_order_number,
        p_advance_required              =>       p_advance_required,
        p_start_date                    =>       p_start_date,
        p_billing_sequence              =>       p_billing_sequence,
        p_line_of_account               =>       p_line_of_account,
        p_attribute11                   =>       p_attribute11,
        p_attribute12                   =>       p_attribute12,
        p_attribute13                   =>       p_attribute13,
        p_attribute14                   =>       p_attribute14,
        p_attribute15                   =>       p_attribute15,
        p_attribute16                   =>       p_attribute16,
        p_attribute17                   =>       p_attribute17,
        p_attribute18                   =>       p_attribute18,
        p_attribute19                   =>       p_attribute19,
        p_attribute20                   =>       p_attribute20,
        p_attribute21                   =>       p_attribute21,
        p_attribute22                   =>       p_attribute22,
        p_attribute23                   =>       p_attribute23,
        p_attribute24                   =>       p_attribute24,
        p_attribute25                   =>       p_attribute25);

 END update_agreement;

--
--Name:                 create_funding
--Type:                 PROCEDURE
--Description:          This procedure is used to create a funding record in PA_PROJECT_FUNDINGS
--Called subprograms:   PA_FUNDING_CORE.CREATE_FUNDING
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--                      15-MAY-2000     Created         Nikhil Mishra
--                      07-SEP-2001     Modified        Srividya Sivaraman
--                     Added all new columns corresponding to MCB2

  PROCEDURE create_funding(
            p_Rowid                   IN OUT NOCOPY VARCHAR2,/*File.sql.39*/
            p_Project_Funding_Id      IN OUT NOCOPY NUMBER,/*File.sql.39*/
            p_Last_Update_Date        IN     DATE,
            p_Last_Updated_By         IN     NUMBER,
            p_Creation_Date           IN     DATE,
            p_Created_By              IN     NUMBER,
            p_Last_Update_Login       IN     NUMBER,
            p_Agreement_Id            IN     NUMBER,
            p_Project_Id              IN     NUMBER,
            p_Task_id                 IN     NUMBER,
            p_Allocated_Amount        IN     NUMBER,
            p_Date_Allocated          IN     DATE,
            p_Attribute_Category      IN     VARCHAR2,
            p_Attribute1              IN     VARCHAR2,
            p_Attribute2              IN     VARCHAR2,
            p_Attribute3              IN     VARCHAR2,
            p_Attribute4              IN     VARCHAR2,
            p_Attribute5              IN     VARCHAR2,
            p_Attribute6              IN     VARCHAR2,
            p_Attribute7              IN     VARCHAR2,
            p_Attribute8              IN     VARCHAR2,
            p_Attribute9              IN     VARCHAR2,
            p_Attribute10             IN     VARCHAR2,
            p_pm_funding_reference    IN     VARCHAR2,
            p_pm_product_code         IN     VARCHAR2,
            p_project_rate_type       IN     VARCHAR2   DEFAULT NULL,
            p_project_rate_date       IN     DATE       DEFAULT NULL,
            p_project_exchange_rate   IN     NUMBER     DEFAULT NULL,
            p_projfunc_rate_type      IN     VARCHAR2   DEFAULT NULL,
            p_projfunc_rate_date      IN     DATE       DEFAULT NULL,
            p_projfunc_exchange_rate  IN     NUMBER     DEFAULT NULL,
            x_err_code                OUT    NOCOPY NUMBER,/*file.sql.39*/
            x_err_msg                 OUT    NOCOPY VARCHAR2,/*file.sql.39*/
            p_funding_category        IN     VARCHAR2   /* For Bug 2244796  */

                      )
  IS
temp varchar2(20) := 'DRAFT';

 l_err_code  NUMBER;
 l_err_msg   VARCHAR2(100);
 np_p_Project_Funding_Id NUMBER := p_Project_Funding_Id;
  BEGIN
  -- dbms_output.put_line('Inside: pa_agreement_utils.create_funding');

  x_err_code := 0;
  x_err_msg := null;

  PA_FUNDING_CORE.CREATE_FUNDING(
            p_rowid                        =>   p_rowid,
            p_project_funding_id           =>   p_project_funding_id,
            p_last_update_date             =>   p_last_update_date,
            p_last_updated_by              =>   p_last_updated_by,
            p_creation_date                =>   p_creation_date,
            p_created_by                   =>   p_created_by,
            p_last_update_login            =>   p_last_update_login,
            p_agreement_id                 =>   p_agreement_id,
            p_project_id                   =>   p_project_id,
            p_task_id                      =>   p_task_id,
            p_budget_type_code             =>   temp,
            p_allocated_amount             =>   p_allocated_amount,
            p_date_allocated               =>   p_date_allocated,
            p_attribute_category           =>   p_attribute_category,
            p_attribute1                   =>   p_attribute1,
            p_attribute2                   =>   p_attribute2,
            p_attribute3                   =>   p_attribute3,
            p_attribute4                   =>   p_attribute4,
            p_attribute5                   =>   p_attribute5,
            p_attribute6                   =>   p_attribute6,
            p_attribute7                   =>   p_attribute7,
            p_attribute8                   =>   p_attribute8,
            p_attribute9                   =>   p_attribute9,
            p_attribute10                  =>   p_attribute10,
            p_pm_funding_reference         =>   p_pm_funding_reference,
            p_pm_product_code              =>   p_pm_product_code,
            p_project_rate_type            =>   p_project_rate_type,
            p_project_rate_date            =>   p_project_rate_date,
            p_project_exchange_rate        =>   p_project_exchange_rate,
            p_projfunc_rate_type           =>   p_projfunc_rate_type,
            p_projfunc_rate_date           =>   p_projfunc_rate_date,
            p_projfunc_exchange_rate       =>   p_projfunc_exchange_rate,
            x_err_code                     =>   l_err_code,
            x_err_msg                      =>   l_err_msg,
            p_funding_category             =>   p_funding_category   /* For Bug2244796 */
          );

      x_err_code := l_err_code;
      x_err_msg  := l_err_msg;

  EXCEPTION

   WHEN OTHERS THEN
      x_err_code := SQLCODE;
      x_err_msg   := SQLERRM;
      p_Project_Funding_Id := np_p_Project_Funding_Id;

  END create_funding;

--
--Name:                 update_funding
--Type:                 PROCEDURE
--Description:          This procedure is used to create a funding record in PA_PROJECT_FUNDINGS
--Called subprograms:   PA_FUNDING_CORE.UPDATE_FUNDING
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--                      15-MAY-2000     Created         Nikhil Mishra.
--                      07-SEP-2001     Modified        Srividya Sivaraman
--                     Added all new columns corresponding to MCB2

  PROCEDURE Update_funding(
            p_Project_Funding_Id      IN     NUMBER,
            p_Last_Update_Date        IN     DATE,
            p_Last_Updated_By         IN     NUMBER,
            p_Last_Update_Login       IN     NUMBER,
            p_Agreement_Id            IN     NUMBER,
            p_Project_Id              IN     NUMBER,
            p_Task_id                 IN     NUMBER,
            p_Allocated_Amount        IN     NUMBER,
            p_Date_Allocated          IN     DATE,
            p_Attribute_Category      IN     VARCHAR2,
            p_Attribute1              IN     VARCHAR2,
            p_Attribute2              IN     VARCHAR2,
            p_Attribute3              IN     VARCHAR2,
            p_Attribute4              IN     VARCHAR2,
            p_Attribute5              IN     VARCHAR2,
            p_Attribute6              IN     VARCHAR2,
            p_Attribute7              IN     VARCHAR2,
            p_Attribute8              IN     VARCHAR2,
            p_Attribute9              IN     VARCHAR2,
            p_Attribute10             IN     VARCHAR2,
            p_pm_funding_reference    IN     VARCHAR2,
            p_pm_product_code         IN     VARCHAR2,
            p_project_rate_type       IN     VARCHAR2   DEFAULT NULL,
            p_project_rate_date       IN     DATE       DEFAULT NULL,
            p_project_exchange_rate   IN     NUMBER     DEFAULT NULL,
            p_projfunc_rate_type      IN     VARCHAR2   DEFAULT NULL,
            p_projfunc_rate_date      IN     DATE       DEFAULT NULL,
            p_projfunc_exchange_rate  IN     NUMBER     DEFAULT NULL,
            x_err_code                OUT    NOCOPY NUMBER,/*File.sql.39*/
            x_err_msg                 OUT    NOCOPY VARCHAR2,/*File.sql.39*/
            p_funding_category        IN     VARCHAR2   /* For Bug2244796 */ )
  IS

 l_err_code  NUMBER;
 l_err_msg   VARCHAR2(100);

  BEGIN

  x_err_code := 0;
  x_err_msg := null;

  PA_FUNDING_CORE.UPDATE_FUNDING(
            p_project_funding_id           =>   p_project_funding_id,
            p_last_update_date             =>   p_last_update_date,
            p_last_updated_by              =>   p_last_updated_by,
            p_last_update_login            =>   p_last_update_login,
            p_agreement_id                 =>   p_agreement_id,
            p_project_id                   =>   p_project_id,
            p_task_id                      =>   p_task_id,
            p_budget_type_code             =>   'DRAFT',
            p_allocated_amount             =>   p_allocated_amount,
            p_date_allocated               =>   p_date_allocated,
            p_attribute_category           =>   p_attribute_category,
            p_attribute1                   =>   p_attribute1,
            p_attribute2                   =>   p_attribute2,
            p_attribute3                   =>   p_attribute3,
            p_attribute4                   =>   p_attribute4,
            p_attribute5                   =>   p_attribute5,
            p_attribute6                   =>   p_attribute6,
            p_attribute7                   =>   p_attribute7,
            p_attribute8                   =>   p_attribute8,
            p_attribute9                   =>   p_attribute9,
            p_attribute10                  =>   p_attribute10,
            p_pm_funding_reference         =>   p_pm_funding_reference,
            p_pm_product_code              =>   p_pm_product_code,
            p_project_rate_type            =>   p_project_rate_type,
            p_project_rate_date            =>   p_project_rate_date,
            p_project_exchange_rate        =>   p_project_exchange_rate,
            p_projfunc_rate_type           =>   p_projfunc_rate_type,
            p_projfunc_rate_date           =>   p_projfunc_rate_date,
            p_projfunc_exchange_rate       =>   p_projfunc_exchange_rate,
            x_err_code                     =>   l_err_code,
            x_err_msg                      =>   l_err_msg,
            p_funding_category             =>   p_funding_category   /* For Bug2244796 */
);

      x_err_code := l_err_code;
      x_err_msg  := l_err_msg;

  EXCEPTION

   WHEN OTHERS THEN
      x_err_code := SQLCODE;
      x_err_msg   := SQLERRM;

  END update_funding;


--
--Name:                 delete_funding
--Type:                 PROCEDURE
--Description:          This procedure is used to delete a funding record in PA_PROJECT_FUNDINGS
--Called subprograms:   PA_FUNDING_CORE.DELETE_FUNDING
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--                      15-MAY-2000     Created         Nikhil Mishra

  PROCEDURE Delete_funding(p_project_funding_id IN NUMBER)
  IS
  BEGIN
   PA_FUNDING_CORE.DELETE_FUNDING(p_project_funding_id);
  END Delete_funding;

--
--Name:                 lock_funding
--Type:                 PROCEDURE
--Description:          This procedure is used to lock a funding record in PA_PROJECT_FUNDINGS
--Called subprograms:   PA_FUNDING_CORE.LOCK_FUNDING
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--                      15-MAY-2000     Created         Nikhil Mishra
  PROCEDURE Lock_funding
  (p_Project_Funding_Id IN NUMBER)
  IS
  BEGIN
  PA_FUNDING_CORE.LOCK_FUNDING(p_Project_Funding_Id);
  END lock_funding;


--
--Name:                 get_agr_curr_code
--Type:                 function
--Description:          This function is used to get agreement currency code
--                       for a given agreement
--Called subprograms:   PA_AGREEMENT_CORE.get_agr_curr_code
--
--History:
--                      10-SEP-2001     Created         Srividya
--                      written for MCB2

  FUNCTION get_agr_curr_code ( p_agreement_id  IN      NUMBER)
            RETURN VARCHAR2

  IS

  BEGIN

      return (PA_AGREEMENT_CORE.GET_AGR_CURR_CODE(p_agreement_id));

  END get_agr_curr_code;


--
--Name:                 check_valid_owning_orgn_id
--Type:                 Function
--Description:          This function will return 'Y'
--                      if the owning organization id is valid
--                      ELSE will return 'N'
--
--Called subprograms:   PA_AGREEMENT_CORE.check_valid_owning_orgn_id
--
--
--History:
--                      10-SEP-2001     Created         Srividya
--                      written for MCB2

   FUNCTION check_valid_owning_orgn_id
            ( p_owning_organization_id  IN      NUMBER)
   RETURN VARCHAR2 IS


   BEGIN
       return(PA_AGREEMENT_CORE.CHECK_VALID_OWNING_ORGN_ID(
                      p_owning_organization_id));
   END check_valid_owning_orgn_id;

--
--Name:                 check_valid_agr_curr_code
--Type:                 Function
--Description:          This function will return 'Y'
--                      if the agreement currency code is valid
--                      ELSE will return 'N'
--
--Called subprograms:   PA_AGREEMENT_CORE.check_valid_agr_curr_code
--
--
--History:
--                      10-SEP-2001     Created         Srividya
--                      written for MCB2

   FUNCTION check_valid_agr_curr_code
            ( p_agreement_currency_code  IN      VARCHAR2)
   RETURN VARCHAR2 IS


   BEGIN
       return(PA_AGREEMENT_CORE.CHECK_VALID_agr_curr_code(
                      p_agreement_currency_code));
   END check_valid_agr_curr_code;


--Name:                 check_invoice_limit
--Type:                 Function
--Description:          This function will return 'Y' IF the invoice limit of
--                      the agreemnet is in the permissible limts
--                      ELSE will return 'N'
--
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_INVOICE_LIMIT
--
--
--History:
--                      10-SEP-2001     Created         Srividya
--                      written for MCB2

  FUNCTION check_invoice_limit ( p_agreement_id   IN	NUMBER)
  RETURN VARCHAR2 IS

  BEGIN

      -- dbms_output.put_line('Inside: PA_AGREEMENT_UTILS.CHECK_INVOICE_LIMIT');
      return (PA_AGREEMENT_CORE.CHECK_INVOICE_LIMIT(p_agreement_id));

  END  check_invoice_limit;

--Name:                 check_valid_exch_rate
--Type:                 Function
--Description:          This function will return 'Y' IF the
--                      exch rate type/rate is valid
--                      ELSE will return 'N'
--
--
--Called subprograms:   PA_FUNDING_CORE.CHECK_VALID_EXCH_RATE
--
--
--History:
--                      10-SEP-2001     Created         Srividya
--                      written for MCB2
/*
   FUNCTION check_valid_exch_rate
         ( p_exchange_rate_type	   IN	VARCHAR2,
           p_exchange_rate   IN	NUMBER)

   RETURN VARCHAR2 IS

   BEGIN

      return(PA_FUNDING_CORE.CHECK_VALID_EXCH_RATE(
               p_exchange_rate_type => p_exchange_rate_type,
               p_exchange_rate => p_exchange_rate ));

   END check_valid_exch_rate;
*/

 END PA_AGREEMENT_UTILS;

/
