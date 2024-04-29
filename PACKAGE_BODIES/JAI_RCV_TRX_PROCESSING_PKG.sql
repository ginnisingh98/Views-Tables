--------------------------------------------------------
--  DDL for Package Body JAI_RCV_TRX_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_TRX_PROCESSING_PKG" AS
/* $Header: jai_rcv_trx_prc.plb 120.25.12010000.13 2010/04/15 11:04:35 boboli ship $ */
/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_rcv_trx_processing_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     26/07/2004   Vijay Shankar for Bug# 3496408, Version:115.0
                    This Package is coded for Corrections Enhancement to invoke CENVAT and RG related insert APIs for PO Functionality.

          - PROCESS_BATCH
             Main procedure that is called from JAINRVCTP Concurrent Program. All the Concurrent Program Parameters are Optional,
             in the sence that all the unprocessed and Pending Receipt Transactions will be Picked up for processing. Calls different
             APIs to process the transaction and pass Localization Related Accounting, Cenvat and RG Entries
             This procedure doesnot COMMIT the data if it is called from an Application

          - PROCESS_TRANSACTION
             Driving procedure that validates the transaction processing and if eligible, then calls different API's based on
             trasaction type for processing. This should never be invoked directly as this needs data in JAI_RCV_TRANSACTIONS and which
             is populated in batch procedure only.
          - POPULATE_DETAILS
             UPDATEs JAI_RCV_TRANSACTIONS with details(transaction,setup, validity) of the transaction that will be used
             while processing the transaction
          - VALIDATE_TRANSACTION
             Validates applicability of Transaction for Normal and Cenvat Accounting, RG Processing. Finally after validation, updates
             process_flag, cenvat_rg_flag, messages of JAI_RCV_TRANSACTIONS with relevant details. Further these values are used
             to decide whether to proceed or not for Accounting and Cenvat processing
          - PROCESS_ISO_TRANSACTION
             RETURNs true if ISO Entries needs to be passed for transaction, else returns false. This is basically an applicability func.
          - GET_ANCESTOR_ID
             RETURNs the transaction_id of PARANT transaction type required for the current transaction
          - GET_APPORTION_FACTOR
             RETURNs the factor that should be used for multiplication with transaction Quantity and JAI_RCV_LINE_TAXES.tax amount to
             get the transaction tax amount
          - GET_TRXN_CENVAT_AMOUNT
             RETURNs the transaction EXCISE Amount
          - GET_TRXN_TAX_AMOUNT
             RETURNs the transaction total TAX Amount (Excluding Modvat Recovery, TDS)
        Other Procedures/Functions are coded for simplicity of the APPLICATION logic

2     26/10/2004   Vijay Shankar for Bugs#3927371,3949109,3949502  Version:115.1
          Bugs#3927371 - Code modified to PROCESS only CORRECT, DELIVER and RTR transactions in PROCESS_TRANSACTIONS procedure
           Code modified to return back ERROR Status only if any error (i.e process_status='E') occurs during Processing.
           If process_status is 'X', then Normal Status is return back by just printing an Information Message in Log
          Bugs#3949109 - added code in POPULATE_DETAILS to fetch subinventory from DELIVER transaction incase of direct delivery if the RECEIVE transaction
           donot have either of location_id or subinventory attached with it
          Bugs#3949502 - For a CORRECT of DELIVER transaction Subinventory is not getting populated, which is Stopping Accounting
           of CORRECT transaction. this is resolved by fetching Subinventory from parent DELIVER and use it for processing

3     18/12/2004   Vijay Shankar for Bug# 4038024, 4070938, 4038044.    FileVersion: 115.2
          Bug#4038024, 4038044
           Modified the code in populate_details to fetch Subinventory/location from parent transaction if it is not present in
           the current transaction
          Bug#4070938
           Modified the value contained in the Package Variable NO_ITEM_CLASS to contain OTIN instead of 'XXXX'. This would mean
           that, if there is no item attached to Receipt Line or if this is a non localization item, then it is treated as OTIN item

4     03/01/2005   Vijay Shankar for Bug# 3940588, Version:115.3

             Following are the changes made for the purpose of RECEIPTsDEPLUG of Old Code and link it with New Corrections Code
             - Added the procedures/functions
               - PROCESS_DEFERRED_CENVAT_CLAIM : Will be invoked when request for JAINRVCTP is submitted from JAINMVAT form.
                 This is coded to process records of JAI_RCV_CENVAT_CLAIM_T table that needs to be claimed/unclaimed.
                 Incase of Unclaim, the transactions that are not yet processed/pending for claim or excise is not included in
                 cost are processed for Cenvat Costing. This happens for DELIVER, RTR and related CORRECTIONS
               - GET_EQUIVALENT_QTY_OF_RECEIVE : Function that Returns quantity equivalent to RECEIVE UOM. Useful incase there
                 are changed between RECEIVE and other receiving transactions
               - TRANSACTION_PROPROCESSOR      : when Called for all RECEIVE and MATCH transactions, this does initial processing of
                 shipment line which will be used for all receiving transactions. Also this is place for other transactions also
                 where in initial processing has to happen for any transaction before going ahead for actual processing.
                 This inserts data into JAI_RCV_CENVAT_CLAIMS, JAI_CMN_RG_OTHERS tables for Cenvat and Cess Amounts
               - TRANSACTION_POSTPROCESSOR     : Does the post processing logic like updating some quantity columns at shipment
                 line level for DELIVER, RTR, RTV and related CORRECTs
             - Increased the filtering condition for transactions processing by adding p_shipment_header_id and p_shipment_line_id
             parameters to PROCESS_BATCH procedure
             - Modified CURSORs c_trxns_to_populate_dtls and c_get_transactions of PROCESS_BATCH, to pickup only those transactions
             where in users cannot modify the taxes anymore
             - UPDATEs JAI_RCV_LINES with tax_modified_flag as 'N' so that taxes for that line cannot be modified anymore
             when p_called_from is JAINPORE (Localization Receipts form)
             - Calls to transaction_preprocessor and transaction_postprocessed are made to do processing required before and after
             actual processing
             - Changes in PROCESS_TRANSACTION procedure
               - Opened up the code to execute procedure for all localization supported receiving transactions
               - Modified the condition which if satisfied makes a call to jai_rcv_excise_processing_pkg.process_transaction
               - Added p_process_special_reason, p_process_special_qty parameters in call to jai_rcv_excise_processing_pkg.process_transaction
             - Modified POPULATE_DETAILS procedure to populate tax_transaction_id and third_party_flag values. Tax_Transaction_id is the
             transaction_id related to parent transaction for which taxes are defaulted/attached. usually this is either RECEIVE or MATCH trx
               - Also changes are made to update ja_in_rcv_transaction.transaction_type to RECEIVE incase of MATCH transaction
             - Modifed VALIDATE_TRANSACTION to function properly. In this procedure different validations are applied that are
             required for NON-CENVAT and CENVAT processing of transactions
             - get_ancestor_id modified to support MATCH transaction also

             - Changes required for Education CESS are done in all procedures/functions to consider CESS taxes also whereever
             Excise and CVD taxes are referred

 5.    09/02/2005  Vijay Shankar for Bug #4172424, Version 115.4
             Issue -
                RG23 D register / accounting entries are not happening
                  (i) if the item class is FGIN/FGEX
                  (ii) if the Claim Cenvat on Receipt flag on receipt is not filled in or set to NO.
             Fix -
                Following changes have been -
                  (i)   Changed the cursor - c_receipt_cenvat_dtl.
                        Added in Input parameter - cp_organization_type.
                        Select for the column online_claim_flag is changed from online_claim_flag to
                        decode(cp_organization_type, 'M', online_claim_flag, jai_constants.yes)
                  (ii)  While opening the cursor c_receipt_cenvat_dtl, passed the additional parameter
                        r_trx.organization_type
                  (iii) In the If condition after lv_statement_id := 27, added the condition -
                        and r_trx.organization_type = 'M'

6.     17/02/2005  Vijay Shankar for Bug#4171469, Version: 115.5
                    changes are made in process_iso_transaction Function as given below to return NOT TO PROCESS ISO if it is
                    a trading to trading and both the orgs have excise_in_rg23d flag as 'Y'


7     23/02/2005   Vijay Shankar for Bug#4179823,   FileVersion:115.6
                   Modified an IF condition in validate_transaction procedure to allow FGIN items in case of RMA Receipts.
                   Previously it is allowing for ISO receipts only incase of FGIN items which is wrong

8     28/02/2005   Vijay Shankar for Bug#4208224,4215402   FileVersion:115.7

                    Bug#4208224
                     The concept of commit interval is giving FETCH OUT OF SEQUENCE Error as we are using FOR UPDATE OF clause
                     for main cursors after RECEIPTS DEPLUG. So, the commit interval concept is removed with this bugfix

                    Bug#4215402
                     Signature of the function get_accrue_on_receipt is modified to accept po_line_location_id also, because there
                     can be cases where a call to this procedure can pass a null value for po_distribution_id and thus returns a
                     wrong value to caller. this happens in case of receiving of non inventory items.
                     So a new parameter is added, which is used to pick the accrue_on_receipt_flag from po_line_locations_all table
                     if po_distribution_id is null

9     19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.8
                    .added two new parameter in validate_transaction to hold the process_vat flag and message.
                    .made a call to jai_rcv_rgm_claims_pkg.insert_rcv_lines in transaction preprocessor
                    .made a call to jai_rcv_rgm_claims_pkg.process_vat based on vat flag. this will do required processing
                     before vat claim happens
                    .added required validation in VALIDATE_TRANSACTION for vat processing and set correct values to process_vat_status
                     and related message
                    .added process_vat_status filter in main cursor c_get_transactions to fetch unprocessed VAT transactions

10    25/03/2005   Vijay Shankar for Bug#4250171. Version: 115.9
                    Following changes are made to make VAT Functionality work for OPM Receipts
                     .transaction_preprocessor is not invoked
                     .started updating ja_in_rcv_transaction which is not done in previous version of this object
                     .location_id logic execution is stopped if it is OPM Receipt as there might have been already a value
                      for this column in the record being processed
                     .process_status and cenvat_rg_flag variables are made 'X' in validate transaction if OPM RECEIPT

11    01/04/2005   Vijay Shankar for Bug#4278511. Version:115.10
                    Incase of ISO receipts, location_id has to be derived from SUBINVENTORY attached to the transaction if present, otherwise
                    we need to fetch location of RCV_TRANSACTONS. Code is modified in populate_details procedure

12    12/04/2005   Harshita for Bug#4300708. Version:116.0 (115.11)
                   When a new receipt gets created, it takes some time for the RTP concurrent to complete and the receipt to
                   get generated. Meanwhile, the customer is clicking on the 'NEW' button and proceeding with
                   the creation of a new receipt.
                   Thus accounting entries for these receipt would not be generated as the concurrent
                   'India - Receiving Transactions Processor' does not get fired. The India - RTP concurrent currently fires
                   only after the receipt gets generated in the Receipts Localized screen and the user either closes the form
                   or clicks on the 'NEW' button.
                   To overcome this issue, The concurrent 'India - Receiving Transactions Processor' has been
                   scheduled. The parameter of the concurrent 'P_CALLED_FROM' has been made visible and
                   defaulted to 'JAINPORE'. The concurrent has been updated to account all the receipts at
                   the organization level when it is called from JAINPORE and the shipemnt_header_id is null.

13  10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                  Code is modified due to the Impact of Receiving Transactions DFF Elimination
                 Code added to implement the functionality of Tax Invoice Generation by grouping the RTV's based
                 on Orgn, Loc, Vendor and site. New procedure process_rtv is written for this functionality and
                 linked to JAITIGRTV concurrent

              * High Dependancy for future Versions of this object *

14  19/05/2005  rallamse for Bug#4336482, Version 116.1
                For SEED there is a change in concurrent "JAINRVCTP" to use FND_STANDARD_DATE with STANDARD_DATE format
                Procedure ja_in_rg_rounding_pkg.do_rounding signature modified by converting p_transaction_from, p_transaction_to
                of DATE datatype to pv_transaction_from, pv_transaction_to of varchar2 datatype.
                The varchar2 values are converted to DATE fromat using fnd_date.canonical_to_date function.

15 08-Jun-2005  File Version 116.3. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                as required for CASE COMPLAINCE.

16. 13-Jun-2005 Ramananda for bug#4428980. File Version: 116.4
                Removal of SQL LITERALs is done

17. 17-Jul-2005 Sanjikum for Bug#4495135, File Version 117.1
                Following changes are done in procedure  - populate_details
                1) Added the variable - ln_tax_apportion_factor and populated the same using - get_apportion_factor(p_transaction_id)
                2) Added the call to jai_rcv_transactions_pkg.update_row to update jai_rcv_transactions.tax_apportion_factor

18. 27/07/2005  Ramananda for Bug#4516577, Version 120.2
                Problem
                -------
                   ISO Accounting Entries from Trading to Excise bonded inventory are not generated in case of following Scenarios
                   1. Trading organization to Trading Organization (only  Source organizations with the 'Excise in RG23D' setup).
                   2. Trading organization to Manufacturing Organization (Source Organization with the 'Excise in RG23D' setup).

                   Fix
                   ---
                   In the function - process_iso_transaction, made the following changes
                   1. In the If condition -
                      " IF r_src_org.excise_in_rg23d <> 'Y' OR r_dest_org.excise_in_rg23d <> 'Y' THEN"
                      removed the second part of the OR "r_dest_org.excise_in_rg23d <> 'Y'"

                   2. In the If condition - "ELSIF r_dest_org.manufacturing = 'Y' THEN"
                      Added the If condition - "IF r_src_org.excise_in_rg23d <> 'Y' THEN"
                      for the statement - lb_process_iso_transaction := false;

                   Dependency Due to This Bug
                   --------------------------
                   jai_rcv_rcv_rtv.plb (120.3)
                   jai_om_rg.plb       (120.2)

16. 01-Aug-2005  Ramananda for Bug#4519697, File Version 120.3
                 1) In the procedure - process_transaction, moved the cursor - c_trx, before calling validate_transaction
                 2) In the procedure - process_transaction, Variables - lv_process_vat_flag, lv_process_vat_message are
                    assigned value before calling validate_transaction
                 3) In the procedure - validate_transaction, added the following condition -
                    "if p_process_vat_flag = jai_constants.successful THEN
                      goto end_of_vat_validation;
                    end if;"

                Column process_vat_flag changed to process_vat_status (jai_rcv_transactions).
                This issue is identified while compiling the object as a part of this fix.

                Dependency due to this Bug
                --------------------------
                jai_rcv_rt_t1.sql (120.2)
                jai_rcv_tax.plb   (120.3)

17. 28/06/2005   Ramananda for Bug#4519719, File Version 120.4
                 Issue : A call to jai_rcv_rgm_claims_pkg.insert_rcv_lines is made even though there
                         do not exist any VAT type of taxes in the receipt.
                 Fis   : Added a condition to check if VAT type of taxes exist in the receipt
                         before the call to jai_rcv_rgm_claims_pkg.insert_rcv_lines

                 Dependency due to this bug:-
                 jai_rcv_rgm_clm.plb (120.2)

18. 01/09/2005  Bug4586752. Added by Lakshmi gopalsami Version 120.5
                Assigned the value of location_id in populate_details
    and used for populating jai_rcv_transactions
    Dependency (Functional)
    ----------------------
    JAIRGMCT.fmb             120.2
    JAIRGMPT.fmb             120.3
    JAIRGMSG.fmb             120.2
    jai_rcv_trx_prc.plb      120.5

19. 02-Sep-2005 Bug4589354. Added by Lakshmi Gopalsami version 120.3
                Commented the following condition.
                OR (r_base_trx.source_document_code = 'REQ' and

                Dependencies :
                jai_rcv_trx_prc.plb  120.6
                jai_rcv_rgm_clm.plb  120.3

20. 26-May-2006 Sanjikum for Bug#4929410, File Version 120.7
                1) Changes done related to performance

21. 17-Jul-2006 Aiyer for the bug 5378630 , File Version 120.6
                      Issue:-
                        India Receiving transaction processor fails during validation phase for RMA
                        type of transactions.

                      Fix:-
                       Converting the reference of RMA TYPE "FG RETURN" into "GOODS RETURN" as FG return is not as per the abbreviation
                       standard

22. 30-OCT-2006 SACSETHI for bug 5228046, File version 120.2
                Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                This bug has datamodel and spec changes.

23. 13-FEB-2007 Vkaranam for bug 4636397,File Version 120.14
                Forward porting the change in 11i bug 4626571 (India Localization- Unordered Receitps-50% Gets Hit Without Claiming Modvat).
                Changes are done in get_ancestor_id function.

24. 16-Feb-2007 srjayara for bug 5064235 -- forward porting for bug# 5054114 in 11i
    File version 120.15
                Issue : The subinventory's location_id is not getting populated in ja_in_rcv_transactions for
                        'RECEIVE' line
                Fix :  The subinventory's location_id will be populated in ja_in_rcv_transactions for 'RECEIVE' line
                       by fetching the subinventory from rcv_transactions 'DELIVER' line.
25. 21-Feb-2007 CSahoo for BUG 5344225, File Version 120.16
                Forward porting of 11i BUG 5343848
                Added two input parameters p_request_id,p_group_id to the procedure process_batch.
                Added a parameter request_id Default null
                If the request_id is not null
                 Called the fnd_concurrent.wait_for_request_id .
                This call will wait till the RVCTP concurrent is completed.

                Added a parameter group_id Default null
                If the group_id is not null
                 Run a infinite loop till the data in rcv_transactions_interface table
                 is purged for the particular group_id.

                The rest of the code in the concurrent is processed only after
                    the data is purged.

16/04/2007 Kunkumar for bugno 5989740
           forward porting to R12 filename:ja_in_receipt_transactions_pkg.sql version 115.42.6107.2


26.   10/05/2007   bgowrava for forward porting Bug#5756676, 11i bug#5747013. File Version :120.18
                   Issue : QTY REGISTER SHOULD BE UPDATED ON RECEIVE DEPENDING ON SETUP
                     Fix : Changes are made to hit the Qty register independent of the Amount register.
                           This would happen in following cases:
                            i) In case of deferred claim, the Qty register would be hit at RECEIVE or MATCH.
                               Previously it was at CLAIM only. Decision to hit the Qty register at RECEIVE
                               or CLAIM would be made depending on Setup.
                           ii) For an excisable item, if there are no taxes attached then the Qty register
                               would be hit. Previously the Qty register was hit at the time of CLAIM and
                               CLAIM can be done only if there are taxes.

                                A spec variable lv_online_qty_flag is set depending on the above conditions.
                                The changes are made in validate_transaction procedure for this.
                                Changes are made in process_transaction to hit the Qty register if lv_online_qty_flag
                                is set to Y.

                         The changes are made on top of 115.34 as 115.35 is obsolete.

                         Dependency Due to this Bug : Yes.

27.   10/05/2007   bgowrava for forward porting Bug#5756676, 11i bug#5747013. File Version :120.18
                   Issue : QTY REGISTER SHOULD BE UPDATED ON RECEIVE DEPENDING ON SETUP
                     Fix : The variable which has the count of excise taxes was used before
                           the cursor was used to fetch the value and so the count is always coming as zero.
                           Now moved the cursor position.

28.   10/05/2007   bgowrava for forward porting Bug#5756676, 11i bug#5747013. File Version :120.18
                   Issue : QTY REGISTER SHOULD BE UPDATED ON RECEIVE DEPENDING ON SETUP
                     Fix : If the organization , location combination does not have any setup for
                           "Update Qty Register Event" then we should get the setup value from
                           NULL site. To do this we were checking if cur_qty_setup%NOTFOUND for location id.
                           This would never be true as the cursor would fetch a record. Now modified this
                           to lv_qty_upd_event IS NULL. If this is NULL then we will fetch it from NULL site.


29.   14-05-2007   ssawant for bug 5879769, File Version 120.19
       Objects was not compiling. so changes are done to make it compiling.

30.   04/06/2007  sacsethi for bug 6109941  File Version 120.20

       CODE REVIEW COMMENTS FOR ENHANCEMENTS

       Problem- Code related to cenvat amount was wrongly commented

31.    21/06/2007  rchandan for bug#6109941, File Version 120.21

       Issue: Code review for enhancements(ER bug#5747013)
         Fix: removed the decalaration of lv_online_qty_flag as it is already decalred in the spec and
              added a nvl check in an if condition.

32.  01-08-2007  rchandan for bug#6030615 , Version 120.23
                 Issue : Inter org Forward porting

33.  05-JAN-2009   Bug 7662347 File version 120.11.12000000.4 / 120.25.12010000.2 / 120.26
                   Issue : RG23 Part I register is not hit during RTV when there are no excise taxes.
                   Fix   : Changed the code so that lv_online_qty_flag will be Y for the RTV transactions
                           also, for receipts which do not have excise taxes. Also added a variable
                           lv_qty_register_entry_type in the process_transaction procedure so that the
                           quantity register will be hit with proper sign.

34. 30-Mar-2009  Bug 8346068 Version  120.11.12000000.5
         Issue: CENVAT UNCLAIMED AFTER DELIVERY OF ITEMS IS NOT LOADED TO ITEM COST
         Fix : commented the below condition
         * and attribute1 = jai_rcv_deliver_rtr_pkg.cenvat_costed_flag  *
         in the cursor c_trxs_for_unclaim.

35.  28-APR-2009   Bug 8410609
                   Issue - Excise invoice number is getting generated for Return To Vendor transactions
                           of OSP items.
                   Expected Behavior - Excise invoice should not be generated for RTV of OSP items. They
                                       are tracked using 57F4 challan.
                   Fix - Added the condition "AND Check_57F4_transaction(rtv_rec.transaction_id) <> 'YES'"
                         in PROCESS_RTV procedure for the generation of excise invoice number.

36.   15-JUN-2009    Bug 8319304  File version 120.11.12000000.7 / 120.25.12010000.5 / 120.29
                                Description : Forward porting of bugs 6914674 and 8314743. Modified the validate_transaction procedure
                                                  so that quantity registers would be hit when the item is excisable, and has excise taxes but with
                                                  recoverable amounts as zero.

37.    21-May-2009   Bug 8538155 (FP for bug 8466620) File version 120.11.12000000.8 / 120.25.12010000.6 / 120.30
                     Issue : Quantity register entry is not reversed during Deliver, when destination is
                               Expense and  the receipt does not have excise taxes.
                     Fix   : As per inputs from PM, fix is done using these guidelines:
                             1. Quantity register should not be hit during Receive, when destination is
                                Expense.
                             2. There should not be any entries in the amount register with zero amount.
                             3. If quantity register gets updated (due to Claim done by mistake), it should
                                be reversed when Deliver happens.

                             Necessary changes are done in validate_transaction procedure.

38.   10-Aug-2009   Bug 8319304 File version 120.11.12000000.9 / 120.25.12010000.7 / 120.31
                               Fixed review comments - ported the missing changes in process_transaction procedure for bug 6914674.

39   09-Aug-2009   Bug 8648138
                   Issue - If excise tax is unclaimed after running "Mass Addtions Create" program, the
                           unclaimed amount does not flow to assets when "Mass Additions Create" is run
                           again.
                   Fix   - Added code in process_deferred_cenvat_claim procedure to update related flags in
                           ap_invoice_distributions_all for the matched invoices so that the tax distributions will
                           be picked up by the "Mass Additions Create" program.

40   23-Oct-2009   Bug 9032251 File version 120.11.12000000.12 / 120.25.12010000.10 / 120.34
                   Issue - If the receipt line has excise and vat taxes, and excise is unclaimed after
                   vat is unclaimed, costing entries are not generated for the exicse (cenvat) taxes.
                   Fix - Commented the "and (attribute2 IS NULL or attribute2 <> jai_constants.yes)"
                   condition in c_trxs_for_unclaim cursor in process_deferred_cenvat_claim procedure.

41.  26-Oct-2009   CSahoo for bug#9019561, File Version 120.11.12000000.13
                   Issue: NON RECOVERABLE TAXES ON PO ,IF CLAIMED FOR CENVAT IT IS HITTING THE EX.REGISTER
                   Fix: Made the changes in the procedure validate_transaction. Added the check that for trading
                   org, if there is no recoverable excise tax, then it would update the p_cenvat_rg_flag as 'X'.
                   In such case, the cenvat won't hit the registers.

42.  01-dec-2009  vkaranam for bug#7595016,File version  120.11.12000000.14
                  Issue:
		  RG23D NOT UPDATED AFTER RECEIVING THE ITEMS IN TRADING ORG. AT MODVAT LOCATION.
                   Fix:
                   For a trading org RG23D shall be hit if the item is excisable and the receipt
                   transaction has the excise taxes irrespective of whether the tax amount is 0
                   or not.
		   Cause for the issue:
		   Validate_transaction procedure :
		   if r_taxes.excise_cnt = 0 or r_receipt_cenvat_dtl.cenvat_amount = 0 then
		     lv_codepath := jai_general_pkg.plot_codepath(18, lv_codepath);
		    p_cenvat_rg_flag        := 'X';
		     p_cenvat_rg_message     := 'Excise Taxes do not exist';
		     goto end_of_cenvat_flag_validation;
		    end if;
		   Change details:
		   Added organization_type condition
		   --if r_taxes.excise_cnt = 0 or(r_trx.organization_type='M' and r_receipt_cenvat_dtl.cenvat_amount = 0	)


43.  15-Apr_2010  Bo Li  For bug9305067 Replace the old attribute_category columns for JAI_RCV_TRANSACTIONS
                                        with new meaningful one

Dependancy:
-----------
----------------------------------------------------------------------------------------------------------------------------*/

/* following procedure added by Vijay Shankar for Bug#3940588 */
PROCEDURE transaction_preprocessor(
  p_shipment_line_id    IN  NUMBER,
  p_transaction_id      IN  NUMBER,
  p_process_status      IN  OUT NOCOPY VARCHAR2,
  p_process_message     IN  OUT NOCOPY VARCHAR2,
  p_simulate_flag       IN  VARCHAR2 --File.Sql.35 Cbabu   DEFAULT 'N'
) IS

--added by ssawant
  CURSOR cur_qty_setup( cp_organization_id NUMBER,cp_location_id     NUMBER)
        IS
        SELECT quantity_register_update_event
                FROM JAI_CMN_INVENTORY_ORGS
         WHERE organization_id = cp_organization_id
                 AND location_id     = cp_location_id ;


--added by ssawant
CURSOR c_base_trx(cp_transaction_id IN NUMBER) IS
    SELECT shipment_header_id, shipment_line_id, transaction_type, quantity, unit_of_measure, uom_code,
      parent_transaction_id, organization_id, location_id, subinventory, currency_conversion_rate,
      attribute_category attr_cat, nvl(attribute5, 'XX') rma_type, nvl(attribute4, 'N') generate_excise_invoice
      , routing_header_id   -- porting of Bug#3949109 (3927371)
      , attribute3  online_claim_flag, source_document_code, po_header_id   -- Vijay Shankar for Bug#3940588
      , po_line_location_id
    FROM rcv_transactions
    WHERE transaction_id = cp_transaction_id;

  r_trx                   c_trx%ROWTYPE;
  r_base_trx              c_base_trx%ROWTYPE;
  r_tax                   jai_rcv_excise_processing_pkg.tax_breakup;

  ln_cenvat_amount        NUMBER;
  ln_other_cenvat_amt     NUMBER;
  lv_breakup_type         VARCHAR2(10);

  -- Bug 5581319. Added by Lakshmi Gopalsami
  -- Increased the size of lv_localpath from 100 to 2000.
  --
  lv_localpath            jai_rcv_transactions.codepath%TYPE; --VARCHAR2(2000);    --File.Sql.35 Cbabu  := '';
  ln_dup_chk              NUMBER;   --File.Sql.35 Cbabu  := 0;

  lv_process_status       VARCHAR2(2);
  lv_process_message      VARCHAR2(1000);





  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
  r_excise_invoice_no     c_excise_invoice_no%ROWTYPE;

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_trx_processing_pkg.transaction_preprocessor';

   -- added, Ramananda for bug # 4519719
  CURSOR c_vat_exists(cp_shipment_line_id NUMBER )
  IS
    SELECT 1
    FROM JAI_RCV_LINE_TAXES a ,  jai_regime_tax_types_v b
    WHERE  shipment_line_id = cp_shipment_line_id AND
    b.regime_code= jai_constants.vat_regime
    and b.tax_type = a.tax_type ;

 ln_vat_exists NUMBER ;
 -- ended, Ramananda for bug # 4519719

BEGIN

  lv_localpath   := '';
  ln_dup_chk     := 0;

  OPEN c_trx(p_transaction_id);
  FETCH c_trx INTO r_trx;
  CLOSE c_trx;

  IF r_trx.transaction_type IN ('RECEIVE', 'MATCH') THEN

    select count(1) into ln_dup_chk
    from JAI_RCV_CENVAT_CLAIMS
    where transaction_id = r_trx.transaction_id;

    IF ln_dup_chk > 0 THEN
      return;
    END IF;

    IF r_trx.organization_type = 'T' THEN
      lv_breakup_type := 'RG23D';
    END IF;

    jai_rcv_excise_processing_pkg.get_tax_amount_breakup(
        p_shipment_line_id  => r_trx.shipment_line_id,
        p_transaction_id    => r_trx.transaction_id,
        p_curr_conv_rate    => r_trx.currency_conversion_rate,
        pr_tax              => r_tax,
        p_breakup_type      => lv_breakup_type,
        p_codepath          => lv_localpath
    );

    -- Uncommented for bug 6109941
    ln_cenvat_amount    := r_tax.basic_excise +
                           r_tax.addl_excise +
         r_tax.other_excise +
         r_tax.cvd +
         r_tax.addl_cvd  ; -- Modified by SACSETHI Bug# 5228046
               -- Forward porting the change in 11i bug 5365523
               -- (Additional CVD Enhancement) as part of the R12 bug 5228046

    ln_other_cenvat_amt := r_tax.excise_edu_cess +
                           r_tax.cvd_edu_cess+
         r_tax.sh_exc_edu_cess +
                           r_tax.sh_cvd_edu_cess;    --Added by kunkumar for forward porting  bug#5907436  to R12


    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    OPEN c_excise_invoice_no(r_base_trx.shipment_line_id);
    FETCH c_excise_invoice_no INTO r_excise_invoice_no;
    CLOSE c_excise_invoice_no;

    -- even if there is no excise, then the data goes into this table. previous code doesnt insert data into this table
    -- if excise taxes are not present for a line
    INSERT INTO JAI_RCV_CENVAT_CLAIMS(
      transaction_id, shipment_line_id, cenvat_amount, cenvat_claimed_ptg, cenvat_sequence,
      other_cenvat_amt, other_cenvat_claimed_amt, creation_date, created_by, last_update_date,
      last_updated_by, last_update_login,
      online_claim_flag,
      vendor_changed_flag
    ) VALUES (
      r_trx.transaction_id, r_trx.shipment_line_id, ln_cenvat_amount, 0, 0,
      ln_other_cenvat_amt, 0, sysdate, fnd_global.user_id, sysdate,
      fnd_global.user_id, fnd_global.login_id,
      r_excise_invoice_no.online_claim_flag, -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. nvl(r_base_trx.online_claim_flag, jai_constants.no),
      jai_constants.no
    );

    -- Vijay Shankar for Bug#3940588 EDUCATION CESS
    IF r_tax.excise_edu_cess <> 0 THEN
      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
          p_source_register     => jai_constants.reg_receipt_cenvat,
          p_source_register_id  => r_trx.transaction_id,
          p_tax_type            => jai_constants.tax_type_exc_edu_cess,
          p_credit              => r_tax.excise_edu_cess,
          p_debit               => null,
          p_process_status      => p_process_status,
          p_process_message     => p_process_message
       );
    END IF;

    IF p_process_status = 'E' THEN
      RETURN;
    END IF;
/*Added by kunkumar for forward porting bug#5989740, start*/
    IF r_tax.sh_exc_edu_cess <> 0 THEN
                     jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
                          p_source_register     => jai_constants.reg_receipt_cenvat,
                          p_source_register_id  => r_trx.transaction_id,
                          p_tax_type            => jai_constants.tax_type_sh_exc_edu_cess,
                          p_credit              => r_tax.sh_exc_edu_cess,
                          p_debit               => null,
                          p_process_status      => p_process_status,
                          p_process_message     => p_process_message
                       );
                    END IF;

                    IF p_process_status = 'E' THEN
                      RETURN;
                    END IF;

                    IF r_tax.sh_cvd_edu_cess <> 0 THEN
                    jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
                          p_source_register     => jai_constants.reg_receipt_cenvat,
                          p_source_register_id  => r_trx.transaction_id,
                          p_tax_type            => jai_constants.tax_type_sh_cvd_edu_cess,
                          p_credit              => r_tax.sh_cvd_edu_cess,
                          p_debit               => null,
                          p_process_status      => p_process_status,
                          p_process_message     => p_process_message
                       );
                    END IF;

                    IF p_process_status = 'E' THEN
                      RETURN;
        END IF;
        /*Added by kunkumar for 5989740, end*/



    IF r_tax.cvd_edu_cess <> 0 THEN
      jai_rcv_excise_processing_pkg.other_cenvat_rg_recording(
          p_source_register     => jai_constants.reg_receipt_cenvat,
          p_source_register_id  => r_trx.transaction_id,
          p_tax_type            => jai_constants.tax_type_cvd_edu_cess,
          p_credit              => r_tax.cvd_edu_cess,
          p_debit               => null,
          p_process_status      => p_process_status,
          p_process_message     => p_process_message
       );
    END IF;

    IF p_process_status = 'E' THEN
      RETURN;
    END IF;

   -- added, Ramananda for bug # 4519719
      OPEN c_vat_exists(p_shipment_line_id) ;
      FETCH c_vat_exists INTO ln_vat_exists ;
      CLOSE c_vat_exists ;

      IF ln_vat_exists = 1 THEN

        /* Call added for VAT Implementation. Vijay Shankar for Bug#4250236(4245089) */
        jai_rcv_rgm_claims_pkg.insert_rcv_lines(
          p_shipment_header_id    => null,
          p_shipment_line_id      => p_shipment_line_id,
          p_transaction_id        => p_transaction_id,
          p_regime_code           => jai_constants.vat_regime
          , p_process_status      => p_process_status,
          p_process_message       => p_process_message,
          p_simulate_flag => p_simulate_flag
        );

        IF p_process_status <> jai_constants.successful THEN
          p_process_status := 'E';
          RETURN;
        END IF;
      END IF ;
    -- ended, Ramananda for bug # 4519719
    /*
    Did not handle UOM Conversion between the Transaction Quantities

    JA_IN_RCV_CENVAT_PKG.insert_row(
      p_shipment_line_id              => p_shipment_line_id ,
      p_tax_transaction_id            => r_trx.tax_transaction_id,
      p_tax_qty                       => r_trx.quantity,
      p_tax_qty_uom_code              => r_trx.uom_code,
      p_receipt_num                   => r_trx.receipt_num,
      p_receipt_date                  => r_trx.transaction_date,
      p_excise_invoice_no             => r_trx.excise_invoice_no,
      p_excise_invoice_date           => r_trx.excise_invoice_date,
      p_basic_excise                  => ln_basic,
      p_addl_excise                   => ln_addl,
      p_cvd                           => ln_cvd,
      p_other_excise                  => ln_other,
      p_cenvat_claimed_ptg            => 0,
      p_cenvat_claimed_amt            => 0,
      p_claimable_flag                => null,
      p_receive_qty                   => 0,
      p_receive_corr_qty              => null,
      p_deliver_bonded_qty            => null,
      p_deliver_nonbonded_qty         => null,
      p_deliver_corr_bonded_qty       => null,
      p_deliver_corr_nonbonded_qty    => null,
      p_rtr_bonded_qty                => null,
      p_rtr_nonbonded_qty             => null,
      p_rtv_qty                       => null,
      p_rtv_corr_qty                  => null,
      p_excise_vendor_id              => null,
      p_excise_vendor_site_id         => null,
      p_called_from                   => 'jai_rcv_trx_processing_pkg.transaction_preprocessor',
      p_simulate_flag                 => p_simulate_flag,
      p_process_status                => p_process_status,
      p_process_message               => p_process_status
    );
    */

  END IF;

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END transaction_preprocessor;

/* following procedure added by Vijay Shankar for Bug#3940588 */
PROCEDURE transaction_postprocessor(
  p_shipment_line_id    IN      NUMBER,
  p_transaction_id      IN      NUMBER,
  p_process_status      IN OUT NOCOPY VARCHAR2,
  p_process_message     IN OUT NOCOPY VARCHAR2,
  p_simulate_flag       IN      VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'N',
  p_codepath            IN OUT NOCOPY VARCHAR2
) IS

  r_trx                 c_trx%ROWTYPE;
  r_base_trx            c_base_trx%ROWTYPE; --added by rchandan for Bug#6030615
  ln_cenvat_amount      NUMBER;
  ln_cenvat_claimed_ptg NUMBER;

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_trx_processing_pkg.transaction_postprocessor';

BEGIN


  FND_FILE.put_line(FND_FILE.log, '^Trx Post Processor');

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'receipt_transactions_pkg.trx_post_proc', 'START');

  OPEN c_trx(p_transaction_id);
  FETCH c_trx INTO r_trx;
  CLOSE c_trx;

  IF r_trx.transaction_type IN ('RECEIVE','MATCH') THEN

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath);
    -- Cenvat Claim is not required for the transaction if the following if condition is satisfied
    IF r_trx.cenvat_rg_status NOT IN ('Y', 'P', 'E') THEN

      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath);
      IF r_trx.item_class IN ('FGIN', 'FGEX') THEN
        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath);
        ln_cenvat_amount := 0;
        ln_cenvat_claimed_ptg := 0;
      END IF;

      UPDATE JAI_RCV_CENVAT_CLAIMS
      SET cenvat_amount = nvl(ln_cenvat_amount, cenvat_amount),
          other_cenvat_amt = nvl(ln_cenvat_amount, other_cenvat_amt),
          cenvat_claimed_ptg = nvl(ln_cenvat_claimed_ptg, 100),
          cenvat_sequence = nvl(cenvat_sequence ,0) + 1,    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
          last_update_date = sysdate,
          last_update_login = fnd_global.login_id,
          last_updated_by = fnd_global.user_id
      WHERE transaction_id = r_trx.tax_transaction_id;
    END IF;

  /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.. Following code is a replacement for removal of ja_in_create_rcv_57f4_trg trigger
  as part of RTV DFF Elimination
  elsif r_trx.transaction_type = 'RETURN TO VENDOR' then

    if r_trx.attribute1 = INV_GEN_STATUS_INV_GENERATED then
      jai_po_osp_pkg.create_rcv_57f4(
        p_transaction_id    => p_transaction_id,
        p_process_status    => p_process_status,
        p_process_message   => p_process_message
      );

      if p_process_status in (jai_constants.unexpected_error) then
        p_process_status := 'E';
        return;
      end if;
    end if;
*/
  end if;
  /*
  IF r_trx.transaction_type = 'DELIVER' THEN

    -- meaning non bonded
    IF r_trx.loc_subinv_type = 'N' THEN
      UPDATE JAI_RCV_CENVAT_CLAIMS
      SET non_bonded_delivery_flag = 'Y',
          cenvat_claimed_ptg = 100
          --last_update_date = sysdate,
          --last_updated_by = fnd_global.user_id
      WHERE transaction_id = p_transaction_id;
    END IF;

  END IF;
  */
  /*
  --*** Did not handle UOM Conversion between the Transaction Quantities
  JA_IN_RCV_CENVAT_PKG.update_quantities(
      p_shipment_line_id              => p_shipment_line_id,
      p_tax_transaction_id            => r_trx.tax_transaction_id,
      p_transaction_type              => r_trx.transaction_type,
      p_parent_transaction_type       => r_trx.parent_transaction_type,
      p_subinventory_type             => r_trx.loc_subinventory_type,
      p_transaction_quantity          => r_trx.quantity,
      p_transaction_uom_code          => r_trx.uom_code,
      p_called_from                   => 'jai_rcv_trx_processing_pkg.transaction_preprocessor',
      p_simulate_flag                 => p_simulate_flag,
      p_process_status                => p_process_status,
      p_process_message               => p_process_message
  );
  */
  p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, 'receipt_transactions_pkg.trx_post_proc', 'END');

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END transaction_postprocessor;

/*============= Check for outside processing transaction ================== */
/* Bug 5365346. Added by Lakshmi Gopalsami */
FUNCTION Check_57F4_transaction( p_transaction_id in number )
         RETURN  varchar2 is
 CURSOR c_check_57F4_for_po IS
  SELECT jpol.line_id
   FROM jai_po_osp_lines jpol,
        jai_po_osp_hdrs jpoh
  WHERE jpol.form_id = jpoh.form_id
    AND (jpoh.po_header_id, jpol.po_line_id  ) IN
             ( SELECT po_header_id, po_line_id
           FROM rcv_transactions
    WHERE transaction_id = p_transaction_id
        );
  ln_line_id NUMBER ;
  ln_ret_value VARCHAR2(3);


BEGIN
  ln_line_id := 0;
  ln_ret_value := 'NO';
  OPEN c_check_57F4_for_po;
   FETCH c_check_57F4_for_po INTO ln_line_id;
   IF c_check_57F4_for_po%NOTFOUND THEN
     ln_ret_value := 'NO';
     fnd_file.put_line(FND_FILE.LOG, 'Check_57F4_transaction->57F4 challan doesnot exist ' );
   ELSE
     ln_ret_value := 'YES';
     fnd_file.put_line(FND_FILE.LOG, 'Check_57F4_transaction->57F4 challan exists ' );
   END IF ;
  CLOSE c_check_57F4_for_po;
  RETURN ln_ret_value;
END check_57f4_transaction;

/*============================== DEFERRED CLAIM Main Procedure ==============================*/
PROCEDURE process_deferred_cenvat_claim(
  p_batch_id            IN  NUMBER,
  p_called_from         IN  VARCHAR2,
  p_simulate_flag       IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N',
  p_process_flag OUT NOCOPY VARCHAR2,
  p_process_message OUT NOCOPY VARCHAR2
) IS

  r_trx                   c_trx%ROWTYPE;
  lv_process_flag         JAI_RCV_TRANSACTIONS.PROCESS_STATUS%TYPE;
  lv_process_message      JAI_RCV_TRANSACTIONS.process_message%TYPE;
  lv_cenvat_rg_flag       JAI_RCV_TRANSACTIONS.CENVAT_RG_STATUS%TYPE;
  lv_cenvat_rg_message    JAI_RCV_TRANSACTIONS.cenvat_rg_message%TYPE;
  lv_common_err_mesg      VARCHAR2(1000);

  lv_codepath             VARCHAR2(1996);
  ln_processed_cnt        NUMBER(10);   --File.Sql.35 Cbabu   := 0;
  ln_errored_cnt          NUMBER(10);   --File.Sql.35 Cbabu   := 0;

  r_tax                   jai_rcv_excise_processing_pkg.tax_breakup;
  lv_breakup_type         VARCHAR2(15);

   lv_ttype_correct JAI_RCV_TRANSACTIONS.transaction_type%type ;
   lv_ttype_deliver JAI_RCV_TRANSACTIONS.transaction_type%type ;
   lv_type_rtr     JAI_RCV_TRANSACTIONS.transaction_type%type ;

  CURSOR c_trxs_for_unclaim(cp_shipment_line_id IN NUMBER, cp_tax_transaction_id IN NUMBER) IS
    select transaction_id, shipment_line_id, organization_type
    from JAI_RCV_TRANSACTIONS
    where (transaction_type IN (lv_ttype_deliver, lv_type_rtr) --'DELIVER', 'RETURN TO RECEIVING')
           or (transaction_type= lv_ttype_correct and parent_transaction_type = lv_ttype_deliver) --'CORRECT' , 'DELIVER'
          )
    and tax_transaction_id = cp_tax_transaction_id
    and shipment_line_id = cp_shipment_line_id
    -- and cenvat_rg_flag <> ('P','X')    -- pending for parent receive claim
    -- and cenvat_rg_flag IN ('N', 'X', 'P', 'XT')
    /* and attribute1 = jai_rcv_deliver_rtr_pkg.cenvat_costed_flag commented for  bug 8346068 by vumaasha */
    --and (attribute2 IS NULL or attribute2 <> jai_constants.yes) /*commented for bug 9032251*/
    FOR UPDATE OF cenvat_rg_status, cenvat_rg_message
    order by shipment_line_id, transaction_id;

  CURSOR c_trxs_to_be_claimed IS
    SELECT * FROM JAI_RCV_CENVAT_CLAIM_T
    WHERE batch_identifier = p_batch_id
    AND error_flag IS NULL
    FOR UPDATE OF transaction_id
    ORDER BY transaction_id;

  CURSOR c_receipt_cenvat_dtl(cp_transaction_id IN NUMBER) IS
    SELECT cenvat_claimed_ptg, quantity_for_2nd_claim
    FROM JAI_RCV_CENVAT_CLAIMS
    WHERE transaction_id = cp_transaction_id;

  r_receipt_cenvat_dtl      c_receipt_cenvat_dtl%ROWTYPE;
  lv_2nd_claim_flag         VARCHAR2(1);
  ln_qty_to_claim           JAI_RCV_CENVAT_CLAIMS.quantity_for_2nd_claim%TYPE;
  lv_process_special_reason VARCHAR2(50);
  ln_process_special_amount NUMBER;
  -- lv_codepath             JAI_RCV_TRANSACTIONS.codepath%TYPE;
  -- lv_process_flag         JAI_RCV_TRANSACTIONS.PROCESS_STATUS%TYPE;
  -- lv_process_message      JAI_RCV_TRANSACTIONS.process_message%TYPE;

  /*Bug 8648138 - Start*/
  ln_invoice_id    ap_invoice_distributions_all.invoice_id%TYPE;

  CURSOR get_invoice (cp_transaction_id NUMBER) IS
  SELECT DISTINCT invoice_id
  FROM ap_invoice_distributions_all
  WHERE rcv_transaction_id = cp_transaction_id;
  /*Bug 8648138 - End*/

BEGIN

  ln_processed_cnt        := 0;
  ln_errored_cnt          := 0;

  -- Unclaim means, Receipt Line is not eligible for Claim. So we need to set all related flags as non recoverable and
  -- and reverse the cenvat entries if any passed against the transactions

  FOR temp_rec IN c_trxs_to_be_claimed LOOP

    ln_processed_cnt          := ln_processed_cnt + 1;
    lv_common_err_mesg        := null;
    lv_cenvat_rg_flag         := null;
    ln_qty_to_claim           := null;
    lv_2nd_claim_flag         := null;
    r_trx                     := null;
    r_tax                     := null;
    lv_codepath               := '';
    lv_process_special_reason := null;

    OPEN c_trx(temp_rec.transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_process_flag       := r_trx.process_status;
    lv_process_message    := r_trx.process_message;
    lv_cenvat_rg_flag     := r_trx.cenvat_rg_status;
    lv_cenvat_rg_message  := r_trx.cenvat_rg_message;

    lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'receipt_transactions_pkg.process_deferred_cenvat_claim', 'START');

    SAVEPOINT start_deferred_claim;

    IF lb_debug THEN
      FND_FILE.put_line(FND_FILE.log, 'trx_id:'||temp_rec.transaction_id||', flag:'||temp_rec.process_flag);
    END IF;

    IF temp_rec.process_flag = 'M' THEN

      OPEN c_receipt_cenvat_dtl(r_trx.tax_transaction_id);
      FETCH c_receipt_cenvat_dtl INTO r_receipt_cenvat_dtl;
      CLOSE c_receipt_cenvat_dtl;

      lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath);

      IF r_trx.item_class IN ('CGIN','CGEX') THEN

        lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);
        IF r_trx.transaction_type IN ('RECEIVE','MATCH') THEN

          IF r_receipt_cenvat_dtl.cenvat_claimed_ptg = 0 THEN
            lv_codepath := jai_general_pkg.plot_codepath(4, lv_codepath);
            lv_2nd_claim_flag := 'N';

          ELSIF r_receipt_cenvat_dtl.cenvat_claimed_ptg = 100 THEN
            lv_codepath := jai_general_pkg.plot_codepath(5, lv_codepath);
            -- Already 100% is Claimed, some problem in code and thats why execution came till here. so process next record
            GOTO next_record;

          -- second claim case
          ELSIF r_receipt_cenvat_dtl.cenvat_claimed_ptg < 100 THEN

            lv_codepath := jai_general_pkg.plot_codepath(6, lv_codepath);
            -- 2nd Claim should be done only to the tune of JAI_RCV_CENVAT_CLAIMS.
            lv_2nd_claim_flag := 'Y';

          ELSE
            lv_codepath := jai_general_pkg.plot_codepath(7, lv_codepath);
            GOTO next_record;
          END IF;

        ELSE

          lv_codepath := jai_general_pkg.plot_codepath(8, lv_codepath);
          IF r_trx.cenvat_claimed_ptg = 0 THEN
            lv_2nd_claim_flag := 'N';
          ELSE
            lv_codepath := jai_general_pkg.plot_codepath(8.1, lv_codepath);
            -- transactions other than RECEIVE should not be processed for 2nd Claim
            GOTO next_record;
          END IF;

        END IF;

      ELSE
        lv_codepath := jai_general_pkg.plot_codepath(9, lv_codepath);
        lv_2nd_claim_flag := 'N';
      END IF;

      IF lv_2nd_claim_flag = 'Y' THEN
        ln_qty_to_claim   := r_receipt_cenvat_dtl.quantity_for_2nd_claim;
        lv_process_special_reason := jai_rcv_excise_processing_pkg.second_50ptg_claim;
      END IF;

      process_transaction(
        p_transaction_id    => temp_rec.transaction_id,
        p_process_flag      => lv_process_flag,
        p_process_message   => lv_process_message,
        p_cenvat_rg_flag    => lv_cenvat_rg_flag,
        p_cenvat_rg_message => lv_cenvat_rg_message,
        p_common_err_mesg   => lv_common_err_mesg,
        p_called_from       => p_called_from,
        p_simulate_flag     => p_simulate_flag,
        p_codepath          => lv_codepath,
        p_process_special_reason  => lv_process_special_reason,
        p_process_special_qty     => ln_qty_to_claim,
        p_excise_processing_reqd => jai_constants.yes,  --File.Sql.35 Cbabu
        p_vat_processing_reqd => jai_constants.yes  --File.Sql.35 Cbabu
      );

      lv_codepath := jai_general_pkg.plot_codepath(10, lv_codepath);

      -- flag value 'X' is removed from the following ELSIF conditions because it is not an ERROR Status. MYXZ
      IF lv_common_err_mesg IS NOT NULL THEN
        -- A common error occured. So, Whole Processing for Transaction should be stopped
        ROLLBACK TO start_deferred_claim;
        FND_FILE.put_line(FND_FILE.log, '*** Common Error for Transaction_id:'||r_trx.transaction_id
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- Error:'||lv_common_err_mesg
        );
        lv_codepath := jai_general_pkg.plot_codepath(11, lv_codepath);

      ELSIF lv_process_flag IN ('E') AND lv_cenvat_rg_flag IN ('E') THEN
        lv_codepath := jai_general_pkg.plot_codepath(12, lv_codepath);
        FND_FILE.put_line(FND_FILE.log, '*** FLAGS ERROR *** Transaction_id:'||r_trx.transaction_id
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ProcessErr:'||lv_process_message
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- CenvatErr:'||lv_cenvat_rg_message
        );
        /*dbms_output.put_line( '*** FLAGS ERROR *** Transaction_id:'||r_trx.transaction_id
            ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ProcessErr:'||lv_process_message
            ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- CenvatErr:'||lv_cenvat_rg_message );
        */
      ELSIF lv_process_flag IN ('E') THEN
        lv_codepath := jai_general_pkg.plot_codepath(13, lv_codepath);
        FND_FILE.put_line(FND_FILE.log, '*** PROCESS ERROR *** Transaction_id:'||r_trx.transaction_id
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ErrorMessage:'||lv_process_message
        );
        /*dbms_output.put_line('*** PROCESS ERROR *** Transaction_id:'||r_trx.transaction_id
            ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ErrorMessage:'||lv_process_message );
        */
      ELSIF lv_cenvat_rg_flag IN ('E') THEN
        lv_codepath := jai_general_pkg.plot_codepath(14, lv_codepath);
        FND_FILE.put_line(FND_FILE.log, '*** CENVAT ERROR *** Transaction_id:'||r_trx.transaction_id
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ErrorMessage:'||lv_cenvat_rg_message
        );
        /*dbms_output.put_line('*** CENVAT ERROR *** Transaction_id:'||r_trx.transaction_id
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ErrorMessage:'||lv_cenvat_rg_message
        );*/
      END IF;

      IF lv_process_flag IN ('X') AND lv_cenvat_rg_flag IN ('X') THEN
        lv_codepath := jai_general_pkg.plot_codepath(15, lv_codepath);
        FND_FILE.put_line(FND_FILE.log, ' Transaction Cant be processed for trx:'||r_trx.transaction_id
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ProcessMessage(X):'||lv_process_message
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- CenvatMessgae(X):'||lv_cenvat_rg_message
        );
        /*dbms_output.put_line('M: Err2: Transaction Cant be processed for trx:'||r_trx.transaction_id
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ProcessMessage(X):'||lv_process_message
          ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- CenvatMessgae(X):'||lv_cenvat_rg_message);
          */
      ELSIF lv_process_flag IN ('X') THEN
        lv_codepath := jai_general_pkg.plot_codepath(16, lv_codepath);
        FND_FILE.put_line(FND_FILE.log, 'Process Message(X):'||lv_process_message);
        /*dbms_output.put_line('M: Err4:'||lv_process_message);*/
      ELSIF lv_cenvat_rg_flag IN ('X') THEN
        lv_codepath := jai_general_pkg.plot_codepath(17, lv_codepath);
        FND_FILE.put_line(FND_FILE.log, 'Cenvat Messgae(X):'||lv_cenvat_rg_message);
        /*dbms_output.put_line('M: Err3:'||lv_cenvat_rg_message);*/
      END IF;

      IF lv_process_flag = 'E' OR lv_cenvat_rg_flag = 'E' THEN
        lv_codepath := jai_general_pkg.plot_codepath(18, lv_codepath);
        p_process_flag    := lv_cenvat_rg_flag;
        p_process_message := lv_cenvat_rg_message;
        fnd_file.put_line(fnd_file.log, 'M: Err5:'||p_process_message);
      END IF;

    -- UNCLAIM PROCESSING
    -- following Unclaim Processing will not happen for
    ELSIf temp_rec.process_flag = 'U' AND r_trx.transaction_type IN ('RECEIVE', 'MATCH') THEN

      lv_codepath := jai_general_pkg.plot_codepath(19, lv_codepath);
      SAVEPOINT start_unclaim;

      -- Costing(Average and Standard)/Expense Logic for Excise Amount

      lv_ttype_correct := 'CORRECT';
      lv_ttype_deliver := 'DELIVER';
      lv_type_rtr      := 'RETURN TO RECEIVING';

      FOR loop_trx IN c_trxs_for_unclaim(r_trx.shipment_line_id, r_trx.tax_transaction_id) LOOP   /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/

        IF r_trx.organization_type = 'T' THEN
          lv_breakup_type := 'RG23D';
        END IF;

        lv_codepath := jai_general_pkg.plot_codepath(21, lv_codepath);
        jai_rcv_excise_processing_pkg.get_tax_amount_breakup(
            p_shipment_line_id  => loop_trx.shipment_line_id,
            p_transaction_id    => loop_trx.transaction_id,
            p_curr_conv_rate    => r_trx.currency_conversion_rate,
            pr_tax              => r_tax,     -- OUT Variable with Breakup
            p_breakup_type      => lv_breakup_type,
            p_codepath          => lv_codepath
        );

        ln_process_special_amount := r_tax.basic_excise +
                               r_tax.addl_excise +
             r_tax.other_excise  +
             r_tax.cvd +
             r_tax.addl_cvd +
              -- Modified by SACSETHI Bug# 5228046
              -- Forward porting the change in 11i bug 5365523
                                      -- (Additional CVD Enhancement) as part of the R12 bug 5228046
             r_tax.excise_edu_cess +
             r_tax.cvd_edu_cess+r_tax.sh_exc_edu_cess +               --Added by kunkumar for forward porting  bug#5907436  to R12
r_tax.sh_cvd_edu_cess;                 --Added by kunkumar for forward porting  bug#5907436  to R12


        IF ln_process_special_amount = 0 THEN
          GOTO skip_unclaim_record;
        END IF;

        lv_codepath := jai_general_pkg.plot_codepath(22, lv_codepath);
        --lv_codepath := '';
        jai_rcv_deliver_rtr_pkg.process_transaction (
            p_transaction_id    => loop_trx.transaction_id,
            p_simulate          => p_simulate_flag,
            p_codepath          => lv_codepath,
            p_process_status    => lv_process_flag,
            p_process_message   => lv_process_message,
            p_process_special_source  => jai_constants.cenvat_noclaim,
            p_process_special_amount  => ln_process_special_amount
        );

        IF p_process_flag IN ('E', 'X') THEN
          lv_codepath := jai_general_pkg.plot_codepath(23, lv_codepath);
          FND_FILE.put_line(FND_FILE.log, 'Unclaim PRC_FLG_Error: RollingBack to process_trxn_flag');
          /*dbms_output.put_line('Unclaim PRC_FLG_Error: RollingBack to process_trxn_flag');*/
          --p_codepath := jai_general_pkg.plot_codepath(6, p_codepath);
          ROLLBACK TO start_unclaim;
          -- following is to take care that if one transaction of RECEIVE childs fail, then loop should not
          -- be executed as the loop is related to CHILDs of RECEIVE Transaction
          EXIT;
        ElSIF p_process_flag = 'Y' THEN
          --p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);
          p_process_message := 'Successful';
        ELSE
          FND_FILE.put_line(FND_FILE.log, 'Unclaim#PRC_FLG#'||p_process_flag);
          --p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
          /*dbms_output.put_line('Unclaim#PRC_FLG#'||p_process_flag);*/
        END IF;

        UPDATE JAI_RCV_TRANSACTIONS
        SET CENVAT_RG_STATUS = 'X',
            cenvat_rg_message = 'Cenvat Unclaimed'
        WHERE CURRENT OF c_trxs_for_unclaim;

        <<skip_unclaim_record>>
        NULL;

      END LOOP;

      lv_codepath := jai_general_pkg.plot_codepath(27, lv_codepath);

      UPDATE JAI_RCV_TRANSACTIONS
      SET CENVAT_RG_STATUS = 'X',
          cenvat_rg_message = 'Cenvat Unclaimed'
      WHERE transaction_id = temp_rec.transaction_id
        -- following is to take care of Pending DELIVER and RTR and related CORRECTS
        -- as the parent receive is not yet claim so need of passing CENVAT RG entries.
        -- Simply update the flag as the transactions is already costed during delivery processing
        OR (  shipment_line_id = r_trx.shipment_line_id
              AND tax_transaction_id = r_trx.tax_transaction_id
              AND (transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')
                 or (transaction_type='CORRECT' and parent_transaction_type = 'DELIVER')
                )
              AND loc_subinv_type = 'N' -- non bonded
              AND CENVAT_RG_STATUS = 'P'  -- waiting for receipt line claim
           );

      /* Shall take the help of support to implement the unclaim functionality */
      UPDATE JAI_RCV_CENVAT_CLAIMS
      SET cenvat_amount = 0,
          other_cenvat_amt = 0,
          cenvat_sequence = cenvat_sequence + 1,
          unclaim_cenvat_flag ='Y',
          unclaim_cenvat_date = trunc(sysdate),
          unclaimed_cenvat_amount = temp_rec.unclaimed_cenvat_amount,
          last_update_date = sysdate,
          last_update_login = fnd_global.login_id,
          last_updated_by = fnd_global.user_id
      WHERE transaction_id = temp_rec.transaction_id;

      /*Bug 8648138 - Unclaimed excise amount should be available for re-transfer to FA from AP, if the transfer
      is done before unclaim*/

      ln_invoice_id := NULL;
      FOR r_invoice IN get_invoice(r_trx.tax_transaction_id)
      LOOP
          ln_invoice_id := r_invoice.invoice_id;

          IF ln_invoice_id IS NOT NULL THEN

              UPDATE ap_invoice_distributions_all aida
              SET assets_addition_flag = 'U',
              assets_tracking_flag = 'Y',
              charge_applicable_to_dist_id = (select invoice_distribution_id from ap_invoice_distributions_all
                                              where line_type_lookup_code in ('ITEM', 'ACCRUAL')
                                              and po_distribution_id = aida.po_distribution_id
                                              )
              WHERE invoice_id = ln_invoice_id
              AND distribution_line_number IN
                 (SELECT distribution_line_number
                  FROM jai_ap_match_inv_taxes  jatd,
                       jai_rcv_line_taxes jrtl
                  WHERE jatd.invoice_id=ln_invoice_id
                  AND   jrtl.transaction_id=r_trx.tax_transaction_id
                  AND   jrtl.modvat_flag = 'Y'
                  AND   jrtl.shipment_line_id = temp_rec.shipment_line_id
                  AND   jrtl.tax_id = jatd.tax_id
                  AND   Upper(jrtl.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', jai_constants.tax_type_cvd,
                                                 jai_constants.tax_type_add_cvd,
                                                 jai_constants.tax_type_exc_edu_cess, jai_constants.tax_type_cvd_edu_cess,
                                                 jai_constants.tax_type_sh_exc_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess)) ;


          END IF;
      END LOOP;
      /*Bug 8648138*/

      -- By doing this future transactions will be taken care not to see Excise taxes as Recoverable
      UPDATE JAI_RCV_LINE_TAXES
      SET   modvat_flag ='N',
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE  shipment_line_id = temp_rec.shipment_line_id
      AND    upper(tax_type) IN ('EXCISE',
                                 'ADDL. EXCISE',
         'OTHER EXCISE',
         'CVD',
         jai_constants.tax_type_add_cvd,
              -- Modified by SACSETHI Bug# 5228046
              -- Forward porting the change in 11i bug 5365523
                                      -- (Additional CVD Enhancement) as part of the R12 bug 5228046
                                 jai_constants.tax_type_exc_edu_cess,
         jai_constants.tax_type_cvd_edu_cess, jai_constants.tax_type_sh_exc_edu_cess,
                                 jai_constants.tax_type_sh_cvd_edu_cess)  -- By kunkumar for bug 5989740
      AND    modvat_flag ='Y';

      lv_codepath := jai_general_pkg.plot_codepath(27.1, lv_codepath);

    END IF;

    << next_record >>

    If lv_common_err_mesg IS NOT NULL
      OR lv_cenvat_rg_flag IN ('E', jai_constants.unexpected_error, jai_constants.expected_error)
    THEN

      lv_codepath := jai_general_pkg.plot_codepath(28, lv_codepath);
      ROLLBACK TO start_deferred_claim;
      p_process_flag := lv_cenvat_rg_flag;
      p_process_message := lv_cenvat_rg_message;
      ln_errored_cnt := ln_errored_cnt + 1;

      UPDATE JAI_RCV_CENVAT_CLAIM_T
      SET error_flag = 'Y',
          error_description = substr(lv_cenvat_rg_message,1,150),
          process_date = sysdate
      WHERE CURRENT OF c_trxs_to_be_claimed;

    ELSE

      lv_codepath := jai_general_pkg.plot_codepath(29, lv_codepath);
      -- Finally after the processing is completed, we need to delete the record from temp table
      DELETE FROM JAI_RCV_CENVAT_CLAIM_T
      WHERE CURRENT OF c_trxs_to_be_claimed;

    END IF;

    lv_codepath := jai_general_pkg.plot_codepath(30, lv_codepath);
    fnd_file.put_line(fnd_file.log, 'Trx_id:'||temp_rec.transaction_id||'. Codepath:'||lv_codepath);
    /*dbms_output.put_line('Trx_id:'||temp_rec.transaction_id||'. Codepath:'||lv_codepath);*/

  END LOOP;

  IF ln_errored_cnt > 0 THEN
    p_process_flag    := jai_constants.unexpected_error;
    p_process_message := 'Errored Record Count:'||ln_errored_cnt;
    fnd_file.put_line(fnd_file.log, 'DeferredClaimError Cnt>0:'||p_process_message);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_deferred_claim;
    p_process_flag    := 'E';
    fnd_file.put_line(fnd_file.log, 'ErrorCodepath:'||lv_codepath);
    p_process_message := 'Processed Count:'||ln_processed_cnt||', Errored Cnt:'||ln_errored_cnt||'. Error Message:'||SQLERRM;
    fnd_file.put_line(fnd_file.log, 'DeferredClaimError6:'||p_process_message);
END process_deferred_cenvat_claim;


/*============================== MAIN PROCEDURE ==============================*/
PROCEDURE process_batch(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2,
  p_organization_id       IN  NUMBER,
  pv_transaction_from      IN  VARCHAR2, /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
  pv_transaction_to        IN  VARCHAR2, /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
  p_transaction_type      IN  VARCHAR2,
  p_parent_trx_type       IN  VARCHAR2,
  p_shipment_header_id    IN  NUMBER,     -- New parameter added by Vijay Shankar for Bug#3940588
  p_receipt_num           IN  VARCHAR2,
  p_shipment_line_id      IN  NUMBER,     -- New parameter added by Vijay Shankar for Bug#3940588
  p_transaction_id        IN  NUMBER,
  p_commit_switch         IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'Y',
  p_called_from           IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'Batch',   -- If the value passed is 'APPLICATION', then data is not Commited in this procedure
  p_simulate_flag         IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N',
  p_trace_switch          IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N'
  p_request_id            IN  NUMBER   DEFAULT NULL, -- CSahoo for Bug 5344225
  p_group_id              IN  NUMBER   DEFAULT NULL -- CSahoo for Bug 5344225
) IS

  /* rallamse bug#4336482 */
   p_transaction_from DATE; --File.Sql.35 Cbabu  DEFAULT fnd_date.canonical_to_date(pv_transaction_from);
   p_transaction_to   DATE; --File.Sql.35 Cbabu  DEFAULT fnd_date.canonical_to_date(pv_transaction_to);
  /* End of Bug# 4336482 */

  ------------ Start, Declaration for TRACE Generation -------------
  lv_request_id     VARCHAR2(50);
  ln_sid            NUMBER;
  ln_serial         NUMBER;
  lv_spid           VARCHAR2(9);
  lv_dbname         VARCHAR2(25);
  ln_audsid         NUMBER; --File.Sql.35 Cbabu  := userenv('SESSIONID');
  lv_tax_modified_check_flag varchar2(1);   --File.Sql.35 Cbabu  := 'Y' ;

  CURSOR c_get_audsid IS
    SELECT a.sid, a.serial#, b.spid
    FROM v$session a, v$process b
    WHERE audsid = ln_audsid
    AND a.paddr = b.addr;

  CURSOR c_get_dbname IS
    SELECT name FROM v$database;
  ------------ End, Declaration for TRACE Generation -------------

  --added,  CSahoo for Bug 5344225
  ln_req_status  BOOLEAN      ;
  lv_phase       VARCHAR2(80) ;
  lv_status      VARCHAR2(80) ;
  lv_dev_phase   VARCHAR2(80) ;
  lv_dev_status  VARCHAR2(80) ;
  lv_message     VARCHAR2(80) ;

  Cursor c_interface_exists(cp_group_id IN NUMBER)
  IS
  select 1
  from rcv_transactions_interface
  where group_id = cp_group_id
  and rownum=1 ;

  Cursor c_interface_error(cp_group_id IN NUMBER)
  IS
  select 1
  from rcv_transactions_interface
  where
   group_id = cp_group_id  and
   (transaction_status_code = 'ERROR' or processing_status_code = 'ERROR')  ;

  ln_error NUMBER ;
   --ended,  CSahoo for Bug 5344225

  lv_process_flag       JAI_RCV_TRANSACTIONS.PROCESS_STATUS%TYPE;
  lv_process_message    JAI_RCV_TRANSACTIONS.process_message%TYPE;
  lv_cenvat_rg_flag     JAI_RCV_TRANSACTIONS.CENVAT_RG_STATUS%TYPE;
  lv_cenvat_rg_message  JAI_RCV_TRANSACTIONS.cenvat_rg_message%TYPE;
  lv_codepath           JAI_RCV_TRANSACTIONS.codepath%TYPE;

  lv_common_err_mesg    VARCHAR2(500);
  ln_processed_cnt      NUMBER; --File.Sql.35 Cbabu  := 0;
  ln_batch_id           NUMBER(15);

  r_trx_after_processing  c_trx%rowtype;


    --commented the below by Sanjikum for Bug#4929410
    /*CURSOR c_trxns_to_populate_dtls IS
    SELECT rowid, transaction_id, shipment_line_id, process_status, cenvat_rg_status,
        transaction_type, parent_transaction_type, receipt_num, cenvat_claimed_ptg
        , attribute_category -- Vijay Shankar for Bug#4250171
    FROM JAI_RCV_TRANSACTIONS a
    WHERE (p_organization_id IS NULL OR organization_id = p_organization_id)
    AND a.receipt_num IS NULL
    AND (p_shipment_header_id IS NULL OR a.shipment_header_id = p_shipment_header_id)
    AND
    (  ( p_called_from = 'JAINPORE' and p_shipment_header_id is null) -- added, Harshita for bug #4300708
       OR ( exists (select 1 from JAI_RCV_LINES b
                where a.shipment_line_id = b.shipment_line_id
                and tax_modified_flag='N') )
    )
    FOR UPDATE OF transaction_id
    ORDER BY receipt_num, transaction_id;


    CURSOR c_get_transactions  IS
    SELECT rowid, transaction_id, process_status, cenvat_rg_status, process_message, cenvat_rg_message,
        transaction_type, parent_transaction_type, receipt_num, cenvat_claimed_ptg,
        shipment_line_id      -- Vijay Shankar for Bug#3940588
    FROM JAI_RCV_TRANSACTIONS a
    WHERE ( p_simulate_flag = 'Y'
            OR
            ( process_status IS NULL OR process_status IN ('N', 'E','P') OR cenvat_rg_status IN ('N', 'E','P')
              -- following condition added by Vijay Shankar for Bug#4250236(4245089). VAT Implementation
              OR -- process_vat_status IN ('N', 'E', 'P') this condition is modified as below for DFF elimination. Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
              process_vat_status IN ('N', 'E', 'P', jai_constants.unexpected_error, jai_constants.expected_error)
              -- Vijay Shankar for Bug#3940588 RECEIPTS DEPLUG
              -- This is no more required because 2nd 50% Claim is handled seperately through deferred Claim procedure
              -- However process_transaction still uses cenvat_claimed_ptg flag to process 2nd 50% Claim
              -- OR cenvat_claimed_ptg = 50
            )
          )
    AND receipt_num IS NOT NULL   -- a Check to see whether populate details is done for this trx or not
    AND (p_transaction_id IS NULL OR transaction_id = p_transaction_id)
    AND (p_organization_id IS NULL OR organization_id = p_organization_id)
    AND (p_shipment_header_id IS NULL OR shipment_header_id = p_shipment_header_id)     -- Vijay Shankar for Bug#3940588
    AND (p_shipment_line_id IS NULL OR shipment_line_id = p_shipment_line_id)           -- Vijay Shankar for Bug#3940588
    -- followingcondition is not required
    --AND (p_receipt_num IS NULL OR receipt_num = p_receipt_num)
    AND (p_transaction_type IS NULL OR transaction_type = p_transaction_type)
    AND (p_parent_trx_type IS NULL OR parent_transaction_type = p_parent_trx_type)      -- Vijay Shankar for Bug#3940588
    AND (
         (p_transaction_from IS NULL AND p_transaction_to IS NULL)
         OR (p_transaction_from IS NULL AND trunc(creation_date) <= p_transaction_to)
         OR (p_transaction_to IS NULL AND trunc(creation_date) >= p_transaction_from)
         OR (trunc(creation_date) BETWEEN p_transaction_from AND p_transaction_to)
        )
    -- Check to pickup only those lines in which taxes cannot be modified,
    and
    ( ( p_shipment_header_id is null and p_called_from = 'JAINPORE' ) OR -- added, Harshita for bug #4300708
        exists (select 1 from JAI_RCV_LINES b
                where b.shipment_line_id = a.shipment_line_id
                and b.tax_modified_flag='N')
    )
    -- 3927371 (generic finding) this should process only these transactions if only receipt number is specified.
    -- This should be removed when old code is obsoleted with new code
    -- AND transaction_type IN ('CORRECT', 'DELIVER', 'RETURN TO RECEIVING');     -- commented for Vijay Shankar for Bug#3940588
    FOR UPDATE OF transaction_id    -- added by Vijay Shankar for Bug#3940588
    ORDER BY transaction_id;    -- added by Vijay Shankar for Bug#3940588 */

  --Start added by Sanjikum for Bug#4929410
  PROCEDURE ja_in_populate_details IS

    CURSOR c_lock_rcv_dtls IS
      SELECT  rowid
      FROM    jai_rcv_transactions
      WHERE   transaction_id IN
              ( SELECT  transaction_id
                FROM    jai_rtp_populate_t)
      FOR UPDATE OF transaction_id  ;

    lock_rcv_rec_dtls  c_lock_rcv_dtls%ROWTYPE ;

  BEGIN
    IF p_shipment_header_id is null THEN

      INSERT
      INTO    JAI_RTP_POPULATE_T
              (TRANSACTION_ID,
              SHIPMENT_LINE_ID,
              PROCESS_FLAG,
              CENVAT_RG_FLAG,
              TRANSACTION_TYPE,
              PARENT_TRANSACTION_TYPE,
              RECEIPT_NUM,
              CENVAT_CLAIMED_PTG,
              ATTRIBUTE_CATEGORY)
      (
      SELECT  transaction_id,
              shipment_line_id,
              process_status,
              cenvat_rg_status,
              transaction_type,
              parent_transaction_type,
              receipt_num,
              cenvat_claimed_ptg,
              attribute_category
      FROM    jai_rcv_transactions a
      WHERE   organization_id = p_organization_id
      AND     a.receipt_num IS NULL
      AND     p_called_from = 'JAINPORE');

    ELSE
      INSERT
      INTO    JAI_RTP_POPULATE_T
              (TRANSACTION_ID,
              SHIPMENT_LINE_ID,
              PROCESS_FLAG,
              CENVAT_RG_FLAG,
              TRANSACTION_TYPE,
              PARENT_TRANSACTION_TYPE,
              RECEIPT_NUM,
              CENVAT_CLAIMED_PTG,
              ATTRIBUTE_CATEGORY)
      (
      SELECT  transaction_id,
              shipment_line_id,
              process_status,
              cenvat_rg_status,
              transaction_type,
              parent_transaction_type,
              receipt_num,
              cenvat_claimed_ptg,
              attribute_category
      FROM    jai_rcv_transactions a
      WHERE   organization_id = p_organization_id
      AND     a.shipment_header_id = p_shipment_header_id
      AND     a.receipt_num IS NULL
      AND     EXISTS (SELECT  1
                      FROM    jai_rcv_lines b
                      WHERE   a.shipment_line_id = b.shipment_line_id
                      AND     tax_modified_flag='N')
      );

    END IF ;

    OPEN  c_lock_rcv_dtls ;
    FETCH c_lock_rcv_dtls INTO lock_rcv_rec_dtls ;
    CLOSE c_lock_rcv_dtls ;
  END ja_in_populate_details;

  PROCEDURE ja_in_get_transactions IS
    CURSOR c_lock_rcv_trans IS
      SELECT  rowid
      FROM    jai_rcv_transactions
      WHERE   transaction_id IN
              ( SELECT  transaction_id
                FROM    jai_rtp_trans_t )
      FOR UPDATE OF transaction_id  ;

    lock_rcv_rec_trans  c_lock_rcv_trans%ROWTYPE ;
  BEGIN
    IF p_shipment_header_id is null THEN
      IF p_transaction_type IS NOT NULL THEN
        IF p_parent_trx_type IS NOT NULL THEN
          INSERT
          INTO    JAI_RTP_TRANS_T
                  (TRANSACTION_ID,
                  PROCESS_FLAG,
                  CENVAT_RG_FLAG,
                  PROCESS_MESSAGE,
                  CENVAT_RG_MESSAGE,
                  TRANSACTION_TYPE,
                  PARENT_TRANSACTION_TYPE,
                  RECEIPT_NUM,
                  CENVAT_CLAIMED_PTG,
                  SHIPMENT_LINE_ID)
                  (
          SELECT  transaction_id,
                  process_status,
                  cenvat_rg_status,
                  process_message,
                  cenvat_rg_message,
                  transaction_type,
                  parent_transaction_type,
                  receipt_num,
                  cenvat_claimed_ptg,
                  shipment_line_id
          FROM    jai_rcv_transactions a
          WHERE   organization_id = p_organization_id
          AND     transaction_type = p_transaction_type
          AND     parent_transaction_type = p_parent_trx_type
          AND     receipt_num IS NOT NULL
          AND     (   p_simulate_flag = 'Y'
                    OR
                      (   process_status IS NULL
                        OR  process_status IN ('N', 'E','P')
                        OR  cenvat_rg_status IN ('N', 'E','P')
                        OR  process_vat_status IN ('N', 'E', 'P', jai_constants.unexpected_error, jai_constants.expected_error)
                      )
                  )
          AND   (
                    (   p_transaction_from IS NULL AND p_transaction_to IS NULL)
                 OR (p_transaction_from IS NULL AND trunc(creation_date) <= p_transaction_to)
                 OR (p_transaction_to IS NULL AND trunc(creation_date) >= p_transaction_from)
                 OR (trunc(creation_date) BETWEEN p_transaction_from AND p_transaction_to)
                )
           ) ;
        ELSE  -- p_parent_trx_type IS NOT NULL
          INSERT
          INTO    JAI_RTP_TRANS_T
                  (TRANSACTION_ID,
                  PROCESS_FLAG,
                  CENVAT_RG_FLAG,
                  PROCESS_MESSAGE,
                  CENVAT_RG_MESSAGE,
                  TRANSACTION_TYPE,
                  PARENT_TRANSACTION_TYPE,
                  RECEIPT_NUM,
                  CENVAT_CLAIMED_PTG,
                  SHIPMENT_LINE_ID)
                  (
          SELECT  transaction_id,
                  process_status,
                  cenvat_rg_status,
                  process_message,
                  cenvat_rg_message,
                  transaction_type,
                  parent_transaction_type,
                  receipt_num,
                  cenvat_claimed_ptg,
                  shipment_line_id
          FROM    jai_rcv_transactions a
          WHERE   organization_id = p_organization_id
          AND     transaction_type = p_transaction_type
          AND     receipt_num IS NOT NULL
          AND     (   p_simulate_flag = 'Y'
                    OR
                      (   process_status IS NULL
                        OR  process_status IN ('N', 'E','P')
                        OR  cenvat_rg_status IN ('N', 'E','P')
                        OR  process_vat_status IN ('N', 'E', 'P', jai_constants.unexpected_error, jai_constants.expected_error)
                      )
                  )
          AND   (
                    (   p_transaction_from IS NULL AND p_transaction_to IS NULL)
                 OR (p_transaction_from IS NULL AND trunc(creation_date) <= p_transaction_to)
                 OR (p_transaction_to IS NULL AND trunc(creation_date) >= p_transaction_from)
                 OR (trunc(creation_date) BETWEEN p_transaction_from AND p_transaction_to)
                )
           ) ;

        END IF ; --IF p_parent_trx_type IS NOT NULL

      ELSE  --IF p_transaction_type IS NOT NULL
        INSERT
        INTO    JAI_RTP_TRANS_T
                (TRANSACTION_ID,
                PROCESS_FLAG,
                CENVAT_RG_FLAG,
                PROCESS_MESSAGE,
                CENVAT_RG_MESSAGE,
                TRANSACTION_TYPE,
                PARENT_TRANSACTION_TYPE,
                RECEIPT_NUM,
                CENVAT_CLAIMED_PTG,
                SHIPMENT_LINE_ID)
                (
        SELECT  transaction_id,
                process_status,
                cenvat_rg_status,
                process_message,
                cenvat_rg_message,
                transaction_type,
                parent_transaction_type,
                receipt_num,
                cenvat_claimed_ptg,
                shipment_line_id
        FROM    jai_rcv_transactions a
        WHERE   organization_id = p_organization_id
        AND     receipt_num IS NOT NULL
        AND     (   p_simulate_flag = 'Y'
                  OR
                    (   process_status IS NULL
                      OR  process_status IN ('N', 'E','P')
                      OR  cenvat_rg_status IN ('N', 'E','P')
                      OR  process_vat_status IN ('N', 'E', 'P', jai_constants.unexpected_error, jai_constants.expected_error)
                    )
                )
        AND   (
                  (   p_transaction_from IS NULL AND p_transaction_to IS NULL)
               OR (p_transaction_from IS NULL AND trunc(creation_date) <= p_transaction_to)
               OR (p_transaction_to IS NULL AND trunc(creation_date) >= p_transaction_from)
               OR (trunc(creation_date) BETWEEN p_transaction_from AND p_transaction_to)
              )
         ) ;
      END IF ; --IF p_transaction_type IS NOT NULL
    ELSE
      INSERT
      INTO    JAI_RTP_TRANS_T
              (TRANSACTION_ID,
              PROCESS_FLAG,
              CENVAT_RG_FLAG,
              PROCESS_MESSAGE,
              CENVAT_RG_MESSAGE,
              TRANSACTION_TYPE,
              PARENT_TRANSACTION_TYPE,
              RECEIPT_NUM,
              CENVAT_CLAIMED_PTG,
              SHIPMENT_LINE_ID)
              (
      SELECT  transaction_id,
              process_status,
              cenvat_rg_status,
              process_message,
              cenvat_rg_message,
              transaction_type,
              parent_transaction_type,
              receipt_num,
              cenvat_claimed_ptg,
              shipment_line_id
      FROM    jai_rcv_transactions a
      WHERE   organization_id = p_organization_id
      AND     shipment_header_id = p_shipment_header_id AND
              (   p_simulate_flag = 'Y'
                OR
                  (     process_status IS NULL
                    OR  process_status IN ('N', 'E','P')
                    OR  cenvat_rg_status IN ('N', 'E','P')
                    OR  process_vat_status IN ('N', 'E', 'P', jai_constants.unexpected_error, jai_constants.expected_error)
                  )
              )
      AND   receipt_num IS NOT NULL
      AND   (p_transaction_id IS NULL OR transaction_id = p_transaction_id)
      AND   (p_shipment_line_id IS NULL OR shipment_line_id = p_shipment_line_id)
      AND   (p_transaction_type IS NULL OR transaction_type = p_transaction_type)
      AND   (p_parent_trx_type IS NULL OR parent_transaction_type = p_parent_trx_type)
      AND   (
                  (p_transaction_from IS NULL AND p_transaction_to IS NULL)
              OR  (p_transaction_from IS NULL AND trunc(creation_date) <= p_transaction_to)
              OR  (p_transaction_to IS NULL AND trunc(creation_date) >= p_transaction_from)
              OR  (trunc(creation_date) BETWEEN p_transaction_from AND p_transaction_to)
            )
      AND   EXISTS (SELECT  1
                    FROM    jai_rcv_lines b
                    WHERE   b.shipment_line_id = a.shipment_line_id
                    AND     b.tax_modified_flag='N')
      );

    END IF ;  -- IF p_shipment_header_id is null

    OPEN  c_lock_rcv_trans ;
    FETCH c_lock_rcv_trans INTO lock_rcv_rec_trans ;
    CLOSE c_lock_rcv_trans ;

  END ja_in_get_transactions ;
  --Start added by Sanjikum for Bug#4929410

BEGIN

  p_transaction_from := fnd_date.canonical_to_date(pv_transaction_from);
  p_transaction_to   := fnd_date.canonical_to_date(pv_transaction_to);
  ln_audsid          := userenv('SESSIONID');
  lv_tax_modified_check_flag := 'Y' ;
  ln_processed_cnt      := 0;


   --Added by CSahoo for Bug 5344225
   --Start
  BEGIN

    IF p_request_id is not null and p_request_id <> -1 THEN -- pramasub FP modified the line and given the comment below
    /*
                     || ssumaith - for Iprocurement Bug#4281841 added the -1 in the above condition to ensure that the program does not
                    || return in case of a call from Iprocurement.
                     */
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
       FND_FILE.put_line(FND_FILE.log, 'Problem in Completion of Receiving Transaction Processor - Request Id ' || p_request_id || '. Exiting from India - Receicing Transaction Processor ');
       RETURN ;
     END IF ;
    END IF ;

    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.put_line(FND_FILE.log, 'Phase : ' || lv_phase || 'Status : ' || lv_status || 'Dev Phase : ' || lv_dev_phase ||
        ' Dev Status : ' || lv_dev_status || ' Message : ' || lv_message );
        FND_FILE.put_line(FND_FILE.log, 'Error in the Call to The fnd_concurrent.wait_for_request for Request Id ' || p_request_id || '. Returning... ');
        RETURN ;
  END;



  BEGIN
    IF p_group_id is not null THEN

     FOR rec_exists in c_interface_exists(p_group_id)
     LOOP
        ln_error := 0 ;

        OPEN c_interface_error(p_group_id) ;
        FETCH c_interface_error INTO ln_error;
        CLOSE c_interface_error ;

        IF ln_error = 1 THEN
          raise_application_error(-20001, ' Error while processing Receiving Transactions. Exiting from India Receiving Transaction Processor ')  ;
        END IF ;

        dbms_lock.sleep(1);
     END LOOP ;
    END IF ;
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.put_line(FND_FILE.log, SQLERRM) ;
      RETURN ;
  END;

  --ended,  CSahoo for Bug 5344225

  FND_FILE.put_line( FND_FILE.log, 'Start of Batch. Date:'||to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss') );

  lv_request_id   := FND_PROFILE.value('CONC_REQUEST_ID');
  FND_FILE.put_line( FND_FILE.log, 'Inputs. OrgnId:'||nvl(p_organization_id,-1)
    ||', TrxFrom->'||nvl(p_transaction_from, to_date('1-01-1700', 'dd-mm-yyyy'))
    ||', Trxto->'||nvl(p_transaction_to, to_date('1-01-1700', 'dd-mm-yyyy'))
    ||', TrxType->'||nvl(p_transaction_type, 'XXX')
    ||', RecptNum->'||nvl(p_receipt_num, 'ABCD')
    ||', CalFrom->'||nvl(p_called_from,'NO')
    ||', TrxId->'|| nvl(p_transaction_id, -999)
    ||', SimFlg->'|| p_simulate_flag
    ||', TrcSwtch->'|| p_trace_switch
    ||', ReqId->'|| lv_request_id
    --CSahoo for Bug 534425
    ||', p_request_id ' ||  p_request_id
    ||', p_group_id ' || p_group_id
  );

  ---------------- Trace Generation Logic-------------------------
  BEGIN
    IF p_trace_switch = 'Y' THEN

      OPEN c_get_audsid;
      FETCH c_get_audsid INTO ln_sid, ln_serial, lv_spid;
      CLOSE c_get_audsid;

      OPEN c_get_dbname;
      FETCH c_get_dbname INTO lv_dbname;
      CLOSE c_get_dbname;

      FND_FILE.put_line(FND_FILE.log, 'TraceFile Name = '||lower(lv_dbname)||'_ora_'||lv_spid||'.trc');

      EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.put_line(FND_FILE.log, '%%%Problem in Trace Generation%%%');
  END;

  /*----------------------------- START of Business Logic ----------------------*/

  /******************** START OF DEFERRED CENVAT CLAIM LOGIC **************/
  BEGIN

    IF p_called_from = 'JAINMVAT' THEN

      -- value contained in p_shipment_header_id when called from JAINMVAT is batch_id of Claim/Unclaim
      ln_batch_id := p_shipment_header_id;

      FND_FILE.put_line( FND_FILE.log, '~~~~~ Start of Deferred Claim ~~~~~. Batch:'||ln_batch_id);
      process_deferred_cenvat_claim(
        p_batch_id            => ln_batch_id,
        p_called_from         => p_called_from,
        p_simulate_flag       => p_simulate_flag,
        p_process_flag        => lv_process_flag,
        p_process_message     => lv_process_message
      );

      FND_FILE.put_line( FND_FILE.log, '~~~~~ End of Deferred Claim ~~~~~');
      IF lv_process_flag IN (jai_constants.unexpected_error, jai_constants.expected_error) THEN
        FND_FILE.put_line(fnd_file.log, 'PROCESS_DEFERRED_CENVAT_CLAIM. Err Message - '||lv_process_message);
        FND_FILE.put_line(fnd_file.log, 'For details, Please refer to JAI_RCV_CENVAT_CLAIMS table with batch_id = '||ln_batch_id);
        retcode := jai_constants.request_warning;
      END IF;

      GOTO end_of_batch;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      FND_file.put_line(fnd_file.log, 'Error Message:'||SQLERRM);
      /*dbms_output.put_line('MainProc-DeferredClaim:Err:'||SQLERRM);*/
      retcode := jai_constants.request_error;
      RETURN;
  END;
  /******************** END OF DEFERRED CLAIM **************/

  -- Start, Vijay Shankar for Bug#3940588
  -- Following has to be executed as and when it is submitted from Receipts Localization form
 jai_cmn_utils_pkg.print_log('tax_mod.log','In transaction processing p_called_from:'||p_called_from);
 FND_FILE.put_line( FND_FILE.log, 'p_called_from:'||p_called_from);

  IF p_called_from = 'JAINPORE' THEN
    FND_FILE.put_line( FND_FILE.log, '~~~~~  Updating JAI_RCV_LINES.tax_modified_flag to N ~~~~~');

    UPDATE JAI_RCV_LINES a
    SET tax_modified_flag = 'N',
        last_update_date = SYSDATE,
        last_update_login = fnd_global.login_id,
        last_updated_by = fnd_global.user_id
    WHERE shipment_header_id = p_shipment_header_id
    AND tax_modified_flag IN ('Y', 'X')
    -- This condition will take not to update tax modified flag incase localization table is not populated
    -- eg.Incase of Unordered Receipt, Until MATCH happens we should not update the tax_modified_flag to 'Y'
    AND exists (select 1 from JAI_RCV_TRANSACTIONS
                               where shipment_line_id = a.shipment_line_id);

    -- This Commit is a definitive Commit that has to happen
    COMMIT;

  END IF;
  -- End, Vijay Shankar for Bug#3940588


  FND_FILE.put_line( FND_FILE.log, '~~~~~ Start Populate Details ~~~~~');
  -- populate_details should be called only once and that too when the trxn is processed for the first time

  ja_in_populate_details ; -- added by Sanjikum for bug#4929410

  --FOR trx IN c_trxns_to_populate_dtls LOOP
  --commented the above and added the below by Sanjikum for Bug#4929410
  FOR trx IN (SELECT * FROM JAI_RTP_POPULATE_T ORDER BY receipt_num, transaction_id)  LOOP
    -- SAVEPOINT start_trx_population;
    lv_codepath := '';

    FND_FILE.put_line( FND_FILE.log, 'Recpt:'||trx.receipt_num||', TrxId:'||trx.transaction_id);
    populate_details(
        p_transaction_id  => trx.transaction_id,
        p_process_status  => lv_process_flag,
        p_process_message => lv_process_message,
        p_simulate_flag   => p_simulate_flag,
        p_codepath        => lv_codepath
    );

    IF lv_process_flag = 'E' THEN
      exit;
    END IF;

    IF trx.transaction_type IN ('RECEIVE','MATCH')
      /*Vijay Shankar for Bug#4250171. condition added to support OPM Transactions */
      AND (p_called_from <> CALLED_FROM_OPM OR trx.attribute_category in (OPM_RECEIPT,OPM_RETURNS) )
    THEN
      transaction_preprocessor(
          p_shipment_line_id  => trx.shipment_line_id,
          p_transaction_id    => trx.transaction_id,
          p_process_status    => lv_process_flag,
          p_process_message   => lv_process_message,
          p_simulate_flag     => p_simulate_flag
      );
    END IF;

    IF lv_process_flag = 'E' THEN
      exit;
    END IF;

  END LOOP;

  -- IF UPPER(p_called_from) <> 'APPLICATION' THEN
  IF lv_process_flag = 'E' THEN
    ROLLBACK;
    FND_FILE.put_line( FND_FILE.log, '*** POPULATE_DETAILS Error ***:'||lv_process_message);
    errbuf := lv_process_message;
    retcode := jai_constants.request_error;
    RETURN;
  ELSIF p_commit_switch = 'Y' THEN
    -- first commit to save all the populated details of JAI_RCV_TRANSACTIONS
    COMMIT;
  END IF;

  /*~~~~~~~~~~~~~~~~~~~~~~~~~ Start of PROCESSING TRANSACTIONS ~~~~~~~~~~~~~~~~~~~~~*/

  ja_in_get_transactions ;  -- internal procedure call ; -- added by Sanjikum for bug #4929410

  --FOR trx IN c_get_transactions  LOOP
  --commented the above and added the below by Sanjikum for Bug#4929410
  FOR trx IN (SELECT * FROM JAI_RTP_TRANS_T ORDER BY transaction_id)   LOOP

  BEGIN

    lv_common_err_mesg := null;
    lv_codepath := '';
    r_trx_after_processing := null;

    FND_FILE.put_line(FND_FILE.log, '+++ Start of ReceiptNo, Transaction_id:'||trx.receipt_num||','||trx.transaction_id
      ||', trxn_type:'||trx.transaction_type
      ||', parent_trxn_type:'||trx.parent_transaction_type
      ||', process_status:'||trx.process_flag
      ||', cenvat_rg_status:'||trx.cenvat_rg_flag
      ||', cenvat_claimed_ptg:'||trx.cenvat_claimed_ptg
    );

    -- lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'process_batch', 'start'); /* 1 */

    SAVEPOINT process_trxn;

    lv_process_flag       := trx.process_flag;
    lv_process_message    := trx.process_message;
    lv_cenvat_rg_flag     := trx.cenvat_rg_flag;
    lv_cenvat_rg_message  := trx.cenvat_rg_message;

    -- added, Harshita for bug #4300708

    IF ( p_called_from = 'JAINPORE' and p_shipment_header_id is null
            and trx.transaction_type IN  ('RECEIVE', 'MATCH') ) THEN
      update JAI_RCV_LINES
      set tax_modified_flag = 'N'
      where receipt_num = trx.receipt_num ;
    END IF ;

    -- ended, Harshita for bug #4300708

    process_transaction(
      p_transaction_id    => trx.transaction_id,
      p_process_flag      => lv_process_flag,
      p_process_message   => lv_process_message,
      p_cenvat_rg_flag    => lv_cenvat_rg_flag,
      p_cenvat_rg_message => lv_cenvat_rg_message,
      p_common_err_mesg   => lv_common_err_mesg,
      p_called_from       => p_called_from,
      p_simulate_flag     => p_simulate_flag,
      p_codepath          => lv_codepath,
        p_excise_processing_reqd => jai_constants.yes,  --File.Sql.35 Cbabu
        p_vat_processing_reqd => jai_constants.yes  --File.Sql.35 Cbabu
    );

    OPEN c_trx(trx.transaction_id);
    FETCH c_trx INTO r_trx_after_processing;
    CLOSE c_trx;

    -- 'X' flag is removed from the following ELSIF conditions because it is not an ERROR Status. MYXZ
    IF lv_common_err_mesg IS NOT NULL THEN
      -- A common error occured. So, Whole Processing for Transaction should be stopped
      ROLLBACK TO process_trxn;
      FND_FILE.put_line(FND_FILE.log, '*** Common Error for Transaction_id:'||trx.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- Error:'||lv_common_err_mesg
      );
      retcode := 1;
    ELSIF lv_process_flag IN ('E') AND lv_cenvat_rg_flag IN ('E') THEN
      FND_FILE.put_line(FND_FILE.log, '*** FLAGS ERROR *** Transaction_id:'||trx.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ProcessErr:'||lv_process_message
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- CenvatErr:'||lv_cenvat_rg_message
      );
    ELSIF lv_process_flag IN ('E') THEN
      FND_FILE.put_line(FND_FILE.log, '*** PROCESS ERROR *** Transaction_id:'||trx.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ErrorMessage:'||lv_process_message
      );
    ELSIF lv_cenvat_rg_flag IN ('E') THEN
      FND_FILE.put_line(FND_FILE.log, '*** CENVAT ERROR *** Transaction_id:'||trx.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ErrorMessage:'||lv_cenvat_rg_message
      );

    /* added for VAT Impl. Vijay Shankar for Bug#4250236(4245089) */
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. ELSIF r_trx_after_processing.process_vat_status <> jai_constants.successful THEN
    ELSIF r_trx_after_processing.process_vat_status in ('E', jai_constants.unexpected_error, jai_constants.expected_error) then
      FND_FILE.put_line(FND_FILE.log, '*** VAT Message *** Transaction_id:'||trx.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||', Flag:'||r_trx_after_processing.process_vat_status
        ||' - ErrorMessage:'||r_trx_after_processing.process_vat_message
      );
    END IF;

    -- Start, 3927371
    IF lv_process_flag IN ('X') AND lv_cenvat_rg_flag IN ('X') THEN
      FND_FILE.put_line(FND_FILE.log, 'Transaction_Id:'||trx.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ProcessMessage(X):'||lv_process_message
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- CenvatMessgae(X):'||lv_cenvat_rg_message
      );
    ELSIF lv_process_flag IN ('X') THEN
      FND_FILE.put_line(FND_FILE.log, 'Process Message(X):'||lv_process_message);
    ELSIF lv_cenvat_rg_flag IN ('X') THEN
      FND_FILE.put_line(FND_FILE.log, 'Cenvat Messgae(X):'||lv_cenvat_rg_message);
    END IF;

    IF lv_process_flag = 'E' OR lv_cenvat_rg_flag = 'E' THEN
      retcode := 1;
    END IF;
    -- End, 3927371

    /* Start, Vijay Shankar for Bug#3940588 */
    -- Transaction Post Processor
    transaction_postprocessor(
        p_shipment_line_id  => trx.shipment_line_id,
        p_transaction_id    => trx.transaction_id,
        p_process_status    => lv_process_flag,
        p_process_message   => lv_process_message,
        p_simulate_flag     => p_simulate_flag,
        p_codepath         => lv_codepath
    );
    -- End, Vijay Shankar for Bug#3940588

    if lv_process_flag = 'E' then
      ROLLBACK TO process_trxn;
      FND_FILE.put_line(FND_FILE.log, 'Error:Transaction_postprocessor. MSG:'||lv_process_message);
    end if;

    IF p_simulate_flag = 'Y' THEN
      FND_FILE.put_line(FND_FILE.log, 'Codepath->'||lv_codepath);
    ELSE
      UPDATE  JAI_RCV_TRANSACTIONS
      SET     codepath = lv_codepath
      --WHERE   rowid = trx.row_id
      --commented the above and added the below by sanjikum for Bug#4929410
      WHERE transaction_id = trx.transaction_id;
    END IF;

    -- IF UPPER(p_called_from) <> 'APPLICATION' THEN
    /* Vijay Shankar for Bug#4208224
    IF p_commit_switch = 'Y' THEN
      IF ln_processed_cnt >= ln_commit_after THEN
        COMMIT;
        ln_processed_cnt := 0;
      ELSE
      END IF;
    END IF;
    */

    ln_processed_cnt := ln_processed_cnt + 1;
    lv_common_err_mesg := null;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO process_trxn;
      FND_FILE.put_line( FND_FILE.log, 'Rolled Back Processing in RECEIPT_TRANSACTIONS_PKG.process_batch: Error->'||SQLERRM);
      retcode := 1;
  END;

  END LOOP;

  <<end_of_batch>>
  -- IF UPPER(p_called_from) <> 'APPLICATION' THEN
  IF p_commit_switch = 'Y' THEN
    -- Final Commit to Permanently Save any changes left
    COMMIT;
  END IF;

/* added by Vijay Shankar for Bug#3940588 */
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    FND_FILE.put_line( FND_FILE.log, 'Error:'||SQLERRM);
    FND_FILE.put_line( FND_FILE.log, 'Error Path:'||lv_codepath);
    RAISE;
END process_batch;

/* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
PROCEDURE insert_rtv_batch_group(
  pn_batch_group_id OUT NOCOPY NUMBER,
  pn_batch_num          IN    NUMBER,
  pv_regime_code        IN    VARCHAR2,
  pn_organization_id    IN    NUMBER,
  pn_location_id        IN    NUMBER,
  pn_vendor_id          IN    NUMBER,
  pn_vendor_site_id     IN    NUMBER,
  pv_invoice_no         IN    VARCHAR2,
  pd_invoice_date       IN    DATE,
  pv_process_status     IN    VARCHAR2,
  pv_process_message    IN    VARCHAR2
) IS
  ln_user_id    NUMBER;
  ln_login_id   NUMBER;

BEGIN

  ln_user_id  := fnd_global.user_id;
  ln_login_id := fnd_global.user_id;

  INSERT INTO jai_rcv_rtv_batch_grps(
    batch_group_id,
    batch_num, regime_code, organization_id, location_id,
    vendor_id, vendor_site_id, invoice_no, invoice_date,
    creation_date, created_by, last_update_date, last_updated_by, last_update_login
  ) VALUES (
    jai_rcv_rtv_batch_grps_s.nextval,
    pn_batch_num, pv_regime_code, pn_organization_id, pn_location_id,
    pn_vendor_id, pn_vendor_site_id, pv_invoice_no, pd_invoice_date,
    sysdate, ln_user_id, sysdate, ln_user_id, ln_login_id
  ) RETURNING batch_group_id INTO pn_batch_group_id;

END insert_rtv_batch_group;

/*following procedure added as part of RTV DFF Elimination Enhacement Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
procedure process_rtv(
    pv_errbuf OUT NOCOPY VARCHAR2,
    pv_retcode OUT NOCOPY VARCHAR2,
    pn_batch_num            IN  NUMBER,
    pn_min_transaction_id   IN  NUMBER,
    pn_max_transaction_id   IN  NUMBER,
    pv_called_from          IN  VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'Y',
    pv_commit_switch        IN  VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'Y',
    pv_debug_switch         IN  VARCHAR2 --File.Sql.35 Cbabu   DEFAULT 'N'
) is

  cursor c_rtv_trxs(cpn_batch_num in number) is
    select a.receipt_num, a.transaction_id, a.shipment_line_id, a.shipment_header_id,
      a.organization_id, a.location_id, b.vendor_id, b.vendor_site_id, b.excise_batch_num, b.vat_batch_num,
      a.excise_invoice_no, a.vat_invoice_no, a.excise_invoice_date, a.vat_invoice_date
      , a.parent_transaction_id,
      a.PROCESS_STATUS, a.process_message, a.CENVAT_RG_STATUS, a.cenvat_rg_message,
      a.PROCESS_VAT_STATUS, a.process_vat_message
      --Modified by Bo Li for replacing the old attributes column with new one Begin
      ------------------------------------------------------------------------------
      , a.excise_inv_gen_status excise_invoice_action, a.vat_inv_gen_status vat_invoice_action,
     ------------------------------------------------------------------------------
     --Modified by Bo Li for replacing the old attributes column with new one End
      nvl(b.receipt_excise_rate,0) receipt_excise_rate,
      nvl(b.rtv_excise_rate, nvl(b.receipt_excise_rate, 0)) rtv_excise_rate,
      decode( b.excise_batch_num, cpn_batch_num, jai_constants.yes, jai_constants.no)   process_excise_in_batch,
      decode( b.vat_batch_num, cpn_batch_num, jai_constants.yes, jai_constants.no)   process_vat_in_batch
    from JAI_RCV_TRANSACTIONS a, jai_rcv_rtv_batch_trxs b
    where a.transaction_id = b.transaction_id
    and (pn_min_transaction_id is null or a.transaction_id >= pn_min_transaction_id)
    and (pn_max_transaction_id is null or a.transaction_id <= pn_max_transaction_id)
    and
      (   ( b.excise_batch_num = cpn_batch_num and a.excise_invoice_no is null)
       or ( b.vat_batch_num = cpn_batch_num and a.vat_invoice_no is null)
      )
    order by a.organization_id, a.location_id, b.vendor_id, b.vendor_site_id, a.transaction_id
    for update of a.excise_invoice_no, a.excise_invoice_date, a.vat_invoice_no, a.vat_invoice_date;

  cursor c_regime_id(cpv_regime_code varchar2) is
    select regime_id
    from JAI_RGM_DEFINITIONS
    where regime_code = cpv_regime_code;

  ln_regime_id            JAI_RGM_DEFINITIONS.regime_id%TYPE;

  lv_excise_invoice_no        JAI_RCV_TRANSACTIONS.excise_invoice_no%TYPE;
  ld_excise_invoice_date      DATE;
  lv_gen_excise_invoice_no    JAI_RCV_TRANSACTIONS.excise_invoice_no%TYPE;
  ld_gen_excise_invoice_date  DATE;

  lv_vat_invoice_no           JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE;
  ld_vat_invoice_date         DATE;
  lv_gen_vat_invoice_no       JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE;
  ld_gen_vat_invoice_date     DATE;

  lv_same_invoice_no_flag VARCHAR2(1);

  ln_organization_id      NUMBER(15);
  ln_location_id          NUMBER(15);
  ln_vendor_id            NUMBER(15);
  ln_vendor_site_id       NUMBER(15);

  lv_errbuf               VARCHAR2(1000);
  lv_statement_id         VARCHAR2(4);


  lv_process_flag           JAI_RCV_TRANSACTIONS.PROCESS_STATUS%TYPE;
  lv_process_message        JAI_RCV_TRANSACTIONS.process_message%TYPE;
  lv_cenvat_rg_flag         JAI_RCV_TRANSACTIONS.CENVAT_RG_STATUS%TYPE;
  lv_cenvat_rg_message      JAI_RCV_TRANSACTIONS.cenvat_rg_message%TYPE;
  lv_common_err_mesg        JAI_RCV_TRANSACTIONS.cenvat_rg_message%TYPE;

  lv_excise_processing_reqd VARCHAR2(1);
  lv_vat_processing_reqd    VARCHAR2(1);
  lv_ssi_cenvat_rg_flag     JAI_RCV_TRANSACTIONS.CENVAT_RG_STATUS%TYPE;
  lv_ssi_cenvat_rg_message  JAI_RCV_TRANSACTIONS.cenvat_rg_message%TYPE;

  lv_codepath               JAI_RCV_TRANSACTIONS.codepath%TYPE;
  r_trx_after_processing    c_trx%ROWTYPE;
  lb_err_flag               boolean;
  ln_processed_cnt          number;

  lv_excise_inv_gen_action  VARCHAR2(50);
  lv_vat_inv_gen_action     VARCHAR2(50);

  ln_excise_batch_group_id  jai_rcv_rtv_batch_grps.batch_group_id%TYPE;
  ln_vat_batch_group_id     jai_rcv_rtv_batch_grps.batch_group_id%TYPE;

begin

  lv_statement_id     := '0';
  if lb_debug then
    fnd_file.put_line(fnd_file.log, 'Input Params. pn_batch_num:'||pn_batch_num
      ||', pn_min_transaction_id:'||pn_min_transaction_id
      ||', pn_max_transaction_id:'||pn_max_transaction_id
      ||', pv_called_from:'||pv_called_from
      ||', pv_commit_switch:'||pv_commit_switch
      ||', pv_debug_switch:'||pv_debug_switch);
  end if;


  ln_processed_cnt    := 0;
  ln_organization_id  := -1;
  ln_location_id      := -1;
  ln_vendor_id        := -1;
  ln_vendor_site_id   := -1;

  /* Excise Invoice Generation for Batch */
  for rtv_rec in c_rtv_trxs(pn_batch_num) loop

    lv_statement_id     := '1';
    lv_excise_invoice_no    := null;
    ld_excise_invoice_date  := null;
    lv_vat_invoice_no       := null;
    ld_vat_invoice_date     := null;

    -- excise invoice number will be generated if the following grouping condition changes
    if ln_organization_id <> rtv_rec.organization_id
      OR ln_location_id <> rtv_rec.location_id
      OR ln_vendor_id <> rtv_rec.vendor_id
      OR ln_vendor_site_id <> rtv_rec.vendor_site_id
    then
      lv_statement_id     := '3';
      ln_organization_id  := rtv_rec.organization_id;
      ln_location_id      := rtv_rec.location_id;
      ln_vendor_id        := rtv_rec.vendor_id;
      ln_vendor_site_id   := rtv_rec.vendor_site_id;

      lv_statement_id     := '4';
      lv_same_invoice_no_flag := null;
      lv_same_invoice_no_flag :=
          jai_cmn_rgm_recording_pkg.get_rgm_attribute_value(
            pv_regime_code          => jai_constants.vat_regime,
            pv_organization_type    => jai_constants.orgn_type_io,
            pn_organization_id      => ln_organization_id,
            pn_location_id          => ln_location_id,
            pv_registration_type    => jai_constants.regn_type_others, --'OTHERS',
            pv_attribute_type_code  => NULL,
            pv_attribute_code       => jai_constants.attr_code_same_inv_no  -- 'SAME_INVOICE_NO'
          );

      lv_statement_id     := '5';
      lv_same_invoice_no_flag     := nvl(lv_same_invoice_no_flag, jai_constants.no);
      lv_gen_excise_invoice_no    := null;
      ld_gen_excise_invoice_date  := null;
      lv_gen_vat_invoice_no       := null;
      ld_gen_vat_invoice_date     := null;
      ln_excise_batch_group_id    := null;
      ln_vat_batch_group_id       := null;

    end if;

    lv_statement_id     := '5.1';
    if lb_debug then
      fnd_file.put_line(fnd_file.log, '~~~ ReceiptNum:'||rtv_rec.receipt_num||', TrxId:'||rtv_rec.transaction_id
        ||', SameFlg:'||lv_same_invoice_no_flag
        ||', ExBatch:'||rtv_rec.excise_batch_num ||', VatBatch:'||rtv_rec.vat_batch_num
        ||', ExAct:'||rtv_rec.excise_invoice_action ||', VatAct:'||rtv_rec.vat_invoice_action
      );
    end if;

    lv_statement_id     := '6';
    /* Start Excise Inv. Gen */
    if rtv_rec.excise_batch_num = pn_batch_num and rtv_rec.excise_invoice_no is null
      and rtv_rec.excise_invoice_action = INV_GEN_STATUS_GENERATE
      /*bug 8410609 - excise invoice not to be generated for OSP items*/
      AND Check_57F4_transaction(rtv_rec.transaction_id) <>'YES'
    then
      lv_statement_id     := '7';
      if lv_same_invoice_no_flag = jai_constants.yes then
        lv_statement_id     := '8';
        lv_excise_invoice_no  := rtv_rec.vat_invoice_no;
        ld_excise_invoice_date  := rtv_rec.vat_invoice_date;
      end if;

      lv_statement_id     := '9';
      if lv_excise_invoice_no is null then
        lv_statement_id     := '10';
        lv_excise_invoice_no := lv_gen_excise_invoice_no;
        ld_excise_invoice_date  := ld_gen_excise_invoice_date;

        lv_statement_id     := '11';
        if lv_excise_invoice_no is null then
          lv_statement_id     := '12';
          ld_gen_excise_invoice_date := trunc(sysdate);
          jai_cmn_setup_pkg.generate_excise_invoice_no(
              p_organization_id       => ln_organization_id,
              p_location_id           => ln_location_id,
              p_called_from           => 'P',         -- Required for excise invoice generation for RTV
              p_order_invoice_type_id => NULL,
              p_fin_year              => jai_general_pkg.get_fin_year(ln_organization_id),
              p_excise_inv_no         => lv_gen_excise_invoice_no,
              p_errbuf                => lv_errbuf
          );

          lv_statement_id     := '13';
          lv_excise_invoice_no := lv_gen_excise_invoice_no;
          ld_excise_invoice_date := ld_gen_excise_invoice_date;

        end if;
      end if;

    else
      lv_statement_id     := '14';
      lv_excise_invoice_no := rtv_rec.excise_invoice_no;
      ld_excise_invoice_date  := rtv_rec.excise_invoice_date;
    end if;
    /* End Excise Inv. Gen */

    lv_statement_id     := '15';
    /* Start VAT Inv. Gen */
    if rtv_rec.vat_batch_num = pn_batch_num and rtv_rec.vat_invoice_no is null
      and rtv_rec.vat_invoice_action = INV_GEN_STATUS_GENERATE
    then
      lv_statement_id     := '16';
      if lv_same_invoice_no_flag = jai_constants.yes then
        lv_statement_id     := '17';
        lv_vat_invoice_no  := lv_excise_invoice_no;
        ld_vat_invoice_date  := ld_excise_invoice_date;
      end if;

      if lv_vat_invoice_no is null then
        lv_statement_id     := '18';
        lv_vat_invoice_no := lv_gen_vat_invoice_no;
        ld_vat_invoice_date := ld_gen_vat_invoice_date;

        if lv_vat_invoice_no is null then

          lv_statement_id     := '19';
          open c_regime_id(jai_constants.vat_regime);
          fetch c_regime_id into ln_regime_id;
          close c_regime_id;

          lv_statement_id     := '20';
          ld_gen_vat_invoice_date := trunc(sysdate);
          jai_cmn_rgm_setup_pkg.gen_invoice_number(
              p_regime_id       => ln_regime_id,
              p_organization_id => ln_organization_id,
              p_location_id     => ln_location_id,
              p_date            => ld_gen_vat_invoice_date,
              p_doc_class       => 'R',
              p_doc_type_id     => null,
              P_invoice_number  => lv_gen_vat_invoice_no,
              p_process_flag    => lv_process_flag,
              p_process_msg     => lv_process_message
          );

          lv_statement_id     := '21';
          if lv_process_flag in (jai_constants.expected_error, jai_constants.unexpected_error) then
            fnd_file.put_line(fnd_file.log, 'VAT Inv Gen Error. Params- RgmId:'||ln_regime_id
                ||', OrgnId:'||ln_organization_id ||', LocId:'||ln_location_id
                ||', InvDate:'||ld_gen_vat_invoice_date||', TrxId:'|| rtv_rec.transaction_id );
            fnd_file.put_line(fnd_file.log, 'ErrorCode:'||lv_process_flag
              ||', ErrMsg:'||lv_process_message);
            raise_application_error( -20112, 'VAT Inv Gen Error. Code:'||lv_process_flag
              ||', MSG:'||lv_process_message);
          end if;

          lv_statement_id     := '22';
          lv_vat_invoice_no := lv_gen_vat_invoice_no;
          ld_vat_invoice_date := ld_gen_vat_invoice_date;
        end if;

      end if;

    else
      lv_statement_id     := '23';
      lv_vat_invoice_no := rtv_rec.vat_invoice_no;
      ld_vat_invoice_date := rtv_rec.vat_invoice_date;
    end if;
    /* End. VAT Inv. Gen. */

    lv_statement_id     := '23.1';
    if lb_debug then
      fnd_file.put_line(fnd_file.log, '~~~ ExInvNo:'||lv_excise_invoicE_no ||', ld_excise_invoice_Date:'||ld_excise_invoice_date
        ||', VatInvNo:'||lv_vat_invoice_no ||', ld_vat_invoice_Date:'||ld_vat_invoice_date
      );
    end if;

    if rtv_rec.excise_batch_num = pn_batch_num and rtv_rec.excise_invoice_no is null then

      if rtv_rec.excise_invoice_action = INV_GEN_STATUS_GENERATE then

        lv_statement_id     := '24';
        update JAI_RCV_TRANSACTIONS a
        set excise_invoice_no = lv_excise_invoice_no,
            excise_invoice_date = ld_excise_invoice_date,
            --attribute3 = pn_batch_num,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id
        where current of c_rtv_trxs;

        lv_statement_id     := '25';
        INSERT INTO JAI_RCV_RTV_DTLS(
          transaction_id, parent_transaction_id, shipment_line_id,
          excise_invoice_no, excise_invoice_date, rg_register_part_i,
          creation_date, created_by, last_update_date, last_updated_by, last_update_login
        ) VALUES (
          rtv_rec.transaction_id, rtv_rec.parent_transaction_id, rtv_rec.shipment_line_id,
          lv_excise_invoice_no, ld_excise_invoice_date, NULL,
          sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, fnd_global.login_id
        );

        lv_excise_inv_gen_action  := INV_GEN_STATUS_INV_GENERATED;
      else
        lv_excise_inv_gen_action  := rtv_rec.excise_invoice_action;
      end if;
    end if;

    if rtv_rec.vat_batch_num = pn_batch_num and rtv_rec.vat_invoice_no is null then
      if rtv_rec.vat_invoice_action = INV_GEN_STATUS_GENERATE then
        lv_statement_id     := '26';
        update JAI_RCV_TRANSACTIONS a
        set vat_invoice_no    = lv_vat_invoice_no,
            vat_invoice_date  = ld_vat_invoice_date,
            --attribute4        = pn_batch_num,
            last_update_date  = sysdate,
            last_updated_by = fnd_global.user_id
        where current of c_rtv_trxs;
        lv_vat_inv_gen_action  := INV_GEN_STATUS_INV_GENERATED;
      else
        lv_vat_inv_gen_action  := rtv_rec.vat_invoice_action;
      end if;
    end if;

    if rtv_rec.process_excise_in_batch = jai_constants.yes and ln_excise_batch_group_id is null then
      lv_statement_id     := '26.1';
      insert_rtv_batch_group(
        pn_batch_group_id     => ln_excise_batch_group_id,
        pn_batch_num          => pn_batch_num,
        pv_regime_code        => jai_constants.excise_regime,
        pn_organization_id    => ln_organization_id,
        pn_location_id        => ln_location_id,
        pn_vendor_id          => ln_vendor_id,
        pn_vendor_site_id     => ln_vendor_site_id,
        pv_invoice_no         => lv_excise_invoice_no,
        pd_invoice_date       => ld_excise_invoice_date,
        pv_process_status     => lv_process_flag,
        pv_process_message    => lv_process_message
      );

      if lv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error) then
        RAISE_APPLICATION_ERROR( 20015, 'Error in Excise insert_rtv_batch_group. MSG:'||lv_process_message);
      end if;
    end if;

    if rtv_rec.process_vat_in_batch = jai_constants.yes and ln_vat_batch_group_id is null then
      lv_statement_id     := '26.2';
      insert_rtv_batch_group(
        pn_batch_group_id     => ln_vat_batch_group_id,
        pn_batch_num          => pn_batch_num,
        pv_regime_code        => jai_constants.vat_regime,
        pn_organization_id    => ln_organization_id,
        pn_location_id        => ln_location_id,
        pn_vendor_id          => ln_vendor_id,
        pn_vendor_site_id     => ln_vendor_site_id,
        pv_invoice_no         => lv_vat_invoice_no,
        pd_invoice_date       => ld_vat_invoice_date,
        pv_process_status     => lv_process_flag,
        pv_process_message    => lv_process_message
      );

      if lv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error) then
        RAISE_APPLICATION_ERROR( 20015, 'Error in Excise insert_rtv_batch_group. MSG:'||lv_process_message);
      end if;
    end if;

    if rtv_rec.process_excise_in_batch = jai_constants.yes
      or rtv_rec.process_vat_in_batch = jai_constants.yes
    then
      update jai_rcv_rtv_batch_trxs
      set excise_batch_group_id = decode(rtv_rec.process_excise_in_batch, jai_constants.yes, ln_excise_batch_group_id),
          vat_batch_group_id = decode(rtv_rec.process_vat_in_batch, jai_constants.yes, ln_vat_batch_group_id)
      where transaction_id = rtv_rec.transaction_id;
    end if;

    lv_statement_id       := '27';

    lv_process_flag       := rtv_rec.process_status;
    lv_process_message    := rtv_rec.process_message;
    lv_cenvat_rg_flag     := rtv_rec.cenvat_rg_status;
    lv_cenvat_rg_message  := rtv_rec.cenvat_rg_message;
    lv_common_err_mesg    := null;
    lb_err_flag           := false;

    if rtv_rec.process_excise_in_batch = jai_constants.yes
      and rtv_rec.excise_invoice_action = INV_GEN_STATUS_GENERATE
    then
      lv_excise_processing_reqd := jai_constants.yes;
    else
      lv_excise_processing_reqd := jai_constants.no;
    end if;

    if rtv_rec.process_vat_in_batch = jai_constants.yes
      and rtv_rec.vat_invoice_action in (INV_GEN_STATUS_GENERATE, INV_GEN_STATUS_INV_NA)
      and rtv_rec.process_vat_status <> jai_constants.successful
    then
      lv_vat_processing_reqd := jai_constants.yes;
    else
      lv_vat_processing_reqd := jai_constants.no;
    end if;

    /* call to process the transactions */
    process_transaction(
      p_transaction_id    => rtv_rec.transaction_id,
      p_process_flag      => lv_process_flag,
      p_process_message   => lv_process_message,
      p_cenvat_rg_flag    => lv_cenvat_rg_flag,
      p_cenvat_rg_message => lv_cenvat_rg_message,
      p_common_err_mesg   => lv_common_err_mesg,
      p_called_from       => CALLED_FROM_JAITIGRTV,  -- pv_called_from,
      p_simulate_flag     => 'N',
      p_codepath          => lv_codepath,
      p_excise_processing_reqd => lv_excise_processing_reqd,
      p_vat_processing_reqd => lv_vat_processing_reqd
    );

    lv_statement_id     := '28';
    OPEN c_trx(rtv_rec.transaction_id);
    FETCH c_trx INTO r_trx_after_processing;
    CLOSE c_trx;

    lv_statement_id     := '29';
    IF lv_common_err_mesg IS NOT NULL THEN
      FND_FILE.put_line(FND_FILE.log, '*** Common Error for Transaction_id:'||rtv_rec.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- Error:'||lv_common_err_mesg
      );
      lb_err_flag := true;
      goto end_of_trx;
      -- lv_err_mesg := lv_common_err_mesg;
    ELSIF lv_process_flag IN ('E') AND lv_cenvat_rg_flag IN ('E') THEN
      FND_FILE.put_line(FND_FILE.log, '*** FLAGS ERROR *** Transaction_id:'||rtv_rec.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ProcessErr:'||lv_process_message
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- CenvatErr:'||lv_cenvat_rg_message
      );
      lb_err_flag := true;
      goto end_of_trx;
    ELSIF lv_process_flag IN ('E') THEN
      FND_FILE.put_line(FND_FILE.log, '*** PROCESS ERROR *** Transaction_id:'||rtv_rec.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ErrorMessage:'||lv_process_message
      );
      lb_err_flag := true;
      goto end_of_trx;
    ELSIF lv_cenvat_rg_flag IN ('E') THEN
      FND_FILE.put_line(FND_FILE.log, '*** CENVAT ERROR *** Transaction_id:'||rtv_rec.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ErrorMessage:'||lv_cenvat_rg_message
      );
      lb_err_flag := true;
      goto end_of_trx;
    ELSIF r_trx_after_processing.process_vat_status in ('E', jai_constants.unexpected_error, jai_constants.expected_error) THEN
      FND_FILE.put_line(FND_FILE.log, '*** VAT Message *** Transaction_id:'||rtv_rec.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||', Flag:'||r_trx_after_processing.process_vat_status
        ||' - ErrorMessage:'||r_trx_after_processing.process_vat_message
      );
      lb_err_flag := true;
      goto end_of_trx;
    END IF;

    lv_statement_id     := '30';
    IF lv_process_flag IN ('X') AND lv_cenvat_rg_flag IN ('X') THEN
      FND_FILE.put_line(FND_FILE.log, 'Transaction_Id:'||rtv_rec.transaction_id
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- ProcessMessage(X):'||lv_process_message
        ||fnd_global.local_chr(10)||fnd_global.local_chr(9)||'- CenvatMessgae(X):'||lv_cenvat_rg_message
      );
    ELSIF lv_process_flag IN ('X') THEN
      FND_FILE.put_line(FND_FILE.log, 'Process Message(X):'||lv_process_message);
    ELSIF lv_cenvat_rg_flag IN ('X') THEN
      FND_FILE.put_line(FND_FILE.log, 'Cenvat Messgae(X):'||lv_cenvat_rg_message);
    END IF;

    lv_statement_id     := '31';
    IF lv_process_flag = 'E' OR lv_cenvat_rg_flag = 'E' THEN
      lb_err_flag := true;
      goto end_of_trx;
      -- retcode := 1;
    END IF;

    /* following procedure call is a replacement for SSI functinoality of JAINRTVN. This is created due to DFF removal */
    if lv_excise_processing_reqd = jai_constants.yes and rtv_rec.receipt_excise_rate <> rtv_rec.rtv_excise_rate then
      jai_rcv_excise_processing_pkg.rtv_processing_for_ssi(
          pn_transaction_id   => rtv_rec.transaction_id,
          pv_codepath         => lv_codepath,
          pv_process_status   => lv_ssi_cenvat_rg_flag,
          pv_process_message  => lv_ssi_cenvat_rg_message
      );

      if lv_ssi_cenvat_rg_flag = 'E' then
        lb_err_flag := true;
        goto end_of_trx;
      end if;
    end if;

    lv_statement_id     := '31.1';
     --Modified by Bo Li for replacing the update_attributes with update_inv_stat_and_no Begin
      --------------------------------------------------------------------------------------------
   /* jai_rcv_transactions_pkg.update_attributes(
      p_transaction_id      => rtv_rec.transaction_id,
      p_attribute1          => lv_excise_inv_gen_action,
      p_attribute2          => lv_vat_inv_gen_action
    );*/

     jai_rcv_transactions_pkg.update_inv_stat_and_no(
      p_transaction_id      => rtv_rec.transaction_id,
      p_excise_inv_gen_status   => lv_excise_inv_gen_action,
      p_vat_inv_gen_status      => lv_vat_inv_gen_action
     );
     --------------------------------------------------------------------------------------------
      --Modified by Bo Li for replacing the update_attributes with update_inv_stat_and_no End

    lv_statement_id     := '32';
    /* Following code is a replacement for removal of ja_in_create_rcv_57f4_trg trigger
       as part of RTV DFF Elimination  */
    -- if r_trx.attribute1 = INV_GEN_STATUS_INV_GENERATED then
    if lv_excise_processing_reqd = jai_constants.yes then
      jai_po_osp_pkg.create_rcv_57f4(
        p_transaction_id    => rtv_rec.transaction_id,
        p_process_status    => lv_process_flag,
        p_process_message   => lv_process_message
      );
    end if;

    lv_statement_id     := '33';
    if lv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error) then
      FND_FILE.put_line(FND_FILE.log, 'Error in Call to jai_po_osp_pkg.create_rcv_57f4. Mesg:'||lv_process_message);
      lv_process_flag := 'E';
      lb_err_flag := true;
      goto end_of_trx;
    end if;
    -- end if;

    lv_statement_id     := '35';
    UPDATE JAI_RCV_TRANSACTIONS
    SET codepath = lv_codepath
    WHERE current of c_rtv_trxs;

    <<end_of_trx>>
    if lb_err_flag then
      fnd_file.put_line( fnd_file.log, 'ErrCodepath:'||lv_codepath);
      raise_application_error( -20012, 'Error during RTV Processing. Look at the log for details');
    end if;

    ln_processed_cnt := ln_processed_cnt + 1;
    lv_common_err_mesg := null;
    lv_codepath := '';
  end loop;

  if pv_commit_switch = jai_constants.yes then
    COMMIT;
    -- ROLLBACK;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    pv_retcode  := jai_constants.request_error;
    pv_errbuf   := 'Error(StmtId:'||lv_statement_id||')-'||SQLERRM;
    FND_FILE.put_line( FND_FILE.log, pv_errbuf);
    -- FND_FILE.put_line( FND_FILE.log, 'Error Path:'||lv_codepath);
end process_rtv;


PROCEDURE process_transaction(
    p_transaction_id            IN        NUMBER,
    p_process_flag              IN OUT NOCOPY VARCHAR2,
    p_process_message           IN OUT NOCOPY VARCHAR2,
    p_cenvat_rg_flag            IN OUT NOCOPY VARCHAR2,
    p_cenvat_rg_message         IN OUT NOCOPY VARCHAR2,
    p_common_err_mesg OUT NOCOPY VARCHAR2,
    p_called_from               IN        VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2,
    -- following parameters introduced for second claim of receive transaction
    p_process_special_reason    IN        VARCHAR2    DEFAULT NULL,
    p_process_special_qty       IN        NUMBER      DEFAULT NULL,
    /*Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.*/
    p_excise_processing_reqd    IN        VARCHAR2, --File.Sql.35 Cbabu     DEFAULT jai_constants.yes,
    p_vat_processing_reqd       IN        VARCHAR2 --File.Sql.35 Cbabu     DEFAULT jai_constants.yes
) IS

--added by ssawant
CURSOR c_base_trx(cp_transaction_id IN NUMBER) IS
   SELECT shipment_header_id, shipment_line_id, transaction_type, quantity, unit_of_measure, uom_code,
   parent_transaction_id, organization_id, location_id, subinventory, currency_conversion_rate,
   attribute_category attr_cat, nvl(attribute5, 'XX') rma_type, nvl(attribute4, 'N') generate_excise_invoice
   , routing_header_id   -- porting of Bug#3949109 (3927371)
   , attribute3  online_claim_flag, source_document_code, po_header_id   -- Vijay Shankar for Bug#3940588
   , po_line_location_id
    FROM rcv_transactions
   WHERE transaction_id = cp_transaction_id;

  r_trx                 c_trx%ROWTYPE;
  r_base_trx            c_base_trx%ROWTYPE;/*bgowrava for forward porting Bug#5756676*/

  lv_transaction_type   JAI_RCV_TRANSACTIONS.transaction_type%TYPE;
  ln_cenvat_claimed_ptg NUMBER;

  lv_object_code        VARCHAR2(10);   --File.Sql.35 Cbabu  := 'RCPT_TRXN:';
  lv_statement_id       VARCHAR2(5);

  lv_execution_point    VARCHAR2(30);   --File.Sql.35 Cbabu  := 'COMMON_CODE';
  lv_temp               VARCHAR2(100);

  lv_process_vat_flag     JAI_RCV_TRANSACTIONS.PROCESS_VAT_STATUS%TYPE;
  lv_process_vat_message  JAI_RCV_TRANSACTIONS.process_vat_message%TYPE;

  lv_process_status       VARCHAR2(2); --added by ssawant
  lv_qty_register_entry_type VARCHAR2(2);   /*bug 7662347*/

BEGIN

  lv_object_code        := 'RCPT_TRXN:';
  lv_execution_point    := 'COMMON_CODE';

  -- this is to identify the path in SQL TRACE file if any problem occured
  SELECT to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||'-jirt_pkg.process_transaction-'||p_transaction_id INTO lv_temp FROM DUAL;

  FND_FILE.put_line(FND_FILE.log, '^Start of Trx:'||p_transaction_id||'. Time:'||to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss')
    ||', PrcSpecialReason:'||p_process_special_reason||', PrcSplQty:'||p_process_special_qty
  );

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'receipt_transactions_pkg.process_transaction', 'START');

  lv_statement_id := '1';

  --added the cursor and 2 assignments here by Ramananda for bug#4519697
  OPEN c_trx(p_transaction_id);
  FETCH c_trx INTO r_trx;
  CLOSE c_trx;

  lv_process_vat_flag := r_trx.process_vat_status; --Process_vat_flag ; -- Ramananda for bug#4519697
  lv_process_vat_message := r_trx.process_vat_message;


  OPEN  c_base_trx(p_transaction_id); /*bgowrava for forward porting Bug#5756676*/
  FETCH c_base_trx INTO r_base_trx;
  CLOSE c_base_trx;

  validate_transaction(
      p_transaction_id    => p_transaction_id,
      p_process_flag      => p_process_flag,
      p_process_message   => p_process_message,
      p_cenvat_rg_flag    => p_cenvat_rg_flag,
      p_cenvat_rg_message => p_cenvat_rg_message,
      /* following two flags introduced for VAT implementation. Vijay Shankar for Bug#4250236(4245089) */
      p_process_vat_flag  => lv_process_vat_flag,
      p_process_vat_message => lv_process_vat_message,
      p_called_from       => p_called_from,
      p_simulate_flag     => p_simulate_flag,
      p_codepath          => p_codepath
  );

  p_codepath := jai_general_pkg.plot_codepath(2, p_codepath);

  -- ERROR occured in Validate transaction. So proceed with next transaction
  -- We should not check for 'X' here. Because Cenvat can be 'N' which should be processed
  -- process_flag = 'E' means somehow an error occured in Validate transaction
  IF p_process_flag = 'E' THEN
    p_common_err_mesg := p_process_message;
    GOTO exit_processing;
  END IF;

  lv_statement_id := '2';
  --removed the cursor c_trx() from here by Ramananda for bug#4519697

  IF r_trx.transaction_type = 'CORRECT' THEN
    lv_transaction_type := r_trx.parent_transaction_type;
  ELSE
    lv_transaction_type := r_trx.transaction_type;
  END IF;

  -- "MATCH" included by Vijay Shankar for Bug#3940588
  IF lv_transaction_type NOT IN ( 'RECEIVE', 'DELIVER', 'RETURN TO RECEIVING', 'RETURN TO VENDOR', 'MATCH' ) THEN
    -- Localization donot support these transactions. So, Pls return back
    FND_FILE.put_line(FND_FILE.log, lv_object_code||'Localization doesnot support this transaction type');
    RETURN;
  END IF;

  p_codepath := jai_general_pkg.plot_codepath(3, p_codepath);

  ------------ Start of PROCESS_FLAG Execution ----------
  -- IF p_process_flag IN ('N','E') THEN
  IF p_simulate_flag = 'Y'
    OR p_process_flag IN ('N')
  THEN

    lv_statement_id := '3';
    SAVEPOINT process_trxn_flag;

    lv_execution_point := 'START_PROCESS_FLAG';

    IF lv_transaction_type IN ( 'RECEIVE', 'RETURN TO VENDOR') THEN
      lv_statement_id := '4';
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath);

      jai_rcv_rcv_rtv_pkg.process_transaction(
          p_transaction_id    => p_transaction_id,
          p_simulation        => p_simulate_flag,
          p_process_flag      => p_process_flag,
          p_process_message   => p_process_message,
          p_debug             => lv_debug,
          p_codepath          => p_codepath
       );

    ELSIF lv_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING') THEN

      lv_statement_id := '5';
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath);

      jai_rcv_deliver_rtr_pkg.process_transaction (
          p_transaction_id    => p_transaction_id,
          p_simulate          => p_simulate_flag,
          p_codepath          => p_codepath,
          p_process_status    => p_process_flag,
          p_process_message   => p_process_message
      );

    ELSE
      FND_FILE.put_line( FND_FILE.log, '1****** No Codepath  ******');
    END IF;

    lv_execution_point := 'END_PROCESS_FLAG';

    lv_statement_id := '6';
    IF p_process_flag IN ('E', 'X') THEN
      FND_FILE.put_line(FND_FILE.log, 'PRC_FLG_Error: RollingBack to process_trxn_flag');
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath);
      ROLLBACK TO process_trxn_flag;
    ElSIF p_process_flag = 'Y' THEN
      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);
      p_process_message := 'Successful';
    ELSE
      FND_FILE.put_line(FND_FILE.log, '1#PRC_FLG#'||p_process_flag);
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
    END IF;

  END IF;

  FND_FILE.put_line(FND_FILE.log, '2#PRC_FLG#'||p_process_flag);
  ------------ End of PROCESS_FLAG Execution ----------

  lv_statement_id := '7';
  ln_cenvat_claimed_ptg := r_trx.cenvat_claimed_ptg;
  FND_FILE.put_line(FND_FILE.log, 'r_trx.item_class:'||r_trx.item_class);
  FND_FILE.put_line(FND_FILE.log, 'lv_online_qty_flag:'||lv_online_qty_flag);

    /*bgowrava for forward porting Bug#5756676..start*/
    IF lv_online_qty_flag = 'Y' THEN

       SAVEPOINT process_online_qty;

       IF r_base_trx.attr_cat = 'India RMA Receipt' AND r_trx.item_class IN ('FGIN', 'FGEX', 'CCIN', 'CCEX')
             /*following OR added for bug 8319304*/
               OR (r_base_trx.attr_Cat = 'India Receipt' and r_base_trx.source_document_Code = 'INVENTORY' AND r_trx.item_class IN ('FGIN', 'FGEX', 'CCIN', 'CCEX')) THEN

          FND_FILE.put_line(FND_FILE.log, 'Calling ja_in_receipt_cenvat_rg_pkg.rg_i_entry');

             /*bug 7662347*/
            IF lv_transaction_type = 'RETURN TO VENDOR' THEN
              lv_qty_register_entry_type := 'Dr';
            ELSE
              lv_qty_register_entry_type := 'Cr';
            END IF;

          jai_rcv_excise_processing_pkg.rg_i_entry(
                                                p_transaction_id       => r_trx.transaction_id,
                                                pr_tax                 => NULL,
                                                p_register_entry_type  => lv_qty_register_entry_type,   /*bug 7662347*/
                                                p_register_id          => ln_part_i_register_id,
                                                p_process_status       => lv_process_status,
                                                p_process_message      => lv_process_message,
                                                p_simulate_flag        => p_simulate_flag,
                                                p_codepath             => p_codepath
                                               );

          FND_FILE.put_line(FND_FILE.log, 'ln_part_i_register_id:'||ln_part_i_register_id);

        ELSIF r_trx.item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX', 'CGIN', 'CGEX') THEN

          lv_register_type := jai_general_pkg.get_rg_register_type( p_item_class  => r_trx.item_class);

          FND_FILE.put_line(FND_FILE.log, 'Register Type:'||lv_register_type);

          -- to determine the way in which CGIN Items are Processed
          IF lv_register_type = 'C' THEN
            jai_rcv_excise_processing_pkg.derive_cgin_scenario(
                                                              p_transaction_id  => p_transaction_id,
                                                              p_cgin_code       => lv_cgin_code,
                                                              p_process_status  => lv_process_status,
                                                              p_process_message => lv_process_message,
                                                              p_codepath        => p_codepath
                                                          );

            FND_FILE.put_line(FND_FILE.log, 'CGIN_CODE->'||lv_cgin_code);
          END IF;
          -- RG23 Part I Entry is already made during first Claim, in case of CGIN Items
          -- So no need of another entry during Second 50% Claim of CENVAT
          IF nvl(lv_cgin_code, 'XXX') <> 'REGULAR-HALF' THEN

            FND_FILE.put_line(FND_FILE.log, 'Calling ja_in_receipt_cenvat_rg_pkg.rg23_part_i_entry');

             /*bug 7662347*/
            IF lv_transaction_type = 'RETURN TO VENDOR' THEN
              lv_qty_register_entry_type := 'Dr';
            ELSE
              lv_qty_register_entry_type := 'Cr';
            END IF;

            jai_rcv_excise_processing_pkg.rg23_part_i_entry(
                                                          p_transaction_id       => r_trx.transaction_id,
                                                          pr_tax                 => NULL,
                                                          p_register_entry_type  => lv_qty_register_entry_type,   /*bug 7662347*/
                                                          p_register_id          => ln_part_i_register_id,
                                                          p_process_status       => lv_process_status,
                                                          p_process_message      => lv_process_message,
                                                          p_simulate_flag        => p_simulate_flag,
                                                          p_codepath             => p_codepath
                                                      );

            --lv_qty_register := 'RG23';

          ELSE
            FND_FILE.put_line( FND_FILE.log, 'No Call to RG23_PART_I_ENTRY');
          END IF;

        END IF;

        IF lv_process_status in ('E','X') THEN
          ROLLBACK TO PROCESS_ONLINE_QTY;
        END IF;

    END IF;

/*bgowrava for forward porting Bug#5756676..end*/

  /* RG/Cenvat Works only incase if its not a Simulation. Because simulation is not implemented for CENVAT Part */
  IF p_simulate_flag = 'N'
    AND ( -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_cenvat_rg_flag IN ('N', 'E')
          -- condition modified as part of DFF Elimination. Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
          ( p_excise_processing_reqd = jai_constants.yes  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
            AND p_cenvat_rg_flag IN ('N', 'E','C') /*Added by nprashar for bug # 8644480 */
            AND (r_trx.transaction_type <> 'RETURN TO VENDOR'
                 OR (r_trx.transaction_type = 'RETURN TO VENDOR' and  p_called_from = CALLED_FROM_JAITIGRTV) -- nvl(r_trx.attribute1,'XXX')<> INV_GEN_STATUS_PENDING)
                 )
          )
          -- following condition will be satisfied during 2nd 50% claim of CGIN items when called from JAINMVAT form
          -- Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
          OR (p_called_from='JAINMVAT' AND r_trx.cenvat_rg_status='Y')
          OR (p_process_special_reason = jai_rcv_excise_processing_pkg.second_50ptg_claim AND ln_cenvat_claimed_ptg < 100)
        )
  THEN

    SAVEPOINT process_cenvat_rg_flag;

    lv_execution_point := 'START_CENVAT_FLAG';

    IF lv_transaction_type IN ( 'RECEIVE', 'RETURN TO VENDOR', 'DELIVER', 'RETURN TO RECEIVING') THEN
      -- this call passes the cenvat related accounting and register entries based on transaction type
      lv_statement_id := '8';
      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath);

      jai_rcv_excise_processing_pkg.process_transaction(
          p_transaction_id   => p_transaction_id,
          p_process_status   => p_cenvat_rg_flag,
          p_cenvat_claimed_ptg  => ln_cenvat_claimed_ptg,
          p_process_message  => p_cenvat_rg_message,
          p_simulate_flag    => p_simulate_flag,
          p_codepath         => p_codepath,
          -- following added by Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
          p_process_special_reason    => p_process_special_reason,
          p_process_special_qty       => p_process_special_qty
      );

    ELSE
      FND_FILE.put_line( FND_FILE.log, lv_object_code||'Transaction type Not supported for cenvat Entries');
    END IF;

    lv_execution_point := 'END_CENVAT_FLAG';

    lv_statement_id := '9';
    IF p_cenvat_rg_flag IN ('E', 'X') THEN
      FND_FILE.put_line(FND_FILE.log, 'CEN_FLG_Error: RollingBack to process_cenvat_rg_flag');
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath);
      ROLLBACK TO process_cenvat_rg_flag;
    ElSIF p_cenvat_rg_flag = 'Y' THEN
      p_cenvat_rg_message := 'Successful';
      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath);
    ELSE
      FND_FILE.put_line(FND_FILE.log, '1#CENVAT_FLG#'||p_cenvat_rg_flag);
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath);
    END IF;

  END IF;

  FND_FILE.put_line(FND_FILE.log, '2#CENVAT_FLG#'||p_cenvat_rg_flag);
  /* End of CENVAT_RG_FLAG Execution */

  lv_statement_id := '10';
  p_codepath := jai_general_pkg.plot_codepath(13, p_codepath);

  /* Start of VAT Execution. Vijay Shankar for Bug#4250236(4245089) */
  IF p_simulate_flag = 'N'
    AND -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. lv_process_vat_flag IN ('N', 'E')
    ( p_vat_processing_reqd = jai_constants.yes    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
      AND lv_process_vat_flag IN ('N', 'E', jai_constants.expected_error, jai_constants.unexpected_error)
      AND (r_trx.transaction_type <> 'RETURN TO VENDOR'
           OR (r_trx.transaction_type = 'RETURN TO VENDOR' and p_called_from = CALLED_FROM_JAITIGRTV)
           )
    )
  THEN

    SAVEPOINT process_vat_flag;

    lv_execution_point := 'START_PROCESS_VAT';

    IF lv_transaction_type IN ( 'RECEIVE', 'RETURN TO VENDOR') THEN
      -- this call passes the cenvat related accounting and register entries based on transaction type
      lv_statement_id := '11';
      p_codepath := jai_general_pkg.plot_codepath(14, p_codepath);

      jai_rcv_rgm_claims_pkg.process_vat(
        p_transaction_id      => p_transaction_id,
        p_process_status      => lv_process_vat_flag,
        p_process_message     => lv_process_vat_message
      );

    ELSE
      FND_FILE.put_line( FND_FILE.log, lv_object_code||'Trxn not supported for VAT processing');
    END IF;

    lv_execution_point := 'END_PROCESS_VAT';

    lv_statement_id := '12';
    IF lv_process_vat_flag = jai_constants.successful THEN
      lv_process_vat_message := 'Successful';
      p_codepath := jai_general_pkg.plot_codepath(16, p_codepath);
    ELSIF lv_process_vat_flag <> jai_constants.successful THEN
      FND_FILE.put_line(FND_FILE.log, 'PrcVatFlg Err: RollingBack to process_vat_flag. Mesg:'||lv_process_vat_message);
      p_codepath := jai_general_pkg.plot_codepath(15, p_codepath);
      ROLLBACK TO process_vat_flag;
    ELSE
      FND_FILE.put_line(FND_FILE.log, '1#PrcVatFlg#'||lv_process_vat_flag);
      p_codepath := jai_general_pkg.plot_codepath(17, p_codepath);
    END IF;

  END IF;

  FND_FILE.put_line(FND_FILE.log, '2#PrcVatFlg#'||lv_process_vat_flag);
  /* End of VAT Execution */

  lv_statement_id := '14';
  p_codepath := jai_general_pkg.plot_codepath(18, p_codepath);

  IF p_simulate_flag = 'N' THEN

    jai_rcv_transactions_pkg.update_process_flags(
        p_transaction_id      => p_transaction_id,
        p_process_flag        => p_process_flag,
        p_process_message     => p_process_message,
        p_cenvat_rg_flag      => p_cenvat_rg_flag,
        p_cenvat_claimed_ptg  => ln_cenvat_claimed_ptg,
        p_cenvat_rg_message   => p_cenvat_rg_message,
        p_process_vat_flag    => lv_process_vat_flag,
        p_process_vat_message => lv_process_vat_message,
        /*Vijay Shankar for Bug#4250171 p_process_vat_flag    => null,
        p_process_vat_message => null,
        */p_process_date        => SYSDATE
    );

  END IF;
  <<exit_processing>>

  FND_FILE.put_line(FND_FILE.log, '$End of Trx:'||p_transaction_id||'. Time:'||to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

  p_codepath := jai_general_pkg.plot_codepath(99, p_codepath, null, 'END');

EXCEPTION
  WHEN OTHERS THEN
    p_common_err_mesg := 'RECEIPT_TRANSACTIONS_PKG.process_transaction(StmtId:'||lv_statement_id||'). Error:'||SQLERRM;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_common_err_mesg);
    IF p_process_flag <> 'Y' THEN
      p_process_flag      := 'E';
      p_process_message   := p_common_err_mesg;
    ELSIF p_cenvat_rg_flag <> 'Y' THEN
      p_cenvat_rg_flag    := 'E';
      p_cenvat_rg_message := p_common_err_mesg;
    ELSE
      -- dont update any of the fields of JAI_RCV_TRANSACTIONS table
      NULL;
    END IF;
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');

END process_transaction;

/* ~~~~~~~~~~~~~~~~~~~~ POPULATION of DETAILS Procedure ~~~~~~~~~~~~~~~~~~~~~~~~*/

PROCEDURE populate_details(
  p_transaction_id    IN  NUMBER,
  p_process_status OUT NOCOPY VARCHAR2,
  p_process_message OUT NOCOPY VARCHAR2,
  p_simulate_flag     IN  VARCHAR2,
  p_codepath          IN OUT NOCOPY VARCHAR2
) IS

  CURSOR c_shp_line_dtls(cp_shipment_line_id IN NUMBER) IS
    SELECT shipment_line_id, item_id
    FROM rcv_shipment_lines
    WHERE shipment_line_id = cp_shipment_line_id;

  CURSOR c_shp_hdr_dtls(cp_shipment_header_id IN NUMBER) IS
    SELECT shipment_header_id, receipt_num
    FROM rcv_shipment_headers
    WHERE shipment_header_id = cp_shipment_header_id;

  CURSOR c_loc_item_dtls(cp_organization_id IN NUMBER, cp_inventory_item_id IN NUMBER) IS
    SELECT item_class, modvat_flag, excise_flag, item_trading_flag
    FROM JAI_INV_ITM_SETUPS
    WHERE organization_id = cp_organization_id
    AND inventory_item_id = cp_inventory_item_id;

  CURSOR c_base_item_dtls(cp_organization_id IN NUMBER, cp_inventory_item_id IN NUMBER) IS
    SELECT inventory_item_flag, inventory_asset_flag
    FROM mtl_system_items
    WHERE organization_id = cp_organization_id
    AND inventory_item_id = cp_inventory_item_id;

  CURSOR c_loc_orgn_dtls(cp_organization_id IN NUMBER) IS
    SELECT decode( manufacturing, 'Y', 'M', decode(trading, 'Y', 'T', 'X')) organization_type, excise_in_rg23d
    FROM JAI_CMN_INVENTORY_ORGS
    WHERE organization_id = cp_organization_id
    AND location_id = 0;

  CURSOR c_mtl_params(cp_organization_id IN NUMBER) IS
    SELECT primary_cost_method
    FROM mtl_parameters
    WHERE organization_id = cp_organization_id;

  CURSOR c_inv_org_linked_to_location(cp_location_id IN NUMBER) IS
    SELECT nvl(inventory_organization_id, -99999) inventory_organization_id
    FROM hr_locations_all
    WHERE location_id = cp_location_id;

  CURSOR c_loc_linked_to_org_subinv(cp_organization_id IN NUMBER, cp_subinventory IN VARCHAR2) IS
    SELECT location_id, decode(bonded, 'Y', 'B', decode(trading, 'Y', 'T', 'N')) loc_subinventory_type
    FROM JAI_INV_SUBINV_DTLS
    WHERE organization_id = cp_organization_id
    AND sub_inventory_name = cp_subinventory;

  CURSOR c_base_subinv_dtls(cp_organization_id IN NUMBER, cp_subinventory IN VARCHAR2) IS
    SELECT asset_inventory
    FROM mtl_secondary_inventories
    WHERE organization_id = cp_organization_id
    AND secondary_inventory_name = cp_subinventory;

  -- porting from Bug#3949109 (3927371)
  CURSOR c_dlry_subinventory(cp_shipment_line_id IN NUMBER, cp_receive_trx_id IN NUMBER, cp_transaction_type rcv_transactions.transaction_type%type) IS
    SELECT subinventory
    FROM rcv_transactions
    WHERE shipment_line_id = cp_shipment_line_id
    AND parent_transaction_id = cp_receive_trx_id
    AND transaction_type = cp_transaction_type --'DELIVER'
    AND transaction_id > cp_receive_trx_id;

  -- Start, Vijay Shankar for Bug#3940588
  ln_tax_transaction_id       JAI_RCV_TRANSACTIONS.tax_transaction_id%TYPE;
  ln_non_po_vendor_cnt        NUMBER;
  lv_third_party_flag         VARCHAR2(1);

  CURSOR c_non_po_vendor_cnt(cp_shipment_header_id IN NUMBER, cp_shipment_line_id IN NUMBER) IS /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    SELECT nvl(count(distinct vendor_id), 0)
    from JAI_RCV_LINE_TAXES
    where shipment_line_id = cp_shipment_line_id
    AND   vendor_id <> (SELECT vendor_id
            FROM   rcv_shipment_headers
            WHERE  shipment_header_id = cp_shipment_header_id
           )
    AND   upper(tax_type) NOT IN (jai_constants.tax_type_tds, jai_constants.tax_type_modvat_recovery) --('TDS', 'MODVAT RECOVERY')
    AND   tax_amount > 0 ;
  -- End, Vijay Shankar for Bug#3940588
  /*
  || srjayara bug 5064235 -- forward porting for bug# 5054114
  || Cursor fetches the subinventory from rcv_transactiosn for DELIVER line
  || based on shipment_line_id of transaction_id passed to the cursor
  */
  CURSOR cur_dlry_subinv ( cp_transaction_id IN NUMBER ) IS
  SELECT  subinventory
  FROM    rcv_transactions
  WHERE   transaction_type = 'DELIVER'
  AND     shipment_line_id = (SELECT  shipment_line_id
                              FROM    jai_rcv_transactions
                              WHERE   transaction_id = cp_transaction_id);

  r_base_trx                  c_base_trx%ROWTYPE;
  r_parent_base_trx           c_base_trx%ROWTYPE;

  -- Vijay Shankar for Bug#4038024
  lv_required_trx_type        RCV_TRANSACTIONS.transaction_type%TYPE;

  r_ancestor_dtls             c_base_trx%ROWTYPE;
  r_shp_line_dtls             c_shp_line_dtls%ROWTYPE;
  r_shp_hdr_dtls              c_shp_hdr_dtls%ROWTYPE;
  r_loc_item_dtls             c_loc_item_dtls%ROWTYPE;
  r_base_item_dtls            c_base_item_dtls%ROWTYPE;
  r_loc_orgn_dtls             c_loc_orgn_dtls%ROWTYPE;
  r_mtl_params                c_mtl_params%ROWTYPE;
  r_base_subinv_dtls          c_base_subinv_dtls%ROWTYPE;
  r_subinv_dtls               c_loc_linked_to_org_subinv%ROWTYPE;


  ln_location_id              NUMBER(15);
  ln_organization_id          NUMBER(15);
  lv_subinventory             RCV_TRANSACTIONS.subinventory%TYPE;
  lv_transaction_type         RCV_TRANSACTIONS.transaction_type%TYPE;
  ln_ancestor_trxn_id         NUMBER(15);

  ln_tax_amount               NUMBER;
  ln_cenvat_amount            NUMBER;
  lv_loc_subinv_type          JAI_RCV_TRANSACTIONS.loc_subinv_type%TYPE;
  lv_base_subinv_asset_flag   JAI_RCV_TRANSACTIONS.BASE_ASSET_INVENTORY%TYPE;

  r_exc_inv_no                c_excise_invoice_no%ROWTYPE;

  /* Vijay Shankar for Bug#4250171 */
  r_trx                       c_trx%ROWTYPE;
  r_parent_trx                c_trx%ROWTYPE;    -- JAI_RCV_TRANSACTIONS record

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_trx_processing_pkg.populate_details';
  ln_tax_apportion_factor     jai_rcv_transactions.tax_apportion_factor%TYPE; --Added by Sanjikum for Bug#4495135

BEGIN

  IF lb_debug THEN
    FND_FILE.put_line(FND_FILE.log, '^ POPULATE_DETAILS');
  END IF;

  p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'populate_details', 'START');

  OPEN c_base_trx(p_transaction_id);
  FETCH c_base_trx INTO r_base_trx;
  CLOSE c_base_trx;

  /* Vijay Shankar for Bug#4250171 */
  OPEN c_trx(p_transaction_id);
  FETCH c_trx INTO r_trx;
  CLOSE c_trx;

  IF r_base_trx.parent_transaction_id > 0 THEN
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath);
    OPEN c_base_trx(r_base_trx.parent_transaction_id);
    FETCH c_base_trx INTO r_parent_base_trx;
    CLOSE c_base_trx;
  END IF;

  OPEN c_shp_line_dtls(r_base_trx.shipment_line_id);
  FETCH c_shp_line_dtls INTO r_shp_line_dtls;
  CLOSE c_shp_line_dtls;

  OPEN c_shp_hdr_dtls(r_base_trx.shipment_header_id);
  FETCH c_shp_hdr_dtls INTO r_shp_hdr_dtls;
  CLOSE c_shp_hdr_dtls;

  OPEN c_loc_item_dtls(r_base_trx.organization_id, r_shp_line_dtls.item_id);
  FETCH c_loc_item_dtls INTO r_loc_item_dtls;
  CLOSE c_loc_item_dtls;

  OPEN c_base_item_dtls(r_base_trx.organization_id, r_shp_line_dtls.item_id);
  FETCH c_base_item_dtls INTO r_base_item_dtls;
  CLOSE c_base_item_dtls;

  OPEN c_loc_orgn_dtls(r_base_trx.organization_id);
  FETCH c_loc_orgn_dtls INTO r_loc_orgn_dtls;
  CLOSE c_loc_orgn_dtls;

  OPEN c_mtl_params(r_base_trx.organization_id);
  FETCH c_mtl_params INTO r_mtl_params;
  CLOSE c_mtl_params;

  /* following if condition added as part of DFF elimination
  Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  if lv_transaction_type <> 'RETURN TO VENDOR' then
    OPEN c_excise_invoice_no(r_base_trx.shipment_line_id);
    FETCH c_excise_invoice_no INTO r_exc_inv_no;
    CLOSE c_excise_invoice_no;
  end if;

  IF r_base_trx.transaction_type = 'CORRECT' THEN
    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath);
    lv_transaction_type := r_parent_base_trx.transaction_type;
  ELSE
    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath);
    lv_transaction_type := r_base_trx.transaction_type;
  END IF;

  -- Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
  -- this is coded to support UNORDERED Transactions by localization in new receipts code. Shall chk the impact
  IF r_base_trx.transaction_type = 'MATCH' THEN
    lv_transaction_type := 'RECEIVE';
    UPDATE JAI_RCV_TRANSACTIONS
    SET transaction_type = lv_transaction_type
    WHERE transaction_id = p_transaction_id;
  END IF;

  /* Vijay Shankar for Bug#4250171 */
  /* following if condition added to OPM for VAT Functionality */
  IF r_trx.trx_information in (OPM_RECEIPT,OPM_RETURNS) THEN --Modified by Bo Li for replacing the attribute_category with trx_information
    IF lv_transaction_type = 'RETURN TO VENDOR' THEN
      OPEN c_trx(r_trx.parent_transaction_id);
      FETCH c_trx INTO r_parent_trx;
      CLOSE c_trx;

      ln_location_id := r_parent_trx.location_id;
      lv_subinventory := r_base_trx.subinventory;
    ELSE
      ln_location_id := r_trx.location_id;
      lv_subinventory := r_base_trx.subinventory;
    END IF;

  -- if both location and subinventory are NULL then goto the parent type i.e RTV to RECEIVE and RTR to DELIVER
  ELSIF nvl(r_base_trx.location_id, 0) = 0 AND nvl(r_base_trx.subinventory, '-XX') = '-XX' THEN

    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath);
    -- following condition added by Vijay Shankar for Bug#4038024. Incase of CORRECT transactions, if location and subinventory
    -- are not present, then we need to look at parent transaction for location. this will mostly happen for DIRECT DELIVERY case
    IF lv_transaction_type IN ('RETURN TO RECEIVING', 'RETURN TO VENDOR')
      OR (r_base_trx.transaction_type = 'CORRECT' AND r_parent_base_trx.transaction_type IN ('RECEIVE', 'DELIVER')) -- BUG#3949502. (3927371)
    THEN

      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath);
      OPEN c_trx(r_base_trx.parent_transaction_id);
      FETCH c_trx INTO r_parent_trx;
      CLOSE c_trx;

      ln_location_id := r_parent_trx.location_id;

    -- following IF condition added as part of porting from Bug#3949109 (3927371)
    -- Incase of Direct Delivery RECEIVE transaction may not have both the location and subinventory. In this case we need to fetch the
    -- subinventory from DELIVER transaction
    ELSIF lv_transaction_type = 'RECEIVE' AND r_base_trx.routing_header_id = 3 THEN   -- this will not execute for correct transactions
      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath);
      OPEN c_dlry_subinventory(r_base_trx.shipment_line_id, p_transaction_id, 'DELIVER');
      FETCH c_dlry_subinventory INTO lv_subinventory;
      CLOSE c_dlry_subinventory;

    END IF;

    IF (lv_transaction_type in ('RETURN TO RECEIVING', 'DELIVER') AND nvl(lv_subinventory,'-XX')='-XX')
      OR (lv_transaction_type in ('RETURN TO VENDOR', 'RECEIVE') AND nvl(ln_location_id,0)=0 AND nvl(lv_subinventory,'-XX')='-XX' )
    THEN

      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath);
      IF lv_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING') THEN
        lv_required_trx_type := 'DELIVER';
      ELSIF lv_transaction_type IN ('RECEIVE', 'RETURN TO VENDOR') THEN
        lv_required_trx_type := 'RECEIVE';
      END IF;

      ln_ancestor_trxn_id := get_ancestor_id(
                                p_transaction_id    => p_transaction_id,
                                p_shipment_line_id  => r_base_trx.shipment_line_id,
                                p_required_trx_type => lv_required_trx_type
                             );

      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath);
      IF ln_ancestor_trxn_id IS NOT NULL THEN
        p_codepath := jai_general_pkg.plot_codepath(10, p_codepath);
        OPEN c_base_trx(ln_ancestor_trxn_id);
        FETCH c_base_trx INTO r_ancestor_dtls;
        CLOSE c_base_trx;

        ln_location_id    := r_ancestor_dtls.location_id;
        lv_subinventory   := r_ancestor_dtls.subinventory;
      END IF;

    END IF;

  ELSE
    p_codepath := jai_general_pkg.plot_codepath(11, p_codepath);
    ln_location_id := r_base_trx.location_id;
    lv_subinventory := r_base_trx.subinventory;
  END IF;

  /* added this end if to support VAT Func for OPM . Vijay Shankar for Bug#4250171*/
  IF nvl(r_trx.attribute_category, 'XXXX') NOT IN (OPM_RECEIPT, OPM_RETURNS) THEN
    /*
    || srjayara bug 5064235 -- forward porting for bug# 5054114
    || Added if condition .. end if to populate the subinventory from DELIVER line
    || in rcv_transactions
    */
    IF lv_subinventory IS NULL THEN
       OPEN  cur_dlry_subinv ( p_transaction_id );
       FETCH cur_dlry_subinv INTO lv_subinventory ;
       CLOSE cur_dlry_subinv ;
    END IF ;


    IF lv_subinventory IS NOT NULL THEN
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath);
      OPEN c_loc_linked_to_org_subinv(r_base_trx.organization_id, lv_subinventory);
      FETCH c_loc_linked_to_org_subinv INTO r_subinv_dtls;
      CLOSE c_loc_linked_to_org_subinv;

      OPEN c_base_subinv_dtls(r_base_trx.organization_id, lv_subinventory);
      FETCH c_base_subinv_dtls INTO r_base_subinv_dtls;
      CLOSE c_base_subinv_dtls;

      IF (nvl(ln_location_id,0) = 0
        /* following condition added by Vijay Shankar for Bug#4278511 to take care of ISO Scenario */
        /* Bug 4589354. Added by Lakshmi Gopalsami.
           Commented the following condition.
        OR (r_base_trx.source_document_code = 'REQ' and */
        OR nvl(r_subinv_dtls.location_id, 0) <> 0 )
      THEN
        p_codepath := jai_general_pkg.plot_codepath(13, p_codepath);
        ln_location_id := r_subinv_dtls.location_id;
      END IF;

      lv_loc_subinv_type        := r_subinv_dtls.loc_subinventory_type;
      lv_base_subinv_asset_flag := r_base_subinv_dtls.asset_inventory;

    END IF;

    -- IF nvl(ln_location_id, 0) = 0 THEN
    IF nvl(ln_location_id, 0) <> 0 THEN
      p_codepath := jai_general_pkg.plot_codepath(14, p_codepath);
      -- OPEN c_inv_org_linked_to_location(r_base_trx.organization_id);
      OPEN c_inv_org_linked_to_location(ln_location_id);
      FETCH c_inv_org_linked_to_location INTO ln_organization_id;
      CLOSE c_inv_org_linked_to_location;

      IF r_base_trx.organization_id <> ln_organization_id THEN
        p_codepath := jai_general_pkg.plot_codepath(15, p_codepath);
        ln_location_id := 0;
      END IF;
    END IF;

  END IF; /* added this end if to support VAT Func for OPM . Vijay Shankar for Bug#4250171*/

  /* Bug 4586752. Added by Lakshmi Gopalsami
   * Assigned the value of location_id to the local variable */
   IF NVL(ln_location_id,0) = 0 THEN
     ln_location_id := r_base_trx.location_id;
   END IF;

  p_codepath := jai_general_pkg.plot_codepath(16, p_codepath);
  ln_tax_amount     := get_trxn_tax_amount(
                          p_transaction_id      => p_transaction_id,
                          p_shipment_line_id    => r_base_trx.shipment_line_id,
                          p_curr_conv_rate      => r_base_trx.currency_conversion_rate,
                          p_return_in_inr_curr => jai_constants.yes --File.Sql.35 Cbabu
                       );

  ln_cenvat_amount  := get_trxn_cenvat_amount(
                          p_transaction_id      => p_transaction_id,
                          p_shipment_line_id    => r_base_trx.shipment_line_id,
                          p_organization_type   => r_loc_orgn_dtls.organization_type,
                          p_curr_conv_rate      => r_base_trx.currency_conversion_rate
                       );

  --Start, added by Vijay Shankar for Bug#3940588
  ln_tax_transaction_id := get_ancestor_id(
                            p_transaction_id    => p_transaction_id,
                            p_shipment_line_id  => r_base_trx.shipment_line_id,
                            p_required_trx_type => 'RECEIVE'
                         );

  -- Third Party invoice flag should be set only at LINE level which is first transaction of Receipt
  -- i.e RECEIVE or MATCH or CORRECT of RECEIVE
  IF lv_transaction_type IN ('RECEIVE', 'MATCH') THEN
    OPEN c_non_po_vendor_cnt(r_base_trx.shipment_header_id, r_base_trx.shipment_line_id);
    FETCH c_non_po_vendor_cnt INTO ln_non_po_vendor_cnt;
    CLOSE c_non_po_vendor_cnt;

    IF ln_non_po_vendor_cnt > 0 THEN
      lv_third_party_flag := 'N';
    ELSE
      lv_third_party_flag := 'X';
    END IF;
  ELSE
    lv_third_party_flag := 'X';
  END IF;
  -- End, added by Vijay Shankar for Bug#3940588

  IF lb_debug THEN
    FND_FILE.put_line(FND_FILE.log, '... RecNum:'||r_shp_hdr_dtls.receipt_num ||',p_cenvat_amount:'||ln_cenvat_amount );
  END IF;

  p_codepath := jai_general_pkg.plot_codepath(17, p_codepath);
  jai_rcv_transactions_pkg.update_row(
    p_transaction_id            => p_transaction_id,
    p_parent_transaction_type   => r_parent_base_trx.transaction_type,
    p_receipt_num               => r_shp_hdr_dtls.receipt_num,
    p_inventory_item_id         => r_shp_line_dtls.item_id,
    p_item_class                => nvl(r_loc_item_dtls.item_class, NO_ITEM_CLASS),
    p_item_cenvatable           => nvl(r_loc_item_dtls.modvat_flag, NO_SETUP),
    p_item_excisable            => nvl(r_loc_item_dtls.excise_flag, NO_SETUP),
    p_item_trading_flag         => nvl(r_loc_item_dtls.item_trading_flag, NO_SETUP),
    p_inv_item_flag             => nvl(r_base_item_dtls.inventory_item_flag, 'N'),
    p_inv_asset_flag            => r_base_item_dtls.inventory_asset_flag,
    p_location_id               => nvl(ln_location_id, 0),
    p_loc_subinv_type           => nvl(lv_loc_subinv_type, NO_SETUP),
    p_base_subinv_asset_flag    => lv_base_subinv_asset_flag,
    p_organization_type         => r_loc_orgn_dtls.organization_type,
    p_excise_in_trading         => nvl(r_loc_orgn_dtls.excise_in_rg23d, 'N'),
    p_costing_method            => r_mtl_params.primary_cost_method,
    p_boe_applied_flag          => NULL,
    p_third_party_flag          => lv_third_party_flag,       -- Vijay Shankar for Bug#3940588
    p_tax_amount                => ln_tax_amount,
    p_cenvat_amount             => ln_cenvat_amount,
    p_excise_invoice_no         => r_exc_inv_no.excise_invoice_no,
    p_excise_invoice_date       => r_exc_inv_no.excise_invoice_date,
    p_tax_transaction_id        => ln_tax_transaction_id,     -- Vijay Shankar for Bug#3940588
    p_assessable_value          => NULL                       -- This needs to be populated during Tax Calculation itself
  );


p_codepath := jai_general_pkg.plot_codepath(18, p_codepath);

  --Start Added by Sanjikum for Bug#4495135
  ln_tax_apportion_factor := get_apportion_factor(p_transaction_id);

p_codepath := jai_general_pkg.plot_codepath(19, p_codepath);
  --This update can't be merged with the above, as get_apportion_factor uses the column tax_transaction_id
  --which is updated only in the above update

  jai_rcv_transactions_pkg.update_row(
    p_transaction_id            => p_transaction_id,
    p_tax_apportion_factor      => ln_tax_apportion_factor
  );
  --End Added by Sanjikum for Bug#4495135

  p_codepath := jai_general_pkg.plot_codepath(20, p_codepath, 'populate_details', 'END');

  IF lb_debug THEN
    FND_FILE.put_line(FND_FILE.log, '$ POPULATE_DETAILS');
  END IF;

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
        p_process_status  := null;
        p_process_message := null;
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END populate_details;

/* ~~~~~~~~~~~~~~~~~~~~ TRANSACTION VALIDATION Procedure ~~~~~~~~~~~~~~~~~~~~~~~~*/

PROCEDURE validate_transaction (
  p_transaction_id      IN      NUMBER,
  p_process_flag        IN OUT NOCOPY VARCHAR2,
  p_process_message     IN OUT NOCOPY VARCHAR2,
  p_cenvat_rg_flag      IN OUT NOCOPY VARCHAR2,
  p_cenvat_rg_message   IN OUT NOCOPY VARCHAR2,
  /* following two flags introduced by Vijay Shankar for Bug#4250236(4245089). VAT Implementation */
  p_process_vat_flag    IN OUT NOCOPY VARCHAR2,
  p_process_vat_message IN OUT NOCOPY VARCHAR2,
  p_called_from         IN      VARCHAR2,
  p_simulate_flag       IN      VARCHAR2,
  p_codepath            IN OUT NOCOPY VARCHAR2
) IS

/*---------------------------------------------
Functionality of this Procedure :
0. If some Scenario has to be Supported/UnSupported by Localization, then this needs to be changed as everything is
   driven based on Flags set in this procedure
1. This Procedure is to set Process Flags or cenvat RG Flag in JAI_RCV_TRANSACTIONS.
      Possible Values :
      ===================
      X - Not Applicable (All values prefexing X means variations of Non Applicability with exact problem)
      P - Pending for Parent transaction to be Processed
      N - To be Processed
      E - Errored out - Populate Error Message during Transaction Processing
      Y - Already Processed
      O - Others - Populate Information Message.
      C -  Entire Quantity Correction has been perfomed after Claim
  CenvatRGFlag Values (All the Values Starting with X mean the Cenvat enries cant be passed and second letter onwards it gives the exactness of problem
  -------------------
  XT - Indicates that Cenvat Entries cant be passed as there is a Change of Month between parent and this transaction

OPEN ISSUES:
 - Third Party Flag needs to be Updated if CORRECTion transactions has to uptake the TP functionality or Whole Receipts
   functionality is moved into the this NEW RECEIPTS CODE
 - Assessable value needs to be populated

---------------------------------------------*/

  CURSOR c_trx(cp_transaction_id IN NUMBER) IS
    SELECT *
    FROM JAI_RCV_TRANSACTIONS
    WHERE transaction_id = cp_transaction_id;

  CURSOR c_receipt_line_dtls(cp_shipment_line_id JAI_RCV_TRANSACTIONS.shipment_line_id%type) is
    SELECT excise_invoice_no, excise_invoice_date, online_claim_flag,
      claim_modvat_flag, nvl(rma_type, 'XXXX') rma_type
    FROM JAI_RCV_LINES
    WHERE  shipment_line_id = cp_shipment_line_id;

  CURSOR c_taxes(cp_shipment_line_id JAI_RCV_TRANSACTIONS.shipment_line_id%type) is /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    SELECT  count(1) total_cnt,
        sum( decode(upper(tax_type), 'EXCISE', 1,
                               'ADDL. EXCISE', 1,
             'OTHER EXCISE', 1,
             'CVD', 1,
             jai_constants.tax_type_add_cvd,1,
              -- Modified by SACSETHI Bug# 5228046
              -- Forward porting the change in 11i bug 5365523
                                      -- (Additional CVD Enhancement) as part of the R12 bug 5228046
                                     jai_constants.tax_type_exc_edu_cess,1,
             jai_constants.tax_type_cvd_edu_cess,1,jai_constants.tax_type_sh_exc_edu_cess,1,
                                     jai_constants.tax_type_sh_cvd_edu_cess,1, 0)  --kunkumar for bugno5989740   -- Vijay Shankar for Bug#3940588 EDU CESS
           ) excise_cnt
    FROM   JAI_RCV_LINE_TAXES
    WHERE  shipment_line_id = cp_shipment_line_id
    AND    tax_type not in (jai_constants.tax_type_tds, jai_constants.tax_type_modvat_recovery); --('TDS', 'MODVAT RECOVERY')

  CURSOR c_excise_tax_count(cp_shipment_line_id JAI_RCV_TRANSACTIONS.shipment_line_id%type) is
    SELECT count(1)
    FROM   JAI_RCV_LINE_TAXES
    WHERE  shipment_line_id = cp_shipment_line_id
    -- AND    tax_type NOT IN ('TDS','Modvat Recovery')
    AND modvat_flag = jai_constants.yes
    AND upper(tax_type) IN ( 'EXCISE',
                             'ADDL. EXCISE',
           'OTHER EXCISE',
           'CVD',
          jai_constants.tax_type_add_cvd  ,
              -- Modified by SACSETHI Bug# 5228046
              -- Forward porting the change in 11i bug 5365523
                                      -- (Additional CVD Enhancement) as part of the R12 bug 5228046
                             jai_constants.tax_type_exc_edu_cess,
           jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_sh_exc_edu_cess,
                             jai_constants.tax_type_sh_cvd_edu_cess);--Added by kunkumar for bugno5989740   -- Vijay Shankar for Bug#3940588 EDU CESS


  ln_recoverable_vat_tax_cnt  NUMBER;
  CURSOR c_recoverable_vat_tax_cnt(cp_shipment_line_id number, cp_regime_code varchar2) is
    SELECT count(1)
    FROM JAI_RCV_LINE_TAXES
    WHERE shipment_line_id = cp_shipment_line_id
    AND modvat_flag = jai_constants.yes
    AND tax_type IN
      ( select tax_type from jai_regime_tax_types_v /*modified this to use View as part of OPM changes */
        where regime_code = cp_regime_code
      );

  CURSOR c_acct_count(cp_parent_transaction_id   JAI_RCV_TRANSACTIONS.transaction_id%type,
                      cp_parent_transaction_type JAI_RCV_TRANSACTIONS.parent_transaction_type%type
                     ) IS
    SELECT count(1)
    FROM   JAI_RCV_JOURNAL_ENTRIES
    WHERE  transaction_id    = cp_parent_transaction_id
    AND    transaction_type  = cp_parent_transaction_type;

  ld_parent_rg_entry_date  DATE;
  CURSOR c_rg_count(cp_parent_transaction_id   JAI_RCV_TRANSACTIONS.transaction_id%type,
                    cp_organization_id         JAI_RCV_TRANSACTIONS.organization_id%type
                   ) IS
    SELECT creation_date
    FROM (SELECT creation_date
          FROM   JAI_CMN_RG_23AC_II_TRXS
          WHERE  receipt_ref        = cp_parent_transaction_id
          AND    organization_id   = cp_organization_id
          AND   transaction_source_num = 18
          UNION
          SELECT creation_date
          FROM   JAI_CMN_RG_PLA_TRXS
          WHERE  ref_document_id   = cp_parent_transaction_id
          AND    organization_id   = cp_organization_id
          AND    transaction_source_num    = 19);

  CURSOR c_parent_rg23d_entry(
    cp_parent_transaction_id   JAI_RCV_TRANSACTIONS.transaction_id%type,
    cp_organization_id         JAI_RCV_TRANSACTIONS.organization_id%type
  ) IS
    SELECT creation_date
    FROM JAI_CMN_RG_23D_TRXS
    WHERE receipt_ref = cp_parent_transaction_id
    AND organization_id = cp_organization_id
    AND transaction_source_num = 18;

  CURSOR c_receipt_cenvat_dtl(cp_transaction_id IN NUMBER, cp_organization_type IN VARCHAR2) IS
    SELECT decode(cp_organization_type, 'M', online_claim_flag, jai_constants.yes) online_claim_flag, -- Changed by Vijay Shankar for Bug #4172424
        cenvat_claimed_ptg, cenvat_claimed_amt, unclaim_cenvat_flag, cenvat_amount
    FROM JAI_RCV_CENVAT_CLAIMS
    WHERE transaction_id = cp_transaction_id;

           /*following cursor added for bug 8538155 (FP for bug 8466620)*/
     cursor c_get_dest(p_line_location_id number, p_distribution_id number) is
     select destination_type_code
     from po_distributions_all
     where line_location_id = p_line_location_id
     and po_distribution_id = nvl(p_distribution_id, po_distribution_id);

  r_trx                   c_trx%ROWTYPE;
  r_parent_trx            c_trx%ROWTYPE;
  r_base_trx              c_base_trx%ROWTYPE;
  r_receipt_line          c_receipt_line_dtls%ROWTYPE;
  r_receipt_cenvat_dtl    c_receipt_cenvat_dtl%ROWTYPE;
  r_taxes                 c_taxes%ROWTYPE;
  r_exc_inv_no            c_excise_invoice_no%ROWTYPE;

  lv_statement_id         VARCHAR2(5);

  lv_transaction_type     JAI_RCV_TRANSACTIONS.transaction_type%TYPE;
  lv_include_cenvat_in_cost VARCHAR2(5);

  ln_excise_tax_count     NUMBER; --File.Sql.35 Cbabu  := 0;
  ln_account_count        NUMBER; --File.Sql.35 Cbabu  := 0;
  ln_rg_count             NUMBER; --File.Sql.35 Cbabu  := 0;
  ln_rtv_cnt              NUMBER; --File.Sql.35 Cbabu  := 0;

  lb_process_iso          BOOLEAN;

  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
  lv_excise_inv_gen_action    VARCHAR2(50);
  lv_vat_inv_gen_action       VARCHAR2(50);

   lv_qty_upd_event       VARCHAR2(30); --added by ssawant

  lv_codepath             JAI_RCV_TRANSACTIONS.codepath%TYPE; --File.Sql.35 := '';
  lv_dest_code VARCHAR2(20);    /*added for bug 8538155 (FP for bug 8466620)*/

BEGIN

  ln_excise_tax_count      := 0;
  ln_account_count         := 0;
  ln_rg_count              := 0;
  ln_rtv_cnt               := 0;
  lv_codepath              := '';

  lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'cenvat_rg_pkg.validate_trx', 'START');
  IF lb_debug THEN
    FND_FILE.put_line(FND_FILE.log, '^VALIDATE_TRANSACTION. Prc_Flag->'||p_process_flag||', Cen_Flag->'||p_cenvat_rg_flag);
  END IF;

  IF p_process_flag IS NULL THEN
    p_process_message   := NULL;
  END IF;

  IF p_cenvat_rg_flag IS NULL THEN
    p_cenvat_rg_message := NULL;
  END IF;

  lv_statement_id := '1';
  OPEN   c_trx(p_transaction_id);
  FETCH  c_trx into r_trx;
  CLOSE  c_trx;

  /* Vijay Shankar for Bug#4250171. following added to support OPM Functionality for VAT Processing */
  IF p_called_from = CALLED_FROM_OPM
    OR r_trx.trx_information in (OPM_RECEIPT, OPM_RETURNS) --Modified by Bo Li for replacing the attribute_category with trx_information
  THEN
    lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);
    p_process_flag        := 'X';
    p_process_message     := 'This Processing not required for OPM Transaction';
    p_cenvat_rg_flag      := 'X';
    p_cenvat_rg_message   := 'This Processing not required for OPM Transaction';
    GOTO end_of_cenvat_flag_validation;
  END IF;

  -- this contains the details of RECEIVE/MATCH transaction type
  OPEN   c_receipt_cenvat_dtl(r_trx.tax_transaction_id,
    r_trx.organization_type);   -- Changed by Vijay Shankar for Bug #4172424
  FETCH  c_receipt_cenvat_dtl into r_receipt_cenvat_dtl;
  CLOSE  c_receipt_cenvat_dtl;

  OPEN   c_base_trx(p_transaction_id);
  FETCH  c_base_trx into r_base_trx;
  CLOSE  c_base_trx;

  lv_statement_id := '2';
  IF r_trx.transaction_type = 'CORRECT' THEN
    lv_transaction_type := r_trx.parent_transaction_type;
  ELSE
    lv_transaction_type := r_trx.transaction_type;
  END IF;

  lv_statement_id := '3';
  /* Fetch all the Information from JAI_RCV_LINES*/
  OPEN   c_receipt_line_dtls(r_trx.shipment_line_id);
  FETCH  c_receipt_line_dtls into r_receipt_line;
  CLOSE  c_receipt_line_dtls;

  --FND_FILE.put_line(fnd_file.log, 'Shp_lineId:'||r_trx.shipment_line_id||', Cnt:'||SQL%ROWCOUNT
  --  ||', Cnt:'||SQL%ROWCOUNT||', exNo:'||r_receipt_line.excise_invoice_no);

  lv_statement_id := '4';
  /* Fetch the Tax count */
  OPEN   c_taxes(r_trx.shipment_line_id);
  FETCH  c_taxes into r_taxes;
  CLOSE  c_taxes;

  lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath);
  lb_process_iso := process_iso_transaction(
                      p_transaction_id    => r_trx.transaction_id,
                      p_shipment_line_id  => r_trx.shipment_line_id
                    );

  ------------------- Process Flag Validation -------------------
  /* Process Flag is set to 'O' when some columns which are required are null or some specific scenarios */

  -- values other than 'Y'  are added by Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
  IF p_process_flag IN ('Y', 'X', 'O', 'XT') THEN
    lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);
    goto end_of_process_flag_validation;
  END IF;


  /*bgowrava for forward porting Bug#5756676..start*/

     lv_online_qty_flag := 'N';

     OPEN  cur_qty_setup(r_trx.organization_id,r_trx.location_id);
     FETCH cur_qty_setup INTO lv_qty_upd_event;
     IF lv_qty_upd_event IS NULL THEN
       CLOSE cur_qty_setup;
       OPEN  cur_qty_setup(r_trx.organization_id,0);
       FETCH cur_qty_setup INTO lv_qty_upd_event;
     END IF;
     CLOSE cur_qty_setup;

     FND_file.put_line( fnd_file.log, 'Quantity Update Event:'||lv_qty_upd_event);

     OPEN cur_item_excise_flag(r_trx.organization_id,r_trx.inventory_item_id );
     FETCH cur_item_excise_flag INTO lv_excise_flag;
     CLOSE cur_item_excise_flag;

     FND_file.put_line( fnd_file.log, 'Item Excisable:'||lv_excise_flag);
     FND_file.put_line( fnd_file.log, 'Excisable Taxes Count:'||r_taxes.excise_cnt);

     FND_file.put_line( fnd_file.log, 'Transaction Type:'||lv_transaction_type);

             /*Bug 8538155 (FP for bug 8466620) - Do not hit the quantity register when there are no recoverable
       * taxes and delivery is to expense location. Reason - when there are no recoverable taxes, the entry
       * will not be reversed during deliver.*/
       lv_dest_code := null;
       open c_get_dest(r_base_trx.po_line_location_id, r_base_trx.po_distribution_id);
       fetch c_get_dest into lv_dest_code;
       close c_get_dest;

        IF r_trx.organization_type = MFG_ORGN AND nvl(lv_dest_code,'XXX') <> 'EXPENSE' THEN


       IF (  ( nvl(lv_qty_upd_event,'X') = 'RECEIVE' AND lv_transaction_type in ('RECEIVE','MATCH') AND nvl(r_trx.quantity_register_flag,'N') = 'N' )
          OR ( lv_excise_flag = 'Y' AND nvl(r_taxes.excise_cnt,0) = 0 AND lv_transaction_type in ('RECEIVE','MATCH','RETURN TO VENDOR'))/*rchandan for bug#6109941.added nvl for tax count*/ /*bug 7662347 - added RETURN TO VENDOR*/
                                        /*bug 8319304 - FP of bugs 6914674 and 8314743 - added the following OR*/
                                        OR ( lv_excise_flag = 'Y' AND r_taxes.excise_cnt>0 AND lv_transaction_type in ('RECEIVE','MATCH','RETURN TO VENDOR') AND nvl(r_receipt_cenvat_dtl.cenvat_amount,0) = 0)
          ) THEN

          lv_online_qty_flag := 'Y';

          FND_file.put_line( fnd_file.log, 'Quantity Register would be hit independent of Amount register');

       END IF;

     END IF;

  /*bgowrava for forward porting Bug#5756676..end*/

  /* 1PROCESS_FLAG. START of PROCESS_FLAG BASIC VALIDATIONS */
  lv_statement_id := '6';
  if r_trx.organization_id is null then
    lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);
    p_process_flag      := 'O';
    p_process_message   := jai_rcv_trx_processing_pkg.get_message('NO-ORG');
    goto end_of_process_flag_validation;
  end if;

  lv_statement_id := '7';
  -- following condition added by Vijay Shankar for Bug#3940588
  -- Common Checks between process_flag and cenvat_rg_flag
  if      lv_transaction_type = 'RETURN TO VENDOR'
     AND (r_base_trx.source_document_code='PO' AND r_base_trx.po_header_id IS NULL)
  then
    lv_codepath := jai_general_pkg.plot_codepath(4, lv_codepath);
    p_process_flag          := 'X';
    p_process_message       := 'RTV against Unordered Receipt will not be processed';
    goto end_of_process_flag_validation;
  end if;
  /* 1PROCESS_FLAG. END of PROCESS_FLAG BASIC VALIDATIONS */

  /* 2PROCESS_FLAG. START of TRANSACTION VALIDATIONS To SEE WHETHER IT IS QUALIFIED w.r.t NON CENVAT TAXES(PROCESS_FLAG)*/

  lv_statement_id := '10';
  if r_taxes.total_cnt = 0 then
    lv_codepath := jai_general_pkg.plot_codepath(5, lv_codepath);
    p_process_flag      := 'X';
    p_process_message   := jai_rcv_trx_processing_pkg.get_message('NO-TAXES');
    goto end_of_process_flag_validation;
  end if;

  lv_statement_id := '11';
  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attr_cat = 'India RMA Receipt' THEN
  if r_base_trx.source_document_code = source_rma then
    lv_codepath := jai_general_pkg.plot_codepath(6, lv_codepath);
    IF ( lv_transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
          -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. AND UPPER(r_base_trx.rma_type) NOT IN ('SCRAP')
          AND r_receipt_line.rma_type NOT IN ('SCRAP')
       )
      OR lv_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING')
    THEN
      lv_codepath := jai_general_pkg.plot_codepath(7, lv_codepath);
       --Added the below by rchandan for Bug#6030615
       OPEN c_trx(p_transaction_id);
       FETCH c_trx into r_trx;
       CLOSE c_trx;
      p_process_flag          := 'X';
      p_process_message       := 'RMA Processing Not Required';
      goto end_of_process_flag_validation;

    ELSIF lv_transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. AND UPPER(r_base_trx.rma_type) IN ('SCRAP')
      AND r_receipt_line.rma_type IN ('SCRAP')
      AND r_taxes.excise_cnt = 0
    THEN
      lv_codepath := jai_general_pkg.plot_codepath(8, lv_codepath);
      p_process_flag          := 'X';
      p_process_message       := 'Excise Taxes donot exist in this RMA transaction';
      goto end_of_process_flag_validation;
    END IF;

  END IF;

  lv_statement_id := '12';
  IF NOT lb_process_iso THEN
    lv_codepath := jai_general_pkg.plot_codepath(9, lv_codepath);
    p_process_flag      := 'X';
    p_process_message   := 'ISO Processing Not Required';
    goto end_of_process_flag_validation;
  END IF;
  /* 2PROCESS_FLAG. END of TRANSACTION VALIDATIONS To SEE WHETHER IT IS QUALIFIED w.r.t NON CENVAT TAXES(PROCESS_FLAG)*/

  /* 3PROCESS_FLAG. START of TRANSACTION VALIDATIONS To SEE WHETHER IT IS PENDING FOR SOMETHING INSPITE OF BEING QUALIFIED for PROCESSING*/
  lv_statement_id := '13';
  --Ensures that if the Parent lines Accounting is not done, then the Accounting for this Line
  --would also be deferred.
  if r_trx.transaction_type = 'CORRECT' AND r_trx.parent_transaction_type in ('DELIVER','RETURN TO RECEIVING') then
    lv_codepath := jai_general_pkg.plot_codepath(10, lv_codepath);
    /* Fetch the Accounting of the parent transaction line */
    OPEN   c_acct_count(r_trx.parent_transaction_id, r_trx.parent_transaction_type);
    FETCH  c_acct_count into ln_account_count;
    CLOSE  c_acct_count;

    if ln_account_count = 0 then
      lv_codepath := jai_general_pkg.plot_codepath(11, lv_codepath);
      p_process_flag        := 'P';
      p_process_message     := jai_rcv_trx_processing_pkg.get_message('NO-BASE-ACCT');
      goto end_of_process_flag_validation;
    end if;
  end if;
  /* 3PROCESS_FLAG. END of TRANSACTION VALIDATIONS To SEE WHETHER IT IS PENDING FOR SOMETHING INSPITE OF BEING QUALIFIED for PROCESSING*/

  p_process_flag   := 'N';

  <<end_of_process_flag_validation>>

  ------------------- Cenvat RG Flag Validation Block -------------------
  /* Cenvat Flag is set to 'O' when some columns which are required are null or some specific scenarios */

  lv_statement_id := '14';
  -- values other than 'Y'  are added by Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
  IF p_cenvat_rg_flag IN ('Y', 'X', 'O', 'XT') THEN
    lv_codepath := jai_general_pkg.plot_codepath(12, lv_codepath);
    goto end_of_cenvat_flag_validation;
  END IF;

  -- following condition is false if the call to this procedure happened from JAINMVAT (i.e deferred Claim Scree)
  FND_file.put_line( fnd_file.log, '54321 ttype:'||r_trx.transaction_type||',exno:'||r_receipt_line.excise_invoice_no
    ||',exda:'||r_receipt_line.excise_invoice_date||',onClFlg:'||r_receipt_cenvat_dtl.online_claim_flag
    ||',CenAmt:'||r_receipt_cenvat_dtl.cenvat_amount||',calFrm:'||p_called_from);

  lv_statement_id := '15';
  /* 1CENVAT_RG_FLAG. START of CENVAT_RG_FLAG BASIC VALIDATIONS */
  if r_trx.organization_id is null then
    lv_codepath := jai_general_pkg.plot_codepath(13, lv_codepath);
    p_cenvat_rg_flag    := 'O';
    p_cenvat_rg_message := jai_rcv_trx_processing_pkg.get_message('NO-ORG');

    goto end_of_cenvat_flag_validation;
  end if;

  lv_statement_id := '16';
  if r_trx.location_id = 0 then
    lv_codepath := jai_general_pkg.plot_codepath(14, lv_codepath);
    p_cenvat_rg_flag    := 'O';
    p_cenvat_rg_message := jai_rcv_trx_processing_pkg.get_message('NO-LOC-ORG-SETUP');
    goto end_of_cenvat_flag_validation;
  end if;
  /* 1CENVAT_RG_FLAG. END of CENVAT_RG_FLAG BASIC VALIDATIONS */

  /* 2CENVAT_RG_FLAG. START of TRANSACTION VALIDATIONS To SEE WHETHER IT IS QUALIFIED w.r.t NON CENVAT TAXES(CENVAT_RG_FLAG)*/
  lv_statement_id := '17';
  if      lv_transaction_type = 'RETURN TO VENDOR'
     AND (r_base_trx.source_document_code='PO' AND r_base_trx.po_header_id IS NULL)
  then
    lv_codepath := jai_general_pkg.plot_codepath(15, lv_codepath);
    p_cenvat_rg_flag        := 'X';
    p_cenvat_rg_message     := 'RTV against Unordered Receipt will not be processed';
    goto end_of_cenvat_flag_validation;
  end if;

  lv_statement_id := '18';
  if r_taxes.total_cnt = 0 then
    lv_codepath := jai_general_pkg.plot_codepath(16, lv_codepath);
    p_cenvat_rg_flag    := 'X';
    p_cenvat_rg_message := jai_rcv_trx_processing_pkg.get_message('NO-TAXES');
    goto end_of_cenvat_flag_validation;
  end if;

  lv_statement_id := '19';
  if r_trx.transaction_type NOT IN ('RECEIVE', 'MATCH')
      AND r_receipt_cenvat_dtl.unclaim_cenvat_flag = 'Y'
  then
    lv_codepath := jai_general_pkg.plot_codepath(17, lv_codepath);
    p_cenvat_rg_flag        := 'X';
    p_cenvat_rg_message     := 'Parent is not eligible for Cenvat Claim';
    goto end_of_cenvat_flag_validation;
  end if;

   /*this condition is changed for an observation made while fixing bug 8538155 (FP for bug 8466620).
    * when delivery is to expense and total recoverable cenvat amount is zero with
    * excise tax lines being present, then the amount register is updated with zero
    * amount during deliver. This behavior is wrong, as per inputs from PM*/
     --added  r_trx.organization_type='M' for bug#7595016
   if r_taxes.excise_cnt = 0 or (r_trx.organization_type='M' and r_receipt_cenvat_dtl.cenvat_amount = 0 ) then
    lv_codepath := jai_general_pkg.plot_codepath(18, lv_codepath);
    p_cenvat_rg_flag        := 'X';
    p_cenvat_rg_message     := 'Excise Taxes do not exist';
    goto end_of_cenvat_flag_validation;
   end if;

  lv_statement_id := '20';
  open   c_excise_tax_count(r_trx.shipment_line_id);
  fetch  c_excise_tax_count into ln_excise_tax_count;
  close  c_excise_tax_count;

  lv_statement_id := '21';
  --added the organization_type for Trading in the IF clause for bug#9019561
  if r_trx.organization_type in ('M','T') AND ln_excise_tax_count = 0 then
    lv_codepath := jai_general_pkg.plot_codepath(19, lv_codepath);
    p_cenvat_rg_flag        := 'X';
    p_cenvat_rg_message     := jai_rcv_trx_processing_pkg.get_message('NO-EXCISE-TAXES');
    goto end_of_cenvat_flag_validation;
  end if;

  if r_trx.organization_type = 'T' AND lv_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING') then
    lv_codepath := jai_general_pkg.plot_codepath(20, lv_codepath);
    p_cenvat_rg_flag        := 'X';
    p_cenvat_rg_message     := 'No Cenvat/RG Entries are passed for '||lv_transaction_type;
    goto end_of_cenvat_flag_validation;
  end if;

  lv_statement_id := '22';
  if lv_transaction_type = 'RETURN TO VENDOR' then

    lv_codepath := jai_general_pkg.plot_codepath(21, lv_codepath);
    if r_trx.transaction_type = 'CORRECT' THEN
      lv_statement_id := '23';
      SELECT count(1) INTO ln_rtv_cnt
      FROM JAI_RCV_RTV_DTLS
      WHERE transaction_id = r_trx.parent_transaction_id;

      lv_statement_id := '24';
      if ln_rtv_cnt = 0 THEN
        lv_codepath := jai_general_pkg.plot_codepath(22, lv_codepath);
        p_cenvat_rg_flag    := 'X';
        p_cenvat_rg_message := 'Parent RTV Transaction doesnt have Excise Invoice';
        goto end_of_cenvat_flag_validation;
      end if;

    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. elsif r_base_trx.generate_excise_invoice = 'N' then
    elsif r_trx.excise_inv_gen_status in ( INV_GEN_STATUS_INV_NA ) then --Modified by Bo Li for replacing the attribute1 with excise_inv_gen_status
    --pramasub FP start IProc
       /*
          || Start Changes by ssumaith - Iprocurement Bug#4281841.
          || Check if the return is created from Iproc.
          */
    OPEN   check_rcpt_source(r_base_Trx.po_line_location_id);
    FETCH  check_rcpt_source INTO lv_apps_source_code;
    CLOSE  check_rcpt_source;

      IF NVL(lv_apps_source_code,'$$') <> 'POR' THEN
          /*
          || The above if was added by ssumaith for Iprocurement Bug#4281841.
          */
    --pramasub FP end IProc
       lv_codepath := jai_general_pkg.plot_codepath(23, lv_codepath);
       lv_excise_inv_gen_action := r_trx.excise_inv_gen_status;   -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.--Modified by Bo Li for replacing the attribute1 with excise_inv_gen_status
       p_cenvat_rg_flag    := 'X';
       -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_cenvat_rg_message := 'DFF Value for Generate Excise Invoice is not given as ''Y''';
       p_cenvat_rg_message := 'Excise invoice not required';
       goto end_of_cenvat_flag_validation;
    --pramasub FP Iporc start
    ELSE
        IF r_trx.cenvat_Rg_status = 'P' or r_trx.process_status = 'P' or r_Trx.process_vat_status = 'P' THEN
        /*
                It means that the user has intentionally set the process action to N in the Iproc IL returns page.
                We are setting the values as to be processed as it can then be picked up and processed.
                */
         p_cenvat_rg_flag    := 'X';
         --p_cenvat_rg_message := 'DFF Value for Generate Excise Invoice is not given as ''Y''';
         --commented out the above line as the message is changed for the bug#4346453 by cbabu | pramasub FP IProc
         p_cenvat_rg_message := 'Excise invoice not required';
         GOTO end_of_cenvat_flag_validation;
      ELSE
        /*
                 || It means initially the flags were some value other than O and we are flagging it to process it later.
                 */
         --lv_codepath := ja_in_general_pkg.plot_codepath(23.1, lv_codepath);
         p_cenvat_rg_flag    := 'O';
         p_cenvat_rg_message := 'Call From Iprocurement returns page';
         p_process_flag      := 'O';
         p_process_vat_flag  := 'O';
         GOTO end_of_cenvat_flag_validation;
        END IF;
    END IF;
    /*
    || Above end if added by ssumaith - Iprocurement Bug#4281841 to handle returns.
         */
    --pramasub FP Iporc end
    end if;
  end if;

  lv_statement_id := '25';
  if r_trx.organization_type = 'T' then
    if r_trx.item_trading_flag <> 'Y' then
      lv_codepath := jai_general_pkg.plot_codepath(24, lv_codepath);
      p_cenvat_rg_flag        := 'O';
      p_cenvat_rg_message     := jai_rcv_trx_processing_pkg.get_message('ITEM-TRADING-NO');
      goto end_of_cenvat_flag_validation;
    elsif r_trx.item_excisable <> 'Y' then
      lv_codepath := jai_general_pkg.plot_codepath(25, lv_codepath);
      p_cenvat_rg_flag        := 'O';
      p_cenvat_rg_message     := 'Trading Item is not Excisable';
      goto end_of_cenvat_flag_validation;
    end if;
  end if;

  lv_statement_id := '26';
  if r_trx.item_class in ('OTIN','OTEX') then
    lv_codepath := jai_general_pkg.plot_codepath(26, lv_codepath);
    p_cenvat_rg_flag        := 'O';
    p_cenvat_rg_message     := jai_rcv_trx_processing_pkg.get_message('ITEM-CLASS-OTIN');
    goto end_of_cenvat_flag_validation;
  elsif r_trx.item_class NOT IN ('RMIN', 'RMEX', 'CGIN', 'CGEX', 'CCIN', 'CCEX', 'FGIN', 'FGEX') then
    lv_codepath := jai_general_pkg.plot_codepath(27, lv_codepath);
    p_cenvat_rg_flag        := 'O';
    p_cenvat_rg_message     := jai_rcv_trx_processing_pkg.get_message('ITEM-CLASS-NULL');
    goto end_of_cenvat_flag_validation;
  end if;

  lv_statement_id := '27';
  /* following condition modified by Vijay Shankar for Bug#4179823 */
  -- if  r_base_trx.source_document_code <> 'REQ' and r_trx.item_class in ('FGIN', 'FGEX')
  --  if  r_base_trx.source_document_code <> 'RMA' and r_trx.item_class in ('FGIN', 'FGEX')
     --commented the above and added the below by rchandan for Bug#6030615
     if  r_base_trx.source_document_code NOT IN ('RMA','INVENTORY') and r_trx.item_class in ('FGIN', 'FGEX')
    and r_trx.organization_type = 'M' -- Changed by Vijay Shanker for Bug #4172424
  then
    p_codepath := jai_general_pkg.plot_codepath(28, p_codepath);
    p_cenvat_rg_flag        := 'X';
    p_cenvat_rg_message     := 'Cenvat Accounting not supported for FGIN Items';
    goto end_of_cenvat_flag_validation;
  end if;

  lv_statement_id := '28';
  if r_trx.organization_type ='M' and r_trx.item_cenvatable = 'N' then
    lv_codepath := jai_general_pkg.plot_codepath(29, lv_codepath);
    p_cenvat_rg_flag        := 'O';
    p_cenvat_rg_message     := jai_rcv_trx_processing_pkg.get_message('ITEM-CENVATABLE-NO');
    goto end_of_cenvat_flag_validation;
  end if;

  lv_statement_id := '29';
  /*
  ||Start of bug 5378630
  ||Modified the below if statement condition such that the RMA_type 'GOODS RETURN' was changed into GOODS RETURN
  */

  IF r_base_trx.source_document_code = SOURCE_RMA
    AND r_receipt_line.rma_type NOT IN ('PRODUCTION INPUT', 'GOODS RETURN')
  THEN
  /* ENd of bug 5378630 */
    lv_codepath := jai_general_pkg.plot_codepath(30, lv_codepath);
    p_cenvat_rg_flag    := 'X';
    p_cenvat_rg_message := 'RMA Processing Not Required';
    goto end_of_cenvat_flag_validation;
  END IF;

  /* Fetch whether RG has been hit */
  if r_trx.transaction_type = 'CORRECT' then

    lv_statement_id := '30';
    lv_codepath := jai_general_pkg.plot_codepath(31, lv_codepath);
    if r_trx.parent_transaction_type in ('RECEIVE', 'RETURN TO VENDOR') then

      lv_codepath := jai_general_pkg.plot_codepath(32, lv_codepath);
      if r_trx.organization_type = 'M' then
        lv_statement_id := '32';
        open   c_rg_count(r_trx.parent_transaction_id, r_trx.organization_id);
        -- fetch  c_rg_count into ln_rg_count;
        fetch  c_rg_count into ld_parent_rg_entry_date;
        close  c_rg_count;
      else    -- Trading Check
        lv_statement_id := '33';
        open   c_parent_rg23d_entry(r_trx.parent_transaction_id, r_trx.organization_id);
        fetch  c_parent_rg23d_entry into ld_parent_rg_entry_date;
        close  c_parent_rg23d_entry;
      end if;

      if to_char(ld_parent_rg_entry_date, 'YYYYMM') <> to_char(SYSDATE, 'YYYYMM') THEN
        lv_codepath := jai_general_pkg.plot_codepath(33, lv_codepath);
        p_cenvat_rg_flag        := 'XT';
        p_cenvat_rg_message     := jai_rcv_trx_processing_pkg.get_message('BASE-MONTH-DIFFERENT');
        goto end_of_cenvat_flag_validation;
      end if;

    else

      lv_statement_id := '35';
      lv_codepath := jai_general_pkg.plot_codepath(34, lv_codepath);
      OPEN   c_trx(r_trx.parent_transaction_id);
      FETCH  c_trx into r_parent_trx;
      CLOSE  c_trx;

      if to_char(r_trx.transaction_date, 'YYYYMM') <> to_char(r_parent_trx.transaction_date, 'YYYYMM') THEN
        lv_codepath := jai_general_pkg.plot_codepath(35, lv_codepath);
        p_cenvat_rg_flag        := 'XT';
        p_cenvat_rg_message     := jai_rcv_trx_processing_pkg.get_message('BASE-MONTH-DIFFERENT');
        goto end_of_cenvat_flag_validation;
      end if;
    end if;
  end if;

  -- we dont do validation for ISO in case of trading because RG23D Entry should be passed even if accounting is not required
  lv_statement_id := '36';
  IF NOT lb_process_iso AND r_trx.organization_type = 'M' THEN
    lv_codepath := jai_general_pkg.plot_codepath(36, lv_codepath);
    p_cenvat_rg_flag    := 'X';
    p_cenvat_rg_message := 'ISO Processing Not Required';
    goto end_of_cenvat_flag_validation;
  END IF;

  IF lv_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING') THEN

    lv_codepath := jai_general_pkg.plot_codepath(37, lv_codepath);
    lv_statement_id := '37';

    -- this call is specific to DELIVER and RTR transactions
    lv_include_cenvat_in_cost := jai_rcv_deliver_rtr_pkg.include_cenvat_in_costing(
                                    p_transaction_id    => p_transaction_id,
                                    p_process_message   => p_cenvat_rg_flag,
                                    p_process_status    => p_cenvat_rg_message,
                                    p_codepath          => lv_codepath
                                 );

    lv_statement_id := '38';
    -- If cenvat is included in costing, then we need to reverse cenvat entries that are passed during RECEIVE Trxn
    IF lv_include_cenvat_in_cost = 'N' THEN
      lv_codepath := jai_general_pkg.plot_codepath(38, lv_codepath);
      p_cenvat_rg_flag    := 'X';
      p_cenvat_rg_message := 'Cenvat Entries not Applicable for transaction type';
      goto end_of_cenvat_flag_validation;
    END IF;

  END IF;

  /* 2CENVAT_RG_FLAG. END of TRANSACTION VALIDATIONS To SEE WHETHER IT IS QUALIFIED w.r.t NON CENVAT TAXES(CENVAT_RG_FLAG)*/

  /* 3CENVAT_RG_FLAG. START of TRANSACTION VALIDATIONS To SEE WHETHER IT IS PENDING FOR SOMETHING INSPITE OF BEING QUALIFIED for PROCESSING*/
  lv_statement_id := '39';
  if r_trx.transaction_type = 'CORRECT' AND r_trx.parent_transaction_type in ('RECEIVE', 'RETURN TO VENDOR') then
    if ld_parent_rg_entry_date IS NULL then
      lv_codepath := jai_general_pkg.plot_codepath(39, lv_codepath);
      p_cenvat_rg_flag        := 'P';
      p_cenvat_rg_message     := jai_rcv_trx_processing_pkg.get_message('NO-BASE-RG');
      goto end_of_cenvat_flag_validation;
    end if;
  end if;

  lv_statement_id := '40';
  IF    r_trx.transaction_type IN ('RECEIVE', 'MATCH')
    AND ( r_receipt_line.excise_invoice_no IS NULL
          OR  r_receipt_line.excise_invoice_date IS NULL
          OR  ( nvl(r_receipt_cenvat_dtl.online_claim_flag, 'N') = 'N'
                AND nvl(r_receipt_cenvat_dtl.cenvat_amount,0) <> 0
                AND p_called_from<>'JAINMVAT'
              )
        )
  THEN
    lv_codepath := jai_general_pkg.plot_codepath(40, lv_codepath);
    p_cenvat_rg_flag        := 'P';
    p_cenvat_rg_message     := 'Pending for Claim';
    goto end_of_cenvat_flag_validation;
  END IF;

  -- following conditions added by Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
  -- check to stop claim of later transactions of RECEIVE if RECEIVE line is not yet claimed
  lv_statement_id := '41';
  IF r_trx.transaction_type NOT IN ('RECEIVE', 'MATCH')
    AND nvl(r_receipt_cenvat_dtl.cenvat_claimed_amt,0) = 0 AND nvl(r_receipt_cenvat_dtl.cenvat_amount,0) <> 0
    AND nvl(r_receipt_cenvat_dtl.online_claim_flag,'N') = 'N'  /*This condition added by nprashar for bug #8644480*/
  THEN
    lv_codepath := jai_general_pkg.plot_codepath(41, lv_codepath);
    p_cenvat_rg_flag        := 'P';
    p_cenvat_rg_message     := 'Pending for Receipt Line Claim';   -- - '||lv_transaction_type;
    goto end_of_cenvat_flag_validation;
  END IF;
  -- End, Vijay Shankar for Bug#3940588
 IF r_trx.transaction_type NOT IN ('RECEIVE', 'MATCH') /*Added by nprashar for bug # 8644480*/
  AND nvl(r_receipt_cenvat_dtl.cenvat_claimed_amt,0) = 0 AND nvl(r_receipt_cenvat_dtl.cenvat_amount,0) <> 0
  AND  nvl(r_receipt_cenvat_dtl.online_claim_flag,'Y') = 'Y' THEN
 --These condition points to Entire quantity Correction ,in such a case the claimed_amount will be zero
 --But since its being claimed before performng Correction the online_claim_flag willbe Y and cenvat_claim_ptg will be > 0
  p_cenvat_rg_flag  := 'C';
 goto end_of_cenvat_flag_validation;
  END IF;


  -- Updation of excise invoice number for all transactions other than RTV
  if lv_transaction_type <> 'RETURN TO VENDOR' and r_trx.excise_invoice_no is null then

    lv_statement_id := '42';
    lv_codepath := jai_general_pkg.plot_codepath(42, lv_codepath);
    OPEN c_excise_invoice_no(r_trx.shipment_line_id);
    FETCH c_excise_invoice_no INTO r_exc_inv_no;
    CLOSE c_excise_invoice_no;

    -- this is to update excise invoice no in case of Offline Claim or somehow excise invoice is not update in POPULATE_DETAILS
    jai_rcv_transactions_pkg.update_excise_invoice_no(
        p_transaction_id      => p_transaction_id,
        p_excise_invoice_no   => r_exc_inv_no.excise_invoice_no,
        p_excise_invoice_date => r_exc_inv_no.excise_invoice_date
    );
  end if;

  /* 3CENVAT_RG_FLAG. END of TRANSACTION VALIDATIONS To SEE WHETHER IT IS PENDING FOR SOMETHING INSPITE OF BEING QUALIFIED for PROCESSING*/

  p_cenvat_rg_flag   :='N';
  <<end_of_cenvat_flag_validation>>

  /* 4 Start of PROCESS_VAT_FLAG Validation */

    --added the below by Ramananda for Bug#4519697
  if p_process_vat_flag = jai_constants.successful THEN
    goto end_of_vat_validation;
  end if;

  /* following condition added as part of DFF elimination. Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  if r_trx.process_vat_status in (jai_constants.yes, 'X', 'O') then
    lv_codepath := jai_general_pkg.plot_codepath(42.0, lv_codepath);
    goto end_of_vat_validation;
  end if;

  if r_trx.location_id = 0 then
    lv_codepath := jai_general_pkg.plot_codepath(42.1, lv_codepath);
    p_process_vat_flag    := 'O';
    p_process_vat_message := jai_rcv_trx_processing_pkg.get_message('NO-LOC-ORG-SETUP');
    goto end_of_vat_validation;
  end if;

  IF lv_transaction_type NOT IN ( 'RECEIVE', 'RETURN TO VENDOR') THEN
    lv_statement_id := '42.1';
    lv_codepath := jai_general_pkg.plot_codepath(42.2, lv_codepath);
    p_process_vat_flag := 'X';
    p_process_vat_message := 'VAT Processing not required for this Transaction Type';
    GOTO end_of_vat_validation;
  END IF;

  OPEN c_recoverable_vat_tax_cnt(r_trx.shipment_line_id, jai_constants.vat_regime);
  FETCH c_recoverable_vat_tax_cnt INTO ln_recoverable_vat_tax_cnt;
  CLOSE c_recoverable_vat_tax_cnt;

  IF ln_recoverable_vat_tax_cnt = 0 THEN
    lv_statement_id := '42.2';
    lv_codepath := jai_general_pkg.plot_codepath(42.3, lv_codepath);
    p_process_vat_flag := 'X';
    p_process_vat_message := 'No VAT Taxes exist for receipt line';
    GOTO end_of_vat_validation;
  END IF;
  --pramasub FP Iproc start
  IF lv_transaction_type = 'RETURN TO VENDOR' then
        --IF r_base_trx.generate_excise_invoice = 'N' THEN
      --pramasub commented the above line as the same condition is replaced by the following line for bug#4346453
      IF r_trx.excise_inv_gen_status in ( INV_GEN_STATUS_INV_NA ) then --Modified by Bo Li for replacing the attribute1 with excise_inv_gen_status
           IF NVL(lv_apps_source_code,'$$') =  'POR' THEN /* gen ex inv in the dff is not 'Y' and its a return for iproc return */
             p_process_vat_flag  := 'O';
             p_process_vat_message := 'Call from Iproc returns IL page';
             GOTO end_of_vat_validation;
           END IF;
        END IF;
     END IF;
  --pramasub FP IProc end
  p_process_vat_flag := 'N';

  <<end_of_vat_validation>>

  /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  if r_trx.transaction_type = 'RETURN TO VENDOR' then

    /* Excise */
    --if p_called_from in (CALLED_FROM_RCV_TRIGGER, CALLED_FROM_FND_REQUEST) then
    if lv_excise_inv_gen_action is null and r_trx.excise_inv_gen_status is null then -- and excise_inv_gen_number is null then ---Modified by Bo Li for replacing the attribute1 with excise_inv_gen_status
      lv_statement_id := '60';
      lv_codepath := jai_general_pkg.plot_codepath(60, lv_codepath);
      /* Flag is set to 'P' only if validations that set the flag as 'X' are done */
      if p_cenvat_rg_flag in ('N', 'P')  then -- FLAG 'P' is not considered as the transaction will be processed again and FLAG will be set to 'N'
        lv_excise_inv_gen_action  := INV_GEN_STATUS_PENDING;
      elsif p_cenvat_rg_flag in ('X', 'O', 'XT') then
        lv_excise_inv_gen_action := INV_GEN_STATUS_NA;
      end if;

    elsif p_called_from = CALLED_FROM_JAITIGRTV and r_trx.attribute1 = INV_GEN_STATUS_INV_NA then
      lv_statement_id := '61';
      lv_codepath := jai_general_pkg.plot_codepath(61, lv_codepath);
      p_cenvat_rg_flag := 'X';
      p_cenvat_rg_message := 'Excise Invoice is not applicable';
    end if;

    /* VAT */
    if lv_vat_inv_gen_action is null and r_trx.vat_inv_gen_status is null then -- and vat_inv_gen_number is null then --Modified by Bo Li for replacing the attribute2 with vat_inv_gen_status
      lv_statement_id := '62';
      lv_codepath := jai_general_pkg.plot_codepath(62, lv_codepath);
      if p_process_vat_flag in ('N') then
        lv_vat_inv_gen_action  := INV_GEN_STATUS_PENDING;
      elsif p_process_vat_flag in ('X', 'O') then
        lv_vat_inv_gen_action := INV_GEN_STATUS_NA;
      end if;
    end if;
  end if;

  IF p_simulate_flag = 'N' THEN
    lv_codepath := jai_general_pkg.plot_codepath(43, lv_codepath);
    lv_statement_id := '43';
    /* Call to update the Flag values as the validation is completed */
    jai_rcv_transactions_pkg.update_process_flags(
      p_transaction_id            => p_transaction_id,
      p_process_flag              => p_process_flag,
      p_process_message           => p_process_message,
      p_cenvat_rg_flag            => p_cenvat_rg_flag,
      p_cenvat_rg_message         => p_cenvat_rg_message,
      p_process_vat_flag          => p_process_vat_flag,
      p_process_vat_message       => p_process_vat_message,
      p_process_date              => SYSDATE
    );

    /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
    if p_called_from <> CALLED_FROM_JAITIGRTV THEN
     /* Bug 5365346. Added by Lakshmi Gopalsami
      | Check whether 57F4 transaction has been created for PO
      | before updating Excise invoice action. If so we need to set
      | the value to 'PENDING' instead of 'NOT_APPLICABLE
      */
      fnd_file.put_line(FND_FILE.LOG, ' transaction id ' || p_transaction_id);

      IF ( Check_57F4_transaction( p_transaction_id ) = 'YES' ) THEN
         lv_excise_inv_gen_action := INV_GEN_STATUS_PENDING;
      END IF ;

       --Modified by Bo Li for replacing the update_attributes with update_inv_stat_and_no Begin
      --------------------------------------------------------------------------------------------
      /*jai_rcv_transactions_pkg.update_attributes(
        p_transaction_id      => p_transaction_id,
        p_attribute1          => lv_excise_inv_gen_action,
        p_attribute2          => lv_vat_inv_gen_action
      );*/

       jai_rcv_transactions_pkg.update_inv_stat_and_no(
        p_transaction_id            => p_transaction_id,
        p_excise_inv_gen_status     => lv_excise_inv_gen_action,
        p_vat_inv_gen_status        => lv_vat_inv_gen_action
      );
      --------------------------------------------------------------------------------------------
       --Modified by Bo Li for replacing the update_attributes with update_inv_stat_and_no End

    end if;

  END IF;

  -- this is the final place where we assign the value to p_codepath from local codepath
  lv_statement_id := '49';
  p_codepath := jai_general_pkg.plot_codepath(lv_codepath||',49', p_codepath, 'cenvat_rg_pkg.validate_trx', 'END');
  -- p_codepath := substr(p_codepath||lv_codepath, 1, 2000);

  FND_FILE.put_line( fnd_file.log, '$ VALIDATE_TRANSACTION PrcFlg:'||p_process_flag||', Msg:'||p_process_message
    ||', CenvatRgFlg:'||p_cenvat_rg_flag ||', Msg:'||p_cenvat_rg_message
    ||', PrcVatFlg:'||p_process_vat_flag ||', Msg:'||p_process_vat_message
    ||', localPath:'||lv_codepath
  );

EXCEPTION
  when others then
    p_process_flag    := 'E';
    p_process_message := 'RECEIPT_TRANSACTION_PKG.Validate_transaction:'||SQLERRM||', Statement_id:'||lv_statement_id;
    FND_FILE.put_line( fnd_file.log, 'Error in '||p_process_message||'. localErrorPath:'||lv_codepath );
    p_codepath := jai_general_pkg.plot_codepath(lv_codepath||',-999', p_codepath, 'cenvat_rg_pkg.validate_trx', 'END');

END validate_transaction;


FUNCTION process_iso_transaction(
  p_transaction_id    IN NUMBER,
  p_shipment_line_id  IN NUMBER
) RETURN BOOLEAN
IS

  CURSOR c_shp_hdr(cp_transaction_id number) IS
    SELECT receipt_source_code
    from rcv_shipment_headers
    WHERE shipment_header_id = (select shipment_header_id
          from rcv_transactions
          where transaction_id = cp_transaction_id);

  CURSOR c_shp_line(cp_shipment_line_id number) IS
    SELECT from_organization_id, to_organization_id
    FROM rcv_shipment_lines
    WHERE shipment_line_id = cp_shipment_line_id;

  CURSOR c_excise_tax_cnt(cp_shipment_line_id number) is
    SELECT count(1)
    FROM JAI_RCV_LINE_TAXES
    WHERE shipment_line_id = cp_shipment_line_id
    -- CVD is Not Considered, because in ISO scenario CVD is not supported.
    AND upper(tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_sh_exc_edu_cess);  --Added by kunkumar for bugno5989740 -- Vijay Shankar for Bug#3940588 EDU CESS

  CURSOR c_organization_info(cp_organization_id number) IS
    SELECT  nvl(trading, 'N') trading, nvl(manufacturing, 'N') manufacturing
          , nvl(excise_in_rg23d, 'N') excise_in_rg23d   -- Vijay Shankar for Bug#4171469
    FROM JAI_CMN_INVENTORY_ORGS
    WHERE organization_id = cp_organization_id
    AND rownum = 1;

  lb_process_iso_transaction      BOOLEAN;  --File.Sql.35 Cbabu  := true;

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_trx_processing_pkg.process_iso_transaction';

  ln_excise_tax_cnt   NUMBER;
  r_shp_line          c_shp_line%ROWTYPE;
  r_shp_hdr           c_shp_hdr%ROWTYPE;
  r_dest_org          c_organization_info%ROWTYPE;
  r_src_org           c_organization_info%ROWTYPE;

BEGIN

  lb_process_iso_transaction       := true;

  OPEN c_shp_hdr(p_transaction_id);
  FETCH c_shp_hdr INTO r_shp_hdr;
  CLOSE c_shp_hdr;

  IF r_shp_hdr.receipt_source_code IN  ('INTERNAL ORDER','INVENTORY')  THEN /*rchandan for bug#6030615*/

    OPEN c_excise_tax_cnt(p_shipment_line_id);
    FETCH c_excise_tax_cnt INTO ln_excise_tax_cnt;
    CLOSE c_excise_tax_cnt;

    IF ln_excise_tax_cnt > 0 THEN

      OPEN c_shp_line(p_shipment_line_id);
      FETCH c_shp_line INTO r_shp_line;
      CLOSE c_shp_line;

      OPEN c_organization_info(r_shp_line.from_organization_id);
      FETCH c_organization_info INTO r_src_org;
      CLOSE c_organization_info;

      IF r_src_org.trading = 'Y' THEN
        OPEN c_organization_info(r_shp_line.to_organization_id);
        FETCH c_organization_info INTO r_dest_org;
        CLOSE c_organization_info;

        /* Vijay Shankar for Bug#4171469
          following condition modified to pass accounting incase of Trading to Trading with both orgs
          having excise_in_rg23d flag set to 'Y'
        */
        -- if this following condition is true, then it means ISO Processing is not required
        -- IF r_dest_org.trading = 'Y' OR r_dest_org.manufacturing = 'Y' THEN
        -- following condition modified by Vijay Shankar for Bug#4171469
        IF r_dest_org.trading = 'Y' THEN
          IF r_src_org.excise_in_rg23d <> 'Y'
             --OR r_dest_org.excise_in_rg23d <> 'Y' --commented by Ramananda for Bug #4516577
          THEN
            lb_process_iso_transaction := false;
          END IF;

        ELSIF r_dest_org.manufacturing = 'Y' THEN
          IF r_src_org.excise_in_rg23d <> 'Y' THEN --Added the if condition by Ramananda for Bug #4516577
            lb_process_iso_transaction := false;
          END IF;
        END IF;
      END IF;

    END IF;

  END IF;

  RETURN lb_process_iso_transaction;

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END process_iso_transaction;


FUNCTION get_ancestor_id(
  p_transaction_id    IN NUMBER,
  p_shipment_line_id  IN NUMBER,
  p_required_trx_type IN VARCHAR2
) RETURN NUMBER IS

  ln_trx_id NUMBER;

  lv_transaction_type     RCV_TRANSACTIONS.transaction_type%TYPE;

BEGIN

  ln_trx_id := p_transaction_id;
  FOR i IN (select transaction_id, transaction_type, parent_transaction_id
            from rcv_transactions
            where shipment_line_id = p_shipment_line_id
            and transaction_id <= p_transaction_id
            order by transaction_id desc)
  LOOP

    IF i.transaction_id = ln_trx_id THEN
      -- added for Vijay Shankar for Bug#3940588
      --IF p_required_trx_type = 'MATCH' THEN /*commented by vkaranam for bug #4636397*/
      IF i.transaction_type = 'MATCH' THEN /*added by vkaranam for bug #4636397*/
        lv_transaction_type := 'RECEIVE';
      ELSE
        lv_transaction_type := i.transaction_type;
      END IF;
      -- End, Vijay Shankar for Bug#3940588

      IF lv_transaction_type = p_required_trx_type THEN
        RETURN i.transaction_id;
      ELSE
        ln_trx_id := i.parent_transaction_id;
      END IF;
    END IF;
  END LOOP;

  RETURN NULL;
END get_ancestor_id;

FUNCTION get_trxn_tax_amount(
  p_transaction_id      IN  NUMBER,
  p_shipment_line_id    IN  NUMBER,
  p_curr_conv_rate      IN  NUMBER,
  p_return_in_inr_curr  IN  VARCHAR2 --File.Sql.35 Cbabu  DEFAULT 'Y'
) RETURN NUMBER IS

/*
  Transaction can have two Currencies 1. Functional(INR) 2. Transactional (Non INR Currency in case of foreign Trxn)
  If p_return_in_inr_curr = 'Y' then Functional tax amount is returned otherwise in transactional currency in returned
  Tax amount returned is to the tune of TRANSACTION Quantity.
  eg in ILDEV -> select jai_rcv_trx_processing_pkg.get_trxn_tax_amount(14108, 10626, 50, 'N') amount from dual;
*/

  -- This cursor gives tax_amount in FOREIGN Currency
  CURSOR c_tax_amount(cp_shipment_line_id IN NUMBER, cp_curr_conv_rate IN NUMBER) IS
    SELECT
      sum(
          nvl(tax_amount, 0) / decode(currency, jai_general_pkg.INDIAN_CURRENCY, cp_curr_conv_rate, 1)
         ) non_inr_tax_amount,
      sum(
          nvl(tax_amount, 0) * decode(currency, jai_general_pkg.INDIAN_CURRENCY, 1, cp_curr_conv_rate)
         ) inr_tax_amount
    FROM JAI_RCV_LINE_TAXES
    WHERE shipment_line_id = cp_shipment_line_id
    AND tax_type NOT IN ('TDS', 'Modvat Recovery');

  ln_tax_amount           NUMBER;
  ln_inr_tax_amount       NUMBER;
  ln_non_inr_tax_amount   NUMBER;

BEGIN

  OPEN c_tax_amount(p_shipment_line_id, p_curr_conv_rate);
  FETCH c_tax_amount INTO ln_non_inr_tax_amount, ln_inr_tax_amount;
  CLOSE c_tax_amount;

  IF p_return_in_inr_curr = 'Y' THEN
    ln_tax_amount := ln_inr_tax_amount;
  ELSE
    ln_tax_amount := ln_non_inr_tax_amount;
  END IF;

  ln_tax_amount := nvl(ln_tax_amount, 0) * get_apportion_factor( p_transaction_id => p_transaction_id );

  RETURN nvl(ln_tax_amount, 0);

END get_trxn_tax_amount;

FUNCTION get_trxn_cenvat_amount(
  p_transaction_id      IN  NUMBER,
  p_shipment_line_id    IN  NUMBER,
  p_organization_type   IN  VARCHAR2,
  p_curr_conv_rate      IN  NUMBER
) RETURN NUMBER IS

/*
  This Always Returns Total Cenvat amount in INR Currency to the tune of transaction quantity, uom
  eg in ILDEV -> select jai_rcv_trx_processing_pkg.get_trxn_cenvat_amount(14108, 10626, 50) amount from dual;
*/

  -- This cursor gives tax_amount in FOREIGN Currency
  CURSOR c_tax_amount(cp_shipment_line_id IN NUMBER, cp_curr_conv_rate IN NUMBER, cp_organization_type IN VARCHAR2) IS
    SELECT
      sum(
          nvl(a.tax_amount, 0) * (b.mod_cr_percentage/100)
          * decode(a.currency, jai_general_pkg.INDIAN_CURRENCY, 1, cp_curr_conv_rate)
         ) manufacturing_cenvat,
      sum(
          nvl(a.tax_amount, 0) * decode(a.currency, jai_general_pkg.INDIAN_CURRENCY, 1, cp_curr_conv_rate)
         ) trading_cenvat
    FROM JAI_RCV_LINE_TAXES a, JAI_CMN_TAXES_ALL b
    WHERE shipment_line_id = cp_shipment_line_id
    AND a.tax_id = b.tax_id
    AND upper(a.tax_type) IN ( 'EXCISE',
                               'ADDL. EXCISE',
             'OTHER EXCISE',
             'CVD',
             jai_constants.tax_type_add_cvd,
              -- Modified by SACSETHI Bug# 5228046
              -- Forward porting the change in 11i bug 5365523
                                      -- (Additional CVD Enhancement) as part of the R12 bug 5228046
                               jai_constants.tax_type_exc_edu_cess,
             jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_sh_exc_edu_cess,
                               jai_constants.tax_type_sh_cvd_edu_cess) --Added by kunkumar for bugno5989740  -- Vijay Shankar for Bug#3940588 EDU CESS
    AND (cp_organization_type = 'T' OR (cp_organization_type <> 'T' AND a.modvat_flag = 'Y') );

  ln_manufacturing_cenvat_amount      NUMBER;
  ln_trading_cenvat_amount            NUMBER;
  ln_tax_amount                       NUMBER;

BEGIN

  OPEN c_tax_amount(p_shipment_line_id, p_curr_conv_rate, p_organization_type);
  FETCH c_tax_amount INTO ln_manufacturing_cenvat_amount, ln_trading_cenvat_amount;
  CLOSE c_tax_amount;

  IF p_organization_type = 'M' THEN
    ln_tax_amount := ln_manufacturing_cenvat_amount;
  ELSIF p_organization_type = 'T' THEN
    ln_tax_amount := ln_trading_cenvat_amount;
  END IF;

  ln_tax_amount := nvl(ln_tax_amount, 0) * get_apportion_factor( p_transaction_id => p_transaction_id );

  RETURN nvl(ln_tax_amount, 0);

END get_trxn_cenvat_amount;


FUNCTION get_apportion_factor(
  p_transaction_id IN NUMBER
) RETURN NUMBER IS

/*
  Returns the Value of (TransactionQuantity * TransactionUOM) / (TaxQuantity * TaxUom)
  i.e if  Transaction Quantity, UOM = 18, EACH
      and         Tax Quantity, UOM =  5, DOZEN
      then this function returns (18*1/5*12)=0.3
*/

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_trx_processing_pkg.get_apportion_factor';

  CURSOR c_ja_in_receipt_lines_qty(cp_shipment_line_id IN NUMBER) IS
    SELECT qty_received, transaction_id
    FROM JAI_RCV_LINES
    WHERE shipment_line_id = cp_shipment_line_id;

  r_trx                   c_trx%ROWTYPE;
  r_tax_trx               c_base_trx%ROWTYPE;

  ln_tax_transaction_id   NUMBER;
  ln_tax_quantity         NUMBER;
  lv_tax_uom_code         MTL_UNITS_OF_MEASURE.uom_code%TYPE;
  lv_trxn_uom_code        MTL_UNITS_OF_MEASURE.uom_code%TYPE;

  ln_uom_conv_rate        NUMBER;
  ln_apportion_factor     NUMBER;

BEGIN

  -- if this is called from jai_rcv_trx_processing_pkg.populate_details then most of the fields are NULL.
  -- So, Check whether the required values are populated or not before proceding further
  OPEN c_trx(p_transaction_id);
  FETCH c_trx INTO r_trx;
  CLOSE c_trx;

  OPEN c_ja_in_receipt_lines_qty(r_trx.shipment_line_id);
  FETCH c_ja_in_receipt_lines_qty INTO ln_tax_quantity, ln_tax_transaction_id;
  CLOSE c_ja_in_receipt_lines_qty;

  IF ln_tax_quantity = 0 THEN
    RETURN 0;
  END IF;

  OPEN c_base_trx(ln_tax_transaction_id);
  FETCH c_base_trx INTO r_tax_trx;
  CLOSE c_base_trx;

  lv_trxn_uom_code    := r_trx.uom_code;
  lv_tax_uom_code     := nvl(r_tax_trx.uom_code,
                             jai_general_pkg.get_uom_code( p_uom  => r_tax_trx.unit_of_measure)
                            );

  IF lv_trxn_uom_code = lv_tax_uom_code THEN
    ln_uom_conv_rate  := 1;
  ELSE
    ln_uom_conv_rate  := jai_general_pkg.trxn_to_primary_conv_rate(
                            p_transaction_uom_code  => lv_trxn_uom_code,
                            p_primary_uom_code      => lv_tax_uom_code,
                            p_inventory_item_id     => r_trx.inventory_item_id
                         );
  END IF;

  ln_apportion_factor := ln_uom_conv_rate * r_trx.quantity/ln_tax_quantity;

  RETURN ln_apportion_factor;

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END get_apportion_factor;

FUNCTION get_equivalent_qty_of_receive(
  p_transaction_id IN NUMBER
) RETURN NUMBER IS

/*
  Returns the Value of (TransactionQuantity * TransactionUOM) / (TaxUom)
  i.e if  Transaction Quantity, UOM = 18, EACH
      and         Tax Quantity, UOM =  5, DOZEN
      then this function returns (18*1/12) = 1.5
*/

  CURSOR c_ja_in_receipt_lines_qty(cp_shipment_line_id IN NUMBER) IS
    SELECT qty_received, transaction_id
    FROM JAI_RCV_LINES
    WHERE shipment_line_id = cp_shipment_line_id;

  r_trx                   c_trx%ROWTYPE;
  r_tax_trx               c_base_trx%ROWTYPE;

  ln_tax_transaction_id   NUMBER;
  ln_tax_quantity         NUMBER;
  lv_tax_uom_code         MTL_UNITS_OF_MEASURE.uom_code%TYPE;
  lv_trxn_uom_code        MTL_UNITS_OF_MEASURE.uom_code%TYPE;

  ln_uom_conv_rate        NUMBER;
  ln_apportion_factor     NUMBER;

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_trx_processing_pkg.get_equivalent_qty_of_receive';

BEGIN

  -- if this is called from jai_rcv_trx_processing_pkg.populate_details then most of the fields are NULL.
  -- So, Check whether the required values are populated or not before proceding further
  OPEN c_trx(p_transaction_id);
  FETCH c_trx INTO r_trx;
  CLOSE c_trx;

  OPEN c_ja_in_receipt_lines_qty(r_trx.shipment_line_id);
  FETCH c_ja_in_receipt_lines_qty INTO ln_tax_quantity, ln_tax_transaction_id;
  CLOSE c_ja_in_receipt_lines_qty;

  IF ln_tax_quantity = 0 THEN
    RETURN 0;
  END IF;

  OPEN c_base_trx(ln_tax_transaction_id);
  FETCH c_base_trx INTO r_tax_trx;
  CLOSE c_base_trx;

  lv_trxn_uom_code    := r_trx.uom_code;
  lv_tax_uom_code     := nvl(r_tax_trx.uom_code,
                             jai_general_pkg.get_uom_code( p_uom  => r_tax_trx.unit_of_measure)
                            );

  IF lv_trxn_uom_code = lv_tax_uom_code THEN
    ln_uom_conv_rate  := 1;
  ELSE
    ln_uom_conv_rate  := jai_general_pkg.trxn_to_primary_conv_rate(
                            p_transaction_uom_code  => lv_trxn_uom_code,
                            p_primary_uom_code      => lv_tax_uom_code,
                            p_inventory_item_id     => r_trx.inventory_item_id
                         );
  END IF;

  ln_apportion_factor := ln_uom_conv_rate * r_trx.quantity;

  RETURN ln_apportion_factor;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END get_equivalent_qty_of_receive;


FUNCTION get_message( p_message_code IN VARCHAR2) RETURN VARCHAR2 IS
  lv_message    JAI_RCV_TRANSACTIONS.process_message%type;
BEGIN

  IF p_message_code = 'NO-ORG' THEN
    lv_message := 'Organization is not found ';

  ELSIF p_message_code = 'NO-LOC-ORG-SETUP' THEN
    lv_message := 'Localization setup does not exist for this Location';

  ELSIF p_message_code = 'TAX-NOT-MODIFIED' THEN
    lv_message := 'Taxes can still be modified ';

  ELSIF p_message_code = 'NO-TAXES' THEN
    lv_message := 'Localization taxes does not exist for this Organization';

  ELSIF p_message_code = 'NO-BASE-ACCT' THEN
    lv_message := 'The Initial Line Accounting/costing is not done';

  ELSIF p_message_code = 'ITEM-CLASS-NULL' THEN
    lv_message := 'Item Class is null ';

  ELSIF p_message_code = 'ITEM-CLASS-OTIN' THEN
    lv_message := 'Item Class is OTIN/OTEX ';

  ELSIF p_message_code = 'ITEM-TRADING-NO' THEN
    lv_message := 'Item Trading Flag is Not present ';

  ELSIF p_message_code = 'ITEM-CENVATABLE-NO' THEN
    lv_message := 'Item Modvat Flag is Not present ';

  ELSIF p_message_code = 'NO-EXCISE-TAXES' THEN
    lv_message := 'No Excise Taxes are present ';

  ELSIF p_message_code = 'NO-BASE-RG' THEN
    lv_message := 'The Initial RG Entry for the parent transaction is not passed ';

  ELSIF p_message_code ='BASE-MONTH-DIFFERENT' THEN
    lv_message := 'Month is changed since Parent RG Entry was passed';
  END IF;

  return lv_message;

END get_message;

--------------------------------------End Message Procedure------------------------------------------------------

FUNCTION get_object_code( p_object_name IN VARCHAR2, p_event_name IN VARCHAR2) RETURN VARCHAR2 IS

-- This is for future use
BEGIN

  return p_object_name||p_event_name||':';
END get_object_code;

FUNCTION get_accrue_on_receipt(
    p_po_distribution_id  IN  NUMBER,
    p_po_line_location_id IN  NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS

  CURSOR c_dist_dtl(cp_po_distribution_id IN NUMBER) IS
    SELECT accrue_on_receipt_flag
    FROM po_distributions_all
    WHERE po_distribution_id = cp_po_distribution_id;

  /* added by Vijay Shankar for Bug#4215402 */
  CURSOR c_po_shipment_dtl(cp_po_line_location_id IN NUMBER) IS
    SELECT accrue_on_receipt_flag
    FROM po_line_locations_all
    WHERE line_location_id = cp_po_line_location_id;

  lv_accrue_on_receipt_flag  po_line_locations_all.accrue_on_receipt_flag%TYPE;

BEGIN

  IF p_po_distribution_id IS NOT NULL THEN
    OPEN c_dist_dtl(p_po_distribution_id);
    FETCH c_dist_dtl INTO lv_accrue_on_receipt_flag;
    CLOSE c_dist_dtl;

  /* added by Vijay Shankar for Bug#4215402 */
  ELSE
    OPEN c_po_shipment_dtl(p_po_line_location_id);
    FETCH c_po_shipment_dtl INTO lv_accrue_on_receipt_flag;
    CLOSE c_po_shipment_dtl;
  END IF;

  RETURN nvl(lv_accrue_on_receipt_flag, 'N');

END get_accrue_on_receipt;

END jai_rcv_trx_processing_pkg;

/
