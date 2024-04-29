--------------------------------------------------------
--  DDL for Package HR_AE_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AE_PERSON_ADDRESS_API" AUTHID CURRENT_USER as
/* $Header: peaddaei.pkh 120.3.12010000.1 2008/07/28 04:02:10 appldev ship $ */
/*#
 * This package contains Address APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Address for UAE
*/
--
--
  -- ----------------------------------------------------------------------------
  -- |-------------------------< create_ae_person_address >---------------------|
  -- ----------------------------------------------------------------------------
  --
-- {Start Of Comments}
/*#
 * This API creates UAE Address for a particular person.
 * As this API is effectively an alternative to the API  see that API for
 * further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  See API create_person_address.
 *
 * <p><b>Post Success</b><br>
 * The API creates a valid person address.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the address and raises an error.
 *
 * @param p_validate If true, the database remains unchanged. If false,
 * the address is created.
 * @param p_effective_date Effective date.
 * @param p_person_id Person for whom the address applies.
 * @param p_primary_flag Identifies the primary address.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comments.
 * @param p_address_line1 Address Line1.
 * @param p_address_line2 Address Line2.
 * @param p_emirate Emirate.
 * @param p_city_village City or Village.
 * @param p_region_area Region or Area.
 * @param p_street Street.
 * @param p_building Building.
 * @param p_flat_number Flat Number.
 * @param p_po_box PO Box.
 * @param p_country Country.
 * @param p_addr_attribute_category Determines context of the
 * addr_attribute Descriptive flexfield in parameters.
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
 * @param p_party_id Party for whom the address applies.
 * @param p_address_id If p_validate is false, uniquely identifies the address
 * created.If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, set to
 * the version number of this address. If p_validate is true, set to null.
 * @rep:displayname Create Person Address for UAE
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--


PROCEDURE create_ae_person_address
  (
   p_validate                   in     boolean  default false
  ,p_effective_date             in     date
  ,p_person_id                  in     number
  ,p_primary_flag               in     varchar2
  ,p_date_from                  in     date
  ,p_date_to                    in     date     default null
  ,p_address_type               in     varchar2 default null
  ,p_comments                   in     long     default null
  ,p_address_line1              in     varchar2
  ,p_address_line2              in     varchar2 default null
  ,p_emirate                    in     varchar2
  ,p_city_village               in     varchar2 default null
  ,p_region_area                in     varchar2 default null
  ,p_street                     in     varchar2 default null
  ,p_building                   in     varchar2 default null
  ,p_flat_number                in     varchar2 default null
  ,p_po_box                     in     varchar2 default null
  ,p_country                    in     varchar2 default null
  ,p_addr_attribute_category    in     varchar2 default null
  ,p_addr_attribute1            in     varchar2 default null
  ,p_addr_attribute2            in     varchar2 default null
  ,p_addr_attribute3            in     varchar2 default null
  ,p_addr_attribute4            in     varchar2 default null
  ,p_addr_attribute5            in     varchar2 default null
  ,p_addr_attribute6            in     varchar2 default null
  ,p_addr_attribute7            in     varchar2 default null
  ,p_addr_attribute8            in     varchar2 default null
  ,p_addr_attribute9            in     varchar2 default null
  ,p_addr_attribute10           in     varchar2 default null
  ,p_addr_attribute11           in     varchar2 default null
  ,p_addr_attribute12           in     varchar2 default null
  ,p_addr_attribute13           in     varchar2 default null
  ,p_addr_attribute14           in     varchar2 default null
  ,p_addr_attribute15           in     varchar2 default null
  ,p_addr_attribute16           in     varchar2 default null
  ,p_addr_attribute17           in     varchar2 default null
  ,p_addr_attribute18           in     varchar2 default null
  ,p_addr_attribute19           in     varchar2 default null
  ,p_addr_attribute20           in     varchar2 default null
  ,p_party_id                   in     number   default null
  ,p_address_id                 out nocopy number
  ,p_object_version_number      out nocopy number
 );



--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ae_person_address >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API updates the addresses of people as identified by the in
 * parameter p_address_id and the in out parameter p_object_version_number,
 * using the UAE style.
 * This API calls the generic API update_person_address with the
 * applicable parameters for a particular address style.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist and is in the correct style.
 *
 * The address_type attribute can only be used after QuickCodes have been
 * defined for the 'ADDRESS_TYPE' lookup type.
 *
 * <p><b>Post Success</b><br>
 * The Address will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the address and raises an error.
 *
 * @param p_validate If true, the database remains unchanged. If false,
 * the address is created.
 * @param p_effective_date The effective date.
 * @param p_address_id The primary key of the Address.
 * @param p_object_version_number The current version of the address to be updated.
 * @param p_primary_flag Identifies the primary address.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address.
 * @param p_comments Comments
 * @param p_address_line1 Address Line1.
 * @param p_address_line2 Address Line2.
 * @param p_emirate Emirate.
 * @param p_city_village City or Village.
 * @param p_region_area Region or Area.
 * @param p_street Street.
 * @param p_building Building.
 * @param p_flat_number Flat Number.
 * @param p_po_box PO Box.
 * @param p_country Country.
 * @param p_addr_attribute_category Determines context of the
 * addr_attribute Descriptive flexfield in parameters.
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
 * @param p_party_id Party for whom the address applies.
 * @rep:displayname Update Address for UAE person.
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle deprecated
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--



PROCEDURE update_ae_person_address
  (
   p_validate                   in     boolean  default false
  ,p_effective_date             in     date
  ,p_address_id                 in     number
  ,p_object_version_number      in out nocopy number
  ,p_primary_flag               in     varchar2
  ,p_date_from                  in     date
  ,p_date_to                    in     date     default null
  ,p_address_type               in     varchar2 default null
  ,p_comments                   in     long     default null
  ,p_address_line1              in     varchar2
  ,p_address_line2              in     varchar2 default null
  ,p_emirate                    in     varchar2
  ,p_city_village               in     varchar2 default null
  ,p_region_area                in     varchar2 default null
  ,p_street                     in     varchar2 default null
  ,p_building                   in     varchar2 default null
  ,p_flat_number                in     varchar2 default null
  ,p_po_box                     in     varchar2 default null
  ,p_country                    in     varchar2 default null
  ,p_addr_attribute_category    in     varchar2 default null
  ,p_addr_attribute1            in     varchar2 default null
  ,p_addr_attribute2            in     varchar2 default null
  ,p_addr_attribute3            in     varchar2 default null
  ,p_addr_attribute4            in     varchar2 default null
  ,p_addr_attribute5            in     varchar2 default null
  ,p_addr_attribute6            in     varchar2 default null
  ,p_addr_attribute7            in     varchar2 default null
  ,p_addr_attribute8            in     varchar2 default null
  ,p_addr_attribute9            in     varchar2 default null
  ,p_addr_attribute10           in     varchar2 default null
  ,p_addr_attribute11           in     varchar2 default null
  ,p_addr_attribute12           in     varchar2 default null
  ,p_addr_attribute13           in     varchar2 default null
  ,p_addr_attribute14           in     varchar2 default null
  ,p_addr_attribute15           in     varchar2 default null
  ,p_addr_attribute16           in     varchar2 default null
  ,p_addr_attribute17           in     varchar2 default null
  ,p_addr_attribute18           in     varchar2 default null
  ,p_addr_attribute19           in     varchar2 default null
  ,p_addr_attribute20           in     varchar2 default null
  ,p_party_id                   in     number   default null
 );


END hr_ae_person_address_api;

/
