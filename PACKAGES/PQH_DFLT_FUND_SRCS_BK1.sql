--------------------------------------------------------
--  DDL for Package PQH_DFLT_FUND_SRCS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_FUND_SRCS_BK1" AUTHID CURRENT_USER as
/* $Header: pqdfsapi.pkh 120.1 2005/10/02 02:26:43 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_dflt_fund_src_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_dflt_fund_src_b
  (
   p_dflt_budget_element_id         in  number
  ,p_dflt_dist_percentage           in  number
  ,p_project_id                     in  number
  ,p_award_id                       in  number
  ,p_task_id                        in  number
  ,p_expenditure_type               in  varchar2
  ,p_organization_id                in  number
  ,p_cost_allocation_keyflex_id     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_dflt_fund_src_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_dflt_fund_src_a
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
end pqh_dflt_fund_srcs_bk1;

 

/
