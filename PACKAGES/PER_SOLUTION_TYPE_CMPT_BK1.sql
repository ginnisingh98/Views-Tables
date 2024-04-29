--------------------------------------------------------
--  DDL for Package PER_SOLUTION_TYPE_CMPT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_TYPE_CMPT_BK1" AUTHID CURRENT_USER as
/* $Header: pestcapi.pkh 120.0 2005/05/31 21:57:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_SOLUTION_TYPE_CMPT_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_type_cmpt_b
  (p_effective_date                in     date
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_api_name                      in     varchar2
  ,p_parent_component_name         in     varchar2
  ,p_updateable                    in     varchar2
  ,p_extensible                    in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_SOLUTION_TYPE_CMPT_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_type_cmpt_a
  (p_effective_date                in     date
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_api_name                      in     varchar2
  ,p_parent_component_name         in     varchar2
  ,p_updateable                    in     varchar2
  ,p_extensible                    in     varchar2
  ,p_object_version_number         in     number
  );
--
end per_solution_type_cmpt_bk1;

 

/
