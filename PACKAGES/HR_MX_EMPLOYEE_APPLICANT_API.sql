--------------------------------------------------------
--  DDL for Package HR_MX_EMPLOYEE_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_EMPLOYEE_APPLICANT_API" AUTHID CURRENT_USER AS
/* $Header: pemxwrea.pkh 120.1 2005/10/02 02:42:56 aroussel $ */
/*#
 * This package contains employee applicant APIs for Mexico.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Employee Applicant for Mexico
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------< mx_hire_to_employee_applicant >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API converts an applicant to an employee for Mexico but lets the
 * employee retain any remaining applicant assignments.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Employee Applicant ( Internal Applicant ) must exist in the relevant
 * business group and must have an applicant assignment with assignment status
 * of 'Accepted'. If person_type_id is supplied, it must have a corresponding
 * system person type of 'EMP', must be active and be in the same business
 * group as that of the applicant being changed to employee.
 *
 * <p><b>Post Success</b><br>
 * Applicant has been successfully hired as an employee.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person, application, assignments, or period of
 * service and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date Hire Date.
 * @param p_person_id Identifies the person record to modify.
 * @param p_per_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id Type of employee being created.
 * @param p_hire_all_accepted_asgs Flag indicating whether to convert all
 * accepted applicant assignments to employee assignments.
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_curp_id Mexican National Identifier.
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
 * @rep:displayname Hire To Employee Applicant for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
PROCEDURE mx_hire_to_employee_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_hire_date                    IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_hire_all_accepted_asgs       IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE    DEFAULT NULL
  ,p_CURP_id                      IN     per_all_people_f.national_identifier%TYPE   DEFAULT hr_api.g_varchar2
  ,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
  ,p_per_effective_start_date        OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_per_effective_end_date          OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_oversubscribed_vacancy_id       OUT NOCOPY NUMBER
  );

END hr_mx_employee_applicant_api ;

 

/
