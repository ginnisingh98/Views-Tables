--------------------------------------------------------
--  DDL for Package POA_SUPPERF_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SUPPERF_API_PKG" AUTHID CURRENT_USER AS
/* $Header: POASPAPS.pls 115.4 2003/01/09 23:25:46 rvickrey ship $*/

   FUNCTION get_receipt_date(p_line_location_id NUMBER) RETURN DATE;

   FUNCTION get_avg_price(p_line_location_id NUMBER,
                          p_price_override   NUMBER) RETURN NUMBER;

   FUNCTION get_primary_avg_price(p_line_location_id NUMBER,
                                  p_price_override   NUMBER,
                                  p_item_id          NUMBER,
                                  p_organization_id  NUMBER,
                                  p_uom              VARCHAR2)
	RETURN NUMBER;

   FUNCTION get_num_receipts(p_line_location_id NUMBER) RETURN NUMBER;

   FUNCTION get_primary_uom(p_item_id NUMBER,
                            p_organization_id NUMBER)	RETURN VARCHAR2;

   FUNCTION get_primary_quantity(p_quantity        NUMBER,
                                 p_item_id         NUMBER,
                                 p_organization_id NUMBER,
                                 p_uom             VARCHAR2)	RETURN NUMBER;

   FUNCTION get_quantity_purchased(p_quantity_ordered   NUMBER,
                                   p_quantity_billed    NUMBER,
                                   p_quantity_cancelled NUMBER,
                                   p_quantity_received  NUMBER,
                                   p_cancel_flag        VARCHAR2,
                                   p_closed_code        VARCHAR2)
	RETURN NUMBER;

   FUNCTION get_total_amount(p_line_location_id NUMBER,
                             p_cancel_flag      VARCHAR2,
                             p_closed_code      VARCHAR2,
                             p_price            NUMBER)	    RETURN NUMBER;

   FUNCTION get_quantity_late(p_line_location_id  NUMBER,
                              p_expected_date     DATE,
                              p_days_late_allowed NUMBER)   RETURN NUMBER;

   FUNCTION get_quantity_early(p_line_location_id  NUMBER,
                               p_expected_date      DATE,
                               p_days_early_allowed NUMBER)  RETURN NUMBER;

   FUNCTION get_quantity_past_due(p_quantity_ordered  NUMBER,
                                  p_quantity_received NUMBER,
				  p_expected_date     DATE,
				  p_days_late_allowed NUMBER)	RETURN NUMBER;

   FUNCTION get_suppliers(p_order_by NUMBER,
                          p_item NUMBER,
                          p_fdate DATE,
                          p_tdate DATE,
                          p_number_of_suppliers NUMBER)	    RETURN VARCHAR2;

   FUNCTION get_last_trx_date(p_line_location_id NUMBER)    RETURN DATE;

   FUNCTION get_rcv_txn_qty(p_line_location_id  NUMBER,
                            p_txn_type          VARCHAR2)	RETURN NUMBER;


   -- Pragmas

   PRAGMA RESTRICT_REFERENCES(get_last_trx_date, WNDS, WNPS, RNPS);

END POA_SUPPERF_API_PKG;

 

/
