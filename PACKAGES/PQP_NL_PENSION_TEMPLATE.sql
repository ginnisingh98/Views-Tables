--------------------------------------------------------
--  DDL for Package PQP_NL_PENSION_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_NL_PENSION_TEMPLATE" AUTHID CURRENT_USER As
/* $Header: pqpnlped.pkh 120.0.12000000.1 2007/01/16 04:24:17 appldev noship $ */

-- Legislation Subgroup Code for all core objects
   g_template_leg_code       VARCHAR2(30):= 'NL';
   g_template_leg_subgroup   VARCHAR2(30);

-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template_Swi >--------------------|
-- ---------------------------------------------------------------------
function Create_User_Template_Swi
           (p_pension_category              In Varchar2
           ,p_eligibility_model             In Varchar2
           ,p_pension_provider_id           In Number
           ,p_pension_type_id               In Number
           ,p_pension_plan_id               In Number    Default Null
           ,p_deduction_method              In Varchar2
           ,p_arrearage_flag                In Varchar2
           ,p_partial_deductions_flag       In Varchar2  Default 'N'
           ,p_employer_component            In Varchar2
           ,p_scheme_prefix                 In Varchar2
           ,p_reporting_name                In Varchar2
           ,p_scheme_description            In Varchar2
           ,p_termination_rule              In Varchar2
           ,p_standard_link                 In Varchar2
           ,p_effective_start_date          In Date      Default Null
           ,p_effective_end_date            In Date      Default Null
           ,p_security_group_id             In Number    Default Null
           ,p_business_group_id             In Number
           )
   return Number;

-- ---------------------------------------------------------------------
-- |------------------< Delete_User_Template_Swi >----------------------|
-- ---------------------------------------------------------------------
procedure Delete_User_Template_Swi
           (p_pension_plan_id              In Number Default Null
           ,p_business_group_id            In Number
           ,p_pension_dedn_ele_name        In Varchar2
           ,p_pension_dedn_ele_type_id     In Number
           ,p_security_group_id            In Number
           ,p_effective_date               In Date
           );

--
-- ---------------------------------------------------------------------
-- |--------------------< Compile_Formula >-----------------------------|
-- ---------------------------------------------------------------------

procedure Compile_Formula
            (p_element_type_id       in Number
            ,p_effective_start_date  in Date
            ,p_scheme_prefix         in Varchar2
            ,p_business_group_id     in Number
            ,p_request_id            out nocopy Number
           );

--
-- ---------------------------------------------------------------------
-- |--------------------< Chk_Scheme_Prefix >---------------------------|
-- ---------------------------------------------------------------------
Procedure chk_scheme_prefix
  (p_scheme_prefix_in              in Varchar2
  );

--
-- ---------------------------------------------------------------------
-- |--------------------< Get_Object_ID >-------------------------------|
-- ---------------------------------------------------------------------
function Get_Object_ID (p_object_type   in Varchar2,
                        p_object_name   in Varchar2,
			p_business_group_id in Number,
			p_template_id in Number)
   return Number;

--
-- ---------------------------------------------------------------------
-- |--------------------< Get_Formula_Id >------------------------------|
-- ---------------------------------------------------------------------
function Get_Formula_Id (p_formula_name      IN VARCHAR2
                        ,p_business_group_id IN NUMBER)
   return Number;

--
-- ---------------------------------------------------------------------
-- |--------------------< Update_Ipval_Defval >------------------------|
-- ---------------------------------------------------------------------
procedure Update_Ipval_Defval(p_ele_name  in Varchar2
                             ,p_ip_name   in Varchar2
                             ,p_def_value in Varchar2
			     ,p_business_group_id in Number);


end pqp_nl_pension_template;

 

/
