--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_INFORMATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_INFORMATION_API" AUTHID CURRENT_USER AS
/* $Header: pecniapi.pkh 120.5 2006/05/23 20:07:51 ndorai noship $ */
/*#
 * This package contains APIs that maintain enterprise structure configuration
 * information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Enterprise Structure Configuration
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_config_information >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Configuration Information.
 *
 * Configuration Information is used for setting up the HRMS Application which
 * the Workstructures components such as Organization, Jobs, Positions.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Configuration data to setup HCM Workstructures setup data will be created.
 *
 * <p><b>Post Failure</b><br>
 * Configuration setup data will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_configuration_code Unique short name of the configuration.
 * @param p_config_information_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_config_sequence Sequence Number to display the data in an order in UI.
 * @param p_config_information1  Descriptive Flexfield Segment.
 * @param p_config_information2  Descriptive Flexfield Segment.
 * @param p_config_information3  Descriptive Flexfield Segment.
 * @param p_config_information4  Descriptive Flexfield Segment.
 * @param p_config_information5  Descriptive Flexfield Segment.
 * @param p_config_information6  Descriptive Flexfield Segment.
 * @param p_config_information7  Descriptive Flexfield Segment.
 * @param p_config_information8  Descriptive Flexfield Segment.
 * @param p_config_information9  Descriptive Flexfield Segment.
 * @param p_config_information10 Descriptive Flexfield Segment.
 * @param p_config_information11 Descriptive Flexfield Segment.
 * @param p_config_information12 Descriptive Flexfield Segment.
 * @param p_config_information13 Descriptive Flexfield Segment.
 * @param p_config_information14 Descriptive Flexfield Segment.
 * @param p_config_information15 Descriptive Flexfield Segment.
 * @param p_config_information16 Descriptive Flexfield Segment.
 * @param p_config_information17 Descriptive Flexfield Segment.
 * @param p_config_information18 Descriptive Flexfield Segment.
 * @param p_config_information19 Descriptive Flexfield Segment.
 * @param p_config_information20 Descriptive Flexfield Segment.
 * @param p_config_information21 Descriptive Flexfield Segment.
 * @param p_config_information22 Descriptive Flexfield Segment.
 * @param p_config_information23 Descriptive Flexfield Segment.
 * @param p_config_information24 Descriptive Flexfield Segment.
 * @param p_config_information25 Descriptive Flexfield Segment.
 * @param p_config_information26 Descriptive Flexfield Segment.
 * @param p_config_information27 Descriptive Flexfield Segment.
 * @param p_config_information28 Descriptive Flexfield Segment.
 * @param p_config_information29 Descriptive Flexfield Segment.
 * @param p_config_information30 Descriptive Flexfield Segment.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_config_information_id Uniquely identifies the configuration created.
 * @param p_object_version_number Set to the version number of the created configuration.
 * @rep:displayname Create Configuration Information
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
Procedure create_config_information
  (   p_validate                       In  Boolean   Default False
     ,p_configuration_code             In  Varchar2
     ,p_config_information_category    In  Varchar2
     ,p_config_sequence                In  Number
     ,p_config_information1            In  Varchar2  Default Null
     ,p_config_information2            In  Varchar2  Default Null
     ,p_config_information3            In  Varchar2  Default Null
     ,p_config_information4            In  Varchar2  Default Null
     ,p_config_information5            In  Varchar2  Default Null
     ,p_config_information6            In  Varchar2  Default Null
     ,p_config_information7            In  Varchar2  Default Null
     ,p_config_information8            In  Varchar2  Default Null
     ,p_config_information9            In  Varchar2  Default Null
     ,p_config_information10           In  Varchar2  Default Null
     ,p_config_information11           In  Varchar2  Default Null
     ,p_config_information12           In  Varchar2  Default Null
     ,p_config_information13           In  Varchar2  Default Null
     ,p_config_information14           In  Varchar2  Default Null
     ,p_config_information15           In  Varchar2  Default Null
     ,p_config_information16           In  Varchar2  Default Null
     ,p_config_information17           In  Varchar2  Default Null
     ,p_config_information18           In  Varchar2  Default Null
     ,p_config_information19           In  Varchar2  Default Null
     ,p_config_information20           In  Varchar2  Default Null
     ,p_config_information21           In  Varchar2  Default Null
     ,p_config_information22           In  Varchar2  Default Null
     ,p_config_information23           In  Varchar2  Default Null
     ,p_config_information24           In  Varchar2  Default Null
     ,p_config_information25           In  Varchar2  Default Null
     ,p_config_information26           In  Varchar2  Default Null
     ,p_config_information27           In  Varchar2  Default Null
     ,p_config_information28           In  Varchar2  Default Null
     ,p_config_information29           In  Varchar2  Default Null
     ,p_config_information30           In  Varchar2  Default Null
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_config_information_id          Out Nocopy Number
     ,p_object_version_number          Out Nocopy Number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_config_information >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Configuration Information.
 *
 * Configuration Information is used for setting up the HRMS Application which
 * the Workstructures components such as Organization, Jobs, Positions.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Configuration data to setup HCM Workstructures setup data will be updated.
 *
 * <p><b>Post Failure</b><br>
 * Configuration setup data will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_config_information_id Uniquely identifies the configuration created.
 * @param p_configuration_code Unique short name of the configuration.
 * @param p_config_information_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_config_sequence Sequence Number to display the data in an order in UI.
 * @param p_config_information1  Descriptive Flexfield Segment.
 * @param p_config_information2  Descriptive Flexfield Segment.
 * @param p_config_information3  Descriptive Flexfield Segment.
 * @param p_config_information4  Descriptive Flexfield Segment.
 * @param p_config_information5  Descriptive Flexfield Segment.
 * @param p_config_information6  Descriptive Flexfield Segment.
 * @param p_config_information7  Descriptive Flexfield Segment.
 * @param p_config_information8  Descriptive Flexfield Segment.
 * @param p_config_information9  Descriptive Flexfield Segment.
 * @param p_config_information10 Descriptive Flexfield Segment.
 * @param p_config_information11 Descriptive Flexfield Segment.
 * @param p_config_information12 Descriptive Flexfield Segment.
 * @param p_config_information13 Descriptive Flexfield Segment.
 * @param p_config_information14 Descriptive Flexfield Segment.
 * @param p_config_information15 Descriptive Flexfield Segment.
 * @param p_config_information16 Descriptive Flexfield Segment.
 * @param p_config_information17 Descriptive Flexfield Segment.
 * @param p_config_information18 Descriptive Flexfield Segment.
 * @param p_config_information19 Descriptive Flexfield Segment.
 * @param p_config_information20 Descriptive Flexfield Segment.
 * @param p_config_information21 Descriptive Flexfield Segment.
 * @param p_config_information22 Descriptive Flexfield Segment.
 * @param p_config_information23 Descriptive Flexfield Segment.
 * @param p_config_information24 Descriptive Flexfield Segment.
 * @param p_config_information25 Descriptive Flexfield Segment.
 * @param p_config_information26 Descriptive Flexfield Segment.
 * @param p_config_information27 Descriptive Flexfield Segment.
 * @param p_config_information28 Descriptive Flexfield Segment.
 * @param p_config_information29 Descriptive Flexfield Segment.
 * @param p_config_information30 Descriptive Flexfield Segment.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number Set to the version number of the created configuration.
 * @rep:displayname Update Configuration Information
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
Procedure update_config_information
    ( p_validate                       In  Boolean   Default False
     ,p_config_information_id          In  Number
     ,p_configuration_code             In  Varchar2
     ,p_config_information_category    In  Varchar2
     ,p_config_sequence                In  Number    Default hr_api.g_number
     ,p_config_information1            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information2            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information3            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information4            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information5            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information6            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information7            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information8            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information9            In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information10           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information11           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information12           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information13           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information14           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information15           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information16           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information17           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information18           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information19           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information20           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information21           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information22           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information23           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information24           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information25           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information26           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information27           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information28           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information29           In  Varchar2  Default hr_api.g_varchar2
     ,p_config_information30           In  Varchar2  Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In Out Nocopy Number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_config_information >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Configuration Information.
 *
 * Configuration Information is used for setting up the HRMS Application which
 * the Workstructures components such as Organization, Jobs, Positions.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Configuration data to setup HCM Workstructures setup data will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * Configuration data will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_config_information_id Uniquely identifies the configuration created.
 * @param p_object_version_number Set to the version number of the created configuration.
 * @rep:displayname Delete Configuration Information
 * @rep:category BUSINESS_ENTITY PER_CONFIG_WORKBENCH
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_config_information
   (  p_validate                     In Boolean Default False
     ,p_config_information_id        In Number
     ,p_object_version_number        IN Number );

End per_ri_config_information_api;
--

 

/
