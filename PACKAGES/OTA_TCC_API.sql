--------------------------------------------------------
--  DDL for Package OTA_TCC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TCC_API" AUTHID CURRENT_USER as
/* $Header: ottccapi.pkh 120.1 2005/10/02 02:08:08 aroussel $ */
/*#
 * This package contains the APIs to create and update a cross charge.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Cross Charge
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_cross_charge >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an internal cross charge by mapping Chart of Account
 * details from Oracle General Ledger to Oracle Human Resources.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Set of Books and the business group should exist.
 *
 * <p><b>Post Success</b><br>
 * The cross charge will be successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a cross charge, and raises an error.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the cross charge.
 * @param p_gl_set_of_books_id Foreign key to GL_SETS_OF_BOOKS.
 * @param p_type The type of Cross charge. Valid values are defined by
 * 'OTA_CROSS_CHARGE_TYPE' lookup type.
 * @param p_from_to Source of the cross charge. Valid values are defined by
 * 'OTA_CROSS_CHARGE_FROM_TO' lookup type.
 * @param p_start_date_active The date on which the cross charge definition
 * becomes active.
 * @param p_end_date_active The date on which the cross charge definition ends.
 * @param p_cross_charge_id If p_validate is false, then this uniquely
 * identifies the cross charge created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created cross charge. If p_validate is true, then the
 * value will be null.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass the
 * database will be modified.
 * @rep:displayname Create Cross Charge
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CROSS_CHARGE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cross_charge
  (p_effective_date               in     date
  ,p_business_group_id              in     number
  ,p_gl_set_of_books_id             in     number
  ,p_type                           in     varchar2
  ,p_from_to                        in     varchar2
  ,p_start_date_active              in     date
  ,p_end_date_active                in     date     default null
  ,p_cross_charge_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_validate                       in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_cross_charge >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the cross charge details.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The cross charge should exist.
 *
 * <p><b>Post Success</b><br>
 * The cross charge will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the cross charge, and raises an error.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cross_charge_id This parameter uniquely identifies the cross charge
 * being updated.
 * @param p_object_version_number Pass in the current version number of the
 * cross charge to be updated. When the API completes, if p_validate is false,
 * will be set to the new version number of the updated cross charge. If
 * p_validate is true will be set to the same value which is passed in.
 * @param p_business_group_id The business group owning the cross charge.
 * @param p_gl_set_of_books_id Foreign key to GL_SETS_OF_BOOKS.
 * @param p_type The type of Cross Charge. Valid values are defined by the
 * 'OTA_CROSS_CHARGE_TYPE' lookup type.
 * @param p_from_to Source of the cross charge. Valid values are defined by the
 * 'OTA_CROSS_CHARGE_FROM_TO' lookup type.
 * @param p_start_date_active The date on which the cross charge definition
 * becomes active.
 * @param p_end_date_active The date on which the cross charge definition ends.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database will be modified.
 * @rep:displayname Update Cross Charge
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CROSS_CHARGE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cross_charge
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_gl_set_of_books_id           in     number    default hr_api.g_number
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_from_to                      in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_validate                     in     boolean    default false
  );


end OTA_TCC_API;

 

/
