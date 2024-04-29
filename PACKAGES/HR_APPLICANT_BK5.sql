--------------------------------------------------------
--  DDL for Package HR_APPLICANT_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_BK5" 
/* $Header: peappapi.pkh 120.5.12010000.5 2009/08/04 11:21:03 pannapur ship $ */
AUTHID CURRENT_USER AS
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< apply_for_job_anytime_b >------------------------|
-- ---------------------------------------------------------------------------+
--
procedure apply_for_job_anytime_b
   (
   P_business_group_id             in     number
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_applicant_number              in     varchar2
  ,p_per_object_version_number     in     number
  ,p_vacancy_id                    in     number
  ,p_person_type_id                in     number
  ,p_assignment_status_type_id     in     number
  );
--
-- ----------------------------------------------------------------------------+
-- |-----------------------< apply_for_job_anytime_a >-------------------------|
-- ----------------------------------------------------------------------------+
--
procedure apply_for_job_anytime_a
   (
   p_business_group_id             in  number
  ,p_effective_date                in  date
  ,p_person_id                     in  number
  ,p_applicant_number              in  varchar2
  ,p_per_object_version_number     in  number
  ,p_vacancy_id                    in  number
  ,p_person_type_id                in  number
  ,p_assignment_status_type_id     in  number
  ,p_application_id                in  number
  ,p_assignment_id                 in  number
  ,p_apl_object_version_number     in  number
  ,p_asg_object_version_number     in  number
  ,p_assignment_sequence           in  number
  ,p_per_effective_start_date      in  date
  ,p_per_effective_end_date        in  date
  ,p_appl_override_warning         in  boolean
  );
--
end hr_applicant_bk5;
--

/
