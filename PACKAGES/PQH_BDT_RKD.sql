--------------------------------------------------------
--  DDL for Package PQH_BDT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDT_RKD" AUTHID CURRENT_USER as
/* $Header: pqbdtrhi.pkh 120.0 2005/05/29 01:28:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_budget_detail_id               in number
 ,p_organization_id_o              in number
 ,p_job_id_o                       in number
 ,p_position_id_o                  in number
 ,p_grade_id_o                     in number
 ,p_budget_version_id_o            in number
 ,p_budget_unit1_percent_o         in number
 ,p_budget_unit1_value_type_cd_o            in varchar2
 ,p_budget_unit1_value_o           in number
 ,p_budget_unit1_available_o        in number
 ,p_budget_unit2_percent_o         in number
 ,p_budget_unit2_value_type_cd_o            in varchar2
 ,p_budget_unit2_value_o           in number
 ,p_budget_unit2_available_o        in number
 ,p_budget_unit3_percent_o         in number
 ,p_budget_unit3_value_type_cd_o            in varchar2
 ,p_budget_unit3_value_o           in number
 ,p_budget_unit3_available_o        in number
 ,p_gl_status_o                             in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_bdt_rkd;

 

/
