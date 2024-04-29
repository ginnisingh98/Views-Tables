--------------------------------------------------------
--  DDL for Package PQH_RATE_MATRIX_NODES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_MATRIX_NODES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrmnapi.pkh 120.4 2006/03/14 11:27:29 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rate_matrix_node_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_matrix_node_b
  (p_effective_date                in     date
  ,p_RATE_MATRIX_NODE_ID  	   in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rate_matrix_node_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_matrix_node_a
  (p_effective_date                in     date
  ,p_RATE_MATRIX_NODE_ID  	   in     number
  ,p_object_version_number         in     number
  );
--
end PQH_RATE_MATRIX_NODES_BK3;

 

/
