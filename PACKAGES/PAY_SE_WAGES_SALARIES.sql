--------------------------------------------------------
--  DDL for Package PAY_SE_WAGES_SALARIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_WAGES_SALARIES" AUTHID CURRENT_USER AS
/* $Header: pysewssa.pkh 120.0.12000000.1 2007/04/24 06:47:12 rsahai noship $ */
/* ############################################################# */
-- For Archive
FUNCTION GET_PARAMETER(p_parameter_string IN VARCHAR2
                      ,p_token            IN VARCHAR2
                      ,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2;



    PROCEDURE get_all_parameters (
      p_payroll_action_id        IN              NUMBER        -- In parameter
    , p_business_group_id        OUT NOCOPY      NUMBER      -- Core parameter
    , p_effective_date           OUT NOCOPY      DATE        -- Core parameter
    , p_legal_employer_id        OUT NOCOPY      NUMBER      -- User parameter
    , p_LU_request   OUT NOCOPY      VARCHAR2    -- User parameter
    , p_LOCAL_UNIT_id        OUT NOCOPY      NUMBER      -- User parameter
    , p_MONTH               OUT NOCOPY      NUMBER         -- User parameter
    , p_YEAR               OUT NOCOPY      NUMBER         -- User parameter
    , p_RETROACTIVE_PAYMENT_FROM	OUT NOCOPY	DATE
    , p_RETROACTIVE_PAYMENT_TO		OUT NOCOPY	DATE
   );

   /* PROCEDURE get_all_parameters (
      p_payroll_action_id        IN              NUMBER        -- In parameter
    , p_business_group_id        OUT NOCOPY      NUMBER      -- Core parameter
    , p_effective_date           OUT NOCOPY      DATE        -- Core parameter
    , p_legal_employer_id        OUT NOCOPY      NUMBER      -- User parameter
    , p_LU_request   OUT NOCOPY      VARCHAR2    -- User parameter
    , p_LOCAL_UNIT_id        OUT NOCOPY      NUMBER      -- User parameter
    ,p_month		OUT NOCOPY	NUMBER
    , p_YEAR               OUT NOCOPY      NUMBER         -- User parameter
    ,p_Retroactive_payment_from OUT NOCOPY DATE
    ,p_Retroactive_payment_to OUT NOCOPY DATE
   ); */

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

-- Proc to Populate the Tag and value into Pl/sql Table
-- Proc to Convert the Pl/sql Table to Clob
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB);

-- Proc to Convert the Pl/sql Table to Clob
/* ############################################################# */
   FUNCTION get_defined_balance_value (
      p_user_name          IN   VARCHAR2
    , p_in_assignment_id   IN   NUMBER
    , p_in_virtual_date    IN   DATE
   )
      RETURN NUMBER;

      PROCEDURE POPULATE_DATA_DETAIL
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2 ,
         p_template_name         IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB);

TYPE xml_rec_type IS RECORD
(
    TagName VARCHAR2(240),
    TagValue VARCHAR2(240)
);
TYPE xml_tab_type
IS TABLE OF xml_rec_type
INDEX BY BINARY_INTEGER;
xml_tab xml_tab_type;

END PAY_SE_WAGES_SALARIES;


 

/
