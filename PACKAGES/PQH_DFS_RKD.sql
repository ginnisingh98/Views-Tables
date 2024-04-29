--------------------------------------------------------
--  DDL for Package PQH_DFS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFS_RKD" AUTHID CURRENT_USER as
/* $Header: pqdfsrhi.pkh 120.0 2005/05/29 01:48:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dflt_fund_src_id               in number
 ,p_dflt_budget_element_id_o       in number
 ,p_dflt_dist_percentage_o         in number
 ,p_project_id_o                   in number
 ,p_award_id_o                     in number
 ,p_task_id_o                      in number
 ,p_expenditure_type_o             in varchar2
 ,p_organization_id_o              in number
 ,p_object_version_number_o        in number
 ,p_cost_allocation_keyflex_id_o   in number
  );
--
end pqh_dfs_rkd;

 

/
