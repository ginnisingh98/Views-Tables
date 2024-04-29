--------------------------------------------------------
--  DDL for Package PER_SOLUTION_SET_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_SET_BK1" AUTHID CURRENT_USER as
/* $Header: peslsapi.pkh 120.0 2005/05/31 21:12:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CREATE_SOLUTION_SET_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_set_b
  (p_effective_date                in     date
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_description                   in     varchar2
  ,p_status                        in     varchar2
  ,p_solution_set_impl_id          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CREATE_SOLUTION_SET_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_set_a
  (p_effective_date                in     date
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_description                   in     varchar2
  ,p_status                        in     varchar2
  ,p_solution_set_impl_id          in     number
  ,p_object_version_number         in     number
  );
--
end per_solution_set_bk1;

 

/
