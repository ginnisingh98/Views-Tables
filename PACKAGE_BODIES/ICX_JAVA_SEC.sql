--------------------------------------------------------
--  DDL for Package Body ICX_JAVA_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_JAVA_SEC" as
/* $Header: ICXJVSCB.pls 120.1 2005/10/07 13:30:56 gjimenez noship $ */

function validateSession( c_cookie_value in varchar2,
			  c_ip_value in varchar2,
			  c_function_code in varchar2 )
	RETURN BOOLEAN is

  n_session_id  number;


begin

  -- n_session_id := to_number(icx_call.decrypt(c_cookie_value, c_ip_value));
     n_session_id := to_number(icx_call.decrypt(c_cookie_value)); -- removed the parameter c_ip_value

  return (icx_sec.validateSessionPrivate(n_session_id, c_function_code));

end;

end icx_java_sec;

/
