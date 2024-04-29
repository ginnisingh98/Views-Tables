--------------------------------------------------------
--  DDL for Package XXAH_VA_LINK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_VA_LINK_PKG" AS

  FUNCTION link_to_main(
     p_blanket_header_id IN  NUMBER
     ) RETURN VARCHAR2;

END xxah_va_link_pkg;

/
