--------------------------------------------------------
--  DDL for Package PAY_SE_ALECTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_ALECTA" AUTHID CURRENT_USER AS
/* $Header: pysealer.pkh 120.0.12010000.2 2008/12/23 14:12:48 rsengupt ship $ */
/* ############################################################# */
-- For Archive
   FUNCTION get_parameter (
      p_parameter_string         IN       VARCHAR2
     ,p_token                    IN       VARCHAR2
     ,p_segment_number           IN       NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2;

   PROCEDURE get_all_parameters (
      p_payroll_action_id        IN       NUMBER              -- In parameter
     ,p_business_group_id        OUT NOCOPY NUMBER          -- Core parameter
     ,p_effective_date           OUT NOCOPY DATE            -- Core parameter
     ,p_legal_employer_id        OUT NOCOPY NUMBER          -- User parameter
     ,p_request_for_all_or_not   OUT NOCOPY VARCHAR2        -- User parameter
     ,p_year                     OUT NOCOPY NUMBER          -- User parameter
     ,p_month                    OUT NOCOPY VARCHAR2
     ,p_sent_from                OUT NOCOPY VARCHAR2
     ,p_sent_to                  OUT NOCOPY VARCHAR2
     ,p_production               OUT NOCOPY VARCHAR2
   );

   PROCEDURE range_code (
      p_payroll_action_id        IN       NUMBER
     ,p_sql                      OUT NOCOPY VARCHAR2
   );

   PROCEDURE assignment_action_code (
      p_payroll_action_id        IN       NUMBER
     ,p_start_person             IN       NUMBER
     ,p_end_person               IN       NUMBER
     ,p_chunk                    IN       NUMBER
   );

   PROCEDURE initialization_code (p_payroll_action_id IN NUMBER);

   FUNCTION get_defined_balance_id (p_user_name IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE archive_code (
      p_assignment_action_id     IN       NUMBER
     ,p_effective_date           IN       DATE
   );

/* ############################################################# */
-- For Report
-- Record for PL/sql Table which contains XMl tag and Value
   TYPE xmlrec IS RECORD (
      tagname       VARCHAR2 (240)
     ,tagvalue      VARCHAR2 (240)
     ,eventnumber   NUMBER
   );

   TYPE hpdxml IS TABLE OF xmlrec
      INDEX BY BINARY_INTEGER;

   ghpd_data               hpdxml;

-- Record for PL/sql Table which contains XMl tag and Value
   TYPE event_row IS RECORD (
      event_code        VARCHAR (240)
     ,bal_ele           VARCHAR2 (240)
     ,balance_type_id   VARCHAR2 (240)
     ,element_type_id   VARCHAR2 (240)
     ,input_value_id    VARCHAR2 (240)
   );

   TYPE event_rows IS TABLE OF event_row
      INDEX BY VARCHAR2 (64);

   TYPE FIELD IS RECORD (
      disp_name    VARCHAR (240)
     ,events_row   event_rows
   );

   TYPE FIELDS IS TABLE OF FIELD
      INDEX BY VARCHAR2 (64);

   TYPE each_le IS RECORD (
      organization_id   VARCHAR2 (240)
     ,field_code        FIELDS
   );

   TYPE each_le_record IS TABLE OF each_le
      INDEX BY BINARY_INTEGER;

   record_legal_employer   each_le_record;

-- Proc to Populate the Tag and value into Pl/sql Table
   PROCEDURE get_xml_for_report (
      p_business_group_id        IN       NUMBER
     ,p_payroll_action_id        IN       VARCHAR2
     ,p_template_name            IN       VARCHAR2
     ,p_xml                      OUT NOCOPY CLOB
   );

-- Proc to Populate the Tag and value into Pl/sql Table
-- Proc to Convert the Pl/sql Table to Clob
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB);

-- Proc to Convert the Pl/sql Table to Clob
/* ############################################################# */
   FUNCTION get_defined_balance_value (
      p_balance_type_id          IN       NUMBER
     ,p_dimension                IN       VARCHAR2
     ,p_in_assignment_id         IN       NUMBER
     ,p_in_virtual_date          IN       DATE
   )
      RETURN NUMBER;

   PROCEDURE logger (p_display IN VARCHAR2, p_value IN VARCHAR2);

   g_start_date            DATE;
   g_end_date              DATE;

   PROCEDURE get_assignment_lvl_info (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_organization_number      OUT NOCOPY VARCHAR2
     ,p_cost_centre              OUT NOCOPY VARCHAR2
   );

   PROCEDURE get_person_lvl_info (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_pin                      OUT NOCOPY VARCHAR2
     ,p_first_name               OUT NOCOPY VARCHAR2
     ,p_last_name                OUT NOCOPY VARCHAR2
     ,p_born_1979                OUT NOCOPY VARCHAR2
   );

   PROCEDURE get_in_time_of_event (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_event_date               OUT NOCOPY DATE
   );

   PROCEDURE get_salary (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_before_after             IN       VARCHAR2
     ,p_event                    IN       VARCHAR2
     ,p_monthly_salary           OUT NOCOPY NUMBER
     ,p_yearly_salary            OUT NOCOPY NUMBER
     ,p_annual_salary            OUT NOCOPY NUMBER  -- changes 2008/2009
   );

   PROCEDURE get_org_lvl_info (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_local_unit_id            OUT NOCOPY NUMBER
     ,p_legal_employer_id        OUT NOCOPY NUMBER
     ,p_location_id              OUT NOCOPY NUMBER
   );

   PROCEDURE get_absence_lvl_info (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_fully_capable            OUT NOCOPY VARCHAR2
     ,p_inability_to_work        OUT NOCOPY VARCHAR2
   );

   PROCEDURE get_salary_change_or_not (
      p_assignment_id            IN       NUMBER
     ,p_new_salary               OUT NOCOPY VARCHAR2
     ,p_event_time               OUT NOCOPY DATE
   );

   PROCEDURE get_salary_cut (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_salary_cut               OUT NOCOPY VARCHAR2
   );

   PROCEDURE get_end_employment_or_not (
      p_assignment_id            IN       NUMBER
     ,p_withdrawl                OUT NOCOPY VARCHAR2
     ,p_event_time               OUT NOCOPY DATE
     ,p_reason                   OUT NOCOPY VARCHAR2
     ,p_effective_date           OUT NOCOPY DATE
   );

   PROCEDURE get_termination_or_not (
      p_assignment_id            IN       NUMBER
     ,p_field_code               IN       VARCHAR2
     ,p_withdrawl                OUT NOCOPY VARCHAR2
     ,p_event_time               OUT NOCOPY DATE
     ,p_reason                   OUT NOCOPY VARCHAR2
     ,p_effective_date           OUT NOCOPY DATE
     ,p_parental_start_date      OUT NOCOPY DATE
   );
END pay_se_alecta;

/
