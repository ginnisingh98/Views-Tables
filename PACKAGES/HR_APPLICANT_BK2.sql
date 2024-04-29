--------------------------------------------------------
--  DDL for Package HR_APPLICANT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_BK2" AUTHID CURRENT_USER as
/* $Header: peappapi.pkh 120.5.12010000.5 2009/08/04 11:21:03 pannapur ship $ */
--
-- ---------------------------------------------------------------------------
-- |--------------------------< hire_applicant_b >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure hire_applicant_b
  (p_hire_date                 in      date,
   p_person_id                 in      number,
   p_assignment_id             in      number,
   p_person_type_id            in      number,
   p_national_identifier       in      varchar2,
   p_per_object_version_number in      number,
   p_employee_number           in     varchar2,
   p_original_date_of_hire     in     date
  );
--
-- ---------------------------------------------------------------------------
-- |--------------------------< hire_applicant_a >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure hire_applicant_a
  (p_hire_date                  in     date,
   p_person_id                  in     number,
   p_assignment_id              in     number,
   p_person_type_id             in     number,
   p_national_identifier        in     varchar2,
   p_per_object_version_number  in     number,
   p_employee_number            in     varchar2,
   p_per_effective_start_date   in     date,
   p_per_effective_end_date     in     date,
   p_unaccepted_asg_del_warning in     boolean,
   p_assign_payroll_warning     in     boolean,
   p_oversubscribed_vacancy_id  in     number,
   p_original_date_of_hire      in     date
  );
end hr_applicant_bk2;
--

/
