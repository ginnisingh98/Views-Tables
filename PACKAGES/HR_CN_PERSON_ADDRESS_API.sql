--------------------------------------------------------
--  DDL for Package HR_CN_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CN_PERSON_ADDRESS_API" AUTHID CURRENT_USER AS
/* $Header: hrcnwrpa.pkh 120.3 2005/11/04 05:36:40 jcolman noship $ */
/*#
 * This package contains APIs for creation of personal addresses for China.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Address for China
*/
  g_trace boolean:=false;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_cn_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a person in business groups using the
 * legislation for China.
 *
 * This API calls the generic create_person_address API. It maps certain
 * columns to user-friendly names appropriate for China so as to ensure easy
 * identification. As this API is an alternative API, see the generic
 * create_person_address API for further explanation
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid person must exist on the start date of the address. The address_type
 * attribute can only be used after QuickCodes have been defined for the
 * 'ADDRESS_TYPE' lookup type. The business group of the person must belong to
 * Chinese legislation. See the corresponding generic API for further details.
 *
 * <p><b>Post Success</b><br>
 * The new address for the employee will be created
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person's address and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_pradd_ovlapval_override Indicates if there is an overlap in the
 * primary address details.
 * @param p_validate_county Validates the county details in the address. This
 * has a default of 'true'.
 * @param p_person_id Identifies the person for whom you create the Address
 * record.
 * @param p_primary_flag Primary Address. Valid values are defined by the
 * 'YES_NO' lookup type.
 * @param p_date_from {@rep:casecolumn PER_ADDRESSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_ADDRESSES.DATE_TO}
 * @param p_address_type Address type, for example, home, business, weekend.
 * Valid values are defined by the 'ADDRESS_TYPE' lookup type.
 * @param p_comments Address comment text
 * @param p_address_line1 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE1}
 * @param p_address_line2 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE2}
 * @param p_province_city_sar Province/City/SAR of the person's address. Valid
 * values are defined by the 'CN_PROVINCE' lookup type.
 * @param p_postal_code Postal Code. Maximum 6 digits
 * @param p_country Country details. Valid values are defined by the
 * 'NATIONALITY' lookup type
 * @param p_telephone {@rep:casecolumn PER_ADDRESSES.TELEPHONE_NUMBER_1}
 * @param p_fax {@rep:casecolumn PER_ADDRESSES.TELEPHONE_NUMBER_2}
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
 * @param p_add_information13 Obsolete parameter, do not use.
 * @param p_add_information14 Obsolete parameter, do not use.
 * @param p_add_information15 Obsolete parameter, do not use.
 * @param p_add_information16 Obsolete parameter, do not use.
 * @param p_add_information17 Obsolete parameter, do not use.
 * @param p_add_information18 Obsolete parameter, do not use.
 * @param p_add_information19 Obsolete parameter, do not use.
 * @param p_add_information20 Obsolete parameter, do not use.
 * @param p_party_id Party for whom the address --HR/TCA merge applies.
 * @param p_address_id If p_validate is false, this uniquely identifies the
 * address created. If p_validate is true, this is set to null.
 * @param p_object_version_number If p_validate is false, then this is set to
 * the version number of the created address. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Person Address for China
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_cn_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT   false
  ,p_effective_date                IN     DATE
  ,p_pradd_ovlapval_override       IN     BOOLEAN  DEFAULT   false
  ,p_validate_county               IN     BOOLEAN  DEFAULT   true
  ,p_person_id                     IN     NUMBER   DEFAULT   null
  ,p_primary_flag                  IN     VARCHAR2
  ,p_date_from                     IN     DATE
  ,p_date_to                       IN     DATE     DEFAULT   null
  ,p_address_type                  IN     VARCHAR2 DEFAULT   null
  ,p_comments                      IN     LONG     DEFAULT   null
  ,p_address_line1                 IN     VARCHAR2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT   null
  ,p_province_city_sar             IN     VARCHAR2
  ,p_postal_code                   IN     VARCHAR2 DEFAULT   null
  ,p_country                       IN     VARCHAR2
  ,p_telephone                     IN     VARCHAR2 DEFAULT   null
  ,p_fax                           IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute1               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute2               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute3               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute4               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute5               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute6               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute7               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute8               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute9               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute10              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute11              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute12              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute13              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute14              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute15              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute16              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute17              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute18              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute19              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute20              IN     VARCHAR2 DEFAULT   null
  ,p_add_information13             IN     VARCHAR2 DEFAULT   null
  ,p_add_information14             IN     VARCHAR2 DEFAULT   null
  ,p_add_information15             IN     VARCHAR2 DEFAULT   null
  ,p_add_information16             IN     VARCHAR2 DEFAULT   null
  ,p_add_information17             IN     VARCHAR2 DEFAULT   null
  ,p_add_information18             IN     VARCHAR2 DEFAULT   null
  ,p_add_information19             IN     VARCHAR2 DEFAULT   null
  ,p_add_information20             IN     VARCHAR2 DEFAULT   null
  ,p_party_id                      IN     NUMBER   DEFAULT   null
  ,p_address_id                    OUT    NOCOPY   NUMBER
  ,p_object_version_number         OUT    NOCOPY   NUMBER   );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cn_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the address details of a person in business groups using
 * the legislation for China.
 *
 * This API calls the generic update_person_address API. It maps certain
 * columns to user-friendly names appropriate for China so as to ensure easy
 * identification.As this API is an alternative API, see the generic
 * update_person_address API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must already exist. The address_type attribute can
 * only be used after QuickCodes have been defined for the 'ADDRESS_TYPE'
 * lookup type. The business group of the person must belong to Chinese
 * legislation. See the corresponding generic API for further details.
 *
 * <p><b>Post Success</b><br>
 * The address details of the person will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person's address and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_validate_county Validates the county details in the address. This
 * has a default value of 'true'.
 * @param p_address_id {@rep:casecolumn PER_ADDRESSES.ADDRESS_ID}
 * @param p_object_version_number This parameter passes in the current version
 * number of the address to be updated. When the API completes, if p_validate
 * is false, this will be set to the new version number of the updated address.
 * If p_validate is true, this will be set to the same value which was passed
 * in.
 * @param p_date_from {@rep:casecolumn PER_ADDRESSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_ADDRESSES.DATE_TO}
 * @param p_primary_flag The primary address for the person. Valid values are
 * defined by the 'YES_NO' lookup type.
 * @param p_address_type Address type, for example, home, business, weekend.
 * Valid values are defined by the 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment Text
 * @param p_address_line1 Address Line 1
 * @param p_address_line2 Address Line 2
 * @param p_province_city_sar Province/City/SAR. Valid values are defined by
 * the 'CN_PROVINCE' lookup type.
 * @param p_postal_code Postal Code. Maximum 6 digits
 * @param p_country Country details. Valid values are defined by the
 * 'NATIONALITY' lookup type
 * @param p_telephone Telephone Number
 * @param p_fax Fax Number
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
 * @param p_add_information13 Obsolete parameter, do not use.
 * @param p_add_information14 Obsolete parameter, do not use.
 * @param p_add_information15 Obsolete parameter, do not use.
 * @param p_add_information16 Obsolete parameter, do not use.
 * @param p_add_information17 Obsolete parameter, do not use.
 * @param p_add_information18 Obsolete parameter, do not use.
 * @param p_add_information19 Obsolete parameter, do not use.
 * @param p_add_information20 Obsolete parameter, do not use.
 * @param p_party_id Party for whom the address applies.
 * @rep:displayname Update Person Address for China
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 PROCEDURE update_cn_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT   false
  ,p_effective_date                IN     DATE
  ,p_validate_county               IN     BOOLEAN  DEFAULT   true
  ,p_address_id                    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY   NUMBER
  ,p_date_from                     IN     DATE     DEFAULT   hr_api.g_date
  ,p_date_to                       IN     DATE     DEFAULT   hr_api.g_date
  ,p_primary_flag                  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_address_type                  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_comments                      IN     LONG     DEFAULT   null
  ,p_address_line1                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_province_city_sar             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_postal_code                   IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_country                       IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_telephone                     IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_fax                           IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute1               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute2               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute3               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute4               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute5               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute6               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute7               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute8               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute9               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute10              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute11              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute12              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute13              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute14              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute15              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute16              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute17              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute18              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute19              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute20              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information13             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information14             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information15             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information16             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information17             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information18             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information19             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information20             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_party_id                      IN     NUMBER   DEFAULT   hr_api.g_number);

END hr_cn_person_address_api;

/
