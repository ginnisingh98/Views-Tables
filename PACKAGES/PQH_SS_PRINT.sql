--------------------------------------------------------
--  DDL for Package PQH_SS_PRINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SS_PRINT" AUTHID CURRENT_USER as
/* $Header: pqprtswi.pkh 120.1 2005/06/07 18:11:27 sgudiwad noship $ */

PROCEDURE set_eff_dte_for_refresh_atts;

PROCEDURE populate_temp_data(
    p_Transaction_Id 	IN         VARCHAR2  ,
    p_session_id   	OUT NOCOPY VARCHAR2,
    p_effective_date    IN         DATE,
    p_doc_short_name    IN         VARCHAR2 );

TYPE params_value_record is RECORD (
              param_name varchar2(4000),
              param_value varchar2(4000),
              param_data_type varchar2(2));
TYPE params_value_table is  TABLE of params_value_record index by binary_integer;
params_table  params_value_table;

FUNCTION get_function_parameter_value(
                     p_parameter_name IN VARCHAR2,
                     p_transaction_id IN VARCHAR2,
                     p_type_code      IN VARCHAR2 default 'PRE',
                     p_effective_date IN VARCHAR2) RETURN VARCHAR2;

FUNCTION set_document_data(p_tag_name IN varchar2, p_tag_value IN varchar2) return NUMBER;

FUNCTION get_session_details (p_txn_id OUT NOCOPY NUMBER, p_session_id OUT NOCOPY NUMBER, p_effective_date OUT NOCOPY DATE) return number;

-- Conversion functions are added here for attributes
FUNCTION get_table_route_id(p_table_alias IN varchar2 ) RETURN VARCHAR2;

FUNCTION get_tenure_status (p_lookup_code varchar2) RETURN VARCHAR2;

FUNCTION get_qualification (p_qualification_type_id varchar2) RETURN VARCHAR2;

FUNCTION get_award_status (p_award_id varchar2) RETURN VARCHAR2;

FUNCTION get_tuition_method (p_tuition_id varchar2) RETURN VARCHAR2;

FUNCTION get_currency_meaning(p_currency_code varchar2) RETURN VARCHAR2;

FUNCTION get_person_title (p_title_code varchar2) RETURN VARCHAR2;

FUNCTION get_gender (p_gender_code varchar2) RETURN VARCHAR2;

FUNCTION get_marital_status(p_marital_code varchar2) RETURN VARCHAR2;

FUNCTION get_termination_reason (p_termination_code varchar2) RETURN VARCHAR2;

FUNCTION get_work_schedule_frequency (p_freq_code varchar2) RETURN VARCHAR2;

FUNCTION get_employee_category (p_category_code varchar2) RETURN VARCHAR2;

FUNCTION get_employment_category (p_category_code varchar2) RETURN VARCHAR2;

FUNCTION get_yes_no (p_lookup_code varchar2) RETURN VARCHAR2;

FUNCTION get_establishment (p_establishment_id varchar2) RETURN VARCHAR2;

FUNCTION get_person_latest_name (p_person_id varchar2) RETURN VARCHAR2;

FUNCTION get_person_brief_name (p_person_id varchar2) RETURN VARCHAR2;

FUNCTION decode_payroll_latest_name (p_payroll_id varchar2) RETURN VARCHAR2;

FUNCTION decode_bargaining_unit_code (p_bargaining_unit_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION decode_collective_agreement(p_collective_agreement_id IN NUMBER) RETURN VARCHAR2;

FUNCTION decode_contract(p_contract_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_user_status(p_assignment_status_type_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_change_reason(p_reason_code IN VARCHAR2) RETURN VARCHAR2;

--
-- Following procedure will be used to delete the temp data day earlier to sysdate(effective date)
-- from table pqh_ss_print_label_temp.
-- The data get generated in this table as on when user visit the Document Create Page / Document Review Page
-- This table contains the attribute label prompts used in SSHR transactions.
--

PROCEDURE purge_temp_data(p_effective_date date default trunc(sysdate));

PROCEDURE replace_where_clause_params(p_where_clause_in  IN PQH_TABLE_ROUTE.where_clause%TYPE,
                                      p_where_clause_out OUT NOCOPY PQH_TABLE_ROUTE.where_clause%TYPE);
FUNCTION decode_value(p_lookup_code varchar2) RETURN VARCHAR2;
FUNCTION get_salary(p_assignment_id  per_assignments_f.assignment_type%TYPE) RETURN  VARCHAR2;
FUNCTION get_currency(p_pay_basis_id per_pay_bases.pay_basis_id%TYPE) RETURN VARCHAR2;
FUNCTION get_change_amount(p_pay_proposal_id  per_pay_proposals.pay_proposal_id%Type) Return Varchar2;
FUNCTION get_change_percent(p_pay_proposal_id  per_pay_proposals.pay_proposal_id%Type) Return Varchar2;

/* -----------------------------------------------------------
   Procedure/Functions to support compensation workbench
   BEGIN
   ----------------------------------------------------------- */

   procedure populate_cwb_data(
    p_group_per_in_ler_id in number,
    p_group_plan_id        in number,
    p_lf_evt_ocrd_dt       in date,
    p_doc_short_name       in varchar2,
    p_session_id           out nocopy varchar2,
    p_effective_date       in date default sysdate) ;
   --
/* -----------------------------------------------------------
   END Supporting proc/func for CWB
   ----------------------------------------------------------- */
END pqh_ss_print;

 

/
