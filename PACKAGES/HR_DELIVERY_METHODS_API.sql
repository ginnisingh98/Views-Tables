--------------------------------------------------------
--  DDL for Package HR_DELIVERY_METHODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DELIVERY_METHODS_API" AUTHID CURRENT_USER as
/* $Header: pepdmapi.pkh 120.1.12010000.2 2009/03/12 10:40:38 dparthas ship $ */
/*#
 * This package contains APIs that will maintain the delivery methods used to
 * communicate with a person.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Delivery Method
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_delivery_method >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new delivery method for a person.
 *
 * A Delivery method is the medium by which one communicates with a person,
 * e.g., e-mail, fax. A person can designate multiple delivery methods, one of
 * which can be the preferred method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person record must exist before a delivery method is created for them.
 *
 * <p><b>Post Success</b><br>
 * A delivery method will be created for the person
 *
 * <p><b>Post Failure</b><br>
 * A delivery method will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_person_id Identifies the person for whom you create the person
 * delivery record.
 * @param p_comm_dlvry_method The delivery method. Valid values are defined by
 * the PER_CM_MTHD lookup type.
 * @param p_date_start Start date for delivery method.
 * @param p_date_end End date for delivery method.
 * @param p_preferred_flag Must be set to 'Y' or 'N'. Valid values are based on
 * the lookup type 'YES_NO'.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_delivery_method_id If p_validate is false then this uniquely
 * identifies the delivery method created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created delivery method. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Delivery Method
 * @rep:category BUSINESS_ENTITY HR_PERSONAL_DELIVERY_METHOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_delivery_method
(
   p_validate                       in  boolean   default false
  ,p_effective_date                 in  date
  ,p_person_id                      in  number
  ,p_comm_dlvry_method              in  varchar2
  ,p_date_start                     in  date
  ,p_date_end                       in  date      default hr_api.g_eot
  ,p_preferred_flag                 in  varchar2  default 'N'
  ,p_request_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_delivery_method_id             out nocopy number
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_delivery_method >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing delivery method for a person.
 *
 * A Delivery method is the vehicle by which one communicates with a person,
 * e.g., e-mail, fax. A person can designate multiple delivery methods, one of
 * which can be the preferred method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A delivery method must exist before it can be updated.
 *
 * <p><b>Post Success</b><br>
 * The delivery method will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The delivery method will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_delivery_method_id This uniquely identifies the delivery method to
 * be updated
 * @param p_object_version_number Pass in the current version number of the
 * delivery method to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated delivery method.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_date_start Start date for delivery method.
 * @param p_date_end End date for delivery method.
 * @param p_comm_dlvry_method The delivery method. Valid values are defined by
 * the PER_CM_MTHD lookup type.
 * @param p_preferred_flag Must be set to 'Y' or 'N'. Valid values are based on
 * the lookup type 'YES_NO'.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @rep:displayname Update Delivery Method
 * @rep:category BUSINESS_ENTITY HR_PERSONAL_DELIVERY_METHOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_delivery_method
  (
   p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_delivery_method_id             in     number
  ,p_object_version_number          in out nocopy number
  ,p_date_start                     in     date      default hr_api.g_date
  ,p_date_end                       in     date      default hr_api.g_date
  ,p_comm_dlvry_method              in     varchar2  default hr_api.g_varchar2
  ,p_preferred_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_request_id                     in     number    default hr_api.g_number
  ,p_program_update_date            in     date      default hr_api.g_date
  ,p_program_application_id         in     number    default hr_api.g_number
  ,p_program_id                     in     number    default hr_api.g_number
  ,p_attribute_category             in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_delivery_method >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a delivery method.
 *
 * A Delivery method is the vehicle by which one communicates with a person,
 * e.g., e-mail, fax. A person can designate multiple delivery methods, one of
 * which can be the preferred method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A delivery method must have been created for a person.
 *
 * <p><b>Post Success</b><br>
 * The delivery method will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The delivery method will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_delivery_method_id This uniquely identifies the delivery method to
 * be deleted
 * @param p_object_version_number Current version number of the delivery method
 * to be deleted.
 * @rep:displayname Delete Delivery Method
 * @rep:category BUSINESS_ENTITY HR_PERSONAL_DELIVERY_METHOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_delivery_method
  (
   p_validate                       in boolean        default false
  ,p_delivery_method_id             in number
  ,p_object_version_number          in number
  );
--
end hr_delivery_methods_api;

/
