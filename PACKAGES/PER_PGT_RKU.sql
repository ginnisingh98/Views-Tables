--------------------------------------------------------
--  DDL for Package PER_PGT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PGT_RKU" AUTHID CURRENT_USER as
/* $Header: pepgtrhi.pkh 120.0 2005/05/31 14:15:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_hier_node_type_id            in number
  ,p_parent_node_type             in varchar2
  ,p_child_value_set              in varchar2
  ,p_object_version_number        in number
  ,p_identifier_key               in varchar2
  ,p_business_group_id_o          in number
  ,p_hierarchy_type_o             in varchar2
  ,p_parent_node_type_o           in varchar2
  ,p_child_node_type_o            in varchar2
  ,p_child_value_set_o            in varchar2
  ,p_object_version_number_o      in number
  ,p_identifier_key_o             in varchar2
  );
--
end per_pgt_rku;

 

/
