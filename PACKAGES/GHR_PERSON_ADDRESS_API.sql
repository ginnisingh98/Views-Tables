--------------------------------------------------------
--  DDL for Package GHR_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PERSON_ADDRESS_API" AUTHID CURRENT_USER as
/* $Header: ghaddapi.pkh 120.2 2005/10/02 01:56:09 aroussel $ */
/*#
 * This package contains person address APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Address
*/
--
-- Package Variables
--
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_us_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  Wrapper to hr_person_address_api.create_us_person_address. Sets the session variables
--  so that the ghr_pa_history table can then be populated to maintain history of the
--  address record
--
procedure create_us_person_address
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
  ,p_address_id                       out nocopy  number
  ,p_object_version_number            out nocopy  number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_us_int_person_address >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Address for a person.
 *
 * This API creates the United States International Address record in the
 * PER_ADDRESSES table. City, State and Zip Code values are not validated in
 * this address style.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The address is successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The address is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override Override overlapping primary address
 * validation. Valid values 'TRUE' or 'FALSE'
 * @param p_validate_county Validate the County information
 * @param p_person_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_ID}
 * @param p_primary_flag {@rep:casecolumn PER_ADDRESSES.PRIMARY_FLAG}
 * @param p_date_from Start date of the address
 * @param p_date_to End date of the address
 * @param p_address_type Type of Address. Valid Values are defined by
 * 'ADDRESS_TYPE' Lookup Type.
 * @param p_comments Comment text
 * @param p_address_line1 The first line of address
 * @param p_address_line2 The second line of address
 * @param p_address_line3 The third line of address
 * @param p_city City Name
 * @param p_state State Code
 * @param p_zip_code Zip code to identify a specific address in the country
 * @param p_county County
 * @param p_country Country
 * @param p_telephone_number_1 Telephone number for the address
 * @param p_telephone_number_2 Second telephone number for the address
 * @param p_addr_attribute_category Determines context of the Address
 * Descriptive Flexfield in parameters.
 * @param p_addr_attribute1 Descriptive flexfield
 * @param p_addr_attribute2 Descriptive flexfield
 * @param p_addr_attribute3 Descriptive flexfield
 * @param p_addr_attribute4 Descriptive flexfield
 * @param p_addr_attribute5 Descriptive flexfield
 * @param p_addr_attribute6 Descriptive flexfield
 * @param p_addr_attribute7 Descriptive flexfield
 * @param p_addr_attribute8 Descriptive flexfield
 * @param p_addr_attribute9 Descriptive flexfield
 * @param p_addr_attribute10 Descriptive flexfield
 * @param p_addr_attribute11 Descriptive flexfield
 * @param p_addr_attribute12 Descriptive flexfield
 * @param p_addr_attribute13 Descriptive flexfield
 * @param p_addr_attribute14 Descriptive flexfield
 * @param p_addr_attribute15 Descriptive flexfield
 * @param p_addr_attribute16 Descriptive flexfield
 * @param p_addr_attribute17 Descriptive flexfield
 * @param p_addr_attribute18 Descriptive flexfield
 * @param p_addr_attribute19 Descriptive flexfield
 * @param p_addr_attribute20 Descriptive flexfield
 * @param p_add_information13 Developer Descriptive flexfield segment.
 * @param p_add_information14 Developer Descriptive flexfield segment.
 * @param p_add_information15 Developer Descriptive flexfield segment.
 * @param p_add_information16 Developer Descriptive flexfield segment.
 * @param p_add_information17 Developer Descriptive flexfield segment.
 * @param p_add_information18 Developer Descriptive flexfield segment.
 * @param p_add_information19 Developer Descriptive flexfield segment.
 * @param p_add_information20 Developer Descriptive flexfield segment.
 * @param p_party_id Developer Descriptive flexfield segment.
 * @param p_address_id System-generated primary key column
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create United States International Person Address
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_us_int_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_pradd_ovlapval_override       in     boolean  default FALSE
  ,p_validate_county               in     boolean  default true
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
  ,p_address_id                       out nocopy  number
  ,p_object_version_number            out nocopy  number
  );
--

--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_us_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  Wrapper to hr_person_address_api.update_us_person_address. Sets the session variables
--  so that the ghr_pa_history table can then be populated to maintain history of the
--  address record

procedure update_us_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy  number
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
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_us_int_person_address >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the address for a person.
 *
 * This API updates the United States International Address record in the
 * PER_ADDRESSES table. City, State and Zip Code values are not validated in
 * this address style.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and address must exist on the effective date,
 *
 * <p><b>Post Success</b><br>
 * The address will be successfully updated
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate_county Validate the County information
 * @param p_address_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_ID}
 * @param p_object_version_number Pass in the current version number of the
 * Address to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated Address. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_date_from Start date at the address
 * @param p_date_to End date at the address
 * @param p_address_type Type of Address. Valid Values are defined by
 * 'ADDRESS_TYPE' Lookup Type.
 * @param p_comments Comment text.
 * @param p_address_line1 The first line of address
 * @param p_address_line2 The second line of address
 * @param p_address_line3 The third line of address
 * @param p_city City Name
 * @param p_state State Code
 * @param p_zip_code Zip code to identify a specific address in the country
 * @param p_county County
 * @param p_country Country
 * @param p_telephone_number_1 Telephone number for the address
 * @param p_telephone_number_2 Second telephone number for the address
 * @param p_addr_attribute_category Determines context of the Address
 * Descriptive Flexfield in parameters.
 * @param p_addr_attribute1 Descriptive flexfield
 * @param p_addr_attribute2 Descriptive flexfield
 * @param p_addr_attribute3 Descriptive flexfield
 * @param p_addr_attribute4 Descriptive flexfield
 * @param p_addr_attribute5 Descriptive flexfield
 * @param p_addr_attribute6 Descriptive flexfield
 * @param p_addr_attribute7 Descriptive flexfield
 * @param p_addr_attribute8 Descriptive flexfield
 * @param p_addr_attribute9 Descriptive flexfield
 * @param p_addr_attribute10 Descriptive flexfield
 * @param p_addr_attribute11 Descriptive flexfield
 * @param p_addr_attribute12 Descriptive flexfield
 * @param p_addr_attribute13 Descriptive flexfield
 * @param p_addr_attribute14 Descriptive flexfield
 * @param p_addr_attribute15 Descriptive flexfield
 * @param p_addr_attribute16 Descriptive flexfield
 * @param p_addr_attribute17 Descriptive flexfield
 * @param p_addr_attribute18 Descriptive flexfield
 * @param p_addr_attribute19 Descriptive flexfield
 * @param p_addr_attribute20 Descriptive flexfield
 * @param p_add_information13 Developer Descriptive flexfield segment.
 * @param p_add_information14 Developer Descriptive flexfield segment.
 * @param p_add_information15 Developer Descriptive flexfield segment.
 * @param p_add_information16 Developer Descriptive flexfield segment.
 * @param p_add_information17 Developer Descriptive flexfield segment.
 * @param p_add_information18 Developer Descriptive flexfield segment.
 * @param p_add_information19 Developer Descriptive flexfield segment.
 * @param p_add_information20 Developer Descriptive flexfield segment.
 * @rep:displayname Update United States International Person Address
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_us_int_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_validate_county               in     boolean  default true
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy  number
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
end ghr_person_address_api;

 

/
