--------------------------------------------------------
--  DDL for Package PER_SOLUTION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_BK3" AUTHID CURRENT_USER as
/* $Header: pesolapi.pkh 120.0 2005/05/31 21:19:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_SOLUTION_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_b
  (p_solution_id                   in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_SOLUTION_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_a
  (p_solution_id                   in     number
  ,p_object_version_number         in     number
  );
--
end per_solution_bk3;

 

/
