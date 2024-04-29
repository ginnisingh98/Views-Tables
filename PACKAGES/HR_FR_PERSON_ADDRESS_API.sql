--------------------------------------------------------
--  DDL for Package HR_FR_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_PERSON_ADDRESS_API" AUTHID CURRENT_USER as
/* $Header: peaddfri.pkh 120.1 2005/10/02 02:09:30 aroussel $ */
/*#
 * This package contains address APIs for France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Address for France
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_fr_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an address for a person with an address style for France.
 *
 * As this API is effectively an alternative to the API create_person_address,
 * see create_person_address API for further details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person (p_person_id) must exist.
 *
 * <p><b>Post Success</b><br>
 * The address is successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the address and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type The type of address. Valid values are defined by the
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_insee_code INSEE code
 * @param p_small_town Small town
 * @param p_postal_code Postal code
 * @param p_city City
 * @param p_department Department. Valid values exist in the 'FR_DEPARTMENT'
 * lookup type.
 * @param p_country Name of the country.
 * @param p_telephone First telephone number of the person.
 * @param p_telephone2 Second telephone number of the person.
 * @param p_telephone3 Third telephone number of the person.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for France
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_fr_person_address
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
  ,p_insee_code                    in     varchar2 default null
  ,p_small_town                    in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_department                    in     varchar2 default null
  ,p_country                       in     varchar2 default null
  ,p_telephone                     in     varchar2 default null
  ,p_telephone2                    in     varchar2 default null
  ,p_telephone3                    in     varchar2 default null
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_fr_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a person's address record for France.
 *
 * This API updates the addresses of people as identified by the in parameter
 * p_address_id and the in out parameter p_object_version_number, using the
 * French style. This API calls the generic API update_person_address with the
 * applicable parameters for a particular address style.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist and is in the correct style. The
 * address_type attribute can only be used after QuickCodes have been defined
 * for the 'ADDRESS_TYPE' lookup type.
 *
 * <p><b>Post Success</b><br>
 * The address is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the address and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_address_id This uniquely identifies the address.
 * @param p_object_version_number Pass in the current version number of the
 * address to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated address. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type The type of address. Valid values are defined by the
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_insee_code INSEE code
 * @param p_small_town Small town
 * @param p_postal_code Postal code
 * @param p_department Department. Valid values exist in the 'FR_DEPARTMENT'
 * lookup type.
 * @param p_city City
 * @param p_country Name of the country.
 * @param p_telephone First telephone number of the person.
 * @param p_telephone2 Second telephone number of the person.
 * @param p_telephone3 Third telephone number of the person.
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
 * @rep:displayname Update Person Address for France
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_fr_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_insee_code                    in     varchar2 default hr_api.g_varchar2
  ,p_small_town                    in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_department                    in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone                     in     varchar2 default hr_api.g_varchar2
  ,p_telephone2                    in     varchar2 default hr_api.g_varchar2
  ,p_telephone3                    in     varchar2 default hr_api.g_varchar2
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
  );
--
end hr_fr_person_address_api;

 

/
