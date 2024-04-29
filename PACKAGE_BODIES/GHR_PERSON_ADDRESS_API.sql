--------------------------------------------------------
--  DDL for Package Body GHR_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PERSON_ADDRESS_API" as
/* $Header: ghaddapi.pkb 120.1 2005/07/01 12:43:45 vnarasim noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_person_address_api.';
--
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
  ,p_comments                      in     long default null
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
  ,p_address_id                       out nocopy  number
  ,p_object_version_number            out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_us_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);

    savepoint ghr_create_us_person_address;

  hr_utility.set_location(l_proc, 6);

  -- set session variables
     ghr_session.set_session_var_for_core
     (p_effective_date   => p_effective_date
     );

  -- Call US Person Address api
  --
  hr_utility.set_location(l_proc, 10);
  hr_person_address_api.create_us_person_address
    (--p_validate                      => p_validate
    p_effective_date                => p_effective_date
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_city                          => p_city
    ,p_county                        => p_county
    ,p_state                         => p_state
    ,p_zip_code                      => p_zip_code
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
  hr_utility.set_location(l_proc, 20);
  ghr_history_api.post_update_process;
  hr_utility.set_location(l_proc,25);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    hr_utility.set_location(l_proc, 30);
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location(l_proc, 35);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_us_person_address;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
   when others then
     ROLLBACK TO ghr_create_us_person_address;
     p_address_id            := null;
     p_object_version_number := null;
     raise;
end create_us_person_address;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_us_int_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_us_int_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_validate_county               in     boolean  default true
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_party_id                      in     number   default null -- HR/TCA merge
  ,p_address_id                       out nocopy  number
  ,p_object_version_number            out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_us_int_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);

    savepoint ghr_create_us_int_per_address;

  hr_utility.set_location(l_proc, 6);

  -- set session variables
     ghr_session.set_session_var_for_core
     (p_effective_date   => p_effective_date
     );

  -- Call US Person Address api
  --
  hr_utility.set_location(l_proc, 10);
   hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_validate_county               => p_validate_county
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'US_GLB'
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
    ,p_add_information13             => p_add_information13
    ,p_add_information14             => p_add_information14
    ,p_add_information15             => p_add_information15
    ,p_add_information16             => p_add_information16
    ,p_add_information17             => p_add_information17
    ,p_add_information18             => p_add_information18
    ,p_add_information19             => p_add_information19
    ,p_add_information20             => p_add_information20
    ,p_party_id                      => p_party_id -- HR/TCA merge
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );

  --
  hr_utility.set_location(l_proc, 20);
  ghr_history_api.post_update_process;
  hr_utility.set_location(l_proc,25);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    hr_utility.set_location(l_proc, 30);
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location(l_proc, 35);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_us_int_per_address;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
   when others then
     ROLLBACK TO ghr_create_us_int_per_address;
     p_address_id            := null;
     p_object_version_number := null;
     raise;
end create_us_int_person_address;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_us_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_us_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy  number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
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
  l_proc                   varchar2(72) := g_package||'update_us_person_address';
  l_object_version_number  per_addresses.object_version_number%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
    l_object_version_number    :=  p_object_version_number;
    hr_utility.set_location(l_proc, 10);
    savepoint ghr_update_us_person_address;


  --
  hr_utility.set_location(l_proc, 15);
  ghr_session.set_session_var_for_core
  (p_effective_date     =>   p_effective_date
  );

  --
  hr_utility.set_location(l_proc, 20);
  hr_person_address_api.update_us_person_address
    (--p_validate                     => p_validate
    p_effective_date               => p_effective_date
    ,p_address_id                   => p_address_id
    ,p_object_version_number        => p_object_version_number
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_city  		            => p_city
    ,p_county                       => p_county
    ,p_state                        => p_state
    ,p_zip_code                     => p_zip_code
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
   hr_utility.set_location(l_proc, 25);
  ghr_history_api.post_update_process;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    hr_utility.set_location(l_proc, 45);
    ROLLBACK TO ghr_update_us_person_address;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
     hr_utility.set_location(' Leaving:'||l_proc, 50);
    when others then
     ROLLBACK TO ghr_update_us_person_address;
     p_object_version_number := l_object_version_number;
     raise;
end update_us_person_address;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_us_int_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_us_int_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_validate_county               in     boolean  default true
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy  number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
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
  ,p_add_information13             in     varchar2 default hr_api.g_varchar2
  ,p_add_information14             in     varchar2 default hr_api.g_varchar2
  ,p_add_information15             in     varchar2 default hr_api.g_varchar2
  ,p_add_information16             in     varchar2 default hr_api.g_varchar2
  ,p_add_information17             in     varchar2 default hr_api.g_varchar2
  ,p_add_information18             in     varchar2 default hr_api.g_varchar2
  ,p_add_information19             in     varchar2 default hr_api.g_varchar2
  ,p_add_information20             in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_us_int_person_address';
  l_object_version_number  per_addresses.object_version_number%type;
  l_style                  varchar2(80);
  --
  cursor csr_add_style is
  select style
    from per_addresses
   where address_id = p_address_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  -- NOCOPY Changes
  l_object_version_number := p_object_version_number;
  --
  -- Check that the address is US International style.
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
    if l_style <> 'US_GLB' then
      hr_utility.set_message(801, 'HR_51283_ADD_MUST_BE_US_STYLE');
      hr_utility.raise_error;
    end if;
  end if;
  --
    savepoint ghr_update_us_int_per_address;

  l_object_version_number    :=  p_object_version_number;
  --
  hr_utility.set_location(l_proc, 15);
  ghr_session.set_session_var_for_core
  (p_effective_date     =>   p_effective_date
  );

  --
  hr_utility.set_location(l_proc, 20);
  hr_person_address_api.update_person_address
    (p_validate                     => p_validate
    ,p_validate_county              => p_validate_county
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
    ,p_add_information13            => p_add_information13
    ,p_add_information14            => p_add_information14
    ,p_add_information15            => p_add_information15
    ,p_add_information16            => p_add_information16
    ,p_add_information17            => p_add_information17
    ,p_add_information18            => p_add_information18
    ,p_add_information19            => p_add_information19
    ,p_add_information20            => p_add_information20
    );
  --
  hr_utility.set_location(l_proc, 25);
  ghr_history_api.post_update_process;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    hr_utility.set_location(l_proc, 45);
    ROLLBACK TO ghr_update_us_int_per_address;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
     hr_utility.set_location(' Leaving:'||l_proc, 50);
    when others then
     ROLLBACK TO ghr_update_us_int_per_address;
     p_object_version_number := l_object_version_number;
     raise;
end update_us_int_person_address;
--
end ghr_person_address_api;

/
