--------------------------------------------------------
--  DDL for Package HR_HK_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HK_PERSON_ADDRESS_API" AUTHID CURRENT_USER AS
/* $Header: hrhkwrpa.pkh 120.1 2005/10/02 02:02:31 aroussel $ */
/*#
 * This package contains person address related APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Address for Hong Kong
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_hk_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address, for a particular person.
 *
 * This API calls the generic API create_person_address with the Hong Kong
 * specific value for address style.
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
 * Inserts a new address for the employee in the Hong Kong Address style.
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
 * @param p_person_id Identifies the person for whom you create the Address
 * record.
 * @param p_primary_flag {@rep:casecolumn PER_ADDRESSES.PRIMARY_FLAG}
 * @param p_date_from {@rep:casecolumn PER_ADDRESSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_ADDRESSES.DATE_TO}
 * @param p_address_type Indicates the Type of Address. Valid values are
 * defined by 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE1}
 * @param p_address_line2 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE2}
 * @param p_address_line3 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE3}
 * @param p_district {@rep:casecolumn PER_ADDRESSES.TOWN_OR_CITY}
 * @param p_area Indicates the Area of the person. Valid Values are defined by
 * 'HK_AREA_CODES' lookup type.
 * @param p_country {@rep:casecolumn PER_ADDRESSES.COUNTRY}
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
 * @param p_address_id If p_validate is false, uniquely identifies the address
 * created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Person. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Hong Kong
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_hk_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_pradd_ovlapval_override       IN     BOOLEAN  DEFAULT FALSE
  ,p_validate_county               IN     BOOLEAN  DEFAULT TRUE
  ,p_person_id                     IN     NUMBER
  ,p_primary_flag                  IN     VARCHAR2
  ,p_date_from                     IN     DATE
  ,p_date_to                       IN     DATE     DEFAULT NULL
  ,p_address_type                  IN     VARCHAR2 DEFAULT NULL
  ,p_comments                      IN     long DEFAULT NULL
  ,p_address_line1                 IN     VARCHAR2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT NULL
  ,p_address_line3                 IN     VARCHAR2 DEFAULT NULL
  ,p_district                      IN     VARCHAR2 DEFAULT NULL
  ,p_area                          IN     VARCHAR2 DEFAULT NULL
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
  ,p_address_id                       OUT NOCOPY NUMBER
  ,p_object_version_number            OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_hk_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the details of a persons address for Hong Kong.
 *
 * This API calls the generic API update_person_address with the Hong Kong
 * specific value for address style.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist and must be in the correct style.The
 * address_type attribute can only be used after QuickCodes have been defined
 * for the 'ADDRESS_TYPE' lookup type.
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
 * Person Address to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Person Address. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_date_from {@rep:casecolumn PER_ADDRESSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_ADDRESSES.DATE_TO}
 * @param p_address_type Indicates the Type of Address. Valid values are
 * defined by 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE1}
 * @param p_address_line2 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE2}
 * @param p_address_line3 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE3}
 * @param p_district {@rep:casecolumn PER_ADDRESSES.TOWN_OR_CITY}
 * @param p_area Indicates the Area of the person. Valid Values are defined by
 * 'HK_AREA_CODES' lookup type.
 * @param p_country {@rep:casecolumn PER_ADDRESSES.COUNTRY}
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
 * @rep:displayname Update Person Address for Hong Kong
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_hk_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_validate_county               IN     BOOLEAN  DEFAULT TRUE
  ,p_address_id                    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_date_from                     IN     DATE     DEFAULT hr_api.g_date
  ,p_date_to                       IN     DATE     DEFAULT hr_api.g_date
  ,p_address_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_comments                      IN     long DEFAULT hr_api.g_varchar2
  ,p_address_line1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_address_line3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_district                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_area                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
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
  );


END hr_hk_person_address_api;

 

/
