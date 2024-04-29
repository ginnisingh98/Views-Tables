--------------------------------------------------------
--  DDL for Package HR_AMEUTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AMEUTIL_SS" AUTHID CURRENT_USER AS
/* $Header: hrameutlss.pkh 120.0.12010000.3 2008/08/18 12:50:58 schowdhu ship $ */

function get_item_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

function get_item_key
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

function get_process_name
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;

FUNCTION get_requestor_person_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION get_selected_person_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

function get_sel_person_assignment_id
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION get_payrate_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number ;

FUNCTION isChangePay
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_assignment_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION isAssignmentChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_supeversior_Chg_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION isSupervisorChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_termination_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;


FUNCTION isTermination
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;


FUNCTION get_loa_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number ;

FUNCTION get_length_of_service
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION get_salary_percent_change
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number ;

FUNCTION get_salary_amount_change
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_transaction_init_date
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_transaction_effective_date
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;


FUNCTION get_sel_person_prop_sup_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_proposed_job_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_proposed_position_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_proposed_grade_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_proposed_location_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_appraisal_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;

FUNCTION get_overall_appraisal_rating
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION isLOAChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_absence_type_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION get_proposed_payroll_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_proposed_salary_basis
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;

FUNCTION get_asg_change_reason
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_leaving_reason
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;

FUNCTION get_assignment_category
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_basic_details_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION isPersonDetailsChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_person_address_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION isPersonAddressChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;

FUNCTION get_person_contact_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION isPersonContactChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_caed_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION isReleaseInformation
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION get_paybasis_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;
FUNCTION getRequestorPositionId
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

FUNCTION get_payroll_con_user_name
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

FUNCTION isMidPayPayPeriodChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;

FUNCTION is_new_change_pay
(p_transaction_step_id IN hr_api_transaction_steps.transaction_step_id%TYPE)
        return varchar2;

END HR_AMEUTIL_SS;

/
