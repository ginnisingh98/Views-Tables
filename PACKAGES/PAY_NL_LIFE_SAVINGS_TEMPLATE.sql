--------------------------------------------------------
--  DDL for Package PAY_NL_LIFE_SAVINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_LIFE_SAVINGS_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pynllssd.pkh 120.1 2007/04/11 04:43:29 rlingama noship $ */

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
	   ,p_er_component                  IN VARCHAR2
	   ,p_arrearage_flag                IN VARCHAR2
	   ,p_ee_deduction_method           IN VARCHAR2
           ,p_er_deduction_method           IN VARCHAR2
	   ,p_saving_scheme_type            IN VARCHAR2
	   ,p_zvw_std_tax_chk               IN VARCHAR2
           ,p_zvw_spl_tax_chk               IN VARCHAR2
           ,p_standard_link                 IN VARCHAR2
           ,p_effective_start_date          IN DATE      DEFAULT NULL
           ,p_effective_end_date            IN DATE      DEFAULT NULL
           ,p_security_group_id             IN NUMBER    DEFAULT NULL
           ,p_business_group_id             IN NUMBER
           )
   RETURN NUMBER ;

-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template_Swi >--------------------|
-- ---------------------------------------------------------------------

FUNCTION Create_User_Template_Swi
        (  p_pension_category              IN VARCHAR2
           ,p_pension_provider_id           IN NUMBER
           ,p_pension_type_id               IN NUMBER
           ,p_scheme_prefix                 IN VARCHAR2
           ,p_reporting_name                IN VARCHAR2
           ,p_scheme_description            IN VARCHAR2
           ,p_termination_rule              IN VARCHAR2
	   ,p_er_component                  IN VARCHAR2
	   ,p_arrearage_flag                IN VARCHAR2
	   ,p_ee_deduction_method           IN VARCHAR2
           ,p_er_deduction_method           IN VARCHAR2
	   ,p_saving_scheme_type            IN VARCHAR2
	   ,p_zvw_std_tax_chk               IN VARCHAR2
           ,p_zvw_spl_tax_chk               IN VARCHAR2
           ,p_standard_link                 IN VARCHAR2
           ,p_effective_start_date          IN DATE      DEFAULT NULL
           ,p_effective_end_date            IN DATE      DEFAULT NULL
           ,p_security_group_id             IN NUMBER    DEFAULT NULL
           ,p_business_group_id             IN NUMBER
          )
   RETURN NUMBER;

-- ---------------------------------------------------------------------
-- |------------------< Delete_User_Template >--------------------------|
-- ---------------------------------------------------------------------

PROCEDURE Delete_User_Template
           (p_savings_plan_id              in Number
           ,p_business_group_id            in Number
           ,p_savings_dedn_ele_name        in Varchar2
           ,p_savings_dedn_ele_type_id     in Number
           ,p_security_group_id            in Number
           ,p_effective_date               in Date
           );

-- ---------------------------------------------------------------------
-- |------------------< Delete_User_Template_Swi >----------------------|
-- ---------------------------------------------------------------------

PROCEDURE  Delete_User_Template_Swi
           (p_savings_plan_id              in Number
           ,p_business_group_id            in Number
           ,p_savings_dedn_ele_name        in Varchar2
           ,p_savings_dedn_ele_type_id     in Number
           ,p_security_group_id            in Number
           ,p_effective_date               in Date
           );

END pay_nl_life_savings_template;

/
