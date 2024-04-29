--------------------------------------------------------
--  DDL for Package PER_SOLUTIONS_SELECTED_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTIONS_SELECTED_BK2" AUTHID CURRENT_USER as
/* $Header: pesosapi.pkh 120.0 2005/05/31 21:24:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_SOLUTIONS_SELECTED_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solutions_selected_b
  (p_object_version_number         in     number
  ,p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< UPDATE_SOLUTIONS_SELECTED_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solutions_selected_a
  (p_object_version_number         in     number
  ,p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  );
--
end per_solutions_selected_bk2;

 

/