--------------------------------------------------------
--  DDL for Package HR_CALENDAR_NODE_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_NODE_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: pepgtapi.pkh 120.0 2005/05/31 14:14:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_node_type_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_node_type_b
  (p_hier_node_type_id             in      number
  ,p_object_version_number         in      number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_node_type_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_node_type_a
  (p_hier_node_type_id             in      number
  ,p_object_version_number         in      number
  );

end HR_CALENDAR_NODE_TYPE_BK3;

 

/
