--------------------------------------------------------
--  DDL for Package RCV_TRANSACTION_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRANSACTION_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: RCVGTPS.pls 120.0.12010000.1 2008/07/24 14:35:40 appldev ship $ */

	FUNCTION conc_request_id
		RETURN NUMBER;

	FUNCTION conc_login_id
		RETURN NUMBER;

	FUNCTION conc_program_id
		RETURN NUMBER;

	FUNCTION prog_appl_id
		RETURN NUMBER;

	FUNCTION user_id
		RETURN NUMBER;

	PROCEDURE RVTTHIns
		( p_rti_id IN RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE
		, p_transaction_type IN RCV_TRANSACTIONS.transaction_type%TYPE
		, p_shipment_header_id IN RCV_SHIPMENT_HEADERS.shipment_header_id%TYPE
		, p_shipment_line_id IN RCV_SHIPMENT_LINES.shipment_line_id%TYPE
		, p_primary_unit_of_measure IN RCV_TRANSACTIONS.primary_unit_of_measure%TYPE
		, p_primary_quantity IN RCV_TRANSACTIONS.primary_quantity%TYPE
		, p_source_doc_unit_of_measure IN RCV_TRANSACTIONS.source_doc_unit_of_measure%TYPE
		, p_source_doc_quantity IN RCV_TRANSACTIONS.source_doc_quantity%TYPE
		, p_parent_id IN RCV_TRANSACTIONS.transaction_id%TYPE
		, p_receive_id IN OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, p_deliver_id IN OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, p_correct_id IN OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, p_return_id IN OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, x_rt_id OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, x_error_message OUT NOCOPY VARCHAR2
		);

END RCV_TRANSACTION_PROCESSOR;

/
