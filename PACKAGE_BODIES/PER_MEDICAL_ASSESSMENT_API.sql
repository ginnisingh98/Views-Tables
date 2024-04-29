--------------------------------------------------------
--  DDL for Package Body PER_MEDICAL_ASSESSMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MEDICAL_ASSESSMENT_API" as
/* $Header: pemeaapi.pkb 115.3 2002/12/11 11:36:55 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_medical_assessment >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_medical_assessment
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_person_id                     IN     NUMBER
  ,p_consultation_date             IN     DATE
  ,p_consultation_type             IN     VARCHAR2
  ,p_examiner_name                 IN     VARCHAR2 DEFAULT NULL
  ,p_organization_id               IN     NUMBER   DEFAULT NULL
  ,p_consultation_result           IN     VARCHAR2 DEFAULT NULL
  ,p_incident_id                   IN     NUMBER   DEFAULT NULL
  ,p_disability_id                 IN     NUMBER   DEFAULT NULL
  ,p_next_consultation_date        IN     DATE     DEFAULT NULL
  ,p_description                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute_category            IN     VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute21                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute22                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute23                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute24                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute25                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute26                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute27                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute28                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute29                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute30                   IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information_category      IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information1              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information2              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information3              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information4              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information5              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information6              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information7              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information8              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information9              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information10             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information11             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information12             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information13             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information14             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information15             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information16             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information17             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information18             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information19             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information20             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information21             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information22             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information23             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information24             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information25             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information26             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information27             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information28             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information29             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information30             IN     VARCHAR2 DEFAULT NULL
  ,p_medical_assessment_id            OUT NOCOPY NUMBER
  ,p_object_version_number            OUT NOCOPY NUMBER) IS
  --
  -- Declare local variables
  --
  l_proc  varchar2(72) := g_package||'create_medical_assessment';
  l_consultation_date      per_medical_assessments.consultation_date%TYPE;
  l_next_consultation_date per_medical_assessments.next_consultation_date%TYPE;
  l_object_version_number  per_medical_assessments.object_version_number%TYPE;
  l_medical_assessment_id  per_medical_assessments.medical_assessment_id%TYPE;
  l_effective_date         DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT create_medical_assessment;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_consultation_date      := TRUNC(p_consultation_date);
  l_next_consultation_date := TRUNC(p_next_consultation_date);
  l_effective_date         := TRUNC(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  BEGIN
    --
    per_medical_assessment_bk1.create_medical_assessment_b
     (p_effective_date                => l_effective_date
     ,p_person_id                     => p_person_id
     ,p_consultation_date             => l_consultation_date
     ,p_consultation_type             => p_consultation_type
     ,p_examiner_name                 => p_examiner_name
     ,p_organization_id               => p_organization_id
     ,p_consultation_result           => p_consultation_result
     ,p_incident_id                   => p_incident_id
     ,p_disability_id                 => p_disability_id
     ,p_next_consultation_date        => l_next_consultation_date
     ,p_description                   => p_description
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
     ,p_mea_information_category      => p_mea_information_category
     ,p_mea_information1              => p_mea_information1
     ,p_mea_information2              => p_mea_information2
     ,p_mea_information3              => p_mea_information3
     ,p_mea_information4              => p_mea_information4
     ,p_mea_information5              => p_mea_information5
     ,p_mea_information6              => p_mea_information6
     ,p_mea_information7              => p_mea_information7
     ,p_mea_information8              => p_mea_information8
     ,p_mea_information9              => p_mea_information9
     ,p_mea_information10             => p_mea_information10
     ,p_mea_information11             => p_mea_information11
     ,p_mea_information12             => p_mea_information12
     ,p_mea_information13             => p_mea_information13
     ,p_mea_information14             => p_mea_information14
     ,p_mea_information15             => p_mea_information15
     ,p_mea_information16             => p_mea_information16
     ,p_mea_information17             => p_mea_information17
     ,p_mea_information18             => p_mea_information18
     ,p_mea_information19             => p_mea_information19
     ,p_mea_information20             => p_mea_information20
     ,p_mea_information21             => p_mea_information21
     ,p_mea_information22             => p_mea_information22
     ,p_mea_information23             => p_mea_information23
     ,p_mea_information24             => p_mea_information24
     ,p_mea_information25             => p_mea_information25
     ,p_mea_information26             => p_mea_information26
     ,p_mea_information27             => p_mea_information27
     ,p_mea_information28             => p_mea_information28
     ,p_mea_information29             => p_mea_information29
     ,p_mea_information30             => p_mea_information30);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_medical_assessment'
        ,p_hook_type   => 'BP');
      --
  END;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process logic
  --
  per_mea_ins.ins
    (p_effective_date                 => l_effective_date
    ,p_person_id                      => p_person_id
    ,p_consultation_date              => l_consultation_date
    ,p_consultation_type              => p_consultation_type
    ,p_examiner_name                  => p_examiner_name
    ,p_organization_id                => p_organization_id
    ,p_incident_id                    => p_incident_id
    ,p_consultation_result            => p_consultation_result
    ,p_disability_id                  => p_disability_id
    ,p_next_consultation_date         => l_next_consultation_date
    ,p_description                    => p_description
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_attribute21                    => p_attribute21
    ,p_attribute22                    => p_attribute22
    ,p_attribute23                    => p_attribute23
    ,p_attribute24                    => p_attribute24
    ,p_attribute25                    => p_attribute25
    ,p_attribute26                    => p_attribute26
    ,p_attribute27                    => p_attribute27
    ,p_attribute28                    => p_attribute28
    ,p_attribute29                    => p_attribute29
    ,p_attribute30                    => p_attribute30
    ,p_mea_information_category       => p_mea_information_category
    ,p_mea_information1               => p_mea_information1
    ,p_mea_information2               => p_mea_information2
    ,p_mea_information3               => p_mea_information3
    ,p_mea_information4               => p_mea_information4
    ,p_mea_information5               => p_mea_information5
    ,p_mea_information6               => p_mea_information6
    ,p_mea_information7               => p_mea_information7
    ,p_mea_information8               => p_mea_information8
    ,p_mea_information9               => p_mea_information9
    ,p_mea_information10              => p_mea_information10
    ,p_mea_information11              => p_mea_information11
    ,p_mea_information12              => p_mea_information12
    ,p_mea_information13              => p_mea_information13
    ,p_mea_information14              => p_mea_information14
    ,p_mea_information15              => p_mea_information15
    ,p_mea_information16              => p_mea_information16
    ,p_mea_information17              => p_mea_information17
    ,p_mea_information18              => p_mea_information18
    ,p_mea_information19              => p_mea_information19
    ,p_mea_information20              => p_mea_information20
    ,p_mea_information21              => p_mea_information21
    ,p_mea_information22              => p_mea_information22
    ,p_mea_information23              => p_mea_information23
    ,p_mea_information24              => p_mea_information24
    ,p_mea_information25              => p_mea_information25
    ,p_mea_information26              => p_mea_information26
    ,p_mea_information27              => p_mea_information27
    ,p_mea_information28              => p_mea_information28
    ,p_mea_information29              => p_mea_information29
    ,p_mea_information30              => p_mea_information30
    ,p_medical_assessment_id          => l_medical_assessment_id
    ,p_object_version_number          => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  BEGIN
    --
    per_medical_assessment_bk1.create_medical_assessment_a
      (p_medical_assessment_id         => p_medical_assessment_id
      ,p_object_version_number         => p_object_version_number
      ,p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_consultation_date             => l_consultation_date
      ,p_consultation_type             => p_consultation_type
      ,p_examiner_name                 => p_examiner_name
      ,p_organization_id               => p_organization_id
      ,p_consultation_result           => p_consultation_result
      ,p_incident_id                   => p_incident_id
      ,p_disability_id                 => p_disability_id
      ,p_next_consultation_date        => l_next_consultation_date
      ,p_description                   => p_description
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
      ,p_mea_information_category      => p_mea_information_category
      ,p_mea_information1              => p_mea_information1
      ,p_mea_information2              => p_mea_information2
      ,p_mea_information3              => p_mea_information3
      ,p_mea_information4              => p_mea_information4
      ,p_mea_information5              => p_mea_information5
      ,p_mea_information6              => p_mea_information6
      ,p_mea_information7              => p_mea_information7
      ,p_mea_information8              => p_mea_information8
      ,p_mea_information9              => p_mea_information9
      ,p_mea_information10             => p_mea_information10
      ,p_mea_information11             => p_mea_information11
      ,p_mea_information12             => p_mea_information12
      ,p_mea_information13             => p_mea_information13
      ,p_mea_information14             => p_mea_information14
      ,p_mea_information15             => p_mea_information15
      ,p_mea_information16             => p_mea_information16
      ,p_mea_information17             => p_mea_information17
      ,p_mea_information18             => p_mea_information18
      ,p_mea_information19             => p_mea_information19
      ,p_mea_information20             => p_mea_information20
      ,p_mea_information21             => p_mea_information21
      ,p_mea_information22             => p_mea_information22
      ,p_mea_information23             => p_mea_information23
      ,p_mea_information24             => p_mea_information24
      ,p_mea_information25             => p_mea_information25
      ,p_mea_information26             => p_mea_information26
      ,p_mea_information27             => p_mea_information27
      ,p_mea_information28             => p_mea_information28
      ,p_mea_information29             => p_mea_information29
      ,p_mea_information30             => p_mea_information30);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_medical_assessment'
        ,p_hook_type   => 'AP');
      --
  END;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  p_medical_assessment_id  := l_medical_assessment_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_medical_assessment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_medical_assessment_id  := NULL;
    p_object_version_number  := NULL;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_medical_assessment;
    --
    -- set in out parameters and set out parameters
    --
    p_medical_assessment_id  := NULL;
    p_object_version_number  := NULL;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    RAISE;
    --
END create_medical_assessment;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_medical_assessment >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_medical_assessment
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_medical_assessment_id         IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_effective_date                IN     DATE
  ,p_consultation_date             IN     DATE     DEFAULT hr_api.g_date
  ,p_consultation_type             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_examiner_name                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_organization_id               IN     NUMBER   DEFAULT hr_api.g_number
  ,p_consultation_result           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_incident_id                   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_disability_id                 IN     NUMBER   DEFAULT hr_api.g_number
  ,p_next_consultation_date        IN     DATE     DEFAULT hr_api.g_date
  ,p_description                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute_category            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute1                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute2                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute3                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute4                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute5                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute6                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute7                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute8                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute9                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute10                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute11                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute12                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute13                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute14                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute15                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute16                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute17                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute18                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute19                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute21                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute22                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute23                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute24                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute25                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute26                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute27                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute28                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute29                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute30                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information_category      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information1              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information2              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information3              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information4              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information5              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information6              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information7              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information8              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information9              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information10             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information11             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information12             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information13             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information14             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information15             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information16             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information17             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information18             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information19             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information20             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information21             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information22             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information23             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information24             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information25             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information26             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information27             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information28             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information29             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information30             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ) IS
  --
  -- Declare LOCAL variables
  --
  l_proc  varchar2(72) := g_package||'update_medical_assessment';
  l_consultation_date      per_medical_assessments.consultation_date%TYPE;
  l_next_consultation_date per_medical_assessments.next_consultation_date%TYPE;
  l_object_version_number  per_medical_assessments.object_version_number%TYPE;
  l_ovn per_medical_assessments.object_version_number%TYPE := p_object_version_number;
  l_medical_assessment_id  per_medical_assessments.medical_assessment_id%TYPE;
  l_effective_date         DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT update_medical_assessment;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date         := trunc(p_effective_date);
  l_consultation_date      := trunc(p_consultation_date);
  l_next_consultation_date := trunc(p_next_consultation_date);
  --
  -- Call Before Process User Hook
  --
  BEGIN
    --
    hr_utility.set_location(l_proc, 20);
    --
    per_medical_assessment_bk2.update_medical_assessment_b
      (p_medical_assessment_id         => p_medical_assessment_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_date                => l_effective_date
      ,p_consultation_date             => l_consultation_date
      ,p_consultation_type             => p_consultation_type
      ,p_examiner_name                 => p_examiner_name
      ,p_organization_id               => p_organization_id
      ,p_consultation_result           => p_consultation_result
      ,p_incident_id                   => p_incident_id
      ,p_disability_id                 => p_disability_id
      ,p_next_consultation_date        => l_next_consultation_date
      ,p_description                   => p_description
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
      ,p_mea_information_category      => p_mea_information_category
      ,p_mea_information1              => p_mea_information1
      ,p_mea_information2              => p_mea_information2
      ,p_mea_information3              => p_mea_information3
      ,p_mea_information4              => p_mea_information4
      ,p_mea_information5              => p_mea_information5
      ,p_mea_information6              => p_mea_information6
      ,p_mea_information7              => p_mea_information7
      ,p_mea_information8              => p_mea_information8
      ,p_mea_information9              => p_mea_information9
      ,p_mea_information10             => p_mea_information10
      ,p_mea_information11             => p_mea_information11
      ,p_mea_information12             => p_mea_information12
      ,p_mea_information13             => p_mea_information13
      ,p_mea_information14             => p_mea_information14
      ,p_mea_information15             => p_mea_information15
      ,p_mea_information16             => p_mea_information16
      ,p_mea_information17             => p_mea_information17
      ,p_mea_information18             => p_mea_information18
      ,p_mea_information19             => p_mea_information19
      ,p_mea_information20             => p_mea_information20
      ,p_mea_information21             => p_mea_information21
      ,p_mea_information22             => p_mea_information22
      ,p_mea_information23             => p_mea_information23
      ,p_mea_information24             => p_mea_information24
      ,p_mea_information25             => p_mea_information25
      ,p_mea_information26             => p_mea_information26
      ,p_mea_information27             => p_mea_information27
      ,p_mea_information28             => p_mea_information28
      ,p_mea_information29             => p_mea_information29
      ,p_mea_information30             => p_mea_information30);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_medical_assessment_b'
        ,p_hook_type   => 'BP');
      --
  END;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  per_mea_upd.upd
    (p_effective_date               => l_effective_date
    ,p_medical_assessment_id        => p_medical_assessment_id
    ,p_object_version_number        => l_object_version_number
    ,p_consultation_date            => l_consultation_date
    ,p_consultation_type            => p_consultation_type
    ,p_examiner_name                => p_examiner_name
    ,p_organization_id              => p_organization_id
    ,p_incident_id                  => p_incident_id
    ,p_consultation_result          => p_consultation_result
    ,p_disability_id                => p_disability_id
    ,p_next_consultation_date       => l_next_consultation_date
    ,p_description                  => p_description
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_mea_information_category     => p_mea_information_category
    ,p_mea_information1             => p_mea_information1
    ,p_mea_information2             => p_mea_information2
    ,p_mea_information3             => p_mea_information3
    ,p_mea_information4             => p_mea_information4
    ,p_mea_information5             => p_mea_information5
    ,p_mea_information6             => p_mea_information6
    ,p_mea_information7             => p_mea_information7
    ,p_mea_information8             => p_mea_information8
    ,p_mea_information9             => p_mea_information9
    ,p_mea_information10            => p_mea_information10
    ,p_mea_information11            => p_mea_information11
    ,p_mea_information12            => p_mea_information12
    ,p_mea_information13            => p_mea_information13
    ,p_mea_information14            => p_mea_information14
    ,p_mea_information15            => p_mea_information15
    ,p_mea_information16            => p_mea_information16
    ,p_mea_information17            => p_mea_information17
    ,p_mea_information18            => p_mea_information18
    ,p_mea_information19            => p_mea_information19
    ,p_mea_information20            => p_mea_information20
    ,p_mea_information21            => p_mea_information21
    ,p_mea_information22            => p_mea_information22
    ,p_mea_information23            => p_mea_information23
    ,p_mea_information24            => p_mea_information24
    ,p_mea_information25            => p_mea_information25
    ,p_mea_information26            => p_mea_information26
    ,p_mea_information27            => p_mea_information27
    ,p_mea_information28            => p_mea_information28
    ,p_mea_information29            => p_mea_information29
    ,p_mea_information30            => p_mea_information30
    );
  --
  -- Call After Process User Hook
  --
  BEGIN
    --
    hr_utility.set_location(l_proc, 40);
    --
    per_medical_assessment_bk2.update_medical_assessment_a
      (p_medical_assessment_id         => p_medical_assessment_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_date                => l_effective_date
      ,p_consultation_date             => l_consultation_date
      ,p_consultation_type             => p_consultation_type
      ,p_examiner_name                 => p_examiner_name
      ,p_organization_id               => p_organization_id
      ,p_consultation_result           => p_consultation_result
      ,p_incident_id                   => p_incident_id
      ,p_disability_id                 => p_disability_id
      ,p_next_consultation_date        => l_next_consultation_date
      ,p_description                   => p_description
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
      ,p_mea_information_category      => p_mea_information_category
      ,p_mea_information1              => p_mea_information1
      ,p_mea_information2              => p_mea_information2
      ,p_mea_information3              => p_mea_information3
      ,p_mea_information4              => p_mea_information4
      ,p_mea_information5              => p_mea_information5
      ,p_mea_information6              => p_mea_information6
      ,p_mea_information7              => p_mea_information7
      ,p_mea_information8              => p_mea_information8
      ,p_mea_information9              => p_mea_information9
      ,p_mea_information10             => p_mea_information10
      ,p_mea_information11             => p_mea_information11
      ,p_mea_information12             => p_mea_information12
      ,p_mea_information13             => p_mea_information13
      ,p_mea_information14             => p_mea_information14
      ,p_mea_information15             => p_mea_information15
      ,p_mea_information16             => p_mea_information16
      ,p_mea_information17             => p_mea_information17
      ,p_mea_information18             => p_mea_information18
      ,p_mea_information19             => p_mea_information19
      ,p_mea_information20             => p_mea_information20
      ,p_mea_information21             => p_mea_information21
      ,p_mea_information22             => p_mea_information22
      ,p_mea_information23             => p_mea_information23
      ,p_mea_information24             => p_mea_information24
      ,p_mea_information25             => p_mea_information25
      ,p_mea_information26             => p_mea_information26
      ,p_mea_information27             => p_mea_information27
      ,p_mea_information28             => p_mea_information28
      ,p_mea_information29             => p_mea_information29
      ,p_mea_information30             => p_mea_information30);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_medical_assessment_a'
        ,p_hook_type   => 'AP');
      --
  END;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_medical_assessment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_medical_assessment;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    RAISE;
    --
END update_medical_assessment;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_medical_assessment >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_medical_assessment
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_medical_assessment_id         IN     NUMBER
  ,p_object_version_number         IN     NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc VARCHAR2(72) := g_package||'delete_medical_assessment';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  SAVEPOINT delete_medical_assessment;
  --
  -- Call Before Process User Hook
  --
  BEGIN
    --
    per_medical_assessment_bk3.delete_medical_assessment_b
     (p_medical_assessment_id => p_medical_assessment_id
     ,p_object_version_number => p_object_version_number);
    --
   EXCEPTION
     --
     WHEN hr_api.cannot_find_prog_unit THEN
       --
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'delete_medical_assessment_b'
         ,p_hook_type   => 'BP');
       --
  END;
  --
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Process Logic
  --
  per_mea_del.del
    (p_medical_assessment_id => p_medical_assessment_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  BEGIN
    --
    per_medical_assessment_bk3.delete_medical_assessment_a
      (p_medical_assessment_id => p_medical_assessment_id
      ,p_object_version_number => p_object_version_number);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name  => 'delete_medical_assessment_a'
        ,p_hook_type   => 'AP');
      --
  END;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_medical_assessment;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO delete_medical_assessment;
    --
    RAISE;
    --
END delete_medical_assessment;
--
END per_medical_assessment_api;

/
