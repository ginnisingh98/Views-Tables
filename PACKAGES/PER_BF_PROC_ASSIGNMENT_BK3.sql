--------------------------------------------------------
--  DDL for Package PER_BF_PROC_ASSIGNMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_PROC_ASSIGNMENT_BK3" AUTHID CURRENT_USER as
/* $Header: pebpaapi.pkh 120.1 2005/10/02 02:12:11 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_processed_assignment_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_processed_assignment_b
  (
   p_processed_assignment_id      in     number
  ,p_processed_assignment_ovn     in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_processed_assignment_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_processed_assignment_a
  (
   p_processed_assignment_id       in     number
  ,p_processed_assignment_ovn      in     number
  );
--
end PER_BF_PROC_ASSIGNMENT_BK3;

 

/
