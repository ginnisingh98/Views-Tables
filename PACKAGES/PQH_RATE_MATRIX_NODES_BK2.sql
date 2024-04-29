--------------------------------------------------------
--  DDL for Package PQH_RATE_MATRIX_NODES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_MATRIX_NODES_BK2" AUTHID CURRENT_USER as
/* $Header: pqrmnapi.pkh 120.4 2006/03/14 11:27:29 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rate_matrix_node_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_matrix_node_b
  (p_effective_date               in   date
  ,p_rate_matrix_node_id            in   number
  ,p_short_code                     in   varchar2
  ,p_pl_id                          in   number
  ,p_level_number                   in   number
  ,p_criteria_short_code            in   varchar2
  ,p_node_name                      in   varchar2
  ,p_parent_node_id                 in   number
  ,p_eligy_prfl_id                  in   number
  ,p_business_group_id              in   number
  ,p_legislation_code               in   varchar2
  ,p_object_version_number          in   number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rate_matrix_node_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_matrix_node_a
  (p_effective_date               in   date
  ,p_rate_matrix_node_id            in   number
  ,p_short_code                     in   varchar2
  ,p_pl_id                          in   number
  ,p_level_number                   in   number
  ,p_criteria_short_code            in   varchar2
  ,p_node_name                      in   varchar2
  ,p_parent_node_id                 in   number
  ,p_eligy_prfl_id                  in   number
  ,p_business_group_id              in   number
  ,p_legislation_code               in   varchar2
  ,p_object_version_number          in   number
  );
--
end PQH_RATE_MATRIX_NODES_BK2;

 

/
