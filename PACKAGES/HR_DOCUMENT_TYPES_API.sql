--------------------------------------------------------
--  DDL for Package HR_DOCUMENT_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DOCUMENT_TYPES_API" AUTHID CURRENT_USER as
/* $Header: hrdtyapi.pkh 120.3.12010000.2 2008/08/06 08:36:12 ubhat ship $ */
/*#
 * This package contains API for document type maintenance.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Document Type
*/
--
-- -----------------------------------------------------------------------------------
-- |--------------------------< create_document_type >--------------------------|
-- -----------------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a document type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resource.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * A document type will be created.
 *
 * <p><b>Post Failure</b><br>
 * A document type will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation
 * values apply. You can set to the base or any installed language. The default
 * value of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG')
 * function value.
 * @param p_description Description of the docuement type being created.
 * @param p_document_type Document Type.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_category_code The Category Code for the Document Type.
 * @param p_active_inactive_flag The flag determines whether the Document
 * Type defined is active or inactive.
 * @param p_multiple_occurences_flag The flag determines whether multiple
 * documents of this Document Type can exist in the database.
 * @param p_authorization_required Determines whether authorization is
 * required for this Document Type.
 * @param p_sub_category_code The Subcategory Code for the Document Type.
 * @param p_legislation_code The Legislation Code for the Document Type.
 * @param p_warning_period Warning Period in number of days before the
 * document of this type expires.
 * @param p_request_id When the API is executed from a concurrent program
 * set to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a
 * concurrent program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program
 * set to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_document_type_id If p_validate is false, then it uniquely
 * identifies the document of record created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then it is set to the
 * version number of the created document extra information.
 * If p_validate is true, it will be set to null.
 * @rep:displayname Create Document Type
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_document_type(
   p_validate                       in     boolean   default false
  ,p_language_code                  IN     VARCHAR2  DEFAULT hr_api.userenv_lang
  ,p_description                    in     varchar2  default null
  ,p_document_type                  in     varchar2
  ,p_effective_date                 in     date      default sysdate
  ,p_category_code                  in     varchar2
  ,p_active_inactive_flag           in     varchar2
  ,p_multiple_occurences_flag       in     varchar2
  ,p_authorization_required         in     varchar2
  ,p_sub_category_code              in     varchar2 default null
  ,p_legislation_code               in     varchar2 default null
  ,p_warning_period                 in     number   default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default sysdate
  ,p_document_type_id               out nocopy number
  ,p_object_version_number          out nocopy number
  );
  --
  --
  -- ----------------------------------------------------------------------------
  -- |-------------------------< update_document_type >---------------------|
  -- ----------------------------------------------------------------------------
  -- {Start Of Comments}
  /*#
   * This API updates the document types.
   *
   * <p><b>Licensing</b><br>
   * This API is licensed for use with Human Resource.
   *
   * <p><b>Prerequisites</b><br>
   * Document Type must exist.
   *
   * <p><b>Post Success</b><br>
   * A document type will be updated.
   *
   * <p><b>Post Failure</b><br>
   * A document type will not be updated and an error will be raised.
   *
   * @param p_validate If true, then validation alone will be performed and
   * the database will remain unchanged. If false and all validation checks
   * pass, then the database will be modified.
   * @param p_effective_date Reference date for validating lookup values
   * are applicable during the start to end active date range. This date does
   * not determine when the changes take effect.
   * @param p_language_code Specifies to which language the translation
   * values apply. You can set to the base or any installed language. The default
   * value of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG')
   * function value.
   * @param p_description Description of the Document Type
   * @param p_document_type Defines the Basic Document Type
   * @param p_document_type_id This uniquely identifies the Document Type.
   * @param p_object_version_number Pass in the current version number of
   * the document of record to be updated. When the API completes if p_validate
   * is false, will be set to the new version number of the updated document of
   * record. If p_validate is true will be set to the same value which was
   * passed in.
   * @param p_category_code The Category Code for the Document Type.
   * @param p_active_inactive_flag The flag determines whether the Document
   * Type defined is active or inactive.
   * @param p_multiple_occurences_flag The flag determines whether multiple
   * documents of this Document Type can exist in the database.
   * @param p_legislation_code The Legislation Code for the Document Type.
   * @param p_authorization_required The flag determines whether
   * authorization is required for that Document Type.
   * @param p_sub_category_code The Sub Category Code for the Document Type
   * @param p_warning_period Warning Period in number of days before the
   * document of this type expires.
   * @param p_request_id When the API is executed from a concurrent program
   * set to the concurrent request identifier.
   * @param p_program_application_id When the API is executed from a
   * concurrent program set to the program's Application.
   * @param p_program_id When the API is executed from a concurrent program
   * set to the program's identifier.
   * @param p_program_update_date When the API is executed from a concurrent
   * program set to when the program was ran.
   * @rep:displayname Update Document Type
   * @rep:category BUSINESS_ENTITY HR_PERSON
   * @rep:lifecycle active
   * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
   * @rep:scope public
   * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
   */
  --
  -- {End Of Comments}
  --
  procedure update_document_type(
  p_validate                     in     boolean  default false
 ,p_effective_date               in     date      default sysdate
 ,p_language_code                IN     VARCHAR2  DEFAULT hr_api.userenv_lang
 ,p_description                  in     varchar2  default hr_api.g_varchar2
 ,p_document_type                in     varchar2
 ,p_document_type_id             in     number
 ,p_object_version_number        in out nocopy number
 ,p_category_code                in     varchar2
 ,p_active_inactive_flag         in     varchar2
 ,p_multiple_occurences_flag     in     varchar2
 ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
 ,p_authorization_required       in     varchar2
 ,p_sub_category_code            in     varchar2  default hr_api.g_varchar2
 ,p_warning_period               in     number    default hr_api.g_number
 ,p_request_id                   in     number    default hr_api.g_number
 ,p_program_application_id       in     number    default hr_api.g_number
 ,p_program_id                   in     number    default hr_api.g_number
 ,p_program_update_date          in     date      default hr_api.g_date
);
--
 -- ----------------------------------------------------------------------------
  -- |-------------------------< delete_document_type >---------------------|
  -- ----------------------------------------------------------------------------
  -- {Start Of Comments}
  /*#
   * This API deletes the document types.
   *
   * <p><b>Licensing</b><br>
   * This API is licensed for use with Human Resource.
   *
   * <p><b>Prerequisites</b><br>
   * Document type must exist.
   *
   * <p><b>Post Success</b><br>
   * A document type will be deleted.
   *
   * <p><b>Post Failure</b><br>
   * A document type will not be deleted and an error will be raised.
   *
   * @param p_validate If true, then validation alone will be performed and
   * the database will remain unchanged. If false and all validation checks pass,
   * then the database will be modified.
   * @param p_document_type_id Id of the Document Type
   * @param p_object_version_number Object version number of the record
   * to be deleted.
   * @rep:displayname Delete Document Type
   * @rep:category BUSINESS_ENTITY HR_PERSON
   * @rep:lifecycle active
   * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
   * @rep:scope public
   * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
   */
  --
  -- {End Of Comments}
  --
  procedure delete_document_type
    (p_validate                      in     boolean  default false
    ,p_document_type_id              in     number
    ,p_object_version_number         in     number
    );

  end hr_document_types_api;
--
--

/
