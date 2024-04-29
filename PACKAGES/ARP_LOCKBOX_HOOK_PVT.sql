--------------------------------------------------------
--  DDL for Package ARP_LOCKBOX_HOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_LOCKBOX_HOOK_PVT" AUTHID CURRENT_USER AS
/*$Header: ARRLBHPS.pls 120.4.12010000.4 2008/08/07 05:32:45 aghoraka ship $*/
--
	TYPE invoice_record IS RECORD
	(
		matching_number		ar_payments_interface_all.INVOICE1%TYPE,
		item_number		ar_payments_interface_all.ITEM_NUMBER%TYPE,
		invoice_number		ar_payments_interface_all.INVOICE1%TYPE,
		amount_applied		ar_payments_interface_all.AMOUNT_APPLIED1%TYPE,
		/* Added For Cross Currency Changes */
		amount_applied_from ar_payments_interface_all.AMOUNT_APPLIED_FROM1%TYPE,
		trans_to_receipt_rate ar_payments_interface_all.TRANS_TO_RECEIPT_RATE1%TYPE,
		invoice_currency_code ar_payments_interface_all.INVOICE_CURRENCY_CODE1%TYPE,
		batch_name ar_payments_interface_all.BATCH_NAME%TYPE,
		record_type   ar_payments_interface_all.RECORD_TYPE%TYPE
	) ;
	TYPE invoice_array IS TABLE OF invoice_record INDEX BY BINARY_INTEGER ;
--
	TYPE line_record IS RECORD
	(
	       item_number		ar_payments_interface_all.ITEM_NUMBER%TYPE,
		invoice_number		ar_payments_interface_all.INVOICE1%TYPE,
		batch_name              ar_payments_interface_all.BATCH_NAME%TYPE,
		apply_to		varchar2(150),
		amount_applied		number,
		allocated_receipt_amount number,
		line_amount		number,
		tax_amount		number,
		freight			number,
		charges			number
	) ;
	TYPE line_array IS TABLE OF line_record INDEX BY BINARY_INTEGER ;
--
PROCEDURE proc_before_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2);
--
PROCEDURE proc_after_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2);
--
PROCEDURE proc_after_second_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2);
--
PROCEDURE proc_for_custom_llca(in_trans_req_id IN NUMBER);
--
END arp_lockbox_hook_pvt;

/
