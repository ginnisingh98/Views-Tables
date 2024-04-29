--------------------------------------------------------
--  DDL for Package PQH_BUDGET_FUND_SRCS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_FUND_SRCS_BK1" AUTHID CURRENT_USER as
/* $Header: pqbfsapi.pkh 120.1 2005/10/02 02:25:46 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_budget_fund_src_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_budget_fund_src_b
  (
   p_budget_element_id              in  number
  ,p_cost_allocation_keyflex_id     in  number
  ,p_project_id                     in  number
  ,p_award_id                       in  number
  ,p_task_id                        in  number
  ,p_expenditure_type               in  varchar2
  ,p_organization_id                in  number
  ,p_distribution_percentage        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_budget_fund_src_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_budget_fund_src_a
  (
   p_budget_fund_src_id             in  number
  ,p_budget_element_id              in  number
  ,p_cost_allocation_keyflex_id     in  number
  ,p_project_id                     in  number
  ,p_award_id                       in  number
  ,p_task_id                        in  number
  ,p_expenditure_type               in  varchar2
  ,p_organization_id                in  number
  ,p_distribution_percentage        in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_fund_srcs_bk1;

 

/
