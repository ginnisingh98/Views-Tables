--------------------------------------------------------
--  DDL for Package FV_AP_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_AP_MATCH_PKG" AUTHID CURRENT_USER AS
-- $Header: FVAPPOMS.pls 120.0 2006/01/04 19:48:14 ksriniva noship $

procedure get_default_qty(p_line_location_id in number,
                            p_qty_ord          in number,
                            p_qty_received     in number,
                            p_qty_billed       in number,
                            p_qty_cancelled    in number,
                            p_qty_accepted     in number,
                            p_qty_outstanding  out nocopy number);
-------------------------------------------------------------------------------
-- This procedure is used to check the tolerance of a purchase order amount
-- when an invoice line amount is matched with the purchase order.
-- The tolerance percentage is defined on the Define Federal Options form.
-------------------------------------------------------------------------------
PROCEDURE shipment_tolerance(p_diff_amount IN NUMBER,
                             p_po_shipment_amount IN NUMBER,
                             p_tolerance_check_status OUT NOCOPY VARCHAR2) ;


End fv_ap_match_pkg;


 

/
