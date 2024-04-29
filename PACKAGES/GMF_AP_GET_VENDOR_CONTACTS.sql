--------------------------------------------------------
--  DDL for Package GMF_AP_GET_VENDOR_CONTACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AP_GET_VENDOR_CONTACTS" AUTHID CURRENT_USER as
/* $Header: gmfvndcs.pls 115.0 99/07/16 04:26:10 porting shi $ */
          procedure AP_GET_VENDOR_CONTACTS
              (st_date in out date, en_date in out date,
            vndor_contact_id in out number,
            vndr_sit_id in out number,
               lst_updt_dt out date, lst_updt_by out number,
            lst_updt_login out number,
            create_dat out date, create_by out number, inact_dt out
            date, f_nam out varchar2, m_nam out varchar2, l_nam out varchar2,
            prfx out varchar2, ttle out varchar2, ml_stop out varchar2, ar_cd
            out varchar2, ph out varchar2,
            row_to_fetch in out number, error_status out number );
END GMF_AP_GET_VENDOR_CONTACTS;

 

/
