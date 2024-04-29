--------------------------------------------------------
--  DDL for Package Body POS_HEADER_INFO_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_HEADER_INFO_S" AS
/* $Header: POSHEADB.pls 115.0 99/08/20 11:09:28 porting sh $ */


  /* GetPaymentTerms
   * ---------------
   * PL/SQL function to get the payment terms either from the po header,
   * or defaulted from the supplier site information.
   */
  FUNCTION GetPaymentTerms(p_sessionID NUMBER, p_vendorSiteID NUMBER)
    RETURN NUMBER
  IS

    v_count    NUMBER;
    v_termID   NUMBER;
    x_progress VARCHAR2(3);

  BEGIN

    SELECT count(po_header_id)
      INTO v_count
      FROM POS_ASN_SHOP_CART_DETAILS
     WHERE session_id = p_sessionID;

    v_termID := NULL;

    IF v_count = 1 THEN

      -- all shipments in the shopping cart for this particular session ID
      -- belong to the same PO, so we grab the term from the terms_id from
      -- po_headers_all.
      SELECT POH.terms_id
        INTO v_termID
        FROM PO_HEADERS_ALL POH,
             POS_ASN_SHOP_CART_DETAILS POS
       WHERE POH.po_header_id = POS.po_header_id
         AND POS.session_id = p_sessionID;

    ELSE

      -- the shipments in the shopping car for this particular session ID
      -- belong to different PO's, so we grab the payment term from the
      -- supplier site instead.
      SELECT terms_id
        INTO v_termID
        FROM PO_VENDOR_SITES
       WHERE vendor_site_id = p_vendorSiteID;

    END IF;

    RETURN(v_termID);

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('GetPaymentTerms', x_progress, sqlcode);
      RAISE;

  END GetPaymentTerms;


END POS_HEADER_INFO_S;


/
