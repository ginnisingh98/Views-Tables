--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ADDRESS_API" as
/* $Header: peaddapi.pkb 120.2.12010000.2 2009/10/01 07:24:00 pchowdav ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_person_address_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_address >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_validate_county               in     boolean  default true
  ,p_person_id                     in     number   default null -- HR/TCA merge
  ,p_primary_flag                  in     varchar2
  ,p_style                         in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_party_id                      in     number   default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id        number;
  l_date_from                date;
  l_proc                     varchar2(72) := g_package||'create_person_address';
  l_date_to                  date;
  l_effective_date           date;
  --
  -- Declare out parameters
  --
  l_address_id               number;
  l_object_version_number    number;
  l_praddress_id             number;
  l_befpradd_id              number;
  l_befpradd_ovn             number;
  l_befpradddate_to          date;
  --
--
-- Bug# 2968022 Start Here
-- Description : Removed the date track mode condition from the cursor
--
-- Bug # 3078778 - DK 2003-08-02
--  Use base table here rather than view. At worst this is a safe change
--  since the api parameters can be assumed to be trusted. It's a consequence
--  of the fact that with a view contact setting of Restricted, no contacts
--  appear in supervisor based security profiles. Benefits related
--  processing of dependents of terminated employees (ie creating
--  addresses for them) needs those contacts to be available in
--  MEE which is typically secured by supervisor security.
-- 3078778
--
  cursor csr_bus_grp is
  select per.business_group_id
    from per_all_people_f per
   where per.person_id =       p_person_id;
--
-- Bug# 2968022 End Here
--
  --
  cursor csr_befpradd is
  select adr.address_id,
         adr.object_version_number,
         adr.date_to
    from per_addresses adr
   where adr.person_id     = p_person_id
     and adr.primary_flag  = 'Y'
     and l_effective_date
       between adr.date_from
         and nvl(adr.date_to,hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_person_address;
  --
  -- Check that p_person_id, p_date_from are not null as they are used in the
  -- cursor.
  --
  if p_party_id is null and p_person_id is not null then -- HR/TCA merge
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'person_id',
       p_argument_value => p_person_id);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'date_from',
     p_argument_value => p_date_from);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_utility.set_location(l_proc, 6);
  --
  l_date_from := trunc(p_date_from);
  l_date_to := trunc(p_date_to);
  l_effective_date := trunc(p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_person_address
    --start of code for bug2611597
    if l_effective_date < l_date_from then
       l_effective_date := l_date_from;
    end if;
    -- End of code for bug2611597
    hr_person_address_bk1.create_person_address_b
      (p_effective_date               => l_effective_date
      ,p_pradd_ovlapval_override      => p_pradd_ovlapval_override
      ,p_validate_county              => p_validate_county
      ,p_person_id                    => p_person_id
      ,p_primary_flag                 => p_primary_flag
      ,p_style                        => p_style
      ,p_date_from                    => l_date_from
      ,p_date_to                      => l_date_to
      ,p_address_type                 => p_address_type
      ,p_comments                     => p_comments
      ,p_address_line1                => p_address_line1
      ,p_address_line2                => p_address_line2
      ,p_address_line3                => p_address_line3
      ,p_town_or_city                 => p_town_or_city
      ,p_region_1                     => p_region_1
      ,p_region_2                     => p_region_2
      ,p_region_3                     => p_region_3
      ,p_postal_code                  => p_postal_code
      ,p_country                      => p_country
      ,p_telephone_number_1           => p_telephone_number_1
      ,p_telephone_number_2           => p_telephone_number_2
      ,p_telephone_number_3           => p_telephone_number_3
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
      ,p_party_id                     => p_party_id -- HR/TCA merge
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_ADDRESS'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_person_address
    --
  end;
  if p_person_id is not null then -- HR/TCA merge
    --
    -- Get business_group_id using person_id.
    --
    open  csr_bus_grp;
    fetch csr_bus_grp into l_business_group_id;
    --
    if csr_bus_grp%notfound then
      close csr_bus_grp;
      hr_utility.set_message(801, 'HR_7298_ADD_PERSON_INVALID');
      hr_utility.raise_error;
    end if;
    close csr_bus_grp;
  end if;
  hr_utility.set_location(l_proc, 70);
  --
  -- Check if primary address overlap validation override mode is on
  --
  if p_pradd_ovlapval_override
    and p_primary_flag = 'Y'
  then
    --
    -- Get the most recent previous primary address details for the person
    --
    open  csr_befpradd;
    fetch csr_befpradd into l_befpradd_id, l_befpradd_ovn, l_befpradddate_to;
    close csr_befpradd;
    if l_befpradd_id is not null then
      --
      -- Check if primary address overlap validation override mode is on
      --
      if p_pradd_ovlapval_override then
        --
        -- End date the previous primary address
        --
        l_befpradddate_to := p_effective_date-1;
        --
        per_add_upd.upd
          (p_address_id            => l_befpradd_id
          ,p_object_version_number => l_befpradd_ovn
          ,p_effective_date        => p_effective_date
          ,p_date_to               => l_befpradddate_to
          --
          ,p_prflagval_override    => TRUE
          );
        --
      end if;
      --
    end if;
    --
  end if;
  hr_utility.set_location(l_proc, 80);
  --
  -- Insert Person Address details.
  --
  per_add_ins.ins
    (p_address_id                   => l_address_id
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
    ,p_date_to                      => l_date_to
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
    ,p_add_information13            => p_add_information13
    ,p_add_information14            => p_add_information14
    ,p_add_information15            => p_add_information15
    ,p_add_information16            => p_add_information16
    ,p_add_information17            => p_add_information17
    ,p_add_information18            => p_add_information18
    ,p_add_information19            => p_add_information19
    ,p_add_information20            => p_add_information20
    ,p_object_version_number        => l_object_version_number
    ,p_validate                     => FALSE
    ,p_effective_date               => l_effective_date
    ,p_validate_county              => p_validate_county
    ,p_party_id                     => p_party_id  -- HR/TCA merge
    );
  --
  hr_utility.set_location(l_proc, 8);
  begin
    --
    -- Start of API User Hook for the after hook of create_person_address
    --
    hr_person_address_bk1.create_person_address_a
      (p_effective_date               => l_effective_date
      ,p_pradd_ovlapval_override      => p_pradd_ovlapval_override
      ,p_validate_county              => p_validate_county
      ,p_person_id                    => p_person_id
      ,p_primary_flag                 => p_primary_flag
      ,p_style                        => p_style
      ,p_date_from                    => l_date_from
      ,p_date_to                      => l_date_to
      ,p_address_type                 => p_address_type
      ,p_comments                     => p_comments
      ,p_address_line1                => p_address_line1
      ,p_address_line2                => p_address_line2
      ,p_address_line3                => p_address_line3
      ,p_town_or_city                 => p_town_or_city
      ,p_region_1                     => p_region_1
      ,p_region_2                     => p_region_2
      ,p_region_3                     => p_region_3
      ,p_postal_code                  => p_postal_code
      ,p_country                      => p_country
      ,p_telephone_number_1           => p_telephone_number_1
      ,p_telephone_number_2           => p_telephone_number_2
      ,p_telephone_number_3           => p_telephone_number_3
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
      ,p_address_id                   => l_address_id
      ,p_object_version_number        => l_object_version_number
      ,p_party_id                     => p_party_id -- HR/TCA merge
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_ADDRESS'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_person_address
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set remaining output arguments
  --
  p_address_id             := l_address_id;
  p_object_version_number  := l_object_version_number;
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
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_address_id             := null;
    p_object_version_number  := null;

    ROLLBACK TO create_person_address;
    raise;
    --
    -- End of fix.
    --
end create_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_gb_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_gb_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number   default null -- HR/TCA merge
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_town                          in     varchar2 default null
  ,p_county                        in     varchar2 default null
  ,p_postcode                      in     varchar2 default null
  ,p_country                       in     varchar2
  ,p_telephone_number              in     varchar2 default null
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
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    ,p_party_id                      => p_party_id -- HR/TCA merge
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
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_validate_county               in     boolean  default true
  ,p_person_id                     in     number   default null -- HR/TCA merge
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
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_validate_county               => p_validate_county
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_us_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_AT_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_AT_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_region                        in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_AT_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'AT_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_region
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_AT_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_AU_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_AU_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
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
  ,p_country                       in     varchar2
  ,p_postal_code                   in     varchar2 default null
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_AU_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'AU_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_state
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_AU_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_DK_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_DK_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_DK_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'DK_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_DK_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_DE_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_DE_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_region                        in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_DE_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'DE_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_region
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_DE_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_IT_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_IT_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_province                      in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_IT_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'IT_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_province
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_IT_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_MX_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_MX_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_state                         in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_MX_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'MX_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_state
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_MX_person_address;

--
--  --------------------------------------------------------------------------
-- |-----------------------< create_MX_LOC_person_address >-------------------|
--  --------------------------------------------------------------------------
--
procedure create_MX_LOC_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_street_name_and_num           in     varchar2
  ,p_neighborhood                  in     varchar2 default null
  ,p_municipality                  in     varchar2
  ,p_postal_code                   in     varchar2
  ,p_city                          in     varchar2
  ,p_state                         in     varchar2
  ,p_country                       in     varchar2
  ,p_telephone                     in     varchar2 default null
  ,p_fax                           in     varchar2 default null
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
  ,p_party_id                      in     number   default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_MX_LOC_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'MX'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_street_name_and_num
    ,p_address_line2                 => p_neighborhood
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_state
    ,p_region_2                      => p_municipality
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone
    ,p_telephone_number_2            => p_fax
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
    ,p_party_id                      => p_party_id
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_MX_LOC_person_address;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_MY_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_MY_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_region                        in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_MY_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'MY_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_region
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_MY_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_PT_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PT_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_PT_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'PT_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_PT_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_BE_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_BE_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_BE_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'BE'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_BE_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_FI_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_FI_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_FI_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'FI_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_FI_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_GR_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_GR_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_GR_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'GR_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_GR_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_HK_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_HK_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_district                      in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_HK_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'HK'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_district
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_HK_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_IE_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_IE_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
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
  ,p_county                        in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_IE_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'IE_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_county
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_IE_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_LU_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_LU_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_LU_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'LU_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_LU_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_NL_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_NL_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_region                        in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_NL_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'NL_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_region
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_NL_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_SG_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_SG_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
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
  ,p_postal_code                   in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_SG_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'SG_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_SG_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_SE_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_SE_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_country                       in     varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_SE_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'SE_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_SE_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ES_GLB_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ES_GLB_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_province                      in     varchar2 default null
  ,p_country                       in     varchar2 default null
  ,p_telephone                     in     varchar2 default null
  ,p_telephone2                    in     varchar2 default null
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
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) ;
  --
begin
  --
  l_proc := g_package||'create_ES_GLB_person_address';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'ES_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_province
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone
    ,p_telephone_number_2            => p_telephone2
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
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_ES_GLB_person_address;
--
--  --------------------------------------------------------------------------
-- |-----------------------< create_ES_person_address >-------------------|
--  --------------------------------------------------------------------------
--
procedure create_ES_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_location_type                 in     varchar2
  ,p_location_name                 in     varchar2
  ,p_location_number               in     varchar2 default null
  ,p_building                      in     varchar2 default null
  ,p_stairs                        in     varchar2 default null
  ,p_floor                         in     varchar2 default null
  ,p_door                          in     varchar2 default null
  ,p_city                          in     varchar2
  ,p_province_name                 in     varchar2
  ,p_postal_code                   in     varchar2
  ,p_country                       in     varchar2
  ,p_telephone                     in     varchar2 default null
  ,p_telephone2                   in      varchar2 default null
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
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                    out    nocopy number
  ,p_object_version_number         out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) ;
  --
begin
  --
  l_proc := g_package||'create_ES_person_address';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'ES'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_location_type
    ,p_address_line2                 => p_location_name
    ,p_address_line3                 => p_location_number
    ,p_add_information13             => p_building
    ,p_add_information14             => p_stairs
    ,p_add_information15             => p_floor
    ,p_add_information16             => p_door
    ,p_town_or_city                  => p_city
    ,p_region_2                      => p_province_name
    ,p_postal_code                   => p_postal_code
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone
    ,p_telephone_number_2            => p_telephone2
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
    ,p_add_information17             => p_add_information17
    ,p_add_information18             => p_add_information18
    ,p_add_information19             => p_add_information19
    ,p_add_information20             => p_add_information20
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end create_ES_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_SA_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_SA_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_person_id                     in     number   default null -- HR/TCA merge
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long default null
  ,p_address_line1                 in     varchar2 default null
  ,p_address_line2                 in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_street                        in     varchar2 default null
  ,p_area                          in     varchar2 default null
  ,p_po_box                        in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
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
  l_proc                varchar2(72) := g_package||'create_SA_person_address';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'SA'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_town_or_city                  => p_city
    ,p_region_1                      => p_street
    ,p_region_2                      => p_area
    ,p_region_3                      => p_po_box
    ,p_postal_code                   => p_postal_code
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
end create_SA_person_address;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_address >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_validate_county               in     boolean  default true
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
-- Start of fix for Bug #2431588
  ,p_primary_flag                  in     varchar2 default hr_api.g_varchar2
-- End of fix for Bug #2431588
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
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
  ,p_add_information13             in     varchar2 default hr_api.g_varchar2
  ,p_add_information14             in     varchar2 default hr_api.g_varchar2
  ,p_add_information15             in     varchar2 default hr_api.g_varchar2
  ,p_add_information16             in     varchar2 default hr_api.g_varchar2
  ,p_add_information17             in     varchar2 default hr_api.g_varchar2
  ,p_add_information18             in     varchar2 default hr_api.g_varchar2
  ,p_add_information19             in     varchar2 default hr_api.g_varchar2
  ,p_add_information20             in     varchar2 default hr_api.g_varchar2
  ,p_party_id                      in     number   default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number per_addresses.object_version_number%TYPE;
  l_proc                  varchar2(72) := g_package||'update_person_address';
  l_effective_date        date;
  l_date_from             per_addresses.date_from%TYPE;
  l_date_to               per_addresses.date_to%TYPE;
  --
  lv_object_version_number number := p_object_version_number ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_person_address;
  --
  -- Check that p_date_from and p_effective_date are not null.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'date_from',
     p_argument_value => p_date_from);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_utility.set_location(l_proc, 6);
  --
  l_date_from := trunc(p_date_from);
  l_date_to := trunc(p_date_to);
  l_effective_date := trunc(p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_person_address
    --
    -- Bug fix 3320430. And condition added to the if condition , to avoid
    -- l_effective_date being modified when l_date_to is having default
    -- value hr_api.g_date.
    --start of code for bug2611597
    if l_effective_date > l_date_to and nvl( l_date_to,hr_api.g_date ) <> hr_api.g_date then
       l_effective_date := l_date_to;
    end if;
    -- End of code for bug2611597
    hr_person_address_bk2.update_person_address_b
      (p_effective_date               => l_effective_date
      ,p_validate_county              => p_validate_county
      ,p_address_id                   => p_address_id
      ,p_object_version_number        => p_object_version_number
      ,p_date_from                    => l_date_from
      ,p_date_to                      => l_date_to
      ,p_address_type                 => p_address_type
      ,p_comments                     => p_comments
      ,p_address_line1                => p_address_line1
      ,p_address_line2                => p_address_line2
      ,p_address_line3                => p_address_line3
      ,p_town_or_city                 => p_town_or_city
      ,p_region_1                     => p_region_1
      ,p_region_2                     => p_region_2
      ,p_region_3                     => p_region_3
      ,p_postal_code                  => p_postal_code
      ,p_country                      => p_country
      ,p_telephone_number_1           => p_telephone_number_1
      ,p_telephone_number_2           => p_telephone_number_2
      ,p_telephone_number_3           => p_telephone_number_3
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
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_ADDRESS'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_person_address
    --
  end;
  --
  hr_utility.set_location(l_proc, 6);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Update Person Address details.
  --
  per_add_upd.upd
    (p_address_id                   => p_address_id
    ,p_date_from                    => l_date_from
-- Start of fix for Bug #2431588
  ,p_primary_flag                   => p_primary_flag
-- End of fix for Bug #2431588
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_country                      => p_country
    ,p_date_to                      => l_date_to
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
    ,p_add_information13            => p_add_information13
    ,p_add_information14            => p_add_information14
    ,p_add_information15            => p_add_information15
    ,p_add_information16            => p_add_information16
    ,p_add_information17            => p_add_information17
    ,p_add_information18            => p_add_information18
    ,p_add_information19            => p_add_information19
    ,p_add_information20            => p_add_information20
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => FALSE
    ,p_effective_date               => l_effective_date
    ,p_validate_county              => p_validate_county
    ,p_party_id                     => p_party_id
    );
  --
  hr_utility.set_location(l_proc, 8);
  begin
    --
    -- Start of API User Hook for the after hook of update_person_address
    --
    hr_person_address_bk2.update_person_address_a
      (p_effective_date               => l_effective_date
      ,p_validate_county              => p_validate_county
      ,p_address_id                   => p_address_id
      ,p_object_version_number        => p_object_version_number
      ,p_date_from                    => l_date_from
      ,p_date_to                      => l_date_to
      ,p_address_type                 => p_address_type
      ,p_comments                     => p_comments
      ,p_address_line1                => p_address_line1
      ,p_address_line2                => p_address_line2
      ,p_address_line3                => p_address_line3
      ,p_town_or_city                 => p_town_or_city
      ,p_region_1                     => p_region_1
      ,p_region_2                     => p_region_2
      ,p_region_3                     => p_region_3
      ,p_postal_code                  => p_postal_code
      ,p_country                      => p_country
      ,p_telephone_number_1           => p_telephone_number_1
      ,p_telephone_number_2           => p_telephone_number_2
      ,p_telephone_number_3           => p_telephone_number_3
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
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_ADDRESS'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_person_address
    --
  end;
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
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;
    ROLLBACK TO update_person_address;
    raise;
    --
    -- End of fix.
    --
end update_person_address;
--
-- ----------------------------------------------------------------------------
-- |---------------< update_pers_addr_with_style >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pers_addr_with_style
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_validate_county               in     boolean  default true
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
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
  ,p_add_information13             in     varchar2 default null
  ,p_add_information14             in     varchar2 default null
  ,p_add_information15             in     varchar2 default null
  ,p_add_information16             in     varchar2 default null
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_party_id                      in     number   default hr_api.g_number
  ,p_style                         in     varchar2
-- Start of fix for Bug #2431588
  ,p_primary_flag		   in     varchar2 default hr_api.g_varchar2
-- End of fix for Bug #2431588
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number per_addresses.object_version_number%TYPE;
  l_proc                  varchar2(72) := g_package||'update_pers_addr_with_style';
  l_effective_date        date;
  l_date_from             per_addresses.date_from%TYPE;
  l_date_to               per_addresses.date_to%TYPE;
  --
  lv_object_version_number number := p_object_version_number ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_pers_addr_with_style;
  --
  -- Check that p_date_from and p_effective_date are not null.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'date_from',
     p_argument_value => p_date_from);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_utility.set_location(l_proc, 6);
  --
  l_date_from := trunc(p_date_from);
  l_date_to := trunc(p_date_to);
  l_effective_date := trunc(p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_pers_addr_with_style
    --
    hr_person_address_bk3.update_pers_addr_with_style_b
      (p_effective_date               => l_effective_date
      ,p_validate_county              => p_validate_county
      ,p_address_id                   => p_address_id
      ,p_object_version_number        => p_object_version_number
      ,p_date_from                    => l_date_from
      ,p_date_to                      => l_date_to
      ,p_address_type                 => p_address_type
      ,p_comments                     => p_comments
      ,p_address_line1                => p_address_line1
      ,p_address_line2                => p_address_line2
      ,p_address_line3                => p_address_line3
      ,p_town_or_city                 => p_town_or_city
      ,p_region_1                     => p_region_1
      ,p_region_2                     => p_region_2
      ,p_region_3                     => p_region_3
      ,p_postal_code                  => p_postal_code
      ,p_country                      => p_country
      ,p_telephone_number_1           => p_telephone_number_1
      ,p_telephone_number_2           => p_telephone_number_2
      ,p_telephone_number_3           => p_telephone_number_3
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
      ,p_style                        => p_style
      ,p_primary_flag                 => p_primary_flag  --fix for bug 8938775
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERS_ADDR_WITH_STYLE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_pers_addr_with_style
    --
  end;
  --
  hr_utility.set_location(l_proc, 6);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Update Person Address details.
  --
  per_add_upd.upd
    (p_address_id                   => p_address_id
    ,p_date_from                    => l_date_from
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_country                      => p_country
    ,p_date_to                      => l_date_to
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
    ,p_add_information13            => p_add_information13
    ,p_add_information14            => p_add_information14
    ,p_add_information15            => p_add_information15
    ,p_add_information16            => p_add_information16
    ,p_add_information17            => p_add_information17
    ,p_add_information18            => p_add_information18
    ,p_add_information19            => p_add_information19
    ,p_add_information20            => p_add_information20
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => FALSE
    ,p_effective_date               => l_effective_date
    ,p_validate_county              => p_validate_county
    ,p_party_id                     => p_party_id
    ,p_style                        => p_style
  -- Start of fix part2 for Bug #2431588
    ,p_primary_flag                   => p_primary_flag
  -- End of fix part2 for Bug #2431588
    );
  --
  hr_utility.set_location(l_proc, 8);
  begin
    --
    -- Start of API User Hook for the after hook of update_pers_addr_with_style
    --
    hr_person_address_bk3.update_pers_addr_with_style_a
      (p_effective_date               => l_effective_date
      ,p_validate_county              => p_validate_county
      ,p_address_id                   => p_address_id
      ,p_object_version_number        => p_object_version_number
      ,p_date_from                    => l_date_from
      ,p_date_to                      => l_date_to
      ,p_address_type                 => p_address_type
      ,p_comments                     => p_comments
      ,p_address_line1                => p_address_line1
      ,p_address_line2                => p_address_line2
      ,p_address_line3                => p_address_line3
      ,p_town_or_city                 => p_town_or_city
      ,p_region_1                     => p_region_1
      ,p_region_2                     => p_region_2
      ,p_region_3                     => p_region_3
      ,p_postal_code                  => p_postal_code
      ,p_country                      => p_country
      ,p_telephone_number_1           => p_telephone_number_1
      ,p_telephone_number_2           => p_telephone_number_2
      ,p_telephone_number_3           => p_telephone_number_3
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
      ,p_style                        => p_style
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERS_ADDR_WITH_STYLE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_pers_addr_with_style
    --
  end;
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
    ROLLBACK TO update_pers_addr_with_style;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;
    ROLLBACK TO update_pers_addr_with_style;
    raise;
    --
    -- End of fix.
    --
end update_pers_addr_with_style;
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
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_town                          in     varchar2 default hr_api.g_varchar2
  ,p_county                        in     varchar2 default hr_api.g_varchar2
  ,p_postcode                      in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number              in     varchar2 default hr_api.g_varchar2
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
  ,p_add_information13	           in     varchar2 default hr_api.g_varchar2
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
  hr_person_address_api.update_person_address
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
  ,p_validate_county               in     boolean  default true
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
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
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end update_us_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_AT_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_AT_person_address
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
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_region                        in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_AT_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'AT_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_region_1                     => p_region
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_AT_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_AU_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_AU_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_state                         in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_AU_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'AU_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_region_1                     => p_state
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_AU_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_DK_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_DK_person_address
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
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_DK_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'DK_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_DK_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_DE_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_DE_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_region                        in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_DE_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'DE_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_region_1                     => p_region
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_DE_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_IT_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_IT_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_region                        in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_IT_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'IT_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_region_1                     => p_region
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_IT_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_MX_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_MX_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_state                         in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_MX_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'MX_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_region_1                     => p_state
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_MX_person_address;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_MX_LOC_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_MX_LOC_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_primary_flag                  in     varchar2 default hr_api.g_varchar2
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_street_name_and_num           in     varchar2 default hr_api.g_varchar2
  ,p_neighborhood                  in     varchar2 default hr_api.g_varchar2
  ,p_municipality                  in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_state                         in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone                     in     varchar2 default hr_api.g_varchar2
  ,p_fax                           in     varchar2 default hr_api.g_varchar2
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
  ,p_party_id                      in     number   default hr_api.g_number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_MX_LOC_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'MX' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_address_id                   => p_address_id
    ,p_object_version_number        => p_object_version_number
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_primary_flag                 => p_primary_flag
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_address_line1                => p_street_name_and_num
    ,p_address_line2                => p_neighborhood
    ,p_town_or_city                 => p_city
    ,p_region_1                     => p_state
    ,p_region_2                     => p_municipality
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone
    ,p_telephone_number_2           => p_fax
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
    ,p_party_id                     => p_party_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_MX_LOC_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_MY_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_MY_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_region                        in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_MY_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'MY_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_region_1                     => p_region
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_MY_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_PT_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PT_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_PT_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'PT_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_PT_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_BE_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_BE_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_BE_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'BE' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_BE_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_FI_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_FI_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_FI_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'FI_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_FI_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_GR_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_GR_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_GR_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'GR_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_GR_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_HK_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_HK_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_district                      in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_HK_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'HK' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_town_or_city                 => p_district
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_HK_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_IE_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_IE_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_county                        in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_IE_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'IE_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_IE_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_LU_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_LU_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_LU_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'LU_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_LU_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_NL_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_NL_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_region                        in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_NL_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'NL_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_region_1                     => p_region
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_NL_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_SG_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_SG_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_SG_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'SG_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_SG_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_SE_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_SE_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_SE_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'SE_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_SE_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ES_GLB_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ES_GLB_person_address
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
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_province                      in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone                     in     varchar2 default hr_api.g_varchar2
  ,p_telephone2                    in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72);
  l_style               per_addresses.style%TYPE;
  --
  cursor csr_add_style is
  select addr.style
    from per_addresses addr
   where addr.address_id = p_address_id;
  --
begin
  --
  l_proc  := g_package||'update_ES_GLB_person_address';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'ES_GLB' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_region_1                     => p_province
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone
    ,p_telephone_number_2           => p_telephone2
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_ES_GLB_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ES_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ES_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_location_type                 in     varchar2 default hr_api.g_varchar2
  ,p_location_name                 in     varchar2 default hr_api.g_varchar2
  ,p_location_number               in     varchar2 default hr_api.g_varchar2
  ,p_building                      in     varchar2 default hr_api.g_varchar2
  ,p_stairs                        in     varchar2 default hr_api.g_varchar2
  ,p_floor                         in     varchar2 default hr_api.g_varchar2
  ,p_door                          in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_province_name                 in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone                     in     varchar2 default hr_api.g_varchar2
  ,p_telephone2                    in     varchar2 default hr_api.g_varchar2
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
  ,p_add_information17             in     varchar2 default hr_api.g_varchar2
  ,p_add_information18             in     varchar2 default hr_api.g_varchar2
  ,p_add_information19             in     varchar2 default hr_api.g_varchar2
  ,p_add_information20             in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) ;
  l_style               per_addresses.style%TYPE;
  --
  cursor csr_add_style is
  select addr.style
    from per_addresses addr
   where addr.address_id = p_address_id;
  --
begin
  --
  l_proc := g_package||'update_ES_person_address';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'ES' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_address_id                   => p_address_id
    ,p_object_version_number        => p_object_version_number
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_address_line1                => p_location_type
    ,p_address_line2                => p_location_name
    ,p_address_line3                => p_location_number
    ,p_add_information13            => p_building
    ,p_add_information14            => p_stairs
    ,p_add_information15            => p_floor
    ,p_add_information16            => p_door
    ,p_town_or_city                 => p_city
    ,p_region_2                     => p_province_name
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone
    ,p_telephone_number_2           => p_telephone2
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
    ,p_add_information17            => p_add_information17
    ,p_add_information18            => p_add_information18
    ,p_add_information19            => p_add_information19
    ,p_add_information20            => p_add_information20
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end update_ES_person_address;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_SA_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_SA_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_street                        in     varchar2 default hr_api.g_varchar2
  ,p_area                          in     varchar2 default hr_api.g_varchar2
  ,p_po_box                        in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
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
  l_proc                varchar2(72) := g_package||'update_SA_person_address';
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
  -- Check that the Address identified is of specified style.
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
    if l_style <> 'SA' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
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
    ,p_town_or_city                 => p_city
    ,p_region_1                     => p_street
    ,p_region_2                     => p_area
    ,p_region_3                     => p_po_box
    ,p_postal_code                  => p_postal_code
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
end update_SA_person_address;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< cre_or_upd_person_address >----------------------|
-- ----------------------------------------------------------------------------
--
procedure cre_or_upd_person_address
  (p_update_mode                   in     varchar2 default hr_api.g_correction
  ,p_validate                      in     boolean  default false
  ,p_address_id                    in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_validate_county               in     boolean  default true
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_primary_flag                  in     varchar2 default hr_api.g_varchar2
  ,p_style                         in     varchar2 default hr_api.g_varchar2
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
  ,p_add_information13             in     varchar2 default hr_api.g_varchar2
  ,p_add_information14             in     varchar2 default hr_api.g_varchar2
  ,p_add_information15             in     varchar2 default hr_api.g_varchar2
  ,p_add_information16             in     varchar2 default hr_api.g_varchar2
  ,p_add_information17             in     varchar2 default hr_api.g_varchar2
  ,p_add_information18             in     varchar2 default hr_api.g_varchar2
  ,p_add_information19             in     varchar2 default hr_api.g_varchar2
  ,p_add_information20             in     varchar2 default hr_api.g_varchar2
  ,p_party_id                      in     number   default NULL -- HR/TCA merge
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'cre_or_upd_person_address';
  l_effective_date       date;
  l_add_rec per_add_shd.g_rec_type;
  l_null_add_rec per_add_shd.g_rec_type;
  l_update_mode varchar2(30);
  l_api_updating boolean;
  --
  lv_address_id                    number := p_address_id ;
  lv_object_version_number         number := p_object_version_number ;
  --
  begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint cre_or_upd_person_address;
  --
  l_update_mode:=p_update_mode;
  l_effective_date:=trunc(p_effective_date);
  l_api_updating := per_add_shd.api_updating
       (p_address_id             => p_address_id
       ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 20);
  --
  -- set the record
  --
  l_add_rec:=
   per_add_shd.convert_args
  (p_address_id
  ,p_business_group_id
  ,p_person_id
  ,trunc(p_date_from)
  ,p_primary_flag
  ,p_style
  ,p_address_line1
  ,p_address_line2
  ,p_address_line3
  ,p_address_type
  ,p_comments
  ,p_country
  ,trunc(p_date_to)
  ,p_postal_code
  ,p_region_1
  ,p_region_2
  ,p_region_3
  ,p_telephone_number_1
  ,p_telephone_number_2
  ,p_telephone_number_3
  ,p_town_or_city
  ,null
  ,null
  ,null
  ,null
  ,p_addr_attribute_category
  ,p_addr_attribute1
  ,p_addr_attribute2
  ,p_addr_attribute3
  ,p_addr_attribute4
  ,p_addr_attribute5
  ,p_addr_attribute6
  ,p_addr_attribute7
  ,p_addr_attribute8
  ,p_addr_attribute9
  ,p_addr_attribute10
  ,p_addr_attribute11
  ,p_addr_attribute12
  ,p_addr_attribute13
  ,p_addr_attribute14
  ,p_addr_attribute15
  ,p_addr_attribute16
  ,p_addr_attribute17
  ,p_addr_attribute18
  ,p_addr_attribute19
  ,p_addr_attribute20
  ,p_add_information13
  ,p_add_information14
  ,p_add_information15
  ,p_add_information16
  ,p_add_information17
  ,p_add_information18
  ,p_add_information19
  ,p_add_information20
  ,p_object_version_number
  ,p_party_id -- HR/TCA merge
  );
  if not l_api_updating then
    --
    -- set g_old_rec to null
    --
    per_add_shd.g_old_rec:=l_null_add_rec;
    hr_utility.set_location(l_proc, 30);
    --
    -- convert the null values
    --
    hr_utility.set_location(l_proc, 40);
    l_add_rec:=per_add_upd.convert_defs(l_add_rec);
    --
    -- insert the data
    --
    hr_utility.set_location(l_proc, 50);
    hr_person_address_api.create_person_address
      (p_validate                     => FALSE
      ,p_effective_date               => l_effective_date
      ,p_validate_county              => p_validate_county
      ,p_pradd_ovlapval_override      => p_pradd_ovlapval_override
      ,p_person_id                    => l_add_rec.person_id
      ,p_primary_flag                 => l_add_rec.primary_flag
      ,p_style                        => l_add_rec.style
      ,p_date_from                    => l_add_rec.date_from
      ,p_date_to                      => l_add_rec.date_to
      ,p_address_type                 => l_add_rec.address_type
      ,p_comments                     => l_add_rec.comments
      ,p_address_line1                => l_add_rec.address_line1
      ,p_address_line2                => l_add_rec.address_line2
      ,p_address_line3                => l_add_rec.address_line3
      ,p_town_or_city                 => l_add_rec.town_or_city
      ,p_region_1                     => l_add_rec.region_1
      ,p_region_2                     => l_add_rec.region_2
      ,p_region_3                     => l_add_rec.region_3
      ,p_postal_code                  => l_add_rec.postal_code
      ,p_country                      => l_add_rec.country
      ,p_telephone_number_1           => l_add_rec.telephone_number_1
      ,p_telephone_number_2           => l_add_rec.telephone_number_2
      ,p_telephone_number_3           => l_add_rec.telephone_number_3
      ,p_addr_attribute_category      => l_add_rec.addr_attribute_category
      ,p_addr_attribute1              => l_add_rec.addr_attribute1
      ,p_addr_attribute2              => l_add_rec.addr_attribute2
      ,p_addr_attribute3              => l_add_rec.addr_attribute3
      ,p_addr_attribute4              => l_add_rec.addr_attribute4
      ,p_addr_attribute5              => l_add_rec.addr_attribute5
      ,p_addr_attribute6              => l_add_rec.addr_attribute6
      ,p_addr_attribute7              => l_add_rec.addr_attribute7
      ,p_addr_attribute8              => l_add_rec.addr_attribute8
      ,p_addr_attribute9              => l_add_rec.addr_attribute9
      ,p_addr_attribute10             => l_add_rec.addr_attribute10
      ,p_addr_attribute11             => l_add_rec.addr_attribute11
      ,p_addr_attribute12             => l_add_rec.addr_attribute12
      ,p_addr_attribute13             => l_add_rec.addr_attribute13
      ,p_addr_attribute14             => l_add_rec.addr_attribute14
      ,p_addr_attribute15             => l_add_rec.addr_attribute15
      ,p_addr_attribute16             => l_add_rec.addr_attribute16
      ,p_addr_attribute17             => l_add_rec.addr_attribute17
      ,p_addr_attribute18             => l_add_rec.addr_attribute18
      ,p_addr_attribute19             => l_add_rec.addr_attribute19
      ,p_addr_attribute20             => l_add_rec.addr_attribute20
      ,p_add_information13            => l_add_rec.add_information13
      ,p_add_information14            => l_add_rec.add_information14
      ,p_add_information15            => l_add_rec.add_information15
      ,p_add_information16            => l_add_rec.add_information16
      ,p_add_information17            => l_add_rec.add_information17
      ,p_add_information18            => l_add_rec.add_information18
      ,p_add_information19            => l_add_rec.add_information19
      ,p_add_information20            => l_add_rec.add_information20
      ,p_address_id                   => l_add_rec.address_id
      ,p_object_version_number        => l_add_rec.object_version_number
      ,p_party_id                     => l_add_rec.party_id -- HR/TCA merge
      );
    hr_utility.set_location(l_proc, 60);
  else
    hr_utility.set_location(l_proc, 70);
    --
    -- updating not inserting
    --
    -- Validating update_mode values
    if (l_update_mode not in (hr_api.g_update,hr_api.g_correction)) then
      hr_utility.set_location(l_proc, 80);
      hr_utility.set_message(800, 'HR_52862_ADD_CHK_MODE');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 90);
    --
    -- Validating effective_date
    --
    if ((p_date_to <> hr_api.g_date) AND ( l_effective_date > p_date_to ))
    or ((p_date_from <> hr_api.g_date) AND ( l_effective_date < p_date_from ))
    then
      hr_utility.set_location(l_proc, 100);
      hr_utility.set_message(800, 'HR_52863_ADD_INVALID_EFF_DATE');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 110);
    --
    per_add_shd.lck
      (p_address_id                => p_address_id
      ,p_object_version_number     => p_object_version_number);
    --
    -- convert the null values
    --
    hr_utility.set_location(l_proc, 130);
    l_add_rec:=per_add_upd.convert_defs(l_add_rec);
    --
    -- check to see if the start date hasn't changed and is equal to the
    -- effective date. This will always be a correction.
    --
    if per_add_shd.g_old_rec.date_from = l_add_rec.date_from
       and  l_add_rec.date_from = l_effective_date then
      l_update_mode:= hr_api.g_correction;
    end if;
    --
    -- check for the modes mode
    --
    if l_update_mode = hr_api.g_correction then
      --
      -- correct the data
      --
      hr_utility.set_location(l_proc, 140);
      --
      -- Bug 2863410 starts here.
      -- If the style is changed then used update_pers_addr_with_style.
      --
      IF per_add_shd.g_old_rec.style <> l_add_rec.style THEN
       --
       hr_utility.set_location(l_proc, 142);
       --
      hr_person_address_api.update_pers_addr_with_style
      (p_validate                     => FALSE
      ,p_effective_date               => l_effective_date
      ,p_validate_county              => p_validate_county
      ,p_address_id                   => l_add_rec.address_id
      ,p_object_version_number        => l_add_rec.object_version_number
      ,p_date_from                    => l_add_rec.date_from
      ,p_date_to                      => l_add_rec.date_to
      ,p_address_type                 => l_add_rec.address_type
      ,p_comments                     => l_add_rec.comments
      ,p_address_line1                => l_add_rec.address_line1
      ,p_address_line2                => l_add_rec.address_line2
      ,p_address_line3                => l_add_rec.address_line3
      ,p_town_or_city                 => l_add_rec.town_or_city
      ,p_region_1                     => l_add_rec.region_1
      ,p_region_2                     => l_add_rec.region_2
      ,p_region_3                     => l_add_rec.region_3
      ,p_postal_code                  => l_add_rec.postal_code
      ,p_country                      => l_add_rec.country
      ,p_telephone_number_1           => l_add_rec.telephone_number_1
      ,p_telephone_number_2           => l_add_rec.telephone_number_2
      ,p_telephone_number_3           => l_add_rec.telephone_number_3
      ,p_addr_attribute_category      => l_add_rec.addr_attribute_category
      ,p_addr_attribute1              => l_add_rec.addr_attribute1
      ,p_addr_attribute2              => l_add_rec.addr_attribute2
      ,p_addr_attribute3              => l_add_rec.addr_attribute3
      ,p_addr_attribute4              => l_add_rec.addr_attribute4
      ,p_addr_attribute5              => l_add_rec.addr_attribute5
      ,p_addr_attribute6              => l_add_rec.addr_attribute6
      ,p_addr_attribute7              => l_add_rec.addr_attribute7
      ,p_addr_attribute8              => l_add_rec.addr_attribute8
      ,p_addr_attribute9              => l_add_rec.addr_attribute9
      ,p_addr_attribute10             => l_add_rec.addr_attribute10
      ,p_addr_attribute11             => l_add_rec.addr_attribute11
      ,p_addr_attribute12             => l_add_rec.addr_attribute12
      ,p_addr_attribute13             => l_add_rec.addr_attribute13
      ,p_addr_attribute14             => l_add_rec.addr_attribute14
      ,p_addr_attribute15             => l_add_rec.addr_attribute15
      ,p_addr_attribute16             => l_add_rec.addr_attribute16
      ,p_addr_attribute17             => l_add_rec.addr_attribute17
      ,p_addr_attribute18             => l_add_rec.addr_attribute18
      ,p_addr_attribute19             => l_add_rec.addr_attribute19
      ,p_addr_attribute20             => l_add_rec.addr_attribute20
      ,p_add_information13            => l_add_rec.add_information13
      ,p_add_information14            => l_add_rec.add_information14
      ,p_add_information15            => l_add_rec.add_information15
      ,p_add_information16            => l_add_rec.add_information16
      ,p_add_information17            => l_add_rec.add_information17
      ,p_add_information18            => l_add_rec.add_information18
      ,p_add_information19            => l_add_rec.add_information19
      ,p_add_information20            => l_add_rec.add_information20
      ,p_style                        => l_add_rec.style
      );
      --
       hr_utility.set_location(l_proc, 144);
      --
     ELSE
      --
      -- Address style is not changed.
      --
      hr_utility.set_location(l_proc, 146);
      --
      hr_person_address_api.update_person_address
      (p_validate                     => FALSE
      ,p_effective_date               => l_effective_date
      ,p_validate_county              => p_validate_county
      ,p_address_id                   => l_add_rec.address_id
      ,p_object_version_number        => l_add_rec.object_version_number
      ,p_date_from                    => l_add_rec.date_from
      ,p_date_to                      => l_add_rec.date_to
      ,p_address_type                 => l_add_rec.address_type
      ,p_comments                     => l_add_rec.comments
      ,p_address_line1                => l_add_rec.address_line1
      ,p_address_line2                => l_add_rec.address_line2
      ,p_address_line3                => l_add_rec.address_line3
      ,p_town_or_city                 => l_add_rec.town_or_city
      ,p_region_1                     => l_add_rec.region_1
      ,p_region_2                     => l_add_rec.region_2
      ,p_region_3                     => l_add_rec.region_3
      ,p_postal_code                  => l_add_rec.postal_code
      ,p_country                      => l_add_rec.country
      ,p_telephone_number_1           => l_add_rec.telephone_number_1
      ,p_telephone_number_2           => l_add_rec.telephone_number_2
      ,p_telephone_number_3           => l_add_rec.telephone_number_3
      ,p_addr_attribute_category      => l_add_rec.addr_attribute_category
      ,p_addr_attribute1              => l_add_rec.addr_attribute1
      ,p_addr_attribute2              => l_add_rec.addr_attribute2
      ,p_addr_attribute3              => l_add_rec.addr_attribute3
      ,p_addr_attribute4              => l_add_rec.addr_attribute4
      ,p_addr_attribute5              => l_add_rec.addr_attribute5
      ,p_addr_attribute6              => l_add_rec.addr_attribute6
      ,p_addr_attribute7              => l_add_rec.addr_attribute7
      ,p_addr_attribute8              => l_add_rec.addr_attribute8
      ,p_addr_attribute9              => l_add_rec.addr_attribute9
      ,p_addr_attribute10             => l_add_rec.addr_attribute10
      ,p_addr_attribute11             => l_add_rec.addr_attribute11
      ,p_addr_attribute12             => l_add_rec.addr_attribute12
      ,p_addr_attribute13             => l_add_rec.addr_attribute13
      ,p_addr_attribute14             => l_add_rec.addr_attribute14
      ,p_addr_attribute15             => l_add_rec.addr_attribute15
      ,p_addr_attribute16             => l_add_rec.addr_attribute16
      ,p_addr_attribute17             => l_add_rec.addr_attribute17
      ,p_addr_attribute18             => l_add_rec.addr_attribute18
      ,p_addr_attribute19             => l_add_rec.addr_attribute19
      ,p_addr_attribute20             => l_add_rec.addr_attribute20
      ,p_add_information13            => l_add_rec.add_information13
      ,p_add_information14            => l_add_rec.add_information14
      ,p_add_information15            => l_add_rec.add_information15
      ,p_add_information16            => l_add_rec.add_information16
      ,p_add_information17            => l_add_rec.add_information17
      ,p_add_information18            => l_add_rec.add_information18
      ,p_add_information19            => l_add_rec.add_information19
      ,p_add_information20            => l_add_rec.add_information20
      );
      --
      hr_utility.set_location(l_proc, 148);
      --
     END IF;
      --
      -- Bug 2863410 ends here.
      --
      hr_utility.set_location(l_proc, 150);
      --
    else
      --
      -- update mode
      --
      hr_utility.set_location(l_proc, 160);
      --
      -- if the start date has changed and it is not the effective date then
      -- we have an error. A change of start date is the new start date for
      -- the new record, so must be the effective date so that the address
      -- is continuous.
      --
      if per_add_shd.g_old_rec.date_from <> l_add_rec.date_from
         and l_add_rec.date_from <> l_effective_date then
        hr_utility.set_location(l_proc, 170);
        hr_utility.set_message(800, 'HR_52863_ADD_INVALID_EFF_DATE');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 180);
      --
      -- end the old address
--2660711, remove this call, change the create call to pass TRUE for
--p_pradd_ovlapval_override which will achieve the same thing
--      hr_person_address_api.update_person_address
--      (p_validate                     => FALSE
--      ,p_effective_date               => l_effective_date
--      ,p_validate_county              => p_validate_county
--      ,p_address_id                   => l_add_rec.address_id
--      ,p_object_version_number        => l_add_rec.object_version_number
--      ,p_date_to                      => l_effective_date-1
--      );
      --

      -- changes started for bug5372061
      if per_add_shd.g_old_rec.primary_flag <> 'Y' and p_primary_flag <> 'Y' then
            hr_person_address_api.update_person_address
            (p_validate                     => FALSE
            ,p_effective_date               => l_effective_date
            ,p_validate_county              => p_validate_county
            ,p_address_id                   => l_add_rec.address_id
            ,p_object_version_number        => l_add_rec.object_version_number
            ,p_date_to                      => l_effective_date-1
            );
            --

      end if;
-- changes ended for bug5372061

      --
      hr_utility.set_location(l_proc, 190);
      --
      -- insert the new address
      --
      hr_person_address_api.create_person_address
      (p_validate                     => FALSE
      ,p_effective_date               => l_effective_date
      ,p_validate_county              => p_validate_county
      ,p_pradd_ovlapval_override      => TRUE  --p_pradd_ovlapval_override   changed for 2660711
      ,p_person_id                    => l_add_rec.person_id
      ,p_primary_flag                 => l_add_rec.primary_flag
      ,p_style                        => l_add_rec.style
      ,p_date_from                    => l_effective_date
      ,p_date_to                      => l_add_rec.date_to
      ,p_address_type                 => l_add_rec.address_type
      ,p_comments                     => l_add_rec.comments
      ,p_address_line1                => l_add_rec.address_line1
      ,p_address_line2                => l_add_rec.address_line2
      ,p_address_line3                => l_add_rec.address_line3
      ,p_town_or_city                 => l_add_rec.town_or_city
      ,p_region_1                     => l_add_rec.region_1
      ,p_region_2                     => l_add_rec.region_2
      ,p_region_3                     => l_add_rec.region_3
      ,p_postal_code                  => l_add_rec.postal_code
      ,p_country                      => l_add_rec.country
      ,p_telephone_number_1           => l_add_rec.telephone_number_1
      ,p_telephone_number_2           => l_add_rec.telephone_number_2
      ,p_telephone_number_3           => l_add_rec.telephone_number_3
      ,p_addr_attribute_category      => l_add_rec.addr_attribute_category
      ,p_addr_attribute1              => l_add_rec.addr_attribute1
      ,p_addr_attribute2              => l_add_rec.addr_attribute2
      ,p_addr_attribute3              => l_add_rec.addr_attribute3
      ,p_addr_attribute4              => l_add_rec.addr_attribute4
      ,p_addr_attribute5              => l_add_rec.addr_attribute5
      ,p_addr_attribute6              => l_add_rec.addr_attribute6
      ,p_addr_attribute7              => l_add_rec.addr_attribute7
      ,p_addr_attribute8              => l_add_rec.addr_attribute8
      ,p_addr_attribute9              => l_add_rec.addr_attribute9
      ,p_addr_attribute10             => l_add_rec.addr_attribute10
      ,p_addr_attribute11             => l_add_rec.addr_attribute11
      ,p_addr_attribute12             => l_add_rec.addr_attribute12
      ,p_addr_attribute13             => l_add_rec.addr_attribute13
      ,p_addr_attribute14             => l_add_rec.addr_attribute14
      ,p_addr_attribute15             => l_add_rec.addr_attribute15
      ,p_addr_attribute16             => l_add_rec.addr_attribute16
      ,p_addr_attribute17             => l_add_rec.addr_attribute17
      ,p_addr_attribute18             => l_add_rec.addr_attribute18
      ,p_addr_attribute19             => l_add_rec.addr_attribute19
      ,p_addr_attribute20             => l_add_rec.addr_attribute20
      ,p_add_information13            => l_add_rec.add_information13
      ,p_add_information14            => l_add_rec.add_information14
      ,p_add_information15            => l_add_rec.add_information15
      ,p_add_information16            => l_add_rec.add_information16
      ,p_add_information17            => l_add_rec.add_information17
      ,p_add_information18            => l_add_rec.add_information18
      ,p_add_information19            => l_add_rec.add_information19
      ,p_add_information20            => l_add_rec.add_information20
      ,p_address_id                   => l_add_rec.address_id
      ,p_object_version_number        => l_add_rec.object_version_number
      ,p_party_id                     => l_add_rec.party_id -- HR/TCA merge
      );
      --
      hr_utility.set_location(l_proc, 190);
      --
    end if;
  end if;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_address_id:=l_add_rec.address_id;
  p_object_version_number:=l_add_rec.object_version_number;
  hr_utility.set_location('Leaving:'||l_proc, 200);
  --
exception
  when hr_api.validate_enabled then
    rollback to cre_or_upd_person_address;
    p_address_id:=null;
    p_object_version_number:=null;
    hr_utility.set_location('Leaving:'||l_proc, 220);
  when others then
    p_address_id                    := lv_address_id ;
    p_object_version_number         := lv_object_version_number ;
    rollback to cre_or_upd_person_address;
    hr_utility.set_location('Leaving:'||l_proc, 230);
    raise;
  --
end cre_or_upd_person_address;
--
end hr_person_address_api;

/
