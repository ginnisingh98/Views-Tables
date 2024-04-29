--------------------------------------------------------
--  DDL for Package IRC_SEARCH_CRITERIA_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SEARCH_CRITERIA_SWI" AUTHID CURRENT_USER As
/* $Header: iriscswi.pkh 120.1 2006/03/13 02:33:01 cnholmes noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_saved_search >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.create_saved_search
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
PROCEDURE create_saved_search
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_search_name                  in     varchar2
  ,p_location                     in     varchar2  default null
  ,p_distance_to_location         in     varchar2  default null
  ,p_geocode_location             in     varchar2 default null
  ,p_geocode_country              in     varchar2 default null
  ,p_derived_location             in     varchar2 default null
  ,p_location_id                  in     number   default null
  ,p_longitude                    in     number   default null
  ,p_latitude                     in     number   default null
  ,p_employee                     in     varchar2  default null
  ,p_contractor                   in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_travel_percentage            in     number    default null
  ,p_min_salary                   in     number    default null
  ,p_salary_currency              in     varchar2  default null
  ,p_salary_period                in     varchar2  default null
  ,p_match_competence             in     varchar2  default null
  ,p_match_qualification          in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_title                    in     varchar2  default null
  ,p_department                   in     varchar2  default null
  ,p_professional_area            in     varchar2  default null
  ,p_use_for_matching             in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
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
  ,p_isc_information_category     in     varchar2  default null
  ,p_isc_information1             in     varchar2  default null
  ,p_isc_information2             in     varchar2  default null
  ,p_isc_information3             in     varchar2  default null
  ,p_isc_information4             in     varchar2  default null
  ,p_isc_information5             in     varchar2  default null
  ,p_isc_information6             in     varchar2  default null
  ,p_isc_information7             in     varchar2  default null
  ,p_isc_information8             in     varchar2  default null
  ,p_isc_information9             in     varchar2  default null
  ,p_isc_information10            in     varchar2  default null
  ,p_isc_information11            in     varchar2  default null
  ,p_isc_information12            in     varchar2  default null
  ,p_isc_information13            in     varchar2  default null
  ,p_isc_information14            in     varchar2  default null
  ,p_isc_information15            in     varchar2  default null
  ,p_isc_information16            in     varchar2  default null
  ,p_isc_information17            in     varchar2  default null
  ,p_isc_information18            in     varchar2  default null
  ,p_isc_information19            in     varchar2  default null
  ,p_isc_information20            in     varchar2  default null
  ,p_isc_information21            in     varchar2  default null
  ,p_isc_information22            in     varchar2  default null
  ,p_isc_information23            in     varchar2  default null
  ,p_isc_information24            in     varchar2  default null
  ,p_isc_information25            in     varchar2  default null
  ,p_isc_information26            in     varchar2  default null
  ,p_isc_information27            in     varchar2  default null
  ,p_isc_information28            in     varchar2  default null
  ,p_isc_information29            in     varchar2  default null
  ,p_isc_information30            in     varchar2  default null
  ,p_date_posted                  in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_search_criteria_id           in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_vacancy_criteria >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.create_vacancy_criteria
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
PROCEDURE create_vacancy_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_id                   in     number
  ,p_effective_date               in     date
  ,p_location                     in     varchar2  default null
  ,p_employee                     in     varchar2  default null
  ,p_contractor                   in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_travel_percentage            in     number    default null
  ,p_min_salary                   in     number    default null
  ,p_max_salary                   in     number    default null
  ,p_salary_currency              in     varchar2  default null
  ,p_salary_period                in     varchar2  default null
  ,p_professional_area            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_min_qual_level               in     number    default null
  ,p_max_qual_level               in     number    default null
  ,p_description                  in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
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
  ,p_isc_information_category     in     varchar2  default null
  ,p_isc_information1             in     varchar2  default null
  ,p_isc_information2             in     varchar2  default null
  ,p_isc_information3             in     varchar2  default null
  ,p_isc_information4             in     varchar2  default null
  ,p_isc_information5             in     varchar2  default null
  ,p_isc_information6             in     varchar2  default null
  ,p_isc_information7             in     varchar2  default null
  ,p_isc_information8             in     varchar2  default null
  ,p_isc_information9             in     varchar2  default null
  ,p_isc_information10            in     varchar2  default null
  ,p_isc_information11            in     varchar2  default null
  ,p_isc_information12            in     varchar2  default null
  ,p_isc_information13            in     varchar2  default null
  ,p_isc_information14            in     varchar2  default null
  ,p_isc_information15            in     varchar2  default null
  ,p_isc_information16            in     varchar2  default null
  ,p_isc_information17            in     varchar2  default null
  ,p_isc_information18            in     varchar2  default null
  ,p_isc_information19            in     varchar2  default null
  ,p_isc_information20            in     varchar2  default null
  ,p_isc_information21            in     varchar2  default null
  ,p_isc_information22            in     varchar2  default null
  ,p_isc_information23            in     varchar2  default null
  ,p_isc_information24            in     varchar2  default null
  ,p_isc_information25            in     varchar2  default null
  ,p_isc_information26            in     varchar2  default null
  ,p_isc_information27            in     varchar2  default null
  ,p_isc_information28            in     varchar2  default null
  ,p_isc_information29            in     varchar2  default null
  ,p_isc_information30            in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_search_criteria_id           in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_saved_search >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.delete_saved_search
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
PROCEDURE delete_saved_search
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_search_criteria_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_vacancy_criteria >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.delete_vacancy_criteria
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
PROCEDURE delete_vacancy_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_search_criteria_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_saved_search >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.update_saved_search
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
PROCEDURE update_saved_search
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_search_criteria_id           in     number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_search_name                  in     varchar2  default hr_api.g_varchar2
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_distance_to_location         in     varchar2  default hr_api.g_varchar2
  ,p_geocode_location             in     varchar2  default hr_api.g_varchar2
  ,p_geocode_country              in     varchar2  default hr_api.g_varchar2
  ,p_derived_location             in     varchar2  default hr_api.g_varchar2
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_longitude                    in     number    default hr_api.g_number
  ,p_latitude                     in     number    default hr_api.g_number
  ,p_employee                     in     varchar2  default hr_api.g_varchar2
  ,p_contractor                   in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_travel_percentage            in     number    default hr_api.g_number
  ,p_min_salary                   in     number    default hr_api.g_number
  ,p_salary_currency              in     varchar2  default hr_api.g_varchar2
  ,p_salary_period                in     varchar2  default hr_api.g_varchar2
  ,p_match_competence             in     varchar2  default hr_api.g_varchar2
  ,p_match_qualification          in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_title                    in     varchar2  default hr_api.g_varchar2
  ,p_department                   in     varchar2  default hr_api.g_varchar2
  ,p_professional_area            in     varchar2  default hr_api.g_varchar2
  ,p_use_for_matching             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
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
  ,p_isc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_isc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information30            in     varchar2  default hr_api.g_varchar2
  ,p_date_posted                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_vacancy_criteria >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.update_vacancy_criteria
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
PROCEDURE update_vacancy_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_search_criteria_id           in     number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_effective_date               in     date
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_employee                     in     varchar2  default hr_api.g_varchar2
  ,p_contractor                   in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_travel_percentage            in     number    default hr_api.g_number
  ,p_min_salary                   in     number    default hr_api.g_number
  ,p_max_salary                   in     number    default hr_api.g_number
  ,p_salary_currency              in     varchar2  default hr_api.g_varchar2
  ,p_salary_period                in     varchar2  default hr_api.g_varchar2
  ,p_professional_area            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_min_qual_level               in     number    default hr_api.g_number
  ,p_max_qual_level               in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
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
  ,p_isc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_isc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_work_choices >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.create_work_choices
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
PROCEDURE create_work_choices
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_location                     in     varchar2  default null
  ,p_distance_to_location         in     varchar2  default null
  ,p_geocode_location             in     varchar2 default null
  ,p_geocode_country              in     varchar2 default null
  ,p_derived_location             in     varchar2 default null
  ,p_location_id                  in     number   default null
  ,p_longitude                    in     number   default null
  ,p_latitude                     in     number   default null
  ,p_employee                     in     varchar2  default null
  ,p_contractor                   in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_travel_percentage            in     number    default null
  ,p_min_salary                   in     number    default null
  ,p_salary_currency              in     varchar2  default null
  ,p_salary_period                in     varchar2  default null
  ,p_match_competence             in     varchar2  default null
  ,p_match_qualification          in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_title                    in     varchar2  default null
  ,p_department                   in     varchar2  default null
  ,p_professional_area            in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
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
  ,p_isc_information_category     in     varchar2  default null
  ,p_isc_information1             in     varchar2  default null
  ,p_isc_information2             in     varchar2  default null
  ,p_isc_information3             in     varchar2  default null
  ,p_isc_information4             in     varchar2  default null
  ,p_isc_information5             in     varchar2  default null
  ,p_isc_information6             in     varchar2  default null
  ,p_isc_information7             in     varchar2  default null
  ,p_isc_information8             in     varchar2  default null
  ,p_isc_information9             in     varchar2  default null
  ,p_isc_information10            in     varchar2  default null
  ,p_isc_information11            in     varchar2  default null
  ,p_isc_information12            in     varchar2  default null
  ,p_isc_information13            in     varchar2  default null
  ,p_isc_information14            in     varchar2  default null
  ,p_isc_information15            in     varchar2  default null
  ,p_isc_information16            in     varchar2  default null
  ,p_isc_information17            in     varchar2  default null
  ,p_isc_information18            in     varchar2  default null
  ,p_isc_information19            in     varchar2  default null
  ,p_isc_information20            in     varchar2  default null
  ,p_isc_information21            in     varchar2  default null
  ,p_isc_information22            in     varchar2  default null
  ,p_isc_information23            in     varchar2  default null
  ,p_isc_information24            in     varchar2  default null
  ,p_isc_information25            in     varchar2  default null
  ,p_isc_information26            in     varchar2  default null
  ,p_isc_information27            in     varchar2  default null
  ,p_isc_information28            in     varchar2  default null
  ,p_isc_information29            in     varchar2  default null
  ,p_isc_information30            in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_search_criteria_id           in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_work_choices >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.delete_work_choices
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
PROCEDURE delete_work_choices
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_search_criteria_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_work_choices >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_search_criteria_api.update_work_choices
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
PROCEDURE update_work_choices
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_search_criteria_id           in     number
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_distance_to_location         in     varchar2  default hr_api.g_varchar2
  ,p_geocode_location             in     varchar2 default hr_api.g_varchar2
  ,p_geocode_country              in     varchar2 default hr_api.g_varchar2
  ,p_derived_location             in     varchar2 default hr_api.g_varchar2
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_longitude                    in     number   default hr_api.g_number
  ,p_latitude                     in     number   default hr_api.g_number
  ,p_employee                     in     varchar2  default hr_api.g_varchar2
  ,p_contractor                   in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_travel_percentage            in     number    default hr_api.g_number
  ,p_min_salary                   in     number    default hr_api.g_number
  ,p_salary_currency              in     varchar2  default hr_api.g_varchar2
  ,p_salary_period                in     varchar2  default hr_api.g_varchar2
  ,p_match_competence             in     varchar2  default hr_api.g_varchar2
  ,p_match_qualification          in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_title                    in     varchar2  default hr_api.g_varchar2
  ,p_department                   in     varchar2  default hr_api.g_varchar2
  ,p_professional_area            in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
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
  ,p_isc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_isc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
--
procedure process_vacancy_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
);
--
end irc_search_criteria_swi;

 

/
