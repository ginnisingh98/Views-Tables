--------------------------------------------------------
--  DDL for Package HR_JOB_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JOB_API_BK3" AUTHID CURRENT_USER as
/* $Header: pejobapi.pkh 120.1.12010000.1 2008/07/28 04:55:31 appldev ship $ */

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_job_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_job_b
  (p_validate                      in     boolean
  ,p_job_id                        in     number
  ,p_object_version_number         in     number);

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_job_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_job_a
  (p_validate                      in     boolean
  ,p_job_id                        in     number
  ,p_object_version_number         in     number);
end hr_job_api_bk3;

/
