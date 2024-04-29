--------------------------------------------------------
--  DDL for Package Body CHV_CUM_PERIODS_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_CUM_PERIODS_S2" as
/* $Header: CHVCUMPB.pls 120.1.12010000.4 2014/05/26 07:45:05 shikapoo ship $ */

/*========================= CHV_CUM_PERIODS =================================*/

/*=============================================================================

  PROCEDURE NAME:     get_cum_info()

=============================================================================*/
PROCEDURE get_cum_info    (x_organization_id               IN      NUMBER,
                           x_vendor_id                     IN      NUMBER,
                           x_vendor_site_id                IN      NUMBER,
                           x_item_id                       IN      NUMBER,
                           x_horizon_start_date            IN      DATE,
                           x_horizon_end_date              IN      DATE,
                           x_purchasing_unit_of_measure    IN      VARCHAR2,
                           x_primary_unit_of_measure       IN      VARCHAR2,
                           x_last_receipt_transaction_id   IN OUT NOCOPY  NUMBER,
                           x_cum_quantity_received         IN OUT NOCOPY  NUMBER,
                           x_cum_quantity_received_prim    IN OUT NOCOPY  NUMBER,
                           x_cum_period_end_date           IN OUT NOCOPY  DATE)   IS



  x_progress               VARCHAR2(3) := NULL;
  x_enable_cum_flag        VARCHAR2(1) := NULL;
  x_cum_period_id          NUMBER      := 0;
  x_cum_period_start_date  DATE;
  x_rtv_update_cum_flag    VARCHAR2(1) := '';
  x_number_records_cpi     NUMBER      := 0;

  x_user_id                NUMBER;
  x_login_id               NUMBER;
  x_max_trans_date         DATE;

  --Bug5674055 commented the existing code and implemented the same using cursors.
  /*bug 8881513 While running the auto schedule program in supplier scheduling
               product there was a performance issue.
	       Modified the sql in the cursor c_trxn_date as per the receiving
               team advice.*/
  cursor c_trxn_date is
  SELECT  /*+ FIRST_ROWS */ transaction_date
   FROM   rcv_transactions rct2,
          rcv_shipment_lines rsl2
   WHERE  rct2.transaction_type = 'RECEIVE'
   AND    rct2.transaction_date between
                           x_cum_period_start_date - 1
                           and
                           nvl(x_cum_period_end_date,rct2.transaction_date+1) + 1
   AND    rsl2.item_id = x_item_id
   AND    rct2.vendor_id = x_vendor_id
   AND    rct2.vendor_site_id = x_vendor_site_id
   AND    rct2.organization_id = x_organization_id
   AND    rct2.shipment_line_id = rsl2.shipment_line_id
   AND    rct2.shipment_header_id = rsl2.shipment_header_id --bug 8881513
   AND    rct2.organization_id = rsl2.to_organization_id --bug 8881513
   ORDER BY transaction_date desc;

   /* Bug#18822988: Cummins GBPA Support */
   /* Added standard PO condition for GBPAs */

   CURSOR c_txn_id IS
   SELECT transaction_id
     FROM rcv_transactions rct,
          rcv_shipment_lines rsl,
          po_headers poh,
          po_line_locations pll
    WHERE transaction_date = x_max_trans_date
    AND   rct.transaction_type = 'RECEIVE'
    AND   rct.transaction_date between x_cum_period_start_date - 1
                                   and nvl(x_cum_period_end_date,rct.transaction_date+1) + 1
    AND   rsl.item_id          = x_item_id
    AND   rsl.po_line_location_id = pll.line_location_id
    AND   rct.vendor_id        = x_vendor_id
    AND   poh.vendor_site_id   = x_vendor_site_id
    AND   rct.organization_id  = x_organization_id
    AND   poh.po_header_id = rct.po_header_id
    AND   rct.shipment_line_id = rsl.shipment_line_id
    AND   (( poh.type_lookup_code = 'BLANKET'
		         AND poh.supply_agreement_flag = 'Y'
             AND EXISTS  (select '1'
                     from po_asl_attributes_val_v paa,
                          po_asl_documents pad
                    WHERE paa.vendor_id = x_vendor_id
                      AND paa.vendor_site_id = x_vendor_site_id
                      AND paa.item_id = x_item_id
                      AND paa.using_organization_id =
                          (SELECT MAX(paa2.using_organization_id)
                           FROM   po_asl_attributes_val_v paa2
                           WHERE  decode(paa2.using_organization_id, -1,
                                         x_organization_id,
                                         paa2.using_organization_id) =
                                         x_organization_id
                              AND paa2.vendor_id = x_vendor_id
                              AND paa2.vendor_site_id = x_vendor_site_id
                              AND paa2.item_id = x_item_id)
                              AND  paa.asl_id = pad.asl_id
                              AND  pad.document_header_id = poh.po_header_id))
           OR ( poh.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll.from_header_id IS NOT NULL
                         AND     pll.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )	)

     ORDER BY transaction_id DESC;


BEGIN

  --Initialize quantities to 0.
  x_cum_quantity_received := 0;
  x_cum_quantity_received_prim := 0;

  -- Get x_user_id and x_login_id from the global variable set.
  x_user_id  := NVL(fnd_global.user_id, 0);
  x_login_id := NVL(fnd_global.login_id, 0);

  --dbms_output.put_line('Get Cum Info: user id, login'||x_user_id||x_login_id);

  -- Get the open cum period for the organization.
  x_progress := '005';
/* Bug 2251090 fixed. In the where clause  of the below sql, added
     the nvl() statement for cum_period_end_date to take care of null
     condition.
  */

  SELECT cum_period_id,
         cum_period_start_date,
         cum_period_end_date
  INTO   x_cum_period_id,
         x_cum_period_start_date,
         x_cum_period_end_date
  FROM   chv_cum_periods
  WHERE  organization_id      = x_organization_id
  AND    x_horizon_start_date BETWEEN cum_period_start_date
                              AND     nvl(cum_period_end_date,x_horizon_start_date+1);

  --dbms_output.put_line('Get Cum Info: end date'||x_cum_period_end_date);
  --dbms_output.put_line('Get Cum Info: start date'||x_cum_period_start_date);
  /* Bug 2251090 fixed. Aded the nvl() condition to the below if condition
    to take care of null condition.
  */

  IF (x_horizon_end_date < nvl(x_cum_period_end_date,x_horizon_end_date+1)) THEN
        x_cum_period_end_date := x_horizon_end_date;
  END IF;

  x_progress := '010';

  SELECT rtv_update_cum_flag
  INTO   x_rtv_update_cum_flag
  FROM   chv_org_options
  WHERE  organization_id = x_organization_id;

  --dbms_output.put_line('Get Cum Info'||x_rtv_update_cum_flag);

  -- Get the last receipt transaction date and receipt transaction
  -- during the cum period.
  -- Note: That we do not store the vendor site id in rcv_transactions
  -- when we create the receipt.  So we must join back to po headers
  -- to verify that we are pointing to the correct vendor site.
  x_progress := '020';

  BEGIN
  /* Bug 2251090 fixed. In the where clause  of the below sql, added
     the nvl() statement for x_cum_period_end_date to take care of null
     condition.
  */

    -- Bug 3656241(forward fix of 3549677)
    -- Following SQL split into 2 sqls for performance improvement.
    -- Also driving off of po_headers by making  poh.vendor_id = x_vendor_id


   /* Bug 5674055
   SELECT max(transaction_date)
   INTO   x_max_trans_date
   FROM   rcv_transactions rct2,
          po_headers poh2,
          rcv_shipment_lines rsl2
   WHERE  rct2.transaction_type = 'RECEIVE'
   AND    rct2.transaction_date between
                           x_cum_period_start_date - 1
                           and
                           nvl(x_cum_period_end_date,rct2.transaction_date+1) + 1
   AND    rsl2.item_id = x_item_id
   AND    poh2.vendor_id = x_vendor_id
   AND    poh2.vendor_site_id = x_vendor_site_id
   AND    rct2.organization_id = x_organization_id
   AND    poh2.po_header_id = rct2.po_header_id
   AND    rct2.shipment_line_id = rsl2.shipment_line_id;*/

   open c_trxn_date;
   fetch c_trxn_date into x_max_trans_date;
   close c_trxn_date;

-- Bug 5674055 commented the following code.
  /*   SELECT max(transaction_id)
    INTO   x_last_receipt_transaction_id
    FROM   rcv_transactions rct,
           rcv_shipment_lines rsl,
           po_headers poh
    WHERE  transaction_date = x_max_trans_date
    (
                SELECT max(transaction_date)
                FROM   rcv_transactions rct2,
                       po_headers poh2,
                       rcv_shipment_lines rsl2
                WHERE  rct2.transaction_type = 'RECEIVE'
                AND    rct2.transaction_date between
                                        x_cum_period_start_date - 1
                                        and
                                        nvl(x_cum_period_end_date,rct2.transaction_date+1) + 1
                AND    rsl2.item_id = x_item_id
                AND    rct2.vendor_id = x_vendor_id
                AND    poh2.vendor_site_id = x_vendor_site_id
                AND    rct2.organization_id = x_organization_id
                AND    poh2.po_header_id = rct2.po_header_id
                AND    rct2.shipment_line_id = rsl2.shipment_line_id)
    AND    rct.transaction_type = 'RECEIVE'
    AND    rct.transaction_date between x_cum_period_start_date - 1
                                    and nvl(x_cum_period_end_date,rct.transaction_date+1) + 1
    AND    rsl.item_id          = x_item_id
    AND    rct.vendor_id        = x_vendor_id
    AND    poh.vendor_site_id   = x_vendor_site_id
    AND    rct.organization_id  = x_organization_id
    AND    poh.po_header_id = rct.po_header_id
    AND    rct.shipment_line_id = rsl.shipment_line_id

 Bug#3067808 Added the following retrictive condition to the SQL so that
** the correct value for transaction_id is retrived from receiving tables
** only for which the ASL entries exists.
*/
 /*   AND    EXISTS  (select '1'
                      from po_asl_attributes_val_v paa,
                           po_asl_documents pad
                     WHERE paa.vendor_id = x_vendor_id
                       AND paa.vendor_site_id = x_vendor_site_id
                       AND paa.item_id = x_item_id
                       AND paa.using_organization_id =
                           (SELECT MAX(paa2.using_organization_id)
                            FROM   po_asl_attributes_val_v paa2
                            WHERE  decode(paa2.using_organization_id, -1,
                                          x_organization_id,
                                          paa2.using_organization_id) =
                                          x_organization_id
                               AND paa2.vendor_id = x_vendor_id
                               AND paa2.vendor_site_id = x_vendor_site_id
                               AND paa2.item_id = x_item_id)
                               AND  paa.asl_id = pad.asl_id
                               AND  pad.document_header_id = poh.po_header_id);*/
/* Bug#3067808 END */

   open c_txn_id;
   fetch c_txn_id into x_last_receipt_transaction_id;
   close c_txn_id;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN null;
      WHEN OTHERS THEN raise;

  END;

  --dbms_output.put_line('Get Cum Info: trx id'||x_last_receipt_transaction_id);

  -- Get the CUM quantity received for the item.
  x_progress := '030';

  chv_cum_periods_s1.get_cum_qty_received(x_vendor_id,
                                          x_vendor_site_id,
                                          x_item_id,
                                          x_organization_id,
                                          x_rtv_update_cum_flag,
                                          x_cum_period_start_date,
                                          x_cum_period_end_date,
                                          x_purchasing_unit_of_measure,
                                          x_cum_quantity_received_prim,
                                          x_cum_quantity_received);

  --dbms_output.put_line('Get Cum Info: cum qty'||x_cum_quantity_received);

  -- If there are no records in chv_cum_period_items, then we must
  -- insert a record.  The first time we build a schedule for an item
  -- we must insert a record into chv_cum_period_items.
  x_progress := '040';

  SELECT count(*)
  INTO   x_number_records_cpi
  FROM   chv_cum_period_items cpi
  WHERE  cpi.cum_period_id = x_cum_period_id
  AND    cpi.vendor_id = x_vendor_id
  AND    cpi.vendor_site_id = x_vendor_site_id
  AND    cpi.organization_id = x_organization_id
  AND    cpi.item_id = x_item_id;

  IF (x_number_records_cpi > 0) THEN

    --dbms_output.put_line('Get Cum Info: record exists in cum period items');
    null;
  ELSE
    x_progress := '050';

    --dbms_output.put_line('Get Cum Info: insert record into cum period items');
    --dbms_output.put_line('Get Cum Info: period'||x_cum_period_id);
    --dbms_output.put_line('Get Cum info: vendor'||x_vendor_id);
    --dbms_output.put_line('Get Cum info: site'||x_vendor_site_id);
    --dbms_output.put_line('Get Cum info: item'||x_item_id);
    --dbms_output.put_line('Get Cum info: purchasing'||x_purchasing_unit_of_measure);
    --dbms_output.put_line('Get Cum info: primary'||x_primary_unit_of_measure);

    INSERT INTO chv_cum_period_items (cum_period_item_id,
                  cum_period_id,
                  organization_id,
                  vendor_id,
                  vendor_site_id,
                  item_id,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login)
    VALUES (chv_cum_period_items_s.NEXTVAL,
                  x_cum_period_id,
                  x_organization_id,
                  x_vendor_id,
                  x_vendor_site_id,
                  x_item_id,
                  SYSDATE,
                  x_user_id,
                  SYSDATE,
                  x_user_id,
                  x_login_id);

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('get_cum_info', x_progress, sqlcode);
      RAISE;

END get_cum_info;

END CHV_CUM_PERIODS_S2;

/
