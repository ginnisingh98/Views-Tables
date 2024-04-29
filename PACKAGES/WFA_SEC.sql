--------------------------------------------------------
--  DDL for Package WFA_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WFA_SEC" AUTHID CURRENT_USER as
/* $Header: wfsecs.pls 120.3.12010000.3 2009/08/26 21:17:11 vshanmug ship $ */

-- Flag to tell get session to just do the validation or do the validation
-- and show the login dialog.  This is used by the monitor so it has a chance
-- to check the access key if the get session fails.
-- This is also used by detached notification viewing to see if a valid
-- session exists.
validate_only  BOOLEAN := FALSE;

--
-- CreateSession - create web session for the client
--   Creates a new web session for the supplied username and password.
--   Session information is typically stored on the web client as an
--   http cookie.
-- IN
--   c_user_name - user name
--   c_user_password - user password (plain text)
-- ERRORS
--   WFSEC_USER_PASSWORD - invalid user name or password
--   WFSEC_SESSION_CREATE - could not create a session
--
procedure CreateSession(
    c_user_name     in varchar2,
    c_user_password in varchar2);

--
-- PseudoSession - create ICX psuedo session for the client
--   Creates a temp ICX session for the current user coming into ICX
--   from an email notification with a link to the applications.
--   Session information is typically stored on the web client as an
--   http cookie.  This only applies to ICX so only wfsecicb will
--   have an actual implementation for this function.  The others
--   do nothing.
--
procedure PseudoSession(IncludeHeader in BOOLEAN default TRUE,
                        user_name     in varchar2 default null);

--
-- GetSession - Get web session information client
--   Gets the session information from the client (typically stored as
--   an http cookie).
-- OUT
--   user_name - user name
-- ERRORS
--   WFSEC_NO_SESSION - no valid session is in effect for the client
--   WFSEC_GET_SESSION - error gettiong session information
--
procedure GetSession(user_name out NOCOPY varchar2);

--
-- Header
--   Print an html page header
-- IN
--   background_onl  - Only set background with no other header
--   disp_find - When defined, Find button is displayed, and the value
--               is the URL the Find button is pointting to.
--
procedure Header(background_only in boolean default FALSE,
                 disp_find in varchar2 default NULL,
                 page_title in varchar2 default NULL,
                 inc_lov_applet  in boolean  default TRUE,
                 pseudo_login in boolean default FALSE);

--
-- Footer
--   Print an html page footer
--
procedure Footer;

--
-- DetailURL
--   Produce URL for notification detail and response page.
-- IN
--   nid - notification id
-- RETURNS
--   URL of detail and response page for notification.
--
function DetailURL(nid in number) return varchar2;


--
-- Create_Help_Syntax
--   Create the javascript necessary to launch the help function
--   Since this is only required for the apps install case
--   IN ( have covered this function with a wfa_sec function.
--   The other wfsec cases are just a stub.
-- IN
--   p_target - target in the help file that you wish to display
--   p_language_code - current user language
--
procedure Create_Help_Syntax (
p_target in varchar2 default null,
p_language_code in varchar2 default null);

--
-- get_role_info
--   Gets role info for the user sources that we know about rather
--   than using the ugly expensive wf_roles view
--
procedure get_role_info (
  role in varchar2,
  name out NOCOPY varchar2,
  display_name out NOCOPY varchar2,
  description out NOCOPY varchar2,
  email_address out NOCOPY varchar2,
  notification_preference out NOCOPY varchar2,
  language out NOCOPY varchar2,
  territory out NOCOPY varchar2,
  orig_system  out NOCOPY varchar2,
  orig_system_id out NOCOPY number
);

-- get_role_info2
--   Gets role info for the user sources that we know about rather
--   than using the ugly expensive wf_roles view
--
procedure get_role_info2(
  role in varchar2,
  name out NOCOPY varchar2,
  display_name out NOCOPY varchar2,
  description out NOCOPY varchar2,
  email_address out NOCOPY varchar2,
  notification_preference out NOCOPY varchar2,
  language out NOCOPY varchar2,
  territory out NOCOPY varchar2,
  orig_system  out NOCOPY varchar2,
  orig_system_id out NOCOPY number,
  FAX out NOCOPY VARCHAR2 ,
  STATUS out NOCOPY VARCHAR2 ,
  EXPIRATION_DATE out NOCOPY DATE,
  p_CompositeName in BOOLEAN default NULL
);

  /* get_role_info3
   *
   * Returns profile and pre-set values for the given role.
   * Added NLS parameter for phase 1 of full NLS support, bug 7578908
   */
  procedure get_role_info3(p_CompositeName in BOOLEAN,
                            p_role in varchar2,
                            p_name out NOCOPY varchar2,
                            p_display_name out NOCOPY varchar2,
                            p_description out NOCOPY varchar2,
                            p_email_address out NOCOPY varchar2,
                            p_notification_preference out NOCOPY varchar2,
                            p_orig_system  out NOCOPY varchar2,
                            p_orig_system_id out NOCOPY number,
                            p_FAX out NOCOPY VARCHAR2,
                            p_STATUS out NOCOPY VARCHAR2,
                            p_EXPIRATION_DATE out NOCOPY DATE  ,
                            p_nlsLanguage out NOCOPY varchar2,
                            p_nlsTerritory out NOCOPY varchar2
                          , p_nlsDateFormat out NOCOPY varchar2
                          , p_nlsDateLanguage out NOCOPY varchar2
                          , p_nlsCalendar out NOCOPY varchar2
                          , p_nlsNumericCharacters out NOCOPY varchar2
                          , p_nlsSort out NOCOPY varchar2
                          , p_nlsCurrency out NOCOPY varchar2
   );

--
-- ResetCookie
--  Resets cookie cookieName to -1.
--
procedure ResetCookie(cookieName in varchar2);

--
-- GET_PROFILE_VALUE (PRIVATE)
--
function Get_Profile_Value(name varchar2,
                           user_name varchar2)
return varchar2;

-- Local_Chr
--   Return specified character in current codeset
-- IN
--   ascii_chr - chr number in US7ASCII
function Local_Chr(
  ascii_chr in number)
return varchar2;
pragma restrict_references (LOCAL_CHR, WNDS);

--
-- DirectLogin - Return proper function name for DirectLogin  --Bug: 1566390
--
--
function DirectLogin(nid in number)
return varchar2;

--
-- GetFWKUserName
--   Return current Framework user name
--
function GetFWKUserName
return varchar2;

--
-- Logout
--  For Single sign-on logout only, other security packages
--  still uses WFA_HTML.Logout to logout
--
procedure Logout;

--
-- DS_Count_Local_Role (PRIVATE)
--   Returns count of a role in local directory service table
-- IN
--   role_name - role to be counted
-- RETURN
--   count of provided role in local directory service table
--
function DS_Count_Local_Role(role_name in varchar2)
return number;

--
-- DS_Update_Local_Role (PRIVATE)
--   Update old name user/role in local directory service tables with new name
-- IN
--   OldName - original name to be replaced
--   NewName - new name to replace
--
procedure DS_Update_Local_Role(
  OldName in varchar2,
  NewName in varchar2
);

--
-- GetUser
--   Return current user name
--   If apps get the FWKUser in standalone get session user.

function GetUser
return varchar2;

--
-- user_id
--   Return current user id, in apps, wrapper to  FND_GLOBAL.user_id
--   In standalone, returns -1.
function user_id return number;


--
-- login_id
--   Return current login id, in apps, wrapper to  FND_GLOBAL.login_id
--   In standalone, returns -1.
function login_id return number;

--
-- security_group_id
--   Return current security_group_id, in apps, wrapper to
--   FND_GLOBAL.security_group_id  In standalone, returns -1.
function security_group_id return number;

--
-- CheckSession
--   Check the cached ICX session id against the current session id to determine
--   if the session has been changed. This function caches the current session id
--   after the check.
-- RETURN
--   boolean - True if session matches, else false
function CheckSession return boolean;


--
-- Random
--   Return a random number in varchar2.  When an implementation is not
--   available, return null.
-- RETURN
--   Text of a random number
function Random return varchar2;

-- bug 7828862
-- Cache_Ctx
--   Caches current session context values such as user_id, resp_id,
--   resp_appl_id and so on from FND_GLOBAL package
--
procedure Cache_Ctx;

--
-- Restore_Ctx
--   Resets current context based on the cached values
--
procedure Restore_Ctx;

end WFA_SEC;

/
