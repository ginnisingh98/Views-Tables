--------------------------------------------------------
--  DDL for Package OTA_TPC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPC_API" AUTHID CURRENT_USER as
/* $Header: ottpcapi.pkh 120.1 2005/10/02 02:08:30 aroussel $ */
/*#
 * This package contains the Organization Training Plan Cost APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Training Plan Cost
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_cost >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Organization Training Plan cost.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The training plan and measurement type must exist
 *
 * <p><b>Post Success</b><br>
 * The cost row is successfully inserted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a cost record, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the cost record.
 * @param p_tp_measurement_type_id The unique identifier for the measurement
 * type, identifying the type of cost.
 * @param p_training_plan_id The training plan against which the cost record is
 * stored.
 * @param p_amount The amount of the cost
 * @param p_booking_id If this is a learner cost, the learner booking
 * identifier.
 * @param p_event_id If this is a class cost, the unique class identifier.
 * @param p_currency_code The currency for money type measure values. Valid
 * values exist in FND_CURRENCIES.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_tp_cost_information1 Descriptive Flexfield
 * @param p_tp_cost_information2 Descriptive Flexfield
 * @param p_tp_cost_information3 Descriptive Flexfield
 * @param p_tp_cost_information4 Descriptive Flexfield
 * @param p_tp_cost_information5 Descriptive Flexfield
 * @param p_tp_cost_information6 Descriptive Flexfield
 * @param p_tp_cost_information7 Descriptive Flexfield
 * @param p_tp_cost_information8 Descriptive Flexfield
 * @param p_tp_cost_information9 Descriptive Flexfield
 * @param p_tp_cost_information10 Descriptive Flexfield
 * @param p_tp_cost_information11 Descriptive Flexfield
 * @param p_tp_cost_information12 Descriptive Flexfield
 * @param p_tp_cost_information13 Descriptive Flexfield
 * @param p_tp_cost_information14 Descriptive Flexfield
 * @param p_tp_cost_information15 Descriptive Flexfield
 * @param p_tp_cost_information16 Descriptive Flexfield
 * @param p_tp_cost_information17 Descriptive Flexfield
 * @param p_tp_cost_information18 Descriptive Flexfield
 * @param p_tp_cost_information19 Descriptive Flexfield
 * @param p_tp_cost_information20 Descriptive Flexfield
 * @param p_tp_cost_information21 Descriptive Flexfield
 * @param p_tp_cost_information22 Descriptive Flexfield
 * @param p_tp_cost_information23 Descriptive Flexfield
 * @param p_tp_cost_information24 Descriptive Flexfield
 * @param p_tp_cost_information25 Descriptive Flexfield
 * @param p_tp_cost_information26 Descriptive Flexfield
 * @param p_tp_cost_information27 Descriptive Flexfield
 * @param p_tp_cost_information28 Descriptive Flexfield
 * @param p_tp_cost_information29 Descriptive Flexfield
 * @param p_tp_cost_information30 Descriptive Flexfield
 * @param p_training_plan_cost_id If p_validate is false, then the ID is set to
 * the unique identifier of the created training plan cost. If p_validate is
 * true, then the value is null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created training plan cost. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Organization Training Plan Cost
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cost
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_tp_measurement_type_id        in     number
  ,p_training_plan_id              in     number
  ,p_amount                        in     number
  ,p_booking_id                    in     number   default null
  ,p_event_id                      in     number   default null
  ,p_currency_code                 in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_information_category          in     varchar2 default null
  ,p_tp_cost_information1          in     varchar2 default null
  ,p_tp_cost_information2          in     varchar2 default null
  ,p_tp_cost_information3          in     varchar2 default null
  ,p_tp_cost_information4          in     varchar2 default null
  ,p_tp_cost_information5          in     varchar2 default null
  ,p_tp_cost_information6          in     varchar2 default null
  ,p_tp_cost_information7          in     varchar2 default null
  ,p_tp_cost_information8          in     varchar2 default null
  ,p_tp_cost_information9          in     varchar2 default null
  ,p_tp_cost_information10         in     varchar2 default null
  ,p_tp_cost_information11         in     varchar2 default null
  ,p_tp_cost_information12         in     varchar2 default null
  ,p_tp_cost_information13         in     varchar2 default null
  ,p_tp_cost_information14         in     varchar2 default null
  ,p_tp_cost_information15         in     varchar2 default null
  ,p_tp_cost_information16         in     varchar2 default null
  ,p_tp_cost_information17         in     varchar2 default null
  ,p_tp_cost_information18         in     varchar2 default null
  ,p_tp_cost_information19         in     varchar2 default null
  ,p_tp_cost_information20         in     varchar2 default null
  ,p_tp_cost_information21         in     varchar2 default null
  ,p_tp_cost_information22         in     varchar2 default null
  ,p_tp_cost_information23         in     varchar2 default null
  ,p_tp_cost_information24         in     varchar2 default null
  ,p_tp_cost_information25         in     varchar2 default null
  ,p_tp_cost_information26         in     varchar2 default null
  ,p_tp_cost_information27         in     varchar2 default null
  ,p_tp_cost_information28         in     varchar2 default null
  ,p_tp_cost_information29         in     varchar2 default null
  ,p_tp_cost_information30         in     varchar2 default null
  ,p_training_plan_cost_id            out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_cost >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a cost record that records a cost value against a training
 * plan.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The cost record to be updated must exist.
 *
 * <p><b>Post Success</b><br>
 * The cost record is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the cost record, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_training_plan_cost_id The unique identifier of the cost record to
 * be updated
 * @param p_object_version_number Pass in the current version number of the
 * training plan cost to be updated. When the API completes, if p_validate is
 * false, will be set to the new version number of the updated training plan
 * cost. If p_validate is true will be set to the same value which is passed
 * in.
 * @param p_amount The amount of the cost.
 * @param p_currency_code The currency for money type measure values. Valid
 * values exist in FND_CURRENCIES.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_tp_cost_information1 Descriptive Flexfield
 * @param p_tp_cost_information2 Descriptive Flexfield
 * @param p_tp_cost_information3 Descriptive Flexfield
 * @param p_tp_cost_information4 Descriptive Flexfield
 * @param p_tp_cost_information5 Descriptive Flexfield
 * @param p_tp_cost_information6 Descriptive Flexfield
 * @param p_tp_cost_information7 Descriptive Flexfield
 * @param p_tp_cost_information8 Descriptive Flexfield
 * @param p_tp_cost_information9 Descriptive Flexfield
 * @param p_tp_cost_information10 Descriptive Flexfield
 * @param p_tp_cost_information11 Descriptive Flexfield
 * @param p_tp_cost_information12 Descriptive Flexfield
 * @param p_tp_cost_information13 Descriptive Flexfield
 * @param p_tp_cost_information14 Descriptive Flexfield
 * @param p_tp_cost_information15 Descriptive Flexfield
 * @param p_tp_cost_information16 Descriptive Flexfield
 * @param p_tp_cost_information17 Descriptive Flexfield
 * @param p_tp_cost_information18 Descriptive Flexfield
 * @param p_tp_cost_information19 Descriptive Flexfield
 * @param p_tp_cost_information20 Descriptive Flexfield
 * @param p_tp_cost_information21 Descriptive Flexfield
 * @param p_tp_cost_information22 Descriptive Flexfield
 * @param p_tp_cost_information23 Descriptive Flexfield
 * @param p_tp_cost_information24 Descriptive Flexfield
 * @param p_tp_cost_information25 Descriptive Flexfield
 * @param p_tp_cost_information26 Descriptive Flexfield
 * @param p_tp_cost_information27 Descriptive Flexfield
 * @param p_tp_cost_information28 Descriptive Flexfield
 * @param p_tp_cost_information29 Descriptive Flexfield
 * @param p_tp_cost_information30 Descriptive Flexfield
 * @rep:displayname Update Organization Training Plan Cost
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_cost
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_training_plan_cost_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_amount                        in     number   default hr_api.g_number
  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information1          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information2          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information3          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information4          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information5          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information6          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information7          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information8          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information9          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information10         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information11         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information12         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information13         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information14         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information15         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information16         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information17         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information18         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information19         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information20         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information21         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information22         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information23         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information24         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information25         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information26         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information27         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information28         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information29         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information30         in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_cost >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a cost record used for recording cost values within an OTA
 * organization training plan.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The cost record to be deleted must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The cost record is successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the cost record, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_training_plan_cost_id The unique identifier for the cost record to
 * be deleted
 * @param p_object_version_number Current version number of the cost to be
 * deleted.
 * @rep:displayname Delete Organization Training Plan Cost
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_cost
  (p_validate                      in     boolean  default false
  ,p_training_plan_cost_id         in     number
  ,p_object_version_number         in     number
  );
end ota_tpc_api;

 

/
