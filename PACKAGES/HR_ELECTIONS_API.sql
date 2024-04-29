--------------------------------------------------------
--  DDL for Package HR_ELECTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELECTIONS_API" AUTHID CURRENT_USER as
/* $Header: peelcapi.pkh 120.1 2005/10/02 02:15:24 aroussel $ */
/*#
 * This package contains APIs that create and maintain election information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Election
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_election_information >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates election information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Organization with the classification of representative body should already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * Election information is created.
 *
 * <p><b>Post Failure</b><br>
 * Election information does not get created and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the representative body.
 * @param p_election_date The election date.
 * @param p_description Description of the election.
 * @param p_rep_body_id Uniquely identifies the representative body for which
 * the election is taking place.
 * @param p_previous_election_date Date of the previous election
 * @param p_next_election_date Date of the next election
 * @param p_result_publish_date Date on which the election results will be
 * publshed.
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
 * @param p_election_info_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield
 * segments.
 * @param p_election_information1 Developers descriptive flexfield.
 * @param p_election_information2 Developers descriptive flexfield.
 * @param p_election_information3 Developers descriptive flexfield.
 * @param p_election_information4 Developers descriptive flexfield.
 * @param p_election_information5 Developers descriptive flexfield.
 * @param p_election_information6 Developers descriptive flexfield.
 * @param p_election_information7 Developers descriptive flexfield.
 * @param p_election_information8 Developers descriptive flexfield.
 * @param p_election_information9 Developers descriptive flexfield.
 * @param p_election_information10 Developers descriptive flexfield.
 * @param p_election_information11 Developers descriptive flexfield.
 * @param p_election_information12 Developers descriptive flexfield.
 * @param p_election_information13 Developers descriptive flexfield.
 * @param p_election_information14 Developers descriptive flexfield.
 * @param p_election_information15 Developers descriptive flexfield.
 * @param p_election_information16 Developers descriptive flexfield.
 * @param p_election_information17 Developers descriptive flexfield.
 * @param p_election_information18 Developers descriptive flexfield.
 * @param p_election_information19 Developers descriptive flexfield.
 * @param p_election_information20 Developers descriptive flexfield.
 * @param p_election_information21 Developers descriptive flexfield.
 * @param p_election_information22 Developers descriptive flexfield.
 * @param p_election_information23 Developers descriptive flexfield.
 * @param p_election_information24 Developers descriptive flexfield.
 * @param p_election_information25 Developers descriptive flexfield.
 * @param p_election_information26 Developers descriptive flexfield.
 * @param p_election_information27 Developers descriptive flexfield.
 * @param p_election_information28 Developers descriptive flexfield.
 * @param p_election_information29 Developers descriptive flexfield.
 * @param p_election_information30 Developers descriptive flexfield.
 * @param p_election_id If p_validate is false, then this uniquely identifies
 * the election information record created. If p_validate is true, then set to
 * null..
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created election information record. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Election Information
 * @rep:category BUSINESS_ENTITY PER_WORK_COUNCIL_ELECTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_election_information
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in	  number
  ,p_election_date                 in     date
  ,p_description		   in     varchar2 default null
  ,p_rep_body_id                   in     number
  ,p_previous_election_date        in     date	   default null
  ,p_next_election_date            in     date     default null
  ,p_result_publish_date           in     date     default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1			   in	  varchar2 default null
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
  ,p_election_info_category 		in     varchar2 default null
  ,p_election_information1         in     varchar2 default null
  ,p_election_information2         in     varchar2 default null
  ,p_election_information3         in     varchar2 default null
  ,p_election_information4         in     varchar2 default null
  ,p_election_information5         in     varchar2 default null
  ,p_election_information6         in     varchar2 default null
  ,p_election_information7         in     varchar2 default null
  ,p_election_information8         in     varchar2 default null
  ,p_election_information9         in     varchar2 default null
  ,p_election_information10        in     varchar2 default null
  ,p_election_information11        in     varchar2 default null
  ,p_election_information12        in     varchar2 default null
  ,p_election_information13        in     varchar2 default null
  ,p_election_information14        in     varchar2 default null
  ,p_election_information15        in     varchar2 default null
  ,p_election_information16        in     varchar2 default null
  ,p_election_information17        in     varchar2 default null
  ,p_election_information18        in     varchar2 default null
  ,p_election_information19        in     varchar2 default null
  ,p_election_information20	   in	  varchar2 default null
  ,p_election_information21        in     varchar2 default null
  ,p_election_information22        in     varchar2 default null
  ,p_election_information23        in     varchar2 default null
  ,p_election_information24        in     varchar2 default null
  ,p_election_information25        in     varchar2 default null
  ,p_election_information26        in     varchar2 default null
  ,p_election_information27        in     varchar2 default null
  ,p_election_information28        in     varchar2 default null
  ,p_election_information29        in     varchar2 default null
  ,p_election_information30        in     varchar2 default null
  ,p_election_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_election_information >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates election information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Election Information should exist.
 *
 * <p><b>Post Success</b><br>
 * Election Information is updated.
 *
 * <p><b>Post Failure</b><br>
 * Election Information is not updated and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_election_id If p_validate is false, uniquely identifies the updated
 * election record. If p_validate is true, set to null.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the representative body.
 * @param p_election_date Date of the election.
 * @param p_description Description of the election process.
 * @param p_rep_body_id Uniquely identifies the representative body for which
 * the election is taking place.
 * @param p_previous_election_date Date of the previous election.
 * @param p_next_election_date Date of the next election.
 * @param p_result_publish_date Date on which the election results will be
 * publshed.
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
 * @param p_election_info_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield
 * segments.
 * @param p_election_information1 Developers descriptive flexfield.
 * @param p_election_information2 Developers descriptive flexfield.
 * @param p_election_information3 Developers descriptive flexfield.
 * @param p_election_information4 Developers descriptive flexfield.
 * @param p_election_information5 Developers descriptive flexfield.
 * @param p_election_information6 Developers descriptive flexfield.
 * @param p_election_information7 Developers descriptive flexfield.
 * @param p_election_information8 Developers descriptive flexfield.
 * @param p_election_information9 Developers descriptive flexfield.
 * @param p_election_information10 Developers descriptive flexfield.
 * @param p_election_information11 Developers descriptive flexfield.
 * @param p_election_information12 Developers descriptive flexfield.
 * @param p_election_information13 Developers descriptive flexfield.
 * @param p_election_information14 Developers descriptive flexfield.
 * @param p_election_information15 Developers descriptive flexfield.
 * @param p_election_information16 Developers descriptive flexfield.
 * @param p_election_information17 Developers descriptive flexfield.
 * @param p_election_information18 Developers descriptive flexfield.
 * @param p_election_information19 Developers descriptive flexfield.
 * @param p_election_information20 Developers descriptive flexfield.
 * @param p_election_information21 Developers descriptive flexfield.
 * @param p_election_information22 Developers descriptive flexfield.
 * @param p_election_information23 Developers descriptive flexfield.
 * @param p_election_information24 Developers descriptive flexfield.
 * @param p_election_information25 Developers descriptive flexfield.
 * @param p_election_information26 Developers descriptive flexfield.
 * @param p_election_information27 Developers descriptive flexfield.
 * @param p_election_information28 Developers descriptive flexfield.
 * @param p_election_information29 Developers descriptive flexfield.
 * @param p_election_information30 Developers descriptive flexfield.
 * @param p_object_version_number Pass in the current version number of the
 * Election Information to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Election
 * Information. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Election Information
 * @rep:category BUSINESS_ENTITY PER_WORK_COUNCIL_ELECTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_election_information
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_election_id                   in out nocopy number
  ,p_business_group_id             in     number
  ,p_election_date                 in     date
  ,p_description		   in	  varchar2
  ,p_rep_body_id                   in     number
  ,p_previous_election_date        in     date     default hr_api.g_date
  ,p_next_election_date            in     date     default hr_api.g_date
  ,p_result_publish_date           in     date     default hr_api.g_date
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
  ,p_election_info_category        in     varchar2 default hr_api.g_varchar2
  ,p_election_information1         in     varchar2 default hr_api.g_varchar2
  ,p_election_information2         in     varchar2 default hr_api.g_varchar2
  ,p_election_information3         in     varchar2 default hr_api.g_varchar2
  ,p_election_information4         in     varchar2 default hr_api.g_varchar2
  ,p_election_information5         in     varchar2 default hr_api.g_varchar2
  ,p_election_information6         in     varchar2 default hr_api.g_varchar2
  ,p_election_information7         in     varchar2 default hr_api.g_varchar2
  ,p_election_information8         in     varchar2 default hr_api.g_varchar2
  ,p_election_information9         in     varchar2 default hr_api.g_varchar2
  ,p_election_information10        in     varchar2 default hr_api.g_varchar2
  ,p_election_information11        in     varchar2 default hr_api.g_varchar2
  ,p_election_information12        in     varchar2 default hr_api.g_varchar2
  ,p_election_information13        in     varchar2 default hr_api.g_varchar2
  ,p_election_information14        in     varchar2 default hr_api.g_varchar2
  ,p_election_information15        in     varchar2 default hr_api.g_varchar2
  ,p_election_information16        in     varchar2 default hr_api.g_varchar2
  ,p_election_information17        in     varchar2 default hr_api.g_varchar2
  ,p_election_information18        in     varchar2 default hr_api.g_varchar2
  ,p_election_information19        in     varchar2 default hr_api.g_varchar2
  ,p_election_information20        in     varchar2 default hr_api.g_varchar2
  ,p_election_information21        in     varchar2 default hr_api.g_varchar2
  ,p_election_information22        in     varchar2 default hr_api.g_varchar2
  ,p_election_information23        in     varchar2 default hr_api.g_varchar2
  ,p_election_information24        in     varchar2 default hr_api.g_varchar2
  ,p_election_information25        in     varchar2 default hr_api.g_varchar2
  ,p_election_information26        in     varchar2 default hr_api.g_varchar2
  ,p_election_information27        in     varchar2 default hr_api.g_varchar2
  ,p_election_information28        in     varchar2 default hr_api.g_varchar2
  ,p_election_information29        in     varchar2 default hr_api.g_varchar2
  ,p_election_information30        in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_election_information >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an election information record and stores the details.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Election iformation record should exist.
 *
 * <p><b>Post Success</b><br>
 * Election information is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Election information is not deleted and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_election_id Identifies the election record to delete..
 * @param p_object_version_number Current version number of the Election
 * Information to be deleted.
 * @rep:displayname Delete Election Information
 * @rep:category BUSINESS_ENTITY PER_WORK_COUNCIL_ELECTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_election_information
  (p_validate                      in     boolean  default false
  ,p_election_id                   in     number
  ,p_object_version_number         in     number
  );
  --
end hr_elections_api;

 

/
