--------------------------------------------------------
--  DDL for Package OTA_ACTIVITY_VERSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACTIVITY_VERSION_API" AUTHID CURRENT_USER as
/* $Header: ottavapi.pkh 120.4.12010000.2 2009/08/11 13:01:11 smahanka ship $ */
/*#
 * This package contains the course APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Course
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_activity_version >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a course.
 *
 * This business process creates a course record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The category under which the course is to be created must exist.
 *
 * <p><b>Post Success</b><br>
 * The Course record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * If the API cannot create a course, an error is raised.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_activity_id {@rep:casecolumn OTA_ACTIVITY_DEFINITIONS.ACTIVITY_ID}
 * @param p_superseded_by_act_version_id {@rep:casecolumn
 * OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID}
 * @param p_developer_organization_id {@rep:casecolumn
 * HR_ALL_ORGANIZATION_UNITS.ORGANIZATION_ID}
 * @param p_controlling_person_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_ID}
 * @param p_version_name Name of the Course.
 * @param p_comments If the profile 'HR:Use Standard Attachments
 * (PER_ATTACHMENT_USAGE)' is set to 'No', this text serves as HR-specific
 * attachment text.
 * @param p_description Description of the Course.
 * @param p_duration Numeric duration of the Course.
 * @param p_duration_units LOOKUP_CODE : OTA_DURATION_UNITS.
 * @param p_end_date End Date.
 * @param p_intended_audience Intended audience.
 * @param p_language_id The unique identifier of the language of the course.
 * @param p_maximum_attendees The maximum number of attendees.
 * @param p_minimum_attendees The minimum number of attendees.
 * @param p_objectives Objectives.
 * @param p_start_date Start Date.
 * @param p_success_criteria LOOKUP_CODE:ACTIVITY_SUCCESS_CRITERIA.
 * @param p_user_status LOOKUP_CODE:ACTIVITY_USER_STATUS.
 * @param p_vendor_id The unique identifer that identifies the vendor of this
 * course.
 * @param p_actual_cost Actual Cost.
 * @param p_budget_cost Budgeted Cost.
 * @param p_budget_currency_code Currency code of the budget currency for this
 * course.
 * @param p_expenses_allowed Expenses allowed. Possible values: 'Y' /'N'.
 * @param p_professional_credit_type LOOKUP_CODE:PROFESSIONAL_CREDIT_TYPE.
 * @param p_professional_credits Professional Credits.
 * @param p_maximum_internal_attendees Maximum Internal Attendees.
 * @param p_tav_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segment.
 * @param p_tav_information1 Descriptive Flexfield Segment.
 * @param p_tav_information2 Descriptive Flexfield Segment.
 * @param p_tav_information3 Descriptive Flexfield Segment.
 * @param p_tav_information4 Descriptive Flexfield Segment.
 * @param p_tav_information5 Descriptive Flexfield Segment.
 * @param p_tav_information6 Descriptive Flexfield Segment.
 * @param p_tav_information7 Descriptive Flexfield Segment.
 * @param p_tav_information8 Descriptive Flexfield Segment.
 * @param p_tav_information9 Descriptive Flexfield Segment.
 * @param p_tav_information10 Descriptive Flexfield Segment.
 * @param p_tav_information11 Descriptive Flexfield Segment.
 * @param p_tav_information12 Descriptive Flexfield Segment.
 * @param p_tav_information13 Descriptive Flexfield Segment.
 * @param p_tav_information14 Descriptive Flexfield Segment.
 * @param p_tav_information15 Descriptive Flexfield Segment.
 * @param p_tav_information16 Descriptive Flexfield Segment.
 * @param p_tav_information17 Descriptive Flexfield Segment.
 * @param p_tav_information18 Descriptive Flexfield Segment.
 * @param p_tav_information19 Descriptive Flexfield Segment.
 * @param p_tav_information20 Descriptive Flexfield Segment.
 * @param p_inventory_item_id The unique identifier of the inventory item to
 * which this course is attached.
 * @param p_organization_id The unique identifier of the Organization which
 * owns the inventory item to which this course is attached.
 * @param p_rco_id RCO_ID for courses imported from Oracle iLearning.
 * @param p_version_code Version Code.
 * @param p_keywords Keywords by which this course can be identified during a
 * search.
 * @param p_business_group_id The unique identifier of the business group that
 * owns this course.
 * @param p_activity_version_id The Course number generation method determines
 * when the API derives and passes out a course number or when the calling
 * program should pass in a value. When the API call completes, if p_validate
 * is true then the ID is set to the generated identifier. If p_validate is
 * false then it is set to the passed value.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created course. If p_validate is true then
 * the value will be null.
 * @param p_data_source LOOKUP_CODE : OTA_DATA_SOURCE.
 * @param p_competency_update_level Valid values are defined by the 'OTA_COMPETENCY_UPDATE_LEVEL' lookup type.
 * Specifies the mode of competency update. This value overrides the value set at the workflow level.
 * @rep:displayname Create Course
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_COURSE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Create_activity_version
  (
  p_effective_date               in date,
  p_validate                     in boolean   default false ,
  p_activity_id                  in number,
  p_superseded_by_act_version_id in number           default null,
  p_developer_organization_id    in number,
  p_controlling_person_id        in number           default null,
  p_version_name                 in varchar2,
  p_comments                     in varchar2         default null,
  p_description                  in varchar2         default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_end_date                     in date             default null,
  p_intended_audience            in varchar2         default null,
  p_language_id                  in number           default null,
  p_maximum_attendees            in number           default null,
  p_minimum_attendees            in number           default null,
  p_objectives                   in varchar2         default null,
  p_start_date                   in date             default null,
  p_success_criteria             in varchar2         default null,
  p_user_status                  in varchar2         default null,
  p_vendor_id                    in number           default null,
  p_actual_cost                  in number           default null,
  p_budget_cost                  in number           default null,
  p_budget_currency_code         in varchar2         default null,
  p_expenses_allowed             in varchar2         default null,
  p_professional_credit_type     in varchar2         default null,
  p_professional_credits         in number           default null,
  p_maximum_internal_attendees   in number           default null,
  p_tav_information_category     in varchar2         default null,
  p_tav_information1             in varchar2         default null,
  p_tav_information2             in varchar2         default null,
  p_tav_information3             in varchar2         default null,
  p_tav_information4             in varchar2         default null,
  p_tav_information5             in varchar2         default null,
  p_tav_information6             in varchar2         default null,
  p_tav_information7             in varchar2         default null,
  p_tav_information8             in varchar2         default null,
  p_tav_information9             in varchar2         default null,
  p_tav_information10            in varchar2         default null,
  p_tav_information11            in varchar2         default null,
  p_tav_information12            in varchar2         default null,
  p_tav_information13            in varchar2         default null,
  p_tav_information14            in varchar2         default null,
  p_tav_information15            in varchar2         default null,
  p_tav_information16            in varchar2         default null,
  p_tav_information17            in varchar2         default null,
  p_tav_information18            in varchar2         default null,
  p_tav_information19            in varchar2         default null,
  p_tav_information20            in varchar2         default null,
  p_inventory_item_id 		   in number	     default null,
  p_organization_id		   in number    	     default null,
  p_rco_id				   in number	     default null,
  p_version_code                 in varchar2  default null,
  p_keywords                     in varchar2  default null,
  p_business_group_id            in number    default null,
  p_activity_version_id          out nocopy number ,
  p_object_version_number        out nocopy number,
  p_data_source                  in varchar2         default null
  ,p_competency_update_level        in     varchar2  default null,
  p_eres_enabled                 in varchar2 default null

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_activity_version >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a course.
 *
 * This business process updates a course record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Course must exist.
 *
 * <p><b>Post Success</b><br>
 * The Course record is updated.
 *
 * <p><b>Post Failure</b><br>
 * If the API cannot update the course, an error is raised.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_activity_version_id {@rep:casecolumn
 * OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID}
 * @param p_activity_id {@rep:casecolumn OTA_ACTIVITY_DEFINITIONS.ACTIVITY_ID}
 * @param p_superseded_by_act_version_id {@rep:casecolumn
 * OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID}
 * @param p_developer_organization_id {@rep:casecolumn
 * HR_ALL_ORGANIZATION_UNITS.ORGANIZATION_ID}
 * @param p_controlling_person_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_ID}
 * @param p_object_version_number Pass in the current version number of the
 * Course to be updated. When the API completes, if p_validate is false, the
 * number is set to the new version number of the updated course. If p_validate
 * is true, the number remains unchanged.
 * @param p_version_name Name of the Course.
 * @param p_comments If the profile 'HR:Use Standard Attachments
 * (PER_ATTACHMENT_USAGE)' is set to 'No', this text serves as HR-specific
 * attachment text.
 * @param p_description Description of the course.
 * @param p_duration Numeric duration of the course.
 * @param p_duration_units LOOKUP_CODE:OTA_DURATION_UNITS.
 * @param p_end_date End Date.
 * @param p_intended_audience Intended audience.
 * @param p_language_id The unique identifier of the language of the course.
 * @param p_maximum_attendees The maximum number of attendees.
 * @param p_minimum_attendees The minimum number of attendees.
 * @param p_objectives Objectives.
 * @param p_start_date Start Date.
 * @param p_success_criteria LOOKUP_CODE:ACTIVITY_SUCCESS_CRITERIA.
 * @param p_user_status LOOKUP_CODE:ACTIVITY_USER_STATUS.
 * @param p_vendor_id The unique identifer that identifies the vendor of this
 * course.
 * @param p_actual_cost Actual Cost.
 * @param p_budget_cost Budgeted Cost.
 * @param p_budget_currency_code Currency code of the budget currency for this
 * course.
 * @param p_expenses_allowed Expenses Allowed. Possible Values 'Y' /'N'.
 * @param p_professional_credit_type LOOKUP_CODE:PROFESSIONAL_CREDIT_TYPE.
 * @param p_professional_credits Professional Credits.
 * @param p_maximum_internal_attendees Maximum Internal Attendees.
 * @param p_tav_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segment.
 * @param p_tav_information1 Descriptive Flexfield Segment.
 * @param p_tav_information2 Descriptive Flexfield Segment.
 * @param p_tav_information3 Descriptive Flexfield Segment.
 * @param p_tav_information4 Descriptive Flexfield Segment.
 * @param p_tav_information5 Descriptive Flexfield Segment.
 * @param p_tav_information6 Descriptive Flexfield Segment.
 * @param p_tav_information7 Descriptive Flexfield Segment.
 * @param p_tav_information8 Descriptive Flexfield Segment.
 * @param p_tav_information9 Descriptive Flexfield Segment.
 * @param p_tav_information10 Descriptive Flexfield Segment.
 * @param p_tav_information11 Descriptive Flexfield Segment.
 * @param p_tav_information12 Descriptive Flexfield Segment.
 * @param p_tav_information13 Descriptive Flexfield Segment.
 * @param p_tav_information14 Descriptive Flexfield Segment.
 * @param p_tav_information15 Descriptive Flexfield Segment.
 * @param p_tav_information16 Descriptive Flexfield Segment.
 * @param p_tav_information17 Descriptive Flexfield Segment.
 * @param p_tav_information18 Descriptive Flexfield Segment.
 * @param p_tav_information19 Descriptive Flexfield Segment.
 * @param p_tav_information20 Descriptive Flexfield Segment.
 * @param p_inventory_item_id The unique identifier of the inventory item to
 * which this course is attached.
 * @param p_organization_id The unique identifier of the Organization which
 * owns the inventory item to which this course is attached.
 * @param p_rco_id RCO_ID for courses imported from Oracle iLearning.
 * @param p_version_code Version Code.
 * @param p_keywords Keywords through which this Course can be identified
 * during search.
 * @param p_business_group_id The unique identifier of the business group that
 * owns this course.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_data_source LOOKUP_CODE:OTA_DATA_SOURCE.
 * @param p_competency_update_level Valid values are defined by the 'OTA_COMPETENCY_UPDATE_LEVEL' lookup type.
 * Specifies the mode of competency update. This value overrides the value set at the workflow level.
 * @rep:displayname Update Course
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_COURSE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_activity_version
  (
  p_effective_date               in date  ,
  p_activity_version_id          in number,
  p_activity_id                  in number           default hr_api.g_number,
  p_superseded_by_act_version_id in number           default hr_api.g_number,
  p_developer_organization_id    in number           default hr_api.g_number,
  p_controlling_person_id        in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_version_name                 in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_end_date                     in date             default hr_api.g_date,
  p_intended_audience            in varchar2         default hr_api.g_varchar2,
  p_language_id                  in number           default hr_api.g_number,
  p_maximum_attendees            in number           default hr_api.g_number,
  p_minimum_attendees            in number           default hr_api.g_number,
  p_objectives                   in varchar2         default hr_api.g_varchar2,
  p_start_date                   in date             default hr_api.g_date,
  p_success_criteria             in varchar2         default hr_api.g_varchar2,
  p_user_status                  in varchar2         default hr_api.g_varchar2,
  p_vendor_id                    in number           default hr_api.g_number,
  p_actual_cost                  in number           default hr_api.g_number,
  p_budget_cost                  in number           default hr_api.g_number,
  p_budget_currency_code         in varchar2         default hr_api.g_varchar2,
  p_expenses_allowed             in varchar2         default hr_api.g_varchar2,
  p_professional_credit_type     in varchar2         default hr_api.g_varchar2,
  p_professional_credits         in number           default hr_api.g_number,
  p_maximum_internal_attendees   in number           default hr_api.g_number,
  p_tav_information_category     in varchar2         default hr_api.g_varchar2,
  p_tav_information1             in varchar2         default hr_api.g_varchar2,
  p_tav_information2             in varchar2         default hr_api.g_varchar2,
  p_tav_information3             in varchar2         default hr_api.g_varchar2,
  p_tav_information4             in varchar2         default hr_api.g_varchar2,
  p_tav_information5             in varchar2         default hr_api.g_varchar2,
  p_tav_information6             in varchar2         default hr_api.g_varchar2,
  p_tav_information7             in varchar2         default hr_api.g_varchar2,
  p_tav_information8             in varchar2         default hr_api.g_varchar2,
  p_tav_information9             in varchar2         default hr_api.g_varchar2,
  p_tav_information10            in varchar2         default hr_api.g_varchar2,
  p_tav_information11            in varchar2         default hr_api.g_varchar2,
  p_tav_information12            in varchar2         default hr_api.g_varchar2,
  p_tav_information13            in varchar2         default hr_api.g_varchar2,
  p_tav_information14            in varchar2         default hr_api.g_varchar2,
  p_tav_information15            in varchar2         default hr_api.g_varchar2,
  p_tav_information16            in varchar2         default hr_api.g_varchar2,
  p_tav_information17            in varchar2         default hr_api.g_varchar2,
  p_tav_information18            in varchar2         default hr_api.g_varchar2,
  p_tav_information19            in varchar2         default hr_api.g_varchar2,
  p_tav_information20            in varchar2         default hr_api.g_varchar2,
  p_inventory_item_id 		   in number	     default hr_api.g_number,
  p_organization_id		   in number    	     default hr_api.g_number,
  p_rco_id			   in number    	     default hr_api.g_number,
  p_version_code                 in varchar2         default hr_api.g_varchar2,
  p_keywords                     in varchar2         default hr_api.g_varchar2,
  p_business_group_id		   in number    	     default hr_api.g_number,
  p_validate                     in boolean      default false,
  p_data_source                  in varchar2         default hr_api.g_varchar2
  ,p_competency_update_level        in     varchar2  default hr_api.g_varchar2,
  p_eres_enabled                 in varchar2 default hr_api.g_varchar2

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_activity_version >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a course record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Course must exist.
 *
 * <p><b>Post Success</b><br>
 * The Course record is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * If the API cannot delete the record, an error is raised.
 * @param p_activity_version_id The unique identifier of the course to be
 * deleted.
 * @param p_object_version_number Pass in the current version number of the
 * Course to be deleted. This object version number must match the object
 * version number for the record in the database.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Course
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_COURSE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_activity_version
  (p_activity_version_id           in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );
end ota_activity_version_api;

/
