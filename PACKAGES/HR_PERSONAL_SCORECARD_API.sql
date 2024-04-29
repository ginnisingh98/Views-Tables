--------------------------------------------------------
--  DDL for Package HR_PERSONAL_SCORECARD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSONAL_SCORECARD_API" AUTHID CURRENT_USER as
/* $Header: pepmsapi.pkh 120.5 2006/10/24 15:51:09 tpapired noship $ */
/*#
 * This package contains personal scorecard APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Personal Scorecard
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_scorecard >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a personal scorecard for an HR assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The performance management plan and HR assignment must already exist.
 *
 * <p><b>Post Success</b><br>
 * The personal scorecard will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The personal scorecard will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_scorecard_name Name of the scorecard.
 * @param p_assignment_id Identifies the assignment for which this scorecard belongs.
 * @param p_start_date Start date of this scorecard.
 * @param p_end_date End date of this scorecard.
 * @param p_plan_id Identifies the performance plan that holds this scorecard.
 * @param p_creator_type Indicates the type of process that created this scorecard
 * whether an automatic process or manually created.
 * @param p_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
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
 * @param p_scorecard_id If p_validate is false, then this uniquely
 * identifies the personal scorecard created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created personal scorecard. If p_validate is true,
 * then the value will be null.
 * @param p_status_code Indicates the status of the personal scorecard, valid values
 * are identified by the lookup type HR_WPM_SCORECARD_STATUS
 * @param p_duplicate_name_warning If set to true, then the assignment already
 * has a scorecard with this name.
 * @rep:displayname Create Personal Scorecard
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_SCORECARD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure create_scorecard
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_scorecard_name                in     varchar2
  ,p_assignment_id                 in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_plan_id                       in     number   default null
  ,p_creator_type                  in     varchar2 default 'MANUAL'
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
  ,p_scorecard_id                     out nocopy   number
  ,p_object_version_number            out nocopy   number
  ,p_status_code                   in     varchar2
  ,p_duplicate_name_warning           out nocopy   boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_scorecard >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a personal scorecard for an HR assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal scorecard must exist.
 *
 * <p><b>Post Success</b><br>
 * The personal scorecard will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The personal scorecard will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_scorecard_id Identifies the personal scorecard to be modified.
 * @param p_object_version_number Pass in the current version number of
 * the personal scorecard to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated personal
 * scorecard. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_scorecard_name Name of the scorecard..
 * @param p_start_date Start date of this scorecard.
 * @param p_end_date End date of this scorecard.
 * @param p_plan_id Identifies the performance plan that holds this scorecard.
 * @param p_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
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
 * @param p_status_code Indicates the status of the personal scorecard, valid values
 * are identified by the lookup type HR_WPM_SCORECARD_STATUS
 * @param p_duplicate_name_warning If set to true, then the assignment already
 * has a scorecard with this name.
 * @rep:displayname Update Personal Scorecard
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_SCORECARD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure update_scorecard
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in out nocopy   number
  ,p_scorecard_name                in     varchar2 default hr_api.g_varchar2
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_plan_id                       in     number   default hr_api.g_number
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
  ,p_status_code                   in     varchar2 default hr_api.g_varchar2
  ,p_duplicate_name_warning           out nocopy   boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_scorecard_status >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the status of a personal scorecard.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal scorecard must exist.
 *
 * <p><b>Post Success</b><br>
 * The personal scorecard's status will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The personal scorecard's status will not be updated and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_scorecard_id Identifies the personal scorecard to be modified.
 * @param p_object_version_number Pass in the current version number of
 * the personal scorecard to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated personal
 * scorecard. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_status_code Indicates the status of the personal scorecard, valid values
 * are identified by the lookup type HR_WPM_SCORECARD_STATUS.
 * @rep:displayname Update Personal Scorecard Status
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_SCORECARD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure update_scorecard_status
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in out nocopy   number
  ,p_status_code                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_scorecard >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a personal scorecard for an HR assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal scorecard must exist.
 *
 * <p><b>Post Success</b><br>
 * The personal scorecard will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The personal scorecard will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_scorecard_id Identifies the personal scorecard to be deleted.
 * @param p_object_version_number Current version number of the personal
 * scorecard to be deleted.
 * @param p_created_by_plan_warning If set to true, then identifies that this
 * scorecard was created automatically during plan publication.
 * @rep:displayname Delete Personal Scorecard
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_SCORECARD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_scorecard
  (p_validate                      in     boolean  default false
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in     number
  ,p_created_by_plan_warning          out nocopy   boolean
  );
--
end hr_personal_scorecard_api;

 

/
