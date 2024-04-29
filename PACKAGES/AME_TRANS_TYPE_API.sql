--------------------------------------------------------
--  DDL for Package AME_TRANS_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_TRANS_TYPE_API" AUTHID CURRENT_USER as
/* $Header: amacaapi.pkh 120.1.12010000.2 2019/09/12 11:53:09 jaakhtar ship $ */
/*#
 * This package contains the AME Transaction Type APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Transaction Type
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_transaction_type >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * Transaction type is created. Application_id, object_version_number,
 * start_date and end_date are set for the new transaction type.
 *
 * <p><b>Post Failure</b><br>
 * The transaction type is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_application_name The name of the transaction type being created.
 * Typically this property must identify the nature of the transaction.
 * @param p_fnd_application_id The fnd_application ID of the transaction type
 * being created. It should be present in the fnd_application table.
 * @param p_transaction_type_id This is an user defined ID for the
 * Transaction Type.
 * @param p_application_id If p_validate is false, then this uniquely
 * identifies the transaction type created. If p_validate is true,
 * then it is set to null.
 * @param p_object_version_number If p_validate is false, then it is set to
 * version number of the created transaction type. If p_validate is true,
 * then it is set to null.
 * @param p_start_date If p_validate is false, then it is set to the
 * effective start date for the created transaction type.
 * If p_validate is true, then it is set to null.
 * @param p_end_date It is the date upto which the transaction type is
 * effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @rep:displayname Create Transaction Type
 * @rep:category BUSINESS_ENTITY AME_TRANSACTION_TYPE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_transaction_type
  (p_validate              in     boolean  default false
  ,p_language_code         in     varchar2 default hr_api.userenv_lang
  ,p_application_name      in     varchar2
  ,p_fnd_application_id    in     number
  ,p_transaction_type_id   in     varchar2
  ,p_application_id           out nocopy number
  ,p_object_version_number    out nocopy number
  ,p_start_date               out nocopy date
  ,p_end_date                 out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ame_transaction_type >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a given transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The application_id which identifies the transaction type should be valid.
 *
 * <p><b>Post Success</b><br>
 * The transaction type is updated.
 *
 * <p><b>Post Failure</b><br>
 * The transaction type is not updated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_application_name The new name of the transaction type.
 * @param p_application_id This uniquely identifies the transaction type
 * to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * transaction type to be updated. When the API completes, if p_validate is
 * false, it will be set to the new version number of the updated
 * transaction type. If p_validate is true, will be set to the same value
 * which was passed in.
 * @param p_start_date If p_validate is false, It is set to present date.
 * If p_validate is true, it is set to null.
 * @param p_end_date It is the date upto which the updated transaction type
 * is effective. If p_validate is false, it is set to 31-Dec-4712.
 * If p_validate is true, it is set to null.
 * @rep:displayname Update Transaction Type
 * @rep:category BUSINESS_ENTITY AME_TRANSACTION_TYPE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_transaction_type
  (p_validate                    in     boolean  default false
  ,p_language_code               in     varchar2 default hr_api.userenv_lang
  ,p_application_name            in     varchar2 default hr_api.g_varchar2
  ,p_application_id              in     number
  ,p_object_version_number       in out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_transaction_type >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a given transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The application_id which identifies the transaction type should be valid.
 *
 * <p><b>Post Success</b><br>
 * The transaction type is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The transaction type is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_application_id This uniquely identifies the transaction type
 * to be deleted.
 * @param p_object_version_number Pass in the current version number of the
 * transaction type to be deleted. When the API completes, if p_validate
 * is false, it will be set to the new version number of the deleted
 * transaction type. If p_validate is true, will be set to the same value
 * which was passed in.
 * @param p_start_date If p_validate is false, it is set to the date from
 * which the deleted transaction type was effective. If p_validate is true,
 * it is set to null.
 * @param p_end_date If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to null.
 * @rep:displayname Delete Transaction Type
 * @rep:category BUSINESS_ENTITY AME_TRANSACTION_TYPE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_transaction_type
  (p_validate               in     boolean  default false
  ,p_application_id         in     number
  ,p_object_version_number  in out nocopy number
  ,p_start_date                out nocopy date
  ,p_end_date                  out nocopy date
  );
--
end AME_TRANS_TYPE_API;

/
