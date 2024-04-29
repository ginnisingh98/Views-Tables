--------------------------------------------------------
--  DDL for Package HR_CHANGE_START_DATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CHANGE_START_DATE_API" AUTHID CURRENT_USER as
/* $Header: pehirapi.pkh 120.1.12010000.1 2008/07/28 04:48:12 appldev ship $ */
/*#
 * This package contains the API for changing the start date of an employee or
 * a contingent worker.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Change Start Date
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_start_date >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes the start date of the employee or contingent worker.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist as of the old start date supplied, and must be an
 * employee or a contingent worker.
 *
 * <p><b>Post Success</b><br>
 * The start date of the employee or contingent worker person record, the
 * period of service or placement, the assignments that coincide with the start
 * date, and the child records are changed to start as of the new start date.
 *
 * <p><b>Post Failure</b><br>
 * An error is raised and the start date is not changed.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person record for which the change of
 * start date is to be processed.
 * @param p_old_start_date The hire date or start of placement
 * @param p_new_start_date The start date that you want to change to.
 * @param p_update_type Specifies whether this update refers to an employee or
 * a contingent worker. Valid values are the same as those used for assignment
 * type. 'E' for employees, 'C' for contingent workers.
 * @param p_applicant_number Applicant number, if specified will cause appl
 * records to be moved also.
 * @param p_warn_ee For employees, set to 'Y' if recurring element entries were
 * changed.
 * @rep:displayname Update Start Date
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_start_date
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_old_start_date                in     date
  ,p_new_start_date                in     date
  ,p_update_type                   in     varchar2
  ,p_applicant_number              in     varchar2  default null
  ,p_warn_ee                       out nocopy    varchar2
  );
--
end hr_change_start_date_api;

/
