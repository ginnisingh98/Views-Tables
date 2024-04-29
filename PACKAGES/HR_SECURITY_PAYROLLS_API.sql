--------------------------------------------------------
--  DDL for Package HR_SECURITY_PAYROLLS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_PAYROLLS_API" AUTHID CURRENT_USER as
/* $Header: hrsprapi.pkh 120.3.12010000.1 2008/07/28 03:49:03 appldev ship $ */
/*#
 * This package contains APIs for Security Payroll.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Security Payroll
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pay_security_payroll >-----------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This api creates a new security payroll
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The security profile id and payroll id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API inserts payroll successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not insert payroll and raises an error
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date  Reference date for validating lookup values
 * are applicable during the start to end active date range. This date
 * does not determine when the changes take effect.
 * @param p_security_profile_id Identifies the security profile record for which
 * the security payroll is to be created.
 * @param p_payroll_id Identifies the payroll record for which the security payroll
 * is to be created.
 * @param p_object_version_number The version of the newly created row.
 * @rep:displayname Create Security Payroll
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_DEFINITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure create_pay_security_payroll
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_security_profile_id           in     number
  ,p_payroll_id                    in     number
  ,p_object_version_number         out nocopy number
  );
--
--
-- --------------------------------------------------------------------------
-- |-----------------------< delete_pay_security_payroll >-----------------|
-- --------------------------------------------------------------------------
--
/*#
 * This api deletes a security payroll
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The security profile id and payroll id must already exist.
 *
 * <p><b>Post Success</b><br>
 * When payroll id is valid, the API deletes the security profile.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete payroll and raises an error
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_security_profile_id Identifies the security profile record for which
 * the security payroll is to be deleted.
 * @param p_payroll_id Identifies the payroll record for which the security
 * payroll is to be deleted.
 * @param p_object_version_number Current version number of the security payroll
 * to be deleted
 * @rep:displayname Delete Security Payroll
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_DEFINITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure delete_pay_security_payroll
  (p_validate                      in     boolean  default false
  ,p_security_profile_id           in     number
  ,p_payroll_id                    in     number
  ,p_object_version_number         in     number
  );
--

end hr_security_payrolls_api;

/
