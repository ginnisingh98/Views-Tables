--------------------------------------------------------
--  DDL for Package IRC_DOCUMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOCUMENT_API" AUTHID CURRENT_USER as
/* $Header: iridoapi.pkh 120.7.12010000.1 2008/07/28 12:41:55 appldev ship $ */
/*#
 * This package contains Document APIs.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Document
*/
-- Global variables
--
  IRC_MARKUP_STARTTAG VARCHAR2(100)  := '<b style="BACKGROUND-COLOR: #ffff66">';
  IRC_MARKUP_ENDTAG   VARCHAR2(100)  := '</b>';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< synchronize_index >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API synchronizes the document text indexes.
 *
 * The API will either add new entries (ONLINE mode) or update and delete old
 * entries (FULL mode). If the mode is NONE then no action will be performed.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will rebuild the index
 *
 * <p><b>Post Failure</b><br>
 * The API will not rebuild the index and an error will be raised
 * @param p_mode Mode can be ONLINE, FULL or NONE
 * @rep:displayname Synchronize Index
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_DOCUMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure synchronize_index(p_mode in varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_document >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a document for a candidate.
 *
 * This API inserts an empty_blob in to the database that can subsequently be
 * used to stream the file in to. This is a second step subsequent to running
 * the API. After streaming the document in to the binary_doc column, the
 * process_document procedure in this package must be run to synchronize this
 * data with the other columns.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The person must already exist
 *
 * <p><b>Post Success</b><br>
 * The document will be created in the database
 *
 * <p><b>Post Failure</b><br>
 * The document will not be created in the database and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_type The type of document. Valid values are defined by
 * 'IRC_DOCUMENT_TYPE' lookup type.
 * @param p_person_id Identifies the person for whom you create the document
 * record.
 * @param p_mime_type MIME type of the file
 * @param p_assignment_id Identifies the assignment for which you create the
 * document record. Not yet used in the iRecruitment application.
 * @param p_file_name The name of the file
 * @param p_description A description of the file
 * @param p_end_date Identifies the date when the record is end dated.
 * @param p_document_id If p_validate is false, then this uniquely identifies
 * the document created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created document. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Document
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_DOCUMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_person_id                     in     number
  ,p_mime_type                     in     varchar2
  ,p_assignment_id                 in     number   default null
  ,p_file_name                     in     varchar2 default null
  ,p_description                   in     varchar2 default Null
  ,p_end_date			   in     date     default Null
  ,p_document_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_document >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the details of a document.
 *
 * This API does not update the actual document itself. If you need to do that
 * then you should select the binary_doc blob from the database and stream the
 * new contents in to it. After streaming the document in to the binary_doc
 * column, the process_document procedure in this package must be run to
 * synchronize this data with the other columns.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The document must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The document will be updated in the database
 *
 * <p><b>Post Failure</b><br>
 * The document will not be updated in the database and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_document_id Identifies the document which is being updated
 * @param p_mime_type MIME type of upload file
 * @param p_type The type of document. Valid values are defined by
 * 'IRC_DOCUMENT_TYPE' lookup type.
 * @param p_file_name The name of the file
 * @param p_description A description of the file
 * @param p_object_version_number Pass in the current version number of the
 * document to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated document. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Document
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_DOCUMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_mime_type                     in     varchar2 default HR_API.G_VARCHAR2
  ,p_type                          in     varchar2 default HR_API.G_VARCHAR2
  ,p_file_name                     in     varchar2 default HR_API.G_VARCHAR2
  ,p_description                   in     varchar2 default HR_API.G_VARCHAR2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_document_track >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the details of a document and track the documents for
 * internet applicants.
 *
 * This API does not update the actual document itself. If you need to do that
 * then you should select the binary_doc blob from the database and stream the
 * new contents in to it. After streaming the document in to the binary_doc
 * column, the process_document procedure in this package must be run to
 * synchronize this data with the other columns.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The document must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The document will be updated in the database
 *
 * <p><b>Post Failure</b><br>
 * The document will not be updated in the database and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_document_id Identifies the document which is being updated
 * @param p_mime_type MIME type of upload file
 * @param p_type The type of document. Valid values are defined by
 * 'IRC_DOCUMENT_TYPE' lookup type.
 * @param p_file_name The name of the file
 * @param p_description A description of the file
 * @param p_person_id Identifies the person_id of the person
 * to whom the document belongs to.
 * @param p_party_id Identifies the party_id of the person
 * to whom the document belongs to.
 * @param p_end_date Identifies the date when the record is end dated.
 * @param p_assignment_id Identifies the assignment id of the applicantion.
 * @param p_object_version_number Pass in the current version number of the
 * document to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated document. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_new_doc_id If p_validate is false, then this uniquely identifies
 * the new document. If p_validate is true, then set to null.
 * @rep:displayname Update Document
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_DOCUMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_DOCUMENT_TRACK
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_mime_type                     in     varchar2 default HR_API.G_VARCHAR2
  ,p_type                          in     varchar2 default HR_API.G_VARCHAR2
  ,p_file_name                     in     varchar2 default HR_API.G_VARCHAR2
  ,p_description                   in     varchar2 default HR_API.G_VARCHAR2
  ,p_person_id			   in     number   default HR_API.G_NUMBER
  ,p_party_id			   in	  number   default HR_API.G_NUMBER
  ,p_end_date			   in	  date	   default HR_API.G_DATE
  ,p_assignment_id		   in     number   default HR_API.G_NUMBER
  ,p_object_version_number         in out nocopy number
  ,p_new_doc_id			   out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_document >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a document.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The document must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The document will be deleted from the database
 *
 * <p><b>Post Failure</b><br>
 * The document will not be deleted from the database and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_document_id Identifies the document which is being updated
 * @param p_object_version_number Current version number of the document to be
 * deleted.
 * @param p_person_id Identifies the person_id of the person
 * to whom the document belongs to.
 * @param p_party_id Identifies the party_id of the person
 * to whom the document belongs to.
 * @param p_end_date Identifies the date when the record is deleted.
 * @param p_type Identifies the document type.
 * @param p_purge Identifies if the document should be deleted or end_dated.
 * @rep:displayname Delete Document
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_DOCUMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_object_version_number         in     number
  ,p_person_id                     in     number
  ,p_party_id			   in	  number
  ,p_end_date			   in     Date
  ,p_type                          in     varchar2
  ,p_purge			   in     varchar2 default 'N'
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< PROCESS_DOCUMENT >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to perform required post insert / update processing
--   on documents stored in the IRC_DOCUMENTS table.  This procedure MUST be
--   called after every call to CREATE_DOCUMENT or UPDATE_DOCUMENT.  This
--   procedure performs the conversion from character data stored in
--   IRC_DOCUMENTS.BINARY_DOC into character data stored in
--   IRC_DOCUMENTS.CHARACTER_DOC.  In addition it also performs fast / full
--   synchronization of the data in CHARACTER_DOC to allow it to be searched.
--
--   NOTE: Full synchronization should only be performed at a time when NO
--         DML is being performed on IRC_DOCUMENTS.  If DML exists, it will
--         FAIL.
--
-- Prerequisites:
--   (i)  The DOCUMENT_ID must exist within the IRC_DOCUMENTS table.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  Commit or rollback
--   p_document_id                  Yes  number   PK of document
--   p_synchronization_level        Yes  varchar2 Full / Fast snychronization
--
-- Post Success:
--   The IRC_DOCUMENTS.CHARACTER_DOC will be populated with inserted / updated
--   data.  interMedia index will be resynchronized.
--
-- Post Failure:
--   An error will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure PROCESS_DOCUMENT
  (p_document_id                   in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< GET_HTML_PREVIEW >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to return a html representation of the binary file
--   stored in irc_documents.binary_doc. If the highlight string is passed
--   then the keywords are highlighted accordingly in the html document.
--
-- Prerequisites:
--   (i)  The DOCUMENT_ID must exist within the IRC_DOCUMENTS table.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_document_id                   Yes number   PK of IRC_DOCUMENTS
--   p_highlight_string             No   varchar2 Keywords to be highlighted
-- Out Parameters:
--                                       clob     HTML representation of file
--
-- Post Success:
--   The clob returned will contain an HTML representation of the binary file.
--
-- Post Failure:
--   An error will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function GET_HTML_PREVIEW
  (p_document_id in number,p_highlight_string in varchar2 default null) return clob;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< IS_INTERNET_APPLICANT >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided check whether the Applicant Is an Internet Applicant.
--   To be an Internet Applicant, the Applicant should have atleast one active
--   Job Application in the Business Group which has Applicant Tracking
--   enabled.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_document_id                   Yes number   PK of IRC_DOCUMENTS
--   p_person_id		     No  number   Person id
--   p_party_id			     Yes number   Party id For the person
-- Out Parameters:
--   p_num_job_applications              number   number of job applications
--                                                for the party id in the
--                                                BG which has Applicant
--                                                tracking enabled
--
-- Post Success:
--   The number of job applications for the applicant will be returned
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure IS_INTERNET_APPLICANT
  (	p_document_id		in		number,
	p_person_id		in		number,
	p_party_id		in		number,
	p_num_job_applications	out nocopy	number	) ;
--

end IRC_DOCUMENT_API;

/
