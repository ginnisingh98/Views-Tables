--------------------------------------------------------
--  DDL for Package IRC_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LOGIN" AUTHID CURRENT_USER as
/* $Header: irclogin.pkh 120.1 2007/11/04 14:30:39 gaukumar noship $ */
--
function createExecLink2
(p_function_name varchar2
,p_application_short_name varchar2
,p_responsibility_key varchar2
,p_security_group_key varchar2
,p_server_name varchar2
,p_parameters varchar2 default null)
return varchar2;
--
function validate_login(
    p_user    IN VARCHAR2,
    p_pwd     IN VARCHAR2,
    p_disable in varchar2)
return VARCHAR2;
--
procedure convertSession(p_token in VARCHAR2,
                      p_username IN VARCHAR2,
                      p_password IN VARCHAR2);
--
end irc_login;

/
