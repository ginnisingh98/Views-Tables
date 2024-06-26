--------------------------------------------------------
--  DDL for Package PQH_BGT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BGT_RKD" AUTHID CURRENT_USER as
/* $Header: pqbgtrhi.pkh 120.0 2005/05/29 01:31:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_budget_id                      in number
 ,p_business_group_id_o            in number
 ,p_start_organization_id_o        in number
 ,p_org_structure_version_id_o     in number
 ,p_budgeted_entity_cd_o           in varchar2
 ,p_budget_style_cd_o              in varchar2
 ,p_budget_name_o                  in varchar2
 ,p_period_set_name_o              in varchar2
 ,p_budget_start_date_o            in date
 ,p_budget_end_date_o              in date
 ,p_gl_budget_name_o               in varchar2
 ,p_psb_budget_flag_o              in varchar2
 ,p_transfer_to_gl_flag_o          in varchar2
 ,p_transfer_to_grants_flag_o      in varchar2
 ,p_status_o                       in varchar2
 ,p_object_version_number_o        in number
 ,p_budget_unit1_id_o              in number
 ,p_budget_unit2_id_o              in number
 ,p_budget_unit3_id_o              in number
 ,p_gl_set_of_books_id_o           in number
 ,p_budget_unit1_aggregate_o       in varchar2
 ,p_budget_unit2_aggregate_o       in varchar2
 ,p_budget_unit3_aggregate_o       in varchar2
 ,p_position_control_flag_o        in varchar2
 ,p_valid_grade_reqd_flag_o        in varchar2
 ,p_currency_code_o                in varchar2
 ,p_dflt_budget_set_id_o           in number
  );
--
end pqh_bgt_rkd;

 

/
