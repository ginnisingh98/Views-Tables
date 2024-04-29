--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_BOOKING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_BOOKING_API" AUTHID CURRENT_USER as
/* $Header: ottrbapi.pkh 120.4 2006/03/06 02:29:49 rdola noship $ */
/*#
 * This package contains the Resource Booking APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Resource Booking
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_resource_booking >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API books a resource for a class.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Class and the Resource must exist.
 *
 * <p><b>Post Success</b><br>
 * The resource booking is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The resource booking will not be created and an error will be raised.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_supplied_resource_id The unique identifier of the resource that is
 * being booked.
 * @param p_date_booking_placed {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.DATE_BOOKING_PLACED}
 * @param p_status Resource Booking status. Valid values are defined by the
 * 'RESOURCE_BOOKING_STATUS' lookup type.
 * @param p_event_id The unique identifier of the class for which the resource
 * is being booked.
 * @param p_absolute_price {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.ABSOLUTE_PRICE}
 * @param p_booking_person_id The unique identifier of the person who is
 * booking the resource.
 * @param p_comments {@rep:casecolumn OTA_RESOURCE_BOOKINGS.COMMENTS}
 * @param p_contact_name {@rep:casecolumn OTA_RESOURCE_BOOKINGS.CONTACT_NAME}
 * @param p_contact_phone_number {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.CONTACT_PHONE_NUMBER}
 * @param p_delegates_per_unit {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.DELEGATES_PER_UNIT}
 * @param p_quantity {@rep:casecolumn OTA_RESOURCE_BOOKINGS.QUANTITY}
 * @param p_required_date_from {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.REQUIRED_DATE_FROM}
 * @param p_required_date_to {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.REQUIRED_DATE_TO}
 * @param p_required_end_time {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.REQUIRED_END_TIME}
 * @param p_required_start_time {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.REQUIRED_START_TIME}
 * @param p_deliver_to {@rep:casecolumn OTA_RESOURCE_BOOKINGS.DELIVER_TO}
 * @param p_primary_venue_flag {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.PRIMARY_VENUE_FLAG}
 * @param p_role_to_play Resource Booking status. Valid values are defined by
 * the 'TRAINER_PARTICIPATION' lookup type.
 * @param p_trb_information_category This context value determines which
 * Flexfield Structure to use with the Resource Booking Descriptive flexfield
 * segments.
 * @param p_trb_information1 Descriptive flexfield segment.
 * @param p_trb_information2 Descriptive flexfield segment.
 * @param p_trb_information3 Descriptive flexfield segment.
 * @param p_trb_information4 Descriptive flexfield segment.
 * @param p_trb_information5 Descriptive flexfield segment.
 * @param p_trb_information6 Descriptive flexfield segment.
 * @param p_trb_information7 Descriptive flexfield segment.
 * @param p_trb_information8 Descriptive flexfield segment.
 * @param p_trb_information9 Descriptive flexfield segment.
 * @param p_trb_information10 Descriptive flexfield segment.
 * @param p_trb_information11 Descriptive flexfield segment.
 * @param p_trb_information12 Descriptive flexfield segment.
 * @param p_trb_information13 Descriptive flexfield segment.
 * @param p_trb_information14 Descriptive flexfield segment.
 * @param p_trb_information15 Descriptive flexfield segment.
 * @param p_trb_information16 Descriptive flexfield segment.
 * @param p_trb_information17 Descriptive flexfield segment.
 * @param p_trb_information18 Descriptive flexfield segment.
 * @param p_trb_information19 Descriptive flexfield segment.
 * @param p_trb_information20 Descriptive flexfield segment.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_resource_booking_id The unique identifier of the resource booking
 * record.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created learning path category Inclusion
 * record. If p_validate is true, then the value is null.
 * @param p_display_to_learner_flag Valid values are defined by the 'YES_NO' lookup type.
 * Specifies whether the booking is displayed to the learner.
 * @param p_book_entire_period_flag Valid values are defined by the 'YES_NO' lookup type.
 * Specifies whether the booking lasts for the entire time of the class or session,
 * starting on the first day at the start time, and ending on the last day at the end time.
 * @param p_chat_id The unique identifier of the chat for which the resource is being booked.
 * @param p_forum_id The unique identifier of the forum for which the resource is being booked.
 * @param p_timezone_code The time zone code of the resource booking.
 * @rep:displayname Create Resource Booking
 * @rep:category BUSINESS_ENTITY OTA_RESOURCE_BOOKING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_resource_booking
  (p_effective_date                 in     date
  ,p_supplied_resource_id           in     number
  ,p_date_booking_placed            in     date
  ,p_status                         in     varchar2
  ,p_event_id                       in     number   default null
  ,p_absolute_price                 in     number   default null
  ,p_booking_person_id              in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_contact_name                   in     varchar2 default null
  ,p_contact_phone_number           in     varchar2 default null
  ,p_delegates_per_unit             in     number   default null
  ,p_quantity                       in     number   default null
  ,p_required_date_from             in     date     default null
  ,p_required_date_to               in     date     default null
  ,p_required_end_time              in     varchar2 default null
  ,p_required_start_time            in     varchar2 default null
  ,p_deliver_to                     in     varchar2 default null
  ,p_primary_venue_flag             in     varchar2 default null
  ,p_role_to_play                   in     varchar2 default null
  ,p_trb_information_category       in     varchar2 default null
  ,p_trb_information1               in     varchar2 default null
  ,p_trb_information2               in     varchar2 default null
  ,p_trb_information3               in     varchar2 default null
  ,p_trb_information4               in     varchar2 default null
  ,p_trb_information5               in     varchar2 default null
  ,p_trb_information6               in     varchar2 default null
  ,p_trb_information7               in     varchar2 default null
  ,p_trb_information8               in     varchar2 default null
  ,p_trb_information9               in     varchar2 default null
  ,p_trb_information10              in     varchar2 default null
  ,p_trb_information11              in     varchar2 default null
  ,p_trb_information12              in     varchar2 default null
  ,p_trb_information13              in     varchar2 default null
  ,p_trb_information14              in     varchar2 default null
  ,p_trb_information15              in     varchar2 default null
  ,p_trb_information16              in     varchar2 default null
  ,p_trb_information17              in     varchar2 default null
  ,p_trb_information18              in     varchar2 default null
  ,p_trb_information19              in     varchar2 default null
  ,p_trb_information20              in     varchar2 default null
  ,p_display_to_learner_flag      in     varchar2  default null
  ,p_book_entire_period_flag    in     varchar2  default null
 -- ,p_unbook_request_flag          in     varchar2  default null
  ,p_chat_id                        in number default null
  ,p_forum_id                       in number default null
  ,p_validate                       in  boolean  default false
  ,p_resource_booking_id            out nocopy number
  ,p_object_version_number          out nocopy NUMBER
  ,p_timezone_code                  IN VARCHAR2 DEFAULT NULL
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_resource_booking >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a resource booking record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The resource booking record must exist.
 *
 * <p><b>Post Success</b><br>
 * The resource booking is succeesfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The resource booking record is not updated and an error is raised.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_supplied_resource_id The unique identifier of the resource booking
 * record.
 * @param p_date_booking_placed {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.DATE_BOOKING_PLACED}
 * @param p_status Resource Booking status. Valid values are defined by the
 * 'RESOURCE_BOOKING_STATUS' lookup type.
 * @param p_event_id The unique identifier of the class for which the resource
 * is being booked.
 * @param p_absolute_price {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.ABSOLUTE_PRICE}
 * @param p_booking_person_id The unique identifier of the person who is
 * booking the resource.
 * @param p_comments {@rep:casecolumn OTA_RESOURCE_BOOKINGS.COMMENTS}
 * @param p_contact_name {@rep:casecolumn OTA_RESOURCE_BOOKINGS.CONTACT_NAME}
 * @param p_contact_phone_number {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.CONTACT_PHONE_NUMBER}
 * @param p_delegates_per_unit {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.DELEGATES_PER_UNIT}
 * @param p_quantity {@rep:casecolumn OTA_RESOURCE_BOOKINGS.QUANTITY}
 * @param p_required_date_from {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.REQUIRED_DATE_FROM}
 * @param p_required_date_to {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.REQUIRED_DATE_TO}
 * @param p_required_end_time {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.REQUIRED_END_TIME}
 * @param p_required_start_time {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.REQUIRED_START_TIME}
 * @param p_deliver_to {@rep:casecolumn OTA_RESOURCE_BOOKINGS.DELIVER_TO}
 * @param p_primary_venue_flag {@rep:casecolumn
 * OTA_RESOURCE_BOOKINGS.PRIMARY_VENUE_FLAG}
 * @param p_role_to_play Resource Booking status. Valid values are defined by
 * the 'TRAINER_PARTICIPATION' lookup type.
 * @param p_trb_information_category This context value determines which
 * Flexfield Structure to use with the Resource Booking Descriptive flexfield
 * segments.
 * @param p_trb_information1 Descriptive flexfield segment.
 * @param p_trb_information2 Descriptive flexfield segment.
 * @param p_trb_information3 Descriptive flexfield segment.
 * @param p_trb_information4 Descriptive flexfield segment.
 * @param p_trb_information5 Descriptive flexfield segment.
 * @param p_trb_information6 Descriptive flexfield segment.
 * @param p_trb_information7 Descriptive flexfield segment.
 * @param p_trb_information8 Descriptive flexfield segment.
 * @param p_trb_information9 Descriptive flexfield segment.
 * @param p_trb_information10 Descriptive flexfield segment.
 * @param p_trb_information11 Descriptive flexfield segment.
 * @param p_trb_information12 Descriptive flexfield segment.
 * @param p_trb_information13 Descriptive flexfield segment.
 * @param p_trb_information14 Descriptive flexfield segment.
 * @param p_trb_information15 Descriptive flexfield segment.
 * @param p_trb_information16 Descriptive flexfield segment.
 * @param p_trb_information17 Descriptive flexfield segment.
 * @param p_trb_information18 Descriptive flexfield segment.
 * @param p_trb_information19 Descriptive flexfield segment.
 * @param p_trb_information20 Descriptive flexfield segment.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_resource_booking_id The unique identifier of the resource booking
 * record.
 * @param p_object_version_number Pass in the current version number of the
 * resource booking record to be updated. When the API completes, if p_validate
 * is false, the number is set to the new version number of the updated
 * resource booking record. If p_validate is true the number remains unchanged.
 * @param p_display_to_learner_flag Valid values are defined by the 'YES_NO' lookup type.
 * Specifies whether the booking is displayed to the learner.
 * @param p_book_entire_period_flag Valid values are defined by the 'YES_NO' lookup type.
 * Specifies whether the booking lasts for the entire time of the class or session,
 * starting on the first day at the start time, and ending on the last day at the end time.
 * @param p_chat_id The unique identifier of the chat for which the resource is being booked.
 * @param p_forum_id The unique identifier of the forum for which the resource is being booked.
 * @param p_timezone_code The time zone code of the resource booking.
 * @rep:displayname Update Resource Booking
 * @rep:category BUSINESS_ENTITY OTA_RESOURCE_BOOKING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_resource_booking
  (p_effective_date                 in     date
  ,p_supplied_resource_id           in     number
  ,p_date_booking_placed            in     date
  ,p_status                         in     varchar2
  ,p_event_id                       in     number   default hr_api.g_number
  ,p_absolute_price                 in     number   default hr_api.g_number
  ,p_booking_person_id              in     number   default hr_api.g_number
  ,p_comments                       in     varchar2 default hr_api.g_varchar2
  ,p_contact_name                   in     varchar2 default hr_api.g_varchar2
  ,p_contact_phone_number           in     varchar2 default hr_api.g_varchar2
  ,p_delegates_per_unit             in     number   default hr_api.g_number
  ,p_quantity                       in     number   default hr_api.g_number
  ,p_required_date_from             in     date     default hr_api.g_date
  ,p_required_date_to               in     date     default hr_api.g_date
  ,p_required_end_time              in     varchar2 default hr_api.g_varchar2
  ,p_required_start_time            in     varchar2 default hr_api.g_varchar2
  ,p_deliver_to                     in     varchar2 default hr_api.g_varchar2
  ,p_primary_venue_flag             in     varchar2 default hr_api.g_varchar2
  ,p_role_to_play                   in     varchar2 default hr_api.g_varchar2
  ,p_trb_information_category       in     varchar2 default hr_api.g_varchar2
  ,p_trb_information1               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information2               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information3               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information4               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information5               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information6               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information7               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information8               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information9               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information10              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information11              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information12              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information13              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information14              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information15              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information16              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information17              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information18              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information19              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information20              in     varchar2 default hr_api.g_varchar2
  ,p_display_to_learner_flag      in     varchar2  default hr_api.g_varchar2
  ,p_book_entire_period_flag    in     varchar2  default hr_api.g_varchar2
 -- ,p_unbook_request_flag	  in     varchar2  default hr_api.g_varchar2
  ,p_chat_id                        in number  default hr_api.g_number
  ,p_forum_id                       in number  default hr_api.g_number
  ,p_validate                       in  boolean
  ,p_resource_booking_id            in  number
  ,p_object_version_number          in out nocopy number
  ,p_timezone_code                  IN VARCHAR2 DEFAULT hr_api.g_varchar2
   );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_resource_booking >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the resource booking record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The resource booking record must exist.
 *
 * <p><b>Post Success</b><br>
 * The resource booking is succeesfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The resource booking is not deleted and an error will be raised.
 * @param p_resource_booking_id The unique identifier of the resource booking
 * record.
 * @param p_object_version_number Current version number of the resource
 * booking record to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Resource Booking
 * @rep:category BUSINESS_ENTITY OTA_RESOURCE_BOOKING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_resource_booking
 (
  p_resource_booking_id                in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  );

end ota_resource_booking_api;

 

/
