--------------------------------------------------------
--  DDL for Package Body JAI_RCV_RCV_RTV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_RCV_RTV_PKG" AS
/* $Header: jai_rcv_rcv_rtv.plb 120.21.12010000.8 2010/02/02 06:21:13 srjayara ship $ */

/* --------------------------------------------------------------------------------------
Filename: jai_rcv_rcv_rtv_pkg.sql

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
06-sep-2004  3848010     Created by Aparajita for correction ER#3848010. version#115.0.

                         This package has been developed as a part of correction ER#3496408.
                         This takes care of the non cenvat processing of RECEIVE and RTV
                         type of transactions along with their CORRECT transactions.

                         Process_transaction procedure of this package is the procedure which is
                         called for processing of RECEIVE and RTV for a particular transaction id.
                         process_transaction calls the following procedures of this package for
                         the processing.

                         get_accounts
                         get_tax_breakup
                         validate_transaction_tax_accnt
                         apply_relieve_boe. This further calls one of this
                          apply_boe
                          relieve_boe
                         post_entries


18-jan-2005              Service Tax and Education Cess. Version#115.1
              4106633    Base Bug For Education Cess on Excise, CVD and Customs.
              4059774    Base Bug For Service Tax Regime Implementation.
              4078546    Modification in receive and rtv accounting for service tax

                         For Education Cess Implementation, following changes are done.
                              1. Taxes of type Excise Cess are considered
                                  along with taxes of type Excise.

                              2. Taxes of type CVD Cess are considered
                                  along with taxes of type CVD.

                              2. Taxes of type Custom Cess are considered
                                  along with taxes of type Custom.

                         For Implementation of Service tax, wherever recoverable
                         service tax exists following changes are done.

                              1. Receiving account is excluding recoverable service tax.
                              2. Accrual account excludes recoverable service tax conditionally.
                              3. Recoverable serive tax amount should be posted to interim
                                 service tax account defined for the org and the tax type
                                 conditionally.

                                 Service Tax accounting is debit for receive and it's corrections
                                 and credit for RTV and it's corrections.

                         Procedure service_tax_accounting has been introduced to take care of
                         accounting for the interim service tax account entries.

17-feb-2005    4171469   ISO accounting for trading to trading ISO scenarios. Version#115.2

                         Eariler trading to trading ISO accounting was not happening. This was
                         because this program unit was not called in that scenarios. Now it
                         is being called from India receiving transaction processor.

                         Changes done for this scenario are, for trading to trading ISO following
                         account entries are required.

                         debit inventory receiving
                         credit intransit inventory account

                         Additional entry of inter org payable and inter org receivable are not required.


                        No dependency.

03-Mar-2005    Vijay Shankar for Bug#4215402, Version:115.3
                 po_distribution_id is populated as null in rcv_Transactions for non inventory items.
                 so to get accrue_on_receipt_flag from PO, we need line_location_id instead of
                 po_distribution_id. So changes are made to pass line_location_id also to
                 jai_rcv_trx_processing_pkg.get_accrue_on_receipt function


19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 116.0(115.5)
                .Modified regime_tax_accounting_interim to work for any regime taxes based on regime setup
                .Made a call to regime_tax_accounting_interim for VAT Regime if recoverable vat taxes exist in the transaction
                .two new parameters are added in get_tax_breakup and post_entries procedure
                . Removed the rounding that is happening in get_tax_breakup procedure
                Other changes for VAT Implementation are made in the package apart from above changes

 10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                 Code is modified due to the Impact of Receiving Transactions DFF Elimination

              * High Dependancy for future Versions of this object *

08-Jun-2005   File Version 116.2. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
              as required for CASE COMPLAINCE.

13-Jun-2005   Ramananda for bug#4428980. File Version: 116.3
              Removal of SQL LITERALs is done

06-Jul-2005   Sanjikum for Bug#4474501
              Commented the Call to function - jai_general_pkg.get_accounting_method

              Ramananda for bug#4477004. File Version: 116.4
              GL Sources and GL Categories got changed. Refer bug for the details

27/07/2005   Ramananda for Bug#4516577. File Version 120.3
             Problem
             -------
             ISO Accounting Entries from Trading to Excise bonded inventory are not generated in case of following Scenarios
             1. Trading organization to Trading Organization (only  Source organizations with the 'Excise in RG23D' setup).
             2. Trading organization to Manufacturing Organization (Source Organization with the 'Excise in RG23D' setup).

             Fix
             ---
             In the Procedure get_accounts made the following changes -
             1. In the cursor - c_ja_in_hr_organization_units,
                added a new column - "NVL(manufacturing, 'N') receiving_org_manufacturing" in the select
             2. Changed the if condition -
                "if  r_iso_from_org_type.source_org_trading = 'Y' and
                    ( r_ja_in_hr_organization_units.receving_org_trading = 'Y'
                      OR
                      r_ja_in_hr_organization_units1.receving_org_trading = 'Y'
                    )
               TO
               "if  r_iso_from_org_type.source_org_trading = 'Y' and
                  ( r_ja_in_hr_organization_units.receving_org_trading = 'Y'
                    OR
                    r_ja_in_hr_organization_units1.receving_org_trading = 'Y'
                    OR                                                           --Added the OR Condition by Ramananda for Bug #4516577
                    r_ja_in_hr_organization_units.receiving_org_manufacturing = 'Y'
                    OR                                                           --Added the OR Condition by Ramananda for Bug #4516577
                    r_ja_in_hr_organization_units1.receiving_org_manufacturing = 'Y'
                  )

             (Functional)  Dependency Due to This Bug
             --------------------------
             jai_rcv_trx_prc.plb  (120.2)
             jai_om_rg.plb        (120.2)

27/07/2005   Ramananda for Bug#4514461, File Version 120.3
             Problem
             -------
             On creating the receipt, system is giving the error - Both Credit and Debit are Zero

             Fix
             ---
             In the Procedure ja_in_receive_rtv_pkg.regime_tax_accounting_interim, before calling ja_in_receipt_accounting_pkg
             Commented the condition -- if (ln_debit is not null or ln_credit is not null) then
             And added the condition -- if (NVL(ln_debit,0) <> 0 OR NVL(ln_credit,0) <> 0) then

             Future Dependency due to this Bug
             ---------------------------------
             None

28/11/2005 Harshita for Bug 4762433, File Version 120.4
           Issue :
           a) lv_source_name was declared with length 15 and assigned the value
              'Purchasing India' which is of length 16 .
           b) Who column information missing in the insert to the table JAI_RCV_REP_ACCRUAL_T.
           Fix :
           a) Modified the size of the variable lv_source_name from 15 to 20.
              Changes made in the post_entries and regime_tax_accounting_interim procedures.
           b) Added the who columns in the insert of JAI_RCV_REP_ACCRUAL_T.
              Change made in the post_entries procedures.
            Future Dependency due to this Bug
            ---------------------------------
             None

30/10/2006 sacsethi for bug 5228046, File version 120.5
            Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
            This bug has datamodel and spec changes.

23/02/07      bduvarag for bug#5527885,File version 120.4
               Forward porting the changes done in 11i bug#5478427
	      bduvarag for bug#5632406,File version 120.4
               Forward porting the changes done in 11i bug#5603081
13/04/2007	bduvarag for the Bug#5989740, file version 120.11
		Forward porting the changes done in 11i bug#5907436

25-April-2007   ssawant for bug 5879769 ,File version 120.5
                Forward porting of
		ENH : SERVICE TAX BY INVENTORY ORGANIZATION AND SERVICE TYPE SOLUTION
		from 11.5( bug no 5694855) to R12 (bug no 5879769).

17-aug-2007     vkaranam for bug 6030615,File version 120.11
                Fwdporting of 115 bug 2942973(Interorg)
21-aug-2007     vkaranam for bug 6030615,File version 120.12
                Issue:
                In R12 we should not use org_organization_defintions view as this will cause the performance degradation.
                Changes are done as per the requirement.

03-dec-2007     Eric modified cursor c_ja_in_receipt_tax_lines  and cursor
                c_ja_in_tax_amt_by_account to pick up the exclusive taxes only

18-FEB-2008:     Changes done by nprashar for Bug #6807023. Changed the value of variable lv_organization_type to jai_constants.orgn_type_io;

15-Apr-2008     rchandan for bug#6971526, File version 120.21
                  Issue : ST2-VAT CLAIM AMOUNT IS NOT RIGHT FOR PARTIALLY RECOVERABLE VAT TAX.
                  Fix : Changes made for bug#6681800 in version 120.16 were missed out when
                        120.17 was arcsed in. Redone the changes.

12-Nov-2008  Modified by JMEENA for bug#7310836
		   Modified the procedure process_transaction and added condition that checks the count of pl/sql table tr_jv.
		   If count is greater than zero then only it will proceed for accounting.

13-Nov-2008   Changes by nprashar for bug  6321337 , FP changes of 11i bug 6200218.Changes has been made in procedure
                     get_accounts to pass the appropirate accounting entries while performing the ISO cycle.
                     trading to trading.

23-Jan-2009   Bug 7699476 File version 120.21.12010000.4 / 120.24
              Issue : IRTP is ending with warning : Error - ORA-06502: PL/SQL:numeric or value error: NULL index table key value
	              Source of the error is procedure regime_tax_accounting_interim in this package.
	      Casue : Index variable l_jv_line_num_generator is used to access a pl sql table. This
	              variable is defined in case of VAT (in elsif part), but undefined for Service
		      regime (if part).
	      Fix   : Added code in the if part so that the index variable will be defined for Service
	              regime also.

6-Apr-2009   Bug 8488470 File version 120.21.12010000.5 / 120.25
                     Issue - Accounting entries are not properly rounded for VAT during CORRECT / RTV. This also causes EU02 error during
                                journal import (one entry used rounded amount, other entry used unrounded amount).
                     Casue - Regime_tax_accounting_interim procedure uses rounding logic for recoverable tax. But the procedure get_tax_breakup
                                  applied rounding only for partially recoverable taxes.
                     Fix - Modified procedure get_tax_breakup so that rounding would be done for fully recoverable taxes also.

12-DEC-2008  Bug 7640943 (FP for bug 7588482) File version 120.21.12010000.6 / 120.26
             Issue : During RTV the balance in receiving inventory / AP accrual account is not
             completely knocked off.
             Cause : Cenvat reversal accounting is generated for the rounded off tax amount for
             the return quantity (legal requirement). But the normal "Receiving" entry is passed
             for the exact (quantity-apportioned) tax amount for the returned quantity. There
             will be a net difference due to rounding.
             Fix   : The normal "Receiving" accounting entry should be generated with the excise
             tax amounts rounded off according to setup. Necessary changes are done in the
             procedure get_tax_breakup.
17-jul-2009 vkaranam for bug#8691046
 Issue:Wrong amount has been accounted for RMA receipt.
	    Fix:
	    ln_credit is wrongly calculated for p_attribute_category = 'CUSTOMER'
            FWDPORTED THE CHANGES doen in 115 bug#6377961 (Replaced p_excise_edu_cess with p_excise_sh_edu_cess).

01-Feb-2010   Bug 9319913 File version 120.21.12010000.8 / 120.28
               Issue - Tax amount gets rounded in the accrual reconciliation report.
               Fix - Removed the round() function for the accrual amount when inserting into table
                     jai_rcv_rep_accrual_t.




Dependency Section
========== =======

Date      Version    Bug         Remarks
--------- -------   ----------  -------------------------------------------------------------
6-sep-04  115.0     ER#3848010  This is a part of correction ER.

28-jan-05 115.1     Er#4239736  This is a Service + Cess Solution.

19-mar-05 115.4     ER#4245089  VAT Solution
10-may-05 116.1     ER#4346453  DFF Elimination Enh.
----------------------------------------------------------------------------------------- */
/*Bug 5527885 Start*/
gn_currency_precision number;
gv_inv_receiving      constant  varchar2(30) := 'INVENTORY RECEIVING';
gv_ap_accrual         constant  varchar2(30) := 'AP ACCRUAL';
gv_boe                constant  varchar2(30) := 'BOE';
gv_rtv_expense        constant  varchar2(30) := 'RTV EXPENSE';
gv_iso_receivables    constant  varchar2(30) := 'ISO RECEIVABLES';
gv_iso_intransit_inv  constant  varchar2(30) := 'ISO INTRANSIT INVENTORY';
gv_vat_interim        constant  varchar2(30) := 'VAT INTERIM';
gv_service_interim    constant  varchar2(30) := 'SERVICE INTERIM';
gv_regime_interim     constant  varchar2(30) := 'REGIME INTERIM';
gv_credit             constant  varchar2(30) := 'CREDIT';
gv_debit              constant  varchar2(30) := 'DEBIT';
/*Bug 5527885 End*/

/****************************** Start process_transaction  ****************************/


  procedure process_transaction
  (
    p_transaction_id                          in                 number,
    p_simulation                              in                 varchar2,  -- default 'N', File.Sql.35
    p_debug                                   in                 varchar2,  -- default 'Y', File.Sql.35
    p_process_flag                            out      nocopy    varchar2,
    p_process_message                         out      nocopy    varchar2,
    p_codepath                                in out   nocopy    varchar2
  )is

  cursor c_ja_in_rcv_transactions(cp_transaction_id in number) is
    select  organization_id,
            location_id,
            transaction_type,
            parent_transaction_type,
            currency_conversion_rate,
            transaction_date,
            parent_transaction_id,
            inventory_item_id,
            inv_item_flag /* Service */
    from    JAI_RCV_TRANSACTIONS
    where   transaction_id = cp_transaction_id;

  cursor    c_rcv_transactions(cp_transaction_id in number) is
    select  shipment_header_id,
            shipment_line_id,
            po_distribution_id,
            po_line_location_id,
            -- attribute5, Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
            vendor_id
            -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. , upper(attribute_category) attribute_category
            -- , source_document_code
            -- , decode(source_document_code, 'RMA', jai_rcv_trx_processing_pkg.india_rma_receipt,
            --                                      jai_rcv_trx_processing_pkg.india_receipt) attribute_category
    from    rcv_transactions
    where   transaction_id = cp_transaction_id;

  cursor    c_rcv_shipment_lines(cp_shipment_line_id number) is
    select  from_organization_id,
            to_organization_id
    from    rcv_shipment_lines
    where   shipment_line_id = cp_shipment_line_id;

  cursor    c_rcv_shipment_headers(cp_shipment_header_id number) is
    select  upper(receipt_source_code) receipt_source_code,
            receipt_num
    from    rcv_shipment_headers
    where   shipment_header_id = cp_shipment_header_id;


  r_ja_in_rcv_transactions            c_ja_in_rcv_transactions%rowtype;
  r_rcv_transactions                  c_rcv_transactions%rowtype;
  r_rcv_shipment_lines                c_rcv_shipment_lines%rowtype;
  r_rcv_shipment_headers              c_rcv_shipment_headers%rowtype;

  ln_boe_account_id                   number;
  ln_rtv_expense_account_id           number;
  ln_excise_expense_account           number;
  ln_excise_rcvble_account            number;
  ln_receiving_account_id             number;
  ln_ap_accrual_account               number;
  ln_po_accrual_account_id            number;
  ln_interorg_payables_account        number;
  ln_intransit_inv_account            number;
  ln_interorg_receivables_accnt       number;
  ln_intransit_type                   number;
  ln_fob_point                        number;

  ln_all_taxes                        number;
  ln_tds_taxes                        number;
  ln_modvat_recovery_taxes            number;
  ln_cvd_taxes                        number;
  ln_add_cvd_taxes                    number;/*5228046 Additional cvd Enhancement*/
  ln_customs_taxes                    number;
  ln_third_party_taxes                number;
  ln_excise_tax                       number;
  ln_service_not_recoverable          number; /* Service */
  ln_service_recoverable              number; /* Service */

  /* two variables added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
  ln_vat_not_recoverable              number;
  ln_vat_recoverable                  number;

  --lv_accounting_method_option         ap_system_parameters_all.accounting_method_option%type;  /* Service */
  --commented the above by Sanjikum for Bug#4474501
  lv_accrue_on_receipt_flag           po_distributions_all.accrue_on_receipt_flag%type;
  ln_excise_edu_cess                  number; /* Educational Cess */
  ln_excise_sh_edu_cess               number; /*Bug 5989740 bduvarag*/
  ln_cvd_edu_cess                     number; /* Educational Cess */
  ln_cvd_sh_edu_cess                  number; /*Bug 5989740 bduvarag*/
  ln_customs_edu_cess                 number; /* Educational Cess */
  ln_customs_sh_edu_cess              number; /*Bug 5989740 bduvarag*/

  lv_temp                             varchar2(50);

  lb_account_service_interim          boolean; /* Service */

  lv_trading_to_trading_iso           varchar2(1); /* Bug#4171469 */
/*Bug 5527885 STart*/
tr_jv                     JOURNAL_LINES;
  ln_jv_num_of_max_rec      number;
  ln_max_jv_abs_amt         number;
  ln_max_jv_amt_type        varchar2(30);
  ln_diff_amt_between_dr_cr number;

  ln_tmp_dr_amt number;
  ln_tmp_cr_amt number;
  ln_cum_dr_amt number;
  ln_cum_cr_amt number;

   v_rounding_diff_from	number;
  v_rounding_diff_to	number;
  v_line_count		number;
  /*Bug 5527885 End*/
begin

  -- this is to identify the path in SQL TRACE file if any problem occured
  SELECT 'jai_rcv_rcv_rtv_pkg-'||p_transaction_id INTO lv_temp FROM DUAL;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '**** Start of procedure jai_rcv_rcv_rtv_pkg.process_transaction ****');
  end if;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.process_transaction', 'START'); /* 1 */

  open c_rcv_transactions(p_transaction_id);
  fetch c_rcv_transactions into r_rcv_transactions;
  close c_rcv_transactions;

  p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
  open c_ja_in_rcv_transactions(p_transaction_id);
  fetch c_ja_in_rcv_transactions into r_ja_in_rcv_transactions;
  close c_ja_in_rcv_transactions;

  p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
  open c_rcv_shipment_headers(r_rcv_transactions.shipment_header_id);
  fetch c_rcv_shipment_headers into r_rcv_shipment_headers;
  close c_rcv_shipment_headers;

  p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
  open c_rcv_shipment_lines(r_rcv_transactions.shipment_line_id);
  fetch c_rcv_shipment_lines into r_rcv_shipment_lines;
  close c_rcv_shipment_lines;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, ' Call to -> get_accounts');
 --   Fnd_File.put_line(Fnd_File.LOG, ' Code Path :' || p_codepath );/*Bug 5527885*/
  end if;

  /* Get the Details for service tax interim accounting and check if it is needed */
  p_codepath := jai_general_pkg.plot_codepath(4.11, p_codepath); /* 4.11 */
  /*lv_accounting_method_option :=
  jai_general_pkg.get_accounting_method
  (
    p_org_id            =>    null,
    p_organization_id   =>    r_ja_in_rcv_transactions.organization_id,
    p_sob_id            =>    null
  );*/
  --commented the above by Sanjikum for Bug#4474501

  p_codepath := jai_general_pkg.plot_codepath(4.12, p_codepath); /* 4.12 */
  lv_accrue_on_receipt_flag :=
  jai_rcv_trx_processing_pkg.get_accrue_on_receipt
  (p_po_distribution_id =>   r_rcv_transactions.po_distribution_id,
  -- added by Vijay Shankar for Bug#4215402
  p_po_line_location_id =>   r_rcv_transactions.po_line_location_id
  );


  p_codepath := jai_general_pkg.plot_codepath(4.13, p_codepath); /* 4.13 */
  /*if  ( (lv_accrue_on_receipt_flag = 'N')
          or
          (lv_accounting_method_option = 'Cash' and
           nvl(r_ja_in_rcv_transactions.inv_item_flag, 'N') = 'N'
          )
        )*/
  --commented the above and added the below for Bug#4474501
  if  lv_accrue_on_receipt_flag = 'N'

  then
    p_codepath := jai_general_pkg.plot_codepath(4.14, p_codepath); /* 4.14 */
    lb_account_service_interim := false;
  else
    p_codepath := jai_general_pkg.plot_codepath(4.15, p_codepath); /* 4.15 */
    lb_account_service_interim := true;
  end if;
/*Bug 5527885 Start*/
 gn_currency_precision :=
      jai_general_pkg.get_currency_precision(r_ja_in_rcv_transactions.organization_id);
  if gn_currency_precision is null then
    p_process_flag := 'E';
    p_process_message := 'Currency Precision is null. Organization:'||r_ja_in_rcv_transactions.organization_id;
    goto exit_from_procedure;
  end if;
/*Bug 5527885 End*/

  p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
  get_accounts
  (
    p_organization_id                =>    r_ja_in_rcv_transactions.organization_id,
    p_location_id                    =>    r_ja_in_rcv_transactions.location_id,
    p_receipt_source_code            =>    r_rcv_shipment_headers.receipt_source_code,
    p_from_organization_id           =>    r_rcv_shipment_lines.from_organization_id,
    p_to_organization_id             =>    r_rcv_shipment_lines.to_organization_id ,
    p_po_distribution_id             =>    r_rcv_transactions.po_distribution_id,
    p_po_line_location_id            =>    r_rcv_transactions.po_line_location_id,
    /** OUT parameters **/
    p_boe_account_id                 =>    ln_boe_account_id,
    p_rtv_expense_account_id         =>    ln_rtv_expense_account_id,
    p_excise_expense_account         =>    ln_excise_expense_account,
    p_excise_rcvble_account          =>    ln_excise_rcvble_account,
    p_receiving_account_id           =>    ln_receiving_account_id,
    p_ap_accrual_account             =>    ln_ap_accrual_account,
    p_po_accrual_account_id          =>    ln_po_accrual_account_id,
    p_interorg_payables_account      =>    ln_interorg_payables_account,
    p_intransit_inv_account          =>    ln_intransit_inv_account,
    p_interorg_receivables_account   =>    ln_interorg_receivables_accnt,
    p_intransit_type                 =>    ln_intransit_type,
    p_fob_point                      =>    ln_fob_point,
    p_trading_to_trading_iso         =>    lv_trading_to_trading_iso,  /* Bug#4171469 */
    p_process_flag                   =>    p_process_flag,
    p_process_message                =>    p_process_message,
    p_debug                          =>    p_debug,
    p_codepath                       =>    p_codepath
   );

  if p_process_flag <> 'Y' then
    /* get_accounts procedure has hit an error, cannot continue processing */
    goto exit_from_procedure;
  end if;


  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, ' Call to -> get_tax_breakup');
--    Fnd_File.put_line(Fnd_File.LOG, ' Code Path :' || p_codepath );/*Bug 5527885*/
  end if;

  p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
  get_tax_breakup
  (
    p_transaction_id                 =>    p_transaction_id,
    p_shipment_line_id               =>    r_rcv_transactions.shipment_line_id,
    p_currency_conversion_rate       =>    r_ja_in_rcv_transactions.currency_conversion_rate,
    p_po_vendor_id                   =>    r_rcv_transactions.vendor_id,
    p_all_taxes                      =>    ln_all_taxes,
    p_tds_taxes                      =>    ln_tds_taxes ,
    p_modvat_recovery_taxes          =>    ln_modvat_recovery_taxes,
    p_cvd_taxes                      =>    ln_cvd_taxes,
    p_add_cvd_taxes                  =>    ln_add_cvd_taxes,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                  =>    ln_customs_taxes,
    p_third_party_taxes              =>    ln_third_party_taxes,
    p_excise_tax                     =>    ln_excise_tax,
    p_service_recoverable            =>    ln_service_recoverable,
    p_service_not_recoverable        =>    ln_service_not_recoverable,
    p_vat_recoverable                =>    ln_vat_recoverable,
    p_vat_not_recoverable            =>    ln_vat_not_recoverable,
    p_excise_edu_cess                =>    ln_excise_edu_cess,
    p_excise_sh_edu_cess             =>    ln_excise_sh_edu_cess,/*Bug 5989740 bduvarag*/
    p_cvd_edu_cess                   =>    ln_cvd_edu_cess,
    p_cvd_sh_edu_cess                =>    ln_cvd_sh_edu_cess,/*Bug 5989740 bduvarag*/
    p_customs_edu_cess               =>    ln_customs_edu_cess,
    p_customs_sh_edu_cess            =>    ln_customs_sh_edu_cess,/*Bug 5989740 bduvarag*/
    p_process_flag                   =>    p_process_flag,
    p_process_message                =>    p_process_message,
    p_debug                          =>    p_debug,
    p_codepath                       =>    p_codepath
  );

  if p_process_flag <> 'Y' then
    /* get_tax_breakup procedure has hit an error, cannot continue processing */
    goto exit_from_procedure;
  end if;


  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, ' Call to -> validate_transaction_tax_accnt');
--    Fnd_File.put_line(Fnd_File.LOG, ' Code Path :' || p_codepath );/*Bug 5527885*/
  end if;

  p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */

  validate_transaction_tax_accnt
  (
    p_transaction_type               =>    r_ja_in_rcv_transactions.transaction_type,
    p_parent_transaction_type        =>    r_ja_in_rcv_transactions.parent_transaction_type,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category             =>    r_rcv_transactions.attribute_category,
    p_receipt_source_code            =>    r_rcv_shipment_headers.receipt_source_code,
    p_boe_account_id                 =>    ln_boe_account_id,
    p_rtv_expense_account_id         =>    ln_rtv_expense_account_id,
    p_excise_expense_account         =>    ln_excise_expense_account,
    p_excise_rcvble_account          =>    ln_excise_rcvble_account,
    p_receiving_account_id           =>    ln_receiving_account_id,
    p_ap_accrual_account             =>    ln_ap_accrual_account,
    p_po_accrual_account_id          =>    ln_po_accrual_account_id,
    p_interorg_payables_account      =>    ln_interorg_payables_account,
    p_intransit_inv_account          =>    ln_intransit_inv_account,
    p_interorg_receivables_account   =>    ln_interorg_receivables_accnt,
    p_intransit_type                 =>    ln_intransit_type,
    p_fob_point                      =>    ln_fob_point,
    p_cvd_taxes                      =>    ln_cvd_taxes,
    p_add_cvd_taxes                  =>    ln_add_cvd_taxes,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                  =>    ln_customs_taxes,
    p_third_party_taxes              =>    ln_third_party_taxes,
    p_excise_tax                     =>    ln_excise_tax,
    p_trading_to_trading_iso         =>    lv_trading_to_trading_iso,  /* Bug#4171469 */
    p_process_flag                   =>    p_process_flag,
    p_process_message                =>    p_process_message,
    p_debug                          =>    p_debug,
    p_codepath                       =>    p_codepath
  );

  if p_process_flag <> 'Y' then
    /* validate_transaction_tax_accnt procedure has hit an error, cannot continue processing */
    goto exit_from_procedure;
  end if;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, ' Call to -> apply_relieve_boe');
--    Fnd_File.put_line(Fnd_File.LOG, ' Code Path :' || p_codepath );/*Bug 5527885*/
  end if;

  p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */

  apply_relieve_boe
  (
    p_transaction_id                =>     p_transaction_id,
    p_transaction_type              =>     r_ja_in_rcv_transactions.transaction_type,
    p_parent_transaction_id         =>     r_ja_in_rcv_transactions.parent_transaction_id,
    p_parent_transaction_type       =>     r_ja_in_rcv_transactions.parent_transaction_type,
    p_shipment_line_id              =>     r_rcv_transactions.shipment_line_id,
    p_shipment_header_id            =>     r_rcv_transactions.shipment_header_id,
    p_organization_id               =>     r_ja_in_rcv_transactions.organization_id,
    p_inventory_item_id             =>     r_ja_in_rcv_transactions.inventory_item_id,
    p_cvd_taxes                     =>     ln_cvd_taxes,
    p_add_cvd_taxes                  =>    ln_add_cvd_taxes,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                 =>     ln_customs_taxes,
    p_cvd_edu_cess                  =>     ln_cvd_edu_cess,     /* Educational Cess */
    p_cvd_sh_edu_cess               =>     ln_cvd_sh_edu_cess, /*Bug 5989740 bduvarag*/
    p_customs_edu_cess              =>     ln_customs_edu_cess, /* Educational Cess */
    p_customs_sh_edu_cess           =>     ln_customs_sh_edu_cess,/*Bug 5989740 bduvarag*/
    p_simulation                    =>     p_simulation,
    p_process_flag                  =>     p_process_flag,
    p_process_message               =>     p_process_message,
    p_debug                         =>     p_debug,
    p_codepath                      =>     p_codepath
  );

  if p_process_flag <> 'Y' then
    /* apply_relieve_boe procedure has hit an error, cannot continue processing */
    goto exit_from_procedure;
  end if;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, ' Call to -> post_entries');
--    Fnd_File.put_line(Fnd_File.LOG, ' Code Path :' || p_codepath );/*Bug 5527885*/
  end if;
      Fnd_File.put_line(Fnd_File.LOG, ' p_transaction_id:'||p_transaction_id);
      Fnd_File.put_line(Fnd_File.LOG, ' ln_receiving_account_id:'||ln_receiving_account_id);
      Fnd_File.put_line(Fnd_File.LOG, ' ln_ap_accrual_account:'||ln_ap_accrual_account);
      Fnd_File.put_line(Fnd_File.LOG, ' ln_intransit_inv_account:'||ln_intransit_inv_account);
      Fnd_File.put_line(Fnd_File.LOG, ' ln_interorg_receivables_accnt:'||ln_interorg_receivables_accnt);
      Fnd_File.put_line(Fnd_File.LOG, ' p_interorg_payables_account:'||ln_interorg_payables_account);


  p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
  post_entries
  (
    p_transaction_id                 =>    p_transaction_id,
    p_transaction_type               =>    r_ja_in_rcv_transactions.transaction_type,
    p_parent_transaction_type        =>    r_ja_in_rcv_transactions.parent_transaction_type,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category             =>    r_rcv_transactions.attribute_category,
    p_receipt_source_code            =>    r_rcv_shipment_headers.receipt_source_code,
    p_transaction_date               =>    r_ja_in_rcv_transactions.transaction_date,
    p_receipt_num                    =>    r_rcv_shipment_headers.receipt_num,
    p_receiving_account_id           =>    ln_receiving_account_id,
    p_ap_accrual_account             =>    ln_ap_accrual_account,
    p_boe_account_id                 =>    ln_boe_account_id,
    p_rtv_expense_account_id         =>    ln_rtv_expense_account_id,
    p_intransit_type                 =>    ln_intransit_type,
    p_fob_point                      =>    ln_fob_point,
    p_intransit_inv_account          =>    ln_intransit_inv_account,
    p_interorg_receivables_account   =>    ln_interorg_receivables_accnt,
    p_all_taxes                      =>    ln_all_taxes,
    p_tds_taxes                      =>    ln_tds_taxes ,
    p_modvat_recovery_taxes          =>    ln_modvat_recovery_taxes,
    p_cvd_taxes                      =>    ln_cvd_taxes,
    p_add_cvd_taxes                  =>    ln_add_cvd_taxes,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                  =>    ln_customs_taxes,
    p_third_party_taxes              =>    ln_third_party_taxes,
    p_excise_tax                     =>    ln_excise_tax,
    p_service_recoverable            =>    ln_service_recoverable,
    p_service_not_recoverable        =>    ln_service_not_recoverable,
    p_vat_recoverable                =>    ln_vat_recoverable,
    p_vat_not_recoverable            =>    ln_vat_not_recoverable,
    p_account_service_interim        =>    lb_account_service_interim,  /* Service */
    p_excise_edu_cess                =>    ln_excise_edu_cess,  /* Educational Cess */
    p_excise_sh_edu_cess             =>    ln_excise_sh_edu_cess, /*Bug 5989740 bduvarag*/
    p_cvd_edu_cess                   =>    ln_cvd_edu_cess,     /* Educational Cess */
    p_cvd_sh_edu_cess                =>    ln_cvd_sh_edu_cess,	/*Bug 5989740 bduvarag*/
    p_customs_edu_cess               =>    ln_customs_edu_cess, /* Educational Cess */
    p_customs_sh_edu_cess            =>    ln_customs_sh_edu_cess,/*Bug 5989740 bduvarag*/
    p_trading_to_trading_iso         =>    lv_trading_to_trading_iso,  /* Bug#4171469 */
    ptr_jv                           =>    tr_jv,   /* 5527885 */
    p_simulation                     =>    p_simulation,
    p_process_flag                   =>    p_process_flag,
    p_process_message                =>    p_process_message,
    p_debug                          =>    'Y',
    p_codepath                       =>    p_codepath
  );

  if p_process_flag <> 'Y' then
    /* post_entries procedure has hit an error, cannot continue processing */
    goto exit_from_procedure;
  end if;

  p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
/*Bug 5632406 Start*/
 if (lb_account_service_interim and nvl(ln_service_recoverable, 0) <> 0 )
    and   r_rcv_shipment_headers.receipt_source_code <> 'CUSTOMER'
    /* bug#5632406 - bduvarag used the p_receipt_source_code
    instead of nvl(r_rcv_transactions.attribute_category, 'XX') <> 'INDIA RMA RECEIPT'*/
  then
/*Bug 5632406 End*/
    p_codepath := jai_general_pkg.plot_codepath(10.1, p_codepath); /* 10.1 */

    regime_tax_accounting_interim
    (
    p_transaction_id                 =>    p_transaction_id,
    p_shipment_line_id               =>    r_rcv_transactions.shipment_line_id,
    p_organization_id                =>    r_ja_in_rcv_transactions.organization_id,
    p_location_id                    =>    r_ja_in_rcv_transactions.location_id,
    p_transaction_type               =>    r_ja_in_rcv_transactions.transaction_type,
    p_currency_conversion_rate       =>    r_ja_in_rcv_transactions.currency_conversion_rate,
    p_parent_transaction_type        =>    r_ja_in_rcv_transactions.parent_transaction_type,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category             =>    r_rcv_transactions.attribute_category,
    p_receipt_source_code            =>    r_rcv_shipment_headers.receipt_source_code,
    p_transaction_date               =>    r_ja_in_rcv_transactions.transaction_date,
    p_receipt_num                    =>    r_rcv_shipment_headers.receipt_num,
    p_regime_code                    =>    jai_constants.service_regime,
    ptr_jv                           =>    tr_jv,/*Bug 5632406*/
    p_simulation                     =>    p_simulation,
    p_process_flag                   =>    p_process_flag,
    p_process_message                =>    p_process_message,
    p_debug                          =>    p_debug,
    p_codepath                       =>    p_codepath
    );

    if p_process_flag <> 'Y' then
      /* post_entries procedure has hit an error, cannot continue processing */
      goto exit_from_procedure;
    end if;

  end if;

  /* following call added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
  if nvl(ln_vat_recoverable, 0) <> 0 and r_rcv_shipment_headers.receipt_source_code <> 'CUSTOMER'  then/*Bug 5527885*/
    p_codepath := jai_general_pkg.plot_codepath(10.2, p_codepath); /* 10.2 */ /*Bug 5527885*/
    /* VAT interim accounting required as recoverable vat tax exists */
    regime_tax_accounting_interim
    (
    p_transaction_id                 =>    p_transaction_id,
    p_shipment_line_id               =>    r_rcv_transactions.shipment_line_id,
    p_organization_id                =>    r_ja_in_rcv_transactions.organization_id,
    p_location_id                    =>    r_ja_in_rcv_transactions.location_id,
    p_transaction_type               =>    r_ja_in_rcv_transactions.transaction_type,
    p_currency_conversion_rate       =>    r_ja_in_rcv_transactions.currency_conversion_rate,
    p_parent_transaction_type        =>    r_ja_in_rcv_transactions.parent_transaction_type,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category             =>    r_rcv_transactions.attribute_category,
    p_receipt_source_code            =>    r_rcv_shipment_headers.receipt_source_code,
    p_transaction_date               =>    r_ja_in_rcv_transactions.transaction_date,
    p_receipt_num                    =>    r_rcv_shipment_headers.receipt_num,
    p_regime_code                    =>    jai_constants.vat_regime,
    ptr_jv                           =>    tr_jv,/*Bug 5632406*/
    p_simulation                     =>    p_simulation,
    p_process_flag                   =>    p_process_flag,
    p_process_message                =>    p_process_message,
    p_debug                          =>    p_debug,
    p_codepath                       =>    p_codepath
    );

    if p_process_flag <> 'Y' then
      /* post_entries procedure has hit an error, cannot continue processing */
      goto exit_from_procedure;
    end if;

  end if;  /* VAT interim accounting */
/*Bug 5527885 Start*/
  p_codepath := jai_general_pkg.plot_codepath(10.3, p_codepath); /* 11 */
  /* START 5478427 */
  /* Code for rounding logic */
  ln_cum_dr_amt := 0;
  ln_cum_cr_amt := 0;
  ln_max_jv_abs_amt := 0;
   v_line_count := 0;/*Bug 5527885*/
Fnd_File.put_line(Fnd_File.LOG, ' Befor looping of table variable tr_jv tr_jv.count is :'||tr_jv.count);  --Added by JMEENA for bug#7310836
IF tr_jv.count > 0    /*added by JMEENA for bug #7310836*/ THEN
  for jv_num in tr_jv.FIRST..tr_jv.LAST loop

    if tr_jv.exists(jv_num) = true then
 v_line_count := v_line_count +1;/*Bug 5527885*/
      ln_tmp_dr_amt := nvl(tr_jv(jv_num).entered_dr, 0);
      ln_tmp_cr_amt := nvl(tr_jv(jv_num).entered_cr, 0);

      ln_cum_dr_amt := ln_cum_dr_amt + ln_tmp_dr_amt;
      ln_cum_cr_amt := ln_cum_cr_amt + ln_tmp_cr_amt;

      ln_tmp_dr_amt := abs(ln_tmp_dr_amt);
      ln_tmp_cr_amt := abs(ln_tmp_cr_amt);
      if ln_max_jv_abs_amt < ln_tmp_dr_amt then
        ln_jv_num_of_max_rec := jv_num;
        ln_max_jv_abs_amt := ln_tmp_dr_amt;
        ln_max_jv_amt_type := gv_debit;
      elsif ln_max_jv_abs_amt < ln_tmp_cr_amt then
        ln_jv_num_of_max_rec := jv_num;
        ln_max_jv_abs_amt := ln_tmp_cr_amt;
        ln_max_jv_amt_type := gv_credit;
      end if;

    end if;

  end loop;
  ln_diff_amt_between_dr_cr := ln_cum_dr_amt - ln_cum_cr_amt;
  /*Bug 5527885*/
    v_rounding_diff_to := (1/(2*(power(10,gn_currency_precision)))) * v_line_count;
  v_rounding_diff_from := (-1) * v_rounding_diff_to;


  p_codepath := jai_general_pkg.plot_codepath(10.4, p_codepath); /* 11 */
  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG,
      'For Rounding- CumDr:'||ln_cum_dr_amt||', CumCr:'||ln_cum_cr_amt||', ProbRec:'||ln_jv_num_of_max_rec
      ||', v_rounding_diff_from:'||v_rounding_diff_from||', v_rounding_diff_to:'||v_rounding_diff_to
      );
  end if;
  /* rounding logic starts */

--  if ln_diff_amt_between_dr_cr <> 0 then
 if (ln_diff_amt_between_dr_cr >= v_rounding_diff_from)
	and  (ln_diff_amt_between_dr_cr <= v_rounding_diff_to)  /* Added for Bug#5527885 */
then
    p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
    if ln_max_jv_amt_type = gv_debit then
      tr_jv(ln_jv_num_of_max_rec).entered_dr :=
            tr_jv(ln_jv_num_of_max_rec).entered_dr - ln_diff_amt_between_dr_cr;
    else /* means credit */
      tr_jv(ln_jv_num_of_max_rec).entered_cr :=
            tr_jv(ln_jv_num_of_max_rec).entered_cr + ln_diff_amt_between_dr_cr;
    end if;
  end if;

  /*
  ptr_jv(2).line_num           := 2;
  ptr_jv(2).acct_type          := lv_acct_type;
  ptr_jv(2).acct_nature        := lv_acct_nature;
  ptr_jv(2).source_name        := lv_source_name;
  ptr_jv(2).category_name      := lv_category_name;
  ptr_jv(2).ccid               := p_ap_accrual_account;
  ptr_jv(2).entered_dr         := round(ln_debit, gn_currency_precision);
  ptr_jv(2).entered_cr         := round(ln_credit, gn_currency_precision);
  ptr_jv(2).currency_code      := ja_in_receipt_transactions_pkg.gv_func_curr;
  ptr_jv(2).accounting_date    := p_transaction_date;
  ptr_jv(2).reference_10       := lv_reference_10;
  ptr_jv(2).reference_23       := lv_reference_23;
  ptr_jv(2).reference_24       := lv_reference_24;
  ptr_jv(2).reference_25       := lv_reference_25;
  ptr_jv(2).reference_26       := lv_reference_26;
  ptr_jv(2).destination        := 'G';
  -- ptr_jv(2).reference_name     := ;
  ptr_jv(2).reference_id       := p_transaction_id;
  ptr_jv(2).non_rnd_entered_dr := ln_debit;
  ptr_jv(2).non_rnd_entered_cr := ln_credit;
  ptr_jv(2).account_name       := gv_ap_accrual;
  ptr_jv(2).summary_jv_flag    := 'Y';
  */

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, 'Account Name                   CCID                        Dr.                  Cr.          Non Rnd Dr.          Non Rnd Cr.'  );
    Fnd_File.put_line(Fnd_File.LOG, '------------------------------ ---------- -------------------- -------------------- -------------------- --------------------'  );
  end if;

  /* Code to Post Journals */
  for jv_num in tr_jv.FIRST..tr_jv.LAST loop

    if tr_jv.exists(jv_num) = true then

      p_codepath := jai_general_pkg.plot_codepath('12.'||tr_jv(jv_num).line_num, p_codepath); /* 10 */
      if p_debug = 'Y' then
        Fnd_File.put_line(Fnd_File.LOG,
              rpad(tr_jv(jv_num).account_name,30, ' ')
              ||' '||rpad(tr_jv(jv_num).ccid,10, ' ')
              ||' '||lpad(nvl(tr_jv(jv_num).entered_dr,0),20, ' ')
              ||' '||lpad(nvl(tr_jv(jv_num).entered_cr,0),20, ' ')
              ||' '||lpad(round(nvl(tr_jv(jv_num).non_rnd_entered_dr,0),8),20, ' ')
              ||' '||lpad(round(nvl(tr_jv(jv_num).non_rnd_entered_cr,0),8),20, ' ')
        );
      end if;
      IF nvl(tr_jv(jv_num).entered_dr,0) <> 0 OR nvl(tr_jv(jv_num).entered_cr,0) <> 0 THEN/*Bug 5527885*/
      jai_rcv_accounting_pkg.process_transaction(
        p_transaction_id            =>    p_transaction_id,
        p_acct_type                 =>    tr_jv(jv_num).acct_type      ,
        p_acct_nature               =>    tr_jv(jv_num).acct_nature    ,
        p_source_name               =>    tr_jv(jv_num).source_name    ,
        p_category_name             =>    tr_jv(jv_num).category_name  ,
        p_code_combination_id       =>    tr_jv(jv_num).ccid           ,
        p_entered_dr                =>    tr_jv(jv_num).entered_dr     ,
        p_entered_cr                =>    tr_jv(jv_num).entered_cr     ,
        p_currency_code             =>    tr_jv(jv_num).currency_code  ,
        p_accounting_date           =>    tr_jv(jv_num).accounting_date,
        p_reference_10              =>    tr_jv(jv_num).reference_10   ,
        p_reference_23              =>    tr_jv(jv_num).reference_23   ,
        p_reference_24              =>    tr_jv(jv_num).reference_24   ,
        p_reference_25              =>    tr_jv(jv_num).reference_25   ,
        p_reference_26              =>    tr_jv(jv_num).reference_26   ,
        p_destination               =>    tr_jv(jv_num).destination    ,
        p_simulate_flag             =>    p_simulation,
        p_codepath                  =>    p_codepath,
        p_process_status            =>    p_process_flag,
        p_process_message           =>    P_process_message
      );
     END IF; /*bug#5527885 */
      if p_process_flag <> 'Y' then
        goto exit_from_procedure;
      end if;

    end if;

  end loop;
  /* END OF 5527885 */
 END IF; --End of bug#7310836, added by JMEENA
 Fnd_File.put_line(Fnd_File.LOG, 'After tr_jv loop. Not processed for Accounting as pl/sql table count is Zero'); --Added by JMEENA for bug#7310836

  -- All the Processing Went Through fine. So Setting the process_flag to 'Y'
  p_process_flag := 'Y';

  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(99, p_codepath, null, 'END'); /* 11 *//*Bug 5527885*/

  if p_debug = 'Y' then
--    Fnd_File.put_line(Fnd_File.LOG, ' Code Path :' || p_codepath );/*Bug 5527885*/
    Fnd_File.put_line(Fnd_File.LOG, '**** End of procedure jai_rcv_rcv_rtv_pkg.process_transaction ****');
  end if;

  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.process_transaction:' || sqlerrm;
    FND_FILE.put_line(FND_FILE.log, 'Error in '||p_process_message);
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path->' || p_codepath );
    return;

end process_transaction;
/****************************** End process_transaction  ****************************/

/******************************** Start get_accounts  *******************************/
  procedure get_accounts
  (
    p_organization_id                         in                  number,
    p_location_id                             in                  number,
    p_receipt_source_code                     in                  varchar2,
    p_from_organization_id                    in                  number,
    p_to_organization_id                      in                  number,
    p_po_distribution_id                      in                  number,
    p_po_line_location_id                     in                  number,
    p_debug                                   in                  varchar2,  -- default 'N', File.Sql.35
    p_boe_account_id                          out                 nocopy number,
    p_rtv_expense_account_id                  out     nocopy      number,
    p_excise_expense_account                  out     nocopy      number,
    p_excise_rcvble_account                   out     nocopy      number,
    p_receiving_account_id                    out     nocopy      number,
    p_ap_accrual_account                      out     nocopy      number,
    p_po_accrual_account_id                   out     nocopy      number,
    p_interorg_payables_account               out     nocopy      number,
    p_intransit_inv_account                   out     nocopy      number,
    p_interorg_receivables_account            out     nocopy      number,
    p_intransit_type                          out     nocopy      number,
    p_fob_point                               out     nocopy      number,
    p_trading_to_trading_iso                  out     nocopy      varchar2, /* Bug#4171469 */
    p_process_flag                            out     nocopy      varchar2,
    p_process_message                         out     nocopy      varchar2,
    p_codepath                                in out  nocopy      varchar2
  )is

  cursor    c_ja_in_hr_organization_units
            (cp_organization_id number, cp_location_id   number) is
    select  boe_account_id,
            excise_expense_account,
            excise_rcvble_account,
            rtv_expense_account_id,
            nvl(trading, 'N') receving_org_trading,  /* Bug#4171469 */
            NVL(manufacturing, 'N') receiving_org_manufacturing --Added by Ramananda for Bug #4516577
    from    JAI_CMN_INVENTORY_ORGS
    where   organization_id = cp_organization_id
    and     location_id = cp_location_id;

  cursor    c_rcv_parameters(cp_organization_id number) is
    select  receiving_account_id
    from    rcv_parameters
    Where   organization_id = cp_organization_id;

  cursor    c_mtl_parameters(cp_organization_id number) is
    select  ap_accrual_account
    from    mtl_parameters
    where   organization_id = cp_organization_id;

  cursor    c_po_distributions_all(cp_po_distribution_id number) is
    select  accrual_account_id
    from    po_distributions_all
    where   po_distribution_id = cp_po_distribution_id;

  cursor    c_po_distributions_all_1(cp_po_line_location_id number) is
    select  accrual_account_id
    from    po_distributions_all
    where   po_distribution_id =
            (
              select max(po_distribution_id)
              from   po_distributions_all
              where  line_location_id = cp_po_line_location_id
            );

  cursor    c_mtl_interorg_parameters
            (cp_from_organization_id number, cp_to_organization_id number) is
    select  interorg_payables_account,
            intransit_inv_account,
            interorg_receivables_account,
            intransit_type,
            fob_point
    from    mtl_interorg_parameters
    where   from_organization_id = cp_from_organization_id
    and     to_organization_id = cp_to_organization_id;

  cursor c_iso_from_org_type(cp_organization_id number) is
    select   nvl(trading, 'N') source_org_trading  /* Bug#4171469 */
    from    JAI_CMN_INVENTORY_ORGS
    where   organization_id = cp_organization_id;



  r_ja_in_hr_organization_units       c_ja_in_hr_organization_units%rowtype;
  r_ja_in_hr_organization_units1      c_ja_in_hr_organization_units%rowtype;
  r_mtl_parameters                    c_mtl_parameters%rowtype;
  r_po_distributions_all              c_po_distributions_all%rowtype;
  r_po_distributions_all_1            c_po_distributions_all_1%rowtype;
  r_rcv_parameters                    c_rcv_parameters%rowtype;
  r_mtl_interorg_parameters           c_mtl_interorg_parameters%rowtype;
  r_iso_from_org_type                 c_iso_from_org_type%rowtype; /* Bug#4171469 */

begin

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  **    Start of procedure jai_rcv_rcv_rtv_pkg.get_accounts **');
  end if;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.get_accounts', 'START'); /* 1 */
  open  c_ja_in_hr_organization_units(p_organization_id,p_location_id);
  fetch c_ja_in_hr_organization_units into r_ja_in_hr_organization_units;
  close c_ja_in_hr_organization_units;


  p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
  open  c_ja_in_hr_organization_units(p_organization_id, 0);
  fetch c_ja_in_hr_organization_units into r_ja_in_hr_organization_units1;
  close c_ja_in_hr_organization_units;

  /** check value for all accounts for the given location ..
      if null get value for null location  **/

  /** BOE account **/
  p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
  if  r_ja_in_hr_organization_units.boe_account_id is not null then
    p_boe_account_id := r_ja_in_hr_organization_units.boe_account_id ;
  elsif r_ja_in_hr_organization_units1.boe_account_id is not null then
    p_boe_account_id  := r_ja_in_hr_organization_units1.boe_account_id ;
  end if;

  /** rtv_expense_account_id **/
  p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
  if r_ja_in_hr_organization_units.rtv_expense_account_id is not null then
    p_rtv_expense_account_id := r_ja_in_hr_organization_units.rtv_expense_account_id ;
  elsif r_ja_in_hr_organization_units1.rtv_expense_account_id is not null then
    p_rtv_expense_account_id := r_ja_in_hr_organization_units1.rtv_expense_account_id ;
  end if;

  /** excise_expense_account **/
  p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
  if r_ja_in_hr_organization_units.excise_expense_account is not null then
    p_excise_expense_account := r_ja_in_hr_organization_units.excise_expense_account ;
  elsif r_ja_in_hr_organization_units1.excise_expense_account is not null then
    p_excise_expense_account := r_ja_in_hr_organization_units1.excise_expense_account ;
  end if;

  /** excise_rcvble_account **/
  p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
  if r_ja_in_hr_organization_units.excise_rcvble_account is not null then
    p_excise_rcvble_account := r_ja_in_hr_organization_units.excise_rcvble_account ;
  elsif r_ja_in_hr_organization_units1.excise_expense_account is not null then
    p_excise_rcvble_account := r_ja_in_hr_organization_units1.excise_rcvble_account ;
  end if;

  p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
  open c_rcv_parameters(p_organization_id);
  fetch c_rcv_parameters into r_rcv_parameters;
  close c_rcv_parameters;

  p_receiving_account_id := r_rcv_parameters.receiving_account_id;

  p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
  open c_mtl_parameters(p_organization_id);
  fetch c_mtl_parameters into r_mtl_parameters;
  close c_mtl_parameters;

  p_ap_accrual_account := r_mtl_parameters.ap_accrual_account;


  p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
  if p_po_distribution_id is not null then

    p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
    open  c_po_distributions_all(p_po_distribution_id);
    fetch c_po_distributions_all into r_po_distributions_all;
    close c_po_distributions_all;

    p_po_accrual_account_id := r_po_distributions_all.accrual_account_id;

  end if;


  if  r_po_distributions_all.accrual_account_id is null and
      p_po_line_location_id is not null then

      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
      open c_po_distributions_all_1(p_po_line_location_id);
      fetch c_po_distributions_all_1 into r_po_distributions_all_1;
      close c_po_distributions_all_1;

      p_po_accrual_account_id := r_po_distributions_all_1.accrual_account_id;

      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */

  end if;


  p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
  p_trading_to_trading_iso := 'N';
  if p_receipt_source_code in('INTERNAL ORDER','INVENTORY')then  -- bug 6030615

    p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
    open  c_mtl_interorg_parameters(p_from_organization_id, p_to_organization_id);
    fetch c_mtl_interorg_parameters into r_mtl_interorg_parameters;
    close c_mtl_interorg_parameters;

    /* Bug#4171469 */
    open c_iso_from_org_type(p_from_organization_id);
    fetch c_iso_from_org_type into r_iso_from_org_type;
    close c_iso_from_org_type;

    if  r_iso_from_org_type.source_org_trading = 'Y' and
        ( r_ja_in_hr_organization_units.receving_org_trading = 'Y'
          OR
          r_ja_in_hr_organization_units1.receving_org_trading = 'Y'/*Changes from nprashar for bug 6321337
         Commented the other 2 OR conditions as forward as per Forward porting 11i bug 6200218
          OR                                                           Added the OR Condition by Ramananda for Bug #4516577
          r_ja_in_hr_organization_units.receiving_org_manufacturing = 'Y'
          OR                                                           Added the OR Condition by Ramananda for Bug #4516577
          r_ja_in_hr_organization_units1.receiving_org_manufacturing = 'Y' Commenting Ends here */
        )

    then
      p_codepath := jai_general_pkg.plot_codepath(14.1, p_codepath); /* 14.1 */
      p_trading_to_trading_iso := 'Y';

    end if;

    p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
    p_interorg_payables_account     := r_mtl_interorg_parameters.interorg_payables_account;
    p_intransit_inv_account         := r_mtl_interorg_parameters.intransit_inv_account;
    p_interorg_receivables_account  := r_mtl_interorg_parameters.interorg_receivables_account;
    p_intransit_type                := r_mtl_interorg_parameters.intransit_type;
    p_fob_point                     := r_mtl_interorg_parameters.fob_point;

  end if; /*p_receipt_source_code = 'INTERNAL ORDER'*/


  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(16, p_codepath, null, 'END'); /* 16 */
  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  if p_debug = 'Y' then
--    Fnd_File.put_line(Fnd_File.LOG, '  Code Path :' || p_codepath );
    Fnd_File.put_line(Fnd_File.LOG, '  ** End of procedure jai_rcv_rcv_rtv_pkg.get_accounts **  ');
  end if;


  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.get_accounts:' || sqlerrm;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path:' || p_codepath );
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 24 */
    return;

end get_accounts;

/******************************** End get_accounts  *******************************/



/******************************** Start get_tax_breakup *****************************/
procedure get_tax_breakup
  (
    p_transaction_id                          in                  number,
    p_shipment_line_id                        in                  number,
    p_currency_conversion_rate                in                  number,
    p_po_vendor_id                            in                  number,
    p_debug                                   in                  varchar2,  -- default 'N', File.Sql.35
    p_all_taxes                               out     nocopy      number,
    p_tds_taxes                               out     nocopy      number,
    p_modvat_recovery_taxes                   out     nocopy      number,
    p_cvd_taxes                               out     nocopy      number,
    p_add_cvd_taxes                           out     nocopy      number, /*5228046 Additional cvd Enhancement*/
    p_customs_taxes                           out     nocopy      number,
    p_third_party_taxes                       out     nocopy      number,
    p_excise_tax                              out     nocopy      number,
    p_service_recoverable                     out     nocopy      number, /* service */
    p_service_not_recoverable                 out     nocopy      number, /* service */
    /* following two params added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    p_vat_recoverable                         out     nocopy      number,
    p_vat_not_recoverable                     out     nocopy      number,
    p_excise_edu_cess                         out     nocopy      number, /* educational cess */
    p_excise_sh_edu_cess                      out     nocopy      number,/*Bug 5989740 bduvarag*/
    p_cvd_edu_cess                            out     nocopy      number, /* educational cess */
    p_cvd_sh_edu_cess                         out     nocopy      number,/*Bug 5989740 bduvarag*/
    p_customs_edu_cess                        out     nocopy      number, /* educational cess */
    p_customs_sh_edu_cess                     out     nocopy      number,/*Bug 5989740 bduvarag*/
    p_process_flag                            out     nocopy      varchar2,
    p_process_message                         out     nocopy      varchar2,
    p_codepath                                in      out nocopy  varchar2
  )
  is

  cursor c_ja_in_receipt_tax_lines(cp_shipment_line_id  number) is
    select  jrtl.tax_id tax_id,
            jrtl.tax_type tax_type,
            nvl(jrtl.tax_amount,0) tax_amount,
            jrtl.currency currency,
            nvl(jrtl.vendor_id, 0) vendor_id,
            nvl(jtc.rounding_factor, 0) rounding_factor,
            nvl(jtc.mod_cr_percentage, 0) recoverable,  /* Service */
            nvl(jrtl.modvat_flag, 'N') modvatable /* Service */
            , nvl(tax_types.regime_code, 'XXXX') regime_code    /* Vijay Shankar for Bug#4250236(4245089). VAT Impl. */

    from    JAI_RCV_LINE_TAXES jrtl,
            JAI_CMN_TAXES_ALL jtc
            , jai_regime_tax_types_v tax_types     /*Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    where   jrtl.shipment_line_id = cp_shipment_line_id
      AND   jrtl.tax_id = jtc.tax_id
      AND   jtc.tax_type = tax_types.tax_type(+)
      AND   NVL(jtc.inclusive_tax_flag,'N')='N'; --add by eric for inclusive tax,picking the exclusive tax only

  cursor c_jai_regimes(p_regime_code varchar2) is
    select regime_id
    from   JAI_RGM_DEFINITIONS
    where  regime_code = p_regime_code;

  cursor c_is_tax_type_in_regime(cp_regime_id  number, cp_tax_type varchar2) is
    select attribute_code regime_tax_type
    from   JAI_RGM_REGISTRATIONS
    where  regime_id = cp_regime_id
    and    registration_type = jai_constants.regn_type_tax_types
    and    attribute_code = cp_tax_type;

  /*
  r_jai_regimes_servce            c_jai_regimes%rowtype;
  r_jai_regimes_vat               c_jai_regimes%rowtype;
  r_is_tax_type_in_regime         c_is_tax_type_in_regime%rowtype;
  */

  ln_tax_apportion_factor         number;
  ln_tax_amount                   number;

begin

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  **    Start of procedure jai_rcv_rcv_rtv_pkg.get_tax_breakup **');
  end if;


  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.get_tax_breakup', 'START'); /* 1 */

  ln_tax_apportion_factor   :=
  jai_rcv_trx_processing_pkg.get_apportion_factor(p_transaction_id);

  p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
  p_all_taxes               := 0;
  p_tds_taxes               := 0;
  p_modvat_recovery_taxes   := 0;
  p_cvd_taxes               := 0;
  p_add_cvd_taxes           := 0; /*5228046 Additional cvd Enhancement*/
  p_customs_taxes           := 0;
  p_third_party_taxes       := 0;
  p_excise_tax              := 0;
  p_service_recoverable     := 0;
  p_service_not_recoverable := 0;
  p_vat_recoverable         := 0;
  p_vat_not_recoverable     := 0;
  p_excise_edu_cess         := 0;
  p_cvd_edu_cess            := 0;
  p_customs_edu_cess        := 0;
  p_excise_sh_edu_cess   		:= 0;	/*Bug 5989740 bduvarag*/
  p_cvd_sh_edu_cess      		:= 0;	/*Bug 5989740 bduvarag*/
  p_customs_sh_edu_cess  		:= 0;	/*Bug 5989740 bduvarag*/


  /*
  open  c_jai_regimes(jai_constants.service_regime);
  fetch c_jai_regimes into r_jai_regimes_servce;
  close c_jai_regimes;

  open  c_jai_regimes(jai_constants.vat_regime);
  fetch c_jai_regimes into r_jai_regimes_vat;
  close c_jai_regimes;
  */

  p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */

  for cur_rec in c_ja_in_receipt_tax_lines(p_shipment_line_id) loop

    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
    ln_tax_amount :=  cur_rec.tax_amount;

    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    ln_tax_amount  := ln_tax_amount * ln_tax_apportion_factor;
    /* apportionment for uom and quantity change wrt the parent RECEIVE
      line for which taxes exist */
    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
    if  nvl(cur_rec.currency, jai_rcv_trx_processing_pkg.gv_func_curr) <>
        jai_rcv_trx_processing_pkg.gv_func_curr
    then
      /* Tax not in functional currency, need to convert*/
      ln_tax_amount := ln_tax_amount * p_currency_conversion_rate;
    end if;

    /*bug 7640943 (FP for bug 7588482) - need to use rounded amounts for excise type of taxes while accounting
     *because amounts would be rounded for excise invoice (cenvat reversal)*/
      IF cur_rec.tax_type IN (jai_constants.tax_type_excise,jai_constants.tax_type_exc_additional,jai_constants.tax_type_exc_other,jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_sh_exc_edu_cess)
       THEN
       ln_tax_amount := Round(ln_tax_amount,Nvl(cur_rec.rounding_factor,0));
      END IF;
    /*end bug 7640943*/


    /* ln_tax_amount := round(ln_tax_amount, cur_rec.rounding_factor); Vijay. Final Observation */
    p_all_taxes := p_all_taxes + ln_tax_amount;

    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */

    if  cur_rec.tax_type = jai_constants.tax_type_tds then /* TDS*/

      p_codepath := jai_general_pkg.plot_codepath(7.1, p_codepath); /* 7.1 */
      p_tds_taxes := p_tds_taxes + ln_tax_amount;


    elsif   cur_rec.tax_type = jai_constants.tax_type_modvat_recovery then /* MODVAT RECOVERY*/

      p_codepath := jai_general_pkg.plot_codepath(7.2, p_codepath); /* 7.2 */
      p_modvat_recovery_taxes := p_modvat_recovery_taxes + ln_tax_amount;

    elsif   cur_rec.tax_type = jai_constants.tax_type_customs then /* CUSTOMS */

      p_codepath := jai_general_pkg.plot_codepath(7.3, p_codepath); /* 7.3 */
      p_customs_taxes := p_customs_taxes + ln_tax_amount;

    elsif   cur_rec.tax_type = jai_constants.tax_type_cvd then  /* CVD */

      p_codepath := jai_general_pkg.plot_codepath(7.4, p_codepath); /* 7.4 */
      p_cvd_taxes := p_cvd_taxes + ln_tax_amount;

    elsif   cur_rec.tax_type = jai_constants.tax_type_add_cvd then  /* ADDITIONAL CVD - Enhancement 5228046 */

      p_codepath := jai_general_pkg.plot_codepath(7.4, p_codepath); /* 7.4 */
      p_add_cvd_taxes := p_add_cvd_taxes + ln_tax_amount;

    elsif   cur_rec.tax_type = jai_constants.tax_type_exc_edu_cess  then /* Educational Cess Excise */

      p_codepath := jai_general_pkg.plot_codepath(7.5, p_codepath); /* 7.5 */
      p_excise_edu_cess :=  p_excise_edu_cess + ln_tax_amount;
/*Bug 5989740 bduvarag start*/
	  elsif   cur_rec.tax_type = jai_constants.tax_type_sh_exc_edu_cess  then /* Higher Secondary Educational Cess Excise */

		  p_codepath := jai_general_pkg.plot_codepath(7.51, p_codepath); /* 7.51 */
		  p_excise_sh_edu_cess :=  p_excise_sh_edu_cess + ln_tax_amount;

/*Bug 5989740 bduvarag end*/
    elsif   cur_rec.tax_type = jai_constants.tax_type_cvd_edu_cess  then /* Educational Cess CVD */

      p_codepath := jai_general_pkg.plot_codepath(7.6, p_codepath); /* 7.6 */
      p_cvd_edu_cess :=  p_cvd_edu_cess + ln_tax_amount;
/*Bug 5989740 bduvarag start*/
	  elsif   cur_rec.tax_type = jai_constants.tax_type_sh_cvd_edu_cess  then /* Higher Secondary Educational Cess CVD */

		  p_codepath := jai_general_pkg.plot_codepath(7.61, p_codepath); /* 7.61 */
		  p_cvd_sh_edu_cess :=  p_cvd_sh_edu_cess + ln_tax_amount;

/*Bug 5989740 bduvarag end*/
    elsif   cur_rec.tax_type = jai_constants.tax_type_customs_edu_cess  then /* Educational Cess CVD */

     p_codepath := jai_general_pkg.plot_codepath(7.7, p_codepath); /* 7.7 */
     p_customs_edu_cess :=  p_customs_edu_cess + ln_tax_amount;
/*Bug 5989740 bduvarag start*/
    elsif   cur_rec.tax_type = jai_constants.tax_type_sh_customs_edu_cess  then /* Higher Secondary Educational Cess CVD */

		 p_codepath := jai_general_pkg.plot_codepath(7.71, p_codepath); /* 7.71 */
		 p_customs_sh_edu_cess :=  p_customs_sh_edu_cess + ln_tax_amount;
/*Bug 5989740 bduvarag end*/
    elsif   cur_rec.tax_type in
            (
              jai_constants.tax_type_excise         , /* EXCISE */
              jai_constants.tax_type_exc_additional , /* EXCISE ADDITIONAL */
              jai_constants.tax_type_exc_other        /* EXCISE OTHERS */
            )
            then

     p_codepath := jai_general_pkg.plot_codepath(7.8, p_codepath); /* 7.8 */
     p_excise_tax := p_excise_tax + ln_tax_amount;

    else

      /* Check tax type by regime, Service and then VAT */

      p_codepath := jai_general_pkg.plot_codepath(7.9, p_codepath); /* 7.9 */

      /*
      r_is_tax_type_in_regime := null;

      open c_is_tax_type_in_regime(r_jai_regimes_servce.regime_id, cur_rec.tax_type);
      fetch c_is_tax_type_in_regime into r_is_tax_type_in_regime;
      close c_is_tax_type_in_regime;

      if   r_is_tax_type_in_regime.regime_tax_type is not null then*/

      /* Service type of Tax */
      if cur_rec.regime_code = jai_constants.service_regime then
        p_codepath := jai_general_pkg.plot_codepath(7.11, p_codepath); /* 7.11 */

        /*bug 8488470 - modified the if block.
          Issue - Unbalanced entries in GL for correct / RTV transactions.
          Cause - In case of recoverable VAT, the individual tax line is rounded, and the credit / debit
                  is done with the rounded amount for interim accounting. But the accrual accounting is
                  using the unrounded amount. This is because the tax amount is rounded only in case of
                  partially recoverable taxes here. Rounding should be applied for fully recoverable taxes
                  also. Moreover, the rounded amount should be considered for the total amount being stored
                  in p_all_taxes variable also.
                  Though issue was observed for VAT related transactions, same is possible with Service tax
                  also.*/
        if  ( cur_rec.modvatable = 'Y' ) then
          p_codepath := jai_general_pkg.plot_codepath(7.12, p_codepath); /* 7.12 */
          /*Bug 5527885 start*/
          p_service_recoverable := p_service_recoverable + Round(ln_tax_amount * cur_rec.recoverable/100, cur_rec.rounding_factor);
          p_service_not_recoverable := p_service_not_recoverable + (ln_tax_amount * (100-cur_rec.recoverable)/100);
          p_all_taxes := p_all_taxes - ln_tax_amount + Round(ln_tax_amount * cur_rec.recoverable/100, cur_rec.rounding_factor) + (ln_tax_amount * (100-cur_rec.recoverable)/100);
        else
          p_codepath := jai_general_pkg.plot_codepath(7.13, p_codepath); /* 7.13 */
          p_service_not_recoverable := p_service_not_recoverable + ln_tax_amount;
        end if;

/*Bug 5527885 End*/
      else

        p_codepath := jai_general_pkg.plot_codepath(7.14, p_codepath); /* 7.14 */

        /*
        r_is_tax_type_in_regime := null;
        open c_is_tax_type_in_regime(r_jai_regimes_vat.regime_id, cur_rec.tax_type);
        fetch c_is_tax_type_in_regime into r_is_tax_type_in_regime;
        close c_is_tax_type_in_regime;

        if   r_is_tax_type_in_regime.regime_tax_type is not null then */

        /* VAT type of Tax */
        if cur_rec.regime_code = jai_constants.vat_regime then
          p_codepath := jai_general_pkg.plot_codepath(7.15, p_codepath); /* 7.15 */

        /*bug 8488470 - modified the if block.
          Issue - Unbalanced entries in GL for correct / RTV transactions.
          Cause - In case of recoverable VAT, the individual tax line is rounded, and the credit / debit
                  is done with the rounded amount for interim accounting. But the accrual accounting is
                  using the unrounded amount. This is because the tax amount is rounded only in case of
                  partially recoverable taxes here. Rounding should be applied for fully recoverable taxes
                  also. Moreover, the rounded amount should be considered for the total amount being stored
                  in p_all_taxes variable also..*/
          if  (cur_rec.modvatable = 'Y' ) then
            p_codepath := jai_general_pkg.plot_codepath(7.16, p_codepath); /* 7.16 */
            p_vat_recoverable := p_vat_recoverable + Round(ln_tax_amount * cur_rec.recoverable/100, cur_rec.rounding_factor);
            p_vat_not_recoverable := p_vat_not_recoverable + (ln_tax_amount * (100 - cur_rec.recoverable)/100);
            p_all_taxes := p_all_taxes - ln_tax_amount + Round(ln_tax_amount * cur_rec.recoverable/100, cur_rec.rounding_factor) + (ln_tax_amount * (100 - cur_rec.recoverable)/100);
         -- End 6971526
          else
            p_codepath := jai_general_pkg.plot_codepath(7.17, p_codepath); /* 7.17 */
            p_vat_not_recoverable := p_vat_not_recoverable + ln_tax_amount;
          end if;

        end if; /* Service and VAT */

      end if; /* else after all tax types */

    end if; /* Check all tax and tax type */


    /* get third party amount */
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
    if
      cur_rec.vendor_id <> p_po_vendor_id and
      cur_rec.vendor_id > 0 and
      cur_rec.tax_type not in (jai_constants.tax_type_tds, jai_constants.tax_type_modvat_recovery)
    then
      p_third_party_taxes := p_third_party_taxes + ln_tax_amount;
    end if;

    /* To indicate second pass of the loop, first means F, statement id need not be incremented in code path*/

  end loop; /* c_ja_in_receipt_tax_lines */

  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, null, 'END'); /* 9 */

  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  Code Path :' || p_codepath );
--    Fnd_File.put_line(Fnd_File.LOG, '  ** End of procedure jai_rcv_rcv_rtv_pkg.get_tax_breakup **  ');/*Bug 5527885*/
  end if;

  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.get_tax_breakup:' || sqlerrm;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path:' || p_codepath );
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 24 */
    return;

end get_tax_breakup;

/******************************** End get_tax_breakup *****************************/


/****************************** Start validate_transaction_tax_accnt ******************************/
  procedure validate_transaction_tax_accnt
  (
    p_transaction_type                        in                  varchar2,
    p_parent_transaction_type                 in                  varchar2,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category                      in                  varchar2,
    p_receipt_source_code                     in                  varchar2,
    p_boe_account_id                          in                  number,
    p_rtv_expense_account_id                  in                  number,
    p_excise_expense_account                  in                  number,
    p_excise_rcvble_account                   in                  number,
    p_receiving_account_id                    in out  nocopy      number,
    p_ap_accrual_account                      in out  nocopy      number,
    p_po_accrual_account_id                   in                  number,
    p_interorg_payables_account               in                  number,
    p_intransit_inv_account                   in                  number,
    p_interorg_receivables_account            in                  number,
    p_intransit_type                          in                  number,
    p_fob_point                               in                  number,
    p_cvd_taxes                               in                  number,
    p_add_cvd_taxes                           in                  number,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                           in                  number,
    p_third_party_taxes                       in                  number,
    p_excise_tax                              in                  number,
    p_trading_to_trading_iso                  in                  varchar2, /* Bug#4171469 */
    p_debug                                   in                  varchar2,   -- default 'N', File.Sql.35
    p_process_flag                            out      nocopy     varchar2,
    p_process_message                         out      nocopy     varchar2,
    p_codepath                                in out   nocopy     varchar2
  )
is


begin

  /* Start Validate Receving Account p_receiving_account_id */
  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  **    Start of procedure jai_rcv_rcv_rtv_pkg.validate_transaction_tax_accnt **');
  end if;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.validate_transaction_tax_accnt', 'START'); /* 1 */

  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. if p_attribute_category  = 'INDIA RMA RECEIPT' then
  if p_receipt_source_code = 'CUSTOMER' then

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */

    if  p_excise_expense_account is null then

      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      p_process_flag    := 'E';
      p_process_message := 'Excise Expense Account is not defined in JAI_CMN_INVENTORY_ORGS, ' ||
                           'for the organization location or null location, cannot proceed as transaction type is RMA';

      goto exit_from_procedure;

    else

      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      p_receiving_account_id := p_excise_expense_account;

    end if;

  elsif p_receiving_account_id is null then

    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    p_process_flag    := 'E';
    p_process_message := 'Receiving Account is not defined in rcv_parameters for the organization.';
    goto exit_from_procedure;

  end if; /*  if p_receipt_source_code = 'CUSTOMER' then
            (p_attribute_category  = 'INDIA RMA RECEIPT') */

  /* End Validate Receving Account p_receiving_account_id */


  /* Start Validate Accrual Account */

  p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
  if p_receipt_source_code in ('INTERNAL ORDER','INVENTORY') then /*added INVENTORY for bug #6030615 by vkaranam*/


    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    /*6488406*/
    if ( ( (p_intransit_type = 2) and (p_fob_point = 1) ) or
(p_trading_to_trading_iso = 'Y'  and p_receipt_source_code = 'INTERNAL ORDER') )then /* Bug#4171469 */

      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
      if p_intransit_inv_account is null then

        p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
        p_process_flag    := 'E';
        p_process_message := 'Intransit Inventory Account is not defined in mtl_interorg_parameters for ' ||
                               'from and to organization of the ISO. ';
          goto exit_from_procedure;
      else
        p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
        p_ap_accrual_account := p_intransit_inv_account;
      end if;

    else

      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11  */

      if p_interorg_payables_account is null then
        p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12  */
        p_process_flag    := 'E';
        p_process_message := 'Inter-org Payables Account is not defined in mtl_interorg_parameters for ' ||
                             'from and to organization of the ISO. ';
        goto exit_from_procedure;
      else
        p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13  */
        p_ap_accrual_account := p_interorg_payables_account;
      end if;

    end if;

  elsif p_receipt_source_code = 'CUSTOMER' then
   -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. if p_attribute_category  = 'INDIA RMA RECEIPT' then

    p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14  */

    if  p_excise_rcvble_account is null then
      p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15  */
      p_process_flag    := 'E';
      p_process_message := 'Excise Receivable Account is not defined in JAI_CMN_INVENTORY_ORGS, ' ||
                           'for the organization location or null location, cannot proceed as transaction type is RMA';
      goto exit_from_procedure;
    else
      p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16  */
      p_ap_accrual_account := p_excise_rcvble_account;
    end if;


  elsif p_po_accrual_account_id is not null then

    p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17  */
    p_ap_accrual_account := p_po_accrual_account_id;

  elsif p_ap_accrual_account is null then

    p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18  */
    p_process_flag    := 'E';
    p_process_message := 'AP Accrual Account is not defined in mtl_parameters for the organization.';
    goto exit_from_procedure;

  end if; /* p_receipt_source_code = 'INTERNAL ORDER' */

  /* End Validate Accrual Account */


  /* Start 'RETURN TO VENDOR'  RTV expense account check */

  p_codepath := jai_general_pkg.plot_codepath(19, p_codepath); /* 19  */
  if ( (p_transaction_type = 'RETURN TO VENDOR')
        or
       (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RETURN TO VENDOR')
      )
  then

    /* Check if Customs, CVD (BOE) or third party type taxes exist */
    p_codepath := jai_general_pkg.plot_codepath(20,  p_codepath); /* 20  */

    if (  (p_cvd_taxes <> 0) OR
          (p_add_cvd_taxes     <> 0) OR  /*5228046 Additional cvd Enhancement*/
          (p_customs_taxes <> 0) OR
	  (p_third_party_taxes <> 0)
	) then

      p_codepath := jai_general_pkg.plot_codepath(21,  p_codepath); /* 21  */

      if  p_rtv_expense_account_id is null then
        p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); /* 22  */
        p_process_flag    := 'E';
        p_process_message := 'RTV Expense Account is not defined in JAI_CMN_INVENTORY_ORGS, ' ||
                             'for the organization location or null location, cannot proceed as transaction type is RTV';
        goto exit_from_procedure;
      end if;

    end if; /* Custom / CVD /third party type of taxes exist  */


  end if;

  /* End 'RETURN TO VENDOR'  RTV expense account check */


  /* Start BOE a/c check */
  if ( (p_transaction_type = 'RECEIVE')
        or
       (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RECEIVE')
      )
  then

    if (  (p_cvd_taxes <> 0) or
          (p_add_cvd_taxes     <> 0) OR  /*5228046 Additional cvd Enhancement*/
          (p_customs_taxes <> 0)
	) then

      p_codepath := jai_general_pkg.plot_codepath(23, p_codepath); /* 23  */

      if p_boe_account_id is null then
          p_codepath := jai_general_pkg.plot_codepath(24, p_codepath); /* 24  */
          p_process_flag    := 'E';
          p_process_message := 'BOE Account is not defined in JAI_CMN_INVENTORY_ORGS, ' ||
                               'for the organization location or null location.';
          goto exit_from_procedure;
      end if;
    end if;

  end if; /*'RECEIVE'*/
  /* End BOE a/c check */


  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(25, p_codepath, null, 'END'); /* 25  */

  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  if p_debug = 'Y' then
--    Fnd_File.put_line(Fnd_File.LOG, '  Code Path :' || p_codepath );/*Bug 5527885*/
    Fnd_File.put_line(Fnd_File.LOG, '  ** End of procedure jai_rcv_rcv_rtv_pkg.validate_transaction_tax_accnt **  ');
  end if;

  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.validate_transaction_tax_accnt:'|| sqlerrm;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path:' || p_codepath );
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 24 */
    return;

end validate_transaction_tax_accnt;

/****************************** End validate_transaction_tax_accnt ******************************/

/****************************** Start apply_relieve_boe ******************************/
  procedure apply_relieve_boe
  (
    p_transaction_id                           in                 number,
    p_transaction_type                         in                 varchar2,
    p_parent_transaction_id                    in                 number,
    p_parent_transaction_type                  in                 varchar2,
    p_shipment_line_id                         in                 number,
    p_shipment_header_id                       in                 number,
    p_organization_id                          in                 number,
    p_inventory_item_id                        in                 number,
    p_cvd_taxes                                in                 number,
    p_add_cvd_taxes                            in                 number,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                            in                 number,
    p_cvd_edu_cess                             in                 number, /* Educational Cess */
    p_cvd_sh_edu_cess                          in                 number, /*Bug 5989740 bduvarag*/
    p_customs_edu_cess                         in                 number, /* Educational Cess */
    p_customs_sh_edu_cess                      in                 number, /*Bug 5989740 bduvarag*/
    p_simulation                               in                 varchar2,
    p_debug                                    in                 varchar2,  -- default 'N', File.Sql.35
    p_process_flag                             out     nocopy     varchar2,
    p_process_message                          out     nocopy     varchar2,
    p_codepath                                 in out  nocopy     varchar2
  )
  is

  cursor    c_is_boe_applied(cp_shipment_line_id number, cp_parent_transaction_id number) is
    select  count(boe_id)
    from    JAI_CMN_BOE_MATCHINGS
    where   shipment_line_id  =   cp_shipment_line_id
    and     transaction_id    =   cp_parent_transaction_id;

  ln_boe_count      number; -- :=0  File.Sql.35 by Brathod

begin
  ln_boe_count := 0;  -- File.Sql.35 by Brathod
  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  **    Start of procedure jai_rcv_rcv_rtv_pkg.apply_relieve_boe **');
  end if;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.apply_relieve_boe', 'START'); /* 1  */

  if not (p_transaction_type = 'CORRECT' and p_parent_transaction_type = 'RECEIVE') then
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2  */
    -- ABC
    --p_process_flag := 'Y';
    --p_process_message := 'apply_relieve_boe is not required as this is not a case of CORRECT to RECEIVE';
    FND_FILE.put_line( FND_FILE.log, 'Apply_relieve_boe is not required as this is not a case of CORRECT to RECEIVE');
    goto exit_from_procedure;
  elsif (p_cvd_taxes + p_add_cvd_taxes + p_customs_taxes) = 0 then /*5228046 Additional cvd Enhancement added p_add_cvd_taxes*/
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3  */
    -- ABC
    --p_process_flag := 'Y';
    --p_process_message := 'apply_relieve_boe is not required as no CVD or Customs type of tax';
    FND_FILE.put_line( FND_FILE.log, 'Apply_relieve_boe is not required as no CVD or ADDITIONAL_CVD or Customs type of tax');
    goto exit_from_procedure;
  end if;

  /* Check if BOE has been applied for the parent transaction */
  p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4  */
  open c_is_boe_applied(p_shipment_line_id, p_parent_transaction_id);
  fetch c_is_boe_applied into ln_boe_count;
  close c_is_boe_applied;

  if nvl(ln_boe_count, 0) = 0 then
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5  */
    -- ABC
    --p_process_flag := 'Y';
    --p_process_message := 'apply_relieve_boe is not required parent transaction has no BOE applied';
    FND_FILE.put_line( FND_FILE.log, 'Apply_relieve_boe is not required parent transaction has no BOE applied');
    goto exit_from_procedure;
  end if;


  if (p_cvd_taxes + p_add_cvd_taxes + p_customs_taxes) > 0 then /*5228046 Additional cvd Enhancement added p_add_cvd_taxes*/

    if p_debug = 'Y' then
      Fnd_File.put_line(Fnd_File.LOG, ' Call to -> apply_boe');
    end if;
    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6  */
    apply_boe
    (
      p_shipment_header_id      =>     p_shipment_header_id,
      p_shipment_line_id        =>     p_shipment_line_id,
      p_transaction_id          =>     p_transaction_id,
      p_organization_id         =>     p_organization_id,
      p_inventory_item_id       =>     p_inventory_item_id,
      p_boe_tax                 =>     p_cvd_taxes     +
                                       p_add_cvd_taxes + /*5228046 Additional cvd Enhancement added p_add_cvd_taxes*/
                                       p_customs_taxes +
                                       p_cvd_edu_cess  +
                                       p_cvd_sh_edu_cess  + /*Bug 5989740 bduvarag*/
                                       p_customs_edu_cess +
                                       p_customs_sh_edu_cess,
      p_simulation              =>     p_simulation,
      p_process_flag            =>     p_process_flag,
      p_process_message         =>     p_process_message,
      p_debug                   =>     p_debug,
      p_codepath                =>     p_codepath
    );

  else

    if p_debug = 'Y' then
      Fnd_File.put_line(Fnd_File.LOG, ' Call to -> relieve_boe');
    end if;
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7  */
    relieve_boe
    (
      p_shipment_header_id      =>     p_shipment_header_id,
      p_shipment_line_id        =>     p_shipment_line_id,
      p_transaction_id          =>     p_transaction_id,
      p_parent_transaction_id   =>     p_parent_transaction_id,
      p_boe_tax                 =>     p_cvd_taxes     +
                                       p_add_cvd_taxes + /*5228046 Additional cvd Enhancement added p_add_cvd_taxes*/
                                       p_customs_taxes +
                                       p_cvd_edu_cess  +
				       p_cvd_sh_edu_cess  + /*Bug 5989740 bduvarag*/
                                       p_customs_edu_cess +
                                       p_customs_sh_edu_cess,
      p_simulation              =>     p_simulation,
      p_process_flag            =>     p_process_flag,
      p_process_message         =>     p_process_message,
      p_debug                   =>     p_debug,
      p_codepath                =>     p_codepath
    );

  end if;

  /* If apply relieve BOE has been done successfully, update the boe_applied_flag in ja_in_rcv_transaction */
  if p_process_flag = 'Y' and nvl(p_simulation , 'Y') <> 'Y'  then

    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8  */
    update  JAI_RCV_TRANSACTIONS
    set     boe_applied_flag = 'Y'
    where   transaction_id = p_transaction_id;

  end if;

  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, null, 'END'); /* 9  */

  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.apply_relieve_boe:' || sqlerrm;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path:' || p_codepath );
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 24 */
    return;

end apply_relieve_boe;


/****************************** End   apply_relieve_boe ******************************/


/****************************** Start apply_boe ******************************/

  procedure apply_boe
  (
    p_shipment_header_id                       in                 number,
    p_shipment_line_id                         in                 number,
    p_transaction_id                           in                 number,
    p_organization_id                          in                 number,
    p_inventory_item_id                        in                 number,
    p_boe_tax                                  in                 number,
    p_simulation                               in                 varchar2,
    p_debug                                    in                 varchar2,  -- default 'N', File.Sql.35
    p_process_flag                             out     nocopy     varchar2,
    p_process_message                          out     nocopy     varchar2,
    p_codepath                                 in out  nocopy     varchar2
  )
is

  cursor c_ja_in_boe_hdr (cp_organization_id number, cp_inventory_item_id number) is
  select boe_id,
         ( nvl(boe_amount, 0) - nvl(amount_applied, 0) - nvl(amount_written_off, 0) )
         available_amount
  from   JAI_CMN_BOE_HDRS  jbh
  where  organization_id =  p_organization_id
  and    ( nvl(boe_amount, 0) - nvl(amount_applied, 0) - nvl(amount_written_off, 0) ) > 0
  and    ( ( nvl(consolidated_flag, 'Y') = 'Y' )
           or
           ( exists ( select '1'
                      from   JAI_CMN_BOE_DTLS
                      where  boe_id = jbh.boe_id
                      and    item_number = cp_inventory_item_id
                     )
           )
         );

  ln_bal_boe_amount         number;
  ln_boe_amount_to_apply    number;

begin

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  **    Start of procedure jai_rcv_rcv_rtv_pkg.apply_boe **');
  end if;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.apply_boe', 'START'); /* 1  */

  ln_bal_boe_amount := p_boe_tax;

  for cur_available_boe in c_ja_in_boe_hdr(p_organization_id, p_inventory_item_id) loop

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2  */

    if ln_bal_boe_amount <= 0 then
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3  */
      goto finish_apply;
    end if;

    if cur_available_boe.available_amount <= ln_bal_boe_amount then
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4  */
      ln_boe_amount_to_apply := cur_available_boe.available_amount;
    else
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5  */
      ln_boe_amount_to_apply := ln_bal_boe_amount;
    end if;

    if nvl(p_simulation , 'Y') <> 'Y' then

      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6  */

      /* Insert a apply record in JAI_CMN_BOE_MATCHINGS */
      insert into JAI_CMN_BOE_MATCHINGS
      (BOE_MATCHING_ID,
        transaction_id,
        shipment_header_id,
        shipment_line_id,
        boe_id,
        amount,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by
       )
      values
      ( JAI_CMN_BOE_MATCHINGS_S.nextval,
        p_transaction_id,
        p_shipment_header_id,
        p_shipment_line_id,
        cur_available_boe.boe_id,
        ln_boe_amount_to_apply,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
      );

      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7  */
      /* update the boe header amount */
      update  JAI_CMN_BOE_HDRS
      set     amount_applied = nvl(amount_applied, 0) + ln_boe_amount_to_apply,
              last_update_date = sysdate,
              last_updated_by = fnd_global.user_id,
              last_update_login = fnd_global.user_id
      where   boe_id = cur_available_boe.boe_id;

      ln_bal_boe_amount := ln_bal_boe_amount - ln_boe_amount_to_apply;

      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8  */

    end if;

    /* To indicate second pass of the loop, first means F, statement id need not be incremented in code path*/

  end loop;

  << finish_apply >>
  if ln_bal_boe_amount > 0 then
    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9  */
    p_process_flag    := 'E';
    P_process_message := 'Matching BOE not available for applying the BOE tax, cannot proceed ' ||
                         '(jai_rcv_rcv_rtv_pkg.apply_boe)';
  end if;

  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(10, p_codepath, null, 'END'); /* 10  */

  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  Code Path :' || p_codepath );
    Fnd_File.put_line(Fnd_File.LOG, '  ** End of procedure jai_rcv_rcv_rtv_pkg.apply_boe **  ');
  end if;

  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.apply_boe:'|| sqlerrm;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path:' || p_codepath );
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 24 */
    return;

end apply_boe;

/****************************** End apply_boe ******************************/


/****************************** Start relieve_boe ******************************/

  procedure relieve_boe
  (
    p_shipment_header_id                       in                 number,
    p_shipment_line_id                         in                 number,
    p_transaction_id                           in                 number,
    p_parent_transaction_id                    in                 number,
    p_boe_tax                                  in                 number,
    p_simulation                               in                 varchar2,
    p_debug                                    in                 varchar2,  -- default 'N', File.Sql.35
    p_process_flag                             out     nocopy     varchar2,
    p_process_message                          out     nocopy     varchar2,
    p_codepath                                 in out  nocopy     varchar2
  )
  is

  cursor c_ja_in_rcp_boe(cp_shipment_line_id number, cp_transaction_id number) is
    select boe_id, amount
    from   JAI_CMN_BOE_MATCHINGS
    where  shipment_line_id = cp_shipment_line_id
    and    transaction_id =   cp_transaction_id;

  ln_bal_boe_amount         number;
  ln_boe_amount_to_unapply  number;

begin

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  **    Start of procedure jai_rcv_rcv_rtv_pkg.relieve_boe **');
  end if;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.relieve_boe', 'START'); /* 1  */
  ln_bal_boe_amount :=  p_boe_tax;

  for applied_boe_rec in   c_ja_in_rcp_boe(p_shipment_line_id, p_parent_transaction_id) loop

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2  */
    if  ln_bal_boe_amount = 0 then
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3  */
      goto   finished_unapply;
    end if;

    if   applied_boe_rec.amount <= abs(ln_bal_boe_amount) then
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4  */
      ln_boe_amount_to_unapply := -1 * applied_boe_rec.amount;
    else
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5  */
      ln_boe_amount_to_unapply := ln_bal_boe_amount;
    end if;

    if nvl(p_simulation , 'Y') <> 'Y' then
      /* Insert a unapply record in JAI_CMN_BOE_MATCHINGS */
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6  */
      insert into JAI_CMN_BOE_MATCHINGS
      (BOE_MATCHING_ID,
        transaction_id,
        shipment_header_id,
        shipment_line_id,
        boe_id,
        amount,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by
       )
      values
      ( JAI_CMN_BOE_MATCHINGS_S.nextval,
        p_transaction_id,
        p_shipment_header_id,
        p_shipment_line_id,
        applied_boe_rec.boe_id,
        ln_boe_amount_to_unapply,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
      );

      /* update the boe header amount */
      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7  */
      update  JAI_CMN_BOE_HDRS
      set     amount_applied = nvl(amount_applied, 0) + ln_boe_amount_to_unapply,
              last_update_date = sysdate,
              last_updated_by = fnd_global.user_id,
              last_update_login = fnd_global.user_id
      where   boe_id = applied_boe_rec.boe_id;

    end if; /* p_simulation = 'Y' */

    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8  */
    ln_bal_boe_amount := ln_bal_boe_amount - ln_boe_amount_to_unapply;


  end loop;

  << finished_unapply >>
    p_process_flag := 'Y';

  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, null, 'END'); /* 9  */

  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  Code Path :' || p_codepath );
    Fnd_File.put_line(Fnd_File.LOG, '  ** End of procedure jai_rcv_rcv_rtv_pkg.relieve_boe **  ');
  end if;

  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.relieve_boe:' || sqlerrm;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path:' || p_codepath );
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 24 */
    return;

end relieve_boe;

/****************************** End relieve_boe ******************************/


/****************************** Start post_entries ******************************/
  procedure post_entries
  (
    p_transaction_id                            in                number,
    p_transaction_type                          in                varchar2,
    p_parent_transaction_type                   in                varchar2,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category                        in                varchar2,
    p_receipt_source_code                       in                varchar2,
    p_transaction_date                          in                date,
    p_receipt_num                               in                varchar2,
    p_receiving_account_id                      in                number,
    p_ap_accrual_account                        in                number,
    p_boe_account_id                            in                number,
    p_rtv_expense_account_id                    in                number,
    p_intransit_type                            in                number,
    p_fob_point                                 in                number,
    p_intransit_inv_account                     in                number,
    p_interorg_receivables_account              in                number,
    p_all_taxes                                 in                number,
    p_tds_taxes                                 in                number,
    p_modvat_recovery_taxes                     in                number,
    p_cvd_taxes                                 in                number,
    p_add_cvd_taxes                             in                number,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                             in                number,
    p_third_party_taxes                         in                number,
    p_excise_tax                                in                number,
    p_service_recoverable                       in                number, /* Service */
    p_service_not_recoverable                   in                number, /* Service */
    p_account_service_interim                   in                boolean, /* Service */
    /* following two params added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    p_vat_recoverable                           in                number,
    p_vat_not_recoverable                       in                number,
    p_excise_edu_cess                           in                number, /* Educational Cess */
    p_excise_sh_edu_cess                        in                number, /*Bug 5989740 bduvarag*/
    p_cvd_edu_cess                              in                number, /* Educational Cess */
    p_cvd_sh_edu_cess                           in                number, /*Bug 5989740 bduvarag*/
    p_customs_edu_cess                          in                number, /* Educational Cess */
    p_customs_sh_edu_cess                       in                number, /*Bug 5989740 bduvarag*/
    p_trading_to_trading_iso                    in                varchar2, /* Bug#4171469 */
    ptr_jv                                      in OUT NOCOPY JOURNAL_LINES,  /* 5527885 */
    p_simulation                                in                varchar2,
    p_debug                                     in                varchar2,  -- default 'N', File.Sql.35
    p_process_flag                              out     nocopy    varchar2,
    p_process_message                           out     nocopy    varchar2,
    p_codepath                                  in out  nocopy    varchar2
  )  is

  cursor c_ja_in_temp_po_accrual (cp_transaction_id number) is
    select  count(1)
    from    JAI_RCV_REP_ACCRUAL_T
    where   transaction_id = cp_transaction_id;

  ln_ja_in_temp_po_accrual      number;

  ln_credit                     number;
  ln_debit                      number;

  /* File.Sql.35 by Brathod */
  lv_source_name                varchar2(20); -- := 'Purchasing India'; -- Harshita . modified the size from 15 to 20 for Bug 4762433
  lv_category_name              varchar2(15); --:= 'Receiving India';
  lv_acct_nature                varchar2(15); --:= 'Receiving';
  lv_acct_type                  varchar2(15);  /* Regular or Reversal*/

  lv_reference_10               varchar2(240);
  lv_reference_23               varchar2(240); -- := 'jai_rcv_rcv_rtv_pkg.post_entries';
  lv_reference_24               varchar2(240); -- := 'rcv_transactions';
  lv_reference_25               varchar2(240); -- :=  'transaction_id';
  lv_reference_26               varchar2(240);
  /* End of File.Sql.35 by Brathod */


begin
/* -----------------------------------------------------------------------------------------------

|  Type |  Additional  |  Account             | Debit/Credit    |  Tax details                     |
|       |  Condition   |                      |                 |                                  |
|  ==== |  ==========  |  ============        | ===========     |  ===========                     |
|  RTV  |  None        |  Receiving           | Credit          | ALL -                            |
|       |              |                      |                 | (TDS + Modvat Recovery +         |
|       |              |                      |                 |  Recoverable Service Tax +       |
|       |              |                      |                 |  Recoverable VAT Tax )           |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|       |  None        |  AP Accrual          | Debit           |  ALL -                           |
|       |              |                      |                 | (TDS + Modvat Recovery +         |
|       |              |                      |                 |  3rd Party + CVD + Customs +     |
|       |              |                      |                 |  Recoverable Service Tax** +     |
|       |              |                      |                 |  Recoverable VAT     Tax** +     |
|       |              |                      |                 |  CVD Edu Cess + Custom Edu Cess) |
|       |              |                      |                 |                                  |
|       |  None        |  RTV expense         | Debit           | 3rd Party + CVD + Customs        |
|       |              |                      |                 | CVD Edu Cess + Custom Edu Cess   |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|=======|==============|======================|=================|==================================|
|       |              |                      |                 |                                  |
|  RMA  |  SCRAP type  |  Excise Expense      | Debit           | Excise + CVD +                   |
|       |              |                      |                 | Excise Edu Cess + CVD Edu Cess   |
|       |              |  Excise Receivable   | Credit          | Excise + CVD                     |
|       |              |                      |                 | Excise Edu Cess + CVD Edu Cess   |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|=======|==============|======================|=================|==================================|
|  ISO  |  None        |  Receiving           | Debit           |  ALL -                           |
|       |              |                      |                 | (TDS + Modvat Recovery +         |
|       |              |                      |                 |  Recoverable Service Tax )       |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|       |  None        |  Intransit Inventory | Credit          | ALL -                            |
|       |              |                      |                 |(TDS + Modvat Recovery +          |
|       |              |                      |                 | CVD + Customs                    |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|       |  None        |  BOE                 | Credit          | CVD + Customs +                  |
|       |              |                      |                 | CVD Edu Cess + Custom Edu Cess   |
|       |--------------|----------------------|-----------------|----------------------------------|
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|       |  Intransit   |                      |                 |                                  |
|       |  Type=2 &    |                      |                 |                                  |
|       |  FOB point=2 |  Interorg Payables   | Credit          |  ALL -                           |
|       |  and not     |                      |                 |  (TDS + Modvat Recovery +        |
|       |  trading to  |                      |                 |   CVD + Customs +                |
|       |  trading ISO |                      |                 |   CVD Edu Cess + Custom Edu Cess |
|       |              |                      |                 |                                  |
|       |  Intransit   |                      |                 |                                  |
|       |  Type=2 &    |                      |                 |                                  |
|       |  FOB point=2 |  Interorg Receivables| Debit           |  ALL -                           |
|       |  and not     |                      |                 |  (TDS + Modvat Recovery +        |
|       |  trading to  |                      |                 |   CVD + Customs +                |
|       |  trading ISO |                      |                 |   CVD Edu Cess + Custom Edu Cess |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|=======|==============|======================|=================|================================= |
|       |              |                      |                 |                                  |
|PO     |  None        | Receiving            |Debit            | ALL -                            |
|Receive|              |                      |                 | (TDS + Modvat Recovery +         |
|       |              |                      |                 |  Recoverable Service Tax +       |
|       |              |                      |                 |  Recoverable VAT Tax )           |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|       |  None        |  AP Accrual          |Credit           | ALL -                            |
|       |              |                      |                 |(TDS + Modvat Recovery +          |
|       |              |                      |                 | CVD + Customs +                  |
|       |              |                      |                 | Recoverable Service Tax** +      |
|       |              |                      |                 | Recoverable VAT Tax** +          |
|       |              |                      |                 | CVD Edu Cess + Custom Edu Cess)  |
|       |              |                      |                 |                                  |
|       |  None        |  BOE                 | Credit          | CVD + Customs                    |
|       |              |                      |                 | CVD Edu Cess + Custom Edu Cess   |
|=======|==============|======================|=================|================================= |
|       |              |                      |                 |                                  |
|Service Tax Accounting at Receive, RTV or their Correct when recoverable service/vat tax exists **|
|       |              |                      |                 |                                  |
|PO     |  None        | Service Tax Interim  | Debit           | Recoverable Service Tax          |
|       |              | Recovery a/c         |                 | By tax type                      |
|       |              | for org and tax type |                 |                                  |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|PO     |  None        | VAT Tax Interim      | Debit           | Recoverable VAT Tax              |
|       |              | Recovery a/c         |                 | By tax type                      |
|       |              | for org and tax type |                 |                                  |
|       |              |                      |                 |                                  |
|       |              |                      |                 |                                  |
|-------|--------------|----------------------|-----------------|--------------------------------  |
|                                                                                                  |
| References:                                                                                      |
| ** - In addition to the existance of recoverable service tax, the following condition should also|
| be NOT TRUE.                                                                                     |
|                                                                                                  |
| ( accrue on receipt = 'N' or (inventory item = 'N' and accounting method option = 'Cash') )      |
|                                                                                                  |
|-----------------------------------------------------------------------------------------------   */
  /* File.Sql.35 by Brathod */
  lv_source_name                := 'Purchasing India';
  lv_category_name              := 'Receiving India';
  lv_acct_nature                := 'Receiving';
  lv_reference_23               := 'jai_rcv_rcv_rtv_pkg.post_entries';
  lv_reference_24               := 'rcv_transactions';
  lv_reference_25               :=  'transaction_id';
  /* End of File.Sql.35 by Brathod*/

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  **    Start of procedure jai_rcv_rcv_rtv_pkg.post_entries **');
  end if;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.post_entries', 'START'); /* 1  */
  /* Set varaiable values for accounting entries with GL link */
  if ( (p_transaction_type = 'RETURN TO VENDOR')
        or
       (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RETURN TO VENDOR')
      )
  then
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2  */
    lv_acct_type := 'REVERSAL';
  else
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3  */
    lv_acct_type := 'REGULAR';
  end if;

  p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4  */
  lv_reference_10 :=  'India Local Receiving Entry for the Receipt Number ' || p_receipt_num ||
                      ' for the Transaction Type ' || p_transaction_type ;

  if p_transaction_type = 'CORRECT' then
    lv_reference_10 := lv_reference_10 || ' of type ' || p_parent_transaction_type;
  end if;


  lv_reference_26 :=  to_char(p_transaction_id);

  /* Accounting Entry # 1 : Receiving Account Id */
  ln_credit := null;
  ln_debit  := null;
    Fnd_File.put_line(Fnd_File.LOG, ' p_receiving_account_id :' || p_receiving_account_id );
  if  p_receiving_account_id is not null then

    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5  */

    if ( (p_transaction_type = 'RETURN TO VENDOR')
          or
         (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RETURN TO VENDOR')
        )
    then

       p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6  */
       ln_debit  := null;
       ln_credit :=
       p_all_taxes -
       (p_tds_taxes + p_modvat_recovery_taxes + p_service_recoverable + p_vat_recoverable); /* Service */


    elsif p_receipt_source_code = 'CUSTOMER' and /*RMA CASE*/
     -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. if p_attribute_category  = 'INDIA RMA RECEIPT' and
          ( (p_transaction_type = 'RECEIVE')
              or
            (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RECEIVE')
          )
    then

      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7  */
      ln_debit  := p_cvd_taxes     +
                   p_add_cvd_taxes +  /*5228046 Additional cvd Enhancement*/
                   p_excise_tax    +
                   p_cvd_edu_cess  +
                   p_cvd_sh_edu_cess  +  /*Bug 5989740 bduvarag*/
                   p_excise_edu_cess + /* Educational Cess */
                   p_excise_sh_edu_cess;
      ln_credit := null;

    else

      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8  */

      ln_debit  :=
      p_all_taxes -
      (p_tds_taxes + p_modvat_recovery_taxes + p_service_recoverable + p_vat_recoverable);


      ln_credit := null;

    end if;

    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9  */
        Fnd_File.put_line(Fnd_File.LOG, ' ln_debit :' || ln_debit );
	        Fnd_File.put_line(Fnd_File.LOG, ' ln_credit :' || ln_credit );
    if ( nvl(ln_debit, 0) <> 0 or nvl(ln_credit, 0) <> 0 ) then
          p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10  */
      /* procedure to populate gl inetrface, JAI_RCV_JOURNAL_ENTRIES and receiving subledger */
       Fnd_File.put_line(Fnd_File.LOG, 'Acc for inventory  Receiving Account ' );

      ptr_jv(1).line_num           := 1;
      ptr_jv(1).acct_type          := lv_acct_type;
      ptr_jv(1).acct_nature        := lv_acct_nature;
      ptr_jv(1).source_name        := lv_source_name;
      ptr_jv(1).category_name      := lv_category_name;
      ptr_jv(1).ccid               := p_receiving_account_id;
      ptr_jv(1).entered_dr         := round(ln_debit, gn_currency_precision);
      ptr_jv(1).entered_cr         := round(ln_credit, gn_currency_precision);
      ptr_jv(1).currency_code      := jai_rcv_trx_processing_pkg.gv_func_curr;
      ptr_jv(1).accounting_date    := p_transaction_date;
      ptr_jv(1).reference_10       := lv_reference_10;
      ptr_jv(1).reference_23       := lv_reference_23;
      ptr_jv(1).reference_24       := lv_reference_24;
      ptr_jv(1).reference_25       := lv_reference_25;
      ptr_jv(1).reference_26       := lv_reference_26;
      ptr_jv(1).destination        := 'G';
      -- ptr_jv(1).reference_name     := ;
      ptr_jv(1).reference_id       := p_transaction_id;
      ptr_jv(1).non_rnd_entered_dr := ln_debit;
      ptr_jv(1).non_rnd_entered_cr := ln_credit;
      ptr_jv(1).account_name       := gv_inv_receiving;
      ptr_jv(1).summary_jv_flag    := 'Y';
/*Bug 5527885 End*/
    end if;

  end if; /* Accounting Entry # 1. Receiving Account Id */


  /* Accounting Entry # 2 : AP Accrual Account Id. Non mandatory entry values may be 0*/
  p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12  */

  ln_credit := null;
  ln_debit  := null;
       Fnd_File.put_line(Fnd_File.LOG, 'p_ap_accrual_account:'||p_ap_accrual_account );
  if p_ap_accrual_account is not null then

    if ( (p_transaction_type = 'RETURN TO VENDOR')
          or
         (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RETURN TO VENDOR')
        )
    then

       p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13  */
       ln_debit  := p_all_taxes -
                    ( p_tds_taxes             +
                      p_modvat_recovery_taxes +
                      p_cvd_taxes             +
                      p_add_cvd_taxes         + /*5228046 Additional cvd Enhancement*/
                      p_customs_taxes         +
                      p_third_party_taxes     +
                      p_cvd_edu_cess          +
		      p_cvd_sh_edu_cess       +		/*Bug 5989740 bduvarag*/
                      p_customs_edu_cess			+
                      p_customs_sh_edu_cess
                    );
       ln_credit := null;

       if  not p_account_service_interim then
         /* Separate Accounting for recoverable service tax not required */
         p_codepath := jai_general_pkg.plot_codepath(13.1, p_codepath); /* 13.1  */
         ln_debit :=  ln_debit - p_service_recoverable;
       end if;


    elsif p_receipt_source_code = 'CUSTOMER' then
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. if p_attribute_category  = 'INDIA RMA RECEIPT' then

      p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14  */
      ln_debit  :=  null;
      ln_credit  := p_cvd_taxes + p_add_cvd_taxes /*5143906 Additional cvd Enhancement*/ + p_excise_tax + p_cvd_edu_cess+ p_cvd_sh_edu_cess /*Bug 5989740 bduvarag*/ + p_excise_edu_cess +p_excise_sh_edu_cess /*Bug 5989740 bduvarag*/;
/* Replaced p_excise_edu_cess with p_excise_sh_edu_cess for bug# 8691046 */

    else

      p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15  */
      ln_debit  :=  null;
      ln_credit  := p_all_taxes -
                   ( p_tds_taxes + p_modvat_recovery_taxes +
                     p_cvd_taxes + p_add_cvd_taxes /*5228046 Additional cvd Enhancement*/ +
                     p_customs_taxes +
                     p_cvd_edu_cess +
		     p_cvd_sh_edu_cess +		/*Bug 5989740 bduvarag*/
                     p_customs_edu_cess +
                     p_customs_sh_edu_cess );

       if  not p_account_service_interim then
        /* Separate Accounting for recoverable service tax not required */
        p_codepath := jai_general_pkg.plot_codepath(15.1, p_codepath); /* 15.1  */
        ln_credit :=  ln_credit - p_service_recoverable;
       end if;

    end if;

           Fnd_File.put_line(Fnd_File.LOG, 'ln_debit:'||ln_debit );
            Fnd_File.put_line(Fnd_File.LOG, 'ln_credit:'||ln_credit );
    p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16  */
    if ( nvl(ln_debit, 0) <> 0  or nvl(ln_credit, 0) <> 0 ) then
      p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17  */

	      Fnd_File.put_line(Fnd_File.LOG, 'Accounting for interorg payables Acc' );
/*
      IF p_receipt_source_code = 'INVENTORY' THEN 6488406
        ln_inter_org_acct := p_interorg_payables_account;
	lv_acct_name      := gv_interorg_receiving;
      ELSE
        ln_inter_org_acct := p_ap_accrual_account;
	lv_acct_name      := gv_ap_accrual;
      END IF; */

      ptr_jv(2).line_num           := 2;
      ptr_jv(2).acct_type          := lv_acct_type;
      ptr_jv(2).acct_nature        := lv_acct_nature;
      ptr_jv(2).source_name        := lv_source_name;
      ptr_jv(2).category_name      := lv_category_name;
      ptr_jv(2).ccid               := p_ap_accrual_account;/*6488406*/
      ptr_jv(2).entered_dr         := round(ln_debit, gn_currency_precision);
      ptr_jv(2).entered_cr         := round(ln_credit, gn_currency_precision);
      ptr_jv(2).currency_code      := jai_rcv_trx_processing_pkg.gv_func_curr;
      ptr_jv(2).accounting_date    := p_transaction_date;
      ptr_jv(2).reference_10       := lv_reference_10;
      ptr_jv(2).reference_23       := lv_reference_23;
      ptr_jv(2).reference_24       := lv_reference_24;
      ptr_jv(2).reference_25       := lv_reference_25;
      ptr_jv(2).reference_26       := lv_reference_26;
      ptr_jv(2).destination        := 'G';
      -- ptr_jv(2).reference_name     := ;
      ptr_jv(2).reference_id       := p_transaction_id;
      ptr_jv(2).non_rnd_entered_dr := ln_debit;
      ptr_jv(2).non_rnd_entered_cr := ln_credit;
      ptr_jv(2).account_name       := gv_ap_accrual;/*6488406*/
      ptr_jv(2).summary_jv_flag    := 'Y';
/*Bug 5527885 End*/
      /* Inserting into JAI_RCV_REP_ACCRUAL_T if no record is already inserted */
      p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18  */
      open  c_ja_in_temp_po_accrual(p_transaction_id);
      fetch c_ja_in_temp_po_accrual into ln_ja_in_temp_po_accrual;
      close c_ja_in_temp_po_accrual;

      if nvl(ln_ja_in_temp_po_accrual, 0) = 0 then
        p_codepath := jai_general_pkg.plot_codepath(19, p_codepath); /* 19  */
        insert into JAI_RCV_REP_ACCRUAL_T
        (
          transaction_id,
          accrual_amount,
          -- Harshita, added the 4 parameters below for Bug 4762433
          created_by    ,
          creation_date ,
          last_updated_by,
          last_update_date,
          last_update_login
        )
        values
        (
          p_transaction_id,
          nvl(ln_credit, ln_debit) ,   /*bug 9319913*/
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.login_id
        );
      end if;

    end if; /* (ln_debit is not 0/null or ln_credit is not 0/null) */


  end if; /* p_ap_accrual_account */


  /* Accounting Entry # 3 : BOE Accounting Entry. Non mandatory entry */
  p_codepath := jai_general_pkg.plot_codepath(21, p_codepath); /* 21  */

  ln_credit := null;
  ln_debit  := null;

  if ( (p_transaction_type = 'RECEIVE')
        or
       (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RECEIVE')
      )
  then

    p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); /* 22  */
    if   (p_cvd_taxes + p_add_cvd_taxes /*5228046 Additional cvd Enhancement*/
            + p_customs_taxes
	    + p_cvd_edu_cess
	    + p_cvd_sh_edu_cess  /*Bug 5989740 bduvarag*/
            + p_customs_edu_cess
            +p_customs_sh_edu_cess) <> 0 THEN
      p_codepath := jai_general_pkg.plot_codepath(23, p_codepath); /* 23  */
      ln_debit    :=  null;
      ln_credit   :=  (p_cvd_taxes + p_add_cvd_taxes /*5228046 Additional cvd Enhancement*/
                     + p_customs_taxes
		     + p_cvd_edu_cess
		     +p_cvd_sh_edu_cess  /*Bug 5989740 bduvarag*/
	            + p_customs_edu_cess
		    +p_customs_sh_edu_cess);

      ptr_jv(3).line_num           := 3;
      ptr_jv(3).acct_type          := lv_acct_type;
      ptr_jv(3).acct_nature        := lv_acct_nature;
      ptr_jv(3).source_name        := lv_source_name;
      ptr_jv(3).category_name      := lv_category_name;
      ptr_jv(3).ccid               := p_boe_account_id;
      ptr_jv(3).entered_dr         := round(ln_debit, gn_currency_precision);
      ptr_jv(3).entered_cr         := round(ln_credit, gn_currency_precision);
      ptr_jv(3).currency_code      := jai_rcv_trx_processing_pkg.gv_func_curr;
      ptr_jv(3).accounting_date    := p_transaction_date;
      ptr_jv(3).reference_10       := lv_reference_10;
      ptr_jv(3).reference_23       := lv_reference_23;
      ptr_jv(3).reference_24       := lv_reference_24;
      ptr_jv(3).reference_25       := lv_reference_25;
      ptr_jv(3).reference_26       := lv_reference_26;
      ptr_jv(3).destination        := 'G';
      -- ptr_jv(3).reference_name     := ;
      ptr_jv(3).reference_id       := p_transaction_id;
      ptr_jv(3).non_rnd_entered_dr := ln_debit;
      ptr_jv(3).non_rnd_entered_cr := ln_credit;
      ptr_jv(3).account_name       := gv_boe;
      ptr_jv(3).summary_jv_flag    := 'N';

      /*Bug 5527885*/
    end if;

  end if; /* BOE Accounting Entry */



  /* Accounting Entry # 4 : RTV expense Accounting Entry, non mandatory entry */
  p_codepath := jai_general_pkg.plot_codepath(24, p_codepath); /* 24  */

  ln_credit := null;
  ln_debit  := null;

  if ( (p_transaction_type = 'RETURN TO VENDOR')
        or
       (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RETURN TO VENDOR')
      )
  then

    p_codepath := jai_general_pkg.plot_codepath(25, p_codepath); /* 25  */
IF  ( p_cvd_taxes     +
          p_add_cvd_taxes + /*5228046 Additional cvd Enhancement*/
          p_customs_taxes +
          p_cvd_edu_cess  +
          p_cvd_sh_edu_cess  +	 /*Bug 5989740 bduvarag*/
          p_customs_edu_cess +
          p_customs_sh_edu_cess +/*Bug 5989740 bduvarag*/
          p_third_party_taxes
        ) <> 0 THEN


      p_codepath := jai_general_pkg.plot_codepath(26, p_codepath); /* 26  */
      ln_debit    :=  ( p_cvd_taxes        + p_add_cvd_taxes /*5228046 Additional cvd Enhancement*/ +
                        p_customs_taxes    + p_cvd_edu_cess +
                        p_cvd_sh_edu_cess  /*Bug 5989740 bduvarag*/
                        +p_customs_edu_cess + p_customs_sh_edu_cess 	 + p_third_party_taxes
                      );
      ln_credit   :=  null;
      /*Bug 5527885 Start*/

      ptr_jv(4).line_num           := 4;
      ptr_jv(4).acct_type          := lv_acct_type;
      ptr_jv(4).acct_nature        := lv_acct_nature;
      ptr_jv(4).source_name        := lv_source_name;
      ptr_jv(4).category_name      := lv_category_name;
      ptr_jv(4).ccid               := p_rtv_expense_account_id;
      ptr_jv(4).entered_dr         := round(ln_debit, gn_currency_precision);
      ptr_jv(4).entered_cr         := round(ln_credit, gn_currency_precision);
      ptr_jv(4).currency_code      := jai_rcv_trx_processing_pkg.gv_func_curr;
      ptr_jv(4).accounting_date    := p_transaction_date;
      ptr_jv(4).reference_10       := lv_reference_10;
      ptr_jv(4).reference_23       := lv_reference_23;
      ptr_jv(4).reference_24       := lv_reference_24;
      ptr_jv(4).reference_25       := lv_reference_25;
      ptr_jv(4).reference_26       := lv_reference_26;
      ptr_jv(4).destination        := 'G';
      -- ptr_jv(4).reference_name     := ;
      ptr_jv(4).reference_id       := p_transaction_id;
      ptr_jv(4).non_rnd_entered_dr := ln_debit;
      ptr_jv(4).non_rnd_entered_cr := ln_credit;
      ptr_jv(4).account_name       := gv_rtv_expense;
      ptr_jv(4).summary_jv_flag    := 'N';
/*Bug 5527885*/
    end if;

  end if; /* RTV Expense Accounting Entry */


  p_codepath := jai_general_pkg.plot_codepath(27, p_codepath); /* 27  */
  ln_credit := null;
  ln_debit  := null;

  Fnd_File.put_line(Fnd_File.LOG, ' p_trading_to_trading_iso :' || p_trading_to_trading_iso );
   Fnd_File.put_line(Fnd_File.LOG, 'p_receipt_source_code:'||p_receipt_source_code );
  --bug 6030615 added inventory
  if p_receipt_source_code IN ('INTERNAL ORDER', 'INVENTORY')-- and  p_trading_to_trading_iso = 'N'
  then /* Bug#4171469 */

    p_codepath := jai_general_pkg.plot_codepath(28, p_codepath); /* 28  */
    Fnd_File.put_line(Fnd_File.LOG, 'p_intransit_type:'||p_intransit_type );
    Fnd_File.put_line(Fnd_File.LOG, 'p_fob_point:'||p_fob_point );
    if ( (p_intransit_type = 2) and  (p_fob_point = 2) ) then
      /* 2 extra accounting entries need to be passed */

      p_codepath := jai_general_pkg.plot_codepath(29, p_codepath); /* 29  */
      IF  p_all_taxes -
        ( p_tds_taxes + p_modvat_recovery_taxes +
          p_cvd_taxes + p_add_cvd_taxes /*5228046 Additional cvd Enhancement*/ +
          p_customs_taxes + p_cvd_edu_cess +p_cvd_sh_edu_cess  	 /*Bug 5989740 bduvarag*/
          + p_customs_edu_cess
          +p_customs_sh_edu_cess) <> 0
      THEN

        p_codepath := jai_general_pkg.plot_codepath(30, p_codepath); /* 30  */
        /* Accounting Entry # 5 : Debit InterOrg Receivable */

        ln_debit  :=  p_all_taxes -
                     ( p_tds_taxes + p_modvat_recovery_taxes + p_cvd_taxes + p_add_cvd_taxes /*5228046 Additional cvd Enhancement*/ + p_customs_taxes +
                       p_cvd_edu_cess + p_cvd_sh_edu_cess + 	 /*Bug 5989740 bduvarag*/
                       p_customs_edu_cess +
                       p_customs_sh_edu_cess);

        ln_credit  := null;
    Fnd_File.put_line(Fnd_File.LOG, 'ln_debit:'||ln_debit );
        Fnd_File.put_line(Fnd_File.LOG, 'Accounting for Inter Receibles Acc' );
        Fnd_File.put_line(Fnd_File.LOG, 'p_interorg_receivables_account:'||p_interorg_receivables_account );
/*Bug 5527885 Start*/

        ptr_jv(5).line_num           := 5;
        ptr_jv(5).acct_type          := lv_acct_type;
        ptr_jv(5).acct_nature        := lv_acct_nature;
        ptr_jv(5).source_name        := lv_source_name;
        ptr_jv(5).category_name      := lv_category_name;
        ptr_jv(5).ccid               := p_interorg_receivables_account;
        ptr_jv(5).entered_dr         := round(ln_debit, gn_currency_precision);
        ptr_jv(5).entered_cr         := round(ln_credit, gn_currency_precision);
        ptr_jv(5).currency_code      := jai_rcv_trx_processing_pkg.gv_func_curr;
        ptr_jv(5).accounting_date    := p_transaction_date;
        ptr_jv(5).reference_10       := lv_reference_10;
        ptr_jv(5).reference_23       := lv_reference_23;
        ptr_jv(5).reference_24       := lv_reference_24;
        ptr_jv(5).reference_25       := lv_reference_25;
        ptr_jv(5).reference_26       := lv_reference_26;
        ptr_jv(5).destination        := 'G';
        -- ptr_jv(5).reference_name     := ;
        ptr_jv(5).reference_id       := p_transaction_id;
        ptr_jv(5).non_rnd_entered_dr := ln_debit;
        ptr_jv(5).non_rnd_entered_cr := ln_credit;
        ptr_jv(5).account_name       := gv_iso_receivables;
        ptr_jv(5).summary_jv_flag    := 'N';

        /* Accounting Entry # 6 : Credit in-transit inventory */

        p_codepath := jai_general_pkg.plot_codepath(31, p_codepath); /* 31  */
        ln_credit  := ln_debit;
        ln_debit  :=  null;

    Fnd_File.put_line(Fnd_File.LOG, 'ln_credit:'||ln_credit );
        Fnd_File.put_line(Fnd_File.LOG, 'Accounting for p_intransit_inv_account Acc' );
        Fnd_File.put_line(Fnd_File.LOG, 'p_intransit_inv_account:'||p_interorg_receivables_account );

        ptr_jv(6).line_num           := 6;
        ptr_jv(6).acct_type          := lv_acct_type;
        ptr_jv(6).acct_nature        := lv_acct_nature;
        ptr_jv(6).source_name        := lv_source_name;
        ptr_jv(6).category_name      := lv_category_name;
        ptr_jv(6).ccid               := p_intransit_inv_account;
        ptr_jv(6).entered_dr         := round(ln_debit, gn_currency_precision);
        ptr_jv(6).entered_cr         := round(ln_credit, gn_currency_precision);
        ptr_jv(6).currency_code      := jai_rcv_trx_processing_pkg.gv_func_curr;
        ptr_jv(6).accounting_date    := p_transaction_date;
        ptr_jv(6).reference_10       := lv_reference_10;
        ptr_jv(6).reference_23       := lv_reference_23;
        ptr_jv(6).reference_24       := lv_reference_24;
        ptr_jv(6).reference_25       := lv_reference_25;
        ptr_jv(6).reference_26       := lv_reference_26;
        ptr_jv(6).destination        := 'G';
        -- ptr_jv(6).reference_name     := ;
        ptr_jv(6).reference_id       := p_transaction_id;
        ptr_jv(6).non_rnd_entered_dr := ln_debit;
        ptr_jv(6).non_rnd_entered_cr := ln_credit;
        ptr_jv(6).account_name       := gv_iso_intransit_inv;
        ptr_jv(6).summary_jv_flag    := 'N';
/*Bug 5527885 End*/

      end if; /* all - tds - mr - cvd - customs */

    end if; /* is  (p_intransit_type = 2) and  (p_fob_point = 2) */

  end if; /* p_receipt_source_code = 'INTERNAL ORDER'  */


  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(32, p_codepath, null, 'END'); /* 32  */

  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  Code Path :' || p_codepath );
    Fnd_File.put_line(Fnd_File.LOG, '  ** End of procedure jai_rcv_rcv_rtv_pkg.post_entries **  ');
  end if;

  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.post_entries:' || sqlerrm;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path:' || p_codepath );
    return;

end post_entries;

/****************************** End post_entries ******************************/


/****************************** Start regime_tax_accounting_interim ******************************/
  procedure regime_tax_accounting_interim
  (
    p_transaction_id                            in                number,
    p_shipment_line_id                          in                number,
    p_organization_id                           in                number,
    p_location_id                               in                number,
    p_transaction_type                          in                varchar2,
    p_currency_conversion_rate                  in                number,
    p_parent_transaction_type                   in                varchar2,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category                        in                varchar2,
    p_receipt_source_code                       in                varchar2,
    p_transaction_date                          in                date,
    p_receipt_num                               in                varchar2,
    p_regime_code                               in                varchar2,
    ptr_jv                                      in OUT NOCOPY JOURNAL_LINES,  /* 5527885 */
    p_simulation                                in                varchar2,
    p_debug                                     in                varchar2,  -- default 'N', File.Sql.35
    p_process_flag                              out     nocopy    varchar2,
    p_process_message                           out     nocopy    varchar2,
    p_codepath                                  in out  nocopy    varchar2
  )
  is

  ln_credit                     number;
  ln_debit                      number;
  /* File.Sql.35 by Brathod */
  lv_source_name                varchar2(20); -- := 'Purchasing India'; -- Harshita . modified the size from 15 to 20 for Bug 4762433
  lv_category_name              varchar2(15); -- := 'Receiving India';
  lv_acct_nature                varchar2(15); -- := 'Receiving';
  lv_acct_type                  varchar2(15);  /* Regular or Reversal*/

  lv_reference_10               varchar2(240);
  lv_reference_23               varchar2(240);-- := 'jai_rcv_rcv_rtv_pkg.regime_tax_accounting_interim';
  lv_reference_24               varchar2(240);-- := 'rcv_transactions';
  lv_reference_25               varchar2(240);-- :=  'transaction_id';
  /* End of File.Sql.35 by Brathod */

  lv_reference_26               varchar2(240);
  ln_tax_apportion_factor       number;
  ln_regime_recovery_interim   number;

  cursor c_jai_regimes (p_regime_code varchar2)is
    select regime_id
    from   JAI_RGM_DEFINITIONS
    where  regime_code = p_regime_code;

--added tax_type in cursor definition for bug # 6807023
  cursor c_ja_in_tax_amt_by_account
  (
    cp_shipment_line_id             number,
    cp_regime_id                    number,
    cp_organization_type            varchar2,
    cp_organization_id              number,
    cp_location_id                  number,
    cp_account_name                 varchar2,
    cp_func_curr                    varchar2,
    cp_tax_apportion_factor         number,
    cp_currency_conversion_rate     number
  ) is
    select  jai_cmn_rgm_recording_pkg.get_account
            (
               cp_regime_id,
               cp_organization_type,
               cp_organization_id,
               cp_location_id, /* Location Not for service tax */
               jrtl.tax_type,
               cp_account_name
            )  interim_regime_account,
            sum
            (
             ROUND( --rchandan for bug#6971526
              decode
              (
                nvl(jrtl.currency , cp_func_curr), cp_func_curr,
                nvl(jrtl.tax_amount,0)* cp_tax_apportion_factor,
                nvl(jrtl.tax_amount,0)* cp_tax_apportion_factor * cp_currency_conversion_rate
               ) * --rchandan for bug#6971526 start
							 (decode(jtc.mod_cr_percentage,100,1,jtc.mod_cr_percentage/100)
							 )
							 , NVL(jtc.rounding_factor, 0)
 	             )--rchandan for bug#6971526 end
              ) tax_amount_by_account
    from    JAI_RCV_LINE_TAXES jrtl,
            JAI_CMN_TAXES_ALL jtc
    where   jrtl.shipment_line_id = cp_shipment_line_id
    and     jrtl.tax_id = jtc.tax_id
    and     ( nvl(jtc.mod_cr_percentage,0) between 0 and 100 ) --rchandan for bug#6971526
    and     nvl(jrtl.modvat_flag, 'N') = 'Y'
    and     jrtl.tax_type in
            (
             select jrr.attribute_code
             from   JAI_RGM_DEFINITIONS jr,
                    JAI_RGM_REGISTRATIONS jrr
             where  jr.regime_id = jrr.regime_id
             and    jr.regime_code = p_regime_code
             and    jrr.registration_type = jai_constants.regn_type_tax_types
            )
      AND   NVL(jtc.inclusive_tax_flag,'N')='N' --add by eric for inclusive tax,picking the exclusive tax only
    group by  jai_cmn_rgm_recording_pkg.get_account
            (
               cp_regime_id,
               cp_organization_type,
               cp_organization_id,
               cp_location_id, /* Location Not for service tax */
               jrtl.tax_type,
               cp_account_name
            ) ;

  /*commented this cursor for bug#6030615,as part of performance issue check
  cursor c_org_organization_definitions(cp_organization_id  number) is
    select operating_unit
    from   org_organization_definitions
    where  organization_id = cp_organization_id;*/
    --added the below cursor for bug#6030615
    CURSOR c_get_ou (cp_organization_id  number)is
    SELECT org_information3 FROM HR_ORGANIZATION_INFORMATION
    WHERE organization_id=cp_organization_id
    AND ORG_INFORMATION_CONTEXT='Accounting Information';

  r_org_organization_definitions    c_get_ou%rowtype;
  r_jai_regimes                     c_jai_regimes%rowtype;
  lv_organization_type              varchar2(2);
  ln_organization_id                number;
  ln_location_id                    number;
  l_jv_line_num_generator           number; /*Bug 5527885*/
begin

  /* File.Sql.35 by Brathod */
  lv_source_name                := 'Purchasing India';
  lv_category_name              := 'Receiving India';
  lv_acct_nature                := 'Receiving';
  lv_reference_23               := 'jai_rcv_rcv_rtv_pkg.regime_tax_accounting_interim';
  lv_reference_24               := 'rcv_transactions';
  lv_reference_25               :=  'transaction_id';
  /* End of File.Sql.35 by Brathod */


  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  **    Start of procedure jai_rcv_rcv_rtv_pkg.regime_tax_accounting_interim **');
  end if;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_rcv_rtv_pkg.regime_tax_accounting_interim', 'START'); /* 1  */
  /* Set varaiable values for accounting entries with GL link */
  if ( (p_transaction_type = 'RETURN TO VENDOR')
        or
       (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RETURN TO VENDOR')
      )
  then
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2  */
    lv_acct_type := 'REVERSAL';
  else
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3  */
    lv_acct_type := 'REGULAR';
  end if;

  p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4  */
  lv_reference_10 :=  p_regime_code||' Regime. India Local Receiving Entry for Receipt Number ' || p_receipt_num ||
                      ', for Transaction Type ' || p_transaction_type ;

  if p_transaction_type = 'CORRECT' then
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5  */
    lv_reference_10 := lv_reference_10 || ' of type ' || p_parent_transaction_type;
  end if;

  lv_reference_26 :=  to_char(p_transaction_id);

  ln_tax_apportion_factor := jai_rcv_trx_processing_pkg.get_apportion_factor(p_transaction_id);

  open  c_jai_regimes(p_regime_code);
  fetch c_jai_regimes into r_jai_regimes;
  close c_jai_regimes;

  if  p_regime_code = jai_constants.service_regime then

    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6  */
    Fnd_File.put_line(Fnd_File.LOG, 'In Service Regime ');
   lv_organization_type := jai_constants.orgn_type_io;
   ln_organization_id  := p_organization_id;
   ln_location_id := p_location_id;
   l_jv_line_num_generator := 61;  /*added for bug 7699476*/
   -- added by nprashar  for Bug 6807023
   Fnd_File.put_line(Fnd_File.LOG, 'In Service Regime lv_organization_type =' ||lv_organization_type||' ln_organization_id='||p_organization_id||'ln_location_id='||p_location_id);

  elsif p_regime_code = jai_constants.vat_regime then

      p_codepath := jai_general_pkg.plot_codepath(6.1, p_codepath); /* 6.1  */
      lv_organization_type := jai_constants.orgn_type_io;
      ln_organization_id  := p_organization_id;
      ln_location_id := p_location_id;
    l_jv_line_num_generator := 41;/*Bug 5527885*/
  end if;
  /* Loop through Taxes of Service/VAT Regime by interim service/vat account
     of tax type and  pass the accounting entries  */
  p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7  */

  for cur_rec in
    c_ja_in_tax_amt_by_account
      (
        p_shipment_line_id,
        r_jai_regimes.regime_id,
        lv_organization_type,
        ln_organization_id,
        ln_location_id,
        jai_constants.recovery_interim,
        jai_rcv_trx_processing_pkg.gv_func_curr,
        ln_tax_apportion_factor,
        p_currency_conversion_rate
      )
  loop
    ln_regime_recovery_interim := cur_rec.interim_regime_account;

    if ln_regime_recovery_interim is null then
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8  */
      p_process_flag    := 'E';
      p_process_message :=
      'RECEIVE_RTV_PKG.service_tax_accounting: Interim Service/vat tax recovery account not defined for some tax type';
      goto   exit_from_procedure;
    end if;

    if ( (p_transaction_type = 'RETURN TO VENDOR')
          or
         (p_transaction_type = 'CORRECT' and p_parent_transaction_type  = 'RETURN TO VENDOR')
        )
    then

       p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9  */
       ln_debit  := null;
       ln_credit := cur_rec.tax_amount_by_account;  /* Service/Vat */

    else

      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10  */
      ln_debit  := cur_rec.tax_amount_by_account;
      ln_credit := null;

    end if;

    p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11  */

    --if (ln_debit is not null or ln_credit is not null) then
    --commented the above and added the below by Ramananda for Bug#4514461
    if (NVL(ln_debit,0) <> 0 OR NVL(ln_credit,0) <> 0) then
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12  */
      /* procedure to populate gl inetrface, JAI_RCV_JOURNAL_ENTRIES and receiving subledger */
/*Bug 5527885 Start*/
/*
      if p_debug = 'Y' then
        Fnd_File.put_line(Fnd_File.LOG, ' Call to -> jai_rcv_accounting_pkg.process_transaction');
      end if;



      jai_rcv_accounting_pkg.process_transaction
      (
      p_transaction_id            =>    p_transaction_id,
      p_acct_type                 =>    lv_acct_type,
      p_acct_nature               =>    lv_acct_nature,
      p_source_name               =>    lv_source_name,
      p_category_name             =>    lv_category_name,
      p_code_combination_id       =>    ln_regime_recovery_interim,
      p_entered_dr                =>    ln_debit,
      p_entered_cr                =>    ln_credit,
      p_currency_code             =>    jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date           =>    p_transaction_date,
      p_reference_10              =>    lv_reference_10,
      p_reference_23              =>    lv_reference_23,
      p_reference_24              =>    lv_reference_24,
      p_reference_25              =>    lv_reference_25,
      p_reference_26              =>    lv_reference_26,
      p_destination               =>    'G',
      p_simulate_flag             =>    p_simulation,
      p_codepath                  =>    p_codepath,
      p_process_status            =>    p_process_flag,
      p_process_message           =>    P_process_message
      );
*/
      ptr_jv(l_jv_line_num_generator).line_num           := l_jv_line_num_generator;
      ptr_jv(l_jv_line_num_generator).acct_type          := lv_acct_type;
      ptr_jv(l_jv_line_num_generator).acct_nature        := lv_acct_nature;
      ptr_jv(l_jv_line_num_generator).source_name        := lv_source_name;
      ptr_jv(l_jv_line_num_generator).category_name      := lv_category_name;
      ptr_jv(l_jv_line_num_generator).ccid               := ln_regime_recovery_interim;
      ptr_jv(l_jv_line_num_generator).entered_dr         := round(ln_debit, gn_currency_precision);
      ptr_jv(l_jv_line_num_generator).entered_cr         := round(ln_credit, gn_currency_precision);
      ptr_jv(l_jv_line_num_generator).currency_code      := jai_rcv_trx_processing_pkg.gv_func_curr;
      ptr_jv(l_jv_line_num_generator).accounting_date    := p_transaction_date;
      ptr_jv(l_jv_line_num_generator).reference_10       := lv_reference_10;
      ptr_jv(l_jv_line_num_generator).reference_23       := lv_reference_23;
      ptr_jv(l_jv_line_num_generator).reference_24       := lv_reference_24;
      ptr_jv(l_jv_line_num_generator).reference_25       := lv_reference_25;
      ptr_jv(l_jv_line_num_generator).reference_26       := lv_reference_26;
      ptr_jv(l_jv_line_num_generator).destination        := 'G';
      -- ptr_jv(l_jv_line_num_generator).reference_name     := ;
      ptr_jv(l_jv_line_num_generator).reference_id       := p_transaction_id;
      ptr_jv(l_jv_line_num_generator).non_rnd_entered_dr := ln_debit;
      ptr_jv(l_jv_line_num_generator).non_rnd_entered_cr := ln_credit;
      ptr_jv(l_jv_line_num_generator).summary_jv_flag    := 'N';
      if p_regime_code = jai_constants.service_regime then
        ptr_jv(l_jv_line_num_generator).account_name := gv_service_interim;
      elsif p_regime_code = jai_constants.vat_regime then
        ptr_jv(l_jv_line_num_generator).account_name := gv_vat_interim;
      else
        ptr_jv(l_jv_line_num_generator).account_name := gv_regime_interim;
      end if;
      l_jv_line_num_generator := l_jv_line_num_generator + 1;
      /*Bug 5527885 End*/
    end if;


  end loop;


  << exit_from_procedure >>
  p_codepath := jai_general_pkg.plot_codepath(32, p_codepath, null, 'END'); /* 32  */

  if p_process_flag is null then
    p_process_flag    := 'Y';
  end if;

  if p_debug = 'Y' then
    Fnd_File.put_line(Fnd_File.LOG, '  Code Path :' || p_codepath );
    Fnd_File.put_line(Fnd_File.LOG, '  ** End of procedure jai_rcv_rcv_rtv_pkg.regime_tax_accounting_interim **  ');
  end if;

  return;

exception
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIVE_RTV_PKG.regime_tax_accounting_interim:' || sqlerrm;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');
    Fnd_File.put_line(Fnd_File.LOG, 'Code Path:' || p_codepath );
    return;

end regime_tax_accounting_interim;
/****************************** End service_tax_accounting ******************************/

end jai_rcv_rcv_rtv_pkg;

/
