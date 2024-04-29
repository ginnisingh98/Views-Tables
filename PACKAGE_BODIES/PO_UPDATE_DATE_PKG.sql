--------------------------------------------------------
--  DDL for Package Body PO_UPDATE_DATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_UPDATE_DATE_PKG" AS
/* $Header: POXUPDTB.pls 120.0.12010000.3 2013/11/28 09:17:31 swvyamas noship $ */

  /* update_promised_date
   * --------------------
   */
  PROCEDURE update_promised_date(p_line_location_id NUMBER,
                                 p_new_promised_date DATE) IS
  BEGIN

    UPDATE PO_LINE_LOCATIONS_ALL
       SET promised_date = p_new_promised_date
     WHERE line_location_id = p_line_location_id;

    COMMIT;

  END update_promised_date;




  /* update_need_by_date
   * -------------------
   */
  PROCEDURE update_need_by_date(p_line_location_id NUMBER,
                             p_new_need_by_date DATE) IS
  BEGIN

    UPDATE PO_LINE_LOCATIONS_ALL
       SET need_by_date = p_new_need_by_date
     WHERE line_location_id = p_line_location_id;

    COMMIT;

  END update_need_by_date;



  /* update_req_need_by_date
   * -----------------------
   */
  PROCEDURE update_req_need_by_date(p_requisition_line_id NUMBER,
                                    p_new_need_by_date    DATE) IS
  BEGIN

    UPDATE PO_REQUISITION_LINES_ALL
       SET need_by_date = p_new_need_by_date
     WHERE requisition_line_id = p_requisition_line_id;

    COMMIT;

  END update_req_need_by_date;

  /* update_promised_date_lead_time
   * -----------------------
   * Update the promised date of the shipment based on the lead time of source document.
   */
  PROCEDURE update_promised_date_lead_time(p_po_header_id NUMBER) IS

  d_progress        NUMBER;
  d_module    VARCHAR2(70) := 'po.plsql.PO_UPDATE_DATE_PKG.update_promised_date_lead_time';
  l_lead_time NUMBER ;
  l_doc_type VARCHAR2(30);
  l_src_line_id NUMBER ;
  l_src_doc_type VARCHAR2(30);

  CURSOR c_get_lines(p_po_header_id NUMBER ) IS
    SELECT po_line_id,from_header_id,from_line_id FROM po_lines_all
    WHERE po_header_id = p_po_header_id;

  CURSOR c_get_shipments(p_po_line_id number) IS
    SELECT line_location_id,approved_flag,approved_date,promised_date
    FROM po_line_locations_all
    WHERE po_line_id = p_po_line_id;

  BEGIN

    d_progress := 0;

    IF (NOT PO_LOG.d_proc ) THEN
      PO_LOG.proc_begin(d_module);
      PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
    END IF ;

    d_progress := 10;

    SELECT type_lookup_code
    INTO l_doc_type
    FROM po_headers_all
    WHERE po_header_id = p_po_header_id;


    IF ( PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_doc_type', l_doc_type);
    END IF ;

    d_progress := 20;

    --The promise date is updated only for standard purchase orders.
    IF l_doc_type LIKE 'STANDARD' THEN

      d_progress := 30;
      IF ( PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Entered the doc type standard case');
      END IF ;

      FOR c_get_lines_rec IN c_get_lines(p_po_header_id) LOOP

        d_progress := 40;
        IF ( PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'Entered the get lines loop with line id : ' ,c_get_lines_rec.po_line_id);
        END IF ;

        --Check if the document line has any source document reference.
        IF  c_get_lines_rec.from_line_id IS NOT NULL THEN

          d_progress := 50;
          SELECT type_lookup_code
          INTO l_src_doc_type
          FROM po_headers_all
          WHERE po_header_id = c_get_lines_rec.from_header_id;

          IF ( PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'Entered the line id not null case : ');
          END IF ;

          --Update lead time only for blanktet type source document.
          IF l_src_doc_type LIKE 'BLANKET' THEN
            FOR c_get_shipments_rec IN c_get_shipments(c_get_lines_rec.po_line_id) LOOP

              d_progress := 60;
              IF ( PO_LOG.d_stmt) THEN
                PO_LOG.stmt(d_module, d_progress, 'Entered the get shipments loop with approval flag ',c_get_shipments_rec.approved_flag );
              END IF ;

              --The promised date of the shipment has to be null to default it based on lead time
              IF (Nvl(c_get_shipments_rec.approved_flag,'N') = 'N' AND c_get_shipments_rec.promised_date IS NULL )THEN

                d_progress := 70;
                IF ( PO_LOG.d_stmt) THEN
                  PO_LOG.stmt(d_module, d_progress, 'Entered the shipments not approved case to fetch lead time');
                END IF ;

                BEGIN

                  --Fetch the lead time value based on the order line Id
                  SELECT lead_time
                  INTO l_lead_time
                  FROM po_attribute_values
                  WHERE po_line_id = c_get_lines_rec.from_line_id;

                  d_progress := 80;
                  IF ( PO_LOG.d_stmt) THEN
                    PO_LOG.stmt(d_module, d_progress, 'Fetched the lead time ', l_lead_time);
                  END IF ;

                  d_progress := 90;

                  IF l_lead_time IS NOT NULL THEN
                    UPDATE po_line_locations_all
                    SET promised_date = SYSDATE  +  l_lead_time,
                    last_accept_date = SYSDATE  +  l_lead_time + Nvl(days_late_receipt_allowed,0)
                    WHERE line_location_id = c_get_shipments_rec.line_location_id
                    AND po_release_id IS NULL ;
                  END IF ;

                  IF ( PO_LOG.d_stmt) THEN
                    PO_LOG.stmt(d_module, d_progress, 'After updating the promised date ', SQL%ROWCOUNT);
                  END IF ;

                EXCEPTION WHEN No_Data_Found THEN
                  IF ( PO_LOG.d_exc) THEN
                    PO_LOG.exc(d_module, d_progress,'No lead time found.Do nothing' );
                  END IF ;

                END ;

              END IF ;
            END LOOP ;
          END IF ;
        END IF ;
      END LOOP;
    END IF;

    d_progress := 100;

  EXCEPTION WHEN OTHERS THEN

    IF ( PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;

  END update_promised_date_lead_time;


END PO_UPDATE_DATE_PKG;



/
