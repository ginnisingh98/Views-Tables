--------------------------------------------------------
--  DDL for Package INV_MO_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MO_PURGE" AUTHID CURRENT_USER AS
/* $Header: INVMOPGS.pls 120.3.12010000.2 2008/12/31 13:31:42 ckrishna ship $ */
--Return values for x_retcode(standard for concurrent programs)

	RETCODE_SUCCESS         CONSTANT     VARCHAR2(1)  := '0';
	RETCODE_WARNING         CONSTANT     VARCHAR2(1)  := '1';
	RETCODE_ERROR           CONSTANT     VARCHAR2(1)  := '2';


-- Procedure to Purge the MObe Order lines

PROCEDURE PURGE_LINES(x_errbuf	OUT NOCOPY VARCHAR2,
		x_retcode	OUT NOCOPY NUMBER,
		p_organization_id	IN NUMBER    :=NULL,
		p_mo_type_id		IN NUMBER    :=NULL,
		p_purge_name		IN VARCHAR2  :=NULL,
		P_date_from		IN VARCHAR2  :=NULL,
		p_date_to		IN VARCHAR2  :=NULL,
		p_mol_pc		IN NUMBER    :=NULL

		) ;

--Bug #4864356
--Added new columns to the record type to avoid re-querying MOL
-- Bug 7647713 Added txn_source_id and organization_id
TYPE MOL_REC IS RECORD(
      header_id          MTL_TXN_REQUEST_HEADERS.header_id%TYPE,
      line_id            MTL_TXN_REQUEST_LINES.line_id%TYPE,
      mo_type            MTL_TXN_REQUEST_HEADERS.move_order_type%TYPE,
      line_status        MTL_TXN_REQUEST_LINES.line_status%TYPE,
      quantity           MTL_TXN_REQUEST_LINES.quantity%TYPE,
      quantity_detailed  MTL_TXN_REQUEST_LINES.quantity_detailed%TYPE,
      quantity_delivered MTL_TXN_REQUEST_LINES.quantity_delivered%TYPE,
      required_quantity  MTL_TXN_REQUEST_LINES.required_quantity%TYPE,
      txn_source_line_id MTL_TXN_REQUEST_LINES.txn_source_line_id%TYPE,
      txn_source_id      MTL_TXN_REQUEST_LINES.txn_source_id%TYPE,
      organization_id    MTL_TXN_REQUEST_LINES.organization_id%TYPE);

END INV_MO_PURGE;



/
