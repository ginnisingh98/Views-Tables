--------------------------------------------------------
--  DDL for Package ICX_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_SEC" AUTHID CURRENT_USER as
/* $Header: ICXSESES.pls 120.0 2005/10/07 12:19:58 gjimenez noship $ */

        PV_CUST_CONTACT_ID              CONSTANT NUMBER := 7;
        PV_VEND_CONTACT_ID              CONSTANT NUMBER := 8;
        PV_INT_CONTACT_ID               CONSTANT NUMBER := 9;
        PV_WEB_USER_ID                  CONSTANT NUMBER := 10;
        PV_USER_ID                      CONSTANT NUMBER := 10;
        PV_LANGUAGE_CODE                CONSTANT NUMBER := 21;
        PV_DATE_FORMAT                  CONSTANT NUMBER := 22;
        PV_SESSION_ID                   CONSTANT NUMBER := 23;
        PV_RESPONSIBILITY_ID            CONSTANT NUMBER := 24;
        PV_USER_REQ_TEMPLATE            CONSTANT NUMBER := 25;
        PV_USER_REQ_OVERRIDE_REQUESTOR  CONSTANT NUMBER := 26;
        PV_USER_REQ_OVERRIDE_LOC_FLAG   CONSTANT NUMBER := 27;
        PV_USER_REQ_DAYS_NEEDED_BY      CONSTANT NUMBER := 28;
        PV_ORG_ID                       CONSTANT NUMBER := 29;
        PV_SESSION_MODE                 CONSTANT NUMBER := 30;
        PV_FUNCTION_ID                  CONSTANT NUMBER := 31;
        PV_FUNCTION_TYPE                CONSTANT NUMBER := 32;
        PV_USERNAME                     CONSTANT NUMBER := 99;
        PV_USER_NAME                    CONSTANT NUMBER := 99;


        TYPE g_char_tbl_type        is table of varchar2(240) index by BINARY_INTEGER;
        TYPE g_date_tbl_type        is table of date          index by BINARY_INTEGER;
        TYPE g_num_tbl_type         is table of number        index by BINARY_INTEGER;

-- For passing more meaningful error messages to JAVA

g_validation_error varchar2(240);

-- ICX_SESSIONS

g_session_id number := -1;
g_transaction_id number := -1;
g_resp_appl_id number := -1;
g_responsibility_id number := -1;
g_security_group_id number := -1;
g_org_id number := -1;
g_function_id number := -1;
g_function_type varchar2(30) := '';
g_menu_id number := -1;
g_page_id number := -1;

g_user_id number := -1;
g_language varchar2(30) := 'AMERICAN';
g_language_code varchar2(30) := 'US';
g_date_format varchar2(80) := 'DD-MON-RRRR';
g_date_language varchar2(30) := 'AMERICAN';
g_numeric_characters varchar2(30) := '.,';
g_nls_sort varchar2(30) := 'BINARY';
g_nls_territory varchar2(30) := 'AMERICA';
g_login_id NUMBER := -1; -- mputman added 2020952
g_prog_appl_id number := -1;
--Bug 3238722
g_p_loginID NUMBER;
g_p_expired varchar2(10);

--added connection level globals for
--1574527 mputman
g_language_c varchar2(30) := null;
g_language_code_c varchar2(30) := null;
g_date_format_c varchar2(80) := null;
g_date_language_c varchar2(30) := null;
g_numeric_characters_c varchar2(30) := null;
g_nls_sort_c varchar2(30) := null;
g_nls_territory_c varchar2(30) := null;

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
g_window_cookie_name varchar2(30) := '';

-- nlbarlow 1574527

g_validateSession_flag boolean := true;

-- for returning a list of responsibilities for a user
type g_responsibility_list is table of varchar2(100)
        index by binary_integer;

function validatePassword(c_user_name     in varchar2,
                          c_user_password in varchar2,
                          n_session_id    out NOCOPY number,
                          c_validate_only in varchar2 default 'N',
                          c_mode_code     in varchar2 default '115P',
                          c_url           in varchar2 default null)
                          return varchar2;

function createSession(p_user_id   in number,
                       c_mode_code in varchar2 default 'SLAVE',
                       c_sec_grp_id in NUMBER DEFAULT NULL,
                       p_server_id in varchar2 DEFAULT NULL)
                        return number;

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

procedure createSessionCookie(p_session_id in number);

function NewSession( user_info  in fnd_user%rowtype,
                     c_user_name        in varchar2,
                     c_password         in varchar2,
                     n_session_id       out NOCOPY number,
                     c_validate_only    in varchar2 default 'N',
                     c_mode_code        in varchar2 default '115P')
                        return varchar2;

procedure ServerLevel(p_server_id in varchar2 default NULL);

function PseudoSession (n_session_id            out NOCOPY number,
                        IncludeHeader           in  boolean default TRUE)
                        return varchar2;

function setSessionPublic(p_ticket in varchar2) return BOOLEAN;



procedure setSessionPrivate( p_session_id        in  number,
                             p_success           out NOCOPY boolean);

procedure setSessionPrivate( p_user_id           in number,
                            p_responsibility_id  in number,
                            p_resp_appl_id       in number,
                            p_security_group_id  in number,
                            p_date_format        in varchar2,
                            p_language           in varchar2,
                            p_date_language      in varchar2,
                            p_numeric_characters in varchar2,
                            p_nls_sort           in varchar2,
                            p_nls_territory      in varchar2);

function validatePlugSession(p_plug_id        in number,
                             p_session_id     in number default NULL,
                             p_update_context in varchar2 default 'N')
                            return BOOLEAN;

function validateSessionPrivate( c_session_id        in number,
                                 c_function_code     in varchar2 default NULL,
                                 c_validate_only     in varchar2 default 'N',
                                 c_commit            in boolean default TRUE,
                                 c_update            in boolean default TRUE,
                                 c_responsibility_id in number default NULL,
                                 c_function_id       in number default NULL,
                                 c_resp_appl_id      in number default NULL,
                                 c_security_group_id in number default NULL,
                                 c_validate_mode_on  in varchar2 default 'Y',
                                 c_transaction_id    in number default NULL)
                                return BOOLEAN;

function validateSessionPrivate( c_encrypted_session_id in varchar2,
                                 c_function_code     in varchar2 default NULL,
                                 c_validate_only     in varchar2 default 'N',
                                 c_commit            in boolean default TRUE,
                                 c_update            in boolean default TRUE,
                                 c_responsibility_id in number default NULL,
                                 c_function_id       in number default NULL,
                                 c_resp_appl_id      in number default NULL,
                                 c_security_group_id in number default NULL,
                                 c_validate_mode_on  in varchar2 default 'Y',
                                 c_encrypted_transaction_id in varchar2 default NULL,
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
                                return BOOLEAN;

function validateSession( c_function_code     in varchar2 default NULL,
                          c_validate_only     in varchar2 default 'N',
                          c_commit            in boolean default TRUE,
                          c_update            in boolean default TRUE,
                          c_validate_mode_on  in varchar2 default 'Y')
                         return BOOLEAN;

function disableUserSession(c_session_id in number default null,
                            c_user_id in number default null) return BOOLEAN;

procedure RemoveCookie;

procedure writeAudit;

procedure set_org_context(
                     n_session_id in number,
                     n_org_id     in number);

function getID( n_param in number,
                c_logo  in varchar2 default 'Y',
                p_session_id in number default NULL)
                return varchar2;

procedure getResponsibilityList(c_user_id        in number,
                                c_application_id in number default null,
                                c_responsibility_list  out NOCOPY g_responsibility_list);

procedure putSessionAttributeValue(p_name in varchar2,
                                   p_value in varchar2,
                                   p_session_id in number default null);

function getSessionAttributeValue(p_name in varchar2,
                                  p_session_id in number default null)
                                  return varchar2;

procedure clearSessionAttributeValue(p_name in varchar2,
                                     p_session_id in number default null);

procedure sendsessioncookie(p_session_id in number);

function getsessioncookie(p_ticket in varchar2 default null) return number;

function getsessioncookiename return varchar2;

function getsessioncookiedomain return varchar2;

procedure getSecureAttributeValues(p_return_status  out NOCOPY varchar2,
                                   p_attri_code     in varchar2,
                                   p_char_tbl      out NOCOPY g_char_tbl_type,
                                   p_session_id      in number default -1);

procedure getSecureAttributeValues(p_return_status  out NOCOPY varchar2,
                                   p_attri_code     in varchar2,
                                   p_date_tbl     out NOCOPY g_date_tbl_type,
                                   p_session_id      in number default -1);

procedure getSecureAttributeValues(p_return_status  out NOCOPY varchar2,
                                   p_attri_code     in varchar2,
                                   p_num_tbl       out NOCOPY g_num_tbl_type,
                                   p_session_id      in number default -1);

function createRFURL( p_function_name          varchar2 default null,
                      p_function_id            number   default null,
                      p_application_id         number,
                      p_responsibility_id      number,
                      p_security_group_id      number,
                      p_session_id             number   default null,
                      p_parameters             varchar2 default null )
         return varchar2;

function createRFLink( p_text                   varchar2,
                       p_application_id         number,
                       p_responsibility_id      number,
                       p_security_group_id      number,
                       p_function_id            number,
                       p_target                 varchar2 default '_top',
                       p_session_id             number   default null)
         return varchar2;

procedure updateSessionContext( p_function_name          varchar2 default null,
                                p_function_id            number   default null,
                                p_application_id         number,
                                p_responsibility_id      number,
                                p_security_group_id      number,
                                p_session_id             number   default null,
                                p_transaction_id         number   default null);

function jumpIntoFlow(  c_person_id     in number default null,
                        c_application_id        in number,
                        c_flow_code     in varchar2,
                        c_sequence      in number default null,
                        c_key1          in varchar2 default null,
                        c_key2          in varchar2 default null,
                        c_key3          in varchar2 default null,
                        c_key4          in varchar2 default null,
                        c_key5          in varchar2 default null,
                        c_key6          in varchar2 default null,
                        c_key7          in varchar2 default null,
                        c_key8          in varchar2 default null,
                        c_key9          in varchar2 default null,
                        c_key10         in varchar2 default null)
                        return varchar2;

function jumpIntoFunction(p_application_id      in number,
                          p_function_code       in varchar2,
                          p_parameter1          in varchar2 default null,
                          p_parameter2          in varchar2 default null,
                          p_parameter3          in varchar2 default null,
                          p_parameter4          in varchar2 default null,
                          p_parameter5          in varchar2 default null,
                          p_parameter6          in varchar2 default null,
                          p_parameter7          in varchar2 default null,
                          p_parameter8          in varchar2 default null,
                          p_parameter9          in varchar2 default null,
                          p_parameter10         in varchar2 default null,
                          p_parameter11         in varchar2 default null)
                          return varchar2;

function getNLS_PARAMETER(p_param in VARCHAR2)
                return varchar2; -- mputman added



function NewSessionId(dummy in number)
                     return number;      -- bug 1388903

PROCEDURE set_session_nls (p_session_id IN NUMBER,
                              p_language IN VARCHAR2,
                              p_date_format_mask IN VARCHAR2,
                              p_language_code IN VARCHAR2,
                              p_date_language IN VARCHAR2,
                              p_numeric_characters IN VARCHAR2,
                              p_sort IN VARCHAR2,
                              p_territory IN VARCHAR2); --mputman added for AOLJ/CRM

FUNCTION CHECK_SESSION(p_session_id IN NUMBER,
                       p_resp_id IN NUMBER DEFAULT NULL,
                       p_app_resp_id IN NUMBER DEFAULT NULL)
                RETURN VARCHAR2;

FUNCTION recreate_session(i_1 IN VARCHAR2,
                          i_2 IN VARCHAR2,
                          p_enc_session IN VARCHAR2,
                          p_mode IN VARCHAR2 DEFAULT '115p')
               RETURN VARCHAR2;

function recreateURL(p_session_id IN NUMBER,
                     p_user_name  in varchar2)
                 return VARCHAR2;

procedure newSessionRaiseEvent (p_user_id     in varchar2 DEFAULT '-7777',
                               p_session_id  in varchar2 DEFAULT '-7777');


function  doNewSessionEvent  (p_guid       in raw,
                              p_evtMsg     in out NOCOPY wf_event_t)
   return VARCHAR2;

/* no longer needed after fix for bug 3238722
function newLoginId
   return number;
*/

PROCEDURE disableSessions (threshold IN NUMBER);

FUNCTION anonFunctionTest(p_func_id IN VARCHAR2,
                          p_user_id IN NUMBER DEFAULT NULL)

                          RETURN BOOLEAN;
PROCEDURE setUserNLS  (p_user_id             IN NUMBER,
                       l_language                OUT NOCOPY varchar2,
                       l_language_code        OUT NOCOPY varchar2,
                       l_date_format          OUT NOCOPY varchar2,
                       l_date_language        OUT NOCOPY varchar2,
                       l_numeric_characters     OUT NOCOPY varchar2,
                       l_nls_sort          OUT NOCOPY varchar2,
                       l_nls_territory          OUT NOCOPY varchar2,
                       l_limit_time                   OUT NOCOPY NUMBER,
                       l_limit_connects    OUT NOCOPY NUMBER,
                       l_org_id              OUT NOCOPY varchar2);


PROCEDURE setUserNLS  (p_user_id             IN NUMBER,
                       l_language                OUT NOCOPY varchar2,
                       l_language_code        OUT NOCOPY varchar2,
                       l_date_format          OUT NOCOPY varchar2,
                       l_date_language        OUT NOCOPY varchar2,
                       l_numeric_characters     OUT NOCOPY varchar2,
                       l_nls_sort          OUT NOCOPY varchar2,
                       l_nls_territory          OUT NOCOPY varchar2,
                       l_limit_time                   OUT NOCOPY NUMBER,
                       l_limit_connects    OUT NOCOPY NUMBER,
                       l_org_id              OUT NOCOPY varchar2,
                       l_timeout             OUT NOCOPY NUMBER);


end icx_sec;

 

/
