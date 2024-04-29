--------------------------------------------------------
--  DDL for Package PQH_BFS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BFS_RKI" AUTHID CURRENT_USER as
/* $Header: pqbfsrhi.pkh 120.0 2005/05/29 01:29:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_budget_fund_src_id             in number
 ,p_budget_element_id              in number
 ,p_cost_allocation_keyflex_id     in number
 ,p_project_id                     in number
 ,p_award_id                       in number
 ,p_task_id                        in number
 ,p_expenditure_type               in varchar2
 ,p_organization_id                in number
 ,p_distribution_percentage        in number
 ,p_object_version_number          in number
  );
end pqh_bfs_rki;

 

/
