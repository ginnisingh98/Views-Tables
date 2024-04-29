--------------------------------------------------------
--  DDL for Package HR_DOCUMENT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DOCUMENT_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: hrdeiapi.pkh 120.8.12010000.2 2010/04/07 11:40:46 tkghosh ship $ */
/*#
 * This package contains procedures to create/update/delete the document of
 * record for a person.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Document API
*/
--
-- -----------------------------------------------------------------------------------
-- |--------------------------< create_doc_extra_info >--------------------------|
-- -----------------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a document of record for a person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resource.
 *
 * <p><b>Prerequisites</b><br>
 * A person must exist.
 *
 * <p><b>Post Success</b><br>
 * A document of record will be created.
 *
 * <p><b>Post Failure</b><br>
 * A document of record will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create
 * the document extra information record.
 * @param p_document_type_id Identifies the document type of the document
 * to be created.
 * @param p_date_from Document is valid from which date
 * @param p_date_to Document is valid till which date
 * @param p_document_number Identifies the Document number of the document.
 * @param p_issued_by Identifies the person who issues the document.
 * @param p_issued_at Identifies the location where the document is issued.
 * @param p_issued_date Identifies the date when the document is issued.
 * @param p_issuing_authority Identifies the Issuing Authority of the
 * document.
 * @param p_verified_by Identfies the person who verifies the document.
 * @param p_verified_date Identifies the date when the document is verified.
 * @param p_related_object_name Identifies the Related Object Name
 * @param p_related_object_id_col Identifies the Related Object Id Column of
 * the document
 * @param p_related_object_id Identfies the Related Object Id of the document.
 * @param p_dei_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_dei_attribute1 Descriptive flexfield segment
 * @param p_dei_attribute2 Descriptive flexfield segment
 * @param p_dei_attribute3 Descriptive flexfield segment
 * @param p_dei_attribute4 Descriptive flexfield segment
 * @param p_dei_attribute5 Descriptive flexfield segment
 * @param p_dei_attribute6 Descriptive flexfield segment
 * @param p_dei_attribute7 Descriptive flexfield segment
 * @param p_dei_attribute8 Descriptive flexfield segment
 * @param p_dei_attribute9 Descriptive flexfield segment
 * @param p_dei_attribute10 Descriptive flexfield segment
 * @param p_dei_attribute11 Descriptive flexfield segment
 * @param p_dei_attribute12 Descriptive flexfield segment
 * @param p_dei_attribute13 Descriptive flexfield segment
 * @param p_dei_attribute14 Descriptive flexfield segment
 * @param p_dei_attribute15 Descriptive flexfield segment
 * @param p_dei_attribute16 Descriptive flexfield segment
 * @param p_dei_attribute17 Descriptive flexfield segment
 * @param p_dei_attribute18 Descriptive flexfield segment
 * @param p_dei_attribute19 Descriptive flexfield segment
 * @param p_dei_attribute20 Descriptive flexfield segment
 * @param p_dei_attribute21 Descriptive flexfield segment
 * @param p_dei_attribute22 Descriptive flexfield segment
 * @param p_dei_attribute23 Descriptive flexfield segment
 * @param p_dei_attribute24 Descriptive flexfield segment
 * @param p_dei_attribute25 Descriptive flexfield segment
 * @param p_dei_attribute26 Descriptive flexfield segment
 * @param p_dei_attribute27 Descriptive flexfield segment
 * @param p_dei_attribute28 Descriptive flexfield segment
 * @param p_dei_attribute29 Descriptive flexfield segment
 * @param p_dei_attribute30 Descriptive flexfield segment
 * @param p_dei_information_category  This context value determines which
 * flexfield structure to use with the developer descriptive flexfield segments
 * @param p_dei_information1 Developer Descriptive flexfield segment
 * @param p_dei_information2 Developer Descriptive flexfield segment
 * @param p_dei_information3 Developer Descriptive flexfield segment
 * @param p_dei_information4 Developer Descriptive flexfield segment
 * @param p_dei_information5 Developer Descriptive flexfield segment
 * @param p_dei_information6 Developer Descriptive flexfield segment
 * @param p_dei_information7 Developer Descriptive flexfield segment
 * @param p_dei_information8 Developer Descriptive flexfield segment
 * @param p_dei_information9 Developer Descriptive flexfield segment
 * @param p_dei_information10 Developer Descriptive flexfield segment
 * @param p_dei_information11 Developer Descriptive flexfield segment
 * @param p_dei_information12 Developer Descriptive flexfield segment
 * @param p_dei_information13 Developer Descriptive flexfield segment
 * @param p_dei_information14 Developer Descriptive flexfield segment
 * @param p_dei_information15 Developer Descriptive flexfield segment
 * @param p_dei_information16 Developer Descriptive flexfield segment
 * @param p_dei_information17 Developer Descriptive flexfield segment
 * @param p_dei_information18 Developer Descriptive flexfield segment
 * @param p_dei_information19 Developer Descriptive flexfield segment
 * @param p_dei_information20 Developer Descriptive flexfield segment
 * @param p_dei_information21 Developer Descriptive flexfield segment
 * @param p_dei_information22 Developer Descriptive flexfield segment
 * @param p_dei_information23 Developer Descriptive flexfield segment
 * @param p_dei_information24 Developer Descriptive flexfield segment
 * @param p_dei_information25 Developer Descriptive flexfield segment
 * @param p_dei_information26 Developer Descriptive flexfield segment
 * @param p_dei_information27 Developer Descriptive flexfield segment
 * @param p_dei_information28 Developer Descriptive flexfield segment
 * @param p_dei_information29 Developer Descriptive flexfield segment
 * @param p_dei_information30 Developer Descriptive flexfield segment
 * @param p_request_id When the API is executed from a concurrent program
 * set to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a
 * concurrent program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program
 * set to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_document_extra_info_id If p_validate is false, then this
 * uniquely identifies the document extra info created.If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created document extra information. If p_validate is
 * true,then the value will be null.
 * @rep:displayname Create Person Document
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_doc_extra_info(
   p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_document_type_id              in     number
  ,p_date_from                     in     date
  ,p_date_to                       in     date  default null
  ,p_document_number               in     varchar2 default null
  ,p_issued_by                     in     varchar2 default null
  ,p_issued_at                     in     varchar2 default null
  ,p_issued_date                   in     date     default null
  ,p_issuing_authority             in     varchar2 default null
  ,p_verified_by                   in     number   default null
  ,p_verified_date                 in     date     default null
  ,p_related_object_name           in     varchar2 default null
  ,p_related_object_id_col         in     varchar2 default null
  ,p_related_object_id             in     number   default null
  ,p_dei_attribute_category        in     varchar2 default null
  ,p_dei_attribute1                in     varchar2 default null
  ,p_dei_attribute2                in     varchar2 default null
  ,p_dei_attribute3                in     varchar2 default null
  ,p_dei_attribute4                in     varchar2 default null
  ,p_dei_attribute5                in     varchar2 default null
  ,p_dei_attribute6                in     varchar2 default null
  ,p_dei_attribute7                in     varchar2 default null
  ,p_dei_attribute8                in     varchar2 default null
  ,p_dei_attribute9                in     varchar2 default null
  ,p_dei_attribute10               in     varchar2 default null
  ,p_dei_attribute11               in     varchar2 default null
  ,p_dei_attribute12               in     varchar2 default null
  ,p_dei_attribute13               in     varchar2 default null
  ,p_dei_attribute14               in     varchar2 default null
  ,p_dei_attribute15               in     varchar2 default null
  ,p_dei_attribute16               in     varchar2 default null
  ,p_dei_attribute17               in     varchar2 default null
  ,p_dei_attribute18               in     varchar2 default null
  ,p_dei_attribute19               in     varchar2 default null
  ,p_dei_attribute20               in     varchar2 default null
  ,p_dei_attribute21               in     varchar2 default null
  ,p_dei_attribute22               in     varchar2 default null
  ,p_dei_attribute23               in     varchar2 default null
  ,p_dei_attribute24               in     varchar2 default null
  ,p_dei_attribute25               in     varchar2 default null
  ,p_dei_attribute26               in     varchar2 default null
  ,p_dei_attribute27               in     varchar2 default null
  ,p_dei_attribute28               in     varchar2 default null
  ,p_dei_attribute29               in     varchar2 default null
  ,p_dei_attribute30               in     varchar2 default null
  ,p_dei_information_category      in     varchar2 default null
  ,p_dei_information1              in     varchar2 default null
  ,p_dei_information2              in     varchar2 default null
  ,p_dei_information3              in     varchar2 default null
  ,p_dei_information4              in     varchar2 default null
  ,p_dei_information5              in     varchar2 default null
  ,p_dei_information6              in     varchar2 default null
  ,p_dei_information7              in     varchar2 default null
  ,p_dei_information8              in     varchar2 default null
  ,p_dei_information9              in     varchar2 default null
  ,p_dei_information10             in     varchar2 default null
  ,p_dei_information11             in     varchar2 default null
  ,p_dei_information12             in     varchar2 default null
  ,p_dei_information13             in     varchar2 default null
  ,p_dei_information14             in     varchar2 default null
  ,p_dei_information15             in     varchar2 default null
  ,p_dei_information16             in     varchar2 default null
  ,p_dei_information17             in     varchar2 default null
  ,p_dei_information18             in     varchar2 default null
  ,p_dei_information19             in     varchar2 default null
  ,p_dei_information20             in     varchar2 default null
  ,p_dei_information21             in     varchar2 default null
  ,p_dei_information22             in     varchar2 default null
  ,p_dei_information23             in     varchar2 default null
  ,p_dei_information24             in     varchar2 default null
  ,p_dei_information25             in     varchar2 default null
  ,p_dei_information26             in     varchar2 default null
  ,p_dei_information27             in     varchar2 default null
  ,p_dei_information28             in     varchar2 default null
  ,p_dei_information29             in     varchar2 default null
  ,p_dei_information30             in     varchar2 default null
  ,p_request_id                    in     number   default null
  ,p_program_application_id        in     number   default null
  ,p_program_id                    in     number   default null
  ,p_program_update_date           in     date     default null
  ,p_document_extra_info_id        out    nocopy number
  ,p_object_version_number         out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_doc_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the document of record for a person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resource
 *
 * <p><b>Prerequisites</b><br>
 * Document of record must exist for a person.
 *
 * <p><b>Post Success</b><br>
 * The document of record will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The document of record will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_document_extra_info_id Identifies the document record to modify.
 * @param p_person_id Identifies the person record for which the document is
 * to be modified.
 * @param p_document_type_id Identifies the document type of the document to
 * modify.
 * @param p_date_from Document is valid from which date
 * @param p_date_to Document is valid till which date
 * @param p_document_number Identifies the Document Number of the document.
 * @param p_issued_by Identifies the person who issues the document.
 * @param p_issued_at Identifies the location where the document is issued.
 * @param p_issued_date Identifies the date when the document is issued.
 * @param p_issuing_authority Identifies the Issuing Authority of the document.
 * @param p_verified_by Identfies the person who verifies the document.
 * @param p_verified_date Identifies the date when the document is verified.
 * @param p_related_object_name Identifies the Related Object Name.
 * @param p_related_object_id_col Identifies the Related Object Id Column
 * of the document.
 * @param p_related_object_id Identfies the Related Object Id of the document.
 * @param p_dei_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_dei_attribute1 Descriptive flexfield segment
 * @param p_dei_attribute2 Descriptive flexfield segment
 * @param p_dei_attribute3 Descriptive flexfield segment
 * @param p_dei_attribute4 Descriptive flexfield segment
 * @param p_dei_attribute5 Descriptive flexfield segment
 * @param p_dei_attribute6 Descriptive flexfield segment
 * @param p_dei_attribute7 Descriptive flexfield segment
 * @param p_dei_attribute8 Descriptive flexfield segment
 * @param p_dei_attribute9 Descriptive flexfield segment
 * @param p_dei_attribute10 Descriptive flexfield segment
 * @param p_dei_attribute11 Descriptive flexfield segment
 * @param p_dei_attribute12 Descriptive flexfield segment
 * @param p_dei_attribute13 Descriptive flexfield segment
 * @param p_dei_attribute14 Descriptive flexfield segment
 * @param p_dei_attribute15 Descriptive flexfield segment
 * @param p_dei_attribute16 Descriptive flexfield segment
 * @param p_dei_attribute17 Descriptive flexfield segment
 * @param p_dei_attribute18 Descriptive flexfield segment
 * @param p_dei_attribute19 Descriptive flexfield segment
 * @param p_dei_attribute20 Descriptive flexfield segment
 * @param p_dei_attribute21 Descriptive flexfield segment
 * @param p_dei_attribute22 Descriptive flexfield segment
 * @param p_dei_attribute23 Descriptive flexfield segment
 * @param p_dei_attribute24 Descriptive flexfield segment
 * @param p_dei_attribute25 Descriptive flexfield segment
 * @param p_dei_attribute26 Descriptive flexfield segment
 * @param p_dei_attribute27 Descriptive flexfield segment
 * @param p_dei_attribute28 Descriptive flexfield segment
 * @param p_dei_attribute29 Descriptive flexfield segment
 * @param p_dei_attribute30 Descriptive flexfield segment
 * @param p_dei_information_category  This context value determines which
 * flexfield structure to use with the developer descriptive flexfield segments
 * @param p_dei_information1 Developer Descriptive flexfield segment
 * @param p_dei_information2 Developer Descriptive flexfield segment
 * @param p_dei_information3 Developer Descriptive flexfield segment
 * @param p_dei_information4 Developer Descriptive flexfield segment
 * @param p_dei_information5 Developer Descriptive flexfield segment
 * @param p_dei_information6 Developer Descriptive flexfield segment
 * @param p_dei_information7 Developer Descriptive flexfield segment
 * @param p_dei_information8 Developer Descriptive flexfield segment
 * @param p_dei_information9 Developer Descriptive flexfield segment
 * @param p_dei_information10 Developer Descriptive flexfield segment
 * @param p_dei_information11 Developer Descriptive flexfield segment
 * @param p_dei_information12 Developer Descriptive flexfield segment
 * @param p_dei_information13 Developer Descriptive flexfield segment
 * @param p_dei_information14 Developer Descriptive flexfield segment
 * @param p_dei_information15 Developer Descriptive flexfield segment
 * @param p_dei_information16 Developer Descriptive flexfield segment
 * @param p_dei_information17 Developer Descriptive flexfield segment
 * @param p_dei_information18 Developer Descriptive flexfield segment
 * @param p_dei_information19 Developer Descriptive flexfield segment
 * @param p_dei_information20 Developer Descriptive flexfield segment
 * @param p_dei_information21 Developer Descriptive flexfield segment
 * @param p_dei_information22 Developer Descriptive flexfield segment
 * @param p_dei_information23 Developer Descriptive flexfield segment
 * @param p_dei_information24 Developer Descriptive flexfield segment
 * @param p_dei_information25 Developer Descriptive flexfield segment
 * @param p_dei_information26 Developer Descriptive flexfield segment
 * @param p_dei_information27 Developer Descriptive flexfield segment
 * @param p_dei_information28 Developer Descriptive flexfield segment
 * @param p_dei_information29 Developer Descriptive flexfield segment
 * @param p_dei_information30 Developer Descriptive flexfield segment
 * @param p_request_id When the API is executed from a concurrent program
 * set to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a
 * concurrent program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program
 * set to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_object_version_number Pass in the current version number of
 * the document extra information to be updated. When the API completes
 * if p_validate is false, will be set to the new version number of the
 * updated document extra information. If p_validate is true will be set
 * to the same value which was passed in.
 * @rep:displayname Update Person Document
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_doc_extra_info
  (p_validate                      in     boolean  default false
  ,p_document_extra_info_id        in     number
  ,p_person_id                     in     number
  ,p_document_type_id              in     number
  ,p_date_from                     in     date
  ,p_date_to                       in     date  default  hr_api.g_date
  ,p_document_number               in     varchar2 default hr_api.g_varchar2
  ,p_issued_by                     in     varchar2 default hr_api.g_varchar2
  ,p_issued_at                     in     varchar2 default hr_api.g_varchar2
  ,p_issued_date                   in     date     default hr_api.g_date
  ,p_issuing_authority             in     varchar2 default hr_api.g_varchar2
  ,p_verified_by                   in     number   default hr_api.g_number
  ,p_verified_date                 in     date     default hr_api.g_date
  ,p_related_object_name           in     varchar2 default hr_api.g_varchar2
  ,p_related_object_id_col         in     varchar2 default hr_api.g_varchar2
  ,p_related_object_id             in     number   default hr_api.g_number
  ,p_dei_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute21               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute22               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute23               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute24               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute25               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute26               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute27               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute28               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute29               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute30               in     varchar2 default hr_api.g_varchar2
  ,p_dei_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_dei_information1              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information2              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information3              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information4              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information5              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information6              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information7              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information8              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information9              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information10             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information11             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information12             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information13             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information14             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information15             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information16             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information17             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information18             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information19             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information20             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information21             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information22             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information23             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information24             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information25             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information26             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information27             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information28             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information29             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information30             in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_doc_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the document of record for a person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resource.
 *
 * <p><b>Prerequisites</b><br>
 * Document of record must exist for a person.
 *
 * <p><b>Post Success</b><br>
 * The document of record will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The document of record will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_document_extra_info_id If p_validate is false, then this
 * uniquely identifies the document extra info to be deleted. If p_validate is
 * true, then set to null.
 * @param p_object_version_number Current version number of the document
 * extra information to be deleted.
 * @rep:displayname Delete Person Document
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_doc_extra_info
  (p_validate                      in     boolean  default false
  ,p_document_extra_info_id        in     number
  ,p_object_version_number         in     number
  );

  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------< set_reviewer >------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --  Sets the value of workflow attribute - Reviewer.
  --  This procedure is called by Documents of Record workflow process.
  --
  --
  -- Prerequisites:
  --  None
  --
  -- In Parameters:
  --   Name                           Reqd Type     Description
  --   itemtype                       Yes  Varchar2 Identifies workflow item type
  --   itemkey                        Yes  Varchar2 Identifies workflow process
  --   actid                          Yes  Number   Identifies workflow activity
  --   funcmode                       Yes  Varchar2 Identifies activity execution mode
  --
  --
  -- Post Success:
  --   The workflow attribute value will be set for Reviewer.
  --
  --   Returns the parameter value.
  --
  --   Name                           Type     Description
  --   resultout                      Varchar2 Indicates whether or not workflow
  --                                           attribute is set.
  --
  -- Post Failure:
  -- Workflow error will be raised.
  --
  -- Access Status:
  --   Internal Development Use Only.
  --
  -- {End Of Comments}
  --
  procedure set_reviewer (itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout out nocopy varchar2);


  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------< set_reviewee >------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --  Checks whether workflow attribute Reviewee is set.
  --  This procedure is called by Documents of Record workflow process.
  --
  --
  -- Prerequisites:
  --  None
  --
  -- In Parameters:
  --   Name                           Reqd Type     Description
  --   itemtype                       Yes  Varchar2 Identifies workflow item type
  --   itemkey                        Yes  Varchar2 Identifies workflow process
  --   actid                          Yes  Number   Identifies workflow activity
  --   funcmode                       Yes  Varchar2 Identifies activity execution mode
  --
  --
  -- Post Success:
  --
  --   Returns the parameter value.
  --
  --   Name                           Type     Description
  --   resultout                      Varchar2 Indicates whether or not workflow
  --                                           attribute is set.
  --
  -- Post Failure:
  -- Workflow error will be raised.
  --
  -- Access Status:
  --   Internal Development Use Only.
  --
  -- {End Of Comments}
  --
  procedure set_reviewee (itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout out nocopy varchar2);

  --
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------<  get_view_pg_wf_notif_params >----------------------|
  -- ----------------------------------------------------------------------------
  --
 -- {Start Of Comments}
  --
  -- Description:
  --  Retrieves the notification parameter values for a given notification
  --  identifier.
  --  This procedure is called by Documents of Record functions.
  --
  --
  -- Prerequisites:
  --  None
  --
  -- In Parameters:
  --   Name                           Reqd Type     Description
  --   p_notification_id              Yes  Number   Identifies the notification.
  --
  --
  -- Post Success:
  --   Returns the parameter values.
  --
  --   Name                           Type     Description
  --   p_dor_id                       Number   Identifies the person document
  --   p_person_id                    Number   Identifies the person
  --   p_effective_date               Date     Date on which person is active.
  --
  --
  -- Post Failure:
  -- An oracle error will be raised.
  --
  -- Access Status:
  --   Internal Development Use Only.
  --
  -- {End Of Comments}
  --
  procedure get_view_pg_wf_notif_params (p_notification_id in number,
                                         p_dor_id          out nocopy varchar2,
                                         p_person_id       out nocopy varchar2,
                                         p_effective_date  out nocopy date);

end hr_document_extra_info_api;

--
--

--
--

/
