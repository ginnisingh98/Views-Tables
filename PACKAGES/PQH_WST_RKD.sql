--------------------------------------------------------
--  DDL for Package PQH_WST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WST_RKD" AUTHID CURRENT_USER as
/* $Header: pqwstrhi.pkh 120.0 2005/05/29 03:04:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_worksheet_budget_set_id        in number
 ,p_dflt_budget_set_id_o           in number
 ,p_worksheet_period_id_o          in number
 ,p_budget_unit1_percent_o         in number
 ,p_budget_unit2_percent_o         in number
 ,p_budget_unit3_percent_o         in number
 ,p_budget_unit1_value_o           in number
 ,p_budget_unit2_value_o           in number
 ,p_budget_unit3_value_o           in number
 ,p_object_version_number_o        in number
 ,p_budget_unit1_value_type_cd_o   in varchar2
 ,p_budget_unit2_value_type_cd_o   in varchar2
 ,p_budget_unit3_value_type_cd_o   in varchar2
 ,p_budget_unit1_available_o       in number
 ,p_budget_unit2_available_o       in number
 ,p_budget_unit3_available_o       in number
  );
--
end pqh_wst_rkd;

 

/