--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_TASKS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_TASKS_BK2" AUTHID CURRENT_USER as
/* $Header: bectkapi.pkh 120.1 2005/10/02 02:35:52 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_task_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_task_b
  (p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_status_cd                     in     varchar2
  ,p_access_cd                     in     varchar2
  ,p_task_last_update_date         in     date
  ,p_task_last_update_by           in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_task_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_task_a
  (p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_status_cd                     in     varchar2
  ,p_access_cd                     in     varchar2
  ,p_task_last_update_date         in     date
  ,p_task_last_update_by           in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_PERSON_TASKS_BK2;

 

/
