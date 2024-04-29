--------------------------------------------------------
--  DDL for Package Body JAI_AP_TDS_GENERATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TDS_GENERATION_PKG" 
/* $Header: jai_ap_tds_gen.plb 120.26.12010000.30 2010/02/12 03:38:29 bgowrava ship $ */
AS
/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_gen.plb

 Created By    : Aparajita

 Created Date  : 24-dec-2004

 Bug           :

 Purpose       : Implementation of tax defaultation functionality on AP invoice.

 Called from   : Trigger ja_in_ap_aia_after_trg
                 Trigger ja_in_ap_aida_after_trg

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.       24/12/2004   Aparajita for bug#4088186. version#115.0. TDS Clean Up.
                        Created this package for implementing the tax defaultation
                        functionality onto AP invoice.

 2.       11/05/2005   rchandan for bug#4333449. Version 116.1
                        A new procedure to insert into jai_ap_tds_thhold_trxs table is added.

                        India Original Invoice for TDS DFF is eliminated. So attribute1 of ap_invoices_al
                        is not populated whenever an invoice is generated. Instead the Invoice details are
                        populated into jai_ap_tds_thhold_trxs. So whenever data is inserted into interface
                        tables the jai_ap_tds_thhold_trxs table is also populated.

3.        11/05/2005   rchandan for bug#4323338. Version 116.2
                        India Org Info DFF is eliminated as a part of JA migration. A table by name JAI_AP_TDS_ORG_TANS is dropped
                        and a view jai_ap_tds_org_tan_v is created to retrieve the PAN NO.

4.        24/05/2005   Ramananda for bug#4388958 File Version: 116.1
                         Changed AP Lookup code from 'TDS' to 'INDIA TDS'

5.        02/06/2005   Ramananda for bug#  4407184 File Version: 116.2
                         SQL Bind variable compliance is done

6.        08-Jun-2005  File Version 116.3. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                       as required for CASE COMPLAINCE.

7.        14-Jun-2005  rchandan for bug#4428980, Version 116.4
                         Modified the object to remove literals from DML statements and CURSORS.

8.        08-Jul-2005  Sanjikum for Bug#4482462
                        1) In the procedure - generate_tds_invoices, removed the column payment_method_lookup_code
                           from cursors - c_po_vendor_sites_all, c_po_vendors
                        2) In the procedure generate_tds_invoices, commented the if condition of payment_method_lookup_code
                        3) In the procedure generate_tds_invoices, commented the value of parameter - p_payment_method_lookup_code
                           while calling procedure - jai_ap_utils_pkg.insert_ap_inv_interface

                       Ramananda for bug#  4407184
                         Re-Done: SQL Bind variable compliance is done

9.        29-Jun-2005  ssumaith - bug#4448789 - removal of hr_operating_units.legal_entity_id from this trigger.

10.       14-Jul-2005  rchandan for bug#4487676.File version 117.2
                        Sequnece jai_ap_tds_invoice_num_s is renamed to JAI_AP_TDS_THHOLD_TRXS_S1

11.       25-Jul-2005  Bug4513458. added by Lakshmi Gopalsami version 120.2
                        Issue:
                        ------
                        TDS tax is always rounded to 2 decimal places
                        Fix:
                        ----
                         1) Changed the statement "ln_tax_amount :=
                            round(pn_tax_amount, 2);"
                            to "ln_tax_amount := pn_tax_amount;"
                         2) Before creating the invoice for TDS authority,
                            added the following condition -
                           "ln_invoice_to_tds_amount :=
                            ROUND(ln_invoice_to_tds_amount,0);"
                         3) In the IF of Supplier Invoice section, added the
                           following condition
                          "ELSE
                           ln_invoice_to_vendor_amount := round(
                           ln_invoice_to_vendor_amount, 0);"

12.       28-Jul-2005  Bug4522507. Added by Lakshmi Gopalsami Version 120.3
                        1) In the Procedure generate_tds_invoices,
                           changed the condition -
                           if ln_tax_amount <= 0 then to
                           if ROUND(ln_tax_amount,2) <= 0 then

                        Dependency(Functional)
                        -----------------------
                        jai_ap_tds_ppay.plb

13.       29-Jul-2005  Bug4522540. Added by Lakshmi Gopalsami Version 120.4
                        Start date and end date of a threshold type was not
                        being considered while selecting the applicable
                        threshold. This has been modified to check
                        threshold validity date range against the GL_date of
                        invoice distributions.

                        Dependency (Functional)
                        -----------------------
                        jai_ap_tds_dflt.plb Version  120.3

14.       18-Aug-2005  Ramananda for bug#4560109 during R12 Sanity Testing. File Verion 120.5
                         In generate_tds_invoices procedure:
                         Added the WHO columns in the 'insert into JAI_AP_TDS_INVOICES' statement

15.       19-Aug-2005  Ramananda for bug#4562793. File Version 120.6
                        1) Moved the Cursor - c_ja_in_tax_codes, up from below the cursor c_po_vendor_sites_all
                        2) Changed the parameters being passed to cursor - c_po_vendors and c_po_vendor_sites_all
                        3) In the procedure maintain_thhold_grps, while updating the table - jai_ap_tds_thhold_grps,
                           changed the update for column - current_threshold_slab_id

                        Dependency Due to this Bug
                        --------------------------
                        No

16.       19-Aug-2005  Ramananda for bug#4562801. File Version 120.6
                        Following changes are done in procedure - generate_tds_invoices
                        1) While inserting into table ja_in_ap_tds_invoices, value of column - invoice_amount is changed
                        2) Calculation for the new added variable - ln_invoice_amount is done

17.       23-Aug-2005  Bug 4559756. Added by Lakshmi Gopalsami Version 120.7
                       Added org_id in call to ap_utilities_pkg to get the correct gl_date and period_name.

18.       02-Sep-2005  Ramananda for Bug#4584221, File Version 120.8
                       Made the following changes -
                       1) Before submitting the request - APXIIMPT,
                          called the jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id) to get the batch_name.
                       2) In submitting the request - APXIIMPT,
                          changed the parameter batch_name from hardcoded value to variable - lv_batch_name

                       Dependency Due to this Bug (Functional)
                       --------------------------
                        jai_ap_utils.pls   (120.2)
                        jai_ap_utils.plb   (120.2)
                        jai_ap_tds_old.plb (120.3)
                        jai_constants.pls  (120.3)
                        jaiorgdffsetup.sql (120.2)
                         jaivmlu.ldt  (120.3)

19.       02-sep-2005   Bug 4774647. Added by Lakshmi Gopalsami version 120.9
                               Passed operating unit also as this parameter
             has been added by base.

20.       07-Dec-2005   Bug 4870243. Added by Harshita version 120.11
          Issue : Invoice Distribution Cursor has no filter based on the Invoice_distribution_id ,
                  line_num and tds_section.
          Fix :   Added the filter conditions in the filter.

21.       13-Jan-2006   Bug 4943949 Added by Lakshmi Gopalsami 120.13
                        Issue:
      ------
        Wrong number of arguments while trying to validate
      the standard invoice. This is due to the parameter
      P_FUNDS_RETURN_CODE added by base in ap_approval_pkg.

      Fix:
      ----
        Added the parameter P_FUNDS_RETURN_CODE in call to
            ap_approval_pkg.
22.   19-Jan-2006   avallabh for bug 4926736. File version 120.14
      Removed the procedure process_tds_batch, since it is no longer used.

23.   27/03/2006    Hjujjuru for Bug 5096787 , File Version 120.15
                   Spec changes have been made in this file as a part og Bug 5096787.
                   Now, the r12 Procedure/Function specs is in this file are in
                   sync with their corrsponding 11i counterparts

24.   03/11/2006   Sanjikum for Bug#5131075, File Version 120.17
                   1) Changes are done for forward porting of bugs - 4722011, 4718907, 4685754, 5346558

                   Dependency Due to this Bug
                   --------------------------
                   Yes, as Package spec is changed and there are multiple files changed as part of current
25    23/02/07   bduvarag for bug#4716884,File version 120.18
                Forward porting the changes done in 11i bug 4629783
		bduvarag for bug#4667681,File version 120.18
		Forward porting the changes done in 11i bug 4576084


26. 03/05/2007   Bug 5722028. Added by csahoo 120.19
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

		  Depedencies:
			=============
			jai_ap_tds_gen.pls - 120.5
			jai_ap_tds_gen.plb - 120.19
			jai_ap_tds_ppay.pls - 120.2
			jai_ap_tds_ppay.plb - 120.5
			jai_ap_tds_can.plb - 120.6

27.  22/06/2007  Bug# 6119216, File Version 120.20
                 Issue:  RTN DOCS ARE NOT GENERATED ON APPLICATION OF PREPAYMENT INVOICE
                 Fix:
                 1.  Changed where clause of the cursor c_check_not_validate.
                 2.  Changed import_and_approve procedure, here a call to fnd_request.submit_request was passing
                     p_invoice_id instead of lv_group_id

28. 11/01/2008 Changes done by nprashar for bug # 6720018.
                         Issue# APAC:PEN:R12:INDIA LOCALIZATION VALIDATING FUNCTION OF TDS INVOICE NOT WORKING.

29.   18/11/2008  Bgowrava  for Bug#4549019,  File Version 120.16.12000000.12, 120.26.12010000.4,  120.31
                        Changes done in procedure - generate_tds_invoices
                        1) Changed the condition - if lv_invoice_to_tds_num is not null and lv_invoice_to_tds_type is not null then
                        2) Added an if condition before calling - jai_ap_interface_pkg.insert_ap_inv_interface for Supplier invoice

30.  26-Nov-2008    Bgowrava for Bug#7389849, File Version 120.16.12000000.13, 120.26.12010000.5,  120.32
                                      modified code to check the enddate of a tax with the invoice date of an invoice rather than sysdate

31.   02-Mar-2009    Bgowrava for Bug#8254510, file Version 120.16.12000000.15, 120.26.12010000.7,  120.34
                                    Modified the code in the procedure process_threshold_transition to avoid calculating the TDS for
			    difference in the rate between the rate at which an invoice has suffered earlier and the rate applicable
			   at the current threshold transition. Also Added code to this procedure to calculate surcharge amount for
			   all previous invoices in the threshold group when the threshold with hte surcharge applicability is
			   breached. A TDS invoice with the namin convention of -SUR- is created for the surcharge invoice.

32.  19-May-2009   Bgowrava for Bug#8459564, File Version 120.16.12000000.17, 120.26.12010000.9, 120.36
                                  Issue: INDIA - TDS CERTIFICATES REPORT DOES NOT DISPLAY CORRECT AMOUNT
			  Fix: Modified the code in the process_threshold_transition procedure to pass the calculated taxable amount
			  for the additional TDS invoice pair created post threshold transition  to the generate_tds_invoices procedure instead of just passing null.

33. 20-Aug-2009   Bgowrava for Bug#8716477, File Version 120.16.12000000.21, 120.26.12010000.13, 120.40
                                 Issue: TDS CR MEMO and INVOICE NOT GENERATED FOR INVOICE HAVING MORE THAN 1000 LINES
                                 Fix: The issue was occuring due to the length of the p_codepath exceeding the maximum length of 1996 and hence the procedure failing due to
			         numeric or value error. Hence commented the line where codepath was assigned with data without calling the funtion jai_general_pkg.plot_codepath.
			        also added exception details in the exception block of process_tds_at_inv_validate procedure.

34. 14-Oct-2009    Bgowrava for Bug# 8995604  , File version 120.16.12000000.22, 120.26.12010000.14, 120.41
                                 Issue:  CREDIT MEMO INCORRECTLY TRANSLATED FOR FOREIGN CURRENCY TDS INV
			 Fix :  Avoided calling the get_rnded_value function for the vendor credit memo in case of foreign currency. also took care to convert hte INR value of tax to
			           foreign currency only after the rounding is completed for the INR tax amount by calling the get_rnded_value function.

35.  09-Dec-2009  Bgowrava for Bug#9186263, File version 120.16.12000000.24, 120.26.12010000.16, 120.43
                                 Issue : INVOICE DATE ON RTN STANDARD INVOICE SHOULD BE GL DATE OF PREPAYMENT APPLICATION
			Fix : Modified the value passed to the parameter invoice_date to ld_acoounting_date instead of the invoice date of the base invoice.


36. 13-Jan-2010  Xiao for Bug#7154864
                 the following changes were made for this issue.
                 1) The cursor c_calculate_tax is modified to retreive default_tax_id also.
                 2) The cursor c_check_slabs_end_dated is included again. this was earlier moved
                    to the trigger through the bug5925513.
                 3) modified c_get_taxes_to_generate_tds to retrieve default tax id when actual_tax_id
                    null.
                 4) modified cursor c_get_taxes_to_generate_tds to consider invoices which have a
                    actual_tax_id defined for generating TDS.
                 5) Uncommented the code responsible for throwing error when the invoice with an
                    enddated tax attached is validated
37. 13-Jan-2010  Xiao for Bug#6596019
                 The following changes are done as per this bug
                 1) modified c_for_each_tds_section to consider the invoice amount after deducting the
                    prepayment amount.
                 2) modified c_get_taxes_to_generate_tds to consider the taxable_amount after
                    deducting the prepayment amount.
                 3) Added new cursor to obtain the prepayment amount applied for a particular invoice.
                 4) Added new cursors c_jai_ap_no_tds_trx and c_jai_no_tds_trx_amt to calculate the
                    TDS only on invoices which have not suffered TDS and ignore those which have already
                    suffered TDS, on reaching cumulative limit.

38. 13-Jan-2010  Xiao for Bug#6596019
                 the code to throw an error when there is no active threshold defined for a
                 section code and the code to throw error when there are no active slabs available
                 for a particular threshold, are moved to the begining of the procedure process_tds_at_inv_validate
                 since it was not getting executed when iside the loop, due to certain conditions not getting satisfied.


40. 13-Jan-2010  Xiao for Bug#6596019
                               Added code for surcharge in the procedure process_threshold_transition
                                also added code for creating surcharge invoices when even is SURCHARGE_CALCULATE
                                in generate_tds_invoices procedure. also resolved the regression created due to earlier
                                 fixes.

41.  13-Jan-2010 Xiao Lv for Bug#8345080, related 11i bug#8333898
                               Issue: TDS DEDUCTING TWICE
                                 Fix: Added a new procedure get_prepay_appln_amt with PRAGMA AUTONOMOUS TRANSACTION to calculate
                                      the application amount for invoices within the current group which are eligible for TDS
                                      deduction at threshold transition. and this application amount is deducted from the total
                                      amount while calculating the threshold transition amount.

42. 13-Jan-2010  Xiao Lv For Bug#8485691, related 11i bug#8439217
                               Issue: TDS CALCULATION AT APPLICABLE RATES DURING THRESHOLD TRANSITION
                                 Fix: Modified the code in the procedure process_threshold_transition in the file jai_ap_tds_gen.plb,
                                      to calculate the tax based on the rate applicable on the invoice which had not suffered TDS
                                      earlier.

43. 13-Jan-2010  Xiao Lv For Bug#8513550, related 11i bug#8439276
                               Issue: ADDITIONAL TDS INV GETTING GENERATED FOR APPLIED PREPAY INV AT THRESHOLD
                                 Fix: Modified the code in the process_threshold_transition procedure in jai_ap_tds_gen.plb. Here
                                      added code to call the get_prepay_appln_amt function even for the invoice which is causing
                                      the threshold transition to detect if any prepayment is attached to this invoice which should
                                      be ignored while calculation of the transition TDS.


44. 14-Jan-2010  Jia For Bug#7431371, related 11i bug#7419533
             Issue: FINANCIALS FOR INDIA -TDS NOT WORKING IN CASE OF MULTIPLE DISTRIBUTIONS
             Fixed:
                1) Modified the code in process get_prepay_invoice_amt.
                  Handled the case where a prepayment that is getting applied on the standard invoice had a 0% TDS
                  tax atttached, in which case the TDS on the standard invoice should deduct TDS on difference of
                  std invoice amount and prepayment invoice amount.
                2) Modified the code in process process_tds_at_inv_validate.
                  Added code in process_tds_at_inv_validate to apply the prepayment amount increamently
                  in all the distribution lines, till there is sufficient amount left in prepayment to be applied.
                  Once the prepayment amount is completely applied, TDS or WCt or ESSI invoices get created on the
                  remaining standard invoice amount based on the TDS, WCT or ESSi tax respectively attached.

45. 14-Jan-2010  Jia For FP Bug#7312295
               Issue: This is a forward port bug for the Bug#7252683.
                   Cancellation of the invoice breaching the surcharge threhsold does not cancel the surcharge invoice
                   that got created while the transition. this results in wrong surcharge calculation.

               Fixed: Modified the code in procedure process_threshold_transition.
                   Added the nvl conditions to the various tax rates used in the surcharge rate calculation formula.
                   without this a null value in any one of either cess, or sh cess was leading to no surcharge invoice
                   getting created, even though surcharge was applicable.

46. 14-Jan-2010  Jia For FP Bug#7368735
               Issue: This is a forward port bug for the Bug#7347096.
                   On attaching a wct tax alone, the error 'Error - Threshold is not defined for the applicable TDS section'
                   was getting thrown,this is due to the entry that gets created for TDS in jai_ap_tds_inv_taxes also with
                   no section codes, even though there is no distribution created which has a TDS tax.

               Fixed: Modified the cursor c_check_valid_tax in procedure process_tds_at_inv_validate to only loop through
                  the distributions which have either a default_section_code or actual_section_code defined.

47. 14-Jan-2010  Jia For FP Bug#8278439
               Issue: This is a forward port bug for the Bug#8269891.
                   The Threshold_hdr_id value in jai_ap_tds_thhold_trxs was not being populated, which was leading to
                   the record missing from the 'India - TDS PAyment Review' report, because the main query of this report
                   is dependent on the value of threshold_hdr_id column of jai_ap_tds_thhold_trxs.

               Fixed: In cases where no default_section_code was specified in the vendor additional information,
                   the value for default_section_code in jai_ap_tds_inv_taxes was populated as null.
                   Hence during the execution of the cursor c_check_valid_tax it would fetch no records as the
                   value for actual_section_code is also null at this point of time. Hence modified this query to
                   be based on actual_tax_id and default_tax_id rather than the section code.

48. 25-Jan-2010 Bug 5751783 (Forward Port of 5721614)
                -------------------------------------
                Issues
                + Amount in certificates is wrong. All calculations are made based on rounded values
                + Certificates are generated with Taxable Basis as 0 but non zero tax amount
                + Certificates are generated with negative amounts.
                + During Prepayment Un-application if Threshold Transition occurs then there are no TDS Invoices generated.
                + Taxable Basis is wrong for Threshold Rollback.
                + Applying Prepayment with different rates results in negative RTN

                Bug 8431516 (Forward Port of 7626202)
                -------------------------------------
                RTN invoice would be generated to negate the effect of TDS invoice created for a prepayment, when the prepayment
                is applied to a standard invoice.

---------------------------------------------------------------------------- */
/*Added Procedure below for Xiao for Bug#7154864*/
procedure get_prepay_invoice_amt(pn_invoice_id NUMBER,pn_prepay_amt OUT NOCOPY NUMBER)
is
PRAGMA AUTONOMOUS_TRANSACTION;
cursor c_get_dist_prepay(p_invoice_id number) is
--select prepay_distribution_id, amount --Comments by Jia for FP Bug#7431371
select prepay_distribution_id, sum(amount) amount --Modified by Jia for FP Bug#7431371
from ap_invoice_distributions_all
where invoice_id = p_invoice_id
and prepay_distribution_id is not null
group by prepay_distribution_id; --Addec by Jia for FP Bug#7431371

cursor c_get_prepay_inv(p_prepay_dist_id number) is
select invoice_id
from ap_invoice_distributions_all
where invoice_distribution_id = p_prepay_dist_id;

cursor c_prepay_tds_cal(p_invoice_id number) is --Xiao for Bug#6767347
select 1 from
jai_ap_tds_thhold_trxs where
invoice_id = p_invoice_id;

--Addec by Jia for FP Bug#7431371, Begin
-------------------------------------------------------------------------------
cursor c_get_tax_code(p_invoice_id number, p_invoice_distribution_id number) is
select nvl(actual_tax_id, default_tax_id) tax_id
from jai_ap_tds_inv_taxes
where invoice_id = p_invoice_id
and invoice_distribution_id = p_invoice_distribution_id;

cursor c_get_tax_rate(p_tax_id number) is
select tax_rate
from jai_cmn_taxes_all
where tax_id = p_tax_id;

ln_tax_id number;
ln_tax_rate number;
-------------------------------------------------------------------------------
--Addec by Jia for FP Bug#7431371, End

ln_invoice_id number;
ln_prepay_tds_exists number := 0;
BEGIN
    BEGIN
	  pn_prepay_amt := 0;
	  for r_get_dist_prepay in c_get_dist_prepay(pn_invoice_id)
	  loop
	   open c_get_prepay_inv(r_get_dist_prepay.prepay_distribution_id);
       fetch c_get_prepay_inv into ln_invoice_id;
       close c_get_prepay_inv;

	   open c_prepay_tds_cal(ln_invoice_id);
	   fetch c_prepay_tds_cal into ln_prepay_tds_exists;
	   close c_prepay_tds_cal;

	   if ln_prepay_tds_exists = 1 then
	   pn_prepay_amt := pn_prepay_amt + abs(r_get_dist_prepay.amount);

     --Addec by Jia for FP Bug#7431371, Begin
     -------------------------------------------------------------------------------
     ELSE
        open c_get_tax_code(ln_invoice_id, r_get_dist_prepay.prepay_distribution_id);
        fetch c_get_tax_code into ln_tax_id;
        close c_get_tax_code;

        open c_get_tax_rate(ln_tax_id);
        fetch c_get_tax_rate into ln_tax_rate;
        close c_get_tax_rate;

        if ln_tax_rate = 0 then
        pn_prepay_amt := pn_prepay_amt + abs(r_get_dist_prepay.amount);
        end if;
     -------------------------------------------------------------------------------
     --Addec by Jia for FP Bug#7431371, End
	   end if;
	  end loop;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		pn_prepay_amt:=0;
	END;
END get_prepay_invoice_amt;

--Added by Xiao Lv for bug#8345080 on 13-Jan-10, begin
procedure get_prepay_appln_amt(pn_invoice_id NUMBER,
                               pn_threshold_grp_id NUMBER,
							   pn_curr_inv_flag VARCHAR2 DEFAULT 'N',   --Added by Xiao Lv for Bug#8513550, related 11i bug#8439276
							   pn_apply_amt OUT NOCOPY NUMBER)
is
PRAGMA AUTONOMOUS_TRANSACTION;
  cursor c_jai_apply_amount(cp_invoice_id number) is
  select sum(a.application_amount) application_amount, d.threshold_grp_id, d.invoice_id
  from jai_ap_tds_prepayments a,
     ap_invoice_distributions_all b,
     ap_invoice_distributions_all c,
     jai_ap_tds_inv_taxes d
  where a.invoice_distribution_id_prepay = b.invoice_distribution_id
  and b.prepay_distribution_id = c.invoice_distribution_id
  and nvl(a.unapply_flag, 'N') <> 'Y'
  and c.invoice_id = cp_invoice_id                --modified by Xiao Lv for Bug#8513550, related 11i bug#8439276
  and c.invoice_id= d.invoice_id
  group by d.threshold_grp_id, d.invoice_id;

  --Added by Xiao Lv for Bug#8513550, related 11i bug#8439276, begin
  cursor c_prepay_apply_amt(cp_invoice_id number) is
  select abs(amount) amount, invoice_distribution_id, prepay_distribution_id
  from ap_invoice_distributions_all
  where invoice_id = cp_invoice_id
  and line_type_lookup_code = 'PREPAY';

  cursor c_get_thhold_grp(cp_invoice_id number, cp_invoice_dist_id number) is
  select threshold_grp_id
  from jai_ap_tds_inv_taxes
  where invoice_distribution_id = cp_invoice_dist_id;

  r_prepay_apply_amt c_prepay_apply_amt%rowtype;
  lv_thhold_grp_id number;
  --Added by Xiao Lv for Bug#8513550, related 11i bug#8439276, end
  r_jai_apply_amount   c_jai_apply_amount%rowtype;

BEGIN
    BEGIN
	  pn_apply_amt := 0;
	   --Added by Xiao Lv for Bug#8513550, related 11i bug#8439276, begin
	  if   pn_curr_inv_flag = 'Y' then
	    for r_prepay_apply_amt in c_prepay_apply_amt(pn_invoice_id) loop
		open c_get_thhold_grp(pn_invoice_id, r_prepay_apply_amt.prepay_distribution_id);
		fetch c_get_thhold_grp into lv_thhold_grp_id;
		close c_get_thhold_grp;

		if lv_thhold_grp_id = pn_threshold_grp_id then
		pn_apply_amt := pn_apply_amt + r_prepay_apply_amt.amount;
		end if;
		end loop;
	  else
	  --Added by Xiao Lv for Bug#8513550, related 11i bug#8439276, end
		for r_jai_apply_amount in c_jai_apply_amount(pn_invoice_id) loop
		if r_jai_apply_amount.threshold_grp_id = pn_threshold_grp_id then
		pn_apply_amt := pn_apply_amt + nvl(r_jai_apply_amount.application_amount,0);
		end if;
		end loop;

	  end if;   --Added by Xiao Lv for Bug#8513550

	  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		pn_apply_amt:=0;
	END;
END get_prepay_appln_amt;
--Added by Xiao Lv for bug#8345080 on 13-Jan-10, end

 /*Added for Bug 8641199 - Start*/
 procedure get_org_id(p_invoice_id IN NUMBER, p_org_id OUT NOCOPY NUMBER)
 is
 PRAGMA AUTONOMOUS_TRANSACTION;
 BEGIN
 select org_id into p_org_id
 from ap_invoices_all
 where invoice_id = p_invoice_id;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 p_org_id := NULL;
 END;
 /*Added for Bug 8641199 - End*/

  /*Modified for Bug 8641199 - Start*/
  procedure status_update_chk_validate
  (
    p_invoice_id                         in                  number,
    p_invoice_line_number                in                  number    default   null, /* AP lines uptake */
    p_invoice_distribution_id            in                  number    default   null,
    p_match_status_flag                  in                  varchar2  default   null,
    p_is_invoice_validated               out       nocopy    varchar2,
    p_process_flag                       out       nocopy    varchar2,
    p_process_message                    out       nocopy    varchar2,
    p_codepath                           in out    nocopy    varchar2
   )
   is

   lv_section_type VARCHAR2(15) ;


    cursor c_check_not_validate(p_invoice_id number, p_section_type VARCHAR2 ) is
      select count(tds_inv_tax_id) total_count, sum(decode(match_status_flag, 'A', 1, 0)) validated_a_count,
 	         sum(decode(match_status_flag, 'T', 1, 0)) validated_t_count
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      -- Harshita for Bug 4870243
      and    nvl(invoice_line_number, -9999) = nvl(p_invoice_line_number, invoice_line_number)
      and    invoice_distribution_id =  nvl(p_invoice_distribution_id, invoice_distribution_id)  -- Bug 6119216
      and    section_type = p_section_type ;

    cursor c_fetch_po_encum(p_org_id number) is
    select nvl(purch_encumbrance_flag, 'N')
    from FINANCIALS_SYSTEM_PARAMS_ALL
    where org_id = p_org_id;


      /*select  tds_inv_tax_id
            from    jai_ap_tds_inv_taxes
            where   invoice_id =  p_invoice_id
            and     nvl(invoice_line_number, -9999) = nvl(p_invoice_line_number, -9999)
            and     nvl(invoice_distribution_id, -9999) =  nvl(p_invoice_distribution_id, -9999)
      and     section_type = p_section_type; */



    cursor c_ap_holds_all(p_invoice_id number) is
      select count(invoice_id)
      from   ap_holds_all
      where  invoice_id = p_invoice_id
      and    release_reason is null;


    ln_total_count      number;
    ln_validated_a_cnt  number;
    ln_validated_t_cnt  number;
    ln_no_of_holds      number;
    lp_org_id           number;
    l_po_encum_flag     VARCHAR2(1);

  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_generation_pkg.status_update_chk_validate', 'START'); /* 1 */

    get_org_id(p_invoice_id, lp_org_id);
    l_po_encum_flag := 'N';
    if lp_org_id is NOT NULL THEN
       open c_fetch_po_encum(lp_org_id);
       fetch c_fetch_po_encum into l_po_encum_flag;
       close c_fetch_po_encum;
    end if;

    if p_invoice_distribution_id is not null and p_match_status_flag is not null then
      update jai_ap_tds_inv_taxes
      set    match_status_flag = p_match_status_flag
      where  invoice_id = p_invoice_id
      and    invoice_distribution_id = p_invoice_distribution_id;
    end if;

    ln_total_count := 0;
    ln_validated_a_cnt := 0;
    ln_validated_t_cnt := 0;

    lv_section_type := 'TDS_SECTION' ;  -- Harshita for Bug 4870243

    open c_check_not_validate(p_invoice_id, lv_section_type); -- Harshita, added lv_section_type for Bug 4870243
    fetch c_check_not_validate into ln_total_count, ln_validated_a_cnt, ln_validated_t_cnt;
    close c_check_not_validate;

    fnd_file.put_line(FND_FILE.LOG, ' Value of total cnt '|| ln_total_count);

    fnd_file.put_line(FND_FILE.LOG, ' Value of validated A cnt '|| ln_validated_a_cnt);
    fnd_file.put_line(FND_FILE.LOG, ' Value of validated T cnt '|| ln_validated_t_cnt);

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */

    if ln_total_count = (ln_validated_a_cnt + ln_validated_t_cnt) then
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */

      p_is_invoice_validated := 'Y';
    else
      p_is_invoice_validated := 'N';
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
    end if;

    if l_po_encum_flag = 'Y' and ln_validated_t_cnt > 0 then
       p_is_invoice_validated := 'N';
       p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    end if;

    if p_match_status_flag is not null then
      /* Scenarios other than holds release */
      open  c_ap_holds_all(p_invoice_id);
      fetch c_ap_holds_all into ln_no_of_holds;
      close c_ap_holds_all;

      if nvl(ln_no_of_holds, 0) > 0 then
        p_is_invoice_validated := 'N';
        p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      end if;

    end if;

    fnd_file.put_line(FND_FILE.LOG,  'Status_update_chk_validate - Status of  parent invoice '|| p_is_invoice_validated);

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath, null, 'END'); /* 7 */
    return;

   exception
      when others then
        p_process_flag := 'E';
        P_process_message := 'jai_ap_tds_generation_pkg.status_update_chk_validate :' ||  sqlerrm;
        return;
  end status_update_chk_validate;

  /*Modified for Bug 8641199 - End*/

  /* ************************************* process_invoice ************************************ */


  /* ************************************* process_tds_at_inv_validate ************************************ */

  procedure process_tds_at_inv_validate
  (
    p_invoice_id                         in                  number,
    p_vendor_id                          in                  number,
    p_vendor_site_id                     in                  number,
    p_accounting_date                    in                  date,
    p_invoice_currency_code              in                  varchar2,
    p_exchange_rate                      in                  number,
    p_set_of_books_id                    in                  number,
    p_org_id                             in                  number,
    p_call_from                          in                  varchar2,
    -- Bug 5722028. Added by Lakshmi Gopalsami
    p_creation_date                      in                  date,
    p_process_flag                       out       nocopy    varchar2,
    p_process_message                    out       nocopy    varchar2,
    p_codepath                           in out    nocopy    varchar2
  )
  is

    cursor c_check_if_exists(p_invoice_id  number) is
      select count(tds_inv_tax_id)
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    (actual_tax_id is not null or default_tax_id is not null);

    cursor c_check_if_processed(p_invoice_id  number,p_process_status jai_ap_tds_inv_taxes.process_status%type) is
      select count(tds_inv_tax_id)
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    process_status = p_process_status;

    cursor c_calculate_tax(p_invoice_id  number) is
      select tds_inv_tax_id, actual_tax_id,default_tax_id, amount, invoice_distribution_id  --Xiao for Bug#7154864
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    (default_tax_id is not null or actual_tax_id is not null); --Xiao for Bug#7154864

    cursor c_ja_in_tax_codes(p_tax_id number) is
      select tax_rate,
             section_code,
             end_date,
             sysdate,
             'Tax : ' || tax_name || ' is end dated as on ' || to_char(end_date, 'dd-mon-yyyy') ||
             '. Setup needs modification.' tax_end_dated_message
      from   JAI_CMN_TAXES_ALL
      where  tax_id = p_tax_id;
    /*Bug 5751783 - Selected non-rounded value for calculation*/
    cursor c_for_each_tds_section(p_invoice_id  number, p_exchange_rate number,p_section_type jai_ap_tds_inv_taxes.section_type%type, p_prepay_amt number) is--rchandan for bug#4428980 --add by xiao for bug#6596019
      select actual_section_code, (sum(amount*p_exchange_rate)-p_prepay_amt) invoice_amount, sum(calc_tax_amount) section_amount,
             sum(tax_amount) tax_amount_orig
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    section_type = p_section_type         --rchandan for bug#4428980
      and    actual_section_code is not null
      group by  actual_section_code;
      --having sum(tax_amount) <> 0;   --Commented by Bgowrava for Bug#8254510

    cursor c_po_vendors(p_vendor_id number) is
      select tds_vendor_type_lookup_code
      from   JAI_AP_TDS_VNDR_TYPE_V
      where  vendor_id = p_vendor_id;

    cursor c_get_threshold
    (p_vendor_id number, p_vendor_site_id number,  p_tds_section_code varchar2,p_section_type jai_ap_tds_inv_taxes.section_type%type) IS   --rchandan for bug#4428980
      select threshold_hdr_id
      from   JAI_AP_TDS_TH_VSITE_V
      where  vendor_id = p_vendor_id
      and    vendor_site_id = p_vendor_site_id
      and    section_type = p_section_type    --rchandan for bug#4428980
      and    section_code = p_tds_section_code;

    cursor    c_get_threshold_group
    (p_vendor_id number, p_tan_no varchar2, p_pan_no varchar2,  p_tds_section_code varchar2 , p_fin_year  number,p_section_type jai_ap_tds_inv_taxes.section_type%type) IS --rchandan for bug#4428980
      select  threshold_grp_id
      from    jai_ap_tds_thhold_grps
      where   vendor_id         =  p_vendor_id
      and     section_type      =  p_section_type --rchandan for bug#4428980
      and     section_code      =  p_tds_section_code
      and     org_tan_num       =  p_tan_no
      and     vendor_pan_num    =  p_pan_no
      and     fin_year          =  p_fin_year;

    cursor c_jai_ap_tds_thhold_grps(p_threshold_grp_id  number) is
      select (
              nvl(total_invoice_amount, 0) -
              nvl(total_invoice_cancel_amount, 0) -
              nvl(total_invoice_apply_amount, 0)  +
              nvl(total_invoice_unapply_amount, 0)
              )
              total_invoice_amount,
              total_tax_paid,
              total_thhold_change_tax_paid,
              current_threshold_slab_id,
              /*Bug 5751783. Selected non-rounded value for calculation*/
              total_calc_tax_paid
      from    jai_ap_tds_thhold_grps
      where   threshold_grp_id = p_threshold_grp_id;


    cursor c_jai_ap_tds_thhold_slabs
    ( p_threshold_hdr_id number, p_threshold_type varchar2, p_amount number) is
      select  threshold_slab_id, threshold_type_id, from_amount, to_amount
      from    jai_ap_tds_thhold_slabs
      where   threshold_hdr_id = p_threshold_hdr_id
      and     threshold_type_id in
            ( select threshold_type_id
              from   jai_ap_tds_thhold_types
              where   threshold_hdr_id = p_threshold_hdr_id
              and     threshold_type = p_threshold_type
        /* Bug 4522540. Added by Lakshmi Gopalsami
           Added the following date condition */
              and    trunc(p_accounting_Date) between from_date
        and nvl(to_date, p_accounting_date + 1)
            )
      and     p_amount between from_amount and nvl(to_amount, p_amount)
      order by from_amount asc;


     /*following cursor added for FP bug 6345725 - need to check if there are any active slab(s) defined */
     cursor c_check_slabs_end_dated (p_threshold_hdr_id number) is
        select 1
        from jai_ap_tds_thhold_types
        where threshold_hdr_id = p_threshold_hdr_id
        and   trunc(p_accounting_Date) between from_date and nvl(to_date, p_accounting_date + 1);

     ln_check_slab_exists NUMBER;

    /*Bug 5751783. Selected non-rounded value for calculation*/

    cursor c_get_taxes_to_generate_tds
    (p_invoice_id number, p_tds_section_code varchar2, p_generate_all_invoices varchar2,
     p_exchange_rate number, p_threshold_slab_id_single number,p_section_type jai_ap_tds_inv_taxes.section_type%type, p_prepay_amt number) IS --rchandan for bug#4428980--add by xiao for bug#6596019
      select nvl(actual_tax_id,default_tax_id) actual_tax_id,   --added nvl by Xiao for Bug#7154864
(             sum(amount*p_exchange_rate)-p_prepay_amt) taxable_amount, --Xiao for bug#6596019
             sum(calc_tax_amount) tax_amount,
             sum(tax_amount) tax_amount_orig
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    section_type      =  p_section_type   --rchandan for bug#4428980
      and    actual_section_code = p_tds_section_code
      and    (
               (p_generate_all_invoices = 'Y' )
               or
               (p_threshold_slab_id_single > 0 )
                or
               (actual_tax_id is NOT NULL) --added by Xiao for Bug#7154864
             )
      group by nvl(actual_tax_id, default_tax_id);  --added nvl by Xiao for Bug#7154864

    cursor c_get_vendor_pan_tan(p_vendor_id number , p_vendor_site_id number) is
      select    c.pan_no pan_no,
                d.org_tan_num tan_no
        from    po_vendors a,
                po_vendor_sites_all b,
                JAI_AP_TDS_VENDOR_HDRS c,
                jai_ap_tds_org_tan_v d  --rchandan for bug#4323338
      where     a.vendor_id = b.vendor_id
        and     b.vendor_id = c.vendor_id
        and     b.vendor_site_id = c.vendor_site_id
        and     b.org_id = d.organization_id
        and     a.vendor_id = p_vendor_id
        and     b.vendor_site_id = p_vendor_site_id;


    lv_attr_code  VARCHAR2(25);
    lv_attr_type_code VARCHAR2(25);
    lv_tds_regime     VARCHAR2(25);
    lv_regn_type_others VARCHAR2(25);

    cursor c_get_fin_year(p_accounting_date  date, p_org_id number) is
      select fin_year
      from   JAI_AP_TDS_YEARS
      where  tan_no in  /* where clause and subquery added by ssumaith - bug# 4448789*/
            (
              SELECT  attribute_value
              FROM    JAI_RGM_ORG_REGNS_V
              WHERE   regime_code = lv_tds_regime
              AND     registration_type = lv_regn_type_others
              AND     attribute_type_code = lv_attr_type_Code
              AND     attribute_code = lv_attr_code
              AND     organization_id = p_org_id
            )
      and    p_accounting_date between start_date and end_date;

    cursor c_gl_sets_of_books(cp_set_of_books_id  number) is
    select currency_code
    from   gl_sets_of_books
    where  set_of_books_id = cp_set_of_books_id;

    /*Bug 5751783. Selected non-rounded value for calculation*/

    cursor c_get_non_tds_section_tax (p_invoice_id number, p_exchange_rate number,p_section_type jai_ap_tds_inv_taxes.section_type%type) IS     --rchandan for bug#4428980
    select section_type,
           actual_tax_id,
           sum(amount*p_exchange_rate) taxable_amount,
           sum(calc_tax_amount) tax_amount,
           sum(tax_amount) tax_amount_orig
    from   jai_ap_tds_inv_taxes
    where  invoice_id = p_invoice_id
    and    section_type      <>  p_section_type        --rchandan for bug#4428980
    and    actual_tax_id is not null
    group by section_type, actual_tax_id;

	/*START, Bgowrava for Bug#8254510*/
	cursor c_jai_slab_start_amt(p_threshold_slab_id number) is
	select jatts.from_amount from_amount,
           jatts.tax_rate tax_rate,
		   jattt.tax_id tax_id,
		   (jitc.tax_rate-(nvl(jitc.surcharge_rate,0) + nvl(jitc.cess_rate,0) + nvl(jitc.sh_cess_rate,0))) tax_rate_orig
	from jai_ap_tds_thhold_slabs jatts,
         jai_ap_tds_thhold_taxes jattt,
         jai_cmn_taxes_all jitc
	where jatts.threshold_slab_id = jattt.threshold_slab_id
	and jattt.tax_id = jitc.tax_id
	and jatts.threshold_slab_id = p_threshold_slab_id;

	r_jai_slab_start_amt_after c_jai_slab_start_amt%rowtype;
	r_jai_slab_start_amt_before c_jai_slab_start_amt%rowtype;
	ln_tds_amt_before number;
	ln_tds_amt_after number;
	ln_tds_tax_amount number;
	/*END, Bgowrava for Bug#8254510*/

    /*START, Added by xiao for Bug#6596019*/
		cursor c_get_prepayment_amt(p_invoice_id number) is
		select amount_paid
		from ap_invoices_all
		where invoice_id = p_invoice_id;

    -- Modified by Jia for FP Bug#7368735, Begin
    ---------------------------------------------------------
    /*
    cursor c_check_valid_tax(p_invoice_id  number) is
		select actual_tax_id, default_tax_id
		from   jai_ap_tds_inv_taxes
		where  invoice_id = p_invoice_id
		and    section_type = 'TDS_SECTION'	;
    */  --Commented by Jia for FP Bug#7368735

    -- Modified by Jia for FP Bug#8278439, Begin
    ------------------------------------------------------------------------
    cursor c_check_valid_tax(p_invoice_id  number) is
    /*
    select nvl(actual_section_code, default_section_code) section_code
    from jai_ap_tds_inv_taxes
    where  section_type = 'TDS_SECTION'
    and invoice_id = p_invoice_id
    and (actual_section_code is not null or default_section_code is not null);
    */ --Commented by Jiaf or FP Bug#8278439
    select jitc.section_code section_code
    from jai_cmn_taxes_all jitc, jai_ap_tds_inv_taxes jatit
    where jitc.tax_id = nvl(jatit.actual_tax_id, jatit.default_tax_id)
    and jatit.section_type = 'TDS_SECTION'
    and jatit.invoice_id = p_invoice_id
    and (actual_tax_id is not null or default_tax_id is not null);
    ------------------------------------------------------------------------
    -- Modified by Jia for FP Bug#8278439, End

    ---------------------------------------------------------
    -- Modified by Jia for FP Bug#7368735, End

    /*END, xiao for Bug#6596019*/

    --Addec by Jia for FP Bug#7431371, Begin
    -------------------------------------------------------------------------------
    cursor c_get_amount_already_applied(p_invoice_distribution_id number) is
    select  sum(application_amount)
    from    jai_ap_tds_prepayments
    where   invoice_distribution_id = p_invoice_distribution_id
    and     nvl(unapply_flag, 'N') <> 'Y';

    ln_remaining_prepayment_amount      number;
    ln_effective_available_amount       number;
    ln_already_applied_amount           number;
    ln_application_amount               number;
    ln_prev_dist_id                     number := 0;
    -------------------------------------------------------------------------------
    --Addec by Jia for FP Bug#7431371, End

      ln_prepayment_app_amt             number :=0; --xiao for Bug#6596019
      r_jai_ap_tds_thhold_grps          c_jai_ap_tds_thhold_grps%rowtype;
      r_gl_sets_of_books                c_gl_sets_of_books%rowtype;
      r_ja_in_tax_codes                 c_ja_in_tax_codes%rowtype;

      ln_count                          number:= 0;
      ln_cnt_already_processed          number:= 0;
      ln_tax_id                         number;
      ln_tax_amount                     number;
      ln_threshold_grp_id               number;
      lv_vendor_type_lookup_code        po_vendors.vendor_type_lookup_code%type;
      ln_threshold_hdr_id               number;
      r_jai_ap_tds_thhold_slabs         c_jai_ap_tds_thhold_slabs%rowtype;
      ln_total_invoice_amount           number;
      ln_threshold_slab_id_before       number;
      ln_threshold_slab_id_after        number;
      ln_threshold_slab_id_single       number;
      lv_generate_all_invoices          varchar2(1);
      ln_threshold_trx_id               number;
      lv_tds_invoice_num                ap_invoices_all.invoice_num%type;
      lv_tds_cm_num                     ap_invoices_all.invoice_num%type;

      lv_pan_no                         JAI_AP_TDS_VENDOR_HDRS.pan_no%type;
      lv_tan_no                         jai_ap_tds_org_tan_v.org_tan_num %type;  --rchandan for bug#4323338
      ln_exchange_rate                  number;
      ln_fin_year                       JAI_AP_TDS_YEARS.fin_year%type;
      lv_slab_transition_tds_event      jai_ap_tds_thhold_trxs.tds_event%type;

      ln_no_of_tds_inv_generated        number := 0;
      lb_result                         boolean;
      ln_req_id                         number;
      ln_start_threshold_trx_id         number;
      ln_threshold_grp_audit_id         number;
      lv_tds_section_type               CONSTANT varchar2(30) := 'TDS_SECTION';    --rchandan for bug#4428980
			-- Bug 5722028. Added by Lakshmi Gopalsami
      ln_tmp_tds_amt                    number;

sqlbuf VARCHAR2(1996);


    begin

      p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_generation_pkg.process_tds_at_inv_validate', 'START'); /* 1 */
      open c_check_if_exists(p_invoice_id);
      fetch c_check_if_exists into ln_count;
      close c_check_if_exists;

      fnd_file.put_line(FND_FILE.LOG, '1. Check for tax count'|| ln_count);

      if nvl(ln_count, 0) = 0 then
        p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
        fnd_file.put_line(FND_FILE.LOG, '2. TDS tax is not applicable');
        p_process_flag := 'X';
        p_process_message := ' TDS tax is not applicable';
        goto exit_from_procedure;
      end if;

      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      open  c_check_if_processed(p_invoice_id,'P');
      fetch c_check_if_processed into ln_cnt_already_processed;
      close c_check_if_processed;

      fnd_file.put_line(FND_FILE.LOG, '3. Check for processed already '|| ln_cnt_already_processed);

      if nvl(ln_cnt_already_processed, 0) > 0 then
        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
        p_process_flag := 'X';
        p_process_message := 'TDS invoices have already been processed for this invoice';
        goto exit_from_procedure;
      end if;


      /* Update actual value from default value if actual is null for TDS section taxes only*/
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      update jai_ap_tds_inv_taxes
      set    actual_tax_id = default_tax_id
      where  invoice_id = p_invoice_id
      and    actual_tax_id is null
      and    user_deleted_tax_flag IS NOT NULL AND user_deleted_tax_flag <> 'Y' -- nvl(user_deleted_tax_flag, 'N') <> 'Y'
      and    section_type = lv_tds_section_type;  --rchandan for bug#4428980


      /* Update processed for those cases where NO TDS has to be deducted for TDS section taxes only */
      update  jai_ap_tds_inv_taxes
      set     process_status = 'P'
      where   invoice_id = p_invoice_id
      and     section_type = lv_tds_section_type  --rchandan for bug#4428980
      and     nvl(user_deleted_tax_flag, 'N') = 'Y';

      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */

      open c_gl_sets_of_books(p_set_of_books_id);
      fetch c_gl_sets_of_books into r_gl_sets_of_books;
      close c_gl_sets_of_books;

      if r_gl_sets_of_books.currency_code <> p_invoice_currency_code then
        /* Foreign currency invoice */
        p_codepath := jai_general_pkg.plot_codepath(6.1, p_codepath); /* 6.1 */
        ln_exchange_rate := p_exchange_rate;
      end if;

      ln_exchange_rate := nvl(ln_exchange_rate, 1);
	   /*START, xiao for Bug#6596019*/
		 for c_rec1 in c_check_valid_tax(p_invoice_id) loop
			r_ja_in_tax_codes := null;

			--Commented by Jia for FP Bug#7368735, Begin
      --------------------------------------------------------------------------
      /*
      open c_ja_in_tax_codes(nvl(c_rec1.actual_tax_id, c_rec1.default_tax_id));
			fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
			close c_ja_in_tax_codes;
      */
      --------------------------------------------------------------------------
			--Commented by Jia for FP Bug#7368735, End

      ln_threshold_hdr_id := 0;
			--open  c_get_threshold(p_vendor_id ,p_vendor_site_id, r_ja_in_tax_codes.section_code,'TDS_SECTION'); --Commented by Jia for FP Bug#7368735
			open  c_get_threshold(p_vendor_id ,p_vendor_site_id, c_rec1.section_code,'TDS_SECTION');
			fetch c_get_threshold into ln_threshold_hdr_id;
			close c_get_threshold;

			if nvl(ln_threshold_hdr_id, 0) = 0 then
				p_codepath := jai_general_pkg.plot_codepath(10, p_codepath);  /*10 */
				p_process_flag := 'E';
				p_process_message := 'Error - Threshold is not defined for the applicable TDS section :' ||
				                    r_ja_in_tax_codes.section_code ;
				goto exit_from_procedure;
			end if;

			ln_check_slab_exists := NULL;
			open c_check_slabs_end_dated(ln_threshold_hdr_id);
			fetch c_check_slabs_end_dated into ln_check_slab_exists;
			if ln_check_slab_exists IS NULL THEN
					 p_process_flag := 'E';
					 p_process_message := 'There are no active thresholds defined for this vendor';
					 goto exit_from_procedure;
			end if;
			close c_check_slabs_end_dated;
			end loop;
   /*END, xiao for Bug#6596019*/

    --Addec by Jia for FP Bug#7431371, Begin
    -------------------------------------------------------------------------------
    get_prepay_invoice_amt(p_invoice_id,ln_prepayment_app_amt);
    ln_remaining_prepayment_amount := ln_prepayment_app_amt;
    ln_application_amount := 0;
    -------------------------------------------------------------------------------
    --Addec by Jia for FP Bug#7431371, End

      /* start Loop through and calculate taxes  for taxes of all sections */
      for cur_rec in c_calculate_tax(p_invoice_id) loop

        p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */

        r_ja_in_tax_codes := null;
        open  c_ja_in_tax_codes(nvl(cur_rec.actual_tax_id,cur_rec.default_tax_id)); --Added nvl by Xiao for Bug#7154864
        fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
        close c_ja_in_tax_codes;

        if trunc(r_ja_in_tax_codes.end_date) <  p_accounting_date then --trunc(r_ja_in_tax_codes.sysdate) then    --commented by Bgowrava for Bug#7389849
          p_codepath := jai_general_pkg.plot_codepath(7.1, p_codepath); /* 7.1 */
          p_process_flag := 'E';
          p_process_message := r_ja_in_tax_codes.tax_end_dated_message;
          goto exit_from_procedure;
        end if;

       /* ln_tax_amount := cur_rec.amount * (r_ja_in_tax_codes.tax_rate/100 );
        ln_tax_amount := ln_tax_amount * ln_exchange_rate;
        ln_tax_amount := round(ln_tax_amount, 2);
	get_prepay_invoice_amt(p_invoice_id,ln_prepayment_app_amt);  */ --commented by bgowrava for bug#7431371

      --Addec by Jia for FP Bug#7431371, Begin
      -------------------------------------------------------------------------------
      ln_already_applied_amount:= 0;
      ln_effective_available_amount := 0;

      open  c_get_amount_already_applied(cur_rec.invoice_distribution_id);
      fetch c_get_amount_already_applied into ln_already_applied_amount;
      close c_get_amount_already_applied;

      ln_already_applied_amount := nvl(ln_already_applied_amount, 0);
      ln_effective_available_amount := cur_rec.amount - ln_already_applied_amount;
      if ln_prev_dist_id <> cur_rec.invoice_distribution_id then
        ln_application_amount := least(ln_remaining_prepayment_amount, ln_effective_available_amount);
      end if;
      -------------------------------------------------------------------------------
      --Addec by Jia for FP Bug#7431371, End

    ln_tax_amount := (cur_rec.amount-nvl(ln_application_amount,0)) * ln_exchange_rate *                      --modified by Bgowrava for bug#7431371
	                 (r_ja_in_tax_codes.tax_rate/100 );			  -- xiao for Bug#6596019

      --Addec by Jia for FP Bug#7431371, Begin
      -------------------------------------------------------------------------------
      if ln_prev_dist_id <> cur_rec.invoice_distribution_id then
        ln_remaining_prepayment_amount :=  ln_remaining_prepayment_amount -  ln_application_amount; --Bgowrava for Bug#7419533
      end if;
      ln_prev_dist_id := cur_rec.invoice_distribution_id;
      -------------------------------------------------------------------------------
      --Addec by Jia for FP Bug#7431371, End


	    /* Bug 5722028. Added by Csahoo
  	    * Called the rounding function as we need to round depending on the
	 * TDS rounding setup. We have a separate column calc_tax_amount
	 * which has non-rounded value.
	 */
	 /* Bug 7280925. Added by Lakshmi Gopalsami
	    Commented the following code as this is being handled in
	    generate_tds_invoicse and maintain_thhold_Grps
	If r_gl_sets_of_books.currency_code = p_invoice_currency_code then
	   ln_tmp_tds_amt := round(ln_tax_amount,g_inr_currency_rounding);
	else
	   ln_tmp_tds_amt := round(ln_tax_amount,g_fcy_currency_rounding);
	end if ;
	*/
	/* Bug 7280925. Commented by Lakshmi Gopalsami
	 * Rounding to 10 is applicable per invoice
	 * and not on each distribution

	IF trunc(p_creation_date) >=
	   trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
	   ln_tmp_tds_amt := get_rnded_value(ln_tmp_tds_amt);
	END IF;
	*/
	fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925  value of tax_amount before update'||ln_tax_amount);
        -- End for bug 5722028.
        /* bug 7280925. Added by Lakshmi Gopalsami
         * changed from ln_tmp_tds_amt to ln_tax_amount
         */

        update jai_ap_tds_inv_taxes
        set    tax_amount = ln_tax_amount, -- ln_tmp_tds_amt, -- Bug 5722028
               actual_section_code = r_ja_in_tax_codes.section_code,
               calc_tax_amount = ln_tax_amount   --Added by Bgowrava for bug#7154864
        where  tds_inv_tax_id = cur_rec.tds_inv_tax_id;

      end loop;
      /* End Loop through and calculate taxes */


      /* Get vendor_type_lookup_code */
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
      open  c_po_vendors(p_vendor_id);
      fetch c_po_vendors into lv_vendor_type_lookup_code;
      close c_po_vendors;

      fnd_file.put_line(FND_FILE.LOG,' 8. TDS Vendor type '|| lv_vendor_type_lookup_code);
      /* Get Pan number and Tan number for the vendor */
      open c_get_vendor_pan_tan(p_vendor_id, p_vendor_site_id);
      fetch c_get_vendor_pan_tan into lv_pan_no, lv_tan_no;
      close c_get_vendor_pan_tan;

       lv_attr_code  := 'TAN NO';
       lv_attr_type_code := 'PRIMARY';
       lv_tds_regime     := 'TDS';
       lv_regn_type_others := 'OTHERS';

      fnd_file.put_line(FND_FILE.LOG,' 8.1 Pan number-> '|| lv_pan_no);

      fnd_file.put_line(FND_FILE.LOG,' 8.1 Tan number-> '|| lv_tan_no);

      /* Get the fin year */
      open c_get_fin_year(p_accounting_date, p_org_id);
      fetch c_get_fin_year into ln_fin_year;
      close c_get_fin_year;

      fnd_file.put_line(FND_FILE.LOG,' 8.2 Fin Year -> '|| ln_fin_year);

      /* Start Loop through for each tds section and process for TDS section taxes only */
      /* This section is meant for threshold, specific to TDS section taxes only */
      for cur_rec_section in  c_for_each_tds_section(p_invoice_id, ln_exchange_rate,'TDS_SECTION', nvl(ln_prepayment_app_amt,0)) LOOP     --rchandan for bug#4428980--add by xiao for bug#6596019

        p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
        ln_threshold_grp_id := 0;
        --ln_threshold_hdr_id := 0;  --commented by xiao for bug#6596019
        ln_threshold_slab_id_before := null;
        ln_threshold_slab_id_after:= null;
        ln_threshold_slab_id_single := null;

        /*open  c_get_threshold
        (p_vendor_id , p_vendor_site_id ,  cur_rec_section.actual_section_code,'TDS_SECTION');   --rchandan for bug#4428980
        fetch c_get_threshold into ln_threshold_hdr_id;
        close c_get_threshold; */ --Commented by xiao for bug#6596019

        fnd_file.put_line(FND_FILE.LOG,' 9. Threshold hdr id-> '|| ln_threshold_hdr_id);

	      /* if nvl(ln_threshold_hdr_id, 0) = 0 then
          p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); -- 10
          fnd_file.put_line(FND_FILE.LOG, '10. Threshold is not defined for the
                                           applicable TDS section '||
                                           cur_rec_section.actual_section_code||
                                         '- Error');
          p_process_flag := 'E';
          p_process_message := 'Error - Threshold is not defined for the applicable TDS section :' ||
                               cur_rec_section.actual_section_code ;
          goto exit_from_procedure;
        end if;	 */  --commented by xiao for bug#6596019

        /* Get the threshold group id */
        p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
        open c_get_threshold_group(p_vendor_id, lv_tan_no, lv_pan_no, cur_rec_section.actual_section_code, ln_fin_year,'TDS_SECTION'); --rchandan for bug#4428980
        fetch c_get_threshold_group into ln_threshold_grp_id;
        close c_get_threshold_group;

   fnd_file.put_line(FND_FILE.LOG, '11. Threshold grp id ->'||ln_threshold_grp_id);

        /* Get the threshold group details   */
        p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
        if nvl(ln_threshold_grp_id, 0) <> 0 then
          p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */

          r_jai_ap_tds_thhold_grps := null;

          open  c_jai_ap_tds_thhold_grps(ln_threshold_grp_id);
          fetch c_jai_ap_tds_thhold_grps into r_jai_ap_tds_thhold_grps;
          close c_jai_ap_tds_thhold_grps;

          ln_total_invoice_amount := r_jai_ap_tds_thhold_grps.total_invoice_amount;

        else
           p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */

          ln_total_invoice_amount := 0;

        end if;

   fnd_file.put_line(FND_FILE.LOG, '12. Total invoice amount -> '||
                                              ln_total_invoice_amount);

        /* Get the threshold position before this invoice impact */
        p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
        open c_jai_ap_tds_thhold_slabs(ln_threshold_hdr_id , 'CUMULATIVE' , ln_total_invoice_amount);
        fetch c_jai_ap_tds_thhold_slabs into r_jai_ap_tds_thhold_slabs;
        close c_jai_ap_tds_thhold_slabs;

        ln_threshold_slab_id_before := nvl(r_jai_ap_tds_thhold_slabs.threshold_slab_id, 0);

   fnd_file.put_line(FND_FILE.LOG, '15. Threshold slab id before '||
                                              ln_threshold_slab_id_before);

        /* Get the threshold position after this invoice impact */
        p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
        /* FP Bug 6345725 - Removed the assignments for p_codepath without ja_in_general_pkg*/
        r_jai_ap_tds_thhold_slabs := null;
        open c_jai_ap_tds_thhold_slabs
        (ln_threshold_hdr_id , 'CUMULATIVE' , ln_total_invoice_amount + cur_rec_section.invoice_amount);
        fetch c_jai_ap_tds_thhold_slabs into r_jai_ap_tds_thhold_slabs;
        close c_jai_ap_tds_thhold_slabs;

        ln_threshold_slab_id_after := nvl(r_jai_ap_tds_thhold_slabs.threshold_slab_id, 0);

        /*start addition for FP bug 6345725 - check for active slabs. if there are no active*/
        /*slabs throw an error message*/
	/*ln_check_slab_exists := NULL;
        open c_check_slabs_end_dated(ln_threshold_hdr_id);
        fetch c_check_slabs_end_dated into ln_check_slab_exists;
        if ln_check_slab_exists IS NULL THEN
           p_process_flag := 'E';
           p_process_message := 'There are no active thresholds defined for this vendor';
           goto exit_from_procedure;
        end if;
	 close c_check_slabs_end_dated;	*/ --commented by bgowrava for bug#6596019
        /*end addition for bug 6345725*/


   fnd_file.put_line(FND_FILE.LOG, '16. Threshold slab id after ->'||
                                              ln_threshold_slab_id_after);
	--p_codepath := p_codepath || to_char(ln_threshold_slab_id_after) || '**';	   --commented by Bgowrava for Bug#8716477
        p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
        if ln_threshold_slab_id_after <> 0 then
        /* Threshold has reached */
          p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */
          lv_generate_all_invoices := 'Y';
        else
          lv_generate_all_invoices := 'N';
          p_codepath := jai_general_pkg.plot_codepath(19, p_codepath); /* 19 */
        end if; /* if ln_threshold_slab_id_after <> 0 */

        fnd_file.put_line(FND_FILE.LOG, '19. Generate invoices -> ' ||
                                              lv_generate_all_invoices);

        /* Check for Single Invoice threshold if cumulative has not been reached */
        if lv_generate_all_invoices = 'N' then
          /* Cumulative threshold not reached */
          r_jai_ap_tds_thhold_slabs := null;
          open c_jai_ap_tds_thhold_slabs(ln_threshold_hdr_id , 'SINGLE' , cur_rec_section.invoice_amount);
          fetch c_jai_ap_tds_thhold_slabs into r_jai_ap_tds_thhold_slabs;
          close c_jai_ap_tds_thhold_slabs;
          ln_threshold_slab_id_single := nvl(r_jai_ap_tds_thhold_slabs.threshold_slab_id, 0);
        end if;

        /* Loop and generate invoices */

        if nvl(ln_threshold_grp_id, 0) = 0 then

           p_codepath := jai_general_pkg.plot_codepath(19.1, p_codepath); /* 19.1 */

           fnd_file.put_line(FND_FILE.LOG, '19.1 Call maintain thhold grps ');

           jai_ap_tds_generation_pkg.maintain_thhold_grps
           (
              p_threshold_grp_id             =>   ln_threshold_grp_id,
              p_vendor_id                    =>   p_vendor_id,
              p_org_tan_num                  =>   lv_tan_no,
              p_vendor_pan_num               =>   lv_pan_no,
              p_section_type                 =>   'TDS_SECTION',
              p_section_code                 =>   cur_rec_section.actual_section_code,
              p_fin_year                     =>   ln_fin_year,
              p_org_id                       =>   p_org_id,
              p_trx_invoice_amount           =>   cur_rec_section.invoice_amount,
              p_tds_event                    =>   'INVOICE VALIDATE',
              p_invoice_id                   =>   p_invoice_id,
              p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
              -- Bug 5722028. Added by CSahoo
	      			p_creation_Date                =>   p_creation_date,
              p_process_flag                 =>   p_process_flag,
              P_process_message              =>   P_process_message,
              p_codepath                     =>   p_codepath
            );

            fnd_file.put_line(FND_FILE.LOG, '19.1 Process flag '|| p_process_flag);
            fnd_file.put_line(FND_FILE.LOG, '19.1 Process message '|| p_process_message);

        else

          p_codepath := jai_general_pkg.plot_codepath(19.2, p_codepath); /* 19.2 */

           jai_ap_tds_generation_pkg.maintain_thhold_grps
           (
              p_threshold_grp_id             =>   ln_threshold_grp_id,
              p_trx_invoice_amount           =>   cur_rec_section.invoice_amount,
              p_tds_event                    =>   'INVOICE VALIDATE',
              p_invoice_id                   =>   p_invoice_id,
              p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
              p_process_flag                 =>   p_process_flag,
              P_process_message              =>   P_process_message,
              p_codepath                     =>   p_codepath
            );

      			fnd_file.put_line(FND_FILE.LOG, '19.2 Process flag '|| p_process_flag);
            fnd_file.put_line(FND_FILE.LOG, '19.2 Process message '|| p_process_message);

        end if;

        --Added by Sanjikum for Bug#5131075(4722011)
        IF p_process_flag = 'E' THEN
          p_codepath := jai_general_pkg.plot_codepath(19.3, p_codepath); /* 19.3 */
          goto exit_from_procedure;
        END IF;

        /* Generate TDS invoices by taxes under the section */
        for cur_rec in
        c_get_taxes_to_generate_tds
        (p_invoice_id , cur_rec_section.actual_section_code, lv_generate_all_invoices,
         ln_exchange_rate, ln_threshold_slab_id_single,'TDS_SECTION', nvl(ln_prepayment_app_amt,0)) LOOP --rchandan for bug#4428980

          p_codepath := jai_general_pkg.plot_codepath(20, p_codepath); /* 20 */

		 /*START, Bgowrava for Bug# 8254510*/
		ln_tds_tax_amount := cur_rec.tax_amount;
		if ln_threshold_slab_id_before <> ln_threshold_slab_id_after then

		open c_jai_slab_start_amt(ln_threshold_slab_id_after);
		fetch c_jai_slab_start_amt into r_jai_slab_start_amt_after;
		close c_jai_slab_start_amt;

		open c_jai_slab_start_amt(ln_threshold_slab_id_before);
		fetch c_jai_slab_start_amt into r_jai_slab_start_amt_before;
		close c_jai_slab_start_amt;

		if ln_threshold_slab_id_before <> 0 and r_jai_slab_start_amt_before.tax_rate_orig <> r_jai_slab_start_amt_after.tax_rate_orig then
		ln_tds_amt_before := r_jai_slab_start_amt_after.from_amount - ln_total_invoice_amount;
		ln_tds_amt_after := cur_rec.taxable_amount - ln_tds_amt_before;

		ln_tds_tax_amount := (ln_tds_amt_before*(nvl(r_jai_slab_start_amt_before.tax_rate, 0)/100))
						 + (ln_tds_amt_after*(nvl(r_jai_slab_start_amt_after.tax_rate, 0)/100));
        end if;
		end if;
		/*END, Bgowrava for Bug#8254510 */

          ln_threshold_trx_id := 0;
          lv_tds_invoice_num  := null;
          lv_tds_cm_num       := null;
          p_process_flag      := null;

          fnd_file.put_line(FND_FILE.LOG, '20. Call generate tds invoices' );

	  fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - tax amount while calling generate tds invoices '|| cur_rec.tax_amount);

          jai_ap_tds_generation_pkg.generate_tds_invoices
          (
            pn_invoice_id              =>      p_invoice_id           ,
            pn_threshold_hdr_id        =>      ln_threshold_hdr_id    ,
            pn_taxable_amount          =>      cur_rec.taxable_amount ,
            pn_tax_amount              =>      ln_tds_tax_amount     ,  --Added by Bgowrava for Bug#8254510
            pn_tax_id                  =>      cur_rec.actual_tax_id  ,
            pd_accounting_date         =>      p_accounting_date      ,
            pv_tds_event               =>      'INVOICE VALIDATE'     ,
            pn_threshold_grp_id        =>      ln_threshold_grp_id    ,
            pv_tds_invoice_num         =>      lv_tds_invoice_num     ,
            pv_cm_invoice_num          =>      lv_tds_cm_num          ,
            pn_threshold_trx_id        =>      ln_threshold_trx_id    ,
            -- Bug 5722028. Added by CSahoo
	    			pd_creation_date           =>      p_creation_date        ,
            p_process_flag             =>      p_process_flag         ,
            p_process_message          =>      p_process_message
          );


          if p_process_flag = 'E' then
     fnd_file.put_line(FND_FILE.LOG, '20 Process flag '|| p_process_flag);
           fnd_file.put_line(FND_FILE.LOG, '20 Process message '|| p_process_message);
           p_codepath := jai_general_pkg.plot_codepath(21, p_codepath); /* 21 */
           goto exit_from_procedure;
          end if;

          p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); /* 22 */

          if ln_start_threshold_trx_id is null then
            ln_start_threshold_trx_id := ln_threshold_trx_id;
          end if;

          fnd_file.put_line(FND_FILE.LOG,' 22. start thhold trx id '||
                                               ln_start_threshold_trx_id);

      /* Bug 7280925. Added by Lakshmi Gopalsami -- can be removed
	   * Need to round the value before calling maintain_thhold_grps

          IF trunc(p_creation_date) >=
	    trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
	    ln_tmp_tds_amt := get_rnded_value(cur_rec.tax_amount);
 	  END IF;
 	  */

	  fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - value of tmp tds before maintain thhold grps'||ln_tax_amount);

          /* Update the total tax amount for which invoice was raised */

          /* bug 7280925. Added by Lakshmi Gopalsami
         * changed from ln_tmp_tds_amt to ln_tax_amount
         */
          p_codepath := jai_general_pkg.plot_codepath(23, p_codepath); /* 23 */

           jai_ap_tds_generation_pkg.maintain_thhold_grps
           (
              p_threshold_grp_id             =>   ln_threshold_grp_id,
              p_trx_tax_paid                 =>   ln_tds_tax_amount,
              p_tds_event                    =>   'INVOICE VALIDATE', --Added by Bgowrava for Bug#8254510
              p_invoice_id                   =>   p_invoice_id,
              p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
              -- Bug 5722028. Added by Lakshmi Gopalsami
	      			p_creation_date                =>   p_creation_date,
              p_process_flag                 =>   p_process_flag,
              P_process_message              =>   P_process_message,
              p_codepath                     =>   p_codepath
            );

          fnd_file.put_line(FND_FILE.LOG, '23 Process flag '|| p_process_flag);
          fnd_file.put_line(FND_FILE.LOG, '23 Process message '|| p_process_message);

	--Added by Sanjikum for Bug#5131075(4722011)
	IF p_process_flag = 'E' THEN
		p_codepath := jai_general_pkg.plot_codepath(23.1, p_codepath); /* 23.1 */
		goto exit_from_procedure;
	END IF;


          /* Punch threshold_trx_id in jai_ap_tds_inv_taxes */
          update  jai_ap_tds_inv_taxes
          set     threshold_trx_id =  ln_threshold_trx_id,
                  threshold_slab_id_single = ln_threshold_slab_id_single
          where   invoice_id = p_invoice_id
          and     section_type      =  lv_tds_section_type   --rchandan for bug#4428980
          and     actual_section_code = cur_rec_section.actual_section_code
          and     nvl(actual_tax_id, default_tax_id) = cur_rec.actual_tax_id   --Added nvl by Xiao for bug#7154864
          and     (
                    (lv_generate_all_invoices = 'Y' )
                     or
                    (ln_threshold_slab_id_single > 0)
                    or
                    (actual_tax_id is NOT NULL) --added by Xiao for bug#7154864
                  );

         ln_no_of_tds_inv_generated := ln_no_of_tds_inv_generated + 2;
         /* TDS invoices are always generated in pair */

        p_codepath := jai_general_pkg.plot_codepath(24, p_codepath); /* 24 */
        end loop;
        /* Loop and generate invoices */

        p_codepath := jai_general_pkg.plot_codepath(25, p_codepath); /* 25 */
        update  jai_ap_tds_inv_taxes
        set     threshold_grp_id   =  ln_threshold_grp_id,
                threshold_hdr_id   =  ln_threshold_hdr_id,
                threshold_slab_id  =  ln_threshold_slab_id_after,
                process_status = 'P'
        where   invoice_id = p_invoice_id
        and     section_type = lv_tds_section_type --rchandan for bug#4428980
        and     actual_section_code = cur_rec_section.actual_section_code;

        if ln_threshold_slab_id_before <> ln_threshold_slab_id_after then
          /* Transition in threshold has happened */
          p_codepath := jai_general_pkg.plot_codepath(26, p_codepath); /* 26 */

    --4407184
    lv_slab_transition_tds_event :=  'THRESHOLD TRANSITION(from slab id -' || ln_threshold_slab_id_before ||
                                          'to slab id - ' || ln_threshold_slab_id_after || ')';

    fnd_file.put_line(FND_FILE.LOG, '26.  Call process transition ');
    fnd_file.put_line(FND_FILE.LOG, '26. Event is '|| lv_slab_transition_tds_event);

    process_threshold_transition
          (
            p_threshold_grp_id    =>      ln_threshold_grp_id,
            p_threshold_slab_id   =>      ln_threshold_slab_id_after,
            p_invoice_id          =>      p_invoice_id,
            p_vendor_id           =>      p_vendor_id,
            p_vendor_site_id      =>      p_vendor_site_id,
            p_accounting_date     =>      p_accounting_date,
            p_tds_event           =>      lv_slab_transition_tds_event,
            p_org_id              =>      p_org_id,
            pv_tds_invoice_num    =>      lv_tds_invoice_num,
            pv_cm_invoice_num     =>      lv_tds_cm_num,
            p_process_flag        =>      p_process_flag,
            p_process_message     =>      p_process_message
          );

          if p_process_flag = 'E' then
          fnd_file.put_line(FND_FILE.LOG, '27 Process flag '|| p_process_flag);
          fnd_file.put_line(FND_FILE.LOG, '27 Process message '|| p_process_message);

            p_codepath := jai_general_pkg.plot_codepath(27, p_codepath); /* 27 */
            goto exit_from_procedure;
          end if;
          ln_no_of_tds_inv_generated := ln_no_of_tds_inv_generated + 2;
          p_codepath := jai_general_pkg.plot_codepath(28, p_codepath); /* 28 */
        end if;

        p_codepath := jai_general_pkg.plot_codepath(29, p_codepath); /* 29 */
      end loop;

      /* End Loop through for each tds section and process */

      p_codepath := jai_general_pkg.plot_codepath(30, p_codepath); /* 30 */
      /* Check if any non-TDS Section taxes are applicable and generate invoices if required. */
      for cur_non_tds_rec in c_get_non_tds_section_tax(p_invoice_id, ln_exchange_rate,'TDS_SECTION') LOOP    --rchandan for bug#4428980

        p_codepath := jai_general_pkg.plot_codepath(31, p_codepath); /* 31 */
        ln_threshold_trx_id := null;
        lv_tds_invoice_num  := null;
        lv_tds_cm_num       := null;
        p_process_flag      := null;

        fnd_file.put_line(FND_FILE.LOG, '31 Call generate tds invoices ');

        fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - WCT Tax amt '||cur_non_tds_rec.tax_amount);

        jai_ap_tds_generation_pkg.generate_tds_invoices
        (
          pn_invoice_id              =>      p_invoice_id                   ,
          pn_threshold_hdr_id        =>      ln_threshold_hdr_id    ,
          pn_taxable_amount          =>      cur_non_tds_rec.taxable_amount ,
          pn_tax_amount              =>      cur_non_tds_rec.tax_amount     ,
          pn_tax_id                  =>      cur_non_tds_rec.actual_tax_id  ,
          pd_accounting_date         =>      p_accounting_date      ,
          pv_tds_event               =>      'INVOICE VALIDATE'     ,
          pn_threshold_grp_id        =>      null    ,
          pv_tds_invoice_num         =>      lv_tds_invoice_num     ,
          pv_cm_invoice_num          =>      lv_tds_cm_num          ,
          pn_threshold_trx_id        =>      ln_threshold_trx_id    ,
          -- Bug 5722028. Added by csahoo
	  pd_creation_date           =>      p_creation_date        ,
          p_process_flag             =>      p_process_flag         ,
          p_process_message          =>      p_process_message
        );

        if p_process_flag = 'E' then
          fnd_file.put_line(FND_FILE.LOG, '31 Process flag '|| p_process_flag);
          fnd_file.put_line(FND_FILE.LOG, '31 Process message '|| p_process_message);

          p_codepath := jai_general_pkg.plot_codepath(32, p_codepath); /* 32 */
          goto exit_from_procedure;
        end if;

        p_codepath := jai_general_pkg.plot_codepath(33, p_codepath); /* 33 */

        if ln_start_threshold_trx_id is null then
          p_codepath := jai_general_pkg.plot_codepath(34, p_codepath); /* 34 */
          ln_start_threshold_trx_id := ln_threshold_trx_id;
        end if;

        fnd_file.put_line(FND_FILE.LOG, '34. Start thhold trx id '|| ln_start_threshold_trx_id);

        /* Punch threshold_trx_id in jai_ap_tds_inv_taxes */
        update  jai_ap_tds_inv_taxes
        set     threshold_trx_id =  ln_threshold_trx_id,
				process_status   = 'P' /*Bug 4667681*/
        where   invoice_id       =  p_invoice_id
        and     section_type     =  cur_non_tds_rec.section_type
        and     actual_tax_id    =  cur_non_tds_rec.actual_tax_id;

      end loop; /* cur_non_tds_rec */


      p_codepath := jai_general_pkg.plot_codepath(35, p_codepath); /* 35 */


      /* If the process is called from batch do not fire import request */

      fnd_file.put_line(FND_FILE.LOG, '35. called from '|| p_call_from);

      if p_call_from <> 'BATCH' then
        /* Not Called from Batch */

        p_codepath := jai_general_pkg.plot_codepath(36, p_codepath); /* 36 */

        if ln_start_threshold_trx_id is not null then

    fnd_file.put_line(FND_FILE.LOG, '36 start thhold trx id '||
                                                ln_start_threshold_trx_id);

          p_codepath := jai_general_pkg.plot_codepath(37, p_codepath); /* 37 */
          import_and_approve
          (
            p_invoice_id                   =>     p_invoice_id,
            p_start_thhold_trx_id          =>     ln_start_threshold_trx_id,
            p_tds_event                    =>     'INVOICE VALIDATE',
            p_process_flag                 =>     p_process_flag,
            p_process_message              =>     p_process_message
          );

    			fnd_file.put_line(FND_FILE.LOG, '37 Process flag '|| p_process_flag);
          fnd_file.put_line(FND_FILE.LOG, '37 Process message '|| p_process_message);

          --Added by Sanjikum for Bug#5131075(4722011)
          IF p_process_flag = 'E' THEN
            p_codepath := jai_general_pkg.plot_codepath(37.1, p_codepath); /* 37.1 */
            goto exit_from_procedure;
          END IF;

        end if; /* if ln_no_of_tds_inv_generated > 0 then  */

      end if; /*   p_call_from <> 'BATCH'  then */

      <<exit_from_procedure>>
      p_codepath := jai_general_pkg.plot_codepath(100, p_codepath); /* 100 */
      return;

    exception
      when others then
	    /*Added below by Bgowrava for Bug#8716477 */
        p_process_flag := 'E';
        P_process_message := 'jai_ap_tds_generation_pkg.process_tds_at_inv_validate :' ||  sqlerrm;
        return;
    end process_tds_at_inv_validate;
  /* ************************************* process_tds_at_inv_validate ************************************ */

  /* *********************************** procedure generate_tds_invoices ********************************** */

procedure generate_tds_invoices
  (
    pn_invoice_id                         in                 number,
    pn_invoice_line_number                in                 number   default null, /* AP lines  */
    pn_invoice_distribution_id            in                 number   default null, /* Prepayment apply / unapply scenario */
    pv_invoice_num_prepay_apply           in                 varchar2 default null, /* Prepayment application secanrio */
    pv_invoice_num_to_tds_apply           in                 varchar2 default null, /* Prepayment unapplication secanrio */
    pv_invoice_num_to_vendor_apply        in                 varchar2 default null, /* Prepayment unapplication secanrio */
    pv_invoice_num_to_vendor_can          in                 varchar2 default null, /* Invoice Cancel Secnario */
    pn_threshold_hdr_id                   in                 number   default null, /* For validate scenario only */
    pn_taxable_amount                     in                 number,
    pn_tax_amount                         in                 number,
    pn_tax_id                             in                 number,
    pd_accounting_date                    in                 date,
    pv_tds_event                          in                 varchar2,
    pn_threshold_grp_id                   in                 number,
    pv_tds_invoice_num                    out      nocopy    varchar2,
    pv_cm_invoice_num                     out      nocopy    varchar2,
    pn_threshold_trx_id                   out      nocopy    number,
    -- Bug 5722028. Added by csahoo
    pd_creation_date                      in                 date,
    p_process_flag                        out      nocopy    varchar2,
    p_process_message                     out      nocopy    varchar2
  )
  is

  cursor c_ap_invoices_all(cp_invoice_id number) is
    select  invoice_num,
            vendor_id,
            vendor_site_id,
            invoice_currency_code,
            exchange_rate_type,
            exchange_date,
            terms_id,
            payment_method_lookup_code,
            pay_group_lookup_code,
            invoice_date,
            goods_received_date,
            invoice_received_date,
            org_id,
            nvl(exchange_rate, 1) exchange_rate,
            set_of_books_id,
            payment_method_code -- Bug 7109056
    from    ap_invoices_all
    where   invoice_id = cp_invoice_id;

  cursor c_po_vendor_sites_all(cp_vendor_id  number, cp_vendor_site_id number) is
    select  terms_id,
            --payment_method_lookup_code, --commented by Sanjikum for Bug#4482462
            pay_group_lookup_code
    from    po_vendor_sites_all
    where   vendor_id = cp_vendor_id
    and     vendor_site_id = cp_vendor_site_id;

  cursor c_po_vendors(cp_vendor_id  number) is
    select  terms_id,
            --payment_method_lookup_code, --commented by Sanjikum for Bug#4482462
            pay_group_lookup_code
    from    po_vendors
    where   vendor_id = cp_vendor_id;


  cursor c_ja_in_tax_codes (pn_tax_id number) is
    select  section_code,
            vendor_id,
            vendor_site_id,
            tax_rate,
            stform_type,
            tax_account_id,
            section_type
    from    JAI_CMN_TAXES_ALL
    where   tax_id = pn_tax_id;


  cursor c_gl_sets_of_books(cp_set_of_books_id  number) is
    select currency_code
    from   gl_sets_of_books
    where  set_of_books_id = cp_set_of_books_id;

  cursor c_get_ja_in_ap_inv_id is
    select to_char(JAI_AP_TDS_THHOLD_TRXS_S1.nextval)--to_char(JAI_AP_TDS_INVOICE_NUM_S.nextval)commented by  rchandan for bug#4487676
    from  dual;

  cursor c_ap_payment_schedules_all(p_invoice_id number) is
    select payment_priority
    from   ap_payment_schedules_all
    where  invoice_id = p_invoice_id;

  r_ap_invoices_all               c_ap_invoices_all%rowtype;
  r_ja_in_tax_codes               c_ja_in_tax_codes%rowtype;
  r_po_vendor_sites_all           c_po_vendor_sites_all%rowtype;
  r_po_vendors                    c_po_vendors%rowtype;
  r_gl_sets_of_books              c_gl_sets_of_books%rowtype;
  r_ap_payment_schedules_all      c_ap_payment_schedules_all%rowtype;


  lv_source                       varchar2(30); --File.Sql.35 Cbabu  := 'TDS';

  lv_invoice_to_tds_num           ap_invoices_all.invoice_num%type;
  lv_invoice_to_vendor_num        ap_invoices_all.invoice_num%type;

  lv_invoice_to_tds_type          ap_invoices_all.invoice_type_lookup_code%type;
  lv_invoice_to_vendor_type       ap_invoices_all.invoice_type_lookup_code%type;

  ln_invoice_to_tds_id            ap_invoices_all.invoice_id%type;
  ln_invoice_to_vendor_id         ap_invoices_all.invoice_id%type;

  ln_invoice_to_tds_line_id       ap_invoice_lines_interface.invoice_line_id%type;
  ln_invoice_to_vendor_line_id    ap_invoice_lines_interface.invoice_line_id%type;

  lv_invoice_to_tds_line_type     ap_invoice_distributions_all.line_type_lookup_code%type; --File.Sql.35 Cbabu  := 'ITEM';
  lv_invoice_to_vendor_line_type  ap_invoice_distributions_all.line_type_lookup_code%type; --File.Sql.35 Cbabu  := 'ITEM';

  ln_invoice_to_tds_amount        number;
  ln_invoice_to_vendor_amount     number;

  ln_exchange_rate                number;
  lv_this_procedure               varchar2(50); --File.Sql.35 Cbabu  := 'jaiap.generate_tds_invoice';

  ln_terms_id                     po_vendors.terms_id%type;
  -- lv_payment_method_lookup_code   po_vendors.payment_method_lookup_code%type; --commented by Sanjikum for Bug#4482462
  lv_pay_group_lookup_code        po_vendors.pay_group_lookup_code%type;

  lv_ja_in_ap_inv_id              varchar2(15);
  ld_accounting_date              date;
  lv_open_period                  ap_invoice_distributions_all.period_name%type;
  ln_tax_amount                   number;

  lv_invoice_num                  ap_invoices_all.invoice_num%type;
  lv_source_attribute             jai_ap_tds_invoices.source_attribute%TYPE ;   --rchandan for bug#4428980

  ln_invoice_amount               ap_invoices_all.invoice_amount%TYPE; --Added by Ramananda for Bug#4562801

 	lv_group_id                     VARCHAR2(80); --Added by Sanjikum for Bug#5131075(4722011)

 	/* Bug 5722028. Added by Lakshmi Gopalsami
	 * Added following variables
	 */
	ln_tds_rnded_amt      NUMBER;
	ln_tds_mod_value      NUMBER;
	ln_tds_rnding_factor  NUMBER;

  lv_section_name varchar2(10); --Added for Bug# 7410219
pv_invoice_date   DATE;  --Added by Bgowrava for Bug#9186263

begin

  lv_source                        := 'INDIA TDS'; /* --:= 'TDS'; --Ramanand for bug#4388958 */
  lv_invoice_to_tds_line_type     := 'ITEM';
  lv_invoice_to_vendor_line_type  := 'ITEM';
  lv_this_procedure               := 'jaiap.generate_tds_invoice';


  /* Amount to be paid to TDS Authority should always be +ve */
  /* In case of prepayment application, this is still passed as +ve amount */

  /* Bug 4513458. added by Lakshmi Gopalsami
   * Removed the rounding and assigned the exact amount
   * and the rounding is handled at later point to
   * accommodate the currency code
  */
  --ln_tax_amount := round(pn_tax_amount, 2);
  ln_tax_amount := pn_tax_amount;

  /* Bug 4522507. Added by Lakshmi Gopalsami
     Checked whether round(ln_tax_amount) is less than
     zero instead of ln_tax_amount */
  if round(ln_tax_amount,2) <= 0 then
    p_process_flag := 'X';
    p_process_message := 'TDS amount must be greater than 0 ';
    goto exit_from_procedure;
  end if;

  open  c_ap_invoices_all(pn_invoice_id);
  fetch c_ap_invoices_all into r_ap_invoices_all;
  close c_ap_invoices_all;

  /*
  || moved this up from the under the cursor - c_po_vendor_sites_all by Ramananda for Bug#4562793
  */
  open  c_ja_in_tax_codes(pn_tax_id);
  fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
  close c_ja_in_tax_codes;

  /*
  || open c_po_vendors(r_ap_invoices_all.vendor_id);
  || Commented the above and added the below by Ramananda for Bug#4562793
  */
  open c_po_vendors(r_ja_in_tax_codes.vendor_id);
  fetch c_po_vendors into r_po_vendors;
  close c_po_vendors;

  /*
  || open  c_po_vendor_sites_all(r_ap_invoices_all.vendor_id, r_ap_invoices_all.vendor_site_id);
  || Commented the above and added the below by sanjikum for Bug#4562793
  */
  open  c_po_vendor_sites_all(r_ja_in_tax_codes.vendor_id, r_ja_in_tax_codes.vendor_site_id);
  fetch c_po_vendor_sites_all into r_po_vendor_sites_all;
  close c_po_vendor_sites_all;

  open  c_gl_sets_of_books(r_ap_invoices_all.set_of_books_id);
  fetch c_gl_sets_of_books into r_gl_sets_of_books;
  close c_gl_sets_of_books;

  /*Bug # 7410219 - Derive the Section Name*/
  if (r_ja_in_tax_codes.section_type = 'TDS_SECTION') then
     lv_section_name := 'TDS';
  elsif (r_ja_in_tax_codes.section_type = 'WCT_SECTION') then
     lv_section_name := 'WCT';
  elsif (r_ja_in_tax_codes.section_type = 'ESSI_SECTION') then
     lv_section_name := 'ESSI';
  end if;
  /*Bug # 7410219 - End*/

  /* Get the payment details from the vendor site */
  ln_terms_id                   := r_po_vendor_sites_all.terms_id;
  -- lv_payment_method_lookup_code := r_po_vendor_sites_all.payment_method_lookup_code;--commented by Sanjikum for Bug#4482462
  lv_pay_group_lookup_code      := r_po_vendor_sites_all.pay_group_lookup_code;


  if (
        ln_terms_id is null or
        -- lv_payment_method_lookup_code is null or --commented by Sanjikum for Bug#4482462
        lv_pay_group_lookup_code is null
     )
  then

    /* Get the payment details from the vendor as it has been not defined for the site */
    ln_terms_id                   := r_po_vendors.terms_id;
    -- lv_payment_method_lookup_code := r_po_vendors.payment_method_lookup_code; --commented by Sanjikum for Bug#4482462
    lv_pay_group_lookup_code      := r_po_vendors.pay_group_lookup_code;

  end if;


  /* Get the unique number to suffix the tds invoices with */
  open c_get_ja_in_ap_inv_id;
  fetch c_get_ja_in_ap_inv_id into lv_ja_in_ap_inv_id;
  close c_get_ja_in_ap_inv_id;

  lv_invoice_num := substr(r_ap_invoices_all.invoice_num, 1, 30);

  /* Invoice Numbers, type  for the invoice pair that is being created */
  if ( (pv_tds_event = 'INVOICE VALIDATE') or (pv_tds_event like 'THRESHOLD TRANSITION%') ) then

    /* Standard invoice to TDS authority, Credit memo to supplier */

    lv_invoice_to_tds_type := 'STANDARD';
    lv_invoice_to_vendor_type := 'CREDIT';
    /*Bug 7410219 - Modified Invoice Number as per Section*/
    lv_invoice_to_tds_num     := lv_invoice_num ||'-'||lv_section_name||'-SI-'||lv_ja_in_ap_inv_id;
    lv_invoice_to_vendor_num := lv_invoice_num ||'-'||lv_section_name||'-CM-'||lv_ja_in_ap_inv_id;

    ln_invoice_to_tds_amount :=  ln_tax_amount;
    ln_invoice_to_vendor_amount := (-1) * ln_tax_amount;

  elsif pv_tds_event = 'PREPAYMENT APPLICATION' OR pv_tds_event like 'THRESHOLD ROLLBACK%' then --Added by Sanjikum for Bug#5131075(4718907)

    /* Credit memo to TDS authority, Standard invoice to supplier */
    if pv_invoice_num_prepay_apply is not null then
      lv_invoice_num := substr(pv_invoice_num_prepay_apply, 1, 30);
    end if;

    lv_invoice_to_tds_type := 'CREDIT';
    lv_invoice_to_vendor_type := 'STANDARD';
    /*Bug 7410219 - Modified Invoice Number as per Section*/
    lv_invoice_to_tds_num     := lv_invoice_num ||'-RTN-'||lv_section_name||'-CM-'||lv_ja_in_ap_inv_id;
    lv_invoice_to_vendor_num  := lv_invoice_num ||'-RTN-'||lv_section_name||'-SI-'||lv_ja_in_ap_inv_id;

    ln_invoice_to_tds_amount :=  -1 * ln_tax_amount;
    ln_invoice_to_vendor_amount :=  ln_tax_amount;

  elsif pv_tds_event = 'PREPAYMENT UNAPPLICATION' then

    /* Standard invoice to TDS authority, Credit memo to supplier */
    lv_invoice_to_tds_type := 'STANDARD';
    lv_invoice_to_vendor_type := 'CREDIT';

    if pv_invoice_num_to_tds_apply is not null then
      lv_invoice_to_tds_num    := 'CAN/' || substr(pv_invoice_num_to_tds_apply, 1, 45);
    else
      /*Bug 7410219 - Modified Invoice Number as per Section*/
      lv_invoice_to_tds_num    := lv_invoice_num ||'-RTN-'||lv_section_name||'-SI-'||lv_ja_in_ap_inv_id;
    end if;

    if pv_invoice_num_to_vendor_apply is not null then
      lv_invoice_to_vendor_num := 'CAN/' || substr(pv_invoice_num_to_vendor_apply, 1, 45);
    else
      /*Bug 7410219 - Modified Invoice Number as per Section*/
      lv_invoice_to_vendor_num := lv_invoice_num ||'-RTN-'||lv_section_name||'-CM-'||lv_ja_in_ap_inv_id;
    end if;

    ln_invoice_to_tds_amount :=  ln_tax_amount;
    ln_invoice_to_vendor_amount := (-1) * ln_tax_amount;

  elsif pv_tds_event = 'INVOICE CANCEL' then

      /* No invoice to TDS authority, Standard invoice to supplier */

      lv_invoice_to_tds_num     := null;

      if pv_invoice_num_to_vendor_can is not null then
        lv_invoice_to_vendor_num := 'CAN/' || substr(pv_invoice_num_to_vendor_can, 1, 45);
      else
        /*Bug 7410219 - Modified Invoice Number as per Section*/
        lv_invoice_to_vendor_num := lv_invoice_num||'-CAN-'||lv_section_name||'-SI-'||lv_ja_in_ap_inv_id;
      end if;

      lv_invoice_to_tds_type := null;
      lv_invoice_to_vendor_type := 'STANDARD';

      ln_invoice_to_tds_amount :=  null;
      ln_invoice_to_vendor_amount := ln_tax_amount;

/*START, Bgowrava for Bug#8254510*/
  elsif ( pv_tds_event = 'SURCHARGE_CALCULATE') then

	    /* Standard invoice to TDS authority, Credit memo to supplier */

	    lv_invoice_to_tds_type := 'STANDARD';
	    lv_invoice_to_vendor_type := 'CREDIT';

	    lv_invoice_to_tds_num     := lv_invoice_num ||'-SUR-SI-'||lv_ja_in_ap_inv_id;
	    lv_invoice_to_vendor_num := lv_invoice_num ||'-SUR-CM-'||lv_ja_in_ap_inv_id;

	    ln_invoice_to_tds_amount :=  ln_tax_amount;
    ln_invoice_to_vendor_amount := (-1) * ln_tax_amount;
/*END,  Bgowrava for Bug#8254510*/

  end if; /* TDS event type */

  pv_tds_invoice_num := lv_invoice_to_tds_num;
  pv_cm_invoice_num  := lv_invoice_to_vendor_num;

  /* Check if the given date is in current open period */

  /* Bug 4559756. Added by Lakshmi Gopalsami
     Added org_id to ap_utilities_pkg
  */
  lv_open_period:=  ap_utilities_pkg.get_current_gl_date
                                     (pd_accounting_date,
              r_ap_invoices_all.org_id
              );

  /* Bug 4559756. Added by Lakshmi Gopalsami
     Added org_id to ap_utilities_pkg
  */

  if lv_open_period is null then

    ap_utilities_pkg.get_open_gl_date
    (
      pd_accounting_date,
      lv_open_period,
      ld_accounting_date,
      r_ap_invoices_all.org_id
    );

    if lv_open_period is null then
      p_process_flag := 'E';
      p_process_message := 'No open accounting Period after : ' || pd_accounting_date ;
      goto exit_from_procedure;
    end if;

    else
      ld_accounting_date := pd_accounting_date;
    end if; /* ld_accounting_date */

    --Added by Sanjikum for Bug#5131075(4722011)
    IF pv_tds_event = 'PREPAYMENT APPLICATION' OR pv_tds_event = 'PREPAYMENT UNAPPLICATION' THEN
      lv_group_id := to_char(pn_invoice_id)||pv_tds_event;
	  pv_invoice_date := ld_accounting_date;   --Added by Bgowrava for Bug#9186263
    ELSE
      lv_group_id := to_char(pn_invoice_id);
	  pv_invoice_date := r_ap_invoices_all.invoice_date;  --Added by Bgowrava for Bug#9186263
    END IF;


    /* Invoice to TDS Authority */
    /* Bug 4513458. Added by Lakshmi Gopalsami
     * Rounded the amount to zero as the TDS invoice amount should
     * be in INR currency */

   -- ln_invoice_to_tds_amount := ROUND(ln_invoice_to_tds_amount,0);
   /* Bug 5722028. Added by csahoo
    * Rounded depending on the setup.
    */
      IF pv_tds_event NOT IN
        -- Bug 7280925. Commented by Lakshmi Gopalsami ('INVOICE CANCEL',
           ('PREPAYMENT UNAPPLICATION')
      THEN
       ln_invoice_to_tds_amount := ROUND(ln_invoice_to_tds_amount,g_inr_currency_rounding);
        fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - value before round '||ln_invoice_to_tds_amount);
	IF trunc(pd_creation_date) >= trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date)
        /* Bug 7280925. Added by Lakshmi Gopalsami
	 * we should not round for WCT and ESSI. For those threshold_grp_id
	 * will be null
	 */
         and pn_threshold_grp_id is not null
	THEN
	  ln_invoice_to_tds_amount := get_rnded_value(ln_invoice_to_tds_amount);
        fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - value after round per setup TDS auth inv'||ln_invoice_to_tds_amount);
	END IF;
      END IF ; -- pv_tds_event  not in

    -- End for Bug 5722028

    --if lv_invoice_to_tds_num is not null and lv_invoice_to_tds_type is not null then
	--commented the above and added the below by bgowrava  for bug#4549019
	if lv_invoice_to_tds_num is not null and lv_invoice_to_tds_type is not null and NVL(ln_invoice_to_tds_amount,0) <> 0 then

      /* Generate the Invoice for the TDS authority - always in functional currency - INR  */

      jai_ap_utils_pkg.insert_ap_inv_interface
      (
        p_jai_source                        => lv_this_procedure,
        p_invoice_id                        => ln_invoice_to_tds_id,
        p_invoice_num                       => lv_invoice_to_tds_num,
        p_invoice_type_lookup_code          => lv_invoice_to_tds_type,
        p_invoice_date                      => pv_invoice_date, --ld_accounting_date,  --Modified by Bgowrava for Bug#9186263
		p_gl_date                           => ld_accounting_date, --Added by Bgowrava for Bug#9186263
        p_vendor_id                         => r_ja_in_tax_codes.vendor_id,
        p_vendor_site_id                    => r_ja_in_tax_codes.vendor_site_id,
        p_invoice_amount                    => ln_invoice_to_tds_amount,
        p_invoice_currency_code             => r_gl_sets_of_books.currency_code,
        p_exchange_rate                     => null,
        p_exchange_rate_type                => null,
        p_exchange_date                     => null,
        p_terms_id                          => ln_terms_id,
        p_description                       => lv_invoice_to_tds_num,
        p_last_update_date                  => sysdate,
        p_last_updated_by                   => fnd_global.user_id,
        p_last_update_login                 => fnd_global.login_id,
        p_creation_date                     => sysdate,
        p_created_by                        => fnd_global.user_id,
        p_source                            => lv_source,
        p_voucher_num                       => lv_invoice_to_tds_num,
        --p_payment_method_lookup_code        => lv_payment_method_lookup_code,
        --commented by Sanjikum for Bug#4482462
        p_pay_group_lookup_code             => lv_pay_group_lookup_code,
        p_org_id                            => r_ap_invoices_all.org_id,
        p_attribute_category                => 'India Original Invoice for TDS',
        p_attribute1                        => pn_invoice_id,
	--added the below by Sanjikum for Bug#5131075(4722011)
        p_group_id                          => lv_group_id -- Bug# 6119216, changed to lv_group_id instead of to_char(p_invoice_id)
      );

      /* Lines Interface */
      jai_ap_utils_pkg.insert_ap_inv_lines_interface
      (
        p_jai_source                        => lv_this_procedure,
        p_invoice_id                        => ln_invoice_to_tds_id,
        p_invoice_line_id                   => ln_invoice_to_tds_line_id,
        p_line_number                       => 1,
        p_line_type_lookup_code             => lv_invoice_to_tds_line_type,
        p_amount                            => ln_invoice_to_tds_amount,
        p_accounting_date                   => ld_accounting_date,
        p_description                       => lv_invoice_to_tds_num,
        p_dist_code_combination_id          => r_ja_in_tax_codes.tax_account_id,
        p_last_update_date                  => sysdate,
        p_last_updated_by                   => fnd_global.user_id,
        p_last_update_login                 => fnd_global.login_id,
        p_creation_date                     => sysdate,
        p_created_by                        => fnd_global.user_id
      );

    end if; /* Invoice to TDS authority */



    /* Invoice to Supplier */

    if lv_invoice_to_vendor_num is not null and lv_invoice_to_vendor_type is not null then

      /* Generate the TDS invoice for the supplier  in supplier invoice currency */

      /* Bug 5722028. Added by csahoo
       * Rounded depending on the setup.
       */
     IF pv_tds_event NOT IN
         -- Bug 7280925. Commented by Lakshmi Gopalsami ('INVOICE CANCEL',
           ('PREPAYMENT UNAPPLICATION') THEN
       if r_ap_invoices_all.invoice_currency_code <> r_gl_sets_of_books.currency_code  then
	   /*START, Bgowrava for Bug#8995604 , Adding below IF statement to round the INR TDS CM invoice to
			        the TDS rounding factor before converting it to a foreign currency CM*/
		ln_invoice_to_vendor_amount := round( ln_invoice_to_vendor_amount, g_inr_currency_rounding);
		IF trunc(pd_creation_date) >= trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date)
           and pn_threshold_grp_id is not null THEN
		    ln_invoice_to_vendor_amount := get_rnded_value(ln_invoice_to_vendor_amount);
		END IF;
	   /*END, Bgowrava for Bug#8995604 */
	  ln_invoice_to_vendor_amount := round( ln_invoice_to_vendor_amount / r_ap_invoices_all.exchange_rate, g_fcy_currency_rounding);
       ELSE
	  ln_invoice_to_vendor_amount := round( ln_invoice_to_vendor_amount, g_inr_currency_rounding);
	  /*START, Bgowrava for Bug#8995604 , Adding below IF statement to round the INR TDS CM invoice to   the TDS rounding factor*/
		IF trunc(pd_creation_date) >= trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date)
		   and pn_threshold_grp_id is not null THEN
		    ln_invoice_to_vendor_amount := get_rnded_value(ln_invoice_to_vendor_amount);
        END IF;
      /*END, Bgowrava for Bug#8995604 */
       end if;
         fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - value before round '||ln_invoice_to_vendor_amount);
       /*IF trunc(pd_creation_date) >=
          trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date)
                and pn_threshold_grp_id is not null
       THEN
	  ln_invoice_to_vendor_amount := get_rnded_value(ln_invoice_to_vendor_amount);
        fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - value after round per setup - vendor invoice'||ln_invoice_to_vendor_amount);
       END IF; */  --commented by bgowrava for Bug#8995604
     END IF;

      if upper(r_ap_invoices_all.exchange_rate_type) = 'USER' then
        ln_exchange_rate := r_ap_invoices_all.exchange_rate;
      else
        ln_exchange_rate := null;
      end if;

      fnd_file.put_line(FND_FILE.LOG, ' CALL utils for inserting interface lines');

IF NVL(ln_invoice_to_vendor_amount,0) <> 0 THEN --condition added by bgowrava  for bug#4549019
      /* Invoices Interface */
      jai_ap_utils_pkg.insert_ap_inv_interface
      (
        p_jai_source                        => lv_this_procedure,
        p_invoice_id                        => ln_invoice_to_vendor_id,
        p_invoice_num                       => lv_invoice_to_vendor_num,
        p_invoice_type_lookup_code          => lv_invoice_to_vendor_type,
        p_invoice_date                      => pv_invoice_date,--r_ap_invoices_all.invoice_date,  --Modified to ld_accounting_date for Bug#9186263
        p_gl_date                           => ld_accounting_date,
        p_vendor_id                         => r_ap_invoices_all.vendor_id,
        p_vendor_site_id                    => r_ap_invoices_all.vendor_site_id,
        p_invoice_amount                    => ln_invoice_to_vendor_amount,
        p_invoice_currency_code             => r_ap_invoices_all.invoice_currency_code,
        p_exchange_rate                     => ln_exchange_rate,
        p_exchange_rate_type                => r_ap_invoices_all.exchange_rate_type,
        p_exchange_date                     => r_ap_invoices_all.exchange_date,
        p_terms_id                          => r_ap_invoices_all.terms_id,
        p_description                       => lv_invoice_to_vendor_num,
        p_last_update_date                  => sysdate,
        p_last_updated_by                   => fnd_global.user_id,
        p_last_update_login                 => fnd_global.login_id,
        p_creation_date                     => sysdate,
        p_created_by                        => fnd_global.user_id,
        p_source                            => lv_source,
        p_voucher_num                       => lv_invoice_to_vendor_num,
        -- Bug 7109056. Added by Lakshmi Gopalsami
        p_payment_method_code        => r_ap_invoices_all.payment_method_code,
        --commented by Sanjikum for Bug#4482462
        p_pay_group_lookup_code             => r_ap_invoices_all.pay_group_lookup_code,
        p_goods_received_date               => r_ap_invoices_all.goods_received_date,
        p_invoice_received_date             => r_ap_invoices_all.invoice_received_date,
        p_org_id                            => r_ap_invoices_all.org_id,
        p_attribute_category                => 'India Original Invoice for TDS',
        p_attribute1                        => pn_invoice_id,
	--commented the above and added the below by Sanjikum for Bug#5131075(4722011)
        p_group_id                          => lv_group_id
      );

      /* Lines Interface */
      jai_ap_utils_pkg.insert_ap_inv_lines_interface
      (
        p_jai_source                        => lv_this_procedure,
        p_invoice_id                        => ln_invoice_to_vendor_id,
        p_invoice_line_id                   => ln_invoice_to_vendor_line_id,
        p_line_number                       => 1,
        p_line_type_lookup_code             => lv_invoice_to_vendor_line_type,
        p_amount                            => ln_invoice_to_vendor_amount,
        p_accounting_date                   => ld_accounting_date,
        p_description                       => lv_invoice_to_vendor_num,
        p_dist_code_combination_id          => r_ja_in_tax_codes.tax_account_id,
        p_last_update_date                  => sysdate,
        p_last_updated_by                   => fnd_global.user_id,
        p_last_update_login                 => fnd_global.login_id,
        p_creation_date                     => sysdate,
        p_created_by                        => fnd_global.user_id
      );

end if;
    end if;   /* Invoice to Supplier */

    /* Store the parent invoices payment priority as this is to be used in the credit memo generated for the supplier */
    open  c_ap_payment_schedules_all(pn_invoice_id);
    fetch c_ap_payment_schedules_all  into r_ap_payment_schedules_all;
    close c_ap_payment_schedules_all;

    /* Bug 5751783
     * Moved the assignment of ln_invoice_amount outside IF as this is used
     * in the insert to jai_ap_tds_thhold_trxs. This has to be derived irrespective
     * of the tds event.
     */

    Fnd_File.put_line(Fnd_File.LOG,  'pn_taxable_amount '||pn_taxable_amount);
    IF pn_taxable_amount IS NOT NULL THEN
       ln_invoice_amount :=  pn_taxable_amount;
    ELSE
       ln_invoice_amount := pn_tax_amount * ( 100 / r_ja_in_tax_codes.tax_rate);
    END IF;
    fnd_file.put_line(FND_FILE.LOG, ' invoice amount'|| ln_invoice_amount);

    /* For downward compatibility with the pre-cleanup code */
    if ( (pv_tds_event = 'INVOICE VALIDATE') or (pv_tds_event like 'THRESHOLD TRANSITION%') ) then

      /*
      || Added the IF-ELSE-ENDIF block by Ramananda for Bug#4562801
      */


      IF r_ja_in_tax_codes.section_type = 'TDS_SECTION' THEN --rchandan for bug#4428980
        lv_source_attribute := 'ATTRIBUTE1';
      ELSIF r_ja_in_tax_codes.section_type = 'WCT_SECTION' THEN
        lv_source_attribute := 'ATTRIBUTE2';
      ELSIF r_ja_in_tax_codes.section_type = 'ESSI_SECTION' THEN
        lv_source_attribute := 'ATTRIBUTE3';
      END IF;

      fnd_file.put_line(FND_FILE.LOG, ' invoice id '|| pn_invoice_id);
      fnd_file.put_line(FND_FILE.LOG, ' invoice amount'|| ln_invoice_amount);
      fnd_file.put_line(FND_FILE.LOG, 'invoice to tds inv num'|| lv_invoice_to_tds_num);
      fnd_file.put_line(FND_FILE.LOG, 'vendor num' ||lv_invoice_to_vendor_num);
      fnd_file.put_line(FND_FILE.LOG, 'tax id '||pn_tax_id);
      fnd_file.put_line(FND_FILE.LOG, 'tax rate'|| r_ja_in_tax_codes.tax_rate);
      fnd_file.put_line(FND_FILE.LOG, 'tds amt'||ln_invoice_to_tds_amount);
      fnd_file.put_line(FND_FILE.LOG, 'sec code '||r_ja_in_tax_codes.section_code);
      fnd_file.put_line(FND_FILE.LOG, 'stformtype '||r_ja_in_tax_codes.stform_type);
      fnd_file.put_line(FND_FILE.LOG, 'org id '|| r_ap_invoices_all.org_id);
      fnd_file.put_line(FND_FILE.LOG, 'src att'||lv_source_attribute);

	   IF NVL(ln_invoice_amount,0) <> 0 THEN --Added the condition by bgowrava for Bug#4549019
      insert into JAI_AP_TDS_INVOICES
      (TDS_INVOICE_ID,
        invoice_id,
        invoice_amount,
        tds_invoice_num,
        dm_invoice_num,
        tds_tax_id,
        tds_tax_rate,
        tds_amount,
        tds_section,
        certificate_number,
        --org_id,
        organization_id,
        source_attribute,
        /* Ramananda for bug#4560109 during R12 Sanity Testing. Added the WHO columns */
        created_by        ,
        creation_date     ,
        last_updated_by   ,
        last_update_date  ,
        last_update_login
      )
      values
      ( JAI_AP_TDS_INVOICES_S.nextval,
        pn_invoice_id,
        --round(ln_invoice_to_tds_amount * ( 100 / r_ja_in_tax_codes.tax_rate), 2),
        --commented the above and added the below by Ramananda for Bug#4562801
        ln_invoice_amount,
        lv_invoice_to_tds_num,
        lv_invoice_to_vendor_num,
        pn_tax_id,
        r_ja_in_tax_codes.tax_rate,
        ln_invoice_to_tds_amount,
        r_ja_in_tax_codes.section_code,
        r_ja_in_tax_codes.stform_type,
        --r_ap_invoices_all.org_id,
        r_ap_invoices_all.org_id,
        lv_source_attribute,  --rchandan for bug#4428980
        /* Ramananda for bug#4560109 during R12 Sanity Testing. Added the WHO columns */
        fnd_global.user_id                             ,
        sysdate                                        ,
        fnd_global.user_id                             ,
        sysdate                                        ,
        fnd_global.login_id
      );
end if;
    end if; /* Only for validate event as done in earlier regime */

    -- Bug 5722028. Added by csahoo
	ln_tds_rnding_factor := 0;
	ln_tds_rnded_amt := pn_tax_amount;
	IF pv_tds_event NOT IN
	   -- Bug 7280925. commented by Lakshmi Gopalsami ('INVOICE CANCEL',
	    ('PREPAYMENT UNAPPLICATION') THEN
  	   IF r_ap_invoices_all.invoice_currency_code = r_gl_sets_of_books.currency_code THEN
	    ln_tds_rnded_amt := ROUND(pn_tax_amount , g_inr_currency_rounding);
		 IF (trunc(pd_creation_date) >=
	     trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date)
           /* Bug 7280925. Added by Lakshmi Gopalsami
	    * we should not round for WCT and ESSI. For those threshold_grp_id
	    * will be null
	    */
            and pn_threshold_grp_id is not null )
	    THEN
		 ln_tds_rnding_factor := jai_ap_tds_generation_pkg.gn_tds_rounding_factor;
		 ln_tds_rnded_amt := get_rnded_value(ln_tds_rnded_amt);
          fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - value after round before insert into trxs'||ln_tds_rnded_amt);
	    END IF; --moved this if-endif block from below to here for bug#8995604
	   ELSE
	    ln_tds_rnded_amt := ROUND(pn_tax_amount / r_ap_invoices_all.exchange_rate, g_fcy_currency_rounding);
	   END IF ;
           fnd_file.put_line(FND_FILE.LOG, ' Bug 7280925 - value before round '||ln_tds_rnded_amt);

	END IF;
     -- End for bug 5722028.


    insert into jai_ap_tds_thhold_trxs
    (
      threshold_trx_id                               ,
      invoice_id                                     ,
      invoice_line_number                            ,
      invoice_distribution_id                        ,
      threshold_grp_id                               ,
      threshold_hdr_id                               ,
      tds_event                                      ,
      tax_id                                         ,
      tax_rate                                       ,
      taxable_amount                                 ,
      tax_amount                                     ,
      tds_authority_vendor_id                        ,
      tds_authority_vendor_site_id                   ,
      invoice_to_tds_authority_num                   ,
      invoice_to_tds_authority_type                  ,
      invoice_to_tds_authority_curr                  ,
      invoice_to_tds_authority_amt                   ,
      vendor_id                                      ,
      vendor_site_id                                 ,
      invoice_to_vendor_num                          ,
      invoice_to_vendor_type                         ,
      invoice_to_vendor_curr                         ,
      invoice_to_vendor_amt                          ,
      parent_inv_payment_priority                    ,
      parent_inv_exchange_rate                       ,
      created_by                                     ,
      creation_date                                  ,
      last_updated_by                                ,
      last_update_date                               ,
      last_update_login															 ,
      calc_tax_amount                                , /*Bug 5751783*/
      tds_rounding_factor -- Bug 5722028. Added by csahoo
    )
    values
    (
      jai_ap_tds_thhold_trxs_s.nextval               ,
      pn_invoice_id                                  ,
      pn_invoice_line_number                         ,
      pn_invoice_distribution_id                     ,
      pn_threshold_grp_id                            ,
      pn_threshold_hdr_id                            ,
      pv_tds_event                                   ,
      pn_tax_id                                      ,
      r_ja_in_tax_codes.tax_rate                     ,
      /* Bug 5751783. Changed to ln_invoice_amount instead of pn_taxable_amount
       * This is done as now pn_taxable_amount will always be populated irrespective
       * of tds_event. Added rounding for pn_tax_amount.
       */
      ln_invoice_amount                              ,
      ln_tds_rnded_amt,  --Bug 5722028. Added by csahoo
      r_ja_in_tax_codes.vendor_id                    ,
      r_ja_in_tax_codes.vendor_site_id               ,
      lv_invoice_to_tds_num                          ,
      lv_invoice_to_tds_type                         ,
      r_gl_sets_of_books.currency_code               ,
      ln_invoice_to_tds_amount                       ,
      r_ap_invoices_all.vendor_id                    ,
      r_ap_invoices_all.vendor_site_id               ,
      lv_invoice_to_vendor_num                       ,
      lv_invoice_to_vendor_type                      ,
      r_ap_invoices_all.invoice_currency_code        ,
      ln_invoice_to_vendor_amount                    ,
      r_ap_payment_schedules_all.payment_priority    ,
      r_ap_invoices_all.exchange_rate                ,
      fnd_global.user_id                             ,
      sysdate                                        ,
      fnd_global.user_id                             ,
      sysdate                                        ,
      fnd_global.login_id		                     ,
      pn_tax_amount                                  , /*Bug 5751783*/
      ln_tds_rnding_factor -- Bug 5722028. Added by csahoo
    )
    returning threshold_trx_id into pn_threshold_trx_id;

    <<exit_from_procedure>>
      return;

    exception
      when others then
        p_process_flag := 'E';
        p_process_message := 'Error from jai_ap_tds_generation_pkg.generate_tds_invoices :' || sqlerrm;

  end generate_tds_invoices;

/* *********************************** procedure generate_tds_invoices ********************************** */

  procedure process_threshold_transition
  (
    p_threshold_grp_id                   in                  number,
    p_threshold_slab_id                  in                  number,
    p_invoice_id                         in                  number,
    p_vendor_id                          in                  number,
    p_vendor_site_id                     in                  number,
    p_accounting_date                    in                  date,
    p_tds_event                          in                  varchar2,
    p_org_id                             in                  number,
    pv_tds_invoice_num                   out       nocopy    varchar2,
    pv_cm_invoice_num                    out       nocopy    varchar2,
    p_process_flag                       out       nocopy    varchar2,
    p_process_message                    out       nocopy    varchar2
  )
  is

    cursor c_jai_ap_tds_thhold_taxes(p_threshold_slab_id number, p_org_id number) is
      select tax_id
      from   jai_ap_tds_thhold_taxes
      where  threshold_slab_id = p_threshold_slab_id
      and    operating_unit_id = p_org_id;

	/* START, Added below cursors for Bgowrava for Bug#8254510*/
   	cursor c_jai_ap_no_tds_trx(cp_threshold_grp_id  number) is
   	  select invoice_id from jai_ap_tds_inv_taxes
   	  where threshold_grp_id = cp_threshold_grp_id
	  and tax_amount <> 0
   	  minus
   	  select invoice_id from jai_ap_tds_thhold_trxs
   	  where threshold_grp_id = cp_threshold_grp_id;

   	cursor c_threshold_passed(cp_threshold_grp_id  number) is
   	  select 1 from jai_ap_tds_thhold_trxs
   	  where threshold_grp_id = cp_threshold_grp_id
   	  and tds_event like 'THRESHOLD TRANSITION%';

	cursor c_jai_no_tds_trx_amt(cp_invoice_id number) is
	  select sum(amount) amount, sum(tax_amount) tax_amount
	  from jai_ap_tds_inv_taxes
	  where invoice_id = cp_invoice_id
	  group by invoice_id;

	cursor c_thhold_grps_inv(cp_threshold_grp_id  number) is
	  select invoice_id, tds_event, tax_id, tax_rate, taxable_amount, tax_amount
	  from jai_ap_tds_thhold_trxs
   	  where threshold_grp_id = cp_threshold_grp_id;

	cursor c_jai_cancelled_amount(cp_invoice_id number) is
	  select nvl(cancelled_amount,0)
	  from ap_invoices_all
	  where invoice_id=cp_invoice_id;

    cursor c_get_threshold(p_vendor_id number, p_vendor_site_id number,  p_tds_section_code varchar2) is
      select threshold_hdr_id
      from   JAI_AP_TDS_TH_VSITE_V
      where  vendor_id = p_vendor_id
      and    vendor_site_id = p_vendor_site_id
      and    section_type = 'TDS_SECTION'
      and    section_code = p_tds_section_code;

	cursor c_sur_already_calc(cp_threshold_grp_id  number) is
	  select 1
	  from jai_ap_tds_thhold_trxs
	  where threshold_grp_id = cp_threshold_grp_id
	  and tds_event like 'SURCHARGE_CALCULATE';
    /* END, Bgowrava for Bug#8254510*/


    cursor c_jai_ap_tds_thhold_grps(cp_threshold_grp_id  number) is
      select (
                nvl(total_invoice_amount, 0) -
                nvl(total_invoice_cancel_amount, 0) -
                nvl(total_invoice_apply_amount, 0)  +
                nvl(total_invoice_unapply_amount, 0)
              )
              total_invoice_amount,
              total_tax_paid,
              /*Bug 5751783. Selected non-rounded value for calculation*/
              total_calc_tax_paid
      from    jai_ap_tds_thhold_grps
      where   threshold_grp_id = cp_threshold_grp_id;

    cursor c_ja_in_tax_codes(cp_tax_id number) is
      select tax_rate, surcharge_rate, cess_rate, sh_cess_rate, section_code  --Added  surcharge_rate, cess_rate, sh_cess_rate, section_code by Bgowrava for bug#8254510
      from   JAI_CMN_TAXES_ALL
      where  tax_id = cp_tax_id;

    /* Bug 5751783. Get the sum of invoice amount for which TDS is not calculated*/
    CURSOR get_tds_not_deducted ( cp_threshold_grp_id IN NUMBER )
    IS
    SELECT SUM (NVL (jatit.amount , 0 ) )
      FROM jai_ap_tds_inv_taxes jatit
      WHERE jatit.threshold_grp_id = cp_threshold_grp_id
         AND match_status_flag = 'A'
         AND jatit.process_status = 'P'
         AND jatit.tax_amount IS NOT NULL
         AND jatit.threshold_trx_id IS NULL
         AND jatit.threshold_slab_id = 0
         AND ( jatit.actual_tax_id IS NOT NULL OR
                 ( jatit.actual_taX_id IS  NULL
                   AND  jatit.default_tax_id IS NOT NULL
                 )
             )
         AND  EXISTS /* check whether iinvoice is not cancelled*/
             ( SELECT invoice_id
               FROM ap_invoices_all ai
               WHERE ai.invoice_id = jatit.invoice_id
                  AND ai.cancelled_Date IS NULL
                  AND ai.cancelled_amount IS NULL
             );


	CURSOR get_thhold_rollbk (cp_threshold_grp_id IN NUMBER )
			 IS
			 SELECT SUM(NVL(jattt.taxable_amount,0))
				 FROM jai_ap_tds_thhold_trxs jattt
				WHERE jattt.threshold_grp_id = cp_threshold_grp_id
					AND (jattt.tds_event like 'THRESHOLD ROLLBACK%');
				-- Bug 5722028. Added by csahoo
				-- added the following condition
	    --jattt.tds_event like 'THRESHOLD TRANSITION%' );    --commented by Bgowrava for Bug#8254510

     /* START, by Bgowrava for Bug#8459564 */
     /* Get the prepayment amount which is applied and RTN invoice is not yet generated. */
    CURSOR get_ppau_tds_not_deducted (cp_threshold_grp_id IN NUMBER )
    IS
    SELECT SUM (NVL (jatp.application_amount, 0 ))
    FROM jai_ap_tds_prepayments jatp
    WHERE jatp.tds_threshold_grp_id = cp_threshold_grp_id
    AND jatp.tds_applicable_flag   = 'Y'
	AND jatp.tds_threshold_trx_id_apply IS NULL
    AND (jatp.unapply_flag IS NULL OR jatp.unapply_flag = 'N') ;
	/* END, by Bgowrava for Bug#8459564 */

    --Added by Xiao Lv for bug#8485691, related 11i bug#8439217, begin
	cursor c_default_tax_id(cp_invoice_id number, cp_tax_id number) is
		select default_tax_id
		from jai_ap_tds_inv_taxes
		where invoice_id = cp_invoice_id
		and default_type = 'TAX'
		and default_tax_id <> cp_tax_id;
    --Added by Xiao Lv for bug#8485691, related 11i bug#8439217, end
    lv_codepath                     jai_ap_tds_inv_taxes.codepath%type;


    r_jai_ap_tds_thhold_taxes       c_jai_ap_tds_thhold_taxes%rowtype;
    r_jai_ap_tds_thhold_grps        c_jai_ap_tds_thhold_grps%rowtype;
    r_ja_in_tax_codes               c_ja_in_tax_codes%rowtype;
    ln_thhold_transition_tax_amt    number;
    lv_tds_invoice_num              ap_invoices_all.invoice_num%type;
    lv_tds_cm_num                   ap_invoices_all.invoice_num%type;
    ln_threshold_trx_id             number;
    ln_threshold_grp_audit_id       number;
    ln_threshold_grp_id             number;

	/*Added below variables by bgowrava for Bug#8254510*/
	ln_thhold_total_tax_amt         number;
    ln_sur_applicable_amt           number;
	ln_inv_surcharge_rate           number;
	ln_trx_surcharge_amount         number;
    ln_thhold_total_sur_amt         number;
    ln_surcharge_rate               number;
    ln_thhold_passed                number;
	ln_threshold_hdr_id             number;
	ln_cancelled_amount             number;
	ln_prepay_applied_amt number; --Added by Xiao Lv for bug#8345080 on 13-Jan-10
	r_ja_in_tax_codes_sur           c_ja_in_tax_codes%rowtype;
    r_jai_no_tds_trx_amt            c_jai_no_tds_trx_amt%rowtype;
	r_sur_already_calc              number;
	/*END, bgowrava for Bug#8254510*/
	/* START, by Bgowrava for Bug#8459564 */
   ln_threshold_slab_id_before   jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
   ln_threshold_slab_id_temp     VARCHAR2 (1000);
   ln_threshold_slab_id_after    jai_ap_tds_thhold_slabs.threshold_slab_id%TYPE;
   ln_taxable_amount             jai_ap_tds_thhold_trxs.taxable_amount%TYPE;
   ln_pp_tds_not_deducted      NUMBER ;
   ln_thhold_trxn_roll         NUMBER ;
   /* END, by Bgowrava for Bug#8459564 */
	ln_thhold_total_inv_amt         number := 0;  --Added by Xiao For Bug#8485691, related 11i bug#8439217
	r_default_tax_id   number;                    --Added by Xiao Bug#8485691, related 11i bug#8439217
	r_ja_in_tax_codes_inv  c_ja_in_tax_codes%rowtype;   --Added by Xiao For Bug#8485691, related 11i bug#8439217
	ln_curr_prepay_amt number;   --Added by Xiao Lv for Bug#8513550, related 11i bug#8439276

  begin

    open  c_jai_ap_tds_thhold_taxes(p_threshold_slab_id, p_org_id);
    fetch c_jai_ap_tds_thhold_taxes into r_jai_ap_tds_thhold_taxes;
    close c_jai_ap_tds_thhold_taxes;

    open  c_jai_ap_tds_thhold_grps(p_threshold_grp_id);
    fetch c_jai_ap_tds_thhold_grps into r_jai_ap_tds_thhold_grps;
    close c_jai_ap_tds_thhold_grps;

    open  c_ja_in_tax_codes(r_jai_ap_tds_thhold_taxes.tax_id);
    fetch c_ja_in_tax_codes into r_ja_in_tax_codes;
    close c_ja_in_tax_codes;

    -- Bug 5722028. Added by csahoo
		    -- Rounded depending on the TDS setup rounding.

	/*ln_thhold_transition_tax_amt :=
	ROUND(r_jai_ap_tds_thhold_grps.total_invoice_amount * (r_ja_in_tax_codes.tax_rate/100),
			 g_inr_currency_rounding);

    IF trunc(sysdate) >=
	 trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
	 ln_thhold_transition_tax_amt := get_rnded_value(ln_thhold_transition_tax_amt);
    END IF;

    ln_thhold_transition_tax_amt := ln_thhold_transition_tax_amt - r_jai_ap_tds_thhold_grps.total_tax_paid;*/ --Commented by Bgowrava for Bug#8254510

	    /* START, Bgowrava for Bug#8254510*/
		ln_threshold_hdr_id := 0;
		open  c_get_threshold(p_vendor_id ,p_vendor_site_id, r_ja_in_tax_codes.section_code);
		fetch c_get_threshold into ln_threshold_hdr_id;
		close c_get_threshold;

		ln_thhold_passed := 0;
	    open c_threshold_passed(p_threshold_grp_id);
		fetch c_threshold_passed into ln_thhold_passed;
		close c_threshold_passed;
        if ln_thhold_passed <> 1 then
	get_prepay_appln_amt(p_invoice_id, p_threshold_grp_id, 'Y', ln_curr_prepay_amt);      --Added by Xiao for Bug#8513550, related 11i bug#8439276

        ln_thhold_total_tax_amt := 0;
		for c_rec_no_tds in c_jai_ap_no_tds_trx(p_threshold_grp_id)
		loop
		open c_jai_no_tds_trx_amt(c_rec_no_tds.invoice_id);
		fetch c_jai_no_tds_trx_amt into r_jai_no_tds_trx_amt;
		close c_jai_no_tds_trx_amt;

	get_prepay_appln_amt(c_rec_no_tds.invoice_id, p_threshold_grp_id, 'N', ln_prepay_applied_amt); --Added by Xiao Lv for bug#8345080
			ln_cancelled_amount := 0;
		open c_jai_cancelled_amount(c_rec_no_tds.invoice_id);
		fetch c_jai_cancelled_amount into ln_cancelled_amount;
		close c_jai_cancelled_amount;
	--Added by Xiao for Bug#8485691, related 11i Bug#8439217, begin
		    r_default_tax_id := null;
			open c_default_tax_id(c_rec_no_tds.invoice_id, r_jai_ap_tds_thhold_taxes.tax_id);
			fetch c_default_tax_id into r_default_tax_id;
			close c_default_tax_id;

			open  c_ja_in_tax_codes(nvl(r_default_tax_id, r_jai_ap_tds_thhold_taxes.tax_id));
            fetch c_ja_in_tax_codes into r_ja_in_tax_codes_inv;
            close c_ja_in_tax_codes;

			ln_thhold_total_inv_amt :=  ln_thhold_total_inv_amt + (r_jai_no_tds_trx_amt.amount - ln_cancelled_amount - ln_prepay_applied_amt - ln_curr_prepay_amt); --Added ln_curr_prepay_amt by xiao for Bug#8513550


		--ln_thhold_total_tax_amt :=  ln_thhold_total_tax_amt + (r_jai_no_tds_trx_amt.amount - ln_cancelled_amount);
	--Added by Xiao for Bug#8485691, related 11i Bug#8439217, end
    ln_thhold_total_tax_amt :=  ln_thhold_total_tax_amt
                              + ((r_jai_no_tds_trx_amt.amount - ln_cancelled_amount - ln_prepay_applied_amt - ln_curr_prepay_amt)
                                                           *(r_ja_in_tax_codes_inv.tax_rate/100));  --Added ln_prepay_applied_amt by Xiao Lv for bug#8345080  --Added ln_curr_prepay_amt by Xiao for Bug#8513550, related 11i bug#8439276
		end loop;

		ln_thhold_transition_tax_amt := ROUND(ln_thhold_total_tax_amt, g_inr_currency_rounding);

        IF trunc(sysdate) >= trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
          ln_thhold_transition_tax_amt := get_rnded_value(ln_thhold_transition_tax_amt);
        END IF;
		/* END, Bgowrava for Bug#8254510*/

    if ln_thhold_transition_tax_amt > 0 then
     /* START, by Bgowrava for Bug#8459564 */
	ln_threshold_slab_id_after := p_threshold_slab_id;
    ln_threshold_slab_id_temp := substr(p_tds_event, instr(p_tds_event,'from slab id -')+14 );
    ln_threshold_slab_id_before := to_number(substr(ln_threshold_slab_id_temp,1, instr(ln_threshold_slab_id_temp,'to slab id -')-1));

    IF ln_threshold_slab_id_before = 0  THEN
	  OPEN get_ppau_tds_not_deducted(p_threshold_grp_id);
	  FETCH get_ppau_tds_not_deducted INTO ln_pp_tds_not_deducted;
	  CLOSE get_ppau_tds_not_deducted;
	   -- Get the rollback taxable amount
	  OPEN get_thhold_rollbk(p_threshold_grp_id);
	  FETCH get_thhold_rollbk INTO ln_thhold_trxn_roll;
	  CLOSE get_thhold_rollbk;
	  ln_taxable_amount := ln_thhold_total_inv_amt - NVL(ln_pp_tds_not_deducted,0)- NVL(ln_thhold_trxn_roll,0);
    ELSE
         -- This case arrives when the transition happens within cumulative.
      ln_taxable_amount := 0;
    END IF;
    /* END, by Bgowrava for Bug#8459564 */

      jai_ap_tds_generation_pkg.generate_tds_invoices
      (
        pn_invoice_id              =>      p_invoice_id           ,
        pn_taxable_amount          =>      ln_taxable_amount      ,   --Modified by Bgowrava for Bug#8459564
        /* No taxable amount in case of threshold transition invoice */
        pn_tax_amount              =>      ln_thhold_transition_tax_amt      ,
        pn_tax_id                  =>      r_jai_ap_tds_thhold_taxes.tax_id    ,
        pd_accounting_date         =>      p_accounting_date      ,
        pv_tds_event               =>      p_tds_event            ,
        pn_threshold_grp_id        =>      p_threshold_grp_id    ,
        pv_tds_invoice_num         =>      lv_tds_invoice_num     ,
        pv_cm_invoice_num          =>      lv_tds_cm_num          ,
        pn_threshold_trx_id        =>      ln_threshold_trx_id    ,
        pd_creation_date           =>      sysdate, -- Bug 5722028. Added by csahoo
        p_process_flag             =>      p_process_flag         ,
        p_process_message          =>      p_process_message
      );

      if p_process_flag = 'E' then
        goto exit_from_procedure;
      end if;

	  	  /* START, by Bgowrava for Bug#8459564
       * Call the import and approve for threshold transition
       * occurred when prepayment unapplication has happened as
       * we already call import_and_approve for validation
       * in procedure process_tds_at_inv_validate
       * Threshold transition can again re-appear during prepayment
       * unapplication
       */

    IF ln_threshold_trx_id IS NOT NULL AND
      p_tds_event like 'THRESHOLD TRANSITION-PPUA%'
    THEN

        import_and_approve
        (
          p_invoice_id                   =>     p_invoice_id,
          p_start_thhold_trx_id          =>     ln_threshold_trx_id,
          p_tds_event                    =>     p_tds_event,
          p_process_flag                 =>     p_process_flag,
          p_process_message              =>     p_process_message
        );

      IF p_process_flag = 'E' THEN
        goto exit_from_procedure;
      END IF;

     END IF;
	 /* END, by Bgowrava for Bug#8459564 */

      /* Update the total tax amount for which invoice was raised */
      ln_threshold_grp_id:= p_threshold_grp_id;
      maintain_thhold_grps
      (
        p_threshold_grp_id             =>   ln_threshold_grp_id,
        p_trx_tax_paid                 =>   ln_thhold_transition_tax_amt,
        p_trx_thhold_change_tax_paid   =>   ln_thhold_transition_tax_amt,
        p_trx_threshold_slab_id        =>   p_threshold_slab_id,
        p_tds_event                    =>   p_tds_event,
        p_invoice_id                   =>   p_invoice_id,
        p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
        -- Bug 5722028. Added by Lakshmi Gopalsami
				p_creation_date                =>   sysdate,
        p_process_flag                 =>   p_process_flag,
        P_process_message              =>   P_process_message,
        p_codepath                     =>   lv_codepath
     );

			--Added by Sanjikum for Bug#5131075(4722011)
			IF p_process_flag = 'E' THEN
				goto exit_from_procedure;
			END IF;

    end if; /* ln_thhold_transition_tax_amt > 0 */
end if;  --Bgowrava for Bug#8254510

/* START, Bgowrava for bug#8254510*/
ln_surcharge_rate := 0;
open c_sur_already_calc(p_threshold_grp_id);
fetch c_sur_already_calc into r_sur_already_calc;
close c_sur_already_calc;

if nvl(r_ja_in_tax_codes.surcharge_rate, 0) > 0  and nvl(r_sur_already_calc, 0) <> 1 then

/* added nvl condition in the surcharge calculation formula below for Bug 7312295*/
ln_surcharge_rate := (nvl(r_ja_in_tax_codes.surcharge_rate,0)/(r_ja_in_tax_codes.tax_rate-(nvl(r_ja_in_tax_codes.surcharge_rate, 0)
                                                   + nvl(r_ja_in_tax_codes.cess_rate, 0)
                                                   + nvl(r_ja_in_tax_codes.sh_cess_rate, 0)))) * 100;

ln_sur_applicable_amt := 0;
ln_inv_surcharge_rate := 0;
ln_trx_surcharge_amount := 0;
ln_thhold_total_sur_amt := 0;
for c_rec_grps_inv in c_thhold_grps_inv(p_threshold_grp_id)
 loop
    r_ja_in_tax_codes_sur := null;
    open  c_ja_in_tax_codes(c_rec_grps_inv.tax_id);
    fetch c_ja_in_tax_codes into r_ja_in_tax_codes_sur;
    close c_ja_in_tax_codes;

    if nvl(r_ja_in_tax_codes_sur.surcharge_rate, 0) = 0 and c_rec_grps_inv.taxable_amount<>0 then
    ln_sur_applicable_amt   :=  ln_sur_applicable_amt + c_rec_grps_inv.taxable_amount;
    ln_inv_surcharge_rate   :=  nvl(r_ja_in_tax_codes_sur.tax_rate, 0) * (ln_surcharge_rate/100); /*Bug 7312295 - Removed CESS and SHECESS*/
    ln_trx_surcharge_amount :=  c_rec_grps_inv.taxable_amount*(ln_inv_surcharge_rate/100);
    ln_thhold_total_sur_amt :=  ln_thhold_total_sur_amt + ln_trx_surcharge_amount;
    end if;
 end loop;

    jai_ap_tds_generation_pkg.generate_tds_invoices
       (
         pn_invoice_id              =>      p_invoice_id           ,
		 pn_threshold_hdr_id        =>      ln_threshold_hdr_id    ,
         pn_taxable_amount          =>      ln_sur_applicable_amt,
         pn_tax_amount              =>      ln_thhold_total_sur_amt      ,
         pn_tax_id                  =>      r_jai_ap_tds_thhold_taxes.tax_id    ,
         pd_accounting_date         =>      p_accounting_date      ,
         pv_tds_event               =>      'SURCHARGE_CALCULATE'            ,
         pn_threshold_grp_id        =>      p_threshold_grp_id    ,
         pv_tds_invoice_num         =>      lv_tds_invoice_num     ,
         pv_cm_invoice_num          =>      lv_tds_cm_num          ,
         pn_threshold_trx_id        =>      ln_threshold_trx_id    ,
 	     pd_creation_date           =>      sysdate,
         p_process_flag             =>      p_process_flag         ,
         p_process_message          =>      p_process_message
       );

       if p_process_flag = 'E' then
         goto exit_from_procedure;
      end if;

      /* Update the total tax amount for which invoice was raised */
		ln_threshold_grp_id:= p_threshold_grp_id;
	    maintain_thhold_grps
		(
		 p_threshold_grp_id             =>   ln_threshold_grp_id,
		 p_trx_tax_paid                 =>   ln_thhold_total_sur_amt,
		 p_trx_thhold_change_tax_paid   =>   ln_thhold_total_sur_amt,
		 p_trx_threshold_slab_id        =>   p_threshold_slab_id,
		 p_tds_event                    =>   'SURCHARGE_CALCULATE',
		 p_invoice_id                   =>   p_invoice_id,
		 p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
		 p_creation_date                =>   sysdate,
		 p_process_flag                 =>   p_process_flag,
		 P_process_message              =>   P_process_message,
		 p_codepath                     =>   lv_codepath
		);

end if;
/* END, Bgowrava for bug#8254510*/

    <<exit_from_procedure>>
        return;

  exception
    when others then
      p_process_flag := 'E';
      p_process_message := 'Error from jai_ap_tds_generation_pkg.process_threshold_transition :' || sqlerrm;
  end process_threshold_transition;

/* *********************************** procedure import_and_approve ********************************** */

  procedure import_and_approve
  (
    p_invoice_id                    in                       number,
    p_start_thhold_trx_id           in                       number,
    p_tds_event                     in                       varchar2,
    p_process_flag                  out            nocopy    varchar2,
    p_process_message               out            nocopy    varchar2
  )
  is

    cursor  c_ap_invoices_all(p_invoice_id number) is
      select  vendor_id,
              vendor_site_id,
			  org_id
      from    ap_invoices_all
      where   invoice_id = p_invoice_id;

    cursor    c_ja_in_po_vendor_sites(p_vendor_id number, p_vendor_site_id number) is
      select  nvl( approved_invoice_flag, 'N' ) approved_invoice_flag
      from    JAI_CMN_VENDOR_SITES
      where   vendor_id       =   p_vendor_id
      and     vendor_site_id  =   p_vendor_site_id;


    r_ap_invoices_all                 c_ap_invoices_all%rowtype;

    lb_result                         boolean;
    ln_import_request_id              number;
    ln_approve_request_id             number;
    lv_approved_invoice_flag          JAI_CMN_VENDOR_SITES.approved_invoice_flag%type;
    lv_batch_name                     ap_batches_all.batch_name%TYPE; --added by Ramananda for Bug#4584221
    lv_group_id                       VARCHAR2(80); --Added by Sanjikum for Bug#5131075(4722011)

  begin
    fnd_file.put_line (fnd_file.log,   'p_tds_event='||p_tds_event);
    --Added by Sanjikum for Bug#5131075(4722011)
    IF p_tds_event = 'PREPAYMENT APPLICATION' OR p_tds_event = 'PREPAYMENT UNAPPLICATION' THEN
      lv_group_id := to_char(p_invoice_id)||p_tds_event;
    ELSE
      lv_group_id := to_char(p_invoice_id);
    END IF;


    /* Invoke payables open interface */

    lb_result := fnd_request.set_mode(true);

	open c_ap_invoices_all(p_invoice_id);
	fetch c_ap_invoices_all into r_ap_invoices_all;
	close c_ap_invoices_all;

    lv_batch_name := jai_ap_utils_pkg.get_tds_invoice_batch(p_invoice_id, r_ap_invoices_all.org_id); --Ramananda for bug#4584221 --added org_id parameter for Bug#9149941

    ln_import_request_id :=
    fnd_request.submit_request
    (
      'SQLAP',
      'APXIIMPT',
      'Import TDS invoices - ' || lower(p_tds_event),
      '',
      false,
      /* Bug 4774647. Added by Lakshmi Gopalsami
          Passed operating unit also as this parameter has been
    added by base .
      */
      '',
      'INDIA TDS', /*--'TDS', --Ramanand for bug#4388958*/
      --'',
			--Commented the above and added the below by Sanjikum for Bug#5131075(4722011)
			lv_group_id,        -- Chaged from to_char(p_invoice_id) for bug# 6119216
      --'TDS'||TO_CHAR(TRUNC(SYSDATE)),
      --commented the above and added the below by Ramananda for Bug#4584221
      lv_batch_name,
      '',
      '',
      '',
      'Y',
      'N',
      'N',
      'N',
      1000,
      fnd_global.user_id,
      fnd_global.login_id
    );

    /* Get vendor and site for the invoice */
   /* open  c_ap_invoices_all(p_invoice_id);
    fetch c_ap_invoices_all into r_ap_invoices_all;
    close c_ap_invoices_all;*/ --moved this code to the start of the procedure for Bug#9149941

    /* Check if Pre-approved TDS invoices setup has been set for the vendor */

    /* Check for vendor and site */
    open   c_ja_in_po_vendor_sites(r_ap_invoices_all.vendor_id, r_ap_invoices_all.vendor_site_id);
    fetch  c_ja_in_po_vendor_sites into lv_approved_invoice_flag;
    close  c_ja_in_po_vendor_sites;

    if nvl(lv_approved_invoice_flag, 'N') <> 'Y' then
      /* Pre-approved TDS invoice is not set for vendor and site, Check for vendor and null site */
      open   c_ja_in_po_vendor_sites(r_ap_invoices_all.vendor_id, 0);
      fetch  c_ja_in_po_vendor_sites into lv_approved_invoice_flag;
      close  c_ja_in_po_vendor_sites;
    end if;

    if nvl(lv_approved_invoice_flag, 'N') <> 'Y' then
      /* Setup for pre-approved TDS invoice is not there for the vendor for site or null site. */
      goto exit_from_procedure;
    end if;


    /*  Control comes here only when Pre-approved TDS invoice is setup for the vendor,
        we need to invoke the request for approval */
    lb_result := fnd_request.set_mode(true);

    ln_approve_request_id :=
    fnd_request.submit_request
    (
      'JA',
      'JAITDSA',
      'Approval Of TDS Invoices ',
      sysdate,
      false,
      ln_import_request_id,
      p_invoice_id,
      r_ap_invoices_all.vendor_id,
      r_ap_invoices_all.vendor_site_id,
      p_start_thhold_trx_id
    );


    <<exit_from_procedure>>
    return;

  exception
    when others then
      p_process_flag := 'E';
      p_process_message := 'Error from jai_ap_tds_generation_pkg.import_and_approve :' || sqlerrm;
  end import_and_approve;

/* *********************************** procedure import_and_approve ********************************** */

/* *********************************** procedure approve_tds_invoices ********************************** */

  procedure approve_tds_invoices
  (
    errbuf                          out            nocopy    varchar2,
    retcode                         out            nocopy    varchar2,
    p_parent_request_id             in             number,
    p_invoice_id                    in             number,
    p_vendor_id                     in             number,
    p_vendor_site_id                in             number,
    p_start_thhold_trx_id           in             number
  )
  is

    cursor  c_jai_ap_tds_thhold_trxs
    (p_invoice_id number, p_start_thhold_trx_id number, p_vendor_id number,  p_vendor_site_id number) is
      select invoice_to_tds_authority_id,
             invoice_to_vendor_id,
             invoice_to_tds_authority_num,
             invoice_to_vendor_num
      from   jai_ap_tds_thhold_trxs
      where  threshold_trx_id >= p_start_thhold_trx_id
      and    invoice_id = p_invoice_id
      and    vendor_id =  p_vendor_id
      and    vendor_site_id =  p_vendor_site_id;

   CURSOR c_jai_chk_tds_inv (p_invoice_id number) IS
    SELECT invoice_id, org_id,
           set_of_books_id -- bug 6819855. Added by Lakshmi Gopalsami
       FROM ap_invoices_all
      WHERE invoice_id = p_invoice_id;

    lb_request_status             boolean;
    lv_phase                      varchar2(100);
    lv_status                     varchar2(100);
    lv_dev_phase                  varchar2(100);
    lv_dev_status                 varchar2(100);
    lv_message                    varchar2(100);

    ln_holds_count                number;
    lv_approval_status            varchar2(100);
    lv_conc_flag  varchar2(10);

    /* Bug 4872659. Added by Lakshmi Gopalsami  */
    ln_tds_invoice_id    NUMBER;
    ln_vendor_invoice_id     NUMBER;
    ln_org_id               NUMBER;

    /* Bug 4943949. Added by Lakshmi gopalsami */
    lv_funds_ret_code varchar2(5);

    /* Bug 6819855. Added by Lakshmi Gopalsami */
    ln_sob_id  NUMBER;
    ln_holds_count1    NUMBER;

    begin

      /* Check for the status of  the import request */
      Fnd_File.put_line(Fnd_File.LOG,  'jai_ap_tds_generation_pkg.approve_tds_invoices');
      Fnd_File.put_line(Fnd_File.LOG,  'p_parent_request_id =>' || p_parent_request_id);
      Fnd_File.put_line(Fnd_File.LOG,  'p_invoice_id=> ' || p_invoice_id );
      Fnd_File.put_line(Fnd_File.LOG,  'p_vendor_id=> ' || p_vendor_id);
      Fnd_File.put_line(Fnd_File.LOG,  'p_vendor_site_id=> ' || p_vendor_site_id);
      Fnd_File.put_line(Fnd_File.LOG,  'p_start_thhold_trx_id=> ' || p_start_thhold_trx_id);

      lb_request_status :=
      fnd_concurrent.wait_for_request
      (
        request_id  =>  p_parent_request_id,
        interval    =>  60,   /*  default value - sleep time in secs */
        max_wait    =>  0,    /* default value - max wait in secs */
        phase       =>  lv_phase,
        status      =>  lv_status,
        dev_phase   =>  lv_dev_phase,
        dev_status  =>  lv_dev_status,
        message     =>  lv_message
      );


      if not ( lv_dev_phase = 'COMPLETE' and  lv_dev_status = 'NORMAL' ) then

        Fnd_File.put_line(Fnd_File.LOG, 'Exiting with warning as parent request not completed with normal status');
        Fnd_File.put_line(Fnd_File.LOG, 'Message from parent request :' || lv_message);
        retcode := 1;
        errbuf := 'Exiting with warnings as parent request not completed with normal status';
        goto exit_from_procedure;

      end if;

      /* Control comes here only when the concurrent request has completed with Normal Status */
      Fnd_File.put_line(Fnd_File.LOG, 'Before Loop ');

      /* Get all the tds invoices that have been created and call the base API to approve it */
      for cur_rec in
      c_jai_ap_tds_thhold_trxs(p_invoice_id , p_start_thhold_trx_id , p_vendor_id ,  p_vendor_site_id)
      loop


        /* Get the status of both the invoices and call approval API, if it is not already approved */
        ln_holds_count := 0;
        lv_approval_status := null;

  /* Bug 4872659. Added by Lakshmi Gopalsami
      There is a possibility that the invoice gets rejected via Interface and
      the invoice  is not existing. Base requires the org_id from the
      invoice_id we pass. Ensure that the invoice_id exists before calling approval
  */

        fnd_file.put_line(FND_FILE.LOG, ' Check for the TDS authority invoice ');

         /*Added by nprashar for bug # 6720018*/
	 IF (FND_GLOBAL.CONC_REQUEST_ID is NULL) THEN
	  lv_conc_flag := 'N';
	ELSE
	  lv_conc_flag := 'Y';
	END IF;

        If cur_rec.invoice_to_tds_authority_id is not null Then

	OPEN c_jai_chk_tds_inv(cur_rec.invoice_to_tds_authority_id);
	 FETCH c_jai_chk_tds_inv INTO ln_tds_invoice_id,
	                              ln_org_id,
				      --Bug 6819855. Added by Lakshmi Gopalsami
				      ln_sob_id;
	CLOSE c_jai_chk_tds_inv;

	fnd_file.put_line(FND_FILE.LOG, ' Org id ' || ln_org_id);


	mo_global.set_policy_context('S', ln_org_id);

        fnd_file.put_line(FND_FILE.LOG,' TDS authority invoice id '
	                               || cur_rec.invoice_to_tds_authority_id);

        /* Invoice to TDS Authority */
        /* Bug 6819855. Added by Lakshmi Gopalsami
	   Commented the following code and added a call to function batch_approval
	 ap_approval_pkg.approve
        (
          p_run_option             =>   null,
          p_invoice_batch_id       =>   null,
          p_begin_invoice_date     =>   null,
          p_end_invoice_date       =>   null,
          p_vendor_id              =>   null,
          p_pay_group              =>   null,
          p_invoice_id             =>   cur_rec.invoice_to_tds_authority_id,
          p_entered_by             =>   null,
          p_set_of_books_id        =>   null,
          p_trace_option           =>   null,
          p_conc_flag              =>    lv_conc_flag 'N', /*Changed by nprashar for  bug # 6720018
          p_holds_count            =>   ln_holds_count,
          p_approval_status        =>   lv_approval_status,
    /* Bug  4943949. Added by Lakshmi Gopalsami
    p_funds_return_code         =>   lv_funds_ret_code,
          p_calling_sequence       =>   'jai_ap_tds_generation_pkg.approve_tds_invoices'
        ) ;
	*/
          BEGIN
	   IF ap_approval_pkg.batch_approval(
	        p_run_option          => 'New',
		p_sob_id              => ln_sob_id,
		p_inv_start_date      => NULL,
		p_inv_end_date        => NULL,
		p_inv_batch_id        => NULL,
		p_vendor_id           => NULL,
		p_pay_group           => NULL,
		p_invoice_id          => cur_rec.invoice_to_tds_authority_id,
		p_entered_by          => NULL,
		p_debug_switch        => 'N',
		p_conc_request_id     => FND_GLOBAL.CONC_REQUEST_ID,
		p_commit_size         => 1000,
		p_org_id              => ln_org_id,
		p_report_holds_count  => ln_holds_count
	       ) THEN

             Fnd_File.put_line(Fnd_File.LOG, 'Invoice to TDS Authority ' ||
	                                      cur_rec.invoice_to_tds_authority_num ||
					      '(' || cur_rec.invoice_to_tds_authority_id ||
					      ') Was submitted for Approval.
					      Holds count ' || ln_holds_count);
    	    END IF ;
          EXCEPTION
	    WHEN OTHERS THEN
	     retcode := 'E';
	     errbuf := 'Error from jai_ap_tds_generation_pkg.approve_tds_invoices-> :
	                           during call to batch_approval for TDS invoice' || sqlerrm;
	  END;

        End if;

        /* Invoice to Supplier */
        ln_holds_count1 := 0;
        lv_approval_status := null;

        If cur_rec.invoice_to_vendor_id is not null Then

	OPEN c_jai_chk_tds_inv(cur_rec.invoice_to_vendor_id);
	 FETCH c_jai_chk_tds_inv INTO ln_vendor_invoice_id,
	                              ln_org_id,
				       --Bug 6819855. Added by Lakshmi Gopalsami
				      ln_sob_id;
	CLOSE c_jai_chk_tds_inv;

	mo_global.set_policy_context('S', ln_org_id);

        fnd_file.put_line(FND_FILE.LOG,' Supplier credit invoice id '
	                               || cur_rec.invoice_to_vendor_id);
        /* Bug 6819855. Added by Lakshmi Gopalsami
	   Commented the following code and added a call to function batch_approval
        ap_approval_pkg.approve
        (
          p_run_option             =>   null,
          p_invoice_batch_id       =>   null,
          p_begin_invoice_date     =>   null,
          p_end_invoice_date       =>   null,
          p_vendor_id              =>   null,
          p_pay_group              =>   null,
          p_invoice_id             =>   cur_rec.invoice_to_vendor_id,
          p_entered_by             =>   null,
          p_set_of_books_id        =>   null,
          p_trace_option           =>   null,
          p_conc_flag              =>      lv_conc_flag /*'N', /*Changed by nprashar for  bug # 6720018
          p_holds_count            =>   ln_holds_count,
          p_approval_status        =>   lv_approval_status,
          /* Bug  4943949. Added by Lakshmi Gopalsami
          p_funds_return_code         =>   lv_funds_ret_code,
          p_calling_sequence       =>   'jai_ap_tds_generation_pkg.approve_tds_invoices'
         ) ;
	 */

	  BEGIN
	   IF ap_approval_pkg.batch_approval(
	        p_run_option          => 'New',
		p_sob_id              => ln_sob_id,
		p_inv_start_date      => NULL,
		p_inv_end_date        => NULL,
		p_inv_batch_id        => NULL,
		p_vendor_id           => NULL,
		p_pay_group           => NULL,
		p_invoice_id          => cur_rec.invoice_to_vendor_id,
		p_entered_by          => NULL,
		p_debug_switch        => 'N',
		p_conc_request_id     => FND_GLOBAL.CONC_REQUEST_ID,
		p_commit_size         => 1000,
		p_org_id              => ln_org_id,
		p_report_holds_count  => ln_holds_count1
	       ) THEN

             Fnd_File.put_line(Fnd_File.LOG, 'Invoice to Supplier for TDS' ||
	                                      cur_rec.invoice_to_vendor_num ||
					      '(' || cur_rec.invoice_to_vendor_id ||
					      ') Was submitted for Approval.
					      Holds count ' || ln_holds_count1);
    	    END IF ;
          EXCEPTION
	    WHEN OTHERS THEN
	     retcode := 'E';
	     errbuf := 'Error from jai_ap_tds_generation_pkg.approve_tds_invoices-> :
	                           during call to batch_approval for TDS invoice' || sqlerrm;
	  END;


       End if;
      end loop;


      <<exit_from_procedure>>

      return;

    exception
      when others then
        retcode := 2;
        errbuf := 'Error from jai_ap_tds_generation_pkg.approve_tds_invoices : ' || sqlerrm;
    end approve_tds_invoices;

/* ********************************* populate_tds_invoice_id  **************************************** */

  procedure populate_tds_invoice_id
  (
    p_invoice_id                        in                number,
    p_invoice_num                       in                varchar2,
    p_vendor_id                         in                number,
    p_vendor_site_id                    in                number,
    p_process_flag                      out     nocopy    varchar2,
    p_process_message                   out     nocopy    varchar2
  )
  is

    cursor c_check_inv_to_tds_authority (p_invoice_num varchar2, p_vendor_id number, p_vendor_site_id number) is
      select  threshold_trx_id,
              invoice_id
      from    jai_ap_tds_thhold_trxs
      where   invoice_to_tds_authority_num = p_invoice_num
      and     tds_authority_vendor_id = p_vendor_id
      and     tds_authority_vendor_site_id = p_vendor_site_id
      and     invoice_to_tds_authority_id is null;


    cursor c_check_inv_to_vendor (p_invoice_num varchar2, p_vendor_id number, p_vendor_site_id number) is
      select  threshold_trx_id
      from    jai_ap_tds_thhold_trxs
      where   invoice_to_vendor_num = p_invoice_num
      and     vendor_id = p_vendor_id
      and     vendor_site_id = p_vendor_site_id
      and     invoice_to_vendor_id is null;

    ln_threshold_trx_id     jai_ap_tds_thhold_trxs.threshold_trx_id%type;
    ln_invoice_id           ap_invoices_all.invoice_id%type;


   begin

    open  c_check_inv_to_tds_authority(p_invoice_num, p_vendor_id, p_vendor_site_id);
    fetch c_check_inv_to_tds_authority into ln_threshold_trx_id, ln_invoice_id;
    close c_check_inv_to_tds_authority;

    if ln_threshold_trx_id is not null then
      /* Invoice being created is the invoice to TDS authority */

      update jai_ap_tds_thhold_trxs
      set    invoice_to_tds_authority_id = p_invoice_id
      where  threshold_trx_id = ln_threshold_trx_id;

    else

      /* Invoice being created is not the invoice to TDS authority */
      /*  check if it is the invoice to vendor for TDS */
      open  c_check_inv_to_vendor(p_invoice_num, p_vendor_id, p_vendor_site_id);
      fetch c_check_inv_to_vendor into ln_threshold_trx_id;
      close c_check_inv_to_vendor;

      if ln_threshold_trx_id is not null then

        /* Invoice being created is teh invoice to TDS authority */
        update jai_ap_tds_thhold_trxs
        set    invoice_to_vendor_id = p_invoice_id
        where  threshold_trx_id = ln_threshold_trx_id;

      end if; /* TDS invoice to vendor */

    end if; /* TDS invoice to TDS authority */


    <<exit_from_procedure>>
    return;

  exception
    when others then
      p_process_flag := 'E';
      p_process_message := 'Error from jai_ap_tds_generation_pkg.populate_tds_invoice_id :' || sqlerrm;
  end populate_tds_invoice_id;

/* ********************************* populate_tds_invoice_id  **************************************** */

/* ********************************  maintain_thhold_grps *******************************************  */

  procedure maintain_thhold_grps
  (
    p_threshold_grp_id                  in out    nocopy    number    ,
    p_vendor_id                         in                  number    default null,
    p_org_tan_num                       in                  varchar2  default null,
    p_vendor_pan_num                    in                  varchar2  default null,
    p_section_type                      in                  varchar2  default null,
    p_section_code                      in                  varchar2  default null,
    p_fin_year                          in                  number    default null,
    p_org_id                            in                  number    default null,
    p_trx_invoice_amount                in                  number    default null,
    p_trx_invoice_cancel_amount         in                  number    default null,
    p_trx_invoice_apply_amount          in                  number    default null,
    p_trx_invoice_unapply_amount        in                  number    default null,
    p_trx_tax_paid                      in                  number    default null,
    p_trx_thhold_change_tax_paid        in                  number    default null,
    p_trx_threshold_slab_id             in                  number    default null,
    p_tds_event                         in                  varchar2,
    p_invoice_id                        in                  number    default null,
    p_invoice_line_number               in                  number    default null, /* AP lines Uptake */
    p_invoice_distribution_id           in                  number    default null,
    p_remarks                           in                  varchar2  default null,
    -- bug 5722028. Added by csahoo
    p_creation_date                     in                  date      default sysdate,
    p_threshold_grp_audit_id            out       nocopy    number,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  )
  is


    cursor c_jai_ap_tds_thhold_grps(p_threshold_grp_id  number) is
      select total_invoice_amount          ,
             total_invoice_cancel_amount   ,
             total_invoice_apply_amount    ,
             total_invoice_unapply_amount  ,
             total_tax_paid                ,
             total_thhold_change_tax_paid  ,
             current_threshold_slab_id     ,
             total_calc_tax_paid           -- Bug 5751783
      from   jai_ap_tds_thhold_grps
      where  threshold_grp_id = p_threshold_grp_id;

    cursor c_get_threshold_grp_id
    ( p_vendor_id number, p_org_tan_num varchar2, p_vendor_pan_num varchar2,
      p_section_type varchar2, p_section_code varchar2, p_fin_year number) is
      select threshold_grp_id
      from   jai_ap_tds_thhold_grps
      where  vendor_id        =      p_vendor_id        and
             org_tan_num      =      p_org_tan_num      and
             vendor_pan_num   =      p_vendor_pan_num   and
             section_type     =      p_section_type     and
             section_code     =      p_section_code     and
             fin_year         =      p_fin_year;


    r_jai_ap_tds_thhold_grps              c_jai_ap_tds_thhold_grps%rowtype;

    ln_threshold_grp_id                   jai_ap_tds_thgrp_audits.threshold_grp_id%type;
    ln_old_invoice_amount                 jai_ap_tds_thgrp_audits.old_invoice_amount%type;
    ln_old_invoice_cancel_amount          jai_ap_tds_thgrp_audits.old_invoice_cancel_amount%type;
    ln_old_invoice_apply_amount           jai_ap_tds_thgrp_audits.old_invoice_apply_amount%type;
    ln_old_invoice_unapply_amount         jai_ap_tds_thgrp_audits.old_invoice_unapply_amount%type;
    ln_old_tax_paid                       jai_ap_tds_thgrp_audits.old_tax_paid%type;
    ln_old_thhold_change_tax_paid         jai_ap_tds_thgrp_audits.old_thhold_change_tax_paid%type;
    ln_old_threshold_slab_id              jai_ap_tds_thgrp_audits.old_threshold_slab_id%type;

    ln_new_invoice_amount                 jai_ap_tds_thgrp_audits.old_invoice_amount%type;
    ln_new_invoice_cancel_amount          jai_ap_tds_thgrp_audits.old_invoice_cancel_amount%type;
    ln_new_invoice_apply_amount           jai_ap_tds_thgrp_audits.old_invoice_apply_amount%type;
    ln_new_invoice_unapply_amount         jai_ap_tds_thgrp_audits.old_invoice_unapply_amount%type;
    ln_new_tax_paid                       jai_ap_tds_thgrp_audits.old_tax_paid%type;
    ln_new_thhold_change_tax_paid         jai_ap_tds_thgrp_audits.old_thhold_change_tax_paid%type;
    ln_new_threshold_slab_id              jai_ap_tds_thgrp_audits.old_threshold_slab_id%type;
    ln_effective_threshold_amount         number;
    ln_effective_tax_paid                 number;

    /*Bug 5751783. Added following variables.*/
    ln_calc_old_tax_paid       jai_ap_tds_thgrp_audits.calc_old_tax_paid%type;
    ln_calc_trx_tax_paid       jai_ap_tds_thgrp_audits.calc_trx_tax_paid%type;
    ln_calc_new_tax_paid     jai_ap_tds_thgrp_audits.calc_new_tax_paid%type;

    -- bug 5722028. Added by csahoo
		ln_tmp_tds_amt      number;
    ln_tmp_tds_change   number;


  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_generation_pkg.maintain_thhold_grps', 'START'); /* 1 */


    /* Validate the input */
    ln_threshold_grp_id := nvl(p_threshold_grp_id, 0);

    if ln_threshold_grp_id = 0 then

      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /*2*/

      if p_vendor_id is null then
        p_process_flag    := 'E';
        P_process_message := 'Vendor must be specified as threshold group identifier is null(jai_ap_tds_generation_pkg.maintain_thhold_grps) ';
        goto exit_from_procedure;
      end if;

      if p_org_tan_num is null then
        p_process_flag    := 'E';
        P_process_message := 'Organization TAN number must be specified as threshold group identifier is null(jai_ap_tds_generation_pkg.maintain_thhold_grps) ';
        goto exit_from_procedure;
      end if;

      if p_vendor_pan_num is null then
        p_process_flag    := 'E';
        P_process_message := 'Vendor PAN number must be specified as threshold group identifier is null(jai_ap_tds_generation_pkg.maintain_thhold_grps) ';
        goto exit_from_procedure;
      end if;

      if p_section_type is null then
        p_process_flag    := 'E';
        P_process_message := 'Section Type must be specified as threshold group identifier is null(jai_ap_tds_generation_pkg.maintain_thhold_grps) ';
        goto exit_from_procedure;
      end if;

      if p_section_code is null then
        p_process_flag    := 'E';
        P_process_message := 'Section Code must be specified as threshold group identifier is null(jai_ap_tds_generation_pkg.maintain_thhold_grps) ';
        goto exit_from_procedure;
      end if;

      if p_fin_year is null then
        p_process_flag    := 'E';
        P_process_message := 'Fin Year must be specified as threshold group identifier is null(jai_ap_tds_generation_pkg.maintain_thhold_grps) ';
        goto exit_from_procedure;
      end if;

    end if; /* Validate the input */

    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /*3*/

    if ln_threshold_grp_id = 0  then

      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      /* Threshold has not been given as an input, check if exists */
      open  c_get_threshold_grp_id
      (p_vendor_id, p_org_tan_num, p_vendor_pan_num, p_section_type, p_section_code, p_fin_year);
      fetch c_get_threshold_grp_id into ln_threshold_grp_id;
      close c_get_threshold_grp_id;

      if nvl(ln_threshold_grp_id, 0) = 0  then

          p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */

          insert into jai_ap_tds_thhold_grps
          (
            threshold_grp_id                  ,
            vendor_id                         ,
            org_tan_num                       ,
            vendor_pan_num                    ,
            section_type                      ,
            section_code                      ,
            fin_year                          ,
            created_by                        ,
            creation_date                     ,
            last_updated_by                   ,
            last_update_date                  ,
            last_update_login
          )
          values
          (
            jai_ap_tds_thhold_grps_s.nextval  ,
            p_vendor_id                       ,
            p_org_tan_num                     ,
            p_vendor_pan_num                  ,
            p_section_type                    ,
            p_section_code                    ,
            p_fin_year                        ,
            fnd_global.user_id                ,
            sysdate                           ,
            fnd_global.user_id                ,
            sysdate                           ,
            fnd_global.login_id
          )
          returning threshold_grp_id into ln_threshold_grp_id;

          p_threshold_grp_id := ln_threshold_grp_id;

      end if; /* ln_threshold_grp_id does not exist */

      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */

    end if; /* ln_threshold_grp_id is not given as an input */

    /* Get the old value of teh threshold group  */
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    open  c_jai_ap_tds_thhold_grps(ln_threshold_grp_id);
    fetch c_jai_ap_tds_thhold_grps into r_jai_ap_tds_thhold_grps;
    close c_jai_ap_tds_thhold_grps;

    ln_old_invoice_amount             :=   r_jai_ap_tds_thhold_grps.total_invoice_amount;
    ln_old_invoice_cancel_amount      :=   r_jai_ap_tds_thhold_grps.total_invoice_cancel_amount;
    ln_old_invoice_apply_amount       :=   r_jai_ap_tds_thhold_grps.total_invoice_apply_amount;
    ln_old_invoice_unapply_amount     :=   r_jai_ap_tds_thhold_grps.total_invoice_unapply_amount;
    ln_old_tax_paid                   :=   r_jai_ap_tds_thhold_grps.total_tax_paid;
    ln_old_thhold_change_tax_paid     :=   r_jai_ap_tds_thhold_grps.total_thhold_change_tax_paid;
    ln_old_threshold_slab_id          :=   r_jai_ap_tds_thhold_grps.current_threshold_slab_id;

    /*Bug 5751783*/
    ln_calc_old_tax_paid              := r_jai_ap_tds_thhold_grps.total_calc_tax_paid;

    /* Check that threshold should not become negative */
    ln_effective_threshold_amount :=
    ( nvl(ln_old_invoice_amount, 0)         + nvl(p_trx_invoice_amount, 0) ) -
    ( nvl(ln_old_invoice_cancel_amount, 0)  + nvl(p_trx_invoice_cancel_amount, 0) ) -
    ( nvl(ln_old_invoice_apply_amount, 0)   + nvl(p_trx_invoice_apply_amount, 0) ) +
    (nvl(ln_old_invoice_unapply_amount, 0) + nvl(p_trx_invoice_unapply_amount, 0) );

    if ln_effective_threshold_amount < 0 then
      p_process_flag := 'E';
      p_process_message := 'Effective Total invoice amount for threshold cannot be negative.(Total Invoice - Cancel - apply + Unapply )' ;
      goto exit_from_procedure;
    end if;

    /* Check that total tax paid should not become negative */
    ln_effective_tax_paid := nvl(ln_old_tax_paid, 0) + nvl(p_trx_tax_paid, 0);
    if ln_effective_tax_paid < 0 then
      p_process_flag := 'E';
      p_process_message := 'Effective Tax Paid amount cannot be negative.' ;
      goto exit_from_procedure;
    end if;

	-- Bug 5722028. Added by Lakshmi Gopalsami
	ln_tmp_tds_amt := ROUND(nvl(p_trx_tax_paid,0),g_inr_currency_rounding);
	ln_tmp_tds_change := ROUND(nvl(p_trx_thhold_change_tax_paid,0), g_inr_currency_rounding);

	IF p_tds_event NOT IN
	  -- Bug 7280925. Commented by Lakshmi Gopalsami ('INVOICE CANCEL',
	  ('PREPAYMENT UNAPPLICATION') THEN
	IF trunc(p_creation_date) >=
	 trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
	 ln_tmp_tds_amt := get_rnded_value(ln_tmp_tds_amt);
	END IF;
	END IF;
    -- End if ;

    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
    update  jai_ap_tds_thhold_grps
    set
      total_invoice_amount          =    nvl(total_invoice_amount, 0)         + nvl(p_trx_invoice_amount, 0),
      total_invoice_cancel_amount   =    nvl(total_invoice_cancel_amount, 0)  + nvl(p_trx_invoice_cancel_amount, 0),
      total_invoice_apply_amount    =    nvl(total_invoice_apply_amount, 0)   + nvl(p_trx_invoice_apply_amount, 0),
      total_invoice_unapply_amount  =    nvl(total_invoice_unapply_amount, 0) + nvl(p_trx_invoice_unapply_amount, 0),
      total_tax_paid                =    nvl(total_tax_paid, 0)               + nvl(p_trx_tax_paid, 0),
      total_thhold_change_tax_paid  =    nvl(total_thhold_change_tax_paid, 0) + nvl(p_trx_thhold_change_tax_paid, 0),
      --current_threshold_slab_id     =    nvl( p_trx_threshold_slab_id, current_threshold_slab_id)
      --commented the above and added the below by Ramananda for Bug#4562793
      current_threshold_slab_id     =    nvl( p_trx_threshold_slab_id, 0),
      /*Bug 5751783. Updated non-rounded value*/
      total_calc_tax_paid           =    nvl(total_calc_tax_paid,0)           + nvl(p_trx_tax_paid,0)

    where threshold_grp_id = ln_threshold_grp_id;

    /* Get the new value */
    r_jai_ap_tds_thhold_grps := null;
    open  c_jai_ap_tds_thhold_grps(ln_threshold_grp_id);
    fetch c_jai_ap_tds_thhold_grps into r_jai_ap_tds_thhold_grps;
    close c_jai_ap_tds_thhold_grps;

    ln_new_invoice_amount               :=   r_jai_ap_tds_thhold_grps.total_invoice_amount;
    ln_new_invoice_cancel_amount        :=   r_jai_ap_tds_thhold_grps.total_invoice_cancel_amount;
    ln_new_invoice_apply_amount         :=   r_jai_ap_tds_thhold_grps.total_invoice_apply_amount;
    ln_new_invoice_unapply_amount       :=   r_jai_ap_tds_thhold_grps.total_invoice_unapply_amount;
    ln_new_tax_paid                     :=   r_jai_ap_tds_thhold_grps.total_tax_paid;
    ln_new_thhold_change_tax_paid       :=   r_jai_ap_tds_thhold_grps.total_thhold_change_tax_paid;
    ln_new_threshold_slab_id            :=   r_jai_ap_tds_thhold_grps.current_threshold_slab_id;

    /*Bug 5751783*/
    ln_calc_new_tax_paid                :=   r_jai_ap_tds_thhold_grps.total_calc_tax_paid;

    /* Insert into the audite table */
    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
    insert into jai_ap_tds_thgrp_audits
    (
      threshold_grp_audit_id               ,
      threshold_grp_id                     ,
      old_invoice_amount                   ,
      old_invoice_cancel_amount            ,
      old_invoice_apply_amount             ,
      old_invoice_unapply_amount           ,
      old_tax_paid                         ,
      old_thhold_change_tax_paid           ,
      old_threshold_slab_id                ,
      trx_invoice_amount                   ,
      trx_invoice_cancel_amount            ,
      trx_invoice_apply_amount             ,
      trx_invoice_unapply_amount           ,
      trx_tax_paid                         ,
      trx_thhold_change_tax_paid           ,
      trx_threshold_slab_id                ,
      new_invoice_amount                   ,
      new_invoice_cancel_amount            ,
      new_invoice_apply_amount             ,
      new_invoice_unapply_amount           ,
      new_tax_paid                         ,
      new_thhold_change_tax_paid           ,
      new_threshold_slab_id                ,
      tds_event                            ,
      invoice_id                           ,
      invoice_line_number                  ,
      invoice_distribution_id              ,
      remarks                              ,
      created_by                           ,
      creation_date                        ,
      last_updated_by                      ,
      last_update_date                     ,
      last_update_login                    ,
      /*Bug 5751783. Inserted non-rounded values also*/
      calc_old_tax_paid                    ,
      calc_trx_tax_paid                    ,
      calc_new_tax_paid
    )
    values
    (
      jai_ap_tds_thgrp_audits_s.nextval    ,
      ln_threshold_grp_id                  ,
      ln_old_invoice_amount                ,
      ln_old_invoice_cancel_amount         ,
      ln_old_invoice_apply_amount          ,
      ln_old_invoice_unapply_amount        ,
      ln_old_tax_paid                      ,
      ln_old_thhold_change_tax_paid        ,
      ln_old_threshold_slab_id             ,
      p_trx_invoice_amount                 ,
      p_trx_invoice_cancel_amount          ,
      p_trx_invoice_apply_amount           ,
      p_trx_invoice_unapply_amount         ,
      ln_tmp_tds_amt,  --added for bug#5722028 csahoo
      p_trx_thhold_change_tax_paid         ,
      p_trx_threshold_slab_id              ,
      ln_new_invoice_amount                ,
      ln_new_invoice_cancel_amount         ,
      ln_new_invoice_apply_amount          ,
      ln_new_invoice_unapply_amount        ,
      ln_new_tax_paid                      ,
      ln_new_thhold_change_tax_paid        ,
      ln_new_threshold_slab_id             ,
      p_tds_event                          ,
      p_invoice_id                         ,
      p_invoice_line_number                ,
      p_invoice_distribution_id            ,
      p_remarks                            ,
      fnd_global.user_id                   ,
      sysdate                              ,
      fnd_global.user_id                   ,
      sysdate                              ,
      fnd_global.login_id                  ,
      /*Bug 5751783*/
      ln_calc_old_tax_paid                 ,
      ln_calc_trx_tax_paid                 ,
      ln_calc_new_tax_paid
    )
    returning  threshold_grp_audit_id into p_threshold_grp_audit_id;
    p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
    <<exit_from_procedure>>

    p_codepath := jai_general_pkg.plot_codepath(100, p_codepath, null, 'END'); /* 1 */
    return;

  exception
    when others then
      fnd_file.put_line(FND_FILE.LOG,' Error in maintain thhold grps '|| substr(SQLERRM,1,200));
      p_process_flag := 'E';
      p_process_message := 'Error from jai_ap_tds_generation_pkg.maintain_thhold_grps :' || sqlerrm;
  end maintain_thhold_grps;

/* ********************************  maintain_thhold_grps *******************************************  */
/* ********************************  insert_tds_thhold_trxs *******************************************  */
	--for bug#4333449
  procedure insert_tds_thhold_trxs
  (
    p_invoice_id                        in                  number,
    p_tds_event                         in                  varchar2,
    p_tax_id                            in                  number     default null,
    p_tax_rate                          in                  number     default null,
    p_taxable_amount                    in                  number     default null,
    p_tax_amount                        in                  number     default null,
    p_tds_authority_vendor_id           in                  number     default null,
    p_tds_authority_vendor_site_id      in                  number     default null,
    p_invoice_tds_authority_num         in                  varchar2   default null,
    p_invoice_tds_authority_type        in                  varchar2   default null,
    p_invoice_tds_authority_curr        in                  varchar2   default null,
    p_invoice_tds_authority_amt         in                  number     default null,
    p_invoice_tds_authority_id          in                  number     default null,
    p_vendor_id                         in                  number     default null,
    p_vendor_site_id                    in                  number     default null,
    p_invoice_vendor_num                in                  varchar2   default null,
    p_invoice_vendor_type               in                  varchar2   default null,
    p_invoice_vendor_curr               in                  varchar2   default null,
    p_invoice_vendor_amt                in                  number     default null,
    p_invoice_vendor_id                 in                  number     default null,
    p_parent_inv_payment_priority       in                  number     default null,
    p_parent_inv_exchange_rate          in                  number     default null
  )
 is
 begin

   fnd_file.put_line(FND_FILE.LOG, ' Insert -> insert_tds_thhold_trxs ');

   insert into jai_ap_tds_thhold_trxs
   (
     threshold_trx_id                         ,
     invoice_id                               ,
     tds_event                                ,
     tax_id                                   ,
     tax_rate                                 ,
     taxable_amount                           ,
     tax_amount                               ,
     tds_authority_vendor_id                  ,
     tds_authority_vendor_site_id             ,
     invoice_to_tds_authority_num             ,
     invoice_to_tds_authority_type            ,
     invoice_to_tds_authority_curr            ,
     invoice_to_tds_authority_amt             ,
     invoice_to_tds_authority_id              ,
     vendor_id                                ,
     vendor_site_id                           ,
     invoice_to_vendor_num                    ,
     invoice_to_vendor_type                   ,
     invoice_to_vendor_curr                   ,
     invoice_to_vendor_amt                    ,
     invoice_to_vendor_id                     ,
     parent_inv_payment_priority              ,
     parent_inv_exchange_rate                 ,
     created_by                               ,
     creation_date                            ,
     last_updated_by                          ,
     last_update_date                         ,
     last_update_login
   )
   values
   (
     jai_ap_tds_thhold_trxs_s.nextval         ,
     p_invoice_id                             ,
     p_tds_event                              ,
     p_tax_id                                 ,
     p_tax_rate                               ,
     p_taxable_amount                         ,
     p_tax_amount                             ,
     p_tds_authority_vendor_id                ,
     p_tds_authority_vendor_site_id           ,
     p_invoice_tds_authority_num              ,
     p_invoice_tds_authority_type             ,
     p_invoice_tds_authority_curr             ,
     p_invoice_tds_authority_amt              ,
     p_invoice_tds_authority_id               ,
     p_vendor_id                              ,
     p_vendor_site_id                         ,
     p_invoice_vendor_num                     ,
     p_invoice_vendor_type                    ,
     p_invoice_vendor_curr                    ,
     p_invoice_vendor_amt                     ,
     p_invoice_vendor_id                      ,
     p_parent_inv_payment_priority            ,
     p_parent_inv_exchange_rate               ,
     fnd_global.user_id                       ,
     sysdate                                  ,
     fnd_global.user_id                       ,
     sysdate                                  ,
     fnd_global.login_id
     );

    fnd_file.put_line(FND_FILE.LOG, ' Done Insert -> insert_tds_thhold_trxs ');
	end insert_tds_thhold_trxs;

	/* ********************************  create_tds_after_holds_rel *******************************************  */

	-- Bug#5131075(4685754).  Added by Lakshmi Gopalsami
	-- Added for holds release

	Procedure create_tds_after_holds_release
	(
		errbuf                       out        nocopy    varchar2,
		retcode                      out        nocopy    varchar2,
		p_invoice_id                 IN  number,
		p_invoice_amount             IN  number,
		p_payment_status_flag        IN varchar2,
		p_invoice_type_lookup_code   IN varchar2,
		p_vendor_id                  IN  number,
		p_vendor_site_id             IN  number,
		p_accounting_date            IN DATE,
		p_invoice_currency_code      IN varchar2,
		p_exchange_rate              IN number,
		p_set_of_books_id            IN number,
		p_org_id                     IN number,
		p_call_from                  IN varchar2,
		p_process_flag               IN varchar2,
		p_process_message            IN varchar2,
		p_codepath                   IN varchar2,
		p_request_id                 IN number default null-- added, Harshita for Bug#5131075(5346558)
	) IS

		lv_is_invoice_validated       varchar2(1);
		lv_invoice_validation_status  varchar2(25);

		lv_process_flag               varchar2(1);
		lv_process_message            varchar2(200);
		lv_codepath                   varchar2(2000);

		--Start addition by sanjikum for Bug#5131075(4722011)
		lv_new_transaction_si         VARCHAR2(1);
		lv_new_transaction_pp         VARCHAR2(1);
		lv_prepay_flag                VARCHAR2(1);

		-- added, Harshita for Bug#5131075(5346558)
		ln_req_status  BOOLEAN      ;
		lv_phase       VARCHAR2(80) ;
		lv_status      VARCHAR2(80) ;
		lv_dev_phase   VARCHAR2(80) ;
		lv_dev_status  VARCHAR2(80) ;
		lv_message     VARCHAR2(80) ;

		CURSOR c_check_prepayment_apply(p_invoice_distribution_id   NUMBER)
		IS
		SELECT  '1'
		FROM    jai_ap_tds_prepayments
		WHERE   invoice_distribution_id_prepay = p_invoice_distribution_id;

		CURSOR c_check_prepayment_unapply(p_invoice_distribution_id_pp  NUMBER)
		IS
		SELECT  '1'
		FROM    jai_ap_tds_prepayments
		WHERE   invoice_distribution_id_prepay = p_invoice_distribution_id_pp
		AND     unapply_flag = 'Y';
		--End addition by sanjikum for Bug#5131075(4722011)

		/*START, Added by Bgowrava for Bug#9214036*/
		CURSOR c_get_rnd_factor (p_org_id IN NUMBER, p_inv_date in date ) IS
        SELECT  nvl(tds_rounding_factor,0), tds_rounding_start_date
        FROM jai_ap_tds_years
        WHERE legal_entity_id  = p_org_id
        AND trunc (p_inv_date) between start_date and end_date ;
		/*END, Added by Bgowrava for Bug#9214036*/

		lv_debug char(1) :='N'; -- Harshita, changed debug to 'N' for 5367640

		 -- Bug 5722028. Added by Lakshmi Gopalsami
		  cursor get_creation_date is
		  select creation_date
		    from ap_invoices_all
		   where invoice_id = p_invoice_id;
		  ld_creation_date DATE;
  -- End for bug 5722028.

	Begin

		 lv_codepath := p_codepath;

	  /*START, Added by Bgowrava for Bug#9214036*/
	  OPEN c_get_rnd_factor (p_org_id,p_accounting_date);
	  FETCH c_get_rnd_factor into JAI_AP_TDS_GENERATION_pkg.gn_tds_rounding_factor, JAI_AP_TDS_GENERATION_pkg.gd_tds_rounding_effective_date;
	  CLOSE c_get_rnd_factor ;
      /*END, Added by Bgowrava for Bug#9214036*/

		 -- Harshita for Bug#5131075(5346558)
			BEGIN
			 IF p_request_id is not null THEN
				ln_req_status :=  fnd_concurrent.wait_for_request
												 (request_id => p_request_id,
													interval   => 1,
													max_wait   => 0,
													phase      => lv_phase,
													status     => lv_status,
													dev_phase  => lv_dev_phase,
													dev_status => lv_dev_status,
													message    => lv_message)   ;

				 IF not ln_req_status THEN
					 FND_FILE.put_line(FND_FILE.log, 'Phase : ' || lv_phase || 'Status : ' || lv_status || 'Dev Phase : ' || lv_dev_phase ||
						' Dev Status : ' || lv_dev_status || ' Message : ' || lv_message );
					 FND_FILE.put_line(FND_FILE.log, 'Status of Completion of previous Concurrent Create TDS Invoice After Holds Release - Request Id ' || p_request_id || ' ' || SQLERRM );
				 END IF ;

			 END IF ;

				EXCEPTION
					WHEN OTHERS THEN
						FND_FILE.put_line(FND_FILE.log, 'Phase : ' || lv_phase || 'Status : ' || lv_status || 'Dev Phase : ' || lv_dev_phase ||
						' Dev Status : ' || lv_dev_status || ' Message : ' || lv_message );
					 FND_FILE.put_line(FND_FILE.log, 'Status of Completion of previous Concurrent Create TDS Invoice After Holds Release - Request Id ' || p_request_id || ' ' || SQLERRM );
			 END;


		 lv_invoice_validation_status :=
			 AP_INVOICES_UTILITY_PKG.get_approval_status(
						l_invoice_id                =>     p_invoice_id,
						l_invoice_amount            =>    p_invoice_amount,
						l_payment_status_flag       =>    p_payment_status_flag,
						l_invoice_type_lookup_code  =>    p_invoice_type_lookup_code);

		if lv_invoice_validation_status not in ('APPROVED', 'AVAILABLE', 'UNPAID') then
			lv_is_invoice_validated := 'N';
		Else
			lv_is_invoice_validated := 'Y';
		end if;

		if lv_debug='Y' then
			fnd_file.put_line(FND_FILE.LOG, ' value of validate'||lv_is_invoice_validated);
		end if ;

		if lv_is_invoice_validated = 'Y' then

		/*START, Added by Bgowrava for Bug#9214036*/
		OPEN get_creation_date;
        FETCH get_creation_date INTO ld_creation_date;
        CLOSE get_creation_date;
		/*END, Added by Bgowrava for Bug#9214036*/

			jai_ap_tds_generation_pkg.process_tds_at_inv_validate
				(
					p_invoice_id               =>     p_invoice_id,
					p_vendor_id                =>    p_vendor_id,
					p_vendor_site_id           =>     p_vendor_site_id,
					p_accounting_date          =>     p_accounting_date,
					p_invoice_currency_code    =>     p_invoice_currency_code,
					p_exchange_rate            =>     p_exchange_rate,
					p_set_of_books_id          =>     p_set_of_books_id,
					p_org_id                   =>     p_org_id,
					p_call_from                =>     p_call_from,
					p_creation_date            =>     ld_creation_date, -- Bug 5722028. Added by csahoo
					p_process_flag             =>     lv_process_flag,
					p_process_message          =>  lv_process_message,
					p_codepath                 =>     lv_codepath
				);

				--Moved this from below to here by Sanjikum for Bug#5131075(4722011)
			if   nvl(lv_process_flag, 'N') = 'E' then
				fnd_file.put_line(FND_FILE.LOG, ' Error in the concurrent program '|| lv_process_message);
				goto exit_from_procedure;
			END IF;

			--Start Addition by Sanjikum for Bug#5131075(4722011)
			FOR i IN(SELECT a.invoice_id,
												a.amount,
												a.invoice_distribution_id,
												a.parent_reversal_id,
												a.prepay_distribution_id,
												a.accounting_date,
												a.org_id,
												a.last_updated_by,
												a.last_update_date,
												a.created_by,
												a.creation_date,
												b.vendor_id,
												b.vendor_site_id,
												b.invoice_currency_code,
												b.exchange_rate,
												b.set_of_books_id
								FROM    ap_invoice_distributions_all a,
												ap_invoices_all b
								WHERE   a.invoice_id = b.invoice_id
								AND     b.invoice_id = p_invoice_id
								AND     a.line_type_lookup_code = 'PREPAY'
								AND     b.source <> 'TDS'
								AND     b.cancelled_date is null
								AND     invoice_type_lookup_code NOT IN ('CREDIT', 'DEBIT'))
			LOOP

				lv_prepay_flag := NULL;

				--Apply Scenario
				IF NVL(i.amount,0) < 0 THEN

					OPEN c_check_prepayment_apply(i.invoice_distribution_id);
					FETCH c_check_prepayment_apply INTO lv_prepay_flag;
					CLOSE c_check_prepayment_apply;

				--Unapply Scenario
				ELSIF NVL(i.amount,0) > 0 THEN

					OPEN c_check_prepayment_unapply(i.parent_reversal_id);
					FETCH c_check_prepayment_unapply INTO lv_prepay_flag;
					CLOSE c_check_prepayment_unapply;

				END IF;

				--should be run, only if prepayment application/unapplication is not already processed
				IF lv_prepay_flag IS NULL THEN


					jai_ap_tds_tax_defaultation.check_old_transaction
					(
					p_invoice_id                    =>    i.invoice_id,
					p_new_transaction               =>    lv_new_transaction_si
					);

					--Check for Pprepayment
					jai_ap_tds_tax_defaultation.check_old_transaction
					(
					p_invoice_distribution_id      =>    i.prepay_distribution_id,
					p_new_transaction               =>   lv_new_transaction_pp
					);

					if lv_new_transaction_si = 'Y' and lv_new_transaction_pp = 'Y' then

						lv_codepath := null;

						jai_ap_tds_prepayments_pkg.process_prepayment
						(
                            p_event                          =>     'INSERT',         --Added for Bug 8431516
							p_invoice_id                     =>     i.invoice_id,
							p_invoice_distribution_id        =>     i.invoice_distribution_id,
							p_prepay_distribution_id         =>     i.prepay_distribution_id,
							p_parent_reversal_id             =>     i.parent_reversal_id,
							p_prepay_amount                  =>     i.amount,
							p_vendor_id                      =>     i.vendor_id,
							p_vendor_site_id                 =>     i.vendor_site_id,
							p_accounting_date                =>     i.accounting_date,
							p_invoice_currency_code          =>     i.invoice_currency_code,
							p_exchange_rate                  =>     i.exchange_rate,
							p_set_of_books_id                =>     i.set_of_books_id,
							p_org_id                         =>     i.org_id,
							p_creation_date                  =>     i.creation_date, -- Bug 5722028
							p_process_flag                   =>     lv_process_flag,
							p_process_message                =>     lv_process_message,
							p_codepath                       =>     lv_codepath
						);

						if   nvl(lv_process_flag, 'N') = 'E' then
							raise_application_error(-20007,
							'Error - procedure jai_ap_tds_generation_pkg.create_tds_after_holds_release : ' || lv_process_message);
						end if;

					else
						--Invoke the old regime functionality
						jai_ap_tds_prepayments_pkg.process_old_transaction
						(
							p_invoice_id                     =>     i.invoice_id,
							p_invoice_distribution_id        =>     i.invoice_distribution_id,
							p_prepay_distribution_id         =>     i.prepay_distribution_id,
							p_amount                         =>     i.amount,
							p_last_updated_by                =>     i.last_updated_by,
							p_last_update_date               =>     i.last_update_date,
							p_created_by                     =>     i.created_by,
							p_creation_date                  =>     i.creation_date,
							p_org_id                         =>     i.org_id,
							p_process_flag                   =>     lv_process_flag,
							p_process_message                =>     lv_process_message
						);

						if   nvl(lv_process_flag, 'N') = 'E' then
							raise_application_error(-20008,
							'Error - procedure jai_ap_tds_generation_pkg.create_tds_after_holds_release : ' || lv_process_message);
						end if;
					end if; --Transactions in new regime

				END IF;

			END LOOP;

			<< exit_from_procedure >>

			NULL;

			--End Addition by Sanjikum for Bug#5131075(4722011)

			Else
				fnd_file.put_line(FND_FILE.LOG,' Not generating the TDS invoice
																		as the parent invoice is not yet validated');
				retcode := 1;
			End if; /* lv_is_invoice_validated = 'Y' */

	End create_tds_after_holds_release;
	-- End for bug#5131075(4685754)

	/* ********************************  create_tds_after_holds_rel *******************************************  */

  --new procedure created by sanjikum for bug#5131075(4718907)
  --This procedure gives the current threshold slab
  PROCEDURE get_tds_threshold_slab( p_prepay_distribution_id  IN              NUMBER,
                                    p_threshold_grp_id        IN OUT  NOCOPY  NUMBER,
                                    p_threshold_hdr_id        IN OUT  NOCOPY  NUMBER,
                                    p_threshold_slab_id       OUT     NOCOPY  NUMBER,
                                    p_threshold_type          OUT     NOCOPY  VARCHAR2,
                                    p_process_flag            OUT     NOCOPY  VARCHAR2,
                                    p_process_message         OUT     NOCOPY  VARCHAR2,
                                    p_codepath                IN OUT  NOCOPY  VARCHAR2)
  IS
    CURSOR c_get_threshold_grp_id(p_prepay_distribution_id  NUMBER)
    IS
    SELECT  threshold_grp_id
    FROM    jai_ap_tds_inv_taxes
    WHERE   invoice_distribution_id = p_prepay_distribution_id
    AND     section_type = 'TDS_SECTION';

    CURSOR c_get_threshold_grp_dtl(p_threshold_grp_id NUMBER)
    IS
    SELECT  *
    FROM    jai_ap_tds_thhold_grps
    WHERE   threshold_grp_id = p_threshold_grp_id;

    CURSOR c_get_threshold_hdr(p_vendor_id      NUMBER,
                                p_org_tan_num   VARCHAR2,
                                p_pan_num       VARCHAR2,
                                p_section_type  VARCHAR2,
                                p_section_code  VARCHAR2)
    IS
    SELECT  threshold_hdr_id
    FROM    jai_ap_tds_th_vsite_v
    WHERE   vendor_id     = p_vendor_id
    AND     tan_no        = p_org_tan_num
    AND     pan_no        = p_pan_num
    AND     section_type  = p_section_type
    AND     section_code  = p_section_code;

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
    r_jai_ap_tds_thhold_slabs c_jai_ap_tds_thhold_slabs%ROWTYPE;
    lv_threshold_type         jai_ap_tds_thhold_types.threshold_type%TYPE;

  BEGIN
    IF p_threshold_grp_id IS NULL THEN
      OPEN c_get_threshold_grp_id(p_prepay_distribution_id);
      FETCH c_get_threshold_grp_id INTO p_threshold_grp_id;
      CLOSE c_get_threshold_grp_id;
    END IF;

    OPEN c_get_threshold_grp_dtl(p_threshold_grp_id);
    FETCH c_get_threshold_grp_dtl INTO r_get_threshold_grp_dtl;
    CLOSE c_get_threshold_grp_dtl;

    IF p_threshold_hdr_id IS NULL THEN
      OPEN c_get_threshold_hdr(r_get_threshold_grp_dtl.vendor_id,
                               r_get_threshold_grp_dtl.org_tan_num,
                               r_get_threshold_grp_dtl.vendor_pan_num,
                               r_get_threshold_grp_dtl.section_type,
                               r_get_threshold_grp_dtl.section_code);
      FETCH c_get_threshold_hdr INTO p_threshold_hdr_id;
      CLOSE c_get_threshold_hdr;
    END IF;

    ln_effective_invoice_amt := r_get_threshold_grp_dtl.total_invoice_amount -
                                r_get_threshold_grp_dtl.total_invoice_cancel_amount -
                                r_get_threshold_grp_dtl.total_invoice_apply_amount +
                                r_get_threshold_grp_dtl.total_invoice_unapply_amount;

    lv_threshold_type := 'CUMULATIVE';

    --check if the current amount falls in the cumulative threshold
    OPEN c_jai_ap_tds_thhold_slabs(p_threshold_hdr_id,
                                  lv_threshold_type,
                                  ln_effective_invoice_amt);
    FETCH c_jai_ap_tds_thhold_slabs INTO r_jai_ap_tds_thhold_slabs;
    CLOSE c_jai_ap_tds_thhold_slabs;

    IF r_jai_ap_tds_thhold_slabs.threshold_slab_id IS NULL THEN

      lv_threshold_type := 'SINGLE';

      --check if the current amount falls in the single threshold
      OPEN c_jai_ap_tds_thhold_slabs(p_threshold_hdr_id,
                                    lv_threshold_type,
                                    99999999999999);
      FETCH c_jai_ap_tds_thhold_slabs INTO r_jai_ap_tds_thhold_slabs;
      CLOSE c_jai_ap_tds_thhold_slabs;
    END IF;

    p_threshold_slab_id := r_jai_ap_tds_thhold_slabs.threshold_slab_id;
    p_threshold_type := lv_threshold_type;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_flag := 'E';
      p_process_message := SUBSTR(SQLERRM,1,200);
  END get_tds_threshold_slab;


  --new procedure created by sanjikum for bug#5131075(4718907)
  --This procedure takes as input the old and new threshold and checks if any type of Threshold Rollback processing is required

  PROCEDURE process_threshold_rollback( p_invoice_id                IN              VARCHAR2,
                                        p_before_threshold_type     IN              VARCHAR2,
                                        p_after_threshold_type      IN              VARCHAR2,
                                        p_before_threshold_slab_id  IN              NUMBER,
                                        p_after_threshold_slab_id   IN              NUMBER,
                                        p_threshold_grp_id          IN              NUMBER,
                                        p_org_id                    IN              NUMBER,
                                        p_accounting_date           IN              DATE,
                                        p_invoice_distribution_id   IN              NUMBER DEFAULT NULL,
                                        p_prepay_distribution_id    IN              NUMBER DEFAULT NULL,
                                        p_process_flag              OUT     NOCOPY  VARCHAR2,
                                        p_process_message           OUT     NOCOPY  VARCHAR2,
                                        p_codepath                  IN OUT  NOCOPY  VARCHAR2)
  IS

    CURSOR  c_threshold_slab(p_threshold_slab_id  NUMBER,
                             p_org_id           NUMBER)
    IS
    SELECT  b.tax_rate,
            b.from_amount,
            a.tax_id
    FROM    jai_ap_tds_thhold_taxes a,
            jai_ap_tds_thhold_slabs b
    WHERE   a.threshold_slab_id = b.threshold_slab_id
    AND     a.operating_unit_id = p_org_id
    AND     b.threshold_slab_id = p_threshold_slab_id;

    CURSOR c_threshold_grp(p_threshold_grp_id NUMBER)
    IS
    SELECT  *
    FROM    jai_ap_tds_thhold_grps
    WHERE   threshold_grp_id = p_threshold_grp_id;

    CURSOR c_taxable_amount(c_threshold_grp_id      NUMBER,
                            c_single_threshold_amt  NUMBER)
    IS
    SELECT  NVL(SUM(a.taxable_amount),0) taxable_amount
    FROM    jai_ap_tds_thhold_trxs a
    WHERE   a.threshold_grp_id = c_threshold_grp_id
    AND     a.tds_event = 'INVOICE VALIDATE'
    AND     a.taxable_amount >= c_single_threshold_amt
    AND     NOT EXISTS (SELECT '1'
                        FROM    jai_ap_tds_inv_cancels b
                        WHERE   a.invoice_id = b.invoice_id);

    CURSOR c_prepayments(c_threshold_grp_id NUMBER)
    IS
    SELECT  *
    FROM    jai_ap_tds_prepayments
    WHERE   tds_threshold_grp_id = c_threshold_grp_id
    AND     NVL(unapply_flag,'N') <> 'Y';

    CURSOR c_thhold_trxs(p_invoice_distribution_id  NUMBER,
                         p_single_threshold_amt     NUMBER)
    IS
    SELECT  'Y'
    FROM    jai_ap_tds_thhold_trxs a,
            jai_ap_tds_inv_taxes b
    WHERE   a.invoice_id = b.invoice_id
    AND     b.invoice_distribution_id = p_invoice_distribution_id
    AND     a.tds_event = 'INVOICE VALIDATE'
    AND     a.taxable_amount >= p_single_threshold_amt;

    r_threshold_slab          c_threshold_slab%ROWTYPE;
    r_before_threshold_slab   c_threshold_slab%ROWTYPE;
    ln_effective_invoice_amt  NUMBER;
    ln_effective_tds_amt      NUMBER;
    ln_diff_tds_amount        NUMBER;
    r_threshold_grp           c_threshold_grp%ROWTYPE;
    v_si_flag                 VARCHAR2(1);
    v_pp_flag                 VARCHAR2(1);
    lv_tds_event              jai_ap_tds_thhold_trxs.tds_event%TYPE;
    lv_tds_invoice_num        ap_invoices_all.invoice_num%type;
    lv_tds_cm_num             ap_invoices_all.invoice_num%type;
    ln_threshold_trx_id       jai_ap_tds_thhold_trxs.threshold_trx_id%TYPE;
    ln_threshold_grp_audit_id jai_ap_tds_thgrp_audits.threshold_grp_audit_id%TYPE;
    ln_threshold_grp_id       jai_ap_tds_thhold_grps.threshold_grp_id%TYPE;

    /* Bug 5751783.
     * Get the sum of invoice amount for which TDS is not calculated
    */
    CURSOR get_tds_not_deducted ( cp_threshold_grp_id IN NUMBER )
    IS
    SELECT SUM (NVL (jatit.amount , 0 ) )
      FROM jai_ap_tds_inv_taxes jatit
      WHERE jatit.threshold_grp_id = cp_threshold_grp_id
         AND match_status_flag = 'A'
         AND jatit.process_status = 'P'
         AND jatit.tax_amount IS NOT NULL
         AND jatit.threshold_trx_id IS NULL
         AND jatit.threshold_slab_id = 0
         AND ( jatit.actual_tax_id IS NOT NULL OR
                 ( jatit.actual_taX_id IS  NULL
                   AND  jatit.default_tax_id IS NOT NULL
                 )
             )
          AND  EXISTS /* check whether iinvoice is not cancelled*/
             ( SELECT invoice_id
               FROM ap_invoices_all ai
               WHERE ai.invoice_id = jatit.invoice_id
                  AND ai.cancelled_Date IS NULL
                  AND ai.cancelled_amount IS NULL
             );

    /* Get the prepayment amount which is applied and RTN invoice
     * is not yet generated.
     */
    CURSOR get_ppau_tds_not_deducted (cp_threshold_grp_id IN NUMBER )
    IS
    SELECT SUM (NVL (jatp.application_amount, 0 ))
      FROM jai_ap_tds_prepayments jatp
      WHERE jatp.tds_threshold_grp_id = cp_threshold_grp_id
         AND jatp.tds_applicable_flag   = 'Y'
         AND jatp.tds_threshold_trx_id_apply IS NULL
         AND jatp.unapply_flag IS NULL OR jatp.unapply_flag = 'N' ;

    ln_tds_not_deducted         NUMBER ;
    ln_pp_tds_not_deducted      NUMBER ;
    ln_thhold_trxn_trsn         NUMBER ;
    ln_taxable_amount           NUMBER ;

    /*Bug 5751783 - End*/
    CURSOR get_thhold_transn (cp_threshold_grp_id IN NUMBER )
	 IS
	 SELECT SUM(NVL(jattt.taxable_amount,0))
		 FROM jai_ap_tds_thhold_trxs jattt
		WHERE jattt.threshold_grp_id = cp_threshold_grp_id
			AND ( jattt.tds_event like 'THRESHOLD TRANSITION%' OR
		-- Bug 5722028. Added by csahoo
		-- added the following condition
				 jattt.tds_event like 'THRESHOLD ROLLBACK%'
	    );

	   -- bug 5722028. Added by csahoo
   ln_taxable_thhold_change    NUMBER;

    FUNCTION get_pp_threshold(p_invoice_distribution_id   IN  NUMBER,
                              p_single_threshold_amt      IN  NUMBER)
    RETURN VARCHAR2
    IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      CURSOR cur_thhold_trxs IS
      SELECT  'Y'
      FROM    jai_ap_tds_thhold_trxs a
      WHERE   a.tds_event = 'INVOICE VALIDATE'
      AND     a.taxable_amount >= p_single_threshold_amt
      AND     a.invoice_id IN (SELECT invoice_id
                              FROM    ap_invoice_distributions_all
                              WHERE   invoice_distribution_id  = (SELECT  prepay_distribution_id
                                                                  FROM    ap_invoice_distributions_all
                                                                  WHERE   invoice_distribution_id = p_invoice_distribution_id));
      lv_pp_flag  VARCHAR2(1);

    BEGIN
      OPEN cur_thhold_trxs;
      FETCH cur_thhold_trxs INTO lv_pp_flag;
      CLOSE cur_thhold_trxs;

      RETURN lv_pp_flag;

    END get_pp_threshold;

  BEGIN

    /*
      This functionality is required only if Threshold changes from any of the cumulative threshold slabs
      to either Single or any other cumulative threshold slab
      We need to check, only if the earlier threshold type is cumulative
      if the earlier type is single, it can't change to cumulative
    */

    IF p_before_threshold_type = 'CUMULATIVE' THEN

      --There is no change in the threshold slab. Means it is still in the same cumulative slab
      IF p_before_threshold_slab_id = p_after_threshold_slab_id THEN

        NULL; --Nothing is required to be done, as there is no slab change

      --There is a change in the slab. New slab is either cumulative or single
      ELSE

        OPEN c_threshold_grp(p_threshold_grp_id);
        FETCH c_threshold_grp INTO r_threshold_grp;
        CLOSE c_threshold_grp;

        OPEN c_threshold_slab(p_threshold_slab_id => p_after_threshold_slab_id,
                              p_org_id            => p_org_id);
        FETCH c_threshold_slab INTO r_threshold_slab;
        CLOSE c_threshold_slab;

        --This is required, if there is no setup for the current threshold
        OPEN c_threshold_slab(p_threshold_slab_id => p_before_threshold_slab_id,
                              p_org_id            => p_org_id);
        FETCH c_threshold_slab INTO r_before_threshold_slab;
        CLOSE c_threshold_slab;

        --If the new threshold type/slab is cumulative
        IF p_after_threshold_type = 'CUMULATIVE' THEN

          ln_effective_invoice_amt := r_threshold_grp.total_invoice_amount -
                                      r_threshold_grp.total_invoice_cancel_amount -
                                      r_threshold_grp.total_invoice_apply_amount +
                                      r_threshold_grp.total_invoice_unapply_amount;

        --If the new threshold type/slab is single
        ELSE

          --If there is no single threshold setup done
          IF p_after_threshold_slab_id IS NULL THEN
            ln_effective_invoice_amt := 0;
          ELSE

            --Calculate the TDS, based on the single threshold and pass the entry for the TDS amount

            --Get all the invoice validations, where invoice amount is > single threshold amount
            OPEN c_taxable_amount(c_threshold_grp_id      =>  p_threshold_grp_id,
                                  c_single_threshold_amt  =>  r_threshold_slab.from_amount);
            FETCH c_taxable_amount INTO ln_effective_invoice_amt;
            CLOSE c_taxable_amount;

						/* Bug 5722028. Added by Lakshmi Gopalsami
						 * We need to fetch the sum of taxable as part of threshold
						 * transition or rollback as this would have been populated
						 * with the amount of invoice on which TDS is not deducted.
						 */

						OPEN get_thhold_transn( cp_threshold_grp_id => p_threshold_grp_id );
							FETCH get_thhold_transn INTO ln_taxable_thhold_change;
						CLOSE get_thhold_transn;

	    			ln_effective_invoice_amt := ln_effective_invoice_amt + nvl(ln_taxable_thhold_change,0);

            --If there are any invoices more than Single threshold, only then need to progress
            IF ln_effective_invoice_amt > 0 THEN

              --Get all the prepayments applied in the current threshold group
              FOR i IN c_prepayments(p_threshold_grp_id)  LOOP

                v_si_flag := NULL;

                --For SI. Check if the invoice amount of SI is more than Single threshold
                OPEN c_thhold_trxs(i.invoice_distribution_id,
                                   r_threshold_slab.from_amount);
                FETCH c_thhold_trxs INTO v_si_flag;
                CLOSE c_thhold_trxs;

                v_pp_flag := NULL;

                --For PP. Check if the invoice amount of SI is more than Single threshold
                --If the current transaction is PP application. As in the else part the autonomous function is
                --being used, which wouldn't be able to see the current transaction...means the PP application
                IF p_invoice_distribution_id = i.invoice_distribution_id_prepay THEN

                  OPEN c_thhold_trxs(p_prepay_distribution_id,
                                     r_threshold_slab.from_amount);
                  FETCH c_thhold_trxs INTO v_pp_flag;
                  CLOSE c_thhold_trxs;
                ELSE
                  --Here the autonomous function is used, as it is required to select from ap_invoice_distributions table.
                  --If this function is not used, this shall give the mutating error
                  v_pp_flag := get_pp_threshold(i.invoice_distribution_id_prepay, r_threshold_slab.from_amount);
                END IF;

                --If both the SI and PP have invoice amount > Single threshold, then adjustment amount need to be calculated
                IF NVL(v_si_flag,'N') = 'Y' AND NVL(v_pp_flag,'N') = 'Y' THEN
                  ln_effective_invoice_amt := ln_effective_invoice_amt - NVL(i.application_amount,0);
                END IF;

              END LOOP; --c_prepayments

            END IF; --ln_effective_invoice_amt > 0

            /*  Bug 5751783
             *  Get the taxable basis for threshold rollback.
             *  Calculate the taxable amount.
             */

            fnd_file.put_line(FND_FILE.LOG,'  inside rollback ');
            OPEN get_tds_not_deducted ( p_threshold_grp_id );
            FETCH get_tds_not_deducted INTO ln_tds_not_deducted;
            CLOSE get_tds_not_deducted;
            -- TDS not deducted for Prepayment application
            OPEN get_ppau_tds_not_deducted(p_threshold_grp_id);
            FETCH get_ppau_tds_not_deducted INTO ln_pp_tds_not_deducted;
            CLOSE get_ppau_tds_not_deducted;
            -- Get the transitioned taxable amount
            OPEN get_thhold_transn(p_threshold_grp_id);
            FETCH get_thhold_transn INTO ln_thhold_trxn_trsn;
            CLOSE get_thhold_transn;

            fnd_file.put_line(FND_FILE.LOG,'SI not deducted ' || ln_tds_not_deducted);
            fnd_file.put_line(FND_FILE.LOG,'PPA/U not deducted ' || ln_pp_tds_not_deducted);
            fnd_file.put_line(FND_FILE.LOG,'Transitioned taxable amount ' || ln_thhold_trxn_trsn);
            ln_taxable_amount := NVL(ln_tds_not_deducted,0) -
                                 NVL(ln_pp_tds_not_deducted,0)-
                                 NVL(ln_thhold_trxn_trsn,0);
            fnd_file.put_line(FND_FILE.LOG,'Remaining taxable amount' || ln_taxable_amount);


          END IF;

        END IF;

        IF NVL(ln_effective_invoice_amt,0) = 0 THEN
          ln_effective_tds_amt := 0;
        ELSE
          /*Bug 5751783. Removed the rounding as this will be used for reverse calculation of invoice amount*/
          ln_effective_tds_amt := ROUND(ln_effective_invoice_amt * (r_threshold_slab.tax_rate/100), g_inr_currency_rounding);
        END IF;

        IF trunc(sysdate) >=
           trunc(jai_ap_tds_generation_pkg.gd_tds_rounding_effective_date) THEN
            ln_effective_tds_amt := get_rnded_value(ln_effective_tds_amt);
        END IF;

        /*Bug 5721614. Used the non-rounded value for calculation*/
        ln_diff_tds_amount := r_threshold_grp.total_tax_paid - ln_effective_tds_amt;


        IF ln_diff_tds_amount > 0 THEN

          --There is an excess TDS payment/deduction. So need to create RTN invoice for the TDS Authority and SI for Vendor for ln_diff_tds_amount

          lv_tds_event := 'THRESHOLD ROLLBACK( from slab id - '||p_before_threshold_slab_id||' to slab id - '||p_after_threshold_slab_id||')';

          jai_ap_tds_generation_pkg.generate_tds_invoices
          (
            pn_invoice_id              =>      p_invoice_id           ,
            /* Bug 5751783. Changed null to calculated value for taxable amount.
             * This value is not rounded as we are performing one more rounding in
             * procedure generate_Tds_invoices.
             * Removed (ln_diff_tds_amount/ r_threshold_slab.tax_rate ) * 100
             * and added ln_taxable_amount
             */
            pn_taxable_amount          =>      NVL(ln_taxable_amount,0),
            --No taxable amount in case of threshold rollback invoice
            pn_tax_amount              =>      ln_diff_tds_amount      ,
            pn_tax_id                  =>      NVL(r_threshold_slab.tax_id, r_before_threshold_slab.tax_id) ,
            pd_accounting_date         =>      p_accounting_date      ,
            pv_tds_event               =>      lv_tds_event            ,
            pn_threshold_grp_id        =>      p_threshold_grp_id    ,
            pv_tds_invoice_num         =>      lv_tds_invoice_num     ,
            pv_cm_invoice_num          =>      lv_tds_cm_num          ,
            pn_threshold_trx_id        =>      ln_threshold_trx_id    ,
            pd_creation_date            =>      sysdate, -- Bug 5722028. Added by csahoo
            p_process_flag             =>      p_process_flag         ,
            p_process_message          =>      p_process_message
          );

          if p_process_flag = 'E' then
            goto exit_from_procedure;
          end if;

          IF ln_threshold_trx_id IS NOT NULL THEN
            jai_ap_tds_generation_pkg.import_and_approve
            (
              p_invoice_id                   =>     p_invoice_id,
              p_start_thhold_trx_id          =>     ln_threshold_trx_id,
              p_tds_event                    =>     lv_tds_event,
              p_process_flag                 =>     p_process_flag,
              p_process_message              =>     p_process_message
            );
          END IF;

          --Update the total tax amount for which invoice was raised
          ln_threshold_grp_id := p_threshold_grp_id;

          maintain_thhold_grps
          (
            p_threshold_grp_id             =>   ln_threshold_grp_id,
            p_trx_tax_paid                 =>   ln_diff_tds_amount*-1, --Multiplied by -1, as this should reduce the total tax amount
            p_trx_thhold_change_tax_paid   =>   ln_diff_tds_amount*-1,
            p_trx_threshold_slab_id        =>   p_after_threshold_slab_id,
            p_tds_event                    =>   lv_tds_event,
            p_invoice_id                   =>   p_invoice_id,
            p_threshold_grp_audit_id       =>   ln_threshold_grp_audit_id,
            -- Bug 5722028. Added by Lakshmi Gopalsami
	    			p_creation_date                =>   sysdate,
            p_process_flag                 =>   p_process_flag,
            P_process_message              =>   P_process_message,
            p_codepath                     =>   p_codepath
         );

          IF p_process_flag = 'E' THEN
            goto exit_from_procedure;
          END IF;

        END IF;

      END IF;

    END IF;

    <<exit_from_procedure>>

    NULL;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_flag := 'E';
      p_process_message := SUBSTR(SQLERRM,1,200);
  END process_threshold_rollback;

  -- Bug 5722028. Added by csahoo
	  FUNCTION get_rnded_value (p_tax_amount in number)
	  RETURN NUMBER AS
	   ln_tmp_tax_amt number ;
	   ln_tds_mod_value number ;
	   ln_tds_sign number;
	  BEGIN
	   ln_tds_sign := sign(p_tax_amount);
	   ln_tmp_tax_amt := abs(p_tax_amount);

	  IF jai_ap_tds_generation_pkg.gn_tds_rounding_factor = -1 then
	    ln_tds_mod_value := 0;
	    ln_tds_mod_value := MOD(ROUND(ln_tmp_tax_amt,
	                                   g_inr_currency_rounding),10);
	    IF ln_tds_mod_value >= 5 THEN
	      ln_tmp_tax_amt := ln_tmp_tax_amt + (10-ln_tds_mod_value);
	    ELSE -- < 5
	      ln_tmp_tax_amt := ln_tmp_tax_amt - ln_tds_mod_value;
	    END IF ;
	  END IF ; -- jai_ap_tds_generation_pkg.gn_tds_rounding_factor = -1
	  return (ln_tmp_tax_amt* ln_tds_sign );
	  END get_rnded_value;
  -- End for bug 5722028.


END jai_ap_tds_generation_pkg;

/
