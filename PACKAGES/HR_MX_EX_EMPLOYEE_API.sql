--------------------------------------------------------
--  DDL for Package HR_MX_EX_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_EX_EMPLOYEE_API" AUTHID CURRENT_USER AS
/* $Header: pemxwrxe.pkh 120.1 2005/10/02 02:43:23 aroussel $ */
/*#
 * This package contains Ex-Employee APIs for Mexico.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Ex-Employee for Mexico
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< mx_final_process_emp >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API sets the final process date for a terminated employee.
 *
 * This API covers the second step in terminating a period of service and all
 * current assignments for an employee. It updates the period of service
 * details and date-effectively deletes all employee assignments as of the
 * final process date. If a final process date is not specified for the U.S.
 * legislation, this API uses the actual termination date. For other
 * legislations, it uses the last standard process date. If you want to change
 * the final process date after it has been entered, you must cancel the
 * termination and reapply the termination from the new date. Element entries
 * for any assignment that have an element termination rule of Final Close are
 * date-effectively deleted from the final process date. Cost allocations,
 * grade step/point placements, COBRA coverage benefits, and personal payment
 * methods for all assignments are date-effectively deleted from the final
 * process date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The ex-employee must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The ex-employee is updated with the relevant final process date. The
 * ex-employee's assignments and other related records are deleted as of the
 * effective date.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the period of service, assignments, or element
 * entries and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_period_of_service_id Period of service that is being terminated.
 * @param p_ss_leaving_reason Social Security Leaving Reason for the employee's
 * termination.
 * @param p_object_version_number Pass in the current version number of the
 * period of service to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated period of
 * service. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_final_process_date Final Process Date. If p_validate is false, then
 * set to the final process date on the updated period of service row. If
 * p_validate is true, then set to the value passed in.
 * @param p_org_now_no_manager_warning If set to true, from the final process
 * date of this assignment there are no other managers in the assignment's
 * organization.
 * @param p_asg_future_changes_warning If set to true, then at least one
 * assignment change, after the actual termination date, has been overwritten
 * with the new assignment status.
 * @param p_entries_changed_warning Set to Y when at least one element entry is
 * affected by the assignment change. Set to S if at least one salary element
 * entry is affected. (This is a more specific case than Y.) Otherwise, set to
 * N when no element entries are affected.
 * @rep:displayname Final Process Employee for Mexico
 * @rep:category BUSINESS_ENTITY PER_EX-EMPLOYEE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
*/
--
-- {End Of Comments}
--
PROCEDURE mx_final_process_emp
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_period_of_service_id          IN     NUMBER
  ,p_ss_leaving_reason             IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_final_process_date            IN OUT NOCOPY DATE
  ,p_org_now_no_manager_warning       OUT NOCOPY BOOLEAN
  ,p_asg_future_changes_warning       OUT NOCOPY BOOLEAN
  ,p_entries_changed_warning          OUT NOCOPY VARCHAR2
  );
--
END hr_mx_ex_employee_api ;

 

/
