--------------------------------------------------------
--  DDL for Package HR_EMPLOYEE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EMPLOYEE_BK2" AUTHID CURRENT_USER as
/* $Header: peempapi.pkh 120.2.12010000.4 2009/03/09 13:25:50 swamukhe ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< re_hire_ex_employee_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure re_hire_ex_employee_b
  (
   p_business_group_id             in     number
  ,p_hire_date                     in     date
  ,p_person_id                     in     number
  ,p_per_object_version_number     in     number
  ,p_person_type_id                in     number
  ,p_rehire_reason                 in     varchar2
   );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< re_hire_ex_employee_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure re_hire_ex_employee_a
  (p_business_group_id             in  number
  ,p_hire_date                     in  date
  ,p_person_id                     in  number
  ,p_per_object_version_number     in  number
  ,p_person_type_id                in  number
  ,p_rehire_reason                 in  varchar2
  ,p_assignment_id                 in  number
  ,p_asg_object_version_number     in  number
  ,p_per_effective_start_date      in  date
  ,p_per_effective_end_date        in  date
  ,p_assignment_sequence           in  number
  ,p_assignment_number             in  varchar2
  ,p_assign_payroll_warning        in  boolean
  );
--
end hr_employee_bk2;

/
