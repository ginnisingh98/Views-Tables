--------------------------------------------------------
--  DDL for Package WF_MAIL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_MAIL_UTIL" AUTHID CURRENT_USER as
/* $Header: wfmluts.pls 120.3 2006/01/25 15:32:13 smayze ship $ */
/*#
 * Provides notification mailer utility APIs to perform conversions of
 * notification data.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Notification Mailer Utility
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_NOTIFICATION
 * @rep:ihelp FND/@mlrutilapi See the related online help
 */

-- GLOBAL Package level variables that contain static data.
g_timezoneName varchar2(80);
g_gmt_offset varchar2(240);
g_install varchar2(60);
g_ntfDocText varchar2(30);

TYPE parserStack_t IS TABLE OF varchar2(2000) INDEX BY BINARY_INTEGER;

-- EncodeBLOB
--   Receives a BLOB input and encodes it to Base64 CLOB
-- IN
--   BLOB data
-- OUT
--   CLOB data
/*#
 * Encodes the specified BLOB to base64 and returns the encoded data as
 * a character large object (CLOB). You can use this procedure to store a
 * BLOB in a PL/SQL CLOB document to be included in a notification
 * message.
 * @param pIDoc Input BLOB Document
 * @param pODoc Output CLOB Document
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Encode BLOB Document to base64
 * @rep:compatibility S
 * @rep:ihelp FND/@mlrutilapi#a_encblob See the related online help
 */
procedure EncodeBLOB(pIDoc  in     blob,
                     pODoc  in out nocopy clob);

-- DecodeBLOB
--   Receives a CLOB input and decodes it from Base64 to BLOB
-- IN
--   CLOB data
-- OUT
--   BLOB data
procedure DecodeBLOB(pIDoc  in     clob,
                     pODoc  in out nocopy blob);
-- StrParser
--   Parse a string and seperate the elements into a memeory table based on the
--   content of the seperators.
-- IN
--    str - The Varchar2 that is to be parsed
--    sep - The list of SINGLE character seprators that will
--          segment the str.
-- RETURN
--    parserStack_t a memory table of Varchar2
--
function strParser(str in varchar2, sep in varchar2) return parserStack_t;

-- ParseContentType
--   Parses document type returned by the PLSQL/PLSQLCLOB/PLSQLBLOB document
--   APIs and returns the parameters
-- IN
--   pContentType - Document Type
-- OUT
--   pMimeType - Content Type of the document
--   pFileName - File Name
--   pExtn     - File Extension
--   pEncoding - Content Encoding

procedure parseContentType(pContentType in varchar2,
                           pMimeType out nocopy varchar2,
                           pFileName out nocopy varchar2,
                           pExtn out nocopy varchar2,
                           pEncoding out nocopy varchar2);

-- getTimezone (PRIVATE)
--   Gets the server timezone message
-- IN
--   contentType - Document Type in varchar2
-- RETURN
--   timezone - Formatted timezone message in varchar2

function getTimezone(contentType in varchar2) return varchar2;

-- getGMTDeviation (PRIVATE)
--    Function to get the gmtDeviation in String time format, for example,
--  Pacific Time with 8 GMT offset would be displayed as '(GMT -8:00/-7:00)
--  Pacific Time' or '(GMT -8:00) Pacific Time' depending on whether the
--  day light savings is enabled or not.
-- IN
--   pName - Timezone name
-- RETURN
--   l_GMT_deviation - GMT deviation in varchar2 format

function getGMTDeviation(pName in varchar2) return varchar2;

end WF_MAIL_UTIL;

 

/
