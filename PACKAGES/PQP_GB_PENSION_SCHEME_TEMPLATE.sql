--------------------------------------------------------
--  DDL for Package PQP_GB_PENSION_SCHEME_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PENSION_SCHEME_TEMPLATE" 
/* $Header: pqpgbped.pkh 120.1 2006/03/28 10:09:34 anshghos noship $ */
AUTHID CURRENT_USER AS


   -- Global Constants

   g_template_leg_code   VARCHAR2 (30)                              := 'GB';
   g_template_name       pay_element_templates.template_name%TYPE
                                                              := 'GB Pensions';


------------------------------------------------------------------------
   FUNCTION create_user_template (
      p_pension_scheme_name       IN   VARCHAR2
     ,p_pension_year_start_dt     IN   DATE
     ,p_pension_category          IN   VARCHAR2
     ,p_pension_provider_id       IN   NUMBER
     ,p_pension_type_id           IN   NUMBER
     ,p_emp_deduction_method      IN   VARCHAR2
     ,p_ele_base_name             IN   VARCHAR2
     ,p_effective_start_date      IN   DATE
     ,p_ele_reporting_name        IN   VARCHAR2
     ,p_ele_classification_id     IN   NUMBER
     ,p_business_group_id         IN   NUMBER
     ,p_eer_deduction_method      IN   VARCHAR2 DEFAULT NULL
     ,p_scon_number               IN   VARCHAR2 DEFAULT NULL
     ,p_econ_number               IN   VARCHAR2 DEFAULT NULL
     ,p_additional_contribution   IN   VARCHAR2 DEFAULT NULL
     ,p_added_years               IN   VARCHAR2 DEFAULT NULL
     ,p_family_widower            IN   VARCHAR2 DEFAULT NULL
     ,p_fwc_added_years           IN   VARCHAR2 DEFAULT NULL
     ,p_scheme_reference_no       IN   VARCHAR2 DEFAULT NULL
     ,p_employer_reference_no     IN   VARCHAR2 DEFAULT NULL
     ,p_associated_ocp_ele_id     IN   NUMBER DEFAULT NULL
     ,p_ele_description           IN   VARCHAR2 DEFAULT NULL
     ,p_pension_scheme_type       IN   VARCHAR2 DEFAULT NULL
     ,p_pensionable_sal_bal_id    IN   NUMBER DEFAULT NULL
     ,p_third_party_only_flag     IN   VARCHAR2 DEFAULT NULL
     ,p_iterative_processing      IN   VARCHAR2 DEFAULT 'N'
     ,p_arrearage_allowed         IN   VARCHAR2 DEFAULT 'N'
     ,p_partial_deduction         IN   VARCHAR2 DEFAULT 'N'
     ,p_termination_rule          IN   VARCHAR2 DEFAULT 'L'
     ,p_standard_link             IN   VARCHAR2 DEFAULT 'N'
   )
      RETURN NUMBER;

   FUNCTION create_user_template_swi (
      p_pension_scheme_name       IN   VARCHAR2
     ,p_pension_year_start_dt     IN   DATE
     ,p_pension_category          IN   VARCHAR2
     ,p_pension_provider_id       IN   NUMBER
     ,p_pension_type_id           IN   NUMBER
     ,p_emp_deduction_method      IN   VARCHAR2
     ,p_ele_base_name             IN   VARCHAR2
     ,p_effective_start_date      IN   DATE
     ,p_ele_reporting_name        IN   VARCHAR2
     ,p_ele_classification_id     IN   NUMBER
     ,p_business_group_id         IN   NUMBER
     ,p_eer_deduction_method      IN   VARCHAR2 DEFAULT NULL
     ,p_scon_number               IN   VARCHAR2 DEFAULT NULL
     ,p_econ_number               IN   VARCHAR2 DEFAULT NULL
     ,p_additional_contribution   IN   VARCHAR2 DEFAULT NULL
     ,p_added_years               IN   VARCHAR2 DEFAULT NULL
     ,p_family_widower            IN   VARCHAR2 DEFAULT NULL
     ,p_fwc_added_years               IN   VARCHAR2 DEFAULT NULL
     ,p_scheme_reference_no       IN   VARCHAR2 DEFAULT NULL
     ,p_employer_reference_no     IN   VARCHAR2 DEFAULT NULL
     ,p_associated_ocp_ele_id     IN   NUMBER DEFAULT NULL
     ,p_ele_description           IN   VARCHAR2 DEFAULT NULL
     ,p_pension_scheme_type       IN   VARCHAR2 DEFAULT NULL
     ,p_pensionable_sal_bal_id    IN   NUMBER DEFAULT NULL
     ,p_third_party_only_flag     IN   VARCHAR2 DEFAULT NULL
     ,p_iterative_processing      IN   VARCHAR2 DEFAULT 'N'
     ,p_arrearage_allowed         IN   VARCHAR2 DEFAULT 'N'
     ,p_partial_deduction         IN   VARCHAR2 DEFAULT 'N'
     ,p_termination_rule          IN   VARCHAR2 DEFAULT 'L'
     ,p_standard_link             IN   VARCHAR2 DEFAULT 'N'
   )
      RETURN NUMBER;


--
   PROCEDURE delete_user_template (
      p_business_group_id   IN   NUMBER
     ,p_ele_base_name       IN   VARCHAR2
     ,p_element_type_id     IN   NUMBER
     ,p_effective_date      IN   DATE
   );


--

   PROCEDURE delete_user_template_swi (
      p_business_group_id   IN   NUMBER
     ,p_ele_base_name       IN   VARCHAR2
     ,p_element_type_id     IN   NUMBER
     ,p_effective_date      IN   DATE
   );
--

END pqp_gb_pension_scheme_template;

 

/
