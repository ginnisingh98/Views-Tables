--------------------------------------------------------
--  DDL for Package Body JAI_AP_HA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_HA_TRIGGER_PKG" AS
/* $Header: jai_ap_ha_t.plb 120.6.12010000.4 2009/06/14 08:19:35 vumaasha ship $ */
  /*
  REM +======================================================================+
  REM NAME          BRI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_HA_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_HA_BRI_T3
  REM
  REM +======================================================================+
  */
  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	  cursor c_get_cm_details(p_invoice_id number) is
    select source
    from   ap_invoices_all
    where invoice_id = p_invoice_id;

  v_source            ap_invoices_all.source%type;


  BEGIN
    pv_return_code := jai_constants.successful ;

/*------------------------------------------------------------------------------------------
FILENAME: ja_in_ai_cm_po_hold_trg.sql

CHANGE HISTORY:
S.No      Date          Author AND Details
1         13/05/2005    Aparajita for bug#3604402. Version#619.1

                        Whenever a 'PO REQUIRED' hold is placed on the TDS invoices because of
                        the setup of PO matched invoices only for the supplier site,
                        it is automatically set to release as this PO matching is not required.

2.        29/11/2005    Aparajita for bug#4036241. Version#115.1

                        Introduced the call to centralized packaged procedure,
                        jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

3.        24/05/2005    Ramananda for bug# 4388958 File Version: 116.1
                        Changed AP Lookup code from 'TDS' to 'INDIA TDS'

4.        08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                        DB Entity as required for CASE COMPLAINCE.  Version 116.2

5.      13-Jun-2005    File Version: 116.3
                       Ramananda for bug#4428980. Removal of SQL LITERALs is done

Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      4036241    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0

--------------------------------------------------------------------------------------------------*/
--if
--  jai_cmn_utils_pkg.check_jai_exists (p_calling_object => 'JA_IN_AI_CM_PO_HOLD_TRG', p_org_id =>  pr_new.org_id)
--  =
--  FALSE
--then
--  /* India Localization funtionality is not required */
--  return;
--end if;


 open c_get_cm_details(pr_new.invoice_id);
 fetch c_get_cm_details into v_source;
 close c_get_cm_details;

 if v_source <> 'INDIA TDS' then -- 'TDS' then --Ramanand for bug#4388958
   -- only for TDS invoices created by india localization.
   return;
 end if;

  -- control comes here only when it is a TDS invoice created by india localization for TDS.
  pr_new.release_lookup_code := 'TDS Override';
  pr_new.release_reason := 'TDS Credit Memo need not be matched to any PO - automatically released' ;

EXCEPTION
  WHEN OTHERS THEN
   -- raise_application_error(-20000, 'Error - trigger ja_in_ai_cm_po_hold_trg : ' || sqlerrm);
   /* Added an exception block by Ramananda for bug#4570303 */
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_AP_HA_TRIGGER_PKG.BRI_T1 '  || substr(sqlerrm,1,1900);

END BRI_T1 ;

  /*
  REM +======================================================================+
  REM NAME          BRIUD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_HA_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_HA_BRIUD_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE BRIUD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	  CURSOR c_ap_invoices_all (p_invoice_id number) is
    SELECT vendor_id,
           vendor_site_id,
           invoice_currency_code,
           exchange_rate,
           set_of_books_id,
           source,
           cancelled_date,
           gl_date,
           org_id,
     			 --Bug#5131075(4685754). Added the below 3 by Lakshmi Gopalsami
				 	 invoice_amount,
				 	 payment_status_flag,
				 	 invoice_type_lookup_code

    FROM   ap_invoices_all
    WHERE  invoice_id = p_invoice_id;

  c_rec_ap_invoices_all     c_ap_invoices_all%rowtype;
  lv_codepath               VARCHAR2(1996);
  lv_is_invoice_validated   varchar2(1);
  lv_process_flag           varchar2(20);
  lv_process_message        varchar2(200);

  lb_result                 boolean;
  ln_req_id                 number;
  ln_org_id                 ap_invoices_all.org_id%type;
  lv_request_id             number ; -- added, Harshita for Bug#5131075(5346558)
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: ja_in_ap_aha_after_trg.sql

CHANGE HISTORY:
S.No      Date          Author and Details

1.     25/03/2004    Aparajita. Bug # 4088186. TDS Clean up. Version#115.0
                       This is the only trigger introduced for all the before event
                       on the table on which this is based.

2.     4384239        File Version: 116.0
                      Procedures, packages, funtions merged into packages

3.     4388958        Ramananda for bug# 4388958 File Version: 116.1
                      Changed AP Lookup code from 'TDS' to 'INDIA TDS'

4.     08-Jun-2005    This Object is Modified to refer to New DB Entity names in place of Old
                      DB Entity as required for CASE COMPLAINCE.  Version 116.2

5. 13-Jun-2005    File Version: 116.3
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

Dependency:
----------

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      3924692    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0



------------------------------------------------------------------------------------------ */

 /* if pv_action = jai_constants.inserting or pv_action = jai_constants.updating then
  ln_org_id := pr_new.org_id;
 elsif pv_action = jai_constants.deleting then
  ln_org_id := pr_old.org_id;
 end if;
 */
  --if
  --  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_AP_AHA_AFTER_TRG',
  --                               p_org_id           =>  ln_org_id
  --                               )
  --  =
  --  FALSE
  --then
    /* India Localization funtionality is not required */
  --  return;
  -- end if;

	--Added by Sanjikum for Bug#5131075(4644291)
	IF pv_action = jai_constants.inserting OR pv_action = jai_constants.deleting THEN
		RETURN;
	END IF;


  /*
	|| TDS Invoice generation  Functionality Bug # 4088186
	*/
  open  c_ap_invoices_all(pr_new.invoice_id);
  fetch c_ap_invoices_all into c_rec_ap_invoices_all;
  close c_ap_invoices_all;

  if   pv_action = jai_constants.updating and
      pr_new.release_reason is not null and
      c_rec_ap_invoices_all.source <> 'INDIA TDS' and /* 'TDS' and --Ramanand for bug#4388958 */
      c_rec_ap_invoices_all.cancelled_date is null
  then

		/* Bug#5131075(4683207). Added by Lakshmi Gopalsami
				Don't proceed for TDS invoice creation if the invoice type
				is either 'CREDIT' or 'DEBIT'
		*/

		If c_rec_ap_invoices_all.invoice_type_lookup_code
								IN ('CREDIT', 'DEBIT')
		Then
			 return;
		End if;

    lv_codepath := null;

		 -- added, Harshita for Bug#5131075(5346558)

		 IF NVL(jai_ap_tds_generation_pkg.gn_invoice_id, -1) = pr_new.invoice_id THEN
			 lv_request_id := jai_ap_tds_generation_pkg.gv_request_id ;
		 END IF ;

		 /*  Bug#5131075(4685754). Added by Lakshmi Gopalsami
					Call the concurrent program if the hold is user
				 releasable and non-postable
		 */

			-- Invoke the concurrent program.

			lb_result := Fnd_Request.set_mode(TRUE);

			ln_req_id := fnd_request.submit_request(
				 'JA',
			 'JAINTDSHD',     --replaced JAITDSHD by JAINTDSHD for bug#6598181
			 'India - Generate TDS Invoices after Holds release',
			 '',
			 FALSE,
			 pr_new.invoice_id,
			 c_rec_ap_invoices_all.invoice_amount,
			 c_rec_ap_invoices_all.payment_status_flag,
			 c_rec_ap_invoices_all.invoice_type_lookup_code,
			 c_rec_ap_invoices_all.vendor_id,
			 c_rec_ap_invoices_all.vendor_site_id,
			 c_rec_ap_invoices_all.gl_date,
			 c_rec_ap_invoices_all.invoice_currency_code,
			 c_rec_ap_invoices_all.exchange_rate,
			 c_rec_ap_invoices_all.set_of_books_id,
			 c_rec_ap_invoices_all.org_id,
						 'JAI_AP_HA_TRIGGER_PKG.BRIUD_T1',
			 lv_process_flag,
			 lv_process_message,
			 lv_codepath,
			 lv_request_id  -- added, Harshita for Bug#5131075(5346558)
					);

			 -- added, Harshita for Bug#5131075(5346558)
			 jai_ap_tds_generation_pkg.gn_invoice_id := pr_new.invoice_id ;
			 jai_ap_tds_generation_pkg.gv_request_id := ln_req_id  ;
			 -- ended, Harshita for Bug#5131075(5346558)

     	return;

  		/* Removed the reference in old code by Lakshmi for bug#5131075(4685754)*/

  end if; /* updating */


 /* Added an exception block by Ramananda for bug#4570303 */
 EXCEPTION
   WHEN OTHERS THEN
	   --raise_application_error(-20000, 'Error - ja_in_ap_aha_after_trg on ap_holds_all   : ' || sqlerrm);
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_AP_HA_TRIGGER_PKG.ARI_T7 '  || substr(sqlerrm,1,1900);

  END BRIUD_T1 ;

END JAI_AP_HA_TRIGGER_PKG ;

/
