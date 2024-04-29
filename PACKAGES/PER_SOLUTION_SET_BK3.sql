--------------------------------------------------------
--  DDL for Package PER_SOLUTION_SET_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_SET_BK3" AUTHID CURRENT_USER as
/* $Header: peslsapi.pkh 120.0 2005/05/31 21:12:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_SOLUTION_SET_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_set_b
  (p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_SOLUTION_SET_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_set_a
  (p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number         in     number
  );
--
end per_solution_set_bk3;

 

/
