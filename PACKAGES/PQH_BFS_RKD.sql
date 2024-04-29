--------------------------------------------------------
--  DDL for Package PQH_BFS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BFS_RKD" AUTHID CURRENT_USER as
/* $Header: pqbfsrhi.pkh 120.0 2005/05/29 01:29:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_budget_fund_src_id             in number
 ,p_budget_element_id_o            in number
 ,p_cost_allocation_keyflex_id_o   in number
 ,p_project_id_o                   in number
 ,p_award_id_o                     in number
 ,p_task_id_o                      in number
 ,p_expenditure_type_o             in varchar2
 ,p_organization_id_o              in number
 ,p_distribution_percentage_o      in number
 ,p_object_version_number_o        in number
  );
--
end pqh_bfs_rkd;

 

/
