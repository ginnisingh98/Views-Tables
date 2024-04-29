--------------------------------------------------------
--  DDL for Package HR_PAY_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAY_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: pegpipkg.pkh 120.3 2005/12/26 22:02:42 sgelvi noship $ */
--
--
--
-- specific functionality for the oab benefit view
-- non split view
--
FUNCTION GET_COVERAGE_TYPE(P_OIPL_ID IN NUMBER) RETURN VARCHAR2;
--
--
FUNCTION eepyc_erpyc_exist
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
         p_effective_start_date IN DATE,
         p_effective_end_date   IN DATE) RETURN VARCHAR2;
--
--
FUNCTION get_eepyc_varchar2
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN VARCHAR2;
--
FUNCTION get_eepyc_number
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN NUMBER;
--
FUNCTION get_eepyc_date
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN DATE;
--
FUNCTION get_erpyc_varchar2
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN VARCHAR2;
FUNCTION get_erpyc_number
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN NUMBER;
FUNCTION get_erpyc_date
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN DATE;

--
-- specific functionality for the oab benefit view
-- split views
--
--
FUNCTION split_eepyc_exist
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
         p_effective_start_date IN DATE,
         p_effective_end_date   IN DATE) RETURN VARCHAR2;
--
FUNCTION split_erpyc_exist
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
         p_effective_start_date IN DATE,
         p_effective_end_date   IN DATE) RETURN VARCHAR2;
--
FUNCTION get_split_eepyc_varchar2
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN VARCHAR2;
--
FUNCTION get_split_eepyc_number
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN NUMBER;
--
FUNCTION get_split_eepyc_date
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN DATE;
--
FUNCTION get_split_erpyc_varchar2
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN VARCHAR2;
FUNCTION get_split_erpyc_number
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN NUMBER;
FUNCTION get_split_erpyc_date
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN DATE;

--
--
TYPE g_reporting_details_rec_type
IS RECORD (
   reporting_name    PAY_ELEMENT_TYPES_F.REPORTING_NAME%TYPE
  ,business_group_id PAY_ELEMENT_TYPES_F.BUSINESS_GROUP_ID%TYPE
  ,payroll_id        PER_ALL_ASSIGNMENTS_F.payroll_id%TYPE
  ,legislation_code  PAY_ELEMENT_TYPES_F.LEGISLATION_CODE%TYPE
  ,element_type_id   PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE
  ,effective_start_date PAY_ELEMENT_TYPES_F.EFFECTIVE_START_DATE%TYPE
  ,effective_end_date   PAY_ELEMENT_TYPES_F.EFFECTIVE_END_DATE%TYPE);
--
TYPE g_element_entry_rec_type
IS RECORD (
   business_group_id PER_BUSINESS_GROUPS.business_group_id%TYPE
  ,payroll_id        PER_ALL_ASSIGNMENTS_F.payroll_id%TYPE
  ,element_entry_id  PAY_ELEMENT_ENTRIES_F.element_entry_id%TYPE
  ,creator_type      PAY_ELEMENT_ENTRIES_F.creator_type%TYPE
  );

-- Global variable to set Generic extract date. It is used to allow the extract
-- on any given date instead of the sysdate.
--
  g_payroll_extract_date date;
--
  g_reporting_details_rec_var g_reporting_details_rec_type;
  g_element_entry_rec_var     g_element_entry_rec_type;

-- Global variables to indicate whether attribute1 has been set in the date
-- tracked table pay_element_types
  g_ele_link_id pay_element_entries_f.element_link_id%TYPE;
  g_ele_entry_id pay_element_entries_f.element_entry_id%TYPE;
  g_ele_start_date pay_element_entries_f.effective_start_date%TYPE;
  g_ele_person_id per_all_people_f.person_id%TYPE;

-- Global variable g_personal_payment_method_id used to store the payment
-- method of the personal_payment_method to be deleted.
  g_personal_payment_method_id
    pay_personal_payment_methods_f.personal_payment_method_id%TYPE;
  g_ppm_ass_id
    pay_personal_payment_methods_f.assignment_id%TYPE;
  g_ppm_start_date
    pay_personal_payment_methods_f.effective_start_date%TYPE;

-- Global variable g_cost_allocation_id used to store the cost
-- allocation id of the cost allocation to be deleted.
  g_cost_allocation_id
    pay_cost_allocations_f.cost_allocation_id%TYPE;
  g_asg_cost_ass_id
    pay_cost_allocations_f.assignment_id%TYPE;
  g_asg_cost_start_date
    pay_cost_allocations_f.effective_start_date%TYPE;

--Procedure set_ele_var_ids is used to set the globals g_elem_link_id, and
--g_ele_entry_id which are used by the trigger hr_adp_ele_entry_value_brd
  PROCEDURE set_ele_var_ids(p_ele_link_id
			    pay_element_entries_f.element_link_id%TYPE,
			    p_ele_entry_id
			    pay_element_entries_f.element_entry_id%TYPE,
			    p_ele_start_date
			    pay_element_entries_f.effective_start_date%TYPE,
			    p_ele_person_id
			    per_all_people_f.person_id%TYPE);

--
  procedure disable_ele_entry_delete;
--
  procedure disable_emp_number_update (p_old_emp_number varchar2 default null,
                                       p_new_emp_number varchar2 default null);
--
  procedure chk_reporting_name_uniqueness ;
--
  FUNCTION get_hot_default(p_input_value_id number
                          ,p_element_link_id number)
                          RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(get_hot_default, WNPS, WNDS);
--
  procedure set_extract_date(p_payroll_extract_date in date);
--
  function get_extract_date return date;
  pragma restrict_references(get_extract_date, WNDS, WNDS);
--
  procedure disable_ppm_update (p_old_priority varchar2 default null,
                                p_new_priority varchar2 default null);
  procedure disable_ppm_delete_purge;
--
  procedure disable_asg_cost_delete_purge;
--
--
--
END HR_PAY_INTERFACE_PKG ;

 

/
