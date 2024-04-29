--------------------------------------------------------
--  DDL for Package PER_SOLUTION_TYPE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_TYPE_BK2" AUTHID CURRENT_USER as
/* $Header: pesltapi.pkh 120.0 2005/05/31 21:15:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_SOLUTION_TYPE_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solution_type_b
  (p_effective_date                in     date
  ,p_object_version_number         in     number
  ,p_solution_type_name            in     varchar2
  ,p_solution_category             in     varchar2
  ,p_updateable                    in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_SOLUTION_TYPE_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solution_type_a
  (p_effective_date                in     date
  ,p_object_version_number         in     number
  ,p_solution_type_name            in     varchar2
  ,p_solution_category             in     varchar2
  ,p_updateable                    in     varchar2
  );
--
end per_solution_type_bk2;

 

/
