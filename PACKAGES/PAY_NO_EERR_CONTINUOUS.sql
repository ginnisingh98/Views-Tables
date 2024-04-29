--------------------------------------------------------
--  DDL for Package PAY_NO_EERR_CONTINUOUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_EERR_CONTINUOUS" AUTHID CURRENT_USER as
/* $Header: pynoeerc.pkh 120.0.12000000.1 2007/05/22 06:24:12 rajesrin noship $ */
--------------------------------------------------------------------------------
-- Global Variables
--------------------------------------------------------------------------------
--
   g_public_org_flag         hr_lookups.lookup_type%type;
   g_risk_cover_flag         hr_lookups.lookup_type%type;
   g_contract_code_mapping   hr_lookups.lookup_type%type;

--
--------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS
--------------------------------------------------------------------------------
   procedure get_all_parameters (
      p_payroll_action_id   in              number,
      p_business_group_id   out nocopy      number,
      p_legal_employer_id   out nocopy      number,
      p_archive             out nocopy      varchar2,
      p_start_date          out nocopy      date,
      p_end_date            out nocopy      date,
      p_effective_date      out nocopy      date
   --  p_report_mode         out nocopy      varchar2
   );

--------------------------------------------------------------------------------
-- GET_PARAMETERS
--------------------------------------------------------------------------------
   function get_parameter (
      p_parameter_string   in   varchar2,
      p_token              in   varchar2,
      p_segment_number     in   number default null
   )
      return varchar2;

--------------------------------------------------------------------------------
-- RANGE_CODE
--------------------------------------------------------------------------------
   procedure range_code (
      p_payroll_action_id   in              number,
      p_sql                 out nocopy      varchar2
   );
    ---------------------------------------  PROCEDURE ARCHIVE_EMPLOYEE_DETAILS -----------------------------------------------------------
   /* EMPLOYEE DETAILS REGION */
   procedure archive_code (
      p_assignment_action_id   in   number,
      p_effective_date         in   date
   );

   procedure initialization_code (
      p_payroll_action_id   in   number
   );

   procedure assignment_action_code (
      p_payroll_action_id   in   number,
      p_start_person        in   number,
      p_end_person          in   number,
      p_chunk               in   number
   );

   function find_total_hour (
      p_hours       in   number,
      p_frequency   in   varchar2
   )
      return number;

   procedure sort_changes (
      p_detail_tab   in out nocopy   pay_interpreter_pkg.t_detailed_output_table_type
   );

   procedure copy (
      p_copy_from   in out nocopy   pay_interpreter_pkg.t_detailed_output_table_type,
      p_from        in              number,
      p_copy_to     in out nocopy   pay_interpreter_pkg.t_detailed_output_table_type,
      p_to          in              number
   );

   function get_assignment_all_hours (
      p_assignment_id        in   per_all_assignments_f.assignment_id%type,
      p_person_id            in   per_all_people_f.person_id%type,
      p_effective_date       in   date,
      p_primary_hour_value        number,
      p_local_unit                number
   )
      return number;


  function check_national_identifier (
   p_national_identifier   varchar2
   ) return varchar2;


   /******** PROCEDURES FOR WRITING THE REPORT ********/
   type xml_rec_type is record (
      tagname    varchar2 (240),
      tagvalue   varchar2 (240)
   );

   type xml_tab_type is table of xml_rec_type
      index by binary_integer;

   xml_tab                   xml_tab_type;

   procedure populate_details (
      p_business_group_id   in              number,
      p_payroll_action_id   in              varchar2,
      p_template_name       in              varchar2,
      p_xml                 out nocopy      clob
   );

   procedure writetoclob (
      p_xfdf_clob   out nocopy   clob
   );
end pay_no_eerr_continuous;


 

/
