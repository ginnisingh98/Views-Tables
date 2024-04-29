--------------------------------------------------------
--  DDL for Package Body JAI_AP_TDS_CANCELLATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TDS_CANCELLATION_PKG" AS
/* $Header: jai_ap_tds_can.plb 120.7.12010000.9 2010/02/16 09:00:26 mbremkum ship $ */

/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_cancellation_pkg_b.sql

 Created By    : Aparajita

 Created Date  : 06-mar-2005

 Bug           :

 Purpose       : Implementation of cancellation functionality for TDS.

 Called from   : Trigger ja_in_ap_aia_after_trg

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.        03/03/2005   Aparajita for bug#4088186. version#115.0. TDS Clean up

                        Created this package for implementing the TDS Cancellation
                        functionality onto AP invoice.

2.        08-Jun-2005    Version 116.1 jai_ap_tds_can -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		         as required for CASE COMPLAINCE.

3.       14-Jun-2005      rchandan for bug#4428980, Version 116.2
                          Modified the object to remove literals from DML statements and CURSORS.
			  As part OF R12 Initiative Inventory conversion the OPM code is commented

4.       29-Jul-2005     Bug4523064. Added by Lakshmi Gopalsami Version 120.2
                        (1) Commented  the following parameters
                         P_set_of_books_id
                         P_period_name
                         P_tax_amount
                         P_check_id
                         and added P_Token as a OUT Parameter
                         and also commented the update for tax_amount
                         (2)Also raised exception if P_TOKEN is not null

5.      23-Aug-2005     Bug4559756. Added by Lakshmi Gopalsami version 120.3
                        (1) Added org_id in cursor c_ap_invoices_all
			(2) Fetched the same before calling ap_utilities_pkg
			    and passed the same the package call.
			 To get the period name and date.

6.    22-nov-2005  Bug 47541213. Added by Lakshmi Gopalsami
                          Changed JAI_TDS_SECTION to TDS_SECTION

7.    03/11/2006   Sanjikum for Bug#5131075, File Version 120.5
                   1) Changes are done for forward porting of bugs - 4718907, 5193852, 4947469

                   Dependency Due to this Bug
                   --------------------------
                   Yes, as Package spec is changed and there are multiple files changed as part of current

 8.		03/05/2007   Bug 5722028. Added by CSahoo 120.6
 									 Forward porting to R12.
                	 passed parameter pd_creation_Date to generate_tdS_invoices
										changed the value to tax_amount instead of calc_tax_amount.
										Depedencies:
										=============
										jai_ap_tds_gen.pls - 120.5
										jai_ap_tds_gen.plb - 120.19
										jai_ap_tds_ppay.pls - 120.2
										jai_ap_tds_ppay.plb - 120.5
										jai_ap_tds_can.plb - 120.6

9. 14/05/2007	bduvarag for the Bug#5722028.
		Removed redundant column names that were causing error

 10.  08/June/2009 Bug 8475540
                   AP Package AP_CANCEL_SINGLE_INVOICE was called without setting MOAC Context
                   resulting in multiple records being fetched when a single row is expected
                   Added call to mo_global.set_policy_context

11. 17-Jul-2009  Bgowrava for Bug#8682951 , File Version 120.4.12000000.4
 	                  Changed the parameter ld_accounting_date to sysdate while  calling process_threshold_rollback in the loop c_jai_ap_tds_inv_taxes.

12. 25-Aug-2009 Bug 8830302
                Fetch Accounting Date from AP_INVOICE_LINES_ALL if distributions is not saved.
                This will prevent failure during cancellation.

13. 07-Jan-2010  Jia for FP Bug#7312295, File Version 120.4.12000000.5
               Issue: This is a forward port bug for the bug7252683.
                   Cancellation of the invoice breaching the surcharge threhsold does not cancel the surcharge invoice that
                   got created while the transition. this results in wrong surcharge calculation

               Fixed: Added the column 'tds_event' to the cusor c_jai_ap_tds_thhold_trxs to pick the tds_even also for cancellation,
                   also ordered the result based on the threshold_trx_id. Checked the slabs after and before cancellation and
                   if it was different then cancelled the surcharge invoice else not cancelled it.

14. 13-Jun-2010   Xiao for Bug#7154864
			commented the call to  jai_ap_inv_tds_generation_pkg.process_threshold_rollback as the need to create
			an RTN invoice no more exists after the changes wrt to this bug have been made.


---------------------------------------------------------------------------- */

/***********************************************************************************************/

  procedure process_invoice
  (
    errbuf                               out    nocopy     varchar2,
    retcode                              out    nocopy     varchar2,
    p_invoice_id                         in                number
  )
  is

    cursor c_jai_ap_tds_thhold_trxs (p_invoice_id number) is--rchandan for bug#4428980
      select threshold_trx_id,
             threshold_grp_id,
             threshold_hdr_id,  --Added by Sanjikum for Bug#5131075(4718907)
             tax_id,
             taxable_amount,
             tax_amount,
             invoice_to_tds_authority_id,
             invoice_to_vendor_id,
             tds_event,          -- Added by Jia for FP Bug#7312295
             calc_tax_amount     -- Bug 5751783
      from   jai_ap_tds_thhold_trxs
      where  invoice_id = p_invoice_id
      and    (tds_event = 'INVOICE VALIDATE' or tds_event = 'SURCHARGE_CALCULATE')  --Bug 7312295 - Added condition 'or tds_event = 'SURCHARGE_CALCULATE'
      order by threshold_trx_id; -- Added by Jia for FP Bug#7312295

      cursor c_ja_in_tax_codes(p_tax_id number) is
        select  vendor_id,
                vendor_site_id,
                tax_rate
        from    JAI_CMN_TAXES_ALL
        where   tax_id = p_tax_id;

    /* Bug 4559756. Added by Lakshmi Gopalsami
       Added org_id for passing it to ap_utilities_pkg

    */
      cursor c_ap_invoices_all(p_invoice_id number) is
        select invoice_id,
               cancelled_date,
               payment_status_flag,
               invoice_amount,
               set_of_books_id,
               invoice_num,
               org_id
        from   ap_invoices_all
        where  invoice_id = p_invoice_id;

    cursor  c_get_parent_inv_dtls(p_invoice_id number) is
      select   set_of_books_id,
               invoice_currency_code,
               exchange_rate
      from     ap_invoices_all
      where    invoice_id = p_invoice_id;


    cursor c_jai_ap_tds_inv_taxes(p_invoice_id number,cp_section_type jai_ap_tds_inv_taxes.section_type%type) is--rchandan for bug#4428980
      select  threshold_grp_id,
              actual_tax_id tax_id,
              sum(amount) taxable_amount,
              sum(tax_amount) tax_amount
      from    jai_ap_tds_inv_taxes jtdsi
      where   invoice_id = p_invoice_id
      and     section_type =  cp_section_type --cp_section_type--rchandan for bug#4428980
      and     threshold_grp_id is not null
      and     threshold_trx_id is null
      group by threshold_grp_id, actual_tax_id;

    cursor c_gl_sets_of_books(cp_set_of_books_id  number) is
      select currency_code
      from   gl_sets_of_books
      where  set_of_books_id = cp_set_of_books_id;

   /* Bug#5131075(5193852). Added by Lakshmi Gopalsami
     | Changed the source of ld_accounting_date to refer to
     | ap_invoice_distributions_all.accounting_date instead of
     | gl_date on headers.
     */
    CURSOR get_dist_gl_date( cp_invoice_id IN ap_invoices_all.invoice_id%TYPE)
    IS
    SELECT accounting_date
      FROM ap_invoice_distributions_all
     WHERE invoice_id = cp_invoice_id
       AND distribution_line_number = 1;
    -- Only one distribution will be created for TDS invoices and so
    -- hard coded the distribution line number to 1.

    /*Bug 8830302 - Get Accounting Date from AP_INVOICE_LINES_ALL.
    This is fail safe if Distributions does not have accounting date*/
    CURSOR c_get_lines_acct_date(cp_invoice_id IN ap_invoices_all.invoice_id%TYPE)
    IS
    SELECT accounting_date
    FROM   ap_invoice_lines_all
    WHERE  invoice_id = cp_invoice_id
    AND    line_number = 1;

    -- Added by Jia for FP Bug#7312295, Begin
    -------------------------------------------------------------------------------
    CURSOR c_get_threshold_grp_dtl(p_threshold_grp_id NUMBER)
    IS
    SELECT  *
    FROM    jai_ap_tds_thhold_grps
    WHERE   threshold_grp_id = p_threshold_grp_id;

    CURSOR c_jai_ap_tds_thhold_slabs( p_threshold_hdr_id  NUMBER,
                                      p_threshold_type    VARCHAR2,
                                      p_amount            NUMBER)
    IS
    SELECT  threshold_slab_id, threshold_type_id, from_amount, to_amount, tax_rate
    FROM    jai_ap_tds_thhold_slabs
    WHERE   threshold_hdr_id = p_threshold_hdr_id
    AND     threshold_type_id in
                ( SELECT  threshold_type_id
                  FROM    jai_ap_tds_thhold_types
                  WHERE   threshold_hdr_id = p_threshold_hdr_id
                  AND     threshold_type = p_threshold_type
                  AND     trunc(sysdate) between from_date and nvl(to_date, sysdate + 1)
                )
    AND     from_amount <= p_amount
    AND     NVL(to_amount, p_amount) >= p_amount
    ORDER BY from_amount asc;

    r_get_threshold_grp_dtl   c_get_threshold_grp_dtl%ROWTYPE;
    ln_effective_invoice_amt  NUMBER;
    ln_effective_inv_amt_after NUMBER;
    r_jai_ap_tds_thhold_slabs c_jai_ap_tds_thhold_slabs%ROWTYPE;
    ln_threshold_slab_id_after jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
    ln_threshold_slab_id_before jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
    ln_taxable_amt number := 0;
    -------------------------------------------------------------------------------
    -- Added by Jia for FP Bug#7312295, End

    r_ja_in_tax_codes                   c_ja_in_tax_codes%rowtype;
    r_ap_invoices_all                   c_ap_invoices_all%rowtype;
    r_get_parent_inv_dtls               c_get_parent_inv_dtls%rowtype;
    r_gl_sets_of_books                  c_gl_sets_of_books%rowtype;

    lv_code_path                        VARCHAR2(1996);
    lv_process_flag                     varchar2(1);
    lv_process_message                  varchar2(250);
    lv_tds_invoice_flag                 varchar2(1);
    lv_tds_invoice_message              varchar2(250);
    lv_tds_credit_memo_flag             varchar2(1);
    lv_tds_credit_memo_message          varchar2(250);

    lb_return_value                     boolean;

    lv_out_message_name                 varchar2(240);
    ln_out_invoice_amount               number;
    ln_out_base_amount                  number;
    ln_out_tax_amount                   number;
    ln_out_temp_cancelled_amount        number;
    ln_out_cancelled_by                 number;
    ln_out_cancelled_amount             number;
    ld_out_cancelled_date               date;
    ld_out_last_update_date             date;
    ln_out_original_prepay_amount       number;
    ln_out_pay_curr_inv_amount          number;

    ld_accounting_date                  date;   --File.Sql.35 Cbabu  := sysdate;
    lv_open_period                      ap_invoice_distributions_all.period_name%type;

    lv_invoice_to_tds_num               ap_invoices_all.invoice_num%type;
    lv_invoice_to_vendor_num            ap_invoices_all.invoice_num%type;
    ln_threshold_trx_id                 number;

    ln_taxable_amount                   number;
    ln_exchange_rate                    ap_invoices_all.exchange_rate%type;
    lv_codepath                         VARCHAR2(1996);
    ln_start_threshold_trx_id           number;
    ln_threshold_grp_id                 number;
    ln_threshold_grp_audit_id           number;
    lv_new_transaction                  varchar2(1);
    lv_token                            varchar2(4000);
    --Added by Sanjikum the below 5 variables for bug#5131075(4718907)
    ln_threshold_slab_id                jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
    lv_threshold_type                   jai_ap_tds_thhold_types.threshold_type%TYPE;
    ln_after_threshold_slab_id          jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
    lv_after_threshold_type             jai_ap_tds_thhold_types.threshold_type%TYPE;
    ln_temp_threshold_hdr_id            jai_ap_tds_thhold_hdrs.threshold_hdr_id%TYPE;
    ld_ret_accounting_date              DATE ; -- bug#5131075(5193852). Added by Lakshmi Gopalsami

  begin

    --ld_accounting_date := sysdate; --commented by Harshita for Bug#5131075(5193852)

    lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'jai_ap_tds_cancellation_pkg.process_invoice', 'START'); /* 1 */
    Fnd_File.put_line(Fnd_File.LOG, '**** Start of procedure jai_ap_tds_cancellation_pkg.process_invoice ****');

    /* Check if Invoice was created after the tds clean up patch */
    jai_ap_tds_tax_defaultation.check_old_transaction
    (
    p_invoice_id                    =>    p_invoice_id,
    p_new_transaction               =>    lv_new_transaction
    );

    if nvl(lv_new_transaction, 'N') = 'N' then
      /* Invoice was created before application of TDS clean up, need to call the old procedure */
      lv_codepath := jai_general_pkg.plot_codepath(1.0, lv_codepath); /* 1.0 */
      Fnd_File.put_line(Fnd_File.LOG, '**** Transaction before application of TDS clean up Calling procedure  ****');
      Fnd_File.put_line(Fnd_File.LOG, ' Invoking OLD procedure jai_ap_tds_old_pkg.cancel_invoice');

      jai_ap_tds_old_pkg.cancel_invoice
      (
        errbuf            =>  errbuf,
        retcode           =>  retcode,
        p_invoice_id      =>  p_invoice_id
      );

      goto exit_from_procedure;

    end if;

    /* bug 4559756. Added by Lakshmi Gopalsami
       Fetch the org_id
    */
    open  c_ap_invoices_all(p_invoice_id);
    fetch c_ap_invoices_all into r_ap_invoices_all;
    close c_ap_invoices_all;


    --Removed the code from here by Lakshmi Gopalsami for Bug#5131075(5193852)

    lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath); /* 2 */

    /* Get all the TDS invoices that were generated at the time of the INVOICE VALIDATE */
    for cur_rec in c_jai_ap_tds_thhold_trxs(p_invoice_id)
    --Bug 7312295 - Removed INVOICE_VALIDATE event from c_jai_ap_tds_thhold_trxs. Modified the cursor to include Validate and Surcharge
    loop
    Fnd_File.put_line(Fnd_File.LOG, ' Inside Loop');
     	--Start Added by Sanjikum for Bug#5131075(4718907)
      jai_ap_tds_generation_pkg.get_tds_threshold_slab(
                              p_prepay_distribution_id  =>  NULL,
                              p_threshold_grp_id        =>  cur_rec.threshold_grp_id,
                              p_threshold_hdr_id        =>  cur_rec.threshold_hdr_id,
                              p_threshold_slab_id       =>  ln_threshold_slab_id,
                              p_threshold_type          =>  lv_threshold_type,
                              p_process_flag            =>  lv_process_flag,
                              p_process_message         =>  lv_process_message,
                              p_codepath                =>  lv_codepath);

      IF lv_process_flag = 'E' THEN
        goto end_of_main_loop;
      END IF;
      --End Added by Sanjikum for Bug#5131075(4718907)


      -- Added by Jia for FP Bug#7312295, Begin
      -------------------------------------------------------------------------------
      IF cur_rec.tds_event = 'INVOICE VALIDATE'
      THEN
        ln_threshold_slab_id_before := ln_threshold_slab_id;
        ln_taxable_amt := cur_rec.taxable_amount;

        OPEN c_get_threshold_grp_dtl(cur_rec.threshold_grp_id);
        FETCH c_get_threshold_grp_dtl INTO r_get_threshold_grp_dtl;
        CLOSE c_get_threshold_grp_dtl;

        ln_effective_invoice_amt := r_get_threshold_grp_dtl.total_invoice_amount -
                                r_get_threshold_grp_dtl.total_invoice_cancel_amount -
                                r_get_threshold_grp_dtl.total_invoice_apply_amount +
                                r_get_threshold_grp_dtl.total_invoice_unapply_amount;

        lv_threshold_type := 'CUMULATIVE';
        ln_effective_inv_amt_after := ln_effective_invoice_amt - cur_rec.taxable_amount;

        --check if the current amount falls in the cumulative threshold
        OPEN c_jai_ap_tds_thhold_slabs( cur_rec.threshold_hdr_id
                                      , lv_threshold_type
                                      , ln_effective_inv_amt_after);
        FETCH c_jai_ap_tds_thhold_slabs INTO r_jai_ap_tds_thhold_slabs;
        CLOSE c_jai_ap_tds_thhold_slabs;

        IF r_jai_ap_tds_thhold_slabs.threshold_slab_id IS NULL
        THEN
          lv_threshold_type := 'SINGLE';
          --check if the current amount falls in the single threshold
          OPEN c_jai_ap_tds_thhold_slabs( cur_rec.threshold_hdr_id
                                        , lv_threshold_type
                                        , 99999999999999);
          FETCH c_jai_ap_tds_thhold_slabs INTO r_jai_ap_tds_thhold_slabs;
          CLOSE c_jai_ap_tds_thhold_slabs;
        END IF;

        ln_threshold_slab_id_after := r_jai_ap_tds_thhold_slabs.threshold_slab_id;
      END IF;  -- IF cur_rec.tds_event = 'INVOICE VALIDATE'

      IF (cur_rec.tds_event = 'INVOICE VALIDATE')
         OR
         (cur_rec.tds_event = 'SURCHARGE_CALCULATE' AND ln_threshold_slab_id_before <> ln_threshold_slab_id_after)
      THEN
      -------------------------------------------------------------------------------
      -- Added by Jia for FP Bug#7312295, End

       lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath); /* 3 */

       lv_tds_invoice_flag        := null;
       lv_tds_invoice_message     := null;
       lv_tds_credit_memo_flag    := null;
       lv_tds_credit_memo_message := null;

      /* Get the details of the Invoice to TDS authority */
      r_ap_invoices_all := null;
      open  c_ap_invoices_all(cur_rec.invoice_to_tds_authority_id);
      fetch c_ap_invoices_all into r_ap_invoices_all;
      close c_ap_invoices_all;

      /* Bug#5131075(5193852). Added by Lakshmi Gopalsami
       * Derivced the accounting_date of the original distribution
       * as this value is also getting passed for Threshold adjustments if the
       * TDS invoice is already paid/cancelled.
       */
      Fnd_File.put_line(Fnd_File.LOG, ' cur_rec.invoice_to_tds_authority_id ' ||cur_rec.invoice_to_tds_authority_id);
      OPEN get_dist_gl_date(cur_rec.invoice_to_tds_authority_id);
			FETCH get_dist_gl_date INTO ld_accounting_date;
      CLOSE get_dist_gl_date;

      /*Bug 8830302 - Fetch Accouting Date from AP_INVOICE_LINES_ALL if Distributions are not saved yet*/
      if (ld_accounting_date is NULL) then
          OPEN c_get_lines_acct_date(cur_rec.invoice_to_tds_authority_id);
          FETCH c_get_lines_acct_date INTO ld_accounting_date;
          CLOSE c_get_lines_acct_date;
      end if;

     /* Check if the TDS invoice is paid, no processing is required if it is already paid. */
      if r_ap_invoices_all.payment_status_flag <> 'N' then
        lv_codepath := jai_general_pkg.plot_codepath(4, lv_codepath); /* 4 */
        lv_tds_invoice_flag := 'X';
        lv_tds_invoice_message := 'Invoice to TDS Authority is already paid.';
        lv_tds_credit_memo_flag := 'X';
        lv_tds_credit_memo_message := 'No processing as Invoice to TDS Authority  is already paid';
        goto Continue_with_next_record;
      end if;

      /*  Check if the invoice to TDS authority is already canccelled,
          if yes, no need to do the cancel processing of the invoice */
      lv_codepath := jai_general_pkg.plot_codepath(5, lv_codepath); /* 5 */
      if r_ap_invoices_all.cancelled_date is not null then
        lv_codepath := jai_general_pkg.plot_codepath(6, lv_codepath); /* 6 */
        lv_tds_invoice_flag := 'X';
        lv_tds_invoice_message := ' Invoice to TDS Authority is already Cancelled.';
        goto credit_memo_processing;
      end if;

      /* Control comes here only when the Invoice to TDS Authority  is not paid or not cancelled, need to cancel it */

      lb_return_value                 :=      null;
      lv_out_message_name             :=      null;
      ln_out_invoice_amount           :=      null;
      ln_out_base_amount              :=      null;
      ln_out_tax_amount               :=      null;
      ln_out_temp_cancelled_amount    :=      null;
      ln_out_cancelled_by             :=      null;
      ln_out_cancelled_amount         :=      null;
      ld_out_cancelled_date           :=      null;
      ld_out_last_update_date         :=      null;
      ln_out_original_prepay_amount   :=      null;
      ln_out_pay_curr_inv_amount      :=      null;
      lv_token                        :=      null;

      lv_codepath := jai_general_pkg.plot_codepath(7, lv_codepath); /* 7 */

     	/* Start for Bug#5131075(5193852). Added by Lakshmi Gopalsami.
		 	| Fetch the accounting date of TDS invoice distribution
		 	| so that the same will be passed for reversal line which will get
		 	| created for cancellation.
		 	*/
    	--Check if the given date is in current open period
    	lv_open_period:=  ap_utilities_pkg.get_current_gl_date
                         (P_Date   =>  ld_accounting_date,
			  									P_Org_Id =>  r_ap_invoices_all.org_id);
       	if lv_open_period is null then

				lv_codepath := jai_general_pkg.plot_codepath(1.1, lv_codepath); /* 1.1 */

				ap_utilities_pkg.get_open_gl_date
				(
					p_date          =>    ld_accounting_date, /* In date */
					p_period_name   =>    lv_open_period,     /* out Period */
					p_gl_date       =>    ld_accounting_date,  /* out date */
					P_Org_Id        =>    r_ap_invoices_all.org_id
				);

				if lv_open_period is null then
					lv_codepath := jai_general_pkg.plot_codepath(1.2, lv_codepath); /* 1.2 */
					lv_process_flag := 'E';
					lv_process_message := 'No open accounting Period after : ' || ld_accounting_date ;
					goto exit_from_procedure;
				end if;
				ld_accounting_date := ld_ret_accounting_date;

    	end if; /* lv_open_period is null */
			ld_ret_accounting_date := NULL;

			-- End for bug#5131075(5193852). Added by Lakshmi Gopalsami

      /* Bug 4523064. Added by Lakshmi Gopalsami
         Commented the following parameters
         P_set_of_books_id
         P_period_name
         P_set_of_books_id
         P_Check_id
         and added the following OUT Parameter
         P_Token
      */

      /*Added set_policy_context call to implement MOAC - Bug 8475540*/

      fnd_file.put_line(FND_FILE.LOG, ' Org id ' || r_ap_invoices_all.org_id);
      mo_global.set_policy_context('S', r_ap_invoices_all.org_id);

      lb_return_value :=
      ap_cancel_pkg.ap_cancel_single_invoice
      (
         P_invoice_id                     =>    cur_rec.invoice_to_tds_authority_id      ,
         P_last_updated_by                =>    fnd_global.user_id                       ,
         P_last_update_login              =>    fnd_global.login_id                      ,
         --P_set_of_books_id              =>    r_ap_invoices_all.set_of_books_id        ,
         P_accounting_date                =>    ld_accounting_date                       ,
         --P_period_name                  =>    lv_open_period                           ,
         P_message_name                   =>    lv_out_message_name                      ,
         P_invoice_amount                 =>    ln_out_invoice_amount                    ,
         P_base_amount                    =>    ln_out_base_amount                       ,
         --P_tax_amount                   =>    ln_out_tax_amount                        ,
         P_temp_cancelled_amount          =>    ln_out_temp_cancelled_amount             ,
         P_cancelled_by                   =>    ln_out_cancelled_by                      ,
         P_cancelled_amount               =>    ln_out_cancelled_amount                  ,
         P_cancelled_date                 =>    ld_out_cancelled_date                    ,
         P_last_update_date               =>    ld_out_last_update_date                  ,
         P_original_prepayment_amount     =>    ln_out_original_prepay_amount            ,
         --P_check_id                     =>    null                                     ,
         P_pay_curr_invoice_amount        =>    ln_out_pay_curr_inv_amount               ,
         P_Token                          =>    lv_token,
         P_calling_sequence               =>    'India Localization - cancel TDS invoice'
      );

      lv_codepath := jai_general_pkg.plot_codepath(8, lv_codepath); /* 8 */

      /* Bug4523064. Check whether any value is returned in lv_token.
         IF it is not null display the error  message. */

      IF nvl(lv_token,'A') <>  'A' Then
      APP_EXCEPTION.RAISE_EXCEPTION(EXCEPTION_TYPE  => 'APP',
                                    EXCEPTION_CODE  => NULL,
                                    EXCEPTION_TEXT  => lv_token);

      End if;

      /* Bug4523064. Added by Lakshmi Gopalsami
         Commented the tax_amount update */

      update  ap_invoices_all
      set     invoice_amount                =           ln_out_invoice_amount           ,
              base_amount                   =           ln_out_base_amount              ,
              --tax_amount                    =           ln_out_tax_amount               ,
              temp_cancelled_amount         =           ln_out_temp_cancelled_amount    ,
              cancelled_by                  =           ln_out_cancelled_by             ,
              cancelled_amount              =           ln_out_cancelled_amount         ,
              cancelled_date                =           ld_out_cancelled_date           ,
              last_update_date              =           ld_out_last_update_date         ,
              original_prepayment_amount    =           ln_out_original_prepay_amount   ,
              pay_curr_invoice_amount       =           ln_out_pay_curr_inv_amount
      where   invoice_id  =   cur_rec.invoice_to_tds_authority_id;

      /*What if ap_cancel_pkg.ap_cancel_single_invoice is not there ?? */
      lv_tds_invoice_flag := 'Y';
      lv_tds_invoice_message := 'Invoice to TDS Authority is Cancelled ';

      lv_codepath := jai_general_pkg.plot_codepath(9, lv_codepath); /* 9 */


      << credit_memo_processing >>
      /* Get the details of the Credit memo to the supplier for TDS  */
      r_ap_invoices_all := null;
      open  c_ap_invoices_all(cur_rec.invoice_to_vendor_id);
      fetch c_ap_invoices_all into r_ap_invoices_all;
      close c_ap_invoices_all;

      /* Bug#5131075(5193852). Added by Lakshmi Gopalsami
       * Derivced the accounting_date of the original distribution
       * as this value is also getting passed for Threshold adjustments if the
       * TDS CM invoice is already paid/cancelled.
       */

      OPEN get_dist_gl_date(cur_rec.invoice_to_vendor_id );
			FETCH get_dist_gl_date INTO ld_accounting_date;
      CLOSE get_dist_gl_date;

      /*Bug 8830302 - Fetch Accouting Date from AP_INVOICE_LINES_ALL if Distributions are not saved yet*/
      if (ld_accounting_date is NULL) then
          OPEN c_get_lines_acct_date(cur_rec.invoice_to_vendor_id);
          FETCH c_get_lines_acct_date INTO ld_accounting_date;
          CLOSE c_get_lines_acct_date;
      end if;

      /*  Check if the Credit memo to the supplier for TDS already canccelled,
          if yes, no need to cancel it again here  */

      if r_ap_invoices_all.cancelled_date is not null then
        lv_codepath := jai_general_pkg.plot_codepath(10, lv_codepath); /* 10 */
        lv_tds_credit_memo_flag := 'X';
        lv_tds_credit_memo_message := 'Credit memo to the supplier for TDS is already Cancelled.';
        goto Continue_with_next_record;
      end if;

      /*  Check if the Credit memo to the supplier for TDS is paid,
          if yes a separate invoice needs to be generated, or else the same credit memo can be cancelled */

      if r_ap_invoices_all.payment_status_flag = 'N' then
        lv_codepath := jai_general_pkg.plot_codepath(11, lv_codepath); /* 11 */
        /* Credit memo not paid, can cancel the same */
        lv_tds_credit_memo_flag := 'Y';
        lv_tds_credit_memo_message := 'Cancelling Credit memo to the supplier for TDS as it is not paid ';

        lb_return_value                 :=      null;
        lv_out_message_name             :=      null;
        ln_out_invoice_amount           :=      null;
        ln_out_base_amount              :=      null;
        ln_out_tax_amount               :=      null;
        ln_out_temp_cancelled_amount    :=      null;
        ln_out_cancelled_by             :=      null;
        ln_out_cancelled_amount         :=      null;
        ld_out_cancelled_date           :=      null;
        ld_out_last_update_date         :=      null;
        ln_out_original_prepay_amount   :=      null;
        ln_out_pay_curr_inv_amount      :=      null;
        lv_token                        :=      NULL;

        lv_codepath := jai_general_pkg.plot_codepath(12, lv_codepath); /* 12 */

				/* Start for Bug#5131075(5193852). Added by Lakshmi Gopalsami.
				| Fetch the accounting date of TDS invoice distribution
				| so that the same will be passed for reversal line which will get
				| created for cancellation.
				*/
				--Check if the given date is in current open period
				lv_open_period:=  ap_utilities_pkg.get_current_gl_date
													 (P_Date   =>  ld_accounting_date,
														P_Org_Id =>  r_ap_invoices_all.org_id);


				if lv_open_period is null then

					lv_codepath := jai_general_pkg.plot_codepath(1.1, lv_codepath); /* 1.1 */

					ap_utilities_pkg.get_open_gl_date
					(
						p_date          =>    ld_accounting_date, /* In date */
						p_period_name   =>    lv_open_period,     /* out Period */
						p_gl_date       =>    ld_accounting_date,  /* out date */
						P_Org_Id        =>    r_ap_invoices_all.org_id
					);

					if lv_open_period is null then
						lv_codepath := jai_general_pkg.plot_codepath(1.2, lv_codepath); /* 1.2 */
						lv_process_flag := 'E';
						lv_process_message := 'No open accounting Period after : ' || ld_accounting_date ;
						goto exit_from_procedure;
					end if;
					ld_accounting_date := ld_ret_accounting_date;

				end if; /* lv_open_period is null */
				ld_ret_accounting_date := NULL;

				-- End for bug#5131075(5193852). Added by Lakshmi Gopalsami


       /* Bug 4523064. Added by Lakshmi Gopalsami
         Commented the following parameters
         P_set_of_books_id
         P_period_name
         P_set_of_books_id
         P_Check_id
         and added the following OUT Parameter
         P_Token
        */

        /*Added set_policy_context call to implement MOAC - Bug 8475540*/

	fnd_file.put_line(FND_FILE.LOG, ' Org id ' || r_ap_invoices_all.org_id);
	mo_global.set_policy_context('S', r_ap_invoices_all.org_id);

        lb_return_value :=
        ap_cancel_pkg.ap_cancel_single_invoice
        (
           P_invoice_id                     =>    cur_rec.invoice_to_vendor_id             ,
           P_last_updated_by                =>    fnd_global.user_id                       ,
           P_last_update_login              =>    fnd_global.login_id                      ,
           --P_set_of_books_id              =>    r_ap_invoices_all.set_of_books_id        ,
           P_accounting_date                =>    ld_accounting_date                       ,
           --P_period_name                  =>    lv_open_period                           ,
           P_message_name                   =>    lv_out_message_name                      ,
           P_invoice_amount                 =>    ln_out_invoice_amount                    ,
           P_base_amount                    =>    ln_out_base_amount                       ,
           --P_tax_amount                   =>    ln_out_tax_amount                        ,
           P_temp_cancelled_amount          =>    ln_out_temp_cancelled_amount             ,
           P_cancelled_by                   =>    ln_out_cancelled_by                      ,
           P_cancelled_amount               =>    ln_out_cancelled_amount                  ,
           P_cancelled_date                 =>    ld_out_cancelled_date                    ,
           P_last_update_date               =>    ld_out_last_update_date                  ,
           P_original_prepayment_amount     =>    ln_out_original_prepay_amount            ,
           --P_check_id                     =>    null                                     ,
           P_pay_curr_invoice_amount        =>    ln_out_pay_curr_inv_amount               ,
           P_token                          =>    lv_token                                 ,
           P_calling_sequence               =>    'India Localization - cancel TDS invoice'
        );

        lv_codepath := jai_general_pkg.plot_codepath(13, lv_codepath); /* 13 */

        /* Bug4523064. Check whether any value is returned in lv_token.
         IF it is not null display the error  message. */

        IF nvl(lv_token,'A') <>  'A' Then
          APP_EXCEPTION.RAISE_EXCEPTION(EXCEPTION_TYPE  => 'APP',
                                        EXCEPTION_CODE  => NULL,
                                        EXCEPTION_TEXT  => lv_token);
        End if;

        /*Bug4523064. Added by Lakshmi Gopalsami
         Commented the tax_amount update */
        update  ap_invoices_all
        set     invoice_amount                =           ln_out_invoice_amount           ,
                base_amount                   =           ln_out_base_amount              ,
               -- tax_amount                    =           ln_out_tax_amount               ,
                temp_cancelled_amount         =           ln_out_temp_cancelled_amount    ,
                cancelled_by                  =           ln_out_cancelled_by             ,
                cancelled_amount              =           ln_out_cancelled_amount         ,
                cancelled_date                =           ld_out_cancelled_date           ,
                last_update_date              =           ld_out_last_update_date         ,
                original_prepayment_amount    =           ln_out_original_prepay_amount   ,
                pay_curr_invoice_amount       =           ln_out_pay_curr_inv_amount
        where   invoice_id  =   cur_rec.invoice_to_vendor_id;


      else
        /* Credit memo has already been paid, have to generate a new invoice to nagate the effect */
        lv_codepath := jai_general_pkg.plot_codepath(14, lv_codepath); /* 14 */
        ln_threshold_trx_id         :=      0;
        lv_invoice_to_tds_num       :=      null;
        lv_invoice_to_vendor_num    :=      null;

        jai_ap_tds_generation_pkg.generate_tds_invoices
        (
          pn_invoice_id                   =>      p_invoice_id                 ,
          pv_invoice_num_to_vendor_can    =>      r_ap_invoices_all.invoice_num,
          pn_taxable_amount               =>      cur_rec.taxable_amount       ,
          pn_tax_amount                   =>      cur_rec.tax_amount           ,
          pn_tax_id                       =>      cur_rec.tax_id               ,
          pd_accounting_date              =>      ld_accounting_date           ,
          pv_tds_event                    =>      'INVOICE CANCEL'             ,
          pn_threshold_grp_id             =>      cur_rec.threshold_grp_id     ,
          pv_tds_invoice_num              =>      lv_invoice_to_tds_num        ,
          pv_cm_invoice_num               =>      lv_invoice_to_vendor_num     ,
          pn_threshold_trx_id             =>      ln_threshold_trx_id          ,
          p_process_flag                  =>      lv_tds_credit_memo_flag      ,
          p_process_message               =>      lv_tds_credit_memo_message	 ,
          -- Bug 5722028. Added by CSahoo
					pd_creation_Date                =>      sysdate



        );


        if lv_tds_credit_memo_flag = 'E' then
          lv_codepath := jai_general_pkg.plot_codepath(15, lv_codepath); /* 15 */
          goto Continue_with_next_record;
        end if;

        lv_tds_credit_memo_flag := 'Y';
        lv_tds_credit_memo_message := 'Generated Standard invoice to suppliet : ' ||lv_invoice_to_vendor_num;
        lv_codepath := jai_general_pkg.plot_codepath(16, lv_codepath); /* 16 */

        if ln_start_threshold_trx_id is null then
          ln_start_threshold_trx_id := ln_threshold_trx_id;
        end if;

        lv_codepath := jai_general_pkg.plot_codepath(17, lv_codepath); /* 17 */
        /* Update the total tax amount for which Cancel invoice was raised */


      end if; /* Credit memo to the supplier paid / not paid */

      /* Control comes here when either the credit memo for the tds authority is cancelled or a
         compensating standard invoice has been made */

      ln_threshold_grp_id := cur_rec.threshold_grp_id;
      jai_ap_tds_generation_pkg.maintain_thhold_grps
      (
        p_threshold_grp_id             =>   ln_threshold_grp_id,
        p_trx_tax_paid                 =>   (-1 * cur_rec.tax_amount),
        p_tds_event                    =>   'INVOICE CANCEL',
        p_invoice_id                   =>   p_invoice_id,
        p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
        p_process_flag                 =>   lv_process_flag,
        P_process_message              =>   lv_process_message,
        p_codepath                     =>   lv_codepath
      );


      << Continue_with_next_record >>

      lv_codepath := jai_general_pkg.plot_codepath(18, lv_codepath); /* 18 */
      /* Update threshold for the cancel invoice amount */

    	ln_threshold_grp_id := cur_rec.threshold_grp_id;/*added by rchandan for bug#5131075(4947469)*/

      jai_ap_tds_generation_pkg.maintain_thhold_grps
      (
        p_threshold_grp_id             =>   ln_threshold_grp_id,
        --p_trx_invoice_cancel_amount    =>   cur_rec.taxable_amount, -- Comments by Jia for FP Bug#7312295
        p_trx_invoice_cancel_amount    =>   ln_taxable_amt, -- Modified by Jia for FP Bug#7312295
        p_tds_event                    =>   'INVOICE CANCEL',
        p_invoice_id                   =>   p_invoice_id,
        p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
        p_process_flag                 =>   lv_process_flag,
        P_process_message              =>   lv_process_message,
        p_codepath                     =>   lv_codepath
      );

      /* insert into JAI_AP_TDS_INV_CANCELS */
      lv_codepath := jai_general_pkg.plot_codepath(19, lv_codepath); /* 19 */

      insert into jai_ap_tds_inv_cancels
      (
        tds_inv_cancel_id                       ,
        invoice_id                              ,
        threshold_grp_id                        ,
        cancel_amount                           ,
        parent_threshold_trx_id                 ,
        tax_id                                  ,
        tds_invoice_flag                        ,
        tds_invoice_message                     ,
        tds_credit_memo_flag                    ,
        tds_credit_memo_message                 ,
        threshold_trx_id_cancel                 ,
        created_by                              ,
        creation_date                           ,
        last_updated_by                         ,
        last_update_date                        ,
        last_update_login
      )
      values
      (
        jai_ap_tds_inv_cancels_s.nextval        ,
        p_invoice_id                            ,
        cur_rec.threshold_grp_id                ,
        cur_rec.taxable_amount                  ,
        cur_rec.threshold_trx_id                ,
        cur_rec.tax_id                          ,
        lv_tds_invoice_flag                     ,
        lv_tds_invoice_message                  ,
        lv_tds_credit_memo_flag                 ,
        lv_tds_credit_memo_message              ,
        ln_threshold_trx_id                     ,
        fnd_global.user_id                      ,
        sysdate                                 ,
        fnd_global.user_id                      ,
        sysdate                                 ,
        fnd_global.login_id
      );

      --Added by Sanjikum for Bug#5131075(4718907)
      jai_ap_tds_generation_pkg.get_tds_threshold_slab(
                              p_prepay_distribution_id  =>  NULL,
                              p_threshold_grp_id        =>  cur_rec.threshold_grp_id,
                              p_threshold_hdr_id        =>  cur_rec.threshold_hdr_id,
                              p_threshold_slab_id       =>  ln_after_threshold_slab_id,
                              p_threshold_type          =>  lv_after_threshold_type,
                              p_process_flag            =>  lv_process_flag,
                              p_process_message         =>  lv_process_message,
                              p_codepath                =>  lv_codepath);

      IF lv_process_flag = 'E' THEN
        goto end_of_main_loop;
      END IF;

      r_ap_invoices_all := NULL;

      OPEN c_ap_invoices_all(p_invoice_id);
      FETCH c_ap_invoices_all into r_ap_invoices_all;
      CLOSE c_ap_invoices_all;

      /*jai_ap_tds_generation_pkg.process_threshold_rollback(
                                  p_invoice_id                =>  p_invoice_id,
                                  p_before_threshold_type     =>  lv_threshold_type,
                                  p_after_threshold_type      =>  lv_after_threshold_type,
                                  p_before_threshold_slab_id  =>  ln_threshold_slab_id,
                                  p_after_threshold_slab_id   =>  ln_after_threshold_slab_id,
                                  p_threshold_grp_id          =>  cur_rec.threshold_grp_id,
                                  p_org_id                    =>  r_ap_invoices_all.org_id,
                                  p_accounting_date           =>  ld_accounting_date,
                                  p_process_flag              =>  lv_process_flag,
                                  p_process_message           =>  lv_process_message,
                                  p_codepath                  =>  lv_codepath);

      IF lv_process_flag = 'E' THEN
        goto end_of_main_loop;
      END IF; */--Commented by Xiao for Bug#7154864

      -- Added by Jia for FP Bug#7312295, Begin
      -------------------------------------------------------------------------------
      END IF;
      ln_taxable_amt := 0;
      -------------------------------------------------------------------------------
      -- Added by Jia for FP Bug#7312295, End

      <<end_of_main_loop>>
      NULL;
      --End Added by Sanjikum for Bug#5131075(4718907)

    end loop; /* Get all the TDS invoices that were generated at the time of the INVOICE VALIDATE */

	if  ln_start_threshold_trx_id is not null then

      /* Some invoices have been generated, call the program for invoking import and approval */

      jai_ap_tds_generation_pkg.import_and_approve
      (
        p_invoice_id                   =>     p_invoice_id,
        p_start_thhold_trx_id          =>     ln_start_threshold_trx_id,
        p_tds_event                    =>     'INVOICE CANCEL',
        p_process_flag                 =>     lv_tds_credit_memo_flag,
        p_process_message              =>     lv_tds_credit_memo_message
      );
    end if;

    /* Process Cases where TDS invoice was not generated because of threshold not being reached. */

    /* Get the exchange rate of the invoice, may be required for taxable_amount in INR for foreign currency */
    lv_codepath := jai_general_pkg.plot_codepath(20, lv_codepath); /* 20 */
    open  c_get_parent_inv_dtls(p_invoice_id);
    fetch c_get_parent_inv_dtls into r_get_parent_inv_dtls;
    close c_get_parent_inv_dtls;

    open c_gl_sets_of_books(r_get_parent_inv_dtls.set_of_books_id);
    fetch c_gl_sets_of_books into r_gl_sets_of_books;
    close c_gl_sets_of_books;

    if r_gl_sets_of_books.currency_code <> r_get_parent_inv_dtls.invoice_currency_code then
      lv_codepath := jai_general_pkg.plot_codepath(21, lv_codepath); /* 21 */
      /* Foreign currency invoice */
      ln_exchange_rate := r_get_parent_inv_dtls.exchange_rate;
    end if;

    lv_codepath := jai_general_pkg.plot_codepath(22, lv_codepath); /* 22 */
    ln_exchange_rate := nvl(ln_exchange_rate, 1);

    for cur_rec in c_jai_ap_tds_inv_taxes(p_invoice_id,'TDS_SECTION')--rchandan for bug#4428980
    loop
	  lv_codepath := jai_general_pkg.plot_codepath(23, lv_codepath); /* 23 */
      ln_threshold_grp_id  := null;
      r_ja_in_tax_codes := null;
      ln_taxable_amount := null;

      open  c_ja_in_tax_codes(cur_rec.tax_id);
      fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
      close c_ja_in_tax_codes;

      if r_ja_in_tax_codes.tax_rate <> 0 then
        lv_codepath := jai_general_pkg.plot_codepath(24, lv_codepath); /* 24 */
        ln_taxable_amount :=  cur_rec.tax_amount * (100/r_ja_in_tax_codes.tax_rate);
        ln_taxable_amount := round(ln_taxable_amount, 2);
      else
        /* 0 rated tax */
        lv_codepath := jai_general_pkg.plot_codepath(25, lv_codepath); /* 25 */
        ln_taxable_amount := cur_rec.taxable_amount * ln_exchange_rate;
      end if;

      --Start Added by Sanjikum for Bug#5131075(4718907)
	    jai_ap_tds_generation_pkg.get_tds_threshold_slab(
                              p_prepay_distribution_id  =>  NULL,
                              p_threshold_grp_id        =>  cur_rec.threshold_grp_id,
                              p_threshold_hdr_id        =>  ln_temp_threshold_hdr_id,
                              p_threshold_slab_id       =>  ln_threshold_slab_id,
                              p_threshold_type          =>  lv_threshold_type,
                              p_process_flag            =>  lv_process_flag,
                              p_process_message         =>  lv_process_message,
                              p_codepath                =>  lv_codepath);

      IF lv_process_flag = 'E' THEN
        goto end_of_outer_loop;
      END IF;
      --End Added by Sanjikum for Bug#5131075(4718907)

      lv_codepath := jai_general_pkg.plot_codepath(26, lv_codepath); /* 26 */
      ln_threshold_grp_id := cur_rec.threshold_grp_id;
	  jai_ap_tds_generation_pkg.maintain_thhold_grps
      (
        p_threshold_grp_id             =>   ln_threshold_grp_id,
        p_trx_invoice_cancel_amount    =>   ln_taxable_amount,
        p_tds_event                    =>   'INVOICE CANCEL',
        p_invoice_id                   =>   p_invoice_id,
        p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
        p_process_flag                 =>   lv_process_flag,
        P_process_message              =>   lv_process_message,
        p_codepath                     =>   lv_codepath
      );

      insert into jai_ap_tds_inv_cancels
      (
        tds_inv_cancel_id                       ,
        invoice_id                              ,
        threshold_grp_id                        ,
        cancel_amount                           ,
        parent_threshold_trx_id                 ,
        tax_id                                  ,
        tds_invoice_flag                        ,
        tds_invoice_message                     ,
        tds_credit_memo_flag                    ,
        tds_credit_memo_message                 ,
        threshold_trx_id_cancel                 ,
        created_by                              ,
        creation_date                           ,
        last_updated_by                         ,
        last_update_date                        ,
        last_update_login
      )
      values
      (
        jai_ap_tds_inv_cancels_s.nextval        ,
        p_invoice_id                            ,
        cur_rec.threshold_grp_id                ,
        ln_taxable_amount                       ,
        null                                    ,
        cur_rec.tax_id                          ,
        null                                    ,
        null                                    ,
        null                                    ,
        null                                    ,
        null                                    ,
        fnd_global.user_id                      ,
        sysdate                                 ,
        fnd_global.user_id                      ,
        sysdate                                 ,
        fnd_global.login_id
      );
      lv_codepath := jai_general_pkg.plot_codepath(27, lv_codepath); /* 27 */

      --Added by Sanjikum for Bug#5131075(4718907)

      jai_ap_tds_generation_pkg.get_tds_threshold_slab(
                              p_prepay_distribution_id  =>  NULL,
                              p_threshold_grp_id        =>  cur_rec.threshold_grp_id,
                              p_threshold_hdr_id        =>  ln_temp_threshold_hdr_id,
                              p_threshold_slab_id       =>  ln_after_threshold_slab_id,
                              p_threshold_type          =>  lv_after_threshold_type,
                              p_process_flag            =>  lv_process_flag,
                              p_process_message         =>  lv_process_message,
                              p_codepath                =>  lv_codepath);

      IF lv_process_flag = 'E' THEN
        goto end_of_outer_loop;
      END IF;

      r_ap_invoices_all := NULL;

      OPEN c_ap_invoices_all(p_invoice_id);
      FETCH c_ap_invoices_all into r_ap_invoices_all;
      CLOSE c_ap_invoices_all;

	/* jai_ap_tds_generation_pkg.process_threshold_rollback(
                                  p_invoice_id                =>  p_invoice_id,
                                  p_before_threshold_type     =>  lv_threshold_type,
                                  p_after_threshold_type      =>  lv_after_threshold_type,
                                  p_before_threshold_slab_id  =>  ln_threshold_slab_id,
                                  p_after_threshold_slab_id   =>  ln_after_threshold_slab_id,
                                  p_threshold_grp_id          =>  cur_rec.threshold_grp_id,
                                  p_org_id                    =>  r_ap_invoices_all.org_id,
                                  p_accounting_date           =>  sysdate,  --modified ld_accounting_date to sysdate by Bgowrava for bug#8682951
                                  p_process_flag              =>  lv_process_flag,
                                  p_process_message           =>  lv_process_message,
                                  p_codepath                  =>  lv_codepath);

      IF lv_process_flag = 'E' THEN
        goto end_of_outer_loop;
      END IF;*/   --Commented by Xiao for Bug#7154864
     <<end_of_outer_loop>>
      NULL;
      --End Added by Sanjikum for Bug#5131075(4718907)

    end loop;

    << exit_from_procedure >>

    lv_codepath := jai_general_pkg.plot_codepath(100, lv_codepath, null, 'END'); /* 100 */
    Fnd_File.put_line(Fnd_File.LOG, lv_codepath);
    Fnd_File.put_line(Fnd_File.LOG, '**** END of procedure jai_ap_tds_cancellation_pkg.process_invoice ****');

    errbuf := lv_codepath;

    if lv_process_flag = 'E' then
      raise_application_error(-20012, lv_process_message);
    end if;
    return;

  exception
    when others then
      errbuf := 'jai_ap_tds_cancellation_pkg.process_invoice :' ||  sqlerrm;
      Fnd_File.put_line(Fnd_File.LOG, 'Err:process_invoice :' ||  sqlerrm);
      raise_application_error(-20013, errbuf);
      return;
  end process_invoice;


/***********************************************************************************************/


end jai_ap_tds_cancellation_pkg;

/
