--------------------------------------------------------
--  DDL for Package HR_ELC_CANDIDATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELC_CANDIDATE_API" AUTHID CURRENT_USER as
/* $Header: peecaapi.pkh 120.1 2005/10/02 02:15:09 aroussel $ */
/*#
 * This package creates candidates for an election for a representative body.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Election Candidate
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_election_candidate >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates candidates for an election for a representative body.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person must exist. Supplementary roles must already have been defined.
 *
 * <p><b>Post Success</b><br>
 * Election Candidate is created.
 *
 * <p><b>Post Failure</b><br>
 * Election candidate is not created and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Business group associated with the election
 * candidate.
 * @param p_person_id Uniquely identifies the person for whom you create the
 * election candidate record.
 * @param p_election_id Election id of the candidate.
 * @param p_rank Rank of the candidate.
 * @param p_role_id Role of the candidate.
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
 * @param p_candidate_info_category This context value determines which
 * flexfield structure to use with the candidate_information developer
 * descriptive flexfield segments.
 * @param p_candidate_information1 Developer descriptive flexfield
 * @param p_candidate_information2 Developer descriptive flexfield
 * @param p_candidate_information3 Developer descriptive flexfield
 * @param p_candidate_information4 Developer descriptive flexfield
 * @param p_candidate_information5 Developer descriptive flexfield
 * @param p_candidate_information6 Developer descriptive flexfield
 * @param p_candidate_information7 Developer descriptive flexfield
 * @param p_candidate_information8 Developer descriptive flexfield
 * @param p_candidate_information9 Developer descriptive flexfield
 * @param p_candidate_information10 Developer descriptive flexfield
 * @param p_candidate_information11 Developer descriptive flexfield
 * @param p_candidate_information12 Developer descriptive flexfield
 * @param p_candidate_information13 Developer descriptive flexfield
 * @param p_candidate_information14 Developer descriptive flexfield
 * @param p_candidate_information15 Developer descriptive flexfield
 * @param p_candidate_information16 Developer descriptive flexfield
 * @param p_candidate_information17 Developer descriptive flexfield
 * @param p_candidate_information18 Developer descriptive flexfield
 * @param p_candidate_information19 Developer descriptive flexfield
 * @param p_candidate_information20 Developer descriptive flexfield
 * @param p_candidate_information21 Developer descriptive flexfield
 * @param p_candidate_information22 Developer descriptive flexfield
 * @param p_candidate_information23 Developer descriptive flexfield
 * @param p_candidate_information24 Developer descriptive flexfield
 * @param p_candidate_information25 Developer descriptive flexfield
 * @param p_candidate_information26 Developer descriptive flexfield
 * @param p_candidate_information27 Developer descriptive flexfield
 * @param p_candidate_information28 Developer descriptive flexfield
 * @param p_candidate_information29 Developer descriptive flexfield
 * @param p_candidate_information30 Developer descriptive flexfield
 * @param p_election_candidate_id If p_validate is false, then this uniquely
 * identifies the created election candidate. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Election Candidate. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Election Candidate
 * @rep:category BUSINESS_ENTITY PER_WORK_COUNCIL_ELECTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_election_candidate
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_election_id                   in     number
  ,p_rank                          in     number
  ,p_role_id                       in     number
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
  ,p_candidate_info_category      in     varchar2 default null
  ,p_candidate_information1              in     varchar2 default null
  ,p_candidate_information2              in     varchar2 default null
  ,p_candidate_information3              in     varchar2 default null
  ,p_candidate_information4              in     varchar2 default null
  ,p_candidate_information5              in     varchar2 default null
  ,p_candidate_information6              in     varchar2 default null
  ,p_candidate_information7              in     varchar2 default null
  ,p_candidate_information8              in     varchar2 default null
  ,p_candidate_information9              in     varchar2 default null
  ,p_candidate_information10             in     varchar2 default null
  ,p_candidate_information11             in     varchar2 default null
  ,p_candidate_information12             in     varchar2 default null
  ,p_candidate_information13             in     varchar2 default null
  ,p_candidate_information14             in     varchar2 default null
  ,p_candidate_information15             in     varchar2 default null
  ,p_candidate_information16             in     varchar2 default null
  ,p_candidate_information17             in     varchar2 default null
  ,p_candidate_information18             in     varchar2 default null
  ,p_candidate_information19             in     varchar2 default null
  ,p_candidate_information20             in     varchar2 default null
  ,p_candidate_information21             in     varchar2 default null
  ,p_candidate_information22             in     varchar2 default null
  ,p_candidate_information23             in     varchar2 default null
  ,p_candidate_information24             in     varchar2 default null
  ,p_candidate_information25             in     varchar2 default null
  ,p_candidate_information26             in     varchar2 default null
  ,p_candidate_information27             in     varchar2 default null
  ,p_candidate_information28             in     varchar2 default null
  ,p_candidate_information29             in     varchar2 default null
  ,p_candidate_information30             in     varchar2 default null
  ,p_election_candidate_id                  out nocopy number
  ,p_object_version_number                  out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_election_candidate >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an election candidate record.
 *
 * The record is identified by p_election_candidate_id and
 * p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Election candidate record must exist.
 *
 * <p><b>Post Success</b><br>
 * Election candidate record is updated.
 *
 * <p><b>Post Failure</b><br>
 * Election candidate record is not updated and returns an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_election_candidate_id Identifies the election candidate record to
 * modify.
 * @param p_object_version_number Pass in the current version number of the
 * election candidate to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated election
 * candidate. If p_validate is true will be set to the same value which was
 * passed in..
 * @param p_business_group_id Business group associated with the election
 * candidate.
 * @param p_person_id Person ID of the election candidate.
 * @param p_election_id Election id of the candidate.
 * @param p_rank Rank of the candidate.
 * @param p_role_id Supplemenatry role of the candidate.
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
 * @param p_candidate_info_category This context value determines which
 * flexfield structure to use with the candidate_information developer
 * descriptive flexfield segments.
 * @param p_candidate_information1 Developer descriptive flexfield
 * @param p_candidate_information2 Developer descriptive flexfield
 * @param p_candidate_information3 Developer descriptive flexfield
 * @param p_candidate_information4 Developer descriptive flexfield
 * @param p_candidate_information5 Developer descriptive flexfield
 * @param p_candidate_information6 Developer descriptive flexfield
 * @param p_candidate_information7 Developer descriptive flexfield
 * @param p_candidate_information8 Developer descriptive flexfield
 * @param p_candidate_information9 Developer descriptive flexfield
 * @param p_candidate_information10 Developer descriptive flexfield
 * @param p_candidate_information11 Developer descriptive flexfield
 * @param p_candidate_information12 Developer descriptive flexfield
 * @param p_candidate_information13 Developer descriptive flexfield
 * @param p_candidate_information14 Developer descriptive flexfield
 * @param p_candidate_information15 Developer descriptive flexfield
 * @param p_candidate_information16 Developer descriptive flexfield
 * @param p_candidate_information17 Developer descriptive flexfield
 * @param p_candidate_information18 Developer descriptive flexfield
 * @param p_candidate_information19 Developer descriptive flexfield
 * @param p_candidate_information20 Developer descriptive flexfield
 * @param p_candidate_information21 Developer descriptive flexfield
 * @param p_candidate_information22 Developer descriptive flexfield
 * @param p_candidate_information23 Developer descriptive flexfield
 * @param p_candidate_information24 Developer descriptive flexfield
 * @param p_candidate_information25 Developer descriptive flexfield
 * @param p_candidate_information26 Developer descriptive flexfield
 * @param p_candidate_information27 Developer descriptive flexfield
 * @param p_candidate_information28 Developer descriptive flexfield
 * @param p_candidate_information29 Developer descriptive flexfield
 * @param p_candidate_information30 Developer descriptive flexfield
 * @rep:displayname Update Election Candidate
 * @rep:category BUSINESS_ENTITY PER_WORK_COUNCIL_ELECTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_election_candidate
  (p_validate                      in     boolean  default false
  ,p_election_candidate_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_election_id                   in     number   default hr_api.g_number
  ,p_rank                          in     number   default hr_api.g_number
  ,p_role_id                       in     number   default hr_api.g_number
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
  ,p_candidate_info_category       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information1        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information2        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information3        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information4        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information5        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information6        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information7        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information8        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information9        in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information10       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information11       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information12       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information13       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information14       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information15       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information16       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information17       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information18       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information19       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information20       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information21       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information22       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information23       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information24       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information25       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information26       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information27       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information28       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information29       in     varchar2 default hr_api.g_varchar2
  ,p_candidate_information30       in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_election_candidate >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an election candidate record.
 *
 * This API deletes a election candidate as identified by the in parameters
 * p_election_candidate_id and p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Election candidate must already exist.
 *
 * <p><b>Post Success</b><br>
 * Election candidate is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Election candidate is not deleted and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_election_candidate_id Identifies the election candidate record to
 * delete.
 * @param p_object_version_number Current version number of the election
 * candidate record to be deleted.
 * @rep:displayname Delete Election Candidate
 * @rep:category BUSINESS_ENTITY PER_WORK_COUNCIL_ELECTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_election_candidate
  (p_validate                      in     boolean  default false
  ,p_election_candidate_id         in     number
  ,p_object_version_number         in out nocopy number
  );

end hr_elc_candidate_api;

 

/
