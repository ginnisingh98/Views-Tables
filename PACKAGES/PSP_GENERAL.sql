--------------------------------------------------------
--  DDL for Package PSP_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_GENERAL" AUTHID CURRENT_USER AS
/* $Header: PSPGENES.pls 120.5.12010000.3 2008/10/20 09:33:12 amakrish ship $  */
procedure  get_annual_salary(p_assignment_id in number,
                    p_session_date  in date,
                    p_annual_salary out NOCOPY number);
procedure get_gl_ccid(p_payroll_id      in number,
                        p_set_of_books_id in number,
		  	p_cost_keyflex_id in number,
                        x_gl_ccid out NOCOPY number);

PROCEDURE TRANSACTION_CHANGE_PURGEBLE;

function business_days (low_date date,
                        high_date date,
			p_assignment_id	NUMBER DEFAULT NULL)
RETURN number;

function last_working_date (last_date date)
RETURN date;

---
FUNCTION find_chart_of_accts(p_set_of_books_id IN NUMBER,
			     p_chart_of_accts OUT NOCOPY VARCHAR2)
RETURN NUMBER;
---
FUNCTION get_gl_description(p_set_of_books_id  IN  NUMBER,
			    a_code_combination_id IN NUMBER)
RETURN VARCHAR2;
---PRAGMA RESTRICT_REFERENCES(get_gl_description,WNDS);
---
FUNCTION find_global_suspense(p_start_date_active IN DATE DEFAULT NULL,
			      p_business_group_id IN NUMBER,
			      p_set_of_books_id   IN NUMBER,
                              p_organization_account_id OUT NOCOPY NUMBER)
RETURN VARCHAR2;
---

PROCEDURE poeta_effective_date
			(p_payroll_end_date IN  DATE,
                         p_project_id       IN  NUMBER,
                         p_award_id         IN  NUMBER,
                         p_task_id          IN  NUMBER,
                         p_effective_date   OUT NOCOPY DATE,
                         p_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE poeta_effective_date
			(p_payroll_end_date IN  DATE,
                         p_project_id       IN  NUMBER,
                         p_task_id          IN  NUMBER,
                         p_effective_date   OUT NOCOPY DATE,
                         p_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE MULTIORG_CLIENT_INFO(
		     p_gl_set_of_bks_id 	OUT NOCOPY	NUMBER,
		     p_business_group_id        OUT NOCOPY     NUMBER,
		     p_operating_unit           OUT NOCOPY     NUMBER,
		     p_pa_gms_install_options	OUT NOCOPY	VARCHAR2);

FUNCTION get_specific_profile(
		     p_profile_name 		IN	VARCHAR2)
return VARCHAR2;

FUNCTION IS_LD_ENABLED (P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2;

/* Added the procedure below as part of "Zero work days" enhancement */

PROCEDURE GET_GMS_EFFECTIVE_DATE(
             p_person_id in number,
             p_effective_date in out NOCOPY date);


FUNCTION AWARD_DATE_VALIDATION
		(P_AWARD_ID 		IN	NUMBER,
                 P_START_DATE 		IN	DATE,
                 P_END_DATE 		IN	DATE)
	RETURN BOOLEAN;

FUNCTION get_gl_values(p_set_of_books_id  IN  NUMBER,
                            a_code_combination_id IN NUMBER)
RETURN VARCHAR2;

-- Added by Ritesh on 14-NOV-2001 for Bug:2103460

FUNCTION get_person_name(p_person_id	  IN NUMBER,
			 p_effective_date IN DATE)
	 RETURN VARCHAR2;

FUNCTION get_assignment_num(p_assignment_id   IN NUMBER,
			    p_effective_date  IN DATE)
	 RETURN VARCHAR2;

FUNCTION get_payroll_name(p_payroll_id 	   IN NUMBER,
			  p_effective_date IN DATE)
	 RETURN VARCHAR2;

/*	Commented the following procedure for bug fix 2397883
--	Introduced the following procedure for bug 2209483
PROCEDURE	igw_percent_effort	(p_person_id		IN	NUMBER,
					p_award_id		IN	NUMBER,
					p_effective_date	IN	DATE,
					p_percent_effort	OUT NOCOPY	NUMBER,
					p_msg_data		OUT NOCOPY	VARCHAR2,
					p_return_status		OUT NOCOPY	VARCHAR2);
	End of bug fix 2397883	*/

-- Pragmas needs to be defined for these functions as they are called from SQL.

PRAGMA RESTRICT_REFERENCES(get_person_name, WNDS);
PRAGMA RESTRICT_REFERENCES(get_assignment_num, WNDS);
PRAGMA RESTRICT_REFERENCES(get_payroll_name, WNDS);

-- End additions for Bug:2103460.

--	Introduced the following for bug fix 2635110
	FUNCTION	get_project_number	(p_project_id		IN	NUMBER)	RETURN VARCHAR2;
	FUNCTION	get_task_number		(p_task_id		IN	NUMBER)	RETURN VARCHAR2;
	FUNCTION	get_award_number	(p_award_id		IN	NUMBER)	RETURN VARCHAR2;
	FUNCTION	get_org_name		(p_org_id		IN	NUMBER)	RETURN VARCHAR2;
	FUNCTION	get_period_name		(p_period_id		IN	NUMBER)	RETURN VARCHAR2;
	FUNCTION	get_element_name	(p_element_type_id	IN	NUMBER)	RETURN VARCHAR2;
	FUNCTION	get_element_name	(p_element_type_id	IN	NUMBER,
						p_effective_date	IN	DATE)	RETURN VARCHAR2;
	FUNCTION	get_source_type		(p_source_type		IN	VARCHAR2,
						p_source_code		IN	VARCHAR2)	RETURN VARCHAR2;
	FUNCTION	get_status_description	(p_status_code		IN	VARCHAR2)	RETURN VARCHAR2;
	FUNCTION	get_error_description	(p_error_code		IN	VARCHAR2)	RETURN VARCHAR2;

--	Pragmas for the above functions
	PRAGMA RESTRICT_REFERENCES(get_project_number, WNDS);
	PRAGMA RESTRICT_REFERENCES(get_task_number, WNDS);
	PRAGMA RESTRICT_REFERENCES(get_award_number, WNDS);
	PRAGMA RESTRICT_REFERENCES(get_org_name, WNDS);
	PRAGMA RESTRICT_REFERENCES(get_period_name, WNDS);
	PRAGMA RESTRICT_REFERENCES(get_element_name, WNDS);
	PRAGMA RESTRICT_REFERENCES(get_source_type, WNDS);
	PRAGMA RESTRICT_REFERENCES(get_status_description, WNDS);
	PRAGMA RESTRICT_REFERENCES(get_error_description, WNDS);
--	End of bug fix 2635110



-- For bug no 2478000 by tbalacha

/**********************************************************************************************
  Description : Function Introduced fro Qubec
  Purpose : To remove hard coded US dollars from LD
  Date:25-Apr-2003
**********************************************************************************************/

FUNCTION get_currency_code(p_business_group_id IN NUMBER ) RETURN VARCHAR2;

-- End of code for bug no 2478000 by tbalacha

--	Introduced the following procedure for bug 2916848
	PROCEDURE	get_currency_precision
				(p_currency_code	IN	VARCHAR2,
				p_precision	OUT NOCOPY	NUMBER,
				p_ext_precision	OUT NOCOPY	NUMBER);

/*****	Commented the following gor bug fix 3146167
	FUNCTION get_payroll_currency(p_payroll_control_id IN NUMBER) RETURN VARCHAR2;
	PRAGMA RESTRICT_REFERENCES(get_payroll_currency, WNDS);
	End of comment for bug fix 3146167	*****/
--	End of bug fix 2916848

-- For BUg 2916848 Ilo Mrc Ehnc.
/*******************************************************************************************
  Description: This function call would replace call to profile option
		PSP: Enable Update Encumbrance, as the profile,
		PSP: Enable Update Encumbrance will be obsoleted by end dating it to '01-jan-2003'.
		The call to the profile PSP: Enable Update Encumbrance , in all the files except
		GMS.pll will be removed and this  new function START_CAPTURING_UPDATES will
		instead called in its place
  Date of Creation: 23-Jul-2003
  Bug :3075435 Dynamic trigger implementaion
**********************************************************************************************/
Function START_CAPTURING_UPDATES(p_business_group_id IN NUMBER) RETURN VARCHAR2;

/**************************************************************************
  Description : this function was Introduced to check for the existence of
		Person_Business_group_id column at customers site , if it
		exist, then this function returns true else it returns false
  Date of creation: 24-Oct-2003
FUNCTION PERSON_BUSINESS_GROUP_ID_EXIST RETURN BOOLEAN;
***************************************************************************/



/*****************************************************************************
 Function name :  VALIDATE_PROC_FOR_HR_UPG
 Creation date :  21-Apr-2004
 Purpose       :  This procedure returns true when Labor Distribtion Product
		  is Installed.
*****************************************************************************/
PROCEDURE VALIDATE_PROC_FOR_HR_UPG(DO_UPG OUT NOCOPY VARCHAR2);

--	Introduced the following for bug fix 2908859/2907203
FUNCTION get_act_dff_grouping_option (p_business_group_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_enc_dff_grouping_option (p_business_group_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_sponsored_flag (p_project_id IN NUMBER) RETURN VARCHAR2;
--	End of changes for bug fix 2908859/2907203

-- Function introduced to be used in Effort Reporting self service module
FUNCTION get_person_name_er(p_person_id IN VARCHAR2, p_effective_date IN DATE) RETURN VARCHAR2 ;
FUNCTION chk_person_validity(p_person_id IN VARCHAR2,p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION get_payroll_name_er(p_payroll_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION chk_payroll_validity(p_payroll_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION chk_position_validity(p_position_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION get_position_name_er(p_position_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 ;
FUNCTION get_fastformula_name_er(p_formula_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION chk_fastformula_validity(p_formula_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION get_job_name_er(p_job_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION chk_job_validity(p_job_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION chk_org_validity(p_org_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;
FUNCTION get_org_name_er(p_org_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 ;
FUNCTION get_fastformula_desc_er(p_formula_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2;

-- End of funtion changes for Er Self service module.

--- Functions used in AME
function get_approval_type(txn_id varchar2) return varchar2;
pragma restrict_references (get_approval_type, wnds, wnps);

function get_person_id(txn_id varchar2) return number;
pragma restrict_references (get_person_id, wnds, wnps);

function get_eff_report_detail_id(txn_id varchar2) return number;
pragma restrict_references (get_eff_report_detail_id, wnds, wnps);

function get_task_id(txn_id varchar2) return number;
pragma restrict_references (get_task_id, wnds, wnps);

function get_project_id(txn_id varchar2) return number;
pragma restrict_references (get_project_id, wnds, wnps);

function get_emp_term_flag(txn_id varchar2) return varchar2;
pragma restrict_references (get_emp_term_flag, wnds, wnps);

function get_user_id_flag(txn_id varchar2) return varchar2;   --Added for bug 6786413
pragma restrict_references (get_user_id_flag, wnds, wnps);

--	Introduced the following for bug fix 3867234
PROCEDURE	add_report_error(p_request_id		IN		NUMBER,
				p_message_level		IN		VARCHAR2,
				p_source_id		IN		NUMBER,
				p_error_message		IN		VARCHAR2,
				p_payroll_action_id	IN		NUMBER		DEFAULT NULL,
				p_return_status		OUT	NOCOPY	VARCHAR2,
				p_source_name		IN		VARCHAR2	DEFAULT NULL,
				p_parent_source_id	IN		NUMBER		DEFAULT NULL,
				p_parent_source_name	IN		VARCHAR2	DEFAULT NULL,
				p_value1		IN		NUMBER		DEFAULT NULL,
				p_value2		IN		NUMBER		DEFAULT NULL,
				p_value3		IN		NUMBER		DEFAULT NULL,
				p_value4		IN		NUMBER		DEFAULT NULL,
				p_value5		IN		NUMBER		DEFAULT NULL,
				p_value6		IN		NUMBER		DEFAULT NULL,
				p_value7		IN		NUMBER		DEFAULT NULL,
				p_value8		IN		NUMBER		DEFAULT NULL,
				p_value9		IN		NUMBER		DEFAULT NULL,
				p_value10		IN		NUMBER		DEFAULT NULL,
				p_information1		IN		VARCHAR2	DEFAULT NULL,
				p_information2		IN		VARCHAR2	DEFAULT NULL,
				p_information3		IN		VARCHAR2	DEFAULT NULL,
				p_information4		IN		VARCHAR2	DEFAULT NULL,
				p_information5		IN		VARCHAR2	DEFAULT NULL,
				p_information6		IN		VARCHAR2	DEFAULT NULL,
				p_information7		IN		VARCHAR2	DEFAULT NULL,
				p_information8		IN		VARCHAR2	DEFAULT NULL,
				p_information9		IN		VARCHAR2	DEFAULT NULL,
				p_information10		IN		VARCHAR2	DEFAULT NULL);

PROCEDURE	add_report_error(p_request_id	IN		NUMBER,
				p_message_level	IN		VARCHAR2,
				p_source_id	IN		NUMBER,
				p_retry_request_id	IN		NUMBER,
				p_pdf_request_id	IN		NUMBER,
				p_error_message	IN		VARCHAR2,
				p_return_status	OUT	NOCOPY	VARCHAR2);
--	End of changes for bug fix 3867234

-- Introduced the following for bug fix 4022334
FUNCTION IS_EFFORT_REPORT_MIGRATED RETURN BOOLEAN ;
-- END of changes for bug fix 4022334

-- Start BUG 4244924YALE ENHANCEMENTS
function GET_CONFIGURATION_OPTION_VALUE(p_business_group_id IN NUMBER,
                                        p_pcv_information_category in varchar2,
                                        p_pcv_information1 in varchar2 default null) return varchar2;

Procedure get_gl_ptaoe_Mapping(p_business_group_id IN NUMBER,
                                              p_proj_segment OUT NOCOPY varchar2, p_tsk_segment OUT NOCOPY varchar2,
                                              p_awd_sgement OUT NOCOPY varchar2, p_exp_org_segment OUT NOCOPY varchar2,
                                              p_exp_type_segment OUT NOCOPY varchar2) ;

-- END BUG 4244924YALE ENHANCEMENTS

--Bug 4334816:Function added for Effort Report Status Monitor
FUNCTION Is_eff_Report_status_changed (p_status_code IN Varchar2, p_wf_itrm_key IN Number)
return varchar2 ;


function get_assignment_status( p_ASSIGNMENT_id in number , p_effective_date in date)
return VARCHAR2;

--R12 MOAC Uptake
G_PREV_PROJ_ID Number(15);
G_PREV_ORG_ID Number(15);

PROCEDURE INIT_MOAC;

FUNCTION Get_transaction_org_id (p_project_id Number,p_expenditure_organization_id Number)
RETURN NUMBER;

-- Bug 7137755
FUNCTION get_pre_app_emp_list(P_REQUEST_ID IN Number)
return varchar2;

-- Bug 7137755
FUNCTION get_app_rej_emp_list(P_WF_ITEM_KEY IN Varchar2)
return varchar2;

END;


/
