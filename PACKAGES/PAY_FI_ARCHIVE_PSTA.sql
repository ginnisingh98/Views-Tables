--------------------------------------------------------
--  DDL for Package PAY_FI_ARCHIVE_PSTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_ARCHIVE_PSTA" AUTHID CURRENT_USER AS
/* $Header: pyfipsta.pkh 120.0.12000000.1 2007/04/26 12:12:47 dbehera noship $ */

  FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2,
      p_token              IN   VARCHAR2,
      p_segment_number     IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2;
  procedure get_all_parameters (
      p_payroll_action_id   in              number,
      p_business_group_id   out nocopy      number,
      p_legal_employer_id   out nocopy      number,
      p_local_unit_id       out nocopy      number,
      p_year                out nocopy      varchar2,
      p_payroll_type_code   out nocopy      varchar2,
      p_payroll_id          out nocopy      varchar2,
      p_archive             out nocopy      varchar2,
      p_effective_date      out nocopy      date
   ) ;

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

   procedure archive_data (
      p_arch_assignment_action_id      in number,
      p_assignment_action_id     in number,
      p_assignment_id            in number
   ) ;
   procedure archive_person_address_details (
      p_person_id   number,
      p_assignment_action_id number,
      p_assignment_id   number
   );
   FUNCTION GET_COUNTRY_NAME(p_territory_code VARCHAR2) RETURN VARCHAR2;

   function get_balance_value (
      p_balance_name           in   varchar2,
      p_assignment_id          in   number,
      p_database_item_suffix   in   varchar2,
      p_bal_date               in   date
   )
      RETURN NUMBER;
END  PAY_FI_ARCHIVE_PSTA;

 

/
