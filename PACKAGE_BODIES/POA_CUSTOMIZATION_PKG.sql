--------------------------------------------------------
--  DDL for Package Body POA_CUSTOMIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_CUSTOMIZATION_PKG" AS
  /* $Header: poacustb.pls 120.0 2005/06/01 23:05:43 appldev noship $ */


-- ========================================================================
--  Purchase_Classification_Code
--
--  This API can be customized for classification of purchases,
--  for example: for Production or Non-Production items.
--  It serves as a gateway where customers can define their own
--  purchase classifications to meet their business needs.
--
--  A new user updateable lookup, Purchase Classification, has been
--  defined for this purpose. It currently is seeded with the lookup
--  codes for Production, and Non-Production.
--  Users can define new lookup codes for their purchase classification
--  through the application.
--  The lookup codes reside in the PO_LOOKUP_CODES table.
--
--  Parameters:	    p_primary_key_id
--		    p_primary_key_type
--
--    where p_primary_key_type refers to the base table of the entity
--    and p_primary_key_id refers to the primary key id of the base table
--    entity.
--
--  Called by:

--    Facts			p_primary_key_type  	p_primary_key_id
--    --------------------	--------------------- 	---------------------
--    Supplier Performance	PO_LINE_LOCATIONS_ALL	line_location_id
--    PO Distributions          PO_DISTRIBUTIONS_ALL  	po_distribution_id
--    Receiving			RCV_TRANSACTIONS    	transaction_id
--
--  Return:	    the lookup_code in the PO_LOOKUP_CODES table
--		    corresponding to the purchase classification type,
--		    where the lookup_type is 'PURCHASE CLASSIFICATION.
--
--            select   lookup_code
--            from     po_lookup_codes
--            where    lookup_type = 'PURCHASE CLASSIFICATION'
-- ========================================================================

 Function Purchase_Classification_Code (
	    p_primary_key_id   in NUMBER,
 	    p_primary_key_type in VARCHAR2) return VARCHAR2 IS

 l_code VARCHAR2(240) := NULL;

 BEGIN
  /* Here could be some conditional statements to call other
     functions from customers defining the classification. */

    return (l_code);

 EXCEPTION when others then
	return NULL;
 END Purchase_Classification_Code;



-- ========================================================================
--  Get_Target_Price
--
--  This API can be customized for calculating the unit target price for the
--  item in the purchase shipment line.
--
--  The target price measure is normally used for calculating
--  a supplier' price score.
--
--  Parameters:	    p_line_location_id
--
--    where p_line_location_id refers to the line_location_id of the record
--    in PO_LINE_LOCATIONS_ALL table
--
--  Called by:	    Supplier Performance fact source view for its
--		    target price measure.
--
--  Return:	    target price expressed in the purchase transaction
--		    currency
-- ========================================================================

FUNCTION Get_Target_Price(p_line_location_id	NUMBER)
  RETURN NUMBER
IS
  v_target_price 	NUMBER := NULL;
BEGIN

  -- Currently default to the best price found

  v_target_price := poa_edw_supperf.find_best_price(p_line_location_id);

  RETURN(v_target_price);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(v_target_price);
  WHEN OTHERS THEN
    RAISE;

END Get_Target_Price;



END POA_CUSTOMIZATION_PKG;

/
