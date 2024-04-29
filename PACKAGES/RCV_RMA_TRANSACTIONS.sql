--------------------------------------------------------
--  DDL for Package RCV_RMA_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_RMA_TRANSACTIONS" 
/* $Header: RCVRMATS.pls 120.0.12000000.1 2007/01/16 23:31:12 appldev ship $*/
AUTHID CURRENT_USER AS
   PROCEDURE derive_rma_line(
      x_cascaded_table      IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                     IN OUT NOCOPY   BINARY_INTEGER,
      temp_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record       IN              rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE derive_rma_trans_del(
      x_cascaded_table      IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                     IN OUT NOCOPY   BINARY_INTEGER,
      temp_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record       IN              rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE derive_rma_correction_line(
      x_cascaded_table      IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                     IN OUT NOCOPY   BINARY_INTEGER,
      temp_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record       IN              rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_rma_line(
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN              BINARY_INTEGER,
      x_header_id        IN              rcv_headers_interface.header_interface_id%TYPE,
      x_header_record    IN              rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE validate_rma_line(
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN              BINARY_INTEGER,
      x_header_record    IN              rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE get_location_id(
      x_location_id_record   IN OUT NOCOPY   rcv_shipment_object_sv.location_id_record_type
   );

   PROCEDURE get_locator_id(
      x_locator_id_record   IN OUT NOCOPY   rcv_shipment_line_sv.locator_id_record_type
   );

   PROCEDURE get_routing_header_id(
      x_routing_header_id_record   IN OUT NOCOPY   rcv_shipment_line_sv.routing_header_id_rec_type
   );

   PROCEDURE get_routing_step_id(
      x_routing_step_id_record   IN OUT NOCOPY   rcv_shipment_line_sv.routing_step_id_rec_type
   );

   PROCEDURE get_reason_id(
      x_reason_id_record   IN OUT NOCOPY   rcv_shipment_line_sv.reason_id_record_type
   );

   PROCEDURE default_item_revision(
      x_item_revision_record   IN OUT NOCOPY   rcv_shipment_line_sv.item_id_record_type
   );

PROCEDURE validate_item_revision(
      x_item_revision_record   IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type
   );

   PROCEDURE check_date_tolerance(
      expected_receipt_date         IN              DATE,
      promised_date                 IN              DATE,
      days_early_receipt_allowed    IN              NUMBER,
      days_late_receipt_allowed     IN              NUMBER,
      receipt_days_exception_code   IN OUT NOCOPY   VARCHAR2
   );

   FUNCTION convert_into_correct_qty(
      source_qty   IN   NUMBER,
      source_uom   IN   VARCHAR2,
      item_id      IN   NUMBER,
      dest_uom     IN   VARCHAR2
   )
      RETURN NUMBER;

   PROCEDURE get_item_id(
      x_item_id_record   IN OUT NOCOPY   rcv_shipment_line_sv.item_id_record_type
   );

-- API call done by EDI to obtain the org_id
   PROCEDURE get_org_id_from_hr_loc_id(
      p_hr_location_id    IN              NUMBER,
      x_organization_id   OUT NOCOPY      NUMBER
   );
END RCV_RMA_TRANSACTIONS;

 

/
