--------------------------------------------------------
--  DDL for Package Body JAI_AP_PSA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_PSA_TRIGGER_PKG" AS
/* $Header: jai_ap_psa_t.plb 120.0 2005/09/01 12:34:50 rallamse noship $ */
  /*
  REM +======================================================================+
  REM NAME          BRIUD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_PSA_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_PSA_BRIUD_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE BRIUD_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
	  cursor c_ap_invoices_all(p_invoice_id number) is
    select  source,
            invoice_type_lookup_code
    from    ap_invoices_all
    where   invoice_id = p_invoice_id;

  cursor  c_jai_ap_tds_thhold_trxs(p_invoice_id number) is
    select parent_inv_payment_priority
    from   jai_ap_tds_thhold_trxs
    where  invoice_to_vendor_id = p_invoice_id;

  ln_parent_inv_payment_priority    jai_ap_tds_thhold_trxs.parent_inv_payment_priority%type;
  r_ap_invoices_all                 c_ap_invoices_all%rowtype;
  ln_org_id                         ap_invoices_all.org_id%type;

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: ja_in_ap_apsa_before_trg.sql

CHANGE HISTORY:
S.No      Date         Author and Details

1.       25/03/2004    Aparajita. Bug # 4088186. TDS Clean up. Version#115.0

                       This is the only trigger introduced for all the before event
                       on the table on which this is based.

2.     24/05/2005     Ramananda for bug# 4388958 File Version: 116.1
                      Changed AP Lookup code from 'TDS' to 'INDIA TDS'

3.     08-Jun-2005    This Object is Modified to refer to New DB Entity names in place of Old
                      DB Entity as required for CASE COMPLAINCE.  Version 116.2

4. 13-Jun-2005    File Version: 116.3
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
 /*if pv_action = jai_constants.inserting or pv_action = jai_constants.updating then
  ln_org_id := pr_new.org_id;
 elsif pv_action = jai_constants.deleting then
  ln_org_id := pr_old.org_id;
 end if;*/

  --if
  --  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_AP_APSA_BEFORE_TRG',
  --                               p_org_id           =>  ln_org_id
  --                               )
  --  =
  --  FALSE
  --then
    /* India Localization funtionality is not required */
  --  return;
  -- end if;


  /* Payment Priority  Functionality */

  if pv_action = jai_constants.inserting then

    open  c_ap_invoices_all(pr_new.invoice_id);
    fetch c_ap_invoices_all into r_ap_invoices_all;
    close c_ap_invoices_all;

    if not (r_ap_invoices_all.invoice_type_lookup_code = 'CREDIT' and r_ap_invoices_all.source = 'INDIA TDS' ) then /*--Ramanand for bug#4388958 --'TDS') then*/
      goto exit_from_trigger;
    end if;

    /* Control will come here only when the invoice is a credit memo to the supplier for TDS */

    /* Get the payment priority */
    open  c_jai_ap_tds_thhold_trxs(pr_new.invoice_id);
    fetch c_jai_ap_tds_thhold_trxs into ln_parent_inv_payment_priority;
    close c_jai_ap_tds_thhold_trxs;

    if ln_parent_inv_payment_priority is not null then
      pr_new.payment_priority := ln_parent_inv_payment_priority;
    end if;

  end if; /*  if pv_action = jai_constants.inserting than  */

  << exit_from_trigger >>
    return;

	 /* Added an exception block by Ramananda for bug#4570303 */
   EXCEPTION
     WHEN OTHERS THEN
		   --raise_application_error(-20000, 'Error - trigger ja_in_ap_apsa_before_trg on ap_payment_schedules_all : ' || sqlerrm);
       Pv_return_code     :=  jai_constants.unexpected_error;
       Pv_return_message  := 'Encountered an error in JAI_AP_PSA_TRIGGER_PKG.BRIUD_T1  '  ||
			                       'Error on ap_payment_schedules_all : ' || substr(sqlerrm,1,1800);
  END BRIUD_T1 ;

END JAI_AP_PSA_TRIGGER_PKG ;

/
