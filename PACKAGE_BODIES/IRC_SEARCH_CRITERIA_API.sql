--------------------------------------------------------
--  DDL for Package Body IRC_SEARCH_CRITERIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SEARCH_CRITERIA_API" as
/* $Header: iriscapi.pkb 120.0 2005/07/26 15:10:47 mbocutt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_SEARCH_CRITERIA_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_SAVED_SEARCH >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_SAVED_SEARCH
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_search_name                   in     varchar2
  ,p_location                      in     varchar2 default null
  ,p_distance_to_location          in     varchar2 default null
  ,p_geocode_location              in     varchar2 default null
  ,p_geocode_country               in     varchar2 default null
  ,p_derived_location              in     varchar2 default null
  ,p_location_id                   in     number   default null
  ,p_longitude                     in     number   default null
  ,p_latitude                      in     number   default null
  ,p_employee                      in     varchar2 default null
  ,p_contractor                    in     varchar2 default null
  ,p_employment_category           in     varchar2 default 'EITHER'
  ,p_keywords                      in     varchar2 default null
  ,p_travel_percentage             in     number   default null
  ,p_min_salary                    in     number   default null
  ,p_salary_currency               in     varchar2 default null
  ,p_salary_period                 in     varchar2 default null
  ,p_match_competence              in     varchar2 default 'N'
  ,p_match_qualification           in     varchar2 default 'N'
  ,p_work_at_home                  in     varchar2 default 'POSSIBLE'
  ,p_job_title                     in     varchar2 default null
  ,p_department                    in     varchar2 default null
  ,p_professional_area             in     varchar2 default null
  ,p_use_for_matching              in     varchar2 default 'N'
  ,p_description                   in     varchar2 default null
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
  ,p_isc_information_category      in     varchar2 default null
  ,p_isc_information1              in     varchar2 default null
  ,p_isc_information2              in     varchar2 default null
  ,p_isc_information3              in     varchar2 default null
  ,p_isc_information4              in     varchar2 default null
  ,p_isc_information5              in     varchar2 default null
  ,p_isc_information6              in     varchar2 default null
  ,p_isc_information7              in     varchar2 default null
  ,p_isc_information8              in     varchar2 default null
  ,p_isc_information9              in     varchar2 default null
  ,p_isc_information10             in     varchar2 default null
  ,p_isc_information11             in     varchar2 default null
  ,p_isc_information12             in     varchar2 default null
  ,p_isc_information13             in     varchar2 default null
  ,p_isc_information14             in     varchar2 default null
  ,p_isc_information15             in     varchar2 default null
  ,p_isc_information16             in     varchar2 default null
  ,p_isc_information17             in     varchar2 default null
  ,p_isc_information18             in     varchar2 default null
  ,p_isc_information19             in     varchar2 default null
  ,p_isc_information20             in     varchar2 default null
  ,p_isc_information21             in     varchar2 default null
  ,p_isc_information22             in     varchar2 default null
  ,p_isc_information23             in     varchar2 default null
  ,p_isc_information24             in     varchar2 default null
  ,p_isc_information25             in     varchar2 default null
  ,p_isc_information26             in     varchar2 default null
  ,p_isc_information27             in     varchar2 default null
  ,p_isc_information28             in     varchar2 default null
  ,p_isc_information29             in     varchar2 default null
  ,p_isc_information30             in     varchar2 default null
  ,p_date_posted                   in     varchar2 default null
  ,p_object_version_number           out nocopy  number
  ,p_search_criteria_id              out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'CREATE_SAVED_SEARCH';
  l_effective_date       date;
  l_object_version_number irc_search_criteria.object_version_number%TYPE;
  l_search_criteria_id    irc_search_criteria.search_criteria_id%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_SAVED_SEARCH;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK1.CREATE_SAVED_SEARCH_B
  (p_effective_date             =>     l_effective_date
  ,p_person_id                  =>     p_person_id
  ,p_search_name                =>     p_search_name
  ,p_location                   =>     p_location
  ,p_distance_to_location       =>     p_distance_to_location
  ,p_geocode_location           =>     p_geocode_location
  ,p_geocode_country            =>     p_geocode_country
  ,p_derived_location           =>     p_derived_location
  ,p_location_id                =>     p_location_id
  ,p_longitude                  =>     p_longitude
  ,p_latitude                   =>     p_latitude
  ,p_employee                   =>     p_employee
  ,p_contractor                 =>     p_contractor
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_match_competence           =>     p_match_competence
  ,p_match_qualification        =>     p_match_qualification
  ,p_work_at_home               =>     p_work_at_home
  ,p_job_title                  =>     p_job_title
  ,p_department                 =>     p_department
  ,p_professional_area          =>     p_professional_area
  ,p_use_for_matching           =>     p_use_for_matching
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_date_posted                =>     p_date_posted
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SAVED_SEARCH'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_ins.ins(
   p_effective_date             =>     l_effective_date
  ,p_object_id                  =>     p_person_id
  ,p_object_type                =>     'PERSON'
  ,p_search_name                =>     p_search_name
  ,p_location                   =>     p_location
  ,p_distance_to_location       =>     p_distance_to_location
  ,p_geocode_location           =>     p_geocode_location
  ,p_geocode_country            =>     p_geocode_country
  ,p_derived_location           =>     p_derived_location
  ,p_location_id                =>     p_location_id
  ,p_longitude                  =>     p_longitude
  ,p_latitude                   =>     p_latitude
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_match_competence           =>     p_match_competence
  ,p_match_qualification        =>     p_match_qualification
  ,p_work_at_home               =>     p_work_at_home
  ,p_job_title                  =>     p_job_title
  ,p_department                 =>     p_department
  ,p_professional_area          =>     p_professional_area
  ,p_use_for_matching           =>     p_use_for_matching
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  ,p_date_posted                =>     p_date_posted
  ,p_search_criteria_id         =>     l_search_criteria_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK1.CREATE_SAVED_SEARCH_A
  (p_effective_date                =>     l_effective_date
  ,p_person_id                     =>     p_person_id
  ,p_search_name                   =>     p_search_name
  ,p_location                      =>     p_location
  ,p_distance_to_location          =>     p_distance_to_location
  ,p_geocode_location              =>     p_geocode_location
  ,p_geocode_country               =>     p_geocode_country
  ,p_derived_location              =>     p_derived_location
  ,p_location_id                   =>     p_location_id
  ,p_longitude                     =>     p_longitude
  ,p_latitude                      =>     p_latitude
  ,p_contractor                    =>     p_contractor
  ,p_employee                      =>     p_employee
  ,p_employment_category           =>     p_employment_category
  ,p_keywords                      =>     p_keywords
  ,p_travel_percentage             =>     p_travel_percentage
  ,p_min_salary                    =>     p_min_salary
  ,p_salary_currency               =>     p_salary_currency
  ,p_salary_period                 =>     p_salary_period
  ,p_match_competence              =>     p_match_competence
  ,p_match_qualification           =>     p_match_qualification
  ,p_work_at_home                  =>     p_work_at_home
  ,p_job_title                     =>     p_job_title
  ,p_department                    =>     p_department
  ,p_professional_area             =>     p_professional_area
  ,p_use_for_matching              =>     p_use_for_matching
  ,p_description                   =>     p_description
  ,p_attribute_category            =>     p_attribute_category
  ,p_attribute1                    =>     p_attribute1
  ,p_attribute2                    =>     p_attribute2
  ,p_attribute3                    =>     p_attribute3
  ,p_attribute4                    =>     p_attribute4
  ,p_attribute5                    =>     p_attribute5
  ,p_attribute6                    =>     p_attribute6
  ,p_attribute7                    =>     p_attribute7
  ,p_attribute8                    =>     p_attribute8
  ,p_attribute9                    =>     p_attribute9
  ,p_attribute10                   =>     p_attribute10
  ,p_attribute11                   =>     p_attribute11
  ,p_attribute12                   =>     p_attribute12
  ,p_attribute13                   =>     p_attribute13
  ,p_attribute14                   =>     p_attribute14
  ,p_attribute15                   =>     p_attribute15
  ,p_attribute16                   =>     p_attribute16
  ,p_attribute17                   =>     p_attribute17
  ,p_attribute18                   =>     p_attribute18
  ,p_attribute19                   =>     p_attribute19
  ,p_attribute20                   =>     p_attribute20
  ,p_attribute21                   =>     p_attribute21
  ,p_attribute22                   =>     p_attribute22
  ,p_attribute23                   =>     p_attribute23
  ,p_attribute24                   =>     p_attribute24
  ,p_attribute25                   =>     p_attribute25
  ,p_attribute26                   =>     p_attribute26
  ,p_attribute27                   =>     p_attribute27
  ,p_attribute28                   =>     p_attribute28
  ,p_attribute29                   =>     p_attribute29
  ,p_attribute30                   =>     p_attribute30
  ,p_isc_information_category      =>     p_isc_information_category
  ,p_isc_information1              =>     p_isc_information1
  ,p_isc_information2              =>     p_isc_information2
  ,p_isc_information3              =>     p_isc_information3
  ,p_isc_information4              =>     p_isc_information4
  ,p_isc_information5              =>     p_isc_information5
  ,p_isc_information6              =>     p_isc_information6
  ,p_isc_information7              =>     p_isc_information7
  ,p_isc_information8              =>     p_isc_information8
  ,p_isc_information9              =>     p_isc_information9
  ,p_isc_information10             =>     p_isc_information10
  ,p_isc_information11             =>     p_isc_information11
  ,p_isc_information12             =>     p_isc_information12
  ,p_isc_information13             =>     p_isc_information13
  ,p_isc_information14             =>     p_isc_information14
  ,p_isc_information15             =>     p_isc_information15
  ,p_isc_information16             =>     p_isc_information16
  ,p_isc_information17             =>     p_isc_information17
  ,p_isc_information18             =>     p_isc_information18
  ,p_isc_information19             =>     p_isc_information19
  ,p_isc_information20             =>     p_isc_information20
  ,p_isc_information21             =>     p_isc_information21
  ,p_isc_information22             =>     p_isc_information22
  ,p_isc_information23             =>     p_isc_information23
  ,p_isc_information24             =>     p_isc_information24
  ,p_isc_information25             =>     p_isc_information25
  ,p_isc_information26             =>     p_isc_information26
  ,p_isc_information27             =>     p_isc_information27
  ,p_isc_information28             =>     p_isc_information28
  ,p_isc_information29             =>     p_isc_information29
  ,p_isc_information30             =>     p_isc_information30
  ,p_date_posted                   =>     p_date_posted
  ,p_object_version_number         =>     l_object_version_number
  ,p_search_criteria_id         =>     l_search_criteria_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SAVED_SEARCH'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_search_criteria_id     := l_search_criteria_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_SAVED_SEARCH;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_search_criteria_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_search_criteria_id     := null;
    p_object_version_number  := null;
    rollback to CREATE_SAVED_SEARCH;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_SAVED_SEARCH;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_SAVED_SEARCH >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_SAVED_SEARCH
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_search_criteria_id            in     number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_search_name                   in     varchar2 default hr_api.g_varchar2
  ,p_location                      in     varchar2 default hr_api.g_varchar2
  ,p_distance_to_location          in     varchar2 default hr_api.g_varchar2
  ,p_geocode_location              in     varchar2 default hr_api.g_varchar2
  ,p_geocode_country               in     varchar2 default hr_api.g_varchar2
  ,p_derived_location              in     varchar2 default hr_api.g_varchar2
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_longitude                     in     number   default hr_api.g_number
  ,p_latitude                      in     number   default hr_api.g_number
  ,p_employee                      in     varchar2 default hr_api.g_varchar2
  ,p_contractor                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category           in     varchar2 default hr_api.g_varchar2
  ,p_keywords                      in     varchar2 default hr_api.g_varchar2
  ,p_travel_percentage             in     number   default hr_api.g_number
  ,p_min_salary                    in     number   default hr_api.g_number
  ,p_salary_currency               in     varchar2 default hr_api.g_varchar2
  ,p_salary_period                 in     varchar2 default hr_api.g_varchar2
  ,p_match_competence              in     varchar2 default hr_api.g_varchar2
  ,p_match_qualification           in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home                  in     varchar2 default hr_api.g_varchar2
  ,p_job_title                     in     varchar2 default hr_api.g_varchar2
  ,p_department                    in     varchar2 default hr_api.g_varchar2
  ,p_professional_area             in     varchar2 default hr_api.g_varchar2
  ,p_use_for_matching              in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
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
  ,p_isc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_isc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information30             in     varchar2 default hr_api.g_varchar2
  ,p_date_posted                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'UPDATE_SAVED_SEARCH';
  l_effective_date       date;
  l_object_version_number irc_search_criteria.object_version_number%TYPE
                         := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_SAVED_SEARCH;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK2.UPDATE_SAVED_SEARCH_B
  (p_effective_date             =>     l_effective_date
  ,p_search_criteria_id         =>     p_search_criteria_id
  ,p_person_id                  =>     p_person_id
  ,p_search_name                =>     p_search_name
  ,p_location                   =>     p_location
  ,p_distance_to_location       =>     p_distance_to_location
  ,p_geocode_location           =>     p_geocode_location
  ,p_geocode_country            =>     p_geocode_country
  ,p_derived_location           =>     p_derived_location
  ,p_location_id                =>     p_location_id
  ,p_longitude                  =>     p_longitude
  ,p_latitude                   =>     p_latitude
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_match_competence           =>     p_match_competence
  ,p_match_qualification        =>     p_match_qualification
  ,p_work_at_home               =>     p_work_at_home
  ,p_job_title                  =>     p_job_title
  ,p_department                 =>     p_department
  ,p_professional_area          =>     p_professional_area
  ,p_use_for_matching           =>     p_use_for_matching
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_date_posted                =>     p_date_posted
  ,p_object_version_number      =>     l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SAVED_SEARCH'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_upd.upd(
   p_effective_date             =>     l_effective_date
  ,p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_id                  =>     p_person_id
  ,p_object_type                =>     'PERSON'
  ,p_search_name                =>     p_search_name
  ,p_location                   =>     p_location
  ,p_distance_to_location       =>     p_distance_to_location
  ,p_geocode_location           =>     p_geocode_location
  ,p_geocode_country            =>     p_geocode_country
  ,p_derived_location           =>     p_derived_location
  ,p_location_id                =>     p_location_id
  ,p_longitude                  =>     p_longitude
  ,p_latitude                   =>     p_latitude
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_match_competence           =>     p_match_competence
  ,p_match_qualification        =>     p_match_qualification
  ,p_work_at_home               =>     p_work_at_home
  ,p_job_title                  =>     p_job_title
  ,p_department                 =>     p_department
  ,p_professional_area          =>     p_professional_area
  ,p_use_for_matching           =>     p_use_for_matching
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_date_posted                =>     p_date_posted
  ,p_object_version_number      =>     l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK2.UPDATE_SAVED_SEARCH_A
  (p_effective_date                =>     l_effective_date
  ,p_search_criteria_id            =>     p_search_criteria_id
  ,p_person_id                     =>     p_person_id
  ,p_search_name                   =>     p_search_name
  ,p_location                      =>     p_location
  ,p_distance_to_location          =>     p_distance_to_location
  ,p_geocode_location              =>     p_geocode_location
  ,p_geocode_country               =>     p_geocode_country
  ,p_derived_location              =>     p_derived_location
  ,p_location_id                   =>     p_location_id
  ,p_longitude                     =>     p_longitude
  ,p_latitude                      =>     p_latitude
  ,p_contractor                    =>     p_contractor
  ,p_employee                      =>     p_employee
  ,p_employment_category           =>     p_employment_category
  ,p_keywords                      =>     p_keywords
  ,p_travel_percentage             =>     p_travel_percentage
  ,p_min_salary                    =>     p_min_salary
  ,p_salary_currency               =>     p_salary_currency
  ,p_salary_period                 =>     p_salary_period
  ,p_match_competence              =>     p_match_competence
  ,p_match_qualification           =>     p_match_qualification
  ,p_work_at_home                  =>     p_work_at_home
  ,p_job_title                     =>     p_job_title
  ,p_department                    =>     p_department
  ,p_professional_area             =>     p_professional_area
  ,p_use_for_matching              =>     p_use_for_matching
  ,p_description                   =>     p_description
  ,p_attribute_category            =>     p_attribute_category
  ,p_attribute1                    =>     p_attribute1
  ,p_attribute2                    =>     p_attribute2
  ,p_attribute3                    =>     p_attribute3
  ,p_attribute4                    =>     p_attribute4
  ,p_attribute5                    =>     p_attribute5
  ,p_attribute6                    =>     p_attribute6
  ,p_attribute7                    =>     p_attribute7
  ,p_attribute8                    =>     p_attribute8
  ,p_attribute9                    =>     p_attribute9
  ,p_attribute10                   =>     p_attribute10
  ,p_attribute11                   =>     p_attribute11
  ,p_attribute12                   =>     p_attribute12
  ,p_attribute13                   =>     p_attribute13
  ,p_attribute14                   =>     p_attribute14
  ,p_attribute15                   =>     p_attribute15
  ,p_attribute16                   =>     p_attribute16
  ,p_attribute17                   =>     p_attribute17
  ,p_attribute18                   =>     p_attribute18
  ,p_attribute19                   =>     p_attribute19
  ,p_attribute20                   =>     p_attribute20
  ,p_attribute21                   =>     p_attribute21
  ,p_attribute22                   =>     p_attribute22
  ,p_attribute23                   =>     p_attribute23
  ,p_attribute24                   =>     p_attribute24
  ,p_attribute25                   =>     p_attribute25
  ,p_attribute26                   =>     p_attribute26
  ,p_attribute27                   =>     p_attribute27
  ,p_attribute28                   =>     p_attribute28
  ,p_attribute29                   =>     p_attribute29
  ,p_attribute30                   =>     p_attribute30
  ,p_isc_information_category      =>     p_isc_information_category
  ,p_isc_information1              =>     p_isc_information1
  ,p_isc_information2              =>     p_isc_information2
  ,p_isc_information3              =>     p_isc_information3
  ,p_isc_information4              =>     p_isc_information4
  ,p_isc_information5              =>     p_isc_information5
  ,p_isc_information6              =>     p_isc_information6
  ,p_isc_information7              =>     p_isc_information7
  ,p_isc_information8              =>     p_isc_information8
  ,p_isc_information9              =>     p_isc_information9
  ,p_isc_information10             =>     p_isc_information10
  ,p_isc_information11             =>     p_isc_information11
  ,p_isc_information12             =>     p_isc_information12
  ,p_isc_information13             =>     p_isc_information13
  ,p_isc_information14             =>     p_isc_information14
  ,p_isc_information15             =>     p_isc_information15
  ,p_isc_information16             =>     p_isc_information16
  ,p_isc_information17             =>     p_isc_information17
  ,p_isc_information18             =>     p_isc_information18
  ,p_isc_information19             =>     p_isc_information19
  ,p_isc_information20             =>     p_isc_information20
  ,p_isc_information21             =>     p_isc_information21
  ,p_isc_information22             =>     p_isc_information22
  ,p_isc_information23             =>     p_isc_information23
  ,p_isc_information24             =>     p_isc_information24
  ,p_isc_information25             =>     p_isc_information25
  ,p_isc_information26             =>     p_isc_information26
  ,p_isc_information27             =>     p_isc_information27
  ,p_isc_information28             =>     p_isc_information28
  ,p_isc_information29             =>     p_isc_information29
  ,p_isc_information30             =>     p_isc_information30
  ,p_date_posted                   =>     p_date_posted
  ,p_object_version_number         =>     l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SAVED_SEARCH'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_SAVED_SEARCH;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_SAVED_SEARCH;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_SAVED_SEARCH;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_SAVED_SEARCH >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_SAVED_SEARCH
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'DELETE_SAVED_SEARCH';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_SAVED_SEARCH;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK3.DELETE_SAVED_SEARCH_B
  (p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_version_number      =>     p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SAVED_SEARCH'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_del.del(
   p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_version_number      =>     p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK3.DELETE_SAVED_SEARCH_A
  (p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_version_number      =>     p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SAVED_SEARCH'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_SAVED_SEARCH;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_SAVED_SEARCH;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_SAVED_SEARCH;
--
-- ----------------------------------------------------------------------------
-- |------------------------< CREATE_VACANCY_CRITERIA >------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VACANCY_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_vacancy_id                    in     number
  ,p_effective_date                in     date
  ,p_location                      in     varchar2 default null
  ,p_employee                      in     varchar2 default null
  ,p_contractor                    in     varchar2 default null
  ,p_employment_category           in     varchar2 default null
  ,p_keywords                      in     varchar2 default null
  ,p_travel_percentage             in     number   default null
  ,p_min_salary                    in     number   default null
  ,p_max_salary                    in     number   default null
  ,p_salary_currency               in     varchar2 default null
  ,p_salary_period                 in     varchar2 default null
  ,p_professional_area             in     varchar2 default null
  ,p_work_at_home                  in     varchar2 default null
  ,p_min_qual_level                in     number   default null
  ,p_max_qual_level                in     number   default null
  ,p_description                   in     varchar2 default null
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
  ,p_isc_information_category      in     varchar2 default null
  ,p_isc_information1              in     varchar2 default null
  ,p_isc_information2              in     varchar2 default null
  ,p_isc_information3              in     varchar2 default null
  ,p_isc_information4              in     varchar2 default null
  ,p_isc_information5              in     varchar2 default null
  ,p_isc_information6              in     varchar2 default null
  ,p_isc_information7              in     varchar2 default null
  ,p_isc_information8              in     varchar2 default null
  ,p_isc_information9              in     varchar2 default null
  ,p_isc_information10             in     varchar2 default null
  ,p_isc_information11             in     varchar2 default null
  ,p_isc_information12             in     varchar2 default null
  ,p_isc_information13             in     varchar2 default null
  ,p_isc_information14             in     varchar2 default null
  ,p_isc_information15             in     varchar2 default null
  ,p_isc_information16             in     varchar2 default null
  ,p_isc_information17             in     varchar2 default null
  ,p_isc_information18             in     varchar2 default null
  ,p_isc_information19             in     varchar2 default null
  ,p_isc_information20             in     varchar2 default null
  ,p_isc_information21             in     varchar2 default null
  ,p_isc_information22             in     varchar2 default null
  ,p_isc_information23             in     varchar2 default null
  ,p_isc_information24             in     varchar2 default null
  ,p_isc_information25             in     varchar2 default null
  ,p_isc_information26             in     varchar2 default null
  ,p_isc_information27             in     varchar2 default null
  ,p_isc_information28             in     varchar2 default null
  ,p_isc_information29             in     varchar2 default null
  ,p_isc_information30             in     varchar2 default null
  ,p_object_version_number           out nocopy  number
  ,p_search_criteria_id              out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'CREATE_VACANCY_CRITERIA';
  l_object_version_number irc_search_criteria.object_version_number%TYPE;
  l_search_criteria_id    irc_search_criteria.search_criteria_id%TYPE;
  l_effective_date       date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_VACANCY_CRITERIA;
  --
  -- Truncate the time portion from all IN date parameters
  l_effective_date := trunc(p_effective_date);
  --
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK4.CREATE_VACANCY_CRITERIA_B
  (p_vacancy_id                 =>     p_vacancy_id
  ,p_effective_date             =>     l_effective_date
  ,p_location                   =>     p_location
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_max_salary                 =>     p_max_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_professional_area          =>     p_professional_area
  ,p_work_at_home               =>     p_work_at_home
  ,p_min_qual_level             =>     p_min_qual_level
  ,p_max_qual_level             =>     p_max_qual_level
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VACANCY_CRITERIA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_ins.ins(
   p_effective_date             =>     l_effective_date
  ,p_object_id                  =>     p_vacancy_id
  ,p_object_type                =>     'VACANCY'
  ,p_location                   =>     p_location
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_max_salary                 =>     p_max_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_professional_area          =>     p_professional_area
  ,p_work_at_home               =>     p_work_at_home
  ,p_min_qual_level             =>     p_min_qual_level
  ,p_max_qual_level             =>     p_max_qual_level
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  ,p_search_criteria_id         =>     l_search_criteria_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK4.CREATE_VACANCY_CRITERIA_A
  (p_vacancy_id                 =>     p_vacancy_id
  ,p_effective_date             =>     l_effective_date
  ,p_location                   =>     p_location
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_max_salary                 =>     p_max_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_professional_area          =>     p_professional_area
  ,p_work_at_home               =>     p_work_at_home
  ,p_min_qual_level             =>     p_min_qual_level
  ,p_max_qual_level             =>     p_max_qual_level
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  ,p_search_criteria_id         =>     l_search_criteria_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VACANCY_CRITERIA'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_search_criteria_id     := l_search_criteria_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_VACANCY_CRITERIA;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_search_criteria_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_search_criteria_id     := null;
    p_object_version_number  := null;
    rollback to CREATE_VACANCY_CRITERIA;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_VACANCY_CRITERIA;
--
-- ----------------------------------------------------------------------------
-- |------------------------< UPDATE_VACANCY_CRITERIA >------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_VACANCY_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_vacancy_id                    in     number   default hr_api.g_number
  ,p_effective_date                in     date
  ,p_location                      in     varchar2 default hr_api.g_varchar2
  ,p_employee                      in     varchar2 default hr_api.g_varchar2
  ,p_contractor                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category           in     varchar2 default hr_api.g_varchar2
  ,p_keywords                      in     varchar2 default hr_api.g_varchar2
  ,p_travel_percentage             in     number   default hr_api.g_number
  ,p_min_salary                    in     number   default hr_api.g_number
  ,p_max_salary                    in     number   default hr_api.g_number
  ,p_salary_currency               in     varchar2 default hr_api.g_varchar2
  ,p_salary_period                 in     varchar2 default hr_api.g_varchar2
  ,p_professional_area             in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home                  in     varchar2 default hr_api.g_varchar2
  ,p_min_qual_level                in     number   default hr_api.g_number
  ,p_max_qual_level                in     number   default hr_api.g_number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
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
  ,p_isc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_isc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information30             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'UPDATE_VACANCY_CRITERIA';
  l_object_version_number irc_search_criteria.object_version_number%TYPE
                         := p_object_version_number;
  l_effective_date       date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_VACANCY_CRITERIA;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK5.UPDATE_VACANCY_CRITERIA_B
  (p_vacancy_id                 =>     p_vacancy_id
  ,p_search_criteria_id         =>     p_search_criteria_id
  ,p_effective_date             =>     l_effective_date
  ,p_location                   =>     p_location
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_max_salary                 =>     p_max_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_professional_area          =>     p_professional_area
  ,p_work_at_home               =>     p_work_at_home
  ,p_min_qual_level             =>     p_min_qual_level
  ,p_max_qual_level             =>     p_max_qual_level
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_VACANCY_CRITERIA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_upd.upd(
   p_effective_date             =>     l_effective_date
  ,p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_id                  =>     p_vacancy_id
  ,p_object_type                =>     'VACANCY'
  ,p_location                   =>     p_location
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_max_salary                 =>     p_max_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_professional_area          =>     p_professional_area
  ,p_work_at_home               =>     p_work_at_home
  ,p_min_qual_level             =>     p_min_qual_level
  ,p_max_qual_level             =>     p_max_qual_level
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK5.UPDATE_VACANCY_CRITERIA_A
  (p_vacancy_id                 =>     p_vacancy_id
  ,p_search_criteria_id         =>     p_search_criteria_id
  ,p_effective_date             =>     l_effective_date
  ,p_location                   =>     p_location
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_max_salary                 =>     p_max_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_professional_area          =>     p_professional_area
  ,p_work_at_home               =>     p_work_at_home
  ,p_min_qual_level             =>     p_min_qual_level
  ,p_max_qual_level             =>     p_max_qual_level
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_VACANCY_CRITERIA'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_VACANCY_CRITERIA;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_VACANCY_CRITERIA;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_VACANCY_CRITERIA;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_VACANCY_CRITERIA >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VACANCY_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'DELETE_VACANCY_CRITERIA';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_VACANCY_CRITERIA;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
 IRC_SEARCH_CRITERIA_BK6.DELETE_VACANCY_CRITERIA_B
  (p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_version_number      =>     p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VACANCY_CRITERIA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_del.del(
    p_search_criteria_id         =>     p_search_criteria_id
   ,p_object_version_number      =>     p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK6.DELETE_VACANCY_CRITERIA_A
  (p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_version_number      =>     p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VACANCY_CRITERIA'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_VACANCY_CRITERIA;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_VACANCY_CRITERIA;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_VACANCY_CRITERIA;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_WORK_CHOICES >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_WORK_CHOICES
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_location                      in     varchar2 default null
  ,p_distance_to_location          in     varchar2 default null
  ,p_geocode_location              in     varchar2 default null
  ,p_geocode_country               in     varchar2 default null
  ,p_derived_location              in     varchar2 default null
  ,p_location_id                   in     number   default null
  ,p_longitude                     in     number   default null
  ,p_latitude                      in     number   default null
  ,p_employee                      in     varchar2 default null
  ,p_contractor                    in     varchar2 default null
  ,p_employment_category           in     varchar2 default 'EITHER'
  ,p_keywords                      in     varchar2 default null
  ,p_travel_percentage             in     number   default null
  ,p_min_salary                    in     number   default null
  ,p_salary_currency               in     varchar2 default null
  ,p_salary_period                 in     varchar2 default null
  ,p_match_competence              in     varchar2 default 'N'
  ,p_match_qualification           in     varchar2 default 'N'
  ,p_work_at_home                  in     varchar2 default 'POSSIBLE'
  ,p_job_title                     in     varchar2 default null
  ,p_department                    in     varchar2 default null
  ,p_professional_area             in     varchar2 default null
  ,p_description                   in     varchar2 default null
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
  ,p_isc_information_category      in     varchar2 default null
  ,p_isc_information1              in     varchar2 default null
  ,p_isc_information2              in     varchar2 default null
  ,p_isc_information3              in     varchar2 default null
  ,p_isc_information4              in     varchar2 default null
  ,p_isc_information5              in     varchar2 default null
  ,p_isc_information6              in     varchar2 default null
  ,p_isc_information7              in     varchar2 default null
  ,p_isc_information8              in     varchar2 default null
  ,p_isc_information9              in     varchar2 default null
  ,p_isc_information10             in     varchar2 default null
  ,p_isc_information11             in     varchar2 default null
  ,p_isc_information12             in     varchar2 default null
  ,p_isc_information13             in     varchar2 default null
  ,p_isc_information14             in     varchar2 default null
  ,p_isc_information15             in     varchar2 default null
  ,p_isc_information16             in     varchar2 default null
  ,p_isc_information17             in     varchar2 default null
  ,p_isc_information18             in     varchar2 default null
  ,p_isc_information19             in     varchar2 default null
  ,p_isc_information20             in     varchar2 default null
  ,p_isc_information21             in     varchar2 default null
  ,p_isc_information22             in     varchar2 default null
  ,p_isc_information23             in     varchar2 default null
  ,p_isc_information24             in     varchar2 default null
  ,p_isc_information25             in     varchar2 default null
  ,p_isc_information26             in     varchar2 default null
  ,p_isc_information27             in     varchar2 default null
  ,p_isc_information28             in     varchar2 default null
  ,p_isc_information29             in     varchar2 default null
  ,p_isc_information30             in     varchar2 default null
  ,p_object_version_number           out nocopy  number
  ,p_search_criteria_id              out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'CREATE_WORK_CHOICES';
  l_effective_date       date;
  l_object_version_number irc_search_criteria.object_version_number%TYPE;
  l_search_criteria_id    irc_search_criteria.search_criteria_id%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_WORK_CHOICES;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK7.CREATE_WORK_CHOICES_B
  (p_effective_date             =>     l_effective_date
  ,p_person_id                  =>     p_person_id
  ,p_location                   =>     p_location
  ,p_distance_to_location       =>     p_distance_to_location
  ,p_geocode_location           =>     p_geocode_location
  ,p_geocode_country            =>     p_geocode_country
  ,p_derived_location           =>     p_derived_location
  ,p_location_id                =>     p_location_id
  ,p_longitude                  =>     p_longitude
  ,p_latitude                   =>     p_latitude
  ,p_employee                   =>     p_employee
  ,p_contractor                 =>     p_contractor
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_match_competence           =>     p_match_competence
  ,p_match_qualification        =>     p_match_qualification
  ,p_work_at_home               =>     p_work_at_home
  ,p_job_title                  =>     p_job_title
  ,p_department                 =>     p_department
  ,p_professional_area          =>     p_professional_area
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_WORK_CHOICES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_ins.ins(
   p_effective_date             =>     l_effective_date
  ,p_object_id                  =>     p_person_id
  ,p_object_type                =>     'WPREF'
  ,p_location                   =>     p_location
  ,p_distance_to_location       =>     p_distance_to_location
  ,p_geocode_location           =>     p_geocode_location
  ,p_geocode_country            =>     p_geocode_country
  ,p_derived_location           =>     p_derived_location
  ,p_location_id                =>     p_location_id
  ,p_longitude                  =>     p_longitude
  ,p_latitude                   =>     p_latitude
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_match_competence           =>     p_match_competence
  ,p_match_qualification        =>     p_match_qualification
  ,p_work_at_home               =>     p_work_at_home
  ,p_job_title                  =>     p_job_title
  ,p_department                 =>     p_department
  ,p_professional_area          =>     p_professional_area
  ,p_use_for_matching           =>     'Y'
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  ,p_search_criteria_id         =>     l_search_criteria_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK7.CREATE_WORK_CHOICES_A
  (p_effective_date                =>     l_effective_date
  ,p_person_id                     =>     p_person_id
  ,p_location                      =>     p_location
  ,p_distance_to_location          =>     p_distance_to_location
  ,p_geocode_location              =>     p_geocode_location
  ,p_geocode_country               =>     p_geocode_country
  ,p_derived_location              =>     p_derived_location
  ,p_location_id                   =>     p_location_id
  ,p_longitude                     =>     p_longitude
  ,p_latitude                      =>     p_latitude
  ,p_contractor                    =>     p_contractor
  ,p_employee                      =>     p_employee
  ,p_employment_category           =>     p_employment_category
  ,p_keywords                      =>     p_keywords
  ,p_travel_percentage             =>     p_travel_percentage
  ,p_min_salary                    =>     p_min_salary
  ,p_salary_currency               =>     p_salary_currency
  ,p_salary_period                 =>     p_salary_period
  ,p_match_competence              =>     p_match_competence
  ,p_match_qualification           =>     p_match_qualification
  ,p_work_at_home                  =>     p_work_at_home
  ,p_job_title                     =>     p_job_title
  ,p_department                    =>     p_department
  ,p_professional_area             =>     p_professional_area
  ,p_description                   =>     p_description
  ,p_attribute_category            =>     p_attribute_category
  ,p_attribute1                    =>     p_attribute1
  ,p_attribute2                    =>     p_attribute2
  ,p_attribute3                    =>     p_attribute3
  ,p_attribute4                    =>     p_attribute4
  ,p_attribute5                    =>     p_attribute5
  ,p_attribute6                    =>     p_attribute6
  ,p_attribute7                    =>     p_attribute7
  ,p_attribute8                    =>     p_attribute8
  ,p_attribute9                    =>     p_attribute9
  ,p_attribute10                   =>     p_attribute10
  ,p_attribute11                   =>     p_attribute11
  ,p_attribute12                   =>     p_attribute12
  ,p_attribute13                   =>     p_attribute13
  ,p_attribute14                   =>     p_attribute14
  ,p_attribute15                   =>     p_attribute15
  ,p_attribute16                   =>     p_attribute16
  ,p_attribute17                   =>     p_attribute17
  ,p_attribute18                   =>     p_attribute18
  ,p_attribute19                   =>     p_attribute19
  ,p_attribute20                   =>     p_attribute20
  ,p_attribute21                   =>     p_attribute21
  ,p_attribute22                   =>     p_attribute22
  ,p_attribute23                   =>     p_attribute23
  ,p_attribute24                   =>     p_attribute24
  ,p_attribute25                   =>     p_attribute25
  ,p_attribute26                   =>     p_attribute26
  ,p_attribute27                   =>     p_attribute27
  ,p_attribute28                   =>     p_attribute28
  ,p_attribute29                   =>     p_attribute29
  ,p_attribute30                   =>     p_attribute30
  ,p_isc_information_category      =>     p_isc_information_category
  ,p_isc_information1              =>     p_isc_information1
  ,p_isc_information2              =>     p_isc_information2
  ,p_isc_information3              =>     p_isc_information3
  ,p_isc_information4              =>     p_isc_information4
  ,p_isc_information5              =>     p_isc_information5
  ,p_isc_information6              =>     p_isc_information6
  ,p_isc_information7              =>     p_isc_information7
  ,p_isc_information8              =>     p_isc_information8
  ,p_isc_information9              =>     p_isc_information9
  ,p_isc_information10             =>     p_isc_information10
  ,p_isc_information11             =>     p_isc_information11
  ,p_isc_information12             =>     p_isc_information12
  ,p_isc_information13             =>     p_isc_information13
  ,p_isc_information14             =>     p_isc_information14
  ,p_isc_information15             =>     p_isc_information15
  ,p_isc_information16             =>     p_isc_information16
  ,p_isc_information17             =>     p_isc_information17
  ,p_isc_information18             =>     p_isc_information18
  ,p_isc_information19             =>     p_isc_information19
  ,p_isc_information20             =>     p_isc_information20
  ,p_isc_information21             =>     p_isc_information21
  ,p_isc_information22             =>     p_isc_information22
  ,p_isc_information23             =>     p_isc_information23
  ,p_isc_information24             =>     p_isc_information24
  ,p_isc_information25             =>     p_isc_information25
  ,p_isc_information26             =>     p_isc_information26
  ,p_isc_information27             =>     p_isc_information27
  ,p_isc_information28             =>     p_isc_information28
  ,p_isc_information29             =>     p_isc_information29
  ,p_isc_information30             =>     p_isc_information30
  ,p_object_version_number         =>     l_object_version_number
  ,p_search_criteria_id         =>     l_search_criteria_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_WORK_CHOICES'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_search_criteria_id     := l_search_criteria_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_WORK_CHOICES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_search_criteria_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_search_criteria_id     := null;
    p_object_version_number  := null;
    rollback to CREATE_WORK_CHOICES;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_WORK_CHOICES;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_WORK_CHOICES >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_WORK_CHOICES
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_search_criteria_id            in     number
  ,p_location                      in     varchar2 default hr_api.g_varchar2
  ,p_distance_to_location          in     varchar2 default hr_api.g_varchar2
  ,p_geocode_location              in     varchar2 default hr_api.g_varchar2
  ,p_geocode_country               in     varchar2 default hr_api.g_varchar2
  ,p_derived_location              in     varchar2 default hr_api.g_varchar2
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_longitude                     in     number   default hr_api.g_number
  ,p_latitude                      in     number   default hr_api.g_number
  ,p_employee                      in     varchar2 default hr_api.g_varchar2
  ,p_contractor                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category           in     varchar2 default hr_api.g_varchar2
  ,p_keywords                      in     varchar2 default hr_api.g_varchar2
  ,p_travel_percentage             in     number   default hr_api.g_number
  ,p_min_salary                    in     number   default hr_api.g_number
  ,p_salary_currency               in     varchar2 default hr_api.g_varchar2
  ,p_salary_period                 in     varchar2 default hr_api.g_varchar2
  ,p_match_competence              in     varchar2 default hr_api.g_varchar2
  ,p_match_qualification           in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home                  in     varchar2 default hr_api.g_varchar2
  ,p_job_title                     in     varchar2 default hr_api.g_varchar2
  ,p_department                    in     varchar2 default hr_api.g_varchar2
  ,p_professional_area             in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
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
  ,p_isc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_isc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information30             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'UPDATE_WORK_CHOICES';
  l_effective_date       date;
  l_object_version_number irc_search_criteria.object_version_number%TYPE
                         := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_WORK_CHOICES;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK8.UPDATE_WORK_CHOICES_B
  (p_effective_date             =>     l_effective_date
  ,p_search_criteria_id         =>     p_search_criteria_id
  ,p_location                   =>     p_location
  ,p_distance_to_location       =>     p_distance_to_location
  ,p_geocode_location           =>     p_geocode_location
  ,p_geocode_country            =>     p_geocode_country
  ,p_derived_location           =>     p_derived_location
  ,p_location_id                =>     p_location_id
  ,p_longitude                  =>     p_longitude
  ,p_latitude                   =>     p_latitude
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_match_competence           =>     p_match_competence
  ,p_match_qualification        =>     p_match_qualification
  ,p_work_at_home               =>     p_work_at_home
  ,p_job_title                  =>     p_job_title
  ,p_department                 =>     p_department
  ,p_professional_area          =>     p_professional_area
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORK_CHOICES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_upd.upd(
   p_effective_date             =>     l_effective_date
  ,p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_type                =>     'WPREF'
  ,p_location                   =>     p_location
  ,p_distance_to_location       =>     p_distance_to_location
  ,p_geocode_location           =>     p_geocode_location
  ,p_geocode_country            =>     p_geocode_country
  ,p_derived_location           =>     p_derived_location
  ,p_location_id                =>     p_location_id
  ,p_longitude                  =>     p_longitude
  ,p_latitude                   =>     p_latitude
  ,p_contractor                 =>     p_contractor
  ,p_employee                   =>     p_employee
  ,p_employment_category        =>     p_employment_category
  ,p_keywords                   =>     p_keywords
  ,p_travel_percentage          =>     p_travel_percentage
  ,p_min_salary                 =>     p_min_salary
  ,p_salary_currency            =>     p_salary_currency
  ,p_salary_period              =>     p_salary_period
  ,p_match_competence           =>     p_match_competence
  ,p_match_qualification        =>     p_match_qualification
  ,p_work_at_home               =>     p_work_at_home
  ,p_job_title                  =>     p_job_title
  ,p_department                 =>     p_department
  ,p_professional_area          =>     p_professional_area
  ,p_description                =>     p_description
  ,p_attribute_category         =>     p_attribute_category
  ,p_attribute1                 =>     p_attribute1
  ,p_attribute2                 =>     p_attribute2
  ,p_attribute3                 =>     p_attribute3
  ,p_attribute4                 =>     p_attribute4
  ,p_attribute5                 =>     p_attribute5
  ,p_attribute6                 =>     p_attribute6
  ,p_attribute7                 =>     p_attribute7
  ,p_attribute8                 =>     p_attribute8
  ,p_attribute9                 =>     p_attribute9
  ,p_attribute10                =>     p_attribute10
  ,p_attribute11                =>     p_attribute11
  ,p_attribute12                =>     p_attribute12
  ,p_attribute13                =>     p_attribute13
  ,p_attribute14                =>     p_attribute14
  ,p_attribute15                =>     p_attribute15
  ,p_attribute16                =>     p_attribute16
  ,p_attribute17                =>     p_attribute17
  ,p_attribute18                =>     p_attribute18
  ,p_attribute19                =>     p_attribute19
  ,p_attribute20                =>     p_attribute20
  ,p_attribute21                =>     p_attribute21
  ,p_attribute22                =>     p_attribute22
  ,p_attribute23                =>     p_attribute23
  ,p_attribute24                =>     p_attribute24
  ,p_attribute25                =>     p_attribute25
  ,p_attribute26                =>     p_attribute26
  ,p_attribute27                =>     p_attribute27
  ,p_attribute28                =>     p_attribute28
  ,p_attribute29                =>     p_attribute29
  ,p_attribute30                =>     p_attribute30
  ,p_isc_information_category   =>     p_isc_information_category
  ,p_isc_information1           =>     p_isc_information1
  ,p_isc_information2           =>     p_isc_information2
  ,p_isc_information3           =>     p_isc_information3
  ,p_isc_information4           =>     p_isc_information4
  ,p_isc_information5           =>     p_isc_information5
  ,p_isc_information6           =>     p_isc_information6
  ,p_isc_information7           =>     p_isc_information7
  ,p_isc_information8           =>     p_isc_information8
  ,p_isc_information9           =>     p_isc_information9
  ,p_isc_information10          =>     p_isc_information10
  ,p_isc_information11          =>     p_isc_information11
  ,p_isc_information12          =>     p_isc_information12
  ,p_isc_information13          =>     p_isc_information13
  ,p_isc_information14          =>     p_isc_information14
  ,p_isc_information15          =>     p_isc_information15
  ,p_isc_information16          =>     p_isc_information16
  ,p_isc_information17          =>     p_isc_information17
  ,p_isc_information18          =>     p_isc_information18
  ,p_isc_information19          =>     p_isc_information19
  ,p_isc_information20          =>     p_isc_information20
  ,p_isc_information21          =>     p_isc_information21
  ,p_isc_information22          =>     p_isc_information22
  ,p_isc_information23          =>     p_isc_information23
  ,p_isc_information24          =>     p_isc_information24
  ,p_isc_information25          =>     p_isc_information25
  ,p_isc_information26          =>     p_isc_information26
  ,p_isc_information27          =>     p_isc_information27
  ,p_isc_information28          =>     p_isc_information28
  ,p_isc_information29          =>     p_isc_information29
  ,p_isc_information30          =>     p_isc_information30
  ,p_object_version_number      =>     l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK8.UPDATE_WORK_CHOICES_A
  (p_effective_date                =>     l_effective_date
  ,p_search_criteria_id            =>     p_search_criteria_id
  ,p_location                      =>     p_location
  ,p_distance_to_location          =>     p_distance_to_location
  ,p_geocode_location              =>     p_geocode_location
  ,p_geocode_country               =>     p_geocode_country
  ,p_derived_location              =>     p_derived_location
  ,p_location_id                   =>     p_location_id
  ,p_longitude                     =>     p_longitude
  ,p_latitude                      =>     p_latitude
  ,p_contractor                    =>     p_contractor
  ,p_employee                      =>     p_employee
  ,p_employment_category           =>     p_employment_category
  ,p_keywords                      =>     p_keywords
  ,p_travel_percentage             =>     p_travel_percentage
  ,p_min_salary                    =>     p_min_salary
  ,p_salary_currency               =>     p_salary_currency
  ,p_salary_period                 =>     p_salary_period
  ,p_match_competence              =>     p_match_competence
  ,p_match_qualification           =>     p_match_qualification
  ,p_work_at_home                  =>     p_work_at_home
  ,p_job_title                     =>     p_job_title
  ,p_department                    =>     p_department
  ,p_professional_area             =>     p_professional_area
  ,p_description                   =>     p_description
  ,p_attribute_category            =>     p_attribute_category
  ,p_attribute1                    =>     p_attribute1
  ,p_attribute2                    =>     p_attribute2
  ,p_attribute3                    =>     p_attribute3
  ,p_attribute4                    =>     p_attribute4
  ,p_attribute5                    =>     p_attribute5
  ,p_attribute6                    =>     p_attribute6
  ,p_attribute7                    =>     p_attribute7
  ,p_attribute8                    =>     p_attribute8
  ,p_attribute9                    =>     p_attribute9
  ,p_attribute10                   =>     p_attribute10
  ,p_attribute11                   =>     p_attribute11
  ,p_attribute12                   =>     p_attribute12
  ,p_attribute13                   =>     p_attribute13
  ,p_attribute14                   =>     p_attribute14
  ,p_attribute15                   =>     p_attribute15
  ,p_attribute16                   =>     p_attribute16
  ,p_attribute17                   =>     p_attribute17
  ,p_attribute18                   =>     p_attribute18
  ,p_attribute19                   =>     p_attribute19
  ,p_attribute20                   =>     p_attribute20
  ,p_attribute21                   =>     p_attribute21
  ,p_attribute22                   =>     p_attribute22
  ,p_attribute23                   =>     p_attribute23
  ,p_attribute24                   =>     p_attribute24
  ,p_attribute25                   =>     p_attribute25
  ,p_attribute26                   =>     p_attribute26
  ,p_attribute27                   =>     p_attribute27
  ,p_attribute28                   =>     p_attribute28
  ,p_attribute29                   =>     p_attribute29
  ,p_attribute30                   =>     p_attribute30
  ,p_isc_information_category      =>     p_isc_information_category
  ,p_isc_information1              =>     p_isc_information1
  ,p_isc_information2              =>     p_isc_information2
  ,p_isc_information3              =>     p_isc_information3
  ,p_isc_information4              =>     p_isc_information4
  ,p_isc_information5              =>     p_isc_information5
  ,p_isc_information6              =>     p_isc_information6
  ,p_isc_information7              =>     p_isc_information7
  ,p_isc_information8              =>     p_isc_information8
  ,p_isc_information9              =>     p_isc_information9
  ,p_isc_information10             =>     p_isc_information10
  ,p_isc_information11             =>     p_isc_information11
  ,p_isc_information12             =>     p_isc_information12
  ,p_isc_information13             =>     p_isc_information13
  ,p_isc_information14             =>     p_isc_information14
  ,p_isc_information15             =>     p_isc_information15
  ,p_isc_information16             =>     p_isc_information16
  ,p_isc_information17             =>     p_isc_information17
  ,p_isc_information18             =>     p_isc_information18
  ,p_isc_information19             =>     p_isc_information19
  ,p_isc_information20             =>     p_isc_information20
  ,p_isc_information21             =>     p_isc_information21
  ,p_isc_information22             =>     p_isc_information22
  ,p_isc_information23             =>     p_isc_information23
  ,p_isc_information24             =>     p_isc_information24
  ,p_isc_information25             =>     p_isc_information25
  ,p_isc_information26             =>     p_isc_information26
  ,p_isc_information27             =>     p_isc_information27
  ,p_isc_information28             =>     p_isc_information28
  ,p_isc_information29             =>     p_isc_information29
  ,p_isc_information30             =>     p_isc_information30
  ,p_object_version_number         =>     l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORK_CHOICES'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_WORK_CHOICES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_WORK_CHOICES;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_WORK_CHOICES;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_WORK_CHOICES >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_WORK_CHOICES
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'DELETE_WORK_CHOICES';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_WORK_CHOICES;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK9.DELETE_WORK_CHOICES_B
  (p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_version_number      =>     p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORK_CHOICES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_isc_del.del(
   p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_version_number      =>     p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  IRC_SEARCH_CRITERIA_BK9.DELETE_WORK_CHOICES_A
  (p_search_criteria_id         =>     p_search_criteria_id
  ,p_object_version_number      =>     p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORK_CHOICES'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_WORK_CHOICES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_WORK_CHOICES;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_WORK_CHOICES;
--
end IRC_SEARCH_CRITERIA_API;

/
