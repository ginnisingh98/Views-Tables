--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BK9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BK9" AUTHID CURRENT_USER as
/* $Header: pepemapi.pkh 120.1.12010000.1 2008/07/28 05:11:13 appldev ship $ */
-- ----------------------------------------------------------------------
-- |------------------------< delete_previous_job_usage_b >-------------|
-- ----------------------------------------------------------------------
--
procedure delete_previous_job_usage_b
  (p_previous_job_usage_id     in      number
  ,p_object_version_number     in      number
  );
--
-- ----------------------------------------------------------------------
-- |------------------------< delete_previous_job_usage_a >-------------|
-- ----------------------------------------------------------------------
--
procedure delete_previous_job_usage_a
  (p_previous_job_usage_id     in      number
  ,p_object_version_number     in      number
  );
--
end hr_previous_employment_bk9;

/
