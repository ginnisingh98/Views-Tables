--------------------------------------------------------
--  DDL for Package HR_PERSON_ABSENCE_CASE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ABSENCE_CASE_SWI" AUTHID CURRENT_USER As
/* $Header: hrabcswi.pkh 120.1 2006/03/17 02:53 snukala noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_person_absence_case >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_absence_case_api.create_person_absence_case
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_person_absence_case
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_name                         in     varchar2
  ,p_business_group_id            in     number
  ,p_incident_id                  in     number    default null
  ,p_absence_category             in     varchar2  default null
  ,p_ac_attribute_category        in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_ac_information_category      in     varchar2  default null
  ,p_ac_information1              in     varchar2  default null
  ,p_ac_information2              in     varchar2  default null
  ,p_ac_information3              in     varchar2  default null
  ,p_ac_information4              in     varchar2  default null
  ,p_ac_information5              in     varchar2  default null
  ,p_ac_information6              in     varchar2  default null
  ,p_ac_information7              in     varchar2  default null
  ,p_ac_information8              in     varchar2  default null
  ,p_ac_information9              in     varchar2  default null
  ,p_ac_information10             in     varchar2  default null
  ,p_ac_information11             in     varchar2  default null
  ,p_ac_information12             in     varchar2  default null
  ,p_ac_information13             in     varchar2  default null
  ,p_ac_information14             in     varchar2  default null
  ,p_ac_information15             in     varchar2  default null
  ,p_ac_information16             in     varchar2  default null
  ,p_ac_information17             in     varchar2  default null
  ,p_ac_information18             in     varchar2  default null
  ,p_ac_information19             in     varchar2  default null
  ,p_ac_information20             in     varchar2  default null
  ,p_ac_information21             in     varchar2  default null
  ,p_ac_information22             in     varchar2  default null
  ,p_ac_information23             in     varchar2  default null
  ,p_ac_information24             in     varchar2  default null
  ,p_ac_information25             in     varchar2  default null
  ,p_ac_information26             in     varchar2  default null
  ,p_ac_information27             in     varchar2  default null
  ,p_ac_information28             in     varchar2  default null
  ,p_ac_information29             in     varchar2  default null
  ,p_ac_information30             in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_absence_case_id              in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_person_absence_case >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_absence_case_api.update_person_absence_case
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_person_absence_case
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_case_id              in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_incident_id                  in     number    default hr_api.g_number
  ,p_absence_category             in     varchar2  default hr_api.g_varchar2
  ,p_ac_attribute_category        in     varchar2  default hr_api.g_varchar2
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
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_ac_information_category      in     varchar2  default hr_api.g_varchar2
  ,p_ac_information1              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information2              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information3              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information4              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information5              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information6              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information7              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information8              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information9              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information10             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information11             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information12             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information13             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information14             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information15             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information16             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information17             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information18             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information19             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information20             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information21             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information22             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information23             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information24             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information25             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information26             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information27             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information28             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information29             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information30             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_person_absence_case >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_absence_case_api.delete_person_absence_case
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_person_absence_case
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_case_id              in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end hr_person_absence_case_swi;

 

/
