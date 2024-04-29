--------------------------------------------------------
--  DDL for Package PQH_BST_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BST_RKI" AUTHID CURRENT_USER as
/* $Header: pqbstrhi.pkh 120.0 2005/05/29 01:35:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_budget_set_id                  in number
 ,p_dflt_budget_set_id             in number
 ,p_budget_period_id               in number
 ,p_budget_unit1_percent           in number
 ,p_budget_unit2_percent           in number
 ,p_budget_unit3_percent           in number
 ,p_budget_unit1_value             in number
 ,p_budget_unit2_value             in number
 ,p_budget_unit3_value             in number
 ,p_budget_unit1_available          in number
 ,p_budget_unit2_available          in number
 ,p_budget_unit3_available          in number
 ,p_object_version_number          in number
 ,p_budget_unit1_value_type_cd     in varchar2
 ,p_budget_unit2_value_type_cd     in varchar2
 ,p_budget_unit3_value_type_cd     in varchar2
 ,p_effective_date                 in date
  );
end pqh_bst_rki;

 

/
