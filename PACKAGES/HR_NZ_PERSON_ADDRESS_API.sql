--------------------------------------------------------
--  DDL for Package HR_NZ_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NZ_PERSON_ADDRESS_API" AUTHID CURRENT_USER AS
/* $Header: hrnzwrpa.pkh 120.3 2005/10/17 07:22:00 rpalli noship $ */
/*#
 * This package contains person address related APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Address for New Zealand
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_nz_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address, for a particular person.
 *
 * This API calls the generic API create_person_address with the New Zealand
 * specific value for the address style.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid person must exist on the start date of the address. The address_type
 * attribute can only be used after QuickCodes have been defined for the
 * 'ADDRESS_TYPE' lookup type.
 *
 * <p><b>Post Success</b><br>
 * Inserts a new address for the employee in the New Zealand Address style.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the address and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_pradd_ovlapval_override Indicates and validates if there is a
 * primary address overlap.
 * @param p_validate_county Validate county details in the address. Set to true
 * by default.
 * @param p_person_id Identifies the person record to modify.
 * @param p_primary_flag {@rep:casecolumn PER_ADDRESSES.PRIMARY_FLAG}
 * @param p_date_from {@rep:casecolumn PER_ADDRESSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_ADDRESSES.DATE_TO}
 * @param p_address_type Indicates the Type of Address. Valid values are
 * defined by 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE1}
 * @param p_address_line2 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE2}
 * @param p_address_line3 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE3}
 * @param p_town_or_city {@rep:casecolumn PER_ADDRESSES.TOWN_OR_CITY}
 * @param p_region_1 Determined by p_style (eg. County for United Kingdom and
 * United States).
 * @param p_region_2 Determined by p_style (eg. State for United States).
 * @param p_region_3 Determined by p_style (eg. PO Box for Saudi Arabia).
 * @param p_postcode {@rep:casecolumn PER_ADDRESSES.POSTAL_CODE}
 * @param p_country Indicates which country the person was born. Valid values
 * as applicable are defined by 'NATIONALITY' lookup type.
 * @param p_telephone_number_1 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_1}
 * @param p_telephone_number_2 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_2}
 * @param p_telephone_number_3 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_3}
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
 * @param p_add_information13 Descriptive flexfield segment.
 * @param p_add_information14 Descriptive flexfield segment.
 * @param p_add_information15 Descriptive flexfield segment.
 * @param p_add_information16 Descriptive flexfield segment.
 * @param p_add_information17 Tax Address State, only applies to United States
 * address style. Valid values are defined by the 'US_STATE' lookup type.
 * @param p_add_information18 Tax Address City, only applies to United States
 * address style.
 * @param p_add_information19 Tax Address County, only applies to United States
 * address style.
 * @param p_add_information20 Tax Address Zip, only applies to United States
 * address style.
 * @param p_party_id Party for whom the address (HR/TCA merge) applies.
 * @param p_address_id If p_validate is false, uniquely identifies the address
 * created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created person address. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Person Address for New Zealand
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_nz_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_pradd_ovlapval_override       IN     BOOLEAN  DEFAULT FALSE
  ,p_validate_county               IN     BOOLEAN  DEFAULT TRUE
  ,p_person_id                     IN     NUMBER
  ,p_primary_flag                  IN     VARCHAR2
  ,p_date_from                     IN     DATE
  ,p_date_to                       IN     DATE     DEFAULT NULL
  ,p_address_type                  IN     VARCHAR2 DEFAULT NULL
  ,p_comments                      IN     LONG 	   DEFAULT NULL
  ,p_address_line1                 IN     VARCHAR2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT NULL
  ,p_address_line3                 IN     VARCHAR2 DEFAULT NULL
  ,p_town_or_city                  IN     VARCHAR2 DEFAULT NULL
  ,p_region_1                      IN     VARCHAR2 DEFAULT NULL
  ,p_region_2                      IN     VARCHAR2 DEFAULT NULL
  ,p_region_3                      IN     VARCHAR2 DEFAULT NULL
  ,p_postcode                      IN     VARCHAR2 DEFAULT NULL
  ,p_country                       IN     VARCHAR2
  ,p_telephone_number_1            IN     VARCHAR2 DEFAULT NULL
  ,p_telephone_number_2            IN     VARCHAR2 DEFAULT NULL
  ,p_telephone_number_3            IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute1               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute2               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute3               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute4               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute5               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute6               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute7               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute8               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute9               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute10              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute11              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute12              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute13              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute14              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute15              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute16              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute17              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute18              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute19              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute20              IN     VARCHAR2 DEFAULT NULL
  ,p_add_information13             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information14             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information15             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information16             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information17             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information18             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information19             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information20             IN     VARCHAR2 DEFAULT NULL
  ,p_party_id                      IN     NUMBER   DEFAULT NULL
  ,p_address_id                       OUT NOCOPY NUMBER
  ,p_object_version_number            OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_nz_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the details of a persons address for New Zealand.
 *
 * This API calls the generic API update_person_address with the New Zealand
 * specific value for address style.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist and must be in the correct style.
 *
 * <p><b>Post Success</b><br>
 * Updates the details if the address is valid.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the address and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_validate_county Validate county details in the address. Set to true
 * by default.
 * @param p_address_id {@rep:casecolumn PER_ADDRESSES.ADDRESS_ID}
 * @param p_object_version_number Pass in the current version number of the
 * person address to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated person address. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_date_from {@rep:casecolumn PER_ADDRESSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_ADDRESSES.DATE_TO}
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_address_type Indicates the Type of Address. Valid values are
 * defined by 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE1}
 * @param p_address_line2 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE2}
 * @param p_address_line3 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE3}
 * @param p_town_or_city {@rep:casecolumn PER_ADDRESSES.TOWN_OR_CITY}
 * @param p_region_1 Determined by p_style (eg. County for United Kingdom and
 * United States).
 * @param p_region_2 Determined by p_style (eg. State for United States).
 * @param p_region_3 Determined by p_style (eg. PO Box for Saudi Arabia).
 * @param p_postcode {@rep:casecolumn PER_ADDRESSES.POSTAL_CODE}
 * @param p_country Indicates which country the person was born. Valid values
 * as applicable are defined by 'NATIONALITY' lookup type.
 * @param p_telephone_number_1 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_1}
 * @param p_telephone_number_2 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_2}
 * @param p_telephone_number_3 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_3}
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
 * @param p_add_information13 Descriptive flexfield segment.
 * @param p_add_information14 Descriptive flexfield segment.
 * @param p_add_information15 Descriptive flexfield segment.
 * @param p_add_information16 Descriptive flexfield segment.
 * @param p_add_information17 Tax Address State, only applies to United States
 * address style. Valid values are defined by the 'US_STATE' lookup type.
 * @param p_add_information18 Tax Address City, only applies to United States
 * address style.
 * @param p_add_information19 Tax Address County, only applies to United States
 * address style.
 * @param p_add_information20 Tax Address Zip, only applies to United States
 * address style.
 * @param p_party_id Party for whom the address (HR/TCA merge) applies.
 * @rep:displayname Update Person Address for New Zealand
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE update_nz_person_address
    (p_validate                      IN     BOOLEAN  DEFAULT FALSE
    ,p_effective_date                IN     DATE
    ,p_validate_county               IN     BOOLEAN  DEFAULT TRUE
    ,p_address_id                    IN     NUMBER
    ,p_object_version_number         IN OUT NOCOPY NUMBER
    ,p_date_from                     IN     DATE     DEFAULT hr_api.g_date
    ,p_date_to                       IN     DATE     DEFAULT hr_api.g_date
    ,p_primary_flag                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_address_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_comments                      IN     LONG 	 DEFAULT hr_api.g_varchar2
    ,p_address_line1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_address_line2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_address_line3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_town_or_city                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_region_1                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_region_2                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_region_3                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_postcode                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_country                       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_telephone_number_1            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_telephone_number_2            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_telephone_number_3            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
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
    ,p_add_information13             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_add_information14             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_add_information15             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_add_information16             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_add_information17             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_add_information18             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_add_information19             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_add_information20             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_party_id                      IN     NUMBER   DEFAULT hr_api.g_number
  );

END hr_nz_person_address_api;

 

/
