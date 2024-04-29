--------------------------------------------------------
--  DDL for Package PQH_RT_MATRIX_NODE_VALUES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RT_MATRIX_NODE_VALUES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrmvapi.pkh 120.6 2006/03/14 11:28:14 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rt_matrix_node_value_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rt_matrix_node_value_b
  (p_effective_date                in     date
  ,p_NODE_value_ID  		in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rt_matrix_node_value_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rt_matrix_node_value_a
  (p_effective_date                in     date
  ,p_NODE_value_ID  		  in     number
  ,p_object_version_number         in     number
  );
--
end PQH_RT_MATRIX_NODE_VALUES_BK3;

 

/
