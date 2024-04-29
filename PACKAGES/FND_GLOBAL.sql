--------------------------------------------------------
--  DDL for Package FND_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_GLOBAL" AUTHID CURRENT_USER as
/* $Header: AFSCGBLS.pls 120.6.12010000.5 2010/03/21 09:08:42 absandhw ship $ */
/*#
 * Application context related APIs.
 * The server-side package FND_GLOBAL returns the values of system
 * globals, such as the login/signon or "session" type of values.
 * You should not use FND_GLOBAL routines in your forms (that is on
 * the client side). On the client side, most of the procedures in the
 * FND_GLOBAL package are replaced by a user profile option with the
 * same (or a similar) name. You should use FND_PROFILE routines in
 * your forms instead.
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Application Context APIs
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:ihelp FND/@e_global#e_global See related online help
 */

--
-- *** Special Char functions ***
--

--
-- Local_Chr
--   Return specified character in current codeset
-- IN
--   ascii_chr - chr number in US7ASCII
--
function Local_Chr(
  ascii_chr in number)
return varchar2;
pragma
restrict_references
(LOCAL_CHR, WNDS, WNPS, RNPS);


--
-- Newline
--   Return newline character in current codeset
--
function Newline
return varchar2;
pragma restrict_references (NEWLINE, WNDS, WNPS, RNPS);

--
-- Tab
--   Return tab character in current codeset
--
function Tab
return varchar2;
pragma restrict_references (TAB, WNDS, WNPS, RNPS);

--
-- *** Session Globals ***
--

--
-- USER_ID - Return user id
--

/*#
 * Returns user id.
 * @return user ID
 * @rep:scope public
 * @rep:displayname Get User_ID
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:lifecycle active
 * @rep:ihelp FND/@e_global See related online help.
 */
function USER_ID return number;
pragma restrict_references (USER_ID, WNDS, WNPS, RNDS);

--
-- RESP_ID - Return responsibility id
--
function RESP_ID return number;
pragma restrict_references (RESP_ID, WNDS, WNPS, RNDS);

--
-- RESP_APPL_ID - Return responsibility application id
--
function RESP_APPL_ID return number;
pragma restrict_references (RESP_APPL_ID, WNDS, WNPS, RNDS);

--
-- SECURITY_GROUP_ID - Return security group id
--
function SECURITY_GROUP_ID return number;
pragma restrict_references (SECURITY_GROUP_ID, WNDS, WNPS, RNDS);

--
-- USER_NAME - Return user name
--
function USER_NAME return varchar2;
pragma restrict_references (USER_NAME, WNDS, WNPS, RNDS);

--
-- RESP_NAME - Return responsibility name
--
function RESP_NAME return varchar2;
pragma restrict_references (RESP_NAME, WNDS, WNPS);

--
-- APPLICATION_NAME - Return responsibility application name
--
function APPLICATION_NAME return varchar2;
pragma restrict_references (APPLICATION_NAME, WNDS, WNPS);

--
-- APPLICATION_SHORT_NAME - Return responsibility application short name
--
function APPLICATION_SHORT_NAME return varchar2;
pragma restrict_references (APPLICATION_SHORT_NAME, WNDS, WNPS, RNDS);

--
-- LOGIN_ID - Return login id (unique per signon)
--



/*#
 * Returns login ID(unique per signon).
 * @return login ID
 * @rep:scope public
 * @rep:displayname Get Login ID
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:lifecycle active
 * @rep:ihelp FND/@e_global See related online help.
 */
function LOGIN_ID return number;
pragma restrict_references (LOGIN_ID, WNDS, WNPS, RNDS);

--
-- CONC_LOGIN_ID - Return conc. program login id
--


/*#
 * Returns concurrent program login ID.
 * @return concurrent program login ID
 * @rep:scope public
 * @rep:displayname Get Conc_Login ID
 * @rep:category BUSINESS_ENTITY FND_APPS_CTX
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:ihelp FND/@e_global See related online help.
 */

function CONC_LOGIN_ID return number;
pragma restrict_references (CONC_LOGIN_ID, WNDS, WNPS, RNDS);

--
-- PROG_APPL_ID - Return conc. program application id
--


/*#
 * Returns concurrent program Application ID.
 * @return concurrent program Aplication ID
 * @rep:scope public
 * @rep:displayname Get Conc_Appl_ID
 * @rep:category BUSINESS_ENTITY FND_APPS_CTX
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:ihelp FND/@e_global See related online help.
 */
function PROG_APPL_ID return number;
pragma restrict_references (PROG_APPL_ID, WNDS, WNPS, RNDS);

--
-- CONC_PROGRAM_ID - Return conc. program id
--
/*#
 * Returns concurrent program ID.
 * @return concurrent Program ID
 * @rep:scope public
 * @rep:displayname Get Conc_Program_ID
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FND_APPS_CTX
 * @rep:lifecycle active
 * @rep:ihelp FND/@e_global See related online help.
 */
function CONC_PROGRAM_ID return number;
pragma restrict_references (CONC_PROGRAM_ID, WNDS, WNPS, RNDS);

--
-- CONC_REQUEST_ID - Return conc. request id
--
/*#
 * Returns concurrent Request ID.
 * @return concurrent request ID
 * @rep:scope public
 * @rep:displayname Get Conc_Request_ID
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FND_APPS_CTX
 * @rep:lifecycle active
 * @rep:ihelp FND/@e_global See related online help.
 */
function CONC_REQUEST_ID return number;
pragma restrict_references (CONC_REQUEST_ID, WNDS, WNPS, RNDS);

--
-- CONC_PRIORITY_REQUEST - Return conc. priority request id
--
function CONC_PRIORITY_REQUEST return number;
pragma restrict_references (CONC_PRIORITY_REQUEST, WNDS, WNPS, RNDS);

--
-- PER_BUSINESS_GROUP_ID - Return HR business group id
--
function PER_BUSINESS_GROUP_ID return number;
pragma restrict_references (PER_BUSINESS_GROUP_ID, WNDS, WNPS, RNDS);

--
-- PER_SECURITY_PROFILE_ID - Return HR security profile id
--
function PER_SECURITY_PROFILE_ID return number;
pragma restrict_references (PER_SECURITY_PROFILE_ID, WNDS, WNPS, RNDS);

--
-- LANGUAGE_COUNT - Return number of installed languages
--
function LANGUAGE_COUNT return number;
pragma restrict_references (LANGUAGE_COUNT, WNDS);

--
-- CURRENT_LANGUAGE - Return current language (language code)
--
function CURRENT_LANGUAGE return varchar2;
pragma restrict_references (CURRENT_LANGUAGE, WNDS, WNPS, RNPS);

--
-- BASE_LANGUAGE - Return base language (language code)
--
function BASE_LANGUAGE return varchar2;
pragma restrict_references (BASE_LANGUAGE, WNDS);

--
-- RT_TEST_ID - Return rt test id
--
function RT_TEST_ID return number;
pragma restrict_references (RT_TEST_ID, WNDS, WNPS, RNDS);


--
-- RT INITIALIZE
-- Set RT test id
-- INTERNAL AOL USE ONLY
--
procedure RT_INITIALIZE(rt_test_id in number);

--
-- SET_SECURITY_GROUP_ID_CONTEXT
-- Set the FND.SECURITY_GROUP_ID for SYS_CONTEXT as used by SECURITY_GROUP_ID_POLICY
-- INTERNAL AOL USE ONLY
--
procedure SET_SECURITY_GROUP_ID_CONTEXT(security_group_id in number);

--
-- SECURITY_GROUP_ID_POLICY
-- Return the security_group_id where clause for the SECURITY_GROUP_ID policy
-- INTERNAL AOL USE ONLY
--
function SECURITY_GROUP_ID_POLICY(d1 varchar2, d2 varchar2) return varchar2;
pragma restrict_references (SECURITY_GROUP_ID_POLICY, WNDS);

--
-- APPS_INITIALIZE - Setup PL/SQL security context
--
-- This procedure may be called to initialize the global security
-- context for a database session.  This should only be done when
-- the session is established outside of a normal forms or
-- concurrent program connection.
--
-- IN
--   FND User ID
--   FND Responsibility ID (two part key, resp_id / resp_appl_id)
--   FND Security Group ID
--


/*#
 * Sets up global variables and profile values in a database
 * session. Call this procedure to initialize the global security context
 * for a database session.This routine should only be used when a
 * session must be established outside of a normal form or concurrent
 * program connection.
 * @param user_id User ID
 * @param resp_id Responsibility ID
 * @param resp_appl_id Application ID to which responsibility belongs
 * @param security_group_id Security group ID
 * @param server_id Server ID
 * @rep:scope public
 * @rep:displayname Initialize Globals
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FND_APPS_CTX
 * @rep:lifecycle active
 * @rep:ihelp FND/@e_global See related online help.
 */



procedure APPS_INITIALIZE(
    user_id in number,
    resp_id in number,
    resp_appl_id in number,
    security_group_id in number default 0,
    server_id in number default -1);

--
-- INITIALIZE
-- Set new values for security globals when new login or responsibility
-- INTERNAL AOL USE ONLY
--
procedure INITIALIZE(session_id in out nocopy number,
                     user_id               in number,
                     resp_id               in number,
                     resp_appl_id          in number,
                     security_group_id     in number,
                     site_id               in number,
                     login_id              in number,
                     conc_login_id         in number,
                     prog_appl_id          in number,
                     conc_program_id       in number,
                     conc_request_id       in number,
                     conc_priority_request in number,
                     form_id               in number default null,
                     form_appl_id          in number default null,
                     conc_process_id       in number default null,
                     conc_queue_id         in number default null,
                     queue_appl_id         in number default null,
                     server_id in number default -1);


--
-- AUDIT_ACTIVE
--
-- Description:  Returns TRUE if the audittrail profile option is on,
--               or FALSE otherwise.  When this function is invoked for
--               the first time, the profile value will be cached in a
--               global variable to avoid the performande hit of having
--               to fetch it each time.
-- Added by Jan Smith.  June, 1999 bug number 879630.
function AUDIT_ACTIVE return BOOLEAN;
pragma restrict_references (AUDIT_ACTIVE, WNDS);

-- SET_NLS_CONTEXT
--
-- Description:  Calls alter session to set the following values in DB.
--               NLS_LANGUAGE, NLS_DATE_FORMAT,NLS_DATE_LANGUAGE,
--               NLS_NUMERIC_CHARACTERS.

procedure set_nls_context(
         p_nls_language in varchar2 default null,
         p_nls_date_format in varchar2 default null,
         p_nls_date_language in varchar2 default null,
         p_nls_numeric_characters in varchar2 default null,
         p_nls_sort in varchar2 default null,
         p_nls_territory in varchar2 default null
);

procedure set_nls(
             p_nls_language in varchar2 default null,
             p_nls_date_format in varchar2 default null,
             p_nls_date_language in varchar2 default null,
             p_nls_numeric_characters in varchar2 default null,
             p_nls_sort in varchar2 default null,
             p_nls_territory in varchar2 default null,
             p_db_nls_language out nocopy varchar2,
             p_db_nls_date_format out nocopy varchar2,
             p_db_nls_date_language out nocopy varchar2,
             p_db_nls_numeric_characters out nocopy varchar2,
             p_db_nls_sort out nocopy varchar2,
             p_db_nls_territory out nocopy varchar2,
             p_db_nls_charset out nocopy varchar2
         );

--
-- Lookup_Security_Group
--   Get Security Group Id from which to retrieve lookup type.
--   This will either be the current security group, or default to the
--   STANDARD security group (id=0) if lookup type not defined
--   in current security group.
-- IN
--   lookup_type
--   view_application_id
-- RETURNS
--   Security_group_id of lookup type to use (current or STANDARD).
-- NOTE
--   This function is used by FND_LOOKUPS and related views to
--   improve performance.
--
function Lookup_Security_Group(
  lookup_type in varchar2,
  view_application_id in number)
return number;
pragma restrict_references(Lookup_Security_Group, WNDS, WNPS);

function Get_Session_Context
return number;
pragma restrict_references(Get_Session_Context, WNDS, WNPS, RNDS);

function Compare_Session_Context(context_id in number)
return boolean;
pragma restrict_references(Compare_Session_Context, WNDS, WNPS, RNDS);

function Assert_No_Pool return boolean;


appl_context_change boolean := FALSE;
resp_context_change boolean := FALSE;
user_context_change boolean := FALSE;
nls_context_change boolean := FALSE;
sec_context_change boolean := FALSE;
session_context number := 0;
no_pool number := null;

--
-- EMPLOYEE_ID - Return employee id of current user
-- * NOTE: Employee_id is a foreign key to PER_PEOPLE_F.PERSON_ID
--
function EMPLOYEE_ID return number;
pragma restrict_references (EMPLOYEE_ID, WNDS, WNPS, RNDS);

--
-- CUSTOMER_ID - Return customer id of current user
-- * NOTE: Customer_id is a foreign key to HZ_PARTIES.PARTY_ID.
--
function CUSTOMER_ID return number;

--
-- SUPPLIER_ID - Return supplier id of current user
-- * NOTE: Supplier_id is a foreign key to
-- PO_VENDOR_CONTACTS.VENDOR_CONTACT_ID
--
function SUPPLIER_ID return number;


--
-- FORM_ID - Return form id
--
function FORM_ID return number;
pragma restrict_references (FORM_ID, WNDS, WNPS, RNDS);

--
-- FORM_APPL_ID - Return form application id
--
function FORM_APPL_ID return number;
pragma restrict_references (FORM_APPL_ID, WNDS, WNPS, RNDS);

--
-- CONC_PROCESS_ID - Return conc process id
--
function CONC_PROCESS_ID return number;
pragma restrict_references (CONC_PROCESS_ID, WNDS, WNPS, RNDS);

--
-- CONC_QUEUE_ID - Return conc queue id
--
function CONC_QUEUE_ID return number;
pragma restrict_references (CONC_QUEUE_ID, WNDS, WNPS, RNDS);

--
-- QUEUE_APPL_ID - Return conc queue appl id
--
function QUEUE_APPL_ID return number;
pragma restrict_references (QUEUE_APPL_ID, WNDS, WNPS, RNDS);

--
-- SESSION_ID - Return session id
--
function SESSION_ID return number;
pragma restrict_references (SESSION_ID, WNDS, WNPS, RNDS);

server_context_change boolean := FALSE;
org_context_change boolean := FALSE;

--
--SERVER_ID - Return user id
--
function SERVER_ID return number;

--
--ORG_ID - Return user id
--
function ORG_ID return number;

--
-- ORG_NAME - Return organization name
--
function ORG_NAME return varchar2;

--
-- PARTY_ID - Return person_party_id of current user
-- * NOTE: person_party_id is a foreign key to
-- HZ_PARTIES.PARTY_ID
--
function PARTY_ID return number;

--
-- Function that are getter methods for NLS settings in DB
--
function NLS_LANGUAGE return varchar2;

function NLS_NUMERIC_CHARACTERS return varchar2;

function NLS_DATE_FORMAT return varchar2;

function NLS_DATE_LANGUAGE return varchar2;

function NLS_TERRITORY return varchar2;

function NLS_SORT return varchar2;

--
-- bless_next_init-
--
--   Only a few Oracle FND developers will ever call this routine.
--   Because it is so rare that anyone would ever call this
--   routine, we aren't going to document it so as not to
--   confuse people.  All you need to know is that calling this
--   routine incorrectly can easily cause showstopper problems
--   even for code outside your product.  So just don't call it
--   unless you have been told to do so by an Oracle FND
--   development manager.
--
--   in argument:
--      permission_code- if you have permission to call this
--                       you will have been given a unique code
--                       that only you are allowed to pass to
--                       confirm that your call is permitted.
--
--   see the internal oracle document for more details:
--   http://www-apps.us.oracle.com/atg/plans/r115x/contextintegrity.txt
--
procedure bless_next_init(permission_code in varchar2);

--
-- Restores the context to the last "approved" value saved away.
--
procedure restore;

--
-- INITIALIZE
-- Set an "array" of security globals,
-- optionally returning all the values initialized this call.
--
procedure initialize(p_mode in varchar2,
                     p_nv in out nocopy fnd_const.t_hashtable);

--
-- INITIALIZE
-- Set an "array" of security globals
-- returning all the values initialized this call.
--
procedure initialize(p_nv in out nocopy fnd_const.t_hashtable);

--
-- INITIALIZE
-- Set a single security global
-- For example, ORG_ID
--

procedure INITIALIZE(name varchar2, value varchar2);

/*   Sets the module and action field of v$session
 *   module_type : type of program/function/action being called (always in lowercase)
 *   module_name : The module or code class name that performs the action.
 */
procedure tag_db_session(module_type varchar2, module_name in varchar2);

/*   Overloaded function for tag_db_session.
 *   This api sets client_identifier and action to SYSADMIN.
 *   module_type : type of program/function/action being called (always in lowercase)
 *   module_name : The module or code class name that performs the action.
 *   application_name : application short name to which the program_name belongs to.
 */

procedure tag_db_session(module_type in varchar2,module_name in varchar2,application_name in varchar2);


end FND_GLOBAL;

/

  GRANT EXECUTE ON "APPS"."FND_GLOBAL" TO "EM_OAM_MONITOR_ROLE";
