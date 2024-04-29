--------------------------------------------------------
--  DDL for Package PER_SOLUTION_CMPT_NAME_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_CMPT_NAME_BK3" AUTHID CURRENT_USER as
/* $Header: pescnapi.pkh 120.0 2005/05/31 20:46:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< DELETE_SOLUTION_CMPT_NAME_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_cmpt_name_b
  (p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_SOLUTION_CMPT_NAME_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_cmpt_name_a
  (p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_object_version_number         in     number
  );
--
end per_solution_cmpt_name_bk3;

 

/
