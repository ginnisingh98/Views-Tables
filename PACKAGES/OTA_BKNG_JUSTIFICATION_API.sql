--------------------------------------------------------
--  DDL for Package OTA_BKNG_JUSTIFICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BKNG_JUSTIFICATION_API" AUTHID CURRENT_USER as
/* $Header: otbjsapi.pkh 120.1 2006/08/30 06:55:10 niarora noship $ */
/*#
 * This package contains Booking Justification APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Booking Justification
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_booking_justification >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the booking justification.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Business group record must exist.
 *
 * <p><b>Post Success</b><br>
 * The booking justification was created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API did not create a booking justification record and has raised an error.
 *
 * @param p_effective_date Reference date for validating that lookup values are applicable
 * during the start-to-end active date range. This date does not determine when
 * the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id The business group owning the section record and the Learning Path.
 * @param p_priority_level Enrollment Priority. Valid values are defined by the
 * 'PRIORITY_LEVEL' lookup type.
 * @param p_justification_text The description of the justification.
 * @param p_start_date_active The start date of the active period for booking justification.
 * @param p_end_date_active The end date of the active period for booking justification.
 * @param p_booking_justification_id The unique identifier for the booking justification record.
 * @param p_object_version_number If p_validate is false, then set to the version number of
 * the created learning path section. If p_validate is true, then the value will be null.
 * @rep:displayname Create Booking Justification
 * @rep:category BUSINESS_ENTITY OTA_ENROLLMENT_JUSTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_booking_justification
  (
  p_effective_date               in date,
  p_validate                     in boolean   default false ,
   p_business_group_id            in number,
   p_priority_level in varchar2,
    p_justification_text in varchar2,
  p_start_date_active            in date,
  p_end_date_active              in date             default null,
  p_booking_justification_id             out nocopy number,
  p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_booking_justification >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the booking justification.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The booking justification record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The booking justification has been updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API did not update a booking justification record and has raised an error.
 *
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start-to-end active date range. This date
 * does not determine when the changes take effect.
 * @param p_booking_justification_id The unique identifier for the booking justification record.
 * @param p_object_version_number Passes in the current version number of the learning path
 * section to be updated. When the API completes, if p_validate is false, will be set to
 * the new version number of the updated learning path section. If p_validate is true will be
 * set to the same value which was passed in.
 * @param p_priority_level Enrollment Priority. Valid values are defined by the
 * 'PRIORITY_LEVEL' lookup type.
 * @param p_justification_text The description of the justification.
 * @param p_start_date_active The start date of the active period for booking justification.
 * @param p_end_date_active The end date of the active period for booking justification.
 * @param p_business_group_id The business group owning the section record and the Learning Path.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Update Booking Justification
 * @rep:category BUSINESS_ENTITY OTA_ENROLLMENT_JUSTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_booking_justification
  (
  p_effective_date               in date,
  p_booking_justification_id             in number,
  p_object_version_number        in out nocopy number,
  p_priority_level                    in varchar2         default hr_api.g_varchar2,
  p_justification_text             in varchar2         default hr_api.g_varchar2,
  p_start_date_active            in date             default hr_api.g_date,
  p_end_date_active              in date             default hr_api.g_date,
  p_business_group_id            in number           default hr_api.g_number,
  p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_booking_justification >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the booking justification.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The booking justification record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The booking justification has been deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API has not deleted the booking justification record, and has raised an error.
 *
 * @param p_booking_justification_id The unique identifier for the booking justification record.
 * @param p_object_version_number Current version number of the learning path section to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Booking Justification
 * @rep:category BUSINESS_ENTITY OTA_ENROLLMENT_JUSTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_booking_justification
  (p_booking_justification_id           in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );
end ota_bkng_justification_api;

 

/
