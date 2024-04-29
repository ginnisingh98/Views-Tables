--------------------------------------------------------
--  DDL for Package POA_EDW_SUPPERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_SUPPERF" AUTHID CURRENT_USER AS
/* $Header: poaspwhs.pls 115.6 2003/12/09 11:54:54 bthammin ship $ */


  FUNCTION get_first_receipt_date(
			p_line_location_id	NUMBER)	    RETURN DATE;

  FUNCTION get_last_rcv_trx_date(
			p_line_location_id	NUMBER)	    RETURN DATE;

  FUNCTION get_qty_shipped(
			p_line_location_id	NUMBER,
			p_shipment_uom		VARCHAR2)   RETURN NUMBER;

  FUNCTION get_qty_delivered(
			p_line_location_id	NUMBER)	    RETURN NUMBER;

  FUNCTION get_qty_received(
			p_type			VARCHAR2,
			p_line_location_id	NUMBER,
			p_expected_date		DATE,
			p_days_early_allowed	NUMBER,
			p_days_late_allowed	NUMBER)	    RETURN NUMBER;

  FUNCTION get_qty_pastdue(
			p_line_location_id	NUMBER,
			p_expected_date		DATE,
		  	p_days_late_allowed	NUMBER)	    RETURN NUMBER;

  FUNCTION get_num_receipts(
			p_type			VARCHAR2,
			p_line_location_id	NUMBER,
			p_expected_date		DATE,
			p_days_early_allowed	NUMBER,
			p_days_late_allowed	NUMBER)	    RETURN NUMBER;

  FUNCTION find_best_price(
			p_line_location_id	NUMBER)     RETURN NUMBER;

  FUNCTION get_rcv_txn_qty(
			p_line_location_id  	NUMBER,
  			p_txn_type          	VARCHAR2)   RETURN NUMBER;

  FUNCTION get_invoice_date(
			p_line_location_id	NUMBER)	RETURN DATE;

  FUNCTION get_days_to_invoice(
			p_line_location_id	NUMBER) RETURN NUMBER;

  FUNCTION get_ipv (
			p_line_location_id	NUMBER) RETURN NUMBER;


  PRAGMA RESTRICT_REFERENCES(get_first_receipt_date, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_last_rcv_trx_date, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_qty_shipped, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_qty_delivered, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_qty_received, WNDS);
  PRAGMA RESTRICT_REFERENCES(get_qty_pastdue, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_num_receipts, WNDS);
  PRAGMA RESTRICT_REFERENCES(find_best_price, WNDS);
  PRAGMA RESTRICT_REFERENCES(get_rcv_txn_qty, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_invoice_date, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_days_to_invoice, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_ipv, WNDS, WNPS, RNPS);

END poa_edw_supperf;

 

/
