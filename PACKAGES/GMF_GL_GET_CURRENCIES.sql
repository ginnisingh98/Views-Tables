--------------------------------------------------------
--  DDL for Package GMF_GL_GET_CURRENCIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_GET_CURRENCIES" AUTHID CURRENT_USER AS
/* $Header: gmfcurds.pls 115.0 99/07/16 04:17:09 porting shi $ */
  PROCEDURE proc_gl_get_currencies(
          st_date  in out  date,
          en_date    in out  date,
          cur_code    in out  varchar2,
          cur_name    in out  varchar2,
          descr          out  varchar2,
          preci          out  number,
          symb           out  varchar2,
          creation_date     out  date,
          created_by       out  number,
          last_update_date  out  date,
          last_updated_by    out  number,
          row_to_fetch   in out  number,
          error_status   out  number);
   FUNCTION get_name (
          usr_id    number ) return varchar2;
END GMF_GL_GET_CURRENCIES;

 

/
