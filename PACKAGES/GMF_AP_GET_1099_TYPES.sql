--------------------------------------------------------
--  DDL for Package GMF_AP_GET_1099_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AP_GET_1099_TYPES" AUTHID CURRENT_USER AS
/* $Header: gmftaxts.pls 115.0 99/07/16 04:24:48 porting shi $ */
  PROCEDURE proc_ap_get_1099_types(
          st_date  in out  date,
          en_date    in out  date,
          form_type   out  varchar2,
          formname    out   varchar2,
          descr out varchar2,
           inac_date out date,
          row_to_fetch in out number,
          error_status out   number);
END GMF_AP_GET_1099_TYPES;

 

/
