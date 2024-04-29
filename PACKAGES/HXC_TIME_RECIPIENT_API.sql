--------------------------------------------------------
--  DDL for Package HXC_TIME_RECIPIENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_RECIPIENT_API" AUTHID CURRENT_USER as
/* $Header: hxchtrapi.pkh 120.1 2005/10/02 02:06:55 aroussel $ */
/*#
 * This package contains Time Recipient APIs.
 * @rep:scope public
 * @rep:product hxt
 * @rep:displayname Time Recipient
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_time_recipient >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Time Recipient within the Time Store.
 *
 * This API creates the details of the Recipient Applications that are
 * registered to use the Time Store.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Application for which the Time Recipient is created must exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Recipient will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The Time Recipient will not be inserted and an application error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_time_recipient_id Primary Key for entity.
 * @param p_application_id Foreign key to FND_APPLICATION.
 * @param p_object_version_number If P_VALIDATE is false, then the value is set
 * to the version number of the created Time Recipient. If P_VALIDATE is true,
 * then the value will be null.
 * @param p_name Name for the Time Recipient.
 * @param p_appl_retrieval_function Package procedure to obtain application
 * mapping.
 * @param p_appl_update_process Package procedure for application specific
 * updates to time data.
 * @param p_appl_validation_process Package procedure to application specific
 * validation.
 * @param p_appl_period_function Package procedure to support application
 * specific time periods.
 * @param p_appl_dyn_template_process Package procedure used to implement a
 * dynamic template selected on the timecard page.
 * @param p_extension_function1 Package procedure to support client hooks.
 * @param p_extension_function2 Package procedure to support client hooks.
 * @rep:displayname Create Time Recipient
 * @rep:category BUSINESS_ENTITY HXC_TIME_RECIPIENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_time_recipient
  (p_validate                       in      boolean   default false
  ,p_time_recipient_id              in  out nocopy hxc_time_recipients.time_recipient_id%TYPE
  ,p_application_id                 in  out nocopy hxc_time_recipients.application_id%TYPE
  ,p_object_version_number          in  out nocopy hxc_time_recipients.object_version_number%TYPE
  ,p_name                           in      varchar2
  ,p_appl_retrieval_function        in      varchar2 default NULL
  ,p_appl_update_process            in      varchar2 default NULL
  ,p_appl_validation_process        in      varchar2 default NULL
  ,p_appl_period_function           in      varchar2 default NULL
  ,p_appl_dyn_template_process      in      varchar2 default NULL
  ,p_extension_function1            in      varchar2 default NULL
  ,p_extension_function2            in      varchar2 default NULL
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_time_recipient >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Time Recipient with a given name and
 * application.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Recipient must exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Recipient will be updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The Time Recipient will not be updated and an application error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_time_recipient_id Primary Key for entity.
 * @param p_application_id Foreign key to FND_APPLICATION.
 * @param p_object_version_number Pass in the current version number of the
 * Time Recipient to be updated. If P_VALIDATE is false, then the value will be
 * set to the new version number of the updated Time Recipient. If P_VALIDATE
 * is true, then the value will be set to the value passed.
 * @param p_name Name for the Time Recipient.
 * @param p_appl_retrieval_function Package procedure to obtain application
 * mapping.
 * @param p_appl_update_process Package procedure for application specific
 * updates to time data.
 * @param p_appl_validation_process Package procedure to application specific
 * validation.
 * @param p_appl_period_function Package procedure to support application
 * specific time periods.
 * @param p_appl_dyn_template_process Package procedure used to implement a
 * dynamic template selected on the timecard page.
 * @param p_extension_function1 Package procedure to support client hooks.
 * @param p_extension_function2 Package procedure to support client hooks.
 * @rep:displayname Update Time Recipient
 * @rep:category BUSINESS_ENTITY HXC_TIME_RECIPIENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_time_recipient
  (p_validate                       in      boolean   default false
  ,p_time_recipient_id              in      hxc_time_recipients.time_recipient_id%TYPE
  ,p_application_id                 in      hxc_time_recipients.application_id%TYPE
  ,p_object_version_number          in  out nocopy hxc_time_recipients.object_version_number%TYPE
  ,p_name                           in      hxc_time_recipients.name%TYPE
  ,p_appl_retrieval_function        in      varchar2 default NULL
  ,p_appl_update_process            in      varchar2 default NULL
  ,p_appl_validation_process        in      varchar2 default NULL
  ,p_appl_period_function           in      varchar2 default NULL
  ,p_appl_dyn_template_process      in      varchar2 default NULL
  ,p_extension_function1            in      varchar2 default NULL
  ,p_extension_function2            in      varchar2 default NULL
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_time_recipient >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Time Recipient.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Recipient must exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Recipient will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The Time Recipient will not be deleted and an application error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_time_recipient_id Primary Key for entity.
 * @param p_object_version_number Current version number to be deleted.
 * @rep:displayname Delete Time Recipient
 * @rep:category BUSINESS_ENTITY HXC_TIME_RECIPIENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_time_recipient
  (p_validate                       in  boolean  default false
  ,p_time_recipient_id              in  hxc_time_recipients.time_recipient_id%TYPE
  ,p_object_version_number          in  hxc_time_recipients.object_version_number%TYPE
  );
--
--
END hxc_time_recipient_api;

 

/
