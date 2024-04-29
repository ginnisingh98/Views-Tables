--------------------------------------------------------
--  DDL for Package HR_IN_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_PERSON_ADDRESS_API" AUTHID CURRENT_USER AS
/* $Header: peaddini.pkh 120.1 2005/10/02 02:37 aroussel $ */
/*#
 * This package contains person address APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Person Address for India
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_in_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a person.
 *
 * This API is effectively an alternative to the API create_person_address. If
 * p_validate is set to false, an address is created. If creating the first
 * address for the specified person, then it must be the primary address. As
 * one and only one primary address can exist at any given time for a person,
 * any subsequent addresses must not be primary.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid person (p_person_id) must exist on the start date (p_date_from) of
 * the address. The address_type attribute can only be used after QuickCodes
 * have been defined for the 'ADDRESS_TYPE' lookup type.
 *
 * <p><b>Post Success</b><br>
 * The person address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the address and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_pradd_ovlapval_override Primary address override flag. If
 * p_pradd_ovlapval_override is set to true and p_primary_flag is 'Y' then the
 * address being created overrides the already existing primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Identifies the primary address.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_country Country of the address. If Address stye is India then the
 * value will be India else wil get the valid values from FND_TERRITORIES
 * @param p_comments Person address comment text.
 * @param p_flat_door_block Flat/Door/Block of the address.
 * @param p_building_village Building/Village of the address.
 * @param p_road_street Road/Street of the address.
 * @param p_area_locality Area/Locality of the address.
 * @param p_town_or_city Town/City of the address.
 * @param p_state_ut State/UT of the address. If Address stye is India then the
 * valid values are defined by 'IN_STATES' lookup type.
 * @param p_pin_code Postal code of the address. If Address stye is India then
 * the first two digits must be valid for a state. Valid values are defined by
 * 'IN_PIN_CODES' lookup type.
 * @param p_addr_attribute_category This context value determines which
 * flexfield structure to use with the Person Address descriptive flexfield
 * segments.
 * @param p_addr_attribute1 Descriptive flexfield segment.
 * @param p_addr_attribute2 Descriptive flexfield segment.
 * @param p_addr_attribute3 Descriptive flexfield segment.
 * @param p_addr_attribute4 Descriptive flexfield segment.
 * @param p_addr_attribute5 Descriptive flexfield segment.
 * @param p_addr_attribute6 Descriptive flexfield segment.
 * @param p_addr_attribute7 Descriptive flexfield segment.
 * @param p_addr_attribute8 Descriptive flexfield segment.
 * @param p_addr_attribute9 Descriptive flexfield segment.
 * @param p_addr_attribute10 Descriptive flexfield segment.
 * @param p_addr_attribute11 Descriptive flexfield segment.
 * @param p_addr_attribute12 Descriptive flexfield segment.
 * @param p_addr_attribute13 Descriptive flexfield segment.
 * @param p_addr_attribute14 Descriptive flexfield segment.
 * @param p_addr_attribute15 Descriptive flexfield segment.
 * @param p_addr_attribute16 Descriptive flexfield segment.
 * @param p_addr_attribute17 Descriptive flexfield segment.
 * @param p_addr_attribute18 Descriptive flexfield segment.
 * @param p_addr_attribute19 Descriptive flexfield segment.
 * @param p_addr_attribute20 Descriptive flexfield segment.
 * @param p_address_id If p_validate is false, uniquely identifies the address
 * created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Person Address. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Person Address for India
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_person_address
  (p_validate                      IN     BOOLEAN  default false
  ,p_effective_date                IN     DATE
  ,p_pradd_ovlapval_override       IN     BOOLEAN  default FALSE
  ,p_person_id                     IN     NUMBER   default null
  ,p_primary_flag                  IN     VARCHAR2
  ,p_date_from                     IN     DATE
  ,p_date_to                       IN     DATE     default null
  ,p_address_type                  IN     VARCHAR2 default null
  ,p_country                       IN     VARCHAR2 default null
  ,p_comments                      IN     LONG     default null
  ,p_flat_door_block               IN     VARCHAR2
  ,p_building_village              IN     VARCHAR2 default null
  ,p_road_street                   IN     VARCHAR2 default null
  ,p_area_locality                 IN     VARCHAR2 default null
  ,p_town_or_city                  IN     VARCHAR2
  ,p_state_ut                      IN     VARCHAR2 default null
  ,p_pin_code                      IN     VARCHAR2 default null
  ,p_addr_attribute_category       IN     VARCHAR2 default null
  ,p_addr_attribute1               IN     VARCHAR2 default null
  ,p_addr_attribute2               IN     VARCHAR2 default null
  ,p_addr_attribute3               IN     VARCHAR2 default null
  ,p_addr_attribute4               IN     VARCHAR2 default null
  ,p_addr_attribute5               IN     VARCHAR2 default null
  ,p_addr_attribute6               IN     VARCHAR2 default null
  ,p_addr_attribute7               IN     VARCHAR2 default null
  ,p_addr_attribute8               IN     VARCHAR2 default null
  ,p_addr_attribute9               IN     VARCHAR2 default null
  ,p_addr_attribute10              IN     VARCHAR2 default null
  ,p_addr_attribute11              IN     VARCHAR2 default null
  ,p_addr_attribute12              IN     VARCHAR2 default null
  ,p_addr_attribute13              IN     VARCHAR2 default null
  ,p_addr_attribute14              IN     VARCHAR2 default null
  ,p_addr_attribute15              IN     VARCHAR2 default null
  ,p_addr_attribute16              IN     VARCHAR2 default null
  ,p_addr_attribute17              IN     VARCHAR2 default null
  ,p_addr_attribute18              IN     VARCHAR2 default null
  ,p_addr_attribute19              IN     VARCHAR2 default null
  ,p_addr_attribute20              IN     VARCHAR2 default null
  ,p_address_id                    OUT NOCOPY    NUMBER
  ,p_object_version_number         OUT NOCOPY    NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_in_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the address of a person.
 *
 * This API is effectively an alternative to the API update_person_address. If
 * p_validate is set to false, the address is updated. Address is updated as
 * identified by the in parameter p_address_id and the in out parameter
 * p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address as identified by the in parameter p_address_id and the in out
 * parameter p_object_version_number must already exist. The address_type
 * attribute can only be used after QuickCodes have been defined for the
 * 'ADDRESS_TYPE' lookup type.
 *
 * <p><b>Post Success</b><br>
 * Updates the address for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the address and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_address_id The primary key of the address.
 * @param p_object_version_number Pass in the current version number of the
 * person address to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated person address. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Person address comment text.
 * @param p_flat_door_block Flat/Door/Block of the address.
 * @param p_building_village Building/Village of the address.
 * @param p_road_street Road/Street of the address.
 * @param p_area_locality Area/Locality of the address.
 * @param p_town_or_city Town/City of the address.
 * @param p_state_ut State/UT of the address. If Address stye is India then the
 * valid values are defined by 'IN_STATES' lookup type.
 * @param p_pin_code Postal code of the address. If Address stye is India then
 * the first two digits must be valid for a state. Valid values are defined by
 * 'IN_PIN_CODES' lookup type.
 * @param p_country Country of the address. If Address stye is India then the
 * value will be India else wil get the valid values from FND_TERRITORIES
 * @param p_addr_attribute_category This context value determines which
 * flexfield structure to use with the Person Address descriptive flexfield
 * segments.
 * @param p_addr_attribute1 Descriptive flexfield segment.
 * @param p_addr_attribute2 Descriptive flexfield segment.
 * @param p_addr_attribute3 Descriptive flexfield segment.
 * @param p_addr_attribute4 Descriptive flexfield segment.
 * @param p_addr_attribute5 Descriptive flexfield segment.
 * @param p_addr_attribute6 Descriptive flexfield segment.
 * @param p_addr_attribute7 Descriptive flexfield segment.
 * @param p_addr_attribute8 Descriptive flexfield segment.
 * @param p_addr_attribute9 Descriptive flexfield segment.
 * @param p_addr_attribute10 Descriptive flexfield segment.
 * @param p_addr_attribute11 Descriptive flexfield segment.
 * @param p_addr_attribute12 Descriptive flexfield segment.
 * @param p_addr_attribute13 Descriptive flexfield segment.
 * @param p_addr_attribute14 Descriptive flexfield segment.
 * @param p_addr_attribute15 Descriptive flexfield segment.
 * @param p_addr_attribute16 Descriptive flexfield segment.
 * @param p_addr_attribute17 Descriptive flexfield segment.
 * @param p_addr_attribute18 Descriptive flexfield segment.
 * @param p_addr_attribute19 Descriptive flexfield segment.
 * @param p_addr_attribute20 Descriptive flexfield segment.
 * @rep:displayname Update Person Address for India
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_in_person_address
   (p_validate                      IN     BOOLEAN  DEFAULT FALSE
   ,p_effective_date                IN     DATE
   ,p_address_id                    IN     NUMBER
   ,p_object_version_number         IN OUT NOCOPY NUMBER
   ,p_date_from                     IN     DATE     DEFAULT hr_api.g_date
   ,p_date_to                       IN     DATE     DEFAULT hr_api.g_date
   ,p_address_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_comments                      IN     LONG     DEFAULT hr_api.g_varchar2
   ,p_flat_door_block               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_building_village              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_road_street                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_area_locality                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_town_or_city                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_state_ut                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_pin_code                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_country                       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute1               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute2               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute3               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute4               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute5               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute6               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute7               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute8               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute9               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute10              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute11              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute12              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute13              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute14              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute15              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute16              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute17              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute18              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute19              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute20              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   );

END hr_in_person_address_api ;


 

/
