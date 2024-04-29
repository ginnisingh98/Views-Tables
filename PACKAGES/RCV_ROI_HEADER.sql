--------------------------------------------------------
--  DDL for Package RCV_ROI_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ROI_HEADER" AUTHID CURRENT_USER as
/* $Header: RCVPREHS.pls 120.1.12010000.2 2013/12/17 04:09:22 honwei ship $*/

g_txn_against_asn          VARCHAR2(1)  := 'N';--Add to receipt 17962808, change default value to 'N'

PROCEDURE process_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE process_vendor_header(p_header_record IN OUT NOCOPY
				rcv_roi_preprocessor.header_rec_type);

PROCEDURE process_customer_header(p_header_record IN OUT NOCOPY
				rcv_roi_preprocessor.header_rec_type);

PROCEDURE process_internal_header(p_header_record IN OUT NOCOPY
				rcv_roi_preprocessor.header_rec_type);

PROCEDURE insert_cancelled_asn_lines(p_header_record IN OUT NOCOPY
				rcv_roi_preprocessor.header_rec_type);

PROCEDURE process_internal_order_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_vendor_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_vendor_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_vendor_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_customer_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_customer_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_customer_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_internal_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_internal_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_internal_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_internal_order_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_internal_order_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_internal_order_header(p_header_record IN OUT NOCOPY
rcv_roi_preprocessor.header_rec_type);

PROCEDURE process_cancellation(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_vendor_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_vendor_site_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_payment_terms_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_shipment_header_id(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_shipment_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_shipment_num(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_vendor_site_id(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_shipment_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_document_type(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_currency_code(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_receipt_date(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_vendor_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_vendor_site_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_asbn_specific_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_shipment_number(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE insert_shipment_header(p_header_record in out NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE update_shipment_header(p_header_record in out NOCOPY rcv_roi_preprocessor.header_rec_type);

END RCV_ROI_HEADER;

/
