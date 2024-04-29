--------------------------------------------------------
--  DDL for Package PQH_WDT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WDT_RKU" AUTHID CURRENT_USER as
/* $Header: pqwdtrhi.pkh 120.0.12000000.1 2007/01/17 00:29:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_worksheet_detail_id            in number
 ,p_worksheet_id                   in number
 ,p_organization_id                in number
 ,p_job_id                         in number
 ,p_position_id                    in number
 ,p_grade_id                       in number
 ,p_position_transaction_id        in number
 ,p_budget_detail_id               in number
 ,p_parent_worksheet_detail_id     in number
 ,p_user_id                        in number
 ,p_action_cd                      in varchar2
 ,p_budget_unit1_percent           in number
 ,p_budget_unit1_value             in number
 ,p_budget_unit2_percent           in number
 ,p_budget_unit2_value             in number
 ,p_budget_unit3_percent           in number
 ,p_budget_unit3_value             in number
 ,p_object_version_number          in number
 ,p_budget_unit1_value_type_cd     in varchar2
 ,p_budget_unit2_value_type_cd     in varchar2
 ,p_budget_unit3_value_type_cd     in varchar2
 ,p_status                         in varchar2
 ,p_budget_unit1_available         in number
 ,p_budget_unit2_available         in number
 ,p_budget_unit3_available         in number
 ,p_old_unit1_value                in number
 ,p_old_unit2_value                in number
 ,p_old_unit3_value                in number
 ,p_defer_flag                     in varchar2
 ,p_propagation_method             in varchar2
 ,p_effective_date                 in date
 ,p_worksheet_id_o                 in number
 ,p_organization_id_o              in number
 ,p_job_id_o                       in number
 ,p_position_id_o                  in number
 ,p_grade_id_o                     in number
 ,p_position_transaction_id_o      in number
 ,p_budget_detail_id_o             in number
 ,p_parent_worksheet_detail_id_o   in number
 ,p_user_id_o                      in number
 ,p_action_cd_o                    in varchar2
 ,p_budget_unit1_percent_o         in number
 ,p_budget_unit1_value_o           in number
 ,p_budget_unit2_percent_o         in number
 ,p_budget_unit2_value_o           in number
 ,p_budget_unit3_percent_o         in number
 ,p_budget_unit3_value_o           in number
 ,p_object_version_number_o        in number
 ,p_budget_unit1_value_type_cd_o   in varchar2
 ,p_budget_unit2_value_type_cd_o   in varchar2
 ,p_budget_unit3_value_type_cd_o   in varchar2
 ,p_status_o                       in varchar2
 ,p_budget_unit1_available_o       in number
 ,p_budget_unit2_available_o       in number
 ,p_budget_unit3_available_o       in number
 ,p_old_unit1_value_o              in number
 ,p_old_unit2_value_o              in number
 ,p_old_unit3_value_o              in number
 ,p_defer_flag_o                   in varchar2
 ,p_propagation_method_o           in varchar2
  );
--
end pqh_wdt_rku;

 

/