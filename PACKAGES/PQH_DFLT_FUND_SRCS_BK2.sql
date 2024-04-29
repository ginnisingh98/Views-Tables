--------------------------------------------------------
--  DDL for Package PQH_DFLT_FUND_SRCS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_FUND_SRCS_BK2" AUTHID CURRENT_USER as
/* $Header: pqdfsapi.pkh 120.1 2005/10/02 02:26:43 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_dflt_fund_src_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_dflt_fund_src_b
  (
   p_dflt_fund_src_id               in  number
  ,p_dflt_budget_element_id         in  number
  ,p_dflt_dist_percentage           in  number
  ,p_project_id                     in  number
  ,p_award_id                       in  number
  ,p_task_id                        in  number
  ,p_expenditure_type               in  varchar2
  ,p_organization_id                in  number
  ,p_object_version_number          in  number
  ,p_cost_allocation_keyflex_id     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_dflt_fund_src_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_dflt_fund_src_a
  (
   p_dflt_fund_src_id               in  number
  ,p_dflt_budget_element_id         in  number
  ,p_dflt_dist_percentage           in  number
  ,p_project_id                     in  number
  ,p_award_id                       in  number
  ,p_task_id                        in  number
  ,p_expenditure_type               in  varchar2
  ,p_organization_id                in  number
  ,p_object_version_number          in  number
  ,p_cost_allocation_keyflex_id     in  number
  );
--
end pqh_dflt_fund_srcs_bk2;

 

/
