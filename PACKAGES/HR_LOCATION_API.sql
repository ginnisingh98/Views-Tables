--------------------------------------------------------
--  DDL for Package HR_LOCATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_API" AUTHID CURRENT_USER AS
/* $Header: hrlocapi.pkh 120.2.12010000.3 2009/10/26 12:26:36 skura ship $ */
/*#
 * This package contains APIs for maintaining location information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Location
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_location >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API is used to create locations.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * If a business group is specified it must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The location is created.
 *
 * <p><b>Post Failure</b><br>
 * The location is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_location_code Unique name of the location
 * @param p_description Description of the location
 * @param p_timezone_code Time zone of the location.
 * @param p_tp_header_id Identifies the inventory header. Used by Oracle EDI
 * Gateway.
 * @param p_ece_tp_location_code Identifies the inventory organization. Used by
 * Oracle EDI Gateway.
 * @param p_address_line_1 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_address_line_2 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_address_line_3 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_bill_to_site_flag Indicates if this is a billing location
 * @param p_country Location Address Developer Descriptive Flexfield Segment.
 * @param p_designated_receiver_id Designated Receiver Person ID. Must be a
 * valid employee within the scope of the location.
 * @param p_in_organization_flag Indicates if the organization is an Internal
 * Organization. Valid values defined in the YES/NO lookup type.
 * @param p_inactive_date Date on which the location becomes inactive. Must be
 * greater than or equal to p_effective_date.
 * @param p_operating_unit_id Identifies the Operating Unit. Used to validate
 * the parameter p_inventory_organization_id.
 * @param p_inventory_organization_id Identifies the Inventory Organization for
 * this location
 * @param p_office_site_flag Indicates whether this location can be used as an
 * office site. Valid values are defined in the YES_NO lookup type.
 * @param p_postal_code Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_receiving_site_flag Indicates whether this location can be used as
 * a receiving site. Valid values are defined in the YES_NO lookup type.
 * @param p_region_1 Location Address Developer Descriptive Flexfield Segment.
 * @param p_region_2 Location Address Developer Descriptive Flexfield Segment.
 * @param p_region_3 Location Address Developer Descriptive Flexfield Segment.
 * @param p_ship_to_location_id Identifies the Ship To Location. If it is
 * passed as null, it will assume the value of the current location identifier.
 * @param p_ship_to_site_flag Indicates whether items can be shipped to this
 * location. Valid values are defined in the YES_NO lookup type.
 * @param p_style This context value determines which Flexfield Structure to
 * use with the Location Address Developer Descriptive flexfield segments.
 * @param p_tax_name This parameter is disabled.
 * @param p_telephone_number_1 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_telephone_number_2 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_telephone_number_3 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_town_or_city Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information13 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information14 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information15 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information16 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information17 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information18 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information19 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information20 Location Address Developer Descriptive Flexfield
 * Segment.
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
 * @param p_global_attribute_category This context value determines which
 * Flexfield Structure to use with the JG_HR_LOCATIONS Descriptive flexfield
 * segments. Used by Oracle Regional Localizations
 * @param p_global_attribute1 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute2 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute3 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute4 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute5 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute6 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute7 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute8 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute9 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute10 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute11 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute12 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute13 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute14 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute15 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute16 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute17 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute18 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute19 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute20 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_business_group_id Business group identifier. No value indicates the
 * location can be used in any business group. Any other value must indicate a
 * business group that exists, and restricts the scope of the location to that
 * business group.
 * @param p_location_id If p_validate is false, uniquely identifies the
 * location created. If p_validate is true set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created location. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Location
 * @rep:category BUSINESS_ENTITY HR_LOCATION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_location
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_code                  IN  VARCHAR2
     ,p_description                    IN  VARCHAR2  DEFAULT NULL
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT NULL
     ,p_tp_header_id                   IN  NUMBER    DEFAULT NULL
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT NULL
     ,p_bill_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_country                        IN  VARCHAR2  DEFAULT NULL
     ,p_designated_receiver_id         IN  NUMBER    DEFAULT NULL
     ,p_in_organization_flag           IN  VARCHAR2  DEFAULT 'Y'
     ,p_inactive_date                  IN  DATE      DEFAULT NULL
     ,p_operating_unit_id              IN  NUMBER    DEFAULT NULL
     ,p_inventory_organization_id      IN  NUMBER    DEFAULT NULL
     ,p_office_site_flag               IN  VARCHAR2  DEFAULT 'Y'
     ,p_postal_code                    IN  VARCHAR2  DEFAULT NULL
     ,p_receiving_site_flag            IN  VARCHAR2  DEFAULT 'Y'
     ,p_region_1                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_2                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_3                       IN  VARCHAR2  DEFAULT NULL
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT NULL
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_style                          IN  VARCHAR2  DEFAULT NULL
     ,p_tax_name                       IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT NULL
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information13              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information14              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information15              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information16              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information17              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information18              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information19              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information20              IN  VARCHAR2  DEFAULT NULL
     ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
     ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute_category      IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute1              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute2              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute3              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute4              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute5              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute6              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute7              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute8              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute9              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute10             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute11             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute12             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute13             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute14             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute15             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute16             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute17             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute18             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute19             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute20             IN  VARCHAR2  DEFAULT NULL
     ,p_business_group_id              IN  NUMBER    DEFAULT NULL
     ,p_location_id                    OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
 );
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_location >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates the details of a location.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The location must exist.
 *
 * <p><b>Post Success</b><br>
 * The location information is updated with the details supplied.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the location, and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_location_id Uniquely identifies the location to be updated.
 * @param p_location_code Unique name of the location
 * @param p_description Description of the location
 * @param p_timezone_code Time zone of the location.
 * @param p_tp_header_id Identifies the inventory header. Used by Oracle EDI
 * Gateway.
 * @param p_ece_tp_location_code Identifies the inventory organization. Used by
 * Oracle EDI Gateway.
 * @param p_address_line_1 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_address_line_2 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_address_line_3 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_bill_to_site_flag Indicates if this is a billing location
 * @param p_country Location Address Developer Descriptive Flexfield Segment.
 * @param p_designated_receiver_id Designated Receiver Person ID. Must be a
 * valid employee within the scope of the location.
 * @param p_in_organization_flag Indicates if the organization is an Internal
 * Organization. Valid values defined in the YES/NO lookup type.
 * @param p_inactive_date Date on which location becomes inactive. Must be
 * greater than or equal to p_effective_date.
 * @param p_operating_unit_id Identifies Operating Unit, used to validate the
 * parameter p_inventory_organization_id.
 * @param p_inventory_organization_id Identifies the Inventory Organization for
 * this location
 * @param p_office_site_flag Indicates whether this location can be used as an
 * office site. Valid values are defined in the YES_NO lookup type.
 * @param p_postal_code Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_receiving_site_flag Indicates whether this location can be used as
 * a receiving site. Valid values are defined in the YES_NO lookup type.
 * @param p_region_1 Location Address Developer Descriptive Flexfield Segment.
 * @param p_region_2 Location Address Developer Descriptive Flexfield Segment.
 * @param p_region_3 Location Address Developer Descriptive Flexfield Segment.
 * @param p_ship_to_location_id Identifies the Ship To Location. If it is
 * passed as null, it will assume the value of the current location identifier.
 * @param p_ship_to_site_flag Indicates whether items can be shipped to this
 * location. Valid values are defined in the YES_NO lookup type.
 * @param p_style This context value determines which Flexfield Structure to
 * use with the Location Address Developer Descriptive flexfield segments.
 * @param p_tax_name This parameter is disabled.
 * @param p_telephone_number_1 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_telephone_number_2 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_telephone_number_3 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_town_or_city Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information13 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information14 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information15 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information16 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information17 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information18 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information19 Location Address Developer Descriptive Flexfield
 * Segment.
 * @param p_loc_information20 Location Address Developer Descriptive Flexfield
 * Segment.
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
 * @param p_global_attribute_category This context value determines which
 * Flexfield Structure to use with the JG_HR_LOCATIONS Descriptive flexfield
 * segments. Used by Oracle Regional Localizations
 * @param p_global_attribute1 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute2 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute3 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute4 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute5 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute6 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute7 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute8 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute9 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute10 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute11 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute12 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute13 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute14 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute15 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute16 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute17 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute18 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute19 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_global_attribute20 JG_HR_LOCATIONS Descriptive Flexfield Segment.
 * Used by Oracle Regional Localizations
 * @param p_object_version_number Pass in the current version number of the
 * location record to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated location record.
 * If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Location
 * @rep:category BUSINESS_ENTITY HR_LOCATION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_location
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_id                    IN  NUMBER
     ,p_location_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_description                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_tp_header_id                   IN  NUMBER    DEFAULT hr_api.g_number
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_bill_to_site_flag              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_country                        IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_designated_receiver_id         IN  NUMBER    DEFAULT hr_api.g_number
     ,p_in_organization_flag           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_inactive_date                  IN  DATE      DEFAULT hr_api.g_date
     ,p_operating_unit_id              IN  NUMBER    DEFAULT NULL
     ,p_inventory_organization_id      IN  NUMBER    DEFAULT hr_api.g_number
     ,p_office_site_flag               IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_postal_code                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_receiving_site_flag            IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT hr_api.g_number
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_style                          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_tax_name                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information13              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information14              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information15              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information16              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information17              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information18              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information19              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information20              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute_category      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute1              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute2              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute3              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute4              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute5              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute6              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute7              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute8              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute9              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute10             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute11             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute12             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute13             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute14             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute15             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute16             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute17             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute18             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute19             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute20             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_location >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API deletes a location.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The location must exist
 *
 * <p><b>Post Success</b><br>
 * The API deletes the location.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the location, and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_location_id Uniquely identifies the location to be deleted.
 * @param p_object_version_number Current version number of the location to be
 * deleted.
 * @rep:displayname Delete Location
 * @rep:category BUSINESS_ENTITY HR_LOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_location
  (  p_validate                     IN BOOLEAN DEFAULT false
    ,p_location_id                  IN hr_locations.location_id%TYPE
    ,p_object_version_number        IN hr_locations.object_version_number%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_location_legal_adr >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API creates a new location as a legal address.
--    The legal address flag will be 'Y' for the location created.
--
--    A location that has been flagged as a legal address can be used as the legal
--    address for a legal entity. This functionality is used by the new financials
--    legal entity model which will be available in a future release of the
--    eBusiness Suite.
--
--    The API is MLS enabled, and there are two translated
--    columns: LOCATION_CODE and DESCRIPTION.
--
--
--    Locations are stored on the HR_LOCATIONS_ALL table.  The translated
--    columns are stored on the HR_LOCATIONS_ALL_TL table.
--
--    The business_group_id of a location determines its scope:
--
--       If the business_group_id is NULL, the location's scope is global.
--       This means the location is visible to/can reference any entity
--       (within the scope of the current security group).
--
--       If the business_group_id is set, the location's scope is local.
--       This means the location is visible to/can reference any entity
--       within the same business_group or whose scope is global (within
--       the scope of the current security group).
--
--
-- Prerequisites:
--
--  None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   Boolean  If true, the database
--                                                remains unchanged.  If false
--                                                then the location will be
--                                                created on the database.
--   p_effective_date               Yes  Date     Used for date_track
--                                                validation.
--   p_language_code                No   Varchar2 The language used for the
--                                                initial translation values
--   p_location_code                Yes  Varchar2 Location name (Translated)
--   p_description                  No   Varchar2 Location description (Translated)
--   p_timezone_code                No   Varchar2 Timezone of Location
--   p_address_line_1               No   Varchar2 Address Flexfield
--   p_address_line_2               No   Varchar2 Address Flexfield
--   p_address_line_3               No   Varchar2 Address Flexfield
--   p_country                      No   Varchar2 Address Flexfield
--   p_inactive_date                No   Date     Date on which location becomes
--   p_postal_code                  No   Varchar2 Address Flexfield
--   p_region_1                     No   Varchar2 Address Flexfield
--   p_region_2                     No   Varchar2 Address Flexfield
--   p_region_3                     No   Varchar2 Address Flexfield
--
--   p_style                        No   Varchar2 Address Flexfield
--   p_town_or_city                 No   Varchar2 Address Flexfield
--   p_telephone_number_1           No   Varchar2 Address Flexfield
--   p_telephone_number_2           No   Varchar2 Address Flexfield
--   p_telephone_number_3           No   Varchar2 Address Flexfield
--   p_loc_information13            No   Varchar2 Address Flexfield
--   p_loc_information14            No   Varchar2 Address Flexfield
--   p_loc_information15            No   Varchar2 Address Flexfield
--   p_loc_information16            No   Varchar2 Address Flexfield
--   p_loc_information17            No   Varchar2 Address Flexfield
--   p_loc_information18            No   Varchar2 Address Flexfield
--   p_loc_information19            No   Varchar2 Address Flexfield
--   p_loc_information20            No   Varchar2 Address Flexfield
--   p_attribute_category           No   Varchar2 Flexfield Category
--   p_attribute1                   No   Varchar2 Flexfield
--   ..
--   p_attribute20                  No   Varchar2 Flexfield
--   p_business_group_id            No   Number   Business group ID. A
--                                                NULL value indicates global
--                                                scope.  Any other value must
--                                                index a valid business group
--                                                and sets the scope of the
--                                                location to local.
--
-- Post Success:
--   When the location has been successfully inserted, the following OUT
--   parameters are set:
--
--   Name                                Type     Description
--
--   p_location_id                       Number   If p_validate is false, this
--                                                contains the ID assigned to
--                                                the location  (otherwise
--                                                contains NULL)
--   p_object_version_number             Number   If p_validate is false, this
--                                                contains the Object Version
--                                                Number of the newly created
--                                                row (otherwise contains NULL)
--
-- Post Failure:
--   The API does not create the location, and raises an error
--
-- Access Status:
--   Internal Development Use Only.
--
-- Special Notes:
-- N/A
-- {End Of Comments}
--
PROCEDURE create_location_legal_adr
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_code                  IN  VARCHAR2
     ,p_description                    IN  VARCHAR2  DEFAULT NULL
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT NULL
     ,p_country                        IN  VARCHAR2  DEFAULT NULL
     ,p_inactive_date                  IN  DATE      DEFAULT NULL
     ,p_postal_code                    IN  VARCHAR2  DEFAULT NULL
     ,p_region_1                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_2                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_3                       IN  VARCHAR2  DEFAULT NULL
     ,p_style                          IN  VARCHAR2  DEFAULT NULL
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT NULL
     /*Added for bug8703747 */
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information13              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information14              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information15              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information16              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information17              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information18              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information19              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information20              IN  VARCHAR2  DEFAULT NULL
    /*Changes end for bug8703747 */
     ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
     ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
     ,p_business_group_id              IN  NUMBER    DEFAULT NULL
     ,p_location_id                    OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
 );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_location_legal_adr >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API updates an existing location which has been created as a
--    legal adress.
--
--    A location that has been flagged as a legal address can be used as the legal
--    address for a legal entity. This functionality is used by the new financials
--    legal entity model which will be available in a future release of the
--    eBusiness Suite.
--
--    The API is MLS enabled, and there are two translated
--    columns: LOCATION_CODE and DESCRIPTION.
--
--    Locations are stored on the HR_LOCATIONS_ALL table.  The translated
--    columns are stored on the HR_LOCATIONS_ALL_TL table. This API will call
--    hr_location_internal API, which is an internal API, which can not be
--    accessed by users.
--
--    The business_group_id of a location determines its scope:
--
--       If the business_group_id is NULL, the location's scope is global.
--       This means the location is visible to/can reference any entity
--       (within the scope of the current security group).
--
--       If the business_group_id is set, the location's scope is local.
--       This means the location is visible to/can reference any entity
--       within the same business_group or whose scope is global (within
--       the scope of the current security group).
--
--
-- Prerequisites:
--
--    None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   Boolean  If true, the database
--                                                remains unchanged.  If false
--                                                then the location will be
--                                                created on the database.
--   p_effective_date               Yes  Date     Used for date_track
--                                                validation.
--   p_language_code                No   Varchar2 Determines which translation(s)
--                                                are updated.
--   p_location_id                  Yes  Number   Primary Key
--   p_location_code                No   Varchar2 Location name (Translated)
--   p_description                  No   Varchar2 Location description (Translated)
--   p_timezone_code                No   Varchar2 Timezone of Location
--   p_address_line_1               No   Varchar2 Address Flexfield
--   p_address_line_2               No   Varchar2 Address Flexfield
--   p_address_line_3               No   Varchar2 Address Flexfield
--   p_country                      No   Varchar2 Address Flexfield
--   p_inactive_date                No   Date     Date on which location becomes
--   p_postal_code                  No   Varchar2 Address Flexfield
--   p_region_1                     No   Varchar2 Address Flexfield
--   p_region_2                     No   Varchar2 Address Flexfield
--   p_region_3                     No   Varchar2 Address Flexfield
--   p_style                        No   Varchar2 Address Flexfield
--   p_town_or_city                 No   Varchar2 Address Flexfield
--   p_telephone_number_1           No   Varchar2 Address Flexfield
--   p_telephone_number_2           No   Varchar2 Address Flexfield
--   p_telephone_number_3           No   Varchar2 Address Flexfield
--   p_loc_information13            No   Varchar2 Address Flexfield
--   p_loc_information14            No   Varchar2 Address Flexfield
--   p_loc_information15            No   Varchar2 Address Flexfield
--   p_loc_information16            No   Varchar2 Address Flexfield
--   p_loc_information17            No   Varchar2 Address Flexfield
--   p_loc_information18            No   Varchar2 Address Flexfield
--   p_loc_information19            No   Varchar2 Address Flexfield
--   p_loc_information20            No   Varchar2 Address Flexfield
--   p_attribute_category           No   Varchar2 Flexfield Category
--   p_attribute1                   No   Varchar2 Flexfield
--   ..
--   p_attribute20                  No   Varchar2 Flexfield
--   p_object_version_number        Yes  Number   Object Version Number
--
-- Post Success:
--   When the location has been successfully updated, the following OUT
--   parameters are set:
--
--   Name                                Type     Description
--
--   p_object_version_number             Number   If p_validate is false, this
--                                                contains the new Object
--                                                Version Number assigned to
--                                                the row (otherwise it is
--                                                left unchanged).
-- Post Failure:
--   The API does not update the location, and raises an error
--
-- Access Status:
--   Internal Development Use Only.
--
--
-- Special Notes:
-- N/A
--
-- {End Of Comments}
--
PROCEDURE update_location_legal_adr
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_location_id                    IN  NUMBER
     ,p_description                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_inactive_date                  IN  DATE      DEFAULT hr_api.g_date
     ,p_postal_code                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_style                          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT hr_api.g_varchar2
    /* Added for bug8703747*/
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information13              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information14              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information15              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information16              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information17              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information18              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information19              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information20              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
    /*Changes end for bug8703747 */
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
  );
--
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2);
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-----------------------< enable_location_legal_adr >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API enables the location identified by p_location_id as a legal
--   address.The legal address flag will be updated to 'Y' for this location.
--
--   A location that has been flagged as a legal address can be used as the legal
--   address for a legal entity. This functionality is used by the new financials
--   legal entity model which will be available in a future release of the
--   eBusiness Suite.
--
--   Prerequisites:
--
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   Boolean  If true, the database
--                                                remains unchanged.  If false
--                                                then the location will be
--                                                created on the database.
--   p_effective_date               Yes  Date     Used for date_track
--                                                validation.
--   p_location_id                  Yes  Number Primary Key
--   p_object_version_number        Yes  Number   Object Version Number
--
-- Post Success:
--   When the location has been successfully enabled as a legal address loaction,
--   the following OUT parameters are set:
--
--   Name                                Type     Description
--
--   p_object_version_number             Number   If p_validate is false, this
--                                                contains the new Object
--                                                Version Number assigned to
--                                                the row (otherwise it is
--                                                left unchanged).
-- Post Failure:
--   The API does not enable the location as legal address location, and
--   raises an error
--
-- Access Status:
--   Internal Development Use Only.
--
--
-- Special Notes:
-- N/A
--
-- {End Of Comments}
--
PROCEDURE enable_location_legal_adr
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_location_id                    IN  NUMBER
     ,p_object_version_number          IN  OUT NOCOPY  NUMBER
     );
--

--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-----------------------< disable_location_legal_adr >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API disables the location identified by p_location_id as a legal
--   address.The legal address flag will be updated to NULL for this location.
--
--   A location that has been flagged as a legal address can be used as the legal
--   address for a legal entity. This functionality is used by the new financials
--   legal entity model which will be available in a future release of the
--   eBusiness Suite.
--
--   Prerequisites:
--
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   Boolean  If true, the database
--                                                remains unchanged.  If false
--                                                then the location will be
--                                                created on the database.
--   p_effective_date               Yes  Date     Used for date_track
--                                                validation.
--   p_location_id                  Yes  Number Primary Key
--   p_object_version_number        Yes  Number   Object Version Number
--
-- Post Success:
--   When the location has been successfully enabled as a legal address loaction,
--   the following OUT parameters are set:
--
--   Name                                Type     Description
--
--   p_object_version_number             Number   If p_validate is false, this
--                                                contains the new Object
--                                                Version Number assigned to
--                                                the row (otherwise it is
--                                                left unchanged).
-- Post Failure:
--   The API does not disable the legal address location, and raises an error
--
-- Access Status:
--   Internal Development Use Only.
--
--
-- Special Notes:
-- N/A
--
-- {End Of Comments}
--
PROCEDURE disable_location_legal_adr
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_location_id                    IN  NUMBER
     ,p_object_version_number          IN  OUT NOCOPY  NUMBER
     );
--

END hr_location_api;
--

/
