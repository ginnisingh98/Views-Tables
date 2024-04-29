--------------------------------------------------------
--  DDL for Package OTA_EVENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVENT_API" AUTHID CURRENT_USER as
/* $Header: otevtapi.pkh 120.2.12010000.3 2009/05/27 13:24:01 pekasi ship $ */
/*#
 * This package contains the class APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Class
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_class >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a class into which the learners enroll.
 *
 * This business process enables the entry of class details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The parent offering must already exist before a class can be created. The
 * parent offering must exist in the same business group as the business group
 * of the class, and must be active within the class dates being entered.
 *
 * <p><b>Post Success</b><br>
 * When the class has been successfully inserted, the following OUT parameters
 * are set.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a class, and raises an error.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_event_id If p_validate is false, then this ID uniquely identifies
 * the class created. If p_validate is true, then it is set to null.
 * @param p_vendor_id Foreign key to PO_VENDORS. The vendor hosting the class.
 * @param p_activity_version_id Foreign key to OTA_ACTIVITY_VERSIONS. The
 * course to which this class belongs.
 * @param p_business_group_id The business group owning the class.
 * @param p_organization_id Foreign key to HR_ALL_ORGANIZATION_UNITS. The
 * organization to which this class belongs.
 * @param p_event_type Class type. Valid values are defined by the
 * 'TRAINING_EVENT_TYPE' lookup type.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created class. If p_validate is true, then
 * the value is null.
 * @param p_title Class's title.
 * @param p_budget_cost The budgeted cost for the class.
 * @param p_actual_cost The actual cost of the class.
 * @param p_budget_currency_code The currency for the budgeted cost.
 * @param p_centre Obsolete parameter, do not use.
 * @param p_comments Comment text.
 * @param p_course_end_date The date on which the class ends.
 * @param p_course_end_time The end time of the class.
 * @param p_course_start_date The date on which the class starts.
 * @param p_course_start_time The start time of the class.
 * @param p_duration The duration of the class measured in units. The unit of
 * measure is specified in the column DURATION_UNITS.
 * @param p_duration_units The units in which the duration is measured. Valid
 * values are defined by the 'OTA_FREQUENCY' lookup type.
 * @param p_enrolment_end_date The closing date for enrollments in this class.
 * @param p_enrolment_start_date The earliest date on which enrollments may be
 * made for this class.
 * @param p_language_id The language in which this class is taught. This is
 * defaulted from the parent offering for the class.
 * @param p_user_status User definition for the class status.
 * @param p_development_event_type User description for the development type
 * defined.
 * @param p_event_status Class status. Valid values are defined by the
 * 'SCHEDULED_EVENT_STATUS' lookup type.
 * @param p_price_basis Price basis for this class. Valid values are defined by
 * the 'EVENT_PRICE_BASIS' lookup type.
 * @param p_currency_code The currency in which the standard price is defined.
 * @param p_maximum_attendees The maximum number of learners who may take this
 * class.
 * @param p_maximum_internal_attendees The maximum number of internal learners
 * who may take this class.
 * @param p_minimum_attendees The minimum number of learners for this class to
 * be viable.
 * @param p_standard_price The standard price per enrollment for this class. A
 * standard price can be per student (learner), per customer, or per order.
 * @param p_category_code Indicates the program of courses for this class.
 * @param p_parent_event_id Relevant for classes with type SESSION only. This
 * indicates the parent class for the SESSION.
 * @param p_book_independent_flag This flag indicates whether this class can
 * occur independently of a program.
 * @param p_public_event_flag This flag indicates whether a class can have
 * learner access associated with it.
 * @param p_secure_event_flag This flag indicates if a class can be maintained
 * only by employees of the administering organization.
 * @param p_evt_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_evt_information1 Descriptive flexfield segment.
 * @param p_evt_information2 Descriptive flexfield segment.
 * @param p_evt_information3 Descriptive flexfield segment.
 * @param p_evt_information4 Descriptive flexfield segment.
 * @param p_evt_information5 Descriptive flexfield segment.
 * @param p_evt_information6 Descriptive flexfield segment.
 * @param p_evt_information7 Descriptive flexfield segment.
 * @param p_evt_information8 Descriptive flexfield segment.
 * @param p_evt_information9 Descriptive flexfield segment.
 * @param p_evt_information10 Descriptive flexfield segment.
 * @param p_evt_information11 Descriptive flexfield segment.
 * @param p_evt_information12 Descriptive flexfield segment.
 * @param p_evt_information13 Descriptive flexfield segment.
 * @param p_evt_information14 Descriptive flexfield segment.
 * @param p_evt_information15 Descriptive flexfield segment.
 * @param p_evt_information16 Descriptive flexfield segment.
 * @param p_evt_information17 Descriptive flexfield segment.
 * @param p_evt_information18 Descriptive flexfield segment.
 * @param p_evt_information19 Descriptive flexfield segment.
 * @param p_evt_information20 Descriptive flexfield segment.
 * @param p_project_id Foreign key to PA_PROJECTS_ALL.
 * @param p_owner_id Foreign key to PER_ALL_PEOPLE_F.
 * @param p_line_id Foreign key to OE_ORDER_LINES_ALL.
 * @param p_org_id Foreign key to HR_ALL_ORGANIZATION_UNITS. The organization
 * that is associated with the enrollment through OM or OTA.
 * @param p_training_center_id Foreign key to HR_ALL_ORGANIZATIONS_UNITS.
 * @param p_location_id Foreign key to HR_LOCATIONS.
 * @param p_offering_id Obsolete parameter, do not use. This is the
 * corresponding iLearning offering for this class.
 * @param p_timezone Time zone of the class.
 * @param p_parent_offering_id Foreign key to OTA_OFFERINGS. This specifies the
 * parent of the class being created.
 * @param p_data_source Source of the class being created. Valid values are
 * defined by the 'OTA_OBJECT_DATA_SOURCE' lookup type.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database will be modified.
 * @param p_event_availability to define the availability of class
 * @rep:displayname Create Class
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CLASS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Create_class
  (p_effective_date              in     date
  ,p_event_id                    out nocopy number,
  p_vendor_id                    in number           default null,
  p_activity_version_id          in number           default null,
  p_business_group_id            in number,
  p_organization_id              in number           default null,
  p_event_type                   in varchar2,
  p_object_version_number        out nocopy number,
  p_title                        in varchar2,
  p_budget_cost                  in number           default null,
  p_actual_cost                  in number           default null,
  p_budget_currency_code         in varchar2         default null,
  p_centre                       in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_course_end_date              in date             default null,
  p_course_end_time              in varchar2         default null,
  p_course_start_date            in date             default null,
  p_course_start_time            in varchar2         default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_enrolment_end_date           in date             default null,
  p_enrolment_start_date         in date             default null,
  p_language_id                  in number           default null,
  p_user_status                  in varchar2         default null,
  p_development_event_type       in varchar2         default null,
  p_event_status                 in varchar2         default null,
  p_price_basis                  in varchar2         default null,
  p_currency_code                in varchar2         default null,
  p_maximum_attendees            in number           default null,
  p_maximum_internal_attendees   in number           default null,
  p_minimum_attendees            in number           default null,
  p_standard_price               in number           default null,
  p_category_code                in varchar2         default null,
  p_parent_event_id              in number           default null,
  p_book_independent_flag        in varchar2         default null,
  p_public_event_flag            in varchar2         default null,
  p_secure_event_flag            in varchar2         default null,
  p_evt_information_category     in varchar2         default null,
  p_evt_information1             in varchar2         default null,
  p_evt_information2             in varchar2         default null,
  p_evt_information3             in varchar2         default null,
  p_evt_information4             in varchar2         default null,
  p_evt_information5             in varchar2         default null,
  p_evt_information6             in varchar2         default null,
  p_evt_information7             in varchar2         default null,
  p_evt_information8             in varchar2         default null,
  p_evt_information9             in varchar2         default null,
  p_evt_information10            in varchar2         default null,
  p_evt_information11            in varchar2         default null,
  p_evt_information12            in varchar2         default null,
  p_evt_information13            in varchar2         default null,
  p_evt_information14            in varchar2         default null,
  p_evt_information15            in varchar2         default null,
  p_evt_information16            in varchar2         default null,
  p_evt_information17            in varchar2         default null,
  p_evt_information18            in varchar2         default null,
  p_evt_information19            in varchar2         default null,
  p_evt_information20            in varchar2         default null,
  p_project_id                   in number           default null,
  p_owner_id		         in number	     default null,
  p_line_id			 in number	     default null,
  p_org_id			 in number	     default null,
  p_training_center_id           in number           default null,
  p_location_id                  in number           default null,
  p_offering_id         	 in number           default null,
  p_timezone	                 in varchar2         default null,
  p_parent_offering_id		 in number	     default null,
  p_data_source	                 in varchar2         default null,
  p_validate                     in boolean          default false,
  p_event_availability           in varchar2         default null
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_class >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a class into which learners are enrolling or have enrolled.
 *
 * This business process enables the user to update class details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The class must exist.
 *
 * <p><b>Post Success</b><br>
 * When the class has been successfully updated, the following OUT parameters
 * are set.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the class, and raises an error.
 * @param p_event_id This parameter uniquely identifies the class being
 * updated.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_vendor_id Foreign key to PO_VENDORS. The vendor hosting the class.
 * @param p_activity_version_id Foreign key to OTA_ACTIVITY_VERSIONS. The
 * course to which this class belongs.
 * @param p_business_group_id The business group owning the class.
 * @param p_organization_id Foreign key to HR_ALL_ORGANIZATION_UNITS. The
 * organization to which this plan applies.
 * @param p_event_type Class type. Valid values are defined by the
 * 'TRAINING_EVENT_TYPE' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * class to be updated.When the API completes if p_validate is false, then the
 * number is set to the version number of the updated class. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_title Class's title
 * @param p_budget_cost The budgeted cost for the class.
 * @param p_actual_cost The actual cost of the class.
 * @param p_budget_currency_code The currency for the budgeted cost.
 * @param p_centre Obsolete parameter, do not use.
 * @param p_comments Comment text.
 * @param p_course_end_date The date on which the class ends.
 * @param p_course_end_time The end time of the class.
 * @param p_course_start_date The date on which the class starts.
 * @param p_course_start_time The start time of the class.
 * @param p_duration The duration of the class measured in units. The unit of
 * measure is specified in the column DURATION_UNITS.
 * @param p_duration_units The units in which the duration is measured. Valid
 * values are defined by the 'OTA_FREQUENCY' lookup type.
 * @param p_enrolment_end_date The closing date for enrollments in this class.
 * @param p_enrolment_start_date The earliest date on which enrollments may be
 * made for this class.
 * @param p_language_id The language in which this class is taught. This is
 * defaulted from the parent offering for the class.
 * @param p_user_status User definition for the class status.
 * @param p_development_event_type User description for the development type
 * defined.
 * @param p_event_status Class status. Valid values are defined by the
 * 'SCHEDULED_EVENT_STATUS' lookup type.
 * @param p_price_basis Price basis for this class. Valid values are defined by
 * the 'EVENT_PRICE_BASIS' lookup type.
 * @param p_currency_code The currency in which the standard price is defined.
 * @param p_maximum_attendees The maximum number of learners who may take this
 * class.
 * @param p_maximum_internal_attendees The maximum number of internal learners
 * who may take this class.
 * @param p_minimum_attendees The minimum number of learners for this class to
 * be viable.
 * @param p_standard_price The standard price per enrollment for this class. A
 * standard price can be per student (learner), per customer, or per order.
 * @param p_category_code Indicates the program of courses for this class.
 * @param p_parent_event_id Relevant only for classes of the type SESSION. This
 * indicates the parent class for the session.
 * @param p_book_independent_flag This flag indicates whether this class can
 * occur independently of a program.
 * @param p_public_event_flag This flag indicates whether a class can have
 * learner access associated with it.
 * @param p_secure_event_flag This flag indicates if a class can be maintained
 * only by employees of the administering organization.
 * @param p_evt_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_evt_information1 Descriptive flexfield segment.
 * @param p_evt_information2 Descriptive flexfield segment.
 * @param p_evt_information3 Descriptive flexfield segment.
 * @param p_evt_information4 Descriptive flexfield segment.
 * @param p_evt_information5 Descriptive flexfield segment.
 * @param p_evt_information6 Descriptive flexfield segment.
 * @param p_evt_information7 Descriptive flexfield segment.
 * @param p_evt_information8 Descriptive flexfield segment.
 * @param p_evt_information9 Descriptive flexfield segment.
 * @param p_evt_information10 Descriptive flexfield segment.
 * @param p_evt_information11 Descriptive flexfield segment.
 * @param p_evt_information12 Descriptive flexfield segment.
 * @param p_evt_information13 Descriptive flexfield segment.
 * @param p_evt_information14 Descriptive flexfield segment.
 * @param p_evt_information15 Descriptive flexfield segment.
 * @param p_evt_information16 Descriptive flexfield segment.
 * @param p_evt_information17 Descriptive flexfield segment.
 * @param p_evt_information18 Descriptive flexfield segment.
 * @param p_evt_information19 Descriptive flexfield segment.
 * @param p_evt_information20 Descriptive flexfield segment.
 * @param p_project_id Foreign key to PA_PROJECTS_ALL.
 * @param p_owner_id Foreign key to PER_ALL_PEOPLE_F.
 * @param p_line_id Foreign key to OE_ORDER_LINES_ALL.
 * @param p_org_id Foreign key to HR_ALL_ORGANIZATION_UNITS. The organization
 * that is associated with the enrollment through OM or OTA.
 * @param p_training_center_id Foreign key to HR_ALL_ORGANIZATIONS_UNITS.
 * @param p_location_id Foreign key to HR_LOCATIONS.
 * @param p_offering_id Obsolete parameter, do not use. This is the
 * corresponding iLearning offering for this class.
 * @param p_timezone Time zone of the class.
 * @param p_parent_offering_id Foreign key to OTA_OFFERINGS. This specifies the
 * parent of the class being created.
 * @param p_data_source Source of the class being created. Valid values are
 * defined by the 'OTA_OBJECT_DATA_SOURCE' lookup type.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database will be modified.
 * @param p_event_availability to define the availability of class
 * @rep:displayname Update Class
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CLASS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_class
  (p_event_id                    in number,
  p_effective_date               in date,
  p_vendor_id                    in number           default hr_api.g_number,
  p_activity_version_id          in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_event_type                   in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_budget_cost                  in number           default hr_api.g_number,
  p_actual_cost                  in number           default hr_api.g_number,
  p_budget_currency_code         in varchar2         default hr_api.g_varchar2,
  p_centre                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_course_end_date              in date             default hr_api.g_date,
  p_course_end_time              in varchar2         default hr_api.g_varchar2,
  p_course_start_date            in date             default hr_api.g_date,
  p_course_start_time            in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_enrolment_end_date           in date             default hr_api.g_date,
  p_enrolment_start_date         in date             default hr_api.g_date,
  p_language_id                  in number           default hr_api.g_number,
  p_user_status                  in varchar2         default hr_api.g_varchar2,
  p_development_event_type       in varchar2         default hr_api.g_varchar2,
  p_event_status                 in varchar2         default hr_api.g_varchar2,
  p_price_basis                  in varchar2         default hr_api.g_varchar2,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_maximum_attendees            in number           default hr_api.g_number,
  p_maximum_internal_attendees   in number           default hr_api.g_number,
  p_minimum_attendees            in number           default hr_api.g_number,
  p_standard_price               in number           default hr_api.g_number,
  p_category_code                in varchar2         default hr_api.g_varchar2,
  p_parent_event_id              in number           default hr_api.g_number,
  p_book_independent_flag        in varchar2         default hr_api.g_varchar2,
  p_public_event_flag            in varchar2         default hr_api.g_varchar2,
  p_secure_event_flag            in varchar2         default hr_api.g_varchar2,
  p_evt_information_category     in varchar2         default hr_api.g_varchar2,
  p_evt_information1             in varchar2         default hr_api.g_varchar2,
  p_evt_information2             in varchar2         default hr_api.g_varchar2,
  p_evt_information3             in varchar2         default hr_api.g_varchar2,
  p_evt_information4             in varchar2         default hr_api.g_varchar2,
  p_evt_information5             in varchar2         default hr_api.g_varchar2,
  p_evt_information6             in varchar2         default hr_api.g_varchar2,
  p_evt_information7             in varchar2         default hr_api.g_varchar2,
  p_evt_information8             in varchar2         default hr_api.g_varchar2,
  p_evt_information9             in varchar2         default hr_api.g_varchar2,
  p_evt_information10            in varchar2         default hr_api.g_varchar2,
  p_evt_information11            in varchar2         default hr_api.g_varchar2,
  p_evt_information12            in varchar2         default hr_api.g_varchar2,
  p_evt_information13            in varchar2         default hr_api.g_varchar2,
  p_evt_information14            in varchar2         default hr_api.g_varchar2,
  p_evt_information15            in varchar2         default hr_api.g_varchar2,
  p_evt_information16            in varchar2         default hr_api.g_varchar2,
  p_evt_information17            in varchar2         default hr_api.g_varchar2,
  p_evt_information18            in varchar2         default hr_api.g_varchar2,
  p_evt_information19            in varchar2         default hr_api.g_varchar2,
  p_evt_information20            in varchar2         default hr_api.g_varchar2,
  p_project_id                   in number           default hr_api.g_number,
  p_owner_id                     in number           default hr_api.g_number,
  p_line_id	                 in number           default hr_api.g_number,
  p_org_id	                 in number           default hr_api.g_number,
  p_training_center_id           in number           default hr_api.g_number,
  p_location_id	                 in number             default hr_api.g_number,
  p_offering_id		         in number               default hr_api.g_number,
  p_timezone	                 in varchar2           default hr_api.g_varchar2,
-- Bug#2200078 Corrected default value for offering_id and timezone
--  p_offering_id		 in number           default null,
--  p_timezone	                 in varchar2         default null,
  p_parent_offering_id 	         in number	         default hr_api.g_number,
  p_data_source                  in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
  p_event_availability           in varchar2         default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_class >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This business process enables the user to delete a class.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The class that is to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The class will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the class, and raises an error.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database will be modified.
 * @param p_event_id This column uniquely identifies the class being deleted.
 * @param p_object_version_number Current version number of the class to be
 * deleted.
 * @rep:displayname Delete Class
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CLASS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_class
  (p_validate                      in     boolean  default false
  ,p_event_id                   in     number
  ,p_object_version_number         in     number
  );

PROCEDURE add_evaluation
    ( p_event_id in number
     ,p_activity_version_id in number);


end ota_event_api;

/
