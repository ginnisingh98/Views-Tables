--------------------------------------------------------
--  DDL for Package Body GMF_AP_GET_1099_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_GET_1099_TYPES" AS
/* $Header: gmftaxtb.pls 115.0 99/07/16 04:24:43 porting shi $ */
  CURSOR cur_ap_get_1099_types(st_date date, en_date date)
    IS
        SELECT   '', income_tax_type, description, inactive_date
           FROM     ap_income_tax_types
        WHERE    last_update_date
        BETWEEN nvl(st_date, last_update_date)
        AND nvl(en_date,last_update_date);
        /*
        SELECT   form_type_name, form_name, description, inactive_date
           FROM     ap_1099_types
        WHERE    last_update_date
        BETWEEN nvl(st_date, last_update_date)
        AND nvl(en_date,last_update_date);
*/
  PROCEDURE proc_ap_get_1099_types(
          st_date  in out  date,
          en_date    in out  date,
          form_type   out  varchar2,
          formname    out   varchar2,
          descr out varchar2,
           inac_date out date,
          row_to_fetch in out number,
          error_status out   number) is

  Begin  /*Beginning of procedure proc_ap_get_1099_types*/
    IF NOT cur_ap_get_1099_types%ISOPEN THEN
      OPEN cur_ap_get_1099_types(st_date, en_date);
    END IF;

    FETCH cur_ap_get_1099_types
    INTO   form_type, formname, descr, inac_date;

    IF cur_ap_get_1099_types%NOTFOUND or row_to_fetch = 1 THEN
      CLOSE cur_ap_get_1099_types;
      if cur_ap_get_1099_types%NOTFOUND then
         error_status := 100;
         end if;
      RETURN;
    END IF;

/* Exception Handling */

    EXCEPTION

      when others then
      error_status := SQLCODE;

  END;  /*End of procedure proc_ap_get_1099_types*/
END GMF_AP_GET_1099_TYPES;  -- END GMF_AP_GET_1099_TYPES

/
