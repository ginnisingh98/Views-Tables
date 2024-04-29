--------------------------------------------------------
--  DDL for Package PER_PGT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PGT_RKD" AUTHID CURRENT_USER as
/* $Header: pepgtrhi.pkh 120.0 2005/05/31 14:15:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_hier_node_type_id            in number
  ,p_business_group_id_o          in number
  ,p_hierarchy_type_o             in varchar2
  ,p_parent_node_type_o           in varchar2
  ,p_child_node_type_o            in varchar2
  ,p_child_value_set_o            in varchar2
  ,p_object_version_number_o      in number
  ,p_identifier_key_o             in varchar2
  );
--
end per_pgt_rkd;

 

/
