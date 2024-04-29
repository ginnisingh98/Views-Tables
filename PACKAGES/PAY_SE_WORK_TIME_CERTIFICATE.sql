--------------------------------------------------------
--  DDL for Package PAY_SE_WORK_TIME_CERTIFICATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_WORK_TIME_CERTIFICATE" AUTHID CURRENT_USER AS
 /* $Header: pysewtcr.pkh 120.0.12010000.8 2008/08/06 08:20:34 ubhat ship $ */


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
     ,p_person_id                OUT NOCOPY NUMBER          -- User parameter
     ,p_assignment_id            OUT NOCOPY VARCHAR2        -- User parameter
     ,p_still_employed           OUT NOCOPY VARCHAR2        -- User parameter
     ,p_income_salary_year       OUT NOCOPY VARCHAR2        -- User parameter
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


--Procedures added for the new version of the Report from 2008

-- For Report
-- Record Created to Update the Break Up of Digits.
TYPE tagdata IS RECORD
        (
            TagName VARCHAR2(240),
            TagValue VARCHAR2(240)
        );
        TYPE ttagdata
        IS TABLE OF tagdata
        INDEX BY BINARY_INTEGER;
        gplsqltable ttagdata;

--Procedure to break up the number into various digits
PROCEDURE get_digit_breakup(
      p_number IN NUMBER,
      p_digit1 OUT NOCOPY NUMBER,
      p_digit2 OUT NOCOPY NUMBER,
      p_digit3 OUT NOCOPY NUMBER,
      p_digit4 OUT NOCOPY NUMBER,
      p_digit5 OUT NOCOPY NUMBER,
      p_digit6 OUT NOCOPY NUMBER,
      p_digit7 OUT NOCOPY NUMBER,
      p_digit8 OUT NOCOPY NUMBER,
      p_digit9 OUT NOCOPY NUMBER,
      p_digit10 OUT NOCOPY NUMBER
   );


 --###############################################################
-- For Report
-- Record for PLsql Table which contains XMl tag and Value
   TYPE xmlrec IS RECORD (
      tagname    VARCHAR2 (240)
     ,tagvalue   VARCHAR2 (240)
   );

   TYPE wtcxml IS TABLE OF xmlrec
      INDEX BY BINARY_INTEGER;

   gwtc_data   wtcxml;

-- Record for PLsql Table which contains XMl tag and Value
-- Proc to Populate the Tag and value into Plsql Table
   PROCEDURE get_xml_for_report (
      p_business_group_id        IN       NUMBER
     ,p_payroll_action_id        IN       VARCHAR2
     ,p_template_name            IN       VARCHAR2
     ,p_xml                      OUT NOCOPY CLOB
   );

-- Proc to Populate the Tag and value into Plsql Table
-- Proc to Convert the Plsql Table to Clob
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB);

-- Proc to Convert the Plsql Table to Clob
-- #############################################################
   FUNCTION get_defined_balance_value (
      p_user_name                IN       VARCHAR2
     ,p_in_assignment_id         IN       NUMBER
     ,p_in_virtual_date          IN       DATE
     ,p_tax_unit_id              IN       NUMBER
     ,p_local_unit_id            IN       NUMBER
   )
      RETURN NUMBER;

   PROCEDURE logger (p_display IN VARCHAR2, p_value IN VARCHAR2);
END pay_se_work_time_certificate;


/
