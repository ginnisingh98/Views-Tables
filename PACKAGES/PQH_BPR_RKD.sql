--------------------------------------------------------
--  DDL for Package PQH_BPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BPR_RKD" AUTHID CURRENT_USER as
/* $Header: pqbprrhi.pkh 120.0 2005/05/29 01:33:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_budget_period_id               in number
 ,p_budget_detail_id_o             in number
 ,p_start_time_period_id_o         in number
 ,p_end_time_period_id_o           in number
 ,p_budget_unit1_percent_o         in number
 ,p_budget_unit2_percent_o         in number
 ,p_budget_unit3_percent_o         in number
 ,p_budget_unit1_value_o           in number
 ,p_budget_unit2_value_o           in number
 ,p_budget_unit3_value_o           in number
 ,p_budget_unit1_value_type_cd_o            in varchar2
 ,p_budget_unit2_value_type_cd_o            in varchar2
 ,p_budget_unit3_value_type_cd_o            in varchar2
 ,p_budget_unit1_available_o        in number
 ,p_budget_unit2_available_o        in number
 ,p_budget_unit3_available_o        in number
 ,p_object_version_number_o        in number
  );
--
end pqh_bpr_rkd;

 

/
