--------------------------------------------------------
--  DDL for Package OE_STRING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_STRING_UTIL" AUTHID CURRENT_USER as
/* $Header: oexustrs.pls 115.1 99/07/16 08:30:26 porting shi $ */
PROCEDURE Get_Substring (String IN OUT VARCHAR2, Sub_string IN OUT VARCHAR2,
Delim VARCHAR2);

FUNCTION Parse_String (String VARCHAR2, Delim VARCHAR2, Delim_cnt NUMBER) RETURN
 VARCHAR2;

END OE_STRING_UTIL;

 

/
