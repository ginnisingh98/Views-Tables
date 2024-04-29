--------------------------------------------------------
--  DDL for Package HR_PL_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_PERSON_ADDRESS_API" AUTHID CURRENT_USER as
/* $Header: peaddpli.pkh 120.2.12010000.1 2008/07/28 04:02:57 appldev ship $ */
/*#
 * This package contains person address APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Personal Address for Poland
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure creates a Polish Address for current and
 * ex-employees,current and ex-applicants and employee contacts.
 *
 * This API is effectively an alternative to the API create_person_address. If
 * p_validate is set to false, an address is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid person (p_person_id) must exist on the start date (p_date_from) of
 * the address.
 *
 * <p><b>Post Success</b><br>
 * The person address will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the address
 * record.
 * @param p_primary_flag Identifies the primary address.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Person address comment text.
 * @param p_street_type Street type of the address. Valid values are defined by
 * 'PL_STREET_TYPE' lookup.
 * @param p_street_name Street name of the address. If a Street Type is
 * entered, then a value must be entered for the Street Name
 * @param p_house_number House number of the address.
 * @param p_flat_number Flat number of the address.
 * @param p_post_code Postal code of the address.
 * @param p_town Town of the address.
 * @param p_province Province of the address. Valid values are defined by
 * 'PL_PROVINCE' lookup type.
 * @param p_district District of the address. Valid values are defined by
 * 'PL_DISTRICT' lookup type.
 * @param p_community Community of the address. Valid values are defined by
 * 'PL_COMMUNITY' lookup type.
 * @param p_post Post of the address.
 * @param p_country Country of the address.
 * @param p_post_box Post Box.
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
 * @param p_party_id Party for whom the address. HR/TCA merge applies.
 * @param p_address_id If p_validate is false, then this uniquely identifies
 * the address created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Person Address. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Person Address for Poland
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_pl_person_address
  (
   p_validate                   in     boolean  default false
  ,p_effective_date             in     date
  ,p_person_id                  in     number
  ,p_primary_flag               in     varchar2
  ,p_date_from                  in     date
  ,p_date_to                    in     date     default null
  ,p_address_type               in     varchar2 default null
  ,p_comments                   in     long default null
  ,p_street_type                in     varchar2 default null
  ,p_street_name                in     varchar2 default null
  ,p_house_number               in     varchar2
  ,p_flat_number                in     varchar2 default null
  ,p_post_code                  in     varchar2
  ,p_town                       in     varchar2
  ,p_province                   in     varchar2
  ,p_district                   in     varchar2 default null
  ,p_community                  in     varchar2
  ,p_post                       in     varchar2 default null
  ,p_country                    in     varchar2
  ,p_post_box                   in     varchar2 default null
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
-- |-------------------------< update_pl_person_address >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure updates a Polish Address for current and
 * ex-employees,current and ex-applicants and employee contacts.
 *
 * This API is effectively an alternative to the API update_person_address. If
 * p_validate is set to false, the address is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The address to be updated must exist on the effective date and should be in
 * the correct style. Valid values are defined by 'ADDRESS_TYPE' lookup type.
 *
 * <p><b>Post Success</b><br>
 * The address will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The address will not be updated and an error will be raised.
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
 * @param p_primary_flag Identifies the primary address.
 * @param p_date_from The date from which the address applies.
 * @param p_date_to The date from which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_comments Person address comment text.
 * @param p_street_type Street type of the address. Valid values are defined by
 * 'PL_STREET_TYPE' lookup.
 * @param p_street_name Street name of the address. If a Street Type is
 * entered, then a value must be entered for the Street Name.
 * @param p_house_number House number of the address.
 * @param p_flat_number Flat number of the address.
 * @param p_post_code Postal code of the address.
 * @param p_town Town of the address.
 * @param p_province Province of the address. Valid values are defined by
 * 'PL_PROVINCE' lookup type.
 * @param p_district District of the address. Valid values are defined by
 * 'PL_DISTRICT' lookup type.
 * @param p_community Community of the address. Valid values are defined by
 * 'PL_COMMUNITY' lookup type.
 * @param p_post Post of the address.
 * @param p_country Country of the address.
 * @param p_post_box Post Box.
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
 * @param p_party_id Party for whom the address. HR/TCA merge applies.
 * @rep:displayname Update Person Address for Poland
 * @rep:category BUSINESS_ENTITY PER_PERSON_ADDRESS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_pl_person_address
  (
   p_validate                   in     boolean  default false
  ,p_effective_date             in     date
  ,p_address_id                 in     number
  ,p_object_version_number      in out nocopy number
  ,p_primary_flag               in     varchar2
  ,p_date_from                  in     date
  ,p_date_to                    in     date     default null
  ,p_address_type               in     varchar2 default null
  ,p_comments                   in     long default null
  ,p_street_type                in     varchar2 default null
  ,p_street_name                in     varchar2 default null
  ,p_house_number               in     varchar2
  ,p_flat_number                in     varchar2 default null
  ,p_post_code                  in     varchar2
  ,p_town                       in     varchar2
  ,p_province                   in     varchar2
  ,p_district                   in     varchar2 default null
  ,p_community                  in     varchar2
  ,p_post                       in     varchar2 default null
  ,p_country                    in     varchar2
  ,p_post_box                   in     varchar2 default null
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


END hr_pl_person_address_api;

/
