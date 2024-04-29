--------------------------------------------------------
--  DDL for Package Body POS_VIEW_RECEIPTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_VIEW_RECEIPTS_GRP" AS
/* $Header: POSGRCPB.pls 120.8.12010000.2 2014/04/21 09:06:20 pneralla ship $*/

/* Logic in this procedure is same as RCV_INVOICE_MATCHING_SV.get_quantities.
since we can not directly use the RCV function as it references secured sysnonyms,
same logic is incorporated here. Also, we are interested only in Return and Rejcted
quantities
For bug:18276920 : added parameter to get accepted_qty also*/


PROCEDURE get_quantities(
    top_transaction_id  IN  NUMBER,
    rtv_txn_qty     IN OUT  NOCOPY NUMBER,
    rejected_txn_qty    IN OUT  NOCOPY NUMBER,
    accepted_txn_qty IN OUT NOCOPY NUMBER)  IS

   X_progress            VARCHAR2(3)  := '000';

   X_primary_uom         VARCHAR2(25) := '';
   X_txn_uom             VARCHAR2(25) := '';
   X_po_uom              VARCHAR2(25) := '';
   X_pr_to_txn_rate      NUMBER := 1;
   X_pr_to_po_rate       NUMBER := 1;
   X_po_to_txn_rate      NUMBER := 1;
   X_item_id             NUMBER := 0;
   X_line_location_id    NUMBER := 0;
   X_received_quantity   NUMBER := 0;
   X_corrected_quantity  NUMBER := 0;
   X_delivered_quantity  NUMBER := 0;
   X_rtv_quantity        NUMBER := 0;
   X_accepted_quantity   NUMBER := 0;
   X_rejected_quantity   NUMBER := 0;

   v_primary_uom         VARCHAR2(25) := '';
   v_po_uom              VARCHAR2(25) := '';
   v_txn_uom             VARCHAR2(25) := '';
   v_txn_id              NUMBER := 0;
   v_primary_quantity    NUMBER := 0;
   v_transaction_type    VARCHAR2(25) := '';
   v_parent_id           NUMBER := 0;
   v_parent_type         VARCHAR2(25) := '';
   v_shipment_line_id    NUMBER := 0;
   v_line_location_id    NUMBER := 0;

   grand_parent_type VARCHAR2(25) := '';
   grand_parent_id       NUMBER := 0;

   /* This cursor recursively query up all the children of the
   ** top transaction (RECEIVE or MATCH)
   */

   CURSOR c_txn_history (c_transaction_id NUMBER) IS
     SELECT
       transaction_id,
       primary_quantity,
       primary_unit_of_measure,
       unit_of_measure,
       source_doc_unit_of_measure,
       transaction_type,
       shipment_line_id,
       po_line_location_id,
       parent_transaction_id
     FROM
       rcv_transactions
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id;

BEGIN
     -- return if invalid input parameters

     IF top_transaction_id IS NULL THEN
       RETURN;
     END IF;

     OPEN c_txn_history(top_transaction_id);

     X_progress := '001';
     LOOP
       FETCH c_txn_history INTO v_txn_id,
                                v_primary_quantity,
                                v_primary_uom,
                                v_txn_uom,
                                v_po_uom,
                                v_transaction_type,
                                v_shipment_line_id,
                                v_line_location_id,
                                v_parent_id;

       EXIT WHEN c_txn_history%NOTFOUND;

       X_progress := '002';

       IF v_transaction_type = 'RECEIVE' OR v_transaction_type = 'MATCH' THEN

         /* Find out the item_id for UOM conversion */
           SELECT item_id INTO X_item_id
           FROM rcv_shipment_lines
           WHERE shipment_line_id = v_shipment_line_id;

           X_received_quantity := v_primary_quantity;
           X_line_location_id := v_line_location_id;
           X_primary_uom := v_primary_uom;
           X_txn_uom := v_txn_uom;
           X_po_uom := v_po_uom;
       ELSIF v_transaction_type = 'RETURN TO VENDOR' THEN

           SELECT transaction_type INTO v_parent_type
           FROM rcv_transactions
           WHERE transaction_id = v_parent_id;

           if v_parent_type = 'ACCEPT' THEN
                X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
           end if;

           if v_parent_type = 'REJECT' THEN
                X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
           end if;
           X_rtv_quantity := X_rtv_quantity + v_primary_quantity;

       ELSIF v_transaction_type = 'DELIVER' THEN
           X_delivered_quantity := X_delivered_quantity + v_primary_quantity;

       ELSIF v_transaction_type = 'ACCEPT' THEN

           SELECT transaction_type INTO v_parent_type
           FROM rcv_transactions
           WHERE transaction_id = v_parent_id;

           if v_parent_type <> 'ACCEPT'  THEN
          X_accepted_quantity := X_accepted_quantity + v_primary_quantity;
           end if;

           if v_parent_type = 'REJECT' THEN
              X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
           end if;

       ELSIF v_transaction_type = 'REJECT' THEN

           SELECT transaction_type INTO v_parent_type
           FROM rcv_transactions
           WHERE transaction_id = v_parent_id;

          if v_parent_type <> 'REJECT'  then
             X_rejected_quantity := X_rejected_quantity + v_primary_quantity;
          end if;
          if v_parent_type = 'ACCEPT' then
             X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
          end if;

       ELSIF v_transaction_type = 'RETURN TO RECEIVING' THEN
          X_delivered_quantity := X_delivered_quantity - v_primary_quantity;

       ELSIF v_transaction_type = 'CORRECT' THEN

         /* The correction function is based on parent transaction type */

           SELECT  transaction_type,parent_transaction_id
           INTO v_parent_type,grand_parent_id
           FROM  rcv_transactions
           WHERE transaction_id = v_parent_id;

           BEGIN
             SELECT transaction_type INTO grand_parent_type
             FROM rcv_transactions
             WHERE transaction_id = grand_parent_id;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
              NULL;
           END;

           IF v_parent_type = 'RECEIVE' OR v_parent_type = 'MATCH' THEN
             X_corrected_quantity := X_corrected_quantity + v_primary_quantity;
           ELSIF v_parent_type = 'RETURN TO VENDOR' THEN
             if grand_parent_type = 'ACCEPT' THEN
                X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
             end if;

             if grand_parent_type = 'REJECT' THEN
                X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
             end if;
             X_rtv_quantity := X_rtv_quantity + v_primary_quantity;

           ELSIF v_parent_type = 'DELIVER' THEN
              X_delivered_quantity := X_delivered_quantity + v_primary_quantity;

           ELSIF v_parent_type = 'ACCEPT' THEN

             if grand_parent_type = 'REJECT' THEN
        X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
         end if;

             if grand_parent_type <> 'ACCEPT' THEN
               X_accepted_quantity := X_accepted_quantity + v_primary_quantity;
             end if;

           ELSIF v_parent_type = 'REJECT' THEN
         if grand_parent_type = 'ACCEPT' THEN
               X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
             end if;

             if grand_parent_type <> 'REJECT' THEN
               X_rejected_quantity := X_rejected_quantity + v_primary_quantity;
             end if;

           ELSIF v_parent_type = 'RETURN TO RECEIVING' THEN

              X_delivered_quantity := X_delivered_quantity - v_primary_quantity;

           END IF;
       END IF;

     END LOOP;

     CLOSE c_txn_history;

     X_progress := '003';

     X_progress := '004';

     /* Get UOM conversion rates */

     X_pr_to_po_rate := po_uom_s.po_uom_convert(X_primary_uom, X_po_uom, X_item_id);
     X_pr_to_txn_rate := po_uom_s.po_uom_convert(X_primary_uom, X_txn_uom, X_item_id);
     X_po_to_txn_rate := po_uom_s.po_uom_convert(X_po_uom, X_txn_uom, X_item_id);


     rtv_txn_qty := X_pr_to_txn_rate * X_rtv_quantity;
     rejected_txn_qty := X_pr_to_txn_rate * X_rejected_quantity;
     accepted_txn_qty := X_pr_to_txn_rate * X_accepted_quantity;

     rtv_txn_qty       := round(rtv_txn_qty,15);
     rejected_txn_qty  := round(rejected_txn_qty,15);
     accepted_txn_qty  := round(accepted_txn_qty,15);

EXCEPTION

  when others then
    po_message_s.sql_error('get_transaction_quantities', X_progress, sqlcode);
    raise;

END get_quantities;


/*To get the LPN/Lot/Serial information for the shipment_line: */

FUNCTION is_LpnLotSerial_Exist (p_rcv_shipment_line_id NUMBER) RETURN NUMBER IS
   isLPN  NUMBER;
   isLot  NUMBER;
   isSerial  NUMBER;
   isWms  VARCHAR2(1);
   lExecFunc VARCHAR2(30);
BEGIN
   /* Find if WMS is installed or not */
   lExecFunc := POS_ASN_CREATE_PVT.check_wms_install(1, isWms);
   IF (isWms <> 'S') THEN
      RETURN 0;
   END IF;


   /* Find if lpn exists for the given shipment_line_id */
   SELECT lpn_id into isLPN
   FROM rcv_transactions rt
   WHERE shipment_line_id = p_rcv_shipment_line_id
   AND transaction_type = 'RECEIVE';

   IF (isLPN is not null) THEN
   /*  LPN exists for this shipment line */
      RETURN 1;
   END IF;

   /*  No LPN; Find the lot or serial defined for this item  */

   SELECT lot_control_code, serial_number_control_code into isLot, isSerial
   FROM mtl_system_items msi, rcv_shipment_lines rsl
   WHERE msi.organization_id   = rsl.to_organization_id
   AND  msi.inventory_item_id = rsl.item_id
   AND rsl.shipment_line_id = p_rcv_shipment_line_id;

   IF (isLot > 1 OR isSerial > 1) THEN
   /*  Either lot or serial defined */
      RETURN 1;
   ELSE
     /*  No lot or serial defined  */
   RETURN 0;
   END IF;

EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN 0;
END;



PROCEDURE get_po_info  (
	p_shipment_header_id IN NUMBER,
 	p_po_switch OUT NOCOPY VARCHAR2,
	p_po_number OUT NOCOPY VARCHAR2,
 	p_po_header_id OUT NOCOPY VARCHAR2,
 	p_release_id OUT NOCOPY VARCHAR2)
IS
    po_num2 VARCHAR2(40);
    header_id2  VARCHAR2(40);
    release_id2  VARCHAR2(40);

         -- Declare cursor to retrieve the PO number for Supplier View.
         CURSOR po_cursor(l_shipment_header_id number) IS
         SELECT DISTINCT(ph.segment1||'-'||pr.release_num), ph.po_header_id, pr.po_release_id
         FROM rcv_shipment_lines rsl, po_headers_all ph,  po_releases_all pr
          WHERE rsl.shipment_header_id= l_shipment_header_id
            AND rsl.po_header_id = ph.po_header_id
            AND rsl.po_release_id = pr.po_release_id
            AND ph.type_lookup_code = 'BLANKET'
          UNION ALL
         SELECT DISTINCT ph.segment1, ph.po_header_id, null
           FROM rcv_shipment_lines rsl, po_headers_all ph
          WHERE rsl.shipment_header_id= l_shipment_header_id
            AND rsl.po_header_id    = ph.po_header_id
            AND ph.type_lookup_code = 'STANDARD';
Begin
       OPEN po_cursor(p_shipment_header_id);

       FETCH po_cursor INTO p_po_number, p_po_header_id, p_release_id;
           if (po_cursor%NOTFOUND) then
            -- no pos
            p_po_switch := 'Po_No';
           else
              --atleast one po
              FETCH po_cursor INTO po_num2, header_id2, release_id2;
              if (po_cursor%NOTFOUND) then
                 --exactly one PO
                 p_po_switch := 'PO_Single';
              else
                 -- multiple POs
                 p_po_switch := 'PO_Multiple';
                 --p_po_number := 'Multiple'; --Pass the FND Message
                 p_po_number := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
              end if;
           end if;

           CLOSE po_cursor;

EXCEPTION WHEN OTHERS THEN
        p_po_switch := 'Po_Excep';
End get_po_info;


PROCEDURE get_invoice_info  (
	p_shipment_header_id IN NUMBER,
 	p_invoice_switch OUT NOCOPY VARCHAR2,
	p_invoice_number OUT NOCOPY VARCHAR2,
 	p_invoice_id OUT NOCOPY VARCHAR2) IS

    inv_num2 VARCHAR2(40);
    header_id2  VARCHAR2(40);

         -- Declare cursor to retrieve the Invoice number for Supplier View.
    CURSOR inv_cursor(l_shipment_header_id number) IS
      SELECT DISTINCT ap.invoice_num,ap.invoice_id
      FROM ap_invoices_all ap, ap_invoice_lines_all al, rcv_transactions rt
      WHERE ap.invoice_id = al.invoice_id
      AND al.rcv_transaction_id = rt.transaction_id
      AND rt.shipment_header_id = l_shipment_header_id;

Begin
    OPEN inv_cursor(p_shipment_header_id);

       FETCH inv_cursor INTO p_invoice_number, p_invoice_id;
           if (inv_cursor%NOTFOUND) then
            -- no invoices
            p_invoice_switch := 'Inv_No';
           else
              --atleast one Invoice
              FETCH inv_cursor INTO inv_num2, header_id2;
              if (inv_cursor%NOTFOUND) then
                 --exactly one Invoice
                 p_invoice_switch := 'Inv_Single';
              else
                 -- multiple Invoices
                 p_invoice_switch := 'Inv_Multiple';
                 --p_invoice_number := 'Multiple'; --Pass the FND Message
                 p_invoice_number := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
              end if;
           end if;

           CLOSE inv_cursor;

EXCEPTION WHEN OTHERS THEN
        p_invoice_switch := 'inv_Excep';
End get_invoice_info;


PROCEDURE get_invoice_info_for_line  (
	p_shipment_line_id IN NUMBER,
 	p_invoice_switch OUT NOCOPY VARCHAR2,
	p_invoice_number OUT NOCOPY VARCHAR2,
 	p_invoice_id OUT NOCOPY VARCHAR2) IS

    inv_num2 VARCHAR2(40);
    header_id2  VARCHAR2(40);

         -- Declare cursor to retrieve the Invoice number for Supplier View.
    CURSOR inv_cursor(l_shipment_line_id number) IS
       SELECT DISTINCT ap.invoice_num,ap.invoice_id
       FROM ap_invoices_all ap, ap_invoice_lines_all al, rcv_transactions rt
       WHERE ap.invoice_id = al.invoice_id
       AND al.rcv_transaction_id = rt.transaction_id
       AND rt.shipment_line_id = l_shipment_line_id;

Begin
    OPEN inv_cursor(p_shipment_line_id);

       FETCH inv_cursor INTO p_invoice_number, p_invoice_id;
           if (inv_cursor%NOTFOUND) then
            -- no invoices
            p_invoice_switch := 'Inv_No';
           else
              --atleast one Invoice
              FETCH inv_cursor INTO inv_num2, header_id2;
              if (inv_cursor%NOTFOUND) then
                 --exactly one Invoice
                 p_invoice_switch := 'Inv_Single';
              else
                 -- multiple Invoices
                 p_invoice_switch := 'Inv_Multiple';
                 --p_invoice_number := 'Multiple'; --Pass the FND Message
                 p_invoice_number := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
              end if;
           end if;

           CLOSE inv_cursor;

EXCEPTION WHEN OTHERS THEN
        p_invoice_switch := 'inv_Excep';
End get_invoice_info_for_line;

END POS_VIEW_RECEIPTS_GRP;


/
