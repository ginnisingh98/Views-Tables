--------------------------------------------------------
--  DDL for Package Body HR_LOCATION_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOCATION_INTERNAL" AS
/* $Header: hrlocbsi.pkb 115.4 2003/09/23 07:31:27 ptitoren noship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := '  hr_location_api.';
--
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-------------------------< create__generic_location >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_generic_location
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
     ,p_legal_address_flag             IN  VARCHAR2  DEFAULT NULL
     ,p_location_id                    OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER

  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_generic_location';
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
  savepoint create_generic_location;
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
  -- Insert non-translatable rows into HR_LOCATIONS_ALL first
  hr_loc_ins.ins
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
     ,p_legal_address_flag            => p_legal_address_flag
     ,p_tp_header_id                  => p_tp_header_id
     ,p_ece_tp_location_code          => p_ece_tp_location_code
     ,p_business_group_id             => p_business_group_id
   );
  --
  --  Now insert translatable rows in HR_LOCATIONS_ALL_TL table
  hr_lot_ins.ins_tl
    ( p_language_code              => l_language_code,
      p_location_id                => l_location_id,
      p_location_code              => p_location_code,
      p_description                => p_description,
      p_business_group_id          => p_business_group_id
    );
  --
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
    ROLLBACK TO create_generic_location;
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
    ROLLBACK TO create_generic_location;
    -- Set OUT parameters.
    p_location_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_generic_location;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_generic_location >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_generic_location
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
     ,p_legal_address_flag             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_generic_location';
  l_object_version_number hr_locations.object_version_number%TYPE;
  l_language_code         hr_locations_all_tl.language%TYPE;
  l_inactive_date         DATE;
  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_generic_location;
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
  --
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Insert non-translatable rows in HR_LOCATIONS_ALL Table
  --
  hr_loc_upd.upd
    ( p_effective_date                => p_effective_date
     ,p_location_id                   => p_location_id
     ,p_object_version_number         => l_object_version_number
     ,p_tp_header_id                  => p_tp_header_id
     ,p_ece_tp_location_code          => p_ece_tp_location_code
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
     ,p_legal_address_flag            => p_legal_address_flag
    );
  --
  --  Now insert translatable rows in HR_LOCATIONS_ALL_TL table
     hr_lot_upd.upd_tl
     ( p_language_code              => l_language_code,
       p_location_id                => p_location_id,
       p_location_code              => p_location_code,
       p_description                => p_description);
  --
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
    ROLLBACK TO update_generic_location;
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
    ROLLBACK TO update_generic_location;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END update_generic_location;
--
---------------------------------------------------------------------------
END hr_location_internal;

/
