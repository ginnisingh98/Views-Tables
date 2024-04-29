--------------------------------------------------------
--  DDL for Package HR_KI_INTEGRATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_INTEGRATIONS_API" AUTHID CURRENT_USER as
/* $Header: hrintapi.pkh 120.1 2005/10/02 02:03:08 aroussel $ */
/*#
 * This package contains APIs that maintain HR Knowledge Integration
 * definition.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Knowledge Integration
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_integration >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a knowledge integration definition.
 *
 * The integration definition can be to any content provider or a third party
 * application. This enable seamless interation to be provided from Oracle HRMS
 * UI.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * Valid Integration Key, Partner Name, Service Name, Source Language and
 * either URL,external application details to register in Single Sign On server
 * or XML Gateway details should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration definition is successfully created into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration definition will not be created and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_integration_key Unique identifier for knowledge integration record.
 * @param p_party_type Type of trading partner.
 * @param p_party_name Name of the party.
 * @param p_party_site_name Party site name.
 * @param p_transaction_type Product short name for the base Oracle
 * application.
 * @param p_transaction_subtype Code for a particular transaction within the
 * application specified by the p_transaction_type.
 * @param p_standard_code XML standard to be used.
 * @param p_ext_trans_type External identifier for the XML message.
 * @param p_ext_trans_subtype Secondary external identifier for the XML
 * message.
 * @param p_trans_direction Indicates if the message is inbound or outbound.
 * @param p_url URL for the simple URL type integration.
 * @param p_partner_name Name of partner.
 * @param p_service_name Name of services provided by the partner.
 * @param p_ext_application_id Internal identifier of the external application.
 * @param p_application_name External application name.
 * @param p_application_type External application type.
 * @param p_application_url URL for the external application.
 * @param p_logout_url URL to log out of the external application.
 * @param p_user_field Name of user field.
 * @param p_password_field Name of password field.
 * @param p_authentication_needed Type of authentication used. Valid values are
 * BASIC or POST.
 * @param p_field_name1 Additional name and value pair field.
 * @param p_field_value1 Additional name and value pair field.
 * @param p_field_name2 Additional name and value pair field.
 * @param p_field_value2 Additional name and value pair field.
 * @param p_field_name3 Additional name and value pair field.
 * @param p_field_value3 Additional name and value pair field.
 * @param p_field_name4 Additional name and value pair field.
 * @param p_field_value4 Additional name and value pair field.
 * @param p_field_name5 Additional name and value pair field.
 * @param p_field_value5 Additional name and value pair field.
 * @param p_field_name6 Additional name and value pair field.
 * @param p_field_value6 Additional name and value pair field.
 * @param p_field_name7 Additional name and value pair field.
 * @param p_field_value7 Additional name and value pair field.
 * @param p_field_name8 Additional name and value pair field.
 * @param p_field_value8 Additional name and value pair field.
 * @param p_field_name9 Additional name and value pair field.
 * @param p_field_value9 Additional name and value pair field.
 * @param p_integration_id If p_validate is false, then this uniquely
 * identifies the knowledge integration been created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created knowledge integration record. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Integration
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_integration
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_integration_key               in     varchar2
  ,p_party_type                    in     varchar2 default null
  ,p_party_name                    in     varchar2 default null
  ,p_party_site_name               in     varchar2 default null
  ,p_transaction_type              in     varchar2 default null
  ,p_transaction_subtype           in     varchar2 default null
  ,p_standard_code                 in     varchar2 default null
  ,p_ext_trans_type                in     varchar2 default null
  ,p_ext_trans_subtype             in     varchar2 default null
  ,p_trans_direction               in     varchar2 default null
  ,p_url                           in     varchar2 default null
  ,p_partner_name                  in     varchar2
  ,p_service_name                  in     varchar2
  ,p_ext_application_id            in     number   default null
  ,p_application_name              in     varchar2 default null
  ,p_application_type              in     varchar2 default null
  ,p_application_url               in     varchar2 default null
  ,p_logout_url                    in     varchar2 default null
  ,p_user_field                    in     varchar2 default null
  ,p_password_field                in     varchar2 default null
  ,p_authentication_needed         in     varchar2 default null
  ,p_field_name1                   in     varchar2 default null
  ,p_field_value1                  in     varchar2 default null
  ,p_field_name2                   in     varchar2 default null
  ,p_field_value2                  in     varchar2 default null
  ,p_field_name3                   in     varchar2 default null
  ,p_field_value3                  in     varchar2 default null
  ,p_field_name4                   in     varchar2 default null
  ,p_field_value4                  in     varchar2 default null
  ,p_field_name5                   in     varchar2 default null
  ,p_field_value5                  in     varchar2 default null
  ,p_field_name6                   in     varchar2 default null
  ,p_field_value6                  in     varchar2 default null
  ,p_field_name7                   in     varchar2 default null
  ,p_field_value7                  in     varchar2 default null
  ,p_field_name8                   in     varchar2 default null
  ,p_field_value8                  in     varchar2 default null
  ,p_field_name9                   in     varchar2 default null
  ,p_field_value9                  in     varchar2 default null
  ,p_integration_id                out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_integration >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates a knowledge integration definition.
 *
 * Keeps an integration in synch with external application in Single Sign On
 * server and XML Gateway schema. If the integration is valid then the value of
 * SYNCHED is set to Y.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid integration_id should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration validation definition will be successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration validation definition will not be created and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_integration_id Internal unique identifier of the knowledge
 * integration record.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the validation record for the knowledge integration
 * record. If p_validate is true, then the value will be null.
 * @rep:displayname Validate Knowledge Integration
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure validate_integration
  (p_validate                      in     boolean  default false
  ,p_integration_id                in     number
  ,p_object_version_number         in out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_integration >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a knowledge integration definition.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid integration must exist.
 *
 * <p><b>Post Success</b><br>
 * The integration definition will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The integration will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_integration_id Internal unique identifier of the knowledge
 * integration record.
 * @param p_source_type Source type of the integration.
 * @param p_target_type Target type of the integration.
 * @param p_party_type Type of trading partner.
 * @param p_party_name Name of the party.
 * @param p_party_site_name Party site name.
 * @param p_transaction_type Product short name for the base Oracle
 * application.
 * @param p_transaction_subtype Code for a particular transaction within the
 * application specified by the p_transaction_type.
 * @param p_standard_code XML standard to be used.
 * @param p_ext_trans_type External identifier for the XML message.
 * @param p_ext_trans_subtype Secondary external identifier for the XML
 * message.
 * @param p_trans_direction Indicates if the message is inbound or outbound.
 * @param p_url URL for the simple URL type integration.
 * @param p_partner_name Name of partner.
 * @param p_service_name Name of services provided by the partner.
 * @param p_application_name External application code.
 * @param p_application_type External application type.
 * @param p_application_url URL for the external application.
 * @param p_logout_url URL to log out of the external application.
 * @param p_user_field Name of user field.
 * @param p_password_field Name of password field.
 * @param p_authentication_needed Type of authentication used. Valid values are
 * BASIC or POST.
 * @param p_field_name1 Additional name and value pair field.
 * @param p_field_value1 Additional name and value pair field.
 * @param p_field_name2 Additional name and value pair field.
 * @param p_field_value2 Additional name and value pair field.
 * @param p_field_name3 Additional name and value pair field.
 * @param p_field_value3 Additional name and value pair field.
 * @param p_field_name4 Additional name and value pair field.
 * @param p_field_value4 Additional name and value pair field.
 * @param p_field_name5 Additional name and value pair field.
 * @param p_field_value5 Additional name and value pair field.
 * @param p_field_name6 Additional name and value pair field.
 * @param p_field_value6 Additional name and value pair field.
 * @param p_field_name7 Additional name and value pair field.
 * @param p_field_value7 Additional name and value pair field.
 * @param p_field_name8 Additional name and value pair field.
 * @param p_field_value8 Additional name and value pair field.
 * @param p_field_name9 Additional name and value pair field.
 * @param p_field_value9 Additional name and value pair field.
 * @param p_object_version_number Pass in the current version number of the
 * knowledge integration to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated backfeed payment
 * detail. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Integration
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_integration
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_integration_id                in     number
  ,p_source_type                   in     varchar2
  ,p_target_type                   in     varchar2
  ,p_party_type                    in     varchar2 default hr_api.g_varchar2
  ,p_party_name                    in     varchar2 default hr_api.g_varchar2
  ,p_party_site_name               in     varchar2 default hr_api.g_varchar2
  ,p_transaction_type              in     varchar2 default hr_api.g_varchar2
  ,p_transaction_subtype           in     varchar2 default hr_api.g_varchar2
  ,p_standard_code                 in     varchar2 default hr_api.g_varchar2
  ,p_ext_trans_type                in     varchar2 default hr_api.g_varchar2
  ,p_ext_trans_subtype             in     varchar2 default hr_api.g_varchar2
  ,p_trans_direction               in     varchar2 default hr_api.g_varchar2
  ,p_url                           in     varchar2 default hr_api.g_varchar2
  ,p_partner_name                  in     varchar2 default hr_api.g_varchar2
  ,p_service_name                  in     varchar2 default hr_api.g_varchar2
  ,p_application_name              in     varchar2 default hr_api.g_varchar2
  ,p_application_type              in     varchar2 default hr_api.g_varchar2
  ,p_application_url               in     varchar2 default hr_api.g_varchar2
  ,p_logout_url                    in     varchar2 default hr_api.g_varchar2
  ,p_user_field                    in     varchar2 default hr_api.g_varchar2
  ,p_password_field                in     varchar2 default hr_api.g_varchar2
  ,p_authentication_needed         in     varchar2 default hr_api.g_varchar2
  ,p_field_name1                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value1                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name2                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value2                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name3                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value3                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name4                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value4                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name5                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value5                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name6                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value6                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name7                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value7                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name8                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value8                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name9                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value9                  in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_integration >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a knowledge integration definition.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * The integration must exist before it can be deleted.
 *
 * <p><b>Post Success</b><br>
 * This API successfully deletes the integration and if applicable, also
 * deletes the associated external application from Single Sign On server.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration definition will not be deleted and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_sso_enabled Valid values are TRUE or FALSE. Should be set to TRUE
 * for integrations using Single Sign On server.
 * @param p_integration_id Internal unique identifier of the knowledge
 * integration record
 * @param p_object_version_number Current version number of the knowledge
 * integration definition to be deleted.
 * @rep:displayname Delete Integration
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_integration
(
 P_VALIDATE                 in boolean         default false
,P_SSO_ENABLED              in boolean   default false
,P_INTEGRATION_ID           in number
,P_OBJECT_VERSION_NUMBER    in number
);
--
end HR_KI_INTEGRATIONS_API;

 

/
