--------------------------------------------------------
--  DDL for Package Body GMF_AP_GET_VENDOR_CONTACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_GET_VENDOR_CONTACTS" as
/* $Header: gmfvndcb.pls 115.0 99/07/16 04:26:05 porting shi $ */
          cursor cur_ap_get_vendor_contacts
            (st_date date, en_date date,
            vndor_contact_id number, vndr_sit_id number) is
       select VENDOR_CONTACT_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
            VENDOR_SITE_ID,
            LAST_UPDATE_LOGIN,
            CREATION_DATE, CREATED_BY, INACTIVE_DATE,
            FIRST_NAME, MIDDLE_NAME, LAST_NAME, PREFIX, TITLE, MAIL_STOP,
            AREA_CODE, PHONE

            from PO_VENDOR_CONTACTS

        where VENDOR_CONTACT_ID = nvl(vndor_contact_id, VENDOR_CONTACT_ID)
          and VENDOR_SITE_ID = nvl(vndr_sit_id, VENDOR_SITE_ID)
          and  last_update_date between
               nvl(st_date, last_update_date)
          and  nvl(en_date, last_update_date);

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
            row_to_fetch in out number, error_status out number )
            is

   begin
      IF NOT cur_ap_get_vendor_contacts%ISOPEN THEN
            OPEN cur_ap_get_vendor_contacts(st_date, en_date,
            vndor_contact_id, vndr_sit_id);
      END IF;



          fetch cur_ap_get_vendor_contacts
         into vndor_contact_id,
               lst_updt_dt, lst_updt_by,
            vndr_sit_id,
            lst_updt_login,
            create_dat, create_by, inact_dt,
            f_nam, m_nam, l_nam,
            prfx, ttle, ml_stop, ar_cd, ph;

             if cur_ap_get_vendor_contacts%NOTFOUND then
               error_status := 100;
                  end if;
      if cur_ap_get_vendor_contacts%NOTFOUND or row_to_fetch = 1 THEN
            CLOSE cur_ap_get_vendor_contacts;
    end if;


   exception
          when others then
          error_status := SQLCODE;


end AP_GET_VENDOR_CONTACTS;
END GMF_AP_GET_VENDOR_CONTACTS;

/
