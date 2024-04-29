--------------------------------------------------------
--  DDL for Package Body PO_RCO_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RCO_VALIDATION_PVT" AS
/* $Header: POXVRCVB.pls 120.15.12010000.38 2014/07/24 02:46:32 mitao ship $ */
--g_pkg_name  CONSTANT     VARCHAR2(30) := 'PO_RCO_VALIDATION_PVT';
-- Read the profile option that enables/disables the debug log
-- Logging global constants
  d_package_base CONSTANT VARCHAR2(100) := po_log.get_package_base(g_pkg_name);

  c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

-- Debugging
  g_debug_stmt CONSTANT BOOLEAN := po_debug.is_debug_stmt_on;
  g_debug_unexp CONSTANT BOOLEAN := po_debug.is_debug_unexp_on;

  g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';
  g_fnd_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');


-- Initializing Private Functions/Procedures
  TYPE number_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  PROCEDURE Insert_PriceBreakRows(p_chn_grp_id IN NUMBER);

  PROCEDURE Insert_LineQuantityOrAmount(p_chn_grp_id IN NUMBER);

  PROCEDURE Validate_Quantity(p_header_id IN NUMBER,
                              p_release_id IN NUMBER,
                              p_po_change_table IN pos_chg_rec_tbl,
                              p_errortable IN OUT NOCOPY po_req_change_err_table,
                              p_error_index IN OUT NOCOPY NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_return_msg OUT NOCOPY VARCHAR2);

  PROCEDURE Decode_poerror(p_header_id IN NUMBER,
                           p_release_id IN NUMBER,
                           p_err_po_msg IN VARCHAR2,
                           p_doc_check_rec_type IN doc_check_return_type,
                           p_po_error_index IN NUMBER,
                           p_errortable IN OUT NOCOPY po_req_change_err_table,
                           p_error_index IN OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_return_msg OUT NOCOPY VARCHAR2);

  PROCEDURE insert_reqchange(p_change_table change_tbl_type,
                             p_chn_req_grp_id NUMBER);

  FUNCTION calculate_newunitprice(p_req_line_id NUMBER, p_new_price NUMBER) RETURN NUMBER;

  PROCEDURE validate_changes(p_req_hdr_id IN NUMBER,
                             p_req_change_table IN OUT NOCOPY change_tbl_type,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_retmsg OUT NOCOPY VARCHAR,
                             p_errortable IN OUT NOCOPY po_req_change_err_table);


  PROCEDURE update_recordswithtax(p_chn_req_grp_id NUMBER);

  PROCEDURE update_internalrecordswithtax(p_chn_req_grp_id NUMBER);

  PROCEDURE copy_change(p_header_id NUMBER,
                        p_release_id NUMBER,
                        p_req_hdr_id NUMBER,
                        req_change_record_tbl IN OUT NOCOPY change_tbl_type,
                        req_index IN NUMBER,
                        po_index IN NUMBER,
                        po_change_record_tbl IN OUT NOCOPY pos_chg_rec_tbl);

  PROCEDURE insert_pricebreakrows(p_chn_grp_id IN NUMBER)
  IS
  l_api_name VARCHAR2(50) := 'Insert_PriceBreakRows';
  l_progress VARCHAR2(5) := '000';

-- added for retroactive pricing checks
  l_retropricing VARCHAR2(20) := '';
  l_quantity_received NUMBER;
  l_accrue_on_receipt_flag po_line_locations_all.accrue_on_receipt_flag%TYPE;
  l_quantity_billed NUMBER;
  l_call_price_break BOOLEAN := TRUE;

  l_req_line_id NUMBER;
  l_old_date DATE;
  l_new_date DATE;
  l_old_qty NUMBER;
  l_new_qty NUMBER;
  l_new_po_qty NUMBER;
  l_old_price NUMBER;
  l_old_curr_price NUMBER;
  l_req_uom po_requisition_lines_all.unit_meas_lookup_code%TYPE;
  l_req_user_id NUMBER;
  l_document_header_id NUMBER;
  l_document_num po_change_requests.document_num%TYPE;
  l_document_revision_num NUMBER;
  l_document_line_number NUMBER;
  l_requester_id NUMBER;

  l_source_doc_header_id NUMBER;
  l_source_doc_line_num NUMBER;
  l_deliver_to_loc_id NUMBER;
  l_destination_org_id NUMBER;
  l_req_currency_code po_requisition_lines_all.currency_code%TYPE;
  l_req_rate_type po_requisition_lines_all.rate_type%TYPE;
  l_org_id NUMBER;
  l_creation_date DATE;
  l_supplier_id NUMBER;
  l_supplier_site_id NUMBER;
  l_order_header_id NUMBER;
  l_order_line_id NUMBER;
  l_line_type_id NUMBER;
  l_item_revision po_requisition_lines_all.item_revision%TYPE;
  l_item_id NUMBER;
  l_category_id NUMBER;
  l_supplier_item_num po_requisition_lines_all.supplier_ref_number%TYPE;
  l_in_price NUMBER;

-- output values
  l_new_base_unit_price NUMBER;
  l_new_price NUMBER;
  l_new_curr_price NUMBER;
  l_discount NUMBER;
  l_currency_code po_requisition_lines_all.currency_code%TYPE;
  l_rate_type po_requisition_lines_all.rate_type%TYPE;
  l_rate_date DATE;
  l_rate NUMBER;
  l_price_break_id NUMBER;

  CURSOR l_linepricebreak_csr(grp_id NUMBER) IS
  SELECT
  DISTINCT
      pcr.document_header_id,
      pcr.document_num,
      pcr.document_revision_num,
      pcr.document_line_id,
      pcr.document_line_number,
      pcr.requester_id
  FROM po_change_requests pcr,
      po_requisition_lines_all prla
  WHERE pcr.change_request_group_id = grp_id
  AND pcr.action_type = 'MODIFICATION'
  AND prla.requisition_line_id = pcr.document_line_id
  AND prla.blanket_po_header_id IS NOT NULL;

  BEGIN
    l_retropricing := fnd_profile.value('PO_ALLOW_RETROPRICING_OF_PO');

    l_req_user_id := fnd_global.user_id;

    OPEN l_linepricebreak_csr(p_chn_grp_id);
    LOOP
      FETCH l_linepricebreak_csr
      INTO
      l_document_header_id,
      l_document_num,
      l_document_revision_num,
      l_req_line_id,
      l_document_line_number,
      l_requester_id;

      EXIT WHEN l_linepricebreak_csr%notfound;
      l_progress := '001';

      SELECT
          prla.need_by_date,
          prla.unit_meas_lookup_code,
          prla.unit_price,
          prla.currency_unit_price,
          prla.blanket_po_header_id,
          prla.blanket_po_line_num,
          prla.deliver_to_location_id,
          prla.destination_organization_id,
          prla.currency_code,
          prla.rate_type,
                      prla.org_id,
          prla.vendor_id,
          prla.vendor_site_id,
          prla.creation_date,
          plla.po_header_id,
          plla.po_line_id,
                      prla.line_type_id,
          prla.item_revision,
          prla.item_id,
          prla.category_id,
          prla.supplier_ref_number,
          prla.unit_price,
          nvl(plla.quantity_received, 0),
          nvl(plla.accrue_on_receipt_flag, 'N'),
          nvl(plla.quantity_billed, 0)
      INTO
          l_old_date,
          l_req_uom,
          l_old_price,
          l_old_curr_price,
          l_source_doc_header_id,
          l_source_doc_line_num,
          l_deliver_to_loc_id,
          l_destination_org_id,
          l_req_currency_code,
          l_req_rate_type,
                      l_org_id,
          l_supplier_id,
          l_supplier_site_id,
          l_creation_date,
          l_order_header_id,
          l_order_line_id,
          l_line_type_id,
          l_item_revision,
          l_item_id,
          l_category_id,
          l_supplier_item_num,
          l_in_price,
                  l_quantity_received,
          l_accrue_on_receipt_flag,
          l_quantity_billed
      FROM
          po_requisition_lines_all prla,
          po_line_locations_all plla
      WHERE prla.requisition_line_id = l_req_line_id
                 AND prla.line_location_id = plla.line_location_id;

      BEGIN
        SELECT new_need_by_date
        INTO l_new_date
        FROM po_change_requests
        WHERE new_need_by_date IS NOT NULL
        AND change_request_group_id = p_chn_grp_id
        AND document_line_id = l_req_line_id;
      EXCEPTION WHEN OTHERS THEN
        l_new_date := l_old_date;
      END;

      l_progress := '002';

      SELECT nvl(SUM(new_quantity), 0)
      INTO l_new_qty
      FROM po_change_requests
      WHERE new_quantity IS NOT NULL
      AND change_request_group_id = p_chn_grp_id
      AND document_line_id = l_req_line_id
      AND action_type = 'MODIFICATION'
      AND request_level = 'DISTRIBUTION';

      SELECT nvl(SUM(req_line_quantity), 0)
      INTO l_old_qty
      FROM po_req_distributions_all
      WHERE requisition_line_id = l_req_line_id
      AND distribution_id NOT IN(SELECT document_distribution_id
                                  FROM po_change_requests
                                  WHERE new_quantity IS NOT NULL
                                  AND change_request_group_id = p_chn_grp_id
                                  AND document_line_id = l_req_line_id
                                  AND action_type = 'MODIFICATION'
                                  AND request_level = 'DISTRIBUTION');

      l_new_qty := l_new_qty + l_old_qty;

      l_progress := '003';

      IF (l_retropricing = 'ALL_RELEASES') THEN
        l_call_price_break := TRUE;
      ELSE
        IF ((l_quantity_received > 0 AND
             l_accrue_on_receipt_flag = 'Y') OR
            (l_quantity_billed > 0)) THEN
          l_call_price_break := FALSE;
        END IF;
      END IF;


      IF (l_call_price_break) THEN

        po_price_break_grp.get_price_break (
                                            p_source_document_header_id => l_source_doc_header_id,
                                            p_source_document_line_num  => l_source_doc_line_num,
                                            p_in_quantity => l_new_qty,
                                            p_unit_of_measure => l_req_uom,
                                            p_deliver_to_location_id => l_deliver_to_loc_id,
                                            p_required_currency  => l_req_currency_code,
                                            p_required_rate_type => l_req_rate_type,
                                            p_need_by_date => l_new_date,
                                            p_destination_org_id => l_destination_org_id,
                                            p_org_id => l_org_id,
                                            p_supplier_id => l_supplier_id,
                                            p_supplier_site_id => l_supplier_site_id,
                                            p_creation_date => l_creation_date,
                                            p_order_header_id => l_order_header_id,
                                            p_order_line_id => l_order_line_id,
                                            p_line_type_id => l_line_type_id,
                                            p_item_revision => l_item_revision,
                                            p_item_id => l_item_id,
                                            p_category_id => l_category_id,
                                            p_supplier_item_num => l_supplier_item_num,
                                            p_in_price => l_in_price,
					        --Below is OUTPUT
                                            x_base_unit_price => l_new_base_unit_price,
                                            x_base_price => l_new_price,
                                            x_currency_price => l_new_curr_price,
                                            x_discount => l_discount,
                                            x_currency_code => l_currency_code,
                                            x_rate_type => l_rate_type,
                                            x_rate_date => l_rate_date,
                                            x_rate => l_rate,
                                            x_price_break_id => l_price_break_id);

        IF (g_fnd_debug = 'Y') THEN
          IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
            fnd_log.string(fnd_log.level_statement, g_module_prefix ||
                           l_api_name, 'New Base Unit Price:' || to_char(l_new_base_unit_price) || ' New Price:' || to_char(l_new_price) || ' New Cur Unit Price:' || to_char(l_new_curr_price));
          END IF;
        END IF;

        IF(l_new_price <> l_old_price) THEN
          l_progress := '004';
          IF(l_old_curr_price IS NULL) THEN
            l_new_curr_price := NULL;
          END IF;
          INSERT INTO po_change_requests
          (
              change_request_group_id,
              change_request_id,
              initiator,
              action_type,
              request_level,
              request_status,
              document_type,
              document_header_id,
              document_num,
              document_revision_num,
              created_by,
              creation_date,
              document_line_id,
              document_line_number,
              old_price,
              new_price,
              old_currency_unit_price,
              new_currency_unit_price,
              last_updated_by,
              last_update_date,
              last_update_login,
              requester_id,
              change_active_flag)
          VALUES
          (
              p_chn_grp_id,
              po_chg_request_seq.nextval,
              'REQUESTER',
              'DERIVED',
              'LINE',
              'SYSTEMSAVE',
              'REQ',
              l_document_header_id,
              l_document_num,
              l_document_revision_num,
              l_req_user_id,
              SYSDATE,
              l_req_line_id,
              l_document_line_number,
              l_old_price,
              l_new_price,
              l_old_curr_price,
              l_new_curr_price,
              l_req_user_id,
              SYSDATE,
              l_req_user_id,
              l_requester_id,
              'Y'
          );

        END IF;

      END IF;  -- if for l_call_price_break check

    END LOOP;
    CLOSE l_linepricebreak_csr;

  EXCEPTION WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', l_progress || ':' || SQLERRM);
      END IF;
    END IF;
    RAISE;

  END insert_pricebreakrows;


-- Inserts Derived Row for Line level Quantity or Amount changes

  PROCEDURE insert_linequantityoramount(p_chn_grp_id IN NUMBER)
  IS
  l_api_name VARCHAR2(50) := 'Insert_LineQuantityOrAmount';
  l_progress VARCHAR2(5) := '000';
  l_line_id NUMBER;
  l_line_num NUMBER;
  l_id NUMBER;
  l_old_quantity NUMBER;
  l_new_quantity NUMBER;
  l_req_user_id NUMBER;
  l_req_header_id NUMBER;
  l_req_num po_requisition_headers_all.segment1%TYPE;
  l_requester_id NUMBER;
  l_matching_basis po_requisition_lines_all.matching_basis%TYPE;
  l_old_amount NUMBER;
  l_new_amount NUMBER;
  l_old_cur_amount NUMBER;
  l_new_cur_amount NUMBER;

  CURSOR l_line_csr(grp_id NUMBER) IS
  SELECT DISTINCT
  document_header_id,
  document_num,
  document_line_id,
  document_line_number,
  requester_id
  FROM po_change_requests
  WHERE action_type = 'MODIFICATION'
  AND change_request_group_id = grp_id;

  CURSOR l_line_qty_chn_csr(line_id NUMBER, grp_id NUMBER) IS
  SELECT change_request_id
  FROM po_change_requests
  WHERE document_line_id = line_id
  AND change_request_group_id = grp_id
  AND new_quantity IS NOT NULL
  AND request_level = 'DISTRIBUTION';

  CURSOR l_line_amt_chn_csr(line_id NUMBER, grp_id NUMBER) IS
  SELECT change_request_id
  FROM po_change_requests
  WHERE document_line_id = line_id
  AND change_request_group_id = grp_id
  AND new_amount IS NOT NULL
  AND request_level = 'DISTRIBUTION';

  BEGIN
    l_req_user_id := fnd_global.user_id;

    OPEN l_line_csr(p_chn_grp_id);
    LOOP
      FETCH l_line_csr INTO
      l_req_header_id,
      l_req_num,
      l_line_id,
      l_line_num,
      l_requester_id;
      EXIT WHEN l_line_csr%notfound;
      l_progress := '001';

      SELECT matching_basis, quantity, amount, currency_amount
      INTO l_matching_basis, l_old_quantity, l_old_amount, l_old_cur_amount
      FROM po_requisition_lines_all
      WHERE requisition_line_id = l_line_id;

              -- handle amount based lines
      IF (l_matching_basis = 'AMOUNT') THEN
        OPEN l_line_amt_chn_csr(l_line_id, p_chn_grp_id);
        FETCH l_line_amt_chn_csr INTO l_id;
        CLOSE l_line_amt_chn_csr;

        l_progress := '002';

        IF(l_id > 0) THEN

          l_progress := '003';
          SELECT SUM(amount)
          INTO l_new_amount
          FROM (
              SELECT new_amount amount
              FROM po_change_requests
              WHERE change_request_group_id = p_chn_grp_id
              AND document_line_id = l_line_id
              AND new_amount IS NOT NULL
              AND request_level = 'DISTRIBUTION'
              UNION ALL
              SELECT req_line_amount amount
              FROM po_req_distributions_all
              WHERE requisition_line_id = l_line_id
              AND distribution_id NOT IN
                  (SELECT document_distribution_id
                  FROM po_change_requests
                  WHERE change_request_group_id = p_chn_grp_id
                  AND document_line_id = l_line_id
                  AND new_amount IS NOT NULL
                  AND request_level = 'DISTRIBUTION')
              );

          SELECT SUM(amount)
          INTO l_new_cur_amount
          FROM (
              SELECT new_currency_amount amount
              FROM po_change_requests
              WHERE change_request_group_id = p_chn_grp_id
              AND document_line_id = l_line_id
              AND new_currency_amount IS NOT NULL
              AND request_level = 'DISTRIBUTION'
              UNION ALL
              SELECT req_line_currency_amount amount
              FROM po_req_distributions_all
              WHERE requisition_line_id = l_line_id
              AND distribution_id NOT IN
                  (SELECT document_distribution_id
                  FROM po_change_requests
                  WHERE change_request_group_id = p_chn_grp_id
                  AND document_line_id = l_line_id
                  AND new_currency_amount IS NOT NULL
                  AND request_level = 'DISTRIBUTION')
              );

        ELSE
          l_new_amount := NULL;
          l_new_cur_amount := NULL;
        END IF;



      ELSE  -- handle quantity based lines
        OPEN l_line_qty_chn_csr(l_line_id, p_chn_grp_id);
        FETCH l_line_qty_chn_csr INTO l_id;
        CLOSE l_line_qty_chn_csr;

        l_progress := '002';

        IF(l_id > 0) THEN

          l_progress := '003';
          SELECT SUM(quantity)
          INTO l_new_quantity
          FROM (
              SELECT new_quantity quantity
              FROM po_change_requests
              WHERE change_request_group_id = p_chn_grp_id
              AND document_line_id = l_line_id
              AND new_quantity IS NOT NULL
              AND request_level = 'DISTRIBUTION'
              UNION ALL
              SELECT req_line_quantity quantity
              FROM po_req_distributions_all
              WHERE requisition_line_id = l_line_id
              AND distribution_id NOT IN
                  (SELECT document_distribution_id
                  FROM po_change_requests
                  WHERE change_request_group_id = p_chn_grp_id
                  AND document_line_id = l_line_id
                  AND new_quantity IS NOT NULL
                  AND request_level = 'DISTRIBUTION')
              );
        ELSE
          l_new_quantity := NULL;
        END IF;

      END IF;

      l_progress := '004';

      INSERT INTO po_change_requests
      (
          change_request_group_id,
          change_request_id,
          initiator,
          action_type,
          request_level,
          request_status,
          document_type,
          document_header_id,
          document_num,
          created_by,
          creation_date,
          document_line_id,
          document_line_number,
          old_quantity,
          new_quantity,
                      old_amount,
                      new_amount,
                      old_currency_amount,
                      new_currency_amount,
          last_updated_by,
          last_update_date,
          last_update_login,
          requester_id,
          change_active_flag)
      VALUES
      (
          p_chn_grp_id,
          po_chg_request_seq.nextval,
          'REQUESTER',
          'DERIVED',
          'LINE',
          'SYSTEMSAVE',
          'REQ',
          l_req_header_id,
          l_req_num,
          l_req_user_id,
          SYSDATE,
          l_line_id,
          l_line_num,
          l_old_quantity,
          l_new_quantity,
                      l_old_amount,
                      l_new_amount,
                      l_old_cur_amount,
                      l_new_cur_amount,
          l_req_user_id,
          SYSDATE,
          l_req_user_id,
          l_requester_id,
          'Y'
      );

    END LOOP;
    CLOSE l_line_csr;
  EXCEPTION WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', l_progress || ':' || SQLERRM);
      END IF;
    END IF;
    RAISE;

  END insert_linequantityoramount;

  PROCEDURE validate_quantity(p_header_id IN NUMBER,
                              p_release_id IN NUMBER,
                              p_po_change_table IN pos_chg_rec_tbl,
                              p_errortable IN OUT NOCOPY po_req_change_err_table,
                              p_error_index IN OUT NOCOPY NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_return_msg OUT NOCOPY VARCHAR2)
  IS
  l_api_name VARCHAR2(50) := 'Validate_quantity';
  l_err_req_line_id NUMBER;
  l_err_req_dist_id NUMBER;
  l_err_req_line_num NUMBER;
  l_err_req_dist_num NUMBER;
  l_err_po_msg VARCHAR2(2000);
  l_err_billed_qty NUMBER;
  l_err_new_qty NUMBER;
  l_err_delivered_qty NUMBER;
  l_qty_old_rec NUMBER;
  l_qty_old_del NUMBER;
  l_qty_old_bill NUMBER;
  l_qty_new_rec NUMBER;
  BEGIN
    x_return_msg := 'VQ001';

    FOR s IN 1..p_po_change_table.count
      LOOP

      IF(p_po_change_table(s).new_quantity IS NOT NULL) THEN

        x_return_msg := 'VQ002';
        /*  SELECT
            quantity_delivered,
            quantity_billed
        INTO
            l_qty_old_del,
            l_qty_old_bill
        FROM po_distributions_all
        WHERE po_distribution_id = p_po_change_table(s).document_distribution_id;
         */
 	                 -- Code commented and new code added for bug 7138977
 	                      select
 	                          dist.quantity_delivered * Decode(line.ORDER_TYPE_LOOKUP_CODE,'AMOUNT', Nvl(dist.rate,1),1), dist.quantity_billed  * Decode(line.ORDER_TYPE_LOOKUP_CODE,'AMOUNT', Nvl(dist.rate,1),1)
 	                      into
 	                                  l_qty_old_del,
 	                          l_qty_old_bill
 	                       from po_distributions_all dist, po_lines_all line
 	                      where  dist.po_line_id = line.po_line_id AND
 	                          dist.po_distribution_id = p_po_change_table(s).document_distribution_id;

 	               IF (g_fnd_debug = 'Y') THEN
 	                 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
 	                     FND_LOG.string(FND_LOG.level_statement, g_module_prefix ||
 	                     l_api_name, 'quantity_delivered : '||l_qty_old_del||', quantity_billed : '||l_qty_old_bill||', new_qty : '||p_po_change_table(s).new_quantity);
 	                 END IF;
 	               END IF;

        IF(l_qty_old_del > p_po_change_table(s).new_quantity OR
           l_qty_old_bill > p_po_change_table(s).new_quantity) THEN

          x_return_msg := 'VQ003:' || p_release_id || '*' || p_po_change_table(s).document_line_location_id ||
          '*' || p_po_change_table(s).document_distribution_id;
          IF(p_release_id IS NULL) THEN
            SELECT
                prla.line_num,
                prda.distribution_num,
                prla.requisition_line_id,
                prda.distribution_id
            INTO
                l_err_req_line_num,
                l_err_req_dist_num,
                l_err_req_line_id,
                l_err_req_dist_id
            FROM
                po_lines_all pla,
                po_line_locations_all plla,
                po_distributions_all pda,
                po_requisition_lines_all prla,
                po_req_distributions_all prda
            WHERE
                pla.po_header_id = p_header_id
                AND pla.po_line_id = p_po_change_table(s).document_line_id
                AND plla.po_line_id = pla.po_line_id
                AND plla.line_location_id = p_po_change_table(s).document_line_location_id
                AND pda.line_location_id = plla.line_location_id
                AND pda.po_distribution_id = p_po_change_table(s).document_distribution_id
                AND pda.req_distribution_id = prda.distribution_id
                AND prda.requisition_line_id = prla.requisition_line_id;

          ELSE
            SELECT
                prla.line_num,
                prda.distribution_num,
                prla.requisition_line_id,
                prda.distribution_id
            INTO
                l_err_req_line_num,
                l_err_req_dist_num,
                l_err_req_line_id,
                l_err_req_dist_id
            FROM
                po_line_locations_all plla,
                po_distributions_all pda,
                po_requisition_lines_all prla,
                po_req_distributions_all prda
            WHERE
                plla.po_release_id = p_release_id
                AND plla.line_location_id = p_po_change_table(s).document_line_location_id
                AND pda.line_location_id = plla.line_location_id
                AND pda.po_distribution_id = p_po_change_table(s).document_distribution_id
                AND pda.req_distribution_id = prda.distribution_id
                AND prda.requisition_line_id = prla.requisition_line_id;

          END IF;
          x_return_msg := 'VQ0031';
          p_errortable.msg_data.extend(1);
          p_errortable.req_line_id.extend(1);
          p_errortable.req_dist_id.extend(1);
          p_errortable.msg_count.extend(1);
          p_errortable.err_attribute.extend(1);

          p_errortable.req_line_id(p_error_index) := l_err_req_line_id;
          p_errortable.req_dist_id(p_error_index) := l_err_req_dist_id;
          fnd_message.set_name('PO', 'PO_RCO_NEW_QTY_BELOW_BILL_DEL');
          fnd_message.set_token('LINE_NUM', l_err_req_line_num);
          fnd_message.set_token('DIST_NUM', l_err_req_dist_num);
          p_errortable.msg_data(p_error_index) := fnd_message.get;
          p_errortable.msg_count(p_error_index) := 1;
          p_errortable.err_attribute(p_error_index) := 'QUANTITY';

          p_error_index := p_error_index + 1;
        END IF;
        x_return_msg := 'VQ004';
        SELECT plla.quantity_received
        INTO l_qty_old_rec
        FROM
            po_line_locations_all plla,
            po_distributions_all pda
        WHERE plla.line_location_id = pda.line_location_id
        AND pda.po_distribution_id = p_po_change_table(s).document_distribution_id;

        x_return_msg := 'VQ005';

        SELECT SUM(plla.quantity_received) + p_po_change_table(s).new_quantity
        INTO l_qty_new_rec
        FROM
            po_line_locations_all plla,
            po_distributions_all pda1,
            po_distributions_all pda2
        WHERE plla.line_location_id = pda1.line_location_id
        AND pda1.po_distribution_id <> p_po_change_table(s).document_distribution_id
        AND pda1.line_location_id = pda2.line_location_id
        AND pda2.po_distribution_id = p_po_change_table(s).document_distribution_id;




        IF(l_qty_old_rec > l_qty_new_rec) THEN
          x_return_msg := 'VQ006';
          IF(p_release_id IS NULL) THEN
            SELECT
                prla.line_num,
                prda.distribution_num,
                prla.requisition_line_id,
                prda.distribution_id
            INTO
                l_err_req_line_num,
                l_err_req_dist_num,
                l_err_req_line_id,
                l_err_req_dist_id
            FROM
                po_lines_all pla,
                po_line_locations_all plla,
                po_distributions_all pda,
                po_requisition_lines_all prla,
                po_req_distributions_all prda
            WHERE
                pla.po_header_id = p_header_id
                AND pla.po_line_id = p_po_change_table(s).document_line_id
                AND plla.po_line_id = pla.po_line_id
                AND plla.line_location_id = p_po_change_table(s).document_line_location_id
                AND pda.line_location_id = plla.line_location_id
                AND pda.po_distribution_id = p_po_change_table(s).document_distribution_id
                AND pda.req_distribution_id = prda.distribution_id
                AND prda.requisition_line_id = prla.requisition_line_id;

          ELSE
            SELECT
                prla.line_num,
                prda.distribution_num,
                prla.requisition_line_id,
                prda.distribution_id
            INTO
                l_err_req_line_num,
                l_err_req_dist_num,
                l_err_req_line_id,
                l_err_req_dist_id
            FROM
                po_line_locations_all plla,
                po_distributions_all pda,
                po_requisition_lines_all prla,
                po_req_distributions_all prda
            WHERE
                plla.po_release_id = p_release_id
                AND plla.line_location_id = p_po_change_table(s).document_line_location_id
                AND pda.line_location_id = plla.line_location_id
                AND pda.po_distribution_id = p_po_change_table(s).document_distribution_id
                AND pda.req_distribution_id = prda.distribution_id
                AND prda.requisition_line_id = prla.requisition_line_id;

          END IF;
          p_errortable.msg_data.extend(1);
          p_errortable.req_line_id.extend(1);
          p_errortable.req_dist_id.extend(1);
          p_errortable.msg_count.extend(1);
          p_errortable.err_attribute.extend(1);

          p_errortable.req_line_id(p_error_index) := l_err_req_line_id;
          p_errortable.req_dist_id(p_error_index) := l_err_req_dist_id;
          fnd_message.set_name('PO', 'PO_RCO_NEW_QTY_BELOW_REC');
          fnd_message.set_token('LINE_NUM', l_err_req_line_num);
          fnd_message.set_token('DIST_NUM', l_err_req_dist_num);
          p_errortable.msg_data(p_error_index) := fnd_message.get;
          p_errortable.msg_count(p_error_index) := 1;
          p_errortable.err_attribute(p_error_index) := 'QUANTITY';

          p_error_index := p_error_index + 1;

        END IF;
      END IF;
    END LOOP;
  EXCEPTION WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', x_return_msg || ':' || SQLERRM);
      END IF;
    END IF;
    RAISE;
  END validate_quantity;


  PROCEDURE decode_poerror(p_header_id IN NUMBER,
                           p_release_id IN NUMBER,
                           p_err_po_msg IN VARCHAR2,
                           p_doc_check_rec_type IN doc_check_return_type,
                           p_po_error_index IN NUMBER,
                           p_errortable IN OUT NOCOPY po_req_change_err_table,
                           p_error_index IN OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_return_msg OUT NOCOPY VARCHAR2)
  IS
  l_api_name VARCHAR2(50) := 'decode_POError';
  l_progress VARCHAR2(5) := '000';
  l_blanket_num po_headers_all.segment1%TYPE;
  l_po_num po_headers_all.segment1%TYPE;
  l_release_num NUMBER;
  l_type_lookup_code po_headers_all.type_lookup_code%TYPE;
  l_doc_type VARCHAR2(2000);
  l_doc_num po_headers_all.segment1%TYPE;
  l_err_po_line_num NUMBER;
  l_vdr_cntct_id po_vendor_contacts.vendor_contact_id%TYPE;
  l_buyer_id po_headers_all.agent_id%TYPE;
  l_vdr_cntct_name varchar2(25);
  l_buyer_name po_buyers_v.full_name%TYPE;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    l_err_po_line_num := p_doc_check_rec_type.line_num(p_po_error_index);

    IF(p_release_id IS NULL) THEN
      SELECT
          segment1,
          type_lookup_code,
		  vendor_contact_id,
		  agent_id
      INTO
          l_po_num,
          l_type_lookup_code,
		  l_vdr_cntct_id,
		  l_buyer_id
      FROM po_headers_all
      WHERE po_header_id = p_header_id;

      IF(l_type_lookup_code = 'STANDARD') THEN
        l_doc_type := fnd_message.get_string('PO', 'PO_WF_NOTIF_STD_PO');
      ELSIF(l_type_lookup_code = 'PLANNED') THEN
        l_doc_type := fnd_message.get_string('PO', 'PO_WF_NOTIF_PLAN_PO');
      ELSIF(l_type_lookup_code = 'BLANKET') THEN
        l_doc_type := fnd_message.get_string('PO', 'PO_WF_NOTIF_BLANKET');
      END IF;

      l_doc_num := l_po_num;
    ELSE
      SELECT
          pha.segment1,
		  pha.vendor_contact_id,
		  pha.agent_id,
          pra.release_num,
          pha.type_lookup_code
      INTO
          l_blanket_num,
		  l_vdr_cntct_id,
		  l_buyer_id,
          l_release_num,
          l_type_lookup_code
      FROM po_headers_all pha,
          po_releases_all pra
      WHERE pra.po_release_id = p_release_id
      AND pra.po_header_id = pha.po_header_id;

      IF(l_type_lookup_code = 'BLANKET') THEN
        l_doc_type := fnd_message.get_string('PO', 'PO_WF_NOTIF_BKT_REL');
      ELSIF(l_type_lookup_code = 'PLANNED') THEN
        l_doc_type := fnd_message.get_string('PO', 'PO_WF_NOTIF_SCH_REL');
      END IF;

      l_doc_num := l_blanket_num || '-' || l_release_num;
    END IF;

    l_progress := '001';

    IF(p_err_po_msg = 'PO_SUB_REL_AMT_GRT_LIMIT_AMT') THEN
		/*PO_RCO_REL_AMT_EXC_LIMIT:
		Changes entered cause the amount being released plus the amount release to date to be
		greater than the amount limit for Release BLANKET_NUM - RELEASE_NUM.*/


      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_REL_AMT_EXC_LIMIT');
      fnd_message.set_token('BLANKET_NUM', l_blanket_num);
      fnd_message.set_token('RELEASE_NUM', l_release_num);

      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;

    ELSIF(p_err_po_msg = 'PO_SUB_REL_AMT_LESS_MINREL_AMT') THEN
		/*PO_RCO_REL_AMT_BELOW_MIN: Changes entered cause the amount being released
		plus the amount release to date to be less than the Min Release Amount for
		Release BLANKET_NUM - RELEASE_NUM*/


      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_REL_AMT_BELOW_MIN');
      fnd_message.set_token('BLANKET_NUM', l_blanket_num);
      fnd_message.set_token('RELEASE_NUM', l_release_num);

      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;


    ELSIF(p_err_po_msg = 'PO_SUB_REL_SHIPAMT_LESS_MINREL') THEN
		/*PO_RCO_REL_LINE_BELOW_MIN: Changes entered cause release line total to be
		less than the agreement limit for line LINE_NUM on Release BLANKET_NUM - RELEASE_NUM.*/


      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_REL_LINE_BELOW_MIN');
      fnd_message.set_token('BLANKET_NUM', l_blanket_num);
      fnd_message.set_token('RELEASE_NUM', l_release_num);
      fnd_message.set_token('LINE_NUM', l_err_po_line_num);

      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;


    ELSIF(p_err_po_msg = 'PO_SUB_REL_RATE_NULL') THEN
		/*PO_RCO_REL_NO_EXCH: No exchange rate conversion information is available for
		Release BLANKET_NUM - RELEASE_NUM your selected currency.
		Please contact your Purchasing department for assistance.*/


      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_REL_NO_EXCH');
      fnd_message.set_token('BLANKET_NUM', l_blanket_num);
      fnd_message.set_token('RELEASE_NUM', l_release_num);

      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;


    ELSIF(p_err_po_msg = 'PO_SUB_DIST_RATE_NULL') THEN
		--PO_RCO_DIST_NO_EXCH: No exchange rate conversion information is available for DOC_TYPE DOC_NUM line LINE_NUM for your selected currency. Please contact your Purchasing department for assistance.


      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_DIST_NO_EXCH');
      fnd_message.set_token('DOC_TYPE', l_doc_type);
      fnd_message.set_token('DOC_NUM', l_doc_num);
      fnd_message.set_token('LINE_NUM', l_err_po_line_num);


      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;


    ELSIF(p_err_po_msg = 'PO_SUB_STD_GA_LINE_LESS_MINREL') THEN
		/*PO_RCO_STD_LINE_BELOW_MIN: Changes entered cause the line total to be
		less than the minimum release amount for line LINE_NUM on Purchase Order PO_NUM.*/


      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_STD_LINE_BELOW_MIN');
      fnd_message.set_token('PO_NUM', l_po_num);
      fnd_message.set_token('LINE_NUM', l_err_po_line_num);


      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;


    ELSIF(p_err_po_msg = 'PO_SUB_REQ_AMT_TOL_EXCEED') THEN
		/*PO_RCO_AMT_EXC_TOL_MIN: Changes entered cause the total amount to
		exceed the amount tolerance limit for DOC_TYPE DOC_NUM.*/


      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_AMT_EXC_TOL_MIN');
      fnd_message.set_token('DOC_TYPE', l_doc_type);
      fnd_message.set_token('DOC_NUM', l_doc_num);


      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;


    ELSIF(p_err_po_msg = 'PO_SUB_REQ_PRICE_TOL_EXCEED') THEN
		/*PO_RCO_LINE_PRICE_ECX_TOL: Changes entered cause the line price to
		exceed the price tolerance limit for LINE_NUM on DOC_TYPE DOC_NUM.*/


      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_LINE_PRICE_ECX_TOL');
      fnd_message.set_token('DOC_TYPE', l_doc_type);
      fnd_message.set_token('DOC_NUM', l_doc_num);
      fnd_message.set_token('LINE_NUM', l_err_po_line_num);


      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;



    ELSIF(p_err_po_msg = 'PO_SUB_STD_AMT_GRT_GA_AMT_LMT') THEN
		/*PO_RCO_STD_AMT_EXC_LIMIT: Changes entered cause the amount being released
		plus the amount release to date to be
		greater than the amount limit for Purchase Order PO_NUM.*/



      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_STD_AMT_EXC_LIMIT');
      fnd_message.set_token('PO_NUM', l_po_num);

      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;


    ELSIF(p_err_po_msg = 'PO_SUB_STD_GA_PRICE_MISMATCH') THEN
		/*PO_RCO_STD_PRICE_EXC_TOL: Changes entered cause the line price to
		exceed the price override tolerance limit for LINE_NUM on Purchase Order PO_NUM.*/

      p_errortable.msg_data.extend(1);
      p_errortable.req_line_id.extend(1);
      p_errortable.req_dist_id.extend(1);
      p_errortable.msg_count.extend(1);
      p_errortable.err_attribute.extend(1);

      fnd_message.set_name('PO', 'PO_RCO_STD_PRICE_EXC_TOL');
      fnd_message.set_token('PO_NUM', l_po_num);
      fnd_message.set_token('LINE_NUM', l_err_po_line_num);

      p_errortable.msg_data(p_error_index) := fnd_message.get;
      p_errortable.msg_count(p_error_index) := 1;
      p_error_index := p_error_index + 1;

	ELSIF(p_err_po_msg = 'PO_PDOI_INVALID_VDR_CNTCT') then
	  /*PO_RCO_INVALID_VDR_CNTCT: You cannot request a change on this Requisition because
	    the Supplier Contact NAME specified on associated Purchase Order PO_NUM is invalid.
	    Please request the Buyer BUYER to create a revision on the PO specifying a valid Contact.*/

	  SELECT 	first_name||', '||last_name into l_vdr_cntct_name
	  FROM 	po_vendor_contacts
	  WHERE 	vendor_contact_id = l_vdr_cntct_id and ROWNUM = 1;

	  SELECT 	full_name into l_buyer_name
	  FROM 	po_buyers_v
	  WHERE 	employee_id = l_buyer_id;

	  p_errorTable.msg_data.extend(1);
	  p_errorTable.req_line_id.extend(1);
	  p_errorTable.req_dist_id.extend(1);
	  p_errorTable.msg_count.extend(1);
	  p_errorTable.err_attribute.extend(1);

	  fnd_message.set_name('PO','PO_RCO_INVALID_VDR_CNTCT');
	  fnd_message.set_token('NAME',l_vdr_cntct_name);
	  fnd_message.set_token('PO_NUM',l_po_num);
	  fnd_message.set_token('BUYER',l_buyer_name);

	  p_errorTable.msg_data(p_error_index) := fnd_message.get;
	  p_errorTable.msg_count(p_error_index) := 1;
	  p_error_index := p_error_index + 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception',
                       p_header_id || '*' || p_release_id || '*' || p_err_po_msg || ':' || SQLERRM);
      END IF;
    END IF;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_return_msg := 'DPE_UNEXP:' || p_header_id || '*' || p_release_id || '*' || p_err_po_msg || '*' || l_progress || ':' || SQLERRM;
  END decode_poerror;

/*
*Given a particular ReqLine_id, and a new transactional price, we will return
*the new functionally currency price.
*/
  FUNCTION calculate_newunitprice(p_req_line_id NUMBER, p_new_price NUMBER) RETURN NUMBER
  IS
  l_transaction_currency po_requisition_lines_all.currency_code%TYPE;
  l_functional_currency gl_sets_of_books.currency_code%TYPE;
  l_rate_type po_requisition_lines_all.rate_type%TYPE;
  l_conversion_date DATE;
  l_rate NUMBER;
  l_unit_price NUMBER;
  l_denominator NUMBER;
  l_numerator NUMBER;
  l_set_of_books_id NUMBER;
  l_gl_rate NUMBER;

  BEGIN

    SELECT 	currency_code
    INTO 	l_transaction_currency
    FROM 	po_requisition_lines_all
    WHERE	requisition_line_id = p_req_line_id ;

    SELECT 	currency_code, fsp.set_of_books_id
    INTO 	l_functional_currency, l_set_of_books_id
    FROM
            gl_sets_of_books gsob,
            financials_system_parameters fsp
    WHERE	fsp.set_of_books_id = gsob.set_of_books_id;

    IF(l_transaction_currency <> l_functional_currency) THEN
      SELECT nvl(rate_type,' ')
      INTO l_rate_type
      FROM po_requisition_lines_all
      WHERE requisition_line_id = p_req_line_id;

      IF(l_rate_type <> 'User') THEN
        SELECT 	rate_date
        INTO 	l_conversion_date
        FROM 	po_requisition_lines_all
        WHERE requisition_line_id = p_req_line_id;

        gl_currency_api.get_triangulation_rate(l_set_of_books_id,
                                               l_transaction_currency,
                                               l_conversion_date,
                                               l_rate_type,
                                               l_denominator,
                                               l_numerator,
                                               l_gl_rate);


        l_unit_price :=
        (p_new_price / l_denominator) * l_numerator;
      ELSE
        SELECT rate
        INTO l_rate
        FROM po_requisition_lines_all
        WHERE requisition_line_id = p_req_line_id;

        l_unit_price := p_new_price *  l_rate;
      END IF;
    ELSE
      l_unit_price := NULL;
    END IF;
    RETURN l_unit_price;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END calculate_newunitprice;

  PROCEDURE generate_po_change_table(p_po_change_table IN OUT NOCOPY pos_chg_rec_tbl,
                                     p_progress OUT NOCOPY VARCHAR) IS
  l_shipment_index number_tbl;
  l_last NUMBER := 1;
  i NUMBER := 1;
  l_po_change_table_count NUMBER;
  l_po_tbl_index NUMBER;
  l_ship_quantity NUMBER;
  l_ship_to_location_id NUMBER;
  l_ship_to_organization_id NUMBER;
  l_need_by_date DATE;

  BEGIN

    l_po_change_table_count := p_po_change_table.count + 1;
    p_progress := 'G1' || to_char(l_po_change_table_count);
    WHILE (i<l_po_change_table_count) LOOP
      p_progress := 'G1' || to_char(l_po_change_table_count) ||' '|| to_char(i);
      IF(p_po_change_table(i).request_level = 'SHIPMENT') THEN
        l_shipment_index(p_po_change_table(i).document_line_location_id) := i;
      END IF;
      i := i + 1;
    END LOOP;
    i := 1;
    l_po_tbl_index := l_po_change_table_count;
    p_progress := 'G2' || to_char(l_po_change_table_count);
    WHILE (i<l_po_change_table_count) LOOP
      p_progress := 'G2' || to_char(l_po_change_table_count) ||' '|| to_char(i);
      IF(p_po_change_table(i).request_level = 'DISTRIBUTION') THEN
        IF(l_shipment_index.exists(p_po_change_table(i).document_line_location_id)) THEN
          p_po_change_table(l_shipment_index(p_po_change_table(i).
                                             document_line_location_id)).new_quantity
          := nvl(p_po_change_table(l_shipment_index(p_po_change_table(i).
                                                    document_line_location_id)).new_quantity,
                 p_po_change_table(l_shipment_index(p_po_change_table(i).
                                                    document_line_location_id)).old_quantity) +
          p_po_change_table(i).new_quantity - p_po_change_table(i).old_quantity;
        ELSE
          p_progress := 'G2' || to_char(l_po_change_table_count) ||' '|| to_char(i) ||' '|| to_char(p_po_change_table(i).document_line_location_id);
          p_po_change_table.extend(1);
          l_shipment_index(p_po_change_table(i).document_line_location_id) := l_po_tbl_index;
          p_progress := 'G2-1' || to_char(l_po_change_table_count) ||' '|| to_char(i) ||' '|| to_char(p_po_change_table(i).document_line_location_id);

          SELECT quantity,
                 ship_to_location_id,
                 ship_to_organization_id,
                 need_by_date
          INTO l_ship_quantity,
               l_ship_to_location_id,
               l_ship_to_organization_id,
               l_need_by_date
          FROM po_line_locations_all
          WHERE line_location_id = p_po_change_table(i).document_line_location_id;

          p_progress := 'G2-2' || to_char(l_po_change_table_count) ||' '|| to_char(i) ||' '|| to_char(p_po_change_table(i).document_line_location_id);
          p_po_change_table(l_po_tbl_index) := po_chg_request_pvt.create_pos_change_rec(
                                                                                        p_action_type         => 'MODIFICATION',
                                                                                        p_initiator           => 'REQUESTER',
                                                                                        p_document_type       => p_po_change_table(i).document_type,
                                                                                        p_request_level       => 'SHIPMENT',
                                                                                        p_request_status      => 'PENDING',
                                                                                        p_document_header_id  => p_po_change_table(i).document_header_id,
                                                                                        p_request_reason      => 'aa',
                                                                                        p_po_release_id       => p_po_change_table(i).po_release_id,
                                                                                        p_document_num        => p_po_change_table(i).document_num,
                                                                                        p_document_revision_num => p_po_change_table(i).document_revision_num,
                                                                                        p_document_line_id    => p_po_change_table(i).document_line_id,
                                                                                        p_document_line_number => p_po_change_table(i).document_line_number,
                                                                                        p_document_line_location_id   => p_po_change_table(i).document_line_location_id,
                                                                                        p_document_shipment_number    => p_po_change_table(i).document_shipment_number,
                                                                                        p_document_distribution_id    => NULL,
                                                                                        p_document_distribution_number => NULL,
                                                                                        p_parent_line_location_id     => NULL, --NUMBER,
                                                                                        p_old_quantity        => l_ship_quantity, --NUMBER,
                                                                                        p_new_quantity        => l_ship_quantity + p_po_change_table(i).new_quantity - p_po_change_table(i).old_quantity,
                                                                                        p_old_promised_date   => NULL, --DATE,
                                                                                        p_new_promised_date   => NULL, --DATE,
                                                                                        p_old_supplier_part_number        => NULL, --VARCHAR2(25),
                                                                                        p_new_supplier_part_number        => NULL, --VARCHAR2(25),
                                                                                        p_old_price           => NULL,
                                                                                        p_new_price           => NULL,
                                                                                        p_old_supplier_reference_num   => NULL, --VARCHAR2(30),
                                                                                        p_new_supplier_reference_num   => NULL,
                                                                                        p_from_header_id      => NULL, --NUMBER
                                                                                        p_recoverable_tax     => NULL, --NUMBER
                                                                                        p_non_recoverable_tax => NULL, --NUMBER
                                                                                        p_ship_to_location_id => l_ship_to_location_id,
                                                                                        p_ship_to_organization_id => l_ship_to_organization_id ,
                                                                                        p_old_need_by_date    => l_need_by_date,
                                                                                        p_new_need_by_date    => NULL,
                                                                                        p_approval_required_flag          => NULL,
                                                                                        p_parent_change_request_id        => NULL,
                                                                                        p_requester_id        => NULL,
                                                                                        p_old_supplier_order_number       => NULL,
                                                                                        p_new_supplier_order_number       => NULL,
                                                                                        p_old_supplier_order_line_num  => NULL,
                                                                                        p_new_supplier_order_line_num  => NULL,
                                                                                        p_additional_changes => NULL,
                                                                                        p_old_start_date => NULL,
                                                                                        p_new_start_date => NULL,
                                                                                        p_old_expiration_date	 => NULL,
                                                                                        p_new_expiration_date	 => NULL,
                                                                                        p_old_amount => NULL,
                                                                                        p_new_amount => NULL
                                                                                        );

          p_progress := 'G2-3' || to_char(l_po_change_table_count) ||' '|| to_char(i) ||' '|| to_char(p_po_change_table(i).document_line_location_id);
          l_po_tbl_index := l_po_tbl_index + 1;
        END IF;
      END IF;
      i := i + 1;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    p_progress := p_progress || SQLERRM;
    RAISE;
  END;

/*
* This API takes in a PLSQL table of requisition changes, transform it into PLSQL tables
* of PO changes (groupd by po_header_id/po_release_id), and call ISP's validate_change_request
* API to validate the changes
*/
  PROCEDURE validate_changes(p_req_hdr_id IN NUMBER,
                             p_req_change_table IN OUT NOCOPY change_tbl_type,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_retmsg OUT NOCOPY VARCHAR,
                             p_errortable IN OUT NOCOPY po_req_change_err_table)
  IS
  l_api_name VARCHAR2(50) := 'Validate_Changes';
  l_po_change_table pos_chg_rec_tbl;
  l_error_table error_tbl_type;
  l_main_loop_flag VARCHAR2(1) := fnd_api.g_true;
  l_get_cur_id_loop_flag VARCHAR2(1) := fnd_api.g_true;
  i NUMBER := 2;
  j NUMBER;
  k NUMBER;
  l_table_index NUMBER;
  l_po_header_id NUMBER;
  l_current_hdr_id NUMBER;
  l_current_rel_id NUMBER;
  l_hdr_id NUMBER;
  l_rel_id NUMBER;
  l_current_row_id NUMBER;

  l_current_rev_num NUMBER;
  l_output_report_id NUMBER;
  l_found_clean VARCHAR2(1);
  l_doc_check_rec_type doc_check_return_type;
  l_online_report_id NUMBER;
  l_error_index NUMBER := 1;

  l_return_status VARCHAR2(1);
  l_return_msg VARCHAR2(2000);
  l_err_po_msg VARCHAR2(2000);

  l_pos_errors_tbl pos_err_type;
  l_decode_status VARCHAR2(1);
  l_decode_msg VARCHAR2(2000);
  l_val_qty_msg VARCHAR2(2000);
  l_val_qty_status VARCHAR2(1);
  l_err_count NUMBER;
  l_req_org_id NUMBER;
  BEGIN
    x_retmsg := 'VC000';
    x_return_status := fnd_api.g_ret_sts_success;

    j := 1;
    l_main_loop_flag := fnd_api.g_true;

--Main Loop Starts
--Main Loop continues so as long there exists records with dirty_flag = 'N'
    WHILE(l_main_loop_flag = fnd_api.g_true)
      LOOP
      x_retmsg := 'VC001';
	--Get First Clean Row => dirty_flag ='N'
      l_get_cur_id_loop_flag := fnd_api.g_true;
      l_found_clean := fnd_api.g_true;
      WHILE(l_get_cur_id_loop_flag = fnd_api.g_true) LOOP
        IF(j = p_req_change_table.count + 1) THEN /*Cannot find any Clean Row, Thus End Procedure*/
          l_main_loop_flag := fnd_api.g_false;
          l_get_cur_id_loop_flag := fnd_api.g_false;
          l_found_clean := fnd_api.g_false;
        ELSIF(p_req_change_table(j).dirty_flag = 'N') THEN
          l_current_row_id := j;
          j := j + 1;
          l_get_cur_id_loop_flag := fnd_api.g_false;
        ELSE
          j := j + 1;
        END IF;
      END LOOP;

      x_retmsg := 'VC002';

	--Obtained First Clean Row in l_current_row_id

      IF(l_found_clean = fnd_api.g_true) THEN

		--Get po_header_id/po_release_id for the current Clean Row
        SELECT
            plla.po_header_id,
            plla.po_release_id
        INTO
            l_current_hdr_id,
            l_current_rel_id
        FROM
            po_line_locations_all plla,
            po_requisition_lines_all prla
        WHERE prla.line_location_id = plla.line_location_id
        AND prla.requisition_line_id = p_req_change_table(l_current_row_id).document_line_id;

		--Refresh l_po_change_table
        IF(l_po_change_table IS NOT NULL) THEN
          l_po_change_table.delete;
        END IF;

        k := 2; /*index of l_po_change_table*/
        p_req_change_table(l_current_row_id).dirty_flag := 'Y';

        l_po_change_table := pos_chg_rec_tbl();
        l_po_change_table.extend(1);
        copy_change(l_current_hdr_id, l_current_rel_id, p_req_hdr_id,
                    p_req_change_table, l_current_row_id, 1, l_po_change_table);


		--Inner Loop Starts
		--Scan through remaining clean Rows in p_req_change_table, and extract those
		--clean rows, copy them over, and mark them as dirty..
        FOR i IN j .. p_req_change_table.count
          LOOP

          IF (p_req_change_table(i).dirty_flag = 'N') THEN



				--Get po_header_id/po_release_id of this clean row
            SELECT
                plla.po_header_id,
                plla.po_release_id
            INTO
                l_hdr_id,
                l_rel_id
            FROM
                po_line_locations_all plla,
                po_requisition_lines_all prla
            WHERE prla.line_location_id = plla.line_location_id
            AND prla.requisition_line_id = p_req_change_table(i).document_line_id;



				--po_header_id matches
            IF(l_current_rel_id IS NULL AND l_rel_id IS NULL AND l_hdr_id = l_current_hdr_id) THEN


              l_po_change_table.extend(1);
              copy_change(l_current_hdr_id, l_current_rel_id, p_req_hdr_id,
                          p_req_change_table, i, k, l_po_change_table);

              p_req_change_table(i).dirty_flag := 'Y';

              k := k + 1;

				--po_release_id matches
            ELSIF(l_rel_id = l_current_rel_id) THEN


              l_po_change_table.extend(1);
              copy_change(l_current_hdr_id, l_current_rel_id, p_req_hdr_id,
                          p_req_change_table, i, k, l_po_change_table);

              p_req_change_table(i).dirty_flag := 'Y';
              k := k + 1;

            END IF;

          END IF;

        END LOOP;

        x_retmsg := 'VC003';


	-- Check new quantity against delivered/received/billed quantity
        validate_quantity(l_current_hdr_id,
                          l_current_rel_id,
                          l_po_change_table,
                          p_errortable,
                          l_error_index,
                          l_val_qty_status,
                          l_val_qty_msg);



        x_retmsg := 'VC0031';
        generate_po_change_table(l_po_change_table, x_retmsg);
        x_retmsg := 'VC0031-1';

        po_chg_request_pvt.validate_change_request(
                                                   p_api_version           => 1.0,
                                                   p_init_msg_list         => fnd_api.g_false,
                                                   x_return_status         => l_return_status,
                                                   x_msg_data     	    => l_return_msg,
                                                   p_po_header_id          => l_current_hdr_id,
                                                   p_po_release_id         => l_current_rel_id,
                                                   p_revision_num          => l_current_rev_num,
                                                   p_po_change_requests    => l_po_change_table,
                                                   x_online_report_id      => l_online_report_id,
                                                   x_pos_errors 			=> l_pos_errors_tbl,
                                                   x_doc_check_error_msg   => l_doc_check_rec_type);
        x_retmsg := 'VC0032';

                -- BUG: 3590131
                -- validate_change_request API set's org id context
                -- to the PO document's org, we need to set it back
        SELECT org_id
        INTO l_req_org_id
        FROM po_requisition_headers_all
        WHERE requisition_header_id = p_req_hdr_id;

                -- set org context back to req's org
        po_moac_utils_pvt.set_org_context(l_req_org_id) ;       -- <R12 MOAC>

        IF(l_return_status = fnd_api.g_ret_sts_error) THEN
          x_retmsg := 'VC0d31:' || l_return_msg;
          l_err_count := l_doc_check_rec_type.online_report_id.count;
          IF(l_err_count > 0) THEN
            FOR y IN 1..l_err_count
              LOOP
              l_err_po_msg := l_doc_check_rec_type.message_name(y);
              decode_poerror(l_current_hdr_id,
                             l_current_rel_id,
                             l_err_po_msg,
                             l_doc_check_rec_type,
                             y,
                             p_errortable,
                             l_error_index,
                             l_decode_status,
                             l_decode_msg);
              IF(l_decode_status <> fnd_api.g_ret_sts_success) THEN
                x_retmsg := 'VC0d41:' || l_decode_msg;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
              END IF;
            END LOOP;
          END IF;
        ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          x_retmsg := 'VC0f31:' || l_return_msg;
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          RETURN;
        END IF;

      END IF;

    END LOOP;

    x_retmsg := 'VC004';

    IF(p_errortable.req_line_id.count>0) THEN

      x_return_status := fnd_api.g_ret_sts_error;
    ELSE

      x_return_status := fnd_api.g_ret_sts_success;
    END IF;


  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_retmsg := 'VC_Exp:' || x_retmsg || ':' || SQLERRM;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', x_retmsg);
      END IF;
    END IF;
  END validate_changes;

/*
*Simple API to insert change records into PO_CHANGE_REQUESTS table
*/
  PROCEDURE insert_reqchange(p_change_table change_tbl_type,
                             p_chn_req_grp_id NUMBER)
  IS
  l_api_name VARCHAR2(50) := 'Insert_ReqChange';
  l_req_user_id NUMBER;

  BEGIN

    l_req_user_id := fnd_global.user_id;
    FOR i IN 1..p_change_table.count
      LOOP

      INSERT INTO po_change_requests
      (
          change_request_group_id,
          change_request_id,
          initiator,
          action_type,
          request_reason,
          request_level,
          request_status,
          document_type,
          document_header_id,
          document_num,
          document_revision_num,
          created_by,
          creation_date,
          document_line_id,
          document_line_number,
          document_distribution_id,
          document_distribution_number,
          old_quantity,
          new_quantity,
          old_price,
          new_price,
          old_need_by_date,
          new_need_by_date,
          old_currency_unit_price,
          new_currency_unit_price,
          last_updated_by,
          last_update_date,
          last_update_login,
          requester_id,
          change_active_flag,
          ref_po_header_id,
          ref_po_num,
          ref_po_release_id,
          ref_po_rel_num,
          old_start_date,
          new_start_date,
          old_expiration_date,
          new_expiration_date,
          old_amount,
          new_amount,
          old_currency_amount,
          new_currency_amount
          )
      VALUES
      (
          p_chn_req_grp_id,
          po_chg_request_seq.nextval,
          'REQUESTER',
          p_change_table(i).action_type,
          p_change_table(i).request_reason,
          p_change_table(i).request_level,
          p_change_table(i).request_status,
          'REQ',
          p_change_table(i).document_header_id,
          p_change_table(i).document_num,
          p_change_table(i).document_revision_num,
          l_req_user_id,
          SYSDATE,
          p_change_table(i).document_line_id,
          p_change_table(i).document_line_number,
          p_change_table(i).document_distribution_id,
          p_change_table(i).document_distribution_number,
          p_change_table(i).old_quantity,
          p_change_table(i).new_quantity,
          p_change_table(i).old_price,
          p_change_table(i).new_price,
          p_change_table(i).old_date,
          p_change_table(i).new_date,
          p_change_table(i).old_currency_unit_price,
          p_change_table(i).new_currency_unit_price,
          l_req_user_id,
          SYSDATE,
          l_req_user_id,
          p_change_table(i).requester_id,
          'Y',
          p_change_table(i).referenced_po_header_id,
          p_change_table(i).referenced_po_document_num,
          p_change_table(i).referenced_release_id,
          p_change_table(i).referenced_release_num,
          p_change_table(i).old_start_date,
          p_change_table(i).new_start_date,
          p_change_table(i).old_end_date,
          p_change_table(i).new_end_date,
          p_change_table(i).old_budget_amount,
          p_change_table(i).new_budget_amount,
          p_change_table(i).old_currency_budget_amount,
          p_change_table(i).new_currency_budget_amount
      );

    END LOOP;


  EXCEPTION WHEN OTHERS THEN

    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', SQLERRM);
      END IF;
    END IF;
    RAISE;
  END insert_reqchange;

/*
*Calculate recoverable tax and non-recoverable tax for a req dist.
*/
  PROCEDURE calculate_disttax(p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_dist_id NUMBER,
                              p_price NUMBER,
                              p_quantity NUMBER,
                              p_dist_amount NUMBER,
                              p_rec_tax OUT NOCOPY NUMBER,
                              p_nonrec_tax OUT NOCOPY NUMBER)
  IS
  l_api_name VARCHAR2(50) := 'Calculate_DistTax';
  l_dist_total NUMBER;
  l_new_total NUMBER;
  l_rec_tax NUMBER;
  l_nonrec_tax NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SELECT
        decode(prl.matching_basis, 'AMOUNT', prd.req_line_amount, prl.unit_price * prd.req_line_quantity),
        decode(prl.matching_basis, 'AMOUNT', p_dist_amount, nvl(p_price, prl.unit_price) * nvl(p_quantity, prd.req_line_quantity)),
        prd.recoverable_tax,
        prd.nonrecoverable_tax
    INTO
        l_dist_total,
        l_new_total,
        l_rec_tax,
        l_nonrec_tax
    FROM
        po_requisition_lines_all prl,
        po_req_distributions_all prd
    WHERE prd.distribution_id = p_dist_id
        AND prd.requisition_line_id = prl.requisition_line_id;

-- Calcualte new tax only if existing total tax amount is
-- greater than zero.
    IF((nvl(l_rec_tax, 0) + nvl(l_nonrec_tax, 0) ) > 0) THEN
      p_rec_tax := (l_rec_tax / l_dist_total) *  l_new_total;

      p_nonrec_tax :=
      (l_nonrec_tax / l_dist_total) *
      l_new_total;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', SQLERRM);
      END IF;
    END IF;
  END calculate_disttax;

/*------------------------------------------------------+
*Given a change group ID, update all distribution records
*with tax information, if needed
+-------------------------------------------------------*/
  PROCEDURE update_recordswithtax(p_chn_req_grp_id NUMBER)
  IS
  l_api_name VARCHAR2(50) := 'Update_RecordsWithTax';
  l_progress VARCHAR2(3) := '000';
  l_id NUMBER;
  l_line_id NUMBER;
  l_dist_id NUMBER;
  l_new_quantity NUMBER;
  l_quantity NUMBER;
  l_price NUMBER;
  l_rec_tax NUMBER;
  l_nonrec_tax NUMBER;
  l_cal_disttax_status VARCHAR2(1);
  l_dist_rec_tax NUMBER;
  l_dist_nonrec_tax NUMBER;
  l_temp_id NUMBER;

  CURSOR l_dist_with_chn_csr(grp_id NUMBER, line_id NUMBER) IS
  SELECT
      change_request_id,
      new_quantity,
      document_distribution_id
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND document_line_id = line_id
  AND request_level = 'DISTRIBUTION';

  CURSOR l_line_id_with_qty_chn_csr(grp_id NUMBER) IS
  SELECT DISTINCT document_line_id
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND new_quantity IS NOT NULL;

  CURSOR l_line_id_with_price_chn_csr(grp_id NUMBER) IS
  SELECT
      change_request_id,
      document_line_id,
      new_price
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND new_price IS NOT NULL;

  CURSOR l_dist_id_csr(line_id NUMBER) IS
  SELECT
      distribution_id,
      req_line_quantity
  FROM po_req_distributions_all
  WHERE requisition_line_id = l_line_id;


  CURSOR l_dist_exist_chn_csr(dist_id NUMBER, grp_id NUMBER) IS
  SELECT
      change_request_id,
      recoverable_tax,
      nonrecoverable_tax
  FROM po_change_requests
  WHERE change_request_group_id = p_chn_req_grp_id
  AND document_distribution_id = l_dist_id;


  BEGIN

	--OUTER LOOP: loops through req distribution records with quantity change, and get the req line ID.
	--Objective is to populate tax attributes for distribution records (with quantity change)
    OPEN l_line_id_with_qty_chn_csr(p_chn_req_grp_id);
    LOOP
      FETCH l_line_id_with_qty_chn_csr INTO
      l_line_id;
      EXIT WHEN l_line_id_with_qty_chn_csr%notfound;

      BEGIN
        SELECT nvl(new_currency_unit_price, new_price)
        INTO l_price
        FROM po_change_requests
        WHERE change_request_group_id = p_chn_req_grp_id
        AND document_line_id = l_line_id
        AND request_level = 'LINE'
        AND new_price IS NOT NULL;
      EXCEPTION WHEN OTHERS THEN
        SELECT nvl(currency_unit_price, unit_price)
        INTO l_price
        FROM po_requisition_lines_all
        WHERE requisition_line_id = l_line_id;
      END;
      l_progress := '001';
		--INNER LOOP: After getting the most recent price, update child distribution records with tax information.
      OPEN l_dist_with_chn_csr(p_chn_req_grp_id, l_line_id);
      LOOP
        FETCH l_dist_with_chn_csr INTO l_id, l_new_quantity, l_dist_id ;
        EXIT WHEN l_dist_with_chn_csr %notfound;

        IF(l_new_quantity IS NOT NULL) THEN
          calculate_disttax(1.0, l_cal_disttax_status, l_dist_id, l_price, l_new_quantity, NULL, l_rec_tax, l_nonrec_tax);
        ELSE
          SELECT req_line_quantity
          INTO l_quantity
          FROM po_req_distributions_all
          WHERE distribution_id = l_dist_id;
          calculate_disttax(1.0, l_cal_disttax_status, l_dist_id, l_price, l_quantity, NULL, l_rec_tax, l_nonrec_tax);
        END IF;
        UPDATE po_change_requests
        SET recoverable_tax = l_rec_tax,
        nonrecoverable_tax = l_nonrec_tax
        WHERE change_request_id = l_id;


      END LOOP;
      CLOSE l_dist_with_chn_csr;
    END LOOP;
    CLOSE l_line_id_with_qty_chn_csr;

    l_dist_id := NULL;
    l_price := NULL;
    l_quantity := NULL;

    l_progress := '002';
	--2nd OUTER LOOP: update recoverable and non recoverable tax attributes of Line Records (with Price Change)
    OPEN l_line_id_with_price_chn_csr(p_chn_req_grp_id);
    LOOP
      FETCH l_line_id_with_price_chn_csr INTO l_id, l_line_id, l_price;
      EXIT WHEN l_line_id_with_price_chn_csr%notfound;

      l_rec_tax := 0;
      l_nonrec_tax := 0;

      OPEN l_dist_id_csr(l_line_id);
      LOOP
        FETCH l_dist_id_csr INTO
        l_dist_id,
        l_quantity;
        EXIT WHEN l_dist_id_csr%notfound;

        OPEN l_dist_exist_chn_csr(l_dist_id, p_chn_req_grp_id);
        FETCH l_dist_exist_chn_csr INTO
        l_temp_id,
        l_dist_rec_tax,
        l_dist_nonrec_tax;
        CLOSE l_dist_exist_chn_csr;

        IF(l_temp_id IS NOT NULL) THEN -- Distribution exist in po_change_requests table
          l_rec_tax := l_rec_tax + l_dist_rec_tax;
          l_nonrec_tax := l_nonrec_tax + l_dist_nonrec_tax;
        ELSE -- Distribution does NOT exist in change table, thus need to calculate
          calculate_disttax(1.0, l_cal_disttax_status, l_dist_id, l_price, l_quantity, NULL, l_dist_rec_tax, l_dist_nonrec_tax);
          l_rec_tax := l_rec_tax + l_dist_rec_tax;
          l_nonrec_tax := l_nonrec_tax + l_dist_nonrec_tax;
        END IF;

      END LOOP;
      CLOSE l_dist_id_csr;

      l_progress := '003';
      UPDATE po_change_requests
      SET recoverable_tax = l_rec_tax,
      nonrecoverable_tax = l_nonrec_tax
      WHERE change_request_id = l_id;
    END LOOP;
    CLOSE l_line_id_with_price_chn_csr;

  EXCEPTION WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception',
                       p_chn_req_grp_id || '*' || l_progress || ':' || SQLERRM);
      END IF;
    END IF;
    RAISE;
  END 	update_recordswithtax;

/*------------------------------------------------------+
*Given a change group ID, update all line records
*with tax information, if qunatity is changed needed
+-------------------------------------------------------*/
  PROCEDURE update_internalrecordswithtax(p_chn_req_grp_id NUMBER)
  IS
  l_id NUMBER;
  l_line_id NUMBER;
  l_dist_id NUMBER;
  l_new_quantity NUMBER;
  l_quantity NUMBER;
  l_price NUMBER;
  l_rec_tax NUMBER;
  l_nonrec_tax NUMBER;
  l_cal_disttax_status VARCHAR2(1);
  l_dist_rec_tax NUMBER;
  l_dist_nonrec_tax NUMBER;
  l_temp_id NUMBER;

  CURSOR l_line_id_with_qty_chn_csr(grp_id NUMBER) IS
  SELECT DISTINCT document_line_id
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND new_quantity IS NOT NULL;


  CURSOR l_dist_id_csr(line_id NUMBER) IS
  SELECT
      distribution_id,
      req_line_quantity
  FROM po_req_distributions_all
  WHERE requisition_line_id = l_line_id;


  CURSOR l_dist_exist_chn_csr(dist_id NUMBER, grp_id NUMBER) IS
  SELECT
      change_request_id,
      recoverable_tax,
      nonrecoverable_tax
  FROM po_change_requests
  WHERE change_request_group_id = p_chn_req_grp_id
  AND document_distribution_id = l_dist_id;

  CURSOR l_dist_with_chn_csr(grp_id NUMBER, line_id NUMBER) IS
  SELECT
      change_request_id,
      new_quantity,
      document_distribution_id
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND document_line_id = line_id
  AND request_level = 'LINE';


  l_api_name     CONSTANT VARCHAR(30) := 'Update_InternalRecordsWithTax';
  l_log_head     CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress     VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_chn_req_grp_id', p_chn_req_grp_id);
    END IF;

	--OUTER LOOP: loops through req distribution records with quantity change, and get the req line ID.
	--Objective is to populate tax attributes for distribution records (with quantity change)
    OPEN l_line_id_with_qty_chn_csr(p_chn_req_grp_id);
    LOOP
      FETCH l_line_id_with_qty_chn_csr INTO
      l_line_id;
      EXIT WHEN l_line_id_with_qty_chn_csr%notfound;

      BEGIN
        SELECT nvl(currency_unit_price, unit_price)
        INTO l_price
        FROM po_requisition_lines_all
        WHERE requisition_line_id = l_line_id;
      EXCEPTION  WHEN OTHERS THEN
        l_price := NULL;
      END;
      l_progress := '001';

      IF g_debug_stmt THEN
        po_debug.debug_var(l_log_head, l_progress, 'l_line_id', l_line_id);
        po_debug.debug_var(l_log_head, l_progress, 'l_price', l_price);
      END IF;


  	--INNER LOOP: After getting the most recent price, update child distribution records with tax information.
      OPEN l_dist_with_chn_csr(p_chn_req_grp_id, l_line_id);
      LOOP
        FETCH l_dist_with_chn_csr INTO l_id, l_new_quantity, l_dist_id ;
        EXIT WHEN l_dist_with_chn_csr %notfound;

        calculate_disttax(1.0, l_cal_disttax_status, l_dist_id, l_price, l_new_quantity, NULL, l_rec_tax, l_nonrec_tax);

        l_progress := '002';

        IF g_debug_stmt THEN
          po_debug.debug_var(l_log_head, l_progress, 'l_rec_tax', l_rec_tax);
          po_debug.debug_var(l_log_head, l_progress, 'l_nonrec_tax', l_nonrec_tax);
          po_debug.debug_stmt(l_log_head, l_progress,'Updating taxes in po_change_request table');
        END IF;


        UPDATE po_change_requests
            SET recoverable_tax = l_rec_tax,
            nonrecoverable_tax = l_nonrec_tax
            WHERE change_request_id = l_id;


      END LOOP;
      CLOSE l_dist_with_chn_csr;
    END LOOP;
    CLOSE l_line_id_with_qty_chn_csr;

  EXCEPTION WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception',
                       p_chn_req_grp_id || '*' || l_progress || ':' || SQLERRM);
      END IF;
    END IF;
    RAISE;
  END 	update_internalrecordswithtax;
/*--------------------------------------------------------------------
*Copy a requisition change record into a PO change record,
*meanwhile updating the req change record with more information
-----------------------------------------------------------------*/
  PROCEDURE copy_change(p_header_id NUMBER,
                        p_release_id NUMBER,
                        p_req_hdr_id NUMBER,
                        req_change_record_tbl IN OUT NOCOPY change_tbl_type,
                        req_index IN NUMBER,
                        po_index IN NUMBER,
                        po_change_record_tbl IN OUT NOCOPY pos_chg_rec_tbl)
  IS
  l_api_name VARCHAR2(50) := 'Copy_Change';
  l_progress VARCHAR2(3) := '000';
  l_po_doc_type VARCHAR2(30);
  l_po_num po_headers_all.segment1%TYPE;
  l_po_revision_num NUMBER;
  l_po_line_id NUMBER;
  l_po_line_number NUMBER;
  l_po_line_location_id NUMBER;
  l_po_shipment_number NUMBER;
  l_po_distribution_id NUMBER;
  l_po_distribution_number NUMBER;
  l_recoverable_tax NUMBER;
  l_non_recoverable_tax NUMBER;
  l_po_request_level po_change_requests.request_level%TYPE;
  l_req_request_level po_change_requests.request_level%TYPE;
  l_req_header_id NUMBER;
  l_req_num po_requisition_headers_all.segment1%TYPE;
  l_req_line_number NUMBER;
  l_req_dist_number NUMBER;
  l_new_functional_price NUMBER;
  l_old_curr_unit_price NUMBER;
  l_old_po_price NUMBER;
  l_old_req_price NUMBER;
  l_old_po_quantity NUMBER;
  l_old_req_quantity NUMBER;
  l_old_po_date DATE;
  l_old_req_date DATE;
  l_new_po_price NUMBER;
  l_new_po_quantity NUMBER;
  l_price_temp NUMBER;
  l_preparer_id NUMBER;
  l_po_ship_to_loc_id NUMBER;
  l_po_ship_to_org_id NUMBER;
  l_item_id NUMBER;
  l_req_uom po_requisition_lines_all.unit_meas_lookup_code%TYPE;
  l_po_uom po_line_locations_all.unit_meas_lookup_code%TYPE;
  l_po_to_req_rate NUMBER;
  l_release_num NUMBER;
  l_old_start_date DATE;
  l_old_end_date DATE;
  l_old_amount NUMBER;
  l_old_curr_amount NUMBER;
  l_old_po_amount NUMBER;
  l_new_start_date DATE;
  l_new_end_date DATE;
  l_new_amount NUMBER;
  l_new_curr_amount NUMBER;
  l_new_po_amount NUMBER;
  l_new_functional_amount NUMBER;
  l_amount_temp NUMBER;

  BEGIN


    IF(p_release_id IS NULL) THEN
      IF(req_change_record_tbl(req_index).document_distribution_id IS NOT NULL) THEN

	--Standard PO Distribution Change
        l_po_request_level := 'DISTRIBUTION';
        l_req_request_level := 'DISTRIBUTION';
        l_progress := '001';
        SELECT
            'PO',
            pha.segment1,
            pha.revision_num,
            pla.po_line_id,
            pla.line_num,
            plla.line_location_id,
            plla.shipment_num,
            pda.po_distribution_id,
            pda.distribution_num,
            prha.segment1,
            prla.line_num,
            prda.distribution_num,
            prda.req_line_quantity,
            pda.quantity_ordered,
            prha.preparer_id,
            plla.ship_to_location_id,
            plla.ship_to_organization_id,
            prla.unit_meas_lookup_code,
            nvl(plla.unit_meas_lookup_code, pla.unit_meas_lookup_code),
            prla.item_id,
            pha.rate,
            prla.unit_price,
            prla.need_by_date,
            prla.assignment_start_date,
            prla.assignment_end_date,
            prda.req_line_amount,
            prda.req_line_currency_amount,
            pda.amount_ordered
        INTO
            l_po_doc_type,
            l_po_num,
            l_po_revision_num,
            l_po_line_id,
            l_po_line_number,
            l_po_line_location_id,
            l_po_shipment_number,
            l_po_distribution_id,
            l_po_distribution_number,
            l_req_num,
            l_req_line_number,
            l_req_dist_number,
            l_old_req_quantity,
            l_old_po_quantity,
            l_preparer_id,
            l_po_ship_to_loc_id,
            l_po_ship_to_org_id,
            l_req_uom,
            l_po_uom,
            l_item_id,
            l_po_to_req_rate,
            l_old_req_price,
            l_old_req_date,
            l_old_start_date,
            l_old_end_date,
            l_old_amount,
            l_old_curr_amount,
            l_old_po_amount
        FROM
            po_headers_all pha,
            po_lines_all pla,
            po_line_locations_all plla,
            po_req_distributions_all prda,
            po_requisition_lines_all prla,
            po_requisition_headers_all prha,
            po_distributions_all pda
        WHERE
            prda.distribution_id = req_change_record_tbl(req_index).document_distribution_id
            AND prda.requisition_line_id = prla.requisition_line_id
            AND prla.line_location_id = plla.line_location_id
            AND plla.po_line_id = pla.po_line_id
            AND pla.po_header_id = pha.po_header_id
            AND prha.requisition_header_id = prla.requisition_header_id
            AND pda.req_distribution_id = prda.distribution_id
            AND pda.line_location_id = prla.line_location_id;

      ELSE

        l_req_request_level := 'LINE';

        l_progress := '002';
        SELECT
            'PO',
            pha.segment1,
            pha.revision_num,
            pla.po_line_id,
            pla.line_num,
            plla.line_location_id,
            plla.shipment_num,
            prha.segment1,
            prla.line_num,
            pla.unit_price,
            prla.currency_unit_price,
            prla.unit_price,
            prla.need_by_date,
            plla.need_by_date,
            prha.preparer_id,
            plla.ship_to_location_id,
            plla.ship_to_organization_id,
            prla.unit_meas_lookup_code,
            nvl(plla.unit_meas_lookup_code, pla.unit_meas_lookup_code),
            prla.item_id,
            pha.rate,
            prla.quantity,
                        plla.quantity,
            prla.assignment_start_date,
            prla.assignment_end_date,
            prla.amount,
            prla.currency_amount,
            plla.amount
        INTO
            l_po_doc_type,
            l_po_num,
            l_po_revision_num,
            l_po_line_id,
            l_po_line_number,
            l_po_line_location_id,
            l_po_shipment_number,
            l_req_num,
            l_req_line_number,
            l_old_po_price,
            l_old_curr_unit_price,
            l_old_req_price,
            l_old_req_date,
            l_old_po_date,
            l_preparer_id,
            l_po_ship_to_loc_id,
            l_po_ship_to_org_id,
            l_req_uom,
            l_po_uom,
            l_item_id,
            l_po_to_req_rate,
            l_old_req_quantity,
            l_old_po_quantity,
            l_old_start_date,
            l_old_end_date,
            l_old_amount,
            l_old_curr_amount,
            l_old_po_amount
        FROM
            po_headers_all pha,
            po_lines_all pla,
            po_line_locations_all plla,
            po_requisition_lines_all prla,
            po_requisition_headers_all prha
        WHERE
            prla.requisition_line_id = req_change_record_tbl(req_index).document_line_id
            AND prla.line_location_id = plla.line_location_id
            AND plla.po_line_id = pla.po_line_id
            AND pla.po_header_id = pha.po_header_id
            AND prha.requisition_header_id = prla.requisition_header_id;
        IF(req_change_record_tbl(req_index).new_price IS NOT NULL) THEN
          l_po_request_level := 'LINE';
          l_po_line_location_id := NULL;
          l_po_shipment_number := NULL;
          l_po_ship_to_loc_id := NULL;
          l_po_ship_to_org_id := NULL;
          l_old_po_quantity := NULL;
        ELSE
          l_po_request_level := 'SHIPMENT';
        END IF;

      END IF;
    ELSE
      IF(req_change_record_tbl(req_index).document_distribution_id IS NOT NULL) THEN

	--Standard PO Distribution Change
        l_po_request_level := 'DISTRIBUTION';
        l_req_request_level := 'DISTRIBUTION';
        l_progress := '003';
        SELECT
            'PO',
            pha.segment1,
            pra.revision_num,
            plla.po_line_id,
            plla.line_location_id,
            plla.shipment_num,
            pda.po_distribution_id,
            pda.distribution_num,
            prha.segment1,
            prla.line_num,
            prda.distribution_num,
            prda.req_line_quantity,
            pda.quantity_ordered,
            prha.preparer_id,
            plla.ship_to_location_id,
            plla.ship_to_organization_id,
            prla.unit_meas_lookup_code,
            nvl(plla.unit_meas_lookup_code, pla.unit_meas_lookup_code),
            prla.item_id,
            pha.rate,
            prla.unit_price,
            prla.need_by_date,
            pra.release_num,
            prla.assignment_start_date,
            prla.assignment_end_date,
            prda.req_line_amount,
            prda.req_line_currency_amount,
            pda.amount_ordered
        INTO
            l_po_doc_type,
            l_po_num,
            l_po_revision_num,
            l_po_line_id,
            l_po_line_location_id,
            l_po_shipment_number,
            l_po_distribution_id,
            l_po_distribution_number,
            l_req_num,
            l_req_line_number,
            l_req_dist_number,
            l_old_req_quantity,
            l_old_po_quantity,
            l_preparer_id,
            l_po_ship_to_loc_id,
            l_po_ship_to_org_id,
            l_req_uom,
            l_po_uom,
            l_item_id,
            l_po_to_req_rate,
            l_old_req_price,
            l_old_req_date,
            l_release_num,
            l_old_start_date,
            l_old_end_date,
            l_old_amount,
            l_old_curr_amount,
            l_old_po_amount
        FROM
            po_headers_all pha,
            po_releases_all pra,
            po_lines_all pla,
            po_line_locations_all plla,
            po_distributions_all pda,
            po_req_distributions_all prda,
            po_requisition_lines_all prla,
            po_requisition_headers_all prha
        WHERE
            prda.distribution_id = req_change_record_tbl(req_index).document_distribution_id
            AND prda.distribution_id = pda.req_distribution_id
            AND pda.line_location_id = plla.line_location_id
            AND plla.po_release_id = pra.po_release_id
            AND pra.po_header_id = pha.po_header_id
            AND prla.requisition_line_id = req_change_record_tbl(req_index).document_line_id
            AND prha.requisition_header_id = prla.requisition_header_id
            AND prla.line_location_id = pda.line_location_id
            AND pla.po_line_id = plla.po_line_id;

      ELSE

        l_req_request_level := 'LINE';
        l_po_request_level := 'SHIPMENT';
        l_progress := '004';
        SELECT
            'PO',
            pha.segment1,
            pra.revision_num,
            plla.po_line_id,
            plla.line_location_id,
            plla.shipment_num,
            prha.segment1,
            prla.line_num,
            plla.price_override,
            prla.currency_unit_price,
            prla.unit_price,
            prla.need_by_date,
            plla.need_by_date,
            prha.preparer_id,
            plla.ship_to_location_id,
            plla.ship_to_organization_id,
            prla.unit_meas_lookup_code,
            nvl(plla.unit_meas_lookup_code, pla.unit_meas_lookup_code),
            prla.item_id,
            pha.rate,
            prla.quantity,
            plla.quantity,
            pra.release_num,
            prla.assignment_start_date,
            prla.assignment_end_date,
            prla.amount,
            prla.currency_amount,
            plla.amount
        INTO
            l_po_doc_type,
            l_po_num,
            l_po_revision_num,
            l_po_line_id,
            l_po_line_location_id,
            l_po_shipment_number,
            l_req_num,
            l_req_line_number,
            l_old_po_price,
            l_old_curr_unit_price,
            l_old_req_price,
            l_old_req_date,
            l_old_po_date,
            l_preparer_id,
            l_po_ship_to_loc_id,
            l_po_ship_to_org_id,
            l_req_uom,
            l_po_uom,
            l_item_id,
            l_po_to_req_rate,
            l_old_req_quantity,
            l_old_po_quantity,
            l_release_num,
            l_old_start_date,
            l_old_end_date,
            l_old_amount,
            l_old_curr_amount,
            l_old_po_amount
        FROM
            po_headers_all pha,
            po_releases_all pra,
            po_lines_all pla,
            po_line_locations_all plla,
            po_requisition_lines_all prla,
            po_requisition_headers_all prha
        WHERE
            prla.requisition_line_id = req_change_record_tbl(req_index).document_line_id
            AND prla.line_location_id = plla.line_location_id
            AND plla.po_release_id = pra.po_release_id
            AND pra.po_header_id = pha.po_header_id
            AND prha.requisition_header_id = prla.requisition_header_id
            AND pla.po_line_id = plla.po_line_id;
      END IF;
    END IF;

-- Calculate New PO Quantity based on UOM Conversion
    IF(l_req_uom <> l_po_uom) THEN
      po_uom_s.uom_convert(
                           from_quantity => req_change_record_tbl(req_index).new_quantity,
                           from_uom => l_req_uom,
                           item_id => l_item_id,
                           to_uom => l_po_uom,
                           to_quantity => l_new_po_quantity);
    ELSE
      l_new_po_quantity := req_change_record_tbl(req_index).new_quantity;
    END IF;

-- Calculate New PO Price based on Currency Conversion
    IF(req_change_record_tbl(req_index).new_price IS NOT NULL) THEN

      l_new_functional_price := calculate_newunitprice(req_change_record_tbl(req_index).document_line_id,
                                                       req_change_record_tbl(req_index).new_price);
      IF(l_new_functional_price IS NOT NULL) THEN
        l_price_temp := req_change_record_tbl(req_index).new_price;
        req_change_record_tbl(req_index).new_price := l_new_functional_price;
        req_change_record_tbl(req_index).new_currency_unit_price := l_price_temp;
        req_change_record_tbl(req_index).old_currency_unit_price := l_old_curr_unit_price;

        IF(l_po_to_req_rate IS NULL) THEN
          l_new_po_price := l_new_functional_price;
        ELSE
          l_new_po_price := l_new_functional_price / l_po_to_req_rate;
        END IF;
      ELSE
        IF(l_po_to_req_rate IS NULL) THEN
          l_new_po_price := req_change_record_tbl(req_index).new_price;
        ELSE
          l_new_po_price := req_change_record_tbl(req_index).new_price / l_po_to_req_rate;
        END IF;
      END IF;
    END IF;

    l_new_start_date := req_change_record_tbl(req_index).new_start_date;
    l_new_end_date := req_change_record_tbl(req_index).new_end_date;

-- Calculate New PO AMOUNT based on Currency Conversion
    IF(req_change_record_tbl(req_index).new_budget_amount IS NOT NULL) THEN

      l_new_functional_amount := calculate_newunitprice(req_change_record_tbl(req_index).document_line_id, req_change_record_tbl(req_index).new_budget_amount);
      IF(l_new_functional_amount IS NOT NULL) THEN
        l_amount_temp := req_change_record_tbl(req_index).new_budget_amount;
        req_change_record_tbl(req_index).new_budget_amount := l_new_functional_amount;
        req_change_record_tbl(req_index).new_currency_budget_amount := l_amount_temp;
        req_change_record_tbl(req_index).old_currency_budget_amount := l_old_curr_amount;

        IF(l_po_to_req_rate IS NULL) THEN
          l_new_po_amount := l_new_functional_amount;
        ELSE
          l_new_po_amount := l_new_functional_amount / l_po_to_req_rate;
        END IF;
      ELSE
        IF(l_po_to_req_rate IS NULL) THEN
          l_new_po_amount := req_change_record_tbl(req_index).new_budget_amount;
        ELSE
          l_new_po_amount := req_change_record_tbl(req_index).new_budget_amount / l_po_to_req_rate;
        END IF;
      END IF;
    END IF;


    po_change_record_tbl(po_index) := po_chg_request_pvt.create_pos_change_rec(
                                                                               p_action_type => 'MODIFICATION',
                                                                               p_initiator => 'REQUESTER',
                                                                               p_document_type => l_po_doc_type,
                                                                               p_request_level => l_po_request_level,
                                                                               p_request_status => 'SYSTEMSAVE',
                                                                               p_document_header_id => p_header_id,
                                                                               p_request_reason => req_change_record_tbl(req_index).request_reason,
                                                                               p_po_release_id => p_release_id,
                                                                               p_document_num => l_po_num,
                                                                               p_document_revision_num => l_po_revision_num,
                                                                               p_document_line_id => l_po_line_id,
                                                                               p_document_line_number => l_po_line_number,
                                                                               p_document_line_location_id => l_po_line_location_id,
                                                                               p_document_shipment_number => l_po_shipment_number,
                                                                               p_document_distribution_id => l_po_distribution_id,
                                                                               p_document_distribution_number => l_po_distribution_number,
                                                                               p_parent_line_location_id => NULL,
                                                                               p_old_quantity => l_old_po_quantity,	--OLD_QUANTITY
                                                                               p_new_quantity => l_new_po_quantity, -- NEW_QUANTITY **
                                                                               p_old_promised_date => NULL, 	-- OLD_PROMISED_DATE
                                                                               p_new_promised_date => NULL, 	--NEW_PROMISED_DATE
                                                                               p_old_supplier_part_number => NULL, --OLD_SUPPLIER_PART_NUMBER
                                                                               p_new_supplier_part_number => NULL, 											--NEW_SUPPLIER_PART_NUMBER
                                                                               p_old_price => l_old_po_price, 	--OLD_PRICE
                                                                               p_new_price => l_new_po_price, 	-- NEW_PRICE **
                                                                               p_old_supplier_reference_num => NULL, 											--OLD_SUPPLIER_REFERENCE_NUMBER
                                                                               p_new_supplier_reference_num => NULL, 											--NEW_SUPPLIER_REFERENCE_NUMBER
                                                                               p_from_header_id => NULL,											--FROM_HEADER_ID
                                                                               p_recoverable_tax => NULL, 											--RECOVERABLE_TAX
                                                                               p_non_recoverable_tax => NULL,											--NON_RECOVERABLE_TAX
                                                                               p_ship_to_location_id => l_po_ship_to_loc_id,-- SHIP_TO_LOCATION_ID
                                                                               p_ship_to_organization_id => l_po_ship_to_org_id,-- SHIP_TO_ORGANIZATION_ID
                                                                               p_old_need_by_date => l_old_po_date,									--OLD_NEED_BY_DATE
                                                                               p_new_need_by_date => req_change_record_tbl(req_index).new_date, 	--NEW_NEED_BY_DATE
                                                                               p_approval_required_flag => NULL,
                                                                               p_parent_change_request_id => NULL,
                                                                               p_requester_id  => NULL,
                                                                               p_old_supplier_order_number => NULL,
                                                                               p_new_supplier_order_number => NULL,
                                                                               p_old_supplier_order_line_num => NULL,
                                                                               p_new_supplier_order_line_num => NULL,
                                                                               p_additional_changes => NULL, -- additional_change
                                                                               p_old_start_date => l_old_start_date,
                                                                               p_new_start_date => l_new_start_date,
                                                                               p_old_expiration_date => l_old_end_date,
                                                                               p_new_expiration_date => l_new_end_date,
                                                                               p_old_amount => l_old_po_amount,
                                                                               p_new_amount => l_new_po_amount);


    req_change_record_tbl(req_index).action_type 		:= 'MODIFICATION';

    req_change_record_tbl(req_index).initiator			:= 'REQUESTER';
    req_change_record_tbl(req_index).request_level := l_req_request_level;
    req_change_record_tbl(req_index).request_status 	:= 'SYSTEMSAVE';
    req_change_record_tbl(req_index).document_header_id	:= p_req_hdr_id;
    req_change_record_tbl(req_index).document_num	:= l_req_num;
    req_change_record_tbl(req_index).document_revision_num := l_po_revision_num;

    req_change_record_tbl(req_index).document_line_number			:= l_req_line_number;
    req_change_record_tbl(req_index).document_distribution_number	:= l_req_dist_number;

    req_change_record_tbl(req_index).old_quantity	:= l_old_req_quantity;
    req_change_record_tbl(req_index).old_price	:= l_old_req_price;
    req_change_record_tbl(req_index).old_date := l_old_req_date;
    req_change_record_tbl(req_index).requester_id := l_preparer_id;

    req_change_record_tbl(req_index).referenced_po_header_id := p_header_id;
    req_change_record_tbl(req_index).referenced_po_document_num := l_po_num;
    req_change_record_tbl(req_index).referenced_release_id := p_release_id;
    req_change_record_tbl(req_index).referenced_release_num := l_release_num;

    req_change_record_tbl(req_index).old_start_date := l_old_start_date;
    req_change_record_tbl(req_index).old_end_date := l_old_end_date;
    req_change_record_tbl(req_index).old_budget_amount := l_old_amount;
    req_change_record_tbl(req_index).old_currency_budget_amount := l_old_curr_amount;

--Exception Handling will be taken care of in parent procedures
  EXCEPTION WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception',
                       l_progress || ':' || SQLERRM);
      END IF;
    END IF;
    RAISE;
  END copy_change;

/*--------------------------------------------------------------
* IS_ON_COMPLEX_WORK_ORDER: For a particular Requisition dwishipment,
* this API checks if the  shipment is linked to a complex work order
----------------------------------------------------------------*/
  PROCEDURE is_on_complex_work_order(p_line_loc_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_header_id po_line_locations_all.po_header_id%TYPE;
  l_api_name VARCHAR2(100) := 'is_on_complex_work_order()';
  BEGIN

    x_return_status := 'N';

    IF(p_line_loc_id IS NOT NULL) THEN
      SELECT po_header_id INTO l_header_id
      FROM po_line_locations_all
      WHERE line_location_id = p_line_loc_id;

    --Call the PO API to check whether the passed PO is complex work order.
      IF (po_complex_work_pvt.is_complex_work_po(l_header_id)) THEN
        x_return_status := 'Y';
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(g_module_prefix, l_api_name);
  END is_on_complex_work_order;


/*-----------------------------------------------------------------------
* IS_REQ_LINE_CANCELLABLE: checks if a requisition line can be cancelled.
* It is called from 2 places
* 1. Called from api IS_REQ_LINE_CHANGEABLE, with p_origin = 'Y'
* 2. Called from the UI directly, with p_origin set to default (null)
------------------------------------------------------------------------*/
  PROCEDURE is_req_line_cancellable(p_api_version IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    p_req_line_id IN NUMBER,
                                    p_origin IN VARCHAR2)
  IS
  l_api_name VARCHAR2(50) := 'IS_REQ_LINE_CANCELLABLE';
  l_progress VARCHAR2(3) := '000';
  --bug# 13999194
  l_auction_display_number po_requisition_lines_all.auction_display_number%TYPE;
  l_auction_line_number NUMBER;
  l_reqs_in_pool_flag VARCHAR2(1);
  l_source_type_code po_requisition_lines_all.source_type_code%TYPE;
  l_return_status VARCHAR2(1);
  l_po_header_id NUMBER;
  l_po_release_id NUMBER;
  l_po_line_id NUMBER;
  l_po_line_loc_id NUMBER;
  l_po_doc_type VARCHAR2(30);
  l_po_doc_subtype VARCHAR2(30);
  l_count NUMBER;
  l_req_change_pending_flag VARCHAR2(1);
  l_agent_id NUMBER;
  l_modified_by_agent VARCHAR2(1);
  l_req_org_id NUMBER;
  l_po_org_id NUMBER;
  l_quantity NUMBER;
  l_received_quantity NUMBER;
  l_billed_quantity NUMBER;
  l_amount NUMBER;
  l_received_amount NUMBER;
  l_billed_amount NUMBER;
  l_receipt_required_flag po_line_locations.receipt_required_flag%TYPE;
  l_rcv_transaction_exist NUMBER := 0;
  l_asn_exist NUMBER := 0;
  l_not_delivered NUMBER := 0;
  l_dist_not_valid NUMBER := 0;
  l_is_on_complex_work_po VARCHAR2(1);
  l_transferred_to_oe_flag varchar(1) := null;
  l_cancelled varchar(1) :=null;
  is_so_cancel varchar2(1):='N';
  l_sts  varchar2(3);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
/*
* If called directly from the UI, we will need to make some extra validations,
* which are also included in IS_REQ_LINE_CHANGEABLE.
*/
    IF (p_origin IS NULL) THEN

      SELECT
        prla.source_type_code,
        prla.auction_display_number,
        prla.auction_line_number,
        prla.reqs_in_pool_flag,
        prla.line_location_id,
        prha.change_pending_flag,
        nvl(prla.modified_by_agent_flag, 'N'),
        prha.transferred_to_oe_flag,
        nvl(prla.cancel_flag,'N')
      INTO
        l_source_type_code,
        l_auction_display_number,
        l_auction_line_number,
        l_reqs_in_pool_flag,
        l_po_line_loc_id,
        l_req_change_pending_flag,
        l_modified_by_agent,
        l_transferred_to_oe_flag,
        l_cancelled
      FROM
            po_requisition_lines_all prla,
            po_requisition_headers_all prha
      WHERE
            prla.requisition_line_id = p_req_line_id AND
        prla.requisition_header_id = prha.requisition_header_id;


      IF (l_cancelled = 'Y' ) THEN

          IF (g_fnd_debug = 'Y') THEN
              IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
                fnd_log.string(fnd_log.level_statement,
                               g_module_prefix || l_api_name,
                               'Req Line ID:' || p_req_line_id || ' ' ||
                               'is Already cancelled');
              END IF;
            END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;


      IF (l_source_type_code = 'INVENTORY') THEN
        IF ( nvl(l_transferred_to_oe_flag,'N') = 'Y'  ) THEN

             is_SO_line_cancellable(p_api_version =>1.0,
                                         x_return_status =>l_sts,
                                         p_req_line_id =>p_req_line_id,
                                          p_req_header_id =>null,
                                         x_cancellable =>is_so_cancel);

              IF (g_fnd_debug = 'Y') THEN
               IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
                fnd_log.string(fnd_log.level_statement,
                               g_module_prefix || l_api_name,
                               'Req Line ID:' || p_req_line_id || ' ' ||
                               'transferred to so ='||is_so_cancel||' status'||l_sts);
               END IF;
              END IF;
          IF( l_sts <>  fnd_api.g_ret_sts_success OR ( l_sts = fnd_api.g_ret_sts_success AND is_so_cancel = 'N') )THEN
               x_return_status := fnd_api.g_ret_sts_error;
          END IF;
         Else
          is_internal_line_cancellable(1.0, x_return_status, p_req_line_id);
       END IF;
      END IF;

    ELSE

      SELECT
            prla.line_location_id,
        prha.change_pending_flag,
            nvl(prla.modified_by_agent_flag, 'N')
      INTO
            l_po_line_loc_id,
        l_req_change_pending_flag,
            l_modified_by_agent
      FROM
            po_requisition_lines_all prla,
        po_requisition_headers_all prha
      WHERE
            prla.requisition_line_id = p_req_line_id AND
        prla.requisition_header_id = prha.requisition_header_id;
    END IF;

  -- If the line is linked to a complex work PO, is not cancellable.
    IF(l_po_line_loc_id IS NOT NULL) THEN
      is_on_complex_work_order(l_po_line_loc_id, l_is_on_complex_work_po);
      IF(l_is_on_complex_work_po = 'Y') THEN
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
    END IF;

  -- Line is placed on PO. Check if the req is in change pending status
    IF (l_req_change_pending_flag = 'Y' AND l_po_line_loc_id IS NOT NULL) THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    IF (l_modified_by_agent = 'Y') THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    l_progress := '001';

/*
* Final Validation to check if a line can be cancelled will be done by
* calling PO Cancel API to check if the corresponding shipment can be cancelled
*/
    IF (x_return_status = fnd_api.g_ret_sts_success AND l_po_line_loc_id IS NOT NULL) THEN
      IF (p_origin IS NULL) THEN
        SELECT COUNT(DISTINCT nvl(prda.requisition_line_id, - 1))
        INTO l_count
        FROM
      po_req_distributions_all prda,
      po_distributions_all pda,
      po_requisition_lines_all prla
        WHERE pda.line_location_id = prla.line_location_id
      AND prla.requisition_line_id = p_req_line_id
      AND pda.req_distribution_id  = prda.distribution_id(+ );

        IF (l_count > 1) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;
      END IF;

      l_progress := '002';

      SELECT
        pha.po_header_id,
        pla.po_line_id,
        plla.po_release_id,
        plla.line_location_id,
        pha.agent_id,
            prla.quantity - nvl(prla.quantity_cancelled, 0),
            plla.quantity_received,
            plla.quantity_billed,
            prla.amount,
            plla.amount_received,
            plla.amount_billed,
            plla.receipt_required_flag
      INTO
        l_po_header_id,
        l_po_line_id,
        l_po_release_id,
        l_po_line_loc_id,
        l_agent_id,
            l_quantity,
            l_received_quantity,
            l_billed_quantity,
            l_amount,
            l_received_amount,
            l_billed_amount,
            l_receipt_required_flag
      FROM
        po_headers_all pha,
        po_lines_all pla,
        po_line_locations_all plla,
        po_requisition_lines_all prla
      WHERE
        prla.requisition_line_id = p_req_line_id
        AND prla.line_location_id = plla.line_location_id
        AND plla.po_line_id = pla.po_line_id
        AND pla.po_header_id = pha.po_header_id;

      l_progress := '003';

        -- Bug : 3578699. If req line is fully received, user cannot cancel
      IF (l_received_quantity >= l_quantity OR
          l_received_amount >= l_amount) THEN

        IF (g_fnd_debug = 'Y') THEN
          IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
            fnd_log.string(fnd_log.level_statement,
                           g_module_prefix || l_api_name,
                           'Req Line ID:' || p_req_line_id || ' ' ||
                           'Shipment Fully Received');
          END IF;
        END IF;

        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;

      l_progress := '004';

        -- Fully Billed Check (BUG: 3658317)
      IF (l_billed_quantity > l_quantity OR
          l_billed_amount > l_amount) THEN

        IF (g_fnd_debug = 'Y') THEN
          IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
            fnd_log.string(fnd_log.level_statement,
                           g_module_prefix || l_api_name,
                           'Req Line ID:' || p_req_line_id || ' ' ||
                           'Shipment Fully Billed');
          END IF;
        END IF;

        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;

      l_progress := '005';

        -- Over Billed Check (If Match Approval Level is set to 3-way or 4-way only, this check is done)
      IF ((l_quantity >= l_billed_quantity AND
           nvl(l_receipt_required_flag, 'Y') <> 'N' AND
           l_billed_quantity > l_received_quantity) OR
          (l_amount >= l_billed_amount AND
           nvl(l_receipt_required_flag, 'Y') <> 'N' AND
           l_billed_amount > l_received_amount)) THEN

        IF (g_fnd_debug = 'Y') THEN
          IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
            fnd_log.string(fnd_log.level_statement,
                           g_module_prefix || l_api_name,
                           'Req Line ID:' || p_req_line_id || ' ' ||
                           'Shipment Over Billed');
          END IF;
        END IF;

        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;

      l_progress := '006';

        -- Check for any Receiving Transaction exists
      BEGIN
        SELECT 1
        INTO l_rcv_transaction_exist
        FROM rcv_transactions_interface
        WHERE
          processing_status_code = 'PENDING' AND
          po_line_location_id = l_po_line_loc_id;

        IF (l_rcv_transaction_exist = 1) THEN

          IF (g_fnd_debug = 'Y') THEN
            IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
              fnd_log.string(fnd_log.level_statement,
                             g_module_prefix || l_api_name,
                             'Req Line ID:' || p_req_line_id || ' ' ||
                             'RCV transaction exists for Shipment');
            END IF;
          END IF;

          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;

      EXCEPTION
        WHEN no_data_found THEN
        NULL;
      END;

      l_progress := '007';

        -- Check for ASN not being fully received
      BEGIN
        SELECT 1
        INTO l_asn_exist
        FROM rcv_shipment_lines
        WHERE
          po_line_location_id = l_po_line_loc_id AND
          nvl(quantity_shipped, 0) > nvl(quantity_received, 0) AND
          nvl(asn_line_flag, 'N') = 'Y' AND
          nvl(shipment_line_status_code, 'EXPECTED') <> 'CANCELLED';

        IF (l_asn_exist = 1) THEN

          IF (g_fnd_debug = 'Y') THEN
            IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
              fnd_log.string(fnd_log.level_statement,
                             g_module_prefix || l_api_name,
                             'Req Line ID:' || p_req_line_id || ' ' ||
                             'ASN not Fully Received');
            END IF;
          END IF;

          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;

      EXCEPTION
        WHEN no_data_found THEN
        NULL;
      END;

      l_progress := '008';

        -- Check if shipment is received but not delivered
      BEGIN

        SELECT 1
        INTO l_not_delivered
        FROM po_line_locations_all plla
        WHERE
          plla.line_location_id = l_po_line_loc_id AND
          ((nvl(plla.quantity_received, 0) >
           (SELECT SUM(nvl(pod.quantity_delivered, 0))
            FROM po_distributions pod
            WHERE pod.line_location_id = plla.line_location_id)) OR
           (nvl(plla.amount_received, 0) >
            (SELECT SUM(nvl(pod.amount_delivered, 0))
             FROM po_distributions pod
             WHERE pod.line_location_id = plla.line_location_id)));

        IF (l_not_delivered = 1) THEN

          IF (g_fnd_debug = 'Y') THEN
            IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
              fnd_log.string(fnd_log.level_statement,
                             g_module_prefix || l_api_name,
                             'Req Line ID:' || p_req_line_id || ' ' ||
                             'Shipment Received but not Delivered');
            END IF;
          END IF;

          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;

      EXCEPTION
        WHEN no_data_found THEN
        NULL;
      END;

      l_progress := '009';

        -- PO distribution checks
      BEGIN

        SELECT 1
        INTO l_dist_not_valid
        FROM
          po_line_locations_all poll,
          po_distributions_all pod,
          gl_code_combinations gcc
        WHERE
          poll.line_location_id = l_po_line_loc_id AND
          pod.line_location_id = poll.line_location_id AND
          gcc.code_combination_id = pod.code_combination_id AND
          ((trunc(SYSDATE) NOT BETWEEN
            nvl(gcc.start_date_active, trunc(SYSDATE) - 1) AND
            nvl(gcc.end_date_active, trunc(SYSDATE) + 1)
           ) OR
           pod.quantity_billed > pod.quantity_ordered OR  -- fully billed
           pod.quantity_delivered > pod.quantity_ordered OR -- over delivered
           (pod.quantity_ordered >= pod.quantity_billed AND -- over billed
            nvl(poll.receipt_required_flag, 'Y') <> 'N' AND
            pod.quantity_billed > pod.quantity_delivered) OR
           pod.amount_billed > pod.amount_ordered OR
           pod.amount_delivered > pod.amount_ordered OR
           (pod.amount_ordered >= pod.amount_billed AND
            nvl(poll.receipt_required_flag, 'Y') <> 'N' AND
            pod.amount_billed > pod.amount_delivered));

        IF (l_dist_not_valid = 1) THEN

          IF (g_fnd_debug = 'Y') THEN
            IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
              fnd_log.string(fnd_log.level_statement,
                             g_module_prefix || l_api_name,
                             'Req Line ID:' || p_req_line_id || ' ' ||
                             'Distribution Checks Failed');
            END IF;
          END IF;

          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;

      EXCEPTION
        WHEN no_data_found THEN
        NULL;
      END;

      l_progress := '010';

      IF (l_po_release_id IS NULL) THEN
        l_po_doc_type := 'PO';
        l_po_doc_subtype := 'STANDARD';

          -- get org id of the PO
        SELECT org_id
        INTO l_po_org_id
        FROM po_headers_all
        WHERE po_header_id = l_po_header_id;
      ELSE
        l_po_doc_type := 'RELEASE';
        l_po_doc_subtype := 'BLANKET';
        l_po_line_id := NULL;

          -- select org id of the release
        SELECT agent_id, org_id
            INTO l_agent_id, l_po_org_id
        FROM po_releases_all
        WHERE po_release_id = l_po_release_id;
      END IF;

      l_progress := '011';

        -- save current org id
      l_req_org_id := mo_global.get_current_org_id();

        -- Set the org context before calling the cancel api
      po_moac_utils_pvt.set_org_context(l_po_org_id) ;         -- <R12 MOAC>

      l_progress := '012';

      po_document_control_grp.check_control_action(
                                                   p_api_version      => 1.0,
                                                   p_init_msg_list    => fnd_api.g_true,
                                                   x_return_status    => l_return_status,
                                                   p_doc_type         => l_po_doc_type,
                                                   p_doc_subtype      => l_po_doc_subtype,
                                                   p_doc_id           => l_po_header_id,
                                                   p_doc_num 	     => NULL,
                                                   p_release_id 	     => l_po_release_id,
                                                   p_release_num	     => NULL,
                                                   p_doc_line_id      => l_po_line_id,
                                                   p_doc_line_num     => NULL,
                                                   p_doc_line_loc_id  => l_po_line_loc_id,
                                                   p_doc_shipment_num => NULL,
                                                   p_action           => 'CANCEL');

      l_progress := '013';

        -- set org context to the original value
      po_moac_utils_pvt.set_org_context(l_req_org_id) ;         -- <R12 MOAC>

      IF (g_fnd_debug = 'Y') THEN
        IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
          fnd_log.string(fnd_log.level_statement,
                         g_module_prefix || l_api_name,
                         'PO_Document_Control_GRP.check_control_action result:' || l_return_status);
        END IF;
      END IF;

      IF (l_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status := fnd_api.g_ret_sts_success;
      ELSE
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

    END IF;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF (g_fnd_debug = 'Y') THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception',
                       p_req_line_id || '*' || l_progress || ':' || SQLERRM);
      END IF;
    END IF;
  END is_req_line_cancellable;

/*--------------------------------------------------------------
* IS_REQ_LINE_CHANGEABLE: For a particular Requisition line,
* this API checks if the line be changed/cancelled, or if price,
* date, and quantity associated with that the line can be changed.
* Called Directly from UI, per req line.
----------------------------------------------------------------*/
  PROCEDURE is_req_line_changeable(p_api_version IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   p_req_line_id IN NUMBER,
                                   p_price_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_date_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_qty_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_start_date_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_end_date_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_amount_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_cancellable_flag OUT NOCOPY VARCHAR2)
  IS
  l_api_name VARCHAR2(50) := 'IS_REQ_LINE_CHANGEABLE';
  l_progress VARCHAR2(100) := '000';
  l_line_changeable_flag VARCHAR2(1);
  l_line_loc_id NUMBER;
  l_source_type_code po_requisition_lines_all.source_type_code%TYPE;
  l_auction_display_number po_requisition_lines_all.auction_display_number%TYPE;
  l_auction_line_number NUMBER;
  l_reqs_in_pool_flag po_requisition_lines_all.reqs_in_pool_flag%TYPE;
  l_authorization_status po_headers_all.authorization_status%TYPE;
  l_frozen_flag VARCHAR2(1);
  l_closed_code po_headers_all.closed_code%TYPE;
  l_cancel_flag po_headers_all.cancel_flag%TYPE;
  l_catalog_type po_requisition_lines_all.catalog_type%TYPE;
  l_allow_price_override_flag po_lines_all.allow_price_override_flag%TYPE;
  l_accrue_on_receipt_flag po_line_locations_all.accrue_on_receipt_flag%TYPE;
  l_qty_received NUMBER;
  l_qty_billed NUMBER;
  l_count NUMBER;
  l_release_id NUMBER;
  l_return_status VARCHAR2(1);
  l_line_type po_line_types.purchase_basis%TYPE;
  l_global_agreement_flag po_headers_all.global_agreement_flag%TYPE;
  l_order_type_lookup_code po_requisition_lines_all.order_type_lookup_code%TYPE ;
  l_po_header_id po_headers_all.po_header_id%TYPE;
  l_template_id po_requisition_lines_all.noncat_template_id%TYPE;
  l_price_editable_flag por_noncat_templates_all_b.price_editable_flag%TYPE;
  l_amount_editable_flag por_noncat_templates_all_b.amount_editable_flag%TYPE;
-- added for retroactive pricing checks
  l_retropricing VARCHAR2(20) := '';
  l_amount_based_service_line BOOLEAN := FALSE;
  l_destination_type_code po_requisition_lines_all.destination_type_code%TYPE;
  l_is_on_complex_work_po VARCHAR2(1);
  l_transferred_to_oe_flag varchar2(1);
  l_price_updateable varchar2(1);
  BEGIN


    x_return_status := fnd_api.g_ret_sts_success;
    l_line_changeable_flag := 'Y';
    p_price_changeable_flag := 'Y';
    p_date_changeable_flag := 'Y';
    p_qty_changeable_flag := 'Y';
    p_start_date_changeable_flag := 'Y';
    p_end_date_changeable_flag := 'Y';
    p_amount_changeable_flag := 'Y';
    p_cancellable_flag := 'Y';

    l_progress := '000';

    l_retropricing := fnd_profile.value('PO_ALLOW_RETROPRICING_OF_PO');

    SELECT
        prla.purchase_basis,
        prla.line_location_id,
        prla.source_type_code,
        prla.auction_display_number,
        prla.auction_line_number,
        prla.reqs_in_pool_flag,
        nvl(prla.catalog_type,' '),
            prla.noncat_template_id,
            prla.destination_type_code,
            prha.transferred_to_oe_flag
    INTO
        l_line_type,
        l_line_loc_id,
        l_source_type_code,
        l_auction_display_number,
        l_auction_line_number,
        l_reqs_in_pool_flag,
        l_catalog_type,
        l_template_id,
        l_destination_type_code,
        l_transferred_to_oe_flag
    FROM
        po_requisition_lines_all prla,
        po_requisition_headers_all prha
    WHERE
            prla.requisition_line_id = p_req_line_id AND
            prla.requisition_header_id = prha.requisition_header_id;

-- for non catalog items with templates amount and price
-- update depends on template definition
    IF (l_template_id IS NOT NULL) THEN
      begin
        SELECT price_editable_flag, amount_editable_flag
        INTO l_price_editable_flag, l_amount_editable_flag
        FROM por_noncat_templates_all_b
        WHERE template_id = l_template_id;
      exception when NO_DATA_FOUND then
        l_price_editable_flag:='Y';
        l_amount_editable_flag:='Y';
      end;
      IF (l_price_editable_flag = 'N') THEN
        p_price_changeable_flag := 'N';
      END IF;

      IF (l_amount_editable_flag = 'N') THEN
        p_amount_changeable_flag := 'N';
      END IF;

    END IF;

-- If Req is linked to complex work.. RCO can not be done.
    is_on_complex_work_order(l_line_loc_id, l_is_on_complex_work_po);

    IF(l_destination_type_code = 'EXPENSE' AND l_is_on_complex_work_po = 'Y') THEN
      l_line_changeable_flag := 'N';
      p_price_changeable_flag := 'N';
      p_date_changeable_flag := 'N';
      p_qty_changeable_flag := 'N';
      p_start_date_changeable_flag := 'N';
      p_end_date_changeable_flag := 'N';
      p_amount_changeable_flag := 'N';
      p_cancellable_flag := 'N';
    END IF;

    IF(l_line_changeable_flag = 'Y') THEN
      IF (l_line_type = 'GOODS') THEN
        IF (l_template_id IS NULL) THEN
          p_amount_changeable_flag := 'N';
        END IF;
        p_start_date_changeable_flag := 'N';
        p_end_date_changeable_flag := 'N';

      ELSIF(l_line_type = 'TEMP LABOR' OR l_line_type = 'SERVICES') THEN

        p_qty_changeable_flag := 'N';
        p_price_changeable_flag := 'N';
        p_date_changeable_flag := 'N';
        p_start_date_changeable_flag := 'Y';
        p_end_date_changeable_flag := 'Y';

        SELECT order_type_lookup_code
        INTO l_order_type_lookup_code
        FROM po_requisition_lines_all
        WHERE requisition_line_id = p_req_line_id;

        IF (l_line_type = 'SERVICES') THEN
          p_date_changeable_flag := 'Y';
          p_start_date_changeable_flag := 'N';
          p_end_date_changeable_flag := 'N';

          -- checking order type lookup code for amount based service lines
          IF (l_order_type_lookup_code <> 'FIXED PRICE') THEN
            p_qty_changeable_flag := 'Y';
            p_amount_changeable_flag := 'N';
            l_amount_based_service_line := TRUE;
          END IF;

        END IF;

        IF(l_line_type = 'TEMP LABOR' AND l_order_type_lookup_code = 'RATE') THEN
		-- for rate-based temp labor line, the budget amount can be modified
          p_amount_changeable_flag := 'Y';

        ELSIF (NOT l_amount_based_service_line) THEN
		-- for fixed price temp labor line and fixed price services line,
		--   if there is a backing GBPA,
		--     if the price override allowed flag is Y, the labor amount can be changed
		--     if the price override allowed flag is N, the labor amount can not be changed.
		--   if there is not a backing GBPA, the labor anount can be changed

          SELECT  pha.global_agreement_flag, pha.po_header_id
          INTO    l_global_agreement_flag, l_po_header_id
          FROM 	po_headers_all pha,
              po_requisition_lines_all prla
          WHERE   pha.po_header_id (+ ) = prla.blanket_po_header_id
          AND     prla.requisition_line_id = p_req_line_id;

          IF(l_global_agreement_flag = 'Y') THEN
            BEGIN
              SELECT pla.allow_price_override_flag
  INTO l_allow_price_override_flag
  FROM 	po_requisition_lines_all prl,
      po_headers_all pha,
      po_lines_all pla
  WHERE	pha.po_header_id = l_po_header_id
      AND     pla.po_header_id = pha.po_header_id
  AND 	prl.blanket_po_line_num = pla.line_num
  AND     prl.requisition_line_id = p_req_line_id;

                       -- in GCPA case, there is no po line associated with po header
                       -- above query will result in no_data_found exception. catch GCPA case in exception block

              IF(l_allow_price_override_flag = 'Y') THEN
                p_amount_changeable_flag := 'Y';
              ELSE
                p_amount_changeable_flag := 'N';
              END IF;

                     -- in GCPA case, user is allowed to change amount

            EXCEPTION
              WHEN no_data_found THEN
              p_amount_changeable_flag := 'Y';
            END;


          ELSE
            p_amount_changeable_flag := 'Y';
          END IF;
        END IF;

      END IF;

  /*
  **Validation #1,#2,#3,#7 in DLD
  */


      l_progress := '001';

  --In the following validation,
  --#1-#6 are shared by different type of requisition lines: GOODS, TEMP LABOR, SERVICES
  --#7-#11 are only for GOODS
  -- bug 13983258: able to edit price for catalog items based on profile
  l_price_updateable := fnd_profile.value('POR_ALLOW_PRICE_UPDATE');
  --Is there an internal order associated with line?(Validation #2 in DLD)
      IF (l_source_type_code = 'INVENTORY') THEN
        l_line_changeable_flag := 'N';

        IF ( nvl(l_transferred_to_oe_flag,'N') = 'Y'  ) THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
        Else
             is_internal_line_cancellable(1.0, l_return_status, p_req_line_id);
        END IF;

        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          p_cancellable_flag := 'N';
        END IF;

  --Is there any PO associated with line?(Validation #1 in DLD)
      ELSIF(l_line_loc_id IS NULL) THEN
        l_line_changeable_flag := 'N';
  --Price change is allowed ONLY on non-catalog items(Validation #7 in DLD)
      ELSIF(l_line_type = 'GOODS' AND l_catalog_type <> 'NONCATALOG' AND l_price_updateable <> 'Y' )THEN
        p_price_changeable_flag := 'N';
      END IF;
    END IF;-- end of l_line_changeable_flag='Y' check

    l_progress := '002';

/*
**Validation #4,#5,#8,#10,#11 in DLD
*/
    IF(l_line_changeable_flag = 'Y') THEN

      SELECT po_release_id INTO l_release_id
      FROM po_line_locations_all
      WHERE line_location_id = l_line_loc_id;

      IF(l_release_id IS NULL) THEN


        SELECT
            nvl(pha.authorization_status,' '),
            nvl(plla.closed_code, 'OPEN'),
            nvl(plla.cancel_flag, 'N'),
            --nvl(pla.allow_price_override_flag, 'N'), --Bug:16100167
            plla.accrue_on_receipt_flag,
            plla.quantity_received,
            plla.quantity_billed,
            nvl(pha.frozen_flag, 'N')
        INTO
            l_authorization_status ,
            l_closed_code,
            l_cancel_flag,
            --l_allow_price_override_flag,
            l_accrue_on_receipt_flag,
            l_qty_received,
            l_qty_billed,
            l_frozen_flag
        FROM
            po_headers_all pha,
            po_lines_all pla,
            po_line_locations_all plla,
            po_requisition_lines_all prla
        WHERE pha.po_header_id = plla.po_header_id
        AND pla.po_line_id = plla.po_line_id
        AND plla.line_location_id = prla.line_location_id
        AND prla.requisition_line_id = p_req_line_id;

      ELSE

        SELECT
            nvl(pra.authorization_status,' '),
            nvl(plla.closed_code, 'OPEN'),
            nvl(plla.cancel_flag, 'N'),
            --nvl(pla.allow_price_override_flag, 'N'),  --Bug:16100167
            plla.accrue_on_receipt_flag,
            plla.quantity_received,
            plla.quantity_billed,
            nvl(pra.frozen_flag,' ')
        INTO
            l_authorization_status ,
            l_closed_code,
            l_cancel_flag,
            --l_allow_price_override_flag,
            l_accrue_on_receipt_flag,
            l_qty_received,
            l_qty_billed,
            l_frozen_flag
        FROM
            po_lines_all pla,
            po_line_locations_all plla,
            po_requisition_lines_all prla,
            po_releases_all pra
        WHERE pla.po_line_id = plla.po_line_id
        AND plla.line_location_id = prla.line_location_id
        AND prla.requisition_line_id = p_req_line_id
        AND pra.po_release_id = plla.po_release_id;


      END IF;

      --Bug:16423039 Consider the override flag on GBPA/BPA in RCO,NOT SPO/BPA Release
      SELECT DECODE(prla.document_type_code,'BLANKET',NVL(pla.allow_price_override_flag, 'N'),'Y')
      INTO l_allow_price_override_flag
      FROM po_lines_all pla,
           po_requisition_lines_all prla
      WHERE pla.line_num(+)        = prla.blanket_po_line_num
      AND pla.po_header_id(+)      = prla.blanket_po_header_id
      AND prla.requisition_line_id = p_req_line_id;

      l_progress := '003';
	--Check authorization status, closed code, cancel flag (Validation #4 and #5 in DLD)
      IF(l_frozen_flag = 'Y' OR l_authorization_status NOT IN('APPROVED') OR l_closed_code IN ('CLOSED','FINALLY CLOSED') OR l_cancel_flag <> 'N') THEN
        l_line_changeable_flag := 'N';
        p_cancellable_flag := 'N';

      ELSIF (l_closed_code IN ('CLOSED FOR INVOICE', 'CLOSED FOR RECEIVING') AND l_retropricing <> 'ALL_RELEASES') THEN
        p_price_changeable_flag := 'N';

	--Check for price override flag (Validation #8)
      ELSIF(l_line_type = 'GOODS' AND l_allow_price_override_flag = 'N') THEN
        p_price_changeable_flag := 'N';

	--Check accrue on receipt flag (Validation #10)
      ELSIF(l_line_type = 'GOODS' AND l_accrue_on_receipt_flag = 'Y' AND
            l_retropricing <> 'ALL_RELEASES') THEN
        p_price_changeable_flag := 'N';

	--If PO line has been partially received or invoiced (Validation #11)
      ELSIF(l_line_type = 'GOODS' AND l_retropricing <> 'ALL_RELEASES' AND
            (l_qty_received > 0 OR l_qty_billed >0)) THEN
        p_price_changeable_flag := 'N';
      END IF;



/*
* Valiation #6: Checking if p_req_line_id corresponds to PO Shipment PS1, and PS1 has multiple PO distributions, which correspond to
* multiple req distributions of multiple req lines or does not correspond to any req distributions:
* In this case, no change, no cancel
*/

      IF(l_line_changeable_flag = 'Y') THEN
        l_progress := '004';
        SELECT COUNT(DISTINCT nvl(prda.requisition_line_id, - 1))
        INTO l_count
        FROM
            po_req_distributions_all prda,
            po_distributions_all pda,
            po_requisition_lines_all prla
        WHERE pda.line_location_id = prla.line_location_id
        AND prla.requisition_line_id = p_req_line_id
        AND pda.req_distribution_id  = prda.distribution_id(+ );

        IF(l_count > 1) THEN
          l_line_changeable_flag := 'N';
          p_cancellable_flag := 'N';
        END IF;
      END IF;

      IF(l_line_changeable_flag = 'N') THEN
        p_price_changeable_flag := 'N';
        p_date_changeable_flag := 'N';
        p_qty_changeable_flag := 'N';
        p_start_date_changeable_flag := 'N';
        p_end_date_changeable_flag := 'N';
        p_amount_changeable_flag := 'N';
      END IF;

	/*
	* Extending Validation #6, if a req line correspond to the line of a Standard PO, its price can only be changed if
	* the req line is associated with a PO Shipment, which is the only shipment of its parent Line.
	*/
      IF(l_release_id IS NULL AND p_price_changeable_flag = 'Y') THEN
        l_progress := '005';
        SELECT COUNT(1)
        INTO l_count
        FROM
            po_requisition_lines_all prla,
            po_line_locations_all plla,
            po_line_locations_all plla2
        WHERE plla.line_location_id = prla.line_location_id
        AND prla.requisition_line_id = p_req_line_id
        AND plla2.po_line_id = plla.po_line_id;

        IF(l_count > 1) THEN
          p_price_changeable_flag := 'N';

        END IF;

      END IF;


    END IF;


    l_progress := '007';

/*
* At this point, if cancel_flag = 'Y', we will need to call another API which further checks if the line
* can be cancelled.
*/
    IF(p_cancellable_flag = 'Y') THEN
      is_req_line_cancellable(1.0, l_return_status, p_req_line_id, 'Y');
      IF(l_return_status = fnd_api.g_ret_sts_error) THEN
        p_cancellable_flag := 'N';
      END IF;
    END IF;

  EXCEPTION WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception',
                       p_req_line_id || '*' || l_progress || ':' || SQLERRM);
      END IF;
    END IF;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
  END is_req_line_changeable;

/*-------------------------------------------------------------------------------------------------
*This API is called directly from the UI. It will have PLSQL tables as input, which contain change/cancel requests
*1. Validate the requests
*2. If ALL valid, same them into PO_CHANGE_REQUESTS table
*x_return_status = 	FND_API.G_RET_STS_SUCCESS => Everything is Valid, and records are saved into change table
*					FND_API.G_RET_STS_ERROR => Caught Errors, thus no records are saved into change table
*					FND_API.G_RET_STS_UNEXP_ERROR => Unexpected Errors Occur in the API
*x_retMsg will indicate details/location of errors.
---------------------------------------------------------------------------------------------------*/
  PROCEDURE save_reqchange(p_api_version IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           p_req_hdr_id IN NUMBER,
                           p_change_table IN po_req_change_table,
                           p_cancel_table IN po_req_cancel_table,
                           p_change_request_group_id OUT NOCOPY NUMBER,
                           x_retmsg OUT NOCOPY VARCHAR2,
                           x_errtable OUT NOCOPY po_req_change_err_table)
  IS
  l_api_name VARCHAR2(50) := 'Save_ReqChange';
  l_req_change_table change_tbl_type;
  l_dummy NUMBER;
  y NUMBER := 1;
  l_change_result VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_cancel_result VARCHAR2(1);
  l_err_line_id_tbl po_tbl_number;
  l_err_line_num_tbl po_tbl_number;
  l_err_dist_id_tbl po_tbl_number;
  l_err_dist_num_tbl po_tbl_number;
  l_err_error_attr_tbl po_tbl_varchar30;
  l_err_msg_count_tbl po_tbl_number;
  l_err_msg_data_tbl po_tbl_varchar2000;
  l_irc_status VARCHAR2(1);
  l_irc_err_msg VARCHAR2(2000);
  l_catch_exception EXCEPTION;
  l_req_dist_id NUMBER;
  l_lineqty_status VARCHAR2(1);
  l_lineqty_msg VARCHAR2(2000);


  BEGIN

    DELETE FROM po_change_requests
    WHERE document_header_id = p_req_hdr_id
    AND request_status = 'SYSTEMSAVE'
    AND initiator = 'REQUESTER';



    x_retmsg := 'SRCH000';

    IF(p_change_table IS NOT NULL) THEN
	--Input Change Table is p_change_table, which is a table of objects. The following "for" loop
	--Copy the data from p_change_table to l_req_change_table, which is a table of record
      FOR x IN 1..p_change_table.req_line_id.count
        LOOP
                /* Start Date, End Date and Amount changes
                   Check if there is any change in start date or end date or amount
                   Set DOCUMENT_DISTRIBUTION_ID only when there is any change in amount
                   Handled Amount and Need By Date Combination for Fixed Price Lines*/
        IF((p_change_table.need_by(x) IS NOT NULL AND  p_change_table.amount(x) IS NOT NULL)
           OR p_change_table.start_date(x) IS NOT NULL
           OR p_change_table.end_date(x) IS NOT NULL
           OR p_change_table.amount(x) IS NOT NULL) THEN
          IF(p_change_table.start_date(x) IS NOT NULL) THEN
            l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
            l_req_change_table(y).new_start_date := p_change_table.start_date(x);
            l_req_change_table(y).request_reason := p_change_table.change_reason(x);
            y := y + 1;
          END IF;
          IF(p_change_table.end_date(x) IS NOT NULL) THEN
            l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
            l_req_change_table(y).new_end_date := p_change_table.end_date(x);
            l_req_change_table(y).request_reason := p_change_table.change_reason(x);
            y := y + 1;
          END IF;
          IF(p_change_table.amount(x) IS NOT NULL) THEN
            IF(p_change_table.req_dist_id(x) IS NULL) THEN
              BEGIN
                SELECT distribution_id
                INTO l_req_dist_id
                FROM po_req_distributions_all
                WHERE requisition_line_id = p_change_table.req_line_id(x);
                l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
                l_req_change_table(y).document_distribution_id := l_req_dist_id;
                l_req_change_table(y).new_budget_amount := p_change_table.amount(x);
                l_req_change_table(y).request_reason := p_change_table.change_reason(x);
                y := y + 1;
              EXCEPTION
                WHEN OTHERS THEN
                NULL;
              END;
            ELSE
              l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
              l_req_change_table(y).document_distribution_id := p_change_table.req_dist_id(x);
              l_req_change_table(y).new_budget_amount := p_change_table.amount(x);
              l_req_change_table(y).request_reason := p_change_table.change_reason(x);
              y := y + 1;
            END IF;
            IF (p_change_table.need_by(x) IS NOT NULL) THEN
              l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
              l_req_change_table(y).new_date := p_change_table.need_by(x);
              l_req_change_table(y).request_reason := p_change_table.change_reason(x);
              y := y + 1;
            END IF;
          END IF;
                /* Price, Need By, Quantity changes
                   Check if there is any change in price or need_by or quantity
                   Set DOCUMENT_DISTRIBUTION_ID only when there is any change in quantity */
        ELSIF(p_change_table.price(x) IS NOT NULL
              OR p_change_table.need_by(x) IS NOT NULL
              OR p_change_table.quantity(x) IS NOT NULL) THEN
          IF(p_change_table.need_by(x) IS NOT NULL) THEN
            l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
            l_req_change_table(y).new_date := p_change_table.need_by(x);
            l_req_change_table(y).request_reason := p_change_table.change_reason(x);
            y := y + 1;
          END IF;
          IF(p_change_table.price(x) IS NOT NULL) THEN
            l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
            l_req_change_table(y).new_price := p_change_table.price(x);
            l_req_change_table(y).request_reason := p_change_table.change_reason(x);
            y := y + 1;
          END IF;
          IF(p_change_table.quantity(x) IS NOT NULL) THEN
            IF(p_change_table.req_dist_id(x) IS NULL) THEN
              BEGIN
                SELECT distribution_id
                INTO l_req_dist_id
                FROM po_req_distributions_all
                WHERE requisition_line_id = p_change_table.req_line_id(x);
                l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
                l_req_change_table(y).document_distribution_id := l_req_dist_id;
                l_req_change_table(y).new_quantity := p_change_table.quantity(x);
                l_req_change_table(y).request_reason := p_change_table.change_reason(x);
                y := y + 1;
              EXCEPTION
                WHEN OTHERS THEN
                NULL;
              END;
            ELSE
              l_req_change_table(y).document_line_id := p_change_table.req_line_id(x);
              l_req_change_table(y).document_distribution_id := p_change_table.req_dist_id(x);
              l_req_change_table(y).new_quantity := p_change_table.quantity(x);
              l_req_change_table(y).request_reason := p_change_table.change_reason(x);
              y := y + 1;
            END IF;
          END IF;
        END IF;

      END LOOP;



	--Validate the Change Requests, by passing in l_req_change_table, a table of records
	--Initialize the Error Table
      l_err_line_id_tbl := po_tbl_number();
      l_err_line_num_tbl := po_tbl_number();
      l_err_dist_id_tbl := po_tbl_number();
      l_err_dist_num_tbl := po_tbl_number();
      l_err_error_attr_tbl := po_tbl_varchar30();
      l_err_msg_count_tbl := po_tbl_number();
      l_err_msg_data_tbl := po_tbl_varchar2000();
      x_errtable := po_req_change_err_table(
                                            l_err_line_id_tbl,
                                            l_err_line_num_tbl,
                                            l_err_dist_id_tbl,
                                            l_err_dist_num_tbl,
                                            l_err_error_attr_tbl,
                                            l_err_msg_count_tbl,
                                            l_err_msg_data_tbl);

      validate_changes(p_req_hdr_id, l_req_change_table, l_change_result, x_retmsg, x_errtable);
    END IF;

--If ALL changes are valid, we will insert change records, and insert cancel records(if any)
    IF(l_change_result = fnd_api.g_ret_sts_success) THEN
      x_retmsg := 'SRCH004';
      SELECT po_chg_request_seq.nextval INTO p_change_request_group_id FROM dual;

      insert_reqchange(l_req_change_table, p_change_request_group_id);
      x_retmsg := 'SRCH005';

      update_recordswithtax(p_change_request_group_id);
      x_retmsg := 'SRCH006';

      insert_linequantityoramount(p_change_request_group_id);

      x_retmsg := 'SRCH0061';

      insert_pricebreakrows(p_change_request_group_id);

      x_retmsg := 'SRCH0062';

	--Process Cancellation Requests
      l_cancel_result := fnd_api.g_ret_sts_success;

      IF(p_cancel_table IS NOT NULL) THEN
        save_reqcancel(1.0, l_cancel_result, p_req_hdr_id, p_cancel_table, l_dummy, x_retmsg, p_change_request_group_id);
      END IF;

      x_return_status := l_cancel_result;
    ELSIF(l_change_result = fnd_api.g_ret_sts_error) THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_retmsg := 'SRCH007';
    ELSE
      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    x_retmsg := 'SRCHUNEXP:' || x_retmsg || ':' || SQLERRM;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', x_retmsg);
      END IF;
    END IF;
  END save_reqchange;

/*--------------------------------------------------------------
**Save_ReqCancel: takes in a PLSQL table as input, containing
**cancellation request. No Validation is done here. This API
**simply insert records into PO_CHANGE_REQUESTS table
---------------------------------------------------------------*/
  PROCEDURE save_reqcancel(p_api_version IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           p_req_hdr_id IN NUMBER,
                           p_cancel_table IN po_req_cancel_table,
                           p_change_request_group_id OUT NOCOPY NUMBER,
                           x_retmsg OUT NOCOPY VARCHAR2,
                           p_grp_id IN NUMBER)
  IS
  l_api_name VARCHAR2(50) := 'Save_ReqCancel';
  l_chn_req_id NUMBER;
  l_req_num po_requisition_headers_all.segment1%TYPE;
  l_req_line_num NUMBER;
  l_req_user_id NUMBER;
  l_line_loc_id NUMBER;
  l_po_header_id NUMBER;
  l_po_release_id NUMBER;
  l_po_revision_num NUMBER;
  l_preparer_id NUMBER;
  l_req_price NUMBER;
  l_req_currency_price NUMBER;
  l_req_quantity NUMBER;
  l_req_date	DATE;
  l_po_num po_change_requests.ref_po_num%TYPE;
  l_po_release_num NUMBER;
  BEGIN
    x_retmsg := '000';
    l_req_user_id := fnd_global.user_id;


    IF(p_grp_id IS NULL) THEN
      SELECT po_chg_request_seq.nextval INTO p_change_request_group_id FROM dual;
      DELETE FROM po_change_requests
      WHERE document_header_id = p_req_hdr_id
      AND initiator = 'REQUESTER'
      AND request_status = 'SYSTEMSAVE';
    ELSE
      p_change_request_group_id := p_grp_id;
    END IF;
    x_retmsg := '001';
    FOR i IN 1..p_cancel_table.req_line_id.count
      LOOP

      SELECT po_chg_request_seq.nextval INTO l_chn_req_id FROM dual;
      SELECT
          prha.segment1,
          prla.line_num,
          prla.line_location_id,
          prha.preparer_id,
          prla.unit_price,
          prla.quantity,
          prla.need_by_date,
          prla.currency_unit_price
      INTO
          l_req_num,
          l_req_line_num,
          l_line_loc_id,
          l_preparer_id,
          l_req_price,
          l_req_quantity,
          l_req_date,
          l_req_currency_price
      FROM
          po_requisition_headers_all prha,
          po_requisition_lines_all prla
      WHERE prla.requisition_line_id = p_cancel_table.req_line_id(i)
      AND prla.requisition_header_id = prha.requisition_header_id;

      IF(l_line_loc_id IS NOT NULL) THEN
        SELECT
            po_release_id,
            po_header_id
        INTO
            l_po_release_id,
            l_po_header_id
        FROM po_line_locations_all
        WHERE line_location_id = l_line_loc_id;
        IF(l_po_release_id IS NULL) THEN
          SELECT revision_num, segment1 INTO
          l_po_revision_num, l_po_num
          FROM po_headers_all
          WHERE po_header_id = l_po_header_id;

                                -- bug 5191164.
                                -- Need to null out l_po_release_num for PO records
          l_po_release_num := NULL;

        ELSE
                                -- get po_number of the source document for RELEASE
          SELECT segment1 INTO l_po_num
          FROM po_headers_all
          WHERE po_header_id = l_po_header_id;

          SELECT revision_num, release_num
          INTO l_po_revision_num, l_po_release_num
          FROM po_releases_all
          WHERE po_release_id = l_po_release_id;
        END IF;
      END IF;
      x_retmsg := '002';
      INSERT INTO po_change_requests
      (
          change_request_group_id,
          change_request_id,
          initiator,
          action_type,
          request_reason,
          request_level,
          request_status,
          document_type,
          document_header_id,
          document_num,
          document_revision_num,
          created_by,
          creation_date,
          document_line_id,
          document_line_number,
          last_updated_by,
          last_update_date,
          last_update_login,
          requester_id,
          change_active_flag,
          old_price,
          old_quantity,
          old_need_by_date,
          old_currency_unit_price,
          ref_po_header_id,
          ref_po_num,
          ref_po_release_id,
          ref_po_rel_num )
      VALUES
      (
          p_change_request_group_id,
          l_chn_req_id,
          'REQUESTER',
          'CANCELLATION',
          p_cancel_table.change_reason(i),
          'LINE',
          'SYSTEMSAVE',
          'REQ',
          p_req_hdr_id,
          l_req_num,
          l_po_revision_num,
          l_req_user_id,
          SYSDATE,
          p_cancel_table.req_line_id(i),
          l_req_line_num,
          l_req_user_id,
          SYSDATE,
          l_req_user_id,
          l_preparer_id,
          'Y',
          l_req_price,
          l_req_quantity,
          l_req_date,
          l_req_currency_price,
          l_po_header_id,
          l_po_num,
          l_po_release_id,
          l_po_release_num
      );


    END LOOP;


    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', x_retmsg || ':' || SQLERRM);
      END IF;
    END IF;
  END save_reqcancel;

/*-----------------------------------------------------------------------------------------------------
* At the Final Stage of Requester Creating Change request, SUBMIT_REQCHANGE will be executed to complete
* the transaction. This API takes care of funds Check, and does a final round of validation against
* all change/cancel requests before kicking off the Workflow.
----------------------------------------------------------------------------------------------------*/
  PROCEDURE submit_reqchange (
                              p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_group_id IN NUMBER,
                              p_fundscheck_flag IN VARCHAR2,
                              p_note_to_approver IN VARCHAR2,
                              p_initiator IN VARCHAR2,
                              x_retmsg OUT NOCOPY VARCHAR2,
                              x_errcode OUT NOCOPY VARCHAR2,
                              x_errtable OUT NOCOPY po_req_change_err_table)
  IS
  l_api_name VARCHAR2(50) := 'Submit_ReqChange';
  i NUMBER := 1;
  l_cancelerrorsize NUMBER;
  l_flag_one VARCHAR2(1);
  l_flag_two VARCHAR2(1);
--l_FC_Tbl po_fcin_type;
  l_req_dist_id NUMBER;
  l_req_line_id NUMBER;
  l_req_hdr_id NUMBER;
  l_req_num po_requisition_headers_all.segment1%TYPE;
  l_po_num po_headers_all.segment1%TYPE;
  l_header_id                NUMBER;
  l_release_id			   NUMBER;
  l_line_id                  NUMBER;
  l_shipment_id              NUMBER;
  l_distribution_id          NUMBER;
  l_budget_account_id 		NUMBER;
  l_gl_date					DATE;
  l_vendor_id 				NUMBER;
  l_old_price					NUMBER;
  l_old_quantity				NUMBER;
  l_old_tax					NUMBER;
  l_ship_to_org_id 	NUMBER;
  l_ship_to_loc_id	NUMBER;
  l_price_changed_flag VARCHAR2(1) := fnd_api.g_false;
  l_qty_changed_flag VARCHAR2(1) := fnd_api.g_false;
  l_change_exist VARCHAR2(1);
  l_cancel_exist VARCHAR2(1);
  l_new_price	NUMBER;
  l_new_quantity NUMBER;
  l_new_po_quantity NUMBER;
  l_rec_tax NUMBER;
  l_nonrec_tax NUMBER;
  l_new_tax NUMBER;
  l_entered_dr NUMBER;
  l_entered_cr NUMBER;
  l_org_id NUMBER;
  l_fc_out_tbl po_fcout_type;
  l_fc_result_code VARCHAR2(1);
  l_fc_result_status VARCHAR2(1);
  l_fc_msg_count NUMBER;
  l_fc_msg_data VARCHAR2(2000);
  l_fc_req_line_id NUMBER;
  l_fc_req_line_num NUMBER;
  l_fc_req_distr_id NUMBER;
  l_fc_req_distr_num NUMBER;
  l_req_change_table change_tbl_type;
  l_new_date DATE;
  l_new_need_by_date DATE;
  l_old_need_by_date DATE;
  l_old_amount NUMBER;
  l_new_amount NUMBER;
  l_price_break VARCHAR2(1);
  -- l_set_of_books_id NUMBER;
  -- l_gl_period GL_PERIOD_STATUSES.PERIOD_NAME%TYPE;

  l_request_reason po_change_requests.request_reason%TYPE;
  l_cancel_errtable po_req_change_err_table;
  l_cal_disttax_status VARCHAR2(1);
  l_item_id NUMBER;
  l_req_uom po_requisition_lines_all.unit_meas_lookup_code%TYPE;
  l_po_uom po_line_locations_all.unit_meas_lookup_code%TYPE;
  l_po_to_req_rate NUMBER;

  l_po_return_code VARCHAR2(100) := '';
  l_err_line_id_tbl po_tbl_number;
  l_err_line_num_tbl po_tbl_number;
  l_err_dist_id_tbl po_tbl_number;
  l_err_dist_num_tbl po_tbl_number;
  l_err_error_attr_tbl po_tbl_varchar30;
  l_err_msg_count_tbl po_tbl_number;
  l_err_msg_data_tbl po_tbl_varchar2000;
  l_wf_status VARCHAR2(1);
  l_distribution_id_tbl po_tbl_number;

  CURSOR l_changes_csr(grp_id NUMBER) IS
  SELECT
      document_header_id,
      document_line_id,
      document_distribution_id,
      new_quantity,
      new_price,
      new_need_by_date,
      request_reason
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND action_type = 'MODIFICATION';

  CURSOR l_cancel_csr(grp_id NUMBER) IS
  SELECT
      document_header_id,
      document_line_id,
      request_reason
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND action_type = 'CANCELLATION';


  CURSOR l_dist_qty_price_chn_csr(grp_id NUMBER) IS
  SELECT
    document_line_id line_id,
    document_distribution_id dist_id,
    document_header_id hdr_id,
    document_num req_num
  FROM
    po_change_requests
  WHERE
    change_request_group_id = grp_id AND
    (new_quantity IS NOT NULL OR new_amount IS NOT NULL) AND
    action_type = 'MODIFICATION'
  UNION
  SELECT
    prda.requisition_line_id line_id,
    prda.distribution_id dist_id,
    prla.requisition_header_id hdr_id,
    prha.segment1	req_num
  FROM
    po_req_distributions_all prda,
    po_requisition_lines_all prla,
    po_change_requests pcr,
    po_requisition_headers_all prha
  WHERE
    prha.requisition_header_id = prla.requisition_header_id AND
    prla.requisition_line_id = prda.requisition_line_id AND
    pcr.document_line_id = prla.requisition_line_id AND
    pcr.change_request_group_id = grp_id AND
    pcr.action_type = 'MODIFICATION' AND (pcr.new_price IS NOT NULL OR
       pcr.new_need_by_date IS NOT NULL);

-- list of standard po distributions effected with the req changes
  CURSOR l_changed_po_dists_csr(grp_id NUMBER) IS
  SELECT           -- any quantity or amount change
    pda.po_distribution_id
  FROM
    po_change_requests pcr,
    po_req_distributions_all prda,
    po_distributions_all pda,
    po_headers_all pha
  WHERE
    pcr.change_request_group_id = grp_id AND
    (pcr.new_quantity IS NOT NULL OR pcr.new_amount IS NOT NULL) AND
    pcr.action_type = 'MODIFICATION' AND
    pcr.document_distribution_id = prda.distribution_id AND
    prda.distribution_id = pda.req_distribution_id AND
    pda.po_header_id = pha.po_header_id AND
    pha.type_lookup_code = 'STANDARD'
  UNION
  SELECT  -- select distributions that are effected with any line change
    pda.po_distribution_id
  FROM
    po_change_requests pcr,
    po_requisition_lines_all prla,
    po_req_distributions_all prda,
    po_distributions_all pda,
    po_headers_all pha
  WHERE
    pcr.change_request_group_id = grp_id AND
    pcr.action_type = 'MODIFICATION' AND
    (pcr.new_price IS NOT NULL OR pcr.new_need_by_date IS NOT NULL) AND
    pcr.document_line_id = prla.requisition_line_id AND
    prla.requisition_line_id = prda.requisition_line_id AND
    prda.distribution_id = pda.req_distribution_id AND
    pda.po_header_id = pha.po_header_id AND
    pha.type_lookup_code = 'STANDARD';

-- list of release distributions effected with the req changes
  CURSOR l_changed_rel_dists_csr(grp_id NUMBER) IS
  SELECT -- any quantity or amount change
    pda.po_distribution_id
  FROM
    po_change_requests pcr,
    po_req_distributions_all prda,
    po_distributions_all pda,
    po_requisition_lines_all prla,
    po_line_locations_all plla
  WHERE
    pcr.change_request_group_id = grp_id AND
    (pcr.new_quantity IS NOT NULL OR pcr.new_amount IS NOT NULL) AND
    pcr.action_type = 'MODIFICATION' AND
    pcr.document_distribution_id = prda.distribution_id AND
    prda.distribution_id = pda.req_distribution_id AND
    prla.requisition_line_id = prda.requisition_line_id AND
    prla.line_location_id = plla.line_location_id AND
    plla.po_release_id IS NOT NULL
  UNION -- select distributions that are effected with any line change
  SELECT
    pda.po_distribution_id
  FROM
    po_change_requests pcr,
    po_requisition_lines_all prla,
    po_req_distributions_all prda,
    po_distributions_all pda,
    po_line_locations_all plla
  WHERE
    pcr.change_request_group_id = grp_id AND
    pcr.action_type = 'MODIFICATION' AND
    (pcr.new_price IS NOT NULL OR pcr.new_need_by_date IS NOT NULL) AND
    pcr.document_line_id = prla.requisition_line_id AND
    prla.requisition_line_id = prda.requisition_line_id AND
    prda.distribution_id = pda.req_distribution_id AND
    prla.line_location_id = plla.line_location_id AND
    plla.po_release_id IS NOT NULL;


  BEGIN
    x_retmsg := 'SMRCH000';
    x_return_status := fnd_api.g_ret_sts_success;

	--Check if Funds Check is needed
    SELECT
        nvl(fsp.req_encumbrance_flag, 'N'),
        nvl(fsp.purch_encumbrance_flag, 'N')
    INTO
        l_flag_one,
        l_flag_two
    FROM financials_system_parameters fsp;

	--Check if change request exist
    l_change_exist := 'N';
    OPEN l_changes_csr(p_group_id);
    FETCH l_changes_csr
    INTO l_req_hdr_id, l_req_line_id, l_req_dist_id, l_new_quantity, l_new_price, l_new_date, l_request_reason;
    IF(l_req_hdr_id IS NOT NULL) THEN
      l_change_exist := 'Y';
    END IF;
    CLOSE l_changes_csr;

	--Check if cancel request exist
    l_cancel_exist := 'N';
    OPEN l_cancel_csr(p_group_id);
    FETCH l_cancel_csr
    INTO l_req_hdr_id, l_req_line_id, l_request_reason;
    IF(l_req_hdr_id IS NOT NULL) THEN
      l_cancel_exist := 'Y';
    END IF;
    CLOSE l_cancel_csr;


    x_retmsg := 'SMRCH001';

	--Funds Check Starts
    IF (l_change_exist = 'Y' AND p_fundscheck_flag = 'Y' AND (l_flag_one <> 'N' OR l_flag_two <> 'N')) THEN

      x_retmsg := 'SMRCH002';
		--Check if any records require funds check.
      OPEN l_dist_qty_price_chn_csr(p_group_id);
      FETCH l_dist_qty_price_chn_csr INTO
      l_req_line_id,
      l_req_dist_id,
      l_req_hdr_id,
      l_req_num;
      CLOSE l_dist_qty_price_chn_csr;

      IF (l_req_num IS NOT NULL) THEN

                  -- initialize distributions list table
        l_distribution_id_tbl	:= po_tbl_number();

                  -- insert NEW/OLD records of standard po distributions into PO_ENCUMBRANCE_GT
        OPEN l_changed_po_dists_csr(p_group_id);

        FETCH l_changed_po_dists_csr BULK COLLECT
        INTO l_distribution_id_tbl;

        CLOSE l_changed_po_dists_csr;

        po_document_funds_grp.populate_encumbrance_gt(
                                                      p_api_version => 1.0,
                                                      x_return_status => x_return_status,
                                                      p_doc_type => po_document_funds_grp.g_doc_type_po,
                                                      p_doc_level => po_document_funds_grp.g_doc_level_distribution,
                                                      p_doc_level_id_tbl => l_distribution_id_tbl,
                                                      p_make_old_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_make_new_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_check_only_flag => po_document_funds_grp.g_parameter_yes);

                    -- error handling after calling populate_encumbrance_gt
        IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
          x_retmsg := 'After calling populate_encumbrance_gt';
          x_errcode := 'FC_FAIL';
          RETURN;
        END IF;

                  -- insert NEW/OLD records of release distributions into PO_ENCUMBRANCE_GT

                  -- re-initialize distributions list table
        l_distribution_id_tbl.delete;

                  -- insert standard po distributions into PO_ENCUMBRANCE_GT
        OPEN l_changed_rel_dists_csr(p_group_id);

        FETCH l_changed_rel_dists_csr BULK COLLECT
        INTO l_distribution_id_tbl;

        CLOSE l_changed_rel_dists_csr;

        po_document_funds_grp.populate_encumbrance_gt(
                                                      p_api_version => 1.0,
                                                      x_return_status => x_return_status,
                                                      p_doc_type => po_document_funds_grp.g_doc_type_release,
                                                      p_doc_level => po_document_funds_grp.g_doc_level_distribution,
                                                      p_doc_level_id_tbl => l_distribution_id_tbl,
                                                      p_make_old_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_make_new_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_check_only_flag => po_document_funds_grp.g_parameter_yes);

                    -- error handling after calling populate_encumbrance_gt
        IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
          x_retmsg := 'After calling populate_encumbrance_gt (release)';
          x_errcode := 'FC_FAIL';
          RETURN;
        END IF;

                    -- Update NEW record in PO_ENCUMBRANCE_GT with the new
                    -- values


        x_retmsg := 'SMRCH003';
			/*
			*Looping through the distribution records which requires fundscheck, and populating the fundscheck
			*input table with the appropriate data.
			*/
        OPEN l_dist_qty_price_chn_csr(p_group_id);

        LOOP
          FETCH l_dist_qty_price_chn_csr INTO
          l_req_line_id,
          l_req_dist_id,
          l_req_hdr_id,
          l_req_num;

          EXIT WHEN l_dist_qty_price_chn_csr%notfound;
          x_retmsg := 'SMRCH0031:' || l_req_line_id || '*' || l_req_dist_id || '*' || l_req_hdr_id || '*' || l_req_num;

          SELECT
              plla.line_location_id,
              pda.po_distribution_id,
              plla.po_line_id,
              nvl(plla.price_override, pla.unit_price),
              pda.quantity_ordered,
                                  pda.amount_ordered,
              prla.item_id,
              prla.unit_meas_lookup_code,
              nvl(plla.unit_meas_lookup_code, pla.unit_meas_lookup_code),
              pha.rate,
              plla.need_by_date,
              plla.ship_to_organization_id,
              plla.ship_to_location_id
          INTO
              l_shipment_id,
              l_distribution_id,
              l_line_id,
              l_old_price,
              l_old_quantity,
                                  l_old_amount,
              l_item_id,
              l_req_uom,
              l_po_uom,
              l_po_to_req_rate,
              l_old_need_by_date,
              l_ship_to_org_id,
              l_ship_to_loc_id
          FROM
              po_req_distributions_all prda,
              po_requisition_lines_all prla,
              po_line_locations_all plla,
              po_distributions_all pda,
              po_lines_all pla,
              po_headers_all pha
          WHERE
              prda.distribution_id = l_req_dist_id
              AND prda.requisition_line_id = prla.requisition_line_id
              AND pda.req_distribution_id = prda.distribution_id
              AND pda.line_location_id = prla.line_location_id
              AND plla.line_location_id = prla.line_location_id
              AND plla.po_header_id = plla.po_header_id
              AND plla.po_line_id = pla.po_line_id
              AND pla.po_header_id = pha.po_header_id;

-- Following Period check has been removed as part of fix for 14198490.

/*        BEGIN
           SELECT   pda.SET_OF_BOOKS_ID,
 	  pda.GL_ENCUMBERED_DATE
           INTO        l_set_of_books_id,
 	  l_gl_date
           FROM      po_distributions_All pda
           WHERE    pda.po_distribution_id = l_distribution_id
           AND         pda.ENCUMBERED_FLAG     = 'Y';

           -- check if GL period is open
           SELECT
               GL_PS.PERIOD_NAME
           INTO
               l_gl_period
           FROM
              GL_PERIOD_STATUSES GL_PS,
              GL_PERIOD_STATUSES PO_PS,
              GL_SETS_OF_BOOKS GL_SOB
           WHERE
            -- Join conditions:
               GL_SOB.set_of_books_id = (l_set_of_books_id)
               AND GL_PS.set_of_books_id = GL_SOB.set_of_books_id
               AND PO_PS.set_of_books_id = GL_SOB.set_of_books_id
               AND GL_PS.period_name = PO_PS.period_name
                -- GL period conditions:
               AND GL_PS.application_id = 101
               -- bug 5206339 <11.5.10 GL PERIOD VALIDATION>
               AND ((  (nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y')) = 'Y'
                         and GL_PS.closing_status IN ('O', 'F'))
               OR
                       ((nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y')) = 'N'))
                -- AND GL_PS.closing_status IN ('O', 'F')
                AND GL_PS.adjustment_period_flag = 'N'
                AND GL_PS.period_year <= GL_SOB.latest_encumbrance_year
                -- PO period conditions:
                AND PO_PS.application_id = 201
                AND PO_PS.closing_status = 'O'
                AND PO_PS.adjustment_period_flag = 'N'
                -- Period date conditions:
                AND (l_gl_date BETWEEN  GL_PS.start_date AND GL_PS.end_date);


          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   x_retMsg :=  'SMRCH0033: No Open GL Period';
                   x_errCode :=  'FC_GL_PERIOD_ERROR';
                   RETURN;
          END;   */

                                -- Obtain new amount (for service lines)
          BEGIN

            SELECT new_amount
INTO l_new_amount
FROM po_change_requests
WHERE
             change_request_group_id = p_group_id AND
document_distribution_id = l_req_dist_id AND
 new_amount IS NOT NULL;

          EXCEPTION WHEN no_data_found THEN
            l_new_amount := l_old_amount;
          END;

				--Obtain most recent quantity
          l_price_break := 'N';
          BEGIN
            SELECT new_quantity
            INTO l_new_quantity
            FROM po_change_requests
            WHERE change_request_group_id = p_group_id
            AND document_distribution_id = l_req_dist_id
            AND new_quantity IS NOT NULL;

            l_price_break := 'Y';

            IF(l_req_uom <> l_po_uom) THEN
              po_uom_s.uom_convert(
                                   from_quantity => l_new_quantity,
                                   from_uom => l_req_uom,
                                   item_id => l_item_id,
                                   to_uom => l_po_uom,
                                   to_quantity => l_new_po_quantity);

              l_new_quantity := l_new_po_quantity;
            END IF;

          EXCEPTION WHEN no_data_found THEN
            l_new_quantity := l_old_quantity;
          END;

				--Obtain most recent price
          BEGIN
            SELECT new_price
            INTO l_new_price
            FROM po_change_requests
            WHERE change_request_group_id = p_group_id
            AND document_line_id = l_req_line_id
            AND action_type = 'MODIFICATION' --Bug:19208896
            AND new_price IS NOT NULL;

            IF(l_po_to_req_rate IS NOT NULL) THEN
              l_new_price := l_new_price / l_po_to_req_rate;
            END IF;

          EXCEPTION WHEN no_data_found THEN
            BEGIN
              SELECT new_need_by_date
              INTO l_new_need_by_date
              FROM po_change_requests
              WHERE change_request_group_id = p_group_id
              AND document_line_id = l_req_line_id
              AND new_need_by_date IS NOT NULL;

              l_price_break := 'Y';
            EXCEPTION WHEN no_data_found THEN
              l_new_need_by_date := l_old_need_by_date;
            END;

            IF(l_price_break = 'Y') THEN
              l_new_price := po_sourcing2_sv.get_break_price(
                                                             x_order_quantity => l_new_quantity,
                                                             x_ship_to_org => l_ship_to_org_id,
                                                             x_ship_to_loc => l_ship_to_loc_id,
                                                             x_po_line_id => l_line_id,
                                                             x_cum_flag => FALSE,
                                                             p_need_by_date => l_new_need_by_date,
                                                             x_line_location_id => l_shipment_id);
            ELSE
              l_new_price := l_old_price;
            END IF;

          END;

				--Calculate new tax
          calculate_disttax(1.0, l_cal_disttax_status, l_req_dist_id, l_new_price, l_new_quantity, NULL,
                            l_rec_tax, l_nonrec_tax);
          l_new_tax := l_nonrec_tax;


                          -- update new values in PO_ENCUMBRANCE_GT
          UPDATE po_encumbrance_gt
          SET
            amount_ordered = l_new_amount,
            quantity_ordered = l_new_quantity,
            price = l_new_price,
            nonrecoverable_tax = l_new_tax
          WHERE
            distribution_id = l_distribution_id AND
            adjustment_status = po_document_funds_grp.g_adjustment_status_new;

        END LOOP;
        CLOSE l_dist_qty_price_chn_csr;


        x_retmsg := 'SMRCH0032';
			--Execute PO Funds Check API

        po_document_funds_grp.check_adjust(
                                           p_api_version => 1.0,
                                           x_return_status => l_fc_result_status,
                                           p_doc_type => po_document_funds_grp.g_doc_type_mixed_po_release,
                                           p_doc_subtype => NULL,
                                           p_override_funds => po_document_funds_grp.g_parameter_use_profile,
                                           p_use_gl_date => po_document_funds_grp.g_parameter_yes,
                                           p_override_date => SYSDATE,
                                           p_report_successes => po_document_funds_grp.g_parameter_no,
                                           x_po_return_code => l_po_return_code,
                                           x_detailed_results => l_fc_out_tbl);

        x_retmsg := 'SMRCH004';

        IF (g_fnd_debug = 'Y') THEN
          IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
            fnd_log.string(fnd_log.level_statement,
                           g_module_prefix || l_api_name,
                           'FUNDS CHECK:' || l_fc_result_status ||' PO RETURN CODE:' || l_po_return_code);
          END IF;
        END IF;

        IF (l_fc_result_status = fnd_api.g_ret_sts_unexp_error) THEN
          x_errcode := 'FC_ERROR';
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;

        ELSE

          IF (l_po_return_code = po_document_funds_grp.g_return_success) THEN
            x_return_status := fnd_api.g_ret_sts_success;

          ELSE  -- there can be warning/error message for other cases
             IF (l_po_return_code = po_document_funds_grp.g_return_WARNING) THEN
 	             x_errCode := 'FC_WARN';
 	     ELSE
                      x_errcode := 'FC_FAIL';
	    END IF;

            x_return_status := fnd_api.g_ret_sts_error;

			  -- populate x_errTable (output PLSQL table) with the corresponding
			  -- funds check error messages.

            l_err_line_id_tbl := po_tbl_number();
            l_err_line_num_tbl := po_tbl_number();
            l_err_dist_id_tbl := po_tbl_number();
            l_err_dist_num_tbl := po_tbl_number();
            l_err_error_attr_tbl := po_tbl_varchar30();
            l_err_msg_count_tbl := po_tbl_number();
            l_err_msg_data_tbl := po_tbl_varchar2000();

            x_errtable := po_req_change_err_table(
                                                  l_err_line_id_tbl,
                                                  l_err_line_num_tbl,
                                                  l_err_dist_id_tbl,
                                                  l_err_dist_num_tbl,
                                                  l_err_error_attr_tbl,
                                                  l_err_msg_count_tbl,
                                                  l_err_msg_data_tbl);


            x_errtable.req_line_id.extend(l_fc_out_tbl.row_index.count);
            x_errtable.req_line_num.extend(l_fc_out_tbl.row_index.count);
            x_errtable.req_dist_id.extend(l_fc_out_tbl.row_index.count);
            x_errtable.req_dist_num.extend(l_fc_out_tbl.row_index.count);
            x_errtable.msg_count.extend(l_fc_out_tbl.row_index.count);
            x_errtable.msg_data.extend(l_fc_out_tbl.row_index.count);
            FOR x IN 1..l_fc_out_tbl.row_index.count LOOP

              SELECT
                            prda.distribution_id,
                            prda.distribution_num,
                            prda.requisition_line_id,
                            prla.line_num
              INTO
                            l_fc_req_distr_id,
                            l_fc_req_distr_num,
                            l_fc_req_line_id,
                            l_fc_req_line_num
              FROM
                            po_requisition_lines_all prla,
                            po_req_distributions_all prda,
                            po_distributions_all pda
              WHERE
                            pda.po_distribution_id = l_fc_out_tbl.distribution_id(x)
                            AND pda.req_distribution_id = prda.distribution_id
                            AND prla.requisition_line_id = prda.requisition_line_id;

              x_errtable.req_line_id(x)  := l_fc_req_line_id;
              x_errtable.req_line_num(x) := l_fc_req_line_num;
              x_errtable.req_dist_id(x)  := l_fc_req_distr_id;
              x_errtable.req_dist_num(x) := l_fc_req_distr_num;
              x_errtable.msg_data(x)     := l_fc_out_tbl.error_msg(x);

            END LOOP;
            RETURN;
          END IF;
        END IF;
      END IF;

    END IF;
	--Funds Check Ends


    i := 1;
    OPEN l_changes_csr(p_group_id);
    LOOP
      FETCH l_changes_csr
      INTO
      l_req_hdr_id,
      l_req_line_id,
      l_req_dist_id,
      l_new_quantity,
      l_new_price,
      l_new_date,
      l_request_reason;
      EXIT WHEN l_changes_csr%notfound;
      l_req_change_table(i).document_line_id := l_req_line_id;
      l_req_change_table(i).document_distribution_id := l_req_dist_id;
      l_req_change_table(i).new_price := l_new_price;
      l_req_change_table(i).new_quantity := l_new_quantity;
      l_req_change_table(i).new_date := l_new_date;
      l_req_change_table(i).request_reason := l_request_reason;

      i := i + 1;
    END LOOP;
    CLOSE l_changes_csr;
    x_retmsg := 'SMRCH006';
    l_err_line_id_tbl := po_tbl_number();
    l_err_line_num_tbl := po_tbl_number();
    l_err_dist_id_tbl := po_tbl_number();
    l_err_dist_num_tbl := po_tbl_number();
    l_err_error_attr_tbl := po_tbl_varchar30();
    l_err_msg_count_tbl := po_tbl_number();
    l_err_msg_data_tbl := po_tbl_varchar2000();

    x_errtable := po_req_change_err_table(
                                          l_err_line_id_tbl,
                                          l_err_line_num_tbl,
                                          l_err_dist_id_tbl,
                                          l_err_dist_num_tbl,
                                          l_err_error_attr_tbl,
                                          l_err_msg_count_tbl,
                                          l_err_msg_data_tbl);

	--Final Round of Validations Against Changes
    IF(l_change_exist = 'Y') THEN
      validate_changes(l_req_hdr_id, l_req_change_table, x_return_status, x_retmsg, x_errtable);
    END IF;
    x_retmsg := 'SMRCH007';
	--Submit Cancel Requests
    IF(l_cancel_exist = 'Y') THEN
      submit_reqcancel(1.0, x_return_status, p_group_id, x_retmsg, l_cancel_errtable, 'Y');
    END IF;

    x_retmsg := 'SMRCH008';




    i := x_errtable.req_line_id.count + 1;
    l_cancelerrorsize := l_cancel_errtable.req_line_id.count;
    IF(l_cancelerrorsize > 0) THEN
      x_errtable.req_line_id.extend(l_cancelerrorsize);
      x_errtable.msg_count.extend(l_cancelerrorsize);
      x_errtable.msg_data.extend(l_cancelerrorsize);


      FOR k IN 1..l_cancelerrorsize
        LOOP
        x_errtable.req_line_id(i) := l_cancel_errtable.req_line_id(k);
        x_errtable.msg_count(i) := 1;
        x_errtable.msg_data(i) :='CANNOT CANCEL';
        i := i + 1;
      END LOOP;
    END IF;

	/*
	* If all requests are valid, update status to "NEW" and kick off workflow
	*/
    IF(x_errtable.req_line_id.count = 0) THEN
      UPDATE po_change_requests
      SET request_status = 'NEW'
      WHERE change_request_group_id = p_group_id
      AND request_status = 'SYSTEMSAVE';

		--Kick Off Workflow
      x_retmsg := 'SMRCH009';
      po_reqchangerequestwf_pvt.submit_req_change(
                                                  p_api_version => 1.0,
                                                  p_commit => fnd_api.g_false,

                                                  p_req_header_id => l_req_hdr_id,
                                                  p_note_to_approver => p_note_to_approver,
                                                  p_initiator => p_initiator,
                                                  x_return_status => l_wf_status);
    ELSE
      x_errcode := 'VC_FAIL';
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_retmsg := x_retmsg || ':' || SQLERRM;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', x_retmsg );
      END IF;
    END IF;
  END submit_reqchange;

/*
**Submit_ReqCancel: Final procedure call for transaction which involves requester
**cancelling a req line.
**This API could be called from the Cancel Flow UI directly, or from Submit_ReqChange API.
*/
  PROCEDURE submit_reqcancel (
                              p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_group_id IN NUMBER,
                              x_retmsg OUT NOCOPY VARCHAR2,
                              p_errtable OUT NOCOPY po_req_change_err_table,
                              p_origin IN VARCHAR2)
  IS
  l_api_name VARCHAR2(50) := 'Submit_ReqCancel';
  l_line_id NUMBER;
  l_result VARCHAR2(1);
  i NUMBER := 1;
  l_canerr_line_id_tbl po_tbl_number;
  l_canerr_line_num_tbl po_tbl_number;
  l_canerr_dist_id_tbl po_tbl_number;
  l_canerr_dist_num_tbl po_tbl_number;
  l_canerr_error_attr_tbl po_tbl_varchar30;
  l_canerr_msg_count_tbl po_tbl_number;
  l_canerr_msg_data_tbl po_tbl_varchar2000;
  l_line_location_id NUMBER;
  l_chn_req_id NUMBER;
  l_req_hdr_id NUMBER;
  l_wf_status VARCHAR2(1);
  l_workflow_needed VARCHAR2(1) := 'N';
  CURSOR l_cancels_csr(grp_id NUMBER) IS
  SELECT
      pcr.document_header_id,
      pcr.document_line_id,
      prla.line_location_id,
      pcr.change_request_id
  FROM
      po_change_requests pcr,
      po_requisition_lines_all prla
  WHERE pcr.action_type = 'CANCELLATION'
  AND pcr.change_request_group_id = grp_id
  AND pcr.document_line_id = prla.requisition_line_id;
  BEGIN


    l_canerr_line_id_tbl := po_tbl_number();
    l_canerr_line_num_tbl := po_tbl_number();
    l_canerr_dist_id_tbl := po_tbl_number();
    l_canerr_dist_num_tbl := po_tbl_number();
    l_canerr_error_attr_tbl := po_tbl_varchar30();
    l_canerr_msg_count_tbl := po_tbl_number();
    l_canerr_msg_data_tbl := po_tbl_varchar2000();

    p_errtable := po_req_change_err_table(
                                          l_canerr_line_id_tbl ,
                                          l_canerr_line_num_tbl,
                                          l_canerr_dist_id_tbl ,
                                          l_canerr_dist_num_tbl,
                                          l_canerr_error_attr_tbl,
                                          l_canerr_msg_count_tbl ,
                                          l_canerr_msg_data_tbl );

	--Calling PO Cancel API to check if the corresponding PO Shipment Can be cancelled.
    OPEN l_cancels_csr(p_group_id);
    LOOP
      FETCH l_cancels_csr INTO
      l_req_hdr_id, l_line_id, l_line_location_id, l_chn_req_id;
      EXIT WHEN l_cancels_csr%notfound;
      IF(l_line_location_id IS NULL) THEN
        UPDATE po_change_requests
        SET request_status = 'ACCEPTED'
        WHERE change_request_id = l_chn_req_id;
      ELSE
        l_workflow_needed := 'Y';
        is_req_line_cancellable(1.0, x_return_status, l_line_id, l_result);
        IF(l_result = 'N') THEN
          p_errtable.req_line_id.extend(1);
          p_errtable.req_line_id(i) := l_line_id;
          i := i + 1;
        END IF;
      END IF;
    END LOOP;

    CLOSE l_cancels_csr;

    x_return_status := fnd_api.g_ret_sts_success;

	--If all requests are valid, update status to "NEW", and kick off Workflow

    IF(p_errtable.req_line_id.count = 0) THEN
      UPDATE po_change_requests
      SET request_status = 'NEW'
      WHERE change_request_group_id = p_group_id
      AND request_status = 'SYSTEMSAVE';

      IF (p_origin IS NULL AND l_workflow_needed = 'Y') THEN

        po_reqchangerequestwf_pvt.submit_req_change(
                                                    p_api_version => 1.0,
                                                    p_commit => fnd_api.g_false,
                                                    x_return_status => l_wf_status,
                                                    p_req_header_id => l_req_hdr_id,
                                                    p_note_to_approver => NULL,
                                                    p_initiator => 'REQUESTER');
      END IF;
    ELSE
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', SQLERRM);
      END IF;
    END IF;
  END submit_reqcancel;

/**
 * This procedure returns whether an internal line can be cancelled or not
 * If the corresponding internal order is cancelled, it returns 'S'.
 * It also checks if the line is in oe interface table.
 **/
PROCEDURE IS_INTERNAL_LINE_CANCELLABLE(p_api_version IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       p_req_line_id IN NUMBER)
IS
  l_req_line_id NUMBER:= 0;
  l_req_header_id NUMBER := 0;
  l_api_name varchar2(50):= 'Is_Internal_Line_Cancellable';
BEGIN
  BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT
    prl.requisition_line_id,
    prh.requisition_header_id
  INTO
    l_req_line_id,
    l_req_header_id
  FROM po_requisition_lines prl,
   po_requisition_headers_all prh  -- <R12 MOAC>
  WHERE prl.requisition_line_id = p_req_line_id AND
    prh.requisition_header_id = prl.requisition_header_id AND
  (NOT EXISTS
   (SELECT 'so line is not cancelled'
    FROM
      po_requisition_lines PORL,
      po_requisition_headers_all PORH, -- <R12 MOAC>
      po_system_parameters POSP
    WHERE
      PORL.requisition_line_id = p_req_line_id AND
      PORL.requisition_header_id = PORH.requisition_header_id AND
      (OE_ORDER_IMPORT_INTEROP_PUB.Get_Open_Qty(posp.order_source_id, porh.requisition_header_id, porl.requisition_line_id))>0)
    AND NOT EXISTS
    (SELECT 'line in interface table'
     FROM
       oe_headers_iface_all SOHI,
       po_system_parameters POSP
     WHERE
      SOHI.orig_sys_document_ref = to_char(PRH.requisition_header_id)
      AND SOHI.order_source_id = POSP.order_source_id));

  EXCEPTION

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception',
    				p_req_line_id||':'||sqlerrm);
       END IF;
    END IF;
    RETURN;
  END;

  /* Bug : 4639448
  ** Call to check whether the SO shipments are still in process..*/
  BEGIN
    IF po_req_lines_sv.val_oe_shipment_in_proc(l_req_header_id,
                                               p_req_line_id) = FALSE
    THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
    END IF;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
  	  x_return_status := FND_API.G_RET_STS_ERROR;
  	  RETURN;
  END;

   /* Bug : 4639448
   ** Call po_req_lines_sv.val_reqs_qty_received to verify if internal
   ** requisition lines which are sourced from inventory, have been received or not.*/
   BEGIN
       IF po_req_lines_sv.val_reqs_qty_received (l_req_header_id,
                                                 p_req_line_id ) = FALSE
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
       END IF;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
   END;

END IS_INTERNAL_LINE_CANCELLABLE;

PROCEDURE is_SO_line_cancellable(p_api_version IN NUMBER,
                                         x_return_status OUT NOCOPY VARCHAR2,
                                         p_req_line_id IN NUMBER,
                                         p_req_header_id IN NUMBER,
                                         x_cancellable OUT NOCOPY VARCHAR2 )
  IS
  l_req_line_id NUMBER := 0;
  l_req_header_id NUMBER := 0;
  l_req_change_pending_flag po_requisition_headers_all.change_pending_flag%type;
  l_transferred_to_oe_flag  po_requisition_lines_all.transferred_to_oe_flag%type;

  l_api_name VARCHAR2(50) := 'is_SO_line_cancellable';
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';
  x_update_allowed BOOLEAN := FALSE;
  x_cancel_allowed BOOLEAN := FALSE;
  X_msg_count number;
  X_msg_data varchar2(3000);
  l_orgid number;
  l_api_version     CONSTANT NUMBER          := 1.0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_header_id', p_req_header_id);
    END IF;

     IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                    p_api_version,
                                    l_api_name  ,
                                    G_PKG_NAME       )
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF (p_req_line_id is null and p_req_header_id is null ) then
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END if;

    IF (p_req_line_id is null and p_req_header_id is not null ) then

        l_progress := '001';

        select change_pending_flag
          into l_req_change_pending_flag
          from po_requisition_headers_all
         where requisition_header_id = p_req_header_id;

        l_progress := '002';

        IF (l_req_change_pending_flag = 'Y') THEN
            -- 18921152 If req is pending for approval,
            -- then does not allow to cancel lines that already on SO
            x_cancellable := 'N';
        ELSE

            l_orgid := PO_ReqChangeRequestWF_PVT.get_sales_order_org(p_req_hdr_id  => p_req_header_id);

            IF g_debug_stmt THEN
                po_debug.debug_var(l_log_head, l_progress, 'Sales order l_orgid', l_orgid);
            END IF;

            IF l_orgid is NOT NULL THEN
            PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
            END IF;

            l_progress := '003';
            -- OM_API.is_req_line_cancellable(l_req_header_id,l_req_line_id,x_return_status);
            -- OM API OM_API provided is
            OE_Internal_Requisition_Pvt.Is_IReq_Changable
            (  P_API_Version            => 1.0
            ,  P_internal_req_line_id   =>p_req_line_id
            ,  P_internal_req_header_id =>p_req_header_id
            ,  X_Update_Allowed         =>x_update_allowed
            ,  X_Cancel_Allowed         =>x_cancel_allowed
            ,  X_msg_count              =>X_msg_count
            ,  X_msg_data               =>X_msg_data
            ,  X_return_status          =>x_return_status
            );


            l_orgid := PO_ReqChangeRequestWF_PVT.get_requisition_org( p_req_hdr_id  => p_req_header_id);

            IF g_debug_stmt THEN
                po_debug.debug_var(l_log_head, l_progress, 'requisition l_orgid', l_orgid);
            END IF;

            IF l_orgid is NOT NULL THEN
                PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
            END IF;

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ElsE
                x_cancellable :=  por_util_pkg.bool_to_varchar(X_Cancel_Allowed);
            END IF;
        END IF; -- if l_req_change_pending_flag

    ELSE    -- IF (p_req_line_id is null and p_req_header_id is not null )

        SELECT
          prl.requisition_line_id,
          prl.transferred_to_oe_flag,
          prh.requisition_header_id,
          prh.change_pending_flag
        INTO
          l_req_line_id,
          l_transferred_to_oe_flag,
          l_req_header_id,
          l_req_change_pending_flag
        FROM po_requisition_lines prl,
         po_requisition_headers_all prh  -- <R12 MOAC>
        WHERE prl.requisition_line_id = p_req_line_id AND
          prh.requisition_header_id = prl.requisition_header_id ;

        IF (l_req_change_pending_flag = 'Y' and l_transferred_to_oe_flag = 'Y') THEN
            -- 18921152 If req is pending for approval,
            -- then does not allow to cancel lines that already on SO
            x_cancellable := 'N';
        ELSE
            l_progress := '002';
            l_orgid := PO_ReqChangeRequestWF_PVT.get_sales_order_org( p_req_line_id=>  p_req_line_id);

            IF g_debug_stmt THEN
                po_debug.debug_var(l_log_head, l_progress, 'Sales order l_orgid', l_orgid);
            END IF;

            IF l_orgid is NOT NULL THEN
                PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
            END IF;

            l_progress := '003';
            -- OM_API.is_req_line_cancellable(l_req_header_id,l_req_line_id,x_return_status);
            -- OM API OM_API provided is
            OE_Internal_Requisition_Pvt.Is_IReq_Changable
            (  P_API_Version            => 1.0
            ,  P_internal_req_line_id   =>l_req_line_id
            ,  P_internal_req_header_id =>l_req_header_id
            ,  X_Update_Allowed         =>x_update_allowed
            ,  X_Cancel_Allowed         =>x_cancel_allowed
            ,  X_msg_count              =>X_msg_count
            ,  X_msg_data               =>X_msg_data
            ,  X_return_status          =>x_return_status
            );


            l_orgid := PO_ReqChangeRequestWF_PVT.get_requisition_org( p_req_line_id=> p_req_line_id );

            IF g_debug_stmt THEN
                po_debug.debug_var(l_log_head, l_progress, 'Requisition l_orgid', l_orgid);
            END IF;

            IF l_orgid is NOT NULL THEN
                PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
            END IF;

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ElsE
                x_cancellable :=  por_util_pkg.bool_to_varchar(X_Cancel_Allowed);
            END IF;
        END IF; -- if l_req_change_pending_flag

    end if; -- IF (p_req_line_id is null and p_req_header_id is not null ) else

     IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress, 'x_cancellable', x_cancellable);
      po_debug.debug_end(l_log_head);
     end if;
  EXCEPTION
    WHEN no_data_found THEN
    x_return_status := fnd_api.g_ret_sts_error;
    RETURN;

    WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF (g_fnd_debug = 'Y') THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception',
                       p_req_line_id || ':' || SQLERRM);
      END IF;
    END IF;
    RETURN;

  END is_SO_line_cancellable;

/**
 * This procedure returns whether an internal line can be updated
 * with quantity and need by date or not
 **/
  PROCEDURE is_internal_line_changeable(p_api_version IN NUMBER
                                     ,  X_Update_Allowed OUT NOCOPY VARCHAR2
                                     ,  X_Cancel_Allowed OUT NOCOPY VARCHAR2
                                     ,  x_return_status OUT NOCOPY VARCHAR2
                                     ,   p_req_line_id IN NUMBER)
  IS
  l_req_line_id NUMBER := 0;
  l_req_header_id NUMBER := 0;
  l_api_name VARCHAR2(50) := 'Is_Internal_Line_Changeable';
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';
  X_msg_count number;
  X_msg_data varchar2(3000);
  l_Update_Allowed boolean :=FALSE;
  l_Cancel_Allowed boolean :=FALSE;
  l_api_version     CONSTANT NUMBER          := 1.0;
  l_orgid number;
  BEGIN

   IF NOT FND_API.Compatible_API_Call (  l_api_version ,
                                    p_api_version,
                                    l_api_name  ,
                                    G_PKG_NAME       )
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
    l_update_allowed := FALSE;
    l_cancel_allowed := FALSE;

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
    END IF;

    SELECT
      prl.requisition_line_id,
      prl.requisition_header_id
    INTO
      l_req_line_id,
      l_req_header_id
    FROM po_requisition_lines_all prl
    WHERE prl.requisition_line_id = p_req_line_id;

    l_progress := '001';

     l_orgid := PO_ReqChangeRequestWF_PVT.get_sales_order_org(p_req_line_id => p_req_line_id);
    IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Sales order l_orgid', l_orgid);
     END IF;

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;


 -- OM_API.is_req_line_changeable(l_req_header_id,l_req_line_id,x_return_status);
-- OM API OM_API provided is
OE_Internal_Requisition_Pvt.Is_IReq_Changable
(  P_API_Version            => 1.0
,  P_internal_req_line_id   =>l_req_line_id
,  P_internal_req_header_id =>l_req_header_id
,  X_Update_Allowed         =>l_update_allowed
,  X_Cancel_Allowed         =>l_cancel_allowed
,  X_msg_count              =>X_msg_count
,  X_msg_data               =>X_msg_data
,  X_return_status          =>x_return_status
);


  l_orgid := PO_ReqChangeRequestWF_PVT.get_requisition_org(p_req_line_id  => p_req_line_id);
   IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Requisition l_orgid', l_orgid);
     END IF;

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;

x_update_allowed := POR_UTIL_PKG.bool_to_varchar(l_update_allowed);
x_cancel_allowed := POR_UTIL_PKG.bool_to_varchar(l_cancel_allowed);

IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress, 'x_update_allowed', x_update_allowed);
      po_debug.debug_var(l_log_head, l_progress, 'x_cancel_allowed', x_cancel_allowed);
      po_debug.debug_end(l_log_head);

    END IF;
  EXCEPTION

    WHEN no_data_found THEN
    x_return_status := fnd_api.g_ret_sts_error;
    RETURN;

    WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF (g_fnd_debug = 'Y') THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception',
                       p_req_line_id || ':' || SQLERRM);
      END IF;
    END IF;
    RETURN;

  END is_internal_line_changeable;

/*--------------------------------------------------------------
**Save_IReqCancel: takes in a PLSQL table as input, containing
**cancellation request. No Validation is done here. This API
**simply insert records into PO_CHANGE_REQUESTS table
---------------------------------------------------------------*/


  PROCEDURE save_ireqcancel(p_api_version IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_hdr_id IN NUMBER,
                            p_cancel_table IN po_req_cancel_table,
                            p_change_request_group_id OUT NOCOPY NUMBER,
                            l_progress OUT NOCOPY VARCHAR2,
                            p_grp_id IN NUMBER)
  IS
  l_api_name VARCHAR2(50) := 'Save_IReqCancel';
  l_chn_req_id NUMBER;
  l_req_num po_requisition_headers_all.segment1%TYPE;
  l_req_line_num NUMBER;
  l_req_user_id NUMBER;
  l_line_loc_id NUMBER;
  l_po_header_id NUMBER;
  l_po_release_id NUMBER;
  l_po_revision_num NUMBER;
  l_preparer_id NUMBER;
  l_req_price NUMBER;
  l_req_currency_price NUMBER;
  l_req_quantity NUMBER;
  l_req_date	DATE;
  l_po_num po_change_requests.ref_po_num%TYPE;
  l_po_release_num NUMBER;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;

  BEGIN
    l_progress := '000';
    l_req_user_id := fnd_global.user_id;
    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version=', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_hdr_id=', p_req_hdr_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_grp_id=', p_grp_id);
    END IF;

    IF(p_grp_id IS NULL) THEN
      SELECT po_chg_request_seq.nextval INTO p_change_request_group_id FROM dual;
      DELETE FROM po_change_requests
      WHERE document_header_id = p_req_hdr_id
      AND initiator = 'REQUESTER'
      AND request_status = 'SYSTEMSAVE';

      IF g_debug_stmt THEN
        po_debug.debug_var(l_log_head, l_progress,'In PO_CHANGE_REQUESTS records deleted=', SQL%rowcount);
        po_debug.debug_var(l_log_head, l_progress, 'p_change_request_group_id=', p_change_request_group_id);
      END IF;

    ELSE
      p_change_request_group_id := p_grp_id;
    END IF;
    l_progress := '001';

    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress,'In PO_CHANGE_REQUESTS records deleted=', SQL%rowcount);
      po_debug.debug_var(l_log_head, l_progress, 'p_cancel_table.req_line_id.count=', p_cancel_table.req_line_id.count);
    END IF;



    FOR i IN 1..p_cancel_table.req_line_id.count
      LOOP

      SELECT po_chg_request_seq.nextval INTO l_chn_req_id FROM dual;
      SELECT
          prha.segment1,
          prla.line_num,
          prha.preparer_id,
          prla.unit_price,
          prla.quantity,
          prla.need_by_date
      INTO
          l_req_num,
          l_req_line_num,
          l_preparer_id,
          l_req_price,
          l_req_quantity,
          l_req_date
      FROM
          po_requisition_headers_all prha,
          po_requisition_lines_all prla
      WHERE prla.requisition_line_id = p_cancel_table.req_line_id(i)
      AND prla.requisition_header_id = prha.requisition_header_id;

	/*	if(l_line_loc_id is not null) then
			select
				po_release_id,
				po_header_id
			into
				l_po_release_id,
				l_po_header_id
			from po_line_locations_all
			where line_location_id = l_line_loc_id;
			if(l_po_release_id is null) then
				select revision_num,segment1 into
				l_po_revision_num, l_po_num
				from po_headers_all
				where po_header_id = l_po_header_id;

                                -- bug 5191164.
                                -- Need to null out l_po_release_num for PO records
                                l_po_release_num := null;

			else
                                -- get po_number of the source document for RELEASE
                                select segment1 into l_po_num
                                from po_headers_all
                                where po_header_id = l_po_header_id;

				select revision_num, release_num
				into l_po_revision_num, l_po_release_num
				from po_releases_all
				where po_release_id = l_po_release_id;
			end if;
		end if;
*/
      l_progress := '002';
      INSERT INTO po_change_requests
      (
          change_request_group_id,
          change_request_id,
          initiator,
          action_type,
          request_reason,
          request_level,
          request_status,
          document_type,
          document_header_id,
          document_num,
          created_by,
          creation_date,
          document_line_id,
          document_line_number,
          last_updated_by,
          last_update_date,
          last_update_login,
          requester_id,
          change_active_flag,
          old_price,
          old_quantity,
          old_need_by_date
   )
      VALUES
      (
          p_change_request_group_id,
          l_chn_req_id,
          'REQUESTER',
          'CANCELLATION',
          p_cancel_table.change_reason(i),
          'LINE',
          'SYSTEMSAVE',
          'REQ',
          p_req_hdr_id,
          l_req_num,
          l_req_user_id,
          SYSDATE,
          p_cancel_table.req_line_id(i),
          l_req_line_num,
          l_req_user_id,
          SYSDATE,
          l_req_user_id,
          l_preparer_id,
          'Y',
          l_req_price,
          l_req_quantity,
          l_req_date
      );

      IF g_debug_stmt THEN
        po_debug.debug_var(l_log_head, l_progress,'NO of records inderted in po_change_requests =', SQL%rowcount);
        po_debug.debug_var(l_log_head, l_progress, 'p_change_request_group_id=', p_change_request_group_id);
        po_debug.debug_var(l_log_head, l_progress,'l_chn_req_id =', l_chn_req_id );
        po_debug.debug_stmt(l_log_head, l_progress,'INITIATOR =REQUESTER' );
        po_debug.debug_stmt(l_log_head, l_progress, 'ACTION_TYPE=CANCELLATION' );
        po_debug.debug_var(l_log_head, l_progress,'p_cancel_table.change_reason(i) =', p_cancel_table.change_reason(i) );
        po_debug.debug_stmt(l_log_head, l_progress, 'REQUEST_LEVEL=LINE' );
        po_debug.debug_stmt(l_log_head, l_progress, 'REQUEST_STATUS=SYSTEMSAVE' );
        po_debug.debug_stmt(l_log_head, l_progress, 'DOCUMENT_TYPE=REQ' );
        po_debug.debug_var(l_log_head, l_progress,'p_req_hdr_id =', p_req_hdr_id );
        po_debug.debug_var(l_log_head, l_progress,'l_req_num =', l_req_num );
        po_debug.debug_var(l_log_head, l_progress,'l_req_user_id =', l_req_user_id );
        po_debug.debug_var(l_log_head, l_progress,'p_cancel_table.req_line_id(i) =', p_cancel_table.req_line_id(i) );
        po_debug.debug_var(l_log_head, l_progress,'l_req_line_num =', l_req_line_num );
        po_debug.debug_var(l_log_head, l_progress,'l_req_user_id =', l_req_user_id );
        po_debug.debug_var(l_log_head, l_progress,'l_req_user_id =', l_req_user_id );
        po_debug.debug_var(l_log_head, l_progress,'l_preparer_id =', l_preparer_id );
        po_debug.debug_stmt(l_log_head, l_progress, 'CHANGE_ACTIVE_FLAG=Y' );
        po_debug.debug_var(l_log_head, l_progress,'l_req_price =', l_req_price );
        po_debug.debug_var(l_log_head, l_progress,'l_req_quantity =', l_req_quantity );
        po_debug.debug_var(l_log_head, l_progress, 'l_req_date=', l_req_date);
      END IF;

    END LOOP;


    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', l_progress || ':' || SQLERRM);
      END IF;
    END IF;
  END save_ireqcancel;

/*-------------------------------------------------------------------------------------------------
*This API is called directly from the UI. It will have PLSQL tables as input, which contain change/cancel requests
*1. Validate the requests
*2. If ALL valid, same them into PO_CHANGE_REQUESTS table
*x_return_status = 	FND_API.G_RET_STS_SUCCESS => Everything is Valid, and records are saved into change table
*					FND_API.G_RET_STS_ERROR => Caught Errors, thus no records are saved into change table
*					FND_API.G_RET_STS_UNEXP_ERROR => Unexpected Errors Occur in the API
*x_retMsg will indicate details/location of errors.
---------------------------------------------------------------------------------------------------*/
  PROCEDURE save_ireqchange(p_api_version IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_hdr_id IN NUMBER,
                            p_change_table IN po_req_change_table,
                            p_cancel_table IN po_req_cancel_table,
                            p_change_request_group_id OUT NOCOPY NUMBER,
                            x_retmsg OUT NOCOPY VARCHAR2,
                            x_errtable OUT NOCOPY po_req_change_err_table)
  IS
  l_api_name VARCHAR2(50) := 'Save_IReqChange';
  l_req_change_table change_tbl_type;
  l_dummy NUMBER;
  y NUMBER := 1;
  l_change_result VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_cancel_result VARCHAR2(1);
  l_err_line_id_tbl po_tbl_number;
  l_err_line_num_tbl po_tbl_number;
  l_err_dist_id_tbl po_tbl_number;
  l_err_dist_num_tbl po_tbl_number;
  l_err_error_attr_tbl po_tbl_varchar30;
  l_err_msg_count_tbl po_tbl_number;
  l_err_msg_data_tbl po_tbl_varchar2000;
  l_irc_status VARCHAR2(1);
  l_irc_err_msg VARCHAR2(2000);
  l_catch_exception EXCEPTION;
  l_req_dist_id NUMBER;
  l_lineqty_status VARCHAR2(1);
  l_lineqty_msg VARCHAR2(2000);
  l_req_num NUMBER;
  l_req_dist_number NUMBER;
  l_old_req_date  DATE;
  l_old_req_quantity NUMBER;
  l_old_amount NUMBER;
  l_preparer_id  NUMBER;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';


  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_hdr_id', p_req_hdr_id);
    END IF;


    DELETE FROM po_change_requests
    WHERE document_header_id = p_req_hdr_id
    AND request_status = 'SYSTEMSAVE'
    AND initiator = 'REQUESTER';

    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress,'NO of rows deleted from PO_CHANGE_REQUESTS', SQL%rowcount);
    END IF;



    x_retmsg := 'SRCH000';

    IF(p_change_table IS NOT NULL) THEN
	--Input Change Table is p_change_table, which is a table of objects. The following "for" loop
	--Copy the data from p_change_table to l_req_change_table, which is a table of record
      IF g_debug_stmt THEN
        po_debug.debug_var(l_log_head, l_progress,'p_change_table is not null and count=', p_change_table.req_line_id.count);
      END IF;



      FOR x IN 1..p_change_table.req_line_id.count
        LOOP
        IF(p_change_table.need_by(x)    IS NOT NULL
      --      OR  p_change_table.amount(x)  is not null
           OR p_change_table.quantity(x) IS NOT NULL) THEN

          IF g_debug_stmt THEN
            po_debug.debug_stmt(l_log_head, l_progress,'In p_change_table need by date or quantity is changed');
          END IF;


          BEGIN
            SELECT
                  prha.segment1,
                  prda.distribution_id,
                  prla.need_by_date,
                      prla.quantity,
                  prla.amount,
                  prha.preparer_id
              INTO
                      l_req_num,
                l_req_dist_number,
                  l_old_req_date,
                l_old_req_quantity,
                  l_old_amount,
                l_preparer_id
              FROM
                      po_requisition_lines_all prla,
                      po_requisition_headers_all prha,
                  po_req_distributions_all  prda
              WHERE
                       prha.requisition_header_id = p_req_hdr_id
                  AND  prha.requisition_header_id = prla.requisition_header_id
                  AND  prla.requisition_line_id = p_change_table.req_line_id(x)
                      AND  prda.requisition_line_id = prla.requisition_line_id;
          EXCEPTION
            WHEN OTHERS THEN
            NULL;
          END;



          l_req_change_table(y).action_type := 'MODIFICATION';
          l_req_change_table(y).request_level := 'LINE';
          l_req_change_table(y).request_status := 'SYSTEMSAVE';
          l_req_change_table(y).initiator			:= 'REQUESTER';
          l_req_change_table(y).document_header_id	:= p_req_hdr_id;
          l_req_change_table(y).document_num	:= l_req_num;
          l_req_change_table(y).document_line_id		:= p_change_table.req_line_id(x);
          l_req_change_table(y).document_distribution_id	:= l_req_dist_number;
          l_req_change_table(y).old_quantity	:= l_old_req_quantity;
          l_req_change_table(y).old_date := l_old_req_date;
          l_req_change_table(y).requester_id := l_preparer_id;
          l_req_change_table(y).old_budget_amount := l_old_amount;

          IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).ACTION_TYPE', l_req_change_table(y).action_type);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).REQUEST_LEVEL', l_req_change_table(y).request_level);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).request_status', l_req_change_table(y).request_status);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).INITIATOR', l_req_change_table(y).initiator);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).DOCUMENT_HEADER_ID', l_req_change_table(y).document_header_id);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).DOCUMENT_NUM', l_req_change_table(y).document_num);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).DOCUMENT_LINE_ID', l_req_change_table(y).document_line_id);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).DOCUMENT_DISTRIBUTION_ID', l_req_change_table(y).document_distribution_id);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).OLD_QUANTITY', l_req_change_table(y).old_quantity);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).old_date', l_req_change_table(y).old_date);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).REQUESTER_ID', l_req_change_table(y).requester_id);
            po_debug.debug_var(l_log_head, l_progress, 'l_req_change_table(y).OLD_BUDGET_AMOUNT', l_req_change_table(y).old_budget_amount);

          END IF;

/*
  if(p_change_table.amount(x) is not null) then

    		l_req_change_table(y).NEW_BUDGET_AMOUNT := p_change_table.amount(x);
				l_req_change_table(y).REQUEST_REASON := p_change_table.change_reason(x);
        y:=y+1;
  END IF;  */

          IF (p_change_table.need_by(x) IS NOT NULL) THEN

            l_req_change_table(y).new_date := p_change_table.need_by(x);
            l_req_change_table(y).request_reason := p_change_table.change_reason(x);
     --     y:=y+1;
          END IF;
          IF(p_change_table.quantity(x) IS NOT NULL) THEN

            l_req_change_table(y).new_quantity := p_change_table.quantity(x);
            l_req_change_table(y).request_reason := p_change_table.change_reason(x);
		--		y:=y+1;
          END IF;
          y := y + 1;
        END IF;

      END LOOP;



	--Validate the Change Requests, by passing in l_req_change_table, a table of records
	--Initialize the Error Table
      l_err_line_id_tbl := po_tbl_number();
      l_err_line_num_tbl := po_tbl_number();
      l_err_dist_id_tbl := po_tbl_number();
      l_err_dist_num_tbl := po_tbl_number();
      l_err_error_attr_tbl := po_tbl_varchar30();
      l_err_msg_count_tbl := po_tbl_number();
      l_err_msg_data_tbl := po_tbl_varchar2000();
      x_errtable := po_req_change_err_table(
                                            l_err_line_id_tbl,
                                            l_err_line_num_tbl,
                                            l_err_dist_id_tbl,
                                            l_err_dist_num_tbl,
                                            l_err_error_attr_tbl,
                                            l_err_msg_count_tbl,
                                            l_err_msg_data_tbl);

--	Validate_Changes(p_req_hdr_id,l_req_change_table,l_change_result,x_retMsg,x_errTable);
-- these validations are done online
    END IF;

--If ALL changes are valid, we will insert change records, and insert cancel records(if any)
 --if(l_change_result = FND_API.G_RET_STS_SUCCESS) then
    x_retmsg := 'SRCH004';
    SELECT po_chg_request_seq.nextval INTO p_change_request_group_id FROM dual;



    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress, 'p_change_request_group_id=', p_change_request_group_id);
    END IF;

    insert_reqchange(l_req_change_table, p_change_request_group_id);
    x_retmsg := 'SRCH005';

    update_internalrecordswithtax(p_change_request_group_id);
    x_retmsg := 'SRCH006';



	---Insert_LineQuantityOrAmount(p_change_request_group_id);  not inserting derived record in po_change_request
    l_change_result := fnd_api.g_ret_sts_success;
    x_retmsg := 'SRCH0061';

--	Insert_PriceBreakRows(p_change_request_group_id);

    x_retmsg := 'SRCH0062';

	--Process Cancellation Requests
    l_cancel_result := fnd_api.g_ret_sts_success;

    IF(p_cancel_table IS NOT NULL) THEN
      save_ireqcancel(1.0, l_cancel_result, p_req_hdr_id, p_cancel_table, l_dummy, x_retmsg, p_change_request_group_id);
    END IF;

	--x_return_status := l_cancel_result;
    x_return_status :=  fnd_api.g_ret_sts_success;

    IF(l_change_result = fnd_api.g_ret_sts_error) THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_retmsg := 'SRCH007';
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    x_retmsg := 'SRCHUNEXP:' || x_retmsg || ':' || SQLERRM;
    x_return_status := fnd_api.g_ret_sts_unexp_error;



    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', x_retmsg);
      END IF;
    END IF;
  END save_ireqchange;



/*
**Submit_IReqCancel: Final procedure call for transaction which involves requester
**cancelling a req line.
**This API could be called from the Cancel Flow UI directly, or from Submit_ReqChange API.
*/
  PROCEDURE submit_ireqcancel (
                               p_api_version IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_group_id IN NUMBER,
                               x_retmsg OUT NOCOPY VARCHAR2,
                               p_errtable OUT NOCOPY po_req_change_err_table,
                               p_origin IN VARCHAR2)
  IS
  l_api_name VARCHAR2(50) := 'Submit_IReqCancel';
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_line_id NUMBER;
  l_result VARCHAR2(1);
  l_progress VARCHAR2(3):='000';
  i NUMBER := 1;
  l_canerr_line_id_tbl po_tbl_number;
  l_canerr_line_num_tbl po_tbl_number;
  l_canerr_dist_id_tbl po_tbl_number;
  l_canerr_dist_num_tbl po_tbl_number;
  l_canerr_error_attr_tbl po_tbl_varchar30;
  l_canerr_msg_count_tbl po_tbl_number;
  l_canerr_msg_data_tbl po_tbl_varchar2000;
  l_line_location_id NUMBER;
  l_chn_req_id NUMBER;
  l_req_hdr_id NUMBER;
  l_wf_status VARCHAR2(1);
  l_workflow_needed VARCHAR2(1) := 'Y';
  CURSOR l_cancels_csr(grp_id NUMBER) IS
  SELECT
      pcr.document_header_id,
      pcr.document_line_id,
      prla.line_location_id,
      pcr.change_request_id
  FROM
      po_change_requests pcr,
      po_requisition_lines_all prla
  WHERE pcr.action_type = 'CANCELLATION'
  AND pcr.change_request_group_id = grp_id
  AND pcr.document_line_id = prla.requisition_line_id;
  BEGIN
    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress, 'p_group_id', p_group_id);
    END IF;


    l_canerr_line_id_tbl := po_tbl_number();
    l_canerr_line_num_tbl := po_tbl_number();
    l_canerr_dist_id_tbl := po_tbl_number();
    l_canerr_dist_num_tbl := po_tbl_number();
    l_canerr_error_attr_tbl := po_tbl_varchar30();
    l_canerr_msg_count_tbl := po_tbl_number();
    l_canerr_msg_data_tbl := po_tbl_varchar2000();

    p_errtable := po_req_change_err_table(
                                          l_canerr_line_id_tbl ,
                                          l_canerr_line_num_tbl,
                                          l_canerr_dist_id_tbl ,
                                          l_canerr_dist_num_tbl,
                                          l_canerr_error_attr_tbl,
                                          l_canerr_msg_count_tbl ,
                                          l_canerr_msg_data_tbl );

	--Calling PO Cancel API to check if the corresponding PO Shipment Can be cancelled.
    OPEN l_cancels_csr(p_group_id);
    LOOP
      FETCH l_cancels_csr INTO
      l_req_hdr_id, l_line_id, l_line_location_id, l_chn_req_id;
      EXIT WHEN l_cancels_csr%notfound;
/*		if(l_line_location_id is null) then
			update po_change_requests
			set request_status = 'ACCEPTED'
			where change_request_id = l_chn_req_id;
		else */--since only lines on so is cancellable so wf is always needed
      l_workflow_needed := 'Y';

	--	end if;
    END LOOP;

    CLOSE l_cancels_csr;

    x_return_status := fnd_api.g_ret_sts_success;

	--If all requests are valid, update status to "NEW", and kick off Workflow

    IF(p_errtable.req_line_id.count = 0) THEN




      UPDATE po_change_requests
          SET request_status = 'NEW'
          WHERE change_request_group_id = p_group_id
          AND request_status = 'SYSTEMSAVE';




      IF (p_origin IS NULL AND l_workflow_needed = 'Y') THEN

        po_reqchangerequestwf_pvt.submit_internal_req_change(
                                                             p_api_version => 1.0,
                                                             p_commit => fnd_api.g_false,
                                                             x_return_status => l_wf_status,
                                                             p_req_header_id => l_req_hdr_id,
                                                             p_note_to_approver => NULL,
                                                             p_initiator => 'REQUESTER');
      END IF;




    ELSE
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', SQLERRM);
      END IF;
    END IF;
  END submit_ireqcancel;


  PROCEDURE get_preparer_name(
                                 p_req_hdr_id                  IN            NUMBER
                              ,  x_preparer_name                OUT NOCOPY    VARCHAR2
                              ,  x_return_status               OUT NOCOPY     VARCHAR2
                              )
  IS
  l_preparer_id NUMBER;
  x_preparer_display_name varchar2(360);
  BEGIN

    SELECT preparer_id into l_preparer_id
    FROM po_requisition_headers_all
    WHERE requisition_header_id = p_req_hdr_id;

    WF_DIRECTORY.GetUserName(  'PER',
  	        	                   l_preparer_id,
         		         	           x_preparer_name,
                  	        	   x_preparer_display_name);


    x_return_status := fnd_api.g_ret_sts_success;
  END get_preparer_name;





 PROCEDURE update_reqcancel_from_so(  p_req_line_id       IN            NUMBER
			            , p_req_cancel_qty   IN            NUMBER
                                    , p_req_cancel_all   IN            BOOLEAN
                                    ,x_return_status     OUT       NOCOPY VARCHAR2 )
  IS

  l_req_line_id NUMBER;
  l_bool_ret_sts BOOLEAN;
  l_return_status VARCHAR2(10);
  l_open_quantity number;
  l_quantity_delivered NUMBER;
  l_quantity NUMBER;
  l_delta_quantity number;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || 'update_reqcancel_from_so';
  l_progress varchar2(3):='000';
  l_count number:=0;
  BEGIN

  -- Bug 8235698: Check whether there is a pending change on this
  -- requisition line , if there exists one then
  -- return Error to the SO (OM) API.

      BEGIN

          SELECT COUNT(*) INTO l_count  FROM po_change_requests
          WHERE request_status in ( 'NEW' , 'MGR_PRE_APP' , 'MGR_APP')
          AND DOCUMENT_TYPE= 'REQ'
          AND REQUEST_LEVEL= 'LINE'
          AND DOCUMENT_LINE_ID=p_req_line_id;

      EXCEPTION
        WHEN no_data_found THEN
          l_count:=0;
      END;

      IF (l_count <> 0 ) THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_debug_stmt THEN
            po_debug.debug_begin(l_log_head);

            po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
            po_debug.debug_var(l_log_head, l_progress, 'No of po_change_requests on req line', l_count);
        END IF;

        return;
      END IF;
      -- have save point
    SAVEPOINT update_reqcancel_from_so_sp;
    /*
     * ALGORITHM : For each req line or perticular line
                  Step 1: Retrive the open receiving quantity INTO l_open_quantity
                  Step 2 : Retrive the REQ LINE quantity INTO l_quantity
    */

   l_return_status := fnd_api.g_ret_sts_success;
   l_progress:='001';

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_qty', p_req_cancel_qty);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_all', p_req_cancel_all);
    END IF;

   IF (p_req_line_id IS NOT NULL ) THEN

    IF p_req_cancel_all THEN

       po_reqchangerequestwf_pvt.req_line_CANCEL(
                            p_req_line_id => p_req_line_id,
                            x_return_status =>l_return_status);
    ELSE

      BEGIN
              SELECT QUANTITY, nvl(QUANTITY_DELIVERED,0)
              INTO l_quantity, l_quantity_delivered
              FROM po_requisition_lines_all
              WHERE REQUISITION_LINE_ID=p_req_line_id;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'l_quantity', l_quantity);
            po_debug.debug_var(l_log_head, l_progress, 'l_quantity_delivered', l_quantity_delivered);
            po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_qty', p_req_cancel_qty);
            po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_all', p_req_cancel_all);
       END IF;

       IF (p_req_cancel_qty IS NOT NULL AND l_quantity IS NOT NULL ) THEN
               IF (l_quantity - p_req_cancel_qty > 0) THEN
                        -- UPDATE THE REQ LINE WITH DELTA QUANTITY AS
                         l_delta_quantity := (-1) *  p_req_cancel_qty ;

                          IF g_debug_stmt THEN
                                  po_debug.debug_var(l_log_head, l_progress, 'l_delta_quantity', l_delta_quantity);
                          END IF;

                          po_reqchangerequestwf_pvt.update_reqline_quan_changes(
                                             p_req_line_id => p_req_line_id,
                                             p_delta_quantity=> l_delta_quantity,
                                             x_return_status =>l_return_status);

                ELSE
                         po_reqchangerequestwf_pvt.req_line_CANCEL(
                            p_req_line_id => p_req_line_id,
                            x_return_status =>l_return_status);
               END IF;
        END IF;
      END IF;
    END IF;



       IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'l_return_status', l_return_status);
       END IF;

    x_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
          WHEN OTHERS THEN
          x_return_status:= FND_API.G_RET_STS_ERROR;
          ROLLBACK  TO update_reqcancel_from_so_sp;
 END update_reqcancel_from_so;




  PROCEDURE update_reqchange_from_so(
                                        p_req_line_id                  IN           NUMBER
                                     ,  p_delta_quantity               IN           NUMBER
                                     ,  p_new_need_by_date             IN           DATE
                                     ,  x_return_status               OUT NOCOPY     VARCHAR2
                                     )
  IS

  l_bool_ret_sts BOOLEAN;
  l_mtl_supply_quantity NUMBER;
  l_return_status varchar2(10);
  l_sync_need_by  varchar2(3);
  l_count number:=0;

  BEGIN
  -- Check whether there is a pending change on this
  -- requisition line , if there exists one then
  -- return Error to the SO (OM) API.

      BEGIN
          SELECT count(*) INTO l_count
          FROM PO_change_requests
          WHERE request_status in ( 'NEW' , 'MGR_PRE_APP' , 'MGR_APP')
          AND DOCUMENT_TYPE= 'REQ'
          AND REQUEST_LEVEL= 'LINE'
          AND DOCUMENT_LINE_ID=p_req_line_id;

      EXCEPTION
        WHEN no_data_found THEN
         l_count :=0;
      END;

      IF (l_count <> 0 ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF;

      -- have save point
    SAVEPOINT update_reqchange_from_so_s;
    -- bug 17443362: set the actual return status here
    x_return_status := fnd_api.g_ret_sts_success;

    --algo
    -- for the given req line the given attribute needs to be chnaged
    -- for quantity .. input is the delta qunatity = new qunatity-old quantity
    --  hence the new line quantity shall be existing qunatity+delta quantity
    -- this is applicable to both mtl_supply and po_requisition_lines_all

    -- for need by date.. input is new need by date so update this value to
    -- both the tables
    IF  p_req_line_id IS NOT NULL AND p_delta_quantity IS NOT NULL THEN

      BEGIN
       po_reqchangerequestwf_pvt.update_reqline_quan_changes(
                                             p_req_line_id => p_req_line_id,
                                             p_delta_quantity=> p_delta_quantity,
                                             x_return_status =>l_return_status);

      EXCEPTION
        WHEN OTHERS THEN
        -- bug 17443362: set the actual return status here
        x_return_status := l_return_status;
        ROLLBACK TO update_reqchange_from_so_s;
      END;


    END IF;

    IF (p_req_line_id IS NOT NULL AND p_new_need_by_date IS NOT NULL ) THEN
      BEGIN
      -- read the profile 	POR: Sync up Need by date on IR with OM
      -- if yes then update the req table
      -- else by pass this and return success
      l_sync_need_by := nvl(fnd_profile.value('POR_SYNC_NEEDBYDATE_OM'), 'NO');

      IF ( l_sync_need_by = 'YES' ) THEN

      po_reqchangerequestwf_pvt.update_req_line_date_changes(p_req_line_id=>p_req_line_id,
                                   p_need_by_date=> p_new_need_by_date,
                                   x_return_status =>l_return_status);

      END IF;
      EXCEPTION
        WHEN OTHERS THEN
        -- bug 17443362: set the actual return status here
       x_return_status := l_return_status;
        ROLLBACK  TO update_reqchange_from_so_s;
      END;

      END IF;
  -- bug 17443362: return the acutal status instead of always success
  -- x_return_status := fnd_api.g_ret_sts_success;

  END update_reqchange_from_so;


/*-----------------------------------------------------------------------------------------------------
* At the Final Stage of Requester Creating Change request, SUBMIT_IREQCHANGE will be executed to complete
* the transaction. This API takes care of funds Check, and does a final round of validation against
* all change/cancel requests before kicking off the Workflow.
----------------------------------------------------------------------------------------------------*/
  PROCEDURE submit_ireqchange (
                               p_api_version IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_group_id IN NUMBER,
                               p_fundscheck_flag IN VARCHAR2,
                               p_note_to_approver IN VARCHAR2,
                               p_initiator IN VARCHAR2,
                               x_retmsg OUT NOCOPY VARCHAR2,
                               x_errcode OUT NOCOPY VARCHAR2,
                               x_errtable OUT NOCOPY po_req_change_err_table)
  IS
  l_api_name VARCHAR2(50) := 'Submit_IReqChange';
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;

  i NUMBER := 1;
  l_cancelerrorsize NUMBER;
  l_flag_one VARCHAR2(1);
  l_flag_two VARCHAR2(1);

  l_req_dist_id NUMBER;
  l_req_line_id NUMBER;
  l_req_hdr_id NUMBER;
  l_req_num po_requisition_headers_all.segment1%TYPE;
  l_budget_account_id 		NUMBER;
  l_gl_date					DATE;
  l_old_quantity				NUMBER;
  l_old_tax					NUMBER;
  l_qty_changed_flag VARCHAR2(1) := fnd_api.g_false;
  l_change_exist VARCHAR2(1);
  l_cancel_exist VARCHAR2(1);
  l_new_quantity NUMBER;
  l_new_so_quantity NUMBER;
  l_rec_tax NUMBER;
  l_nonrec_tax NUMBER;
  l_new_tax NUMBER;
  l_entered_dr NUMBER;
  l_entered_cr NUMBER;
  l_org_id NUMBER;
  l_fc_out_tbl po_fcout_type;
  l_fc_result_code VARCHAR2(1);
  l_fc_result_status VARCHAR2(1);
  l_fc_msg_count NUMBER;
  l_fc_msg_data VARCHAR2(2000);
  l_fc_req_line_id NUMBER;
  l_fc_req_line_num NUMBER;
  l_fc_req_distr_id NUMBER;
  l_fc_req_distr_num NUMBER;
  l_req_change_table change_tbl_type;
  l_new_date DATE;
  l_new_need_by_date DATE;
  l_old_need_by_date DATE;
  l_old_amount NUMBER;
  l_new_amount NUMBER;
  l_new_price NUMBER;
  l_distribution_id NUMBER;
  l_request_reason po_change_requests.request_reason%TYPE;
  l_cancel_errtable po_req_change_err_table;
  l_cal_disttax_status VARCHAR2(1);
  l_item_id NUMBER;
  l_req_uom po_requisition_lines_all.unit_meas_lookup_code%TYPE;
  l_po_uom po_line_locations_all.unit_meas_lookup_code%TYPE;
  l_po_to_req_rate NUMBER;

  l_po_return_code VARCHAR2(100) := '';
  l_err_line_id_tbl po_tbl_number;
  l_err_line_num_tbl po_tbl_number;
  l_err_dist_id_tbl po_tbl_number;
  l_err_dist_num_tbl po_tbl_number;
  l_err_error_attr_tbl po_tbl_varchar30;
  l_err_msg_count_tbl po_tbl_number;
  l_err_msg_data_tbl po_tbl_varchar2000;
  l_wf_status VARCHAR2(1);
  l_distribution_id_tbl po_tbl_number;

  CURSOR l_changes_csr(grp_id NUMBER) IS
  SELECT
      document_header_id,
      document_line_id,
      document_distribution_id,
      new_quantity,
      new_need_by_date,
      request_reason
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND action_type = 'MODIFICATION';

  CURSOR l_cancel_csr(grp_id NUMBER) IS
  SELECT
      document_header_id,
      document_line_id,
      request_reason
  FROM po_change_requests
  WHERE change_request_group_id = grp_id
  AND action_type = 'CANCELLATION';


  CURSOR l_dist_qty_price_chn_csr(grp_id NUMBER) IS
  SELECT
    document_line_id line_id,
    document_distribution_id dist_id,
    document_header_id hdr_id,
    document_num req_num
  FROM
    po_change_requests
  WHERE
    change_request_group_id = grp_id AND
    new_quantity IS NOT NULL  AND
    action_type = 'MODIFICATION'
 ;/* UNION
  SELECT
    prda.requisition_line_id line_id,
    prda.distribution_id dist_id,
    prla.requisition_header_id hdr_id,
    prha.segment1	req_num
  FROM
    po_req_distributions_all prda,
    po_requisition_lines_all prla,
    po_change_requests pcr,
    po_requisition_headers_all prha
  WHERE
    prha.requisition_header_id = prla.requisition_header_id AND
    prla.requisition_line_id = prda.requisition_line_id AND
    pcr.document_line_id = prla.requisition_line_id AND
    pcr.change_request_group_id = grp_id AND
    pcr.action_type = 'MODIFICATION' AND
    pcr.new_need_by_date IS NOT NULL;*/

-- list of req distributions effected with the req changes
  CURSOR l_changed_req_dists_csr(grp_id NUMBER) IS
  SELECT           -- any quantity change
    pcr.document_distribution_id
  FROM
    po_change_requests pcr
  WHERE
    pcr.change_request_group_id = grp_id AND
    pcr.new_quantity IS NOT NULL  AND
    pcr.action_type = 'MODIFICATION';

 /*   AND
    pcr.document_distribution_id = prda.distribution_id*/
/*  CURSOR l_changed_req_dists_csr(grp_id NUMBER) IS
  SELECT           -- any quantity or amount change
    prda.distribution_id
  FROM
    po_change_requests pcr,
    po_req_distributions_all prda
  WHERE
    pcr.change_request_group_id = grp_id AND
    pcr.new_quantity IS NOT NULL  AND
    pcr.action_type = 'MODIFICATION' AND
    pcr.document_distribution_id = prda.distribution_id
;  UNION
  SELECT  -- select distributions that are effected with any line change
    prda.distribution_id
  FROM
    po_change_requests pcr,
    po_requisition_lines_all prla,
    po_req_distributions_all prda
  WHERE
    pcr.change_request_group_id = grp_id AND
    pcr.action_type = 'MODIFICATION' AND
    pcr.new_need_by_date IS NOT NULL AND
    pcr.document_line_id = prla.requisition_line_id AND
    prla.requisition_line_id = prda.requisition_line_id ;*/

-- list of release distributions effected with the req changes
  CURSOR l_dist_tax_csr(grp_id NUMBER) IS
  SELECT -- any quantity change
    prla.requisition_line_id,
    prda.distribution_id,
    prla.requisition_header_id,
    prla.unit_price,
    nvl(pcr.new_quantity, pcr.old_quantity)
  FROM
    po_change_requests pcr,
     po_req_distributions_all prda,
    po_requisition_lines_all prla
  WHERE
    pcr.change_request_group_id = grp_id AND
    pcr.new_quantity IS NOT NULL AND
  --  (pcr.new_quantity IS NOT NULL OR  pcr.new_need_by_date IS NOT NULL) AND
    pcr.action_type = 'MODIFICATION' AND
    pcr.document_distribution_id = prda.distribution_id AND
    prla.requisition_line_id = prda.requisition_line_id AND
    pcr.document_line_id = prla.requisition_line_id ;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_error;
    x_retmsg := 'SMRCH000';
    x_return_status := fnd_api.g_ret_sts_success;

	--Check if Funds Check is needed
    SELECT
        nvl(fsp.req_encumbrance_flag, 'N')
    INTO
        l_flag_one
    FROM financials_system_parameters fsp;

	--Check if change request exist
    l_change_exist := 'N';
    OPEN l_changes_csr(p_group_id);

    FETCH l_changes_csr
    INTO l_req_hdr_id, l_req_line_id, l_req_dist_id, l_new_quantity,
     l_new_date, l_request_reason;
    IF(l_req_hdr_id IS NOT NULL) THEN
      l_change_exist := 'Y';
    END IF;
    CLOSE l_changes_csr;

    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, x_retmsg, 'l_flag_one=', l_flag_one);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_change_exist=', l_change_exist);
      po_debug.debug_var(l_log_head, x_retmsg, 'p_group_ID=', p_group_id);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_cancel_exist=', l_cancel_exist);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_req_hdr_id=', l_req_hdr_id);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_req_line_id=', l_req_line_id);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_request_reason=', l_request_reason);
    END IF;

  	--Check if cancel request exist
    l_cancel_exist := 'N';
    l_req_hdr_id := NULL;l_req_line_id := NULL;l_request_reason := NULL;

    OPEN l_cancel_csr(p_group_id);
    FETCH l_cancel_csr
    INTO l_req_hdr_id, l_req_line_id, l_request_reason;

    IF(l_req_hdr_id IS NOT NULL) THEN
      l_cancel_exist := 'Y';
    END IF;

    CLOSE l_cancel_csr;

    x_retmsg := 'SMRCH001';

    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, x_retmsg, 'l_flag_one=', l_flag_one);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_change_exist=', l_change_exist);
      po_debug.debug_var(l_log_head, x_retmsg, 'p_group_ID=', p_group_id);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_cancel_exist=', l_cancel_exist);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_req_hdr_id=', l_req_hdr_id);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_req_line_id=', l_req_line_id);
      po_debug.debug_var(l_log_head, x_retmsg, 'l_request_reason=', l_request_reason);
    END IF ;

	--Funds Check Starts
    IF (l_change_exist = 'Y' AND p_fundscheck_flag = 'Y' AND l_flag_one <> 'N' ) THEN

      x_retmsg := 'SMRCH002';
      IF g_debug_stmt THEN
        po_debug.debug_stmt(l_log_head, x_retmsg,'change exists with funds check');
      END IF;

      --Check if any records require funds check.
      OPEN l_dist_qty_price_chn_csr(p_group_id);
      FETCH l_dist_qty_price_chn_csr INTO
      l_req_line_id,
      l_req_dist_id,
      l_req_hdr_id,
      l_req_num;
      CLOSE l_dist_qty_price_chn_csr;

      IF (l_req_num IS NOT NULL) THEN

        -- initialize distributions list table
        l_distribution_id_tbl	:= po_tbl_number();

        -- insert NEW/OLD records of standard po distributions into PO_ENCUMBRANCE_GT
        OPEN l_changed_req_dists_csr(p_group_id);

        FETCH l_changed_req_dists_csr BULK COLLECT
        INTO l_distribution_id_tbl;

        CLOSE l_changed_req_dists_csr;

        po_document_funds_grp.populate_encumbrance_gt(
                                                      p_api_version => 1.0,
                                                      x_return_status => x_return_status,
                                                      p_doc_type => po_document_funds_grp.g_doc_type_requisition,                 --call with req type at dist level
                                                      p_doc_level => po_document_funds_grp.g_doc_level_distribution,
                                                      p_doc_level_id_tbl => l_distribution_id_tbl,
                                                      p_make_old_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_make_new_copies_flag => po_document_funds_grp.g_parameter_yes,
                                                      p_check_only_flag => po_document_funds_grp.g_parameter_yes);

                    -- error handling after calling populate_encumbrance_gt
        IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
          x_retmsg  := 'After calling populate_encumbrance_gt';
          x_errcode := 'FC_FAIL';
          IF g_debug_stmt THEN
            po_debug.debug_stmt(l_log_head, x_retmsg,'error exists with funds check');
          END IF;

          RETURN;
        END IF;

        -- re-initialize distributions list table
        l_distribution_id_tbl.delete;

        -- Update NEW record in PO_ENCUMBRANCE_GT with the new
        -- values
        x_retmsg := 'SMRCH003';

        /*
			*Looping through the distribution records which requires fundscheck, and populating the fundscheck
			*input table with the appropriate data.
			*/

/**/
--need to get newest price quantity and amount



        OPEN l_dist_tax_csr(p_group_id);

        LOOP
          FETCH l_dist_tax_csr INTO
          l_req_line_id,
          l_req_dist_id,
          l_req_hdr_id,
          l_new_price,
          l_new_quantity;
          EXIT WHEN l_dist_tax_csr%notfound;
          x_retmsg := 'SMRCH0031:' || l_req_line_id || '*' || l_req_dist_id || '*' || l_req_hdr_id || '*' || l_req_num;

          IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, x_retmsg,'l_req_line_id ', l_req_line_id );
            po_debug.debug_var(l_log_head, x_retmsg,'l_req_dist_id ', l_req_dist_id );
            po_debug.debug_var(l_log_head, x_retmsg,'l_req_hdr_id ', l_req_hdr_id );
            po_debug.debug_var(l_log_head, x_retmsg,'l_new_price ', l_new_price );
            po_debug.debug_var(l_log_head, x_retmsg, 'l_new_quantity', l_new_quantity);
          END IF;

          calculate_disttax(1.0, l_cal_disttax_status, l_req_dist_id, l_new_price, l_new_quantity, NULL,
                            l_rec_tax, l_nonrec_tax);
          l_new_tax := l_nonrec_tax;
          l_new_amount := l_new_price*l_new_quantity;
          IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, x_retmsg, 'l_rec_tax=', l_rec_tax);
            po_debug.debug_var(l_log_head, x_retmsg, 'l_nonrec_tax=', l_nonrec_tax);
          END IF;

		  -- update new values in PO_ENCUMBRANCE_GT
          UPDATE po_encumbrance_gt
          SET
            amount_ordered = l_new_amount,
            quantity_ordered = l_new_quantity,
            price = l_new_price,
            nonrecoverable_tax = l_new_tax
          WHERE
            distribution_id = l_distribution_id AND
            adjustment_status = po_document_funds_grp.g_adjustment_status_new;

        END LOOP;
        CLOSE l_dist_tax_csr;


        x_retmsg := 'SMRCH0032';
			--Execute PO Funds Check API

                        po_document_funds_grp.check_adjust(
                          p_api_version => 1.0,
                          x_return_status => l_fc_result_status,
                          p_doc_type => po_document_funds_grp.g_doc_type_REQUISITION,
                          p_doc_subtype => NULL,
                          p_override_funds => po_document_funds_grp.g_parameter_USE_PROFILE,
                          p_use_gl_date => po_document_funds_grp.g_parameter_YES,
                          p_override_date => sysdate,
                          p_report_successes => po_document_funds_grp.g_parameter_NO,
                          x_po_return_code => l_po_return_code,
                          x_detailed_results => l_fc_out_tbl);

			x_retMsg := 'SMRCH004';

                        IF (g_fnd_debug = 'Y') THEN
                          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                            FND_LOG.string(FND_LOG.level_statement,
                                         g_module_prefix || l_api_name,
                                         'FUNDS CHECK:' || l_fc_result_status ||' PO RETURN CODE:' || l_po_return_code);
                          END IF;
                        END IF;

        IF (l_fc_result_status = fnd_api.g_ret_sts_unexp_error) THEN
          x_errcode := 'FC_ERROR';
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;

        ELSE
          IF g_debug_stmt THEN
            po_debug.debug_STmt(l_log_head, x_retmsg, 'after check adjust of funds check');
          END IF;


          IF (l_po_return_code = po_document_funds_grp.g_return_success) THEN
            x_return_status := fnd_api.g_ret_sts_success;

          ELSE  -- there can be warning/error message for other cases

            x_errcode := 'FC_FAIL';
            x_return_status := fnd_api.g_ret_sts_error;

			  -- populate x_errTable (output PLSQL table) with the corresponding
			  -- funds check error messages.

            l_err_line_id_tbl := po_tbl_number();
            l_err_line_num_tbl := po_tbl_number();
            l_err_dist_id_tbl := po_tbl_number();
            l_err_dist_num_tbl := po_tbl_number();
            l_err_error_attr_tbl := po_tbl_varchar30();
            l_err_msg_count_tbl := po_tbl_number();
            l_err_msg_data_tbl := po_tbl_varchar2000();

            x_errtable := po_req_change_err_table(
                                                  l_err_line_id_tbl,
                                                  l_err_line_num_tbl,
                                                  l_err_dist_id_tbl,
                                                  l_err_dist_num_tbl,
                                                  l_err_error_attr_tbl,
                                                  l_err_msg_count_tbl,
                                                  l_err_msg_data_tbl);


            x_errtable.req_line_id.extend(l_fc_out_tbl.row_index.count);
            x_errtable.req_line_num.extend(l_fc_out_tbl.row_index.count);
            x_errtable.req_dist_id.extend(l_fc_out_tbl.row_index.count);
            x_errtable.req_dist_num.extend(l_fc_out_tbl.row_index.count);
            x_errtable.msg_count.extend(l_fc_out_tbl.row_index.count);
            x_errtable.msg_data.extend(l_fc_out_tbl.row_index.count);
            FOR x IN 1..l_fc_out_tbl.row_index.count LOOP

              SELECT
                            prda.distribution_id,
                            prda.distribution_num,
                            prda.requisition_line_id,
                            prla.line_num
              INTO
                            l_fc_req_distr_id,
                            l_fc_req_distr_num,
                            l_fc_req_line_id,
                            l_fc_req_line_num
              FROM
                            po_requisition_lines_all prla,
                            po_req_distributions_all prda,
                            po_distributions_all pda
              WHERE
                            pda.po_distribution_id = l_fc_out_tbl.distribution_id(x)
                            AND pda.req_distribution_id = prda.distribution_id
                            AND prla.requisition_line_id = prda.requisition_line_id;

              x_errtable.req_line_id(x)  := l_fc_req_line_id;
              x_errtable.req_line_num(x) := l_fc_req_line_num;
              x_errtable.req_dist_id(x)  := l_fc_req_distr_id;
              x_errtable.req_dist_num(x) := l_fc_req_distr_num;
              x_errtable.msg_data(x)     := l_fc_out_tbl.error_msg(x);

            END LOOP;
            RETURN;
          END IF;
        END IF;
      END IF;

    END IF;
	--Funds Check Ends


    i := 1;
    OPEN l_changes_csr(p_group_id);
    LOOP
      FETCH l_changes_csr
      INTO
      l_req_hdr_id,
      l_req_line_id,
      l_req_dist_id,
      l_new_quantity,
		--l_new_price,
      l_new_date,
      l_request_reason;
      EXIT WHEN l_changes_csr%notfound;
      l_req_change_table(i).document_line_id := l_req_line_id;
      l_req_change_table(i).document_distribution_id := l_req_dist_id;
      l_req_change_table(i).new_price := l_new_price;
      l_req_change_table(i).new_quantity := l_new_quantity;
      l_req_change_table(i).new_date := l_new_date;
      l_req_change_table(i).request_reason := l_request_reason;

      i := i + 1;
    END LOOP;
    CLOSE l_changes_csr;
    x_retmsg := 'SMRCH006';
    l_err_line_id_tbl := po_tbl_number();
    l_err_line_num_tbl := po_tbl_number();
    l_err_dist_id_tbl := po_tbl_number();
    l_err_dist_num_tbl := po_tbl_number();
    l_err_error_attr_tbl := po_tbl_varchar30();
    l_err_msg_count_tbl := po_tbl_number();
    l_err_msg_data_tbl := po_tbl_varchar2000();

    x_errTable := po_req_change_err_table(
                                          l_err_line_id_tbl,
                                          l_err_line_num_tbl,
                                          l_err_dist_id_tbl,
                                          l_err_dist_num_tbl,
                                          l_err_error_attr_tbl,
                                          l_err_msg_count_tbl,
                                          l_err_msg_data_tbl);

--Final Round of Validations Against Changes
--	if(l_change_exist = 'Y') then
--		Validate_Changes(l_req_hdr_id,l_req_change_table,x_return_status,x_retMsg,x_errTable);
--call OM API for this validation this is not needed
--	end if;
    x_retmsg := 'SMRCH007';
	--Submit Cancel Requests
        IF g_debug_stmt THEN
            po_debug.debug_stmt(l_log_head, x_retmsg, 'submitting changes...');
        END IF;

    IF(l_cancel_exist = 'Y') THEN
      submit_ireqcancel(1.0, x_return_status, p_group_id, x_retmsg, x_errTable, 'Y');
    END IF;

    x_retmsg := 'SMRCH008';
/*     i:=x_errTable.req_line_id.count+1;
     l_CancelErrorSize:=l_cancel_ErrTable.req_line_id.count;

	if(l_CancelErrorSize > 0) then
		x_errTable.req_line_id.extend(l_CancelErrorSize);
		x_errTable.msg_count.extend(l_CancelErrorSize);
		x_errTable.msg_data.extend(l_CancelErrorSize);

  		for k in 1..l_CancelErrorSize
		loop
			x_errTable.req_line_id(i):=l_cancel_ErrTable.req_line_id(k);
			x_errTable.msg_count(i):=1;
			x_errTable.msg_data(i):='CANNOT CANCEL';
			i:=i+1;
		end loop;
	end if;
 	/*
	* If all requests are valid, update status to "NEW" and kick off workflow
	*/



    IF(x_errtable.req_line_id.count = 0) THEN

        IF g_debug_stmt THEN
            po_debug.debug_stmt(l_log_head, x_retmsg, 'all change requests are valid, updating status to "NEW" and kick off workflow');
        END IF;


     UPDATE po_change_requests
      SET request_status = 'NEW'
      WHERE change_request_group_id = p_group_id
      AND request_status = 'SYSTEMSAVE';


		--Kick Off Workflow
      x_retmsg := 'SMRCH009';

      po_reqchangerequestwf_pvt.submit_internal_req_change(
                                                           p_api_version => 1.0,
                                                           p_commit => fnd_api.g_false,
                                                           p_req_header_id => l_req_hdr_id,
                                                           p_note_to_approver => p_note_to_approver,
                                                           p_initiator => p_initiator,
                                                           x_return_status => l_wf_status);
    ELSE
      x_errcode := 'VC_FAIL';
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_retmsg := x_retmsg || ':' || SQLERRM;
    IF g_fnd_debug = 'Y' THEN
      IF (fnd_log.g_current_runtime_level <= fnd_log.level_unexpected) THEN
        fnd_log.string(fnd_log.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', x_retmsg );

      END IF;
    END IF;
  END SUBMIT_IREQCHANGE;

/* This is called from the UI to check whether the new values are valid
*/
procedure validate_internal_req_changes(
                                  p_req_line_id    IN NUMBER
                                , p_req_header_id  IN NUMBER
                                , p_need_by_date        IN  DATE DEFAULT NULL
                                , p_old_quantity       IN  NUMBER DEFAULT 0
                                , p_new_quantity       IN  NUMBER DEFAULT 0
                                ,  X_return_status           OUT NOCOPY VARCHAR2
                                )
IS

L_msg_data VARCHAR2(2000);
L_msg_count NUMBER;
l_delta_quantity number;
l_log_head              CONSTANT VARCHAR2(100) := c_log_head ||'validate_internal_req_changes';
l_progress varchar2(3) := '000';

/*Procedure Call_Process_Order_for_IReq  -- Specification definition
(  P_API_Version             IN  NUMBER
,  P_internal_req_line_id    IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id  IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  P_Mode                    IN  VARCHAR2
,  P_Cancel_ISO              IN  BOOLEAN DEFAULT FALSE
,  P_Cancel_ISO_lines        IN  BOOLEAN DEFAULT FALSE
,  P_New_Request_Date        IN  DATE DEFAULT NULL
,  P_Delta_Ordered_Qty       IN  NUMBER DEFAULT 0
,  X_msg_count               OUT NOCOPY NUMBER
,  X_msg_data                OUT NOCOPY VARCHAR2
,  X_return_status           OUT NOCOPY VARCHAR2
);*/

l_orgid number;
l_open_quantity number;
BEGIN

/* Only for the qunatity changes check for the the new ordered quantity is less
than received+open receiving
quantity then the throw error */

IF( p_new_quantity   <> 0 ) THEN

 BEGIN
       SELECT nvl(sum(w.shipped_quantity),0)
              INTO l_open_quantity
              FROM oe_order_lines_all oel
                  ,oe_order_headers_all oeh
                  ,wsh_delivery_details w
                  ,po_requisition_lines_all pol
                  ,po_requisition_headers_all poh --Bug 14280643
              WHERE
                  oel.header_id = oeh.header_id
              AND oel.line_id   = w.source_line_id
              AND w.source_code = 'OE'
              AND w.released_status = 'C'
              AND oel.source_document_line_id=pol.requisition_line_id
              AND oel.source_document_id=pol.requisition_header_id
              AND oeh.source_document_id = pol.requisition_header_id --Bug 14280643
              AND poh.requisition_header_id = pol.requisition_header_id --Bug 14280643
              AND poh.segment1 = oeh.orig_sys_document_ref --Bug 14280643
              AND oeh.source_document_type_id =10
              AND pol.REQUISITION_LINE_ID=p_req_line_id;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_open_quantity := 0;
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

IF ( p_new_quantity    < l_open_quantity ) THEN
      RAISE FND_API.G_EXC_ERROR;
END IF;
END IF;
l_delta_quantity := p_new_quantity-p_old_quantity;

 IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_header_id', p_req_header_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_need_by_date', p_need_by_date);
      po_debug.debug_var(l_log_head, l_progress, 'p_old_quantity', p_old_quantity);
      po_debug.debug_var(l_log_head, l_progress, 'p_new_quantity', p_new_quantity);
      po_debug.debug_var(l_log_head, l_progress, 'l_delta_quantity', l_delta_quantity);
  END IF;

l_progress :='001';


 l_orgid := PO_ReqChangeRequestWF_PVT.get_sales_order_org(p_req_line_id =>p_req_line_id);

   IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Sales order l_orgid', l_orgid);
     END IF;

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;

 IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress, 'Calling OM API Validating the changes');
 END IF;

OE_Internal_Requisition_Pvt.Call_Process_Order_for_IReq
(  P_API_Version             => 1.0
,  P_internal_req_line_id    => p_req_line_id
,  P_internal_req_header_id  => p_req_header_id
,  P_Mode                    => 'V'   --SIMPLY VALIDATING
,  P_New_Request_Date        => p_need_by_date
,  P_Delta_Ordered_Qty       => l_delta_quantity
,  X_msg_count               => L_msg_count
,  X_msg_data                => L_msg_data
,  X_return_status           => X_return_status
);

IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress, 'returning from OM API Validating the changes');
END IF;

  l_orgid := PO_ReqChangeRequestWF_PVT.get_requisition_org( p_req_hdr_id  => p_req_header_id,
				 p_req_line_id =>p_req_line_id);

   IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'Requisition l_orgid', l_orgid);
     END IF;

    IF l_orgid is NOT NULL THEN
        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
    END IF;


 IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress, 'returning from OM API Validating the changes');
      po_debug.debug_var(l_log_head, l_progress, 'l_orgid', l_orgid);
      po_debug.debug_var(l_log_head, l_progress, 'L_msg_data', L_msg_data);
      po_debug.debug_var(l_log_head, l_progress, 'L_msg_count', L_msg_count);
      po_debug.debug_var(l_log_head, l_progress, 'X_return_status', X_return_status);
      po_debug.debug_end(l_log_head);

 END IF;
exception
when others then
 X_return_status:=FND_API.G_RET_STS_ERROR;
 IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress, ' Validating the changes in exception'|| sqlerrm);
      po_debug.debug_var(l_log_head, l_progress, 'l_orgid', l_orgid);
      po_debug.debug_var(l_log_head, l_progress, 'L_msg_data', L_msg_data);
      po_debug.debug_var(l_log_head, l_progress, 'L_msg_count', L_msg_count);
      po_debug.debug_var(l_log_head, l_progress, 'X_return_status', X_return_status);
      po_debug.debug_end(l_log_head);
END IF;
END validate_internal_req_changes;






-- 14227140 changes starts
/**
* Procedure to update the cancel qty in req line from SO
* This method is called when a SO initiated partial
* cancellation of Qty (Primary or Secondary) or cancellation of line.
*

* @param p_req_line_id number canceled req line
* @param p_req_can_prim_qty number canceled Prim Qty of req line
* @param p_req_can_sec_qty number canceled Secondary Qty of req line
* @param p_req_can_all boolean to hole weather req line cancelation flag
* @param x_return_status returns the tstatus of the api.
*/
 PROCEDURE update_reqcancel_from_so(  p_req_line_id       IN           NUMBER
                                    , p_req_cancel_prim_qty   IN            NUMBER
                                    , p_req_cancel_sec_qty   IN        NUMBER
                                    , p_req_cancel_all   IN            BOOLEAN
                                    ,x_return_status     OUT       NOCOPY VARCHAR2 )
  IS

  l_req_line_id NUMBER;
  l_bool_ret_sts BOOLEAN;
  l_return_status VARCHAR2(10);
  l_open_quantity number;
  l_prim_quantity NUMBER;
  l_sec_quantity NUMBER;
  l_delta_prim_quantity number :=0;
  l_delta_sec_quantity number :=0;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || 'update_reqcancel_from_so';
  l_progress varchar2(3):='000';
  l_count number:=0;
  BEGIN

  -- Bug 8235698: Check whether there is a pending change on this
  -- requisition line , if there exists one then
  -- return Error to the SO (OM) API.

      BEGIN

          SELECT COUNT(*) INTO l_count  FROM po_change_requests
          WHERE request_status in ( 'NEW' , 'MGR_PRE_APP' , 'MGR_APP')
          AND DOCUMENT_TYPE= 'REQ'
          AND REQUEST_LEVEL= 'LINE'
          AND DOCUMENT_LINE_ID=p_req_line_id;

      EXCEPTION
        WHEN no_data_found THEN
          l_count:=0;
      END;

      IF (l_count <> 0 ) THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_debug_stmt THEN
            po_debug.debug_begin(l_log_head);

            po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
            po_debug.debug_var(l_log_head, l_progress, 'No of po_change_requests on req line', l_count);
        END IF;

        return;
      END IF;
      -- have save point
    SAVEPOINT update_reqcancel_from_so_sp;
    /*
     * ALGORITHM : For each req line or perticular line
                  Step 1: Retrive the open receiving quantity INTO l_open_quantity
                  Step 2 : Retrive the REQ LINE quantity INTO l_quantity
    */

   l_return_status := fnd_api.g_ret_sts_success;
   l_progress:='001';

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_prim_qty', p_req_cancel_prim_qty);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_sec_qty', p_req_cancel_sec_qty);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_all', p_req_cancel_all);
    END IF;

   IF (p_req_line_id IS NOT NULL ) THEN

    IF p_req_cancel_all THEN

       po_reqchangerequestwf_pvt.req_line_CANCEL(
                            p_req_line_id => p_req_line_id,
                            x_return_status =>l_return_status);
    ELSE

      BEGIN
          SELECT QUANTITY, SECONDARY_QUANTITY
              INTO l_prim_quantity, l_sec_quantity
              FROM po_requisition_lines_all
              WHERE REQUISITION_LINE_ID=p_req_line_id;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'l_prim_quantity', l_prim_quantity);
            po_debug.debug_var(l_log_head, l_progress, 'l_sec_quantity', l_sec_quantity);
            po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_prim_qty', p_req_cancel_prim_qty);
            po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_sec_qty', p_req_cancel_sec_qty);
            po_debug.debug_var(l_log_head, l_progress, 'p_req_cancel_all', p_req_cancel_all);
       END IF;
         IF ((p_req_cancel_prim_qty IS NOT NULL AND l_prim_quantity IS NOT NULL)
           OR (p_req_cancel_sec_qty IS NOT NULL AND l_sec_quantity IS NOT NULL) ) THEN
               IF ((l_prim_quantity - p_req_cancel_prim_qty > 0) OR
                  (l_sec_quantity - p_req_cancel_sec_qty > 0)) THEN

                    IF(l_prim_quantity - p_req_cancel_prim_qty > 0) THEN
                    -- update the req line primary quantity with delta quantity as
                     l_delta_prim_quantity := (-1) *  p_req_cancel_prim_qty ;
                    END IF;
                    IF(l_sec_quantity - p_req_cancel_sec_qty > 0) THEN
                    -- update the req line secondary quantity with delta quantity as
                     l_delta_sec_quantity := (-1) *  p_req_cancel_sec_qty ;
                    END IF;

                    IF g_debug_stmt THEN
                            po_debug.debug_var(l_log_head, l_progress, 'l_delta_prim_quantity', l_delta_prim_quantity);
                            po_debug.debug_var(l_log_head, l_progress, 'l_delta_sec_quantity', l_delta_sec_quantity);
                    END IF;

                      po_reqchangerequestwf_pvt.update_reqline_quan_changes(
                                         p_req_line_id => p_req_line_id,
                                         p_delta_prim_quantity=> l_delta_prim_quantity,
                                         p_delta_sec_quantity=> l_delta_sec_quantity,
                                         x_return_status =>l_return_status);

                ELSE
                         po_reqchangerequestwf_pvt.req_line_CANCEL(
                            p_req_line_id => p_req_line_id,
                            x_return_status =>l_return_status);
               END IF;
        END IF;
      END IF;
    END IF;

       IF g_debug_stmt THEN
            po_debug.debug_var(l_log_head, l_progress, 'l_return_status', l_return_status);
       END IF;

    x_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
          WHEN OTHERS THEN
          x_return_status:= FND_API.G_RET_STS_ERROR;
          ROLLBACK  TO update_reqcancel_from_so_sp;
 END update_reqcancel_from_so;


/**
* Procedure to update the Qty changes on req line from SO changes
* This method is called when a SO initiated change in Qty (Primary or Secondary).
*
* @param p_req_line_id number holds the req line number
* @param p_delta_quantity_prim number changed Prim Qty of SO
* @param p_delta_quantity_sec number changed Secondary Qty of SO
* @param p_new_need_by_date date need by date of SO.
* @param x_return_status returns the tstatus of the api
*/
 PROCEDURE update_reqchange_from_so(
                                        p_req_line_id                  IN           NUMBER
                                     ,  p_delta_quantity_prim          IN           NUMBER
                                     ,  p_delta_quantity_sec           IN           NUMBER
                                     ,  p_new_need_by_date             IN           DATE
                                     ,  x_return_status               OUT NOCOPY     VARCHAR2
                                     )
  IS

  l_bool_ret_sts BOOLEAN;
  l_mtl_supply_quantity NUMBER;
  l_return_status varchar2(10);
  l_sync_need_by  varchar2(3);
  l_count number:=0;

  BEGIN
  -- Check whether there is a pending change on this
  -- requisition line , if there exists one then
  -- return Error to the SO (OM) API.

      BEGIN
          SELECT count(*) INTO l_count
          FROM PO_change_requests
          WHERE request_status in ( 'NEW' , 'MGR_PRE_APP' , 'MGR_APP')
          AND DOCUMENT_TYPE= 'REQ'
          AND REQUEST_LEVEL= 'LINE'
          AND DOCUMENT_LINE_ID=p_req_line_id;

      EXCEPTION
        WHEN no_data_found THEN
         l_count :=0;
      END;

      IF (l_count <> 0 ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF;

      -- have save point
    SAVEPOINT update_reqchange_from_so_s;
    l_return_status := fnd_api.g_ret_sts_success;

    --algo
    -- for the given req line the given attribute needs to be chnaged
    -- for quantity .. input is the delta qunatity = new qunatity-old quantity
    --  hence the new line quantity shall be existing qunatity+delta quantity
    -- this is applicable to both mtl_supply and po_requisition_lines_all

    -- for need by date.. input is new need by date so update this value to
    -- both the tables
    IF  p_req_line_id IS NOT NULL AND (p_delta_quantity_prim IS NOT NULL OR p_delta_quantity_sec IS NOT NULL )THEN

      BEGIN
       po_reqchangerequestwf_pvt.update_reqline_quan_changes(
                                             p_req_line_id => p_req_line_id,
                                             p_delta_prim_quantity=> p_delta_quantity_prim,
                                             p_delta_sec_quantity=> p_delta_quantity_sec,
                                             x_return_status =>l_return_status);

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO update_reqchange_from_so_s;
      END;


    END IF;

    IF (p_req_line_id IS NOT NULL AND p_new_need_by_date IS NOT NULL ) THEN
      BEGIN
      -- read the profile 	POR: Sync up Need by date on IR with OM
      -- if yes then update the req table
      -- else by pass this and return success
      l_sync_need_by := nvl(fnd_profile.value('POR_SYNC_NEEDBYDATE_OM'), 'NO');

      IF ( l_sync_need_by = 'YES' ) THEN

      po_reqchangerequestwf_pvt.update_req_line_date_changes(p_req_line_id=>p_req_line_id,
                                   p_need_by_date=> p_new_need_by_date,
                                   x_return_status =>l_return_status);

      END IF;
      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK  TO update_reqchange_from_so_s;
      END;

    END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  END update_reqchange_from_so;

-- 14227140 changes ends



-- 7669581 changes starts
/**
* Procedure to clear the change request attachments added at line level
* before inistiating the change request
* (To clear the attachments that are left unprocessed in change request flow).
*
* @param p_req_hdr_id number holds the req header id
* @param x_return_status returns the tstatus of the api
*/
  PROCEDURE del_req_line_chng_attachments(p_req_hdr_id IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2)
   IS
     CURSOR l_req_lines_csr(req_hdr_id NUMBER) IS
     SELECT REQUISITION_LINE_ID FROM po_requisition_lines_all where REQUISITION_HEADER_ID = req_hdr_id;
     l_req_line_id NUMBER;
   BEGIN

     OPEN l_req_lines_csr(p_req_hdr_id);
      LOOP
       FETCH l_req_lines_csr INTO
       l_req_line_id;
       EXIT WHEN l_req_lines_csr%notfound;
       IF(l_req_line_id IS NOT NULL) THEN
         -- delete the attachmnets of change request
         FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments ( 'REQ_LINE_CHANGES',l_req_line_id, NULL,NULL,NULL, NULL,'Y');
         --there is no commit in above call
         COMMIT;
       END IF;
     END LOOP;
    CLOSE l_req_lines_csr;
    x_return_status := fnd_api.g_ret_sts_success;
    EXCEPTION
     WHEN OTHERS THEN
         x_return_status:= fnd_api.g_ret_sts_error;

  END  del_req_line_chng_attachments;
-- 7669581 changes ends

-- 16839471  changes starts
/**
* Procedure to clear the change request attachments added at line level
*
* @param p_req_line_id number holds the req line id
* @param x_return_status returns the tstatus of the api
*/
 PROCEDURE del_chng_req_line_attachments(p_req_line_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2)
 IS
  l_progress varchar2(3):='000';
  l_log_head CONSTANT VARCHAR2(100) := c_log_head || 'del_chng_req_line_attachments';

   BEGIN
    IF(p_req_line_id IS NOT NULL) THEN
       IF g_debug_stmt THEN
         l_progress :='001';
         po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
       END IF;
       -- delete the attachmnets of change request
       FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments ( 'REQ_LINE_CHANGES',p_req_line_id, NULL,NULL,NULL, NULL,'Y');
       --there is no commit in above call
       IF g_debug_stmt THEN
         l_progress :='002';
         po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
       END IF;
       COMMIT;
    END IF;
    x_return_status := fnd_api.g_ret_sts_success;
   EXCEPTION
    WHEN OTHERS THEN
       x_return_status:= fnd_api.g_ret_sts_error;
       IF g_debug_stmt THEN
         l_progress :='003';
         po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
         po_debug.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
       END IF;

  END del_chng_req_line_attachments;
-- 16839471 changes ends


END po_rco_validation_pvt;

/
