--------------------------------------------------------
--  DDL for Package PAY_SE_HOLIDAY_PAY_DEBT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_HOLIDAY_PAY_DEBT" AUTHID CURRENT_USER AS
/* $Header: pysehpdr.pkh 120.0.12000000.1 2007/04/20 06:34:06 abhgangu noship $ */
/* ############################################################# */
-- For Archive
   FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2
    , p_token              IN   VARCHAR2
    , p_segment_number     IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2;

   PROCEDURE get_all_parameters (
      p_payroll_action_id        IN              NUMBER       -- In parameter
    , p_business_group_id        OUT NOCOPY      NUMBER     -- Core parameter
    , p_effective_date           OUT NOCOPY      DATE       -- Core parameter
    , p_legal_employer_id        OUT NOCOPY      NUMBER     -- User parameter
    , p_request_for_all_or_not   OUT NOCOPY      VARCHAR2   -- User parameter
    , p_start_date               OUT NOCOPY      DATE       -- User parameter
    , p_end_date                 OUT NOCOPY      DATE
   );

   PROCEDURE range_code (
      p_payroll_action_id   IN              NUMBER
    , p_sql                 OUT NOCOPY      VARCHAR2
   );

   PROCEDURE assignment_action_code (
      p_payroll_action_id   IN   NUMBER
    , p_start_person        IN   NUMBER
    , p_end_person          IN   NUMBER
    , p_chunk               IN   NUMBER
   );

   PROCEDURE initialization_code (p_payroll_action_id IN NUMBER);

   FUNCTION get_defined_balance_id (p_user_name IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER
    , p_effective_date         IN   DATE
   );

/* ############################################################# */
-- For Report
-- Record for PL/sql Table which contains XMl tag and Value
   TYPE xmlrec IS RECORD (
      tagname    VARCHAR2 (240)
    , tagvalue   VARCHAR2 (240)
   );

   TYPE hpdxml IS TABLE OF xmlrec
      INDEX BY BINARY_INTEGER;

   ghpd_data   hpdxml;

-- Record for PL/sql Table which contains XMl tag and Value
-- Proc to Populate the Tag and value into Pl/sql Table
   PROCEDURE get_xml_for_report (
      p_business_group_id   IN              NUMBER
    , p_payroll_action_id   IN              VARCHAR2
    , p_template_name       IN              VARCHAR2
    , p_xml                 OUT NOCOPY      CLOB
   );

-- Proc to Populate the Tag and value into Pl/sql Table
-- Proc to Convert the Pl/sql Table to Clob
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB);

-- Proc to Convert the Pl/sql Table to Clob
/* ############################################################# */
   FUNCTION get_defined_balance_value (
      p_user_name          IN   VARCHAR2
    , p_in_assignment_id   IN   NUMBER
    , p_in_virtual_date    IN   DATE
    , p_tax_unit_id        IN   NUMBER
    , p_local_unit_id      IN   NUMBER
   )
      RETURN NUMBER;
END pay_se_holiday_pay_debt;

 

/
