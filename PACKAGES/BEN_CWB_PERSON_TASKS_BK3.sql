--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_TASKS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_TASKS_BK3" AUTHID CURRENT_USER as
/* $Header: bectkapi.pkh 120.1 2005/10/02 02:35:52 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_task_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_task_b
  (p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_task_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_task_a
  (p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_PERSON_TASKS_BK3;

 

/
