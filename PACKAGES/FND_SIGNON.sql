--------------------------------------------------------
--  DDL for Package FND_SIGNON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SIGNON" AUTHID DEFINER as
/* $Header: AFSCSGNS.pls 120.4.12010000.6 2015/06/18 09:58:07 absandhw ship $ */
/*#
* This package provides api's to create a new session and update the auditing
* tables with the session information.
* @rep:scope public
* @rep:product FND
* @rep:displayname Audit Sign On
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_APPS_CTX
*/

--
-- AUDIT_FORM - Signon audit form begin | end
--
-- If END_FORM
--   Stamp end time on current form record.
-- If BEGIN_FORM
--   Insert new soa record for form level auditing.
--
procedure AUDIT_FORM(login_id in number,
                     login_resp_id in number,
                     form_application in varchar2,
                     form_name in varchar2,
                     audit_level in varchar2 DEFAULT 'D',
                     begin_flag in number DEFAULT 0);
--
-- AUDIT_RESPONSIBILITY - Signon audit responsibility
--
-- Insert new soa record for responsibility,
-- update pid in soa logins table.
--
procedure AUDIT_RESPONSIBILITY(audit_level	in varchar2,
                               login_id		in number,
                               login_resp_id	in out nocopy number,
                               resp_appl_id	in number,
                               resp_id			in number,
                               terminal_id	in varchar2,
                               spid				in varchar2);
--
-- AUDIT_USER - Begin user level signon auditing
--
-- Insert new soa record for login,
-- create new login_id for this signon.
--
procedure AUDIT_USER(login_id in out nocopy number,
                     audit_level in varchar2,
                     user_id in number,
                     terminal_id in varchar2,
                     login_name in varchar2,
                     spid in varchar2,
                     session_number in number,
		     p_loginfrom in varchar2 DEFAULT NULL);
--
-- AUDIT_END - End signon audit
--
-- End stamp last user and resp record when exiting.
--
procedure AUDIT_END(login_id in number);

--
-- NEW_SESSION - Misc signon things
--
-- Get new session number, check password expiration, etc
--
procedure NEW_SESSION(UID in  number,
                      SID out nocopy number,
                      EXPIRED out nocopy varchar2);

--
-- Bug 3375261. new_icx_session(user_id,login_id,expired)
-- is called by Java APIs
-- SessionManager.validateLogin and WebAppsContext.createSession,
-- this causes the functions in new_icx_session to be executed
-- twice in a local login flow. The fix is to split the functionality
-- of new_icx_session into two new APIs:
-- (1) is_pwd_expired: performs password expiration related operations,
--     to be used when authenticating a user/pwd pair
-- (2) new_icx_session(UID,l_login_id): performs auditing and
--     session number related operation, to be used when a session
--     is created.
--
-- is_pwd_expired - check password expiration and update password
--                  expiration information if password has not expired.
--                  this is an autonomous transaction.
--
--                  UID is user_id
--                  if successful, the EXPIRED out parameter is assigned
--                  'Y' if pwd has expired, or 'N' if pwd hasn't
--                  expired (or if uid doesn't exist in FND_USER).
--                  if an error occurs during processing,
--                  app_exception.application_exception is raised.
--
procedure is_pwd_expired(UID in  number,
                         EXPIRED out nocopy varchar2);
--
-- new_icx_session - generates a new session number and performs auditing
--                   related operations.
--
--                   UID is user_id, if user_id doesn't exist in
--                   FND_USER, exception is raised.
--                   if successful, the login_id out parameter holds
--                   the newly generated login_id
--                  if an error occurs during processing,
--                  app_exception.application_exception is raised.
--
    /*#
     * Generates a new session number and performs auditing related
     * operations.
     * @param uid User Id
     * @param login_id Login ID of audit record
     * @rep:lifecycle active
     * @rep:displayname Generate new session
     * @rep:compatibility S
     */
procedure new_icx_session(UID   IN NUMBER,
                          login_id  OUT nocopy NUMBER);

--
-- UPDATE_NAVIGATOR
--
-- Update navigator info for current user/resp.
--
procedure UPDATE_NAVIGATOR(
    USER_ID in number,
    RESP_ID in number,
    APPL_ID in number,
    LOGIN_ID in number,
    FUNCTION1 in varchar2,
    FUNCTION2 in varchar2,
    FUNCTION3 in varchar2,
    FUNCTION4 in varchar2,
    FUNCTION5 in varchar2,
    FUNCTION6 in varchar2,
    FUNCTION7 in varchar2,
    FUNCTION8 in varchar2,
    FUNCTION9 in varchar2,
    FUNCTION10 in varchar2,
    WINDOW_WIDTH in number,
    WINDOW_HEIGHT in number,
    WINDOW_XPOS in number,
    WINDOW_YPOS in number,
    NEW_WINDOW_FLAG in varchar2);

--
-- GET_NAVIGATOR_PREFERENCES
--   Get Navigator window sizing preferences.
--
procedure GET_NAVIGATOR_PREFERENCES(
    WINDOW_WIDTH out nocopy number,
    WINDOW_HEIGHT out nocopy number,
    WINDOW_XPOS out nocopy number,
    WINDOW_YPOS out nocopy number,
    NEW_WINDOW_FLAG out nocopy varchar2);

--
-- SET_SESSION
--   Store session date whenever new session is created.
-- To be called in pre-form of any form opened in a new session.
-- This is to maintain session dates for AOL forms running under
-- HR responsibilities.
--
procedure SET_SESSION(session_date in varchar2);

-- Misc signon things for an aol/j session.
-- For internal use only.

    /*#
     * Wrapper to new_icx_session(user_id, login_id, expired). This api is for
     * internal use and is called by java api's.
     * @param user_id User Id
     * @param login_id Login ID of audit record
     * @param expired Y/N flag indicating password expiry
     * @rep:lifecycle active
     * @rep:displayname Java wrapper api to generate new session and validate password expiry
     * @rep:compatibility S
     */
PROCEDURE new_aolj_session(user_id IN NUMBER,
			   login_id OUT nocopy NUMBER,
			   expired OUT nocopy VARCHAR2);



procedure AUDIT_WEB_RESPONSIBILITY(login_id in number,
                                   login_resp_id in number,
                                   resp_appl_id in number,
                                   resp_id in number);

    /*#
     * Generates a new session number, performs auditing related operations
     * and check password expiration.
     * @param user_id User Id
     * @param login_id Login ID of audit record
     * @param expired Y/N flag indicating password expiry
     * @rep:lifecycle active
     * @rep:displayname Generate new session and validate password expiry
     * @rep:compatibility S
     */
PROCEDURE new_icx_session(user_id IN NUMBER,
			   login_id OUT nocopy NUMBER,
			   expired OUT nocopy VARCHAR2,
			   p_loginfrom in varchar2 DEFAULT NULL);


--
-- new_proxy_icx_session - this is same as new_icx_session(UID, login_id) with
--                         a single change for handling SIGNONAUDIT:LEVEL
--                         differently for Proxy Sessions(Signon Audit is
--                         always enabled at FORM level for proxy sessions).
--                         We could have overloaded 'new_icx_session' but there
--                         already exists an overloaded version with 3 params.
--                         Hence we've chosen this new name for this api.
--                         This api is for internal use. This is called from
--                         new_icx_session(UID, login_id) and from
--                         FND_SESSION_MANAGEMENT.createSessionPrivate api.
--
    /*#
     * Generates a new session number, performs auditing related operations
     * and check password expiration. This is same as
     * new_icx_session(UID, login_id) with some extra processing for auditing
     * related operations for Proxy Sessions.
     * This api is for internal use. And it should be called only while
     * creating the proxy sessions.
     * @param uid User Id
     * @param proxy_user Proxy User Id
     * @param login_id Login ID of audit record
     * @rep:lifecycle active
     * @rep:displayname Generate new proxy session
     * @rep:compatibility S
     */
procedure new_proxy_icx_session(UID   IN NUMBER,
                          proxy_user IN NUMBER ,
                          login_id  OUT nocopy NUMBER);

/* BUG:5052314: API to retrieve number of unsuccessful logins */
/* previous to current login */
FUNCTION get_invalid_logins(p_userID number) return NUMBER;

/* BUG:6076369, modified signature and made it public to not break forms */
procedure AUDIT_USER_END(login_id in number, pend_time in date default SYSDATE);

end FND_SIGNON;

/
