--------------------------------------------------------
--  DDL for Package PER_RI_CONFIGURATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIGURATION_API" AUTHID CURRENT_USER AS
/* $Header: pecnfapi.pkh 120.2 2006/05/23 20:11:11 ndorai noship $ */
/*#
 * This package contains APIs for the creation and maintenance of
 * enterprise structure configuration.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Workbench Configuration.
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_configuration >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Workbench Configuration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Configuration data uniquely identified by configuration code will be
 * created.
 *
 * <p><b>Post Failure</b><br>
 * Data will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_configuration_code Unique short name of the configuration.
 * @param p_configuration_type Type of the configuration.
 * @param p_configuration_status Status of the configuration such as Complete, Load.
 * @param p_configuration_name Name of the configuration for identification.
 * @param p_configuration_description A brief description of the configuration.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number Set to the version number of the created configuration.
 * @rep:displayname Create Configuration
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
Procedure create_configuration
  (   p_validate                      In  Boolean   Default False
     ,p_configuration_code            In  Varchar2
     ,p_configuration_type            In  Varchar2
     ,p_configuration_status          In  Varchar2
     ,p_configuration_name            In  Varchar2
     ,p_configuration_description     In  Varchar2
     ,p_language_code                 In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                In  Date
     ,p_object_version_number         Out Nocopy Number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_configuration >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Workbench Configuration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Configuration data uniquely identified by configuration code will be
 * updated.
 *
 * <p><b>Post Failure</b><br>
 * Data will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_configuration_code Unique short name of the configuration.
 * @param p_configuration_type Type of the configuration.
 * @param p_configuration_status Status of the configuration such as Complete, Load.
 * @param p_configuration_name Name of the configuration.
 * @param p_configuration_description Brief description of the configuration.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number Set to the version number of the created configuration.
 * @rep:displayname Update Configuration
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
Procedure update_configuration
  (   p_validate                       In  Boolean   Default False
     ,p_configuration_code             In  Varchar2
     ,p_configuration_type             In  Varchar2  Default hr_api.g_varchar2
     ,p_configuration_status           In  Varchar2  Default hr_api.g_varchar2
     ,p_configuration_name             In  Varchar2  Default hr_api.g_varchar2
     ,p_configuration_description      In  Varchar2  Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In  Out Nocopy Number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_configuration >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Workbench Configuration records.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * NONE
 *
 * <p><b>Post Success</b><br>
 * Configuration data uniquely identified by configuration code will be
 * deleted.
 *
 * <p><b>Post Failure</b><br>
 * Record will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_configuration_code Unique short name of the configuration.
 * @param p_object_version_number Set to the version number of the created configuration.
 * @rep:displayname Delete Configuration
 * @rep:category BUSINESS_ENTITY PER_CONFIG_WORKBENCH
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_configuration
   (  p_validate                    In Boolean Default False
     ,p_configuration_code          In Varchar2
     ,p_object_version_number       In Number );

End per_ri_configuration_api;
--

 

/
