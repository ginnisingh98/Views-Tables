--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_PVT" AS
/* $Header: ozfvofrb.pls 120.103.12010000.16 2010/01/13 11:43:11 nepanda ship $ */
-------------------------------
-- PACKAGE
--    OZF_Offer_PVT
--
-- PURPOSE
--    Use QP_Modifiers_PUB package to create offers.
--
-- PROCEDURES
--   PUBLIC -- Process_modifiers
--   PRIVATE -- Process_offers
-- HISTORY
--   20-MAY-2000  Satish Karumuri  Created.
--   10-SEP-2001  julou  modified
--                makd changes to process_trade_deal procedure including:
--                off_invoice and billback operands are not mandantory.
--                input is broken into 4 small tbls to be processed seperately.
--                added check conditions for operands and limits.
--   19-OCT-2001  julou
--                added formula_id
--                made customer editable for lumpsum and trade deal offer
--                added validation for start and end date
--   26-OCT-2001  julou
--                added budget id for trade deal detail screen(update mode)
--                added profile option values for advanced options
--   30-OCT-2001  julou
--                added validation for max_amount_per_rule and max_qty_per_rule
--   03-DEC-2001  julou
--                changed default incompatibility group to null for trade deal
--   14-DEC-2001  julou
--                added check for default profile values
--                populate list_header_id for order value discount
--   15-MAY-2002  added break_type for promotional goods offer
--   18-Jun-2002  rssharma
--                Added new Qualifier for trade Deal Offers
--                To accomodate this added new ELSIF condition in offer_qualifiers procedure.
--                THis conditon corresponds to CUSTOMER_BILL_TO qualifier_type
--   19-Aug-2002  RSSHARMA Added Functions for getting Budget Related Columns in Overview
--   20-Aug-2002  RSSHARMA Added validation to not create duplicate budget requests and
--                Duplicate Offer Usage.Added two private functions get_campaign_count
--                and get_budget_source_count for this
--   29-Aug-2002  RSSHARMA Added Conditional passing of offer amount limit to QP.
--                Pass limit only if the Profile for Recalculated Committed is Off
--                OR the profile is on and the Flag for passing limit is on.
--                ALso Corrected Bug due to which the limit for Offer Amount will
--                never be deleted ..
--   24-Sep-2002  RSSHARMA Fixed bug in VOlume Offers where the accrual flag is not
--                updated from if the INcentive is changed from Accrual to Off INvoice
--                FOr Off INvoice offer Explicitly setting accrual flag to N.
--   23-Oct-2002  RSSHARMA Made Committed=Max independent of RECAL profile
--   24-OCT-2002  julou    added recalculate committed related changes to activate_offer,
--                         activate_offer_over, validate_offer API
--   28-Oct-2002  RSSHARMA CHanged Grouping No from 10 to -1 for Customer and Dates
--                when a qualifier is created
--   28-Oct-2002  RSSHARMA Changed code to handle Territory as Qualifier Type
--   28-OCT-2002  julou    modified process_ozf_offers so that IEB is not update when offer
--                         is in PENDING_ACTIVE. Changed the order of updating and posting
--                         LUMPSUM/SCAN_DATA
--   01-NOV-2002  julou    pass list_header_id to qualifiers tbl to fix copy API not copying
--                         order_value_from and order_value_to.
--   15-Nov-2002  RSSHARNA Added Flex Fields to QP_List_headers
--   26-Nov-2002  RSSHARMA Added Flex Field to qp_list_lines
--   12-DEC-2002  julou    1. parent as budget source update issue and creating budget request
--                         2. activation issue with LUMPSUM and SCAN_DATA offers
--                            moved update after posting offers
--   26-DEC-2002  julou    enhancement 2465253: added profile value for override flag.
--   06-Jan-2003  rssharma  Fixed issue where status code is set to null
--                          if the user status id is missing
--   09-JAN-2003  julou    fixed accrual_flag for multi-tier Accrual offers
--   30-JAN-2003  julou    changed process_qp_list_headers. if offer is updated from
--                         PROGRAM(offer_operation is null) populated active_flag as whatever parsed in.
--   03-Feb-2003  RSSHARMA Added Function discount_lines_exist to check if active discount rules exist for an offer
--                this function is required by budgets team
--   06-Feb-2003  RSSHARMA Fixed Bug # 2783888 .Added code for receiving Volume Offer Lines
--                with Offer type = 'VOLUME_OFFER' instead of the Volume Offer Type.
--                If the Offer type is 'VOLUME_OFFER' then hit another query to get the
--                Volume Offer type and then call process_regular_discounts with this
--                 volume Offer type as Offer Type.
--                This won't affect any of the existing Offer Calls as we already are
--                 retrieving this Volume Offer Type and Passing it in the API call
--   19-FEB-2003  julou    bug 2806139 - correct process_qp_list_header.
--                         only make offer active in qp when all approval/validation passed.
--   26-FEB-2003  julou    bug 2821174 - make IEB updatable to lower value
--   13-MAR-2003  julou    bug 2844095 - update ozf_offers.qualifier_deleted='Y' if qualifier is deleted
--   01-Apr-2003  RSSHARMA fixed bug # 2778138. Added Customer SHip To to Offer Qualifiers
--   15-Apr-2003  RSSHARMA Added Flex Field Code
--   22-APR-2003  julou    bug 2916480 - for custom setup 101 and 108, l_budget_required is null.
--                         added check for l_budget_required and treat it as 'N' if NULL, in process_modifiers
--   30-APR-2003  RSSHARMA Added Qualifiers Flex Fields
--   04-JUN-2003  julou    bug 2986459 - modified process_ozf_offer.
--                         populate IEB from cue card if offer is ACTIVE and IEB is null
--   Tue Jun 17 2003:2/47 PM  RSSHARMA Changed procedure offer_dates. Create the Order and Ship
--                        Dates with different Group Numbers
--   Tue Jul 15 2003:3/35 PM  RSSHARMA Added AMOUNT as new Discount Type for Order Value Offers
-- Wed Nov 26 2003:3/0 PM  rssharma Made process_qp_list_lines public and added an out variable
-- Mon Dec 01 2003:7/33 PM  RSSHARMA Changed process_regular_discounts to allow creating inactive discount rules.
-- Tue Dec 02 2003:1/51 PM RSSHARMA Added Creating inactive discount rules for regular, Order Value , Promotional Goods Offers
--                          And Skip Validation for minimum 1 discount line for an offer to become active for Soft Fund
--                       with Custom Setup Id = 110
--   15-JAN-2004 julou    Bug 3376179 - Added cusor to retrieve offer_id in activate_offer_over.
--                        Budget validation does not parse in offer_id, only qp_list_header_id
--  Thu Jan 15 2004:7/25 PM RSSHARMA to fix bug 3352620 , added function get_qualifier_name
-- Thu Feb 12 2004:6/17 PM RSSHARMA Fixed bug # 3429719. Make Start Date Required for Net Accrual offers
-- Fri Feb 20 2004:4/45 PM RSSHARMA Dont create or update qualifiers for Net Accrual Lumpsum and Scan Data Offers
--                      when qualifier is entered in header
-- Wed Mar 10 2004:11/23 AM RSSHARMA Raise business event on Offer activation
-- Thu Apr 08 2004:5/27 PM RSSHARMA Fixed bug #.3560980. Start date and end Date were saved with a timestamp
--      if the start date and end date fell in April to November (daylight savings period). Pricing engine
--      does not pick up offers if time stamp is specified so these offers did not get applied in OM
--      SO truncate the start date and end date of the offer so that it is picked up by Pricing engine.
-- Tue May 25 2004 RIMEHROT bug fix 3629490. Check if qualifier exists before deleting.
-- Wed Jun 30 2004:3/23 PM RSSHARMA Fixed bug # 3735380.Correct TotalForecastAmount Calculation for ScanData Offer
-- Tue Aug 31 2004:10/48 AM RSSHARMA Fixed bug # 3851487. Modifier Level Code for terms Upgrade Discount Type in Order Value
--      Offers was hard coded to LINE and the Pricing Phase Id was hardcoded to LIST LINE ADJUSMENT. Changed code to remove
--  hardcoding and accept the Values entered in the UI
--   DEC-03-2004  julou    bug 3999358: get error inactivating discount line.
--                         Occurs if offer start date and inactivating date is the same day.
--                         Solution: If start_date is not null take the greater of start_date and sysdate
--                         as discount line end date. If end_date is not null take the smaller of
--                         end_date and sysdate. Otherwise use sysdate.
--Tue May 03 2005:2/38 PM RSSHARMA Support creation of Sales method QUalifier from Create Offer Screen.
--  Fixed bug # 4354567. CHanged signature of process_header_tiers. Added additional out parameter
--  to pass back modifier lines created in the transaction.
-- Tue Jun 14 2005:7/34 PM RSSHARMA Added functions get_offer_discount_line_id and get_formula_name
--  Fri Jun 24 2005:7/46 PM RSSHARMA Added method vo_qualifier. If offer_type is Volume Offer use VO_Qualifier
-- to create and update Qualifiers from process_modifiers procedure
-- Thu Jul 07 2005:7/18 PM RSSHARMA Volume Offer Activation Changes. Added procedures push_discount_rules_to_qp,
--  relate_qp_ozf_for_vo , push_data_to_qp_and_relate.
--  Added new procedure process_offer_activation. this procedure will be one common procedure called during offer activation.
--  Currently this procedure pushes ozf data to qp during offer activation
--  Thu Aug 19 1999:6/50 AM RSSHARMA Added process to relate ozf and qp discounts and products. Also changed signature of create_offer_tiers
-- Tue Sep 27 2005:7/30 PM RSSHARMA Pass end date properly for end dating Discount lines using adjustments.
-- issues with trade deal remain. Only one line is end dated
-- Wed Sep 28 2005:12/18 PM RSSHARMA Push Accum attribute47 to qp during volume Offer activation.
--  DOnt push discount rules to qp if qp_list_lines already exist.
-- Wed Sep 28 2005:6/2 PM RSSHARMA During Volume Offer Activation push formula into proper column(price_by_formula_id) in qp_list_lines
-- Thu Sep 29 2005:1/46 PM RSSHARMA Corrected Accum Attribute to PRICING_ATTRIBUTE19 from PRICING_ATTRIBUTE47
-- Sat Oct 01 2005:5/40 PM RSSHARMA Corrected Qualifier Attribute used for creating sales method Qualifier
-- Wed Oct 12 2005:11/47 AM RSSHARMA Added new method debug_message to add debug messages to fnd only if the profile FND: Message Level Threshold level is high.
-- Create a pbh line, with same tier but "0" discounts for volume offer products with apply_discount flag set to "NO"
-- in push_discount_rules_to_qp procedure
-- Thu Oct 13 2005:7/21 PM RSSHARMA cleaned up MOAC code
-- Thu Oct 20 2005:4/14 PM RSSHARMA Added Following validations.
-- If The Security profile is off, in which case local(operating unit specific offers cannot be created), clear the org_id and set the global_flag to Y, for the data sent to QP
-- while the org_id is sent to ozf_offers
-- If the Offer is Lumpsum or scandata then , raise an exception if the org_id is not passed in since scandata and lumpsum offers always are org specific
-- Fri Oct 21 2005:6/45 PM RSSHARMA r12 changes to function discount_lines_exist
-- Changed function to query ozf_offer_discount_lines and ozf_offer_discount_products
-- if offer type is VOLUME_OFFER
-- Mon Oct 31 2005:3/1 PM RSSHARMA Fixed bug # 4706367. Raise Error for Lumpsum and scandata only if it is null or g_miss in create mode
-- and null indicated by (g_miss) in update mode
-- Mon Nov 14 2005:4/45 PM Fixed bug # 4625922. Due to issues in process_regular_discounts, the user was not able to perform any database operations
--  in the Offer Line Details page. the error occured due to debug mesages, printing data which did not exist
-- Thu Mar 30 2006:3/12 PM RSSHAMA new Adjustment changes to process_regular_discounts and process_trade_deal
-- Mon Apr 03 2006:1/57 PM RSSHARMA Pass start date active and end date active to MUlti-tier PBH lines.
-- Mon Apr 03 2006:3/8 PM RSSHARMA Fix passing start date and end date while updating multi-tier lines.
-- Wed Apr 05 2006:2/18 PM RSSHARMA Fixed bug # 5142859.If the passed in currency is null create budget request with default currency.
-- Wed Apr 05 2006:2/52 PM  RSSHARMA Fixed bug # 5142859. Added currency required for Lumpsum and scandata offers validation
-- Mon May 22 2006:2/30 PM RSSHARMA Fixed bug # 5227285. During update check against the frozen date_qualifier_profile_value to store dates in Qualifiers
-- or to store the dates in Header.
-- Tue May 23 2006:4/55 PM RSSHARMA Fixed bug # 5212053. Do not allow a Volume Offer to go active if one of the discount tables is empty.
-- Tue May 23 2006:6/3 PM  RSSHARMA Added condition to above that there must be atleast one non-excluded item in each discount table to make it active
-- Thu Jul 06 2006:11/23 AM RSSHARMA Fixed bug # 5332406. Changed process_header_tiers and push_discount_rules_to_qp_and_Relate for QP fix on continuous tiers
-- Fri Jul 06 2006:5/19 PM RSSHARMA Fixed update issues on multi-tier lines from the UI
-- Fri Apr 13 2007: nirprasa fix for bug 5969719
-- Mon Jul 09 2007: gdeepika fix for bug 5675554.Removed hardcoding in getPricingPhase(),pricing_group_sequence,product_precedence.
-- Thu Nov 29 2007: nirprasa fix for bug 6416762
-- Mon Dec 24 2007: nirprasa R12.1 SD Enhancement
-- Wed Feb 13 2008: kdass  fixed bug 6816780 - For SD Offer, defaulted ask_for_flag = N, removed start_date
--                                     for customers, truncated start and end dates for products
-- Wed Feb 13 2008: nirprasa fixed bug 6813556
-- Tue Fev 19 2008: nirprasa Added SDR validations: do not create offer header if there are no vendor approved lines.
--                           Do not create offer if OZF_SD_DEFAULT_BUDGET profile is not set.
-- Tue Apr 01 2008: nirprasa Added amount null check before calling qp_limits_pub.process_limits
-- Tue Apr 15 2008: nirprasa fixed bug 6968932
-- Wed Apr 16 2008: nirprasa fixed bug 6974091
-- Wed Apr 30 2008: nirprasa fixed bug 7004273
-- Tue Aug 12 2008: nirprasa fixed bug 7321745
-- Tue Aug 12 2008: nirprasa fixed bug 7321732
-- Tue Aug 22 2008: nirprasa fixed bug 7340864
-- Tue Aug 22 2008: nirprasa fixed bug 7584161 and 7580884
-- Tue Jun 02 2009: nepanda fix for bug 8507709 : vol offer - updating lines in qp from 'on-hold' - 'active'
-- Mon Aug 03 2009: nepanda fix for bug # 8717146. Changing qualifier date mask to 24 Hr Format
-- Thu Dec 3 2009 : nepanda : fix for bug 9149865 error when using the word 'and' for offer adjustment name
-- Tue Dec 15 2009: nepanda : fix for Bug 9204974 - fp:9151787: unable to cancel draft offrs when a bdgt reqst has rejected
-- Wed Jan 13 2010: nepanda fix for forwardport of bug # 8580281 accrul offer/budget allows you to to enter a discount rules without level/name
-------------------------------------------------------------------------------------

g_pkg_name CONSTANT VARCHAR2(30):= 'OZF_Offer_Pvt';
g_file_name CONSTANT VARCHAR2(15) := 'ozfvofrb.pls';
g_sd_offer VARCHAR2(15) := 'N';

OZF_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


PROCEDURE debug_message(p_message IN VARCHAR2)
IS
BEGIN

  IF (OZF_DEBUG_HIGH_ON) THEN
       ozf_utility_pvt.debug_message(p_message);

   END IF;
END debug_message;

/*
Common procedure called during offer activation
*/

PROCEDURE process_offer_activation
(
  p_api_version_number           IN   NUMBER
  , p_init_msg_list         IN   VARCHAR2
  , p_commit                IN   VARCHAR2
  , p_validation_level      IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offer_rec             IN Modifier_LIST_Rec_Type
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'process_offer_activation';
l_errorLocation NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_offer_rec.offer_type = 'VOLUME_OFFER' THEN
push_discount_rules_to_qp
(
        p_init_msg_list         => FND_API.G_FALSE
        ,p_api_version           => 1.0
        ,p_commit                => FND_API.G_FALSE
        , x_return_status        => x_return_status
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        , p_qp_list_header_id    => p_offer_rec.qp_list_header_id
        , x_error_location       => l_errorLocation
);
/*    push_data_to_qp_and_relate
    (
        p_api_version_number            => p_api_version_number
        , p_init_msg_list               => p_init_msg_list
        , p_commit                      => p_commit
        , p_validation_level            => p_validation_level

        , x_return_status               => x_return_status
        , x_msg_count                   => x_msg_count
        , x_msg_data                    => x_msg_data
        , p_qp_list_header_id           => p_offer_rec.qp_list_header_id
    );
*/
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

END IF;

debug_message('Private API: '|| l_api_name || ' End');


END process_offer_activation;

FUNCTION get_offer_discount_id(p_offer_id IN NUMBER) RETURN VARCHAR2
IS
l_offer_discount_line_id NUMBER := -1;
BEGIN

SELECT min(offer_discount_line_id) INTO l_offer_discount_line_id
FROM ozf_offer_discount_lines
WHERE offer_id = p_offer_id AND tier_type ='PBH';

IF(l_offer_discount_line_id IS NULL) THEN
    RETURN -1;
ELSE
    RETURN l_offer_discount_line_id ;
END IF;

END ;


FUNCTION get_formula_name(p_formula_id IN NUMBER) RETURN VARCHAR2
IS
l_formula_name QP_PRICE_FORMULAS_TL.NAME%TYPE;
BEGIN
    SELECT name INTO l_formula_name FROM qp_price_formulas_tl WHERE price_formula_id = p_formula_id AND language = userenv('lang');
    return l_formula_name;
END get_formula_name;

--FUNCTION get_vo_tier_id(p_offer_id)

FUNCTION get_qualifier_name(p_qualifier_type IN VARCHAR2 , p_qualifier_id IN NUMBER) RETURN VARCHAR2
IS
cursor c_qual_name(p_qualifier_ctx VARCHAR2,p_qualifier_attr VARCHAR2,p_qualifier_id NUMBER)
IS
SELECT QP_QP_Form_Pricing_Attr.Get_Attribute_Value('QP_ATTR_DEFNS_QUALIFIER',p_qualifier_ctx, p_qualifier_attr, p_qualifier_id)
from dual;
l_cust_name varchar2(240);
l_qualifier_ctx VARCHAR2 (240);
l_qualifier_attr VARCHAR2(240);
BEGIN
IF p_qualifier_type = 'CUSTOMER' THEN
l_qualifier_ctx := 'CUSTOMER';
l_qualifier_attr := 'QUALIFIER_ATTRIBUTE2';
ELSIF p_qualifier_type = 'LIST' THEN
l_qualifier_ctx := 'CUSTOMER_GROUP';
l_qualifier_attr := 'QUALIFIER_ATTRIBUTE1';
ELSIF p_qualifier_type = 'SEGMENT' THEN
l_qualifier_ctx := 'CUSTOMER_GROUP';
l_qualifier_attr := 'QUALIFIER_ATTRIBUTE2';
ELSIF p_qualifier_type = 'BUYER' THEN
l_qualifier_ctx := 'CUSTOMER_GROUP';
l_qualifier_attr := 'QUALIFIER_ATTRIBUTE3';
ELSIF p_qualifier_type = 'TERRITORY' THEN
l_qualifier_ctx := 'TERRITORY';
l_qualifier_attr := 'QUALIFIER_ATTRIBUTE1';
ELSIF p_qualifier_type = 'CUSTOMER_BILL_TO' THEN
l_qualifier_ctx := 'CUSTOMER';
l_qualifier_attr := 'QUALIFIER_ATTRIBUTE14';
ELSIF p_qualifier_type = 'SHIP_TO' THEN
l_qualifier_ctx := 'CUSTOMER';
l_qualifier_attr := 'QUALIFIER_ATTRIBUTE11';
END IF;

open c_qual_name(l_qualifier_ctx,l_qualifier_attr,p_qualifier_id);
    fetch c_qual_name into l_cust_name;
close c_qual_name;
RETURN l_cust_name;
END;


FUNCTION get_commited_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_committed_amount NUMBER := 0;

  CURSOR curr_committed_amount(list_header_id NUMBER) IS
  SELECT SUM(DECODE(recal_flag, 'N',committed_amt)) committed_amount
  FROM   ozf_object_checkbook_v
  WHERE  object_id = list_header_id
  AND    object_type = 'OFFR';

BEGIN
  OPEN curr_committed_amount( p_list_header_id ) ;
  FETCH curr_committed_amount INTO p_committed_amount ;
  CLOSE curr_committed_amount ;
  RETURN p_committed_amount ;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
END;


FUNCTION get_recal_commited_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_committed_amount NUMBER := 0;

  CURSOR curr_committed_amount(list_header_id NUMBER) IS
  SELECT SUM(committed_amt) recal_committed_amount
  FROM   ozf_object_checkbook_v
  WHERE  object_id = list_header_id
  AND    object_type = 'OFFR';

BEGIN
  OPEN curr_committed_amount( p_list_header_id ) ;
  FETCH curr_committed_amount INTO p_committed_amount ;
  CLOSE curr_committed_amount ;
  RETURN p_committed_amount ;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
END;

FUNCTION get_earned_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_earned_amount NUMBER := 0;

  CURSOR curr_earned_amount(list_header_id NUMBER) IS
  SELECT NVL(SUM(NVL(utilized_amt,0)),0) utlized_amount
  FROM   ozf_object_checkbook_v
  WHERE  object_id = list_header_id
  AND    object_type = 'OFFR';

BEGIN
  OPEN curr_earned_amount( p_list_header_id ) ;
  FETCH curr_earned_amount INTO p_earned_amount ;
  CLOSE curr_earned_amount ;
  RETURN p_earned_amount ;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN 0;
END;

FUNCTION get_paid_amount(p_list_header_id IN NUMBER)
RETURN NUMBER
IS
  p_paid_amount NUMBER := 0;

  CURSOR curr_paid_amount(list_header_id NUMBER) IS
  SELECT NVL(SUM(NVL(paid_amt,0)),0) paid_amount FROM ozf_object_checkbook_v
  WHERE  object_id = list_header_id
  AND    object_type = 'OFFR';

BEGIN
  OPEN curr_paid_amount( p_list_header_id ) ;
  FETCH curr_paid_amount INTO p_paid_amount ;
  CLOSE curr_paid_amount ;
  RETURN p_paid_amount ;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
END;


FUNCTION get_list_line_no RETURN NUMBER IS
  x number;
  CURSOR cur_get_list_line_no IS
  SELECT ams_qp_list_line_no_s.nextval from dual;
BEGIN
  OPEN cur_get_list_line_no;
  FETCH cur_get_list_line_no INTO x;
  CLOSE cur_get_list_line_no;
  RETURN x;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
END;


FUNCTION get_budget_source_count(p_list_header_id IN NUMBER)
RETURN NUMBER IS
p_count NUMBER := 0;

CURSOR cur_budget_source_count(list_header_id NUMBER) IS
SELECT   count(1)
FROM ozf_act_budgets
where act_budget_used_by_id = list_header_id
  and arc_act_budget_used_by = 'OFFR'
AND transfer_type = 'REQUEST';


BEGIN
OPEN cur_budget_source_count( p_list_header_id ) ;
FETCH cur_budget_source_count INTO p_count ;
CLOSE cur_budget_source_count ;
return p_count ;

EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;


--nepanda : fix for fp of bug number 9151787
FUNCTION get_active_budget_source_count(p_list_header_id IN NUMBER)
RETURN NUMBER IS
p_count NUMBER := 0;

CURSOR cur_active_budget_source_count(list_header_id NUMBER) IS
SELECT   count(1)
FROM ozf_act_budgets
where act_budget_used_by_id = list_header_id
  and arc_act_budget_used_by = 'OFFR'
AND transfer_type = 'REQUEST'
AND status_code NOT IN ('CLOSED', 'REJECTED');


BEGIN
OPEN cur_active_budget_source_count( p_list_header_id ) ;
FETCH cur_active_budget_source_count INTO p_count ;
CLOSE cur_active_budget_source_count ;
return p_count ;

EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;


PROCEDURE add_message ( p_msg_count IN NUMBER)
IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FOR i IN 1 .. p_msg_count LOOP
    l_msg_data :=  Oe_Msg_Pub.get( p_msg_index => i,
                                   p_encoded => 'F' );
    Fnd_Message.SET_NAME('OZF','OZF_QP_ERROR');
    Fnd_Message.SET_TOKEN('ERROR_MSG',l_msg_data);
    Fnd_Msg_Pub.ADD;
  END LOOP;
END add_message;

FUNCTION find_territories( aso_party_id  IN   NUMBER,oe_sold_to_org IN NUMBER)
RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS

  l_multirecord         Qp_Attr_Mapping_Pub.t_multirecord;

BEGIN

  oe_debug_pub.add('Before Calling OZF_QP_QUAL_PVT.Find_SA_Territories: ');
  oe_debug_pub.add('aso_party_id: ' || aso_party_id);
  oe_debug_pub.add('oe_sold_to_org: ' || oe_sold_to_org);
  l_multirecord := OZF_QP_QUAL_PVT.Find_SA_Territories(p_party_id    => aso_party_id
                                                      ,p_sold_to_org => oe_sold_to_org);
  oe_debug_pub.add('After Calling OZF_QP_QUAL_PVT.Find_SA_Territories: Count ' || l_multirecord.COUNT);

  RETURN l_multirecord;

END find_territories;


FUNCTION find_sections( aso_inventory_item_id  IN  NUMBER, oe_inventory_item_id IN NUMBER)
RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS
  p_inventory_item_id NUMBER;

  CURSOR cur_item_sections IS
  SELECT jsi.section_id
  FROM   ibe_dsp_section_items jsi
  WHERE  jsi.inventory_item_id = p_inventory_item_id;

  l_multirecord   Qp_Attr_Mapping_Pub.t_multirecord;
  l_count NUMBER := 1;

BEGIN
  IF aso_inventory_item_id = Fnd_Api.g_miss_num THEN
    p_inventory_item_id := oe_inventory_item_id;
  ELSE
    p_inventory_item_id := aso_inventory_item_id;
  END IF;
  FOR sections_rec IN cur_item_sections LOOP
    l_multirecord(l_count) := sections_rec.section_id;
    l_count := l_count + 1;
  END LOOP;

  RETURN(l_multirecord);

END;


PROCEDURE process_adv_options
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_advanced_options_rec  IN   ADVANCED_OPTION_REC_TYPE
)
IS
  CURSOR  cur_get_lines IS
  SELECT  list_line_id,modifier_level_code,price_break_type_code
  FROM    qp_list_lines
  WHERE   list_header_id = p_advanced_options_rec.list_header_id;

  -- bug 3435528 populate cust_account_id to beneficiary_account_id
  CURSOR c_cust_account_id(p_site_use_id NUMBER, p_site_use_code VARCHAR2) IS
  SELECT a.cust_account_id
  FROM   hz_cust_acct_sites_all a, hz_cust_site_uses_all b
  WHERE  a.cust_acct_site_id = b.cust_acct_site_id
  AND    b.site_use_code = p_site_use_code
  AND    b.site_use_id = p_site_use_id;
  -- end comment

  l_modifiers_tbl          Qp_Modifiers_Pub.modifiers_tbl_type;

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'process_adv_options';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_object_version_number NUMBER;

  i NUMBER := 1;

  v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
  v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
  v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
  v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
  v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
  v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
  v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
  v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
  l_promotional_offers_rec ozf_promotional_offers_pvt.offers_rec_type;

BEGIN

  SAVEPOINT process_adv_options;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  IF NOT Fnd_Api.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;

  FOR line_rec IN cur_get_lines LOOP
    l_modifiers_tbl(i).pricing_phase_id         := p_advanced_options_rec.pricing_phase_id;
    l_modifiers_tbl(i).modifier_level_code      := p_advanced_options_rec.modifier_level_code;
    l_modifiers_tbl(i).incompatibility_grp_code := p_advanced_options_rec.incompatibility_grp_code;
    l_modifiers_tbl(i).product_precedence       := p_advanced_options_rec.product_precedence;
    IF line_rec.modifier_level_code <> 'ORDER' THEN
      l_modifiers_tbl(i).pricing_group_sequence   := p_advanced_options_rec.pricing_group_sequence;
    END IF;
    l_modifiers_tbl(i).print_on_invoice_flag    := p_advanced_options_rec.print_on_invoice_flag;
    l_modifiers_tbl(i).price_break_type_code    := line_rec.price_break_type_code;
    l_modifiers_tbl(i).list_line_id             := line_rec.list_line_id;
    l_modifiers_tbl(i).operation                := Qp_Globals.G_OPR_UPDATE;
    i:= i+1;
  END LOOP;

  Qp_Modifiers_Pub.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => p_init_msg_list,
      p_return_values          => Fnd_Api.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifiers_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
   );

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

   l_promotional_offers_rec.qp_list_header_id             := p_advanced_options_rec.list_header_id;
   l_promotional_offers_rec.autopay_flag                  := p_advanced_options_rec.autopay_flag;
   l_promotional_offers_rec.autopay_days                := p_advanced_options_rec.autopay_days;
   l_promotional_offers_rec.autopay_method              := p_advanced_options_rec.autopay_method;
/*
   IF p_advanced_options_rec.autopay_days IS NOT NULL THEN
     l_promotional_offers_rec.autopay_days                := p_advanced_options_rec.autopay_days;
   ELSE
     l_promotional_offers_rec.autopay_days                := FND_PROFILE.VALUE('OZF_DEFAULT_AUTOPAY_DAYS');
   END IF;

   IF p_advanced_options_rec.autopay_method IS NOT NULL THEN
     l_promotional_offers_rec.autopay_method              := p_advanced_options_rec.autopay_method;
   ELSE
     l_promotional_offers_rec.autopay_method              := FND_PROFILE.VALUE('OZF_DEFAULT_AUTOPAY_METHOD');
   END IF;
*/
   l_promotional_offers_rec.autopay_party_attr            := p_advanced_options_rec.autopay_party_attr;
   l_promotional_offers_rec.autopay_party_id              := p_advanced_options_rec.autopay_party_id;

   -- bug 3435528
   IF p_advanced_options_rec.autopay_party_attr IS NULL OR p_advanced_options_rec.autopay_party_id IS NULL THEN
     l_promotional_offers_rec.beneficiary_account_id := NULL;
     l_promotional_offers_rec.autopay_party_attr := NULL;
     l_promotional_offers_rec.autopay_party_id := NULL;
   ELSIF p_advanced_options_rec.autopay_party_attr = 'CUSTOMER' THEN
     l_promotional_offers_rec.beneficiary_account_id := p_advanced_options_rec.autopay_party_id;
   ElSIF p_advanced_options_rec.autopay_party_attr = 'CUSTOMER_BILL_TO' THEN
     OPEN c_cust_account_id(p_advanced_options_rec.autopay_party_id, 'BILL_TO');
     FETCH c_cust_account_id INTO l_promotional_offers_rec.beneficiary_account_id;
     CLOSE c_cust_account_id;
   ElSIF p_advanced_options_rec.autopay_party_attr = 'SHIP_TO' THEN
     OPEN c_cust_account_id(p_advanced_options_rec.autopay_party_id, 'SHIP_TO');
     FETCH c_cust_account_id INTO l_promotional_offers_rec.beneficiary_account_id;
     CLOSE c_cust_account_id;
   END IF;
   -- end comment

   OZF_Promotional_Offers_Pvt.UPDATE_OFFERS(
        p_api_version_number    => 1.0,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_offers_rec            => l_promotional_offers_rec,
        x_object_version_number => l_object_version_number
   );

  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
  IF p_commit = Fnd_Api.g_true THEN
    COMMIT WORK;
  END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO process_adv_options;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO process_adv_options;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO process_adv_options;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;


PROCEDURE create_offer_tiers
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
  ,x_error_location        OUT NOCOPY  NUMBER
--  ,x_modifiers_tbl         OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
--  ,x_pricing_attr_tbl      OUT NOCOPY qp_modifiers_pub.pricing_attr_tbl_type
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'create_offer_tiers';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
  l_pricing_attr_tbl       Qp_Modifiers_Pub.pricing_attr_tbl_type;
  v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
  v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
  v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
  v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
  v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
  v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
  v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
  v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;

  CURSOR cur_get_adv_options(parent_list_line_id NUMBER) IS
  SELECT proration_type_code   ,
         product_precedence    ,
         pricing_group_sequence,
         print_on_invoice_flag ,
         pricing_phase_id      ,
         modifier_level_code   ,
         automatic_flag
  FROM   qp_list_lines
  WHERE  list_line_id = parent_list_line_id;

  CURSOR cur_get_prod_info( parent_list_line_id NUMBER) IS
  SELECT product_attribute_context,
         product_attribute ,
         product_attr_value,
         product_uom_code  ,
         pricing_attribute_context
    FROM qp_pricing_attributes
   WHERE list_line_id = parent_list_line_id;

  -- fix for accrual_flag for multi-tier lines
  CURSOR c_offer_type(p_list_header_id NUMBER) IS
  SELECT DECODE(offer_type, 'VOLUME_OFFER', volume_offer_type, offer_type)
    FROM ozf_offers
   WHERE qp_list_header_id = p_list_header_id;
  l_offer_type    VARCHAR2(30);

  CURSOR c_pbh_pricing_attr_id(l_id NUMBER) IS
  SELECT c.pricing_attribute_id,
         c.list_line_id
  FROM   qp_rltd_modifiers a, qp_pricing_attributes b, qp_pricing_attributes c
  WHERE  c.list_line_id = a.from_rltd_modifier_id
  AND    a.to_rltd_modifier_id = b.list_line_id
  AND    b.pricing_attribute_id = l_id;

  l_pricing_attribute_id NUMBER;
  l_line_index           NUMBER;
  l_list_line_id         NUMBER;
BEGIN

  SAVEPOINT create_offer_tiers;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  IF NOT Fnd_Api.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;
  x_error_location := 0;



  IF p_modifier_line_tbl.count > 0 THEN
    FOR i in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
      IF p_modifier_line_tbl.exists(i) THEN
        IF p_modifier_line_tbl(i).operation <> fnd_api.g_miss_char THEN
          IF p_modifier_line_tbl(i).operation = 'CREATE' THEN
          debug_message('Operation Create');
            OPEN cur_get_adv_options(p_modifier_line_tbl(i).list_line_id);
            FETCH cur_get_adv_options INTO l_modifiers_tbl(i).proration_type_code,
                                           l_modifiers_tbl(i).product_precedence ,
                                           l_modifiers_tbl(i).pricing_group_sequence,
                                           l_modifiers_tbl(i).print_on_invoice_flag,
                                           l_modifiers_tbl(i).pricing_phase_id ,
                                           l_modifiers_tbl(i).modifier_level_code,
                                           l_modifiers_tbl(i).automatic_flag  ;
            CLOSE cur_get_adv_options;

            OPEN cur_get_prod_info(p_modifier_line_tbl(i).list_line_id);
            FETCH cur_get_prod_info INTO l_pricing_attr_tbl(i).product_attribute_context ,
                                         l_pricing_attr_tbl(i).product_attribute  ,
                                         l_pricing_attr_tbl(i).product_attr_value ,
                                         l_pricing_attr_tbl(i).product_uom_code   ,
                                         l_pricing_attr_tbl(i).pricing_attribute_context ;

            CLOSE cur_get_prod_info;

            l_modifiers_tbl(i).from_rltd_modifier_id := p_modifier_line_tbl(i).list_line_id;
            l_modifiers_tbl(i).list_line_type_code       := 'DIS';
            l_modifiers_tbl(i).rltd_modifier_grp_type    := 'PRICE BREAK';
            l_modifiers_tbl(i).rltd_modifier_grp_no      := 1;
            l_modifiers_tbl(i).list_header_id            := p_modifier_line_tbl(i).list_header_id;
            l_pricing_attr_tbl(i).modifiers_index          := i;
          ELSE
            l_modifiers_tbl(i).list_line_id := p_modifier_line_tbl(i).list_line_id;
          END IF;

          l_modifiers_tbl(i).operation                 := p_modifier_line_tbl(i).operation ;
          l_modifiers_tbl(i).arithmetic_operator       := p_modifier_line_tbl(i).arithmetic_operator;
          l_modifiers_tbl(i).operand                   := p_modifier_line_tbl(i).operand;
          l_modifiers_tbl(i).price_break_type_code     := p_modifier_line_tbl(i).price_break_type_code;
    debug_message('Adding accr flag');
          OPEN c_offer_type (l_modifiers_tbl(i).list_header_id);
          FETCH c_offer_type INTO l_offer_type;
          CLOSE c_offer_type;
          IF l_offer_type = 'ACCRUAL' THEN
            l_modifiers_tbl(i).accrual_flag              := 'Y';
          ELSIF l_offer_type = 'OFF_INVOICE' THEN
            l_modifiers_tbl(i).accrual_flag              := 'N';
          END IF;
            l_modifiers_tbl(i).start_date_active := p_modifier_line_tbl(i).start_date_active;
debug_message('Done start date');
          l_pricing_attr_tbl(i).pricing_attribute        := p_modifier_line_tbl(i).pricing_attr;
          l_pricing_attr_tbl(i).pricing_attribute_id     := p_modifier_line_tbl(i).pricing_attribute_id;
          l_pricing_attr_tbl(i).pricing_attr_value_from  := p_modifier_line_tbl(i).pricing_attr_value_from;
          l_pricing_attr_tbl(i).pricing_attr_value_to    := p_modifier_line_tbl(i).pricing_attr_value_to;
          l_pricing_attr_tbl(i).comparison_operator_code := 'BETWEEN';
          l_pricing_attr_tbl(i).operation                := p_modifier_line_tbl(i).operation;
        END IF;
      END IF;
    END LOOP;

    OPEN  c_pbh_pricing_attr_id(p_modifier_line_tbl(p_modifier_line_tbl.first).pricing_attribute_id);
    FETCH c_pbh_pricing_attr_id INTO l_pricing_attribute_id, l_list_line_id;
    CLOSE c_pbh_pricing_attr_id;

    l_line_index := l_pricing_attr_tbl.last + 1;

    l_pricing_attr_tbl(l_line_index).pricing_attribute_id := l_pricing_attribute_id;
    l_pricing_attr_tbl(l_line_index).operation            := 'UPDATE';
    l_pricing_attr_tbl(l_line_index).pricing_attribute    := p_modifier_line_tbl(p_modifier_line_tbl.first).pricing_attr;

    -- nirprasa, fix for bug 7340864
     IF(p_modifier_line_tbl(p_modifier_line_tbl.first).operation <> 'CREATE') THEN
        l_modifiers_tbl(l_line_index).price_break_type_code := p_modifier_line_tbl(p_modifier_line_tbl.first).price_break_type_code;
        l_modifiers_tbl(l_line_index).operation := 'UPDATE';
        l_modifiers_tbl(l_line_index).list_line_id := l_list_line_id;
    END IF;

  END IF;
debug_message('Calling Pub Process in tiers');
  Qp_Modifiers_Pub.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => p_init_msg_list,
      p_return_values          => Fnd_Api.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifiers_tbl,
      p_pricing_attr_tbl       => l_pricing_attr_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
   );

  IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
    IF v_modifiers_tbl.COUNT > 0 THEN
      FOR i IN v_modifiers_tbl.first..v_modifiers_tbl.last LOOP
        IF v_modifiers_tbl.EXISTS(i) THEN
          IF v_modifiers_tbl(i).return_status <> Fnd_Api.g_ret_sts_success THEN
            x_error_location := i;
            EXIT;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;


--   x_modifiers_tbl         := v_modifiers_tbl;
--   x_pricing_attr_tbl       := v_pricing_attr_tbl;

  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
  IF p_commit = Fnd_Api.g_true THEN
    COMMIT WORK;
  END IF;
debug_message('End Create Tiers');
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO create_offer_tiers;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO create_offer_tiers;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO create_offer_tiers;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;


PROCEDURE populateRltdExclusions
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pricing_attr_tbl      IN PRICING_ATTR_TBL_TYPE
  ,px_pricing_attr_tbl     OUT NOCOPY PRICING_ATTR_TBL_TYPE
)
IS
CURSOR c_rltdListLine(cp_listLineId NUMBER) IS
SELECT nvl(related_modifier_id,-1) related_modifier_id
FROM ozf_related_deal_lines a
WHERE a.modifier_id = cp_listLineId;

CURSOR c_pricingAttrId (cp_listLineId NUMBER, cp_productAttr VARCHAR2, cp_productAttrValue VARCHAR2) IS
SELECT pricing_attribute_id
FROM qp_pricing_attributes
WHERE list_line_id = cp_listLineId
AND product_attribute = cp_productAttr
AND product_attr_value = cp_productAttrValue
AND excluder_flag = 'Y';

i NUMBER:= 0;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
i := 1;
IF nvl(p_pricing_attr_tbl.count, 0) > 0 THEN
    FOR j in p_pricing_attr_tbl.first .. p_pricing_attr_tbl.last LOOP
        IF p_pricing_attr_tbl.exists(j) THEN
                FOR l_rltdListLine  IN c_rltdListLine(cp_listLineId => p_pricing_attr_tbl(j).list_line_id) LOOP
                IF l_rltdListLine.related_modifier_id = -1 THEN
                null;
                ELSE
                        px_pricing_attr_tbl(i) := p_pricing_attr_tbl(j);
                        px_pricing_attr_tbl(i).list_line_id := l_rltdListLine.related_modifier_id;
                        IF p_pricing_attr_tbl(j).operation <> 'CREATE' THEN
                            OPEN c_pricingAttrId(cp_listLineId => px_pricing_attr_tbl(i).list_line_id
                                                                , cp_productAttr => p_pricing_attr_tbl(j).product_attribute
                                                                , cp_productAttrValue => p_pricing_attr_tbl(j).product_attr_value
                                                             );
                            FETCH c_pricingAttrId INTO px_pricing_attr_tbl(i).pricing_attribute_id;
                            IF c_pricingAttrId%NOTFOUND THEN
                                px_pricing_attr_tbl(i).operation := null;
                            END IF;
                            CLOSE c_pricingAttrId;
                    END IF;
                END IF;
                END LOOP;
        END IF;
    END LOOP;
END IF;

END populateRltdExclusions;

PROCEDURE processRegExclusions
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pricing_attr_tbl      IN   PRICING_ATTR_TBL_TYPE
  ,x_error_location        OUT NOCOPY  NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'processRegExclusions';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_pricing_attr_tbl       Qp_Modifiers_Pub.pricing_attr_tbl_type;
  v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
  v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
  v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
  v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
  v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
  v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
  v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
  v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;

BEGIN
  SAVEPOINT process_exlusions;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  IF NOT Fnd_Api.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;
  x_error_location := 0;
  IF p_pricing_attr_tbl.COUNT > 0 THEN
    FOR i IN p_pricing_attr_tbl.first..p_pricing_attr_tbl.last LOOP
      IF p_pricing_attr_tbl.EXISTS(i) THEN
        --dbms_output.put_line('start:'||i);
        l_pricing_attr_tbl(i).list_line_id               := p_pricing_attr_tbl(i).list_line_id;

        l_pricing_attr_tbl(i).product_attribute          := p_pricing_attr_tbl(i).product_attribute;
        l_pricing_attr_tbl(i).product_attribute_context  := 'ITEM';
        l_pricing_attr_tbl(i).product_attr_value         := p_pricing_attr_tbl(i).product_attr_value;

        IF p_pricing_attr_tbl(i).operation <> 'CREATE' THEN
          l_pricing_attr_tbl(i).pricing_attribute_id       := p_pricing_attr_tbl(i).pricing_attribute_id;
        END IF;
        l_pricing_attr_tbl(i).excluder_flag              := 'Y';
        l_pricing_attr_tbl(i).operation                  := p_pricing_attr_tbl(i).operation;
        --dbms_output.put_line('end:'||i);
      END IF;
    END LOOP;
  END IF;

  Qp_Modifiers_Pub.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => p_init_msg_list,
      p_return_values          => Fnd_Api.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_pricing_attr_tbl       => l_pricing_attr_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
   );
        --dbms_output.put_line('done qp api:'||x_return_status);

  IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
    IF v_pricing_attr_tbl.COUNT > 0 THEN
      FOR i IN v_pricing_attr_tbl.first..v_pricing_attr_tbl.last LOOP
        IF v_pricing_attr_tbl.EXISTS(i) THEN
          IF v_pricing_attr_tbl(i).return_status <> Fnd_Api.g_ret_sts_success THEN
            x_error_location := i;
            EXIT;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;

        --dbms_output.put_line('done qp api:'||x_return_status);

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  IF p_commit = Fnd_Api.g_true THEN
    COMMIT WORK;
  END IF;
        --dbms_output.put_line('done qp api:'||x_return_status);
        --dbms_output.put_line('done :');
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO process_exlusions;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO process_exlusions;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO process_exlusions;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
       Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END processRegExclusions;

/**
One scenario left out for now is , if a Product is excluded from a TD Line comprising of only 1 discount.
On creating second discount, the exclusion is not copied over.
Same is true for Line level qualifiers
Another issue is the process_trade_deal does not process the qd discount record at all if the qd discount is set to  null
*/
PROCEDURE process_exclusions
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_pricing_attr_tbl      IN   PRICING_ATTR_TBL_TYPE
  ,x_error_location        OUT NOCOPY  NUMBER
)
IS
l_pricing_attr_tbl      PRICING_ATTR_TBL_TYPE;
BEGIN
-- initialize
-- process reqular exclusions
-- populate related exclusions data
-- process related exclusions
x_return_status := FND_API.G_RET_STS_SUCCESS;
processRegExclusions
(
   p_init_msg_list         => FND_API.G_FALSE
  ,p_api_version           => 1.0
  ,p_commit                => FND_API.G_FALSE
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_pricing_attr_tbl      => p_pricing_attr_tbl
  ,x_error_location        => x_error_location
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

populateRltdExclusions
(
  x_return_status          => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_pricing_attr_tbl      => p_pricing_attr_tbl
  ,px_pricing_attr_tbl      => l_pricing_attr_tbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--dbms_output.put_line('Rltd Pricing attr count is :'||nvl(l_pricing_attr_tbl.count,0));
IF nvl(l_pricing_attr_tbl.count,0) > 0 THEN
--dbms_output.put_line('Rltd Pricing attr count is :'||nvl(l_pricing_attr_tbl.count,0));
processRegExclusions
(
   p_init_msg_list         => FND_API.G_FALSE
  ,p_api_version           => 1.0
  ,p_commit                => FND_API.G_FALSE
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_pricing_attr_tbl      => l_pricing_attr_tbl
  ,x_error_location        => x_error_location
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END IF;
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,'process_exclusions');
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END process_exclusions;


PROCEDURE process_rltd_modifier_qual
(
   p_init_msg_list IN  VARCHAR2
  ,p_commit        IN  VARCHAR2
  ,p_list_line_id  IN  NUMBER
  ,x_return_status OUT NOCOPY  VARCHAR2
  ,x_msg_count     OUT NOCOPY  NUMBER
  ,x_msg_data      OUT NOCOPY  VARCHAR2)
IS
  CURSOR c_modifier_qualifier IS
  SELECT qpq.qualifier_context
        ,qpq.qualifier_attribute
        ,qpq.qualifier_attr_value
        ,qpq.qualifier_attr_value_to
        ,qpq.comparison_operator_code
        ,qpq.qualifier_grouping_no
        ,qpq.start_date_active
        ,qpq.end_date_active
        ,qpq.active_flag
        ,qpq.context
        ,qpq.attribute1
        ,qpq.attribute2
        ,qpq.attribute3
        ,qpq.attribute4
        ,qpq.attribute5
        ,qpq.attribute6
        ,qpq.attribute7
        ,qpq.attribute8
        ,qpq.attribute9
        ,qpq.attribute10
        ,qpq.attribute11
        ,qpq.attribute12
        ,qpq.attribute13
        ,qpq.attribute14
        ,qpq.attribute15
        ,qpq.list_line_id
        ,qpq.list_header_id
  FROM   qp_qualifiers qpq
  WHERE  qpq.list_line_id = p_list_line_id;

  CURSOR c_rltd_modifier_id(p_qp_list_header_id NUMBER, p_modifier_id NUMBER) IS
  SELECT related_modifier_id
  FROM   ozf_related_deal_lines
  WHERE  modifier_id = p_modifier_id
  AND    qp_list_header_id = p_qp_list_header_id;

  l_api_version CONSTANT   NUMBER       := 1.0;
  l_api_name    CONSTANT   VARCHAR2(30) := 'process_rltd_modifier_qual';
  l_full_name   CONSTANT   VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_qualifiers_tbl         Qp_Qualifier_Rules_Pub.qualifiers_tbl_type;
  v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
  v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
  v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
  v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
  v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
  v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
  v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
  v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
  l_qualifiers_tbl_out     qp_qualifier_rules_pub.qualifiers_tbl_type;

  l_rltd_modifier_id NUMBER;
  l_index            NUMBER := 0;

BEGIN
  SAVEPOINT process_rltd_modifier_qual;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;

  FOR l_modifier_qualifier IN c_modifier_qualifier LOOP
    OPEN  c_rltd_modifier_id(l_modifier_qualifier.list_header_id, p_list_line_id);
    FETCH c_rltd_modifier_id INTO l_rltd_modifier_id;
    CLOSE c_rltd_modifier_id;
debug_message('jl rltd modifier id: ' || l_rltd_modifier_id);
    IF l_rltd_modifier_id IS NOT NULL AND l_rltd_modifier_id <> fnd_api.g_miss_num THEN
      DELETE FROM qp_qualifiers
      WHERE  list_header_id = l_modifier_qualifier.list_header_id
      AND    list_line_id = l_rltd_modifier_id;

      l_index := l_index + 1;
      l_qualifiers_tbl(l_index).list_header_id           := l_modifier_qualifier.list_header_id;
      l_qualifiers_tbl(l_index).list_line_id             := l_rltd_modifier_id;
      l_qualifiers_tbl(l_index).operation                := 'CREATE';
      l_qualifiers_tbl(l_index).qualifier_context        := l_modifier_qualifier.qualifier_context;
      l_qualifiers_tbl(l_index).qualifier_attribute      := l_modifier_qualifier.qualifier_attribute;
      l_qualifiers_tbl(l_index).qualifier_attr_value     := l_modifier_qualifier.qualifier_attr_value;
      l_qualifiers_tbl(l_index).qualifier_attr_value_to  := l_modifier_qualifier.qualifier_attr_value_to;
      l_qualifiers_tbl(l_index).comparison_operator_code := l_modifier_qualifier.comparison_operator_code;
      l_qualifiers_tbl(l_index).qualifier_grouping_no    := l_modifier_qualifier.qualifier_grouping_no;
      l_qualifiers_tbl(l_index).start_date_active        := l_modifier_qualifier.start_date_active;
      l_qualifiers_tbl(l_index).end_date_active          := l_modifier_qualifier.end_date_active;
      l_qualifiers_tbl(l_index).active_flag              := l_modifier_qualifier.active_flag;
      l_qualifiers_tbl(l_index).context                  := l_modifier_qualifier.context;
      l_qualifiers_tbl(l_index).attribute1               := l_modifier_qualifier.attribute1;
      l_qualifiers_tbl(l_index).attribute2               := l_modifier_qualifier.attribute2;
      l_qualifiers_tbl(l_index).attribute3               := l_modifier_qualifier.attribute3;
      l_qualifiers_tbl(l_index).attribute4               := l_modifier_qualifier.attribute4;
      l_qualifiers_tbl(l_index).attribute5               := l_modifier_qualifier.attribute5;
      l_qualifiers_tbl(l_index).attribute6               := l_modifier_qualifier.attribute6;
      l_qualifiers_tbl(l_index).attribute7               := l_modifier_qualifier.attribute7;
      l_qualifiers_tbl(l_index).attribute8               := l_modifier_qualifier.attribute8;
      l_qualifiers_tbl(l_index).attribute9               := l_modifier_qualifier.attribute9;
      l_qualifiers_tbl(l_index).attribute10              := l_modifier_qualifier.attribute10;
      l_qualifiers_tbl(l_index).attribute11              := l_modifier_qualifier.attribute11;
      l_qualifiers_tbl(l_index).attribute12              := l_modifier_qualifier.attribute12;
      l_qualifiers_tbl(l_index).attribute13              := l_modifier_qualifier.attribute13;
      l_qualifiers_tbl(l_index).attribute14              := l_modifier_qualifier.attribute14;
      l_qualifiers_tbl(l_index).attribute15              := l_modifier_qualifier.attribute15;
    END IF;
  END LOOP;
debug_message('jl qualifier tbl count: ' || l_qualifiers_tbl.count);
--raise Fnd_Api.g_exc_error;
  Qp_Modifiers_Pub.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => p_init_msg_list,
      p_return_values          => Fnd_Api.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_qualifiers_tbl         => l_qualifiers_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => l_qualifiers_tbl_out,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
   );

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO process_rltd_modifier_qual;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO process_rltd_modifier_qual;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO process_rltd_modifier_qual;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END process_rltd_modifier_qual;

PROCEDURE process_market_qualifiers
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_qualifiers_tbl         IN  QUALIFIERS_TBL_TYPE
  ,x_error_location        OUT NOCOPY  NUMBER
  ,x_qualifiers_tbl        OUT NOCOPY qp_qualifier_rules_pub.qualifiers_tbl_type
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'process_market_qualifiers';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_qualifiers_tbl         Qp_Qualifier_Rules_Pub.qualifiers_tbl_type;
  v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
  v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
  v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
  v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
  v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
  v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
  v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
  v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
  l_qualifier_deleted      VARCHAR2(1) := 'N';
  l_qp_list_header_id      NUMBER;
  l_offer_type             VARCHAR2(30);

  CURSOR c_offer_type(l_list_header_id NUMBER) IS
  SELECT offer_type
  FROM   ozf_offers
  WHERE  qp_list_header_id = l_list_header_id;

BEGIN
  SAVEPOINT process_market_qualifiers;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  IF NOT Fnd_Api.compatible_api_call
  (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;
  x_error_location := 0;
  IF p_qualifiers_tbl.COUNT > 0 THEN
    FOR i IN p_qualifiers_tbl.first..p_qualifiers_tbl.last LOOP
      IF p_qualifiers_tbl.EXISTS(i) THEN
        IF p_qualifiers_tbl(i).operation <> 'CREATE' THEN
          l_qualifiers_tbl(i).qualifier_id              := p_qualifiers_tbl(i).qualifier_id;
        END IF;
        l_qualifiers_tbl(i).list_header_id            := p_qualifiers_tbl(i).list_header_id;

        IF  p_qualifiers_tbl(i).list_line_id IS NOT NULL
        AND p_qualifiers_tbl(i).list_line_id <> FND_API.G_MISS_NUM
        THEN
          l_qualifiers_tbl(i).list_line_id          := p_qualifiers_tbl(i).list_line_id;
        ELSE
          l_qualifiers_tbl(i).list_line_id          := -1;
        END IF;

        l_qualifiers_tbl(i).qualifier_context         := p_qualifiers_tbl(i).qualifier_context;
        l_qualifiers_tbl(i).qualifier_attribute       := p_qualifiers_tbl(i).qualifier_attribute;
        l_qualifiers_tbl(i).qualifier_attr_value      := p_qualifiers_tbl(i).qualifier_attr_value;
        l_qualifiers_tbl(i).qualifier_attr_value_to   := p_qualifiers_tbl(i).qualifier_attr_value_to;
        l_qualifiers_tbl(i).comparison_operator_code  := p_qualifiers_tbl(i).comparison_operator_code;
        l_qualifiers_tbl(i).qualifier_grouping_no     := p_qualifiers_tbl(i).qualifier_grouping_no;
        l_qualifiers_tbl(i).start_date_active         := p_qualifiers_tbl(i).start_date_active;
        l_qualifiers_tbl(i).end_date_active           := p_qualifiers_tbl(i).end_date_active;
        l_qualifiers_tbl(i).operation                 := p_qualifiers_tbl(i).operation;
        l_qualifiers_tbl(i).context                   := p_qualifiers_tbl(i).context;
        l_qualifiers_tbl(i).attribute1                := p_qualifiers_tbl(i).attribute1;
        l_qualifiers_tbl(i).attribute2                := p_qualifiers_tbl(i).attribute2;
        l_qualifiers_tbl(i).attribute3                := p_qualifiers_tbl(i).attribute3;
        l_qualifiers_tbl(i).attribute4                := p_qualifiers_tbl(i).attribute4;
        l_qualifiers_tbl(i).attribute5                := p_qualifiers_tbl(i).attribute5;
        l_qualifiers_tbl(i).attribute6                := p_qualifiers_tbl(i).attribute6;
        l_qualifiers_tbl(i).attribute7                := p_qualifiers_tbl(i).attribute7;
        l_qualifiers_tbl(i).attribute8                := p_qualifiers_tbl(i).attribute8;
        l_qualifiers_tbl(i).attribute9                := p_qualifiers_tbl(i).attribute9;
        l_qualifiers_tbl(i).attribute10                := p_qualifiers_tbl(i).attribute10;
        l_qualifiers_tbl(i).attribute11                := p_qualifiers_tbl(i).attribute11;
        l_qualifiers_tbl(i).attribute12                := p_qualifiers_tbl(i).attribute12;
        l_qualifiers_tbl(i).attribute13                := p_qualifiers_tbl(i).attribute13;
        l_qualifiers_tbl(i).attribute14                := p_qualifiers_tbl(i).attribute14;
        l_qualifiers_tbl(i).attribute15                := p_qualifiers_tbl(i).attribute15;
        IF p_qualifiers_tbl(i).operation = 'DELETE' THEN
          l_qualifier_deleted := 'Y';
          l_qp_list_header_id := p_qualifiers_tbl(i).list_header_id;
        END IF;
      END IF;
    END LOOP;
  END IF;

  Qp_Modifiers_Pub.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => p_init_msg_list,
      p_return_values          => Fnd_Api.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_qualifiers_tbl         => l_qualifiers_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => x_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
   );

  IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
    IF v_qualifiers_tbl.COUNT > 0 THEN
      FOR i IN v_qualifiers_tbl.first..v_qualifiers_tbl.last LOOP
        IF v_qualifiers_tbl.EXISTS(i) THEN
          IF v_qualifiers_tbl(i).return_status <> Fnd_Api.g_ret_sts_success THEN
            x_error_location := i;
            EXIT;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  FOR i IN NVL(p_qualifiers_tbl.FIRST, 1)..NVL(p_qualifiers_tbl.LAST, 0) LOOP
    OPEN  c_offer_type(p_qualifiers_tbl(i).list_header_id);
    FETCH c_offer_type INTO l_offer_type;
    CLOSE c_offer_type;

    debug_message('jl offer type: ' || l_offer_type);
    debug_message('jl list line id: ' || p_qualifiers_tbl(i).list_line_id);

    IF l_offer_type = 'DEAL' AND p_qualifiers_tbl(i).list_line_id IS NOT NULL AND p_qualifiers_tbl(i).list_line_id <> fnd_api.g_miss_num AND p_qualifiers_tbl(i).list_line_id <> -1 THEN
      process_rltd_modifier_qual(
             p_init_msg_list => p_init_msg_list,
             p_commit        => fnd_api.g_false,
             p_list_line_id  => p_qualifiers_tbl(i).list_line_id,
             x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data);
    END IF;
  END LOOP;
--raise Fnd_Api.G_EXC_ERROR;
  IF l_qualifier_deleted = 'Y' THEN
    UPDATE ozf_offers
    SET    qualifier_deleted = 'Y'
    WHERE  qp_list_header_id = l_qp_list_header_id;
  END IF;

  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
  IF p_commit = Fnd_Api.g_true THEN
    COMMIT WORK;
  END IF;


EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO process_market_qualifiers;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO process_market_qualifiers;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO process_market_qualifiers;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;

PROCEDURE process_market_qualifiers
(
   p_init_msg_list         IN  VARCHAR2
  ,p_api_version           IN  NUMBER
  ,p_commit                IN  VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,p_qualifiers_tbl        IN  QUALIFIERS_TBL_TYPE
  ,x_error_location        OUT NOCOPY NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'process_market_qualifiers';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_qualifiers_tbl         Qp_Qualifier_Rules_Pub.qualifiers_tbl_type;
  v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
  v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
  v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
  v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
  v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
  v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
  v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
  v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
  l_qualifier_deleted      VARCHAR2(1) := 'N';
  l_qp_list_header_id      NUMBER;

BEGIN
  SAVEPOINT process_market_qualifiers;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  IF NOT Fnd_Api.compatible_api_call
  (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;
  x_error_location := 0;
  IF p_qualifiers_tbl.COUNT > 0 THEN
    FOR i IN p_qualifiers_tbl.first..p_qualifiers_tbl.last LOOP
      IF p_qualifiers_tbl.EXISTS(i) THEN
        IF p_qualifiers_tbl(i).operation <> 'CREATE' THEN
          l_qualifiers_tbl(i).qualifier_id              := p_qualifiers_tbl(i).qualifier_id;
        END IF;
        l_qualifiers_tbl(i).list_header_id            := p_qualifiers_tbl(i).list_header_id;

        IF  p_qualifiers_tbl(i).list_line_id IS NOT NULL
        AND p_qualifiers_tbl(i).list_line_id <> FND_API.G_MISS_NUM
        THEN
          l_qualifiers_tbl(i).list_line_id          := p_qualifiers_tbl(i).list_line_id;
        ELSE
          l_qualifiers_tbl(i).list_line_id          := -1;
        END IF;

        l_qualifiers_tbl(i).qualifier_context         := p_qualifiers_tbl(i).qualifier_context;
        l_qualifiers_tbl(i).qualifier_attribute       := p_qualifiers_tbl(i).qualifier_attribute;
        l_qualifiers_tbl(i).qualifier_attr_value      := p_qualifiers_tbl(i).qualifier_attr_value;
        l_qualifiers_tbl(i).qualifier_attr_value_to   := p_qualifiers_tbl(i).qualifier_attr_value_to;
        l_qualifiers_tbl(i).comparison_operator_code  := p_qualifiers_tbl(i).comparison_operator_code;
        l_qualifiers_tbl(i).qualifier_grouping_no     := p_qualifiers_tbl(i).qualifier_grouping_no;
        l_qualifiers_tbl(i).start_date_active         := p_qualifiers_tbl(i).start_date_active;
        l_qualifiers_tbl(i).end_date_active           := p_qualifiers_tbl(i).end_date_active;
        l_qualifiers_tbl(i).operation                 := p_qualifiers_tbl(i).operation;
        l_qualifiers_tbl(i).context                   := p_qualifiers_tbl(i).context;
        l_qualifiers_tbl(i).attribute1                := p_qualifiers_tbl(i).attribute1;
        l_qualifiers_tbl(i).attribute2                := p_qualifiers_tbl(i).attribute2;
        l_qualifiers_tbl(i).attribute3                := p_qualifiers_tbl(i).attribute3;
        l_qualifiers_tbl(i).attribute4                := p_qualifiers_tbl(i).attribute4;
        l_qualifiers_tbl(i).attribute5                := p_qualifiers_tbl(i).attribute5;
        l_qualifiers_tbl(i).attribute6                := p_qualifiers_tbl(i).attribute6;
        l_qualifiers_tbl(i).attribute7                := p_qualifiers_tbl(i).attribute7;
        l_qualifiers_tbl(i).attribute8                := p_qualifiers_tbl(i).attribute8;
        l_qualifiers_tbl(i).attribute9                := p_qualifiers_tbl(i).attribute9;
        l_qualifiers_tbl(i).attribute10                := p_qualifiers_tbl(i).attribute10;
        l_qualifiers_tbl(i).attribute11                := p_qualifiers_tbl(i).attribute11;
        l_qualifiers_tbl(i).attribute12                := p_qualifiers_tbl(i).attribute12;
        l_qualifiers_tbl(i).attribute13                := p_qualifiers_tbl(i).attribute13;
        l_qualifiers_tbl(i).attribute14                := p_qualifiers_tbl(i).attribute14;
        l_qualifiers_tbl(i).attribute15                := p_qualifiers_tbl(i).attribute15;
        IF p_qualifiers_tbl(i).operation = 'DELETE' THEN
          l_qualifier_deleted := 'Y';
          l_qp_list_header_id := p_qualifiers_tbl(i).list_header_id;
        END IF;
      END IF;
    END LOOP;
  END IF;

  Qp_Modifiers_Pub.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => p_init_msg_list,
      p_return_values          => Fnd_Api.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_qualifiers_tbl         => l_qualifiers_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
   );

  IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
    IF v_qualifiers_tbl.COUNT > 0 THEN
      FOR i IN v_qualifiers_tbl.first..v_qualifiers_tbl.last LOOP
        IF v_qualifiers_tbl.EXISTS(i) THEN
          IF v_qualifiers_tbl(i).return_status <> Fnd_Api.g_ret_sts_success THEN
            x_error_location := i;
            EXIT;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  IF l_qualifier_deleted = 'Y' THEN
    UPDATE ozf_offers
    SET    qualifier_deleted = 'Y'
    WHERE  qp_list_header_id = l_qp_list_header_id;
  END IF;

  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
  IF p_commit = Fnd_Api.g_true THEN
    COMMIT WORK;
  END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO process_market_qualifiers;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO process_market_qualifiers;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO process_market_qualifiers;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;

PROCEDURE offer_budget(
    p_modifier_list_rec   IN modifier_list_rec_type
   ,x_return_status      OUT NOCOPY VARCHAR2
   ,x_msg_count          OUT NOCOPY NUMBER
   ,x_msg_data           OUT NOCOPY VARCHAR2
   ,p_operation           IN VARCHAR2
  ) IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'offer_budget';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_act_budgets_rec   OZF_Actbudgets_Pvt.act_budgets_rec_type;

  CURSOR cur_get_offer_budget IS
  SELECT activity_budget_id,object_version_number
  FROM   ozf_act_budgets
  WHERE  act_budget_used_by_id  = p_modifier_list_rec.qp_list_header_id
  AND    arc_act_budget_used_by = 'OFFR';

  l_activity_budget_id     NUMBER;
  l_object_version_number  NUMBER;

BEGIN

  ----------- initialize -------------
  SAVEPOINT offer_budget;

  x_return_status := Fnd_Api.g_ret_sts_success;

  l_act_budgets_rec.act_budget_used_by_id  := p_modifier_list_rec.qp_list_header_id;
  l_act_budgets_rec.budget_source_id       :=  p_modifier_list_rec.budget_source_id;
  l_act_budgets_rec.budget_source_type     := p_modifier_list_rec.budget_source_type;--'FUND';
  l_act_budgets_rec.transfer_type          := 'REQUEST';
  l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
  l_act_budgets_rec.request_currency       := nvl(p_modifier_list_rec.transaction_currency_code,FND_PROFILE.VALUE('JTF_PROFILE_DEFAULT_CURRENCY'));
  l_act_budgets_rec.approved_in_currency   := nvl(p_modifier_list_rec.transaction_currency_code,FND_PROFILE.VALUE('JTF_PROFILE_DEFAULT_CURRENCY'));
  IF p_modifier_list_rec.offer_type = 'SCAN_DATA' THEN
    IF p_modifier_list_rec.offer_amount = fnd_api.g_miss_num THEN -- calling from offer detail
      l_act_budgets_rec.request_amount       := p_modifier_list_rec.budget_amount_tc;
    END IF;
  ELSE
    l_act_budgets_rec.request_amount       := p_modifier_list_rec.offer_amount;
  END IF;

  IF get_budget_source_count(p_modifier_list_rec.qp_list_header_id) = 0 AND l_act_budgets_rec.request_amount >= 0 THEN
    OZF_Actbudgets_Pvt.create_act_budgets(
       p_api_version      =>  l_api_version
      ,p_init_msg_list    =>  Fnd_Api.g_false
      ,p_commit           =>  Fnd_Api.g_false
      ,p_validation_level =>  Fnd_Api.g_valid_level_full
      ,x_return_status    =>  x_return_status
      ,x_msg_count        =>  x_msg_count
      ,x_msg_data         =>  x_msg_data
      ,p_act_budgets_rec  =>  l_act_budgets_rec
      ,x_act_budget_id    =>  l_activity_budget_id
    );

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;
  ELSE
   ----nepanda : fix for FP of bug number 9151787
    IF p_operation = 'UPDATE' AND p_modifier_list_rec.offer_type = 'SCAN_DATA' AND get_active_budget_source_count(p_modifier_list_rec.qp_list_header_id) =1 THEN
      OPEN cur_get_offer_budget;
      FETCH cur_get_offer_budget INTO l_act_budgets_rec.activity_budget_id, l_act_budgets_rec.object_version_number;
      CLOSE cur_get_offer_budget;
   ozf_utility_pvt.debug_message('GR: l_act_budgets_rec.budget_source_type: ' || l_act_budgets_rec.budget_source_type);
   ozf_utility_pvt.debug_message('GR: l_act_budgets_rec.budget_source_id: ' || l_act_budgets_rec.budget_source_id);

      OZF_Actbudgets_Pvt.update_act_budgets(
         p_api_version      =>  l_api_version
        ,p_init_msg_list    =>  Fnd_Api.g_false
        ,p_commit           =>  Fnd_Api.g_false
        ,p_validation_level =>  Fnd_Api.g_valid_level_full
        ,x_return_status    =>  x_return_status
        ,x_msg_count        =>  x_msg_count
        ,x_msg_data         =>  x_msg_data
        ,p_act_budgets_rec  =>  l_act_budgets_rec
      );
    END IF;

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;
  END IF;

  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO offer_budget;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO offer_budget;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO offer_budget;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END offer_budget;


PROCEDURE offer_object_usage(
  p_modifier_list_rec   IN modifier_list_rec_type
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
 )
IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'offer_object_usage';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_act_offer_rec OZF_Act_Offers_Pvt.act_offer_rec_type;
  l_activity_offer_id  NUMBER := Fnd_Api.g_miss_num;

BEGIN

  ---------- initialize -------------
  SAVEPOINT offer_object_usage;

  x_return_status := Fnd_Api.g_ret_sts_success;

  l_act_offer_rec.act_offer_used_by_id   := p_modifier_list_rec.offer_used_by_id;
  l_act_offer_rec.arc_act_offer_used_by  := 'CAMP';
  l_act_offer_rec.qp_list_header_id      := p_modifier_list_rec.qp_list_header_id;
  l_act_offer_rec.primary_offer_flag     := 'N';

  OZF_Act_Offers_Pvt.Create_Act_Offer
      (
         p_api_version       => 1.0,
         p_init_msg_list     => FND_API.g_false,
         p_commit            => Fnd_Api.g_false,
         p_validation_level  => Fnd_Api.g_valid_level_full,
         x_return_status     => x_return_status ,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_act_offer_rec     => l_act_offer_rec,
         x_act_offer_id      => l_activity_offer_id
      );

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO offer_object_usage;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO offer_object_usage;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO offer_object_usage;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END offer_object_usage;


PROCEDURE process_sales_method
(
   p_init_msg_list          IN   VARCHAR2
  , p_api_version           IN   NUMBER
  , p_commit                IN   VARCHAR2
  , p_modifier_list_rec     IN modifier_list_rec_type
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY NUMBER
  , x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_qualifier_id(l_list_header_id NUMBER) IS
  SELECT qualifier_id
  FROM   qp_qualifiers
  WHERE  list_header_id = l_list_header_id
  AND    qualifier_context = 'SOLD_BY'
  ORDER BY qualifier_id;

  l_qualifier_id NUMBER;

  l_operation VARCHAR2(30);
  l_qualifier_rec  OZF_OFFER_PVT.qualifiers_Rec_Type;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
debug_message('Sales method flag = : '||p_modifier_list_rec.sales_method_flag);
    IF p_modifier_list_rec.sales_method_flag = 'I' OR  p_modifier_list_rec.sales_method_flag = 'D' THEN
--        l_qualifier_rec.operation := 'CREATE';
        l_qualifier_rec.qualifier_id := FND_API.g_miss_num;
        l_qualifier_rec.qualifier_context   := 'SOLD_BY';
        l_qualifier_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE1';
        l_qualifier_rec.qualifier_attr_value := p_modifier_list_rec.sales_method_flag;
        l_qualifier_rec.comparison_operator_code  := '=';
        l_qualifier_rec.qualifier_grouping_no := 20;
        l_qualifier_rec.list_header_id       := p_modifier_list_rec.qp_list_header_id;

    OPEN c_qualifier_id(p_modifier_list_rec.qp_list_header_id);
    FETCH c_qualifier_id INTO l_qualifier_id;
    IF (c_qualifier_id%NOTFOUND) THEN
        l_operation := 'CREATE';
    ELSE
        l_operation := 'UPDATE';
        l_qualifier_rec.qualifier_id := l_qualifier_id;
    END IF;
    debug_message('"Operation is : '||l_operation);
    IF l_operation ='UPDATE' THEN -- in case there are multiple only the first created will be updated
      OZF_Volume_Offer_Qual_PVT.update_vo_qualifier
        (
            p_api_version_number         => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_validation_level         => FND_API.G_VALID_LEVEL_FULL

            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data

            , p_qualifiers_rec           => l_qualifier_rec --  IN   OZF_OFFER_PVT.qualifiers_Rec_Type
        );
    ELSIF l_operation ='CREATE' THEN

    OZF_Volume_Offer_Qual_PVT.create_vo_qualifier
        (
            p_api_version_number         => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_validation_level         => FND_API.G_VALID_LEVEL_FULL

            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data

            , p_qualifiers_rec           => l_qualifier_rec --  IN   OZF_OFFER_PVT.qualifiers_Rec_Type
        );
    END IF;
    END IF;

END process_sales_method;

-------------------------------------------------------
-- Start of Comments
--
-- NAME
--   Offer_qualifier
--
-- PURPOSE
--   This Procedure create Offer QUalifiers from Create or Details screen for Quick Offers.
--
-- IN
--   p_modifier_list_rec         IN   modifier_list_rec_type,
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--
-- NOTES
--
-- HISTORY
--    Tue May 03 2005:2/37 PM RSSHARMA Modified.
--    Support creation of Sales method QUalifier from Create Offer Screen.
-- End of Comments
---------------------------------------------------------

PROCEDURE offer_qualifier(
  p_modifier_list_rec   IN modifier_list_rec_type
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
 )IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'offer_qualifier';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_qualifier_tbl   qualifiers_tbl_type;
  l_error_location NUMBER := 0;
  l_qualifier_id   NUMBER;

  CURSOR c_qualifier_id(l_list_header_id NUMBER) IS
  SELECT qualifier_id
  FROM   qp_qualifiers
  WHERE  list_header_id = l_list_header_id
  AND    list_line_id = -1
  AND    qualifier_context IN ('CUSTOMER', 'CUSTOMER_GROUP','TERRITORY')
  and rownum < 2;

  CURSOR c_sm_qualifier_id(l_list_header_id NUMBER) IS
  SELECT qualifier_id
  FROM   qp_qualifiers
  WHERE  list_header_id = l_list_header_id
  AND    list_line_id = -1
  AND    qualifier_context IN ('SOLD_BY');

  i NUMBER := 0;
  x_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;

  ---Start POS profile Batch changes
  cursor check_Ship_From_Stock(p_offr_code VARCHAR2) IS
  SELECT ship_from_stock_flag
  FROM ozf_request_headers_all_b
  WHERE agreement_number=p_offr_code
  AND ship_from_stock_flag='Y';

  l_spr_accr_offr  VARCHAR2(1):='N';

---End POS profile Batch changes

BEGIN

  ----------- initialize -------------
  SAVEPOINT offer_qualifier;

  x_return_status := Fnd_Api.g_ret_sts_success;
  ---Start POS profile Batch changes

   If p_modifier_list_rec.custom_setup_id=119 THEN
	Open check_Ship_From_Stock(p_modifier_list_rec.offer_code);
	Fetch check_Ship_From_Stock into l_spr_accr_offr;
	IF (check_Ship_From_Stock%NOTFOUND) THEN
         l_spr_accr_offr :='N';
        END IF;
	Close check_Ship_From_Stock;
  END IF;

---End POS profile Batch changes


  IF p_modifier_list_rec.modifier_operation ='UPDATE' THEN
    OPEN  c_qualifier_id(p_modifier_list_rec.qp_list_header_id);
    FETCH c_qualifier_id INTO l_qualifier_id;
    CLOSE c_qualifier_id;

    IF (l_qualifier_id IS NOT NULL AND l_qualifier_id <> FND_API.g_miss_num) THEN
      i := i + 1;
      l_qualifier_tbl(i).operation      := 'DELETE';
      l_qualifier_tbl(i).list_header_id := p_modifier_list_rec.qp_list_header_id;
      l_qualifier_tbl(i).qualifier_id   := l_qualifier_id;
    END IF;

    l_qualifier_id := NULL;

    OPEN  c_sm_qualifier_id(p_modifier_list_rec.qp_list_header_id);
    FETCH c_sm_qualifier_id INTO l_qualifier_id;
    CLOSE c_sm_qualifier_id;

    IF (l_qualifier_id IS NOT NULL AND l_qualifier_id <> FND_API.g_miss_num) THEN
      i := i + 1;
      l_qualifier_tbl(i).operation      := 'DELETE';
      l_qualifier_tbl(i).list_header_id := p_modifier_list_rec.qp_list_header_id;
      l_qualifier_tbl(i).qualifier_id   := l_qualifier_id;
    END IF;

    IF l_qualifier_tbl.COUNT > 0 THEN
      process_market_qualifiers
      (p_api_version       => 1.0,
       p_init_msg_list     => Fnd_Api.g_false,
       p_commit            => Fnd_Api.g_false,
       x_return_status     => x_return_status ,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,
       p_qualifiers_tbl    => l_qualifier_tbl,
       x_error_location    => l_error_location,
       x_qualifiers_tbl    => x_qualifiers_tbl);

      IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    END IF; -- FOR l_qualifier_tbl(1).qualifier_id IS NOT NULL, bug fix 3629490
  END IF; -- end UPDATE mode

  i := 0;
  l_qualifier_tbl.DELETE;

  IF (p_modifier_list_rec.ql_qualifier_id <> Fnd_Api.g_miss_num AND p_modifier_list_rec.ql_qualifier_id IS NOT NULL) THEN
    i := i+1;
    l_qualifier_tbl(i).operation := p_modifier_list_rec.modifier_operation ;
    l_qualifier_tbl(i).list_header_id := p_modifier_list_rec.qp_list_header_id;

    IF p_modifier_list_rec.ql_qualifier_type = 'CUSTOMER' THEN
      l_qualifier_tbl(i).qualifier_context   := 'CUSTOMER';
      l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE2';
    ELSIF p_modifier_list_rec.ql_qualifier_type = 'CUSTOMER_BILL_TO' THEN
      l_qualifier_tbl(i).qualifier_context   := 'CUSTOMER';
      l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE14';
    ELSIF p_modifier_list_rec.ql_qualifier_type = 'BUYER' THEN
      l_qualifier_tbl(i).qualifier_context   := 'CUSTOMER_GROUP';
      l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE3';
    ELSIF p_modifier_list_rec.ql_qualifier_type = 'LIST' THEN
      l_qualifier_tbl(i).qualifier_context   := 'CUSTOMER_GROUP';
      l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE1';
    ELSIF p_modifier_list_rec.ql_qualifier_type = 'SEGMENT' THEN
      l_qualifier_tbl(i).qualifier_context   := 'CUSTOMER_GROUP';
      l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE2';
    ELSIF p_modifier_list_rec.ql_qualifier_type = 'TERRITORY' THEN
       l_qualifier_tbl(i).qualifier_context   := 'TERRITORY';
       l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE1';
    ELSIF p_modifier_list_rec.ql_qualifier_type = 'SHIP_TO' THEN
       l_qualifier_tbl(i).qualifier_context   := 'CUSTOMER';
       l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE11';
    END IF;
-- rssharma Added Code for using Territories as Qualifeir Type


    l_qualifier_tbl(i).qualifier_attr_value := p_modifier_list_rec.ql_qualifier_id;
    l_qualifier_tbl(i).comparison_operator_code  := '=';
    l_qualifier_tbl(i).qualifier_grouping_no := 10;
-- rssharma 28-Oct-2002  changed grouping number to -1 from 10

    l_qualifier_tbl(i).operation := 'CREATE';
    l_qualifier_tbl(i).qualifier_id := FND_API.g_miss_num;
  END IF;

  IF p_modifier_list_rec.sales_method_flag IS NOT NULL AND p_modifier_list_rec.sales_method_flag <> FND_API.g_miss_char THEN
    i := i+1;

    IF p_modifier_list_rec.sales_method_flag = 'I' OR  p_modifier_list_rec.sales_method_flag = 'D' THEN
      l_qualifier_tbl(i).operation := 'CREATE';
      l_qualifier_tbl(i).qualifier_id := FND_API.g_miss_num;
      l_qualifier_tbl(i).qualifier_context   := 'SOLD_BY';
      l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE1';
      l_qualifier_tbl(i).qualifier_attr_value := p_modifier_list_rec.sales_method_flag;
      l_qualifier_tbl(i).comparison_operator_code  := '=';
       --Modified the following piece of code to set the qualifier grouping no for POS profile changes
	IF l_spr_accr_offr='Y' AND p_modifier_list_rec.sales_method_flag = 'I' THEN
	l_qualifier_tbl(i).qualifier_grouping_no := 10;
	ELSE
        l_qualifier_tbl(i).qualifier_grouping_no := 20;
	END IF;
      l_qualifier_tbl(i).list_header_id       := p_modifier_list_rec.qp_list_header_id;
    END IF;
  END IF;

  ---Start POS profile Batch changes

   If (p_modifier_list_rec.custom_setup_id = 119 AND l_spr_accr_offr = 'Y') THEN
   IF (p_modifier_list_rec.ql_qualifier_id <> Fnd_Api.g_miss_num AND p_modifier_list_rec.ql_qualifier_id IS NOT NULL) THEN
	   i := i+1;
	   l_qualifier_tbl(i).operation := 'CREATE' ;
	  l_qualifier_tbl(i).qualifier_id := FND_API.g_miss_num;
	   l_qualifier_tbl(i).qualifier_context   := 'SOLD_BY';
	   l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE2';
	   l_qualifier_tbl(i).qualifier_attr_value := p_modifier_list_rec.ql_qualifier_id;
	   l_qualifier_tbl(i).comparison_operator_code  := '=';
	   l_qualifier_tbl(i).qualifier_grouping_no := 10;
	    l_qualifier_tbl(i).list_header_id       := p_modifier_list_rec.qp_list_header_id;

     END IF;
    END IF;
  ---End POS profile Batch changes


--raise Fnd_Api.g_exc_error;
  IF l_qualifier_tbl.COUNT > 0 THEN
    process_market_qualifiers
    (p_api_version       => 1.0,
     p_init_msg_list     => Fnd_Api.g_false,
     p_commit            => Fnd_Api.g_false,
     x_return_status     => x_return_status ,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,
     p_qualifiers_tbl    => l_qualifier_tbl,
     x_error_location    => l_error_location,
     x_qualifiers_tbl     => x_qualifiers_tbl);

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;
  END IF;

  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO offer_qualifier;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO offer_qualifier;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO offer_qualifier;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END offer_qualifier;


PROCEDURE vo_qualifier
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_list_rec     IN   modifier_list_rec_type
 )
 IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'VO_qualifier';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_qualifier_tbl   qualifiers_tbl_type;
  l_error_location NUMBER := 0;

  CURSOR c_qualifier_id(l_list_header_id NUMBER) IS
  SELECT qualifier_id
  FROM   qp_qualifiers
  WHERE  list_header_id = l_list_header_id
  AND    qualifier_context IN ('CUSTOMER', 'CUSTOMER_GROUP','TERRITORY')
  ORDER BY qualifier_id;
  l_qualifier_id NUMBER;

  l_operation VARCHAR2(30);

  i NUMBER := 0;
   x_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
l_qualifiers_rec  OZF_OFFER_PVT.qualifiers_Rec_Type;
BEGIN

  ----------- initialize -------------
  SAVEPOINT vo_qualifier_pvt;

  x_return_status := Fnd_Api.g_ret_sts_success;
  IF
     (p_modifier_list_rec.ql_qualifier_id <> Fnd_Api.g_miss_num
    AND   p_modifier_list_rec.ql_qualifier_id IS NOT NULL)
  THEN
--  i := i+1;
--  l_qualifiers_rec.operation := p_modifier_list_rec.modifier_operation ;
  l_qualifiers_rec.list_header_id := p_modifier_list_rec.qp_list_header_id;

  IF p_modifier_list_rec.ql_qualifier_type = 'CUSTOMER' THEN
    l_qualifiers_rec.qualifier_context   := 'CUSTOMER';
    l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE2';
  ELSIF p_modifier_list_rec.ql_qualifier_type = 'CUSTOMER_BILL_TO' THEN
    l_qualifiers_rec.qualifier_context   := 'CUSTOMER';
    l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE14';
  ELSIF p_modifier_list_rec.ql_qualifier_type = 'BUYER' THEN
    l_qualifiers_rec.qualifier_context   := 'CUSTOMER_GROUP';
    l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE3';
  ELSIF p_modifier_list_rec.ql_qualifier_type = 'LIST' THEN
    l_qualifiers_rec.qualifier_context   := 'CUSTOMER_GROUP';
    l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE1';
  ELSIF p_modifier_list_rec.ql_qualifier_type = 'SEGMENT' THEN
    l_qualifiers_rec.qualifier_context   := 'CUSTOMER_GROUP';
    l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE2';
   ELSIF p_modifier_list_rec.ql_qualifier_type = 'TERRITORY' THEN
     l_qualifiers_rec.qualifier_context   := 'TERRITORY';
     l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE1';
   ELSIF p_modifier_list_rec.ql_qualifier_type = 'SHIP_TO' THEN
     l_qualifiers_rec.qualifier_context   := 'CUSTOMER';
     l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE11';
--   QUALIFIER_ATTRIBUTE11
   END IF;
-- rssharma Added Code for using Territories as Qualifeir Type


  l_qualifiers_rec.qualifier_attr_value := p_modifier_list_rec.ql_qualifier_id;
  l_qualifiers_rec.comparison_operator_code  := '=';
  l_qualifiers_rec.qualifier_grouping_no := 10;

    OPEN c_qualifier_id(p_modifier_list_rec.qp_list_header_id);
    FETCH c_qualifier_id INTO l_qualifier_id;
    IF (c_qualifier_id%NOTFOUND) THEN
        l_operation := 'CREATE';
    ELSE
        l_operation := 'UPDATE';
        l_qualifiers_rec.qualifier_id := l_qualifier_id;
    END IF;
    IF l_operation ='UPDATE' THEN -- in case there are multiple only the first created will be updated
      OZF_Volume_Offer_Qual_PVT.update_vo_qualifier
        (
            p_api_version_number         => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_validation_level         => FND_API.G_VALID_LEVEL_FULL

            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data

            , p_qualifiers_rec           => l_qualifiers_rec --  IN   OZF_OFFER_PVT.qualifiers_Rec_Type
        );
    ELSIF l_operation ='CREATE' THEN

    OZF_Volume_Offer_Qual_PVT.create_vo_qualifier
        (
            p_api_version_number         => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_validation_level         => FND_API.G_VALID_LEVEL_FULL

            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data

            , p_qualifiers_rec           => l_qualifiers_rec --  IN   OZF_OFFER_PVT.qualifiers_Rec_Type
        );
    END IF;

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

debug_message('"Calling process sales method');
process_sales_method
(
   p_init_msg_list          => p_init_msg_list
  , p_api_version           => p_api_version
  , p_commit                => p_commit
  , p_modifier_list_rec     => p_modifier_list_rec
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
);

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;


  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
    END IF;
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    ROLLBACK TO vo_qualifier_pvt;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO vo_qualifier_pvt;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    ROLLBACK TO vo_qualifier_pvt;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END vo_qualifier;


--nirprasa
PROCEDURE populate_limits_rec(
  p_limit_type  IN VARCHAR2,
  x_limits_rec  OUT NOCOPY QP_Limits_PUB.Limits_Rec_Type,
  p_limit_exceed_action_code    IN   VARCHAR2 DEFAULT NULL) IS
BEGIN

  IF p_limit_exceed_action_code IS NOT NULL AND p_limit_exceed_action_code <> FND_API.G_MISS_CHAR THEN
  x_limits_rec.limit_exceed_action_code := p_limit_exceed_action_code;
  END IF;

  x_limits_rec.limit_hold_flag          := 'Y';
  x_limits_rec.organization_flag        := 'N';
  x_limits_rec.operation                := 'CREATE';

  IF p_limit_type = 'MAX_QTY_PER_ORDER' THEN
    x_limits_rec.limit_level_code       := 'TRANSACTION';
  ELSE
    x_limits_rec.limit_level_code       := 'ACROSS_TRANSACTION';
  END IF;

  IF p_limit_type = 'MAX_ORDERS_PER_CUSTOMER' THEN
    x_limits_rec.basis       := 'USAGE';
  ELSIF p_limit_type = 'MAX_AMOUNT_PER_RULE' THEN
    x_limits_rec.basis       := 'COST';
  ELSIF p_limit_type IN ('MAX_QTY_PER_ORDER','MAX_QTY_PER_CUSTOMER','MAX_QTY_PER_RULE') THEN
    x_limits_rec.basis       := 'QUANTITY';
  END IF;

  IF p_limit_type IN ('MAX_QTY_PER_CUSTOMER','MAX_ORDERS_PER_CUSTOMER') THEN
     x_limits_rec.multival_attr1_type       := 'QUALIFIER';
     x_limits_rec.multival_attr1_context    := 'CUSTOMER';
     x_limits_rec.multival_attribute1       := 'QUALIFIER_ATTRIBUTE2';
  END IF;

  IF p_limit_type = 'MAX_QTY_PER_ORDER' THEN
    x_limits_rec.limit_number := 1;
  ELSIF p_limit_type = 'MAX_QTY_PER_CUSTOMER' THEN
    x_limits_rec.limit_number := 2;
  ELSIF p_limit_type = 'MAX_QTY_PER_RULE' THEN
    x_limits_rec.limit_number := 3;
  ELSIF p_limit_type = 'MAX_ORDERS_PER_CUSTOMER' THEN
    x_limits_rec.limit_number := 4;
  ELSIF p_limit_type = 'MAX_AMOUNT_PER_RULE' THEN
    x_limits_rec.limit_number := 5;
  END IF;
END populate_limits_rec;

-- This procedure will only handle limits at the line level. Header Level
-- Limits are processed in process_qp_list_header itself.

PROCEDURE process_limits(
  x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_limit_type            IN   VARCHAR2
 ,p_limit_amount          IN   NUMBER DEFAULT fnd_api.g_miss_num
 ,p_list_line_id          IN   NUMBER DEFAULT fnd_api.g_miss_num
 ,p_list_header_id        IN   NUMBER
 ,p_limit_id              IN   NUMBER DEFAULT fnd_api.g_miss_num
 ,p_limit_exceed_action_code    IN   VARCHAR2 DEFAULT NULL
 )
IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'process_limits';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  CURSOR cur_does_limit_exist(p_limit_number NUMBER) IS
  SELECT count(limit_id)
  FROM   qp_limits
  WHERE  list_line_id = p_list_line_id
  AND    limit_number = p_limit_number;

  l_limit_exists NUMBER;
  l_limit_number NUMBER;

  l_limits_rec                    QP_Limits_PUB.Limits_Rec_Type;
  v_limits_rec                    QP_Limits_PUB.Limits_Rec_Type;
  v_limits_val_rec                QP_Limits_PUB.Limits_Val_Rec_Type;
  v_limit_attrs_tbl               QP_Limits_PUB.Limit_Attrs_Tbl_Type;
  v_limit_attrs_val_tbl           QP_Limits_PUB.Limit_Attrs_Val_Tbl_Type;
  v_limit_balances_tbl            QP_Limits_PUB.Limit_Balances_Tbl_Type;
  v_limit_balances_val_tbl        QP_Limits_PUB.Limit_Balances_Val_Tbl_Type;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  IF p_limit_id = fnd_api.g_miss_num
  AND ( p_limit_amount = fnd_api.g_miss_num or p_limit_amount IS NULL) THEN
    RETURN;
  END IF;

  IF p_limit_type = 'MAX_QTY_PER_ORDER' THEN
    l_limit_number := 1;
  ELSIF p_limit_type = 'MAX_QTY_PER_CUSTOMER' THEN
    l_limit_number := 2;
  ELSIF p_limit_type = 'MAX_QTY_PER_RULE' THEN
    l_limit_number := 3;
  ELSIF p_limit_type = 'MAX_ORDERS_PER_CUSTOMER' THEN
    l_limit_number := 4;
  ELSIF p_limit_type = 'MAX_AMOUNT_PER_RULE' THEN
    l_limit_number := 5;
  END IF;

  OPEN cur_does_limit_exist(l_limit_number);
  FETCH cur_does_limit_exist INTO l_limit_exists;
  CLOSE cur_does_limit_exist;

  IF l_limit_exists > 0 THEN
    IF p_limit_amount IS NULL THEN
      l_limits_rec.operation := 'DELETE';
      l_limits_rec.limit_id := p_limit_id;
    ELSIF p_limit_amount <> fnd_api.g_miss_num THEN
      l_limits_rec.operation := 'UPDATE';
      l_limits_rec.limit_id  := p_limit_id;
      l_limits_rec.amount    := p_limit_amount;
    END IF;
  ELSE
  --nirprasa
    IF p_limit_exceed_action_code IS NOT NULL AND p_limit_exceed_action_code <> FND_API.G_MISS_CHAR THEN
    populate_limits_rec(p_limit_type,l_limits_rec,p_limit_exceed_action_code);
    ELSE
    populate_limits_rec(p_limit_type,l_limits_rec);
    END IF;

    l_limits_rec.list_line_id   := p_list_line_id;
    l_limits_rec.list_header_id := p_list_header_id;
    l_limits_rec.amount         := p_limit_amount;
  END IF;

-- as per suggetsion from Renuka and Karan for error message
-- ORA-01400: cannot insert NULL into ("QP"."QP_LIMITS"."AMOUNT") in Package QP_Limits_Util Procedure

  IF l_limits_rec.amount IS NOT NULL AND
         l_limits_rec.amount <> FND_API.G_MISS_NUM THEN

  QP_Limits_PUB.Process_Limits
  ( p_init_msg_list           =>  FND_API.g_true,
    p_api_version_number      =>  1.0,
    p_commit                  =>  FND_API.g_false,
    x_return_status           =>  x_return_status,
    x_msg_count               =>  x_msg_count,
    x_msg_data                =>  x_msg_data,
    p_LIMITS_rec              =>  l_limits_rec,
    x_LIMITS_rec              =>  v_LIMITS_rec,
    x_LIMITS_val_rec          =>  v_LIMITS_val_rec,
    x_LIMIT_ATTRS_tbl         =>  v_LIMIT_ATTRS_tbl,
    x_LIMIT_ATTRS_val_tbl     =>  v_LIMIT_ATTRS_val_tbl,
    x_LIMIT_BALANCES_tbl      =>  v_LIMIT_BALANCES_tbl,
    x_LIMIT_BALANCES_val_tbl  =>  v_LIMIT_BALANCES_val_tbl
  );

 END IF;

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;
  Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_error ;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END process_limits;


-------------------------------------------------------
-- Start of Comments
--
-- NAME
--   Post_Lumpsum_Offer
--
-- PURPOSE
--   This Procedure posts a lumpsum type offer.
--
-- IN
--   p_init_msg_list         IN   VARCHAR2,
--   p_api_version           IN   NUMBER,
--   p_commit                IN   VARCHAR2,
--   p_offer_rec             IN   offers_rec_type
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--
-- NOTES
--
-- HISTORY
--    15-MAY-2001    julou    created
-- End of Comments
---------------------------------------------------------
PROCEDURE Post_Lumpsum_Offer(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   p_commit                IN   VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_offer_rec             IN   modifier_list_rec_type
   )
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Post_Lumpsum_Offer';
  l_api_version        CONSTANT NUMBER   := 1.0;
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
  l_old_status_id NUMBER;
  l_approval_type VARCHAR2(30);
  l_offer_rec  modifier_list_rec_type := p_offer_rec;

  CURSOR c_old_user_status_id IS
  SELECT user_status_id
  FROM   ozf_offers
  WHERE  qp_list_header_id = l_offer_rec.qp_list_header_id;

BEGIN
  SAVEPOINT post_lumpsum_offer;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_old_user_status_id;
  FETCH c_old_user_status_id INTO l_old_status_id;
  CLOSE c_old_user_status_id;

  OZF_Utility_PVT.check_new_status_change
    (
      p_object_type      => 'OFFR',
      p_object_id        => l_offer_rec.qp_list_header_id,
      p_old_status_id    => l_old_status_id,
      p_new_status_id    => l_offer_rec.user_status_id,
      p_custom_setup_id  => l_offer_rec.custom_setup_id,
      x_approval_type    => l_approval_type,
         x_return_status    => x_return_status
    );

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  OZF_Fund_Adjustment_PVT.post_utilized_budget(
       p_offer_id        => p_offer_rec.qp_list_header_id
      ,p_offer_type      => 'LUMPSUM'
      ,p_api_version     => p_api_version
      ,p_init_msg_list    => p_init_msg_list
      ,p_commit          => FND_API.G_FALSE
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,x_return_status   => x_return_status);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.Count_And_Get
  (
    p_count          =>   x_msg_count,
    p_data           =>   x_msg_data,
    p_encoded        =>      FND_API.G_FALSE
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.g_ret_sts_error ;
    ROLLBACK TO post_lumpsum_offer;
    FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      l_msg_count,
           p_data        =>      l_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    ROLLBACK TO post_lumpsum_offer;
    FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      l_msg_count,
           p_data            =>      l_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    ROLLBACK TO post_lumpsum_offer;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      l_msg_count,
         p_data            =>      l_msg_data,
         p_encoded           =>      FND_API.G_FALSE
        );

END Post_Lumpsum_Offer ;


-------------------------------------------------------
-- Start of Comments
--
-- NAME
--   Post_Scan_Data_Offer
--
-- PURPOSE
--   This Procedure posts a Scan Data type offer.
--
-- IN
--   p_init_msg_list         IN   VARCHAR2,
--   p_api_version           IN   NUMBER,
--   p_commit                IN   VARCHAR2,
--   p_offer_rec             IN   offers_rec_type
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--
-- NOTES
--
-- HISTORY
--    02-OCT-2002    julou    created
-- End of Comments
---------------------------------------------------------
PROCEDURE Post_Scan_Data_Offer(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   p_commit                IN   VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_offer_rec             IN   modifier_list_rec_type
   )
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Post_Scan_Data_Offer';
  l_api_version        CONSTANT NUMBER   := 1.0;
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
  l_old_status_id NUMBER;
  l_approval_type VARCHAR2(30);
  l_offer_rec  modifier_list_rec_type := p_offer_rec;

  CURSOR c_old_user_status_id IS
  SELECT user_status_id
  FROM   ozf_offers
  WHERE  qp_list_header_id = l_offer_rec.qp_list_header_id;

BEGIN
  SAVEPOINT post_scan_data_offer;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_old_user_status_id;
  FETCH c_old_user_status_id INTO l_old_status_id;
  CLOSE c_old_user_status_id;

  OZF_Utility_PVT.check_new_status_change
    (
      p_object_type      => 'OFFR',
      p_object_id        => l_offer_rec.qp_list_header_id,
      p_old_status_id    => l_old_status_id,
      p_new_status_id    => l_offer_rec.user_status_id,
      p_custom_setup_id  => l_offer_rec.custom_setup_id,
      x_approval_type    => l_approval_type,
         x_return_status    => x_return_status
    );

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  OZF_Fund_Adjustment_PVT.post_utilized_budget(
       p_offer_id        => p_offer_rec.qp_list_header_id
      ,p_offer_type      => 'SCAN_DATA'
      ,p_api_version     => p_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,p_commit          => p_commit
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,x_return_status   => x_return_status);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.Count_And_Get
  (
    p_count   => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => FND_API.G_FALSE
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.g_ret_sts_error ;
    ROLLBACK TO post_scan_data_offer;
    FND_MSG_PUB.Count_AND_Get
         ( p_count   => l_msg_count,
           p_data    => l_msg_data,
           p_encoded => FND_API.G_FALSE
          );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    ROLLBACK TO post_scan_data_offer;
    FND_MSG_PUB.Count_AND_Get
         ( p_count   => l_msg_count,
           p_data    => l_msg_data,
           p_encoded => FND_API.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    ROLLBACK TO post_scan_data_offer;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_AND_Get
       ( p_count   => l_msg_count,
         p_data    => l_msg_data,
         p_encoded => FND_API.G_FALSE
        );

END Post_Scan_Data_Offer ;


--------------------------------------------------
-- Start of Comments
--
-- NAME
--   validate_offer_dates
--
-- PURPOSE
--   This Procedure validates the dates in offer rec.
--
-- IN
--   p_init_msg_list         IN   VARCHAR2,
--   p_api_version           IN   NUMBER,
--   p_offer_rec             IN   offers_rec_type
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--
-- NOTES
--
-- HISTORY
--    17-OCT-2001    julou    created
-- End of Comments
-------------------------------------------------
PROCEDURE validate_offer_dates
(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_offer_rec             IN   modifier_list_rec_type
   )
IS

  CURSOR c_creation_date(l_list_header_id NUMBER) IS
  SELECT TRUNC(creation_date)
  FROM   qp_list_headers
  WHERE  list_header_id = l_list_header_id;

  l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Offer_Dates';
  l_api_version        CONSTANT NUMBER   := 1.0;
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
  l_creation_date DATE;

BEGIN
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
  IF p_offer_rec.start_date_active IS NOT NULL
  AND p_offer_rec.start_date_active <> FND_API.G_MISS_DATE THEN
    IF p_offer_rec.offer_operation = 'CREATE' THEN
      IF p_offer_rec.start_date_active < TRUNC(SYSDATE) THEN
        IF p_offer_rec.offer_type <> 'NET_ACCRUAL' AND p_offer_rec.custom_setup_id <> 117 THEN
          Fnd_Message.SET_NAME('OZF','OZF_OFFR_STARTDATE_LT_SYSDATE');
          Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    ELSIF p_offer_rec.offer_operation = 'UPDATE' THEN
      OPEN c_creation_date(p_offer_rec.qp_list_header_id);
      FETCH c_creation_date INTO l_creation_date;
      CLOSE c_creation_date;
      IF p_offer_rec.start_date_active < l_creation_date THEN
        IF p_offer_rec.offer_type <> 'NET_ACCRUAL' AND p_offer_rec.custom_setup_id <> 117 THEN
          Fnd_Message.SET_NAME('OZF','OZF_OFFR_STARTDATE_LT_CREDATE');
          Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;
  END IF;
*/
  IF p_offer_rec.end_date_active IS NOT NULL
  AND p_offer_rec.end_date_active <> FND_API.G_MISS_DATE THEN
    IF p_offer_rec.offer_operation = 'CREATE' THEN
      IF p_offer_rec.end_date_active < TRUNC(SYSDATE) THEN
        IF p_offer_rec.offer_type <> 'NET_ACCRUAL' AND p_offer_rec.custom_setup_id <> 117 THEN
          Fnd_Message.SET_NAME('OZF','OZF_OFFR_ENDDATE_LT_SYSDATE');
          Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    ELSIF p_offer_rec.offer_operation = 'UPDATE' THEN
      OPEN c_creation_date(p_offer_rec.qp_list_header_id);
      FETCH c_creation_date INTO l_creation_date;
      CLOSE c_creation_date;
      IF p_offer_rec.end_date_active < l_creation_date THEN
        IF p_offer_rec.offer_type <> 'NET_ACCRUAL' AND p_offer_rec.custom_setup_id <> 117 THEN
          Fnd_Message.SET_NAME('OZF','OZF_OFFR_ENDDATE_LT_CREDATE');
          Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;
  END IF;

  IF p_offer_rec.offer_type IN ('SCAN_DATA', 'NET_ACCRUAL')
  OR (p_offer_rec.offer_type = 'LUMPSUM' AND p_offer_rec.custom_setup_id <> 110) -- not applicable to soft fund
  THEN
    IF p_offer_rec.start_date_active IS NULL THEN
      ozf_utility_pvt.error_message('OZF_OFFR_NO_START_DATE');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.g_ret_sts_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      l_msg_count,
           p_data        =>      l_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      l_msg_count,
           p_data            =>      l_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      l_msg_count,
         p_data            =>      l_msg_data,
         p_encoded           =>      FND_API.G_FALSE
        );
END validate_offer_dates;

-------------------------------------------------
-- Start of Comments
--
-- NAME
--   validate_offer
--
-- PURPOSE
--   This Procedure validates the offer
--
-- IN
--   p_init_msg_list         IN   VARCHAR2,
--   p_api_version           IN   NUMBER,
--   p_offer_rec             IN   offers_rec_type
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--
-- NOTES
--
-- HISTORY
--    15-MAY-2001    julou    created
--    29-MAY-2001    julou    modified
--                            no validatation for approved amount and offer amount
--                            if budget approval is not required
-- End of Comments
-------------------------------------------------
PROCEDURE Validate_Offer(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_offer_rec             IN   modifier_list_rec_type
   )
IS

  CURSOR c_approved_amount(l_id NUMBER) IS
  SELECT nvl(sum(approved_amount),0)
  FROM   ozf_act_budgets
  WHERE  arc_act_budget_used_by = 'OFFR'
  AND    act_budget_used_by_id = l_id;

  l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Offer';
  l_api_version        CONSTANT NUMBER   := 1.0;
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
  l_approved_amount  NUMBER;

  l_estimated_amount  NUMBER;
  l_bapl_count NUMBER;
  l_offers_rec  modifier_list_rec_type := p_offer_rec;

  CURSOR cur_attr_avail_flag IS
  SELECT attr_available_flag
  FROM   ams_custom_setup_attr
  WHERE  custom_setup_id = p_offer_rec.custom_setup_id
  AND    object_attribute = 'BREQ';

  CURSOR c_committed_amount IS
  SELECT NVL(SUM(scan_value * scan_unit_forecast/quantity), 0)
  FROM   ams_act_products
  WHERE  arc_act_product_used_by = 'OFFR'
  AND    act_product_used_by_id = p_offer_rec.qp_list_header_id;

  l_attr_avail_flag        VARCHAR2(1);
  l_recal VARCHAR2(1);
  l_committed_amount    NUMBER := 0;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN cur_attr_avail_flag;
  FETCH cur_attr_avail_flag INTO l_attr_avail_flag;
  CLOSE cur_attr_avail_flag;

  IF l_attr_avail_flag = 'Y' THEN

    --IF l_offers_rec.offer_type NOT IN ('OID','TERMS') THEN  -- Header Level Limits not enforced for Promotional Goods


    OPEN c_approved_amount(l_offers_rec.qp_list_header_id);
    FETCH c_approved_amount INTO l_approved_amount;
    CLOSE c_approved_amount;

    l_recal := NVL(FND_PROFILE.VALUE('OZF_BUDGET_ADJ_ALLOW_RECAL'), 'Y');
    --julou checking approved amount vs committed amount for recal=N and lumpsum, scan_data
    IF l_recal = 'N' OR (l_recal = 'Y' AND p_offer_rec.offer_type IN ('LUMPSUM', 'SCAN_DATA')) THEN
      -- populate committed amount
      IF p_offer_rec.offer_type = 'SCAN_DATA' THEN
        OPEN c_committed_amount;
        FETCH c_committed_amount INTO l_committed_amount;
        CLOSE c_committed_amount;
      ELSIF p_offer_rec.offer_type = 'LUMPSUM' THEN
        IF p_offer_rec.lumpsum_amount IS NULL
        OR p_offer_rec.lumpsum_amount = FND_API.G_MISS_NUM THEN
          l_committed_amount := 0;
        ELSE
          l_committed_amount := p_offer_rec.lumpsum_amount;
        END IF;
      ELSE -- other offer types
        IF p_offer_rec.offer_amount IS NULL
        OR p_offer_rec.offer_amount = FND_API.G_MISS_NUM THEN
          l_committed_amount := 0;
        ELSE
          l_committed_amount := p_offer_rec.offer_amount;
        END IF;
      END IF;

      IF l_committed_amount > l_approved_amount THEN
        OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFER_AMNT_GT_APPR_AMNT');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF l_recal = 'Y' AND p_offer_rec.offer_type NOT IN ('LUMPSUM', 'SCAN_DATA') THEN
      IF l_approved_amount < 0 THEN
        OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_NO_APPROVED_AMOUNT');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;

  FND_MSG_PUB.Count_And_Get
     (
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data,
      p_encoded        =>   FND_API.G_FALSE
     );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.g_ret_sts_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      l_msg_count,
           p_data        =>      l_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      l_msg_count,
           p_data            =>      l_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      l_msg_count,
         p_data            =>      l_msg_data,
         p_encoded           =>      FND_API.G_FALSE
        );

END validate_offer;

PROCEDURE validate_scandata_budget(
               p_init_msg_list     IN  VARCHAR2
              ,p_api_version       IN  NUMBER
              ,x_return_status     OUT NOCOPY VARCHAR2
              ,x_msg_count         OUT NOCOPY NUMBER
              ,x_msg_data          OUT NOCOPY VARCHAR2
              ,p_qp_list_header_id IN  NUMBER)
IS
  CURSOR c_request_amount IS
  SELECT NVL(SUM(request_amount), 0)
    FROM ozf_act_budgets
   WHERE arc_act_budget_used_by = 'OFFR'
     AND act_budget_used_by_id = p_qp_list_header_id;

  CURSOR c_committed_amount IS
  SELECT NVL(SUM(scan_value * scan_unit_forecast/quantity), 0)
    FROM ams_act_products
   WHERE arc_act_product_used_by = 'OFFR'
     AND act_product_used_by_id = p_qp_list_header_id;

  l_api_name    CONSTANT VARCHAR2(30) := 'validate_scandata_budget';
  l_api_version        CONSTANT NUMBER   := 1.0;
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;

  l_request_amount  NUMBER;
  l_committed_amount  NUMBER;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  c_request_amount;
  FETCH c_request_amount INTO l_request_amount;
  IF c_request_amount%NOTFOUND THEN
    CLOSE c_request_amount;
    OZF_Utility_PVT.Error_Message('OZF_OFFR_NO_BUDGET_REQUEST');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_request_amount;

  OPEN c_committed_amount;
  FETCH c_committed_amount INTO l_committed_amount;
  CLOSE c_committed_amount;

  IF l_committed_amount > l_request_amount THEN
    OZF_Utility_PVT.Error_Message('OZF_OFFR_REQAMT_LT_OFFAMT');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FND_MSG_PUB.Count_And_Get
  (p_count          =>   x_msg_count,
   p_data           =>   x_msg_data,
   p_encoded        =>   FND_API.G_FALSE);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error ;
      FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      l_msg_count,
          p_data        =>      l_msg_data,
          p_encoded    =>      FND_API.G_FALSE
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      l_msg_count,
          p_data            =>      l_msg_data,
          p_encoded        =>      FND_API.G_FALSE
        );
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      l_msg_count,
          p_data            =>      l_msg_data,
          p_encoded           =>      FND_API.G_FALSE
         );

END validate_scandata_budget;

-------------------------------------------------
-- Start of Comments
--
-- NAME
--   Push_Target_group
--
-- PURPOSE
--   This Procedure pushes target group info for each schedule into QP
--
-- IN
--   p_init_msg_list         IN   VARCHAR2,
--   p_api_version           IN   NUMBER,
--   p_commit                IN   VARCHAR2,
--   p_offer_rec             IN   offers_rec_type
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--
-- NOTES
--
-- HISTORY
--    15-MAY-2001    julou    created
-- End of Comments
-------------------------------------------------
PROCEDURE Push_Target_group(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   p_commit                IN   VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_offer_rec             IN   modifier_list_rec_type
   )
IS

  CURSOR c_act_offer(l_qp_id NUMBER) IS
  SELECT act_offer_used_by_id
  FROM   ozf_act_offers
  WHERE  arc_act_offer_used_by = 'CSCH'
  AND    qp_list_header_id = l_qp_id;
  l_act_offer_rec c_act_offer%ROWTYPE;

  CURSOR c_list_header_id(l_sch_id NUMBER) IS
  SELECT list_header_id
  FROM   ams_act_lists
  WHERE  list_act_type = 'TARGET'
  AND    list_used_by = 'CSCH'
  AND    list_used_by_id = l_sch_id;

  CURSOR c_schedule_dates(l_sch_id NUMBER) IS
  SELECT start_date_time, end_date_time
  FROM   ams_campaign_schedules_vl
  WHERE  schedule_id = l_sch_id
    AND  status_code = 'ACTIVE';
  l_schedule_dates  c_schedule_dates%ROWTYPE;

  l_api_name    CONSTANT VARCHAR2(30) := 'Push_Target_group';
  l_api_version        CONSTANT NUMBER   := 1.0;
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
  l_list_header_id NUMBER;
  l_qualifiers_tbl  qualifiers_tbl_type;
  l_error_location NUMBER;

  l_index NUMBER ;
  x_qualifiers_tbl        qp_qualifier_rules_pub.qualifiers_tbl_type;
BEGIN
   SAVEPOINT Push_Target_group;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_index := 1;

   FOR l_act_offer_rec IN c_act_offer(p_offer_rec.qp_list_header_id)
   LOOP

      OPEN c_list_header_id(l_act_offer_rec.act_offer_used_by_id);
      FETCH c_list_header_id INTO l_list_header_id;
      CLOSE c_list_header_id;

      OPEN c_schedule_dates(l_act_offer_rec.act_offer_used_by_id);
      FETCH c_schedule_dates INTO l_schedule_dates;

      IF c_schedule_dates%FOUND THEN

         l_qualifiers_tbl(l_index).qualifier_context := 'CUSTOMER_GROUP';
         l_qualifiers_tbl(l_index).qualifier_attribute := 'QUALIFIER_ATTRIBUTE1';
         l_qualifiers_tbl(l_index).qualifier_attr_value := l_list_header_id;
         l_qualifiers_tbl(l_index).comparison_operator_code := '=';
         l_qualifiers_tbl(l_index).list_header_id := p_offer_rec.qp_list_header_id;
         l_qualifiers_tbl(l_index).start_date_active := l_schedule_dates.start_date_time;
         l_qualifiers_tbl(l_index).end_date_active := l_schedule_dates.end_date_time;
         l_qualifiers_tbl(l_index).operation := 'CREATE';

         l_index := l_index + 1;

      END IF;

      CLOSE c_schedule_dates;

   END LOOP;

  IF l_qualifiers_tbl.count > 0  THEN
   process_market_qualifiers
   (
      p_init_msg_list  => p_init_msg_list
     ,p_api_version    => p_api_version
     ,p_commit         => FND_API.g_false
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
     ,p_qualifiers_tbl => l_qualifiers_tbl
     ,x_error_location => l_error_location
     ,x_qualifiers_tbl => x_qualifiers_tbl
    );


   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  END IF;

   FND_MSG_PUB.Count_And_Get
   ( p_count          =>   x_msg_count,
     p_data           =>   x_msg_data,
     p_encoded          =>   FND_API.G_FALSE
    );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.g_ret_sts_error ;
    ROLLBACK TO Push_Target_group;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      l_msg_count,
           p_data        =>      l_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.g_ret_sts_unexp_error ;
    ROLLBACK TO Push_Target_group;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      l_msg_count,
           p_data            =>      l_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
 WHEN OTHERS THEN
       x_return_status := FND_API.g_ret_sts_unexp_error ;
    ROLLBACK TO Push_Target_group;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      l_msg_count,
         p_data            =>      l_msg_data,
         p_encoded           =>      FND_API.G_FALSE
        );

END Push_Target_group;


PROCEDURE update_request_status (
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,
  p_qp_list_header_id IN         NUMBER
)
IS
  CURSOR c_req_header_rec(p_offer_id IN NUMBER) IS
  SELECT req.request_header_id,req.object_version_number,req.status_code
  FROM   ozf_request_headers_all_b req,ozf_offers off
  WHERE  req.request_number = off.offer_code
  AND    off.qp_list_header_id = p_offer_id;

  l_req_header_id NUMBER;
  l_obj_ver_num   NUMBER;
  l_status_code   VARCHAR2 (30);
  l_return_status VARCHAR2 (10)  := fnd_api.g_ret_sts_success;
  l_api_name      VARCHAR2 (60)  := 'update_request_status';
  l_full_name     VARCHAR2 (100) := g_pkg_name||'.'||l_api_name;
  l_api_version   NUMBER         := 1;
BEGIN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high) THEN
    debug_message(l_full_name||' : '||'begin');
  END IF;

  OPEN  c_req_header_rec(p_qp_list_header_id);
  FETCH c_req_header_rec INTO l_req_header_id, l_obj_ver_num, l_status_code;
  CLOSE c_req_header_rec;

  IF l_status_code <> 'APPROVED' THEN
    UPDATE ozf_request_headers_all_b
    SET    status_code ='APPROVED',
           object_version_number = l_obj_ver_num + 1
    WHERE  request_header_id = l_req_header_id;
  END IF;

  fnd_msg_pub.count_and_get (p_count=> x_msg_count,
                             p_data=> x_msg_data,
                             p_encoded=> fnd_api.g_false);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count=> x_msg_count,
                                 p_data=> x_msg_data,
                                 p_encoded=> fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count=> x_msg_count,
                                 p_data=> x_msg_data,
                                 p_encoded=> fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get (p_count=> x_msg_count,
                                 p_data=> x_msg_data,
                                 p_encoded=> fnd_api.g_false);
END update_request_status;


-------------------------------------------------
-- Start of Comments
--
-- NAME
--   Activate_Offer_Over
--
-- PURPOSE
--   This Procedure actives the offer if certain conditions are met.
--
-- IN
--   p_init_msg_list         IN   VARCHAR2,
--   p_api_version           IN   NUMBER,
--   p_commit                IN   VARCHAR2,
--   p_offer_rec             IN   offers_rec_type
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--
-- NOTES
--
-- HISTORY
--    15-MAY-2001    julou    created
-- End of Comments
-------------------------------------------------
PROCEDURE Activate_Offer_Over(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   p_commit                IN   VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_called_from            IN  VARCHAR2, -- possible values 'B' Budget,'R' -Regular
   p_offer_rec             IN   modifier_list_rec_type,
   x_amount_error          OUT NOCOPY  VARCHAR2
   )
IS

  CURSOR c_offer_id(p_qp_list_header_id NUMBER) IS
  SELECT offer_id
  FROM   ozf_offers
  WHERE  qp_list_header_id = p_qp_list_header_id;

  CURSOR c_offer_start_date(p_list_header_id NUMBER) IS
  SELECT q.start_date_active, o.start_date
  FROM   qp_list_headers_b q, ozf_offers o
  WHERE  o.qp_list_header_id = q.list_header_id
  AND    q.list_header_id = p_list_header_id;

-- nepanda : start : fix for bug 8507709 : added cursor to find out if data is already there in qp_list_line table for an offer
  CURSOR c_exists_in_qp_list_line(l_list_header_id NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM qp_list_lines
                  WHERE list_header_id = l_list_header_id);
  l_exists_in_qp_list_line NUMBER;
-- nepanda : end : fix for bug 8507709
  -- fix for bug 7004273 and 7201785
  CURSOR c_sd_req_header_rec(p_offer_id IN NUMBER) IS
  SELECT sdr.object_version_number, sdr.request_header_id
  FROM   ozf_sd_request_headers_all_b sdr, ozf_offers off
--WHERE  nvl(sdr.authorization_number,sdr.request_number) = off.offer_code
  WHERE  sdr.request_number = off.offer_code
  AND    off.qp_list_header_id = p_offer_id
  AND    sdr.user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS', 'PENDING_OFFER_APPROVAL');


  l_api_name    CONSTANT VARCHAR2(30) := 'Activate_Offer_Over';
  l_api_version        CONSTANT NUMBER   := 1.0;
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
  --l_offer_rec  modifier_list_rec_type := p_offer_rec;
  l_recal     VARCHAR2(1);
  l_pass_validation_flag VARCHAR2(1);
  l_offer_id  NUMBER;
  x_qualifiers_tbl        qp_qualifier_rules_pub.qualifiers_tbl_type;
  l_start_date_q DATE;
  l_start_date_o DATE;
  l_start_date DATE;
  l_obj_ver_num NUMBER;
  l_sdr_req_header_id NUMBER;
BEGIN
   SAVEPOINT activate_offer_over;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_amount_error := 'N';

  IF p_offer_rec.custom_setup_id = 105 THEN
    OPEN c_offer_id(p_offer_rec.qp_list_header_id);
    FETCH c_offer_id INTO l_offer_id;
    CLOSE c_offer_id;

    IF p_offer_rec.status_code = 'DRAFT' THEN
      l_pass_validation_flag := 'N';
    ELSE
      l_pass_validation_flag := 'Y';
    END IF;

    pv_referral_comp_pub.Update_Referral_Status (p_api_version          => p_api_version,
                                                 p_init_msg_list        => p_init_msg_list,
                                                 p_commit               => p_commit,
                                                 p_validation_level     => FND_API.g_valid_level_full,
                                                 p_offer_id             => l_offer_id,
                                                 p_pass_validation_flag => l_pass_validation_flag,
                                                 x_return_status        => x_return_status,
                                                 x_msg_count            => x_msg_count,
                                                 x_msg_data             => x_msg_data);
  END IF;

  IF p_offer_rec.status_code = 'DRAFT' THEN
    -- CP validation fails. update offer to DRAFT
    UPDATE ozf_offers
    SET    status_code = 'DRAFT'
          ,user_status_id = OZF_Utility_PVT.get_default_user_status ('OZF_OFFER_STATUS', 'DRAFT')
          ,status_date = SYSDATE
          ,object_version_number = object_version_number + 1
    WHERE  qp_list_header_id = p_offer_rec.qp_list_header_id;
  ELSE
    -- validate approved amount vs committed amout and update offer status depending on recal
    -- moved from end
    validate_offer(
        p_init_msg_list    => FND_API.G_FALSE,
        p_api_version     => 1.0,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_offer_rec  =>  p_offer_rec
        );
    l_recal := FND_PROFILE.VALUE('OZF_BUDGET_ADJ_ALLOW_RECAL');
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     --julou amount validation failed, update status depending on recal
      IF p_called_from = 'R' THEN
        IF p_offer_rec.offer_type IN ('LUMPSUM', 'SCAN_DATA') THEN
          UPDATE ozf_offers
          SET    status_code = 'PENDING_ACTIVE',
                 status_date = SYSDATE,
                 object_version_number = object_version_number + 1,
                 user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS',  'PENDING_ACTIVE')
          WHERE  qp_list_header_id = p_offer_rec.qp_list_header_id;
        ELSE
          UPDATE ozf_offers
          SET    status_code = DECODE(l_recal, 'N', 'PENDING_ACTIVE', 'Y', 'DRAFT'),
                 status_date = SYSDATE,
                 object_version_number = object_version_number + 1,
                 user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS',  DECODE(l_recal, 'N', 'PENDING_ACTIVE', 'Y', 'DRAFT'))
          WHERE  qp_list_header_id = p_offer_rec.qp_list_header_id;
        END IF;
      ELSE -- called from B/ set amount error and the caller takes care of status
        x_amount_error := 'Y';
      END IF; -- end called from 'R'

      IF p_offer_rec.custom_setup_id = 110 THEN
        UPDATE ozf_approval_access
        SET    action_code = NULL
             , action_date = NULL
             , action_performed_by = NULL
             , workflow_itemkey = NULL
             , approval_access_flag = 'Y'
             , object_version_number = object_version_number + 1
             , last_update_date = sysdate
             , last_updated_by = FND_GLOBAL.user_id
        WHERE  approval_access_id IN
              (SELECT apr.approval_access_id
               FROM   ozf_approval_access apr
                    , ozf_request_headers_all_b req
                    , jtf_rs_resource_extns jre
               WHERE  req.request_header_id = apr.object_id
               AND    apr.object_id = req.request_header_id
               AND    req.offer_id = p_offer_rec.qp_list_header_id
               AND    req.request_class = 'SOFT_FUND' -- or 'SPECIAL_PRICE'
               AND    req.approved_by = jre.resource_id
               AND    apr.action_performed_by = jre.user_id);
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;-- validation fails, update to DRAFT or PENDING_ACTIVE and return(no posting)

    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      --julou validation passed, update offer to active and posting

      -- Invoke Post_Lumpsum_Offer/Post_Scan_Data_Offer
      -- budget CP does not post lumpsum and scan data. Posting is done here for both R and B
      IF p_offer_rec.offer_type = 'LUMPSUM' THEN
        Post_Lumpsum_Offer(
          p_api_version     => 1.0,
          p_init_msg_list    => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          p_offer_rec  =>  p_offer_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      ELSIF p_offer_rec.offer_type = 'SCAN_DATA' THEN
        Post_Scan_Data_Offer(
          p_api_version     => 1.0,
          p_init_msg_list    => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          p_offer_rec  =>  p_offer_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      OPEN  c_offer_start_date(p_offer_rec.qp_list_header_id);
      FETCH c_offer_start_date INTO l_start_date_q, l_start_date_o;
      CLOSE c_offer_start_date;

      IF l_start_date_o IS NULL THEN
        l_start_date := GREATEST(NVL(l_start_date_q, SYSDATE), SYSDATE);
      ELSE
        l_start_date := l_start_date_o;
      END IF;

      UPDATE ozf_offers
      SET    status_code = 'ACTIVE',
             status_date = SYSDATE,
             object_version_number = object_version_number + 1,
             start_date = l_start_date,
             user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS', 'ACTIVE')
      WHERE  qp_list_header_id = p_offer_rec.qp_list_header_id;

      IF p_offer_rec.custom_setup_id = 110 THEN -- soft fund offers
        -- update ozf_request_headers_all_b update activating
        update_request_status (x_return_status     => x_return_status,
                               x_msg_count         => x_msg_count,
                               x_msg_data          => x_msg_data,
                               p_qp_list_header_id => p_offer_rec.qp_list_header_id);
      END IF;

      ozf_utility_pvt.write_conc_log('p_offer_rec.custom_setup_id '||p_offer_rec.custom_setup_id);
      ozf_utility_pvt.write_conc_log('p_offer_rec.qp_list_header_id '||p_offer_rec.qp_list_header_id);


       IF p_offer_rec.custom_setup_id = 118 THEN -- SD offers
        -- update ozf_sd_request_headers_all_b update activating
        OPEN c_sd_req_header_rec(p_offer_rec.qp_list_header_id);
        FETCH c_sd_req_header_rec INTO l_obj_ver_num , l_sdr_req_header_id;
        CLOSE c_sd_req_header_rec;

        ozf_utility_pvt.write_conc_log('l_obj_ver_num '||l_obj_ver_num);
        ozf_utility_pvt.write_conc_log('l_sdr_req_header_id '|| l_sdr_req_header_id);

        --fix for bug 7004273

          UPDATE ozf_sd_request_headers_all_b
          SET    user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS', 'ACTIVE') ,
          object_version_number = l_obj_ver_num + 1
          WHERE  request_header_id = l_sdr_req_header_id;
      END IF;

      IF p_offer_rec.offer_type NOT IN('LUMPSUM', 'SCAN_DATA', 'NET_ACCRUAL') THEN
        UPDATE qp_list_headers_b
           SET active_flag = 'Y'
         WHERE list_header_id = p_offer_rec.qp_list_header_id;

        UPDATE qp_qualifiers
           SET active_flag='Y'
         WHERE list_header_id = p_offer_rec.qp_list_header_id;
/*
         IF p_offer_rec.offer_type = 'DEAL' THEN
           process_rltd_modifier_qual(
             p_init_msg_list  => p_init_msg_list,
             p_commit         => p_commit,
             p_list_header_id => p_offer_rec.qp_list_header_id,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data);
         END IF;*/
      END IF;

      -- Invoke Push_Target_Group if the offer is re-useable
      -- For Non-Reusable Offers Schedule activation should push the target group.
      IF p_offer_rec.reusable = 'Y' THEN
        Push_Target_group(
          p_api_version      => 1.0,
          p_init_msg_list    => FND_API.G_FALSE,
          p_commit           => FND_API.g_false,
          p_offer_rec        =>  p_offer_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;
  END IF;

debug_message('Calling Process Offer Activation');

-- nepanda : start : fix for bug 8507709 : check if line data is not there in qp_list_lines table already, then only call process_offer_activation
     l_exists_in_qp_list_line := NULL;
     OPEN c_exists_in_qp_list_line(p_offer_rec.qp_list_header_id);
          FETCH c_exists_in_qp_list_line INTO l_exists_in_qp_list_line;
     CLOSE c_exists_in_qp_list_line;

IF l_exists_in_qp_list_line IS NULL THEN
-- nepanda : end : fix for bug 8507709
process_offer_activation
(
    p_api_version_number         => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => p_commit
    , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_offer_rec          => p_offer_rec
);

--          RAISE FND_API.G_EXC_ERROR;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
END IF;

  FND_MSG_PUB.Count_And_Get
       (p_count          =>   x_msg_count,
        p_data           =>   x_msg_data,
        p_encoded        =>   FND_API.G_FALSE
       );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.g_ret_sts_error ;
    ROLLBACK TO activate_offer_over;
    FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      l_msg_count,
           p_data        =>      l_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    ROLLBACK TO activate_offer_over;
    FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      l_msg_count,
           p_data            =>      l_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    ROLLBACK TO activate_offer_over;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      l_msg_count,
         p_data            =>      l_msg_data,
         p_encoded           =>      FND_API.G_FALSE
        );
END Activate_Offer_Over;


PROCEDURE offer_dates(
  p_modifier_list_rec   IN modifier_list_rec_type
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
 )IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'offer_dates';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_qualifier_tbl   qualifiers_tbl_type;
  l_error_location NUMBER := 0;
  i NUMBER := 1;
  l_ord_id NUMBER := 0;
  l_ship_id NUMBER := 0;

  CURSOR c_qualifier_id(l_list_header_id NUMBER) IS
  SELECT qualifier_id , qualifier_context , qualifier_attribute
    FROM qp_qualifiers
   WHERE list_header_id = l_list_header_id
     AND qualifier_context = 'ORDER'
     AND qualifier_attribute in ('QUALIFIER_ATTRIBUTE1','QUALIFIER_ATTRIBUTE8');

    x_qualifiers_tbl        qp_qualifier_rules_pub.qualifiers_tbl_type;

BEGIN

 ----------- initialize -------------
   SAVEPOINT offer_dates;

   x_return_status := Fnd_Api.g_ret_sts_success;

  FOR c1_rec IN c_qualifier_id(p_modifier_list_rec.qp_list_header_id) LOOP
    IF c1_rec.qualifier_attribute = 'QUALIFIER_ATTRIBUTE1'
    THEN l_ord_id := c1_rec.qualifier_id ;
    ELSIF c1_rec.qualifier_attribute = 'QUALIFIER_ATTRIBUTE8'
    THEN l_ship_id := c1_rec.qualifier_id ;
    END IF;
    END LOOP;

/*
   The logic of the operator is as
   if both start date and end date are entered then the operator is 'BETWEEN' else the operator is '='
*/
-- Order Date
        IF (NOT
            (l_ord_id = 0 AND
              (p_modifier_list_rec.start_date_active_first IS NULL OR p_modifier_list_rec.start_date_active_first = Fnd_Api.g_miss_date
              )
              AND
              (p_modifier_list_rec.end_date_active_first IS NULL OR p_modifier_list_rec.end_date_active_first = Fnd_Api.g_miss_date
              )
           )
         )
    THEN
      IF p_modifier_list_rec.start_date_active_first <> fnd_api.g_miss_date THEN
      l_qualifier_tbl(i).qualifier_context   :='ORDER';
      l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE1';
      -- fix for bug # 8717146. Changing qualifier date mask to 24 Hr Format
      l_qualifier_tbl(i).qualifier_attr_value := to_char(p_modifier_list_rec.start_date_active_first,'YYYY/MM/DD HH24:MI:SS');
      l_qualifier_tbl(i).qualifier_attr_value_to := to_char(p_modifier_list_rec.end_date_active_first,'YYYY/MM/DD HH24:MI:SS');
      l_qualifier_tbl(i).comparison_operator_code  := '=';
      IF(p_modifier_list_rec.start_date_active_first IS NOT NULL AND p_modifier_list_rec.end_date_active_first IS NOT NULL ) THEN
      l_qualifier_tbl(i).comparison_operator_code  := 'BETWEEN';
      END IF;

      l_qualifier_tbl(i).qualifier_grouping_no := -100;
-- rssharma Changed Grouping Number from 10 to -1

       IF l_ord_id <> 0 AND (p_modifier_list_rec.start_date_active_first IS NULL AND p_modifier_list_rec.end_date_active_first IS NULL )
       THEN
              l_qualifier_tbl(i).operation :='DELETE';
              l_qualifier_tbl(i).qualifier_id := l_ord_id;
        ELSIF l_ord_id <> 0 THEN
              l_qualifier_tbl(i).operation :='UPDATE';
              l_qualifier_tbl(i).qualifier_id := l_ord_id;
      ELSE
              l_qualifier_tbl(i).operation :='CREATE';
      END IF;
      l_qualifier_tbl(i).list_header_id       := p_modifier_list_rec.qp_list_header_id;
      i := i+1;
      END IF;
-- End Order Date
-- Ship Date
      END IF;

/*
   The logic of the operator is as
   if both start date and end date are entered then the operator is 'BETWEEN' else the operator is '='
*/
      IF (
        NOT(
            l_ship_id = 0
            AND
            (p_modifier_list_rec.start_date_active_second IS NULL OR p_modifier_list_rec.start_date_active_second = Fnd_Api.g_miss_date )
            AND
            (p_modifier_list_rec.end_date_active_second IS NULL OR p_modifier_list_rec.end_date_active_second = Fnd_Api.g_miss_date )
           )
         ) THEN
         IF p_modifier_list_rec.start_date_active_second <> fnd_api.g_miss_date THEN
      l_qualifier_tbl(i).qualifier_context   :='ORDER';
      l_qualifier_tbl(i).qualifier_attribute := 'QUALIFIER_ATTRIBUTE8';
      -- fix for bug # 8717146. Changing qualifier date mask to 24 Hr Format
      l_qualifier_tbl(i).qualifier_attr_value := to_char(p_modifier_list_rec.start_date_active_second,'YYYY/MM/DD HH24:MI:SS');
      l_qualifier_tbl(i).qualifier_attr_value_to := to_char(p_modifier_list_rec.end_date_active_second,'YYYY/MM/DD HH24:MI:SS');
      l_qualifier_tbl(i).comparison_operator_code  := '=';
      IF(p_modifier_list_rec.start_date_active_second IS NOT NULL AND p_modifier_list_rec.end_date_active_second IS NOT NULL ) THEN
      l_qualifier_tbl(i).comparison_operator_code  := 'BETWEEN';
      END IF;
      l_qualifier_tbl(i).qualifier_grouping_no := -200;
-- rssharma Changed grouping Number to -1 from 10

     IF l_ship_id <> 0 AND (p_modifier_list_rec.start_date_active_second IS NULL AND p_modifier_list_rec.end_date_active_second is NULL)
      THEN
              l_qualifier_tbl(i).operation :='DELETE';
              l_qualifier_tbl(i).qualifier_id := l_ship_id;
      ELSIF l_ship_id <> 0 THEN
              l_qualifier_tbl(i).operation :='UPDATE';
              l_qualifier_tbl(i).qualifier_id := l_ship_id;
      ELSE
              l_qualifier_tbl(i).operation :='CREATE';
      END IF;

      l_qualifier_tbl(i).list_header_id       := p_modifier_list_rec.qp_list_header_id;
      i := i+1;
      END IF;

    END IF;
-- End Ship date

   process_market_qualifiers
   (
       p_api_version       => 1.0,
       p_init_msg_list     => Fnd_Api.g_false,
       p_commit            => Fnd_Api.g_false,
       x_return_status     => x_return_status ,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,
       p_qualifiers_tbl    => l_qualifier_tbl,
       x_error_location    => l_error_location,
       x_qualifiers_tbl    => x_qualifiers_tbl
    );
   IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
     RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

      Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO offer_dates;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO offer_dates;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO offer_dates;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END offer_dates;



PROCEDURE process_qp_list_header(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_list_rec     IN   modifier_list_rec_type
  ,x_modifier_list_rec     OUT NOCOPY  modifier_list_rec_type
  ,p_old_status_id          IN  NUMBER
  ,p_approval_type          IN  VARCHAR2
  ,p_new_status_code        IN  VARCHAR2
) IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'process_qp_list_header';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_modifier_list_rec      Qp_Modifiers_Pub.modifier_list_rec_type;
   v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;

   v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
   v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
   v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
   v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
   v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;

   l_limits_rec                    QP_Limits_PUB.Limits_Rec_Type;
   temp_limits_rec                 QP_Limits_PUB.Limits_Rec_Type;
   v_limits_rec                    QP_Limits_PUB.Limits_Rec_Type;
   v_limits_val_rec                QP_Limits_PUB.Limits_Val_Rec_Type;
   v_limit_attrs_tbl               QP_Limits_PUB.Limit_Attrs_Tbl_Type;
   v_limit_attrs_val_tbl           QP_Limits_PUB.Limit_Attrs_Val_Tbl_Type;
   v_limit_balances_tbl            QP_Limits_PUB.Limit_Balances_Tbl_Type;
   v_limit_balances_val_tbl        QP_Limits_PUB.Limit_Balances_Val_Tbl_Type;

   l_uk_flag                VARCHAR2(1);

--nepanda : fix for bug 9149865
   CURSOR c_check_uniqeness_create
   IS
   SELECT 1 from AMS_SOURCE_CODES
   WHERE source_code = p_modifier_list_rec.offer_code;

BEGIN
    SAVEPOINT process_qp_list_header;
--dbms_output.put_line('calling qp procedure');

    x_return_status := Fnd_Api.g_ret_sts_success;


   l_modifier_list_rec.operation          := p_modifier_list_rec.modifier_operation;
   l_modifier_list_rec.list_header_id     := p_modifier_list_rec.qp_list_header_id ;
   l_modifier_list_rec.list_type_code     := 'PRO';
   l_modifier_list_rec.source_system_code := FND_PROFILE.VALUE('QP_SOURCE_SYSTEM_CODE');
   l_modifier_list_rec.description        := p_modifier_list_rec.description;
   l_modifier_list_rec.comments           := p_modifier_list_rec.comments;
   l_modifier_list_rec.currency_code      := p_modifier_list_rec.currency_code;
   l_modifier_list_rec.start_date_active  := trunc(p_modifier_list_rec.start_date_active);
   l_modifier_list_rec.end_date_active    := trunc(p_modifier_list_rec.end_date_active);
   l_modifier_list_rec.automatic_flag     := 'Y';
-- 15-Nov-2002  rssharma added FlexFields
   l_modifier_list_rec.ask_for_flag       := p_modifier_list_rec.ask_for_flag;
   l_modifier_list_rec.attribute1        := p_modifier_list_rec.attribute1;
   l_modifier_list_rec.attribute2        := p_modifier_list_rec.attribute2;
   l_modifier_list_rec.attribute3        := p_modifier_list_rec.attribute3;
   l_modifier_list_rec.attribute4        := p_modifier_list_rec.attribute4;
   l_modifier_list_rec.attribute5        := p_modifier_list_rec.attribute5;
   l_modifier_list_rec.attribute6        := p_modifier_list_rec.attribute6;
   l_modifier_list_rec.attribute7        := p_modifier_list_rec.attribute7;
   l_modifier_list_rec.attribute8        := p_modifier_list_rec.attribute8;
   l_modifier_list_rec.attribute9        := p_modifier_list_rec.attribute9;
   l_modifier_list_rec.attribute10       := p_modifier_list_rec.attribute10;
   l_modifier_list_rec.attribute11       := p_modifier_list_rec.attribute11;
   l_modifier_list_rec.attribute12       := p_modifier_list_rec.attribute12;
   l_modifier_list_rec.attribute13       := p_modifier_list_rec.attribute13;
   l_modifier_list_rec.attribute14       := p_modifier_list_rec.attribute14;
   l_modifier_list_rec.attribute15       := p_modifier_list_rec.attribute15;
   l_modifier_list_rec.context       := p_modifier_list_rec.context;
   l_modifier_list_rec.global_flag       := p_modifier_list_rec.global_flag;
   l_modifier_list_rec.org_id            := p_modifier_list_rec.orig_org_id;

-- end change 15-Nov-2002
   IF p_modifier_list_rec.offer_code <> Fnd_Api.g_miss_char  THEN
     l_modifier_list_rec.name             := p_modifier_list_rec.offer_code;
   END IF;

  IF p_modifier_list_rec.offer_operation IS NOT NULL AND p_modifier_list_rec.offer_operation <> FND_API.G_MISS_CHAR THEN
    IF p_modifier_list_rec.modifier_operation = 'CREATE' THEN
      l_modifier_list_rec.active_flag     := 'N';
    ELSIF p_modifier_list_rec.modifier_operation = 'UPDATE' THEN
      IF (p_modifier_list_rec.user_status_id <> FND_API.g_miss_num)
      AND (p_modifier_list_rec.user_status_id <> p_old_status_id) THEN
      --nepanda : fix for bug 8507709 : call process_offer_activation only when status is changing from DRAFT to ACTIVE (in order to prevent populating qp_list_lines table in case of ON-HOLD to ACTIVE
        IF p_new_status_code = 'ACTIVE' THEN
          IF p_approval_type is NULL AND p_modifier_list_rec.offer_type NOT IN ('LUMPSUM', 'SCAN_DATA') THEN
            l_modifier_list_rec.active_flag     := 'Y';
	    IF ozf_utility_pvt.get_system_status_code(p_old_status_id) = 'DRAFT' THEN
		debug_message('Calling activate');
            process_offer_activation
            (
                p_api_version_number         => p_api_version
                , p_init_msg_list              => p_init_msg_list
                , p_commit                     => FND_API.g_false
                , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                , x_return_status              => x_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_offer_rec                  => p_modifier_list_rec
            );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
		END IF;
          END IF;
        ELSE
          l_modifier_list_rec.active_flag     := 'N';
        END IF;
      END IF;
    END IF;
  ELSE
    IF p_modifier_list_rec.active_flag = FND_API.G_MISS_CHAR OR p_modifier_list_rec.active_flag IS NULL THEN
      l_modifier_list_rec.active_flag := 'N';
    ELSE
      l_modifier_list_rec.active_flag := p_modifier_list_rec.active_flag;
    END IF;
  END IF;

   IF p_modifier_list_rec.start_date_active_first <> Fnd_Api.g_miss_date OR  p_modifier_list_rec.end_date_active_first <> Fnd_Api.g_miss_date THEN
     l_modifier_list_rec.active_date_first_type   := 'ORD';
   END IF;

   IF p_modifier_list_rec.start_date_active_second <> Fnd_Api.g_miss_date OR  p_modifier_list_rec.end_date_active_second <> Fnd_Api.g_miss_date THEN
     l_modifier_list_rec.active_date_second_type  := 'SHIP';
   END IF;

   IF p_modifier_list_rec.start_date_active_second IS NULL AND  p_modifier_list_rec.end_date_active_second IS NULL THEN
     l_modifier_list_rec.active_date_second_type  := NULL;
   END IF;

   IF p_modifier_list_rec.start_date_active_first IS NULL AND  p_modifier_list_rec.end_date_active_first IS NULL THEN
     l_modifier_list_rec.active_date_first_type  := NULL;
   END IF;

   l_modifier_list_rec.start_date_active_first  := p_modifier_list_rec.start_date_active_first;
   l_modifier_list_rec.end_date_active_first    := p_modifier_list_rec.end_date_active_first;

   l_modifier_list_rec.start_date_active_second := p_modifier_list_rec.start_date_active_second;
   l_modifier_list_rec.end_date_active_second   := p_modifier_list_rec.end_date_active_second;

   IF p_modifier_list_rec.modifier_operation = 'CREATE' THEN
     IF p_modifier_list_rec.offer_code = Fnd_Api.g_miss_char or p_modifier_list_rec.offer_code IS NULL THEN
        l_modifier_list_rec.name := Ams_Sourcecode_Pvt.get_new_source_code (
                   p_object_type => 'OFFR',
                   p_custsetup_id => p_modifier_list_rec.custom_setup_id,
                   p_global_flag   => Fnd_Api.g_false
               );
     ELSE
        l_modifier_list_rec.name        := p_modifier_list_rec.offer_code;
	--nepanda : fix for bug 9149865
        --l_uk_flag := OZF_Utility_PVT.check_uniqueness('AMS_SOURCE_CODES','source_code =   ''' || p_modifier_list_rec.offer_code || '''');

	OPEN c_check_uniqeness_create;
		FETCH c_check_uniqeness_create INTO l_uk_flag;
        CLOSE c_check_uniqeness_create;


       IF l_uk_flag = 1 THEN --Fnd_Api.g_false THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.set_name('OZF', 'OZF_ACT_OFFER_DUP_OFFER_CODE');
          Fnd_Msg_Pub.ADD;
         END IF;
       END IF;
     END IF;
   END IF;

/**
In case of lumpsum and scandata Offers the OrgID field appears in the UI, irrespective of the security profile since
they are always local. The org_id is actually stored in ozf_offers, in this case.
This code only makes sure that if the profile is OFF then the global flag is Y., to get rid of qp_list_header creation errors
*/
   IF NVL(fnd_profile.value('QP_SECURITY_CONTROL'), 'OFF') = 'OFF' THEN
        l_modifier_list_rec.global_flag := 'Y';
        l_modifier_list_rec.org_id      := NULL;
  END IF;

--dbms_output.put_line('calling qp procedure');
      Qp_Modifiers_Pub.process_modifiers(
        p_api_version_number    => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_return_values         => Fnd_Api.G_FALSE,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_modifier_list_rec     => l_modifier_list_rec,
        x_modifier_list_rec     => v_modifier_list_rec,
        x_modifier_list_val_rec => v_modifier_list_val_rec,
        x_modifiers_tbl         => v_modifiers_tbl,
        x_modifiers_val_tbl     => v_modifiers_val_tbl,
        x_qualifiers_tbl        => v_qualifiers_tbl,
        x_qualifiers_val_tbl    => v_qualifiers_val_tbl,
        x_pricing_attr_tbl      => v_pricing_attr_tbl,
        x_pricing_attr_val_tbl  => v_pricing_attr_val_tbl
       );

--dbms_output.put_line('Return status1 is :'||x_return_status);
 IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;
  x_modifier_list_rec.qp_list_header_id := v_modifier_list_rec.list_header_id;
  x_modifier_list_rec.name              := v_modifier_list_rec.name;



-- Start of Offers Limit functionality.  Need to set INSERT, UPDATE and DELETE for limits
-- if profile OZF_BUDGET_ADJ_ALLOW_RECAL is 'Y' AND CommittedAmountEqMax flag is Y OR profile OZF_BUDGET_ADJ_ALLOW_RECAL is 'N'
/*
IF (p_modifier_list_rec.offer_amount <> fnd_api.g_miss_num
    AND p_modifier_list_rec.offer_amount is not null
   )
OR (--p_modifier_list_rec.amount_limit_id = fnd_api.g_miss_num
    AND p_modifier_list_rec.offer_amount <> fnd_api.g_miss_num
    AND p_modifier_list_rec.offer_amount is not null
    )
THEN
*/
--RSSHARMA Commented out the above if as if clashes with the if for delete operation ..
--this introduced a bug due to which the limit will neve be deleted as this if clashed with the if for delete
   IF p_modifier_list_rec.modifier_operation IN ('UPDATE','DELETE') THEN
      l_limits_rec.list_header_id   := p_modifier_list_rec.qp_list_header_id;
   ELSIF p_modifier_list_rec.modifier_operation = 'CREATE' THEN
      l_limits_rec.list_header_id   := v_modifier_list_rec.list_header_id;
   END IF;

IF   p_modifier_list_rec.amount_limit_id = fnd_api.g_miss_num
 AND p_modifier_list_rec.offer_amount <> fnd_api.g_miss_num
 AND p_modifier_list_rec.offer_amount is not null THEN
 IF ( p_modifier_list_rec.committed_amount_eq_max = 'Y')-- deal in limits only if the recal profile is off or the profile is on and the flag is Yes
THEN
   l_limits_rec.operation                 := 'CREATE';
   l_limits_rec.basis                     := 'COST'    ;
   --- When OM starts supporting HARD Need to change it to HARD.
   --l_limits_rec.limit_exceed_action_code  := 'SOFT'   ;
   l_limits_rec.limit_hold_flag           := 'Y'   ;
   l_limits_rec.limit_id                  := fnd_api.g_miss_num;
   l_limits_rec.limit_level_code          :='ACROSS_TRANSACTION';
   l_limits_rec.limit_number              := 1;
   l_limits_rec.organization_flag         := 'N'  ;
   l_limits_rec.amount                    := p_modifier_list_rec.offer_amount;
END IF;
ELSIF (p_modifier_list_rec.amount_limit_id <> fnd_api.g_miss_num AND p_modifier_list_rec.amount_limit_id IS NOT NULL) THEN
  IF p_modifier_list_rec.offer_amount IS NULL OR -- if committed=max is no or Committed Amount is null delete the limit
  (p_modifier_list_rec.committed_amount_eq_max = 'N')
  THEN
    l_limits_rec.operation          := 'DELETE';
    l_limits_rec.limit_id           := p_modifier_list_rec.amount_limit_id;
  ELSIF  p_modifier_list_rec.offer_amount IS NOT NULL THEN
IF (p_modifier_list_rec.committed_amount_eq_max = 'Y' )
THEN
    l_limits_rec.operation          :=  'UPDATE';
    l_limits_rec.limit_id           :=  p_modifier_list_rec.amount_limit_id;
    l_limits_rec.amount             :=  p_modifier_list_rec.offer_amount;
    END IF;
  END IF;
END IF;


 QP_Limits_PUB.Process_Limits
( p_init_msg_list           =>  FND_API.g_true,
  p_api_version_number      =>  1.0,
  p_commit                  =>  FND_API.g_false,
  x_return_status           =>  x_return_status,
  x_msg_count               =>  x_msg_count,
  x_msg_data                =>  x_msg_data,
  p_LIMITS_rec              =>  l_limits_rec,
  x_LIMITS_rec              =>  v_LIMITS_rec,
  x_LIMITS_val_rec          =>  v_LIMITS_val_rec,
  x_LIMIT_ATTRS_tbl         =>  v_LIMIT_ATTRS_tbl,
  x_LIMIT_ATTRS_val_tbl     =>  v_LIMIT_ATTRS_val_tbl,
  x_LIMIT_BALANCES_tbl      =>  v_LIMIT_BALANCES_tbl,
  x_LIMIT_BALANCES_val_tbl  =>  v_LIMIT_BALANCES_val_tbl
);


--    RAISE Fnd_Api.g_exc_error;
 IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;

--END IF;
--END IF; -- END OZF_BUDGET_ADJ_ALLOW_RECAL profile if
l_limits_rec := temp_limits_rec;

IF (p_modifier_list_rec.max_no_of_uses <> fnd_api.g_miss_num
    AND p_modifier_list_rec.max_no_of_uses is not null
   )
OR (p_modifier_list_rec.uses_limit_id = fnd_api.g_miss_num
    AND p_modifier_list_rec.max_no_of_uses <> fnd_api.g_miss_num
    AND p_modifier_list_rec.max_no_of_uses is not null
    )
THEN

   IF p_modifier_list_rec.modifier_operation IN ('UPDATE','DELETE') THEN
      l_limits_rec.list_header_id   := p_modifier_list_rec.qp_list_header_id;
   ELSIF p_modifier_list_rec.modifier_operation = 'CREATE' THEN
      l_limits_rec.list_header_id   := v_modifier_list_rec.list_header_id;
   END IF;

IF   p_modifier_list_rec.uses_limit_id = fnd_api.g_miss_num
 AND p_modifier_list_rec.max_no_of_uses <> fnd_api.g_miss_num
 AND p_modifier_list_rec.max_no_of_uses is not null THEN
   l_limits_rec.operation                 := 'CREATE';
   l_limits_rec.basis                     := 'USAGE'    ;
   --- When OM starts supporting HARD Need to change it to HARD.
   --l_limits_rec.limit_exceed_action_code  := 'SOFT'   ;
   l_limits_rec.limit_hold_flag           := 'Y'   ;
   l_limits_rec.limit_id                  := fnd_api.g_miss_num;
   l_limits_rec.limit_level_code          :='ACROSS_TRANSACTION';
   l_limits_rec.limit_number              := 1;
   l_limits_rec.organization_flag         := 'N'  ;
   l_limits_rec.amount                    := p_modifier_list_rec.max_no_of_uses;
   l_limits_rec.multival_attr1_type       := 'QUALIFIER';
   l_limits_rec.multival_attr1_context    := 'CUSTOMER';
   l_limits_rec.multival_attribute1       := 'QUALIFIER_ATTRIBUTE2';

ELSIF (p_modifier_list_rec.uses_limit_id <> fnd_api.g_miss_num AND p_modifier_list_rec.uses_limit_id IS NOT NULL) THEN
  IF p_modifier_list_rec.max_no_of_uses IS NULL THEN
    l_limits_rec.operation          := 'DELETE';
    l_limits_rec.limit_id           := p_modifier_list_rec.uses_limit_id;
  ELSIF  p_modifier_list_rec.max_no_of_uses IS NOT NULL THEN
    l_limits_rec.operation          :=  'UPDATE';
    l_limits_rec.limit_id           :=  p_modifier_list_rec.uses_limit_id;
    l_limits_rec.amount             :=  p_modifier_list_rec.max_no_of_uses;
  END IF;
END IF;

 QP_Limits_PUB.Process_Limits
( p_init_msg_list           =>  FND_API.g_true,
  p_api_version_number      =>  1.0,
  p_commit                  =>  FND_API.g_false,
  x_return_status           =>  x_return_status,
  x_msg_count               =>  x_msg_count,
  x_msg_data                =>  x_msg_data,
  p_LIMITS_rec              =>  l_limits_rec,
  x_LIMITS_rec              =>  v_LIMITS_rec,
  x_LIMITS_val_rec          =>  v_LIMITS_val_rec,
  x_LIMIT_ATTRS_tbl         =>  v_LIMIT_ATTRS_tbl,
  x_LIMIT_ATTRS_val_tbl     =>  v_LIMIT_ATTRS_val_tbl,
  x_LIMIT_BALANCES_tbl      =>  v_LIMIT_BALANCES_tbl,
  x_LIMIT_BALANCES_val_tbl  =>  v_LIMIT_BALANCES_val_tbl
);


 IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;

END IF;

    Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO process_qp_list_header;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO process_qp_list_header;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO process_qp_list_header;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;

PROCEDURE validateOzfOffer
(
  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_list_rec     IN   modifier_list_rec_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF (p_modifier_list_rec.offer_type = 'LUMPSUM' OR p_modifier_list_rec.offer_type = 'SCAN_DATA' ) THEN
    IF p_modifier_list_rec.offer_operation = 'CREATE' THEN
        IF (p_modifier_list_rec.currency_code IS NULL OR p_modifier_list_rec.currency_code = FND_API.G_MISS_CHAR) THEN
             OZF_Utility_PVT.error_message('OZF_OFFR_LS_SD_CURR_REQD');
             x_return_status := Fnd_Api.g_ret_sts_error;
             RETURN;
        END IF;
    ELSIF p_modifier_list_rec.offer_operation = 'UPDATE' THEN
        IF (p_modifier_list_rec.currency_code IS NULL) THEN
             OZF_Utility_PVT.error_message('OZF_OFFR_LS_SD_CURR_REQD');
             x_return_status := Fnd_Api.g_ret_sts_error;
             RETURN;
        END IF;
    END IF;
END IF;
END validateOzfOffer;

PROCEDURE process_ozf_offer(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_list_rec     IN   modifier_list_rec_type
  ,x_offer_id              OUT NOCOPY  NUMBER
 )
 IS
   CURSOR c_scan_value IS
   SELECT NVL(SUM(scan_value * scan_unit_forecast/quantity),0)
     FROM ams_act_products
    WHERE arc_act_product_used_by = 'OFFR'
      AND act_product_used_by_id = p_modifier_list_rec.qp_list_header_id;

  CURSOR c_old_status IS
  SELECT status_code
    FROM ozf_offers
   WHERE qp_list_header_id = p_modifier_list_rec.qp_list_header_id;

   l_promotional_offers_rec  OZF_Promotional_Offers_Pvt.offers_rec_Type;
   l_object_version_number  NUMBER;
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'process_ozf_offer';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_offer_id    NUMBER;
   l_scan_value  NUMBER;
--   l_status_code VARCHAR2(30);
   l_old_status  VARCHAR2(30);

BEGIN
    SAVEPOINT process_ozf_offer;

    x_return_status := Fnd_Api.g_ret_sts_success;

validateOzfOffer
(
  x_return_status         => x_return_status
  ,x_msg_count            => x_msg_count
  ,x_msg_data             => x_msg_data
  ,p_modifier_list_rec    => p_modifier_list_rec
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   OPEN c_scan_value;
   FETCH c_scan_value INTO l_scan_value;
   CLOSE c_scan_value;

   OPEN c_old_status;
   FETCH c_old_status INTO l_old_status;
   CLOSE c_old_status;
   -- if DRAFT sync IEB and committed amount
   IF l_old_status = 'DRAFT' THEN
     IF p_modifier_list_rec.offer_type = 'SCAN_DATA' THEN
       IF p_modifier_list_rec.offer_amount IS NOT NULL
       AND p_modifier_list_rec.offer_amount <> FND_API.G_MISS_NUM THEN -- called by budget cue card
         IF p_modifier_list_rec.budget_amount_tc IS NOT NULL
         AND p_modifier_list_rec.budget_amount_tc <> FND_API.G_MISS_NUM THEN
           IF p_modifier_list_rec.budget_amount_tc >= l_scan_value THEN
             l_promotional_offers_rec.budget_amount_tc := p_modifier_list_rec.budget_amount_tc;
           ELSE
             FND_MESSAGE.SET_NAME('OZF','OZF_OFFR_IEB_LT_SCANVALUE');
             Fnd_Msg_Pub.ADD;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
       ELSE -- called by offer detail
         --IF p_modifier_list_rec.budget_amount_tc IS NOT NULL
         --AND p_modifier_list_rec.budget_amount_tc <> FND_API.G_MISS_NUM THEN
           l_promotional_offers_rec.budget_amount_tc := p_modifier_list_rec.budget_amount_tc;
         --ELSE
         --  l_promotional_offers_rec.budget_amount_tc := 0;
         --END IF;
       END IF;
       l_promotional_offers_rec.offer_amount := NULL;
     ELSE
       IF p_modifier_list_rec.offer_amount IS NOT NULL
       AND p_modifier_list_rec.offer_amount <> FND_API.G_MISS_NUM
       THEN -- from detail, sync ieb with committed amount
         l_promotional_offers_rec.budget_amount_tc := p_modifier_list_rec.offer_amount;
         l_promotional_offers_rec.offer_amount := p_modifier_list_rec.offer_amount;
       ELSIF p_modifier_list_rec.budget_amount_tc IS NOT NULL
       AND p_modifier_list_rec.budget_amount_tc <> FND_API.G_MISS_NUM
       THEN -- from budget cue card, sync committed with ieb
         l_promotional_offers_rec.offer_amount := p_modifier_list_rec.budget_amount_tc;
         l_promotional_offers_rec.budget_amount_tc := p_modifier_list_rec.budget_amount_tc;
       END IF; -- both are no value, do nothing
     END IF;
   ELSE -- active, pending active etc, do not sync
     l_promotional_offers_rec.offer_amount := p_modifier_list_rec.offer_amount;
     l_promotional_offers_rec.budget_amount_tc := p_modifier_list_rec.budget_amount_tc;
   END IF;

   IF l_promotional_offers_rec.budget_amount_tc < 0 THEN
     FND_MESSAGE.SET_NAME('OZF','OZF_OFFR_IEB_NEG');
     Fnd_Msg_Pub.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_promotional_offers_rec.qp_list_header_id        := p_modifier_list_rec.qp_list_header_id;
   l_promotional_offers_rec.custom_setup_id             := p_modifier_list_rec.custom_setup_id;
   l_promotional_offers_rec.retroactive                 := p_modifier_list_rec.retroactive;
   l_promotional_offers_rec.volume_offer_type           := p_modifier_list_rec.volume_offer_type;
   l_promotional_offers_rec.confidential_flag           := p_modifier_list_rec.confidential_flag;
   l_promotional_offers_rec.budget_source_type          := p_modifier_list_rec.budget_source_type;
   l_promotional_offers_rec.budget_source_id            := p_modifier_list_rec.budget_source_id;
   l_promotional_offers_rec.source_from_parent          := p_modifier_list_rec.source_from_parent;
   IF l_promotional_offers_rec.source_from_parent = 'Y' THEN
     l_promotional_offers_rec.budget_source_id := p_modifier_list_rec.offer_used_by_id;
     l_promotional_offers_rec.budget_source_type := 'CAMP';
   END IF;
-- Right now Budget only support sourcing from the Parent Campaign
--   IF l_promotional_offers_rec.budget_source_type = 'CAMP' THEN
--   l_promotional_offers_rec.source_from_parent          := 'Y';
--   END IF;
   l_promotional_offers_rec.buyer_name                  := p_modifier_list_rec.buyer_name;
  IF p_modifier_list_rec.offer_operation = 'CREATE' THEN
   l_promotional_offers_rec.qp_list_header_id           := p_modifier_list_rec.qp_list_header_id;
   l_promotional_offers_rec.offer_code                  := p_modifier_list_rec.offer_code;
   l_promotional_offers_rec.custom_setup_id             := p_modifier_list_rec.custom_setup_id;
   l_promotional_offers_rec.order_value_discount_type   := p_modifier_list_rec.order_value_discount_type;
   l_promotional_offers_rec.budget_offer_yn             := p_modifier_list_rec.budget_offer_yn;

  END IF;

   IF   p_modifier_list_rec.budget_source_id <> Fnd_Api.g_miss_num
   AND  p_modifier_list_rec.budget_source_id IS NOT NULL THEN
     IF p_modifier_list_rec.offer_type <> 'SCAN_DATA' THEN
       l_promotional_offers_rec.budget_amount_tc             := p_modifier_list_rec.offer_amount;
     END IF;
   END IF;

   l_promotional_offers_rec.qualifier_type              := p_modifier_list_rec.ql_qualifier_type;
   l_promotional_offers_rec.qualifier_id                := p_modifier_list_rec.ql_qualifier_id;
   l_promotional_offers_rec.activity_media_id            := p_modifier_list_rec.activity_media_id;
   l_promotional_offers_rec.user_status_id               := p_modifier_list_rec.user_status_id;
-- if the user_status_id is missing then make status_code code also missing
   IF l_promotional_offers_rec.user_status_id = FND_API.g_miss_num THEN
      l_promotional_offers_rec.status_code                  := FND_API.g_miss_char;
   ELSIF l_promotional_offers_rec.user_status_id IS NULL THEN
      l_promotional_offers_rec.status_code                  := NULL;
   ELSE
      l_promotional_offers_rec.status_code                  := OZF_Utility_PVT.get_system_status_code(p_modifier_list_rec.user_status_id);
   END IF;

   l_promotional_offers_rec.reusable                     := nvl(p_modifier_list_rec.reusable,'N');
   l_promotional_offers_rec.owner_id                     := p_modifier_list_rec.owner_id;
   l_promotional_offers_rec.wf_item_key                  := p_modifier_list_rec.wf_item_key;
   l_promotional_offers_rec.object_version_number        := p_modifier_list_rec.object_version_number;
   l_promotional_offers_rec.offer_id                     := p_modifier_list_rec.offer_id;
   l_promotional_offers_rec.offer_type                   := p_modifier_list_rec.offer_type;
   l_promotional_offers_rec.perf_date_from               := p_modifier_list_rec.perf_date_from;
   l_promotional_offers_rec.perf_date_to                 := p_modifier_list_rec.perf_date_to;
   l_promotional_offers_rec.modifier_level_code          := p_modifier_list_rec.modifier_level_code;
   l_promotional_offers_rec.lumpsum_amount               := p_modifier_list_rec.lumpsum_amount;
   l_promotional_offers_rec.lumpsum_payment_type         := p_modifier_list_rec.lumpsum_payment_type;
   l_promotional_offers_rec.customer_reference           := p_modifier_list_rec.customer_reference;
   l_promotional_offers_rec.buying_group_contact_id      := p_modifier_list_rec.buying_group_contact_id;

   IF p_modifier_list_rec.lumpsum_amount is not null AND
        p_modifier_list_rec.lumpsum_amount <> FND_API.g_miss_num THEN
     l_promotional_offers_rec.offer_amount               := p_modifier_list_rec.lumpsum_amount;
   END IF;

   l_promotional_offers_rec.budget_amount_fc             := p_modifier_list_rec.budget_amount_fc;
   l_promotional_offers_rec.transaction_currency_code    := p_modifier_list_rec.currency_code;
   l_promotional_offers_rec.functional_currency_code     := p_modifier_list_rec.functional_currency_code;
   l_promotional_offers_rec.distribution_type            := p_modifier_list_rec.distribution_type;
   l_promotional_offers_rec.break_type                   := p_modifier_list_rec.break_type;
   l_promotional_offers_rec.tier_level                   := p_modifier_list_rec.tier_level;
   l_promotional_offers_rec.na_rule_header_id            := p_modifier_list_rec.na_rule_header_id;
   l_promotional_offers_rec.sales_method_flag            := p_modifier_list_rec.sales_method_flag;
   l_promotional_offers_rec.org_id                       := p_modifier_list_rec.orig_org_id;
--   l_promotional_offers_rec.na_qual_context              := p_modifier_list_rec.na_qual_context;
--   l_promotional_offers_rec.na_qual_attr                 := p_modifier_list_rec.na_qual_attr;
--   l_promotional_offers_rec.na_qual_attr_value           := p_modifier_list_rec.na_qual_attr_value;


   IF p_modifier_list_rec.offer_operation = 'CREATE' THEN
     OZF_Promotional_Offers_Pvt.CREATE_OFFERS
      (
        p_api_version_number => 1.0,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_offers_rec         => l_promotional_offers_rec,
        x_offer_id           => x_offer_id
      );
   ELSIF p_modifier_list_rec.offer_operation = 'UPDATE' THEN

      OZF_Promotional_Offers_Pvt.UPDATE_OFFERS
      (
        p_api_version_number    => 1.0,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_offers_rec            => l_promotional_offers_rec,
        x_object_version_number => l_object_version_number
      );
      x_offer_id := l_promotional_offers_rec.offer_id;
   ELSIF p_modifier_list_rec.offer_operation = 'DELETE' THEN
     OZF_Promotional_Offers_Pvt.DELETE_OFFERS
      (
        p_api_version_number    => 1.0,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_offer_id              => l_promotional_offers_rec.offer_id,
        p_object_version_number => l_promotional_offers_rec.object_version_number
      );
   END IF;

 IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;

    Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO process_ozf_offer;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO process_ozf_offer;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO process_ozf_offer;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;

--=============================PBH Creation procedures===============================================
FUNCTION getOfferType
(
p_listHeaderId NUMBER
)
RETURN VARCHAR2 IS
CURSOR c_offerType(cp_listHeaderId NUMBER) IS
SELECT offer_type
FROM ozf_offers
WHERE qp_list_header_id = cp_listHeaderId;
l_offerType OZF_OFFERS.offer_type%TYPE;
BEGIN
    OPEN c_offerType(cp_listHeaderId  => p_listHeaderId);
    FETCH c_offerType INTO l_offerType;
        IF c_offerType%NOTFOUND THEN
            l_offerType := NULL;
        END IF;
    CLOSE c_offerType;
    RETURN l_offerType;
END getOfferType;

FUNCTION getDiscountLevel
(
p_listHeaderId IN NUMBER
)
RETURN VARCHAR2 IS
CURSOR c_discountLevel(cp_listHeaderId IN NUMBER) IS
SELECT MODIFIER_LEVEL_CODE
FROM ozf_offers
WHERE qp_list_header_id = cp_listHeaderId;
l_discountlevel OZF_OFFERS.MODIFIER_LEVEL_CODE%TYPE;
BEGIN
    OPEN c_discountLevel(cp_listHeaderId => p_listHeaderId);
    FETCH c_discountLevel INTO l_discountLevel;
        IF c_discountLevel%NOTFOUND THEN
            l_discountLevel := 'LINEGROUP';
        END IF;
    CLOSE c_discountLevel;
    RETURN l_discountLevel;
END getDiscountLevel;

    /*gdeepika - defaulted the princing phase using profiles -bug 5675554*/
FUNCTION getPricingPhase
(
p_listHeaderId IN NUMBER
)
RETURN VARCHAR2 IS
l_pricingPhase NUMBER;
BEGIN
    CASE getDiscountLevel(p_listHeaderId => p_listHeaderId)
        WHEN 'LINEGROUP' THEN
              l_pricingPhase := FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP');
        WHEN 'LINE' THEN
              l_pricingPhase := FND_PROFILE.value('OZF_PRICING_PHASE_LINE');
        WHEN 'ORDER' THEN
              l_pricingPhase := FND_PROFILE.value('OZF_PRICING_PHASE_ORDER');
        ELSE
              l_pricingPhase := FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP');
    END CASE;
    RETURN l_pricingPhase;
END getPricingPhase;

PROCEDURE populateZeroDiscount
    (
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_modifiersTbl            IN OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
    )
    IS
    l_index NUMBER;
    BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_index := x_modifiersTbl.count + 1;
    x_modifiersTbl(l_index).operation              := 'CREATE' ;
    x_modifiersTbl(l_index).list_line_type_code    := 'DIS' ;
    x_modifiersTbl(l_index).list_header_id         := p_modifierLineRec.list_header_id;
    x_modifiersTbl(l_index).arithmetic_operator    := NVL(p_modifierLineRec.arithmetic_operator, '%');
    x_modifiersTbl(l_index).operand                :=  0;
    x_modifiersTbl(l_index).proration_type_code    := 'N';
    x_modifiersTbl(l_index).product_precedence     := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');

    IF getDiscountLevel(p_listHeaderId => p_modifierLineRec.list_header_id) <> 'ORDER' THEN
      x_modifiersTbl(l_index).pricing_group_sequence := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
    END IF;
    x_modifiersTbl(l_index).print_on_invoice_flag  := 'Y';
    x_modifiersTbl(l_index).pricing_phase_id       := getPricingPhase(p_listHeaderId => p_modifierLineRec.list_header_id);
    x_modifiersTbl(l_index).modifier_level_code    := getDiscountLevel(p_listHeaderId => p_modifierLineRec.list_header_id);
    x_modifiersTbl(l_index).modifier_parent_index  := 1;
    x_modifiersTbl(l_index).price_break_type_code  := 'POINT';
    x_modifiersTbl(l_index).automatic_flag         := 'Y';

    x_modifiersTbl(l_index).rltd_modifier_grp_type        := 'PRICE BREAK';
    x_modifiersTbl(l_index).rltd_modifier_grp_no          := 1;
    x_modifiersTbl(l_index).modifier_parent_index         := 1;
    END populateZeroDiscount;

PROCEDURE populateRegularDiscount
    (
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_modifiersTbl            IN OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
    )
IS
l_index NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_index := x_modifiersTbl.count + 1;
    x_modifiersTbl(l_index).operation              := 'CREATE' ;
    x_modifiersTbl(l_index).list_line_type_code    := 'DIS' ;
    x_modifiersTbl(l_index).list_header_id         := p_modifierLineRec.list_header_id;
    x_modifiersTbl(l_index).arithmetic_operator    := NVL(p_modifierLineRec.arithmetic_operator, '%');
    x_modifiersTbl(l_index).operand                := NVL(p_modifierLineRec.operand, 0);
    x_modifiersTbl(l_index).proration_type_code    := 'N';
    x_modifiersTbl(l_index).product_precedence     := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');
    IF getDiscountLevel(p_listHeaderId => p_modifierLineRec.list_header_id) <> 'ORDER' THEN
      x_modifiersTbl(l_index).pricing_group_sequence := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
    END IF;
    x_modifiersTbl(l_index).print_on_invoice_flag  := 'Y';
    x_modifiersTbl(l_index).pricing_phase_id       := getPricingPhase(p_listHeaderId => p_modifierLineRec.list_header_id);
    x_modifiersTbl(l_index).modifier_level_code    := getDiscountLevel(p_listHeaderId => p_modifierLineRec.list_header_id);
    x_modifiersTbl(l_index).modifier_parent_index  := 1;
    x_modifiersTbl(l_index).price_break_type_code  := 'POINT';
    x_modifiersTbl(l_index).automatic_flag         := 'Y';
    x_modifiersTbl(l_index).rltd_modifier_grp_type        := 'PRICE BREAK';
    x_modifiersTbl(l_index).rltd_modifier_grp_no          := 1;
    x_modifiersTbl(l_index).modifier_parent_index         := 1;
END populateRegularDiscount;

PROCEDURE populateDISModifierData
(
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_modifiersTbl            IN OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
)
IS
    l_index NUMBER;
    l_modifierLineRec         MODIFIER_LINE_REC_TYPE;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_index := nvl(x_modifiersTbl.count,0) + 1;
    ozf_utility_pvt.debug_message('After setting index:'||p_modifierLineRec.pricing_attr_value_from);
    l_modifierLineRec := p_modifierLineRec;
    IF p_modifierLineRec.pricing_attr_value_from IS NOT NULL AND p_modifierLineRec.pricing_attr_value_from <> FND_API.G_MISS_CHAR THEN
        l_modifierLineRec.pricing_attr_value_from := 0;
    END IF;
    IF NVL(to_number(l_modifierLineRec.pricing_attr_value_from), 0) > 0 THEN
    ozf_utility_pvt.debug_message('Calling Populate zero discount');
    populateZeroDiscount
    (
        x_return_status             => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
        ,p_modifierLineRec          => l_modifierLineRec
        , x_modifiersTbl            => x_modifiersTbl
    );
    l_index := l_index + 1;
    END IF;

ozf_utility_pvt.debug_message('Calling Populate Regular discount');
populateRegularDiscount
    (
        x_return_status             => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
        ,p_modifierLineRec          => p_modifierLineRec
        , x_modifiersTbl            => x_modifiersTbl
    );
--    END IF;
END populateDISModifierData;

PROCEDURE populateZeroPricingAttr(
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_pricingAttrTbl          IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
l_index NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_index := nvl(x_pricingAttrTbl.count,0) + 1;
    x_pricingAttrTbl(l_index).product_attribute_context  := 'ITEM';
    x_pricingAttrTbl(l_index).product_attribute          := p_modifierLineRec.product_attr;
    x_pricingAttrTbl(l_index).product_attr_value         := p_modifierLineRec.product_attr_val;
    x_pricingAttrTbl(l_index).product_uom_code           := p_modifierLineRec.product_uom_code;
    x_pricingAttrTbl(l_index).pricing_attribute_context  := 'VOLUME';
    x_pricingAttrTbl(l_index).pricing_attribute          := NVL(p_modifierLineRec.pricing_attr,'PRICING_ATTRIBUTE10');
    x_pricingAttrTbl(l_index).pricing_attr_value_from    := 0;--NVL(p_modifier_line_tbl(i).pricing_attr_value_from, 0);
    x_pricingAttrTbl(l_index).pricing_attr_value_to      := NVL(p_modifierLineRec.pricing_attr_value_from, 0);
    x_pricingAttrTbl(l_index).comparison_operator_code   := 'BETWEEN';
    x_pricingAttrTbl(l_index).modifiers_index            := l_index; -- here there is a 1-1 correspondence between modifies and pricing attr, so can use the same index
    x_pricingAttrTbl(l_index).operation                  := 'CREATE';
END populateZeroPricingAttr;


PROCEDURE populateRegularPricingAttr(
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_pricingAttrTbl          IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
l_index NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_index := nvl(x_pricingAttrTbl.count,0) + 1;
    x_pricingAttrTbl(l_index).product_attribute_context  := 'ITEM';
    x_pricingAttrTbl(l_index).product_attribute          := p_modifierLineRec.product_attr;
    x_pricingAttrTbl(l_index).product_attr_value         := p_modifierLineRec.product_attr_val;
    x_pricingAttrTbl(l_index).product_uom_code           := p_modifierLineRec.product_uom_code;
    x_pricingAttrTbl(l_index).pricing_attribute_context  := 'VOLUME';
    --x_pricingAttrTbl(l_index).pricing_attribute          := 'PRICING_ATTRIBUTE10';
    -- fir for bug 7340864
    x_pricingAttrTbl(l_index).pricing_attribute          := NVL(p_modifierLineRec.pricing_attr, 'PRICING_ATTRIBUTE10');
    x_pricingAttrTbl(l_index).pricing_attr_value_from    := NVL(p_modifierLineRec.pricing_attr_value_from, 0);
    x_pricingAttrTbl(l_index).pricing_attr_value_to      := 9999999999;
    x_pricingAttrTbl(l_index).comparison_operator_code   := 'BETWEEN';
    x_pricingAttrTbl(l_index).modifiers_index            := l_index; -- here there is a 1-1 correspondence between modifies and pricing attr, so can use the same index
    x_pricingAttrTbl(l_index).operation                  := 'CREATE';
END populateRegularPricingAttr;

PROCEDURE populateUpdatePricingAttr(
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_pricingAttrTbl          IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
CURSOR c_pricingAttr(cp_listLineId NUMBER) IS
 SELECT pricing_attribute_id FROM qp_pricing_attributes
 WHERE list_line_id = cp_listLineId
 OR list_line_id IN (select to_rltd_modifier_id FROM  qp_rltd_modifiers WHERE from_rltd_modifier_id = cp_listLineId AND rltd_modifier_grp_type = 'PRICE BREAK');
i  NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
i := 1;
FOR l_pricingAttr IN c_pricingAttr(cp_listLineId => p_modifierLineRec.list_line_id) LOOP
    x_pricingAttrTbl(i).pricing_attribute_id       := l_pricingAttr.pricing_attribute_id;
    x_pricingAttrTbl(i).product_attribute_context  := 'ITEM';
    x_pricingAttrTbl(i).product_attribute          := p_modifierLineRec.product_attr;
    x_pricingAttrTbl(i).product_attr_value         := p_modifierLineRec.product_attr_val;
    x_pricingAttrTbl(i).product_uom_code           := p_modifierLineRec.product_uom_code;
    x_pricingAttrTbl(i).pricing_attribute_context  := p_modifierLineRec.pricing_attribute_context;
    x_pricingAttrTbl(i).pricing_attribute          := p_modifierLineRec.pricing_attr;
    x_pricingAttrTbl(i).pricing_attr_value_from    := p_modifierLineRec.pricing_attr_value_from;
    x_pricingAttrTbl(i).pricing_attr_value_to      := p_modifierLineRec.pricing_attr_value_to;
--    x_pricingAttrTbl(i).comparison_operator_code   := 'BETWEEN';
    x_pricingAttrTbl(i).operation                  := p_modifierLineRec.operation;
    i := i + 1;
END LOOP;
END populateUpdatePricingAttr;


/**
Populates CHild DIS Pricing Attributes into QP Record Structures given a single Price Break Header Record
*/
PROCEDURE populateDISPricingAttrData
(
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_pricingAttrTbl          IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
l_index NUMBER;
    l_modifierLineRec         MODIFIER_LINE_REC_TYPE;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_index := x_pricingAttrTbl.count + 1;
    l_modifierLineRec := p_modifierLineRec;
    IF p_modifierLineRec.operation = 'CREATE' THEN
    IF p_modifierLineRec.pricing_attr_value_from IS NOT NULL AND p_modifierLineRec.pricing_attr_value_from <> FND_API.G_MISS_CHAR THEN
        l_modifierLineRec.pricing_attr_value_from := 0;
    END IF;
    IF NVL(to_number(l_modifierLineRec.pricing_attr_value_from), 0) > 0 THEN
        populateZeroPricingAttr
        (
            x_return_status             => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
            ,p_modifierLineRec          => l_modifierLineRec
            , x_pricingAttrTbl            => x_pricingAttrTbl
        );
        l_index := l_index + 1;
        END IF;
        populateRegularPricingAttr
        (
            x_return_status             => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
            ,p_modifierLineRec          => l_modifierLineRec
            , x_pricingAttrTbl            => x_pricingAttrTbl
        );
--    END IF;
    ELSE
         populateUpdatePricingAttr
        (
            x_return_status             => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
            ,p_modifierLineRec          => l_modifierLineRec
            , x_pricingAttrTbl            => x_pricingAttrTbl
        );
    END IF;

END populateDISPricingAttrData;

/**
Populates CHild DIS data  into QP Record Structures given a single Price Break Header Record
*/
PROCEDURE populateDisData
(
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_modifiersTbl            IN OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
        , x_pricingAttrTbl          IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
ozf_utility_pvt.debug_message('Calling populate DIS Modifier Data');
IF p_modifierLineRec.operation = 'CREATE' THEN
    populateDISModifierData
    (
    x_return_status             => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
    ,p_modifierLineRec          => p_modifierLineRec
    , x_modifiersTbl            => x_modifiersTbl
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END IF;
ozf_utility_pvt.debug_message('Calling populate DIS Pricing Attr Data');
populateDISPricingAttrData
(
x_return_status             => x_return_status
,x_msg_count                => x_msg_count
,x_msg_data                 => x_msg_data
,p_modifierLineRec          => p_modifierLineRec
,x_pricingAttrTbl           => x_pricingAttrTbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END populateDisData;


/**
Populates Modifier Information into QP Modifiers Structures given a single Price Break Header Record
*/
PROCEDURE populatePBHModifierData
(
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_modifiersTbl            OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_modifiersTbl(1).operation      := p_modifierLineRec.operation;
    x_modifiersTbl(1).list_header_id := p_modifierLineRec.list_header_id;
    x_modifiersTbl(1).list_line_id   := p_modifierLineRec.list_line_id;
    x_modifiersTbl(1).start_date_active        := p_modifierLineRec.start_date_active;
    x_modifiersTbl(1).end_date_active          := p_modifierLineRec.end_date_active;
    x_modifiersTbl(1).accrual_flag := 'N';
    IF p_modifierLineRec.operation = 'CREATE' THEN
    --    l_child_index := l_child_index + 1;
        x_modifiersTbl(1).list_line_type_code      := 'PBH' ;
        x_modifiersTbl(1).proration_type_code      := 'N';
        x_modifiersTbl(1).product_precedence       := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');
        x_modifiersTbl(1).print_on_invoice_flag    := 'Y';
        x_modifiersTbl(1).pricing_phase_id         := getPricingPhase(p_listHeaderId => p_modifierLineRec.list_header_id);
        x_modifiersTbl(1).modifier_level_code      := getDiscountLevel(p_listHeaderId => p_modifierLineRec.list_header_id);
        x_modifiersTbl(1).price_break_type_code    := 'POINT';
        x_modifiersTbl(1).automatic_flag           := 'Y';
        IF getDiscountLevel(p_listHeaderId => p_modifierLineRec.list_header_id) <> 'ORDER' THEN
          x_modifiersTbl(1).pricing_group_sequence   := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
        END IF;
    end if;
   IF getOfferType(p_listHeaderId => p_modifierLineRec.list_header_id) = 'ACCRUAL' THEN
     x_modifiersTbl(1).accrual_flag := 'Y';
   END IF;


END populatePBHModifierData;

/**
Populates Pricing Attributes into QP Pricing Attribute Structures given a single Price Break Header Record
*/
PROCEDURE populatePBHPricingAttrData
(
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        , x_pricingAttrTbl          OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_pricingAttrTbl(1).product_attribute_context  := 'ITEM';
    x_pricingAttrTbl(1).product_attribute          := p_modifierLineRec.product_attr;
    x_pricingAttrTbl(1).product_attr_value         := p_modifierLineRec.product_attr_val;
    x_pricingAttrTbl(1).product_uom_code           := p_modifierLineRec.product_uom_code;
    x_pricingAttrTbl(1).pricing_attribute_context  := 'VOLUME';
    x_pricingAttrTbl(1).pricing_attribute          := NVL(p_modifierLineRec.pricing_attr, 'PRICING_ATTRIBUTE10');
    x_pricingAttrTbl(1).comparison_operator_code   := 'BETWEEN';
    x_pricingAttrTbl(1).modifiers_index            := 1;
    x_pricingAttrTbl(1).operation                  := p_modifierLineRec.operation;
    x_pricingAttrTbl(1).pricing_attribute_id       := p_modifierLineRec.pricing_attribute_id;
END populatePBHPricingAttrData;

/**
Populates Price Break Header Data Into QP Record structures given a single Price Break Header Record
*/
PROCEDURE populatePbhData
(
        x_return_status             OUT NOCOPY  VARCHAR2
        ,x_msg_count                OUT NOCOPY  NUMBER
        ,x_msg_data                 OUT NOCOPY  VARCHAR2
        ,p_modifierLineRec          IN   MODIFIER_LINE_REC_TYPE
        , x_modifiersTbl            OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
        , x_pricingAttrTbl          OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
BEGIN
-- initialize
-- populate modifers data
-- populate pricing attribute data
x_return_status := FND_API.G_RET_STS_SUCCESS;
populatePBHModifierData
(
x_return_status             => x_return_status
,x_msg_count                => x_msg_count
,x_msg_data                 => x_msg_data
,p_modifierLineRec          => p_modifierLineRec
, x_modifiersTbl            => x_modifiersTbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populatePBHPricingAttrData
(
x_return_status             => x_return_status
,x_msg_count                => x_msg_count
,x_msg_data                 => x_msg_data
,p_modifierLineRec          => p_modifierLineRec
,x_pricingAttrTbl           => x_pricingAttrTbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END populatePbhData;

/**
Creates a PBH line in QP tables given a single PBH line
*/
PROCEDURE processPbhLine
    (
        x_return_status         OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY  NUMBER
        ,x_msg_data              OUT NOCOPY  VARCHAR2
        ,p_offerType               IN VARCHAR2
        ,p_modifierLineRec         IN   MODIFIER_LINE_REC_TYPE
        ,x_modifiersTbl            OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
        -- ,x_error_location        OUT NOCOPY  NUMBER
    )
    IS
    l_modifiersTbl          Qp_Modifiers_Pub.modifiers_tbl_type;
    l_pricingAttrTbl       Qp_Modifiers_Pub.pricing_attr_tbl_type;
    v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
    v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
    v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
    v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
    v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
    v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
    v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
    v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
    l_control_rec            qp_globals.control_rec_type;
    BEGIN
    -- initialize
    -- populate pbh data
    -- populate dis data
    -- process db txn
    -- process errors
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_modifiersTbl.delete;
        l_pricingAttrTbl.delete;
        populatePbhData
        (
        x_return_status         => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
        ,p_modifierLineRec      => p_modifierLineRec
        , x_modifiersTbl        => l_modifiersTbl
        , x_pricingAttrTbl      => l_pricingAttrTbl
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        populateDisData
        (
        x_return_status         => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
        ,p_modifierLineRec      => p_modifierLineRec
        , x_modifiersTbl        => l_modifiersTbl
        , x_pricingAttrTbl      => l_pricingAttrTbl
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   QP_Modifiers_PUB.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifiersTbl,
      p_pricing_attr_tbl       => l_pricingAttrTbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );
     x_modifiersTbl := v_modifiers_tbl;
 IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
    return;
 END IF;
END processPbhLine;

--=============================END PBH Creation procedures============================================

/*
This API will only deal with PBH records.  The tiers fragment will not call this
API.  It will call another API */
--=================================================================================
--  Fixed bug # 4354567. Accept additional OUT NOCOPY parameter to pass back the modifier lines created
--====================================================================================

PROCEDURE process_header_tiers
( x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_offer_type            IN   VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,x_modifiers_tbl         OUT NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
 ,x_error_location        OUT NOCOPY  NUMBER
) IS

 l_api_version CONSTANT NUMBER       := 1.0;
 l_api_name    CONSTANT VARCHAR2(30) := 'process_header_tiers';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;

BEGIN
-- initialize
-- loop thru lines
-- for each pbh create the line in the database
-- handle exception
x_return_status := Fnd_Api.g_ret_sts_success;
IF nvl(p_modifier_line_tbl.count,0) > 0 THEN
FOR i in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
 IF p_modifier_line_tbl.exists(i) THEN
    processPbhLine
    (
        x_return_status             => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
         ,p_offerType               => p_offer_type
         ,p_modifierLineRec         => p_modifier_line_tbl(i)
         ,x_modifiersTbl            => v_modifiers_tbl
        -- ,x_error_location        OUT NOCOPY  NUMBER
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        x_error_location := i;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        x_error_location := i;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END IF;
 IF nvl(v_modifiers_tbl.count,0) > 0 THEN
 FOR i in v_modifiers_tbl.first .. v_modifiers_tbl.last LOOP
    IF v_modifiers_tbl.exists(i) THEN
--        dbms_output.put_line('Adding to :'||nvl(v_modifiers_tbl.count,0) + i);
         x_modifiers_tbl(nvl(x_modifiers_tbl.count,0) + i) := v_modifiers_tbl(i);
    END IF;
 END LOOP;
 END IF;

END LOOP;
END IF;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END;

--nepanda fix for forwardport of bug # 8580281
PROCEDURE checkRequiredItems
(
  x_return_status         OUT NOCOPY VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 ,p_modifier_line_rec     IN   MODIFIER_LINE_REC_TYPE
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_modifier_line_rec.operation = 'CREATE' THEN
        IF (p_modifier_line_rec.product_attr IS NULL OR p_modifier_line_rec.product_attr = FND_API.G_MISS_CHAR)
        THEN
                    FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_LEVEL'));
                    FND_MSG_PUB.Add;
                    x_return_status := FND_API.g_ret_sts_error;
        END IF;
        IF (p_modifier_line_rec.product_attr_val IS NULL OR p_modifier_line_rec.product_attr_val = FND_API.G_MISS_CHAR)
        THEN
            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_NAME'));
            FND_MSG_PUB.Add;
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
        IF (p_modifier_line_rec.list_line_type_code IS NULL OR p_modifier_line_rec.list_line_type_code = FND_API.G_MISS_CHAR)
        THEN
            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_TIER_TYPE'));
            FND_MSG_PUB.Add;
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
    ELSIF p_modifier_line_rec.operation = 'UPDATE' THEN
        IF (p_modifier_line_rec.product_attr IS NULL )
        THEN
            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_LEVEL'));
            FND_MSG_PUB.Add;
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
        IF (p_modifier_line_rec.product_attr_val IS NULL )
            THEN
                FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_NAME'));
                FND_MSG_PUB.Add;
                x_return_status := FND_API.g_ret_sts_error;
            END IF;
        END IF;
        IF (p_modifier_line_rec.list_line_type_code IS NULL )
        THEN
            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OZF_UTILITY_PVT.getAttributeName(p_attributeCode => 'OZF_TIER_TYPE'));
            FND_MSG_PUB.Add;
            x_return_status := FND_API.g_ret_sts_error;
        END IF;
END checkRequiredItems;


PROCEDURE checkItems
    (
      x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
     ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
     ,x_error_location        OUT NOCOPY NUMBER
    )
    IS
    BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF nvl(p_modifier_line_tbl.count,0) > 0 THEN
            FOR i in p_modifier_line_tbl.first .. p_modifier_line_tbl.last LOOP
                checkRequiredItems
                (
                      x_return_status         => x_return_status
                     ,x_msg_count             => x_msg_count
                     ,x_msg_data              => x_msg_data
                     ,p_modifier_line_rec     => p_modifier_line_tbl(i)
                );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    x_error_location := i;
                    return;
                END IF;
            END LOOP;
        END IF;
END checkItems;
--nepanda fix for forwardport of bug # 8580281 end

-- Use this procedure to create off invoice, Acruals, Terms Substitution
PROCEDURE process_regular_discounts
(
  x_return_status         OUT  NOCOPY VARCHAR2
 ,x_msg_count             OUT  NOCOPY NUMBER
 ,x_msg_data              OUT  NOCOPY VARCHAR2
 ,p_parent_offer_type     IN   VARCHAR2
 ,p_offer_type            IN   VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,x_modifiers_tbl         OUT  NOCOPY QP_MODIFIERS_PUB.modifiers_tbl_type
 ,x_error_location        OUT  NOCOPY NUMBER
) IS

 l_api_version CONSTANT NUMBER       := 1.0;
 l_api_name    CONSTANT VARCHAR2(30) := 'process_regular_discounts';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 tiers_modifier_line_tbl  MODIFIER_LINE_TBL_TYPE;

 l_modifiers_tbl          Qp_Modifiers_Pub.modifiers_tbl_type;
 l_pricing_attr_tbl       Qp_Modifiers_Pub.pricing_attr_tbl_type;
 l_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
 v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
 v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
 v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
 v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
 v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
 v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
 v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
 v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
 p_list_line_id NUMBER;

 i number := 0;
 l_tier_count number := 0;
 l_list_header_id NUMBER;
 l_override_flag VARCHAR2(1);

 TYPE map_record IS RECORD
 (
   orig_row number,
   new_row number,
   tier_row number
 );

 TYPE map_table IS TABLE OF map_record
   INDEX BY BINARY_INTEGER;

 l_map_table map_table;

 CURSOR cur_get_discount_level(p_list_header_id NUMBER) IS
 SELECT modifier_level_code
   FROM ozf_offers
  WHERE qp_list_header_id = p_list_header_id;

  l_discount_level VARCHAR2(30):= 'NONE';
  l_pricing_phase_id NUMBER;


 CURSOR cur_get_offer_enddate(p_list_header_id NUMBER) IS
 SELECT start_date_active, end_date_active
   FROM qp_list_headers_b
  WHERE list_header_id = p_list_header_id;

  l_end_date  date;
  l_start_date  DATE;

  CURSOR c_adv_options_exist(l_list_header_id NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM qp_list_lines
                  WHERE list_header_id = l_list_header_id);

  CURSOR c_adv_options(l_list_header_id NUMBER) IS
  SELECT pricing_phase_id,print_on_invoice_flag,incompatibility_grp_code,pricing_group_sequence,product_precedence
    FROM qp_list_lines
   WHERE list_header_id = l_list_header_id;

  l_adv_options_exist      NUMBER;

BEGIN
  x_return_status := Fnd_Api.g_ret_sts_success;

--nepanda fix for forwardport of bug # 8580281
  checkItems
    (
      x_return_status         => x_return_status
     ,x_msg_count             => x_msg_count
     ,x_msg_data              => x_msg_data
     ,p_modifier_line_tbl     => p_modifier_line_tbl
     ,x_error_location        => x_error_location
    );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--nepanda fix for forwardport of bug # 8580281 end

  l_override_flag := FND_PROFILE.value('OZF_OFFR_OVERRIDE_FLAG');
  l_list_header_id := p_modifier_line_tbl(p_modifier_line_tbl.last).list_header_id;

  OPEN cur_get_discount_level(l_list_header_id);
 FETCH cur_get_discount_level into l_discount_level;
 CLOSE cur_get_discount_level;
  OPEN cur_get_offer_enddate(l_list_header_id);
 FETCH cur_get_offer_enddate into l_start_date, l_end_date;
 CLOSE cur_get_offer_enddate;

 IF l_discount_level = 'LINEGROUP' THEN
    NULL;
 ELSIF l_discount_level = 'LINE' THEN
   NULL;
 ELSIF l_discount_level = 'ORDER' THEN
   NULL;
 ELSE
   l_discount_level   := 'LINEGROUP';
 END IF;

FOR j in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
  IF p_modifier_line_tbl.exists(j) THEN
  debug_message('ListLineTypeCode is :'||p_modifier_line_tbl(j).list_line_type_code);
--    RAISE Fnd_Api.g_exc_error;
  -- all tiers will be passed as PBH even though some of them are actually Tiers
  IF  p_modifier_line_tbl(j).list_line_type_code <> 'PBH' THEN
      i := i+1;

      l_map_table(j).orig_row := j;
      l_map_table(j).new_row := i;

      l_modifiers_tbl(i).operation      := p_modifier_line_tbl(j).operation;
      --l_modifiers_tbl(i).list_header_id := p_modifier_line_tbl(j).list_header_id;
      l_modifiers_tbl(i).list_header_id := l_list_header_id;
      l_modifiers_tbl(i).list_line_id   := p_modifier_line_tbl(j).list_line_id;
      l_modifiers_tbl(i).list_line_no   := p_modifier_line_tbl(j).list_line_no;
      l_modifiers_tbl(i).price_by_formula_id := p_modifier_line_tbl(j).price_by_formula_id;

-- rssharma added flex field on 26-Nov-2002
   l_modifiers_tbl(i).attribute1        := p_modifier_line_tbl(j).attribute1;
   l_modifiers_tbl(i).attribute2        := p_modifier_line_tbl(j).attribute2;
   l_modifiers_tbl(i).attribute3        := p_modifier_line_tbl(j).attribute3;
   l_modifiers_tbl(i).attribute4        := p_modifier_line_tbl(j).attribute4;
   l_modifiers_tbl(i).attribute5        := p_modifier_line_tbl(j).attribute5;
   l_modifiers_tbl(i).attribute6        := p_modifier_line_tbl(j).attribute6;
   l_modifiers_tbl(i).attribute7        := p_modifier_line_tbl(j).attribute7;
   l_modifiers_tbl(i).attribute8        := p_modifier_line_tbl(j).attribute8;
   l_modifiers_tbl(i).attribute9        := p_modifier_line_tbl(j).attribute9;
   l_modifiers_tbl(i).attribute10       := p_modifier_line_tbl(j).attribute10;
   l_modifiers_tbl(i).attribute11       := p_modifier_line_tbl(j).attribute11;
   l_modifiers_tbl(i).attribute12       := p_modifier_line_tbl(j).attribute12;
   l_modifiers_tbl(i).attribute13       := p_modifier_line_tbl(j).attribute13;
   l_modifiers_tbl(i).attribute14       := p_modifier_line_tbl(j).attribute14;
   l_modifiers_tbl(i).attribute15       := p_modifier_line_tbl(j).attribute15;
   l_modifiers_tbl(i).context           := p_modifier_line_tbl(j).context;
-- gramanat added start_date_active
   l_modifiers_tbl(i).start_date_active   := p_modifier_line_tbl(j).start_date_active;
   l_modifiers_tbl(i).end_date_active     := p_modifier_line_tbl(j).end_date_active;
-- end change on 26-Nov-2002

    IF p_modifier_line_tbl(j).operation = 'CREATE' THEN
        l_modifiers_tbl(i).proration_type_code      := 'N';
        l_modifiers_tbl(i).modifier_level_code      := l_discount_level;
        l_modifiers_tbl(i).automatic_flag           := 'Y';
      -- get advanced options
      OPEN c_adv_options_exist(p_modifier_line_tbl(1).list_header_id);
      FETCH c_adv_options_exist INTO l_adv_options_exist;
      CLOSE c_adv_options_exist;

      IF l_adv_options_exist IS NULL THEN
        IF l_discount_level = 'LINEGROUP' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 3 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 3;
--          END IF;
        ELSIF l_discount_level = 'LINE' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINE');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 2 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 2;
--          END IF;
        ELSIF l_discount_level = 'ORDER' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_ORDER');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 4 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 4;
--          END IF;
        ELSE
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 3 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 3;
--          END IF;
        END IF;

        l_modifiers_tbl(i).print_on_invoice_flag := FND_PROFILE.value('OZF_PRINT_ON_INVOICE');

        IF p_parent_offer_type = 'DEAL' THEN
          l_modifiers_tbl(i).incompatibility_grp_code := NULL;
        ELSE
          l_modifiers_tbl(i).incompatibility_grp_code := FND_PROFILE.value('OZF_INCOMPATIBILITY_GROUP');
        END IF;

        IF l_discount_level <> 'ORDER' THEN
          l_modifiers_tbl(i).pricing_group_sequence := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
--          IF l_modifiers_tbl(i).pricing_group_sequence <> 1 THEN
--            l_modifiers_tbl(i).pricing_group_sequence   := 1;
--          END IF;
        END IF;

        l_modifiers_tbl(i).product_precedence := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');

      ELSE
        OPEN c_adv_options(p_modifier_line_tbl(1).list_header_id);
        FETCH c_adv_options INTO l_modifiers_tbl(i).pricing_phase_id,l_modifiers_tbl(i).print_on_invoice_flag,l_modifiers_tbl(i).incompatibility_grp_code,l_modifiers_tbl(i).pricing_group_sequence,l_modifiers_tbl(i).product_precedence;
        CLOSE c_adv_options;

      END IF; -- end advanced options
    END IF; -- end operation

-- common code irrespective of operation so moved it outside
/*      IF p_modifier_line_tbl(j).inactive_flag = 'N' THEN
        IF l_start_date IS NOT NULL THEN
          l_modifiers_tbl(i).end_date_active := l_start_date;
        ELSIF l_end_date IS NOT NULL THEN
          l_modifiers_tbl(i).end_date_active := LEAST(l_end_date, SYSDATE);
        ELSE
          l_modifiers_tbl(i).end_date_active := SYSDATE;
        END IF;
        --l_modifiers_tbl(i).end_date_active       := least(nvl(l_end_date,sysdate-1),sysdate);
      ELSE
        null;
--        l_modifiers_tbl(i).end_date_active := NULL;
      END IF;
      */
      IF p_offer_type = 'OFF_INVOICE' OR p_offer_type = 'VOLUME_OFFER' THEN
        l_modifiers_tbl(i).arithmetic_operator      := p_modifier_line_tbl(j).arithmetic_operator;
        l_modifiers_tbl(i).operand                  := p_modifier_line_tbl(j).operand;
        l_modifiers_tbl(i).list_line_type_code      := 'DIS';
        l_modifiers_tbl(i).override_flag            := l_override_flag;
        l_modifiers_tbl(i).accrual_flag             := 'N';
      ELSIF p_offer_type = 'ACCRUAL' THEN
        l_modifiers_tbl(i).list_line_type_code      := 'DIS';
        l_modifiers_tbl(i).override_flag            := l_override_flag;

        IF  p_modifier_line_tbl(j).arithmetic_operator not in ('%','AMT','LUMPSUM','NEWPRICE') THEN
          l_modifiers_tbl(i).benefit_qty              := p_modifier_line_tbl(j).operand;
          l_modifiers_tbl(i).benefit_uom_code         := p_modifier_line_tbl(j).benefit_uom_code;
          l_modifiers_tbl(i).operand                  := p_modifier_line_tbl(j).operand;
          l_modifiers_tbl(i).arithmetic_operator      := 'AMT';
          l_modifiers_tbl(i).estim_accrual_rate       := 1;
          l_modifiers_tbl(i).accrual_conversion_rate  := 1;
        ELSE
          l_modifiers_tbl(i).benefit_qty              := null;
          l_modifiers_tbl(i).benefit_uom_code         := null;
          l_modifiers_tbl(i).operand                  := p_modifier_line_tbl(j).operand;
          l_modifiers_tbl(i).arithmetic_operator      := p_modifier_line_tbl(j).arithmetic_operator;
        END IF;
        l_modifiers_tbl(i).accrual_flag             := 'Y';

      ELSIF p_offer_type = 'TERMS' THEN
        l_modifiers_tbl(i).list_line_type_code      := 'TSN';
        l_modifiers_tbl(i).override_flag            := 'N'; -- overriding is not supported
        l_modifiers_tbl(i).substitution_context     := 'TERMS';
        l_modifiers_tbl(i).pricing_phase_id         := 2;
        l_modifiers_tbl(i).modifier_level_code      := 'LINE';
        l_modifiers_tbl(i).substitution_attribute   := p_modifier_line_tbl(j).substitution_attr;
        l_modifiers_tbl(i).substitution_value       := p_modifier_line_tbl(j).substitution_val;
        l_modifiers_tbl(i).estim_gl_value           := p_modifier_line_tbl(j).estim_gl_value;
      END IF;  -- end offer_type

    l_pricing_attr_tbl(i).pricing_attribute_id     := p_modifier_line_tbl(j).pricing_attribute_id;
    l_pricing_attr_tbl(i).product_attribute_context  := 'ITEM';
    l_pricing_attr_tbl(i).product_attribute          := p_modifier_line_tbl(j).product_attr;
    l_pricing_attr_tbl(i).product_attr_value         := p_modifier_line_tbl(j).product_attr_val;

   IF p_modifier_line_tbl(j).pricing_attr = 'PRICING_ATTRIBUTE10' THEN--if volume_type is qty
    IF p_modifier_line_tbl(j).product_uom_code is not null and p_modifier_line_tbl(j).product_uom_code <> FND_API.g_miss_char THEN
      l_pricing_attr_tbl(i).product_uom_code      :=  p_modifier_line_tbl(j).product_uom_code;
      l_modifiers_tbl(i).price_break_type_code    := 'POINT';
      l_pricing_attr_tbl(i).pricing_attribute_context  := 'VOLUME';
      l_pricing_attr_tbl(i).pricing_attribute          := p_modifier_line_tbl(j).pricing_attr;
      l_pricing_attr_tbl(i).pricing_attr_value_from    := p_modifier_line_tbl(j).pricing_attr_value_from;
      IF p_modifier_line_tbl(j).operation <> 'CREATE' THEN
        l_pricing_attr_tbl(i).pricing_attr_value_to      := p_modifier_line_tbl(j).pricing_attr_value_to;
      END IF;
      l_pricing_attr_tbl(i).comparison_operator_code   := 'BETWEEN';
    ELSIF  (p_parent_offer_type<>'DEAL') AND (p_modifier_line_tbl(j).product_uom_code is null --fix for bug 5969719
           OR p_modifier_line_tbl(j).product_uom_code = FND_API.g_miss_char
           ) AND
         ((p_modifier_line_tbl(j).pricing_attr_value_from is not null
         AND p_modifier_line_tbl(j).pricing_attr_value_from <> FND_API.g_miss_num) OR
           (p_modifier_line_tbl(j).pricing_attr is not null
           AND p_modifier_line_tbl(j).pricing_attr <> FND_API.g_miss_char))
           THEN
          FND_MESSAGE.SET_NAME('OZF','OZF_UOM_QTY_REQD');

          Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE -- volume type is amount
      l_pricing_attr_tbl(i).product_uom_code      :=  p_modifier_line_tbl(j).product_uom_code;
      l_modifiers_tbl(i).price_break_type_code    := 'POINT';
      l_pricing_attr_tbl(i).pricing_attribute_context  := 'VOLUME';
      l_pricing_attr_tbl(i).pricing_attribute          := p_modifier_line_tbl(j).pricing_attr;
      l_pricing_attr_tbl(i).pricing_attr_value_from    := p_modifier_line_tbl(j).pricing_attr_value_from;
      IF p_modifier_line_tbl(j).operation <> 'CREATE' THEN
        l_pricing_attr_tbl(i).pricing_attr_value_to      := p_modifier_line_tbl(j).pricing_attr_value_to;
      END IF;
      l_pricing_attr_tbl(i).comparison_operator_code   := 'BETWEEN';
 END IF;


  l_pricing_attr_tbl(i).modifiers_index            := i;
  l_pricing_attr_tbl(i).list_line_id               := p_modifier_line_tbl(j).list_line_id;
  l_pricing_attr_tbl(i).operation                  := p_modifier_line_tbl(j).operation;


  IF p_modifier_line_tbl(j).order_value_from <> fnd_api.g_miss_char and
    p_modifier_line_tbl(j).order_value_from is not null THEN

    -- This fragment only appears in the detail detail page.  Assuming list line id is available.
    IF  p_modifier_line_tbl(j).qualifier_id = fnd_api.g_miss_num THEN
      l_qualifiers_tbl(i).operation      := 'CREATE';
      l_qualifiers_tbl(i).qualifier_id   := fnd_api.g_miss_num;
    ELSIF p_modifier_line_tbl(j).order_value_from is not null or p_modifier_line_tbl(j).order_value_to is not null THEN
      l_qualifiers_tbl(i).qualifier_id             := p_modifier_line_tbl(j).qualifier_id;
      l_qualifiers_tbl(i).operation                := 'UPDATE';
    ELSIF p_modifier_line_tbl(j).order_value_from is null and p_modifier_line_tbl(j).order_value_to is null THEN
      l_qualifiers_tbl(i).qualifier_id             := p_modifier_line_tbl(j).qualifier_id;
      l_qualifiers_tbl(i).operation                := 'DELETE';
    END IF;

    -- julou list_header_id is passed to qualifier otherwise copy API will not copy
    -- order_value_from and order_value_to
    l_qualifiers_tbl(i).list_header_id           := p_modifier_line_tbl(j).list_header_id;
    l_qualifiers_tbl(i).list_line_id             := p_modifier_line_tbl(j).list_line_id;
    l_qualifiers_tbl(i).qualifier_context        := 'VOLUME';
    l_qualifiers_tbl(i).qualifier_attribute      := 'QUALIFIER_ATTRIBUTE10';
    l_qualifiers_tbl(i).qualifier_attr_value     := p_modifier_line_tbl(j).order_value_from;
    IF p_modifier_line_tbl(j).order_value_to is not null and p_modifier_line_tbl(j).order_value_to <> FND_API.g_miss_char THEN
      l_qualifiers_tbl(i).qualifier_attr_value_to  := p_modifier_line_tbl(j).order_value_to;
    ELSE
      l_qualifiers_tbl(i).qualifier_attr_value_to := FND_API.g_miss_char;
    END IF;
    l_qualifiers_tbl(i).comparison_operator_code := 'BETWEEN';
    l_qualifiers_tbl(i).qualifier_grouping_no    := 1;

   END IF;

  ELSE
  l_tier_count := l_tier_count + 1;

  l_map_table(j).orig_row := j;
  l_map_table(j).tier_row := l_tier_count;

  tiers_modifier_line_tbl(l_tier_count) := p_modifier_line_tbl(j);
 END IF;

END IF;
debug_message('ListLineTypeCode is :'||p_modifier_line_tbl(j).list_line_type_code);
END LOOP;
--    RAISE Fnd_Api.g_exc_error;

  IF l_modifiers_tbl.count > 0 THEN -- bug 3711957. when processing PBH, l_modifiers_tbl is empty
    QP_Modifiers_PUB.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifiers_tbl,
      p_pricing_attr_tbl       => l_pricing_attr_tbl,
      p_qualifiers_tbl         => l_qualifiers_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );

 IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
   IF v_modifiers_tbl.COUNT > 0 THEN
    FOR k IN v_modifiers_tbl.first..v_modifiers_tbl.last LOOP
     IF v_modifiers_tbl.EXISTS(k) THEN
        IF v_modifiers_tbl(k).return_status <> Fnd_Api.g_ret_sts_success THEN
           FOR t in l_map_table.first..l_map_table.last LOOP
             IF l_map_table.exists(t) THEN
               IF l_map_table(t).new_row = k THEN
                 x_error_location := l_map_table(t).orig_row;
                EXIT;
               END IF;
            END IF;
           END LOOP;
          END IF;
        END IF;
    END LOOP;
   END IF;
 END IF;

 IF x_return_status = Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;

 x_modifiers_tbl := v_modifiers_tbl;
  END IF; -- end bug 3711957
 ---Process Limits
 /*#############################################################################
   When processing Terms upgrade type of discounts limit information could come
   during creation.  The list_line_id might have been created in the above call.
   So Have to check for creation and set list line id accordingly.  There will be
   no 'PBH' type of records for Terms Substitution.
   ##############################################################################*/

IF p_offer_type = 'TERMS' THEN

 FOR limit_index in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
  IF p_modifier_line_tbl.exists(limit_index) THEN
   IF p_modifier_line_tbl(limit_index).operation = 'CREATE' THEN
     p_list_line_id := v_modifiers_tbl(limit_index).list_line_id;
   ELSE
     p_list_line_id := p_modifier_line_tbl(limit_index).list_line_id;
   END IF;
      process_limits
      (
       x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_limit_type        =>'MAX_ORDERS_PER_CUSTOMER'
      ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_orders_per_customer
      ,p_list_line_id      => p_list_line_id
      ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
      ,p_limit_id          => p_modifier_line_tbl(limit_index).max_orders_per_customer_id
      );

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

  END IF;
 END LOOP;

END IF;


IF tiers_modifier_line_tbl.count > 0 THEN
  process_header_tiers
  (
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    p_offer_type           => p_offer_type,
    p_modifier_line_tbl    => tiers_modifier_line_tbl,
    x_modifiers_tbl        => x_modifiers_tbl,
    x_error_location       => x_error_location
  );

END IF;

    IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      FOR t in l_map_table.first..l_map_table.last LOOP
         IF l_map_table.exists(t) THEN
            IF l_map_table(t).tier_row = x_error_location THEN
              x_error_location := l_map_table(t).orig_row;
              EXIT;
            END IF;
         END IF;
     END LOOP;
   END IF;

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

/*#############################################################################
   For Off Invoice and Accruals, Limit information comes only
   through a details page. i.e List_line_id will have a value as part of the record.
   When a trade deal is created, the same procedure will be called twice, Once for
   Off Invoice and Once for Accrual. If it is trade deal limits will not be processed
   through here.
 #############################################################################*/

IF p_parent_offer_type <> 'DEAL' THEN

IF p_offer_type IN ('OFF_INVOICE','ACCRUAL') THEN

--nirprasa
 FOR limit_index in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
   IF p_modifier_line_tbl.exists(limit_index) THEN

   p_list_line_id := p_modifier_line_tbl(limit_index).list_line_id;

   IF p_modifier_line_tbl(limit_index).operation = 'CREATE'
   AND v_modifiers_tbl.exists(limit_index) THEN

     p_list_line_id := v_modifiers_tbl(limit_index).list_line_id;

   ELSE

     p_list_line_id := p_modifier_line_tbl(limit_index).list_line_id;

   END IF;

   --  IF p_modifier_line_tbl(limit_index).limit_exceed_action_code IS NOT NULL
   --   OR p_modifier_line_tbl(limit_index).limit_exceed_action_code <> FND_API.G_MISS_CHAR THEN

      process_limits
      (
       x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_limit_type                 => 'MAX_QTY_PER_ORDER'
      ,p_limit_amount               => p_modifier_line_tbl(limit_index).max_qty_per_order
      ,p_list_line_id               => p_list_line_id
      ,p_list_header_id             => p_modifier_line_tbl(limit_index).list_header_id
      ,p_limit_id                   => p_modifier_line_tbl(limit_index).max_qty_per_order_id
      );


   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

      process_limits
      (
       x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_limit_type        =>'MAX_QTY_PER_CUSTOMER'
      ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_qty_per_customer
      ,p_list_line_id      => p_modifier_line_tbl(limit_index).list_line_id
      ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
      ,p_limit_id          => p_modifier_line_tbl(limit_index).max_qty_per_customer_id
      );

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

 IF g_sd_offer = 'Y' THEN
      process_limits
      (
       x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_limit_type                 => 'MAX_QTY_PER_RULE'
      ,p_limit_amount               => p_modifier_line_tbl(limit_index).max_qty_per_rule
      ,p_list_line_id               => p_list_line_id
      ,p_list_header_id             => p_modifier_line_tbl(p_modifier_line_tbl.last).list_header_id
      ,p_limit_id                   => p_modifier_line_tbl(limit_index).max_qty_per_rule_id
      ,p_limit_exceed_action_code   => p_modifier_line_tbl(limit_index).limit_exceed_action_code
      );
  ELSE
   process_limits
      (
       x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_limit_type        =>'MAX_QTY_PER_RULE'
      ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_qty_per_rule
      ,p_list_line_id      => p_modifier_line_tbl(limit_index).list_line_id
      ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
      ,p_limit_id          => p_modifier_line_tbl(limit_index).max_qty_per_rule_id
      );

    END IF;

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

     process_limits
      (
       x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_limit_type        =>'MAX_ORDERS_PER_CUSTOMER'
      ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_orders_per_customer
      ,p_list_line_id      => p_modifier_line_tbl(limit_index).list_line_id
      ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
      ,p_limit_id          => p_modifier_line_tbl(limit_index).max_orders_per_customer_id
      );

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

     process_limits
      (
       x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_limit_type        =>'MAX_AMOUNT_PER_RULE'
      ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_amount_per_rule
      ,p_list_line_id      => p_modifier_line_tbl(limit_index).list_line_id
      ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
      ,p_limit_id          => p_modifier_line_tbl(limit_index).max_amount_per_rule_id
      );

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

  END IF;
 END LOOP;

END IF;

END IF;

       Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;


PROCEDURE activate_offer
(
   x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_qp_list_header_id     IN   NUMBER
  ,p_new_status_id         IN   NUMBER
)IS

 l_api_version CONSTANT NUMBER       := 1.0;
 l_api_name    CONSTANT VARCHAR2(30) := 'activate_offer';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 l_offer_rec  modifier_list_rec_type;
 l_amount_error VARCHAR2(1);
 l_offer_type   VARCHAR2(30);

CURSOR cur_get_ozf_offers IS
SELECT  OFFER_ID
      , QP_LIST_HEADER_ID
      , OFFER_TYPE
      , OFFER_CODE
      , REUSABLE
      , CUSTOM_SETUP_ID
      , USER_STATUS_ID
      , OWNER_ID
      , OBJECT_VERSION_NUMBER
      , PERF_DATE_FROM
      , PERF_DATE_TO
      , STATUS_CODE
      , STATUS_DATE
      , ORDER_VALUE_DISCOUNT_TYPE
      , MODIFIER_LEVEL_CODE
      , OFFER_AMOUNT
      , LUMPSUM_AMOUNT
      , LUMPSUM_PAYMENT_TYPE
      , DISTRIBUTION_TYPE
      , BUDGET_AMOUNT_FC
      , BUDGET_AMOUNT_TC
      , TRANSACTION_CURRENCY_CODE
      , FUNCTIONAL_CURRENCY_CODE
      , ACTIVITY_MEDIA_ID
      , BREAK_TYPE
  FROM ozf_offers
 WHERE qp_list_header_id = p_qp_list_header_id;

  CURSOR c_approved_amount(l_id NUMBER) IS
  SELECT nvl(sum(approved_amount),0)
  FROM   ozf_act_budgets
  WHERE  arc_act_budget_used_by = 'OFFR'
  AND    act_budget_used_by_id = l_id;

 l_status_code varchar2(30);
 l_approved_amount number;
 l_recal       VARCHAR2(1);
BEGIN

  SAVEPOINT activate_offer_api;

  x_return_status := FND_API.g_ret_sts_success;

  l_status_code  :=  OZF_Utility_PVT.get_system_status_code(p_new_status_id);

   OPEN cur_get_ozf_offers;
  FETCH cur_get_ozf_offers
  INTO l_offer_rec.OFFER_ID
      ,l_offer_rec.QP_LIST_HEADER_ID
      ,l_offer_rec.OFFER_TYPE
      ,l_offer_rec.OFFER_CODE
      ,l_offer_rec.REUSABLE
      ,l_offer_rec.CUSTOM_SETUP_ID
      ,l_offer_rec.USER_STATUS_ID
      ,l_offer_rec.OWNER_ID
      ,l_offer_rec.OBJECT_VERSION_NUMBER
      ,l_offer_rec.PERF_DATE_FROM
      ,l_offer_rec.PERF_DATE_TO
      ,l_offer_rec.STATUS_CODE
      ,l_offer_rec.STATUS_DATE
      ,l_offer_rec.ORDER_VALUE_DISCOUNT_TYPE
      ,l_offer_rec.MODIFIER_LEVEL_CODE
      ,l_offer_rec.OFFER_AMOUNT
      ,l_offer_rec.LUMPSUM_AMOUNT
      ,l_offer_rec.LUMPSUM_PAYMENT_TYPE
      ,l_offer_rec.DISTRIBUTION_TYPE
      ,l_offer_rec.BUDGET_AMOUNT_FC
      ,l_offer_rec.BUDGET_AMOUNT_TC
      ,l_offer_rec.TRANSACTION_CURRENCY_CODE
      ,l_offer_rec.FUNCTIONAL_CURRENCY_CODE
      ,l_offer_rec.ACTIVITY_MEDIA_ID
      ,l_offer_rec.BREAK_TYPE;
  CLOSE cur_get_ozf_offers;

  IF p_new_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','ACTIVE')
        AND l_offer_rec.CUSTOM_SETUP_ID = 118  THEN

        update ozf_sd_request_headers_all_b set user_status_id= OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS','ACTIVE')
        where offer_id= l_offer_rec.qp_list_header_id;

  END IF;

  IF l_status_code <> 'ACTIVE' THEN

   UPDATE ozf_offers
      SET status_code = l_status_code,
          status_date = SYSDATE,
          object_version_number = object_version_number + 1,
          user_status_id =  p_new_status_id
    WHERE qp_list_header_id = p_qp_list_header_id;



    IF l_offer_rec.CUSTOM_SETUP_ID = 118 THEN
        IF p_new_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','DENIED_TA')
        OR p_new_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','REJECTED') THEN

        update ozf_sd_request_headers_all_b set user_status_id= OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS','OFFER_REJECTED')
        where offer_id= l_offer_rec.qp_list_header_id;

END IF;


    END IF;

    IF SQL%NOTFOUND THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;

   RETURN;

  END IF;



      activate_offer_over(
          p_init_msg_list    => FND_API.g_false
         ,p_api_version      => l_api_version
         ,p_commit           => FND_API.G_FALSE
         ,x_return_status    => x_return_status
         ,x_msg_count        => x_msg_count
         ,x_msg_data         => x_msg_data
         ,p_offer_rec        => l_offer_rec
         ,p_called_from      => 'B'
         ,x_amount_error     => l_amount_error
       );

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

   l_recal := FND_PROFILE.VALUE('OZF_BUDGET_ADJ_ALLOW_RECAL');
   -- update status according to recal flag
   UPDATE ozf_offers
      SET status_code = DECODE(l_amount_error, 'Y', DECODE(l_recal, 'N', 'PENDING_ACTIVE', 'Y', 'DRAFT'), 'N', 'ACTIVE'),
          status_date = SYSDATE,
          object_version_number = object_version_number + 1,
          user_status_id = decode(l_amount_error, 'Y', OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS', DECODE(l_recal, 'N', 'PENDING_ACTIVE', 'Y', 'DRAFT')),'N', p_new_status_id)
      WHERE qp_list_header_id = p_qp_list_header_id;

/*
-- julou if recal = 'N' if approved>committed -> active otherwise pending_active
   IF l_recal = 'N' THEN
     UPDATE ozf_offers
        SET status_code = decode(l_amount_error,'Y','PENDING_ACTIVE','N','ACTIVE'),
            status_date = SYSDATE,
            object_version_number = object_version_number + 1,
            user_status_id = decode(l_amount_error,'Y',OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','PENDING_ACTIVE'),'N',p_new_status_id)
      WHERE qp_list_header_id = p_qp_list_header_id;
    ELSIF FND_PROFILE.VALUE('OZF_BUDGET_ADJ_ALLOW_RECAL') = 'Y' THEN
      -- if recal='N' if approved>0 -> active(no status change) otherwise draft
      OPEN c_approved_amount(p_qp_list_header_id);
      FETCH c_approved_amount INTO l_approved_amount;
      CLOSE c_approved_amount;

      IF l_approved_amount <= 0 THEN
        UPDATE ozf_offers
           SET status_code = 'DRAFT',
               status_date = SYSDATE,
               object_version_number = object_version_number + 1,
               user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','DRAFT')
         WHERE qp_list_header_id = p_qp_list_header_id;
       END IF;
    END IF;
*/
   IF l_amount_error = 'N' THEN -- update qp to active only when validation passes
     IF l_offer_rec.offer_type NOT IN('LUMPSUM', 'SCAN_DATA', 'NET_ACCRUAL') THEN
       UPDATE qp_list_headers_b
          SET active_flag = 'Y'
        WHERE list_header_id = p_qp_list_header_id;

       UPDATE qp_qualifiers
          SET active_flag='Y'
        WHERE list_header_id = p_qp_list_header_id;
     END IF;
    END IF;
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO activate_offer_api;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO activate_offer_api;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO activate_offer_api;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;


PROCEDURE process_order_value
(
  x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
  , x_modifiers_tbl         OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
 ,x_error_location        OUT NOCOPY  NUMBER
) IS

 l_api_version CONSTANT NUMBER       := 1.0;
 l_api_name    CONSTANT VARCHAR2(30) := 'process_order_value';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 l_modifiers_tbl          Qp_Modifiers_Pub.modifiers_tbl_type;
 l_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
 v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
 v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
 v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
 v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
 v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
 v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
 v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
 v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;

 p_list_line_id NUMBER;
 CURSOR cur_get_discount_level(p_list_header_id NUMBER) IS
 SELECT modifier_level_code
   FROM ozf_offers
  WHERE qp_list_header_id = p_list_header_id;

 CURSOR cur_get_ov_discount_type(p_list_header_id NUMBER) IS
 SELECT order_value_discount_type
   FROM ozf_offers
  WHERE qp_list_header_id = p_list_header_id;


   CURSOR cur_get_offer_enddate(p_list_header_id NUMBER) IS
 SELECT start_date_active, end_date_active
   FROM qp_list_headers_b
  WHERE list_header_id = p_list_header_id;

  l_discount_level VARCHAR2(30);
  l_order_value_discount_type VARCHAR2(30);
  l_pricing_phase_id NUMBER;
  l_list_header_id NUMBER;

  CURSOR c_adv_options_exist(l_list_header_id NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM qp_list_lines
                  WHERE list_header_id = l_list_header_id);

  CURSOR c_adv_options(l_list_header_id NUMBER) IS
  SELECT pricing_phase_id,print_on_invoice_flag,incompatibility_grp_code,pricing_group_sequence,product_precedence
    FROM qp_list_lines
   WHERE list_header_id = l_list_header_id;

  l_adv_options_exist NUMBER;
  l_override_flag     VARCHAR2(1);
  l_end_date DATE;
  l_start_date DATE;
BEGIN
  x_return_status := Fnd_Api.g_ret_sts_success;
  l_override_flag := FND_PROFILE.value('OZF_OFFR_OVERRIDE_FLAG');
  l_list_header_id := p_modifier_line_tbl(p_modifier_line_tbl.last).list_header_id;

  OPEN cur_get_discount_level(l_list_header_id);
  FETCH cur_get_discount_level into l_discount_level;
  CLOSE cur_get_discount_level;

    OPEN cur_get_offer_enddate(l_list_header_id);
    FETCH cur_get_offer_enddate into l_start_date, l_end_date;
    CLOSE cur_get_offer_enddate;

  IF l_discount_level = 'LINEGROUP' THEN
    NULL;
  ELSIF l_discount_level = 'LINE' THEN
    NULL;
  ELSIF l_discount_level = 'ORDER' THEN
    NULL;
  ELSE
    l_discount_level   := 'LINEGROUP';
  END IF;


FOR i in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
  IF p_modifier_line_tbl.exists(i) THEN

    l_modifiers_tbl(i).operation      := p_modifier_line_tbl(i).operation;
    l_modifiers_tbl(i).list_header_id := p_modifier_line_tbl(i).list_header_id;
    l_modifiers_tbl(i).list_line_id   := p_modifier_line_tbl(i).list_line_id;

    OPEN  cur_get_ov_discount_type(l_list_header_id);
    FETCH cur_get_ov_discount_type into l_order_value_discount_type;
    CLOSE cur_get_ov_discount_type;

    IF p_modifier_line_tbl(i).operation = 'CREATE' THEN

      l_modifiers_tbl(i).proration_type_code      := 'N';
      l_modifiers_tbl(i).print_on_invoice_flag    := 'Y';
      l_modifiers_tbl(i).modifier_level_code      := l_discount_level;
      l_modifiers_tbl(i).price_break_type_code    := 'POINT';
      l_modifiers_tbl(i).automatic_flag           := 'Y';
      IF l_order_value_discount_type = 'AMT' OR l_order_value_discount_type = 'DIS' THEN
      l_modifiers_tbl(i).list_line_type_code      := 'DIS';
      ELSE
      l_modifiers_tbl(i).list_line_type_code      := l_order_value_discount_type;
      END IF;
      l_modifiers_tbl(i).override_flag            := l_override_flag;

      -- get advanced options
      OPEN c_adv_options_exist(p_modifier_line_tbl(1).list_header_id);
      FETCH c_adv_options_exist INTO l_adv_options_exist;
      CLOSE c_adv_options_exist;

      IF l_adv_options_exist IS NULL THEN
        IF l_discount_level = 'LINEGROUP' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 3 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 3;
--          END IF;
        ELSIF l_discount_level = 'LINE' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINE');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 2 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 2;
--          END IF;
        ELSIF l_discount_level = 'ORDER' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_ORDER');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 4 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 4;
--          END IF;
        ELSE
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 3 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 3;
--          END IF;
        END IF;

        l_modifiers_tbl(i).print_on_invoice_flag := FND_PROFILE.value('OZF_PRINT_ON_INVOICE');
        l_modifiers_tbl(i).incompatibility_grp_code := FND_PROFILE.value('OZF_INCOMPATIBILITY_GROUP');

        IF l_discount_level <> 'ORDER' THEN
          l_modifiers_tbl(i).pricing_group_sequence := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
--          IF l_modifiers_tbl(i).pricing_group_sequence <>1 THEN
--            l_modifiers_tbl(i).pricing_group_sequence   := 1;
--          END IF;
        END IF;

        l_modifiers_tbl(i).product_precedence := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');

      ELSE
        OPEN c_adv_options(p_modifier_line_tbl(1).list_header_id);
        FETCH c_adv_options INTO l_modifiers_tbl(i).pricing_phase_id,l_modifiers_tbl(i).print_on_invoice_flag,l_modifiers_tbl(i).incompatibility_grp_code,l_modifiers_tbl(i).pricing_group_sequence,l_modifiers_tbl(i).product_precedence;
        CLOSE c_adv_options;
      END IF;
      -- end advanced options

    END IF;

    IF l_order_value_discount_type = 'DIS' THEN
      l_modifiers_tbl(i).override_flag            := l_override_flag;
      l_modifiers_tbl(i).arithmetic_operator      := '%';
      l_modifiers_tbl(i).operand                  := p_modifier_line_tbl(i).operand;
      ELSIF l_order_value_discount_type = 'AMT' THEN
      l_modifiers_tbl(i).override_flag            := l_override_flag;
      l_modifiers_tbl(i).arithmetic_operator      := 'AMT';
      l_modifiers_tbl(i).operand                  := p_modifier_line_tbl(i).operand;
    END IF;

    IF p_modifier_line_tbl(i).list_line_type_code = 'TSN' THEN
      l_modifiers_tbl(i).override_flag            := l_override_flag;
      l_modifiers_tbl(i).substitution_context     := 'TERMS';
      l_modifiers_tbl(i).modifier_level_code      := l_discount_level;
--      l_modifiers_tbl(i).pricing_phase_id         := 2;
      l_modifiers_tbl(i).substitution_attribute   := p_modifier_line_tbl(i).substitution_attr;
      l_modifiers_tbl(i).substitution_value       := p_modifier_line_tbl(i).substitution_val;
      l_modifiers_tbl(i).estim_gl_value           := p_modifier_line_tbl(i).estim_gl_value;
    END IF;

    l_modifiers_tbl(i).start_date_active         := p_modifier_line_tbl(i).start_date_active;
    l_modifiers_tbl(i).end_date_active           := p_modifier_line_tbl(i).end_date_active;

     IF p_modifier_line_tbl(i).inactive_flag = 'N' THEN
        IF l_start_date IS NOT NULL THEN
          l_modifiers_tbl(i).end_date_active := GREATEST(l_start_date, SYSDATE);
        ELSIF l_end_date IS NOT NULL THEN
          l_modifiers_tbl(i).end_date_active := LEAST(l_end_date, SYSDATE);
        ELSE
          l_modifiers_tbl(i).end_date_active := SYSDATE;
        END IF;
        --l_modifiers_tbl(i).end_date_active       := least(nvl(l_end_date,sysdate-1),sysdate);
      ELSE
        l_modifiers_tbl(i).end_date_active := p_modifier_line_tbl(i).end_date_active;
      END IF;

  END IF;
-- rssharma added flex field on 15-Apr-2003
   l_modifiers_tbl(i).attribute1        := p_modifier_line_tbl(i).attribute1;
   l_modifiers_tbl(i).attribute2        := p_modifier_line_tbl(i).attribute2;
   l_modifiers_tbl(i).attribute3        := p_modifier_line_tbl(i).attribute3;
   l_modifiers_tbl(i).attribute4        := p_modifier_line_tbl(i).attribute4;
   l_modifiers_tbl(i).attribute5        := p_modifier_line_tbl(i).attribute5;
   l_modifiers_tbl(i).attribute6        := p_modifier_line_tbl(i).attribute6;
   l_modifiers_tbl(i).attribute7        := p_modifier_line_tbl(i).attribute7;
   l_modifiers_tbl(i).attribute8        := p_modifier_line_tbl(i).attribute8;
   l_modifiers_tbl(i).attribute9        := p_modifier_line_tbl(i).attribute9;
   l_modifiers_tbl(i).attribute10       := p_modifier_line_tbl(i).attribute10;
   l_modifiers_tbl(i).attribute11       := p_modifier_line_tbl(i).attribute11;
   l_modifiers_tbl(i).attribute12       := p_modifier_line_tbl(i).attribute12;
   l_modifiers_tbl(i).attribute13       := p_modifier_line_tbl(i).attribute13;
   l_modifiers_tbl(i).attribute14       := p_modifier_line_tbl(i).attribute14;
   l_modifiers_tbl(i).attribute15       := p_modifier_line_tbl(i).attribute15;
   l_modifiers_tbl(i).context           := p_modifier_line_tbl(i).context;
-- end change on 15-Apr-2003
debug_message('ENdDateActive is :'||l_modifiers_tbl(i).end_date_active);
END LOOP;

  QP_Modifiers_PUB.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifiers_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );
 x_modifiers_tbl :=  v_modifiers_tbl;

 IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
   IF v_modifiers_tbl.COUNT > 0 THEN
    FOR k IN v_modifiers_tbl.first..v_modifiers_tbl.last LOOP
     IF v_modifiers_tbl.EXISTS(k) THEN
        IF v_modifiers_tbl(k).return_status <> Fnd_Api.g_ret_sts_success THEN
             x_error_location := k;
             EXIT;
        END IF;
      END IF;
    END LOOP;
   END IF;
 END IF;

 IF x_return_status = Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;
FOR i in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
 IF p_modifier_line_tbl.exists(i) THEN


  l_qualifiers_tbl(i).qualifier_id             := p_modifier_line_tbl(i).qualifier_id;
  l_qualifiers_tbl(i).list_header_id           := p_modifier_line_tbl(i).list_header_id; -- list_header_id for order value discount
  l_qualifiers_tbl(i).list_line_id             := v_modifiers_tbl(i).list_line_id;
  l_qualifiers_tbl(i).qualifier_context         := 'VOLUME';
  l_qualifiers_tbl(i).qualifier_attribute       := 'QUALIFIER_ATTRIBUTE10';
  l_qualifiers_tbl(i).qualifier_attr_value      := p_modifier_line_tbl(i).order_value_from;
  IF p_modifier_line_tbl(i).order_value_to IS NOT NULL AND
        p_modifier_line_tbl(i).order_value_to <> FND_API.g_miss_char THEN
   l_qualifiers_tbl(i).qualifier_attr_value_to   := p_modifier_line_tbl(i).order_value_to;
  ELSE
   l_qualifiers_tbl(i).qualifier_attr_value_to   := FND_API.g_miss_char;
  END IF;
  l_qualifiers_tbl(i).comparison_operator_code  := 'BETWEEN';
  l_qualifiers_tbl(i).qualifier_grouping_no     := 1;
  l_qualifiers_tbl(i).operation                 := p_modifier_line_tbl(i).operation;

 END IF;

END LOOP;


  QP_Modifiers_PUB.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_qualifiers_tbl         => l_qualifiers_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );

 IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
   IF v_qualifiers_tbl.COUNT > 0 THEN
    FOR k IN v_qualifiers_tbl.first..v_qualifiers_tbl.last LOOP
     IF v_qualifiers_tbl.EXISTS(k) THEN
        IF v_qualifiers_tbl(k).return_status <> Fnd_Api.g_ret_sts_success THEN
             x_error_location := k;
             EXIT;
        END IF;
      END IF;
    END LOOP;
   END IF;
 END IF;

 IF x_return_status = Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;

 -- The following code is commented for now. If we decide that we need limits
 -- for order value type of discounts,  we will open this code up.

 /* FOR limit_index in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP

  IF p_modifier_line_tbl.exists(limit_index) THEN

   IF p_modifier_line_tbl(limit_index).operation = 'CREATE' THEN
     p_list_line_id := v_modifiers_tbl(limit_index).list_line_id;
   ELSE
     p_list_line_id := p_modifier_line_tbl(limit_index).list_line_id;
   END IF;

    IF p_modifier_line_tbl(limit_index).list_line_type_code = 'TSN' THEN
       process_limits
       (
        x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_limit_type        =>'MAX_ORDERS_PER_CUSTOMER'
       ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_orders_per_customer
       ,p_list_line_id      => p_list_line_id
       ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
       ,p_limit_id          => p_modifier_line_tbl(limit_index).max_orders_per_customer_id
       );
    ELSIF p_modifier_line_tbl(limit_index).list_line_type_code = 'DIS' THEN
       process_limits
       (
        x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_limit_type        =>'MAX_AMOUNT_PER_RULE'
       ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_amount_per_rule
       ,p_list_line_id      => p_list_line_id
       ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
       ,p_limit_id          => p_modifier_line_tbl(limit_index).max_amount_per_rule_id
       );
    END IF;

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     x_error_location := limit_index;
     RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

  END IF;
 END LOOP; */

    Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;


PROCEDURE validate_lumpsum_offer
(
   p_init_msg_list         IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_qp_list_header_id     IN   NUMBER
)IS

 l_api_version CONSTANT NUMBER       := 1.0;
 l_api_name    CONSTANT VARCHAR2(30) := 'validate_lumpsum_offer';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 CURSOR cur_get_lumpsum_details IS
 SELECT status_code,lumpsum_amount,object_version_number,distribution_type,qp_list_header_id,offer_id
   FROM ozf_offers
  WHERE qp_list_header_id = p_qp_list_header_id;

  l_lumpsum_offer cur_get_lumpsum_details%rowtype;

 CURSOR cur_get_lumpsum_line_details IS
 SELECT nvl(sum(line_lumpsum_qty),0)
   FROM ams_act_products
  WHERE ARC_ACT_PRODUCT_USED_BY = 'OFFR'
    AND ACT_PRODUCT_USED_BY_ID = p_qp_list_header_id;

l_total_distribution NUMBER;

BEGIN
x_return_status := Fnd_Api.g_ret_sts_success;

OPEN cur_get_lumpsum_details;
FETCH cur_get_lumpsum_details INTO l_lumpsum_offer;
CLOSE cur_get_lumpsum_details;

OPEN cur_get_lumpsum_line_details;
FETCH cur_get_lumpsum_line_details INTO l_total_distribution;
CLOSE cur_get_lumpsum_line_details;

IF l_lumpsum_offer.distribution_type = 'AMT' THEN
 IF l_lumpsum_offer.STATUS_CODE = 'PENDING' OR l_lumpsum_offer.STATUS_CODE = 'ACTIVE' THEN

  IF l_total_distribution <> l_lumpsum_offer.lumpsum_amount THEN
    FND_MESSAGE.SET_NAME('OZF','OZF_INVALID_DISTR_ACTIVE');
    Fnd_Msg_Pub.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 ELSE

  IF l_total_distribution > l_lumpsum_offer.lumpsum_amount THEN
    FND_MESSAGE.SET_NAME('OZF','OZF_INVALID_DISTRIBUTION');
    Fnd_Msg_Pub.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 END IF;

ELSIF  l_lumpsum_offer.distribution_type = '%' THEN

 IF l_lumpsum_offer.STATUS_CODE = 'PENDING' OR l_lumpsum_offer.STATUS_CODE = 'ACTIVE' THEN

  IF l_total_distribution <> 100 THEN
    FND_MESSAGE.SET_NAME('OZF','OZF_INVALID_DISTR_ACTIVE');
    Fnd_Msg_Pub.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


 ELSE

  IF l_total_distribution > 100 THEN
    FND_MESSAGE.SET_NAME('OZF','OZF_INVALID_DISTRIBUTION');
    Fnd_Msg_Pub.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 END IF;

END IF;

Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END;


-------------------------------------------------
-- Start of Comments
--
-- NAME
--   check_pg_reqd_items
--
-- PURPOSE
--   Checks the required items for Promotional goods offers
--
-- IN
--   p_modifier_line_tbl       IN   MODIFIER_LINE_TBL_TYPE
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--  x_error_location          OUT NUMBER
--
-- NOTES
--
-- HISTORY
--    Mon Aug 09 2004:5/30 PM RSSHARMA Created
-- End of Comments
-------------------------------------------------

PROCEDURE check_pg_reqd_items(
  x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,x_error_location        OUT NOCOPY  NUMBER
)
IS
BEGIN
  FOR i IN p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
    IF (p_modifier_line_tbl(i).PRODUCT_ATTR_VAL IS NULL OR p_modifier_line_tbl(i).PRODUCT_ATTR_VAL = FND_API.g_miss_char)
        OR
        ( p_modifier_line_tbl(i).PRODUCT_ATTR IS NULL OR p_modifier_line_tbl(i).PRODUCT_ATTR = FND_API.g_miss_char )
  THEN
     OZF_Utility_PVT.error_message('OZF_OFFR_ITEM_REQD');
     x_return_status := Fnd_Api.g_ret_sts_error;
  END IF;
  END LOOP;
END check_pg_reqd_items;


PROCEDURE process_promotional_goods
(
  x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,x_modifiers_tbl         OUT NOCOPY  qp_modifiers_pub.modifiers_tbl_type
 ,x_error_location        OUT NOCOPY  NUMBER
) IS

 l_api_version CONSTANT NUMBER       := 1.0;
 l_api_name    CONSTANT VARCHAR2(30) := 'process_promotional_goods';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 tiers_modifier_line_tbl  MODIFIER_LINE_TBL_TYPE;
 p_list_line_id  NUMBER;
 l_modifiers_tbl          Qp_Modifiers_Pub.modifiers_tbl_type;
 l_pricing_attr_tbl       Qp_Modifiers_Pub.pricing_attr_tbl_type;
 v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
 v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
 v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
 v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
 v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
 v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
 v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
 v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
 l_control_rec            qp_globals.control_rec_type;

 l_modifier_parent_index        NUMBER := 0;
 l_list_header_id        NUMBER;
 l_related_modifier_id   NUMBER := 0;

CURSOR cur_get_PRG_line_id(p_list_header_id NUMBER) IS
SELECT list_line_id
FROM   qp_list_lines
WHERE  list_header_id = p_list_header_id
  AND  list_line_type_code = 'PRG';

l_use_modifier_index   boolean;

 CURSOR cur_get_discount_level(p_list_header_id NUMBER) IS
 SELECT modifier_level_code
   FROM ozf_offers
  WHERE qp_list_header_id = p_list_header_id;

  l_discount_level VARCHAR2(30);
  l_pricing_phase_id NUMBER;

  CURSOR c_adv_options_exist(l_list_header_id NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM qp_list_lines
                  WHERE list_header_id = l_list_header_id);

  CURSOR c_adv_options(l_list_header_id NUMBER) IS
  SELECT pricing_phase_id,print_on_invoice_flag,incompatibility_grp_code,pricing_group_sequence,product_precedence
    FROM qp_list_lines
   WHERE list_header_id = l_list_header_id;

  l_adv_options_exist      NUMBER;

  CURSOR c_get_break_type(l_list_header_id NUMBER) IS
  SELECT break_type
    FROM ozf_offers
   WHERE qp_list_header_id = l_list_header_id;

 CURSOR cur_get_offer_enddate(p_list_header_id NUMBER) IS
 SELECT start_date_active, end_date_active
   FROM qp_list_headers_b
  WHERE list_header_id = p_list_header_id;

  l_break_type    VARCHAR2(30);
   l_end_date DATE;
   l_start_date DATE;
BEGIN
  x_return_status := Fnd_Api.g_ret_sts_success;

  l_list_header_id := p_modifier_line_tbl(p_modifier_line_tbl.first).list_header_id;

  OPEN cur_get_PRG_line_id(l_list_header_id);
  FETCH cur_get_prg_line_id INTO l_related_modifier_id;
  CLOSE cur_get_PRG_line_id;


    OPEN cur_get_offer_enddate(l_list_header_id);
    FETCH cur_get_offer_enddate into l_start_date, l_end_date;
    CLOSE cur_get_offer_enddate;

  IF nvl(l_related_modifier_id,0) = 0 THEN
    l_use_modifier_index := TRUE;
  ELSE
    l_use_modifier_index := FALSE;
  END IF;

  OPEN cur_get_discount_level(l_list_header_id);
  FETCH cur_get_discount_level into l_discount_level;
  CLOSE cur_get_discount_level;

  IF l_discount_level = 'LINEGROUP' THEN
    NULL;
  ELSIF l_discount_level = 'LINE' THEN
    NULL;
  ELSIF l_discount_level = 'ORDER' THEN
    NULL;
  ELSE
    l_discount_level   := 'LINEGROUP';
  END IF;

  OPEN c_get_break_type(l_list_header_id);
  FETCH c_get_break_type INTO l_break_type;
  CLOSE c_get_break_type;

  FOR i IN p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP

  IF p_modifier_line_tbl.exists(i) THEN

    l_modifiers_tbl(i).operation      := p_modifier_line_tbl(i).operation;
    l_modifiers_tbl(i).list_header_id := p_modifier_line_tbl(i).list_header_id;
    l_modifiers_tbl(i).list_line_id   := p_modifier_line_tbl(i).list_line_id;
    l_modifiers_tbl(i).override_flag  := 'N'; -- overriding is not supported

    IF p_modifier_line_tbl(i).operation = 'CREATE' THEN
      check_pg_reqd_items(
        x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_modifier_line_tbl     => p_modifier_line_tbl
       ,x_error_location        => x_error_location
      );
    IF x_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
    END IF;

    IF i = p_modifier_line_tbl.first and l_use_modifier_index = TRUE and p_modifier_line_tbl(i).list_line_type_code = 'RLTD' THEN
        l_modifier_parent_index := i;
        l_modifiers_tbl(i).list_line_type_code := 'PRG' ;
        l_modifiers_tbl(i).override_flag       := 'N'; -- overriding is not supported
       -- l_modifiers_tbl(i).rltd_modifier_grp_type := 'QUALIFIER';
        l_modifiers_tbl(i).rltd_modifier_grp_no   := 1;
        l_modifiers_tbl(i).price_break_type_code    := l_break_type;
        l_control_rec.process :=  FALSE;
      ELSIF p_modifier_line_tbl(i).list_line_type_code = 'RLTD' THEN
        l_control_rec.process :=  FALSE;
        l_modifiers_tbl(i).list_line_type_code    := p_modifier_line_tbl(i).list_line_type_code;
        l_modifiers_tbl(i).override_flag          := 'N'; -- overriding is not supported
        IF l_use_modifier_index = TRUE THEN
          l_modifiers_tbl(i).modifier_parent_index := l_modifier_parent_index;
        ELSE
          l_modifiers_tbl(i).from_rltd_modifier_id  := l_related_modifier_id;
        END IF;
          l_modifiers_tbl(i).rltd_modifier_grp_type := 'QUALIFIER';
          l_modifiers_tbl(i).rltd_modifier_grp_no   := 1;
          l_modifiers_tbl(i).price_break_type_code    := l_break_type;
      ELSIF p_modifier_line_tbl(i).list_line_type_code = 'DIS' THEN
        l_control_rec.process :=  TRUE;
        l_modifiers_tbl(i).list_line_type_code    := p_modifier_line_tbl(i).list_line_type_code;
        l_modifiers_tbl(i).override_flag          := 'N'; -- overriding is not supported
        l_modifiers_tbl(i).from_rltd_modifier_id  := l_related_modifier_id;
        l_modifiers_tbl(i).rltd_modifier_grp_type := 'BENEFIT';
        l_modifiers_tbl(i).rltd_modifier_grp_no   := 1;
      END IF;
      l_modifiers_tbl(i).proration_type_code      := 'N';
      l_modifiers_tbl(i).modifier_level_code      := l_discount_level;
      l_modifiers_tbl(i).automatic_flag           := 'Y';

      -- get advanced options
      OPEN c_adv_options_exist(p_modifier_line_tbl(1).list_header_id);
      FETCH c_adv_options_exist INTO l_adv_options_exist;
      CLOSE c_adv_options_exist;

      IF l_adv_options_exist IS NULL THEN
        IF l_discount_level = 'LINEGROUP' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 3 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 3;
--          END IF;
        ELSIF l_discount_level = 'LINE' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINE');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 2 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 2;
--          END IF;
        ELSIF l_discount_level = 'ORDER' THEN
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_ORDER');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 4 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 4;
--          END IF;
        ELSE
          l_modifiers_tbl(i).pricing_phase_id := FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP');
--          IF l_modifiers_tbl(i).pricing_phase_id <> 3 THEN
--            l_modifiers_tbl(i).pricing_phase_id := 3;
--          END IF;
        END IF;

        l_modifiers_tbl(i).print_on_invoice_flag := FND_PROFILE.value('OZF_PRINT_ON_INVOICE');
        l_modifiers_tbl(i).incompatibility_grp_code := FND_PROFILE.value('OZF_INCOMPATIBILITY_GROUP');

        IF l_discount_level <> 'ORDER' THEN
          l_modifiers_tbl(i).pricing_group_sequence := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
--          IF l_modifiers_tbl(i).pricing_group_sequence <> 1 THEN
--            l_modifiers_tbl(i).pricing_group_sequence   := 1;
--          END IF;
        END IF;

        l_modifiers_tbl(i).product_precedence := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');

      ELSE
        OPEN c_adv_options(p_modifier_line_tbl(1).list_header_id);
        FETCH c_adv_options INTO l_modifiers_tbl(i).pricing_phase_id,l_modifiers_tbl(i).print_on_invoice_flag,l_modifiers_tbl(i).incompatibility_grp_code,l_modifiers_tbl(i).pricing_group_sequence,l_modifiers_tbl(i).product_precedence;
        CLOSE c_adv_options;
      END IF;
      -- end advanced options

    END IF;

    l_modifiers_tbl(i).start_date_active           := p_modifier_line_tbl(i).start_date_active;
    l_modifiers_tbl(i).end_date_active             := p_modifier_line_tbl(i).end_date_active;
    l_modifiers_tbl(i).arithmetic_operator         := p_modifier_line_tbl(i).arithmetic_operator;
    l_modifiers_tbl(i).operand                     := p_modifier_line_tbl(i).operand;
    l_modifiers_tbl(i).benefit_limit               := p_modifier_line_tbl(i).benefit_limit;
    l_modifiers_tbl(i).benefit_price_list_line_id  := p_modifier_line_tbl(i).benefit_price_list_line_id;
    l_modifiers_tbl(i).benefit_qty                 := p_modifier_line_tbl(i).benefit_qty;
    l_modifiers_tbl(i).benefit_uom_code            := p_modifier_line_tbl(i).benefit_uom_code;
    l_pricing_attr_tbl(i).pricing_attribute_id       := p_modifier_line_tbl(i).pricing_attribute_id;
    l_pricing_attr_tbl(i).product_attribute_context  := 'ITEM';
    l_pricing_attr_tbl(i).product_attribute          := p_modifier_line_tbl(i).product_attr;
    l_pricing_attr_tbl(i).product_attr_value         := p_modifier_line_tbl(i).product_attr_val;

    /*IF p_modifier_line_tbl(i).list_line_type_code <> 'DIS' THEN
      IF p_modifier_line_tbl(i).product_uom_code is not null and p_modifier_line_tbl(i).product_uom_code <> FND_API.g_miss_char THEN
        l_pricing_attr_tbl(i).product_uom_code           := p_modifier_line_tbl(i).product_uom_code;
          l_pricing_attr_tbl(i).pricing_attribute_context  := 'VOLUME';
        l_pricing_attr_tbl(i).pricing_attribute          := p_modifier_line_tbl(i).pricing_attr;
        l_pricing_attr_tbl(i).pricing_attr_value_from    := p_modifier_line_tbl(i).pricing_attr_value_from;
        IF p_modifier_line_tbl(i).operation <> 'CREATE' THEN
          l_pricing_attr_tbl(i).pricing_attr_value_to      := p_modifier_line_tbl(i).pricing_attr_value_to;
        END IF;
        l_pricing_attr_tbl(i).comparison_operator_code   := 'BETWEEN';
      END IF;
    END IF;*/

    -- fix for bug 7321732.
       IF p_modifier_line_tbl(i).list_line_type_code <> 'DIS' THEN
    IF p_modifier_line_tbl(i).pricing_attr = 'PRICING_ATTRIBUTE10' THEN--if volume_type is qty
      IF p_modifier_line_tbl(i).product_uom_code is not null and p_modifier_line_tbl(i).product_uom_code <> FND_API.g_miss_char THEN
        l_pricing_attr_tbl(i).product_uom_code           := p_modifier_line_tbl(i).product_uom_code;
          l_pricing_attr_tbl(i).pricing_attribute_context  := 'VOLUME';
        l_pricing_attr_tbl(i).pricing_attribute          := p_modifier_line_tbl(i).pricing_attr;
        l_pricing_attr_tbl(i).pricing_attr_value_from    := p_modifier_line_tbl(i).pricing_attr_value_from;
        IF p_modifier_line_tbl(i).operation <> 'CREATE' THEN
          l_pricing_attr_tbl(i).pricing_attr_value_to      := p_modifier_line_tbl(i).pricing_attr_value_to;
        END IF;
        l_pricing_attr_tbl(i).comparison_operator_code   := 'BETWEEN';

      ELSIF (p_modifier_line_tbl(i).product_uom_code is null
                OR p_modifier_line_tbl(i).product_uom_code = FND_API.g_miss_char
            ) AND
           ((p_modifier_line_tbl(i).pricing_attr_value_from is not null
              AND p_modifier_line_tbl(i).pricing_attr_value_from <> FND_API.g_miss_num) OR
           (p_modifier_line_tbl(i).pricing_attr is not null
           AND p_modifier_line_tbl(i).pricing_attr <> FND_API.g_miss_char))
           THEN
          FND_MESSAGE.SET_NAME('OZF','OZF_UOM_QTY_REQD');

          Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE -- volume type is amount
        l_pricing_attr_tbl(i).product_uom_code           := p_modifier_line_tbl(i).product_uom_code;
          l_pricing_attr_tbl(i).pricing_attribute_context  := 'VOLUME';
        l_pricing_attr_tbl(i).pricing_attribute          := p_modifier_line_tbl(i).pricing_attr;
        l_pricing_attr_tbl(i).pricing_attr_value_from    := p_modifier_line_tbl(i).pricing_attr_value_from;
        IF p_modifier_line_tbl(i).operation <> 'CREATE' THEN
          l_pricing_attr_tbl(i).pricing_attr_value_to      := p_modifier_line_tbl(i).pricing_attr_value_to;
        END IF;
        l_pricing_attr_tbl(i).comparison_operator_code   := 'BETWEEN';
     END IF;
    END IF;

    l_pricing_attr_tbl(i).modifiers_index            := i;
    l_pricing_attr_tbl(i).list_line_id               := p_modifier_line_tbl(i).list_line_id;
    l_pricing_attr_tbl(i).operation                  := p_modifier_line_tbl(i).operation;

      IF p_modifier_line_tbl(i).inactive_flag = 'N' THEN
        IF l_start_date IS NOT NULL THEN
          l_modifiers_tbl(i).end_date_active := GREATEST(l_start_date, SYSDATE);
        ELSIF l_end_date IS NOT NULL THEN
          l_modifiers_tbl(i).end_date_active := LEAST(l_end_date, SYSDATE);
        ELSE
          l_modifiers_tbl(i).end_date_active := SYSDATE;
        END IF;
        --l_modifiers_tbl(i).end_date_active       := least(nvl(l_end_date,sysdate-1),sysdate);
      ELSE
        l_modifiers_tbl(i).end_date_active := p_modifier_line_tbl(i).end_date_active;
      END IF;

  END IF;

-- rssharma added flex field on 15-Apr-2003
   l_modifiers_tbl(i).attribute1        := p_modifier_line_tbl(i).attribute1;
   l_modifiers_tbl(i).attribute2        := p_modifier_line_tbl(i).attribute2;
   l_modifiers_tbl(i).attribute3        := p_modifier_line_tbl(i).attribute3;
   l_modifiers_tbl(i).attribute4        := p_modifier_line_tbl(i).attribute4;
   l_modifiers_tbl(i).attribute5        := p_modifier_line_tbl(i).attribute5;
   l_modifiers_tbl(i).attribute6        := p_modifier_line_tbl(i).attribute6;
   l_modifiers_tbl(i).attribute7        := p_modifier_line_tbl(i).attribute7;
   l_modifiers_tbl(i).attribute8        := p_modifier_line_tbl(i).attribute8;
   l_modifiers_tbl(i).attribute9        := p_modifier_line_tbl(i).attribute9;
   l_modifiers_tbl(i).attribute10       := p_modifier_line_tbl(i).attribute10;
   l_modifiers_tbl(i).attribute11       := p_modifier_line_tbl(i).attribute11;
   l_modifiers_tbl(i).attribute12       := p_modifier_line_tbl(i).attribute12;
   l_modifiers_tbl(i).attribute13       := p_modifier_line_tbl(i).attribute13;
   l_modifiers_tbl(i).attribute14       := p_modifier_line_tbl(i).attribute14;
   l_modifiers_tbl(i).attribute15       := p_modifier_line_tbl(i).attribute15;
   l_modifiers_tbl(i).context       := p_modifier_line_tbl(i).context;
-- end change on 15-Apr-2003

END LOOP;

QP_Modifiers_GRP.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      p_commit                 => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_control_rec            => l_control_rec,
      p_modifiers_tbl          => l_modifiers_tbl,
      p_pricing_attr_tbl       => l_pricing_attr_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );
x_modifiers_tbl := v_modifiers_tbl;
 IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
   IF v_modifiers_tbl.COUNT > 0 THEN
    FOR k IN v_modifiers_tbl.first..v_modifiers_tbl.last LOOP
     IF v_modifiers_tbl.EXISTS(k) THEN
        IF v_modifiers_tbl(k).return_status <> Fnd_Api.g_ret_sts_success THEN
          x_error_location := k;
          EXIT;
    END IF;
      END IF;
    END LOOP;
   END IF;
 END IF;

 IF x_return_status = Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;

 FOR limit_index in p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP

  IF p_modifier_line_tbl.exists(limit_index) THEN

   IF p_modifier_line_tbl(limit_index).operation = 'CREATE' THEN
     p_list_line_id := v_modifiers_tbl(limit_index).list_line_id;
   ELSE
     p_list_line_id := p_modifier_line_tbl(limit_index).list_line_id;
   END IF;

    IF p_modifier_line_tbl(limit_index).list_line_type_code = 'DIS' THEN
       process_limits
       (
        x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_limit_type        =>'MAX_QTY_PER_ORDER'
       ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_qty_per_order
       ,p_list_line_id      => p_list_line_id
       ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
       ,p_limit_id          => p_modifier_line_tbl(limit_index).max_qty_per_order_id
       );

     IF x_return_status = Fnd_Api.g_ret_sts_error THEN
        x_error_location := limit_index;
      RAISE Fnd_Api.g_exc_error;
     ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      x_error_location := limit_index;
      RAISE Fnd_Api.g_exc_unexpected_error;
     END IF;


       process_limits
       (
        x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_limit_type        =>'MAX_QTY_PER_CUSTOMER'
       ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_qty_per_customer
       ,p_list_line_id      => p_list_line_id
       ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
       ,p_limit_id          => p_modifier_line_tbl(limit_index).max_qty_per_customer_id
       );

     IF x_return_status = Fnd_Api.g_ret_sts_error THEN
          x_error_location := limit_index;
       RAISE Fnd_Api.g_exc_error;
     ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         x_error_location := limit_index;
       RAISE Fnd_Api.g_exc_unexpected_error;
     END IF;

     process_limits
       (
        x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_limit_type        =>'MAX_QTY_PER_RULE'
       ,p_limit_amount      => p_modifier_line_tbl(limit_index).max_qty_per_rule
       ,p_list_line_id      => p_list_line_id
       ,p_list_header_id    => p_modifier_line_tbl(limit_index).list_header_id
       ,p_limit_id          => p_modifier_line_tbl(limit_index).max_qty_per_rule_id
       );

     IF x_return_status = Fnd_Api.g_ret_sts_error THEN
         x_error_location := limit_index;
       RAISE Fnd_Api.g_exc_error;
     ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         x_error_location := limit_index;
       RAISE Fnd_Api.g_exc_unexpected_error;
     END IF;


    END IF;


  END IF;
 END LOOP;

    Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END;

PROCEDURE process_trade_deal
(
  x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,p_list_header_id        IN  NUMBER
 , x_modifiers_tbl       OUT NOCOPY qp_modifiers_pub.modifiers_tbl_type
 ,x_error_location        OUT NOCOPY NUMBER
) IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'process_trade_deal';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_modifier_line_tbl       MODIFIER_LINE_TBL_TYPE := p_modifier_line_tbl;
  v_off_modifiers_tbl       qp_modifiers_pub.modifiers_tbl_type;
  v_accr_modifiers_tbl      qp_modifiers_pub.modifiers_tbl_type;
  temp_modifier_line_tbl    MODIFIER_LINE_TBL_TYPE := p_modifier_line_tbl;

  l_modifier_line_all_off_tbl   MODIFIER_LINE_TBL_TYPE; -- line has both off_invoice and accrual values, off_invoice
  l_modifier_line_all_acc_tbl   MODIFIER_LINE_TBL_TYPE; -- line has both off_invoice and accrual values, accural
  l_modifier_line_off_tbl   MODIFIER_LINE_TBL_TYPE;     -- line has only off_invoice value
  l_modifier_line_acc_tbl   MODIFIER_LINE_TBL_TYPE;     -- line has only accrual value
  v_modifier_all_off_tbl    qp_modifiers_pub.modifiers_tbl_type;
  v_modifier_all_acc_tbl    qp_modifiers_pub.modifiers_tbl_type;
  v_modifier_off_tbl        qp_modifiers_pub.modifiers_tbl_type;
  v_modifier_acc_tbl        qp_modifiers_pub.modifiers_tbl_type;
  v_modifier_ret_tbl        qp_modifiers_pub.modifiers_tbl_type;
 l_related_lines_rec      ozf_related_lines_pvt.related_lines_rec_type;
 l_related_deal_lines_id  NUMBER;
 l_all_index NUMBER := 0;
 l_off_index NUMBER := 0;
 l_acc_index NUMBER := 0;
 l_index     NUMBER := 0;
 l_modifier_id NUMBER;
 l_related_modifier_id NUMBER;

 CURSOR get_accr_pricing_attribute_id (p_list_line_id NUMBER) IS
 SELECT pricing_attribute_id
   FROM qp_pricing_attributes
  WHERE list_line_id = p_list_line_id
    AND excluder_flag = 'N';

l_object_version_number NUMBER;

l_accr_qty_limit_id NUMBER;
l_accr_amount_limit_id NUMBER;

CURSOR cur_get_accrual_limit_id(p_limit_number NUMBER,p_list_line_id NUMBER) IS
SELECT limit_id
  FROM qp_limits
 WHERE limit_number = p_limit_number
   AND list_line_id = p_list_line_id;

  CURSOR c_modifier_id(l_id NUMBER) IS
  SELECT modifier_id, related_modifier_id
    FROM ozf_related_deal_lines
   WHERE related_deal_lines_id = l_id;

  CURSOR c_creation(l_id NUMBER) IS
  SELECT creation_date, created_by
    FROM ozf_related_deal_lines
   WHERE related_deal_lines_id = l_id;

BEGIN
  x_return_status := Fnd_Api.g_ret_sts_success;
  IF p_modifier_line_tbl.count > 0 THEN
    FOR i IN p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
      IF p_modifier_line_tbl.exists(i) THEN
        IF p_modifier_line_tbl(i).max_amount_per_rule IS NOT NULL
        AND p_modifier_line_tbl(i).max_amount_per_rule <> FND_API.G_MISS_NUM
        AND p_modifier_line_tbl(i).max_amount_per_rule <= 0 THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.SET_NAME('OZF','OZF_TRD_DEAL_NEG_AMT');
            Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.g_exc_error;
        END IF;

        IF p_modifier_line_tbl(i).max_qty_per_rule IS NOT NULL
        AND p_modifier_line_tbl(i).max_qty_per_rule <> FND_API.G_MISS_NUM
        AND p_modifier_line_tbl(i).max_qty_per_rule <= 0 THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.SET_NAME('OZF','OZF_TRD_DEAL_NEG_QTY');
            Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.g_exc_error;
        END IF;
      END IF;
    END LOOP;

    l_modifier_line_tbl.delete;
    FOR i IN p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
      IF p_modifier_line_tbl.exists(i) THEN
        IF p_modifier_line_tbl(i).operation <> FND_API.g_miss_char THEN

          IF ((p_modifier_line_tbl(i).operand IS NULL OR p_modifier_line_tbl(i).operand = FND_API.g_miss_num)
          OR (p_modifier_line_tbl(i).arithmetic_operator IS NULL OR p_modifier_line_tbl(i).arithmetic_operator = FND_API.g_miss_char))
          AND ((p_modifier_line_tbl(i).qd_operand IS NULL OR p_modifier_line_tbl(i).qd_operand = FND_API.g_miss_num)
          OR (p_modifier_line_tbl(i).qd_arithmetic_operator IS NULL OR p_modifier_line_tbl(i).qd_arithmetic_operator = FND_API.g_miss_char)) THEN
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.SET_NAME('OZF','OZF_TRD_DEAL_NO_OPERAND');
              Fnd_Msg_Pub.ADD;
            END IF;
            RAISE Fnd_Api.g_exc_error;

          ELSIF ((p_modifier_line_tbl(i).operand IS NOT NULL AND p_modifier_line_tbl(i).operand <> FND_API.g_miss_num)
          AND (p_modifier_line_tbl(i).arithmetic_operator IS NOT NULL AND p_modifier_line_tbl(i).arithmetic_operator <> FND_API.g_miss_char))
          AND ((p_modifier_line_tbl(i).qd_operand IS NOT NULL AND p_modifier_line_tbl(i).qd_operand <> FND_API.g_miss_num)
          AND (p_modifier_line_tbl(i).qd_arithmetic_operator IS NOT NULL AND p_modifier_line_tbl(i).qd_arithmetic_operator <> FND_API.g_miss_char)) THEN
            l_all_index := l_all_index + 1;
            l_modifier_line_all_off_tbl(l_all_index) := p_modifier_line_tbl(i);
            l_modifier_line_all_acc_tbl(l_all_index) := p_modifier_line_tbl(i);

            l_modifier_line_all_acc_tbl(l_all_index).list_line_id := p_modifier_line_tbl(i).qd_list_line_id;
            l_modifier_line_all_acc_tbl(l_all_index).operand := p_modifier_line_tbl(i).qd_operand;
            l_modifier_line_all_acc_tbl(l_all_index).arithmetic_operator := p_modifier_line_tbl(i).qd_arithmetic_operator;

            IF p_modifier_line_tbl(i).list_line_id IS NULL OR p_modifier_line_tbl(i).list_line_id = FND_API.g_miss_num THEN
              l_modifier_line_all_off_tbl(l_all_index).operation := 'CREATE';
              l_modifier_line_all_off_tbl(l_all_index).list_line_id := FND_API.g_miss_num;
              l_modifier_line_all_off_tbl(l_all_index).pricing_attribute_id := FND_API.g_miss_num;
            END IF;

            IF p_modifier_line_tbl(i).qd_list_line_id IS NULL OR p_modifier_line_tbl(i).qd_list_line_id = FND_API.g_miss_num THEN
              l_modifier_line_all_acc_tbl(l_all_index).operation := 'CREATE';
              l_modifier_line_all_acc_tbl(l_all_index).list_line_id := FND_API.g_miss_num;
              l_modifier_line_all_acc_tbl(l_all_index).pricing_attribute_id := FND_API.g_miss_num;
            END IF;

--            l_modifier_line_tbl(i) := p_modifier_line_tbl(i);
            l_index := l_index + 1;

            IF l_modifier_line_all_acc_tbl(l_all_index).operation = 'UPDATE' THEN
              OPEN get_accr_pricing_attribute_id(l_modifier_line_all_acc_tbl(l_all_index).list_line_id);
              FETCH get_accr_pricing_attribute_id into l_modifier_line_all_acc_tbl(l_all_index).pricing_attribute_id;
              CLOSE get_accr_pricing_attribute_id;
            END IF;

          ELSIF ((p_modifier_line_tbl(i).operand IS NOT NULL AND p_modifier_line_tbl(i).operand <> FND_API.g_miss_num)
          AND (p_modifier_line_tbl(i).arithmetic_operator IS NOT NULL AND p_modifier_line_tbl(i).arithmetic_operator <> FND_API.g_miss_char))
          AND ((p_modifier_line_tbl(i).qd_operand IS NULL OR p_modifier_line_tbl(i).qd_operand = FND_API.g_miss_num)
          OR (p_modifier_line_tbl(i).qd_arithmetic_operator IS NULL OR p_modifier_line_tbl(i).qd_arithmetic_operator = FND_API.g_miss_char)) THEN
            -- fix for bug 7321745
            OPEN c_modifier_id(p_modifier_line_tbl(i).qd_related_deal_lines_id);
            FETCH c_modifier_id INTO l_modifier_id,l_related_modifier_id;
            CLOSE c_modifier_id;

            IF l_related_modifier_id IS NOT NULL THEN
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.SET_NAME('OZF','OZF_TRD_DEAL_NO_ACC_OPERAND');
              Fnd_Msg_Pub.ADD;
              x_error_location := i;
            END IF;
            RAISE Fnd_Api.g_exc_error;
            END IF;

            l_off_index := l_off_index + 1;
            l_modifier_line_off_tbl(l_off_index) := p_modifier_line_tbl(i);
            l_index := l_index + 1;
--            l_modifier_line_tbl(l_index) := p_modifier_line_tbl(i);

            IF p_modifier_line_tbl(i).list_line_id IS NULL OR p_modifier_line_tbl(i).list_line_id = FND_API.g_miss_num THEN
              l_modifier_line_off_tbl(l_off_index).operation := 'CREATE';
              l_modifier_line_off_tbl(l_off_index).list_line_id := FND_API.g_miss_num;
              l_modifier_line_off_tbl(l_off_index).pricing_attribute_id := FND_API.g_miss_num;
            END IF;

          ELSIF ((p_modifier_line_tbl(i).qd_operand IS NOT NULL AND p_modifier_line_tbl(i).qd_operand <> FND_API.g_miss_num)
          AND (p_modifier_line_tbl(i).qd_arithmetic_operator IS NOT NULL AND p_modifier_line_tbl(i).qd_arithmetic_operator <> FND_API.g_miss_char))
          AND ((p_modifier_line_tbl(i).operand IS NULL OR p_modifier_line_tbl(i).operand = FND_API.g_miss_num)
          OR (p_modifier_line_tbl(i).arithmetic_operator IS NULL OR p_modifier_line_tbl(i).arithmetic_operator = FND_API.g_miss_char)) THEN

            -- fix for bug 7321745

            OPEN c_modifier_id(p_modifier_line_tbl(i).qd_related_deal_lines_id);
            FETCH c_modifier_id INTO l_modifier_id,l_related_modifier_id;
            CLOSE c_modifier_id;

            IF l_modifier_id IS NOT NULL AND l_related_modifier_id IS NOT NULL THEN
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.SET_NAME('OZF','OZF_TRD_DEAL_NO_OFF_OPERAND');
              Fnd_Msg_Pub.ADD;
              x_error_location := i;
            END IF;
            RAISE Fnd_Api.g_exc_error;
            END IF;

            l_acc_index := l_acc_index + 1;
            l_modifier_line_acc_tbl(l_acc_index) := p_modifier_line_tbl(i);

            l_modifier_line_acc_tbl(l_acc_index).list_line_id := p_modifier_line_tbl(i).qd_list_line_id;
            l_modifier_line_acc_tbl(l_acc_index).operand := p_modifier_line_tbl(i).qd_operand;
            l_modifier_line_acc_tbl(l_acc_index).arithmetic_operator := p_modifier_line_tbl(i).qd_arithmetic_operator;

            l_index := l_index + 1;
--            l_modifier_line_tbl(l_index) := p_modifier_line_tbl(i);

            IF p_modifier_line_tbl(i).qd_list_line_id IS NULL OR p_modifier_line_tbl(i).qd_list_line_id = FND_API.g_miss_num THEN
              l_modifier_line_acc_tbl(l_acc_index).operation := 'CREATE';
              l_modifier_line_acc_tbl(l_acc_index).list_line_id := FND_API.g_miss_num;
              l_modifier_line_acc_tbl(l_acc_index).pricing_attribute_id := FND_API.g_miss_num;
            END IF;

            IF l_modifier_line_acc_tbl(l_acc_index).operation = 'UPDATE' THEN
              OPEN get_accr_pricing_attribute_id(l_modifier_line_acc_tbl(l_acc_index).list_line_id);
              FETCH get_accr_pricing_attribute_id into l_modifier_line_acc_tbl(l_acc_index).pricing_attribute_id;
              CLOSE get_accr_pricing_attribute_id;
            END IF;
          END IF;

        END IF;
      END IF;
--dbms_output.put_line('table count is :'||l_modifier_line_tbl.count);
-- rssharma added flex field on 15-Apr-2003
/*   l_modifier_line_all_off_tbl(i).attribute1        := p_modifier_line_tbl(i).attribute1;
   l_modifier_line_all_off_tbl(i).attribute2        := p_modifier_line_tbl(i).attribute2;
   l_modifier_line_all_off_tbl(i).attribute3        := p_modifier_line_tbl(i).attribute3;
   l_modifier_line_all_off_tbl(i).attribute4        := p_modifier_line_tbl(i).attribute4;
   l_modifier_line_all_off_tbl(i).attribute5        := p_modifier_line_tbl(i).attribute5;
   l_modifier_line_all_off_tbl(i).attribute6        := p_modifier_line_tbl(i).attribute6;
   l_modifier_line_all_off_tbl(i).attribute7        := p_modifier_line_tbl(i).attribute7;
   l_modifier_line_all_off_tbl(i).attribute8        := p_modifier_line_tbl(i).attribute8;
   l_modifier_line_all_off_tbl(i).attribute9        := p_modifier_line_tbl(i).attribute9;
   l_modifier_line_all_off_tbl(i).attribute10       := p_modifier_line_tbl(i).attribute10;
   l_modifier_line_all_off_tbl(i).attribute11       := p_modifier_line_tbl(i).attribute11;
   l_modifier_line_all_off_tbl(i).attribute12       := p_modifier_line_tbl(i).attribute12;
   l_modifier_line_all_off_tbl(i).attribute13       := p_modifier_line_tbl(i).attribute13;
   l_modifier_line_all_off_tbl(i).attribute14       := p_modifier_line_tbl(i).attribute14;
   l_modifier_line_all_off_tbl(i).attribute15       := p_modifier_line_tbl(i).attribute15;
   l_modifier_line_all_off_tbl(i).context       := p_modifier_line_tbl(i).context;

   l_modifier_line_acc_tbl(i).attribute1        := p_modifier_line_tbl(i).attribute1;
   l_modifier_line_acc_tbl(i).attribute2        := p_modifier_line_tbl(i).attribute2;
   l_modifier_line_acc_tbl(i).attribute3        := p_modifier_line_tbl(i).attribute3;
   l_modifier_line_acc_tbl(i).attribute4        := p_modifier_line_tbl(i).attribute4;
   l_modifier_line_acc_tbl(i).attribute5        := p_modifier_line_tbl(i).attribute5;
   l_modifier_line_acc_tbl(i).attribute6        := p_modifier_line_tbl(i).attribute6;
   l_modifier_line_acc_tbl(i).attribute7        := p_modifier_line_tbl(i).attribute7;
   l_modifier_line_acc_tbl(i).attribute8        := p_modifier_line_tbl(i).attribute8;
   l_modifier_line_acc_tbl(i).attribute9        := p_modifier_line_tbl(i).attribute9;
   l_modifier_line_acc_tbl(i).attribute10       := p_modifier_line_tbl(i).attribute10;
   l_modifier_line_acc_tbl(i).attribute11       := p_modifier_line_tbl(i).attribute11;
   l_modifier_line_acc_tbl(i).attribute12       := p_modifier_line_tbl(i).attribute12;
   l_modifier_line_acc_tbl(i).attribute13       := p_modifier_line_tbl(i).attribute13;
   l_modifier_line_acc_tbl(i).attribute14       := p_modifier_line_tbl(i).attribute14;
   l_modifier_line_acc_tbl(i).attribute15       := p_modifier_line_tbl(i).attribute15;
   l_modifier_line_acc_tbl(i).context       := p_modifier_line_tbl(i).context;
*/
-- end change on 15-Apr-2003

    END LOOP;

    IF l_modifier_line_all_off_tbl.count > 0 THEN
      process_regular_discounts
      (
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
          p_parent_offer_type    => 'DEAL',
        p_offer_type           => 'OFF_INVOICE',
        p_modifier_line_tbl    => l_modifier_line_all_off_tbl,
        x_modifiers_tbl        => v_modifier_all_off_tbl,
        x_error_location       => x_error_location
      );

      IF x_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    END IF;
    IF l_modifier_line_off_tbl.count > 0 THEN
      process_regular_discounts
      (
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
          p_parent_offer_type    => 'DEAL',
        p_offer_type           => 'OFF_INVOICE',
        p_modifier_line_tbl    => l_modifier_line_off_tbl,
        x_modifiers_tbl        => v_modifier_off_tbl,
        x_error_location       => x_error_location
      );

      IF x_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

    END IF;

    IF l_modifier_line_all_acc_tbl.count > 0 THEN
      process_regular_discounts
      (
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_parent_offer_type    => 'DEAL',
        p_offer_type           => 'ACCRUAL',
        p_modifier_line_tbl    => l_modifier_line_all_acc_tbl,
        x_modifiers_tbl        => v_modifier_all_acc_tbl,
        x_error_location       => x_error_location
      );

      IF x_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF l_modifier_line_acc_tbl.count > 0 THEN
      process_regular_discounts
      (
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_parent_offer_type    => 'DEAL',
        p_offer_type           => 'ACCRUAL',
        p_modifier_line_tbl    => l_modifier_line_acc_tbl,
        x_modifiers_tbl        => v_modifier_acc_tbl,
        x_error_location       => x_error_location
      );

      IF x_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    END IF;

/*
v_modifier_all_off_tbl
v_modifier_off_tbl
v_modifier_all_acc_tbl
v_modifier_acc_tbl
*/
v_modifier_ret_tbl.delete;
IF nvl(v_modifier_all_off_tbl.count,0) > 0 THEN
    FOR i in v_modifier_all_off_tbl.first .. v_modifier_all_off_tbl.last LOOP
        v_modifier_ret_tbl(nvl(v_modifier_ret_tbl.count,0)+1) := v_modifier_all_off_tbl(i);
    END LOOP;
END IF;
IF nvl(v_modifier_off_tbl.count,0) > 0 THEN
    FOR i in v_modifier_off_tbl.first .. v_modifier_off_tbl.last LOOP
            v_modifier_ret_tbl(nvl(v_modifier_ret_tbl.count,0)+1) := v_modifier_off_tbl(i);
    END LOOP;
END IF;
IF nvl(v_modifier_all_acc_tbl.count,0) > 0 THEN
    FOR i in v_modifier_all_acc_tbl.first .. v_modifier_all_acc_tbl.last LOOP
        v_modifier_ret_tbl(nvl(v_modifier_ret_tbl.count,0)+1) := v_modifier_all_acc_tbl(i);
    END LOOP;
END IF;
IF nvl(v_modifier_acc_tbl.count,0) > 0 THEN
    FOR i in v_modifier_acc_tbl.first .. v_modifier_acc_tbl.last LOOP
            v_modifier_ret_tbl(nvl(v_modifier_ret_tbl.count,0)+1) := v_modifier_acc_tbl(i);
    END LOOP;
END IF;

    l_all_index := 0;
    l_off_index := 0;
    l_acc_index := 0;
/*
Fixed issues in updating Trade Deal Discount lines
*/
    FOR i IN p_modifier_line_tbl.first..p_modifier_line_tbl.last LOOP
      IF p_modifier_line_tbl.exists(i) THEN
        l_modifier_line_tbl(i) := p_modifier_line_tbl(i);
--        --dbms_output.put_line('i:'||i||' : Operation :'||p_modifier_line_tbl(i).operation);
        IF ((p_modifier_line_tbl(i).operand IS NOT NULL AND p_modifier_line_tbl(i).operand <> FND_API.g_miss_num)
        AND (p_modifier_line_tbl(i).arithmetic_operator IS NOT NULL AND p_modifier_line_tbl(i).arithmetic_operator <> FND_API.g_miss_char))
        AND ((p_modifier_line_tbl(i).qd_operand IS NOT NULL AND p_modifier_line_tbl(i).qd_operand <> FND_API.g_miss_num)
        AND (p_modifier_line_tbl(i).qd_arithmetic_operator IS NOT NULL AND p_modifier_line_tbl(i).qd_arithmetic_operator <> FND_API.g_miss_char)) THEN
          l_all_index := l_all_index + 1;
          l_modifier_line_tbl(i).list_line_id := v_modifier_all_off_tbl(l_all_index).list_line_id;
          l_modifier_line_tbl(i).qd_list_line_id := v_modifier_all_acc_tbl(l_all_index).list_line_id;
--          --dbms_output.put_line('All  :listlineId'||l_modifier_line_tbl(i).list_line_id || ' td id : '||l_modifier_line_tbl(i).qd_list_line_id);
        ELSIF ((p_modifier_line_tbl(i).operand IS NOT NULL AND p_modifier_line_tbl(i).operand <> FND_API.g_miss_num)
        AND (p_modifier_line_tbl(i).arithmetic_operator IS NOT NULL AND p_modifier_line_tbl(i).arithmetic_operator <> FND_API.g_miss_char))
        AND ((p_modifier_line_tbl(i).qd_operand IS NULL OR p_modifier_line_tbl(i).qd_operand = FND_API.g_miss_num)
        OR (p_modifier_line_tbl(i).qd_arithmetic_operator IS NULL OR p_modifier_line_tbl(i).qd_arithmetic_operator = FND_API.g_miss_char)) THEN
          l_off_index := l_off_index + 1;
          l_modifier_line_tbl(i).list_line_id := v_modifier_off_tbl(l_off_index).list_line_id;
          l_modifier_line_tbl(i).qd_list_line_id := null;
--          --dbms_output.put_line('Off  :listlineId'||l_modifier_line_tbl(i).list_line_id || ' td id : '||l_modifier_line_tbl(i).qd_list_line_id);
        ELSIF ((p_modifier_line_tbl(i).qd_operand IS NOT NULL AND p_modifier_line_tbl(i).qd_operand <> FND_API.g_miss_num)
        AND (p_modifier_line_tbl(i).qd_arithmetic_operator IS NOT NULL AND p_modifier_line_tbl(i).qd_arithmetic_operator <> FND_API.g_miss_char))
        AND ((p_modifier_line_tbl(i).operand IS NULL OR p_modifier_line_tbl(i).operand = FND_API.g_miss_num)
        OR (p_modifier_line_tbl(i).arithmetic_operator IS NULL OR p_modifier_line_tbl(i).arithmetic_operator = FND_API.g_miss_char)) THEN
          l_acc_index := l_acc_index + 1;
          l_modifier_line_tbl(i).qd_list_line_id := v_modifier_acc_tbl(l_acc_index).list_line_id;
          l_modifier_line_tbl(i).list_line_id := null;
--          --dbms_output.put_line('Acc  :listlineId'||l_modifier_line_tbl(i).list_line_id || ' td id : '||l_modifier_line_tbl(i).qd_list_line_id);
        END IF;
      END IF;
    END LOOP;
    -- Call Related Deal Lines and establish the relation ship.
    -- and push estimated_max if estimated is not equal to max.
    FOR i IN l_modifier_line_tbl.first..l_modifier_line_tbl.last LOOP
      IF l_modifier_line_tbl.exists(i) THEN
        IF  l_modifier_line_tbl(i).operation <> FND_API.g_miss_char THEN

          IF (l_modifier_line_tbl(i).max_qty_per_rule IS NULL OR l_modifier_line_tbl(i).max_qty_per_rule = FND_API.G_MISS_NUM)
          AND l_modifier_line_tbl(i).qd_estimated_qty_is_max = 'Y' THEN
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.SET_NAME('OZF','OZF_TRD_DEAL_NO_QTY');
              Fnd_Msg_Pub.ADD;
            END IF;
            RAISE Fnd_Api.g_exc_error;
          END IF;

          IF (l_modifier_line_tbl(i).max_amount_per_rule IS NULL OR l_modifier_line_tbl(i).max_amount_per_rule = FND_API.G_MISS_NUM)
          AND l_modifier_line_tbl(i).qd_estimated_amount_is_max = 'Y' THEN
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.SET_NAME('OZF', 'OZF_TRD_DEAL_NO_AMT');
              Fnd_Msg_Pub.ADD;
            END IF;
            RAISE Fnd_Api.g_exc_error;
          END IF;

          l_related_lines_rec := NULL;
          l_related_lines_rec.qp_list_header_id         := l_modifier_line_tbl(i).list_header_id;

          IF l_modifier_line_tbl(i).operation = 'CREATE' THEN
            IF l_modifier_line_tbl(i).list_line_id IS NOT NULL AND l_modifier_line_tbl(i).list_line_id <> FND_API.g_miss_num THEN
              l_related_lines_rec.modifier_id := l_modifier_line_tbl(i).list_line_id;
              IF l_modifier_line_tbl(i).qd_list_line_id IS NOT NULL AND l_modifier_line_tbl(i).qd_list_line_id <> FND_API.g_miss_num THEN
                l_related_lines_rec.related_modifier_id := l_modifier_line_tbl(i).qd_list_line_id;
              END IF;
            ELSE
              l_related_lines_rec.modifier_id := l_modifier_line_tbl(i).qd_list_line_id;
            END IF;
          ELSE
            l_related_lines_rec.related_deal_lines_id := l_modifier_line_tbl(i).qd_related_deal_lines_id;
            OPEN c_modifier_id(l_related_lines_rec.related_deal_lines_id);
            FETCH c_modifier_id INTO l_modifier_id,l_related_modifier_id;
            CLOSE c_modifier_id;

            IF l_modifier_id = l_modifier_line_tbl(i).list_line_id THEN
              l_related_lines_rec.modifier_id := l_modifier_line_tbl(i).list_line_id;
              l_related_lines_rec.related_modifier_id := l_modifier_line_tbl(i).qd_list_line_id;
            ELSIF l_modifier_id = l_modifier_line_tbl(i).qd_list_line_id THEN
              l_related_lines_rec.modifier_id := l_modifier_line_tbl(i).qd_list_line_id;
              l_related_lines_rec.related_modifier_id := l_modifier_line_tbl(i).list_line_id;
            END IF;

            l_related_lines_rec.object_version_number := l_modifier_line_tbl(i).qd_object_version_number;
          END IF;

          l_related_lines_rec.estimated_qty_is_max := l_modifier_line_tbl(i).qd_estimated_qty_is_max;
          l_related_lines_rec.estimated_amount_is_max := l_modifier_line_tbl(i).qd_estimated_amount_is_max;
          l_related_lines_rec.estimated_qty := l_modifier_line_tbl(i).max_qty_per_rule;
          l_related_lines_rec.estimated_amount := l_modifier_line_tbl(i).max_amount_per_rule;
          l_related_lines_rec.estimate_qty_uom := l_modifier_line_tbl(i).estimate_qty_uom;

          IF  l_modifier_line_tbl(i).operation = 'CREATE' THEN
            OZF_Related_Lines_PVT.Create_related_lines
            (
             p_api_version_number       => 1.0
            ,x_return_status            => x_return_Status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
            ,p_related_lines_rec        => l_related_lines_rec
            ,x_related_deal_lines_id    => l_related_deal_lines_id
            );

          ELSIF l_modifier_line_tbl(i).operation = 'UPDATE' THEN
            OPEN c_creation(l_related_lines_rec.related_deal_lines_id);
            FETCH c_creation INTO l_related_lines_rec.creation_date,l_related_lines_rec.created_by;
            CLOSE c_creation;
            OZF_Related_Lines_PVT.update_related_lines
            (
             p_api_version_number     => 1.0
            ,x_return_status          => x_return_Status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
            ,p_related_lines_rec      => l_related_lines_rec
            ,x_object_version_number  => l_object_version_number
            );
          END IF;

          IF x_return_status = Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;

        END IF;
      END IF;
    END LOOP;

  END IF;

  -- process limits
  FOR limit_index IN l_modifier_line_tbl.first..l_modifier_line_tbl.last LOOP
    IF l_modifier_line_tbl.exists(limit_index) THEN
      IF  l_modifier_line_tbl(limit_index).operation <> FND_API.g_miss_char THEN
          IF  l_modifier_line_tbl(limit_index).qd_estimated_qty_is_max = 'Y' THEN
            IF l_modifier_line_tbl(limit_index).list_line_id IS NOT NULL
          AND l_modifier_line_tbl(limit_index).list_line_id <> FND_API.G_MISS_NUM THEN
            process_limits
            (
              x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
             ,p_limit_type        =>'MAX_QTY_PER_RULE'
             ,p_limit_amount      => l_modifier_line_tbl(limit_index).max_qty_per_rule
             ,p_list_line_id      => l_modifier_line_tbl(limit_index).list_line_id
             ,p_list_header_id    => l_modifier_line_tbl(limit_index).list_header_id
             ,p_limit_id          => l_modifier_line_tbl(limit_index).max_qty_per_rule_id
            );

            IF x_return_status = Fnd_Api.g_ret_sts_error THEN
              x_error_location := limit_index;
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              x_error_location := limit_index;
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
          END IF;

          IF l_modifier_line_tbl(limit_index).qd_list_line_id IS NOT NULL
          AND l_modifier_line_tbl(limit_index).qd_list_line_id <> FND_API.G_MISS_NUM THEN

            OPEN cur_get_accrual_limit_id(3,l_modifier_line_tbl(limit_index).qd_list_line_id);
            FETCH cur_get_accrual_limit_id into l_accr_qty_limit_id;
              CLOSE cur_get_accrual_limit_id;

            process_limits
            (
             x_return_status     => x_return_status
            ,x_msg_count         => x_msg_count
            ,x_msg_data          => x_msg_data
            ,p_limit_type        =>'MAX_QTY_PER_RULE'
            ,p_limit_amount      => l_modifier_line_tbl(limit_index).max_qty_per_rule
            ,p_list_line_id      => l_modifier_line_tbl(limit_index).qd_list_line_id
            ,p_list_header_id    => l_modifier_line_tbl(limit_index).list_header_id
            ,p_limit_id          => l_accr_qty_limit_id
            );

            IF x_return_status = Fnd_Api.g_ret_sts_error THEN
              x_error_location := limit_index;
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              x_error_location := limit_index;
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
          END IF;
        END IF;

        IF  l_modifier_line_tbl(limit_index).qd_estimated_amount_is_max = 'Y' THEN
          IF l_modifier_line_tbl(limit_index).list_line_id IS NOT NULL
          AND l_modifier_line_tbl(limit_index).list_line_id  <> FND_API.G_MISS_NUM THEN
            process_limits
            (
             x_return_status     => x_return_status
            ,x_msg_count         => x_msg_count
            ,x_msg_data          => x_msg_data
            ,p_limit_type        =>'MAX_AMOUNT_PER_RULE'
            ,p_limit_amount      => l_modifier_line_tbl(limit_index).max_amount_per_rule
            ,p_list_line_id      => l_modifier_line_tbl(limit_index).list_line_id
            ,p_list_header_id    => l_modifier_line_tbl(limit_index).list_header_id
            ,p_limit_id          => l_modifier_line_tbl(limit_index).max_amount_per_rule_id
            );

            IF x_return_status = Fnd_Api.g_ret_sts_error THEN
              x_error_location := limit_index;
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              x_error_location := limit_index;
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
          END IF;

          IF l_modifier_line_tbl(limit_index).qd_list_line_id IS NOT NULL
          AND l_modifier_line_tbl(limit_index).qd_list_line_id  <> FND_API.G_MISS_NUM THEN

            OPEN cur_get_accrual_limit_id(5,l_modifier_line_tbl(limit_index).qd_list_line_id);
              FETCH cur_get_accrual_limit_id into l_accr_amount_limit_id;
              CLOSE cur_get_accrual_limit_id;

            process_limits
            (
             x_return_status     => x_return_status
            ,x_msg_count         => x_msg_count
            ,x_msg_data          => x_msg_data
            ,p_limit_type        =>'MAX_AMOUNT_PER_RULE'
            ,p_limit_amount      => l_modifier_line_tbl(limit_index).max_amount_per_rule
            ,p_list_line_id      => l_modifier_line_tbl(limit_index).qd_list_line_id
            ,p_list_header_id    => l_modifier_line_tbl(limit_index).list_header_id
            ,p_limit_id          => l_accr_amount_limit_id
            );

            IF x_return_status = Fnd_Api.g_ret_sts_error THEN
              x_error_location := limit_index;
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              x_error_location := limit_index;
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;

x_modifiers_tbl := v_modifier_ret_tbl;

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
   WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;

PROCEDURE validateQpListLines
(
  x_return_status           OUT NOCOPY  VARCHAR2
 ,x_msg_count               OUT NOCOPY  NUMBER
 ,x_msg_data                OUT NOCOPY  VARCHAR2
 ,p_modifier_line_tbl       IN   MODIFIER_LINE_TBL_TYPE
 ,p_listHeaderId            IN   NUMBER
)
IS
 CURSOR c_currency(cp_listHeaderId NUMBER)
 IS
 SELECT transaction_currency_code
 FROM ozf_offers
 WHERE qp_list_header_id = cp_listHeaderId;
 l_currency ozf_offers.transaction_currency_code%TYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_modifier_line_tbl.count > 0 THEN
    FOR i in p_modifier_line_tbl.first .. p_modifier_line_tbl.last LOOP
        IF p_modifier_line_tbl.exists(i) THEN
            OPEN c_currency(cp_listHeaderId => nvl(p_modifier_line_tbl(i).list_header_id,p_listHeaderId));
                FETCH c_currency INTO l_currency;
            CLOSE c_currency;
            IF l_currency IS NULL THEN
                IF (p_modifier_line_tbl(i).operand <> FND_API.G_MISS_NUM AND p_modifier_line_tbl(i).operand IS NOT NULL)
                        AND
                       (p_modifier_line_tbl(i).arithmetic_operator <> FND_API.G_MISS_CHAR AND p_modifier_line_tbl(i).arithmetic_operator IS NOT NULL)
                THEN
                        IF
                        (p_modifier_line_tbl(i).list_line_type_code = 'DIS' AND p_modifier_line_tbl(i).arithmetic_operator <> '%' )
                        THEN
                             OZF_Utility_PVT.error_message('OZF_OFFR_OPT_CURR_PCNT');
                             x_return_status := FND_API.G_RET_STS_ERROR;
                             RAISE FND_API.g_exc_error;
                        END IF;
                END IF;
                IF (p_modifier_line_tbl(i).qd_operand <> FND_API.G_MISS_NUM AND p_modifier_line_tbl(i).qd_operand IS NOT NULL)
                   AND
                   (p_modifier_line_tbl(i).qd_arithmetic_operator <> FND_API.G_MISS_CHAR AND p_modifier_line_tbl(i).qd_arithmetic_operator IS NOT NULL)
                THEN
                        IF
                        (p_modifier_line_tbl(i).list_line_type_code = 'DIS' AND p_modifier_line_tbl(i).qd_arithmetic_operator <> '%' )
                        THEN
                             OZF_Utility_PVT.error_message('OZF_OFFR_OPT_CURR_PCNT');
                             x_return_status := FND_API.G_RET_STS_ERROR;
                             RAISE FND_API.g_exc_error;
                        END IF;
                END IF;
            END IF;
        END IF;
    END LOOP;
END IF;
END validateQpListLines;

PROCEDURE process_qp_list_lines
(
  x_return_status         OUT NOCOPY  VARCHAR2
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,p_offer_type            IN   VARCHAR2
 ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
 ,p_list_header_id        IN   NUMBER
 ,x_modifier_line_tbl     OUT NOCOPY  qp_modifiers_pub.modifiers_tbl_type
 ,x_error_location        OUT NOCOPY  NUMBER
)IS
 l_api_version CONSTANT NUMBER       := 1.0;
 l_api_name    CONSTANT VARCHAR2(30) := 'process_qp_list_lines';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_modifier_line_tbl qp_modifiers_pub.modifiers_tbl_type;
-- RSSHARMA changed on 06-Feb-2003
 CURSOR c_volume_offer_type IS
 SELECT volume_offer_type FROM ozf_offers
 where qp_list_header_id = p_list_header_id;

 l_Volume_offer_type ozf_offers.volume_offer_type%type;

 l_modifier_line_rec_tbl MODIFIER_LINE_TBL_TYPE := p_modifier_line_tbl;

BEGIN

   SAVEPOINT process_qp_list_lines;

   x_return_status := Fnd_Api.g_ret_sts_success;
   x_error_location := 0;
   validateQpListLines
(
 x_return_status           => x_return_status
 ,x_msg_count              => x_msg_count
 ,x_msg_data               => x_msg_data
 ,p_modifier_line_tbl      => p_modifier_line_tbl
 ,p_listHeaderId           => p_list_header_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF p_list_header_id IS NOT NULL AND p_list_header_id<> FND_API.G_MISS_NUM THEN
l_modifier_line_rec_tbl(p_modifier_line_tbl.last).list_header_id := p_list_header_id;
END IF;

IF p_modifier_line_tbl.count > 0 THEN

IF p_offer_type IN ('OFF_INVOICE','TERMS','ACCRUAL') THEN
 process_regular_discounts
  (
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    p_parent_offer_type    => p_offer_type,
    p_offer_type           => p_offer_type,
    p_modifier_line_tbl    => l_modifier_line_rec_tbl, --Added by nirma
    x_modifiers_tbl        => l_modifier_line_tbl,
    x_error_location       => x_error_location
  );
ELSIF p_offer_type IN ('OID') THEN
 process_promotional_goods
  (
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    p_modifier_line_tbl    => p_modifier_line_tbl,
    x_modifiers_tbl        => l_modifier_line_tbl,
    x_error_location       => x_error_location
  );
ELSIF p_offer_type IN ('ORDER') THEN
  process_order_value
  (
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    p_modifier_line_tbl    => p_modifier_line_tbl,
    x_modifiers_tbl        => l_modifier_line_tbl,
    x_error_location       => x_error_location
  );
ELSIF p_offer_type IN ('DEAL') THEN -- note trade deal does not return values properly so far
  process_trade_deal
  (
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    p_modifier_line_tbl    => p_modifier_line_tbl,
    p_list_header_id       => p_list_header_id,
    x_modifiers_tbl        => l_modifier_line_tbl,
    x_error_location       => x_error_location
  );
ELSIF p_offer_type IN ('VOLUME_OFFER') THEN

OPEN c_volume_offer_type ;
fetch c_volume_offer_type INTO l_Volume_offer_type;
CLOSE c_volume_offer_type ;

 process_regular_discounts
  (
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    p_parent_offer_type    => p_offer_type,
    p_offer_type           => l_volume_offer_type,
    p_modifier_line_tbl    => p_modifier_line_tbl,
    x_modifiers_tbl        => l_modifier_line_tbl,
    x_error_location       => x_error_location
  );
--rssharma end change on 06-Feb-2003
END IF;

x_modifier_line_tbl := l_modifier_line_tbl;

   IF x_return_status = Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
END IF;
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO process_qp_list_lines;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO process_qp_list_lines;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO process_qp_list_lines;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;


PROCEDURE validate_offer_approval
(  x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_init_msg_list         IN   VARCHAR2
  ,p_modifier_list_rec     IN   modifier_list_rec_type
)IS

l_api_version CONSTANT NUMBER       := 1.0;
 l_api_name    CONSTANT VARCHAR2(30) := 'validate_offer_approval';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
CURSOR c_budget_exist IS
SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
          SELECT 1
          FROM   ozf_act_budgets
          WHERE  arc_act_budget_used_by = 'OFFR'
          AND    act_budget_used_by_id = p_modifier_list_rec.qp_list_header_id);
 l_budget_exist           NUMBER;


BEGIN

  x_return_status := Fnd_Api.g_ret_sts_success;

  OPEN c_budget_exist;
  FETCH c_budget_exist INTO l_budget_exist;
  CLOSE c_budget_exist;


  IF l_budget_exist IS NULL THEN
     OZF_Utility_PVT.error_message('OZF_EVE_NO_BGT_SRC');
     RAISE FND_API.g_exc_error;
  END IF;


-- For Lumpsum Offers if distribution is complete
  IF p_modifier_list_rec.offer_type = 'LUMPSUM' AND p_modifier_list_rec.custom_setup_id <> 110 THEN

   validate_lumpsum_offer
   (
     p_init_msg_list        => p_init_msg_list
    ,x_return_status        => x_return_status
    ,x_msg_count            => x_msg_count
    ,x_msg_data             => x_msg_data
    ,p_qp_list_header_id    => p_modifier_list_rec.qp_list_header_id
   );

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

END IF;

   Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;


FUNCTION get_campaign_count(p_list_header_id IN NUMBER)
RETURN NUMBER IS
p_count NUMBER := 0;

CURSOR cur_budget_source_count(list_header_id NUMBER) IS
SELECT   count(1)
FROM ozf_act_offers
where qp_list_header_id = list_header_id;

BEGIN
OPEN cur_budget_source_count( p_list_header_id ) ;
FETCH cur_budget_source_count INTO p_count ;
CLOSE cur_budget_source_count ;
return p_count ;

EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;


/*
This function checks id active discount rules exist for an offer.
If active discount rules exist for the offer then the function returns 0
else it returns -1
r12 changes
Changed function to query ozf_offer_discount_lines and ozf_offer_discount_products
if offer type is VOLUME_OFFER
*/
FUNCTION discount_lines_exist(p_list_header_id IN NUMBER) RETURN NUMBER
IS
  l_lines_count NUMBER := 0;
  CURSOR c_list_line(l_list_header_id NUMBER) IS
  SELECT COUNT(*)
  FROM qp_list_lines
  WHERE list_header_id = l_list_header_id
  AND decode(greatest(end_date_active, sysdate), sysdate,'N','Y') = 'Y';

    CURSOR c_offerType(cp_listHeaderId NUMBER) IS
    SELECT offer_type
    FROM ozf_offers
    WHERE qp_list_header_id = cp_listHeaderId;

    CURSOR c_voCnt(cp_listHeaderId NUMBER) IS
    SELECT 1 FROM dual WHERE EXISTS(SELECT
                                     'X' FROM ozf_offer_discount_lines a, ozf_offer_discount_products b, ozf_offers c
                                     WHERE a.offer_discount_line_id = b.offer_discount_line_id
                                     AND a.offer_id = c.offer_id
                                     AND c.qp_list_header_id = cp_listHeaderId
                                        );

    l_offerType OZF_OFFERS.offer_type%TYPE := null;
    l_return NUMBER := -1;
BEGIN
    l_offerType := null;
        OPEN c_offerType(p_list_header_id);
        FETCH c_offerType into l_offerType;
        IF (c_offerType%NOTFOUND) THEN
            l_offerType := null;
        END IF;
        CLOSE c_offerType;

        l_lines_count := 0;

        IF (l_offerType = 'VOLUME_OFFER') THEN
            OPEN c_voCnt(p_list_header_id);
            FETCH c_voCnt INTO l_lines_count;
            IF c_voCnt%NOTFOUND THEN
                l_lines_count := 0;
            END IF;
            CLOSE c_voCnt;
        ELSIF (l_offerType = 'ACCRUAL') THEN
          OPEN c_list_line(p_list_header_id);
          FETCH c_list_line INTO l_lines_count;
            IF c_list_line%NOTFOUND THEN
                l_lines_count := 0;
            END IF;
          CLOSE c_list_line;
        ELSE
            l_lines_count := 0;
        END IF;

        l_return := -1;
        IF l_lines_count <> 0 THEN
              l_RETURN :=  0;
          ELSE
              l_RETURN := -1;
       END IF;
       RETURN l_return;
       EXCEPTION
       WHEN OTHERS THEN
        RETURN -1;

END discount_lines_exist ;


PROCEDURE Update_Offer_Status
(
   p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_modifier_list_rec     IN   modifier_list_rec_type
)
IS

  CURSOR c_offer_start_date(p_list_header_id NUMBER) IS
  SELECT q.start_date_active, o.start_date
  FROM   qp_list_headers_b q, ozf_offers o
  WHERE  o.qp_list_header_id = q.list_header_id
  AND    q.list_header_id = p_list_header_id;

  l_start_date_q DATE;
  l_start_date_o DATE;
  l_start_date   DATE;

  l_api_name    CONSTANT VARCHAR2(30) := 'update_offer_status';

BEGIN

  SAVEPOINT update_offer_status;

  OPEN  c_offer_start_date(p_modifier_list_rec.qp_list_header_id);
  FETCH c_offer_start_date INTO l_start_date_q, l_start_date_o;
  CLOSE c_offer_start_date;

  IF p_modifier_list_rec.status_code = 'ACTIVE' THEN
    IF l_start_date_o IS NULL THEN
      l_start_date := GREATEST(NVL(l_start_date_q, SYSDATE), SYSDATE);
    ELSE
      l_start_date := l_start_date_o;
    END IF;
  ELSE
    l_start_date := l_start_date_o;
  END IF;

  UPDATE ozf_offers
  SET    user_status_id = p_modifier_list_rec.user_status_id,
         status_code = p_modifier_list_rec.status_code,
         status_date = SYSDATE,
         start_date = l_start_date,
       object_version_number = object_version_number + 1
  WHERE  qp_list_header_id = p_modifier_list_rec.qp_list_header_id;

  IF p_modifier_list_rec.status_code = 'ACTIVE'
  AND p_modifier_list_rec.offer_type NOT IN ('LUMPSUM', 'SCAN_DATA', 'NET_ACCRUAL') THEN
    UPDATE qp_list_headers_b
    SET    active_flag = 'Y'
    WHERE  list_header_id = p_modifier_list_rec.qp_list_header_id;
  -- Forward port bug 3143594. 11i.10 bug is 3614058
    UPDATE qp_qualifiers
    SET    active_flag = 'Y'
    WHERE  list_header_id = p_modifier_list_rec.qp_list_header_id;

  END IF;

  process_offer_activation
(
    p_api_version_number         => 1.0
    , p_init_msg_list              => FND_API.g_false
    , p_commit                     => p_commit
    , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_offer_rec                  => p_modifier_list_rec
);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


  IF p_commit = Fnd_Api.g_true THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      ROLLBACK TO update_offer_status;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get(p_count   => x_msg_count,
                                p_data    => x_msg_data,
                                p_encoded => Fnd_Api.G_FALSE);
END update_offer_status;


PROCEDURE raise_offer_event(p_offer_id      IN NUMBER,
                            p_adjustment_id IN NUMBER :=NULL)
IS
l_item_key varchar2(30);
l_parameter_list wf_parameter_list_t;
BEGIN
  l_item_key := p_offer_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();

  debug_message('Offer Id is :'||p_offer_id );
  wf_event.AddParameterToList(p_name           => 'P_OFFER_ID',
                              p_value          => p_offer_id,
                              p_parameterlist  => l_parameter_list);

  if p_adjustment_id IS NOT NULL  then
    wf_event.AddParameterToList(p_name         => 'P_ADJUSTMENT_ID',
                              p_value          => p_adjustment_id,
                              p_parameterlist  => l_parameter_list);
  end if;

  debug_message('Item Key is  :'||l_item_key);
  wf_event.raise( p_event_name => 'oracle.apps.ozf.offer.OfferApproval',
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);
EXCEPTION
WHEN OTHERS THEN
     debug_message('Exception in raising business event');
     RAISE Fnd_Api.g_exc_error;
END;

FUNCTION getDateQualifier(p_qpListHeaderId NUMBER)
RETURN VARCHAR2
IS
CURSOR c_dateQualifier(cp_qpListHeaderId NUMBER) IS
SELECT date_qualifier_profile_value
FROM ozf_offers
WHERE qp_list_header_id = cp_qpListHeaderId;
l_dateQualifier VARCHAR2(1):= NULL;
BEGIN
OPEN c_dateQualifier(cp_qpListHeaderId  => p_qpListHeaderId ) ;
FETCH c_dateQualifier INTO l_dateQualifier;
IF c_dateQualifier%NOTFOUND  THEN
    l_dateQualifier := null;
END IF;
CLOSE c_dateQualifier;
return l_dateQualifier;
END getDateQualifier;

PROCEDURE process_modifiers
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offer_type            IN   VARCHAR2
  ,p_modifier_list_rec     IN   modifier_list_rec_type
  ,p_modifier_line_tbl     IN   MODIFIER_LINE_TBL_TYPE
  ,x_qp_list_header_id     OUT NOCOPY  NUMBER
  ,x_error_location        OUT NOCOPY  NUMBER
)
IS

  v_modifier_list_rec      modifier_list_rec_type;
  temp_modifier_list_rec   modifier_list_rec_type := p_modifier_list_rec;
  date_temp_modifier_list_rec   modifier_list_rec_type := p_modifier_list_rec;
  l_modifier_list_rec      modifier_list_rec_type := p_modifier_list_rec;
  l_offer_id               NUMBER;
  v_modifier_line_tbl          qp_modifiers_pub.modifiers_tbl_type; --
  l_modifier_line_tbl      MODIFIER_LINE_TBL_TYPE := p_modifier_line_tbl;

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'process_modifiers';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_handle_status VARCHAR2(1);

  l_old_status_id          NUMBER;
  l_approval_type          VARCHAR2(30);
  l_new_status_code        VARCHAR2(30);
  l_old_status_code        VARCHAR2(30);
  l_status_code            VARCHAR2(30); -- status from budget API

  l_owner_id               NUMBER;
  l_amount_error           VARCHAR2(1);
  l_budget_required        VARCHAR2(1);
  l_approval_required      VARCHAR2(1);
  l_lines_count            NUMBER;

  l_offers_rec             modifier_list_rec_type := p_modifier_list_rec;

  l_na_qual_context        VARCHAR2(30);
  l_na_qual_attribute      VARCHAR2(30);

  l_old_offer_id           NUMBER;

   CURSOR cur_get_user_status IS
   SELECT user_status_id,owner_id,status_code,offer_id
     FROM ozf_offers
    WHERE qp_list_header_id = p_modifier_list_rec.qp_list_header_id;

   CURSOR c_offer_budget IS
   SELECT budget_source_type, budget_source_id, budget_amount_tc
     FROM ozf_offers
    WHERE qp_list_header_id = p_modifier_list_rec.qp_list_header_id;

  CURSOR c_budget_required IS
  SELECT attr_available_flag
    FROM ams_custom_setup_attr
   WHERE object_attribute = 'BREQ'
     AND custom_setup_id = p_modifier_list_rec.custom_setup_id;

  CURSOR c_prod_line IS
  SELECT COUNT(*)
    FROM ams_act_products
   WHERE arc_act_product_used_by = 'OFFR'
     AND act_product_used_by_id = p_modifier_list_rec.qp_list_header_id;

  CURSOR c_list_line IS
  SELECT COUNT(*)
    FROM qp_list_lines
   WHERE list_header_id = p_modifier_list_rec.qp_list_header_id;

  CURSOR c_na_line IS
  SELECT COUNT(*)
  FROM   ozf_offer_discount_lines
  WHERE  offer_id =
         (SELECT offer_id FROM ozf_offers WHERE qp_list_header_id = p_modifier_list_rec.qp_list_header_id);

  CURSOR c_prg_buy_count IS
  SELECT COUNT(*)
    FROM qp_list_lines
   WHERE list_header_id = p_modifier_list_rec.qp_list_header_id
     AND TRUNC(SYSDATE) <= TRUNC(NVL(end_date_active, SYSDATE))
     AND list_line_type_code = 'PRG';

  CURSOR c_prg_get_count IS
  SELECT COUNT(*)
    FROM qp_list_lines
   WHERE list_header_id = p_modifier_list_rec.qp_list_header_id
     AND TRUNC(SYSDATE) <= TRUNC(NVL(end_date_active, SYSDATE))
     AND list_line_type_code = 'DIS';

  l_prg_buy_count NUMBER;
  l_prg_get_count NUMBER;

  -- bug 3412451 need to update budget line upon offer activation if no approval nor validation invoked
  CURSOR c_budget_request(p_qp_list_header_id NUMBER) IS
  SELECT activity_budget_id
  FROM   ozf_act_budgets
  WHERE  act_budget_used_by_id = p_qp_list_header_id
  AND    arc_act_budget_used_by = 'OFFR';
  -- end comment

CURSOR c_vo_line (p_qp_list_header_id NUMBER)IS
SELECT count(*) FROM ozf_offer_discount_products a, ozf_offer_discount_lines b
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND b.offer_id = (SELECT offer_id FROM ozf_offers WHERE qp_list_header_id = p_qp_list_header_id);

CURSOR c_emptyDiscStruct(cp_qpListheaderId NUMBER) IS
SELECT 1 FROM
ozf_offer_discount_lines a , ozf_offers b
WHERE a.tier_type = 'PBH'
AND a.offer_id = b.offer_id --8013
AND
( NOT EXISTS(SELECT 'X'  FROM ozf_offer_discount_products WHERE offer_discount_line_id = a.offer_discount_line_id AND excluder_flag = 'N')
OR NOT EXISTS(SELECT 'X'  FROM ozf_offer_discount_lines WHERE parent_discount_line_id = a.offer_discount_line_id)
)
AND b.qp_list_header_id = cp_qpListheaderId;

l_emptyDiscStruct VARCHAR2(1) := NULL;



  CURSOR c_budget_req_count(p_list_header_id NUMBER) IS
  SELECT COUNT(*)
  FROM   ozf_act_budgets
  WHERE  arc_act_budget_used_by = 'OFFR'
  AND    status_code = 'NEW'
  AND    transfer_type = 'REQUEST'
  AND    act_budget_used_by_id = p_list_header_id;
  l_budget_req_count NUMBER := 0;
BEGIN
    SAVEPOINT process_modifiers;
--dbms_output.put_line('calling qp procedure');
    IF Fnd_Api.to_boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
    END IF;

   IF NOT Fnd_Api.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;
   x_error_location := 0;

   -- added by julou 14-DEC-2001 check default profile values before going any further
   IF FND_PROFILE.value('OZF_PRICING_PHASE_LINEGROUP') IS NULL THEN
     FND_MESSAGE.set_name('OZF','OZF_NO_PRICING_PHASE_LINEGROUP');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_PROFILE.value('OZF_PRICING_PHASE_LINE') IS NULL THEN
     FND_MESSAGE.set_name('OZF','OZF_NO_PRICING_PHASE_LINE');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_PROFILE.value('OZF_PRICING_PHASE_ORDER') IS NULL THEN
     FND_MESSAGE.set_name('OZF','OZF_NO_PRICING_PHASE_ORDER');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE') IS NULL THEN
     FND_MESSAGE.set_name('OZF','OZF_NO_PRICING_GROUP_SEQUENCE');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_PROFILE.value('OZF_PRINT_ON_INVOICE') IS NULL THEN
     FND_MESSAGE.set_name('OZF','OZF_NO_PRINT_ON_INVOICE');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
/* julou bug 3498759 - comment OUT NOCOPY as these profiles are not mandatory
   IF FND_PROFILE.value('OZF_INCOMPATIBILITY_GROUP') IS NULL THEN
     FND_MESSAGE.set_name('OZF','OZF_NO_INCOMPATIBILITY_GROUP');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
*/
   IF FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE') IS NULL THEN
     FND_MESSAGE.set_name('OZF','OZF_NO_PRODUCT_PRECEDENCE');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- end of code added by julou
   validate_offer_dates(
           p_api_version          => 1.0
          ,p_init_msg_list        => p_init_msg_list
          ,x_return_status        => x_return_status
          ,x_msg_count            => x_msg_count
          ,x_msg_data             => x_msg_data
          ,p_offer_rec            => p_modifier_list_rec
        );

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
           ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
           END IF;

  IF p_modifier_list_rec.modifier_operation <> FND_API.g_miss_char THEN

    IF p_modifier_list_rec.modifier_operation = 'UPDATE' THEN

      OPEN cur_get_user_status;
        FETCH cur_get_user_status INTO l_old_status_id,l_owner_id,l_old_status_code,l_old_offer_id;
      CLOSE cur_get_user_status;

      IF l_old_status_code = 'ACTIVE' THEN
      --julou in active status, if recal='N', validated committed vs approved othterwise do nothing
        IF FND_PROFILE.VALUE('OZF_BUDGET_ADJ_ALLOW_RECAL') = 'N' THEN
        validate_offer
          (
           p_api_version          => 1.0
          ,p_init_msg_list        => p_init_msg_list
          ,x_return_status        => x_return_status
          ,x_msg_count            => x_msg_count
          ,x_msg_data             => x_msg_data
          ,p_offer_rec            => p_modifier_list_rec
        );

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
           ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
           END IF;
         END IF;
     END IF;

    IF (p_modifier_list_rec.user_status_id <> FND_API.g_miss_num)
       AND (p_modifier_list_rec.user_status_id <> l_old_status_id) THEN

      l_new_status_code :=  OZF_Utility_PVT.get_system_status_code(p_modifier_list_rec.user_status_id);

         --IF l_new_status_code = 'ACTIVE' THEN

          OZF_Utility_PVT.check_new_status_change
          (
             p_object_type      => 'OFFR',
             p_object_id        => p_modifier_list_rec.qp_list_header_id,
             p_old_status_id    => l_old_status_id,
             p_new_status_id    => p_modifier_list_rec.user_status_id,
             p_custom_setup_id  => p_modifier_list_rec.custom_setup_id,
             x_approval_type    => l_approval_type,
                x_return_status    => x_return_status
          );

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
           ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
           END IF;

        OPEN c_budget_required;
        FETCH c_budget_required INTO l_budget_required;
        CLOSE c_budget_required;

         --END IF;

    END IF;

  END IF;

  IF p_modifier_list_rec.offer_type = 'VOLUME_OFFER' THEN
    l_modifier_list_rec.offer_type := p_modifier_list_rec.volume_offer_type;
  END IF;

    IF p_modifier_list_rec.modifier_operation = 'UPDATE' THEN
    IF getDateQualifier(p_qpListHeaderId => p_modifier_list_rec.qp_list_header_id) = 'A'
    THEN
    offer_dates(
     p_modifier_list_rec   => p_modifier_list_rec
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data  => x_msg_data
    );

    ELSIF getDateQualifier(p_qpListHeaderId => p_modifier_list_rec.qp_list_header_id) = 'Y'
    THEN
    offer_dates(
     p_modifier_list_rec   => p_modifier_list_rec
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data  => x_msg_data
    );

    l_modifier_list_rec.start_date_active_first := Fnd_Api.g_miss_date;
    l_modifier_list_rec.end_date_active_first := Fnd_Api.g_miss_date;
    l_modifier_list_rec.start_date_active_second := Fnd_Api.g_miss_date;
    l_modifier_list_rec.end_date_active_second := Fnd_Api.g_miss_date;

    END IF;

           IF x_return_status = Fnd_Api.g_ret_sts_error THEN
           RAISE Fnd_Api.g_exc_error;
           ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
           RAISE Fnd_Api.g_exc_unexpected_error;
           END IF;
    END IF;

    IF l_approval_type IS NULL AND (l_budget_required = 'N' OR l_budget_required IS NULL) THEN
      l_approval_required := NULL;
    ELSE
      l_approval_required := 'Y';
    END IF;

l_modifier_list_rec.offer_type := p_offer_type;

  IF p_modifier_list_rec.global_flag = 'Y' THEN
    IF p_modifier_list_rec.orig_org_id IS NOT NULL AND p_modifier_list_rec.orig_org_id <> fnd_api.g_miss_num THEN
      FND_MESSAGE.set_name('OZF', 'OZF_CLEAR_OU');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;


  l_modifier_list_rec.global_flag := p_modifier_list_rec.global_flag;
  l_modifier_list_rec.orig_org_id := p_modifier_list_rec.orig_org_id;

-- if org id is sent from the ui pass it on
-- of org id is not passed from the ui,
-- and if global flag is set as no
-- and if default org profile is not set then raise not default org is profile

-- if orgid is not sent from the ui and

/*
Org Id is always required for ScanData and Lumpsum offers
*/
IF (p_offer_type = 'LUMPSUM'OR p_offer_type = 'SCAN_DATA') THEN
    IF (
        (
            (p_modifier_list_rec.modifier_operation = 'CREATE' )
            AND
            (p_modifier_list_rec.orig_org_id IS NULL OR p_modifier_list_rec.orig_org_id = FND_API.G_MISS_NUM)
         )
            OR
         (
            (p_modifier_list_rec.modifier_operation = 'UPDATE' )
            AND
            (p_modifier_list_rec.orig_org_id IS NULL)
         )
        )
    THEN
            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORG_ID');
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
    END IF;
END IF;
--dbms_output.put_line('calling process qp_ list header');
    process_qp_list_header(
      p_api_version          => 1.0,
      p_init_msg_list        => p_init_msg_list,
      x_return_status        => x_return_status,
      x_msg_count            => x_msg_count,
      x_msg_data             => x_msg_data,
      p_modifier_list_rec    => l_modifier_list_rec,
      x_modifier_list_rec    => v_modifier_list_rec,
      p_old_status_id        => l_old_status_id,
      p_approval_type        => l_approval_required,
      p_new_status_code      => l_new_status_code
    );
       IF x_return_status = Fnd_Api.g_ret_sts_error THEN
           RAISE Fnd_Api.g_exc_error;
       ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
           RAISE Fnd_Api.g_exc_unexpected_error;
       END IF;

debug_message('Operation is is :'||   p_modifier_list_rec.modifier_operation);

  IF p_modifier_list_rec.modifier_operation = 'CREATE' THEN
   temp_modifier_list_rec.qp_list_header_id  := v_modifier_list_rec.qp_list_header_id;
   x_qp_list_header_id                       := v_modifier_list_rec.qp_list_header_id;
   temp_modifier_list_rec.offer_code         := v_modifier_list_rec.name;

  ELSIF p_modifier_list_rec.modifier_operation = 'UPDATE' THEN
    IF l_new_status_code = 'ACTIVE' AND p_modifier_list_rec.offer_type = 'VOLUME_OFFER' THEN
      ozf_check_dup_prod_pvt.check_dup_prod(
                x_return_status => x_return_status
               ,x_msg_count     => x_msg_count
               ,x_msg_data      => x_msg_data
               ,p_offer_id      => l_old_offer_id);

      IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF l_approval_type = 'THEME' THEN
      temp_modifier_list_rec.user_status_id := OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','SUBMITTED_TA');
      temp_modifier_list_rec.status_code := 'SUBMITTED_TA';
    ELSIF l_approval_type = 'BUDGET' THEN
      temp_modifier_list_rec.user_status_id := OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','PENDING');
      temp_modifier_list_rec.status_code := 'PENDING';
    -- julou budget w/o approval scenario
    ELSIF l_budget_required = 'Y' THEN
      IF l_new_status_code = 'ACTIVE' THEN
        temp_modifier_list_rec.user_status_id := OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','PENDING_VALIDATION');
        temp_modifier_list_rec.status_code := 'PENDING_VALIDATION';
      END IF;
    ELSE -- no validation or approval required
      IF l_new_status_code = 'ACTIVE' THEN
        OPEN  c_budget_req_count(temp_modifier_list_rec.qp_list_header_id);
        FETCH c_budget_req_count INTO l_budget_req_count;
        CLOSE c_budget_req_count;

        IF l_budget_req_count = 0 THEN
          temp_modifier_list_rec.user_status_id := OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','ACTIVE');
          temp_modifier_list_rec.status_code := 'ACTIVE';
        ELSE
          OZF_budgetapproval_pvt.budget_request_approval(
              p_init_msg_list => FND_API.G_FALSE
             ,p_api_version   => l_api_version
             ,p_commit        => FND_API.G_FALSE
             ,x_return_status => x_return_status
             ,x_msg_count     => x_msg_count
             ,x_msg_data      => x_msg_data
             ,p_object_type   => 'OFFR'
             ,p_object_id     => temp_modifier_list_rec.qp_list_header_id
             ,x_status_code   => l_status_code);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;

          temp_modifier_list_rec.user_status_id := OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS',l_status_code);
          temp_modifier_list_rec.status_code := l_status_code;
        END IF;
      END IF;
    -- julou end
    END IF;

  END IF;

  IF p_modifier_list_rec.offer_operation <> FND_API.g_miss_char THEN
    process_ozf_offer(
        p_api_version          => 1.0,
        p_init_msg_list        => p_init_msg_list,
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_modifier_list_rec    => temp_modifier_list_rec,
        x_offer_id             => l_offer_id
      );

       IF x_return_status = Fnd_Api.g_ret_sts_error THEN
           RAISE Fnd_Api.g_exc_error;
       ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
           RAISE Fnd_Api.g_exc_unexpected_error;
       END IF;
/*
  IF l_budget_req_count > 0 THEN
            OZF_budgetapproval_pvt.budget_request_approval(
              p_init_msg_list => FND_API.G_FALSE
             ,p_api_version   => l_api_version
             ,p_commit        => FND_API.G_FALSE
             ,x_return_status => x_return_status
             ,x_msg_count     => x_msg_count
             ,x_msg_data      => x_msg_data
             ,p_object_type   => 'OFFR'
             ,p_object_id     => temp_modifier_list_rec.qp_list_header_id
             ,x_status_code   => l_status_code);

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
  END IF;
*/
-- If Offer is activated then Raise business event
  IF (p_modifier_list_rec.modifier_operation = 'UPDATE') AND (p_modifier_list_rec.user_status_id <> FND_API.g_miss_num)
       AND (p_modifier_list_rec.user_status_id <> l_old_status_id)
  THEN
      raise_offer_event(p_offer_id => temp_modifier_list_rec.qp_list_header_id );
  END IF;

 debug_message('after raise_offer_event:');
-- julou create budget request for scan data offer if initial product line is created
  -- julou 12-10-2002 if source from campaign, use campaign id as budget source id
  -- and create budget request.
  IF temp_modifier_list_rec.source_from_parent = 'Y' THEN
    temp_modifier_list_rec.budget_source_id := temp_modifier_list_rec.offer_used_by_id;
    temp_modifier_list_rec.budget_source_type := 'CAMP';
  END IF;

  IF p_offer_type = 'SCAN_DATA' THEN
--    IF get_budget_source_count(p_modifier_list_rec.qp_list_header_id) = 0
--    THEN
-- uncommented by gramanat
      OPEN c_offer_budget;
      FETCH c_offer_budget INTO temp_modifier_list_rec.budget_source_type, temp_modifier_list_rec.budget_source_id, temp_modifier_list_rec.budget_amount_tc;
      CLOSE c_offer_budget;
-- end uncommented by gramanat
   debug_message('GR: temp_modifier_list_rec.budget_source_type: ' || temp_modifier_list_rec.budget_source_type);
 debug_message('GR: temp_modifier_list_rec.budget_source_id: ' || temp_modifier_list_rec.budget_source_id);

      IF temp_modifier_list_rec.budget_source_id IS NOT NULL THEN
        IF temp_modifier_list_rec.offer_amount = Fnd_Api.g_miss_num THEN
          offer_budget(
              p_modifier_list_rec  => temp_modifier_list_rec
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,p_operation          => p_modifier_list_rec.modifier_operation
          );

          IF x_return_status = Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;

--        END IF;
      END IF;
    END IF;
  END IF;
-- julou end

    IF p_modifier_list_rec.modifier_operation = 'CREATE' THEN
      AMS_CampaignRules_PVT.push_source_code(
         temp_modifier_list_rec.offer_code,
         'OFFR',
         x_qp_list_header_id
       );
    END IF;

  END IF;

  IF  p_modifier_list_rec.offer_operation = 'UPDATE'
  AND p_modifier_list_rec.modifier_operation = 'UPDATE' THEN

    IF (p_modifier_list_rec.user_status_id <> FND_API.g_miss_num)
      AND (p_modifier_list_rec.user_status_id <> l_old_status_id) THEN


      IF l_new_status_code = 'ACTIVE' THEN
        -- julou bug 2122722 activating offer w/o discount lines
        IF p_modifier_list_rec.offer_type IN ('LUMPSUM','SCAN_DATA') THEN
          OPEN c_prod_line;
          FETCH c_prod_line INTO l_lines_count;
          CLOSE c_prod_line;
        ELSIF p_modifier_list_rec.offer_type = 'OID' THEN
          OPEN  c_prg_buy_count;
          FETCH c_prg_buy_count INTO l_prg_buy_count;
          CLOSE c_prg_buy_count;

          OPEN  c_prg_get_count;
          FETCH c_prg_get_count INTO l_prg_get_count;
          CLOSE c_prg_get_count;

          l_lines_count := LEAST(l_prg_buy_count, l_prg_get_count);
        ELSIF p_modifier_list_rec.offer_type = 'NET_ACCRUAL' THEN
          OPEN c_na_line;
          FETCH c_na_line INTO l_lines_count;
          CLOSE c_na_line;
        ELSIF p_modifier_list_rec.offer_type = 'VOLUME_OFFER' THEN

         OPEN c_vo_line(p_modifier_list_rec.qp_list_header_id) ;
             FETCH c_vo_line INTO l_lines_count;
         CLOSE c_vo_line;

         OPEN c_emptyDiscStruct(cp_qpListheaderId => p_modifier_list_rec.qp_list_header_id);
             FETCH c_emptyDiscStruct INTO l_emptyDiscStruct;
             IF c_emptyDiscStruct%NOTFOUND THEN
                l_emptyDiscStruct := NULL;
             END IF;
         CLOSE c_emptyDiscStruct;
        ELSE
          OPEN c_list_line;
          FETCH c_list_line INTO l_lines_count;
          CLOSE c_list_line;
        END IF;
         debug_message('l_lines_count :'||l_lines_count);

        IF l_lines_count = 0 THEN
          IF p_modifier_list_rec.custom_setup_id <> 110 THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_OFFR_NO_DISC_LINES');
            FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
          END IF;
        END IF;
        -- julou end bug 2122722
        -- julou BREQ
        IF l_emptyDiscStruct = '1' THEN
            FND_MESSAGE.set_name('OZF', 'OZF_OFFR_EMPTY_DISC_STRUCT');
            FND_MSG_PUB.add;
          RAISE FND_API.g_exc_error;
        END IF;


        IF l_budget_required = 'Y' THEN
          IF get_budget_source_count(p_modifier_list_rec.qp_list_header_id) = 0 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_OFFR_NO_BUDGET_REQUEST');
              FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
          END IF;
        END IF;

        -- validate scan data offer budgets
        IF p_modifier_list_rec.offer_type = 'SCAN_DATA' THEN
          validate_scandata_budget(p_init_msg_list     => FND_API.G_FALSE
              ,p_api_version       => l_api_version
              ,x_return_status     => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_qp_list_header_id => p_modifier_list_rec.qp_list_header_id);

          IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
          ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
          END IF;
        END IF;
      END IF;



        IF l_approval_type IS NULL THEN
        -- budget approval is not required, call budget_request_approval
        -- enhancement for budget w/o approval scenario
          IF l_budget_required = 'Y' AND l_new_status_code = 'ACTIVE' THEN
          IF l_old_status_code <> 'PENDING_ACTIVE' THEN
            OZF_budgetapproval_pvt.budget_request_approval(
              p_init_msg_list => FND_API.G_FALSE
             ,p_api_version   => l_api_version
             ,p_commit        => FND_API.G_FALSE
             ,x_return_status => x_return_status
             ,x_msg_count     => x_msg_count
             ,x_msg_data      => x_msg_data
             ,p_object_type   => 'OFFR'
             ,p_object_id     => p_modifier_list_rec.qp_list_header_id
             ,x_status_code   => l_status_code);

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;

            temp_modifier_list_rec.user_status_id := OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS',l_status_code);
            temp_modifier_list_rec.status_code := l_status_code;
          END IF;
--julou end BREQ
          -- julou handle status depending on recal(handled by activate_offer_over).
          -- if active(no product validation is required, 'ACTIVE' is returned directly),
          -- need to call activate_offer_over for posting, validation, and updating status.
          -- otherwise, budget API will call its CP and activate_offer_over is
          -- called inside itself. no further action required here.
          -- if from PENDING_ACTIVE to ACTIVE, no budget validation is called.
          IF l_old_status_code = 'PENDING_ACTIVE' OR l_status_code = 'ACTIVE' THEN
            Activate_Offer_over(
               p_init_msg_list     => FND_API.G_FALSE
              ,p_api_version       => l_api_version
              ,p_commit            => FND_API.G_FALSE
              ,x_return_status     => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_called_from       => 'R'
              ,p_offer_rec         => temp_modifier_list_rec
              ,x_amount_error      => l_amount_error
               );
            debug_message('Activate_Offer_over :'|| x_return_status);
            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
          ELSIF l_status_code = 'DRAFT' THEN
            -- CP validation fails. update offer to DRAFT
            UPDATE ozf_offers
               SET status_code = 'DRAFT'
                  ,user_status_id = OZF_Utility_PVT.get_default_user_status ('OZF_OFFER_STATUS', 'DRAFT')
                  ,status_date = SYSDATE
                  ,object_version_number = object_version_number + 1
             WHERE qp_list_header_id = p_modifier_list_rec.qp_list_header_id;
          END IF;
          END IF;-- end l_budget_required='Y'
        ELSIF l_approval_type = 'BUDGET' THEN
          IF l_old_status_code <> 'PENDING_ACTIVE' THEN
            validate_offer_approval
             ( x_return_status     => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_init_msg_list     => FND_API.G_FALSE
              ,p_modifier_list_rec => p_modifier_list_rec );

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;

            ams_approval_pvt.StartProcess(
            p_activity_type    => 'OFFR',
            p_activity_id      => p_modifier_list_rec.qp_list_header_id,
            p_approval_type    => 'BUDGET',
            p_object_version_number => p_modifier_list_rec.object_version_number+1,
            p_orig_stat_id     => l_old_status_id,
            p_new_stat_id      => p_modifier_list_rec.user_status_id,
            p_reject_stat_id   => OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','REJECTED'),
            p_requester_userid => OZF_Utility_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1)),
            p_workflowprocess  => 'AMS_APPROVAL',
            p_item_type        => 'AMSAPRV');
          ELSE
            Activate_Offer_over(
               p_init_msg_list     => FND_API.G_FALSE
              ,p_api_version       => l_api_version
              ,p_commit            => FND_API.G_FALSE
              ,x_return_status     => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_called_from       => 'R'
              ,p_offer_rec         => temp_modifier_list_rec
              ,x_amount_error      => l_amount_error
               );

            IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
          END IF;
        ELSIF l_approval_type = 'THEME' THEN
          ams_approval_pvt.StartProcess(
            p_activity_type    => 'OFFR',
            p_activity_id      => p_modifier_list_rec.qp_list_header_id,
            p_approval_type    => 'CONCEPT',
            p_object_version_number => p_modifier_list_rec.object_version_number+1,
            p_orig_stat_id     => l_old_status_id,
            p_new_stat_id      => p_modifier_list_rec.user_status_id,
            p_reject_stat_id   => OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','DENIED_TA'),
            p_requester_userid => OZF_Utility_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1)),
            p_workflowprocess  => 'AMS_CONCEPT_APPROVAL',
            p_item_type        => 'AMSAPRV');
        END IF;
     END IF;
  END IF;


  IF (p_modifier_list_rec.modifier_operation ='CREATE')
  OR
  (p_modifier_list_rec.modifier_operation ='UPDATE' AND get_campaign_count(p_modifier_list_rec.qp_list_header_id) < 1)
   THEN
    IF    p_modifier_list_rec.offer_used_by_id <> Fnd_Api.g_miss_num
    AND   p_modifier_list_rec.offer_used_by_id IS NOT NULL
    THEN

         offer_object_usage(
              p_modifier_list_rec  => temp_modifier_list_rec
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
          );

      IF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;
    END IF;
  END IF;



-- RSSHARMA changed condition to attach a budget even in create page
  -- julou 12-10-2002 if source from campaign, use campaign id as budget source id
  -- and create budget request.
  IF p_modifier_list_rec.source_from_parent = 'Y' THEN
    temp_modifier_list_rec.budget_source_id := p_modifier_list_rec.offer_used_by_id;
    temp_modifier_list_rec.budget_source_type := 'CAMP';
  END IF;

  IF (p_modifier_list_rec.modifier_operation ='CREATE')
  OR
  (p_modifier_list_rec.modifier_operation ='UPDATE' AND get_budget_source_count(p_modifier_list_rec.qp_list_header_id) < 1)
  THEN
    IF   (temp_modifier_list_rec.budget_source_id <> Fnd_Api.g_miss_num
            AND  temp_modifier_list_rec.budget_source_id IS NOT NULL )
    AND  ( p_modifier_list_rec.offer_amount <> Fnd_Api.g_miss_num
            AND p_modifier_list_rec.offer_amount IS NOT NULL
    )

    THEN
         offer_budget(
              p_modifier_list_rec  => temp_modifier_list_rec
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,p_operation          => p_modifier_list_rec.modifier_operation
          );
    END IF;
  END IF;



--    x_return_status := Fnd_Api.g_ret_sts_error;
       IF x_return_status = Fnd_Api.g_ret_sts_error THEN
           RAISE Fnd_Api.g_exc_error;
       ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
           RAISE Fnd_Api.g_exc_unexpected_error;
       END IF;

       debug_message('Offer Type is : '|| p_offer_type);
  IF p_offer_type NOT IN  ('LUMPSUM','SCAN_DATA', 'VOLUME_OFFER', 'NET_ACCRUAL') THEN
 IF( (p_modifier_list_rec.custom_setup_id = 119 AND p_modifier_list_rec.modifier_operation = 'CREATE') OR (p_modifier_list_rec.custom_setup_id <> 119  AND p_modifier_list_rec.modifier_operation IN ('CREATE','UPDATE'))) THEN
    IF    (p_modifier_list_rec.ql_qualifier_id <> Fnd_Api.g_miss_num
    AND   p_modifier_list_rec.ql_qualifier_id IS NOT NULL)
    OR
    (
    p_modifier_list_rec.sales_method_flag IS NOT NULL
    AND
    p_modifier_list_rec.sales_method_flag <> Fnd_Api.g_miss_char
    )
    THEN
        offer_qualifier(
              p_modifier_list_rec  => temp_modifier_list_rec
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
          );

      IF x_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

    END IF; -- ql_qualifier_id is not null

  END IF;   -- operation
  ELSIF p_offer_type = 'NET_ACCRUAL' THEN
    IF p_modifier_list_rec.na_qualifier_type IS NOT NULL
    AND p_modifier_list_rec.na_qualifier_type <> fnd_api.g_miss_char
    AND p_modifier_list_rec.na_qualifier_id IS NOT NULL
    AND p_modifier_list_rec.na_qualifier_id <> fnd_api.g_miss_num
    THEN
/*
      IF p_modifier_list_rec.na_qualifier_type = 'CUSTOMER' THEN
        l_na_qual_context   := 'CUSTOMER';
        l_na_qual_attribute := 'QUALIFIER_ATTRIBUTE2';
      ELSIF p_modifier_list_rec.na_qualifier_type = 'CUSTOMER_BILL_TO' THEN
        l_na_qual_context   := 'CUSTOMER';
        l_na_qual_attribute := 'QUALIFIER_ATTRIBUTE14';
      ELSIF p_modifier_list_rec.na_qualifier_type = 'BUYER' THEN
        l_na_qual_context   := 'CUSTOMER_GROUP';
        l_na_qual_attribute := 'QUALIFIER_ATTRIBUTE3';
      ELSIF p_modifier_list_rec.na_qualifier_type = 'LIST' THEN
        l_na_qual_context   := 'CUSTOMER_GROUP';
        l_na_qual_attribute := 'QUALIFIER_ATTRIBUTE1';
      ELSIF p_modifier_list_rec.na_qualifier_type = 'SEGMENT' THEN
        l_na_qual_context   := 'CUSTOMER_GROUP';
        l_na_qual_attribute := 'QUALIFIER_ATTRIBUTE2';
      ELSIF p_modifier_list_rec.na_qualifier_type = 'TERRITORY' THEN
        l_na_qual_context   := 'TERRITORY';
        l_na_qual_attribute := 'QUALIFIER_ATTRIBUTE1';
      ELSIF p_modifier_list_rec.na_qualifier_type = 'SHIP_TO' THEN
        l_na_qual_context   := 'CUSTOMER';
        l_na_qual_attribute := 'QUALIFIER_ATTRIBUTE11';
      END IF;
*/
      INSERT INTO ozf_offer_qualifiers(
         qualifier_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,qualifier_grouping_no
        ,qualifier_context
        ,qualifier_attribute
        ,qualifier_attr_value
        ,start_date_active
        ,end_date_active
        ,offer_id
        ,active_flag
        ,object_version_number)
      VALUES(
         ozf_offer_qualifiers_s.NEXTVAL
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,SYSDATE
        ,FND_GLOBAL.user_id
        ,FND_GLOBAL.conc_login_id
        ,10
        ,NULL--l_na_qual_context
        ,p_modifier_list_rec.na_qualifier_type--l_na_qual_attribute
        ,TO_CHAR(p_modifier_list_rec.na_qualifier_id)
        ,p_modifier_list_rec.start_date_active
        ,p_modifier_list_rec.end_date_active
        ,l_offer_id
        ,'Y'
        ,1);
    END IF;
  ELSIF p_offer_type = 'VOLUME_OFFER' THEN
--    v_modifier_list_rec
    l_modifier_list_rec := p_modifier_list_rec;
    l_modifier_list_rec.offer_id := l_offer_id;
    l_modifier_list_rec.qp_list_header_id := v_modifier_list_rec.qp_list_header_id;
  vo_qualifier
    (
       p_init_msg_list         => p_init_msg_list
      ,p_api_version           => p_api_version
      ,p_commit                => p_commit
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      ,p_modifier_list_rec     => l_modifier_list_rec
     );

       IF x_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;


 END IF; -- OFFER_TYPE

 END IF;
debug_message('p_modifier_line_tbl.COUNT :'|| p_modifier_line_tbl.COUNT);
IF p_modifier_line_tbl.COUNT > 0 THEN
  process_qp_list_lines
  (
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    p_offer_type           => p_offer_type,
    p_modifier_line_tbl    => l_modifier_line_tbl,
    p_list_header_id       => temp_modifier_list_rec.qp_list_header_id,
    x_modifier_line_tbl    => v_modifier_line_tbl,
    x_error_location       => x_error_location
  );
debug_message('process_qp_list_lines x_return_status '||x_return_status);
 IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
     RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;


END IF;

IF p_modifier_list_rec.custom_setup_id = 118 THEN
        IF p_modifier_list_rec.user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','DENIED_TA')
          OR p_modifier_list_rec.user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','REJECTED') THEN --


        update ozf_sd_request_headers_all_b set user_status_id= OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS','OFFER_REJECTED')
        where offer_id=p_modifier_list_rec.qp_list_header_id;

        ELSIF p_modifier_list_rec.user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','ACTIVE') THEN

        update ozf_sd_request_headers_all_b set user_status_id= OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS','ACTIVE')
        where offer_id= p_modifier_list_rec.qp_list_header_id;

        END IF;
END IF;

     Fnd_Msg_Pub.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   Fnd_Api.G_FALSE
        );
   IF p_commit = Fnd_Api.g_true THEN
      COMMIT WORK;
   END IF;
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO process_modifiers;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO process_modifiers;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO process_modifiers;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END;


/*
remaning character or string buffer too small in relate_qp_ozf_for_vo procedure
*/



/*
LOgic for buliding relations
1. Discounts
relations for discounts(ozf_discount_lines and qp_list_lines) are stored only if the OZF Products that have apply discount = y.

If the OZF Product has apply discount =  n (which may be a discount or an exclusion) and is not an exclusion
then a single qp discount line with list line type code DIS and 0% discount is created.
-- This line can be related to the ozf_product since the ozf product in this case has a one to one relation with qp pricing attribute.
If the ozf product is an exclusion no qp_list_line is created for it. A qp pricing attribute is created for every PBH discount line created for the ozf discount line.

2. Products.
Relations between ozf products and qp products ie ozf_discount_products and qp_pricing_attributes are stored for every product irrespective of the apply discount flag or the include volume flag
*/


--===================================Push Discount Rules to QP===========================
PROCEDURE populatePricingAttr
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_qp_list_header_id     IN NUMBER
  , p_offDiscountProductId   IN NUMBER
  , x_pricingAttrRec        OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_Rec_type
)
IS
CURSOR c_products(cp_offDiscountProductId NUMBER)IS
SELECT a.offer_discount_line_id
, a.product_context
, a.product_attribute
, a.product_attr_value
, a.apply_discount_flag
, a.include_volume_flag
, a.excluder_flag
, b.volume_break_type
, b.volume_type
, b.discount_type
, b.uom_code
FROM ozf_offer_discount_products a, ozf_offer_discount_lines b
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND a.off_discount_product_id = cp_offDiscountProductId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_products IN c_products(cp_offDiscountProductId => p_offDiscountProductId) LOOP
    x_pricingAttrRec.product_attribute_context := l_products.product_context;
    x_pricingAttrRec.product_attribute         := l_products.product_attribute;
    x_pricingAttrRec.product_attr_value        := l_products.product_attr_value;
    x_pricingAttrRec.product_uom_code          := l_products.uom_code;
    x_pricingAttrRec.pricing_attribute_context := 'VOLUME';
    x_pricingAttrRec.pricing_attribute         := l_products.volume_type;
    x_pricingAttrRec.comparison_operator_code   := 'BETWEEN';
--    x_pricingAttrRec.modifiers_index            := i;
    x_pricingAttrRec.operation                  := Qp_Globals.G_OPR_CREATE;
END LOOP;
END populatePricingAttr;

FUNCTION getVOAccrualFlag
(
    p_qpListHeaderId IN NUMBER
) RETURN VARCHAR2 IS
CURSOR c_accrualFlag(cp_qpListHeaderId NUMBER) IS
SELECT decode( VOLUME_OFFER_TYPE, 'ACCRUAL','Y','N')
FROM ozf_offers
WHERE qp_list_header_id = cp_qpListHeaderId;
l_accrualFlag VARCHAR2(1);
BEGIN
    OPEN c_accrualFlag(cp_qpListHeaderId => p_qpListHeaderId);
    FETCH c_accrualFlag INTO l_accrualFlag;
        IF c_accrualFlag%NOTFOUND THEN
            l_accrualFlag := 'Y';
        END IF;
    CLOSE c_accrualFlag;
    RETURN l_accrualFlag;
END getVOAccrualFlag;

FUNCTION getDiscountLineId
(
p_offDiscountProductId IN NUMBER
)
RETURN NUMBER IS
CURSOR c_discountLineId(cp_offDiscountProductId NUMBER) IS
SELECT offer_discount_line_id
FROM ozf_offer_discount_products
WHERE off_discount_product_id = cp_offDiscountProductId ;
l_discountLineId ozf_offer_discount_lines.offer_discount_line_id%TYPE;
BEGIN
OPEN c_discountLineId(cp_offDiscountProductId => p_offDiscountProductId);
FETCH c_discountLineId INTO l_discountLineId;
IF c_discountLineId%NOTFOUND THEN
    l_discountLineId := null;
END IF;
CLOSE c_discountLineId;
return l_discountLineId;
END getDiscountLineId;

PROCEDURE populatePBHRec
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,x_modifiersRec           OUT NOCOPY Qp_Modifiers_Pub.modifiers_rec_type
  ,p_offDiscountProductId   IN NUMBER
  , p_qpListHeaderId        IN NUMBER
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_modifiersRec.operation := QP_GLOBALS.G_OPR_CREATE;
    x_modifiersRec.list_header_id := p_qpListHeaderId;
    x_modifiersRec.list_line_type_code      := 'PBH';
    x_modifiersRec.proration_type_code      := 'N';
    x_modifiersRec.product_precedence       := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');
    x_modifiersRec.incompatibility_grp_code := FND_PROFILE.value('OZF_INCOMPATIBILITY_GROUP');
    x_modifiersRec.print_on_invoice_flag    := 'Y';
    x_modifiersRec.pricing_phase_id         := getPricingPhase(p_listHeaderId => p_qpListHeaderId);
    x_modifiersRec.modifier_level_code      := getDiscountLevel(p_listHeaderId => p_qpListHeaderId);
    x_modifiersRec.automatic_flag := 'Y';
    x_modifiersRec.price_break_type_code := 'RANGE';
    x_modifiersRec.accum_attribute          := 'PRICING_ATTRIBUTE19';
    x_modifiersRec.accrual_flag := getVOAccrualFlag(p_qpListHeaderId => p_qpListHeaderId );
    IF getDiscountLevel(p_listHeaderId => p_qpListHeaderId) <> 'ORDER' THEN
        x_modifiersRec.pricing_group_sequence   := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
    END IF;
    x_modifiersRec.attribute1               := getDiscountLineId(p_offDiscountProductId => p_offDiscountProductId);
END populatePBHRec;


PROCEDURE populateZeroDiscounts
(
    x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                OUT NOCOPY  NUMBER
    ,x_msg_data                 OUT NOCOPY  VARCHAR2
    ,x_modifiersRec             OUT NOCOPY Qp_Modifiers_Pub.modifiers_rec_type
    , p_qpListHeaderId          IN NUMBER
    , p_offDiscountProductId    IN NUMBER
)
IS
CURSOR c_discounts( cp_offDiscountProductId NUMBER) IS
SELECT  a.volume_break_type
, a.discount_type
FROM ozf_offer_discount_lines a, ozf_offer_discount_products b
WHERE a.offer_discount_line_id    = b.offer_discount_line_id
AND b.off_discount_product_id   = cp_offDiscountProductId;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_discounts IN c_discounts(cp_offDiscountProductId => p_offDiscountProductId) LOOP
        x_modifiersRec.operation                := QP_GLOBALS.G_OPR_CREATE;
        x_modifiersRec.list_header_id           := p_qpListHeaderId;
        x_modifiersRec.accrual_flag             := getVOAccrualFlag(p_qpListHeaderId => p_qpListHeaderId );
        x_modifiersRec.list_line_type_code      := 'DIS';
        x_modifiersRec.proration_type_code      := 'N';
        x_modifiersRec.product_precedence       := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');
        x_modifiersRec.print_on_invoice_flag    := 'Y';
        x_modifiersRec.pricing_phase_id         := getPricingPhase(p_listHeaderId => p_qpListHeaderId );
        x_modifiersRec.modifier_level_code      := getDiscountLevel(p_listHeaderId => p_qpListHeaderId );
        x_modifiersRec.automatic_flag           := 'Y';
        x_modifiersRec.price_break_type_code    := l_discounts.volume_break_type;
        x_modifiersRec.arithmetic_operator      := l_discounts.discount_type;
        x_modifiersRec.operand                  := 0;
        x_modifiersRec.price_by_formula_id      := null;
    --    x_modifiersRec.modifiers_index            := k;
        x_modifiersRec.rltd_modifier_grp_type   := 'PRICE BREAK';
        x_modifiersRec.rltd_modifier_grp_no     := 1;
        x_modifiersRec.modifier_parent_index    := 1;
        IF getDiscountLevel(p_listHeaderId => p_qpListHeaderId ) <> 'ORDER' THEN
            x_modifiersRec.pricing_group_sequence   := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
        END IF;
        x_modifiersRec.attribute1               := -1; -- for later identification
END LOOP;
END populateZeroDiscounts;
PROCEDURE populateRegularDiscounts
    (
    x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                OUT NOCOPY  NUMBER
    ,x_msg_data                 OUT NOCOPY  VARCHAR2
    ,x_modifiersRec             OUT NOCOPY Qp_Modifiers_Pub.modifiers_rec_type
    ,p_offerDiscountLineId      IN NUMBER
    , p_qpListHeaderId          IN NUMBER
    , p_offDiscountProductId    IN NUMBER
    )
IS
CURSOR c_discounts(cp_offerDiscountLineId NUMBER , cp_offDiscountProductId NUMBER) IS
SELECT decode(c.apply_discount_flag, 'N',0,a.discount) discount
, decode(c.apply_discount_flag, 'N',null,a.formula_id) formula_id
, b.volume_break_type
, b.discount_type
FROM ozf_offer_discount_lines a, ozf_offer_discount_lines b, ozf_offer_discount_products c
WHERE a.parent_discount_line_id = b.offer_discount_line_id
AND b.offer_discount_line_id    = c.offer_discount_line_id
AND c.excluder_flag             = 'N'
AND c.off_discount_product_id   = cp_offDiscountProductId
AND a.offer_discount_line_id = cp_offerDiscountLineId;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
FOR l_discounts IN c_discounts(cp_offerDiscountLineId => p_offerDiscountLineId , cp_offDiscountProductId => p_offDiscountProductId) LOOP
        x_modifiersRec.operation                := QP_GLOBALS.G_OPR_CREATE;
        x_modifiersRec.list_header_id           := p_qpListHeaderId;
        x_modifiersRec.accrual_flag             := getVOAccrualFlag(p_qpListHeaderId => p_qpListHeaderId );
        x_modifiersRec.list_line_type_code      := 'DIS';
        x_modifiersRec.proration_type_code      := 'N';
        x_modifiersRec.product_precedence       := FND_PROFILE.value('OZF_PRODUCT_PRECEDENCE');
        x_modifiersRec.print_on_invoice_flag    := 'Y';
        x_modifiersRec.pricing_phase_id         := getPricingPhase(p_listHeaderId => p_qpListHeaderId );
        x_modifiersRec.modifier_level_code      := getDiscountLevel(p_listHeaderId => p_qpListHeaderId );
        x_modifiersRec.automatic_flag           := 'Y';
        x_modifiersRec.price_break_type_code    := l_discounts.volume_break_type;
        x_modifiersRec.arithmetic_operator      := l_discounts.discount_type;
        x_modifiersRec.operand                  := l_discounts.discount;
        x_modifiersRec.price_by_formula_id      := l_discounts.formula_id;
    --    x_modifiersRec.modifiers_index            := k;
        x_modifiersRec.rltd_modifier_grp_type   := 'PRICE BREAK';
        x_modifiersRec.rltd_modifier_grp_no     := 1;
        x_modifiersRec.modifier_parent_index    := 1;
        x_modifiersRec.attribute1               := p_offerDiscountLineId; -- for later identification
        IF getDiscountLevel(p_listHeaderId => p_qpListHeaderId ) <> 'ORDER' THEN
            x_modifiersRec.pricing_group_sequence   := FND_PROFILE.value('OZF_PRICING_GROUP_SEQUENCE');
        END IF;
END LOOP;
END populateRegularDiscounts;

FUNCTION getMinVolume
(
p_offDiscountProductId NUMBER
)
RETURN NUMBER
IS
CURSOR c_minVolume(cp_offDiscountProductId NUMBER) IS
SELECT min(volume_from)
FROM ozf_offer_discount_lines a, ozf_offer_discount_products b
WHERE a.parent_discount_line_id = b.offer_discount_line_id
AND b.off_discount_product_id = cp_offDiscountProductId;

l_minVolume OZF_OFFER_DISCOUNT_LINES.volume_from%TYPE;
BEGIN
OPEN c_minVolume(cp_offDiscountProductId => p_offDiscountProductId);
FETCH c_minVolume INTO l_minVolume;
IF c_minVolume%NOTFOUND THEN
    l_minVolume := null;
END IF;
CLOSE c_minVolume;
return l_minVolume;
END getMinVolume;

PROCEDURE populateDISData
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , x_modifiersTbl          OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
  , p_offDiscountProductId  IN NUMBER
  , p_qpListHeaderId        IN NUMBER
)
IS
CURSOR c_discounts(cp_offerDiscountProductId NUMBER) IS
SELECT a.offer_discount_line_id
FROM ozf_offer_discount_lines a, ozf_offer_discount_products b
WHERE a.parent_discount_line_id = b.offer_discount_line_id
AND b.off_discount_product_id = cp_offerDiscountProductId;
i NUMBER;
BEGIN
-- initialize
-- loop thru all discounts records
-- populate regular discount data
-- process for apply discount flag
x_return_status := FND_API.G_RET_STS_SUCCESS;
i := 1;
IF getMinVolume(p_offDiscountProductId => p_offDiscountProductId) <> 0 THEN
populateZeroDiscounts
(
    x_return_status             => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      , x_modifiersRec          => x_modifiersTbl(i)
      , p_qpListHeaderId        => p_qpListHeaderId
      , p_offDiscountProductId  => p_offDiscountProductId
);
i := i + 1;
END IF;

FOR l_discounts in c_discounts(cp_offerDiscountProductId => p_offDiscountProductId) LOOP
    populateRegularDiscounts
    (
    x_return_status             => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      , x_modifiersRec          => x_modifiersTbl(i)
      , p_offerDiscountLineId   => l_discounts.offer_discount_line_id
      , p_qpListHeaderId        => p_qpListHeaderId
      , p_offDiscountProductId  => p_offDiscountProductId
    );
    i := i +1;
END LOOP;
END populateDISData;


PROCEDURE populateModifiers
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_qp_list_header_id     IN NUMBER
  , p_offDiscountProductId  IN NUMBER
  , x_modifiersTbl        OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
)
IS
  l_modifiersRec        Qp_Modifiers_Pub.modifiers_rec_type;
  l_modifiersTbl        Qp_Modifiers_Pub.modifiers_tbl_type;
  v_modifiersTbl        Qp_Modifiers_Pub.modifiers_tbl_type;
  i NUMBER;
BEGIN
-- initialize
-- populate PBH data
-- populate DIS data
x_return_status := FND_API.G_RET_STS_SUCCESS;
populatePBHRec
(
x_return_status             => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , x_modifiersRec          => l_modifiersRec
  , p_qpListHeaderId        => p_qp_list_header_id
  , p_offDiscountProductId  => p_offDiscountProductId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populateDISData
(
x_return_status             => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , x_modifiersTbl          => v_modifiersTbl
  , p_qpListHeaderId        => p_qp_list_header_id
  , p_offDiscountProductId  => p_offDiscountProductId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_modifiersTbl(1) := l_modifiersRec;
i := 2;
IF nvl(v_modifiersTbl.count,0) > 0 THEN
    FOR j in v_modifiersTbl.first .. v_modifiersTbl.last LOOP
        IF v_modifiersTbl.exists(j) THEN
            x_modifiersTbl(i) := v_modifiersTbl(j);
            i := i+1;
        END IF;
    END LOOP;
END IF;
END populateModifiers;

PROCEDURE processPricingAttr
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  ,x_pricingAttrRec         IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_Rec_type
  ,p_offerDiscountLineId    IN NUMBER
  ,p_offDiscountProductId   IN NUMBER
)
IS
CURSOR c_volume(cp_offerDiscountLineId NUMBER) IS
SELECT volume_from, volume_to
FROM ozf_offer_discount_lines
WHERE offer_discount_line_id = cp_offerDiscountLineId ;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_offerDiscountLineId  = -1 THEN
        x_pricingAttrRec.pricing_attr_value_from    := 0;
        x_pricingAttrRec.pricing_attr_value_to      := getMinVolume(p_offDiscountProductId => p_offDiscountProductId);
    ELSE
        FOR l_volume IN c_volume(cp_offerDiscountLineId => to_number(p_offerDiscountLineId)) LOOP
            x_pricingAttrRec.pricing_attr_value_from    := l_volume.volume_from;
            x_pricingAttrRec.pricing_attr_value_to      := l_volume.volume_to;
        END LOOP;
    END IF;
END processPricingAttr;

PROCEDURE processData
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , x_modifiersTbl          IN  Qp_Modifiers_Pub.modifiers_tbl_type
  , x_pricingAttrTbl        IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
  , x_pricingAttrRec        IN Qp_Modifiers_Pub.pricing_attr_Rec_type
  , p_offDiscountProductId  IN NUMBER
)
IS
BEGIN
-- initialise
-- loop thru modifiers tbl
--- for list_line_type_code = PBH simply assign the pricing attr rec
-- for list_line_type_code = DIS populate the volume from and volume to in the pricing attr table
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(x_modifiersTbl.count,0) > 0 THEN
    FOR i in x_modifiersTbl.first .. x_modifiersTbl.last LOOP
        IF x_modifiersTbl.exists(i) THEN
        x_pricingAttrTbl(i)                 := x_pricingAttrRec;
        x_pricingAttrTbl(i).modifiers_index := i;
        IF x_modifiersTbl(i).list_line_type_code = 'DIS' THEN
            processPricingAttr
            (
                x_return_status             => x_return_status
                  ,x_msg_count              => x_msg_count
                  ,x_msg_data               => x_msg_data
                  ,p_offerDiscountLineId    => to_number(x_modifiersTbl(i).attribute1)
                  , p_offDiscountProductId  => p_offDiscountProductId
                  ,x_pricingAttrRec         => x_pricingAttrTbl(i)
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        END IF;
    END LOOP;
END IF;
END processData;

PROCEDURE populateExclusions
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_qpListHeaderId        IN NUMBER
  , x_pricingAttrTbl        IN OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
CURSOR c_exclusions(cp_qpListHeaderId IN NUMBER) IS
SELECT a.product_attribute, a.product_attr_value, a.excluder_flag
FROM ozf_offer_discount_products a,  ozf_offers b
WHERE a.offer_id = b.offer_id
AND a.excluder_flag             = 'Y'
AND b.qp_list_header_id = cp_qpListHeaderId;
i NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
i := nvl(x_pricingAttrTbl.count,0) +1;
FOR l_exclusions IN c_exclusions(cp_qpListHeaderId => p_qpListHeaderId) LOOP
x_pricingAttrTbl(i).product_attribute_context   := 'ITEM';
x_pricingAttrTbl(i).product_attribute := l_exclusions.product_attribute;
x_pricingAttrTbl(i).product_attr_value:= l_exclusions.product_attr_value;
x_pricingAttrTbl(i).excluder_flag     := l_exclusions.excluder_flag;
x_pricingAttrTbl(i).modifiers_index   := 1;
x_pricingAttrTbl(i).operation         := QP_GLOBALS.G_OPR_CREATE;
i := i + 1;
END LOOP;
END populateExclusions;


PROCEDURE relateOzfQpDiscounts
(
    x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count              OUT NOCOPY  NUMBER
    ,x_msg_data               OUT NOCOPY  VARCHAR2
    ,p_modifiersTbl           IN qp_modifiers_pub.modifiers_tbl_type
)
IS
l_discRec OZF_QP_DISCOUNTS_PVT.qp_discount_rec_type;
l_qpDiscountId NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(p_modifiersTbl.count,0) > 0 THEN
FOR i in p_modifiersTbl.first .. p_modifiersTbl.last LOOP
IF p_modifiersTbl.exists(i) THEN
    IF p_modifiersTbl(i).attribute1 <> '-1' THEN
        l_discRec.list_line_id              := p_modifiersTbl(i).list_line_id;
        l_discRec.offer_discount_line_id    := to_number(p_modifiersTbl(i).attribute1);
        OZF_QP_DISCOUNTS_PVT.Create_ozf_qp_discount
        (
            p_api_version_number         => 1.0
            , p_init_msg_list              => FND_API.G_FALSE
            , p_commit                     => FND_API.G_FALSE
            , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_qp_disc_rec                => l_discRec
            , x_qp_discount_id             => l_qpDiscountId
        );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;
    END IF;
END IF;
END LOOP;
END IF;
END relateOzfQpDiscounts;

PROCEDURE relateOzfQpProducts
(
    x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                OUT NOCOPY  NUMBER
    ,x_msg_data                 OUT NOCOPY  VARCHAR2
    ,p_pricingAttrTbl           IN qp_modifiers_pub.pricing_attr_tbl_type
    ,p_offDiscountProductId     IN NUMBER
)
IS
l_prodRec OZF_QP_PRODUCTS_PVT.qp_product_rec_type;
l_qpProductId NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF nvl(p_pricingAttrTbl.count,0) > 0 THEN
    FOR i in p_pricingAttrTbl.first .. p_pricingAttrTbl.last LOOP
        IF p_pricingAttrTbl.exists(i) THEN
            IF p_pricingAttrTbl(i).excluder_flag <> 'Y' THEN
                l_prodRec.pricing_attribute_id      := p_pricingAttrTbl(i).pricing_attribute_id;
                l_prodRec.off_discount_product_id    := p_offDiscountProductId;
                OZF_QP_PRODUCTS_PVT.Create_ozf_qp_product
                (
                    p_api_version_number         => 1.0
                    , p_init_msg_list              => FND_API.G_FALSE
                    , p_commit                     => FND_API.G_FALSE
                    , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                    , x_return_status              => x_return_status
                    , x_msg_count                  => x_msg_count
                    , x_msg_data                   => x_msg_data
                    , p_qp_product_rec             => l_prodRec
                    , x_qp_product_id             => l_qpProductId
                );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    return;
                END IF;
            END IF;
        END IF;
    END LOOP;
END IF;
END relateOzfQpProducts;

PROCEDURE relateOzfQp
    (
    x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count              OUT NOCOPY  NUMBER
    ,x_msg_data               OUT NOCOPY  VARCHAR2
    ,p_modifiersTbl           IN qp_modifiers_pub.modifiers_tbl_type
    ,p_pricingAttrTbl         IN qp_modifiers_pub.pricing_attr_tbl_type
    ,p_offDiscountProductId   IN NUMBER
    )
IS
BEGIN
-- initialize
-- relate discounts
-- relate products
x_return_status := FND_API.G_RET_STS_SUCCESS;
relateOzfQpDiscounts
(
    x_return_status          => x_return_status
    ,x_msg_count             => x_msg_count
    ,x_msg_data              => x_msg_data
    ,p_modifiersTbl          => p_modifiersTbl
);
IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
END IF;
relateOzfQpProducts
(
    x_return_status          => x_return_status
    ,x_msg_count             => x_msg_count
    ,x_msg_data              => x_msg_data
    ,p_pricingAttrTbl          => p_pricingAttrTbl
    ,p_offDiscountProductId    => p_offDiscountProductId
);
IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
END IF;
END relateOzfQp;

PROCEDURE pushDiscountRuleToQp
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_qp_list_header_id     IN NUMBER
  , p_offDiscountProductId  IN NUMBER
  , x_error_location        OUT NOCOPY NUMBER
  , x_modifiersTbl          OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
  , x_pricingAttrTbl        OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
l_pricingAttrTbl        Qp_Modifiers_Pub.pricing_attr_tbl_type;
l_pricingAttrRec        Qp_Modifiers_Pub.pricing_attr_Rec_type;
l_modifiersTbl          Qp_Modifiers_Pub.modifiers_tbl_type;

 v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
 v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
 v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
 v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
 v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
 v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
 v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
 v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
 l_control_rec            qp_globals.control_rec_type;
BEGIN
-- initialize
-- for the product populate pricing attribute
-- populate discount structure
-- assign modifier index to each pricing attribute rec
-- push data to QP
-- process errors
x_return_status := FND_API.G_RET_STS_SUCCESS;
populatePricingAttr
(
x_return_status             => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_qp_list_header_id     => p_qp_list_header_id
  ,p_offDiscountProductId  => p_offDiscountProductId
  ,x_pricingAttrRec        => l_pricingAttrRec
);

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populateModifiers
(
x_return_status             => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , p_qp_list_header_id     => p_qp_list_header_id
  , p_offDiscountProductId  => p_offDiscountProductId
  , x_modifiersTbl          => l_modifiersTbl
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
processData
(
x_return_status              => x_return_status
  , x_msg_count              => x_msg_count
  , x_msg_data               => x_msg_data
  , x_modifiersTbl           => l_modifiersTbl
  , x_pricingAttrRec         => l_pricingAttrRec
  , x_pricingAttrTbl         => l_pricingAttrTbl
  , p_offDiscountProductId  => p_offDiscountProductId
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
populateExclusions
(
x_return_status              => x_return_status
  , x_msg_count              => x_msg_count
  , x_msg_data               => x_msg_data
  , p_qpListHeaderId         => p_qp_list_header_id
  , x_pricingAttrTbl         => l_pricingAttrTbl

);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

   QP_Modifiers_PUB.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifiersTbl,
      p_pricing_attr_tbl       => l_pricingAttrTbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;
    x_modifiersTbl      := v_modifiers_tbl;
    x_pricingAttrTbl    := v_pricing_attr_tbl;
END pushDiscountRuleToQp;

PROCEDURE pushDiscountRuleToQpAndRelate
(
x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2
  , p_qp_list_header_id     IN NUMBER
  , p_offDiscountProductId  IN NUMBER
  , x_error_location        OUT NOCOPY NUMBER
  , x_modifiersTbl          OUT NOCOPY Qp_Modifiers_Pub.modifiers_tbl_type
  , x_pricingAttrTbl        OUT NOCOPY Qp_Modifiers_Pub.pricing_attr_tbl_type
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
pushDiscountRuleToQp
(
    x_return_status          => x_return_status
    , x_msg_count              => x_msg_count
    , x_msg_data               => x_msg_data
    , p_qp_list_header_id     => p_qp_list_header_id
    , p_offDiscountProductId  => p_offDiscountProductId
    , x_error_location        => x_error_location
    , x_modifiersTbl          => x_modifiersTbl
    , x_pricingAttrTbl        => x_pricingAttrTbl
);
IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    return;
END IF;
relateOzfQp
(
    x_return_status          => x_return_status
    , x_msg_count              => x_msg_count
    , x_msg_data               => x_msg_data
    , p_modifiersTbl              => x_modifiersTbl
    , p_pricingAttrTbl          => x_pricingAttrTbl
    , p_offDiscountProductId    => p_offDiscountProductId
);
IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    return;
END IF;
END pushDiscountRuleToQpAndRelate;
/*
This procedure pushes OZF data into qp for pricing execution
There is no one to one mapping between ozf and qp data. the Mapping is slighly more complicated.
The logic for mapping is as
-- for regular product records and product records with include volume = 'N' and apply discount as 'Y'
create the whole discount structure for each product
-- for product records with include volume = Y and apply discount = N create a simple discount record with 0% discount
-- for exclusions there is a separate processing
-- for a product to be excluded from an ozf discount structure, it should be excluded from all the discount structures created in qp
-- the logic used is
-- parse thru the modifier table. For each record with list_line_type_code = 'PBH' create a pricing_attribute_record. relate the two
-- using modifier_index of the modifier record in the modifier table. Add this pricing record to the pricing_attr_tbl

*/
PROCEDURE push_discount_rules_to_qp
(
   p_init_msg_list         IN   VARCHAR2
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  , p_qp_list_header_id    IN NUMBER
  , x_error_location       OUT NOCOPY NUMBER
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'push_discount_rules_to_qp';
l_api_version_number CONSTANT NUMBER := 1.0;

CURSOR c_products(cp_qpListHeaderId NUMBER)IS
SELECT a.off_discount_product_id
FROM ozf_offer_discount_products a, ozf_offers b
WHERE a.offer_id = b.offer_id
AND a.excluder_flag = 'N'
AND b.qp_list_header_id = cp_qpListHeaderId;

  l_modifiersTbl          Qp_Modifiers_Pub.modifiers_tbl_type;
  l_pricingAttrTbl        Qp_Modifiers_Pub.pricing_attr_tbl_type;
  l_errorLocation   NUMBER;
BEGIN
-- initialize
SAVEPOINT push_disc_rules;
x_return_status := Fnd_Api.g_ret_sts_success;

FOR l_products in c_products(cp_qpListHeaderId => p_qp_list_header_id) LOOP
pushDiscountRuleToQpAndRelate
(
x_return_status             => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  , p_qp_list_header_id     => p_qp_list_header_id
  , p_offDiscountProductId  => l_products.off_discount_product_id
  , x_error_location        => l_errorLocation
  , x_modifiersTbl          => l_modifiersTbl
  , x_pricingAttrTbl        => l_pricingAttrTbl
);
 IF x_return_status = Fnd_Api.g_ret_sts_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_error;
 ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    add_message(x_msg_count);
    RAISE Fnd_Api.g_exc_unexpected_error;
 END IF;
END LOOP;



   IF p_commit = Fnd_Api.g_true THEN
      COMMIT WORK;
   END IF;
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO push_disc_rules;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO push_disc_rules;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO push_disc_rules;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

/*1. Get Discount Structures
For each discount structure
        get the Discounts
        Get products
        populate discount and product records
        create data in qp
        get data created
        create relation ship*/
END push_discount_rules_to_qp;

FUNCTION get_grace_days(p_sdr_header_id IN NUMBER)
RETURN NUMBER
IS
  p_grace_days NUMBER := 0;
  l_supplier_site_id NUMBER;



  CURSOR c_get_supplier_site_id(l_sdr_header_id NUMBER) IS
  SELECT supplier_site_id
    FROM ozf_sd_request_headers_all_b
   WHERE request_header_id = l_sdr_header_id;



  CURSOR c_get_grace_days(l_supplier_site_id NUMBER) IS
  SELECT nvl(grace_days,0)
    FROM ozf_supp_trd_prfls_all
   WHERE supplier_site_id = l_supplier_site_id;


BEGIN

  --dbms_output.put_line('N get_grace_days '||p_sdr_header_id);

  OPEN c_get_supplier_site_id( p_sdr_header_id ) ;
  FETCH c_get_supplier_site_id INTO l_supplier_site_id ;
  CLOSE c_get_supplier_site_id ;


  --dbms_output.put_line('N supplier_site_id '||l_supplier_site_id);

  OPEN c_get_grace_days( l_supplier_site_id ) ;
  FETCH c_get_grace_days INTO p_grace_days ;
  CLOSE c_get_grace_days ;



  --dbms_output.put_line('N grace_days '||p_grace_days);

    RETURN p_grace_days;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
END;

/*
This procedure creates SD offer header record.
*/

PROCEDURE populateSDHeaderRec(
         x_return_status          OUT     NOCOPY  VARCHAR2
        ,x_msg_count              OUT     NOCOPY  NUMBER
        ,x_msg_data               OUT     NOCOPY  VARCHAR2
        ,p_operation               IN             VARCHAR2
        ,p_sdr_header_id           IN             NUMBER
        ,p_qp_list_header_id       IN             NUMBER
        ,x_modifier_list_rec       OUT NOCOPY     Modifier_LIST_Rec_Type
)
IS

  CURSOR c_offer_info(l_qp_list_header_id NUMBER) IS
  SELECT offer_id, offer_type, custom_setup_id, offer_code, tier_level, object_version_number
    FROM ozf_offers
   WHERE qp_list_header_id = l_qp_list_header_id;


  CURSOR c_sdr_info(l_sdr_header_id NUMBER) IS
  SELECT sales_order_currency,
         request_currency_code,
         request_start_date,
         request_end_date,
         authorization_number,
         request_number,
         asignee_resource_id,
         request_basis,
         org_id
    FROM ozf_sd_request_headers_all_b
   WHERE request_header_id = l_sdr_header_id;


   l_modifier_list_rec      Modifier_LIST_Rec_Type;

   l_sales_order_currency   VARCHAR2(30);
   l_request_currency_code  VARCHAR2(30);
   l_start_date_active      DATE;
   l_end_date_active        DATE;
   l_authorization_number   VARCHAR2(3000);
   l_request_number         VARCHAR2(3000);
   l_asignee_resource_id    NUMBER;
   l_request_basis          VARCHAR2(1);
   l_org_id                 NUMBER;

BEGIN

SAVEPOINT populateSDHeaderRec;


    IF p_operation='UPDATE' THEN
        OPEN c_offer_info(p_qp_list_header_id);
        FETCH c_offer_info INTO x_modifier_list_rec.offer_id,
                                x_modifier_list_rec.offer_type,
                                x_modifier_list_rec.custom_setup_id,
                                x_modifier_list_rec.offer_code,
                                x_modifier_list_rec.tier_level,
                                x_modifier_list_rec.object_version_number;
        CLOSE c_offer_info;


        x_modifier_list_rec.STATUS_CODE                   := 'ACTIVE';
        --l_modifier_list_rec.USER_STATUS_ID                := p_modifier_list_rec.USER_STATUS_ID;
        x_modifier_list_rec.ACTIVE_FLAG                   := 'Y';

    END IF;

    IF p_operation='CREATE' THEN
        x_modifier_list_rec.OFFER_TYPE                    := 'ACCRUAL';
        x_modifier_list_rec.CUSTOM_SETUP_ID               := 118;
        x_modifier_list_rec.OBJECT_VERSION_NUMBER         := 1;
        x_modifier_list_rec.STATUS_CODE                   := 'DRAFT';
        x_modifier_list_rec.STATUS_DATE                   := sysdate;
        x_modifier_list_rec.ACTIVE_FLAG                   := 'N';

    END IF;

    x_modifier_list_rec.MODIFIER_LEVEL_CODE               := 'LINE';
    x_modifier_list_rec.BUDGET_AMOUNT_TC                  := 0;
    x_modifier_list_rec.OFFER_AMOUNT                      := 0;
    x_modifier_list_rec.LIST_TYPE_CODE                    := 'PRO';


    OPEN  c_sdr_info(p_sdr_header_id);
    FETCH c_sdr_info INTO l_sales_order_currency,
                          l_request_currency_code,
                          l_start_date_active,
                          l_end_date_active,
                          l_authorization_number,
                          l_request_number,
                          l_asignee_resource_id,
                          l_request_basis,
                          l_org_id;
    CLOSE c_sdr_info;

/*uncomment offer code */

debug_message('N: populateSDHeaderRec' || l_sales_order_currency);
debug_message('N: populateSDHeaderRec' || l_request_currency_code);

    x_modifier_list_rec.TRANSACTION_CURRENCY_CODE     := NVL(l_sales_order_currency, l_request_currency_code);
    x_modifier_list_rec.CURRENCY_CODE                 := NVL(l_sales_order_currency, l_request_currency_code);
    x_modifier_list_rec.START_DATE_ACTIVE             := trunc(l_start_date_active);
    x_modifier_list_rec.END_DATE_ACTIVE               := trunc(l_end_date_active + get_grace_days(p_sdr_header_id));
    x_modifier_list_rec.NAME                          := NVL(l_authorization_number, l_request_number);
    x_modifier_list_rec.DESCRIPTION                   := NVL(l_authorization_number, l_request_number);
    --fix for bug 7580884
    x_modifier_list_rec.OFFER_CODE                    := l_request_number; --NVL(l_authorization_number, l_request_number);
    x_modifier_list_rec.COMMENTS                      := FND_MESSAGE.GET_STRING('OZF','OZF_SD_OFFER_COMMENTS');
    x_modifier_list_rec.ASK_FOR_FLAG                  := NVL(l_request_basis,'N');

   IF l_org_id IS NOT NULL AND l_org_id <> FND_API.G_MISS_NUM
        AND NVL(fnd_profile.value('QP_SECURITY_CONTROL'), 'OFF') <> 'OFF' THEN
        x_modifier_list_rec.global_flag                   := 'N';
        x_modifier_list_rec.orig_org_id                   :=  l_org_id;
    ELSE
        x_modifier_list_rec.global_flag                   := 'Y';
    END IF;

   -- x_modifier_list_rec.global_flag                   := 'Y';

    x_modifier_list_rec.BUDGET_SOURCE_ID              := FND_PROFILE.VALUE('OZF_SD_DEFAULT_BUDGET');
    x_modifier_list_rec.BUDGET_SOURCE_TYPE            := 'FUND';

    x_modifier_list_rec.OFFER_OPERATION               := p_operation;
    x_modifier_list_rec.MODIFIER_OPERATION            := p_operation;
    x_modifier_list_rec.OWNER_ID                      := l_asignee_resource_id;

debug_message('N: populateSDHeaderRec x_modifier_list_rec.TRANSACTION_CURRENCY_CODE ' || x_modifier_list_rec.TRANSACTION_CURRENCY_CODE);

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO populateSDHeaderRec;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO populateSDHeaderRec;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO populateSDHeaderRec;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,'populateSDHeaderRec');
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END populateSDHeaderRec;


/*
This procedure creates SD offer discount line records.
The mapping b/w QP and SDR lines is stored in orig_sys_line_ref and orig_sys_header_ref
columns in tables qp_list_lines and qp_pricing_attributes
*/

PROCEDURE populateSDDiscountRulesRec(
         x_return_status           OUT NOCOPY  VARCHAR2
        ,x_msg_count               OUT NOCOPY  NUMBER
        ,x_msg_data                OUT NOCOPY  VARCHAR2
        ,p_operation               IN VARCHAR2
        ,p_sdr_header_id           IN NUMBER
        ,p_qp_list_header_id       IN NUMBER
        ,x_modifier_line_tbl       OUT NOCOPY     modifier_line_tbl_type
)
IS

l_modifier_line_tbl     MODIFIER_LINE_TBL_TYPE;
l_supplier_site_id      NUMBER;
l_allow_qty_increase    VARCHAR2(1);
l_prod_index            NUMBER := 1;
l_list_line_id          NUMBER;
l_orig_sys_line_ref_id  NUMBER;
l_converted_amt         NUMBER;
l_rate                  NUMBER;
l_request_currency_code VARCHAR2(15);
l_sales_order_currency  VARCHAR2(15);
l_limit_id              NUMBER;


  CURSOR  cur_get_disc_lines IS
  SELECT  request_line_id,product_context,
          prod_catg_id,inventory_item_id,
          item_uom,product_cost,
          product_cost_currency,
          requested_discount_type,
          requested_discount_value,
          approved_discount_type,
          approved_discount_value,
          approved_discount_currency,
          requested_discount_currency,
          cost_basis,limit_qty,
          start_date,end_date
   FROM   ozf_sd_request_lines_all
  WHERE   request_header_id = p_sdr_header_id
    AND   vendor_approved_flag='Y';

  CURSOR  cur_get_sys_line_ref_id(p_request_line_id NUMBER,p_qp_list_header_id NUMBER) IS
  SELECT  list_line_no,list_line_id
   FROM   qp_list_lines
  WHERE   list_line_no = to_char(p_request_line_id)
    AND   list_header_id = p_qp_list_header_id  ;

  CURSOR  cur_get_header_info IS
  SELECT  sales_order_currency,
          request_currency_code,
          supplier_site_id
    FROM  ozf_sd_request_headers_all_b
   WHERE  request_header_id = p_sdr_header_id;

  CURSOR  cur_get_qty_inc_flag(p_supplier_site_id NUMBER) IS
  SELECT  allow_qty_increase
    FROM  ozf_supp_trd_prfls_all
   WHERE  supplier_site_id = p_supplier_site_id;


  CURSOR cur_get_limit_id(p_list_line_id NUMBER) IS
  SELECT limit_id
    FROM qp_limits
   WHERE list_line_id = p_list_line_id
     AND limit_number = 3;

BEGIN
SAVEPOINT populateSDDiscountRulesRec;




  x_return_status := Fnd_Api.g_ret_sts_success;
  --x_error_location := 0;

debug_message('N: populateSDDiscountRulesRec' || p_operation);

    FOR line_rec IN cur_get_disc_lines LOOP
      debug_message('N: request_line_id' || line_rec.request_line_id);
      debug_message('N: l_prod_index' || l_prod_index);
      --IF p_operation = 'UPDATE' THEN
      debug_message('N: p_qp_list_header_id' || p_qp_list_header_id);
            OPEN cur_get_sys_line_ref_id(line_rec.request_line_id,p_qp_list_header_id);
            FETCH cur_get_sys_line_ref_id INTO l_orig_sys_line_ref_id,l_list_line_id;
            CLOSE cur_get_sys_line_ref_id;
            --dbms_output.put_line('N: l_list_line_id' || l_list_line_id);

     -- END IF;

      debug_message('N: l_orig_sys_line_ref_id' || l_orig_sys_line_ref_id);
      IF l_orig_sys_line_ref_id IS NULL OR l_orig_sys_line_ref_id=FND_API.G_MISS_NUM THEN
      x_modifier_line_tbl(l_prod_index).OPERATION                   := 'CREATE';
      ELSE
      x_modifier_line_tbl(l_prod_index).OPERATION                   := 'UPDATE';
      x_modifier_line_tbl(l_prod_index).list_line_id                := l_list_line_id;

      OPEN cur_get_limit_id(l_list_line_id);
      FETCH cur_get_limit_id INTO l_limit_id;
      CLOSE cur_get_limit_id;

      x_modifier_line_tbl(l_prod_index).MAX_QTY_PER_RULE_ID        := l_limit_id;

      END IF;
      debug_message('N: list_line_id' || x_modifier_line_tbl(l_prod_index).list_line_id);
      debug_message('N: OPERATION' || x_modifier_line_tbl(l_prod_index).OPERATION );

      debug_message('N: line_rec.request_line_id ' ||  line_rec.request_line_id );
      x_modifier_line_tbl(l_prod_index).LIST_LINE_NO                := to_char(line_rec.request_line_id);
      debug_message('N:  x_modifier_line_tbl(l_prod_index).LIST_LINE_NO ' ||  x_modifier_line_tbl(l_prod_index).LIST_LINE_NO );
      x_modifier_line_tbl(l_prod_index).LIST_HEADER_ID              := p_qp_list_header_id;
          --dbms_output.put_line('N: x_modifier_line_tbl(l_prod_index).LIST_HEADER_ID ' || x_modifier_line_tbl(l_prod_index).LIST_HEADER_ID);
      x_modifier_line_tbl(l_prod_index).LIST_LINE_TYPE_CODE         := 'DIS';
      x_modifier_line_tbl(l_prod_index).OPERAND                     := NVL(line_rec.approved_discount_value, line_rec.requested_discount_value);
      x_modifier_line_tbl(l_prod_index).ARITHMETIC_OPERATOR         := NVL(line_rec.approved_discount_type, line_rec.requested_discount_type);

      --if discount type is NEWPRICE get the discount amount
      --if discount type is Amount/Newprice do the currency conevrsion
      --Use sysdate as exchange date

      debug_message('ARITHMETIC_OPERATOR '||x_modifier_line_tbl(l_prod_index).ARITHMETIC_OPERATOR);



      debug_message('product_cost_currency '|| line_rec.product_cost_currency);
      debug_message('approved_discount_currency '|| line_rec.approved_discount_currency);
      debug_message('requested_discount_currency '|| line_rec.requested_discount_currency);
      debug_message('OPERAND '|| x_modifier_line_tbl(l_prod_index).OPERAND);

      IF x_modifier_line_tbl(l_prod_index).ARITHMETIC_OPERATOR = 'NEWPRICE' THEN

      IF line_rec.product_cost_currency
         <> NVL(line_rec.approved_discount_currency,line_rec.requested_discount_currency) THEN

         ozf_utility_pvt.convert_currency (
            x_return_status=> x_return_status,
            p_from_currency=> line_rec.product_cost_currency,
            p_to_currency=> NVL(line_rec.approved_discount_currency,line_rec.requested_discount_currency),
            p_conv_date=> sysdate,
            p_from_amount=> line_rec.product_cost,
            x_to_amount=> l_converted_amt
            );

            debug_message('l_converted_amt '|| l_converted_amt);

            line_rec.product_cost := l_converted_amt;

        END IF;

        x_modifier_line_tbl(l_prod_index).ARITHMETIC_OPERATOR := 'AMT';
        x_modifier_line_tbl(l_prod_index).OPERAND             := line_rec.product_cost - x_modifier_line_tbl(l_prod_index).OPERAND;

       END IF;






      OPEN cur_get_header_info;
      FETCH cur_get_header_info INTO l_sales_order_currency,
                                     l_request_currency_code,
                                     l_supplier_site_id;
      CLOSE cur_get_header_info;

      --dbms_output.put_line('l_converted_amt '|| l_converted_amt);


      IF x_modifier_line_tbl(l_prod_index).ARITHMETIC_OPERATOR = 'AMT'
      AND  NVL(line_rec.approved_discount_currency,line_rec.requested_discount_currency)
       <> NVL(l_sales_order_currency,l_request_currency_code) THEN
      ozf_utility_pvt.convert_currency (
            x_return_status=> x_return_status,
            p_from_currency=> NVL(line_rec.approved_discount_currency,line_rec.requested_discount_currency),
            p_to_currency=> NVL(l_sales_order_currency,l_request_currency_code),
            p_conv_date=> sysdate,
            p_from_amount=> x_modifier_line_tbl(l_prod_index).OPERAND,
            x_to_amount=> l_converted_amt
            );
        x_modifier_line_tbl(l_prod_index).OPERAND := l_converted_amt;
      END IF;

      IF line_rec.product_context = 'PRODUCT' THEN
            x_modifier_line_tbl(l_prod_index).PRODUCT_ATTR          := 'PRICING_ATTRIBUTE1';
            x_modifier_line_tbl(l_prod_index).PRODUCT_ATTR_VAL      := line_rec.inventory_item_id;
      Else
            x_modifier_line_tbl(l_prod_index).PRODUCT_ATTR          := 'PRICING_ATTRIBUTE2';
            x_modifier_line_tbl(l_prod_index).PRODUCT_ATTR_VAL      := line_rec.prod_catg_id;
      END IF;


      x_modifier_line_tbl(l_prod_index).PRODUCT_UOM_CODE            := line_rec.item_uom;
      x_modifier_line_tbl(l_prod_index).MAX_QTY_PER_RULE            := line_rec.limit_qty;
      x_modifier_line_tbl(l_prod_index).START_DATE_ACTIVE           := trunc(line_rec.start_date);
      -- fix for bug 7584161
      --x_modifier_line_tbl(l_prod_index).END_DATE_ACTIVE             := trunc(line_rec.end_date);
      x_modifier_line_tbl(l_prod_index).END_DATE_ACTIVE             := trunc(line_rec.end_date+get_grace_days(p_sdr_header_id));
      x_modifier_line_tbl(l_prod_index).GENERATE_USING_FORMULA_ID   := line_rec.cost_basis;

      IF l_supplier_site_id IS NOT NULL
       AND l_supplier_site_id <> FND_API.G_MISS_NUM AND x_modifier_line_tbl(l_prod_index).OPERATION = 'CREATE' THEN

      OPEN cur_get_qty_inc_flag(l_supplier_site_id);
      FETCH cur_get_qty_inc_flag INTO l_allow_qty_increase;
      CLOSE cur_get_qty_inc_flag;

      IF l_allow_qty_increase = 'Y' THEN
        x_modifier_line_tbl(l_prod_index).LIMIT_EXCEED_ACTION_CODE  := 'SOFT';
      ELSE
      x_modifier_line_tbl(l_prod_index).LIMIT_EXCEED_ACTION_CODE  := 'HARD';
      END IF;

      END IF;

      l_orig_sys_line_ref_id := NULL;
      l_list_line_id := NULL;
      l_limit_id := FND_API.G_MISS_NUM;

      l_prod_index := l_prod_index+1;
  END LOOP;



  EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO populateSDDiscountRulesRec;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO populateSDDiscountRulesRec;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO populateSDDiscountRulesRec;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,'populateSDDiscountRulesRec');
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END populateSDDiscountRulesRec;

/*
This procedure creates SD offer qualifier line records.
*/

PROCEDURE populateSDQualifiers(
         x_return_status           OUT NOCOPY  VARCHAR2
        ,x_msg_count               OUT NOCOPY  NUMBER
        ,x_msg_data                OUT NOCOPY  VARCHAR2
        ,p_sdr_header_id           IN NUMBER
        ,p_qp_list_header_id       IN NUMBER
        ,x_qualifier_tbl           OUT NOCOPY   qualifiers_tbl_type
)
IS

l_qualifier_tbl         qualifiers_tbl_type;
l_site_use_id           NUMBER;
l_cust_acct_id          NUMBER;
l_cust_seq_id           NUMBER;
l_cust_add_type_code    VARCHAR2(250);
l_cust_type_code        VARCHAR2(250);
l_qual_index            NUMBER:= 1;
l_end_cust_count        NUMBER:=0;
l_qualifier_grouping_no NUMBER:=10;
l_internal_order_number NUMBER;
l_order_header_id       NUMBER;
l_org_id                NUMBER;

  CURSOR  cur_get_cust_qual_lines IS
  SELECT  request_customer_id,party_id,
          cust_account_id,site_use_id,
          cust_usage_code,end_customer_flag
   FROM   ozf_sd_customer_details
  WHERE   request_header_id = p_sdr_header_id;

  CURSOR  cur_get_end_cust_qual_lines IS
  SELECT  request_customer_id,party_id,
          cust_account_id,site_use_id,
          cust_usage_code,end_customer_flag
   FROM   ozf_sd_customer_details
  WHERE   request_header_id = p_sdr_header_id;

  CURSOR  cur_get_end_cust_count IS
  SELECT  count(request_customer_id)
    FROM  ozf_sd_customer_details
   WHERE  request_header_id = p_sdr_header_id
     AND  end_customer_flag = 'Y';

  CURSOR  cur_get_old_qualifiers IS
  SELECT  qualifier_id
    FROM  qp_qualifiers
   WHERE  list_header_id = p_qp_list_header_id;

  CURSOR  cur_get_internal_order_number IS
  SELECT  internal_order_number,org_id
    FROM  ozf_sd_request_headers_all_b
   WHERE  request_header_id = p_sdr_header_id;

  CURSOR  cur_get_order_header_id (p_internal_order_number NUMBER,p_org_id NUMBER)IS
  SELECT  header_id
    FROM  oe_order_headers_all
   WHERE  order_number = p_internal_order_number
     AND  org_id=p_org_id;

BEGIN
SAVEPOINT populateSDQualifiers;

    x_return_status := Fnd_Api.g_ret_sts_success;
   --x_error_location := 0;
   debug_message('N: populateSDQualifiers' || p_qp_list_header_id);

    OPEN cur_get_end_cust_count;
    FETCH cur_get_end_cust_count INTO l_end_cust_count;
    CLOSE cur_get_end_cust_count;

    debug_message('N: populateSDQualifiers' || l_end_cust_count);


      IF p_qp_list_header_id IS NOT NULL AND p_qp_list_header_id <> FND_API.G_MISS_NUM THEN
        FOR old_cust_line_rec IN cur_get_old_qualifiers LOOP

             x_qualifier_tbl(l_qual_index).list_header_id  := p_qp_list_header_id;
             x_qualifier_tbl(l_qual_index).qualifier_id  := old_cust_line_rec.qualifier_id;
             x_qualifier_tbl(l_qual_index).operation       := 'DELETE';
             x_qualifier_tbl(l_qual_index).list_line_id               := -1;
             l_qual_index := l_qual_index+1;

        END LOOP;
      END IF;


    IF l_end_cust_count>0 THEN  --Check if any end customer exists. If yes then do the customer , end customer grouping
        FOR cust_line_rec IN cur_get_cust_qual_lines LOOP
            IF cust_line_rec.end_customer_flag = 'N' THEN
                FOR end_cust_line_rec IN cur_get_end_cust_qual_lines LOOP
                    IF end_cust_line_rec.end_customer_flag = 'Y' THEN

                        --Populate customer record
                        x_qualifier_tbl(l_qual_index).list_header_id  := p_qp_list_header_id;
                        x_qualifier_tbl(l_qual_index).qualifier_grouping_no := l_qualifier_grouping_no;

                       -- IF p_operation<>'DELETE' THEN
                        IF cust_line_rec.cust_usage_code = 'CUSTOMER' OR
                        cust_line_rec.cust_usage_code = 'BILL_TO' OR
                        cust_line_rec.cust_usage_code = 'SHIP_TO' THEN

                            x_qualifier_tbl(l_qual_index).qualifier_context  := 'CUSTOMER';

                        ELSIF cust_line_rec.cust_usage_code = 'BUYING_GROUP' THEN
                            x_qualifier_tbl(l_qual_index).qualifier_context  := 'CUSTOMER_GROUP';
                        END IF;


                        IF cust_line_rec.end_customer_flag='N' THEN
                            IF cust_line_rec.cust_usage_code='CUSTOMER' THEN
                                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE2';
                                x_qualifier_tbl(l_qual_index).qualifier_attr_value := cust_line_rec.cust_account_id;
                            ELSIF cust_line_rec.cust_usage_code='BILL_TO' THEN
                                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE14';
                                x_qualifier_tbl(l_qual_index).qualifier_attr_value := cust_line_rec.site_use_id;
                            ELSIF cust_line_rec.cust_usage_code='SHIP_TO' THEN
                                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE11';
                                x_qualifier_tbl(l_qual_index).qualifier_attr_value := cust_line_rec.site_use_id;
                            ELSIF cust_line_rec.cust_usage_code='BUYING_GROUP' THEN
                                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE3';
                                x_qualifier_tbl(l_qual_index).qualifier_attr_value := cust_line_rec.party_id;
                            END IF;
                        ELSIF cust_line_rec.end_customer_flag='Y' THEN --always customer name as per FDD
                            x_qualifier_tbl(l_qual_index).qualifier_attribute     := 'QUALIFIER_ATTRIBUTE20';
                            x_qualifier_tbl(l_qual_index).qualifier_attr_value    := cust_line_rec.cust_account_id;
                        END IF;


                        x_qualifier_tbl(l_qual_index).operation := 'CREATE';
                        x_qualifier_tbl(l_qual_index).qualifier_attr_value_to    := NULL;
                        x_qualifier_tbl(l_qual_index).qualifier_id               := NULL;
                        x_qualifier_tbl(l_qual_index).comparison_operator_code   := '=';
                        x_qualifier_tbl(l_qual_index).start_date_active          := NULL;
                        x_qualifier_tbl(l_qual_index).end_date_active            := NULL;
                        x_qualifier_tbl(l_qual_index).activity_market_segment_id := NULL;
                        x_qualifier_tbl(l_qual_index).list_line_id               := -1;


                        l_qual_index := l_qual_index+1;
                        --end Populate customer record.
                        --Start populating end customer record

                        x_qualifier_tbl(l_qual_index).list_header_id  := p_qp_list_header_id;
                        x_qualifier_tbl(l_qual_index).qualifier_grouping_no := l_qualifier_grouping_no;

                        --IF p_operation<>'DELETE' THEN
                        IF end_cust_line_rec.cust_usage_code = 'CUSTOMER' OR
                        end_cust_line_rec.cust_usage_code = 'BILL_TO' OR
                        end_cust_line_rec.cust_usage_code = 'SHIP_TO' THEN
                        x_qualifier_tbl(l_qual_index).qualifier_context  := 'CUSTOMER';

                        ELSIF end_cust_line_rec.cust_usage_code = 'BUYING_GROUP' THEN
                            x_qualifier_tbl(l_qual_index).qualifier_context  := 'CUSTOMER_GROUP';
                        END IF;


                        IF end_cust_line_rec.end_customer_flag='N' THEN
                            IF end_cust_line_rec.cust_usage_code='CUSTOMER' THEN
                                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE2';
                                x_qualifier_tbl(l_qual_index).qualifier_attr_value := end_cust_line_rec.cust_account_id;
                            ELSIF end_cust_line_rec.cust_usage_code='BILL_TO' THEN
                                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE14';
                                x_qualifier_tbl(l_qual_index).qualifier_attr_value := end_cust_line_rec.site_use_id;
                            ELSIF end_cust_line_rec.cust_usage_code='SHIP_TO' THEN
                                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE11';
                                x_qualifier_tbl(l_qual_index).qualifier_attr_value := end_cust_line_rec.site_use_id;
                            ELSIF end_cust_line_rec.cust_usage_code='BUYING_GROUP' THEN
                                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE3';
                                x_qualifier_tbl(l_qual_index).qualifier_attr_value := end_cust_line_rec.party_id;
                            END IF;

                        ELSIF end_cust_line_rec.end_customer_flag='Y' THEN --always customer name as per FDD
                            x_qualifier_tbl(l_qual_index).qualifier_attribute     := 'QUALIFIER_ATTRIBUTE20';
                            x_qualifier_tbl(l_qual_index).qualifier_attr_value    := end_cust_line_rec.cust_account_id;
                        END IF;


                        x_qualifier_tbl(l_qual_index).operation := 'CREATE';
                        x_qualifier_tbl(l_qual_index).qualifier_attr_value_to    := NULL;
                        x_qualifier_tbl(l_qual_index).qualifier_id               := NULL;
                        x_qualifier_tbl(l_qual_index).comparison_operator_code   := '=';
                        x_qualifier_tbl(l_qual_index).start_date_active          := NULL;
                        x_qualifier_tbl(l_qual_index).end_date_active            := NULL;
                        x_qualifier_tbl(l_qual_index).activity_market_segment_id := NULL;
                        x_qualifier_tbl(l_qual_index).list_line_id               := -1;

                        l_qual_index := l_qual_index+1;
                        l_qualifier_grouping_no := l_qualifier_grouping_no+10;
                        --End populating end customer record
            END IF; --End of end_cust.qualifier_attribute IF
           END LOOP;--End of end_cust loop
         END IF;--End of cust.qualifier_attribute IF
       END LOOP;--End of end_cust loop


    ELSE--No end customers so no need for grouping logic
        FOR cust_line_rec IN cur_get_cust_qual_lines LOOP

            x_qualifier_tbl(l_qual_index).list_header_id  := p_qp_list_header_id;
            x_qualifier_tbl(l_qual_index).qualifier_grouping_no := l_qualifier_grouping_no;

            IF cust_line_rec.cust_usage_code = 'CUSTOMER' OR
            cust_line_rec.cust_usage_code = 'BILL_TO' OR
            cust_line_rec.cust_usage_code = 'SHIP_TO' THEN
                x_qualifier_tbl(l_qual_index).qualifier_context  := 'CUSTOMER';

            ELSIF cust_line_rec.cust_usage_code = 'BUYING_GROUP' THEN
                x_qualifier_tbl(l_qual_index).qualifier_context  := 'CUSTOMER_GROUP';
            END IF;



            IF cust_line_rec.cust_usage_code='CUSTOMER' THEN
                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE2';
                x_qualifier_tbl(l_qual_index).qualifier_attr_value := cust_line_rec.cust_account_id;
            ELSIF cust_line_rec.cust_usage_code='BILL_TO' THEN
                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE14';
                x_qualifier_tbl(l_qual_index).qualifier_attr_value := cust_line_rec.site_use_id;
            ELSIF cust_line_rec.cust_usage_code='SHIP_TO' THEN
                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE11';
                x_qualifier_tbl(l_qual_index).qualifier_attr_value := cust_line_rec.site_use_id;
            ELSIF cust_line_rec.cust_usage_code='BUYING_GROUP' THEN
                x_qualifier_tbl(l_qual_index).qualifier_attribute  := 'QUALIFIER_ATTRIBUTE3';
                x_qualifier_tbl(l_qual_index).qualifier_attr_value := cust_line_rec.party_id;
            END IF;
            x_qualifier_tbl(l_qual_index).operation                  := 'CREATE';
            x_qualifier_tbl(l_qual_index).qualifier_attr_value_to    := NULL;
            x_qualifier_tbl(l_qual_index).qualifier_id               := NULL;
            x_qualifier_tbl(l_qual_index).comparison_operator_code   := '=';
            x_qualifier_tbl(l_qual_index).start_date_active          := NULL;
            x_qualifier_tbl(l_qual_index).end_date_active            := NULL;
            x_qualifier_tbl(l_qual_index).activity_market_segment_id := NULL;
            x_qualifier_tbl(l_qual_index).list_line_id               := -1;

            l_qual_index := l_qual_index+1;
            l_qualifier_grouping_no := l_qualifier_grouping_no+10;
      END LOOP;
    END IF;--END IF

            OPEN cur_get_internal_order_number;
            FETCH cur_get_internal_order_number INTO l_internal_order_number,l_org_id;
            CLOSE cur_get_internal_order_number;

            IF l_internal_order_number IS NOT NULL
                AND l_internal_order_number <> FND_API.G_MISS_NUM THEN

                    OPEN cur_get_order_header_id(l_internal_order_number,l_org_id);
                    FETCH cur_get_order_header_id INTO l_order_header_id;
                    CLOSE cur_get_order_header_id;

                    x_qualifier_tbl(l_qual_index).operation                 := 'CREATE';
                    x_qualifier_tbl(l_qual_index).qualifier_attribute       := 'QUALIFIER_ATTRIBUTE21';
                    x_qualifier_tbl(l_qual_index).qualifier_attr_value      := l_order_header_id;
                    x_qualifier_tbl(l_qual_index).qualifier_grouping_no     := -1;
                    x_qualifier_tbl(l_qual_index).qualifier_context         := 'ORDER';
                    x_qualifier_tbl(l_qual_index).comparison_operator_code   := '=';

                    x_qualifier_tbl(l_qual_index).list_line_id               := -1;
                    x_qualifier_tbl(l_qual_index).list_header_id             := p_qp_list_header_id;
                    x_qualifier_tbl(l_qual_index).start_date_active          := NULL;
                    x_qualifier_tbl(l_qual_index).end_date_active            := NULL;
                    x_qualifier_tbl(l_qual_index).qualifier_attr_value_to    := NULL;
                    x_qualifier_tbl(l_qual_index).qualifier_id               := NULL;

            END IF;

  EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO populateSDQualifiers;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO populateSDQualifiers;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO populateSDQualifiers;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,'populateSDQualifiers');
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END populateSDQualifiers;

/*
This procedure is starting point of SD offer creation and updation.
*/

PROCEDURE process_sd_modifiers(
   p_sdr_header_id         IN  NUMBER
  ,p_init_msg_list         IN  VARCHAR2 :=FND_API.g_true
  ,p_api_version           IN  NUMBER
  ,p_commit                IN  VARCHAR2 :=FND_API.g_false
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,x_qp_list_header_id     IN OUT NOCOPY  NUMBER
  ,x_error_location        OUT NOCOPY NUMBER)
IS
  l_api_version CONSTANT        NUMBER       := 1.0;
  l_api_name    CONSTANT        VARCHAR2(30) := 'process_sd_modifiers';
  l_offer_id                    NUMBER;
  l_obj_ver_num                 NUMBER;
  l_excl_index                  NUMBER := 0;
  l_dummy                       NUMBER;
  l_user_status_id              NUMBER := 0;
  l_accrual_type                VARCHAR2(30);
  l_cost_center_id              NUMBER;
  l_supplier_site_id            NUMBER;
  l_cust_account_id             NUMBER;
  l_site_use_id                 NUMBER;
  l_operation                   VARCHAR2(30);
  l_access_exists               NUMBER;
  l_activity_access_id          NUMBER;
  l_object_version_number       NUMBER;
  l_access_id                   NUMBER;
  l_qp_list_header_id           NUMBER;
  l_sdr_status_id               NUMBER;

  l_old_status_id               NUMBER;
  l_theme_approval_req          VARCHAR2(1);
  l_budget_approval_req         VARCHAR2(1);


  l_modifier_list_rec           ozf_offer_pvt.modifier_list_rec_type;
  l_modifier_line_tbl           ozf_offer_pvt.modifier_line_tbl_type;
  l_dummy_modifier_line_tbl     ozf_offer_pvt.modifier_line_tbl_type;
  l_exclusion_tbl               ozf_offer_pvt.pricing_attr_tbl_type;
  l_qualifiers_tbl              ozf_offer_pvt.qualifiers_tbl_type;
  l_qualifiers_tbl_out          qp_qualifier_rules_pub.qualifiers_tbl_type;
  l_advanced_options_rec        ozf_offer_pvt.ADVANCED_OPTION_REC_TYPE;
  l_access_rec                  ams_access_pvt.access_rec_type;



  CURSOR c_offer_info(l_qp_list_header_id NUMBER) IS
  SELECT offer_id, offer_type, custom_setup_id, offer_code, tier_level, object_version_number, transaction_currency_code, user_status_id
    FROM ozf_offers
   WHERE qp_list_header_id = l_qp_list_header_id;

  CURSOR c_user_status_id(l_new_status VARCHAR2) IS
  SELECT min(user_status_id)
    FROM ams_user_statuses_vl
   WHERE system_status_type = 'OZF_OFFR_STATUS'
     AND system_status_code=l_new_status;

  CURSOR c_sdr_info(l_sdr_hdr_id NUMBER) IS
  SELECT accrual_type,cust_account_id,supplier_site_id
    FROM  ozf_sd_request_headers_all_b
   WHERE request_header_id=l_sdr_hdr_id;

  CURSOR c_supp_trd_prfl_info(l_supplier_site_id NUMBER) IS
  SELECT cust_account_id, site_use_id
    FROM ozf_supp_trd_prfls_all
   WHERE supplier_site_id=l_supplier_site_id;


  CURSOR c_allow_qty_increase(l_supplier_site_id NUMBER) IS
  SELECT allow_qty_increase
    FROM ozf_supp_trd_prfls_all
   WHERE supplier_site_id=l_supplier_site_id;

  CURSOR c_offer_access(l_qp_list_header_id NUMBER,l_request_header_id NUMBER) IS
  SELECT access_id,user_id,status
    FROM (
        SELECT activity_access_id access_id,user_or_role_id user_id,'ACCESS' status
          FROM ams_act_access
         WHERE act_access_to_object_id=l_qp_list_header_id
           AND arc_act_access_to_object='OFFR'
           AND arc_user_or_role_type = 'USER'
         UNION
        SELECT request_access_id access_id, user_id user_id,'REQUEST' status
          FROM ozf_sd_request_access
         WHERE request_header_id=l_request_header_id
           AND approver_flag='Y'
           AND enabled_flag='Y');

  CURSOR c_access_exists(l_resource_id NUMBER,l_qp_list_header_id NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM ams_act_access
                  WHERE act_access_to_object_id = l_qp_list_header_id
                    AND arc_act_access_to_object='OFFR'
                    AND user_or_role_id = l_resource_id
                    AND arc_user_or_role_type = 'USER');

  CURSOR c_offer_access_details(l_qp_list_header_id NUMBER,l_resource_id NUMBER) IS
  SELECT activity_access_id,object_version_number
    FROM ams_act_access
   WHERE act_access_to_object_id = l_qp_list_header_id
     AND arc_act_access_to_object = 'OFFR'
     AND user_or_role_id = l_resource_id
     AND arc_user_or_role_type = 'USER';

  CURSOR c_get_sdr_status(p_sdr_header_id NUMBER) IS
  SELECT user_status_id
    FROM OZF_SD_REQUEST_HEADERS_ALL_B
   WHERE request_header_id=p_sdr_header_id;

  CURSOR cur_is_theme_appr_req(p_custom_setup_id NUMBER) IS
  SELECT attr_available_flag
  FROM   ams_custom_setup_attr
  WHERE  custom_setup_id = p_custom_setup_id
  AND    object_attribute = 'TAPL';

  CURSOR cur_is_budget_appr_req(p_custom_setup_id NUMBER) IS
  SELECT attr_available_flag
  FROM   ams_custom_setup_attr
  WHERE  custom_setup_id = p_custom_setup_id
  AND    object_attribute = 'BAPL';

  CURSOR c_get_sdr_owner(p_sdr_header_id NUMBER) IS
  SELECT NVL(resource_id,-1)
    FROM ozf_sd_request_access
   WHERE request_header_id= p_sdr_header_id;

BEGIN

  SAVEPOINT process_sd_modifiers;
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  IF NOT Fnd_Api.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;
  x_error_location := 0;
  g_sd_offer := 'Y';

IF FND_PROFILE.VALUE('OZF_SD_DEFAULT_BUDGET') IS NULL THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SD_OFFR_NO_BUDGET_REQUEST');
                FND_MSG_PUB.add;
        END IF;
        RAISE Fnd_Api.g_exc_unexpected_error;
END IF;

  /*decide operation*/

  debug_message('N: qp_list_header_id' || x_qp_list_header_id);

  l_qp_list_header_id := x_qp_list_header_id;
  IF x_qp_list_header_id IS NULL
  OR x_qp_list_header_id = Fnd_Api.g_miss_num THEN
    l_operation := 'CREATE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  OPEN c_get_sdr_status(p_sdr_header_id);
  FETCH c_get_sdr_status INTO l_sdr_status_id;
  CLOSE c_get_sdr_status;

    IF l_sdr_status_id = OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS','CANCELLED')
    OR l_sdr_status_id = OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS','CLOSED') THEN

    OPEN c_offer_info(x_qp_list_header_id);
    FETCH c_offer_info INTO l_modifier_list_rec.offer_id, l_modifier_list_rec.offer_type,
    l_modifier_list_rec.custom_setup_id, l_modifier_list_rec.offer_code,
    l_modifier_list_rec.tier_level, l_modifier_list_rec.object_version_number,
    l_modifier_list_rec.transaction_currency_code,
    l_modifier_list_rec.user_status_id;
    CLOSE c_offer_info;


        IF x_qp_list_header_id IS NOT NULL THEN
                l_modifier_list_rec.qp_list_header_id := x_qp_list_header_id;
                l_modifier_list_rec.offer_operation := 'UPDATE';
                l_modifier_list_rec.status_code := 'COMPLETED';
                l_modifier_list_rec.modifier_operation := 'UPDATE';
                --l_modifier_list_rec.operation := 'UPDATE';
                l_modifier_list_rec.user_status_id := OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','COMPLETED');
                l_qp_list_header_id := x_qp_list_header_id;

              /*Complete Offer*/
               process_modifiers(
               p_init_msg_list     => p_init_msg_list
              ,p_api_version       => p_api_version
              ,p_commit            => p_commit
              ,x_return_status     => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_offer_type        => 'ACCRUAL'
              ,p_modifier_list_rec => l_modifier_list_rec
              ,p_modifier_line_tbl => l_dummy_modifier_line_tbl -- lines are already created. use empty line.
              ,x_qp_list_header_id => x_qp_list_header_id
              ,x_error_location    => x_error_location);

              GOTO COMPLETED_OFFER;

        END IF;
    END IF;

  /*Create Header record*/
     populateSDHeaderRec(
        x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_operation         => l_operation
       ,p_sdr_header_id     => p_sdr_header_id
       ,p_qp_list_header_id => x_qp_list_header_id
       ,x_modifier_list_rec => l_modifier_list_rec
     );

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;

   /*Create Header*/
  IF l_operation = 'CREATE' THEN

    l_modifier_list_rec.modifier_operation := 'CREATE';
    l_modifier_list_rec.status_code := 'DRAFT';
    l_modifier_list_rec.user_status_id := ozf_utility_pvt.get_default_user_status('OZF_OFFER_STATUS','DRAFT');--1600;

    IF l_modifier_list_rec.OWNER_ID IS NULL OR l_modifier_list_rec.OWNER_ID = fnd_api.g_miss_num THEN
      l_modifier_list_rec.OWNER_ID                      := ozf_utility_pvt.get_resource_id(NVL(FND_GLOBAL.user_id,-1));
    ELSE
      l_modifier_list_rec.OWNER_ID                      := l_modifier_list_rec.OWNER_ID;
    END IF;

    l_modifier_list_rec.modifier_operation := 'CREATE';


    debug_message('N:  l_modifier_list_rec.TRANSACTION_CURRENCY_CODE ' || l_modifier_list_rec.TRANSACTION_CURRENCY_CODE);
    debug_message('x_return_status '     ||x_return_status);
    debug_message('x_qp_list_header_id ' ||x_qp_list_header_id);


  ELSE

    l_modifier_list_rec.qp_list_header_id:= x_qp_list_header_id;

    IF l_modifier_list_rec.OWNER_ID IS NULL OR l_modifier_list_rec.OWNER_ID = -1
    OR l_modifier_list_rec.OWNER_ID = fnd_api.g_miss_num THEN

    OPEN c_get_sdr_owner(p_sdr_header_id);
    FETCH c_get_sdr_owner INTO l_modifier_list_rec.OWNER_ID;
    CLOSE c_get_sdr_owner;

    ELSE
      l_modifier_list_rec.OWNER_ID                      := l_modifier_list_rec.OWNER_ID;
    END IF;

  END IF;

  --dbms_output.put_line('Nirma 2 ' );





  debug_message('N: l_offer_id'||l_offer_id);
  debug_message('N: l_modifier_list_rec.transaction_currency_code 33'||l_modifier_list_rec.transaction_currency_code);
  debug_message('N: pass list_header_id for update'||x_qp_list_header_id);

  /*Create Discount Line Records*/

  populateSDDiscountRulesRec(
        x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_operation         => l_operation
       ,p_sdr_header_id     => p_sdr_header_id
       ,p_qp_list_header_id => x_qp_list_header_id
       ,x_modifier_line_tbl => l_modifier_line_tbl
     );

    IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;

  debug_message('N: 11 l_modifier_line_tbl count ' || l_modifier_line_tbl.count);

  /*Create Discount Lines*/

  IF l_modifier_line_tbl.count>0 THEN

  Ozf_Offer_Pvt.process_modifiers(
     p_init_msg_list     => p_init_msg_list
    ,p_api_version       => p_api_version
    ,p_commit            => p_commit
    ,x_return_status     => x_return_status
    ,x_msg_count         => x_msg_count
    ,x_msg_data          => x_msg_data
    ,p_offer_type        => 'ACCRUAL'
    ,p_modifier_list_rec => l_modifier_list_rec
    ,p_modifier_line_tbl => l_modifier_line_tbl
    ,x_qp_list_header_id => l_dummy
    ,x_error_location    => x_error_location);

   ELSE

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_OFFR_NO_DISC_LINES');
            FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
  END IF;

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
    RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;


  IF l_dummy IS NOT NULL THEN
  x_qp_list_header_id:=l_dummy;
  END IF;

   OPEN c_offer_info(x_qp_list_header_id);
  FETCH c_offer_info INTO l_modifier_list_rec.offer_id,
                          l_modifier_list_rec.offer_type,
                          l_modifier_list_rec.custom_setup_id,
                          l_modifier_list_rec.offer_code,
                          l_modifier_list_rec.tier_level,
                          l_modifier_list_rec.object_version_number,
                          l_modifier_list_rec.transaction_currency_code,
                          l_modifier_list_rec.user_status_id;
  CLOSE c_offer_info;


   IF l_modifier_list_rec.user_status_id IS NOT NULL AND l_modifier_list_rec.user_status_id <> fnd_api.g_miss_num THEN -- might have additional stage eg ACTIVE to go
      --dbms_output.put_line('l_modifier_list_rec.user_status_id set operation as update' );
      l_modifier_list_rec.offer_operation := 'UPDATE';
      l_modifier_list_rec.modifier_operation := 'UPDATE';
      l_modifier_list_rec.user_status_id := l_modifier_list_rec.user_status_id;
      l_modifier_list_rec.status_code := ozf_utility_pvt.get_system_status_code(l_modifier_list_rec.user_status_id);
    END IF;

  /*Create Qualifier Line Records*/
  --dbms_output.put_line('N: x_qp_list_header_id '||x_qp_list_header_id);

  IF x_qp_list_header_id IS NOT NULL THEN
  populateSDQualifiers(
         x_return_status     => x_return_status
        ,x_msg_count         => x_msg_count
        ,x_msg_data          => x_msg_data
        ,p_sdr_header_id     => p_sdr_header_id
        ,p_qp_list_header_id => x_qp_list_header_id
        ,x_qualifier_tbl     => l_qualifiers_tbl
     );
  debug_message('N: count3 '||l_qualifiers_tbl.count);

  IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
     RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;

  /*Create Market Qualifiers*/
  process_market_qualifiers(
         p_init_msg_list  => p_init_msg_list
        ,p_api_version    => p_api_version
        ,p_commit         => p_commit
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data
        ,p_qualifiers_tbl => l_qualifiers_tbl
        ,x_error_location => x_error_location
        ,x_qualifiers_tbl => l_qualifiers_tbl_out);

  debug_message('N: count4 '||l_qualifiers_tbl_out.count);

  /*IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
    RAISE Fnd_Api.g_exc_error;
  ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
     RAISE Fnd_Api.g_exc_unexpected_error;
  END IF;*/

  debug_message('N: activate the records '||x_return_status);


    l_advanced_options_rec.list_header_id := x_qp_list_header_id;

    OPEN  c_sdr_info(p_sdr_header_id);
    FETCH c_sdr_info INTO l_accrual_type, l_cust_account_id, l_supplier_site_id;
    CLOSE c_sdr_info;

    IF l_accrual_type='SUPPLIER' THEN
        OPEN  c_supp_trd_prfl_info(l_supplier_site_id);
        FETCH c_supp_trd_prfl_info INTO l_cust_account_id,l_site_use_id;
        CLOSE c_supp_trd_prfl_info;
    END IF;

    l_advanced_options_rec.autopay_party_id := l_cust_account_id;

    IF l_site_use_id IS NULL THEN
        l_advanced_options_rec.autopay_party_attr := 'CUSTOMER';
        --l_advanced_options_rec.autopay_party_id := l_cust_account_id;
        --l_advanced_options_rec.beneficiary_account_id := l_cust_account_id;
    ELSE
        l_advanced_options_rec.autopay_party_attr := 'CUSTOMER_BILL_TO';
        l_advanced_options_rec.autopay_party_id := l_site_use_id;
        --l_advanced_options_rec.beneficiary_account_id := l_cust_account_id;
    END IF;

   /*Create Advance Option*/
    process_adv_options(
    p_init_msg_list         => p_init_msg_list
    ,p_api_version          => p_api_version
    ,p_commit               => p_commit
    ,x_return_status        => x_return_status
    ,x_msg_count            => x_msg_count
    ,x_msg_data             => x_msg_data
    ,p_advanced_options_rec => l_advanced_options_rec
    );

    /*activate the offer */
    --change the create record to update record and activate the offer.

  OPEN c_offer_info(x_qp_list_header_id);
  FETCH c_offer_info INTO l_modifier_list_rec.offer_id, l_modifier_list_rec.offer_type,
  l_modifier_list_rec.custom_setup_id, l_modifier_list_rec.offer_code,
  l_modifier_list_rec.tier_level, l_modifier_list_rec.object_version_number,
  l_modifier_list_rec.transaction_currency_code,
  l_modifier_list_rec.user_status_id;
  CLOSE c_offer_info;


  debug_message('N: process_adv_options '||x_return_status);
  debug_message('N: x_qp_list_header_id '|| x_qp_list_header_id);


    IF x_qp_list_header_id IS NOT NULL THEN

      OPEN  cur_is_theme_appr_req(l_modifier_list_rec.custom_setup_id);
      FETCH cur_is_theme_appr_req INTO l_theme_approval_req;
      CLOSE cur_is_theme_appr_req;



      OPEN  cur_is_budget_appr_req(l_modifier_list_rec.custom_setup_id);
      FETCH cur_is_budget_appr_req INTO l_budget_approval_req;
      CLOSE cur_is_budget_appr_req;

      debug_message('N: l_theme_approval_req '|| l_theme_approval_req);
      debug_message('N: l_budget_approval_req '|| l_budget_approval_req);

      IF l_theme_approval_req='Y' THEN

      Ams_Approval_Submit_Pvt.Submit_Approval(
           p_api_version       => 1,
           p_init_msg_list     => FND_API.g_true,
           p_commit            => FND_API.g_false,
           p_validation_level  => FND_API.g_valid_level_full,
           p_object_id         => x_qp_list_header_id,
           p_object_type       => 'OFFR',
           p_new_status_id     => 1640,   -- planned status for offers
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data);

       ELSIF l_budget_approval_req = 'Y' AND l_theme_approval_req='N' THEN

       Ams_Approval_Submit_Pvt.Submit_Approval(
           p_api_version       => 1,
           p_init_msg_list     => FND_API.g_false,
           p_commit            => FND_API.g_false,
           p_validation_level  => FND_API.g_valid_level_full,
           p_object_id         => x_qp_list_header_id,
           p_object_type       => 'OFFR',
           p_new_status_id     => 1604,   -- will come from status dropdown on approval detail page
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data);

       ELSE

       l_modifier_list_rec.qp_list_header_id := x_qp_list_header_id;
        l_modifier_list_rec.offer_operation := 'UPDATE';
        l_modifier_list_rec.status_code := 'ACTIVE';
        l_modifier_list_rec.modifier_operation := 'UPDATE';
        --l_modifier_list_rec.operation := 'UPDATE';
        l_modifier_list_rec.user_status_id := OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','ACTIVE');
        l_qp_list_header_id := x_qp_list_header_id;

        /*Activate Offer*/
       process_modifiers(
       p_init_msg_list     => p_init_msg_list
      ,p_api_version       => p_api_version
      ,p_commit            => p_commit
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_offer_type        => 'ACCRUAL'
      ,p_modifier_list_rec => l_modifier_list_rec
      ,p_modifier_line_tbl => l_dummy_modifier_line_tbl -- lines are already created. use empty line.
      ,x_qp_list_header_id => x_qp_list_header_id
      ,x_error_location    => x_error_location);

      /*added this code to make SDR active */

        /*IF l_modifier_list_rec.user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_OFFER_STATUS','ACTIVE') THEN

        debug_message('p_sdr_header_id1111 = '|| p_sdr_header_id);

        update ozf_sd_request_headers_all_b
        set user_status_id = OZF_Utility_PVT.get_default_user_status('OZF_SD_REQUEST_STATUS','ACTIVE')
        where request_header_id = p_sdr_header_id;

        END IF;*/

       END IF;



    debug_message('N: activate the records1  '||x_return_status);
    END IF;

     IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
     ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
     END IF;

     IF l_qp_list_header_id IS NULL THEN
     l_qp_list_header_id := x_qp_list_header_id;
     END IF;

     /*Add access code*/
      debug_message('N: x_qp_list_header_id  '||l_qp_list_header_id);
      debug_message('N: p_sdr_header_id  '||p_sdr_header_id);
      debug_message('N: b4 adding access');

     FOR l_offer_access_rec IN c_offer_access(l_qp_list_header_id,p_sdr_header_id) LOOP
     debug_message('N: l_offer_access_rec.user_id  '||l_offer_access_rec.user_id);
     debug_message('N: l_qp_list_header_id  '||l_qp_list_header_id);
     l_access_exists := 0;
        OPEN c_access_exists (ozf_utility_pvt.get_resource_id(nvl(l_offer_access_rec.user_id,-1)),l_qp_list_header_id);
        FETCH c_access_exists INTO l_access_exists;
        CLOSE c_access_exists;
        debug_message('N: l_access_exists  '||l_access_exists);
        debug_message('N: l_offer_access_rec.status  '|| l_offer_access_rec.status);

        IF l_access_exists <> 1  AND l_offer_access_rec.status='REQUEST' THEN
            --CREATE
            l_access_rec.act_access_to_object_id := l_qp_list_header_id;
            l_access_rec.arc_act_access_to_object := 'OFFR';
            l_access_rec.user_or_role_id := ozf_utility_pvt.get_resource_id(l_offer_access_rec.user_id);
            l_access_rec.arc_user_or_role_type := 'USER';
            l_access_rec.admin_flag := 'Y';
            l_access_rec.owner_flag := 'N';
            debug_message('N: l_access_rec.user_or_role_id  '||l_access_rec.user_or_role_id);
            debug_message('N: l_access_rec.act_access_to_object_id  '||l_access_rec.act_access_to_object_id);

            ams_access_pvt.create_access(
                p_api_version => l_api_version
                ,p_init_msg_list => fnd_api.g_false
                ,p_validation_level => fnd_api.g_valid_level_full
                ,x_return_status => x_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data
                ,p_commit => fnd_api.g_false
                ,p_access_rec => l_access_rec
                ,x_access_id => l_access_id);

            IF x_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
             debug_message('N: x_return_status  '||x_return_status);
        END IF;
     END LOOP;
  END IF;

   <<COMPLETED_OFFER>>
  NULL;

  IF x_qp_list_header_id IS NULL THEN
     x_qp_list_header_id := l_qp_list_header_id;
  END IF;


  debug_message('Returned Status to Calling API '|| x_return_status);
  debug_message('Returned list_header_id to Calling API '|| x_qp_list_header_id);

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO process_sd_modifiers;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO process_sd_modifiers;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
     ROLLBACK TO process_sd_modifiers;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END process_sd_modifiers;

END OZF_Offer_Pvt;


/
