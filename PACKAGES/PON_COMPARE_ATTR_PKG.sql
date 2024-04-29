--------------------------------------------------------
--  DDL for Package PON_COMPARE_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_COMPARE_ATTR_PKG" AUTHID CURRENT_USER as
/* $Header: PONCHATS.pls 120.0 2005/06/01 19:56:09 appldev noship $ */

FUNCTION getGroupAttrTargetValue(auctionId number,bidNumber number,attrGroup varchar2) return number;
--
--
FUNCTION get_bid_total_score
  (p_bid_number           IN pon_bid_headers.bid_number%TYPE)
 RETURN NUMBER;
--
--
end PON_COMPARE_ATTR_PKG;

 

/
