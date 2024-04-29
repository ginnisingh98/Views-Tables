--------------------------------------------------------
--  DDL for Package PON_SUPPLIER_RESEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_SUPPLIER_RESEARCH_PVT" AUTHID CURRENT_USER AS
-- $Header: PONSUPRS.pls 120.0 2005/06/01 18:33:39 appldev noship $

	-- To return the total Invited negotiations for a given supplier.
	-- Called for the Supplier Search page results table region VOImpl.
	-- Also called by get_total_txn_history for Supplier Details page Transaction History region info.
	 FUNCTION get_total_invited_negotiations (p_tp_id IN PLS_INTEGER,
	                                          p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL )
	 RETURN PLS_INTEGER;

	 -- To return the total Awarded bids for a given supplier.
	-- Called for the Supplier Search page results table region VOImpl.
	-- Also called by get_total_txn_history for Supplier Details page Transaction History region info.
	 FUNCTION get_total_awarded_bids (p_tp_id IN PLS_INTEGER,
	                                   p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL )
	 RETURN PLS_INTEGER;

	 -- To return the total purchase order documents for a given supplier.
	 -- This total includes SPO, BPA, CPA and Purchase Order Releases.
	-- Called for the Supplier Search page results table region VOImpl.
	 FUNCTION get_total_po_documents (p_tp_id IN PLS_INTEGER,
	                                  p_vendor_id IN PLS_INTEGER)
	 RETURN PLS_INTEGER;

	-- To return the total Sourcing and Purchasing related totals a given supplier.
	-- Called for the Supplier Details page Transaction History region.
	 PROCEDURE get_total_txn_history (p_tp_id IN PLS_INTEGER,
	                                  p_vendor_id IN PLS_INTEGER,
	                                x_total_invited                    OUT NOCOPY PLS_INTEGER,
	                                x_total_invited_responses  OUT NOCOPY PLS_INTEGER,
	                                x_total_other_responses    OUT NOCOPY PLS_INTEGER,
	                                x_total_awarded                OUT NOCOPY PLS_INTEGER,
	                                x_total_spo                        OUT NOCOPY PLS_INTEGER,
	                                x_total_bpa                        OUT NOCOPY PLS_INTEGER,
	                                x_total_cpa                        OUT NOCOPY PLS_INTEGER,
	                                x_total_po_releases          OUT NOCOPY PLS_INTEGER  );

END pon_supplier_research_pvt;

 

/
