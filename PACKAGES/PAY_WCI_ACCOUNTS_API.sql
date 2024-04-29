--------------------------------------------------------
--  DDL for Package PAY_WCI_ACCOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_ACCOUNTS_API" AUTHID CURRENT_USER as
/* $Header: pypwaapi.pkh 120.1 2005/10/02 02:33:47 aroussel $ */
/*#
 * This Package contains Workers Compensation Account APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Worker Compensation Account for Canada
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_wci_account >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Workers Compensation Account for a Business Group for a
 * location.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group and the location_id for which the account is being
 * created , should exist.
 *
 * <p><b>Post Success</b><br>
 * It will create a Workers compensation account for that business group
 *
 * <p><b>Post Failure</b><br>
 * It will not create a Workers compensation account for that business group
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id Business Group Id for which the Workers
 * compensation account number is created
 * @param p_carrier_id Carrier ID
 * @param p_account_number Workers compensation Account number
 * @param p_name Name of the Workers compensation account
 * @param p_location_id Location ID for which the Workers compensation account
 * number is created
 * @param p_comments Comment text
 * @param p_account_id The Account_id created for the Workers compensation
 * account.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Workers compensation account. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Worker Compensation Account
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_wci_account
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_carrier_id                    in     number
  ,p_account_number                in     varchar2
  ,p_name                          in     varchar2 default null
  ,p_location_id                   in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_account_id                    out    nocopy number
  ,p_object_version_number         out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_wci_account >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Workers Compensation Account for a Business Group and
 * location.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Workers compensation account should exist
 *
 * <p><b>Post Success</b><br>
 * The Workers compensation account will be updated
 *
 * <p><b>Post Failure</b><br>
 * The Workers compensation account will not be updated
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_account_id The account_id of the WCI account which is being updated
 * @param p_object_version_number Pass in the current version number of the
 * Workers compensation account to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Workers compensation account. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_name The new name of the WCI account which is being updated
 * @param p_account_number The new Account Number of the account which is being
 * updated
 * @param p_location_id The new location ID of the account which is being
 * updated
 * @param p_comments Comment text
 * @rep:displayname Update Worker Compensation Account
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_wci_account
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_account_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_wci_account >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Workers compensation account.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Workers compensation account to be deleted exists
 *
 * <p><b>Post Success</b><br>
 * The Workers compensation account will be deleted
 *
 * <p><b>Post Failure</b><br>
 * The Workers compensation account will not be deleted
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_account_id Account ID of the Workers compensation account to be
 * deleted
 * @param p_object_version_number Current version number of the Workers
 * compensation account to be deleted.
 * @rep:displayname Delete Worker Compensation Account
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_wci_account
  (p_validate                      in     boolean  default false
  ,p_account_id                    in     number
  ,p_object_version_number         in     number
  );
--
end pay_wci_accounts_api;

 

/
