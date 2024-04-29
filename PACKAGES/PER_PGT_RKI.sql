--------------------------------------------------------
--  DDL for Package PER_PGT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PGT_RKI" AUTHID CURRENT_USER as
/* $Header: pepgtrhi.pkh 120.0 2005/05/31 14:15:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_hier_node_type_id            in number
  ,p_business_group_id            in number
  ,p_hierarchy_type               in varchar2
  ,p_parent_node_type             in varchar2
  ,p_child_node_type              in varchar2
  ,p_child_value_set              in varchar2
  ,p_object_version_number        in number
  ,p_identifier_key               in varchar2
  );
end per_pgt_rki;

 

/
