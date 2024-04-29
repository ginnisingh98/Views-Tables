--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_LOCATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_LOCATION_API" AUTHID CURRENT_USER AS
/* $Header: pecnlapi.pkh 120.5 2006/05/25 07:18:26 ndorai noship $ */
/*#
 * This package contains APIs for maintaining location information
 * created using the Workbench Configuration.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Workbench Config Location
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_location >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to create locations for Enterprise Structure Configuration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Location will be created.
 *
 * <p><b>Post Failure</b><br>
 * Location will not be created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_configuration_code Unique short name of the configuration.
 * @param p_configuration_context This context value determines the type of organization
 * context to which this location is attached to.
 * @param p_location_code Unique short name of the location.
 * @param p_description Description of the location.
 * @param p_style This context value determines which Flexfield Structure to
 * use with the  Descriptive flexfield segments.
 * @param p_address_line_1      Descriptive Flexfield Segment.
 * @param p_address_line_2      Descriptive Flexfield Segment.
 * @param p_address_line_3      Descriptive Flexfield Segment.
 * @param p_town_or_city        Descriptive Flexfield Segment.
 * @param p_country             Descriptive Flexfield Segment.
 * @param p_postal_code         Descriptive Flexfield Segment.
 * @param p_region_1            Descriptive Flexfield Segment.
 * @param p_region_2            Descriptive Flexfield Segment.
 * @param p_region_3            Descriptive Flexfield Segment.
 * @param p_telephone_number_1  Descriptive Flexfield Segment.
 * @param p_telephone_number_2  Descriptive Flexfield Segment.
 * @param p_telephone_number_3  Descriptive Flexfield Segment.
 * @param p_loc_information13   Descriptive Flexfield Segment.
 * @param p_loc_information14   Descriptive Flexfield Segment.
 * @param p_loc_information15   Descriptive Flexfield Segment.
 * @param p_loc_information16   Descriptive Flexfield Segment.
 * @param p_loc_information17   Descriptive Flexfield Segment.
 * @param p_loc_information18   Descriptive Flexfield Segment.
 * @param p_loc_information19   Descriptive Flexfield Segment.
 * @param p_loc_information20   Descriptive Flexfield Segment.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created location. If p_validate is true, then the
 * value will be null.
 * @param p_location_id If p_validate is false, uniquely identifies the
 * location created. If p_validate is true set to null.
 * @rep:displayname Create Config Workbench Location
 * @rep:category BUSINESS_ENTITY PER_CONFIG_WORKBENCH
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
Procedure create_location
  (   p_validate                       In  Boolean   Default False
     ,p_configuration_code             In  Varchar2
     ,p_configuration_context          In  Varchar2
     ,p_location_code                  In  Varchar2
     ,p_description                    In  Varchar2  Default Null
     ,p_style                          In  Varchar2  Default Null
     ,p_address_line_1                 In  Varchar2  Default Null
     ,p_address_line_2                 In  Varchar2  Default Null
     ,p_address_line_3                 In  Varchar2  Default Null
     ,p_town_or_city                   In  Varchar2  Default Null
     ,p_country                        In  Varchar2  Default Null
     ,p_postal_code                    In  Varchar2  Default Null
     ,p_region_1                       In  Varchar2  Default Null
     ,p_region_2                       In  Varchar2  Default Null
     ,p_region_3                       In  Varchar2  Default Null
     ,p_telephone_number_1             In  Varchar2  Default Null
     ,p_telephone_number_2             In  Varchar2  Default Null
     ,p_telephone_number_3             In  Varchar2  Default Null
     ,p_loc_information13              In  Varchar2  Default Null
     ,p_loc_information14              In  Varchar2  Default Null
     ,p_loc_information15              In  Varchar2  Default Null
     ,p_loc_information16              In  Varchar2  Default Null
     ,p_loc_information17              In  Varchar2  Default Null
     ,p_loc_information18              In  Varchar2  Default Null
     ,p_loc_information19              In  Varchar2  Default Null
     ,p_loc_information20              In  Varchar2  Default Null
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          Out Nocopy Number
     ,p_location_id                    Out Nocopy Number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_location >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to update locations for Enterprise Structure Configuration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Location will be updated.
 *
 * <p><b>Post Failure</b><br>
 * Location will not be updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_location_id Uniquely identifies the location to be updated.
 * @param p_configuration_code Unique short name of the configuration.
 * @param p_configuration_context This context value determines the type of organization
 * context to which this location is attached to.
 * @param p_location_code Unique short name of the location.
 * @param p_description Description of the location.
 * @param p_style This context value determines which Flexfield Structure to
 * use with the  Descriptive flexfield segments.
 * @param p_address_line_1      Descriptive flexfield segments.
 * @param p_address_line_2      Descriptive flexfield segments.
 * @param p_address_line_3      Descriptive flexfield segments.
 * @param p_town_or_city        Descriptive flexfield segments.
 * @param p_country             Descriptive flexfield segments.
 * @param p_postal_code         Descriptive flexfield segments.
 * @param p_region_1            Descriptive flexfield segments.
 * @param p_region_2            Descriptive flexfield segments.
 * @param p_region_3            Descriptive flexfield segments.
 * @param p_telephone_number_1  Descriptive flexfield segments.
 * @param p_telephone_number_2  Descriptive flexfield segments.
 * @param p_telephone_number_3  Descriptive flexfield segments.
 * @param p_loc_information13   Descriptive flexfield segments.
 * @param p_loc_information14   Descriptive flexfield segments.
 * @param p_loc_information15   Descriptive flexfield segments.
 * @param p_loc_information16   Descriptive flexfield segments.
 * @param p_loc_information17   Descriptive flexfield segments.
 * @param p_loc_information18   Descriptive flexfield segments.
 * @param p_loc_information19   Descriptive flexfield segments.
 * @param p_loc_information20   Descriptive flexfield segments.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created location. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Update Config Workbench Location
 * @rep:category BUSINESS_ENTITY PER_CONFIG_WORKBENCH
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
Procedure update_location
    ( p_validate                       In  Boolean   Default False
     ,p_location_id                    In  Number
     ,p_configuration_code             In  Varchar2
     ,p_configuration_context          In  Varchar2
     ,p_location_code                  In  Varchar2
     ,p_description                    In  Varchar2  Default hr_api.g_varchar2
     ,p_style                          In  Varchar2  Default hr_api.g_varchar2
     ,p_address_line_1                 In  Varchar2  Default hr_api.g_varchar2
     ,p_address_line_2                 In  Varchar2  Default hr_api.g_varchar2
     ,p_address_line_3                 In  Varchar2  Default hr_api.g_varchar2
     ,p_town_or_city                   In  Varchar2  Default hr_api.g_varchar2
     ,p_country                        In  Varchar2  Default hr_api.g_varchar2
     ,p_postal_code                    In  Varchar2  Default hr_api.g_varchar2
     ,p_region_1                       In  Varchar2  Default hr_api.g_varchar2
     ,p_region_2                       In  Varchar2  Default hr_api.g_varchar2
     ,p_region_3                       In  Varchar2  Default hr_api.g_varchar2
     ,p_telephone_number_1             In  Varchar2  Default hr_api.g_varchar2
     ,p_telephone_number_2             In  Varchar2  Default hr_api.g_varchar2
     ,p_telephone_number_3             In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information13              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information14              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information15              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information16              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information17              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information18              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information19              In  Varchar2  Default hr_api.g_varchar2
     ,p_loc_information20              In  Varchar2  Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In Out Nocopy Number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_location >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to delete locations for Enterprise Structure Configuration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Location will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * Location will not be deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_location_id Uniquely identifies the location to be updated.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created location. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Delete Config Workbench Location
 * @rep:category BUSINESS_ENTITY PER_CONFIG_WORKBENCH
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_location
   (  p_validate                     In Boolean Default False
     ,p_location_id                  In Number
     ,p_object_version_number        IN Number );

End per_ri_config_location_api;
--

 

/
