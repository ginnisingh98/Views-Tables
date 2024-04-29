--------------------------------------------------------
--  DDL for Package HR_USER_ACCT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_ACCT_API" AUTHID CURRENT_USER as
/* $Header: hrusrapi.pkh 120.4.12010000.2 2008/08/06 08:50:17 ubhat ship $ */
/*#
 * This package contains user account APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname User Account
*/
--
-- Private Global Variables
--

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_user_acct >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new user account for a person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist as of effective date.
 *
 * <p><b>Post Success</b><br>
 * The user account is successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The user account is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create the user account.
 * @param p_per_effective_start_date Identifies the effective start date of the person.
 * @param p_per_effective_end_date Identifies the effective end date of the person.
 * @param p_assignment_id Identifies the assignment for the associated person.
 * @param p_asg_effective_start_date Identifies the effective start date of the assignment.
 * @param p_asg_effective_end_date Identifies the effective end date of the assignment.
 * @param p_business_group_id Identifies the business group of the person.
 * @param p_date_from Identifies the start date depending on the p_run_type and letting the
 * user hook program know the person extract criteria.
 * @param p_date_to Identifies the end date depending on the p_run_type and letting the
 * user hook program know the person extract criteria.
 * @param p_hire_date Hire Date.
 * @param p_org_structure_id Identifies the organization structure for letting the user hook
 * program know the person extract criteria.
 * @param p_org_structure_vers_id Identifies version of the organization structure
 * for letting the user hook program know the person extract criteria.
 * @param p_parent_org_id Identifies the parent organization for letting the user hook
 * program know the person extract criteria.
 * @param p_single_org_id Identifies the single organization for letting the user hook
 * program know the person extract criteria.
 * @param p_run_type Identifies run type for letting the user hook program
 * know the person extract criteria.
 * @param p_user_id If p_validate is false, then this uniquely identifies
 * the created user account. If p_validate is true, then set to null.
 * @rep:displayname Create User Account
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
PROCEDURE create_user_acct
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_per_effective_start_date      in     date     default null
  ,p_per_effective_end_date        in     date     default null
  ,p_assignment_id                 in     number   default null
  ,p_asg_effective_start_date      in     date     default null
  ,p_asg_effective_end_date        in     date     default null
  ,p_business_group_id             in     number
  ,p_date_from                     in     date     default null
  ,p_date_to                       in     date     default null
  ,p_hire_date                     in     date     default null
  ,p_org_structure_id              in     number   default null
  ,p_org_structure_vers_id         in     number   default null
  ,p_parent_org_id                 in     number   default null
  ,p_single_org_id                 in     number   default null
  ,p_run_type                      in     varchar2 default null
  ,p_user_id                       out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------- < update_user_acct > ---------------------------|
-- |                                                                          |
-- | USAGE:                                                                   |
-- | -----                                                                    |
-- | This wrapper module is used to update fnd_user and                       |
-- | fnd_user_responsibility records specifically for expiring a user         |
-- | account.  User accounts for terminated persons will not be               |
-- | deleted because some HR history forms have sql statements join to the    |
-- | fnd_user table to derive the who columns.                                |
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates user accounts.
 *
 * The API is strictly used for inactivating terminated
 * person user accounts. These user accounts will not be deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person should exist as a terminated person.
 *
 * <p><b>Post Success</b><br>
 * All user accounts associated with the terminated person are inactivated.
 *
 * <p><b>Post Failure</b><br>
 * The user account is not updated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person whose user account should be inactivated.
 * @param p_per_effective_start_date Identifies the effective start date of the person as an ex-person.
 * @param p_per_effective_end_date Identifies the effective end date of the person as an ex-person.
 * @param p_assignment_id Identifies the terminated assignments for the associated person.
 * @param p_asg_effective_start_date Identifies the effective start date of the terminated assignment.
 * @param p_asg_effective_end_date Identifies the effective end date of the terminated assignment.
 * @param p_business_group_id Identifies the business group of the person.
 * @param p_date_from Identifies the start date depending on the p_run_type and letting the
 * user hook program know the person extract criteria.
 * @param p_date_to Identifies the end date depending on the p_run_type and letting the
 * user hook program know the person extract criteria.
 * @param p_org_structure_id Identifies the organization structure for letting the user hook
 * program know the person extract criteria.
 * @param p_org_structure_vers_id Identifies version of the organization structure
 * for letting the user hook program know the person extract criteria.
 * @param p_parent_org_id Identifies the parent organization for letting the user hook
 * program know the person extract criteria.
 * @param p_single_org_id Identifies the single organization for letting the user hook
 * program know the person extract criteria.
 * @param p_run_type Identifies run type for letting the user hook program
 * know the person extract criteria.
 * @param p_inactivate_date Date on which the person is terminated.
 * @rep:displayname Update User Account
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

PROCEDURE update_user_acct
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_per_effective_start_date      in     date     default null
  ,p_per_effective_end_date        in     date     default null
  ,p_assignment_id                 in     number   default null
  ,p_asg_effective_start_date      in     date     default null
  ,p_asg_effective_end_date        in     date     default null
  ,p_business_group_id             in     number
  ,p_date_from                     in     date     default null
  ,p_date_to                       in     date     default null
  ,p_org_structure_id              in     number   default null
  ,p_org_structure_vers_id         in     number   default null
  ,p_parent_org_id                 in     number   default null
  ,p_single_org_id                 in     number   default null
  ,p_run_type                      in     varchar2 default null
  ,p_inactivate_date               in     date
  );

--
--
END hr_user_acct_api;

/
