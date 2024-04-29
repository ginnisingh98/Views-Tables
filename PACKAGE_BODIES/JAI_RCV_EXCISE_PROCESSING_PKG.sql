--------------------------------------------------------
--  DDL for Package Body JAI_RCV_EXCISE_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_EXCISE_PROCESSING_PKG" AS
/* $Header: jai_rcv_exc_prc.plb 120.22.12010000.12 2010/03/17 07:03:19 vkaranam ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_rcv_exc_prc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

13-Jun-2005  4428980     File Version: 116.3
                         Ramananda for bug#4428980. Removal of SQL LITERALs is done

27-Jul-2005  4516667     Added by Lakshmi Gopalsami Version 120.2
                         (1) Removed CVD from additional amount. This is
			     accidentally added to additional excise. This is
			     done in PROCEDURE rg23_d_entry.
                         (2) Rounded p_rate_per_unit to 4 decimal places in
 			     jai_cmn_rg_23d_trxs_pkg.insert_row

27-Jul-2005  4516678     Added by Lakshmi Gopalsami Version 120.3
                         Issue :
                          a.Whenever a user creates a receipt for a CGIN or
			    CGEX item, 50% cenvat is claimed. If he/she intends to
			    return the entire quantity in the receipt, he/she must
			    claim the remaining 50% cenvat first and then do the
			    RTV. Else, the system should throw an error.

                          b.After creating a receipt for a CGIN or CGEX item,
			    if the user does a partial RTV on that receipt,
			    the system should allow it although the remaining
			    50% CENVAT has not been claimed.

			 Fix   :
                          a. Added code to check this in Package jai_rcv_tax_pkg
			  (1) Created new procedure pick_register_type to get the
			  register_type depending on the item_class
			  (2)Created two new cursors  c_fetch_receive_quantity
			  and c_fetch_transaction_Quantity to get the
			  quantity received for the receipt and RTV transactions
			  (3) Added  nvl(cenvat_amount,0) in
			  cursor c_fetch_unclaim_cenvat

			  Dependencies(Functional)
			  ------------------------
			  jai_rcv_tax.plb Version 120.2

                          b. The cenvat receivable accounts were not getting passed
			     in case of a CGIN/CGEX item.
			     Thus, the system is throwing an error.
			     Commented the generic assignment for cenvat
			     accounting entries and added the condition for
			     CGIN and CGEX item class in procedure
			     accounting_entries.


02-May-06    5176133   Added by rallamse version 120.4
                       Issue : Object not getting compiled
                       Fix:
                       Modified the multi-line statement :
                       r_diff_tax.basic_excise  := r_rtv_dtls.excise_basis_amt
                       to a single line statement
17-Jul-2006  5378630 Aiyer, File Version 120.6
                      Issue:-
                        India Receiving transaction processor fails during validation phase for RMA
                        type of transactions.

                      Fix:-
                       During DFF elimination one elsif statment in the procedure validate_transaction got missed out
                       due to which for RMA TYPE of either "PRODUCTION INPUT" or "GOODS RETURN" the code used to fail.
                       To restrict this added back the if condition to check that the failure should happen only for PO receipt with FGIN or FGEX type
                       of item class. The new IF condition now checks for source_document_type in PO or REQUISITION
                       Also converted the reference of RMA TYPE "FG RETURN" into "GOODS RETURN" as FG return is not as per the abbreviation
                       standard

14-feb-2007  4704957,5841749  vkaranam,File version 120.11
                              4704957-Forward porting the changes in 11i bug 4683156(return to vendor report shows 50% cenvat amount for partial rtv)
                              5841749-Forward porting the changes in 11i bug 5647216(doing rtv for partial quantity, after claiming 50%, is giving error)


22-Feb-2007 5155138 srjayara, file version 120.12
			Forward port for 11i bug 5110511
			Issue: No accounting should be passed for Excise and Cess in case of RMA receipt for a Trading
			       organization.
			Fix: When call to accounting_entries is made for Trading organization a check is added so that
			     the call is made only if the attribute category is not India RMA Receipt.
16-APR-2007   Bug 5989740 Vkaranam for bug 5989740, File version 120.13
              Forward porting the changes in 115 bug 5907436(Enh:Handling Secondary And Higher Education Cess)


17 14-may-07   kunkumar made changes for Budget and ST by IO and Build issues resolved	.

04-Jun-2007  ssawant for bug#6084771,File Version 120.18
                Issue: UNABLE TO CLAIM CENVAT
                  Fix: Added reference_id while jai_rcv_accounting_pkg.process_transaction to avoid
                       the Duplicate accounting error.

08-Jun-2007  CSahoo for bug#6078460, File Version 120.20
						 Issue:Excise Expense entry is getting generated for Excise and Education cess but
									 not for the SHE cess. The accounting entrty needs to be generated for the
									 same.
						 Fix: Added code for SH Education Cess Acccounting Entries in the procedure rtv_processing_for_ssi.

9-Nov-2008  Bug 5752026 (FP for bug 5747435) File version 120.25
             Issue : Total duty amount includes addl. CVD for the invoices flown from receipts.
                     This is not consistent with what we have for manual entries.
             Fix   : Excluded the addl. CVD when calculating the total duty amount in procedure
                     rg23_d_entry.
23-jun-2009 vkaranam for bug#4767479
            forwardported the changes done in 115 bug#4751114
	    Issue:  India Rg23 Part II report also picks autoclaimed entry for RTV against same Receipt exise invoice no instead of showing as a
                  seperate record.
                Fix:
                  The issue was coming as the excise invoice no generated for autoclaimed entry for RTV was same as that of the receipt.
                  Changes are made in rg23_part_ii_entry procedure to append '/1' to the receipt's
                  excise invoice no and assign it to the excise invoice no of autoclaimed entry for RTV

14-aug-2009 vkaranam for bug#4750798
	    fwdported the changes done in 115 bug 4619176   /7229349
22-feb-2010  vkaranam for bug#9346733
             Issue:
             CENVAT CREDIT AMOUNT IS ROUNDING OFF TO THE NEAREST RUPEE WHILE DELIVERY OF MATErial
             to non bonded subinvetory
             fix details:
             commented the call to do_Canvat_rounding in process_transaction procedure.

17-mar-2010 vkaranam for bug#9478222
            issue:
            RMA CENVAT CLAIM CENVAT_RG_PKG.PROCESS_TRANSACTION->ORA-01722: INVALID NUMBER, S
            Fix:
            added to_char(p_transaction_id) in  CURSOR cur_rg1_register_id


--------------------------------------------------------------------------------------*/

  FUNCTION get_apportioned_tax(
    pr_tax      IN  TAX_BREAKUP,
    p_factor    IN  NUMBER,
    p_claim_type IN VARCHAR2     -- Date 30/10/2006 Bug 5228046 added by SACSETHI
  ) RETURN TAX_BREAKUP IS

    r_tax   TAX_BREAKUP;
    ln_factor     NUMBER;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_excise_processing_pkg.get_apportioned_tax';

  BEGIN

    if p_factor IS NULL  THEN   /*Commented the condition  or p_factor = 0  the changes for  bug # 8644480 */
      ln_factor := 1;
    else
      ln_factor := p_factor;
    end if;

    r_tax.basic_excise     := pr_tax.basic_excise     * ln_factor;
    r_tax.addl_excise      := pr_tax.addl_excise      * ln_factor;
    r_tax.other_excise     := pr_tax.other_excise     * ln_factor;
    r_tax.cvd              := pr_tax.cvd              * ln_factor;
    r_tax.non_cenvat       := pr_tax.non_cenvat       * ln_factor;
    r_tax.excise_edu_cess  := pr_tax.excise_edu_cess  * ln_factor;
    r_tax.cvd_edu_cess     := pr_tax.cvd_edu_cess     * ln_factor;
     /*added the following by vkaranam for budget 07 impact - bug#5989740*/
    --start
    r_tax.sh_exc_edu_cess  := pr_tax.sh_exc_edu_cess  * ln_factor;
    r_tax.sh_cvd_edu_cess  := pr_tax.sh_cvd_edu_cess  * ln_factor;
    --end


     -- Date 30/10/2006 Bug 5228046 added by sacsethi
    IF p_claim_type ='2ND CLAIM' THEN
       r_tax.addl_cvd       := 0;
    ELSE
       r_tax.addl_cvd       := pr_tax.addl_cvd;
    END IF;
    RETURN r_tax;

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END get_apportioned_tax;


  -- Start, following procedures added by Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
  PROCEDURE get_changed_vendor_dtls(
    p_receive_trx_id      IN  NUMBER,
    p_shipment_line_id    IN  NUMBER,
    p_vendor_id OUT NOCOPY NUMBER,
    p_vendor_site_id OUT NOCOPY NUMBER
  ) IS

    CURSOR c_receipt_cenvat_dtl(cp_transaction_id IN NUMBER) IS
      SELECT vendor_changed_flag, vendor_id, vendor_site_id
      FROM JAI_RCV_CENVAT_CLAIMS
      WHERE transaction_id = cp_transaction_id;

    r_receipt_cenvat_dtl  c_receipt_cenvat_dtl%ROWTYPE;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_excise_processing_pkg.get_changed_vendor_dtls';

  BEGIN

    OPEN c_receipt_cenvat_dtl(p_receive_trx_id);
    FETCH c_receipt_cenvat_dtl INTO r_receipt_cenvat_dtl;
    CLOSE c_receipt_cenvat_dtl;

    IF r_receipt_cenvat_dtl.vendor_changed_flag = 'Y' THEN
      p_vendor_id       := r_receipt_cenvat_dtl.vendor_id;
      p_vendor_site_id  := r_receipt_cenvat_dtl.vendor_site_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    p_vendor_id := null;
    p_vendor_site_id := null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END get_changed_vendor_dtls;

  /* Procedure Created by Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
     POST PROCESSOR of CENVAT */
  PROCEDURE post_cenvat_processor(
    p_transaction_id            IN  NUMBER,
    p_cenvat_claimed_ptg        IN  NUMBER,
    p_cenvat_claimed_amt        IN  NUMBER,
    p_other_cenvat_claimed_amt  IN  NUMBER
  ) IS

    r_trx                         c_trx%ROWTYPE;
    lv_transaction_type           JAI_RCV_TRANSACTIONS.transaction_type%TYPE;

     --start additions for bug#4750798

  CURSOR c_rtv_qty(cp_transaction_id  jai_rcv_transactions.transaction_id%TYPE)
  IS
  select quantity  from jai_rcv_transactions
  WHERE   transaction_id = cp_transaction_id;

 cursor c_fetch_base_correct_qty(p_transaction_id number) is
    select nvl(sum(quantity),0)
    from   rcv_transactions
    where  parent_transaction_id = p_transaction_id
  and    transaction_type='CORRECT';

  v_rtv_qty                     jai_rcv_transactions.quantity%TYPE;
  v_excise_rf                    NUMBER;
  v_excise_edu_cess_rf          NUMBER;
  v_excise_she_cess_rf          NUMBER;
  v_base_correct_quantity       NUMBER;
  v_changed_cenvat_quantity     NUMBER;


---end additions for bug#4750798


    ln_trx_qty_for_2nd_claim      NUMBER;
    ln_trx_equivalent_of_receive  NUMBER;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_excise_processing_pkg.post_cenvat_processor';




  BEGIN

    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    -- update the quantity for 2nd claim only during the first claim of transaction line and that too only for CG Items only
    IF p_cenvat_claimed_ptg = 50 AND r_trx.item_class IN ('CGIN','CGEX') THEN

      IF lv_transaction_type IN ('DELIVER','RETURN TO RECEIVING','RETURN TO VENDOR') THEN
        ln_trx_equivalent_of_receive := jai_rcv_trx_processing_pkg.get_equivalent_qty_of_receive(r_trx.transaction_id);
      ELSE
        ln_trx_equivalent_of_receive := r_trx.quantity;
      END IF;

      IF lv_transaction_type IN ('RECEIVE', 'MATCH')
        -- non bonded RTR case i.e goods are returned to receiving from non bonded subinventory
        or (lv_transaction_type = 'RETURN TO RECEIVING' and nvl(r_trx.loc_subinv_type, 'X') = 'N')
      THEN
        -- only during 1st Claim the quantity should be updated
        ln_trx_qty_for_2nd_claim  := ln_trx_equivalent_of_receive;

      ELSIF lv_transaction_type = 'RETURN TO VENDOR'
        -- non bonded delivery case. i.e goods are delivered to non bonded subinventory
        or (lv_transaction_type = 'DELIVER' and nvl(r_trx.loc_subinv_type, 'X') = 'N')
      THEN
        ln_trx_qty_for_2nd_claim  := -1 * ln_trx_equivalent_of_receive;

      ELSE
        ln_trx_qty_for_2nd_claim := 0;
      END IF;

    ELSE
    --start additions for bug#4750798
             IF lv_transaction_type = 'RETURN TO VENDOR'
        THEN
            OPEN c_rtv_qty(r_trx.transaction_id);
            FETCH c_rtv_qty INTO v_rtv_qty;
            CLOSE c_rtv_qty;
            ln_trx_qty_for_2nd_claim  := -1*v_rtv_qty;
        ELSE
             ln_trx_qty_for_2nd_claim := 0;
        END IF;
	 --end additions for bug#4750798

    END IF;

    /* Start, Vijay Shankar for Bug#3940588 */
    IF r_trx.transaction_type IN ('RECEIVE', 'MATCH') THEN
      UPDATE JAI_RCV_CENVAT_CLAIMS
      SET cenvat_claimed_ptg = p_cenvat_claimed_ptg,
          cenvat_sequence = nvl(cenvat_sequence, 0) + 1,
          cenvat_claimed_amt = nvl(cenvat_claimed_amt, 0) + p_cenvat_claimed_amt,
          other_cenvat_claimed_amt = nvl(other_cenvat_claimed_amt,0) + p_other_cenvat_claimed_amt,
          quantity_for_2nd_claim = nvl(quantity_for_2nd_claim,0) + nvl(ln_trx_qty_for_2nd_claim, 0),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE transaction_id = p_transaction_id;

      -- this is to set the flag that is shown in JAINPORE, which signifies that the cenvat is claimed or not
      update JAI_RCV_LINES
      set claim_modvat_flag = 'Y',
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      where transaction_id = p_transaction_id;

    ELSE

      UPDATE JAI_RCV_CENVAT_CLAIMS
      SET quantity_for_2nd_claim = nvl(quantity_for_2nd_claim,0) + ln_trx_qty_for_2nd_claim,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE transaction_id = r_trx.tax_transaction_id;

    END IF;
    /* End, Vijay Shankar for Bug#3940588 */


      --start additions for bug#4750798
                get_excise_tax_rounding_factor(
                   p_transaction_id => r_trx.tax_transaction_id,
                   p_Excise_rf => v_excise_rf,
                   p_Excise_edu_cess_rf => v_excise_edu_cess_rf,
                   p_Excise_she_cess_rf => v_excise_she_cess_rf
                );

  FND_FILE.put_line(FND_FILE.log, '^CENVAT_RG_PKG.post_cenvat_processor. v_excise_rf->'||v_excise_rf||'-v_excise_edu_cess_rf->'||v_excise_edu_cess_rf||'-v_excise_she_cess_rf->'||v_excise_she_cess_rf);

   IF r_trx.transaction_type = 'RECEIVE' THEN
   UPDATE  JAI_RCV_CENVAT_CLAIMS
           SET   cenvat_amt_for_2nd_claim = ROUND((NVL(cenvat_amount,0))-(NVL(cenvat_claimed_amt,0)),v_excise_rf),
           other_cenvat_amt_for_2nd_claim = ROUND((NVL(other_cenvat_amt,0))-(NVL(other_cenvat_claimed_amt,0)),v_excise_edu_cess_rf) ,
         last_update_date  = sysdate,
           last_updated_by   = fnd_global.user_id,
           last_update_login = fnd_global.login_id
           WHERE   transaction_id = r_trx.tax_transaction_id;
  ELSE

                ln_trx_equivalent_of_receive := jai_rcv_trx_processing_pkg .get_equivalent_qty_of_receive(r_trx.tax_transaction_id);

                open  c_fetch_base_correct_qty(r_trx.tax_transaction_id);
                 fetch c_fetch_base_correct_qty into v_base_correct_quantity;
                close c_fetch_base_correct_qty;

                        v_changed_cenvat_quantity := nvl(v_base_correct_quantity,0) + ln_trx_equivalent_of_receive;

                FND_FILE.put_line(FND_FILE.log, '^CENVAT_RG_PKG.post_cenvat_processor.ln_trx_equivalent_of_receive->'||ln_trx_equivalent_of_receive);
                FND_FILE.put_line(FND_FILE.log, '^CENVAT_RG_PKG.post_cenvat_processor.v_changed_cenvat_quantity->'||v_changed_cenvat_quantity);

                UPDATE JAI_RCV_CENVAT_CLAIMS
                SET cenvat_amt_for_2nd_claim = ROUND(nvl(v_changed_cenvat_quantity,   0) *nvl(cenvat_amount,   0) / nvl(ln_trx_equivalent_of_receive,   0),   v_excise_rf) -cenvat_claimed_amt,
                  other_cenvat_amt_for_2nd_claim = ROUND(nvl(v_changed_cenvat_quantity,   0) *nvl(other_cenvat_amt,   0) / nvl(ln_trx_equivalent_of_receive,   0),   v_excise_edu_cess_rf) -other_cenvat_claimed_amt,
                  last_update_date = sysdate,
                  last_updated_by = fnd_global.user_id,
                  last_update_login = fnd_global.login_id
                WHERE transaction_id = r_trx.tax_transaction_id;

  END IF;
--end additions for bug#4750798

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END post_cenvat_processor;

  /* Start of bug 5365346. Created by Lakshmi Gopalsami */
  PROCEDURE  update_RTV_Diff_value
            (pr_base_trx            IN jai_rcv_excise_processing_pkg.c_base_trx%ROWTYPE,
	     pr_tax                 IN jai_rcv_excise_processing_pkg.c_trx%ROWTYPE,
  	     pr_diff_tax            IN TAX_BREAKUP,
	     p_source_reg           IN VARCHAR2 ,
	     p_register_entry_type  IN VARCHAR2 ,
             p_register_id          IN OUT NOCOPY NUMBER,
	     p_simulate_flag        IN  VARCHAR2,
	     p_codepath             IN OUT NOCOPY VARCHAR2,
	     p_process_status       OUT NOCOPY VARCHAR2,
	     p_process_message      OUT NOCOPY VARCHAR2
	    ) IS

    ln_tr_amount       NUMBER ;
    ln_opening_balance NUMBER ;
    ln_closing_balance NUMBER ;
    ln_dr_basic        NUMBER ;
    ln_dr_addl         NUMBER ;
    ln_dr_other        NUMBER ;
    ln_other_tax_debit NUMBER ;
    ln_cr_basic        NUMBER ;
    ln_cr_addl         NUMBER ;
    ln_cr_other        NUMBER ;
    ln_other_tax_credit  NUMBER ;
    ln_transaction_id   NUMBER(10);
    lv_transaction_type VARCHAR2(50);
    ln_register_id      NUMBER ;
    lv_remarks          JAI_CMN_RG_PLA_TRXS.REMARKS%TYPE;
    lv_statement_id     VARCHAR2(5);
    lv_process_status   VARCHAR2(2);
    lv_process_message  VARCHAR2(2000);
    lv_register_type    JAI_CMN_RG_23AC_II_TRXS.register_type%TYPE;
    ln_reg_dr           NUMBER ;
    ln_reg_cr           NUMBER ;
    lv_upd_opening_bal_dr NUMBER ;
    lv_upd_opening_bal_cr NUMBER ;
    ln_ex_cess_diff     NUMBER ;
    ln_cvd_cess_diff    NUMBER ;
    ln_ex_sh_cess_diff     NUMBER ;
    ln_cvd_sh_cess_diff    NUMBER ;


  BEGIN

   p_codepath := jai_general_pkg.plot_codepath(1, p_codepath,
   'jai_rcv_excise_processing_pkg.update_RTV_Diff_value', 'START');


   lv_statement_id := '1';
   p_codepath := jai_general_pkg.plot_codepath(1, p_codepath);

   fnd_file.put_line(FND_FILE.LOG, ' Inside Update RTV Diff value ->statement id '
                                    || lv_statement_id);
   fnd_file.put_line(FND_FILE.LOG, ' source register ' || p_source_reg);
   /* If source register is PLA */
   IF p_source_reg = 'PLA' THEN
      IF pr_tax.transaction_type = 'CORRECT' THEN
        lv_transaction_type := pr_tax.parent_transaction_type;
      ELSE
        lv_transaction_type := pr_tax.transaction_type;
      END IF;
      lv_statement_id := '2';
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
      jai_cmn_rg_pla_trxs_pkg.get_trxn_type_and_id(lv_transaction_type,
                           pr_base_trx.source_document_code,
			   ln_transaction_id);
      lv_statement_id := '3';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath);
      FOR c_get_register_id IN
           (SELECT register_id ,
	           cr_basic_ed,
		   cr_additional_ed,
		   cr_other_ed,
		   dr_basic_ed,
		   dr_additional_ed,
		   dr_other_ed,
		   other_tax_credit,
		   other_tax_debit,
		   remarks
            FROM jai_cmn_rg_pla_trxs
	    WHERE organization_id = pr_tax.organization_id
	      AND location_id = pr_tax.location_id
	      AND inventory_item_id = pr_tax.inventory_item_id
	      AND ref_document_id = pr_tax.transaction_id
	      AND transaction_source_num = ln_transaction_id
	    )
      LOOP
        lv_statement_id := '4';
	p_codepath := jai_general_pkg.plot_codepath(4, p_codepath);
        fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
        ln_register_id := c_get_register_id.register_id;
	ln_dr_basic    := c_get_register_id.dr_basic_ed;
	ln_dr_addl     := c_get_register_id.dr_additional_ed;
	ln_dr_other    := c_get_register_id.dr_other_ed;
	ln_other_tax_debit := c_get_register_id.other_tax_debit;
	ln_cr_basic    := c_get_register_id.cr_basic_ed;
	ln_cr_addl     := c_get_register_id.cr_additional_ed;
	ln_cr_other    := c_get_register_id.cr_other_ed;
	ln_other_tax_credit := c_get_register_id.other_tax_credit;
	lv_remarks     := c_get_register_id.remarks || 'RTV ADjustment';
	fnd_file.put_line(FND_FILE.LOG, ' RTV Adjustment values --> ');
	fnd_file.put_line(FND_FILE.LOG, ' Register id ' || ln_register_id);
	fnd_file.put_line(FND_FILE.LOG, 'CR: Basic--Addl--Other--cess'||
                         ln_cr_basic||'--'||ln_cr_addl||'--'||
			 ln_cr_other||'--'||ln_other_tax_credit);
	fnd_file.put_line(FND_FILE.LOG, 'DR: Basic--Addl--Other--cess'||
                         ln_dr_basic||'--'||ln_dr_addl||'--'||
			 ln_dr_other||'--'||ln_other_tax_debit);
      END LOOP ;

      lv_statement_id := '5';
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);

      lv_statement_id := '6';
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);

      lv_statement_id := '7';
      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
      /* Set the value of credit and debit basic, additional and other */

      IF p_register_entry_type = CENVAT_DEBIT THEN
         lv_statement_id := '8';
	 p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
         lv_upd_opening_bal_dr := ln_dr_basic + ln_dr_addl + ln_dr_other;
         ln_dr_basic   := ln_dr_basic+ pr_diff_tax.basic_excise;
         ln_dr_addl    := ln_dr_addl + pr_diff_tax.addl_excise + pr_diff_tax.cvd;
         ln_dr_other   := ln_dr_other + pr_diff_tax.other_excise;
         ln_other_tax_debit  := ln_other_tax_debit +
	                        pr_diff_tax.excise_edu_cess +
				pr_diff_tax.cvd_edu_cess + nvl(pr_diff_tax.sh_exc_edu_cess,0) +
				 nvl(pr_diff_tax.sh_cvd_edu_cess,0); --Bgowrava for Bug#6071509, added SH related cess
	 ln_reg_dr     := nvl(pr_diff_tax.basic_excise,0) +
                          nvl(pr_diff_tax.addl_excise,0)+ nvl(pr_diff_tax.cvd,0) +
			  nvl(pr_diff_tax.other_excise,0);
         fnd_file.put_line(FND_FILE.LOG, ' Reg. dr' || ln_reg_dr);
      ELSE
         lv_statement_id := '10';
         lv_upd_opening_bal_cr := ln_cr_basic + ln_cr_addl + ln_cr_other;
         fnd_file.put_line(FND_FILE.LOG, ' Reg. open cr' || lv_upd_opening_bal_cr);
         ln_cr_basic   := ln_cr_basic + pr_diff_tax.basic_excise;
         ln_cr_addl    := ln_cr_addl + pr_diff_tax.addl_excise + pr_diff_tax.cvd;
         ln_cr_other   := ln_cr_other + pr_diff_tax.other_excise;
         ln_other_tax_credit  := ln_other_tax_credit +
	                         pr_diff_tax.excise_edu_cess +
				 pr_diff_tax.cvd_edu_cess + nvl(pr_diff_tax.sh_exc_edu_cess,0) +
				 nvl(pr_diff_tax.sh_cvd_edu_cess,0); --Bgowrava for Bug#6071509, added SH related cess
	 ln_reg_cr     := nvl(pr_diff_tax.basic_excise,0) +
                          nvl(pr_diff_tax.addl_excise,0)+ nvl(pr_diff_tax.cvd,0) +
			  nvl(pr_diff_tax.other_excise,0);
         fnd_file.put_line(FND_FILE.LOG, ' Reg. cr' || ln_reg_cr);
      END IF;

      /* Calculate the transaction amount difference to be updated */

      ln_tr_amount :=  nvl(ln_reg_cr,0) - nvl(ln_reg_dr,0);

      fnd_file.put_line(FND_FILE.LOG, ' Trx amt ' || ln_tr_amount);

            /*  Get the balance details */
      jai_cmn_rg_balances_pkg.get_balance(
         P_ORGANIZATION_ID   => pr_tax.organization_id,
         P_LOCATION_ID       => pr_tax.location_id,
         P_REGISTER_TYPE     => 'PLA',
         P_OPENING_BALANCE   => ln_opening_balance,
         P_PROCESS_STATUS    => lv_process_status,
         P_PROCESS_MESSAGE   => lv_process_message
       );
      lv_statement_id := '9';
      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
      ln_closing_balance := ln_opening_balance + ln_tr_amount;
      ln_opening_balance := ln_opening_balance - (nvl(lv_upd_opening_bal_cr,0) - nvl(lv_upd_opening_bal_dr,0));

      fnd_file.put_line(FND_FILE.LOG, 'Opening balance to be updated ' || ln_opening_balance);

      lv_statement_id := '10';
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);

      /* Update PLA with the latest difference amount to the existing amount */
      JAI_CMN_RG_PLA_TRXS_PKG.update_row(
         P_REGISTER_ID         => ln_register_id,
	 P_CR_BASIC_ED         => ln_cr_basic,
	 P_CR_ADDITIONAL_ED    => ln_cr_addl,
	 P_CR_OTHER_ED         => ln_cr_other,
	 P_DR_BASIC_ED         => ln_dr_basic,
	 P_DR_ADDITIONAL_ED    => ln_dr_addl,
	 P_DR_OTHER_ED         => ln_dr_other,
	 P_REMARKS             => lv_remarks,
	 P_OPENING_BALANCE     => ln_opening_balance,
	 P_CLOSING_BALANCE     => ln_closing_balance,
	 P_OTHER_TAX_CREDIT    => ln_other_tax_credit,
	 P_OTHER_TAX_DEBIT     => ln_other_tax_debit
         );
      lv_statement_id := '11';
      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
      /* Update the balances with the latest amount*/

      jai_cmn_rg_balances_pkg.update_row(
        p_organization_id   => pr_tax.organization_id,
        p_location_id       => pr_tax.location_id,
        p_register_type     => 'PLA',
	p_amount_to_be_added=> ln_tr_amount,
	p_simulate_flag     => p_simulate_flag,
	p_process_status    => lv_process_status,
	p_process_message   => lv_process_message
     );
     p_register_id := ln_register_id;
   /* If source register is RG23 part II */
   ELSE
      lv_register_type := jai_general_pkg.get_rg_register_type(pr_tax.item_class);
      IF pr_tax.transaction_type = 'CORRECT' THEN
        lv_transaction_type := pr_tax.parent_transaction_type;
      ELSE
        lv_transaction_type := pr_tax.transaction_type;
      END IF;
      lv_statement_id := '2';
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
      jai_cmn_rg_23ac_ii_pkg.get_trxn_type_and_id(lv_transaction_type,
                           pr_base_trx.source_document_code,
			   ln_transaction_id);
      lv_statement_id := '3';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath);
      FOR c_get_register_id IN
           (SELECT register_id ,
	           cr_basic_ed,
		   cr_additional_ed,
		   cr_other_ed,
		   dr_basic_ed,
		   dr_additional_ed,
		   dr_other_ed,
		   other_tax_credit,
		   other_tax_debit,
		   remarks
            FROM JAI_CMN_RG_23AC_II_TRXS
	    WHERE organization_id = pr_tax.organization_id
	      AND location_id = pr_tax.location_id
	      AND inventory_item_id = pr_tax.inventory_item_id
	      AND receipt_ref = pr_tax.transaction_id
	      AND transaction_source_num = ln_transaction_id
	    )
      LOOP
        lv_statement_id := '4';
        fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
        ln_register_id := c_get_register_id.register_id;
	ln_dr_basic    := c_get_register_id.dr_basic_ed;
	ln_dr_addl     := c_get_register_id.dr_additional_ed;
	ln_dr_other    := c_get_register_id.dr_other_ed;
	ln_other_tax_debit := c_get_register_id.other_tax_debit;
	ln_cr_basic    := c_get_register_id.cr_basic_ed;
	ln_cr_addl     := c_get_register_id.cr_additional_ed;
	ln_cr_other    := c_get_register_id.cr_other_ed;
	ln_other_tax_credit := c_get_register_id.other_tax_credit;
	lv_remarks     := c_get_register_id.remarks || 'RTV ADjustment';
	fnd_file.put_line(FND_FILE.LOG, ' RTV Adjustment values --> ');
	fnd_file.put_line(FND_FILE.LOG, ' Register id ' || ln_register_id);
	fnd_file.put_line(FND_FILE.LOG, 'CR: Basic--Addl--Other--cess'||
                         ln_cr_basic||'--'||ln_cr_addl||'--'||
			 ln_cr_other||'--'||ln_other_tax_credit);
	fnd_file.put_line(FND_FILE.LOG, 'DR: Basic--Addl--Other--cess'||
                         ln_dr_basic||'--'||ln_dr_addl||'--'||
			 ln_dr_other||'--'||ln_other_tax_debit);
      END LOOP ;

      lv_statement_id := '5';
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);


      lv_statement_id := '6';
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
      /* Set the value of credit and debit basic, additional and other */
      IF p_register_entry_type = CENVAT_DEBIT THEN
         lv_statement_id := '7';
         lv_upd_opening_bal_dr := ln_dr_basic + ln_dr_addl + ln_dr_other;
         ln_dr_basic   := ln_dr_basic+ pr_diff_tax.basic_excise;
         ln_dr_addl    := ln_dr_addl + pr_diff_tax.addl_excise + pr_diff_tax.cvd;
         ln_dr_other   := ln_dr_other + pr_diff_tax.other_excise;
         ln_other_tax_debit  := ln_other_tax_debit +
	                        pr_diff_tax.excise_edu_cess +
				pr_diff_tax.cvd_edu_cess + nvl(pr_diff_tax.sh_exc_edu_cess,0) +
				 nvl(pr_diff_tax.sh_cvd_edu_cess,0); --Bgowrava for Bug#6071509, added SH related cess
	 ln_reg_dr     := nvl(pr_diff_tax.basic_excise,0) +
                          nvl(pr_diff_tax.addl_excise,0)+ nvl(pr_diff_tax.cvd,0) +
			  nvl(pr_diff_tax.other_excise,0);
      ELSE
         lv_statement_id := '8';
	 p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
	 lv_upd_opening_bal_cr := ln_cr_basic + ln_cr_addl + ln_cr_other;
         ln_cr_basic   := ln_cr_basic + pr_diff_tax.basic_excise;
         ln_cr_addl    := ln_cr_addl + pr_diff_tax.addl_excise + pr_diff_tax.cvd;
         ln_cr_other   := ln_cr_other + pr_diff_tax.other_excise;
         ln_other_tax_credit  := ln_other_tax_credit +
	                         pr_diff_tax.excise_edu_cess +
				 pr_diff_tax.cvd_edu_cess+ nvl(pr_diff_tax.sh_exc_edu_cess,0) +
				 nvl(pr_diff_tax.sh_cvd_edu_cess,0); --Bgowrava for Bug#6071509, added SH related cess
	 ln_reg_cr     := nvl(pr_diff_tax.basic_excise,0) +
                          nvl(pr_diff_tax.addl_excise,0)+ nvl(pr_diff_tax.cvd,0) +
			  nvl(pr_diff_tax.other_excise,0);
      END IF;

       /* Calculate the transaction amount difference to be updated */

      ln_tr_amount :=  nvl(ln_reg_cr,0) - nvl(ln_reg_dr,0);

      lv_statement_id := '9';
      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);

      /*  Get the balance details */
      jai_cmn_rg_balances_pkg.get_balance(
         P_ORGANIZATION_ID   => pr_tax.organization_id,
         P_LOCATION_ID       => pr_tax.location_id,
         P_REGISTER_TYPE     => lv_register_type,
         P_OPENING_BALANCE   => ln_opening_balance,
         P_PROCESS_STATUS    => lv_process_status,
         P_PROCESS_MESSAGE   => lv_process_message
       );
      lv_statement_id := '10';
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
      ln_closing_balance := ln_opening_balance + ln_tr_amount;
      ln_opening_balance := ln_opening_balance - (nvl(lv_upd_opening_bal_cr,0) - nvl(lv_upd_opening_bal_dr,0));
      fnd_file.put_line(FND_FILE.LOG, 'Opening balance to be updated ' || ln_opening_balance);

      lv_statement_id := '11';
      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);

      /* Update RG 23 Part II with the latest difference amount to the existing amount */
      jai_cmn_rg_23ac_ii_pkg.update_row(
         P_REGISTER_ID         => ln_register_id,
	 P_CR_BASIC_ED         => ln_cr_basic,
	 P_CR_ADDITIONAL_ED    => ln_cr_addl,
	 P_CR_OTHER_ED         => ln_cr_other,
	 P_DR_BASIC_ED         => ln_dr_basic,
	 P_DR_ADDITIONAL_ED    => ln_dr_addl,
	 P_DR_OTHER_ED         => ln_dr_other,
	 P_REMARKS             => lv_remarks,
	 P_OPENING_BALANCE     => ln_opening_balance,
	 P_CLOSING_BALANCE     => ln_closing_balance,
	 P_OTHER_TAX_CREDIT    => ln_other_tax_credit,
	 P_OTHER_TAX_DEBIT     => ln_other_tax_debit,
	 p_simulate_flag     => p_simulate_flag,
	 p_process_status    => lv_process_status,
	 p_process_message   => lv_process_message
         );
      lv_statement_id := '12';
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath);
      fnd_file.put_line(FND_FILE.LOG, ' Value of statement id ' || lv_statement_id);
      /* Update the balances with the latest amount*/

      jai_cmn_rg_balances_pkg.update_row(
        p_organization_id   => pr_tax.organization_id,
        p_location_id       => pr_tax.location_id,
        p_register_type     => lv_register_type,
	p_amount_to_be_added=> ln_tr_amount,
	p_simulate_flag     => p_simulate_flag,
	p_process_status    => lv_process_status,
	p_process_message   => lv_process_message
     );
     p_register_id := ln_register_id;
   END IF ;

   /* Update CESS balances */
   IF pr_diff_tax.excise_edu_cess <> 0 THEN
      IF p_register_entry_type = CENVAT_DEBIT THEN
        ln_other_tax_debit  := pr_diff_tax.excise_edu_cess;
      ELSE
        ln_other_tax_credit := pr_diff_tax.excise_edu_cess;
      END IF;

      ln_ex_cess_diff := nvl(ln_other_tax_credit,0) -
                         nvl(ln_other_tax_debit,0);

      UPDATE  JAI_CMN_RG_OTHERS
         SET  credit = credit + ln_other_tax_credit,
              debit  = debit + ln_other_tax_debit,
  	      opening_balance = opening_balance,
	      closing_balance = closing_balance + ln_ex_cess_diff
       WHERE  source_register = decode(p_source_reg,'PLA', jai_constants.reg_pla,
                                  decode(lv_register_type,
				         jai_constants.register_type_a,
					 jai_constants.reg_rg23a_2,
					 jai_constants.reg_rg23c_2
					)
				   )
        AND  source_register_id = p_register_id
        AND  tax_type = jai_constants.tax_type_exc_edu_cess;
   END IF; /* Excise cess*/

   p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);

   IF pr_diff_tax.cvd_edu_cess <> 0 THEN
     IF p_register_entry_type = CENVAT_DEBIT THEN
        ln_other_tax_debit  := pr_diff_tax.cvd_edu_cess;
     ELSE
        ln_other_tax_credit := pr_diff_tax.cvd_edu_cess;
     END IF;

     ln_cvd_cess_diff := nvl(ln_other_tax_credit,0) -
                        nvl(ln_other_tax_debit,0);

     UPDATE  JAI_CMN_RG_OTHERS
        SET  credit = credit + ln_other_tax_credit,
             debit  = debit + ln_other_tax_debit,
	     opening_balance = opening_balance,
	     closing_balance = closing_balance + ln_cvd_cess_diff
      WHERE  source_register = decode(p_source_reg,'PLA', jai_constants.reg_pla,
                                  decode(lv_register_type,
				         jai_constants.register_type_a,
					 jai_constants.reg_rg23a_2,
					 jai_constants.reg_rg23c_2
					)
				   )
        AND  source_register_id = p_register_id
        AND  tax_type = jai_constants.tax_type_cvd_edu_cess;
    END IF; /* CVD Cess */

    --For Excise SH Edu cess
    IF pr_diff_tax.sh_exc_edu_cess <> 0 THEN
		      IF p_register_entry_type = CENVAT_DEBIT THEN
		        ln_other_tax_debit  := pr_diff_tax.sh_exc_edu_cess;
		      ELSE
		        ln_other_tax_credit := pr_diff_tax.sh_exc_edu_cess;
		      END IF;

		      ln_ex_sh_cess_diff := nvl(ln_other_tax_credit,0) -
		                         nvl(ln_other_tax_debit,0);

		      UPDATE  JAI_CMN_RG_OTHERS
		         SET  credit = credit + ln_other_tax_credit,
		              debit  = debit + ln_other_tax_debit,
		  	      opening_balance = opening_balance,
			      closing_balance = closing_balance + ln_ex_sh_cess_diff
		       WHERE  source_register = decode(p_source_reg,'PLA', jai_constants.reg_pla,
		                                  decode(lv_register_type,
						         jai_constants.register_type_a,
							 jai_constants.reg_rg23a_2,
							 jai_constants.reg_rg23c_2
							)
						   )
		        AND  source_register_id = p_register_id
		        AND  tax_type = jai_constants.tax_type_sh_exc_edu_cess;
   END IF; /* Excise SH cess*/

   --For CVD SH cess
   IF pr_diff_tax.sh_cvd_edu_cess <> 0 THEN
	      IF p_register_entry_type = CENVAT_DEBIT THEN
	         ln_other_tax_debit  := pr_diff_tax.sh_cvd_edu_cess;
	      ELSE
	         ln_other_tax_credit := pr_diff_tax.sh_cvd_edu_cess;
	      END IF;

	      ln_cvd_sh_cess_diff := nvl(ln_other_tax_credit,0) -
	                         nvl(ln_other_tax_debit,0);

	      UPDATE  JAI_CMN_RG_OTHERS
	         SET  credit = credit + ln_other_tax_credit,
	              debit  = debit + ln_other_tax_debit,
	 	     opening_balance = opening_balance,
	 	     closing_balance = closing_balance + ln_cvd_sh_cess_diff
	       WHERE  source_register = decode(p_source_reg,'PLA', jai_constants.reg_pla,
	                                   decode(lv_register_type,
	 				         jai_constants.register_type_a,
	 					 jai_constants.reg_rg23a_2,
	 					 jai_constants.reg_rg23c_2
	 					)
	 				   )
	         AND  source_register_id = p_register_id
	         AND  tax_type = jai_constants.tax_type_sh_cvd_edu_cess;
    END IF; /* CVD SH Cess */

  EXCEPTION
    WHEN OTHERS THEN
      lv_process_status := 'E';
      lv_process_message := 'EXC_PRC_PKG.update_RTV_Diff_value'||SQLERRM
                            ||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||lv_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');
  END update_RTV_Diff_value;

  -- End for bug 5365346

  PROCEDURE do_cenvat_rounding(
    p_transaction_id  IN NUMBER,
    pr_tax            IN OUT NOCOPY TAX_BREAKUP,
    p_codepath        IN OUT NOCOPY VARCHAR2
  ) IS

    ln_total_cenvat         NUMBER;
    ln_total_cenvat_rounded NUMBER;
    ln_rounded_amt          NUMBER;

    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_excise_processing_pkg.do_cenvat_rounding';
  BEGIN

    FND_FILE.put_line(FND_FILE.log, '^CENVAT_RG_PKG.do_cenvat_rounding. Basic->'||pr_tax.basic_excise
      ||', Additional->'||pr_tax.addl_excise
      ||', Other->'|| pr_tax.other_excise||', CVD->'|| pr_tax.cvd
    ||', Add CVD -> '|| pr_tax.addl_CVD
    -- Date 30/10/2006 Bug 5228046 added by sacsethi
    );

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg_pkg.do_cenvat_rounding', 'START');

    ln_total_cenvat         := pr_tax.basic_excise +
                               pr_tax.addl_excise +
			       pr_tax.other_excise +
			       pr_tax.cvd +
  			       pr_tax.addl_cvd ; -- Date 30/10/2006 Bug 5228046 added by sacsethi


    ln_total_cenvat_rounded := round(ln_total_cenvat, gn_cenvat_rnd);
    ln_rounded_amt          := ln_total_cenvat - ln_total_cenvat_rounded;

    IF ln_rounded_amt <> 0 THEN

      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath);

      IF pr_tax.cvd <> 0 THEN
         pr_tax.cvd :=  pr_tax.cvd - ln_rounded_amt;
      ELSIF pr_tax.other_excise <> 0 THEN
         pr_tax.other_excise :=  pr_tax.other_excise - ln_rounded_amt;
      ELSIF pr_tax.addl_excise <> 0 THEN
        pr_tax.addl_excise := pr_tax.addl_excise - ln_rounded_amt;
      -- Date 30/10/2006 Bug 5228046 added by sacsethi
      -- START BUG 5228046
      ELSIF pr_tax.addl_cvd <> 0 THEN
        pr_tax.addl_cvd := pr_tax.addl_cvd - ln_rounded_amt;
      -- END BUG 5228046
      ELSE
        pr_tax.basic_excise := pr_tax.basic_excise - ln_rounded_amt;
      END IF;

      FND_FILE.put_line(FND_FILE.log, 'Rounded Amts. Basic->'||pr_tax.basic_excise||
                                      ',Additional->'||pr_tax.addl_excise||
				      ', Other->'|| pr_tax.other_excise||
				      ', CVD->'|| pr_tax.cvd ||
				    ', Addl CVD-> ' || pr_tax.addl_cvd     -- Date 30/10/2006 Bug 5228046 added by sacsethi
      );

    END IF;

    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath, null, 'END');
  EXCEPTION
    WHEN OTHERS THEN
    pr_tax := null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END do_cenvat_rounding;

  PROCEDURE process_transaction(
    p_transaction_id            IN        NUMBER,
    p_cenvat_claimed_ptg        IN OUT NOCOPY VARCHAR2,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2,
    -- following parameters introduced for second claim of receive transaction
    -- Vijay shankar for Bug#3940588. RECEIPTS DEPLUG
    p_process_special_reason    IN        VARCHAR2    DEFAULT NULL,
    p_process_special_qty       IN        NUMBER      DEFAULT NULL
  ) IS

    lv_procedure_name             VARCHAR2(60); --File.Sql.35 Cbabu  := 'CENVAT_RG_PKG.process_transaction';

    r_trx                         c_trx%ROWTYPE;
    r_base_trx                    c_base_trx%ROWTYPE;
    r_orgn_info                   c_orgn_info%ROWTYPE;
    lv_transaction_type           RCV_TRANSACTIONS.transaction_type%TYPE;
    ln_trx_type_code              NUMBER(5);

    -- For RTV case
    ln_receive_trx_id             JAI_RCV_TRANSACTIONS.transaction_type%TYPE;
    ln_receive_basic              NUMBER;
    ln_receive_addl               NUMBER;
    ln_receive_other              NUMBER;
    ln_receive_cvd                NUMBER;
    ln_receipt_addl_cvd           NUMBER;     -- Date 30/10/2006 Bug 5228046 added by sacsethi
    ln_receive_non_cenvat         NUMBER;
    lv_receive_part_ii_type       VARCHAR2(10);
    ln_receive_part_ii_reg_id     NUMBER;
    ln_receive_charge_accnt       NUMBER;

    lv_cenvat_accounting_type     VARCHAR2(10);
    lv_register_entry_type        VARCHAR2(10);
    lv_cgin_code                  VARCHAR2(100);

    lv_reference_num              JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE;

    -- amount related variables
    ln_curr_conv_rate             NUMBER;
    ln_excise_amount              NUMBER;

    /* Vijay Shankar for Bug#3940588 */
    r_half_tax                    TAX_BREAKUP;/*uncommented by vkaranam for bug 4704957*/
    r_tax                         TAX_BREAKUP;


    ln_amount_factor              NUMBER;   --File.Sql.35 Cbabu  := 1;
    ln_apportion_factor           NUMBER;

    ln_charge_account_id          NUMBER;
    lv_part_i_register            VARCHAR2(20);
    ln_part_i_register_id         NUMBER;
    lv_part_ii_register           VARCHAR2(20);
    ln_part_ii_register_id        NUMBER;
    lv_register_type              VARCHAR(1);

    lv_excise_invoice_no          JAI_RCV_TRANSACTIONS.excise_invoice_no%TYPE;
    ld_excise_invoice_date        JAI_RCV_TRANSACTIONS.excise_invoice_date%TYPE;
    lv_tax_breakup_type           VARCHAR2(20);
    lb_process_iso                BOOLEAN;

    lv_message                    VARCHAR2(500);
    lv_err_message                VARCHAR2(500);
    lv_statement_id               VARCHAR2(5);
    lv_temp                       VARCHAR2(50);

    lv_cenvat_register_type       VARCHAR2(30);
    lv_edu_cess_register_type     VARCHAR2(30);
    r_cenvat                      TAX_BREAKUP;
    r_edu_cess                    TAX_BREAKUP;

    /*bgowrava for forward porting Bug#5756676 START*/

    CURSOR cur_rg1_register_id
		  IS
		  SELECT register_id
		    FROM JAI_CMN_RG_I_TRXS
		   WHERE TRANSACTION_SOURCE_NUM = 18
		     AND register_id    > 0 /*This check excludes master org records*/
		     AND ref_doc_no     = to_char(p_transaction_id);--added for bug#9478222

		  CURSOR cur_rg23_1_register_id
		  IS
		  SELECT register_id
		    FROM JAI_CMN_RG_23AC_I_TRXS
		   WHERE TRANSACTION_SOURCE_NUM = 18
		     AND register_id    > 0 /*This check excludes master org records*/
     AND RECEIPT_REF     = p_transaction_id;
/*bgowrava for forward porting Bug#5756676 END*/


    /* Bug 6800251. Added by Lakshmi Gopalsami
     * Fetched the total amount of RTV of the receipt
     * for which we are claiming the 2nd 50%.
     * This cursor will be fetched only in case of 2nd 50% claim
     */
    CURSOR C_Get_Total_RTV (cp_shipment_header_id IN NUMBER,
                            cp_shipment_line_id IN NUMBER
                           ) IS
    SELECT SUM(nvl(quantity,0))
      FROM jai_rcv_transactions jrt
     WHERE
       -- jrt.transaction_id > p_transaction_id AND
       jrt.transaction_type = 'RETURN TO VENDOR'
       AND jrt.shipment_header_id = cp_shipment_header_id
       AND jrt.shipment_line_id = cp_shipment_line_id;

    ln_RTV_qty NUMBER;
    ln_special_qty NUMBER;

  BEGIN

  /*----------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME: jai_rcv_excise_processing_pkg.sql
  S.No  dd/mm/yyyy   Author and Details
  ------------------------------------------------------------------------------------------------------------------------------
  1     26/07/2004   Vijay Shankar for Bug# 3496408, Version:115.0
                      This Package is coded for Corrections Enhancement to invoke CENVAT and RG related insert APIs for PO Functionality.

            - PROCESS_TRANSACTION
               This is the driving procedure that calls different internal API's which further calls CENVAT and RG APIs for data insertion
            - VALIDATE_TRANSACTION
               Validates whether CENVAT and RG entries needs to be passed for receipt transaction.
               Returns a value based on which the main procedure either proceeds or returns with a error message
            - DERIVE_CGIN_SCENARIO
               Returns a CGIN Scenario Code based on which Accounting and RG entry APIs are invoked
               valid values:  (1) 'REGULAR-FULL + REVERSAL-HALF' (2) 'REGULAR-HALF'
                              (3) 'REGULAR-FULL'                 (4) 'REGULAR-FULL + PARENT-REGULAR-HALF'
            - RG_I_ENTRY
               Has the RG1 Entry related data fetching logic. Invokes API to pass an RG1 Entry
            - RG23_PART_I_ENTRY
               Has the RG23 Part1 Entry related data fetching logic. Invokes API to pass RG23(A or C) Entry for quantity
            - RG23_D_ENTRY
               Has the RG23D Entry related data fetching logic. Invokes API to pass an RG23D Entry
            - RG23_PART_II_ENTRY
               Has the RG23 Part2 Entry related data fetching logic. Invokes API to pass RG23(A or C) Entry for Amount
            - PLA_ENTRY
               Has data fetching logic related to PLA Entry. Invokes API to pass a PLA Entry
            - ACCOUNTING_ENTRIES
               Determines the accounts that needs to be hit based on input params. Call Receipt Accounting API to pass accounting entries
            - GENERATE_EXCISE_INVOICE
               Invoices excise invoice no generation API and returns a value to caller
            Other Procedure and Functions are used for the processing of the transaction purpose

  2     26/10/2004   Vijay Shankar for Bug# 3927371, Version:115.1
                      IF Condition for Trading related transaction processing is corrected, which is previously wrong in PROCESS_TRANSACTION procedure

  3     03/01/2005   Vijay Shankar for Bug# 3940588, Version:115.2, 115.3
                      Following are the changes done as part of RECEIPTS DEPLUG and Education Cess Enhancement
                      - Added a RECORD Definition for tax breakup as TAX_BREAUP and modified to use this as a parameter in all the calls
                      that passes cenvat accounting and register entries. this change is made from an extensible perspective of breakup
                      - added the following procedures
                        - get_vendor_changed_dtls   : Retuns the changed excise vendor details as OUT Parameters
                        - post_cenvat_processor     : Updates JAI_RCV_CENVAT_CLAIMS, JAI_RCV_LINES tables with claim details
                        - other_cenvat_rg_recording : Inserts a record into JAI_CMN_RG_OTHERS table with the parameters passed to the call
                      - added the parameters p_process_special_reason and qty in PROCESS_TRANSACTION. These are used incase the accounting
                      and rg entries should consider these values for TAX_BREAUP instead of main transaction values.
                      These parameters are mainly added for RECEIPTS DEPLUG to support second Claim functionality of CGIN items
                      - COMMENTED the code related to AUTO Claim of 2nd 50% of RECEIVE transaction to the tune of RETURN TO VENDOR
                      that is being processed. this redundant as the 2nd 50% claim of RECEIVE will happen only to the tune of remaining
                      quantity of RECEIVE after RTV. Previous functionality is that, it claims whole of RECEIVE quantity for 2nd 50% also
                      Incase of CGIN items, CGIN_CODE returned from derive_cgin_code for RTV previously is 'REGULAR-FULL + PARENT-REGULAR-HALF'
                      and now it returns 'REGULAR-FULL + REVERSAL-HALF' incase the parent RECEIVE is only 50% claimed
                      - Call to get_vendor_changed_dtls is added in all RG Entries related procedures like rg23_part_i_entry etc. this
                      is used to insert RG Entries with a different Vendor other than excise if the user indicated the same through
                      Claim Cenvat Screen of India Localization
                      - Modified all RG Entries related procedures to make calls to other_cenvat_rg_recording incase EXCISE or CVD
                      EDUCATION_CESS are attached to receipt lines. the call inturn makes relevant CESS entries into RG tables
                      - Modified ACCOUTING_ENTRIES procedure to pass accounting for CESS Amounts to relevant CESS accounts of
                      Organization Additional information. this passes different accounting entries for EXCISE and CVD EUDCATION_CESS
                      incase they have different accounts defined in Organization Addl. Info Setup
                      - Modified get_tax_amount_breakup to break the amount for EXCISE_EDUCATION_CESS and CVD_EDUCATION_CESS also

  4.   16/02/2005 - bug#4187859  - File Version - 115.4
                   Even when RTV did not have cess, Validation to cess was done and an error was thrown to the uset that cess amount is
                   zero. This has been stopped by adding code not to call the ja_in_rg_others_pkg.insert_row procedure only if
                   the cess amount is not zero.

                   Dependency due to this bug:-
                    None

  5.   16/03/2005 - Vijay Shankar for Bug#4211045  - File Version - 115.5
                     Incase of RMA Accounting for CESS, we are hitting Cr. Excise Receivable A/C  and Dr. Cess RM A/C for Cess Amount.
                     this set of accounting for cess is wrong, instead it should be Cr. Cess Paid Payable Account and Dr. Cess RM A/C for Cess Amount
                     to fix this, changes are made in accounting_entries procedure and a call to jai_rcv_accounting_pkg.process_transaction
                     is made to pass an extra entry as Cr. Cess Paid Payable Accnt for Cess amt

  6.   15/04/2005    Sanjikum for Bug #4293421, File Version 116.0(115.7)

                     Problem
                     -------
                     During Cenvat Claim, while Inserting the Record into JAI_CMN_RG_23AC_II_TRXS, the Transaction date is inserted as Transaction Date of
                     the JAI_RCV_TRANSACTIONS.transaction_date. It should be the date on which claim is being made.

                     Fix
                     ---
                     In the Procedure rg23_part_ii_entry, while calling jai_cmn_rg_23ac_ii_pkg.insert_row, value of the parameter
                     p_transaction_date is changed to SYSDATE from r_trx.transaction_date

  7.   19/04/2005   Vijay Shankar for Bug #4103161, File Version 116.1(115.8)
                     Rounding of RTV Excise amounts to nearest rupee is removed as it will be done separately through RG Rounding
                     Concurrrent program

                   * Dependancy for later versions of this object *

  8   10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.2
                   Code is modified due to the Impact of Receiving Transactions DFF Elimination
                   added a procedure rtv_processing_for_ssi that will be invoked for SSI processing
                * High Dependancy for future Versions of this object *


 9   10-may-2007  bgowrava for forward porting Bug#5756676, 11i bug#5747013. File Version 120.15
	                  Issue : QTY REGISTER SHOULD BE UPDATED ON RECEIVE DEPENDING ON SETUP
	                    Fix : Changes are made to check if the Qty register is already hit. If it is then
	                          the Qty register is updated with the amounts. Otherwise call to api is made
	                          to insert into Qty register

	                  Dependancy due to this bug : Yes

10   10-may-2007  bgowrava for forward porting Bug#5756676, 11i bug#5747013. File Version 120.15
	                  Issue : QTY REGISTER SHOULD BE UPDATED ON RECEIVE DEPENDING ON SETUP
	                    Fix : The excise_invoice_no and excise_invoice_date should also be updated in Qty registers
                          in case of deferred claim also. So modified the update statement to update these columns also

11.   04/06/2007  sacsethi for bug 6109941  file version #120.18

                  CODE REVIEW COMMENTS FOR ENHANCEMENTS

		  Problem found for forward porting for Enhancement Additional cvd ( 5228046)  and budget 2007  ( 5989740)


  Dependancy:
  -----------
  IN60105D2 + 3496408
  IN60106   + 3940588 + 4146708/4239736 + 4103161 + 4346453

  /* IMPORTANT NOTE:
    For Receiving Transactions: In case of CGIN Claim a value needs to be passed for JAI_CMN_RG_23AC_II_TRXS.REFERENCE_NUM column
      that will be used for Duplicate Checking.
      Incase of RECEIVE transaction value passed for 1st 50% Claim is '1st Claim'. During 2nd 50% Claim '2nd Claim' is passed
      If 2nd Claim is happening from RTV transaction then TRANSACTION_ID of RECEIVE is passed as the value towards REFERENCE_NUM
      In all Other transactions value passed for REFERENCE_NUM column is NULL


  ----------------------------------------------------------------------------------------------------------------------------*/

    lv_procedure_name    := 'CENVAT_RG_PKG.process_transaction';
    ln_amount_factor     := 1;

    -- this is to identify the path in SQL TRACE file if any problem occured
    SELECT 'jai_rcv_excise_processing_pkg-'||p_transaction_id INTO lv_temp FROM DUAL;

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'*** Start jai_rcv_excise_processing_pkg.process_transaction');
      -- FND_FILE.put_line(FND_FILE.log,'*** Start jai_rcv_excise_processing_pkg.process_transaction');
    end if;

    lv_statement_id := '0';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.process_trx', 'START'); /* 1 */
    FND_FILE.put_line( FND_FILE.log, '***** Start of jai_rcv_excise_processing_pkg.process_transaction. Time:'||to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') );

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    lv_statement_id := '2';
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */

    validate_transaction(
      p_transaction_id    => p_transaction_id,
      p_validation_type   => 'COMMON',
      p_process_status    => p_process_status,
      p_process_message   => p_process_message,
      p_simulate_flag     => p_simulate_flag,
      p_codepath          => p_codepath
    );

    IF p_process_status IN ('X', 'E') THEN
      GOTO finish;
    END IF;

    lv_statement_id := '3';
    IF r_trx.organization_type = 'T' THEN
      lv_tax_breakup_type := 'RG23D';
    ELSE  -- manufacturing and others
      lv_tax_breakup_type := 'MODVAT';
    END IF;

    lv_statement_id := '4';
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */

    -- ln_curr_conv_rate := r_trx.currency_conversion_rate;
    get_tax_amount_breakup(
        p_shipment_line_id  => r_trx.shipment_line_id,
        p_transaction_id    => r_trx.transaction_id,
        p_curr_conv_rate    => r_trx.currency_conversion_rate,
        pr_tax              => r_tax,
        p_breakup_type      => lv_tax_breakup_type,
        p_codepath          => p_codepath
    );

    -- Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
    -- following should be executed only incase of RECEIVE (or) MATCH transactions and that too for 2nd claim
    IF p_process_special_reason = jai_rcv_excise_processing_pkg.second_50ptg_claim THEN
      /* Bug 6800251. Added by Lakshmi Gopalsami
       * Get the total RTV qty and proportion it against the receipt qty.
       * The tax breakup should happen for the remaining quantity so that
       * half of the amount can be used for 2nd claim.
       * changed p_process_special_qty
       */
      OPEN C_Get_Total_RTV(r_trx.shipment_header_id, r_trx.shipment_line_id);
        FETCH C_Get_Total_RTV INTO ln_RTV_qty;
      CLOSE C_Get_Total_RTV;
      ln_special_qty := r_trx.quantity - nvl(ln_RTV_qty,0);
      /* Bug 6800251.
       * This is to check whether all the materials are returned.
       * case where RTV qty = Receipt Qty cannot happen before 2nd claim,
       * as 100% should be claimed before returning full goods.
       *
       */
      r_tax := get_apportioned_tax(r_tax, ln_special_qty/r_trx.quantity,'2ND CLAIM' );
       -- Date 01/11/2006 Bug 5228046 added by SACSETHI
    END IF;

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'*** Start jai_rcv_excise_processing_pkg.process_transaction');
      -- FND_FILE.put_line(FND_FILE.log,'*** Start jai_rcv_excise_processing_pkg.process_transaction');
    end if;

    -- Following is to calculate Tax Breakup Amount As Per Apportion Factor. This is calculated based on
    -- Transaction UOMs, Quantities of Parent RECEIVE and present trxn an
    lv_statement_id := '4a';
    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */

    -- These variable are used for 2nd 50% Claim of RECEIVE Transaction of CGIN Items

     r_half_tax := get_apportioned_tax(r_tax, 0.5,null);/*uncommented by vkaranam  and passed null to the p_claim_type parameter for bug 4704957*/

    /* Call to Rounding of Excise Amounts */
    -- Rounding is done only for transaction types other than RECEIVE. Rounding of RECEIVE is handled at Excise invoice level seperately
    /* following is modified to include RETURN TO VENDOR as rounding of RTV will be done through a seperate process
    Vijay Shankar for Bug#4103161
    IF lv_transaction_type <> 'RECEIVE' THEN */
    /*commented by vkaranam for bug#9346733
    IF lv_transaction_type NOT IN ('RECEIVE','RETURN TO VENDOR') THEN
      do_cenvat_rounding(
        p_transaction_id  => r_trx.transaction_id,
        pr_tax            => r_tax,
        p_codepath        => p_codepath
      );
    END IF;

    if lb_rg_debug then
      --dbms_output.put_line('After Rounding. Basic:'||r_tax.basic_excise||', Addl:'||r_tax.addl_excise
      --  ||', Other:'||r_tax.other_excise||', cvd:'||r_tax.cvd ||', Addl. CVD:'||r_tax.addl_cvd);
      -- Date 30/10/2006 Bug 5228046 added by sacsethi
      FND_FILE.put_line(FND_FILE.log, 'After Rounding. Basic:'||r_tax.basic_excise||', Addl:'||r_tax.addl_excise
        ||', Other:'||r_tax.other_excise||', cvd:'||r_tax.cvd ||', Addl. CVD :'||r_tax.addl_cvd   );
    end if;
    */

    OPEN c_orgn_info(r_trx.organization_id, r_trx.location_id);
    FETCH c_orgn_info INTO r_orgn_info;
    CLOSE c_orgn_info;

    lv_register_type := jai_general_pkg.get_rg_register_type( p_item_class  => r_trx.item_class);

    lv_statement_id := '5';
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */

    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
    -- Excise Invoce Generation for Return to Vendor Transactions
    IF lv_transaction_type = 'RETURN TO VENDOR' THEN

      generate_excise_invoice(
          p_transaction_id       => p_transaction_id,
          p_organization_id      => r_trx.organization_id,
          p_location_id          => r_trx.location_id,
          p_excise_invoice_no    => lv_excise_invoice_no,
          p_excise_invoice_date  => ld_excise_invoice_date,
          p_simulate_flag        => p_simulate_flag,
          p_errbuf               => lv_err_message,
          p_codepath             => p_codepath
      );

      if lb_rg_debug then
        --dbms_output.put_line('After ExciseInv Gen. ExInvNo:'||nvl(lv_excise_invoice_no,'NULL') );
        FND_FILE.put_line(FND_FILE.log, 'After ExciseInv Gen. ExInvNo:'||nvl(lv_excise_invoice_no, 'NULL') );
      end if;

      lv_statement_id := '6';
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
      IF lv_excise_invoice_no IS NOT NULL THEN
        INSERT INTO JAI_RCV_RTV_DTLS(
          transaction_id, parent_transaction_id, shipment_line_id,
          excise_invoice_no, excise_invoice_date, rg_register_part_i,
          creation_date, created_by, last_update_date, last_updated_by, last_update_login
        ) VALUES (
          p_transaction_id, r_trx.parent_transaction_id, r_trx.shipment_line_id,
          lv_excise_invoice_no, ld_excise_invoice_date, NULL,
          SYSDATE, FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.user_id, FND_GLOBAL.login_id
        );

        lv_statement_id := '7';
        p_codepath := jai_general_pkg.plot_codepath(9, p_codepath);
        jai_rcv_transactions_pkg.update_excise_invoice_no(
          p_transaction_id      => p_transaction_id,
          p_excise_invoice_no   => lv_excise_invoice_no,
          p_excise_invoice_date => ld_excise_invoice_date
        );
      ELSE
        lv_message := 'Cenvat Entries cannot be posted due to Excise Invoice cant be generated';
        GOTO finish;
      END IF;

    END IF;
    */

    -- to determine the way in which CGIN Items are Processed
    IF lv_register_type = 'C' THEN
      derive_cgin_scenario(
          p_transaction_id  => p_transaction_id,
          p_cgin_code       => lv_cgin_code,
          p_process_status  => p_process_status,
          p_process_message => p_process_message,
          p_codepath        => p_codepath
      );

      FND_FILE.put_line(FND_FILE.log, 'CGIN_CODE->'||lv_cgin_code);
      IF p_process_status IN ('E', 'X') THEN
        GOTO finish;
      END IF;
    END IF;

    -- Following is Very Important IF condition that determines whether the transaction should be debited or credited
    IF lv_transaction_type IN ('RECEIVE', 'RETURN TO RECEIVING') THEN
      lv_cenvat_accounting_type  := CENVAT_DEBIT;
      lv_register_entry_type     := CENVAT_CREDIT;
    ELSIF lv_transaction_type IN ('DELIVER', 'RETURN TO VENDOR') THEN
      lv_cenvat_accounting_type  := CENVAT_CREDIT;
      lv_register_entry_type     := CENVAT_DEBIT;
    END IF;

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log, 'AccntEntry Type:'||lv_cenvat_accounting_type||', RegEntryType:'|| lv_register_entry_type);
    end if;

    -- 90% of the cenvat entries entries happen only for RECEIVE and RTV entries (code=1)
    -- and cenvat entries happen for DELIVER and RTR (code=2)cases only if subinventory is nonbonded
    -- 1. RECEIVE and RTV.   We dont check for Subinventory for these transaction types
    -- 2. DELIVER and RTR. These were supported only if subinventory is non bonded or expense or non asset case
    lv_statement_id := '8';
    p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
    IF lv_transaction_type IN ('RECEIVE', 'RETURN TO RECEIVING', 'DELIVER', 'RETURN TO VENDOR') THEN

      IF r_trx.organization_type = jai_rcv_trx_processing_pkg.MFG_ORGN  THEN

        lv_statement_id := '9';
        p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */

        IF (r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma  -- 'India RMA Receipt'
            AND r_trx.item_class IN ('FGIN', 'FGEX', 'CCIN', 'CCEX'))
	  /*Added by nprashar for bug 6710747 The following condition is added to support register update for Inter Org Transfer*/
	  OR ( r_base_trx.source_document_Code = 'INVENTORY' AND lv_transaction_type <>'DELIVER' AND r_trx.item_class IN ('FGIN', 'FGEX', 'CCIN', 'CCEX'))
        THEN

        /*bgowrava for forward porting Bug#5756676..start*/
				        IF nvl(r_trx.quantity_register_flag,'N') = 'Y' THEN

				          OPEN  cur_rg1_register_id;
				          FETCH cur_rg1_register_id INTO ln_part_i_register_id;
				          CLOSE cur_rg1_register_id;

				          UPDATE JAI_CMN_RG_I_TRXS
				             SET basic_ed              = r_tax.basic_excise,
				                 additional_ed         = r_tax.addl_excise + r_tax.cvd,
				                 other_ed              = r_tax.other_excise,
				                 excise_duty_amount    = r_tax.basic_excise + r_tax.addl_excise + r_tax.cvd + r_tax.other_excise,
				                 excise_invoice_number = r_trx.excise_invoice_no,
				                 excise_invoice_date   = r_trx.excise_invoice_date
           WHERE register_id           = ln_part_i_register_id;

           ELSE

          rg_i_entry(
              p_transaction_id       => r_trx.transaction_id,
              pr_tax                 => r_tax,
              p_register_entry_type  => lv_register_entry_type,
              p_register_id          => ln_part_i_register_id,
              p_process_status       => p_process_status,
              p_process_message      => p_process_message,
              p_simulate_flag        => p_simulate_flag,
              p_codepath             => p_codepath
          );

          END IF;
          /*bgowrava for forward porting Bug#5756676..end*/

          IF ln_part_i_register_id IS NOT NULL THEN
            lv_part_i_register  := 'RG1';
          END IF;

        ELSIF r_trx.item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX', 'CGIN', 'CGEX') THEN

          lv_statement_id := '10';
          p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */

          -- RG23 Part I Entry is already made during first Claim, in case of CGIN Items
          -- So no need of another entry during Second 50% Claim of CENVAT
          IF nvl(lv_cgin_code, 'XXX') <> 'REGULAR-HALF' THEN

           /*bgowrava for forward porting Bug#5756676..start*/

							IF nvl(r_trx.quantity_register_flag,'N') = 'Y' THEN

							FND_FILE.put_line(FND_FILE.log, 'Quantity register is already hit. So updating amounts');

								OPEN  cur_rg23_1_register_id;
								FETCH cur_rg23_1_register_id INTO ln_part_i_register_id;
								CLOSE cur_rg23_1_register_id;

			  			  FND_FILE.put_line(FND_FILE.log, 'RG23 Part I Register Id:'||ln_part_i_register_id);

								UPDATE JAI_CMN_RG_23AC_I_TRXS
									 SET basic_ed            = r_tax.basic_excise,
			  			         additional_ed       = r_tax.addl_excise + r_tax.cvd,
			  			         additional_cvd      = r_tax.addl_cvd,
			  			         other_ed            = r_tax.other_excise,
			  			         EXCISE_INVOICE_NO   = r_trx.excise_invoice_no,
			  			         excise_invoice_date = r_trx.excise_invoice_date
								 WHERE register_id         = ln_part_i_register_id;

							ELSE

					     FND_FILE.put_line(FND_FILE.log, 'Quantity register is not hit. So calling rg23_part_i_entry');
               rg23_part_i_entry(
                p_transaction_id       => r_trx.transaction_id,
                pr_tax                 => r_tax,
                p_register_entry_type  => lv_register_entry_type,
                p_register_id          => ln_part_i_register_id,
                p_process_status       => p_process_status,
                p_process_message      => p_process_message,
                p_simulate_flag        => p_simulate_flag,
                p_codepath             => p_codepath
            );

            END IF;
          /*bgowrava for forward porting Bug#5756676..end*/

          ELSE
            FND_FILE.put_line( FND_FILE.log, 'No Call to RG23_PART_I_ENTRY');
          END IF;

          IF ln_part_i_register_id IS NOT NULL THEN
            lv_part_i_register  := 'RG23'||lv_register_type;
          END IF;

        ELSE
          lv_message := 'ItemClass Not Supported for Transaction';
          GOTO finish;
        END IF;

        IF p_process_status IN ('E', 'X') THEN
          GOTO finish;
        END IF;

        /*uncommneted by vkaranam for bug#4704957, start */--Commented by Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG.
        -- Start PARENT Half Claim entry for RTV
        -- This is for RTV case when Parent RECEIVE is only 50% Claimed
        IF lv_transaction_type = 'RETURN TO VENDOR'
          AND lv_register_type = 'C'
          AND lv_cgin_code like '%PARENT-REGULAR-HALF%'
        THEN

          FND_FILE.put_line(FND_FILE.log, '<< Start 2nd 50% Claim of RECEIVE during RTV');

          lv_statement_id := '11';
          p_codepath := jai_general_pkg.plot_codepath(13, p_codepath);
          ln_receive_trx_id := r_trx.tax_transaction_id;

          -- Pass an RG23 PartII Entry against Parent RECEIVE line to the tune of 50% of RTV Quantity
          rg23_part_ii_entry(
              --p_transaction_id        => r_trx.transaction_id,
              p_transaction_id        => r_trx.tax_transaction_id,--added by vkaranam for bug 5841749
              pr_tax                  => r_half_tax,
              p_part_i_register_id    => NULL,
              p_register_entry_type   => CENVAT_CREDIT,
              p_reference_num         => r_trx.transaction_id,/*ln_receive_trx_id is replaced by r_trx.transaction_id by vkaranam for bug#4704957*/
              p_register_id           => ln_receive_part_ii_reg_id,
              p_process_status        => p_process_status,
              p_process_message       => p_process_message,
              p_simulate_flag         => p_simulate_flag,
              p_codepath              => p_codepath
          );

          IF p_process_status IN ('E', 'X') THEN
            GOTO finish;
          END IF;

          IF ln_receive_part_ii_reg_id IS NOT NULL THEN
            lv_receive_part_ii_type := 'RG23C';

            -- Vijay Shankar for Bug#3940588. The same is coded at the end of procedure
            -- this is to increase the cenvat_claimed_amt to the tune of second 50% that is claimed now on RECEIVE transaction
            UPDATE JAI_RCV_CENVAT_CLAIMS
              SET cenvat_claimed_amt = nvl(cenvat_claimed_amt,0)
                          + (r_half_tax.basic_excise +
			     r_half_tax.addl_excise +
			     r_half_tax.other_excise +
			     r_half_tax.cvd +
			     r_tax.addl_cvd     -- Date 30/10/2006 Bug 5228046 added by sacsethi
			    ),
                        other_cenvat_claimed_amt = nvl(other_cenvat_claimed_amt,0)
                          + (r_half_tax.excise_edu_cess + r_half_tax.cvd_edu_cess+nvl(r_half_tax.sh_exc_edu_cess,0)
                          + nvl(r_half_tax.sh_cvd_edu_cess,0)),
                          /*added nvl(r_half_tax.sh_exc_edu_cess,0) + nvl(r_half_tax.sh_cvd_edu_cess,0) by vkaranam for budget 07 impact - bug#5989740*/
                  cenvat_sequence = cenvat_sequence + 1,
                  last_update_date = sysdate,
                  last_updated_by = fnd_global.user_id
            WHERE transaction_id = ln_receive_trx_id;
            -- CHK whether the above update is required or not. because there is another update at the end of procedure

          END IF;

          lv_statement_id := '11a';
          p_codepath := jai_general_pkg.plot_codepath(14, p_codepath);
          -- Pass accounting for the remaining 50% Claim against Parent RECEIVE line to the tune of RTV Quantity.
          -- Full amount is passed here but half amount will be passed in accounting_entries procedure
          accounting_entries(
              p_transaction_id          => r_trx.transaction_id,
              pr_tax                    => r_tax,
              p_cgin_code               => 'REGULAR-HALF',
              p_cenvat_accounting_type  => CENVAT_DEBIT,
              p_amount_register         => lv_receive_part_ii_type,
              p_cenvat_account_id       => ln_receive_charge_accnt,
              p_process_status          => p_process_status,
              p_process_message         => p_process_message,
              p_simulate_flag           => p_simulate_flag,
              p_codepath                => p_codepath
          );

          IF p_process_status IN ('E', 'X') THEN
            GOTO finish;
          END IF;

          jai_cmn_rg_23ac_ii_pkg.update_payment_details(
            p_register_id         => ln_receive_part_ii_reg_id,
            p_register_id_part_i  => NULL,
            p_charge_account_id   => ln_receive_charge_accnt
          );

          FND_FILE.put_line(FND_FILE.log, '>> END 2nd 50% Claim of RECEIVE during RTV');

        END IF;
        -- End PARENT Half Claim entry for RTV
        /*vkaranam for bug #4704957,end*/

        lv_statement_id := '11b';
        p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
        -- lv_cgin_code will have a value only in case of CGIN items wherein 1st 50% claim is 'REGULAR-FULL + REVERSAL-HALF'
        -- and 2nd 50% claim is done by 'REGULAR-HALF'
        IF lv_cgin_code IN ( 'REGULAR-FULL + REVERSAL-HALF', 'REGULAR-HALF') THEN
          ln_amount_factor := 0.5;
        ELSE
          ln_amount_factor := 1;
        END IF;

        lv_statement_id := '12';

        /* START - DUTY REGISTER HITTING LOGIC */
        -- following if condition modified by Vijay Shankar for RECEIPTS DEPLUG
        -- IF lv_transaction_type = 'RETURN TO VENDOR' AND r_orgn_info.pref_pla = 1 THEN
        IF lv_transaction_type = 'RETURN TO VENDOR' THEN

          p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */

          derive_duty_registers(
            p_organization_id           => r_trx.organization_id,
            p_location_id               => r_trx.location_id,
            p_item_class                => r_trx.item_class,
            pr_tax                      => r_tax,
            p_cenvat_register_type      => lv_cenvat_register_type,
            -- p_edu_cess_register_type    => lv_edu_cess_register_type,
            p_process_flag              => p_process_status,
            p_process_message           => p_process_message,
            p_codepath                  => p_codepath
          );

          IF p_process_status = 'E' THEN
            GOTO finish;
          END IF;

        ELSE
          lv_cenvat_register_type   := NULL;
          lv_edu_cess_register_type := NULL;
        END IF;

        IF    (lv_cenvat_register_type IS NULL AND lv_edu_cess_register_type IS NULL)
            OR lv_cenvat_register_type IN (jai_constants.register_type_a, jai_constants.register_type_c)
        THEN

          lv_statement_id := '13';
          p_codepath := jai_general_pkg.plot_codepath(17, p_codepath);

          IF lv_transaction_type = 'RECEIVE' AND lv_cgin_code IS NOT NULL THEN
            -- 1st Claim
            IF nvl(p_cenvat_claimed_ptg, 0) = 0 THEN
              lv_reference_num := CGIN_FIRST_CLAIM;
            -- 2nd Claim onwards. -- Helpful to identify the duplicate entry in JAI_CMN_RG_23AC_II_TRXS. if the line is 100% Claimed, then we should not pass another entry
            ELSE    -- IF p_cenvat_claimed_ptg = 50 THEN
              lv_reference_num := CGIN_SECOND_CLAIM;
            END IF;
          ELSE
            lv_reference_num := NULL;
          END IF;

          lv_statement_id := '13.1';
          rg23_part_ii_entry(
              p_transaction_id        => r_trx.transaction_id,
              pr_tax                  => get_apportioned_tax(r_tax,
	                                                     ln_amount_factor,
							     UPPER(lv_reference_num)     -- Date 30/10/2006 Bug 5228046 added by sacsethi
							    ),
              p_part_i_register_id    => ln_part_i_register_id,
              p_register_entry_type   => lv_register_entry_type,
              p_reference_num         => lv_reference_num,
              p_register_id           => ln_part_ii_register_id,
              p_process_status        => p_process_status,
              p_process_message       => p_process_message,
              p_simulate_flag         => p_simulate_flag,
              p_codepath              => p_codepath
          );

          IF p_process_status IN ('E', 'X') THEN
            GOTO finish;
          END IF;

          IF ln_part_ii_register_id IS NOT NULL THEN
            lv_part_ii_register  := 'RG23'||lv_register_type;
          END IF;

        ELSIF lv_cenvat_register_type = jai_constants.register_type_pla THEN

          lv_statement_id := '13.2';
          p_codepath := jai_general_pkg.plot_codepath(17.1, p_codepath);
          pla_entry(
              p_transaction_id      => p_transaction_id,
              pr_tax                => get_apportioned_tax(r_tax,
	                                                   ln_amount_factor,
							   UPPER(lv_reference_num)) ,    -- Date 30/10/2006 Bug 5228046 added by sacsethi
              p_register_entry_type => lv_register_entry_type,
              p_register_id         => ln_part_ii_register_id,
              p_process_status      => p_process_status,
              p_process_message     => p_process_message,
              p_simulate_flag       => p_simulate_flag,
              p_codepath            => p_codepath
          );

          IF p_process_status IN ('E', 'X') THEN
            GOTO finish;
          END IF;

          IF ln_part_ii_register_id IS NOT NULL THEN
            lv_part_ii_register  := 'PLA';
          END IF;

        ELSE
          lv_statement_id := '13.3';
          p_codepath := jai_general_pkg.plot_codepath(17.2, p_codepath);
          --p_process_status  := 'E';
          lv_message := 'Duty Register cannot be derived';
          GOTO finish;
        END IF;

        /* END - DUTY REGISTER HITTING LOGIC */

        /* START - ACCOUNTING LOGIC */
        lv_statement_id := '13a';
        p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */

        fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb> --- 1');

        accounting_entries(
            p_transaction_id          => r_trx.transaction_id,
            pr_tax                    => r_tax,
            p_cgin_code               => lv_cgin_code,
            p_cenvat_accounting_type  => lv_cenvat_accounting_type,
            p_amount_register         => lv_part_ii_register,
            p_cenvat_account_id       => ln_charge_account_id,
            p_process_status          => p_process_status,
            p_process_message         => p_process_message,
            p_simulate_flag           => p_simulate_flag,
            p_codepath                => p_codepath
        );

        IF p_process_status IN ('E', 'X') THEN
          GOTO finish;
        END IF;
        /* END - ACCOUNTING LOGIC */

      ELSIF r_trx.organization_type = jai_rcv_trx_processing_pkg.TRADING_ORGN THEN

        -- In a Trading Organization all the ITEM CLASSes are supported

        lv_statement_id := '14';
        -- IF r_trx.item_class IN ('FGIN', 'FGEX') THEN
          -- right now i am assuming that we need not pass any accouting entries. however we need to pass rg23d entry

        lv_statement_id := '15';
        p_codepath := jai_general_pkg.plot_codepath(20, p_codepath); /* 20 */
        rg23_d_entry(
            p_transaction_id      => p_transaction_id,
            pr_tax                => r_tax,
            p_register_entry_type => lv_register_entry_type,
            p_register_id         => ln_part_i_register_id,
            p_process_status      => p_process_status,
            p_process_message     => p_process_message,
            p_simulate_flag       => p_simulate_flag,
            p_codepath            => p_codepath
        );

        IF ln_part_i_register_id IS NOT NULL THEN
          lv_part_i_register  := 'RG23D';
        END IF;

        IF p_process_status IN ('E', 'X') THEN
          GOTO finish;
        END IF;

        lv_statement_id := '16';
        p_codepath := jai_general_pkg.plot_codepath(21, p_codepath); /* 21 */
        -- there is no part II entry for TRADING transactions
        IF lv_transaction_type IN ('RECEIVE', 'RETURN TO VENDOR') AND r_trx.excise_in_trading = 'Y' THEN

          lb_process_iso := jai_rcv_trx_processing_pkg.process_iso_transaction(
                                p_transaction_id    => r_trx.transaction_id,
                                p_shipment_line_id  => r_trx.shipment_line_id
                            );

          -- No cenvat accounting in case of DELIVER/ RETURN TO RECEIVING.
          -- Also accounting happens only if Organization Setup for Excise in RG23D is checked

        -- Vijay Shankar for Bug#3927371, This needs modification after discussing with Yadu
          -- IF r_trx.organization_type = 'M' OR (r_trx.organization_type = 'T' AND lb_process_iso)
          IF ( r_base_trx.source_document_code <> 'REQ'
            OR (r_base_trx.source_document_code='REQ' AND lb_process_iso) )
            AND r_base_trx.source_document_code <> jai_rcv_trx_processing_pkg.source_rma /*srjayara for bug#5155138 - change done for base bug 5110511 + DFF Elimination*/

          THEN

            p_codepath := jai_general_pkg.plot_codepath(21.2, p_codepath);
            accounting_entries(
                p_transaction_id          => r_trx.transaction_id,
                pr_tax                    => r_tax,
                p_cgin_code               => NULL, -- lv_cgin_code can be null as this is trading organization
                p_cenvat_accounting_type  => lv_cenvat_accounting_type,
                p_amount_register         => lv_part_ii_register,
                p_cenvat_account_id       => ln_charge_account_id,
                p_process_status          => p_process_status,
                p_process_message         => p_process_message,
                p_simulate_flag           => p_simulate_flag,
                p_codepath                => p_codepath
            );

          ELSE
            FND_FILE.put_line( FND_FILE.log, '..No Accounting Required for Trading Orgn');
          END IF;

        END IF;

      ELSE
        p_codepath := jai_general_pkg.plot_codepath(21.5, p_codepath);
        lv_message := 'Organization Type Not supported';
        GOTO finish;
      END IF;

      IF p_process_status IN ('E', 'X') THEN
        GOTO finish;
      END IF;

    ELSE
      lv_statement_id := '18';
      p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); /* 22 */
      lv_message := 'Transaction Type Not supported';
      GOTO finish;
    END IF;

    lv_statement_id := '19';
    p_codepath := jai_general_pkg.plot_codepath(23, p_codepath); /* 23 */
    -- Updation of RG Part1 Registers with Payment Register, Register_Id_Part_II, ChargeAccountId
    update_registers(
        p_quantity_register_id  => ln_part_i_register_id,
        p_quantity_register     => lv_part_i_register,
        p_payment_register_id   => ln_part_ii_register_id,
        p_payment_register      => lv_part_ii_register,
        p_charge_account_id     => ln_charge_account_id,
        p_process_status        => p_process_status,
        p_process_message       => p_process_message,
        p_simulate_flag         => p_simulate_flag,
        p_codepath              => p_codepath
    );

    IF lv_transaction_type = 'RETURN TO VENDOR' AND ln_part_i_register_id IS NOT NULL THEN
      lv_statement_id := '20';
      p_codepath := jai_general_pkg.plot_codepath(24, p_codepath); /* 24 */
      UPDATE JAI_RCV_RTV_DTLS
      SET rg_register_part_i = ln_part_i_register_id
      WHERE transaction_id = p_transaction_id;
    END IF;

    -- Assigning the Percentage value that has been claimed w.r.t transaction
    IF lv_register_type = 'C' THEN
      IF lv_transaction_type = 'RECEIVE' THEN
        IF lv_cgin_code = 'REGULAR-FULL' THEN
          p_cenvat_claimed_ptg := 100;
        ELSE      --IF lv_transaction_type = 'REGULAR-HALF' THEN
          p_cenvat_claimed_ptg := nvl(p_cenvat_claimed_ptg, 0) + 50;
        END IF;
      ELSE
        IF lv_cgin_code in ('REGULAR-FULL + REVERSAL-HALF', 'REGULAR-HALF') THEN
          p_cenvat_claimed_ptg := 50;
        ELSE
          p_cenvat_claimed_ptg := 100;
        END IF;
      END IF;
    ELSE
      p_cenvat_claimed_ptg := 100;
    END IF;

    -- CALL TO Post Processor updated claim related stuff in JAI_RCV_CENVAT_CLAIMS and JAI_RCV_LINES at RECEIVE trx level
    -- Vijay Shankar for Bug#3940588
    post_cenvat_processor(
      p_transaction_id            => p_transaction_id,
      p_cenvat_claimed_ptg        => p_cenvat_claimed_ptg,
      p_cenvat_claimed_amt        => (
                                        (  r_tax.basic_excise +
					   r_tax.addl_excise +
					   r_tax.other_excise +
					   r_tax.cvd
					)  * ln_amount_factor
				     ) + r_tax.addl_cvd ,-- Date 30/10/2006 Bug 5228046 added by sacsethi
      p_other_cenvat_claimed_amt  => (r_tax.excise_edu_cess + r_tax.cvd_edu_cess+r_tax.sh_exc_edu_cess + r_tax.sh_cvd_edu_cess) * ln_amount_factor/*added r_tax.sh_exc_edu_cess + r_tax.sh_cvd_edu_cess
                                                                                                                                                   by vkaranam for budget 07 impact - bug#5989740*/
    );

    p_process_status := 'Y';

    <<finish>>
    IF lv_message IS NOT NULL THEN
      p_codepath := jai_general_pkg.plot_codepath(25, p_codepath); /* 25 */

      FND_FILE.put_line(FND_FILE.log, 'CENVAT_RG_PKG.process_trxn:'||lv_message||', StatementId:'||lv_statement_id);
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.process_trxn:'||lv_message||', StatementId:'||lv_statement_id;
    END IF;

    p_codepath := jai_general_pkg.plot_codepath(26, p_codepath, null, 'END'); /* 26 */
    FND_FILE.put_line( FND_FILE.log, '----- END, jai_rcv_excise_processing_pkg.process_transaction. Time:'||to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') );

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.process_transaction->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END process_transaction;

  -- this procedure to be called only for RMA case of FGIN, FGEX, CCIN, CCEX
  PROCEDURE rg_i_entry(
    p_transaction_id      IN  NUMBER,
    pr_tax                IN  TAX_BREAKUP,
    p_register_entry_type IN  VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag       IN  VARCHAR2,
    p_codepath            IN OUT NOCOPY VARCHAR2
  ) IS

    r_trx                     c_trx%ROWTYPE;
    r_base_trx                c_base_trx%ROWTYPE;

    ln_register_id            JAI_CMN_RG_I_TRXS.register_id%TYPE;
    lv_slno                   JAI_CMN_RG_I_TRXS.slno%TYPE;
    lv_range                  JAI_CMN_RG_I_TRXS.range_no%TYPE;
    lv_division               JAI_CMN_RG_I_TRXS.division_no%TYPE;
    ln_excise_duty_rate       JAI_CMN_RG_I_TRXS.excise_duty_rate%TYPE;
    lv_excise_invoice_no      JAI_CMN_RG_I_TRXS.excise_invoice_number%TYPE;
    ld_excise_invoice_date    JAI_CMN_RG_I_TRXS.excise_invoice_date%TYPE;
    ln_customer_id            RCV_TRANSACTIONS.customer_id%TYPE;
    ln_customer_site_id       RCV_TRANSACTIONS.customer_site_id%TYPE;
    r_parent_base_trx         c_base_trx%ROWTYPE;

    ln_entry_type             NUMBER;   --File.Sql.35 Cbabu  := 1;
    ln_basic_ed               NUMBER;
    ln_additional_ed          NUMBER;
    ln_other_ed               NUMBER;
    ln_excise_duty_amount     NUMBER;


    lv_transaction_type       JAI_CMN_RG_I_TRXS.transaction_type%TYPE;

    ln_quantity               NUMBER;
    ln_vendor_id              NUMBER(15);
    ln_vendor_site_id         NUMBER(15);

    lv_statement_id           VARCHAR2(5);
    ln_exc_edu_cess           NUMBER; /*vkaranam for bug 5989740*/
    ln_sh_exc_edu_cess        NUMBER; /*vkaranam for bug 5989740*/

	  /* added, vumaasha for Bug 4689713   */
   Cursor c_excise_tax_rate(cp_shipment_header_id JAI_RCV_LINE_TAXES.shipment_header_id%TYPE,
                           cp_shipment_line_id JAI_RCV_LINE_TAXES.shipment_line_id%TYPE ) IS
    select nvl(sum(jrtl.tax_rate),0) , count(jrtl.tax_rate)
    from   JAI_RCV_LINE_TAXES  jrtl ,
           JAI_CMN_TAXES_ALL     jtc
    where  jrtl.tax_id   = jtc.tax_id
    and    jrtl.shipment_header_id = cp_shipment_header_id
    and    jrtl.shipment_line_id   = cp_shipment_line_id
    AND    UPPER(jtc.tax_type) = 'EXCISE'  ;

    ln_total_tax_rate  JAI_CMN_TAXES_ALL.tax_rate%TYPE;
    ln_number_of_Taxes NUMBER;

  /* ended, vumaasha for Bug 4689713 */

  BEGIN

    ln_entry_type := 1;
    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'^ RG1 Entry. Basic:'||pr_tax.basic_excise
        ||', Addl:'||pr_tax.addl_excise||', Other:'||pr_tax.other_excise
        ||', CVD:'||pr_tax.cvd||', EntryType:'||p_register_entry_type ||', PrcSta:'||p_process_status
      );
    end if;

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.rg_i_entry', 'START'); /* 1 */

    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_statement_id := '2';
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    ln_customer_id      := r_base_trx.customer_id;
    ln_customer_site_id := r_base_trx.customer_site_id;

    IF r_base_trx.source_document_code = 'REQ' THEN
      lv_statement_id := '4';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      OPEN c_source_orgn_loc( r_base_trx.shipment_header_id, r_base_trx.requisition_line_id);
      FETCH c_source_orgn_loc INTO ln_vendor_id, ln_vendor_site_id;
      CLOSE c_source_orgn_loc;

      ln_vendor_id      := -ln_vendor_id;
      ln_vendor_site_id := -ln_vendor_site_id;

    ELSE
      lv_statement_id := '5';
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */

      get_changed_vendor_dtls(
        p_receive_trx_id      => r_trx.tax_transaction_id,
        p_shipment_line_id    => r_trx.shipment_line_id,
        p_vendor_id           => ln_vendor_id,
        p_vendor_site_id      => ln_vendor_site_id
      );

      ln_vendor_id      := nvl(ln_vendor_id, r_base_trx.vendor_id);
      ln_vendor_site_id := nvl(ln_vendor_site_id, r_base_trx.vendor_site_id);

    END IF;

    IF r_base_trx.source_document_code = 'RMA' THEN
      IF ln_customer_site_id IS NULL THEN
        /*OPEN c_base_trx( jai_rcv_trx_processing_pkg.get_ancestor_id(
                            p_transaction_id     => r_trx.transaction_id,
                            p_shipment_line_id   => r_trx.shipment_line_id,
                            p_required_trx_type  => 'RECEIVE'
                         )
                       );*/
        OPEN c_base_trx(r_trx.tax_transaction_id);
        FETCH c_base_trx INTO r_parent_base_trx;
        CLOSE c_base_trx;

        ln_customer_site_id := r_parent_base_trx.customer_site_id;
      END IF;
    END IF;

    lv_statement_id := '61';
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    jai_general_pkg.get_range_division(
        p_vendor_id       => ln_vendor_id,
        p_vendor_site_id  => ln_vendor_site_id,
        p_range_no        => lv_range,
        p_division_no     => lv_division
    );

    lv_excise_invoice_no    := r_trx.excise_invoice_no;
    ld_excise_invoice_date  := r_trx.excise_invoice_date;

    lv_statement_id := '7';
    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt' THEN
    IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma then -- 'India RMA Receipt' THEN
      lv_transaction_type := 'CR';
    ELSE
      lv_transaction_type := 'R';
    END IF;

    IF p_register_entry_type = CENVAT_DEBIT THEN
      ln_entry_type := -1;
    END IF;

    lv_statement_id := '8';
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    ln_quantity           := r_trx.quantity * ln_entry_type;
    ln_basic_ed           := pr_tax.basic_excise * ln_entry_type;
    ln_additional_ed      := (pr_tax.addl_excise + pr_tax.cvd) * ln_entry_type;
    ln_other_ed           := pr_tax.other_excise * ln_entry_type;
    ln_excise_duty_amount := ln_basic_ed + ln_additional_ed + ln_other_ed;
    ln_exc_edu_cess       := pr_tax.excise_edu_cess * ln_entry_type;/*added by vkaranam for bug #5989740*/
    ln_sh_exc_edu_cess       := pr_tax.sh_exc_edu_cess * ln_entry_type;/*added by vkaranam for bug #5989740*/
    /* ln_excise_duty_rate := ln_excise_duty_amount/ln_quantity; commented, vumaasha for Bug 4689713 */

	/* added, Vumaasha for Bug 4689713  */

    OPEN c_excise_tax_rate( r_trx.shipment_header_id, r_trx.shipment_line_id ) ;
    FETCH c_excise_tax_rate INTO ln_total_tax_rate , ln_number_of_Taxes ;
    CLOSE c_excise_tax_rate;

    if NVL(ln_number_of_Taxes,0) = 0 then
      ln_number_of_Taxes := 1;
    end if;

    ln_excise_duty_rate := ln_total_tax_rate / ln_number_of_Taxes;

   /* ended, Vumaasha for Bug 4689713   */


    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'Before call to RG1. ExDutyAmt:'||ln_excise_duty_amount);
    end if;

    lv_statement_id := '9';
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
    jai_cmn_rg_i_trxs_pkg.create_rg1_entry(
        p_register_id                  => p_register_id,
        p_register_id_part_ii          => null,
        p_fin_year                     => jai_general_pkg.get_fin_year(p_organization_id => r_trx.organization_id),
        p_slno                         => lv_slno,
        p_transaction_id               => null,
        p_organization_id              => r_trx.organization_id,
        p_location_id                  => r_trx.location_id,
        p_transaction_date             => r_trx.transaction_date,
        p_inventory_item_id            => r_trx.inventory_item_id,
        p_transaction_type             => lv_transaction_type,
        p_ref_doc_id                   => to_char(p_transaction_id),
        p_quantity                     => ln_quantity,
        p_transaction_uom_code         => r_trx.uom_code,
        p_issue_type                   => null,
        p_excise_duty_amount           => ln_excise_duty_amount,
        p_excise_invoice_number        => r_trx.excise_invoice_no,
        p_excise_invoice_date          => r_trx.excise_invoice_date,
        p_payment_register             => null,
        p_charge_account_id            => NULL,
        p_range_no                     => lv_range,
        p_division_no                  => lv_division,
        p_remarks                      => null,
        p_basic_ed                     => ln_basic_ed,
        p_additional_ed                => ln_additional_ed,
        p_other_ed                     => ln_other_ed,
        p_assessable_value             => null,
        p_excise_duty_rate             => ln_excise_duty_rate,
        p_vendor_id                    => ln_vendor_id,
        p_vendor_site_id               => ln_vendor_site_id,
        p_customer_id                  => ln_customer_id,
        p_customer_site_id             => ln_customer_site_id,
        p_creation_date                => SYSDATE,
        p_created_by                   => fnd_global.user_id,
        p_last_update_date             => SYSDATE,
        p_last_updated_by              => fnd_global.user_id,
        p_last_update_login            => fnd_global.login_id,
        p_called_from                  => 'RECEIPTS',
        p_cess_amount                  => ln_exc_edu_cess ,/*added by vkaranam for budget 07 impact - bug#5989740*/
	p_sh_cess_amount               => ln_sh_exc_edu_cess --added by vkaranam for budget 07 impact - bug#5989740
     );


     /*bgowrava for forward porting Bug#5756676..start*/

		 	UPDATE JAI_RCV_TRANSACTIONS
		 		 SET quantity_register_flag  = 'Y',
		 				 last_updated_by         = fnd_global.user_id,
		 				 last_update_date        = sysdate,
		 				 last_update_login       = fnd_global.login_id
		 	 WHERE transaction_id          = p_transaction_id ;

		   FND_FILE.put_line(FND_FILE.log, 'Updating quantity register flag to Y');

		   /*bgowrava for forward porting Bug#5756676..end*/


    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, null, 'END'); /* 9 */

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.rg_i_entry->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END rg_i_entry;

  PROCEDURE rg23_part_i_entry(
    p_transaction_id    IN NUMBER,
    pr_tax                IN  TAX_BREAKUP,
    p_register_entry_type IN VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag     IN VARCHAR2,
    p_codepath          IN OUT NOCOPY VARCHAR2
  ) IS

    CURSOR c_po_header(cp_po_header_id IN NUMBER) IS
      SELECT po_header_id, creation_date
      FROM po_headers_all
      WHERE po_header_id = cp_po_header_id;

    r_trx                     c_trx%ROWTYPE;
    r_base_trx                c_base_trx%ROWTYPE;
    r_po_header               c_po_header%ROWTYPE;

    ln_register_id            JAI_CMN_RG_23AC_I_TRXS.register_id%TYPE;
    ln_vendor_id              RCV_TRANSACTIONS.vendor_id%TYPE;
    ln_vendor_site_id         RCV_TRANSACTIONS.vendor_site_id%TYPE;
    lv_excise_invoice_no      JAI_CMN_RG_23AC_I_TRXS.EXCISE_INVOICE_NO%TYPE;
    ld_excise_invoice_date    JAI_CMN_RG_23AC_I_TRXS.excise_invoice_date%TYPE;
    lv_transaction_type       RCV_TRANSACTIONS.transaction_type%TYPE;
    ln_customer_id            RCV_TRANSACTIONS.customer_id%TYPE;
    ln_customer_site_id       RCV_TRANSACTIONS.customer_site_id%TYPE;
    r_parent_base_trx         c_base_trx%ROWTYPE;

    ln_entry_type             NUMBER;   --File.Sql.35 Cbabu  := 1;
    ln_basic_ed               NUMBER;
    ln_additional_ed          NUMBER;
    ln_additional_cvd         NUMBER;     -- Date 30/10/2006 Bug 5228046 added by sacsethi
    ln_other_ed               NUMBER;
    ln_quantity               NUMBER;

    lv_statement_id           VARCHAR2(5);
  BEGIN

    ln_entry_type    := 1;
    if lb_rg_debug then
     -- Date 30/10/2006 Bug 5228046 added by sacsethi
      FND_FILE.put_line(FND_FILE.log,'^ RG23_PART_I_Entry. Basic:'||pr_tax.basic_excise
        ||', Addl:'||pr_tax.addl_excise||', Other:'||pr_tax.other_excise
        ||', CVD:'||pr_tax.cvd ||', Addl. CVD: '|| pr_tax.addl_cvd||', EntryType:'||p_register_entry_type ||', PrcSta:'||p_process_status
      );
    end if;

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.23_part_i', 'START'); /* 1 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_statement_id := '2';
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */

    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    ln_customer_id      := r_base_trx.customer_id;
    ln_customer_site_id := r_base_trx.customer_site_id;

    lv_statement_id := '3';
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    IF r_base_trx.po_header_id IS NOT NULL THEN
      OPEN c_po_header(r_base_trx.po_header_id);
      FETCH c_po_header INTO r_po_header;
      CLOSE c_po_header;
    END IF;

    IF r_base_trx.source_document_code = 'REQ' THEN
      lv_statement_id := '4';
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      OPEN c_source_orgn_loc( r_base_trx.shipment_header_id, r_base_trx.requisition_line_id);
      FETCH c_source_orgn_loc INTO ln_vendor_id, ln_vendor_site_id;
      CLOSE c_source_orgn_loc;

      ln_vendor_id      := -ln_vendor_id;
      ln_vendor_site_id := -ln_vendor_site_id;

    ELSE
      lv_statement_id := '5';
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */

      -- Vijay Shankar for Bug#3940588
      get_changed_vendor_dtls(
        p_receive_trx_id      => r_trx.tax_transaction_id,
        p_shipment_line_id    => r_trx.shipment_line_id,
        p_vendor_id           => ln_vendor_id,
        p_vendor_site_id      => ln_vendor_site_id
      );

      ln_vendor_id      := nvl(ln_vendor_id, r_base_trx.vendor_id);
      ln_vendor_site_id := nvl(ln_vendor_site_id, r_base_trx.vendor_site_id);
    END IF;

    IF r_base_trx.source_document_code = 'RMA' THEN

      IF ln_customer_site_id IS NULL THEN
        /*OPEN c_base_trx( jai_rcv_trx_processing_pkg.get_ancestor_id(
                            p_transaction_id     => r_trx.transaction_id,
                            p_shipment_line_id   => r_trx.shipment_line_id,
                            p_required_trx_type  => 'RECEIVE'
                         )
                       );*/
        OPEN c_base_trx(r_trx.tax_transaction_id);
        FETCH c_base_trx INTO r_parent_base_trx;
        CLOSE c_base_trx;

        ln_customer_site_id := r_parent_base_trx.customer_site_id;
      END IF;
    END IF;

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    IF p_register_entry_type = CENVAT_DEBIT THEN
      ln_entry_type := -1;
    END IF;

    lv_excise_invoice_no    := r_trx.excise_invoice_no;
    ld_excise_invoice_date  := r_trx.excise_invoice_date;

    lv_statement_id := '6';
    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
    ln_quantity           := r_trx.quantity * ln_entry_type;
    ln_basic_ed           := pr_tax.basic_excise * ln_entry_type;
    ln_additional_ed      := (pr_tax.addl_excise + pr_tax.cvd) * ln_entry_type;
    ln_additional_cvd      := pr_tax.addl_cvd  * ln_entry_type;  -- Date 06/04/2007 by sacsethi for bug 6109941
    ln_other_ed           := pr_tax.other_excise * ln_entry_type;

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'Before call to jai_cmn_rg_23ac_i_trxs_pkg.insert_row');
    end if;

    lv_statement_id := '7';
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    jai_cmn_rg_23ac_i_trxs_pkg.insert_row(
        p_register_id                   => p_register_id,
        p_inventory_item_id             => r_trx.inventory_item_id,
        p_organization_id               => r_trx.organization_id,
        p_quantity_received             => ln_quantity,
        p_receipt_id                    => r_trx.transaction_id,
        p_transaction_type              => lv_transaction_type,
        p_receipt_date                  => r_trx.transaction_date,      -- Why cant this be ShipmentHeader.Receipt_date
        p_po_header_id                  => r_base_trx.po_header_id,
        p_po_header_date                => r_po_header.creation_date,
        p_po_line_id                    => r_base_trx.po_line_id,
        p_po_line_location_id           => r_base_trx.po_line_location_id,
        p_vendor_id                     => ln_vendor_id,
        p_vendor_site_id                => ln_vendor_site_id,
        p_customer_id                   => ln_customer_id,
        p_customer_site_id              => ln_customer_site_id,
        p_goods_issue_id                => NULL,
        p_goods_issue_date              => NULL,
        p_goods_issue_quantity          => NULL,
        p_sales_invoice_id              => NULL,
        p_sales_invoice_date            => NULL,
        p_sales_invoice_quantity        => NULL,
        p_excise_invoice_id             => lv_excise_invoice_no,
        p_excise_invoice_date           => ld_excise_invoice_date,
        p_oth_receipt_quantity          => NULL,
        p_oth_receipt_id                => NULL,
        p_oth_receipt_date              => NULL,
        p_register_type                 => jai_general_pkg.get_rg_register_type(p_item_class => r_trx.item_class),
        p_identification_no             => NULL,
        p_identification_mark           => NULL,
        p_brand_name                    => NULL,
        p_date_of_verification          => NULL,
        p_date_of_installation          => NULL,
        p_date_of_commission            => NULL,
        p_regiser_id_part_ii            => NULL,
        p_place_of_install              => NULL,
        p_remarks                       => NULL,
        p_location_id                   => r_trx.location_id,
        p_transaction_uom_code          => r_trx.uom_code,
        p_transaction_date              => r_trx.transaction_date,
        p_basic_ed                      => ln_basic_ed,
        p_additional_ed                 => ln_additional_ed,
        p_additional_cvd                => ln_additional_cvd,     -- Date 30/10/2006 Bug 5228046 added by sacsethi
        p_other_ed                      => ln_other_ed,
        p_charge_account_id             => NULL,
        p_transaction_source            => r_base_trx.source_document_code,
        p_called_from                   => 'CENVAT_RG_PKG.rg23_part_i_entry',
        p_simulate_flag                 => p_simulate_flag,
        p_process_status                => p_process_status,
        p_process_message               => p_process_message
    );

    /*bgowrava for forward porting Bug#5756676..start*/

			UPDATE JAI_RCV_TRANSACTIONS
				 SET quantity_register_flag  = 'Y',
						 last_updated_by         = fnd_global.user_id,
						 last_update_date        = sysdate,
						 last_update_login       = fnd_global.login_id
			 WHERE transaction_id          = p_transaction_id ;

		  FND_FILE.put_line(FND_FILE.log, 'Updating quantity register flag to Y');

  /*bgowrava for forward porting Bug#5756676..end*/

    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath, null, 'END'); /* 8 */

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.rg23_part_i_entry->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END rg23_part_i_entry;

  PROCEDURE rg23_d_entry(
    p_transaction_id    IN NUMBER,
    pr_tax                IN  TAX_BREAKUP,
    p_register_entry_type       IN VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag     IN VARCHAR2,
    p_codepath          IN OUT NOCOPY VARCHAR2
  ) IS

    CURSOR c_rma_tax_rate(cp_oe_order_line_id IN NUMBER) IS
      SELECT rel.excise_duty_rate
      FROM JAI_OM_OE_RMA_LINES rel
      WHERE rel.rma_line_id = cp_oe_order_line_id;

    CURSOR c_parent_register_id(cp_receipt_id IN NUMBER, cp_transaction_id IN NUMBER) IS
      SELECT register_id
      FROM JAI_CMN_RG_23D_TRXS
      WHERE receipt_ref = cp_receipt_id
      ANd transaction_source_num = cp_transaction_id;

    CURSOR c_tax_rate(cp_shipment_line_id IN NUMBER) IS
      SELECT tax_rate
      FROM JAI_RCV_LINE_TAXES
      WHERE shipment_line_id = cp_shipment_line_id
      AND tax_type IN (jai_constants.tax_type_excise,
                       jai_constants.tax_type_exc_additional,
                       jai_constants.tax_type_exc_other,
		       jai_constants.tax_type_cvd,
		       jai_constants.tax_type_add_cvd)
      --AND upper(tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD')
      -- we need not include the CESS here, because the rate should correspond to actual tax instead of cess
      ORDER BY tax_line_no;

    r_trx                     c_trx%ROWTYPE;
    r_base_trx                c_base_trx%ROWTYPE;

    ln_register_id            JAI_CMN_RG_23D_TRXS.register_id%TYPE;
    ln_vendor_id              RCV_TRANSACTIONS.vendor_id%TYPE;
    ln_vendor_site_id         RCV_TRANSACTIONS.vendor_site_id%TYPE;
    lv_excise_invoice_no      JAI_CMN_RG_23D_TRXS.comm_invoice_no%TYPE;
    ld_excise_invoice_date    JAI_CMN_RG_23D_TRXS.comm_invoice_date%TYPE;
    ln_excise_duty_rate       JAI_CMN_RG_23D_TRXS.excise_duty_rate%TYPE;
    lv_transaction_type       RCV_TRANSACTIONS.transaction_type%TYPE;
    lv_transaction_uom_code   MTL_UNITS_OF_MEASURE.uom_code%TYPE;
    ln_customer_id            RCV_TRANSACTIONS.customer_id%TYPE;
    ln_customer_site_id       RCV_TRANSACTIONS.customer_site_id%TYPE;
    r_parent_base_trx         c_base_trx%ROWTYPE;

    ln_entry_type             NUMBER;   --File.Sql.35 Cbabu  := 1;
    ln_basic_ed               NUMBER;
    ln_additional_ed          NUMBER;
    ln_other_ed               NUMBER;
    ln_additional_cvd         NUMBER;    -- Date 30/10/2006 Bug 5228046 added by sacsethi
    ln_cvd                    NUMBER;
    ln_duty_amount            NUMBER;
    ln_quantity_received      NUMBER;
    ln_qty_to_adjust          NUMBER;

    ln_ancestor_reg_id        JAI_CMN_RG_23D_TRXS.register_id%TYPE;
    ln_ancestor_trxn_id       RCV_TRANSACTIONS.transaction_id%TYPE;

    lv_statement_id           VARCHAR2(5);

    ln_other_tax_debit        NUMBER;
    ln_other_tax_credit       NUMBER;

  BEGIN

    ln_entry_type := 1;

    if lb_rg_debug then

    -- Date 30/10/2006 Bug 5228046 added by sacsethi
      FND_FILE.put_line(FND_FILE.log,'^ RG23_D_Entry. Basic:'||pr_tax.basic_excise
        ||', Addl:'||pr_tax.addl_excise||', Other:'||pr_tax.other_excise
        ||', CVD:'||pr_tax.cvd||', Addl. CVD:'||pr_tax.addl_cvd||', EntryType:'||p_register_entry_type ||', PrcSta:'||p_process_status
      );
    end if;

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.23_d', 'START'); /* 1 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_statement_id := '2';
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    ln_customer_id      := r_base_trx.customer_id;
    ln_customer_site_id := r_base_trx.customer_site_id;

    IF r_base_trx.source_document_code = 'REQ' THEN
      lv_statement_id := '3';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      OPEN c_source_orgn_loc( r_base_trx.shipment_header_id, r_base_trx.requisition_line_id);
      FETCH c_source_orgn_loc INTO ln_vendor_id, ln_vendor_site_id;
      CLOSE c_source_orgn_loc;

      ln_vendor_id      := -ln_vendor_id;
      ln_vendor_site_id := -ln_vendor_site_id;

    ELSE
      ln_vendor_id      := r_base_trx.vendor_id;
      ln_vendor_site_id := r_base_trx.vendor_site_id;
    END IF;

    lv_excise_invoice_no    := r_trx.excise_invoice_no;
    ld_excise_invoice_date  := r_trx.excise_invoice_date;

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    IF r_base_trx.source_document_code = 'RMA' THEN
      lv_statement_id := '4';
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      OPEN c_rma_tax_rate(r_base_trx.oe_order_line_id);
      FETCH c_rma_tax_rate INTO ln_excise_duty_rate;
      CLOSE c_rma_tax_rate;

      IF ln_customer_site_id IS NULL THEN
        /*OPEN c_base_trx( jai_rcv_trx_processing_pkg.get_ancestor_id
                              (p_transaction_id     => r_trx.transaction_id,
                               p_shipment_line_id   => r_trx.shipment_line_id,
                               p_required_trx_type  => 'RECEIVE')
                       );*/
        OPEN c_base_trx(r_trx.tax_transaction_id);
        FETCH c_base_trx INTO r_parent_base_trx;
        CLOSE c_base_trx;

        ln_customer_site_id := r_parent_base_trx.customer_site_id;
      END IF;

    ELSE
      lv_statement_id := '4.1';
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      OPEN c_tax_rate(r_trx.shipment_line_id);
      FETCH c_tax_rate INTO ln_excise_duty_rate;
      CLOSE c_tax_rate;
    END IF;

    lv_statement_id := '5';
    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
    lv_transaction_uom_code := r_trx.uom_code;

    IF p_register_entry_type = CENVAT_DEBIT THEN
      ln_entry_type := -1;
      ln_other_tax_debit    := pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess+nvl(pr_tax.sh_exc_edu_cess,0)+ nvl(pr_tax.sh_cvd_edu_cess,0);/*added pr_tax.sh_exc_edu_cess + pr_tax.sh_cvd_edu_cess by vkaranam for budget 07 impact - bug#5989740*/
    ELSIF p_register_entry_type = CENVAT_CREDIT THEN
      ln_entry_type := 1;
      ln_other_tax_credit   := pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess+nvl(pr_tax.sh_exc_edu_cess,0)+ nvl(pr_tax.sh_cvd_edu_cess,0);/*added pr_tax.sh_exc_edu_cess + pr_tax.sh_cvd_edu_cess by vkaranam for budget 07 impact - bug#5989740*/
    END IF;

    ln_quantity_received  := r_trx.quantity * ln_entry_type;
    ln_qty_to_adjust      := ln_quantity_received;

    ln_basic_ed           := pr_tax.basic_excise * ln_entry_type;

    /* Bug 4516667. Added by Lakshmi.
     Removed CVD from additional amount. This is accidentally added to
     additional excise */

    ln_additional_ed      := pr_tax.addl_excise  * ln_entry_type;
    ln_other_ed           := pr_tax.other_excise * ln_entry_type;
    ln_cvd                := pr_tax.cvd * ln_entry_type;

    -- Date 30/10/2006 Bug 5228046 added by sacsethi
    -- START BUG 5228046
    ln_additional_cvd     := pr_tax.addl_cvd * ln_entry_type;
    ln_duty_amount        := ln_basic_ed + ln_additional_ed + ln_other_ed + ln_cvd; /*addl. CVD excluded for bug 5752026 (FP for bug 5747435)*/
    -- END BUG 5228046

    IF ln_qty_to_adjust < 0 OR lv_transaction_type = 'RETURN TO VENDOR' THEN
      ln_qty_to_adjust := 0;
    END IF;

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'Calling jai_cmn_rg_23d_trxs_pkg.insert_row');
    end if;

    lv_statement_id := '6';
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    jai_cmn_rg_23d_trxs_pkg.insert_row(
        p_register_id                   => p_register_id,
        p_organization_id               => r_trx.organization_id,
        p_location_id                   => r_trx.location_id,
        p_transaction_type              => lv_transaction_type,
        p_receipt_id                    => p_transaction_id,
        p_quantity_received             => ln_quantity_received,
        p_inventory_item_id             => r_trx.inventory_item_id,
        p_subinventory                  => r_base_trx.subinventory,
        p_reference_line_id             => r_trx.shipment_line_id,
        p_transaction_uom_code          => lv_transaction_uom_code,
        p_customer_id                   => ln_customer_id,
        p_bill_to_site_id               => NULL,
        p_ship_to_site_id               => ln_customer_site_id,
        p_quantity_issued               => NULL,
        p_register_code                 => NULL,
        p_released_date                 => NULL,
        p_comm_invoice_no               => lv_excise_invoice_no,
        p_comm_invoice_date             => ld_excise_invoice_date,
        p_receipt_boe_num               => jai_general_pkg.get_matched_boe_no(p_transaction_id),
        p_oth_receipt_id                => NULL,
        p_oth_receipt_date              => NULL,
        p_oth_receipt_quantity          => NULL,
        p_remarks                       => 'Live-Trx/PrntTrx:'||r_trx.transaction_id||'/'||r_trx.parent_transaction_id,
        p_qty_to_adjust                 => ln_qty_to_adjust,
        /* Bug 4516667.
         As per discussion with Vikram and Gadde rounding to 4 decimal places
	 for rate per unit */
        p_rate_per_unit                 => round(ln_duty_amount/ln_quantity_received,4),
        p_excise_duty_rate              => ln_excise_duty_rate,
        p_charge_account_id             => NULL,    -- this will be updated later by calling update procedure
        p_duty_amount                   => ln_duty_amount,
        p_receipt_date                  => r_trx.transaction_date,
        p_goods_issue_id                => NULL,
        p_goods_issue_date              => NULL,
        p_goods_issue_quantity          => NULL,
        p_transaction_date              => r_trx.transaction_date,
        p_basic_ed                      => ln_basic_ed,
        p_additional_ed                 => ln_additional_ed,
        p_additional_cvd                => ln_additional_cvd,  -- Date 30/10/2006 Bug 5228046 added by sacsethi
        p_other_ed                      => ln_other_ed,
        p_cvd                           => ln_cvd,
        p_vendor_id                     => ln_vendor_id,
        p_vendor_site_id                => ln_vendor_site_id,
        p_receipt_num                   => r_trx.receipt_num,
        p_attribute1                    => NULL,
        p_attribute2                    => NULL,
        p_attribute3                    => NULL,
        p_attribute4                    => NULL,
        p_attribute5                    => NULL,
        p_consignee                     => NULL,
        p_manufacturer_name             => NULL,
        p_manufacturer_address          => NULL,
        p_manufacturer_rate_amt_per_un  => NULL,
        p_qty_received_from_manufactur  => NULL,
        p_tot_amt_paid_to_manufacturer  => NULL,
        p_other_tax_credit              => ln_other_tax_credit,
        p_other_tax_debit               => ln_other_tax_debit,
        p_transaction_source            => r_base_trx.source_document_code,
        p_called_from                   => 'CENVAT_RG_PKG.rg23_d_entry',
        p_simulate_flag                 => p_simulate_flag,
        p_process_status                => p_process_status,
        p_process_message               => p_process_message
    );

    p_codepath := jai_general_pkg.plot_codepath(7.1, p_codepath);
    lv_statement_id := '6.1';
    -- Vijay Shankar for Bug#3940588 EDUCATION CESS
    IF pr_tax.excise_edu_cess <> 0 THEN
      IF p_register_entry_type = CENVAT_DEBIT THEN
        ln_other_tax_debit  := pr_tax.excise_edu_cess;
      ELSE
        ln_other_tax_credit := pr_tax.excise_edu_cess;
      END IF;
      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
          p_source_register     => jai_constants.reg_rg23d,
          p_source_register_id  => p_register_id,
          p_tax_type            => jai_constants.tax_type_exc_edu_cess,
          p_credit              => ln_other_tax_credit,
          p_debit               => ln_other_tax_debit,
          p_process_status      => p_process_status,
          p_process_message     => p_process_message
       );
    END IF;

    lv_statement_id := '6.2';
    p_codepath := jai_general_pkg.plot_codepath(7.2, p_codepath);

    IF pr_tax.cvd_edu_cess <> 0 THEN
      IF p_register_entry_type = CENVAT_DEBIT THEN
        ln_other_tax_debit  := pr_tax.cvd_edu_cess;
      ELSE
        ln_other_tax_credit := pr_tax.cvd_edu_cess;
      END IF;
      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
          p_source_register     => jai_constants.reg_rg23d,
          p_source_register_id  => p_register_id,
          p_tax_type            => jai_constants.tax_type_cvd_edu_cess,
          p_credit              => ln_other_tax_credit,
          p_debit               => ln_other_tax_debit,
          p_process_status      => p_process_status,
          p_process_message     => p_process_message
       );
    END IF;
 /*added the following by vkaranam for budget 07 impact - bug#5989740*/
  --start
  lv_statement_id := '6.3';
	p_codepath := jai_general_pkg.plot_codepath(7.3, p_codepath);

	 IF pr_tax.sh_exc_edu_cess <> 0 THEN
	    IF p_register_entry_type = CENVAT_DEBIT THEN
	      ln_other_tax_debit  := pr_tax.sh_exc_edu_cess;
	    ELSE
	      ln_other_tax_credit := pr_tax.sh_exc_edu_cess;
	    END IF;

	    jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
	        p_source_register     => jai_constants.reg_rg23d,
	        p_source_register_id  => p_register_id,
	        p_tax_type            => jai_constants.tax_type_sh_exc_edu_cess,
	        p_credit              => ln_other_tax_credit,
	        p_debit               => ln_other_tax_debit,
	        p_process_status      => p_process_status,
	        p_process_message     => p_process_message
	     );
  END IF;

  lv_statement_id := '6.4';
	p_codepath := jai_general_pkg.plot_codepath(7.4, p_codepath);

	 IF pr_tax.sh_cvd_edu_cess <> 0 THEN
			IF p_register_entry_type = CENVAT_DEBIT THEN
				ln_other_tax_debit  := pr_tax.sh_cvd_edu_cess;
			ELSE
				ln_other_tax_credit := pr_tax.sh_cvd_edu_cess;
			END IF;
			  jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
					p_source_register     => jai_constants.reg_rg23d,
					p_source_register_id  => p_register_id,
					p_tax_type            => jai_constants.tax_type_sh_cvd_edu_cess,
					p_credit              => ln_other_tax_credit,
					p_debit               => ln_other_tax_debit,
					p_process_status      => p_process_status,
					p_process_message     => p_process_message
 			 );
	END IF;
	--end bug#5989740


    lv_statement_id := '6.5';
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */

    -- following code to update parent RG23D entry with transaction qty
    IF lv_transaction_type = 'RETURN TO VENDOR' OR ln_quantity_received < 0 THEN
      FND_FILE.put_line(FND_FILE.log, 'To Update Qty_To_Adjust field of RG23D Table' );

      lv_statement_id := '7';
      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
      ln_quantity_received  := nvl(r_base_trx.primary_quantity, r_base_trx.quantity);

      -- this is to reduce main RG23D entry of RECEIVE transaction incase of -ve RECEIVE Correction
      IF lv_transaction_type = 'RECEIVE' THEN
        ln_quantity_received := -ln_quantity_received;
      END IF;

      ln_ancestor_trxn_id   := jai_rcv_trx_processing_pkg.get_ancestor_id(
                                  p_transaction_id    => r_trx.transaction_id,
                                  p_shipment_line_id  => r_trx.shipment_line_id,
                                  p_required_trx_type => 'RECEIVE'
                               );

      lv_statement_id := '8';
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
      OPEN c_parent_register_id(ln_ancestor_trxn_id, 18);
      FETCH c_parent_register_id INTO ln_ancestor_reg_id;
      CLOSE c_parent_register_id;

      if lb_rg_debug then
        FND_FILE.put_line(FND_FILE.log,'Calling jai_cmn_rg_23d_trxs_pkg.update_qty_to_adjust');
      end if;

      lv_statement_id := '9';
      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
      jai_cmn_rg_23d_trxs_pkg.update_qty_to_adjust(
          p_register_id     => ln_ancestor_reg_id,
          p_quantity        => ln_quantity_received ,
          p_simulate_flag   => p_simulate_flag,
          p_process_status  => p_process_status,
          p_process_message => p_process_message
      );

    END IF;

    p_codepath := jai_general_pkg.plot_codepath(12, p_codepath, null, 'END'); /* 12 */

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.rg23_d_entry->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END rg23_d_entry;

  PROCEDURE rg23_part_ii_entry(
    p_transaction_id        IN        NUMBER,
    pr_tax                  IN        TAX_BREAKUP,
    p_part_i_register_id    IN        NUMBER,
    p_register_entry_type   IN        VARCHAR2,
    p_reference_num         IN        VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag         IN        VARCHAR2,
    p_codepath              IN OUT NOCOPY VARCHAR2
  ) IS

    r_trx                     c_trx%ROWTYPE;
    r_base_trx                c_base_trx%ROWTYPE;
    r_parent_trx              c_trx%ROWTYPE;

   r_rtv_trx                 c_trx%ROWTYPE;/*vkaranam for bug#4767479*/
  ln_reference_num          NUMBER ;/*vkaranam for bug#4767479*/
  lv_exc_flag               VARCHAR2 (1);/*vkaranam for bug#4767479*/

    ln_register_id            JAI_CMN_RG_23AC_II_TRXS.register_id%TYPE;
    ln_vendor_id              RCV_TRANSACTIONS.vendor_id%TYPE;
    ln_vendor_site_id         RCV_TRANSACTIONS.vendor_site_id%TYPE;
    lv_transaction_type       RCV_TRANSACTIONS.transaction_type%TYPE;
    lv_excise_invoice_no      JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE;
    ld_excise_invoice_date    JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE;
    ln_customer_id            RCV_TRANSACTIONS.customer_id%TYPE;
    ln_customer_site_id       RCV_TRANSACTIONS.customer_site_id%TYPE;
    r_parent_base_trx         c_base_trx%ROWTYPE;

    ln_cr_basic               JAI_CMN_RG_23AC_II_TRXS.cr_basic_ed%TYPE;
    ln_cr_addl                JAI_CMN_RG_23AC_II_TRXS.cr_additional_ed%TYPE;
    ln_cr_other               JAI_CMN_RG_23AC_II_TRXS.cr_other_ed%TYPE;
    ln_dr_basic               JAI_CMN_RG_23AC_II_TRXS.dr_basic_ed%TYPE;
    ln_dr_addl                JAI_CMN_RG_23AC_II_TRXS.dr_additional_ed%TYPE;
    ln_dr_other               JAI_CMN_RG_23AC_II_TRXS.dr_other_ed%TYPE;

-- Date 04/06/2007 by sacsethi for bug 5228046
    ln_cr_addl_cvd            JAI_CMN_RG_23AC_II_TRXS.cr_additional_cvd%TYPE;
    ln_dr_addl_cvd            JAI_CMN_RG_23AC_II_TRXS.dr_additional_cvd%TYPE;


    lv_statement_id           VARCHAR2(5);
    ln_other_tax_credit       NUMBER;
    ln_other_tax_debit        NUMBER;
    lv_register_type          JAI_CMN_RG_23AC_II_TRXS.register_type%TYPE;
    lv_source_register        JAI_CMN_RG_OTHERS.source_register%TYPE;

  BEGIN

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'^ RG23_PART_II_Entry. Basic:'||pr_tax.basic_excise
        ||', Addl:'||pr_tax.addl_excise||', Other:'||pr_tax.other_excise
        ||', CVD:'||pr_tax.cvd||', ExCes:'||pr_tax.excise_edu_cess||', CvdCes:'||pr_tax.cvd_edu_cess
        ||', EntryType:'||p_register_entry_type ||', PrcSta:'||p_process_status
        ||', Part1Id:'||p_part_i_register_id||', RefNo:'||p_reference_num
      );
    end if;

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.23_part_ii', 'START'); /* 1 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_statement_id := '2';
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    ln_customer_id      := r_base_trx.customer_id;
    ln_customer_site_id := r_base_trx.customer_site_id;

    IF r_base_trx.source_document_code = 'REQ' THEN
      lv_statement_id := '3';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      OPEN c_source_orgn_loc( r_base_trx.shipment_header_id, r_base_trx.requisition_line_id);
      FETCH c_source_orgn_loc INTO ln_vendor_id, ln_vendor_site_id;
      CLOSE c_source_orgn_loc;

      ln_vendor_id      := -ln_vendor_id;
      ln_vendor_site_id := -ln_vendor_site_id;

    ELSE

      -- Vijay Shankar for Bug#3940588
      get_changed_vendor_dtls(
        p_receive_trx_id      => r_trx.tax_transaction_id,
        p_shipment_line_id    => r_trx.shipment_line_id,
        p_vendor_id           => ln_vendor_id,
        p_vendor_site_id      => ln_vendor_site_id
      );

      ln_vendor_id      := nvl(ln_vendor_id, r_base_trx.vendor_id);
      ln_vendor_site_id := nvl(ln_vendor_site_id, r_base_trx.vendor_site_id);

    END IF;

    IF r_base_trx.source_document_code = 'RMA' THEN
      IF ln_customer_site_id IS NULL THEN
        /*OPEN c_base_trx( jai_rcv_trx_processing_pkg.get_ancestor_id
                              (p_transaction_id     => r_trx.transaction_id,
                               p_shipment_line_id   => r_trx.shipment_line_id,
                               p_required_trx_type  => 'RECEIVE')
                       );*/
        OPEN c_base_trx(r_trx.tax_transaction_id);
        FETCH c_base_trx INTO r_parent_base_trx;
        CLOSE c_base_trx;

        ln_customer_site_id := r_parent_base_trx.customer_site_id;
      END IF;
    END IF;

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    -- p_reference_num will contain parent RECEIVE trx_id incase of PARENT REGULAR 50% that is passed during RTV of CGIN item
    IF lv_transaction_type = 'RETURN TO VENDOR' AND p_reference_num IN (CGIN_FIRST_CLAIM, CGIN_SECOND_CLAIM) THEN
      OPEN c_trx(to_number(p_reference_num));
      FETCH c_trx INTO r_parent_trx;
      CLOSE c_trx;
      lv_excise_invoice_no    := r_parent_trx.excise_invoice_no;
      ld_excise_invoice_date  := r_parent_trx.excise_invoice_date;
 ELSIF lv_transaction_type = 'RECEIVE' AND p_reference_num IS NOT NULL THEN /*elsif added by vkaranam for bug#4767479*/
    /*p_reference_num would have the transaction id of Return to Vendor in case of Partial RTV auto claim record*/

    BEGIN
      ln_reference_num := to_number(p_reference_num);
      lv_exc_flag      := 'A'; /*A indiactes auto claim for RTV*/
      FND_FILE.put_line(FND_FILE.log,'p_reference_num:'||p_reference_num);
    EXCEPTION
      WHEN OTHERS THEN
        /*this exception would come if p_reference_num does not contain a number. It means p_reference_num is not having any transaction_id
         This means this transaction belongs to normal RECEIVE transaction*/
        lv_exc_flag      := 'C'; /*C indicates claim for Receipt transaction*/
        FND_FILE.put_line(FND_FILE.log,'Exception '||sqlerrm||' occurred and is handled');
        FND_FILE.put_line(FND_FILE.log,'p_reference_num:'||p_reference_num);
    END;
    IF lv_exc_flag = 'A' THEN
      OPEN c_trx(ln_reference_num);
      FETCH c_trx INTO r_rtv_trx;
      CLOSE c_trx;
      IF r_rtv_trx.transaction_type = 'RETURN TO VENDOR' THEN
        lv_excise_invoice_no    := r_trx.excise_invoice_no||'/1';
        ld_excise_invoice_date  := r_trx.excise_invoice_date;
      ELSE
        lv_excise_invoice_no    := r_trx.excise_invoice_no;
        ld_excise_invoice_date  := r_trx.excise_invoice_date;
      END IF ;
    ELSIF lv_exc_flag = 'C' THEN
      lv_excise_invoice_no    := r_trx.excise_invoice_no;
      ld_excise_invoice_date  := r_trx.excise_invoice_date;
    END IF ;
   --end additions for bug#4767479
    ELSE
      lv_excise_invoice_no    := r_trx.excise_invoice_no;
      ld_excise_invoice_date  := r_trx.excise_invoice_date;
    END IF;

    lv_statement_id := '4';
    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
    IF p_register_entry_type = CENVAT_DEBIT THEN
      ln_dr_basic   := pr_tax.basic_excise;
      ln_dr_addl    := pr_tax.addl_excise + pr_tax.cvd;
      ln_dr_other   := pr_tax.other_excise;
      ln_dr_addl_cvd := pr_tax.addl_cvd; --Date 30/10/2006 Bug 5228046 added by sacsethi
      ln_other_tax_debit  := pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess + nvl(pr_tax.sh_exc_edu_cess,0)+ nvl(pr_tax.sh_cvd_edu_cess,0); --Bgowrava for Bug #6071509 ,Added SH related cess
    ELSE
      ln_cr_basic   := pr_tax.basic_excise;
      ln_cr_addl    := pr_tax.addl_excise + pr_tax.cvd;
      ln_cr_other   := pr_tax.other_excise;
      ln_cr_addl_cvd := pr_tax.addl_cvd; --Date 30/10/2006 Bug 5228046 added by sacsethi
      ln_other_tax_credit := pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess+ nvl(pr_tax.sh_exc_edu_cess,0)+ nvl(pr_tax.sh_cvd_edu_cess,0); --Bgowrava for Bug #6071509 ,Added SH related cess
    END IF;

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'Calling jai_cmn_rg_23ac_ii_pkg.insert_row');
    end if;

    lv_register_type := jai_general_pkg.get_rg_register_type(r_trx.item_class);
    if lv_register_type = jai_constants.register_type_a then
      lv_source_register := jai_constants.reg_rg23a_2;
    else
      lv_source_register := jai_constants.reg_rg23c_2;
    end if;

    lv_statement_id := '5';
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    jai_cmn_rg_23ac_ii_pkg.insert_row(
        p_register_id                   => p_register_id,
        p_inventory_item_id             => r_trx.inventory_item_id,
        p_organization_id               => r_trx.organization_id,
        p_receipt_id                    => r_trx.transaction_id,
        p_receipt_date                  => r_trx.transaction_date,
        p_cr_basic_ed                   => ln_cr_basic,
        p_cr_additional_ed              => ln_cr_addl,
        p_cr_additional_cvd              => ln_cr_addl_cvd,  -- Date 30/10/2006 Bug 5228046 added by sacsethi
        p_cr_other_ed                   => ln_cr_other,
        p_dr_basic_ed                   => ln_dr_basic,
        p_dr_additional_ed              => ln_dr_addl,
        p_dr_additional_cvd              => ln_dr_addl_cvd, -- Date 30/10/2006 Bug 5228046 added by sacsethi
        p_dr_other_ed                   => ln_dr_other,
        p_excise_invoice_no             => lv_excise_invoice_no,
        p_excise_invoice_date           => ld_excise_invoice_date,
        p_register_type                 => lv_register_type,
        p_remarks                       => 'Live-Trx/PrntTrx:'||r_trx.transaction_id||'/'||r_trx.parent_transaction_id,
        p_vendor_id                     => ln_vendor_id,
        p_vendor_site_id                => ln_vendor_site_id,
        p_customer_id                   => ln_customer_id,
        p_customer_site_id              => ln_customer_site_id,
        p_location_id                   => r_trx.location_id,
        p_transaction_date              => SYSDATE, --r_trx.transaction_date, --Changed by Sanjikum for Bug #4293421
        p_charge_account_id             => NULL,
        p_register_id_part_i            => p_part_i_register_id,
        p_reference_num                 => p_reference_num,
        p_rounding_id                   => NULL,
        p_other_tax_credit              => ln_other_tax_credit,
        p_other_tax_debit               => ln_other_tax_debit,
        p_transaction_type              => lv_transaction_type,
        p_transaction_source            => r_base_trx.source_document_code,
        p_called_from                   => 'CENVAT_RG_PKG.rg23_part_ii_entry',
        p_simulate_flag                 => p_simulate_flag,
        p_process_status                => p_process_status,
        p_process_message               => p_process_message
    );

    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath);

    -- Vijay Shankar for Bug#3940588 EDUCATION CESS
    IF pr_tax.excise_edu_cess <> 0 THEN
      IF p_register_entry_type = CENVAT_DEBIT THEN
        ln_other_tax_debit  := pr_tax.excise_edu_cess;
      ELSE
        ln_other_tax_credit := pr_tax.excise_edu_cess;
      END IF;
      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
          p_source_register     => lv_source_register,
          p_source_register_id  => p_register_id,
          p_tax_type            => jai_constants.tax_type_exc_edu_cess,
          p_credit              => ln_other_tax_credit,
          p_debit               => ln_other_tax_debit,
          p_process_status      => p_process_status,
          p_process_message     => p_process_message
       );
    END IF;

    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);

    IF pr_tax.cvd_edu_cess <> 0 THEN
      IF p_register_entry_type = CENVAT_DEBIT THEN
        ln_other_tax_debit  := pr_tax.cvd_edu_cess;
      ELSE
        ln_other_tax_credit := pr_tax.cvd_edu_cess;
      END IF;
      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
          p_source_register     => lv_source_register,
          p_source_register_id  => p_register_id,
          p_tax_type            => jai_constants.tax_type_cvd_edu_cess,
          p_credit              => ln_other_tax_credit,
          p_debit               => ln_other_tax_debit,
          p_process_status      => p_process_status,
          p_process_message     => p_process_message
       );
    END IF;

    --For SH EDU CESS
    -- START,Bgowrava for Bug#6071509
    IF pr_tax.sh_exc_edu_cess <> 0 THEN
		      IF p_register_entry_type = CENVAT_DEBIT THEN
		        ln_other_tax_debit  := pr_tax.sh_exc_edu_cess;
		      ELSE
		        ln_other_tax_credit := pr_tax.sh_exc_edu_cess;
		      END IF;
		      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
		          p_source_register     => lv_source_register,
		          p_source_register_id  => p_register_id,
		          p_tax_type            => jai_constants.tax_type_sh_exc_edu_cess,
		          p_credit              => ln_other_tax_credit,
		          p_debit               => ln_other_tax_debit,
		          p_process_status      => p_process_status,
		          p_process_message     => p_process_message
		       );
		    END IF;

		    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);

		    IF pr_tax.sh_cvd_edu_cess <> 0 THEN
		      IF p_register_entry_type = CENVAT_DEBIT THEN
		        ln_other_tax_debit  := pr_tax.sh_cvd_edu_cess;
		      ELSE
		        ln_other_tax_credit := pr_tax.sh_cvd_edu_cess;
		      END IF;
		      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
		          p_source_register     => lv_source_register,
		          p_source_register_id  => p_register_id,
		          p_tax_type            => jai_constants.tax_type_sh_cvd_edu_cess,
		          p_credit              => ln_other_tax_credit,
		          p_debit               => ln_other_tax_debit,
		          p_process_status      => p_process_status,
		          p_process_message     => p_process_message
		       );
    END IF;

     -- END,Bgowrava for Bug#6071509

    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath, null, 'END');

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.rg23_part_ii_entry->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END rg23_part_ii_entry;

  PROCEDURE pla_entry(
    p_transaction_id        IN  NUMBER,
    pr_tax                  IN  TAX_BREAKUP,
    p_register_entry_type   IN  VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag         IN  VARCHAR2,
    p_codepath              IN OUT NOCOPY VARCHAR2
  ) IS

    r_trx                     c_trx%ROWTYPE;
    r_base_trx                c_base_trx%ROWTYPE;
    r_orgn_info               c_orgn_info%ROWTYPE;

    ln_register_id            JAI_CMN_RG_PLA_TRXS.register_id%TYPE;
    ln_vendor_id              RCV_TRANSACTIONS.vendor_id%TYPE;
    ln_vendor_site_id         RCV_TRANSACTIONS.vendor_site_id%TYPE;
    lv_excise_invoice_no      JAI_CMN_RG_PLA_TRXS.DR_INVOICE_NO%TYPE;
    ld_excise_invoice_date    JAI_CMN_RG_PLA_TRXS.dr_invoice_date%TYPE;
    lv_transaction_type       RCV_TRANSACTIONS.transaction_type%TYPE;

    ln_cr_basic               JAI_CMN_RG_PLA_TRXS.cr_basic_ed%TYPE;
    ln_cr_addl                JAI_CMN_RG_PLA_TRXS.cr_additional_ed%TYPE;
    ln_cr_other               JAI_CMN_RG_PLA_TRXS.cr_other_ed%TYPE;
    ln_dr_basic               JAI_CMN_RG_PLA_TRXS.dr_basic_ed%TYPE;
    ln_dr_addl                JAI_CMN_RG_PLA_TRXS.dr_additional_ed%TYPE;
    ln_dr_other               JAI_CMN_RG_PLA_TRXS.dr_other_ed%TYPE;

    lv_statement_id           VARCHAR2(5);
    ln_other_tax_credit       NUMBER;
    ln_other_tax_debit        NUMBER;

  BEGIN

    if lb_rg_debug then
    FND_FILE.put_line(FND_FILE.log,'^ PLA_Entry. Basic:'||pr_tax.basic_excise
      ||', Addl:'||pr_tax.addl_excise||', Other:'||pr_tax.other_excise||', ExCes:'||pr_tax.excise_edu_cess||', CvdCes:'||pr_tax.cvd_edu_cess
      ||', SH_ExCes:'||pr_tax.sh_exc_edu_cess||', SH_CvdCes:'||pr_tax.sh_cvd_edu_cess /*added by vkaranam for bug #5989740*/
      ||', CVD:'||pr_tax.cvd
      ||', EntryType:'||p_register_entry_type ||', PrcSta:'||p_process_status
    );
   end if;

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'^ PLA_Entry');
    end if;

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.pla', 'START'); /* 1 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_statement_id := '2';
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    IF r_base_trx.source_document_code = 'REQ' THEN
      lv_statement_id := '3';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */

      OPEN c_source_orgn_loc( r_base_trx.shipment_header_id, r_base_trx.requisition_line_id);
      FETCH c_source_orgn_loc INTO ln_vendor_id, ln_vendor_site_id;
      CLOSE c_source_orgn_loc;

      ln_vendor_id      := -ln_vendor_id;
      ln_vendor_site_id := -ln_vendor_site_id;

    ELSE

      -- Vijay Shankar for Bug#3940588
      get_changed_vendor_dtls(
        p_receive_trx_id      => r_trx.tax_transaction_id,
        p_shipment_line_id    => r_trx.shipment_line_id,
        p_vendor_id           => ln_vendor_id,
        p_vendor_site_id      => ln_vendor_site_id
      );

      ln_vendor_id      := nvl(ln_vendor_id, r_base_trx.vendor_id);
      ln_vendor_site_id := nvl(ln_vendor_site_id, r_base_trx.vendor_site_id);

    END IF;

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    lv_excise_invoice_no    := r_trx.excise_invoice_no;
    ld_excise_invoice_date  := r_trx.excise_invoice_date;

    lv_statement_id := '4';
    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
    IF p_register_entry_type = CENVAT_DEBIT THEN
      ln_dr_basic   := pr_tax.basic_excise;
      ln_dr_addl    := pr_tax.addl_excise + pr_tax.cvd;
      ln_dr_other   := pr_tax.other_excise;
     ln_other_tax_debit  := pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess+nvl(pr_tax.sh_exc_edu_cess,0)+ nvl(pr_tax.sh_cvd_edu_cess,0);/*added pr_tax.sh_exc_edu_cess + pr_tax.sh_cvd_edu_cess by vkaranam for budget 07 impact - bug#5989740*/
    ELSE
      ln_cr_basic   := pr_tax.basic_excise;
      ln_cr_addl    := pr_tax.addl_excise + pr_tax.cvd;
      ln_cr_other   := pr_tax.other_excise;
      ln_other_tax_credit  := pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess+nvl(pr_tax.sh_exc_edu_cess,0)+ nvl(pr_tax.sh_cvd_edu_cess,0);/*added pr_tax.sh_exc_edu_cess + pr_tax.sh_cvd_edu_cess by vkaranam for budget 07 impact - bug#5989740*/
    END IF;

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'Calling jai_cmn_rg_pla_trxs_pkg.insert_row');
    end if;

    lv_statement_id := '5';
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    jai_cmn_rg_pla_trxs_pkg.insert_row(
        p_register_id                   => p_register_id,
        p_tr6_challan_no                => NULL,
        p_tr6_challan_date              => NULL,
        p_cr_basic_ed                   => ln_cr_basic,
        p_cr_additional_ed              => ln_cr_addl,
        p_cr_other_ed                   => ln_cr_other,
        p_ref_document_id               => r_trx.transaction_id,
        p_ref_document_date             => r_trx.transaction_date,
        p_dr_invoice_id                 => lv_excise_invoice_no,
        p_dr_invoice_date               => ld_excise_invoice_date,
        p_dr_basic_ed                   => ln_dr_basic,
        p_dr_additional_ed              => ln_dr_addl,
        p_dr_other_ed                   => ln_dr_other,
        p_organization_id               => r_trx.organization_id,
        p_location_id                   => r_trx.location_id,
        p_bank_branch_id                => NULL,
        p_entry_date                    => NULL,
        p_inventory_item_id             => r_trx.inventory_item_id,
        p_vendor_cust_flag              => 'V',
        p_vendor_id                     => ln_vendor_id,
        p_vendor_site_id                => ln_vendor_site_id,
        p_excise_invoice_no             => lv_excise_invoice_no,
        p_remarks                       => 'Live-Trx/PrntTrx:'||r_trx.transaction_id||'/'||r_trx.parent_transaction_id,
        p_transaction_date              => r_trx.transaction_date,
        p_charge_account_id             => NULL,
        p_other_tax_credit              => ln_other_tax_credit,
        p_other_tax_debit               => ln_other_tax_debit,
        p_transaction_type              => lv_transaction_type,
        p_transaction_source            => r_base_trx.source_document_code,
        p_called_from                   => 'cenvat_RG_PKG.pla_entry',
        p_simulate_flag                 => p_simulate_flag,
        p_process_status                => p_process_status,
        p_process_message               => p_process_message
    );

    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath);

    -- Vijay Shankar for Bug#3940588 EDUCATION CESS
    IF pr_tax.excise_edu_cess <> 0 THEN
      IF p_register_entry_type = CENVAT_DEBIT THEN
        ln_other_tax_debit  := pr_tax.excise_edu_cess;
      ELSE
        ln_other_tax_credit := pr_tax.excise_edu_cess;
      END IF;
      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
          p_source_register     => jai_constants.reg_pla,
          p_source_register_id  => p_register_id,
          p_tax_type            => jai_constants.tax_type_exc_edu_cess,
          p_credit              => ln_other_tax_credit,
          p_debit               => ln_other_tax_debit,
          p_process_status      => p_process_status,
          p_process_message     => p_process_message
       );
    END IF;

    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);

    IF pr_tax.cvd_edu_cess <> 0 THEN
      IF p_register_entry_type = CENVAT_DEBIT THEN
        ln_other_tax_debit  := pr_tax.cvd_edu_cess;
      ELSE
        ln_other_tax_credit := pr_tax.cvd_edu_cess;
      END IF;
      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
          p_source_register     => jai_constants.reg_pla,
          p_source_register_id  => p_register_id,
          p_tax_type            => jai_constants.tax_type_cvd_edu_cess,
          p_credit              => ln_other_tax_credit,
          p_debit               => ln_other_tax_debit,
          p_process_status      => p_process_status,
          p_process_message     => p_process_message
       );
    END IF;

  /*added the following by vkaranam for budget 07 impact - bug#5989740*/
  --start
  p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
   IF pr_tax.sh_exc_edu_cess <> 0 THEN
	    IF p_register_entry_type = CENVAT_DEBIT THEN
	      ln_other_tax_debit  := nvl(pr_tax.sh_exc_edu_cess,0);
	    ELSE
	      ln_other_tax_credit := nvl(pr_tax.sh_exc_edu_cess,0);
	    END IF;

	    jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
	        p_source_register     => jai_constants.reg_pla,
	        p_source_register_id  => p_register_id,
	        p_tax_type            => jai_constants.tax_type_sh_exc_edu_cess,
	        p_credit              => ln_other_tax_credit,
	        p_debit               => ln_other_tax_debit,
	        p_process_status      => p_process_status,
	        p_process_message     => p_process_message
	     );
	  END IF;

	  p_codepath := jai_general_pkg.plot_codepath(9, p_codepath);

	  IF pr_tax.sh_cvd_edu_cess <> 0 THEN
	    IF p_register_entry_type = CENVAT_DEBIT THEN
	      ln_other_tax_debit  := nvl(pr_tax.sh_cvd_edu_cess,0);
	    ELSE
	      ln_other_tax_credit := nvl(pr_tax.sh_cvd_edu_cess,0);
	    END IF;
	    jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
	        p_source_register     => jai_constants.reg_pla,
	        p_source_register_id  => p_register_id,
	        p_tax_type            => jai_constants.tax_type_sh_cvd_edu_cess,
	        p_credit              => ln_other_tax_credit,
	        p_debit               => ln_other_tax_debit,
	        p_process_status      => p_process_status,
	        p_process_message     => p_process_message
	     );
	  END IF;
	  --end #5989740



    p_codepath := jai_general_pkg.plot_codepath(10, p_codepath, NULL, 'END'); /* 6 */

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.pla_entry->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END pla_entry;

  /*~~~~~~~~~~~~~~~~~~~ ACCOUNTING_ENTRIES Main Procedure for Accounting ~~~~~~~~~~~~~~~~~~~~~*/

  PROCEDURE accounting_entries(
    p_transaction_id    IN NUMBER,
    pr_tax              IN  TAX_BREAKUP,
    p_cgin_code         IN VARCHAR2,
    p_cenvat_accounting_type IN VARCHAR2,
    p_amount_register   IN VARCHAR2,
    p_cenvat_account_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag     IN VARCHAR2,
    p_codepath          IN OUT NOCOPY VARCHAR2
  , pv_retro_reference          IN VARCHAR2 DEFAULT NULL --Added by rchandan on Jan 18,2008 for retro

  ) IS

    r_trx                           c_trx%ROWTYPE;
    r_base_trx                      c_base_trx%ROWTYPE;
    r_orgn_info                     c_orgn_info%ROWTYPE;
    r_rcv_params                    c_rcv_params%ROWTYPE;

    lv_register_type                VARCHAR2(1);
    lv_transaction_type             RCV_TRANSACTIONS.transaction_type%TYPE;
    ln_total_excise_amt             NUMBER;
    ln_cenvat_claimed_ptg           NUMBER;

    lv_accnt_type                   JAI_RCV_JOURNAL_ENTRIES.acct_type%TYPE;
    lv_accnt_nature                 JAI_RCV_JOURNAL_ENTRIES.acct_nature%TYPE;

    ln_cenvat_accnt_id              NUMBER;
    ln_cenvat_balancing_accnt_id    NUMBER;
    ln_receiving_accnt_id           NUMBER;
    ln_cenvat_rcvble_accnt_id       NUMBER;
    lv_cgin_case                    VARCHAR2(100);

    ln_debit                        NUMBER;
    ln_credit                       NUMBER;
    ln_balancing_debit              NUMBER;
    ln_balancing_credit             NUMBER;

    lv_accounting_date              DATE;   --File.Sql.35 Cbabu  := trunc(SYSDATE);
    lv_reference10                  VARCHAR2(240);
    lv_message                      VARCHAR2(200);

    lv_statement_id                 VARCHAR2(5);

    ln_exc_edu_cess_accnt           NUMBER(15);
    ln_exc_edu_cess_rcvble_accnt    NUMBER(15);
    ln_total_excise_edu_cess_amt    NUMBER;
    ln_edu_cess_debit               NUMBER;
    ln_edu_cess_credit              NUMBER;
    ln_bal_edu_cess_debit           NUMBER;
    ln_bal_edu_cess_credit          NUMBER;

    /* following variables added as part of Bug#4211045 */
    ln_cess_paid_payable_accnt_id   NUMBER;
    ln_edu_cess_balancing_debit     NUMBER;
    ln_edu_cess_balancing_credit    NUMBER;
    /*added the following variables by vkaranam for budget 07 impact - bug#5989740*/
    ln_sh_cess_paid_payable_accnt   NUMBER;
    ln_sh_exc_edu_cess_accnt        NUMBER;
    ln_sh_exc_edu_cess_rcvb_accnt   NUMBER;
    ln_sh_total_exc_edu_cess_amt    NUMBER;
    ln_sh_edu_cess_debit            NUMBER;
    ln_sh_edu_cess_credit           NUMBER;
    ln_sh_edu_cess_balancin_debit  NUMBER;
    ln_sh_edu_cess_balancin_credit NUMBER;
    ln_sh_bal_edu_cess_debit       NUMBER;
    ln_sh_bal_edu_cess_credit      NUMBER;


  BEGIN

    lv_accounting_date := trunc(SYSDATE);

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb> --- 2');

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'^ Accounting Entries. CGIN Code->'||nvl(p_cgin_code, 'NULL')
      ||'. Basic:'||pr_tax.basic_excise ||', Addl:'||pr_tax.addl_excise||', Other:'||pr_tax.other_excise
      ||', ExCes:'||pr_tax.excise_edu_cess||', CvdCes:'||pr_tax.cvd_edu_cess
      --added by vkaranam fro bug #5989740
      ||', SH_ExCes:'||pr_tax.sh_exc_edu_cess||', SH_CvdCes:'||pr_tax.sh_cvd_edu_cess
      ||', CVD:'||pr_tax.cvd
      -- Bug 5143906. Added by Lakshmi Gopalsami
      ||', Addl CVD: '|| pr_tax.addl_cvd
      ||', AccntType:'||p_cenvat_accounting_type ||', PrcSta:'||p_process_status
      ||', AmtRegister:'||p_amount_register||', CGIN Code->'||nvl(p_cgin_code, 'NULL')
    );
    end if;


     fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 3');

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.accounting', 'START'); /* 1 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_statement_id := '2';
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 4');

    lv_reference10  := 'India Local Cenvat Entries for Receipt:' || r_trx.receipt_num ||'. Transaction Type '||r_trx.transaction_type;
    if r_trx.transaction_type = 'CORRECT' THEN
      lv_reference10 := lv_reference10 || ' of '||r_trx.parent_transaction_type;
    end if;

    lv_statement_id := '3';
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    IF( NVL(r_trx.cenvat_claimed_ptg, 0) = 100 AND pv_retro_reference IS NULL ) THEN--Added by eric on Jan 18,2008 for retro
      p_process_status    := 'E';
      p_process_message := 'Cenvat was fully claimed already. No more claims can happen';
      GOTO end_of_accounting;
    END IF;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 5');

    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    lv_statement_id := '4';
    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 6');

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    lv_register_type := jai_general_pkg.get_rg_register_type(r_trx.item_class);

    -- following cenvat_claimed_ptg corresponds to RECEIVE i.e parent of any other type of transaction
    -- ln_cenvat_claimed_ptg := get_receive_claimed_ptg(p_transaction_id, r_trx.shipment_line_id);

    lv_statement_id := '5';
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    OPEN c_orgn_info(r_trx.organization_id, r_trx.location_id);
    FETCH c_orgn_info INTO r_orgn_info;
    CLOSE c_orgn_info;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 7');

    OPEN c_rcv_params(r_trx.organization_id);
    FETCH c_rcv_params INTO r_rcv_params;  -- this is the default accnt and will be overriden later based on transaction requirement
    CLOSE c_rcv_params;
    ln_receiving_accnt_id := r_rcv_params.receiving_account_id;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 8');

    lv_statement_id := '5a';
    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
    IF r_trx.organization_type = 'M' THEN
      lv_statement_id := '6';
      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
      lv_accnt_nature   := 'CENVAT';
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt' THEN
      IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma then
        ln_receiving_accnt_id := r_orgn_info.excise_rcvble_account;   /* In front end this is shown as excise Paid Payable Accnt */

        /* Vijay Shankar for Bug#4211045 */
        ln_cess_paid_payable_accnt_id := r_orgn_info.cess_paid_payable_account_id;
        ln_sh_cess_paid_payable_accnt :=r_orgn_info.sh_cess_paid_payable_acct_id ;--added by vkaranam for budget 07 impact - bug#5989740
      END IF;

      IF p_amount_register = 'PLA' THEN
        ln_cenvat_accnt_id        := r_orgn_info.modvat_pla_account_id;
        ln_exc_edu_cess_accnt     := r_orgn_info.modvat_pla_account_id;          -- CHK IMPORTANT
        ln_sh_exc_edu_cess_accnt     := r_orgn_info.modvat_pla_account_id;          -- by vkaranam,bug #5989740
      ELSIF p_amount_register = 'RG23A' THEN
        ln_cenvat_accnt_id        := r_orgn_info.modvat_rm_account_id;
        ln_exc_edu_cess_accnt     := r_orgn_info.excise_edu_cess_rm_account;
        ln_sh_exc_edu_cess_accnt  := r_orgn_info.sh_cess_rm_account;--added by vkaranam for budget 07 impact - bug#5989740
      ELSIF p_amount_register = 'RG23C' THEN
        ln_cenvat_accnt_id          := r_orgn_info.modvat_cg_account_id;
        ln_exc_edu_cess_accnt       := r_orgn_info.excise_edu_cess_cg_account;
        ln_sh_exc_edu_cess_accnt       := r_orgn_info.sh_cess_cg_account_id;--added by vkaranam for budget 07 impact - bug#5989740
	-- Bug 4516678. Added by Lakshmi Gopalsami.
	-- Commented the following assignments.
        --ln_cenvat_rcvble_accnt_id   := r_orgn_info.cenvat_rcvble_account;
        --ln_exc_edu_cess_rcvble_accnt := r_orgn_info.excise_edu_cess_rcvble_accnt;
      ELSE
        -- something wrong
        NULL;
      END IF;

      /* Bug 4516678. Added by Lakshmi Gopalsami
         Added the following conditions for CGIN and CGEX type of items
      */

      IF r_trx.item_class IN ('CGIN','CGEX') THEN
        ln_cenvat_rcvble_accnt_id   := r_orgn_info.cenvat_rcvble_account;
        ln_exc_edu_cess_rcvble_accnt := r_orgn_info.excise_edu_cess_rcvble_accnt;
        ln_sh_exc_edu_cess_rcvb_accnt := r_orgn_info.sh_cess_rcvble_acct_id;--added by vkaranam for budget 07 impact - bug#5989740
      END IF ;

    ELSIF r_trx.organization_type = 'T' THEN
      lv_accnt_nature   := 'TRADING';
      ln_cenvat_accnt_id    := r_orgn_info.excise_23d_account;
      ln_exc_edu_cess_accnt := r_orgn_info.excise_23d_account;    -- CHK IMPORTANT
      ln_sh_exc_edu_cess_accnt := r_orgn_info.excise_23d_account;    -- bug #5989740
      ln_cess_paid_payable_accnt_id := r_orgn_info.excise_23d_account; -- bug #5989740
    ELSE
      -- something wrong
      fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 9');
      NULL;
    END IF;
     fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 10');

    ln_total_excise_amt := nvl(pr_tax.basic_excise,0) +
                           nvl(pr_tax.addl_excise,0)  +
			   nvl(pr_tax.other_excise,0) +
			   nvl(pr_tax.cvd,0)  +
      			   nvl(pr_tax.addl_cvd,0); --Date 30/10/2006 Bug 5228046 added by sacsethi

     fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 11');
    ln_total_excise_edu_cess_amt := nvl(pr_tax.excise_edu_cess,0) + nvl(pr_tax.cvd_edu_cess,0);
    --added by vkaranam for budget 07 impact - bug#5989740
    ln_sh_total_exc_edu_cess_amt := nvl(pr_tax.sh_exc_edu_cess,0) + nvl(pr_tax.sh_cvd_edu_cess,0);

    lv_statement_id := '7';
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
    -- IF ln_cenvat_accnt_id IS NULL THEN
    IF ln_total_excise_amt <> 0 THEN
      IF ln_cenvat_accnt_id IS NULL THEN
        IF r_trx.organization_type = 'T' THEN
          lv_message := 'Excise RG23D Account was not defined in Organization Setup';
        ELSIF p_amount_register = 'PLA' THEN
          lv_message := 'Modvat PLA Account was not defined in Organization Setup';
        ELSIF lv_register_type = 'A' THEN
          lv_message := 'Modvat RM Account was not defined in Organization Setup';
        ELSIF lv_register_type = 'C' THEN
          lv_message := 'Modvat CG Account was not defined in Organization Setup';
        ELSE
          lv_message := 'Could not derive Cenvat Account';
        END IF;

      ELSIF p_cgin_code IN ('REGULAR-HALF', 'REGULAR-FULL + REVERSAL-HALF','REGULAR-FULL-RETRO') AND ln_cenvat_rcvble_accnt_id IS NULL THEN
        lv_message := 'Cenvat Receivable Account was not defined in Organization Setup';
      END IF;
    END IF;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 12');

    IF ln_receiving_accnt_id IS NULL THEN
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt' THEN
      IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma then
        lv_message := 'Excise Receivable Account was not defined in Organization Setup';
      ELSE
        lv_message := 'Receivable Account was not defined in RCV Parameters';
      END IF;
    END IF;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 13');

    /* following Added for EDUCATION CESS by Vijay Shankar*/
    IF ln_total_excise_edu_cess_amt <> 0 THEN
      /* Vijay Shankar for Bug#4211045 */
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt'
      IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma
        AND ln_cess_paid_payable_accnt_id IS NULL
      THEN
        lv_message := 'Cess Paid/Payable Account was not defined in Organization Setup'; /* Cess meaning Excise Education Cess */
      END IF;

      IF ln_exc_edu_cess_accnt IS NULL THEN
        IF r_trx.organization_type = 'T' THEN
          lv_message := 'Excise RG23D Account was not defined in Organization Setup';
        ELSIF p_amount_register = 'PLA' THEN
          lv_message := 'Modvat PLA Account was not defined in Organization Setup';
        ELSIF lv_register_type = 'A' THEN
          lv_message := 'Excise Education Cess RM Account was not defined in Organization Setup';
        ELSIF lv_register_type = 'C' THEN
          lv_message := 'Excise Education Cess CG Account was not defined in Organization Setup';
        ELSE
          lv_message := 'Could not derive Cenvat Account';
        END IF;

      ELSIF p_cgin_code IN ('REGULAR-HALF', 'REGULAR-FULL + REVERSAL-HALF','REGULAR-FULL-RETRO') AND ln_cenvat_rcvble_accnt_id IS NULL THEN
        lv_message := 'Excise Education Cess Receivable Account was not defined in Organization Setup';
      END IF;
    END IF;
  /*added the following by vkaranam for budget 07 impact - bug#5989740*/
   --start
  IF ln_sh_total_exc_edu_cess_amt <> 0 THEN
	     IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma
	      AND ln_sh_cess_paid_payable_accnt IS NULL
	    THEN
	      lv_message := 'Secondary/Higher Cess Paid/Payable Account was not defined in Organization Setup';
	    END IF;

	    IF ln_sh_exc_edu_cess_accnt IS NULL THEN
	      IF r_trx.organization_type = 'T' THEN
	        lv_message := 'Excise RG23D Account was not defined in Organization Setup';
	      ELSIF p_amount_register = 'PLA' THEN
	        lv_message := 'Modvat PLA Account was not defined in Organization Setup';
	      ELSIF lv_register_type = 'A' THEN
	        lv_message := 'Secondary/Higher Excise Education Cess RM Account was not defined in Organization Setup';
	      ELSIF lv_register_type = 'C' THEN
	        lv_message := 'Secondary/Higher Excise Education Cess CG Account was not defined in Organization Setup';
	      ELSE
	        lv_message := 'Could not derive Cenvat Account';
	      END IF;

	    ELSIF p_cgin_code IN ('REGULAR-HALF', 'REGULAR-FULL + REVERSAL-HALF','REGULAR-FULL-RETRO') AND ln_cenvat_rcvble_accnt_id IS NULL THEN
	      lv_message := 'Secondary/Higher Excise Education Cess Receivable Account was not defined in Organization Setup';
	    END IF;
  END IF;
 --end bug #5989740


    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 14');

    lv_statement_id := '8';
    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
    IF lv_message IS NOT NULL THEN
      p_process_status  := 'E';
      p_process_message := lv_message;
      RETURN;
    END IF;


    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 15');

    -- This will be used to update PART 1 and 2 Registers later
    p_cenvat_account_id := ln_cenvat_accnt_id;

    IF lv_transaction_type IN ('RECEIVE', 'RETURN TO RECEIVING') THEN
      lv_accnt_type   := 'REGULAR';
    ELSIF lv_transaction_type IN ('DELIVER', 'RETURN TO VENDOR') THEN
      lv_accnt_type   := 'REVERSAL';
    ELSE
      -- Sorry
      fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 16');
      NULL;
    END IF;

    lv_statement_id := '9';
    p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
    IF p_cenvat_accounting_type = CENVAT_DEBIT THEN
      ln_debit            := ln_total_excise_amt;
      ln_balancing_credit := ln_total_excise_amt;
      ln_credit           := NULL;
      ln_balancing_debit  := NULL;
    ELSE
      ln_credit           := ln_total_excise_amt;
      ln_balancing_debit  := ln_total_excise_amt;
      ln_debit            := NULL;
      ln_balancing_credit := NULL;
    END IF;

    -- Vijay Shankar for Bug#3940588 ADDED for EDUCATION CESS
    -- If both accounts are same, then we can pass the accounting in one entry instead of two
    IF ln_exc_edu_cess_accnt IS NOT NULL AND ln_cenvat_accnt_id IS NOT NULL
      AND ln_exc_edu_cess_accnt = ln_cenvat_accnt_id
    THEN
      ln_edu_cess_debit   := null;
      ln_edu_cess_credit  := null;
      IF p_cenvat_accounting_type = CENVAT_DEBIT THEN
        ln_debit  := ln_debit + ln_total_excise_edu_cess_amt;
      ELSE
        ln_credit := ln_credit + ln_total_excise_edu_cess_amt;
      END IF;

    /* if the execution comes here, it means different accounts are defined for edu cess. So, we need to pass
       seperate entry for cess */
    ELSIF ln_total_excise_edu_cess_amt <> 0 THEN

      IF p_cenvat_accounting_type = CENVAT_DEBIT THEN
        ln_edu_cess_debit := ln_total_excise_edu_cess_amt;
        ln_edu_cess_credit  := null;
      ELSE
        ln_edu_cess_credit := ln_total_excise_edu_cess_amt;
        ln_edu_cess_debit   := null;
      END IF;

    END IF;
    -- End Education Cess
    /*added the following by vkaranam for budget 07 impact - bug#5989740*/
   --start
  IF ln_sh_exc_edu_cess_accnt IS NOT NULL AND ln_cenvat_accnt_id IS NOT NULL
	    AND ln_sh_exc_edu_cess_accnt = ln_cenvat_accnt_id
	  THEN
	    ln_sh_edu_cess_debit   := null;
	    ln_sh_edu_cess_credit  := null;

	    IF p_cenvat_accounting_type = CENVAT_DEBIT THEN
	      ln_debit  := ln_debit + ln_sh_total_exc_edu_cess_amt;
	    ELSE
	      ln_credit := ln_credit + ln_sh_total_exc_edu_cess_amt;
	    END IF;

	  /* if the execution comes here, it means different accounts are defined for edu cess. So, we need to pass
	     seperate entry for cess */
	  ELSIF ln_sh_total_exc_edu_cess_amt <> 0 THEN

	    IF p_cenvat_accounting_type = CENVAT_DEBIT THEN
	      ln_sh_edu_cess_debit := ln_sh_total_exc_edu_cess_amt;
	      ln_sh_edu_cess_credit  := null;
	    ELSE
	      ln_sh_edu_cess_credit := ln_sh_total_exc_edu_cess_amt;
	      ln_sh_edu_cess_debit   := null;
	    END IF;

  END IF;
  --end bug#5989740


    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 17');
    /* setting values for balancing credit/debit variables */
    /* edu_cess_balancing part was coded as part of Bug#4211045 */
    IF ln_total_excise_edu_cess_amt <> 0 THEN
      ln_edu_cess_balancing_debit := null;
      ln_edu_cess_balancing_credit := null;

      IF p_cenvat_accounting_type = CENVAT_DEBIT THEN

        /* ln_balancing_credit := ln_balancing_credit + ln_total_excise_edu_cess_amt; */
        /* If condition added by Vijay Shankar for Bug#4211045. Else is existing previously itself as above statement */
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt' THEN
        IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma then
          ln_edu_cess_balancing_credit := ln_total_excise_edu_cess_amt;
        ELSE
          ln_balancing_credit := ln_balancing_credit + ln_total_excise_edu_cess_amt;
        END IF;

      ELSE

        /* ln_balancing_debit := ln_balancing_debit + ln_total_excise_edu_cess_amt; */
        /* If condition added by Vijay Shankar for Bug#4211045. Else is existing previously itself as above statement */
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt' THEN
        IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma then
          ln_edu_cess_balancing_debit := ln_total_excise_edu_cess_amt;
        ELSE
          ln_balancing_debit := ln_balancing_debit + ln_total_excise_edu_cess_amt;
        END IF;
      END IF;
    END IF;
 /*added the following by vkaranam for budget 07 impact - bug#5989740*/
	 --start
	IF ln_sh_total_exc_edu_cess_amt <> 0 THEN
	    ln_sh_edu_cess_balancin_debit := null;
	    ln_sh_edu_cess_balancin_credit := null;

	    IF p_cenvat_accounting_type = CENVAT_DEBIT THEN



	      IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma then
	        ln_sh_edu_cess_balancin_credit := ln_sh_total_exc_edu_cess_amt;
	      ELSE
	        ln_balancing_credit := ln_balancing_credit + ln_sh_total_exc_edu_cess_amt;
	      END IF;

	    ELSE


	      IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma then
	        ln_sh_edu_cess_balancin_debit := ln_sh_total_exc_edu_cess_amt;
	      ELSE
	        ln_balancing_debit := ln_balancing_debit + ln_sh_total_exc_edu_cess_amt;
	      END IF;
	    END IF;
	  END IF;
  --end bug#5989740


    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 18');

    lv_statement_id := '10';
    p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
    IF p_cgin_code IS NULL OR (lv_register_type = 'C' AND p_cgin_code like 'REGULAR-FULL%') THEN

      if lb_rg_debug then
        FND_FILE.put_line(FND_FILE.log,'11_1 jai_rcv_accounting_pkg.process_transaction.'
          ||' Debit:'||ln_debit||', Credit:'||ln_credit||', CenvatAccntId:'||ln_cenvat_accnt_id);
      end if;

      lv_statement_id := '10a';
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
      -- Actual Entry-1: Cenvat Accounting ( This Includes Edu Cess also if different account is not specified for cess)
    -- bug 5581319. Added by Lakshmi Gopalsami
    IF NVL(ln_debit,0) <> 0 OR NVL(ln_credit,0) <> 0 THEN
      fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 19');
      jai_rcv_accounting_pkg.process_transaction(
          P_TRANSACTION_ID       => p_transaction_id,
          P_ACCT_TYPE            => lv_accnt_type,
          P_ACCT_NATURE          => lv_accnt_nature,
          P_SOURCE_NAME          => gv_source_name,
          P_CATEGORY_NAME        => gv_category_name,
          P_CODE_COMBINATION_ID  => ln_cenvat_accnt_id,
          P_ENTERED_DR           => ln_debit,
          P_ENTERED_CR           => ln_credit,
          P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
          P_ACCOUNTING_DATE      => lv_accounting_date,
          P_REFERENCE_10         => lv_reference10,
          P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
          P_REFERENCE_24         => 'rcv_transactions',
          P_REFERENCE_25         => 'transaction_id',
          P_REFERENCE_26         => to_char(p_transaction_id),
          P_DESTINATION          => 'G',
          P_SIMULATE_FLAG        => p_simulate_flag,
          P_CODEPATH             => p_codepath,
          P_PROCESS_STATUS       => p_process_status,
          P_PROCESS_MESSAGE      => p_process_message,
          p_reference_name       => pv_retro_reference /*added by rchandan*/
      );

      IF p_process_status IN ('E', 'X') THEN
        GOTO end_of_accounting;
      END IF;
     END IF;
     -- Bug 5581319

      -- Start, EDUCATION CESS ACCCOUNTING
      IF nvl(ln_edu_cess_debit,0)<>0 OR nvl(ln_edu_cess_credit,0)<>0 THEN

        if lb_rg_debug then
          FND_FILE.put_line(FND_FILE.log,'11_2 Cen Accounting -- '
            ||' Dr:'||ln_edu_cess_debit||', Cr:'||ln_edu_cess_credit||', EduCessAccnt:'||ln_cenvat_accnt_id);
        end if;
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 20');
        lv_statement_id := '10a';
        p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
        -- Actual Entry-2: Cenvat Cess Accounting
        jai_rcv_accounting_pkg.process_transaction(
            P_TRANSACTION_ID       => p_transaction_id,
            P_ACCT_TYPE            => lv_accnt_type,
            P_ACCT_NATURE          => lv_accnt_nature,
            P_SOURCE_NAME          => gv_source_name,
            P_CATEGORY_NAME        => gv_category_name,
            P_CODE_COMBINATION_ID  => ln_exc_edu_cess_accnt,
            P_ENTERED_DR           => ln_edu_cess_debit,
            P_ENTERED_CR           => ln_edu_cess_credit,
            P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
            P_ACCOUNTING_DATE      => lv_accounting_date,
            P_REFERENCE_10         => lv_reference10,
            P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
            P_REFERENCE_24         => 'rcv_transactions',
            P_REFERENCE_25         => 'transaction_id',
            P_REFERENCE_26         => to_char(p_transaction_id),
            P_DESTINATION          => 'G',
            P_SIMULATE_FLAG        => p_simulate_flag,
            P_CODEPATH             => p_codepath,
            P_PROCESS_STATUS       => p_process_status,
            P_PROCESS_MESSAGE      => p_process_message,
            p_reference_name       => pv_retro_reference /*added by rchandan*/
        );

        IF p_process_status IN ('E', 'X') THEN
          GOTO end_of_accounting;
        END IF;
      END IF;
      -- End, EDUCATION CESS ACCCOUNTING
/*added the following by vkaranam for budget 07 impact - bug#5989740*/
  --start SH_excise_edu_cess accounting
    IF nvl(ln_sh_edu_cess_debit,0)<>0 OR nvl(ln_sh_edu_cess_credit,0)<>0 THEN

      if lb_rg_debug then
        FND_FILE.put_line(FND_FILE.log,'11_3 Cen Accounting -- '
          ||' SH_Dr:'||ln_sh_edu_cess_debit||', SH_Cr:'||ln_sh_edu_cess_credit||', SH_EduCessAccnt:'||ln_sh_exc_edu_cess_accnt);
      end if;

      lv_statement_id := '10b';
      p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
      -- Actual Entry-2: Cenvat Cess Accounting
      jai_rcv_accounting_pkg.process_transaction(
          P_TRANSACTION_ID       => p_transaction_id,
          P_ACCT_TYPE            => lv_accnt_type,
          P_ACCT_NATURE          => lv_accnt_nature,
          P_SOURCE_NAME          => gv_source_name,
          P_CATEGORY_NAME        => gv_category_name,
          P_CODE_COMBINATION_ID  => ln_sh_exc_edu_cess_accnt,
          P_ENTERED_DR           => ln_sh_edu_cess_debit,
          P_ENTERED_CR           => ln_sh_edu_cess_credit,
          P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
          P_ACCOUNTING_DATE      => lv_accounting_date,
          P_REFERENCE_10         => lv_reference10,
          P_REFERENCE_23         => 'ja_in_receipt_cenvat_rg_pkg.accounting_entries',
          P_REFERENCE_24         => 'rcv_transactions',
          P_REFERENCE_25         => 'transaction_id',
          P_REFERENCE_26         => to_char(p_transaction_id),
          P_DESTINATION          => 'G',
          P_SIMULATE_FLAG        => p_simulate_flag,
          P_CODEPATH             => p_codepath,
          P_PROCESS_STATUS       => p_process_status,
          P_PROCESS_MESSAGE      => p_process_message,
          p_reference_name       => pv_retro_reference /*added by rchandan*/
          , p_reference_id         => 3
      );

      IF p_process_status IN ('E', 'X') THEN
        GOTO end_of_accounting;
      END IF;
    END IF;
    -- End 5989740


      if lb_rg_debug then
        FND_FILE.put_line(FND_FILE.log,'12 jai_rcv_accounting_pkg.process_transaction.'
          ||' Debit:'||ln_balancing_debit||', Credit:'||ln_balancing_credit||', RecvngAccntId:'||ln_receiving_accnt_id);
      end if;

      lv_statement_id := '10b';
      p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
      -- Balancing Entry: Receiving Accounting
     -- bug 5581319. Added by Lakshmi Gopalsami
     IF NVL(ln_balancing_debit,0) <> 0 OR NVL(ln_balancing_credit,0) <> 0 THEN
      fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 21');

      jai_rcv_accounting_pkg.process_transaction(
          P_TRANSACTION_ID       => p_transaction_id,
          P_ACCT_TYPE            => lv_accnt_type,
          P_ACCT_NATURE          => lv_accnt_nature,
          P_SOURCE_NAME          => gv_source_name,
          P_CATEGORY_NAME        => gv_category_name,
          P_CODE_COMBINATION_ID  => ln_receiving_accnt_id,
          P_ENTERED_DR           => ln_balancing_debit,
          P_ENTERED_CR           => ln_balancing_credit,
          P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
          P_ACCOUNTING_DATE      => lv_accounting_date,
          P_REFERENCE_10         => lv_reference10,
          P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
          P_REFERENCE_24         => 'rcv_transactions',
          P_REFERENCE_25         => 'transaction_id',
          P_REFERENCE_26         => to_char(p_transaction_id),
          P_DESTINATION          => 'G',
          P_SIMULATE_FLAG        => p_simulate_flag,
          P_CODEPATH             => p_codepath,
          P_PROCESS_STATUS       => p_process_status,
          P_PROCESS_MESSAGE      => p_process_message,
          p_reference_name       => pv_retro_reference ,/*added by rchandan*/
           p_reference_id         => 5--replaced 3 with 5 by vkaranam fro bug#5989740
      );

      IF p_process_status IN ('E', 'X') THEN
        GOTO end_of_accounting;
      END IF;
     END IF;
     -- Bug 5581319


      /* following entry (CESS BALANCING ENTRY for RMA Production Input and GOODS RETURN cases)
       added by Vijay Shankar for Bug#4211045 */
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt'
      IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma
        AND nvl(ln_edu_cess_balancing_debit, ln_edu_cess_balancing_credit) <> 0
      THEN

        lv_statement_id := '10b';
        p_codepath := jai_general_pkg.plot_codepath(13.1, p_codepath);
        -- Balancing Entry: Receiving Accounting
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 22');
        jai_rcv_accounting_pkg.process_transaction(
            P_TRANSACTION_ID       => p_transaction_id,
            P_ACCT_TYPE            => lv_accnt_type,
            P_ACCT_NATURE          => lv_accnt_nature,
            P_SOURCE_NAME          => gv_source_name,
            P_CATEGORY_NAME        => gv_category_name,
            P_CODE_COMBINATION_ID  => ln_cess_paid_payable_accnt_id,
            P_ENTERED_DR           => ln_edu_cess_balancing_debit,
            P_ENTERED_CR           => ln_edu_cess_balancing_credit,
            P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
            P_ACCOUNTING_DATE      => lv_accounting_date,
            P_REFERENCE_10         => lv_reference10,
            P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
            P_REFERENCE_24         => 'rcv_transactions',
            P_REFERENCE_25         => 'transaction_id',
            P_REFERENCE_26         => to_char(p_transaction_id),
            P_DESTINATION          => 'G',
            P_SIMULATE_FLAG        => p_simulate_flag,
            P_CODEPATH             => p_codepath,
            P_PROCESS_STATUS       => p_process_status,
            P_PROCESS_MESSAGE      => p_process_message,
            p_reference_name       => pv_retro_reference, /*added by rchandan*/
             p_reference_id         => 6 --replaced 4 with 6 by vkaranam fro bug#5989740
        );

        IF p_process_status IN ('E', 'X') THEN
          GOTO end_of_accounting;
        END IF;

      END IF;
 /*added the following by vkaranam for budget 07 impact - bug#5989740*/
 	   --start
 	   if lb_rg_debug then
 	 	      FND_FILE.put_line(FND_FILE.log,'15 JA_IN_RECEIPT_ACCOUNTING_PKG.process_transaction.'
 	 	        ||' SH_Debit:'||ln_sh_edu_cess_balancin_debit||', SH_Credit:'||ln_sh_edu_cess_balancin_credit
 	 	        ||', ln_sh_cess_paid_payable_accnt:'||ln_sh_cess_paid_payable_accnt);
 	   end if;

 	   IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma
 	 	      AND nvl(ln_sh_edu_cess_balancin_debit, ln_sh_edu_cess_balancin_credit) <> 0
 	 	    THEN

 	 	      lv_statement_id := '10d';
 	 	      p_codepath := jai_general_pkg.plot_codepath(15.1, p_codepath);
 	 	      -- Balancing Entry: Receiving Accounting
 	 	      jai_rcv_accounting_pkg.process_transaction(
 	 	          P_TRANSACTION_ID       => p_transaction_id,
 	 	          P_ACCT_TYPE            => lv_accnt_type,
 	 	          P_ACCT_NATURE          => lv_accnt_nature,
 	 	          P_SOURCE_NAME          => gv_source_name,
 	 	          P_CATEGORY_NAME        => gv_category_name,
 	 	          P_CODE_COMBINATION_ID  => ln_sh_cess_paid_payable_accnt,--replaced ln_cess_paid_payable_accnt_id with ln_sh_cess_paid_payable_accnt for bug #5989740
 	 	          P_ENTERED_DR           => ln_sh_edu_cess_balancin_debit,
 	 	          P_ENTERED_CR           => ln_sh_edu_cess_balancin_credit,
 	 	          P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
 	 	          P_ACCOUNTING_DATE      => lv_accounting_date,
 	 	          P_REFERENCE_10         => lv_reference10,
 	 	          P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
 	 	          P_REFERENCE_24         => 'rcv_transactions',
 	 	          P_REFERENCE_25         => 'transaction_id',
 	 	          P_REFERENCE_26         => to_char(p_transaction_id),
 	 	          P_DESTINATION          => 'G',
 	 	          P_SIMULATE_FLAG        => p_simulate_flag,
 	 	          P_CODEPATH             => p_codepath,
 	 	          P_PROCESS_STATUS       => p_process_status,
 	 	          P_PROCESS_MESSAGE      => p_process_message,
 	 	          p_reference_name       => pv_retro_reference /*added by rchandan*/
 	 	          , p_reference_id         => 4
 	 	      );

 	 	      IF p_process_status IN ('E', 'X') THEN
 	 	        GOTO end_of_accounting;
 	 	      END IF;

 	  END IF;

 	  --end 5989740


    END IF;

    /*~~~~~~~~~ Reversal/Regular Entry of 50% for CGIN Items from MainCG/RcvbleCG account to RcvbleCG/MainCG account ~~~~~~~~~~~~~~~*/

    lv_statement_id := '11';
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb> --- 23a - cgin code ' || p_cgin_code );

    IF nvl(p_cgin_code,'AA') IN ('REGULAR-HALF', 'REGULAR-FULL + REVERSAL-HALF') THEN
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 23');
      lv_statement_id := '12';
      p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */

      -- this can happen only for RECEIVE type of transaction and that too for 2nd 50% Claim
      IF p_cgin_code = 'REGULAR-HALF' THEN
        lv_accnt_nature     := 'CENVAT-REG-50%';
        ln_debit            := ln_total_excise_amt/2;
        ln_balancing_credit := ln_total_excise_amt/2;
        ln_credit           := NULL;
        ln_balancing_debit  := NULL;

        -- Vijay Shankar for Bug#3940588 ADDED for EDUCATION CESS
        IF ln_exc_edu_cess_accnt IS NOT NULL AND ln_cenvat_accnt_id IS NOT NULL
          AND ln_exc_edu_cess_accnt = ln_cenvat_accnt_id
        THEN
          ln_debit            := ln_debit + ln_total_excise_edu_cess_amt/2;
          ln_edu_cess_debit   := null;
        -- if different account is specified for Cess, then we pass separate entry for cess and balance the amount with balance entry
        ELSIF ln_total_excise_edu_cess_amt <> 0 THEN
          ln_edu_cess_debit   := ln_total_excise_edu_cess_amt/2;
        END IF;
        ln_edu_cess_credit  := null;

        -- this is required in case Excise Rcvble and Edu Cess Rcvble are same, so that no separate accnt entry for Cess Rcvble Amount
        IF ln_exc_edu_cess_rcvble_accnt IS NOT NULL AND ln_cenvat_rcvble_accnt_id IS NOT NULL
          AND ln_cenvat_rcvble_accnt_id = ln_exc_edu_cess_rcvble_accnt
        THEN
          ln_balancing_credit := ln_balancing_credit + ln_total_excise_edu_cess_amt/2;
        ELSIF ln_total_excise_edu_cess_amt <> 0 THEN
          ln_bal_edu_cess_credit := ln_total_excise_edu_cess_amt/2;
          ln_bal_edu_cess_debit := null;
        END IF;
        -- End, Vijay Shankar for Bug#3940588
   /*added the following by vkaranam for budget 07 impact - bug#5989740*/
		  --start
	    IF ln_sh_exc_edu_cess_accnt IS NOT NULL AND ln_cenvat_accnt_id IS NOT NULL
					AND ln_sh_exc_edu_cess_accnt = ln_cenvat_accnt_id
				THEN
					ln_debit            := ln_debit + ln_sh_total_exc_edu_cess_amt/2;
					ln_sh_edu_cess_debit   := null;
				-- if different account is specified for Cess, then we pass separate entry for cess and balance the amount with balance entry
				ELSIF ln_sh_total_exc_edu_cess_amt <> 0 THEN
					ln_sh_edu_cess_debit   := ln_sh_total_exc_edu_cess_amt/2;
				END IF;
				ln_sh_edu_cess_credit  := null;

				-- this is required in case Excise Rcvble and SH Edu Cess Rcvble are same, so that no separate accnt entry for Cess Rcvble Amount
				IF ln_sh_exc_edu_cess_rcvb_accnt IS NOT NULL AND ln_cenvat_rcvble_accnt_id IS NOT NULL
					AND ln_cenvat_rcvble_accnt_id = ln_sh_exc_edu_cess_rcvb_accnt
				THEN
					ln_balancing_credit := ln_balancing_credit + ln_sh_total_exc_edu_cess_amt/2;
				ELSIF ln_sh_total_exc_edu_cess_amt <> 0 THEN -- Date 04/06/2007 by sacsethi for bug 6109941
					ln_sh_bal_edu_cess_credit := ln_sh_total_exc_edu_cess_amt/2;
					ln_sh_bal_edu_cess_debit := null;
	    END IF;
     -- End bug#5989740


      ELSIF p_cgin_code = 'REGULAR-FULL + REVERSAL-HALF' THEN

        lv_accnt_nature   := 'CENVAT-REV-50%';
        IF p_cenvat_accounting_type = CENVAT_DEBIT THEN
          -- because this is reversal transaction, opposite of regular acocunting should be passed
          -- this happens in case of DELIVER Trxn
        /*ln_credit           := ln_total_excise_amt/2;
          ln_balancing_debit  := ln_total_excise_amt/2;
		  commented the above and added the below by vumaasha for 7716044
		  as ln_total_excise_amt is including the additional CVD, which shouldn't be reversed */
		  ln_credit           := (ln_total_excise_amt - nvl(pr_tax.addl_cvd,0))/2;
		  ln_balancing_debit  := (ln_total_excise_amt - nvl(pr_tax.addl_cvd,0))/2;
          ln_debit            := NULL;
          ln_balancing_credit := NULL;

          -- Vijay Shankar for Bug#3940588 ADDED for EDUCATION CESS
          IF ln_exc_edu_cess_accnt IS NOT NULL AND ln_cenvat_accnt_id IS NOT NULL
            AND ln_exc_edu_cess_accnt = ln_cenvat_accnt_id
          THEN
            ln_credit           := ln_credit + ln_total_excise_edu_cess_amt/2;
            ln_edu_cess_credit  := null;
          -- if different account is specified for Cess, then we pass separate entry for cess and balance the amount with balance entry
          ELSIF ln_total_excise_edu_cess_amt <> 0 THEN
            ln_edu_cess_credit   := ln_total_excise_edu_cess_amt/2;
          END IF;
          ln_edu_cess_debit  := null;

          -- this is required in case Excise Rcvble and Edu Cess Rcvble are same, so that no separate accnt entry for Cess Rcvble Amount
          IF ln_exc_edu_cess_rcvble_accnt IS NOT NULL AND ln_cenvat_rcvble_accnt_id IS NOT NULL
            AND ln_cenvat_rcvble_accnt_id = ln_exc_edu_cess_rcvble_accnt
          THEN
            ln_balancing_debit := ln_balancing_debit + ln_total_excise_edu_cess_amt/2;
            ln_bal_edu_cess_debit  := null;
            ln_bal_edu_cess_credit := null;
          ELSIF ln_total_excise_edu_cess_amt <> 0 THEN
            ln_bal_edu_cess_debit := ln_total_excise_edu_cess_amt/2;
            ln_bal_edu_cess_credit := null;
          END IF;
          -- End, Vijay Shankar for Bug#3940588
  /*added the following by vkaranam for budget 07 impact - bug#5989740*/
	IF ln_sh_exc_edu_cess_accnt IS NOT NULL AND ln_cenvat_accnt_id IS NOT NULL
	  AND ln_sh_exc_edu_cess_accnt = ln_cenvat_accnt_id
	THEN
	  ln_credit           := ln_credit + ln_sh_total_exc_edu_cess_amt/2;
	  ln_sh_edu_cess_credit  := null;
	-- if different account is specified for Cess, then we pass separate entry for cess and balance the amount with balance entry
	ELSIF ln_sh_total_exc_edu_cess_amt <> 0 THEN
	  ln_sh_edu_cess_credit   := ln_sh_total_exc_edu_cess_amt/2;
	END IF;
	ln_sh_edu_cess_debit  := null;

	-- this is required in case Excise Rcvble and Edu Cess Rcvble are same, so that no separate accnt entry for Cess Rcvble Amount
	IF ln_sh_exc_edu_cess_rcvb_accnt IS NOT NULL AND ln_cenvat_rcvble_accnt_id IS NOT NULL
	  AND ln_cenvat_rcvble_accnt_id = ln_sh_exc_edu_cess_rcvb_accnt
	THEN

	  ln_balancing_debit := ln_balancing_debit + ln_sh_total_exc_edu_cess_amt/2;
	  ln_sh_bal_edu_cess_debit  := null;
	  ln_sh_bal_edu_cess_credit := null;
	ELSIF ln_sh_total_exc_edu_cess_amt <> 0 THEN
	  ln_sh_bal_edu_cess_debit := ln_sh_total_exc_edu_cess_amt/2;
	  ln_sh_bal_edu_cess_credit := null;
	END IF;
     -- End bug 5989740


        ELSE

          /* ln_debit            := ln_total_excise_amt/2;
          ln_balancing_credit := ln_total_excise_amt/2;
		  commented the above and added the below by vumaasha for 7716044.
		  as ln_total_excise_amt is including the additional CVD, which shouldn't be reversed */
		  ln_debit            := (ln_total_excise_amt - nvl(pr_tax.addl_cvd,0))/2;
		  ln_balancing_credit := (ln_total_excise_amt - nvl(pr_tax.addl_cvd,0))/2;
          ln_credit           := NULL;
          ln_balancing_debit  := NULL;

          -- Vijay Shankar for Bug#3940588 ADDED for EDUCATION CESS
          IF ln_exc_edu_cess_accnt IS NOT NULL AND ln_cenvat_accnt_id IS NOT NULL
            AND ln_exc_edu_cess_accnt = ln_cenvat_accnt_id
          THEN
            ln_debit            := ln_debit + ln_total_excise_edu_cess_amt/2;
            ln_edu_cess_debit   := null;
          -- if different account is specified for Cess, then we pass separate entry for cess and balance the amount with balance entry
          ELSIF ln_total_excise_edu_cess_amt <> 0 THEN
            ln_edu_cess_debit   := ln_total_excise_edu_cess_amt/2;
          END IF;
          ln_edu_cess_credit  := null;

          -- this is required in case Excise Rcvble and Edu Cess Rcvble are same, so that no separate accnt entry for Cess Rcvble Amount
          IF ln_exc_edu_cess_rcvble_accnt IS NOT NULL AND ln_cenvat_rcvble_accnt_id IS NOT NULL
            AND ln_cenvat_rcvble_accnt_id = ln_exc_edu_cess_rcvble_accnt
          THEN
            ln_balancing_credit := ln_balancing_credit + ln_total_excise_edu_cess_amt/2;
            ln_bal_edu_cess_debit  := null;
            ln_bal_edu_cess_credit := null;
          ELSIF ln_total_excise_edu_cess_amt <> 0 THEN
            ln_bal_edu_cess_credit := ln_total_excise_edu_cess_amt/2;
            ln_bal_edu_cess_debit := null;
          END IF;
          -- End, Vijay Shankar for Bug#3940588
   /*added the following by vkaranam for budget 07 impact - bug#5989740*/
	IF ln_sh_exc_edu_cess_accnt IS NOT NULL AND ln_cenvat_accnt_id IS NOT NULL
	  AND ln_sh_exc_edu_cess_accnt = ln_cenvat_accnt_id
	THEN
	  ln_debit            := ln_debit + ln_sh_total_exc_edu_cess_amt/2;
	  ln_sh_edu_cess_debit   := null;
	-- if different account is specified for Cess, then we pass separate entry for cess and balance the amount with balance entry
	ELSIF ln_sh_total_exc_edu_cess_amt <> 0 THEN
	  ln_sh_edu_cess_debit   := ln_sh_total_exc_edu_cess_amt/2;
	END IF;
	ln_sh_edu_cess_credit  := null;

	-- this is required in case Excise Rcvble and Edu Cess Rcvble are same, so that no separate accnt entry for Cess Rcvble Amount
	IF ln_sh_exc_edu_cess_rcvb_accnt IS NOT NULL AND ln_cenvat_rcvble_accnt_id IS NOT NULL
	  AND ln_cenvat_rcvble_accnt_id = ln_sh_exc_edu_cess_rcvb_accnt
	THEN
	  ln_balancing_credit := ln_balancing_credit + ln_sh_total_exc_edu_cess_amt/2;
	  ln_sh_bal_edu_cess_debit  := null;
	  ln_sh_bal_edu_cess_credit := null;
	ELSIF ln_sh_total_exc_edu_cess_amt <> 0 THEN
	  ln_sh_bal_edu_cess_credit := ln_sh_total_exc_edu_cess_amt/2;
	  ln_sh_bal_edu_cess_debit := null;
	END IF;
   -- End bug 5989740

        END IF;

      ELSE
        FND_FILE.put_line(FND_FILE.log, '**** CGIN_CODE Not Handled ****');

        p_process_message   := 'CGIN_CODE Not Handled';
        GOTO end_of_accounting;
      END IF;

      lv_statement_id := '13';
      p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
      if lb_rg_debug then
        FND_FILE.put_line(FND_FILE.log,'21 jai_rcv_accounting_pkg.process_transaction'
          ||' Debit:'||ln_debit||', Credit:'||ln_credit||', CenvatAccntId:'||ln_cenvat_accnt_id);
      end if;

      lv_statement_id := '13a';
      p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
      -- SecondSet First Entry_1: Cenvat Accounting
      -- bug 5581319. Added by Lakshmi Gopalsami
     IF NVL(ln_balancing_debit,0) <> 0 OR NVL(ln_balancing_credit,0) <> 0 THEN

      fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 24');
      jai_rcv_accounting_pkg.process_transaction(
          P_TRANSACTION_ID       => p_transaction_id,
          P_ACCT_TYPE            => lv_accnt_type,
          P_ACCT_NATURE          => lv_accnt_nature,
          P_SOURCE_NAME          => gv_source_name,
          P_CATEGORY_NAME        => gv_category_name,
          P_CODE_COMBINATION_ID  => ln_cenvat_accnt_id,
          P_ENTERED_DR           => ln_debit,
          P_ENTERED_CR           => ln_credit,
          P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
          P_ACCOUNTING_DATE      => lv_accounting_date,
          P_REFERENCE_10         => lv_reference10,
          P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
          P_REFERENCE_24         => 'rcv_transactions',
          P_REFERENCE_25         => 'transaction_id',
          P_REFERENCE_26         => to_char(p_transaction_id),
          P_DESTINATION          => 'G',
          P_SIMULATE_FLAG        => p_simulate_flag,
          P_CODEPATH             => p_codepath,
          P_PROCESS_STATUS       => p_process_status,
          P_PROCESS_MESSAGE      => p_process_message,
          p_reference_name       => pv_retro_reference, /*added by rchandan*/
	  p_reference_id         => 7 /*added by ssawant for bug 6084771*/
      );

      IF p_process_status IN ('E', 'X') THEN
        GOTO end_of_accounting;
      END IF;
    END IF;
    -- bug 5581319

      -- Vijay Shankar for Bug#3940588 EDUCATION CESS Accoounting
      IF nvl(ln_edu_cess_debit,0)<>0 OR nvl(ln_edu_cess_credit,0)<>0 THEN

        if lb_rg_debug then
          FND_FILE.put_line(FND_FILE.log,'21_1 Cess Accnt - '
            ||' Dr:'||ln_edu_cess_debit||', Cr:'||ln_edu_cess_credit||', Cess Accnt:'||ln_exc_edu_cess_accnt);
        end if;
        -- SecondSet First Entry_2: Education Cess Accounting
        lv_statement_id := '13z';
        p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
        -- SecondSet First Entry: cenvat Accounting
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 25');
        jai_rcv_accounting_pkg.process_transaction(
            P_TRANSACTION_ID       => p_transaction_id,
            P_ACCT_TYPE            => lv_accnt_type,
            P_ACCT_NATURE          => lv_accnt_nature,
            P_SOURCE_NAME          => gv_source_name,
            P_CATEGORY_NAME        => gv_category_name,
            P_CODE_COMBINATION_ID  => ln_exc_edu_cess_accnt,
            P_ENTERED_DR           => ln_edu_cess_debit,
            P_ENTERED_CR           => ln_edu_cess_credit,
            P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
            P_ACCOUNTING_DATE      => lv_accounting_date,
            P_REFERENCE_10         => lv_reference10,
            P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
            P_REFERENCE_24         => 'rcv_transactions',
            P_REFERENCE_25         => 'transaction_id',
            P_REFERENCE_26         => to_char(p_transaction_id),
            P_DESTINATION          => 'G',
            P_SIMULATE_FLAG        => p_simulate_flag,
            P_CODEPATH             => p_codepath,
            P_PROCESS_STATUS       => p_process_status,
            P_PROCESS_MESSAGE      => p_process_message,
            p_reference_name       => pv_retro_reference, /*added by rchandan*/
	    p_reference_id         => 8 /*added by ssawant for bug 6084771*/
        );

        IF p_process_status IN ('E', 'X') THEN
          GOTO end_of_accounting;
        END IF;

      END IF;
 /*added the following by vkaranam for budget 07 impact - bug#5989740*/
    --start
    IF nvl(ln_sh_edu_cess_debit,0)<>0 OR nvl(ln_sh_edu_cess_credit,0)<>0 THEN

	    if lb_rg_debug then
	    FND_FILE.put_line(FND_FILE.log,'21_2 Cess Accnt - '
	      ||' Dr:'||ln_sh_edu_cess_debit||', Cr:'||ln_sh_edu_cess_credit||', SH Cess Accnt:'||ln_sh_exc_edu_cess_accnt);
	  end if;
	  -- SecondSet First Entry_2: SH Education Cess Accounting
	  lv_statement_id := '13x';
	  p_codepath := jai_general_pkg.plot_codepath(20, p_codepath);
	  -- SecondSet First Entry: cenvat Accounting
	  jai_rcv_accounting_pkg.process_transaction(
	      P_TRANSACTION_ID       => p_transaction_id,
	      P_ACCT_TYPE            => lv_accnt_type,
	      P_ACCT_NATURE          => lv_accnt_nature,
	      P_SOURCE_NAME          => gv_source_name,
	      P_CATEGORY_NAME        => gv_category_name,
	      P_CODE_COMBINATION_ID  => ln_sh_exc_edu_cess_accnt,
	      P_ENTERED_DR           => ln_sh_edu_cess_debit,
	      P_ENTERED_CR           => ln_sh_edu_cess_credit,
	      P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
	      P_ACCOUNTING_DATE      => lv_accounting_date,
	      P_REFERENCE_10         => lv_reference10,
	      P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
	      P_REFERENCE_24         => 'rcv_transactions',
	      P_REFERENCE_25         => 'transaction_id',
	      P_REFERENCE_26         => to_char(p_transaction_id),
	      P_DESTINATION          => 'G',
	      P_SIMULATE_FLAG        => p_simulate_flag,
	      P_CODEPATH             => p_codepath,
	      P_PROCESS_STATUS       => p_process_status,
	      P_PROCESS_MESSAGE      => p_process_message,
	      p_reference_name       => pv_retro_reference, /*added by rchandan*/
              p_reference_id         => 9  /*added by ssawant for bug 6084771*/
	  );

	  IF p_process_status IN ('E', 'X') THEN
	    GOTO end_of_accounting;
	  END IF;

    END IF;
    --end 5989740


      FND_FILE.put_line( FND_FILE.log, 'Codepath->'||p_codepath);
      if lb_rg_debug then
        FND_FILE.put_line(FND_FILE.log,'22 jai_rcv_accounting_pkg.process_transaction'
          ||' Debit:'||ln_balancing_debit||', Credit:'||ln_balancing_credit||', CenRcvbleAccntId:'||ln_cenvat_rcvble_accnt_id);
      end if;

      lv_statement_id := '13b';
      p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */
      -- SecondSet Balancing Entry: Cenvat Receivable Accounting
      -- bug 5581319. Added by Lakshmi Gopalsami
      IF NVL(ln_balancing_debit,0) <> 0 OR NVL(ln_balancing_credit,0) <> 0 THEN

      fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 26');
      jai_rcv_accounting_pkg.process_transaction(
          P_TRANSACTION_ID       => p_transaction_id,
          P_ACCT_TYPE            => lv_accnt_type,
          P_ACCT_NATURE          => lv_accnt_nature,
          P_SOURCE_NAME          => gv_source_name,
          P_CATEGORY_NAME        => gv_category_name,
          P_CODE_COMBINATION_ID  => ln_cenvat_rcvble_accnt_id,
          P_ENTERED_DR           => ln_balancing_debit,
          P_ENTERED_CR           => ln_balancing_credit,
          P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
          P_ACCOUNTING_DATE      => lv_accounting_date,
          P_REFERENCE_10         => lv_reference10,
          P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
          P_REFERENCE_24         => 'rcv_transactions',
          P_REFERENCE_25         => 'transaction_id',
          P_REFERENCE_26         => to_char(p_transaction_id),
          P_DESTINATION          => 'G',
          P_SIMULATE_FLAG        => p_simulate_flag,
          P_CODEPATH             => p_codepath,
          P_PROCESS_STATUS       => p_process_status,
          P_PROCESS_MESSAGE      => p_process_message,
          p_reference_name       => pv_retro_reference, /*added by rchandan*/
	  p_reference_id         => 10 /*added by ssawant for bug 6084771*/
      );

      IF p_process_status IN ('E', 'X') THEN
        GOTO end_of_accounting;
      END IF;
     END IF;
     -- Bug 5581319

      -- Vijay Shankar for Bug#3940588 EDUCATION CESS ACCOUNTING
      IF nvl(ln_bal_edu_cess_debit,0)<>0 OR nvl(ln_bal_edu_cess_credit,0)<>0  THEN

        if lb_rg_debug then
          FND_FILE.put_line(FND_FILE.log,'22_2 Cess Rcvble accnt'
            ||' Dr:'||ln_bal_edu_cess_debit||', Cr:'||ln_bal_edu_cess_credit||', CessRcvbleAccnt:'||ln_cenvat_rcvble_accnt_id);
        end if;

        lv_statement_id := '13b';
        p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */
        -- SecondSet Balancing Entry: Cenvat Receivable Accounting
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 27');
        jai_rcv_accounting_pkg.process_transaction(
            P_TRANSACTION_ID       => p_transaction_id,
            P_ACCT_TYPE            => lv_accnt_type,
            P_ACCT_NATURE          => lv_accnt_nature,
            P_SOURCE_NAME          => gv_source_name,
            P_CATEGORY_NAME        => gv_category_name,
            P_CODE_COMBINATION_ID  => ln_exc_edu_cess_rcvble_accnt,
            P_ENTERED_DR           => ln_bal_edu_cess_debit,
            P_ENTERED_CR           => ln_bal_edu_cess_credit,
            P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
            P_ACCOUNTING_DATE      => lv_accounting_date,
            P_REFERENCE_10         => lv_reference10,
            P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
            P_REFERENCE_24         => 'rcv_transactions',
            P_REFERENCE_25         => 'transaction_id',
            P_REFERENCE_26         => to_char(p_transaction_id),
            P_DESTINATION          => 'G',
            P_SIMULATE_FLAG        => p_simulate_flag,
            P_CODEPATH             => p_codepath,
            P_PROCESS_STATUS       => p_process_status,
            P_PROCESS_MESSAGE      => p_process_message,
            p_reference_name       => pv_retro_reference, /*added by rchandan*/
	    p_reference_id         => 11 /*added by ssawant for bug 6084771*/
        );

        IF p_process_status IN ('E', 'X') THEN
          GOTO end_of_accounting;
        END IF;

      END IF;
      -- END EDUCATION CESS ACCOUNTING
/*added the following by vkaranam for budget 07 impact - bug#5989740*/
    --start
    IF nvl(ln_sh_bal_edu_cess_debit,0)<>0 OR nvl(ln_sh_bal_edu_cess_credit,0)<>0  THEN

	      if lb_rg_debug then
	        FND_FILE.put_line(FND_FILE.log,'22_3 Cess Rcvble accnt'
	          ||' Dr:'||ln_sh_bal_edu_cess_debit||', Cr:'||ln_sh_bal_edu_cess_credit||', SH CessRcvbleAccnt:'||ln_cenvat_rcvble_accnt_id);
	      end if;

	      lv_statement_id := '13d';
	      p_codepath := jai_general_pkg.plot_codepath(20, p_codepath); /* 18 */
	      -- SecondSet Balancing Entry: Cenvat Receivable Accounting
	     jai_rcv_accounting_pkg.process_transaction(
	          P_TRANSACTION_ID       => p_transaction_id,
	          P_ACCT_TYPE            => lv_accnt_type,
	          P_ACCT_NATURE          => lv_accnt_nature,
	          P_SOURCE_NAME          => gv_source_name,
	          P_CATEGORY_NAME        => gv_category_name,
	          P_CODE_COMBINATION_ID  => ln_sh_exc_edu_cess_rcvb_accnt,
	          P_ENTERED_DR           => ln_sh_bal_edu_cess_debit,
	          P_ENTERED_CR           => ln_sh_bal_edu_cess_credit,
	          P_CURRENCY_CODE        => jai_rcv_trx_processing_pkg.gv_func_curr,
	          P_ACCOUNTING_DATE      => lv_accounting_date,
	          P_REFERENCE_10         => lv_reference10,
	          P_REFERENCE_23         => 'jai_rcv_excise_processing_pkg.accounting_entries',
	          P_REFERENCE_24         => 'rcv_transactions',
	          P_REFERENCE_25         => 'transaction_id',
	          P_REFERENCE_26         => to_char(p_transaction_id),
	          P_DESTINATION          => 'G',
	          P_SIMULATE_FLAG        => p_simulate_flag,
	          P_CODEPATH             => p_codepath,
	          P_PROCESS_STATUS       => p_process_status,
	          P_PROCESS_MESSAGE      => p_process_message,
	          p_reference_name       => pv_retro_reference, /*added by rchandan*/
		  p_reference_id         => 12 /*added by ssawant for bug 6084771*/
	      );

	      IF p_process_status IN ('E', 'X') THEN
	        GOTO end_of_accounting;
	      END IF;

	END IF;
	-- END bug 5989740



    END IF;

    <<end_of_accounting>>
    NULL;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 28a');
    p_codepath := jai_general_pkg.plot_codepath(19, p_codepath, null, 'END'); /* 19 */
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- 28');
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_exc_prc.plb --- ERR 29');
      p_process_message := 'CENVAT_RG_PKG.accounting_entries->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END accounting_entries;


  PROCEDURE update_registers(
    p_quantity_register_id  IN  NUMBER,
    p_quantity_register     IN  VARCHAR2,
    p_payment_register_id   IN  NUMBER,
    p_payment_register      IN  VARCHAR2,
    p_charge_account_id     IN  NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag         IN  VARCHAR2,
    p_codepath              IN OUT NOCOPY VARCHAR2
  ) IS

    lv_statement_id   VARCHAR2(5);
  BEGIN

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.update_reg' , 'START'); /* 1 */
    if lb_rg_debug then
      /*dbms_output.put_line('^ Upd_Regs. Payid:'||p_payment_register_id
        ||', PayReg:'||p_payment_register
        ||', Qtyid:'||p_quantity_register_id
        ||', QtyReg:'||p_quantity_register
        ||', ChrgAccnt:'||p_charge_account_id); */
      fnd_file.put_line(fnd_file.log, '^ Upd_Regs. Payid:'||p_payment_register_id
        ||', PayReg:'||p_payment_register
        ||', Qtyid:'||p_quantity_register_id
        ||', QtyReg:'||p_quantity_register
        ||', ChrgAccnt:'||p_charge_account_id);
    end if;

    IF p_quantity_register IN ('RG23A', 'RG23C') THEN
      lv_statement_id := '2';
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      jai_cmn_rg_23ac_i_trxs_pkg.update_payment_details(
        p_register_id         => p_quantity_register_id,
        p_register_id_part_ii => p_payment_register_id,
        p_charge_account_id   => p_charge_account_id
      );

    ELSIF p_quantity_register = 'RG23D' THEN
      lv_statement_id := '3';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      jai_cmn_rg_23d_trxs_pkg.update_payment_details(
        p_register_id         => p_quantity_register_id,
        p_charge_account_id   => p_charge_account_id
      );

    ELSIF p_quantity_register = 'RG1' THEN
      lv_statement_id := '4';
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      UPDATE JAI_CMN_RG_I_TRXS
      SET
        register_id_part_ii = p_payment_register_id,
        charge_account_id   = p_charge_account_id,
        payment_register    = p_payment_register
      WHERE register_id = p_quantity_register_id;

    ELSE
      FND_FILE.put_line( FND_FILE.log, 'JA_IN_RECEIPT_MODVAT_RG_PKG.update_registers: No Quantity Register Updated');
    END IF;

    IF p_payment_register IN ('RG23A', 'RG23C') THEN
      lv_statement_id := '5';
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      jai_cmn_rg_23ac_ii_pkg.update_payment_details(
        p_register_id         => p_payment_register_id,
        p_register_id_part_i  => p_quantity_register_id,
        p_charge_account_id   => p_charge_account_id
      );

    ELSIF p_payment_register = 'PLA' THEN
      lv_statement_id := '6';
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      jai_cmn_rg_pla_trxs_pkg.update_payment_details(
        p_register_id         => p_payment_register_id,
        p_charge_account_id   => p_charge_account_id
      );

    ELSE
      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
      FND_FILE.put_line( FND_FILE.log, 'JA_IN_RECEIPT_MODVAT_RG_PKG.update_registers: No Payment Register Updated');
    END IF;

    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath, NULL, 'END'); /* 8 */

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.update_registers->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END update_registers;

  -- If this function returns a message, then it means there is some problem and processing should be stopped
  PROCEDURE validate_transaction(
    p_transaction_id    IN NUMBER,
    p_validation_type   IN VARCHAR2,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag     IN VARCHAR2,
    p_codepath          IN OUT NOCOPY VARCHAR2
  ) IS

    r_trx                   c_trx%ROWTYPE;
    r_base_trx              c_base_trx%ROWTYPE;
    lv_validation_message   VARCHAR2(100);
    lv_transaction_type     RCV_TRANSACTIONS.transaction_type%TYPE;

    lv_include_cenvat_in_cost   VARCHAR2(5);

    CURSOR c_rg23_part_ii_chk(cp_transaction_id IN NUMBER) IS
      SELECT count(1)
      FROM JAI_CMN_RG_23AC_II_TRXS;

    lv_statement_id     VARCHAR2(5);

    r_jai_receipt_line    c_jai_receipt_line%ROWTYPE;   -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
    lv_source_req         CONSTANT VARCHAR2(3)   := 'REQ';
  BEGIN

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'^ Validate');
    end if;

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.validate', 'START'); /* 1 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_statement_id := '2';
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    OPEN c_jai_receipt_line(r_trx.shipment_line_id);
    FETCH c_jai_receipt_line INTO r_jai_receipt_line;
    CLOSE c_jai_receipt_line;

    IF p_validation_type = 'COMMON' THEN

      lv_statement_id := '5';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      --upper added by narao.
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt' AND upper(r_base_trx.rma_type) NOT IN ('PRODUCTION INPUT', 'GOODS RETURN') THEN
       /*
       ||Start of bug 5378630
       ||Modified the below if statement condition such that the RMA_type 'GOODS RETURN' was changed into GOODS RETURN
       */
      IF r_base_trx.source_document_code = jai_rcv_trx_processing_pkg.source_rma
        AND upper(r_jai_receipt_line.rma_type) NOT IN ('PRODUCTION INPUT', 'GOODS RETURN')
      THEN
        /* End of bug 5378630 */
        lv_validation_message := 'RMA Type Not supported';

      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. ELSIF r_base_trx.attr_cat = 'India Receipt'  THEN
      ELSIF r_base_trx.source_document_code IN ( jai_constants.source_po,lv_source_req ) THEN /* added by aiyer for the bug 5378630 */
        IF r_trx.organization_type = 'M' AND r_trx.item_class IN ('FGIN', 'FGEX')
	   and r_base_trx.source_document_code <> 'INVENTORY'  THEN /* 6030615 - interorg  */
          lv_validation_message := 'Item Class not supported for Manufacturing Transactions';

        --ELSIF r_trx.organization_type = 'T' AND r_trx.item_class = jai_rcv_trx_processing_pkg.NO_SETUP THEN
        --
        ELSE
          lv_statement_id := '5.1';
        END IF;

      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. ELSE
      --  lv_statement_id := '5.2';

      END IF;

      IF lv_transaction_type = 'RECEIVE' THEN
        lv_statement_id := '6';
        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
        IF r_trx.organization_type = 'M' THEN
          IF r_trx.item_cenvatable <> 'Y' THEN
            lv_validation_message := 'Item is not a Cenvatable one';
          END IF;

        ELSIF r_trx.organization_type = 'T' THEN
          IF r_trx.item_trading_flag <> 'Y' THEN
            lv_validation_message := 'Item is not a Tradable one';
          --ELSIF r_trx.excise_in_trading <> 'Y' THEN
          --  lv_validation_message := 'Oraganization Setup for Excise in Trading is not checked';
          ELSIF r_trx.item_excisable <> 'Y' THEN
            lv_validation_message := 'Trading Item is not excisable';
          END IF;
        ELSE
          lv_validation_message := 'No Setup for Organization';
        END IF;

      ELSIF lv_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING') THEN

        lv_statement_id := '7';
        p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
        IF r_trx.organization_type = 'T' THEN
          lv_validation_message := 'No Cenvat/RG Entries are passed for '||lv_transaction_type;
          GOTO end_of_validation;
        END IF;

        lv_statement_id := '7.1';
        p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
        lv_include_cenvat_in_cost := jai_rcv_deliver_rtr_pkg.include_cenvat_in_costing(
                                        p_transaction_id    => p_transaction_id,
                                        p_process_message   => p_process_message,
                                        p_process_status    => p_process_status,
                                        p_codepath          => p_codepath
                                     );

        IF p_process_status IN ('E', 'X') THEN
          RETURN;
        END IF;

        -- if the following condition is satisfied, then we need not pass any CENVAT entries during DELIVER or RTR transactions
        IF lv_include_cenvat_in_cost = 'N' THEN
          lv_validation_message := 'Cenvat Entries are not required for Transaction';
          GOTO end_of_validation;
        END IF;

      ELSIF lv_transaction_type = 'RETURN TO VENDOR' THEN

        lv_statement_id := '8';
        p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
        IF r_trx.organization_type = 'T' THEN
          IF r_trx.item_trading_flag <> 'Y' THEN
            lv_validation_message := 'Item is not a Tradable one';
          --ELSIF r_trx.excise_in_trading <> 'Y' THEN
          --  lv_validation_message := 'Organization Setup for Excise In RG23D is not done';
          ELSIF r_trx.item_excisable <> 'Y' THEN
            lv_validation_message := 'Trading Item is not excisable';

          END IF;
        END IF;

      END IF;

    ELSIF p_validation_type IN ('RECEIVE', 'RETURN TO VENDOR') THEN
      -- lv_validation_message := 'Item Class not supported';
      NULL;
    ELSIF p_validation_type IN ('DELIVER', 'RETURN TO RECEIVING') THEN
      NULL;
    ELSE
      NULL;
    END IF;

    <<end_of_validation>>

    lv_statement_id := '9';
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
    IF lv_validation_message IS NOT NULL THEN
      p_process_status  := 'X';
      p_process_message := lv_validation_message;
    END IF;

    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, NULL, 'END'); /* 9 */

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'CENVAT_RG_PKG.validate_transaction->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

  END validate_transaction;

  -- This procedure assumes that this is called only at the time of RTV
  PROCEDURE generate_excise_invoice(
    p_transaction_id          IN  NUMBER,
    p_organization_id         IN  NUMBER,
    p_location_id             IN  NUMBER,
    p_excise_invoice_no OUT NOCOPY VARCHAR2,
    p_excise_invoice_date OUT NOCOPY DATE,
    p_simulate_flag           IN VARCHAR2,
    p_errbuf OUT NOCOPY VARCHAR2,
    p_codepath                IN OUT NOCOPY VARCHAR2
  ) IS

    CURSOR c_rtv_excise_inv_no(cp_transaction_id IN NUMBER) IS
      SELECT excise_invoice_no, excise_invoice_date
      FROM JAI_RCV_RTV_DTLS
      WHERE transaction_id = cp_transaction_id;

    r_trx       c_trx%ROWTYPE;
    lv_statement_id   VARCHAR2(5);
  BEGIN

    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'^ Gen_Exc_inv');
    end if;

    lv_statement_id := '1';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.generate_exc_inv', 'START'); /* 1 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    IF r_trx.transaction_type = 'CORRECT' THEN
      lv_statement_id := '2';
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */

      OPEN c_rtv_excise_inv_no(r_trx.parent_transaction_id);
      FETCH c_rtv_excise_inv_no INTO p_excise_invoice_no, p_excise_invoice_date;
      CLOSE c_rtv_excise_inv_no;
    ELSE
      lv_statement_id := '3';
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      jai_cmn_setup_pkg.generate_excise_invoice_no(
          p_organization_id       => p_organization_id,
          p_location_id           => p_location_id,
          p_called_from           => 'P',         -- Required for excise generation during RTV
          p_order_invoice_type_id => NULL,
          p_fin_year              => jai_general_pkg.get_fin_year(p_organization_id),
          p_excise_inv_no         => p_excise_invoice_no,
          p_errbuf                => p_errbuf
      );

      IF p_excise_invoice_no IS NOT NULL THEN
        p_excise_invoice_date := trunc(SYSDATE);
      END IF;
    END IF;

    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath, NULL, 'END'); /* 4 */

  EXCEPTION
    WHEN OTHERS THEN
      p_errbuf := 'CENVAT_RG_PKG.generate_excise_invoice->'||SQLERRM||', StmtId->'||lv_statement_id;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_errbuf);
      p_codepath := jai_general_pkg.plot_codepath(999, p_errbuf, null, 'END');
      RAISE;

  END generate_excise_invoice;

  FUNCTION get_receive_claimed_ptg(
    p_transaction_id     IN  NUMBER,
    p_shipment_line_id  IN  NUMBER,
    p_codepath        IN OUT NOCOPY VARCHAR2
  ) RETURN NUMBER IS

    CURSOR c_cenvat_claimed_ptg(cp_shipment_line_id IN NUMBER) IS
      SELECT nvl(cenvat_claimed_ptg,0)
      FROM JAI_RCV_CENVAT_CLAIMS
      WHERE shipment_line_id = cp_shipment_line_id;

    ln_cenvat_claimed_ptg         NUMBER;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_excise_processing_pkg.get_receive_claimed_ptg';

    --ln_ancestor_receive_trxn_id   JAI_RCV_TRANSACTIONS.transaction_id%TYPE;

  BEGIN

  /*
    Ancestor should be a RECEIVE type of transaction, because CENVAT is claimed only for RECEIVE transaction and all other
    transactions follow this
    This is the function that should be changed if all Receipt Queries should be based on TRANSACTION_ID instead of SHIPMENT_LINE_ID
  */
    --ln_ancestor_receive_trxn_id :=
    --    jai_rcv_trx_processing_pkg.get_ancestor_id(p_transaction_id, p_shipment_line_id, 'RECEIVE');

    -- commented as pert of review and modified  p_shipment_line_id -> p_transaction_id
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.get_receive_claimed_ptg', 'START'); /* 1 */
    OPEN c_cenvat_claimed_ptg(p_shipment_line_id);
    FETCH c_cenvat_claimed_ptg INTO ln_cenvat_claimed_ptg;
    CLOSE c_cenvat_claimed_ptg;

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath, NULL, 'END'); /* 2 */

    RETURN ln_cenvat_claimed_ptg;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END get_receive_claimed_ptg;

  /*~~~~~~~~~~~~~~~~~~~~~~~~~ TAX BREAUP ~~~~~~~~~~~~~~~~~~~~~~~~~~*/

  PROCEDURE get_tax_amount_breakup(
    p_shipment_line_id  IN      NUMBER,
    p_transaction_id    IN      NUMBER,
    p_curr_conv_rate    IN      NUMBER,
    pr_tax              OUT NOCOPY TAX_BREAKUP,
    p_breakup_type      IN      VARCHAR2,
    p_codepath          IN OUT NOCOPY VARCHAR2
  ) IS

    ln_curr_conv            NUMBER;
    ln_mod_problem_amt      NUMBER;
    ln_nonmod_problem_amt   NUMBER;
    ln_apportion_factor     NUMBER;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_excise_processing_pkg.get_tax_amount_breakup';

  BEGIN
    /* This procedure returns excise amounts as per transaction quantity
    If p_breakup_type is RG23D, then total tax amount should be added to excise amount instead of taking
    mod_cr_percentage into consideration
    */

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.tax_breakup','START'); /* 1 */
    if lb_rg_debug then
      FND_FILE.put_line(FND_FILE.log,'^ tax_breakup');
    end if;

    ln_mod_problem_amt      := 0;
    ln_nonmod_problem_amt   := 0;

    ln_apportion_factor   := jai_rcv_trx_processing_pkg.get_apportion_factor(p_transaction_id);

    FOR tax_rec IN (SELECT  rtl.tax_type                                                                      ,
                            nvl(rtl.tax_amount, 0)                                              tax_amount    ,
                            nvl(rtl.modvat_flag, 'N')                                           modvat_flag   ,
                            nvl(rtl.currency, jai_rcv_trx_processing_pkg.gv_func_curr)      currency      ,
                            nvl(decode(p_breakup_type, 'RG23D', 100, jtc.mod_cr_percentage), 0) mod_cr_percentage,
                            nvl(jtc.rounding_factor, 0)                                         rnd
                    FROM JAI_RCV_LINE_TAXES rtl, JAI_CMN_TAXES_ALL jtc
                    WHERE rtl.shipment_line_id = p_shipment_line_id
                    AND jtc.tax_id = rtl.tax_id)
    LOOP

      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */


      IF tax_rec.currency <> jai_rcv_trx_processing_pkg.gv_func_curr THEN
        ln_curr_conv := NVL(p_curr_conv_rate, 1);
      ELSE
        ln_curr_conv := 1;
      END IF;

      IF p_breakup_type = 'RG23D' THEN    -- trading case
        p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
        IF upper(tax_rec.tax_type) = 'EXCISE' THEN
          p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
          pr_tax.basic_excise   := pr_tax.basic_excise + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

        ELSIF upper(tax_rec.tax_type) = 'ADDL. EXCISE' THEN
          p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
          pr_tax.addl_excise    := pr_tax.addl_excise + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

        ELSIF upper(tax_rec.tax_type) = 'OTHER EXCISE' THEN
          p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
          pr_tax.other_excise   := pr_tax.other_excise + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

        ELSIF tax_rec.tax_type = 'CVD' THEN
          p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
          pr_tax.cvd      := pr_tax.cvd + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

        -- Start, Vijay Shankar for Bug#3940588
        ELSIF tax_rec.tax_type = jai_constants.tax_type_exc_edu_cess THEN
          pr_tax.excise_edu_cess   := pr_tax.excise_edu_cess + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

        ELSIF tax_rec.tax_type = jai_constants.tax_type_cvd_edu_cess THEN
          pr_tax.cvd_edu_cess   := pr_tax.cvd_edu_cess + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        -- End, Vijay Shankar for Bug#3940588
      /*added the following by vkaranam for budget 07 impact - bug#5989740*/
      --start
      ELSIF tax_rec.tax_type = jai_constants.tax_type_sh_cvd_edu_cess THEN
         pr_tax.sh_cvd_edu_cess  := nvl(pr_tax.sh_cvd_edu_cess,0) + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

      ELSIF tax_rec.tax_type = jai_constants.tax_type_sh_exc_edu_cess THEN
			   pr_tax.sh_exc_edu_cess  := nvl(pr_tax.sh_exc_edu_cess,0) + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

      --end bug #5989740*/

        ELSIF tax_rec.tax_type = jai_constants.tax_type_add_cvd THEN
          p_codepath := jai_general_pkg.plot_codepath(7.1, p_codepath); /* 7.1 */
          pr_tax.addl_cvd  := pr_tax.addl_cvd + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        ELSE
          p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
          pr_tax.non_cenvat  := pr_tax.non_cenvat + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        END IF;

      ELSE  -- manufacturing case
        p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */

         IF tax_rec.modvat_flag = 'Y' AND
         upper(tax_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE',
                               'OTHER EXCISE', 'CVD',
             -- Bug 5143906. Added by Lakshmi Gopalsami
             -- Included Addl. CVD
             'ADDITIONAL_CVD',
             jai_constants.tax_type_exc_edu_cess,
             jai_constants.tax_type_cvd_edu_cess,
             /*added the following by vkaranam for budget 07 impact - bug#5989740*/
             jai_constants.tax_type_sh_cvd_edu_cess,
             jai_constants.tax_type_sh_exc_edu_cess)
     THEN

          p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
          IF upper(tax_rec.tax_type) = 'EXCISE' THEN
            p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
            pr_tax.basic_excise := pr_tax.basic_excise
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
            pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

          ELSIF upper(tax_rec.tax_type) = 'ADDL. EXCISE' THEN
            p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
            pr_tax.addl_excise := pr_tax.addl_excise
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
            pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

          ELSIF upper(tax_rec.tax_type) = 'OTHER EXCISE' THEN
            p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
            pr_tax.other_excise := pr_tax.other_excise
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
            pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

          ELSIF tax_rec.tax_type IN ('CVD') THEN
            p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
            pr_tax.cvd := pr_tax.cvd
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
            pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
-- Date 04/06/2007 by sacsethi for bug 6109941
-- Code review from bug 5228046
          ELSIF tax_rec.tax_type IN ( jai_constants.tax_type_add_cvd) THEN
            p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
            pr_tax.addl_cvd := pr_tax.addl_cvd
              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
            pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
-------------------------------------------------
          -- Start, Vijay Shankar for Bug#3940588
          ELSIF tax_rec.tax_type = jai_constants.tax_type_exc_edu_cess THEN
            pr_tax.excise_edu_cess   := pr_tax.excise_edu_cess +
                + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
            pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

          ELSIF tax_rec.tax_type = jai_constants.tax_type_cvd_edu_cess THEN
            pr_tax.cvd_edu_cess   := pr_tax.cvd_edu_cess
                + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
            pr_tax.non_cenvat := pr_tax.non_cenvat
              + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
          -- End, Vijay Shankar for Bug#3940588
         /*added the following by vkaranam for budget 07 impact - bug#5989740*/
        --start
        ELSIF tax_rec.tax_type = jai_constants.tax_type_sh_exc_edu_cess THEN

          pr_tax.sh_exc_edu_cess   := nvl(pr_tax.sh_exc_edu_cess,0)+
					              + round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
					pr_tax.non_cenvat := pr_tax.non_cenvat
					            + round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
			  ELSIF tax_rec.tax_type = jai_constants.tax_type_sh_cvd_edu_cess THEN

				  pr_tax.sh_cvd_edu_cess   := nvl(pr_tax.sh_cvd_edu_cess,0)+
											+ round(tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
				  pr_tax.non_cenvat := pr_tax.non_cenvat
										+ round(tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
	--end ,for bug #5989740


          ELSE
            p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
            ln_mod_problem_amt := ln_mod_problem_amt
              + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
          END IF;

        ELSIF tax_rec.modvat_flag = 'N' and tax_rec.tax_type NOT IN ('TDS', 'Modvat Recovery') THEN
          p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
          pr_tax.non_cenvat := pr_tax.non_cenvat
            + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);

        ELSE
          p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
          ln_nonmod_problem_amt := ln_nonmod_problem_amt
            + round(tax_rec.tax_amount * ln_curr_conv * ln_apportion_factor, tax_rec.rnd);
        END IF;

      END IF;

    END LOOP;

    if lb_rg_debug then
      /*dbms_output.put_line('$tax_breakup. Basic:'||pr_tax.basic_excise||', Addl:'||pr_tax.addl_excise
        ||', Other:'||pr_tax.other_excise||', cvd:'||pr_tax.cvd||', Addl. CVD:'|| pr_tax.addl_cvd||', exc_ces:'||pr_tax.excise_edu_cess||', cvd_ces:'||pr_tax.cvd_edu_cess );

        */
      FND_FILE.put_line(FND_FILE.log, '$tax_breakup. Basic:'||pr_tax.basic_excise||', Addl:'||pr_tax.addl_excise
        ||', Other:'||pr_tax.other_excise||', cvd:'||pr_tax.cvd||', Addl. CVD:'|| pr_tax.addl_cvd||', exc_ces:'||pr_tax.excise_edu_cess||', cvd_ces:'||pr_tax.cvd_edu_cess );
    end if;

    p_codepath := jai_general_pkg.plot_codepath(18, p_codepath, NULL, 'END'); /* 18 */

  EXCEPTION
    WHEN OTHERS THEN
    pr_tax := null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END get_tax_amount_breakup;

  PROCEDURE other_cenvat_rg_recording(
    p_source_register     IN  VARCHAR2,
    p_source_register_id  IN  NUMBER,
    p_tax_type            IN  VARCHAR2,
    p_credit              IN  NUMBER,
    p_debit               IN  NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
  ) IS
    ln_source_type    NUMBER(2);
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_excise_processing_pkg.other_cenvat_rg_recording';
  BEGIN

    IF p_source_register IN (jai_constants.reg_rg23a_2, jai_constants.reg_rg23c_2) THEN
      ln_source_type := jai_constants.reg_rg23_2_code;
    ELSIF p_source_register = jai_constants.reg_rg23d THEN
      ln_source_type := jai_constants.reg_rg23d_code;
    ELSIF p_source_register = jai_constants.reg_pla THEN
      ln_source_type := jai_constants.reg_pla_code;
    ELSIF p_source_register = jai_constants.reg_receipt_cenvat THEN
      ln_source_type := jai_constants.reg_receipt_cenvat_code;
    END IF;

    INSERT INTO JAI_CMN_RG_OTHERS(
      rg_other_id, source_type, source_register,
      source_register_id, tax_type, credit, debit,
      created_by, creation_date, last_updated_by, last_update_date
    ) VALUES (
      JAI_CMN_RG_OTHERS_S.nextval, ln_source_type, p_source_register,
      p_source_register_id, p_tax_type, p_credit, p_debit,
      fnd_global.user_id, sysdate, fnd_global.user_id, sysdate
    );
   EXCEPTION
     WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
     FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
     app_exception.raise_exception;
  END other_cenvat_rg_recording;

  /*~~~~~~~~~~~~~~~~~~~~~~ DERIVING CGIN Scenario ~~~~~~~~~~~~~~~~~~~~~~~~~*/

  PROCEDURE derive_cgin_scenario(
    p_transaction_id      IN  NUMBER,
    p_cgin_code OUT NOCOPY VARCHAR2,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_codepath            IN OUT NOCOPY VARCHAR2
  ) IS

    r_trx                   c_trx%ROWTYPE;

    lv_transaction_type     JAI_RCV_TRANSACTIONS.transaction_type%TYPE;
    ln_receive_claimed_ptg  NUMBER;
    lv_message              VARCHAR2(200);
    lv_object_name varchar2(200) := 'jai_rcv_excise_processing_pkg.dervice_cgin_scenario';

BEGIN

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'cenvat_rg.cgin_scenario' , 'START'); /* 1 */
    if lb_rg_debug then
      -- dbms_output.put_line('^ Drv_CGIN_Scnrio');
      FND_FILE.put_line(FND_FILE.log,'^ Drv_CGIN_Scnrio');
    end if;


  /*
    In 50% claim case there will be another set of entries that needs to be passed in some scenarios and in some scenario it is
    REGULAR key word that appear in p_cgin_code is linked with transaction accounting entries that will happen if there is no concept of 50% Claim

    ____________________________________________________________________________________________________________________________
    | Transaction Type  |Claim No| Accounting Entries                           |  Comments
    | ----------------  |--------| ------------------------------               |  -------------------
    | RECEIVE           |      1 | X   - Dr. Modvat CG, Cr. Inventory Receiving |
    |                   |        | X/2 - Dr. Cenvat Receivable, Cr. Modvat CG   |  Code = 'REGULAR-FULL + REVERSAL-HALF'
    |                   |        |                                              |
    |                   |      2 | X/2 - Dr. Modvat RG, Cr. Cenvat Receivable   |  There cant be no Claim in case of Delivery
    |                   |        |                                              |  Code = 'REGULAR-HALF'
    |                   |        |                                              |  to NonBonded Subinventory
    |                   |        |                                              |
    | DELIVER           |        | X   - Dr. Inventory Receiving, Dr. Modvat CG |  Code = 'REGULAR-FULL + REVERSAL-HALF'
    |  (NonBondedSubinv)|        | X/2 - Dr. Modvat CG, Cr. Cenvat Receivable   |
    |                   |        |                                              |
    | RTR               |        | X   - Dr. Modvat CG, Dr. Inventory Receiving |  Code = 'REGULAR-FULL + REVERSAL-HALF'
    |  (NonBondedSubinv)|        | X/2 - Dr. Cenvat Receivable, Cr. Modvat CG   |
    |                   |        |                                              |
    | RTV               |        |Case 1: Parent Receive was 50% Claimed        |
    |                   |        | X/2 - Dr. Cenvat Receivable, Cr. Modvat CG   |  X/2 Amount is to 50% Claim of Parent Trxn
    |                   |        | X   - Dr. Inventory Receiving, Cr. Modvat RG |  This is Regular Entry that happens during RTV
    |                   |        |                                              |  Code = 'REGULAR-FULL + PARENT-REGULAR-HALF'
    |                   |        |                                              |
    |                   |        |Case 2: Parent Receive was 100% Claimed       |
    |                   |        | X   - Dr. Inventory Receiving, Cr. Modvat RG |  Parent is fully claimed. no need of passing X/2 entry
    |                   |        |                                              |  Code = 'REGULAR-FULL'
    ____________________________________________________________________________________________________________________________

    NOTE: If Parent Receive is Claimed 100% then Code returned is
              - REGULAR Full for DELIVER/RTR and related CORRECT transactions
              - REGUALR FULL/REGULAR HALF  for RECEIVE CORRECTion if CORRECT is not yet Claimed/50% claimed

    X is the Full Cenvat Amount of RECEIVE Line

    Possible Values of RETURN Codes
      1) 'REGULAR-FULL + REVERSAL-HALF'
      2) 'REGULAR-HALF'
      3) 'REGULAR-FULL'
      4) 'REGULAR-FULL + PARENT-REGULAR-HALF'
  */

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    IF r_trx.cenvat_claimed_ptg = 100 THEN
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      lv_message := 'Transaction is already full claimed';
      GOTO end_of_call;
    END IF;

    ln_receive_claimed_ptg    := get_receive_claimed_ptg(p_transaction_id, r_trx.shipment_line_id, p_codepath);
    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */

    IF r_trx.transaction_type = 'CORRECT' THEN
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      lv_transaction_type := r_trx.parent_transaction_type;
    ELSE
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      lv_transaction_type := r_trx.transaction_type;
    END IF;

    --following if block only for RECEIVE transactions
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    IF r_trx.transaction_type = 'RECEIVE' THEN        --, 'DELIVER', 'RETURN TO RECEIVING') THEN
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */

      IF r_trx.cenvat_claimed_ptg = 0 THEN
        p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
        p_cgin_code := 'REGULAR-FULL + REVERSAL-HALF';

      -- RECEIVE is 50% claimed case
      ELSIF r_trx.cenvat_claimed_ptg < 100 THEN
        p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
        p_cgin_code := 'REGULAR-HALF';

      -- RECEIVE is 100% claimed case
      ELSIF r_trx.cenvat_claimed_ptg = 100 THEN
        p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
        lv_message := 'Transaction is Fully Claimed';
        GOTO end_of_call;
      END IF;

    -- this elsif for DELIVER, RETURN TO RECEIVING, CORRECT of RECEIVE, DELIVER and RETURN TO RECEIVING
    ELSIF lv_transaction_type IN ('RECEIVE', 'DELIVER', 'RETURN TO RECEIVING') THEN
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */

      IF ln_receive_claimed_ptg = 0 THEN

        p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
        lv_message := 'Parent Receive Transaction is not Claimed';
        GOTO end_of_call;

      -- RECEIVE is 50% claimed case
      ELSIF ln_receive_claimed_ptg < 100 THEN

        p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
        IF r_trx.cenvat_claimed_ptg = 0 THEN
          p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
          p_cgin_code := 'REGULAR-FULL + REVERSAL-HALF';
        ELSIF r_trx.cenvat_claimed_ptg = 50 THEN
          p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
          lv_message := 'Second Claim did not happen for Parent transaction';
          GOTO end_of_call;
        END IF;

      -- RECEIVE is 100% claimed case
      ELSIF ln_receive_claimed_ptg = 100 THEN
        p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
        IF r_trx.cenvat_claimed_ptg = 0 THEN
          p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */
          p_cgin_code := 'REGULAR-FULL';
        ELSIF r_trx.cenvat_claimed_ptg < 100 THEN
          p_codepath := jai_general_pkg.plot_codepath(19, p_codepath); /* 19 */
          p_cgin_code := 'REGULAR-HALF';
        END IF;
      END IF;

    ELSIF lv_transaction_type = 'RETURN TO VENDOR' THEN

      p_codepath := jai_general_pkg.plot_codepath(20, p_codepath); /* 20 */
      -- Need to implement this. Very Complicated One
      IF ln_receive_claimed_ptg = 0 THEN
        p_codepath := jai_general_pkg.plot_codepath(21, p_codepath); /* 21 */
        lv_message := 'Parent Receive Transaction is not Claimed';
        GOTO end_of_call;

      -- RECEIVE is 50% claimed case
      ELSIF ln_receive_claimed_ptg < 100 THEN
        p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); /* 22 */
        -- following modified by Vijay Shankar for Bug#3940588
         p_cgin_code := 'REGULAR-FULL + PARENT-REGULAR-HALF';/*uncommented by vkaranam fro bug #4704957*/
        --p_cgin_code := 'REGULAR-FULL + REVERSAL-HALF';/*commented by vkaranam fro bug #4704957*/

      -- RECEIVE is 100% claimed case
      ELSIF ln_receive_claimed_ptg = 100 THEN
        p_codepath := jai_general_pkg.plot_codepath(23, p_codepath); /* 23 */
        p_cgin_code := 'REGULAR-FULL';

      END IF;
      p_codepath := jai_general_pkg.plot_codepath(24, p_codepath); /* 24 */

    END IF;

    <<end_of_call>>
    p_codepath := jai_general_pkg.plot_codepath(25, p_codepath); /* 25 */

    IF lv_message IS NOT NULL THEN
      p_process_status  := 'E';
      p_process_message := lv_message;
      RETURN;
    END IF;
    p_codepath := jai_general_pkg.plot_codepath(26, p_codepath, NULL, 'END'); /* 26 */
  EXCEPTION
    WHEN OTHERS THEN
    p_cgin_code := null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END derive_cgin_scenario;

  PROCEDURE derive_duty_registers(
    p_organization_id           IN      NUMBER,
    p_location_id               IN      NUMBER,
    p_item_class                IN      VARCHAR2,
    pr_tax                      IN      TAX_BREAKUP,
    p_cenvat_register_type OUT NOCOPY VARCHAR2,
    -- p_edu_cess_register_type        OUT VARCHAR2,
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  ) IS

    r_orgn_info               c_orgn_info%ROWTYPE;

    lv_process_flag           JAI_RCV_TRANSACTIONS.PROCESS_STATUS%TYPE;
    lv_process_message        JAI_RCV_TRANSACTIONS.process_message%TYPE;

    lv_pref1_register         VARCHAR2(30);
    lv_pref2_register         VARCHAR2(30);

    lv_cess_pref1_register    VARCHAR2(30);
    lv_cess_pref2_register    VARCHAR2(30);

    /*
    (x) If PREF_PLA = 1 then directly check balances in PLA
        a) if ssi_unit_flag='Y' then no need of checking balances, return cenvat_register as PLA
        b) elsif ssi_unit_flag='N' then
          i) check balances in PLA
          ii) check balances in respective registers  based on ITEM CLASS

    (y) If PREF_PLA <> 1, then
        a) check balances in respective register based on ITEM CLASS
        b) if (a) fails then check (a), b(i) of (x)
    */

  BEGIN

    FND_FILE.put_line( fnd_file.log, '^derive_duty_registers');
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'CENVAT_RG_PKG.DRV_DUTY_REG' , 'START');

    OPEN c_orgn_info(p_organization_id, p_location_id);
    FETCH c_orgn_info INTO r_orgn_info;
    CLOSE c_orgn_info;

    IF r_orgn_info.pref_pla = 1 THEN
      lv_pref1_register         := jai_constants.register_type_pla;
      lv_cess_pref1_register    := jai_constants.reg_pla;

      IF p_item_class IN ('CGIN','CGEX') THEN
        p_codepath := jai_general_pkg.plot_codepath(2, p_codepath);
        lv_pref2_register       := jai_constants.register_type_c;
        lv_cess_pref2_register  := jai_constants.reg_rg23c;
      ELSE
        p_codepath := jai_general_pkg.plot_codepath(3, p_codepath);
        lv_pref2_register       := jai_constants.register_type_a;
        lv_cess_pref2_register  := jai_constants.reg_rg23a;
      END IF;

    ELSE  -- IF r_orgn_info.pref_rg23a = 1 THEN

      IF p_item_class IN ('CGIN','CGEX') THEN
        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath);
        lv_pref1_register       := jai_constants.register_type_c;
        lv_cess_pref1_register  := jai_constants.reg_rg23c;
      ELSE
        p_codepath := jai_general_pkg.plot_codepath(5, p_codepath);
        lv_pref1_register       := jai_constants.register_type_a;
        lv_cess_pref1_register  := jai_constants.reg_rg23a;
      END IF;

      lv_pref2_register         := jai_constants.register_type_pla;
      lv_cess_pref2_register    := jai_constants.reg_pla;

    END IF;

    IF lb_rg_debug THEN
      FND_FILE.put_line( fnd_file.log, 'Org PlaPref:'||r_orgn_info.pref_pla||', 23aPref:'||r_orgn_info.pref_rg23a
        ||', 23cPref:'||r_orgn_info.pref_rg23c||', pref1_reg:'||lv_pref1_register||', pref2_reg:'||lv_pref2_register
        ||', AllowNegative:'||r_orgn_info.allow_negative_pla
      );
      /*dbms_output.put_line( 'Org PlaPref:'||r_orgn_info.pref_pla||', 23aPref:'||r_orgn_info.pref_rg23a
        ||', 23cPref:'||r_orgn_info.pref_rg23c||', pref1_reg:'||lv_pref1_register||', pref2_reg:'||lv_pref2_register
        ||', AllowNegative:'||r_orgn_info.allow_negative_pla);
        */
    END IF;

    IF    lv_pref1_register = jai_constants.register_type_pla
      AND r_orgn_info.allow_negative_pla = jai_constants.yes
    THEN
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath);
      p_cenvat_register_type    := jai_constants.register_type_pla;
      GOTO end_of_procedure;
    END IF;

    /* BALANCES CHECKING */
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);
    check_cenvat_balances(
      p_organization_id       => p_organization_id,
      p_location_id           => p_location_id,
      p_transaction_amount    => pr_tax.basic_excise +
                                 pr_tax.addl_excise +
				 pr_tax.other_excise +
				 pr_tax.cvd +
				 pr_tax.addl_cvd ,    -- Date 30/10/2006 Bug 5228046 added by sacsethi
      p_register_type         => lv_pref1_register,
      p_process_flag          => lv_process_flag,
      p_process_message       => lv_process_message
    );

    IF lv_process_flag = jai_constants.unexpected_error THEN
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
      p_process_flag    := 'E';
      p_process_message :=  lv_process_message;
      GOTO end_of_procedure;

    ELSIF lv_process_flag = jai_constants.expected_error THEN
      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath);

    ELSIF lv_process_flag = jai_constants.successful THEN

      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath);
      IF pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess <> 0 THEN /* This if condition and its else added by ssumaith - bug# 4187859*/
          jai_cmn_rg_others_pkg.check_balances(
            p_organization_id   => p_organization_id ,
            p_location_id       => p_location_id,
            p_register_type     => lv_cess_pref1_register,
            p_trx_amount        => pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess,
            p_process_flag      => lv_process_flag,
            p_process_message   => lv_process_message
          );

          IF lv_process_flag = jai_constants.unexpected_error THEN
            p_codepath := jai_general_pkg.plot_codepath(12, p_codepath);
            p_process_flag    := 'E';
            p_process_message :=  lv_process_message;
            GOTO end_of_procedure;

          ELSIF lv_process_flag = jai_constants.expected_error THEN
            p_codepath := jai_general_pkg.plot_codepath(13, p_codepath);
          ELSIF lv_process_flag = jai_constants.successful THEN
            p_codepath := jai_general_pkg.plot_codepath(14, p_codepath);
            p_cenvat_register_type  := lv_pref1_register;
            GOTO end_of_procedure;
          END IF;
   /*added the following by vkaranam for budget 07 impact - bug#5989740*/
    --start
    ELSIF nvl(pr_tax.sh_exc_edu_cess,0) + nvl(pr_tax.sh_cvd_edu_cess,0) <> 0 THEN

		          jai_cmn_rg_others_pkg.check_sh_balances(
		          p_organization_id   => p_organization_id ,
		          p_location_id       => p_location_id,
		          p_register_type     => lv_cess_pref1_register,
		          p_trx_amount        => nvl(pr_tax.sh_exc_edu_cess,0) + nvl(pr_tax.sh_cvd_edu_cess,0),
		          p_process_flag      => lv_process_flag,
		          p_process_message   => lv_process_message
		        );

		        IF lv_process_flag = jai_constants.unexpected_error THEN
		          p_codepath := jai_general_pkg.plot_codepath(14.1, p_codepath);
		          p_process_flag    := 'E';
		          p_process_message :=  lv_process_message;
		          GOTO end_of_procedure;

		        ELSIF lv_process_flag = jai_constants.expected_error THEN
		          p_codepath := jai_general_pkg.plot_codepath(14.2, p_codepath);
		        ELSIF lv_process_flag = jai_constants.successful THEN
		          p_codepath := jai_general_pkg.plot_codepath(14.3, p_codepath);
		          p_cenvat_register_type  := lv_pref1_register;
		          GOTO end_of_procedure;
           END IF;
    --end bug #5989740

      ELSE
         lv_process_flag    := jai_constants.successful;
         lv_process_message := NULL;
         goto end_of_procedure;
      END IF;
    END IF;

    IF lv_pref2_register = jai_constants.register_type_pla
      AND r_orgn_info.allow_negative_pla = jai_constants.yes
    THEN
      p_codepath := jai_general_pkg.plot_codepath(15, p_codepath);
      p_cenvat_register_type  := lv_pref2_register;
      GOTO end_of_procedure;
    END IF;

    p_codepath := jai_general_pkg.plot_codepath(16, p_codepath);
    check_cenvat_balances(
      p_organization_id       => p_organization_id,
      p_location_id           => p_location_id,
      p_transaction_amount    => pr_tax.basic_excise +
                                 pr_tax.addl_excise +
				 pr_tax.other_excise +
				 pr_tax.cvd +
				 pr_tax.addl_cvd,  -- Date 04/06/2007 by sacsethi for bug 6109941
      p_register_type         => lv_pref2_register,
      p_process_flag          => lv_process_flag,
      p_process_message       => lv_process_message
    );

    IF lv_process_flag = jai_constants.unexpected_error THEN
      p_codepath := jai_general_pkg.plot_codepath(17, p_codepath);
      p_process_flag    := 'E';
      p_process_message :=  lv_process_message;
      GOTO end_of_procedure;

    ELSIF lv_process_flag = jai_constants.expected_error THEN
      p_codepath := jai_general_pkg.plot_codepath(18, p_codepath);
      p_process_flag    := 'E';
      p_process_message :=  'Sufficient Balances are not available in both '||lv_pref1_register||' and '||lv_pref2_register||' registers';
      GOTO end_of_procedure;

    ELSIF lv_process_flag = jai_constants.successful THEN

      p_codepath := jai_general_pkg.plot_codepath(19, p_codepath);

      IF pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess <> 0 THEN /* This if condition and its else added by ssumaith - bug# 4187859*/
          jai_cmn_rg_others_pkg.check_balances(
            p_organization_id   => p_organization_id ,
            p_location_id       => p_location_id,
            p_register_type     => lv_cess_pref2_register,
            p_trx_amount        => pr_tax.excise_edu_cess + pr_tax.cvd_edu_cess,
            p_process_flag      => lv_process_flag,
            p_process_message   => lv_process_message
          );
          IF lv_process_flag = jai_constants.unexpected_error THEN
            p_codepath := jai_general_pkg.plot_codepath(20, p_codepath);
            p_process_flag    := 'E';
            p_process_message :=  lv_process_message;
            GOTO end_of_procedure;

          ELSIF lv_process_flag = jai_constants.expected_error THEN
            p_codepath := jai_general_pkg.plot_codepath(21, p_codepath);
            p_process_flag    := 'E';
            p_process_message :=  'Sufficient Balances are not available in both '||lv_pref1_register||' and '||lv_pref2_register||' registers';
            GOTO end_of_procedure;

          ELSIF lv_process_flag = jai_constants.successful THEN
            p_codepath := jai_general_pkg.plot_codepath(22, p_codepath);
            p_cenvat_register_type  := lv_pref2_register;
            GOTO end_of_procedure;
          END IF;
/*added the following by vkaranam for budget 07 impact - bug#5989740*/
     --start
     ELSIF nvl(pr_tax.sh_exc_edu_cess,0) + nvl(pr_tax.sh_cvd_edu_cess,0) <> 0 THEN

 	  jai_cmn_rg_others_pkg.check_sh_balances(
 	  p_organization_id   => p_organization_id ,
 	  p_location_id       => p_location_id,
 	  p_register_type     => lv_cess_pref2_register,
 	  p_trx_amount        => nvl(pr_tax.sh_exc_edu_cess,0) + nvl(pr_tax.sh_cvd_edu_cess,0),
 	  p_process_flag      => lv_process_flag,
 	  p_process_message   => lv_process_message
 	);

 	IF lv_process_flag = jai_constants.unexpected_error THEN
 	  p_codepath := jai_general_pkg.plot_codepath(22.1, p_codepath);
 	  p_process_flag    := 'E';
 	  p_process_message :=  lv_process_message;
 	  GOTO end_of_procedure;

 	ELSIF lv_process_flag = jai_constants.expected_error THEN
	   p_codepath := jai_general_pkg.plot_codepath(22.2, p_codepath);
	   p_process_flag    := 'E';
	   p_process_message :=  'Sufficient Balances are not available in both '||lv_pref1_register||' and '||lv_pref2_register||' registers';
	   GOTO end_of_procedure;

        ELSIF lv_process_flag = jai_constants.successful THEN
	   p_codepath := jai_general_pkg.plot_codepath(22.3, p_codepath);
	   p_cenvat_register_type  := lv_pref2_register;
	   GOTO end_of_procedure;
        END IF;

     --end bug #5989740


      ELSE
          lv_process_flag    := jai_constants.successful;
          lv_process_message := NULL;
          goto end_of_procedure;
      END IF;
    END IF;

    <<end_of_procedure>>

    p_codepath := jai_general_pkg.plot_codepath(25, p_codepath, 'CENVAT_RG_PKG.DRV_DUTY_REG' , 'END');
    FND_FILE.put_line( fnd_file.log, '$derive_duty_registers. Register Type:'||p_cenvat_register_type);
    -- dbms_output.put_line( '$derive_duty_registers. Register Type:'||p_cenvat_register_type);

  EXCEPTION
    WHEN OTHERS THEN
      p_process_flag    := 'E';
      p_process_message := 'DERIVE_DUTY_REGISTERS: Error:'||SQLERRM;
      p_codepath := jai_general_pkg.plot_codepath(-999, p_codepath, 'CENVAT_RG_PKG.DRV_DUTY_REG' , 'END');

  END derive_duty_registers;

  PROCEDURE check_cenvat_balances(
    p_organization_id           IN      NUMBER,
    p_location_id               IN      NUMBER,
    p_transaction_amount        IN      NUMBER,
    p_register_type             IN      VARCHAR2,
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
  ) IS

    CURSOR c_orgn_balances(cp_organization_id IN NUMBER, cp_location_id IN NUMBER, cp_register_type IN VARCHAR2) IS
      SELECT  decode( cp_register_type,
                      jai_constants.register_type_pla, pla_balance,
                      jai_constants.register_type_a, rg23a_balance,
                      jai_constants.register_type_c, rg23c_balance
                    )
      FROM JAI_CMN_RG_BALANCES
      WHERE organization_id = cp_organization_id
      AND location_id = cp_location_id;

    ln_current_balance  NUMBER;

  BEGIN

    OPEN c_orgn_balances(p_organization_id, p_location_id, p_register_type);
    FETCH c_orgn_balances INTO ln_current_balance;
    CLOSE c_orgn_balances;

    IF ( nvl(ln_current_balance,0) - nvl(p_transaction_amount,0)) < 0 THEN
      p_process_flag    := jai_constants.expected_error;
      p_process_message := 'Sufficient Balances are not available in '''||p_register_type||''' register';
    ELSE
      p_process_flag    := jai_constants.successful;
    END IF;

  END check_cenvat_balances;

  procedure rtv_processing_for_ssi(
    pn_transaction_id                 NUMBER,
    pv_codepath         in out nocopy varchar2,
    pv_process_status   out nocopy    varchar2,
    pv_process_message  out nocopy    varchar2
  ) is

    cursor c_rtv_dtls(cp_transaction_id in number) is
      select receipt_excise_rate, rtv_excise_rate, excise_basis_amt
      from jai_rcv_rtv_batch_trxs
      where transaction_id = cp_transaction_id;

    lv_stform_type JAI_CMN_TAXES_ALL.stform_type%type ;

    cursor c_excise_cess_rate(cp_shipment_line_id in number) is
      select a.tax_rate, b.tax_account_id, a.tax_id
      from JAI_RCV_LINE_TAXES a, JAI_CMN_TAXES_ALL b
      where a.shipment_line_id = cp_shipment_line_id
      and a.tax_id = b.tax_id
      and ( a.tax_type = jai_constants.tax_type_exc_edu_cess
            -- following is to take care of Initial solution(Year2004) for Excise Cess func.
	    or (a.tax_type = jai_constants.tax_type_other and b.stform_type =  lv_stform_type) --'EXCISE - CESS') /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
            --or (a.tax_type = 'Other' and b.stform_type = 'EXCISE - CESS')
          );

		--added by csahoo for bug#6078460
		cursor c_excise_sh_cess_rate(cp_shipment_line_id in number) is
					select a.tax_rate, b.tax_account_id, a.tax_id
					from JAI_RCV_LINE_TAXES a, JAI_CMN_TAXES_ALL b
					where a.shipment_line_id = cp_shipment_line_id
					and a.tax_id = b.tax_id
					and ( a.tax_type = jai_constants.tax_type_sh_exc_edu_cess
								-- following is to take care of Initial solution(Year2004) for Excise sh Cess func.
					or (a.tax_type = jai_constants.tax_type_other and b.stform_type =  lv_stform_type)
				 );

    cursor c_po_dist_accrual_accnt_id(cp_transaction_id in number) is
      select accrual_account_id
      from po_distributions_all a,
          ( select po_line_location_id
            from rcv_transactions
            where transaction_id = cp_transaction_id) b
      where a.line_location_id = b.po_line_location_id;

    cursor c_mtl_ap_accrual_accnt_id(cp_organization_id in number) is
      select ap_accrual_account
      from mtl_parameters
      where organization_id = cp_organization_id;

    r_trx                     c_trx%ROWTYPE;
    r_orgn_info               c_orgn_info%ROWTYPE;

    lv_reference10            gl_interface.reference10%TYPE;
    lv_reference23            gl_interface.reference23%TYPE;
    lv_reference24            gl_interface.reference24%TYPE;
    lv_reference25            gl_interface.reference26%TYPE;
    lv_reference26            gl_interface.reference25%TYPE;
    lv_reference_name         JAI_RCV_JOURNAL_ENTRIES.reference_name%TYPE;
    ln_reference_id           JAI_RCV_JOURNAL_ENTRIES.reference_id%TYPE;

    lv_accounting_date        DATE;
    lv_acct_nature            JAI_RCV_JOURNAL_ENTRIES.acct_nature%TYPE;
    lv_acct_type              JAI_RCV_JOURNAL_ENTRIES.acct_type%TYPE;

    r_diff_tax                jai_rcv_excise_processing_pkg.TAX_BREAKUP;
    r_rtv_dtls                c_rtv_dtls%ROWTYPE;

    ln_excise_cess_tax_id     JAI_CMN_TAXES_ALL.tax_id%TYPE;
    ln_excise_cess_rate       NUMBER;
    ln_excise_cess_accnt_id   gl_code_combinations.code_combination_id%TYPE;
    --added by csahoo for bug#6078460, start
    ln_excise_sh_cess_tax_id     JAI_CMN_TAXES_ALL.tax_id%TYPE;
		ln_excise_sh_cess_rate       NUMBER;
    ln_excise_sh_cess_accnt_id   gl_code_combinations.code_combination_id%TYPE;
    --added by csahoo for bug#6078460, end
    lv_cenvat_register_type   VARCHAR2(30);
    lv_reference_num          JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE;
    lv_simulate_flag          VARCHAR2(1);

    ln_part_ii_register_id    NUMBER(15);
    lv_register_entry_type    VARCHAR2(15);

    ln_ccid                   gl_code_combinations.code_combination_id%TYPE;
    ln_credit_amt             number;
    ln_debit_amt              number;

    ln_balancing_ccid         gl_code_combinations.code_combination_id%TYPE;
    ln_balancing_credit_amt   number;
    ln_balancing_debit_amt    number;

    lv_statement_id           VARCHAR2(4);

    -- Bug 5365346. Added by Lakshmi Gopalsami
    r_base_trx                c_base_trx%ROWTYPE;
  begin

    lv_statement_id := '1';
    pv_codepath := jai_general_pkg.plot_codepath(1, pv_codepath, 'jai_rcv_excise_processing_pkg.rtv_processing_for_ssi', 'START');
    lv_simulate_flag        := jai_constants.no;
    lv_register_entry_type  := jai_rcv_excise_processing_pkg.cenvat_debit;

    open c_trx(pn_transaction_id);
    fetch c_trx into r_trx;
    close c_trx;

    -- bug 5365346. Added by Lakshmi Gopalsami
    OPEN  c_base_trx(pn_transaction_id);
     FETCH  c_base_trx INTO  r_base_trx;
    CLOSE  c_base_trx;

    open c_rtv_dtls(pn_transaction_id);
    fetch c_rtv_dtls into r_rtv_dtls;
    close c_rtv_dtls;
    r_diff_tax.basic_excise  := r_rtv_dtls.excise_basis_amt * (r_rtv_dtls.rtv_excise_rate - r_rtv_dtls.receipt_excise_rate) / 100;

     lv_statement_id := '2';
    if nvl(r_diff_tax.basic_excise, 0) <> 0 then
     lv_stform_type := 'EXCISE - CESS' ;
      open c_excise_cess_rate(r_trx.shipment_line_id);
      fetch c_excise_cess_rate into ln_excise_cess_rate, ln_excise_cess_accnt_id, ln_excise_cess_tax_id;
      close c_excise_cess_rate;
      r_diff_tax.excise_edu_cess := nvl(ln_excise_cess_rate, 0) * r_diff_tax.basic_excise/100;
    else
      GOTO end_of_procedure;
    end if;

    if r_diff_tax.excise_edu_cess <> 0 and ln_excise_cess_accnt_id is null then
      lv_statement_id := '2.1';
      pv_codepath := jai_general_pkg.plot_codepath(2.1, pv_codepath);
      pv_process_status := 'E';
      pv_process_message := 'Excise Education cess account is not defined in the tax. (TaxId:'||ln_excise_cess_tax_id||')';
      GOTO end_of_procedure;
    end if;

    --added by csahoo for bug#6078460, start
		if nvl(r_diff_tax.basic_excise, 0) <> 0 then
		 lv_stform_type := 'EXCISE - SH - CESS' ;
			open c_excise_sh_cess_rate(r_trx.shipment_line_id);
			fetch c_excise_sh_cess_rate into ln_excise_sh_cess_rate, ln_excise_sh_cess_accnt_id, ln_excise_sh_cess_tax_id;
			close c_excise_sh_cess_rate;
			r_diff_tax.sh_exc_edu_cess := nvl(ln_excise_sh_cess_rate, 0) * r_diff_tax.basic_excise/100;
		else
			GOTO end_of_procedure;
		end if;

		if r_diff_tax.sh_exc_edu_cess <> 0 and ln_excise_sh_cess_accnt_id is null then
			lv_statement_id := '2.1';
			pv_codepath := jai_general_pkg.plot_codepath(2.1, pv_codepath);
			pv_process_status := 'E';
			pv_process_message := 'Excise SH Education cess account is not defined in the tax. (TaxId:'||ln_excise_sh_cess_tax_id||')';
			GOTO end_of_procedure;
    end if;
    --added by csahoo for bug#6078460, end

    lv_statement_id := '3';
    /* Start Register Entry */
    jai_rcv_excise_processing_pkg.derive_duty_registers(
      p_organization_id           => r_trx.organization_id,
      p_location_id               => r_trx.location_id,
      p_item_class                => r_trx.item_class,
      pr_tax                      => r_diff_tax,
      p_cenvat_register_type      => lv_cenvat_register_type,
      p_process_flag              => pv_process_status,
      p_process_message           => pv_process_message,
      p_codepath                  => pv_codepath
    );

    lv_statement_id := '4';
    if pv_process_status = 'E' then
      GOTO end_of_procedure;
    end if;

    if lv_cenvat_register_type IN (jai_constants.register_type_a, jai_constants.register_type_c) then

      lv_statement_id := '5';
      pv_codepath := jai_general_pkg.plot_codepath(17, pv_codepath);

      lv_reference_num := 'CENVAT-SSI';
      /*
      jai_rcv_excise_processing_pkg.rg23_part_ii_entry(
          p_transaction_id        => r_trx.transaction_id,
	  pr_tax                  => r_diff_tax,
          p_part_i_register_id    => null,
          p_register_entry_type   => lv_register_entry_type,
          p_reference_num         => lv_reference_num,
          p_register_id           => ln_part_ii_register_id,
          p_process_status        => pv_process_status,
          p_process_message       => pv_process_message,
          p_simulate_flag         => lv_simulate_flag,
          p_codepath              => pv_codepath
      );
      */
      BEGIN
	      update_RTV_Diff_value
	      ( pr_base_trx          => r_base_trx,
		pr_tax               => r_trx,
		pr_diff_tax          => r_diff_tax,
		p_source_reg         => 'RG23II',
		p_register_entry_type => lv_register_entry_type,
		p_register_id         => ln_part_ii_register_id,
		p_simulate_flag       => lv_simulate_flag,
		p_codepath            => pv_codepath,
		p_process_status      => pv_process_status,
		p_process_message     => pv_process_message
	      );
      EXCEPTION
        WHEN OTHERS THEN
	  fnd_file.put_line(FND_FILE.LOG, ' exception ' || SQLERRM);
      END ;
      lv_statement_id := '6';
      IF pv_process_status IN ('E', 'X') THEN
        GOTO end_of_procedure;
      END IF;
      lv_reference_name := 'JAI_CMN_RG_23AC_II_TRXS';
      ln_reference_id   := ln_part_ii_register_id;
    elsif lv_cenvat_register_type = jai_constants.register_type_pla THEN
      lv_statement_id := '7';
      pv_codepath := jai_general_pkg.plot_codepath(17.1, pv_codepath);
      /* Bug 5365346. Added by Lakshmi Gopalsami
         Commented the call to pla entry and added
      jai_rcv_excise_processing_pkg.pla_entry(
          p_transaction_id      => r_trx.transaction_id,
          pr_tax                => r_diff_tax,
          p_register_entry_type => lv_register_entry_type,
          p_register_id         => ln_part_ii_register_id,
          p_process_status      => pv_process_status,
          p_process_message     => pv_process_message,
          p_simulate_flag       => lv_simulate_flag,
          p_codepath            => pv_codepath
      );
      */
      Begin
	      update_RTV_Diff_value
	      ( pr_base_trx          => r_base_trx,
		pr_tax               => r_trx,
		pr_diff_tax          => r_diff_tax,
		p_source_reg         => 'PLA',
		p_register_entry_type => lv_register_entry_type,
		p_register_id         => ln_part_ii_register_id,
		p_simulate_flag       => lv_simulate_flag,
		p_codepath            => pv_codepath,
		p_process_status      => pv_process_status,
		p_process_message     => pv_process_message
	      );
      Exception
        WHEN OTHERS THEN
	  fnd_file.put_line(FND_FILE.LOG, ' exception ' || SQLERRM);
      END ;
      lv_statement_id := '8';
      IF pv_process_status IN ('E', 'X') THEN
        GOTO end_of_procedure;
      END IF;
      lv_reference_name := 'JAI_CMN_RG_PLA_TRXS';
      ln_reference_id   := ln_part_ii_register_id;
    else
      lv_statement_id := '9';
      pv_codepath := jai_general_pkg.plot_codepath(17.2, pv_codepath);
      pv_process_status := 'E';
      pv_process_message := 'Duty Register cannot be derived';
      GOTO end_of_procedure;
    end if;
    /* End Register Entry */

    lv_statement_id := '10';
    open c_orgn_info(r_trx.organization_id, r_trx.location_id);
    fetch c_orgn_info into r_orgn_info;
    close c_orgn_info;

    if lv_cenvat_register_type = jai_constants.register_type_a then
      lv_statement_id := '11';
      ln_ccid := r_orgn_info.modvat_rm_account_id;
    elsif lv_cenvat_register_type = jai_constants.register_type_c then
      lv_statement_id := '12';
      ln_ccid := r_orgn_info.modvat_cg_account_id;
    elsif lv_cenvat_register_type = jai_constants.register_type_pla then
      lv_statement_id := '13';
      ln_ccid := r_orgn_info.modvat_pla_account_id;
    end if;

    if ln_ccid is null then
      lv_statement_id := '14';
      pv_process_status    := 'E';
      pv_process_message := 'Modvat '||lv_cenvat_register_type||' account in Organization Setup doesnot exist';
      GOTO end_of_procedure;
    end if;

    if r_orgn_info.rtv_account_flag = jai_constants.yes then
      ln_balancing_ccid := r_orgn_info.rtv_expense_account_id;
      if ln_balancing_ccid is null then
        null;
      end if;
    elsif r_orgn_info.rtv_account_flag = jai_constants.no then

      open c_po_dist_accrual_accnt_id(r_trx.transaction_id);
      fetch c_po_dist_accrual_accnt_id into ln_balancing_ccid;
      close  c_po_dist_accrual_accnt_id;

      if ln_balancing_ccid is null then
        open c_po_dist_accrual_accnt_id(r_trx.transaction_id);
        fetch c_po_dist_accrual_accnt_id into ln_balancing_ccid;
        close  c_po_dist_accrual_accnt_id;
      end if;

    end if;

    lv_statement_id := '15';
    if ln_balancing_ccid is null then
      pv_process_status  := 'E';
      pv_process_message := 'No value for po and mtl accrual account';
      GOTO end_of_procedure;
    end if;

    lv_acct_type        := 'REVERSAL';
    lv_acct_nature      := 'CENVAT-SSI';
    lv_accounting_date  := trunc(sysdate);

    lv_reference23      := 'JAINRTVN';
    lv_reference24      := 'rcv_transactions';
    lv_reference25      := 'transaction_id';
    lv_reference26      := to_char(r_trx.transaction_id);

    lv_statement_id := '16';
    lv_reference10      := 'India Local RTV Entry for the Receipt Number ' || r_trx.receipt_num;
    if r_trx.transaction_type = 'CORRECT' THEN
      lv_reference10 := lv_reference10 || ' of '||r_trx.parent_transaction_type;
    end if;

    if lv_register_entry_type = jai_rcv_excise_processing_pkg.CENVAT_DEBIT then
      ln_debit_amt  := null;
      ln_credit_amt := r_diff_tax.basic_excise;
      ln_balancing_debit_amt  := r_diff_tax.basic_excise;
      ln_balancing_credit_amt := null;
    else
      ln_debit_amt  := r_diff_tax.basic_excise;
      ln_credit_amt := null;
      ln_balancing_debit_amt  := null;
      ln_balancing_credit_amt := r_diff_tax.basic_excise;
    end if;

    lv_statement_id := '20';
    /* Primary Accounting Entry - 1 */
    jai_rcv_accounting_pkg.process_transaction(
        p_transaction_id       => r_trx.transaction_id,
        p_acct_type            => lv_acct_type,
        p_acct_nature          => lv_acct_nature,
        p_source_name          => jai_rcv_excise_processing_pkg.gv_source_name,
        p_category_name        => jai_rcv_excise_processing_pkg.gv_category_name,

        p_code_combination_id  => ln_ccid,
        p_entered_dr           => ln_debit_amt,
        p_entered_cr           => ln_credit_amt,

        p_currency_code        => jai_rcv_trx_processing_pkg.gv_func_curr,
        p_accounting_date      => lv_accounting_date,
        p_reference_10         => lv_reference10,
        p_reference_23         => lv_reference23, --'jai_rcv_excise_processing_pkg.accounting_entries',
        p_reference_24         => lv_reference24, --'rcv_transactions',
        p_reference_25         => lv_reference25, --'transaction_id',
        p_reference_26         => lv_reference26, -- <transaction_id_value>
        p_destination          => 'G',
        p_simulate_flag        => lv_simulate_flag,
        p_codepath             => pv_codepath,
        p_process_status       => pv_process_status,
        p_process_message      => pv_process_message
        ,p_reference_name     => lv_reference_name,
        p_reference_id        => ln_reference_id
    );

    lv_statement_id := '21';
    if pv_process_status = 'E' then
      goto end_of_procedure;
    end if;

    lv_statement_id := '22';
    /* Balacing Accounting Entry - 1  */
    jai_rcv_accounting_pkg.process_transaction(
        p_transaction_id       => r_trx.transaction_id,
        p_acct_type            => lv_acct_type,
        p_acct_nature          => lv_acct_nature,
        p_source_name          => jai_rcv_excise_processing_pkg.gv_source_name,
        p_category_name        => jai_rcv_excise_processing_pkg.gv_category_name,

        p_code_combination_id  => ln_balancing_ccid,
        p_entered_dr           => ln_balancing_debit_amt,
        p_entered_cr           => ln_balancing_credit_amt,

        p_currency_code        => jai_rcv_trx_processing_pkg.gv_func_curr,
        p_accounting_date      => lv_accounting_date,
        p_reference_10         => lv_reference10,
        p_reference_23         => lv_reference23, --'jai_rcv_excise_processing_pkg.accounting_entries',
        p_reference_24         => lv_reference24, --'rcv_transactions',
        p_reference_25         => lv_reference25, --'transaction_id',
        p_reference_26         => lv_reference26, -- <transaction_id_value>
        p_destination          => 'G',
        p_simulate_flag        => lv_simulate_flag,
        p_codepath             => pv_codepath,
        p_process_status       => pv_process_status,
        p_process_message      => pv_process_message
        ,p_reference_name     => lv_reference_name,
        p_reference_id        => ln_reference_id
    );

    lv_statement_id := '23';
    if pv_process_status = 'E' then
      goto end_of_procedure;
    end if;

    /* Education Cess Acccounting Entries */
    if r_diff_tax.excise_edu_cess <> 0 then

      lv_statement_id := '24';
      lv_acct_nature  := 'CENVAT-EDUCESS-SSI';
      ln_ccid         := ln_excise_cess_accnt_id;

      if lv_register_entry_type = jai_rcv_excise_processing_pkg.CENVAT_DEBIT then
        ln_debit_amt  := null;
        ln_credit_amt := r_diff_tax.excise_edu_cess;
        ln_balancing_debit_amt  := r_diff_tax.excise_edu_cess;
        ln_balancing_credit_amt := null;
      else
        ln_debit_amt  := r_diff_tax.excise_edu_cess;
        ln_credit_amt := null;
        ln_balancing_debit_amt  := null;
        ln_balancing_credit_amt := r_diff_tax.excise_edu_cess;
      end if;

      lv_statement_id := '25';
      /* Primary Accounting Entry - 2 */
      jai_rcv_accounting_pkg.process_transaction(
          p_transaction_id       => r_trx.transaction_id,
          p_acct_type            => lv_acct_type,
          p_acct_nature          => lv_acct_nature,
          p_source_name          => jai_rcv_excise_processing_pkg.gv_source_name,
          p_category_name        => jai_rcv_excise_processing_pkg.gv_category_name,

          p_code_combination_id  => ln_ccid,
          p_entered_dr           => ln_debit_amt,
          p_entered_cr           => ln_credit_amt,

          p_currency_code        => jai_rcv_trx_processing_pkg.gv_func_curr,
          p_accounting_date      => lv_accounting_date,
          p_reference_10         => lv_reference10,
          p_reference_23         => lv_reference23, --'jai_rcv_excise_processing_pkg.accounting_entries',
          p_reference_24         => lv_reference24, --'rcv_transactions',
          p_reference_25         => lv_reference25, --'transaction_id',
          p_reference_26         => lv_reference26, -- <transaction_id_value>
          p_destination          => 'G',
          p_simulate_flag        => lv_simulate_flag,
          p_codepath             => pv_codepath,
          p_process_status       => pv_process_status,
          p_process_message      => pv_process_message
          ,p_reference_name     => lv_reference_name,
          p_reference_id        => ln_reference_id
      );

      lv_statement_id := '26';
      if pv_process_status = 'E' then
        goto end_of_procedure;
      end if;

      lv_statement_id := '27';
      /* Balacing Accounting Entry - 2  */
      jai_rcv_accounting_pkg.process_transaction(
          p_transaction_id       => r_trx.transaction_id,
          p_acct_type            => lv_acct_type,
          p_acct_nature          => lv_acct_nature,
          p_source_name          => jai_rcv_excise_processing_pkg.gv_source_name,
          p_category_name        => jai_rcv_excise_processing_pkg.gv_category_name,

          p_code_combination_id  => ln_balancing_ccid,
          p_entered_dr           => ln_balancing_debit_amt,
          p_entered_cr           => ln_balancing_credit_amt,

          p_currency_code        => jai_rcv_trx_processing_pkg.gv_func_curr,
          p_accounting_date      => lv_accounting_date,
          p_reference_10         => lv_reference10,
          p_reference_23         => lv_reference23, --'jai_rcv_excise_processing_pkg.accounting_entries',
          p_reference_24         => lv_reference24, --'rcv_transactions',
          p_reference_25         => lv_reference25, --'transaction_id',
          p_reference_26         => lv_reference26, -- <transaction_id_value>
          p_destination          => 'G',
          p_simulate_flag        => lv_simulate_flag,
          p_codepath             => pv_codepath,
          p_process_status       => pv_process_status,
          p_process_message      => pv_process_message
          ,p_reference_name     => lv_reference_name,
          p_reference_id        => ln_reference_id
      );

      lv_statement_id := '28';
      if pv_process_status = 'E' then
        goto end_of_procedure;
      end if;

    end if;

    -- added by csahoo for bug#6078460, start
		/* SH Education Cess Acccounting Entries */
		 if r_diff_tax.excise_edu_cess <> 0 then

			 lv_statement_id := '29';
			 lv_acct_nature  := 'CENVAT-SH-EDUCESS-SSI';
			 ln_ccid         := ln_excise_sh_cess_accnt_id;

			 if lv_register_entry_type = jai_rcv_excise_processing_pkg.CENVAT_DEBIT then
				 ln_debit_amt  := null;
				 ln_credit_amt := r_diff_tax.sh_exc_edu_cess;
				 ln_balancing_debit_amt  := r_diff_tax.sh_exc_edu_cess;
				 ln_balancing_credit_amt := null;
			 else
				 ln_debit_amt  := r_diff_tax.sh_exc_edu_cess;
				 ln_credit_amt := null;
				 ln_balancing_debit_amt  := null;
				 ln_balancing_credit_amt := r_diff_tax.sh_exc_edu_cess;
			 end if;

			 lv_statement_id := '30';
			 /* Primary Accounting Entry - 2 */
			 jai_rcv_accounting_pkg.process_transaction(
					 p_transaction_id       => r_trx.transaction_id,
					 p_acct_type            => lv_acct_type,
					 p_acct_nature          => lv_acct_nature,
					 p_source_name          => jai_rcv_excise_processing_pkg.gv_source_name,
					 p_category_name        => jai_rcv_excise_processing_pkg.gv_category_name,

					 p_code_combination_id  => ln_ccid,
					 p_entered_dr           => ln_debit_amt,
					 p_entered_cr           => ln_credit_amt,

					 p_currency_code        => jai_rcv_trx_processing_pkg.gv_func_curr,
					 p_accounting_date      => lv_accounting_date,
					 p_reference_10         => lv_reference10,
					 p_reference_23         => lv_reference23, --'jai_rcv_excise_processing_pkg.accounting_entries',
					 p_reference_24         => lv_reference24, --'rcv_transactions',
					 p_reference_25         => lv_reference25, --'transaction_id',
					 p_reference_26         => lv_reference26, -- <transaction_id_value>
					 p_destination          => 'G',
					 p_simulate_flag        => lv_simulate_flag,
					 p_codepath             => pv_codepath,
					 p_process_status       => pv_process_status,
					 p_process_message      => pv_process_message
					 ,p_reference_name     => lv_reference_name,
					 p_reference_id        => ln_reference_id
			 );
			fnd_file.put_line(FND_FILE.LOG, ' lv_statement_id ' || lv_statement_id);
			 lv_statement_id := '31';
			 if pv_process_status = 'E' then
				 goto end_of_procedure;
			 end if;

			 lv_statement_id := '32';
			 /* Balacing Accounting Entry - 2  */
			 jai_rcv_accounting_pkg.process_transaction(
					 p_transaction_id       => r_trx.transaction_id,
					 p_acct_type            => lv_acct_type,
					 p_acct_nature          => lv_acct_nature,
					 p_source_name          => jai_rcv_excise_processing_pkg.gv_source_name,
					 p_category_name        => jai_rcv_excise_processing_pkg.gv_category_name,

					 p_code_combination_id  => ln_balancing_ccid,
					 p_entered_dr           => ln_balancing_debit_amt,
					 p_entered_cr           => ln_balancing_credit_amt,

					 p_currency_code        => jai_rcv_trx_processing_pkg.gv_func_curr,
					 p_accounting_date      => lv_accounting_date,
					 p_reference_10         => lv_reference10,
					 p_reference_23         => lv_reference23, --'jai_rcv_excise_processing_pkg.accounting_entries',
					 p_reference_24         => lv_reference24, --'rcv_transactions',
					 p_reference_25         => lv_reference25, --'transaction_id',
					 p_reference_26         => lv_reference26, -- <transaction_id_value>
					 p_destination          => 'G',
					 p_simulate_flag        => lv_simulate_flag,
					 p_codepath             => pv_codepath,
					 p_process_status       => pv_process_status,
					 p_process_message      => pv_process_message
					 ,p_reference_name     => lv_reference_name,
					 p_reference_id        => ln_reference_id
			 );
			fnd_file.put_line(FND_FILE.LOG, ' lv_statement_id ' || lv_statement_id);
			 lv_statement_id := '28';
			 if pv_process_status = 'E' then
				 goto end_of_procedure;
			 end if;


    end if;

    -- added by csahoo for bug#6078460, end

    lv_statement_id := '29';
    pv_process_status := jai_constants.yes;
    <<end_of_procedure>>
    pv_codepath := jai_general_pkg.plot_codepath(75, pv_codepath, 'jai_rcv_excise_processing_pkg.rtv_processing_for_ssi', 'END');

  exception
    when others then
      pv_process_status := 'E';
      pv_process_message := 'Unexpected error in jai_rcv_excise_processing_pkg.rtv_processing_for_ssi(StmtId:'
                            ||lv_statement_id||'). ErrMsg:'||SQLERRM;
      pv_codepath := jai_general_pkg.plot_codepath(999, pv_codepath, 'jai_rcv_excise_processing_pkg.rtv_processing_for_ssi', 'END');

  end rtv_processing_for_ssi;
  --start additions for bug#4750798
  PROCEDURE get_excise_tax_rounding_factor(
   p_transaction_id IN NUMBER,
   p_Excise_rf OUT NOCOPY NUMBER,
   p_Excise_edu_cess_rf OUT NOCOPY NUMBER,
   p_Excise_she_cess_rf OUT NOCOPY NUMBER
   )
   IS
   CURSOR c_get_tax_rounding_factor(cp_transaction_id NUMBER) IS
        SELECT jt.tax_id,jt.tax_name,nvl(jt.ROUNDING_FACTOR,0) rf,jt.tax_type
        FROM jai_rcv_line_taxes jrt,rcv_transactions rt,
          jai_cmn_taxes_all jt
        WHERE jrt.shipment_line_id = rt.shipment_line_id
         AND jrt.shipment_header_id = rt.shipment_header_id
         AND jt.tax_id = jrt.tax_id
         AND rt.transaction_id=cp_transaction_id;
   BEGIN

    FOR tax_rf in  c_get_tax_rounding_factor(p_transaction_id)
    LOOP

     IF tax_rf.tax_type='Excise' THEN
       p_Excise_rf:=tax_rf.rf;
     ELSIF tax_rf.tax_type='EXCISE_EDUCATION_CESS' THEN
        p_Excise_edu_cess_rf:=tax_rf.rf;
     ELSIF tax_rf.tax_type='EXCISE_SH_EDU_CESS' THEN
        p_Excise_she_cess_rf:=tax_rf.rf;
     END IF;

    END LOOP;


   END get_excise_tax_rounding_factor;

 --end additions for bug#4750798


END jai_rcv_excise_processing_pkg;

/
