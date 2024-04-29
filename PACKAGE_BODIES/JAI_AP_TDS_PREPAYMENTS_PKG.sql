--------------------------------------------------------
--  DDL for Package Body JAI_AP_TDS_PREPAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TDS_PREPAYMENTS_PKG" AS
/* $Header: jai_ap_tds_ppay.plb 120.5.12010000.13 2010/06/21 08:29:45 mbremkum ship $ */

/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_prepayemnts_pkg_b.sql

 Created By    : Aparajita

 Created Date  : 03-mar-2005

 Bug           :

 Purpose       : Implementation of prepayment functionality for TDS.

 Called from   : Trigger ja_in_ap_aia_after_trg
                 Trigger ja_in_ap_aida_after_trg

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.        03/03/2005   Aparajita for bug#4088186. version#115.0. TDS Clean Up.

                        Created this package for implementing the TDS prepayemnts
                        functionality onto AP invoice.

2.        08-Jun-2005    Version 116.1 jai_ap_tds_ppay -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		                     as required for CASE COMPLAINCE.

3.     14-Jun-2005      rchandan for bug#4428980, Version 116.2
                        Modified the object to remove literals from DML statements and CURSORS.
4.     28-Jul-2005     Bug 4522507. Added by Lakshmi Gopalsami version 120.2
                       - Made the changes in Procedure process_tds_invoices
                           a) Added 2 new cursors c_get_if_tds_inv_generated_pp,
                           c_get_amt_tds_inv_generated_si.
                           b) Code Added to open and Fetch the details from the
			   above 2 cursors
                           c) Changed the value of parameter pn_tax_amount,
                              while calling
			     jai_ap_tds_generation_pkg.generate_tds_invoices
                           d) Changed the value of parameter p_trx_tax_paid,
                             while calling
			     jai_ap_tds_generation_pkg.maintain_thhold_grps

                        Dependencies (Functional)
			-------------------------
			jai_ap_tds_gen.plb Version 120.3

6.    22-nov-2005  Bug 47541213. Added by Lakshmi Gopalsami
                          Changed JAI_TDS_SECTION to TDS_SECTION

7.    03/11/2006   Sanjikum for Bug#5131075, File Version 120.4
                   1) Changes are done for forward porting of bugs - 4722011, 4718907

                   Dependency Due to this Bug
                   --------------------------
                   Yes, as Package spec is changed and there are multiple files changed as part of current

8.		14/03/2007   Bug 5722028. Added by CSahoo 120.5
									Forward Porting to R12
                  Added parameter p_creation_date for the follownig procedures
	          			process_tds_at_inv_validate
		maintain_thhold_grps
		and pd_creation_date in generate_tds_invoices.
		Added global variables
		gn_tds_rounding_factor
		gd_tds_rounding_effective_date and function get_rnded_value
		is created.

		updated jai_ap_tdS_inv_taxes and jai_ap_tds_thhold_grps
		withe the rounded values. This is done in procedure
		process_tds_at_inv_validate and maintain_thhold_grps.
		In generate_tds_invoices derived the logic for rounding.
								Added conditions in queries for fetching the taxable
		amount in procedure process_threshold_transition and
								process_threshold_rollback. Added the parameters p_creation_date
		or pd_creation_date wherever required.
		Search for bug number for complete fix.

		Depedencies:
		=============
		jai_ap_tds_gen.pls - 120.5
		jai_ap_tds_gen.plb - 120.19
		jai_ap_tds_ppay.pls - 120.2
		jai_ap_tds_ppay.plb - 120.5
		jai_ap_tds_can.plb - 120.6


9.		6/01/2010   Added by Jia for FP bug6929483
						 Issue:	This is a forward port bug for the bug6911776
                  Applying prepayment to an invoice takes longer time

             Fixed: 1) Add new procedure get_prepay_invoice_id to get invoice_id
                    2) Modified the procedure populate_section_tax and procedure process_tds_invoices.
                    The queries referring to the table jai_ap_tds_inv_taxes,
                    included invoice_id in their where clause to make use of existing index

10.   07/01/2010   Added by Xiao Lv for FP bug#8345080
             Issue:	This is a forward port bug for the bug8333898
                  TDS DEDUCTING TWICE

             Fixed: 1) Add new cursor c_get_grp_details_si_inv_dist, c_get_tax_sec_det.

11.  13-Jan-2010  Xiao for Bug#6596019
                        Commented the code related to creation of TDS invoices for RTN generation.
			This is implemented because on application of prepayment the TDS calculated is
			on the net amount of standard invoice and hence the RTN need not be created.

12.		14/01/2010   Added by Jia for FP Bug#7431371
						 Issue:	This is a forward port bug for the 11i Bug#7419533
                 FINANCIALS FOR INDIA -TDS NOT WORKING IN CASE OF MULTIPLE DISTRIBUTIONS
             Fixed: Commented the code in procdeure process_tds_invoices for calling the procedure maintain_thhold_grps.

13. 25-Jan-2010 Bug 5751783 (Forward Port of 5721614)
                -------------------------------------
                Issues
                + Amount in certificates is wrong. All calculations are made based on rounded values
                + Certificates are generated with Taxable Basis as 0 but non zero tax amount
                + Certificates are generated with negative amounts.
                + During Prepayment Un-application if Threshold Transition occurs then there are no TDS Invoices generated.
                + Taxable Basis is wrong for Threshold Rollback.
                + Applying Prepayment with different rates results in negative RTN

                Bug 8679964 (Forward Port of 8639011)
                -------------------------------------
                When attempting to unapply prepayment error message pops up  'Cannot unapply the prepayment as it was applied
                before validating the standard invoice' even though the prepayment was applied after validation of std invoice.

                Bug 6363056 (Forward Port of 6031679)
                -------------------------------------
                When prepayment from the previous year is applied on to the Standard Invoice of the current year,
                it results in 'Effective Tax Amount cannot be negative'.
                This issue is fixed by Invoice ID of the latest document in jai_ap_tds_thhold_trxs when inserting records
                for TDS Event 'PREPAYMENT APPLICATION'. Apart from this, the threshold group which belongs latest
                GL Date in the Distribution is used.

                Bug 6972230 (Forward Port of 6742977)
                -------------------------------------
                RTN not generated for the correct amount when Prepayment Tax Rate is different from the Standard Invoice
                Tax Rate

                Bug 6929483 (Forward Port of 6911776)
                -------------------------------------
                Pending fix which was dependent in 5751783 is done here

                Bug 8431516 (Forward Port of 7626202)
                -------------------------------------
                RTN invoice would be generated to negate the effect of TDS invoice created for a prepayment, when the prepayment
                is applied to a standard invoice.

14. 21-Jun-2010 Bug - 9826422
                Description: Records are inserted into AP Interface tables using Standard Invoice, but import_and_approve
                was called using the Prepayment Invoice ID. Hence wrong group_id was getting passed and no
                Invoices were getting improved
                Fix: Replaced p_invoice_id by ln_parent_invoice_id

--------------------------------------------------------------------------- */

  -- Added by Jia for FP bug6929483, Begin
  -----------------------------------------------------------------------------
  PROCEDURE get_prepay_invoice_id
  (
    p_prepay_inv_dist_id  NUMBER,
    p_prepay_inv_id       OUT NOCOPY NUMBER
   )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    BEGIN
      SELECT invoice_id
        INTO p_prepay_inv_id
        FROM ap_invoice_distributions_all
       WHERE invoice_distribution_id = p_prepay_inv_dist_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_prepay_inv_id := null;
    END;
  END get_prepay_invoice_id;

  /*Bug 8431516 - Start*/
  FUNCTION get_reversal_flag(pn_invoice_dist_id NUMBER) RETURN VARCHAR2
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR c_get_reversal_flag(p_inv_dist_id NUMBER) is
  SELECT reversal_flag
  FROM ap_invoice_distributions_all
  WHERE invoice_distribution_id = p_inv_dist_id;
  v_reversal_flag VARCHAR2(1);
  BEGIN
       OPEN c_get_reversal_flag(pn_invoice_dist_id);
       FETCH c_get_reversal_flag INTO v_reversal_flag;
       CLOSE c_get_reversal_flag;
       v_reversal_flag := NVL(v_reversal_flag,'N');
       RETURN v_reversal_flag;
  END get_reversal_flag;
  /*Bug 8431516 - End*/

  -----------------------------------------------------------------------------
  -- Added by Jia for FP bug6929483, End


  procedure process_prepayment
  (
    p_event                              in                 varchar2,    --Added for Bug 8431516
    p_invoice_id                         in                 number,
    p_invoice_distribution_id            in                 number,
    p_prepay_distribution_id             in                 number,
    p_parent_reversal_id                 in                 number,
    p_prepay_amount                      in                 number,
    p_vendor_id                          in                 number,
    p_vendor_site_id                     in                 number,
    p_accounting_date                    in                 date,
    p_invoice_currency_code              in                 varchar2,
    p_exchange_rate                      in                 number,
    p_set_of_books_id                    in                 number,
    p_org_id                             in                 number,
    -- Bug 5722028. Added by CSahoo
    p_creation_date                      in                 date,
    p_process_flag                       out     nocopy     varchar2,
    p_process_message                    out     nocopy     varchar2,
    p_codepath                           in out  nocopy     varchar2
  )
  is
  /*Bug 5751783 - Start*/
  cursor c_get_prepay_apply(cp_invoice_id number, cp_inv_dist_id number) is
  select tds_threshold_trx_id_apply, count(1)
  from   jai_ap_tds_prepayments
  where  invoice_id = cp_invoice_id
  and    invoice_distribution_id_prepay = cp_inv_dist_id
  group by tds_threshold_trx_id_apply;

  ln_prepay_apply number;
  ln_prepay_apply_trx_id number;
  /*Bug 5751783 - End*/
  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_prepayemnts_pkg.process_prepayment', 'START'); /* 1 */

    if p_prepay_amount < 0 then

      /* Event is APPLY of prepayment */

      jai_ap_tds_prepayments_pkg.allocate_prepayment
      (
        p_invoice_id                       =>       p_invoice_id               ,
        p_invoice_distribution_id          =>       p_invoice_distribution_id  ,
        p_prepay_amount                    =>       p_prepay_amount            ,
        p_process_flag                     =>       p_process_flag             ,
        p_process_message                  =>       p_process_message          ,
        p_codepath                         =>       p_codepath
      );

      if p_process_flag = 'E' then
        goto  exit_from_procedure;
      end if;

      jai_ap_tds_prepayments_pkg.populate_section_tax
      (
        p_invoice_id                       =>       p_invoice_id                ,
        p_invoice_distribution_id          =>       p_invoice_distribution_id   ,
        p_prepay_distribution_id           =>       p_prepay_distribution_id    ,
        p_process_flag                     =>       p_process_flag              ,
        p_process_message                  =>       p_process_message           ,
        p_codepath                         =>       p_codepath
      );

      if p_process_flag = 'E' then
        goto  exit_from_procedure;
      end if;


      jai_ap_tds_prepayments_pkg.process_tds_invoices
      (
        p_event                              =>     p_event                     ,    --Added for Bug 8431516
        p_invoice_id                         =>     p_invoice_id                ,
        p_invoice_distribution_id            =>     p_invoice_distribution_id   ,
        p_prepay_distribution_id             =>     p_prepay_distribution_id    ,
        p_prepay_amount                      =>     p_prepay_amount             ,
        p_vendor_id                          =>     p_vendor_id                 ,
        p_vendor_site_id                     =>     p_vendor_site_id            ,
        p_accounting_date                    =>     p_accounting_date           ,
        p_invoice_currency_code              =>     p_invoice_currency_code     ,
        p_exchange_rate                      =>     p_exchange_rate             ,
        p_set_of_books_id                    =>     p_set_of_books_id           ,
        p_org_id                             =>     p_org_id                    ,
        -- Bug 5722028. Added by Lakshmi Gopalsami
				p_creation_date                   =>     p_creation_date,
        p_process_flag                       =>     p_process_flag              ,
        p_process_message                    =>     p_process_message           ,
        p_codepath                           =>     p_codepath
      );

      if p_process_flag = 'E' then
        goto  exit_from_procedure;
      end if;


    elsif p_prepay_amount > 0 then

      /* Event is UNAPPLY of prepayment */
      /* Bug 5721614. Added by Lakshmi Gopalsami
       * Included parameter p_prepay_distribution_id
       */

      open c_get_prepay_apply(p_invoice_id, p_invoice_distribution_id);
      fetch c_get_prepay_apply into ln_prepay_apply_trx_id, ln_prepay_apply;
      close c_get_prepay_apply;

      if p_event = 'INSERT' and nvl(ln_prepay_apply,0) > 0 and nvl(ln_prepay_apply_trx_id, 0) = 0 then
         p_process_flag := 'E';
         P_process_message := 'Error - Cannot Unapply prepayment as it was Applied before Validating the Standard invoice';
         goto  exit_from_procedure;
      end if;


      jai_ap_tds_prepayments_pkg.process_unapply
      (
        p_event                             =>     p_event                     ,      --Added for Bug 8431516
        p_invoice_id                        =>     p_invoice_id                ,
        p_invoice_distribution_id           =>     p_invoice_distribution_id   ,
        p_parent_distribution_id            =>     p_parent_reversal_id        ,
        p_prepay_distribution_id            =>     p_prepay_distribution_id    ,      /*Bug 5751783*/
        p_prepay_amount                     =>     p_prepay_amount             ,
        p_vendor_id                         =>     p_vendor_id                 ,
        p_vendor_site_id                    =>     p_vendor_site_id            ,
        p_accounting_date                   =>     p_accounting_date           ,
        p_invoice_currency_code             =>     p_invoice_currency_code     ,
        p_exchange_rate                     =>     p_exchange_rate             ,
        p_set_of_books_id                   =>     p_set_of_books_id           ,
        p_org_id                            =>     p_org_id                    ,
        -- Bug 5722028. Added by CSahoo
				p_creation_date                   =>     p_creation_date,
        p_process_flag                      =>     p_process_flag              ,
        p_process_message                   =>     p_process_message           ,
        p_codepath                          =>     p_codepath
      );

			--Added by Sanjikum for Bug#5131075(4722011)
			IF p_process_flag = 'E' THEN
				goto exit_from_procedure;
			END IF;

    end if;


    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(100, p_codepath, null, 'END'); /* 100 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'jai_ap_tds_prepayemnts_pkg.process_prepayment :' ||  sqlerrm;
      return;
  end process_prepayment;



/***********************************************************************************************/
  procedure process_unapply
  (
    p_event                              in                 varchar2,     --Added for Bug 8431516
    p_invoice_id                         in                 number,
    p_invoice_distribution_id            in                 number, /* PREPAY UNAPPLY distribution */
    p_parent_distribution_id             in                 number, /* parent PREPAY APPLY distribution */
    p_prepay_distribution_id             in                 number, /* Distribution id of the prepay line - Bug 5751783*/
    p_prepay_amount                      in                 number,
    p_vendor_id                          in                 number,
    p_vendor_site_id                     in                 number,
    p_accounting_date                    in                 date,
    p_invoice_currency_code              in                 varchar2,
    p_exchange_rate                      in                 number,
    p_set_of_books_id                    in                 number,
    p_org_id                             in                 number,
    -- Bug 5722028. Added by CSahoo
    p_creation_date                      in                 date,
    p_process_flag                       out     nocopy     varchar2,
    p_process_message                    out     nocopy     varchar2,
    p_codepath                           in out  nocopy     varchar2
  )
  is

    /* Bug 5751783
    *  Fetched the non-rounded value of the tds paid in order to avoid
    *  any rounding issues.
    */
    cursor c_get_total_prepayment_tax
      (p_invoice_id number, p_invoice_distribution_id number, p_exchange_rate number) is
      select sum( decode(tds_applicable_flag , 'Y', application_amount*p_exchange_rate,  0) ) tds_taxable_basis,
             sum( decode(tds_applicable_flag , 'Y', calc_tds_appln_amt,  0) ) tds_amount,
             sum( decode(tds_applicable_flag , 'Y', tds_application_amount,  0) ) tds_amount_orig,
             sum( decode(wct_applicable_flag,  'Y', application_amount*p_exchange_rate,  0) ) wct_taxable_basis,
             sum( decode(wct_applicable_flag,  'Y', calc_wct_appln_amt,  0) ) wct_amount,
             sum( decode(wct_applicable_flag , 'Y', wct_application_amount,  0) ) wct_amount_orig,
             sum( decode(essi_applicable_flag, 'Y', application_amount*p_exchange_rate, 0) ) essi_taxable_basis,
             sum( decode(essi_applicable_flag, 'Y', calc_essi_appln_amt, 0) ) essi_amount,
             sum( decode(essi_applicable_flag, 'Y', essi_application_amount,  0) ) essi_amount_orig
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_invoice_distribution_id;

    cursor c_tds_details_apply(p_invoice_id number, p_invoice_distribution_id number, p_exchange_rate in number) is
      select tds_threshold_grp_id,
             tds_threshold_trx_id_apply,
             -- Bug 6363056
             sum(decode(tds_applicable_flag , 'Y', application_amount*p_exchange_rate,  0)) tds_taxable_basis,
             sum(decode(tds_applicable_flag , 'Y', calc_tds_appln_amt,  0))  tds_amount,
             sum(decode(tds_applicable_flag , 'Y', tds_application_amount,  0)) tds_amount_orig,
             sum(decode(wct_applicable_flag,  'Y', application_amount*p_exchange_rate,  0))  wct_taxable_basis,
             sum(decode(wct_applicable_flag,  'Y', calc_wct_appln_amt,  0))  wct_amount,
             sum(decode(wct_applicable_flag , 'Y', wct_application_amount,  0))  wct_amount_orig,
             sum(decode(essi_applicable_flag, 'Y', application_amount*p_exchange_rate, 0))  essi_taxable_basis,
             sum(decode(essi_applicable_flag, 'Y', calc_essi_appln_amt, 0))  essi_amount,
             sum(decode(essi_applicable_flag , 'Y', essi_application_amount,  0))  essi_amount_orig
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_invoice_distribution_id
      and    tds_threshold_grp_id is not null
      and    nvl(unapply_flag, 'N') <> 'Y' -- Bug 6363056
      group by
      tds_threshold_grp_id,
      tds_threshold_trx_id_apply; /*Bug 9132694 - Added Group By clause to sum the tax amounts and create a single RTN reversal entry on unapplication*/

    cursor c_wct_details_apply(p_invoice_id number, p_invoice_distribution_id number) is
      select wct_threshold_trx_id_apply, invoice_distribution_id -- Bug 6363056
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_invoice_distribution_id
      and    wct_threshold_trx_id_apply is not null;

    cursor c_essi_details_apply(p_invoice_id number, p_invoice_distribution_id number) is
      select essi_threshold_trx_id_apply, invoice_distribution_id -- Bug 6363056
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_invoice_distribution_id
      and    essi_threshold_trx_id_apply is not null;

    cursor c_gl_sets_of_books(cp_set_of_books_id  number) is
      select currency_code
      from   gl_sets_of_books
      where  set_of_books_id = cp_set_of_books_id;

    cursor c_get_tds_tax_id(p_invoice_id number, p_prepay_distribution_id number) is
      select tds_tax_id_prepay
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_prepay_distribution_id
      and    tds_tax_id_prepay is not null
      and    tds_applicable_flag = 'Y';

    cursor c_get_wct_tax_id(p_invoice_id number, p_prepay_distribution_id number) is
      select wct_tax_id_prepay
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_prepay_distribution_id
      and    wct_tax_id_prepay is not null
      and    wct_applicable_flag = 'Y';

    cursor c_get_essi_tax_id(p_invoice_id number, p_prepay_distribution_id number) is
      select essi_tax_id_prepay
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_prepay_distribution_id
      and    essi_tax_id_prepay is not null
      and    essi_applicable_flag = 'Y';

    cursor c_get_invoice_num_of_apply(p_threshold_trx_id number) is
      select invoice_to_tds_authority_num,
             invoice_to_vendor_num,
             /* Bug 5751783
              * Pass the Prepayment application invoice_id for generating the
              * prepayment unapplication
              */
             invoice_id,
             tax_id
      from   jai_ap_tds_thhold_trxs
      where  threshold_trx_id = p_threshold_trx_id;


      r_get_total_prepayment_tax        c_get_total_prepayment_tax%rowtype;
      r_tds_details_apply               c_tds_details_apply%rowtype;
      r_gl_sets_of_books                c_gl_sets_of_books%rowtype;

      lv_invoice_to_tds_num             ap_invoices_all.invoice_num%type;
      lv_invoice_to_vendor_num          ap_invoices_all.invoice_num%type;
      ln_threshold_trx_id_apply         number;
      ln_threshold_trx_id_tds           number;
      ln_threshold_trx_id_wct           number;
      ln_threshold_trx_id_essi          number;
      ln_start_threshold_trx_id         number;
      ln_exchange_rate                  number;
      ln_tax_id                         number;
      ln_threshold_grp_id               number;
      ln_threshold_grp_audit_id         number;
      lv_invoice_num_to_tds_apply       ap_invoices_all.invoice_num%type;
      lv_invoice_num_to_vendor_apply    ap_invoices_all.invoice_num%type;
      /*Bug 5751783 - Start*/
      ln_parent_pp_invoice_id           NUMBER ;
      ln_threshold_slab_id              jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
      lv_threshold_type                 jai_ap_tds_thhold_types.threshold_type%TYPE;
      ln_after_threshold_slab_id        jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
      lv_after_threshold_type           jai_ap_tds_thhold_types.threshold_type%TYPE;
      ln_temp_threshold_grp_id          jai_ap_tds_thhold_grps.threshold_grp_id%TYPE;
      ln_temp_threshold_hdr_id          jai_ap_tds_thhold_hdrs.threshold_hdr_id%TYPE;
      lv_slab_transition_tds_event      jai_ap_tds_thhold_trxs.tds_event%type;
      lv_ppu_tds_inv_num                ap_invoices_all.invoice_num%type;
      lv_ppu_tds_cm_num                 ap_invoices_all.invoice_num%type;
      /*Bug 5751783 - End*/
      -- Bug 6031679. Added by Lakshmi Gopalsami
      ln_inv_dist_id_apply ap_invoice_distributions_all.invoice_distribution_id%TYPE ;


  begin
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_prepayemnts_pkg.process_unapply', 'START'); /* 1 */

    open c_gl_sets_of_books(p_set_of_books_id);
    fetch c_gl_sets_of_books into r_gl_sets_of_books;
    close c_gl_sets_of_books;

    if r_gl_sets_of_books.currency_code <> p_invoice_currency_code then
      /* Foreign currency invoice */
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      ln_exchange_rate := p_exchange_rate;
    end if;

    ln_exchange_rate := nvl(ln_exchange_rate, 1);

    open  c_get_total_prepayment_tax(p_invoice_id, p_parent_distribution_id, ln_exchange_rate);
    fetch c_get_total_prepayment_tax  into r_get_total_prepayment_tax;
    close c_get_total_prepayment_tax;

    /* Bug 5751783
     * Call to procedure - get_tds_threshold_slab,
     * Store the current Threshold slab and type
     * before PP Unapplication
     */
    /* Unapply TDS */
    if r_get_total_prepayment_tax.tds_amount > 0 then

     OPEN c_tds_details_apply(p_invoice_id, p_parent_distribution_id, ln_exchange_rate);
     LOOP
      FETCH  c_tds_details_apply INTO  r_tds_details_apply;
      EXIT WHEN c_tds_details_apply%NOTFOUND ;

      ln_temp_threshold_grp_id := r_tds_details_apply.tds_threshold_grp_id;
      jai_ap_tds_generation_pkg.get_tds_threshold_slab(
                                    p_prepay_distribution_id => p_prepay_distribution_id,
                                    p_threshold_grp_id       => ln_temp_threshold_grp_id,
                                    p_threshold_hdr_id       => ln_temp_threshold_hdr_id,
                                    p_threshold_slab_id      => ln_threshold_slab_id,
                                    p_threshold_type         => lv_threshold_type,
                                    p_process_flag           => p_process_flag,
                                    p_process_message        => p_process_message,
                                    p_codepath               => p_codepath);

      IF p_process_flag = 'E' THEN
         goto exit_from_procedure;
      END IF;


      ln_threshold_grp_id:= r_tds_details_apply.tds_threshold_grp_id;
      jai_ap_tds_generation_pkg.maintain_thhold_grps
      (
        p_threshold_grp_id             =>   ln_threshold_grp_id,
        p_trx_invoice_unapply_amount   =>   r_tds_details_apply.tds_taxable_basis,/*5751783*/
        p_tds_event                    =>   'PREPAYMENT UNAPPLICATION',
        p_invoice_id                   =>   p_invoice_id,
        p_invoice_distribution_id      =>   p_invoice_distribution_id,
        p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
        p_process_flag                 =>   p_process_flag,
        P_process_message              =>   p_process_message,
        p_codepath                     =>   p_codepath
      );

      --Added by Sanjikum for Bug#5131075(4722011)
      IF p_process_flag = 'E' THEN
         goto exit_from_procedure;
      END IF;


      if  r_tds_details_apply.tds_threshold_trx_id_apply is not null then

        lv_invoice_to_tds_num := null;
        lv_invoice_to_vendor_num := null;
        ln_tax_id := null;

        /* get the tds invoice numbers at apply */
        /* Bug 5721614. Added by Lakshmi Gopalsami
         * Fetched the invoice_id to be passed for generating the TDS invoice
         * for prepayment unapplication.
         */
        open  c_get_invoice_num_of_apply(r_tds_details_apply.tds_threshold_trx_id_apply);
        fetch c_get_invoice_num_of_apply into
                    lv_invoice_num_to_tds_apply,
                    lv_invoice_num_to_vendor_apply,
                    ln_parent_pp_invoice_id,
                    ln_tax_id; -- bug 6031679
        close c_get_invoice_num_of_apply ;

        /* Bug 5751783
         * Changed from p_invoice_id to ln_parent_pp_invoice_id ie,
         * invoice_id of the prepayment application.
         */
        jai_ap_tds_generation_pkg.generate_tds_invoices
        (
          pn_invoice_id                   =>      ln_parent_pp_invoice_id                         ,
          pn_invoice_distribution_id      =>      p_invoice_distribution_id                       ,
          pv_invoice_num_to_tds_apply     =>      lv_invoice_num_to_tds_apply                     ,
          pv_invoice_num_to_vendor_apply  =>      lv_invoice_num_to_vendor_apply                  ,
          pn_taxable_amount               =>      r_tds_details_apply.tds_taxable_basis           ,/*5751783*/
          pn_tax_amount                   =>      r_tds_details_apply.tds_amount_orig             ,/*5751783*/
          pn_tax_id                       =>      ln_tax_id                                       ,
          pd_accounting_date              =>      p_accounting_date                               ,
          pv_tds_event                    =>      'PREPAYMENT UNAPPLICATION'                      ,
          pn_threshold_grp_id             =>      r_tds_details_apply.tds_threshold_grp_id        ,
          pv_tds_invoice_num              =>      lv_invoice_to_tds_num                           ,
          pv_cm_invoice_num               =>      lv_invoice_to_vendor_num                        ,
          pn_threshold_trx_id             =>      ln_threshold_trx_id_tds                         ,
          pd_creation_date                =>      p_creation_date, -- Bug 5722028. Added by CSahoo
          p_process_flag                  =>      p_process_flag                                  ,
          p_process_message               =>      p_process_message
        );

        if  p_process_flag = 'E' then
          goto exit_from_procedure;
        end if;

        /* prepayment apply scenario for backward compatibility*/
        update  JAI_AP_TDS_INVOICES
        set     amt_reversed = nvl(amt_reversed, 0) - r_get_total_prepayment_tax.tds_amount,
                amt_applied  = nvl(amt_applied, 0)   - abs(p_prepay_amount)
        where   invoice_id = p_invoice_id;
        /* prepayment apply scenario for backward compatibility*/

        /* Update the threshold group */

				ln_threshold_grp_id:= r_tds_details_apply.tds_threshold_grp_id;
                if p_event = 'INSERT' then /*Added for Bug 8431516*/
                    jai_ap_tds_generation_pkg.maintain_thhold_grps
                    (
                        p_threshold_grp_id             =>   ln_threshold_grp_id,
                        p_trx_tax_paid                 =>   r_get_total_prepayment_tax.tds_amount,
                        p_tds_event                    =>   'PREPAYMENT UNAPPLICATION',
                        p_invoice_id                   =>   p_invoice_id,
                        p_invoice_distribution_id      =>   p_invoice_distribution_id,
                        p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
                        p_process_flag                 =>   p_process_flag,
                        P_process_message              =>   p_process_message,
                        p_codepath                     =>   p_codepath
                    );

                    --Added by Sanjikum for Bug#5131075(4722011)
                    IF p_process_flag = 'E' THEN
                        goto exit_from_procedure;
                    END IF;
                END IF; /*if p_event = 'INSERT' then*/

        update jai_ap_tds_prepayments
        set    tds_threshold_trx_id_unapply = ln_threshold_trx_id_tds
        where  invoice_id = p_invoice_id
        and    invoice_distribution_id_prepay = p_parent_distribution_id
        and    tds_threshold_trx_id_apply is not null
        and    tds_applicable_flag = 'Y';

        if ln_start_threshold_trx_id is null then
          ln_start_threshold_trx_id := ln_threshold_trx_id_tds;
        end if;

      end if; /* r_tds_details_apply.tds_threshold_trx_id_apply is not null */

    /* update the unapply flag for invoice distribution */
    update jai_ap_tds_prepayments
    set    unapply_flag = 'Y'
    where  invoice_id = p_invoice_id
    and    invoice_distribution_id_prepay = p_parent_distribution_id;

    /*Bug 9132694 - Only one Unapplication entry would be created in jai_ap_tds_thhold_trxs for one unapplication*/

    /* Bug 5751783
     * Call to procedure - get_tds_threshold_slab,
     * Store the current Threshold slab and type
     * After PP Unapplication
     */

     jai_ap_tds_generation_pkg.get_tds_threshold_slab(
       p_prepay_distribution_id => p_prepay_distribution_id,
       p_threshold_grp_id       => ln_temp_threshold_grp_id,
       p_threshold_hdr_id       => ln_temp_threshold_hdr_id,
       p_threshold_slab_id      => ln_after_threshold_slab_id,
       p_threshold_type         => lv_after_threshold_type,
       p_process_flag           => p_process_flag,
       p_process_message        => p_process_message,
       p_codepath               => p_codepath);

     IF p_process_flag = 'E' THEN
        goto exit_from_procedure;
     END IF;

     IF ln_threshold_slab_id <> ln_after_threshold_slab_id THEN
        lv_slab_transition_tds_event :=
          'THRESHOLD TRANSITION-PPUA(from slab id -' || ln_threshold_slab_id ||
          'to slab id - ' || ln_after_threshold_slab_id || ')';
         jai_ap_tds_generation_pkg.process_threshold_transition
          (
            p_threshold_grp_id    =>      ln_temp_threshold_grp_id,
            p_threshold_slab_id   =>      ln_after_threshold_slab_id,
            p_invoice_id          =>      ln_parent_pp_invoice_id,
            p_vendor_id           =>      p_vendor_id,
            p_vendor_site_id      =>      p_vendor_site_id,
            p_accounting_date     =>      p_accounting_date,
            p_tds_event           =>      lv_slab_transition_tds_event,
            p_org_id              =>      p_org_id,
            pv_tds_invoice_num    =>      lv_ppu_tds_inv_num,
            pv_cm_invoice_num     =>      lv_ppu_tds_cm_num,
            p_process_flag        =>      p_process_flag,
            p_process_message     =>      p_process_message
          );

        IF p_process_flag = 'E' THEN
                goto exit_from_procedure;
        END IF;
      END IF ; /* ln_threshold_slab_id <> ln_after_threshold_slab_id */
      ln_threshold_trx_id_tds := NULL ;
      /*Bug 5751783*/
     END LOOP ;
     CLOSE  c_tds_details_apply;


    end if; /* r_get_total_prepayment_tax.tds_amount > 0*/
    /* Unapply TDS */


    /* Unapply WCT */
    ln_threshold_trx_id_apply := null;
    if r_get_total_prepayment_tax.wct_amount > 0 then

     OPEN c_wct_details_apply(p_invoice_id, p_parent_distribution_id);
     LOOP
      FETCH c_wct_details_apply into ln_threshold_trx_id_apply, ln_inv_dist_id_apply ;
      EXIT WHEN c_wct_details_apply%NOTFOUND ;

      if  ln_threshold_trx_id_apply is not null then

        lv_invoice_to_tds_num := null;
        lv_invoice_to_vendor_num := null;
        ln_tax_id := null;

        /* get the tds invoice numbers at apply */
        /* Bug 5751783
         * Fetched the invoice_id to be passed for generating the TDS invoice
         * for prepayment unapplication.
         */
        open  c_get_invoice_num_of_apply(ln_threshold_trx_id_apply);
        fetch c_get_invoice_num_of_apply into
                 lv_invoice_num_to_tds_apply,
                 lv_invoice_num_to_vendor_apply,
                 ln_parent_pp_invoice_id,
                 ln_tax_id ;
        close c_get_invoice_num_of_apply ;

        /* Bug 5751783
         * Changed from p_invoice_id to ln_parent_pp_invoice_id ie,
         * invoice_id of the prepayment application.
         */

        jai_ap_tds_generation_pkg.generate_tds_invoices
        (
          pn_invoice_id                   =>      ln_parent_pp_invoice_id                         ,
          pn_invoice_distribution_id      =>      p_invoice_distribution_id                       ,
          pv_invoice_num_to_tds_apply     =>      lv_invoice_num_to_tds_apply                     ,
          pv_invoice_num_to_vendor_apply  =>      lv_invoice_num_to_vendor_apply                  ,
          pn_taxable_amount               =>      r_get_total_prepayment_tax.wct_taxable_basis    ,
          pn_tax_amount                   =>      r_get_total_prepayment_tax.wct_amount_orig      ,
          pn_tax_id                       =>      ln_tax_id                                       ,
          pd_accounting_date              =>      p_accounting_date                               ,
          pv_tds_event                    =>      'PREPAYMENT UNAPPLICATION'                      ,
          pn_threshold_grp_id             =>      null                                            ,
          pv_tds_invoice_num              =>      lv_invoice_to_tds_num                           ,
          pv_cm_invoice_num               =>      lv_invoice_to_vendor_num                        ,
          pn_threshold_trx_id             =>      ln_threshold_trx_id_wct                         ,
          pd_creation_date                =>      p_creation_date, -- Bug 5722028. Added by csahoo
          p_process_flag                  =>      p_process_flag                                  ,
          p_process_message               =>      p_process_message
        );

        if  p_process_flag = 'E' then
          goto exit_from_procedure;
        end if;

        update jai_ap_tds_prepayments
        set    wct_threshold_trx_id_unapply = ln_threshold_trx_id_wct
        where  invoice_id = p_invoice_id
        and    invoice_distribution_id_prepay = p_parent_distribution_id
        and    wct_threshold_trx_id_apply is not null
        and    wct_applicable_flag = 'Y';

        if ln_start_threshold_trx_id is null then
          ln_start_threshold_trx_id := ln_threshold_trx_id_wct;
        end if;

      end if; /* ln_threshold_trx_id_apply.tds_threshold_trx_id_apply is not null  */
      ln_threshold_trx_id_apply := null;
      ln_threshold_trx_id_wct := null;
     END LOOP ;
     CLOSE c_wct_details_apply;
    end if;
    /* Unapply WCT */

    /* Unapply ESSI */
    ln_threshold_trx_id_apply := null;
    /*Bug 5751783. Changed to ESSI instead of wct_amount*/
    if r_get_total_prepayment_tax.essi_amount > 0 then

     OPEN c_essi_details_apply(p_invoice_id, p_parent_distribution_id);
     LOOP
      FETCH c_essi_details_apply into ln_threshold_trx_id_apply,ln_inv_dist_id_apply;
      EXIT WHEN c_essi_details_apply%NOTFOUND ;

      if  ln_threshold_trx_id_apply is not null then

        lv_invoice_to_tds_num := null;
        lv_invoice_to_vendor_num := null;
        ln_tax_id := null;

        /* get the tds invoice numbers at apply */
        /* Bug 5751783
         * Fetched the invoice_id to be passed for generating the TDS invoice
         * for prepayment unapplication.
         */
        open  c_get_invoice_num_of_apply(ln_threshold_trx_id_apply);
        fetch c_get_invoice_num_of_apply into
                   lv_invoice_num_to_tds_apply,
                   lv_invoice_num_to_vendor_apply,
                   ln_parent_pp_invoice_id,
                   ln_tax_id;
        close c_get_invoice_num_of_apply ;

        /* Bug 5721614. Added by Lakshmi Gopalsami
         * Changed from p_invoice_id to ln_parent_pp_invoice_id ie,
         * invoice_id of the prepayment application.
         */
        jai_ap_tds_generation_pkg.generate_tds_invoices
        (
          pn_invoice_id                   =>      ln_parent_pp_invoice_id                         ,
          pn_invoice_distribution_id      =>      p_invoice_distribution_id                       ,
          pv_invoice_num_to_tds_apply     =>      lv_invoice_num_to_tds_apply                     ,
          pv_invoice_num_to_vendor_apply  =>      lv_invoice_num_to_vendor_apply                  ,
          pn_taxable_amount               =>      r_get_total_prepayment_tax.essi_taxable_basis   ,
          pn_tax_amount                   =>      r_get_total_prepayment_tax.essi_amount_orig     ,
          pn_tax_id                       =>      ln_tax_id                                       ,
          pd_accounting_date              =>      p_accounting_date                               ,
          pv_tds_event                    =>      'PREPAYMENT UNAPPLICATION'                      ,
          pn_threshold_grp_id             =>      null                                            ,
          pv_tds_invoice_num              =>      lv_invoice_to_tds_num                           ,
          pv_cm_invoice_num               =>      lv_invoice_to_vendor_num                        ,
          pn_threshold_trx_id             =>      ln_threshold_trx_id_essi                        ,
          pd_creation_date                =>      p_creation_date, -- Bug 5722028. Added by CSahoo
          p_process_flag                  =>      p_process_flag                                  ,
          p_process_message               =>      p_process_message
        );

        if  p_process_flag = 'E' then
          goto exit_from_procedure;
        end if;

        update jai_ap_tds_prepayments
        set    essi_threshold_trx_id_unapply = ln_threshold_trx_id_essi
        where  invoice_id = p_invoice_id
        and    invoice_distribution_id_prepay = p_parent_distribution_id
        and    essi_threshold_trx_id_apply is not null
        and    essi_applicable_flag = 'Y';


        if ln_start_threshold_trx_id is null then
          ln_start_threshold_trx_id := ln_threshold_trx_id_essi;
        end if;

      end if; /* ln_threshold_trx_id_apply.tds_threshold_trx_id_apply is not null */
      ln_threshold_trx_id_apply := null;
      ln_threshold_trx_id_essi := null;
     END LOOP ;
     CLOSE  c_essi_details_apply;
    end if;
    /* Unapply ESSI */

    /* update the unapply flag for all */
    update jai_ap_tds_prepayments
    set    unapply_flag = 'Y'
    where  invoice_id = p_invoice_id
    and    invoice_distribution_id_prepay = p_parent_distribution_id;

    /* prepayment apply scenario for backward compatibility*/
    update  JAI_AP_TDS_INVOICES
    set  amt_reversed = nvl(amt_reversed, 0) - r_get_total_prepayment_tax.tds_amount_orig,
         amt_applied  = nvl(amt_applied, 0)  - abs(p_prepay_amount)
    where  invoice_id = p_invoice_id;

    if ln_start_threshold_trx_id is not null then

      jai_ap_tds_generation_pkg.import_and_approve
      (
        p_invoice_id                   =>     ln_parent_pp_invoice_id, /*Bug 5751783*/
        p_start_thhold_trx_id          =>     ln_start_threshold_trx_id,
        p_tds_event                    =>     'PREPAYMENT UNAPPLICATION',
        p_process_flag                 =>     p_process_flag,
        p_process_message              =>     p_process_message
      );

      --Added by Sanjikum for Bug#5131075(4722011)
      IF p_process_flag = 'E' THEN
         goto exit_from_procedure;
      END IF;

    end if;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(100, p_codepath, null, 'END'); /* 100 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'jai_ap_tds_prepayemnts_pkg.process_unapply :' ||  sqlerrm;
      return;
  end process_unapply;

/***********************************************************************************************/

  procedure allocate_prepayment
  (
    p_invoice_id                         in                     number,
    p_invoice_distribution_id            in                     number, /* Of the PREPAY line */
    p_prepay_amount                      in                     number,
    p_process_flag                       out     nocopy         varchar2,
    p_process_message                    out     nocopy         varchar2,
    p_codepath                           in out  nocopy         varchar2
  )
  is
    /*Bug 9494469 - Removed parameter cp_section_type from c_jai_ap_tds_inv_taxes*/
    cursor c_jai_ap_tds_inv_taxes(p_invoice_id number, p_prepay_distribution_id number) is
      select invoice_distribution_id, amount, invoice_line_number, invoice_id
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id <> p_prepay_distribution_id
      --and    section_type = cp_section_type /*Commented for Bug 9494469*/
      and    nvl(actual_tax_id, default_tax_id) is not null /*Bug 8431516*/
	  and    amount > 0; --Added by bgowrava for bug#9214036

    cursor c_get_amount_already_applied(p_invoice_distribution_id number) is
      select  sum(application_amount)
      from    jai_ap_tds_prepayments
      where   invoice_distribution_id = p_invoice_distribution_id
      and     nvl(unapply_flag, 'N') <> 'Y';

/*START, Added by bgowrava for bug#9214036*/
	cursor c_get_effective_available_amt(p_invoice_id number, p_invoice_line_num number) is
	select sum(amount) amount
	from jai_ap_tds_inv_taxes
	where invoice_id = p_invoice_id
	and invoice_line_number = p_invoice_line_num
	and amount < 0;
/*END, Added by bgowrava for bug#9214036*/

      ln_remaining_prepayment_amount      number;
      ln_effective_available_amount       number;
      ln_already_applied_amount           number;
      ln_application_amount               number;
      ln_less_amount                      number; --Added by bgowrava for bug#9214036
      lv_reversal_flag                    varchar2(1); /*Bug 8431516*/

  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_prepayemnts_pkg.allocate_prepayment', 'START'); /* 1 */

    ln_remaining_prepayment_amount := abs(p_prepay_amount); /* Apply amount is negative */

    /* Loop through to get the taxable basis for each line in jai_ap_tds_inv_taxes */
    /* It is ok to loop through section_type = 'TDS_SECTION as considering any one section type
       is ok and tds section will always be there */

    -- Bug 4754213. Added by Lakshmi Gopalsami
    for cur_si_distributions_rec in c_jai_ap_tds_inv_taxes(p_invoice_id, p_invoice_distribution_id) /*Bug 9494469 - Removed parameter cp_section_type*/
    loop

      lv_reversal_flag := get_reversal_flag(cur_si_distributions_rec.invoice_distribution_id); /*Bug 8431516*/
      if lv_reversal_flag = 'N' then /*Bug 8431516*/

          ln_already_applied_amount:= 0;
          ln_effective_available_amount := 0;
          ln_application_amount := 0;

          open  c_get_amount_already_applied(cur_si_distributions_rec.invoice_distribution_id);
          fetch c_get_amount_already_applied into ln_already_applied_amount;
          close c_get_amount_already_applied;

          ln_already_applied_amount := nvl(ln_already_applied_amount, 0);

          /*START, Added by bgowrava for bug#9214036*/
          open c_get_effective_available_amt(cur_si_distributions_rec.invoice_id, cur_si_distributions_rec.invoice_line_number);
          fetch c_get_effective_available_amt into ln_less_amount;
          close c_get_effective_available_amt;
          ln_less_amount := nvl(ln_less_amount, 0);
          /*END, Added by bgowrava for bug#9214036*/

          ln_effective_available_amount := cur_si_distributions_rec.amount - ln_already_applied_amount - abs(ln_less_amount);  --Added abs(ln_less_amount) by Bgowrava for Bug#9214036

          ln_application_amount := least(ln_remaining_prepayment_amount, ln_effective_available_amount);

          if ln_application_amount > 0 then

            /* Insert into jai_ap_tds_prepayments */
            insert into jai_ap_tds_prepayments
            (
              tds_prepayment_id                                   ,
              invoice_id                                          ,
              invoice_distribution_id_prepay                      ,
              invoice_distribution_id                             ,
              application_amount                                  ,
              created_by                                          ,
              creation_date                                       ,
              last_updated_by                                     ,
              last_update_date                                    ,
              last_update_login
            )
            values
            (
              jai_ap_tds_prepayments_s.nextval                    ,
              p_invoice_id                                        ,
              p_invoice_distribution_id                           ,
              cur_si_distributions_rec.invoice_distribution_id    ,
              ln_application_amount                               ,
              fnd_global.user_id                                  ,
              sysdate                                             ,
              fnd_global.user_id                                  ,
              sysdate                                             ,
              fnd_global.login_id
            );

          end if;

          ln_remaining_prepayment_amount :=  ln_remaining_prepayment_amount -  ln_application_amount;

          if ln_remaining_prepayment_amount <= 0 then
            goto exit_from_procedure;
          end if;

      end if; /*if lv_reversal_flag = 'N' then*/

    end loop; /* cur_si_distributions_rec in c_jai_ap_tds_inv_taxes */


    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(100, p_codepath, null, 'END'); /* 100 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'jai_ap_tds_prepayemnts_pkg.allocate_prepayment :' ||  sqlerrm;
      return;
  end allocate_prepayment;

/***********************************************************************************************/

  procedure populate_section_tax
  (
    p_invoice_id                         in                 number,
    p_invoice_distribution_id            in                 number, /* Of the PREPAY line in the SI*/
    p_prepay_distribution_id             in                 number, /*Distribution id of the PP invoice */
    p_process_flag                       out     nocopy     varchar2,
    p_process_message                    out     nocopy     varchar2,
    p_codepath                           in out  nocopy     varchar2
  )
  is

    cursor c_get_tax_details_pp_inv_dist(p_pre_pay_inv_id number, p_prepay_distribution_id number) is  -- Added parameter p_pre_pay_inv_id by Jia for FP bug6929483
      select section_type,
             nvl(actual_section_code, default_section_code) section_code,   --Added NVL condition for Bug 8431516
             nvl(actual_tax_id, default_tax_id) tax_id                      --Added NVL condition for Bug 8431516
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_pre_pay_inv_id -- Added where clause p_pre_pay_inv_id by Jia for FP bug6929483
      and    invoice_distribution_id = p_prepay_distribution_id
      and    nvl(actual_tax_id, default_tax_id) is not null;                --Added NVL condition for Bug 8431516

    cursor c_get_tax_details_si_inv_dist(p_invoice_id number, p_invoice_distribution_id number) is
      select section_type,
             nvl(actual_section_code, default_section_code)  section_code,
             nvl(actual_tax_id, default_tax_id) tax_id
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id = p_invoice_distribution_id;


     cursor c_jai_ap_tds_prepayments(p_invoice_id number, p_invoice_distribution_id number) is
       select tds_prepayment_id,
              invoice_distribution_id
       from   jai_ap_tds_prepayments
       where  invoice_id = p_invoice_id
       and    invoice_distribution_id_prepay = p_invoice_distribution_id;



    cursor c_get_tds_application_basis(p_invoice_id number) is
      select 'N'
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    nvl(match_status_flag, 'N') <> 'A';

    /* Bug 5751783 - Start*/
    /* added parameter p_pre_pay_inv_id to cursor for bug 6929483*/
    CURSOR get_threshold_trx_id (p_pre_pay_inv_id number, p_invoice_distribution_id IN NUMBER )
    IS
    SELECT threshold_trx_id
    FROM   jai_ap_tds_inv_taxes
    WHERE  invoice_id = p_pre_pay_inv_id
    AND    invoice_distribution_id = p_invoice_distribution_id ;

    lv_si_thhold_trx_id      jai_ap_tds_thhold_trxs.threshold_trx_id%TYPE;
    lv_pp_thhold_trx_id      jai_ap_tds_thhold_trxs.threshold_trx_id%TYPE;
    /* Bug 5751783 - End*/

    lv_applicable_flag                varchar2(1);
    lv_is_si_validated_flag           varchar2(1);

    lv_tds_section_code_prepay        jai_ap_tds_prepayments.tds_section_code_prepay%type;
    ln_tds_tax_id_prepay              jai_ap_tds_prepayments.tds_tax_id_prepay%type;
    ln_wct_tax_id_prepay              jai_ap_tds_prepayments.wct_tax_id_prepay%type;
    ln_essi_tax_id_prepay             jai_ap_tds_prepayments.essi_tax_id_prepay%type;
    lv_application_basis              jai_ap_tds_prepayments.application_basis%type;


    lv_tds_section_code_other         jai_ap_tds_prepayments.tds_section_code_other%type;
    ln_tds_tax_id_other               jai_ap_tds_prepayments.tds_tax_id_other%type;
    lv_tds_applicable_flag            jai_ap_tds_prepayments.tds_applicable_flag%type;
    ln_wct_tax_id_other               jai_ap_tds_prepayments.wct_tax_id_other%type;
    lv_wct_applicable_flag            jai_ap_tds_prepayments.wct_applicable_flag%type;
    ln_essi_tax_id_other              jai_ap_tds_prepayments.essi_tax_id_other%type;
    lv_essi_applicable_flag           jai_ap_tds_prepayments.essi_applicable_flag%type;

    pre_pay_inv_id                    ap_invoice_distributions_all.invoice_id%TYPE;  -- Added by Jia for FP bug6929483


  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_prepayemnts_pkg.populate_section_tax', 'START'); /* 1 */

    get_prepay_invoice_id(p_prepay_distribution_id,pre_pay_inv_id); -- Added by Jia for FP bug6929483

    /*
    open  c_get_tds_application_basis(p_invoice_id);
    fetch c_get_tds_application_basis into lv_is_si_validated_flag;
    close c_get_tds_application_basis;

    if nvl(lv_is_si_validated_flag, 'Y') = 'Y' then
      lv_application_basis := 'STANDARD INVOICE';
    else
      lv_application_basis := 'PREPAYMENT';
    end if;
    */

    /* Bug 5751783
    * Commented the above logic as the above is obsoleted and the logic
    * for the deriving the basis is changed.
    * We should get the details of the invoice which is created latest in the
    * system.  i.e., whichever is validated later in the system. We can get
    * these details by getting the value of threshold_trx_id from
    * jai_ap_tds_inv_taxes.
    */

    -- Get the tds_threshold_trx_id of the prepay invoice.
    OPEN get_threshold_trx_id (pre_pay_inv_id,p_prepay_distribution_id );
    FETCH get_threshold_trx_id INTO lv_pp_thhold_trx_id ;
    CLOSE get_threshold_trx_id;

    -- Get the threshold_trx_id of the standard invoice.
    SELECT max(nvl(threshold_trx_id, 0))
    INTO lv_si_thhold_trx_id
    FROM jai_ap_tds_inv_taxes
    WHERE invoice_id = p_invoice_id ;

    IF (lv_si_thhold_trx_id >  NVL (lv_pp_thhold_trx_id,0 )) THEN
       lv_application_basis := 'STANDARD INVOICE';
    ELSIF ( NVL (lv_pp_thhold_trx_id,0 ) <> 0 ) THEN
      lv_application_basis := 'PREPAYMENT';
    END IF ;
    /*Bug 5751783 - End*/

    /* Get the details of the taxes of all sections that was applicable on the distribution line as in the Prepayment */
    for cur_rec_pp_tax_details in c_get_tax_details_pp_inv_dist(pre_pay_inv_id,p_prepay_distribution_id) loop -- Added parameter pre_pay_inv_id by Jia for FP bug6929483
      -- Bug 4754213. Added by Lakshmi Gopalsami
      if cur_rec_pp_tax_details.section_type = 'TDS_SECTION' then
        lv_tds_section_code_prepay := cur_rec_pp_tax_details.section_code;
        ln_tds_tax_id_prepay       := cur_rec_pp_tax_details.tax_id;
      elsif cur_rec_pp_tax_details.section_type = 'WCT_SECTION' then
        ln_wct_tax_id_prepay       := cur_rec_pp_tax_details.tax_id;
      elsif cur_rec_pp_tax_details.section_type = 'ESSI_SECTION' then
        ln_essi_tax_id_prepay       := cur_rec_pp_tax_details.tax_id;
      end if;

    end loop;  /* cur_rec_pp_tax_details */


    /* Loop and get all the distribution is that has been been allocated for this prepayment and
       get the tax details that is applicable on the allocated line */
    for cur_rec_pp_allocations in c_jai_ap_tds_prepayments(p_invoice_id, p_invoice_distribution_id) loop

      for cur_rec in c_get_tax_details_si_inv_dist(p_invoice_id, cur_rec_pp_allocations.invoice_distribution_id) loop
       -- Bug 4754213. Added by Lakshmi Gopalsami
      if  cur_rec.section_type = 'TDS_SECTION' then

        lv_tds_section_code_other := cur_rec.section_code;
        ln_tds_tax_id_other       := cur_rec.tax_id;

        if lv_tds_section_code_other = lv_tds_section_code_prepay and
           lv_tds_section_code_other is not null and
           lv_tds_section_code_prepay is not null
        then
          lv_tds_applicable_flag := 'Y';
        else
          lv_tds_applicable_flag := 'N';
        end if;

      elsif cur_rec.section_type = 'WCT_SECTION' then

        ln_wct_tax_id_other       := cur_rec.tax_id;

        if ln_wct_tax_id_prepay is not null and ln_wct_tax_id_other is not null then
          lv_wct_applicable_flag := 'Y';
        else
          lv_wct_applicable_flag := 'N';
        end if;

      elsif cur_rec.section_type = 'ESSI_SECTION' then

        ln_essi_tax_id_other       := cur_rec.tax_id;

        if ln_essi_tax_id_prepay is not null and ln_essi_tax_id_other is not null then
          lv_essi_applicable_flag := 'Y';
        else
          lv_essi_applicable_flag := 'N';
        end if;

      end if; /* Section type of the SI distributions */

     end loop; /* Cur rec */


     /* Update jai_ap_tds_prepayments */
     update jai_ap_tds_prepayments
     set    application_basis           =     lv_application_basis            ,
            tds_section_code_prepay     =     lv_tds_section_code_prepay      ,
            tds_section_code_other      =     lv_tds_section_code_other       ,
            tds_tax_id_prepay           =     ln_tds_tax_id_prepay            ,
            tds_tax_id_other            =     ln_tds_tax_id_other             ,
            tds_applicable_flag         =     lv_tds_applicable_flag          ,
            wct_tax_id_prepay           =     ln_wct_tax_id_prepay            ,
            wct_tax_id_other            =     ln_wct_tax_id_other             ,
            wct_applicable_flag         =     lv_wct_applicable_flag          ,
            essi_tax_id_prepay          =     ln_essi_tax_id_prepay           ,
            essi_tax_id_other           =     ln_essi_tax_id_other            ,
            essi_applicable_flag        =     lv_essi_applicable_flag
     where  tds_prepayment_id = cur_rec_pp_allocations.tds_prepayment_id;


    end loop; /* cur_rec_pp_allocations */


    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(100, p_codepath, null, 'END'); /* 100 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'jai_ap_tds_prepayemnts_pkg.populate_section_tax :' ||  sqlerrm;
      return;
  end populate_section_tax;

/***********************************************************************************************/
  procedure process_tds_invoices
  (
    p_event                              in                     varchar2,      /*Bug 8431516*/
    p_invoice_id                         in                     number,
    p_invoice_distribution_id            in                     number,
    p_prepay_distribution_id             in                     number,
    p_prepay_amount                      in                     number,
    p_vendor_id                          in                     number,
    p_vendor_site_id                     in                     number,
    p_accounting_date                    in                     date,
    p_invoice_currency_code              in                     varchar2,
    p_exchange_rate                      in                     number,
    p_set_of_books_id                    in                     number,
    p_org_id                             in                     number,
    -- Bug 5722028. Added by CSahoo
    p_creation_date                      in                     date,
    p_process_flag                       out     nocopy         varchar2,
    p_process_message                    out     nocopy         varchar2,
    p_codepath                           in out  nocopy         varchar2
  )
  is

    cursor c_gl_sets_of_books(cp_set_of_books_id  number) is
      select currency_code
      from   gl_sets_of_books
      where  set_of_books_id = cp_set_of_books_id;

    cursor c_jai_ap_tds_prepayments(p_invoice_id number, p_invoice_distribution_id number) is
      select tds_prepayment_id,
             application_amount,
             application_basis,
             /*
             decode(tds_applicable_flag, 'Y',
                    decode(application_basis, 'STANDARD INVOICE', tds_tax_id_other, tds_tax_id_prepay),
                    null) tds_tax_id,
             decode(wct_applicable_flag, 'Y',
                    decode(application_basis, 'STANDARD INVOICE', wct_tax_id_other, wct_tax_id_prepay),
                    null) wct_tax_id,
             decode(essi_applicable_flag, 'Y',
                    decode(application_basis, 'STANDARD INVOICE', essi_tax_id_other, essi_tax_id_prepay),
                    null) essi_tax_id
             */
             /* Bug 6363056. Commented the above
              * and added the following. Need to selected the lowest rate between
              * SI and PP
              */
             tds_applicable_flag, tds_tax_id_other, tds_tax_id_prepay,
             wct_applicable_flag, wct_tax_id_other, wct_tax_id_prepay,
             essi_applicable_flag, essi_tax_id_other, essi_tax_id_prepay
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_invoice_distribution_id;


    cursor c_ja_in_tax_codes(p_tax_id number) is
      select nvl(tax_rate, 0) tax_rate
      from   JAI_CMN_TAXES_ALL
      where  tax_id = p_tax_id;

    --Add parameter p_pre_pay_inv_id in cursor c_get_prepayment_throup by Jia for FP bug6929483, Begin
    cursor c_get_prepayment_thgroup(p_pre_pay_inv_id number, p_prepay_distribution_id number,cp_section_type jai_ap_tds_inv_taxes.section_type%type) IS  --rchandan for bug#4428980
      select threshold_grp_id,
             actual_tax_id,
             threshold_trx_id /*Bug 6363056*/
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_pre_pay_inv_id -- Added by Jia for FP bug6929483
      and    invoice_distribution_id = p_prepay_distribution_id
      and    section_type = cp_section_type;   --rchandan for bug#4428980

    cursor c_get_pp_section_tax_id(p_prepay_distribution_id number, p_section_type varchar2) is
      select actual_tax_id, invoice_id /*Bug 5751783*/
      from   jai_ap_tds_inv_taxes
      where  invoice_distribution_id = p_prepay_distribution_id
      and    section_type = p_section_type;


    cursor c_jai_ap_tds_thhold_grps(p_threshold_grp_id number) is
      select nvl(current_threshold_slab_id, 0) current_threshold_slab_id
      from   jai_ap_tds_thhold_grps
      where  threshold_grp_id = p_threshold_grp_id;

      cursor c_ap_invoices_all (p_invoice_distribution_id number) is
        select invoice_num, invoice_id  /*Bug 5751783*/
        from   ap_invoices_all
        where  invoice_id in
               ( select invoice_id
                 from   jai_ap_tds_inv_taxes        /* ap_invoice_distributions not used for mutation problem */
                 where  invoice_distribution_id = p_invoice_distribution_id);


    cursor c_get_total_prepayment_tax
      (p_invoice_id number, p_invoice_distribution_id number, p_exchange_rate number) is
      select sum( decode(tds_applicable_flag , 'Y', application_amount*p_exchange_rate,  0) ) tds_taxable_basis,
             sum( decode(tds_applicable_flag , 'Y', tds_application_amount,  0) ) tds_amount,
             sum( decode(wct_applicable_flag,  'Y', application_amount*p_exchange_rate,  0) ) wct_taxable_basis,
             sum( decode(wct_applicable_flag,  'Y', wct_application_amount,  0) ) wct_amount,
             sum( decode(essi_applicable_flag, 'Y', application_amount*p_exchange_rate, 0) ) essi_taxable_basis,
             sum( decode(essi_applicable_flag, 'Y', essi_application_amount, 0) ) essi_amount
      from   jai_ap_tds_prepayments
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_invoice_distribution_id;

     /* Bug 4522507. Added by Lakshmi Gopalsami */

     cursor c_get_if_tds_inv_generated_pp(p_prepay_distribution_id  number) is
      select threshold_trx_id
      from   jai_ap_tds_inv_taxes
      where  invoice_distribution_id = p_prepay_distribution_id
          -- Bug 4754213. Added by Lakshmi Gopalsami
      and    section_type = 'TDS_SECTION';

    /*Bug 6363056 - Replaced p_invoice_distribution_id with p_item_distribution_id*/
    cursor c_get_amt_tds_inv_generated_si(p_invoice_id number, p_item_distribution_id  number) is
      select sum(calc_tds_appln_amt) , sum(application_amount)
      from   jai_ap_tds_prepayments jatp
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id_prepay = p_invoice_distribution_id
      /*Bug 6363056. Added invoice_distribution_id condition also*/
      and    invoice_distribution_id = p_item_distribution_id
      and    tds_applicable_flag = 'Y'
      and    exists (select '1'
                     from   jai_ap_tds_inv_taxes
                     where  invoice_distribution_id = jatp.invoice_distribution_id
 	             -- Bug 4754213. Added by Lakshmi Gopalsami
                     and    section_type = 'TDS_SECTION'
                     and    threshold_trx_id  is not null
                    );

    /*Bug 6363056 Start*/
    cursor c_si_ap_invoices_all (p_invoice_id number) is
    select invoice_num, invoice_id
    from   ap_invoices_all
    where  invoice_id = p_invoice_id;

    CURSOR c_get_thgrp_det ( p_threshold_grp_id NUMBER ) IS
    SELECT *
    FROM jai_ap_tds_thhold_grps
    WHERE threshold_grp_id = p_threshold_grp_id;
    /*Bug 6363056 End*/


   --Added by Xiao Lv for Bug#8345080 on 7-Jan-10, begin

   cursor c_get_grp_details_si_inv_dist(p_invoice_id number, p_invoice_distribution_id number)
       is
     select threshold_grp_id
       from jai_ap_tds_inv_taxes
      where invoice_id = p_invoice_id
        and invoice_distribution_id = p_invoice_distribution_id
        and section_type = 'TDS_SECTION'; --Added for bug#8855650 by JMEENA

	 cursor c_get_tax_sec_det(p_invoice_id number, p_invoice_distribution_id number)
	     is
	   select tds_section_code_other, tds_tax_id_other, application_amount, invoice_distribution_id
	     from jai_ap_tds_prepayments
	    where invoice_id = p_invoice_id
        and invoice_distribution_id_prepay = p_invoice_distribution_id;

   ln_si_thgrp_id                    number;
	 r_get_tax_sec_det                 c_get_tax_sec_det%rowtype;

   --Added by Xiao Lv for Bug#8345080 on 7-Jan-10, end

    r_gl_sets_of_books                  c_gl_sets_of_books%rowtype;
    r_ja_in_tax_codes                   c_ja_in_tax_codes%rowtype;
    r_get_total_prepayment_tax          c_get_total_prepayment_tax%rowtype;

    ln_exchange_rate                    number;
    ln_threshold_grp_id                 number;
    ln_total_tds_amount                 number;
    ln_current_threshold_slab_id        jai_ap_tds_thhold_grps.current_threshold_slab_id%type;
    ln_prepay_tax_id                    number;

    lv_invoice_to_tds_num               ap_invoices_all.invoice_num%type;
    lv_invoice_to_vendor_num            ap_invoices_all.invoice_num%type;
    lv_invoice_num_prepay_apply         ap_invoices_all.invoice_num%type;
    ln_threshold_trx_id_tds             number;
    ln_threshold_trx_id_wct             number;
    ln_threshold_trx_id_essi            number;
    ln_start_threshold_trx_id           number;
    ln_prepayment_amount                number;

    lb_result                           boolean;
    ln_req_id                           number;
    ln_pp_section_tax_id                number;
    ln_threshold_grp_audit_id           number;
    lv_application_basis                jai_ap_tds_prepayments.application_basis%type;
    /* Bug 4522507. Added by Lakshmi Gopalsami */
    ln_threshold_trx_id_prepay          jai_ap_tds_inv_taxes.threshold_trx_id%type;
    ln_amt_tds_inv_generated_si         number;
    --Added the below 6 variables by Sanjikum for Bug#5131075(4718907)
    ln_threshold_slab_id								jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
    lv_threshold_type										jai_ap_tds_thhold_types.threshold_type%TYPE;
    ln_after_threshold_slab_id					jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
    lv_after_threshold_type							jai_ap_tds_thhold_types.threshold_type%TYPE;
    ln_temp_threshold_grp_id						jai_ap_tds_thhold_grps.threshold_grp_id%TYPE;
    ln_temp_threshold_hdr_id						jai_ap_tds_thhold_hdrs.threshold_hdr_id%TYPE;

    -- Bug 5722028. Added by CSahoo
    ln_tds_tmp_amt number;
    /*Bug 5751783 - Start*/
    ln_si_tax_id                   NUMBER ;
    ln_parent_invoice_id           NUMBER ;
    ln_pp_section_invoice_id       NUMBER ;
    /*Bug 5751783 - End*/
    /*Bug 6363056 - Start*/
    r_ja_in_tax_codes_prepay       c_ja_in_tax_codes%rowtype;
    ln_tax_rate_basis              JAI_CMN_TAXES_ALL.tax_rate%TYPE ;
    ln_si_wct_tax_id               JAI_CMN_TAXES_ALL.tax_id%TYPE ;
    ln_si_essi_tax_id              JAI_CMN_TAXES_ALL.tax_id%TYPE ;
    ln_si_thhold_grp_id            jai_ap_tds_thhold_grps.threshold_grp_id%TYPE;
    ln_pp_thhold_grp_id            jai_ap_tds_thhold_grps.threshold_grp_id%TYPE;
    ln_parent_tax_id               JAI_CMN_TAXES_ALL.tax_id%TYPE ;
    ln_tds_application_amt         jai_ap_tds_prepayments.application_amount%TYPE ;
    r_pp_jai_ap_tds_thhold_grps    c_get_thgrp_det%ROWTYPE ;
    r_si_jai_ap_tds_thhold_grps    c_get_thgrp_det%ROWTYPE ;
    /*Bug 6363056 - End*/
    pre_pay_inv_id                    ap_invoice_distributions_all.invoice_id%TYPE;  -- Added by Jia for FP bug6929483
    /*START, Bgowrava for Bug#7626202*/
    ln_tot_tds_amt                 number := 0;
    ln_tot_appln_amt               number := 0;
    /*END, Bgowrava for Bug#7626202*/


  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_prepayemnts_pkg.process_tds_invoices', 'START'); /* 1 */

    get_prepay_invoice_id(p_prepay_distribution_id,pre_pay_inv_id); -- Added by Jia for FP bug6929483

    open c_gl_sets_of_books(p_set_of_books_id);
    fetch c_gl_sets_of_books into r_gl_sets_of_books;
    close c_gl_sets_of_books;

    if r_gl_sets_of_books.currency_code <> p_invoice_currency_code then
      /* Foreign currency invoice */
      p_codepath := jai_general_pkg.plot_codepath(6.1, p_codepath); /* 6.1 */
      ln_exchange_rate := p_exchange_rate;
    end if;

    ln_exchange_rate := nvl(ln_exchange_rate, 1);

    ln_prepayment_amount := -1 * p_prepay_amount * ln_exchange_rate;

    /* update the tax amount for the prepayements */
    for cur_rec in c_jai_ap_tds_prepayments(p_invoice_id, p_invoice_distribution_id)
    loop

      if lv_application_basis is null then
        lv_application_basis := cur_rec.application_basis;
      end if;

      /* TDS application amount */
      if cur_rec.tds_tax_id_other is not null AND
         cur_rec.tds_tax_id_prepay IS NOT NULL AND -- Bug 6363056
         cur_rec.tds_applicable_flag = 'Y'  -- Bug 6363056
      THEN

        r_ja_in_tax_codes := null;
        open c_ja_in_tax_codes(cur_rec.tds_tax_id_other); -- Bug 6363056
        fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
        close c_ja_in_tax_codes;

        ln_tax_rate_basis := r_ja_in_tax_codes.tax_rate; -- bug 6363056
        ln_si_tax_id := cur_rec.tds_tax_id_other; -- bug 6363056


        /* Bug 5722028. Addd by CSahoo
	     * Need to round the value as per the setup.
	     */
        ln_tds_tmp_amt := 0;
        if r_gl_sets_of_books.currency_code = p_invoice_currency_code then
          ln_tds_tmp_amt := round(cur_rec.application_amount *ln_exchange_rate
                      * (ln_tax_rate_basis/100),  /*Bug 6363056*/
                  jai_ap_tds_generation_pkg.g_inr_currency_rounding);
        else
          ln_tds_tmp_amt := round(cur_rec.application_amount *ln_exchange_rate
                      * (ln_tax_rate_basis/100),  /*Bug 6363056*/
                  jai_ap_tds_generation_pkg.g_fcy_currency_rounding);
        end if;
        IF trunc(p_creation_date) >=
           trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
          ln_tds_tmp_amt := jai_ap_tds_generation_pkg.get_rnded_value(ln_tds_tmp_amt);
        END IF;
	    -- End for bug 5722028


        update jai_ap_tds_prepayments
        set    tds_application_amount = ln_tds_tmp_amt, -- Bug 5722028
               /*Bug 5751783. Added the update for non-rounded value also*/
               calc_tds_appln_amt = cur_rec.application_amount * ln_exchange_rate * (ln_tax_rate_basis/100)
        where  tds_prepayment_id = cur_rec.tds_prepayment_id;

      end if; /* TDS */

      /* WCT application amount */
      if cur_rec.wct_tax_id_other is not null AND
         cur_rec.wct_tax_id_prepay IS NOT NULL AND -- Bug 6363056
         cur_rec.wct_applicable_flag = 'Y'  -- Bug 6363056
      THEN

        r_ja_in_tax_codes := null;
        open c_ja_in_tax_codes(cur_rec.wct_tax_id_other); -- Bug 6363056
        fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
        close c_ja_in_tax_codes;

        /*Bug 6363056 - Start*/
        ln_tax_rate_basis := r_ja_in_tax_codes.tax_rate;
        ln_si_wct_tax_id := cur_rec.wct_tax_id_other;

        IF cur_rec.wct_tax_id_other <> cur_rec.wct_tax_id_prepay THEN
          r_ja_in_tax_codes_prepay := NULL ;
          OPEN  c_ja_in_tax_codes(cur_rec.wct_tax_id_prepay);
           FETCH  c_ja_in_tax_codes INTO  r_ja_in_tax_codes_prepay;
          CLOSE  c_ja_in_tax_codes;
          IF ln_tax_rate_basis > r_ja_in_tax_codes_prepay.tax_rate THEN
            ln_tax_rate_basis := r_ja_in_tax_codes_prepay.tax_rate;   /* Modified r_ja_in_tax_codes to r_ja_in_tax_codes_prepay for Bug 6972230 */
            ln_si_wct_tax_id := cur_rec.wct_tax_id_prepay; /* Modified wct_tax_id_other to wct_tax_id_prepay for Bug 6972230 */
          END IF ;
        END IF ;
        /*Bug 6363056 - End*/


        /* Bug 5722028. Addd by CSahoo
         * Need to round the value as per the setup.
         */
        ln_tds_tmp_amt := 0;
        if r_gl_sets_of_books.currency_code = p_invoice_currency_code then
          ln_tds_tmp_amt := round(cur_rec.application_amount *ln_exchange_rate
                      * (ln_tax_rate_basis/100), /*Bug 6363056*/
                  jai_ap_tds_generation_pkg.g_inr_currency_rounding);
        else
          ln_tds_tmp_amt := round(cur_rec.application_amount *ln_exchange_rate
                      * (ln_tax_rate_basis/100), /*Bug 6363056*/
                  jai_ap_tds_generation_pkg.g_fcy_currency_rounding);
        end if;

        /* Bug 7280925. Commented by Lakshmi Gopalsami
         * Rounding to 10 is applicable only for TDS.
         * WCT and ESSI should be rounded to Re. 1
         IF trunc(p_creation_date) >=
           trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
          ln_tds_tmp_amt := jai_ap_tds_generation_pkg.get_rnded_value(ln_tds_tmp_amt);
         END IF;
         */
	    -- End for bug 5722028

        update jai_ap_tds_prepayments
        set    wct_application_amount = ln_tds_tmp_amt, -- Bug 5722028
               /*Bug 5751783. Added the update for non-rounded value also*/
               calc_wct_appln_amt = cur_rec.application_amount * ln_exchange_rate * (ln_tax_rate_basis/100)
        where  tds_prepayment_id = cur_rec.tds_prepayment_id;

      end if; /* WCT */

      /* ESSI application amount */
      if cur_rec.essi_tax_id_other is not null AND
         cur_rec.essi_tax_id_prepay IS NOT NULL AND -- Bug 6363056
         cur_rec.essi_applicable_flag = 'Y'  -- Bug 6363056
      THEN

        r_ja_in_tax_codes := null;
        open c_ja_in_tax_codes(cur_rec.essi_tax_id_other); --Bug 6363056
        fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
        close c_ja_in_tax_codes;

        /*Bug 6363056 - Start*/
        ln_tax_rate_basis := r_ja_in_tax_codes.tax_rate;
        ln_si_essi_tax_id := cur_rec.essi_tax_id_other;

        IF cur_rec.essi_tax_id_other <> cur_rec.essi_tax_id_prepay THEN
          r_ja_in_tax_codes_prepay := NULL ;
          OPEN  c_ja_in_tax_codes(cur_rec.essi_tax_id_prepay);
           FETCH  c_ja_in_tax_codes INTO  r_ja_in_tax_codes_prepay;
          CLOSE  c_ja_in_tax_codes;
          IF ln_tax_rate_basis > r_ja_in_tax_codes_prepay.tax_rate THEN
            ln_tax_rate_basis := r_ja_in_tax_codes.tax_rate;
            ln_si_essi_tax_id := cur_rec.wct_tax_id_prepay;
          END IF ;
        END IF ;
        /*Bug 6363056 - End*/

        /* Bug 5722028. Addd by Lakshmi Gopalsami
         * Need to round the value as per the setup.
         */
        ln_tds_tmp_amt := 0;
        if r_gl_sets_of_books.currency_code = p_invoice_currency_code then
          ln_tds_tmp_amt := round(cur_rec.application_amount *ln_exchange_rate
                      * (ln_tax_rate_basis/100),
                  jai_ap_tds_generation_pkg.g_inr_currency_rounding);
        else
          ln_tds_tmp_amt := round(cur_rec.application_amount *ln_exchange_rate
                      * (ln_tax_rate_basis/100),
                  jai_ap_tds_generation_pkg.g_fcy_currency_rounding);
        end if;
        /* Bug 7280925. Commented by Lakshmi Gopalsami
         * Rounding to 10 is applicable only for TDS.
         * WCT and ESSI should be rounded to Re. 1
        IF trunc(p_creation_date) >=
           trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
          ln_tds_tmp_amt := jai_ap_tds_generation_pkg.get_rnded_value(ln_tds_tmp_amt);
        END IF;
        */
        -- End for bug 5722028

        update jai_ap_tds_prepayments
        set    essi_application_amount = ln_tds_tmp_amt, --Bug 5722028
               /*Bug 5751783. Added the update for non-rounded value also*/
               calc_essi_appln_amt = cur_rec.application_amount * ln_exchange_rate * (ln_tax_rate_basis/100)
        where  tds_prepayment_id = cur_rec.tds_prepayment_id;

      end if; /* ESSI */

    end loop;

    open  c_get_total_prepayment_tax(p_invoice_id, p_invoice_distribution_id, ln_exchange_rate);
    fetch c_get_total_prepayment_tax into r_get_total_prepayment_tax;
    close c_get_total_prepayment_tax;

    --Added by Xiao Lv for bug#8345080 on 07-Jan-10, begin

	open c_get_tax_sec_det(p_invoice_id, p_invoice_distribution_id);
    fetch c_get_tax_sec_det into r_get_tax_sec_det;
    close c_get_tax_sec_det;

	if r_get_tax_sec_det.application_amount > 0
	   and (r_get_tax_sec_det.tds_section_code_other is not null or r_get_tax_sec_det.tds_tax_id_other is not null)
	   and r_get_total_prepayment_tax.tds_amount = 0
    then
	   open c_get_grp_details_si_inv_dist(p_invoice_id, r_get_tax_sec_det.invoice_distribution_id);
	   fetch c_get_grp_details_si_inv_dist into ln_si_thgrp_id;
	   close c_get_grp_details_si_inv_dist;

	   jai_ap_tds_generation_pkg.maintain_thhold_grps(
		     p_threshold_grp_id             =>   ln_si_thgrp_id,
		     p_trx_invoice_apply_amount     =>   r_get_tax_sec_det.application_amount,
		     p_tds_event                    =>   'PREPAYMENT APPLICATION',
		     p_invoice_id                   =>   p_invoice_id,
		     p_invoice_distribution_id      =>   p_invoice_distribution_id,
		     p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
		     p_creation_Date                =>   p_creation_date,
		     p_process_flag                 =>   p_process_flag,
		     P_process_message              =>   p_process_message,
		     p_codepath                     =>   p_codepath
           );
    end if; --r_get_tax_sec_det.application_amount > 0

    --Added by Xiao Lv for bug#8345080 on 07-Jan-10, end

    if r_get_total_prepayment_tax.tds_amount > 0 then

     /*  Bug 6363056
      *  Get the details of threshold grp for prepay and invoice.
      *  This determines which group needs to be hit.
      */

      -- Added parameter pre_pay_inv_id by Jia for FP bug6929483,Begin
      ----------------------------------------------------------------------
      --open c_get_prepayment_thgroup(p_prepay_distribution_id,'TDS_SECTION');   --rchandan for bug#4428980
      open c_get_prepayment_thgroup(pre_pay_inv_id,p_prepay_distribution_id,'TDS_SECTION');
      ----------------------------------------------------------------------
      -- Added parameter pre_pay_inv_id by Jia for FP bug6929483,End
      fetch c_get_prepayment_thgroup into ln_pp_thhold_grp_id, ln_prepay_tax_id, ln_threshold_trx_id_prepay;
      close c_get_prepayment_thgroup;

      IF ln_pp_thhold_grp_id IS NULL
         AND (r_get_total_prepayment_tax.tds_amount > 0 OR
              r_get_total_prepayment_tax.wct_amount > 0 OR
              r_get_total_prepayment_tax.essi_amount > 0) THEN
        p_process_flag := 'E';
        P_process_message := 'Threshold group identifier is not found against the prepayment invoice TDS tax, cannot proceed.';
        goto  exit_from_procedure;
      end if;

      OPEN c_get_thgrp_det(ln_pp_thhold_grp_id);
      FETCH c_get_thgrp_det INTO r_pp_jai_ap_tds_thhold_grps;
      CLOSE c_get_thgrp_det;

      FOR get_si_det IN (SELECT jattt.*,
                                jatp.tds_prepayment_id tds_prepayment_id,
                                jatp.application_amount tds_taxable_basis,
                                jatp.invoice_distribution_id tax_dist
                         FROM jai_ap_tds_thhold_trxs jattt,
                              jai_ap_tds_prepayments jatp
                         WHERE jattt.invoice_id = jatp.invoice_id
                         AND jattt.tds_event = 'INVOICE VALIDATE'
                         AND jatp.tds_applicable_flag ='Y'
                         AND invoice_distribution_id_prepay = p_invoice_distribution_id
                         AND jattt.invoice_id = p_invoice_id
                         AND jatp.invoice_distribution_id in
                             (select invoice_distribution_id
                              from jai_ap_tdS_inv_taxes
                              where threshold_trx_id = jattt.threshold_trx_id
                              and invoice_id = p_invoice_id
                              and section_type ='TDS_SECTION'
                             )
                        )
      LOOP

        ln_temp_threshold_grp_id := get_si_det.threshold_grp_id;
        ln_parent_tax_id := get_si_det.tax_id ;

        IF NVL (ln_pp_thhold_grp_id, 0) <> 0 AND
           NVL (ln_temp_threshold_grp_id, 0) <> 0 AND
           NVL (ln_temp_threshold_grp_id,0 ) <> NVL (ln_pp_thhold_grp_id, 0)
        THEN
           OPEN c_get_thgrp_det(ln_temp_threshold_grp_id);
           FETCH c_get_thgrp_det INTO r_si_jai_ap_tds_thhold_grps;
           CLOSE c_get_thgrp_det;
           IF r_pp_jai_ap_tds_thhold_grps.fin_year >  r_si_jai_ap_tds_thhold_grps.fin_year THEN
              ln_temp_threshold_grp_id := ln_pp_thhold_grp_id;
           END IF ;
        END IF ;

        ln_threshold_grp_id := ln_temp_threshold_grp_id;

        --Call to procedure - get_tds_threshold_slab, Store the current Threshold slab and type before PP application
        jai_ap_tds_generation_pkg.get_tds_threshold_slab(
                p_prepay_distribution_id        =>        p_prepay_distribution_id,
                p_threshold_grp_id              =>        ln_temp_threshold_grp_id,
                p_threshold_hdr_id              =>        ln_temp_threshold_hdr_id,
                p_threshold_slab_id             =>        ln_threshold_slab_id,
                p_threshold_type                =>        lv_threshold_type,
                p_process_flag                  =>        p_process_flag,
                p_process_message               =>        p_process_message,
                p_codepath                      =>        p_codepath);

        IF p_process_flag = 'E' THEN
                goto exit_from_procedure;
        END IF;

        if r_get_total_prepayment_tax.tds_amount > 0 THEN
           /* update the threshold with the tds amount that will be impacted because of this application */
           jai_ap_tds_generation_pkg.maintain_thhold_grps
           (
                p_threshold_grp_id             =>   ln_threshold_grp_id,
                p_trx_invoice_apply_amount     =>   get_si_det.tds_taxable_basis,
                p_tds_event                    =>   'PREPAYMENT APPLICATION',
                p_invoice_id                   =>   p_invoice_id,
                p_invoice_distribution_id      =>   p_invoice_distribution_id,
                p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
                p_creation_Date                =>   p_creation_date,
                p_process_flag                 =>   p_process_flag,
                P_process_message              =>   p_process_message,
                p_codepath                     =>   p_codepath
           );

          IF p_process_flag = 'E' THEN
            GOTO  exit_from_procedure;
          END IF;

          -- Update each distribution with the threshold grp id as
          -- it may vary depending on the date and the group.
          update  jai_ap_tds_prepayments
          set     tds_threshold_grp_id = ln_threshold_grp_id
          where   tds_prepayment_id = get_si_det.tds_prepayment_id; -- Bug 6363056

           /* TDS invoice was generated against the Prepayment,
           check for what amount of the SI, TDS invoice was generated */

          /* Bug 6363056
           * Changed from p_invoice_distribution_id to get_si_det.invoice_distribution_id
           * as we need to generate for each line in jai_ap_tds_thhold_thhold_trxs
           */
          open  c_get_amt_tds_inv_generated_si(p_invoice_id, get_si_det.tax_dist);
          fetch c_get_amt_tds_inv_generated_si INTO ln_amt_tds_inv_generated_si, ln_tds_application_amt;
          close c_get_amt_tds_inv_generated_si;

          /*Bug 8431516 - Start*/
          ln_tot_tds_amt := ln_tot_tds_amt + ln_amt_tds_inv_generated_si;
          ln_tot_appln_amt := ln_tot_appln_amt + ln_tds_application_amt;
          if p_event = 'INSERT' then
             update  jai_ap_tds_prepayments
             set     tds_threshold_trx_id_apply = -999
             where   tds_prepayment_id = get_si_det.tds_prepayment_id; --Bug 6031679
          end if;
          /*Bug 8431516 - End*/

          IF  ln_amt_tds_inv_generated_si > 0 THEN
              IF  lv_application_basis = 'STANDARD INVOICE' THEN
                /* get the standard invoice number */
                OPEN   c_si_ap_invoices_all(p_invoice_id);
                FETCH  c_si_ap_invoices_all INTO lv_invoice_num_prepay_apply, ln_parent_invoice_id;
                CLOSE  c_si_ap_invoices_all;
              ELSE
                 /*Bug 8606302 - Start*/
                 /*cursor c_ap_invoices_all would not fetch the Invoice ID if the Prepayment did not
                 suffer TDS when it was validated initially, but only when Threshold was breached
                 In the above case there would be no records in jai_ap_tds_inv_taxes with the distribution
                 ID of the Prepayment Invoice*/
                 get_prepay_invoice_id(p_prepay_distribution_id, ln_parent_invoice_id);
                 OPEN   c_si_ap_invoices_all (ln_parent_invoice_id);
                 FETCH  c_si_ap_invoices_all INTO  lv_invoice_num_prepay_apply, ln_parent_invoice_id;
                 CLOSE  c_si_ap_invoices_all;
                /*Bug 8606302 - End*/
              END  IF ; /* lv_application_basis*/
          end if; /* if ln_amt_tds_inv_generated_si > 0 then */
        end if ;


        --Call to procedure - get_tds_threshold_slab. Store the current Threshold slab and type After PP application
        jai_ap_tds_generation_pkg.get_tds_threshold_slab(
        p_prepay_distribution_id        =>        p_prepay_distribution_id,
        p_threshold_grp_id                =>         ln_temp_threshold_grp_id,
        p_threshold_hdr_id                =>         ln_temp_threshold_hdr_id,
        p_threshold_slab_id                =>         ln_after_threshold_slab_id,
        p_threshold_type                =>         lv_after_threshold_type,
        p_process_flag                  =>         p_process_flag,
        p_process_message               =>         p_process_message,
        p_codepath                        =>         p_codepath);

        IF p_process_flag = 'E' THEN
                goto exit_from_procedure;
        END IF;

      END LOOP ; /* get_si_det */
     end if; /* if r_get_total_prepayment_tax.tds_amount > 0 then */    --moved this statement from above to here for Bug 6972230

     /*Bug 8431516 - Start*/
     IF  ln_tot_tds_amt > 0 THEN
         IF  lv_application_basis = 'STANDARD INVOICE' THEN
             /* get the standard invoice number */
             OPEN   c_si_ap_invoices_all(p_invoice_id);
             FETCH  c_si_ap_invoices_all INTO  lv_invoice_num_prepay_apply, ln_parent_invoice_id;
             CLOSE  c_si_ap_invoices_all;
         ELSE
             /*Bug 8606302 - Start*/
             /*cursor c_ap_invoices_all would not fetch the Invoice ID if the Prepayment did not
             suffer TDS when it was validated initially, but only when Threshold was breached
             In the above case there would be no records in jai_ap_tds_inv_taxes with the distribution
             ID of the Prepayment Invoice*/
             get_prepay_invoice_id(p_prepay_distribution_id, ln_parent_invoice_id);
             OPEN   c_si_ap_invoices_all (ln_parent_invoice_id);
             FETCH  c_si_ap_invoices_all INTO  lv_invoice_num_prepay_apply, ln_parent_invoice_id;
             CLOSE  c_si_ap_invoices_all;
             /*Bug 8606302 - End*/
         END  IF ; /* lv_application_basis*/

         fnd_file.put_line(FND_FILE.log, ' value of dist id '|| p_invoice_distribution_id);
         fnd_file.put_line(FND_FILE.log, ' value of prepay dist id '|| p_prepay_distribution_id);
         fnd_file.put_line(FND_FILE.log, ' value of invoice id '|| ln_parent_invoice_id);
         fnd_file.put_line(FND_FILE.log, ' value of invoice num '||lv_invoice_num_prepay_apply);

         if p_event = 'INSERT' then  /*Bug 8431516*/
               /*Bug 5751783. Changed from invoice_id to ln_parent_invoice_id*/
               jai_ap_tds_generation_pkg.generate_tds_invoices
               (
                 pn_invoice_id               =>      ln_parent_invoice_id,
                 pn_invoice_distribution_id  =>      p_invoice_distribution_id,
                 pv_invoice_num_prepay_apply =>      lv_invoice_num_prepay_apply,
                 pn_taxable_amount           =>      ln_tot_appln_amt, /*Bug 6363056*/
                 pn_tax_amount               =>      ln_tot_tds_amt,
                 pn_tax_id                   =>      ln_parent_tax_id,
                 pd_accounting_date          =>      p_accounting_date,
                 pv_tds_event                =>      'PREPAYMENT APPLICATION',
                 pn_threshold_grp_id         =>      ln_threshold_grp_id,
                 pv_tds_invoice_num          =>      lv_invoice_to_tds_num,
                 pv_cm_invoice_num           =>      lv_invoice_to_vendor_num,
                 pn_threshold_trx_id         =>      ln_threshold_trx_id_tds,
                 pd_creation_date           =>       p_creation_date, -- Bug 5722028. Added by Lakshmi Gopalsami
                 p_process_flag              =>      p_process_flag,
                 p_process_message           =>      p_process_message
                );

                IF p_process_flag = 'E' THEN
                 GOTO  exit_from_procedure;
                END  IF ;

                 /* prepayment apply scenario for backward compatibility*/

                IF  ln_start_threshold_trx_id is null THEN
                   ln_start_threshold_trx_id := ln_threshold_trx_id_tds;
                END  IF ;

                /* Update the threshold group */
                jai_ap_tds_generation_pkg.maintain_thhold_grps
                ( p_threshold_grp_id             =>   ln_threshold_grp_id,
                  p_trx_tax_paid                 =>   (-1 * ln_tot_tds_amt),
                  p_tds_event                    =>   'PREPAYMENT APPLICATION',
                  p_invoice_id                   =>   p_invoice_id,
                  p_invoice_distribution_id      =>   p_invoice_distribution_id,
                  p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
                  p_creation_date                =>   p_creation_date,
                  p_process_flag                 =>   p_process_flag,
                  P_process_message              =>   p_process_message,
                  p_codepath                     =>   p_codepath
                 );

                --Added by Sanjikum for Bug#4722011
                IF p_process_flag = 'E' THEN
                    GOTO  exit_from_procedure;
                END IF;

                /* Update jai_ap_tds_prepayments with threshold_trx_id_apply*/
                -- Update each distribution with the threshold grp id as
                -- it may vary depending on the date and the group.
                -- changed invoice_distribution_id_prepay to invoice_distribution_id.
                update  jai_ap_tds_prepayments
                set     tds_threshold_trx_id_apply = ln_threshold_trx_id_tds
                where   tds_threshold_trx_id_apply = -999
                and invoice_id = p_invoice_id
                and invoice_distribution_id_prepay = p_invoice_distribution_id; /*Bug 6363056*/

                if p_event = 'INSERT' then           --Added for Bug 8431516
                    /* Bug 5751783
                     * Changed from p_invoice_id to ln_parent_invoice_id
                     * Parent invoice_id should be depending on the TDS invoice
                     * created.
                     */
                    jai_ap_tds_generation_pkg.process_threshold_rollback
                    ( p_invoice_id                   =>        ln_parent_invoice_id,
                      p_before_threshold_type        =>        lv_threshold_type,
                      p_after_threshold_type         =>        lv_after_threshold_type,
                      p_before_threshold_slab_id     =>        ln_threshold_slab_id,
                      p_after_threshold_slab_id      =>        ln_after_threshold_slab_id,
                      p_threshold_grp_id             =>        ln_temp_threshold_grp_id,
                      p_org_id                       =>        p_org_id,
                      p_accounting_date              =>        p_accounting_date,
                      p_invoice_distribution_id      =>        p_invoice_distribution_id,
                      p_prepay_distribution_id       =>        p_prepay_distribution_id,
                      p_process_flag                 =>        p_process_flag,
                      p_process_message              =>        p_process_message,
                      p_codepath                     =>        p_codepath);

                    IF p_process_flag = 'E' THEN
                       goto exit_from_procedure;
                    END IF;
                end if; /*if p_event = 'INSERT' then*/  --Added for Bug 8431516

          end if; /*if p_event = 'INSERT' then*/  --Added for Bug 8431516
     end if ; /* IF  ln_tot_tds_amt > 0 THEN */
    /*Bug 8431516 - End*/

    /* prepayment apply scenario for backward compatibility*/
    update  JAI_AP_TDS_INVOICES
    set     amt_reversed = nvl(amt_reversed, 0) + r_get_total_prepayment_tax.tds_amount,
            amt_applied  = nvl(amt_applied, 0)  + abs(p_prepay_amount)
    where   invoice_id = p_invoice_id;

    -- End for bug 6363056.

    if r_get_total_prepayment_tax.wct_amount > 0  then
        /* get the tax_id */
        ln_pp_section_tax_id := null;
        ln_parent_invoice_id := null;

        /*Bug 6363056*/
        if lv_application_basis = 'STANDARD INVOICE' then
           /* get the standard invoice number */
           ln_parent_invoice_id := p_invoice_id;
        else
           /* Get the prepayment number */
           open  c_get_pp_section_tax_id(p_prepay_distribution_id, 'WCT_SECTION');
           fetch c_get_pp_section_tax_id into ln_pp_section_tax_id, ln_parent_invoice_id;
           close c_get_pp_section_tax_id;
        end if;

        /*Bug 6363056*/
        IF nvl(ln_pp_section_tax_id,-1) <> ln_si_wct_tax_id THEN
           ln_pp_section_tax_id := ln_si_wct_tax_id;
        END IF ;

        if p_event = 'INSERT' then      --Added for Bug 8431516
              /*Bug 5751783 - Changed from p_invoice_id to ln_pp_section_invoice_id*/
              jai_ap_tds_generation_pkg.generate_tds_invoices
              (
                pn_invoice_id              =>      ln_parent_invoice_id                           ,
                pn_invoice_distribution_id =>      p_invoice_distribution_id                      ,
                pn_taxable_amount          =>      r_get_total_prepayment_tax.wct_taxable_basis   ,
                pn_tax_amount              =>      r_get_total_prepayment_tax.wct_amount          ,
                pn_tax_id                  =>      ln_pp_section_tax_id                           ,
                pd_accounting_date         =>      p_accounting_date                              ,
                pv_tds_event               =>      'PREPAYMENT APPLICATION'                       ,
                pn_threshold_grp_id        =>      null                                           ,
                pv_tds_invoice_num         =>      lv_invoice_to_tds_num                          ,
                pv_cm_invoice_num          =>      lv_invoice_to_vendor_num                       ,
                pn_threshold_trx_id        =>      ln_threshold_trx_id_wct                        ,
                pd_creation_date           =>      p_creation_date                                ,
                p_process_flag             =>      p_process_flag                                 ,
                p_process_message          =>      p_process_message
              );

              if  p_process_flag = 'E' then
                goto exit_from_procedure;
              end if;

              update jai_ap_tds_prepayments
              set    wct_threshold_trx_id_apply = ln_threshold_trx_id_wct
              where  invoice_id = p_invoice_id
              and    invoice_distribution_id_prepay = p_invoice_distribution_id
              and    wct_applicable_flag = 'Y';

              if ln_start_threshold_trx_id is null then
                ln_start_threshold_trx_id := ln_threshold_trx_id_wct;
              end if;
        end if; /*if p_event = 'INSERT' then*/    --Added for Bug 8431516
        /* Generate the return invoices */
    end if; /* if r_get_total_prepayment_tax.wct_amount > 0  then */


    if r_get_total_prepayment_tax.essi_amount > 0 then
        /* get the tax_id */
        ln_pp_section_tax_id := null;
        ln_parent_invoice_id := null;
        /*Bug 6363056*/
        if lv_application_basis = 'STANDARD INVOICE' then
           /* get the standard invoice number */
           ln_parent_invoice_id := p_invoice_id;
        else
           /* Get the prepayment number */
           open  c_get_pp_section_tax_id(p_prepay_distribution_id, 'WCT_SECTION');
           fetch c_get_pp_section_tax_id into ln_pp_section_tax_id, ln_parent_invoice_id;
           close c_get_pp_section_tax_id;
        end if;

        /*Bug 6363056*/
        IF nvl(ln_pp_section_tax_id,-1) <> ln_si_essi_tax_id THEN
           ln_pp_section_tax_id := ln_si_essi_tax_id;
        END IF ;

        IF p_event = 'INSERT' then    --Added for Bug 8431516
              /*Bug 5751783 - Changed from p_invoice_id to ln_pp_section_invoice_id*/
              jai_ap_tds_generation_pkg.generate_tds_invoices
              (
                pn_invoice_id              =>      ln_parent_invoice_id                           ,
                pn_invoice_distribution_id =>      p_invoice_distribution_id                      ,
                pn_taxable_amount          =>      r_get_total_prepayment_tax.essi_taxable_basis  ,
                pn_tax_amount              =>      r_get_total_prepayment_tax.essi_amount         ,
                pn_tax_id                  =>      ln_pp_section_tax_id                           ,
                pd_accounting_date         =>      p_accounting_date                              ,
                pv_tds_event               =>      'PREPAYMENT APPLICATION'                       ,
                pn_threshold_grp_id        =>      null                                           ,
                pv_tds_invoice_num         =>      lv_invoice_to_tds_num                          ,
                pv_cm_invoice_num          =>      lv_invoice_to_vendor_num                       ,
                pn_threshold_trx_id        =>      ln_threshold_trx_id_essi                       ,
                pd_creation_date           =>      p_creation_date                                ,
                p_process_flag             =>      p_process_flag                                 ,
                p_process_message          =>      p_process_message
              );

              if  p_process_flag = 'E' then
                goto exit_from_procedure;
              end if;

              update jai_ap_tds_prepayments
              set    essi_threshold_trx_id_apply = ln_threshold_trx_id_essi
              where  invoice_id = p_invoice_id
              and    invoice_distribution_id_prepay = p_invoice_distribution_id
              and    essi_applicable_flag = 'Y';

              if ln_start_threshold_trx_id is null then
                ln_start_threshold_trx_id := ln_threshold_trx_id_essi;
              end if;
        end if; /*IF p_event = 'INSERT' then*/   --Added for Bug 8431516
    end if; /* if r_get_total_prepayment_tax.essi_amount > 0 then */

    if ln_start_threshold_trx_id is not null then
        /*Bug - 9826422
        Records are inserted into AP Interface tables using Standard Invoice, but import_and_approve
        was called using the Prepayment Invoice ID. Hence wrong group_id was getting passed and no
        Invoices were getting improved*/
        jai_ap_tds_generation_pkg.import_and_approve
        (
          p_invoice_id                   =>     ln_parent_invoice_id,
          p_start_thhold_trx_id          =>     ln_start_threshold_trx_id,
          p_tds_event                    =>     'PREPAYMENT APPLICATION',
          p_process_flag                 =>     p_process_flag,
          p_process_message              =>     p_process_message
        );

    end if;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(100, p_codepath, null, 'END'); /* 100 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'jai_ap_tds_prepayemnts_pkg.process_tds_invoices :' ||  sqlerrm;
      return;
  end process_tds_invoices;

/***********************************************************************************************/

/* **************************************** process_old_transaction **************************************** */

  procedure process_old_transaction
  (
    p_invoice_id                          in                  number,
    p_invoice_distribution_id             in                  number,
    p_prepay_distribution_id              in                  number,
    p_amount                              in                  number,
    p_last_updated_by                     in                  number,
    p_last_update_date                    in                  date,
    p_created_by                          in                  number,
    p_creation_date                       in                  date,
    p_org_id                              in                  number,
    p_process_flag                        out   nocopy         varchar2,
    p_process_message                     out   nocopy         varchar2
  )
  is

    cursor   c_tds_count(p_invoice_id  number, p_source_attribute varchar2) is
      select count(1)
      from   JAI_AP_TDS_INVOICES
      where  invoice_id = p_invoice_id
      and    source_attribute = p_source_attribute;

    /* Following cursor definition has been changed to cater for the obsoletion of table ja_in_ap_tds_inv_temp */
    cursor   c_tds_count_unapp(p_invoice_id  number, p_section_type varchar2) IS   --rchandan for bug#4428980
      select count(1)
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    section_type = p_section_type;   --rchandan for bug#4428980

   ln_tds_count_attribute1      number;
   ln_tds_count_attribute2      number;
   ln_tds_count_attribute3      number;
   lb_result                    boolean;
   ln_req_id                    number;

  begin
    /* This code is to replace the following three triggers of the old tds regime
    1. ja_in_prepay_insert_trg
    2. ja_in_prepay_insert_wct_trg
    3. ja_in_prepay_insert_wct1_trg
    */

    open c_tds_count(p_invoice_id, 'ATTRIBUTE1');
    fetch c_tds_count into ln_tds_count_attribute1;
    close c_tds_count;

    if ln_tds_count_attribute1 = 0 then
      -- the standard invoice does not have tds attached to it.
      -- check if there is TDS record in temp table, this would happen when the invoice is unapproved.
      -- Bug 4754213. Added by Lakshmi Gopalsami
      open c_tds_count_unapp(p_invoice_id, 'TDS_SECTION');   --rchandan for bug#4428980
      fetch c_tds_count_unapp into ln_tds_count_attribute1;
      close c_tds_count_unapp;

      ln_tds_count_attribute1 := nvl(ln_tds_count_attribute1, 0);

      if ln_tds_count_attribute1 = 0 then
        goto attribut2_processing;
      end if;

    end if;


    if p_amount < 0  then /* Case of Apply */

      lb_result := fnd_request.set_mode(TRUE);
      ln_req_id :=
      fnd_request.submit_request
      (
        'JA',
        'JAINPREP',
        'To Insert Prepayment Distributions',
        '',
        FALSE,
        p_invoice_id,
        p_invoice_distribution_id,
        abs(p_amount),
        p_last_updated_by,
        p_last_update_date,
        p_created_by ,
        p_creation_date,
        p_org_id,
        p_prepay_distribution_id,
        'I',
        'ATTRIBUTE1'
      );

    elsif p_amount > 0 then

      lb_result := fnd_request.set_mode(TRUE);
      ln_req_id :=
      fnd_request.submit_request
      (
        'JA',
        'JAINUNPR',
        'To Unapply Prepayment Distributions',
        '',
        FALSE,
        p_invoice_id,
        p_last_updated_by,
        p_last_update_date,
        p_created_by ,
        p_creation_date,
        p_org_id,
        p_prepay_distribution_id,
        p_invoice_distribution_id,
        'ATTRIBUTE1'
      );

    end if;

    /* Check for WCT tax */
    << attribut2_processing >>
    open c_tds_count(p_invoice_id, 'ATTRIBUTE2');
    fetch c_tds_count into ln_tds_count_attribute2;
    close c_tds_count;

    if ln_tds_count_attribute2 = 0 then
      -- the standard invoice does not have tds attached to it.
      -- check if there is TDS record in temp table, this would happen when the invoice is unapproved.
      open c_tds_count_unapp(p_invoice_id, 'WCT_SECTION');
      fetch c_tds_count_unapp into ln_tds_count_attribute2;
      close c_tds_count_unapp;

      ln_tds_count_attribute2 := nvl(ln_tds_count_attribute2, 0);

      if ln_tds_count_attribute2 = 0 then
        goto attribut3_processing;
      end if;

    end if;


    if p_amount < 0  then /* Case of Apply */

      lb_result := fnd_request.set_mode(TRUE);
      ln_req_id :=
      fnd_request.submit_request
      (
        'JA',
        'JAINPREP',
        'To Insert Prepayment Distributions',
        '',
        FALSE,
        p_invoice_id,
        p_invoice_distribution_id,
        abs(p_amount),
        p_last_updated_by,
        p_last_update_date,
        p_created_by ,
        p_creation_date,
        p_org_id,
        p_prepay_distribution_id,
        'I',
        'ATTRIBUTE2'
      );

    elsif p_amount > 0 then

      lb_result := fnd_request.set_mode(TRUE);
      ln_req_id :=
      fnd_request.submit_request
      (
        'JA',
        'JAINUNPR',
        'To Unapply Prepayment Distributions',
        '',
        FALSE,
        p_invoice_id,
        p_last_updated_by,
        p_last_update_date,
        p_created_by ,
        p_creation_date,
        p_org_id,
        p_prepay_distribution_id,
        p_invoice_distribution_id,
        'ATTRIBUTE2'
      );

    end if;

    /* Check for ESSI Tax */
    << attribut3_processing >>
    open c_tds_count(p_invoice_id, 'ATTRIBUTE3');
    fetch c_tds_count into ln_tds_count_attribute3;
    close c_tds_count;

    if ln_tds_count_attribute3 = 0 then
      -- the standard invoice does not have tds attached to it.
      -- check if there is TDS record in temp table, this would happen when the invoice is unapproved.
      open c_tds_count_unapp(p_invoice_id, 'ESSI_SECTION');
      fetch c_tds_count_unapp into ln_tds_count_attribute3;
      close c_tds_count_unapp;

      ln_tds_count_attribute3 := nvl(ln_tds_count_attribute3, 0);

      if ln_tds_count_attribute3 = 0 then
        goto exit_from_procedure;
      end if;

    end if;


    if p_amount < 0  then /* Case of Apply */

      lb_result := fnd_request.set_mode(TRUE);
      ln_req_id :=
      fnd_request.submit_request
      (
        'JA',
        'JAINPREP',
        'To Insert Prepayment Distributions',
        '',
        FALSE,
        p_invoice_id,
        p_invoice_distribution_id,
        abs(p_amount),
        p_last_updated_by,
        p_last_update_date,
        p_created_by ,
        p_creation_date,
        p_org_id,
        p_prepay_distribution_id,
        'I',
        'ATTRIBUTE3'
      );

    elsif p_amount > 0 then

      lb_result := fnd_request.set_mode(TRUE);
      ln_req_id :=
      fnd_request.submit_request
      (
        'JA',
        'JAINUNPR',
        'To Unapply Prepayment Distributions',
        '',
        FALSE,
        p_invoice_id,
        p_last_updated_by,
        p_last_update_date,
        p_created_by ,
        p_creation_date,
        p_org_id,
        p_prepay_distribution_id,
        p_invoice_distribution_id,
        'ATTRIBUTE3'
      );

    end if;

    << exit_from_procedure >>
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'jai_ap_tds_prepayemnts_pkg.process_old_transaction :' ||  sqlerrm;
      return;
  end process_old_transaction;

/* **************************************** process_old_transaction **************************************** */

end jai_ap_tds_prepayments_pkg;

/
