--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_PERIODS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_PERIODS_BK1" AUTHID CURRENT_USER as
/* $Header: pqwprapi.pkh 120.0 2005/05/29 03:02:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WORKSHEET_PERIOD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_PERIOD_b
  (
   p_end_time_period_id             in  number
  ,p_worksheet_detail_id            in  number
  ,p_budget_unit1_percent           in  number
  ,p_budget_unit2_percent           in  number
  ,p_budget_unit3_percent           in  number
  ,p_budget_unit1_value             in  number
  ,p_budget_unit2_value             in  number
  ,p_budget_unit3_value             in  number
  ,p_budget_unit1_value_type_cd     in  varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2
  ,p_start_time_period_id           in  number
  ,p_budget_unit3_available         in  number
  ,p_budget_unit2_available         in  number
  ,p_budget_unit1_available         in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WORKSHEET_PERIOD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_PERIOD_a
  (
   p_worksheet_period_id            in  number
  ,p_end_time_period_id             in  number
  ,p_worksheet_detail_id            in  number
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
  ,p_start_time_period_id           in  number
  ,p_budget_unit3_available         in  number
  ,p_budget_unit2_available         in  number
  ,p_budget_unit1_available         in  number
  ,p_effective_date                 in  date
  );
--
end pqh_WORKSHEET_PERIODS_bk1;

 

/
