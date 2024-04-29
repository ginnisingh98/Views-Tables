--------------------------------------------------------
--  DDL for Package PQH_BGT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BGT_RKI" AUTHID CURRENT_USER as
/* $Header: pqbgtrhi.pkh 120.0 2005/05/29 01:31:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_budget_id                      in number
 ,p_business_group_id              in number
 ,p_start_organization_id          in number
 ,p_org_structure_version_id       in number
 ,p_budgeted_entity_cd             in varchar2
 ,p_budget_style_cd                in varchar2
 ,p_budget_name                    in varchar2
 ,p_period_set_name                in varchar2
 ,p_budget_start_date              in date
 ,p_budget_end_date                in date
 ,p_gl_budget_name                 in varchar2
 ,p_psb_budget_flag                in varchar2
 ,p_transfer_to_gl_flag            in varchar2
 ,p_transfer_to_grants_flag        in varchar2
 ,p_status                         in varchar2
 ,p_object_version_number          in number
 ,p_budget_unit1_id                in number
 ,p_budget_unit2_id                in number
 ,p_budget_unit3_id                in number
 ,p_gl_set_of_books_id             in number
 ,p_budget_unit1_aggregate         in varchar2
 ,p_budget_unit2_aggregate         in varchar2
 ,p_budget_unit3_aggregate         in varchar2
 ,p_position_control_flag          in varchar2
 ,p_valid_grade_reqd_flag          in varchar2
 ,p_currency_code                  in varchar2
 ,p_dflt_budget_set_id             in number
 ,p_effective_date                 in date
  );
end pqh_bgt_rki;

 

/
