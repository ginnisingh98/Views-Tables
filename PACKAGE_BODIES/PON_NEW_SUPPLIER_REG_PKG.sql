--------------------------------------------------------
--  DDL for Package Body PON_NEW_SUPPLIER_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_NEW_SUPPLIER_REG_PKG" as
-- $Header: PONNSRB.pls 120.3.12010000.4 2013/09/16 04:32:02 puppulur ship $

--
----------------------------------------
--When a supplier is approved in iSP, iSP calls back
--on Sourcing to update our records with the hz_party_ids
--of the approved supplier and suppleir contacts.
-- apart from updating the trading_partner_ids in various
-- tables, the callback procedure creates user roles for
-- these supplier users so that they can get all the
-- notifications this point onwards.
-- created on 05/20/2005 by snatu
---------------------------------------
PROCEDURE SRC_POS_REG_SUPPLIER_CALLBACK
  (
   x_return_status            OUT NOCOPY  VARCHAR2,
   x_msg_count                OUT NOCOPY  NUMBER,
   x_msg_data                 OUT NOCOPY  VARCHAR2,
   p_requested_supplier_id    IN          NUMBER,
   p_po_vendor_id             IN          NUMBER,
   p_supplier_hz_party_id     IN          NUMBER,
   p_user_id                  IN          NUMBER
  )
IS
--
   l_current_date CONSTANT DATE := sysdate;

   TYPE NUMBER_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_req_contact_id NUMBER_TYPE;
   l_auction_header_id NUMBER_TYPE;

   TYPE VARCHAR2_WF_ROLE_TYPE IS TABLE OF VARCHAR2(320) INDEX BY BINARY_INTEGER;
   l_wf_role_name VARCHAR2_WF_ROLE_TYPE;

   l_org_id PON_AUCTION_HEADERS_ALL.ORG_ID%TYPE;
   l_party_id PON_BIDDING_PARTIES.TRADING_PARTNER_ID%TYPE;
   l_vendor_contact_id PON_BIDDING_PARTIES.TRADING_PARTNER_CONTACT_ID%TYPE;
   l_user_name FND_USER.USER_NAME%TYPE;

   -- Bug 9222914
   CURSOR bids_cursor IS
     SELECT ah.intgr_hdr_attach_flag,
            ah.auction_header_id,
            bh.bid_number
     FROM pon_auction_headers_all ah,
          pon_bid_headers bh
     WHERE ah.auction_header_id = bh.auction_header_id
       AND ah.auction_status = 'AUCTION_CLOSED'
       AND bh.bid_status = 'ACTIVE'
       AND bh.trading_partner_id = p_requested_supplier_id
       AND bh.vendor_id = -1;
--
--
BEGIN
-- updates PBP with the name and id from hz_parties
	UPDATE pon_bidding_parties
	SET trading_partner_id = p_supplier_hz_party_id,
	trading_partner_name = (
	          select party_name from hz_parties where party_id = p_supplier_hz_party_id),
        requested_supplier_id = null,
        requested_supplier_name = null,
	last_update_date = l_current_date,
	last_updated_by = nvl(p_user_id,last_updated_by)
	WHERE
	requested_supplier_id = p_requested_supplier_id;
--
-- Begin Bug 9222914
-- Integrate Header Attachments
	FOR bid IN bids_cursor LOOP
	  IF (bid.intgr_hdr_attach_flag = 'Y') THEN
	    fnd_attached_documents2_pkg.copy_attachments(
	      X_from_entity_name => 'PON_BID_HEADERS',
	      X_from_pk1_value => bid.auction_header_id,
	      X_from_pk2_value => bid.bid_number,
	      X_to_entity_name => 'PO_VENDORS',
	      X_to_pk1_value => p_po_vendor_id,
	      X_created_by => fnd_global.user_id,
	      X_last_update_login => fnd_global.login_id);
	  END IF;
	END LOOP;
-- End Bug 9222914
--
-- Begin Bug 9048792
-- Updates pon_bid_headers with the name and id from hz_parties
	UPDATE pon_bid_headers
	SET trading_partner_id = p_supplier_hz_party_id,
	    trading_partner_name = (
	          SELECT party_name FROM hz_parties WHERE party_id = p_supplier_hz_party_id),
	    vendor_id = p_po_vendor_id
	WHERE trading_partner_id = p_requested_supplier_id
	  AND vendor_id = -1;
--
-- End Bug 9048792
--
--  updates party line exclusions with the approved supplier
	UPDATE pon_party_line_exclusions
	SET trading_partner_id =p_supplier_hz_party_id,
        requested_supplier_id = null,
	last_update_date = l_current_date,
	last_updated_by = nvl(p_user_id,last_updated_by),
	last_update_login = nvl(p_user_id,last_update_login)
	WHERE
	requested_supplier_id = p_requested_supplier_id;
--
-- upadtes the denormalized table with party_id
	UPDATE pon_pf_supplier_formula
	SET trading_partner_id = p_supplier_hz_party_id,
        requested_supplier_id = null,
	Last_update_date = l_current_date,
	Last_updated_by = nvl(p_user_id,last_updated_by),
	Last_update_login = nvl(p_user_id,last_update_login)
	WHERE
	requested_supplier_id = p_requested_supplier_id;

--
-- loop through all the supplier contacts and set the suppler contact ids
    SELECT DISTINCT requested_supplier_contact_id
      BULK COLLECT INTO l_req_contact_id
    FROM pon_bidding_parties
    WHERE trading_partner_id = p_supplier_hz_party_id;

    IF (l_req_contact_id.count <> 0) THEN  --{
	    FOR x IN 1..l_req_contact_id.COUNT
	    LOOP
	        -- call iSP API to get vendor_contact_id
              pos_request_utils_pkg.pos_get_contact_approved_det
               (l_req_contact_id(x),
                l_vendor_contact_id,
                x_return_status,
                x_msg_count,
                x_msg_data
               );
	     -- check return_status
         IF (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN --{
	        UPDATE pon_bidding_parties
	        SET trading_partner_contact_id = l_vendor_contact_id,
	            trading_partner_contact_name =
	             (SELECT party_name FROM hz_parties WHERE party_id = l_vendor_contact_id),
                    requested_supplier_contact_id = null,
                    requested_supp_contact_name = null
	        WHERE requested_supplier_contact_id = l_req_contact_id(x);

	        -- create wf user for fnd_user_name
	        BEGIN
	          SELECT user_name
		      INTO l_user_name
		      FROM fnd_user
                  WHERE person_party_id = l_vendor_contact_id;
	        EXCEPTION
	          WHEN TOO_MANY_ROWS THEN
	          SELECT user_name
  		      INTO l_user_name
		      FROM fnd_user
                  WHERE person_party_id = l_vendor_contact_id
                      AND ROWNUM = 1;
	        END;

	        -- Begin Bug 9048792
	        -- Updates pon_bid_headers with the first contact id and name
	        IF (x = 1) THEN
	          UPDATE pon_bid_headers
	          SET trading_partner_contact_id = l_vendor_contact_id,
	              trading_partner_contact_name = l_user_name
	          WHERE trading_partner_id = p_supplier_hz_party_id
	            AND nvl(evaluation_flag, 'N') = 'N';
	        END IF;
	        -- End Bug 9048792

	        -- loop through all auctions and create wf user with the user_name
	        -- and update pon_bidding_parties  to null out wf_user_name

	        SELECT DISTINCT ah.auction_header_id, ah.wf_role_name
	            BULK COLLECT INTO l_auction_header_id, l_wf_role_name
	        FROM pon_bidding_parties pbp, pon_auction_headers_all ah
	        WHERE pbp.trading_partner_contact_id = l_vendor_contact_id
	          AND pbp.wf_user_name IS NOT NULL
	          AND pbp.auction_header_id = ah.auction_header_id;

	        IF (l_auction_header_id.count <> 0) THEN
	           FOR y IN 1..l_auction_header_id.COUNT
	           LOOP
	              WF_DIRECTORY.AddUsersToAdHocRole(l_wf_role_name(y), l_user_name);
	              UPDATE pon_bidding_parties
	              SET wf_user_name = NULL
	              WHERE auction_header_id = l_auction_header_id(y)
	              AND trading_partner_contact_id = l_vendor_contact_id;
	           END LOOP;
	        END IF; -- auctions exist for given supplier contact

         END IF;  --} isp API returns contact_party_id with success

       END LOOP; -- loop through contacts
     END IF; --} requested supplier contacts exist
--
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;
--
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count := 0;
      x_msg_data := NULL;
      RETURN;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_msg_count := 1;
      fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
      fnd_message.set_token('PACKAGE','PON_NEW_SUPPLIER_REG_PKG');
      fnd_message.set_token('PROCEDURE','SRC_POS_REG_SUPPLIER_CALLBACK');
      fnd_message.set_token('ERROR', ' [' || SQLERRM || ']');
      --APP_EXCEPTION.RAISE_EXCEPTION;
      fnd_message.retrieve(x_msg_data);
      RETURN;
--
--
END SRC_POS_REG_SUPPLIER_CALLBACK;
--
--
END PON_NEW_SUPPLIER_REG_PKG;

/
