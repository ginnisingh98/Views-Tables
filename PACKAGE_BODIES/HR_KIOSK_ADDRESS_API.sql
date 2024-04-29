--------------------------------------------------------
--  DDL for Package Body HR_KIOSK_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KIOSK_ADDRESS_API" as
/* $Header: pekadapi.pkb 115.2 2003/02/11 10:48:43 pkakar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_kiosk_address_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_address >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_style                         in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2 default null
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_town_or_city                  in     varchar2 default null
  ,p_region_1                      in     varchar2 default null
  ,p_region_2                      in     varchar2 default null
  ,p_region_3                      in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_country                       in     varchar2 default null
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
  ,p_telephone_number_3            in     varchar2 default null
  ,p_addr_attribute_category       in     varchar2 default null
  ,p_addr_attribute1               in     varchar2 default null
  ,p_addr_attribute2               in     varchar2 default null
  ,p_addr_attribute3               in     varchar2 default null
  ,p_addr_attribute4               in     varchar2 default null
  ,p_addr_attribute5               in     varchar2 default null
  ,p_addr_attribute6               in     varchar2 default null
  ,p_addr_attribute7               in     varchar2 default null
  ,p_addr_attribute8               in     varchar2 default null
  ,p_addr_attribute9               in     varchar2 default null
  ,p_addr_attribute10              in     varchar2 default null
  ,p_addr_attribute11              in     varchar2 default null
  ,p_addr_attribute12              in     varchar2 default null
  ,p_addr_attribute13              in     varchar2 default null
  ,p_addr_attribute14              in     varchar2 default null
  ,p_addr_attribute15              in     varchar2 default null
  ,p_addr_attribute16              in     varchar2 default null
  ,p_addr_attribute17              in     varchar2 default null
  ,p_addr_attribute18              in     varchar2 default null
  ,p_addr_attribute19              in     varchar2 default null
  ,p_addr_attribute20              in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id   per_addresses.business_group_id%TYPE;
  l_date_from           per_addresses.date_from%TYPE;
  l_proc                varchar2(72) := g_package||'create_person_address';
  --
  cursor csr_bus_grp is
  select per.business_group_id
    from per_people_f per
   where per.person_id =       p_person_id
     and l_date_from   between per.effective_start_date
                       and     per.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_person_address;
  end if;
  --
  -- Check that p_person_id, p_date_from are not null as they are used in the
  -- cursor.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'person_id',
     p_argument_value => p_person_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'date_from',
     p_argument_value => p_date_from);
  --
  hr_utility.set_location(l_proc, 6);
  --
  l_date_from := trunc(p_date_from);
  --
  -- Get business_group_id using person_id.
  --
  open  csr_bus_grp;
  fetch csr_bus_grp
   into l_business_group_id;
  --
  if csr_bus_grp%notfound then
    close csr_bus_grp;
    hr_utility.set_message(801, 'HR_7298_ADD_PERSON_INVALID');
    hr_utility.raise_error;
  end if;
  --
  close csr_bus_grp;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Insert Person Address details.
  --
  per_kad_ins.ins
    (p_address_id                   => p_address_id
    ,p_business_group_id            => l_business_group_id
    ,p_person_id                    => p_person_id
    ,p_date_from                    => l_date_from
    ,p_primary_flag                 => p_primary_flag
    ,p_style                        => p_style
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_country                      => p_country
    ,p_date_to                      => trunc(p_date_to)
    ,p_postal_code                  => p_postal_code
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_town_or_city                 => p_town_or_city
    ,p_addr_attribute_category      => p_addr_attribute_category
    ,p_addr_attribute1              => p_addr_attribute1
    ,p_addr_attribute2              => p_addr_attribute2
    ,p_addr_attribute3              => p_addr_attribute3
    ,p_addr_attribute4              => p_addr_attribute4
    ,p_addr_attribute5              => p_addr_attribute5
    ,p_addr_attribute6              => p_addr_attribute6
    ,p_addr_attribute7              => p_addr_attribute7
    ,p_addr_attribute8              => p_addr_attribute8
    ,p_addr_attribute9              => p_addr_attribute9
    ,p_addr_attribute10             => p_addr_attribute10
    ,p_addr_attribute11             => p_addr_attribute11
    ,p_addr_attribute12             => p_addr_attribute12
    ,p_addr_attribute13             => p_addr_attribute13
    ,p_addr_attribute14             => p_addr_attribute14
    ,p_addr_attribute15             => p_addr_attribute15
    ,p_addr_attribute16             => p_addr_attribute16
    ,p_addr_attribute17             => p_addr_attribute17
    ,p_addr_attribute18             => p_addr_attribute18
    ,p_addr_attribute19             => p_addr_attribute19
    ,p_addr_attribute20             => p_addr_attribute20
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => FALSE
    ,p_effective_date               => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_person_address;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_address_id             := null;
    p_object_version_number  := null;
end create_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_gb_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_gb_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_town                          in     varchar2 default null
  ,p_county                        in     varchar2 default null
  ,p_postcode                      in     varchar2 default null
  ,p_country                       in     varchar2
  ,p_telephone_number              in     varchar2 default null
  ,p_addr_attribute_category       in     varchar2 default null
  ,p_addr_attribute1               in     varchar2 default null
  ,p_addr_attribute2               in     varchar2 default null
  ,p_addr_attribute3               in     varchar2 default null
  ,p_addr_attribute4               in     varchar2 default null
  ,p_addr_attribute5               in     varchar2 default null
  ,p_addr_attribute6               in     varchar2 default null
  ,p_addr_attribute7               in     varchar2 default null
  ,p_addr_attribute8               in     varchar2 default null
  ,p_addr_attribute9               in     varchar2 default null
  ,p_addr_attribute10              in     varchar2 default null
  ,p_addr_attribute11              in     varchar2 default null
  ,p_addr_attribute12              in     varchar2 default null
  ,p_addr_attribute13              in     varchar2 default null
  ,p_addr_attribute14              in     varchar2 default null
  ,p_addr_attribute15              in     varchar2 default null
  ,p_addr_attribute16              in     varchar2 default null
  ,p_addr_attribute17              in     varchar2 default null
  ,p_addr_attribute18              in     varchar2 default null
  ,p_addr_attribute19              in     varchar2 default null
  ,p_addr_attribute20              in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_gb_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_kiosk_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'GB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_town
    ,p_region_1                      => p_county
    ,p_postal_code                   => p_postcode
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number
    ,p_addr_attribute_category       => p_addr_attribute_category
    ,p_addr_attribute1               => p_addr_attribute1
    ,p_addr_attribute2               => p_addr_attribute2
    ,p_addr_attribute3               => p_addr_attribute3
    ,p_addr_attribute4               => p_addr_attribute4
    ,p_addr_attribute5               => p_addr_attribute5
    ,p_addr_attribute6               => p_addr_attribute6
    ,p_addr_attribute7               => p_addr_attribute7
    ,p_addr_attribute8               => p_addr_attribute8
    ,p_addr_attribute9               => p_addr_attribute9
    ,p_addr_attribute10              => p_addr_attribute10
    ,p_addr_attribute11              => p_addr_attribute11
    ,p_addr_attribute12              => p_addr_attribute12
    ,p_addr_attribute13              => p_addr_attribute13
    ,p_addr_attribute14              => p_addr_attribute14
    ,p_addr_attribute15              => p_addr_attribute15
    ,p_addr_attribute16              => p_addr_attribute16
    ,p_addr_attribute17              => p_addr_attribute17
    ,p_addr_attribute18              => p_addr_attribute18
    ,p_addr_attribute19              => p_addr_attribute19
    ,p_addr_attribute20              => p_addr_attribute20
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_gb_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_us_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_us_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_state                         in     varchar2 default null
  ,p_zip_code                      in     varchar2 default null
  ,p_county                        in     varchar2 default null
  ,p_country                       in     varchar2
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
  ,p_addr_attribute_category       in     varchar2 default null
  ,p_addr_attribute1               in     varchar2 default null
  ,p_addr_attribute2               in     varchar2 default null
  ,p_addr_attribute3               in     varchar2 default null
  ,p_addr_attribute4               in     varchar2 default null
  ,p_addr_attribute5               in     varchar2 default null
  ,p_addr_attribute6               in     varchar2 default null
  ,p_addr_attribute7               in     varchar2 default null
  ,p_addr_attribute8               in     varchar2 default null
  ,p_addr_attribute9               in     varchar2 default null
  ,p_addr_attribute10              in     varchar2 default null
  ,p_addr_attribute11              in     varchar2 default null
  ,p_addr_attribute12              in     varchar2 default null
  ,p_addr_attribute13              in     varchar2 default null
  ,p_addr_attribute14              in     varchar2 default null
  ,p_addr_attribute15              in     varchar2 default null
  ,p_addr_attribute16              in     varchar2 default null
  ,p_addr_attribute17              in     varchar2 default null
  ,p_addr_attribute18              in     varchar2 default null
  ,p_addr_attribute19              in     varchar2 default null
  ,p_addr_attribute20              in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_us_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_kiosk_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'US'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_county
    ,p_region_2                      => p_state
    ,p_postal_code                   => p_zip_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_addr_attribute_category       => p_addr_attribute_category
    ,p_addr_attribute1               => p_addr_attribute1
    ,p_addr_attribute2               => p_addr_attribute2
    ,p_addr_attribute3               => p_addr_attribute3
    ,p_addr_attribute4               => p_addr_attribute4
    ,p_addr_attribute5               => p_addr_attribute5
    ,p_addr_attribute6               => p_addr_attribute6
    ,p_addr_attribute7               => p_addr_attribute7
    ,p_addr_attribute8               => p_addr_attribute8
    ,p_addr_attribute9               => p_addr_attribute9
    ,p_addr_attribute10              => p_addr_attribute10
    ,p_addr_attribute11              => p_addr_attribute11
    ,p_addr_attribute12              => p_addr_attribute12
    ,p_addr_attribute13              => p_addr_attribute13
    ,p_addr_attribute14              => p_addr_attribute14
    ,p_addr_attribute15              => p_addr_attribute15
    ,p_addr_attribute16              => p_addr_attribute16
    ,p_addr_attribute17              => p_addr_attribute17
    ,p_addr_attribute18              => p_addr_attribute18
    ,p_addr_attribute19              => p_addr_attribute19
    ,p_addr_attribute20              => p_addr_attribute20
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_us_person_address;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_address >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_town_or_city                  in     varchar2 default hr_api.g_varchar2
  ,p_region_1                      in     varchar2 default hr_api.g_varchar2
  ,p_region_2                      in     varchar2 default hr_api.g_varchar2
  ,p_region_3                      in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_3            in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number per_addresses.object_version_number%TYPE;
  l_proc                  varchar2(72) := g_package||'update_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_person_address;
  end if;
  hr_utility.set_location(l_proc, 6);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Update Person Address details.
  --
  per_kad_upd.upd
    (p_address_id                   => p_address_id
    ,p_date_from                    => trunc(p_date_from)
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_country                      => p_country
    ,p_date_to                      => trunc(p_date_to)
    ,p_postal_code                  => p_postal_code
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_town_or_city                 => p_town_or_city
    ,p_addr_attribute_category      => p_addr_attribute_category
    ,p_addr_attribute1              => p_addr_attribute1
    ,p_addr_attribute2              => p_addr_attribute2
    ,p_addr_attribute3              => p_addr_attribute3
    ,p_addr_attribute4              => p_addr_attribute4
    ,p_addr_attribute5              => p_addr_attribute5
    ,p_addr_attribute6              => p_addr_attribute6
    ,p_addr_attribute7              => p_addr_attribute7
    ,p_addr_attribute8              => p_addr_attribute8
    ,p_addr_attribute9              => p_addr_attribute9
    ,p_addr_attribute10             => p_addr_attribute10
    ,p_addr_attribute11             => p_addr_attribute11
    ,p_addr_attribute12             => p_addr_attribute12
    ,p_addr_attribute13             => p_addr_attribute13
    ,p_addr_attribute14             => p_addr_attribute14
    ,p_addr_attribute15             => p_addr_attribute15
    ,p_addr_attribute16             => p_addr_attribute16
    ,p_addr_attribute17             => p_addr_attribute17
    ,p_addr_attribute18             => p_addr_attribute18
    ,p_addr_attribute19             => p_addr_attribute19
    ,p_addr_attribute20             => p_addr_attribute20
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => FALSE
    ,p_effective_date               => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_person_address;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
end update_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_gb_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_gb_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_town                          in     varchar2 default hr_api.g_varchar2
  ,p_county                        in     varchar2 default hr_api.g_varchar2
  ,p_postcode                      in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_gb_person_address';
  l_style               per_addresses.style%TYPE;
  --
  cursor csr_add_style is
  select addr.style
    from per_addresses addr
   where addr.address_id = p_address_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that the Address identified is GB style.
  --
  open  csr_add_style;
  fetch csr_add_style
   into l_style;
  if csr_add_style%notfound then
    --
    close csr_add_style;
    --
    hr_utility.set_location(l_proc, 7);
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
    --
  else
    --
    close csr_add_style;
    --
    if l_style <> 'GB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_7788_ADD_INV_NOT_GB_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_kiosk_address_api.update_person_address
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_address_id                   => p_address_id
    ,p_object_version_number        => p_object_version_number
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_town_or_city                 => p_town
    ,p_region_1                     => p_county
    ,p_postal_code                  => p_postcode
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number
    ,p_addr_attribute_category      => p_addr_attribute_category
    ,p_addr_attribute1              => p_addr_attribute1
    ,p_addr_attribute2              => p_addr_attribute2
    ,p_addr_attribute3              => p_addr_attribute3
    ,p_addr_attribute4              => p_addr_attribute4
    ,p_addr_attribute5              => p_addr_attribute5
    ,p_addr_attribute6              => p_addr_attribute6
    ,p_addr_attribute7              => p_addr_attribute7
    ,p_addr_attribute8              => p_addr_attribute8
    ,p_addr_attribute9              => p_addr_attribute9
    ,p_addr_attribute10             => p_addr_attribute10
    ,p_addr_attribute11             => p_addr_attribute11
    ,p_addr_attribute12             => p_addr_attribute12
    ,p_addr_attribute13             => p_addr_attribute13
    ,p_addr_attribute14             => p_addr_attribute14
    ,p_addr_attribute15             => p_addr_attribute15
    ,p_addr_attribute16             => p_addr_attribute16
    ,p_addr_attribute17             => p_addr_attribute17
    ,p_addr_attribute18             => p_addr_attribute18
    ,p_addr_attribute19             => p_addr_attribute19
    ,p_addr_attribute20             => p_addr_attribute20
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_gb_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_us_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_us_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_state                         in     varchar2 default hr_api.g_varchar2
  ,p_zip_code                      in     varchar2 default hr_api.g_varchar2
  ,p_county                        in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_us_person_address';
  l_style               per_addresses.style%TYPE;
  --
  cursor csr_add_style is
  select style
    from per_addresses
   where address_id = p_address_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that the address is US style.
  --
  open  csr_add_style;
  fetch csr_add_style
   into l_style;
  if csr_add_style%notfound then
    close csr_add_style;
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  else
    hr_utility.set_location(l_proc, 10);
    --
    close csr_add_style;
    --
    if l_style <> 'US' then
      hr_utility.set_message(801, 'HR_51283_ADD_MUST_BE_US_STYLE');
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Update Person Address details.
  --
  hr_kiosk_address_api.update_person_address
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_address_id                   => p_address_id
    ,p_object_version_number        => p_object_version_number
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_town_or_city                 => p_city
    ,p_region_1                     => p_county
    ,p_region_2                     => p_state
    ,p_postal_code                  => p_zip_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_addr_attribute_category      => p_addr_attribute_category
    ,p_addr_attribute1              => p_addr_attribute1
    ,p_addr_attribute2              => p_addr_attribute2
    ,p_addr_attribute3              => p_addr_attribute3
    ,p_addr_attribute4              => p_addr_attribute4
    ,p_addr_attribute5              => p_addr_attribute5
    ,p_addr_attribute6              => p_addr_attribute6
    ,p_addr_attribute7              => p_addr_attribute7
    ,p_addr_attribute8              => p_addr_attribute8
    ,p_addr_attribute9              => p_addr_attribute9
    ,p_addr_attribute10             => p_addr_attribute10
    ,p_addr_attribute11             => p_addr_attribute11
    ,p_addr_attribute12             => p_addr_attribute12
    ,p_addr_attribute13             => p_addr_attribute13
    ,p_addr_attribute14             => p_addr_attribute14
    ,p_addr_attribute15             => p_addr_attribute15
    ,p_addr_attribute16             => p_addr_attribute16
    ,p_addr_attribute17             => p_addr_attribute17
    ,p_addr_attribute18             => p_addr_attribute18
    ,p_addr_attribute19             => p_addr_attribute19
    ,p_addr_attribute20             => p_addr_attribute20
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end update_us_person_address;
--
end hr_kiosk_address_api;

/
