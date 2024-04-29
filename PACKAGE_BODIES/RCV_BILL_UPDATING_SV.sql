--------------------------------------------------------
--  DDL for Package Body RCV_BILL_UPDATING_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_BILL_UPDATING_SV" AS
/* $Header: RCVBLUPB.pls 120.2 2006/03/21 22:53:02 samanna noship $*/

/** June 07, 1999,    bgu
 *  AP is no longer maintaining base_amount_billed, po will remove all reference
 *  to the field.
 */
PROCEDURE ap_update_po_distributions(   X_po_distribution_id    IN  NUMBER,
                                        X_quantity_billed       IN  NUMBER,
                                        X_uom_lookup_code       IN  VARCHAR2,
                                        X_amount_billed         IN  NUMBER,
                                        X_matching_basis        IN  VARCHAR2) IS

  X_progress            VARCHAR2(3) := '000';

  X_po_uom          VARCHAR2(25)    := '';
  X_item_id         NUMBER      := 0;
  X_po_quantity_billed      NUMBER      := 0;
  X_po_amount_billed        NUMBER      := 0;
  X_to_po_rate          NUMBER      := 1;


BEGIN

  SELECT
    pl.unit_meas_lookup_code,
    pl.item_id
  INTO
    X_po_uom,
    X_item_id
  FROM
    po_distributions pd,
    po_lines pl
  WHERE
    pd.po_distribution_id   = X_po_distribution_id AND
    pl.po_line_id       = pd.po_line_id;

  X_progress := '001';

  /* Get UOM conversion rates */

  IF(X_matching_basis = 'QUANTITY') THEN
     X_to_po_rate := po_uom_s.po_uom_convert(X_uom_lookup_code, X_po_uom, X_item_id);
  X_progress := '002';

  /* Calculate the quantity with UOM info */
     X_po_quantity_billed := round( (nvl(X_quantity_billed,0) * X_to_po_rate) ,15);
  END IF;

  /* Calculate the amount with new info */
  X_po_amount_billed := nvl(X_amount_billed,0);

  X_progress := '003';

  /* Update PO_DISTRIBUTIONS */
--Bug#2602981.Changed the X_po_quantity_billed to round(X_po_quantity_billed,15)

  /* Bug 4305628: For Planned Purchase orders, the quantity/amount billed on the
  **              Scheduled Release (SR) as well as the backing order (PPO)
  **              should be updated.
  */
  UPDATE po_distributions_all pod
  SET pod.quantity_billed = nvl(pod.quantity_billed,0) + X_po_quantity_billed,
      pod.amount_billed   = nvl(pod.amount_billed,0)   + X_po_amount_billed
  WHERE po_distribution_id  = X_po_distribution_id
     OR ( pod.distribution_type = 'PLANNED'
          AND pod.po_distribution_id = ( SELECT pod2.source_distribution_id
                                          FROM   po_distributions pod2
                                        WHERE pod2.distribution_type = 'SCHEDULED'
                                          AND pod2.po_distribution_id = X_po_distribution_id)
        );

  X_progress := '004';

EXCEPTION

  when others then
    po_message_s.sql_error('ap_update_po_distributions', X_progress, sqlcode);
    raise;

END ap_update_po_distributions;



PROCEDURE ap_update_po_line_locations(  X_po_line_location_id   IN  NUMBER,
                                        X_quantity_billed   IN  NUMBER,
                                        X_uom_lookup_code   IN  VARCHAR2,
                                        X_amount_billed     IN  NUMBER,
                                        X_matching_basis    IN  VARCHAR2) IS

  X_progress        VARCHAR2(3) := '000';

  X_po_uom      VARCHAR2(25)    := '';
  X_item_id     NUMBER      := 0;
  X_po_quantity_billed  NUMBER      := 0;
  X_po_amount_billed    NUMBER      := 0;
  X_to_po_rate      NUMBER      := 1;


BEGIN

  SELECT
    pl.unit_meas_lookup_code,
    pl.item_id
  INTO
    X_po_uom,
    X_item_id
  FROM
    po_line_locations ll,
    po_lines pl
  WHERE
    ll.line_location_id     = X_po_line_location_id AND
    pl.po_line_id       = ll.po_line_id;

  X_progress := '001';

  /* Get UOM conversion rates */

  IF( x_matching_basis = 'QUANTITY') THEN
     X_to_po_rate := po_uom_s.po_uom_convert(X_uom_lookup_code, X_po_uom, X_item_id);

  X_progress := '002';

  /* Calculate the quantity with UOM info */
  /* and amount with new info */
     X_po_quantity_billed := round((nvl(X_quantity_billed,0) * X_to_po_rate),15);
  ELSIF X_matching_basis = 'AMOUNT' THEN
     X_po_amount_billed := nvl(X_amount_billed,0);
  END IF;

  X_progress := '003';

  /* Update PO_LINE_LOCATIONS */
--Bug#2602981. Changed the X_po_quantity_billed to round(X_po_quantity_billed,15)

  /* Bug 4305628: For Planned Purchase orders, the quantity/amount billed on the
  **              Scheduled Release (SR) as well as the backing order (PPO)
  **              should be updated.
  */
  UPDATE po_line_locations_all pll
  SET pll.quantity_billed = nvl(pll.quantity_billed,0) + X_po_quantity_billed,
      pll.amount_billed   = nvl(pll.amount_billed,0)   + X_po_amount_billed
  WHERE pll.line_location_id    = X_po_line_location_id
     OR (  pll.shipment_type = 'PLANNED'
           AND pll.line_location_id = ( SELECT pll2.source_shipment_id
                                          FROM  po_line_locations pll2
                                        WHERE pll2.shipment_type = 'SCHEDULED'
                                          AND  pll2.line_location_id = X_po_line_location_id)
        );

  X_progress := '004';

EXCEPTION

  when others then
    po_message_s.sql_error('ap_update_po_line_locations', X_progress, sqlcode);
    raise;

END ap_update_po_line_locations;



PROCEDURE ap_update_rcv_transactions(   X_rcv_transaction_id    IN  NUMBER,
                    X_quantity_billed   IN  NUMBER,
                    X_uom_lookup_code   IN  VARCHAR2,
                    X_amount_billed     IN  NUMBER,
                    X_matching_basis    IN  VARCHAR2) IS
  X_progress            VARCHAR2(3) := '000';

  X_rcv_uom         VARCHAR2(25)    := '';
  X_item_id         NUMBER      := 0;
  X_rcv_quantity_billed     NUMBER      := 0;
  X_rcv_amount_billed       NUMBER      := 0;
  X_to_rcv_rate         NUMBER      := 1;


BEGIN

  SELECT
    rt.unit_of_measure,
    NVL(rt.quantity_billed, 0),
    NVL(rt.amount_billed, 0),
    rs.item_id
  INTO
    X_rcv_uom,
    X_rcv_quantity_billed,
    X_rcv_amount_billed,
    X_item_id
  FROM
    rcv_transactions rt,
    rcv_shipment_lines rs
  WHERE
    rt.transaction_id   = X_rcv_transaction_id AND
    rs.shipment_line_id = rt.shipment_line_id;

  X_progress := '001';

  /* Get UOM conversion rates */

  IF (x_matching_basis = 'QUANTITY') THEN
     X_to_rcv_rate := po_uom_s.po_uom_convert(X_uom_lookup_code, X_rcv_uom, X_item_id);

  X_progress := '002';

  /* Calculate the quantity with UOM info */
     X_rcv_quantity_billed := X_rcv_quantity_billed + (nvl(X_quantity_billed,0) * X_to_rcv_rate);
  END IF;

  /* Update the amount with new info */
  X_rcv_amount_billed := X_rcv_amount_billed + X_amount_billed;

  X_progress := '003';

  /* Update RCV_TRANSACTIONS */
--Bug#2602981.Changed the X_rcv_quantity_billed to round(X_rcv_quantity_billed,15)
  UPDATE
    rcv_transactions
  SET
    quantity_billed = round(X_rcv_quantity_billed,15),
    amount_billed   = X_rcv_amount_billed
  WHERE
    transaction_id  = X_rcv_transaction_id;

  X_progress := '004';

EXCEPTION

  when others then
    po_message_s.sql_error('ap_update_rcv_transactions', X_progress, sqlcode);
    raise;

END ap_update_rcv_transactions;



END RCV_BILL_UPDATING_SV;

/
