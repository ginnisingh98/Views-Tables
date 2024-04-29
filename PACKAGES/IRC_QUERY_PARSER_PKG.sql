--------------------------------------------------------
--  DDL for Package IRC_QUERY_PARSER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_QUERY_PARSER_PKG" AUTHID CURRENT_USER as
/* $Header: irctxqpr.pkh 120.0 2005/07/26 15:02:13 mbocutt noship $ */
function query_parser (input_text IN VARCHAR2)  return VARCHAR2;
function isInvalidKeyword (input_text IN VARCHAR2)  return BOOLEAN;
end;

 

/
