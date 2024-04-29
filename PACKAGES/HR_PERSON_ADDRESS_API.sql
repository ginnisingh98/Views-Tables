--------------------------------------------------------
--  DDL for Package HR_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ADDRESS_API" AUTHID CURRENT_USER as
/* $Header: peaddapi.pkh 120.4.12010000.2 2009/10/01 07:19:46 pchowdav ship $ */
/*#
 * This package contains APIs that create and maintain address information for
 * a person.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Address
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person.
 *
 * An address record stores address information for current or ex-employees,
 * current or ex-applicants, and employee contacts. If the process is creating
 * the first address for the specified person, it must be the primary address.
 * As only one primary address can exist for a person at a given time,
 * subsequent addresses cannot be primary.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * A valid person (p_person_id) must exist on the start date (p_date_from) of
 * the address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_validate_county Set to false to allow a null value for United
 * States County field. Note: If you set the p_validate_county flag to FALSE
 * and do not enter a county, then the address will not be valid for United
 * States payroll processing.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_style Identifies the style of address (eg.'United Kingdom').
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type The type of address. Valid values are defined by the
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_town_or_city Town or city name.
 * @param p_region_1 Determined by p_style (eg. County for United Kingdom and
 * United States).
 * @param p_region_2 Determined by p_style (eg. State for United States).
 * @param p_region_3 Determined by p_style (eg. PO Box for Saudi Arabia).
 * @param p_postal_code Determined by p_style (eg. Postal code for United
 * Kingdom or Zip code for United States).
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  ,p_party_id                      in     number   default null -- HR/TCA merge
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_gb_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in the United Kingdom.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in the United Kingdom. As this API is effectively
 * an alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type The type of address.The address_type attribute can
 * only be used after QuickCodes have been defined for the 'ADDRESS_TYPE'
 * lookup type
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_town Name of the town, mapped to town_or_city.
 * @param p_county Name of the county, mapped to region_1. Valid values are
 * defined by the 'GB_COUNTY' lookup type.
 * @param p_postcode Postal code of the address.
 * @param p_country Name of the country.
 * @param p_telephone_number Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
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
 * @param p_party_id Party for which the address applies.
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for United Kingdom
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_us_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in the United States.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in the United States. As this API is effectively
 * an alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_validate_county Set to false to allow United States county to be
 * null. Please note. If you set the p_validate_county flag to FALSE and do not
 * enter a county then the address will not be valid for United States payroll
 * processing.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. The address_type attribute can only
 * be used after QuickCodes have been defined for the 'ADDRESS_TYPE' lookup
 * type.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_city Name of the city, mapped to town_or_city. The city is
 * mandatory if payroll is installed under US legislation.
 * @param p_state Name of the state, mapped to region_2. The state is mandatory
 * if payroll is installed under US legislation. Valid values are defined by
 * the 'US_STATE' lookup type.
 * @param p_zip_code Zip code of the adddress, mapped to postal_code. The zip
 * code is mandatory if payroll is installed under US legislation.
 * @param p_county Name of the county, mapped to region_1. The County is
 * mandatory if payroll is installed under US legislation
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
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
 * @param p_add_information17 Tax Address State.Valid values are defined by the
 * 'US_STATE' lookup type
 * @param p_add_information18 Tax Address City.
 * @param p_add_information19 Tax Address County.
 * @param p_add_information20 Tax Address Zip.
 * @param p_party_id Party for which the address (HR/TCA merge) applies.
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for United States
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_at_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Austria.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Austria. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the region, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Austria
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_au_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Australia.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Australia. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_state Name of the state, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_postal_code Postal code of the address.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Australia
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_dk_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Denmark.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Denmark. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Denmark
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_de_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Germany.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Germany. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the region, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Germany
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_it_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address style for a given person in Italy.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Italy. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_province Name of the province, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Italy
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_mx_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Mexico.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Mexico. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_state Name of the region, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Mexico
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  ,p_comments                      in     long default null
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
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_mx_loc_person_address >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person using the Mexico (Local)
 * address style.
 *
 * An address record stores address information for current or ex-employees,
 * current or ex-applicants, and employee contacts. If the process is creating
 * the first address for the specified person, it must be the primary address.
 * As only one primary address can exist for a person at a given time,
 * subsequent addresses cannot be primary. This API should be used only if you
 * wish to use the Mexico style. If you wish to create an address of
 * Mexico(International) Style - MX_GLB, you must use the
 * CREATE_MX_PERSON_ADDRESS procedure.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * A valid person must exist on the start date of the address.
 *
 * <p><b>Post Success</b><br>
 * The API creates Person Address in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the address and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the person
 * address record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_street_name_and_num Street Name and Number.
 * @param p_neighborhood Neighborhood.
 * @param p_municipality Municipality.
 * @param p_postal_code Postal Code.
 * @param p_city City.
 * @param p_state Mexican State.
 * @param p_country Name of the country.
 * @param p_telephone Telephone number.
 * @param p_fax Fax number.
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
 * @param p_add_information13 Developer descriptive flexfield segment.
 * @param p_add_information14 Developer descriptive flexfield segment.
 * @param p_add_information15 Developer descriptive flexfield segment.
 * @param p_add_information16 Developer descriptive flexfield segment.
 * @param p_add_information17 Obsolete parameter, do not use.
 * @param p_add_information18 Obsolete parameter, do not use.
 * @param p_add_information19 Obsolete parameter, do not use.
 * @param p_add_information20 Obsolete parameter, do not use.
 * @param p_party_id Party for whom the address (HR/TCA merge) applies.
 * @param p_address_id If p_validate is false, then it uniquely identifies the
 * address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created person address. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Local Mexican Person Address
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_my_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Malaysia.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Malaysia. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the state, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Malaysia
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pt_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Portugal.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Portugal. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Portugal
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_be_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Belgium.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Belgium. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Belgium
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_fi_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Finland.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Finland. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Finland
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_gr_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Greece.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Greece. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Greece
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_hk_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Hong Kong.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Hong Kong. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_district District.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ie_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Ireland.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Ireland. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_county Name of the city, mapped to town_or_city.
 * @param p_postal_code Postal code of the address.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Ireland
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_lu_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Luxembourg.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Luxembourg. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Luxembourg
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_nl_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in the Netherlands.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in the Netherlands. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the region, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Netherlands
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_sg_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Singapore.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Singapore. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_postal_code Postal code of the address.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Singapore
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_se_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Sweden.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Sweden. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Sweden
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_es_glb_person_address >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Spanish Style global address for a particular person.
 *
 * As this API is effectively an alternative to the API create_person_address,
 * see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The API creates Person Address in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the address and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Indicates if this is a primary or non-primary address.
 * Y or N.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment Text.
 * @param p_address_line1 Line 1 of address.
 * @param p_address_line2 Line 2 of address.
 * @param p_address_line3 Line 3 of address.
 * @param p_postal_code Postal Code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_province Name of the Spanish province, mapped to region_1
 * @param p_country Name of the Country.
 * @param p_telephone Telephone number for the address.
 * @param p_telephone2 Second Telephone number for the address.
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
 * @param p_address_id If p_validate is false, uniquely identifies the address
 * created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Global Spanish Address for a Person.
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  ,p_comments                      in     long default null
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_es_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Spain.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Spain. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_date_from The date from which this address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_location_type Type of the location, mapped to address_line_1.
 * @param p_location_name Name of the location, mapped to address_line_2.
 * @param p_location_number Number of the location, mapped to address_line_3.
 * @param p_postal_code Postal Code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_province_name Name of the province, mapped to region_2.
 * @param p_country Name of the country.
 * @param p_telephone Telephone number for the address.
 * @param p_telephone2 Second Telephone number for the address.
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
 * @param p_building Name of the building, mapped to add_information_13
 * @param p_stairs Stair number, mapped to add_information_14
 * @param p_floor Floor number, mapped to add_information_15
 * @param p_door Door number, mapped to add_information_16
 * @param p_add_information17 Obsolete parameter, do not use.
 * @param p_add_information18 Obsolete parameter, do not use.
 * @param p_add_information19 Obsolete parameter, do not use.
 * @param p_add_information20 Obsolete parameter, do not use.
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Spain
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure create_ES_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default false
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
  ,p_add_information17             in     varchar2 default null
  ,p_add_information18             in     varchar2 default null
  ,p_add_information19             in     varchar2 default null
  ,p_add_information20             in     varchar2 default null
  ,p_address_id                    out    nocopy number
  ,p_object_version_number         out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_sa_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address for a given person in Saudi Arabia.
 *
 * It calls the generic API create_person_address, with the parameters set as
 * appropriate for an address in Saudi Arabia. As this API is effectively an
 * alternative to the API create_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Identifies the primary address.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_street Name of the street, mapped to region_1
 * @param p_area Name of the area, mapped to region_2
 * @param p_po_box PO BOX identifier, mapped to region_3
 * @param p_postal_code Postal code of the address.
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
 * @rep:displayname Create Person Address for Saudi Arabia
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a particular address for a given person.
 *
 * An address record stores address information for current or ex-employees,
 * current or ex-applicants, and employee contacts. If the process is creating
 * the first address for the specified person, it must be the primary address.
 * As only one primary address can exist for a person at a given time,
 * subsequent addresses cannot be primary.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The address must exist for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate_county Set to false to allow a null value for United
 * States County field. Note: If you set the p_validate_county flag to FALSE
 * and do not enter a county, then the address will not be valid for United
 * States payroll processing.
 * @param p_address_id This uniquely identifies the address.
 * @param p_object_version_number Pass in the current version number of the
 * address to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated address. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_address_type The type of address. Valid values are defined by the
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_town_or_city Town or city name.
 * @param p_region_1 Determined by p_style (eg. County for United Kingdom and
 * United States).
 * @param p_region_2 Determined by p_style (eg. State for United States).
 * @param p_region_3 Determined by p_style (eg. PO Box for Saudi Arabia).
 * @param p_postal_code Determined by p_style (eg. Postcode for United Kingdom
 * or zip code for United States).
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_add_information17 Tax Address State, only apply to United States
 * address style. Valid values are defined by the 'US_STATE' lookup type.
 * @param p_add_information18 Tax Address City, only apply to United States
 * address style.
 * @param p_add_information19 Tax Address County, only apply to United States
 * address style.
 * @param p_add_information20 Tax Address Zip, only apply to United States
 * address style.
 * @param p_party_id Party for whom the address applies.
 * @rep:displayname Update Person Address
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  ,p_primary_flag		   in     varchar2 default hr_api.g_varchar2
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
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_pers_addr_with_style >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a particular address for a given person.
 *
 * An address record stores address information for current or ex-employees,
 * current or ex-applicants, and employee contacts. Only one primary address
 * can exist for a person at a given time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address must exist for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate_county Set to false to allow a null value for United
 * States County field. Note: If you set the p_validate_county flag to FALSE
 * and do not enter a county, then the address will not be valid for United
 * States payroll processing.
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
 * @param p_town_or_city Town or city name.
 * @param p_region_1 Determined by p_style (eg. County for United Kingdom and
 * United States).
 * @param p_region_2 Determined by p_style (eg. State for United States).
 * @param p_region_3 Determined by p_style (eg. PO Box for Saudi Arabia).
 * @param p_postal_code Determined by p_style (eg. Postcode for United Kingdom
 * or zip code for United States).
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_add_information17 Tax Address State, only apply to United States
 * address style. Valid values are defined by the 'US_STATE' lookup type.
 * @param p_add_information18 Tax Address City, only apply to United States
 * address style.
 * @param p_add_information19 Tax Address County, only apply to United States
 * address style.
 * @param p_add_information20 Tax Address Zip, only apply to United States
 * address style.
 * @param p_party_id Party for whom the address applies.
 * @param p_style Address style.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @rep:displayname Update Person Address with Style
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
-- Start of fix part2 for Bug #2431588
  ,p_primary_flag		   in     varchar2 default hr_api.g_varchar2
-- End of fix for part2 Bug #2431588
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_gb_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in the United Kingdom.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in the United Kingdom. As this API is effectively
 * an alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in the United Kingdom for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_town Name of the town, mapped to town_or_city.
 * @param p_county Name of the county, mapped to region_1. Valid values are
 * defined by the 'GB_COUNTY' lookup type.
 * @param p_postcode Postal code of the address.
 * @param p_country Name of the country.
 * @param p_telephone_number Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
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
 * @rep:displayname Update Person Address for United Kingdom
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  ,p_add_information13             in     varchar2 default hr_api.g_varchar2
  ,p_add_information14             in     varchar2 default hr_api.g_varchar2
  ,p_add_information15             in     varchar2 default hr_api.g_varchar2
  ,p_add_information16             in     varchar2 default hr_api.g_varchar2
  ,p_add_information17             in     varchar2 default hr_api.g_varchar2
  ,p_add_information18             in     varchar2 default hr_api.g_varchar2
  ,p_add_information19             in     varchar2 default hr_api.g_varchar2
  ,p_add_information20             in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_us_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in the United States.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in the United States. As this API is effectively
 * an alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in the United States for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate_county Set to false to allow a null value for United
 * States County field. Note: If you set the p_validate_county flag to FALSE
 * and do not enter a county, then the address will not be valid for United
 * States payroll processing.
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
 * @param p_city Name of the city, mapped to town_or_city. The city is
 * mandatory if payroll is installed under US legislation.
 * @param p_state Name of the state, mapped to region_2. The state is mandatory
 * if payroll is installed under US legislation. Valid values are defined by
 * the 'US_STATE' lookup type.
 * @param p_zip_code Zip code of the address, mapped to postal_code. The zip
 * code is mandatory if payroll is installed under US legislation.
 * @param p_county Name of the county, mapped to region_1. The County is
 * mandatory if payroll is installed under US legislation
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
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
 * @param p_add_information17 Tax Address State.Valid values are defined by the
 * 'US_STATE' lookup type.
 * @param p_add_information18 Tax Address City.
 * @param p_add_information19 Tax Address County.
 * @param p_add_information20 Tax Address Zip.
 * @rep:displayname Update Person Address for United States
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_at_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Austria.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Austria. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Austria for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the region, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Austria
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_AT_person_address
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_au_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Australia.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Australia. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Australia for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_state Name of the state, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_postal_code Postal code of the address.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Australia
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_AU_person_address
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_dk_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Denmark.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Denmark. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Denmark for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Denmark
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_DK_person_address
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_de_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Germany.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Germany. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Germany for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the region, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Germany
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_it_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Italy.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Italy. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Italy for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the province, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Italy
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_mx_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Mexico.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Mexico. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Mexico for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_state Name of the state, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Mexico
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_mx_loc_person_address >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a particular person address of Mexico (Local) style.
 *
 * An address record stores address information for current or ex-employees,
 * current or ex-applicants, and employee contacts. If the process is creating
 * the first address for the specified person, it must be the primary address.
 * As only one primary address can exist for a person at a given time,
 * subsequent addresses cannot be primary.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The address must exist for the person.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Person Address in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the address and raises an error.
 *
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
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_address_type The type of address. Valid values are defined by the
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_street_name_and_num Street Name and Number
 * @param p_neighborhood Neighborhood.
 * @param p_municipality Municipality.
 * @param p_postal_code Postal Code.
 * @param p_city City.
 * @param p_state Mexican State.
 * @param p_country Name of the country.
 * @param p_telephone Telephone number.
 * @param p_fax Fax number.
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
 * @param p_add_information17 Obsolete parameter, do not use.
 * @param p_add_information18 Obsolete parameter, do not use.
 * @param p_add_information19 Obsolete parameter, do not use.
 * @param p_add_information20 Obsolete parameter, do not use.
 * @param p_party_id Party for whom the address (HR/TCA merge) applies.
 * @rep:displayname Update Local Mexican Person Address
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
 ) ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_my_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Malaysia.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Malaysia. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Malasia for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the State.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Malaysia
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pt_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Portugal.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Portugal. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Portugal for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Portugal
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_be_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Belgium.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Belgium. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Belgium for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Belgium
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_fi_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Finland.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Finland. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Finland for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Finland
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_gr_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Greece.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Greece. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Greece for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Greece
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_hk_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Hong Kong.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Hong Kong. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Hong Kong for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_district Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ie_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Ireland.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Irelend. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Ireland for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_county Name of the county, mapped to region_1.
 * @param p_postal_code Postal code of the address.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Ireland
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_lu_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Luxembourg.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Luxembourg. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Luxembourg for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Luxembourg
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_nl_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in the Netherlands.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in the Netherlands. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in the Netherlands for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_region Name of the region, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Netherlands
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_sg_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Singapore.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Singapore. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Singapore for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_postal_code Postal code of the address.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Singapore
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_se_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Sweden.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Sweden. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Sweden for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_postal_code Postal code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @rep:displayname Update Person Address for Sweden
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_es_glb_person_address >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Global Spanish Style address for a particular person.
 *
 * This API calls the generic API update_person_address, with the parameters
 * set as appropriate for an address in Spain. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation. This API updates the addresses of people as identified by the
 * in parameter p_address_id and the in out parameter p_object_version_number,
 * using the style ES_GLB.
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
 * The API creates Person Address in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the address and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_address_id The primary key of the address.
 * @param p_object_version_number Pass in the current version number of the
 * Address to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated Address. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Comment text.
 * @param p_address_line1 Line 1 of address.
 * @param p_address_line2 Line 2 of address.
 * @param p_address_line3 Line 3 of address.
 * @param p_postal_code Postal code of address.
 * @param p_city Name of the city, mapped to town_or_city
 * @param p_province Name of the Spanish province, mapped to region_1.
 * @param p_country Name of the country.
 * @param p_telephone Telephone number for the address.
 * @param p_telephone2 Secondary Telephone number for the address.
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
 * @rep:displayname Update Global Spanish Address for a Person.
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_es_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Spain.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Spain. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in Spain for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_location_type Type of the location, mapped to address_line_1.
 * @param p_location_name Name of the location, mapped to address_line_2.
 * @param p_location_number Number of the location, mapped to address_line_3.
 * @param p_postal_code Postal Code of the address.
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_province_name Name of the province, mapped to region_2.
 * @param p_country Name of the country.
 * @param p_telephone Telephone number for the address.
 * @param p_telephone2 Second Telephone number for the address.
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
 * @param p_building Name of the building, mapped to add_information_13
 * @param p_stairs Stair number, mapped to add_information_14
 * @param p_floor Floor number, mapped to add_information_15
 * @param p_door Door number, mapped to add_information_16
 * @param p_add_information17 Obsolete parameter, do not use.
 * @param p_add_information18 Obsolete parameter, do not use.
 * @param p_add_information19 Obsolete parameter, do not use.
 * @param p_add_information20 Obsolete parameter, do not use.
 * @rep:displayname Update Person Address for Spain
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_sa_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an address for a given person in Saudi Arabia.
 *
 * It calls the generic API update_person_address, with the parameters set as
 * appropriate for an address in Saudi Arabia. As this API is effectively an
 * alternative to the API update_person_address, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist in saudi Arabia for the person.
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_city Name of the city, mapped to town_or_city.
 * @param p_street Name of the street, mapped to region_1
 * @param p_area Name of the area, mapped to region_2
 * @param p_po_box PO BOX identifier, mapped to region_3
 * @param p_postal_code Postal code of the address.
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
 * @rep:displayname Update Person Address for Saudi Arabia
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< cre_or_upd_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new address or updates an existing address for a given
 * person.
 *
 * If the process is creating the first address for the specified person, it
 * must be the primary address. As only one primary address can exist for a
 * person at a given time, subsequent addresses cannot be primary. Setting
 * p_update_mode to CORRECTION will correct an existing record. Setting it to
 * UPDATE will end the existing address as of the effective date and insert a
 * new address.
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
 * When the address is valid, if p_update_mode is set to CORRECTION, then API
 * will correct the existing record. if p_update_mode is set to UPDATE, then
 * API will end the existing address as of the effective date and insert a new
 * address.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the address and raises an error.
 * @param p_update_mode Sets the pseudo-date track mode.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number When the process creates a new address, if
 * p_validate is false, then the process sets to the version number of the
 * created address. If p_validate is true, then the value will be null. For
 * updating existing address, pass in the current version number of the address
 * to be updated. When the API completes if p_validate is false, will be set to
 * the new version number of the updated address. If p_validate is true will be
 * set to the same value which was passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Set to true to override the existing
 * primary address.
 * @param p_validate_county Set to false to allow a null value for United
 * States County field. Note: If you set the p_validate_county flag to FALSE
 * and do not enter a county, then the address will not be valid for United
 * States payroll processing.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_business_group_id Business group of person associated with the
 * address.
 * @param p_primary_flag Flag specifying if this is a primary address. Valid
 * values are 'Y' or 'N'.
 * @param p_style Identifies the style of address (eg.'United Kingdom').
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of the address.
 * @param p_address_line2 The second line of the address.
 * @param p_address_line3 The third line of the address.
 * @param p_town_or_city Town or city name.
 * @param p_region_1 Determined by p_style (eg. County for United Kingdom and
 * United States).
 * @param p_region_2 Determined by p_style (eg. State for United States)
 * @param p_region_3 Determined by p_style (eg. PO Box for Saudi Arabia).
 * @param p_postal_code Determined by p_style (eg. Postcode for United Kingdom
 * or Zip code for United States).
 * @param p_country Name of the country.
 * @param p_telephone_number_1 Telephone number for the address.
 * @param p_telephone_number_2 Second telephone number for the address.
 * @param p_telephone_number_3 Third telephone number for the address.
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
 * @param p_add_information17 Tax Address State, only apply to United States
 * address style. Valid values are defined by the 'US_STATE' lookup type.
 * @param p_add_information18 Tax Address City, only apply to United States
 * address style.
 * @param p_add_information19 Tax Address County, only apply to United States
 * address style.
 * @param p_add_information20 Tax Address Zip, only apply to United States
 * address style.
 * @param p_party_id Party for whom the address applies.
 * @rep:displayname Create or Update Person Address
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  );
--
end hr_person_address_api;

/
