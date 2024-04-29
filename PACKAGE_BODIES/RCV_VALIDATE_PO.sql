--------------------------------------------------------
--  DDL for Package Body RCV_VALIDATE_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_VALIDATE_PO" AS
/* $Header: RCVTIR4B.pls 120.2.12010000.9 2014/03/13 07:31:52 smididud ship $ */

/*===========================================================================
FUNCTION NAME: prevent_doc_action()

===========================================================================*/

FUNCTION prevent_doc_action(  x_Entity             IN varchar2,
                              x_Action             IN varchar2,
                              x_Po_num             IN varchar2,
                              x_Org_id             IN NUMBER,
                              x_Po_header_id       IN NUMBER,
                              x_Release_num        IN NUMBER,
                              x_Release_id         IN NUMBER,
                              x_Po_line_num        IN NUMBER,
                              x_Po_line_id         IN NUMBER,
                              x_Shipment_num       IN NUMBER,
                              x_Shipment_line_id   IN NUMBER,
                              x_Item_id            IN NUMBER,
			      x_item_num           IN varchar2,
                              x_Item_revision      IN varchar2,
                              x_Item_description   IN varchar2,
                              x_Unit_of_measure    IN varchar2
                            )   RETURN VARCHAR2 IS
l_count number := 0;
x_progress VARCHAR2(3) := NULL;

begin

  x_progress := '010';

	IF x_entity = 'Header' then

	  x_progress := '020';


	  SELECT Count(1)
	  INTO l_count
	  FROM rcv_transactions_interface
	  WHERE transaction_status_code = 'PENDING'
	  and processing_status_code <> 'ERROR'
	  AND source_document_code = 'PO'
	  AND (po_header_id = x_po_header_id OR (document_num = x_po_num AND org_id = x_Org_id))
          AND ( (po_release_id IS NULL OR (po_release_id IS NOT NULL AND po_release_id = x_Release_id))  /* bug 18038975 */
                 OR (release_num IS NULL OR (release_num IS NOT NULL AND release_num = x_Release_num)) );

	 x_progress := '030';

	ELSIF x_entity = 'Line' THEN

	  x_progress := '040';


	  SELECT Count(1)
	  INTO l_count
	  FROM rcv_transactions_interface
	  WHERE transaction_status_code = 'PENDING'
	  and processing_status_code <> 'ERROR'
	  AND source_document_code = 'PO'
	  AND ( po_header_id = nvl(x_po_header_id,po_header_id)
	        OR (document_num = nvl(x_po_num,document_num) AND org_id = nvl(x_Org_id,org_id)) )
          AND ( (po_release_id IS NULL OR (po_release_id IS NOT NULL AND po_release_id = x_Release_id)) /* bug 18038975 */
                OR (release_num IS NULL OR (release_num IS NOT NULL AND release_num = x_Release_num)) )
	  AND ( po_line_id = x_po_line_id OR document_line_num = x_po_line_num
		OR item_id = x_item_id OR item_num = x_item_num OR item_description = x_Item_description);


	x_progress := '050';

	ELSIF x_entity = 'Shipment' THEN

	  x_progress := '060';

	  SELECT Count(1)
	  INTO l_count
	  FROM rcv_transactions_interface
	  WHERE transaction_status_code = 'PENDING'
	  and processing_status_code <> 'ERROR'
	  AND source_document_code = 'PO'
	  AND ( po_header_id = nvl(x_po_header_id,po_header_id)
	        OR (document_num = nvl(x_po_num,document_num) AND org_id = nvl(x_Org_id,org_id)) )
          AND ( (po_release_id IS NULL OR (po_release_id IS NOT NULL AND po_release_id = x_Release_id)) /* bug 18038975 */
                OR (release_num IS NULL OR (release_num IS NOT NULL AND release_num = x_Release_num)) )
	  AND ( po_line_id = nvl(x_po_line_id,po_line_id)  OR document_line_num = nvl(x_po_line_num,document_line_num)
		OR ( item_id = nvl(x_item_id,item_id) OR item_num = nvl(x_item_num,item_num)
		OR item_description = nvl(item_description,x_Item_description) ) )
	  AND (po_line_location_id = x_Shipment_line_id OR document_shipment_line_num = x_shipment_num);

	END IF;

	x_progress := '070';

	if l_count <>0 then
	 return 'TRUE';
	else
	 return 'FALSE';
	end if;

 EXCEPTION

	WHEN OTHERS THEN

        po_message_s.sql_error('prevent_doc_action', x_progress,sqlcode);
	return 'TRUE';
        RAISE;

End prevent_doc_action;

/*===========================================================================

  PROCEDURE NAME: validate_novation_receipts()

===========================================================================*/

PROCEDURE validate_novation_receipts (
          p_request_id IN NUMBER,
          p_vendor_id IN NUMBER,
          p_novation_date IN DATE,
          p_header_id_tbl IN  PO_TBL_NUMBER,
          x_validation_results IN OUT NOCOPY po_multi_mod_val_results_type,
          x_validation_result_type OUT NOCOPY VARCHAR2,
          x_return_status OUT NOCOPY VARCHAR2,
          x_error_msg OUT NOCOPY VARCHAR2 ) IS

  CURSOR c_rt_invioce (p_po_header_id IN NUMBER) IS
  SELECT DISTINCT shipment_header_id
    FROM (
  SELECT rsl.shipment_header_id, rsl.shipment_line_id, rsl.quantity_received
    FROM rcv_transactions rt,
         rcv_shipment_lines rsl,
         po_line_locations_all poll
   WHERE rt.transaction_type IN ('RECEIVE', 'MATCH')
     AND rt.shipment_line_id = rsl.shipment_line_id
     AND rsl.po_line_location_id = poll.line_location_id
     AND rsl.po_header_id = poll.po_header_id
     AND rt.po_line_location_id = poll.line_location_id
     AND rt.po_header_id = poll.po_header_id
     AND poll.match_option = 'R'
     AND rt.source_document_code = 'PO'
     AND rt.quantity IS NOT NULL
     AND rt.po_header_id = p_po_header_id
  GROUP BY rsl.shipment_header_id, rsl.shipment_line_id, rsl.quantity_received
  HAVING rsl.quantity_received > Sum(Nvl(rt.quantity_billed, 0))
  UNION
  SELECT rsl.shipment_header_id, rsl.shipment_line_id, rsl.amount_received
    FROM rcv_transactions rt,
         rcv_shipment_lines rsl,
         po_line_locations_all poll
   WHERE rt.transaction_type IN ('RECEIVE', 'MATCH')
     AND rt.shipment_line_id = rsl.shipment_line_id
     AND rsl.po_line_location_id = poll.line_location_id
     AND rsl.po_header_id = poll.po_header_id
     AND rt.po_line_location_id = poll.line_location_id
     AND rt.po_header_id = poll.po_header_id
     AND poll.match_option = 'R'
     AND rt.source_document_code = 'PO'
     AND rt.amount IS NOT NULL
     AND rt.po_header_id = p_po_header_id
  GROUP BY rsl.shipment_header_id, rsl.shipment_line_id, rsl.amount_received
  HAVING rsl.amount_received > Sum(Nvl(rt.amount_billed, 0)) ) ;


  CURSOR c_rt_novation (p_po_header_id IN NUMBER, p_date IN DATE) IS
  SELECT rsh.shipment_header_id,
         rsh.receipt_num,
         Min(rt.transaction_date)
    FROM rcv_transactions rt,
         rcv_shipment_headers rsh
   WHERE rt.shipment_header_id = rsh.shipment_header_id
     AND rt.po_header_id = p_po_header_id
     AND rt.source_document_code = 'PO'
     AND rt.transaction_type IN  ('RECEIVE', 'MATCH')
     AND rt.transaction_date >= p_date
  GROUP BY rsh.shipment_header_id,
           rsh.receipt_num;


  l_po_header_id             po_headers_all.po_header_id%TYPE;
  l_shipment_header_id       rcv_shipment_headers.shipment_header_id%TYPE;
  l_receipt_date             rcv_transactions.transaction_date%TYPE;
  l_receipt_number           rcv_shipment_headers.receipt_num%TYPE;
  l_multi_mod_val_result_id  NUMBER;
  l_receipt_amount           NUMBER;
  l_exception_type           VARCHAR2(200) := NULL ;
  l_message_name             VARCHAR2(200) := NULL;
  l_rti_count                NUMBER;
  l_progress                 VARCHAR2(5);
  i                          NUMBER;


BEGIN

  i := 1;
  l_progress := '000';
  x_validation_result_type := 'SUCCESS';
  x_validation_results     := po_multi_mod_val_results_type.new_instance();

  FOR i IN 1 .. p_header_id_tbl.Count LOOP

    l_po_header_id := p_header_id_tbl(i);
    l_progress := '010';

    OPEN c_rt_invioce(l_po_header_id);
    LOOP

      l_progress := '020';
      FETCH c_rt_invioce INTO  l_shipment_header_id;

      IF c_rt_invioce%NOTFOUND THEN
        EXIT;
      END IF;

      l_progress := '030';
      SELECT rsh.receipt_num, Min(rt.transaction_date)
        INTO l_receipt_number, l_receipt_date
        FROM rcv_shipment_headers rsh,
             rcv_transactions rt
       WHERE rt.shipment_header_id = rsh.shipment_header_id
         AND rt.transaction_type IN ('RECEIVE', 'MATCH')
         AND rsh.shipment_header_id = l_shipment_header_id
      GROUP BY rsh.receipt_num;

      SELECT Nvl(Sum(Nvl(rsl.quantity_received, 0) * NVL(poll.price_override, pol.unit_price) ), 0)
        INTO l_receipt_amount
        FROM rcv_shipment_lines rsl,
             po_line_locations_all poll,
             po_lines_all pol
       WHERE rsl.po_line_location_id = poll.line_location_id
         AND rsl.po_line_id = pol.po_line_id
         AND pol.po_line_id = poll.po_line_id
         AND rsl.quantity_shipped IS NOT NULL
         AND rsl.shipment_header_id = l_shipment_header_id ;

      IF l_receipt_amount = 0 THEN
         SELECT Nvl(Sum(Nvl(rsl.amount_received, 0)), 0)
           INTO l_receipt_amount
           FROM rcv_shipment_lines rsl
          WHERE rsl.quantity_shipped IS NULL
            AND rsl.shipment_header_id = l_shipment_header_id ;

      END IF;

      l_progress := '040';

      l_exception_type := 'PO_SUPCHG_UNINV_RCV';
      l_message_name   := NULL;
      x_validation_result_type := 'WARNING';
      SELECT po_multi_mod_val_results_s.nextval
        INTO l_multi_mod_val_result_id
        FROM dual;

      x_validation_results.add_result (p_multi_mod_val_result_id => l_multi_mod_val_result_id,
                                       p_multi_mod_request_id => p_request_id,
                                       p_result_type => 'WARNING',
                                       p_validation_type => 'RECEIPTS',
                                       p_exception_type => l_exception_type,
                                       p_document_id => l_po_header_id,
                                       p_document_number => NULL,
                                       p_related_document_id => l_shipment_header_id,
                                       p_related_document_number => l_receipt_number,
                                       p_related_document_date => l_receipt_date,
                                       p_related_document_amount => l_receipt_amount,
                                       p_message_application => 'PO',
                                       p_message_name => l_message_name);

    END LOOP; -- FETCH c_rt_invioce INTO ..

    CLOSE c_rt_invioce;


    /* If there are any open transactions in the receiving open interface for any
       of the selected documents, generate an exception */
    l_progress := '050';
    l_rti_count := 0;
    l_exception_type := NULL;
    l_message_name   := NULL;

    SELECT count(*)
      INTO l_rti_count
      FROM rcv_transactions_interface rti
     WHERE rti.po_header_id = l_po_header_id
        OR ( (rti.receipt_source_code = 'VENDOR' OR rti.source_document_code = 'PO')
              AND EXISTS
                ( SELECT 1
                    FROM po_headers_all poh
                   WHERE type_lookup_code IN('STANDARD', 'BLANKET', 'SCHEDULED')
                     AND poh.segment1 = rti.document_num
                     AND poh.org_id = Nvl(rti.org_id, poh.org_id)
                     AND poh.po_header_id = l_po_header_id )
           );

    IF l_rti_count > 0 THEN

       l_progress := '060';

       l_exception_type := 'PO_SUPCHG_WITH_RCV_TRX_SUM';
       l_message_name   := 'PO_SUPCHG_WITH_RCV_TRX';
       x_validation_result_type := 'WARNING';
       SELECT po_multi_mod_val_results_s.nextval
       INTO l_multi_mod_val_result_id
       FROM dual;

       x_validation_results.add_result (p_multi_mod_val_result_id => l_multi_mod_val_result_id,
                                        p_multi_mod_request_id => p_request_id,
                                        p_result_type => 'WARNING',
                                        p_validation_type => 'RECEIPTS',
                                        p_exception_type => l_exception_type,
                                        p_document_id => l_po_header_id,
                                        p_related_document_id => NULL,
                                        p_related_document_number => NULL,
                                        p_related_document_date => NULL,
                                        p_related_document_amount => NULL,
                                        p_message_application => 'PO',
                                        p_message_name => l_message_name);
    END IF;


    /* If there are any receipts where the receipt date is ON OR AFTER the
       'Effective Date of Novation' , then generate an exception */

    l_exception_type := NULL;
    l_message_name   := NULL;
    OPEN c_rt_novation(l_po_header_id, p_novation_date);
    LOOP

      l_progress := '070';
      FETCH c_rt_novation INTO  l_shipment_header_id, l_receipt_number, l_receipt_date;

      IF c_rt_novation%NOTFOUND THEN
        EXIT;
      END IF;

      l_progress := '080';
      SELECT Sum(Nvl(rsl.quantity_received, 0) * NVL(poll.price_override, pol.unit_price) )
        INTO l_receipt_amount
        FROM rcv_shipment_lines rsl,
             po_line_locations_all poll,
             po_lines_all pol
       WHERE rsl.po_line_location_id = poll.line_location_id
         AND rsl.po_line_id = pol.po_line_id
         AND pol.po_line_id = poll.po_line_id
         AND rsl.quantity_shipped IS NOT NULL
         AND rsl.shipment_header_id = l_shipment_header_id ;

      IF l_receipt_amount = 0 THEN
         SELECT Sum(Nvl(rsl.amount_received, 0))
           INTO l_receipt_amount
           FROM rcv_shipment_lines rsl
          WHERE rsl.quantity_shipped IS NULL
            AND rsl.shipment_header_id = l_shipment_header_id ;

      END IF;

      l_progress := '090';
      l_exception_type := 'PO_SUPCHG_RDAT_GE_NOVDAT_SUM';
      l_message_name   := 'PO_SUPCHG_RDAT_GE_NOVDAT';
      x_validation_result_type := 'WARNING';
      SELECT po_multi_mod_val_results_s.nextval
        INTO l_multi_mod_val_result_id
        FROM dual;

      x_validation_results.add_result  (p_multi_mod_val_result_id => l_multi_mod_val_result_id,
                                        p_multi_mod_request_id => p_request_id,
                                        p_result_type => 'WARNING',
                                        p_validation_type => 'RECEIPTS',
                                        p_exception_type => l_exception_type,
                                        p_document_id => l_po_header_id,
                                        p_related_document_id => l_shipment_header_id,
                                        p_related_document_number => l_receipt_number,
                                        p_related_document_date => l_receipt_date,
                                        p_related_document_amount => l_receipt_amount,
                                        p_message_application => 'PO',
                                        p_message_name => l_message_name);


    END LOOP; -- FETCH c_rt_novation INTO ..

    CLOSE c_rt_novation;



  END LOOP; -- FOR i IN 1 .. n LOOP

  l_progress := '100';
  x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN OTHERS
    THEN

      x_validation_result_type := 'WARNING';
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_msg := 'All records failed by rcv_validate_po.validate_novation_receipts in process '||l_progress;

END validate_novation_receipts;

End RCV_VALIDATE_PO;


/
