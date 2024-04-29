--------------------------------------------------------
--  DDL for Package Body JAI_PAN_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PAN_UPDATE_PKG" as
/* $Header: jai_pan_update_b.plb 120.0.12000000.1 2007/07/24 06:56:06 rallamse noship $ */

PROCEDURE Print_Log
        (
        P_debug                 IN      VARCHAR2,
        P_string                IN      VARCHAR2
        ) IS

  stemp    VARCHAR2(1000);
  nlength  NUMBER := 1;

BEGIN

  IF (P_Debug = 'Y') THEN
     WHILE(length(P_string) >= nlength)
     LOOP

        stemp := substrb(P_string, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
        nlength := (nlength + 80);

     END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print_log;


Procedure pan_update ( P_errbuf      OUT NOCOPY varchar2,
		       P_return_code OUT NOCOPY varchar2,
                       P_vendor_id    IN         PO_VENDORS.vendor_id%TYPE,
                       P_old_pan_num  IN   JAI_AP_TDS_VENDOR_HDRS.pan_no%TYPE,
		       P_new_pan_num  IN   JAI_AP_TDS_VENDOR_HDRS.pan_no%TYPE,
		       P_debug_flag   IN         varchar2) is


/* Cursor to lock the jai_ap_tds_thhold_grps */

Cursor C_lock_thhold_grps is
 select threshold_grp_id,
        vendor_id,
	org_tan_num,
	vendor_pan_num,
	section_type,
	section_code,
	fin_year,
	total_invoice_amount,
	total_invoice_cancel_amount,
	total_invoice_apply_amount,
	total_invoice_unapply_amount,
	total_tax_paid,
	total_thhold_change_tax_paid,
	current_threshold_slab_id,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login
   from JAI_AP_TDS_THHOLD_GRPS
  where vendor_id = P_vendor_id
    and vendor_pan_num = p_old_pan_num
  order by vendor_id,threshold_grp_id
  for UPDATE of threshold_grp_id NOWAIT;



/* Update the tables in the following order

(1) ja_in_vendor_tds_info_hdr
(2) jai_ap_tds_thhold_grps
(3) jai_ap_tds_thhold_xceps

*/

lv_vendor_site_id_updated varchar2(1000) ;
lv_thhold_grp_id_updated varchar2(1000) ;
lv_thhold_xcep_id_updated varchar2(1000) ;
ln_request_id number;
lv_debug_flag varchar2(30);
lv_debug_msg varchar2(4000) ;


begin

 lv_debug_flag := nvl(p_debug_flag, 'N');

 lv_vendor_site_id_updated  := '';
 lv_thhold_grp_id_updated   := '';
 lv_thhold_xcep_id_updated  := '';

 fnd_file.put_line(FND_FILE.LOG, 'START OF Procedure ');

  ln_request_id := FND_GLOBAL.conc_request_id;

  lv_debug_msg := ' A. Report Parameters';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg := ' B. request id '|| ln_request_id ;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg := ' C. debug flag ' || lv_debug_flag;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg := ' D. old pan ' || P_old_pan_num ;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg := ' E. new pan ' || P_new_pan_num ;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg :='  F. vendor id '|| P_vendor_id;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

 -- Update the jai_ap_tds_thhold_grps

  lv_debug_msg := ' 1. Update JAI_AP_TDS_THHOLD_GRPS';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  for  thhold_grps in C_lock_thhold_grps
   loop

     lv_debug_msg := ' 2. Going to update JAI_AP_TDS_THHOLD_GRPS';

      If lv_debug_flag = 'Y' then
        Print_log(lv_debug_flag, lv_debug_msg);
      End if;

      update JAI_AP_TDS_THHOLD_GRPS
         set vendor_pan_num = P_new_pan_num
       where vendor_id = P_vendor_id
         and vendor_pan_num = P_old_pan_num
	 and threshold_grp_id = thhold_grps.threshold_grp_id;

      lv_debug_msg := ' 3. Done with update of '|| thhold_grps.threshold_grp_id;

      If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
      End if;

      lv_thhold_grp_id_updated := lv_thhold_grp_id_updated || '-' || thhold_grps.threshold_grp_id;

      lv_debug_msg := ' 4. Value of lv_thhold_grp_id_updated '|| lv_thhold_grp_id_updated;

      If lv_debug_flag = 'Y' then
        Print_log(lv_debug_flag, lv_debug_msg);
      End if;


   end loop;


 -- Update the JAI_AP_TDS_VENDOR_HDRS
  lv_debug_msg := ' 5. Update JAI_AP_TDS_VENDOR_HDRS';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  for vndr_tds_hdr in (select vthdr.*
                           from JAI_AP_TDS_VENDOR_HDRS vthdr
			  where vthdr.vendor_id = P_vendor_id
			    and vthdr.pan_no = P_old_pan_num)
    loop

     lv_debug_msg := ' 6. Going to update JAI_AP_TDS_VENDOR_HDRS';

     If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
     End if;

      update JAI_AP_TDS_VENDOR_HDRS
         set pan_no = P_new_pan_num
       where vendor_id = vndr_tds_hdr.vendor_id
         and vendor_site_id = vndr_tds_hdr.vendor_site_id
	 and pan_no = P_old_pan_num;


     lv_debug_msg := ' 7. Done with update of vendor '|| vndr_tds_hdr.vendor_id;
     lv_debug_msg := lv_debug_msg || ' site '|| vndr_tds_hdr.vendor_site_id ;

     If lv_debug_flag = 'Y' then
      Print_log(lv_debug_flag, lv_debug_msg);
     End if;

      If vndr_tds_hdr.vendor_site_id <> 0 Then
        lv_vendor_site_id_updated := lv_vendor_site_id_updated || ' - '||vndr_tds_hdr.vendor_site_id;
      End if;

      lv_debug_msg := ' 8. Value of lv_vendor_site_id_updated '|| lv_vendor_site_id_updated;


      If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
      End if;

    end loop;


 -- jai_ap_tds_thhold_xceps

  lv_debug_msg := ' 9. Update jai_ap_tds_thhold_xceps';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  for thhold_xceps in (select tdsxps.*
                          from jai_ap_tds_thhold_xceps tdsxps
			 where tdsxps.vendor_id = P_vendor_id
			   and vendor_pan = P_old_pan_num)
   loop

     lv_debug_msg := ' 10. Going to update jai_ap_tds_thhold_xceps';

     If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
     End if;

     Update jai_ap_tds_thhold_xceps
        set vendor_pan = P_new_pan_num
      where vendor_id = P_vendor_id
        and vendor_pan = P_old_pan_num;

     lv_debug_msg := ' 11. Done with update of vendor'||P_vendor_id ;

     If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
     End if;

     lv_thhold_xcep_id_updated := lv_thhold_xcep_id_updated || '-' || thhold_xceps.threshold_exception_id;

     lv_debug_msg := ' 12. Value of lv_thhold_xcep_id_updated '|| lv_thhold_xcep_id_updated;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

   end loop;


 -- insert a record in jai_ap_tds_pan_changes
 -- This help us to keep track of PAN changes for the given vendor


  lv_debug_msg := ' 13. Inside insert -  ';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

   Insert into jai_ap_tds_pan_changes
    ( pan_change_id,
      vendor_id,
      old_pan_num,
      new_pan_num,
      request_id,
      request_date,
      vendor_site_id_updated,
      thhold_grp_id_updated,
      thhold_xcep_id_updated,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    )
   values
    ( jai_ap_tds_pan_changes_s.nextval,
      P_vendor_id,
      P_old_pan_num,
      P_new_pan_num,
      ln_request_id,
      sysdate,
      lv_vendor_site_id_updated,
      lv_thhold_grp_id_updated,
      lv_thhold_xcep_id_updated,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id
    );


   commit;

Exception
    When others then

     IF (SQLCODE < 0) then

      If lv_debug_flag = 'Y' then
         Print_log(lv_debug_flag,lv_debug_msg);
         Print_log(lv_debug_flag,SQLERRM);
      End if;
     END IF;

    IF (SQLCODE = -54) then
      If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag,'(Pan update :Exception) Vendor to be updated by this process are locked');
      end if;
    END IF;

End pan_update;

End  jai_pan_update_pkg;

/
