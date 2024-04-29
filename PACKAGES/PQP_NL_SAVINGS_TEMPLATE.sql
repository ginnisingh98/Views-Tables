--------------------------------------------------------
--  DDL for Package PQP_NL_SAVINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_NL_SAVINGS_TEMPLATE" AUTHID CURRENT_USER As
/* $Header: pqpnlsad.pkh 120.1.12000000.1 2007/01/16 04:24:44 appldev noship $ */

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
-- |------------------< Create_User_Template_Swi >----------------------|
-- ---------------------------------------------------------------------
function Create_User_Template_Swi
           (p_pension_category              In Varchar2
           ,p_eligibility_model             In Varchar2
           ,p_pension_provider_id           In Number
           ,p_pension_type_id               In Number
           ,p_pension_plan_id               In Number    Default Null
           ,p_deduction_method              In Varchar2
	   ,p_saving_scheme_type            In Varchar2
           ,p_arrearage_flag                In Varchar2
           ,p_partial_deductions_flag       In Varchar2  Default 'N'
           ,p_employer_component            In Varchar2
           ,p_scheme_prefix                 In Varchar2
           ,p_reporting_name                In Varchar2
           ,p_scheme_description            In Varchar2
           ,p_termination_rule              In Varchar2
	   ,p_zvw_std_tax_chk               IN VARCHAR2
           ,p_zvw_spl_tax_chk               IN VARCHAR2
           ,p_standard_link                 In Varchar2
           ,p_effective_start_date          In Date      Default Null
           ,p_effective_end_date            In Date      Default Null
           ,p_security_group_id             In Number    Default Null
           ,p_business_group_id             In Number
           )
   return Number;

-- ---------------------------------------------------------------------
-- |--------------------< Delete_User_Template_Swi >--------------------|
-- ---------------------------------------------------------------------
procedure Delete_User_Template_Swi
           (p_savings_plan_id              In Number Default Null
           ,p_business_group_id            In Number
           ,p_savings_dedn_ele_name        In Varchar2
           ,p_savings_dedn_ele_type_id     In Number
           ,p_security_group_id            In Number
           ,p_effective_date               In Date
           );

--

end pqp_nl_savings_template;

 

/
