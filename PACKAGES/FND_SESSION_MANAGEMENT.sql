--------------------------------------------------------
--  DDL for Package FND_SESSION_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SESSION_MANAGEMENT" AUTHID CURRENT_USER as
/* $Header: AFICXSMS.pls 120.6.12010000.6 2016/04/06 18:18:44 rsantis ship $ */
/*#
* This package provides api's to create/validate icx sessions and api's
* to store/retrieve session attribute values.
* @rep:scope public
* @rep:product FND
* @rep:displayname Single Signon Session Management
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_APPS_CTX
*/

	PV_WEB_USER_ID			CONSTANT NUMBER := 10;
	PV_USER_ID			CONSTANT NUMBER := 10;
	PV_LANGUAGE_CODE		CONSTANT NUMBER := 21;
	PV_DATE_FORMAT			CONSTANT NUMBER := 22;
	PV_SESSION_ID			CONSTANT NUMBER := 23;
	PV_RESPONSIBILITY_ID		CONSTANT NUMBER := 24;
	PV_ORG_ID			CONSTANT NUMBER := 29;
	PV_SESSION_MODE			CONSTANT NUMBER := 30;
        PV_FUNCTION_ID                  CONSTANT NUMBER := 31;
        PV_FUNCTION_TYPE                CONSTANT NUMBER := 32;
	PV_USERNAME			CONSTANT NUMBER := 99;
	PV_USER_NAME			CONSTANT NUMBER := 99;


-- For passing more meaningful error messages to JAVA

g_validation_error varchar2(240);

-- ICX_SESSIONS

g_session_id number := -1;
g_session_mode varchar2(30) := '115X';
g_transaction_id number := -1;
g_resp_appl_id number := -1;
g_responsibility_id number := -1;
g_security_group_id number := -1;
g_node_id number := -1;
g_org_id number := -1;
g_function_id number := -1;
g_function_type varchar2(30) := '';
g_menu_id number := -1;
g_page_id number := -1;

g_mac_key raw(20);
g_enc_key raw(32);

g_user_id number := -1;
g_proxy_user_id number := -1;
g_language varchar2(30) := 'AMERICAN';
g_language_code varchar2(30) := 'US';
g_date_format varchar2(80) := 'DD-MON-RRRR';
g_date_language varchar2(30) := 'AMERICAN';
g_numeric_characters varchar2(30) := '.,';
g_nls_sort varchar2(30) := 'BINARY';
g_nls_territory varchar2(30) := 'AMERICA';
g_login_id NUMBER := -1; -- mputman added 2020952
g_prog_appl_id number := -1;

/* 3152313
g_language_c varchar2(30) := null;
g_language_code_c varchar2(30) := null;
g_date_format_c varchar2(80) := null;
g_date_language_c varchar2(30) := null;
g_numeric_characters_c varchar2(30) := null;
g_nls_sort_c varchar2(30) := null;
g_nls_territory_c varchar2(30) := null;
*/

g_OA_HTML varchar2(30) := 'OA_HTML';
g_OA_MEDIA varchar2(30) := 'OA_MEDIA';
g_style_sheet varchar2(30) := 'oracle.css';

g_mode_code varchar2(30) := null;

-- ICX_PARAMETERS

g_home_url varchar2(240) := '';
g_webmaster_email varchar2(80) := '';
g_query_set number := -1;
g_max_rows number := -1;
g_session_cookie_name varchar2(81) := '';
g_session_cookie_domain varchar2(30) := '';

g_validateSession_flag boolean := true;

function NewSessionId return number;

function NewTransactionId return number;

function NewTransactionId(p_session_id in number) return number;

function NewXSID return varchar2;

procedure newSessionRaiseEvent(p_user_id     in varchar2 DEFAULT '-7777',
                               p_session_id  in varchar2 DEFAULT '-7777');


procedure validateSession_pragma(p_session_id in number);


function doNewSessionEvent(p_guid       in raw,
                           p_evtMsg     in out NOCOPY wf_event_t)
         return VARCHAR2;

    /*#
     * Creates new icx session and returns session id.
     * @param p_user_id User Id
     * @param c_mode_code Mode of the session. Different values for mode are 115P for SSWA, 115J for SSWA with SSO, else 115X.
     * @param c_sec_grp_id Security Group Id
     * @param p_server_id Server Id
     * @param p_home_url Home URL
     * @param p_language_code Language Code. If passed in and is one of the
     * installed languages, the language code and nls language settings for the
     * session to be created will overwrite what's specified in the nls
     * profiles. The other nls settings will still get their values from the
     * profiles.
     * @param p_proxy_user User Id of the Proxy User. It's not null for the
     * proxy sessions and null for the normal sessions.
     * @return Session Id
     * @rep:lifecycle active
     * @rep:displayname Create new session
     * @rep:compatibility S
     */
function createSession(p_user_id   in number,
                       c_mode_code in varchar2 default '115P',
                       c_sec_grp_id in NUMBER DEFAULT NULL,
                       p_server_id in varchar2 DEFAULT NULL,
                       p_home_url in varchar2 default null,
                       p_language_code in varchar2 default NULL,
                       p_proxy_user in number default null)
                        return number;

function convertGuestSession(p_user_id in number,
                             p_server_id in varchar2 DEFAULT NULL,
                             p_session_id in varchar2,
                             p_language_code in varchar2 default NULL,
                             c_sec_grp_id    in NUMBER DEFAULT NULL,
                             p_home_url in varchar2 default null,
                             p_mode_code in varchar2 default null)
        return varchar2;

function createTransaction(p_session_id in number,
                           p_resp_appl_id in number default null,
                           p_responsibility_id in number default null,
                           p_security_group_id in number default null,
                           p_menu_id in number default null,
                           p_function_id in number default null,
                           p_function_type in varchar2 default null,
                           p_page_id in number default null)
                           return number;

procedure removeTransaction(p_transaction_id in number);

procedure setSessionPrivate(p_user_id		 in number,
			    p_responsibility_id  in number,
			    p_resp_appl_id       in number,
			    p_security_group_id  in number,
			    p_date_format	 in varchar2,
			    p_language		 in varchar2,
			    p_date_language	 in varchar2,
			    p_numeric_characters in varchar2,
                            p_nls_sort           in varchar2,
                            p_nls_territory      in varchar2,
                            p_node_id            in number default null);

procedure initializeSSWAGlobals(p_session_id        in number,
                                p_transaction_id    in number default NULL,
                                p_resp_appl_id      in number default NULL,
                                p_responsibility_id in number default NULL,
                                p_security_group_id in number default NULL,
                                p_function_id       in number default NULL);

function validateSessionPrivate( c_XSID              in varchar2,
                                 c_function_code     in varchar2 default NULL,
                                 c_commit            in boolean default TRUE,
                                 c_update            in boolean default TRUE,
                                 c_responsibility_id in number default NULL,
                                 c_function_id       in number default NULL,
                                 c_resp_appl_id      in number default NULL,
                                 c_security_group_id in number default NULL,
                                 c_validate_mode_on  in varchar2 default 'Y',
                                 c_XTID              in varchar2 default NULL,
                                 session_id             out NOCOPY number,
                                 transaction_id         out NOCOPY number,
                                 user_id                out NOCOPY number,
                                 responsibility_id      out NOCOPY number,
                                 resp_appl_id           out NOCOPY number,
                                 security_group_id      out NOCOPY number,
                                 language_code          out NOCOPY varchar2,
                                 nls_language           out NOCOPY varchar2,
                                 date_format_mask       out NOCOPY varchar2,
                                 nls_date_language      out NOCOPY varchar2,
                                 nls_numeric_characters out NOCOPY varchar2,
                                 nls_sort               out NOCOPY varchar2,
                                 nls_territory          out NOCOPY varchar2)
                                return varchar2;

function getID(	n_param in number,
		p_session_id in number)
		return varchar2;

procedure putSessionAttributeValue(p_name in varchar2,
                                   p_value in varchar2,
                                   p_session_id in number);

function getSessionAttributeValue(p_name in varchar2,
                                  p_session_id in number)
                                  return varchar2;

procedure clearSessionAttributeValue(p_name in varchar2,
                                     p_session_id in number);

function getsessioncookiename return varchar2;

procedure updateSessionContext( p_function_name          varchar2 default null,
                                p_function_id            number   default null,
                                p_application_id         number,
                                p_responsibility_id      number,
                                p_security_group_id      number,
                                p_session_id             number,
                                p_transaction_id         number   default null);

function getNLS_PARAMETER(p_param in VARCHAR2)
		return varchar2; -- mputman added

PROCEDURE set_session_nls (p_session_id IN NUMBER,
                              p_language IN VARCHAR2,
                              p_date_format_mask IN VARCHAR2,
                              p_language_code IN VARCHAR2,
                              p_date_language IN VARCHAR2,
                              p_numeric_characters IN VARCHAR2,
                              p_sort IN VARCHAR2,
                              p_territory IN VARCHAR2); --mputman added for AOLJ/CRM

FUNCTION check_session(p_session_id IN NUMBER,
                       p_resp_id IN NUMBER DEFAULT NULL,
                       p_app_resp_id IN NUMBER DEFAULT NULL,
                       p_tickle IN VARCHAR2 DEFAULT 'Y')
                RETURN VARCHAR2;

procedure reset_session(p_session_id in number);

/*
function newLoginId
   return number;
*/

PROCEDURE disableSessions (threshold IN NUMBER);

function disableUserSession(c_session_id in number,
                            c_user_id in number default null) return BOOLEAN;

PROCEDURE setUserNLS  (p_user_id             IN NUMBER,
                       p_language_code       IN varchar2 default null,
                       l_language	         OUT NOCOPY varchar2,
                       l_language_code	      OUT NOCOPY varchar2,
                       l_date_format	      OUT NOCOPY varchar2,
                       l_date_language	      OUT NOCOPY varchar2,
                       l_numeric_characters	OUT NOCOPY varchar2,
                       l_nls_sort      	   OUT NOCOPY varchar2,
                       l_nls_territory      	OUT NOCOPY varchar2,
                       l_limit_time		      OUT NOCOPY NUMBER,
                       l_limit_connects	   OUT NOCOPY NUMBER,
                       l_org_id              OUT NOCOPY varchar2,
                       l_timeout              OUT NOCOPY NUMBER);

function GET_CACHING_KEY(p_reference_path VARCHAR2) return VARCHAR2;

-- returns the proxy user id if the session is a proxy session
-- returns NULL otherwise
-- if p_session_id is null, return the information for the current session
    /*#
     * Checks if a given session is proxy session or normal session. Returns
     * proxy user id if it's a proxy session otherwise retuns null.
     * @param p_session_id Session Id
     * @return Proxy User Id if it's a proxy session else, NULL
     * @rep:lifecycle active
     * @rep:displayname Check current session for proxy/normal
     * @rep:compatibility S
     */
function isProxySession(p_session_id in number default null) return number;

--  *** INTERNAL API to be used by AOL only ***
--      The newSSOSession API is to be used to invalidate/timeout SSO sessions
--      when limiting SSO users to one session in an EBS instance
--      It is similar to the doNewSession API which limits the local ICX
--      sessions.
PROCEDURE newSSOSession(p_user_id in number default null, p_session_id in number);


-- Bug 13487530
-- This api returns true if the release is 12.1 or higher.
-- Session hijacking is supported in releases 12.1.3 and higher only.
-- 12.1.3 is an FND.B session hijacking dependency and any backport to
-- 12.1.1 or 12.1.2 files impacted by session hijacking will require a
-- branch on branch.
function is_hijack_session return boolean;

----------------------------------
--  Language Calculation (Bug 22256016)
--
--  Language Calcualtion configuration API
----
--  Set the language rule for the SITE,a SERVER or USER
--  use rule=NULL to remove the rule.
--
--
PROCEDURE setLanguageRule(
      rule  in varchar2 default 'SESSION,DISPLAY,BROWSER,PROFILE,BASE', -- use null to remove rule
      level in varchar2  default 'SITE', -- or SERVER or USER
      level_value_name    in varchar2 default null   --  FND_NODES.SERVER_NAME or FND_USER.USER_NAME
    );
--
--
-- Retrieves the language rule for SITE,SERVER or USER
-- If smate rule for all is ena enabled(default) the the SERVER/SITE is returned instead.
---
FUNCTION  getLanguageRule(
      level in varchar2  default 'SITE', -- or SERVER or USER
      level_value_name    in varchar2 default null   --  FND_NODES.SERVER_NAME or FND_USER.USER_NAME
    ) return varchar2;

--
-- Set the option to apply the same rule for all users or not
-- Use null to retrieve current setting
-- Pass TRUE or FALSE to enabled or disable this restriction.
--
FUNCTION sameLanguageRuleForAll( optionVal IN BOOLEAN DEFAULT NULL) return VARCHAR2;



end FND_SESSION_MANAGEMENT;

/
