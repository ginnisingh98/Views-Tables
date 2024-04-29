--------------------------------------------------------
--  DDL for Package FND_AOLJ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_AOLJ_UTIL" AUTHID CURRENT_USER as
/* $Header: AFAJUTLS.pls 120.5.12010000.2 2013/11/13 16:28:44 fskinner ship $ */
/*#
* This package is for internal use. It provides api's which are currently used
* by AOLJ group for fetching context values to minimize number of roundtrips.
* @rep:scope private
* @rep:product FND
* @rep:displayname Session Api's for AOLJ
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_APPS_CTX
*/

/*
** MULTI_PROFILE_VALUE_SPECIFIC - Get profile values for a specific user/resp/appl
**                        in group to minimize # of roundtips
**   Default user/resp/appl is current login.
*/
function MULTI_PROFILE_VALUE_SPECIFIC(
                    NUMOFNAMES        in number default 1,
                    NAMES             in varchar2,
                    USER_ID           in number default null,
                    RESPONSIBILITY_ID in number default null,
                    APPLICATION_ID    in number default null)
return varchar2;

/*
    -- SET_NLS_CONTEXT
    --
    -- Description:  Calls alter session to set the following values in DB.
    -- NLS_LANGUAGE, NLS_DATE_FORMAT,NLS_DATE_LANGUAGE, NLS_SORT
    -- NLS_TERRITORY,NLS_NUMERIC_CHARACTERS
*/


PROCEDURE set_nls_context( p_nls_language IN VARCHAR2 DEFAULT NULL,
                        p_nls_date_format IN VARCHAR2 DEFAULT NULL,
                        p_nls_date_language IN VARCHAR2 DEFAULT NULL,
                        p_nls_numeric_characters IN VARCHAR2 DEFAULT NULL,
                        p_nls_sort IN VARCHAR2 DEFAULT NULL,
                        p_nls_territory IN VARCHAR2 DEFAULT NULL,
                        p_db_nls_language OUT NOCOPY VARCHAR2,
                        p_db_nls_date_format OUT NOCOPY VARCHAR2,
                        p_db_nls_date_language OUT NOCOPY VARCHAR2,
                        p_db_nls_numeric_characters OUT NOCOPY VARCHAR2,
                        p_db_nls_sort OUT NOCOPY VARCHAR2,
                        p_db_nls_territory OUT NOCOPY VARCHAR2,
                        p_db_nls_charset OUT NOCOPY VARCHAR2
                        );


/* -- getClassVersionFromDB
   --
   -- Prints out version information for Java classes stored in the database
   --
   -- getClassVersionFromDB(p_classname VARCHAR2) -- Print out the version for a single class
   -- getClassVersionFromDB                       -- Print out version information for all Java classes
   --
   -- Calls a Java stored procedure which writes to System.out, so when used from SQL*Plus,
   -- SET SERVEROUTPUT ON needs to be used.
   --
   -- EX: To display the version of Log.java from SQL*Plus:
   --
   -- SQL> set serveroutput on
   -- SQL> execute fnd_aolj_util.getClassVersionFromDB('oracle.apps.fnd.common.Log');
   -- >>> Class: oracle.apps.fnd.common.Log
   -- ... : Log.java 115.8 2002/02/08 19:20:20 mskees ship $
   --
   -- PL/SQL procedure successfully completed.
*/
PROCEDURE getClassVersionFromDB;
PROCEDURE getClassVersionFromDB(p_classname VARCHAR2);

/* For AOL INTERNAL USE ONLY!!
*/
    /*#
     * Creates new icx session, validates it and returns session id.
     * @param p_user_id User Id
     * @param p_server_id Server Id
     * @param p_language_code Language Code. If passed in and is one of the
     * installed languages, the language code and nls language settings for the
     * session to be created will overwrite what's specified in the nls
     * profiles. The other nls settings will still get their values from the
     * profiles.
     * @param p_function_code Function Code
     * @param p_validate_only Y/N flag
     * @param p_commit TRUE/FALSE. If TRUE updates last_connect and counter in ICX_SESSIONS
     * @param p_update TRUE/FALSE. If TRUE updates last_connect and counter in ICX_SESSIONS
     * @param p_responsibility_id Responsibility Id
     * @param p_function_id Function Id
     * @param p_resp_appl_id Responsibility's Application Id
     * @param p_security_group_id Security Group Id
     * @param p_home_url Home URL
     * @param p_proxy_user User Id of the Proxy User. It's not null for the
     * proxy sessions and null for the normal sessions.
     * @param mode_code Mode of the session. Different values for mode are 115P for SSWA, 115J for SSWA with SSO, else 115X.
     * @param session_id Session Id
     * @param transaction_id Transaction Id
     * @param user_id Session's User Id
     * @param responsibility_id Session's Responsibility Id
     * @param resp_appl_id Session's Responsibility Application Id
     * @param security_group_id Session's Security Group Id
     * @param language_code Session's Language Code
     * @param nls_language Session's NLS Language
     * @param date_format_mask Session's Date Format Mask
     * @param nls_date_language Session's NLS Date Language
     * @param nls_numeric_characters Session's NLS Numeric Characters
     * @param nls_sort Session's NLS Sort
     * @param nls_territory Session's NLS Territory
     * @param login_id Session's Login Id
     * @param xsid Session's XSID
     * @return Y/N flag indicating whether session is created or not
     * @rep:lifecycle active
     * @rep:displayname Create new session
     * @rep:compatibility S
     */
function createSession(
            p_user_id              in number,
            p_server_id            in varchar2,
            p_language_code        in varchar2,
            p_function_code        in varchar2,
            p_validate_only        in varchar2,
            p_commit               in boolean,
            p_update               in boolean,
            p_responsibility_id    in number,
            p_function_id          in number,
            p_resp_appl_id         in number,
            p_security_group_id    in number,
            p_home_url             in varchar2,
            p_proxy_user           in number,
            mode_code              in out nocopy varchar2,
            session_id             out nocopy number,
            transaction_id         out nocopy number,
            user_id                out nocopy number,
            responsibility_id      out nocopy number,
            resp_appl_id           out nocopy number,
            security_group_id      out nocopy number,
            language_code          out nocopy varchar2,
            nls_language           out nocopy varchar2,
            date_format_mask       out nocopy varchar2,
            nls_date_language      out nocopy varchar2,
            nls_numeric_characters out nocopy varchar2,
            nls_sort               out nocopy varchar2,
            nls_territory          out nocopy varchar2,
            login_id               out nocopy number,
            xsid                   out nocopy varchar2
  ) return VARCHAR2;

/*  -- is_Valid_ICX() --  For AOL INTERNAL USE ONLY!!!!
    This function is a wrapper to ICX_SEC.validateSessionPrivate and is added for
    bug 2246010, to synchronise with ICX changes and to provide for a single call
    interface from all WebAppsContext.validateSession() methods via the method
    WebAppsContext.doValidateSession().
*/
function is_Valid_ICX(
            p_session_id           in varchar2,
            p_function_code        in varchar2,
            p_validate_only        in varchar2,
            p_commit               in boolean,
            p_update               in boolean,
            p_responsibility_id    in number,
            p_function_id          in number,
            p_resp_appl_id         in number,
            p_security_group_id    in number,
            p_validate_mode_on     in varchar2,
            p_transaction_id       in varchar2,
            session_id             out nocopy number,
            transaction_id         out nocopy number,
            user_id                out nocopy number,
            responsibility_id      out nocopy number,
            resp_appl_id           out nocopy number,
            security_group_id      out nocopy number,
            language_code          out nocopy varchar2,
            nls_language           out nocopy varchar2,
            date_format_mask       out nocopy varchar2,
            nls_date_language      out nocopy varchar2,
            nls_numeric_characters out nocopy varchar2,
            nls_sort               out nocopy varchar2,
            nls_territory          out nocopy varchar2,
            login_id               out nocopy number,
            p_isEncrypt         in boolean )
return varchar2;

/* for AOL internal use only */
function convertGuestSession(
            p_user_id              in number,
            p_server_id            in varchar2,
            p_session_id           in varchar2,
            p_language_code        in varchar2,
            p_function_code        in varchar2,
            p_validate_only        in varchar2,
            p_commit               in boolean,
            p_update               in boolean,
            p_responsibility_id    in number,
            p_function_id          in number,
            p_resp_appl_id         in number,
            p_security_group_id    in number,
            p_home_url             in varchar2,
            p_mode_code            in out nocopy varchar2,
            session_id             out nocopy number,
            transaction_id         out nocopy number,
            user_id                out nocopy number,
            responsibility_id      out nocopy number,
            resp_appl_id           out nocopy number,
            security_group_id      out nocopy number,
            language_code          out nocopy varchar2,
            nls_language           out nocopy varchar2,
            date_format_mask       out nocopy varchar2,
            nls_date_language      out nocopy varchar2,
            nls_numeric_characters out nocopy varchar2,
            nls_sort               out nocopy varchar2,
            nls_territory          out nocopy varchar2,
            login_id               out nocopy number
  ) return VARCHAR2;

PROCEDURE display_AOLJ_RUP;


end FND_AOLJ_UTIL;


/
