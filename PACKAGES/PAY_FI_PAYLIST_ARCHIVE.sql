--------------------------------------------------------
--  DDL for Package PAY_FI_PAYLIST_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_PAYLIST_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyfipayla.pkh 120.0 2006/01/24 04:16:26 atrivedi noship $ */
   FUNCTION get_balance_value (
      p_balance_name           IN   VARCHAR2,
      p_assignment_action_id   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2,
      p_token              IN   VARCHAR2,
      p_segment_number     IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2;
 PROCEDURE get_all_parameters (
      p_payroll_action_id   IN              NUMBER -- In parameter
                                                  ,
      p_business_group_id   OUT NOCOPY      NUMBER,
      p_start_date          OUT NOCOPY      DATE,
      p_effective_date      OUT NOCOPY      DATE,
      --p_legal_employer_id   OUT NOCOPY      NUMBER,
      p_payroll_id          OUT NOCOPY      NUMBER,
      p_run_payroll_action_id       OUT NOCOPY      NUMBER,
      p_archive             OUT NOCOPY      VARCHAR2
   );

   PROCEDURE range_code (
      p_payroll_action_id   IN              NUMBER,
      p_sql                 OUT NOCOPY      VARCHAR2
   );

   PROCEDURE assignment_action_code (
      p_payroll_action_id   IN   NUMBER,
      p_start_person        IN   NUMBER,
      p_end_person          IN   NUMBER,
      p_chunk               IN   NUMBER
   );

   PROCEDURE initialization_code (p_payroll_action_id IN NUMBER);

   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER,
      p_effective_date         IN   DATE
   );
END pay_fi_paylist_archive;

 

/
