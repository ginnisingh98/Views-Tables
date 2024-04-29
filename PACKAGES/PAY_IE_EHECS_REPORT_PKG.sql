--------------------------------------------------------
--  DDL for Package PAY_IE_EHECS_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_EHECS_REPORT_PKG" AUTHID CURRENT_USER as
/* $Header: pyieehecs.pkh 120.1.12010000.1 2008/07/27 22:49:39 appldev ship $ */
level_cnt number;

g_payroll_id  VARCHAR2(100);
g_business_Group_id  VARCHAR2(100);
g_employer_id VARCHAR2(100);
g_rep_group varchar2(50);
g_pact_id NUMBER;
g_ie_nat_min_wage_rate Number;

g_where_clause VARCHAR2(1000);
g_where_clause1 VARCHAR2(1000);
g_where_clause_asg_set VARCHAR2(1000);
g_exc_inc VARCHAR2(10);

g_year varchar2(50);
g_quarter varchar2(50);
g_assignment_set_id varchar2(50);
g_occupational_category varchar2(50);
g_occupational_category_M_C_P varchar2(50);
g_report_type varchar2(50);
g_declare_date varchar2(50);
g_change_indicator varchar2(50);
g_comments varchar2(300);

g_qtr_start_date date;
g_qtr_end_date date;

g_org_name varchar2(200);
g_archive_effective_date date;

TYPE balance_name_rec IS RECORD (
  balance_name VARCHAR2(100));

TYPE balance_id_rec IS RECORD (
  defined_balance_id NUMBER,
  balance_name VARCHAR2(100));

TYPE balance_name_tab IS TABLE OF balance_name_rec INDEX BY BINARY_INTEGER;
TYPE balance_id_tab   IS TABLE OF balance_id_rec   INDEX BY BINARY_INTEGER;

g_balance_name balance_name_tab;
g_def_bal_id  balance_id_tab;


PROCEDURE range_code(	pactid IN NUMBER,
			sqlstr OUT nocopy VARCHAR2);

PROCEDURE assignment_action_code(pactid in number,
			          stperson in number,
				  endperson in number,
				  chunk in number);

PROCEDURE archive_init(p_payroll_action_id IN NUMBER);

PROCEDURE archive_data(p_assactid in number,
                        p_effective_date in date);
procedure archive_deinit(pactid IN NUMBER);

PROCEDURE gen_body_xml;

PROCEDURE gen_header_xml;

PROCEDURE gen_footer_xml;

CURSOR  c_body IS
SELECT 'TRANSFER_ACT_ID=P', ptoa.Object_Action_id
FROM    pay_temp_object_actions ptoa
WHERE   ptoa.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value
	     ('TRANSFER_PAYROLL_ACTION_ID'))
ORDER BY ptoa.Object_Action_id;

CURSOR c_hdr IS
    SELECT  'PAYROLL_ACTION_ID=P'
      ,pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    FROM  dual;

CURSOR c_asg_actions IS
    SELECT  'TRANSFER_ACT_ID=P'
      ,pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
    FROM  dual;
END PAY_IE_EHECS_REPORT_PKG;

/
