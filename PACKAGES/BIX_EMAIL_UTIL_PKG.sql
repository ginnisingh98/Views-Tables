--------------------------------------------------------
--  DDL for Package BIX_EMAIL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_EMAIL_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxeuts.pls 115.10 2002/11/27 00:26:58 djambula noship $ */

FUNCTION get_max_date_of_email_table(p_context IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_max_date_of_agent_table(p_context IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_email_table_footer(p_context IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_agent_table_footer(p_context IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

END BIX_EMAIL_UTIL_PKG;

 

/
