--------------------------------------------------------
--  DDL for Package PAY_FI_ARCHIVE_UMFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_ARCHIVE_UMFR" AUTHID CURRENT_USER AS
/* $Header: pyfiumfa.pkh 120.0 2006/01/24 03:55:49 atrivedi noship $ */

   FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2,
      p_token              IN   VARCHAR2,
      p_segment_number     IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2;

   PROCEDURE get_all_parameters (
      p_payroll_action_id   IN              NUMBER -- In parameter
                                                  ,
      p_business_group_id   OUT NOCOPY      NUMBER -- Core parameter
                                                  ,
      p_effective_date      OUT NOCOPY      DATE -- Core parameter
                                                ,
      p_trade_union_id      OUT NOCOPY      NUMBER -- User parameter
                                                  ,
      p_legal_employer_id   OUT NOCOPY      NUMBER -- User parameter
                                                  ,
      p_local_unit_id       OUT NOCOPY      NUMBER -- User parameter
                                                  ,
      p_period              OUT NOCOPY      VARCHAR2,
      p_period_end_date     OUT NOCOPY      DATE,
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

   FUNCTION get_country_name (p_territory_code VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_defined_balance_id (p_user_name IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER,
      p_effective_date         IN   DATE
   );
END pay_fi_archive_umfr;

 

/
