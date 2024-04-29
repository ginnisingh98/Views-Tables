--------------------------------------------------------
--  DDL for Package PAY_IE_P35
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_P35" AUTHID CURRENT_USER AS
/* $Header: pyiep35x.pkh 120.4.12010000.2 2008/09/30 12:34:35 rsahai ship $ */

level_cnt NUMBER;

function GET_DEFINED_BALANCE_ID (  p_dimension_name varchar2,
                                   p_balance_name varchar2
                                   )
return number;


FUNCTION  get_parameter(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2) RETURN VARCHAR2;

FUNCTION get_initial_class (p_max_action_id in NUMBER,
                            l_segment4  in number,
                            p_ppsn_override IN VARCHAR2) RETURN VARCHAR2; --6633719

FUNCTION get_second_class (p_assignment_id in NUMBER) RETURN VARCHAR2;

FUNCTION get_p60_second_class (p_assignment_id in NUMBER) RETURN VARCHAR2;

FUNCTION get_third_class (p_assignment_id in NUMBER) RETURN VARCHAR2;

FUNCTION get_fourth_class (p_assignment_id in NUMBER) RETURN VARCHAR2;

FUNCTION get_fifth_class (p_assignment_id in NUMBER) RETURN VARCHAR2;

FUNCTION weeks_at_initial_class (p_assignment_id in NUMBER,
					   l_segment4  in number) RETURN NUMBER;
FUNCTION weeks_at_second_class (p_assignment_id in NUMBER,
					  l_segment4  in number) RETURN NUMBER;
FUNCTION weeks_at_third_class (p_assignment_id in NUMBER,
					 l_segment4  in number) RETURN NUMBER;
FUNCTION weeks_at_fourth_class (p_assignment_id in NUMBER,
					  l_segment4  in number) RETURN NUMBER;
FUNCTION weeks_at_fifth_class (p_assignment_id in NUMBER,
					  l_segment4  in number) RETURN NUMBER;

FUNCTION get_prsi_weeks (l_class in varchar2,
				 l_segment4  in number) RETURN NUMBER;

FUNCTION get_total_insurable_weeks (p_person_id in NUMBER
						,p_tax_unit_id in NUMBER
						,p_assignment_action_id IN NUMBER
						,p_Act_Context_id  number default NULL  --6633719
						,p_Act_Context_value varchar2 default NULL --6633719
						,p_dimension_name varchar2 default '_PER_PAYE_REF_YTD' --6633719
						,p_ppsn_override VARCHAR2 default NULL) RETURN NUMBER; --6633719

-- Bug 2979713 - PRSI Context Balances (below 2 functions added)

FUNCTION get_start_date RETURN DATE;

FUNCTION get_end_date RETURN DATE;

/*Added for bug fix 3815830*/
FUNCTION replace_xml_symbols(p_string IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE range_code(
                p_payroll_action_id     IN  NUMBER,
                sqlstr                OUT NOCOPY VARCHAR2);
--
PROCEDURE action_creation(
                          pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER);

Procedure archive_code  (p_assactid       IN NUMBER
				,p_effective_date IN DATE);

Procedure deinit_code (p_payroll_action_id IN NUMBER);

/* Function to check the override ppsn */ --6633719
FUNCTION OVERRIDE_PPSN(asg_id NUMBER) RETURN VARCHAR2;

END pay_ie_p35;

/
