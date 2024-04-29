--------------------------------------------------------
--  DDL for Package Body JTF_SEC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_SEC_UTIL_PKG" AS
/* $Header: JTFSECB.pls 115.2 2002/06/17 22:22:50 dehu noship $ */
FUNCTION conv_special_html_chars (html_str IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
RETURN(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(html_str,
'&', '&#38;'),
'<', '&#60;'),
'>', '&#62;'),
'"', '&#34;'),
'''', '&#39;'));

END conv_special_html_chars;

end jtf_sec_util_pkg;

/
