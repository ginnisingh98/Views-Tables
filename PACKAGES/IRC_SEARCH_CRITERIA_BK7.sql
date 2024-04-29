--------------------------------------------------------
--  DDL for Package IRC_SEARCH_CRITERIA_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SEARCH_CRITERIA_BK7" AUTHID CURRENT_USER as
/* $Header: iriscapi.pkh 120.2 2008/02/21 14:24:29 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_WORK_CHOICES_B >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_WORK_CHOICES_B
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_location                      in     varchar2
  ,p_distance_to_location          in     varchar2
  ,p_geocode_location              in     varchar2
  ,p_geocode_country               in     varchar2
  ,p_derived_location              in     varchar2
  ,p_location_id                   in     number
  ,p_longitude                     in     number
  ,p_latitude                      in     number
  ,p_employee                      in     varchar2
  ,p_contractor                    in     varchar2
  ,p_employment_category           in     varchar2
  ,p_keywords                      in     varchar2
  ,p_travel_percentage             in     number
  ,p_min_salary                    in     number
  ,p_salary_currency               in     varchar2
  ,p_salary_period                 in     varchar2
  ,p_match_competence              in     varchar2
  ,p_match_qualification           in     varchar2
  ,p_work_at_home                  in     varchar2
  ,p_job_title                     in     varchar2
  ,p_department                    in     varchar2
  ,p_professional_area             in     varchar2
  ,p_description                   in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_isc_information_category      in     varchar2
  ,p_isc_information1              in     varchar2
  ,p_isc_information2              in     varchar2
  ,p_isc_information3              in     varchar2
  ,p_isc_information4              in     varchar2
  ,p_isc_information5              in     varchar2
  ,p_isc_information6              in     varchar2
  ,p_isc_information7              in     varchar2
  ,p_isc_information8              in     varchar2
  ,p_isc_information9              in     varchar2
  ,p_isc_information10             in     varchar2
  ,p_isc_information11             in     varchar2
  ,p_isc_information12             in     varchar2
  ,p_isc_information13             in     varchar2
  ,p_isc_information14             in     varchar2
  ,p_isc_information15             in     varchar2
  ,p_isc_information16             in     varchar2
  ,p_isc_information17             in     varchar2
  ,p_isc_information18             in     varchar2
  ,p_isc_information19             in     varchar2
  ,p_isc_information20             in     varchar2
  ,p_isc_information21             in     varchar2
  ,p_isc_information22             in     varchar2
  ,p_isc_information23             in     varchar2
  ,p_isc_information24             in     varchar2
  ,p_isc_information25             in     varchar2
  ,p_isc_information26             in     varchar2
  ,p_isc_information27             in     varchar2
  ,p_isc_information28             in     varchar2
  ,p_isc_information29             in     varchar2
  ,p_isc_information30             in     varchar2
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_WORK_CHOICES_A >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_WORK_CHOICES_A
  (p_effective_date                in     date
  ,p_search_criteria_id            in     number
  ,p_person_id                     in     number
  ,p_location                      in     varchar2
  ,p_distance_to_location          in     varchar2
  ,p_geocode_location              in     varchar2
  ,p_geocode_country               in     varchar2
  ,p_derived_location              in     varchar2
  ,p_location_id                   in     number
  ,p_longitude                     in     number
  ,p_latitude                      in     number
  ,p_employee                      in     varchar2
  ,p_contractor                    in     varchar2
  ,p_employment_category           in     varchar2
  ,p_keywords                      in     varchar2
  ,p_travel_percentage             in     number
  ,p_min_salary                    in     number
  ,p_salary_currency               in     varchar2
  ,p_salary_period                 in     varchar2
  ,p_match_competence              in     varchar2
  ,p_match_qualification           in     varchar2
  ,p_work_at_home                  in     varchar2
  ,p_job_title                     in     varchar2
  ,p_department                    in     varchar2
  ,p_professional_area             in     varchar2
  ,p_description                   in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_isc_information_category      in     varchar2
  ,p_isc_information1              in     varchar2
  ,p_isc_information2              in     varchar2
  ,p_isc_information3              in     varchar2
  ,p_isc_information4              in     varchar2
  ,p_isc_information5              in     varchar2
  ,p_isc_information6              in     varchar2
  ,p_isc_information7              in     varchar2
  ,p_isc_information8              in     varchar2
  ,p_isc_information9              in     varchar2
  ,p_isc_information10             in     varchar2
  ,p_isc_information11             in     varchar2
  ,p_isc_information12             in     varchar2
  ,p_isc_information13             in     varchar2
  ,p_isc_information14             in     varchar2
  ,p_isc_information15             in     varchar2
  ,p_isc_information16             in     varchar2
  ,p_isc_information17             in     varchar2
  ,p_isc_information18             in     varchar2
  ,p_isc_information19             in     varchar2
  ,p_isc_information20             in     varchar2
  ,p_isc_information21             in     varchar2
  ,p_isc_information22             in     varchar2
  ,p_isc_information23             in     varchar2
  ,p_isc_information24             in     varchar2
  ,p_isc_information25             in     varchar2
  ,p_isc_information26             in     varchar2
  ,p_isc_information27             in     varchar2
  ,p_isc_information28             in     varchar2
  ,p_isc_information29             in     varchar2
  ,p_isc_information30             in     varchar2
  ,p_object_version_number         in     number
  );
--
end IRC_SEARCH_CRITERIA_BK7;

/
