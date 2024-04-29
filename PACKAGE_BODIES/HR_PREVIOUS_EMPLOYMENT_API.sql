--------------------------------------------------------
--  DDL for Package Body HR_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PREVIOUS_EMPLOYMENT_API" as
/* $Header: pepemapi.pkb 120.0.12010000.2 2008/08/06 09:21:29 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_previous_employment_api.';
-- -----------------------------------------------------------------------
-- |-------------------------< create_previous_employer >----------------|
-- -----------------------------------------------------------------------
--
procedure create_previous_employer
(  p_effective_date               IN      date
  ,p_validate                     IN      boolean   default false
  ,p_business_group_id            IN      number
  ,p_person_id                    IN      number
  ,p_party_id                     IN      number    default null
  ,p_start_date                   IN      date      default null
  ,p_end_date                     IN      date      default null
  ,p_period_years                 IN      number    default null
  ,p_period_months                IN      number    default null
  ,p_period_days                  IN      number    default null
  ,p_employer_name                IN      varchar2  default null
  ,p_employer_country             IN      varchar2  default null
  ,p_employer_address             IN      varchar2  default null
  ,p_employer_type                IN      varchar2  default null
  ,p_employer_subtype             IN      varchar2  default null
  ,p_description                  IN      varchar2  default null
  ,p_all_assignments              IN      varchar2  default 'N'
  ,p_pem_attribute_category       IN      varchar2  default null
  ,p_pem_attribute1               IN      varchar2  default null
  ,p_pem_attribute2               IN      varchar2  default null
  ,p_pem_attribute3               IN      varchar2  default null
  ,p_pem_attribute4               IN      varchar2  default null
  ,p_pem_attribute5               IN      varchar2  default null
  ,p_pem_attribute6               IN      varchar2  default null
  ,p_pem_attribute7               IN      varchar2  default null
  ,p_pem_attribute8               IN      varchar2  default null
  ,p_pem_attribute9               IN      varchar2  default null
  ,p_pem_attribute10              IN      varchar2  default null
  ,p_pem_attribute11              IN      varchar2  default null
  ,p_pem_attribute12              IN      varchar2  default null
  ,p_pem_attribute13              IN      varchar2  default null
  ,p_pem_attribute14              IN      varchar2  default null
  ,p_pem_attribute15              IN      varchar2  default null
  ,p_pem_attribute16              IN      varchar2  default null
  ,p_pem_attribute17              IN      varchar2  default null
  ,p_pem_attribute18              IN      varchar2  default null
  ,p_pem_attribute19              IN      varchar2  default null
  ,p_pem_attribute20              IN      varchar2  default null
  ,p_pem_attribute21              IN      varchar2  default null
  ,p_pem_attribute22              IN      varchar2  default null
  ,p_pem_attribute23              IN      varchar2  default null
  ,p_pem_attribute24              IN      varchar2  default null
  ,p_pem_attribute25              IN      varchar2  default null
  ,p_pem_attribute26              IN      varchar2  default null
  ,p_pem_attribute27              IN      varchar2  default null
  ,p_pem_attribute28              IN      varchar2  default null
  ,p_pem_attribute29              IN      varchar2  default null
  ,p_pem_attribute30              IN      varchar2  default null
  ,p_pem_information_category     IN      varchar2  default null
  ,p_pem_information1             IN      varchar2  default null
  ,p_pem_information2             IN      varchar2  default null
  ,p_pem_information3             IN      varchar2  default null
  ,p_pem_information4             IN      varchar2  default null
  ,p_pem_information5             IN      varchar2  default null
  ,p_pem_information6             IN      varchar2  default null
  ,p_pem_information7             IN      varchar2  default null
  ,p_pem_information8             IN      varchar2  default null
  ,p_pem_information9             IN      varchar2  default null
  ,p_pem_information10            IN      varchar2  default null
  ,p_pem_information11            IN      varchar2  default null
  ,p_pem_information12            IN      varchar2  default null
  ,p_pem_information13            IN      varchar2  default null
  ,p_pem_information14            IN      varchar2  default null
  ,p_pem_information15            IN      varchar2  default null
  ,p_pem_information16            IN      varchar2  default null
  ,p_pem_information17            IN      varchar2  default null
  ,p_pem_information18            IN      varchar2  default null
  ,p_pem_information19            IN      varchar2  default null
  ,p_pem_information20            IN      varchar2  default null
  ,p_pem_information21            IN      varchar2  default null
  ,p_pem_information22            IN      varchar2  default null
  ,p_pem_information23            IN      varchar2  default null
  ,p_pem_information24            IN      varchar2  default null
  ,p_pem_information25            IN      varchar2  default null
  ,p_pem_information26            IN      varchar2  default null
  ,p_pem_information27            IN      varchar2  default null
  ,p_pem_information28            IN      varchar2  default null
  ,p_pem_information29            IN      varchar2  default null
  ,p_pem_information30            IN      varchar2  default null
  ,p_previous_employer_id         OUT NOCOPY     number
  ,p_object_version_number        OUT NOCOPY     number
  ) is
    --
    -- Declare cursors and local variables
    --
    l_flag   varchar2(30);
    l_proc  varchar2(72) := g_package||'create_previous_employer';
    --
    l_start_date    per_previous_employers.start_date%TYPE;
    l_end_date      per_previous_employers.end_date%TYPE;
    --
    l_previous_employer_id
                      per_previous_employers.previous_employer_id%type;
    l_object_version_number
                      per_previous_employers.object_version_number%type;
    l_period_years          per_previous_employers.period_years%type
                            := p_period_years;
    l_period_months         per_previous_employers.period_months%type
                            := p_period_months;
    l_period_days           per_previous_employers.period_days%type
                            := p_period_days;
    l_employer_type         per_previous_employers.employer_type%type
                            := p_employer_type;
    l_employer_subtype      per_previous_employers.employer_subtype%type;
    l_all_assignments       per_previous_employers.all_assignments%type
                            := p_all_assignments;
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_previous_employer;
  --
  -- Truncate the time portion from all IN date parameters
  l_start_date        :=  trunc(p_start_date);
  l_end_date          :=  trunc(p_end_date);
  l_employer_subtype  :=  p_employer_subtype;
  -- Calculate Period Years and Days if null.
  --
  if p_period_years is null
     and p_period_months is null
     and p_period_days is null then
       per_pem_bus.get_period_values(l_start_date
                                    ,l_end_date
                                    ,l_period_years
                                    ,l_period_months
                                    ,l_period_days);
  end if;
  --
  if p_employer_type is null then
    l_employer_type := 'UK';
    l_employer_subtype := null;
  end if;
  --
  -- Call Before Process User Hook
  --
   begin
      hr_previous_employment_bk1.create_previous_employer_b
    (  p_effective_date               =>    p_effective_date
      ,p_previous_employer_id         =>    p_previous_employer_id
      ,p_business_group_id            =>    p_business_group_id
      ,p_person_id                    =>    p_person_id
      ,p_party_id                     =>    p_party_id
      ,p_start_date                   =>    l_start_date
      ,p_end_date                     =>    l_end_date
      ,p_period_years                 =>    l_period_years
      ,p_period_months                =>    l_period_months
      ,p_period_days                  =>    l_period_days
      ,p_employer_name                =>    p_employer_name
      ,p_employer_country             =>    p_employer_country
      ,p_employer_address             =>    p_employer_address
      ,p_employer_type                =>    l_employer_type
      ,p_employer_subtype             =>    l_employer_subtype
      ,p_description                  =>    p_description
      ,p_all_assignments              =>    l_all_assignments
      ,p_pem_attribute_category       =>    p_pem_attribute_category
      ,p_pem_attribute1               =>    p_pem_attribute1
      ,p_pem_attribute2               =>    p_pem_attribute2
      ,p_pem_attribute3               =>    p_pem_attribute3
      ,p_pem_attribute4               =>    p_pem_attribute4
      ,p_pem_attribute5               =>    p_pem_attribute5
      ,p_pem_attribute6               =>    p_pem_attribute6
      ,p_pem_attribute7               =>    p_pem_attribute7
      ,p_pem_attribute8               =>    p_pem_attribute8
      ,p_pem_attribute9               =>    p_pem_attribute9
      ,p_pem_attribute10              =>    p_pem_attribute10
      ,p_pem_attribute11              =>    p_pem_attribute11
      ,p_pem_attribute12              =>    p_pem_attribute12
      ,p_pem_attribute13              =>    p_pem_attribute13
      ,p_pem_attribute14              =>    p_pem_attribute14
      ,p_pem_attribute15              =>    p_pem_attribute15
      ,p_pem_attribute16              =>    p_pem_attribute16
      ,p_pem_attribute17              =>    p_pem_attribute17
      ,p_pem_attribute18              =>    p_pem_attribute18
      ,p_pem_attribute19              =>    p_pem_attribute19
      ,p_pem_attribute20              =>    p_pem_attribute20
      ,p_pem_attribute21              =>    p_pem_attribute21
      ,p_pem_attribute22              =>    p_pem_attribute22
      ,p_pem_attribute23              =>    p_pem_attribute23
      ,p_pem_attribute24              =>    p_pem_attribute24
      ,p_pem_attribute25              =>    p_pem_attribute25
      ,p_pem_attribute26              =>    p_pem_attribute26
      ,p_pem_attribute27              =>    p_pem_attribute27
      ,p_pem_attribute28              =>    p_pem_attribute28
      ,p_pem_attribute29              =>    p_pem_attribute29
      ,p_pem_attribute30              =>    p_pem_attribute30
      ,p_pem_information_category     =>    p_pem_information_category
      ,p_pem_information1             =>    p_pem_information1
      ,p_pem_information2             =>    p_pem_information2
      ,p_pem_information3             =>    p_pem_information3
      ,p_pem_information4             =>    p_pem_information4
      ,p_pem_information5             =>    p_pem_information5
      ,p_pem_information6             =>    p_pem_information6
      ,p_pem_information7             =>    p_pem_information7
      ,p_pem_information8             =>    p_pem_information8
      ,p_pem_information9             =>    p_pem_information9
      ,p_pem_information10            =>    p_pem_information10
      ,p_pem_information11            =>    p_pem_information11
      ,p_pem_information12            =>    p_pem_information12
      ,p_pem_information13            =>    p_pem_information13
      ,p_pem_information14            =>    p_pem_information14
      ,p_pem_information15            =>    p_pem_information15
      ,p_pem_information16            =>    p_pem_information16
      ,p_pem_information17            =>    p_pem_information17
      ,p_pem_information18            =>    p_pem_information18
      ,p_pem_information19            =>    p_pem_information19
      ,p_pem_information20            =>    p_pem_information20
      ,p_pem_information21            =>    p_pem_information21
      ,p_pem_information22            =>    p_pem_information22
      ,p_pem_information23            =>    p_pem_information23
      ,p_pem_information24            =>    p_pem_information24
      ,p_pem_information25            =>    p_pem_information25
      ,p_pem_information26            =>    p_pem_information26
      ,p_pem_information27            =>    p_pem_information27
      ,p_pem_information28            =>    p_pem_information28
      ,p_pem_information29            =>    p_pem_information29
      ,p_pem_information30            =>    p_pem_information30
      ,p_object_version_number        =>    l_object_version_number
      );
   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name
                  => 'hr_previous_employment_api.create_previous_employer'
          ,p_hook_type
                  => 'BP'
          );
   end;
  --
  -- Validation in addition to Row Handlers
  -- Process Logic
  per_pem_ins.ins
    (p_effective_date             =>  p_effective_date
    ,p_business_group_id          =>  p_business_group_id
    ,p_person_id                  =>  p_person_id
    ,p_party_id                   =>  p_party_id
    ,p_start_date                 =>  l_start_date
    ,p_end_date                   =>  l_end_date
    ,p_period_years               =>  l_period_years
    ,p_period_months              =>  l_period_months
    ,p_period_days                =>  l_period_days
    ,p_employer_name              =>  p_employer_name
    ,p_employer_country           =>  p_employer_country
    ,p_employer_address           =>  p_employer_address
    ,p_employer_type              =>  l_employer_type
    ,p_employer_subtype           =>  l_employer_subtype
    ,p_description                =>  p_description
    ,p_all_assignments            =>  l_all_assignments
    ,p_pem_attribute_category     =>  p_pem_attribute_category
    ,p_pem_attribute1             =>  p_pem_attribute1
    ,p_pem_attribute2             =>  p_pem_attribute2
    ,p_pem_attribute3             =>  p_pem_attribute3
    ,p_pem_attribute4             =>  p_pem_attribute4
    ,p_pem_attribute5             =>  p_pem_attribute5
    ,p_pem_attribute6             =>  p_pem_attribute6
    ,p_pem_attribute7             =>  p_pem_attribute7
    ,p_pem_attribute8             =>  p_pem_attribute8
    ,p_pem_attribute9             =>  p_pem_attribute9
    ,p_pem_attribute10            =>  p_pem_attribute10
    ,p_pem_attribute11            =>  p_pem_attribute11
    ,p_pem_attribute12            =>  p_pem_attribute12
    ,p_pem_attribute13            =>  p_pem_attribute13
    ,p_pem_attribute14            =>  p_pem_attribute14
    ,p_pem_attribute15            =>  p_pem_attribute15
    ,p_pem_attribute16            =>  p_pem_attribute16
    ,p_pem_attribute17            =>  p_pem_attribute17
    ,p_pem_attribute18            =>  p_pem_attribute18
    ,p_pem_attribute19            =>  p_pem_attribute19
    ,p_pem_attribute20            =>  p_pem_attribute20
    ,p_pem_attribute21            =>  p_pem_attribute21
    ,p_pem_attribute22            =>  p_pem_attribute22
    ,p_pem_attribute23            =>  p_pem_attribute23
    ,p_pem_attribute24            =>  p_pem_attribute24
    ,p_pem_attribute25            =>  p_pem_attribute25
    ,p_pem_attribute26            =>  p_pem_attribute26
    ,p_pem_attribute27            =>  p_pem_attribute27
    ,p_pem_attribute28            =>  p_pem_attribute28
    ,p_pem_attribute29            =>  p_pem_attribute29
    ,p_pem_attribute30            =>  p_pem_attribute30
    ,p_pem_information_category   =>  p_pem_information_category
    ,p_pem_information1           =>  p_pem_information1
    ,p_pem_information2           =>  p_pem_information2
    ,p_pem_information3           =>  p_pem_information3
    ,p_pem_information4           =>  p_pem_information4
    ,p_pem_information5           =>  p_pem_information5
    ,p_pem_information6           =>  p_pem_information6
    ,p_pem_information7           =>  p_pem_information7
    ,p_pem_information8           =>  p_pem_information8
    ,p_pem_information9           =>  p_pem_information9
    ,p_pem_information10          =>  p_pem_information10
    ,p_pem_information11          =>  p_pem_information11
    ,p_pem_information12          =>  p_pem_information12
    ,p_pem_information13          =>  p_pem_information13
    ,p_pem_information14          =>  p_pem_information14
    ,p_pem_information15          =>  p_pem_information15
    ,p_pem_information16          =>  p_pem_information16
    ,p_pem_information17          =>  p_pem_information17
    ,p_pem_information18          =>  p_pem_information18
    ,p_pem_information19          =>  p_pem_information19
    ,p_pem_information20          =>  p_pem_information20
    ,p_pem_information21          =>  p_pem_information21
    ,p_pem_information22          =>  p_pem_information22
    ,p_pem_information23          =>  p_pem_information23
    ,p_pem_information24          =>  p_pem_information24
    ,p_pem_information25          =>  p_pem_information25
    ,p_pem_information26          =>  p_pem_information26
    ,p_pem_information27          =>  p_pem_information27
    ,p_pem_information28          =>  p_pem_information28
    ,p_pem_information29          =>  p_pem_information29
    ,p_pem_information30          =>  p_pem_information30
    ,p_previous_employer_id       =>  l_previous_employer_id
    ,p_object_version_number      =>  l_object_version_number
    );
-- Call After Process User Hook
  --
  begin
      hr_previous_employment_bk1.create_previous_employer_a
    (  p_effective_date               =>    p_effective_date
      ,p_previous_employer_id         =>    p_previous_employer_id
      ,p_business_group_id            =>    p_business_group_id
      ,p_person_id                    =>    p_person_id
      ,p_party_id                     =>    p_party_id
      ,p_start_date                   =>    l_start_date
      ,p_end_date                     =>    l_end_date
      ,p_period_years                 =>    l_period_years
      ,p_period_months                =>    l_period_months
      ,p_period_days                  =>    l_period_days
      ,p_employer_name                =>    p_employer_name
      ,p_employer_country             =>    p_employer_country
      ,p_employer_address             =>    p_employer_address
      ,p_employer_type                =>    l_employer_type
      ,p_employer_subtype             =>    l_employer_subtype
      ,p_description                  =>    p_description
      ,p_all_assignments              =>    l_all_assignments
      ,p_pem_attribute_category       =>    p_pem_attribute_category
      ,p_pem_attribute1               =>    p_pem_attribute1
      ,p_pem_attribute2               =>    p_pem_attribute2
      ,p_pem_attribute3               =>    p_pem_attribute3
      ,p_pem_attribute4               =>    p_pem_attribute4
      ,p_pem_attribute5               =>    p_pem_attribute5
      ,p_pem_attribute6               =>    p_pem_attribute6
      ,p_pem_attribute7               =>    p_pem_attribute7
      ,p_pem_attribute8               =>    p_pem_attribute8
      ,p_pem_attribute9               =>    p_pem_attribute9
      ,p_pem_attribute10              =>    p_pem_attribute10
      ,p_pem_attribute11              =>    p_pem_attribute11
      ,p_pem_attribute12              =>    p_pem_attribute12
      ,p_pem_attribute13              =>    p_pem_attribute13
      ,p_pem_attribute14              =>    p_pem_attribute14
      ,p_pem_attribute15              =>    p_pem_attribute15
      ,p_pem_attribute16              =>    p_pem_attribute16
      ,p_pem_attribute17              =>    p_pem_attribute17
      ,p_pem_attribute18              =>    p_pem_attribute18
      ,p_pem_attribute19              =>    p_pem_attribute19
      ,p_pem_attribute20              =>    p_pem_attribute20
      ,p_pem_attribute21              =>    p_pem_attribute21
      ,p_pem_attribute22              =>    p_pem_attribute22
      ,p_pem_attribute23              =>    p_pem_attribute23
      ,p_pem_attribute24              =>    p_pem_attribute24
      ,p_pem_attribute25              =>    p_pem_attribute25
      ,p_pem_attribute26              =>    p_pem_attribute26
      ,p_pem_attribute27              =>    p_pem_attribute27
      ,p_pem_attribute28              =>    p_pem_attribute28
      ,p_pem_attribute29              =>    p_pem_attribute29
      ,p_pem_attribute30              =>    p_pem_attribute30
      ,p_pem_information_category     =>    p_pem_information_category
      ,p_pem_information1             =>    p_pem_information1
      ,p_pem_information2             =>    p_pem_information2
      ,p_pem_information3             =>    p_pem_information3
      ,p_pem_information4             =>    p_pem_information4
      ,p_pem_information5             =>    p_pem_information5
      ,p_pem_information6             =>    p_pem_information6
      ,p_pem_information7             =>    p_pem_information7
      ,p_pem_information8             =>    p_pem_information8
      ,p_pem_information9             =>    p_pem_information9
      ,p_pem_information10            =>    p_pem_information10
      ,p_pem_information11            =>    p_pem_information11
      ,p_pem_information12            =>    p_pem_information12
      ,p_pem_information13            =>    p_pem_information13
      ,p_pem_information14            =>    p_pem_information14
      ,p_pem_information15            =>    p_pem_information15
      ,p_pem_information16            =>    p_pem_information16
      ,p_pem_information17            =>    p_pem_information17
      ,p_pem_information18            =>    p_pem_information18
      ,p_pem_information19            =>    p_pem_information19
      ,p_pem_information20            =>    p_pem_information20
      ,p_pem_information21            =>    p_pem_information21
      ,p_pem_information22            =>    p_pem_information22
      ,p_pem_information23            =>    p_pem_information23
      ,p_pem_information24            =>    p_pem_information24
      ,p_pem_information25            =>    p_pem_information25
      ,p_pem_information26            =>    p_pem_information26
      ,p_pem_information27            =>    p_pem_information27
      ,p_pem_information28            =>    p_pem_information28
      ,p_pem_information29            =>    p_pem_information29
      ,p_pem_information30            =>    p_pem_information30
      ,p_object_version_number        =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name
                => 'hr_previous_employment_api.create_previous_employer'
        ,p_hook_type
                => 'AP'
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
  p_previous_employer_id   := l_previous_employer_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_previous_employer;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_previous_employer_id   := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_previous_employer;
    --
    -- set in out parameters and set out parameters
    --
    p_previous_employer_id   := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_previous_employer;
--
-- -----------------------------------------------------------------------
-- |------------------------< update_previous_employer >-----------------|
-- -----------------------------------------------------------------------
procedure update_previous_employer
(  p_effective_date             IN      date
  ,p_validate                   IN      boolean   default false
  ,p_previous_employer_id       IN      number
  ,p_start_date                 IN      date      default hr_api.g_date
  ,p_end_date                   IN      date      default hr_api.g_date
  ,p_period_years               IN      number    default hr_api.g_number
  ,p_period_months              IN      number    default hr_api.g_number
  ,p_period_days                IN      number    default hr_api.g_number
  ,p_employer_name              IN      varchar2  default hr_api.g_varchar2
  ,p_employer_country           IN      varchar2  default hr_api.g_varchar2
  ,p_employer_address           IN      varchar2  default hr_api.g_varchar2
  ,p_employer_type              IN      varchar2  default hr_api.g_varchar2
  ,p_employer_subtype           IN      varchar2  default hr_api.g_varchar2
  ,p_description                IN      varchar2  default hr_api.g_varchar2
  ,p_all_assignments            IN      varchar2  default 'N'
  ,p_pem_attribute_category     IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute1             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute2             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute3             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute4             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute5             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute6             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute7             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute8             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute9             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute10            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute11            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute12            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute13            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute14            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute15            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute16            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute17            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute18            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute19            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute20            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute21            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute22            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute23            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute24            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute25            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute26            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute27            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute28            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute29            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute30            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information_category   IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information1           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information2           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information3           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information4           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information5           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information6           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information7           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information8           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information9           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information10          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information11          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information12          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information13          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information14          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information15          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information16          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information17          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information18          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information19          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information20          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information21          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information22          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information23          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information24          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information25          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information26          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information27          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information28          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information29          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information30          IN      varchar2  default hr_api.g_varchar2
  ,p_object_version_number      IN OUT NOCOPY  number
  ) is
    l_proc                    varchar2(72)
                            := g_package||'update_previous_employer';
    l_previous_employer_id
                            per_previous_employers.previous_employer_id%type;
    l_object_version_number
                        per_previous_employers.object_version_number%type
                        :=  p_object_version_number;
    l_ovn per_previous_employers.object_version_number%type :=  p_object_version_number;
    l_business_group_id per_previous_employers.business_group_id%type;
    --
    l_start_date        per_previous_employers.start_date%type;
    l_end_date          per_previous_employers.end_date%type;
    --
    -- Bug 3702553: changed datatype from %type to number(10).
    --
    l_period_years      number(10)
                        := p_period_years;
    l_period_months     number(10)
                        := p_period_months;
    l_period_days       number(10)
                        := p_period_days;
    l_employer_type     per_previous_employers.employer_type%type
                        := p_employer_type;
    l_employer_subtype  per_previous_employers.employer_subtype%type;
    l_all_assignments    per_previous_employers.all_assignments%type
                        := p_all_assignments;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_previous_employer;
    --
    -- Truncate the time portion from all IN date parameters
    --
    l_start_date        :=  trunc(p_start_date);
    l_end_date          :=  trunc(p_end_date);
    --
    l_employer_subtype      :=  p_employer_subtype;
    -- Calculate Period Years and Days if null.
    --
    if p_period_years is null
       and p_period_months is null
       and p_period_days is null then
         per_pem_bus.get_period_values(l_start_date
                                      ,l_end_date
                                      ,l_period_years
                                      ,l_period_months
                                      ,l_period_days);
    end if;
    --
    if  p_employer_type is null then
      l_employer_type    := 'UK';
      l_employer_subtype := null;
    end if;
    --
    -- Call Before Process User Hook
    --
  begin
    hr_previous_employment_bk2.update_previous_employer_b
    (  p_effective_date           =>  p_effective_date
      ,p_previous_employer_id     =>  p_previous_employer_id
      ,p_start_date               =>  l_start_date
      ,p_end_date                 =>  l_end_date
      ,p_period_years             =>  l_period_years
      ,p_period_months            =>  l_period_months
      ,p_period_days              =>  l_period_days
      ,p_employer_name            =>  p_employer_name
      ,p_employer_country         =>  p_employer_country
      ,p_employer_address         =>  p_employer_address
      ,p_employer_type            =>  l_employer_type
      ,p_employer_subtype         =>  l_employer_subtype
      ,p_description              =>  p_description
      ,p_all_assignments          =>  l_all_assignments
      ,p_pem_attribute_category   =>  p_pem_attribute_category
      ,p_pem_attribute1           =>  p_pem_attribute1
      ,p_pem_attribute2           =>  p_pem_attribute2
      ,p_pem_attribute3           =>  p_pem_attribute3
      ,p_pem_attribute4           =>  p_pem_attribute4
      ,p_pem_attribute5           =>  p_pem_attribute5
      ,p_pem_attribute6           =>  p_pem_attribute6
      ,p_pem_attribute7           =>  p_pem_attribute7
      ,p_pem_attribute8           =>  p_pem_attribute8
      ,p_pem_attribute9           =>  p_pem_attribute9
      ,p_pem_attribute10          =>  p_pem_attribute10
      ,p_pem_attribute11          =>  p_pem_attribute11
      ,p_pem_attribute12          =>  p_pem_attribute12
      ,p_pem_attribute13          =>  p_pem_attribute13
      ,p_pem_attribute14          =>  p_pem_attribute14
      ,p_pem_attribute15          =>  p_pem_attribute15
      ,p_pem_attribute16          =>  p_pem_attribute16
      ,p_pem_attribute17          =>  p_pem_attribute17
      ,p_pem_attribute18          =>  p_pem_attribute18
      ,p_pem_attribute19          =>  p_pem_attribute19
      ,p_pem_attribute20          =>  p_pem_attribute20
      ,p_pem_attribute21          =>  p_pem_attribute21
      ,p_pem_attribute22          =>  p_pem_attribute22
      ,p_pem_attribute23          =>  p_pem_attribute23
      ,p_pem_attribute24          =>  p_pem_attribute24
      ,p_pem_attribute25          =>  p_pem_attribute25
      ,p_pem_attribute26          =>  p_pem_attribute26
      ,p_pem_attribute27          =>  p_pem_attribute27
      ,p_pem_attribute28          =>  p_pem_attribute28
      ,p_pem_attribute29          =>  p_pem_attribute29
      ,p_pem_attribute30          =>  p_pem_attribute30
      ,p_pem_information_category =>  p_pem_information_category
      ,p_pem_information1         =>  p_pem_information1
      ,p_pem_information2         =>  p_pem_information2
      ,p_pem_information3         =>  p_pem_information3
      ,p_pem_information4         =>  p_pem_information4
      ,p_pem_information5         =>  p_pem_information5
      ,p_pem_information6         =>  p_pem_information6
      ,p_pem_information7         =>  p_pem_information7
      ,p_pem_information8         =>  p_pem_information8
      ,p_pem_information9         =>  p_pem_information9
      ,p_pem_information10        =>  p_pem_information10
      ,p_pem_information11        =>  p_pem_information11
      ,p_pem_information12        =>  p_pem_information12
      ,p_pem_information13        =>  p_pem_information13
      ,p_pem_information14        =>  p_pem_information14
      ,p_pem_information15        =>  p_pem_information15
      ,p_pem_information16        =>  p_pem_information16
      ,p_pem_information17        =>  p_pem_information17
      ,p_pem_information18        =>  p_pem_information18
      ,p_pem_information19        =>  p_pem_information19
      ,p_pem_information20        =>  p_pem_information20
      ,p_pem_information21        =>  p_pem_information21
      ,p_pem_information22        =>  p_pem_information22
      ,p_pem_information23        =>  p_pem_information23
      ,p_pem_information24        =>  p_pem_information24
      ,p_pem_information25        =>  p_pem_information25
      ,p_pem_information26        =>  p_pem_information26
      ,p_pem_information27        =>  p_pem_information27
      ,p_pem_information28        =>  p_pem_information28
      ,p_pem_information29        =>  p_pem_information29
      ,p_pem_information30        =>  p_pem_information30
      ,p_object_version_number    =>  l_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name
                  => 'hr_previous_employment.update_previous_employer'
          ,p_hook_type
                  => 'BP'
          );
    end;
  --
  -- Call row handler procedure to update previous employer details
  --
  per_pem_upd.upd
   (   p_effective_date             =>  p_effective_date
      ,p_previous_employer_id       =>  p_previous_employer_id
      ,p_object_version_number      =>  l_object_version_number
      ,p_start_date                 =>  l_start_date
      ,p_end_date                   =>  l_end_date
      ,p_period_years               =>  l_period_years
      ,p_period_months              =>  l_period_months
      ,p_period_days                =>  l_period_days
      ,p_employer_name              =>  p_employer_name
      ,p_employer_country           =>  p_employer_country
      ,p_employer_address           =>  p_employer_address
      ,p_employer_type              =>  l_employer_type
      ,p_employer_subtype           =>  l_employer_subtype
      ,p_description                =>  p_description
      ,p_all_assignments            =>  l_all_assignments
      ,p_pem_attribute_category     =>  p_pem_attribute_category
      ,p_pem_attribute1             =>  p_pem_attribute1
      ,p_pem_attribute2             =>  p_pem_attribute2
      ,p_pem_attribute3             =>  p_pem_attribute3
      ,p_pem_attribute4             =>  p_pem_attribute4
      ,p_pem_attribute5             =>  p_pem_attribute5
      ,p_pem_attribute6             =>  p_pem_attribute6
      ,p_pem_attribute7             =>  p_pem_attribute7
      ,p_pem_attribute8             =>  p_pem_attribute8
      ,p_pem_attribute9             =>  p_pem_attribute9
      ,p_pem_attribute10            =>  p_pem_attribute10
      ,p_pem_attribute11            =>  p_pem_attribute11
      ,p_pem_attribute12            =>  p_pem_attribute12
      ,p_pem_attribute13            =>  p_pem_attribute13
      ,p_pem_attribute14            =>  p_pem_attribute14
      ,p_pem_attribute15            =>  p_pem_attribute15
      ,p_pem_attribute16            =>  p_pem_attribute16
      ,p_pem_attribute17            =>  p_pem_attribute17
      ,p_pem_attribute18            =>  p_pem_attribute18
      ,p_pem_attribute19            =>  p_pem_attribute19
      ,p_pem_attribute20            =>  p_pem_attribute20
      ,p_pem_attribute21            =>  p_pem_attribute21
      ,p_pem_attribute22            =>  p_pem_attribute22
      ,p_pem_attribute23            =>  p_pem_attribute23
      ,p_pem_attribute24            =>  p_pem_attribute24
      ,p_pem_attribute25            =>  p_pem_attribute25
      ,p_pem_attribute26            =>  p_pem_attribute26
      ,p_pem_attribute27            =>  p_pem_attribute27
      ,p_pem_attribute28            =>  p_pem_attribute28
      ,p_pem_attribute29            =>  p_pem_attribute29
      ,p_pem_attribute30            =>  p_pem_attribute30
      ,p_pem_information_category   =>  p_pem_information_category
      ,p_pem_information1           =>  p_pem_information1
      ,p_pem_information2           =>  p_pem_information2
      ,p_pem_information3           =>  p_pem_information3
      ,p_pem_information4           =>  p_pem_information4
      ,p_pem_information5           =>  p_pem_information5
      ,p_pem_information6           =>  p_pem_information6
      ,p_pem_information7           =>  p_pem_information7
      ,p_pem_information8           =>  p_pem_information8
      ,p_pem_information9           =>  p_pem_information9
      ,p_pem_information10          =>  p_pem_information10
      ,p_pem_information11          =>  p_pem_information11
      ,p_pem_information12          =>  p_pem_information12
      ,p_pem_information13          =>  p_pem_information13
      ,p_pem_information14          =>  p_pem_information14
      ,p_pem_information15          =>  p_pem_information15
      ,p_pem_information16          =>  p_pem_information16
      ,p_pem_information17          =>  p_pem_information17
      ,p_pem_information18          =>  p_pem_information18
      ,p_pem_information19          =>  p_pem_information19
      ,p_pem_information20          =>  p_pem_information20
      ,p_pem_information21          =>  p_pem_information21
      ,p_pem_information22          =>  p_pem_information22
      ,p_pem_information23          =>  p_pem_information23
      ,p_pem_information24          =>  p_pem_information24
      ,p_pem_information25          =>  p_pem_information25
      ,p_pem_information26          =>  p_pem_information26
      ,p_pem_information27          =>  p_pem_information27
      ,p_pem_information28          =>  p_pem_information28
      ,p_pem_information29          =>  p_pem_information29
      ,p_pem_information30          =>  p_pem_information30
      );
  begin
    hr_previous_employment_bk2.update_previous_employer_a
    (  p_effective_date           =>  p_effective_date
      ,p_previous_employer_id     =>  p_previous_employer_id
      ,p_start_date               =>  l_start_date
      ,p_end_date                 =>  l_end_date
      ,p_period_years             =>  l_period_years
      ,p_period_months            =>  l_period_months
      ,p_period_days              =>  l_period_days
      ,p_employer_name            =>  p_employer_name
      ,p_employer_country         =>  p_employer_country
      ,p_employer_address         =>  p_employer_address
      ,p_employer_type            =>  l_employer_type
      ,p_employer_subtype         =>  l_employer_subtype
      ,p_description              =>  p_description
      ,p_all_assignments          =>  l_all_assignments
      ,p_pem_attribute_category   =>  p_pem_attribute_category
      ,p_pem_attribute1           =>  p_pem_attribute1
      ,p_pem_attribute2           =>  p_pem_attribute2
      ,p_pem_attribute3           =>  p_pem_attribute3
      ,p_pem_attribute4           =>  p_pem_attribute4
      ,p_pem_attribute5           =>  p_pem_attribute5
      ,p_pem_attribute6           =>  p_pem_attribute6
      ,p_pem_attribute7           =>  p_pem_attribute7
      ,p_pem_attribute8           =>  p_pem_attribute8
      ,p_pem_attribute9           =>  p_pem_attribute9
      ,p_pem_attribute10          =>  p_pem_attribute10
      ,p_pem_attribute11          =>  p_pem_attribute11
      ,p_pem_attribute12          =>  p_pem_attribute12
      ,p_pem_attribute13          =>  p_pem_attribute13
      ,p_pem_attribute14          =>  p_pem_attribute14
      ,p_pem_attribute15          =>  p_pem_attribute15
      ,p_pem_attribute16          =>  p_pem_attribute16
      ,p_pem_attribute17          =>  p_pem_attribute17
      ,p_pem_attribute18          =>  p_pem_attribute18
      ,p_pem_attribute19          =>  p_pem_attribute19
      ,p_pem_attribute20          =>  p_pem_attribute20
      ,p_pem_attribute21          =>  p_pem_attribute21
      ,p_pem_attribute22          =>  p_pem_attribute22
      ,p_pem_attribute23          =>  p_pem_attribute23
      ,p_pem_attribute24          =>  p_pem_attribute24
      ,p_pem_attribute25          =>  p_pem_attribute25
      ,p_pem_attribute26          =>  p_pem_attribute26
      ,p_pem_attribute27          =>  p_pem_attribute27
      ,p_pem_attribute28          =>  p_pem_attribute28
      ,p_pem_attribute29          =>  p_pem_attribute29
      ,p_pem_attribute30          =>  p_pem_attribute30
      ,p_pem_information_category =>  p_pem_information_category
      ,p_pem_information1         =>  p_pem_information1
      ,p_pem_information2         =>  p_pem_information2
      ,p_pem_information3         =>  p_pem_information3
      ,p_pem_information4         =>  p_pem_information4
      ,p_pem_information5         =>  p_pem_information5
      ,p_pem_information6         =>  p_pem_information6
      ,p_pem_information7         =>  p_pem_information7
      ,p_pem_information8         =>  p_pem_information8
      ,p_pem_information9         =>  p_pem_information9
      ,p_pem_information10        =>  p_pem_information10
      ,p_pem_information11        =>  p_pem_information11
      ,p_pem_information12        =>  p_pem_information12
      ,p_pem_information13        =>  p_pem_information13
      ,p_pem_information14        =>  p_pem_information14
      ,p_pem_information15        =>  p_pem_information15
      ,p_pem_information16        =>  p_pem_information16
      ,p_pem_information17        =>  p_pem_information17
      ,p_pem_information18        =>  p_pem_information18
      ,p_pem_information19        =>  p_pem_information19
      ,p_pem_information20        =>  p_pem_information20
      ,p_pem_information21        =>  p_pem_information21
      ,p_pem_information22        =>  p_pem_information22
      ,p_pem_information23        =>  p_pem_information23
      ,p_pem_information24        =>  p_pem_information24
      ,p_pem_information25        =>  p_pem_information25
      ,p_pem_information26        =>  p_pem_information26
      ,p_pem_information27        =>  p_pem_information27
      ,p_pem_information28        =>  p_pem_information28
      ,p_pem_information29        =>  p_pem_information29
      ,p_pem_information30        =>  p_pem_information30
      ,p_object_version_number    =>  l_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name
              => 'hr_previous_employment_api.update_previous_employer'
          ,p_hook_type
              => 'AP'
          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
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
    rollback to update_previous_employer;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- IN OUT parameter should be reset to its IN value
    -- therefore no need to reset p_object_version_number
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_previous_employer;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_previous_employer;
--
-- -----------------------------------------------------------------------
-- |----------------------< delete_previous_employer >-------------------|
-- -----------------------------------------------------------------------
--
procedure delete_previous_employer
  (p_validate                      in     boolean  default false
  ,p_previous_employer_id          in     number
  ,p_object_version_number         in out nocopy number
  )
 is
  l_proc                   varchar2(72)
                           := g_package||'delete_previous_employer';
  l_previous_employer_id   per_previous_employers.previous_employer_id%TYPE;
  l_object_version_number  per_previous_employers.object_version_number%TYPE
                           := p_object_version_number;
  l_ovn per_previous_employers.object_version_number%TYPE := p_object_version_number;
    --
    -- Define cursor to select all the previous jobs of a
    -- perticular employer
    --
    cursor csr_previous_jobs(t_previous_employer_id number) is
      select   previous_job_id
              ,object_version_number
      from     per_previous_jobs
      where    previous_employer_id = t_previous_employer_id;
    --
    cursor csr_previous_job_usages(t_previous_employer_id number) is
      select  previous_job_usage_id
             ,object_version_number
      from    per_previous_job_usages
      where   previous_employer_id = t_previous_employer_id;
    --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_previous_employer;
  --
  -- Call Before Process User Hook
  --
    begin
    hr_previous_employment_bk3.delete_previous_employer_b
      (p_previous_employer_id          => p_previous_employer_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name
              => 'hr_previous_employment_api.delete_previous_employer'
        ,p_hook_type
              => 'BP'
        );
    end;
    --
    -- Process Logic
    -- Impliment Cascading delete on per_previous_jobs table
    -- when a previous_employer is deleted
      for pjo in csr_previous_jobs(p_previous_employer_id) loop
        hr_previous_employment_api.delete_previous_job
        (p_validate               =>  false
        ,p_previous_job_id        =>  pjo.previous_job_id
        ,p_object_version_number  =>  pjo.object_version_number
        );
      end loop;
    -- End of logic to cascade delete all the previous jobs of a perticular
    -- previous employer
    --
    -- Impliment cascading delete on per_previous_job_usages table
    -- when a previous employer_id is deleted
      for pju in csr_previous_job_usages(p_previous_employer_id) loop
        hr_previous_employment_api.delete_previous_job_usage
        (p_validate               =>  false
        ,p_previous_job_usage_id  =>  pju.previous_job_usage_id
        ,p_object_version_number  =>  pju.object_version_number);
      end loop;
    -- End of logic to cascade delete all the previous job usages of a
    -- perticular previous employer
    --
    -- Call row handler procedure to delete previous employer details
    --
      per_pem_del.del
      (p_previous_employer_id       =>  p_previous_employer_id
      ,p_object_version_number      =>  l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
      begin
    hr_previous_employment_bk3.delete_previous_employer_a
      (p_previous_employer_id          => p_previous_employer_id
      ,p_object_version_number         => l_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name
                => 'hr_previous_employment_api.delete_previous_employer'
            ,p_hook_type
                => 'AP'
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
      --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_previous_employer;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- IN OUT parameter should be reset to its IN value therefore
    -- no need to set p_object_version_number
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_previous_employer;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_previous_employer;
--
-- -----------------------------------------------------------------------
-- |--------------------------< create_previous_job >--------------------|
-- -----------------------------------------------------------------------
--
procedure create_previous_job
(  p_effective_date                 in     date
  ,p_validate                       in     boolean  default false
  ,p_previous_employer_id           in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_period_years                   in     number   default null
  ,p_period_months                  in     number   default null
  ,p_period_days                    in     number   default null
  ,p_job_name                       in     varchar2 default null
  ,p_employment_category            in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_all_assignments                in     varchar2 default 'N'
  ,p_pjo_attribute_category         in     varchar2 default null
  ,p_pjo_attribute1                 in     varchar2 default null
  ,p_pjo_attribute2                 in     varchar2 default null
  ,p_pjo_attribute3                 in     varchar2 default null
  ,p_pjo_attribute4                 in     varchar2 default null
  ,p_pjo_attribute5                 in     varchar2 default null
  ,p_pjo_attribute6                 in     varchar2 default null
  ,p_pjo_attribute7                 in     varchar2 default null
  ,p_pjo_attribute8                 in     varchar2 default null
  ,p_pjo_attribute9                 in     varchar2 default null
  ,p_pjo_attribute10                in     varchar2 default null
  ,p_pjo_attribute11                in     varchar2 default null
  ,p_pjo_attribute12                in     varchar2 default null
  ,p_pjo_attribute13                in     varchar2 default null
  ,p_pjo_attribute14                in     varchar2 default null
  ,p_pjo_attribute15                in     varchar2 default null
  ,p_pjo_attribute16                in     varchar2 default null
  ,p_pjo_attribute17                in     varchar2 default null
  ,p_pjo_attribute18                in     varchar2 default null
  ,p_pjo_attribute19                in     varchar2 default null
  ,p_pjo_attribute20                in     varchar2 default null
  ,p_pjo_attribute21                in     varchar2 default null
  ,p_pjo_attribute22                in     varchar2 default null
  ,p_pjo_attribute23                in     varchar2 default null
  ,p_pjo_attribute24                in     varchar2 default null
  ,p_pjo_attribute25                in     varchar2 default null
  ,p_pjo_attribute26                in     varchar2 default null
  ,p_pjo_attribute27                in     varchar2 default null
  ,p_pjo_attribute28                in     varchar2 default null
  ,p_pjo_attribute29                in     varchar2 default null
  ,p_pjo_attribute30                in     varchar2 default null
  ,p_pjo_information_category       in     varchar2 default null
  ,p_pjo_information1               in     varchar2 default null
  ,p_pjo_information2               in     varchar2 default null
  ,p_pjo_information3               in     varchar2 default null
  ,p_pjo_information4               in     varchar2 default null
  ,p_pjo_information5               in     varchar2 default null
  ,p_pjo_information6               in     varchar2 default null
  ,p_pjo_information7               in     varchar2 default null
  ,p_pjo_information8               in     varchar2 default null
  ,p_pjo_information9               in     varchar2 default null
  ,p_pjo_information10              in     varchar2 default null
  ,p_pjo_information11              in     varchar2 default null
  ,p_pjo_information12              in     varchar2 default null
  ,p_pjo_information13              in     varchar2 default null
  ,p_pjo_information14              in     varchar2 default null
  ,p_pjo_information15              in     varchar2 default null
  ,p_pjo_information16              in     varchar2 default null
  ,p_pjo_information17              in     varchar2 default null
  ,p_pjo_information18              in     varchar2 default null
  ,p_pjo_information19              in     varchar2 default null
  ,p_pjo_information20              in     varchar2 default null
  ,p_pjo_information21              in     varchar2 default null
  ,p_pjo_information22              in     varchar2 default null
  ,p_pjo_information23              in     varchar2 default null
  ,p_pjo_information24              in     varchar2 default null
  ,p_pjo_information25              in     varchar2 default null
  ,p_pjo_information26              in     varchar2 default null
  ,p_pjo_information27              in     varchar2 default null
  ,p_pjo_information28              in     varchar2 default null
  ,p_pjo_information29              in     varchar2 default null
  ,p_pjo_information30              in     varchar2 default null
  ,p_previous_job_id                out nocopy    number
  ,p_object_version_number          out nocopy    number
  ) is
  -- Declare cursors and local variables
  --
    l_flag                  varchar2(30);
    l_proc                  varchar2(72)
                            := g_package||'create_previous_job';
    --
    l_start_date            per_previous_jobs.start_date%type;
    l_end_date              per_previous_jobs.end_date%type;
    --
    l_previous_job_id       per_previous_jobs.previous_job_id%type;
    l_object_version_number  per_previous_jobs.object_version_number%type;
    --
    l_period_years          per_previous_employers.period_years%type;
    l_period_months         per_previous_employers.period_months%type;
    l_period_days           per_previous_employers.period_days%type;
    --
    l_all_assignments   per_previous_jobs.all_assignments%type;
 begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_previous_job;
  --
  -- Truncate the time portion from all IN date parameters
  l_start_date      :=  trunc(p_start_date);
  l_end_date        :=  trunc(p_end_date);
  --
  l_period_years    :=  p_period_years;
  l_period_months   :=  p_period_months;
  l_period_days     :=  p_period_days;
  --
  l_all_assignments :=  p_all_assignments;
  --
    if p_period_years is null
       and p_period_months is null
       and p_period_days is null then
         per_pem_bus.get_period_values(l_start_date
                                      ,l_end_date
                                      ,l_period_years
                                      ,l_period_months
                                      ,l_period_days);
    end if;
    --
    -- Call Before Process User Hook
    --
   begin
   hr_previous_employment_bk4.create_previous_job_b
      (p_effective_date                 =>     p_effective_date
      ,p_previous_employer_id           =>     p_previous_employer_id
      ,p_start_date                     =>     l_start_date
      ,p_end_date                       =>     l_end_date
      ,p_period_years                   =>     l_period_years
      ,p_period_months                  =>     l_period_months
      ,p_period_days                    =>     l_period_days
      ,p_job_name                       =>     p_job_name
      ,p_employment_category            =>     p_employment_category
      ,p_description                    =>     p_description
      ,p_all_assignments                =>     l_all_assignments
      ,p_pjo_attribute_category         =>     p_pjo_attribute_category
      ,p_pjo_attribute1                 =>     p_pjo_attribute1
      ,p_pjo_attribute2                 =>     p_pjo_attribute2
      ,p_pjo_attribute3                 =>     p_pjo_attribute3
      ,p_pjo_attribute4                 =>     p_pjo_attribute4
      ,p_pjo_attribute5                 =>     p_pjo_attribute5
      ,p_pjo_attribute6                 =>     p_pjo_attribute6
      ,p_pjo_attribute7                 =>     p_pjo_attribute7
      ,p_pjo_attribute8                 =>     p_pjo_attribute8
      ,p_pjo_attribute9                 =>     p_pjo_attribute9
      ,p_pjo_attribute10                =>     p_pjo_attribute10
      ,p_pjo_attribute11                =>     p_pjo_attribute11
      ,p_pjo_attribute12                =>     p_pjo_attribute12
      ,p_pjo_attribute13                =>     p_pjo_attribute13
      ,p_pjo_attribute14                =>     p_pjo_attribute14
      ,p_pjo_attribute15                =>     p_pjo_attribute15
      ,p_pjo_attribute16                =>     p_pjo_attribute16
      ,p_pjo_attribute17                =>     p_pjo_attribute17
      ,p_pjo_attribute18                =>     p_pjo_attribute18
      ,p_pjo_attribute19                =>     p_pjo_attribute19
      ,p_pjo_attribute20                =>     p_pjo_attribute20
      ,p_pjo_attribute21                =>     p_pjo_attribute21
      ,p_pjo_attribute22                =>     p_pjo_attribute22
      ,p_pjo_attribute23                =>     p_pjo_attribute23
      ,p_pjo_attribute24                =>     p_pjo_attribute24
      ,p_pjo_attribute25                =>     p_pjo_attribute25
      ,p_pjo_attribute26                =>     p_pjo_attribute26
      ,p_pjo_attribute27                =>     p_pjo_attribute27
      ,p_pjo_attribute28                =>     p_pjo_attribute28
      ,p_pjo_attribute29                =>     p_pjo_attribute29
      ,p_pjo_attribute30                =>     p_pjo_attribute30
      ,p_pjo_information_category       =>     p_pjo_information_category
      ,p_pjo_information1               =>     p_pjo_information1
      ,p_pjo_information2               =>     p_pjo_information2
      ,p_pjo_information3               =>     p_pjo_information3
      ,p_pjo_information4               =>     p_pjo_information4
      ,p_pjo_information5               =>     p_pjo_information5
      ,p_pjo_information6               =>     p_pjo_information6
      ,p_pjo_information7               =>     p_pjo_information7
      ,p_pjo_information8               =>     p_pjo_information8
      ,p_pjo_information9               =>     p_pjo_information9
      ,p_pjo_information10              =>     p_pjo_information10
      ,p_pjo_information11              =>     p_pjo_information11
      ,p_pjo_information12              =>     p_pjo_information12
      ,p_pjo_information13              =>     p_pjo_information13
      ,p_pjo_information14              =>     p_pjo_information14
      ,p_pjo_information15              =>     p_pjo_information15
      ,p_pjo_information16              =>     p_pjo_information16
      ,p_pjo_information17              =>     p_pjo_information17
      ,p_pjo_information18              =>     p_pjo_information18
      ,p_pjo_information19              =>     p_pjo_information19
      ,p_pjo_information20              =>     p_pjo_information20
      ,p_pjo_information21              =>     p_pjo_information21
      ,p_pjo_information22              =>     p_pjo_information22
      ,p_pjo_information23              =>     p_pjo_information23
      ,p_pjo_information24              =>     p_pjo_information24
      ,p_pjo_information25              =>     p_pjo_information25
      ,p_pjo_information26              =>     p_pjo_information26
      ,p_pjo_information27              =>     p_pjo_information27
      ,p_pjo_information28              =>     p_pjo_information28
      ,p_pjo_information29              =>     p_pjo_information29
      ,p_pjo_information30              =>     p_pjo_information30
      ,p_object_version_number          =>     l_object_version_number
      );
   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name
                => 'hr_previous_employment_api.create_previous_job'
          ,p_hook_type
                => 'BP'
          );
   end;
  --
  -- Validation in addition to Row Handlers
  -- Process Logic
  per_pjo_ins.ins
    (p_effective_date                 =>     p_effective_date
    ,p_previous_employer_id           =>     p_previous_employer_id
    ,p_start_date                     =>     l_start_date
    ,p_end_date                       =>     l_end_date
    ,p_period_years                   =>     l_period_years
    ,p_period_months                  =>     l_period_months
    ,p_period_days                    =>     l_period_days
    ,p_job_name                       =>     p_job_name
    ,p_employment_category            =>     p_employment_category
    ,p_description                    =>     p_description
    ,p_all_assignments                =>     l_all_assignments
    ,p_pjo_attribute_category         =>     p_pjo_attribute_category
    ,p_pjo_attribute1                 =>     p_pjo_attribute1
    ,p_pjo_attribute2                 =>     p_pjo_attribute2
    ,p_pjo_attribute3                 =>     p_pjo_attribute3
    ,p_pjo_attribute4                 =>     p_pjo_attribute4
    ,p_pjo_attribute5                 =>     p_pjo_attribute5
    ,p_pjo_attribute6                 =>     p_pjo_attribute6
    ,p_pjo_attribute7                 =>     p_pjo_attribute7
    ,p_pjo_attribute8                 =>     p_pjo_attribute8
    ,p_pjo_attribute9                 =>     p_pjo_attribute9
    ,p_pjo_attribute10                =>     p_pjo_attribute10
    ,p_pjo_attribute11                =>     p_pjo_attribute11
    ,p_pjo_attribute12                =>     p_pjo_attribute12
    ,p_pjo_attribute13                =>     p_pjo_attribute13
    ,p_pjo_attribute14                =>     p_pjo_attribute14
    ,p_pjo_attribute15                =>     p_pjo_attribute15
    ,p_pjo_attribute16                =>     p_pjo_attribute16
    ,p_pjo_attribute17                =>     p_pjo_attribute17
    ,p_pjo_attribute18                =>     p_pjo_attribute18
    ,p_pjo_attribute19                =>     p_pjo_attribute19
    ,p_pjo_attribute20                =>     p_pjo_attribute20
    ,p_pjo_attribute21                =>     p_pjo_attribute21
    ,p_pjo_attribute22                =>     p_pjo_attribute22
    ,p_pjo_attribute23                =>     p_pjo_attribute23
    ,p_pjo_attribute24                =>     p_pjo_attribute24
    ,p_pjo_attribute25                =>     p_pjo_attribute25
    ,p_pjo_attribute26                =>     p_pjo_attribute26
    ,p_pjo_attribute27                =>     p_pjo_attribute27
    ,p_pjo_attribute28                =>     p_pjo_attribute28
    ,p_pjo_attribute29                =>     p_pjo_attribute29
    ,p_pjo_attribute30                =>     p_pjo_attribute30
    ,p_pjo_information_category       =>     p_pjo_information_category
    ,p_pjo_information1               =>     p_pjo_information1
    ,p_pjo_information2               =>     p_pjo_information2
    ,p_pjo_information3               =>     p_pjo_information3
    ,p_pjo_information4               =>     p_pjo_information4
    ,p_pjo_information5               =>     p_pjo_information5
    ,p_pjo_information6               =>     p_pjo_information6
    ,p_pjo_information7               =>     p_pjo_information7
    ,p_pjo_information8               =>     p_pjo_information8
    ,p_pjo_information9               =>     p_pjo_information9
    ,p_pjo_information10              =>     p_pjo_information10
    ,p_pjo_information11              =>     p_pjo_information11
    ,p_pjo_information12              =>     p_pjo_information12
    ,p_pjo_information13              =>     p_pjo_information13
    ,p_pjo_information14              =>     p_pjo_information14
    ,p_pjo_information15              =>     p_pjo_information15
    ,p_pjo_information16              =>     p_pjo_information16
    ,p_pjo_information17              =>     p_pjo_information17
    ,p_pjo_information18              =>     p_pjo_information18
    ,p_pjo_information19              =>     p_pjo_information19
    ,p_pjo_information20              =>     p_pjo_information20
    ,p_pjo_information21              =>     p_pjo_information21
    ,p_pjo_information22              =>     p_pjo_information22
    ,p_pjo_information23              =>     p_pjo_information23
    ,p_pjo_information24              =>     p_pjo_information24
    ,p_pjo_information25              =>     p_pjo_information25
    ,p_pjo_information26              =>     p_pjo_information26
    ,p_pjo_information27              =>     p_pjo_information27
    ,p_pjo_information28              =>     p_pjo_information28
    ,p_pjo_information29              =>     p_pjo_information29
    ,p_pjo_information30              =>     p_pjo_information30
    ,p_previous_job_id                =>     l_previous_job_id
    ,p_object_version_number          =>     l_object_version_number
    );
-- Call After Process User Hook
--
  begin
   hr_previous_employment_bk4.create_previous_job_a
      (p_effective_date                 =>     p_effective_date
      ,p_previous_job_id                =>     p_previous_job_id
      ,p_previous_employer_id           =>     p_previous_employer_id
      ,p_start_date                     =>     l_start_date
      ,p_end_date                       =>     l_end_date
      ,p_period_years                   =>     l_period_years
      ,p_period_months                  =>     l_period_months
      ,p_period_days                    =>     l_period_days
      ,p_job_name                       =>     p_job_name
      ,p_employment_category            =>     p_employment_category
      ,p_description                    =>     p_description
      ,p_all_assignments                =>     l_all_assignments
      ,p_pjo_attribute_category         =>     p_pjo_attribute_category
      ,p_pjo_attribute1                 =>     p_pjo_attribute1
      ,p_pjo_attribute2                 =>     p_pjo_attribute2
      ,p_pjo_attribute3                 =>     p_pjo_attribute3
      ,p_pjo_attribute4                 =>     p_pjo_attribute4
      ,p_pjo_attribute5                 =>     p_pjo_attribute5
      ,p_pjo_attribute6                 =>     p_pjo_attribute6
      ,p_pjo_attribute7                 =>     p_pjo_attribute7
      ,p_pjo_attribute8                 =>     p_pjo_attribute8
      ,p_pjo_attribute9                 =>     p_pjo_attribute9
      ,p_pjo_attribute10                =>     p_pjo_attribute10
      ,p_pjo_attribute11                =>     p_pjo_attribute11
      ,p_pjo_attribute12                =>     p_pjo_attribute12
      ,p_pjo_attribute13                =>     p_pjo_attribute13
      ,p_pjo_attribute14                =>     p_pjo_attribute14
      ,p_pjo_attribute15                =>     p_pjo_attribute15
      ,p_pjo_attribute16                =>     p_pjo_attribute16
      ,p_pjo_attribute17                =>     p_pjo_attribute17
      ,p_pjo_attribute18                =>     p_pjo_attribute18
      ,p_pjo_attribute19                =>     p_pjo_attribute19
      ,p_pjo_attribute20                =>     p_pjo_attribute20
      ,p_pjo_attribute21                =>     p_pjo_attribute21
      ,p_pjo_attribute22                =>     p_pjo_attribute22
      ,p_pjo_attribute23                =>     p_pjo_attribute23
      ,p_pjo_attribute24                =>     p_pjo_attribute24
      ,p_pjo_attribute25                =>     p_pjo_attribute25
      ,p_pjo_attribute26                =>     p_pjo_attribute26
      ,p_pjo_attribute27                =>     p_pjo_attribute27
      ,p_pjo_attribute28                =>     p_pjo_attribute28
      ,p_pjo_attribute29                =>     p_pjo_attribute29
      ,p_pjo_attribute30                =>     p_pjo_attribute30
      ,p_pjo_information_category       =>     p_pjo_information_category
      ,p_pjo_information1               =>     p_pjo_information1
      ,p_pjo_information2               =>     p_pjo_information2
      ,p_pjo_information3               =>     p_pjo_information3
      ,p_pjo_information4               =>     p_pjo_information4
      ,p_pjo_information5               =>     p_pjo_information5
      ,p_pjo_information6               =>     p_pjo_information6
      ,p_pjo_information7               =>     p_pjo_information7
      ,p_pjo_information8               =>     p_pjo_information8
      ,p_pjo_information9               =>     p_pjo_information9
      ,p_pjo_information10              =>     p_pjo_information10
      ,p_pjo_information11              =>     p_pjo_information11
      ,p_pjo_information12              =>     p_pjo_information12
      ,p_pjo_information13              =>     p_pjo_information13
      ,p_pjo_information14              =>     p_pjo_information14
      ,p_pjo_information15              =>     p_pjo_information15
      ,p_pjo_information16              =>     p_pjo_information16
      ,p_pjo_information17              =>     p_pjo_information17
      ,p_pjo_information18              =>     p_pjo_information18
      ,p_pjo_information19              =>     p_pjo_information19
      ,p_pjo_information20              =>     p_pjo_information20
      ,p_pjo_information21              =>     p_pjo_information21
      ,p_pjo_information22              =>     p_pjo_information22
      ,p_pjo_information23              =>     p_pjo_information23
      ,p_pjo_information24              =>     p_pjo_information24
      ,p_pjo_information25              =>     p_pjo_information25
      ,p_pjo_information26              =>     p_pjo_information26
      ,p_pjo_information27              =>     p_pjo_information27
      ,p_pjo_information28              =>     p_pjo_information28
      ,p_pjo_information29              =>     p_pjo_information29
      ,p_pjo_information30              =>     p_pjo_information30
      ,p_object_version_number          =>     l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'hr_previous_employment_api.create_previous_job'
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
  p_previous_job_id         := l_previous_job_id;
  p_object_version_number    := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_previous_job;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_previous_job_id      := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_previous_job;
    --
    -- set in out parameters and set out parameters
    --
    p_previous_job_id      := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_previous_job;
--
-- -----------------------------------------------------------------------
-- |-------------------------< update_previous_job >---------------------|
-- -----------------------------------------------------------------------
--
procedure update_previous_job
  (p_effective_date               in     date
  ,p_validate                     in     boolean   default false
  ,p_previous_job_id              in     number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_job_name                     in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default 'N'
  ,p_pjo_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ) is
  l_proc                    varchar2(72)
                            := g_package||'update_previous_job';
  l_previous_employer_id    per_previous_jobs.previous_employer_id%type;
  l_object_version_number    per_previous_jobs.object_version_number%type
                            := p_object_version_number;
  l_ovn per_previous_jobs.object_version_number%type := p_object_version_number;
  l_business_group_id        per_previous_employers.business_group_id%type;
  --
  l_start_date        per_previous_jobs.start_date%type;
  l_end_date          per_previous_jobs.end_date%type;
  --
  l_period_years      Number(10); --per_previous_jobs.period_years%type;
  l_period_months   Number(10);  --per_previous_jobs.period_months%type;
  l_period_days       Number(10); --per_previous_jobs.period_days%type;
  --
  l_all_assignments    per_previous_jobs.all_assignments%type;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_previous_job;
    --
    -- Truncate the time portion from all IN date parameters
    --
    l_start_date      :=  trunc(p_start_date);
    l_end_date        :=  trunc(p_end_date);
    --
    l_period_years    :=  p_period_years;
    l_period_months   :=  p_period_months;
    l_period_days     :=  p_period_days;
    --
    l_all_assignments :=  p_all_assignments;
    --
      if p_period_years is null
         and p_period_months is null
         and p_period_days is null then
           per_pem_bus.get_period_values(l_start_date
                                        ,l_end_date
                                        ,l_period_years
                                        ,l_period_months
                                        ,l_period_days);
    end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_previous_employment_bk5.update_previous_job_b
      (p_effective_date                 =>     p_effective_date
      ,p_previous_job_id                =>     p_previous_job_id
      ,p_start_date                     =>     l_start_date
      ,p_end_date                       =>     l_end_date
      ,p_period_years                   =>     l_period_years
      ,p_period_months                  =>     l_period_months
      ,p_period_days                    =>     l_period_days
      ,p_job_name                       =>     p_job_name
      ,p_employment_category            =>     p_employment_category
      ,p_description                    =>     p_description
      ,p_all_assignments                =>     l_all_assignments
      ,p_pjo_attribute_category         =>     p_pjo_attribute_category
      ,p_pjo_attribute1                 =>     p_pjo_attribute1
      ,p_pjo_attribute2                 =>     p_pjo_attribute2
      ,p_pjo_attribute3                 =>     p_pjo_attribute3
      ,p_pjo_attribute4                 =>     p_pjo_attribute4
      ,p_pjo_attribute5                 =>     p_pjo_attribute5
      ,p_pjo_attribute6                 =>     p_pjo_attribute6
      ,p_pjo_attribute7                 =>     p_pjo_attribute7
      ,p_pjo_attribute8                 =>     p_pjo_attribute8
      ,p_pjo_attribute9                 =>     p_pjo_attribute9
      ,p_pjo_attribute10                =>     p_pjo_attribute10
      ,p_pjo_attribute11                =>     p_pjo_attribute11
      ,p_pjo_attribute12                =>     p_pjo_attribute12
      ,p_pjo_attribute13                =>     p_pjo_attribute13
      ,p_pjo_attribute14                =>     p_pjo_attribute14
      ,p_pjo_attribute15                =>     p_pjo_attribute15
      ,p_pjo_attribute16                =>     p_pjo_attribute16
      ,p_pjo_attribute17                =>     p_pjo_attribute17
      ,p_pjo_attribute18                =>     p_pjo_attribute18
      ,p_pjo_attribute19                =>     p_pjo_attribute19
      ,p_pjo_attribute20                =>     p_pjo_attribute20
      ,p_pjo_attribute21                =>     p_pjo_attribute21
      ,p_pjo_attribute22                =>     p_pjo_attribute22
      ,p_pjo_attribute23                =>     p_pjo_attribute23
      ,p_pjo_attribute24                =>     p_pjo_attribute24
      ,p_pjo_attribute25                =>     p_pjo_attribute25
      ,p_pjo_attribute26                =>     p_pjo_attribute26
      ,p_pjo_attribute27                =>     p_pjo_attribute27
      ,p_pjo_attribute28                =>     p_pjo_attribute28
      ,p_pjo_attribute29                =>     p_pjo_attribute29
      ,p_pjo_attribute30                =>     p_pjo_attribute30
      ,p_pjo_information_category       =>     p_pjo_information_category
      ,p_pjo_information1               =>     p_pjo_information1
      ,p_pjo_information2               =>     p_pjo_information2
      ,p_pjo_information3               =>     p_pjo_information3
      ,p_pjo_information4               =>     p_pjo_information4
      ,p_pjo_information5               =>     p_pjo_information5
      ,p_pjo_information6               =>     p_pjo_information6
      ,p_pjo_information7               =>     p_pjo_information7
      ,p_pjo_information8               =>     p_pjo_information8
      ,p_pjo_information9               =>     p_pjo_information9
      ,p_pjo_information10              =>     p_pjo_information10
      ,p_pjo_information11              =>     p_pjo_information11
      ,p_pjo_information12              =>     p_pjo_information12
      ,p_pjo_information13              =>     p_pjo_information13
      ,p_pjo_information14              =>     p_pjo_information14
      ,p_pjo_information15              =>     p_pjo_information15
      ,p_pjo_information16              =>     p_pjo_information16
      ,p_pjo_information17              =>     p_pjo_information17
      ,p_pjo_information18              =>     p_pjo_information18
      ,p_pjo_information19              =>     p_pjo_information19
      ,p_pjo_information20              =>     p_pjo_information20
      ,p_pjo_information21              =>     p_pjo_information21
      ,p_pjo_information22              =>     p_pjo_information22
      ,p_pjo_information23              =>     p_pjo_information23
      ,p_pjo_information24              =>     p_pjo_information24
      ,p_pjo_information25              =>     p_pjo_information25
      ,p_pjo_information26              =>     p_pjo_information26
      ,p_pjo_information27              =>     p_pjo_information27
      ,p_pjo_information28              =>     p_pjo_information28
      ,p_pjo_information29              =>     p_pjo_information29
      ,p_pjo_information30              =>     p_pjo_information30
      ,p_object_version_number          =>     l_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'hr_previous_employment.update_previous_job'
          ,p_hook_type   => 'BP'
          );
    end;
  --
  -- Call row handler procedure to update previous employer details
  --
  per_pjo_upd.upd
    (p_effective_date               =>     p_effective_date
    ,p_previous_job_id              =>     p_previous_job_id
    ,p_object_version_number        =>     l_object_version_number
    ,p_start_date                   =>     l_start_date
    ,p_end_date                     =>     l_end_date
    ,p_period_years                 =>     l_period_years
    ,p_period_months                =>     l_period_months
    ,p_period_days                  =>     l_period_days
    ,p_job_name                     =>     p_job_name
    ,p_employment_category          =>     p_employment_category
    ,p_description                  =>     p_description
    ,p_all_assignments              =>     l_all_assignments
    ,p_pjo_attribute_category       =>     p_pjo_attribute_category
    ,p_pjo_attribute1               =>     p_pjo_attribute1
    ,p_pjo_attribute2               =>     p_pjo_attribute2
    ,p_pjo_attribute3               =>     p_pjo_attribute3
    ,p_pjo_attribute4               =>     p_pjo_attribute4
    ,p_pjo_attribute5               =>     p_pjo_attribute5
    ,p_pjo_attribute6               =>     p_pjo_attribute6
    ,p_pjo_attribute7               =>     p_pjo_attribute7
    ,p_pjo_attribute8               =>     p_pjo_attribute8
    ,p_pjo_attribute9               =>     p_pjo_attribute9
    ,p_pjo_attribute10              =>     p_pjo_attribute10
    ,p_pjo_attribute11              =>     p_pjo_attribute11
    ,p_pjo_attribute12              =>     p_pjo_attribute12
    ,p_pjo_attribute13              =>     p_pjo_attribute13
    ,p_pjo_attribute14              =>     p_pjo_attribute14
    ,p_pjo_attribute15              =>     p_pjo_attribute15
    ,p_pjo_attribute16              =>     p_pjo_attribute16
    ,p_pjo_attribute17              =>     p_pjo_attribute17
    ,p_pjo_attribute18              =>     p_pjo_attribute18
    ,p_pjo_attribute19              =>     p_pjo_attribute19
    ,p_pjo_attribute20              =>     p_pjo_attribute20
    ,p_pjo_attribute21              =>     p_pjo_attribute21
    ,p_pjo_attribute22              =>     p_pjo_attribute22
    ,p_pjo_attribute23              =>     p_pjo_attribute23
    ,p_pjo_attribute24              =>     p_pjo_attribute24
    ,p_pjo_attribute25              =>     p_pjo_attribute25
    ,p_pjo_attribute26              =>     p_pjo_attribute26
    ,p_pjo_attribute27              =>     p_pjo_attribute27
    ,p_pjo_attribute28              =>     p_pjo_attribute28
    ,p_pjo_attribute29              =>     p_pjo_attribute29
    ,p_pjo_attribute30              =>     p_pjo_attribute30
    ,p_pjo_information_category     =>     p_pjo_information_category
    ,p_pjo_information1             =>     p_pjo_information1
    ,p_pjo_information2             =>     p_pjo_information2
    ,p_pjo_information3             =>     p_pjo_information3
    ,p_pjo_information4             =>     p_pjo_information4
    ,p_pjo_information5             =>     p_pjo_information5
    ,p_pjo_information6             =>     p_pjo_information6
    ,p_pjo_information7             =>     p_pjo_information7
    ,p_pjo_information8             =>     p_pjo_information8
    ,p_pjo_information9             =>     p_pjo_information9
    ,p_pjo_information10            =>     p_pjo_information10
    ,p_pjo_information11            =>     p_pjo_information11
    ,p_pjo_information12            =>     p_pjo_information12
    ,p_pjo_information13            =>     p_pjo_information13
    ,p_pjo_information14            =>     p_pjo_information14
    ,p_pjo_information15            =>     p_pjo_information15
    ,p_pjo_information16            =>     p_pjo_information16
    ,p_pjo_information17            =>     p_pjo_information17
    ,p_pjo_information18            =>     p_pjo_information18
    ,p_pjo_information19            =>     p_pjo_information19
    ,p_pjo_information20            =>     p_pjo_information20
    ,p_pjo_information21            =>     p_pjo_information21
    ,p_pjo_information22            =>     p_pjo_information22
    ,p_pjo_information23            =>     p_pjo_information23
    ,p_pjo_information24            =>     p_pjo_information24
    ,p_pjo_information25            =>     p_pjo_information25
    ,p_pjo_information26            =>     p_pjo_information26
    ,p_pjo_information27            =>     p_pjo_information27
    ,p_pjo_information28            =>     p_pjo_information28
    ,p_pjo_information29            =>     p_pjo_information29
    ,p_pjo_information30            =>     p_pjo_information30
    );
  begin
    hr_previous_employment_bk5.update_previous_job_a
      (p_effective_date                 =>     p_effective_date
      ,p_previous_job_id                =>     p_previous_job_id
      ,p_start_date                     =>     l_start_date
      ,p_end_date                       =>     l_end_date
      ,p_period_years                   =>     l_period_years
      ,p_period_months                  =>     l_period_months
      ,p_period_days                    =>     l_period_days
      ,p_job_name                       =>     p_job_name
      ,p_employment_category            =>     p_employment_category
      ,p_description                    =>     p_description
      ,p_all_assignments                =>     l_all_assignments
      ,p_pjo_attribute_category         =>     p_pjo_attribute_category
      ,p_pjo_attribute1                 =>     p_pjo_attribute1
      ,p_pjo_attribute2                 =>     p_pjo_attribute2
      ,p_pjo_attribute3                 =>     p_pjo_attribute3
      ,p_pjo_attribute4                 =>     p_pjo_attribute4
      ,p_pjo_attribute5                 =>     p_pjo_attribute5
      ,p_pjo_attribute6                 =>     p_pjo_attribute6
      ,p_pjo_attribute7                 =>     p_pjo_attribute7
      ,p_pjo_attribute8                 =>     p_pjo_attribute8
      ,p_pjo_attribute9                 =>     p_pjo_attribute9
      ,p_pjo_attribute10                =>     p_pjo_attribute10
      ,p_pjo_attribute11                =>     p_pjo_attribute11
      ,p_pjo_attribute12                =>     p_pjo_attribute12
      ,p_pjo_attribute13                =>     p_pjo_attribute13
      ,p_pjo_attribute14                =>     p_pjo_attribute14
      ,p_pjo_attribute15                =>     p_pjo_attribute15
      ,p_pjo_attribute16                =>     p_pjo_attribute16
      ,p_pjo_attribute17                =>     p_pjo_attribute17
      ,p_pjo_attribute18                =>     p_pjo_attribute18
      ,p_pjo_attribute19                =>     p_pjo_attribute19
      ,p_pjo_attribute20                =>     p_pjo_attribute20
      ,p_pjo_attribute21                =>     p_pjo_attribute21
      ,p_pjo_attribute22                =>     p_pjo_attribute22
      ,p_pjo_attribute23                =>     p_pjo_attribute23
      ,p_pjo_attribute24                =>     p_pjo_attribute24
      ,p_pjo_attribute25                =>     p_pjo_attribute25
      ,p_pjo_attribute26                =>     p_pjo_attribute26
      ,p_pjo_attribute27                =>     p_pjo_attribute27
      ,p_pjo_attribute28                =>     p_pjo_attribute28
      ,p_pjo_attribute29                =>     p_pjo_attribute29
      ,p_pjo_attribute30                =>     p_pjo_attribute30
      ,p_pjo_information_category       =>     p_pjo_information_category
      ,p_pjo_information1               =>     p_pjo_information1
      ,p_pjo_information2               =>     p_pjo_information2
      ,p_pjo_information3               =>     p_pjo_information3
      ,p_pjo_information4               =>     p_pjo_information4
      ,p_pjo_information5               =>     p_pjo_information5
      ,p_pjo_information6               =>     p_pjo_information6
      ,p_pjo_information7               =>     p_pjo_information7
      ,p_pjo_information8               =>     p_pjo_information8
      ,p_pjo_information9               =>     p_pjo_information9
      ,p_pjo_information10              =>     p_pjo_information10
      ,p_pjo_information11              =>     p_pjo_information11
      ,p_pjo_information12              =>     p_pjo_information12
      ,p_pjo_information13              =>     p_pjo_information13
      ,p_pjo_information14              =>     p_pjo_information14
      ,p_pjo_information15              =>     p_pjo_information15
      ,p_pjo_information16              =>     p_pjo_information16
      ,p_pjo_information17              =>     p_pjo_information17
      ,p_pjo_information18              =>     p_pjo_information18
      ,p_pjo_information19              =>     p_pjo_information19
      ,p_pjo_information20              =>     p_pjo_information20
      ,p_pjo_information21              =>     p_pjo_information21
      ,p_pjo_information22              =>     p_pjo_information22
      ,p_pjo_information23              =>     p_pjo_information23
      ,p_pjo_information24              =>     p_pjo_information24
      ,p_pjo_information25              =>     p_pjo_information25
      ,p_pjo_information26              =>     p_pjo_information26
      ,p_pjo_information27              =>     p_pjo_information27
      ,p_pjo_information28              =>     p_pjo_information28
      ,p_pjo_information29              =>     p_pjo_information29
      ,p_pjo_information30              =>     p_pjo_information30
      ,p_object_version_number          =>     l_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'hr_previous_employment_api.update_previous_job'
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
    rollback to update_previous_job;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- IN OUT parameter should be reset to its IN value
    -- therefore no need to reset p_object_version_number
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_previous_job;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_previous_job;
--
-- -----------------------------------------------------------------------
-- |-------------------------< delete_previous_job >---------------------|
-- -----------------------------------------------------------------------
--
procedure delete_previous_job
  (p_validate                      in     boolean  default false
  ,p_previous_job_id               in     number
  ,p_object_version_number         in out nocopy number
  ) is
l_proc                    varchar2(72)
                          := g_package||'delete_previous_job';
l_previous_employer_id    per_previous_jobs.previous_employer_id%type;
l_object_version_number   per_previous_jobs.object_version_number%type
                          := p_object_version_number;
l_ovn per_previous_jobs.object_version_number%type := p_object_version_number;
  --
  -- Cursor for all the records in previous job usages
    cursor csr_pju is
      select  previous_job_usage_id
             ,object_version_number
      from    per_previous_job_usages
      where   previous_job_id = p_previous_job_id;
  -- Cursor for all the records in previous job extra info
    cursor csr_pji is
      select  previous_job_extra_info_id
             ,object_version_number
      from    per_prev_job_extra_info
      where   previous_job_id = p_previous_job_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_previous_job;
  --
  -- Call Before Process User Hook
  --
    begin
    hr_previous_employment_bk6.delete_previous_job_b
      (p_previous_job_id          =>  p_previous_job_id
      ,p_object_version_number    =>  l_object_version_number
      );
    exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name
                => 'hr_previous_employment_api.delete_previous_employer'
        ,p_hook_type
                => 'BP'
        );
    end;
    --
    -- Process Logic
    -- Delete associated Previous Job Usage records
    for pju in csr_pju loop
      hr_previous_employment_api.delete_previous_job_usage
        (p_validate               =>  false
        ,p_previous_job_usage_id  =>  pju.previous_job_usage_id
        ,p_object_version_number  =>  pju.object_version_number
        );
    end loop;
    --
    -- Delete associated Previous Job Extra Info records
    for pji_rec in csr_pji loop
      hr_previous_employment_api.delete_prev_job_extra_info
        (p_validate                   =>  false
        ,p_previous_job_extra_info_id =>  pji_rec.previous_job_extra_info_id
        ,p_object_version_number      =>  pji_rec.object_version_number
        );
    end loop;
    --
    -- Call row handler procedure to delete previous job details
    --
      per_pjo_del.del
      (p_previous_job_id       => p_previous_job_id
      ,p_object_version_number => l_object_version_number
      );
    --
    -- Call After Process User Hook
    --
        begin
    hr_previous_employment_bk6.delete_previous_job_a
      (p_previous_job_id          =>  p_previous_job_id
      ,p_object_version_number    =>  l_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'hr_previous_employment_api.delete_previous_job'
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
      --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_previous_job;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- IN OUT parameter should be reset to its IN value therefore
    -- no need to set p_object_version_number
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_previous_job;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_previous_job;
--
--
-- -----------------------------------------------------------------------
-- |-------------------------< create_prev_job_extra_info >--------------|
-- -----------------------------------------------------------------------
--
procedure create_prev_job_extra_info
  (p_validate                       in  boolean   default false
  ,p_previous_job_id                in  number
  ,p_information_type               in  varchar2  default null
  ,p_pji_attribute_category         in  varchar2  default null
  ,p_pji_attribute1                 in  varchar2  default null
  ,p_pji_attribute2                 in  varchar2  default null
  ,p_pji_attribute3                 in  varchar2  default null
  ,p_pji_attribute4                 in  varchar2  default null
  ,p_pji_attribute5                 in  varchar2  default null
  ,p_pji_attribute6                 in  varchar2  default null
  ,p_pji_attribute7                 in  varchar2  default null
  ,p_pji_attribute8                 in  varchar2  default null
  ,p_pji_attribute9                 in  varchar2  default null
  ,p_pji_attribute10                in  varchar2  default null
  ,p_pji_attribute11                in  varchar2  default null
  ,p_pji_attribute12                in  varchar2  default null
  ,p_pji_attribute13                in  varchar2  default null
  ,p_pji_attribute14                in  varchar2  default null
  ,p_pji_attribute15                in  varchar2  default null
  ,p_pji_attribute16                in  varchar2  default null
  ,p_pji_attribute17                in  varchar2  default null
  ,p_pji_attribute18                in  varchar2  default null
  ,p_pji_attribute19                in  varchar2  default null
  ,p_pji_attribute20                in  varchar2  default null
  ,p_pji_attribute21                in  varchar2  default null
  ,p_pji_attribute22                in  varchar2  default null
  ,p_pji_attribute23                in  varchar2  default null
  ,p_pji_attribute24                in  varchar2  default null
  ,p_pji_attribute25                in  varchar2  default null
  ,p_pji_attribute26                in  varchar2  default null
  ,p_pji_attribute27                in  varchar2  default null
  ,p_pji_attribute28                in  varchar2  default null
  ,p_pji_attribute29                in  varchar2  default null
  ,p_pji_attribute30                in  varchar2  default null
  ,p_pji_information_category       in  varchar2  default null
  ,p_pji_information1               in  varchar2  default null
  ,p_pji_information2               in  varchar2  default null
  ,p_pji_information3               in  varchar2  default null
  ,p_pji_information4               in  varchar2  default null
  ,p_pji_information5               in  varchar2  default null
  ,p_pji_information6               in  varchar2  default null
  ,p_pji_information7               in  varchar2  default null
  ,p_pji_information8               in  varchar2  default null
  ,p_pji_information9               in  varchar2  default null
  ,p_pji_information10              in  varchar2  default null
  ,p_pji_information11              in  varchar2  default null
  ,p_pji_information12              in  varchar2  default null
  ,p_pji_information13              in  varchar2  default null
  ,p_pji_information14              in  varchar2  default null
  ,p_pji_information15              in  varchar2  default null
  ,p_pji_information16              in  varchar2  default null
  ,p_pji_information17              in  varchar2  default null
  ,p_pji_information18              in  varchar2  default null
  ,p_pji_information19              in  varchar2  default null
  ,p_pji_information20              in  varchar2  default null
  ,p_pji_information21              in  varchar2  default null
  ,p_pji_information22              in  varchar2  default null
  ,p_pji_information23              in  varchar2  default null
  ,p_pji_information24              in  varchar2  default null
  ,p_pji_information25              in  varchar2  default null
  ,p_pji_information26              in  varchar2  default null
  ,p_pji_information27              in  varchar2  default null
  ,p_pji_information28              in  varchar2  default null
  ,p_pji_information29              in  varchar2  default null
  ,p_pji_information30              in  varchar2  default null
  ,p_previous_job_extra_info_id     out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_flag        varchar2(30);
  l_previous_job_extra_info_id
                per_prev_job_extra_info.previous_job_extra_info_id%type;
  l_object_version_number
                per_prev_job_extra_info.object_version_number%type;
  l_proc        varchar2(72) := g_package||'create_prev_job_extra_info';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_prev_job_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
        hr_previous_employment_bka.create_prev_job_extra_info_b
       (p_previous_job_id                =>     p_previous_job_id
       ,p_information_type               =>     p_information_type
       ,p_pji_attribute_category         =>     p_pji_attribute_category
       ,p_pji_attribute1                 =>     p_pji_attribute1
       ,p_pji_attribute2                 =>     p_pji_attribute2
       ,p_pji_attribute3                 =>     p_pji_attribute3
       ,p_pji_attribute4                 =>     p_pji_attribute4
       ,p_pji_attribute5                 =>     p_pji_attribute5
       ,p_pji_attribute6                 =>     p_pji_attribute6
       ,p_pji_attribute7                 =>     p_pji_attribute7
       ,p_pji_attribute8                 =>     p_pji_attribute8
       ,p_pji_attribute9                 =>     p_pji_attribute9
       ,p_pji_attribute10                =>     p_pji_attribute10
       ,p_pji_attribute11                =>     p_pji_attribute11
       ,p_pji_attribute12                =>     p_pji_attribute12
       ,p_pji_attribute13                =>     p_pji_attribute13
       ,p_pji_attribute14                =>     p_pji_attribute14
       ,p_pji_attribute15                =>     p_pji_attribute15
       ,p_pji_attribute16                =>     p_pji_attribute16
       ,p_pji_attribute17                =>     p_pji_attribute17
       ,p_pji_attribute18                =>     p_pji_attribute18
       ,p_pji_attribute19                =>     p_pji_attribute19
       ,p_pji_attribute20                =>     p_pji_attribute20
       ,p_pji_attribute21                =>     p_pji_attribute21
       ,p_pji_attribute22                =>     p_pji_attribute22
       ,p_pji_attribute23                =>     p_pji_attribute23
       ,p_pji_attribute24                =>     p_pji_attribute24
       ,p_pji_attribute25                =>     p_pji_attribute25
       ,p_pji_attribute26                =>     p_pji_attribute26
       ,p_pji_attribute27                =>     p_pji_attribute27
       ,p_pji_attribute28                =>     p_pji_attribute28
       ,p_pji_attribute29                =>     p_pji_attribute29
       ,p_pji_attribute30                =>     p_pji_attribute30
       ,p_pji_information_category       =>     p_pji_information_category
       ,p_pji_information1               =>     p_pji_information1
       ,p_pji_information2               =>     p_pji_information2
       ,p_pji_information3               =>     p_pji_information3
       ,p_pji_information4               =>     p_pji_information4
       ,p_pji_information5               =>     p_pji_information5
       ,p_pji_information6               =>     p_pji_information6
       ,p_pji_information7               =>     p_pji_information7
       ,p_pji_information8               =>     p_pji_information8
       ,p_pji_information9               =>     p_pji_information9
       ,p_pji_information10              =>     p_pji_information10
       ,p_pji_information11              =>     p_pji_information11
       ,p_pji_information12              =>     p_pji_information12
       ,p_pji_information13              =>     p_pji_information13
       ,p_pji_information14              =>     p_pji_information14
       ,p_pji_information15              =>     p_pji_information15
       ,p_pji_information16              =>     p_pji_information16
       ,p_pji_information17              =>     p_pji_information17
       ,p_pji_information18              =>     p_pji_information18
       ,p_pji_information19              =>     p_pji_information19
       ,p_pji_information20              =>     p_pji_information20
       ,p_pji_information21              =>     p_pji_information21
       ,p_pji_information22              =>     p_pji_information22
       ,p_pji_information23              =>     p_pji_information23
       ,p_pji_information24              =>     p_pji_information24
       ,p_pji_information25              =>     p_pji_information25
       ,p_pji_information26              =>     p_pji_information26
       ,p_pji_information27              =>     p_pji_information27
       ,p_pji_information28              =>     p_pji_information28
       ,p_pji_information29              =>     p_pji_information29
       ,p_pji_information30              =>     p_pji_information30
       ,p_object_version_number          =>     l_object_version_number
       );
  exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_prev_job_extra_info'
          ,p_hook_type   => 'BP'
          );
  end;
  --
  -- Validation in addition to Row Handlers
  -- Process Logic
  per_pji_ins.ins
  (p_previous_job_id                =>     p_previous_job_id
  ,p_information_type               =>     p_information_type
  ,p_pji_attribute_category         =>     p_pji_attribute_category
  ,p_pji_attribute1                 =>     p_pji_attribute1
  ,p_pji_attribute2                 =>     p_pji_attribute2
  ,p_pji_attribute3                 =>     p_pji_attribute3
  ,p_pji_attribute4                 =>     p_pji_attribute4
  ,p_pji_attribute5                 =>     p_pji_attribute5
  ,p_pji_attribute6                 =>     p_pji_attribute6
  ,p_pji_attribute7                 =>     p_pji_attribute7
  ,p_pji_attribute8                 =>     p_pji_attribute8
  ,p_pji_attribute9                 =>     p_pji_attribute9
  ,p_pji_attribute10                =>     p_pji_attribute10
  ,p_pji_attribute11                =>     p_pji_attribute11
  ,p_pji_attribute12                =>     p_pji_attribute12
  ,p_pji_attribute13                =>     p_pji_attribute13
  ,p_pji_attribute14                =>     p_pji_attribute14
  ,p_pji_attribute15                =>     p_pji_attribute15
  ,p_pji_attribute16                =>     p_pji_attribute16
  ,p_pji_attribute17                =>     p_pji_attribute17
  ,p_pji_attribute18                =>     p_pji_attribute18
  ,p_pji_attribute19                =>     p_pji_attribute19
  ,p_pji_attribute20                =>     p_pji_attribute20
  ,p_pji_attribute21                =>     p_pji_attribute21
  ,p_pji_attribute22                =>     p_pji_attribute22
  ,p_pji_attribute23                =>     p_pji_attribute23
  ,p_pji_attribute24                =>     p_pji_attribute24
  ,p_pji_attribute25                =>     p_pji_attribute25
  ,p_pji_attribute26                =>     p_pji_attribute26
  ,p_pji_attribute27                =>     p_pji_attribute27
  ,p_pji_attribute28                =>     p_pji_attribute28
  ,p_pji_attribute29                =>     p_pji_attribute29
  ,p_pji_attribute30                =>     p_pji_attribute30
  ,p_pji_information_category       =>     p_pji_information_category
  ,p_pji_information1               =>     p_pji_information1
  ,p_pji_information2               =>     p_pji_information2
  ,p_pji_information3               =>     p_pji_information3
  ,p_pji_information4               =>     p_pji_information4
  ,p_pji_information5               =>     p_pji_information5
  ,p_pji_information6               =>     p_pji_information6
  ,p_pji_information7               =>     p_pji_information7
  ,p_pji_information8               =>     p_pji_information8
  ,p_pji_information9               =>     p_pji_information9
  ,p_pji_information10              =>     p_pji_information10
  ,p_pji_information11              =>     p_pji_information11
  ,p_pji_information12              =>     p_pji_information12
  ,p_pji_information13              =>     p_pji_information13
  ,p_pji_information14              =>     p_pji_information14
  ,p_pji_information15              =>     p_pji_information15
  ,p_pji_information16              =>     p_pji_information16
  ,p_pji_information17              =>     p_pji_information17
  ,p_pji_information18              =>     p_pji_information18
  ,p_pji_information19              =>     p_pji_information19
  ,p_pji_information20              =>     p_pji_information20
  ,p_pji_information21              =>     p_pji_information21
  ,p_pji_information22              =>     p_pji_information22
  ,p_pji_information23              =>     p_pji_information23
  ,p_pji_information24              =>     p_pji_information24
  ,p_pji_information25              =>     p_pji_information25
  ,p_pji_information26              =>     p_pji_information26
  ,p_pji_information27              =>     p_pji_information27
  ,p_pji_information28              =>     p_pji_information28
  ,p_pji_information29              =>     p_pji_information29
  ,p_pji_information30              =>     p_pji_information30
  ,p_previous_job_extra_info_id     =>     l_previous_job_extra_info_id
  ,p_object_version_number          =>     l_object_version_number
  );
  -- Call After Process User Hook
  --
  begin
       hr_previous_employment_bka.create_prev_job_extra_info_a
       (p_previous_job_id                =>     p_previous_job_id
       ,p_information_type               =>     p_information_type
       ,p_pji_attribute_category         =>     p_pji_attribute_category
       ,p_pji_attribute1                 =>     p_pji_attribute1
       ,p_pji_attribute2                 =>     p_pji_attribute2
       ,p_pji_attribute3                 =>     p_pji_attribute3
       ,p_pji_attribute4                 =>     p_pji_attribute4
       ,p_pji_attribute5                 =>     p_pji_attribute5
       ,p_pji_attribute6                 =>     p_pji_attribute6
       ,p_pji_attribute7                 =>     p_pji_attribute7
       ,p_pji_attribute8                 =>     p_pji_attribute8
       ,p_pji_attribute9                 =>     p_pji_attribute9
       ,p_pji_attribute10                =>     p_pji_attribute10
       ,p_pji_attribute11                =>     p_pji_attribute11
       ,p_pji_attribute12                =>     p_pji_attribute12
       ,p_pji_attribute13                =>     p_pji_attribute13
       ,p_pji_attribute14                =>     p_pji_attribute14
       ,p_pji_attribute15                =>     p_pji_attribute15
       ,p_pji_attribute16                =>     p_pji_attribute16
       ,p_pji_attribute17                =>     p_pji_attribute17
       ,p_pji_attribute18                =>     p_pji_attribute18
       ,p_pji_attribute19                =>     p_pji_attribute19
       ,p_pji_attribute20                =>     p_pji_attribute20
       ,p_pji_attribute21                =>     p_pji_attribute21
       ,p_pji_attribute22                =>     p_pji_attribute22
       ,p_pji_attribute23                =>     p_pji_attribute23
       ,p_pji_attribute24                =>     p_pji_attribute24
       ,p_pji_attribute25                =>     p_pji_attribute25
       ,p_pji_attribute26                =>     p_pji_attribute26
       ,p_pji_attribute27                =>     p_pji_attribute27
       ,p_pji_attribute28                =>     p_pji_attribute28
       ,p_pji_attribute29                =>     p_pji_attribute29
       ,p_pji_attribute30                =>     p_pji_attribute30
       ,p_pji_information_category       =>     p_pji_information_category
       ,p_pji_information1               =>     p_pji_information1
       ,p_pji_information2               =>     p_pji_information2
       ,p_pji_information3               =>     p_pji_information3
       ,p_pji_information4               =>     p_pji_information4
       ,p_pji_information5               =>     p_pji_information5
       ,p_pji_information6               =>     p_pji_information6
       ,p_pji_information7               =>     p_pji_information7
       ,p_pji_information8               =>     p_pji_information8
       ,p_pji_information9               =>     p_pji_information9
       ,p_pji_information10              =>     p_pji_information10
       ,p_pji_information11              =>     p_pji_information11
       ,p_pji_information12              =>     p_pji_information12
       ,p_pji_information13              =>     p_pji_information13
       ,p_pji_information14              =>     p_pji_information14
       ,p_pji_information15              =>     p_pji_information15
       ,p_pji_information16              =>     p_pji_information16
       ,p_pji_information17              =>     p_pji_information17
       ,p_pji_information18              =>     p_pji_information18
       ,p_pji_information19              =>     p_pji_information19
       ,p_pji_information20              =>     p_pji_information20
       ,p_pji_information21              =>     p_pji_information21
       ,p_pji_information22              =>     p_pji_information22
       ,p_pji_information23              =>     p_pji_information23
       ,p_pji_information24              =>     p_pji_information24
       ,p_pji_information25              =>     p_pji_information25
       ,p_pji_information26              =>     p_pji_information26
       ,p_pji_information27              =>     p_pji_information27
       ,p_pji_information28              =>     p_pji_information28
       ,p_pji_information29              =>     p_pji_information29
       ,p_pji_information30              =>     p_pji_information30
       ,p_previous_job_extra_info_id     =>     l_previous_job_extra_info_id
       ,p_object_version_number          =>     l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_prev_job_extra_info'
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
  p_object_version_number       := l_object_version_number;
  p_previous_job_extra_info_id  := l_previous_job_extra_info_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_prev_job_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_previous_job_extra_info_id    := null;
    p_object_version_number          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_prev_job_extra_info;
    --
    -- set in out parameters and set out parameters
    --
    p_previous_job_extra_info_id    := null;
    p_object_version_number          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_prev_job_extra_info;
--
-- -----------------------------------------------------------------------
-- |------------------------< update_prev_job_extra_info >---------------|
-- -----------------------------------------------------------------------
procedure update_prev_job_extra_info
     (p_validate                     in boolean  default false
     ,p_previous_job_id              in number
     ,p_information_type             in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute_category       in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute1               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute2               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute3               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute4               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute5               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute6               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute7               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute8               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute9               in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute10              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute11              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute12              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute13              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute14              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute15              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute16              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute17              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute18              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute19              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute20              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute21              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute22              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute23              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute24              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute25              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute26              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute27              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute28              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute29              in varchar2 default hr_api.g_varchar2
     ,p_pji_attribute30              in varchar2 default hr_api.g_varchar2
     ,p_pji_information_category     in varchar2 default hr_api.g_varchar2
     ,p_pji_information1             in varchar2 default hr_api.g_varchar2
     ,p_pji_information2             in varchar2 default hr_api.g_varchar2
     ,p_pji_information3             in varchar2 default hr_api.g_varchar2
     ,p_pji_information4             in varchar2 default hr_api.g_varchar2
     ,p_pji_information5             in varchar2 default hr_api.g_varchar2
     ,p_pji_information6             in varchar2 default hr_api.g_varchar2
     ,p_pji_information7             in varchar2 default hr_api.g_varchar2
     ,p_pji_information8             in varchar2 default hr_api.g_varchar2
     ,p_pji_information9             in varchar2 default hr_api.g_varchar2
     ,p_pji_information10            in varchar2 default hr_api.g_varchar2
     ,p_pji_information11            in varchar2 default hr_api.g_varchar2
     ,p_pji_information12            in varchar2 default hr_api.g_varchar2
     ,p_pji_information13            in varchar2 default hr_api.g_varchar2
     ,p_pji_information14            in varchar2 default hr_api.g_varchar2
     ,p_pji_information15            in varchar2 default hr_api.g_varchar2
     ,p_pji_information16            in varchar2 default hr_api.g_varchar2
     ,p_pji_information17            in varchar2 default hr_api.g_varchar2
     ,p_pji_information18            in varchar2 default hr_api.g_varchar2
     ,p_pji_information19            in varchar2 default hr_api.g_varchar2
     ,p_pji_information20            in varchar2 default hr_api.g_varchar2
     ,p_pji_information21            in varchar2 default hr_api.g_varchar2
     ,p_pji_information22            in varchar2 default hr_api.g_varchar2
     ,p_pji_information23            in varchar2 default hr_api.g_varchar2
     ,p_pji_information24            in varchar2 default hr_api.g_varchar2
     ,p_pji_information25            in varchar2 default hr_api.g_varchar2
     ,p_pji_information26            in varchar2 default hr_api.g_varchar2
     ,p_pji_information27            in varchar2 default hr_api.g_varchar2
     ,p_pji_information28            in varchar2 default hr_api.g_varchar2
     ,p_pji_information29            in varchar2 default hr_api.g_varchar2
     ,p_pji_information30            in varchar2 default hr_api.g_varchar2
     ,p_previous_job_extra_info_id   in number
     ,p_object_version_number        in out nocopy number
     ) is
     --
     l_proc      varchar2(72) := g_package||'update_prev_job_extra_info';
     l_object_version_number
                 per_prev_job_extra_info.object_version_number%type
                              :=  p_object_version_number;
    l_ovn per_prev_job_extra_info.object_version_number%type :=  p_object_version_number;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_prev_job_extra_info;
    --
      -- Call Before Process User Hook
    --
  begin
        hr_previous_employment_bkb.update_prev_job_extra_info_b
       (p_previous_job_id                =>     p_previous_job_id
       ,p_information_type               =>     p_information_type
       ,p_pji_attribute_category         =>     p_pji_attribute_category
       ,p_pji_attribute1                 =>     p_pji_attribute1
       ,p_pji_attribute2                 =>     p_pji_attribute2
       ,p_pji_attribute3                 =>     p_pji_attribute3
       ,p_pji_attribute4                 =>     p_pji_attribute4
       ,p_pji_attribute5                 =>     p_pji_attribute5
       ,p_pji_attribute6                 =>     p_pji_attribute6
       ,p_pji_attribute7                 =>     p_pji_attribute7
       ,p_pji_attribute8                 =>     p_pji_attribute8
       ,p_pji_attribute9                 =>     p_pji_attribute9
       ,p_pji_attribute10                =>     p_pji_attribute10
       ,p_pji_attribute11                =>     p_pji_attribute11
       ,p_pji_attribute12                =>     p_pji_attribute12
       ,p_pji_attribute13                =>     p_pji_attribute13
       ,p_pji_attribute14                =>     p_pji_attribute14
       ,p_pji_attribute15                =>     p_pji_attribute15
       ,p_pji_attribute16                =>     p_pji_attribute16
       ,p_pji_attribute17                =>     p_pji_attribute17
       ,p_pji_attribute18                =>     p_pji_attribute18
       ,p_pji_attribute19                =>     p_pji_attribute19
       ,p_pji_attribute20                =>     p_pji_attribute20
       ,p_pji_attribute21                =>     p_pji_attribute21
       ,p_pji_attribute22                =>     p_pji_attribute22
       ,p_pji_attribute23                =>     p_pji_attribute23
       ,p_pji_attribute24                =>     p_pji_attribute24
       ,p_pji_attribute25                =>     p_pji_attribute25
       ,p_pji_attribute26                =>     p_pji_attribute26
       ,p_pji_attribute27                =>     p_pji_attribute27
       ,p_pji_attribute28                =>     p_pji_attribute28
       ,p_pji_attribute29                =>     p_pji_attribute29
       ,p_pji_attribute30                =>     p_pji_attribute30
       ,p_pji_information_category       =>     p_pji_information_category
       ,p_pji_information1               =>     p_pji_information1
       ,p_pji_information2               =>     p_pji_information2
       ,p_pji_information3               =>     p_pji_information3
       ,p_pji_information4               =>     p_pji_information4
       ,p_pji_information5               =>     p_pji_information5
       ,p_pji_information6               =>     p_pji_information6
       ,p_pji_information7               =>     p_pji_information7
       ,p_pji_information8               =>     p_pji_information8
       ,p_pji_information9               =>     p_pji_information9
       ,p_pji_information10              =>     p_pji_information10
       ,p_pji_information11              =>     p_pji_information11
       ,p_pji_information12              =>     p_pji_information12
       ,p_pji_information13              =>     p_pji_information13
       ,p_pji_information14              =>     p_pji_information14
       ,p_pji_information15              =>     p_pji_information15
       ,p_pji_information16              =>     p_pji_information16
       ,p_pji_information17              =>     p_pji_information17
       ,p_pji_information18              =>     p_pji_information18
       ,p_pji_information19              =>     p_pji_information19
       ,p_pji_information20              =>     p_pji_information20
       ,p_pji_information21              =>     p_pji_information21
       ,p_pji_information22              =>     p_pji_information22
       ,p_pji_information23              =>     p_pji_information23
       ,p_pji_information24              =>     p_pji_information24
       ,p_pji_information25              =>     p_pji_information25
       ,p_pji_information26              =>     p_pji_information26
       ,p_pji_information27              =>     p_pji_information27
       ,p_pji_information28              =>     p_pji_information28
       ,p_pji_information29              =>     p_pji_information29
       ,p_pji_information30              =>     p_pji_information30
       ,p_previous_job_extra_info_id     =>     p_previous_job_extra_info_id
       ,p_object_version_number          =>     l_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'update_prev_job_extra_info'
          ,p_hook_type   => 'BP'
          );
    end;
    --
  -- Call row handler procedure to update previous job extra info
  --
    per_pji_upd.upd
    (p_previous_job_extra_info_id   =>     p_previous_job_extra_info_id
    ,p_object_version_number        =>     l_object_version_number
    ,p_previous_job_id              =>     p_previous_job_id
    ,p_information_type             =>     p_information_type
    ,p_pji_attribute_category       =>     p_pji_attribute_category
    ,p_pji_attribute1               =>     p_pji_attribute1
    ,p_pji_attribute2               =>     p_pji_attribute2
    ,p_pji_attribute3               =>     p_pji_attribute3
    ,p_pji_attribute4               =>     p_pji_attribute4
    ,p_pji_attribute5               =>     p_pji_attribute5
    ,p_pji_attribute6               =>     p_pji_attribute6
    ,p_pji_attribute7               =>     p_pji_attribute7
    ,p_pji_attribute8               =>     p_pji_attribute8
    ,p_pji_attribute9               =>     p_pji_attribute9
    ,p_pji_attribute10              =>     p_pji_attribute10
    ,p_pji_attribute11              =>     p_pji_attribute11
    ,p_pji_attribute12              =>     p_pji_attribute12
    ,p_pji_attribute13              =>     p_pji_attribute13
    ,p_pji_attribute14              =>     p_pji_attribute14
    ,p_pji_attribute15              =>     p_pji_attribute15
    ,p_pji_attribute16              =>     p_pji_attribute16
    ,p_pji_attribute17              =>     p_pji_attribute17
    ,p_pji_attribute18              =>     p_pji_attribute18
    ,p_pji_attribute19              =>     p_pji_attribute19
    ,p_pji_attribute20              =>     p_pji_attribute20
    ,p_pji_attribute21              =>     p_pji_attribute21
    ,p_pji_attribute22              =>     p_pji_attribute22
    ,p_pji_attribute23              =>     p_pji_attribute23
    ,p_pji_attribute24              =>     p_pji_attribute24
    ,p_pji_attribute25              =>     p_pji_attribute25
    ,p_pji_attribute26              =>     p_pji_attribute26
    ,p_pji_attribute27              =>     p_pji_attribute27
    ,p_pji_attribute28              =>     p_pji_attribute28
    ,p_pji_attribute29              =>     p_pji_attribute29
    ,p_pji_attribute30              =>     p_pji_attribute30
    ,p_pji_information_category     =>     p_pji_information_category
    ,p_pji_information1             =>     p_pji_information1
    ,p_pji_information2             =>     p_pji_information2
    ,p_pji_information3             =>     p_pji_information3
    ,p_pji_information4             =>     p_pji_information4
    ,p_pji_information5             =>     p_pji_information5
    ,p_pji_information6             =>     p_pji_information6
    ,p_pji_information7             =>     p_pji_information7
    ,p_pji_information8             =>     p_pji_information8
    ,p_pji_information9             =>     p_pji_information9
    ,p_pji_information10            =>     p_pji_information10
    ,p_pji_information11            =>     p_pji_information11
    ,p_pji_information12            =>     p_pji_information12
    ,p_pji_information13            =>     p_pji_information13
    ,p_pji_information14            =>     p_pji_information14
    ,p_pji_information15            =>     p_pji_information15
    ,p_pji_information16            =>     p_pji_information16
    ,p_pji_information17            =>     p_pji_information17
    ,p_pji_information18            =>     p_pji_information18
    ,p_pji_information19            =>     p_pji_information19
    ,p_pji_information20            =>     p_pji_information20
    ,p_pji_information21            =>     p_pji_information21
    ,p_pji_information22            =>     p_pji_information22
    ,p_pji_information23            =>     p_pji_information23
    ,p_pji_information24            =>     p_pji_information24
    ,p_pji_information25            =>     p_pji_information25
    ,p_pji_information26            =>     p_pji_information26
    ,p_pji_information27            =>     p_pji_information27
    ,p_pji_information28            =>     p_pji_information28
    ,p_pji_information29            =>     p_pji_information29
    ,p_pji_information30            =>     p_pji_information30
    );
  begin
         hr_previous_employment_bkb.update_prev_job_extra_info_a
         (p_previous_job_id                =>     p_previous_job_id
         ,p_information_type               =>     p_information_type
         ,p_pji_attribute_category         =>     p_pji_attribute_category
         ,p_pji_attribute1                 =>     p_pji_attribute1
         ,p_pji_attribute2                 =>     p_pji_attribute2
         ,p_pji_attribute3                 =>     p_pji_attribute3
         ,p_pji_attribute4                 =>     p_pji_attribute4
         ,p_pji_attribute5                 =>     p_pji_attribute5
         ,p_pji_attribute6                 =>     p_pji_attribute6
         ,p_pji_attribute7                 =>     p_pji_attribute7
         ,p_pji_attribute8                 =>     p_pji_attribute8
         ,p_pji_attribute9                 =>     p_pji_attribute9
         ,p_pji_attribute10                =>     p_pji_attribute10
         ,p_pji_attribute11                =>     p_pji_attribute11
         ,p_pji_attribute12                =>     p_pji_attribute12
         ,p_pji_attribute13                =>     p_pji_attribute13
         ,p_pji_attribute14                =>     p_pji_attribute14
         ,p_pji_attribute15                =>     p_pji_attribute15
         ,p_pji_attribute16                =>     p_pji_attribute16
         ,p_pji_attribute17                =>     p_pji_attribute17
         ,p_pji_attribute18                =>     p_pji_attribute18
         ,p_pji_attribute19                =>     p_pji_attribute19
         ,p_pji_attribute20                =>     p_pji_attribute20
         ,p_pji_attribute21                =>     p_pji_attribute21
         ,p_pji_attribute22                =>     p_pji_attribute22
         ,p_pji_attribute23                =>     p_pji_attribute23
         ,p_pji_attribute24                =>     p_pji_attribute24
         ,p_pji_attribute25                =>     p_pji_attribute25
         ,p_pji_attribute26                =>     p_pji_attribute26
         ,p_pji_attribute27                =>     p_pji_attribute27
         ,p_pji_attribute28                =>     p_pji_attribute28
         ,p_pji_attribute29                =>     p_pji_attribute29
         ,p_pji_attribute30                =>     p_pji_attribute30
         ,p_pji_information_category       =>     p_pji_information_category
         ,p_pji_information1               =>     p_pji_information1
         ,p_pji_information2               =>     p_pji_information2
         ,p_pji_information3               =>     p_pji_information3
         ,p_pji_information4               =>     p_pji_information4
         ,p_pji_information5               =>     p_pji_information5
         ,p_pji_information6               =>     p_pji_information6
         ,p_pji_information7               =>     p_pji_information7
         ,p_pji_information8               =>     p_pji_information8
         ,p_pji_information9               =>     p_pji_information9
         ,p_pji_information10              =>     p_pji_information10
         ,p_pji_information11              =>     p_pji_information11
         ,p_pji_information12              =>     p_pji_information12
         ,p_pji_information13              =>     p_pji_information13
         ,p_pji_information14              =>     p_pji_information14
         ,p_pji_information15              =>     p_pji_information15
         ,p_pji_information16              =>     p_pji_information16
         ,p_pji_information17              =>     p_pji_information17
         ,p_pji_information18              =>     p_pji_information18
         ,p_pji_information19              =>     p_pji_information19
         ,p_pji_information20              =>     p_pji_information20
         ,p_pji_information21              =>     p_pji_information21
         ,p_pji_information22              =>     p_pji_information22
         ,p_pji_information23              =>     p_pji_information23
         ,p_pji_information24              =>     p_pji_information24
         ,p_pji_information25              =>     p_pji_information25
         ,p_pji_information26              =>     p_pji_information26
         ,p_pji_information27              =>     p_pji_information27
         ,p_pji_information28              =>     p_pji_information28
         ,p_pji_information29              =>     p_pji_information29
         ,p_pji_information30              =>     p_pji_information30
         ,p_previous_job_extra_info_id     =>     p_previous_job_extra_info_id
         ,p_object_version_number          =>     l_object_version_number
         );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name
              => 'hr_previous_employment_bkb.update_prev_job_extra_info_a'
          ,p_hook_type
              => 'AP'
          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
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
    rollback to update_prev_job_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_prev_job_extra_info;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_prev_job_extra_info;
--
-- -----------------------------------------------------------------------
-- |----------------------< delete_prev_job_extra_info >-----------------|
-- -----------------------------------------------------------------------
--
procedure delete_prev_job_extra_info
  (p_validate                       in     boolean
  ,p_previous_job_extra_info_id     in      number
  ,p_object_version_number          in out nocopy number
  )
 is
 l_proc             varchar2(72)
                    := g_package||'delete_prev_job_extra_info';
 l_previous_job_extra_info_id
                    per_prev_job_extra_info.previous_job_extra_info_id%type;
 l_object_version_number
                    per_prev_job_extra_info.object_version_number%type
                    := p_object_version_number;
 l_ovn per_prev_job_extra_info.object_version_number%type  := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_prev_job_extra_info;
  --
  -- Call Before Process User Hook
  --
    begin
      hr_previous_employment_bkc.delete_prev_job_extra_info_b
      (p_previous_job_extra_info_id    => p_previous_job_extra_info_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
        when hr_api.cannot_find_prog_unit then
            hr_api.cannot_find_prog_unit_error
            (p_module_name => 'delete_prev_job_extra_info'
            ,p_hook_type   => 'BP'
            );
      end;
  --
  -- Process Logic
  --
  -- Call row handler procedure to delete previous job extra info
  --
    per_pji_del.del
    (p_previous_job_extra_info_id    => p_previous_job_extra_info_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    hr_previous_employment_bkc.delete_prev_job_extra_info_a
      (p_previous_job_extra_info_id    => p_previous_job_extra_info_id
      ,p_object_version_number         => l_object_version_number
       );
  exception
  when hr_api.cannot_find_prog_unit then
    hr_api.cannot_find_prog_unit_error
      (p_module_name => 'delete_prev_job_extra_info'
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
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_prev_job_extra_info;
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
    rollback to delete_prev_job_extra_info;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_prev_job_extra_info;
--
-- -----------------------------------------------------------------------
-- |-------------------------< create_previous_job_usage >---------------|
-- -----------------------------------------------------------------------
--
procedure create_previous_job_usage
    (p_validate                       in        boolean
    ,p_assignment_id                  in        number
    ,p_previous_employer_id           in        number
    ,p_previous_job_id                in        number
    ,p_start_date                     in        date     default null
    ,p_end_date                       in        date     default null
    ,p_period_years                   in        number   default null
    ,p_period_months                  in        number   default null
    ,p_period_days                    in        number   default null
    ,p_pju_attribute_category         in        varchar2 default null
    ,p_pju_attribute1                 in        varchar2 default null
    ,p_pju_attribute2                 in        varchar2 default null
    ,p_pju_attribute3                 in        varchar2 default null
    ,p_pju_attribute4                 in        varchar2 default null
    ,p_pju_attribute5                 in        varchar2 default null
    ,p_pju_attribute6                 in        varchar2 default null
    ,p_pju_attribute7                 in        varchar2 default null
    ,p_pju_attribute8                 in        varchar2 default null
    ,p_pju_attribute9                 in        varchar2 default null
    ,p_pju_attribute10                in        varchar2 default null
    ,p_pju_attribute11                in        varchar2 default null
    ,p_pju_attribute12                in        varchar2 default null
    ,p_pju_attribute13                in        varchar2 default null
    ,p_pju_attribute14                in        varchar2 default null
    ,p_pju_attribute15                in        varchar2 default null
    ,p_pju_attribute16                in        varchar2 default null
    ,p_pju_attribute17                in        varchar2 default null
    ,p_pju_attribute18                in        varchar2 default null
    ,p_pju_attribute19                in        varchar2 default null
    ,p_pju_attribute20                in        varchar2 default null
    ,p_pju_information_category       in        varchar2 default null
    ,p_pju_information1               in        varchar2 default null
    ,p_pju_information2               in        varchar2 default null
    ,p_pju_information3               in        varchar2 default null
    ,p_pju_information4               in        varchar2 default null
    ,p_pju_information5               in        varchar2 default null
    ,p_pju_information6               in        varchar2 default null
    ,p_pju_information7               in        varchar2 default null
    ,p_pju_information8               in        varchar2 default null
    ,p_pju_information9               in        varchar2 default null
    ,p_pju_information10              in        varchar2 default null
    ,p_pju_information11              in        varchar2 default null
    ,p_pju_information12              in        varchar2 default null
    ,p_pju_information13              in        varchar2 default null
    ,p_pju_information14              in        varchar2 default null
    ,p_pju_information15              in        varchar2 default null
    ,p_pju_information16              in        varchar2 default null
    ,p_pju_information17              in        varchar2 default null
    ,p_pju_information18              in        varchar2 default null
    ,p_pju_information19              in        varchar2 default null
    ,p_pju_information20              in        varchar2 default null
    ,p_previous_job_usage_id          out nocopy       number
    ,p_object_version_number          out nocopy       number
    ) is
  --
  -- Declare cursors and local variables
  --
  l_flag             varchar2(30);
  l_start_date      per_previous_job_usages.start_date%type;
  l_end_date        per_previous_job_usages.end_date%type;
  l_period_years    per_previous_job_usages.period_years%type;
  l_period_months   per_previous_job_usages.period_months%type;
  l_period_days     per_previous_job_usages.period_days%type;
  l_previous_job_usage_id
                    per_previous_job_usages.previous_job_usage_id%type;
  l_object_version_number
                    per_previous_job_usages.object_version_number%type;
  l_proc            varchar2(72) := g_package||'create_prev_job_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_previous_job_usage;
  --
  -- Get the default values from previous jobs
  --
  per_pju_bus.get_previous_job_dates
             (p_previous_employer_id  =>  p_previous_employer_id
             ,p_previous_job_id       =>  p_previous_job_id
             ,p_start_date            =>  l_start_date
             ,p_end_date              =>  l_end_date
             ,p_period_years          =>  l_period_years
             ,p_period_months         =>  l_period_months
             ,p_period_days           =>  l_period_days
             );
  --
  -- Truncate the time portion from all IN date parameters
  if  p_start_date is not null and p_end_date is not null then
    l_start_date    :=trunc(p_start_date);
    l_end_date      :=trunc(p_end_date);
  end if;
  --
  l_period_years  :=p_period_years;
  l_period_months :=p_period_months;
  l_period_days   :=p_period_days;
  --
    if p_period_years is null
       and p_period_months is null
       and p_period_days is null then
         per_pem_bus.get_period_values(l_start_date
                                      ,l_end_date
                                      ,l_period_years
                                      ,l_period_months
                                      ,l_period_days);
    end if;
  --
  --
  -- Call Before Process User Hook
  --
  begin
      hr_previous_employment_bk7.create_previous_job_usage_b
      ( p_assignment_id                  =>     p_assignment_id
       ,p_previous_employer_id           =>     p_previous_employer_id
       ,p_previous_job_id                =>     p_previous_job_id
       ,p_start_date                     =>     l_start_date
       ,p_end_date                       =>     l_end_date
       ,p_period_years                   =>     l_period_years
       ,p_period_months                  =>     l_period_months
       ,p_period_days                    =>     l_period_days
       ,p_pju_attribute_category         =>     p_pju_attribute_category
       ,p_pju_attribute1                 =>     p_pju_attribute1
       ,p_pju_attribute2                 =>     p_pju_attribute2
       ,p_pju_attribute3                 =>     p_pju_attribute3
       ,p_pju_attribute4                 =>     p_pju_attribute4
       ,p_pju_attribute5                 =>     p_pju_attribute5
       ,p_pju_attribute6                 =>     p_pju_attribute6
       ,p_pju_attribute7                 =>     p_pju_attribute7
       ,p_pju_attribute8                 =>     p_pju_attribute8
       ,p_pju_attribute9                 =>     p_pju_attribute9
       ,p_pju_attribute10                =>     p_pju_attribute10
       ,p_pju_attribute11                =>     p_pju_attribute11
       ,p_pju_attribute12                =>     p_pju_attribute12
       ,p_pju_attribute13                =>     p_pju_attribute13
       ,p_pju_attribute14                =>     p_pju_attribute14
       ,p_pju_attribute15                =>     p_pju_attribute15
       ,p_pju_attribute16                =>     p_pju_attribute16
       ,p_pju_attribute17                =>     p_pju_attribute17
       ,p_pju_attribute18                =>     p_pju_attribute18
       ,p_pju_attribute19                =>     p_pju_attribute19
       ,p_pju_attribute20                =>     p_pju_attribute20
       ,p_pju_information_category       =>     p_pju_information_category
       ,p_pju_information1               =>     p_pju_information1
       ,p_pju_information2               =>     p_pju_information2
       ,p_pju_information3               =>     p_pju_information3
       ,p_pju_information4               =>     p_pju_information4
       ,p_pju_information5               =>     p_pju_information5
       ,p_pju_information6               =>     p_pju_information6
       ,p_pju_information7               =>     p_pju_information7
       ,p_pju_information8               =>     p_pju_information8
       ,p_pju_information9               =>     p_pju_information9
       ,p_pju_information10              =>     p_pju_information10
       ,p_pju_information11              =>     p_pju_information11
       ,p_pju_information12              =>     p_pju_information12
       ,p_pju_information13              =>     p_pju_information13
       ,p_pju_information14              =>     p_pju_information14
       ,p_pju_information15              =>     p_pju_information15
       ,p_pju_information16              =>     p_pju_information16
       ,p_pju_information17              =>     p_pju_information17
       ,p_pju_information18              =>     p_pju_information18
       ,p_pju_information19              =>     p_pju_information19
       ,p_pju_information20              =>     p_pju_information20
       ,p_object_version_number          =>     l_object_version_number
       );
  exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_prev_job_extra_info'
          ,p_hook_type   => 'BP'
          );
  end;
  --
  -- Validation in addition to Row Handlers
  -- Process Logic
  per_pju_ins.ins
  (p_assignment_id                  =>     p_assignment_id
  ,p_previous_employer_id           =>     p_previous_employer_id
  ,p_previous_job_id                =>     p_previous_job_id
  ,p_start_date                     =>     l_start_date
  ,p_end_date                       =>     l_end_date
  ,p_period_years                   =>     l_period_years
  ,p_period_months                  =>     l_period_months
  ,p_period_days                    =>     l_period_days
  ,p_pju_attribute_category         =>     p_pju_attribute_category
  ,p_pju_attribute1                 =>     p_pju_attribute1
  ,p_pju_attribute2                 =>     p_pju_attribute2
  ,p_pju_attribute3                 =>     p_pju_attribute3
  ,p_pju_attribute4                 =>     p_pju_attribute4
  ,p_pju_attribute5                 =>     p_pju_attribute5
  ,p_pju_attribute6                 =>     p_pju_attribute6
  ,p_pju_attribute7                 =>     p_pju_attribute7
  ,p_pju_attribute8                 =>     p_pju_attribute8
  ,p_pju_attribute9                 =>     p_pju_attribute9
  ,p_pju_attribute10                =>     p_pju_attribute10
  ,p_pju_attribute11                =>     p_pju_attribute11
  ,p_pju_attribute12                =>     p_pju_attribute12
  ,p_pju_attribute13                =>     p_pju_attribute13
  ,p_pju_attribute14                =>     p_pju_attribute14
  ,p_pju_attribute15                =>     p_pju_attribute15
  ,p_pju_attribute16                =>     p_pju_attribute16
  ,p_pju_attribute17                =>     p_pju_attribute17
  ,p_pju_attribute18                =>     p_pju_attribute18
  ,p_pju_attribute19                =>     p_pju_attribute19
  ,p_pju_attribute20                =>     p_pju_attribute20
  ,p_pju_information_category       =>     p_pju_information_category
  ,p_pju_information1               =>     p_pju_information1
  ,p_pju_information2               =>     p_pju_information2
  ,p_pju_information3               =>     p_pju_information3
  ,p_pju_information4               =>     p_pju_information4
  ,p_pju_information5               =>     p_pju_information5
  ,p_pju_information6               =>     p_pju_information6
  ,p_pju_information7               =>     p_pju_information7
  ,p_pju_information8               =>     p_pju_information8
  ,p_pju_information9               =>     p_pju_information9
  ,p_pju_information10              =>     p_pju_information10
  ,p_pju_information11              =>     p_pju_information11
  ,p_pju_information12              =>     p_pju_information12
  ,p_pju_information13              =>     p_pju_information13
  ,p_pju_information14              =>     p_pju_information14
  ,p_pju_information15              =>     p_pju_information15
  ,p_pju_information16              =>     p_pju_information16
  ,p_pju_information17              =>     p_pju_information17
  ,p_pju_information18              =>     p_pju_information18
  ,p_pju_information19              =>     p_pju_information19
  ,p_pju_information20              =>     p_pju_information20
  ,p_previous_job_usage_id          =>     l_previous_job_usage_id
  ,p_object_version_number          =>     l_object_version_number
  );
  -- Call After Process User Hook
  --
  begin
      hr_previous_employment_bk7.create_previous_job_usage_a
       ( p_assignment_id                 =>     p_assignment_id
       ,p_previous_employer_id           =>     p_previous_employer_id
       ,p_previous_job_id                =>     p_previous_job_id
       ,p_start_date                     =>     l_start_date
       ,p_end_date                       =>     l_end_date
       ,p_period_years                   =>     l_period_years
       ,p_period_months                  =>     l_period_months
       ,p_period_days                    =>     l_period_days
       ,p_pju_attribute_category         =>     p_pju_attribute_category
       ,p_pju_attribute1                 =>     p_pju_attribute1
       ,p_pju_attribute2                 =>     p_pju_attribute2
       ,p_pju_attribute3                 =>     p_pju_attribute3
       ,p_pju_attribute4                 =>     p_pju_attribute4
       ,p_pju_attribute5                 =>     p_pju_attribute5
       ,p_pju_attribute6                 =>     p_pju_attribute6
       ,p_pju_attribute7                 =>     p_pju_attribute7
       ,p_pju_attribute8                 =>     p_pju_attribute8
       ,p_pju_attribute9                 =>     p_pju_attribute9
       ,p_pju_attribute10                =>     p_pju_attribute10
       ,p_pju_attribute11                =>     p_pju_attribute11
       ,p_pju_attribute12                =>     p_pju_attribute12
       ,p_pju_attribute13                =>     p_pju_attribute13
       ,p_pju_attribute14                =>     p_pju_attribute14
       ,p_pju_attribute15                =>     p_pju_attribute15
       ,p_pju_attribute16                =>     p_pju_attribute16
       ,p_pju_attribute17                =>     p_pju_attribute17
       ,p_pju_attribute18                =>     p_pju_attribute18
       ,p_pju_attribute19                =>     p_pju_attribute19
       ,p_pju_attribute20                =>     p_pju_attribute20
       ,p_pju_information_category       =>     p_pju_information_category
       ,p_pju_information1               =>     p_pju_information1
       ,p_pju_information2               =>     p_pju_information2
       ,p_pju_information3               =>     p_pju_information3
       ,p_pju_information4               =>     p_pju_information4
       ,p_pju_information5               =>     p_pju_information5
       ,p_pju_information6               =>     p_pju_information6
       ,p_pju_information7               =>     p_pju_information7
       ,p_pju_information8               =>     p_pju_information8
       ,p_pju_information9               =>     p_pju_information9
       ,p_pju_information10              =>     p_pju_information10
       ,p_pju_information11              =>     p_pju_information11
       ,p_pju_information12              =>     p_pju_information12
       ,p_pju_information13              =>     p_pju_information13
       ,p_pju_information14              =>     p_pju_information14
       ,p_pju_information15              =>     p_pju_information15
       ,p_pju_information16              =>     p_pju_information16
       ,p_pju_information17              =>     p_pju_information17
       ,p_pju_information18              =>     p_pju_information18
       ,p_pju_information19              =>     p_pju_information19
       ,p_pju_information20              =>     p_pju_information20
       ,p_previous_job_usage_id          =>     l_previous_job_usage_id
       ,p_object_version_number          =>     l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_previous_job_usage'
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
  p_previous_job_usage_id  := l_previous_job_usage_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_previous_job_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_previous_job_usage_id    := null;
    p_object_version_number    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_previous_job_usage;
    --
    -- set in out parameters and set out parameters
    --
    p_previous_job_usage_id    := null;
    p_object_version_number    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_previous_job_usage;
--
-- -----------------------------------------------------------------------
-- |------------------------< update_previous_job_usage >----------------|
-- -----------------------------------------------------------------------
--
procedure update_previous_job_usage
  (p_validate                       in boolean
  ,p_previous_job_usage_id          in number
  ,p_assignment_id                  in number
  ,p_previous_employer_id           in number
  ,p_previous_job_id                in number
  ,p_start_date                     in date     default hr_api.g_date
  ,p_end_date                       in date     default hr_api.g_date
  ,p_period_years                   in number   default hr_api.g_number
  ,p_period_months                  in number   default hr_api.g_number
  ,p_period_days                    in number   default hr_api.g_number
  ,p_pju_attribute_category         in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute1                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute2                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute3                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute4                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute5                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute6                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute7                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute8                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute9                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute10                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute11                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute12                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute13                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute14                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute15                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute16                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute17                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute18                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute19                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute20                in varchar2 default hr_api.g_varchar2
  ,p_pju_information_category       in varchar2 default hr_api.g_varchar2
  ,p_pju_information1               in varchar2 default hr_api.g_varchar2
  ,p_pju_information2               in varchar2 default hr_api.g_varchar2
  ,p_pju_information3               in varchar2 default hr_api.g_varchar2
  ,p_pju_information4               in varchar2 default hr_api.g_varchar2
  ,p_pju_information5               in varchar2 default hr_api.g_varchar2
  ,p_pju_information6               in varchar2 default hr_api.g_varchar2
  ,p_pju_information7               in varchar2 default hr_api.g_varchar2
  ,p_pju_information8               in varchar2 default hr_api.g_varchar2
  ,p_pju_information9               in varchar2 default hr_api.g_varchar2
  ,p_pju_information10              in varchar2 default hr_api.g_varchar2
  ,p_pju_information11              in varchar2 default hr_api.g_varchar2
  ,p_pju_information12              in varchar2 default hr_api.g_varchar2
  ,p_pju_information13              in varchar2 default hr_api.g_varchar2
  ,p_pju_information14              in varchar2 default hr_api.g_varchar2
  ,p_pju_information15              in varchar2 default hr_api.g_varchar2
  ,p_pju_information16              in varchar2 default hr_api.g_varchar2
  ,p_pju_information17              in varchar2 default hr_api.g_varchar2
  ,p_pju_information18              in varchar2 default hr_api.g_varchar2
  ,p_pju_information19              in varchar2 default hr_api.g_varchar2
  ,p_pju_information20              in varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
          --
        l_start_date      per_previous_job_usages.start_date%type;
        l_end_date        per_previous_job_usages.end_date%type;
        --
        l_period_years        number;
        l_period_months       number;
        l_period_days         number;
        --
        l_proc              varchar2(72)
                            := g_package||'update_previous_job_usage';
        l_object_version_number
                            per_previous_job_usages.object_version_number%type
                            := p_object_version_number;
   l_ovn per_previous_job_usages.object_version_number%type := p_object_version_number;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_previous_job_usage;
    --
    -- Get the default values from previous jobs
    --
    per_pju_bus.get_previous_job_dates
               (p_previous_employer_id  =>  p_previous_employer_id
               ,p_previous_job_id       =>  p_previous_job_id
               ,p_start_date            =>  l_start_date
               ,p_end_date              =>  l_end_date
               ,p_period_years          =>  l_period_years
               ,p_period_months         =>  l_period_months
               ,p_period_days           =>  l_period_days
               );
    --
    -- Truncate the time portion from all IN date parameters
    if p_start_date is not null and p_end_date is not null then
      l_start_date  :=  trunc(p_start_date);
      l_end_date    :=  trunc(p_end_date);
    end if;
    --
    l_period_years  :=  p_period_years;
    l_period_months :=  p_period_months;
    l_period_days   :=  p_period_days;
    --
    if p_period_years is null
       and p_period_months is null
       and p_period_days is null then
         per_pem_bus.get_period_values(l_start_date
                                      ,l_end_date
                                      ,l_period_years
                                      ,l_period_months
                                      ,l_period_days);
    end if;
    --
    -- Call Before Process User Hook
    --
  begin
        hr_previous_employment_bk8.update_previous_job_usage_b
       (p_assignment_id                  =>     p_assignment_id
       ,p_previous_employer_id           =>     p_previous_employer_id
       ,p_previous_job_id                =>     p_previous_job_id
       ,p_start_date                     =>     l_start_date
       ,p_end_date                       =>     l_end_date
       ,p_period_years                   =>     l_period_years
       ,p_period_months                  =>     l_period_months
       ,p_period_days                    =>     l_period_days
       ,p_pju_attribute_category         =>     p_pju_attribute_category
       ,p_pju_attribute1                 =>     p_pju_attribute1
       ,p_pju_attribute2                 =>     p_pju_attribute2
       ,p_pju_attribute3                 =>     p_pju_attribute3
       ,p_pju_attribute4                 =>     p_pju_attribute4
       ,p_pju_attribute5                 =>     p_pju_attribute5
       ,p_pju_attribute6                 =>     p_pju_attribute6
       ,p_pju_attribute7                 =>     p_pju_attribute7
       ,p_pju_attribute8                 =>     p_pju_attribute8
       ,p_pju_attribute9                 =>     p_pju_attribute9
       ,p_pju_attribute10                =>     p_pju_attribute10
       ,p_pju_attribute11                =>     p_pju_attribute11
       ,p_pju_attribute12                =>     p_pju_attribute12
       ,p_pju_attribute13                =>     p_pju_attribute13
       ,p_pju_attribute14                =>     p_pju_attribute14
       ,p_pju_attribute15                =>     p_pju_attribute15
       ,p_pju_attribute16                =>     p_pju_attribute16
       ,p_pju_attribute17                =>     p_pju_attribute17
       ,p_pju_attribute18                =>     p_pju_attribute18
       ,p_pju_attribute19                =>     p_pju_attribute19
       ,p_pju_attribute20                =>     p_pju_attribute20
       ,p_pju_information_category       =>     p_pju_information_category
       ,p_pju_information1               =>     p_pju_information1
       ,p_pju_information2               =>     p_pju_information2
       ,p_pju_information3               =>     p_pju_information3
       ,p_pju_information4               =>     p_pju_information4
       ,p_pju_information5               =>     p_pju_information5
       ,p_pju_information6               =>     p_pju_information6
       ,p_pju_information7               =>     p_pju_information7
       ,p_pju_information8               =>     p_pju_information8
       ,p_pju_information9               =>     p_pju_information9
       ,p_pju_information10              =>     p_pju_information10
       ,p_pju_information11              =>     p_pju_information11
       ,p_pju_information12              =>     p_pju_information12
       ,p_pju_information13              =>     p_pju_information13
       ,p_pju_information14              =>     p_pju_information14
       ,p_pju_information15              =>     p_pju_information15
       ,p_pju_information16              =>     p_pju_information16
       ,p_pju_information17              =>     p_pju_information17
       ,p_pju_information18              =>     p_pju_information18
       ,p_pju_information19              =>     p_pju_information19
       ,p_pju_information20              =>     p_pju_information20
       ,p_previous_job_usage_id          =>     p_previous_job_usage_id
       ,p_object_version_number          =>     l_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'update_previous_job_usage'
          ,p_hook_type   => 'BP'
          );
    end;
  --
  -- Call row handler procedure to update previous job usages
  --
  per_pju_upd.upd
  (p_previous_job_usage_id          =>     p_previous_job_usage_id
  ,p_object_version_number          =>     l_object_version_number
  ,p_assignment_id                  =>     p_assignment_id
  ,p_previous_employer_id           =>     p_previous_employer_id
  ,p_previous_job_id                =>     p_previous_job_id
  ,p_start_date                     =>     l_start_date
  ,p_end_date                       =>     l_end_date
  ,p_period_years                   =>     l_period_years
  ,p_period_months                  =>     l_period_months
  ,p_period_days                    =>     l_period_days
  ,p_pju_attribute_category         =>     p_pju_attribute_category
  ,p_pju_attribute1                 =>     p_pju_attribute1
  ,p_pju_attribute2                 =>     p_pju_attribute2
  ,p_pju_attribute3                 =>     p_pju_attribute3
  ,p_pju_attribute4                 =>     p_pju_attribute4
  ,p_pju_attribute5                 =>     p_pju_attribute5
  ,p_pju_attribute6                 =>     p_pju_attribute6
  ,p_pju_attribute7                 =>     p_pju_attribute7
  ,p_pju_attribute8                 =>     p_pju_attribute8
  ,p_pju_attribute9                 =>     p_pju_attribute9
  ,p_pju_attribute10                =>     p_pju_attribute10
  ,p_pju_attribute11                =>     p_pju_attribute11
  ,p_pju_attribute12                =>     p_pju_attribute12
  ,p_pju_attribute13                =>     p_pju_attribute13
  ,p_pju_attribute14                =>     p_pju_attribute14
  ,p_pju_attribute15                =>     p_pju_attribute15
  ,p_pju_attribute16                =>     p_pju_attribute16
  ,p_pju_attribute17                =>     p_pju_attribute17
  ,p_pju_attribute18                =>     p_pju_attribute18
  ,p_pju_attribute19                =>     p_pju_attribute19
  ,p_pju_attribute20                =>     p_pju_attribute20
  ,p_pju_information_category       =>     p_pju_information_category
  ,p_pju_information1               =>     p_pju_information1
  ,p_pju_information2               =>     p_pju_information2
  ,p_pju_information3               =>     p_pju_information3
  ,p_pju_information4               =>     p_pju_information4
  ,p_pju_information5               =>     p_pju_information5
  ,p_pju_information6               =>     p_pju_information6
  ,p_pju_information7               =>     p_pju_information7
  ,p_pju_information8               =>     p_pju_information8
  ,p_pju_information9               =>     p_pju_information9
  ,p_pju_information10              =>     p_pju_information10
  ,p_pju_information11              =>     p_pju_information11
  ,p_pju_information12              =>     p_pju_information12
  ,p_pju_information13              =>     p_pju_information13
  ,p_pju_information14              =>     p_pju_information14
  ,p_pju_information15              =>     p_pju_information15
  ,p_pju_information16              =>     p_pju_information16
  ,p_pju_information17              =>     p_pju_information17
  ,p_pju_information18              =>     p_pju_information18
  ,p_pju_information19              =>     p_pju_information19
  ,p_pju_information20              =>     p_pju_information20
  );
  begin
       hr_previous_employment_bk8.update_previous_job_usage_a
       (p_assignment_id                  =>     p_assignment_id
       ,p_previous_employer_id           =>     p_previous_employer_id
       ,p_previous_job_id                =>     p_previous_job_id
       ,p_start_date                     =>     l_start_date
       ,p_end_date                       =>     l_end_date
       ,p_period_years                   =>     l_period_years
       ,p_period_months                  =>     l_period_months
       ,p_period_days                    =>     l_period_days
       ,p_pju_attribute_category         =>     p_pju_attribute_category
       ,p_pju_attribute1                 =>     p_pju_attribute1
       ,p_pju_attribute2                 =>     p_pju_attribute2
       ,p_pju_attribute3                 =>     p_pju_attribute3
       ,p_pju_attribute4                 =>     p_pju_attribute4
       ,p_pju_attribute5                 =>     p_pju_attribute5
       ,p_pju_attribute6                 =>     p_pju_attribute6
       ,p_pju_attribute7                 =>     p_pju_attribute7
       ,p_pju_attribute8                 =>     p_pju_attribute8
       ,p_pju_attribute9                 =>     p_pju_attribute9
       ,p_pju_attribute10                =>     p_pju_attribute10
       ,p_pju_attribute11                =>     p_pju_attribute11
       ,p_pju_attribute12                =>     p_pju_attribute12
       ,p_pju_attribute13                =>     p_pju_attribute13
       ,p_pju_attribute14                =>     p_pju_attribute14
       ,p_pju_attribute15                =>     p_pju_attribute15
       ,p_pju_attribute16                =>     p_pju_attribute16
       ,p_pju_attribute17                =>     p_pju_attribute17
       ,p_pju_attribute18                =>     p_pju_attribute18
       ,p_pju_attribute19                =>     p_pju_attribute19
       ,p_pju_attribute20                =>     p_pju_attribute20
       ,p_pju_information_category       =>     p_pju_information_category
       ,p_pju_information1               =>     p_pju_information1
       ,p_pju_information2               =>     p_pju_information2
       ,p_pju_information3               =>     p_pju_information3
       ,p_pju_information4               =>     p_pju_information4
       ,p_pju_information5               =>     p_pju_information5
       ,p_pju_information6               =>     p_pju_information6
       ,p_pju_information7               =>     p_pju_information7
       ,p_pju_information8               =>     p_pju_information8
       ,p_pju_information9               =>     p_pju_information9
       ,p_pju_information10              =>     p_pju_information10
       ,p_pju_information11              =>     p_pju_information11
       ,p_pju_information12              =>     p_pju_information12
       ,p_pju_information13              =>     p_pju_information13
       ,p_pju_information14              =>     p_pju_information14
       ,p_pju_information15              =>     p_pju_information15
       ,p_pju_information16              =>     p_pju_information16
       ,p_pju_information17              =>     p_pju_information17
       ,p_pju_information18              =>     p_pju_information18
       ,p_pju_information19              =>     p_pju_information19
       ,p_pju_information20              =>     p_pju_information20
       ,p_previous_job_usage_id          =>     p_previous_job_usage_id
       ,p_object_version_number          =>     l_object_version_number
       );
    exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name
            => 'hr_previous_employment_bk8.update_previous_job_usage_a'
        ,p_hook_type
            => 'AP'
        );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
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
    rollback to update_previous_job_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_previous_job_usage;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_previous_job_usage;
--
-- -----------------------------------------------------------------------
-- |----------------------< delete_previous_job_usage >------------------|
-- -----------------------------------------------------------------------
--
procedure delete_previous_job_usage
  (p_validate                       in     boolean
  ,p_previous_job_usage_id          in      number
  ,p_object_version_number          in out nocopy number
  )
 is
 l_proc            varchar2(72)
                   := g_package||'delete_previous_job_usage';
 l_previous_job_usage_id
                   per_previous_job_usages.previous_job_usage_id%type;
 l_object_version_number
                   per_previous_job_usages.object_version_number%type
                   := p_object_version_number;
 l_ovn per_previous_job_usages.object_version_number%type  := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_previous_job_usage;
  --
  -- Call Before Process User Hook
  --
    begin
      hr_previous_employment_bk9.delete_previous_job_usage_b
      (p_previous_job_usage_id    =>  p_previous_job_usage_id
      ,p_object_version_number    =>  l_object_version_number
      );
  exception
        when hr_api.cannot_find_prog_unit then
            hr_api.cannot_find_prog_unit_error
            (p_module_name => 'delete_previous_job_usage'
            ,p_hook_type   => 'BP'
            );
      end;
  --
  -- Process Logic
  --
  -- Call row handler procedure to delete previous job usages
  --
    per_pju_del.del
    (p_previous_job_usage_id    =>  p_previous_job_usage_id
    ,p_object_version_number    =>  l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
      begin
         hr_previous_employment_bk9.delete_previous_job_usage_a
         (p_previous_job_usage_id    => p_previous_job_usage_id
       ,p_object_version_number    => l_object_version_number
       );
    exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'delete_previous_job_usage'
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
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_previous_job_usage;
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
    rollback to delete_previous_job_usage;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_previous_job_usage;
--
end hr_previous_employment_api;

/
