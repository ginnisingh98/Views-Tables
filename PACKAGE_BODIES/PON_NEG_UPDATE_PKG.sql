--------------------------------------------------------
--  DDL for Package Body PON_NEG_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_NEG_UPDATE_PKG" as
/* $Header: PONUPDTB.pls 120.11.12010000.2 2013/06/06 07:59:28 pamaniko ship $ */
g_module_prefix        CONSTANT VARCHAR2(50) := 'pon.plsql.PON_NEG_UPDATE_PKG.';

-------Variables---------
-- used for AutoExtension, to represent unlimited int, this needs to
-- match SourcingUtil.UNLIMITED_INT
UNLIMITED_INT NUMBER := 10000;
--------------------------


PROCEDURE MANUAL_CLOSE (p_auction_header_id IN NUMBER,
                        p_close_now_flag IN VARCHAR2,
                        p_new_close_date IN DATE,
                        p_reason IN VARCHAR2,
                        p_user_id IN NUMBER) IS

x_temp DATE;
x_close_bidding_date DATE;
BEGIN

   -- lock negotiation header
   SELECT LAST_UPDATE_DATE, CLOSE_BIDDING_DATE
     INTO x_temp, x_close_bidding_date
     FROM PON_AUCTION_HEADERS_ALL
    WHERE AUCTION_HEADER_ID = p_auction_header_id
      FOR UPDATE;

   -- update header close date
   update pon_auction_headers_all
      set close_bidding_date = p_new_close_date,
          original_close_bidding_date = x_close_bidding_date,
          last_update_date = sysdate,
          last_updated_by = p_user_id
    where auction_header_id = p_auction_header_id;

   -- update item close date
   update pon_auction_item_prices_all
      set close_bidding_date = p_new_close_date,
          last_update_date = sysdate,
          last_updated_by = p_user_id
    where auction_header_id = p_auction_header_id
    and   close_bidding_date > p_new_close_date;

   -- send notifications
   if (p_close_now_flag = 'Y') then
      pon_auction_pkg.CLOSEEARLY_AUCTION(p_auction_header_id,
                                         p_new_close_date,
                                         p_reason);
   else
      pon_auction_pkg.CLOSECHANGED_AUCTION(p_auction_header_id,
                                           2,  -- type code
                                           p_new_close_date,
                                           p_reason);
   end if;

END MANUAL_CLOSE;


PROCEDURE CANCEL_NEGOTIATION (p_auction_header_id IN NUMBER,
                              p_send_note_flag IN VARCHAR2,
                              p_reason IN VARCHAR2,
                              p_user_id IN NUMBER,
                              x_error_code OUT NOCOPY VARCHAR2) IS


x_temp DATE;
x_auction_origination_code  pon_auction_headers_all.auction_origination_code%TYPE;
x_trading_partner_contact_id pon_auction_headers_all.trading_partner_contact_id%TYPE;
x_auction_header_id_prev_round pon_auction_headers_all.auction_header_id_prev_round%TYPE;
x_auction_status pon_auction_headers_all.auction_status%TYPE;

BEGIN

   x_error_code := 'SUCCESS';

   -- select data from header
   select auction_origination_code, trading_partner_contact_id,
	auction_header_id_prev_round, auction_status
     into x_auction_origination_code, x_trading_partner_contact_id,
	x_auction_header_id_prev_round, x_auction_status
     from pon_auction_headers_all
    where auction_header_id = p_auction_header_id;

   -- lock the negotiation
   SELECT LAST_UPDATE_DATE
     INTO x_temp
     FROM PON_AUCTION_HEADERS_ALL
    WHERE AUCTION_HEADER_ID = p_auction_header_id
      FOR UPDATE;

   -- update header
   -- update the pause details also.
   update pon_auction_headers_all
      set auction_status = 'CANCELLED',
          cancel_date = sysdate,
          last_update_date = sysdate,
          last_updated_by = p_user_id,
	  is_paused = null,
	  pause_remarks = null,
	  last_pause_date = null
    where auction_header_id = p_auction_header_id;

   -- Record Action History
   PON_ACTION_HIST_PKG.RECORDHISTORY(p_auction_header_id,
                                     -1,
                                     'PON_AUCTION',
                                     'CANCEL',
                                     x_trading_partner_contact_id,
                                     p_reason,
                                     null,
                                     null,
                                     'N');

   -- if an autocreated document is cancelled, return the
   -- backing requisitions to the req. pool
   if (x_auction_origination_code = 'REQUISITION') then
      IF( x_auction_status = 'DRAFT') THEN
        PON_AUCTION_PKG.CANCEL_NEGOTIATION_REF(
        Nvl(x_auction_header_id_prev_round,p_auction_header_id), x_error_code);
      ELSE
     PON_AUCTION_PKG.CANCEL_NEGOTIATION_REF(p_auction_header_id, x_error_code);
      END IF;
   end if;

   -- if good so far, kick off workflow notification process.
   if (p_send_note_flag = 'Y' and x_error_code = 'SUCCESS') then
     PON_AUCTION_PKG.CANCEL_AUCTION(p_auction_header_id);
   end if;

END CANCEL_NEGOTIATION;

--
-- Procedure to Manually Extend a Negotiation
-- Called from oracle.apps.pon.negotiation.tools.server.ManualExtendAMImpl.java
-- Called from oracle.apps.pon.negotiation.tools.server.NegPauseAMImpl.java
-- Negotiation Resume also will be treated as Manual Extend operation.
--
PROCEDURE MANUAL_EXTEND (p_auction_header_id IN NUMBER,
			    p_close_date IN DATE,
			    p_new_close_date IN DATE,
			    p_is_autoExtend IN VARCHAR2,
			    p_new_autoextend_num IN NUMBER,
			    p_is_allExtend IN VARCHAR2,
			    p_new_duration IN NUMBER,
			    p_new_extend_type IN VARCHAR2,
			    p_user_id IN NUMBER,
			    p_last_updated_date IN DATE,
                p_auto_extend_min_trigger IN NUMBER,
          		p_result OUT NOCOPY NUMBER,
                p_extended_close_bidding_date OUT NOCOPY DATE ) IS


x_update_date DATE;
x_new_close_date DATE;
x_close_date DATE;
v_pause_date DATE;
v_ispaused VARCHAR2(1);
v_is_staggered VARCHAR2(1);
x_new_autoextend_num NUMBER;
x_num_extension_occurred NUMBER;
x_first_line_close_date DATE;

BEGIN

   ------------- RETURN VALUES ----------------------------------
   -- Value    --          MEANING  ---------                   -
   --  0                Successful                              -
   --  1                Concurrency Problem (STALE DATA)        -
   --  2                New Close Date is less than SYSDATE     -
   --  3                Negotiation is already closed           -
   --  4                New Close Date less than Original one   -
   --  6                Negotiation is already paused           -
   ---------------------------------------------------------------------

   -- lock the negotiation header
   SELECT LAST_UPDATE_DATE, nvl( IS_PAUSED, 'N' ), nvl( LAST_PAUSE_DATE, sysdate ), nvl(number_of_extensions, 0),
     nvl2(staggered_closing_interval,'Y','N'), first_line_close_date
     INTO x_update_date, v_ispaused, v_pause_date, x_num_extension_occurred, v_is_staggered, x_first_line_close_date
     FROM PON_AUCTION_HEADERS_ALL
     WHERE AUCTION_HEADER_ID = p_auction_header_id
   FOR UPDATE;


   -- check the negotiation is already paused or not.
   -- for resume operation, p_is_autoExtend argument will have "R" value.
   -- 'R' indicates : "Resume" operation.
   -- the p_new_close_date value will be null for resume operations.
   if (p_is_autoExtend <> 'R' and v_ispaused = 'Y' ) then
	p_result := 6;
 	return;
   end if;

   --Verify concurrency
   if (x_update_date <> p_last_updated_date) then
	p_result := 1;
 	return;
   end if;

   if (v_ispaused = 'Y') then
   	x_new_close_date := sysdate + ( p_close_date - v_pause_date );

    IF (v_is_staggered = 'Y' AND sysdate <= x_first_line_close_date) THEN
     x_first_line_close_date := x_first_line_close_date + ( sysdate - v_pause_date );
    END IF;

   else
	  if (SYSDATE >= p_close_date) then
 		p_result := 3;
		return;
	  end if;

    IF (v_is_staggered = 'Y' AND sysdate <= x_first_line_close_date) THEN

       x_first_line_close_date := x_first_line_close_date + ( p_new_close_date - p_close_date);

    END IF;

	  x_new_close_date := p_new_close_date;

          if (SYSDATE >= x_new_close_date) then
        	p_result := 2;
       	        return;
          end if;

          if (p_close_date > x_new_close_date) then
 	       p_result := 4;
	       return;
          end if;
   end if;

   -- This extended close bidding date will be retrieved from the java layer.
   p_extended_close_bidding_date := x_new_close_date;

   -- update header close date and reset the pause related fields.
   UPDATE PON_AUCTION_HEADERS_ALL
	  SET CLOSE_BIDDING_DATE = x_new_close_date,
          LAST_UPDATE_DATE= sysdate,
	  LAST_UPDATED_BY = p_user_id,
	  ORIGINAL_CLOSE_BIDDING_DATE = p_close_date,
    FIRST_LINE_CLOSE_DATE = x_first_line_close_date,
	  IS_PAUSED = NULL,
	  PAUSE_REMARKS = NULL,
	  LAST_PAUSE_DATE = NULL
    WHERE AUCTION_HEADER_ID = p_auction_header_id;

    -- update the item prices all table close bidding date.
    -- do not update the close date for already closed items.
    UPDATE PON_AUCTION_ITEM_PRICES_ALL
          SET CLOSE_BIDDING_DATE = CLOSE_BIDDING_DATE + (x_new_close_date-p_close_date),
	  LAST_UPDATE_DATE= sysdate,
	  LAST_UPDATED_BY = p_user_id
    WHERE AUCTION_HEADER_ID = p_auction_header_id
          AND CLOSE_BIDDING_DATE > decode(v_ispaused, 'Y', v_pause_date, SYSDATE) ;


   -- for manual extend, if the need by date is before the new close bidding
   -- date, then need extend need by date behind the scene
   UPDATE PON_AUCTION_ITEM_PRICES_ALL
	  SET NEED_BY_DATE = NEED_BY_DATE + (x_new_close_date-p_close_date),
	  LAST_UPDATE_DATE= sysdate,
	  LAST_UPDATED_BY = p_user_id
    WHERE AUCTION_HEADER_ID = p_auction_header_id
          AND NEED_BY_DATE < x_new_close_date;

   UPDATE PON_AUCTION_ITEM_PRICES_ALL
          SET NEED_BY_START_DATE = NEED_BY_START_DATE + (x_new_close_date-p_close_date),
	  LAST_UPDATE_DATE= sysdate,
	  LAST_UPDATED_BY = p_user_id
    WHERE AUCTION_HEADER_ID = p_auction_header_id
          AND NEED_BY_START_DATE < x_new_close_date;

    -- Update AutoExtend information
    -- For the Auto-extension case, the p_new_autoextend_num represents
    -- additional extensions needed.  If it's set to unlimited, set the
    -- new auto extension number to unlimited, else add it to the number
    -- of extensions that have already occurred.
    if (p_is_autoExtend = 'Y') then
        if (p_new_autoextend_num = UNLIMITED_INT) then
           x_new_autoextend_num := UNLIMITED_INT;
        else
           x_new_autoextend_num := x_num_extension_occurred+p_new_autoextend_num;
        end if;
 	UPDATE PON_AUCTION_HEADERS_ALL
          SET AUTO_EXTEND_FLAG = 'Y',
          AUTO_EXTEND_NUMBER = x_new_autoextend_num,
          AUTO_EXTEND_ALL_LINES_FLAG = p_is_allExtend,
	  AUTO_EXTEND_DURATION = p_new_duration,
          AUTO_EXTEND_TYPE_FLAG = p_new_extend_type,
	  AUTOEXTEND_CHANGED_FLAG = 'Y',
          AUTO_EXTEND_MIN_TRIGGER_RANK = p_auto_extend_min_trigger
          WHERE AUCTION_HEADER_ID = p_auction_header_id;
   end if;

   -- Call WorkFlow
   -- dont call the work flow if the negotiation is paused (Resume Negotaition case).
   if (v_ispaused <> 'Y') then
   	   if ( p_close_date < x_new_close_date) then
	       pon_auction_pkg.CLOSECHANGED_AUCTION(p_auction_header_id,
                                           1,  -- type code
                                           x_new_close_date,
                                           NULL);
	   end if;
   end if;

   p_result := 0;

END MANUAL_EXTEND;

--
-- When deleting a new round draft negotiation, need to activate previous round negotiation
--


PROCEDURE ACTIVATE_PREV_ROUND_NEG (p_prev_round_auction_header_id IN NUMBER) IS

BEGIN

update pon_auction_headers_all
set    auction_status = 'ACTIVE'
where  auction_header_id = p_prev_round_auction_header_id;

END ACTIVATE_PREV_ROUND_NEG;


--
-- If the negotiation that the buyer is amending becomes closed or cancelled,
-- the buyer will not be able to submit the amendment.
-- An error messaage will be displayed to the buyer

PROCEDURE CAN_EDIT_DRAFT_AMEND (p_auction_header_id_prev_doc IN NUMBER,
                                x_error_code OUT NOCOPY VARCHAR2) IS


v_auction_status        VARCHAR2(25);
v_award_status          VARCHAR2(25);
v_view_by_date          DATE;
v_open_bidding_date     DATE;
v_close_bidding_date    DATE;
v_sysdate               DATE;
v_is_paused             VARCHAR2(1);

l_module_name           VARCHAR2(30) := 'CAN_EDIT_DRAFT_AMEND';

BEGIN

select auction_status, award_status, view_by_date, open_bidding_date, close_bidding_date, sysdate, NVL( is_paused, 'N')
into   v_auction_status, v_award_status, v_view_by_date, v_open_bidding_date, v_close_bidding_date, v_sysdate, v_is_paused
from   pon_auction_headers_all
where  auction_header_id = p_auction_header_id_prev_doc;

if v_is_paused <> 'Y' then

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'The auction is not paused.');
  END IF;

  if (v_close_bidding_date < v_sysdate OR
    v_auction_status is not null AND v_auction_status = 'CANCELLED') then
    x_error_code := 'ERROR';
  else
    x_error_code := 'SUCCESS';
  end if;
else
   x_error_code := 'SUCCESS';
end if;

END CAN_EDIT_DRAFT_AMEND;


--
-- Called during the amendment and new round processes, the procedure below
-- makes the necessary changes to move from the old document to the new one
-- Called from oracle.apps.pon.schema.server.AuctionHeadersALLEOImpl.java
--

PROCEDURE UPDATE_TO_NEW_DOCUMENT (p_auction_header_id_curr_doc IN NUMBER,
                                  p_doc_number_curr_doc IN VARCHAR2,
                                  p_auction_header_id_prev_doc IN NUMBER,
                                  p_auction_origination_code IN VARCHAR2,
                                  p_is_new IN VARCHAR2,
                                  p_is_publish IN VARCHAR2,
                                  p_transaction_type IN VARCHAR2,
                                  p_user_id IN NUMBER,
                                  x_error_code OUT NOCOPY VARCHAR2,
                                  x_error_msg OUT NOCOPY VARCHAR2) IS


v_temp DATE;
v_doc_number_prev_doc pon_auction_headers_all.document_number%TYPE;

BEGIN

   x_error_code := 'SUCCESS';
   x_error_msg  := '';

   -- lock negotiation
   SELECT LAST_UPDATE_DATE, document_number
   INTO v_temp, v_doc_number_prev_doc
   FROM PON_AUCTION_HEADERS_ALL
   WHERE AUCTION_HEADER_ID = p_auction_header_id_prev_doc
   FOR UPDATE;

   -- when saving the document for the first time...
      --  change the status of the previous round document
      --  copy negotiation references in our tables (pon_backing_requisitions)


   if (p_is_new = 'Y') then

      -- update status of previous round document

      if (p_transaction_type = 'CREATE_NEW_ROUND') then

         update pon_auction_headers_all
           set  AWARD_STATUS = 'NO',
                AUCTION_STATUS = 'AUCTION_CLOSED',
                LAST_UPDATE_DATE = sysdate,
                LAST_UPDATED_BY = p_user_id
         where auction_header_id = p_auction_header_id_prev_doc;

      end if;

      -- if an autocreated document is being taken to a new round or amended,
      -- copy negotiation references locally

      if (p_auction_origination_code = 'REQUISITION') then

         PON_AUCTION_PKG.COPY_BACKING_REQ(p_auction_header_id_prev_doc, p_auction_header_id_curr_doc, x_error_code);

      end if;


   end if;



   -- when publishing the document....
       -- call PO api to change negotiation references in their tables
       -- if we're amended a document
       --      1) change the auction status and award status of the previous amendment to be AMENDED and NO respectively
       --      2) update previous 'ACTIVE' bids to be 'RESUBMISSION_REQUIRED'


   if (p_is_publish = 'Y' and x_error_code = 'SUCCESS') then

      if (p_auction_origination_code = 'REQUISITION') then

         PON_AUCTION_PKG.UPDATE_NEGOTIATION_REF(p_auction_header_id_prev_doc, v_doc_number_prev_doc, p_auction_header_id_curr_doc, p_doc_number_curr_doc, x_error_code, x_error_msg);

      end if;

      -- previous active bids are no longer valid
      -- suppliers will need to acknowledge amendments before their bid
      -- becomes active again


      -- update pause details also.
      if (p_transaction_type = 'CREATE_AMENDMENT') then

         update pon_auction_headers_all
           set  AWARD_STATUS = 'NO',
                AUCTION_STATUS = 'AMENDED',
		is_paused = null,
		pause_remarks = null,
		last_pause_date = null,
                LAST_UPDATE_DATE = sysdate,
                LAST_UPDATED_BY = p_user_id
         where auction_header_id = p_auction_header_id_prev_doc;

         update pon_bid_headers
           set  BID_STATUS = 'RESUBMISSION'
         where  auction_header_id = p_auction_header_id_prev_doc and
                bid_status = 'ACTIVE';

      end if;


   end if;


END UPDATE_TO_NEW_DOCUMENT;


-- Updates the modified flag and last_amendment_update columns by comparing
-- the values of the user-enterable fields of the new negotiation
-- to the previous negotiation

PROCEDURE UPDATE_MODIFIED_FIELDS (p_currAuctionHeaderId IN NUMBER,
                                  p_prevAuctionHeaderId IN NUMBER,
                                  p_action IN VARCHAR2) IS

BEGIN

  UPDATE_NEG_TEAM_MODIFIED(p_currAuctionHeaderId, p_prevAuctionHeaderId, p_action);

  UPDATE_CURRENCY_RATES_MODIFIED(p_currAuctionHeaderId, p_prevAuctionHeaderId, p_action);

  UPDATE_INVITEES_MODIFIED(p_currAuctionHeaderId, p_prevAuctionHeaderId, p_action);

  UPDATE_HDR_ATTR_MODIFIED(p_currAuctionHeaderId, p_prevAuctionHeaderId, p_action);

END UPDATE_MODIFIED_FIELDS;


-- Updates the modified flag and last_amendment_update columns by comparing
-- the values of the user-enterable fields of the new negotiation
-- to the previous negotiation

PROCEDURE UPDATE_CURRENCY_RATES_MODIFIED (p_currAuctionHeaderId IN NUMBER,
                                          p_prevAuctionHeaderId IN NUMBER,
                                          p_action IN VARCHAR2) IS

v_currAmendmentNumber NUMBER;

BEGIN

   select nvl(amendment_number, 0)
   into   v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;


   -- first, reset the modified flag and last amendment update columns

   if (p_action = 'MULTIROUND') then

     update pon_auction_currency_rates
       set  MODIFIED_FLAG = null,
            LAST_AMENDMENT_UPDATE = 0
     where auction_header_id = p_currAuctionHeaderId;

   else

     update pon_auction_currency_rates rates
       set  MODIFIED_FLAG = null,
            LAST_AMENDMENT_UPDATE = (select nvl(last_amendment_update, 0)
                                     from   pon_auction_currency_rates
                                     where  auction_header_id = p_prevAuctionHeaderId and
                                            bid_currency_code = rates.bid_currency_code)
     where   auction_header_id = p_currAuctionHeaderId;

     -- since above query will set last_amendment_update to null for new rows
     -- need to set last_amendment_update to current amendment number for those rows

     update pon_auction_currency_rates rates
       set  LAST_AMENDMENT_UPDATE = v_currAmendmentNumber
     where  auction_header_id = p_currAuctionHeaderId and
            last_amendment_update is null;

   end if;

   -- next, do pairwise comparisons to find updated rows

   update pon_auction_currency_rates currRates
     set  MODIFIED_FLAG = 'Y',
          LAST_AMENDMENT_UPDATE = v_currAmendmentNumber
   where auction_header_id = p_currAuctionHeaderId and
         exists (select null
                 from   pon_auction_currency_rates prevRates
                 where  prevRates.auction_header_id = p_prevAuctionHeaderId and
                        prevRates.bid_currency_code = currRates.bid_currency_code and
                        (nvl(prevRates.rate_dsp, -9999) <> nvl(currRates.rate_dsp, -9999) or
                         nvl(prevRates.number_price_decimals, -9999) <> nvl(currRates.number_price_decimals, -9999)));

END UPDATE_CURRENCY_RATES_MODIFIED;

-- Updates the modified flag and last_amendment_update columns by comparing
-- the values of the user-enterable fields of the new negotiation
-- to the previous negotiation

PROCEDURE UPDATE_NEG_TEAM_MODIFIED (p_currAuctionHeaderId IN NUMBER,
                                    p_prevAuctionHeaderId IN NUMBER,
                                    p_action IN VARCHAR2) IS

v_currAmendmentNumber NUMBER;

BEGIN

   select nvl(amendment_number, 0)
   into   v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;


   -- first, reset the modified flag and last amendment update columns

   if (p_action = 'MULTIROUND') then

     update pon_neg_team_members
       set  MODIFIED_FLAG = null,
            LAST_AMENDMENT_UPDATE = 0
     where auction_header_id = p_currAuctionHeaderId;

   else

     update pon_neg_team_members neg
       set  MODIFIED_FLAG = null,
            LAST_AMENDMENT_UPDATE = (select nvl(last_amendment_update, 0)
                                     from   pon_neg_team_members
                                     where  auction_header_id = p_prevAuctionHeaderId and
                                            user_id = neg.user_id)
   where   auction_header_id = p_currAuctionHeaderId;

     -- since above query will set last_amendment_update to null for new rows
     -- need to set last_amendment_update to current amendment number for those rows

     update pon_neg_team_members neg
       set  LAST_AMENDMENT_UPDATE = v_currAmendmentNumber
     where  auction_header_id = p_currAuctionHeaderId and
            last_amendment_update is null;

   end if;

   -- next, do pairwise comparisons to find updated rows

   update pon_neg_team_members currNeg
     set  MODIFIED_FLAG = 'Y',
          LAST_AMENDMENT_UPDATE = v_currAmendmentNumber
   where auction_header_id = p_currAuctionHeaderId and
         exists (select null
                 from   pon_neg_team_members prevNeg
                 where  prevNeg.auction_header_id = p_prevAuctionHeaderId and
                        prevNeg.user_id = currNeg.user_id and

                        (nvl(prevNeg.approver_flag, 'N') <> nvl(currNeg.approver_flag, 'N') or
                         nvl(prevNeg.menu_name, 'PON_SOURCING_VIEWNEG') <> nvl(currNeg.menu_name, 'PON_SOURCING_VIEWNEG') or
                         nvl(prevNeg.task_name, 'null') <> nvl(currNeg.task_name, 'null') or
                         nvl(prevNeg.target_date, sysdate) <> nvl(currNeg.target_date, sysdate)));


END UPDATE_NEG_TEAM_MODIFIED;

-- Updates the modified flag and last_amendment_update columns by comparing
-- the values of the user-enterable fields of the new negotiation
-- to the previous negotiation

PROCEDURE UPDATE_INVITEES_MODIFIED (p_currAuctionHeaderId IN NUMBER,
                                    p_prevAuctionHeaderId IN NUMBER,
                                    p_action IN VARCHAR2) IS

v_currAmendmentNumber NUMBER;

BEGIN

   select nvl(amendment_number, 0)
   into   v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;

   -- first, reset the modified flag and last amendment update columns
   -- only if modified flag is not "P" or "S" ...
   -- the value "P" indicates that the buyer price factor values have been modified
   -- and the value "S" indicates that the Supplier Access has been modified
   -- so regardless if supplier info (contact, currency, etc...) has changed
   -- modified flag will still have a value of "P" or "S"...
   -- this will influence all sql below...

   if (p_action = 'MULTIROUND') then

     update pon_bidding_parties
       set  MODIFIED_FLAG = null,
            LAST_AMENDMENT_UPDATE = 0
     where auction_header_id = p_currAuctionHeaderId and
           nvl(modified_flag, 'N') <> 'P' and
           nvl(modified_flag, 'N') <> 'S';

   else

   update pon_bidding_parties invitees
     set  MODIFIED_FLAG = null,
          LAST_AMENDMENT_UPDATE = (select nvl(last_amendment_update, 0)
                                   from   pon_bidding_parties
                                   where  auction_header_id = p_prevAuctionHeaderId and
                                          (trading_partner_id = invitees.trading_partner_id
                                    OR requested_supplier_id =invitees.requested_supplier_id) and
                                          nvl(vendor_site_id, -9999) = nvl(invitees.vendor_site_id, -9999))
   where   auction_header_id = p_currAuctionHeaderId and
           nvl(modified_flag, 'N') <> 'P' and
           nvl(modified_flag, 'N') <> 'S';

     -- since above query will set last_amendment_update to null for new rows
     -- need to set last_amendment_update to current amendment number for those rows

     update pon_bidding_parties invitees
       set  LAST_AMENDMENT_UPDATE = v_currAmendmentNumber
     where  auction_header_id = p_currAuctionHeaderId and
            last_amendment_update is null;

   end if;

   -- next, do pairwise comparisons to find updated rows

   update pon_bidding_parties currInvitees
     set  MODIFIED_FLAG = 'Y',
          LAST_AMENDMENT_UPDATE = v_currAmendmentNumber
   where auction_header_id = p_currAuctionHeaderId and
         nvl(modified_flag, 'N') <> 'P' and
         nvl(modified_flag, 'N') <> 'S' and
          exists (select null
                  from   pon_bidding_parties prevInvitees
                  where  prevInvitees.auction_header_id = p_prevAuctionHeaderId and
                         (prevInvitees.trading_partner_id = currInvitees.trading_partner_id
                           or prevInvitees.requested_supplier_id = currInvitees.requested_supplier_id) and
                         nvl(prevInvitees.vendor_site_id, -9999) = nvl(currInvitees.vendor_site_id, -9999) and
                         (nvl(prevInvitees.trading_partner_contact_id, -9999) <> nvl(currInvitees.trading_partner_contact_id, -9999) or
                          nvl(prevInvitees.requested_supplier_contact_id, -999) <> nvl(currInvitees.requested_supplier_contact_id, -999) or
                          nvl(prevInvitees.additional_contact_email, 'null') <> nvl(currInvitees.additional_contact_email, 'null') or
                          nvl(prevInvitees.bid_currency_code, 'null') <> nvl(currInvitees.bid_currency_code, 'null') or
                          nvl(prevInvitees.rate_dsp, -9999) <> nvl(currInvitees.rate_dsp, -9999) or
                          nvl(prevInvitees.number_price_decimals, -9999) <> nvl(currInvitees.number_price_decimals, -9999)));


END UPDATE_INVITEES_MODIFIED;

-- Updates the modified flag and last_amendment_update columns by comparing
-- the values of the user-enterable fields of the new negotiation
-- to the previous negotiation

PROCEDURE UPDATE_HDR_ATTR_MODIFIED (p_currAuctionHeaderId IN NUMBER,
                                             p_prevAuctionHeaderId IN NUMBER,
                                             p_action IN VARCHAR2) IS

v_currAmendmentNumber NUMBER;

BEGIN

   select nvl(amendment_number, 0)
   into   v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;


   -- first, reset the modified flag and last amendment update columns

   if (p_action = 'MULTIROUND') then

     update pon_auction_attributes auctionAttr
       set  MODIFIED_FLAG = null,
            MODIFIED_DATE = (select modified_date
                             from pon_auction_attributes
                             where auction_header_id = p_prevAuctionHeaderId and
                                   sequence_number = auctionAttr.sequence_number and
                                   line_number = -1),
            LAST_AMENDMENT_UPDATE = 0
     where auction_header_id = p_currAuctionHeaderId
       and line_number       = -1;

     -- since above query will set modified_date to null for new rows
     -- need to set modified_date to sysdate for those rows

     update pon_auction_attributes auctionAttr
       set  MODIFIED_DATE = sysdate
     where  auction_header_id = p_currAuctionHeaderId and
            line_number = -1 and
            modified_date is null;

   else

     update pon_auction_attributes auctionAttr
       set   MODIFIED_FLAG = null,
             MODIFIED_DATE = (select modified_date
                              from pon_auction_attributes
                              where auction_header_id = p_prevAuctionHeaderId and
                                    sequence_number = auctionAttr.sequence_number and
                        	    line_number = -1),
             LAST_AMENDMENT_UPDATE = (select nvl(last_amendment_update, 0)
                                          from  pon_auction_attributes
                                          where auction_header_id = p_prevAuctionHeaderId and
                                                sequence_number =  auctionAttr.sequence_number and
                                                line_number = -1)
       where   auction_header_id = p_currAuctionHeaderId
       and   line_number       = -1;

     -- since above query will set modified_date and last_amendment_update to null for new rows
     -- need to set modified_date and last_amendment_update to sysdate and current amendment number respectively for those rows

     update pon_auction_attributes auctionAttr
       set  MODIFIED_DATE = sysdate,
            LAST_AMENDMENT_UPDATE = v_currAmendmentNumber
     where  auction_header_id  = p_currAuctionHeaderId and
            line_number = -1 and
            last_amendment_update is null;

   end if;

   -- next, do pairwise comparisons to find updated rows

   update pon_auction_attributes currAttr
   set  MODIFIED_FLAG = 'Y',
        MODIFIED_DATE = sysdate,
        LAST_AMENDMENT_UPDATE = v_currAmendmentNumber
   where auction_header_id = p_currAuctionHeaderId and
         line_number = -1 and
         exists (select null
                 from   pon_auction_attributes prevAttr
                 where  prevAttr.auction_header_id = p_prevAuctionHeaderId and
                        prevAttr.line_number = -1 and
                        prevAttr.sequence_number = currAttr.sequence_number and
   (nvl(currAttr.attribute_name, 'null') <> nvl(prevAttr.attribute_name, 'null') OR
    nvl(currAttr.description, 'null') <> nvl(prevAttr.description, 'null') OR
    nvl(currAttr.datatype, 'null')    <> nvl(prevAttr.datatype, 'null') OR
    nvl(currAttr.mandatory_flag, 'null') <> nvl(prevAttr.mandatory_flag, 'null') OR
    nvl(currAttr.value, 'null')	     <> nvl(prevAttr.value, 'null') OR
    nvl(currAttr.display_prompt, 'null') <> nvl(prevAttr.display_prompt, 'null') OR
    nvl(currAttr.help_text, 'null')	 <> nvl(prevAttr.help_text, 'null') OR
    nvl(currAttr.display_target_flag, 'null') <> nvl(prevAttr.display_target_flag, 'null') OR
    nvl(currAttr.attribute_list_id, -99) <> nvl(prevAttr.attribute_list_id, -99) OR
    nvl(currAttr.display_only_flag, 'null') <> nvl(prevAttr.display_only_flag, 'null') OR
    nvl(currAttr.copied_from_cat_flag, 'null') <> nvl(prevAttr.copied_from_cat_flag, 'null') OR
    nvl(currAttr.weight, -99) <> nvl(prevAttr.weight, -99) OR
    nvl(currAttr.scoring_type, 'null') <> nvl(prevAttr.scoring_type, 'null') OR    nvl(currAttr.attr_level, 'null')   <> nvl(prevAttr.attr_level, 'null') OR
    nvl(currAttr.attr_group, 'null')   <> nvl(prevAttr.attr_group, 'null') OR
    nvl(currAttr.attr_max_score, -99)  <> nvl(prevAttr.attr_max_score, -99) OR
    nvl(currAttr.internal_attr_flag, 'null')  <> nvl(prevAttr.internal_attr_flag, 'null')));

END UPDATE_HDR_ATTR_MODIFIED;

-- As a general rule...
--       Any action taken outside of the amendment process on
--       them most current negotiation will indirectly be taken on
--       the previous amended negotiations

-- The following function is to add suppliers to previous amended negotiations
-- if suppliers are added from the Invite Additional Suppliers page

PROCEDURE PROPAGATE_BACK_INSERT_INVITEE(p_currAuctionHeaderId IN NUMBER,
                                        p_sequence IN NUMBER ) IS

v_auctionHeaderIdOrigAmend NUMBER;
v_currAmendmentNumber NUMBER;

BEGIN

   select auction_header_id_orig_amend, nvl(amendment_number, 0)
   into   v_auctionHeaderIdOrigAmend, v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;

   insert into pon_bidding_parties
          (auction_header_id,
           list_id,
           last_update_date,
           last_updated_by,
           sequence,
           trading_partner_name,
           trading_partner_id,
           trading_partner_contact_name,
           trading_partner_contact_id,
           wf_user_name,
           creation_date,
           created_by,
           bid_currency_code,
           number_price_decimals,
           rate,
           derive_type,
           additional_contact_email,
           round_number,
           registration_id,
           rate_dsp,
           wf_item_key,
           last_amendment_update,
           vendor_site_id,
           vendor_site_code,
           modified_flag,
           access_type)

    select pah.auction_header_id,
           pbp.list_id,
           pbp.last_update_date,
           pbp.last_updated_by,
           pbp.sequence,
           pbp.trading_partner_name,
           pbp.trading_partner_id,
           pbp.trading_partner_contact_name,
           pbp.trading_partner_contact_id,
           pbp.wf_user_name,
           pbp.creation_date,
           pbp.created_by,
           pbp.bid_currency_code,
           pbp.number_price_decimals,
           pbp.rate,
           pbp.derive_type,
           pbp.additional_contact_email,
           pbp.round_number,
           pbp.registration_id,
           pbp.rate_dsp,
           pbp.wf_item_key,
           pbp.last_amendment_update,
           pbp.vendor_site_id,
           pbp.vendor_site_code,
           pbp.modified_flag,
           pbp.access_type
     from  pon_auction_headers_all pah,
           pon_bidding_parties pbp
     where pah.auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
           pah.amendment_number < v_currAmendmentNumber and
           pbp.auction_header_id = p_currAuctionHeaderId and
           pbp.sequence = p_sequence ;

END PROPAGATE_BACK_INSERT_INVITEE;

-- As a general rule...
--       Any action taken outside of the amendment process on
--       them most current negotiation will indirectly be taken on
--       the previous amended negotiations

-- The following function is to update supplier acknowledgments in
-- previous amended negotiations

PROCEDURE PROPAGATE_BACK_UPDATE_INVITEE(p_currAuctionHeaderId IN NUMBER,
                                        p_sequence IN NUMBER) IS

v_auctionHeaderIdOrigAmend NUMBER;
v_currAmendmentNumber NUMBER;

BEGIN

   select auction_header_id_orig_amend, nvl(amendment_number, 0)
   into   v_auctionHeaderIdOrigAmend, v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;

   update pon_bidding_parties pbp
     set (ack_partner_contact_id, supp_acknowledgement, ack_note_to_auctioneer, acknowledgement_time) =

    (select currPbp.ack_partner_contact_id, currPbp.supp_acknowledgement, currPbp.ack_note_to_auctioneer, currPbp.acknowledgement_time
     from   pon_bidding_parties currPbp
     where  currPbp.auction_header_id = p_currAuctionHeaderId and
            currPbp.sequence = p_sequence)

   where pbp.auction_header_id in (select auction_header_id from pon_auction_headers_all where auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and amendment_number <> v_currAmendmentNumber) and
         pbp.sequence = p_sequence ;

END PROPAGATE_BACK_UPDATE_INVITEE;

-- As a general rule...
--       Any action taken outside of the amendment process on
--       them most current negotiation will indirectly be taken on
--       the previous amended negotiations

-- The following function is to add collaboration team members to
-- previous amended negotiations if members are added from the
-- Manage Collaboration Team page

PROCEDURE PROPAGATE_BACK_INSERT_MEMBER(p_currAuctionHeaderId IN NUMBER,
                                       p_userId IN NUMBER) IS

v_auctionHeaderIdOrigAmend NUMBER;
v_currAmendmentNumber NUMBER;

BEGIN

   select auction_header_id_orig_amend, nvl(amendment_number, 0)
   into   v_auctionHeaderIdOrigAmend, v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;

   insert into pon_neg_team_members
          (auction_header_id,
           list_id,
           user_id,
           menu_name,
           member_type,
           approver_flag,
           approval_status,
           task_name,
           target_date,
           completion_date,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_amendment_update,
           modified_flag)

   select  pah.auction_header_id,
           pntm.list_id,
           pntm.user_id,
           pntm.menu_name,
           pntm.member_type,
           pntm.approver_flag,
           pntm.approval_status,
           pntm.task_name,
           pntm.target_date,
           pntm.completion_date,
           pntm.creation_date,
           pntm.created_by,
           pntm.last_update_date,
           pntm.last_updated_by,
           pntm.last_amendment_update,
           pntm.modified_flag
     from  pon_auction_headers_all pah,
           pon_neg_team_members pntm
     where pah.auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
           pah.amendment_number < v_currAmendmentNumber and
           pntm.auction_header_id = p_currAuctionHeaderId and
           pntm.user_id = p_userId;

END PROPAGATE_BACK_INSERT_MEMBER;

PROCEDURE PROPAGATE_BACK_UNLOCK(p_currAuctionHeaderId IN NUMBER,
                                p_userId              IN NUMBER,
                                p_unlock_date         IN DATE,
				p_unlock_type	      IN VARCHAR2) IS

v_auctionHeaderIdOrigAmend NUMBER;
v_currAmendmentNumber NUMBER;
l_module_name VARCHAR2 (30);

BEGIN

   l_module_name := 'PROPAGATE_BACK_UNLOCK';

   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
     FND_LOG.string (log_level => FND_LOG.level_procedure,
       module => g_module_prefix || l_module_name,
       message => 'Entered procedure = ' || l_module_name || '.' ||
                  ' Parameters: p_currAuctionHeaderId = ' || p_currAuctionHeaderId || ', ' ||
                  ' p_userId = ' || p_userId || ', ' || ' p_unlock_date = ' || p_unlock_date || ', ' ||
		  ' p_unlock_type = ' || p_unlock_type);
   END IF;

   select auction_header_id_orig_amend, nvl(amendment_number, 0)
   into   v_auctionHeaderIdOrigAmend, v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;

   IF p_unlock_type = 'Technical' THEN
	update pon_auction_headers_all
   	set    technical_lock_status = 'UNLOCKED',
               technical_unlock_tp_contact_id = p_userId,
               technical_actual_unlock_date = p_unlock_date
   	where  auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
               amendment_number < v_currAmendmentNumber;
   ELSE
	update pon_auction_headers_all
   	set    sealed_auction_status = 'UNLOCKED',
               sealed_unlock_tp_contact_id = p_userId,
               sealed_actual_unlock_date = p_unlock_date
   	where  auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
               amendment_number < v_currAmendmentNumber;
   END IF;

   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
     FND_LOG.string (log_level => FND_LOG.level_procedure,
       module => g_module_prefix || l_module_name,
       message => 'Leaving procedure = ' || l_module_name);
   END IF;

END PROPAGATE_BACK_UNLOCK;

PROCEDURE PROPAGATE_BACK_UNSEAL(p_currAuctionHeaderId IN NUMBER,
                                p_userId              IN NUMBER,
                                p_unseal_date         IN DATE,
				p_unseal_type	      IN VARCHAR2) IS

v_auctionHeaderIdOrigAmend NUMBER;
v_currAmendmentNumber NUMBER;
v_technicalLockStatus VARCHAR2(20);
l_module_name VARCHAR2 (30);

BEGIN

   l_module_name := 'PROPAGATE_BACK_UNSEAL';

   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
     FND_LOG.string (log_level => FND_LOG.level_procedure,
       module => g_module_prefix || l_module_name,
       message => 'Entered procedure = ' || l_module_name || '.' ||
                  ' Parameters: p_currAuctionHeaderId = ' || p_currAuctionHeaderId || ', ' ||
                  ' p_userId = ' || p_userId || ', ' || ' p_unseal_date = ' || p_unseal_date || ', ' ||
		  ' p_unseal_type = ' || p_unseal_type);
   END IF;

   select auction_header_id_orig_amend, nvl(amendment_number, 0), technical_lock_status
   into   v_auctionHeaderIdOrigAmend, v_currAmendmentNumber, v_technicalLockStatus
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;

   IF p_unseal_type = 'Technical' THEN
	update pon_auction_headers_all
   	set    technical_lock_status = 'ACTIVE',
               technical_unseal_tp_contact_id = p_userId,
               technical_actual_unseal_date = p_unseal_date
   	where  auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
               amendment_number < v_currAmendmentNumber;

   ELSIF p_unseal_type = 'Commercial' THEN
	IF v_technicalLockStatus = 'ACTIVE' THEN
	   update pon_auction_headers_all
   	   set    sealed_auction_status = 'ACTIVE',
                  sealed_unseal_tp_contact_id = p_userId,
                  sealed_actual_unseal_date = p_unseal_date
   	   where  auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
                  amendment_number < v_currAmendmentNumber;
	ELSE
   	   update pon_auction_headers_all
   	   set    sealed_auction_status = 'ACTIVE',
	          sealed_unseal_tp_contact_id = p_userId,
                  sealed_actual_unseal_date = p_unseal_date,
	          technical_lock_status = 'ACTIVE',
                  technical_unseal_tp_contact_id = p_userId,
                  technical_actual_unseal_date = p_unseal_date
   	   where  auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
                  amendment_number < v_currAmendmentNumber;
	END IF;
   ELSE
   	update pon_auction_headers_all
   	set    sealed_auction_status = 'ACTIVE',
               sealed_unseal_tp_contact_id = p_userId,
               sealed_actual_unseal_date = p_unseal_date
   	where  auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
               amendment_number < v_currAmendmentNumber;
   END IF;

   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
     FND_LOG.string (log_level => FND_LOG.level_procedure,
       module => g_module_prefix || l_module_name,
       message => 'Leaving procedure = ' || l_module_name);
   END IF;

END PROPAGATE_BACK_UNSEAL;

PROCEDURE PROCESS_PRICE_FACTORS(p_auction_header_id IN NUMBER,
                                p_user_id           IN NUMBER,
                                p_login_id          IN NUMBER) IS

l_auction_has_price_elements VARCHAR2(2);
BEGIN

 SELECT HAS_PRICE_ELEMENTS
 INTO l_auction_has_price_elements
 FROM PON_AUCTION_HEADERS_ALL
 WHERE AUCTION_HEADER_ID = p_auction_header_id;

 IF ('Y' = l_auction_has_price_elements) THEN

   insert into pon_price_elements
          (auction_header_id,
           line_number,
           list_id,
           price_element_type_id,
           pricing_basis,
           value,
           display_target_flag,
           sequence_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           pf_type,
           display_to_suppliers_flag)

    select auction_header_id,
           line_number,
           -1,
           -10,
           decode(order_type_lookup_code, 'FIXED PRICE', 'FIXED_AMOUNT', 'PER_UNIT'),
           unit_target_price,
           unit_display_target_flag,
           -10,
           sysdate,
           p_user_id,
           sysdate,
           p_user_id,
           'SUPPLIER',
           'Y'
    from   pon_auction_item_prices_all
    where  auction_header_id = p_auction_header_id and
           (has_price_elements_flag = 'Y' or has_buyer_pfs_flag = 'Y');

    insert into pon_pf_supplier_formula
           (auction_header_id,
            line_number,
            trading_partner_id,
            vendor_site_id,
            unit_price,
            fixed_amount,
            percentage,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)

    select  paip.auction_header_id,
            paip.line_number,
            pbp.trading_partner_id,
            pbp.vendor_site_id,
            sum(decode(ppe.pricing_basis, 'PER_UNIT', ppsv.value, 0)) unit_price,
            sum(decode(ppe.pricing_basis, 'FIXED_AMOUNT', ppsv.value, 0)) fixed_amount,
            1 + sum(decode(ppe.pricing_basis, 'PERCENTAGE', ppsv.value/100, 0)) percentage,
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            p_login_id
    from    pon_auction_item_prices_all paip,
            pon_bidding_parties pbp,
            pon_pf_supplier_values ppsv,
            pon_price_elements ppe
    where   paip.auction_header_id = p_auction_header_id and
            pbp.auction_header_id = paip.auction_header_id and
            pbp.auction_header_id = ppsv.auction_header_id and
            pbp.sequence = ppsv.supplier_seq_number and
            paip.line_number = ppsv.line_number and
            ppsv.auction_header_id = ppe.auction_header_id and
            ppsv.line_number = ppe.line_number and
            ppsv.pf_seq_number = ppe.sequence_number
    group by paip.auction_header_id, paip.line_number, pbp.trading_partner_id, pbp.vendor_site_id;

  END IF;

END PROCESS_PRICE_FACTORS;

PROCEDURE MANUAL_CLOSE_LINE (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_line_number IN NUMBER,
  p_user_id IN NUMBER,
  x_is_auction_closed OUT NOCOPY VARCHAR2
) IS

l_module_name VARCHAR2 (30);
x_temp PON_AUCTION_HEADERS_ALL.LAST_UPDATE_DATE%TYPE;
x_close_bidding_date PON_AUCTION_HEADERS_ALL.CLOSE_BIDDING_DATE%TYPE;
v_auction_last_line_number PON_AUCTION_ITEM_PRICES_ALL.LINE_NUMBER%TYPE;
p_new_close_date PON_AUCTION_HEADERS_ALL.CLOSE_BIDDING_DATE%TYPE;
BEGIN

  l_module_name := 'MANUAL_CLOSE_LINE';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name || '.' ||
                 ' Parameters: p_auction_header_id = ' || p_auction_header_id || ', ' ||
                 ' p_user_id = ' || p_user_id);
  END IF;

  -- lock negotiation header
  SELECT LAST_UPDATE_DATE, CLOSE_BIDDING_DATE
  INTO x_temp, x_close_bidding_date
  FROM PON_AUCTION_HEADERS_ALL
  WHERE AUCTION_HEADER_ID = p_auction_header_id
  FOR UPDATE;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module => g_module_prefix || l_module_name,
      message => 'Locked the negotiation header');
  END IF;

  -- update header date
  update pon_auction_headers_all
  set last_update_date = sysdate,
      last_updated_by = p_user_id
  where auction_header_id = p_auction_header_id;

  p_new_close_date := sysdate;

  -- update item close date
  update pon_auction_item_prices_all
  set close_bidding_date = p_new_close_date,
  last_update_date = sysdate,
  last_updated_by = p_user_id
  where auction_header_id = p_auction_header_id
  and (line_number = p_line_number
  or parent_line_number = p_line_number);

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module => g_module_prefix || l_module_name,
      message => 'Update header and the line.');
  END IF;

  --In case this is the last line then the auction has to be closed.
  select line_number into v_auction_last_line_number
  from pon_auction_item_prices_all
  where auction_header_id = p_auction_header_id
  and disp_line_number  =
    (select max(disp_line_number)
     from pon_auction_item_prices_all
     where auction_header_id=p_auction_header_id
     and group_type in ('LINE', 'LOT', 'GROUP'));

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module => g_module_prefix || l_module_name,
      message => 'The last line in the auction is = ' || v_auction_last_line_number);
  END IF;

  if (p_line_number = v_auction_last_line_number) then

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'The last line number in the auction matches with p_line_number, closing the negotiation');
    END IF;

    update pon_auction_headers_all set close_bidding_date = p_new_close_date
    where auction_header_id = p_auction_header_id;
    x_is_auction_closed := 'Y';

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Updated header sending notification.');
    END IF;

    pon_auction_pkg.CLOSEEARLY_AUCTION(p_auction_header_id,
                                         p_new_close_date,
                                         null);
  end if;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END MANUAL_CLOSE_LINE;

PROCEDURE PROPAGATE_BACK_TECH_EVAL(p_currAuctionHeaderId IN NUMBER,
				   p_tech_eval_status    IN VARCHAR2) IS

v_auctionHeaderIdOrigAmend NUMBER;
v_currAmendmentNumber NUMBER;
l_module_name VARCHAR2 (30);

BEGIN

   l_module_name := 'PROPAGATE_BACK_TECH_EVAL';

   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
     FND_LOG.string (log_level => FND_LOG.level_procedure,
       module => g_module_prefix || l_module_name,
       message => 'Entered procedure = ' || l_module_name || '.' ||
                  ' Parameters: p_currAuctionHeaderId = ' || p_currAuctionHeaderId || ', ' ||
                  ' p_tech_eval_status = ' || p_tech_eval_status);
   END IF;

   select auction_header_id_orig_amend, nvl(amendment_number, 0)
   into   v_auctionHeaderIdOrigAmend, v_currAmendmentNumber
   from   pon_auction_headers_all
   where  auction_header_id = p_currAuctionHeaderId;

	update pon_auction_headers_all
	set    technical_evaluation_status = p_tech_eval_status
	where  auction_header_id_orig_amend = v_auctionHeaderIdOrigAmend and
	       amendment_number < v_currAmendmentNumber;

   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
     FND_LOG.string (log_level => FND_LOG.level_procedure,
       module => g_module_prefix || l_module_name,
       message => 'Leaving procedure = ' || l_module_name);
   END IF;

END PROPAGATE_BACK_TECH_EVAL;

END PON_NEG_UPDATE_PKG;

/
