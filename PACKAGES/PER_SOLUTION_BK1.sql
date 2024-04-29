--------------------------------------------------------
--  DDL for Package PER_SOLUTION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_BK1" AUTHID CURRENT_USER as
/* $Header: pesolapi.pkh 120.0 2005/05/31 21:19:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_SOLUTION_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_b
  (p_effective_date                in     date
  ,p_solution_name                 in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_description                   in     varchar2
  ,p_link_to_full_description      in     varchar2
  ,p_vertical                      in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_user_id                       in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_SOLUTION_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_a
  (p_effective_date                in     date
  ,p_solution_name                 in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_description                   in     varchar2
  ,p_link_to_full_description      in     varchar2
  ,p_vertical                      in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_user_id                       in     varchar2
  ,p_solution_id                   in     number
  ,p_object_version_number         in     number
  );
--
end per_solution_bk1;

 

/
