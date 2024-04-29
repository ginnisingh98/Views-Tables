--------------------------------------------------------
--  DDL for Package PAY_WCI_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_RATES_API" AUTHID CURRENT_USER as
/* $Header: pypwrapi.pkh 120.1 2005/10/02 02:33:57 aroussel $ */
/*#
 * This package contains WCI rates APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Worker Compensation Rate
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_wci_rate >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Workers compensation rate for an existing WCI account.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Workers compensation account should already exist
 *
 * <p><b>Post Success</b><br>
 * The Workers compensation rate will be created
 *
 * <p><b>Post Failure</b><br>
 * The Workers compensation rate will not be created
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_account_id Account id for the Workers compensation account for
 * which the rate to be created
 * @param p_code Code of the Workers compensation rate to be created
 * @param p_rate Rate of the Workers compensation rate to be created
 * @param p_description Description of the Workers compensation rate to be
 * created
 * @param p_comments Comment text
 * @param p_rate_id The rate_id of the Workers compensation rate created
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created WCI rate. If p_validate is true, then the
 * value will be null
 * @rep:displayname Create Worker Compensation Rate
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_wci_rate
  (p_validate                      in     boolean  default false
  ,p_account_id                    in     number
  ,p_code                          in     varchar2
  ,p_rate                          in     number   default null
  ,p_description                   in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_rate_id                       out    nocopy number
  ,p_object_version_number         out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_wci_rate >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Workers compensation rate.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Workers compensation rate whould already exist for the business group
 *
 * <p><b>Post Success</b><br>
 * The Workers compensation rate will be updated
 *
 * <p><b>Post Failure</b><br>
 * The Workers compensation rate will not be updated
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rate_id The rate_id for the Workers compensation rate to be updated
 * @param p_object_version_number Pass in the current version number of the
 * Workers compensation rate to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Workers compensation rate. If p_validate is true will be set to the same
 * value which was passed in
 * @param p_code {@rep:casecolumn PAY_WCI_RATES.CODE}
 * @param p_rate {@rep:casecolumn PAY_WCI_RATES.RATE}
 * @param p_description Description of the Workers compensation rate to be
 * updated
 * @param p_comments Comment text
 * @rep:displayname Update Worker Compensation Rate
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_wci_rate
  (p_validate                      in     boolean  default false
  ,p_rate_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_code                          in     varchar2 default hr_api.g_varchar2
  ,p_rate                          in     number   default hr_api.g_number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_wci_rate >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Workers compensation rate.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rate_id should alredy exist
 *
 * <p><b>Post Success</b><br>
 * The Workers compensation rate will be deleted
 *
 * <p><b>Post Failure</b><br>
 * The WCI rate will not be deleted
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_object_version_number Current version number of the Workers
 * compensation rate to be deleted
 * @param p_rate_id Rate_id for which the occupation is being deleted
 * @rep:displayname Delete Worker Compensation Rate
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_wci_rate
  (p_validate                      in     boolean  default false
  ,p_object_version_number         in     number
  ,p_rate_id                       in     number
  );
--
end pay_wci_rates_api;

 

/
