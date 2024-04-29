--------------------------------------------------------
--  DDL for Package JTF_SEC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_SEC_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFSECS.pls 115.2 2002/06/17 22:22:39 dehu noship $ */
/*
 * FUNCTION NAME:	conv_special_html_chars
 * DESCRIPTION:
 *			converts html special characters to prevent
 *			cross-site scripting attack.  converts the following
 *                      characters that have special meanings under
 *                      HTML spec to their numerical entity representation:
 *				< > & " '
 * PARAMETERS:
 *			html_str IN  HTML string that will be converted
 */
FUNCTION conv_special_html_chars (html_str IN VARCHAR2) RETURN VARCHAR2;
END jtf_sec_util_pkg;

 

/
