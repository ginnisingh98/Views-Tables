--------------------------------------------------------
--  DDL for Package Body HR_LOCATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOCATION_API" AS
/* $Header: hrlocapi.pkb 120.1.12010000.3 2010/01/19 13:26:57 pchowdav ship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := '  hr_location_api.';
--
--------------------------------------------------------------------------------
g_dummy  number(1);  -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_location >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_location
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_code                  IN  VARCHAR2
     ,p_description                    IN  VARCHAR2  DEFAULT NULL
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT NULL
     ,p_tp_header_id                   IN  NUMBER    DEFAULT NULL
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT NULL
     ,p_bill_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_country                        IN  VARCHAR2  DEFAULT NULL
     ,p_designated_receiver_id         IN  NUMBER    DEFAULT NULL
     ,p_in_organization_flag           IN  VARCHAR2  DEFAULT 'Y'
     ,p_inactive_date                  IN  DATE      DEFAULT NULL
     ,p_operating_unit_id              IN  NUMBER    DEFAULT NULL
     ,p_inventory_organization_id      IN  NUMBER    DEFAULT NULL
     ,p_office_site_flag               IN  VARCHAR2  DEFAULT 'Y'
     ,p_postal_code                    IN  VARCHAR2  DEFAULT NULL
     ,p_receiving_site_flag            IN  VARCHAR2  DEFAULT 'Y'
     ,p_region_1                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_2                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_3                       IN  VARCHAR2  DEFAULT NULL
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT NULL
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_style                          IN  VARCHAR2  DEFAULT NULL
     ,p_tax_name                       IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT NULL
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information13              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information14              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information15              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information16              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information17              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information18              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information19              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information20              IN  VARCHAR2  DEFAULT NULL
     ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
     ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute_category      IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute1              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute2              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute3              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute4              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute5              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute6              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute7              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute8              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute9              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute10             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute11             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute12             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute13             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute14             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute15             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute16             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute17             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute18             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute19             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute20             IN  VARCHAR2  DEFAULT NULL
     ,p_business_group_id              IN  NUMBER    DEFAULT NULL
     ,p_location_id                    OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER

  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_location';
  l_location_id           hr_locations_all.location_id%TYPE;
  l_object_version_number hr_locations_all.object_version_number%TYPE;
  l_language_code         hr_locations_all_tl.language%TYPE;
  l_inactive_date         DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_location;
  --
  hr_utility.set_location(l_proc, 15);
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_inactive_date := trunc (p_inactive_date);
  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
    BEGIN
    --
    -- Start of API User Hook for the before hook of create_location
    --
    hr_location_bk1.create_location_b
     (
     p_effective_date                => p_effective_date
    ,p_language_code                 => l_language_code
    ,p_location_code                 => p_location_code
    ,p_description                   => p_description
    ,p_timezone_code                 => p_timezone_code
    ,p_tp_header_id                  => p_tp_header_id
    ,p_ece_tp_location_code          => p_ece_tp_location_code
    ,p_address_line_1                => p_address_line_1
    ,p_address_line_2                => p_address_line_2
    ,p_address_line_3                => p_address_line_3
    ,p_bill_to_site_flag             => p_bill_to_site_flag
    ,p_country                       => p_country
    ,p_designated_receiver_id        => p_designated_receiver_id
    ,p_in_organization_flag          => p_in_organization_flag
    ,p_inactive_date                 => l_inactive_date
    ,p_operating_unit_id             => p_operating_unit_id
    ,p_inventory_organization_id     => p_inventory_organization_id
    ,p_office_site_flag              => p_office_site_flag
    ,p_postal_code                   => p_postal_code
    ,p_receiving_site_flag           => p_receiving_site_flag
    ,p_region_1                      => p_region_1
    ,p_region_2                      => p_region_2
    ,p_region_3                      => p_region_3
    ,p_ship_to_location_id           => p_ship_to_location_id
    ,p_ship_to_site_flag             => p_ship_to_site_flag
    ,p_style                         => p_style
    ,p_tax_name                      => p_tax_name
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_town_or_city                  => p_town_or_city
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
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
    ,p_global_attribute_category     => p_global_attribute_category
    ,p_global_attribute1             => p_global_attribute1
    ,p_global_attribute2             => p_global_attribute2
    ,p_global_attribute3             => p_global_attribute3
    ,p_global_attribute4             => p_global_attribute4
    ,p_global_attribute5             => p_global_attribute5
    ,p_global_attribute6             => p_global_attribute6
    ,p_global_attribute7             => p_global_attribute7
    ,p_global_attribute8             => p_global_attribute8
    ,p_global_attribute9             => p_global_attribute9
    ,p_global_attribute10            => p_global_attribute10
    ,p_global_attribute11            => p_global_attribute11
    ,p_global_attribute12            => p_global_attribute12
    ,p_global_attribute13            => p_global_attribute13
    ,p_global_attribute14            => p_global_attribute14
    ,p_global_attribute15            => p_global_attribute15
    ,p_global_attribute16            => p_global_attribute16
    ,p_global_attribute17            => p_global_attribute17
    ,p_global_attribute18            => p_global_attribute18
    ,p_global_attribute19            => p_global_attribute19
    ,p_global_attribute20            => p_global_attribute20
    ,p_business_group_id             => p_business_group_id
     );
     EXCEPTION
       WHEN hr_api.cannot_find_prog_unit THEN
         hr_api.cannot_find_prog_unit_error
           (  p_module_name => 'CREATE_LOCATION'
             ,p_hook_type   => 'BP'
           );
    --
    -- End of API User Hook for the before hook of create_location
    --
  END;
  -- Process Logic
  --
  -- Insert non-translatable rows into HR_LOCATIONS_ALL first

  hr_utility.set_location(l_proc, 25);

  hr_location_internal.create_generic_location
  (   p_effective_date                => p_effective_date
     ,p_location_id                   => l_location_id
     ,p_object_version_number         => l_object_version_number
     ,p_location_code                 => p_location_code
     ,p_timezone_code                 => p_timezone_code
     ,p_address_line_1                => p_address_line_1
     ,p_address_line_2                => p_address_line_2
     ,p_address_line_3                => p_address_line_3
     ,p_bill_to_site_flag             => p_bill_to_site_flag
     ,p_country                       => p_country
     ,p_description                   => p_description
     ,p_designated_receiver_id        => p_designated_receiver_id
     ,p_in_organization_flag          => p_in_organization_flag
     ,p_inactive_date                 => l_inactive_date
     ,p_operating_unit_id             => p_operating_unit_id
     ,p_inventory_organization_id     => p_inventory_organization_id
     ,p_office_site_flag              => p_office_site_flag
     ,p_postal_code                   => p_postal_code
     ,p_receiving_site_flag           => p_receiving_site_flag
     ,p_region_1                      => p_region_1
     ,p_region_2                      => p_region_2
     ,p_region_3                      => p_region_3
     ,p_ship_to_location_id           => p_ship_to_location_id
     ,p_ship_to_site_flag             => p_ship_to_site_flag
     ,p_style                         => p_style
     -- Bug 4195237 : 'p_tax_name' parameter is disabled.
     -- Passing 'null' to hr_location_internal
     ,p_tax_name                      => null
     ,p_telephone_number_1            => p_telephone_number_1
     ,p_telephone_number_2            => p_telephone_number_2
     ,p_telephone_number_3            => p_telephone_number_3
     ,p_town_or_city                  => p_town_or_city
     ,p_loc_information13             => p_loc_information13
     ,p_loc_information14             => p_loc_information14
     ,p_loc_information15             => p_loc_information15
     ,p_loc_information16             => p_loc_information16
     ,p_loc_information17             => p_loc_information17
     ,p_loc_information18             => p_loc_information18
     ,p_loc_information19             => p_loc_information19
     ,p_loc_information20             => p_loc_information20
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
     ,p_global_attribute_category     => p_global_attribute_category
     ,p_global_attribute1             => p_global_attribute1
     ,p_global_attribute2             => p_global_attribute2
     ,p_global_attribute3             => p_global_attribute3
     ,p_global_attribute4             => p_global_attribute4
     ,p_global_attribute5             => p_global_attribute5
     ,p_global_attribute6             => p_global_attribute6
     ,p_global_attribute7             => p_global_attribute7
     ,p_global_attribute8             => p_global_attribute8
     ,p_global_attribute9             => p_global_attribute9
     ,p_global_attribute10            => p_global_attribute10
     ,p_global_attribute11            => p_global_attribute11
     ,p_global_attribute12            => p_global_attribute12
     ,p_global_attribute13            => p_global_attribute13
     ,p_global_attribute14            => p_global_attribute14
     ,p_global_attribute15            => p_global_attribute15
     ,p_global_attribute16            => p_global_attribute16
     ,p_global_attribute17            => p_global_attribute17
     ,p_global_attribute18            => p_global_attribute18
     ,p_global_attribute19            => p_global_attribute19
     ,p_global_attribute20            => p_global_attribute20
     ,p_legal_address_flag            => 'N'
     ,p_tp_header_id                  => p_tp_header_id
     ,p_ece_tp_location_code          => p_ece_tp_location_code
     ,p_business_group_id             => p_business_group_id
   );

  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_location
    --
    hr_location_bk1.create_location_a
     (
     p_effective_date                => p_effective_date
    ,p_language_code                 => l_language_code
    ,p_location_code                 => p_location_code
    ,p_description                   => p_description
    ,p_timezone_code                 => p_timezone_code
    ,p_tp_header_id                  => p_tp_header_id
    ,p_ece_tp_location_code          => p_ece_tp_location_code
    ,p_address_line_1                => p_address_line_1
    ,p_address_line_2                => p_address_line_2
    ,p_address_line_3                => p_address_line_3
    ,p_bill_to_site_flag             => p_bill_to_site_flag
    ,p_country                       => p_country
    ,p_designated_receiver_id        => p_designated_receiver_id
    ,p_in_organization_flag          => p_in_organization_flag
    ,p_inactive_date                 => l_inactive_date
    ,p_operating_unit_id             => p_operating_unit_id
    ,p_inventory_organization_id     => p_inventory_organization_id
    ,p_office_site_flag              => p_office_site_flag
    ,p_postal_code                   => p_postal_code
    ,p_receiving_site_flag           => p_receiving_site_flag
    ,p_region_1                      => p_region_1
    ,p_region_2                      => p_region_2
    ,p_region_3                      => p_region_3
    ,p_ship_to_location_id           => p_ship_to_location_id
    ,p_ship_to_site_flag             => p_ship_to_site_flag
    ,p_style                         => p_style
    ,p_tax_name                      => p_tax_name
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_town_or_city                  => p_town_or_city
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
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
    ,p_global_attribute_category     => p_global_attribute_category
    ,p_global_attribute1             => p_global_attribute1
    ,p_global_attribute2             => p_global_attribute2
    ,p_global_attribute3             => p_global_attribute3
    ,p_global_attribute4             => p_global_attribute4
    ,p_global_attribute5             => p_global_attribute5
    ,p_global_attribute6             => p_global_attribute6
    ,p_global_attribute7             => p_global_attribute7
    ,p_global_attribute8             => p_global_attribute8
    ,p_global_attribute9             => p_global_attribute9
    ,p_global_attribute10            => p_global_attribute10
    ,p_global_attribute11            => p_global_attribute11
    ,p_global_attribute12            => p_global_attribute12
    ,p_global_attribute13            => p_global_attribute13
    ,p_global_attribute14            => p_global_attribute14
    ,p_global_attribute15            => p_global_attribute15
    ,p_global_attribute16            => p_global_attribute16
    ,p_global_attribute17            => p_global_attribute17
    ,p_global_attribute18            => p_global_attribute18
    ,p_global_attribute19            => p_global_attribute19
    ,p_global_attribute20            => p_global_attribute20
    ,p_business_group_id             => p_business_group_id
    ,p_location_id                   => l_location_id
    ,p_object_version_number         => l_object_version_number
    );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LOCATION'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_location
    --
  END;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
    IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
   -- Set all output arguments
  --
  p_location_id := l_location_id;
  p_object_version_number := l_object_version_number;
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_location;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_location_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_location;
    -- Set OUT parameters.
    p_location_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_location;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_location >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_location
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_id                    IN  NUMBER
     ,p_location_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_description                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_tp_header_id                   IN  NUMBER    DEFAULT hr_api.g_number
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_bill_to_site_flag              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_country                        IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_designated_receiver_id         IN  NUMBER    DEFAULT hr_api.g_number
     ,p_in_organization_flag           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_inactive_date                  IN  DATE      DEFAULT hr_api.g_date
     ,p_operating_unit_id              IN  NUMBER    DEFAULT NULL
     ,p_inventory_organization_id      IN  NUMBER    DEFAULT hr_api.g_number
     ,p_office_site_flag               IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_postal_code                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_receiving_site_flag            IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT hr_api.g_number
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_style                          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_tax_name                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information13              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information14              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information15              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information16              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information17              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information18              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information19              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information20              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute_category      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute1              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute2              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute3              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute4              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute5              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute6              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute7              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute8              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute9              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute10             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute11             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute12             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute13             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute14             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute15             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute16             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute17             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute18             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute19             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute20             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_location';
  l_object_version_number hr_locations.object_version_number%TYPE;
  l_language_code         hr_locations_all_tl.language%TYPE;
  l_inactive_date         DATE;

  l_temp_ovn   number := p_object_version_number;
  --
  l_address_line_1        VARCHAR2(240);
  l_address_line_2        VARCHAR2(240);
  l_address_line_3        VARCHAR2(240);
  l_country               VARCHAR2(60);
  l_postal_code           VARCHAR2(30);
  l_region_1              VARCHAR2(120);
  l_region_2              VARCHAR2(120);
  l_region_3              VARCHAR2(120);
  l_style                 VARCHAR2(30);
  l_town_or_city          VARCHAR2(30);

BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_location;
  --
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_inactive_date := trunc (p_inactive_date);
  --
  -- Validate the language parameter.
  -- l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to be
  -- passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  hr_utility.set_location(l_proc, 20);

  if hr_general2.is_location_legal_adr(p_location_id => p_location_id) then
  --
-- fix for bug 9223716,the address fields are enabled for update.
    --
    -- Check that the non updateable parameter for legal address has
    -- not been passed in.
    --
    -- p_address_line_1
    -- p_address_line_2
    -- p_address_line_3
    -- p_country
    -- p_inactive_date
    -- p_postal_code
    -- p_region_1
    -- p_region_2
    -- p_region_3
    -- p_style
    -- p_town_or_city

    -- fix 3219077 start
       select address_line_1
             ,address_line_2
             ,address_line_3
             ,country
             ,inactive_date
             ,postal_code
             ,region_1
             ,region_2
             ,region_3
             ,style
             ,town_or_city
       into   l_address_line_1
             ,l_address_line_2
             ,l_address_line_3
             ,l_country
             ,l_inactive_date
             ,l_postal_code
             ,l_region_1
             ,l_region_2
             ,l_region_3
             ,l_style
             ,l_town_or_city
       from   hr_locations_all loc
     where  loc.location_id = p_location_id;
  -- fix 3219077 end

       hr_utility.set_location(l_proc, 25);

    if (

      /* nvl(p_address_line_1,hr_api.g_varchar2) <>
                    nvl(l_address_line_1,hr_api.g_varchar2)  OR
       nvl(p_address_line_2,hr_api.g_varchar2) <>
                    nvl(l_address_line_2,hr_api.g_varchar2) OR
       nvl(p_address_line_3,hr_api.g_varchar2) <>
                    nvl(l_address_line_3,hr_api.g_varchar2) OR
       nvl(p_country,hr_api.g_varchar2)        <>
                    nvl(l_country,hr_api.g_varchar2) OR */
       nvl(p_inactive_date,hr_api.g_date)  <>
                    nvl(l_inactive_date,hr_api.g_date)
      /* OR
       nvl(p_postal_code,hr_api.g_varchar2)    <>
                    nvl(l_postal_code,hr_api.g_varchar2) OR
       nvl(p_region_1,hr_api.g_varchar2)       <>
                    nvl(l_region_1,hr_api.g_varchar2) OR
       nvl(p_region_2,hr_api.g_varchar2)       <>
                    nvl(l_region_2,hr_api.g_varchar2) OR
       nvl(p_region_3,hr_api.g_varchar2)       <>
                    nvl(l_region_3,hr_api.g_varchar2) OR
       nvl(p_style,hr_api.g_varchar2)          <>
                    nvl(l_style,hr_api.g_varchar2) OR
       nvl(p_town_or_city,hr_api.g_varchar2)   <>
                    nvl(l_town_or_city,hr_api.g_varchar2) */
       )    then

       hr_utility.set_location(l_proc, 26);

       hr_utility.set_message(800, 'HR_50049_NON_UPDATEABLE_VALUES');
       hr_utility.raise_error;

    end if;

  end if;

  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
    BEGIN
    --
    -- Start of API User Hook for the before hook of update_location
    --
    hr_location_bk2.update_location_b
      (
     p_effective_date                => p_effective_date
    ,p_language_code                 => l_language_code
    ,p_location_id                   => p_location_id
    ,p_location_code                 => p_location_code
    ,p_description                   => p_description
    ,p_timezone_code                 => p_timezone_code
    ,p_tp_header_id                  => p_tp_header_id
    ,p_ece_tp_location_code          => p_ece_tp_location_code
    ,p_address_line_1                => p_address_line_1
    ,p_address_line_2                => p_address_line_2
    ,p_address_line_3                => p_address_line_3
    ,p_bill_to_site_flag             => p_bill_to_site_flag
    ,p_country                       => p_country
    ,p_designated_receiver_id        => p_designated_receiver_id
    ,p_in_organization_flag          => p_in_organization_flag
    ,p_inactive_date                 => l_inactive_date
    ,p_operating_unit_id             => p_operating_unit_id
    ,p_inventory_organization_id     => p_inventory_organization_id
    ,p_office_site_flag              => p_office_site_flag
    ,p_postal_code                   => p_postal_code
    ,p_receiving_site_flag           => p_receiving_site_flag
    ,p_region_1                      => p_region_1
    ,p_region_2                      => p_region_2
    ,p_region_3                      => p_region_3
    ,p_ship_to_location_id           => p_ship_to_location_id
    ,p_ship_to_site_flag             => p_ship_to_site_flag
    ,p_style                         => p_style
    ,p_tax_name                      => p_tax_name
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_town_or_city                  => p_town_or_city
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
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
    ,p_global_attribute_category     => p_global_attribute_category
    ,p_global_attribute1             => p_global_attribute1
    ,p_global_attribute2             => p_global_attribute2
    ,p_global_attribute3             => p_global_attribute3
    ,p_global_attribute4             => p_global_attribute4
    ,p_global_attribute5             => p_global_attribute5
    ,p_global_attribute6             => p_global_attribute6
    ,p_global_attribute7             => p_global_attribute7
    ,p_global_attribute8             => p_global_attribute8
    ,p_global_attribute9             => p_global_attribute9
    ,p_global_attribute10            => p_global_attribute10
    ,p_global_attribute11            => p_global_attribute11
    ,p_global_attribute12            => p_global_attribute12
    ,p_global_attribute13            => p_global_attribute13
    ,p_global_attribute14            => p_global_attribute14
    ,p_global_attribute15            => p_global_attribute15
    ,p_global_attribute16            => p_global_attribute16
    ,p_global_attribute17            => p_global_attribute17
    ,p_global_attribute18            => p_global_attribute18
    ,p_global_attribute19            => p_global_attribute19
    ,p_global_attribute20            => p_global_attribute20
    ,p_object_version_number         => l_object_version_number
     );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LOCATION'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_location
    --
  END;
  --
  -- Insert non-translatable rows in HR_LOCATIONS_ALL Table
  --
  hr_location_internal.update_generic_location
    ( p_effective_date                => p_effective_date
     ,p_language_code                 => l_language_code  -- Added for bug 3368450.
     ,p_location_id                   => p_location_id
     ,p_timezone_code                 => p_timezone_code
     ,p_object_version_number         => l_object_version_number
     ,p_tp_header_id                  => p_tp_header_id
     ,p_ece_tp_location_code          => p_ece_tp_location_code
     ,p_location_code                 => p_location_code
     ,p_address_line_1                => p_address_line_1
     ,p_address_line_2                => p_address_line_2
     ,p_address_line_3                => p_address_line_3
     ,p_bill_to_site_flag             => p_bill_to_site_flag
     ,p_country                       => p_country
     ,p_description                   => p_description
     ,p_designated_receiver_id        => p_designated_receiver_id
     ,p_in_organization_flag          => p_in_organization_flag
     ,p_inactive_date                 => l_inactive_date
     ,p_operating_unit_id             => p_operating_unit_id
     ,p_inventory_organization_id     => p_inventory_organization_id
     ,p_office_site_flag              => p_office_site_flag
     ,p_postal_code                   => p_postal_code
     ,p_receiving_site_flag           => p_receiving_site_flag
     ,p_region_1                      => p_region_1
     ,p_region_2                      => p_region_2
     ,p_region_3                      => p_region_3
     ,p_ship_to_location_id           => p_ship_to_location_id
     ,p_ship_to_site_flag             => p_ship_to_site_flag
     ,p_style                         => p_style
     -- Bug 4195237 : 'p_tax_name' parameter is disabled.
     -- Passing 'null' to hr_location_internal
     ,p_tax_name                      => null
     ,p_telephone_number_1            => p_telephone_number_1
     ,p_telephone_number_2            => p_telephone_number_2
     ,p_telephone_number_3            => p_telephone_number_3
     ,p_town_or_city                  => p_town_or_city
     ,p_loc_information13             => p_loc_information13
     ,p_loc_information14             => p_loc_information14
     ,p_loc_information15             => p_loc_information15
     ,p_loc_information16             => p_loc_information16
     ,p_loc_information17             => p_loc_information17
     ,p_loc_information18             => p_loc_information18
     ,p_loc_information19             => p_loc_information19
     ,p_loc_information20             => p_loc_information20
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
     ,p_global_attribute_category     => p_global_attribute_category
     ,p_global_attribute1             => p_global_attribute1
     ,p_global_attribute2             => p_global_attribute2
     ,p_global_attribute3             => p_global_attribute3
     ,p_global_attribute4             => p_global_attribute4
     ,p_global_attribute5             => p_global_attribute5
     ,p_global_attribute6             => p_global_attribute6
     ,p_global_attribute7             => p_global_attribute7
     ,p_global_attribute8             => p_global_attribute8
     ,p_global_attribute9             => p_global_attribute9
     ,p_global_attribute10            => p_global_attribute10
     ,p_global_attribute11            => p_global_attribute11
     ,p_global_attribute12            => p_global_attribute12
     ,p_global_attribute13            => p_global_attribute13
     ,p_global_attribute14            => p_global_attribute14
     ,p_global_attribute15            => p_global_attribute15
     ,p_global_attribute16            => p_global_attribute16
     ,p_global_attribute17            => p_global_attribute17
     ,p_global_attribute18            => p_global_attribute18
     ,p_global_attribute19            => p_global_attribute19
     ,p_global_attribute20            => p_global_attribute20
    );

--
    BEGIN
    --
    -- Start of API User Hook for the after hook of update_location
    --
    hr_location_bk2.update_location_a
      (
     p_effective_date                => p_effective_date
    ,p_language_code                 => l_language_code
    ,p_location_id                   => p_location_id
    ,p_location_code                 => p_location_code
    ,p_description                   => p_description
    ,p_timezone_code                 => p_timezone_code
    ,p_tp_header_id                  => p_tp_header_id
    ,p_ece_tp_location_code          => p_ece_tp_location_code
    ,p_address_line_1                => p_address_line_1
    ,p_address_line_2                => p_address_line_2
    ,p_address_line_3                => p_address_line_3
    ,p_bill_to_site_flag             => p_bill_to_site_flag
    ,p_country                       => p_country
    ,p_designated_receiver_id        => p_designated_receiver_id
    ,p_in_organization_flag          => p_in_organization_flag
    ,p_inactive_date                 => l_inactive_date
    ,p_operating_unit_id             => p_operating_unit_id
    ,p_inventory_organization_id     => p_inventory_organization_id
    ,p_office_site_flag              => p_office_site_flag
    ,p_postal_code                   => p_postal_code
    ,p_receiving_site_flag           => p_receiving_site_flag
    ,p_region_1                      => p_region_1
    ,p_region_2                      => p_region_2
    ,p_region_3                      => p_region_3
    ,p_ship_to_location_id           => p_ship_to_location_id
    ,p_ship_to_site_flag             => p_ship_to_site_flag
    ,p_style                         => p_style
    ,p_tax_name                      => p_tax_name
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_town_or_city                  => p_town_or_city
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
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
    ,p_global_attribute_category     => p_global_attribute_category
    ,p_global_attribute1             => p_global_attribute1
    ,p_global_attribute2             => p_global_attribute2
    ,p_global_attribute3             => p_global_attribute3
    ,p_global_attribute4             => p_global_attribute4
    ,p_global_attribute5             => p_global_attribute5
    ,p_global_attribute6             => p_global_attribute6
    ,p_global_attribute7             => p_global_attribute7
    ,p_global_attribute8             => p_global_attribute8
    ,p_global_attribute9             => p_global_attribute9
    ,p_global_attribute10            => p_global_attribute10
    ,p_global_attribute11            => p_global_attribute11
    ,p_global_attribute12            => p_global_attribute12
    ,p_global_attribute13            => p_global_attribute13
    ,p_global_attribute14            => p_global_attribute14
    ,p_global_attribute15            => p_global_attribute15
    ,p_global_attribute16            => p_global_attribute16
    ,p_global_attribute17            => p_global_attribute17
    ,p_global_attribute18            => p_global_attribute18
    ,p_global_attribute19            => p_global_attribute19
    ,p_global_attribute20            => p_global_attribute20
    ,p_object_version_number         => l_object_version_number
     );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LOCATION'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_location
    --
  END;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
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
    ROLLBACK TO update_location;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO update_location;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END update_location;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_location >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_location
   (  p_validate                     IN BOOLEAN DEFAULT false
     ,p_location_id                  IN hr_locations.location_id%TYPE
     ,p_object_version_number        IN hr_locations.object_version_number%TYPE )

IS
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_location';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_location;
  --
    BEGIN
    hr_utility.set_location( l_proc, 20);
    hr_location_bk3.delete_location_b (
      p_location_id                 => p_location_id,
      p_object_version_number       => p_object_version_number );
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LOCATION'
        ,p_hook_type   => 'BP'
   );
  END;
  --
  -- Process Logic
  -- =============
  --
  --  Need to lock main table to maintain the locking ladder order
  --
  hr_utility.set_location( l_proc, 30);
  hr_loc_shd.lck (   p_location_id                 => p_location_id,
                     p_object_version_number       => p_object_version_number );
  --
  --  Remove all matching translation rows
  --
  hr_utility.set_location( l_proc, 35);
  hr_lot_del.del_tl (
    p_location_id                 => p_location_id );
  --
  --  Remove non-translated data row
  --
  hr_utility.set_location( l_proc, 40);
  hr_loc_del.del(
    p_location_id                 => p_location_id,
    p_object_version_number       => p_object_version_number );
  --
    BEGIN
    hr_utility.set_location( l_proc, 50);
    hr_location_bk3.delete_location_a (
      p_location_id                 => p_location_id,
      p_object_version_number       => p_object_version_number );
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LOCATION'
        ,p_hook_type   => 'AP'
   );
  END;
--
--
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
     RAISE hr_api.validate_enabled;
  END IF;
  --
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_location;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO delete_location;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
END delete_location;
--

--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |---------------------< create_location_legal_adr >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_location_legal_adr
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_code                  IN  VARCHAR2
     ,p_description                    IN  VARCHAR2  DEFAULT NULL
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT NULL
     ,p_country                        IN  VARCHAR2  DEFAULT NULL
     ,p_inactive_date                  IN  DATE      DEFAULT NULL
     ,p_postal_code                    IN  VARCHAR2  DEFAULT NULL
     ,p_region_1                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_2                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_3                       IN  VARCHAR2  DEFAULT NULL
     ,p_style                          IN  VARCHAR2  DEFAULT NULL
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT NULL
  /*Added for bug8703747 */
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information13              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information14              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information15              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information16              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information17              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information18              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information19              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information20              IN  VARCHAR2  DEFAULT NULL
/*Changes end for bug8703747 */
     ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
     ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
     ,p_business_group_id              IN  NUMBER    DEFAULT NULL
     ,p_location_id                    OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER

  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_location_legal_adr';
  l_location_id           hr_locations_all.location_id%TYPE;
  l_object_version_number hr_locations_all.object_version_number%TYPE;
  l_language_code         hr_locations_all_tl.language%TYPE;
  l_inactive_date         DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_location_legal_adr;
  --
  hr_utility.set_location(l_proc, 15);
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_inactive_date := trunc (p_inactive_date);
  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --

    BEGIN
    --
    -- Start of API User Hook for the before hook of create_generic_location
    --
    hr_location_bk4.create_location_legal_adr_b(
     p_effective_date                => p_effective_date
    ,p_language_code                 => l_language_code
    ,p_location_code                 => p_location_code
    ,p_description                   => p_description
    ,p_timezone_code                 => p_timezone_code
    ,p_address_line_1                => p_address_line_1
    ,p_address_line_2                => p_address_line_2
    ,p_address_line_3                => p_address_line_3
    ,p_country                       => p_country
    ,p_inactive_date                 => l_inactive_date
    ,p_postal_code                   => p_postal_code
    ,p_region_1                      => p_region_1
    ,p_region_2                      => p_region_2
    ,p_region_3                      => p_region_3
    ,p_style                         => p_style
    ,p_town_or_city                  => p_town_or_city
    ,p_attribute_category            => p_attribute_category
   /* Added for bug8703747*/
     ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
/* Changes end for bug8703747*/
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
    ,p_business_group_id             => p_business_group_id
     );
     EXCEPTION
       WHEN hr_api.cannot_find_prog_unit THEN
         hr_api.cannot_find_prog_unit_error
           (  p_module_name => 'create_location_legal_adr'
             ,p_hook_type   => 'BP'
           );
    --
    -- End of API User Hook for the before hook of create_generic_location
    --
  END;

  -- Process Logic
  --
  -- Call the internal API

  hr_location_internal.create_generic_location
  (   p_effective_date                => p_effective_date
     ,p_location_id                   => l_location_id
     ,p_object_version_number         => l_object_version_number
     ,p_location_code                 => p_location_code
     ,p_address_line_1                => p_address_line_1
     ,p_address_line_2                => p_address_line_2
     ,p_address_line_3                => p_address_line_3
     ,p_country                       => p_country
     ,p_description                   => p_description
     ,p_inactive_date                 => l_inactive_date
     ,p_postal_code                   => p_postal_code
     ,p_region_1                      => p_region_1
     ,p_region_2                      => p_region_2
     ,p_region_3                      => p_region_3
     ,p_style                         => p_style
     ,p_town_or_city                  => p_town_or_city
     /* Added for bug8703747*/
     ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
/* Changes end for bug8703747*/
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
     ,p_legal_address_flag            => 'Y'
     ,p_business_group_id             => p_business_group_id
   );

  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_generic_location
    --
    hr_location_bk4.create_location_legal_adr_a
      (
     p_effective_date                => p_effective_date
    ,p_language_code                 => l_language_code
    ,p_location_code                 => p_location_code
    ,p_description                   => p_description
    ,p_timezone_code                 => p_timezone_code
    ,p_address_line_1                => p_address_line_1
    ,p_address_line_2                => p_address_line_2
    ,p_address_line_3                => p_address_line_3
    ,p_country                       => p_country
    ,p_inactive_date                 => l_inactive_date
    ,p_postal_code                   => p_postal_code
    ,p_region_1                      => p_region_1
    ,p_region_2                      => p_region_2
    ,p_region_3                      => p_region_3
    ,p_style                         => p_style
    ,p_town_or_city                  => p_town_or_city
    ,p_attribute_category            => p_attribute_category
    /* Added for bug8703747*/
     ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
/* Changes end for bug8703747*/
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
    ,p_business_group_id             => p_business_group_id
    ,p_location_id                   => l_location_id
    ,p_object_version_number         => l_object_version_number
   );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_location_legal_adr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_generic_location
    --
  END;

  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
    IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_location_id := l_location_id;
  p_object_version_number := l_object_version_number;
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_location_legal_adr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_location_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_location_legal_adr;
    -- Set OUT parameters.
    p_location_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_location_legal_adr;
-- ----------------------------------------------------------------------------
-- |--------------------< update_location_legal_adr >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_location_legal_adr
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_location_id                    IN  NUMBER
     ,p_description                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_inactive_date                  IN  DATE      DEFAULT hr_api.g_date
     ,p_postal_code                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_style                          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT hr_api.g_varchar2
    /* Added for bug8703747*/
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information13              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information14              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information15              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information16              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information17              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information18              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information19              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information20              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
    /*Changes end for bug8703747 */
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_location_legal_adr';
  l_object_version_number hr_locations.object_version_number%TYPE;
  l_temp_ovn   number(9) := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_location_legal_adr;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
    BEGIN
    --
    -- Start of API User Hook for the before hook of update_location_legal_adr
    --
    hr_location_bk5.update_location_legal_adr_b
      (
     p_effective_date                => p_effective_date
    ,p_location_id                   => p_location_id
    ,p_description                   => p_description
    ,p_timezone_code                 => p_timezone_code
    ,p_address_line_1                => p_address_line_1
    ,p_address_line_2                => p_address_line_2
    ,p_address_line_3                => p_address_line_3
    ,p_inactive_date                 => p_inactive_date
    ,p_postal_code                   => p_postal_code
    ,p_region_1                      => p_region_1
    ,p_region_2                      => p_region_2
    ,p_region_3                      => p_region_3
    ,p_style                         => p_style
    ,p_town_or_city                  => p_town_or_city
      /*Added for bug8703747 */
     ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
 /*Changes end for bug8703747 */
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
    ,p_object_version_number         => l_object_version_number
      );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_location_legal_adr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_location_legal_adr
    --
  END;
  --
  -- Call the internal API
  --
  hr_location_internal.update_generic_location
    ( p_effective_date                => p_effective_date
     ,p_location_id                   => p_location_id
     ,p_object_version_number         => l_object_version_number
     ,p_description                   => p_description
     ,p_address_line_1                => p_address_line_1
     ,p_address_line_2                => p_address_line_2
     ,p_address_line_3                => p_address_line_3
     ,p_inactive_date                 => p_inactive_date
     ,p_postal_code                   => p_postal_code
     ,p_region_1                      => p_region_1
     ,p_region_2                      => p_region_2
     ,p_region_3                      => p_region_3
     ,p_style                         => p_style
     ,p_town_or_city                  => p_town_or_city
       /*Added for bug8703747 */
     ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
 /*Changes end for bug8703747 */
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
    );

--
    BEGIN
    --
    -- Start of API User Hook for the after hook of update_location_legal_adr
    --
    hr_location_bk5.update_location_legal_adr_a
      (
         p_effective_date                => p_effective_date
        ,p_location_id                   => p_location_id
        ,p_description                   => p_description
        ,p_timezone_code                 => p_timezone_code
        ,p_address_line_1                => p_address_line_1
        ,p_address_line_2                => p_address_line_2
        ,p_address_line_3                => p_address_line_3
        ,p_inactive_date                 => p_inactive_date
        ,p_postal_code                   => p_postal_code
        ,p_region_1                      => p_region_1
        ,p_region_2                      => p_region_2
        ,p_region_3                      => p_region_3
        ,p_style                         => p_style
        ,p_town_or_city                  => p_town_or_city
          /*Added for bug8703747 */
     ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
    ,p_loc_information13             => p_loc_information13
    ,p_loc_information14             => p_loc_information14
    ,p_loc_information15             => p_loc_information15
    ,p_loc_information16             => p_loc_information16
    ,p_loc_information17             => p_loc_information17
    ,p_loc_information18             => p_loc_information18
    ,p_loc_information19             => p_loc_information19
    ,p_loc_information20             => p_loc_information20
 /*Changes end for bug8703747 */
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
        ,p_object_version_number         => l_object_version_number
      );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_location_legal_adr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_location_legal_adr
    --
  END;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
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
    ROLLBACK TO update_location_legal_adr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO update_location_legal_adr;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END update_location_legal_adr;
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
              p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
-- ----------------------------------------------------------------------------
-- |----------------------< disable_location_legal_adr >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE disable_location_legal_adr
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_location_id                    IN  NUMBER
     ,p_object_version_number          IN OUT NOCOPY  NUMBER

  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'disable_location_legal_adr';
  l_object_version_number hr_locations_all.object_version_number%TYPE;
  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint disable_location_legal_adr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Bug fix 3205662.
  -- User hook call added.
  --
  BEGIN
      --
      -- Start of API User Hook for the before hook of disable_location_legal_adr
      --
      hr_location_bk7.disable_location_legal_adr_b
      (
         p_effective_date    => p_effective_date
   ,p_location_id            => p_location_id
   ,p_object_version_number  => l_object_version_number
      );

  EXCEPTION
      WHEN hr_api.cannot_find_prog_unit THEN
            hr_api.cannot_find_prog_unit_error
              (p_module_name => 'disable_location_legal_adr'
              ,p_hook_type   => 'BP'
              );
       --
       -- End of API User Hook for the before hook of disable_location_legal_adr
       --
  END;
  --
  -- UPDATE ROW IN HR_LOCATIONS_ALL table
  --
    hr_location_internal.update_generic_location
  (   p_effective_date                => p_effective_date
     ,p_location_id                   => p_location_id
     ,p_object_version_number         => l_object_version_number
     ,p_legal_address_flag       => NULL
   );

  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Bug fix 3205662.
  -- User hook call added.
  --
  BEGIN
     --
     -- Start of API User Hook for the after hook of disable_location_legal_adr
     --
     hr_location_bk7.disable_location_legal_adr_a
     (
         p_effective_date    => p_effective_date
   ,p_location_id            => p_location_id
   ,p_object_version_number  => l_object_version_number
     );

  EXCEPTION
     WHEN hr_api.cannot_find_prog_unit THEN
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'disable_location_legal_adr'
            ,p_hook_type   => 'AP'
            );
      --
      -- End of API User Hook for the after hook of disable_location_legal_adr
      --
  END;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO disable_location_legal_adr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO disable_location_legal_adr;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END disable_location_legal_adr;
--
-- ----------------------------------------------------------------------------
-- |------------------------< enable_location_legal_adr >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE enable_location_legal_adr
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_location_id                    IN  NUMBER
     ,p_object_version_number          IN OUT NOCOPY  NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'enable_location_legal_adr';
  l_object_version_number hr_locations_all.object_version_number%TYPE;
  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint enable_location_legal_adr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Bug fix 3205662.
  -- User hook call added.
  --
  BEGIN
        --
        -- Start of API User Hook for the before hook of enable_location_legal_adr
        --
        hr_location_bk6.enable_location_legal_adr_b
        (
           p_effective_date     => p_effective_date
     ,p_location_id            => p_location_id
     ,p_object_version_number  => l_object_version_number
        );

  EXCEPTION
        WHEN hr_api.cannot_find_prog_unit THEN
              hr_api.cannot_find_prog_unit_error
                (p_module_name => 'enable_location_legal_adr'
                ,p_hook_type   => 'BP'
                );
        --
        -- End of API User Hook for the before hook of enable_location_legal_adr
        --
  END;
  --
  -- UPDATE ROW IN HR_LOCATIONS_ALL table
  --
    hr_location_internal.update_generic_location
  (   p_effective_date                => p_effective_date
     ,p_location_id                   => p_location_id
     ,p_object_version_number         => l_object_version_number
     ,p_legal_address_flag       => 'Y'
   );

  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Bug fix 3205662.
  -- User hook call added.
  --
  BEGIN
       --
       -- Start of API User Hook for the after hook of enable_location_legal_adr
       --
       hr_location_bk6.enable_location_legal_adr_a
       (
           p_effective_date       => p_effective_date
     ,p_location_id            => p_location_id
     ,p_object_version_number  => l_object_version_number
       );
  EXCEPTION
          WHEN hr_api.cannot_find_prog_unit THEN
                hr_api.cannot_find_prog_unit_error
                  (p_module_name => 'enable_location_legal_adr'
                  ,p_hook_type   => 'AP'
                  );
        --
        -- End of API User Hook for the after hook of enable_location_legal_adr
        --
  END;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO enable_location_legal_adr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO enable_location_legal_adr;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END enable_location_legal_adr;
--
-----------------------------------------------------------------------------
END hr_location_api;

/
