--------------------------------------------------------
--  DDL for Package HR_CAGR_GRADE_STRUCTURES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_GRADE_STRUCTURES_API" AUTHID CURRENT_USER as
/* $Header: pegrsapi.pkh 120.1 2005/10/02 02:17:25 aroussel $ */
/*#
 * This package contains APIs which maintain collective agreement grade
 * structures.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Collective Agreement Grade Structure
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_cagr_grade_structures >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a collective agreement grade structure.
 *
 * A collective agreement may have one or more valid grade structures which are
 * defined via the CAGR Grades key flexfield.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement for which the grade structure is to be created must
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement grade structure is created.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement grade structure is not created and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_grade_structure_id If p_validate is false, then this uniquely
 * identifies the collective agreement grade structure created. If p_validate
 * is true, then set to null.
 * @param p_collective_agreement_id Uniquely identifies the parent collective
 * agreement.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created grade structure. If p_validate is true, then
 * the value will be null.
 * @param p_id_flex_num Uniquely identifies the collective agreement grade
 * structure within the internal key flexfield table.
 * @param p_dynamic_insert_allowed Indicates whether the assignment collective
 * agreement grades can vary from the collectively agreed set.
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
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Collective Agreement Grade Structure
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cagr_grade_structures
  (p_validate                       in  boolean   default false
  ,p_cagr_grade_structure_id        out nocopy number
  ,p_collective_agreement_id        in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_id_flex_num                    in  number    default null
  ,p_dynamic_insert_allowed         in  varchar2  default null
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
  ,p_effective_date		    in  date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_cagr_grade_structures >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a collective agreement grade structure.
 *
 * This API updates a collective agreement grade structure. A collective
 * agreement may have one or more valid grade structures which are defined
 * within the CAGR Grades key flexfield.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement grade structure as identified by the parameter
 * p_cagr_grade_structure_id and the p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement grade structure is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the collective agreement grade structure and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_grade_structure_id Uniquely identifies the collective
 * agreement grade structure to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * collective agreement grade structure to be updated. When the API completes
 * if p_validate is false, will be set to the new version number of the updated
 * collective agreement grade structure . If p_validate is true will be set to
 * the same value which was passed in.
 * @param p_dynamic_insert_allowed Indicates whether the assignment collective
 * agreement grades can vary from the collectively agreed set.
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
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Collective Agreement Grade Structure
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cagr_grade_structures
  (p_validate                       in  boolean   default false
  ,p_cagr_grade_structure_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_dynamic_insert_allowed         in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_date	            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_cagr_grade_structures >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a collective agreement grade structure.
 *
 * A collective agreement may have one or more valid grade structures which are
 * defined within the CAGR Grades key flexfield.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement grade structure as identified by the parameter
 * p_cagr_grade_structure_id and the p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement grade structure is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the collective agreement grade structure and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_grade_structure_id Uniquely identifies the collective
 * agreement grade structure to be deleted.
 * @param p_object_version_number Current version number of the collective
 * agreement grade structure to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Collective Agreement Grade Structure
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_cagr_grade_structures
  (p_validate                       in  boolean  default false
  ,p_cagr_grade_structure_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date		    in  date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_cagr_grade_structure_id      Yes  number    PK of record
--   p_effective_date	            No   date      Session date
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
   p_cagr_grade_structure_id        in     number
  ,p_object_version_number          in     number
  ,p_effective_date		    in     date
  );
--
end hr_cagr_grade_structures_api;

 

/
