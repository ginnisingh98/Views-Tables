--------------------------------------------------------
--  DDL for Package Body JAI_RCV_DELIVER_RTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_DELIVER_RTR_PKG" AS
/* $Header: jai_rcv_del_rtr.plb 120.6.12010000.5 2010/04/15 10:57:13 boboli ship $ */
/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_rcv_deliver_rtr_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     26/07/2004   Nagaraj.s for Bug# 3496408, Version:115.0
                    This Package is coded for Corrections Enhancement to pass Deliver and RTR Entries.

2     26/10/2004   Vijay Shankar for Bug#3949518 (3927371), Version:115.1
                    Modified the p_subinventory_code parameter passed to Average_Costing and Expense_Accounting procedure to use
                    DELIVER Subinventory incase RTR subinventory is NULL

3     10/11/2004   Vijay Shankar for Bug#4003518, Version:115.2
                    Modified the PROCESS_TRANSACTION definition to DEFAULT 'N' for p_simulate parameter. without this, its not a
                    problem in Oracle8i, however it is problem in 9i and thus the bugfix

4     12/12/2004   Vijay Shankar for Bug#4038034  (4038024),   FileVersion:115.3
                    Redundant piece of code checking related to tax_amount calculation in commented as these are already taken
                    care in INCLUDE_CENVAT_IN_COSTING function and this being used in the check. This redundant piece of code is
                    causing the issue specified in the bug

5     23/12/2004   Vijay Shankar for Bug#4071458,   FileVersion:115.4
                    Modified an IF condition, so that the procedure process_transaction will not error out if ln_total is 0. check
                    is modified to fail only if both ln_total and ln_non_modvat_amount are 0.

6     15/12/2004   Vijay Shankar for Bug#4068823, 3940588,   FileVersion:115.5
                   Following are the changes made for the purpose of Service Tax and Education Cess Enhancements
                   - Added two new parameters p_process_special_Reason and amount in process_transaction to implement the functionality
                   of Deferred Claim for RECEIPTS DEPLUG of existing code. If these parameters were passed with values related to
                   Cenvat Unclaim, then process_special_amount is taken as ln_total instead of calculating it from transaction
                   and proceed further to do either of Costing or Expensing

                   - Uncommented the call to OPM_COSTING to support OPM Receipts Functionality also
                   - INCLUDE_CENVAT_IN_COSTING is modified to include some more checks to return a value to caller
                   - Modfied the Main Cursor in DELIVER_RTR_RECO_NONEXCISE procedure not to pass INDIVIDUAL accounting for taxes
                   related to 'Service Tax India' and 'SERVICE_EDUCATION_CESS' tax types
                   - Modified the procedures expense_accounting, average_costing, standard_costing, opm_costing to include parameters
                   p_process_special_Reason in the signature. this is used to pass a different value for JAI_RCV_JOURNAL_ENTRIES.acct_nature,
                   for accounting_entries identification


7     23/02/2005   Vijay Shankar for Bug#4179823,   FileVersion:115.6
                   Modified an IF condition in include_cenvat_in_costing function to allow FGIN items in case of RMA Receipts.
                   Previously it is allowing for ISO receipts only incase of FGIN items which is wrong

8     17/03/2005   Vijay Shankar for Bug#4229164,   FileVersion:115.7
                   Modified the code in jai_rcv_deliver_rtr_pkg.opm_costing procedure to consider currency rate also which is passed as parameter to the  procedure.
                     - Added a new parameter p_currency_conversion_rate to jai_rcv_deliver_rtr_pkg.opm_costing procedure
                     - started passing the value to newly added parameter by fetching the value from JAI_RCV_TRANSACTIONS table

9     19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.8
                    modified the procedures to support the functinoality of "VAT UNCLAIM" in similar lines to "CENVAT UNCLAIM".
                    This would be called from jai_rcv_rgm_claims_pkg incase of VAT NOCLAIM selected by user for a receipt line incase
                    DELIVER/RTR or related CORRECTs happened

10  10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                 Code is modified due to the Impact of Receiving Transactions DFF Elimination

              * High Dependancy for future Versions of this object *

11 08-Jun-2005  Version 116.2 jai_rcv_del_rtr -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

12. 13-Jun-2005    File Version: 116.3
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

13. 7-Jul-2005     File Version: 116.4
                  rchandan for bug#4473022. Modified the object as part of SLA impact uptake.
		  While calling jai_rcv_accounting_pkg.process_transaction apropriate values are passed for
		  reference parameters instead of NULL.


14. 01/11/2006       SACSETHI for bug 5228046, File version 120.3
                 Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                 This bug has datamodel and spec changes.

15.	27/Apr/2007		CSahoo for bug#5989740, File Version 120.4
									Forward Porting of 11i bug#5907436
									handling secondary and higher education cess
									added the sh cess types.

16.  20-Nov-2008   Bug 7581494 : Porting Bug 6905807 from 120.2.12000000.5 to 12.1 Branch
                                 Bug 6681800 not yet ported to 12.1

17. 18-JAN-2010  JMEENA for bug#9233826
				In the procedure get_tax_amount_breakup modified the calculation of ln_non_modvat_amount for inclusive tax.

DEPENDANCY:
-----------
IN60105D2 + 3496408
IN60106   + 4239736 + 4245089 + 4346453

16.  28-NOV-2007    Added by Jia Li for India tax inclusive
17.  19-Mar-2008    Modified by Jia Li for Bug#6877290
                 Issue: UNIT COST CALCULATE IS INCORRECT IN AVG ORGANIZATION
                 Fixed: Modified procedure get_tax_amount_breakup,
                       change modvat_amount and non_modvat_amount calculate position,
                       moved tax_amount calculate into inclusive_flag clause

18.  06-04-2009   FP 12.0: 7539200:RECEIVING AND DELIVERY ACC VISIBLE FROM LOCALISATION SCREEN
				  Fix details: Commented the code which inserts accounting
				  entries in jai_rcv_journal_entries for OPM costing

19.  15-Apr_2010  Bo Li  For bug9305067 Replace the old attribute_category columns for JAI_RCV_TRANSACTIONS
                                        with new meaningful one
----------------------------------------------------------------------------------------------------------------------------*/

  PROCEDURE process_transaction
  (
      p_transaction_id                IN            NUMBER,
      p_simulate                      IN            VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N',
      p_codepath                      IN OUT NOCOPY VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      -- Vijay Shankar for Bug#4068823. RECEIPTS DELUG
      p_process_special_source        IN            VARCHAR2  DEFAULT NULL,
      p_process_special_amount        IN            NUMBER    DEFAULT NULL
  ) is

    /* Cursor Definitions */
    CURSOR c_trx(cp_transaction_id IN NUMBER) IS
    SELECT *
    FROM JAI_RCV_TRANSACTIONS
    WHERE transaction_id = cp_transaction_id;

    CURSOR c_base_line_dtls(cp_transaction_id IN NUMBER) IS
    SELECT quantity, unit_of_measure, source_doc_unit_of_measure, source_doc_quantity
    from   rcv_transactions
    where  transaction_id = cp_transaction_id;

    CURSOR c_rcv_trx(cp_transaction_id IN NUMBER) IS
    SELECT *
    FROM   rcv_transactions
    where  transaction_id = cp_transaction_id;

    CURSOR c_mtl_trx(cp_organization_id IN NUMBER) IS
    /* Bug 4941701. Added by Lakshmi Gopalsami
       For performance fix. SQL id - 14829562
       Changed the reference mtl_parameters from mtl_parameters_view
       and selected process_enabled_flag in the cursor.  */
    SELECT process_enabled_flag
    FROM   mtl_parameters
    WHERE  Organization_id =  cp_organization_id;

    /* Record Declarations */
    r_trx                     c_trx%rowtype;
    r_base_line_dtls          c_base_line_dtls%rowtype;
    r_rcv_trx                 c_rcv_trx%rowtype;
    r_rcv_dlry_trx            c_rcv_trx%rowtype;      -- Bug#3949518 (3927371)
    r_mtl_trx                 c_mtl_trx%rowtype;
    r_dlry_trx                c_trx%rowtype;


    /* Variable Declarations */
    lv_procedure_name             VARCHAR2(60); --File.Sql.35 Cbabu  := 'jai_rcv_deliver_rtr_pkg.process_transaction';
    -- lv_register_type              VARCHAR2(1); --Either A or C.
    lv_opm_organization_flag      mtl_parameters_view.process_enabled_flag%type;
    lv_statement_id               VARCHAR2(4);
    lv_debug                      VARCHAR2(1); --File.Sql.35 Cbabu  := 'Y';
    lv_accounting_type            VARCHAR2(30);
    lv_include_cenvat_in_costing  VARCHAR2(1);
    lv_destination_type           rcv_transactions.destination_type_code%type;


    /* Number Declarations */
    ln_apportion_factor         NUMBER; --File.Sql.35 Cbabu   := 1;   -- default value added by Vijay Shankar for Bug#4068823 for RECEIPTS DEPLUG
    ln_modvat_amount            NUMBER; --File.Sql.35 Cbabu   := 0;
    ln_non_modvat_amount        NUMBER; --File.Sql.35 Cbabu   := 0;
    ln_other_modvat_amount      NUMBER; --File.Sql.35 Cbabu   := 0;
    ln_total                    NUMBER; --File.Sql.35 Cbabu   := 0;
    ln_opm_total                NUMBER; --File.Sql.35 Cbabu   := 0;
    ln_receiving_account_id     rcv_parameters.receiving_account_id%type;
    ln_dlry_trx_id              JAI_RCV_TRANSACTIONS.transaction_id%type;

    ln_receive_trx_id           JAI_RCV_TRANSACTIONS.transaction_id%type;
    lv_temp                     VARCHAR2(50);

    lv_cenvat_costed_flag       VARCHAR2(15);

  BEGIN
    lv_procedure_name             := 'jai_rcv_deliver_rtr_pkg.process_transaction';
    lv_debug                      := jai_constants.yes;
    ln_apportion_factor         := 1;   -- default value added by Vijay Shankar for Bug#4068823 for RECEIPTS DEPLUG
    ln_modvat_amount            := 0;
    ln_non_modvat_amount        := 0;
    ln_other_modvat_amount      := 0;
    ln_total                    := 0;
    ln_opm_total                := 0;

    -- this is to identify the path in SQL TRACE file if any problem occured
    SELECT 'jai_rcv_deliver_rtr_pkg-'||p_transaction_id INTO lv_temp FROM DUAL;

    FND_FILE.put_line( FND_FILE.log, '~~~~~~ Start of jai_rcv_deliver_rtr_pkg.process_transaction. Time:'||to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.process_transaction', 'START'); /* 1 */

    /* Fetch all the information from JAI_RCV_TRANSACTIONS */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_statement_id := '1';
    ln_receive_trx_id := r_trx.tax_transaction_id;

    /* Vijay Shankar for Bug#4068823
    jai_rcv_trx_processing_pkg.get_ancestor_id
                         (
                             p_transaction_id     => r_trx.transaction_id,
                             p_shipment_line_id   => r_trx.shipment_line_id,
                             p_required_trx_type  => 'RECEIVE'
                         );
    */

    /* Fetch all the information from rcv_transactions for transaction type RECEIVE*/
    OPEN   c_base_line_dtls(ln_receive_trx_id);
    FETCH  c_base_line_dtls INTO r_base_line_dtls;
    CLOSE  c_base_line_dtls;

    lv_statement_id := '2';
    if r_base_line_dtls.quantity = 0 THEN
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      p_process_status     := 'E';
      p_process_message    := 'The Quantity in rcv_transactions for RECEIVE line is Zero';
      goto exit_from_procedure;
    end if;

    --p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    --lv_statement_id := '2.1';

    /* Fetch the information of certain columns which are not present in JAI_RCV_TRANSACTIONS */
    OPEN     c_rcv_trx(p_transaction_id);
    FETCH    c_rcv_trx into r_rcv_trx;
    CLOSE    c_rcv_trx;

    lv_statement_id := '3';
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */

    /* Fetch the Receiving Account Id */
    ln_receiving_account_id := receiving_account
                                (
                                  p_organization_id      =>        r_trx.organization_id,
                                  p_process_message      =>        p_process_message,
                                  p_process_status       =>        p_process_status,
                                  p_codepath             =>        p_codepath
                                );

    if p_process_status in ('E', 'X')  THEN
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      goto exit_from_procedure;
    end if;

    lv_statement_id := '4';

    if (r_trx.transaction_type ='CORRECT' and r_trx.parent_transaction_type = 'DELIVER')
        or r_trx.transaction_type = 'DELIVER'
    then
      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
      lv_accounting_type := 'REGULAR';
    elsif (r_trx.transaction_type ='CORRECT' and r_trx.parent_transaction_type = 'RETURN TO RECEIVING')
            or r_trx.transaction_type = 'RETURN TO RECEIVING'
    then
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
      lv_accounting_type  := 'REVERSAL';
    end if;

    /* following condition added by Vijay Shankar for Bug#4068823. RECEIPTS DEPLUG
      vat_noclaim added by Vijay Shankar for Bug#4250236(4245089). VAT Impl.
    */
    if nvl(p_process_special_source, 'XX') NOT IN ( jai_constants.cenvat_noclaim, jai_constants.vat_noclaim) then

        -- following gets executed only for NORMAL DELIVER and RTR transactions and not for UNCLAIM Processing till <<start_of_actual_processing>>
        lv_statement_id := '5';
        p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */

        /* Apportion Factor */
        ln_apportion_factor  := jai_rcv_trx_processing_pkg.get_apportion_factor
                                    (p_transaction_id => r_trx.transaction_id);

        if lv_debug ='Y' then
          fnd_file.put_line( fnd_file.log, '1.1  ln_apportion_factor ' || ln_apportion_factor );
        end if;

        /*Step 1 : Call Individual Tax Entries As this should happen in any case if
           Recoverable Taxes other than Excise Exist */
        deliver_rtr_reco_nonexcise
        (
           p_transaction_id                   =>    r_trx.transaction_id,
           p_transaction_date                 =>    r_trx.transaction_date,
           p_organization_id                  =>    r_trx.organization_id,
           p_transaction_type                 =>    r_trx.transaction_type,
           p_parent_transaction_type          =>    r_trx.parent_transaction_type,
           p_receipt_num                      =>    r_trx.receipt_num,
           p_shipment_line_id                 =>    r_trx.shipment_line_id,
           p_currency_conversion_rate         =>    r_trx.currency_conversion_rate,
           p_apportion_factor                 =>    ln_apportion_factor,
           p_receiving_account_id             =>    ln_receiving_account_id,
           p_accounting_type                  =>    lv_accounting_type,
           p_simulate                         =>    p_simulate,
           p_process_message                  =>    p_process_message,
           p_process_status                   =>    p_process_status,
           p_codepath                         =>    p_codepath
        );

        p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
        if p_process_status IN ('E', 'X')  THEN
          p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
          goto exit_from_procedure;
        end if;

        /* Get Register Type */
        -- lv_register_type := jai_general_pkg.get_rg_register_type(p_item_class => r_trx.item_class);

        p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
        get_tax_amount_breakup
        (
            p_shipment_line_id             =>    r_trx.shipment_line_id,
            p_transaction_id               =>    r_trx.transaction_id,
            p_curr_conv_rate               =>    r_trx.currency_conversion_rate,
            p_excise_amount                =>    ln_modvat_amount,
            p_non_modvat_amount            =>    ln_non_modvat_amount  ,
            p_other_modvat_amount          =>    ln_other_modvat_amount ,
            p_process_message              =>    p_process_message,
            p_process_status               =>    p_process_status,
            p_codepath                     =>    p_codepath
        );

        p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
        if p_process_status in ('E', 'X')  THEN
          p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
          goto exit_from_procedure;
        end if;

        lv_include_cenvat_in_costing :=   include_cenvat_in_costing
                                          (
                                            p_transaction_id    => p_transaction_id,
                                            p_process_message   => p_process_message,
                                            p_process_status    => p_process_status,
                                            p_codepath          => p_codepath
                                          );

        p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
        if p_process_status in ('E', 'X')  THEN
          p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
          goto exit_from_procedure;
        end if;

        /* Logic to arrive at the Total for which Costing or Expense Accounting has to be done */
        if lv_include_cenvat_in_costing ='Y' then
          p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
          ln_total := nvl(ln_non_modvat_amount,0) + nvl(ln_modvat_amount,0);
        else
          p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */
          ln_total := nvl(ln_non_modvat_amount,0);
        end if;

    end if;   -- end of p_process_special_source not in ( jai_constants.cenvat_noclaim ...

    /* following condition added by Vijay Shankar for Bug#4068823. RECEIPTS DEPLUG
      vat_noclaim added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    IF p_process_special_source IN ( jai_constants.cenvat_noclaim, jai_constants.vat_noclaim) THEN
      ln_total    := p_process_special_amount;
      p_codepath  := jai_general_pkg.plot_codepath(18.1, p_codepath);
    ELSE
      ln_total := nvl(ln_total,0); --In case the Total is Null.
      p_codepath := jai_general_pkg.plot_codepath(19, p_codepath); /* 19 */
    END IF;

    if lv_debug='Y' THEN
      fnd_file.put_line( fnd_file.log, ' 1.3 ln_modvat_amount ='||  ln_modvat_amount
        ||', ln_non_modvat_amount ='  ||  ln_non_modvat_amount
        ||', ln_other_modvat_amount ='||  ln_other_modvat_amount
        ||', ln_total ='||  ln_total);
    end if;

    if ln_total = 0 then
      p_codepath := jai_general_pkg.plot_codepath(20, p_codepath); /* 20 */
      -- Vijay Shankar for Bug#4071458
      -- following if condition added to return successfully so that Individual Accounting happens without Costing/Expense Accounting
      if ln_other_modvat_amount <> 0 then
        p_process_status    := 'Y';
      else

        p_process_status    := 'X';
        p_process_message   := 'Non cenvatable/recoverable taxes doesnot exist. As a result, no Accounting/Costing';
      end if;

      goto exit_from_procedure;
    else
       /*Proportionate the Total with the Quantity of this transaction */
       p_codepath := jai_general_pkg.plot_codepath(21, p_codepath); /* 21 */
       ln_opm_total  := ln_total; /*This Total is required as in OPM Organization, costing would be based on source doc quantity */
       ln_total      := ln_total * ln_apportion_factor; /*This Amount would be the one which would be used for costing */
    end if;

    /* Logic to arrive at the Total for which Costing or Expense Accounting Ends here */
    p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); /* 22 */
    open  c_mtl_trx(r_trx.organization_id);
    fetch c_mtl_trx into r_mtl_trx;
    close c_mtl_trx;

    /* Following Hierarchy is followed for Deciding on what has to happen
      1. Expense Routing
      2. OPM Costing
      3. Average Costing
      4. Standard Costing.
    */

    if -- (r_trx.transaction_type  ='CORRECT' AND r_trx.parent_transaction_type = 'DELIVER') or  Vijay Shankar for Bug#4038034
        r_trx.transaction_type  = 'DELIVER'
    then

        lv_destination_type := r_trx.destination_type_code;

    elsif  -- 'DELIVER' in the following if elsif condition is added by Vijay Shankar for Bug#4038034
          (r_trx.transaction_type  ='CORRECT' AND r_trx.parent_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')) or
           r_trx.transaction_type  = 'RETURN TO RECEIVING'
    then

      ln_dlry_trx_id := jai_rcv_trx_processing_pkg.get_ancestor_id
                          (
                            r_trx.transaction_id,
                            r_trx.shipment_line_id,
                            'DELIVER'
                          );

      open  c_trx(ln_dlry_trx_id);
      fetch c_trx into r_dlry_trx;
      close c_trx;

      lv_destination_type := r_dlry_trx.destination_type_code;

      OPEN     c_rcv_trx(ln_dlry_trx_id);
      FETCH    c_rcv_trx into r_rcv_dlry_trx;
      CLOSE    c_rcv_trx;

    end if;

    if    lv_destination_type             ='EXPENSE'
          or r_trx.inv_asset_flag         ='N'
          or r_trx.inv_item_flag          ='N'
          or r_trx.base_asset_inventory = 2
    then

      p_codepath := jai_general_pkg.plot_codepath(23, p_codepath); /* 23 */

      expense_accounting
      (
        p_transaction_id            =>        r_trx.transaction_id,
        p_transaction_date          =>        r_trx.transaction_date,
        p_organization_id           =>        r_trx.organization_id,
        p_transaction_type          =>        r_trx.transaction_type,
        p_parent_transaction_type   =>        r_trx.parent_transaction_type,
        p_receipt_num               =>        r_trx.receipt_num,
        p_shipment_line_id          =>        r_trx.shipment_line_id,
        p_subinventory_code         =>        nvl(r_rcv_trx.subinventory, r_rcv_dlry_trx.subinventory),   -- Bug#3949518 (3927371)
        p_accounted_amount          =>        ln_total,
        p_receiving_account_id      =>        ln_receiving_account_id,
        p_source_document_code      =>        r_rcv_trx.source_document_code,
        p_po_distribution_id        =>        r_rcv_trx.po_distribution_id,
        p_po_line_location_id       =>        r_rcv_trx.po_line_location_id,
        p_inventory_item_id         =>        r_trx.inventory_item_id,
        p_accounting_type           =>        lv_accounting_type,
        p_simulate                  =>        p_simulate,
        p_process_message           =>        p_process_message,
        p_process_status            =>        p_process_status,
        p_codepath                  =>        p_codepath,
        p_process_special_source    =>        p_process_special_source
      );

      p_codepath := jai_general_pkg.plot_codepath(24, p_codepath); /* 24 */

      if p_process_status in ('E', 'X')  THEN
        p_codepath := jai_general_pkg.plot_codepath(25, p_codepath); /* 25 */
        goto exit_from_procedure;
      end if;

    elsif nvl(r_mtl_trx.process_enabled_flag,'N') ='Y'  then /* OPM Costing Route */

      /* In case of OPM Organizations, No Costing Impact is present in case of RTR Transactions */


      if (r_trx.transaction_type  ='CORRECT' AND r_trx.parent_transaction_type ='RETURN TO RECEIVING')
          or r_trx.transaction_type  ='RETURN TO RECEIVING'
      then
        p_codepath := jai_general_pkg.plot_codepath(26, p_codepath); -- 26
        goto exit_from_procedure;
      end if;

      --commented as opm is not taken part of this enhancement.
      -- Call to the following procedure is openedup by Vijay Shankar for Bug#4068823 for RECEIPT DEPLUG
      opm_costing (
          p_transaction_id               =>   r_trx.transaction_id,
          p_transaction_date             =>   r_trx.transaction_date,
          p_organization_id              =>   r_trx.organization_id,
          p_costing_amount               =>   ln_opm_total,   --To be checked   /* INR Total */
          p_receiving_account_id         =>   ln_receiving_account_id,
          p_rcv_unit_of_measure          =>   r_base_line_dtls.unit_of_measure,  --Indicates UOM of RECEIVE Line
          p_rcv_source_unit_of_measure   =>   r_base_line_dtls.source_doc_unit_of_measure, --Indicates Source UOM of RECEIVE Line
          p_rcv_quantity                 =>   r_base_line_dtls.quantity,    -- Indicates Quantity of RECEIVE Line
          p_source_doc_quantity          =>   r_base_line_dtls.source_doc_quantity, -- Indicates Source doc Quantity of RECEIVE Line
          p_source_document_code         =>   r_rcv_trx.source_document_code,
          p_po_distribution_id           =>   r_rcv_trx.po_distribution_id,
          p_subinventory_code            =>   nvl(r_rcv_trx.subinventory, r_rcv_dlry_trx.subinventory),   -- Bug#3949518 (3927371)
          p_simulate                     =>   p_simulate,
          p_process_message              =>   p_process_message,
          p_process_status               =>   p_process_status,
          p_codepath                     =>   p_codepath,
          p_process_special_source       =>   p_process_special_source,
          /* following parameter added by Vijay Shankar for Bug#4229164 */
          p_currency_conversion_rate     =>   nvl(r_trx.currency_conversion_rate, 1)
      );

      if p_process_status in ('E', 'X')  THEN
        goto exit_from_procedure;
      end if;

    elsif r_trx.costing_method = 2 then

      p_codepath := jai_general_pkg.plot_codepath(27, p_codepath); /* 27 */
      average_costing
      (
        p_transaction_id                => r_trx.transaction_id,
        p_transaction_date              => r_trx.transaction_date,
        p_organization_id               => r_trx.organization_id,
        p_parent_transaction_type       => r_trx.parent_transaction_type,
        p_transaction_type              => r_trx.transaction_type,
        p_subinventory_code             => nvl(r_rcv_trx.subinventory, r_rcv_dlry_trx.subinventory),   -- Bug#3949518 (3927371)
        p_costing_amount                => ln_total,
        p_receiving_account_id          => ln_receiving_account_id,
        p_source_document_code          => r_rcv_trx.source_document_code,
        p_po_distribution_id            => r_rcv_trx.po_distribution_id,
        p_unit_of_measure               => r_rcv_trx.unit_of_measure,
        p_inventory_item_id             => r_trx.inventory_item_id,
        p_accounting_type               => lv_accounting_type,
        p_simulate                      => p_simulate,
        p_process_message               => p_process_message,
        p_process_status                => p_process_status,
        p_codepath                      => p_codepath,
        p_process_special_source        => p_process_special_source
      );

      p_codepath := jai_general_pkg.plot_codepath(28, p_codepath); /* 28 */
      if p_process_status in ('E', 'X')  THEN
        p_codepath := jai_general_pkg.plot_codepath(29, p_codepath); /* 29 */
        goto exit_from_procedure;
      end if;


    elsif r_trx.costing_method = 1 then

      p_codepath := jai_general_pkg.plot_codepath(30, p_codepath); /* 30 */

      standard_costing
      (
        p_transaction_id            =>    r_trx.transaction_id,
        p_transaction_date          =>    r_trx.transaction_date,
        p_organization_id           =>    r_trx.organization_id,
        p_parent_transaction_type   =>    r_trx.parent_transaction_type,
        p_transaction_type          =>    r_trx.transaction_type,
        p_costing_amount            =>    ln_total,
        p_receiving_account_id      =>    ln_receiving_account_id,
        p_accounting_type           =>    lv_accounting_type,
        p_simulate                  =>    p_simulate,
        p_process_message           =>    p_process_message,
        p_process_status            =>    p_process_status,
        p_codepath                  =>    p_codepath,
        p_process_special_source    => p_process_special_source
      );

      p_codepath := jai_general_pkg.plot_codepath(31, p_codepath); /* 31 */
      if p_process_status in ('E', 'X')  THEN
        p_codepath := jai_general_pkg.plot_codepath(32, p_codepath); /* 32 */
        goto exit_from_procedure;
      end if;

    end if; --r_mtl_trx.process_enabled_flag

    /* following was coded to support UNCLAIM functionality during RECEIPTS DEPLUG. Vijay Shankar for Bug#4068823
      vat_noclaim added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    IF    lv_include_cenvat_in_costing = 'Y'
      or  p_process_special_source IN ( jai_constants.cenvat_noclaim, jai_constants.vat_noclaim)
    THEN
      p_codepath := jai_general_pkg.plot_codepath(33, p_codepath);
      lv_cenvat_costed_flag := jai_constants.yes;
    ELSE
      p_codepath := jai_general_pkg.plot_codepath(34, p_codepath);
      lv_cenvat_costed_flag := jai_constants.no;
    END IF;

    IF    r_trx.cenvat_costed_flag IS NULL --Modified by Bo Li for replacing the attribute2 with cenvat_costed_flag
      OR (/*r_trx.attribute1 = jai_rcv_deliver_rtr_pkg.cenvat_costed_flag
          AND*/nvl(r_trx.cenvat_costed_flag,jai_constants.no) <> jai_constants.yes)--Modified by Bo Li for replacing the attribute2 with cenvat_costed_flg
    THEN

      p_codepath := jai_general_pkg.plot_codepath(35, p_codepath);

      --Modified by Bo Li for replacing the update_attributes with update_cenvat_costed_flag Begin
      --------------------------------------------------------------------------------------------
      /*jai_rcv_transactions_pkg.update_attributes(
        p_transaction_id        => p_transaction_id,
        p_attribute1            => jai_rcv_deliver_rtr_pkg.cenvat_costed_flag,
        p_attribute2            => lv_cenvat_costed_flag
      );*/

       jai_rcv_transactions_pkg.update_cenvat_costed_flag(
        p_transaction_id        => p_transaction_id,
        p_cenvat_costed_flag     => lv_cenvat_costed_flag
      );
      --------------------------------------------------------------------------------------------
      --Modified by Bo Li for replacing the update_attributes with update_cenvat_costed_flag End
    END IF;

    -- Process is Successful. Now the PROCESS_FLAG can be set to 'Y'
    p_process_status := 'Y';

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(40, p_codepath, null, 'END'); /* 33 */
    return;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status    := 'E';
      p_process_message   := 'DELIVER_RTR_PKG.process_transaction:' || sqlerrm;
      fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 34 */
      return;
  END process_transaction;

  /* ------------------------------------------------start of deliver_rtr_reco_nonexcise------------*/
  PROCEDURE deliver_rtr_reco_nonexcise
  (
      p_transaction_id               IN             NUMBER,
      p_transaction_date             IN             DATE,
      p_organization_id              IN             NUMBER,
      p_transaction_type             IN             VARCHAR2,
      p_parent_transaction_type      IN             VARCHAR2,
      p_receipt_num                  IN             VARCHAR2,
      p_shipment_line_id             IN             NUMBER,
      p_currency_conversion_rate     IN             NUMBER,
      p_apportion_factor             IN             NUMBER,
      p_receiving_account_id         IN             NUMBER,
      p_accounting_type              IN             VARCHAR2,
      p_simulate                     IN             VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                     IN OUT NOCOPY VARCHAR2
  ) is

    /*
    Accounting Entries which happen in this scenario are
   |------------------------------------------------------------------------------------------------
   | Transaction   |                       |                           |                           |
   |  Type         |        Amount         | Credit                    |   Debit                   |
   | ==============|====================== |===========================|===========================|
   | DELIVER       |          Total        |   Inv.Receiving           |                           |
   | DELIVER       |    Individual Tax Amt |                           |   Individual Tax Accounts |
   | RTR           |          Total        |                           |   Inv.Receiving           |
   | RTR           |    Individual Tax Amt |   Individual Tax Accounts |                           |
   | ============= | ======================|===========================|===========================|
    ----------------------------------------------------------------------------------------------
    */

    /* Character Variable Declarations */
    lv_reference_10_desc1         VARCHAR2(75);--File.Sql.35 Cbabu   := 'India Local Receiving Entry for the Receipt Number ';
    lv_reference_10_desc2         VARCHAR2(30);--File.Sql.35 Cbabu   := ' For the Transaction Type ';
    lv_reference_10_desc          gl_interface.reference10%type;
    lv_account_nature             VARCHAR2(30);--File.Sql.35 Cbabu   := 'Individual Tax';
    lv_reference23                gl_interface.reference23%type;--File.Sql.35 Cbabu   := 'jai_rcv_deliver_rtr_pkg.deliver_rtr_reco_nonexcise';
    lv_source                     VARCHAR2(100);--File.Sql.35 Cbabu          := 'Purchasing India';
    lv_category                   VARCHAR2(100);--File.Sql.35 Cbabu          := 'Receiving India';
    lv_reference24                gl_interface.reference24%type;--File.Sql.35 Cbabu   := 'rcv_transactions';
    lv_reference25                gl_interface.reference25%type;--File.Sql.35 Cbabu   := 'transaction_id';

    ln_individual_tax_amount         number;--File.Sql.35 Cbabu  := 0;
    ln_rec_account_tax_amount        number;--File.Sql.35 Cbabu   := 0;
    ln_credit_amount                 number;
    ln_debit_amount                  number;

  BEGIN
    --File.Sql.35 Cbabu
    lv_account_nature             := 'Individual Tax';
    lv_reference_10_desc1         := 'India Local Receiving Entry for the Receipt Number ';
    lv_reference_10_desc2         := ' For the Transaction Type ';
    lv_reference23                := 'jai_rcv_deliver_rtr_pkg.deliver_rtr_reco_nonexcise';
    lv_source                     := 'Purchasing India';
    lv_category                   := 'Receiving India';
    lv_reference24                := 'rcv_transactions';
    lv_reference25                := 'transaction_id';
    ln_individual_tax_amount      := 0;
    ln_rec_account_tax_amount     := 0;

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.deliver_rtr_reco_nonexcise', 'START'); /* 1 */

    if p_transaction_type = 'CORRECT' then
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      lv_reference_10_desc := lv_reference_10_desc1 || p_receipt_num ||lv_reference_10_desc2 ||p_transaction_type ||' of Type ' || p_parent_transaction_type;
    else
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      lv_reference_10_desc := lv_reference_10_desc1 || p_receipt_num ||lv_reference_10_desc2 ||p_transaction_type ;
    end if;


    For tax_rec IN
        (
          SELECT
              sum(
                rtl.tax_amount * (NVL(jtc.mod_cr_percentage, 0)/100)
                * decode(nvl(rtl.currency, jai_rcv_trx_processing_pkg.gv_func_curr), jai_rcv_trx_processing_pkg.gv_func_curr, 1, p_currency_conversion_rate)
              ) tax_amount,
              jtc.tax_account_id
          FROM   JAI_RCV_LINE_TAXES rtl,
                 JAI_CMN_TAXES_ALL jtc
          WHERE  jtc.tax_id = rtl.tax_id
                 AND  shipment_line_id = p_shipment_line_id
                 AND  upper(rtl.tax_type) NOT IN ( 'EXCISE', 'ADDL. EXCISE',
		                                   'OTHER EXCISE', 'CVD','TDS', 'MODVAT RECOVERY',
               					   jai_constants.tax_type_add_cvd , -- Date 01/11/2006 Bug 5228046 added by SACSETHI
                                                    jai_constants.tax_type_exc_edu_cess,
						    jai_constants.tax_type_cvd_edu_cess,   -- Vijay Shankar for Bug#4068823 EDUCATION CESS
						    jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) -- added by csahoo for bug#5989740
                 -- following condition added by Vijay Shankar for Bug#4068823. Service Tax Enhancement
                 -- this is added to Stop Recovery Service Tax Accounting, as this will be done during RECEIVE trx or
                 -- during Payables Invoice/Payment depending on transaction parameters
                 AND  rtl.tax_type NOT IN (select attribute_code from JAI_RGM_REGISTRATIONS aa, JAI_RGM_DEFINITIONS bb
                                           where  aa.regime_id = bb.regime_id
                                           /* vat_regime is included in the following clause by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
                                           and    bb.regime_code IN (jai_constants.service_regime, jai_constants.vat_regime)
                                           and    aa.registration_type = jai_constants.regn_type_tax_types )
                 AND  NVL(rtl.modvat_flag, 'N') = 'Y'
          GROUP BY jtc.tax_account_id
        )
      LOOP

        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */

        if tax_rec.tax_account_id is null then
          p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
          p_process_status    := 'E';
          p_process_message   := 'The Tax Account is not found for this Tax : ';
          goto exit_from_procedure;
        end if;

        ln_individual_tax_amount := NVL(tax_rec.tax_amount,0) * nvl(p_apportion_factor,0);
        ln_rec_account_tax_amount := nvl(ln_rec_account_tax_amount,0) + nvl(ln_individual_tax_amount,0);

        if ln_individual_tax_amount <> 0 then

          p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
          if (p_transaction_type  ='CORRECT' AND p_parent_transaction_type = 'DELIVER') or
              p_transaction_type  = 'DELIVER' then /* DELIVER scenario */

            p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
            ln_credit_amount := NULL;
            ln_debit_amount  := ln_individual_tax_amount;

          elsif (p_transaction_type  ='CORRECT' AND p_parent_transaction_type = 'RETURN TO RECEIVING') or
                 p_transaction_type  = 'RETURN TO RECEIVING'  then /* RTR scenario */

            p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
            ln_credit_amount := ln_individual_tax_amount;
            ln_debit_amount  := NULL;

          end if;

          p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
          jai_rcv_accounting_pkg.process_transaction
          (
            p_transaction_id              =>      p_transaction_id,
            p_acct_type                   =>      p_accounting_type,
            p_acct_nature                 =>      lv_account_nature,
            p_source_name                 =>      lv_source,
            p_category_name               =>      lv_category,
            p_code_combination_id         =>      tax_rec.tax_account_id,
            p_entered_dr                  =>      ln_debit_amount,
            p_entered_cr                  =>      ln_credit_amount,
            p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
            p_accounting_date             =>      p_transaction_date,
            p_reference_10                =>      lv_reference_10_desc, --Reference10
            p_reference_23                =>      lv_reference23,
            p_reference_24                =>      lv_reference24,
            p_reference_25                =>      lv_reference25,
            p_reference_26                =>      to_char(p_transaction_id),
            p_destination                 =>      'G', /*Indicates that GL Interface needs to be hit */
            p_simulate_flag               =>      p_simulate,
            p_codepath                    =>      p_codepath,
            p_process_message             =>      p_process_message,
            p_process_status              =>      p_process_status
          );

          p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
          if p_process_status IN ('E', 'X') then
            p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
            goto exit_from_procedure;
          end if;

        end if; --end if for ln_individual_tax_amount <> 0
        p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
      end loop; --End Loop for Tax Rec.

    p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
    if ln_rec_account_tax_amount <> 0 then

          p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
          if (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'DELIVER') or
             p_transaction_type  = 'DELIVER' then /* DELIVER scenario */

            p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
            ln_credit_amount := ln_rec_account_tax_amount;
            ln_debit_amount  := NULL;

          elsif (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'RETURN TO RECEIVING') or
                 p_transaction_type = 'RETURN TO RECEIVING'  then /* RTR scenario */

            p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
            ln_credit_amount := NULL;
            ln_debit_amount  := ln_rec_account_tax_amount;

          end if;


          p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
          jai_rcv_accounting_pkg.process_transaction
          (
            p_transaction_id              =>      p_transaction_id,
            p_acct_type                   =>      p_accounting_type,
            p_acct_nature                 =>      lv_account_nature,
            p_source_name                 =>      lv_source,
            p_category_name               =>      lv_category,
            p_code_combination_id         =>      p_receiving_account_id,
            p_entered_dr                  =>      ln_debit_amount,
            p_entered_cr                  =>      ln_credit_amount,
            p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
            p_accounting_date             =>      p_transaction_date,
            p_reference_10                =>      lv_reference_10_desc, --Reference10
            p_reference_23                =>      lv_reference23,
            p_reference_24                =>      lv_reference24,
            p_reference_25                =>      lv_reference25,
            p_reference_26                =>      to_char(p_transaction_id),
            p_destination                 =>      'G', /*Indicates that GL Interface needs to be hit */
            p_simulate_flag               =>      p_simulate,
            p_codepath                    =>      lv_reference23,
            p_process_message             =>      p_process_message,
            p_process_status              =>      p_process_status
          );

          p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
          if p_process_status in ('E', 'X') then
            p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */
            goto exit_from_procedure;
          end if;
    end if; --end if for ln_rec_account_tax_amount <> 0

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(19, p_codepath, null, 'END'); /* 19 */
    return;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status    := 'E';
      p_process_message   := 'DELIVER_RTR_PKG.deliver_rtr_reco_nonexcise:' || sqlerrm;
      fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 20 */
      return;
  END deliver_rtr_reco_nonexcise;

  /*----------------------------------------------------------------------------------------*/
  PROCEDURE get_tax_amount_breakup
  (
      p_shipment_line_id             IN             NUMBER,
      p_transaction_id               IN             NUMBER,
      p_curr_conv_rate               IN             NUMBER,
      p_excise_amount OUT NOCOPY NUMBER,
      p_non_modvat_amount OUT NOCOPY NUMBER,
      p_other_modvat_amount OUT NOCOPY NUMBER,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                     IN OUT NOCOPY VARCHAR2
  ) IS

      ln_modvat_amount            NUMBER; --File.Sql.35 Cbabu   := 0;
      ln_non_modvat_amount        NUMBER; --File.Sql.35 Cbabu   := 0;
      ln_other_modvat_amount      NUMBER; --File.Sql.35 Cbabu   := 0;
      ln_conv_factor              NUMBER;
      lv_tax_modvat_flag          JAI_RCV_LINE_TAXES.modvat_flag%type;
      lv_debug                    VARCHAR2(1); --File.Sql.35 Cbabu  := 'Y';

      cursor c_ja_in_rcv_transactions(cp_transaction_id number) is
      select item_trading_flag,organization_type,excise_in_trading,item_excisable
      from   JAI_RCV_TRANSACTIONS
      where  transaction_id = cp_transaction_id;

      r_ja_in_rcv_transactions c_ja_in_rcv_transactions%rowtype;

  BEGIN

      --File.Sql.35 Cbabu
      ln_modvat_amount           := 0;
      ln_non_modvat_amount       := 0;
      ln_other_modvat_amount     := 0;
      lv_debug                    := 'Y';

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.get_tax_amount_breakup' , 'START'); /* 1 */

    OPEN   c_ja_in_rcv_transactions(p_transaction_id);
    FETCH  c_ja_in_rcv_transactions into r_ja_in_rcv_transactions;
    CLOSE  c_ja_in_rcv_transactions;

    FOR tax_rec IN
      (
        SELECT
          rtl.tax_type,
          nvl(rtl.tax_amount, 0)        tax_amount,
          nvl(rtl.modvat_flag, 'N')     modvat_flag,
          nvl(jtc.inclusive_tax_flag, 'N') inclusive_tax_flag, -- Added by Jia Li for India tax inclusive on 2007/11/28
          nvl(rtl.currency, 'INR')      currency,
          nvl(jtc.mod_cr_percentage, 0) mod_cr_percentage
        FROM
          JAI_RCV_LINE_TAXES rtl,
          JAI_CMN_TAXES_ALL jtc
        WHERE
          shipment_line_id = p_shipment_line_id
          AND jtc.tax_id = rtl.tax_id

        )
    LOOP

      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2*/
      if tax_rec.currency <> jai_rcv_trx_processing_pkg.gv_func_curr THEN
        ln_conv_factor := NVL(p_curr_conv_rate, 1);
        p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3*/
      ELSE
        ln_conv_factor := 1;
        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4*/
      end if;

      /*
        Comparison below is due to the case where Excise in RG23D ='Y', Tax_Rec.Modvat_Flag will be N
        as Item Modvat Flag in the setup is No.
        As a result of this, Excise should not be added to Item cost and hence deciding the Modvat
        Amount solely upon the Modvat Flag in JAI_RCV_LINE_TAXES is wrong.
        Hence, a variable ( lv_tax_modvat_flag) is first set based on the above permutations
        and then a decision of whether the Excise needs to be added or not is done based on this flag.
      */

      if  tax_rec.modvat_flag = 'Y'
          and upper(tax_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
	                                   'TDS', 'MODVAT RECOVERY',
         			           jai_constants.tax_type_add_cvd , -- Date 01/11/2006 Bug 5228046 added by SACSETHI
                                           jai_constants.tax_type_exc_edu_cess,
					   jai_constants.tax_type_cvd_edu_cess,   -- Vijay Shankar for Bug#4068823 EDUCATION CESS
					   jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) -- added by csahoo for bug#5989740
      then

        p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
        lv_tax_modvat_flag := 'Y';

      elsif upper(tax_rec.modvat_flag) = 'Y'
            and tax_rec.tax_type NOT IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
                         		  jai_constants.tax_type_add_cvd , -- Date 01/11/2006 Bug 5228046 added by SACSETHI
                                          jai_constants.tax_type_exc_edu_cess,
					  jai_constants.tax_type_cvd_edu_cess,   -- Vijay Shankar for Bug#4068823 EDUCATION CESS
					  jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) -- added by csahoo for bug#5989740
      then

        p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
        lv_tax_modvat_flag := 'Y';

      elsif tax_rec.modvat_flag                                = 'N'
            and  r_ja_in_rcv_transactions.item_trading_flag    = 'Y' /* Excise IN RG23D scenario */
            and  r_ja_in_rcv_transactions.excise_in_trading    = 'Y'
            and  r_ja_in_rcv_transactions.item_excisable       = 'Y'
            and  r_ja_in_rcv_transactions.organization_type    = 'T'
            and  upper(tax_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
              				     jai_constants.tax_type_add_cvd , -- Date 01/11/2006 Bug 5228046 added by SACSETHI
					     jai_constants.tax_type_exc_edu_cess,
					     jai_constants.tax_type_cvd_edu_cess,   -- Vijay Shankar for Bug#4068823 EDUCATION CESS
					     jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) -- added by csahoo for bug#5989740
      then

            p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
            lv_tax_modvat_flag := 'Y';

      else
            lv_tax_modvat_flag := 'N';

      end if; --tax_rec.modvat_flag = 'Y'

      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */

      if upper(tax_rec.tax_type) NOT IN ('TDS', 'MODVAT RECOVERY') THEN

        p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */

        if lv_tax_modvat_flag = 'Y'
        and upper(tax_rec.tax_type) IN ( 'EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
                                         jai_constants.tax_type_add_cvd , -- Date 01/11/2006 Bug 5228046 added by SACSETHI
                                         jai_constants.tax_type_exc_edu_cess,
					 jai_constants.tax_type_cvd_edu_cess,   -- Vijay Shankar for Bug#4068823 EDUCATION CESS
					 jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) -- added by csahoo for bug#5989740
        then

          p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
          ln_modvat_amount     := ln_modvat_amount     + tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_conv_factor;

          -- Added by Jia Li for India tax inclusive 2007/11/28, Begin
          -- TD15-Changed Standard and Average Costing
          -- recoverable tax is inclusive, its costing effect needs to be negated
          -- Modified by Jia Li for Bug#6877290
          ----------------------------------------------------------------------
          IF ( tax_rec.inclusive_tax_flag = 'Y' )
          THEN
            --ln_non_modvat_amount := ln_non_modvat_amount + tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_conv_factor * (-1); --Commented for bug#9233826
	    ln_non_modvat_amount := ln_non_modvat_amount + tax_rec.tax_amount * ( tax_rec.mod_cr_percentage/100) * ln_conv_factor * (-1);  -- Added for bug#9233826 by JMEENA
          ELSIF ( tax_rec.inclusive_tax_flag = 'N' )
          THEN
            ln_non_modvat_amount := ln_non_modvat_amount + tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_conv_factor;
          END IF; --tax_rec.inclusive_tax_flag = 'Y'
          -----------------------------------------------------------------------
          -- Added by Jia Li for India tax inclusive 2007/11/28, End

        elsif lv_tax_modvat_flag = 'Y'
          and upper(tax_rec.tax_type) NOT IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
        				      jai_constants.tax_type_add_cvd , -- Date 01/11/2006 Bug 5228046 added by SACSETHI
                                              jai_constants.tax_type_exc_edu_cess,
					      jai_constants.tax_type_cvd_edu_cess,   -- Vijay Shankar for Bug#4068823 EDUCATION CESS
					      jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess) -- added by csahoo for bug#5989740
        then

          p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
          ln_other_modvat_amount := ln_other_modvat_amount + tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_conv_factor;

          -- Added by Jia Li for India tax inclusive 2007/11/28, Begin
          -- TD15-Changed Standard and Average Costing
          -- recoverable tax is inclusive, its costing effect needs to be negated
          -- Modified by Jia Li for Bug#6877290
          ----------------------------------------------------------------------
          IF ( tax_rec.inclusive_tax_flag = 'Y' )
          THEN
           -- ln_non_modvat_amount   := ln_non_modvat_amount + tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_conv_factor * (-1); --Commented for bug#9233826
	    ln_non_modvat_amount   := ln_non_modvat_amount + tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_conv_factor * (-1); -- Added for bug#9233826 by JMEENA
          ELSIF ( tax_rec.inclusive_tax_flag = 'N' )
          THEN
            ln_non_modvat_amount   := ln_non_modvat_amount + tax_rec.tax_amount * (1 - tax_rec.mod_cr_percentage/100) * ln_conv_factor;
          END IF; --tax_rec.inclusive_tax_flag = 'Y'
          ----------------------------------------------------------------------
          -- Added by Jia Li for India tax inclusive 2007/11/28, End

        ELSIF lv_tax_modvat_flag ='N' and upper(tax_rec.tax_type) NOT IN ('TDS', 'MODVAT RECOVERY') THEN

          p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */

          -- Added by Jia Li for India tax inclusive 2007/11/28, Begin
          -- TD15-Changed Standard and Average Costing
          -- non-recoverable tax is inclusive, its costing should not be considered as it is already costed.
          -- Modified by Jia Li for Bug#6877290
          ----------------------------------------------------------------------
          IF ( tax_rec.inclusive_tax_flag = 'Y' )
          THEN
            ln_non_modvat_amount   := ln_non_modvat_amount + tax_rec.tax_amount * ln_conv_factor * 0;
          ELSIF ( tax_rec.inclusive_tax_flag = 'N' )
          THEN
            ln_non_modvat_amount   := ln_non_modvat_amount + tax_rec.tax_amount * ln_conv_factor;
          END IF; --tax_rec.inclusive_tax_flag = 'Y'
          ----------------------------------------------------------------------
          -- Added by Jia Li for India tax inclusive 2007/11/28, End

        end if; /* tax_rec.modvat_flag*/
        p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */

      end if; /*tax_rec.tax_type NOT IN ('TDS', 'Modvat Recovery')*/
      p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */

    END LOOP;

    /* Resseting the Out variables  */
    p_excise_amount            := ln_modvat_amount;
    p_non_modvat_amount        := ln_non_modvat_amount;
    p_other_modvat_amount      := ln_other_modvat_amount;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(15, p_codepath, null, 'END'); /* 15 */
    return;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status    := 'E';
      p_process_message   := 'DELIVER_RTR_PKG.get_tax_amount_breakup:' || sqlerrm;
      fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 16 */
      return;

  END get_tax_amount_breakup;

  /* ------------------------------------------------start of get_tax_amount_breakup------------*/
  PROCEDURE opm_costing
  (
      p_transaction_id               IN             NUMBER,
      p_transaction_date             IN             DATE,
      p_organization_id              IN             NUMBER,
      p_costing_amount               IN             NUMBER,
      p_receiving_account_id         IN             NUMBER,
      p_rcv_unit_of_measure          IN             VARCHAR2, /*Indicates UOM of RECEIVE Line */
      p_rcv_source_unit_of_measure   IN             VARCHAR2, /*Indicates Source UOM of RECEIVE Line */
      p_rcv_quantity                 IN             NUMBER,   /*Indicates Quantity of RECEIVE Line */
      p_source_doc_quantity          IN             NUMBER,   /*Indicates Source doc Quantity of RECEIVE Line */
      p_source_document_code         IN             VARCHAR2,
      p_po_distribution_id           IN             NUMBER,
      p_subinventory_code            IN             VARCHAR2,
      p_simulate                     IN             VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                     IN OUT NOCOPY VARCHAR2,
      p_process_special_source       IN             VARCHAR2,
      /* following parameter added by Vijay Shankar for Bug#4229164 */
      p_currency_conversion_rate      IN            NUMBER
  ) IS

    ln_rcv_quantity               rcv_transactions.quantity%TYPE;
    ln_material_account_id        mtl_secondary_inventories.material_account%type;
    ln_costing_amount             NUMBER;

    lv_accounting_type            varchar2(30); --File.Sql.35 Cbabu  := 'REGULAR'; /*Hard coded as Localization does not do anything in case of a RTR Transaction */
    lv_source                     varchar2(30); --File.Sql.35 Cbabu   := 'Inventory India';
    lv_category                   varchar2(30); --File.Sql.35 Cbabu   := 'MTL';
    lv_account_nature             VARCHAR2(30); --File.Sql.35 Cbabu   := 'OPM Costing';
    lv_debug                      VARCHAR2(1); --File.Sql.35 Cbabu    := 'Y';

    /* Bug 7581494 : Porting Bug 6905807 from 120.2.12000000.5 to 12.1 Branch */
    ln_opm_costing_amount         NUMBER;
    ln_apportion_factor           NUMBER;
    -- End Bug 7581494

    /*
    Accounting Entries which happen in this scenario are
   |---------------|-----------------------|---------------------------|--------------------------|
   | Transaction   |                       |                           |                          |
   |  Type         |        Amount         | Credit                    |   Debit                  |
   | ==============|====================== |===========================|==========================|
   | DELIVER       |          Total        |   Inv.Receiving           |                          |
   | DELIVER       |          Total        |                           |  Material Account        |
   ----------------|-----------------------|---------------------------|--------------------------|

   Only JAI_RCV_JOURNAL_ENTRIES is recorded with above entries But RCV_TRANSACTIONS will be updated only
   once.
    */

  BEGIN
    lv_accounting_type            := 'REGULAR';
    lv_source                     := 'Inventory India';
    lv_category                   := 'MTL';
    lv_account_nature             := 'OPM Costing';
    lv_debug                      := 'Y';

    /* This comparison is for Evaluating the Quantity */
    /* Meaning of this comparison
    if the Unit Of Measure is changed while RECEIVING then
    source doc quantity of RCV_TRANSACTIONS needs to be picked up
    otherwise
    the Quantity of RCV_TRANSACTIONS can be picked up.
    */

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.opm_costing', 'START'); /* 1 */

    -- This procedure should not be used. So returning back
    -- GOTO exit_from_procedure;

    if p_rcv_unit_of_measure <>   p_rcv_source_unit_of_measure then
      ln_rcv_quantity := p_source_doc_quantity;
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    ELSE
      ln_rcv_quantity := p_rcv_quantity;
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    end if;

    if nvl(ln_rcv_quantity,0) = 0 THEN
      p_process_status    := 'E';
      p_process_message   := 'The Quantity in RECEIVE line is Zero ';
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      goto exit_from_procedure;
    end if;

    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    ln_material_account_id := material_account
                                     (
                                       p_organization_id          =>  p_organization_id,
                                       p_source_document_code     =>  p_source_document_code,
                                       p_po_distribution_id       =>  p_po_distribution_id,
                                       p_subinventory             =>  p_subinventory_code,
                                       p_process_message          =>  p_process_message,
                                       p_process_status           =>  p_process_status,
                                       p_codepath                 =>  p_codepath
                                     );

     p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */

     if p_process_status in ('E', 'X') then
       p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
       goto exit_from_procedure;
     end if;

    -- ln_costing_amount :=   p_costing_amount / ln_rcv_quantity;
    /* above cost calculation is modified as belowe by Vijay Shankar for Bug#4229164 */

    /* Bug 7581494 : Porting Bug 6905807 from 120.2.12000000.5 to 12.1 Branch */
    ln_costing_amount :=   p_costing_amount /   p_currency_conversion_rate;
    ln_apportion_factor := jai_rcv_trx_processing_pkg.get_apportion_factor
 	                                                    ( p_transaction_id => p_transaction_id);
    ln_opm_costing_amount := p_costing_amount * ln_apportion_factor ;

    /* End Bug 7581494 : Porting Bug 6905807 from 120.2.12000000.5 to 12.1 Branch.*/
    if lv_debug ='Y' then
          fnd_file.put_line(fnd_file.log, 'OPM Costing. ln_apportion_factor:'||ln_apportion_factor
 	                                      ||', ln_opm_costing_amount:'||ln_opm_costing_amount
 	                                      ||', pCostAmt:'||p_costing_amount
 	                                      ||', Qty:'||ln_rcv_quantity
 	                                      ||', FinalCostAmt:'||ln_costing_amount
 	                                      ||', OPMCostAmt:'||ln_opm_costing_amount
                            );
    end if;

    /* Destination in this case is O1, which indicates that the JAI_RCV_JOURNAL_ENTRIES would be hit
       and also rcv_transactions would be updated */
    /* Credit Inventory Receiving Account */
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */


	/*

	commented for bug 7681614 by vumaasha


    jai_rcv_accounting_pkg.process_transaction
    (
      p_transaction_id              =>      p_transaction_id,
      p_acct_type                   =>      lv_accounting_type,
      p_acct_nature                 =>      lv_account_nature,
      p_source_name                 =>      lv_source,
      p_category_name               =>      lv_category,
      p_code_combination_id         =>      p_receiving_account_id,
      p_entered_dr                  =>      NULL,
      p_entered_cr                  =>      ln_opm_costing_amount,
      p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date             =>      p_transaction_date,
      p_reference_10                =>      NULL,
      p_reference_23                =>      NULL,
      p_reference_24                =>      NULL,
      p_reference_25                =>      NULL,
      p_reference_26                =>      NULL,
      p_destination                 =>      'O1',
      p_simulate_flag               =>      p_simulate,
      p_codepath                    =>      p_codepath,
      p_process_message             =>      p_process_message,
      p_process_status              =>      p_process_status
    );

	end of comment for bug 7681614 by vumaasha
	*/

    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */

    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
      goto exit_from_procedure;
    end if;

    /* Debit Material Account
     Destination in this case is O1, which indicates that the JAI_RCV_JOURNAL_ENTRIES would be hit
     and also rcv_transactions would be updated */

    p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */

	/*

	commented for bug 7681614 by vumaasha


	jai_rcv_accounting_pkg.process_transaction
    (
      p_transaction_id              =>      p_transaction_id,
      p_acct_type                   =>      lv_accounting_type,
      p_acct_nature                 =>      lv_account_nature,
      p_source_name                 =>      lv_source,
      p_category_name               =>      lv_category,
      p_code_combination_id         =>      ln_material_account_id,
      p_entered_dr                  =>      ln_opm_costing_amount,
      p_entered_cr                  =>      NULL,
      p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date             =>      p_transaction_date,
      p_reference_10                =>      NULL,
      p_reference_23                =>      NULL,
      p_reference_24                =>      NULL,
      p_reference_25                =>      NULL,
      p_reference_26                =>      NULL,
      p_destination                 =>      'O2',
      p_simulate_flag               =>      p_simulate,
      p_codepath                    =>      p_codepath,
      p_process_message             =>      p_process_message,
      p_process_status              =>      p_process_status
    );

	end of comment for bug 7681614 by vumaasha

	*/

    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
      goto exit_from_procedure;
    end if;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(13, p_codepath, null, 'END'); /* 13 */
    return;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status    := 'E';
      p_process_message   := 'DELIVER_RTR_PKG.opm_costing:' || sqlerrm;
      fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 14 */
      return;
  END opm_costing;

  /*---------------------------------------------------------------------------------------*/
  PROCEDURE expense_accounting
  (
     p_transaction_id            IN            NUMBER,
     p_transaction_date          IN            DATE,
     p_organization_id           IN            NUMBER,
     p_transaction_type          IN            VARCHAR2,
     p_parent_transaction_type   IN            VARCHAR2,
     p_receipt_num               IN            VARCHAR2,
     p_shipment_line_id          IN            NUMBER,
     p_subinventory_code         IN            VARCHAR2,
     p_accounted_amount          IN            NUMBER,
     p_receiving_account_id      IN            NUMBER,
     p_source_document_code      IN            VARCHAR2,
     p_po_distribution_id        IN            NUMBER,
     p_po_line_location_id       IN            NUMBER,
     p_inventory_item_id         IN            NUMBER,
     p_accounting_type           IN            VARCHAR2,
     p_simulate                  IN            VARCHAR2,
     p_process_message OUT NOCOPY VARCHAR2,
     p_process_status OUT NOCOPY VARCHAR2,
     p_codepath                  IN OUT NOCOPY VARCHAR2,
     p_process_special_source     IN            VARCHAR2
  ) IS

    /* This Procedure is meant for Expense Accounting Entries
       Accounting Entries in this context are:

     |------------------------------------------------------------------------------------------------
     | Transaction   |                       |                           |                           |
     |  Type         |        Amount         | Credit                    |   Debit                   |
     | ==============|====================== |===========================|===========================|
     | DELIVER       |          Total        | Inv.Receiving             |                           |
     | DELIVER       |          Total        |                           |   Expense Account         |
     -------------------------------------------------------------------------------------------------
     | RTR           |          Total        | Expense Account           |                           |
     | RTR           |          Total        |                           |   Inv.Receiving           |
     -------------------------------------------------------------------------------------------------

    */

    lv_account_nature          VARCHAR2(30); --File.Sql.35 Cbabu                   := 'Expense Accounting';
    lv_source                   VARCHAR2(100); --File.Sql.35 Cbabu         := 'Purchasing India';
    lv_category                 VARCHAR2(100); --File.Sql.35 Cbabu         := 'Receiving India';
    lv_reference23             gl_interface.reference23%type; --File.Sql.35 Cbabu  := 'jai_rcv_deliver_rtr_pkg.expense_accounting';
    lv_reference24             gl_interface.reference24%type; --File.Sql.35 Cbabu  := 'rcv_transactions';
    lv_reference25             gl_interface.reference25%type; --File.Sql.35 Cbabu  := 'transaction_id';
    lv_debug                   VARCHAR2(1); --File.Sql.35 Cbabu                    := 'Y';
    lv_reference_10_desc1      VARCHAR2(75); --File.Sql.35 Cbabu                   := 'India Local Receiving Entry for the Receipt Number ';
    lv_reference_10_desc2      VARCHAR2(30); --File.Sql.35 Cbabu                   := ' For the Transaction Type ';
    lv_reference_10_desc       gl_interface.reference10%type;

    ln_credit_amount           NUMBER;
    ln_debit_amount            NUMBER;
    ln_expense_account         mtl_secondary_inventories.expense_account%type;


  BEGIN
     --File.Sql.35 Cbabu
    lv_account_nature          := 'Expense Accounting';
    lv_source                  := 'Purchasing India';
    lv_category                := 'Receiving India';
    lv_reference23             := 'jai_rcv_deliver_rtr_pkg.expense_accounting';
    lv_reference24             := 'rcv_transactions';
    lv_reference25             := 'transaction_id';
    lv_debug                   := 'Y';
    lv_reference_10_desc1      := 'India Local Receiving Entry for the Receipt Number ';
    lv_reference_10_desc2      := ' For the Transaction Type ';

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.expense_accounting', 'START'); /* 1 */

    /* Vijay Shankar for Bug#4068823. RECEIPTS DEPLUG
       vat_noclaim added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    IF p_process_special_source = jai_constants.cenvat_noclaim THEN
      lv_account_nature := 'Cenvat Unclaim Expense';
    ELSIF p_process_special_source = jai_constants.vat_noclaim THEN
      lv_account_nature := 'VAT Unclaim Expense';
    END IF;

    if p_transaction_type='CORRECT' then
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      lv_reference_10_desc := lv_reference_10_desc1 || p_receipt_num ||lv_reference_10_desc2 ||p_transaction_type ||' of Type ' || p_parent_transaction_type;
    else
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      lv_reference_10_desc := lv_reference_10_desc1 || p_receipt_num ||lv_reference_10_desc2 ||p_transaction_type ;
    end if;


   p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
   ln_expense_account := expense_account
                         (
                            p_transaction_id            =>  p_transaction_id,
                            p_organization_id           =>  p_organization_id,
                            p_subinventory_code         =>  p_subinventory_code,
                            p_po_distribution_id        =>  p_po_distribution_id,
                            p_po_line_location_id       =>  p_po_line_location_id,
                            p_item_id                   =>  p_inventory_item_id,
                            p_process_message           =>  p_process_message,
                            p_process_status            =>  p_process_status,
                            p_codepath                  =>  p_codepath
                         );
    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */

    if p_process_status IN ('E', 'X') THEN
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath, NULL, 'END'); /* 5 */
      goto exit_from_procedure;
    end if;

    if (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'DELIVER') or
        p_transaction_type = 'DELIVER' then

      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      ln_debit_amount   := NULL;
      ln_credit_amount  := p_accounted_amount;

    ELSIF  (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'RETURN TO RECEIVING') or
            p_transaction_type = 'RETURN TO RECEIVING' then

      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
      ln_debit_amount   := p_accounted_amount;
      ln_credit_amount  := NULL;

    end if;

    /* Inventory Receiving Account */
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
    jai_rcv_accounting_pkg.process_transaction
    (
      p_transaction_id              =>      p_transaction_id,
      p_acct_type                   =>      p_accounting_type,
      p_acct_nature                 =>      lv_account_nature,
      p_source_name                 =>      lv_source,
      p_category_name               =>      lv_category,
      p_code_combination_id         =>      p_receiving_account_id,
      p_entered_dr                  =>      ln_debit_amount,
      p_entered_cr                  =>      ln_credit_amount,
      p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date             =>      p_transaction_date,
      p_reference_10                =>      lv_reference_10_desc || p_receipt_num ||lv_reference_10_desc1 ||p_transaction_type, --Reference10
      p_reference_23                =>      lv_reference23,
      p_reference_24                =>      lv_reference24,
      p_reference_25                =>      lv_reference25,
      p_reference_26                =>      to_char(p_transaction_id),
      p_destination                 =>      'G', /*Indicates that GL Interface needs to be hit */
      p_simulate_flag               =>      p_simulate,
      p_codepath                    =>      p_codepath,
      p_process_message             =>      p_process_message,
      p_process_status              =>      p_process_status
    );
    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */

    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
      goto exit_from_procedure;
    end if;

    if (p_transaction_type ='CORRECT' AND p_parent_transaction_type ='DELIVER') or
        p_transaction_type ='DELIVER' then

      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
      ln_debit_amount   := p_accounted_amount;
      ln_credit_amount  := NULL;

    elsif  (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'RETURN TO RECEIVING') or
            p_transaction_type = 'RETURN TO RECEIVING' then

      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
      ln_debit_amount   := NULL;
      ln_credit_amount  := p_accounted_amount;
    end if;

    /* Expense Account */
    p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
    jai_rcv_accounting_pkg.process_transaction
    (
      p_transaction_id              =>      p_transaction_id,
      p_acct_type                   =>      p_accounting_type,
      p_acct_nature                 =>      lv_account_nature,
      p_source_name                 =>      lv_source,
      p_category_name               =>      lv_category,
      p_code_combination_id         =>      ln_expense_account,
      p_entered_dr                  =>      ln_debit_amount,
      p_entered_cr                  =>      ln_credit_amount,
      p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date             =>      p_transaction_date,
      p_reference_10                =>      lv_reference_10_desc || p_receipt_num ||lv_reference_10_desc1 ||p_transaction_type, --Reference10
      p_reference_23                =>      lv_reference23,
      p_reference_24                =>      lv_reference24,
      p_reference_25                =>      lv_reference25,
      p_reference_26                =>      to_char(p_transaction_id),
      p_destination                 =>      'G', /*Indicates that GL Interface needs to be hit */
      p_simulate_flag               =>      p_simulate,
      p_codepath                    =>      p_codepath,
      p_process_message             =>      p_process_message,
      p_process_status              =>      p_process_status
    );
    p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */

    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
      goto exit_from_procedure;
    end if;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(16, p_codepath, null, 'END'); /* 16 */
    return;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status    := 'E';
      p_process_message   := 'DELIVER_RTR_PKG.expense_accounting:' || sqlerrm ;
      fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 17 */

  END expense_accounting;

  /* ---------------------------------------------start of average costing procedure --------------*/
  PROCEDURE average_costing
  (
    p_transaction_id            IN            NUMBER,
    p_transaction_date          IN            DATE,
    p_organization_id           IN            NUMBER,
    p_parent_transaction_type   IN            VARCHAR2,
    p_transaction_type          IN            VARCHAR2,
    p_subinventory_code         IN            VARCHAR2,
    p_costing_amount            IN            NUMBER,
    p_receiving_account_id      IN            NUMBER,
    p_source_document_code      IN            VARCHAR2,
    p_po_distribution_id        IN            NUMBER,
    p_unit_of_measure           IN            VARCHAR2,
    p_inventory_item_id         IN            NUMBER,
    p_accounting_type           IN            VARCHAR2,
    p_simulate                  IN            VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_process_status OUT NOCOPY VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2,
    p_process_special_source    IN            VARCHAR2
  ) is

    ln_material_account_id     mtl_secondary_inventories.material_account%type;
    ln_costing_amount          number;

    lv_source                  varchar2(30); --File.Sql.35 Cbabu  := 'Inventory India';
    lv_category                varchar2(30); --File.Sql.35 Cbabu  := 'MTL';
    lv_debug                   varchar2(1); --File.Sql.35 Cbabu   := 'Y';
    lv_uom_code                mtl_units_of_measure.unit_of_measure % TYPE;
    lv_account_nature          varchar2(30); --File.Sql.35 Cbabu  := 'Average Costing';

    /*
    This Procedure is meant for Costing Entries in case of a Average costing Organization
       with the destination type being Inventory.

       The Value change part is sent to MMTT and hence only 1 row is populated into MMTT
       with the Account being Inv. Receiving Always.

    Transaction Type     | Amount            |     Account
    =====================|===================|==========================================
    DELIVER              |  Costing          |   Inv.Receiving
    RETURN TO RECEIVING  | -Costing          |   Inv.Receiving
    =====================|===================|==========================================

    The Entry recorded in JAI_RCV_JOURNAL_ENTRIES is :

    Transaction Type      Amount              Credit                   Debit
    |===================|=================|====================|=======================|
    |DELIVER            |   Costing       |  Inv. Receiving    |                       |
    |DELIVER            |   Costing       |                    |    Material Account   |
    ------------------------------------------------------------------------------------
    |RTR                |   -Costing      |  Inv. Receiving    |                       |
    |RTR                |   -Costing      |                    |    Material Account   |
    |===================|=================|====================|=======================|
    */

  BEGIN
    --File.Sql.35 Cbabu
    lv_source                  := 'Inventory India';
    lv_category                := 'MTL';
    lv_debug                   := 'Y';
    lv_account_nature          := 'Average Costing';

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.average_costing', 'START'); /* 1 */

    IF p_process_special_source = jai_constants.cenvat_noclaim THEN
      lv_account_nature := 'Unclaim Average Costing';

    /* elsif added for vat_noclaim by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    ELSIF  p_process_special_source = jai_constants.vat_noclaim THEN
      lv_account_nature := 'VAT Unclaim Average Costing';
    END IF;

    /* Fetch the Material Account Id */
    ln_material_account_id := material_account
                              (
                                 p_organization_id          =>  p_organization_id,
                                 p_source_document_code     =>  p_source_document_code,
                                 p_po_distribution_id       =>  p_po_distribution_id,
                                 p_subinventory             =>  p_subinventory_code,
                                 p_process_message          =>  p_process_message,
                                 p_process_status           =>  p_process_status,
                                 p_codepath                 =>  p_codepath
                              );
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */

    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      goto exit_from_procedure;
    end if;

    lv_uom_code  := jai_general_pkg.get_uom_code(p_uom => p_unit_of_measure);


    if lv_uom_code IS NULL THEN

      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      lv_uom_code  := jai_general_pkg.get_primary_uom_code
                      (
                       p_organization_id     => p_organization_id,
                       p_inventory_item_id   => p_inventory_item_id
                      );
    end if;

    if lv_debug='Y' THEN
      fnd_file.put_line( fnd_file.log, ' 3.3 '|| ' p_unit_of_measure -> ' ||  p_unit_of_measure || ' lv_uom_code -> ' ||  lv_uom_code);
    end if;

    if (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'DELIVER') or
        p_transaction_type = 'DELIVER' then

      ln_costing_amount := p_costing_amount;
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */

    elsif (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'RETURN TO RECEIVING') or
           p_transaction_type = 'RETURN TO RECEIVING' then

      ln_costing_amount := -p_costing_amount;
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */

    end if;

    /* Destination in this case is A1, which indicates that the JAI_RCV_JOURNAL_ENTRIES would be hit
       and also MMTT would be updated */

    /* Inventory Receiving Account */
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    jai_rcv_accounting_pkg.process_transaction
    (
      p_transaction_id              =>      p_transaction_id,
      p_acct_type                   =>      p_accounting_type,
      p_acct_nature                 =>      lv_account_nature,
      p_source_name                 =>      lv_source,
      p_category_name               =>      lv_category,
      p_code_combination_id         =>      p_receiving_account_id,
      p_entered_dr                  =>      NULL, /* This should never be changed to Zero */
      p_entered_cr                  =>      ln_costing_amount,
      p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date             =>      p_transaction_date,
      p_reference_10                =>      NULL,
      p_reference_23                =>      NULL,
      p_reference_24                =>      NULL,
      p_reference_25                =>      NULL,
      p_reference_26                =>      NULL,
      p_destination                 =>      'A1', /*Indicates Average Costing Entry */
      p_simulate_flag               =>      p_simulate,
      p_codepath                    =>      p_codepath,
      p_process_message             =>      p_process_message,
      p_process_status              =>      p_process_status
    );
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */

    if p_process_status in ('E', 'X') then
      goto exit_from_procedure;
    end if;

    /* Debit Material Account
    /* Destination in this case is A2, which indicates that the JAI_RCV_JOURNAL_ENTRIES would be hit
       and also MMTT would be updated */

    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
    jai_rcv_accounting_pkg.process_transaction
    (
      p_transaction_id              =>      p_transaction_id,
      p_acct_type                   =>      p_accounting_type,
      p_acct_nature                 =>      lv_account_nature,
      p_source_name                 =>      lv_source,
      p_category_name               =>      lv_category,
      p_code_combination_id         =>      ln_material_account_id,
      p_entered_dr                  =>      ln_costing_amount,
      p_entered_cr                  =>      NULL, /* This should never be changed to Zero */
      p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date             =>      p_transaction_date,
      p_reference_10                =>      NULL,
      p_reference_23                =>      NULL,
      p_reference_24                =>      NULL,
      p_reference_25                =>      NULL,
      p_reference_26                =>      NULL,
      p_destination                 =>      'A2', /*Indicates Average Costing Entry */
      p_simulate_flag               =>      p_simulate,
      p_codepath                    =>      p_codepath,
      p_process_message             =>      p_process_message,
      p_process_status              =>      p_process_status
    );

    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
      goto exit_from_procedure;
    end if;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(11, p_codepath, null, 'END'); /* 11 */
    return;

  exception
    WHEN OTHERS THEN
      p_process_status    := 'E';
      p_process_message   := 'DELIVER_RTR_PKG.average_costing:' || sqlerrm ;
      fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 12 */

  END average_costing;

  /*----------------------------start of standard costing-------------------------------------------------------*/

  PROCEDURE standard_costing
  (
      p_transaction_id            IN            NUMBER,
      p_transaction_date          IN            DATE,
      p_organization_id           IN            NUMBER,
      p_parent_transaction_type   IN            VARCHAR2,
      p_transaction_type          IN            VARCHAR2,
      p_costing_amount            IN            NUMBER,
      p_receiving_account_id      IN            NUMBER,
      p_accounting_type           IN            VARCHAR2,
      p_simulate                  IN            VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                  IN OUT NOCOPY VARCHAR2,
      p_process_special_source    IN            VARCHAR2
  ) is

      /*
    This Procedure is meant for Costing Entries in case of a Standard costing Organization


    The Costing Amount is populated into  MTA.

    Transaction Type     | Amount            |     Account
    =====================|===================|==========================================
    DELIVER              |  Negative Amount  |   Inv.Receiving
    DELIVER              |  Positive Amount  |   PPV Account
    -----------------------------------------------------------------------------------
    RETURN TO RECEIVING  |  Positive Amount  |   Inv.Receiving
    RETURN TO RECEIVING  |  Negative Amount  |   PPV Account
    =====================|===================|==========================================

    The Entry recorded in JAI_RCV_JOURNAL_ENTRIES is :

    Transaction Type      Amount              Credit                   Debit
    ===================|=================|====================|=======================|
    DELIVER            | Costing Amount  |   Inv.Receiving    |                       |
    DELIVER            | Costing Amount  |                    |  PPV Account          |
    -------------------------------------|--------------------|-----------------------|
    RTR                | Costing Amount  |                    | Inv.Receiving         |
    RTR                | Costing Amount  |   PPV Account      |                       |
    ===================|=================|====================|=======================|

    */

    ln_ppv_account_id           mtl_parameters.purchase_price_var_account%type;
    ln_credit_amount            NUMBER;
    ln_debit_amount             NUMBER;

    lv_source                  VARCHAR2(30); --File.Sql.35 Cbabu  := 'Inventory India';
    lv_category                VARCHAR2(30); --File.Sql.35 Cbabu  := 'MTL';
    lv_account_nature          VARCHAR2(30); --File.Sql.35 Cbabu  := 'Standard Costing';
    --lv_debug                   varchar2(1)  := 'Y';

    --lv_transaction_type        JAI_RCV_TRANSACTIONS.transaction_type%TYPE;
    lv_reference_10_desc1         VARCHAR2(75);--rchandan for bug#4473022
    lv_reference_10_desc2         VARCHAR2(30); --rchandan for bug#4473022
    lv_reference_10_desc          gl_interface.reference10%type;--rchandan for bug#4473022

  BEGIN

    lv_source                  := 'Inventory India';
    lv_category                := 'MTL';
    lv_account_nature          := 'Standard Costing';
    lv_reference_10_desc1      := 'India Local Receiving Entry for the Receipt Number ';--rchandan for bug#4473022
    lv_reference_10_desc2      := ' For the Transaction Type ';--rchandan for bug#4473022

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.standard_costing', 'START'); /* 1 */

    -- Vijay Shankar for Bug#4068823. RECEIPTS DEPLUG
    IF p_process_special_source = jai_constants.cenvat_noclaim THEN
      lv_account_nature := 'Unclaim Standard Costing';

    /* elsif added for vat_noclaim by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    ELSIF  p_process_special_source = jai_constants.vat_noclaim THEN
      lv_account_nature := 'VAT Unclaim Standard Costing';
    END IF;

    ln_ppv_account_id :=  ppv_account
                          (
                              p_organization_id   => p_organization_id,
                              p_process_message   => p_process_message,
                              p_process_status    => p_process_status,
                              p_codepath          => p_codepath
                          );
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */

    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      goto exit_from_procedure;
    end if;

    if (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'DELIVER')  or
        p_transaction_type = 'DELIVER' then

      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      ln_credit_amount     := p_costing_amount;
      ln_debit_amount      := NULL;

    elsif (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'RETURN TO RECEIVING') or
           p_transaction_type = 'RETURN TO RECEIVING' then

      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      ln_credit_amount     := NULL;
      ln_debit_amount      := p_costing_amount;

    end if;

    /* Receiving Inspection Account */
    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
    jai_rcv_accounting_pkg.process_transaction
    (
      p_transaction_id              =>      p_transaction_id,
      p_acct_type                   =>      p_accounting_type,
      p_acct_nature                 =>      lv_account_nature,
      p_source_name                 =>      lv_source,
      p_category_name               =>      lv_category,
      p_code_combination_id         =>      p_receiving_account_id,
      p_entered_dr                  =>      ln_debit_amount,
      p_entered_cr                  =>      ln_credit_amount,
      p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date             =>      p_transaction_date,
      p_reference_10                =>      NULL,
      p_reference_23                =>      'jai_rcv_deliver_rtr_pkg.standard_costing',   --rchandan for bug#4473022
      p_reference_24                =>      'rcv_transactions',  --rchandan for bug#4473022
      p_reference_25                =>      NULL,
      p_reference_26                =>      to_char(p_transaction_id),
      p_destination                 =>      'S', /*Indicates Standard Costing. */
      p_simulate_flag               =>      p_simulate,
      p_codepath                    =>      p_codepath,
      p_process_message             =>      p_process_message,
      p_process_status              =>      p_process_status
    );

    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
      goto exit_from_procedure;
    end if;

    if (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'DELIVER') or
        p_transaction_type = 'DELIVER' then

      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
      ln_credit_amount     := NULL;
      ln_debit_amount      := p_costing_amount;

    elsif (p_transaction_type ='CORRECT' AND p_parent_transaction_type = 'RETURN TO RECEIVING') or
           p_transaction_type = 'RETURN TO RECEIVING' then

      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
      ln_credit_amount     := p_costing_amount;
      ln_debit_amount      := NULL;

    end if;

    /* PPV Account */
    p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
    jai_rcv_accounting_pkg.process_transaction
    (
      p_transaction_id              =>      p_transaction_id,
      p_acct_type                   =>      p_accounting_type,
      p_acct_nature                 =>      lv_account_nature,
      p_source_name                 =>      lv_source,
      p_category_name               =>      lv_category,
      p_code_combination_id         =>      ln_ppv_account_id,
      p_entered_dr                  =>      ln_debit_amount,
      p_entered_cr                  =>      ln_credit_amount,
      p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
      p_accounting_date             =>      p_transaction_date,
      p_reference_10                =>      NULL,
      p_reference_23                =>      'jai_rcv_deliver_rtr_pkg.standard_costing',   --rchandan for bug#4473022
      p_reference_24                =>      'rcv_transactions',  --rchandan for bug#4473022
      p_reference_25                =>      NULL,
      p_reference_26                =>      to_char(p_transaction_id),
      p_destination                 =>      'S', /*Indicates Standard Costing. */
      p_simulate_flag               =>      p_simulate,
      p_codepath                    =>      p_codepath,
      p_process_message             =>      p_process_message,
      p_process_status              =>      p_process_status
    );

    if p_process_status in ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
      goto exit_from_procedure;
    end if;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(13, p_codepath, null, 'END'); /* 13 */
    return;

    EXCEPTION
      WHEN OTHERS THEN
        p_process_status    := 'E';
        p_process_message   := 'DELIVER_RTR_PKG.standard_costing:' || sqlerrm ;
        fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
        p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 14 */

  END standard_costing;


/* ------------------------------------start of receiving_account-----------------------*/

  FUNCTION  receiving_account
  (
      p_organization_id              IN             NUMBER,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                     IN OUT NOCOPY VARCHAR2
  )
  return number is

    CURSOR c_receiving_account(cp_organization_id number) IS
    SELECT receiving_account_id
    FROM   rcv_parameters
    WHERE  organization_id = cp_organization_id;

    ln_receiving_account_id    rcv_parameters.receiving_account_id%type;
    --lv_debug                   varchar2(1)  := 'Y';

  BEGIN

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.receiving_account', 'START'); /* 1 */
    open  c_receiving_account(p_organization_id);
    fetch c_receiving_account into ln_receiving_account_id;
    close c_receiving_account;

    if ln_receiving_account_id is null then
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath, null, 'END'); /* 2 */
      p_process_status   :='E';
      p_process_message  :='Receiving Account Not Defined';
      RETURN null;
      -- raise no_receiving_account;
    else
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath, null, 'END'); /* 3 */
      return(ln_receiving_account_id);
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status   := 'E';
      p_process_message  := 'DELIVER_RTR_PKG.receiving_account:' || SQLERRM;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 5 */
      return null;

  END  receiving_account;

  /*----------------------------------------------------------------------*/
  FUNCTION material_account
  (
      p_organization_id              IN             NUMBER,
      p_source_document_code         IN             VARCHAR2,
      p_po_distribution_id           IN             NUMBER,
      p_subinventory                 IN             VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                     IN OUT NOCOPY VARCHAR2
  )
  RETURN NUMBER IS

    CURSOR  c_costing_group_id(cp_po_distribution_id number) is
    SELECT  costing_group_id
    FROM    pjm_project_parameters
    WHERE  project_id in
          (select project_id
           from  po_distributions_all
           where  po_distribution_id =cp_po_distribution_id
          );

    /* cursor to get the material account pertaining to the cost group passed */
    CURSOR c_material_account_cg(cp_cost_group_id number) is
    SELECT material_account
    FROM   cst_cost_group_accounts
    WHERE  cost_group_id = cp_cost_group_id;

    /* cursor to get the material account */
    CURSOR c_material_account(cp_organization_id number , cp_subinventory varchar2) is
    SELECT material_account
    FROM mtl_secondary_inventories
    WHERE organization_id        = cp_organization_id
    AND secondary_inventory_name = cp_subinventory;


    ln_material_account_id     mtl_secondary_inventories.material_account%type;
    ln_costing_group_id        pjm_project_parameters.costing_group_id%type;

    lv_debug                   varchar2(1); --File.Sql.35 Cbabu   := 'Y';

  BEGIN

    lv_debug                   := 'Y';
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.material_account', 'START'); /* 1 */

    if p_source_document_code = 'PO' then

      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      open  c_costing_group_id(p_po_distribution_id);
      fetch c_costing_group_id into ln_costing_group_id;
      close c_costing_group_id;


      open  c_material_account_cg(ln_costing_group_id);
      fetch c_material_account_cg into ln_material_account_id;
      close c_material_account_cg;

      if lv_debug='Y' THEN
        fnd_file.put_line( fnd_file.log, '4_2.1 costing group' || ln_costing_group_id);
        fnd_file.put_line( fnd_file.log, '4_2.2 material acct of costing group' || ln_material_account_id);
      end if;

    end if;

    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    if ln_material_account_id is null then

      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      open  c_material_account(p_organization_id,p_subinventory);
      fetch c_material_account into ln_material_account_id;
      close c_material_account;

    end if;

    if  ln_material_account_id is null then
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath, null, 'END'); /* 5 */
      p_process_status   :='E';
      p_process_message  :='Material Account Not Defined';
      return null;
      --raise no_material_account;
    else
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath, null, 'END'); /* 6 */
      return(ln_material_account_id);
    end if;


  EXCEPTION

    WHEN OTHERS THEN
      p_process_status   :='E';
      p_process_message  :='DELIVER_RTR_PKG.material_account:' || SQLERRM;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 8 */
      return null;

  END material_account ;

  /*---------------------------------Start of Expense_Account----------------------------*/
  FUNCTION expense_account
  (
      p_transaction_id                IN             NUMBER,
      p_organization_id               IN             NUMBER,
      p_subinventory_code             IN             VARCHAR2,
      p_po_distribution_id            IN             NUMBER,
      p_po_line_location_id           IN             NUMBER,
      p_item_id                       IN             NUMBER,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                      IN OUT NOCOPY VARCHAR2
  )
  RETURN NUMBER IS

    ln_expense_account     mtl_secondary_inventories.expense_account%type;

    lv_debug               varchar2(1); --File.Sql.35 Cbabu   := 'Y';

    cursor c_fetch_expense_acct(cp_organization_id in number, cp_subinventory_code in varchar2) IS
    SELECT expense_account
    FROM mtl_secondary_inventories
    WHERE organization_id        = cp_organization_id
    AND secondary_inventory_name = cp_subinventory_code;

    cursor c_fetch_expense_acct1(cp_po_distribution_id in number) IS
    SELECT code_combination_id
    FROM   po_distributions_all
    WHERE  po_distribution_id = cp_po_distribution_id;

    CURSOR c_fetch_expense_acct2(cp_po_line_location_id in number) IS
    SELECT code_combination_id
    FROM po_distributions_all
    WHERE line_location_id = cp_po_line_location_id
    AND creation_date IN
    (SELECT max(creation_date)
     FROM po_distributions_all
     WHERE line_location_id = cp_po_line_location_id
    );

    CURSOR c_fetch_expense_acct3(cp_organization_id in number, cp_item_id in number) IS
    SELECT expense_account
    FROM mtl_system_items
    WHERE organization_id   = cp_organization_id
    AND   inventory_item_id = cp_item_id;

  BEGIN

    lv_debug  := 'Y';

    /* In case of a Expense Route Data is populated into rcv_receiving_sub_ledger
       and hence CCID can be picked up from here instead of looking into various
       other possibilities
   */

    /* To be checked whether this can be done in a different way */
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.expense_account', 'START'); /* 1 */

    open  c_fetch_expense_acct(p_organization_id, p_subinventory_code);
    fetch c_fetch_expense_acct into ln_expense_account;
    close c_fetch_expense_acct;

    if ln_expense_account is null then

      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      if p_po_distribution_id is not null then

        p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
        open   c_fetch_expense_acct1(p_po_distribution_id);
        fetch  c_fetch_expense_acct1 into ln_expense_account;
        close  c_fetch_expense_acct1;

      elsif p_po_line_location_id is not null then

        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
        open  c_fetch_expense_acct2(p_po_line_location_id);
        fetch c_fetch_expense_acct2 into ln_expense_account;
        close c_fetch_expense_acct2;

      end if;
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */

    end if; --end if for ln_expense_account.

    if ln_expense_account is null then

      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      open   c_fetch_expense_acct3(p_organization_id, p_item_id);
      fetch  c_fetch_expense_acct3 into ln_expense_account;
      close  c_fetch_expense_acct3;

    end if;


    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    if ln_expense_account is null then
      p_process_status     := 'E';
      p_process_message    := 'Expense Account is Not Found ';
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath, null, 'END'); /* 8 */
     return null;
    end if;

    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, null, 'END'); /* 9 */

    return(ln_expense_account);


  EXCEPTION
    WHEN OTHERS THEN
      p_process_status   := 'E';
      p_process_message  := 'DELIVER_RTR_PKG.expense_account:' || SQLERRM;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 10 */
      return null;
  END expense_account;

/*----------------------------------------------------------------------------------------*/

  FUNCTION ppv_account
  (
      p_organization_id               IN      NUMBER,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                      IN OUT NOCOPY VARCHAR2
  )
  return number is

    lv_debug              varchar2(1); --File.Sql.35 Cbabu   := 'Y';
    cursor c_ppv_account(cp_organization_id IN NUMBER) is
    SELECT purchase_price_var_account
    FROM mtl_parameters
    WHERE organization_id = cp_organization_id;

    ln_ppv_account_id     NUMBER;


  BEGIN

      lv_debug    := 'Y';

      p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.ppv_account', 'START'); /* 1 */
      open  c_ppv_account(p_organization_id);
      fetch c_ppv_account into ln_ppv_account_id;
      close c_ppv_account;

      if ln_ppv_account_id is null then
        p_process_status   := 'E';
        p_process_message  := 'The Purchase Price Variance Account is not found  ' ;
        p_codepath := jai_general_pkg.plot_codepath(2, p_codepath, null, 'END'); /* 2 */
        return null;
      ELSE
        p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
        return(ln_ppv_account_id);
      end if;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status   := 'E';
      p_process_message  := 'DELIVER_RTR_PKG.ppv_account:' || SQLERRM ;
      fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 4 */
      return null;
  END ppv_account;

/*----------------------------------------------------------------------------------------*/
function include_cenvat_in_costing
(
    p_transaction_id               IN             NUMBER,
    p_process_message OUT NOCOPY VARCHAR2,
    p_process_status OUT NOCOPY VARCHAR2,
    p_codepath                     IN OUT NOCOPY VARCHAR2
)
return varchar2 is

  lv_ret_value        VARCHAR2(30);

  lv_destination_type             varchar2(30);
  lv_transaction_type             varchar2(30);
  lv_loc_subinv_type              JAI_RCV_TRANSACTIONS.loc_subinv_type%type;
  lv_debug                        varchar2(1);--File.Sql.35 Cbabu   := 'Y';
  lv_include_cenvat_in_costing    varchar2(1);

  ln_dlry_trx_id                  NUMBER;

  CURSOR c_receipt_cenvat_dtl(cp_transaction_id IN NUMBER) IS
    SELECT  nvl(unclaim_cenvat_flag, jai_constants.no)        unclaim_cenvat_flag,
            nvl(non_bonded_delivery_flag, jai_constants.no)   non_bonded_delivery_flag,
            nvl(cenvat_claimed_amt, 0)                        cenvat_claimed_amt
    FROM JAI_RCV_CENVAT_CLAIMS
    WHERE transaction_id = cp_transaction_id;

  CURSOR c_trx(cp_transaction_id number) is
    SELECT *
    FROM   JAI_RCV_TRANSACTIONS
    WHERE  transaction_id = cp_transaction_id;

  r_trx                   c_trx%ROWTYPE;
  r_dlry_trx              c_trx%ROWTYPE;
  r_base_trx              c_base_trx%ROWTYPE;

  r_receipt_cenvat_dtl    c_receipt_cenvat_dtl%ROWTYPE;

begin

  lv_debug   := 'Y';
  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_deliver_rtr_pkg.include_cenvat_in_costing', 'START'); /* 1 */

  OPEN c_trx(p_transaction_id);
  FETCH c_trx INTO r_trx;
  CLOSE c_trx;

  OPEN c_receipt_cenvat_dtl(r_trx.tax_transaction_id);
  FETCH c_receipt_cenvat_dtl INTO r_receipt_cenvat_dtl;
  CLOSE c_receipt_cenvat_dtl;

  IF r_receipt_cenvat_dtl.unclaim_cenvat_flag = 'Y' THEN
    p_codepath := jai_general_pkg.plot_codepath(1.1, p_codepath); /* 12 */
    lv_include_cenvat_in_costing :='Y';
    GOTO end_of_procedure;

  /* following is incorporated as part of non bonded delivery functionaliy
    if the condition is satisfied, then it means receipt line is not claimed and a non bonded delivery is done
    In this case Cenvat has to be costed.
    If non bonded flag is set after Claim Cenvat is done, then we need to pass/reverse the rg entries that are passed during
    RECEIVE for whatever applicable transactions
  */
  ELSIF r_receipt_cenvat_dtl.cenvat_claimed_amt = 0
    AND r_receipt_cenvat_dtl.non_bonded_delivery_flag = 'Y'
  THEN
    p_codepath := jai_general_pkg.plot_codepath(1.2, p_codepath); /* 12 */
    lv_include_cenvat_in_costing :='Y';
    GOTO end_of_procedure;

  END IF;

  IF r_trx.transaction_type = 'CORRECT' THEN
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    lv_transaction_type := r_trx.parent_transaction_type;
  ELSE
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    lv_transaction_type := r_trx.transaction_type;
  END IF;

  IF lv_transaction_type NOT IN ( 'DELIVER', 'RETURN TO RECEIVING') THEN
    /* this procedure is not valid for the transaction being processed */
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    RETURN 'X';
  END IF;

  IF lv_transaction_type = 'RETURN TO RECEIVING' THEN

    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
    ln_dlry_trx_id := jai_rcv_trx_processing_pkg.get_ancestor_id
                        ( r_trx.transaction_id, r_trx.shipment_line_id, 'DELIVER');

    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    OPEN c_trx(ln_dlry_trx_id);
    FETCH c_trx INTO r_dlry_trx;
    CLOSE c_trx;

    lv_destination_type   := r_dlry_trx.destination_type_code;
    lv_loc_subinv_type    := nvl(r_dlry_trx.loc_subinv_type, 'X');


  ELSE --DELIVER scenario.

    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
    lv_destination_type := r_trx.destination_type_code;
    lv_loc_subinv_type  := nvl(r_trx.loc_subinv_type, 'X');

  END IF; --End if for RETURN TO RECEIVING

  OPEN c_base_trx(p_transaction_id);
  FETCH c_base_trx INTO r_base_trx;
  CLOSE c_base_trx;

  if r_trx.organization_type = 'M'  THEN

    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);
    if r_trx.item_cenvatable = 'N' THEN

      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
      lv_include_cenvat_in_costing :='Y';

    elsif  r_trx.item_class in ('OTIN','OTEX') then

      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath);
      lv_include_cenvat_in_costing :='Y';

    /* modified the following condition by vijay Shankar for Bug#4179823
    elsif  r_base_trx.source_document_code <> 'REQ' and r_trx.item_class in ('FGIN', 'FGEX') then */
    elsif  r_base_trx.source_document_code <> 'RMA' and r_trx.item_class in ('FGIN', 'FGEX')
           and r_trx.organization_type = 'M'
    then
      p_codepath := jai_general_pkg.plot_codepath(9.1, p_codepath);
      lv_include_cenvat_in_costing :='Y';

    elsif lv_destination_type = 'INVENTORY' THEN

      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
      if r_trx.base_asset_inventory = 2 then

        p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
        if  r_trx.item_class not in ('CGIN','CGEX') then

          p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
          lv_include_cenvat_in_costing :='Y';

        elsif r_trx.item_class in ('CGIN','CGEX') then

          p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
          if lv_loc_subinv_type IN ('X','N') then
            p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
            lv_include_cenvat_in_costing :='Y';
          end if;

        end if; --end if for r_trx.item_class

      elsif r_trx.base_asset_inventory = 1 then

          p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
          if lv_loc_subinv_type IN ('X','N') then
            p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
            lv_include_cenvat_in_costing :='Y';
          end if;

      end if; --end if for r_trx.base_asset_inventory

    elsif lv_destination_type = 'EXPENSE' THEN

      p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
      if r_trx.item_class not in  ('CGIN','CGEX') then
        lv_include_cenvat_in_costing :='Y';
      end if;
    else
      p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */
      lv_include_cenvat_in_costing :='X';
    end if; --end if for r_trx.item_cenvatable='N'

  elsif r_trx.organization_type = 'T'  THEN

    p_codepath := jai_general_pkg.plot_codepath(19, p_codepath); /* 19 */
    if r_trx.item_trading_flag <> 'Y'
      or r_trx.item_excisable  <> 'Y'
      or r_trx.excise_in_trading <> 'Y'
    then
      p_codepath := jai_general_pkg.plot_codepath(20, p_codepath); /* 20 */
      lv_include_cenvat_in_costing :='Y';
    end if;

  else

    p_codepath := jai_general_pkg.plot_codepath(21, p_codepath); /* 21 */
    lv_include_cenvat_in_costing :='X';

  end if; --r_trx.organization_type = 'M'

  <<end_of_procedure>>

  if lv_include_cenvat_in_costing is null then
    p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); /* 22 */
    lv_include_cenvat_in_costing :='N';
  end if;

  p_codepath := jai_general_pkg.plot_codepath(23, p_codepath, null, 'END'); /* 23 */
  lv_ret_value := lv_include_cenvat_in_costing;

  return lv_ret_value;

exception
  when others then
    p_process_status   := 'E';
    p_process_message  := 'DELIVER_RTR_PKG.include_cenvat_in_costing:' || SQLERRM ;
    fnd_file.put_line( fnd_file.log, 'Error in '||p_process_message);
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 24 */
    return null;
end include_cenvat_in_costing;

END jai_rcv_deliver_rtr_pkg;

/
