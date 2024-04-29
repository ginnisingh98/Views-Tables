--------------------------------------------------------
--  DDL for Package PAY_IE_PENSION_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PENSION_TEMPLATE" AUTHID CURRENT_USER As
/* $Header: pyiepend.pkh 120.0.12000000.1 2007/01/17 20:54:27 appldev noship $ */
-- Legislation Subgroup Code for all core objects
   g_template_leg_code       VARCHAR2(30):= 'IE';
   g_template_leg_subgroup   VARCHAR2(30);

-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template_Swi >--------------------|
-- ---------------------------------------------------------------------
function Create_User_Template_Swi
           (p_pension_provider_id           In Number
           ,p_pension_type_id               In Number
           ,p_scheme_prefix                 In Varchar2
           ,p_reporting_name                In Varchar2
  	       ,p_prsa2_certificate             In Varchar2
	       ,p_third_party                   In Varchar2
           ,p_termination_rule              In Varchar2
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
           (p_business_group_id            In Number
           ,p_pension_dedn_ele_name        In Varchar2
           ,p_pension_dedn_ele_type_id     In Number
           ,p_security_group_id            In Number
           ,p_effective_date               In Date
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
-- |--------------------< Update_Ipval_Defval >------------------------|
-- ---------------------------------------------------------------------
procedure Update_Ipval_Defval(p_ele_name  in Varchar2
                             ,p_ip_name   in Varchar2
                             ,p_def_value in Varchar2
			     ,p_business_group_id in Number);


end pay_ie_pension_template;

 

/
