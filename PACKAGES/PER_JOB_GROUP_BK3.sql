--------------------------------------------------------
--  DDL for Package PER_JOB_GROUP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_GROUP_BK3" AUTHID CURRENT_USER as
/* $Header: pejgrapi.pkh 120.1 2005/10/02 02:18:06 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_JOB_GROUP_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_JOB_GROUP_b
  (p_job_group_id                  in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_JOB_GROUP_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_JOB_GROUP_a
  (p_job_group_id                  in     number
  ,p_object_version_number         in     number
  );
--
end PER_JOB_GROUP_BK3;

 

/
