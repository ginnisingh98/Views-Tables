--------------------------------------------------------
--  DDL for Package HR_EMPLOYEE_APPLICANT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EMPLOYEE_APPLICANT_BK2" 
/* $Header: peemaapi.pkh 120.2.12010000.5 2010/03/26 07:29:49 gpurohit ship $ */
AUTHID CURRENT_USER AS
--
-- +---------------------------------------------------------------------------+
-- |-----------------------< hire_employee_applicant_b >-----------------------|
-- +---------------------------------------------------------------------------+
--
procedure hire_employee_applicant_b
  (p_hire_date                 in      date,
   p_person_id                 in      number,
   p_primary_assignment_id     in      number,
   p_overwrite_primary         in      varchar2,
   p_person_type_id            in      number,
   p_per_object_version_number in      number
  );
--
-- +-------------------------------------------------------------------------+
-- |---------------------< hire_employee_applicant_a >-----------------------|
-- +-------------------------------------------------------------------------+
--
procedure hire_employee_applicant_a
  (p_hire_date                  in     date,
   p_person_id                  in     number,
   p_primary_assignment_id      in     number,
   p_overwrite_primary          in     varchar2,
   p_person_type_id             in     number,
   p_per_object_version_number  in     number,
   p_per_effective_start_date   in     date,
   p_per_effective_end_date     in     date,
   p_unaccepted_asg_del_warning in     boolean,
   p_assign_payroll_warning     in     boolean
  ,p_oversubscribed_vacancy_id  in     number
  );
--
END hr_employee_applicant_bk2;

/
