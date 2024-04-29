--------------------------------------------------------
--  DDL for Package Body JAI_AP_IA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_IA_TRIGGER_PKG" AS
/* $Header: jai_ap_ia_t.plb 120.3.12010000.3 2008/10/14 13:00:02 bgowrava ship $ */

  /*
  REM +======================================================================+
  REM NAME          ARUID_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_IA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_IA_ARIUD_T2
  REM
  REM +======================================================================+
  */
  PROCEDURE ARUID_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: ja_in_ap_aia_after_trg.sql

CHANGE HISTORY:
S.No      Date          Author and Details

1.        22/11/2004    Aparajita, created  for bug # 3924692. Version # 115.0

                        This is the common after row level trigger for all events, that is
                        insert, update and delete.

                        Introduced the call to centralized packaged procedure,
                        jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

2.        08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                        DB Entity as required for CASE COMPLAINCE.  Version 116.1

3.      13-Jun-2005    File Version: 116.2
                       Ramananda for bug#4428980. Removal of SQL LITERALs is done

4.			01-FEB-2007			CSahoo for BUG#5631784, Version 120.1
												Forward Porting of ii1 BUG#4742259(TCS solution)
												When an invoice generated during the TCS settlement is paid we update
												the invoice_id column in the jai_rgm_settlements table with the
												corresponding invoice_id.
												Update of invoice_id in jai_rgm_settlements is made when payment_status_flag is
												Y. Previously it was checking if amount_paid is more than invoice_amount.
                        This would not work if there is any discount.
                        The if condition to update invoice_id in jai_rgm_settlements was modified from
												IF nvl(:new.payment_status_flag,'N') <> 'Y' AND nvl(:new.payment_status_flag,'N') = 'Y' to
                        IF nvl(:old.payment_status_flag,'N') <> 'Y' AND nvl(:new.payment_status_flag,'N') = 'Y'
5	29/03/2007	bduvarag for bug#5662741,File version 120.2
		       Forward porting the changes done in 11i bug#5638769

6   15-OCT-2007  Bug 6493858 File version 120.0.12000000.3
                 Removed changes done for bug 5662741 and moved the logic to jai_ap_ida_t.plb.


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

  --if
  --  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_AP_AIA_AFTER_TRG',
  --                               p_org_id           =>  pr_new.org_id,
  --                               p_set_of_books_id  =>  pr_new.set_of_books_id )
  --  =
  --  FALSE
  --then
    /* India Localization funtionality is not required */
  --  return;
  --end if;

  if pv_action = jai_constants.updating then

  -- Bug 7114863. Added by Lakshmi Gopalsami
  -- Removed the reference to jai_ap_tolerance_pkg.check_tolerance_hold

   /*BUG#5631784, Added by CSahoo*/
	 IF nvl(pr_old.payment_status_flag,'N') <> 'Y' AND nvl(pr_new.payment_status_flag,'N') = 'Y' AND pr_new.invoice_num like 'TCS%' THEN

			UPDATE jai_rgm_settlements
				 SET invoice_id            = pr_new.invoice_id,
						 last_updated_by       = fnd_global.user_id,
						 last_update_date      = sysdate
			 WHERE system_invoice_no     = pr_new.invoice_num
				 AND tax_authority_id      = pr_new.vendor_id
				 AND tax_authority_site_id = pr_new.vendor_site_id;

    END IF;/*5631784 end*/

  end if; /* updating */


exception
  when others then
    --raise_application_error(-20000, 'Error - trigger ja_in_ap_aia_after_trg on ap_invoices_all : ' || sqlerrm);
    /* Added an exception block by Ramananda for bug#4570303 */
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_AP_IA_TRIGGER_PKG.ARI_T7 '  ||
                          'Error on ap_invoices_all : ' || substr(sqlerrm,1,1800);

  END ARUID_T1 ;

  /*
  REM +======================================================================+
  REM NAME          BRIUD_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_AP_IA_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_AP_IA_BRIUD_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE BRIUD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    lb_result                         boolean;
  ln_req_id                         number;
  lv_process_flag                   varchar2(20);
  lv_process_message                varchar2(1100);
  ln_org_id                         ap_invoices_all.org_id%type;
  ln_set_of_books_id                ap_invoices_all.set_of_books_id%type;

  /*changes for bug 5662741 removed for bug 6493858/6411412*/

    /*START, Bgowrava for Bug#5638773 */
  CURSOR c_tds_invoice_id(cp_invoice_id	NUMBER)
  IS
  SELECT invoice_to_tds_authority_id invoice_id, invoice_to_tds_authority_num invoice_num
  FROM 		jai_ap_tds_thhold_trxs
  WHERE 	invoice_id = cp_invoice_id;

  r_tds_invoice_id	c_tds_invoice_id%ROWTYPE;
  lv_invoice_payment_status ap_invoices_all.payment_status_flag%TYPE;

	FUNCTION get_invoice_payment_status(p_invoice_id  IN  NUMBER)
	RETURN VARCHAR2
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;

		CURSOR c_payment_status(cp_invoice_id 	NUMBER)
		IS
		SELECT  payment_status_flag
		FROM    ap_invoices_all
		WHERE   invoice_id = cp_invoice_id;

		r_payment_status c_payment_status%ROWTYPE;
	BEGIN
		OPEN c_payment_status(p_invoice_id);
		FETCH c_payment_status INTO r_payment_status;
		CLOSE c_payment_status;

		RETURN r_payment_status.payment_status_flag;
	END get_invoice_payment_status;

	/*END, Bgowrava for Bug#5638773 */

  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
 FILENAME: jai_ap_ia_t.sql

CHANGE HISTORY:
S.No      Date         Author and Details

1.       25/03/2004    Aparajita. Bug # 4088186. TDS Clean up. Version#115.0

                       This is the only trigger introduced for all the before event
                       on the table on which this is based.

2.       14/04/2005    4284505     ssumaith - file version 115.1

                       Code added for service tax support for 3rd party taxes in a receipt.
                       In this trigger code has been added to populate the invoice id into
                       the jai_Rcv_tp_invoices table based on the invoice_num , vendor and
                       vendor site.


                       This patch creates dependency by addition of a new table - jai_rcv_tp_inv_Details
                       and addition of new column (invoice_id) in the table jai_Rcv_tp_invoices table.

                       A new procedure has been added to the package - jai_rcv_third_party_pkg which does
                       the actual invoice id update , and hence this package should go along with this trigger

2.      24/05/2005    Ramananda for bug# 4388958 File Version: 116.1
      Changed AP Lookup code from 'TDS' to 'INDIA TDS'
                        Changed AP Lookup code from 'RECEIPT' to 'INDIA TAX INVOICE'

3.      08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                      DB Entity as required for CASE COMPLAINCE.  Version 116.2

4. 13-Jun-2005    File Version: 116.3
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

5.       14/10/2008    Bgowrava for Bug#5638773, file version 120.0.12000000.7, 120.3.12010000.3
                                   Issue - Base AP invoice shouldn't be allowed to be cancelled, if the corresponding
                                               invoice to TDS Authority is already paid
                                   Fix -   1) Added a new cursor - c_tds_invoice_id, to get the tds_invoice_id
                                             2) Created an autonomous function to get the payment_status of an invoice
                                              3) Added the code to if check the tds_invoice is already paid, then stop the
                                                   cancelling of base invoice by using - raise_application_error

Dependency:
----------
Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1.      3924692    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, which was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0




------------------------------------------------------------------------------------------ */
 if pv_action = jai_constants.inserting or pv_action = jai_constants.updating then
  ln_org_id := pr_new.org_id;
  ln_set_of_books_id := pr_new.set_of_books_id;
 elsif pv_action = jai_constants.deleting then
  ln_org_id := pr_old.org_id;
  ln_set_of_books_id := pr_old.set_of_books_id;
 end if;

  --if
  --  jai_cmn_utils_pkg.check_jai_exists (p_calling_object   => 'JA_IN_AP_AIA_BEFORE_TRG',
  --                               p_org_id           =>  ln_org_id,
  --                               p_set_of_books_id  =>  ln_set_of_books_id )
  --  =
 --   FALSE
 -- then
    /* India Localization funtionality is not required */
 --   return;
--  end if;


  /*
  || Cancellation Functionality
  */
  if pv_action = jai_constants.updating then

    if pr_old.cancelled_date is null and pr_new.cancelled_date is not null then

      if pr_new.source <> 'INDIA TDS' then  /* 'TDS' then --Ramanand for bug#4388958 */

	  /*START, Bgowrava for Bug#5638773 */
	  OPEN c_tds_invoice_id(pr_old.invoice_id);
	  FETCH c_tds_invoice_id INTO r_tds_invoice_id;
	  CLOSE c_tds_invoice_id;

	  IF r_tds_invoice_id.invoice_id IS NOT NULL THEN
	  lv_invoice_payment_status := get_invoice_payment_status(r_tds_invoice_id.invoice_id);
		IF NVL(lv_invoice_payment_status,'N') <> 'N' THEN
		pv_return_code := jai_constants.expected_error ;
		pv_return_message := 'Invoice to TDS Authority - '||r_tds_invoice_id.invoice_num||' is already paid. Current invoice can''t be cancelled';
		END IF;
	  END IF;

	  /*END, Bgowrava for Bug#5638773 */

        /* TDs functionality on TDS invoice is not required. */

		/*changes for bug 5662741 removed for bug 6493858/6411412*/
		/*the logic is moved to jai_ap_ida_t.plb*/

        lb_result := fnd_request.set_mode(true);

        ln_req_id :=
        Fnd_Request.submit_request
        (
          'JA',
          'JAINAPIC',
          'Cancel TDS invoices',
          '',
          false,
          pr_new.invoice_id
        );

      end if; /* pr_new.source <> 'TDS' then  */

    end if;  /* if pr_old.cancelled_date is null and pr_new.cancelled_date is not null then */

  end if; /*  if pv_action = jai_constants.updating than  */

  /* Update invoice Ids in TDS tables for TDS invoices */
  if pv_action = jai_constants.inserting and pr_new.source = 'INDIA TDS' then  /* 'TDS' then --Ramanand for bug#4388958 */

    jai_ap_tds_generation_pkg.populate_tds_invoice_id
    (
      p_invoice_id            =>    pr_new.invoice_id,
      p_invoice_num           =>    pr_new.invoice_num,
      p_vendor_id             =>    pr_new.vendor_id,
      p_vendor_site_id        =>    pr_new.vendor_site_id,
      p_process_flag          =>    lv_process_flag,
      p_process_message       =>    lv_process_message
    );

    if   nvl(lv_process_flag, 'N') = 'E' then
/*       raise_application_error(-20001,
      'Error - trigger ja_in_ap_aida_before_trg on ja_in_ap_aia_before_trg : ' || lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=
      'Error - trigger ja_in_ap_aida_before_trg on ja_in_ap_aia_before_trg : ' || lv_process_message ; return ;
    end if;

  end if; /* Update invoice Ids in TDS tables for TDS invoices */

  /* Update invoice Ids in Third Party tables for Third Party invoices */
  if pv_action = jai_constants.inserting and pr_new.source = 'INDIA TAX INVOICE' then /* 'RECEIPT' then --Ramanand for bug#4388958 */

     jai_rcv_third_party_pkg.populate_tp_invoice_id
     (
       p_invoice_id           =>    pr_new.invoice_id,
       p_invoice_num          =>    pr_new.invoice_num,
       p_vendor_id            =>    pr_new.vendor_id,
       p_vendor_site_id       =>    pr_new.vendor_site_id,
       p_process_flag         =>    lv_process_flag,
       p_process_message      =>    lv_process_message
     );
    if   nvl(lv_process_flag, 'N') = jai_constants.unexpected_error then
/*          raise_application_error(-20002,
         'Error - trigger ja_in_ap_aida_before_trg on ja_in_ap_aia_before_trg : ' || lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=
         'Error - trigger ja_in_ap_aida_before_trg on ja_in_ap_aia_before_trg : ' || lv_process_message ; return ;
    end if;
  end if;

  /*
  || Update invoice Ids in Third Party tables for Third Party invoices
  */

  /* Deleting */
  if pv_action = jai_constants.deleting  then

    jai_ap_tds_tax_defaultation.process_delete
    (
      p_invoice_id                  =>  pr_old.invoice_id,
      p_process_flag                =>  lv_process_flag,
      P_process_message             =>  lv_process_message
    );

      if   nvl(lv_process_flag, 'N') = 'E' then
/*         raise_application_error(-20002,
        'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message); */ pv_return_code := jai_constants.expected_error ; pv_return_message :=
        'Error - trigger ja_in_ap_aida_before_trg on ap_invoice_distributions_all : ' || lv_process_message ; return ;
      end if;

  end if; /* Deleting */


exception
  when others then
    --raise_application_error(-20003, 'Error - trigger ja_in_ap_aia_before_trg on ap_invoices_all : ' || sqlerrm);
    /* Added an exception block by Ramananda for bug#4570303 */
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_AP_IA_TRIGGER_PKG.ARI_T7 '  ||
                            'Error on ap_invoices_all : ' || substr(sqlerrm,1,1800);

  END BRIUD_T1 ;

END JAI_AP_IA_TRIGGER_PKG ;

/
