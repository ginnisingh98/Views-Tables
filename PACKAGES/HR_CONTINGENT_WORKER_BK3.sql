--------------------------------------------------------
--  DDL for Package HR_CONTINGENT_WORKER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTINGENT_WORKER_BK3" AUTHID CURRENT_USER as
/* $Header: pecwkapi.pkh 120.1.12010000.1 2008/07/28 04:28:14 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< apply_for_job_b >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure apply_for_job_b
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_object_version_number         in     number
  ,p_applicant_number              in     varchar2
  ,p_person_type_id                in     number
  ,p_vacancy_id                    in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< apply_for_job_a >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure apply_for_job_a
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_object_version_number         in     number
  ,p_applicant_number              in     varchar2
  ,p_person_type_id                in     number
  ,p_vacancy_id                    in     number
  ,p_per_effective_start_date      in     date
  ,p_per_effective_end_date        in     date
  ,p_application_id                in     number
  ,p_apl_object_version_number     in     number
  ,p_assignment_id                 in     number
  ,p_asg_object_version_number     in     number
  ,p_assignment_sequence           in     number
  );
--
end hr_contingent_worker_bk3;

/
