--------------------------------------------------------
--  DDL for Package PAY_IE_CESS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_CESS_REPORT" AUTHID CURRENT_USER as
/* $Header: pyiecess.pkh 120.0.12010000.1 2009/03/31 07:18:04 knadhan noship $ */
level_cnt number;

g_payroll_id  VARCHAR2(100);
g_business_Group_id  VARCHAR2(100);
g_start_date  date;
g_end_date  date;
g_person_id  VARCHAR2(100);
g_employer_id VARCHAR2(100);
g_file_type varchar2(50);
g_rep_group varchar2(50);
g_pact_id NUMBER;
--g_file_type varchar2(10):='N';
g_where_clause VARCHAR2(1000);
g_where_clause1 VARCHAR2(1000);
g_where_clause2 VARCHAR2(1000);
g_where_clause3 VARCHAR2(1000);
g_submitted VARCHAR2(1000):='Already Submitted';
g_org_name varchar2(200);
--g_archive_effective_date date;

PROCEDURE range_code(	pactid IN NUMBER,
			sqlstr OUT nocopy VARCHAR2);

PROCEDURE assignment_action_code(pactid in number,
			          stperson in number,
				  endperson in number,
				  chunk in number);

PROCEDURE archive_init(p_payroll_action_id IN NUMBER);

PROCEDURE archive_data(p_assactid in number,
                        p_effective_date in date);
/*
FUNCTION get_arc_bal_value(
                     p_assignment_action_id  in number
		    ,p_payroll_action_id     in number     -- 5005788
                    ,p_balance_name          in varchar2 ) return number;

		    */

PROCEDURE gen_body_xml;

PROCEDURE gen_header_xml;

PROCEDURE gen_footer_xml;

CURSOR  c_body IS
    SELECT 'TRANSFER_ACT_ID=P', paa.assignment_action_id
    FROM    pay_assignment_actions paa
    WHERE   paa.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value
	     ('TRANSFER_PAYROLL_ACTION_ID'))
    ORDER BY paa.assignment_action_id;

CURSOR c_hdr IS
    SELECT  'PAYROLL_ACTION_ID=P'
      ,pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    FROM  dual;

CURSOR c_asg_actions IS
    SELECT  'TRANSFER_ACT_ID=P'
      ,pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
    FROM  dual;


END PAY_IE_CESS_REPORT;

/
