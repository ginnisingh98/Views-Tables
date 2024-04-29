--------------------------------------------------------
--  DDL for Package AR_ECAPP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ECAPP_PKG" AUTHID CURRENT_USER AS
/*$Header: ARECAPPS.pls 120.2.12010000.1 2009/03/23 07:40:26 mpsingh noship $*/

TYPE t_cash_receipt_id	IS TABLE OF ar_cash_receipts.cash_receipt_id%TYPE
			INDEX BY BINARY_INTEGER;
TYPE t_receipt_number	IS TABLE OF ar_cash_receipts.receipt_number%TYPE
			INDEX BY BINARY_INTEGER;
TYPE t_org_id		IS TABLE OF ar_cash_receipts.org_id%TYPE
			INDEX BY BINARY_INTEGER;
TYPE t_bepcode		IS TABLE OF iby_trxn_summaries_all.bepcode%TYPE
			INDEX BY BINARY_INTEGER;
TYPE t_bepmessage	IS TABLE OF iby_trxn_summaries_all.bepmessage%TYPE
			INDEX BY BINARY_INTEGER;
TYPE t_instrtype	IS TABLE OF iby_trxn_summaries_all.instrtype%TYPE
			INDEX BY BINARY_INTEGER;
TYPE t_request_id	IS TABLE OF ar_cash_receipts.request_id%TYPE
			INDEX BY BINARY_INTEGER;

PROCEDURE correct_settlement_error ;


PROCEDURE UPDATE_STATUS(
			totalRows	IN NUMBER,
			txn_id_Tab	IN JTF_VARCHAR2_TABLE_100,
			req_type_Tab	IN JTF_VARCHAR2_TABLE_100,
			Status_Tab	IN JTF_NUMBER_TABLE,
			updatedt_Tab	IN JTF_DATE_TABLE,
			refcode_Tab	IN JTF_VARCHAR2_TABLE_100,
			o_status	OUT NOCOPY VARCHAR2,
			o_errcode	OUT NOCOPY VARCHAR2,
			o_errmsg	OUT NOCOPY VARCHAR2,
			o_statusindiv_Tab IN OUT NOCOPY JTF_VARCHAR2_TABLE_100
			);


END AR_ECAPP_PKG;

/
