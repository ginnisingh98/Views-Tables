--------------------------------------------------------
--  DDL for Package PER_JOB_GROUP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_GROUP_BK2" AUTHID CURRENT_USER as
/* $Header: pejgrapi.pkh 120.1 2005/10/02 02:18:06 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_JOB_GROUP_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_JOB_GROUP_b
  (p_effective_date                in     date
  ,p_job_group_id                  in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_internal_name                 in     varchar2
  ,p_displayed_name                in     varchar2
  ,p_id_flex_num                   in     number
  ,p_master_flag                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_JOB_GROUP_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_JOB_GROUP_a
  (p_effective_date                in     date
  ,p_job_group_id                  in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_internal_name                 in     varchar2
  ,p_displayed_name                in     varchar2
  ,p_id_flex_num                   in     number
  ,p_master_flag                   in     varchar2
  );
--
end PER_JOB_GROUP_BK2;

 

/
