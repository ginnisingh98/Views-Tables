--------------------------------------------------------
--  DDL for Package HR_SCORECARD_SHARING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SCORECARD_SHARING_API" AUTHID CURRENT_USER as
/* $Header: pepshapi.pkh 120.1 2006/10/16 23:38:56 tpapired noship $ */
/*#
 * This package contains scorecard sharing APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Scorecard Sharing
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_sharing_instance >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API shares a personal scorecard with a nominated person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal scorecard and person must exist.
 *
 * <p><b>Post Success</b><br>
 * The scorecard will have been shared.
 *
 * <p><b>Post Failure</b><br>
 * The scorecard will not be shared and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_scorecard_id Identifies the scorecard that is available to be shared.
 * @param p_person_id Identifies the person for whom the scorecard is shared
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
 * @param p_sharing_instance_id If p_validate is false, then this uniquely
 * identifies the sharing instance created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created sharing instance. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Sharing Instance
 * @rep:category BUSINESS_ENTITY PER_SCORECARD_SHARING
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure create_sharing_instance
  (p_validate                      in     boolean  default false
  ,p_scorecard_id                  in     number
  ,p_person_id                     in     number
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
  ,p_sharing_instance_id              out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_sharing_instance >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a scorecard sharing instance.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The sharing instance must exist.
 *
 * <p><b>Post Success</b><br>
 * The sharing instance will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The sharing instance will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_sharing_instance_id Identifies the sharing instance to be
 * deleted.
 * @param p_object_version_number Current version number of the sharing
 * instance to be deleted.
 * @rep:displayname Delete Sharing Instance
 * @rep:category BUSINESS_ENTITY PER_SCORECARD_SHARING
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_sharing_instance
  (p_validate                      in     boolean  default false
  ,p_sharing_instance_id           in     number
  ,p_object_version_number         in     number
  );
--
end hr_scorecard_sharing_api;

 

/
