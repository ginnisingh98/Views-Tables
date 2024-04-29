--------------------------------------------------------
--  DDL for Package PER_CA_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CA_PERSON_ADDRESS_API" AUTHID CURRENT_USER as
/* $Header: peaddcai.pkh 120.1 2005/10/02 02:09:23 aroussel $ */
/*#
 * This package contains person address APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Address for Canada
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ca_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the address for the person.
 *
 * The person is identified by the in parameter p_person_id. This API calls the
 * generic API create_person_address, with the parameters set as appropriate
 * for a Canada style address. As this API is effectively an alternative to the
 * API create_person_address, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The Canada style address will be created for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API will not create the address and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pradd_ovlapval_override If true, the previous primary address will
 * have the end date populated. If false, primary address can have overlap
 * dates.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag {@rep:casecolumn PER_ADDRESSES.PRIMARY_FLAG}
 * @param p_date_from {@rep:casecolumn PER_ADDRESSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_ADDRESSES.DATE_TO}
 * @param p_address_type {@rep:casecolumn PER_ADDRESSES.ADDRESS_TYPE}
 * @param p_comments {@rep:casecolumn PER_ADDRESSES.COMMENTS}
 * @param p_address_line1 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE1}
 * @param p_address_line2 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE2}
 * @param p_address_line3 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE3}
 * @param p_city {@rep:casecolumn PER_ADDRESSES.TOWN_OR_CITY}
 * @param p_province Province or Territory.
 * @param p_postal_code Postal Code.
 * @param p_country {@rep:casecolumn PER_ADDRESSES.COUNTRY}
 * @param p_telephone_number_1 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_1}
 * @param p_telephone_number_2 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_2}
 * @param p_cma Census Metropolitan Area.
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
 * @param p_add_information17 Tax Address State.
 * @param p_add_information18 Tax Address City.
 * @param p_add_information19 Tax Address County.
 * @param p_add_information20 Tax Address Zip.
 * @param p_address_id If p_validate is false, uniquely identifies the address
 * created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Person Address for Canada
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ca_person_address
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
  ,p_province                      in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_country                       in     varchar2
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
  ,p_cma                           in     varchar2 default null
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
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ca_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the address.
 *
 * The address is identified by the in parameter p_address_id and the in out
 * parameter p_object_version_number. This API calls the generic API
 * update_person_address, with the parameters set as appropriate for a Canada
 * style address. As this API is effectively an alternative to the API
 * update_person_address, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must be in Canada style address. See API
 * update_person_address for further details.
 *
 * <p><b>Post Success</b><br>
 * The API will update the Canada style address.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the address and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_address_id The primary key of the address.
 * @param p_object_version_number Pass in the current version number of the
 * address to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated address. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_date_from {@rep:casecolumn PER_ADDRESSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_ADDRESSES.DATE_TO}
 * @param p_address_type {@rep:casecolumn PER_ADDRESSES.ADDRESS_TYPE}
 * @param p_comments {@rep:casecolumn PER_ADDRESSES.COMMENTS}
 * @param p_address_line1 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE1}
 * @param p_address_line2 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE2}
 * @param p_address_line3 {@rep:casecolumn PER_ADDRESSES.ADDRESS_LINE3}
 * @param p_city {@rep:casecolumn PER_ADDRESSES.TOWN_OR_CITY}
 * @param p_province Province or Territory.
 * @param p_postal_code Postal Code.
 * @param p_country {@rep:casecolumn PER_ADDRESSES.COUNTRY}
 * @param p_telephone_number_1 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_1}
 * @param p_telephone_number_2 {@rep:casecolumn
 * PER_ADDRESSES.TELEPHONE_NUMBER_2}
 * @param p_cma Census Metropolitan Area.
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
 * @param p_add_information17 Tax Address State.
 * @param p_add_information18 Tax Address City.
 * @param p_add_information19 Tax Address County.
 * @param p_add_information20 Tax Address Zip.
 * @rep:displayname Update Person Address for Canada
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ca_person_address
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
  ,p_province                      in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
  ,p_cma                           in     varchar2 default hr_api.g_varchar2
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
end per_ca_person_address_api;

 

/
