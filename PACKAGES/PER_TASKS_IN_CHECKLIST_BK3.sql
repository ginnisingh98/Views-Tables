--------------------------------------------------------
--  DDL for Package PER_TASKS_IN_CHECKLIST_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_TASKS_IN_CHECKLIST_BK3" AUTHID CURRENT_USER as
/* $Header: pectkapi.pkh 120.3 2006/01/13 05:10:20 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_task_in_ckl_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_task_in_ckl_b
  (p_task_in_checklist_id          in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_task_in_ckl_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_task_in_ckl_a
  (p_task_in_checklist_id          in     number
  ,p_object_version_number         in     number
  );
--
end PER_TASKS_IN_CHECKLIST_BK3;

 

/
