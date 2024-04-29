--------------------------------------------------------
--  DDL for Package PQP_NL_PGGM_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_NL_PGGM_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pqpggped.pkh 120.0.12000000.1 2007/01/16 04:19:28 appldev noship $ */

-- Legislation Subgroup Code for all core objects

   g_template_leg_code       VARCHAR2(30):= 'NL';
   g_template_leg_subgroup   VARCHAR2(30);

   TYPE g_creator_rec IS RECORD(
     type             pay_retro_component_usages.creator_type%TYPE,
     name             varchar2(100),
     id               number);

   TYPE g_component_rec IS RECORD(
     name                     pay_retro_components.component_name%TYPE,
     id                       pay_retro_components.retro_component_id%TYPE,
     type                     pay_retro_components.retro_type%TYPE,
     start_time_def_name      pay_time_definitions.definition_name%TYPE,
     end_time_def_name        pay_time_definitions.definition_name%TYPE,
     time_span_id             pay_time_spans.time_span_id%TYPE);

   TYPE g_component_tab is table of g_component_rec INDEX BY BINARY_INTEGER;

   TYPE g_retro_ele_rec IS RECORD(
     name       pay_element_types_f.element_name%TYPE,
     id         pay_element_types_f.element_type_id%TYPE);

   g_creator          g_creator_rec;
   g_component        g_component_tab;
   g_retro_ele        g_retro_ele_rec;
   g_legislation_code CONSTANT VARCHAR2(2):= 'NL';
   g_retro_def_name   CONSTANT VARCHAR2(30) := 'Standard Retropay';


-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template >------------------------|
-- ---------------------------------------------------------------------
FUNCTION Create_User_Template
           (p_pension_category              IN VARCHAR2
           ,p_pension_provider_id           IN NUMBER
           ,p_pension_type_id               IN NUMBER
           ,p_scheme_prefix                 IN VARCHAR2
           ,p_reporting_name                IN VARCHAR2
           ,p_scheme_description            IN VARCHAR2
           ,p_termination_rule              IN VARCHAR2
           ,p_standard_link                 IN VARCHAR2
           ,p_effective_start_date          IN DATE      DEFAULT NULL
           ,p_effective_end_date            IN DATE      DEFAULT NULL
           ,p_security_group_id             IN NUMBER    DEFAULT NULL
           ,p_business_group_id             IN NUMBER
           ,p_basis_rounding                IN VARCHAR2
           ,p_contrib_rounding              IN VARCHAR2
           ,p_link_dedn_elements            IN VARCHAR2
           ,p_link_retro_elements           IN VARCHAR2
           )
   RETURN NUMBER ;

-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template_Swi >--------------------|
-- ---------------------------------------------------------------------

FUNCTION Create_User_Template_Swi
           (p_pension_category              IN VARCHAR2
           ,p_pension_provider_id           IN NUMBER
           ,p_pension_type_id               IN NUMBER
           ,p_scheme_prefix                 IN VARCHAR2
           ,p_reporting_name                IN VARCHAR2
           ,p_scheme_description            IN VARCHAR2
           ,p_termination_rule              IN VARCHAR2
           ,p_standard_link                 IN VARCHAR2
           ,p_effective_start_date          IN DATE      DEFAULT NULL
           ,p_effective_end_date            IN DATE      DEFAULT NULL
           ,p_security_group_id             IN NUMBER    DEFAULT NULL
           ,p_business_group_id             IN NUMBER
           ,p_basis_rounding                IN VARCHAR2
           ,p_contrib_rounding              IN VARCHAR2
           ,p_link_dedn_elements            IN VARCHAR2
           ,p_link_retro_elements           IN VARCHAR2
           )
   RETURN NUMBER;

-- ---------------------------------------------------------------------
-- |------------------< Delete_User_Template >--------------------------|
-- ---------------------------------------------------------------------

PROCEDURE Delete_User_Template
           (p_business_group_id            IN NUMBER
           ,p_pension_dedn_ele_name        IN VARCHAR2
           ,p_pension_dedn_ele_type_id     IN NUMBER
           ,p_security_group_id            IN NUMBER
           ,p_effective_date               IN DATE
           );

-- ---------------------------------------------------------------------
-- |------------------< Delete_User_Template_Swi >----------------------|
-- ---------------------------------------------------------------------

PROCEDURE Delete_User_Template_Swi
           (p_business_group_id            IN NUMBER
           ,p_pension_dedn_ele_name        IN VARCHAR2
           ,p_pension_dedn_ele_type_id     IN NUMBER
           ,p_security_group_id            IN NUMBER
           ,p_effective_date               IN DATE
           );

END pqp_nl_pggm_template;

 

/