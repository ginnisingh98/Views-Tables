--------------------------------------------------------
--  DDL for Package HR_PERSON_TYPE_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_TYPE_USAGE_API" AUTHID CURRENT_USER as
/* $Header: peptuapi.pkh 120.3 2005/10/31 02:56:09 jpthomas noship $ */
/*#
 * This package maintains person type usages.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Type Usage
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_type_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates information held about a type associated with a person.
 *
 * A person has a type that defines which business processes can apply to that
 * person. For example, you can only hire someone who as a person type of
 * 'Applicant'. A person can have many types at one time, for example, employee
 * and applicant. This API allows update to flexfield information for a
 * particular person type usage.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person type usage record must exist before it can be updated.
 *
 * <p><b>Post Success</b><br>
 * The person type usage will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The person type usage will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_type_usage_id Uniquely identifies the person type usage
 * record to update.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_object_version_number Pass in the current version number of the
 * person type usage to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated person type
 * usage. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_person_type_id Uniquely identifies the type associated to the
 * person. Update of this value is currently unsupported.
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
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person type usage which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person type usage which now exists as of
 * the effective date. If p_validate is true, then set to null.
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
 * @rep:displayname Update Person Type Usage
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_person_type_usage
  (
   p_validate                       in  boolean    default false
  ,p_person_type_usage_id           in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_person_type_id                 in  number    default hr_api.g_number
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
  ,p_attribute21                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_person_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
function  check_person_type
          (
            p_person_id                      in  number
           ,p_effective_date                 in  date
           ,p_person_type                    in  varchar2
          ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_person_ex_type >-------------------------|
-- ----------------------------------------------------------------------------
--
function check_person_ex_type
          (
            p_person_id                      in  number
           ,p_effective_date                 in  date
           ,p_person_type                    in  varchar2
          ) return boolean;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_type_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an association between a type and a person.
 *
 * A person has a type that defines which business processes can apply to that
 * person. For example, you can only hire someone who as a person type of
 * 'Applicant'. A person can have many types at one time, for example, employee
 * and applicant. This API associates a type to a person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person must exist.
 *
 * <p><b>Post Success</b><br>
 * A person type usage record will be created.
 *
 * <p><b>Post Failure</b><br>
 * A person type usage record will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person who will be associated with the
 * specified person type.
 * @param p_person_type_id The person type for this person
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
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
 * @param p_person_type_usage_id If p_validate is false, then this uniquely
 * identifies the created person type usage. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created person type usage. If p_validate is true, then
 * the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person type usage. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person type usage. If p_validate is true,
 * then set to null.
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
 * @rep:displayname Create Person Type Usage
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_person_type_usage
(
   p_validate                       in boolean    default false
  ,p_person_id                      in  number
  ,p_person_type_id                 in  number
  ,p_effective_date                 in  date
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
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_person_type_usage_id           out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_type_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a person type usage.
 *
 * Many restrictions are placed upon the deletion of person types. For example,
 * you cannot delete a person type of 'employee' as this is equivalent to a
 * termination. Instead, the correct business process must be used. It is
 * possible to delete person type usage records based on user defined person
 * types.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person type usage must exist
 *
 * <p><b>Post Success</b><br>
 * The person type usage will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The person type usage will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_type_usage_id Uniquely identifies the person type usage
 * record to be deleted.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_object_version_number Current version number of the person type
 * usage to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted person type usage row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted person type usage row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Person Type Usage
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_person_type_usage
  (
   p_validate                       in boolean        default false
  ,p_person_type_usage_id           in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  );
end hr_person_type_usage_api;

 

/
