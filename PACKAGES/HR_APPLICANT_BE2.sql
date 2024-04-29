--------------------------------------------------------
--  DDL for Package HR_APPLICANT_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_BE2" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure  hire_applicant_a (
p_hire_date                    date,
p_person_id                    number,
p_assignment_id                number,
p_person_type_id               number,
p_national_identifier          varchar2,
p_per_object_version_number    number,
p_employee_number              varchar2,
p_per_effective_start_date     date,
p_per_effective_end_date       date,
p_unaccepted_asg_del_warning   boolean,
p_assign_payroll_warning       boolean,
p_oversubscribed_vacancy_id    number,
p_original_date_of_hire        date);
end hr_applicant_be2;

/
