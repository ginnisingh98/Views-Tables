--------------------------------------------------------
--  DDL for Package OTA_LP_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_ENROLLMENT_API" AUTHID CURRENT_USER as
/* $Header: otlpeapi.pkh 120.7 2006/07/12 11:14:59 niarora noship $ */
/*#
 * This package contains learning path enrollment APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Learning Path Enrollment
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_lp_enrollment >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the learning path enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Learning Path, Learning Path Section and Learning Path Member records
 * must exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path enrollment record is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The learning path enrollment record is not created and an error is raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_learning_path_id The unique identifier of the learning path for
 * which enrollment is being done.
 * @param p_person_id Identifies the person for whom you create the learning
 * path enrollment record.
 * @param p_contact_id Identifies the external contact for whom you create the
 * learning path enrollment record.
 * @param p_path_status_code Status of the learning path enrollment. Valid
 * values are defined by 'OTA_LEARNING_PATH_STATUS' lookup type.
 * @param p_enrollment_source_code Source of the learning path enrollment.
 * Valid values are defined by 'OTA_TRAINING_PLAN_SOURCE' lookup type.
 * @param p_no_of_mandatory_courses Number of mandatory courses in the learning
 * path.
 * @param p_no_of_completed_courses Number of courses in the learning path,
 * completed by the learner.
 * @param p_completion_target_date Date before which the learner has to
 * complete the learning path.
 * @param p_completion_date Date on which the learner has completed the
 * learning path.
 * @param p_creator_person_id Identifies the person who has created the
 * learning path enrollment for the learner.
 * @param p_business_group_id The unique identifer of the business group to
 * which the learning path belongs.
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
 * @param p_lp_enrollment_id Identifies the learning path enrollment record.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created learning path enrollment. If p_validate is
 * true, then the value will be null.
 * @param p_is_history_flag Determines whether the learning path enrollment
 * record should be moved to history once completed. Valid values are Y
 * and N. Default value is N.
 * @rep:displayname Create Learning Path Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LP_SUBSCRIPTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_lp_enrollment
  (
  p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_learning_path_id             in number,
  p_person_id                    in number           default null,
  p_contact_id                   in number           default null,
  p_path_status_code             in varchar2,
  p_enrollment_source_code       in varchar2,
  p_no_of_mandatory_courses      in number           default null,
  p_no_of_completed_courses      in number           default null,
  p_completion_target_date       in date             default null,
  p_completion_date              in date             default null,
  p_creator_person_id            in number           default null,
  p_business_group_id            in number,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_attribute21                  in varchar2         default null,
  p_attribute22                  in varchar2         default null,
  p_attribute23                  in varchar2         default null,
  p_attribute24                  in varchar2         default null,
  p_attribute25                  in varchar2         default null,
  p_attribute26                  in varchar2         default null,
  p_attribute27                  in varchar2         default null,
  p_attribute28                  in varchar2         default null,
  p_attribute29                  in varchar2         default null,
  p_attribute30                  in varchar2         default null,
  p_IS_HISTORY_FLAG              in varchar2         default 'N',
  p_lp_enrollment_id             out nocopy number,
  p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_lp_enrollment >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the learning path enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path enrollment record with the given object version number
 * must exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path enrollment record is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The learning path enrollment record is not updated and an error is raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_lp_enrollment_id Identifies the learning path enrollment record
 * that is to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * learning path enrollment to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated learning path
 * enrollment. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_person_id Identifies the person for whom you create the learning
 * path enrollment record.
 * @param p_contact_id Identifies the external contact for whom you create the
 * learning path enrollment record.
 * @param p_path_status_code Status of the learning path enrollment. Valid
 * values are defined by 'OTA_LEARNING_PATH_STATUS' lookup type.
 * @param p_enrollment_source_code Source of the learning path enrollment.
 * Valid values are defined by 'OTA_TRAINING_PLAN_SOURCE' lookup type.
 * @param p_no_of_mandatory_courses Number of mandatory courses in the learning
 * path.
 * @param p_no_of_completed_courses Number of courses in the learning path,
 * completed by the learner.
 * @param p_completion_target_date Date before which the learner has to
 * complete the learning path.
 * @param p_completion_date Date on which the learner has completed the
 * learning path.
 * @param p_creator_person_id Identifies the person who has created the
 * learning path enrollment for the learner.
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
 * @param p_business_group_id The unique identifer of the business group to
 * which the learning path belongs.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_is_history_flag Determines whether the learning path enrollment
 * record should be moved to history once completed. Valid values are Y
 * and N. Default value is N.
 * @rep:displayname Update Learning Path Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LP_SUBSCRIPTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_lp_enrollment
  (
  p_effective_date               in date,
  p_lp_enrollment_id             in number,
  p_object_version_number        in out nocopy number,
  p_person_id                    in number           default hr_api.g_number,
  p_contact_id                   in number           default hr_api.g_number,
  p_path_status_code             in varchar2         default hr_api.g_varchar2,
  p_enrollment_source_code       in varchar2         default hr_api.g_varchar2,
  p_no_of_mandatory_courses      in number           default hr_api.g_number,
  p_no_of_completed_courses      in number           default hr_api.g_number,
  p_completion_target_date       in date             default hr_api.g_date,
  p_completion_date               in date             default hr_api.g_date,
  p_creator_person_id            in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_is_history_flag              in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_lp_enrollment >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the learning path enrollment record.
 *
 * This business process allows the user to delete a Learning Path Enrollment
 * within the Learning Path functionality.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * All the learning path component enrollment records must be deleted before
 * deleting the learning path enrollment.
 *
 * <p><b>Post Success</b><br>
 * The learning path enrollment record is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The learning path enrollment record is not deleted and an error is raised.
 *
 * @param p_lp_enrollment_id Identifies the learning path enrollment record
 * that is to be deleted.
 * @param p_object_version_number Current version number of the learning path
 * enrollment to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Learning Path Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LP_SUBSCRIPTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_lp_enrollment
  (p_lp_enrollment_id           in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< subscribe_to_learning_path >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Learning Path Subscription.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Learning Path should exist.
 *
 * <p><b>Post Success</b><br>
 * Learning Path Enrollment and Learning Path Member Enrollment records are created.
 *
 * <p><b>Post Failure</b><br>
 * No Learning Path enrollment records are created, and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_learning_path_id The unique identifier of the learning path being subscribed to.
 * @param p_person_id Identifies the person subscribing to the learning path.
 * @param p_contact_id Identifies the external contact subscribing to the learning path.
 * @param p_enrollment_source_code Source of the learning path enrollment. Valid values are
 * defined by the 'OTA_TRAINING_PLAN_SOURCE' lookup type.
 * @param p_business_group_id The business group owning the section record and the Learning Path.
 * @param p_creator_person_id Identifies the person who has created the learning path subscription for the learner.
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
 * @param p_lp_enrollment_id Identifies the learning path enrollment record.
 * @param p_path_status_code Status of the learning path subscription. Valid values
 * are defined by the 'OTA_LEARNING_PATH_STATUS' lookup type
 * @rep:displayname Learning Path Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LP_SUBSCRIPTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure subscribe_to_learning_path
  (p_validate in boolean default false
  ,p_learning_path_id IN NUMBER
  ,p_person_id IN NUMBER default null
  ,p_contact_id IN NUMBER default null
  ,p_enrollment_source_code IN VARCHAR2
   ,p_business_group_id IN NUMBER
   ,p_creator_person_id IN NUMBER
      ,p_attribute_category IN VARCHAR2 default NULL
       ,p_attribute1                   IN VARCHAR2 default NULL
    ,p_attribute2                   IN VARCHAR2 default NULL
    ,p_attribute3                   IN VARCHAR2 default NULL
    ,p_attribute4                  IN VARCHAR2 default NULL
    ,p_attribute5                  IN VARCHAR2 default NULL
    ,p_attribute6                   IN VARCHAR2 default NULL
    ,p_attribute7                  IN VARCHAR2 default NULL
    ,p_attribute8                 IN VARCHAR2 default NULL
    ,p_attribute9                 IN VARCHAR2 default NULL
    ,p_attribute10                 IN VARCHAR2 default NULL
    ,p_attribute11              IN VARCHAR2 default NULL
    ,p_attribute12               IN VARCHAR2 default NULL
    ,p_attribute13               IN VARCHAR2 default NULL
    ,p_attribute14                IN VARCHAR2 default NULL
    ,p_attribute15                IN VARCHAR2 default NULL
    ,p_attribute16                  IN VARCHAR2 default NULL
    ,p_attribute17                 IN VARCHAR2 default NULL
    ,p_attribute18                 IN VARCHAR2 default NULL
    ,p_attribute19                IN VARCHAR2 default NULL
    ,p_attribute20                 IN VARCHAR2 default NULL
    ,p_attribute21                 IN VARCHAR2 default NULL
    ,p_attribute22                IN VARCHAR2 default NULL
    ,p_attribute23               IN VARCHAR2 default NULL
    ,p_attribute24                 IN VARCHAR2 default NULL
    ,p_attribute25              IN VARCHAR2 default NULL
    ,p_attribute26                 IN VARCHAR2 default NULL
    ,p_attribute27                  IN VARCHAR2 default NULL
    ,p_attribute28                  IN VARCHAR2 default NULL
    ,p_attribute29                 IN VARCHAR2 default NULL
    ,p_attribute30                  IN VARCHAR2 default NULL
  ,p_lp_enrollment_id OUT NOCOPY number
  ,p_path_status_code OUT NOCOPY VARCHAR2
  );
end ota_lp_enrollment_api;

 

/
