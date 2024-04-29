--------------------------------------------------------
--  DDL for Package Body PER_DISABILITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DISABILITY_API" as
/* $Header: pedisapi.pkb 115.5 2002/12/10 16:32:02 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_disability_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_disability >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_disability
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_category                      in     varchar2
  ,p_status                        in     varchar2
  ,p_quota_fte                     in     number   default 1.00
  ,p_organization_id               in     number   default null
  ,p_registration_id               in     varchar2 default null
  ,p_registration_date             in     date     default null
  ,p_registration_exp_date         in     date     default null
  ,p_description                   in     varchar2 default null
  ,p_degree                        in     number   default null
  ,p_reason                        in     varchar2 default null
  ,p_work_restriction              in     varchar2 default null
  ,p_incident_id                   in     number   default null
  ,p_medical_assessment_id         in     number   default null
  ,p_pre_registration_job          in     varchar2 default null
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
  ,p_dis_information_category      in     varchar2 default null
  ,p_dis_information1              in     varchar2 default null
  ,p_dis_information2              in     varchar2 default null
  ,p_dis_information3              in     varchar2 default null
  ,p_dis_information4              in     varchar2 default null
  ,p_dis_information5              in     varchar2 default null
  ,p_dis_information6              in     varchar2 default null
  ,p_dis_information7              in     varchar2 default null
  ,p_dis_information8              in     varchar2 default null
  ,p_dis_information9              in     varchar2 default null
  ,p_dis_information10             in     varchar2 default null
  ,p_dis_information11             in     varchar2 default null
  ,p_dis_information12             in     varchar2 default null
  ,p_dis_information13             in     varchar2 default null
  ,p_dis_information14             in     varchar2 default null
  ,p_dis_information15             in     varchar2 default null
  ,p_dis_information16             in     varchar2 default null
  ,p_dis_information17             in     varchar2 default null
  ,p_dis_information18             in     varchar2 default null
  ,p_dis_information19             in     varchar2 default null
  ,p_dis_information20             in     varchar2 default null
  ,p_dis_information21             in     varchar2 default null
  ,p_dis_information22             in     varchar2 default null
  ,p_dis_information23             in     varchar2 default null
  ,p_dis_information24             in     varchar2 default null
  ,p_dis_information25             in     varchar2 default null
  ,p_dis_information26             in     varchar2 default null
  ,p_dis_information27             in     varchar2 default null
  ,p_dis_information28             in     varchar2 default null
  ,p_dis_information29             in     varchar2 default null
  ,p_dis_information30             in     varchar2 default null
  ,p_disability_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                     varchar2(72) := g_package||'create_disability';
  l_disability_id            per_disabilities_f.disability_id%TYPE;
  l_object_version_number    per_disabilities_f.object_version_number%TYPE;
  l_object_version_number1   per_medical_assessments.object_version_number%TYPE;
  l_effective_date           date;
  l_effective_start_date     per_disabilities_f.effective_start_date%TYPE;
  l_effective_end_date       per_disabilities_f.effective_end_date%TYPE;
  l_registration_date        per_disabilities_f.registration_date%TYPE;
  l_registration_exp_date    per_disabilities_f.registration_exp_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_disability;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_registration_date := trunc(p_registration_date);
  l_registration_exp_date := trunc(p_registration_exp_date);

  --
  -- Call Before Process User Hook
  --
  begin
    per_disability_api_bk1.create_disability_b
       (p_effective_date                => l_effective_date
       ,p_person_id                     => p_person_id
       ,p_category                      => p_category
       ,p_status                        => p_status
       ,p_quota_fte                     => p_quota_fte
       ,p_organization_id               => p_organization_id
       ,p_registration_id               => p_registration_id
       ,p_registration_date             => l_registration_date
       ,p_registration_exp_date         => l_registration_exp_date
       ,p_description                   => p_description
       ,p_degree                        => p_degree
       ,p_reason                        => p_reason
       ,p_work_restriction              => p_work_restriction
       ,p_incident_id                   => p_incident_id
       ,p_pre_registration_job          => p_pre_registration_job
       ,p_attribute_category            => p_attribute_category
       ,p_attribute1                    => p_attribute1
       ,p_attribute2                    => p_attribute2
       ,p_attribute3                    => p_attribute3
       ,p_attribute4                    => p_attribute4
       ,p_attribute5                    => p_attribute5
       ,p_attribute6                    => p_attribute6
       ,p_attribute7                    => p_attribute7
       ,p_attribute8                    => p_attribute8
       ,p_attribute9                    => p_attribute9
       ,p_attribute10                   => p_attribute10
       ,p_attribute11                   => p_attribute11
       ,p_attribute12                   => p_attribute12
       ,p_attribute13                   => p_attribute13
       ,p_attribute14                   => p_attribute14
       ,p_attribute15                   => p_attribute15
       ,p_attribute16                   => p_attribute16
       ,p_attribute17                   => p_attribute17
       ,p_attribute18                   => p_attribute18
       ,p_attribute19                   => p_attribute19
       ,p_attribute20                   => p_attribute20
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       ,p_dis_information_category      => p_dis_information_category
       ,p_dis_information1              => p_dis_information1
       ,p_dis_information2              => p_dis_information2
       ,p_dis_information3              => p_dis_information3
       ,p_dis_information4              => p_dis_information4
       ,p_dis_information5              => p_dis_information5
       ,p_dis_information6              => p_dis_information6
       ,p_dis_information7              => p_dis_information7
       ,p_dis_information8              => p_dis_information8
       ,p_dis_information9              => p_dis_information9
       ,p_dis_information10             => p_dis_information10
       ,p_dis_information11             => p_dis_information11
       ,p_dis_information12             => p_dis_information12
       ,p_dis_information13             => p_dis_information13
       ,p_dis_information14             => p_dis_information14
       ,p_dis_information15             => p_dis_information15
       ,p_dis_information16             => p_dis_information16
       ,p_dis_information17             => p_dis_information17
       ,p_dis_information18             => p_dis_information18
       ,p_dis_information19             => p_dis_information19
       ,p_dis_information20             => p_dis_information20
       ,p_dis_information21             => p_dis_information21
       ,p_dis_information22             => p_dis_information22
       ,p_dis_information23             => p_dis_information23
       ,p_dis_information24             => p_dis_information24
       ,p_dis_information25             => p_dis_information25
       ,p_dis_information26             => p_dis_information26
       ,p_dis_information27             => p_dis_information27
       ,p_dis_information28             => p_dis_information28
       ,p_dis_information29             => p_dis_information29
       ,p_dis_information30             => p_dis_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_disability_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- check person type the disability is allowd to be created for...
  --
  -- Process Logic
  --
per_dis_ins.ins
       (p_effective_date                => l_effective_date
       ,p_person_id                     => p_person_id
       ,p_category                      => p_category
       ,p_status                        => p_status
       ,p_quota_fte                     => p_quota_fte
       ,p_organization_id               => p_organization_id
       ,p_registration_id               => p_registration_id
       ,p_registration_date             => l_registration_date
       ,p_registration_exp_date         => l_registration_exp_date
       ,p_description                   => p_description
       ,p_degree                        => p_degree
       ,p_reason                        => p_reason
       ,p_work_restriction              => p_work_restriction
       ,p_incident_id                   => p_incident_id
       ,p_pre_registration_job          => p_pre_registration_job
       ,p_attribute_category            => p_attribute_category
       ,p_attribute1                    => p_attribute1
       ,p_attribute2                    => p_attribute2
       ,p_attribute3                    => p_attribute3
       ,p_attribute4                    => p_attribute4
       ,p_attribute5                    => p_attribute5
       ,p_attribute6                    => p_attribute6
       ,p_attribute7                    => p_attribute7
       ,p_attribute8                    => p_attribute8
       ,p_attribute9                    => p_attribute9
       ,p_attribute10                   => p_attribute10
       ,p_attribute11                   => p_attribute11
       ,p_attribute12                   => p_attribute12
       ,p_attribute13                   => p_attribute13
       ,p_attribute14                   => p_attribute14
       ,p_attribute15                   => p_attribute15
       ,p_attribute16                   => p_attribute16
       ,p_attribute17                   => p_attribute17
       ,p_attribute18                   => p_attribute18
       ,p_attribute19                   => p_attribute19
       ,p_attribute20                   => p_attribute20
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       ,p_dis_information_category      => p_dis_information_category
       ,p_dis_information1              => p_dis_information1
       ,p_dis_information2              => p_dis_information2
       ,p_dis_information3              => p_dis_information3
       ,p_dis_information4              => p_dis_information4
       ,p_dis_information5              => p_dis_information5
       ,p_dis_information6              => p_dis_information6
       ,p_dis_information7              => p_dis_information7
       ,p_dis_information8              => p_dis_information8
       ,p_dis_information9              => p_dis_information9
       ,p_dis_information10             => p_dis_information10
       ,p_dis_information11             => p_dis_information11
       ,p_dis_information12             => p_dis_information12
       ,p_dis_information13             => p_dis_information13
       ,p_dis_information14             => p_dis_information14
       ,p_dis_information15             => p_dis_information15
       ,p_dis_information16             => p_dis_information16
       ,p_dis_information17             => p_dis_information17
       ,p_dis_information18             => p_dis_information18
       ,p_dis_information19             => p_dis_information19
       ,p_dis_information20             => p_dis_information20
       ,p_dis_information21             => p_dis_information21
       ,p_dis_information22             => p_dis_information22
       ,p_dis_information23             => p_dis_information23
       ,p_dis_information24             => p_dis_information24
       ,p_dis_information25             => p_dis_information25
       ,p_dis_information26             => p_dis_information26
       ,p_dis_information27             => p_dis_information27
       ,p_dis_information28             => p_dis_information28
       ,p_dis_information29             => p_dis_information29
       ,p_dis_information30             => p_dis_information30
       ,p_disability_id                 => l_disability_id
       ,p_object_version_number         => l_object_version_number
       ,p_effective_start_date          => l_effective_start_date
       ,p_effective_end_date            => l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  begin
    per_disability_api_bk1.create_disability_a
       (p_effective_date                => l_effective_date
       ,p_person_id                     => p_person_id
       ,p_category                      => p_category
       ,p_status                        => p_status
       ,p_quota_fte                     => p_quota_fte
       ,p_organization_id               => p_organization_id
       ,p_registration_id               => p_registration_id
       ,p_registration_date             => l_registration_date
       ,p_registration_exp_date         => l_registration_exp_date
       ,p_description                   => p_description
       ,p_degree                        => p_degree
       ,p_reason                        => p_reason
       ,p_work_restriction              => p_work_restriction
       ,p_incident_id                   => p_incident_id
       ,p_pre_registration_job          => p_pre_registration_job
       ,p_attribute_category            => p_attribute_category
       ,p_attribute1                    => p_attribute1
       ,p_attribute2                    => p_attribute2
       ,p_attribute3                    => p_attribute3
       ,p_attribute4                    => p_attribute4
       ,p_attribute5                    => p_attribute5
       ,p_attribute6                    => p_attribute6
       ,p_attribute7                    => p_attribute7
       ,p_attribute8                    => p_attribute8
       ,p_attribute9                    => p_attribute9
       ,p_attribute10                   => p_attribute10
       ,p_attribute11                   => p_attribute11
       ,p_attribute12                   => p_attribute12
       ,p_attribute13                   => p_attribute13
       ,p_attribute14                   => p_attribute14
       ,p_attribute15                   => p_attribute15
       ,p_attribute16                   => p_attribute16
       ,p_attribute17                   => p_attribute17
       ,p_attribute18                   => p_attribute18
       ,p_attribute19                   => p_attribute19
       ,p_attribute20                   => p_attribute20
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       ,p_dis_information_category      => p_dis_information_category
       ,p_dis_information1              => p_dis_information1
       ,p_dis_information2              => p_dis_information2
       ,p_dis_information3              => p_dis_information3
       ,p_dis_information4              => p_dis_information4
       ,p_dis_information5              => p_dis_information5
       ,p_dis_information6              => p_dis_information6
       ,p_dis_information7              => p_dis_information7
       ,p_dis_information8              => p_dis_information8
       ,p_dis_information9              => p_dis_information9
       ,p_dis_information10             => p_dis_information10
       ,p_dis_information11             => p_dis_information11
       ,p_dis_information12             => p_dis_information12
       ,p_dis_information13             => p_dis_information13
       ,p_dis_information14             => p_dis_information14
       ,p_dis_information15             => p_dis_information15
       ,p_dis_information16             => p_dis_information16
       ,p_dis_information17             => p_dis_information17
       ,p_dis_information18             => p_dis_information18
       ,p_dis_information19             => p_dis_information19
       ,p_dis_information20             => p_dis_information20
       ,p_dis_information21             => p_dis_information21
       ,p_dis_information22             => p_dis_information22
       ,p_dis_information23             => p_dis_information23
       ,p_dis_information24             => p_dis_information24
       ,p_dis_information25             => p_dis_information25
       ,p_dis_information26             => p_dis_information26
       ,p_dis_information27             => p_dis_information27
       ,p_dis_information28             => p_dis_information28
       ,p_dis_information29             => p_dis_information29
       ,p_dis_information30             => p_dis_information30
       ,p_disability_id                 => l_disability_id
       ,p_object_version_number         => l_object_version_number
       ,p_effective_start_date          => l_effective_start_date
       ,p_effective_end_date            => l_effective_end_date
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_disability_a'
        ,p_hook_type   => 'AP'
        );
  end;

  -- if medical assessment id has been passed in then
  -- call per_medical_assessment_api.update_medical_assessment to
  -- set the foreign key of disability_id for the supplied
  -- medical asessment id, and therby link the disability to the
  -- assessment.
  --
  if p_medical_assessment_id is not null then
   begin
   -- get ovn of medical_assessment record
   -- for update.

	select mea.object_version_number into l_object_version_number1
     from per_medical_assessments mea
     where mea.medical_assessment_id = p_medical_assessment_id;

     per_medical_assessment_api.update_medical_assessment
     (p_validate                            => p_validate
     ,p_medical_assessment_id               => p_medical_assessment_id
     ,p_object_version_number               => l_object_version_number1
     ,p_effective_date                      => l_effective_date
     ,p_disability_id                       => l_disability_id);


   EXCEPTION
   WHEN NO_DATA_FOUND then
     hr_utility.set_message(800, 'HR_289018_DIS_INV_ASSMT');
     hr_utility.raise_error;
   END;
  end if;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_disability_id          := l_disability_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_disability;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_disability_id          := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_disability;
    --
    -- set in out parameters and set out parameters
    --
    p_disability_id          := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_disability;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_disability >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_disability
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_disability_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_category                      in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_quota_fte                     in     number   default hr_api.g_number
  ,p_organization_id               in     number   default hr_api.g_number
  ,p_registration_id               in     varchar2 default hr_api.g_varchar2
  ,p_registration_date             in     date     default hr_api.g_date
  ,p_registration_exp_date         in     date     default hr_api.g_date
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_degree                        in     number   default hr_api.g_number
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_work_restriction              in     varchar2 default hr_api.g_varchar2
  ,p_incident_id                   in     number   default hr_api.g_number
  ,p_medical_assessment_id         in     number   default hr_api.g_number
  ,p_pre_registration_job          in     varchar2 default hr_api.g_varchar2
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
  ,p_dis_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_dis_information1              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information2              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information3              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information4              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information5              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information6              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information7              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information8              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information9              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information10             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information11             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information12             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information13             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information14             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information15             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information16             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information17             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information18             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information19             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information20             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information21             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information22             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information23             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information24             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information25             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information26             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information27             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information28             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information29             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information30             in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- cusor to check if any causal med_assment recs exist
  -- for the current disability_id
  --
  cursor c_control_med_assmt is
    select mea.medical_assessment_id
    from per_medical_assessments mea
    where mea.disability_id = p_disability_id
    and mea.consultation_result = 'DI';
  --
  l_proc                     varchar2(72) := g_package||'update_disability';
  l_disability_id            per_disabilities_f.disability_id%TYPE;
  l_object_version_number    per_disabilities_f.object_version_number%TYPE;
  l_ovn per_disabilities_f.object_version_number%TYPE := p_object_version_number;
  l_object_version_number1   per_medical_assessments.object_version_number%TYPE;
  l_effective_date           date;
  l_effective_start_date     per_disabilities_f.effective_start_date%TYPE;
  l_effective_end_date       per_disabilities_f.effective_end_date%TYPE;
  l_registration_date        per_disabilities_f.registration_date%TYPE;
  l_registration_exp_date    per_disabilities_f.registration_exp_date%TYPE;
  --
  l_mea_id                   per_medical_assessments.medical_assessment_id%TYPE;
  l_new_flag                 boolean := TRUE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_disability;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_registration_date := trunc(p_registration_date);
  l_registration_exp_date := trunc(p_registration_exp_date);
  --
  -- store ovn passed in
  l_object_version_number := p_object_version_number;


  --
  --  Control linking/unlinking of child medical_assessment records:
  --
  -- 1) unlink causal medical assessment rec from disability rec if medical_assessment is null
  -- or value has changed.
  --
  -- 2) link a new causal medical assessment to the disability, if supplied.
  --  (if a disability_id has not yet been set for the medical assessment record)

 if (p_medical_assessment_id is null) or
    ((p_medical_assessment_id is not null) and (p_medical_assessment_id <> hr_api.g_number)) then
   --
   -- always execute the cursor if not default value, to determine state of
   -- any medical_assessment record for the disability
   --
   open c_control_med_assmt;
   fetch c_control_med_assmt into l_mea_id;
    if c_control_med_assmt%found then
      close c_control_med_assmt;
      -- a child causal medical record exists for the disability_id
      if (p_medical_assessment_id is NULL) or
         (p_medical_assessment_id is not NULL and l_mea_id <> p_medical_assessment_id) then
        BEGIN
        --
        -- unlink previous child medical record first.
        --
          select mea.object_version_number into l_object_version_number1
          from per_medical_assessments mea
          where mea.medical_assessment_id = l_mea_id;

          per_medical_assessment_api.update_medical_assessment
          (p_validate                            => p_validate
          ,p_medical_assessment_id               => l_mea_id
          ,p_object_version_number               => l_object_version_number1
          ,p_effective_date                      => l_effective_date
          ,p_disability_id                       => NULL);
          --
          if p_medical_assessment_id IS NULL then
            l_new_flag := FALSE;
          end if;
          --
          EXCEPTION
           WHEN NO_DATA_FOUND then
           hr_utility.set_message(800, 'HR_289018_DIS_INV_ASSMT');
           hr_utility.raise_error;
        END;
      end if;
    else
      close c_control_med_assmt;
    end if;

    if l_new_flag and p_medical_assessment_id is not null then
      BEGIN
      --
      -- make a new link to new medical assessment child record,
      -- (as identified by the p_medical_assessment_id value).
      --
      select mea.object_version_number into l_object_version_number1
      from per_medical_assessments mea
      where mea.medical_assessment_id = p_medical_assessment_id
      and mea.consultation_result = 'DI'
      and (mea.disability_id is null or mea.disability_id = p_disability_id);

        per_medical_assessment_api.update_medical_assessment
        (p_validate                            => p_validate
        ,p_medical_assessment_id               => p_medical_assessment_id
        ,p_object_version_number               => l_object_version_number1
        ,p_effective_date                      => l_effective_date
        ,p_disability_id                       => p_disability_id);

       EXCEPTION
       WHEN NO_DATA_FOUND then
         hr_utility.set_message(800, 'HR_289018_DIS_INV_ASSMT');
         hr_utility.raise_error;
      END;
    end if;

  end if;

  --
  -- Call Before Process User Hook
  --
  BEGIN

    per_disability_api_bk2.update_disability_b
       (p_effective_date                => l_effective_date
       ,p_datetrack_mode                => p_datetrack_mode
       ,p_disability_id                 => p_disability_id
       ,p_object_version_number         => l_object_version_number
       ,p_category                      => p_category
       ,p_status                        => p_status
       ,p_quota_fte                     => p_quota_fte
       ,p_organization_id               => p_organization_id
       ,p_registration_id               => p_registration_id
       ,p_registration_date             => l_registration_date
       ,p_registration_exp_date         => l_registration_exp_date
       ,p_description                   => p_description
       ,p_degree                        => p_degree
       ,p_reason                        => p_reason
       ,p_work_restriction              => p_work_restriction
       ,p_incident_id                   => p_incident_id
       ,p_pre_registration_job          => p_pre_registration_job
       ,p_attribute_category            => p_attribute_category
       ,p_attribute1                    => p_attribute1
       ,p_attribute2                    => p_attribute2
       ,p_attribute3                    => p_attribute3
       ,p_attribute4                    => p_attribute4
       ,p_attribute5                    => p_attribute5
       ,p_attribute6                    => p_attribute6
       ,p_attribute7                    => p_attribute7
       ,p_attribute8                    => p_attribute8
       ,p_attribute9                    => p_attribute9
       ,p_attribute10                   => p_attribute10
       ,p_attribute11                   => p_attribute11
       ,p_attribute12                   => p_attribute12
       ,p_attribute13                   => p_attribute13
       ,p_attribute14                   => p_attribute14
       ,p_attribute15                   => p_attribute15
       ,p_attribute16                   => p_attribute16
       ,p_attribute17                   => p_attribute17
       ,p_attribute18                   => p_attribute18
       ,p_attribute19                   => p_attribute19
       ,p_attribute20                   => p_attribute20
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       ,p_dis_information_category      => p_dis_information_category
       ,p_dis_information1              => p_dis_information1
       ,p_dis_information2              => p_dis_information2
       ,p_dis_information3              => p_dis_information3
       ,p_dis_information4              => p_dis_information4
       ,p_dis_information5              => p_dis_information5
       ,p_dis_information6              => p_dis_information6
       ,p_dis_information7              => p_dis_information7
       ,p_dis_information8              => p_dis_information8
       ,p_dis_information9              => p_dis_information9
       ,p_dis_information10             => p_dis_information10
       ,p_dis_information11             => p_dis_information11
       ,p_dis_information12             => p_dis_information12
       ,p_dis_information13             => p_dis_information13
       ,p_dis_information14             => p_dis_information14
       ,p_dis_information15             => p_dis_information15
       ,p_dis_information16             => p_dis_information16
       ,p_dis_information17             => p_dis_information17
       ,p_dis_information18             => p_dis_information18
       ,p_dis_information19             => p_dis_information19
       ,p_dis_information20             => p_dis_information20
       ,p_dis_information21             => p_dis_information21
       ,p_dis_information22             => p_dis_information22
       ,p_dis_information23             => p_dis_information23
       ,p_dis_information24             => p_dis_information24
       ,p_dis_information25             => p_dis_information25
       ,p_dis_information26             => p_dis_information26
       ,p_dis_information27             => p_dis_information27
       ,p_dis_information28             => p_dis_information28
       ,p_dis_information29             => p_dis_information29
       ,p_dis_information30             => p_dis_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_disability_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  -- Process Logic
  --
per_dis_upd.upd
       (p_effective_date                => l_effective_date
       ,p_datetrack_mode                => p_datetrack_mode
       ,p_disability_id                 => p_disability_id
       ,p_object_version_number         => l_object_version_number
       ,p_category                      => p_category
       ,p_status                        => p_status
       ,p_quota_fte                     => p_quota_fte
       ,p_organization_id               => p_organization_id
       ,p_registration_id               => p_registration_id
       ,p_registration_date             => l_registration_date
       ,p_registration_exp_date         => l_registration_exp_date
       ,p_description                   => p_description
       ,p_degree                        => p_degree
       ,p_reason                        => p_reason
       ,p_work_restriction              => p_work_restriction
       ,p_incident_id                   => p_incident_id
       ,p_pre_registration_job          => p_pre_registration_job
       ,p_attribute_category            => p_attribute_category
       ,p_attribute1                    => p_attribute1
       ,p_attribute2                    => p_attribute2
       ,p_attribute3                    => p_attribute3
       ,p_attribute4                    => p_attribute4
       ,p_attribute5                    => p_attribute5
       ,p_attribute6                    => p_attribute6
       ,p_attribute7                    => p_attribute7
       ,p_attribute8                    => p_attribute8
       ,p_attribute9                    => p_attribute9
       ,p_attribute10                   => p_attribute10
       ,p_attribute11                   => p_attribute11
       ,p_attribute12                   => p_attribute12
       ,p_attribute13                   => p_attribute13
       ,p_attribute14                   => p_attribute14
       ,p_attribute15                   => p_attribute15
       ,p_attribute16                   => p_attribute16
       ,p_attribute17                   => p_attribute17
       ,p_attribute18                   => p_attribute18
       ,p_attribute19                   => p_attribute19
       ,p_attribute20                   => p_attribute20
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       ,p_dis_information_category      => p_dis_information_category
       ,p_dis_information1              => p_dis_information1
       ,p_dis_information2              => p_dis_information2
       ,p_dis_information3              => p_dis_information3
       ,p_dis_information4              => p_dis_information4
       ,p_dis_information5              => p_dis_information5
       ,p_dis_information6              => p_dis_information6
       ,p_dis_information7              => p_dis_information7
       ,p_dis_information8              => p_dis_information8
       ,p_dis_information9              => p_dis_information9
       ,p_dis_information10             => p_dis_information10
       ,p_dis_information11             => p_dis_information11
       ,p_dis_information12             => p_dis_information12
       ,p_dis_information13             => p_dis_information13
       ,p_dis_information14             => p_dis_information14
       ,p_dis_information15             => p_dis_information15
       ,p_dis_information16             => p_dis_information16
       ,p_dis_information17             => p_dis_information17
       ,p_dis_information18             => p_dis_information18
       ,p_dis_information19             => p_dis_information19
       ,p_dis_information20             => p_dis_information20
       ,p_dis_information21             => p_dis_information21
       ,p_dis_information22             => p_dis_information22
       ,p_dis_information23             => p_dis_information23
       ,p_dis_information24             => p_dis_information24
       ,p_dis_information25             => p_dis_information25
       ,p_dis_information26             => p_dis_information26
       ,p_dis_information27             => p_dis_information27
       ,p_dis_information28             => p_dis_information28
       ,p_dis_information29             => p_dis_information29
       ,p_dis_information30             => p_dis_information30
       ,p_effective_start_date          => l_effective_start_date
       ,p_effective_end_date            => l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  begin
    per_disability_api_bk2.update_disability_a
       (p_effective_date                => l_effective_date
       ,p_datetrack_mode                => p_datetrack_mode
       ,p_disability_id                 => p_disability_id
       ,p_object_version_number         => l_object_version_number
       ,p_category                      => p_category
       ,p_status                        => p_status
       ,p_quota_fte                     => p_quota_fte
       ,p_organization_id               => p_organization_id
       ,p_registration_id               => p_registration_id
       ,p_registration_date             => l_registration_date
       ,p_registration_exp_date         => l_registration_exp_date
       ,p_description                   => p_description
       ,p_degree                        => p_degree
       ,p_reason                        => p_reason
       ,p_work_restriction              => p_work_restriction
       ,p_incident_id                   => p_incident_id
       ,p_pre_registration_job          => p_pre_registration_job
       ,p_attribute_category            => p_attribute_category
       ,p_attribute1                    => p_attribute1
       ,p_attribute2                    => p_attribute2
       ,p_attribute3                    => p_attribute3
       ,p_attribute4                    => p_attribute4
       ,p_attribute5                    => p_attribute5
       ,p_attribute6                    => p_attribute6
       ,p_attribute7                    => p_attribute7
       ,p_attribute8                    => p_attribute8
       ,p_attribute9                    => p_attribute9
       ,p_attribute10                   => p_attribute10
       ,p_attribute11                   => p_attribute11
       ,p_attribute12                   => p_attribute12
       ,p_attribute13                   => p_attribute13
       ,p_attribute14                   => p_attribute14
       ,p_attribute15                   => p_attribute15
       ,p_attribute16                   => p_attribute16
       ,p_attribute17                   => p_attribute17
       ,p_attribute18                   => p_attribute18
       ,p_attribute19                   => p_attribute19
       ,p_attribute20                   => p_attribute20
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       ,p_dis_information_category      => p_dis_information_category
       ,p_dis_information1              => p_dis_information1
       ,p_dis_information2              => p_dis_information2
       ,p_dis_information3              => p_dis_information3
       ,p_dis_information4              => p_dis_information4
       ,p_dis_information5              => p_dis_information5
       ,p_dis_information6              => p_dis_information6
       ,p_dis_information7              => p_dis_information7
       ,p_dis_information8              => p_dis_information8
       ,p_dis_information9              => p_dis_information9
       ,p_dis_information10             => p_dis_information10
       ,p_dis_information11             => p_dis_information11
       ,p_dis_information12             => p_dis_information12
       ,p_dis_information13             => p_dis_information13
       ,p_dis_information14             => p_dis_information14
       ,p_dis_information15             => p_dis_information15
       ,p_dis_information16             => p_dis_information16
       ,p_dis_information17             => p_dis_information17
       ,p_dis_information18             => p_dis_information18
       ,p_dis_information19             => p_dis_information19
       ,p_dis_information20             => p_dis_information20
       ,p_dis_information21             => p_dis_information21
       ,p_dis_information22             => p_dis_information22
       ,p_dis_information23             => p_dis_information23
       ,p_dis_information24             => p_dis_information24
       ,p_dis_information25             => p_dis_information25
       ,p_dis_information26             => p_dis_information26
       ,p_dis_information27             => p_dis_information27
       ,p_dis_information28             => p_dis_information28
       ,p_dis_information29             => p_dis_information29
       ,p_dis_information30             => p_dis_information30
       ,p_effective_start_date          => l_effective_start_date
       ,p_effective_end_date            => l_effective_end_date
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_disability_a'
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
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_disability;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- passed in values are returned.
    -- p_object_version_number  := null;
    -- p_effective_start_date   := null;
    -- p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_disability;
    --
    -- set in out parameters and set out parameters
    --
     p_object_version_number  := l_ovn;
     p_effective_start_date   := null;
     p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_disability;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_disability >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_disability
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_disability_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  Cursor csr_mea is
     select medical_assessment_id, object_version_number
     from per_medical_assessments mea
     where mea.disability_id = p_disability_id;
  --
  --
  l_proc varchar2(72) := g_package||'delete_disability';
  l_object_version_number per_disabilities_f.object_version_number%TYPE;
  l_ovn per_disabilities_f.object_version_number%TYPE := p_object_version_number;
  l_effective_start_date per_disabilities_f.effective_start_date%TYPE;
  l_effective_end_date per_disabilities_f.effective_end_date%TYPE;
  l_ovn1 per_medical_assessments.object_version_number%TYPE;
  l_assessment_id per_medical_assessments.medical_assessment_id%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_disability;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  hr_utility.set_location(l_proc, 30);
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_disability
    --
    per_disability_api_bk3.delete_disability_b
      (p_effective_date                   =>  trunc(p_effective_date)
      ,p_datetrack_mode                   =>  p_datetrack_mode
      ,p_disability_id                    =>  p_disability_id
      ,p_object_version_number            =>  l_object_version_number
      );
    --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_disability_b'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_disability
    --
  end;
    --
    -- Nullify any foreign key references that may exist for the
    -- disability record to be deleted in per_medical_assessments table.
    -- (required when performing DT Purge only, as this field is not
    --  part of date tracked disability entity)
    --
    if p_datetrack_mode = 'ZAP' then
      open csr_mea;
      loop
      fetch csr_mea into l_assessment_id, l_ovn1;
      exit when csr_mea%notfound;
    --
      per_medical_assessment_api.update_medical_assessment
      (p_validate                            => p_validate
      ,p_medical_assessment_id               => l_assessment_id
      ,p_object_version_number               => l_ovn1
      ,p_effective_date                      => trunc(p_effective_date)
      ,p_disability_id                       => NULL);

      end loop;
      close csr_mea;
    end if;

    --
    -- Continue with delete of disability.
    --
    per_dis_del.del
      (p_disability_id                 => p_disability_id
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_object_version_number         => l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      ,p_datetrack_mode                => p_datetrack_mode
      );
    --
  begin
    --
    -- Start of API User Hook for the after hook of delete_contract
    --
    per_disability_api_bk3.delete_disability_a
      (p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_disability_id                  =>  p_disability_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_disability_a'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_contract
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  p_object_version_number := l_object_version_number;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments (returned by some dt modes only)
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_disability;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_disability;
    --
    -- set in out parameters and set out parameters
    --
     p_object_version_number  := l_ovn;
     p_effective_start_date   := null;
     p_effective_end_date     := null;
    --
    raise;
    --
end delete_disability;
--
--
end per_disability_api;

/
