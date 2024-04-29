--------------------------------------------------------
--  DDL for Package PAY_JP_ISDF_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ISDF_RPT" AUTHID CURRENT_USER AS
/* $Header: pyjpisrp.pkh 120.6.12000000.2 2007/09/20 02:36:16 keyazawa noship $ */
--
  g_msg_circle fnd_new_messages.message_text%type;
--
  TYPE XMLRec IS RECORD(xmlstring VARCHAR2(4000));
  TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
--
  vXMLTable tXMLTable;
--
  level_cnt      NUMBER;
--
  cursor c_header
  is
  select 1
  from dual ;
--
  cursor c_footer
  is
  select 1
  from dual ;
--
  cursor eof
  is
  select 1
  from dual ;
--
  cursor c_body
  is
  select 'TRANSFER_ACT_ID=P',
         assignment_action_id
  from   pay_assignment_actions
  where payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
--
FUNCTION chk_ass_set(
  p_assignment_id     IN NUMBER,
  p_assignment_set_id IN NUMBER,
  p_formula_id        IN NUMBER,
  p_effective_date    IN DATE,
  p_dummy             IN NUMBER) RETURN BOOLEAN;
--
FUNCTION get_amendment_flag(
  p_assignment_id     IN NUMBER,
  p_assignment_set_id IN NUMBER) RETURN VARCHAR2;
--
FUNCTION chk_ass_set_mixed(
  p_assignment_set_id IN NUMBER) RETURN NUMBER;
--
FUNCTION chk_all_exclusions(
  p_assignment_set_id IN NUMBER) RETURN NUMBER;
--
PROCEDURE range_cursor(
  P_PAYROLL_ACTION_ID number,
  P_SQLSTR            OUT NOCOPY varchar2);
--
PROCEDURE action_creation(
  P_PAYROLL_ACTION_ID number,
  P_START_PERSON_ID   number,
  P_END_PERSON_ID     number,
  P_CHUNK             number);
--
PROCEDURE gen_xml_header;
--
PROCEDURE generate_xml;
--
PROCEDURE PRINT_CLOB(p_clob IN CLOB);
--
PROCEDURE gen_xml_footer;
--
PROCEDURE init_code(P_PAYROLL_ACTION_ID IN  NUMBER) ;
--
PROCEDURE archive_code(
  P_ASSIGNMENT_ACTION_ID IN NUMBER,
  P_EFFECTIVE_DATE       IN DATE) ;
--
PROCEDURE assact_xml(p_assignment_action_id IN NUMBER);
--
PROCEDURE get_ss_xml(
  p_assignment_action_id IN  NUMBER,
  p_xml                  OUT NOCOPY CLOB);
--
PROCEDURE get_cp_xml(
  p_assignment_action_id IN  NUMBER,
  p_xml                  OUT NOCOPY CLOB);
--
PROCEDURE WritetoCLOB(p_write_xml OUT NOCOPY CLOB);
--
FUNCTION submit_report(
  p_pact_id   IN NUMBER,
  p_assset_id IN NUMBER,
  p_eff_date  IN VARCHAR2) return number;
--
END PAY_JP_ISDF_RPT;

 

/
