--------------------------------------------------------
--  DDL for Package PQH_BCE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BCE_RKD" AUTHID CURRENT_USER as
/* $Header: pqbcerhi.pkh 120.0 2005/05/29 01:27:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_bdgt_cmmtmnt_elmnt_id          in number
 ,p_budget_id_o                    in number
 ,p_actual_commitment_type_o       in varchar2
 ,p_element_type_id_o              in number
 ,p_salary_basis_flag_o            in varchar2
 ,p_element_input_value_id_o       in number
 ,p_balance_type_id_o              in number
 ,p_frequency_input_value_id_o     in number
 ,p_formula_id_o                   in number
 ,p_dflt_elmnt_frequency_o         in varchar2
 ,p_overhead_percentage_o          in number
 ,p_object_version_number_o        in number
  );
--
end pqh_bce_rkd;

 

/
