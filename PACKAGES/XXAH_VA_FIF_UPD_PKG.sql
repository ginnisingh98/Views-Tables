--------------------------------------------------------
--  DDL for Package XXAH_VA_FIF_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_VA_FIF_UPD_PKG" 
AS
PROCEDURE UPDATE_SA_LINES (errbuf OUT VARCHAR2
                          ,retcode OUT VARCHAR2
                         ,p_blanket_number in oe_blanket_headers_all.
      order_number%type
                         ,p_line_number in oe_blanket_lines_all.line_number%
      type );
END xxah_va_fif_upd_pkg;

/
