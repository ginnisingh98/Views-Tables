--------------------------------------------------------
--  DDL for Package PAY_CN_AUDIT_XMLGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_AUDIT_XMLGEN" AUTHID CURRENT_USER AS
/* $Header: pycnauxml.pkh 120.0.12010000.3 2010/05/26 17:23:21 dduvvuri noship $ */

/*
 ===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
 Name
                pay_cn_audit_xmlgen
 File
                pycnauxml.pkh
 Purpose

    The purpose of this package is to support the generation of XML for the process
    China Payroll Data Export.

 Date                 Author          Verion       Bug         Details
 ============================================================================
30-MAR-2010           LNAGARAJ         1.0        9469668      Initial file created
13-APR-2010           DDUVVURI         1.1        9469668      Resolved GSCC errors.
26-MAY-2010           DDUVVURI         1.2        9743013,9742923,9742617 - Modified function get_message_text
                                                             and used payr_name in TYPE asg_record
 ============================================================================
*/

 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;
  g_year                 VARCHAR2(20);
  g_start_date           DATE;
  g_end_date             DATE;
  g_bg_id                NUMBER;
  g_package   VARCHAR2(20);
  g_payroll_action_id number;
  g_start_period number;
  g_end_period number;

PROCEDURE gen_xml_header_pay;

 function get_message_text(p_act_info1 VARCHAR2,
                          p_act_info2 VARCHAR2,
                          p_act_info3 VARCHAR2,
                          p_act_info4 VARCHAR2,
			  p_act_info5 VARCHAR2
) return varchar2 ;

PROCEDURE generate_xml;

PROCEDURE sort_action (
    payactid in varchar2,
    sqlstr in out nocopy varchar2,
    len out nocopy number
) ;

PROCEDURE gen_xml_footer;

PROCEDURE range_cursor (
    p_pactid  IN NUMBER,
    p_sqlstr  OUT nocopy VARCHAR2
);


PROCEDURE action_creation(
	p_pactid        	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson    IN NUMBER,
	p_chunk 	        IN NUMBER );

PROCEDURE assact_xml(p_assignment_action_id    IN NUMBER);

--

 PROCEDURE initialization_code
    (
      p_payroll_action_id    IN  NUMBER
    );


FUNCTION get_employee_number (p_person_id     in number,
                           p_effective_date    in date)
return Varchar2 ;

FUNCTION get_employee_name(p_person_id     in number,
                           p_effective_date    in date)
RETURN VARCHAR2;

FUNCTION get_cost_alloc_key_flex(p_payroll_id IN NUMBER,
                                 p_element_type_id IN NUMBER)
RETURN VARCHAR2;

PROCEDURE load_xml_internal ( p_node_type       IN  VARCHAR2
                               ,p_node          IN    VARCHAR2
                               ,p_data          IN    VARCHAR2);

PROCEDURE set_globals;

TYPE XMLRec IS RECORD(xmlstring VARCHAR2(4000));
--TYPE XMLRec IS RECORD(xmlstring RAW(4000));
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;

TYPE pay_prd_rec IS RECORD
(p_code fnd_lookup_values.lookup_code%type,
 p_meaning fnd_lookup_values.meaning%type);

 TYPE tab_pay_prd is TABLE OF pay_prd_rec INDEX BY BINARY_INTEGER;
g_pay_prd tab_pay_prd;
g_pay_ele tab_pay_prd;
g_ind_asg tab_pay_prd;
g_ind_detail tab_pay_prd;


TYPE ptp_rec IS table of varchar2(1000) index by binary_integer;

TYPE pay_prd_dis_rec IS RECORD
(p_num VARCHAR2(1000),
 p_start VARCHAR2(1000),
 p_end VARCHAR2(1000),
 p_year VARCHAR2(1000)
 );
 TYPE tab_pay_prd_dis is TABLE OF pay_prd_dis_rec INDEX BY BINARY_INTEGER;

TYPE asg_record IS RECORD
(
start_date DATE,
end_date DATE,
asg_id NUMBER,
payr_name VARCHAR2(1000)
);

TYPE tab_asg_rec is TABLE OF asg_record INDEX BY BINARY_INTEGER;

type t_new_type_rec is record (eno VARCHAR2(100),
asg_cat VARCHAR2(100),
emp_name VARCHAR2(100),
asg_org_id VARCHAR2(100),
pname VARCHAR2(100),
yr VARCHAR2(100),
pno VARCHAR2(100),
acct_yr VARCHAR2(100),
accnt_prd VARCHAR2(100),
currency VARCHAR2(100));
--
type t_new_type_cur is ref cursor return t_new_type_rec;
--

PROCEDURE OPEN_CSR_ASG_QUERY_DP(p_start IN DATE
                    ,p_end IN DATE
                    ,p_asg_id IN NUMBER
                    ,p_payr_id IN NUMBER
                    ,p_prd_num IN NUMBER
		    ,ref_curs IN OUT NOCOPY t_new_type_cur);

PROCEDURE OPEN_CSR_ASG_QUERY_DE(p_start IN DATE
                    ,p_end IN DATE
                    ,p_asg_id IN NUMBER
                    ,p_payr_id IN NUMBER
                    ,p_prd_num IN NUMBER
		    ,ref_curs IN OUT NOCOPY t_new_type_cur);

CURSOR c_header
IS
SELECT pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
FROM DUAL;

CURSOR c_asg_det
IS
SELECT 1
FROM DUAL ;

CURSOR c_body
IS
SELECT  'TRANSFER_ACT_ID=P',
        assignment_action_id
FROM  pay_assignment_actions
WHERE payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
ORDER BY action_sequence;

PROCEDURE deinitialization_code (p_pactid IN NUMBER);

END pay_cn_audit_xmlgen;

/
