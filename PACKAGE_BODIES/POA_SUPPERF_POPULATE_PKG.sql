--------------------------------------------------------
--  DDL for Package Body POA_SUPPERF_POPULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SUPPERF_POPULATE_PKG" AS
/* $Header: POASPPPB.pls 115.11 2004/03/04 13:14:31 sriswami ship $ */

   /* populate_fact_table
    * -------------------
    * Main procedure to extract neccessary facts from po base tables and
    * insert into poa_bis_supplier_performance.  The data is only extracted if
    * the last_update_date of po_line_locations_all is between the date
    * parameters.
    * Delete the corresponding record in the fact table before inserting
    * the updated one.
    */
   PROCEDURE populate_fact_table(p_start_date IN DATE, p_end_date IN DATE)
   IS

      CURSOR C_EXTRACT IS
         SELECT pll.ship_to_location_id,
                pll.ship_to_organization_id,
                poh.org_id,
                pol.item_id,
                pol.category_id,
                poh.vendor_id,
                poh.vendor_site_id,
                poh.agent_id,
                pll.line_location_id,
                pll.quantity,
                pll.quantity_cancelled,
                pll.quantity_billed,
                pll.quantity_rejected,
                pll.price_override,
                pll.creation_date,
                pll.cancel_flag,
                pll.closed_code,
                pll.days_early_receipt_allowed,
                pll.days_late_receipt_allowed,
                NVL(pll.promised_date, pll.need_by_date) 	expected_date,
                gls.currency_code,
                nvl(poh.rate_type, 'Corporate') 		rate_type,
                nvl(poh.rate_date, pll.creation_date) 		rate_date,
                poh.rate,
                pol.unit_meas_lookup_code,			/* FPI */
		por.consigned_consumption_flag por_consigned_consumption_flag,
/* FPI */	poh.consigned_consumption_flag poh_consigned_consumption_flag,
		pll.consigned_flag,		/* FPI */
                poh.shipping_control            /* FPJ */
         FROM   po_line_locations_all        pll,
                po_lines_all                 pol,
                po_headers_all               poh,
                financials_system_params_all fsp,
                gl_sets_of_books             gls,
		po_releases_all		     por  /* FPI */
         WHERE  pll.po_line_id          = pol.po_line_id
         AND    pll.po_header_id        = poh.po_header_id
         AND    NVL(poh.org_id, -999)   = NVL(fsp.org_id, -999)
         AND    gls.set_of_books_id     = fsp.set_of_books_id
         AND    pll.shipment_type       IN ('STANDARD', 'BLANKET', 'SCHEDULED')
         AND    pol.matching_basis = 'QUANTITY'
         AND    NVL(pll.approved_flag, 'N') = 'Y'
         AND    pol.item_id             IS NOT NULL
	 AND 	pll.po_release_id = por.po_release_id(+)   /* FPI */
	 AND    poa_supperf_api_pkg.get_last_trx_date(pll.line_location_id)
					BETWEEN p_start_date AND p_end_date;

      v_c_info                  C_EXTRACT%ROWTYPE;
      v_quantity_rejected       NUMBER;
      v_primary_uom             VARCHAR2(25);
      v_uom_rate                NUMBER;
      v_quantity_purchased      NUMBER;
      v_total_amount            NUMBER;
      v_receipt_date            DATE;
      v_avg_price               NUMBER;
      v_num_receipts            NUMBER;
      v_quantity_received       NUMBER;
      v_quantity_received_late  NUMBER;
      v_quantity_received_early NUMBER;
      v_quantity_past_due       NUMBER;
      v_date_dimension          DATE;
      v_purchase_price		NUMBER; /* FPI */
      v_quantity_ordered	NUMBER; /* FPI */
      v_shipment_expected_date  DATE;  /*  FPI */
      x_progress                VARCHAR2(10);

   BEGIN

      POA_LOG.debug_line('populate_fact_table:  entered');
      POA_LOG.debug_line(' ');

      OPEN C_EXTRACT;
      LOOP
       BEGIN
         x_progress := '001';
         FETCH C_EXTRACT INTO v_c_info;
         EXIT WHEN C_EXTRACT%NOTFOUND;

         x_progress := '002';

      v_date_dimension := NVL(v_c_info.expected_date,
				 v_c_info.creation_date);


        v_primary_uom := poa_supperf_api_pkg.get_primary_uom(
                                             v_c_info.item_id,
                                             v_c_info.org_id
                                          );

    	 x_progress := '003';
         v_uom_rate := inv_convert.inv_um_convert(
                                             v_c_info.item_id,
                                             5,
                                             1, NULL, NULL,
                                             v_c_info.unit_meas_lookup_code,
                                             v_primary_uom
                                          );


	x_progress := '004';
         v_avg_price := poa_supperf_api_pkg.get_avg_price(
                                             v_c_info.line_location_id,
                                             v_c_info.price_override
                                          );
	x_progress := '005';

	if (v_c_info.poh_consigned_consumption_flag='Y'/* FPI */
		     OR v_c_info.por_consigned_consumption_flag='Y')
	then
		x_progress := '006';
		v_receipt_date :=null;
 		v_quantity_received :=null;
  		v_quantity_rejected :=null ;
		v_num_receipts := null;
		v_quantity_past_due := null;
		v_shipment_expected_date := null;
		x_progress := '007';
	else
		x_progress := '008';
		v_receipt_date :=
			poa_supperf_api_pkg.get_receipt_date(
                                             v_c_info.line_location_id
                                          );

		x_progress := '009';
		v_quantity_received :=
 				poa_supperf_api_pkg.get_rcv_txn_qty(
					    v_c_info.line_location_id,
                                            'RECEIVE'
                                          );

		x_progress := '010';
		v_quantity_rejected :=
			poa_supperf_api_pkg.get_rcv_txn_qty(
					    v_c_info.line_location_id,
                                            'REJECT'
                                          );
 		-- should watch out for null receipts
		v_num_receipts := poa_supperf_api_pkg.get_num_receipts(
                                             v_c_info.line_location_id
                                          );

		x_progress := '011';
                if (v_c_info.shipping_control='BUYER') then
                 v_quantity_past_due := 0;
                else
	  	 v_quantity_past_due :=
			poa_supperf_api_pkg.get_quantity_past_due(
                                            (v_c_info.quantity -
					     v_c_info.quantity_cancelled) *
					    v_uom_rate,
                                            v_quantity_received,
                                            v_c_info.expected_date,
                                            v_c_info.days_late_receipt_allowed
                                          );
                end if;

		v_shipment_expected_date := v_c_info.expected_date;
	end if;

	if (v_c_info.consigned_flag = 'Y') then
                x_progress := '012';

		v_purchase_price := null;
		v_quantity_ordered := null;
		v_quantity_purchased := null;
		v_total_amount := null;

		 x_progress := '013';
	else
		x_progress := '014';
	    	v_purchase_price := v_avg_price / v_uom_rate;
		v_quantity_ordered := v_c_info.quantity * v_uom_rate;

 		x_progress := '015';
		v_quantity_purchased :=
			   poa_supperf_api_pkg.get_quantity_purchased(
                                      v_c_info.quantity * v_uom_rate,
                                      v_c_info.quantity_billed * v_uom_rate,
                                      v_c_info.quantity_cancelled * v_uom_rate,
                                      nvl(v_quantity_received,
					poa_supperf_api_pkg.get_rcv_txn_qty(
					    v_c_info.line_location_id,
                                            'RECEIVE'
                                          )),
                                      v_c_info.cancel_flag,
                                      v_c_info.closed_code
                                    );

		x_progress := '016';
		v_total_amount :=
 			         poa_supperf_api_pkg.get_total_amount(
                                             v_c_info.line_location_id,
                                             v_c_info.cancel_flag,
                                             v_c_info.closed_code,
                                             v_c_info.price_override
                                          );
	end if;

	x_progress := '017';



         --
         -- Calculate quantity received early, late and past-due.
         -- If there's no receipt yet, set the quantity early, late,
	 -- to null and handle those in the reports.
	 --
         IF v_num_receipts = 0
	THEN
            v_quantity_received_late 	:= NULL;
            v_quantity_received_early 	:= NULL;
        ELSE
  		x_progress := '018';

		if (v_c_info.poh_consigned_consumption_flag='Y'/* FPI */
		     OR v_c_info.por_consigned_consumption_flag='Y')
		then
			v_quantity_received_late := null;
			v_quantity_received_early :=null;
                elsif (v_c_info.shipping_control = 'BUYER' ) then
                        v_quantity_received_late := 0;
                        v_quantity_received_early := 0;
		else
  			x_progress := '019';
			v_quantity_received_late :=
			poa_supperf_api_pkg.get_quantity_late(
					    v_c_info.line_location_id,
                                            v_c_info.expected_date,
                                            v_c_info.days_late_receipt_allowed
                                          );
  			x_progress := '020';
 			v_quantity_received_early :=
			poa_supperf_api_pkg.get_quantity_early(
                                            v_c_info.line_location_id,
                                            v_c_info.expected_date,
                                            v_c_info.days_early_receipt_allowed
                                          );
		end if;

         END IF;

         x_progress := '021';

	 --
         -- Delete coresponding row in the fact table if it exists,
	 -- then insert row.
         --
         x_progress := '022';
         delete_row(v_c_info.line_location_id);

         x_progress := '023';
         insert_row(v_c_info.line_location_id,
                    v_c_info.ship_to_location_id,
                    v_c_info.ship_to_organization_id,
                    v_c_info.org_id,
                    v_c_info.item_id,
                    v_c_info.category_id,
                    v_c_info.vendor_id,
                    v_c_info.vendor_site_id,
                    v_c_info.agent_id,
                    v_date_dimension,
                    v_quantity_purchased,
/* FPI */	    v_purchase_price,
                    v_primary_uom,
                    v_c_info.currency_code,
                    v_c_info.rate_type,
                    v_c_info.rate_date,
                    v_c_info.rate,
/* FPI */	    v_quantity_ordered,
                    v_quantity_received,
                    v_quantity_rejected,
                    v_total_amount,
                    v_num_receipts,
                    v_quantity_received_late,
                    v_quantity_received_early,
                    v_quantity_past_due,
                    v_receipt_date,
/* FPI */	    v_shipment_expected_date,
                    trunc(v_date_dimension, 'MONTH'),
                    trunc(v_date_dimension, 'Q'),
                    trunc(v_date_dimension, 'YYYY'),
                    fnd_global.user_id,
                    sysdate,
                    sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    fnd_global.conc_request_id,
                    fnd_global.prog_appl_id,
                    fnd_global.conc_program_id,
                    sysdate
                   );
        EXCEPTION
           WHEN OTHERS THEN
              POA_LOG.put_line('populate_fact_table:  ' || x_progress
                               || ' ' || sqlerrm);
              POA_LOG.put_line(' ');

              POA_LOG.debug_line('populate_fact_table: line_location_id - ' ||
                                 to_char(v_c_info.line_location_id));
              POA_LOG.debug_line(' ');
        END;
      END LOOP;

      CLOSE C_EXTRACT;

   EXCEPTION
      WHEN OTHERS THEN
   	 POA_LOG.put_line('populate_fact_table:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');

   	 POA_LOG.debug_line('populate_fact_table: line_location_id - ' ||
                            to_char(v_c_info.line_location_id));
      	 POA_LOG.debug_line(' ');

         RAISE;

   END populate_fact_table;





   /* delete_row
    * ----------
    * This procedure deletes a record from poa_bis_supplier_performace fact
    * table for the given shipment.
    */
   PROCEDURE delete_row(p_line_location_id NUMBER)
   IS
      x_progress    VARCHAR2(3);
   BEGIN
      x_progress := '001';

      DELETE FROM poa_bis_supplier_performance
      WHERE  po_shipment_id = p_line_location_id;

   EXCEPTION
      WHEN OTHERS THEN
   	 POA_LOG.put_line('delete_row:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;

   END delete_row;




   /* insert_row
    * ----------
    * This procedure simply inserts a single record into the supplier
    * performance fact table.
    */
   PROCEDURE insert_row(p_shipment_id              NUMBER,
                        p_ship_to_location_id      NUMBER,
                        p_ship_to_organization_id  NUMBER,
                        p_org_id                   NUMBER,
                        p_item_id                  NUMBER,
                        p_category_id              NUMBER,
                        p_supplier_id              NUMBER,
                        p_supplier_site_id         NUMBER,
                        p_buyer_id                 NUMBER,
                        p_date_dimension           DATE,
                        p_quantity_purchased       NUMBER,
                        p_purchase_price           NUMBER,
                        p_primary_uom              VARCHAR2,
                        p_currency_code            VARCHAR2,
                        p_rate_type                VARCHAR2,
                        p_rate_date                DATE,
                        p_rate                     NUMBER,
                        p_quantity_ordered         NUMBER,
                        p_quantity_received        NUMBER,
                        p_quantity_rejected        NUMBER,
                        p_amount                   NUMBER,
                        p_number_of_receipts       NUMBER,
                        p_quantity_received_late   NUMBER,
                        p_quantity_received_early  NUMBER,
                        p_quantity_past_due        NUMBER,
                        p_first_receipt_date       DATE,
                        p_shipment_expected_date   DATE,
                        p_month_bucket             DATE,
                        p_quarter_bucket           DATE,
                        p_year_bucket              DATE,
                        p_created_by               NUMBER,
                        p_creation_date            DATE,
                        p_last_update_date         DATE,
                        p_last_updated_by          NUMBER,
                        p_last_update_login        NUMBER,
                        p_request_id               NUMBER,
                        p_program_application_id   NUMBER,
                        p_program_id               NUMBER,
                        p_program_update_date      DATE)
   IS
      x_progress    VARCHAR2(3);
   BEGIN
      x_progress := '001';

      INSERT INTO poa_bis_supplier_performance (
						PO_SHIPMENT_ID 	     ,
						SHIP_TO_LOCATION_ID		,
						SHIP_TO_ORGANIZATION_ID	,
						ORG_ID 				,
						ITEM_ID				 ,
						category_id,
						SUPPLIER_ID	,
						SUPPLIER_SITE_ID	,
						BUYER_ID			,
						DATE_DIMENSION 			,
						QUANTITY_PURCHASED			,
						PURCHASE_PRICE 			,
						PRIMARY_UOM				,
						CURRENCY_CODE				,
						RATE_TYPE				,
						RATE_DATE				,
						RATE					,
						QUANTITY_ORDERED			,
						QUANTITY_RECEIVED			,
						QUANTITY_REJECTED			,
						AMOUNT 				,
						NUMBER_OF_RECEIPTS			,
						QUANTITY_RECEIVED_LATE 		,
						QUANTITY_RECEIVED_EARLY		,
						QUANTITY_PAST_DUE			,
						FIRST_RECEIPT_DATE			,
						SHIPMENT_EXPECTED_DATE 		,
						MONTH_BUCKET				,
						QUARTER_BUCKET 			,
						YEAR_BUCKET				,
						CREATED_BY			 ,
						CREATION_DATE			 ,
						LAST_UPDATE_DATE		 ,
						LAST_UPDATED_BY		 ,
						LAST_UPDATE_LOGIN		,
						REQUEST_ID			,
						PROGRAM_APPLICATION_ID 	,
						PROGRAM_ID			,
						PROGRAM_UPDATE_DATE
						)
	VALUES
      (
         p_shipment_id,
         p_ship_to_location_id,
         p_ship_to_organization_id,
         p_org_id,
         p_item_id,
         p_category_id,
         p_supplier_id,
         p_supplier_site_id,
         p_buyer_id,
         p_date_dimension,
         p_quantity_purchased,
         p_purchase_price,
         p_primary_uom,
         p_currency_code,
         p_rate_type,
         p_rate_date,
         p_rate,
         p_quantity_ordered,
         p_quantity_received,
         p_quantity_rejected,
         p_amount,
         p_number_of_receipts,
         p_quantity_received_late,
         p_quantity_received_early,
         p_quantity_past_due,
         p_first_receipt_date,
         p_shipment_expected_date,
         p_month_bucket,
         p_quarter_bucket,
         p_year_bucket,
         p_created_by,
         p_creation_date,
         p_last_update_date,
         p_last_updated_by,
         p_last_update_login,
         p_request_id,
         p_program_application_id,
         p_program_id,
         p_program_update_date
      );

   EXCEPTION
      WHEN OTHERS THEN
   	 POA_LOG.put_line('insert_row:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;

   END insert_row;

END POA_SUPPERF_POPULATE_PKG;




/
