--------------------------------------------------------
--  DDL for Package PSP_ENC_CRT_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_CRT_XML" AUTHID CURRENT_USER AS
/* $Header: PSPELXLS.pls 120.0 2006/06/06 22:23:00 vdharmap noship $ */
	P_SET_OF_BOOKS_ID	number;
	P_PAYROLL_ACTION_ID	number;
	P_REQUEST_ID	varchar2(40);
	P_BUSINESS_GROUP_ID	number;

        function cf_charging_instformula(p_gl_code_combination_id in number,
                                 p_project_id in number,
                                 p_task_id in number,
                                 p_award_id in number,
                                 p_expenditure_organization_id in number,
                                 p_expenditure_type in varchar2) return char;

	function CF_currency_codeFormula return Char  ;

        function CF_run_dateFormula return varchar2  ;

        function initialize_sched_lookups return boolean;

        function last_date_earned(p_payroll_id number) return varchar2;

        G_assignment     fnd_lookup_values.meaning%type;
        G_global_element fnd_lookup_values.meaning%type;
        G_org_level      fnd_lookup_values.meaning%type;
        G_suspense       fnd_lookup_values.meaning%type;
        G_org_default    fnd_lookup_values.meaning%type;
        G_asg_element    fnd_lookup_values.meaning%type;
        G_asg_ele_group  fnd_lookup_values.meaning%type;
        G_icx_date_mask  varchar2(20);

        function cf_p_orig_req_id return number;


END PSP_ENC_CRT_XML;

 

/
