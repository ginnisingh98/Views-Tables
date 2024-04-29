--------------------------------------------------------
--  DDL for Package Body PQH_ACCOMMODATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ACCOMMODATIONS_API" as
/* $Header: pqaccapi.pkb 115.1 2002/11/26 22:33:05 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_ACCOMMODATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_accommodation>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_accommodation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_accommodation_name             in     varchar2
  ,p_business_group_id              in     number
  ,p_location_id                    in     number
  ,p_accommodation_desc             in     varchar2 default null
  ,p_accommodation_type             in     varchar2 default null
  ,p_style                          in     varchar2 default null
  ,p_address_line_1                 in     varchar2 default null
  ,p_address_line_2                 in     varchar2 default null
  ,p_address_line_3                 in     varchar2 default null
  ,p_town_or_city                   in     varchar2 default null
  ,p_country                        in     varchar2 default null
  ,p_postal_code                    in     varchar2 default null
  ,p_region_1                       in     varchar2 default null
  ,p_region_2                       in     varchar2 default null
  ,p_region_3                       in     varchar2 default null
  ,p_telephone_number_1             in     varchar2 default null
  ,p_telephone_number_2             in     varchar2 default null
  ,p_telephone_number_3             in     varchar2 default null
  ,p_floor_number                   in     varchar2 default null
  ,p_floor_area                     in     number   default null
  ,p_floor_area_measure_unit        in     varchar2 default null
  ,p_main_rooms                     in     number   default null
  ,p_family_size                    in     number   default null
  ,p_suitability_disabled           in     varchar2 default null
  ,p_rental_value                   in     number   default null
  ,p_rental_value_currency          in     varchar2 default null
  ,p_owner                          in     varchar2 default null
  ,p_comments                       in     varchar2 default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_accommodation_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'CREATE_ACCOMMODATION';

  l_accommodation_id       pqh_accommodations_f.accommodation_id%TYPE;
  l_object_version_number  pqh_accommodations_f.object_version_number%TYPE;
  l_effective_start_date   pqh_accommodations_f.effective_start_date%TYPE;
  l_effective_end_date     pqh_accommodations_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_ACCOMMODATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_ACCOMMODATIONS_BK1.create_accommodation_b
      (p_effective_date                => p_effective_date
      ,p_accommodation_name            => p_accommodation_name
      ,p_business_group_id             => p_business_group_id
      ,p_location_id                   => p_location_id
      ,p_accommodation_desc            => p_accommodation_desc
      ,p_accommodation_type            => p_accommodation_type
      ,p_style                         => p_style
      ,p_address_line_1                => p_address_line_1
      ,p_address_line_2                => p_address_line_3
      ,p_address_line_3                => p_address_line_3
      ,p_town_or_city                  => p_town_or_city
      ,p_country                       => p_country
      ,p_postal_code                   => p_postal_code
      ,p_region_1                      => p_region_1
      ,p_region_2                      => p_region_2
      ,p_region_3                      => p_region_3
      ,p_telephone_number_1            => p_telephone_number_1
      ,p_telephone_number_2            => p_telephone_number_2
      ,p_telephone_number_3            => p_telephone_number_3
      ,p_floor_number                  => p_floor_number
      ,p_floor_area                    => p_floor_area
      ,p_floor_area_measure_unit       => p_floor_area_measure_unit
      ,p_main_rooms                    => p_main_rooms
      ,p_family_size                   => p_family_size
      ,p_suitability_disabled          => p_suitability_disabled
      ,p_rental_value                  => p_rental_value
      ,p_rental_value_currency         => p_rental_value_currency
      ,p_owner                         => p_owner
      ,p_comments                      => p_comments
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ACCOMMODATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_acc_ins.ins
      (p_effective_date                => p_effective_date
      ,p_accommodation_name            => p_accommodation_name
      ,p_business_group_id             => p_business_group_id
      ,p_location_id                   => p_location_id
      ,p_accommodation_desc            => p_accommodation_desc
      ,p_accommodation_type            => p_accommodation_type
      ,p_style                         => p_style
      ,p_address_line_1                => p_address_line_1
      ,p_address_line_2                => p_address_line_3
      ,p_address_line_3                => p_address_line_3
      ,p_town_or_city                  => p_town_or_city
      ,p_country                       => p_country
      ,p_postal_code                   => p_postal_code
      ,p_region_1                      => p_region_1
      ,p_region_2                      => p_region_2
      ,p_region_3                      => p_region_3
      ,p_telephone_number_1            => p_telephone_number_1
      ,p_telephone_number_2            => p_telephone_number_2
      ,p_telephone_number_3            => p_telephone_number_3
      ,p_floor_number                  => p_floor_number
      ,p_floor_area                    => p_floor_area
      ,p_floor_area_measure_unit       => p_floor_area_measure_unit
      ,p_main_rooms                    => p_main_rooms
      ,p_family_size                   => p_family_size
      ,p_suitability_disabled          => p_suitability_disabled
      ,p_rental_value                  => p_rental_value
      ,p_rental_value_currency         => p_rental_value_currency
      ,p_owner                         => p_owner
      ,p_comments                      => p_comments
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_accommodation_id              => l_accommodation_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_ACCOMMODATIONS_BK1.create_accommodation_a
      (p_effective_date                => p_effective_date
      ,p_accommodation_name            => p_accommodation_name
      ,p_business_group_id             => p_business_group_id
      ,p_location_id                   => p_location_id
      ,p_accommodation_desc            => p_accommodation_desc
      ,p_accommodation_type            => p_accommodation_type
      ,p_style                         => p_style
      ,p_address_line_1                => p_address_line_1
      ,p_address_line_2                => p_address_line_3
      ,p_address_line_3                => p_address_line_3
      ,p_town_or_city                  => p_town_or_city
      ,p_country                       => p_country
      ,p_postal_code                   => p_postal_code
      ,p_region_1                      => p_region_1
      ,p_region_2                      => p_region_2
      ,p_region_3                      => p_region_3
      ,p_telephone_number_1            => p_telephone_number_1
      ,p_telephone_number_2            => p_telephone_number_2
      ,p_telephone_number_3            => p_telephone_number_3
      ,p_floor_number                  => p_floor_number
      ,p_floor_area                    => p_floor_area
      ,p_floor_area_measure_unit       => p_floor_area_measure_unit
      ,p_main_rooms                    => p_main_rooms
      ,p_family_size                   => p_family_size
      ,p_suitability_disabled          => p_suitability_disabled
      ,p_rental_value                  => p_rental_value
      ,p_rental_value_currency         => p_rental_value_currency
      ,p_owner                         => p_owner
      ,p_comments                      => p_comments
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_accommodation_id              => l_accommodation_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ACCOMMODATION'
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
  p_accommodation_id       := l_accommodation_id;
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
    rollback to CREATE_ACCOMMODATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_accommodation_id       := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_accommodation_id       := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    rollback to CREATE_ACCOMMODATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_accommodation;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------<update_accommodation>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_accommodation
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_accommodation_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_accommodation_name           in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_accommodation_desc           in     varchar2  default hr_api.g_varchar2
  ,p_accommodation_type           in     varchar2  default hr_api.g_varchar2
  ,p_style                        in     varchar2  default hr_api.g_varchar2
  ,p_address_line_1               in     varchar2  default hr_api.g_varchar2
  ,p_address_line_2               in     varchar2  default hr_api.g_varchar2
  ,p_address_line_3               in     varchar2  default hr_api.g_varchar2
  ,p_town_or_city                 in     varchar2  default hr_api.g_varchar2
  ,p_country                      in     varchar2  default hr_api.g_varchar2
  ,p_postal_code                  in     varchar2  default hr_api.g_varchar2
  ,p_region_1                     in     varchar2  default hr_api.g_varchar2
  ,p_region_2                     in     varchar2  default hr_api.g_varchar2
  ,p_region_3                     in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_1           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_2           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_3           in     varchar2  default hr_api.g_varchar2
  ,p_floor_number                 in     varchar2  default hr_api.g_varchar2
  ,p_floor_area                   in     number    default hr_api.g_number
  ,p_floor_area_measure_unit      in     varchar2  default hr_api.g_varchar2
  ,p_main_rooms                   in     number    default hr_api.g_number
  ,p_family_size                  in     number    default hr_api.g_number
  ,p_suitability_disabled         in     varchar2  default hr_api.g_varchar2
  ,p_rental_value                 in     number    default hr_api.g_number
  ,p_rental_value_currency        in     varchar2  default hr_api.g_varchar2
  ,p_owner                        in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
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
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'UPDATE_ACCOMMODATION';

  l_effective_start_date   pqh_accommodations_f.effective_start_date%TYPE;
  l_effective_end_date     pqh_accommodations_f.effective_end_date%TYPE;
  l_object_version_number number := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_ACCOMMODATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_ACCOMMODATIONS_BK2.update_accommodation_b
      (p_effective_date                => p_effective_date
      ,p_datetrack_mode                => p_datetrack_mode
      ,p_accommodation_id              => p_accommodation_id
      ,p_object_version_number         => p_object_version_number
      ,p_accommodation_name            => p_accommodation_name
      ,p_business_group_id             => p_business_group_id
      ,p_location_id                   => p_location_id
      ,p_accommodation_desc            => p_accommodation_desc
      ,p_accommodation_type            => p_accommodation_type
      ,p_style                         => p_style
      ,p_address_line_1                => p_address_line_1
      ,p_address_line_2                => p_address_line_3
      ,p_address_line_3                => p_address_line_3
      ,p_town_or_city                  => p_town_or_city
      ,p_country                       => p_country
      ,p_postal_code                   => p_postal_code
      ,p_region_1                      => p_region_1
      ,p_region_2                      => p_region_2
      ,p_region_3                      => p_region_3
      ,p_telephone_number_1            => p_telephone_number_1
      ,p_telephone_number_2            => p_telephone_number_2
      ,p_telephone_number_3            => p_telephone_number_3
      ,p_floor_number                  => p_floor_number
      ,p_floor_area                    => p_floor_area
      ,p_floor_area_measure_unit       => p_floor_area_measure_unit
      ,p_main_rooms                    => p_main_rooms
      ,p_family_size                   => p_family_size
      ,p_suitability_disabled          => p_suitability_disabled
      ,p_rental_value                  => p_rental_value
      ,p_rental_value_currency         => p_rental_value_currency
      ,p_owner                         => p_owner
      ,p_comments                      => p_comments
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ACCOMMODATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_acc_upd.upd
      (p_effective_date                => p_effective_date
      ,p_datetrack_mode                => p_datetrack_mode
      ,p_accommodation_id              => p_accommodation_id
      ,p_object_version_number         => p_object_version_number
      ,p_accommodation_name            => p_accommodation_name
      ,p_business_group_id             => p_business_group_id
      ,p_location_id                   => p_location_id
      ,p_accommodation_desc            => p_accommodation_desc
      ,p_accommodation_type            => p_accommodation_type
      ,p_style                         => p_style
      ,p_address_line_1                => p_address_line_1
      ,p_address_line_2                => p_address_line_3
      ,p_address_line_3                => p_address_line_3
      ,p_town_or_city                  => p_town_or_city
      ,p_country                       => p_country
      ,p_postal_code                   => p_postal_code
      ,p_region_1                      => p_region_1
      ,p_region_2                      => p_region_2
      ,p_region_3                      => p_region_3
      ,p_telephone_number_1            => p_telephone_number_1
      ,p_telephone_number_2            => p_telephone_number_2
      ,p_telephone_number_3            => p_telephone_number_3
      ,p_floor_number                  => p_floor_number
      ,p_floor_area                    => p_floor_area
      ,p_floor_area_measure_unit       => p_floor_area_measure_unit
      ,p_main_rooms                    => p_main_rooms
      ,p_family_size                   => p_family_size
      ,p_suitability_disabled          => p_suitability_disabled
      ,p_rental_value                  => p_rental_value
      ,p_rental_value_currency         => p_rental_value_currency
      ,p_owner                         => p_owner
      ,p_comments                      => p_comments
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_ACCOMMODATIONS_BK2.update_accommodation_a
      (p_effective_date                => p_effective_date
      ,p_datetrack_mode                => p_datetrack_mode
      ,p_accommodation_id              => p_accommodation_id
      ,p_object_version_number         => p_object_version_number
      ,p_accommodation_name            => p_accommodation_name
      ,p_business_group_id             => p_business_group_id
      ,p_location_id                   => p_location_id
      ,p_accommodation_desc            => p_accommodation_desc
      ,p_accommodation_type            => p_accommodation_type
      ,p_style                         => p_style
      ,p_address_line_1                => p_address_line_1
      ,p_address_line_2                => p_address_line_3
      ,p_address_line_3                => p_address_line_3
      ,p_town_or_city                  => p_town_or_city
      ,p_country                       => p_country
      ,p_postal_code                   => p_postal_code
      ,p_region_1                      => p_region_1
      ,p_region_2                      => p_region_2
      ,p_region_3                      => p_region_3
      ,p_telephone_number_1            => p_telephone_number_1
      ,p_telephone_number_2            => p_telephone_number_2
      ,p_telephone_number_3            => p_telephone_number_3
      ,p_floor_number                  => p_floor_number
      ,p_floor_area                    => p_floor_area
      ,p_floor_area_measure_unit       => p_floor_area_measure_unit
      ,p_main_rooms                    => p_main_rooms
      ,p_family_size                   => p_family_size
      ,p_suitability_disabled          => p_suitability_disabled
      ,p_rental_value                  => p_rental_value
      ,p_rental_value_currency         => p_rental_value_currency
      ,p_owner                         => p_owner
      ,p_comments                      => p_comments
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ACCOMMODATION'
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
  p_object_version_number  := p_object_version_number;
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
    rollback to UPDATE_ACCOMMODATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --

    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    rollback to UPDATE_ACCOMMODATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_accommodation;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------<delete_accommodation>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_accommodation
  (p_validate                         in     boolean  default false
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_accommodation_id                 in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
   ) is
  --
  -- Declare cursors and local variables
  --

  l_proc      varchar2(72) := g_package||'DELETE_SITUATION';
  l_effective_start_date   pqh_accommodations_f.effective_start_date%TYPE;
  l_effective_end_date     pqh_accommodations_f.effective_end_date%TYPE;
l_object_version_number number :=	p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_ACCOMMODATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_ACCOMMODATIONS_BK3.delete_accommodation_b
      (p_effective_date                   => p_effective_date
      ,p_datetrack_mode                   => p_datetrack_mode
      ,p_accommodation_id                 => p_accommodation_id
      ,p_object_version_number            => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ACCOMMODATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_acc_del.del
      (p_effective_date                   => p_effective_date
      ,p_datetrack_mode                   => p_datetrack_mode
      ,p_accommodation_id                 => p_accommodation_id
      ,p_object_version_number            => p_object_version_number
      ,p_effective_start_date             => l_effective_start_date
      ,p_effective_end_date               => l_effective_end_date
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_ACCOMMODATIONS_BK3.delete_accommodation_a
      (p_effective_date                   => p_effective_date
      ,p_datetrack_mode                   => p_datetrack_mode
      ,p_accommodation_id                 => p_accommodation_id
      ,p_object_version_number            => p_object_version_number
      ,p_effective_start_date             => l_effective_start_date
      ,p_effective_end_date               => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ACCOMMODATION'
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
  p_object_version_number  := p_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_ACCOMMODATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    rollback to DELETE_ACCOMMODATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_accommodation;
--
end pqh_accommodations_api;

/
