--------------------------------------------------------
--  DDL for Package PER_SOLUTION_TYPE_CMPT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_TYPE_CMPT_BK3" AUTHID CURRENT_USER as
/* $Header: pestcapi.pkh 120.0 2005/05/31 21:57:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< DELETE_SOLUTION_TYPE_CMPT_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_type_cmpt_b
  (p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< DELETE_SOLUTION_TYPE_CMPT_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_type_cmpt_a
  (p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_object_version_number         in     number
  );
--
end per_solution_type_cmpt_bk3;

 

/
