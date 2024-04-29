--------------------------------------------------------
--  DDL for Package HR_IN_LOCATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_LOCATION_API" AUTHID CURRENT_USER AS
/* $Header: pelocini.pkh 120.1 2005/10/02 02:42 aroussel $ */
/*#
 * This package contains location APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Location for India
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_in_location >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new location.
 *
 * The API is MLS enabled, and there are two translated columns: LOCATION_CODE
 * and DESCRIPTION. The business_group_id of a location determines its scope.
 * If the business_group_id is NULL, the location's scope is global. If the
 * business_group_id is set, the location's scope is local.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Some fields require certain applications to be installed. See &quot;In
 * Parameters&quot; for full details.
 *
 * <p><b>Post Success</b><br>
 * A new location will be created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a location and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_location_code Location name (Translated).
 * @param p_description Location description (Translated).
 * @param p_timezone_code Timezone of Location.
 * @param p_tp_header_id Identifier for the Inventory Header.
 * @param p_ece_tp_location_code Inventory Organization.
 * @param p_flat_door_block Flat/Door/Block of the address.
 * @param p_building_village Building/Village of the address.
 * @param p_road_street Road/Street of the address.
 * @param p_bill_to_site_flag Bill-to-Site Flag. Valid values are defined by
 * 'YES/NO' lookup type. Default 'Y'.
 * @param p_country Country of the address. If Address stye is India then the
 * value will be India else wil get the valid values from FND_TERRITORIES
 * @param p_designated_receiver_id Designated Receiver Person ID Must be a
 * valid employee within the scope of the location
 * @param p_in_organization_flag Internal Organization Flag. Valid values are
 * defined by 'YES/NO' lookup type. Default 'Y'.
 * @param p_inactive_date Date on which location becomes inactive. Must be
 * greater than or equal to p_effective_date.
 * @param p_operating_unit_id Needs to be provided if inventory_organization_id
 * is provided. See special notes below. Not stored on database.
 * @param p_inventory_organization_id Identifier for the Inventory Organization
 * @param p_office_site_flag Office-Site Flag. Valid values are defined by
 * 'YES/NO' lookup type. Default 'Y'.
 * @param p_postal_code Postal code of the address. If Address stye is India
 * then the first two digits must be valid for a state. Valid values are
 * defined by 'IN_PIN_CODES' lookup type.
 * @param p_receiving_site_flag Receiving-Site Flag. Valid values are defined
 * by 'YES/NO' lookup type. Default 'Y'. If the current location is a 'Ship-to'
 * site receiving_site_flag must also = 'Y'.
 * @param p_ship_to_location_id Ship-to Location Id. Should never be NULL. IF
 * it is passed through as NULL, then it will take the value of LOCATION_ID.
 * The following must be true for validation to succeed: 1). INACTIVE_DATE (if
 * set) &gt;= SESSION_DATE. 2). BUSINESS_GROUP_ID is null or equal to the
 * business group of the location. NOTE: if the business group of the location
 * is null do not enforce this validation rule.
 * @param p_ship_to_site_flag Ship-to-Site Flag. Valid values are defined by
 * 'YES/NO' lookup type. If SHIP_TO_LOCATION_ID is equal to LOCATION_ID then
 * the SHIP_TO_SITE_FLAG must be 'Y'. If the SHIP_TO_LOCATION_ID is passed as
 * NULL, then it takes on the value of LOCATION_ID. If the SHIP_TO_LOCATION_ID
 * is some other ID then the SHIP_TO_SITE_FLAG must be 'N'.
 * @param p_style Address Flexfield.
 * @param p_tax_name Tax Code.
 * @param p_telephone_number Telephone Number of the address.
 * @param p_fax_number Fax Number of the address.
 * @param p_area Area/Locality of the address.
 * @param p_town_city_district Town/City/District of the address.
 * @param p_state_ut State/UT of the address. If Address stye is India then the
 * valid values are defined by 'IN_STATES' lookup type.
 * @param p_email Email.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_global_attribute_category The global context value which flexfield
 * structure uses with the descriptive flexfield segments.
 * @param p_global_attribute1 Descriptive flexfield segment.
 * @param p_global_attribute2 Descriptive flexfield segment.
 * @param p_global_attribute3 Descriptive flexfield segment.
 * @param p_global_attribute4 Descriptive flexfield segment.
 * @param p_global_attribute5 Descriptive flexfield segment.
 * @param p_global_attribute6 Descriptive flexfield segment.
 * @param p_global_attribute7 Descriptive flexfield segment.
 * @param p_global_attribute8 Descriptive flexfield segment.
 * @param p_global_attribute9 Descriptive flexfield segment.
 * @param p_global_attribute10 Descriptive flexfield segment.
 * @param p_global_attribute11 Descriptive flexfield segment.
 * @param p_global_attribute12 Descriptive flexfield segment.
 * @param p_global_attribute13 Descriptive flexfield segment.
 * @param p_global_attribute14 Descriptive flexfield segment.
 * @param p_global_attribute15 Descriptive flexfield segment.
 * @param p_global_attribute16 Descriptive flexfield segment.
 * @param p_global_attribute17 Descriptive flexfield segment.
 * @param p_global_attribute18 Descriptive flexfield segment.
 * @param p_global_attribute19 Descriptive flexfield segment.
 * @param p_global_attribute20 Descriptive flexfield segment.
 * @param p_business_group_id Business group ID. A NULL value indicates global
 * scope. Any other value must index a valid business group and set the scope
 * of the location to local.
 * @param p_location_id If p_validate is false, this contains the ID assigned
 * to the location (otherwise contains NULL).
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created location. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Location for India
 * @rep:category BUSINESS_ENTITY HR_LOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
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
  ) ;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_in_location >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a location.
 *
 * The API is MLS enabled, and there are two translated columns: LOCATION_CODE
 * and DESCRIPTION. The business_group_id of a location determines its scope.
 * If the business_group_id is NULL, the location's scope is global. If the
 * business_group_id is set, the location's scope is local.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Some fields require certain applications to have been installed.See &quot;In
 * Parameters&quot; for full details.
 *
 * <p><b>Post Success</b><br>
 * The location will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The API will not update the location and will raise an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_location_id Primary Key of the location to be updated.
 * @param p_location_code Location name (Translated).
 * @param p_description Location description (Translated).
 * @param p_timezone_code Timezone of Location.
 * @param p_tp_header_id Identifier for the Inventory Header.
 * @param p_ece_tp_location_code Inventory Organization.
 * @param p_flat_door_block Flat/Door/Block of the address.
 * @param p_building_village Building/Village of the address.
 * @param p_road_street Road/Street of the address.
 * @param p_bill_to_site_flag Bill-to-Site Flag. Valid values are defined by
 * 'YES/NO' lookup type. Default 'Y'.
 * @param p_country Country of the address. If Address stye is India then the
 * value will be India else wil get the valid values from FND_TERRITORIES
 * @param p_designated_receiver_id Designated Receiver Person ID Must be a
 * valid employee within the scope of the location.
 * @param p_in_organization_flag Internal Organization Flag. Valid values are
 * defined by 'YES/NO' lookup type. Default 'Y'.
 * @param p_inactive_date Date on which location becomes inactive. Must be
 * greater than or equal to p_effective_date.
 * @param p_operating_unit_id Needs to be provided if inventory_organization_id
 * is provided. See special notes below. Not stored on database.
 * @param p_inventory_organization_id Identifier for the Inventory
 * Organization.
 * @param p_office_site_flag Office-Site Flag. Valid values are defined by
 * 'YES/NO' lookup type. Default 'Y'.
 * @param p_postal_code Postal code of the address. If Address stye is India
 * then the first two digits must be valid for a state. Valid values are
 * defined by 'IN_PIN_CODES' lookup type.
 * @param p_receiving_site_flag Receiving-Site Flag. Valid values are defined
 * by 'YES/NO' lookup type. Default 'Y'. If the current location is a 'Ship-to'
 * site receiving_site_flag must also = 'Y'.
 * @param p_ship_to_location_id Ship-to Location Id. Must be an active
 * 'Ship-to' location within the scope of the current location.
 * @param p_ship_to_site_flag Ship-to-Site Flag. Valid values are defined by
 * 'YES/NO' lookup type. Default 'Y'. If ship_to_location_id is NULL, no
 * further validation is performed. If ship_to_location_id is not NULL,
 * ship_to_site_flag must be 'Y' if the 'Ship-to' location is the current
 * location, otherwise it must be 'N'.
 * @param p_style Address Flexfield.
 * @param p_tax_name Tax Code.
 * @param p_telephone_number Telephone Number of the address.
 * @param p_fax_number Fax Number of the address.
 * @param p_area Area/Locality of the address.
 * @param p_town_city_district Town/City/District of the address.
 * @param p_state_ut State/UT of the address. If Address stye is India then the
 * valid values are defined by 'IN_STATES' lookup type.
 * @param p_email Email.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_global_attribute_category The global context value which flexfield
 * structure uses with the descriptive flexfield segments.
 * @param p_global_attribute1 Descriptive flexfield segment.
 * @param p_global_attribute2 Descriptive flexfield segment.
 * @param p_global_attribute3 Descriptive flexfield segment.
 * @param p_global_attribute4 Descriptive flexfield segment.
 * @param p_global_attribute5 Descriptive flexfield segment.
 * @param p_global_attribute6 Descriptive flexfield segment.
 * @param p_global_attribute7 Descriptive flexfield segment.
 * @param p_global_attribute8 Descriptive flexfield segment.
 * @param p_global_attribute9 Descriptive flexfield segment.
 * @param p_global_attribute10 Descriptive flexfield segment.
 * @param p_global_attribute11 Descriptive flexfield segment.
 * @param p_global_attribute12 Descriptive flexfield segment.
 * @param p_global_attribute13 Descriptive flexfield segment.
 * @param p_global_attribute14 Descriptive flexfield segment.
 * @param p_global_attribute15 Descriptive flexfield segment.
 * @param p_global_attribute16 Descriptive flexfield segment.
 * @param p_global_attribute17 Descriptive flexfield segment.
 * @param p_global_attribute18 Descriptive flexfield segment.
 * @param p_global_attribute19 Descriptive flexfield segment.
 * @param p_global_attribute20 Descriptive flexfield segment.
 * @param p_object_version_number Pass in the current version number of the
 * location to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated location. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Location for India
 * @rep:category BUSINESS_ENTITY HR_LOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
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
  ) ;
END hr_in_location_api ;

 

/
