--------------------------------------------------------
--  DDL for Package Body HR_IN_LOCATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_LOCATION_API" AS
/* $Header: pelocini.pkb 115.0 2004/05/25 04:15 gaugupta noship $ */
g_package  VARCHAR2(33) := 'hr_in_location_api.';
g_trace BOOLEAN ;

-- ----------------------------------------------------------------------------
-- |-------------------------------< create_in_location >------------------------|
-- ----------------------------------------------------------------------------


PROCEDURE create_in_location
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT null
     ,p_location_code                  IN  VARCHAR2
     ,p_description                    IN  VARCHAR2  DEFAULT NULL
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT NULL
     ,p_tp_header_id                   IN  NUMBER    DEFAULT NULL
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT NULL
     ,p_flat_door_block                IN  VARCHAR2
     ,p_building_village               IN  VARCHAR2  DEFAULT NULL
     ,p_road_street                    IN  VARCHAR2  DEFAULT NULL
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
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT NULL
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_style                          IN  VARCHAR2  DEFAULT NULL
     ,p_tax_name                       IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number               IN  VARCHAR2  DEFAULT NULL
     ,p_fax_number                     IN  VARCHAR2  DEFAULT NULL
     ,p_area                           IN  VARCHAR2  DEFAULT NULL
     ,p_town_city_district             IN  VARCHAR2
     ,p_state_ut                       IN  VARCHAR2  DEFAULT NULL
     ,p_email                          IN  VARCHAR2  DEFAULT NULL
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
  -- Declare cursors and local variables
  --
    l_proc   VARCHAR2(72);
  --
 begin

 l_proc  := g_package||'create_in_location';
 g_trace := hr_utility.debug_enabled ;

 IF g_trace THEN
   hr_utility.set_location('Entering: '||l_proc, 10);
 END IF ;

 hr_location_api.create_location
      (
      p_validate                      => p_validate
     ,p_effective_date                => p_effective_date
     ,p_language_code                 => p_language_code
     ,p_location_code                 => p_location_code
     ,p_description                   => p_description
     ,p_timezone_code                 => p_timezone_code
     ,p_tp_header_id                  => p_tp_header_id
     ,p_ece_tp_location_code          => p_ece_tp_location_code
     ,p_address_line_1                => p_flat_door_block
     ,p_address_line_2                => p_building_village
     ,p_address_line_3                => p_road_street
     ,p_bill_to_site_flag             => p_bill_to_site_flag
     ,p_country                       => 'IN'
     ,p_designated_receiver_id        => p_designated_receiver_id
     ,p_in_organization_flag          => p_in_organization_flag
     ,p_inactive_date                 => p_inactive_date
     ,p_operating_unit_id             => p_operating_unit_id
     ,p_inventory_organization_id     => p_inventory_organization_id
     ,p_office_site_flag              => p_office_site_flag
     ,p_postal_code                   => p_postal_code
     ,p_receiving_site_flag           => p_receiving_site_flag
     ,p_ship_to_location_id           => p_ship_to_location_id
     ,p_ship_to_site_flag             => p_ship_to_site_flag
     ,p_style                         => 'IN'
     ,p_tax_name                      => p_tax_name
     ,p_telephone_number_1            => p_telephone_number
     ,p_telephone_number_2            => p_fax_number
     ,p_loc_information14             => p_area
     ,p_loc_information15             => p_town_city_district
     ,p_loc_information16             => p_state_ut
     ,p_loc_information17             => p_email
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
     ,p_location_id           	      => p_location_id
     ,p_object_version_number 	      => p_object_version_number );

   IF g_trace THEN
     hr_utility.set_location('Leaving: '||l_proc, 30);
   END IF ;

 END create_in_location ;

-- ----------------------------------------------------------------------------
-- |-------------------------------< update_in_location >------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE update_in_location
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT null
     ,p_location_id                    IN  NUMBER
     ,p_location_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_description                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_tp_header_id                   IN  NUMBER    DEFAULT hr_api.g_number
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_flat_door_block                IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_building_village               IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_road_street                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
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
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT hr_api.g_number
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_style                          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_tax_name                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number               IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_fax_number                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_area                           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_town_city_district             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_state_ut                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_email                          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
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

 -- Declare cursors and local variables
 --
    l_proc      VARCHAR2(72);
 --
 begin

 l_proc  := g_package||'update_in_location';
 g_trace := hr_utility.debug_enabled ;

 IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
 END IF ;

 hr_location_api.update_location
      (
      p_validate                      => p_validate
     ,p_effective_date                => p_effective_date
     ,p_language_code                 => p_language_code
     ,p_location_code                 => p_location_code
     ,p_description                   => p_description
     ,p_timezone_code                 => p_timezone_code
     ,p_tp_header_id                  => p_tp_header_id
     ,p_ece_tp_location_code          => p_ece_tp_location_code
     ,p_address_line_1                => p_flat_door_block
     ,p_address_line_2                => p_building_village
     ,p_address_line_3                => p_road_street
     ,p_bill_to_site_flag             => p_bill_to_site_flag
     ,p_country                       => p_country
     ,p_designated_receiver_id        => p_designated_receiver_id
     ,p_in_organization_flag          => p_in_organization_flag
     ,p_inactive_date                 => p_inactive_date
     ,p_operating_unit_id             => p_operating_unit_id
     ,p_inventory_organization_id     => p_inventory_organization_id
     ,p_office_site_flag              => p_office_site_flag
     ,p_postal_code                   => p_postal_code
     ,p_receiving_site_flag           => p_receiving_site_flag
     ,p_ship_to_location_id           => p_ship_to_location_id
     ,p_ship_to_site_flag             => p_ship_to_site_flag
     ,p_style                         => 'IN'
     ,p_tax_name                      => p_tax_name
     ,p_telephone_number_1            => p_telephone_number
     ,p_telephone_number_2            => p_fax_number
     ,p_loc_information14             => p_area
     ,p_loc_information15             => p_town_city_district
     ,p_loc_information16             => p_state_ut
     ,p_loc_information17             => p_email
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
     ,p_location_id           	      => p_location_id
     ,p_object_version_number 	      => p_object_version_number );

   IF g_trace THEN
     hr_utility.set_location('Leaving: '||l_proc, 30);
   END IF ;
 END update_in_location ;


END hr_in_location_api ;

/
