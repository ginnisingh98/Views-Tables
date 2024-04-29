--------------------------------------------------------
--  DDL for Package PAY_NO_EERR_STATUS_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_EERR_STATUS_CONTROL" AUTHID CURRENT_USER AS
/* $Header: pynoeers.pkh 120.0.12000000.1 2007/05/22 06:28:24 rajesrin noship $ */

--------------------------------------------------------------------------------
-- Global Variables
--------------------------------------------------------------------------------
--
g_public_org_flag hr_lookups.lookup_type%TYPE;
g_risk_cover_flag hr_lookups.lookup_type%TYPE;
g_contract_code_mapping hr_lookups.lookup_type%TYPE;
--
--------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS
--------------------------------------------------------------------------------
procedure get_all_parameters (
      p_payroll_action_id   in              number,
      p_business_group_id   out nocopy      number,
      p_legal_employer_id   out nocopy      number,
      p_archive             out nocopy      varchar2,
    --  p_start_date          out nocopy      date,
    --  p_end_date          out nocopy      date,
      p_effective_date      out nocopy      date
    --  p_report_mode         out nocopy      varchar2
   );
--------------------------------------------------------------------------------
-- GET_PARAMETERS
--------------------------------------------------------------------------------
FUNCTION GET_PARAMETER(
		 p_parameter_string IN VARCHAR2
		,p_token            IN VARCHAR2
		,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2;
--------------------------------------------------------------------------------
-- RANGE_CODE
--------------------------------------------------------------------------------
procedure range_code (
      p_payroll_action_id   in              number,
      p_sql                 out nocopy      varchar2
   );
 ---------------------------------------  PROCEDURE ARCHIVE_EMPLOYEE_DETAILS -----------------------------------------------------------
/* EMPLOYEE DETAILS REGION */
  PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
			      ,p_effective_date    IN DATE);
 PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER);
 PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER);

PROCEDURE sort_changes(p_detail_tab IN OUT NOCOPY pay_interpreter_pkg.t_detailed_output_table_type);

PROCEDURE copy(p_copy_from IN OUT NOCOPY pay_interpreter_pkg.t_detailed_output_table_type
              ,p_from      IN            NUMBER
              ,p_copy_to   IN OUT NOCOPY pay_interpreter_pkg.t_detailed_output_table_type
              ,p_to        IN            NUMBER);



 FUNCTION GET_ASSIGNMENT_ALL_HOURS

(P_ASSIGNMENT_ID IN per_all_assignments_f.assignment_id%type,
 P_PERSON_ID     IN per_all_people_f.person_id%type,
 P_EFFECTIVE_DATE IN DATE,
 P_PRIMARY_HOUR_VALUE NUMBER,
 p_local_unit   number) RETURN number ;

function check_national_identifier (
   p_national_identifier   varchar2
) return varchar2;


   function find_total_hour (
         p_hours       in   number,
         p_frequency   in   varchar2
      )
         return number;

/******** PROCEDURES FOR WRITING THE REPORT ********/

TYPE xml_rec_type IS RECORD
(
    TagName VARCHAR2(240),
    TagValue VARCHAR2(240)
);

TYPE xml_tab_type
IS TABLE OF xml_rec_type
INDEX BY BINARY_INTEGER;

xml_tab xml_tab_type;

         PROCEDURE populate_details
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2 ,
         p_template_name         IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB);


PROCEDURE WritetoCLOB
        (p_xfdf_clob             OUT NOCOPY CLOB);


END PAY_NO_EERR_STATUS_CONTROL;

 

/
