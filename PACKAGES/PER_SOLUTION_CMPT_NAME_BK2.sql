--------------------------------------------------------
--  DDL for Package PER_SOLUTION_CMPT_NAME_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_CMPT_NAME_BK2" AUTHID CURRENT_USER as
/* $Header: pescnapi.pkh 120.0 2005/05/31 20:46:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_SOLUTION_CMPT_NAME_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solution_cmpt_name_b
  (p_object_version_number         in     number
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_name                          in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_SOLUTION_CMPT_NAME_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solution_cmpt_name_a
  (p_object_version_number         in     number
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_name                          in     varchar2
  );
--
end per_solution_cmpt_name_bk2;

 

/
