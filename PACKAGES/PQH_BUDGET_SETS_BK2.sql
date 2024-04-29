--------------------------------------------------------
--  DDL for Package PQH_BUDGET_SETS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_SETS_BK2" AUTHID CURRENT_USER as
/* $Header: pqbstapi.pkh 120.1 2005/10/02 02:26:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_set_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_set_b
  (
   p_budget_set_id                  in  number
  ,p_dflt_budget_set_id             in  number
  ,p_budget_period_id               in  number
  ,p_budget_unit1_percent           in  number
  ,p_budget_unit2_percent           in  number
  ,p_budget_unit3_percent           in  number
  ,p_budget_unit1_value             in  number
  ,p_budget_unit2_value             in  number
  ,p_budget_unit3_value             in  number
  ,p_budget_unit1_available          in  number
  ,p_budget_unit2_available          in  number
  ,p_budget_unit3_available          in  number
  ,p_object_version_number          in  number
  ,p_budget_unit1_value_type_cd     in  varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_set_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_set_a
  (
   p_budget_set_id                  in  number
  ,p_dflt_budget_set_id             in  number
  ,p_budget_period_id               in  number
  ,p_budget_unit1_percent           in  number
  ,p_budget_unit2_percent           in  number
  ,p_budget_unit3_percent           in  number
  ,p_budget_unit1_value             in  number
  ,p_budget_unit2_value             in  number
  ,p_budget_unit3_value             in  number
  ,p_budget_unit1_available          in  number
  ,p_budget_unit2_available          in  number
  ,p_budget_unit3_available          in  number
  ,p_object_version_number          in  number
  ,p_budget_unit1_value_type_cd     in  varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2
  ,p_effective_date                 in  date
  );
--
end pqh_budget_sets_bk2;

 

/
