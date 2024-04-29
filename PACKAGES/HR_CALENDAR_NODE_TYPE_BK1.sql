--------------------------------------------------------
--  DDL for Package HR_CALENDAR_NODE_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_NODE_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: pepgtapi.pkh 120.0 2005/05/31 14:14:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_node_type_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_node_type_b
      (p_effective_date            in date
      ,p_child_node_type           in varchar2
      ,p_child_node_name           in varchar2
      ,p_hierarchy_type            in varchar2
      ,p_child_value_set           in varchar2
      ,p_parent_node_type          in varchar2
      ,p_identifier_key            in varchar2
      ,p_description               in varchar2);

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_node_type_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_node_type_a
      (p_effective_date            in date
      ,p_child_node_type           in varchar2
      ,p_child_node_name           in varchar2
      ,p_hierarchy_type            in varchar2
      ,p_child_value_set           in varchar2
      ,p_parent_node_type          in varchar2
      ,p_identifier_key            in varchar2
      ,p_description               in varchar2
      ,p_hier_node_type_id         in number
      ,p_object_version_number     in number);
--
end HR_CALENDAR_NODE_TYPE_BK1;

 

/
