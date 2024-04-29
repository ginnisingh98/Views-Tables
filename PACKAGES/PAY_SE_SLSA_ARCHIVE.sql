--------------------------------------------------------
--  DDL for Package PAY_SE_SLSA_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_SLSA_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyseslsa.pkh 120.0.12000000.1 2007/07/18 11:12:36 psingla noship $ */
/* ############################################################# */
-- For Archive
   FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2,
      p_token              IN   VARCHAR2,
      p_segment_number     IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2;

   PROCEDURE get_all_parameters (
      p_payroll_action_id        IN              NUMBER -- In parameter
                                                       ,
      p_business_group_id        OUT NOCOPY      NUMBER -- Core parameter
                                                       ,
      p_effective_date           OUT NOCOPY      DATE -- Core parameter
                                                     ,
      p_legal_employer_id        OUT NOCOPY      NUMBER -- User parameter
                                                       ,
      p_request_for_all_or_not   OUT NOCOPY      VARCHAR2 -- User parameter
                                                         ,
      p_start_date               OUT NOCOPY      DATE -- User parameter
                                                     ,
      p_end_date                 OUT NOCOPY      DATE
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

   PROCEDURE initialization_code (
      p_payroll_action_id   IN   NUMBER
   );

   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER,
      p_effective_date         IN   DATE
   );

   PROCEDURE get_schedule_duration (
      p_start_date      IN              DATE,
      p_end_date        IN              DATE,
      p_days_or_hours   IN              VARCHAR2,
      p_duration        IN OUT NOCOPY   NUMBER
   );
END pay_se_slsa_archive;

 

/
