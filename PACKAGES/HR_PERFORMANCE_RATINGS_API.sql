--------------------------------------------------------
--  DDL for Package HR_PERFORMANCE_RATINGS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERFORMANCE_RATINGS_API" AUTHID CURRENT_USER as
/* $Header: peprtapi.pkh 120.2 2006/02/13 14:12:27 vbala noship $ */
/*#
 * This package contains performance ratings APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Performance Rating
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_performance_rating >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates performance rating.
 *
 * A performance rating is a single evaluation of an objective within an
 * appraisal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An objective and an appraisal must exist.
 *
 * <p><b>Post Success</b><br>
 * Performance rating is created.
 *
 * <p><b>Post Failure</b><br>
 * Performance rating is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_appraisal_id Identifies the appraisal record.
 * @param p_person_id Identifies the person record.
 * @param p_objective_id Identifies the objective.
 * @param p_performance_level_id Identifier of the performance rating level.
 * @param p_comments Comment text.
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
 * @param p_performance_rating_id If p_validate is false, this uniquely
 * @param p_appr_line_score The score related to an appraisal objective assessment.
 * identifies the performance rating created. If p_validate is true, set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created performance rating. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Performance Rating
 * @rep:category BUSINESS_ENTITY PER_PERFORMANCE_REVIEW
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_performance_rating
  (p_validate                      in     boolean     default false
  ,p_effective_date                in     date
  ,p_appraisal_id                  in     number
  ,p_person_id                     in     number default null
  ,p_objective_id                  in     number
  ,p_performance_level_id          in     number      default null
  ,p_comments                      in     varchar2    default null
  ,p_attribute_category            in     varchar2    default null
  ,p_attribute1                    in     varchar2    default null
  ,p_attribute2                    in     varchar2    default null
  ,p_attribute3                    in     varchar2    default null
  ,p_attribute4                    in     varchar2    default null
  ,p_attribute5                    in     varchar2    default null
  ,p_attribute6                    in     varchar2    default null
  ,p_attribute7                    in     varchar2    default null
  ,p_attribute8                    in     varchar2    default null
  ,p_attribute9                    in     varchar2    default null
  ,p_attribute10                   in     varchar2    default null
  ,p_attribute11                   in     varchar2    default null
  ,p_attribute12                   in     varchar2    default null
  ,p_attribute13                   in     varchar2    default null
  ,p_attribute14                   in     varchar2    default null
  ,p_attribute15                   in     varchar2    default null
  ,p_attribute16                   in     varchar2    default null
  ,p_attribute17                   in     varchar2    default null
  ,p_attribute18                   in     varchar2    default null
  ,p_attribute19                   in     varchar2    default null
  ,p_attribute20                   in     varchar2    default null
  ,p_performance_rating_id            out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_appr_line_score               in     number      default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_performance_rating >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the performance rating.
 *
 * A performance rating is a single evaluation of an objective within an
 * appraisal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid performance rating must exist.
 *
 * <p><b>Post Success</b><br>
 * The performance rating is updated.
 *
 * <p><b>Post Failure</b><br>
 * Performance rating is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_performance_rating_id Identifies the performance rating to be
 * updated.
 * @param p_person_id Identifies the person record.
 * @param p_object_version_number Pass in the current version number of the
 * performance rating to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated performance
 * rating. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_appraisal_id Identifies the appraisal record.
 * @param p_objective_id Identifies the objective.
 * @param p_performance_level_id Identifier of the performance rating level.
 * @param p_comments Comment text.
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
 * @param p_appr_line_score The score related to an appraisal objective assessment.
 * @rep:displayname Update Performance Rating
 * @rep:category BUSINESS_ENTITY PER_PERFORMANCE_REVIEW
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_performance_rating
  (p_validate                      in     boolean     default false
  ,p_effective_date                in     date
  ,p_performance_rating_id         in     number
  ,p_person_id                     in     number default null
  ,p_object_version_number         in out nocopy number
  ,p_appraisal_id                  in     number      default hr_api.g_number
  ,p_objective_id                  in     number      default hr_api.g_number
  ,p_performance_level_id          in     number      default hr_api.g_number
  ,p_comments                      in     varchar2    default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2    default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2    default hr_api.g_varchar2
  ,p_appr_line_score               in     number      default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_performance_rating >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes performance rating.
 *
 * A performance rating is a single evaluation of an objective within an
 * appraisal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid performance rating must exist.
 *
 * <p><b>Post Success</b><br>
 * Performance rating is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Performance rating is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_performance_rating_id Identifies the performance rating to be
 * deleted.
 * @param p_object_version_number Current version number of the performance
 * rating to be deleted.
 * @rep:displayname Delete Performance Rating
 * @rep:category BUSINESS_ENTITY PER_PERFORMANCE_REVIEW
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_performance_rating
  (p_validate                      in     boolean  default false
  ,p_performance_rating_id         in     number
  ,p_object_version_number         in     number
  );
end hr_performance_ratings_api;

 

/
