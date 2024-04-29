--------------------------------------------------------
--  DDL for Package FND_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FILE" AUTHID CURRENT_USER as
/* $Header: AFCPPIOS.pls 120.2.12010000.2 2011/08/01 19:44:50 ckclark ship $ */
/*#
 * This package contains the procedures to write text to log and output files. Supports a maximum buffer line size of 32k.
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname FND File
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST
 * @rep:lifecycle active
 * @rep:compatibility S
 */

LOG		constant number := 1;
OUTPUT		constant number := 2;

UTL_FILE_ERROR  exception;

PRAGMA exception_init(UTL_FILE_ERROR, -20100);

/*#
 * Writes text to a file, without appending any new line characters
 * @param WHICH Log file or Output file
 * @param BUFF Text to write
 * @rep:displayname Put
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
procedure PUT(WHICH in number, BUFF in varchar2);

/*#
 * Writes text to a file followed by a new line character
 * @param WHICH Log file or Output file
 * @param BUFF Text to write
 * @rep:displayname Put Line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
procedure PUT_LINE(WHICH in number, BUFF in varchar2);

/*#
 * Writes line terminators to a file (new line character)
 * @param WHICH Log file or Output file
 * @param LINES Number of lines to write
 * @rep:displayname Put Line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
procedure NEW_LINE(WHICH in number, LINES in natural := 1);

/*#
 * Sets the temporary log and out filenames and the temp directory to the user-specified values
 * @param P_LOG Temporary log filename
 * @param P_OUT Temporary output filename
 * @param P_DIR Temporary directory name
 * @rep:displayname Put Names
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
procedure PUT_NAMES(P_LOG in varchar2, P_OUT in varchar2, P_DIR in varchar2);

procedure RELEASE_NAMES(P_LOG in varchar2, P_OUT in varchar2);

procedure GET_NAMES(P_LOG in out nocopy varchar2, P_OUT in out nocopy varchar2);

/*#
 * Closes any open log/output files
 * @rep:displayname Close
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
procedure CLOSE;

/*#
 * Returns 1 if file is open, else 0
 * @rep:displayname Is_Open
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
function IS_OPEN (WHICH in varchar2) return number;

end FND_FILE;

/

  GRANT EXECUTE ON "APPS"."FND_FILE" TO "CS";
  GRANT EXECUTE ON "APPS"."FND_FILE" TO "EM_OAM_MONITOR_ROLE";
