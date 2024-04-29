--------------------------------------------------------
--  DDL for Package PQH_ACCOMMODATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ACCOMMODATIONS_API" AUTHID CURRENT_USER as
/* $Header: pqaccapi.pkh 120.1 2005/10/02 02:25:22 aroussel $ */
/*#
 * This package contains APIs to create, update and delete accommodations.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Accommodation for France
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_accommodation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates and creates an accommodation.
 *
 * This API allows to setup an employer's accommodation. Details recorded
 * include whether the accommodation is suitable for disabled, owning
 * department, rental value, number of persons accommodated etc.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An accommodation can be created for an existing business group only.
 *
 * <p><b>Post Success</b><br>
 * A new accommodation is created for the specified business group.
 *
 * <p><b>Post Failure</b><br>
 * An accommodation is not created in the database and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the Date Track operation comes into
 * force
 * @param p_accommodation_name Identifies the unique accommodation name
 * @param p_business_group_id Identifies the business group for which the
 * accommodation is created.
 * @param p_location_id Identifies the HR location for the accommodation.
 * Foreign Key to HR_ALL_LOCATIONS table.
 * @param p_accommodation_desc Any general description of the accommodation
 * @param p_accommodation_type Identifies the type of accommodation, for
 * example, independent house, company flat. Valid values are identified by
 * lookup type 'PQH_ACC_TYPE'
 * @param p_style Identifies the address style selected for providing address
 * information of the accommodation
 * @param p_address_line_1 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.ADDRESS_LINE_1}
 * @param p_address_line_2 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.ADDRESS_LINE_2}
 * @param p_address_line_3 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.ADDRESS_LINE_3}
 * @param p_town_or_city Identifies the name of the city or town given as a
 * part of the address of the accommodation
 * @param p_country Identifies the name of the country given as part of the
 * address of the accommodation
 * @param p_postal_code Identifies the postal code given as part of the address
 * of the accommodation
 * @param p_region_1 {@rep:casecolumn PQH_ACCOMMODATIONS_F.REGION_1}
 * @param p_region_2 {@rep:casecolumn PQH_ACCOMMODATIONS_F.REGION_2}
 * @param p_region_3 {@rep:casecolumn PQH_ACCOMMODATIONS_F.REGION_3}
 * @param p_telephone_number_1 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.TELEPHONE_NUMBER_1}
 * @param p_telephone_number_2 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.TELEPHONE_NUMBER_2}
 * @param p_telephone_number_3 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.TELEPHONE_NUMBER_3}
 * @param p_floor_number Identifies the floor number of the accommodation
 * @param p_floor_area Identifies the floor area of the accommodation given in
 * terms of units mentioned in floor area unit parameter
 * @param p_floor_area_measure_unit Identifies a unit of area measurement in
 * terms of which floor area is provided. Valid values are identified by lookup
 * type 'PQH_ACC_AREA_TYPE'
 * @param p_main_rooms Identifies the number of main rooms in the accommodation
 * @param p_family_size Identifies the family size that can be accommodated in
 * the accommodation
 * @param p_suitability_disabled A flag that denotes whether the accommodation
 * is suitable for a disabled person or not
 * @param p_rental_value Rental value of the accommodation in terms of currency
 * given in currency parameter
 * @param p_rental_value_currency Currency in terms of which rental value is
 * provided. This is a foreign key to FND_CURRENCIES.
 * @param p_owner Name of the organization, legal entity etc that owns the
 * accommodation. This is a foreign key to HR_ALL_ORGANIZATION_UNITS table.
 * @param p_comments Comment text
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_accommodation_id The process returns the unique accommodation
 * identifier generated for the new accommodation record.
 * @param p_object_version_number If p_validate is false, the process returns
 * the version number of the created accommodation record. If p_validate is
 * true, it returns null.
 * @param p_effective_start_date If p_validate is false, the process returns
 * the earliest effective start date for the created accommodation record. If
 * p_validate is true, it returns null.
 * @param p_effective_end_date If p_validate is false, the process returns
 * effective end date for the created accommodation record. If p_validate is
 * true, it returns null.
 * @rep:displayname Create Accommodation
 * @rep:category BUSINESS_ENTITY PQH_EMPLOYER_ACCOMMODATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_accommodation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_accommodation_name             in     varchar2
  ,p_business_group_id              in     number
  ,p_location_id                    in     number
  ,p_accommodation_desc             in     varchar2 default null
  ,p_accommodation_type             in     varchar2 default null
  ,p_style                          in     varchar2 default null
  ,p_address_line_1                 in     varchar2 default null
  ,p_address_line_2                 in     varchar2 default null
  ,p_address_line_3                 in     varchar2 default null
  ,p_town_or_city                   in     varchar2 default null
  ,p_country                        in     varchar2 default null
  ,p_postal_code                    in     varchar2 default null
  ,p_region_1                       in     varchar2 default null
  ,p_region_2                       in     varchar2 default null
  ,p_region_3                       in     varchar2 default null
  ,p_telephone_number_1             in     varchar2 default null
  ,p_telephone_number_2             in     varchar2 default null
  ,p_telephone_number_3             in     varchar2 default null
  ,p_floor_number                   in     varchar2 default null
  ,p_floor_area                     in     number   default null
  ,p_floor_area_measure_unit        in     varchar2 default null
  ,p_main_rooms                     in     number   default null
  ,p_family_size                    in     number   default null
  ,p_suitability_disabled           in     varchar2 default null
  ,p_rental_value                   in     number   default null
  ,p_rental_value_currency          in     varchar2 default null
  ,p_owner                          in     varchar2 default null
  ,p_comments                       in     varchar2 default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_accommodation_id                  OUT NOCOPY number
  ,p_object_version_number             OUT NOCOPY number
  ,p_effective_start_date              OUT NOCOPY date
  ,p_effective_end_date                OUT NOCOPY date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_accommodation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the employer's accommodation details.
 *
 * Details that can be updated by this API include rental value, number of
 * rooms, family size, size of the accommodation etc.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * This accommodation record must exist with the specified object version
 * number.
 *
 * <p><b>Post Success</b><br>
 * The existing accommodation record is updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The existing accommodation record is not changed in the database and an
 * error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the Date Track operation comes into
 * force
 * @param p_datetrack_mode Indicates which Date Track mode to use when updating
 * the record. It can be either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change
 * @param p_accommodation_id Unique accommodation identifier assigned to the
 * accommodation record while creation as a primary key
 * @param p_object_version_number Passes the current version number of the
 * accommodation record to be updated. When the API completes if p_validate is
 * false, the process returns the new version number of the updated
 * accommodation record. If p_validate is true, it returns the same value which
 * was passed in
 * @param p_accommodation_name Identifies the unique accommodation name
 * @param p_business_group_id Identifies the business group for which the
 * accommodation is created.
 * @param p_location_id Identifies the HR location for the accommodation.
 * Foreign key to HR_ALL_LOCATIONS table.
 * @param p_accommodation_desc General description of the accommodation
 * @param p_accommodation_type Identifies the type of accommodation, for
 * example, independent house, company flat. Valid values are identified by
 * lookup type 'PQH_ACC_TYPE'
 * @param p_style Identifies the address style selected for providing address
 * information of the accommodation
 * @param p_address_line_1 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.ADDRESS_LINE_1}
 * @param p_address_line_2 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.ADDRESS_LINE_2}
 * @param p_address_line_3 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.ADDRESS_LINE_3}
 * @param p_town_or_city Identifies the name of the city or town given as a
 * part of the address of the accommodation
 * @param p_country Identifies the name of the country given as part of the
 * address of the accommodation
 * @param p_postal_code Identifies the postal code given as part of the address
 * of the accommodation
 * @param p_region_1 {@rep:casecolumn PQH_ACCOMMODATIONS_F.REGION_1}
 * @param p_region_2 {@rep:casecolumn PQH_ACCOMMODATIONS_F.REGION_2}
 * @param p_region_3 {@rep:casecolumn PQH_ACCOMMODATIONS_F.REGION_3}
 * @param p_telephone_number_1 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.TELEPHONE_NUMBER_1}
 * @param p_telephone_number_2 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.TELEPHONE_NUMBER_2}
 * @param p_telephone_number_3 {@rep:casecolumn
 * PQH_ACCOMMODATIONS_F.TELEPHONE_NUMBER_3}
 * @param p_floor_number Identifies the floor number of the accommodation
 * @param p_floor_area Identifies the floor area of the accommodation given in
 * terms of units mentioned in floor area unit parameter
 * @param p_floor_area_measure_unit Identifies a unit of area measurement in
 * terms of which floor area is provided. Valid values are identified by lookup
 * type 'PQH_ACC_AREA_TYPE'
 * @param p_main_rooms Identifies the number of main rooms in the accommodation
 * @param p_family_size Identifies the family size that can be accommodated in
 * the accommodation
 * @param p_suitability_disabled A flag that denotes whether the accommodation
 * is suitable for a disabled person or not
 * @param p_rental_value Rental value of the accommodation in terms of currency
 * given in currency parameter
 * @param p_rental_value_currency Currency in terms of which rental value is
 * provided. This is a foreign key to FND_CURRENCIES.
 * @param p_owner Name of the organization, legal entity etc. that owns the
 * accommodation. This is a foreign key to HR_ALL_ORGANIZATION_UNITS table.
 * @param p_comments Comment text
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_effective_start_date If p_validate is false, the process returns
 * the effective start date on the updated accommodation row which now exists
 * as of the effective date. If p_validate is true, it returns null
 * @param p_effective_end_date If p_validate is false, the process returns the
 * effective end date on the updated accommodation row which now exists as of
 * the effective date. If p_validate is true, it returns null
 * @rep:displayname Update Accommodation
 * @rep:category BUSINESS_ENTITY PQH_EMPLOYER_ACCOMMODATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_accommodation
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_accommodation_id             in     number
  ,p_object_version_number        in OUT NOCOPY number
  ,p_accommodation_name           in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_accommodation_desc           in     varchar2  default hr_api.g_varchar2
  ,p_accommodation_type           in     varchar2  default hr_api.g_varchar2
  ,p_style                        in     varchar2  default hr_api.g_varchar2
  ,p_address_line_1               in     varchar2  default hr_api.g_varchar2
  ,p_address_line_2               in     varchar2  default hr_api.g_varchar2
  ,p_address_line_3               in     varchar2  default hr_api.g_varchar2
  ,p_town_or_city                 in     varchar2  default hr_api.g_varchar2
  ,p_country                      in     varchar2  default hr_api.g_varchar2
  ,p_postal_code                  in     varchar2  default hr_api.g_varchar2
  ,p_region_1                     in     varchar2  default hr_api.g_varchar2
  ,p_region_2                     in     varchar2  default hr_api.g_varchar2
  ,p_region_3                     in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_1           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_2           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_3           in     varchar2  default hr_api.g_varchar2
  ,p_floor_number                 in     varchar2  default hr_api.g_varchar2
  ,p_floor_area                   in     number    default hr_api.g_number
  ,p_floor_area_measure_unit      in     varchar2  default hr_api.g_varchar2
  ,p_main_rooms                   in     number    default hr_api.g_number
  ,p_family_size                  in     number    default hr_api.g_number
  ,p_suitability_disabled         in     varchar2  default hr_api.g_varchar2
  ,p_rental_value                 in     number    default hr_api.g_number
  ,p_rental_value_currency        in     varchar2  default hr_api.g_varchar2
  ,p_owner                        in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            OUT NOCOPY date
  ,p_effective_end_date              OUT NOCOPY date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_accommodation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an accommodation record from the database.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A record should exist with the specified object version number. Also
 * references for this accommodation must exist in the system.
 *
 * <p><b>Post Success</b><br>
 * The accommodation record is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The accommodation record is not deleted from the database and an error is
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the Date Track operation comes into
 * force
 * @param p_datetrack_mode Indicates which Date Track mode to use when deleting
 * the record. It can either ZAP, DELETE, FUTURE_CHANGE or DELETE_NEXT_CHANGE.
 * Modes available for use with a particular record depend on the dates of
 * previous record changes and the effective date of this change
 * @param p_accommodation_id Unique accommodation identifier assigned to the
 * accommodation record when created as primary key
 * @param p_object_version_number Current version number of the accommodation
 * record to be deleted
 * @param p_effective_start_date If p_validate is false, the process returns
 * the earliest effective start date for the created accommodation record. If
 * p_validate is true, it returns null.
 * @param p_effective_end_date If p_validate is false, the process returns
 * effective end date for the created accommodation record. If p_validate is
 * true, it returns null.
 * @rep:displayname Delete Accommodation
 * @rep:category BUSINESS_ENTITY PQH_EMPLOYER_ACCOMMODATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_accommodation
  (p_validate                         in     boolean  default false
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_accommodation_id                 in     number
  ,p_object_version_number            in OUT NOCOPY number
  ,p_effective_start_date                OUT NOCOPY date
  ,p_effective_end_date                  OUT NOCOPY date
  );

--
end pqh_accommodations_api;

 

/
