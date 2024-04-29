--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BKC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BKC" AUTHID CURRENT_USER as
/* $Header: pepemapi.pkh 120.1.12010000.1 2008/07/28 05:11:13 appldev ship $ */
-- ----------------------------------------------------------------------
-- |------------------------< delete_prev_job_extra_info_b >------------|
-- ----------------------------------------------------------------------
--
procedure delete_prev_job_extra_info_b
  (p_previous_job_extra_info_id     in      number
  ,p_object_version_number          in      number
  );
--
-- ----------------------------------------------------------------------
-- |------------------------< delete_prev_job_extra_info_a >------------|
-- ----------------------------------------------------------------------
--
procedure delete_prev_job_extra_info_a
  (p_previous_job_extra_info_id     in      number
  ,p_object_version_number          in      number
  );
--
end hr_previous_employment_bkc;

/