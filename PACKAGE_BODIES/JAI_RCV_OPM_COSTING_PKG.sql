--------------------------------------------------------
--  DDL for Package Body JAI_RCV_OPM_COSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_OPM_COSTING_PKG" AS
/* $Header: jai_rcv_opm_cst.plb 120.5.12010000.6 2009/10/14 05:45:50 srjayara noship $ */
  PROCEDURE opm_cost_adjust( errbuf             OUT NOCOPY VARCHAR2,
                             retcode            OUT NOCOPY NUMBER,
                             p_organization_id  IN NUMBER     ,
                             p_start_date       IN VARCHAR2   ,
                             p_end_date         IN VARCHAR2   )
  IS
 /*------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY
  ------------------------------------------------------------------------------------------------------------
  Sl.No.          Date          	Developer   	BugNo           Remarks
  ------------------------------------------------------------------------------------------------------------
  1.              21-JUL-2008 	JMEENA     	7268999        Added the code to convert the ln_costing_amount to base currency before updating the tables.

  2.			  23-MAR-2009	VUMAASHA	7655123		   In mtl_material_transactions the cost is always recorded in functional currency.
  														   The Variable ln_costing_amt_func_curr is added for store the costing
														   amount in functional currency.
  3.              26-May-2009     Bug 8505362   File version 120.0.12000000.10 / 120.5.12010000.4 / 120.8
                                  Issue - Costing update for non-recoverable taxes is wrong when transaction UOM is
				  different from primary UOM.
				  Cause - In MMT table, the cost is to be updated in terms of rate / quantity in primary UOM. But
				  the code updates it with rate / quantity in transaction UOM.
				  Fix - When calculating the amount to update the MMT table, used rcv_transactions.primary_quantity
				  instead of jai_rcv_transactions.quantity.

  4.              01-OCT-2009    Bug 8966461 File version 120.0.12000000.11 / 120.5.12010000.5 / 120.9
                                 Issue - Costing update is wrong for CORRECT transactions with negative
				         quantity.
			         Fix - Divided the costing amount variables by quantity instead of
				       ABS(quantity). As the quantity is negative, costing amount should
				       be positive for the accouting to be correct. For negative quantity,
				       apportion factor will also be negative, and needs to be divided by
				       value with same sign.

  5.              14-Oct-2009    Bug 8894858 File version 120.0.12000000.12 / 120.5.12010000.6 / 120.10
                                 Issue - Costing update is wrong when the uom for RECEIVE transaction is
                                         is different from the source document (PO) uom.
                                 Fix - Used rcv_transactions.source_doc_quantity instead of rcv_transactions.quantity
                                       to calculate the costing amount to be added to po_unit_price.
                                       Also incorporated the changes for bug 8830292 - the program has to pick
                                       the transactions based on the transaction date, not the date of receipt.
  ------------------------------------------------------------------------------------------------------------*/
  ld_start_date  DATE;
  ld_end_date    DATE;

  lv_deliver_trx  CONSTANT VARCHAR2(30) := 'DELIVER';
  lv_correct_trx  CONSTANT VARCHAR2(30) := 'CORRECT';
  lv_rtr_trx      CONSTANT VARCHAR2(30) := 'RETURN TO RECEIVING';

  CURSOR cur_receipt_records(cp_start_date DATE, cp_end_date DATE)
  IS
  SELECT *
    FROM rcv_shipment_lines rsl
   WHERE ( p_organization_id IS NULL OR to_organization_id = p_organization_id )
     /*even though to_organization_id is NULL ALLOWED, it is always populated*/
     --AND trunc(creation_date) between cp_start_date AND cp_end_date /*bug 8830292*/
     AND to_organization_id IN ( SELECT jcio.organization_id
                                   FROM jai_cmn_inventory_orgs jcio,
                                        mtl_parameters mtl
                                  WHERE mtl.organization_id = jcio.organization_id
                                    AND mtl.process_enabled_flag = 'Y'
                               )
     AND EXISTS ( SELECT 1
		                FROM jai_rcv_transactions
		               WHERE shipment_header_id = rsl.shipment_header_id
		                 AND shipment_line_id = rsl.shipment_line_id
		                 AND transaction_type = lv_deliver_trx
				 AND trunc(transaction_date) between cp_start_date and cp_end_date  /*bug 8830292*/
                 );

   /*cursor modified for bug 8505362, to include the quanity in primary UOM*/
  CURSOR cur_rcv_costing_records(cp_shipment_line_id IN NUMBER )
  IS
  SELECT rt.transaction_id, rt.quantity, rt.primary_quantity, jrt.currency_conversion_rate, jrt.transaction_type, rt.source_doc_quantity  /*bug 8894858*/
    FROM rcv_transactions rt, jai_rcv_transactions jrt
   WHERE rt.transaction_id = jrt.transaction_id
     AND jrt.shipment_line_id          = cp_shipment_line_id
     AND ( (jrt.transaction_type IN (lv_deliver_trx,lv_rtr_trx))
           OR (jrt.transaction_type = lv_correct_trx AND
           jrt.parent_transaction_type IN (lv_rtr_trx,lv_deliver_trx)) )
     AND nvl(jrt.opm_costing_flag,'N') = 'N';

  CURSOR cur_receipt_num(cp_shipment_line_id NUMBER)
  IS
  SELECT receipt_num
    FROM jai_rcv_lines
   WHERE shipment_line_id = cp_shipment_line_id;

  CURSOR cur_orgn_name(cp_orgn_id NUMBER)
  IS
  SELECT name
    FROM hr_all_organization_units
   WHERE organization_id = cp_orgn_id;

  CURSOR cur_sob_currency(cp_cob_id NUMBER)
  IS
  SELECT currency_code
    FROM gl_sets_of_books
   WHERE set_of_books_id = cp_cob_id ;

   ln_modvat_amount             NUMBER;
   ln_non_modvat_amount         NUMBER;
   ln_other_modvat_amount       NUMBER;
   lv_process_message           VARCHAR2(4000);
   lv_process_status            VARCHAR2(100);
   lv_codepath                  VARCHAR2(4000);
   ln_costing_amount            NUMBER;
   ln_costing_amt_func_curr		NUMBER; /* Added for the bug 7655123 */
   lv_include_cenvat_in_costing VARCHAR2(1);
   ln_apportion_factor          NUMBER;
   lv_receipt_num               VARCHAR2(30);
   lv_orgn_name                 VARCHAR2(240);
   ln_receipt_count             NUMBER;
   lv_receipt_processed         VARCHAR2(1);
   ln_sob_id                    NUMBER;
   lv_sob_currency              VARCHAR2(15);
  BEGIN
    retcode := 0;
    ln_sob_id := fnd_profile.value('GL_SET_OF_BKS_ID');

    OPEN cur_sob_currency(ln_sob_id);
    FETCH cur_sob_currency INTO lv_sob_currency;
    CLOSE cur_sob_currency;

    IF (AD_EVENT_REGISTRY_PKG.Is_Event_Done( p_Owner => 'JA',
		                                         p_Event_Name => 'JAI_EXISTENCE_OF_TABLES' ) = FALSE )
		   OR lv_sob_currency <> 'INR' THEN

		   fnd_file.put_line(fnd_file.output,'This report is for Financials for India Customers only' );
		   return;

		END IF;


    ld_start_date := fnd_date.canonical_to_date(p_start_date);
    ld_end_date   := fnd_date.canonical_to_date(p_end_date);

    IF p_organization_id IS NOT NULL THEN

      OPEN cur_orgn_name(p_organization_id);
			FETCH cur_orgn_name INTO lv_orgn_name;
      CLOSE cur_orgn_name;

    END IF;

    fnd_file.put_line(fnd_file.output,'Concurrent Program Name: India - Program to Update OPM Cost' );
    fnd_file.new_line(fnd_file.output,1);
    fnd_file.put_line(fnd_file.output,'Parameters :' );
    fnd_file.new_line(fnd_file.output,1);
    fnd_file.put_line(fnd_file.output,'        Organization Name  :'||lv_orgn_name );
    fnd_file.put_line(fnd_file.output,'        Receipt Start Date :'||ld_start_date );
    fnd_file.put_line(fnd_file.output,'        Receipt End Date   :'||ld_end_date );

    ln_receipt_count := 0;

    fnd_file.new_line(fnd_file.output,6);

    fnd_file.put_line(fnd_file.output,'**********************************OPM Cost Update Begins**********************************' );

    FOR receipt_rec IN cur_receipt_records(ld_start_date,ld_end_date) LOOP

       fnd_file.new_line(fnd_file.output,2);

       OPEN cur_receipt_num(receipt_rec.shipment_line_id);
       FETCH cur_receipt_num INTO lv_receipt_num;
       CLOSE cur_receipt_num;

       IF p_organization_id IS NULL THEN

         OPEN cur_orgn_name(receipt_rec.to_organization_id);
         FETCH cur_orgn_name INTO lv_orgn_name;
         CLOSE cur_orgn_name;

       END IF;

       lv_receipt_processed := 'N';

       fnd_file.new_line(fnd_file.output,2);
       fnd_file.put_line(fnd_file.output,'Receipt Number                 :' ||lv_receipt_num );
       fnd_file.put_line(fnd_file.output,'Organization Name              :' ||lv_orgn_name );


      FOR rcv_costing_records IN cur_rcv_costing_records(receipt_rec.shipment_line_id) LOOP

        jai_rcv_deliver_rtr_pkg.get_tax_amount_breakup
        (
            p_shipment_line_id             =>    receipt_rec.shipment_line_id,
            p_transaction_id               =>    rcv_costing_records.transaction_id,
            p_curr_conv_rate               =>    rcv_costing_records.currency_conversion_rate,
            p_excise_amount                =>    ln_modvat_amount,
            p_non_modvat_amount            =>    ln_non_modvat_amount  ,
            p_other_modvat_amount          =>    ln_other_modvat_amount ,
            p_process_message              =>    lv_process_message,
            p_process_status               =>    lv_process_status,
            p_codepath                     =>    lv_codepath
        );

        if lv_process_status in ('E', 'X')  THEN
          raise_application_error(-20120,'Error while fetching the costing amount :'||lv_process_message);
        end if;

        lv_include_cenvat_in_costing := jai_rcv_deliver_rtr_pkg.include_cenvat_in_costing
                                          (
                                            p_transaction_id    => rcv_costing_records.transaction_id,
                                            p_process_message   => lv_process_message,
                                            p_process_status    => lv_process_status,
                                            p_codepath          => lv_codepath
                                          );

        if lv_process_status in ('E', 'X')  THEN
          raise_application_error(-20120,'Error while fetching include cenvat in costing flag:'||lv_process_message);
        end if;

        if lv_include_cenvat_in_costing ='Y' then
          ln_costing_amount := nvl(ln_non_modvat_amount,0) + nvl(ln_modvat_amount,0);
        else
          ln_costing_amount := nvl(ln_non_modvat_amount,0);
        end if;
        ln_apportion_factor := jai_rcv_trx_processing_pkg.get_apportion_factor
                                                   ( p_transaction_id => rcv_costing_records.transaction_id);



		/* added by VUMAASHA for bug 7655123 */
		ln_costing_amt_func_curr := ln_costing_amount;
                /*bug 8505362 - costing amount for func. currency should be calculated per unit in the primary UOM*/
		/*ABS removed for bug 8966461*/
		ln_costing_amt_func_curr := round((ln_costing_amt_func_curr * ln_apportion_factor)/rcv_costing_records.primary_quantity,5);
		/* end for bug 7655123 */

		--Added by JMEENA for bug#7268999
		fnd_file.put_line(fnd_file.output,'ln_costing_amount before conversion:'||ln_costing_amount );
		ln_costing_amount:= ln_costing_amount/NVL(rcv_costing_records.currency_conversion_rate,1);
		fnd_file.put_line(fnd_file.output,'ln_costing_amount After conversion:'||ln_costing_amount );
		--End of bug#7268999

	/*bug 8966461 - negative quantities will lead to apportion factor becoming negative.
	 * Therefore, if we divide by ABS(quantity) then costing amount will be negative.
	 * Since actual accounting will be passed using quantity*cost, the costing
	 * amount should be positive, as long as the tax amount is positive.*/
        ln_costing_amount := round((ln_costing_amount * ln_apportion_factor)/rcv_costing_records.source_doc_quantity,5); /*bug 8894858*/

        IF ln_costing_amount IS NOT NULL THEN

					UPDATE rcv_transactions
						 SET po_unit_price = po_unit_price + ln_costing_amount
					 WHERE transaction_id = rcv_costing_records.transaction_id;

					UPDATE mtl_material_transactions
						 SET transaction_cost = transaction_cost + ln_costing_amt_func_curr /* Modified for bug 7655123 */
					 WHERE rcv_transaction_id = rcv_costing_records.transaction_id;

					UPDATE jai_rcv_transactions
						 SET opm_costing_flag   = 'Y',
								 opm_costing_amount = ln_costing_amount
					 WHERE transaction_id     = rcv_costing_records.transaction_id;

				 END IF;

        lv_receipt_processed := 'Y';
        fnd_file.new_line(fnd_file.output,1);
        fnd_file.put_line(fnd_file.output,'Transaction Type              :' ||rcv_costing_records.transaction_type );
        fnd_file.put_line(fnd_file.output,'Transaction Quantity          :' ||rcv_costing_records.quantity );
        fnd_file.put_line(fnd_file.output,'Non recoverable taxes per unit:' ||ln_costing_amount );
        fnd_file.put_line(fnd_file.output,'Cost Update Successful' );
      END LOOP;

      IF lv_receipt_processed = 'N' THEN

        fnd_file.new_line(fnd_file.output,1);
        fnd_file.put_line(fnd_file.output,'The Receipt was already Cost updated');

      END IF;

      ln_receipt_count := ln_receipt_count + 1;

    END LOOP;
    fnd_file.new_line(fnd_file.output,2);
    fnd_file.put_line(fnd_file.output,'Total number of receipts processed :' ||ln_receipt_count);
    fnd_file.new_line(fnd_file.output,2);

    fnd_file.put_line(fnd_file.output,'**********************************OPM Cost Update Ends**********************************' );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := SUBSTR(SQLERRM,1,200);
      fnd_file.put_line(fnd_file.log,'Error while processing receipt :'||lv_receipt_num);
      ROLLBACK;
  END opm_cost_adjust;

END jai_rcv_opm_costing_pkg;

/
