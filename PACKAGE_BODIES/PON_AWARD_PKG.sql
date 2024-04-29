--------------------------------------------------------
--  DDL for Package Body PON_AWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AWARD_PKG" as
-- $Header: PONAWRDB.pls 120.42.12010000.9 2015/08/12 09:02:36 irasoolm ship $

-- a collection that stores numbers
TYPE integerList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

g_debug_mode    CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- choli update for emd
PROCEDURE NotifyEmdAdmin(
                p_auction_header_id           NUMBER,    --  2
                p_emd_admin_name         VARCHAR2,  --  3
                p_auction_tp_name            VARCHAR2,  --  4
                p_auction_title               VARCHAR2,  --  5
                p_auction_header_id_encrypted  VARCHAR2,    --  6
                x_doc_number_dsp    PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE) IS



x_number_awarded  NUMBER;
x_number_rejected  NUMBER;
x_sequence  NUMBER;
x_itemtype  VARCHAR2(8) := 'PONAWARD';
x_itemkey  VARCHAR2(50);
x_bid_list  VARCHAR2(1);
x_progress  VARCHAR2(3);
x_bid_contact_tp_dp_name varchar2(240);
x_auction_type varchar2(30);
x_auction_type_name varchar2(30) := '';
x_event_title       varchar2(80);
x_event_id          NUMBER;
x_auction_open_bidding_date DATE;
x_auction_close_bidding_date DATE;
x_language_code VARCHAR2(3) := null;
x_timezone  VARCHAR2(80);
x_newstarttime  DATE;
x_newendtime  DATE;
x_newawardtime  DATE;
x_doctype_group_name   VARCHAR2(60);
x_msg_suffix     VARCHAR2(3) := '';

x_auction_round_number    NUMBER;
x_doctype_id_value    NUMBER;
x_oex_timezone VARCHAR2(80);
x_bidder_contact_id   NUMBER;
x_timezone_disp VARCHAR2(240);
x_bid           VARCHAR2(10);
x_bid_caps      VARCHAR2(10);
x_note_to_supplier PON_BID_HEADERS.NOTE_TO_SUPPLIER%TYPE;
x_view_quote_url_supplier VARCHAR2(2000);
x_award_date PON_AUCTION_HEADERS_ALL.AWARD_DATE%TYPE;
x_trading_partner_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
x_tp_display_name PON_BID_HEADERS.TRADING_PARTNER_NAME%TYPE;
x_tp_address_name PON_BID_HEADERS.VENDOR_SITE_CODE%TYPE;
x_preview_date             DATE;
x_preview_date_in_tz             DATE;
x_timezone1_disp                VARCHAR2(240);
x_has_items_flag                PON_AUCTION_HEADERS_ALL.HAS_ITEMS_FLAG%TYPE;
x_staggered_closing_interval    NUMBER;
x_staggered_close_note          VARCHAR2(1000);
x_bid_award_status PON_BID_HEADERS.AWARD_STATUS%TYPE;



BEGIN

      IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_award_pkg.NotifyEmdAdmin'
                      ,message   => 'Start calling NotifyEmdAdmin');
      END IF;
    x_progress := '010';

    --
    -- Get the bidder's language code so that the c1_bid_info
    -- has right value for x_language_code
    --
    IF p_emd_admin_name is not null THEN
       PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(p_emd_admin_name,x_language_code);
    END IF;

    -- Set the userenv language so the message token (attribute) values that we retrieve using the
    -- getMessage call return the message in the correct language => x_language_code


    pon_auction_pkg.SET_SESSION_LANGUAGE(null, x_language_code);

    --
    -- Get next value in sequence for itemkey
    --

    SELECT pon_auction_wf_acbid_s.nextval
    INTO   x_sequence
    FROM   dual;

    --
    -- get the contact name and auction type
    --


    x_progress := '020';



    x_itemkey := (to_char(p_emd_admin_name)||'-'||to_char(x_sequence));

    x_progress := '022';

    --
    -- Create the wf process
    --

    wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'NOTIFY_EMD_ADMIN_PROCESS');

    --
    -- Set all the item attributes
    --
    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_ID',
                                 avalue     => p_auction_header_id);
	      /* Setting the Company header attribute */
    wf_engine.SetItemAttrText(itemtype   => x_itemtype
                             ,itemkey    => x_itemkey
                             ,aname      => 'AUCTION_TP_NAME'
	                         ,avalue     => p_auction_tp_name);
     /*  wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                  aname      => 'PON_AUC_WF_AWARD_SUBJECT',
                                  avalue     => pon_auction_pkg.getMessage('PON_AUC_WF_AWARD_SUBJECT', x_msg_suffix,
                   'DOC_NUMBER', x_doc_number_dsp,
                   'AUCTION_TITLE', pon_auction_pkg.replaceHtmlChars(p_auction_title)));  */

       wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                  aname      => 'PON_AUC_WF_AWARD_SUBJECT',
                                  avalue     => 'Auction' || x_doc_number_dsp || '(' || p_auction_title || ') has been awarded');
              /* Setting the negotiation title header attribute */
    wf_engine.SetItemAttrText(itemtype   => x_itemtype
	                         ,itemkey    => x_itemkey
                             ,aname      => 'AUCTION_TITLE'
                             ,avalue     =>  pon_auction_pkg.replaceHtmlChars(p_auction_title));
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_TYPE_NAME',
                               avalue     => x_auction_type_name);

    wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'EMD_APPROVER',
                                 avalue     => p_emd_admin_name);
        -- Bug 4295915: Set the  workflow owner
    wf_engine.SetItemAttrText  (itemtype    => x_itemtype,
                             itemkey    => x_itemkey,
                             aname      => 'ORIGIN_USER_NAME',
                             avalue     => fnd_global.user_name);

    wf_engine.SetItemOwner(itemtype => x_itemtype,
                           itemkey  => x_itemkey,
                           owner    => fnd_global.user_name);


    --
    -- Start the workflow
    --

    wf_engine.StartProcess(itemtype => x_itemtype,
                           itemkey  => x_itemkey );
    pon_auction_pkg.UNSET_SESSION_LANGUAGE;

    x_progress := '029';
    IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_award_pkg.NotifyEmdAdmin'
                      ,message   => 'End calling NotifyEmdAdmin');
      END IF;

END;

PROCEDURE update_all_bid_item_prices
(
 p_bid_number     IN NUMBER,
 p_award_status   IN VARCHAR2,
 p_award_date     IN DATE,
 p_auctioneer_id  IN NUMBER
) IS

l_max_line_number      	NUMBER;
l_batch_size		NUMBER;
l_batch_start		NUMBER;
l_batch_end		NUMBER;
l_commit_flag		BOOLEAN;

BEGIN

	-- by default, we do not want to commit intermittently
	l_commit_flag := FALSE;

	-- just set award_qty same as bid_qty
        select 	nvl(max(line_number),0)
	into 	l_max_line_number
	from 	pon_bid_item_prices
        where 	bid_number = p_bid_number;

	l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;

	l_batch_start := 1;

        IF (l_max_line_number <l_batch_size) THEN
            l_batch_end := l_max_line_number;
        ELSE
	    l_commit_flag := TRUE; -- commit if we are going to loop over multiple times
            l_batch_end   := l_batch_size;
        END IF;


	WHILE (l_batch_start <= l_max_line_number) LOOP --{ main-batching-loop

		UPDATE PON_BID_ITEM_PRICES pbip
		SET
		(pbip.award_status,
		 pbip.award_quantity,
		 pbip.award_date,
		 pbip.last_update_date,
		 pbip.last_updated_by,
                 pbip.award_price,
                 pbip.award_shipment_number) =
		(
		select
			p_award_status,
		        decode (paip.group_type, 'LOT_LINE', null,
						 'GROUP',    null,
			    decode (paha.contract_type, 'BLANKET', null,
	        	      decode (paip.order_type_lookup_code, 'FIXED PRICE', 1,
                        	                         	   'AMOUNT',      1,
                                	                 	   'RATE',        1, pbip.quantity ))),
		        p_award_date,
			p_award_date,
        		p_auctioneer_id,
        		pbip.price,
                        null
		from
			pon_auction_item_prices_all paip,
			pon_auction_headers_all paha
		where  	pbip.bid_number 	= p_bid_number
		and    	pbip.auction_header_id  = paip.auction_header_id
		and     pbip.line_number 	= paip.line_number
		and     paha.auction_header_id  = pbip.auction_header_id
		)
		where
			pbip.bid_number		=  p_bid_number		  and
			pbip.line_number	>= l_batch_start 	  and
			pbip.line_number	<= l_batch_end;

           	l_batch_start := l_batch_end + 1;

           	IF (l_batch_end + l_batch_size > l_max_line_number) THEN
               		l_batch_end := l_max_line_number;
           	ELSE
               		l_batch_end := l_batch_end + l_batch_size;
           	END IF;


		IF(l_commit_flag = TRUE) THEN
			COMMIT;
		END IF;

	END LOOP; --} --end-loop

END update_all_bid_item_prices;


PROCEDURE update_all_auction_item_prices
(
  p_auction_id    IN NUMBER,
  p_bid_number    IN NUMBER,
  p_award_date	  IN DATE,
  p_auctioneer_id IN NUMBER
) IS

l_batch_size		NUMBER;
l_batch_start		NUMBER;
l_batch_end		NUMBER;
l_max_line_number      	NUMBER;
l_commit_flag		BOOLEAN;

BEGIN

	-- by default, we do not want to commit intermittently
	l_commit_flag := FALSE;

        select 	nvl(max(line_number),0)
	into 	l_max_line_number
	from 	pon_auction_item_prices_all
        where 	auction_header_id = p_auction_id;

	l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;

	l_batch_start := 1;

        IF (l_max_line_number <l_batch_size) THEN
            l_batch_end := l_max_line_number;
        ELSE
	    l_commit_flag := TRUE; -- commit if we are going to loop over multiple times
            l_batch_end   := l_batch_size;
        END IF;

	WHILE (l_batch_start <= l_max_line_number) LOOP --{ main-batching-loop

		UPDATE pon_auction_item_prices_all paip
		SET
		(paip.award_status,
		paip.awarded_quantity,
		paip.award_mode,
		paip.last_update_date,
		paip.last_updated_by) =
		(
		select
			decode (pbip.award_status, 'AWARDED', 'AWARDED', 'REJECTED', 'AWARDED', 'PARTIAL', 'AWARDED', to_char(null)),
		        decode (paip.group_type, 'LOT_LINE', null,
						 'GROUP',    null,
	        	      decode (paip.order_type_lookup_code, 'FIXED PRICE', 1,
                        	                         	   'AMOUNT',      1,
                                	                 	   'RATE',        1,
				decode (paha.contract_type, 'BLANKET', 1, 'CONTRACT', 1, pbip.quantity) ) ),
	        	g_AWARD_QUOTE,
		        p_award_date,
        		p_auctioneer_id
		from
			pon_bid_item_prices pbip,
			pon_auction_headers_all paha
		where  	pbip.bid_number 	= p_bid_number
		and    	pbip.auction_header_id  = paip.auction_header_id
		and     pbip.line_number 	= paip.line_number
		and     paha.auction_header_id  = pbip.auction_header_id
		)
		where
			paip.auction_header_id 	=  p_auction_id		  and
			paip.line_number	>= l_batch_start 	  and
			paip.line_number	<= l_batch_end;

           	l_batch_start := l_batch_end + 1;

           	IF (l_batch_end + l_batch_size > l_max_line_number) THEN
               		l_batch_end := l_max_line_number;
           	ELSE
               		l_batch_end := l_batch_end + l_batch_size;
           	END IF;

		IF(l_commit_flag = TRUE) THEN
			COMMIT;
		END IF;

	END LOOP; --} --end-loop- batching

--
END update_all_auction_item_prices;



  -- This method is kind of redundant because we now use the
  -- award status flag to determine which item is awarded and
  -- which is not.
  -- So removed all the old code to delete unawarded items and only
  -- doing an update of the award quantity

PROCEDURE clean_unawarded_items (p_batch_id            IN NUMBER) IS

BEGIN

   -- update the award quantity to 0 for those fields that have award quantity
   -- less than 0
  UPDATE pon_award_items_interface
 SET award_quantity = 0
  WHERE batch_id = p_batch_id
  AND award_quantity < 0;

  COMMIT;

END clean_unawarded_items;


/*
 Reject the active bids on negotiation items that were not awarded
 and cancel backing requisitions for the items, if any
*/
PROCEDURE reject_unawarded_active_bids(p_auction_header_id     IN NUMBER,
                                       p_user_id               IN NUMBER,
                                       p_note_to_rejected      IN VARCHAR2,
									   p_neg_has_lines         IN VARCHAR2) IS

  -- select all active bid items for for which award decision is not made.
  -- this includes auction lines with no award decision made
  -- and auction lines with award decision made but have bid items unawarded
  CURSOR active_bid_lines(p_auction_header_id NUMBER) IS
          select al.line_number,
                 al.line_origination_code,
				 nvl(al.award_status,'NO'),
                 bl.bid_number,
                 bl.order_number,
                 bl.award_quantity
            from pon_auction_item_prices_all al,
                 pon_bid_item_prices bl,
                 pon_bid_headers bh
           where al.auction_header_id = p_auction_header_id
             and bl.auction_header_id = al.auction_header_id
             and bl.line_number = al.line_number
             and bh.bid_number = bl.bid_number
             and nvl(bh.bid_status,'NONE') = 'ACTIVE'
			 -- we get lines with award decision made but have some bids unawarded
			 --and nvl(al.award_status,'NO') = 'NO'
             and nvl(bl.award_status,'NO') = 'NO';


    -- FPK: CPA select all active bids for which award decision is not made.
	CURSOR active_bid_headers(p_auction_header_id NUMBER) IS
	       select nvl(ah.award_status,'NO'),
	                 bh.bid_number
	       from pon_auction_headers_all ah,
	                 pon_bid_headers bh
	       where bh.auction_header_id = p_auction_header_id
	       and bh.auction_header_id = ah.auction_header_id
	       and nvl(bh.bid_status,'NONE') = 'ACTIVE'
		   and nvl(bh.award_status,'NO') = 'NO';


  x_line_number pon_auction_item_prices_all.line_number%type;
  x_old_line_number pon_auction_item_prices_all.line_number%type;
  x_line_origination_code pon_auction_item_prices_all.line_origination_code%type;
  x_bid_number pon_bid_headers.bid_number%type;
  x_order_number pon_bid_headers.order_number%type;
  x_award_quantity pon_bid_item_prices.award_quantity%type;
  x_line_award_status pon_auction_item_prices_all.award_status%type;
  x_stored_note_to_rejected pon_acceptances.reason%type;
  x_error_code VARCHAR2(20);

  x_bid_number_list integerList;
  x_bid_number_found BOOLEAN;
  x_count NUMBER;

  -- FPK: CPA
  x_header_award_status  PON_BID_HEADERS.AWARD_STATUS%TYPE;

BEGIN
 IF p_neg_has_lines = 'Y' THEN -- FPK: CPA
      open active_bid_lines(p_auction_header_id);
      loop
            fetch active_bid_lines
             into x_line_number,
                  x_line_origination_code,
				  x_line_award_status,
                  x_bid_number,
                  x_order_number,
                  x_award_quantity;
            exit when active_bid_lines%notfound;
			-- "AND x_line_award_status = 'NO'" condition added
			-- to ensure ONLY lines with NO award decision made are put back into the pool.
            if (x_line_origination_code = 'REQUISITION' AND x_line_award_status = 'NO') then
               PON_AUCTION_PKG.CANCEL_NEGOTIATION_REF_BY_LINE(p_auction_header_id, x_line_number, x_error_code);
            end if;
/*
            -- reject the bid line (note that reject shares the same
            -- procedure as award)
            award_bid (x_order_number,          -- p_order_number
                     p_user_id,                 -- p_auctioneer_id
                     p_auction_header_id,       -- p_auction_header_id
                     x_bid_number,              -- p_bid_number
                     x_line_number,             -- p_auction_line_number
                     x_award_quantity,          -- p_award_quantity
                     'REJECTED',                -- p_award_status
                     p_note_to_rejected,        -- p_reason
		             sysdate,                   -- p_award_date,
                     null,                      -- p_originPartyId: obsolete
                     null,                      -- p_originUserId: obsolete
                     null,                      -- p_currency: obsolete
                     null                       -- p_billType: obsolete
                    );
*/
         -- added for the new award flow in FPJ
		 -- Need to take care of notes in pon_acceptances.
	 	  update_single_bid_item_prices
	       (
	        x_bid_number,
			x_line_number,
			'REJECTED',
			x_award_quantity,
			sysdate,
			p_user_id
		   );

            -- determine if the bid number of the bid line has been added to the list
            x_bid_number_found := FALSE;

            FOR i IN 1 .. x_bid_number_list.COUNT LOOP
              IF x_bid_number = x_bid_number_list(i) THEN
                x_bid_number_found := TRUE;
                EXIT;
              END IF;
            END LOOP;

            -- if not, add it to the list
            IF NOT(x_bid_number_found) THEN
              x_bid_number_list(x_bid_number_list.COUNT + 1) := x_bid_number;
            END IF;

            -- complete or award item disposition as necessary
            -- there could be multiple bids for the same line
            -- only need to call it once for each line
            IF (x_old_line_number is null OR
                x_old_line_number <> x_line_number) THEN
               x_old_line_number := x_line_number;

	       IF (x_line_award_status = 'NO') THEN
	         -- Update acceptances for the lines with no award decision made
                update_unawarded_acceptances(
		   p_auction_header_id, -- auction header id
		   x_line_number,      -- line number
		   p_note_to_rejected, --note to rejected suppliers
		   SYSDATE,            -- award_date
		   p_user_id);
	       ELSE
  	        -- Update acceptances for the lines with award decision already made
		   x_stored_note_to_rejected := null;
		   x_count := 0;
		   SELECT count(*) INTO x_count FROM pon_acceptances
		   WHERE auction_header_id = p_auction_header_id
		   AND line_number = x_line_number
		   AND ACCEPTANCE_TYPE = 'REJECTED';
--
		   IF x_count > 0 THEN
		     -- rejection note exists and carried over for rejected suppliers
		     SELECT distinct REASON INTO x_stored_note_to_rejected
		     FROM pon_acceptances
		     WHERE auction_header_id = p_auction_header_id
		     AND line_number = x_line_number
		     AND ACCEPTANCE_TYPE = 'REJECTED';
	           END IF;
--
	   	   update_unawarded_acceptances(
		           p_auction_header_id, -- auction header id
			   x_line_number,      -- line number
			   x_stored_note_to_rejected, --note to rejected suppliers
			   SYSDATE,            -- award_date
			   p_user_id);
	       END IF;
               award_item_disposition (p_auction_header_id, x_line_number, 0);
            END IF;

      END LOOP;
      CLOSE active_bid_lines;

      -- update the award status for the bids whose lines were rejected
      FOR i IN 1 .. x_bid_number_list.COUNT LOOP
        update_single_bid_header(x_bid_number_list(i), p_user_id);
      END LOOP;

      -- update the award status for the auction that was bidded on
      -- if any bid line was rejected
      IF x_bid_number_list.COUNT > 0 THEN
        update_auction_headers(p_auction_header_id, g_AWARD_LINE, SYSDATE, p_user_id, 'Y');
      END IF;
 ELSE -- negotiation does not have lines
    OPEN active_bid_headers(p_auction_header_id);
	LOOP
	   FETCH active_bid_headers
	   INTO x_header_award_status, x_bid_number;
       EXIT WHEN active_bid_headers%NOTFOUND;

	   -- determine if the bid number has been added to the list
	   x_bid_number_found := FALSE;

	   FOR i IN 1 .. x_bid_number_list.COUNT LOOP
	      IF x_bid_number = x_bid_number_list(i) THEN
	         x_bid_number_found := TRUE;
	         EXIT;
	      END IF;
	   END LOOP;

	   -- if not, add it to the list
	   IF NOT(x_bid_number_found) THEN
	          x_bid_number_list(x_bid_number_list.COUNT + 1) := x_bid_number;
	   END IF;
	END LOOP;
    CLOSE active_bid_headers;

	-- update the award status for the active bids in this auction where no
	-- award decision made (all bids will be rejected)
    FORALL k IN 1..x_bid_number_list.COUNT

        UPDATE PON_BID_HEADERS
		SET AWARD_STATUS = 'REJECTED',
		    AWARD_DATE   = SYSDATE, /* new column created as part of CPA project.
	                                   It will be updated only when negotiation does
                                       not have lines. */
    	    last_update_date = SYSDATE,
		    last_updated_by = p_user_id
		WHERE bid_number = x_bid_number_list(k);

	 -- update the award status for the auction that was bidded on
	 -- and no award decision made
	 IF x_bid_number_list.COUNT > 0 THEN
	    update_auction_headers(p_auction_header_id, g_AWARD_QUOTE, SYSDATE,
	                           p_user_id, 'N');
	 END IF;
 END IF; -- IF neg. has lines
END reject_unawarded_active_bids;

----------------------------------------------------------------
-- Complete award process for a negotiation
-- mirrors NegotiationDoc.completeAward which is gone after
-- migration to OA
-- also contains some logic from reviewComplete.jsp
----------------------------------------------------------------

PROCEDURE complete_award (p_auction_header_id_encrypted IN VARCHAR2,
                          p_auction_header_id           IN NUMBER,
                          p_note_to_rejected            IN VARCHAR2,
                          p_shared_award_decision       IN VARCHAR2,
                          p_user_id                     IN NUMBER,
                          p_create_po_flag              IN VARCHAR2,
                          p_source_reqs_flag            IN VARCHAR2,
                          p_no_bids_flag                IN VARCHAR2,
                          p_has_backing_reqs_flag       IN VARCHAR2,
                          p_outcome_status              IN VARCHAR2,
						  p_has_scoring_teams_flag      IN VARCHAR2,
						  p_scoring_lock_tpc_id         IN NUMBER) IS

x_line_number pon_auction_item_prices_all.line_number%type;
x_line_origination_code pon_auction_item_prices_all.line_origination_code%type;
x_error_code VARCHAR2(20);
x_awarded_quantity NUMBER;
l_neg_has_lines PON_AUCTION_HEADERS_ALL.HAS_ITEMS_FLAG%TYPE; -- FPK: CPA

--Business Events Changes
x_return_status  VARCHAR2(20);
x_msg_count      NUMBER;
x_msg_data       VARCHAR2(2000);

-- select items without any bids that had backing requisitions
CURSOR items_with_reqs_no_bids(p_auction_header_id NUMBER) IS
        SELECT 	line_number, line_origination_code
        FROM 	PON_AUCTION_ITEM_PRICES_ALL
        WHERE 	auction_header_id = p_auction_header_id
        AND   	nvl(number_of_bids,0) = 0
	AND	line_origination_code = 'REQUISITION';


CURSOR auction_items_all (p_auction_header_id NUMBER) IS
        SELECT line_number, nvl(awarded_quantity, 0)
          FROM PON_AUCTION_ITEM_PRICES_ALL
         WHERE auction_header_id = p_auction_header_id;

BEGIN

l_neg_has_lines := PON_AUCTION_PKG.neg_has_lines(p_auction_header_id); -- FPK: CPA
----
      if (p_create_po_flag <> 'Y' and p_has_backing_reqs_flag = 'Y') then
            -- put requisitions back in pool if auction
            -- has backing req and no outcome creation
            PON_AUCTION_PKG.CANCEL_NEGOTIATION_REF(p_auction_header_id, x_error_code);
      end if;

	/* FPK: CPA
	   If negotiation has lines: for all items that have active bids but are not awarded,
	   reject the active bids and cancel backing requisitions, if any
	   If negotiation does not have lines: reject all active bids that were not awarded n
	   nor rejected (no award decision was made)
    */
      reject_unawarded_active_bids(p_auction_header_id, p_user_id, p_note_to_rejected, l_neg_has_lines);

      -- Requisitions should be put back into the pool if
      -- an item has received no bids and the buyer
      -- is completing the auction

  IF l_neg_has_lines = 'Y' THEN -- FPK: CPA
      open items_with_reqs_no_bids(p_auction_header_id);
      loop

	/*
		rrkulkar-large-auction-support changes
		modified the cursor to simply loop over the exact set of lines
		rather than looping over all the lines, and filtering the lines
		in the cursor-loop by adding an if condition

	*/
            fetch items_with_reqs_no_bids
             into x_line_number,
                  x_line_origination_code;
            exit when items_with_reqs_no_bids%notfound;

	    PON_AUCTION_PKG.CANCEL_NEGOTIATION_REF_BY_LINE(p_auction_header_id, x_line_number, x_error_code);

      end loop;
      close items_with_reqs_no_bids;
--

	/*
	rrkulkar-large-auction-support changes
	instead of looping over all the lines, we can update all
	lines in a single query

	*/

	/*
	rrkulkar-large-auction-support : commented out the call to complete_item_disposition
	need to add batching here
	*/

	    update pon_auction_item_prices_all
            set    AWARD_STATUS     = 'COMPLETED',
                   LAST_UPDATE_DATE = sysdate,
                   AWARDED_QUANTITY = nvl(awarded_quantity,0)
	    where auction_header_id = p_auction_header_id;

  END IF; -- IF l_neg_has_lines = 'Y'
--
  -- if team scoring is enabled, call routine to lock team scoring
  IF (p_has_scoring_teams_flag = 'Y') THEN
    -- check to see if the auction was already locked for scoring
    -- if this were true, the p_scoring_lock_tpc_id will be -1
    -- as determined in the CompleteAwardAM from where this API is called.
    IF (p_scoring_lock_tpc_id = -1) THEN
      NULL;
    ELSE
      -- call pvt API to lock scoring
      IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_award_pkg.complete_award'
                      ,message   => 'before calling private API to lock team scoring');
      END IF;

      PON_TEAM_SCORING_UTIL_PVT.lock_scoring(p_api_version => 1
	                                      ,p_auction_header_id => p_auction_header_id
	  									  ,p_tpc_id => p_scoring_lock_tpc_id
	   									  ,x_return_status => x_return_status
										  ,x_msg_data => x_msg_data
										  ,x_msg_count => x_msg_count);

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(log_level => fnd_log.level_unexpected
       	   	        ,module    => 'pon_award_pkg.complete_award'
                    ,message   => 'Error while locking team scoring');
        END IF;
      END IF;
    END IF;
  END IF;


      complete_auction (p_auction_header_id);

      award_notification (p_auction_header_id_encrypted,
                          p_auction_header_id,
                          p_shared_award_decision);

      -- post processing: originally in reviewComplete.jsp
      -- For no bids we would come directly to this page.
      -- Thus setShareAwardDecision will be N. We do not want that.
      -- As otherwise the button will appear in bidViewAuction
      -- update database w/ outcome status, source req result,
      -- and award completion date
      update pon_auction_headers_all
         set outcome_status = p_outcome_status,
             award_complete_date = sysdate,
             source_reqs_flag = p_source_reqs_flag,
             share_award_decision = decode(p_no_bids_flag, 'Y', 'I', share_award_decision),
             last_update_date = sysdate
       where auction_header_id = p_auction_header_id;

  -- Raise Business Event
  PON_BIZ_EVENTS_PVT.RAISE_NEG_AWRD_COMPLETE_EVENT(
     p_api_version       => 1.0 ,
     p_init_msg_list     => FND_API.G_FALSE,
     p_commit            => FND_API.G_FALSE,
     p_auction_header_id => p_auction_header_id,
     p_create_po_flag    => p_create_po_flag,
     x_return_status     => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data);

END complete_award;

----------------------------------------------------------------
-- complete auction
-- mirrors NegotiationDoc.completeAuction which is gone after
-- migration to OA
----------------------------------------------------------------

PROCEDURE complete_auction (p_auction_header_id     IN NUMBER ) IS

x_event_id pon_auction_headers_all.event_id%type;
x_count NUMBER;

BEGIN
        -- complete auction header disposition
	-- clear out the request_id for super-large auctions
	update pon_auction_headers_all
           set AWARD_STATUS = 'COMPLETED',
               AUCTION_STATUS = 'AUCTION_CLOSED',
	       REQUEST_ID  = NULL,
               LAST_UPDATE_DATE = sysdate
	 where auction_header_id = p_auction_header_id;

        -- complete work flow
        pon_auction_pkg.COMPLETE_AUCTION(p_auction_header_id);

END complete_auction;

----------------------------------------------------------------
-- send award notifications
-- mirrors NegotiationDoc.awardNotification which is gone after
-- migration to OA
----------------------------------------------------------------

PROCEDURE award_notification (p_auction_header_id_encrypted IN VARCHAR2,
                              p_auction_header_id           IN NUMBER,
                              p_shared_award_decision       IN VARCHAR2) IS

x_bid_number pon_bid_headers.bid_number%type;
x_bid_tp_contact_name pon_bid_headers.trading_partner_contact_name%type;
x_auction_tp_name pon_auction_headers_all.trading_partner_name%type;
x_auction_title pon_auction_headers_all.auction_title%type;
x_emd_admin_name pon_neg_team_members.user_name%type;
x_doc_number_dsp pon_auction_headers_all.document_number%type;
CURSOR all_bidders(p_auction_header_id NUMBER) IS
    select b.bid_number,
           b.trading_partner_contact_name contact,
           a.trading_partner_name auctioneer,
           a.auction_title
      from pon_bid_headers b,
           pon_auction_headers_all a
     where b.auction_header_id = p_auction_header_id
       and not nvl(b.bid_status,'NONE') in ('ARCHIVED','DISQUALIFIED')
       and a.auction_header_id = b.auction_header_id;

-- choli update for emd
CURSOR all_emdAdmins(p_auction_header_id NUMBER) IS
       select u.user_name,
              a.trading_partner_name auctioneer,
              a.auction_title,
              a.document_number
         from pon_neg_team_members b, pon_auction_headers_all a, fnd_user u
        where b.menu_name = 'EMD_ADMIN'
          and b.approver_flag = 'Y'
          and a.auction_header_id = b.auction_header_id
          and u.user_id = b.user_id
          and a.auction_header_id = p_auction_header_id;

BEGIN

    if (p_shared_award_decision = 'Y') then

       -- send a notification to each supplier
       open all_bidders(p_auction_header_id);
       loop
            fetch all_bidders
             into x_bid_number,
                  x_bid_tp_contact_name,
                  x_auction_tp_name,
                  x_auction_title;
            exit when all_bidders%notfound;

            pon_auction_pkg.AWARD_BID(x_bid_number,
                                      p_auction_header_id,
                                      x_bid_tp_contact_name,
                                      x_auction_tp_name,
                                      x_auction_title,
                                      p_auction_header_id_encrypted);
       end loop;
       close all_bidders;

       -- update pon_auction_headers_all
       update pon_auction_headers_all
          set SHARE_AWARD_DECISION = p_shared_award_decision
        where auction_header_id = p_auction_header_id;

    end if;

    -- choli update for emd
       open all_emdAdmins(p_auction_header_id);
       loop
            fetch all_emdAdmins
             into x_emd_admin_name,
                  x_auction_tp_name,
                  x_auction_title,
                  x_doc_number_dsp;
            exit when all_emdAdmins%notfound;

            NotifyEmdAdmin(p_auction_header_id,
                                      x_emd_admin_name,
                                      x_auction_tp_name,
                                      x_auction_title,
                                      p_auction_header_id_encrypted,
                                      x_doc_number_dsp);
       end loop;
       close all_emdAdmins;

END award_notification;

----------------------------------------------------------------
-- complete item disposition
-- mirrors NegotiationItem.completeDisposition which is gone after
-- migration to OA
----------------------------------------------------------------

PROCEDURE  complete_item_disposition  (p_auction_header_id     IN NUMBER,
                                       p_line_number           IN NUMBER,
                                       p_award_quantity        IN NUMBER) IS

BEGIN
	    update pon_auction_item_prices_all
               set AWARD_STATUS = 'COMPLETED',
                   LAST_UPDATE_DATE = sysdate,
                   AWARDED_QUANTITY = p_award_quantity
	     where auction_header_id = p_auction_header_id
	       and line_number = p_line_number;

END complete_item_disposition;


----------------------------------------------------------------
-- award item disposition
-- mirrors complete_item_disposition
-- except that pon_auction_item_prices_all.award_status column is set to AWARDED (instead of COMPLETED)
----------------------------------------------------------------

PROCEDURE  award_item_disposition  (p_auction_header_id     IN NUMBER,
                                       p_line_number           IN NUMBER,
                                       p_award_quantity        IN NUMBER) IS

BEGIN
	    update pon_auction_item_prices_all
               set AWARD_STATUS = 'AWARDED',
                   LAST_UPDATE_DATE = sysdate,
                   AWARDED_QUANTITY = p_award_quantity
	     where auction_header_id = p_auction_header_id
	       and line_number = p_line_number;

END award_item_disposition;

--
----------------------------------------------------------------
-- handles awarding for award by quote, award by line, award line
-- procedure added by snatu on 08/15/03
-- Coded for FPJ
----------------------------------------------------------------
PROCEDURE award_auction
( p_auctioneer_id     IN  NUMBER
, p_auction_header_id IN  NUMBER
, p_last_update_date  IN  DATE
, p_mode              IN  VARCHAR2
, p_line_num          IN  NUMBER
, p_award_table       IN  PON_AWARD_TABLE
, p_note_to_accepted  IN  VARCHAR2
, p_note_to_rejected  IN  VARCHAR2
, p_batch_id          IN  NUMBER
, x_status            OUT NOCOPY VARCHAR2
)
IS
--
l_counter BINARY_INTEGER;
l_size    NUMBER;
l_index   BINARY_INTEGER;
l_rec     PON_AWARD_REC;
--
l_award_lines  t_award_lines;
-- FPK: CPA
l_awarded_bid_headers t_awarded_bid_headers;
l_neg_has_lines PON_AUCTION_HEADERS_ALL.HAS_ITEMS_FLAG%TYPE;

l_matrix_index NUMBER;
--
l_current_bid_number           NUMBER;
l_bid_list_index               NUMBER;
l_tmp_award_quantity           NUMBER;
l_group_type                   pon_auction_item_prices_all.group_type%TYPE;
l_award_date                   DATE;
TYPE BID_LIST_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_bid_list                     BID_LIST_TYPE;
l_winning_bid		       NUMBER;
l_neg_contract_type 		pon_auction_headers_all.contract_type%TYPE;

--
l_has_quantity_tiers        pon_auction_item_prices_all.has_quantity_tiers%TYPE;
l_award_shipment_number     NUMBER;
l_suffix                    VARCHAR2(2);

--
BEGIN
--
--
IF (g_debug_mode = 'Y') THEN
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.AWARD_AUCTION', 'Entering procedure with p_auctioneer_id: ' || p_auctioneer_id );
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.AWARD_AUCTION',' p_last_update_date : '|| p_last_update_date || ' ,p_mode : '|| p_mode || ' ,p_line_num : '|| p_line_num);
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.AWARD_AUCTION',' p_batch_id : '|| p_batch_id || ' ,p_auction_header_id : ' || p_auction_header_id );
     END IF;
END IF;

l_neg_has_lines := PON_AUCTION_PKG.neg_has_lines(p_auction_header_id);

select contract_type
into l_neg_contract_type
from pon_auction_headers_all
where auction_header_id = p_auction_header_id
and rownum =1;

IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.AWARD_AUCTION.AUCTION_ID:' || p_auction_header_id,'START');
END IF;
--
  l_matrix_index := 0;
  l_award_date := SYSDATE;
--
  IF (p_mode = g_AWARD_QUOTE) THEN

  	 clear_draft_awards (p_auction_header_id, p_line_num, l_award_date, p_auctioneer_id, l_neg_has_lines);

	 /* update auction-header by nulling out the request-id */

	 update pon_auction_headers_all
	 set    request_id = to_number(null)
	 where  auction_header_id = p_auction_header_id;

  	 -- Need to expand all the AWARDED bids to build the lines
	 l_size := p_award_table.COUNT;
	 FOR l_index IN 1..l_size LOOP -- Loop through all the bids
     	 l_rec := p_award_table(l_index);
	 -- Construct Matrix only in case of awarded bids
	 IF l_rec.award_outcome = g_AWARD_OUTCOME_WIN THEN

	    IF l_neg_has_lines = 'Y' THEN -- FPK: CPA

		l_winning_bid := l_rec.bid_number;

		update_all_bid_item_prices(l_winning_bid, get_award_status(l_rec.award_outcome), l_award_date, p_auctioneer_id);

		if(l_neg_contract_type in ('BLANKET', 'CONTRACT')) then
			update_all_auction_item_prices(p_auction_header_id, l_winning_bid, l_award_date, p_auctioneer_id);
		end if;

		ELSE -- negotiation does not have lines
			 -- Build table of active bids.
	         -- All the bids will have one of the award outcome status: win, lose or no award.
	               l_matrix_index := l_matrix_index + 1;
		       l_awarded_bid_headers(l_matrix_index).bid_number := l_rec.bid_number;
		       l_awarded_bid_headers(l_matrix_index).award_status := get_award_status(l_rec.award_outcome);
		       l_awarded_bid_headers(l_matrix_index).award_date := l_award_date;
	    END IF;

		 --update total agreed amount (if any)
		 IF l_rec.total_agreement_amount is not null THEN
		 	UPDATE pon_bid_headers
			SET po_agreed_amount = l_rec.total_agreement_amount
			WHERE bid_number = l_rec.bid_number;
		 END IF;
	END IF; -- IF l_rec.award_outcome = g_AWARD_OUTCOME_WIN
		 -- update notes
		 update_notes_for_bid(l_rec.bid_number, l_rec.note_to_supplier, l_rec.internal_note, p_auctioneer_id);
     END LOOP;

        -- outside the loop, update all auction_lines
        -- in case of BPA outcome, we can award multiple bids -> but we will update
        -- all auction lines just once

	IF (l_neg_has_lines = 'Y') THEN
	   IF (l_neg_contract_type <> 'BLANKET' and l_neg_contract_type <> 'CONTRACT') THEN
	      update_all_auction_item_prices(p_auction_header_id, l_winning_bid, l_award_date, p_auctioneer_id);
	   END IF;
	END IF;


  END IF ;
--
  IF (p_mode = g_AWARD_MULTIPLE_LINES) THEN --{
  	 clear_draft_awards (p_auction_header_id, p_line_num, l_award_date, p_auctioneer_id, l_neg_has_lines);
  	 -- Need to set award quantity and award_status
	 l_size := p_award_table.COUNT;
	 l_current_bid_number := -1;
--
	 FOR l_index IN 1..l_size LOOP -- Loop through all the bids
     	 l_rec := p_award_table(l_index);
		 -- Construct Matrix only in case of awarded bids
		 IF l_rec.award_outcome = g_AWARD_OUTCOME_WIN THEN
		      --Get Award Qty FROM Response Qty
		     SELECT decode (ai.order_type_lookup_code, 'FIXED PRICE', 1, 'AMOUNT', 1, 'RATE', decode(ai.purchase_basis , 'TEMP LABOR' ,bi.quantity, 1) , bi.quantity) INTO l_tmp_award_quantity
                     FROM pon_bid_item_prices bi, pon_auction_item_prices_all ai
                     WHERE bi.bid_number = l_rec.bid_number
                     AND bi.line_number = l_rec.line_number
                     AND ai.auction_header_id = bi.auction_header_id
                     AND ai.line_number = bi.line_number;
--
		     SELECT ai.group_type INTO l_group_type
			 FROM pon_bid_item_prices bi, pon_auction_item_prices_all ai
   			 WHERE bi.bid_number = l_rec.bid_number
                         AND bi.line_number = l_rec.line_number
                         AND ai.auction_header_id = bi.auction_header_id
			 AND ai.line_number = bi.line_number;
--
		 	 l_matrix_index := l_matrix_index + 1;
			 l_award_lines(l_matrix_index).bid_number := l_rec.bid_number;
			 l_award_lines(l_matrix_index).line_number := l_rec.line_number;
			 l_award_lines(l_matrix_index).award_status := get_award_status(l_rec.award_outcome);
		 	 l_award_lines(l_matrix_index).award_quantity := l_tmp_award_quantity;
 		 	 l_award_lines(l_matrix_index).award_date := l_award_date;
                         l_award_lines(l_matrix_index).group_type := l_group_type;
		 END IF;
	   	 -- Update Internal Notes and Notes to Suppliers for each bid
		 IF (l_current_bid_number <> l_rec.bid_number) THEN
 	 	 	update_notes_for_bid(l_rec.bid_number, l_rec.note_to_supplier, l_rec.internal_note, p_auctioneer_id);
		    --update total agreed amount (if any)
			IF l_rec.total_agreement_amount is not null THEN
			   UPDATE pon_bid_headers
			   SET po_agreed_amount = l_rec.total_agreement_amount
			   WHERE bid_number = l_rec.bid_number;
			END IF;

			l_current_bid_number := l_rec.bid_number;
		 END IF;
	 END LOOP;
  END IF; --}
--
  IF ((p_mode = g_AWARD_LINE) OR (p_mode = g_AWARD_LINE_H)
    OR(p_mode = g_AWARD_GROUP) OR (p_mode =  g_AWARD_GROUP_H)) THEN --{
--
         -- First, REJECT the group line level awards - No cumulative awards
         IF (p_mode = g_AWARD_GROUP) THEN
            clear_draft_awards (p_auction_header_id, p_line_num, l_award_date,
                                p_auctioneer_id, l_neg_has_lines);
         END IF;
--
	 l_bid_list_index := 0;
         SELECT ai.group_type INTO l_group_type
	 FROM pon_auction_item_prices_all ai
   	 WHERE ai.auction_header_id = p_auction_header_id
	 AND ai.line_number = p_line_num;
--
     -- Getting the suffix to display the error message correctly.
     l_suffix := PON_LARGE_AUCTION_UTIL_PKG.GET_DOCTYPE_SUFFIX (p_auction_header_id);

     -- Need to set award quantity and award_status
	 l_size := p_award_table.COUNT;
	 FOR l_index IN 1..l_size LOOP -- Loop through all the bids
     	l_rec := p_award_table(l_index);

        --R12.1 price tiers changes
        select nvl(has_quantity_tiers,'N') into l_has_quantity_tiers
        from pon_bid_item_prices
        where bid_number = l_rec.bid_number
        and line_number = p_line_num;

        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.AWARD_AUCTION', 'bid_number ' || l_rec.bid_number ||' ; line number ' ||p_line_num|| ' ; has_quantity_tiers  ' || l_has_quantity_tiers);
            END IF;
        END IF;

	    -- Construct Matrix in any case (WIN/LOSR)
	 	l_matrix_index := l_matrix_index +1;
		l_award_lines(l_matrix_index).bid_number := l_rec.bid_number;
		l_award_lines(l_matrix_index).line_number := p_line_num; --l_rec.line_number;
		l_award_lines(l_matrix_index).award_status := get_award_status(l_rec.award_outcome);
 	    l_award_lines(l_matrix_index).award_date := l_award_date;
 	    l_award_lines(l_matrix_index).group_type := l_group_type;
--
		IF l_rec.award_outcome = g_AWARD_OUTCOME_WIN THEN --{

		    /*
		     R12.1 Quantity based price tiers changes
		     If quantity tiers are present for a line and award quantity is not null
		     validating if award qty falls within the quantity tiers specified by the supplier
		     Update the award shipment number acoordingly.
		    */

		   IF ( 'Y' = l_has_quantity_tiers AND l_rec.award_quantity IS NOT NULL)
		   THEN  --{
		        l_award_shipment_number := -1;

		        select nvl((select pbs.shipment_number
		        from pon_bid_shipments pbs, pon_auction_item_prices_all paip
		        where pbs.bid_number = l_rec.bid_number
		        and pbs.line_number = p_line_num
		        AND l_rec.award_quantity >= pbs.quantity
		        AND l_rec.award_quantity <= pbs.max_quantity
		        AND paip.auction_header_id = pbs.auction_header_id
		        AND paip.line_number = pbs.line_number ),-1)
		        into l_award_shipment_number from dual;

	                IF (g_debug_mode = 'Y') THEN
        	            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                	           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.AWARD_AUCTION', 'award_shipment_number ' || l_award_shipment_number);
	                    END IF;
        	        END IF;

			IF ( l_award_shipment_number = -1) THEN --{
		        	-- Insert errors in interface table.
		                INSERT INTO PON_INTERFACE_ERRORS(
		                                              batch_id
		                                            , column_name
		                                            , error_message_name
        		                                    , table_name
                		                            , INTERFACE_LINE_ID
                        		                    , expiration_date
		                                            , created_by
        		                                    , creation_date
                		                            , last_updated_by
		                                            , last_update_date
		                                            , last_update_login
        		                                    , TOKEN1_NAME
                		                            , TOKEN1_VALUE
                        		                    )
				                    Values(
                		                                p_batch_id
                        		                        , fnd_message.get_string('PON','PON_AUCTION_AWARD_QTY')
		                                                , 'PON_QUANTITY_TIER_VIOLATION' || l_suffix
		                                                , 'PON_BID_ITEM_PRICES'
		                                                , p_line_num
		                                                , SYSDATE+7
        		                                        , fnd_global.user_id
		                                                , sysdate
		                                                , fnd_global.user_id
        		                                        , sysdate
                		                                , fnd_global.login_id
		                                                , 'BID_NUM'
		                                                , l_rec.bid_number
        		                                        );


		                x_status := 'FAILURE';

                        	IF (g_debug_mode = 'Y') THEN
	                            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	                            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.AWARD_AUCTION.AUCTION_ID:' || p_auction_header_id||' bid_number : '||l_rec.bid_number||' line_num: '||p_line_num, 'Quantity Tier Violation');
                	                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT,' award_quantity: '||l_rec.award_quantity,'Quantity Tier Violation');
                        	    END IF;
	                        END IF;
		       --} End of l_shipment_number = -1
		        ELSE --{ START of l_award_shipment_number != -1,

		            --
		            -- Award qty falls withtin the quantity specified by the supplier.
		            -- saving the corresponding shipment number
		            --
		            l_award_lines(l_matrix_index).award_shipment_number := l_award_shipment_number;

		        END IF; --} END of l_award_shipment_number != -1,
		   --} End of has_quantity_tiers='Y' and award_quantity not null
		   ELSE --{ Start of has_quantity_tiers <> 'Y' or award_quantity <> null

		    --
		    -- Line does not have quantity tiers so setting the default value as -1.
		    --
		    l_award_lines(l_matrix_index).award_shipment_number := -1;

		   END IF; --} End of has_quantity_tiers <> 'Y' or award_quantity <> null ; END of Quantity tiers loop

		   l_award_lines(l_matrix_index).award_quantity := l_rec.award_quantity;
                   l_award_lines(l_matrix_index).note_to_supplier := p_note_to_accepted;

		--} End of award_outcome_win
		ELSE --{ Start of award_outcome_lose

		    IF ((x_status is NULL) OR (x_status = 'SUCCESS')) THEN --{
		        l_award_lines(l_matrix_index).award_quantity := null;
		        l_award_lines(l_matrix_index).note_to_supplier := p_note_to_rejected;
		    END IF; --}

		END IF; --} End of award_outcome_lose

		--Update Notes only in case of Award Line V Page and NOT for Award Line H Page
		IF ((p_mode = g_AWARD_LINE OR p_mode = g_AWARD_GROUP) AND ((x_status is NULL) OR (x_status = 'SUCCESS'))) THEN
 	 	   update_notes_for_bid(l_rec.bid_number, l_rec.note_to_supplier, l_rec.internal_note, p_auctioneer_id);
		END IF;
	   	 -- Add new bid to the array
		l_bid_list_index := l_bid_list_index + 1;
		l_bid_list(l_bid_list_index) := l_rec.bid_number;
--
	 END LOOP;
  END IF; --}
--
IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.AWARD_AUCTION.AUCTION_ID:' || p_auction_header_id,'MATRIX BUILT');
END IF;
--
-- Clears the award history in case any for this auction
  IF (p_mode = g_AWARD_QUOTE) or (p_mode = g_AWARD_MULTIPLE_LINES) THEN --{

        IF l_neg_has_lines = 'Y' THEN -- FPK: CPA
	  IF(p_mode = g_AWARD_MULTIPLE_LINES) THEN
	     update_bid_item_prices(p_auction_header_id,l_award_lines,p_auctioneer_id, p_mode);
          END IF;
	END IF;

	  update_bid_headers(p_auction_header_id, p_auctioneer_id, l_awarded_bid_headers, l_neg_has_lines);

	IF l_neg_has_lines = 'Y' THEN -- FPK: CPA
          IF(p_mode = g_AWARD_MULTIPLE_LINES) THEN
	    update_auction_item_prices(p_auction_header_id, null, l_award_date, p_auctioneer_id, p_mode);
	  END IF;
	END IF;

	update_auction_headers(p_auction_header_id, p_mode, l_award_date, p_auctioneer_id, l_neg_has_lines);

        IF l_neg_has_lines = 'Y' THEN  -- FPK: CPA

	    bulk_update_pon_acceptances(
	  			p_auction_header_id,
	  			null, null, null,
				l_award_date, p_auctioneer_id, p_mode);
	END IF;
   --}
   ELSE --{
	  update_bid_item_prices(p_auction_header_id,l_award_lines,p_auctioneer_id, p_mode);
	  l_size := l_bid_list.count;
	  FOR l_index IN 1..l_size LOOP
	  	  update_single_bid_header(l_bid_list(l_index),p_auctioneer_id);
	  END LOOP;
	  update_auction_item_prices(p_auction_header_id,p_line_num, l_award_date, p_auctioneer_id, p_mode);
	  update_auction_headers(p_auction_header_id, p_mode, l_award_date, p_auctioneer_id, l_neg_has_lines);
	  bulk_update_pon_acceptances(
	           p_auction_header_id, p_line_num,
			   p_note_to_accepted, p_note_to_rejected,
			   l_award_date, p_auctioneer_id, p_mode);
  End IF; --}
--
--
--
IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.AWARD_AUCTION.AUCTION_ID:' || p_auction_header_id,'READY_TO_COMMIT');
END IF;
--

/*  check if the auction has been modified by some other user
    If it has been modified, status returns failure
    else this is the only user modifying hte auction
    changes are committed to the database in the middle tier
*/
   IF (((x_status is NULL) OR (x_status = 'SUCCESS')) AND (is_auction_not_updated (p_auction_header_id, p_last_update_date))) THEN
      x_status := 'SUCCESS';
	  -- update the last update date
	  UPDATE pon_Auction_headers_all
	  SET last_update_date = SYSDATE
	  WHERE auction_header_id = p_auction_header_id;
	  --
		IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.AWARD_AUCTION.AUCTION_ID:' || p_auction_header_id,'SUCCEEDED');
		END IF;
      --
   ELSE
      x_status := 'FAILURE';
		--
		IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.AWARD_AUCTION.AUCTION_ID:' || p_auction_header_id,'FAILED');
		END IF;
		--
   END IF;
--
END award_auction;
--
--
PROCEDURE update_bid_item_prices
(
	p_auction_id    IN NUMBER,
	p_award_lines   IN t_award_lines,
	p_auctioneer_id IN NUMBER,
	p_mode          IN VARCHAR2
)
IS
l_size NUMBER;
l_index NUMBER;
l_group_type pon_auction_item_prices_all.group_type%type;
l_award_quantity pon_bid_item_prices.award_quantity%type;
l_award_shipment_number NUMBER;
--
/* for updating group for each bid's group line,
   we maintain an associative array (hashmap equivalant)
   in the form of (bid:group_number  ==> 1234:56
   and once all bid lines are updated, we traverse through this map
   and update the required bid groups
*/
type bid_line_asso is table of varchar2(30) index by varchar2(30);
l_bid_group_map bid_line_asso;
l_bid_line_key VARCHAR2(30);
l_parent_line_number pon_auction_item_prices_all.parent_line_number%type;
l_bid_number pon_bid_item_prices.bid_number%type;
--
BEGIN

  IF (g_debug_mode = 'Y') THEN
     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_BID_ITEM_PRICES', 'Entering procedure with p_mode: ' || p_mode || ' ,p_auction_id : ' || p_auction_id || ' ,p_auctioneer_id : '|| p_auctioneer_id);
      END IF;
  END IF;

  l_size := p_award_lines.COUNT;
  -- Loop through the matrix to update bid items and acceptances
  FOR l_index IN 1..l_size LOOP
         l_group_type := p_award_lines(l_index).group_type;
         IF (l_group_type = 'GROUP') THEN
           l_award_quantity := null;
         ELSE
           l_award_quantity := p_award_lines(l_index).award_quantity;
           l_award_shipment_number := p_award_lines(l_index).award_shipment_number;
         END IF;

         IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_BID_ITEM_PRICES', 'l_index : ' || l_index || ' ; award shipment number : ' || l_award_shipment_number || ' ; award quantity  : ' || l_award_quantity);
             END IF;
         END IF;

         --
         -- Price Tiers Changes. If quantity based price tiers are present call the upd_single_bid_item_prices_qt
         -- Api which takes the unit price from pon_bid_shipments according to awarded shipment number.
         --

         IF ( l_award_shipment_number IS NULL OR
              l_award_shipment_number = -1 ) THEN --{
            update_single_bid_item_prices
            (
                p_award_lines(l_index).bid_number,
                p_award_lines(l_index).line_number,
                p_award_lines(l_index).award_status,
                l_award_quantity,
                p_award_lines(l_index).award_date,
                p_auctioneer_id
            );
         ELSE

         -- Quantity Tiers Case.
           upd_single_bid_item_prices_qt
           (
                p_award_lines(l_index).bid_number,
                p_award_lines(l_index).line_number,
                p_award_lines(l_index).award_status,
                l_award_quantity,
                p_award_lines(l_index).award_date,
                p_auctioneer_id,
                l_award_shipment_number
           );
         END IF; --}

--
	   IF (      (p_mode = g_AWARD_MULTIPLE_LINES AND l_group_type = 'LOT')
	          OR (p_mode = g_AWARD_LINE AND l_group_type = 'LOT')
		  OR (p_mode = g_AWARD_LINE_H AND l_group_type = 'LOT')
                  OR (p_mode = g_AWARD_AUTO_RECOMMEND AND l_group_type = 'LOT')
                  OR (p_mode = g_AWARD_GROUP_H AND l_group_type = 'GROUP')
		  OR (p_mode = g_AWARD_GROUP AND l_group_type = 'GROUP') ) THEN
		  award_bi_subline (
                        p_auction_id,
		        p_award_lines(l_index).bid_number,
			p_award_lines(l_index).line_number,
			p_award_lines(l_index).award_status,
			p_award_lines(l_index).award_date,
			p_auctioneer_id );
          ELSIF ( (p_mode = g_AWARD_MULTIPLE_LINES OR p_mode = g_AWARD_LINE
                OR p_mode = g_AWARD_LINE_H OR p_mode= g_AWARD_AUTO_RECOMMEND)
	        AND (l_group_type = 'GROUP_LINE') ) THEN

                   -- get parent line number
                   SELECT parent_line_number INTO l_parent_line_number
                   FROM pon_auction_item_prices_all
                   WHERE auction_header_id = p_auction_id
                   AND line_number = p_award_lines(l_index).line_number;

                  /* Key will be bid:group 1234:56 */
                  l_bid_line_key := to_char(p_award_lines(l_index).bid_number) || ':' || to_char(l_parent_line_number);
                  IF NOT (l_bid_group_map.exists(l_bid_line_key)) THEN
                    l_bid_group_map(l_bid_line_key) := l_bid_line_key;
                  END IF;
	   END IF;
  END LOOP;
  l_bid_line_key := l_bid_group_map.FIRST;
  WHILE l_bid_line_key IS NOT NULL LOOP
    -- update bid group
    l_bid_number := to_number(SUBSTR(l_bid_line_key ,1, instr(l_bid_line_key, ':') -1 ));
    l_parent_line_number := to_number(SUBSTR(l_bid_line_key, instr(l_bid_line_key, ':') +1));
                 -- update parent group
                  update_bi_group_award(
                        p_auction_id,
                        l_bid_number,
                        l_parent_line_number,
                        sysdate,
                        p_auctioneer_id
                        );

    l_bid_line_key := l_bid_group_map.NEXT(l_bid_line_key);
  END LOOP;

  IF (g_debug_mode = 'Y') THEN
     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_BID_ITEM_PRICES', 'Returning to the caller.....');
      END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      IF (g_debug_mode = 'Y') THEN
         IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_BID_ITEM_PRICES', 'An exception occurred during the execution. Raising the exception.....');
          END IF;
      END IF;
  RAISE;
--
END update_bid_item_prices;
--
--
PROCEDURE update_single_bid_item_prices
(
 p_bid_number     IN NUMBER,
 p_line_number    IN NUMBER,
 p_award_status   IN VARCHAR2,
 p_award_quantity IN NUMBER,
 p_award_date     IN DATE,
 p_auctioneer_id  IN NUMBER
)
IS
l_award_price   NUMBER;
BEGIN

        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_SINGLE_BID_ITEM_PRICES', 'Entering the procedure for p_bid_number : ' || p_bid_number || ' ; p_line_number : ' || p_line_number);

                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_SINGLE_BID_ITEM_PRICES', 'p_award_quantity : ' || p_award_quantity || ' ;p_award_date : ' || p_award_date || ' ;p_auctioneer_id : ' || p_auctioneer_id);

                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_SINGLE_BID_ITEM_PRICES',' ;p_award_status : ' || p_award_status);

            END IF;
        END IF;

        --
        -- Cost Factors Enhancements
        -- If award_quantity is not zero or null then use the per unit and fixed amount component and award
        -- quantity to calculate the award price
        --
        SELECT decode(p_award_status, 'REJECTED', null,
                      decode(nvl(p_award_quantity,0), 0,pbip.price,
                            pbip.per_unit_price_component + pbip.fixed_amount_component /p_award_quantity))
        INTO l_award_price
        FROM pon_bid_item_prices pbip,
            pon_auction_item_prices_all paip
        WHERE pbip.bid_number = p_bid_number
        AND pbip.line_number = p_line_number
        AND paip.auction_header_id = pbip.auction_header_id
        AND paip.line_number = pbip.line_number;

        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_SINGLE_BID_ITEM_PRICES', 'award_price: ' || l_award_price);
            END IF;
        END IF;

  	  --
      -- as this procedure will be called only if price tiers are not applicable so reseting the award_Shipment_number
      --
  	  UPDATE PON_BID_ITEM_PRICES
	  SET award_quantity = p_award_quantity,
		  --bug 18437645
		  --For Proxy Bidding case using the price column instead of award price
		  award_price = Decode(PROXY_BID_FLAG,'Y',price,l_award_price),
	      award_status = p_award_status,
		  award_date = p_award_date,
		  last_update_date = p_award_date,
		  last_updated_by = p_auctioneer_id,
		  award_shipment_number = NULL
	  WHERE Bid_number =  p_bid_number AND
	        Line_Number = p_line_number;

        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPDATE_SINGLE_BID_ITEM_PRICES', 'PON_BID_ITEM_PRICES has been updated. Returning to the caller....');
            END IF;
        END IF;

END update_single_bid_item_prices;

/*==========================================================================================================================
 * PROCEDURE : upd_single_bid_item_prices_qt
 * PARAMETERS:  1. p_bid_number - bid number for which the award_price and shipment no to be updated.
 *              2. p_line_number - corresponding line number
 *              3. p_award_status - award status 'AWARDED' or 'REJECTED'
 *              4. p_award_quantity - The quantity awarded
 *              5. p_award_date -- Award Datw
 *              6. p_auctioneer_id - Id of person who is saving award
 *              7. p_award_shipment_number - Quantity awarded falls in the tiers range corresponding to the shipment number
 * COMMENT   : This procedure calculates the award price based on the per unit and fixed amount component and
 *               corresponding to the award shipment number. PON_BID_ITEM_PRICES is updated accordingly
 *==========================================================================================================================*/
PROCEDURE upd_single_bid_item_prices_qt
(
 p_bid_number     IN NUMBER,
 p_line_number    IN NUMBER,
 p_award_status   IN VARCHAR2,
 p_award_quantity IN NUMBER,
 p_award_date     IN DATE,
 p_auctioneer_id  IN NUMBER,
 p_award_shipment_number IN NUMBER
)
IS
 l_award_price   NUMBER;
BEGIN

    IF (g_debug_mode = 'Y') THEN
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPD_SINGLE_BID_ITEM_PRICES_QT', 'Entering the procedure for p_bid_number : ' || p_bid_number || ' ; p_line_number : ' || p_line_number);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPD_SINGLE_BID_ITEM_PRICES_QT', 'p_award_status : ' || p_award_status || ' ;p_award_quantity : ' || p_award_quantity || ' ;p_award_date : ' || p_award_date);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPD_SINGLE_BID_ITEM_PRICES_QT',' p_auctioneer_id : ' || p_auctioneer_id || ' ;p_award_shipment_number : ' || p_award_shipment_number);
        END IF;
    END IF;

    --
    -- Cost Factors Enhancements
    -- If award_quantity is not zero or null then use the per unit and fixed amount component and award
    -- quantity to calculate the award price
    --

    SELECT DECODE(p_award_status, 'REJECTED', NULL,
                   DECODE (NVL(p_award_quantity,0), 0, pbs.price,
                        pbs.per_unit_price_component+pbip.fixed_amount_component/p_award_quantity))
    INTO l_award_price
    FROM pon_bid_item_prices pbip,
        pon_auction_item_prices_all paip,
        pon_bid_shipments pbs
    WHERE pbip.bid_number = p_bid_number
    AND pbip.line_number = p_line_number
    AND paip.auction_header_id = pbip.auction_header_id
    AND paip.line_number = pbip.line_number
    AND pbs.bid_number = pbip.bid_number
    AND pbs.line_number = pbip.line_number
    AND pbs.shipment_number = p_award_shipment_number;

    IF (g_debug_mode = 'Y') THEN --{
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN --}
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPD_SINGLE_BID_ITEM_PRICES_QT', 'award_price: ' || l_award_price);
        END IF; --}
    END IF; --}

    UPDATE PON_BID_ITEM_PRICES
    SET award_quantity = p_award_quantity,
        award_status = p_award_status,
        award_date = p_award_date,
        last_update_date = p_award_date,
        last_updated_by = p_auctioneer_id,
        award_price = l_award_price,
        award_shipment_number = p_award_shipment_number
    WHERE Bid_number =  p_bid_number AND
        Line_Number = p_line_number;

    IF (g_debug_mode = 'Y') THEN
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'pon.plsql.PON_AWARD_PKG.UPD_SINGLE_BID_ITEM_PRICES_QT', 'PON_BID_ITEM_PRICES has been updated. Returning to the caller....');
        END IF;
    END IF;

END upd_single_bid_item_prices_qt;

--
--
PROCEDURE update_bid_headers
(
p_auction_id           IN NUMBER,
p_auctioneer_id        IN NUMBER,
p_awarded_bid_headers  IN t_awarded_bid_headers DEFAULT t_emptytbl, -- FPK: CPA
p_neg_has_lines        IN VARCHAR2                                  -- FPK: CPA
)
IS
--
CURSOR c_active_bids (c_auction_id NUMBER) is
    SELECT bh.bid_number
	FROM pon_bid_headers bh
   	WHERE bh.auction_header_id = c_auction_id
	AND bid_status = 'ACTIVE';

l_active_bids_rec c_active_bids%ROWTYPE;

-- FPK: CPA
l_index             PLS_INTEGER;
l_bid_headers_count PLS_INTEGER :=0;  -- generic pon_bid_headers index

-- Declaration of individual elements to avoid ORA-3113 error because
-- FORALL does not allow update of elements using rec(i).field
l_bid_number_tbl    Number_tbl_type;
l_award_status_tbl  Char25_tbl_type;
l_award_date_tbl    Date_tbl_type;
--
BEGIN
IF p_neg_has_lines = 'Y' THEN -- FPK: CPA
	OPEN c_active_bids (p_auction_id);
	LOOP
		FETCH c_active_bids into l_active_bids_rec;
		EXIT WHEN c_active_bids%NOTFOUND;
    	update_single_bid_header (l_active_bids_rec.bid_number,
		                  p_auctioneer_id );
	END LOOP;
	CLOSE c_active_bids;
ELSE -- negotiation does not have lines
	 -- Loop through the matrix to update bid headers
   -- Map all values into single table arrays to avoid Oracle errors
   -- caused by using rec(i).field
   IF p_awarded_bid_headers.count > 0 THEN
    FOR l_index IN p_awarded_bid_headers.first..p_awarded_bid_headers.last
    LOOP
     l_bid_headers_count := l_bid_headers_count + 1;
     l_bid_number_tbl(l_bid_headers_count)  := p_awarded_bid_headers(l_index).bid_number;
     l_award_status_tbl(l_bid_headers_count):= p_awarded_bid_headers(l_index).award_status;
     l_award_date_tbl(l_bid_headers_count)  := p_awarded_bid_headers(l_index).award_date;

    END LOOP;
  END IF;

   FORALL k IN 1..l_bid_headers_count
      	UPDATE PON_BID_HEADERS
		SET AWARD_STATUS = l_award_status_tbl(k),
		    AWARD_DATE   = l_award_date_tbl(k), /* new column created as part of CPA project.
	                                               It will be updated only when negotiation does
                                                   not have lines. */
    	    last_update_date = SYSDATE,
		    last_updated_by = p_auctioneer_id
		WHERE bid_number = l_bid_number_tbl(k);
END IF;

END update_bid_headers;
--
--
PROCEDURE update_single_bid_header
(
  p_bid_number    IN NUMBER,
  p_auctioneer_id IN NUMBER
)
IS
--
CURSOR c_bid_lines (c_bid_number NUMBER) is

	    	SELECT 	bi.Line_number,
		   	bi.award_status,
		   	nvl(bi.award_price , bi.price) * bi.award_quantity   award_price
		FROM  pon_bid_item_prices bi, pon_auction_item_prices_all ai
	   	WHERE bi.bid_number = c_bid_number
		and bi.auction_header_id = ai.auction_header_id
		and bi.line_number = ai.line_number
		and ai.group_type in ('LOT', 'LINE', 'GROUP_LINE');

l_bid_lines_rec c_bid_lines%ROWTYPE;
--
l_award_status   VARCHAR2(30);
l_awarded_lines  NUMBER;
l_rejected_lines NUMBER;
l_total_lines    NUMBER ;
l_award_amount   NUMBER;
l_contract_type  VARCHAR2(20);
--
--
BEGIN
	l_award_amount := null;
	l_awarded_lines := 0;
	l_rejected_lines := 0;
	l_total_lines := 0;
	l_award_status := null;
--
    	SELECT ah.contract_type INTO l_contract_type
	FROM pon_auction_headers_all ah, pon_bid_headers bh
	WHERE bh.bid_number = p_bid_number
	AND bh.auction_header_id = ah.auction_header_id;
--
   	OPEN c_bid_lines (p_bid_number);
	LOOP
	 	 FETCH c_bid_lines into l_bid_lines_rec;
		 EXIT WHEN c_bid_lines%NOTFOUND;
		 l_total_lines := l_total_lines + 1;
	 	 IF l_bid_lines_rec.AWARD_STATUS = 'AWARDED' THEN
	 	 	l_awarded_lines := l_awarded_lines + 1;
		 END IF;
	 	 IF l_bid_lines_rec.AWARD_STATUS = 'REJECTED' THEN
	 	 	l_rejected_lines := l_rejected_lines + 1;
		 END IF;
		 IF l_contract_type = 'STANDARD' THEN
		    l_award_amount := nvl(l_award_amount,0) + nvl(l_bid_lines_rec.award_price,0);
		 END IF;
	END LOOP;

	CLOSE c_bid_lines;
	IF (l_awarded_lines <> 0) AND (l_awarded_lines = l_total_lines) THEN
	   l_award_status := 'AWARDED';
	ELSIF (l_rejected_lines <> 0) AND (l_rejected_lines = l_total_lines) THEN
	    l_award_status := 'REJECTED';
	ELSIF l_awarded_lines > 0 THEN
	    l_award_status := 'PARTIAL';
	END IF;
--
	UPDATE PON_BID_HEADERS
	SET AWARD_STATUS = l_award_status,
         total_award_amount = l_award_amount,
    	 last_update_date = SYSDATE,
	 last_updated_by = p_auctioneer_id
	WHERE bid_number = p_bid_number;
--
END update_single_bid_header;
--
--
PROCEDURE update_auction_item_prices
(
  p_auction_id    IN NUMBER,
  p_line_number   IN NUMBER,
  p_award_date    IN DATE,
  p_auctioneer_id IN NUMBER,
  p_mode          IN VARCHAR2
)
IS
CURSOR c_auction_items (c_auction_id NUMBER) IS
	   SELECT line_number, group_type
	   FROM pon_auction_item_prices_all
	   WHERE auction_header_id = c_auction_id;
l_auction_items_rec c_auction_items%ROWTYPE;
--
CURSOR c_item_sublines (c_auction_id NUMBER, c_parent_line_number NUMBER) IS
           SELECT line_number, group_type
           FROM pon_auction_item_prices_all
           WHERE auction_header_id = c_auction_id
           AND parent_line_number = c_parent_line_number;

l_item_sublines_rec c_item_sublines%ROWTYPE;
--
l_group_type  pon_auction_item_prices_all.group_type%TYPE;
--
BEGIN

     OPEN c_auction_items(p_auction_id);

     IF (p_mode = g_AWARD_QUOTE OR p_mode = g_AWARD_MULTIPLE_LINES
        OR p_mode=g_AWARD_AUTO_RECOMMEND OR p_mode = g_AWARD_OPTIMIZATION) THEN
	  LOOP
		  FETCH c_auction_items INTO  l_auction_items_rec;
		  EXIT WHEN c_auction_items%NOTFOUND;
		  update_single_auction_item(p_auction_id,
		               l_auction_items_rec.line_number,
			       p_auctioneer_id, p_mode);
	  END LOOP;
	  CLOSE c_auction_items;
    ELSE
	  update_single_auction_item (p_auction_id,
		               p_line_number,
			       p_auctioneer_id,
                               p_mode);

          SELECT group_type INTO l_group_type FROM pon_auction_item_prices_all
          WHERE auction_header_id = p_auction_id
                AND line_number = p_line_number;
          IF ((p_mode = g_AWARD_LINE AND l_group_type = 'LOT')
	    OR (p_mode = g_AWARD_LINE_H AND l_group_type = 'LOT')
            OR (p_mode = g_AWARD_GROUP_H AND l_group_type = 'GROUP')
	    OR (p_mode = g_AWARD_GROUP AND l_group_type = 'GROUP') ) THEN
--
	      OPEN c_item_sublines (p_auction_id, p_line_number);
--
              LOOP
	       fetch c_item_sublines into l_item_sublines_rec;
	       EXIT WHEN c_item_sublines%NOTFOUND;
	       -- update the child lines

               update_single_auction_item(p_auction_id,
		               l_item_sublines_rec.line_number,
	                       p_auctioneer_id,
                               p_mode);
              END LOOP;
--
           ELSIF ((p_mode = g_AWARD_LINE OR p_mode = g_AWARD_LINE_H)
               AND l_group_type = 'GROUP_LINE') THEN
	       update_ai_group_award(p_auction_id,
                               p_line_number,
			       p_award_date,
			       p_auctioneer_id);

	   END IF;
--
      END IF;
--
--
END update_auction_item_prices;
--
--
PROCEDURE update_single_auction_item
(
  p_auction_id    IN NUMBER,
  p_line_number   IN NUMBER,
  p_auctioneer_id IN NUMBER,
  p_mode          IN pon_auction_item_prices_all.award_mode%type
)
IS
CURSOR c_bid_items (c_auction_id NUMBER, c_line_number NUMBER) IS
	 SELECT bi.Line_number,
	 	ai.order_type_lookup_code,
		bi.award_status,
		bi.award_quantity,
		ai.group_type
	 FROM pon_bid_item_prices bi,
	 	  pon_bid_headers bh,
		  pon_auction_item_prices_all ai
	 WHERE bi.auction_header_id = c_auction_id
	  	   AND bi.line_number = c_line_number
		   AND bh.bid_status = 'ACTIVE'
		   AND bh.auction_header_id = bi.auction_header_id
		   AND bh.bid_number = bi.bid_number
	  	   AND ai.auction_header_id = bi.auction_header_id
	  	   AND ai.line_number = bi.line_number;
l_bid_items_rec c_bid_items%ROWTYPE;
l_award_status VARCHAR2(20);
l_award_made BOOLEAN;
l_award_quantity NUMBER;
l_line_type VARCHAR2(20);
l_contract_type VARCHAR2(20);
l_group_type VARCHAR2(20);
l_item_award_mode pon_auction_item_prices_all.award_mode%type;
--
BEGIN
   l_award_status := null;
   l_award_quantity := null;
   l_line_type := NULL;
   l_award_made := FALSE;
   l_item_award_mode := null;
--
   SELECT ah.contract_type INTO l_contract_type
   FROM pon_auction_headers_all ah
   WHERE ah.auction_header_id = p_auction_id;
--
   OPEN c_bid_items(p_auction_id, p_line_number) ;
   LOOP
   	  FETCH c_bid_items INTO l_bid_items_rec;
	  EXIT WHEN c_bid_items%NOTFOUND;
	  l_line_type := l_bid_items_rec.order_type_lookup_code;
          l_group_type:= l_bid_items_rec.group_type;
	  IF l_bid_items_rec.award_status = 'AWARDED' THEN
	  	  l_award_quantity := nvl(l_award_quantity,0) + l_bid_items_rec.award_quantity;
		  IF (NOT l_award_made)  THEN
		  	  l_award_made := TRUE;
		  END IF;
	  END IF;
	  IF ((l_award_status is null)
	      AND ((l_bid_items_rec.award_status = 'AWARDED'))
		  --Bug 12573845
		  --PON_AUCTION_ITEM_PRICES_ALL table was being updated with AWARDED status regardless of the bid status
		  --Modified such that only if Bid line is awarded, Negotiation line is set to AWARDED
                  --OR (l_bid_items_rec.award_status = 'REJECTED')
                  --OR (l_bid_items_rec.award_status = 'PARTIAL'))
		 ) THEN
	  	  l_award_status := 'AWARDED';
	  END IF;
   END LOOP;
   CLOSE c_bid_items;
--
   IF (l_award_made) AND (NOT (l_contract_type = 'STANDARD' AND l_line_type = 'QUANTITY'))
       AND (l_group_type <> 'LOT_LINE' AND  l_group_type <> 'GROUP') THEN
   	  l_award_quantity := 1;
   END IF ;
--
   -- set award mode = GROUP for group level award.
   IF(p_mode = g_AWARD_GROUP OR p_mode = g_AWARD_GROUP_H) AND l_group_type = 'GROUP' THEN
     l_item_award_mode := 'GROUP';
   END IF;
   UPDATE pon_auction_item_prices_all
   SET award_status = l_award_status,
   	   awarded_quantity = l_award_quantity,
           award_mode = l_item_award_mode,
   	   last_update_date = SYSDATE,
	   last_updated_by = p_auctioneer_id
   WHERE auction_header_id = p_auction_id
	   AND line_number = p_line_number;
--
END update_single_auction_item;
--
--
PROCEDURE update_auction_headers
(
  p_auction_id    IN NUMBER,
  p_mode          IN VARCHAR2,
  p_award_date	  IN DATE,
  p_auctioneer_id IN NUMBER,
  p_neg_has_lines IN VARCHAR2 -- FPK: CPA
)
IS
--
/*
CURSOR c_auction_lines (c_auction_id NUMBER) is
	    SELECT Line_number, award_status
		FROM pon_auction_item_prices_all
	   	WHERE auction_header_id = c_auction_id
			  AND number_of_bids > 0
			  AND group_type in ('LOT', 'LINE', 'GROUP_LINE');

l_auction_lines_rec c_auction_lines%ROWTYPE;
*/
--
l_award_status VARCHAR2(20);
l_award_mode VARCHAR2(20);
l_awarded_lines NUMBER;
l_total_lines NUMBER;

l_awarded_bids NUMBER; -- FPK: CPA
--
BEGIN
	l_awarded_lines := 0;
	l_total_lines := 0;
	l_award_status := 'NO';
	l_award_mode := null;

/*	CASE p_mode
	   WHEN g_AWARD_QUOTE THEN l_Award_mode := 'HEADER';
	   WHEN g_AWARD_MULTIPLE_LINES THEN l_award_mode := 'MULTIPLE_LINES';
	   WHEN g_AWARD_LINE THEN l_award_mode := 'LINE';
	   WHEN g_AWARD_LINE_H THEN l_award_mode := 'LINE';
	   WHEN g_AWARD_AUTO_RECOMMEND THEN l_award_mode := 'LINE';
	   ELSE l_Award_Status := null;
	END CASE;
 */
    IF p_mode = g_AWARD_QUOTE THEN
	   l_Award_mode := 'HEADER';
	ELSIF p_mode = g_AWARD_MULTIPLE_LINES THEN
	   l_award_mode := 'MULTIPLE_LINES';
	ELSIF p_mode = g_AWARD_LINE THEN
	   l_award_mode := 'LINE';
	ELSIF p_mode = g_AWARD_LINE_H THEN
	   l_award_mode := 'LINE';
	ELSIF p_mode = g_AWARD_GROUP THEN
	   l_award_mode := 'LINE';
        ELSIF p_mode = g_AWARD_GROUP_H THEN
           l_award_mode := 'LINE';
	ELSIF p_mode = g_AWARD_AUTO_RECOMMEND THEN
           l_award_mode := 'LINE';
    ELSIF p_mode = g_AWARD_OPTIMIZATION THEN
	   l_award_mode := 'LINE';
	ELSE l_award_mode := null;
     END IF;
--
IF p_neg_has_lines = 'Y' THEN -- FPK: CPA

/*
	large-auction-support changes
	rather than looping over all the lines, we will simply
	execute a single query
*/

	SELECT 	count(Line_number), sum(decode(award_status, 'AWARDED', 1, 0))
	INTO	l_total_lines, l_awarded_lines
	FROM 	pon_auction_item_prices_all
	WHERE 	auction_header_id = p_auction_id
	AND 	number_of_bids > 0
	AND 	group_type in ('LOT', 'LINE', 'GROUP_LINE');

	IF ((l_awarded_lines <> 0) AND (l_awarded_lines = l_total_lines) ) THEN
	   l_award_status := 'AWARDED';
	ELSIF (l_awarded_lines > 0) THEN
	   l_award_status := 'PARTIAL';
	END IF;
ELSE -- negotiation does not have lines
	BEGIN
      select 'AWARDED' -- it means an award decision was made
	  into l_award_status
	  from dual
	  where exists (select 1
	                from pon_bid_headers
	                where auction_header_id = p_auction_id
                    and bid_status = 'ACTIVE'
	                and award_status IN ('AWARDED', 'REJECTED'));
	  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     NULL; -- award_status is set to 'NO' in the beggining of the procedure.
	  END;

END IF; -- IF p_neg_has_lines = 'Y'

	UPDATE PON_Auction_HEADERS_all
	SET AWARD_STATUS = l_award_status,
	    award_mode = l_award_mode,
            award_date = p_award_date,
            last_updated_by = p_auctioneer_id
            -- modified after last update date check
            --award_approval_status = 'REQUIRED'
            --last_update_date = SYSDATE
	WHERE auction_header_id = p_auction_id ;

        UPDATE PON_AUCTION_HEADERS_ALL
        SET award_approval_status = 'REQUIRED'
        WHERE auction_header_id = p_auction_id
        AND nvl(award_approval_flag, 'N') = 'Y';
--
END update_auction_headers;
--
--
-- Updates the award_approval_status and sets to REQUIRED
-- since the award is modified, sets the upadated by column as well.
PROCEDURE update_award_agreement_amount
(
 p_auction_id    IN NUMBER,
 p_auctioneer_id IN NUMBER
)
IS
BEGIN
    -- Updates approval_status if approval flag is set
    UPDATE PON_AUCTION_HEADERS_ALL
    SET award_approval_status = 'REQUIRED'
    WHERE auction_header_id = p_auction_id
    AND nvl(award_approval_flag, 'N') = 'Y';
--
    -- Updates last update date etc since award is modified.
    UPDATE PON_Auction_HEADERS_all
    SET award_date =  SYSDATE,
    last_updated_by = p_auctioneer_id,
    last_update_date = SYSDATE
    WHERE auction_header_id = p_auction_id ;
--
END update_award_agreement_amount;
--
--
PROCEDURE bulk_update_pon_acceptances
( p_auction_header_id IN NUMBER,
  p_line_number 	  IN NUMBER,
  p_note_to_accepted  IN VARCHAR2,
  p_note_to_rejected  IN VARCHAR2,
  p_award_date    	  IN DATE,
  p_auctioneer_id	  IN NUMBER,
  p_mode              IN VARCHAR2
)
IS
BEGIN
   IF(p_line_number > 0 ) THEN
     IF (p_mode = g_AWARD_GROUP OR p_mode = g_AWARD_GROUP_H) THEN
	   -- Group Level Awards
	   -- Insert empty notes for group lines
	   -- Delete notes for a line
		 DELETE FROM pon_acceptances
		 WHERE auction_header_id = p_auction_header_id
		       AND line_number IN (SELECT line_number FROM pon_auction_item_prices_all
			                   WHERE parent_line_number = p_line_number
					   AND auction_header_id = p_auction_header_id);
		 INSERT INTO pon_acceptances (
		 	acceptance_id,
			auction_header_id,
		   	auction_line_number,
		        bid_number,
			line_number,
			acceptance_type,
			acceptance_date,
			reason,
			creation_date,
			created_by)
		 SELECT pon_acceptances_s.nextval,
		        bi.auction_header_id,
			bi.auction_line_number,
			bi.bid_number,
			bi.line_number,
			bi.award_status,
			p_award_date,
			null,
			p_award_date,
			p_auctioneer_id
		 FROM pon_bid_item_prices bi, pon_bid_headers bh, pon_auction_item_prices_all ai
		  WHERE bi.auction_header_id = ai.auction_header_id
		        AND ai.line_number = bi.line_number
		        AND (bi.award_status = 'AWARDED'
			     OR bi.award_status = 'REJECTED')
			AND bi.bid_number = bh.bid_number
			AND bh.bid_status = 'ACTIVE'
			AND ai.auction_header_id = p_auction_header_id
			AND ai.parent_line_number = p_line_number;
--
  	  ELSE
	   -- Award Line Mode
	   -- Delete notes for a line
		 DELETE FROM pon_acceptances
		 WHERE auction_header_id = p_auction_header_id
		       AND line_number = p_line_number;
		 INSERT INTO pon_acceptances (
		 	acceptance_id,
			auction_header_id,
		   	auction_line_number,
		    bid_number,
			line_number,
			acceptance_type,
			acceptance_date,
			reason,
			creation_date,
			created_by)
		 SELECT pon_acceptances_s.nextval,
		    bi.auction_header_id,
			bi.auction_line_number,
			bi.bid_number,
			bi.line_number,
			bi.award_status,
			p_award_date,
			decode (bi.award_status,
			       'AWARDED', p_note_to_accepted,
			       'REJECTED', p_note_to_rejected,
					null),
			SYSDATE,
			p_auctioneer_id
		 FROM pon_bid_item_prices bi, pon_bid_headers bh
		  WHERE bi.auction_header_id = p_auction_header_id
		        AND bi.line_number = p_line_number
		        AND (bi.award_status = 'AWARDED'
					OR bi.award_status = 'REJECTED')
				AND bi.bid_number = bh.bid_number
				AND bh.bid_status = 'ACTIVE';
	  END IF;
   ELSE
   -- Header Level Award
   -- Delete notes for an auction
	 DELETE FROM pon_acceptances
	 WHERE auction_header_id = p_auction_header_id;
--
	 INSERT INTO pon_acceptances (
	 	acceptance_id,
		auction_header_id,
	   	auction_line_number,
	    bid_number,
		line_number,
		acceptance_type,
		acceptance_date,
		reason,
		creation_date,
		created_by)
	 SELECT pon_acceptances_s.nextval,
	    bi.auction_header_id,
		bi.auction_line_number,
		bi.bid_number,
		bi.line_number,
		bi.award_status,
		p_award_date,
		decode (bi.award_status,
		       'AWARDED', p_note_to_accepted,
		       'REJECTED', p_note_to_rejected,
				null),
		p_award_date,
		p_auctioneer_id
	 FROM pon_bid_item_prices bi, pon_bid_headers bh, pon_auction_item_prices_all ai
	  WHERE bi.auction_header_id = p_auction_header_id
	        AND (bi.award_status = 'AWARDED'
				OR bi.award_status = 'REJECTED')
			AND bi.bid_number = bh.bid_number
			AND bh.bid_status = 'ACTIVE'
			AND bi.auction_header_id = ai.auction_header_id
			AND bi.line_number = ai.line_number
			AND ai.group_type IN ('LOT', 'LINE', 'GROUP_LINE');
   END IF;
END bulk_update_pon_acceptances;
--
--
FUNCTION get_award_status (award_outcome IN VARCHAR2)
RETURN VARCHAR2
IS
--
l_award_status VARCHAR2(20);
BEGIN
/*
	CASE award_outcome
	   WHEN g_AWARD_OUTCOME_WIN THEN l_Award_Status := 'AWARDED';
	   WHEN g_AWARD_OUTCOME_LOSE THEN l_Award_Status := 'REJECTED';
	   WHEN g_AWARD_OUTCOME_NOAWARD THEN l_Award_Status := 'REJECTED';
	   ELSE l_Award_Status := null;
	END CASE;
*/
	IF award_outcome = g_AWARD_OUTCOME_WIN THEN
	   l_Award_Status := 'AWARDED';
	ELSIF award_outcome = g_AWARD_OUTCOME_LOSE THEN
	   l_Award_Status := 'REJECTED';
	ELSIF award_outcome = g_AWARD_OUTCOME_NOAWARD THEN
	   l_Award_Status := 'REJECTED';
	ELSE l_Award_Status := null;
	END IF;

	RETURN l_award_status;
--
END get_award_status;
--
--
PROCEDURE update_unawarded_acceptances
( p_auction_header_id IN NUMBER,
  p_line_number 	  IN NUMBER,
  p_note_to_rejected  IN VARCHAR2,
  p_award_date    	  IN DATE,
  p_auctioneer_id	  IN NUMBER
)
IS
BEGIN
   -- Award Line Mode
   -- Delete rejected notes for a line
	 DELETE FROM pon_acceptances
	 WHERE auction_header_id = p_auction_header_id
	       AND line_number = p_line_number
		   AND acceptance_type = 'REJECTED';
   -- insert rejection note for all rejected suppliers
	 INSERT INTO pon_acceptances (
	 	acceptance_id,
		auction_header_id,
	   	auction_line_number,
	    bid_number,
		line_number,
		acceptance_type,
		acceptance_date,
		reason,
		creation_date,
		created_by)
	 SELECT pon_acceptances_s.nextval,
	    bi.auction_header_id,
		bi.auction_line_number,
		bi.bid_number,
		bi.line_number,
		'REJECTED',
		p_award_date,
        p_note_to_rejected,
		p_award_date,
		p_auctioneer_id
	 FROM pon_bid_item_prices bi, pon_bid_headers bh
	  WHERE bi.auction_header_id = p_auction_header_id
	        AND bi.line_number = p_line_number
	        AND nvl(bi.award_status, 'NO') <> 'AWARDED' -- can be REJECTED/ NO
			AND bi.bid_number = bh.bid_number
			AND bh.bid_status = 'ACTIVE';
END update_unawarded_acceptances;
--
--
PROCEDURE update_notes_for_bid
(
  p_bid_number  IN NUMBER,
  p_note_to_supplier  IN VARCHAR2,
  p_internal_note IN VARCHAR2,
  p_auctioneer_id IN NUMBER
)
IS
BEGIN
	UPDATE pon_bid_headers
	SET Internal_note = p_internal_note,
		note_to_supplier = p_note_to_supplier
	WHERE bid_number = p_bid_number;
END update_notes_for_bid;
--
--
PROCEDURE clear_draft_awards
(
  p_auction_header_id IN NUMBER,
  p_line_number  IN NUMBER,
  p_award_date IN DATE,
  p_auctioneer_id IN NUMBER,
  p_neg_has_lines IN VARCHAR2 -- FPK: CPA
)
IS
BEGIN

 IF p_neg_has_lines = 'Y' THEN -- FPK: CPA


   IF (p_line_number IS NULL OR p_line_number <= 0 )THEN
         -- Header level awards
         --Update award status to REJECTED for all the bids
	 UPDATE pon_bid_item_prices
	 SET award_status = 'REJECTED',
	     award_quantity = NULL,
	     award_date = p_award_date,
	     last_update_date = p_award_date,
	     last_updated_by = p_auctioneer_id,
	     award_shipment_number = NULL,
	     award_price = NULL
	 WHERE bid_number IN (
	 	   	      SELECT bid_number
			      FROM pon_bid_headers
			      WHERE auction_header_id = p_auction_header_id
			      AND bid_status = 'ACTIVE'
			     );

	 -- Delete All Awards since it is a header-level awarding
	 DELETE FROM pon_acceptances
	 WHERE auction_header_id = p_auction_header_id;

         -- reset the award mode at auction item level
         UPDATE pon_auction_item_prices_all
         SET award_mode = null
         WHERE auction_header_id = p_auction_header_id;
   ELSE
        -- Group Level awards need to be rejected first
         --Update award status to REJECTED for all the bids
         UPDATE pon_bid_item_prices
         SET award_status = 'REJECTED',
             award_quantity = NULL,
             award_date = p_award_date,
             last_update_date = p_award_date,
             last_updated_by = p_auctioneer_id,
             award_shipment_number = NULL,
             award_price = NULL
         WHERE bid_number IN (
                              SELECT bid_number
                              FROM pon_bid_headers
                              WHERE auction_header_id = p_auction_header_id
                              AND bid_status = 'ACTIVE'
                             )
             AND line_number IN (SELECT line_number
                                 FROM pon_auction_item_prices_all
                                 WHERE auction_header_id = p_auction_header_id
                                 AND (line_number = p_line_number
                                      OR parent_line_number = p_line_number));

         -- Delete All group line awards since it is a group-level awarding
         DELETE FROM pon_acceptances
         WHERE auction_header_id = p_auction_header_id
         AND line_number IN (SELECT line_number
                                 FROM pon_auction_item_prices_all
                                 WHERE auction_header_id = p_auction_header_id
                                 AND parent_line_number = p_line_number);
   END IF;
 END IF;

   /* FPK: CPA
   Reset notes for all the bids and update all active bids award status to REJECTED no matter
   if negotiation has lines or not. Previoulsy award_status was not being updated to REJECTED when
   negotiation had lines, but there is no harm in doing so at this point, as award_status will be
   updated later in update_single_bid_header procedure. */

		 UPDATE pon_bid_headers
		 SET  award_status = 'REJECTED',
	          note_to_supplier = NULL,
		      internal_note = NULL,
		      po_agreed_amount = NULL,
		      last_update_date = SYSDATE,
		      last_updated_by = p_auctioneer_id
		 WHERE auction_header_id = p_auction_header_id
		 AND bid_status = 'ACTIVE';
END clear_draft_awards;
--
--
--
--
PROCEDURE clear_awards_recommendation
(
  p_auction_header_id NUMBER,
  p_award_date DATE,
  p_auctioneer_id IN NUMBER
)
IS
BEGIN
--Update award status to REJECTED for all the bids
	 UPDATE pon_bid_item_prices
	 SET award_status = 'REJECTED',
	     award_quantity = NULL,
		 award_date = p_award_date,
		 last_update_date = SYSDATE,
		 last_updated_by = p_auctioneer_id,
                 award_price = NULL
	 WHERE bid_number IN (
	 	SELECT bid_number
	        FROM pon_bid_headers
		WHERE auction_header_id = p_auction_header_id
		AND bid_status = 'ACTIVE'
		);
--reset notes for all the bids
	 UPDATE pon_bid_headers
	 SET po_agreed_amount = NULL,
	     last_update_date = SYSDATE,
	     last_updated_by = p_auctioneer_id
	 WHERE bid_number IN (
	 	 SELECT bid_number
		 FROM pon_bid_headers
		 WHERE auction_header_id = p_auction_header_id
		 AND bid_status = 'ACTIVE'
		 );
END clear_awards_recommendation;

--
--
----------------------------------------------------------------
-- handles accepting an AutoAward Scenario
----------------------------------------------------------------
--
PROCEDURE accept_award_scenario
(
   p_scenario_id         IN  NUMBER,
   p_auctioneer_id    IN  NUMBER,
   p_last_update_date IN  DATE,
   x_status           OUT NOCOPY VARCHAR2
 )
  IS

     l_auction_header_id NUMBER;
     l_mode VARCHAR2(50);
     l_batch_id NUMBER;
     l_num_of_non_shortlisted_supp NUMBER;
BEGIN

   -- retrieve auction header id and batch id
   BEGIN
      SELECT COUNT(DISTINCT pbh.bid_number)
	INTO l_num_of_non_shortlisted_supp
	FROM pon_optimize_results por, pon_bid_headers pbh
	WHERE por.bid_number = pbh.bid_number
	AND pbh.shortlist_flag = 'N'
        AND por.scenario_id = p_scenario_id;

      IF (l_num_of_non_shortlisted_supp > 0) THEN
	 x_status := 'NOT_SHORTLISTED';
	 RETURN;
      END IF;

      SELECT auction_header_id, pon_auction_summary_s.NEXTVAL
	INTO l_auction_header_id, l_batch_id
	FROM pon_optimize_scenarios
	WHERE scenario_id = p_scenario_id;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      x_status := 'FAILURE';
      RETURN;
   END;

   l_mode := g_AWARD_OPTIMIZATION;

   -- insert award results into interface table
   INSERT into pon_auction_summary
     (batch_id,
      auction_id,
      bid_number,
      line_number,
      award_quantity,
      award_shipment_number)
     SELECT
     l_batch_id,
     l_auction_header_id,
     por.bid_number,
     por.line_number,
     por.award_quantity,
     por.award_shipment_number
     FROM pon_optimize_results por, pon_auction_item_prices_all paip,
          pon_auction_headers_all pah,
          pon_bid_item_prices pbip
     WHERE pah.auction_header_id = l_auction_header_id
     AND   pah.auction_header_id = paip.auction_header_id
     AND   por.bid_number = pbip.bid_number
     AND   por.line_number = pbip.line_number
     AND   por.scenario_id = p_scenario_id
     AND   paip.line_number = por.line_number;


   -- save the award result
   save_award_recommendation(l_batch_id, p_auctioneer_id, p_last_update_date, l_mode, x_status);

   IF (x_status = 'FAILURE') THEN
     RETURN;
   END IF;

   -- unset the accepted date of the previously accepted scenario
   UPDATE pon_optimize_scenarios
     SET accepted_date = NULL
     WHERE accepted_date IS NOT NULL
       AND auction_header_id= l_auction_header_id;

   -- set accepted date of the accepted scenario
   UPDATE pon_optimize_scenarios
     SET accepted_date = SYSDATE,
     last_update_date = SYSDATE,
     last_updated_by = p_auctioneer_id
     WHERE scenario_id = p_scenario_id;

   -- clean up inteface table
   DELETE FROM pon_auction_summary
     WHERE batch_id = l_batch_id;

END accept_award_scenario;

--
--
----------------------------------------------------------------
-- procedure added by snatu on 08/15/03
-- handles awarding in FPJ for system recommended awards
----------------------------------------------------------------
--
PROCEDURE save_award_recommendation
(
   p_batch_id         IN  NUMBER,
   p_auctioneer_id    IN  NUMBER,
   p_last_update_date IN  DATE,
   p_mode             IN  VARCHAR2,
   x_status           OUT NOCOPY VARCHAR2
)
IS
CURSOR c_reco_awards (c_batch_id NUMBER) IS
  SELECT
        pas.auction_id,
	pas.line_number,
        pas.bid_number,
        decode(p_mode,
	   g_AWARD_OPTIMIZATION,  decode(ai.order_type_lookup_code, 'RATE',  decode(ai.quantity, NULL, NULL, pas.award_quantity), 'QUANTITY', decode(ai.quantity, NULL, NULL, pas.award_quantity), pas.award_quantity),
	   decode(ai.order_type_lookup_code, 'RATE',  decode(ai.quantity, NULL, NULL, pas.award_quantity), 'QUANTITY', decode(ai.quantity, NULL, NULL, pas.award_quantity), pas.award_quantity))award_quantity,
	pas.bid_price,
	pas.trading_partner_id,
	pas.trading_partner_contact_id,
	pas.batch_id,
        ai.group_type,
        pas.award_shipment_number
  FROM pon_auction_summary pas
       , pon_auction_item_prices_all ai
       , pon_auction_headers_all ah
  WHERE
    pas.award_quantity >0
    AND pas.batch_id = c_batch_id
    AND ah.auction_header_id = pas.auction_id
    AND ai.auction_header_id = pas.auction_id
    AND ai.line_number = pas.line_number
  ORDER BY
	pas.line_number;
  l_reco_awards_rec c_reco_awards%ROWTYPE;
--
  l_award_lines t_award_lines;
  l_matrix_index        NUMBER;
  l_auction_header_id   NUMBER;
  l_current_bid_number  NUMBER;
  l_current_update_date DATE;
  l_award_date          DATE;

BEGIN

 l_current_bid_number := null;
 l_matrix_index := 0;
 l_award_date := SYSDATE;
--
 -- Need to set award quantity and award_status and award_date
  OPEN c_reco_awards (p_batch_id);
  LOOP
	  fetch c_reco_awards into l_reco_awards_rec;
	  EXIT WHEN c_reco_awards%NOTFOUND;
	  -- Get Auction Header Id only once
	  IF (l_matrix_index = 0) THEN
	  	 l_auction_header_id := l_reco_awards_rec.auction_id;
	  END IF;

--DBMS_OUTPUT.PUT_LINE('l_auction_header_id' || l_auction_header_id);
	 -- Construct Matrix for the awarded bids
  	  l_matrix_index := l_matrix_index + 1;
	  l_award_lines(l_matrix_index).bid_number := l_reco_awards_rec.bid_number;
	  l_award_lines(l_matrix_index).line_number := l_reco_awards_rec.line_number;
	  l_award_lines(l_matrix_index).award_status := 'AWARDED';
	  l_award_lines(l_matrix_index).award_quantity := l_reco_awards_rec.award_quantity;
	  l_award_lines(l_matrix_index).award_date := l_award_date;
          l_award_lines(l_matrix_index).group_type := l_reco_awards_rec.group_type;
          l_award_lines(l_matrix_index).award_shipment_number := l_reco_awards_rec.award_shipment_number;
  END LOOP;

	  clear_awards_recommendation (l_auction_header_id, l_award_date, p_auctioneer_id);
	  update_bid_item_prices(l_auction_header_id,l_award_lines,p_auctioneer_id, p_mode);
	  /* FPK: CPA p_neg_has_lines parameter hardcoded to 'Y' as save_award_recommendation
          procedure will only be called if negotiation has lines */
          update_bid_headers(l_auction_header_id, p_auctioneer_id, t_emptytbl, 'Y');
	  update_auction_item_prices(l_auction_header_id,null, l_award_date, p_auctioneer_id, p_mode);
	  /* FPK: CPA p_neg_has_lines parameter hardcoded to 'Y' as save_award_recommendation
          procedure will only be called if negotiation has lines */
	  update_auction_headers(l_auction_header_id, p_mode, l_award_date, p_auctioneer_id, 'Y');

	  bulk_update_pon_acceptances(
	  			l_auction_header_id,
	  			null, null, null,
				l_award_date, p_auctioneer_id, p_mode);
--
/*  check if the auction has been modified by some other user
    If it has been modified, status returns failure
    else this is the only user modifying hte auction
    changes are committed to the database in the middle tier
*/
   IF (is_auction_not_updated (l_auction_header_id, p_last_update_date)) THEN
      x_status := 'SUCCESS';
	  -- update the last update date
	  UPDATE PON_Auction_HEADERS_all
	  SET last_update_date = SYSDATE
	  WHERE auction_header_id = l_auction_header_id;
	  --
   ELSE
      x_status := 'FAILURE';
   END IF;
--
END save_award_recommendation;


--
--
----------------------------------------------------------------
-- handles copying of a scenario
----------------------------------------------------------------

PROCEDURE copy_award_scenario
(
  p_scenario_id         IN NUMBER,
  p_user_id	        IN NUMBER,
  p_cost_scenario_flag  IN VARCHAR2,
  x_cost_scenario_id	OUT NOCOPY NUMBER,
  x_status              OUT NOCOPY VARCHAR2
)
IS

l_fnd_user_id NUMBER;
l_next_scenario_number NUMBER;
l_num_constraints NUMBER;
l_num_bid_classes NUMBER;
l_auction_header_id NUMBER;
l_dummy_scenario_number NUMBER;
l_new_scenario_id NUMBER;

BEGIN

  -- Derive fnd_user_id from tp_id
  -- This will not fail if more than one user setup w/ same buyer.
  -- But, this will reurn any of the matched user id in such cases
  BEGIN
          SELECT USER_ID
          INTO l_fnd_user_id
          FROM FND_USER
          WHERE PERSON_PARTY_ID = p_user_id
          AND NVL(END_DATE,SYSDATE+1) > SYSDATE;
  EXCEPTION
     WHEN TOO_MANY_ROWS THEN
         IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
               IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                         FND_LOG.string(log_level => FND_LOG.level_unexpected,
                                        module    => 'pon.plsql.pon_award_pkg.copy_award_scenario',
                                        message   => 'Multiple Users found for person_party_id:'||p_user_id);
               END IF;
         END IF;

         SELECT USER_ID
         INTO l_fnd_user_id
         FROM FND_USER
         WHERE PERSON_PARTY_ID = p_user_id
         AND NVL(END_DATE,SYSDATE+1) > SYSDATE
         AND ROWNUM = 1;
  END;

  -- derive auction_header_id
  select auction_header_id into l_auction_header_id
  from pon_optimize_scenarios
  where scenario_id = p_scenario_id;

  -- store the next scenario id in a local variable
  select pon_optimize_scenarios_s.nextval
  into l_new_scenario_id from dual;

  IF(p_cost_scenario_flag =  'Y') THEN

 	-- we donot display this number any place
	-- all we want is to have a unique combination
	l_next_scenario_number := l_new_scenario_id;

  ELSE
  	select max(scenario_number) + 1
        into l_next_scenario_number
	from pon_optimize_scenarios
	where auction_header_id = l_auction_header_id
	and   (cost_scenario_flag is null or cost_scenario_flag <> 'Y');

  END IF;

  --first copy the scenario
  INSERT INTO PON_OPTIMIZE_SCENARIOS(
	  	auction_header_id,
	  	scenario_id,
	  	scenario_name,
                scenario_number,
	  	objective_code,
	  	status,
	  	price_type,
	  	internal_note,
	  	updated_tp_contact_id,
	  	last_tp_update_date,
	  	creation_date,
	  	created_by,
	  	last_update_date,
	  	last_updated_by,
	  	last_update_login,
		cost_scenario_flag,
		parent_scenario_id,
		constraint_priority_type)
   SELECT       auction_header_id,
	        l_new_scenario_id,
	  	scenario_name,
		l_next_scenario_number,
	  	objective_code,
	  	'NOT_RUN',
	  	price_type,
	  	internal_note,
	  	p_user_id,
	  	sysdate,
	  	sysdate,
	  	l_fnd_user_id,
	  	sysdate,
	  	l_fnd_user_id,
	  	l_fnd_user_id,
		p_cost_scenario_flag,
		decode(p_cost_scenario_flag, 'Y', p_scenario_id, to_number(null)),
		nvl(constraint_priority_type, 'MANDATORY')
   FROM         pon_optimize_scenarios
   WHERE        scenario_id = p_scenario_id;

   -- copy the constraints

   -- make sure there is at least 1 row to prevent no data found exception
   select count(*) into l_num_constraints
   from pon_optimize_constraints
   where scenario_id = p_scenario_id;

   IF (l_num_constraints > 0) THEN

     INSERT INTO PON_OPTIMIZE_CONSTRAINTS(
	          scenario_id,
	          sequence_number,
	          auction_header_id,
	          constraint_type,
	          line_number,
	          min_amount,
	  	  max_amount,
	          amount_type,
		  min_quantity,
	          max_quantity,
	          quantity_cutoff,
	          price_cutoff,
		  split_award_flag,
	          integral_qty_award_flag,
	          excluded_flag,
	          from_date,
	          to_date,
	          min_score,
	          supp_classification,
	          attr_sequence_number,
	          attr_group_name,
	          trading_partner_id,
	          trading_partner_contact_id,
	          vendor_site_id,
	          creation_date,
	  	  created_by,
	  	  last_update_date,
	  	  last_updated_by,
	  	  last_update_login,
 		 MIN_MAX_AMOUNT_PRIORITY
		,MIN_MAX_AMOUNT_COST
		,MIN_MAX_AMOUNT_INFEAS_FLAG
		,MIN_MAX_QUANTITY_PRIORITY
		,MIN_MAX_QUANTITY_COST
		,MIN_MAX_QUANTITY_INFEAS_FLAG
		,QUANTITY_CUTOFF_PRIORITY
		,QUANTITY_CUTOFF_COST
		,QUANTITY_CUTOFF_INFEAS_FLAG
		,PRICE_CUTOFF_PRIORITY
		,PRICE_CUTOFF_COST
		,PRICE_CUTOFF_INFEAS_FLAG
		,SPLIT_AWARD_PRIORITY
		,SPLIT_AWARD_INFEAS_FLAG
		,SPLIT_AWARD_COST
		,INTEGRAL_QTY_AWARD_PRIORITY
		,INTEGRAL_QTY_AWARD_INFEAS_FLAG
		,INTEGRAL_QTY_AWARD_COST
		,EXCLUDED_SUPPLIER_PRIORITY
		,EXCLUDED_SUPPLIER_INFEAS_FLAG
		,EXCLUDED_SUPPLIER_COST
		,PROMISED_DATE_PRIORITY
		,PROMISED_DATE_COST
		,PROMISED_DATE_INFEAS_FLAG
		,MIN_SCORE_PRIORITY
		,MIN_SCORE_COST
		,MIN_SCORE_INFEAS_FLAG)
     SELECT       l_new_scenario_id,
	          sequence_number,
	          auction_header_id,
	          constraint_type,
	          line_number,
	          min_amount,
	  	  max_amount,
	          amount_type,
		  min_quantity,
	          max_quantity,
	          quantity_cutoff,
	          price_cutoff,
		  split_award_flag,
	          integral_qty_award_flag,
	          excluded_flag,
	          from_date,
	          to_date,
	          min_score,
	          supp_classification,
	          attr_sequence_number,
	          attr_group_name,
	          trading_partner_id,
	          trading_partner_contact_id,
	          vendor_site_id,
	          sysdate,
	  	  l_fnd_user_id,
	  	  sysdate,
	  	  l_fnd_user_id,
	  	  l_fnd_user_id,
		 MIN_MAX_AMOUNT_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
		,MIN_MAX_QUANTITY_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
		,QUANTITY_CUTOFF_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
		,PRICE_CUTOFF_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
		,SPLIT_AWARD_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
		,INTEGRAL_QTY_AWARD_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
		,EXCLUDED_SUPPLIER_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
		,PROMISED_DATE_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
		,MIN_SCORE_PRIORITY
		,TO_NUMBER(NULL)
		,TO_CHAR(NULL)
     FROM         pon_optimize_constraints
     WHERE        scenario_id = p_scenario_id;

   END IF;

   -- copy the bid class information
   -- make sure a row exists first to prevent no data found exception
   select count(*) into l_num_bid_classes
   from pon_optimize_bid_class
   where scenario_id = p_scenario_id;

   IF (l_num_bid_classes > 0) THEN
     INSERT INTO PON_OPTIMIZE_BID_CLASS(
  	          scenario_id,
  	          sequence_number,
	          bid_number,
	          creation_date,
	  	  created_by,
	  	  last_update_date,
	  	  last_updated_by,
	  	  last_update_login
     )
     SELECT       l_new_scenario_id,
	          sequence_number,
	          bid_number,
	          sysdate,
	  	  l_fnd_user_id,
	  	  sysdate,
	  	  l_fnd_user_id,
	  	  l_fnd_user_id
     FROM         pon_optimize_bid_class
     WHERE        scenario_id = p_scenario_id;
  END IF;

  x_status := 'SUCCESS';

  IF (p_cost_scenario_flag = 'Y') THEN

  	-- populate this value only when we are
	-- copying a scenario to do cost of constriant
	-- calculation

  	x_cost_scenario_id := l_new_scenario_id;
  ELSE

	-- else, set it to some dummy value

	x_cost_scenario_id := -9999;

  END IF;


EXCEPTION
   when others then
   x_status := 'FAILURE';
   raise;
END copy_award_scenario;



PROCEDURE batch_award_spreadsheet
(
   p_auction_header_id IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_auctioneer_id     IN  NUMBER,
   p_last_update_date  IN  DATE,
   x_status            OUT NOCOPY VARCHAR2
)
IS

 l_award_date DATE;

BEGIN
	 l_award_date := SYSDATE;

	 update_auction_headers(p_auction_header_id, p_mode, l_award_date, p_auctioneer_id, 'Y');
--
	/*  check if the auction has been modified by some other user
	    If it has been modified, status returns failure
	    else this is the only user modifying the auction
	*/

	   IF (is_auction_not_updated (p_auction_header_id, p_last_update_date)) THEN
	      x_status := 'SUCCESS';
		  -- update the last update date
		  UPDATE pon_Auction_headers_all
		  SET last_update_date = SYSDATE
		  WHERE auction_header_id = p_auction_header_id;
	  --
		 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.BATCH_AWARD_SPREADSHEET.AUCTION_ID:'
				  || p_auction_header_id,'SUCCEEDED.');
		END IF;
      --
   	ELSE
      	    x_status := 'FAILURE';
		--
		IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.BATCH_AWARD_SPREADSHEET.AUCTION_ID:'
				 || p_auction_header_id,'FAILED.');
		END IF;
		--
	   END IF;


END BATCH_AWARD_SPREADSHEET;
--
--
----------------------------------------------------------------
-- procedure added by snatu on 08/15/03
-- handles awarding in FPJ for awarding through spreadsheet
----------------------------------------------------------------
--
--
PROCEDURE save_award_spreadsheet
(
   p_batch_id          IN  NUMBER,
   p_auction_header_id IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_auctioneer_id     IN  NUMBER,
   p_last_update_date  IN  DATE,
   p_batch_enabled     IN  VARCHAR2,
   p_is_xml_upload     IN  VARCHAR2,
   x_status            OUT NOCOPY VARCHAR2
)
IS
CURSOR c_spsheet_awards (c_batch_id NUMBER, c_auction_header_id NUMBER, c_is_xml_upload VARCHAR2) IS
--Query retrives rows ordered in way exported in spreadhsheet
  SELECT
	aii.auction_header_id,
	aii.auction_line_number,
	aii.bid_number,
	DECODE (nvl(aii.award_status,'N'),'N',null,
		    DECODE (ai.ORDER_TYPE_LOOKUP_CODE,
			       'QUANTITY', aii.award_quantity,
                               'RATE' , decode (ai.purchase_basis , 'TEMP LABOR' , aii.award_quantity ,1) ,
		   		   1) )award_quantity,
	decode (nvl(aii.award_status,'N'),'Y', g_AWARD_OUTCOME_WIN,
		   	g_AWARD_OUTCOME_LOSE) award_outcome,
	aii.awardreject_reason,
        ai.group_type,
        aii.award_shipment_number
  FROM pon_award_items_interface aii,
  	   pon_auction_item_prices_all ai,
  	   pon_bid_item_prices bi,
           pon_auction_headers_all pah
  WHERE
	aii.batch_id = c_batch_id
	AND aii.auction_header_id = c_auction_header_id
	AND aii.auction_header_id = ai.auction_header_id
	AND aii.AUCTION_LINE_NUMBER = ai.LINE_NUMBER
	AND bi.bid_number = aii.bid_number
	AND bi.line_number = aii.AUCTION_LINE_NUMBER
        AND pah.auction_header_id = aii.auction_header_id
  ORDER BY
	ai.disp_line_number asc,
	decode(c_is_xml_upload, 'Y', decode(pah.bid_ranking, 'MULTI_ATTRIBUTE_SCORING', decode(nvl(bi.PRICE,0), 0, 0, nvl(bi.TOTAL_WEIGHTED_SCORE,0)/bi.PRICE), decode(bi.PRICE,0,0, 1/bi.PRICE)), decode(bi.PRICE, 0, 0, 1/bi.PRICE)) desc, bi.PUBLISH_DATE asc;
  l_spsheet_awards_rec c_spsheet_awards%ROWTYPE;
--
  l_award_lines         t_award_lines;
  l_matrix_index        NUMBER;
  l_size    	        NUMBER;
  l_current_bid_number  NUMBER;
  l_current_update_date DATE;
  l_award_date          DATE;
  l_curr_line_num       NUMBER;
--
  TYPE BID_LIST_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_bid_list                     BID_LIST_TYPE;
  TYPE ITEM_LIST_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_item_list                    ITEM_LIST_TYPE;
  TYPE ACCEPT_LIST_TYPE IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  l_accept_list                  ACCEPT_LIST_TYPE;
  TYPE REJECT_LIST_TYPE IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  l_reject_list                  REJECT_LIST_TYPE;
--
BEGIN

 l_matrix_index := 0;
 l_award_date := SYSDATE;
 l_curr_line_num := NULL;
--

--  Get distinct lines awarded/rejected
  SELECT DISTINCT auction_line_number BULK COLLECT INTO l_item_list
  FROM   pon_award_items_interface
  WHERE	 batch_id = p_batch_id
  AND    auction_header_id = p_auction_header_id;

-- Get distinct bids awarded/rejected
  SELECT DISTINCT bid_number BULK COLLECT INTO l_bid_list
  FROM   pon_award_items_interface
  WHERE	 batch_id = p_batch_id
  AND   auction_header_id = p_auction_header_id;
--
 -- Need to set award quantity and award_status and award_date

  OPEN c_spsheet_awards (p_batch_id, p_auction_header_id, p_is_xml_upload);

      LOOP --{
	  fetch c_spsheet_awards into l_spsheet_awards_rec;
	  EXIT WHEN c_spsheet_awards%NOTFOUND;
	  -- Construct Matrix in any case (WIN/LOSR)
	  l_matrix_index := l_matrix_index +1;
	  l_award_lines(l_matrix_index).bid_number := l_spsheet_awards_rec.bid_number;
	  l_award_lines(l_matrix_index).line_number := l_spsheet_awards_rec.auction_line_number;
	  l_award_lines(l_matrix_index).award_status := get_award_status(l_spsheet_awards_rec.award_outcome);
	  l_award_lines(l_matrix_index).award_date := l_award_date;
	  l_award_lines(l_matrix_index).award_quantity := l_spsheet_awards_rec.award_quantity;
          l_award_lines(l_matrix_index).group_type :=  l_spsheet_awards_rec.group_type;
          l_award_lines(l_matrix_index).award_shipment_number := l_spsheet_awards_rec.award_shipment_number;

-- Update notes per line for awarded / rejected suppleirs
	  IF (l_curr_line_num IS NULL ) THEN
	    l_curr_line_num := l_spsheet_awards_rec.auction_line_number;
	    l_accept_list(l_curr_line_num) := NULL;
	    l_reject_list(l_curr_line_num) := NULL;
	  END IF;
	  IF (l_curr_line_num <> l_spsheet_awards_rec.auction_line_number ) THEN
	  -- new line ; update curr line
	    l_curr_line_num := l_spsheet_awards_rec.auction_line_number;
	    l_accept_list(l_curr_line_num) := NULL;
	    l_reject_list(l_curr_line_num) := NULL;
	  END IF ;
--
	  IF (l_accept_list(l_curr_line_num) IS NULL
	      AND l_award_lines(l_matrix_index).award_status = 'AWARDED') THEN
	       l_accept_list(l_curr_line_num) := l_spsheet_awards_rec.awardreject_reason;
	  END IF ;
--
	  IF (l_reject_list(l_curr_line_num) IS NULL
	      AND l_award_lines(l_matrix_index).award_status = 'REJECTED') THEN
		  l_reject_list(l_curr_line_num) := l_spsheet_awards_rec.awardreject_reason;
	  END IF ;
--
	END LOOP;

	--}

--
	-- this procedure updates all the bid lines one-by-one

	  update_bid_item_prices(p_auction_header_id,l_award_lines,p_auctioneer_id, p_mode);

	  l_size := l_bid_list.count;

	  FOR l_index IN 1..l_size LOOP

		-- this procedure updates the award_status
		-- for all the bids at the bid-header level
		-- we don't need to invoke this over here -> this should be invoked after all
		-- batches are exhausted

	  	update_single_bid_header(l_bid_list(l_index),p_auctioneer_id);

	  END LOOP;

	  l_size := l_item_list.count;

	  FOR l_index IN 1..l_size LOOP

             update_auction_item_prices(p_auction_header_id, l_item_list(l_index), l_award_date, p_auctioneer_id, p_mode);

             -- update acceptances per auction line
	     bulk_update_pon_acceptances (
	          p_auction_header_id, l_item_list(l_index),
		  l_accept_list(l_item_list(l_index)), l_reject_list(l_item_list(l_index)),
		  l_award_date, p_auctioneer_id, p_mode);

	  END LOOP;

	 /* FPK: CPA p_neg_has_lines parameter hardcoded to 'Y' as save_award_spreadsheet
        procedure will only be called if negotiation has lines */

	-- this procedure loops over all the lines to determine the auction-header-level
	-- award-status etc.

	if(p_batch_enabled = 'N') then --{

		update_auction_headers(p_auction_header_id, p_mode, l_award_date, p_auctioneer_id, 'Y');
--
	/*  check if the auction has been modified by some other user
	    If it has been modified, status returns failure
	    else this is the only user modifying the auction
	*/

	   IF (is_auction_not_updated (p_auction_header_id, p_last_update_date)) THEN
	      x_status := 'SUCCESS';
		  -- update the last update date
		  UPDATE pon_Auction_headers_all
		  SET last_update_date = SYSDATE
		  WHERE auction_header_id = p_auction_header_id;
	  --
		 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.SAVE_AWARD_SPREADSHEET.AUCTION_ID:'
				  || p_auction_header_id,'SUCCEEDED.');
		END IF;
      --
   	ELSE
      	    x_status := 'FAILURE';
		--
		IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, 'PON_AWARD_PKG.SAVE_AWARD_SPREADSHEET.AUCTION_ID:'
				 || p_auction_header_id,'FAILED.');
		END IF;
		--
	   END IF;

	else

                -- delete interface data
                delete from pon_award_items_interface
                where batch_id = p_batch_id;

		x_status := 'SUCCESS';

	end if; --}

--
END save_award_spreadsheet;
--
--
FUNCTION is_auction_not_updated (
  p_auction_header_id NUMBER,
  p_last_update_date DATE
) RETURN BOOLEAN
IS
l_current_update_date DATE;
BEGIN
    SELECT last_update_date INTO l_current_update_date
    FROM pon_auction_headers_all
	WHERE auction_header_id = p_auction_header_id;
	IF (l_current_update_date = p_last_update_date) THEN
	   RETURN TRUE;
	ELSE
	   RETURN FALSE;
	END IF;
END  is_auction_not_updated;
--
PROCEDURE toggle_shortlisting
( p_user_id    IN NUMBER
, p_bid_number IN NUMBER
, p_event      IN VARCHAR2
)
IS

l_person_id NUMBER;

BEGIN
  -- This will never fail even if more than one user setup w/ same buyer
  -- as always there will be one record for an user_id in fnd_user
  SELECT PERSON_PARTY_ID INTO l_person_id
  FROM FND_USER
  WHERE user_id = p_user_id;

  IF (p_event = 'NOT_SHORTLIST') THEN
    UPDATE PON_BID_HEADERS
    SET SHORTLIST_FLAG = 'N'
      , LAST_UPDATE_DATE = SYSDATE
      , LAST_UPDATED_BY = p_user_id
      , SHORTLIST_TPC_ID = l_person_id
    WHERE BID_NUMBER = p_bid_number;
  ELSIF (p_event = 'SHORTLIST') THEN
    UPDATE PON_BID_HEADERS
    SET SHORTLIST_FLAG = 'Y'
      , LAST_UPDATE_DATE = SYSDATE
      , LAST_UPDATED_BY = p_user_id
      , SHORTLIST_TPC_ID = l_person_id
    WHERE BID_NUMBER = p_bid_number;
  END IF;

EXCEPTION
   when others then
   raise;

END toggle_shortlisting;


-- Returns the award amount for a negotiation.
FUNCTION get_award_amount(p_auction_header_id IN NUMBER) RETURN NUMBER IS
  l_award_amount NUMBER;
BEGIN

  BEGIN
    SELECT SUM(DECODE(ah.contract_type, 'STANDARD', bh.total_award_amount, bh.po_agreed_amount * (1/nvl(bh.rate, 1))))
    INTO l_award_amount
    FROM
      pon_auction_headers_all ah,
      pon_bid_headers bh
    WHERE
          ah.auction_header_id = p_auction_header_id
      AND ah.auction_header_id = bh.auction_header_id
      AND bh.award_status in ('AWARDED', 'PARTIAL');
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  RETURN l_award_amount;

END get_award_amount;
--
--
PROCEDURE award_bi_subline (
   p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
   p_bid_number IN pon_bid_headers.bid_number%TYPE,
   p_parent_line_number IN pon_bid_item_prices.line_number%TYPE,
   p_award_status IN pon_bid_item_prices.award_status%TYPE,
   p_award_date IN pon_bid_item_prices.award_date%TYPE,
   p_auctioneer_id pon_bid_item_prices.LAST_UPDATED_BY%TYPE)
IS
CURSOR c_sublines (c_auction_header_id pon_bid_headers.auction_header_id%TYPE,
                   c_bid_number pon_bid_headers.bid_number%TYPE,
				   c_parent_line_number pon_bid_item_prices.line_number%TYPE) IS
--Query retrives sublines for the given parent line
   SELECT
    bi.line_number,
    DECODE (p_award_status, 'AWARDED',decode (aii.group_type,
                                        'LOT_LINE', null, decode (aii.order_type_lookup_code,
                                                            'FIXED PRICE', 1,
                                                            'AMOUNT', 1,
                                                            'RATE', decode (aii.purchase_basis, 'TEMP LABOR', bi.quantity, 1), bi.quantity )), null) award_quantity
  FROM pon_bid_item_prices bi, pon_auction_item_prices_all aii
  WHERE
	bi.bid_number = c_bid_number
	   AND bi.line_number IN (SELECT ai.line_number
                           FROM pon_auction_item_prices_all ai
                   WHERE ai.parent_line_number = c_parent_line_number
                   AND ai.auction_header_id = bi.auction_header_id )
         AND aii.auction_header_id =  bi.auction_header_id
         AND aii.line_number = bi.line_number;

  l_sublines_rec c_sublines%ROWTYPE;

BEGIN
  OPEN c_sublines (p_auction_header_id, p_bid_number, p_parent_line_number);
  LOOP
	  FETCH c_sublines INTO l_sublines_rec;
	  EXIT WHEN c_sublines%NOTFOUND;
	  -- update the child lines
      update_single_bid_item_prices
	       (
	        p_bid_number,
			l_sublines_rec.line_number,
			p_award_status,
			l_sublines_rec.award_quantity,
			p_award_date,
			p_auctioneer_id
		   );
   END LOOP;
END award_bi_subline;
--
--
----------------------------------------------------------------
-- gets the parent line
--and sets the award status of parent line by querying up the child lines
----------------------------------------------------------------
PROCEDURE update_bi_group_award (
   p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
   p_bid_number IN pon_bid_headers.bid_number%TYPE,
   p_parent_line_number IN pon_auction_item_prices_all.parent_line_number%TYPE,
   p_award_date IN pon_bid_item_prices.award_date%TYPE,
   p_auctioneer_id IN pon_bid_item_prices.last_updated_by%TYPE )
IS
l_total_lines NUMBER;
l_awarded_lines NUMBER;
l_rejected_lines NUMBER;
l_award_status pon_bid_item_prices.award_status%TYPE;
BEGIN
  --get total, awarded/ rejected lines
  --
  SELECT count (*) ,
         sum(decode(bi.award_status,'AWARDED',1,0)) ,
         sum(decode(bi.award_status,'REJECTED',1,0))
  INTO l_total_lines,
       l_awarded_lines,
       l_rejected_lines
  FROM pon_auction_item_prices_all ai, pon_bid_item_prices bi
  WHERE ai.parent_line_number = p_parent_line_number
  AND ai.auction_header_id = p_auction_header_id
  and ai.auction_header_id = bi.auction_header_id(+)
  and bi.bid_number = p_bid_number
  and bi.line_number = ai.line_number;

  IF (l_total_lines = l_awarded_lines) THEN
    l_award_status := 'AWARDED' ;
  ELSIF  (l_awarded_lines > 0) THEN
    l_award_status := 'PARTIAL';
  ELSIF (l_total_lines = l_rejected_lines) THEN
    l_award_status := 'REJECTED';
  ELSE
    l_award_status := null;
  END IF;
--
	 update_single_bid_item_prices
	       (
	        p_bid_number,
		p_parent_line_number,
		l_award_status,
		null,
		p_award_date,
		p_auctioneer_id
		);

END update_bi_group_award;
--
--
PROCEDURE update_ai_group_award (
   p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
   p_line_number IN pon_bid_item_prices.line_number%TYPE,
   p_award_date IN pon_bid_item_prices.award_date%TYPE,
   p_auctioneer_id IN pon_bid_item_prices.last_updated_by%TYPE)
IS
l_total_lines NUMBER;
l_awarded_lines NUMBER;
l_parent_line_number NUMBER;
l_award_status pon_auction_item_prices_all.award_status%TYPE;
BEGIN
  --get total and awarded lines
 SELECT parent_line_number INTO l_parent_line_number FROM pon_auction_item_prices_all
 WHERE auction_header_id = p_auction_header_id AND line_number = p_line_number;
--
-- all the group lines have bids if a single group line has a bid
-- hence all group lines are awardable and hence considered for the count
  SELECT COUNT(*) INTO l_total_lines
  FROM pon_auction_item_prices_all ai
  WHERE parent_line_number = l_parent_line_number
  and auction_header_id = p_auction_header_id;
--
  select COUNT(*) INTO l_awarded_lines
  FROM pon_auction_item_prices_all
  WHERE parent_line_number = l_parent_line_number
  AND award_status = 'AWARDED'
  and auction_header_id = p_auction_header_id;

  IF (l_total_lines = l_awarded_lines) THEN
    l_award_status := 'AWARDED' ;
  ELSIF  (l_awarded_lines > 0) THEN
    l_award_status := 'PARTIAL';
  ELSE
    l_award_status := null;
  END IF;
--
   UPDATE pon_auction_item_prices_all
   SET award_status = l_award_status,
   	   awarded_quantity = null,
           award_mode = null,
   	   last_update_date = p_award_date,
	   last_updated_by = p_auctioneer_id
   WHERE auction_header_id = p_auction_header_id
	   AND line_number = l_parent_line_number;

END update_ai_group_award;
--
--


PROCEDURE get_award_totals(
	p_auction_header_id	in 	number,
	p_award_total		out	nocopy	number,
	p_current_total		out	nocopy	number,
	p_savings_total		out	nocopy	number,
	p_savings_percent	out	nocopy	number)
IS
	l_current_total_temp 	NUMBER;
BEGIN

	p_award_total		:= 0;
	p_current_total		:= 0;
	p_savings_total		:= 0;
	p_savings_percent	:= 0;
	l_current_total_temp	:= 0;

        SELECT  sum(nvl2(PAIP.current_price,
                         PAIP.current_price * nvl(PAIP.awarded_quantity, 0),
                         sum(decode(PBIP.award_status, 'AWARDED', nvl(PBIP.award_quantity, 0), 0) * nvl(PBIP.award_price, 0))))
        INTO    p_current_total
        FROM    pon_bid_item_prices             PBIP,
                pon_bid_headers                 PBH,
                pon_auction_item_prices_all     PAIP
        WHERE   PAIP.auction_header_id  = p_auction_header_id
        AND     PAIP.auction_header_id  = PBIP.auction_header_id (+)
        AND     PAIP.line_number        = PBIP.line_number (+)
        AND     PBIP.bid_number         = PBH.bid_number (+)
        AND     PBH.bid_status (+)      = 'ACTIVE'
        AND     NVL(PBH.award_status, 'NONE') IN ('PARTIAL', 'AWARDED')
        GROUP BY
                PAIP.line_number, PAIP.current_price, PAIP.awarded_quantity;

        SELECT  sum(decode(PBIP.award_status, 'AWARDED', nvl(PBIP.award_quantity, 0), 0) * nvl(PBIP.award_price, 0))
        INTO    p_award_total
        FROM    pon_bid_item_prices             PBIP,
                pon_bid_headers                 PBH
        WHERE   PBH.auction_header_id   = p_auction_header_id
        AND     PBIP.bid_number         = PBH.bid_number (+)
        AND     PBH.bid_status (+)      = 'ACTIVE'
        AND     NVL(PBH.award_status, 'NONE') IN ('PARTIAL', 'AWARDED');

	p_savings_total := p_current_total - p_award_total;

        -- safety check to avoid divide-by-zero exception
        IF p_current_total IS NULL OR p_current_total = 0 THEN
          p_savings_percent := 0;
	ELSE
          p_savings_percent := (p_savings_total / p_current_total) * 100;
        END IF;

EXCEPTION

	WHEN OTHERS THEN

      	IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        	fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_award_pkg.get_award_totals'
                      ,message   => 'exception occurred while calculating totals ' || SUBSTR(SQLERRM, 1, 200));
      	END IF;


		NULL;


END;


FUNCTION does_bid_exist
(
   p_scenario_id IN  PON_OPTIMIZE_CONSTRAINTS.SCENARIO_ID%TYPE,
   p_sequence_number IN  PON_OPTIMIZE_CONSTRAINTS.SEQUENCE_NUMBER%TYPE,
   p_bid_number IN  PON_BID_HEADERS.BID_NUMBER%TYPE
)  RETURN              VARCHAR2
IS
l_bid_exists VARCHAR2(1);
BEGIN

  BEGIN
    SELECT 'Y'
    INTO l_bid_exists
    FROM dual
    WHERE EXISTS (SELECT 1
    FROM pon_optimize_bid_class pobc
    WHERE pobc.scenario_id = p_scenario_id
    AND pobc.sequence_number = p_sequence_number
    AND pobc.bid_number = p_bid_number);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_bid_exists := 'N';
   END;
return l_bid_exists;
END;

FUNCTION has_scored_attribute
(
   p_auction_header_id IN  PON_AUCTION_ATTRIBUTES.AUCTION_HEADER_ID%TYPE,
   p_line_number IN  PON_AUCTION_ATTRIBUTES.LINE_NUMBER%TYPE
)  RETURN              VARCHAR2
IS
l_scored_attribute_exists VARCHAR2(1);
BEGIN

  BEGIN
    SELECT 'Y'
    INTO l_scored_attribute_exists
    FROM dual
    WHERE EXISTS (SELECT 1
    FROM pon_attribute_scores pas
    WHERE pas.auction_header_id = p_auction_header_id
    AND pas.line_number = p_line_number);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_scored_attribute_exists := 'N';
   END;
return l_scored_attribute_exists;
END;

PROCEDURE preprocess_cost_of_constraint
(
  p_scenario_id         	IN NUMBER,
  p_user_id         		IN NUMBER,
  p_cost_constraint_flag	IN VARCHAR2,
  p_constraint_type		IN VARCHAR2,
  p_internal_type		IN VARCHAR2,
  p_line_number			IN NUMBER,
  p_sequence_number		IN NUMBER,
  x_cost_scenario_id		OUT NOCOPY NUMBER,
  x_status              	OUT NOCOPY VARCHAR2
)
IS

l_new_scenario_id	 NUMBER;
l_status		 VARCHAR2(10);
l_order_type_lookup_code PON_AUCTION_ITEM_PRICES_ALL.order_type_lookup_code%TYPE;
l_auction_qty              NUMBER;
l_contract_type          PON_AUCTION_HEADERS_ALL.contract_type%TYPE;
l_module                 VARCHAR2(200);
l_priority               VARCHAR2(30);
BEGIN

l_module := 'pon.plsql.PON_AWARD_PKG.preprocess_cost_of_constraint';
l_priority := '1_CRITICAL';
	-- basic initialization

	l_new_scenario_id := -9999;

        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Entering procedure with p_scenario_id: ' || p_scenario_id );
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module,' p_cost_constraint_flag : '|| p_cost_constraint_flag || ' ,p_constraint_type : '|| p_constraint_type || ' ,p_internal_type : '|| p_internal_type);
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module,' p_line_number : '|| p_line_number || ' ,p_sequence_number : ' || p_sequence_number );
            END IF;
        END IF;

	copy_award_scenario(p_scenario_id		=> p_scenario_id,
  			    p_user_id			=> p_user_id,
			    p_cost_scenario_flag 	=> p_cost_constraint_flag,
			    x_cost_scenario_id		=> l_new_scenario_id,
  			    x_status			=> l_status);


        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'After  copy_award_scenario is called. New scenario id is' || l_new_scenario_id ||' ; Status ' ||l_status);
            END IF;
        END IF;

	IF (l_status <> 'FAILURE') THEN

		-- these initial conditions are applicable to those
		-- scenarios where multiple constraints are saved on the
		-- same row of pon_optimize_constraints table

		IF (p_constraint_type = 'LINE_CONST') THEN --{

			IF (p_internal_type = 'LINE_SPLIT_AWARD') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_SPLIT_AWARD internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	SPLIT_AWARD_FLAG 	= decode(SPLIT_AWARD_FLAG, 'Y', 'N', 'Y'),
				     	SPLIT_AWARD_PRIORITY 	= NVL2(SPLIT_AWARD_PRIORITY,l_priority,null),
					SPLIT_AWARD_INFEAS_FLAG = TO_CHAR(NULL),
					SPLIT_AWARD_COST 	= TO_NUMBER(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			ELSIF (p_internal_type = 'LINE_INTEGER_QUANTITY') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_INTEGER_QUANTITY internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	INTEGRAL_QTY_AWARD_FLAG 	= decode(INTEGRAL_QTY_AWARD_FLAG, 'Y', 'N', 'Y'),
				     	INTEGRAL_QTY_AWARD_PRIORITY 	= NVL2(INTEGRAL_QTY_AWARD_PRIORITY,l_priority,null),
					INTEGRAL_QTY_AWARD_INFEAS_FLAG = TO_CHAR(NULL),
					INTEGRAL_QTY_AWARD_COST 	= TO_NUMBER(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;


			ELSIF (p_internal_type = 'LINE_AWARD_QTY') THEN

                                BEGIN
                                  SELECT pah.contract_type,
                                         pai.order_type_lookup_code,
                                         nvl(pai.quantity, 1)
                                  INTO l_contract_type,
                                       l_order_type_lookup_code,
                                       l_auction_qty
                                  FROM pon_auction_headers_all pah,
                                       pon_auction_item_prices_all pai,
                                       pon_optimize_scenarios pos
                                 WHERE pah.auction_header_id = pai.auction_header_id
                                   AND pah.auction_header_id = pos.auction_header_id
                                   AND pai.line_number = p_line_number
                                   AND pos.scenario_id = l_new_scenario_id;
                                EXCEPTION
                                  WHEN OTHERS THEN
                                      IF (g_debug_mode = 'Y') THEN
                                        IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED, l_module, 'Selecting auction info in LINE_AWARD_QTY internal type constraint if condition caused error');
                                        END IF;
                                      END IF;

                                END;

                                -- We need to set Max Qty to 1 for FIXED PRICE and AMOUNT based lines for SPO, BPA and CPA
                                -- For SPO, We need to set Max Qty to auction qty for QUANTITY based lines
                                -- For BPA and CPA, If auction qty is null we need to set Max Qty to 1, otherwise we should set it to auction qty

                                -- In the above sql for selecting the auction qty as we use nvl to set auction qty to 1,
                                -- all the above conditions should be satisfied

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_AWARD_QTY internal type constraint');
                                  END IF;
                                END IF;

                                UPDATE  PON_OPTIMIZE_CONSTRAINTS
                                SET     MIN_QUANTITY 	= 0,
			        	MAX_QUANTITY 	= DECODE(l_order_type_lookup_code, 'FIXED PRICE', 1, 'AMOUNT', 1, l_auction_qty),
					MIN_MAX_QUANTITY_PRIORITY = NVL2(MIN_MAX_QUANTITY_PRIORITY,l_priority,null),
					MIN_MAX_QUANTITY_COST = TO_NUMBER(NULL),
					MIN_MAX_QUANTITY_INFEAS_FLAG = TO_CHAR(NULL)
                                WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND     SEQUENCE_NUMBER 	= p_sequence_number
                                AND     CONSTRAINT_TYPE 	= p_constraint_type;

			ELSIF (p_internal_type = 'LINE_AWARD_AMOUNT') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_AWARD_AMOUNT internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_AMOUNT 		= TO_NUMBER(NULL),
				     	MAX_AMOUNT 		= TO_NUMBER(NULL),
					MIN_MAX_AMOUNT_PRIORITY = TO_CHAR(NULL),
					MIN_MAX_AMOUNT_COST 	= TO_NUMBER(NULL),
					MIN_MAX_AMOUNT_INFEAS_FLAG = TO_CHAR(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;


			ELSIF (p_internal_type = 'LINE_MIN_QTY') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_MIN_QTY internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	QUANTITY_CUTOFF 	    = TO_NUMBER(NULL),
				     	QUANTITY_CUTOFF_PRIORITY    = TO_CHAR(NULL),
					QUANTITY_CUTOFF_INFEAS_FLAG = TO_CHAR(NULL),
					QUANTITY_CUTOFF_COST 	= TO_NUMBER(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;



			ELSIF (p_internal_type = 'LINE_MAX_PRICE')  THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_MAX_PRICE internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	PRICE_CUTOFF 	    = TO_NUMBER(NULL),
				     	PRICE_CUTOFF_PRIORITY    = TO_CHAR(NULL),
					PRICE_CUTOFF_INFEAS_FLAG = TO_CHAR(NULL),
					PRICE_CUTOFF_COST 	= TO_NUMBER(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;



			ELSIF (p_internal_type = 'LINE_MIN_SCORE') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_MIN_SCORE internal type constraint');
                                  END IF;
                                END IF;
				-- XYZ - SIMILAR CONDITION NEEDED FOR
				-- AwardOptConstraint.SINGLE_HEADER_ATTR_CUTOFF
				-- AwardOptConstraint.GROUP_HEADER_ATTR_CUTOFF

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_SCORE 	    = TO_NUMBER(NULL),
				     	MIN_SCORE_PRIORITY    = TO_CHAR(NULL),
					MIN_SCORE_INFEAS_FLAG = TO_CHAR(NULL),
					MIN_SCORE_COST 	= TO_NUMBER(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			ELSIF (p_internal_type = 'LINE_PROMISED_DATE') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_PROMISED_DATE internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	FROM_DATE 	      = TO_DATE(NULL),
					TO_DATE			= TO_DATE(NULL),
				     	PROMISED_DATE_PRIORITY    = TO_CHAR(NULL),
					PROMISED_DATE_INFEAS_FLAG = TO_CHAR(NULL),
					PROMISED_DATE_COST 	= TO_NUMBER(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			END IF;

		--}

		ELSIF (p_constraint_type = 'SUPP_LINE_CONST') THEN --{

			-- two constraints
			-- Line Number of Suppliers : same seqnum
			-- Line Any One Supplier    : same seqnum

			IF    (p_internal_type = 'LINE_NUM_SUPP') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_NUM_SUPP internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_QUANTITY 	= TO_NUMBER(NULL),
				     	MAX_QUANTITY 	= TO_NUMBER(NULL),
					MIN_MAX_QUANTITY_PRIORITY = TO_CHAR(NULL),
					MIN_MAX_QUANTITY_COST 	  = TO_NUMBER(NULL),
					MIN_MAX_QUANTITY_INFEAS_FLAG = TO_CHAR(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;


			ELSIF (p_internal_type = 'LINE_ANY_ONE_SUPP') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_ANY_ONE_SUPP internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_AMOUNT 		= TO_NUMBER(NULL),
				     	MAX_AMOUNT 		= TO_NUMBER(NULL),
					MIN_MAX_AMOUNT_PRIORITY = TO_CHAR(NULL),
					MIN_MAX_AMOUNT_COST 	= TO_NUMBER(NULL),
					MIN_MAX_AMOUNT_INFEAS_FLAG = TO_CHAR(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;


			--ELSE

				--DELETE FROM PON_OPTIMIZE_CONSTRAINTS
				--WHERE   SCENARIO_ID 	= p_scenario_id
				--AND 	CONSTRAINT_TYPE = p_constraint_type
				--AND 	SEQUENCE_NUMBER	= p_sequence_number;

			END IF;

		--}

		ELSIF (p_constraint_type = 'SUPP_BIZ_CONST') THEN --{

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating SUPP_BIZ_CONST constraint type');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_AMOUNT 		= TO_NUMBER(NULL),
				     	MAX_AMOUNT 		= TO_NUMBER(NULL),
					MIN_MAX_AMOUNT_PRIORITY = TO_CHAR(NULL),
					MIN_MAX_AMOUNT_COST 	= TO_NUMBER(NULL),
					MIN_MAX_AMOUNT_INFEAS_FLAG = TO_CHAR(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

		--}

		ELSIF (p_constraint_type = 'BID_LINE_CONST') THEN --{
			IF    (p_internal_type = 'LINE_SUPP_SITE_AMT') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_SUPP_SITE_AMT internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_AMOUNT 		= TO_NUMBER(NULL),
				     	MAX_AMOUNT 		= TO_NUMBER(NULL),
					MIN_MAX_AMOUNT_PRIORITY = TO_CHAR(NULL),
					MIN_MAX_AMOUNT_COST 	= TO_NUMBER(NULL),
					MIN_MAX_AMOUNT_INFEAS_FLAG = TO_CHAR(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			ELSIF    (p_internal_type = 'LINE_SUPP_SITE_QTT') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_SUPP_SITE_QTT internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_QUANTITY 		= TO_NUMBER(NULL),
				     	MAX_QUANTITY            = TO_NUMBER(NULL),
					MIN_MAX_QUANTITY_PRIORITY = TO_CHAR(NULL),
					MIN_MAX_QUANTITY_COST 	= TO_NUMBER(NULL),
					MIN_MAX_QUANTITY_INFEAS_FLAG = TO_CHAR(NULL)
				WHERE   SCENARIO_ID 		= l_new_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

                        END IF;
		ELSE

                        IF (g_debug_mode = 'Y') THEN
                            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before deleting constraint from pon_optimize_constraints');
                            END IF;
                        END IF;
			-- INCLUDES LINE-LEVEL INDIVIDUAL SUPPLIER CONSTRAINTS AS WELL

			-- if the constraint type is either of the remaining types,
			-- we can delete the row from pon_optimize_constraints
			-- using the sequence_number

			DELETE FROM PON_OPTIMIZE_CONSTRAINTS
			WHERE   SCENARIO_ID 	= l_new_scenario_id
			AND 	CONSTRAINT_TYPE = p_constraint_type
			AND 	SEQUENCE_NUMBER	= p_sequence_number;

		END IF;

		x_cost_scenario_id := l_new_scenario_id;
		x_status 	   := 'SUCCESS';

	ELSE
		x_cost_scenario_id := -9999;
		x_status 	   := 'FAILURE';


	END IF;



EXCEPTION
	WHEN OTHERS THEN
		x_cost_scenario_id := -9999;
		x_status 	   := 'FAILURE';
		RAISE;

END;


PROCEDURE postprocess_cost_of_constraint
(
  p_scenario_id         IN NUMBER,
  p_constraint_type	IN VARCHAR2,
  p_internal_type	IN VARCHAR2,
  p_line_number		IN NUMBER,
  p_sequence_number	IN NUMBER,
  x_status              OUT NOCOPY VARCHAR2
)

IS
l_num_constraints 		NUMBER;
l_num_bid_classes 		NUMBER;
l_num_results			NUMBER;
l_cost_of_constraint 		NUMBER;
l_parent_scenario_id		NUMBER;
l_module                        VARCHAR2(250);
BEGIN

        l_module := 'pon.plsql.PON_AWARD_PKG.postprocess_cost_of_constraint';
        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Entering procedure with p_scenario_id: ' || p_scenario_id );
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module,' p_constraint_type : '|| p_constraint_type || ' ,p_internal_type : '|| p_internal_type);
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module,' p_line_number : '|| p_line_number || ' ,p_sequence_number : ' || p_sequence_number );
            END IF;
        END IF;

	-- USE PARENT_SCENARIO_ID TO JOIN TO MAIN SCENARIO
	-- DETERMINE THE COST AS FOLLOWS -

	SELECT (PARENT_SCENARIO.TOTAL_AWARD_AMOUNT - COST_SCENARIO.TOTAL_AWARD_AMOUNT),
		PARENT_SCENARIO.SCENARIO_ID
	INTO   	L_COST_OF_CONSTRAINT,
		L_PARENT_SCENARIO_ID
	FROM   PON_OPTIMIZE_SCENARIOS COST_SCENARIO,
	       PON_OPTIMIZE_SCENARIOS PARENT_SCENARIO
	WHERE  COST_SCENARIO.SCENARIO_ID   = p_scenario_id
	AND    PARENT_SCENARIO.SCENARIO_ID = COST_SCENARIO.PARENT_SCENARIO_ID;

        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'After selecting cost: L_COST_OF_CONSTRAINT: ' || L_COST_OF_CONSTRAINT || ' , L_PARENT_SCENARIO_ID: '||L_PARENT_SCENARIO_ID );
            END IF;
        END IF;

	-- UPDATE THE CORRESPONDING ROW IN CONSTRAINTS TABLE
	-- OF PARENT SCENARIO WITH THIS COST OF CONSTRAINT

		IF (p_constraint_type = 'LINE_CONST') THEN

			IF    (p_internal_type = 'LINE_SPLIT_AWARD') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_SPLIT_AWARD internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	SPLIT_AWARD_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			ELSIF (p_internal_type = 'LINE_INTEGER_QUANTITY') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_INTEGER_QUANTITY internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	INTEGRAL_QTY_AWARD_COST = l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;


			ELSIF (p_internal_type = 'LINE_AWARD_QTY') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_AWARD_QTY internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_QUANTITY_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;


			ELSIF (p_internal_type = 'LINE_AWARD_AMOUNT') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_AWARD_AMOUNT internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_AMOUNT_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;


			ELSIF (p_internal_type = 'LINE_MIN_QTY') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_MIN_QTY internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	QUANTITY_CUTOFF_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;



			ELSIF (p_internal_type = 'LINE_MAX_PRICE')  THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_MAX_PRICE internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	PRICE_CUTOFF_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;



			ELSIF (p_internal_type = 'LINE_MIN_SCORE') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_MIN_SCORE internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_SCORE_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			ELSIF (p_internal_type = 'LINE_PROMISED_DATE') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_PROMISED_DATE internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	PROMISED_DATE_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			END IF;

		ELSIF (p_constraint_type = 'SUPP_LINE_CONST') THEN

			-- three constraints

			-- Line Number of Suppliers : same seqnum
			-- Line Any One Supplier    : same seqnum
			-- Line-level award amount and
			-- award quantity for each supplier : different seqnum


			IF    (p_internal_type = 'LINE_NUM_SUPP') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_NUM_SUPP internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_QUANTITY_COST 	  = l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;


			ELSIF (p_internal_type = 'LINE_ANY_ONE_SUPP') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_ANY_ONE_SUPP internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_AMOUNT_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			END IF;

		ELSIF (p_constraint_type = 'BID_LINE_CONST') THEN

			IF    (p_internal_type = 'LINE_SUPP_SITE_AMT') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_SUPP_SITE_AMT internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_AMOUNT_COST = l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

			ELSIF    (p_internal_type = 'LINE_SUPP_SITE_QTT') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating LINE_SUPP_SITE_QTT internal type constraint');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_QUANTITY_COST 	  = l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

                        END IF;
		ELSIF (p_constraint_type = 'SUPP_BIZ_CONST') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating SUPP_BIZ_CONST constraint type');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_AMOUNT_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

		ELSIF (	p_constraint_type = 'BUDGET_AMT_CONST'  OR
			p_constraint_type = 'INCUMBENT_SUPP_CONST' OR
			p_constraint_type = 'ANY_SUPP_CONST' OR
			p_constraint_type = 'SUPP_ASL_CONST' OR
			p_constraint_type = 'SUPPLIER_CONST' )  THEN


                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating BUDGET_AMT_CONST, INCUMBENT_SUPP_CONST, ANY_SUPP_CONST, ');
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'SUPP_ASL_CONST, SUPPLIER_CONST  constraint types');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_AMOUNT_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

		ELSIF (p_constraint_type = 'NUM_OF_SUPP_CONST') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating NUM_OF_SUPP_CONST constraint type');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_MAX_QUANTITY_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

		ELSIF (	p_constraint_type = 'TOTAL_HDR_ATTR_CONST' OR
			p_constraint_type = 'HDR_ATTR_CONST' ) THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating TOTAL_HDR_ATTR_CONST, HDR_ATTR_CONST constraint types');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	MIN_SCORE_COST 		= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

		ELSIF (p_constraint_type = 'INCL_HOLD_SUPP_CONST') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating INCL_HOLD_SUPP_CONST constraint type');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	EXCLUDED_SUPPLIER_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;

		ELSIF (p_constraint_type = 'NO_SPLIT_GROUP_CONST') THEN

                                IF (g_debug_mode = 'Y') THEN
                                  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before updating NO_SPLIT_GROUP_CONST constraint type');
                                  END IF;
                                END IF;

				UPDATE 	PON_OPTIMIZE_CONSTRAINTS
				SET 	SPLIT_AWARD_COST 	= l_cost_of_constraint
				WHERE   SCENARIO_ID 		= l_parent_scenario_id
				AND	SEQUENCE_NUMBER 	= p_sequence_number
				AND	CONSTRAINT_TYPE 	= p_constraint_type;
		END IF;

        IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before deleting the dummy scneario with p_scenario_id: ' || p_scenario_id );
            END IF;
        END IF;

	DELETE FROM PON_OPTIMIZE_SCENARIOS  WHERE SCENARIO_ID = P_SCENARIO_ID;

	-- do some basic initialization

	l_num_constraints := 0;
	l_num_bid_classes := 0;
	l_num_results     := 0;


	-- make sure there is at least 1 row to prevent no data found exception
	select count(*) into l_num_constraints
	from pon_optimize_constraints
	where scenario_id = p_scenario_id;

	IF (l_num_constraints > 0) THEN
          IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before deleting the dummy scenario constraints from PON_OPTIMIZE_CONSTRAINTS for p_scenario_id: ' || p_scenario_id );
            END IF;
          END IF;

	 DELETE FROM PON_OPTIMIZE_CONSTRAINTS WHERE SCENARIO_ID = P_SCENARIO_ID;

	END IF;

	select count(*) into l_num_bid_classes
   	from pon_optimize_bid_class
   	where scenario_id = p_scenario_id;

	IF (l_num_bid_classes > 0) THEN
          IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before deleting the dummy scenario details from PON_OPTIMIZE_BID_CLASS for p_scenario_id: ' || p_scenario_id );
            END IF;
          END IF;

	 DELETE FROM PON_OPTIMIZE_BID_CLASS WHERE SCENARIO_ID = P_SCENARIO_ID;
	END IF;

	select count(*) into l_num_results
   	from pon_optimize_results
   	where scenario_id = p_scenario_id;

        IF(l_num_results > 0) THEN
          IF (g_debug_mode = 'Y') THEN
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT, l_module, 'Before deleting the dummy scenario results from PON_OPTIMIZE_RESULTS for p_scenario_id: ' || p_scenario_id );
            END IF;
          END IF;

		DELETE FROM PON_OPTIMIZE_RESULTS WHERE SCENARIO_ID = P_SCENARIO_ID;

 	END IF;

	X_STATUS := 'SUCCESS';

EXCEPTION
	WHEN OTHERS THEN
		X_STATUS := 'FAILURE';
                IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(log_level => fnd_log.LEVEL_UNEXPECTED
                      ,module    => l_module
                      ,message   => 'When others exception raised in postprocess_cost_of_constraint');
                END IF;

		RAISE;
END;


PROCEDURE reset_cost_of_constraint
(
  p_scenario_id         IN NUMBER,
  x_status              OUT NOCOPY VARCHAR2
)

IS

l_num_constraints 	NUMBER;

BEGIN

	-- initialize number of constraints
	l_num_constraints := -1;

	-- make sure there is at least 1 row to prevent no data found exception
	select count(*) into l_num_constraints
	from pon_optimize_constraints
	where scenario_id = p_scenario_id;

	IF (l_num_constraints > 0) THEN

	  UPDATE PON_OPTIMIZE_CONSTRAINTS
	  SET
		MIN_MAX_AMOUNT_COST 	= TO_NUMBER(NULL),
		MIN_MAX_QUANTITY_COST 	= TO_NUMBER(NULL),
		PRICE_CUTOFF_COST 	= TO_NUMBER(NULL),
		SPLIT_AWARD_COST 	= TO_NUMBER(NULL),
		QUANTITY_CUTOFF_COST 	= TO_NUMBER(NULL),
		INTEGRAL_QTY_AWARD_COST = TO_NUMBER(NULL),
		EXCLUDED_SUPPLIER_COST 	= TO_NUMBER(NULL),
		PROMISED_DATE_COST 	= TO_NUMBER(NULL),
		MIN_SCORE_COST 		= TO_NUMBER(NULL)
 	  WHERE
		SCENARIO_ID = P_SCENARIO_ID;

	END IF;

	X_STATUS := 'SUCCESS';

EXCEPTION
	WHEN OTHERS THEN
		X_STATUS := 'FAILURE';
		RAISE;
END;

/*======================================================================
 FUNCTION :  GET_SAVING_PERCENT_INCENTIVE    PUBLIC
 PARAMETERS:
  p_scenario_id    IN    scenario id

 COMMENT   : Returns the saving percent of the given scenario.
======================================================================*/
FUNCTION GET_SAVING_PERCENT_INCENTIVE (p_scenario_id   IN NUMBER)
       RETURN NUMBER
IS
  L_SAVING_PERCENT NUMBER := 0;

  l_total_award NUMBER := 0;
  l_new_rebate NUMBER := 0;
  l_incentive NUMBER := 0;
  l_total_incentive NUMBER := 0;
  l_total_current_amount NUMBER := 0;

  l_bid_number_col 			 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
  l_award_total_sum_col		 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
  l_savings_amount_col		 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
  l_current_amount_col		 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
  l_current_total_spend_col  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
  l_fixed_incentive_col      PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
  l_current_rebate_col       PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

BEGIN

SELECT
bi.bid_number as selected_bid_number,
SUM(por.award_quantity * decode(nvl(por.award_shipment_number,-1),-1,bi.per_unit_price_component,pbs.per_unit_price_component) + bi.fixed_amount_component) AS  award_total_sum,
SUM(por.award_quantity * nvl2(ai.current_price,  (ai.current_price -por.award_price),   0)) AS savings_amount,
SUM(por.award_quantity * nvl(ai.current_price,por.award_price)) AS current_amount,
nvl(pbh.CURRENT_TOTAL_SPEND, 0) CURRENT_TOTAL_SPEND,
nvl(pbh.FIXED_INCENTIVE, 0) FIXED_INCENTIVE,
nvl(pbh.CURRENT_REBATE,0) CURRENT_REBATE
BULK COLLECT INTO
  l_bid_number_col ,
  l_award_total_sum_col	,
  l_savings_amount_col,
  l_current_amount_col,
  l_current_total_spend_col,
  l_fixed_incentive_col,
  l_current_rebate_col
FROM
pon_bid_item_prices bi,
pon_auction_item_prices_all ai,
pon_optimize_scenarios pos,
pon_optimize_results por,
pon_bid_shipments pbs,
pon_bid_headers pbh
WHERE
por.scenario_id = pos.scenario_id
AND
por.bid_number = bi.bid_number
AND
pos.auction_header_id = bi.auction_header_id
AND
ai.auction_header_id = bi.auction_header_id
AND
bi.line_number = por.line_number
AND
ai.line_number = bi.line_number
AND
ai.group_type in ('LINE', 'LOT', 'GROUP_LINE')
AND
nvl(por.award_quantity, -1) > 0
AND
por.bid_number = pbh.bid_number
and
pos.scenario_id = p_scenario_id
AND por.bid_number = pbs.bid_number(+)
AND por.line_number = pbs.line_number(+)
AND nvl(por.award_shipment_number,   -1) = pbs.shipment_number(+)
GROUP BY bi.bid_number, pbh.CURRENT_TOTAL_SPEND, pbh.FIXED_INCENTIVE, pbh.CURRENT_REBATE;

FOR i IN 1..l_bid_number_col.COUNT LOOP

	l_total_Award := l_award_total_sum_col(i) + l_current_total_spend_col(i);

	BEGIN
		 select rebate
		 into l_new_rebate
		 from pon_bid_rebates
		 where bid_number = l_bid_number_col(i)
	 	  	   and l_total_award between lower_spend and upper_spend;

	EXCEPTION WHEN NO_DATA_FOUND THEN
			  l_new_rebate := 0;
	END;

	if l_new_rebate = 0 then
	   l_new_rebate := l_current_rebate_col(i);
	end if;

	l_incentive :=  l_fixed_incentive_col(i) + (l_award_total_sum_col(i) * l_new_rebate / 100 )
					+ l_current_total_spend_col(i) * ( l_new_rebate - l_current_rebate_col(i) )/100;

	l_total_incentive := l_total_incentive + l_incentive + l_savings_amount_col(i);
	l_total_current_amount := l_total_current_amount + l_current_amount_col(i);
END LOOP;

	if l_total_current_amount <> 0 then
	  l_saving_percent := l_total_incentive/l_total_current_amount*100;
	end if;

    RETURN l_saving_percent;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END GET_SAVING_PERCENT_INCENTIVE;

FUNCTION getDependentReqLevel
(
p_auction_header_id IN NUMBER,
p_sequence_number IN NUMBER
)
RETURN NUMBER
IS
l_level NUMBER;
l_loopBreak VARCHAR2(1);
l_ParentRequirementId NUMBER;
l_DepRequirementId NUMBER;
BEGIN
l_level:=0;
l_loopBreak:='N';
l_DepRequirementId:=p_sequence_number;


WHILE l_loopBreak='N'
LOOP

BEGIN
SELECT PARENT_REQUIREMENT_ID
INTO l_ParentRequirementId
FROM
pon_attributes_rules
WHERE
auction_header_id=p_auction_header_id
AND
dependent_requirement_id=l_DepRequirementId
AND
ROWNUM=1;

l_Level:=l_Level+1;
l_DepRequirementId:=l_ParentRequirementId;

EXCEPTION
WHEN No_Data_Found THEN
l_loopBreak:='Y';
END;

END LOOP;
RETURN l_Level;

END;

END PON_AWARD_PKG;

/
