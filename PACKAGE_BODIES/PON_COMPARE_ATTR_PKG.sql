--------------------------------------------------------
--  DDL for Package Body PON_COMPARE_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_COMPARE_ATTR_PKG" as
/* $Header: PONCHATB.pls 120.0 2005/06/01 14:14:39 appldev noship $ */

FUNCTION getGroupAttrTargetValue(auctionId number,bidNumber number,attrGroup varchar2) return number is

CURSOR c_record is
      select bav.score,paa.attr_max_score,paa.weight
      from pon_bid_attribute_values bav,
           pon_auction_attributes paa
      where bav.auction_header_id=auctionId and
            bav.auction_header_id=paa.auction_header_id and
	    bav.bid_number = bidNumber and
            bav.attribute_name=paa.attribute_name and
            paa.attr_group=attrGroup;

 groupTargetValue number :=0;
 weightEnabled Boolean := false;
weightEnabledVarchar varchar2(1) := 'N';

begin

select nvl(hdr_attr_enable_weights,'N') into weightEnabledVarchar
from pon_auction_headers_all
where auction_header_id=auctionId;


if (weightEnabledVarchar = 'Y') then
   weightEnabled := true;
end if;


For attr IN c_record LOOP
begin
if (weightEnabled = true) then
   groupTargetValue := groupTargetValue +
                       (attr.score/attr.attr_max_score)*attr.weight;
else
   groupTargetValue := groupTargetValue + attr.score;
end if;
end;
end loop;

return(groupTargetValue);

end  getGroupAttrTargetValue;
--
-- ------------------------------------------------------------------------
--  calculate_bid_total_score
--  calculates bid header level score
-- ------------------------------------------------------------------------
--
FUNCTION get_bid_total_score
 (p_bid_number           IN pon_bid_headers.bid_number%TYPE)
 RETURN NUMBER
IS
  v_bid_total_score  NUMBER;
BEGIN
--
    SELECT
        DECODE (NVL(pah.HDR_ATTR_ENABLE_WEIGHTS, 'N')
        , 'Y', SUM(NVL(pba.WEIGHTED_SCORE, 0))
        , 'N', SUM(NVL(pba.SCORE, 0))
        ) INTO v_bid_total_score
     FROM pon_bid_attribute_values pba, pon_auction_headers_all pah
     WHERE pba.BID_NUMBER = p_bid_number
     and pba.LINE_NUMBER = -1
     and pba.AUCTION_HEADER_ID = pah.auction_header_id
     GROUP BY pah.HDR_ATTR_ENABLE_WEIGHTS;

  RETURN v_bid_total_score;
--
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN NULL;
--
END get_bid_total_score;
--
--
end PON_COMPARE_ATTR_PKG;

/
