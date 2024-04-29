--------------------------------------------------------
--  DDL for Package RCV_ROI_HEADER_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ROI_HEADER_COMMON" 
/* $Header: RCVOIHCS.pls 120.0.12010000.2 2008/10/09 19:22:11 vthevark ship $ */
AUTHID CURRENT_USER AS
Type common_default_record_type is RECORD
(destination_type_code rcv_transactions_interface.destination_type_code%type,
 transaction_type rcv_transactions_interface.transaction_type%type,
 processing_mode_code rcv_transactions_interface.processing_mode_code%type,
 processing_status_code rcv_transactions_interface.processing_status_code%type,
 transaction_status_code rcv_transactions_interface.transaction_status_code%type,
 auto_transact_code rcv_transactions_interface.auto_transact_code%type
);
PROCEDURE derive_ship_to_org_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE derive_from_org_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE derive_location_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE derive_payment_terms_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE derive_receiver_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE derive_shipment_header_id(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE derive_uom_info(x_cascaded_table	IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,n IN binary_integer);


PROCEDURE default_last_update_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE default_creation_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE default_asn_type(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE default_shipment_header_id(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE default_receipt_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE default_ship_to_location_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE default_ship_from_loc_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);


PROCEDURE validate_trx_type(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_shipment_date(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_expected_receipt_date(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_receipt_num(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_ship_to_org_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_from_org_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_location_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_payment_terms_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_receiver_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE validate_freight_carrier_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE derive_ship_to_org_from_rti(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE genReceiptNum(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
PROCEDURE commonDefaultCode(p_trx_record IN OUT NOCOPY RCV_ROI_HEADER_COMMON.common_default_record_type);
PROCEDURE validate_item(x_cascaded_table	IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,n IN binary_integer);
PROCEDURE validate_substitute_item(x_cascaded_table	IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,n IN binary_integer);
PROCEDURE validate_item_revision(x_cascaded_table	IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,n IN binary_integer);
PROCEDURE validate_ship_from_loc_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);
/* lcm changes */
PROCEDURE validate_lcm_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

END RCV_ROI_HEADER_COMMON;

/
