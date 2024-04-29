--------------------------------------------------------
--  DDL for Package ICX_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_LOGIN" AUTHID CURRENT_USER as
/* $Header: ICXLOGIS.pls 120.1 2005/10/07 13:35:12 gjimenez noship $ */

function validateSession(session_id in number) return number;

function get_fnd_message(application_code in varchar2,
                         message_name in varchar2,
                         message_token_name in varchar2 default null,
                         message_token_value in varchar2 default null)
         return varchar2;

function get_page_id(p_user_id in number)
         return number;


function replace_onMouseOver_quotes(p_string in varchar2,
                                    p_browser in varchar2)
         return varchar2;

end icx_login;
 

/
