--------------------------------------------------------
--  DDL for Package OTA_OFFERING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OFFERING_API" AUTHID CURRENT_USER as
/* $Header: otoffapi.pkh 120.4.12010000.2 2008/08/05 11:45:04 ubhat ship $ */
/*#
 * This package contains the offering APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Offering
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_offering >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an offering.
 *
 * This API enables the user to create an offering and enter details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The parent course and delivery mode must already exist before an offering
 * can be created. The parent course and delivery mode must exist in the same
 * business group as the business group of the offering, and must be active
 * within the offering dates being entered.
 *
 * <p><b>Post Success</b><br>
 * When the offering has been successfully inserted, the following OUT
 * parameters are set.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create an offering, and raises an error.
 * @param p_validate If true, then only validation is performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database is modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the offering.
 * @param p_name The name of the offering. This must be unique within a course.
 * @param p_start_date The date on which the offering starts.
 * @param p_activity_version_id Foreign key to OTA_ACTIVITY_VERSION_ID. This
 * column denotes the parent course for the offering.
 * @param p_end_date The date on which the offering ends.
 * @param p_owner_id Foreign key to PER_ALL_PEOPLE_F.
 * @param p_delivery_mode_id Foreign key to OTA_CATEGORY_USAGES. This denotes
 * the category usage of type DM, and is the delivery mode for the offering.
 * @param p_language_id Ignore this parameter and populate p_language_code
 * @param p_duration The duration of the class measured in units. The unit of
 * measure is specified in column DURATION_UNITS.
 * @param p_duration_units The units in which the duration is measured. Valid
 * values are defined by the 'OTA_FREQUENCY' lookup type.
 * @param p_learning_object_id Foreign key to OTA_LEARNING_OBJECTS. This is
 * mandatory for offerings with an online delivery mode.
 * @param p_player_toolbar_flag This flag indicates whether or not the toolbar
 * appears in the player window for an online offering.
 * @param p_player_toolbar_bitset This column indicates whether or not the
 * following buttons appears in the player window: toolbar, next, outline,
 * exit, previous.
 * @param p_player_new_window_flag This indicates whether or not the player
 * opens in a new browser window.
 * @param p_maximum_attendees The maximum number of learners allowed to attend.
 * @param p_maximum_internal_attendees The maximum number of internal learners
 * allowed to attend.
 * @param p_minimum_attendees The minimum number of learners required for this
 * offering.
 * @param p_actual_cost The actual cost of the offering.
 * @param p_budget_cost The budgeted cost of the offering.
 * @param p_budget_currency_code The actual cost of the offering in the
 * budgeted currency.
 * @param p_price_basis Price basis of the offering: Student, Customer, or No
 * Charge. The value selected is defaulted in classes under this offering.
 * Valid values are defined by the 'EVENT_PRICE_BASIS' lookup type.
 * @param p_currency_code The currency in which the standard price is defined.
 * @param p_standard_price The standard price per enrollment for this offering.
 * A standard price can be per student (learner), per customer, or per order.
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
 * @param p_offering_id If p_validate is false, then this ID uniquely
 * identifies the offering being created. If p_validate is true, then it is set
 * to null.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created offering. If p_validate is true,
 * then the value is null.
 * @param p_data_source Source of the offering being created. Valid values are
 * defined by the 'OTA_OBJECT_DATA_SOURCE' lookup type.
 * @param p_vendor_id Foreign key to PO_VENDORS. The vendor hosting the
 * offering.
 * @param p_description Description of the offering.
 * @param p_competency_update_level Valid values are defined by the 'OTA_COMPETENCY_UPDATE_LEVEL' lookup type.
 * Specifies the mode of competency update. This value overrides the value set at the workflow level.
 * @param p_language_code The language in which offering is taught, use
 *  OTA_NATURAL_LANGUAGES_V to pick the language code. The parameter
 *  language_id can be ignored
 * @rep:displayname Create Offering
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_OFFERING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Create_offering
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_name                          in     varchar2
  ,p_start_date                     in     date
  ,p_activity_version_id            in     number   default null
  ,p_end_date                       in     date     default null
  ,p_owner_id                       in     number   default null
  ,p_delivery_mode_id               in     number   default null
  ,p_language_id                    in     number   default null
  ,p_duration                       in     number   default null
  ,p_duration_units                 in     varchar2 default null
  ,p_learning_object_id             in     number   default null
  ,p_player_toolbar_flag            in     varchar2 default null
  ,p_player_toolbar_bitset          in     number   default null
  ,p_player_new_window_flag         in     varchar2 default null
  ,p_maximum_attendees              in     number   default null
  ,p_maximum_internal_attendees     in     number   default null
  ,p_minimum_attendees              in     number   default null
  ,p_actual_cost                    in     number   default null
  ,p_budget_cost                    in     number   default null
  ,p_budget_currency_code           in     varchar2 default null
  ,p_price_basis                    in     varchar2 default null
  ,p_currency_code                  in     varchar2 default null
  ,p_standard_price                 in     number   default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_offering_id                       out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_data_source                    in     varchar2 default null
  ,p_vendor_id                      in     number default null
  ,p_description		    in     varchar2  default null
  ,p_competency_update_level      in     varchar2  default null
  ,p_language_code                in     varchar2  default null   -- 2733966
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_offering >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an offering.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The offering that is being updated must exist.
 *
 * <p><b>Post Success</b><br>
 * The offering is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the offering and raises an error.
 * @param p_validate If true, then only validation is performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database is modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_offering_id This uniquely identifies the offering being updated.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the updated offering. If p_validate is true,
 * then the value is null.
 * @param p_business_group_id The business group owning the offering.
 * @param p_name The name of the offering. This must be unique within a course.
 * @param p_start_date The date on which the offering starts.
 * @param p_activity_version_id Foreign key to OTA_ACTIVITY_VERSION_ID. This
 * column denotes the parent course for the offering.
 * @param p_end_date The date on which the offering ends.
 * @param p_owner_id Foreign key to PER_ALL_PEOPLE_F.
 * @param p_delivery_mode_id Foreign key to OTA_CATEGORY_USAGES. This denotes
 * the category usage of type DM, and is the delivery mode for the offering.
 * @param p_language_id Ignore this parameter and populate p_language_code
 * @param p_duration The duration of the class measured in units. The unit of
 * measure is specified in column DURATION_UNITS.
 * @param p_duration_units The units in which the duration is measured. Valid
 * values are defined by the 'OTA_FREQUENCY' lookup type.
 * @param p_learning_object_id Foreign key to OTA_LEARNING_OBJECTS. This is
 * mandatory for offerings with an online delivery mode.
 * @param p_player_toolbar_flag This flag indicates whether or not the toolbar
 * appears in the player window for an online offering.
 * @param p_player_toolbar_bitset This column indicates whether or not the
 * following buttons appear in the player window: toolbar, next, outline, exit,
 * previous.
 * @param p_player_new_window_flag This indicates whether or not the player
 * opens in a new browser window.
 * @param p_maximum_attendees The maximum number of learners allowed to attend.
 * @param p_maximum_internal_attendees The maximum number of internal learners
 * allowed to attend.
 * @param p_minimum_attendees The minimum number of learners required for this
 * offering.
 * @param p_actual_cost The actual cost of the offering.
 * @param p_budget_cost The budgeted cost of the offering.
 * @param p_budget_currency_code The actual cost of the offering in the
 * budgeted currency.
 * @param p_price_basis Price basis of the offering: Student, Customer, or No
 * Charge. The value selected is defaulted in classes under this offering.
 * Valid values are defined by the 'EVENT_PRICE_BASIS' lookup type.
 * @param p_currency_code The currency in which the standard price is defined.
 * @param p_standard_price The standard price per enrollment for this offering.
 * A standard price can be per student (learner), per customer, or per order.
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
 * @param p_data_source Source of the offering being created. Valid values are
 * defined by the 'OTA_OBJECT_DATA_SOURCE' lookup type.
 * @param p_vendor_id Foreign key to PO_VENDORS. The vendor hosting the
 * offering.
 * @param p_description Description of the offering.
 * @param p_competency_update_level Valid values are defined by the 'OTA_COMPETENCY_UPDATE_LEVEL' lookup type.
 * Specifies the mode of competency update. This value overrides the value set at the workflow level.
 * @param p_language_code The language in which offering is taught, use
 * OTA_NATURAL_LANGUAGES_V to pick the language code. The parameter
 * language_id can be ignored
 * @rep:displayname Update Offering
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_OFFERING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_offering
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_offering_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_owner_id                     in     number    default hr_api.g_number
  ,p_delivery_mode_id             in     number    default hr_api.g_number
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_learning_object_id           in     number    default hr_api.g_number
  ,p_player_toolbar_flag          in     varchar2  default hr_api.g_varchar2
  ,p_player_toolbar_bitset        in     number    default hr_api.g_number
  ,p_player_new_window_flag       in     varchar2  default hr_api.g_varchar2
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_price_basis                  in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_standard_price               in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_description		  in     varchar2  default hr_api.g_varchar2
 ,p_competency_update_level      in     varchar2  default hr_api.g_varchar2
 ,p_language_code                in     varchar2  default hr_api.g_varchar2   -- 2733966
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_offering >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API enables the user to delete an offering.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The offering must exist and should not have classes under it.
 *
 * <p><b>Post Success</b><br>
 * The offering is successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the offering, and raises an error.
 * @param p_validate If true, then only validation is performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database is modified.
 * @param p_offering_id This uniquely identifies the offering being deleted.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the offering being deleted. If p_validate is
 * true, then the value is null.
 * @rep:displayname Delete Offering
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_OFFERING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_offering
  (p_validate                      in     boolean  default false
  ,p_offering_id                   in     number
  ,p_object_version_number         in     number
  );

end ota_offering_api;

/
