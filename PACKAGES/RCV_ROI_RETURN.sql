--------------------------------------------------------
--  DDL for Package RCV_ROI_RETURN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ROI_RETURN" 
/* $Header: RCVPRERS.pls 120.1 2006/04/19 00:38:34 szaveri noship $*/
AUTHID CURRENT_USER AS
   CURSOR default_return (v_parent_trx_id NUMBER)
   IS
      SELECT   rt.po_revision_num, rt.primary_unit_of_measure,
               rt.po_header_id, rt.po_release_id, rt.location_id,
               rt.organization_id OID, rsh.receipt_source_code,
               rt.source_document_code, rt.wip_entity_id, rt.wip_line_id,
               rt.wip_repetitive_schedule_id, rt.wip_operation_seq_num,
               rt.wip_resource_seq_num, rt.department_code,
               rt.bom_resource_id, rt.oe_order_header_id,
               rt.oe_order_line_id, rt.destination_context,
               rt.inspection_status_code, rt.currency_code,
               rt.currency_conversion_type, rt.currency_conversion_rate,
               rt.currency_conversion_date, rt.shipment_header_id,
               rt.shipment_line_id, rsl.category_id, rt.vendor_id,
               rt.vendor_site_id, rt.customer_id, rt.customer_site_id,
               rt.po_unit_price, rt.movement_id, rt.po_line_id,
               rt.po_line_location_id, rt.deliver_to_person_id,
               rt.deliver_to_location_id, rt.po_distribution_id,
               rt.locator_id, rsl.item_description, rt.subinventory,
               rt.reason_id, rt.transfer_lpn_id, rt.lpn_id
          FROM rcv_transactions rt,
               rcv_shipment_lines rsl,
               rcv_shipment_headers rsh
         WHERE rt.transaction_id = v_parent_trx_id
           AND rt.shipment_line_id = rsl.shipment_line_id
           AND rt.shipment_header_id = rsh.shipment_header_id
           AND (   (    (   (rt.transaction_type IN
                                ('RECEIVE',
                                 'TRANSFER',
                                 'ACCEPT',
                                 'REJECT',
                                 'MATCH'
                                )
                            )
                         OR (    rt.transaction_type = 'UNORDERED'
                             AND NOT EXISTS (
                                    SELECT 'PROCESSED MATCH ROWS'
                                      FROM rcv_transactions rt2
                                     WHERE rt2.parent_transaction_id =
                                                             rt.transaction_id
                                       AND rt2.transaction_type = 'MATCH')
                             AND NOT EXISTS (
                                    SELECT 'UNPROCESSED MATCH ROWS'
                                      FROM rcv_transactions_interface rti
                                     WHERE rti.parent_transaction_id =
                                                             rt.transaction_id
                                       AND rti.transaction_type = 'MATCH')
                            )
                        )
                    AND EXISTS (
                           SELECT 'POSTIVE RCV SUPPLY'
                             FROM rcv_supply rs
                            WHERE rs.rcv_transaction_id = rt.transaction_id
                              AND rs.to_org_primary_quantity >
                                     (SELECT NVL (SUM (rti.primary_quantity),
                                                  0
                                                 )
                                        FROM rcv_transactions_interface rti
                                       WHERE rti.parent_transaction_id =
                                                             rt.transaction_id
                                         AND rti.transaction_status_code =
                                                                     'PENDING'))
                   )
                OR (    rt.transaction_type = 'DELIVER'
                    AND rt.source_document_code <> 'RMA'
                   )
               )
           AND rt.source_document_code IN ('PO', 'RMA')
      ORDER BY rt.transaction_id;

   CURSOR default_return_rti (v_parent_inter_trx_id NUMBER)
   IS
      SELECT rti.po_revision_num, rti.primary_unit_of_measure,
             rti.po_header_id, rti.po_release_id, rti.location_id,
             rti.to_organization_id OID, rti.receipt_source_code,
             rti.source_document_code, rti.wip_entity_id, rti.wip_line_id,
             rti.wip_repetitive_schedule_id, rti.wip_operation_seq_num,
             rti.wip_resource_seq_num, rti.department_code,
             rti.bom_resource_id, rti.oe_order_header_id,
             rti.oe_order_line_id, rti.destination_context,
             rti.inspection_status_code, rti.currency_code,
             rti.currency_conversion_rate, rti.currency_conversion_type,
             rti.currency_conversion_date, rti.shipment_header_id,
             rti.shipment_line_id, rti.category_id, rti.vendor_id,
             rti.vendor_site_id, rti.customer_id, rti.customer_site_id,
             rti.po_unit_price, rti.movement_id, rti.po_line_id,
             rti.po_line_location_id, rti.deliver_to_person_id,
             rti.deliver_to_location_id, rti.po_distribution_id,
             rti.locator_id, rti.item_description, rti.subinventory,
             rti.reason_id, rti.transfer_lpn_id,rti.lpn_id
        FROM rcv_transactions_interface rti
       WHERE interface_transaction_id = v_parent_inter_trx_id;

   PROCEDURE derive_return_line (
      x_cascaded_table      IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                     IN OUT NOCOPY   BINARY_INTEGER,
      temp_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record       IN              rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_return_line (
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN              BINARY_INTEGER
   );

   PROCEDURE derive_return_line_qty (
      x_cascaded_table      IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                     IN OUT NOCOPY   BINARY_INTEGER,
      temp_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type
   );

   PROCEDURE derive_reason_info (
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN OUT NOCOPY   BINARY_INTEGER
   );

   PROCEDURE derive_ship_to_org_info (
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN OUT NOCOPY   BINARY_INTEGER,
      x_header_record    IN              rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_common_lines (
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN              BINARY_INTEGER
   );

   PROCEDURE default_po_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_shipment_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_wip_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_oe_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_currency_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_vendor_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_customer_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_deliver_to_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_source_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_item_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_destination_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_location_info (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_movement_id (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

   PROCEDURE default_bom_resource_id (
      x_cascaded_table     IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                    IN              BINARY_INTEGER,
      default_return_rec   IN              default_return%ROWTYPE
   );

PROCEDURE derive_inv_qty (
x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
n                  IN              BINARY_INTEGER
);

PROCEDURE derive_inv_qty_1(
p_destination_type_code IN rcv_transactions_interface.destination_type_code%type,
p_transaction_type IN rcv_transactions_interface.transaction_type%type,
p_quantity IN rcv_transactions_interface.quantity%type,
p_interface_transaction_id IN rcv_transactions_interface.interface_transaction_id%type,
p_to_organization_id IN rcv_transactions_interface.to_organization_id%type,
p_item_id IN rcv_transactions_interface.item_id%type,
p_item_revision IN rcv_transactions_interface.item_revision%type,
p_receipt_source_code IN rcv_transactions_interface.receipt_source_code%type,
p_po_header_id IN rcv_transactions_interface.po_header_id%type,
p_unit_of_measure IN rcv_transactions_interface.unit_of_measure%type,
p_primary_unit_of_measure IN rcv_transactions_interface.primary_unit_of_measure%type,
p_subinventory IN rcv_transactions_interface.subinventory%type,
p_locator_id IN rcv_transactions_interface.locator_id%type,
p_transfer_lpn_id IN rcv_transactions_interface.transfer_lpn_id%type,
p_lpn_id IN rcv_transactions_interface.lpn_id%type,
x_error_status IN OUT NOCOPY VARCHAR2,
x_error_message IN OUT NOCOPY VARCHAR2
);

END RCV_ROI_RETURN;

 

/
