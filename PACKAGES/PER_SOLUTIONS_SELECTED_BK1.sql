--------------------------------------------------------
--  DDL for Package PER_SOLUTIONS_SELECTED_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTIONS_SELECTED_BK1" AUTHID CURRENT_USER as
/* $Header: pesosapi.pkh 120.0 2005/05/31 21:24:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_SOLUTIONS_SELECTED_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solutions_selected_b
  (p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_SOLUTIONS_SELECTED_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solutions_selected_a
  (p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number         in     number
  );
--
end per_solutions_selected_bk1;

 

/
