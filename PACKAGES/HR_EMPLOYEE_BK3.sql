--------------------------------------------------------
--  DDL for Package HR_EMPLOYEE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EMPLOYEE_BK3" AUTHID CURRENT_USER as
/* $Header: peempapi.pkh 120.2.12010000.4 2009/03/09 13:25:50 swamukhe ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< apply_for_internal_vacancy_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure apply_for_internal_vacancy_b
   (
   P_business_group_id             in     number
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_applicant_number              in     varchar2
  ,p_per_object_version_number     in     number
  ,p_vacancy_id                    in     number
  ,p_person_type_id                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< apply_for_internal_vacancy_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure apply_for_internal_vacancy_a
   (
   p_business_group_id             in  number
  ,p_effective_date                in  date
  ,p_person_id                     in  number
  ,p_applicant_number              in  varchar2
  ,p_per_object_version_number     in  number
  ,p_vacancy_id                    in  number
  ,p_person_type_id                in  number
  ,p_application_id                in  number
  ,p_assignment_id                 in  number
  ,p_apl_object_version_number     in  number
  ,p_asg_object_version_number     in  number
  ,p_assignment_sequence           in  number
  ,p_per_effective_start_date      in  date
  ,p_per_effective_end_date        in  date
  ,p_appl_override_warning         in  boolean -- 3652025
  );
--
end hr_employee_bk3;

/
