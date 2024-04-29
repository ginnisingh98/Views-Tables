--------------------------------------------------------
--  DDL for Package WF_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_CORE" AUTHID CURRENT_USER as
/* $Header: wfcores.pls 120.10.12010000.3 2010/04/22 21:55:04 alsosa ship $ */
/*#
 * Provides APIs that can be called by an application
 * program or workflow function in the runtime phase
 * to handle error processing.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Core
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@wfcore See the related online help
 */

--
-- CONN_TAG_WF
--  This is the connection tag identificator for workflow module
-- CONN_TAG_BES
--  This is the connection tag identificator for business events
CONN_TAG_WF varchar2(2):='wf';
CONN_TAG_BES varchar2(3):='bes';

--
-- SESSION_LEVEL
--   The protection level at which this session is operating
--
session_level   NUMBER := 10;

--
-- UPLOAD_MODE
--   Mode to upload data
-- Valid values are:
--   UPGRADE - honor both protection and customization levels of data
--   UPLOAD - honor only protection level of data
--   FORCE - force upload regardless of protection or customization level
--
upload_mode VARCHAR2(8) := 'UPGRADE';

--
-- ERROR_XXX - error message variables
--   When a workflow error occurs, these variables will be populated
--   with all available information about the problem
--
error_name      VARCHAR2(30);
error_number    NUMBER;
error_message   VARCHAR2(2000);
error_stack     VARCHAR2(32000);



/*
** Create a global plsql variable that stores the current item
** type when uploading an item.  This is used by the generic
** loader overlay because the primary key of the wf_item_types
** table is :NAME and the primary key for the wf_item_attributes
** table is :NAME and item_type but the item_type comes from th
** :NAME value in the loader definition
*/
upload_placeholder    VARCHAR2(30) := NULL;

-- Local_CS
--
-- Local CharacterSet
LOCAL_CS        VARCHAR2(30) := NULL;

-- Newline in local CharacterSet
LOCAL_CS_NL     VARCHAR2(30) := NULL;

-- Tab in local CharacterSet
LOCAL_CS_TB     VARCHAR2(30) := NULL;

-- Carriage Return in local CharacterSet
LOCAL_CS_CR     VARCHAR2(30) := NULL;

-- Bug 3945469
-- Create two global plsql variables to store the database major version
--   and the value of aq_tm_processes
G_ORACLE_MAJOR_VERSION	NUMBER;
G_AQ_TM_PROCESSES	VARCHAR2(512) ;

--
-- Canonical Format Masks
--
-- Copied from FND_NUMBER and FND_DATE packages.
--
canonical_date_mask VARCHAR2(26) := 'YYYY/MM/DD HH24:MI:SS';
canonical_number_mask VARCHAR2(100) := 'FM999999999999999999999.99999999999999999999';

/*
** Implements the Hash Key Method
*/
HashBase               NUMBER := 1;
HashSize               NUMBER := 16777216;  -- 2^24

-- HashKey
-- Generate the Hash Key for a string
FUNCTION HashKey (p_HashString in varchar2) return number;

--
-- Clear
--   Clear the error buffers.
-- EXCEPTIONS
--   none
--
/*#
 * Clears the error buffer.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Clear
 * @rep:ihelp FND/@wfcore#a_clear See the related online help
 */
procedure Clear;
pragma restrict_references(CLEAR, WNDS, RNDS, RNPS);

--
-- Get_Error
--   Return current error info and clear error stack.
--   Returns null if no current error.
--
-- IN
--   maxErrStackLength - Maximum length of error_stack to return - number
--
-- OUT
--   error_name - error name - varchar2(30)
--   error_message - substituted error message - varchar2(2000)
--   error_stack - error call stack, truncated if needed  - varchar2(2000)
-- EXCEPTIONS
--   none
--
/*#
 * Returns the internal name of the current error message
 * and the token substituted error message. The procedure
 * also clears the error stack. A null value is returned
 * if there is no current error.
 * @param err_name Error Name
 * @param err_message Error Message
 * @param err_stack Error Stack
 * @param maxErrStackLength Maximum length of error stack to return
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Error
 * @rep:ihelp FND/@wfcore#a_geterr See the related online help
 */
procedure Get_Error(err_name out nocopy varchar2,
                    err_message out nocopy varchar2,
                    err_stack out nocopy varchar2,
                    maxErrStackLength in number default 4000);
pragma restrict_references(GET_ERROR, WNDS, RNDS);

--
-- Token
--   define error token
-- IN
--   token_name  - name of token
--   token_value - token value
-- EXCEPTIONS
--   none
--
/*#
 * Defines an error token and substitutes it with a value
 * for use in a predefined workflow error message.
 * @param token_name Token  Name
 * @param token_value Token Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Token
 * @rep:ihelp FND/@wfcore#a_token See the related online help
 */
procedure Token(token_name  in varchar2,
                token_value in varchar2);
pragma restrict_references(TOKEN, WNDS, RNDS);

--
-- Substitute
--   Return substituted message string, with exception if not found
-- IN
--   mtype - message type (WFERR, WFTKN, etc)
--   mname - message internal name
-- EXCEPTIONS
--   Raises an exception if message is not found.
--
function Substitute(mtype in varchar2, mname in varchar2)
return varchar2;

--
-- Translate
--   Get substituted message string
-- IN
--   tkn_name - Message name (must be WFTKN)
-- RETURNS
--   Translated value of string token
--
/*#
 * Translates the string value of an error token
 * by returning the language-specific value for
 * the token defined in the WF_RESOURCES table for
 * the current language setting.
 * @param tkn_name Token Name
 * @return Translated token value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Translate
 * @rep:ihelp FND/@wfcore#a_transl See the related online help
 */
function Translate (tkn_name in varchar2)
return varchar2;
pragma restrict_references(TRANSLATE, WNDS);

--
-- Raise
--   Raise an exception to the caller
-- IN
--   error_name - error name (must be WFERR)
-- EXCEPTIONS
--   Raises an a user-defined (20002) exception with the error message.
--
/*#
 * Raises a predefined workflow exception to the calling
 * application by supplying a correct error number and
 * token substituted message for the specified internal
 * error message name.
 * @param name  Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Raise
 * @rep:ihelp FND/@wfcore#a_raise See the related online help
 */
procedure Raise(name in varchar2);

--
-- Context
--   set procedure context (for stack trace)
-- IN
--   pkg_name   - package name
--   proc_name  - procedure/function name
--   arg1       - first IN argument
--   argn       - n'th IN argument
-- EXCEPTIONS
--   none
--
/*#
 * Adds an entry to the error stack to provide context
 * information that helps locate the source of an error.
 * Use this procedure with predefined errors raised by
 * calls to TOKEN( ) and RAISE( ), with custom-defined
 * exceptions, or even without exceptions whenever an error
 * condition is detected.
 * @param pkg_name Package  Name
 * @param proc_name Procedure Name
 * @param arg1  Argument 1
 * @param arg2  Argument 2
 * @param arg3  Argument 3
 * @param arg4  Argument 4
 * @param arg5  Argument 5
 * @param arg6  Argument 6
 * @param arg7  Argument 7
 * @param arg8  Argument 8
 * @param arg9  Argument 9
 * @param arg10 Argument 10
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Context
 * @rep:ihelp FND/@wfcore#a_context See the related online help
 */
procedure Context(pkg_name  in varchar2,
                  proc_name in varchar2,
                  arg1      in varchar2 default '*none*',
                  arg2      in varchar2 default '*none*',
                  arg3      in varchar2 default '*none*',
                  arg4      in varchar2 default '*none*',
                  arg5      in varchar2 default '*none*',
                  arg6      in varchar2 default '*none*',
                  arg7      in varchar2 default '*none*',
                  arg8      in varchar2 default '*none*',
                  arg9      in varchar2 default '*none*',
                  arg10      in varchar2 default '*none*');
pragma restrict_references(CONTEXT, WNDS);

--
-- RANDOM
--   Return a random string
-- RETURNS
--   A random string, max 80 characters
--
function RANDOM
return varchar2;
-- pragma restrict_references(RANDOM, WNDS);

--
-- ACTIVITY_RESULT
--	Return the meaning of an activities result_type
--	Including standard engine codes
-- IN
--   LOOKUP_TYPE
--   LOOKUP_CODE
--
-- RETURNS
--   MEANING
--
function activity_result( result_type in varchar2, result_code in varchar2) return varchar2;
pragma restrict_references(ACTIVITY_RESULT, WNDS, WNPS, RNPS);
--
--
--
-- GetResource
--   Called by WFResourceManager.class. Used by the Monitor and Lov Applet.
--   fetch A resource from wf_resource table.
-- IN
-- x_restype
-- x_resname

procedure GetResource(x_restype varchar2,
                      x_resname varchar2);
--
-- GetResources
--   Called by WFResourceManager.class. Used by the Monitor and Lov Applet.
--   fetch some resources from wf_resource table that match the respattern.
-- IN
-- x_restype
-- x_respattern
procedure GetResources(x_restype varchar2,
                       x_respattern varchar2);

-- *** Substitue HTML Characters ****
--function SubstituteSpecialChars

/*#
 * Substitutes HTML character entity references for special characters in
 * a text string and returns the modified text including the substitutions.
 * You can use this function as a security precaution when creating a PL/SQL
 * document or a PL/SQL CLOB document that contains HTML, to ensure that only
 * the HTML code you intend to include is executed.
 * @param some_text Text string with HTML characters
 * @return String with HTML characters substituted with HTML codes
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Substitute HTML Special Characters
 * @rep:compatibility S
 * @rep:ihelp FND/@a_subsc See the related online help
 */
function SubstituteSpecialChars(some_text in varchar2)
return varchar2;
pragma restrict_references(SubstituteSpecialChars,WNDS);

-- *** Special Char functions ***

-- Local_Chr
--   Return specified character in current codeset
-- IN
--   ascii_chr - chr number in US7ASCII
function Local_Chr(
  ascii_chr in number)
return varchar2;
pragma restrict_references (LOCAL_CHR, WNDS);

-- Newline
--   Return newline character in current codeset
function Newline
return varchar2;
pragma restrict_references (NEWLINE, WNDS);

-- Tab
--   Return tab character in current codeset
function Tab
return varchar2;
pragma restrict_references (TAB, WNDS);

-- CR - CarriageReturn
--   Return CR character in current codeset.
function CR
return varchar2;

--
-- CheckIllegalChars (PRIVATE)
-- IN
--   p_text - text to be checked
--   p_raise_exception - raise exception if true
-- RET
--   Return true if illegal character exists
function CheckIllegalChars(p_text varchar2, p_raise_exception boolean, p_illegal_charset varchar2 default null)
return boolean;

procedure InitCache;

  -- Bug 7578908. Phase 1 default values for NLS parameters
  -- Strictly to be used by WF only.
  FUNCTION nls_date_format   RETURN varchar2;
  FUNCTION nls_date_language RETURN varchar2;
  FUNCTION nls_calendar      RETURN varchar2;
  FUNCTION nls_sort         RETURN varchar2;
  FUNCTION nls_currency      RETURN varchar2;
  FUNCTION nls_numeric_characters RETURN varchar2;
  FUNCTION nls_language RETURN varchar2;
  FUNCTION nls_territory RETURN varchar2;
  procedure initializeNLSDefaults;

  --
  -- Tag_DB_Session (PRIVATE)
  -- Used by the different WF Engine entry points to tag the current session
  -- as per the Connection tag initiative described in bug 9370420
  -- This procedure checks for the user and application id. If they are not
  -- set then it means the context is not set.
  --
  procedure TAG_DB_SESSION(p_module_type varchar, p_action varchar2);

end WF_CORE;

/

  GRANT EXECUTE ON "APPS"."WF_CORE" TO "EM_OAM_MONITOR_ROLE";
