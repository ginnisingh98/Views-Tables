--------------------------------------------------------
--  DDL for Package PQH_BUDGET_FUND_SRCS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_FUND_SRCS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbfsapi.pkh 120.1 2005/10/02 02:25:46 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_fund_src_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_fund_src_b
  (
   p_budget_fund_src_id             in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_fund_src_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_fund_src_a
  (
   p_budget_fund_src_id             in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_fund_srcs_bk3;

 

/
