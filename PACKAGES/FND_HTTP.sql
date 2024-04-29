--------------------------------------------------------
--  DDL for Package FND_HTTP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_HTTP" AUTHID CURRENT_USER AS
/* $Header: AFSCHTPS.pls 115.0 99/07/16 23:29:02 porting ship  $ */

--Record of name,value pairs for ouput values
TYPE output_rec_type IS RECORD(name VARCHAR2(30),value VARCHAR2(240));

--Table of output name,value pairs.
TYPE output_tab_type IS TABLE OF output_rec_type INDEX BY BINARY_INTEGER;

--Table of encoded message strings
TYPE error_tab_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

-- Makes a http request to a java servlet. Parses the returned HTML
-- page and stores the values in the OUT parameters.
-- p_result is the value returned from the java servlet.This is
-- usually true or false, but it may also be error codes.
-- If the java program had any other information to return, these are
-- returned as a PL/SQL table of name-value pairs.
-- If the call failed, then the errors from the error stack are
-- returned in a PL/SQL table of encoded messages.
-- The caller should call fnd_message.set_encoded and fnd_message.get
-- to get the entire translated message.

PROCEDURE java_serv( p_url IN VARCHAR2,
		     p_result OUT VARCHAR2,
		     p_output_tab OUT output_tab_type,
		     p_encoded_errors_tab OUT error_tab_type);
END fnd_http;

 

/
