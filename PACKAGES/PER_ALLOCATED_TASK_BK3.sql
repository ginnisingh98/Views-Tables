--------------------------------------------------------
--  DDL for Package PER_ALLOCATED_TASK_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ALLOCATED_TASK_BK3" AUTHID CURRENT_USER as
/* $Header: pepatapi.pkh 120.2.12010000.2 2008/08/06 09:20:51 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_alloc_task_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alloc_task_b
  (p_allocated_task_id             in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_alloc_task_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alloc_task_a
  (p_allocated_task_id             in     number
  ,p_object_version_number         in     number
  );
--
end PER_ALLOCATED_TASK_BK3;

/
