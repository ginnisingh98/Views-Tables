--------------------------------------------------------
--  DDL for Package ICX_PORTLET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_PORTLET" AUTHID CURRENT_USER as
/* $Header: ICXPUTIS.pls 120.0 2005/10/07 12:17:58 gjimenez noship $ */

TYPE responsibility IS RECORD (
        ids            varchar2(80),
        name           varchar2(240));

TYPE responsibilityTable IS TABLE OF responsibility index by binary_integer;

procedure responsibilities(p_portlet_id       in number,
                           p_responsibilities out NOCOPY icx_portlet.responsibilityTable);

-- Returns SSWA session id
function validateSessionpart1
  return number;

function validateSessionpart2(p_session_id        in number,
                              p_application_id    in number default NULL,
                              p_responsibility_id in number default NULL,
                              p_security_group_id in number default NULL,
                              p_function_id       in number default NULL)
  return boolean;

function validateSession(p_application_id    in number default NULL,
                         p_responsibility_id in number default NULL,
                         p_security_group_id in number default NULL,
                         p_function_id       in number default NULL)
  return boolean;

function createBookmarkLink(p_text                   varchar2,
                            p_application_id         number,
                            p_responsibility_id      number,
                            p_security_group_id      number,
                            p_function_id            number,
                            p_function_type          varchar2 default 'WWW',
                            p_web_html_call          varchar2 default null,
                            p_target                 varchar2 default '_top',
                            p_session_id             number   default null,
                            p_agent                  varchar2 default null,
                            p_parameters             varchar2 default null)
  return varchar2;


-- Special version of the createBookmarkLink to be used only by
-- the OA Framework navigate (and similar) portlet(s).

function createFwkBookmarkLink(p_text                   varchar2,
                            p_application_id         number,
                            p_responsibility_id      number,
                            p_security_group_id      number,
                            p_function_id            number,
                            p_function_type          varchar2 default 'WWW',
                            p_web_html_call          varchar2 default null,
                            p_target                 varchar2 default '_top',
                            p_session_id             number   default null,
                            p_agent                  varchar2 default null,
                            p_parameters             varchar2 default null)
  return varchar2;

procedure updCacheByUser(p_user_name varchar2);

procedure updCacheByFuncName(p_function_name varchar2);

procedure updateCacheByUserFunc(p_user_name varchar2, p_function_name varchar2);

procedure updCacheKeyValueByUser(p_user_name varchar2, p_caching_key_value varchar2);

procedure updCacheKeyValueByFuncName(p_function_name varchar2, p_caching_key_value varchar2);

procedure updateCacheKeyValueByUserFunc(p_user_name varchar2, p_function_name varchar2, p_caching_key_value varchar2);

procedure updCacheKeyValueByPortletRef(p_reference_path varchar2, p_caching_key_value varchar2);


function createExecLink(p_application_id         number,
                        p_responsibility_id      number,
                        p_security_group_id      number,
                        p_function_id            number,
                        p_parameters             VARCHAR2 DEFAULT NULL,
                        p_target                 varchar2 default '_top',
                        p_link_name              VARCHAR2 DEFAULT NULL,
                        p_url_only               VARCHAR2 DEFAULT 'N')
                       return VARCHAR2;

function createExecLink2(p_application_short_name  VARCHAR2,
                         p_responsibility_key      VARCHAR2,
                         p_security_group_key      VARCHAR2,
                         p_function_name           VARCHAR2,
                         p_parameters              VARCHAR2 DEFAULT NULL,
                         p_target                  varchar2 default '_top',
                         p_link_name               VARCHAR2 DEFAULT NULL,
                         p_url_only                VARCHAR2 DEFAULT 'N')
                       return VARCHAR2;

function GET_CACHING_KEY(p_reference_path VARCHAR2) return VARCHAR2;

FUNCTION SSORedirect (p_req_url IN VARCHAR2 DEFAULT NULL,
                      p_cancel_url IN VARCHAR2 DEFAULT NULL)
                      RETURN VARCHAR2;

Function listener_token return varchar2;


end ICX_PORTLET;

 

/
