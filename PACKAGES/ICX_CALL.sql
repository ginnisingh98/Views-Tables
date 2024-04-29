--------------------------------------------------------
--  DDL for Package ICX_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CALL" AUTHID CURRENT_USER as
/* $Header: ICXSECAS.pls 120.0 2005/10/07 12:18:32 gjimenez noship $ */

function encrypt(c_string varchar2) return varchar2;

function encrypt2(c_string varchar2,
                  c_session_id number default null) return varchar2;

function encrypt3(c_number in number,
                  c_number_of_digits in number default 4)
    return varchar2;

function encrypt4(p_string varchar2,
                  p_session_id number default null) return varchar2;

function decrypt(c_string varchar2) return varchar2;

function decrypt2(c_text_id number,
                  c_session_id number default null) return varchar2;

function decrypt3(c_hex in varchar2)
    return number;

function decrypt4(p_string varchar2,
                  p_session_id number default null) return varchar2;

function CRCHASH(KEYSTRING in varchar2, DATASTRING in varchar2)
    return number;

end icx_call;

 

/
