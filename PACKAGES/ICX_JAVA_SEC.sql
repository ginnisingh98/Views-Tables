--------------------------------------------------------
--  DDL for Package ICX_JAVA_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_JAVA_SEC" AUTHID CURRENT_USER as
/* $Header: ICXJVSCS.pls 120.1 2005/10/07 13:31:57 gjimenez noship $ */

function validateSession( c_cookie_value in varchar2,
			  c_ip_value in varchar2,
			  c_function_code in varchar2 )
	RETURN BOOLEAN;

end icx_java_sec;

 

/
