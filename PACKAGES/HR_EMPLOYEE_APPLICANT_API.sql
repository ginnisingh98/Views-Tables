--------------------------------------------------------
--  DDL for Package HR_EMPLOYEE_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EMPLOYEE_APPLICANT_API" AUTHID CURRENT_USER as
/* $Header: peemaapi.pkh 120.2.12010000.5 2010/03/26 07:29:49 gpurohit ship $ */
/*#
 * This package contains employee applicant APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employee Applicant
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< hire_to_employee_applicant >--------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
PROCEDURE hire_to_employee_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_hire_date                    IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE    DEFAULT NULL
  ,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
  ,p_per_effective_start_date        OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_per_effective_end_date          OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< hire_to_employee_applicant >--------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
PROCEDURE hire_to_employee_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_hire_date                    IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE    DEFAULT NULL
  ,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
  ,p_per_effective_start_date        OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_per_effective_end_date          OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_oversubscribed_vacancy_id       out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< hire_to_employee_applicant >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API converts an applicant to an employee but lets them retain any
 * remaining applicant assignments.
 *
 * This API converts a person of type Applicant to a person of type Employee
 * (EMP).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee applicant (Internal Applicant) must exist in the relevant
 * business group and have an applicant assignment with the assignment status
 * Accepted. If person_type_id is supplied, it must have a corresponding system
 * person type of EMP and must be active in the same business group as the
 * applicant being changed to employee.
 *
 * <p><b>Post Success</b><br>
 * The applicant has been successfully hired as an employee.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person, application, assignments, or period of
 * service and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date Hire Date.
 * @param p_person_id Person who is being hired.
 * @param p_per_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id Type of employee being created.
 * @param p_hire_all_accepted_asgs Flag indicating whether to convert all
 * accepted applicant assignments to employee assignments.
 * @param p_assignment_id Assignment record into which a person is being hired.
 * @param p_national_identifier Number by which a person is identified in a
 * given legislation.
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an employee number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is false then will be set to the employee number. If
 * p_validate is true then will be set to the passed value.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_oversubscribed_vacancy_id Vacancy that was oversubscribed when the
 * applicant was hired.
 * @rep:displayname Hire To Employee Applicant
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE hire_to_employee_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_hire_date                    IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_hire_all_accepted_asgs       IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE    DEFAULT NULL
  ,p_national_identifier          IN     per_all_people_f.national_identifier%TYPE   DEFAULT hr_api.g_varchar2
  ,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
  ,p_per_effective_start_date        OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_per_effective_end_date          OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_oversubscribed_vacancy_id       out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< hire_employee_applicant >----------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure hire_employee_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_person_type_id            in      number   default null,
   p_assignment_id             in      number   default null,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< hire_employee_applicant >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API converts an applicant to an employee.
 *
 * This API converts a person of type Applicant to a person of type Employee
 * (EMP) and ends any remaining applicant assignments.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee applicant (internal applicant) must exist in the relevant
 * business group and have an applicant assignment with the assignment status
 * Accepted. If person_type_id is supplied, it must have a corresponding system
 * person type of EMP and must be active in the same business group as the
 * applicant being changed to employee.
 *
 * <p><b>Post Success</b><br>
 * The applicant has been successfully hired as an employee.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person, application, assignments, or period of
 * service and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date Hire Date.
 * @param p_person_id Person who is being hired.
 * @param p_primary_assignment_id Primary assignment record.
 * @param p_person_type_id Type of employee being created.
 * @param p_overwrite_primary Flag indicating whether the current primary
 * assignment is to be replaced.
 * @param p_per_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_unaccepted_asg_del_warning If set to true, then the unaccepted
 * applicant assignments have been terminated.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_oversubscribed_vacancy_id Vacancy that was oversubscribed when the
 * applicant was hired.
 * @rep:displayname Hire Employee Applicant
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure hire_employee_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_primary_assignment_id     in      number   default null,
   p_person_type_id            in      number   default null,
   p_overwrite_primary         in      varchar2 default 'N',
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean
  ,p_oversubscribed_vacancy_id    out nocopy  number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< hire_employee_applicant >----------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is for Self Service Human Resources(SSHR) use only.
-- This API converts a person of type Employee.Applicant to a person of type
-- Employee if there is only one Application at the time of hiring or the API
-- will hire the Employee.Applicant into the selected Application assignment
-- and wont close the other Application assignments leaving the person in
-- Employee.Applicant person type.
--
procedure hire_employee_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_asg_rec	 in out nocopy per_all_assignments_f%rowtype,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_primary_assignment_id     in      number   default null,
   p_person_type_id            in      number   default null,
   p_overwrite_primary         in      varchar2 default 'N',
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean
  ,p_oversubscribed_vacancy_id    out nocopy  number
  ,p_called_from               in       varchar2
);
--
--
-- #2264569: PL/SQL table to be used when hiring Applicants
-- Process Flag ==> (C)onvert, (R)etain, (E)nd Date (it can be null)
--
   type rec_appl is record (
      id per_all_assignments_f.assignment_id%TYPE,
      process_flag varchar2(2)
     );
   type t_ApplTable is table of rec_appl index by binary_integer;

   T_EmptyAPPL t_ApplTable;

--
-- routines to handle elements in table
--
function locate_element(p_table t_ApplTable
                       ,p_id per_all_assignments_f.assignment_id%TYPE)
   return binary_integer;
--
--
function locate_value(p_table t_ApplTable
                     ,p_flag varchar2)
   return binary_integer;
--
--
function end_date_exists(p_table t_ApplTable
                              ,p_id per_all_assignments_f.assignment_id%TYPE)
   return integer;
--
--
function is_convert(p_table t_ApplTable
                   ,p_id per_all_assignments_f.assignment_id%TYPE)
   return boolean;
--
--
function retain_exists(p_table t_ApplTable) return boolean;
--
--
function tab_is_empty(p_table t_ApplTable) return boolean;
--
--
function empty_table return t_ApplTable;
--
--
function retain_flag return varchar2;
--
function convert_flag return varchar2;
--
function end_date_flag return varchar2;
--
-- end #2264569

END hr_employee_applicant_api;

/
