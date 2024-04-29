--------------------------------------------------------
--  DDL for Package PER_BF_BALANCE_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_BALANCE_TYPES_API" AUTHID CURRENT_USER as
/* $Header: pebbtapi.pkh 120.1 2005/10/02 02:12:04 aroussel $ */
/*#
 * This package contains APIs that will maintain backfeed balance types for
 * customers who are using a third party payroll application.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Backfeed Balance Type
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_balance_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new backfeed balance type information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Business group must be created for linking the balance amount.
 *
 * <p><b>Post Success</b><br>
 * The backfeed balance type will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed balance type will not be created and an error will be raised.
 * @param p_balance_type_id Uniquely identifies the backfeed balance type
 * record to create.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created backfeed balance type. If p_validate is true,
 * then the value will be null.
 * @param p_input_value_id Internal identifier of the element types input
 * value.
 * @param p_business_group_id Business group in which the balance type is
 * created.
 * @param p_displayed_name Name of the balance type to be displayed on forms
 * and reports.
 * @param p_internal_name Internal name of the balance type.
 * @param p_uom Unit of Measure for the balance.
 * @param p_currency Currency of the balance type.
 * @param p_category Category to group the types.
 * @param p_date_from Date the type is valid from.
 * @param p_date_to Date the type is valid to.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Backfeed Balance Type
 * @rep:category BUSINESS_ENTITY PER_BF_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_balance_type
 ( p_balance_type_id	          out nocopy    number
  ,p_object_version_number        out nocopy    number
  --
  ,p_input_value_id               in     number         default null
  ,p_business_group_id            in     number
  ,p_displayed_name               in     varchar2
  ,p_internal_name                in     varchar2
  ,p_uom                          in     varchar2       default null
  ,p_currency                     in     varchar2       default null
  ,p_category                     in     varchar2       default null
  ,p_date_from                    in     date           default null
  ,p_date_to                      in     date           default null
  ,p_validate                     in     boolean        default false
  ,p_effective_date               in     date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_balance_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates new backfeed balance type information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business type must be passed to the API.
 *
 * <p><b>Post Success</b><br>
 * The backfeed balance type will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed balance type will not be updated and an error will be raised.
 * @param p_balance_type_id Uniquely identifies the backfeed balance type
 * record to update.
 * @param p_input_value_id Internal identifier of the element types input
 * value.
 * @param p_displayed_name Name of the balance type to be displayed on forms
 * and reports
 * @param p_internal_name Internal name of the balance type.
 * @param p_uom Unit of Measure for the balance.
 * @param p_currency Currency of the balance type.
 * @param p_category Category to group the types.
 * @param p_date_from Date the type is valid from.
 * @param p_date_to Date the type is valid to.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number Pass in the current version number of the
 * backfeed balance type to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated backfeed balance
 * amount. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Backfeed Balance Type
 * @rep:category BUSINESS_ENTITY PER_BF_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_balance_type
 ( p_balance_type_id              in number
  ,p_input_value_id               in number     default hr_api.g_number
  ,p_displayed_name               in varchar2   default hr_api.g_varchar2
  ,p_internal_name                in varchar2   default hr_api.g_varchar2
  ,p_uom                          in varchar2   default hr_api.g_varchar2
  ,p_currency                     in varchar2   default hr_api.g_varchar2
  ,p_category                     in varchar2   default hr_api.g_varchar2
  ,p_date_from                    in date       default hr_api.g_date
  ,p_date_to                      in date       default hr_api.g_date
  ,p_validate                     in boolean    default false
  ,p_effective_date               in date
  ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_balance_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes new backfeed balance type information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid balance_type must already exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed balance type amount will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed balance type will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_balance_type_id Balance_type to be deleted. If p_validate is false,
 * uniquely identifies the balance_type to be deleted. If p_validate is true,
 * set to null.
 * @param p_object_version_number Current version number of the backfeed
 * balance type to be deleted.
 * @rep:displayname Delete Backfeed Balance Type
 * @rep:category BUSINESS_ENTITY PER_BF_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_balance_type
(p_validate                           in boolean default false,
 p_balance_type_id                    in number,
 p_object_version_number              in number
);
--
end per_bf_balance_types_api;

 

/
