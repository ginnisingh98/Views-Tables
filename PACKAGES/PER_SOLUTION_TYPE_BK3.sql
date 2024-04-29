--------------------------------------------------------
--  DDL for Package PER_SOLUTION_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: pesltapi.pkh 120.0 2005/05/31 21:15:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_SOLUTION_TYPE_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_type_b
  (p_solution_type_name            in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_SOLUTION_TYPE_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_type_a
  (p_solution_type_name            in     varchar2
  ,p_object_version_number         in     number
  );
--
end per_solution_type_bk3;

 

/
