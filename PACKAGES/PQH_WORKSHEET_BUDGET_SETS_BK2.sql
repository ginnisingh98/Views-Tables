--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_BUDGET_SETS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_BUDGET_SETS_BK2" AUTHID CURRENT_USER as
/* $Header: pqwstapi.pkh 120.0 2005/05/29 03:03:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_WORKSHEET_BUDGET_SET_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_WORKSHEET_BUDGET_SET_b
  (
   p_worksheet_budget_set_id        in  number
  ,p_dflt_budget_set_id             in  number
  ,p_worksheet_period_id            in  number
  ,p_budget_unit1_percent           in  number
  ,p_budget_unit2_percent           in  number
  ,p_budget_unit3_percent           in  number
  ,p_budget_unit1_value             in  number
  ,p_budget_unit2_value             in  number
  ,p_budget_unit3_value             in  number
  ,p_object_version_number          in  number
  ,p_budget_unit1_value_type_cd     in  varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2
  ,p_budget_unit1_available         in  number
  ,p_budget_unit2_available         in  number
  ,p_budget_unit3_available         in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_WORKSHEET_BUDGET_SET_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_WORKSHEET_BUDGET_SET_a
  (
   p_worksheet_budget_set_id        in  number
  ,p_dflt_budget_set_id             in  number
  ,p_worksheet_period_id            in  number
  ,p_budget_unit1_percent           in  number
  ,p_budget_unit2_percent           in  number
  ,p_budget_unit3_percent           in  number
  ,p_budget_unit1_value             in  number
  ,p_budget_unit2_value             in  number
  ,p_budget_unit3_value             in  number
  ,p_object_version_number          in  number
  ,p_budget_unit1_value_type_cd     in  varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2
  ,p_budget_unit1_available         in  number
  ,p_budget_unit2_available         in  number
  ,p_budget_unit3_available         in  number
  ,p_effective_date                 in  date
  );
--
end pqh_WORKSHEET_BUDGET_SETS_bk2;

 

/
