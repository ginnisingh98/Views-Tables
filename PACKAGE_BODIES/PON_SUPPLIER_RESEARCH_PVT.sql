--------------------------------------------------------
--  DDL for Package Body PON_SUPPLIER_RESEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_SUPPLIER_RESEARCH_PVT" AS
-- $Header: PONSUPRB.pls 120.1 2005/07/27 09:05:40 rpatel noship $

	-- To return the Transaction History time period profile option value.
	-- This profile option value is used in time bound Transaction History aggregates.
	-- The profile option is updateable at all levels, and the current default is 6 months.
	 FUNCTION get_txn_history_range_profile
	 RETURN PLS_INTEGER IS
	    l_txn_history_range_in_months PLS_INTEGER ;
	  BEGIN
	        -- Fetch the profile value for data range in months.
	        l_txn_history_range_in_months := fnd_profile.value('PON_SUPP_TXN_HIST_RANGE');

	       IF (l_txn_history_range_in_months IS NULL) THEN
	                -- Set the default value for the Transaction History data.
	                l_txn_history_range_in_months:= 6;
	       END IF;

	       RETURN l_txn_history_range_in_months;

	 EXCEPTION
	      WHEN OTHERS THEN
	                 l_txn_history_range_in_months:= 6;
	                 RAISE;
	 END;

     -- To return the total Invited negotiations for a given supplier.
     --  Suppliers who  have been invited atleast once on a Negotiation.
	 FUNCTION get_total_invited_negotiations (p_tp_id IN PLS_INTEGER,
	                                  p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL )
	 RETURN PLS_INTEGER IS
	  l_tot_inv  PLS_INTEGER := 0;
	 l_txn_history_range_in_months PLS_INTEGER ;
	  BEGIN

	           IF (p_txn_history_range_in_months IS NULL) THEN
	                 -- Fetch the profile value for data range in months.
	                 l_txn_history_range_in_months := get_txn_history_range_profile;
	           ELSE
	                 l_txn_history_range_in_months := p_txn_history_range_in_months;
	           END IF;

	       -- Fetch the total invited negotiations
	       -- The negotiations that have an auction status as 'Amended'  are not to be counted.
		   SELECT COUNT(DISTINCT pbp.auction_header_id ) total_invited
		   INTO   l_tot_inv
		   FROM   pon_bidding_parties pbp,
	                  pon_auction_headers pah
		   WHERE  pbp.list_id = -1
		   AND    pbp.trading_partner_id = p_tp_id
		   AND    pah.auction_header_id = pbp.auction_header_id
		   AND    pah.auction_status IN ('ACTIVE', 'AUCTION_CLOSED')
		   AND    NVL(pah.is_template_flag, 'N') = 'N'
	       AND    pah.creation_date >= ADD_MONTHS( TRUNC(SYSDATE) ,-(l_txn_history_range_in_months));

	   RETURN l_tot_inv;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	          l_tot_inv := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;

	 -- To return the total Invited responses to negotiations for a given supplier.
	 --  Suppliers who  have responded atleast once.
	 FUNCTION get_total_invited_responses (p_tp_id IN PLS_INTEGER,
	                     p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL )
	 RETURN PLS_INTEGER IS
	  l_tot_inv  PLS_INTEGER := 0;
	  l_txn_history_range_in_months PLS_INTEGER ;
	  BEGIN

	           IF (p_txn_history_range_in_months IS NULL) THEN
	                 -- Fetch the profile value for data range in months.
	                 l_txn_history_range_in_months := get_txn_history_range_profile;
	           ELSE
	                 l_txn_history_range_in_months := p_txn_history_range_in_months;
	           END IF;

	     -- Fetch the total invited responses to the negotiations
		 -- i.e. The Supplier was been invited, and has atleast one response.
		SELECT COUNT( DISTINCT(pbh.auction_header_id)) total_invited
		INTO   l_tot_inv
		FROM   pon_bid_headers pbh,
		       pon_auction_headers pah,
	           pon_bidding_parties pbp
	     WHERE pbh.trading_partner_id =  p_tp_id
	      AND  pbh. bid_status IN ('ACTIVE')
	      AND  pah.auction_header_id = pbh.auction_header_id
	      AND  pah.auction_status IN ('ACTIVE', 'AUCTION_CLOSED')
	      AND  NVL(pah.is_template_flag, 'N') = 'N'
	      AND  pbh.auction_header_id = pbp.auction_header_id
	      AND  pbh.trading_partner_id = pbp.trading_partner_id
	      AND  pbp.list_id = -1
	      AND  pbh.creation_date >= ADD_MONTHS(TRUNC(SYSDATE),  -(l_txn_history_range_in_months));

	   RETURN l_tot_inv;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	           l_tot_inv := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;

	-- To return the total Un-Invited responses to the negotiations for a given supplier.
	FUNCTION get_total_uninvited_responses (p_tp_id IN PLS_INTEGER,
	                               p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL )
	 RETURN PLS_INTEGER IS
	  l_tot_uninv  PLS_INTEGER := 0;
	  l_txn_history_range_in_months PLS_INTEGER ;
	  BEGIN

	           IF (p_txn_history_range_in_months IS NULL) THEN
	                 -- Fetch the profile value for data range in months.
	                 l_txn_history_range_in_months := get_txn_history_range_profile;
	           ELSE
	                 l_txn_history_range_in_months := p_txn_history_range_in_months;
	           END IF;

		   -- Fetch the total un-invited responses to the negotiations
		  -- i.e. The Supplier was not invited, but has atleast one response.
		 SELECT COUNT( DISTINCT(pbh.auction_header_id)) total_uninvited
		 INTO      l_tot_uninv
		FROM    pon_bid_headers pbh,
		               pon_auction_headers pah
	     WHERE   pbh.trading_partner_id =  p_tp_id
	       AND      bid_status IN ('ACTIVE')
	       AND      pah.auction_header_id = pbh.auction_header_id
	      AND      pah.auction_status IN ('ACTIVE', 'AUCTION_CLOSED')
	      AND     NVL(pah.is_template_flag, 'N') = 'N'
	      AND      pbh.auction_header_id NOT IN       -- invited parties list
		                ( SELECT  pbp.auction_header_id
		                  FROM     pon_bidding_parties pbp
	                        WHERE   pbh.trading_partner_id = pbp.trading_partner_id
			  AND        pbp.list_id = -1)
	      AND    pbh.creation_date >= ADD_MONTHS(TRUNC(SYSDATE), -(l_txn_history_range_in_months));

	   RETURN l_tot_uninv;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	           l_tot_uninv := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;

	 -- To return the total Awarded bids for a given supplier.
	 FUNCTION get_total_awarded_bids (p_tp_id IN PLS_INTEGER,
	                             p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL )
	 RETURN PLS_INTEGER IS
	  l_tot_awd  PLS_INTEGER := 0;
	 l_txn_history_range_in_months PLS_INTEGER ;
	  BEGIN

	           IF (p_txn_history_range_in_months IS NULL) THEN
	                 -- Fetch the profile value for data range in months.
	                 l_txn_history_range_in_months := get_txn_history_range_profile;
	           ELSE
	                 l_txn_history_range_in_months := p_txn_history_range_in_months;
	           END IF;

	     -- Fetch the total awarded bids
	    -- Count the Negotiations that have atleast one bid got awarded/partially awarded.
	     SELECT COUNT(DISTINCT pbh.auction_header_id) total_awarded
	     INTO      l_tot_awd
	     FROM   pon_bid_headers pbh,
		            pon_auction_headers pah
	     WHERE  pbh.trading_partner_id = p_tp_id
	     AND    pah.auction_header_id = pbh.auction_header_id
	     AND    pah.auction_status IN ('ACTIVE', 'AUCTION_CLOSED')
	     AND     NVL(pah.is_template_flag, 'N') = 'N'
	     AND    NVL(pbh.award_status,'NA') IN ('AWARDED', 'PARTIAL')
	     AND    bid_status IN ('ACTIVE')
	    AND     pbh.creation_date >= ADD_MONTHS(TRUNC(SYSDATE), -(l_txn_history_range_in_months));

	   RETURN l_tot_awd;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	          l_tot_awd := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;

    -- To return the total purchase order SPO,BPA, CPA for a given supplier.
	-- The status of type Incomplete or In-Process or Awating Approval are not counted.
	-- Not counting the PPOs for the totals that are shown against a given supplier.
	PROCEDURE get_total_po_orders (p_tp_id IN PLS_INTEGER,
	                                p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL,
	                                x_total_spo OUT NOCOPY PLS_INTEGER,
	                                x_total_bpa OUT NOCOPY PLS_INTEGER,
	                                x_total_cpa OUT NOCOPY PLS_INTEGER  )
	 IS
	  l_total_spo  PLS_INTEGER := 0;
	  l_total_bpa  PLS_INTEGER := 0;
	  l_total_cpa  PLS_INTEGER := 0;
	 l_txn_history_range_in_months PLS_INTEGER ;
	  BEGIN

	           IF (p_txn_history_range_in_months IS NULL) THEN
	                 -- Fetch the profile value for data range in months.
	                 l_txn_history_range_in_months := get_txn_history_range_profile;
	           ELSE
	                 l_txn_history_range_in_months := p_txn_history_range_in_months;
	           END IF;

	      -- Fetch the po document totals
	      SELECT  SUM(DECODE(type_lookup_code, 'STANDARD', 1,0)) total_spo,
		          SUM(DECODE(type_lookup_code, 'BLANKET', 1,0)) total_bpa,
	              SUM(DECODE(type_lookup_code, 'CONTRACT', 1,0)) total_cpa
	      INTO    l_total_spo,
		           l_total_bpa,
		           l_total_cpa
	      FROM    po_vendors pv,
	              hz_parties hp,
	              po_headers poh
	      WHERE   hp.party_id = p_tp_id
	      AND     poh.vendor_id    = pv.vendor_id
	      AND     poh.authorization_status NOT IN
		                 ( 'IN PROCESS','INCOMPLETE','REQUIRES REAPPROVAL')
	      AND     pv.party_id     =  hp.party_id
	      AND     poh.creation_date >= ADD_MONTHS(TRUNC(SYSDATE), -(l_txn_history_range_in_months));

	      -- populate the return variables.
	      x_total_spo :=  l_total_spo;
	      x_total_bpa := l_total_bpa;
	      x_total_cpa := l_total_cpa;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	            x_total_spo :=  0;
	            x_total_bpa := 0;
	            x_total_cpa := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;

    -- To return the total purchase order SPO,BPA, CPA for a given vendor_id.
    -- For some of the supplier search results based rows, there is no hz_party entry
    -- until invited, for such supplier, getting details from PO is done by the vendor_id.
	-- The status of type Incomplete or In-Process or Awating Approval are not counted.
	-- Not counting the PPOs for the totals that are shown against a given supplier.
	PROCEDURE get_total_po_orders_vendor_id (p_vendor_id IN PLS_INTEGER,
	                                p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL,
	                                x_total_spo OUT NOCOPY PLS_INTEGER,
	                                x_total_bpa OUT NOCOPY PLS_INTEGER,
	                                x_total_cpa OUT NOCOPY PLS_INTEGER  )
	 IS
	  l_total_spo  PLS_INTEGER := 0;
	  l_total_bpa  PLS_INTEGER := 0;
	  l_total_cpa  PLS_INTEGER := 0;
	 l_txn_history_range_in_months PLS_INTEGER ;
	  BEGIN

	           IF (p_txn_history_range_in_months IS NULL) THEN
	                 -- Fetch the profile value for data range in months.
	                 l_txn_history_range_in_months := get_txn_history_range_profile;
	           ELSE
	                 l_txn_history_range_in_months := p_txn_history_range_in_months;
	           END IF;

	      -- Fetch the po document totals
	      SELECT  SUM(DECODE(type_lookup_code, 'STANDARD', 1,0)) total_spo,
		          SUM(DECODE(type_lookup_code, 'BLANKET', 1,0)) total_bpa,
	              SUM(DECODE(type_lookup_code, 'CONTRACT', 1,0)) total_cpa
	      INTO    l_total_spo,
		           l_total_bpa,
		           l_total_cpa
	      FROM    po_vendors pv,
	              po_headers poh
	      WHERE   pv.vendor_id = p_vendor_id
	      AND     poh.vendor_id    = pv.vendor_id
	      AND     poh.authorization_status NOT IN
		                 ( 'IN PROCESS','INCOMPLETE','REQUIRES REAPPROVAL')
	      AND     poh.creation_date >= ADD_MONTHS(TRUNC(SYSDATE), -(l_txn_history_range_in_months));

	      -- populate the return variables.
	      x_total_spo :=  l_total_spo;
	      x_total_bpa := l_total_bpa;
	      x_total_cpa := l_total_cpa;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	            x_total_spo :=  0;
	            x_total_bpa := 0;
	            x_total_cpa := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;


	 -- To return the total purchase order releases for a given supplier.
	 -- The status of type Incomplete or In-Process or Awating Approval are not counted.
	-- To skip the release type of SCHEDULE as they are tied to uncounted PPOs.
	 FUNCTION get_total_po_releases (p_tp_id IN PLS_INTEGER,
	                       p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL)
	 RETURN PLS_INTEGER IS
	  l_tot_po_rel  PLS_INTEGER := 0;
	 l_txn_history_range_in_months PLS_INTEGER ;

	  BEGIN

	           IF (p_txn_history_range_in_months IS NULL) THEN
	                 -- Fetch the profile value for data range in months.
	                 l_txn_history_range_in_months := get_txn_history_range_profile;
	           ELSE
	                 l_txn_history_range_in_months := p_txn_history_range_in_months;
	           END IF;

	      -- Fetch the total purchasing releases
	      SELECT  COUNT(*) total_po_releases
	      INTO      l_tot_po_rel
	      FROM    po_vendors pv,
	                     hz_parties hp,
	                     po_releases_all por,
	                     po_headers  poh
	      WHERE   hp.party_id = p_tp_id
	      AND       poh.PO_HEADER_ID = por.PO_HEADER_ID
	      AND       por.release_type = 'BLANKET'
	      AND       poh.authorization_status NOT IN
		                 ( 'IN PROCESS','INCOMPLETE','REQUIRES REAPPROVAL')
	      AND      por.authorization_status NOT IN
		                 ( 'IN PROCESS','INCOMPLETE','REQUIRES REAPPROVAL')
	      AND     poh.vendor_id    = pv.vendor_id
	      AND     pv.party_id     = hp.party_id
	      AND     por.creation_date >= ADD_MONTHS(TRUNC(SYSDATE), -(l_txn_history_range_in_months));

	   RETURN l_tot_po_rel;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	          l_tot_po_rel := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;

	 -- To return the total purchase order releases for a given vendor-id.
     -- For some of the supplier search results based rows, there is no hz_party entry
     -- until invited, for such supplier, getting details from PO is done by the vendor_id.
     -- The status of type Incomplete or In-Process or Awating Approval are not counted.
	 -- To skip the release type of SCHEDULE as they are tied to uncounted PPOs.
	 FUNCTION get_total_po_rel_vendor_id (p_vendor_id IN PLS_INTEGER,
	                       p_txn_history_range_in_months IN PLS_INTEGER DEFAULT NULL)
	 RETURN PLS_INTEGER IS
     l_tot_po_rel  PLS_INTEGER := 0;
	 l_txn_history_range_in_months PLS_INTEGER ;

	  BEGIN

	           IF (p_txn_history_range_in_months IS NULL) THEN
	                 -- Fetch the profile value for data range in months.
	                 l_txn_history_range_in_months := get_txn_history_range_profile;
	           ELSE
	                 l_txn_history_range_in_months := p_txn_history_range_in_months;
	           END IF;

	      -- Fetch the total purchasing releases
	      SELECT  COUNT(*) total_po_releases
	      INTO      l_tot_po_rel
	      FROM    po_vendors pv,
                  po_releases_all por,
                  po_headers  poh
	      WHERE   pv.vendor_id = p_vendor_id
	      AND     poh.vendor_id    = pv.vendor_id
	      AND     poh.PO_HEADER_ID = por.PO_HEADER_ID
	      AND     por.release_type = 'BLANKET'
	      AND     poh.authorization_status NOT IN
		                 ( 'IN PROCESS','INCOMPLETE','REQUIRES REAPPROVAL')
	      AND     por.authorization_status NOT IN
		                 ( 'IN PROCESS','INCOMPLETE','REQUIRES REAPPROVAL')
	      AND     por.creation_date >= ADD_MONTHS(TRUNC(SYSDATE), -(l_txn_history_range_in_months));

	   RETURN l_tot_po_rel;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	          l_tot_po_rel := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;


	 -- To return the total purchase order documents for a given supplier.
	 -- This total includes SPO, BPA, CPA and Purchase Order Releases.
	 -- This will call function/procedure within this package to aggregate.
	 --  To be used to publish the totals on the Supplier Research results table columns.
	 FUNCTION get_total_po_documents (p_tp_id     IN PLS_INTEGER,
	                                  p_vendor_id IN PLS_INTEGER)
	 RETURN PLS_INTEGER IS

	  l_total_spo    PLS_INTEGER := 0;
	  l_total_bpa    PLS_INTEGER := 0;
	  l_total_cpa    PLS_INTEGER := 0;
	  l_tot_po_rel   PLS_INTEGER := 0;
	  l_tot_po_docs  PLS_INTEGER := 0;
	  l_txn_history_range_in_months PLS_INTEGER ;
	  BEGIN

       -- Fetch the profile value for data range in months.
       l_txn_history_range_in_months := get_txn_history_range_profile;


       IF (NVL( p_tp_id , -1) <> -1)
	   THEN
	        -- Trading-Partner-Id is available.
	        -- Fetch total purchase orders and agreements totals.
            get_total_po_orders(p_tp_id, l_txn_history_range_in_months ,
	                           l_total_spo, l_total_bpa, l_total_cpa ) ;

            -- Fetch total purchase agreement based releases.
	        l_tot_po_rel := get_total_po_releases(p_tp_id,
			                                 l_txn_history_range_in_months) ;
	   ELSE
  	        -- Trading-Partner-Id is available. Use Vendor-id.
	        -- Fetch total purchase orders and agreements totals.
            get_total_po_orders_vendor_id(p_vendor_id,
			                              l_txn_history_range_in_months ,
	                                      l_total_spo, l_total_bpa,
										  l_total_cpa ) ;

            -- Fetch total purchase agreement based releases.
	        l_tot_po_rel := get_total_po_rel_vendor_id(p_vendor_id,
			                                l_txn_history_range_in_months) ;
	   END IF;


	   -- Add all po documents for a final total that is published
	   -- on the supplier search page results table column.
	   l_tot_po_docs := ( l_total_spo +
	                      l_total_bpa +
	                      l_total_cpa +
		                  l_tot_po_rel  );

	   RETURN l_tot_po_docs;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	             l_tot_po_docs := 0;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;

	-- To return the total Sourcing and Purchasing related aggregates for a given supplier.
	-- This procedure returns all the Transaction History region related fields.
	-- Consolidates all the function calls for single call from the middle tier.
	-- To be called from the Supplier Details AM for a given trading_partner_id.
	--
	 PROCEDURE get_total_txn_history (p_tp_id IN PLS_INTEGER,
	                                  p_vendor_id IN PLS_INTEGER,
	                                x_total_invited                    OUT NOCOPY PLS_INTEGER,
	                                x_total_invited_responses  OUT NOCOPY PLS_INTEGER,
	                                x_total_other_responses    OUT NOCOPY PLS_INTEGER,
	                                x_total_awarded                OUT NOCOPY PLS_INTEGER,
	                                x_total_spo                        OUT NOCOPY PLS_INTEGER,
	                                x_total_bpa                        OUT NOCOPY PLS_INTEGER,
	                                x_total_cpa                        OUT NOCOPY PLS_INTEGER,
	                                x_total_po_releases          OUT NOCOPY PLS_INTEGER  )
	 IS

	-- local variables for Oracle Sourcing related  aggregates
	  l_total_invited                       PLS_INTEGER := 0;
	  l_total_invited_responses     PLS_INTEGER := 0;
	  l_total_other_responses       PLS_INTEGER := 0;
	  l_total_awarded                   PLS_INTEGER := 0;

	-- local variables for Oracle Purchasing related aggregates
	  l_total_spo                           PLS_INTEGER := 0;
	  l_total_bpa                          PLS_INTEGER := 0;
	  l_total_cpa                          PLS_INTEGER := 0;
	  l_total_po_releases            PLS_INTEGER := 0;

	  l_txn_history_range_in_months PLS_INTEGER ;

	  BEGIN

	    -- Fetch the profile value for data range in months.
	    l_txn_history_range_in_months := get_txn_history_range_profile;

	    -- Fetch total invited negotiations from pon bidding parties.
	    l_total_invited := get_total_invited_negotiations (p_tp_id,
		                                          l_txn_history_range_in_months);

	    -- Fetch  the total Invited responses to negotiations for a given supplier.
	   l_total_invited_responses := get_total_invited_responses (p_tp_id,
	                                              l_txn_history_range_in_months);

	   -- Fetch  the total Un-Invited responses to the negotiations for a given supplier.
	   l_total_other_responses  := get_total_uninvited_responses (p_tp_id,
	                                            l_txn_history_range_in_months);

	    -- Fetch the total Awarded bids for a given supplier.
	    l_total_awarded  := get_total_awarded_bids (p_tp_id, l_txn_history_range_in_months);

       IF (NVL( p_tp_id , -1) <> -1)
	   THEN
	        -- Trading-Partner-Id is available.
	        -- Fetch total purchase orders and agreements totals.
            get_total_po_orders(p_tp_id, l_txn_history_range_in_months ,
	                           l_total_spo, l_total_bpa, l_total_cpa ) ;

            -- Fetch total purchase agreement based releases.
	        l_total_po_releases := get_total_po_releases(p_tp_id,
			                                 l_txn_history_range_in_months) ;
	   ELSE
  	        -- Trading-Partner-Id is available. Use Vendor-id.
	        -- Fetch total purchase orders and agreements totals.
            get_total_po_orders_vendor_id(p_vendor_id,
			                              l_txn_history_range_in_months ,
	                                      l_total_spo, l_total_bpa,
										  l_total_cpa ) ;

            -- Fetch total purchase agreement based releases.
	        l_total_po_releases := get_total_po_rel_vendor_id(p_vendor_id,
			                                l_txn_history_range_in_months) ;
	   END IF;

	      -- populate the return variables.
	      x_total_invited              :=  l_total_invited           ;
	      x_total_invited_responses    :=  l_total_invited_responses ;
	      x_total_other_responses      :=  l_total_other_responses   ;
	      x_total_awarded              :=  l_total_awarded           ;
	      x_total_spo                  :=  l_total_spo               ;
	      x_total_bpa                  :=  l_total_bpa               ;
	      x_total_cpa                  :=  l_total_cpa               ;
	      x_total_po_releases          :=  l_total_po_releases       ;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	           -- return zero for totals,  displayed as blank on the UI.
	           x_total_invited               := 0 ;
	           x_total_invited_responses     := 0 ;
	           x_total_other_responses       := 0 ;
	           x_total_awarded               := 0 ;
	           x_total_spo                   := 0 ;
	           x_total_bpa                   := 0 ;
	           x_total_cpa                   := 0 ;
	           x_total_po_releases           := 0 ;
	      WHEN OTHERS THEN
	                 RAISE;
	 END;

END pon_supplier_research_pvt;

/
