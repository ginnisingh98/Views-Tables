--------------------------------------------------------
--  DDL for Package PQH_BPL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BPL_RKU" AUTHID CURRENT_USER as
/* $Header: pqbplrhi.pkh 120.0 2005/05/29 01:32:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_pool_id                      in number
  ,p_name                         in varchar2
  ,p_budget_version_id            in number
  ,p_budget_unit_id               in number
  ,p_object_version_number        in number
  ,p_entity_type                  in varchar2
  ,p_parent_pool_id             in number
  ,p_business_group_id            in number
  ,p_approval_status              in varchar2
  ,p_wf_transaction_category_id	  in number
  ,p_name_o                       in varchar2
  ,p_budget_version_id_o          in number
  ,p_budget_unit_id_o             in number
  ,p_object_version_number_o      in number
  ,p_entity_type_o                in varchar2
  ,p_parent_pool_id_o           in number
  ,p_business_group_id_o          in number
  ,p_approval_status_o            in varchar2
  ,p_wf_transaction_category_id_o in number
  );
--
end pqh_bpl_rku;

 

/
