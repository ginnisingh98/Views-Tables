--------------------------------------------------------
--  DDL for Package PER_SOLUTION_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: pesltapi.pkh 120.0 2005/05/31 21:15:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_SOLUTION_TYPE_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_type_b
  (p_effective_date                in     date
  ,p_solution_type_name            in     varchar2
  ,p_solution_category             in     varchar2
  ,p_updateable                    in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_SOLUTION_TYPE_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_type_a
  (p_effective_date                in     date
  ,p_solution_type_name            in     varchar2
  ,p_solution_category             in     varchar2
  ,p_updateable                    in     varchar2
  ,p_object_version_number         in     number
  );
--
end per_solution_type_bk1;

 

/
