--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_BUDGET_SETS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_BUDGET_SETS_BK3" AUTHID CURRENT_USER as
/* $Header: pqwstapi.pkh 120.0 2005/05/29 03:03:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_BUDGET_SET_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_BUDGET_SET_b
  (
   p_worksheet_budget_set_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORKSHEET_BUDGET_SET_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_BUDGET_SET_a
  (
   p_worksheet_budget_set_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_WORKSHEET_BUDGET_SETS_bk3;

 

/
