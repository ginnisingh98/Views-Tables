--------------------------------------------------------
--  DDL for Package HR_BATCH_MESSAGE_LINE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BATCH_MESSAGE_LINE_API" AUTHID CURRENT_USER as
/* $Header: hrabmapi.pkh 120.1 2005/10/02 01:58:41 aroussel $ */
/*#
 * This package contains APIs that will maintain line messages information for
 * a batch.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Batch Message Line
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_message_line >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a message line for a particular batch run.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The message line will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The message line will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_batch_run_number Identifies the batch run number for the message
 * line(s) to be created.
 * @param p_api_name Identifies the API for which the message is being created.
 * @param p_status Determines if the message is being created for a sucessful
 * or failure API. Value must be 'F' or 'S'.
 * @param p_error_number Identifies the Oracle error number (SQLCODE).
 * @param p_error_message Identifes the Oracle error message text (SQLERRM).
 * @param p_extended_error_message Identifes any further error text.
 * @param p_source_row_information Identifes the source row for which the
 * message was generated.
 * @param p_line_id If p_validate is false, this uniquely identifies the
 * message line created.
 * @rep:displayname Create Message Line
 * @rep:category BUSINESS_ENTITY HR_MESSAGE_LINE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_message_line
  (p_validate                      in     boolean  default false
  ,p_batch_run_number              in     number
  ,p_api_name                      in     varchar2
  ,p_status                        in     varchar2
  ,p_error_number                  in     number   default null
  ,p_error_message                 in     varchar2 default null
  ,p_extended_error_message        in     varchar2 default null
  ,p_source_row_information        in     varchar2 default null
  ,p_line_id                          out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_message_line >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a message line for a particular batch run.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The message line will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete any message line and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_line_id Identifies the batch line to delete.
 * @rep:displayname Delete Message Line
 * @rep:category BUSINESS_ENTITY HR_MESSAGE_LINE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_message_line
  (p_validate                      in     boolean  default false
  ,p_line_id                       in     number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_batch_lines >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes batch message line(s) for a particular batch run number.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The API batch message line(s) will be deleted for the specified batch run
 * number.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete any message line and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_batch_run_number Identifies the batch run number for the message
 * line(s) to be deleted.
 * @rep:displayname Delete Batch Lines
 * @rep:category BUSINESS_ENTITY HR_MESSAGE_LINE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_batch_lines
  (p_validate                      in     boolean  default false
  ,p_batch_run_number              in     number);
end hr_batch_message_line_api;

 

/
