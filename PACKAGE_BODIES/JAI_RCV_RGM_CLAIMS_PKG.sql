--------------------------------------------------------
--  DDL for Package Body JAI_RCV_RGM_CLAIMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_RGM_CLAIMS_PKG" AS
/* $Header: jai_rcv_rgm_clm.plb 120.15.12010000.7 2010/04/15 10:58:07 boboli ship $ */


  TABLE_RCV_TRANSACTIONS    CONSTANT VARCHAR2(30)  := 'RCV_TRANSACTIONS';
  RECEIVING                 CONSTANT VARCHAR2(30)  := 'RECEIVING';
  RTV                       CONSTANT VARCHAR2(15)  := 'RTV';
  CORRECT_RECEIVE           CONSTANT VARCHAR2(30)  := 'CORRECT-RECEIVE';
  CORRECT_RTV               CONSTANT VARCHAR2(30)  := 'CORRECT-RTV';

  PROCEDURE get_location(
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_location_id         OUT NOCOPY  hr_locations_all.location_id%TYPE,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2)
  IS
    CURSOR c_dlry_subinventory(cp_shipment_line_id  IN NUMBER,
                               cp_receive_trx_id    IN NUMBER,
             cp_transaction_type rcv_transactions.transaction_type%type)
    IS
    SELECT  subinventory
    FROM    rcv_transactions
    WHERE   shipment_line_id = cp_shipment_line_id
    AND     parent_transaction_id = cp_receive_trx_id
    AND     transaction_type =  cp_transaction_type --'DELIVER' /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    AND     transaction_id > cp_receive_trx_id;

    CURSOR c_loc_linked_to_org_subinv(cp_organization_id  IN NUMBER,
                                      cp_subinventory     IN VARCHAR2)
    IS
    SELECT  location_id
    FROM    JAI_INV_SUBINV_DTLS
    WHERE   organization_id = cp_organization_id
    AND     sub_inventory_name = cp_subinventory;

    CURSOR c_inv_org_linked_to_location(cp_location_id IN NUMBER)
    IS
    SELECT  nvl(inventory_organization_id, -99999) inventory_organization_id
    FROM    hr_locations_all
    WHERE   location_id = cp_location_id;

    r_trx                     c_trx%ROWTYPE;
    r_parent_trx              c_trx%ROWTYPE;
    r_base_trx                c_base_trx%ROWTYPE;
    r_parent_base_trx         c_base_trx%ROWTYPE;
    r_ancestor_dtls           c_base_trx%ROWTYPE;
    lv_subinventory           RCV_TRANSACTIONS.subinventory%TYPE;
    ln_location_id            NUMBER(15);
    lv_required_trx_type      RCV_TRANSACTIONS.transaction_type%TYPE;
    ln_ancestor_trxn_id       NUMBER(15);
    r_subinv_dtls             c_loc_linked_to_org_subinv%ROWTYPE;
    ln_organization_id        NUMBER(15);
    lv_transaction_type       RCV_TRANSACTIONS.transaction_type%TYPE;
  BEGIN
/*****************************************************************************************************************************************************************************************
Change History -
*****************************************************************************************************************************************************************************************
1. 27-Jan-2005   Sanjikum for Bug #4248727 Version #115.1
                  New Package created for creating VAT Processing

2   25/03/2005   Vijay Shankar for Bug#4250171. Version: 115.2
                  modified the code in get_location procedure, so that location_id value is fetched from JAI_RCV_TRANSACTIONS
                  incase of OPM Receipts

3  01/04/2005    Vijay Shankar for Bug#4278511. Version:115.3
                  Incase of ISO receipts, location_id has to be derived from SUBINVENTORY attached to the transaction if present, otherwise
                  we need to fetch location of RCV_TRANSACTONS. Code is modified in get_location procedure

4.  04/04/2005   Sanjikum for Bug #4279050 Version #115.4
                 Problem
                 -------
                 In the Procedure update_rcv_lines, For setting the flag lv_process_status_flag, first Partial Claim is checked and then Full Claimed,
                 which is creating the problem in case of full claim happens in the first installment

                 Fix
                 ---
                 1) In the Procedure update_rcv_lines, For setting the flag lv_process_status_flag, now first Full Claimed is checked
                    and then Partial Claim
                 2) In the procedure - update_rcv_lines, added one more parameter - p_shipment_header_id

5.  08/04/2005   Sanjikum for Bug #4279050 Version #116.0 (115.5)
                 Re-checked the same file again

6. 10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                 Code is modified due to the Impact of Receiving Transactions DFF Elimination

              * High Dependancy for future Versions of this object *

7. 08-Jun-2005  File Version 116.2. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                as required for CASE COMPLAINCE.

8. 13-Jun-2005  Ramananda for bug#4428980. File Version: 116.3
                Removal of SQL LITERALs is done

9. 06-Jul-2005  Ramananda for bug#4477004. File Version: 116.4
                GL Sources and GL Categories got changed. Refer bug for the details

10.02-Aug-2005  Ramananda for Bug#4530112. File Version 120.2
                 Problem
                 -------
                 In case of RTV, if VAT Claim is not done, system is asking to make the VAT Claim first

                 Fix
                 ---
                 1) In the Procedure process_vat, added cursor c_rcv_rgm_lines
                 2) In the Procedure process_vat, added an IF condition -
                    "IF r_rcv_rgm_lines.invoice_no IS NULL AND (r_trx.transaction_type = 'RETURN TO VENDOR'
                     OR (r_trx.transaction_type = 'CORRECT' AND r_trx.parent_transaction_type IN ('RECEIVE', 'MATCH', 'RETURN TO VENDOR') ) ) THEN"

                 Added the following as the object is not compiled because of R12 changes.
                 These were introudced as default values were removed from the procedure spec. and function spec.
                 1. Procedue call update_rcv_lines is changed:
                       p_invoice_no   => jai_rcv_rgm_claims_pkg.gv_invoice_no_dflt,    --File.Sql.35 Cbabu
                       p_invoice_date => jai_rcv_rgm_claims_pkg.gd_invoice_date_dflt    --File.Sql.35 Cbabu

                  2. Procedure call generate_schedule is changed:
                      p_override            => jai_constants.no

                 Dependency Due to this Bug:-
                 File jai_rcv_tax.plb (120.4) is changed as part of this Bug,
                 so this object is dependent on current Bug and object jai_rcv_tax.plb(120.4)

11. 02-Aug-2005  Ramananda for Bug#4519719. File Version 120.2
                 Issue : Processing should not take place if no VAT type of taxes
                 Fis   : Added a condition to check if VAT type of taxes exist in the receipt
                         before the call to jai_rcv_rgm_claims_pkg.insert_rcv_lines. If no VAT type of taxes
                         exist, the return from the procedure.

                 Dependency due to this bug:-
                 jai_rcv_trx_prc.plb (120.4)

12. 02-Sep-2005 Bug4589354. Added by Lakshmi Gopalsami version 120.3
                Commented the following condition.
                OR (r_base_trx.source_document_code = 'REQ' and

    Dependencies :
    jai_rcv_trx_prc.plb  120.6
    jai_rcv_rgm_clm.plb  120.3

13. 25-Jan-2006 Bug4929929. Added by Lakshmi Gopalsami Version 120.4
                Removed the NVL  in cursor  c_receipt_source_code
                as shipment_header_id and shipment_line_id cannot be null.

14. 26-FEB-2007   SSAWANT , File version 120.7
                  Forward porting the change in 11.5 bug 4760317 to R12 bug no 4950914

			a) Following changes are done in procedure - generate_schedule
					- In the definition of procedure added one more parameter - p_simulate_flag
					- In the cursor - cur_tax, added one more where condition - "AND 		NVL(a.tax_amount,0) <> 0;"
					- Added a new cursor - cur_installment_count
					- Added new variable - r_installment_count
					- In loop of cursor - cur_tax, after calling procedure - generate_term_schedules, added a delete statement
					- In loop of cursor - cur_tax, after calling procedure - generate_term_schedules, added the code for
			b) Following changes are done in procedure - process_vat
				- Added a new condition to return from the procedure, if ja_in_rcv_transactions.process_vat_flag is 'SS'.
					After this added the call to procedure - generate_schedule

			 c) Following changes are done in procedure - process_claim
					- Before call to procedure - jai_rgm_trx_recording_pkg.insert_vat_repository_entry, added the condition that
					either of debit or credit amount should be null

			 d) Following changes are done in procedure - process_no_claim
					- Changed the definition of procedure
					- Changed the definition of cursor - c_shipment_lines and changed the statement to open this cursor
					- Before call to procedure - ja_in_receipt_accounting_pkg.process_transaction, added the condition that
							either of debit or credit amount should be null

			 e) Following changes are done in procedure - process_batch
					- Commented the condition - "IF p_batch_id IS NULL AND p_shipment_header_id IS NULL AND p_shipment_line_id IS NULL THEN"
						- Changed the call to procedure - process_no_claim

			 f) Following changes are done in procedure - do_rtv_accounting
					- Before call to procedure - jai_rgm_trx_recording_pkg.insert_vat_repository_entry, added the condition that
						either of debit or credit amount should be null

			 g) Following changes are done in procedure - do_rma_accounting
					- In the loop of cursor - cur_tax, Added the following condition -
						IF NVL(rec_tax.tax_amount,0) = 0 THEN
						goto END_OF_LOOP;
						END IF;
					- Before call to procedure - ja_in_receipt_accounting_pkg.process_transaction, added the condition that
						ln_tax_amount <> 0
			   		- Added a new Label - <<END_OF_LOOP>>
15	05-03-2007	bduvarag for bug#5899383,File version 120.8
			Forward porting the changes done in 11i bug 5496355

                Dependency Due to this bug
                --------------------------
                Yes, there are new parameters added in some procedures

16	28-05-2007	SACSETHI for bug 6071533 file Version 120.10

			VAT CLAIM ACCOUNTING ENTRY IS NOT GETTING GENERATED FOR RECEIPTS

			Problem - In Procedure Generate Schedule , We were making default value
			          for argument p_simulate_flag  to null but it should be 'N'
				  Which resulting in execution not happening for vat

                        Solution - Signature of procedure generate_schedule is changes for argument
			           p_simulate_flag from NULL TO 'N'

                        Dependncies - jai_rcv_rgm_clm.pls , jai_rcv_rgm_clm.plb

17     29-05-2007       sacsehi for bug 6078460  File version 120.11
                        R12RUP03-ST1: RTV NOT WORKING

			Problem - Cursor c_regime where clause was wrongly specified which
			          resulting in failure in generation of rtv accounting .....

18.   21/06/2007        brathod, for bug# 6109941, File Version 120.12, 120.13
                        1.  Removed update of ATTRIBUTE (DFF) columns of RCV_SHIPMENT_HEADERS and RCV_SHIPMENT_LINES table
                        2.  added excise_invoice_no and excise_invoice_date in cursor c_shipment_lines
                        3.  Changed reference of r_trx.excise_invoice_no and r_trx.excise_invoice_date to
                             rec_lines.excise_invoice_no and rec_lines.excise_invoice_date resp.

19    4-JUN-2009     Bug 8488470 File version 120.6.12000000.6 / 120.15.12010000.3 / 120.17
                     Issue - Accounting entries not rounded properly during CORRECT / RTV transactions.
		     Cause - The unrounded amount is being used to generate the schedules. After this,
		             the installment amounts are rounded as per setup. But the last installment
			     gets unrounded to account for the difference between total of all installment
			     amounts and the total recoverable amount. If the claim is done in single
			     installment, then effectively there is no rounding.
		     Fix   - Modified procedure generate_schedule to use the rounded amount to generate
		             claim schedule, so that all installments would be populated with rounded
			     amounts.

20.  02-JUL-2009   Bgowrava for Bug#8414075 , File Version 	120.6.12000000.7 / 120.15.12010000.4 / 120.18
                   Addded nvl condition to ln_process_special_amount while calling the procedure jai_rcv_deliver_rtr_pkg.process_transaction.
				   Also rounded the ln_amount value according to rounding factor mentioned in the tax setupthe same is passed in the
 	               call to jai_cmn_rgm_terms_pkg.generate_term_schedules.

21   09-AUG-2009  Bug 8648138
                  Issue - If VAT is unclaimed after running "Mass Addtions Create" program, the unclaimed amount does not
                          flow to assets when "Mass Additions Create" is run again.
                  Fix   - Added code in process_deferred_cenvat_claim procedure to update related flags in ap_invoice_distributions_all
                          for the matched invoices so that the tax distributions will be picked up by the "Mass Additions Create" program.

22.  20-AUG-2009  JMEENA for bug#8302581
				   Modified procedure do_rma_accounting and added code to debit the Liability account and credit Interim Liabality
				   account for the Non Recoverable Item In RMA order having VAT taxes.
				   Called procedure jai_cmn_rgm_recording_pkg.insert_vat_repository_entry to insert records in the jai_rgm_trx_records
				   table to reverse the VAT settlement entries for the non recoverable Items in the RMA Order.
Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
 A datamodel change )

============================================================================================================
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                  Version     Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
jai_ap_interface_pkg_b.sql
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.0                 4248727        4245089                                                                                      This is Part of VAT Enhancement, so dependent on VAT Enhancement
115.2                 4250171        4250171                                                                                      There are changes done for OPM. So dependency is introduced
115.3                 4278511        4278511                                                                                      There are changes done for OPM. So dependency is introduced
115.4                 4279050        4279050            jai_rcv_rgm_claims_s.sql                115.1       Sanjikum 07/04/2005
115.4                 4279050        4279050            ja_in_create_4279050.sql                115.0       Sanjikum 07/04/2005
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
****************************************************************************************************************************************************************************************/
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    OPEN c_trx(r_base_trx.parent_transaction_id);
    FETCH c_trx INTO r_parent_trx;
    CLOSE c_trx;

    OPEN c_base_trx(r_base_trx.parent_transaction_id);
    FETCH c_base_trx INTO r_parent_base_trx;
    CLOSE c_base_trx;

    IF r_base_trx.transaction_type = 'CORRECT' THEN
      lv_transaction_type := r_parent_base_trx.transaction_type;
    ELSE
      lv_transaction_type := r_base_trx.transaction_type;
    END IF;

    /* Vijay Shankar for Bug#4250171. following condition added to implement VAT Functionality for OPM */
    if r_trx.trx_information = jai_rcv_trx_processing_pkg.OPM_RECEIPT then

      if lv_transaction_type = 'RETURN TO VENDOR' THEN
        ln_location_id := r_parent_trx.location_id;
        lv_subinventory := r_base_trx.subinventory;
      else
        ln_location_id := r_trx.location_id;
        lv_subinventory := r_base_trx.subinventory;
      end if;

    -- if both location and subinventory are NULL then goto the parent type i.e RTV to RECEIVE and RTR to DELIVER
    ELSIF nvl(r_base_trx.location_id, 0) = 0 AND nvl(r_base_trx.subinventory, '-XX') = '-XX' THEN
      -- following condition added by Vijay Shankar for Bug#4038024. Incase of CORRECT transactions, if location and subinventory
      -- are not present, then we need to look at parent transaction for location. this will mostly happen for DIRECT DELIVERY case
      IF lv_transaction_type IN ('RETURN TO RECEIVING', 'RETURN TO VENDOR')
        OR (r_base_trx.transaction_type = 'CORRECT' AND r_parent_base_trx.transaction_type IN ('RECEIVE', 'DELIVER'))
      THEN

        ln_location_id := r_parent_trx.location_id;

      -- Incase of Direct Delivery RECEIVE transaction may not have both the location and subinventory. In this case we need to fetch the
      -- subinventory from DELIVER transaction
      ELSIF lv_transaction_type = 'RECEIVE' AND r_base_trx.routing_header_id = 3 THEN   -- this will not execute for correct transactions
        OPEN c_dlry_subinventory(r_base_trx.shipment_line_id, p_transaction_id, 'DELIVER'); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
        FETCH c_dlry_subinventory INTO lv_subinventory;
        CLOSE c_dlry_subinventory;

      END IF;

      IF (lv_transaction_type in ('RETURN TO RECEIVING', 'DELIVER') AND nvl(lv_subinventory,'-XX')='-XX')
        OR (lv_transaction_type in ('RETURN TO VENDOR', 'RECEIVE') AND nvl(ln_location_id,0)=0 AND nvl(lv_subinventory,'-XX')='-XX' )
      THEN

        IF lv_transaction_type IN ('DELIVER', 'RETURN TO RECEIVING') THEN
          lv_required_trx_type := 'DELIVER';
        ELSIF lv_transaction_type IN ('RECEIVE', 'RETURN TO VENDOR') THEN
          lv_required_trx_type := 'RECEIVE';
        END IF;

        ln_ancestor_trxn_id := jai_rcv_trx_processing_pkg.get_ancestor_id(
                                  p_transaction_id    => p_transaction_id,
                                  p_shipment_line_id  => r_base_trx.shipment_line_id,
                                  p_required_trx_type => lv_required_trx_type
                               );

        IF ln_ancestor_trxn_id IS NOT NULL THEN
          OPEN c_base_trx(ln_ancestor_trxn_id);
          FETCH c_base_trx INTO r_ancestor_dtls;
          CLOSE c_base_trx;

          ln_location_id    := r_ancestor_dtls.location_id;
          lv_subinventory   := r_ancestor_dtls.subinventory;
        END IF;

      END IF;

    ELSE
      ln_location_id := r_base_trx.location_id;
      lv_subinventory := r_base_trx.subinventory;
    END IF;

    IF lv_subinventory IS NOT NULL THEN
      OPEN c_loc_linked_to_org_subinv(r_base_trx.organization_id, lv_subinventory);
      FETCH c_loc_linked_to_org_subinv INTO r_subinv_dtls;
      CLOSE c_loc_linked_to_org_subinv;

      IF (nvl(ln_location_id,0) = 0
        /* following condition added by Vijay Shankar for Bug#4278511 to take care of ISO Scenario */
  /* Bug 4589354. Added by Lakshmi Gopalsami.
           Commented the following condition.
        OR (r_base_trx.source_document_code = 'REQ' and */
        OR nvl(r_subinv_dtls.location_id, 0) <> 0 )
      THEN
        ln_location_id := r_subinv_dtls.location_id;
      END IF;

    END IF;

    IF nvl(ln_location_id, 0) <> 0 THEN
      OPEN c_inv_org_linked_to_location(ln_location_id);
      FETCH c_inv_org_linked_to_location INTO ln_organization_id;
      CLOSE c_inv_org_linked_to_location;

      IF r_base_trx.organization_id <> ln_organization_id THEN
        ln_location_id := 0;
      END IF;
    END IF;

    p_location_id := ln_location_id;
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR('jai_rcv_rgm_claims_pkg.get_location Error:'||SQLERRM,1,250);
  END get_location;

  PROCEDURE generate_schedule(
                p_term_id             IN          jai_rgm_terms.term_id%TYPE DEFAULT NULL,
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE DEFAULT NULL,
                p_tax_type            IN          JAI_CMN_TAXES_ALL.tax_type%TYPE DEFAULT NULL,
                p_tax_id              IN          JAI_CMN_TAXES_ALL.tax_id%TYPE DEFAULT NULL,
                p_override            IN          VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N',
		--p_simulate_flag	      IN	  VARCHAR2 DEFAULT 'N', --Added  for Bug 4950914
                p_process_status      OUT         NOCOPY  VARCHAR2,
                p_process_message     OUT         NOCOPY  VARCHAR2,
                /*Bug 5096787. Added by Lakshmi Gopalsami  */
                p_simulate_flag       IN          VARCHAR2 DEFAULT 'N' -- Date 28/05/2007 sacsethi for bug 6071533 Change default value from null to N
                )
  IS
    CURSOR  cur_lines(cp_shipment_header_id  IN  rcv_shipment_headers.shipment_header_id%TYPE,
                      cp_shipment_line_id    IN  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  shipment_header_id, shipment_line_id
    FROM    JAI_RCV_LINES
    WHERE   shipment_header_id = NVL(cp_shipment_header_id, shipment_header_id)
    AND     shipment_line_id = NVL(cp_shipment_line_id, shipment_line_id)
    ORDER BY shipment_line_id;

    CURSOR  cur_txns(cp_shipment_line_id  IN  rcv_shipment_lines.shipment_line_id%TYPE,
                     cp_transaction_id    IN  rcv_transactions.transaction_id%TYPE)
    IS
    SELECT  transaction_id,
            transaction_type,
            transaction_date,
            tax_transaction_id,
            parent_transaction_type,
            currency_conversion_rate,
            quantity,
            DECODE(transaction_type, 'RECEIVE', 1, 'RETURN TO VENDOR', -1, 'CORRECT',
                  DECODE(parent_transaction_type, 'RECEIVE', SIGN(quantity), 'RETURN TO VENDOR', SIGN(quantity)*-1))  quantity_multiplier
    FROM    JAI_RCV_TRANSACTIONS
    WHERE   shipment_line_id = NVL(cp_shipment_line_id, shipment_line_id)
    AND     transaction_id = NVL(cp_transaction_id, transaction_id)
    AND     (
              transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
            OR
              (   transaction_type = 'CORRECT'
              AND parent_transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
              )
            )
    ORDER BY transaction_id;

    CURSOR  cur_tax(cp_transaction_id           IN  rcv_transactions.transaction_id%TYPE,
                    cp_currency_conversion_rate IN  JAI_RCV_TRANSACTIONS.currency_conversion_rate%TYPE)
    IS
    SELECT  DECODE(a.currency, jai_constants.func_curr, a.tax_amount*(b.mod_cr_percentage/100),
	        a.tax_amount*cp_currency_conversion_rate*(b.mod_cr_percentage/100)) tax_amount  --Removed Round condition by Bgowrava for Bug#8414075
                  /*DECODE(a.currency, jai_constants.func_curr, a.tax_amount, a.tax_amount*cp_currency_conversion_rate),
                  NVL(b.rounding_factor, 0) Commented by Nitin for Bug:# 6681800
                 ) tax_amount*/,
            a.tax_type,
            a.tax_id,
            NVL(b.rounding_factor,0) rounding_factor
    FROM    JAI_RCV_LINE_TAXES a,
            JAI_CMN_TAXES_ALL b
    WHERE   a.transaction_id = cp_transaction_id
    AND     a.tax_type IN ( select tax_type
                            from jai_regime_tax_types_v
                            where regime_code = jai_constants.vat_regime
                          )
    AND     a.tax_id = b.tax_id
    AND     a.modvat_flag = 'Y'
    --Added  for Bug#4950914
    AND 		NVL(a.tax_amount,0) <> 0;

    CURSOR  cur_term(cp_shipment_line_id IN rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  term_id, rcv_rgm_line_id, receipt_date
    FROM    jai_rcv_rgm_lines
    WHERE   shipment_line_id = cp_shipment_line_id;

    CURSOR cur_sum_schedules(cp_schedule_id  IN  NUMBER)
    IS
    SELECT  SUM(installment_amount) total_installment_amount, MAX(installment_no) max_installment_no
    FROM    jai_rgm_trm_schedules_t
    WHERE   schedule_id = cp_schedule_id;

    		--Added the cursor for Bug#4950914
		CURSOR cur_installment_count(	cp_rcv_rgm_line_id	IN	NUMBER,
						cp_transaction_id  	IN 	NUMBER,
						cp_tax_id		IN 	NUMBER,
						cp_schedule_id		IN 	NUMBER)
		IS
		SELECT	COUNT(*) count
		FROM 		jai_rcv_rgm_claims
		WHERE 	rcv_rgm_line_id = cp_rcv_rgm_line_id
		AND 		transaction_id = cp_transaction_id
		AND 		tax_id = cp_tax_id
		AND 		installment_no IN (	SELECT	installment_no
								FROM 		jai_rgm_trm_schedules_t
								WHERE 	schedule_id = cp_schedule_id);


    r_term  cur_term%ROWTYPE;
    ln_schedule_id  NUMBER;
    lv_process_flag VARCHAR2(2);
    lv_process_msg  VARCHAR2(1000);
    ln_amount       NUMBER;
    r_sum_schedules cur_sum_schedules%ROWTYPE;
    r_installment_count	cur_installment_count%ROWTYPE; --Added  for Bug#4950914

    ln_apportion_factor NUMBER;

  BEGIN

    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    IF p_override = 'Y' THEN
      DELETE  jai_rcv_rgm_claims
      WHERE   shipment_header_id  = NVL(p_shipment_header_id, shipment_header_id)
      AND     shipment_line_id    = NVL(p_shipment_line_id, shipment_line_id)
      AND     transaction_id      = NVL(p_transaction_id, transaction_id)
      AND     tax_type            = NVL(p_tax_type, tax_type)
      AND     tax_id              = NVL(p_tax_id, tax_id);
    END IF;

    FOR rec_lines IN cur_lines(p_shipment_header_id, p_shipment_line_id)
    LOOP
		IF gv_debug THEN
			fnd_file.put_line(fnd_file.log, 'In Generate Schedule -- LOOP 1:');
			fnd_file.put_line(fnd_file.log, 'Shipment Header :'||rec_lines.shipment_header_id||' shipment_line_id '||rec_lines.shipment_line_id);
		END IF;

      OPEN cur_term(rec_lines.shipment_line_id);
      FETCH cur_term INTO r_term;
      CLOSE cur_term;

      FOR rec_txns IN cur_txns(rec_lines.shipment_line_id, p_transaction_id)
      LOOP
        ln_apportion_factor := ABS(jai_rcv_trx_processing_pkg.get_apportion_factor(rec_txns.transaction_id));

		IF gv_debug THEN
			fnd_file.put_line(fnd_file.log, 'ln_apportion_factor: '||ln_apportion_factor);
			fnd_file.put_line(fnd_file.log, 'Transaction_id: '||rec_txns.transaction_id);
			fnd_file.put_line(fnd_file.log, 'Tax_transaction_id: '||rec_txns.tax_transaction_id);
                        fnd_file.put_line(fnd_file.log, 'p_simulate_flag: '||p_simulate_flag);
		END IF;


        FOR tax_rec IN cur_tax(rec_txns.tax_transaction_id, rec_txns.currency_conversion_rate)
        LOOP
          ln_amount := round(tax_rec.tax_amount * ln_apportion_factor, nvl(tax_rec.rounding_factor,0));
	  /*above line modified for bug 8488470. If we do not round the amount here, last installment
	   * will have unrounded amount. Effectively there will be no rounding if there is only one
	   * installment.*/

	  IF gv_debug THEN
		fnd_file.put_line(fnd_file.log, 'tax_rec.tax_amount: '||tax_rec.tax_amount);
		fnd_file.put_line(fnd_file.log, 'ln_amount: '||ln_amount);
	  END IF;

          jai_cmn_rgm_terms_pkg.generate_term_schedules(p_term_id       => NVL(p_term_id,r_term.term_id),
                                                    p_amount        => ln_amount,
                                                    p_register_date => r_term.receipt_date,
                                                    p_schedule_id   => ln_schedule_id,
                                                    p_process_flag  => lv_process_flag,
                                                    p_process_msg   => lv_process_msg);

          IF lv_process_flag <> jai_constants.successful THEN

	    --Added  for Bug#4950914
              DELETE  jai_rgm_trm_schedules_t
	      WHERE   schedule_id = ln_schedule_id;
  	      fnd_file.put_line(fnd_file.log, ' After Generating jai_cmn_rgm_terms_pkg.generate_term_schedules');
	    p_process_status := lv_process_flag;
            p_process_message := lv_process_msg;
            RETURN;
          END IF;


	--Start Added by Sanjikum for Bug#4950914
          r_installment_count := NULL;

          OPEN cur_installment_count(	cp_rcv_rgm_line_id => r_term.rcv_rgm_line_id,
          				cp_transaction_id  => rec_txns.transaction_id,
          				cp_tax_id	   => tax_rec.tax_id,
          				cp_schedule_id	   => ln_schedule_id);
					FETCH cur_installment_count INTO r_installment_count;
					CLOSE cur_installment_count;

					IF r_installment_count.count > 0 THEN
						DELETE  jai_rgm_trm_schedules_t
						WHERE   schedule_id = ln_schedule_id;

						IF p_simulate_flag = 'Y' THEN
							p_process_status := jai_constants.expected_error;
							p_process_message := 'Duplicate Records in jai_rcv_rgm_claims';
							--This message text is being compared for duplication check, so don't change this.
							--Or search for the same text in this package and change it at all the places
							RETURN;
						ELSE
							EXIT;
						END IF;

					END IF;

          IF p_simulate_flag = 'N' THEN
          --End Added by Sanjikum for Bug#4950914

						UPDATE  jai_rgm_trm_schedules_t
						SET     installment_amount = ROUND(installment_amount, tax_rec.rounding_factor)
						WHERE   schedule_id = ln_schedule_id;

						OPEN cur_sum_schedules(ln_schedule_id);
						FETCH cur_sum_schedules INTO r_sum_schedules;
						CLOSE cur_sum_schedules;
						IF NVL(r_sum_schedules.total_installment_amount,0) <> NVL(ln_amount,0) THEN
							UPDATE  jai_rgm_trm_schedules_t
							SET     installment_amount = installment_amount + ln_amount - r_sum_schedules.total_installment_amount
							WHERE   installment_no = r_sum_schedules.max_installment_no
							AND     schedule_id = ln_schedule_id;
						END IF;

						UPDATE  jai_rgm_trm_schedules_t
						SET     installment_amount = installment_amount*rec_txns.quantity_multiplier
						WHERE   schedule_id = ln_schedule_id;

						INSERT
						INTO    jai_rcv_rgm_claims
										(
											CLAIM_SCHEDULE_ID,
											RCV_RGM_LINE_ID,
											Shipment_header_id,
											Shipment_line_id,
											Regime_code,
											Tax_transaction_id,
											Transaction_type,
											Transaction_id,
											Parent_transaction_type,
											Installment_no,
											Installment_amount,
											Claimed_amount,
											Scheduled_date,
											claimed_date,
											Status,
											Manual_claim_flag,
											Remarks,
											Tax_type,
											Tax_id,
											Trx_tax_id,
											CREATED_BY,
											CREATION_DATE,
											LAST_UPDATED_BY,
											LAST_UPDATE_DATE,
											LAST_UPDATE_LOGIN
										)
						SELECT  jai_rcv_rgm_claims_s.NEXTVAL,
										r_term.rcv_rgm_line_id,
										rec_lines.shipment_header_id,
										rec_lines.shipment_line_id,
										jai_constants.vat_regime,
										rec_txns.tax_transaction_id,
										rec_txns.transaction_type,
										rec_txns.transaction_id,
										rec_txns.parent_transaction_type,
										installment_no,
										installment_amount,
										NULL,
										installment_date,
										NULL,
										'N',
										NULL,
										NULL,
										tax_rec.tax_type,
										tax_rec.tax_id,
										NULL,
										fnd_global.user_id,
										SYSDATE,
										fnd_global.user_id,
										SYSDATE,
										fnd_global.login_id
						FROM    jai_rgm_trm_schedules_t
						WHERE   schedule_id = ln_schedule_id;
					END IF; --end of p_simulate_flag


          DELETE  jai_rgm_trm_schedules_t
          WHERE   schedule_id = ln_schedule_id;

        END LOOP;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,200);
                     fnd_file.put_line(fnd_file.log, 'gone into error  ');
  END generate_schedule;

  PROCEDURE insert_rcv_lines(
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE,
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_regime_code         IN          JAI_RGM_DEFINITIONS.regime_code%TYPE,
                p_simulate_flag       IN          VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'N',
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2)
  IS
    r_trx                   c_trx%ROWTYPE;
    r_base_trx              c_base_trx%ROWTYPE;

    /* File.Sql.35 BY Brathod */
    ln_recoverable_amount     NUMBER ; -- := 0;
    ln_non_recoverable_amt    NUMBER ; -- := 0;
    ln_dup_chk                NUMBER ; -- := 0;
    lv_localpath              VARCHAR2(100); --  := '';
    /* End of File.Sql.35 by Brathod*/

    lv_breakup_type           VARCHAR2(10);
    lv_process_status         VARCHAR2(2);
    lv_process_message        VARCHAR2(1000);
    ln_apportion_factor       NUMBER;
    ln_curr_conv              NUMBER;
    lv_process_flag           VARCHAR2(2);
    lv_process_msg            VARCHAR2(1996);
    lv_item_class             jai_rgm_lookups.attribute_code%TYPE;
    ln_term_id                NUMBER;
    ln_location_id            NUMBER(15);

    CURSOR  c_tax_amount (cp_shipment_line_id  IN  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  nvl(rtl.tax_amount, 0) tax_amount,
            nvl(rtl.modvat_flag, 'N') modvat_flag,
            nvl(rtl.currency, jai_constants.func_curr) currency,
            nvl(jtc.rounding_factor, 0) rnd,
	    nvl(jtc.mod_cr_percentage, 0) modvat_percentage /*Added by Nitin for bug # 6681800*/
    FROM    JAI_RCV_LINE_TAXES rtl,
            JAI_CMN_TAXES_ALL jtc
    WHERE   shipment_line_id = cp_shipment_line_id
    AND     jtc.tax_id = rtl.tax_id
    AND     rtl.modvat_flag = 'Y'
    AND     jtc.tax_type IN (select tax_type
                           from jai_regime_tax_types_v
                           where regime_code = jai_constants.vat_regime);

    CURSOR  c_shipment_lines(cp_shipment_header_id   IN  rcv_shipment_headers.shipment_header_id%TYPE,
                             cp_shipment_line_id     IN  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  a.shipment_line_id, a.transaction_id, a.inventory_item_id, a.receipt_num, b.line_num
            , excise_invoice_no, excise_invoice_date -- brathod, Bug# 6109941
    FROM    JAI_RCV_LINES a,
            rcv_shipment_lines b
    WHERE   a.shipment_header_id = b.shipment_header_id
    AND     a.shipment_line_id = b.shipment_line_id
    AND     a.shipment_header_id = NVL(cp_shipment_header_id,a.shipment_header_id)
    AND     a.shipment_line_id = NVL(cp_shipment_line_id, a.shipment_line_id);

    CURSOR  c_regime (cp_regime_id   IN  JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL,
                      cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE DEFAULT NULL)
    IS
    SELECT  *
    FROM    JAI_RGM_DEFINITIONS
    WHERE   regime_id = NVL(cp_regime_id, regime_id)
    AND     regime_code = NVL(cp_regime_code, regime_code);

    /* Bug 4929929. Added by Lakshmi Gopalsami
       Removed the NVL as shipment_header_id and shipment_line_id
       cannot be null.
    */

    CURSOR  c_receipt_source_code(cp_shipment_header_id IN  rcv_shipment_headers.shipment_header_id%TYPE,
                                  cp_shipment_line_id   IN  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  receipt_source_code
    FROM    rcv_shipment_headers a,
            rcv_shipment_lines b
    WHERE   a.shipment_header_id = b.shipment_header_id
    AND     a.shipment_header_id = cp_shipment_header_id
    AND     b.shipment_line_id = cp_shipment_line_id;

    r_regime              c_regime%ROWTYPE;
    r_receipt_source_code c_receipt_source_code%ROWTYPE;

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
   /*bduvarag Bug 5899383 Start*/
    lv_def_vat_invoice_no         jai_rcv_transactions.excise_invoice_no%type;
    ld_def_vat_invoice_Date       jai_rcv_transactions.excise_invoice_date%type;
    lv_default_invoice_setup      VARCHAR2(100);
    /*bduvarag Bug 5899383 End*/

  BEGIN

    -- added, Ramananda for bug # 4519719

    OPEN c_vat_exists(p_shipment_line_id) ;
    FETCH c_vat_exists INTO ln_vat_exists ;
    CLOSE c_vat_exists ;

    IF ln_vat_exists <> 1 THEN
      return ;
    END IF ;

    -- ended, Ramananda for bug # 4519719

    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    /* File.Sql.35 by Brathod */
    ln_recoverable_amount     := 0;
    ln_non_recoverable_amt    := 0;
    ln_dup_chk                := 0;
    lv_localpath              := '';
    /* End of File.Sql.35 by Brathod */

    OPEN c_regime(NULL, jai_constants.vat_regime);
    FETCH c_regime INTO r_regime;
    CLOSE c_regime;

    OPEN c_receipt_source_code(p_shipment_header_id, p_shipment_line_id);
    FETCH c_receipt_source_code INTO r_receipt_source_code;
    CLOSE c_receipt_source_code;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, '1 insert_rcv_lines: Bef Main loop:');
      END IF;

    FOR rec_lines IN c_shipment_lines(p_shipment_header_id, p_shipment_line_id)
    LOOP
      OPEN c_trx(rec_lines.transaction_id);
      FETCH c_trx INTO r_trx;
      CLOSE c_trx;


      IF r_trx.transaction_type IN ('RECEIVE', 'MATCH')  THEN

        select  count(1)
        into    ln_dup_chk
        from    jai_rcv_rgm_lines
        where   transaction_id = r_trx.transaction_id;

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, '2 insert_rcv_lines:ln_dup_chk:'||ln_dup_chk);
        END IF;

        IF ln_dup_chk > 0 THEN
          return;
        END IF;

        ln_recoverable_amount := 0;

        FOR tax_rec IN c_tax_amount(rec_lines.shipment_line_id)
        LOOP
          IF tax_rec.currency <> jai_constants.func_curr THEN
            ln_curr_conv := NVL(r_trx.currency_conversion_rate, 1);
          ELSE
            ln_curr_conv := 1;
          END IF;
          ln_recoverable_amount  := ln_recoverable_amount + round(tax_rec.tax_amount * ln_curr_conv * (tax_rec.modvat_percentage/100), tax_rec.rnd);  /*ADDED BY NITIN FOR BUG # 6681800*/
        END LOOP;

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, '3 insert_rcv_lines:ln_recoverable_amount:'||ln_recoverable_amount);
        END IF;

        --In the Final Observation Change
        if ln_recoverable_amount = 0 then
          p_process_status := jai_constants.successful;
          p_process_message := NULL;
          RETURN;
        end if;

        OPEN c_base_trx(rec_lines.transaction_id);
        FETCH c_base_trx INTO r_base_trx;
        CLOSE c_base_trx;

        ln_location_id := r_base_trx.location_id;

        IF r_base_trx.location_id IS NULL
          /* following condition added by Vijay Shankar for Bug#4278511 to take care of ISO Scenario */
          OR r_base_trx.source_document_code = 'REQ'
        THEN
          get_location( p_transaction_id  => rec_lines.transaction_id,
                        p_location_id     => ln_location_id,
                        p_process_status  => lv_process_flag,
                        p_process_message => lv_process_msg);

          IF lv_process_flag <> jai_constants.successful THEN
            p_process_status := lv_process_flag;
            p_process_message := 'Error in Line Number '||rec_lines.line_num||' - '||lv_process_msg;
            RETURN;
          END IF;
        END IF;
        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, '4 insert_rcv_lines: after get_location:'||r_base_trx.location_id);
        END IF;


        jai_inv_items_pkg.jai_get_attrib(
                          p_regime_code       => r_regime.regime_code,
                          p_organization_id   => r_base_trx.organization_id,
                          p_inventory_item_id => rec_lines.inventory_item_id,
                          p_attribute_code    => 'ITEM CLASS',
                          p_attribute_value   => lv_item_class,
                          p_process_flag      => lv_process_flag,
                          p_process_msg       => lv_process_msg
                          );
        IF lv_process_flag <> jai_constants.successful THEN
          p_process_status := lv_process_flag;
          p_process_message := 'Error in Line Number '||rec_lines.line_num||' - '||lv_process_msg;
          RETURN;
        END IF;


        jai_cmn_rgm_terms_pkg.get_term_id(
                          p_regime_id       => r_regime.regime_id,
                          p_item_id         => rec_lines.inventory_item_id,
                          p_organization_id => r_base_trx.organization_id,
                          p_party_type      => jai_constants.orgn_type_io,
                          p_location_id     => ln_location_id,
                          p_term_id         => ln_term_id,
                          p_process_flag    => lv_process_flag,
                          p_process_msg     => lv_process_msg
                          );
        IF lv_process_flag <> jai_constants.successful THEN
          p_process_status := lv_process_flag;
          p_process_message := 'Error in Line Number '||rec_lines.line_num||' - '||lv_process_msg;
          RETURN;
        END IF;

        jai_cmn_rgm_terms_pkg.set_term_in_use(
                          p_term_id         => ln_term_id,
                          p_process_flag    => lv_process_flag,
                          p_process_msg     => lv_process_msg
                          );

        IF lv_process_flag <> jai_constants.successful THEN
          p_process_status := lv_process_flag;
          p_process_message := 'Error in Line Number '||rec_lines.line_num||' - '||lv_process_msg;
          RETURN;
        END IF;

        -- even if there is no VAT, then the data goes into this table
	/*bduvarag Bug 5899383 start*/
	        lv_default_invoice_setup := jai_cmn_rgm_recording_pkg.get_rgm_attribute_value(
                                    pv_regime_code          => jai_constants.vat_regime,
                                    pv_organization_type    => jai_constants.orgn_type_io,
                                    pn_organization_id      => r_trx.organization_id,
                                    pn_location_id          => ln_location_id,
                                    pv_registration_type    => jai_constants.regn_type_others, --'OTHERS',
                                    pv_attribute_type_code  => NULL,
                                    pv_attribute_code       => 'DEFAULT_INVOICE_DETAILS' ); --'DEFAULT_INVOICE_DETAILS');


        --
        -- Bug# 6109941
        -- All the reference to r_trx.excise_invoice_no and r_trx.excise_invoice_date are changed to
        -- rec_lines.excise_invoice_no and rec_lines.excise_invoice_date resp.
        --
        IF gv_debug THEN
           fnd_file.put_line(fnd_file.log, 'ABCD def_inv_setup : lv_default_invoice_setup:'||lv_default_invoice_setup);
           fnd_file.put_line(fnd_file.log, 'ABCD r_trx.organization_id : '||r_trx.organization_id);
           fnd_file.put_line(fnd_file.log, 'ABCD ln_location_id : '||ln_location_id);
           fnd_file.put_line(fnd_file.log, 'ABCD rec_lines.excise_invoice_no : '||rec_lines.excise_invoice_no); -- Bug# 6109941
           fnd_file.put_line(fnd_file.log, 'ABCD rec_lines.excise_invoice_date : '||rec_lines.excise_invoice_date); -- Bug# 6109941

        END IF;

        IF upper(lv_default_invoice_setup) in ( 'Y', 'YES') then

        /* Means - We can use the excise invoice number as vat invoice number and excise invoice date as vat invoice date
        || Need to check whether the ja_in_rcv_transactions has the excise_invoice_no and excise_invoice_Date stamped
           for the shipment line id .
        */

        IF rec_lines.excise_invoice_no is not NULL THEN                  -- Bug# 6109941
           lv_def_vat_invoice_no   := rec_lines.excise_invoice_no;       -- Bug# 6109941
           ld_def_vat_invoice_Date := rec_lines.excise_invoice_date;     -- Bug# 6109941
        ELSE
           lv_def_vat_invoice_no   := NULL;
           ld_def_vat_invoice_Date := NULL;
        END IF;

        --
        -- End Bug# 6109941
        --


        END IF;
	/*bduvarag Bug 5899383 End*/

        INSERT
        INTO    jai_rcv_rgm_lines
                (
                  RCV_RGM_LINE_ID,
                  SHIPMENT_HEADER_ID,
                  SHIPMENT_LINE_ID,
                  ORGANIZATION_ID,
                  LOCATION_ID,
                  INVENTORY_ITEM_ID,
                  RECEIPT_NUM,
                  RECEIPT_DATE,
                  REGIME_CODE,
                  REGIME_ITEM_CLASS,
                  TRANSACTION_ID,
                  RECOVERABLE_AMOUNT,
                  RECOVERED_AMOUNT,
                  PROCESS_STATUS_FLAG,
                  TERM_ID,
                 INVOICE_NO,
                INVOICE_DATE,
                  VENDOR_ID,
                  VENDOR_SITE_ID,
                  RECEIPT_SOURCE_CODE,
                  RECEIVE_QTY,
                  CORRECT_RECEIVE_QTY,
                  RTV_QTY,
                  CORRECT_RTV_QTY,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN
                )
        VALUES
                (
                  jai_rcv_rgm_lines_s.NEXTVAL,
                  r_base_trx.shipment_header_id,
                  r_base_trx.shipment_line_id,
                  r_base_trx.organization_id,
                  ln_location_id,
                  rec_lines.inventory_item_id,
                  rec_lines.receipt_num,
                  r_base_trx.transaction_date,
                  jai_constants.vat_regime,
                  lv_item_class,
                  r_trx.transaction_id,
                  ln_recoverable_amount,
                  0,
                  DECODE(NVL(ln_recoverable_amount,0), 0, 'X', 'N'),
                  ln_term_id,
                  lv_def_vat_invoice_no, /* bduvarag   Bug# 5899383*/
                  ld_def_vat_invoice_Date, /* bduvarag  Bug# 5899383*/
                  NULL,
                  NULL,
                  r_receipt_source_code.receipt_source_code,
                  r_base_trx.quantity,
                  NULL,
                  NULL,
                  NULL,
                  fnd_global.user_id,
                  SYSDATE,
                  fnd_global.user_id,
                  SYSDATE,
                  fnd_global.login_id);
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,200);
  END insert_rcv_lines;

  PROCEDURE update_rcv_lines(
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_receipt_num         IN          JAI_RCV_LINES.receipt_num%TYPE DEFAULT NULL,
                p_recoverable_amount  IN          jai_rcv_rgm_lines.recoverable_amount%TYPE DEFAULT NULL,
                p_recovered_amount    IN          jai_rcv_rgm_lines.recovered_amount%TYPE DEFAULT NULL,
                p_term_id             IN          jai_rgm_terms.term_id%TYPE DEFAULT -999,
                p_invoice_no          IN          JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE, --File.Sql.35 Cbabu  DEFAULT '-X9X',
                p_invoice_date        IN          JAI_RCV_TRANSACTIONS.vat_invoice_date%TYPE, --File.Sql.35 Cbabu  DEFAULT TO_DATE('01/01/1900','DD/MM/YYYY'),
                p_vendor_id           IN          po_vendors.vendor_id%TYPE DEFAULT -999,
                p_vendor_site_id      IN          po_vendor_sites_all.vendor_site_id%TYPE DEFAULT NULL,
                p_correct_receive_qty IN          jai_rcv_rgm_lines.correct_receive_qty%TYPE DEFAULT NULL,
                p_rtv_qty             IN          jai_rcv_rgm_lines.rtv_qty%TYPE DEFAULT NULL,
                p_correct_rtv_qty     IN          jai_rcv_rgm_lines.correct_rtv_qty%TYPE DEFAULT NULL,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2)
  IS
    ln_recoverable_amount NUMBER;
    ln_recovered_amount   NUMBER;
    lv_process_status_flag VARCHAR2(2);

    CURSOR c_total_amount(cp_shipment_header_id IN  rcv_shipment_headers.shipment_header_id%TYPE,
                          cp_shipment_line_id   IN  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  NVL(SUM(installment_amount),0) recoverable_amount,
            NVL(SUM(claimed_amount),0) recovered_amount
    FROM    jai_rcv_rgm_claims
    WHERE   shipment_header_id = cp_shipment_header_id
    AND     shipment_line_id = cp_shipment_line_id;

    r_total_amount  c_total_amount%ROWTYPE;
  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    IF p_shipment_line_id IS NULL AND p_receipt_num IS NULL THEN
      p_process_status := jai_constants.expected_error;
      p_process_message := 'Either of Shipment_line_id or receipt_num is mandatory';
      RETURN;
    END IF;

    OPEN c_total_amount(p_shipment_header_id, p_shipment_line_id);
    FETCH c_total_amount INTO r_total_amount;
    CLOSE c_total_amount;

    UPDATE  JAI_RCV_RGM_LINES
    SET     recoverable_amount  = r_total_amount.recoverable_amount,
            recovered_amount    = r_total_amount.recovered_amount,
            correct_receive_qty = NVL(correct_receive_qty,0) + NVL(p_correct_receive_qty,0),
            rtv_qty             = NVL(rtv_qty,0) + NVL(p_rtv_qty,0),
            correct_rtv_qty     = NVL(correct_rtv_qty,0) + NVL(p_correct_rtv_qty,0)
    WHERE   shipment_line_id    = NVL(p_shipment_line_id,shipment_line_id)
    AND     receipt_num         = NVL(p_receipt_num, receipt_num)
    RETURNING recoverable_amount, recovered_amount INTO ln_recoverable_amount, ln_recovered_amount;

    IF (ln_recovered_amount > 0) OR (ln_recoverable_amount = ln_recovered_amount) THEN
      --Interchanged the IF and ELSIF conditions for Bug #4279050, by Sanjikum
      IF ln_recoverable_amount = ln_recovered_amount THEN --
        lv_process_status_flag := 'F';
      ELSIF ln_recovered_amount > 0 THEN
        lv_process_status_flag := 'P';
      END IF;

      UPDATE  JAI_RCV_RGM_LINES
      SET     process_status_flag = lv_process_status_flag
      WHERE   shipment_line_id    = NVL(p_shipment_line_id,shipment_line_id)
      AND     receipt_num         = NVL(p_receipt_num, receipt_num);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,200);
  END update_rcv_lines;

  PROCEDURE process_vat(
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2)
  IS
    r_trx                   c_trx%ROWTYPE;
    r_base_trx              c_base_trx%ROWTYPE;

    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. lv_vat_invoice_no       JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE;

    lv_accounting_type      VARCHAR2(100);

    /* File.Sql.35 by Brathod */
    lv_account_nature       VARCHAR2(100); --  := 'VAT INTERIM';
    lv_source_name          VARCHAR2(100); -- := 'Purchasing India';
    lv_category_name        VARCHAR2(100); -- := 'Receiving India';
    lv_reference_23         gl_interface.reference23%TYPE ; -- := 'jai_rgm_claim_pkg.process_vat';
    lv_reference_24         gl_interface.reference24%TYPE ; -- := 'rcv_transactions';
    lv_reference_25         gl_interface.reference25%TYPE ; -- := p_transaction_id;
    lv_reference_26         gl_interface.reference26%TYPE ; -- := 'transaction_id';
    lv_destination          VARCHAR2(10) ; -- := 'G';
    ld_accounting_date      DATE    ; -- := TRUNC(SYSDATE);
    /* End of File.Sql.35 by Brathod */

    ln_code_combination_id  NUMBER;
    ln_entered_dr           NUMBER;
    ln_entered_cr           NUMBER;
    lv_currency_code        VARCHAR2(10);
    lv_reference_10         gl_interface.reference10%TYPE;
    lv_code_path            VARCHAR2(1996);
    lv_process_status       VARCHAR2(2);
    lv_process_message      VARCHAR2(1000);
    ln_location_id          NUMBER;
    ln_statement_id         NUMBER;

    /*CURSOR cur_total_tax(cp_transaction_id           IN  JAI_RCV_LINE_TAXES.transaction_id%TYPE,
                         cp_currency_conversion_rate IN JAI_RCV_TRANSACTIONS.currency_conversion_rate%TYPE)
    IS
    SELECT  SUM(DECODE(currency, jai_constants.func_curr, tax_amount, tax_amount*cp_currency_conversion_rate)) tax_amount
    FROM    JAI_RCV_LINE_TAXES
    WHERE   transaction_id = cp_transaction_id
    AND     tax_type in (select tax_type
                           from jai_regime_tax_types_v
                           where regime_code = jai_constants.vat_regime)
    AND     NVL(modvat_flag,'N') = 'Y';*/

    CURSOR  c_regime (cp_regime_id   IN  JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL,
                      cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE DEFAULT NULL)
    IS
    SELECT  *
    FROM    JAI_RGM_DEFINITIONS
    WHERE   regime_id = NVL(cp_regime_id, regime_id)
    AND     regime_code = NVL(cp_regime_code, regime_code);

    CURSOR  c_vat_invoice(cp_transaction_id  IN  NUMBER)
    IS
    SELECT  vat_invoice_no, vat_invoice_date
    FROM    JAI_RCV_TRANSACTIONS
    WHERE   transaction_id = cp_transaction_id;

    /*CURSOR  cur_txn(cp_transaction_id    IN  rcv_transactions.transaction_id%TYPE)
    IS
    SELECT  currency_conversion_rate,
            quantity,
            DECODE(transaction_type, 'RECEIVE', 1, 'RETURN TO VENDOR', -1, 'CORRECT',
                  DECODE(parent_transaction_type, 'RECEIVE', SIGN(quantity), 'RETURN TO VENDOR', SIGN(quantity)*-1))  quantity_multiplier
    FROM    JAI_RCV_TRANSACTIONS
    WHERE   transaction_id = cp_transaction_id
    AND     (
              transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
            OR
              (   transaction_type = 'CORRECT'
              AND parent_transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
              )
            );*/

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursor c_org_info and variable r_org_info
     * and implemented caching logic.
     */
    --cursor added by Ramananda for Bug#4530112
    CURSOR c_rcv_rgm_lines(cp_shipment_line_id  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  *
    FROM    jai_rcv_rgm_lines
    WHERE   shipment_line_id = cp_shipment_line_id;

    r_rcv_rgm_lines c_rcv_rgm_lines%ROWTYPE;

    r_regime  c_regime%ROWTYPE;
    --ln_total_cenvat_amount  NUMBER;
    ln_tax_amount NUMBER;
    --ln_apportion_factor NUMBER;

    lv_codepath   JAI_RCV_TRANSACTIONS.codepath%TYPE;
    lv_setup      VARCHAR2(10);
    r_vat_invoice c_vat_invoice%ROWTYPE;
    --r_txn         cur_txn%ROWTYPE;

    lv_simulate_flag VARCHAR2(1);   --File.Sql.35 Cbabu
    ln_rtv_qty              NUMBER;
    ln_correct_receive_qty  NUMBER;
    ln_correct_rtv_qty      NUMBER;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Defined variable for implementing caching logic.
     */
    l_func_curr_det      jai_plsql_cache_pkg.func_curr_details;
    lv_organization_code org_organization_definitions.organization_code%TYPE;
    -- End for bug 5243532

  BEGIN

    /* File.Sql.35 by Brathod */

    lv_account_nature       := 'VAT INTERIM';
    lv_source_name          := 'Purchasing India';
    lv_category_name        := 'Receiving India';
    lv_reference_23         := 'jai_rgm_claim_pkg.process_vat';
    lv_reference_24         := 'rcv_transactions';
    lv_reference_25         := p_transaction_id;
    lv_reference_26         := 'transaction_id';
    lv_destination          := 'G';
    ld_accounting_date      := TRUNC(SYSDATE);

    /* End of File.Sql.35 by Brathod */

    ln_statement_id := 1;

    lv_simulate_flag := jai_constants.no;   --File.Sql.35 Cbabu
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'rgm_claim_pkg.process_vat', 'START');

    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

--Start  for Bug#4950914
--means transacrion has already completed
    IF r_trx.process_vat_status = jai_constants.successful THEN
    	RETURN;
    END IF;

		--this is just to check, if the transaction has already been processed by checking the records from
		--jai_rcv_rgm_claims for current transaction
		generate_schedule (
												p_shipment_header_id  => r_trx.shipment_header_id,
												p_shipment_line_id    => r_trx.shipment_line_id,
												p_transaction_id      => r_trx.transaction_id,
												p_simulate_flag				=> 'Y',
												p_process_message     => lv_process_message,
												p_process_status      => lv_process_status,
												p_term_id	      => NULL,
												p_tax_id              => NULL,
												p_override            => NULL
											);
		IF lv_process_status = jai_constants.expected_error AND
			 lv_process_message = 'Duplicate Records in jai_rcv_rgm_claims' THEN
			 --This process message is being passed from the procedure generate_schedule
			 --So shouldn't be changed OR should be changed at all the places in the in this package
			RETURN;
		END IF;
    --End for Bug#4950914

    ln_statement_id := 2;
    lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath);

    ln_location_id := r_trx.location_id;

    ln_statement_id := 3;
    OPEN c_base_trx(p_transaction_id);
    FETCH c_base_trx INTO r_base_trx;
    CLOSE c_base_trx;

    --Code Added by Ramananda for Bug #4530112 the following Scenario
      --VAT Claim is not done
      --Following Transactions are being done
        --RTV
        --CORRECT OF RECEIVE
        --CORRECT OF RTV
    OPEN c_rcv_rgm_lines(r_trx.shipment_line_id);
    FETCH c_rcv_rgm_lines INTO r_rcv_rgm_lines;
    CLOSE c_rcv_rgm_lines;

    IF r_rcv_rgm_lines.invoice_no IS NULL AND (r_trx.transaction_type = 'RETURN TO VENDOR' OR (r_trx.transaction_type = 'CORRECT' AND r_trx.parent_transaction_type IN ('RECEIVE', 'MATCH', 'RETURN TO VENDOR') ) ) THEN
      --to Generate the Schedule for the Current Transaction
      generate_schedule (
                          p_shipment_header_id  => r_base_trx.shipment_header_id,
                          p_shipment_line_id    => r_base_trx.shipment_line_id,
                          p_transaction_id      => r_trx.transaction_id,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_override            => jai_constants.no --File.Sql.35 Added by Ramananda for bug#4530112
                        );

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        GOTO EXIT_POINT;
      END IF;

      IF r_trx.transaction_type = 'RETURN TO VENDOR' THEN
        ln_rtv_qty := r_base_trx.quantity;
      ELSIF r_trx.transaction_type = 'CORRECT' THEN
        IF r_trx.parent_transaction_type IN ('RECEIVE', 'MATCH') THEN
          ln_correct_receive_qty := r_base_trx.quantity;
        ELSIF r_trx.parent_transaction_type = 'RETURN TO VENDOR' THEN
          ln_correct_rtv_qty := r_base_trx.quantity;
        END IF;
      END IF;

      --to Update the jai_rcv_rgm_lines table for the Schedule generated above
      update_rcv_lines(p_shipment_header_id => r_base_trx.shipment_header_id,
                      p_shipment_line_id    => r_base_trx.shipment_line_id,
                      p_rtv_qty             => ln_rtv_qty,
                      p_correct_receive_qty => ln_correct_receive_qty,
                      p_correct_rtv_qty     => ln_correct_rtv_qty,
                      p_process_message     => lv_process_message,
                      p_process_status      => lv_process_status,
                      /* Added the following by Ramananda for bug#4530112 */
                       p_invoice_no   => jai_rcv_rgm_claims_pkg.gv_invoice_no_dflt,    --File.Sql.35
                       p_invoice_date => jai_rcv_rgm_claims_pkg.gd_invoice_date_dflt    --File.Sql.35
                      );

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        GOTO EXIT_POINT;
      END IF;

      GOTO EXIT_POINT;

    END IF;
    --End Added by Ramananda for Bug #4530112

    OPEN c_regime(NULL, jai_constants.vat_regime);
    FETCH c_regime INTO r_regime;
    CLOSE c_regime;
    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the commented codes for cursr cur_txn
     * and cur_total_tax.
     * Removed  cursor c_org_info and implemented caching logic.
     */

    l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => r_trx.organization_id );
    lv_organization_code  := l_func_curr_det.organization_code;

    ln_statement_id := 5;

    IF r_base_trx.transaction_type = 'CORRECT' THEN
      lv_reference_10 := 'India Local VAT Entries for Receipt:'||r_trx.receipt_num||'. Transaction Type CORRECT of '||r_trx.parent_transaction_type||' for the Organization code '||lv_organization_code;
    ELSE
      lv_reference_10 := 'India Local VAT Entries for Receipt:'||r_trx.receipt_num||'. Transaction Type '||r_trx.transaction_type||' for the Organization code '||lv_organization_code;
    END IF;

    lv_currency_code := jai_constants.func_curr;

    IF gv_debug THEN
      fnd_file.put_line(fnd_file.log, 'r_base_trx.transaction_type:'||r_base_trx.transaction_type);
    END IF;

    ln_statement_id := 6;
    IF r_base_trx.transaction_type IN ('RECEIVE', 'MATCH') THEN

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, '1 RECEIVE: Before insert_rcv_lines:');
      END IF;

      ln_statement_id := 7;
      --Populate the lines for quantity and Recoverable amount
      insert_rcv_lines(p_shipment_header_id => r_base_trx.shipment_header_id,
                       p_shipment_line_id   => r_base_trx.shipment_line_id,
                       p_transaction_id     => r_trx.transaction_id,
                       p_regime_code        => jai_constants.vat_regime,
                       p_process_message    => lv_process_message,
                       p_process_status     => lv_process_status,
                       p_simulate_flag      => lv_simulate_flag --File.Sql.35 Cbabu
                     );

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, '1.1 RECEIVE: After insert_rcv_lines:');
      END IF;

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        GOTO EXIT_POINT;
      END IF;

      lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);

      ln_statement_id := 8;
      generate_schedule(
                          p_shipment_header_id  => r_base_trx.shipment_header_id,
                          p_shipment_line_id    => r_base_trx.shipment_line_id,
                          p_transaction_id      => r_trx.transaction_id,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_override            => jai_constants.no --File.Sql.35 Cbabu
                       );

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        GOTO EXIT_POINT;
      END IF;

      IF r_base_trx.source_document_code = 'RMA' then  --.receipt_source_code = 'CUSTOMER' THEN
        do_rma_accounting(p_transaction_id  => p_transaction_id,
                          p_process_message => lv_process_message,
                          p_process_status  => lv_process_status
                         );

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          GOTO EXIT_POINT;
        END IF;
      END IF;

    ELSIF r_base_trx.transaction_type = 'RETURN TO VENDOR' THEN
      ln_statement_id := 9;
      lv_accounting_type := 'REVERSAL';

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'Inside RTV:');
      END IF;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'Before generate Schedule');
      END IF;

      ln_statement_id := 10;
      generate_schedule (
                          p_shipment_header_id => r_base_trx.shipment_header_id,
                          p_shipment_line_id => r_base_trx.shipment_line_id,
                          p_transaction_id => r_trx.transaction_id,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_override            => jai_constants.no --File.Sql.35 Cbabu
                        );

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        GOTO EXIT_POINT;
      END IF;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'After generate Schedule');
      END IF;

      /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'r_base_trx.attribute_category'||r_base_trx.attribute_category);
        fnd_file.put_line(fnd_file.log, 'r_base_trx.attribute4'||r_base_trx.attribute4);
      END IF;
      */

      ln_statement_id := 11;
      /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. IF r_base_trx.attribute_category = 'India Return to Vendor' AND r_base_trx.attribute4 = 'Y' THEN
      */
      --
      --  Bug# 6109941 , Removed commented code based on DFF logic
      --

      ln_statement_id := 14;
      do_rtv_accounting(  p_shipment_header_id  => r_base_trx.shipment_header_id,
                          p_shipment_line_id    => r_base_trx.shipment_line_id,
                          p_transaction_id      => p_transaction_id,
                          p_called_from         => 'RETURN TO VENDOR',
                          p_invoice_no          => r_trx.vat_invoice_no,  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. lv_vat_invoice_no,
                          p_invoice_date        => r_trx.vat_invoice_date,  --TRUNC(SYSDATE),
                          p_process_status      => lv_process_status,
                          p_process_message     => lv_process_message);

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        GOTO EXIT_POINT;
      END IF;

      ln_statement_id := 15;

      --ln_total_cenvat_amount := ln_total_cenvat_amount * r_txn.quantity_multiplier * ln_apportion_factor;

      ln_statement_id := 16;
      update_rcv_lines(p_shipment_header_id => r_base_trx.shipment_header_id,
                       p_shipment_line_id   => r_base_trx.shipment_line_id,
                       p_rtv_qty            => r_trx.quantity,
                       --p_recoverable_amount => ln_total_cenvat_amount,
                       p_process_message    => lv_process_message,
                       p_process_status     => lv_process_status,
                       p_invoice_no   => jai_rcv_rgm_claims_pkg.gv_invoice_no_dflt,    --File.Sql.35 Cbabu
                       p_invoice_date => jai_rcv_rgm_claims_pkg.gd_invoice_date_dflt    --File.Sql.35 Cbabu
                     );

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        GOTO EXIT_POINT;
      END IF;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'After update_rcv_lines:');
      END IF;
      ln_statement_id := 17;

    ELSIF r_base_trx.transaction_type = 'CORRECT' THEN

      IF r_trx.parent_transaction_type = 'RECEIVE' THEN
        ln_statement_id := 18;
        lv_accounting_type := 'REGULAR';

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'r_trx.parent_transaction_type :'||r_trx.parent_transaction_type);
        END IF;

        ln_statement_id := 19;
        generate_schedule (
                            p_shipment_header_id  => r_base_trx.shipment_header_id,
                            p_shipment_line_id    => r_base_trx.shipment_line_id,
                            p_transaction_id      => r_trx.transaction_id,
                            p_process_message     => lv_process_message,
                            p_process_status      => lv_process_status,
                            p_override            => jai_constants.no --File.Sql.35 Cbabu
                          );

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          GOTO EXIT_POINT;
        END IF;

        ln_statement_id := 20;
        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'After Generate Schedule');
        END IF;

        OPEN c_vat_invoice(r_trx.parent_transaction_id);
        FETCH c_vat_invoice INTO r_vat_invoice;
        CLOSE c_vat_invoice;

        ln_statement_id := 21;
        UPDATE  JAI_RCV_TRANSACTIONS
        SET     vat_invoice_no = r_vat_invoice.vat_invoice_no,
                vat_invoice_date = r_vat_invoice.vat_invoice_date
        WHERE   transaction_id = r_trx.transaction_id;

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'Before Process_Claim');
        END IF;

        ln_statement_id := 22;
        --Call the Claim API with Shipment_line_id
        process_claim(  p_regime_id           => r_regime.regime_id,
                        p_shipment_header_id  => r_base_trx.shipment_header_id,
                        p_shipment_line_id    => r_base_trx.shipment_line_id,
                        p_invoice_no          => r_vat_invoice.vat_invoice_no,
                        p_invoice_date        => TRUNC(SYSDATE),
                        p_called_from         => 'CORRECT OF RECEIVE',
                        p_process_message     => lv_process_message,
                        p_process_status      => lv_process_status
                     );

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          GOTO EXIT_POINT;
        END IF;

        IF r_base_trx.source_document_code = 'RMA' then  --r_receipt_source_code.receipt_source_code = 'CUSTOMER' THEN
          do_rma_accounting(p_transaction_id  => p_transaction_id,
                            p_process_message => lv_process_message,
                            p_process_status  => lv_process_status
                           );

          IF lv_process_status <> jai_constants.successful THEN
            p_process_status := lv_process_status;
            p_process_message := lv_process_message;
            GOTO EXIT_POINT;
          END IF;
        END IF;

        ln_statement_id := 23;
        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'After Process_claim');
        END IF;

        --ln_total_cenvat_amount := ln_total_cenvat_amount * r_txn.quantity_multiplier * ln_apportion_factor;

        --Update the lines
        update_rcv_lines(p_shipment_header_id => r_base_trx.shipment_header_id,
                        p_shipment_line_id    => r_base_trx.shipment_line_id,
                        p_correct_receive_qty => r_base_trx.quantity,
                        --p_recoverable_amount  => ln_total_cenvat_amount,
                        p_process_status      => lv_process_status,
                        p_process_message     => lv_process_message,
                       p_invoice_no   => jai_rcv_rgm_claims_pkg.gv_invoice_no_dflt,    --File.Sql.35 Cbabu
                       p_invoice_date => jai_rcv_rgm_claims_pkg.gd_invoice_date_dflt    --File.Sql.35 Cbabu
                      );

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          GOTO EXIT_POINT;
        END IF;

        ln_statement_id := 24;
        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'After Update_rcv_lines');
        END IF;

      ELSIF r_trx.parent_transaction_type = 'RETURN TO VENDOR' THEN
        lv_accounting_type := 'REVERSAL';

        ln_statement_id := 25;

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'r_trx.parent_transaction_type :'||r_trx.parent_transaction_type);
        END IF;

        generate_schedule (
                            p_shipment_header_id  => r_base_trx.shipment_header_id,
                            p_shipment_line_id    => r_base_trx.shipment_line_id,
                            p_transaction_id      => r_trx.transaction_id,
                            p_process_message     => lv_process_message,
                            p_process_status      => lv_process_status,
                            p_override            => jai_constants.no --File.Sql.35 Cbabu
                          );

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          GOTO EXIT_POINT;
        END IF;

        ln_statement_id := 26;

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'After Generate Schedule');
        END IF;

        --Get the VAT Invoice no from Parent
        OPEN c_trx(r_base_trx.parent_transaction_id);
        FETCH c_trx INTO r_trx;
        CLOSE c_trx;

        ln_statement_id := 27;

        --Update the VAT Invoice no in JAI_RCV_TRANSACTIONS
        UPDATE  JAI_RCV_TRANSACTIONS
        SET     vat_invoice_no = r_trx.vat_invoice_no,
                vat_invoice_date = TRUNC(SYSDATE)
        WHERE   transaction_id = r_base_trx.transaction_id; --r_trx now points to the parent transaction

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'Before Process_Claim');
        END IF;

        ln_statement_id := 28;

        do_rtv_accounting(  p_shipment_header_id  => r_base_trx.shipment_header_id,
                            p_shipment_line_id    => r_base_trx.shipment_line_id,
                            p_transaction_id      => p_transaction_id,
                            p_called_from         => 'CORRECT OF RETURN TO VENDOR',
                            p_invoice_no          => r_trx.vat_invoice_no,
                            p_invoice_date        => TRUNC(SYSDATE),
                            p_process_status      => lv_process_status,
                            p_process_message     => lv_process_message);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          GOTO EXIT_POINT;
        END IF;

        ln_statement_id := 29;
        /*
        --Call the Claim API with Shipment_line_id
        process_claim(  p_regime_id           => r_regime.regime_id,
                        p_shipment_header_id  => r_base_trx.shipment_header_id,
                        p_shipment_line_id    => r_base_trx.shipment_line_id,
                        p_invoice_no          => r_trx.vat_invoice_no,
                        p_invoice_date        => TRUNC(SYSDATE),
                        p_called_from         => 'CORRECT OF RETURN TO VENDOR',
                        p_process_message     => lv_process_message,
                        p_process_status      => lv_process_status
                     );

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          GOTO EXIT_POINT;
        END IF;

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'After Process_claim');
        END IF;
        */

        --ln_total_cenvat_amount := ln_total_cenvat_amount * r_txn.quantity_multiplier * ln_apportion_factor;

        ln_statement_id := 30;
        --Update the lines
        update_rcv_lines(p_shipment_header_id => r_base_trx.shipment_header_id,
                        p_shipment_line_id    => r_base_trx.shipment_line_id,
                        p_correct_rtv_qty     => r_base_trx.quantity,
                        p_process_message     => lv_process_message,
                        p_process_status      => lv_process_status,
                       p_invoice_no   => jai_rcv_rgm_claims_pkg.gv_invoice_no_dflt,    --File.Sql.35 Cbabu
                       p_invoice_date => jai_rcv_rgm_claims_pkg.gd_invoice_date_dflt    --File.Sql.35 Cbabu
                    );

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          GOTO EXIT_POINT;
        END IF;

        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'After Update_rcv_lines');
        END IF;

      END IF;
    END IF;
    <<EXIT_POINT>>
    UPDATE  JAI_RCV_TRANSACTIONS
    SET     PROCESS_VAT_STATUS = SUBSTR(p_process_status,1,2),
            process_vat_message = SUBSTR(p_process_message,1,1000)
    WHERE   transaction_id = p_transaction_id;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := 'Stmt :'||ln_statement_id||' '||SUBSTR(SQLERRM,1,200);
      fnd_file.put_line(fnd_file.log, 'PROCESS_VAT ERROR:'||p_process_message);

  END process_vat;

  PROCEDURE process_claim(
                p_regime_id           IN          JAI_RGM_DEFINITIONS.regime_id%TYPE,
                p_regime_regno        IN          VARCHAR2 DEFAULT NULL,
                p_organization_id     IN          hr_all_organization_units.organization_id%TYPE DEFAULT NULL,
                p_location_id         IN          hr_locations_all.location_id%TYPE DEFAULT NULL,
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_batch_id            IN          JAI_RCV_RGM_LINES.BATCH_NUM%TYPE DEFAULT NULL,
                p_force               IN          VARCHAR2 DEFAULT NULL,
                p_invoice_no          IN          JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE,
                p_invoice_date        IN          JAI_RCV_TRANSACTIONS.vat_invoice_date%TYPE,
                p_called_from         IN          VARCHAR2,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2)
  IS
    CURSOR cur_claims(cp_regime_id           IN  VARCHAR2,
                      cp_regime_regno        IN  VARCHAR2,
                      cp_organization_id     IN  NUMBER,
                      cp_location_id         IN  NUMBER,
                      cp_shipment_header_id  IN  VARCHAR2,
                      cp_shipment_line_id    IN  NUMBER,
                      cp_batch_id            IN  NUMBER,
                      cp_force               IN  VARCHAR2)
    IS
    SELECT  b.organization_id,
            b.location_id,
            b.shipment_header_id,
            b.shipment_line_id,
            b.scheduled_date,
            b.transaction_id,
            b.tax_type,
            b.installment_amount,
            b.installment_no,
            b.invoice_no,
            b.invoice_date,
            b.receipt_num,
            b.rcv_rgm_line_id
    FROM    JAI_RGM_ORG_REGNS_V a,
            jai_rcv_rgm_txns_v b,
            JAI_RGM_DEFINITIONS c
    WHERE   a.regime_code         = c.regime_code
    AND     c.regime_id           = cp_regime_id
    AND     a.attribute_value     = NVL(cp_regime_regno, a.attribute_value)
    AND     a.attribute_type_code = jai_constants.rgm_attr_type_code_primary --'PRIMARY'
    AND     a.attribute_code      = jai_constants.attr_code_regn_no --'REGISTRATION_NO'
    AND     a.organization_id     = NVL(cp_organization_id, a.organization_id)
    AND     a.location_id         = NVL(cp_location_id, a.location_id)
    AND     b.shipment_header_id  = NVL(cp_shipment_header_id,b.shipment_header_id)
    AND     b.shipment_line_id    = NVL(cp_shipment_line_id, b.shipment_line_id)
    AND     (     NVL(cp_batch_id,0) = 0
              OR  (NVL(cp_batch_id,0) <> 0 AND b.batch_num = cp_batch_id)
            )
    AND     a.organization_id     = b.organization_id
    AND     a.location_id         = b.location_id
    AND     b.scheduled_date      <= DECODE(cp_force, 'Y', b.scheduled_date, SYSDATE)
    AND     b.invoice_no IS NOT NULL
    AND     b.process_status_flag NOT IN ('Z') /* 'Z' meaning the line is marked for UNCLAIM, but not yet processed*/
    AND     NVL(b.installment_amount,0) <> 0;

    CURSOR  c_regime (cp_regime_id   IN  JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL,
                      cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE DEFAULT NULL)
    IS
    SELECT  *
    FROM    JAI_RGM_DEFINITIONS
    WHERE   regime_id = NVL(cp_regime_id, regime_id)
    AND     regime_code = NVL(cp_regime_code, regime_code);

    CURSOR c_claim_schedule( cp_shipment_header_id IN  rcv_shipment_headers.shipment_header_id%TYPE,
                             cp_shipment_line_id   IN  rcv_shipment_lines.shipment_line_id%TYPE,
                             cp_tax_type           IN  JAI_CMN_TAXES_ALL.tax_type%TYPE,
                             cp_installment_no     IN  jai_rcv_rgm_claims.installment_no%TYPE)
    IS
    SELECT  MIN(claim_schedule_id) claim_schedule_id
    FROM    jai_rcv_rgm_claims
    WHERE   shipment_header_id = cp_shipment_header_id
    AND     shipment_line_id = cp_shipment_line_id
    AND     tax_type = cp_tax_type
    AND     installment_no = cp_installment_no
    AND     nvl(status,'N') = 'N';

    CURSOR  c_vat_invoice(cp_shipment_header_id IN NUMBER,
                          cp_shipment_line_id   IN NUMBER)
    IS
    SELECT  a.vat_invoice_no, a.vat_invoice_date, b.transaction_id, a.tax_transaction_id,
                a.excise_invoice_no , a.excise_invoice_Date /*bduvarag Bug5899383*/
    FROM    JAI_RCV_TRANSACTIONS a,
            JAI_RCV_LINES b
    WHERE   a.transaction_id = b.transaction_id
    AND     b.shipment_header_id = cp_shipment_header_id
    AND     b.shipment_line_id = cp_shipment_line_id;

    lv_currency_code  VARCHAR2(10);
    r_regime  c_regime%ROWTYPE;

    lv_accounting_type      VARCHAR2(100);
    lv_account_nature       VARCHAR2(100); --  := 'VAT CLAIM';
    lv_source_name          VARCHAR2(100); --   := 'Purchasing India';
    lv_category_name        VARCHAR2(100); --   := 'Receiving India';
    ld_accounting_date      DATE ; --  := TRUNC(SYSDATE);
    lv_reference_10         gl_interface.reference10%TYPE;
    lv_reference_23         gl_interface.reference23%TYPE ; --   := 'jai_rgm_claim_pkg.process_claim';
    lv_reference_24         gl_interface.reference24%TYPE ; --  := 'jai_rgm_trx_records';
    lv_reference_26         gl_interface.reference26%TYPE ; --  := 'repository_id';
    lv_destination          VARCHAR2(10) ; --  := 'G';

    ln_code_combination_id  NUMBER;
    ln_entered_dr           NUMBER;
    ln_entered_cr           NUMBER;
    lv_reference_25         gl_interface.reference25%TYPE;
    lv_code_path            JAI_RCV_TRANSACTIONS.codepath%TYPE;
    lv_process_status       VARCHAR2(2);
    lv_process_message      VARCHAR2(1000);
    ln_repository_id        jai_rgm_trx_records.repository_id%TYPE;
    r_claim_schedule        c_claim_schedule%ROWTYPE;
    lv_codepath JAI_RCV_TRANSACTIONS.codepath%TYPE;
    ln_interim_recovery_account NUMBER;
    r_vat_invoice   c_vat_invoice%ROWTYPE;
    lv_source_trx_type  VARCHAR2(50);
    lv_account_name     VARCHAR2(50);
    lv_invoice_no       JAI_RCV_RGM_LINES.invoice_no%TYPE;
    ld_invoice_date     JAI_RCV_RGM_LINES.invoice_date%TYPE;
/*bduvarag Bug 5899383 Start*/
    lv_default_invoice_setup     VARCHAR2(100);
    ld_excise_invoice_Date       DATE;
/*bduvarag Bug 5899383 End*/
  BEGIN

    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    /* File.Sql.35 by Brathod */
    lv_account_nature        := 'VAT CLAIM';
    lv_source_name           := 'Purchasing India';
    lv_category_name         := 'Receiving India';
    ld_accounting_date       := TRUNC(SYSDATE);
    lv_reference_23          := 'jai_rgm_claim_pkg.process_claim';
    lv_reference_24          := 'jai_rgm_trx_records';
    lv_reference_26          := 'repository_id';
    lv_destination           := 'G';
    /* End of File.Sql.35 by Brathod */


    IF gv_debug THEN
      fnd_file.put_line(fnd_file.log, 'Inside Claim Process');
    END IF;

    OPEN c_regime(p_regime_id, NULL);
    FETCH c_regime INTO r_regime;
    CLOSE c_regime;

    IF p_called_from IN ('CONCURRENT', 'CORRECT OF RECEIVE') THEN
      lv_accounting_type := 'REGULAR';
    ELSIF p_called_from IN ('RETURN TO VENDOR', 'CORRECT OF RETURN TO VENDOR') THEN
      lv_accounting_type := 'REVERSAL';
    END IF;

    FOR rec_claims IN cur_claims( p_regime_id,
                                  p_regime_regno,
                                  p_organization_id,
                                  p_location_id,
                                  p_shipment_header_id,
                                  p_shipment_line_id,
                                  p_batch_id,
                                  p_force)
    LOOP

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'Inside Loop');
        fnd_file.put_line(fnd_file.log, 'Installment Amount : '||rec_claims.installment_amount);
        fnd_file.put_line(fnd_file.log, 'receipt_num : '||rec_claims.receipt_num);

      END IF;

      lv_reference_10 := 'India Local VAT Claim Entries For Receipt:'||rec_claims.receipt_num||' Transaction Type CLAIM for installment no '||rec_claims.installment_no;

      OPEN c_vat_invoice(rec_claims.shipment_header_id, rec_claims.shipment_line_id);
      FETCH c_vat_invoice INTO r_vat_invoice;
      CLOSE c_vat_invoice;

      IF r_vat_invoice.vat_invoice_no IS NULL OR r_vat_invoice.vat_invoice_date IS NULL THEN

        UPDATE  JAI_RCV_TRANSACTIONS
        SET     vat_invoice_no = rec_claims.invoice_no,
                vat_invoice_date = rec_claims.invoice_date
        WHERE   transaction_id = r_vat_invoice.transaction_id;
      END IF;
/*bduvarag Bug 5899383 start*/
      lv_default_invoice_setup := jai_cmn_rgm_recording_pkg.get_rgm_attribute_value(
                                  pv_regime_code          => jai_constants.vat_regime,
                                  pv_organization_type    => jai_constants.orgn_type_io,
                                  pn_organization_id      => rec_claims.organization_id,
                                  pn_location_id          => rec_claims.location_id,
                                  pv_registration_type    => jai_constants.regn_type_others, --'OTHERS',
                                  pv_attribute_type_code  => NULL,
                                  pv_attribute_code       => 'DEFAULT_INVOICE_DETAILS' ); --'DEFAULT_INVOICE_DETAILS');
      If upper(lv_default_invoice_setup) in ( 'Y', 'YES') then

      /* Means - We can use the excise invoice number as vat invoice number and excise invoice date as vat invoice date
      || and viceversa Need to check whether the ja_in_rcv_transactions has the excise_invoice_no and excise_invoice_Date stamped
         for the shipment line id .
      */

      IF rec_claims.invoice_no is not NULL  and r_vat_invoice.excise_invoice_no is null THEN

         --
         -- Bug 6109941, Removed update statement of dff attribute columns of
         -- RCV_SHIPMENT_HEADERS and RCV_TRASACTIONS tables
         --

         UPDATE JAI_RCV_LINES
         SET    excise_invoice_no   = rec_claims.invoice_no,
                excise_invoice_Date = rec_claims.invoice_date
         WHERE  shipment_header_id  = rec_claims.shipment_header_id
         AND    excise_invoice_no IS NULL;


         UPDATE jai_rcv_transactions
         SET    excise_invoice_no   = rec_claims.invoice_no,
                excise_invoice_Date = rec_claims.invoice_date
         WHERE  transaction_id      = r_vat_invoice.transaction_id
         AND    excise_invoice_no IS NULL;

         /*
         || End additions by ssumaith for defaulting the vat invoice number as excise invoice number - Bug# 5899383
         */


      END IF;
      END IF;
      /*bduvarag Bug 5899383 End*/
      --DO the Register_entry
      OPEN c_claim_schedule(rec_claims.shipment_header_id,
                            rec_claims.shipment_line_id,
                            rec_claims.tax_type,
                            rec_claims.installment_no);
      FETCH c_claim_schedule INTO r_claim_schedule;
      CLOSE c_claim_schedule;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'Before Start of Accounting');
      END IF;

      --Accounting
      lv_currency_code := jai_constants.func_curr;

      --for Balancing Accountid for register entry
      ln_interim_recovery_account :=
                                jai_cmn_rgm_recording_pkg.get_account(
                                  p_regime_id         => r_regime.regime_id,
                                  p_organization_type => jai_constants.orgn_type_io,
                                  p_organization_id   => rec_claims.organization_id,
                                  p_location_id       => rec_claims.location_id,
                                  p_tax_type          => rec_claims.tax_type,
                                  p_account_name      => jai_constants.recovery_interim);

      IF ln_interim_recovery_account IS NULL THEN
        p_process_status := jai_constants.expected_error;
        p_process_message := 'Interim recovery Account not defined in VAT Setup';
        RETURN;
      END IF;

      ln_code_combination_id :=
                                jai_cmn_rgm_recording_pkg.get_account(
                                  p_regime_id         => r_regime.regime_id,
                                  p_organization_type => jai_constants.orgn_type_io,
                                  p_organization_id   => rec_claims.organization_id,
                                  p_location_id       => rec_claims.location_id,
                                  p_tax_type          => rec_claims.tax_type,
                                  p_account_name      => jai_constants.recovery);

      IF ln_code_combination_id IS NULL THEN
        p_process_status := jai_constants.expected_error;
        p_process_message := 'Recovery Account not defined in VAT Setup';
        RETURN;
      END IF;

      ln_entered_dr := NULL;
      ln_entered_cr := rec_claims.installment_amount;

      IF ln_entered_cr < 0 THEN
        ln_entered_dr := ln_entered_cr*-1;
        ln_entered_cr := NULL;
      END IF;

      lv_account_name := jai_constants.recovery;
      /*
      IF p_called_from = 'RETURN TO VENDOR' THEN
        lv_source_trx_type := 'VAT CLAIM for RTV';
      ELSIF p_called_from = 'CORRECT OF RETURN TO VENDOR' THEN
        lv_source_trx_type := 'VAT CLAIM for CORRECT OF RTV';
      ELSIF p_called_from = 'CORRECT OF RECEIVE' THEN
        lv_source_trx_type := 'VAT CLAIM for CORRECT OF RCV';
      ELSE
        lv_source_trx_type := 'VAT CLAIM';
      END IF;
      */
      IF p_called_from = 'RETURN TO VENDOR' THEN
        lv_source_trx_type := RTV;
      ELSIF p_called_from = 'CORRECT OF RETURN TO VENDOR' THEN
        lv_source_trx_type := CORRECT_RTV;
      ELSIF p_called_from = 'CORRECT OF RECEIVE' THEN
        lv_source_trx_type := CORRECT_RECEIVE;
      ELSE
        lv_source_trx_type := RECEIVING;
      END IF;

      IF p_called_from = 'CONCURRENT' OR p_invoice_no IS NULL THEN
        lv_invoice_no := rec_claims.invoice_no;
        ld_invoice_date := rec_claims.invoice_date;
      ELSIF p_invoice_no IS NOT NULL THEN
        lv_invoice_no := p_invoice_no;
        ld_invoice_date := p_invoice_date;
      END IF;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'Before Passing the Repository Entry');
      END IF;

	 IF NVL(ln_entered_cr,0) <> 0 OR NVL(ln_entered_dr,0) <> 0 THEN --Added for Bug#4950914
				jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
																		pn_repository_id        => ln_repository_id,
											pn_regime_id            => r_regime.regime_id,
											pv_tax_type             => rec_claims.tax_type,
											pv_organization_type    => jai_constants.orgn_type_io,
											pn_organization_id      => rec_claims.organization_id,
											pn_location_id          => rec_claims.location_id,
											pv_source               => jai_constants.source_rcv,
											pv_source_trx_type      => lv_source_trx_type,
											pv_source_table_name    => TABLE_RCV_TRANSACTIONS,    /* 'JAI_RCV_RGM_CLAIMS', Vijay */
											pn_source_id            => nvl(r_vat_invoice.tax_transaction_id, r_vat_invoice.transaction_id), /* r_claim_schedule.claim_schedule_id, Vijay */
											pd_transaction_date     => trunc(sysdate),
											pv_account_name         => lv_account_name,
											pn_charge_account_id    => ln_code_combination_id,
											pn_balancing_account_id => ln_interim_recovery_account,
											pn_credit_amount        => ln_entered_cr,
											pn_debit_amount         => ln_entered_dr,
											pn_assessable_value     => NULL,
											pn_tax_rate             => NULL,
											pn_reference_id         => r_claim_schedule.claim_schedule_id,
											pn_batch_id             => NULL,
											pn_inv_organization_id  => rec_claims.organization_id,
											pv_invoice_no           => lv_invoice_no,
											pd_invoice_date         => ld_invoice_date,
											pv_called_from          => 'JAI_RGM_CLAIM_PKG.PROCESS_CLAIM',
											pv_process_flag         => lv_process_status,
											pv_process_message      => lv_process_message,
											 --Added by Bo Li for bug9305067 2010-4-14 BEGIN
                      --------------------------------------------------
											pv_trx_reference_context    => NULL,
											pv_trx_reference1           => NULL,
											pv_trx_reference2           => NULL,
											pv_trx_reference3           => NULL,
											pv_trx_reference4           => NULL,
											pv_trx_reference5           => NULL
											 --------------------------------------------------
											 --Added by Bo Li for bug9305067 2010-4-14 END


											);

				IF gv_debug THEN
					fnd_file.put_line(fnd_file.log, 'lv_process_status'||lv_process_status);
					fnd_file.put_line(fnd_file.log, 'lv_process_message'||lv_process_message);
				END IF;


				IF lv_process_status <> jai_constants.successful THEN
					p_process_status := lv_process_status;
					p_process_message := lv_process_message;
					RETURN;
				END IF;
			END IF;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'After Passing the Repository Entry');
      END IF;

      -- Dr VAT Recovery
      ln_entered_dr := rec_claims.installment_amount;
      ln_entered_cr := NULL;

      IF NVL(rec_claims.installment_amount,0) <> 0 THEN
        jai_rcv_accounting_pkg.process_transaction(
                          p_transaction_id      => rec_claims.transaction_id,
                          p_acct_type           => lv_accounting_type,
                          p_acct_nature         => lv_account_nature,
                          p_source_name         => lv_source_name,
                          p_category_name       => lv_category_name,
                          p_code_combination_id => ln_code_combination_id,
                          p_entered_dr          => ln_entered_dr,
                          p_entered_cr          => ln_entered_cr,
                          p_currency_code       => lv_currency_code,
                          p_accounting_date     => ld_accounting_date,
                          p_reference_10        => lv_reference_10,
                          p_reference_23        => lv_reference_23,
                          p_reference_24        => lv_reference_24,
                          p_reference_25        => ln_repository_id,
                          p_reference_26        => lv_reference_26,
                          p_destination         => lv_destination,
                          p_simulate_flag       => 'N',
                          p_codepath            => lv_code_path,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_reference_name      => 'JAI_RCV_RGM_CLAIMS',
                          p_reference_id        => r_claim_schedule.claim_schedule_id);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
        END IF;
      END IF;

      /*
      -- Cr Vat Interim
      ln_code_combination_id :=
                                jai_cmn_rgm_recording_pkg.get_account(
                                  p_regime_id         => r_regime.regime_id,
                                  p_organization_type => jai_constants.orgn_type_io,
                                  p_organization_id   => rec_claims.organization_id,
                                  p_location_id       => rec_claims.location_id,
                                  p_tax_type          => rec_claims.tax_type,
                                  p_account_name      => jai_constants.recovery_interim);

      IF ln_interim_recovery_account IS NULL THEN
        p_process_status := jai_constants.expected_error;
        p_process_message := 'Interim recovery Account not defined in VAT Setup';
        RETURN;
      END IF;
      */

      ln_entered_dr := NULL;
      ln_entered_cr := rec_claims.installment_amount;

      IF NVL(rec_claims.installment_amount,0) <> 0 THEN
        jai_rcv_accounting_pkg.process_transaction(
                          p_transaction_id      => rec_claims.transaction_id,
                          p_acct_type           => lv_accounting_type,
                          p_acct_nature         => lv_account_nature,
                          p_source_name         => lv_source_name,
                          p_category_name       => lv_category_name,
                          p_code_combination_id => ln_interim_recovery_account,
                          p_entered_dr          => ln_entered_dr,
                          p_entered_cr          => ln_entered_cr,
                          p_currency_code       => lv_currency_code,
                          p_accounting_date     => ld_accounting_date,
                          p_reference_10        => lv_reference_10,
                          p_reference_23        => lv_reference_23,
                          p_reference_24        => lv_reference_24,
                          p_reference_25        => ln_repository_id,
                          p_reference_26        => lv_reference_26,
                          p_destination         => lv_destination,
                          p_simulate_flag       => 'N',
                          p_codepath            => lv_code_path,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_reference_name      => 'JAI_RCV_RGM_CLAIMS',
                          p_reference_id        => r_claim_schedule.claim_schedule_id);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
        END IF;
      END IF;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'After Passing the Accounting Entry');
      END IF;

      UPDATE  jai_rcv_rgm_claims
      SET     status = 'Y',
              claimed_amount = installment_amount,
              claimed_date     = TRUNC(SYSDATE)
      WHERE   shipment_header_id = rec_claims.shipment_header_id
      AND     shipment_line_id = rec_claims.shipment_line_id
      AND     tax_type         = rec_claims.tax_type
      AND     installment_no   = rec_claims.installment_no
      AND     status           <> 'Y';

      --Update lines for recovered amount
      update_rcv_lines(p_shipment_header_id  => rec_claims.shipment_header_id,
                       p_shipment_line_id    => rec_claims.shipment_line_id,
                       p_recovered_amount    => rec_claims.installment_amount,
                       p_process_message     => lv_process_message,
                       p_process_status      => lv_process_status,
                       p_invoice_no   => jai_rcv_rgm_claims_pkg.gv_invoice_no_dflt,    --File.Sql.35 Cbabu
                       p_invoice_date => jai_rcv_rgm_claims_pkg.gd_invoice_date_dflt    --File.Sql.35 Cbabu
                       );

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        RETURN;
      END IF;


      --Update the claims table with status, claimed_amount and claim date
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR('jai_rcv_rgm_claims_pkg.process_claim Error:'||SQLERRM,1,200);
  END process_claim;

  /*PROCEDURE process_no_claim(
                p_shipment_header_id IN           rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id   IN           rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_batch_id           IN           jai_rcv_rgm_lines.batch_id%TYPE DEFAULT NULL,
                p_process_status     OUT NOCOPY   VARCHAR2,
                p_process_message    OUT NOCOPY   VARCHAR2)*/
  --commented the above  for Bug#4950914
  PROCEDURE process_no_claim(
                p_shipment_header_id  IN           rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN           rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_batch_id            IN           jai_rcv_rgm_lines.batch_num%TYPE DEFAULT NULL,
                p_regime_regno        IN           VARCHAR2 DEFAULT NULL,
                p_organization_id     IN           hr_all_organization_units.organization_id%TYPE DEFAULT NULL,
                p_location_id         IN           hr_locations_all.location_id%TYPE DEFAULT NULL,
                p_process_status      OUT NOCOPY   VARCHAR2,
                p_process_message     OUT NOCOPY   VARCHAR2,
                p_regime_id           IN           JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL )
  IS
    /*CURSOR  c_shipment_lines(cp_shipment_header_id  IN  rcv_shipment_headers.shipment_header_id%TYPE,
                             cp_shipment_line_id    IN  rcv_shipment_lines.shipment_line_id%TYPE,
                             cp_batch_id            IN  jai_rcv_rgm_lines.batch_id%TYPE)
    IS
    SELECT  shipment_header_id,
            shipment_line_id,
            receipt_num,
            transaction_id
    FROM    jai_rcv_rgm_lines
    WHERE   ((   NVL(cp_batch_id,0) = 0
            AND shipment_header_id  = NVL(cp_shipment_header_id, shipment_header_id)
            AND shipment_line_id    = NVL(cp_shipment_line_id, shipment_line_id))
    OR      (   NVL(cp_batch_id,0) <> 0
            AND batch_id            = cp_batch_id))
    AND     process_status_flag = 'Z'
    ORDER BY transaction_id;*/

    --commented the above and added the below for Bug#4950914

    CURSOR c_shipment_lines(cp_regime_id           IN  VARCHAR2,
 		            cp_regime_regno        IN  VARCHAR2,
			    cp_organization_id     IN  NUMBER,
			    cp_location_id         IN  NUMBER,
			    cp_shipment_header_id  IN  VARCHAR2,
			    cp_shipment_line_id    IN  NUMBER,
			    cp_batch_id            IN  NUMBER)
    IS
    SELECT  b.organization_id,
            b.location_id,
            b.shipment_header_id,
            b.shipment_line_id,
            b.transaction_id,
            b.receipt_num,
            b.rcv_rgm_line_id
    FROM    JAI_RGM_ORG_REGNS_V a,
            jai_rcv_rgm_lines b,
            JAI_RGM_DEFINITIONS c
    WHERE   a.regime_code         = c.regime_code
    AND     c.regime_id           = cp_regime_id
    AND     a.attribute_value     = NVL(cp_regime_regno, a.attribute_value)
    AND     a.attribute_type_code = jai_constants.rgm_attr_type_code_primary --'PRIMARY'
    AND     a.attribute_code      = jai_constants.attr_code_regn_no --'REGISTRATION_NO'
    AND     a.organization_id     = NVL(cp_organization_id, a.organization_id)
    AND     a.location_id         = NVL(cp_location_id, a.location_id)
    AND     b.shipment_header_id  = NVL(cp_shipment_header_id,b.shipment_header_id)
    AND     b.shipment_line_id    = NVL(cp_shipment_line_id, b.shipment_line_id)
    AND     (     NVL(cp_batch_id,0) = 0
              OR  (NVL(cp_batch_id,0) <> 0 AND b.BATCH_NUM = cp_batch_id)
            )
    AND     a.organization_id     = b.organization_id
    AND     a.location_id         = b.location_id
    AND     b.process_status_flag = 'Z'; /* 'Z' meaning the line is marked for UNCLAIM, but not yet processed*/

    CURSOR cur_tax(cp_transaction_id           IN JAI_RCV_LINE_TAXES.transaction_id%TYPE,
                   cp_currency_conversion_rate IN JAI_RCV_TRANSACTIONS.currency_conversion_rate%TYPE)
    IS
    SELECT  jtl.tax_type,
            /*Added by Nitin for Bug # 6681800 */ SUM(DECODE(jtl.currency, jai_constants.func_curr, jtl.tax_amount*(rtl.mod_cr_percentage/100), jtl.tax_amount*(rtl.mod_cr_percentage/100)*cp_currency_conversion_rate)) tax_amount
	    /*Commented by Nitin for bug :6681800 SUM(DECODE(currency, jai_constants.func_curr, tax_amount, tax_amount*cp_currency_conversion_rate)) tax_amount*/
    FROM    JAI_RCV_LINE_TAXES jtl ,JAI_CMN_TAXES_ALL rtl  /* Need to have join with JAI_CMN_TAXES_ALL*/
    WHERE   jtl.transaction_id = cp_transaction_id
    AND     jtl.tax_type in (select tax_type
                         from jai_regime_tax_types_v
                         where regime_code = jai_constants.vat_regime)
    AND     NVL(jtl.modvat_flag,'N') = 'Y'
    AND    jtl.tax_id = rtl.tax_id -- Bug 7454592. Added by Lakshmi Gopalsami
    GROUP BY jtl.tax_type;

    CURSOR cur_total_tax(cp_transaction_id           IN JAI_RCV_LINE_TAXES.transaction_id%TYPE,
                         cp_currency_conversion_rate IN JAI_RCV_TRANSACTIONS.currency_conversion_rate%TYPE)
    IS
    SELECT  SUM(ROUND(DECODE(a.currency, jai_constants.func_curr, /*Added by Nitin for bug # 6681800*/a.tax_amount*(b.mod_cr_percentage/100), a.tax_amount*(b.mod_cr_percentage/100)*cp_currency_conversion_rate),NVL(b.rounding_factor,1))) tax_amount
    FROM    JAI_RCV_LINE_TAXES a,
            JAI_CMN_TAXES_ALL b
    WHERE   a.transaction_id = cp_transaction_id
    AND     a.tax_type in (select tax_type
                           from jai_regime_tax_types_v
                           where regime_code = jai_constants.vat_regime)
    AND     a.tax_id = b.tax_id
    AND     NVL(a.modvat_flag,'N') = 'Y';

    CURSOR c_receive_transaction(cp_shipment_header_id IN  rcv_shipment_headers.shipment_header_id%TYPE,
                                 cp_shipment_line_id IN  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  transaction_id,
            organization_id,
            location_id,
            currency_conversion_rate
    FROM    JAI_RCV_TRANSACTIONS
    WHERE   shipment_header_id = cp_shipment_header_id
    AND     shipment_line_id = cp_shipment_line_id
    AND     transaction_type = 'RECEIVE';

    CURSOR  c_regime (cp_regime_id   IN  JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL,
                      cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE DEFAULT NULL)
    IS
    SELECT  *
    FROM    JAI_RGM_DEFINITIONS
    WHERE   regime_id = NVL(cp_regime_id, regime_id)
    AND     regime_code = NVL(cp_regime_code, regime_code);

    CURSOR  c_rcv_parameters(cp_organization_id number) IS
    SELECT  receiving_account_id
    FROM    rcv_parameters
    WHERE   organization_id = cp_organization_id;

    lv_ttype_receive  JAI_RCV_TRANSACTIONS.transaction_type%type;
    lv_ttype_correct  JAI_RCV_TRANSACTIONS.transaction_type%type;
    lv_ttype_deliver  JAI_RCV_TRANSACTIONS.transaction_type%type;
    lv_ttype_rtr      JAI_RCV_TRANSACTIONS.transaction_type%type;

    CURSOR  c_receive_correct_txns(cp_shipment_header_id  IN  rcv_shipment_headers.shipment_header_id%TYPE,  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
                                  cp_shipment_line_id    IN  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  transaction_id,
            tax_transaction_id
    FROM    JAI_RCV_TRANSACTIONS
    WHERE   shipment_header_id = cp_shipment_header_id
    AND     shipment_line_id = cp_shipment_line_id
    AND     (   transaction_type = lv_ttype_receive --'RECEIVE'
            OR
                (   transaction_type =  lv_ttype_correct -- 'CORRECT'
                AND parent_transaction_type = lv_ttype_receive )--'RECEIVE')
            )
    ORDER BY transaction_id;

    CURSOR  c_deliver_rtr_txns(cp_shipment_header_id  IN  rcv_shipment_headers.shipment_header_id%TYPE,
                               cp_shipment_line_id    IN  rcv_shipment_lines.shipment_line_id%TYPE) /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    IS
    SELECT  transaction_id,
            tax_transaction_id,
            SIGN(quantity)  quantity_multiplier
    FROM    JAI_RCV_TRANSACTIONS
    WHERE   shipment_header_id = cp_shipment_header_id
    AND     shipment_line_id = cp_shipment_line_id
    AND     (   transaction_type IN (lv_ttype_deliver, lv_ttype_rtr) --('DELIVER', 'RETURN TO RECEIVING')
            OR
                (   transaction_type = lv_ttype_correct --'CORRECT'
                AND parent_transaction_type IN (lv_ttype_deliver, lv_ttype_rtr)) --('DELIVER', 'RETURN TO RECEIVING'))
            )
    ORDER BY transaction_id;

    r_regime            c_regime%ROWTYPE;
    r_rcv_parameters    c_rcv_parameters%rowtype;
    r_receive_transaction c_receive_transaction%ROWTYPE;


    /* File.Sql.35 by Brathod */
    lv_accounting_type      VARCHAR2(100) ; -- := 'REGULAR';
    lv_account_nature       VARCHAR2(100) ; -- := 'VAT NO CLAIM';
    lv_source_name          VARCHAR2(100) ; -- := 'Purchasing India';
    lv_category_name        VARCHAR2(100) ; -- := 'Receiving India';
    ld_accounting_date      DATE          ; -- := TRUNC(SYSDATE);
    lv_reference_10         gl_interface.reference10%TYPE ; -- := 'VAT Unclaim of the Receiving Entries';
    lv_reference_23         gl_interface.reference23%TYPE ; -- := 'jai_rgm_claim_pkg.process_no_claim';
    lv_reference_24         gl_interface.reference24%TYPE ; -- := 'JAI_RCV_TRANSACTIONS';
    lv_reference_25         gl_interface.reference25%TYPE ;
    lv_reference_26         gl_interface.reference26%TYPE ; -- := 'transaction_id';
    lv_destination          VARCHAR2(10) ; -- := 'G';
    /* End of File.Sql.35 by Brathod */

    ln_code_combination_id  NUMBER;
    ln_entered_dr           NUMBER;
    ln_entered_cr           NUMBER;
    lv_currency_code        VARCHAR2(10);

    lv_code_path            VARCHAR2(1996);
    lv_process_status       VARCHAR2(2);
    lv_process_message      VARCHAR2(1000);
    lv_codepath             JAI_RCV_TRANSACTIONS.codepath%TYPE;
    rec_total_tax           cur_total_tax%ROWTYPE;
    ln_process_special_amount  NUMBER;
    ln_apportion_factor     NUMBER;

    /*Bug 8648138*/
    ln_invoice_id ap_invoice_distributions_all.invoice_id%TYPE;

    CURSOR get_invoice(cp_transaction_id NUMBER) IS
    SELECT DISTINCT invoice_id
    FROM ap_invoice_distributions_all
    WHERE rcv_transaction_id = cp_transaction_id;
    /*Bug 8648138*/

  BEGIN
    /* File.Sql.35 BY Brathod */
    lv_accounting_type      := 'REGULAR';
    lv_account_nature       := 'VAT NO CLAIM';
    lv_source_name          := 'Purchasing India';
    lv_category_name        := 'Receiving India';
    ld_accounting_date      := TRUNC(SYSDATE);
    lv_reference_10         := 'VAT Unclaim of the Receiving Entries';
    lv_reference_23         := 'jai_rgm_claim_pkg.process_no_claim';
    lv_reference_24         := 'JAI_RCV_TRANSACTIONS';
    lv_reference_26         := 'transaction_id';
    lv_destination          := 'G';
    /* End of File.Sql.35 by Brathod */

    p_process_status := jai_constants.successful;
    p_process_message := NULL;


    lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'jai_rcv_rgm_claims_pkg.process_no_claim', 'START');

    OPEN c_regime(NULL, jai_constants.vat_regime);
    FETCH c_regime INTO r_regime;
    CLOSE c_regime;

        /*FOR r_shipment_lines IN c_shipment_lines(p_shipment_header_id,
                                             p_shipment_line_id,
                                             p_batch_id)*/
		--commented the above and added the below  for Bug#4950914
    FOR r_shipment_lines IN c_shipment_lines(	cp_regime_id           =>		p_regime_id,
						cp_regime_regno        => 	p_regime_regno,
						cp_organization_id     => 	p_organization_id,
						cp_location_id         => 	p_location_id,
						cp_shipment_header_id  => 	p_shipment_header_id,
						cp_shipment_line_id    => 	p_shipment_line_id,
						cp_batch_id            => 	p_batch_id)
    LOOP

      r_receive_transaction := NULL;
      r_rcv_parameters      := NULL;

      lv_reference_10 := 'India Local UnClaim VAT Entries for Receipt:'||r_shipment_lines.receipt_num||'. Transaction Type VAT Unclaim';

      lv_reference_25 := r_shipment_lines.transaction_id;

      lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath);

      OPEN c_receive_transaction(r_shipment_lines.shipment_header_id, r_shipment_lines.shipment_line_id);
      FETCH c_receive_transaction INTO r_receive_transaction;
      CLOSE c_receive_transaction;

      OPEN c_rcv_parameters(r_receive_transaction.organization_id);
      FETCH c_rcv_parameters into r_rcv_parameters;
      CLOSE c_rcv_parameters;

      --Pass the accounting entry
     lv_ttype_receive := 'RECEIVE' ;
     lv_ttype_correct := 'CORRECT' ;

      FOR r_receive_correct_txns IN c_receive_correct_txns(r_shipment_lines.shipment_header_id, r_shipment_lines.shipment_line_id)
      LOOP

        ln_apportion_factor := jai_rcv_trx_processing_pkg.get_apportion_factor(r_receive_correct_txns.transaction_id);

        FOR rec_tax IN cur_tax(r_receive_transaction.transaction_id, r_receive_transaction.currency_conversion_rate)
        LOOP
          lv_currency_code := jai_constants.func_curr;

          --DR Inventory Receiving
          ln_code_combination_id := r_rcv_parameters.receiving_account_id;

          ln_entered_dr := rec_tax.tax_amount*ln_apportion_factor;
          ln_entered_cr := NULL;

 IF NVL(ln_entered_dr,0) <> 0 OR NVL(ln_entered_cr,0) <> 0 THEN --Added  for Bug#4950914
          jai_rcv_accounting_pkg.process_transaction(
                          p_transaction_id      => r_receive_correct_txns.transaction_id,
                          p_acct_type           => lv_accounting_type,
                          p_acct_nature         => lv_account_nature,
                          p_source_name         => lv_source_name,
                          p_category_name       => lv_category_name,
                          p_code_combination_id => ln_code_combination_id,
                          p_entered_dr          => ln_entered_dr,
                          p_entered_cr          => ln_entered_cr,
                          p_currency_code       => lv_currency_code,
                          p_accounting_date     => ld_accounting_date,
                          p_reference_10        => lv_reference_10,
                          p_reference_23        => lv_reference_23,
                          p_reference_24        => lv_reference_24,
                          p_reference_25        => lv_reference_25,
                          p_reference_26        => lv_reference_26,
                          p_destination         => lv_destination,
                          p_simulate_flag       => 'N',
                          p_codepath            => lv_code_path,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_reference_name      => rec_tax.tax_type,
                          p_reference_id        => NULL);

          IF lv_process_status <> jai_constants.successful THEN
            p_process_status := lv_process_status;
            p_process_message := lv_process_message;
            RETURN;
          END IF;
      END IF;

          --CR VAT Interrim
          ln_code_combination_id :=
                                  jai_cmn_rgm_recording_pkg.get_account(
                                    p_regime_id         => r_regime.regime_id,
                                    p_organization_type => jai_constants.orgn_type_io,
                                    p_organization_id   => r_receive_transaction.organization_id,
                                    p_location_id       => r_receive_transaction.location_id,
                                    p_tax_type          => rec_tax.tax_type,
                                    p_account_name      => jai_constants.recovery_interim);

          ln_entered_dr := NULL;
          ln_entered_cr := rec_tax.tax_amount*ln_apportion_factor;

IF NVL(ln_entered_dr,0) <> 0 OR NVL(ln_entered_cr,0) <> 0 THEN --Added  for Bug#4950914
          jai_rcv_accounting_pkg.process_transaction(
                          p_transaction_id      => r_receive_correct_txns.transaction_id,
                          p_acct_type           => lv_accounting_type,
                          p_acct_nature         => lv_account_nature,
                          p_source_name         => lv_source_name,
                          p_category_name       => lv_category_name,
                          p_code_combination_id => ln_code_combination_id,
                          p_entered_dr          => ln_entered_dr,
                          p_entered_cr          => ln_entered_cr,
                          p_currency_code       => lv_currency_code,
                          p_accounting_date     => ld_accounting_date,
                          p_reference_10        => lv_reference_10,
                          p_reference_23        => lv_reference_23,
                          p_reference_24        => lv_reference_24,
                          p_reference_25        => lv_reference_25,
                          p_reference_26        => lv_reference_26,
                          p_destination         => lv_destination,
                          p_simulate_flag       => 'N',
                          p_codepath            => lv_code_path,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_reference_name      => rec_tax.tax_type,
                          p_reference_id        => NULL);

          IF lv_process_status <> jai_constants.successful THEN
            p_process_status := lv_process_status;
            p_process_message := lv_process_message;
            RETURN;
          END IF;
    END IF;

	END LOOP;
      END LOOP;

      -- LOOP Through DELIVER/RTR

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'Before the Deliver RTR Transaction Cost Reversal');
        fnd_file.put_line(fnd_file.log, 'Shipment_header_id'||r_shipment_lines.shipment_header_id);
        fnd_file.put_line(fnd_file.log, 'Shipment_line_id'||r_shipment_lines.shipment_line_id);
      END IF;

      lv_ttype_deliver :=  'DELIVER' ;
      lv_ttype_rtr     :=  'RETURN TO RECEIVING' ;
      lv_ttype_receive := 'RECEIVE' ;
      lv_ttype_correct := 'CORRECT' ;


      FOR r_deliver_rtr_txns IN c_deliver_rtr_txns(r_shipment_lines.shipment_header_id, r_shipment_lines.shipment_line_id)
      LOOP

        OPEN cur_total_tax(r_deliver_rtr_txns.tax_transaction_id, r_receive_transaction.currency_conversion_rate);
        FETCH cur_total_tax INTO rec_total_tax;
        CLOSE cur_total_tax;

        ln_process_special_amount := rec_total_tax.tax_amount *
                                     ABS(jai_rcv_trx_processing_pkg.get_apportion_factor(r_deliver_rtr_txns.transaction_id)) *
                                     r_deliver_rtr_txns.quantity_multiplier;
        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'In the LOOP');
          fnd_file.put_line(fnd_file.log, 'Tax_transaction_id'||r_deliver_rtr_txns.Tax_transaction_id);
          fnd_file.put_line(fnd_file.log, 'transaction_id'||r_deliver_rtr_txns.transaction_id);
          fnd_file.put_line(fnd_file.log, 'currency_conversion_rate'||r_receive_transaction.currency_conversion_rate);
          fnd_file.put_line(fnd_file.log, 'Tax_amount'||rec_total_tax.tax_amount);
          fnd_file.put_line(fnd_file.log, 'Apportion Factor'||ABS(jai_rcv_trx_processing_pkg.get_apportion_factor(r_deliver_rtr_txns.transaction_id)));

        END IF;

        jai_rcv_deliver_rtr_pkg.process_transaction(
                                        p_transaction_id          => r_deliver_rtr_txns.transaction_id,
                                        p_simulate                => jai_constants.no,
                                        p_codepath                => lv_code_path,
                                        p_process_message         => lv_process_message,
                                        p_process_status          => lv_process_status,
                                        p_process_special_source  => jai_constants.vat_noclaim,
                                        p_process_special_amount  => nvl(ln_process_special_amount,0));   --Added nvl condition by Bgowrava for Bug#8414075


        IF lv_process_status = 'E' THEN
          p_process_status := jai_constants.expected_error;
          p_process_message := lv_process_message;
          RETURN;
        END IF;

      END LOOP;

      /*Bug 8648138 - Unclaimed VAT amount should be available for re-transfer to FA from AP, if the transfer
      is done before unclaim*/

      ln_invoice_id := NULL;
      FOR r_invoice IN get_invoice(r_receive_transaction.transaction_id)
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
                 WHERE jrtl.tax_id = jatd.tax_id
                 AND   jatd.invoice_id = ln_invoice_id
                 AND   jrtl.transaction_id = r_receive_transaction.transaction_id
                 AND   jrtl.shipment_line_id = r_shipment_lines.shipment_line_id
                 AND   jrtl.modvat_flag = 'Y'
                 AND   jrtl.tax_type IN (SELECT tax_type
                                         FROM jai_regime_tax_types_v
                                         WHERE regime_code = jai_constants.vat_regime)) ;

          END IF;
      END LOOP;
      /*Bug 8648138*/

      UPDATE  JAI_RCV_LINE_TAXES
      SET     modvat_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = fnd_global.user_id,
              last_update_login = fnd_global.login_id
      WHERE   shipment_header_id = r_shipment_lines.shipment_header_id
      AND     shipment_line_id  = r_shipment_lines.shipment_line_id
      AND     tax_type IN (select tax_type
                           from jai_regime_tax_types_v
                           where regime_code = jai_constants.vat_regime)
      AND     modvat_flag = 'Y';

      --To update the Status, so that It should not be considered for claiming
      UPDATE  jai_rcv_rgm_lines
      SET     process_status_flag = 'U',
              recoverable_amount = 0,
              recovered_amount = 0
      WHERE   shipment_header_id = r_shipment_lines.shipment_header_id
      AND     shipment_line_id = r_shipment_lines.shipment_line_id;
      --ABC--Update the other fields also, which are updated at the time of inserting the lines

      --Ideally, this shouldn't delete any rows.
      DELETE  jai_rcv_rgm_claims
      WHERE   shipment_header_id = r_shipment_lines.shipment_header_id
      AND     shipment_line_id = r_shipment_lines.shipment_line_id;
    END LOOP;

    lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath, 'jai_rcv_rgm_claims_pkg.process_no_claim', 'START');
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,200);
  END process_no_claim;

  PROCEDURE process_batch(
                errbuf                OUT NOCOPY  VARCHAR2,
                retcode               OUT NOCOPY  VARCHAR2,
                p_regime_id           IN          JAI_RGM_DEFINITIONS.regime_id%TYPE,
                p_regime_regno        IN          VARCHAR2 DEFAULT NULL,
                p_organization_id     IN          hr_all_organization_units.organization_id%TYPE DEFAULT NULL,
                p_location_id         IN          hr_locations_all.location_id%TYPE DEFAULT NULL,
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_batch_id            IN          JAI_RCV_RGM_LINES.BATCH_NUM%TYPE DEFAULT NULL,
                p_force               IN          VARCHAR2 DEFAULT NULL,
                p_commit_switch       IN          VARCHAR2,
                p_invoice_no          IN          JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE,
                pv_invoice_date        IN          VARCHAR2,  /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
                p_called_from         IN          VARCHAR2)
  IS
    lv_process_status  VARCHAR2(2);
    lv_process_message VARCHAR2(1996);
    lv_codepath JAI_RCV_TRANSACTIONS.codepath%TYPE;

    /* rallamse bug#4336482 */
     p_invoice_date CONSTANT DATE DEFAULT fnd_date.canonical_to_date(pv_invoice_date);
    /* End of Bug# 4336482 */

    -- Date 29/05/2007 by sacsethi for bug 6078460
    -- Cursor where clause changed

    CURSOR  c_regime (cp_regime_id   IN  JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL,
                      cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE DEFAULT NULL)
    IS
    SELECT  *
    FROM    JAI_RGM_DEFINITIONS
    WHERE   (regime_id is null OR ( cp_regime_id IS NULL OR regime_id = cp_regime_id  ))  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    AND     (regime_code = cp_regime_code OR  regime_code is null);

    --WHERE   regime_id = NVL(cp_regime_id, regime_id)
    --AND     regime_code = NVL(cp_regime_code, regime_code);

    r_regime c_regime%ROWTYPE;

  BEGIN
    lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'jai_rcv_rgm_claims_pkg.process_batch', 'START');


    OPEN c_regime(p_regime_id, NULL);
    FETCH c_regime INTO r_regime;
    CLOSE c_regime;

    IF r_regime.regime_code <> jai_constants.vat_regime THEN
      errbuf := 'This program is for VAT Regime Only';
      retcode := jai_constants.request_error;
      RETURN;
    END IF;

   --commented the below for Bug#4950914
    /*IF p_batch_id IS NULL AND p_shipment_header_id IS NULL AND p_shipment_line_id IS NULL THEN
      errbuf := 'Invalid Parameters Passed';
      retcode := jai_constants.request_error;
      RETURN;
    END IF;*/

    lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath);

    process_claim(p_regime_id           => p_regime_id,
                  p_regime_regno        => p_regime_regno,
                  p_organization_id     => p_organization_id,
                  p_location_id         => p_location_id,
                  p_shipment_header_id  => p_shipment_header_id,
                  p_shipment_line_id    => p_shipment_line_id,
                  p_batch_id            => p_batch_id,
                  p_force               => p_force,
                  p_invoice_no          => p_invoice_no,
                  p_invoice_date        => p_invoice_date,
                  p_called_from         => p_called_from,
                  p_process_status      => lv_process_status,
                  p_process_message     => lv_process_message);

    IF lv_process_status <> jai_constants.successful THEN
      retcode := jai_constants.request_error;
      errbuf := lv_process_message;
      RETURN;
    END IF;

    lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);

   --changed/Added the below for Bug#4950914
    process_no_claim(
			p_regime_id           =>	p_regime_id,
			p_regime_regno        =>	p_regime_regno,
			p_organization_id     =>	p_organization_id,
			p_location_id         =>	p_location_id,
			p_shipment_header_id  =>	p_shipment_header_id,
			p_shipment_line_id    =>	p_shipment_line_id,
			p_batch_id            =>	p_batch_id,
                  	p_process_status     	=> lv_process_status,
                   	p_process_message    	=> lv_process_message);


    IF lv_process_status <> jai_constants.successful THEN
      retcode := jai_constants.request_error;
      errbuf := lv_process_message;
      RETURN;
    END IF;

    lv_codepath := jai_general_pkg.plot_codepath(4, lv_codepath);

    IF p_commit_switch = 'Y' THEN
      COMMIT;
    END IF;

    lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'jai_rcv_rgm_claims_pkg.process_batch', 'END');
  END process_batch;

  PROCEDURE do_rtv_accounting(
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE,
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_called_from         IN          VARCHAR2,
                p_invoice_no          IN          JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE,
                p_invoice_date        IN          JAI_RCV_TRANSACTIONS.vat_invoice_date%TYPE,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2)
  IS
    CURSOR c_total_vat_amount(cp_transaction_id IN  rcv_transactions.transaction_id%TYPE)
    IS
    SELECT  b.organization_id,
            b.location_id,
            b.receipt_num,
            a.tax_type,
            (NVL(SUM(a.installment_amount),0) - NVL(SUM(a.claimed_amount),0))*-1 installment_amount
    FROM    jai_rcv_rgm_claims a,
            jai_rcv_rgm_lines b
    WHERE   a.rcv_rgm_line_id = b.rcv_rgm_line_id
    AND     a.transaction_id = cp_transaction_id
    GROUP BY b.organization_id,
             b.location_id,
             b.receipt_num,
             a.tax_type;

    CURSOR  c_min_installment_no(cp_shipment_header_id  IN  rcv_shipment_headers.shipment_header_id%TYPE,
                                 cp_shipment_line_id    IN  rcv_shipment_lines.shipment_line_id%TYPE,
         cp_transaction_type jai_rcv_rgm_claims.transaction_type%type)
    IS
    SELECT  NVL(max(installment_no),0) installment_no --for Bug #4279050, changed from min to max
    FROM    jai_rcv_rgm_claims
    WHERE   shipment_header_id = cp_shipment_header_id
    AND     shipment_line_id = cp_shipment_line_id
    AND     transaction_type =  cp_transaction_type --'RECEIVE' /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    AND     claimed_date IS NOT NULL;

    CURSOR c_total_reversal_amount(cp_shipment_header_id  IN  rcv_shipment_headers.shipment_header_id%TYPE,
                                   cp_shipment_line_id    IN  rcv_shipment_lines.shipment_line_id%TYPE,
                                   cp_transaction_id      IN  rcv_transactions.transaction_id%TYPE,
                                   cp_tax_type            IN  VARCHAR2,
                                   cp_installment_no      IN  NUMBER)
    IS
    SELECT  (NVL(SUM(installment_amount),0) - NVL(SUM(claimed_amount),0))*-1 installment_amount
    FROM    jai_rcv_rgm_claims
    WHERE   shipment_header_id = cp_shipment_header_id
    AND     shipment_line_id = cp_shipment_line_id
    AND     transaction_id  = cp_transaction_id
    AND     installment_no > cp_installment_no
    AND     tax_type = cp_tax_type;

    -- Date 29/05/2007 by sacsethi for bug 6078460
    -- Cursor where clause changed

    CURSOR  c_regime (cp_regime_id   IN  JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL,
                      cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE DEFAULT NULL)
    IS
    SELECT  *
    FROM    JAI_RGM_DEFINITIONS
    WHERE   (regime_id is null OR ( cp_regime_id IS NULL OR regime_id = cp_regime_id  ))  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    AND     (regime_code = cp_regime_code OR  regime_code is null);

    --WHERE   regime_id = NVL(cp_regime_id, regime_id)
    --AND     regime_code = NVL(cp_regime_code, regime_code);

    CURSOR c_claim_schedule(cp_shipment_header_id IN  rcv_shipment_headers.shipment_header_id%TYPE,
                            cp_shipment_line_id   IN  rcv_shipment_lines.shipment_line_id%TYPE,
                            cp_transaction_id     IN  rcv_transactions.transaction_id%TYPE,
                            cp_tax_type           IN  JAI_CMN_TAXES_ALL.tax_type%TYPE)
    IS
    SELECT  MIN(claim_schedule_id) claim_schedule_id
    FROM    jai_rcv_rgm_claims
    WHERE   shipment_header_id = cp_shipment_header_id
    AND     shipment_line_id = cp_shipment_line_id
    AND     tax_type = cp_tax_type
    AND     transaction_id = cp_transaction_id
    AND     NVL(claimed_amount,0) = 0;

    r_total_vat_amount      c_total_vat_amount%ROWTYPE;
    r_min_installment_no    c_min_installment_no%ROWTYPE;
    r_total_reversal_amount c_total_reversal_amount%ROWTYPE;
    r_regime                c_regime%ROWTYPE;
    r_claim_schedule        c_claim_schedule%ROWTYPE;
    r_trx                 c_trx%ROWTYPE;    /* Vijay */

    /* File.Sql.35 by Brathod */
    lv_accounting_type      VARCHAR2(100) ; -- := 'REVERSAL';
    lv_account_nature       VARCHAR2(100) ; -- := 'VAT CLAIM';
    lv_source_name          VARCHAR2(100) ; -- := 'Purchasing India';
    lv_category_name        VARCHAR2(100) ; -- := 'Receiving India';
    ld_accounting_date      DATE          ; -- := TRUNC(SYSDATE);
    lv_reference_23         gl_interface.reference23%TYPE ; -- := 'jai_rgm_claim_pkg.process_vat';
    lv_reference_24         gl_interface.reference24%TYPE ; -- := 'JAI_RCV_TRANSACTIONS';
    lv_reference_25         gl_interface.reference25%TYPE ; -- := p_transaction_id;
    lv_reference_26         gl_interface.reference26%TYPE ; -- := 'transaction_id';
    lv_destination          VARCHAR2(10) ; -- := 'G';
    /* End of File.Sql.35 by Brathod */

    ln_rec_ccid             NUMBER;
    ln_int_ccid             NUMBER;
    ln_entered_dr           NUMBER;
    ln_entered_cr           NUMBER;

    lv_reference_10         gl_interface.reference10%TYPE;
    lv_code_path            VARCHAR2(1996);
    lv_process_status       VARCHAR2(2);
    lv_process_message      VARCHAR2(1000);
    lv_currency_code        VARCHAR2(10);
    ln_repository_id        NUMBER;
    ln_statement_id         NUMBER;
  BEGIN

    /* File.Sql.35 by Brathod */
    lv_accounting_type     := 'REVERSAL';
    lv_account_nature      := 'VAT CLAIM';
    lv_source_name         := 'Purchasing India';
    lv_category_name       := 'Receiving India';
    ld_accounting_date     := TRUNC(SYSDATE);
    lv_reference_23        := 'jai_rgm_claim_pkg.process_vat';
    lv_reference_24        := 'JAI_RCV_TRANSACTIONS';
    lv_reference_25        := p_transaction_id;
    lv_reference_26        := 'transaction_id';
    lv_destination         := 'G';
    /* End of File.Sql.35 by Brathod */

    ln_statement_id := 100;
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    OPEN c_regime(NULL, jai_constants.vat_regime);
    FETCH c_regime INTO r_regime;
    CLOSE c_regime;

    OPEN c_min_installment_no(p_shipment_header_id, p_shipment_line_id, 'RECEIVE');
    FETCH c_min_installment_no INTO r_min_installment_no;
    CLOSE c_min_installment_no;

    /* Vijay */
    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    lv_currency_code := jai_constants.func_curr;

    ln_statement_id := 101;
    FOR rec_taxes IN c_total_vat_amount(p_transaction_id)
    LOOP

      ln_statement_id := 102;
      lv_reference_10 := 'India Local VAT Claim Reversal Entries for Receipt:'||rec_taxes.receipt_num||'. Transaction Type '||p_called_from;

      OPEN c_claim_schedule(p_shipment_header_id, p_shipment_line_id, p_transaction_id,rec_taxes.tax_type);
      FETCH c_claim_schedule INTO r_claim_schedule;
      CLOSE c_claim_schedule;

      ln_statement_id := 102.1;

      OPEN c_total_reversal_amount(p_shipment_header_id, p_shipment_line_id, p_transaction_id, rec_taxes.tax_type, r_min_installment_no.installment_no);
      FETCH c_total_reversal_amount INTO r_total_reversal_amount;
      CLOSE c_total_reversal_amount;

      ln_statement_id := 102.2;
      ln_rec_ccid :=
                    jai_cmn_rgm_recording_pkg.get_account(
                      p_regime_id         => r_regime.regime_id,
                      p_organization_type => jai_constants.orgn_type_io,
                      p_organization_id   => rec_taxes.organization_id,
                      p_location_id       => rec_taxes.location_id,
                      p_tax_type          => rec_taxes.tax_type,
                      p_account_name      => jai_constants.recovery);

      IF ln_rec_ccid IS NULL THEN
        p_process_status := jai_constants.expected_error;
        p_process_message := 'Recovery Account not defined in VAT Setup';
        RETURN;
      END IF;

      ln_statement_id := 102.3;
      ln_int_ccid :=
                    jai_cmn_rgm_recording_pkg.get_account(
                      p_regime_id         => r_regime.regime_id,
                      p_organization_type => jai_constants.orgn_type_io,
                      p_organization_id   => rec_taxes.organization_id,
                      p_location_id       => rec_taxes.location_id,
                      p_tax_type          => rec_taxes.tax_type,
                      p_account_name      => jai_constants.recovery_interim);

      IF ln_int_ccid IS NULL THEN
        p_process_status := jai_constants.expected_error;
        p_process_message := 'Internal Recovery Account not defined in VAT Setup';
        RETURN;
      END IF;

      ln_statement_id := 103;
      --For Unclaimed Amount(for eg if out of 20, 15 is already claimed...then for 5)
      --DR Vat Recovery
      ln_entered_dr := r_total_reversal_amount.installment_amount;
      ln_entered_cr := NULL;

      IF NVL(r_total_reversal_amount.installment_amount,0) <> 0 THEN
        jai_rcv_accounting_pkg.process_transaction(
                          p_transaction_id      => nvl(r_trx.tax_transaction_id, p_transaction_id),    /* p_transaction_id, Vijay */
                          p_acct_type           => lv_accounting_type,
                          p_acct_nature         => lv_account_nature,
                          p_source_name         => lv_source_name,
                          p_category_name       => lv_category_name,
                          p_code_combination_id => ln_rec_ccid,
                          p_entered_dr          => ln_entered_dr,
                          p_entered_cr          => ln_entered_cr,
                          p_currency_code       => lv_currency_code,
                          p_accounting_date     => ld_accounting_date,
                          p_reference_10        => lv_reference_10,
                          p_reference_23        => lv_reference_23,
                          p_reference_24        => lv_reference_24,
                          p_reference_25        => lv_reference_25,
                          p_reference_26        => lv_reference_26,
                          p_destination         => lv_destination,
                          p_simulate_flag       => 'N',
                          p_codepath            => lv_code_path,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_reference_name      => rec_taxes.tax_type||'1',
                          p_reference_id        => NULL);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
        END IF;
      END IF;

      --CR Vat Interim
      ln_entered_dr := NULL;
      ln_entered_cr := r_total_reversal_amount.installment_amount;

      IF NVL(r_total_reversal_amount.installment_amount,0) <> 0 THEN
        jai_rcv_accounting_pkg.process_transaction(
                          p_transaction_id      => nvl(r_trx.tax_transaction_id, p_transaction_id),   /* p_transaction_id, Vijay */
                          p_acct_type           => lv_accounting_type,
                          p_acct_nature         => lv_account_nature,
                          p_source_name         => lv_source_name,
                          p_category_name       => lv_category_name,
                          p_code_combination_id => ln_int_ccid,
                          p_entered_dr          => ln_entered_dr,
                          p_entered_cr          => ln_entered_cr,
                          p_currency_code       => lv_currency_code,
                          p_accounting_date     => ld_accounting_date,
                          p_reference_10        => lv_reference_10,
                          p_reference_23        => lv_reference_23,
                          p_reference_24        => lv_reference_24,
                          p_reference_25        => lv_reference_25,
                          p_reference_26        => lv_reference_26,
                          p_destination         => lv_destination,
                          p_simulate_flag       => 'N',
                          p_codepath            => lv_code_path,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_reference_name      => rec_taxes.tax_type||'1',
                          p_reference_id        => NULL);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
        END IF;
      END IF;

      --For Unclaimed Amount(for eg if out of 20, 15 is already claimed...then for 20)
      --DR Vat Interim
      ln_entered_dr := rec_taxes.installment_amount;
      ln_entered_cr := NULL;

      IF NVL(rec_taxes.installment_amount,0) <> 0 THEN
        jai_rcv_accounting_pkg.process_transaction(
                          p_transaction_id      => p_transaction_id,
                          p_acct_type           => lv_accounting_type,
                          p_acct_nature         => lv_account_nature,
                          p_source_name         => lv_source_name,
                          p_category_name       => lv_category_name,
                          p_code_combination_id => ln_int_ccid,
                          p_entered_dr          => ln_entered_dr,
                          p_entered_cr          => ln_entered_cr,
                          p_currency_code       => lv_currency_code,
                          p_accounting_date     => ld_accounting_date,
                          p_reference_10        => lv_reference_10,
                          p_reference_23        => lv_reference_23,
                          p_reference_24        => lv_reference_24,
                          p_reference_25        => lv_reference_25,
                          p_reference_26        => lv_reference_26,
                          p_destination         => lv_destination,
                          p_simulate_flag       => 'N',
                          p_codepath            => lv_code_path,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_reference_name      => rec_taxes.tax_type||'2',
                          p_reference_id        => NULL);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
        END IF;
      END IF;

      --CR Vat Recovery
      ln_entered_dr := NULL;
      ln_entered_cr := rec_taxes.installment_amount;

      IF NVL(rec_taxes.installment_amount,0) <> 0 THEN
        jai_rcv_accounting_pkg.process_transaction(
                          p_transaction_id      => p_transaction_id,
                          p_acct_type           => lv_accounting_type,
                          p_acct_nature         => lv_account_nature,
                          p_source_name         => lv_source_name,
                          p_category_name       => lv_category_name,
                          p_code_combination_id => ln_rec_ccid,
                          p_entered_dr          => ln_entered_dr,
                          p_entered_cr          => ln_entered_cr,
                          p_currency_code       => lv_currency_code,
                          p_accounting_date     => ld_accounting_date,
                          p_reference_10        => lv_reference_10,
                          p_reference_23        => lv_reference_23,
                          p_reference_24        => lv_reference_24,
                          p_reference_25        => lv_reference_25,
                          p_reference_26        => lv_reference_26,
                          p_destination         => lv_destination,
                          p_simulate_flag       => 'N',
                          p_codepath            => lv_code_path,
                          p_process_message     => lv_process_message,
                          p_process_status      => lv_process_status,
                          p_reference_name      => rec_taxes.tax_type||'2',
                          p_reference_id        => NULL);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
        END IF;
      END IF;

      ln_statement_id := 104;

      ln_entered_dr := rec_taxes.installment_amount;
      ln_entered_cr := NULL;

      IF ln_entered_dr < 0 THEN
        ln_entered_cr := ln_entered_dr*-1;
        /* Vijay ln_entered_cr := NULL; */
        ln_entered_dr := NULL;
      END IF;

      ln_statement_id := 105;
      IF NVL(ln_entered_dr,0) <> 0 OR NVL(ln_entered_cr,0) <> 0 THEN --Added  for Bug#4950914
      jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
                                  pn_repository_id        => ln_repository_id,
                                  pn_regime_id            => r_regime.regime_id,
                                  pv_tax_type             => rec_taxes.tax_type,
                                  pv_organization_type    => jai_constants.orgn_type_io,
                                  pn_organization_id      => rec_taxes.organization_id,
                                  pn_location_id          => rec_taxes.location_id,
                                  pv_source               => jai_constants.source_rcv,
                                  pv_source_trx_type      => 'VAT CLAIM',
                                  pv_source_table_name    => TABLE_RCV_TRANSACTIONS,    /* 'JAI_RCV_RGM_CLAIMS', Vijay */
                                  pn_source_id            => p_transaction_id,    /* r_claim_schedule.claim_schedule_id, Vijay */
                                  pd_transaction_date     => trunc(sysdate),
                                  pv_account_name         => jai_constants.recovery,
                                  pn_charge_account_id    => ln_rec_ccid,
                                  pn_balancing_account_id => ln_int_ccid,
                                  pn_credit_amount        => ln_entered_cr,
                                  pn_debit_amount         => ln_entered_dr,
                                  pn_assessable_value     => NULL,
                                  pn_tax_rate             => NULL,
                                  pn_reference_id         => r_claim_schedule.claim_schedule_id,
                                  pn_batch_id             => NULL,
                                  pn_inv_organization_id  => rec_taxes.organization_id,
                                  pv_invoice_no           => p_invoice_no,
                                  pd_invoice_date         => p_invoice_date,
                                  pv_called_from          => 'JAI_RGM_CLAIM_PKG.DO_RTV_ACCOUNTING',
                                  pv_process_flag         => lv_process_status,
                                  pv_process_message      => lv_process_message,

                                  --Added by Bo Li for bug9305067 2010-4-14 BEGIN
                                  --------------------------------------------------
                                  pv_trx_reference_context       => NULL,
      	                        	pv_trx_reference1         	    => NULL,
      	                        	pv_trx_reference2         	    => NULL,
                                  pv_trx_reference3              => NULL,
                                  pv_trx_reference4              => NULL,
                                  pv_trx_reference5              => NULL
                                  --------------------------------------------------
                                  --Added by Bo Li for bug9305067 2010-4-14 END
                                  );
      ln_statement_id := 106;
      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'lv_process_status'||lv_process_status);
        fnd_file.put_line(fnd_file.log, 'lv_process_message'||lv_process_message);
      END IF;

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        RETURN;
      END IF;

   END IF;

      ln_statement_id := 107;
      ln_entered_dr := NULL;
      ln_entered_cr := r_total_reversal_amount.installment_amount;

      IF ln_entered_cr < 0 THEN
        ln_entered_dr := ln_entered_cr*-1;
        ln_entered_cr := NULL;
      END IF;

      ln_statement_id := 108;
      /* if condition added by Vijay */
      IF NVL(r_total_reversal_amount.installment_amount,0) <> 0 THEN

         jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
                                  pn_repository_id        => ln_repository_id,
                                  pn_regime_id            => r_regime.regime_id,
                                  pv_tax_type             => rec_taxes.tax_type,
                                  pv_organization_type    => jai_constants.orgn_type_io,
                                  pn_organization_id      => rec_taxes.organization_id,
                                  pn_location_id          => rec_taxes.location_id,
                                  pv_source               => jai_constants.source_rcv,
                                  pv_source_trx_type      => 'VAT CLAIM for RTV',
                                  pv_source_table_name    => TABLE_RCV_TRANSACTIONS,    /* 'JAI_RCV_RGM_CLAIMS', Vijay */
                                  pn_source_id            => nvl(r_trx.tax_transaction_id, p_transaction_id),    /* r_claim_schedule.claim_schedule_id, Vijay*/
                                  pd_transaction_date     => TRUNC(SYSDATE),
                                  pv_account_name         => jai_constants.recovery,
                                  pn_charge_account_id    => ln_rec_ccid,
                                  pn_balancing_account_id => ln_int_ccid,
                                  pn_credit_amount        => ln_entered_cr,
                                  pn_debit_amount         => ln_entered_dr,
                                  pn_assessable_value     => NULL,
                                  pn_tax_rate             => NULL,
                                  pn_reference_id         => r_claim_schedule.claim_schedule_id,
                                  pn_batch_id             => NULL,
                                  pn_inv_organization_id  => rec_taxes.organization_id,
                                  pv_invoice_no           => p_invoice_no,
                                  pd_invoice_date         => p_invoice_date,
                                  pv_called_from          => 'JAI_RGM_CLAIM_PKG.DO_RTV_ACCOUNTING',
                                  pv_process_flag         => lv_process_status,
                                  pv_process_message      => lv_process_message,

                                  --Added by Bo Li for bug9305067 2010-4-14 BEGIN
                                  --------------------------------------------------
                                  pv_trx_reference1           => NULL,
                          				pv_trx_reference2           => NULL,
                                  pv_trx_reference3           => NULL,
                                  pv_trx_reference4           => NULL,
                                  pv_trx_reference5           => NULL
                                  -------------------------------------------------
                                  --Added by Bo Li for bug9305067 2010-4-14 END
                                  );

        ln_statement_id := 109;
        IF gv_debug THEN
          fnd_file.put_line(fnd_file.log, 'lv_process_status'||lv_process_status);
          fnd_file.put_line(fnd_file.log, 'lv_process_message'||lv_process_message);
        END IF;

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
        END IF;

      end if;

    END LOOP;

    UPDATE  jai_rcv_rgm_claims
    SET     claimed_amount = installment_amount,
            claimed_date  = TRUNC(SYSDATE),
            status = 'Y'
    WHERE   shipment_header_id = p_shipment_header_id
    AND     shipment_line_id = p_shipment_line_id
    AND     transaction_id = p_transaction_id
    AND     installment_no <= r_min_installment_no.installment_no
    AND     status = 'N';

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := 'Stmt :'||ln_statement_id||' '||SUBSTR(SQLERRM,1,200);
  END do_rtv_accounting;

  PROCEDURE do_rma_accounting(
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2)
  IS

    CURSOR cur_tax(cp_transaction_id            IN  JAI_RCV_LINE_TAXES.transaction_id%TYPE,
                   cp_currency_conversion_rate  IN  JAI_RCV_TRANSACTIONS.currency_conversion_rate%TYPE)
    IS
    SELECT  a.tax_type,/*COL (b.mod_cr_percentage/100) added by Nitin for bug #6681800*/
            SUM(ROUND(DECODE(a.currency, jai_constants.func_curr, a.tax_amount*(b.mod_cr_percentage/100), a.tax_amount*(b.mod_cr_percentage/100)*cp_currency_conversion_rate),NVL(b.rounding_factor,0))) tax_amount
    FROM    JAI_RCV_LINE_TAXES a,
            JAI_CMN_TAXES_ALL b
    WHERE   a.transaction_id = cp_transaction_id
    AND     a.tax_type in (select tax_type
                           from jai_regime_tax_types_v
                           where regime_code = jai_constants.vat_regime)
    AND     NVL(a.modvat_flag,'N') = 'Y'
    AND     a.tax_id = b.tax_id
    GROUP BY a.tax_type;

    -- Date 29/05/2007 by sacsethi for bug 6078460
    -- Cursor where clause changed

    CURSOR  c_regime (cp_regime_id   IN  JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL,
                      cp_regime_code IN  JAI_RGM_DEFINITIONS.regime_code%TYPE DEFAULT NULL)
    IS
    SELECT  *
    FROM    JAI_RGM_DEFINITIONS
    WHERE   (regime_id is null OR ( cp_regime_id IS NULL OR regime_id = cp_regime_id  ))  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    AND     (regime_code = cp_regime_code OR  regime_code is null);

    --WHERE   regime_id = NVL(cp_regime_id, regime_id)
    --AND     regime_code = NVL(cp_regime_code, regime_code);

	-- Added by JMEENA for bug#8302581
	Cursor get_item_id(p_transaction_id NUMBER) IS
	SELECT item_id
	FROM rcv_shipment_lines rsl,
		rcv_transactions rt
	WHERE rsl.shipment_line_id = rt.shipment_line_id
	AND rt.transaction_id = p_transaction_id;

	lv_item_id 				NUMBER;
	lv_vat_recoverable_for_item	JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_VALUE%TYPE;
	lv_account_name			VARCHAR2(100);
	lv_process_flag VARCHAR2(2);
    lv_process_msg  VARCHAR2(1000);
	ln_repository_id	NUMBER;
	-- End for bug#8302581

    r_regime                c_regime%ROWTYPE;
    r_trx                   c_trx%ROWTYPE;
    /* File.Sql.35 by Brathod */
    lv_accounting_type      VARCHAR2(100) ; -- := 'REGULAR';
    lv_account_nature       VARCHAR2(100) ; -- := 'Receiving';
    lv_source_name          VARCHAR2(100) ; -- := 'Purchasing India';
    lv_category_name        VARCHAR2(100) ; -- := 'Receiving India';
    lv_reference_23         gl_interface.reference23%TYPE ; -- := 'jai_rgm_claim_pkg.do_rma_accounting';
    lv_reference_24         gl_interface.reference24%TYPE ; -- := 'rcv_transactions';
    lv_reference_25         gl_interface.reference25%TYPE ; -- := p_transaction_id;
    lv_reference_26         gl_interface.reference26%TYPE ; -- := 'transaction_id';
    lv_destination          VARCHAR2(10) ; -- := 'G';
    /* End of File.Sql.35 by Brathod */
    ln_code_combination_id  NUMBER;
    ln_entered_dr           NUMBER;
    ln_entered_cr           NUMBER;
    lv_currency_code        VARCHAR2(10);
    ld_accounting_date      DATE;
    lv_reference_10         gl_interface.reference10%TYPE;
    lv_code_path            JAI_RCV_TRANSACTIONS.codepath%TYPE;
    lv_process_status       VARCHAR2(2);
    lv_process_message      VARCHAR2(1000);
    ln_apportion_factor     NUMBER;
    ln_tax_amount           NUMBER;
    LN_DEBIT_CCID           NUMBER;
    LN_CREDIT_CCID          NUMBER;

  BEGIN

    /* File.Sql.35 by Brathod */
    lv_accounting_type      := 'REGULAR';
    lv_account_nature       := 'Receiving';
    lv_source_name          := 'Purchasing India';
    lv_category_name        := 'Receiving India';
    lv_reference_23         := 'jai_rgm_claim_pkg.do_rma_accounting';
    lv_reference_24         := 'rcv_transactions';
    lv_reference_25         := p_transaction_id;
    lv_reference_26         := 'transaction_id';
    lv_destination          := 'G';
    /* End of File.Sql.35 by Brathod */

    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    OPEN c_trx(p_transaction_id);
    FETCH c_trx INTO r_trx;
    CLOSE c_trx;

    OPEN c_regime(NULL, jai_constants.vat_regime);
    FETCH c_regime INTO r_regime;
    CLOSE c_regime;

    ld_accounting_date  := trunc(r_trx.transaction_date);
    lv_currency_code := jai_constants.func_curr;
    lv_reference_10 := 'India Local VAT RMA Entries for Receipt:'||r_trx.receipt_num
                        ||'. Transaction Type '||r_trx.transaction_type;

    if r_trx.transaction_type = 'CORRECT' then
      lv_reference_10 := lv_reference_10 || ' of type ' || r_trx.parent_transaction_type;
    end if;

    ln_apportion_factor := jai_rcv_trx_processing_pkg.get_apportion_factor(p_transaction_id);

    lv_code_path := '';

    FOR rec_tax IN cur_tax(r_trx.tax_transaction_id, r_trx.currency_conversion_rate)
    LOOP

          --Added by for Bug#4950914
      IF NVL(rec_tax.tax_amount,0) = 0 THEN
      	goto END_OF_LOOP;
      END IF;

      ln_tax_amount := rec_tax.tax_amount*ln_apportion_factor;

      IF gv_debug THEN
        fnd_file.put_line(fnd_file.log, 'rec_tax.tax_amount:'||rec_tax.tax_amount);
        fnd_file.put_line(fnd_file.log, 'ln_tax_amount:'||ln_tax_amount);
      END IF;

	-- Added by JMEENA for bug#8302581
	OPEN get_item_id(p_transaction_id);
	FETCH get_item_id INTO lv_item_id;
	CLOSE get_item_id;

	jai_inv_items_pkg.jai_get_attrib(
                          p_regime_code       => jai_constants.vat_regime,
                          p_organization_id   => r_trx.organization_id,
                          p_inventory_item_id => lv_item_id,
                          p_attribute_code    => jai_constants.rgm_attr_item_recoverable,
                          p_attribute_value   => lv_vat_recoverable_for_item,
                          p_process_flag      => lv_process_flag,
                          p_process_msg       => lv_process_msg
                          );
        IF lv_process_flag <> jai_constants.successful THEN
          p_process_status := lv_process_flag;
          p_process_message := 'Error Message:'||lv_process_msg;
          RETURN;
        END IF;

	IF lv_vat_recoverable_for_item <> jai_constants.yes THEN
	    lv_account_name:= 	jai_constants.Liability;
	ELSE
		lv_account_name:=	jai_constants.recovery_interim;
	END IF;
	-- End bug#8302581
	fnd_file.put_line(fnd_file.log, 'lv_account_name:'||lv_account_name||'jai_constants.recovery_interim:'|| jai_constants.recovery_interim);
      ln_debit_ccid :=
                                jai_cmn_rgm_recording_pkg.get_account(
                                  p_regime_id         => r_regime.regime_id,
                                  p_organization_type => jai_constants.orgn_type_io,
                                  p_organization_id   => r_trx.organization_id,
                                  p_location_id       => r_trx.location_id,
                                  p_tax_type          => rec_tax.tax_type,
                                  p_account_name      => lv_account_name);

      IF ln_debit_ccid IS NULL THEN
        p_process_status := jai_constants.expected_error;
        p_process_message := 'Interim recovery Account not defined in VAT Setup';
        RETURN;
      END IF;

      --dr VAT Interim
      ln_entered_dr := ln_tax_amount;
      ln_entered_cr := NULL;

 --Added  for Bug#4950914
      IF NVL(ln_tax_amount,0) <> 0 THEN
      jai_rcv_accounting_pkg.process_transaction(
                        p_transaction_id      => r_trx.transaction_id,
                        p_acct_type           => lv_accounting_type,
                        p_acct_nature         => lv_account_nature,
                        p_source_name         => lv_source_name,
                        p_category_name       => lv_category_name,
                        p_code_combination_id => ln_debit_ccid,
                        p_entered_dr          => ln_entered_dr,
                        p_entered_cr          => ln_entered_cr,
                        p_currency_code       => lv_currency_code,
                        p_accounting_date     => ld_accounting_date,
                        p_reference_10        => lv_reference_10,
                        p_reference_23        => lv_reference_23,
                        p_reference_24        => lv_reference_24,
                        p_reference_25        => lv_reference_25,
                        p_reference_26        => lv_reference_26,
                        p_destination         => lv_destination,
                        p_simulate_flag       => 'N',
                        p_codepath            => lv_code_path,
                        p_process_message     => lv_process_message,
                        p_process_status      => lv_process_status,
                        p_reference_name      => rec_tax.tax_type,
                        p_reference_id        => NULL);

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        RETURN;
      END IF;
END IF;
      --CR Interim Liability
      ln_credit_ccid :=
                                jai_cmn_rgm_recording_pkg.get_account(
                                  p_regime_id         => r_regime.regime_id,
                                  p_organization_type => jai_constants.orgn_type_io,
                                  p_organization_id   => r_trx.organization_id,
                                  p_location_id       => r_trx.location_id,
                                  p_tax_type          => rec_tax.tax_type,
                                  p_account_name      => jai_constants.liability_interim);

      IF ln_credit_ccid IS NULL THEN
        p_process_status := jai_constants.expected_error;
        p_process_message := 'Interim Liability Account not defined in VAT Setup';
        RETURN;
      END IF;

      ln_entered_dr := NULL;
      ln_entered_cr := ln_tax_amount;

--Added  for Bug#4950914
      IF NVL(ln_tax_amount,0) <> 0 THEN
      jai_rcv_accounting_pkg.process_transaction(
                        p_transaction_id      => r_trx.transaction_id,
                        p_acct_type           => lv_accounting_type,
                        p_acct_nature         => lv_account_nature,
                        p_source_name         => lv_source_name,
                        p_category_name       => lv_category_name,
                        p_code_combination_id => ln_credit_ccid,
                        p_entered_dr          => ln_entered_dr,
                        p_entered_cr          => ln_entered_cr,
                        p_currency_code       => lv_currency_code,
                        p_accounting_date     => ld_accounting_date,
                        p_reference_10        => lv_reference_10,
                        p_reference_23        => lv_reference_23,
                        p_reference_24        => lv_reference_24,
                        p_reference_25        => lv_reference_25,
                        p_reference_26        => lv_reference_26,
                        p_destination         => lv_destination,
                        p_simulate_flag       => 'N',
                        p_codepath            => lv_code_path,
                        p_process_message     => lv_process_message,
                        p_process_status      => lv_process_status,
                        p_reference_name      => rec_tax.tax_type,
                        p_reference_id        => NULL);

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        RETURN;
      END IF;
END IF;

--Added below code by JMEENA for bug#8302581
IF lv_vat_recoverable_for_item <> jai_constants.yes THEN
IF ln_entered_cr < 0 THEN
ln_entered_cr:= NULL ;
ln_entered_dr:= ln_entered_cr*-1;
END IF;

jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
											pn_repository_id        => ln_repository_id,
											pn_regime_id            => r_regime.regime_id,
											pv_tax_type             => rec_tax.tax_type,
											pv_organization_type    => jai_constants.orgn_type_io,
											pn_organization_id      => r_trx.organization_id,
											pn_location_id          => r_trx.location_id,
											pv_source               => jai_constants.source_rcv,
											pv_source_trx_type      => upper(lv_account_nature),
											pv_source_table_name    => upper(lv_reference_24),
											pn_source_id            => r_trx.transaction_id ,
											pd_transaction_date     => trunc(sysdate),
											pv_account_name         => jai_constants.Liability,
											pn_charge_account_id    => ln_debit_ccid,
											pn_balancing_account_id => ln_credit_ccid,
											pn_credit_amount        => ln_entered_cr,
											pn_debit_amount         => ln_entered_dr,
											pn_assessable_value     => NULL,
											pn_tax_rate             => NULL,
											pn_reference_id         => NULL,
											pn_batch_id             => NULL,
											pn_inv_organization_id  => r_trx.organization_id,
											pv_invoice_no           => r_trx.vat_invoice_no,
											pd_invoice_date         => r_trx.vat_invoice_date,
											pv_called_from          => 'JAINPORE',
											pv_process_flag         => lv_process_status,
											pv_process_message      => lv_process_message,
											--Added by Bo Li for bug9305067 2010-4-14 BEGIN
											-----------------------------------------------
											pv_trx_reference_context    => 'RMA',
                      pv_trx_reference1           => NULL,
                      pv_trx_reference2           => NULL,
                      pv_trx_reference3           => NULL,
                      pv_trx_reference4           => NULL,
                      pv_trx_reference5           => NULL
                      ----------------------------------------------
                      --Added by Bo Li for bug9305067 2010-4-14 END
                      );

				IF lv_process_status <> jai_constants.successful THEN
					p_process_status := lv_process_status;
					p_process_message := lv_process_message;
					RETURN;
				END IF;
END IF;
--End bug#8302581
        <<END_OF_LOOP>>

        NULL;

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,200);
  END do_rma_accounting;

END jai_rcv_rgm_claims_pkg;

/
