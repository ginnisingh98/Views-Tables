--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_UTIL" AS
/* $Header: OEXUBSOB.pls 120.19.12010000.13 2010/04/26 14:09:02 aambasth ship $ */
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Blanket_Util';

PROCEDURE Insert_History_Records
          (p_header_rec           IN OUT NOCOPY OE_Blanket_PUB.Header_Rec_Type
          ,p_line_tbl             IN OUT NOCOPY OE_Blanket_PUB.Line_Tbl_Type
          ,p_version_flag in varchar2 := null
          ,p_phase_change_flag in varchar2 := null
          ,x_return_status        IN OUT NOCOPY VARCHAR2
          );

PROCEDURE Validate_Min_Max_Range (p_min_value IN NUMBER, p_max_value IN NUMBER, p_attribute IN VARCHAR2, x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE Lock_Blanket
(   x_return_status             OUT NOCOPY VARCHAR2
,   p_blanket_id                IN NUMBER
,   p_blanket_line_id           IN NUMBER
,   p_x_lock_control            IN OUT NOCOPY NUMBER
);

-- ER 5743580
--Added for Bug 9027699
FUNCTION  is_end_date_operation
( p_line_rec           IN     OE_Blanket_PUB.line_rec_type,
  p_old_line_rec       IN     OE_Blanket_PUB.line_rec_type)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status varchar2(1);

BEGIN
IF l_debug_level > 0 then
oe_debug_pub.add('Entering is_end_date_operation ');
end if;
IF p_line_rec.operation = oe_globals.g_opr_update AND p_line_rec.end_date_active = trunc(sysdate) AND
   NOT OE_GLOBALS.Equal(p_line_rec.end_date_active, p_old_line_rec.end_date_active) THEN

	IF  p_line_rec.override_blanket_controls_flag = 'N' THEN
          IF nvl(p_line_rec.released_amount,0) < p_line_rec.blanket_min_amount THEN
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_CLOSE_MIN_VALUES');
              OE_MSG_PUB.ADD;
              if l_debug_level > 0 then
               oe_debug_pub.add('Blanket line close min amount ');
              end if;
             -- return false; This is a warning..hence not returning ..

          ELSIF nvl(p_line_rec.released_quantity,0) < p_line_rec.blanket_min_quantity THEN
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_CLOSE_MIN_VALUES');
              OE_MSG_PUB.ADD;
              if l_debug_level > 0 then
                 oe_debug_pub.add('Blanket line close min quantity ');
              end if;
              --return false; This is a warning..hence not returning ..
          END IF;
	END IF;


	BEGIN
		SELECT 'ERROR'
		INTO l_dummy
		FROM OE_ORDER_LINES
		WHERE trunc(request_date) > trunc(p_line_rec.end_date_active)
		AND BLANKET_NUMBER = p_line_rec.order_number
		AND BLANKET_LINE_NUMBER = p_line_rec.line_number
		AND ROWNUM = 1;

		IF l_dummy = 'ERROR' THEN
			fnd_message.set_name('ONT', 'OE_BLKT_LINE_RELEASE_END_DATE');
			OE_MSG_PUB.Add;
			return false;
		END IF;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	NULL;  --no rows with conflicting end dates
	END;


      --validate item uniqueness
      -- This is called just to make sure that a delayed request is logged..else validate_entity was being called again
      -- from process_object
      OE_Delayed_Requests_Pvt.Log_Request(p_Entity_Code =>
	         OE_BLANKET_pub.G_ENTITY_BLANKET_LINE ,
               p_Entity_Id => p_line_rec.line_id,
               p_requesting_entity_code    =>
                 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
               p_requesting_entity_id      => p_line_rec.line_id,
               p_request_type => 'VALIDATE_BLANKET_INV_ITEM',
               p_param1    => p_line_rec.inventory_item_id,
               p_param2    => p_line_rec.header_id,
               p_param3    => p_line_rec.item_identifier_type,
	       p_param4    => p_line_rec.ordered_item_id, --bug6826787
	       p_param5    => p_line_rec.ordered_item,    --bug6826787
               p_date_param1    => p_line_rec.start_date_active,
               p_date_param2    => p_line_rec.end_date_active,
               x_return_status => l_return_status);

    return true;


ELSE
    return false;
END IF;

END is_end_date_operation;


FUNCTION Validate_Ship_to_Org
( p_ship_to_org_id      IN  NUMBER
, p_sold_to_org_id      IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
l_site_use_code   VARCHAR2(30) := 'SHIP_TO';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
    IF l_debug_level > 0 then
    oe_debug_pub.add('Entering Validate_ship_to_org',1);
    oe_debug_pub.add('ship_to_org_id :'||to_char(p_ship_to_org_id),2);
    END IF;

    IF  g_customer_relations = 'N' THEN

    Select 'VALID'
    Into   l_dummy
    From   oe_ship_to_orgs_v
    Where  customer_id = p_sold_to_org_id
    AND          site_use_id = p_ship_to_org_id
    AND  status = 'A'
    AND  address_status ='A'; --bug 2752321
    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting Validate_ship_to_org',1);
    END IF;
    RETURN TRUE;
    ELSIF g_customer_relations = 'Y' THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add ('Cr: Yes Line Ship',2);
        END IF;

    SELECT /* MOAC_SQL_CHANGE */ 'VALID'
    Into   l_dummy
    FROM   HZ_CUST_SITE_USES_ALL SITE,
           HZ_CUST_ACCT_SITES ACCT_SITE
    WHERE SITE.SITE_USE_ID     = p_ship_to_org_id
    AND SITE.SITE_USE_CODE     = l_site_use_code
    AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
    AND SITE.STATUS = 'A'
       AND ACCT_SITE.STATUS ='A' AND --bug 2752321
    ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                    and h.org_id=acct_site.org_id
                        and ship_to_flag = 'Y' and status = 'A')
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID =
ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
    AND ROWNUM = 1;
   RETURN TRUE;
    ELSIF g_customer_relations = 'A' THEN
    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_SHIP_TO_ORGS_V   SHP
    WHERE   SHP.ORGANIZATION_ID =p_ship_to_org_id
    AND     SHP.STATUS = 'A'
    AND     SHP.ADDRESS_STATUS ='A' --bug 2752321
    AND     SYSDATE BETWEEN NVL(SHP.START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(SHP.END_DATE_ACTIVE, SYSDATE);

    RETURN TRUE;

    END IF;
   RETURN TRUE;


EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_Ship_To_Org;


FUNCTION Validate_Deliver_To_Org
( p_deliver_to_org_id IN  NUMBER
, p_sold_to_org_id        IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
l_site_use_code   VARCHAR2(30) := 'DELIVER_TO';

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 then
  oe_debug_pub.add('Entering OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
  oe_debug_pub.add('deliver_to_org_id :'||to_char(p_deliver_to_org_id),2);
  END IF;


  IF g_customer_relations  = 'N' THEN
    SELECT 'VALID'
    INTO   l_dummy
    FROM   oe_deliver_to_orgs_v
    WHERE  customer_id = p_sold_to_org_id
    AND          site_use_id = p_deliver_to_org_id
    AND  status = 'A'
    AND  address_status ='A';--bug 2752321
    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    END IF;
    RETURN TRUE;

  ELSIF g_customer_relations = 'Y' THEN
    IF l_debug_level > 0 then
    oe_debug_pub.add('Cr: Yes Line Deliver',2);
    END IF;

    SELECT /* MOAC_SQL_CHANGE */ 'VALID'
      Into   l_dummy
      FROM   HZ_CUST_SITE_USES_ALL SITE,
           HZ_CUST_ACCT_SITES ACCT_SITE
     WHERE SITE.SITE_USE_ID     = p_deliver_to_org_id
       AND SITE.SITE_USE_CODE     = l_site_use_code
       AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
       AND SITE.STATUS = 'A'
       AND ACCT_SITE.STATUS ='A' AND
       ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                    and h.org_id=acct_site.org_id
                        and ship_to_flag = 'Y' and status='A')
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID =
ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
        AND ROWNUM = 1;

    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    END IF;
    RETURN TRUE;

  ELSIF g_customer_relations = 'A' THEN

    SELECT  'VALID'
      INTO    l_dummy
      FROM    OE_DELIVER_TO_ORGS_V   DEL
     WHERE   DEL.ORGANIZATION_ID =p_deliver_to_org_id
       AND     DEL.STATUS = 'A'
               AND DEL.ADDRESS_STATUS ='A' --bug 2752321
       AND     SYSDATE BETWEEN NVL(DEL.START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(DEL.END_DATE_ACTIVE, SYSDATE);
    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    END IF;
    RETURN TRUE;


  END IF;
   IF l_debug_level > 0 then
  oe_debug_pub.add('Exiting OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
   END IF;
  RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_Deliver_To_Org;


FUNCTION Validate_Invoice_To_Org
( p_Invoice_to_org_id IN  NUMBER
, p_sold_to_org_id        IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
l_site_use_code   VARCHAR2(30) := 'BILL_TO';

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 then
  oe_debug_pub.add('Entering Validate_Invoice_To_Org',1);
  oe_debug_pub.add('Invoice_to_org_id :'||to_char(p_Invoice_to_org_id),2);
  END IF;


  IF g_customer_relations  = 'N' THEN

            Select 'VALID'
            Into   l_dummy
            From   oe_invoice_to_orgs_v
            Where  customer_id = p_sold_to_org_id
            And    site_use_id = p_invoice_to_org_id
            and    status='A'
            and   address_status ='A';
          RETURN TRUE;

    ELSIF g_customer_relations = 'Y' THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('Cr: Yes Line Inv',2);
        END IF;

    SELECT /* MOAC_SQL_CHANGE */ 'VALID'
    Into   l_dummy
    FROM   HZ_CUST_SITE_USES_ALL SITE,
           HZ_CUST_ACCT_SITES ACCT_SITE
    WHERE SITE.SITE_USE_ID     = p_invoice_to_org_id
    AND SITE.SITE_USE_CODE     = l_site_use_code
    AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
    AND SITE.STATUS = 'A'
       AND ACCT_SITE.STATUS ='A' AND
    ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                    and h.org_id=acct_site.org_id
                        and bill_to_flag = 'Y' and status='A')
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
    AND ROWNUM = 1;

  RETURN TRUE;
  END IF;
  RETURN TRUE;

        EXCEPTION
                WHEN OTHERS THEN
           RETURN FALSE;
   END Validate_Invoice_To_Org;
 -- End ER 5743580


PROCEDURE create_price_list(
			    p_index in NUMBER,
			    x_return_status OUT NOCOPY varchar2)
IS
 gpr_return_status varchar2(1) := NULL;
 gpr_msg_count number := 0;
 gpr_msg_data varchar2(2000);
 gpr_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 gpr_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 gpr_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 gpr_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 gpr_qualifiers_tbl QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 l_qualifiers_tbl QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 gpr_qualifiers_val_tbl QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 gpr_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 gpr_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 ppr_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 ppr_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 ppr_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 ppr_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 ppr_qualifiers_tbl QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 ppr_qualifiers_val_tbl QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 ppr_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 xpr_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 xpr_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 xpr_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 xpr_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 xpr_qualifiers_tbl QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 xpr_qualifiers_val_tbl QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 xpr_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 xpr_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 K number := 1;
 j number := 1;
 I number := p_Index;
 lheader_id number;
 l_list_line_seq NUMBER;
 ind NUMBER := 1;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_user_precedence NUMBER; --Bug#8468331

BEGIN
   /* set the list_header_id to g_miss_num */

    if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In create price list');
    end if;
	IF oe_delayed_requests_pvt.g_delayed_requests(I).param1 IS NULL THEN
		RETURN;
	END IF;

   gpr_price_list_rec.list_header_id := FND_API.G_MISS_NUM;
   gpr_price_list_rec.name := oe_delayed_requests_pvt.g_delayed_requests(I).param1;
   gpr_price_list_rec.list_type_code := 'PRL';
   gpr_price_list_rec.list_source_code := 'BLKT';
--   gpr_price_list_rec.description := oe_delayed_requests_pvt.g_delayed_requests(I).paramtext1;
   gpr_price_list_rec.currency_code := oe_delayed_requests_pvt.g_delayed_requests(I).param2;
   --11i10 Pricing Changes Start
   if oe_code_control.get_code_release_level >= '110510' then
      gpr_price_list_rec.list_source_code := 'BSO';
      gpr_price_list_rec.orig_system_header_ref :=
                oe_delayed_requests_pvt.g_delayed_requests(I).entity_id;
      gpr_price_list_rec.shareable_flag := 'N';
      gpr_price_list_rec.sold_to_org_id :=
                oe_delayed_requests_pvt.g_delayed_requests(I).param7;
      -- Add blanket header qualifier
        l_qualifiers_tbl(1).excluder_flag := 'N';
        l_qualifiers_tbl(1).comparison_operator_code := '=';
        l_qualifiers_tbl(1).qualifier_context := 'ORDER';
	--Bug#8468331
        /*The precedence with which pricing was being called was hardcoded as 700(the seeded value)
        so even if this value is changed in Pricing Setup the price list being created via BSO has
        the precedence as 700 and not the user updated value.*/
        SELECT a.user_precedence INTO l_user_precedence
	FROM   qp_segments_v a,
	       qp_prc_contexts_b b,
	       qp_pte_segments c
	WHERE
	    b.prc_context_type = 'QUALIFIER' and
	    b.prc_context_code = 'ORDER' and
	    b.prc_context_id = a.prc_context_id and
	    a.segment_mapping_column = 'QUALIFIER_ATTRIBUTE5' and
	    a.segment_id = c.segment_id and
            c.pte_code = 'ORDFUL';
        --Bug#8468331
        --l_qualifiers_tbl(1).qualifier_precedence := 700; --commented Bug#8468331
        l_qualifiers_tbl(1).qualifier_precedence := l_user_precedence; --Bug#8468331

        l_qualifiers_tbl(1).qualifier_attribute := 'QUALIFIER_ATTRIBUTE5';
        -- Blanket Header ID is the qualifier attribute value
        l_qualifiers_tbl(1).qualifier_attr_value :=
                oe_delayed_requests_pvt.g_delayed_requests(I).entity_id;
        l_qualifiers_tbl(1).qualifier_grouping_no := 1;
        l_qualifiers_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;
   end if;
   --11i10 Pricing Changes End

   gpr_price_list_rec.operation := QP_GLOBALS.G_OPR_CREATE;
   --MOAC changes to force the PL tobe created in a ORG
   gpr_price_list_rec.org_id := mo_global.get_current_org_id;
   gpr_price_list_rec.global_flag := 'N';
   lheader_id := oe_delayed_requests_pvt.g_delayed_requests(I).entity_id;

	I := oe_delayed_requests_pvt.g_delayed_requests.first;

	WHILE I IS NOT NULL
	LOOP
IF oe_delayed_requests_pvt.g_delayed_requests(I).request_type = 'CREATE_BLANKET_PRICE_LIST'
		AND
		oe_delayed_requests_pvt.g_delayed_requests(I).entity_code =
			 oe_blanket_pub.g_entity_blanket_LINE THEN
    if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In create price list - line');
    end if;
		IF oe_delayed_requests_pvt.g_delayed_requests(I).param1 IS NULL THEN
                     if l_debug_level > 0 then
			oe_debug_pub.add('Blanket In Skip');
                     end if;
			GOTO SKIP_LINE;
		END IF;
	g_line_id_tbl(ind).line_id := oe_delayed_requests_pvt.g_delayed_requests(I).entity_id;

          select QP_LIST_LINES_S.NEXTVAL into l_list_line_seq from dual; --bug8344368
	  gpr_price_list_line_tbl(ind).list_line_id := l_list_line_seq;
          gpr_price_list_line_tbl(ind).list_line_type_code := 'PLL';
          gpr_price_list_line_tbl(ind).operation := QP_GLOBALS.G_OPR_CREATE;
          gpr_price_list_line_tbl(ind).operand := oe_delayed_requests_pvt.g_delayed_requests(I).param1;
          gpr_price_list_line_tbl(ind).arithmetic_operator := 'UNIT_PRICE';

        -- Bug 3209215, Issue 9.1
        -- Pass precedence value on price list lines
        gpr_price_list_line_tbl(ind).product_precedence := 1;

        gpr_pricing_attr_tbl(K).pricing_attribute_id := FND_API.G_MISS_NUM;
        gpr_pricing_attr_tbl(K).list_line_id := FND_API.G_MISS_NUM;
        gpr_pricing_attr_tbl(K).PRODUCT_ATTRIBUTE_CONTEXT := 'ITEM';


	IF oe_delayed_requests_pvt.g_delayed_requests(I).param4 = 'CAT' THEN

	   gpr_pricing_attr_tbl(K).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE2';
           gpr_pricing_attr_tbl(K).PRODUCT_ATTR_VALUE := oe_delayed_requests_pvt.g_delayed_requests(I).param3;

	ELSIF oe_delayed_requests_pvt.g_delayed_requests(I).param4 = 'ALL' THEN

	   gpr_pricing_attr_tbl(K).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE3';
           gpr_pricing_attr_tbl(K).PRODUCT_ATTR_VALUE := 'ALL';

	ELSE

	   gpr_pricing_attr_tbl(K).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE1';
           gpr_pricing_attr_tbl(K).PRODUCT_ATTR_VALUE := oe_delayed_requests_pvt.g_delayed_requests(I).param3;

           -- 11i10 Pricing Change
           -- Send customer item on price list line record
           IF oe_delayed_requests_pvt.g_delayed_requests(I).param4 = 'CUST'
              AND OE_Code_Control.Get_Code_Release_Level >= '110510'
           THEN
              gpr_price_list_line_tbl(ind).customer_item_id :=
                oe_delayed_requests_pvt.g_delayed_requests(I).param8;
             oe_debug_pub.add('sending cust item id :'||
                gpr_price_list_line_tbl(ind).customer_item_id);
           END IF;

	END IF;



        gpr_pricing_attr_tbl(K).PRODUCT_UOM_CODE := oe_delayed_requests_pvt.g_delayed_requests(I).param2;
        gpr_pricing_attr_tbl(K).EXCLUDER_FLAG := 'N';
        gpr_pricing_attr_tbl(K).ATTRIBUTE_GROUPING_NO := 1;
        gpr_pricing_attr_tbl(K).list_line_id := l_list_line_seq;
        gpr_pricing_attr_tbl(K).operation := QP_GLOBALS.G_OPR_CREATE;

	--Added for bug8344368
	k:= K+1;

	gpr_pricing_attr_tbl(K).pricing_attribute_id := FND_API.G_MISS_NUM;
	gpr_pricing_attr_tbl(K).list_line_id := l_list_line_seq;
        gpr_pricing_attr_tbl(K).operation := QP_GLOBALS.G_OPR_CREATE;
        gpr_pricing_attr_tbl(K).pricing_attribute_context := 'QP_INTERNAL';
        gpr_pricing_attr_tbl(K).pricing_attribute := 'PRICING_ATTRIBUTE1';
        gpr_pricing_attr_tbl(K).pricing_attr_value_from := l_list_line_seq;
        gpr_pricing_attr_tbl(K).comparison_operator_code := '=';


	k:= k+1;
	ind := ind+1;

		<< SKIP_LINE >>
		oe_delayed_requests_pvt.g_delayed_requests.delete(I);
		END IF;
		I := oe_delayed_requests_pvt.g_delayed_requests.next(I);

	END LOOP;

        /*
        -- 11i10 Pricing Changes
        IF OE_Code_Control.Get_Code_Release_Level >= '110510' THEN
        -----------------------------------------------------------
        -- Set up the blanket line qualifier record
        -----------------------------------------------------------
        gpr_qualifiers_tbl(K).qualifier_grouping_no := 1;
        gpr_qualifiers_tbl(K).excluder_flag := 'N';
        gpr_qualifiers_tbl(K).qualifier_precedence := 700;
        gpr_qualifiers_tbl(K).qualifier_context := 'ORDER';
        gpr_qualifiers_tbl(K).qualifier_attribute := 'QUALIFIER_ATTRIBUTE6';
        gpr_qualifiers_tbl(K).comparison_operator_code := '=';
        -- Blanket Line ID is the qualifier attribute value
        gpr_qualifiers_tbl(K).qualifier_attr_value := oe_delayed_requests_pvt.g_delayed_requests(I).entity_id;
        oe_debug_pub.add('entity id :'||oe_delayed_requests_pvt.g_delayed_requests(I).entity_id);
        gpr_qualifiers_tbl(K).operation := QP_GLOBALS.G_OPR_CREATE;
        END IF;
        */

        QP_PRICE_LIST_GRP.Process_Price_List
(   p_api_version_number            => 1
,   p_init_msg_list                 => FND_API.G_FALSE
,   p_return_values                 => FND_API.G_FALSE
,   p_commit                        => FND_API.G_FALSE
,   x_return_status                 => x_return_status
,   x_msg_count                     => gpr_msg_count
,   x_msg_data                      => gpr_msg_data
,   p_PRICE_LIST_rec                => gpr_price_list_rec
,   p_PRICE_LIST_LINE_tbl           => gpr_price_list_line_tbl
,   p_PRICING_ATTR_tbl              => gpr_pricing_attr_tbl
,   p_qualifiers_tbl                => l_qualifiers_tbl
,   x_PRICE_LIST_rec                => ppr_price_list_rec
,   x_PRICE_LIST_val_rec            => ppr_price_list_val_rec
,   x_PRICE_LIST_LINE_tbl           => ppr_price_list_line_tbl
,   x_PRICE_LIST_LINE_val_tbl       => ppr_price_list_line_val_tbl
,   x_QUALIFIERS_tbl                => ppr_qualifiers_tbl
,   x_QUALIFIERS_val_tbl            => ppr_qualifiers_val_tbl
,   x_PRICING_ATTR_tbl              => ppr_pricing_attr_tbl
,   x_PRICING_ATTR_val_tbl          => ppr_pricing_attr_val_tbl
);


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  --Removed for bug8344368
  /*IF OE_Code_Control.Code_Release_Level >= '110510' THEN

     gpr_pricing_attr_tbl.delete;
     K := ppr_price_list_line_tbl.first;
     WHILE K is not null LOOP
        gpr_pricing_attr_tbl(K).list_line_id :=
                 ppr_price_list_line_tbl(K).list_line_id;
        gpr_pricing_attr_tbl(K).operation := QP_GLOBALS.G_OPR_CREATE;
        gpr_pricing_attr_tbl(K).pricing_attribute_context := 'QP_INTERNAL';
        gpr_pricing_attr_tbl(K).pricing_attribute := 'PRICING_ATTRIBUTE1';
        gpr_pricing_attr_tbl(K).pricing_attr_value_from :=
                 ppr_price_list_line_tbl(K).list_line_id;
        gpr_pricing_attr_tbl(K).comparison_operator_code := '=';
        if l_debug_level > 0 then
           oe_debug_pub.add('pricing attr id :'||
                               gpr_pricing_attr_tbl(K).pricing_attribute_id);
           oe_debug_pub.add('list line id :'||
                               gpr_pricing_attr_tbl(K).pricing_attr_value_from);
        end if;
	K := ppr_price_list_line_tbl.next(K);
     END LOOP;

     QP_PRICE_LIST_GRP.Process_Price_List
           ( p_api_version_number            => 1
           ,   p_init_msg_list                 => FND_API.G_FALSE
           ,   p_return_values                 => FND_API.G_FALSE
           ,   p_commit                        => FND_API.G_FALSE
           ,   x_return_status                 => x_return_status
           ,   x_msg_count                     => gpr_msg_count
           ,   x_msg_data                      => gpr_msg_data
           ,   p_PRICING_ATTR_tbl              => gpr_pricing_attr_tbl
           ,   x_PRICE_LIST_rec                => xpr_price_list_rec
           ,   x_PRICE_LIST_val_rec            => xpr_price_list_val_rec
           ,   x_PRICE_LIST_LINE_tbl           => xpr_price_list_line_tbl
           ,   x_PRICE_LIST_LINE_val_tbl       => xpr_price_list_line_val_tbl
           ,   x_QUALIFIERS_tbl                => xpr_qualifiers_tbl
           ,   x_QUALIFIERS_val_tbl            => xpr_qualifiers_val_tbl
           ,   x_PRICING_ATTR_tbl              => xpr_pricing_attr_tbl
           ,   x_PRICING_ATTR_val_tbl          => xpr_pricing_attr_val_tbl
           );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  END IF; -- end if code release level check to create pricing attributes

*/

  --11i10 Pricing Changes Start
  if oe_code_control.get_code_release_level >= '110510' then
	Update oe_blanket_headers
           set lock_control = lock_control + 1
               ,last_updated_by = fnd_global.user_id
               ,last_update_date = sysdate
	where header_id = lheader_id ;
	Update oe_blanket_headers_ext
	set new_price_list_id = ppr_price_list_rec.list_header_id
        where order_number = (select  /* MOAC_SQL_CHANGE */ order_number
                                from oe_blanket_headers_all
                               where header_id = lheader_id);
        g_header_rec.new_price_list_id := ppr_price_list_rec.list_header_id;
        --for bug 3285562
        IF g_header_rec.price_list_id is NULL
        THEN
           Update oe_blanket_headers
           set price_list_id = ppr_price_list_rec.list_header_id
           where header_id = lheader_id;
        g_header_rec.price_list_id := ppr_price_list_rec.list_header_id;
        END IF;
        --End bug 3285562
  else
	Update oe_blanket_headers
	set --qp_list_header_id = ppr_price_list_rec.list_header_id,
	    price_list_id = ppr_price_list_rec.list_header_id ,
		lock_control = lock_control + 1
	where header_id = lheader_id ;
        g_header_rec.price_list_id := ppr_price_list_rec.list_header_id;
  end if;
  --11i10 Pricing Changes End

	K := ppr_price_list_line_tbl.first;
	WHILE K is not null
	LOOP

	Update oe_blanket_lines
	set
	    price_list_id = ppr_price_list_rec.list_header_id,
		lock_control = lock_control + 1
	WHERE
	line_id = g_line_id_tbl(K).line_id ;

	UPDATE oe_blanket_lines_ext
	SET
	    qp_list_line_id = ppr_price_list_line_tbl(K).list_line_id
	WHERE
	line_id = g_line_id_tbl(K).line_id ;

		K := ppr_price_list_line_tbl.next(K);
	END LOOP;

        OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
		g_new_price_list := false;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END create_price_list;

PROCEDURE Add_price_list_line
(p_req_ind           IN NUMBER
,x_return_status     OUT NOCOPY varchar2)
IS
 gpr_return_status varchar2(1) := NULL;
 gpr_msg_count number := 0;
 gpr_msg_data varchar2(2000);
 gpr_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 gpr_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 gpr_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 gpr_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 gpr_qualifiers_tbl QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 gpr_qualifiers_val_tbl QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 gpr_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 gpr_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 ppr_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 ppr_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 ppr_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 ppr_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 ppr_qualifiers_tbl QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 ppr_qualifiers_val_tbl QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 ppr_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 xpr_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 xpr_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 xpr_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 xpr_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 xpr_qualifiers_tbl QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 xpr_qualifiers_val_tbl QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 xpr_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 xpr_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 K number := 1;
 j number := 1;
 I number := p_req_ind;
 lheader_id number;
 l_list_line_seq NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	--begin commented the below if statement for bug 4762658
		/*IF oe_delayed_requests_pvt.g_delayed_requests(I).param3 IS NULL THEN
				RETURN;
		END IF;*/
	--end for bug 4762658
	--for bug 3229225
        IF  (oe_delayed_requests_pvt.g_delayed_requests(I).param1 IS NULL OR oe_delayed_requests_pvt.g_delayed_requests(I).param1=FND_API.G_MISS_NUM)
        THEN
           IF l_debug_level > 0
           THEN
              oe_debug_pub.add('Skip for null values');
           END IF;
           oe_delayed_requests_pvt.g_delayed_requests.delete(I);
           GOTO SKIP_LINE1;
        END IF;

          select QP_LIST_LINES_S.NEXTVAL into l_list_line_seq from dual; --bug8344368
	  gpr_price_list_line_tbl(k).list_line_id := l_list_line_seq;
          gpr_price_list_line_tbl(k).list_line_type_code := 'PLL';
          gpr_price_list_line_tbl(k).operation := QP_GLOBALS.G_OPR_CREATE;
          gpr_price_list_line_tbl(k).operand := oe_delayed_requests_pvt.g_delayed_requests(I).param1;
          gpr_price_list_line_tbl(k).arithmetic_operator := 'UNIT_PRICE';
          gpr_price_list_line_tbl(k).list_header_id :=
	   oe_delayed_requests_pvt.g_delayed_requests(I).param5 ;
        -- Bug 3209215, Issue 9.1
        -- Pass precedence value on price list lines
        gpr_price_list_line_tbl(k).product_precedence := 1;

        gpr_pricing_attr_tbl(K).pricing_attribute_id := FND_API.G_MISS_NUM;
        gpr_pricing_attr_tbl(K).list_line_id := FND_API.G_MISS_NUM;
        gpr_pricing_attr_tbl(K).list_header_id :=
		oe_delayed_requests_pvt.g_delayed_requests(I).param5;
        gpr_pricing_attr_tbl(K).PRODUCT_ATTRIBUTE_CONTEXT := 'ITEM';

	IF oe_delayed_requests_pvt.g_delayed_requests(I).param4 = 'CAT' THEN

	   gpr_pricing_attr_tbl(K).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE2';
           gpr_pricing_attr_tbl(K).PRODUCT_ATTR_VALUE := oe_delayed_requests_pvt.g_delayed_requests(I).param3;

	ELSIF oe_delayed_requests_pvt.g_delayed_requests(I).param4 = 'ALL' THEN

	   gpr_pricing_attr_tbl(K).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE3';
           gpr_pricing_attr_tbl(K).PRODUCT_ATTR_VALUE := 'ALL';

	ELSE

	   gpr_pricing_attr_tbl(K).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE1';
           gpr_pricing_attr_tbl(K).PRODUCT_ATTR_VALUE := oe_delayed_requests_pvt.g_delayed_requests(I).param3;

           -- 11i10 Pricing Change
           -- Send customer item on price list line record
           IF oe_delayed_requests_pvt.g_delayed_requests(I).param4 = 'CUST'
              AND OE_Code_Control.Get_Code_Release_Level >= '110510'
           THEN
              gpr_price_list_line_tbl(k).customer_item_id :=
                oe_delayed_requests_pvt.g_delayed_requests(I).param8;
             oe_debug_pub.add('sending cust item id :'||
                gpr_price_list_line_tbl(k).customer_item_id);
           END IF;

	END IF;

        gpr_pricing_attr_tbl(K).PRODUCT_UOM_CODE := oe_delayed_requests_pvt.g_delayed_requests(I).param2;
        gpr_pricing_attr_tbl(K).EXCLUDER_FLAG := 'N';
        gpr_pricing_attr_tbl(K).ATTRIBUTE_GROUPING_NO := 1;
        gpr_pricing_attr_tbl(K).list_line_id := l_list_line_seq;
        gpr_pricing_attr_tbl(K).operation := QP_GLOBALS.G_OPR_CREATE;

	--Added for bug8344368
	k:= K+1;

	gpr_pricing_attr_tbl(K).pricing_attribute_id := FND_API.G_MISS_NUM;
	gpr_pricing_attr_tbl(K).list_line_id := l_list_line_seq;
        gpr_pricing_attr_tbl(K).operation := QP_GLOBALS.G_OPR_CREATE;
        gpr_pricing_attr_tbl(K).pricing_attribute_context := 'QP_INTERNAL';
        gpr_pricing_attr_tbl(K).pricing_attribute := 'PRICING_ATTRIBUTE1';
        gpr_pricing_attr_tbl(K).pricing_attr_value_from := l_list_line_seq;--bug8344368
        gpr_pricing_attr_tbl(K).comparison_operator_code := '=';


                --oe_delayed_requests_pvt.g_delayed_requests.delete(I);

        QP_PRICE_LIST_GRP.Process_Price_List
(   p_api_version_number            => 1
,   p_init_msg_list                 => FND_API.G_FALSE
,   p_return_values                 => FND_API.G_FALSE
,   p_commit                        => FND_API.G_FALSE
,   x_return_status                 => x_return_status
,   x_msg_count                     => gpr_msg_count
,   x_msg_data                      => gpr_msg_data
,   p_PRICE_LIST_rec                => gpr_price_list_rec
,   p_PRICE_LIST_LINE_tbl           => gpr_price_list_line_tbl
,   p_PRICING_ATTR_tbl              => gpr_pricing_attr_tbl
,   x_PRICE_LIST_rec                => ppr_price_list_rec
,   x_PRICE_LIST_val_rec            => ppr_price_list_val_rec
,   x_PRICE_LIST_LINE_tbl           => ppr_price_list_line_tbl
,   x_PRICE_LIST_LINE_val_tbl       => ppr_price_list_line_val_tbl
,   x_QUALIFIERS_tbl                => ppr_qualifiers_tbl
,   x_QUALIFIERS_val_tbl            => ppr_qualifiers_val_tbl
,   x_PRICING_ATTR_tbl              => ppr_pricing_attr_tbl
,   x_PRICING_ATTR_val_tbl          => ppr_pricing_attr_val_tbl
);


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

 -- removed for bug8344368
 /* IF OE_Code_Control.Code_Release_Level >= '110510' THEN

     gpr_pricing_attr_tbl.delete;
     K := ppr_price_list_line_tbl.first;
     WHILE K is not null LOOP
        gpr_pricing_attr_tbl(K).list_line_id :=
                 ppr_price_list_line_tbl(K).list_line_id;
        gpr_pricing_attr_tbl(K).operation := QP_GLOBALS.G_OPR_CREATE;
        gpr_pricing_attr_tbl(K).pricing_attribute_context := 'QP_INTERNAL';
        gpr_pricing_attr_tbl(K).pricing_attribute := 'PRICING_ATTRIBUTE1';
        gpr_pricing_attr_tbl(K).pricing_attr_value_from :=
                 ppr_price_list_line_tbl(K).list_line_id;
        gpr_pricing_attr_tbl(K).comparison_operator_code := '=';
        if l_debug_level > 0 then
           oe_debug_pub.add('pricing attr id :'||
                               gpr_pricing_attr_tbl(K).pricing_attribute_id);
           oe_debug_pub.add('list line id :'||
                               gpr_pricing_attr_tbl(K).pricing_attr_value_from);
        end if;
	K := ppr_price_list_line_tbl.next(K);
     END LOOP;

     QP_PRICE_LIST_GRP.Process_Price_List
           ( p_api_version_number            => 1
           ,   p_init_msg_list                 => FND_API.G_FALSE
           ,   p_return_values                 => FND_API.G_FALSE
           ,   p_commit                        => FND_API.G_FALSE
           ,   x_return_status                 => x_return_status
           ,   x_msg_count                     => gpr_msg_count
           ,   x_msg_data                      => gpr_msg_data
           ,   p_PRICING_ATTR_tbl              => gpr_pricing_attr_tbl
           ,   x_PRICE_LIST_rec                => xpr_price_list_rec
           ,   x_PRICE_LIST_val_rec            => xpr_price_list_val_rec
           ,   x_PRICE_LIST_LINE_tbl           => xpr_price_list_line_tbl
           ,   x_PRICE_LIST_LINE_val_tbl       => xpr_price_list_line_val_tbl
           ,   x_QUALIFIERS_tbl                => xpr_qualifiers_tbl
           ,   x_QUALIFIERS_val_tbl            => xpr_qualifiers_val_tbl
           ,   x_PRICING_ATTR_tbl              => xpr_pricing_attr_tbl
           ,   x_PRICING_ATTR_val_tbl          => xpr_pricing_attr_val_tbl
           );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  END IF; -- end if code release level check to create pricing attributes
*/

        Update oe_blanket_lines
        set
            price_list_id = ppr_price_list_line_tbl(1).list_header_id,
                lock_control = lock_control + 1
        WHERE
        line_id =
	 oe_delayed_requests_pvt.g_delayed_requests(I).entity_id ;

        Update oe_blanket_lines_ext
        set qp_list_line_id = ppr_price_list_line_tbl(1).list_line_id
        WHERE
        line_id =
	 oe_delayed_requests_pvt.g_delayed_requests(I).entity_id ;

<< SKIP_LINE1 >>
            g_new_price_list := false;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

NULL;
END Add_price_list_line;


--for bug 3309427
--To clear the List Line ID if the user swaps from inline Pricelist to standard Pricelist
PROCEDURE Clear_Price_List_Line
(p_req_ind           IN NUMBER
,x_return_status     OUT NOCOPY varchar2)
IS
--
 gpr_return_status varchar2(1)	:= NULL;
 gpr_msg_count number 		:= 0;
 gpr_msg_data varchar2(2000);
 gpr_price_list_rec		QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 gpr_price_list_line_tbl 	QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 gpr_pricing_attr_tbl 		QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 gpr_pricing_attr_val_tbl 	QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 ppr_price_list_rec 		QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 ppr_price_list_val_rec 	QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 ppr_price_list_line_tbl	QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 ppr_price_list_line_val_tbl 	QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
 ppr_qualifiers_tbl 		QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 ppr_qualifiers_val_tbl 	QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 ppr_pricing_attr_tbl 		QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_attr_val_tbl 	QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
 k number			:= 1;
 l_debug_level CONSTANT NUMBER 	:= oe_debug_pub.g_debug_level;
--
BEGIN
  x_return_status:= FND_API.G_RET_STS_SUCCESS;
  gpr_price_list_line_tbl(K).list_line_id := oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).Param1 ;
  gpr_price_list_line_tbl(K).operation 	  := QP_GLOBALS.G_OPR_UPDATE;
  gpr_price_list_line_tbl(K).list_header_id :=
		oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param2;
  gpr_price_list_line_tbl(K).end_date_active :=sysdate;

  IF((NOT IS_BLANKET_PRICE_LIST(p_price_list_id => oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).Param3
                                ,p_blanket_header_id =>oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).Param4 ))
  AND (gpr_price_list_line_tbl(K).list_line_id is not null))
  THEN
     QP_PRICE_LIST_GRP.Process_Price_List
	(   p_api_version_number            => 1
	,   p_init_msg_list                 => FND_API.G_FALSE
	,   p_return_values                 => FND_API.G_FALSE
	,   p_commit                        => FND_API.G_FALSE
	,   x_return_status                 => x_return_status
	,   x_msg_count                     => gpr_msg_count
	,   x_msg_data                      => gpr_msg_data
	,   p_PRICE_LIST_rec                => gpr_price_list_rec
	,   p_PRICE_LIST_LINE_tbl           => gpr_price_list_line_tbl
	,   p_PRICING_ATTR_tbl              => gpr_pricing_attr_tbl
	,   x_PRICE_LIST_rec                => ppr_price_list_rec
	,   x_PRICE_LIST_val_rec            => ppr_price_list_val_rec
	,   x_PRICE_LIST_LINE_tbl           => ppr_price_list_line_tbl
	,   x_PRICE_LIST_LINE_val_tbl       => ppr_price_list_line_val_tbl
	,   x_QUALIFIERS_tbl                => ppr_qualifiers_tbl
	,   x_QUALIFIERS_val_tbl            => ppr_qualifiers_val_tbl
	,   x_PRICING_ATTR_tbl              => ppr_pricing_attr_tbl
	,   x_PRICING_ATTR_val_tbl          => ppr_pricing_attr_val_tbl
	);


     IF  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;

     Update oe_blanket_lines_ext
     set    qp_list_line_id = Null
     WHERE  line_id = oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).entity_id ;
  END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Expected Error in Clear_Blanket_List_line...',4);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('UnExpected Error in Clear_Blanket_list_line...'||sqlerrm,4);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           OE_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME
             ,'Validate Attributes'
             );
        END IF;
END Clear_price_list_line;

PROCEDURE Validate_Attributes
(  p_x_header_rec        IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
,  p_old_header_rec      IN OE_Blanket_PUB.Header_rec_type
,  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL
,  x_return_status       OUT NOCOPY VARCHAR2
) IS
l_dummy VARCHAR2(10);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    if l_debug_level > 0 then
       oe_debug_pub.add('Entering OE_BLANKET_UTIL.VALIDATE_ATTRIBUTES',1);
    end if;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate header attributes

    IF  p_x_header_rec.accounting_rule_id IS NOT NULL AND
        (   p_x_header_rec.accounting_rule_id <>
            p_old_header_rec.accounting_rule_id OR
            p_old_header_rec.accounting_rule_id IS NULL )
    THEN

      IF NOT OE_Validate.Accounting_Rule(p_x_header_rec.accounting_rule_id)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.accounting_rule_id := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.freight_terms_code IS NOT NULL AND
        (   p_x_header_rec.freight_terms_code <>
            p_old_header_rec.freight_terms_code OR
            p_old_header_rec.freight_terms_code IS NULL )
    THEN

      IF NOT OE_Validate.Freight_Terms(p_x_header_rec.freight_terms_code)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.freight_terms_code := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
       END IF;

    END IF;

       IF  p_x_header_rec.invoicing_rule_id IS NOT NULL AND
        (   p_x_header_rec.invoicing_rule_id <>
            p_old_header_rec.invoicing_rule_id OR
            p_old_header_rec.invoicing_rule_id IS NULL )
    THEN

      IF NOT OE_Validate.Invoicing_Rule(p_x_header_rec.invoicing_rule_id)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.invoicing_rule_id := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
       END IF;

    END IF;

     IF  p_x_header_rec.order_type_id IS NOT NULL AND
        (   p_x_header_rec.order_type_id <>
            p_old_header_rec.order_type_id OR
            p_old_header_rec.order_type_id IS NULL )
    THEN
       BEGIN

       SELECT 'VALID' into l_dummy
       FROM 	oe_transaction_types_vl
       WHERE 	SALES_DOCUMENT_TYPE_CODE = 'B'
       AND      transaction_type_id = p_x_header_rec.order_type_id
       AND	trunc(sysdate) between start_date_Active and
        nvl(end_date_active,trunc(sysdate));

       EXCEPTION
         WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
       END;
    END IF;

    IF  p_x_header_rec.payment_term_id IS NOT NULL AND
        (   p_x_header_rec.payment_term_id <>
            p_old_header_rec.payment_term_id OR
            p_old_header_rec.payment_term_id IS NULL )
    THEN
      IF NOT OE_Validate.Payment_Term(p_x_header_rec.payment_term_id)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.payment_term_id := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.price_list_id IS NOT NULL AND
        (   p_x_header_rec.price_list_id <>
            p_old_header_rec.price_list_id OR
            p_old_header_rec.price_list_id IS NULL )
    THEN
      IF NOT OE_Validate.Price_List(p_x_header_rec.price_list_id)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.price_list_id := NULL;
	 ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.shipping_method_code IS NOT NULL AND
        (   p_x_header_rec.shipping_method_code <>
            p_old_header_rec.shipping_method_code OR
            p_old_header_rec.shipping_method_code IS NULL )
    THEN

      IF NOT OE_Validate.Shipping_Method(p_x_header_rec.shipping_method_code)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.shipping_method_code := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.ship_from_org_id IS NOT NULL AND
        (   p_x_header_rec.ship_from_org_id <>
            p_old_header_rec.ship_from_org_id OR
            p_old_header_rec.ship_from_org_id IS NULL )
    THEN

      IF NOT OE_Validate.Ship_From_Org(p_x_header_rec.ship_from_org_id)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.ship_from_org_id := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.sold_to_org_id IS NOT NULL AND
        (   p_x_header_rec.sold_to_org_id <>
            p_old_header_rec.sold_to_org_id OR
            p_old_header_rec.sold_to_org_id IS NULL )
    THEN

      IF NOT OE_Validate.Sold_To_Org(p_x_header_rec.sold_to_org_id)
      THEN
           x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

    END IF;

-- hashraf start of pack J
    IF  p_x_header_rec.sold_to_site_use_id IS NOT NULL AND
        (   p_x_header_rec.sold_to_site_use_id <>
            p_old_header_rec.sold_to_site_use_id OR
            p_old_header_rec.sold_to_site_use_id IS NULL )
    THEN

      IF NOT OE_Validate.Customer_Location(p_x_header_rec.sold_to_site_use_id)
      THEN
           x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

    END IF;

-- hashraf end of pack J

    IF  p_x_header_rec.invoice_to_org_id IS NOT NULL AND
        (   p_x_header_rec.invoice_to_org_id <>
            p_old_header_rec.invoice_to_org_id OR
            p_old_header_rec.invoice_to_org_id IS NULL )
    THEN

      IF NOT OE_Validate.Invoice_To_Org(p_x_header_rec.invoice_to_org_id)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.invoice_to_org_id := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.ship_to_org_id IS NOT NULL AND
        (   p_x_header_rec.ship_to_org_id <>
            p_old_header_rec.ship_to_org_id OR
            p_old_header_rec.ship_to_org_id IS NULL )
    THEN

      IF NOT OE_Validate.Ship_To_Org(p_x_header_rec.ship_to_org_id)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.ship_to_org_id := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.transactional_curr_code IS NOT NULL AND
        (   p_x_header_rec.transactional_curr_code <>
            p_old_header_rec.transactional_curr_code OR
            p_old_header_rec.transactional_curr_code IS NULL )
    THEN

      IF NOT OE_Validate.Transactional_Curr
                         (p_x_header_rec.transactional_curr_code)
      THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;

    -- Salesrep_id
    IF  p_x_header_rec.salesrep_id IS NOT NULL AND
        (   p_x_header_rec.salesrep_id <>
            p_old_header_rec.salesrep_id OR
            p_old_header_rec.salesrep_id IS NULL )
    THEN

      IF NOT OE_Validate.salesrep(p_x_header_rec.salesrep_id)
      THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_header_rec.salesrep_id := NULL;
	 ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    -- Validate descriptive flex

    IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE OR

    (  p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
         (p_x_header_rec.attribute1 IS NOT NULL AND
        (   p_x_header_rec.attribute1 <>
            p_old_header_rec.attribute1 OR
            p_old_header_rec.attribute1 IS NULL ))
    OR  (p_x_header_rec.attribute10 IS NOT NULL AND
        (   p_x_header_rec.attribute10 <>
            p_old_header_rec.attribute10 OR
            p_old_header_rec.attribute10 IS NULL ))
    OR  (p_x_header_rec.attribute11 IS NOT NULL AND
        (   p_x_header_rec.attribute11 <>
            p_old_header_rec.attribute11 OR
            p_old_header_rec.attribute11 IS NULL ))
    OR  (p_x_header_rec.attribute12 IS NOT NULL AND
        (   p_x_header_rec.attribute12 <>
            p_old_header_rec.attribute12 OR
            p_old_header_rec.attribute12 IS NULL ))
    OR  (p_x_header_rec.attribute13 IS NOT NULL AND
        (   p_x_header_rec.attribute13 <>
            p_old_header_rec.attribute13 OR
            p_old_header_rec.attribute13 IS NULL ))
    OR  (p_x_header_rec.attribute14 IS NOT NULL AND
        (   p_x_header_rec.attribute14 <>
            p_old_header_rec.attribute14 OR
            p_old_header_rec.attribute14 IS NULL ))
    OR  (p_x_header_rec.attribute15 IS NOT NULL AND
        (   p_x_header_rec.attribute15 <>
            p_old_header_rec.attribute15 OR
            p_old_header_rec.attribute15 IS NULL ))
    OR  (p_x_header_rec.attribute16 IS NOT NULL AND --For bug 2184255
        (   p_x_header_rec.attribute16 <>
            p_old_header_rec.attribute16 OR
            p_old_header_rec.attribute16 IS NULL ))
    OR  (p_x_header_rec.attribute17 IS NOT NULL AND
        (   p_x_header_rec.attribute17 <>
            p_old_header_rec.attribute17 OR
            p_old_header_rec.attribute17 IS NULL ))
    OR  (p_x_header_rec.attribute18 IS NOT NULL AND
        (   p_x_header_rec.attribute18 <>
            p_old_header_rec.attribute18 OR
            p_old_header_rec.attribute18 IS NULL ))
    OR  (p_x_header_rec.attribute19 IS NOT NULL AND
        (   p_x_header_rec.attribute19 <>
            p_old_header_rec.attribute19 OR
            p_old_header_rec.attribute19 IS NULL ))
    OR  (p_x_header_rec.attribute2 IS NOT NULL AND
        (   p_x_header_rec.attribute2 <>
            p_old_header_rec.attribute2 OR
            p_old_header_rec.attribute2 IS NULL ))
    OR  (p_x_header_rec.attribute20 IS NOT NULL AND  -- for bug 2184255
        (   p_x_header_rec.attribute20 <>
            p_old_header_rec.attribute20 OR
            p_old_header_rec.attribute20 IS NULL ))
    OR  (p_x_header_rec.attribute3 IS NOT NULL AND
        (   p_x_header_rec.attribute3 <>
            p_old_header_rec.attribute3 OR
            p_old_header_rec.attribute3 IS NULL ))
    OR  (p_x_header_rec.attribute4 IS NOT NULL AND
        (   p_x_header_rec.attribute4 <>
            p_old_header_rec.attribute4 OR
            p_old_header_rec.attribute4 IS NULL ))
    OR  (p_x_header_rec.attribute5 IS NOT NULL AND
        (   p_x_header_rec.attribute5 <>
            p_old_header_rec.attribute5 OR
            p_old_header_rec.attribute5 IS NULL ))
    OR  (p_x_header_rec.attribute6 IS NOT NULL AND
        (   p_x_header_rec.attribute6 <>
            p_old_header_rec.attribute6 OR
            p_old_header_rec.attribute6 IS NULL ))
    OR  (p_x_header_rec.attribute7 IS NOT NULL AND
        (   p_x_header_rec.attribute7 <>
            p_old_header_rec.attribute7 OR
            p_old_header_rec.attribute7 IS NULL ))
    OR  (p_x_header_rec.attribute8 IS NOT NULL AND
        (   p_x_header_rec.attribute8 <>
            p_old_header_rec.attribute8 OR
            p_old_header_rec.attribute8 IS NULL ))
    OR  (p_x_header_rec.attribute9 IS NOT NULL AND
        (   p_x_header_rec.attribute9 <>
            p_old_header_rec.attribute9 OR
            p_old_header_rec.attribute9 IS NULL ))
    OR  (p_x_header_rec.context IS NOT NULL AND
        (   p_x_header_rec.context <>
            p_old_header_rec.context OR
            p_old_header_rec.context IS NULL )))
    THEN


         oe_debug_pub.add('Before calling header_desc_flex',2);
	IF OE_ORDER_CACHE.IS_FLEX_ENABLED('OE_BLKT_HEADER_ATTRIBUTES') = 'Y' THEN

         IF NOT OE_VALIDATE.Header_Desc_Flex
          (p_context            => p_x_header_rec.context
          ,p_attribute1         => p_x_header_rec.attribute1
          ,p_attribute2         => p_x_header_rec.attribute2
          ,p_attribute3         => p_x_header_rec.attribute3
          ,p_attribute4         => p_x_header_rec.attribute4
          ,p_attribute5         => p_x_header_rec.attribute5
          ,p_attribute6         => p_x_header_rec.attribute6
          ,p_attribute7         => p_x_header_rec.attribute7
          ,p_attribute8         => p_x_header_rec.attribute8
          ,p_attribute9         => p_x_header_rec.attribute9
          ,p_attribute10        => p_x_header_rec.attribute10
          ,p_attribute11        => p_x_header_rec.attribute11
          ,p_attribute12        => p_x_header_rec.attribute12
          ,p_attribute13        => p_x_header_rec.attribute13
          ,p_attribute14        => p_x_header_rec.attribute14
          ,p_attribute15        => p_x_header_rec.attribute15
          ,p_attribute16        => p_x_header_rec.attribute16  -- for bug 2184255
          ,p_attribute17        => p_x_header_rec.attribute17
          ,p_attribute18        => p_x_header_rec.attribute18
          ,p_attribute19        => p_x_header_rec.attribute19
          ,p_attribute20        => p_x_header_rec.attribute20
          ,p_document_type      => 'BLANKET')
          THEN

            IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
               p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
            THEN
                p_x_header_rec.context    := null;
                p_x_header_rec.attribute1 := null;
                p_x_header_rec.attribute2 := null;
                p_x_header_rec.attribute3 := null;
                p_x_header_rec.attribute4 := null;
                p_x_header_rec.attribute5 := null;
                p_x_header_rec.attribute6 := null;
                p_x_header_rec.attribute7 := null;
                p_x_header_rec.attribute8 := null;
                p_x_header_rec.attribute9 := null;
                p_x_header_rec.attribute10 := null;
                p_x_header_rec.attribute11 := null;
                p_x_header_rec.attribute12 := null;
                p_x_header_rec.attribute13 := null;
                p_x_header_rec.attribute14 := null;
                p_x_header_rec.attribute15 := null;
                p_x_header_rec.attribute16 := null;  -- for bug 2184255
                p_x_header_rec.attribute17 := null;
                p_x_header_rec.attribute18 := null;
                p_x_header_rec.attribute19 := null;
                p_x_header_rec.attribute20 := null;


            ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
                  p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
            THEN
                p_x_header_rec.context    := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute1 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute2 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute3 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute4 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute5 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute6 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute7 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute8 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute9 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute10 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute11 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute12 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute13 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute14 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute15 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute16 := FND_API.G_MISS_CHAR;  -- for bug 2184255
                p_x_header_rec.attribute17 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute18 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute19 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute20 := FND_API.G_MISS_CHAR;


            ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
	  ELSE -- if the flex validation is successfull
	    -- For bug 2511313
	    IF p_x_header_rec.context IS NULL
	      OR p_x_header_rec.context = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.context    := oe_validate.g_context;
	    END IF;

	    IF p_x_header_rec.attribute1 IS NULL
	      OR p_x_header_rec.attribute1 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute1 := oe_validate.g_attribute1;
	    END IF;

	    IF p_x_header_rec.attribute2 IS NULL
	      OR p_x_header_rec.attribute2 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute2 := oe_validate.g_attribute2;
	    END IF;

	    IF p_x_header_rec.attribute3 IS NULL
	      OR p_x_header_rec.attribute3 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute3 := oe_validate.g_attribute3;
	    END IF;

	    IF p_x_header_rec.attribute4 IS NULL
	      OR p_x_header_rec.attribute4 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute4 := oe_validate.g_attribute4;
	    END IF;

	    IF p_x_header_rec.attribute5 IS NULL
	      OR p_x_header_rec.attribute5 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute5 := oe_validate.g_attribute5;
	    END IF;

	    IF p_x_header_rec.attribute6 IS NULL
	      OR p_x_header_rec.attribute6 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute6 := oe_validate.g_attribute6;
	    END IF;

	    IF p_x_header_rec.attribute7 IS NULL
	      OR p_x_header_rec.attribute7 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute7 := oe_validate.g_attribute7;
	    END IF;

	    IF p_x_header_rec.attribute8 IS NULL
	      OR p_x_header_rec.attribute8 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute8 := oe_validate.g_attribute8;
	    END IF;

	    IF p_x_header_rec.attribute9 IS NULL
	      OR p_x_header_rec.attribute9 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute9 := oe_validate.g_attribute9;
	    END IF;

	    IF p_x_header_rec.attribute10 IS NULL
	      OR p_x_header_rec.attribute10 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute10 := Oe_validate.G_attribute10;
	    End IF;

	    IF p_x_header_rec.attribute11 IS NULL
	      OR p_x_header_rec.attribute11 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute11 := oe_validate.g_attribute11;
	    END IF;

	    IF p_x_header_rec.attribute12 IS NULL
	      OR p_x_header_rec.attribute12 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute12 := oe_validate.g_attribute12;
	    END IF;

	    IF p_x_header_rec.attribute13 IS NULL
	      OR p_x_header_rec.attribute13 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute13 := oe_validate.g_attribute13;
	    END IF;

	    IF p_x_header_rec.attribute14 IS NULL
	      OR p_x_header_rec.attribute14 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute14 := oe_validate.g_attribute14;
	    END IF;

	    IF p_x_header_rec.attribute15 IS NULL
	      OR p_x_header_rec.attribute15 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute15 := oe_validate.g_attribute15;
	    END IF;

	    IF p_x_header_rec.attribute16 IS NULL  -- for bug 2184255
	      OR p_x_header_rec.attribute16 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute16 := oe_validate.g_attribute16;
	    END IF;

	    IF p_x_header_rec.attribute17 IS NULL
	      OR p_x_header_rec.attribute17 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute17 := oe_validate.g_attribute17;
	    END IF;

	    IF p_x_header_rec.attribute18 IS NULL
	      OR p_x_header_rec.attribute18 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute18 := oe_validate.g_attribute18;
	    END IF;

	    IF p_x_header_rec.attribute19 IS NULL
	      OR p_x_header_rec.attribute19 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute19 := oe_validate.g_attribute19;
	    END IF;

	    IF p_x_header_rec.attribute20 IS NULL
	      OR p_x_header_rec.attribute20 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute20 := oe_validate.g_attribute20;
	    END IF;

	    -- end of assignments, bug 2511313
	 END IF;
	END IF ; -- If flex enabled
    END IF;

    if l_debug_level > 0 then
      oe_debug_pub.add('After blanket header_desc_flex  ' || x_return_status,2);
      oe_debug_pub.add('Exiting OE_BLANKET_UTIL.VALIDATE_ATTRIBUTES',1);
    end if;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
           ,'Validate Attributes'
         );
      END IF;

END Validate_Attributes;

PROCEDURE Validate_Attributes
( p_x_line_rec         IN OUT NOCOPY OE_Blanket_PUB.line_rec_type
, p_old_line_rec       IN OE_Blanket_PUB.line_rec_type
,  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL
, x_return_status      OUT NOCOPY VARCHAR2
) IS
--{ Bug # 5562785

l_context_required_flag fnd_descriptive_flexs_vl.context_required_flag%TYPE;
l_default_context_field_name fnd_descriptive_flexs_vl.default_context_field_name%TYPE;
l_validate_line VARCHAR2(1) := 'Y';

CURSOR c_check_context(l_flex_name fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE) IS
  SELECT context_required_flag, default_context_field_name
  FROM FND_DESCRIPTIVE_FLEXS_VL
  WHERE (application_id = 660)
  AND (descriptive_flexfield_name = l_flex_name);
  -- Bug # 5562785}
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    if l_debug_level > 0 then
       oe_debug_pub.add('Enter procedure OE_blanket_util.validate line Attributes',1);
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
 -- Compare line attributes with header record if the header record is
    -- created in the same call to process_order. If they match
    -- then no need to re-validate line attributes.


--  Validate line attributes

    IF  p_x_line_rec.accounting_rule_id IS NOT NULL AND
        (   p_x_line_rec.accounting_rule_id <>
            p_old_line_rec.accounting_rule_id OR
            p_old_line_rec.accounting_rule_id IS NULL )
    THEN
      if l_debug_level > 0 then
        oe_debug_pub.add('Calling OE_VALIDATE for accounting_rule',1);
      end if;
        IF NOT OE_Validate.Accounting_Rule(p_x_line_rec.accounting_rule_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_line_rec.accounting_rule_id := NULL;
	 ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.freight_terms_code IS NOT NULL AND
        (   p_x_line_rec.freight_terms_code <>
            p_old_line_rec.freight_terms_code OR
            p_old_line_rec.freight_terms_code IS NULL )
    THEN

        IF NOT OE_Validate.Freight_Terms(p_x_line_rec.freight_terms_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_line_rec.freight_terms_code := NULL;
	 ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
	END IF;
    END IF;

    IF  p_x_line_rec.invoicing_rule_id IS NOT NULL AND
        (   p_x_line_rec.invoicing_rule_id <>
            p_old_line_rec.invoicing_rule_id OR
            p_old_line_rec.invoicing_rule_id IS NULL )
    THEN
        IF NOT OE_Validate.Invoicing_Rule(p_x_line_rec.invoicing_rule_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_line_rec.invoicing_rule_id := NULL;
	 ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.item_type_code IS NOT NULL AND
        (   p_x_line_rec.item_type_code <>
            p_old_line_rec.item_type_code OR
            p_old_line_rec.item_type_code IS NULL )
    THEN
        IF NOT OE_Validate.Item_Type(p_x_line_rec.item_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_x_line_rec.payment_term_id IS NOT NULL AND
        (   p_x_line_rec.payment_term_id <>
            p_old_line_rec.payment_term_id OR
            p_old_line_rec.payment_term_id IS NULL )
    THEN
        IF NOT OE_Validate.Payment_Term(p_x_line_rec.payment_term_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_line_rec.payment_term_id := NULL;
	 ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.price_list_id IS NOT NULL AND
        (   p_x_line_rec.price_list_id <>
            p_old_line_rec.price_list_id OR
            p_old_line_rec.price_list_id IS NULL )
    THEN
        IF NOT OE_Validate.Price_List(p_x_line_rec.price_list_id) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_x_line_rec.shipping_method_code IS NOT NULL AND
        (   p_x_line_rec.shipping_method_code <>
            p_old_line_rec.shipping_method_code OR
            p_old_line_rec.shipping_method_code IS NULL )
    THEN
        IF NOT OE_Validate.Shipping_Method(p_x_line_rec.shipping_method_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_line_rec.shipping_method_code := NULL;
	 ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.ship_from_org_id IS NOT NULL AND
        (   p_x_line_rec.ship_from_org_id <>
            p_old_line_rec.ship_from_org_id OR
            p_old_line_rec.ship_from_org_id IS NULL )
    THEN
        IF NOT OE_Validate.Ship_From_Org(p_x_line_rec.ship_from_org_id) THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_line_rec.ship_from_org_id := NULL;
	  ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.salesrep_id IS NOT NULL AND
        (   p_x_line_rec.salesrep_id <>
            p_old_line_rec.salesrep_id OR
            p_old_line_rec.salesrep_id IS NULL )
    THEN
        IF NOT OE_Validate.salesrep(p_x_line_rec.salesrep_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
	   p_x_line_rec.salesrep_id := NULL;
	 ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;

    --{ Bug # 5562785

OPEN c_check_context('OE_BLKT_LINE_ATTRIBUTES');
FETCH c_check_context INTO l_context_required_flag,l_default_context_field_name;
CLOSE c_check_context;

oe_debug_pub.add('Maitrayee: Entering the code change in Validate_Attributes');
-- Skip the Validation if not changes are made in the DFF from the UI.

IF l_context_required_flag = 'Y' AND ( p_x_line_rec.context IS NULL OR p_x_line_rec.context = FND_API.G_MISS_CHAR ) AND (OE_GLOBALS.G_UI_FLAG) THEN

  l_validate_line := 'N';
  IF l_debug_level > 0 then
    oe_debug_pub.add('Skipping Validation');
  END IF;

ELSIF l_context_required_flag = 'Y' AND ( p_x_line_rec.context IS NULL OR p_x_line_rec.context = FND_API.G_MISS_CHAR ) AND NOT (OE_GLOBALS.G_UI_FLAG) THEN

-- Show Error message if appropriate context value is not passed
-- from the Process Order Call and if the Context field is required.

	FND_MESSAGE.SET_NAME('FND', 'ONT_BLKT_CONTEXT_NOT_FOUND');

        OE_MSG_PUB.ADD;
	IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Context not set for OE_BLKT_LINE_ATTRIBUTES DFF ' ) ;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
 ELSE

 -- Validate the DFF in all other cases.

  l_validate_line := 'Y';

  IF l_debug_level > 0 then
     oe_debug_pub.add('Validating the Flex Field');
  END IF;

END IF;

-- Bug # 5562785)

  IF(l_validate_line = 'Y') THEN   -- Bug # 5562785

    IF p_x_line_rec.operation = oe_globals.g_opr_create OR
	(p_x_line_rec.operation = oe_globals.g_opr_update  AND
          (p_x_line_rec.attribute1 IS NOT NULL AND
        (   p_x_line_rec.attribute1 <>
            p_old_line_rec.attribute1 OR
            p_old_line_rec.attribute1 IS NULL ))
    OR  (p_x_line_rec.attribute10 IS NOT NULL AND
        (   p_x_line_rec.attribute10 <>
            p_old_line_rec.attribute10 OR
            p_old_line_rec.attribute10 IS NULL ))
    OR  (p_x_line_rec.attribute11 IS NOT NULL AND
        (   p_x_line_rec.attribute11 <>
            p_old_line_rec.attribute11 OR
            p_old_line_rec.attribute11 IS NULL ))
    OR  (p_x_line_rec.attribute12 IS NOT NULL AND
        (   p_x_line_rec.attribute12 <>
            p_old_line_rec.attribute12 OR
            p_old_line_rec.attribute12 IS NULL ))
    OR  (p_x_line_rec.attribute13 IS NOT NULL AND
        (   p_x_line_rec.attribute13 <>
            p_old_line_rec.attribute13 OR
            p_old_line_rec.attribute13 IS NULL ))
    OR  (p_x_line_rec.attribute14 IS NOT NULL AND
        (   p_x_line_rec.attribute14 <>
            p_old_line_rec.attribute14 OR
            p_old_line_rec.attribute14 IS NULL ))
    OR  (p_x_line_rec.attribute15 IS NOT NULL AND
        (   p_x_line_rec.attribute15 <>
            p_old_line_rec.attribute15 OR
            p_old_line_rec.attribute15 IS NULL ))
    OR  (p_x_line_rec.attribute16 IS NOT NULL AND -- For bug 2184255
        (   p_x_line_rec.attribute16 <>
            p_old_line_rec.attribute16 OR
            p_old_line_rec.attribute16 IS NULL ))
    OR  (p_x_line_rec.attribute17 IS NOT NULL AND
        (   p_x_line_rec.attribute17 <>
            p_old_line_rec.attribute17 OR
            p_old_line_rec.attribute17 IS NULL ))
    OR  (p_x_line_rec.attribute18 IS NOT NULL AND
        (   p_x_line_rec.attribute18 <>
            p_old_line_rec.attribute18 OR
            p_old_line_rec.attribute18 IS NULL ))
    OR  (p_x_line_rec.attribute19 IS NOT NULL AND
        (   p_x_line_rec.attribute19 <>
            p_old_line_rec.attribute19 OR
            p_old_line_rec.attribute19 IS NULL ))
    OR  (p_x_line_rec.attribute2 IS NOT NULL AND
        (   p_x_line_rec.attribute2 <>
            p_old_line_rec.attribute2 OR
            p_old_line_rec.attribute2 IS NULL ))
    OR  (p_x_line_rec.attribute20 IS NOT NULL AND
        (   p_x_line_rec.attribute20 <>
            p_old_line_rec.attribute20 OR
            p_old_line_rec.attribute20 IS NULL ))
    OR  (p_x_line_rec.attribute3 IS NOT NULL AND
        (   p_x_line_rec.attribute3 <>
            p_old_line_rec.attribute3 OR
            p_old_line_rec.attribute3 IS NULL ))
    OR  (p_x_line_rec.attribute4 IS NOT NULL AND
        (   p_x_line_rec.attribute4 <>
            p_old_line_rec.attribute4 OR
            p_old_line_rec.attribute4 IS NULL ))
    OR  (p_x_line_rec.attribute5 IS NOT NULL AND
        (   p_x_line_rec.attribute5 <>
            p_old_line_rec.attribute5 OR
            p_old_line_rec.attribute5 IS NULL ))
    OR  (p_x_line_rec.attribute6 IS NOT NULL AND
        (   p_x_line_rec.attribute6 <>
            p_old_line_rec.attribute6 OR
            p_old_line_rec.attribute6 IS NULL ))
    OR  (p_x_line_rec.attribute7 IS NOT NULL AND
        (   p_x_line_rec.attribute7 <>
            p_old_line_rec.attribute7 OR
            p_old_line_rec.attribute7 IS NULL ))
    OR  (p_x_line_rec.attribute8 IS NOT NULL AND
        (   p_x_line_rec.attribute8 <>
            p_old_line_rec.attribute8 OR
            p_old_line_rec.attribute8 IS NULL ))
    OR  (p_x_line_rec.attribute9 IS NOT NULL AND
        (   p_x_line_rec.attribute9 <>
            p_old_line_rec.attribute9 OR
            p_old_line_rec.attribute9 IS NULL ))
    OR  (p_x_line_rec.context IS NOT NULL AND
        (   p_x_line_rec.context <>
            p_old_line_rec.context OR
            p_old_line_rec.context IS NULL )))
    THEN

       oe_debug_pub.add('Before calling line_desc_flex',2);
       IF Oe_Order_Cache.IS_FLEX_ENABLED('OE_BLKT_LINE_ATTRIBUTES') = 'Y'  THEN

	  IF NOT OE_VALIDATE.Line_Desc_Flex
	    (p_context            => p_x_line_rec.context
	     ,p_attribute1         => p_x_line_rec.attribute1
	     ,p_attribute2         => p_x_line_rec.attribute2
	     ,p_attribute3         => p_x_line_rec.attribute3
	     ,p_attribute4         => p_x_line_rec.attribute4
	     ,p_attribute5         => p_x_line_rec.attribute5
	     ,p_attribute6         => p_x_line_rec.attribute6
	     ,p_attribute7         => p_x_line_rec.attribute7
	     ,p_attribute8         => p_x_line_rec.attribute8
	     ,p_attribute9         => p_x_line_rec.attribute9
	     ,p_attribute10        => p_x_line_rec.attribute10
	     ,p_attribute11        => p_x_line_rec.attribute11
	     ,p_attribute12        => p_x_line_rec.attribute12
	     ,p_attribute13        => p_x_line_rec.attribute13
	     ,p_attribute14        => p_x_line_rec.attribute14
	     ,p_attribute15        => p_x_line_rec.attribute15
	     ,p_attribute16        => p_x_line_rec.attribute16  -- for bug 2184255
	     ,p_attribute17        => p_x_line_rec.attribute17
	     ,p_attribute18        => p_x_line_rec.attribute18
	     ,p_attribute19        => p_x_line_rec.attribute19
	     ,p_attribute20        => p_x_line_rec.attribute20
	     ,p_document_type      => 'BLANKET'              ) THEN	-- Bug # 5562785

	     IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
	       p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN

                p_x_line_rec.context    := null;
                p_x_line_rec.attribute1 := null;
                p_x_line_rec.attribute2 := null;
                p_x_line_rec.attribute3 := null;
                p_x_line_rec.attribute4 := null;
                p_x_line_rec.attribute5 := null;
                p_x_line_rec.attribute6 := null;
                p_x_line_rec.attribute7 := null;
                p_x_line_rec.attribute8 := null;
                p_x_line_rec.attribute9 := null;
                p_x_line_rec.attribute10 := null;
                p_x_line_rec.attribute11 := null;
                p_x_line_rec.attribute12 := null;
                p_x_line_rec.attribute13 := null;
                p_x_line_rec.attribute14 := null;
                p_x_line_rec.attribute15 := null;
                p_x_line_rec.attribute16 := null;  -- for bug 2184255
                p_x_line_rec.attribute17 := null;
                p_x_line_rec.attribute18 := null;
                p_x_line_rec.attribute19 := null;
                p_x_line_rec.attribute20 := null;

	   ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
	     p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN

                p_x_line_rec.context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute10 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute16 := FND_API.G_MISS_CHAR;  -- for bug 2184255
                p_x_line_rec.attribute17 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute18 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute19 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute20 := FND_API.G_MISS_CHAR;

	   ELSIF p_validation_level = FND_API.G_VALID_LEVEL_NONE THEN
  	        NULL;

          ELSE
	     x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

	ELSE -- if the flex validation is successfull
	    -- For bug 2511313
	    IF p_x_line_rec.context IS NULL
	      OR p_x_line_rec.context = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.context    := oe_validate.g_context;
	    END IF;

	    IF p_x_line_rec.attribute1 IS NULL
	      OR p_x_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute1 := oe_validate.g_attribute1;
	    END IF;

	    IF p_x_line_rec.attribute2 IS NULL
	      OR p_x_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute2 := oe_validate.g_attribute2;
	    END IF;

	    IF p_x_line_rec.attribute3 IS NULL
	      OR p_x_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute3 := oe_validate.g_attribute3;
	    END IF;

	    IF p_x_line_rec.attribute4 IS NULL
	      OR p_x_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute4 := oe_validate.g_attribute4;
	    END IF;

	    IF p_x_line_rec.attribute5 IS NULL
	      OR p_x_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute5 := oe_validate.g_attribute5;
	    END IF;

	    IF p_x_line_rec.attribute6 IS NULL
	      OR p_x_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute6 := oe_validate.g_attribute6;
	    END IF;

	    IF p_x_line_rec.attribute7 IS NULL
	      OR p_x_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute7 := oe_validate.g_attribute7;
	    END IF;

	    IF p_x_line_rec.attribute8 IS NULL
	      OR p_x_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute8 := oe_validate.g_attribute8;
	    END IF;

	    IF p_x_line_rec.attribute9 IS NULL
	      OR p_x_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute9 := oe_validate.g_attribute9;
	    END IF;

	    IF p_x_line_rec.attribute10 IS NULL
	      OR p_x_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute10 := Oe_validate.G_attribute10;
	    End IF;

	    IF p_x_line_rec.attribute11 IS NULL
	      OR p_x_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute11 := oe_validate.g_attribute11;
	    END IF;

	    IF p_x_line_rec.attribute12 IS NULL
	      OR p_x_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute12 := oe_validate.g_attribute12;
	    END IF;

	    IF p_x_line_rec.attribute13 IS NULL
	      OR p_x_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute13 := oe_validate.g_attribute13;
	    END IF;

	    IF p_x_line_rec.attribute14 IS NULL
	      OR p_x_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute14 := oe_validate.g_attribute14;
	    END IF;

	    IF p_x_line_rec.attribute15 IS NULL
	      OR p_x_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute15 := oe_validate.g_attribute15;
	    END IF;
	    IF p_x_line_rec.attribute16 IS NULL  -- for bug 2184255
	      OR p_x_line_rec.attribute16 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute16 := oe_validate.g_attribute16;
	    END IF;

	    IF p_x_line_rec.attribute17 IS NULL
	      OR p_x_line_rec.attribute17 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute17 := oe_validate.g_attribute17;
	    END IF;

	    IF p_x_line_rec.attribute18 IS NULL
	      OR p_x_line_rec.attribute18 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute18 := oe_validate.g_attribute18;
	    END IF;

	    IF p_x_line_rec.attribute19 IS NULL
	      OR p_x_line_rec.attribute19 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute19 := oe_validate.g_attribute19;
	    END IF;

	    IF p_x_line_rec.attribute20 IS NULL  -- for bug 2184255
	      OR p_x_line_rec.attribute20 = FND_API.G_MISS_CHAR THEN
	       p_x_line_rec.attribute20 := oe_validate.g_attribute20;
	    END IF;

	    -- end of assignments, bug 2511313
         END IF; -- Flex Validation successfull
	END IF; -- Is flex enabled

         oe_debug_pub.add('After line_desc_flex  ' || x_return_status,2);

    END IF;  -- For Additional Line Information

  END IF; -- 5562785

    if l_debug_level > 0 then
        oe_debug_pub.add('Exiting procedure OE_BLANKET_UTIL.Validate Line Attributes',1);
    end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate Attributes'
            );
        END IF;

END Validate_Attributes;

FUNCTION Validate_Item_Fields(
 p_item_identifier_type IN VARCHAR2,
 p_inventory_item_id IN NUMBER,
 p_sold_to_org_id IN NUMBER,
 p_ordered_item_id IN NUMBER,
 p_ordered_item IN VARCHAR2
)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(240);

--code taken from OE_validate_line.validate_item_fields
/* added for 2219230 */
l_org_flag   NUMBER := 2;
item_val_org NUMBER := to_number(OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));

CURSOR xref IS
        SELECT DECODE(items.org_independent_flag, 'Y', 1,
                 DECODE(items.organization_id, item_val_org, 1, 2))
        FROM  mtl_cross_reference_types types
            , mtl_cross_references items
            , mtl_system_items_vl sitems
        WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.organization_id = item_val_org
           AND sitems.inventory_item_id = p_inventory_item_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
	   ORDER BY 1;
/* end of code added for 2219230 */

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if l_debug_level > 0 then
     oe_debug_pub.add('In validate Item Fields', 1);

     oe_debug_pub.add('item identifier type :'||p_item_identifier_type);
     oe_debug_pub.add('inventory item id :'||p_inventory_item_id);
     oe_debug_pub.add('ordered item id :'||p_ordered_item_id);
     oe_debug_pub.add('ordered item :'||p_ordered_item);
     oe_debug_pub.add('sold to org id :'||p_sold_to_org_id);
    end if;
     --perform validation of inventory_item_id based on context
      IF p_item_identifier_type = 'INT' THEN --validate inventory_item_id
       if l_debug_level > 0 then
	  oe_debug_pub.add('Blanket In validate INT');
       end if;
      	   	SELECT 'valid'
      	   	INTO  l_dummy
      	   	FROM  mtl_system_items_b
      	  	WHERE inventory_item_id = p_inventory_item_id
      	   	AND organization_id = OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
                AND customer_order_enabled_flag = 'Y';

      ELSIF p_item_identifier_type = 'CUST' THEN
       if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate CUST',1);
       end if;
	      	SELECT 'valid'
      		INTO  l_dummy
      		FROM   mtl_customer_items citems
        	        ,mtl_customer_item_xrefs cxref
        	    	,mtl_system_items_vl sitems
      		WHERE citems.customer_item_id = cxref.customer_item_id
        		AND cxref.inventory_item_id = sitems.inventory_item_id
        		AND sitems.inventory_item_id = p_inventory_item_id
        		AND sitems.organization_id =
		   	OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
        		AND citems.customer_item_id = p_ordered_item_id
        		AND citems.customer_id = p_sold_to_org_id
         		AND citems.inactive_flag = 'N'
        		AND cxref.inactive_flag = 'N';

      ELSIF  p_item_identifier_type = 'CAT' THEN
       if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate CAT');
       end if;
             SELECT  'VALID'
            INTO    l_dummy
            FROM    MTL_CATEGORIES_VL
            WHERE   CATEGORY_ID = p_inventory_item_id
            AND     ENABLED_FLAG = 'Y';

      ELSE
       if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate generic');
       end if;
        	--code taken from OE_validate_line.validate_item_fields
        	/* SELECT replaced for with the following for 2219230 */
              if l_debug_level > 0 then
        	oe_debug_pub.add('Validating generic item, item_val_org:'||to_char(item_val_org),5);
              end if;
        	OPEN xref;
        	FETCH xref INTO l_org_flag;
        	IF xref%NOTFOUND OR l_org_flag <> 1 THEN
                 if l_debug_level > 0 then
        	  oe_debug_pub.add('Blanket Invalid Generic Item', 1);
                 end if;
        	  CLOSE xref;
        	END IF;
        	CLOSE xref;

      END IF;

      RETURN TRUE;

    EXCEPTION
	   WHEN NO_DATA_FOUND THEN
            if l_debug_level > 0 then
             oe_debug_pub.add('Validate Item based on context: No data found',1);
            end if;
	     RETURN FALSE;
           WHEN OTHERS THEN
            if l_debug_level > 0 then
             oe_debug_pub.add('Validate_Item_Fields: When Others',1);
            end if;
	     RETURN FALSE;
END Validate_Item_Fields;

--PP Revenue Recognition
--bug 4893057
FUNCTION Validate_Accounting_Rule(
p_inventory_item_id IN NUMBER,
p_accounting_rule_id IN NUMBER
)
RETURN BOOLEAN
IS
l_rule_type VARCHAR2(10);
l_item_org NUMBER := to_number(OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_service_item_flag VARCHAR2(1);
l_bom_item_type NUMBER;
l_dummy VARCHAR2(25);

BEGIN
    if l_debug_level > 0 then
	     oe_debug_pub.add('In validate accounting rule', 1);
	     oe_debug_pub.add('inventory item id :'||p_inventory_item_id);
	     oe_debug_pub.add('l_item_org :'||l_item_org);
    end if;
    --Bug 5169363
    --bug5220335 moved the query under BEGIN-EXCEPTION-END
    BEGIN
       SELECT  'VALID'
       INTO    l_dummy
       FROM    MTL_CATEGORIES_VL
       WHERE   CATEGORY_ID = p_inventory_item_id
       AND     ENABLED_FLAG = 'Y';
    EXCEPTION
       WHEN OTHERS THEN
	  l_dummy := null;
    END;

    IF OE_GLOBALS.Equal(l_dummy,'VALID') THEN
	RETURN TRUE;
    ELSE
	    IF p_inventory_item_id IS NOT NULL THEN
		select service_item_flag,bom_item_type
		into l_service_item_flag, l_bom_item_type
		from MTL_SYSTEM_ITEMS
		where inventory_item_id = p_inventory_item_id
		AND    organization_id =  l_item_org;
	    END IF;

	    IF NOT (l_bom_item_type = 4 and l_service_item_flag = 'Y') THEN -- not service
		IF p_accounting_rule_id <> FND_API.G_MISS_NUM AND
		     p_accounting_rule_id IS NOT NULL THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Getting accounting rule type');
			END IF;
			SELECT type
			INTO l_rule_type
			FROM ra_rules
			WHERE rule_id = p_accounting_rule_id;
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Rule Type is :'||l_rule_type);
			END IF;
			IF l_rule_type = 'PP_DR_ALL' or l_rule_type = 'PP_DR_PP' THEN
			     RETURN FALSE;
			END IF; --End of rule type
		END IF;--End of accounting type id is not null
	      END IF; --End of item type not Service

	      RETURN TRUE;
    END IF;
    --Bug 5169363

EXCEPTION
   WHEN OTHERS THEN
	    if l_debug_level > 0 then
		oe_debug_pub.add('Validate_Accounting Rule: When Others',1);
		oe_debug_pub.add('Error message...'||sqlerrm);
	    end if;
    RETURN FALSE;
END Validate_Accounting_Rule;
--bug 4893057


PROCEDURE Validate_Entity
( p_line_rec           IN OUT NOCOPY  OE_Blanket_PUB.line_rec_type
, p_old_line_rec       IN OE_Blanket_PUB.Line_rec_type := OE_Blanket_PUB.G_MISS_BLANKET_LINE_REC
, x_return_status      OUT NOCOPY VARCHAR2
)IS

l_dummy varchar2(30);
l_valid_line_number varchar2(1);
l_old_line_rec OE_Blanket_PUB.Line_rec_type  := p_old_line_rec;
l_site_use_code   VARCHAR2(30);
l_return_status varchar2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_list_line_exists            VARCHAR2(1) := 'N';
l_temp varchar2(100);
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;



    if l_debug_level > 0 then
       oe_debug_pub.add('Enter OE_BLANKET_UTIL.Validate ENTITY - Line',1);
       oe_debug_pub.add('Operation : '||p_line_rec.operation);
       oe_debug_pub.add('Price List ID : '||p_line_rec.price_list_id);
       oe_debug_pub.add('Unit List Price : '||p_line_rec.unit_list_price);
       oe_debug_pub.add('Line end date : '||p_line_rec.end_date_active);
       oe_debug_pub.add('Header end date : '||g_header_rec.end_date_active);
    end if;

    -- Load old line rec if not passed
    IF p_line_rec.operation = oe_globals.g_opr_update THEN
       IF l_old_line_rec.line_id is null THEN
   	  l_old_line_rec := Query_Row(p_line_id => p_line_rec.line_id);
       END IF;
    END IF;

  -- Validate Last Updated By values.
    -- Added for bug #6270818.
    IF p_line_rec.operation = oe_globals.g_opr_update
    THEN
       If p_line_rec.last_updated_by <> FND_GLOBAL.USER_ID or
           l_old_line_rec.last_updated_by <> FND_GLOBAL.USER_ID
       THEN
          p_line_rec.last_updated_by := FND_GLOBAL.USER_ID;
          l_old_line_rec.last_updated_by := FND_GLOBAL.USER_ID;
      END IF;
          p_line_rec.last_update_date := sysdate;
          l_old_line_rec.last_update_date := sysdate;
     END IF;


    -- Load header
    Load_Header(p_header_id => p_line_rec.header_id,
                x_return_status => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
    END IF;

    -- Versioning/Reasons changes (moved to beginning for bug 3775937
    if OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
       OE_GLOBALS.G_CAPTURED_REASON = 'V' THEN
        OE_GLOBALS.G_REASON_CODE := p_line_rec.revision_change_reason_code;
        OE_GLOBALS.G_REASON_COMMENTS := p_line_rec.revision_change_comments;
        OE_GLOBALS.G_CAPTURED_REASON := 'Y';
    end if;

   -- added for bug 3443777 need to call validate entity for reasons capture
   IF (p_line_rec.operation <> OE_GLOBALS.g_opr_delete)
    and  not  OE_BLANKET_UTIL.is_end_date_operation(p_line_rec, l_old_line_rec)    -- Added for bug 9027699

   THEN

 /*   IF p_line_rec.operation = oe_globals.g_opr_update AND p_line_rec.end_date_active = trunc(sysdate) AND
   NOT OE_GLOBALS.Equal(p_line_rec.end_date_active, p_old_line_rec.end_date_active) THEN

     null;

else*/
    -----------------------------------------------------------
    --  Check required attributes.
    -----------------------------------------------------------

     if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate entity 1');
        oe_debug_pub.add('1 '||x_return_status, 1);
     end if;

    IF  p_line_rec.line_id IS NULL
    THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('line_id'));
        OE_MSG_PUB.Add;

    END IF;

    IF p_line_rec.item_identifier_type IS NULL
    THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
             OE_Order_UTIL.Get_Attribute_Name('ITEM_IDENTIFIER_TYPE'));
        OE_MSG_PUB.Add;

    ELSIF p_line_rec.item_identifier_type <> 'ALL'
        AND p_line_rec.inventory_item_id IS NULL
    THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
             OE_Order_UTIL.Get_Attribute_Name('INVENTORY_ITEM_ID'));
        OE_MSG_PUB.Add;

    END IF;

    IF  p_line_rec.start_date_active IS NULL
    THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Activation Date');
        OE_MSG_PUB.Add;

    END IF;

    --  Return Error if a required attribute is missing.

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate entity 2');
    end if;

    -- Customer Item Validation
    IF (p_line_rec.operation = oe_globals.g_opr_update or p_line_rec.operation = oe_globals.g_opr_create) AND
        p_line_rec.ITEM_IDENTIFIER_TYPE = 'CUST' then
       oe_blanket_util.Get_Inventory_Item(p_x_line_rec => p_line_rec,
                                       x_return_status => l_return_status);
    END if;
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       oe_debug_pub.add('Raise and Error in Customer ITem Validation oe_blanket_util.Get_Inventory_Item');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --PP Revenue Recognition
    --bug 4893057
    IF NOT Validate_Accounting_Rule
	(p_line_rec.inventory_item_id,
	p_line_rec.accounting_rule_id)
    THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.Set_Name('ONT','OE_INVALID_ATTRIBUTE');
	FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_Util.Get_Attribute_Name('ACCOUNTING_RULE_ID'));
	OE_MSG_PUB.ADD;
    END IF;


    ---------------------------------------------------------------------
    --  Validate attribute dependencies here.
    ---------------------------------------------------------------------

    -- Log request to validate line number if line number changed

    IF NOT OE_GLOBALS.Equal
       (p_line_rec.line_number,l_old_line_rec.line_number)
    THEN
       --some fields not allowed to update if release exists against line
       IF (p_line_rec.released_amount > 0) THEN
	   fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_LINE_ATTRIBUTE');
           fnd_message.set_token('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('LINE_NUMBER'));
           OE_MSG_PUB.Add;
       ELSE
           oe_delayed_requests_pvt.Log_request(p_Entity_Code =>
		 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
		    p_Entity_Id => p_line_rec.line_id,
	            p_requesting_entity_code    =>
		 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
		p_requesting_entity_id      => p_line_rec.line_id,
		    p_request_type => 'VALIDATE_BLANKET_LINE_NUMBER',
		    p_param1    => p_line_rec.header_id,
		    p_param2   => p_line_rec.line_number,
		    x_return_status => l_return_status);
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
       END IF;
    END IF;


    -- Inventory Item Validations

    IF NOT OE_GLOBALS.Equal
        (p_line_rec.item_identifier_type,l_old_line_rec.item_identifier_type)
       OR NOT OE_GLOBALS.Equal
        (p_line_rec.inventory_item_id,l_old_line_rec.inventory_item_id)
       OR NOT OE_GLOBALS.Equal
        (p_line_rec.end_date_active,l_old_line_rec.end_date_active)
       OR NOT OE_GLOBALS.Equal
        (p_line_rec.start_date_active,l_old_line_rec.start_date_active)
    THEN
      --fields not allowed to update if releases exist against this line
     IF (p_line_rec.released_amount > 0) AND
       (NOT OE_GLOBALS.Equal
        (p_line_rec.inventory_item_id,l_old_line_rec.inventory_item_id)) THEN

            fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_LINE_ATTRIBUTE');
            fnd_message.set_token('ATTRIBUTE',
               OE_Order_UTIL.Get_Attribute_Name('INVENTORY_ITEM_ID'));
            OE_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;

     ELSIF (p_line_rec.released_amount > 0) AND
      (NOT OE_GLOBALS.Equal
       (p_line_rec.item_identifier_type,l_old_line_rec.item_identifier_type)) THEN
            fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_LINE_ATTRIBUTE');
            fnd_message.set_token('ATTRIBUTE',
               OE_Order_UTIL.Get_Attribute_Name('ITEM_IDENTIFIER_TYPE'));
            OE_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;

     ELSE

      -- Inventory Item ID should be null for 'ALL Item' Context
      IF p_line_rec.item_identifier_type = 'ALL' THEN

        IF p_line_rec.inventory_item_id IS NOT NULL THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT', 'OE_ITEM_VALIDATION_FAILED');
            OE_MSG_PUB.add;
        END IF;

      -- For all other context values, validate item id
      ELSE

	IF NOT Validate_Item_Fields
			( p_line_rec.item_identifier_type,
			p_line_rec.inventory_item_id,
                        p_line_rec.sold_to_org_id,
			p_line_rec.ordered_item_id,
			p_line_rec.ordered_item
			) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT', 'OE_ITEM_VALIDATION_FAILED');
            OE_MSG_PUB.add;
        END IF;

      END IF;

      if l_debug_level > 0 then
	oe_debug_pub.add('before logging request for item uniqueness');
      end if;

      --validate item uniqueness
      OE_Delayed_Requests_Pvt.Log_Request(p_Entity_Code =>
	         OE_BLANKET_pub.G_ENTITY_BLANKET_LINE ,
               p_Entity_Id => p_line_rec.line_id,
               p_requesting_entity_code    =>
                 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
               p_requesting_entity_id      => p_line_rec.line_id,
               p_request_type => 'VALIDATE_BLANKET_INV_ITEM',
               p_param1    => p_line_rec.inventory_item_id,
               p_param2    => p_line_rec.header_id,
               p_param3    => p_line_rec.item_identifier_type,
	       p_param4    => p_line_rec.ordered_item_id, --bug6826787
	       p_param5    => p_line_rec.ordered_item,    --bug6826787
               p_date_param1    => p_line_rec.start_date_active,
               p_date_param2    => p_line_rec.end_date_active,
               x_return_status => l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



     END IF; --if released amount

    END IF; --if item changing


    -- Validate Ship to

    IF p_line_rec.ship_to_org_id IS NOT NULL AND
             ( NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id ,l_old_line_rec.ship_to_org_id) OR
               NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id ,l_old_line_rec.sold_to_org_id)) THEN
             -- ER 5743580
              IF ( NOT Validate_Ship_To_Org(p_line_rec.ship_to_org_id,
                                            p_line_rec.sold_to_org_id )) THEN
                  if l_debug_level > 0 then
                   oe_debug_pub.add ('Blanket In: No data found',2);
                  end if;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE'
                      , OE_Order_Util.Get_Attribute_Name('ship_to_org_id'));
                   OE_MSG_PUB.Add;
               END IF;
    END IF; -- Ship to

    --  Deliver to Org id depends on sold to org.
       if l_debug_level > 0 then
             oe_debug_pub.add('Validating deliver_to_org_id :'|| to_char(p_line_rec.deliver_to_org_id),2);
             oe_debug_pub.add(' Customer Relations :'|| g_customer_relations, 1);
       end if;
    IF p_line_rec.deliver_to_org_id IS NOT NULL AND
         ( NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_org_id,l_old_line_rec.deliver_to_org_id) OR
           NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id ,l_old_line_rec.sold_to_org_id)) THEN
                -- ER 5743580
             IF NOT (Validate_Deliver_To_Org(p_line_rec.deliver_to_org_id,
                                            p_line_rec.sold_to_org_id )) THEN

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                  OE_Order_Util.Get_Attribute_Name('deliver_to_org_id'));
                  OE_MSG_PUB.Add;
              END IF;

    END IF; -- Deliver to

    --  Invoice to Org id depends on sold to org.

    IF p_line_rec.invoice_to_org_id IS NOT NULL AND
          ( NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id ,l_old_line_rec.invoice_to_org_id) OR
            NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id ,l_old_line_rec.sold_to_org_id)) THEN
                -- ER 5743580
                IF NOT ( Validate_Invoice_To_Org ( p_line_rec.invoice_to_org_id,
                                                   p_line_rec.sold_to_org_id )) THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                  OE_Order_Util.Get_Attribute_Name('invoice_to_org_id'));
                  OE_MSG_PUB.Add;
                END IF;
    END IF; -- Invoice to org

    if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate entity 3');
    end if;


  -- Date Validations
  --Changes made for Bug No 5528599 start
  if (p_line_rec.end_date_active is not NULL and
       (p_line_rec.start_date_active)
	  > (p_line_rec.end_date_active)) THEN
             if ( nvl(p_line_rec.source_document_type_id,0) = 2 --bug#5528507
               AND p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE)
             then
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
	      OE_MSG_PUB.ADD;
              oe_debug_pub.add('1: Not Setting Error',1);

            else
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
              OE_MSG_PUB.ADD;
              oe_debug_pub.add('1: Setting Error',1);
              x_return_status := FND_API.G_RET_STS_ERROR;
           end if;
  --Changes made for Bug No 5528599
  end if;

  --line start date must be after header date range
  if (p_line_rec.start_date_active < g_header_rec.start_date_active)
  then
        FND_MESSAGE.SET_NAME('ONT','OE_BLKT_END_DATE_CONFLICT');
	OE_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

  -- if header end date exists, line end date cannot be null
  -- and it cannot be greater than header end date
  if g_header_rec.end_date_active is not NULL then
   if p_line_rec.end_date_active is NULL
      or (p_line_rec.end_date_active
            > g_header_rec.end_date_active)
   then
        FND_MESSAGE.SET_NAME('ONT','OE_BLKT_END_DATE_CONFLICT');
	OE_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
   end if;
  end if;

  if l_debug_level > 0 then
     oe_debug_pub.add('Blanket In validate entity 4, status :'||
                                      x_return_status);
  end if;

  -- pricing uom is required if it is a blanket price list
  -- and ordered UOM is null
  IF p_line_rec.order_quantity_uom IS NULL THEN
    IF (g_new_price_list AND (p_line_rec.pricing_uom IS NULL)) THEN
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
            OE_Order_Util.Get_Attribute_Name('PRICING_QUANTITY_UOM'));
        OE_MSG_PUB.Add;
    ELSIF p_line_rec.price_list_id IS NOT NULL THEN
      IF IS_BLANKET_PRICE_LIST(p_price_list_id => p_line_rec.price_list_id)
      AND p_line_rec.pricing_uom IS NULL THEN
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
            OE_Order_Util.Get_Attribute_Name('PRICING_QUANTITY_UOM'));
        OE_MSG_PUB.Add;
      END IF;
    END IF;
  END IF;

IF NOT g_new_price_list AND
   p_line_rec.price_list_id IS NULL AND
   (p_line_rec.enforce_price_list_flag = 'Y') THEN
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('PRICE_LIST_ID'));
	  OE_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;
END IF;

-- UOM is required if any of the quantities are given on the blanket line
IF     p_line_rec.order_quantity_uom IS NULL AND
      (p_line_rec.Blanket_Min_Quantity IS NOT NULL
    OR p_line_rec.Blanket_Max_Quantity IS NOT NULL
    OR p_line_rec.Min_Release_Quantity IS NOT NULL
    OR p_line_rec.Max_Release_Quantity IS NOT NULL) THEN
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_QUANTITY_UOM');
	  OE_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;

END IF;

-- Bug 8770382 Start

	If (p_line_rec.blanket_max_quantity < p_line_rec.released_quantity)
	and ((l_old_line_rec.blanket_max_quantity >= l_old_line_rec.released_quantity)
	      or (Nvl(l_old_line_rec.blanket_max_quantity,0) = 0))
	and (p_line_rec.override_blanket_controls_flag = 'N') then

      		fnd_message.set_name('ONT','OE_BSA_REL_QUANTITY');
     		FND_MESSAGE.SET_TOKEN('VALUE',l_old_line_rec.released_quantity);
      		OE_MSG_PUB.ADD;
      		x_return_status := FND_API.G_RET_STS_ERROR;

 	elsif  (p_line_rec.blanket_max_amount < p_line_rec.released_amount)
    	and ((l_old_line_rec.blanket_max_amount >= l_old_line_rec.released_amount)
              or (nvl(l_old_line_rec.blanket_max_amount,0) = 0))
    	and (p_line_rec.override_blanket_controls_flag = 'N') then

       		fnd_message.set_name('ONT','OE_BSA_REL_AMOUNT');
       		FND_MESSAGE.SET_TOKEN('VALUE',l_old_line_rec.released_amount);
       		OE_MSG_PUB.ADD;
       		x_return_status := FND_API.G_RET_STS_ERROR;


 	end if;

 -- Bug 8770382 End



-- Validate min/max limits
  Validate_Min_Max_Range(p_line_rec.Blanket_Min_Quantity,
       p_line_rec.blanket_max_quantity,
       'BLANKET_LINE_QUANTITY', x_return_status);
  Validate_Min_Max_Range(p_line_rec.Min_release_quantity,
       p_line_rec.Max_release_quantity,
       'BLANKET_LINE_RELEASE_QUANTITY', x_return_status);
  Validate_Min_Max_Range(p_line_rec.Min_release_amount,
       p_line_rec.Max_release_amount,
       'BLANKET_LINE_RELEASE_AMOUNT', x_return_status);
  Validate_Min_Max_Range(p_line_rec.blanket_min_amount,
       p_line_rec.blanket_max_amount,
       'BLANKET_LINE_AMOUNT', x_return_status);
/*
    IF p_line_rec.blanket_max_amount > g_header_rec.blanket_max_amount THEN
         FND_MESSAGE.SET_NAME('ONT','OE_BLKT_LINE_MIN_MAX_VALUES');
         OE_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
*/
    IF p_line_rec.min_release_amount > p_line_rec.blanket_max_amount OR
       p_line_rec.max_release_amount > p_line_rec.blanket_max_amount THEN
         FND_MESSAGE.SET_NAME('ONT','OE_BLKT_LINE_MAX_AMOUNT');
         OE_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    IF p_line_rec.min_release_quantity > p_line_rec.blanket_max_quantity OR
       p_line_rec.max_release_quantity > p_line_rec.blanket_max_quantity THEN
         FND_MESSAGE.SET_NAME('ONT','OE_BLKT_LINE_MAX_QUANTITY');
         OE_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

   IF p_line_rec.operation = oe_globals.g_opr_update THEN

    if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate entity 4: update');
    end if;

      --not allowed to change any attributes on a previously closed blanket
    IF p_line_rec.end_date_active < trunc(sysdate) and
       l_old_line_rec.end_date_active < trunc(sysdate) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_ATTR_CLOSED');
                 OE_MSG_PUB.Add;
    END IF;
    --Srini
    --oe_blanket_util.Get_Inventory_Item(p_x_line_rec => p_line_rec,
    --                                   x_return_status => l_return_status);
    --End srini
      --display warning if we haven't fulfilled minimum requirements


    IF NOT OE_GLOBALS.Equal(p_line_rec.end_date_active, l_old_line_rec.end_date_active) AND
       p_line_rec.end_date_active <= trunc(sysdate) AND
       p_line_rec.override_blanket_controls_flag = 'N' THEN
          IF nvl(p_line_rec.released_amount,0) < p_line_rec.blanket_min_amount THEN
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_CLOSE_MIN_VALUES');
              OE_MSG_PUB.ADD;
              if l_debug_level > 0 then
               oe_debug_pub.add('Blanket line close min amount ');
              end if;

          ELSIF nvl(p_line_rec.released_quantity,0) < p_line_rec.blanket_min_quantity THEN
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_CLOSE_MIN_VALUES');
              OE_MSG_PUB.ADD;
              if l_debug_level > 0 then
                 oe_debug_pub.add('Blanket line close min quantity ');
              end if;
          END IF;
    END IF;

       --some fields are not allowed to update if release exists against line
       IF (p_line_rec.released_amount > 0) THEN
	         IF NOT OE_GLOBALS.Equal (p_line_rec.order_quantity_uom,
	               l_old_line_rec.order_quantity_uom) THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
	                fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_LINE_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE',
                                   OE_Order_UTIL.Get_Attribute_Name('ORDER_QUANTITY_UOM'));
			OE_MSG_PUB.Add;
                 END IF;
       END IF;

         /*     IF NOT OE_GLOBALS.EQUAL (p_line_rec.end_date_active, l_old_line_rec.end_date_active) THEN
                --validate item uniqueness
		OE_Delayed_Requests_Pvt.Log_Request(p_Entity_Code =>
			OE_BLANKET_pub.G_ENTITY_BLANKET_LINE ,
		    p_Entity_Id => p_line_rec.line_id,
                    p_requesting_entity_code    =>
                 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
                p_requesting_entity_id      => p_line_rec.line_id,
		   p_request_type => 'VALIDATE_BLANKET_INV_ITEM',
		    p_param1    => p_line_rec.inventory_item_id,
		    p_param2    => p_line_rec.header_id,
		    p_param3    => p_line_rec.item_identifier_type,
		    p_param4    => p_line_rec.ordered_item_id, --bug6826787
		    p_param5    => p_line_rec.ordered_item,    --bug6826787
		    p_date_param1    => p_line_rec.start_date_active,
		    p_date_param2    => p_line_rec.end_date_active,
		    x_return_status => l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

              END IF;*/

               IF p_line_rec.end_date_active IS NOT NULL THEN
                    BEGIN
                       SELECT 'ERROR'
                         INTO l_dummy
                         FROM OE_ORDER_LINES
                        WHERE trunc(request_date) > trunc(p_line_rec.end_date_active)
                        AND BLANKET_NUMBER = p_line_rec.order_number
                        AND BLANKET_LINE_NUMBER = p_line_rec.line_number
                        AND ROWNUM = 1;

                        IF l_dummy = 'ERROR' THEN
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                fnd_message.set_name('ONT', 'OE_BLKT_LINE_RELEASE_END_DATE');
                                OE_MSG_PUB.Add;
                        END IF;

                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             NULL;  --no rows with conflicting end dates
                    END;
               END IF;

/*
       -- Bug 2792852 => pricing uom is not stored on the blanket line, it
       -- is derived from the list_line_id in the forms post-query.
       -- So it will always be null on the old rec thus this check will
       -- always post error even if user was updating some other field
       -- on the blanket line.
       -- Therefore commenting out NOCOPY {file.sql.39 change}  the check, logging of price list
       -- line creation is anyway restricted to line CREATE operation.
       oe_debug_pub.add('old pricing uom :'||l_old_line_rec.pricing_uom);
       oe_debug_pub.add('new pricing uom :'||p_line_rec.pricing_uom);
       --pricing uom not allowed to change if blanket price list
       if NOT OE_GLOBALS.EQUAL(p_line_rec.pricing_uom,
                           l_old_line_rec.pricing_uom) THEN
          if (g_new_price_list) THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UPDATE_LINE_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_UTIL.Get_Attribute_Name('PRICING_QUANTITY_UOM'));
	     OE_MSG_PUB.ADD;
	     x_return_status := FND_API.G_RET_STS_ERROR;
          elsif p_line_rec.price_list_id IS NOT NULL THEN
           if IS_BLANKET_PRICE_LIST(p_price_list_id => p_line_rec.price_list_id) THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UPDATE_LINE_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_UTIL.Get_Attribute_Name('PRICING_QUANTITY_UOM'));
	     OE_MSG_PUB.ADD;
    	     x_return_status := FND_API.G_RET_STS_ERROR;
           end if;
          end if;
       end if;
*/

      if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate entity update 1');
      end if;
       if NOT OE_GLOBALS.EQUAL(p_line_rec.released_amount,
                           l_old_line_rec.released_amount) THEN
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UPDATE_LINE_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Released Amount');
	  OE_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;
       end if;

       if NOT OE_GLOBALS.EQUAL(p_line_rec.returned_amount,
                           l_old_line_rec.returned_amount) THEN
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UPDATE_LINE_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Returned Amount');
	  OE_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;
       end if;

       if NOT OE_GLOBALS.EQUAL(p_line_rec.released_quantity,
                           Round(l_old_line_rec.released_quantity, 6)) THEN --round() added for bug 9587613
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UPDATE_LINE_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Released Quantity');
	  OE_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;
       end if;

       if NOT OE_GLOBALS.EQUAL(p_line_rec.fulfilled_quantity,
                           Round(l_old_line_rec.fulfilled_quantity, 6)) THEN --round() added for bug 9587613
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UPDATE_LINE_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Fulfilled Quantity');
	  OE_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;
       end if;

       if NOT OE_GLOBALS.EQUAL(p_line_rec.fulfilled_amount,
                           l_old_line_rec.fulfilled_amount) THEN
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UPDATE_LINE_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Fulfilled Amount');
	  OE_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;
       end if;

       if NOT OE_GLOBALS.EQUAL(p_line_rec.returned_quantity,
                           Round(l_old_line_rec.returned_quantity, 6)) THEN --round() added for bug 9587613
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UPDATE_LINE_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Returned Quantity');
	  OE_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;
       end if;
       if l_debug_level > 0 then
	oe_debug_pub.add('Blanket In validate entity update 2');
       end if;

    END IF; --if g_opr_update


    ---------------------------------------------------------------------
    -- Bug 3193220
    -- Expiration Date cannot be less than sysdate
    ---------------------------------------------------------------------
--Changes made for Bug No 5528599
    if (NOT OE_GLOBALS.EQUAL(trunc(p_line_rec.end_date_active),
                           trunc(l_old_line_rec.end_date_active))
       AND trunc(p_line_rec.end_date_active) < trunc(sysdate))
       THEN
             oe_debug_pub.add('2:source_document_type_id :'|| p_line_rec.source_document_type_id,1);
             oe_debug_pub.add('2:source_document_line_id :'|| p_line_rec.source_document_line_id,1);

             if ( nvl(p_line_rec.source_document_type_id,0) = 2 --bug#5528507
               AND p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE)
             then
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
              OE_MSG_PUB.ADD;
              oe_debug_pub.add('2: Not Setting Error',1);

            else
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
              OE_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              oe_debug_pub.add('2:  Setting Error',1);
           end if;
    end if;
--Changes made for Bug No 5528599
    -- End Expiration Date < sysdate check



    -- Bug 2792852
    -- Price list lines can only be created for new blanket lines.
    -- Comment out NOCOPY /* file.sql.39 change */ this if check
    -- 11i10 - also support creation of new price list lines when
    -- blanket line is updated with list price information i.e. list
    -- price was originally null on the line.
    -- Note that it's not supported if list price existed before
    -- and user tries to update list price itself.
    --IF p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

      --only add line information if new price list
    -- This if is for the scenario where price list is also being
    -- created i.e. blanket header with new price list is being
    -- created.
    IF (g_new_price_list AND p_line_rec.price_list_id IS NULL)
    THEN

      if l_debug_level > 0 then
         oe_debug_pub.add('log CREATE_BLANKET_PRICE_LIST');
      end if;

     --for bug 3229225.Commented out NOCOPY /* file.sql.39 change */ the If condition and added modified condition
     --     IF p_line_rec.unit_list_price IS NOT NULL
     IF NOT OE_GLOBALS.EQUAL(p_line_rec.unit_list_price,p_old_line_rec.unit_list_price)
     THEN
         oe_delayed_requests_pvt.Log_request(p_Entity_Code =>
                OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
		p_Entity_Id => p_line_rec.line_id,
                p_requesting_entity_code    =>
                 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
                p_requesting_entity_id  => p_line_rec.line_id,
		p_request_type => 'CREATE_BLANKET_PRICE_LIST',
		p_param1=> p_line_rec.unit_list_price,
		p_param2 => nvl(p_line_rec.pricing_uom,
		p_line_rec.order_quantity_uom),
		p_param3 => p_line_rec.inventory_item_id,
		p_param4 => p_line_rec.item_identifier_type,
                -- 11i10 Pricing Changes
                -- Add header_id, sold_to_org and ordered_item parameters
                p_param6 => p_line_rec.header_id,
                p_param7 => p_line_rec.sold_to_org_id,
                p_param8 => p_line_rec.ordered_item_id,
		x_return_status => l_return_status );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

    -- This if is for the scenario where either new blanket lines
    -- with price information are being added OR existing blanket
    -- lines with null price are being updated with list price.
    -- 11i10 Pricing Changes
    ELSIF IS_BLANKET_PRICE_LIST(p_price_list_id => p_line_rec.price_list_id
                                ,p_blanket_header_id => p_line_rec.header_id)
          OR (p_line_rec.price_list_id IS NULL
              AND g_header_rec.new_price_list_id IS NOT NULL)
    THEN
      -- Only for release before 11i10 check if header and line price list
      -- are same.
      IF (OE_Code_Control.Get_Code_Release_Level < '110510'
          AND OE_GLOBALS.Equal(p_line_rec.price_list_id, g_header_rec.price_list_id))
         OR OE_Code_Control.Get_Code_Release_Level >= '110510'
      THEN

      if l_debug_level > 0 then
         oe_debug_pub.add('qp list line id :'||p_line_rec.qp_list_line_id);
      end if;


      --for bug 3229225.Commented out NOCOPY /* file.sql.39 change */ the If condition and added modified condition
      --      IF p_line_rec.unit_list_price IS NOT NULL
      --       AND p_line_rec.qp_list_line_id IS NULL THEN

      IF (NOT OE_GLOBALS.EQUAL(p_line_rec.unit_list_price,p_old_line_rec.unit_list_price))
           OR (p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
                     p_line_rec.unit_list_price IS NOT NULL) --Bug#4694968
      THEN

        -- Bug 3380740
        -- Log the add price list line if price changes and list
        -- line does not exist
        if p_line_rec.qp_list_line_id IS NOT NULL then

            BEGIN

            SELECT 'Y'
             INTO l_list_line_exists
             FROM QP_LIST_LINES
            WHERE LIST_LINE_ID = p_line_rec.qp_list_line_id;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_list_line_exists := 'N';
            END;

        end if;

        if l_list_line_exists = 'N' THEN

        if l_debug_level > 0 then
         oe_debug_pub.add('log ADD_BLANKET_PRICE_LIST_LINE');
        end if;

	oe_delayed_requests_pvt.Log_request(p_Entity_Code =>
				 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
		p_Entity_Id => p_line_rec.line_id,
                p_requesting_entity_code    =>
                 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
                p_requesting_entity_id  => p_line_rec.line_id,
		p_request_type => 'ADD_BLANKET_PRICE_LIST_LINE',
		p_param1=> p_line_rec.unit_list_price,
		p_param2 => nvl(p_line_rec.pricing_uom,
		p_line_rec.order_quantity_uom),
		p_param3 => p_line_rec.inventory_item_id,
		p_param4 => p_line_rec.item_identifier_type,
                -- 11i10 Pricing Changes
                -- Send header new price list if line price list is null
                -- Add header_id, sold_to_org and ordered_item parameters
		p_param5 => nvl(p_line_rec.price_list_id,
                                g_header_rec.new_price_list_id),
                p_param6 => p_line_rec.header_id,
                p_param7 => p_line_rec.sold_to_org_id,
                p_param8 => p_line_rec.ordered_item_id,
		x_return_status => x_return_status );

        end if; -- if list line does not exist

      END IF; -- if list price changes

      ELSIF p_line_rec.price_list_id IS NOT NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
             OE_Order_UTIL.Get_Attribute_Name('UNIT_LIST_PRICE'));
         OE_MSG_PUB.ADD;
      END IF;

    END IF; --if g_new_price_list

    --END IF; -- if operation is CREATE

   --for bug 3309427
   --Log request to clear out NOCOPY /* file.sql.39 change */ unit price if the Price list field is updated to a non blanket pricelist.
   IF((NOT IS_BLANKET_PRICE_LIST(p_price_list_id => p_line_rec.price_list_id
                                ,p_blanket_header_id => p_line_rec.header_id))
   AND (p_line_rec.qp_list_line_id is not null))
   THEN
      if l_debug_level > 0 then
         oe_debug_pub.add('qp list line id :'||p_line_rec.qp_list_line_id);
         oe_debug_pub.add('Log delayed request: CLEAR_BLANKET_PRICE_LIST_LINE');
      end if;

      oe_delayed_requests_pvt.Log_request(p_Entity_Code =>
				 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
		p_Entity_Id => p_line_rec.line_id,
                p_requesting_entity_code    =>
                 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
                p_requesting_entity_id  => p_line_rec.line_id,
		p_request_type => OE_GLOBALS.G_CLEAR_BLKT_PRICE_LIST_LINE,
                p_param1=> p_line_rec.qp_list_line_id,
	        p_param2 => g_header_rec.new_price_list_id,
                p_param3 =>  p_line_rec.price_list_id,
                p_param4 => p_line_rec.header_id,
         	x_return_status => x_return_status );
    END IF;

    -- 11i10 Pricing Changes Start
    -- Log request to create new discount line
    IF NOT OE_GLOBALS.EQUAL(p_line_rec.discount_percent,
                            p_old_line_rec.discount_percent)
       OR NOT OE_GLOBALS.EQUAL(p_line_rec.discount_amount,
                            p_old_line_rec.discount_amount)
          OR (p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND --bug#4691643
                (p_line_rec.discount_amount IS NOT NULL OR
                  p_line_rec.discount_percent IS NOT NULL))
    THEN

        IF p_line_rec.modifier_list_line_id IS NOT NULL
        THEN
           oe_debug_pub.add('modifier list line id is not null');
           fnd_message.set_name('ONT','OE_BLKT_CANNOT_UPDATE_DIS');
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF g_header_rec.new_modifier_list_name IS NULL
              AND g_header_rec.new_modifier_list_id IS NULL
        THEN
           fnd_message.set_name('ONT','OE_BLKT_CANNOT_ENTER_DIS');
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF p_line_rec.discount_percent IS NOT NULL
              AND p_line_rec.discount_amount IS NOT NULL
        THEN
           fnd_message.set_name('ONT','OE_BLKT_DISCOUNT_CONFLICT');
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
           -- Log delayed request to create new modifier list line
	   oe_delayed_requests_pvt.Log_request
	       (p_entity_code => OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
		p_Entity_Id => p_line_rec.line_id,
                p_requesting_entity_code    =>
                 OE_BLANKET_pub.G_ENTITY_BLANKET_LINE,
                p_requesting_entity_id  => p_line_rec.line_id,
		p_request_type => 'ADD_MODIFIER_LIST_LINE',
		p_param1 => p_line_rec.discount_percent,
		p_param2 => p_line_rec.discount_amount,
		p_param3 => p_line_rec.inventory_item_id,
		p_param4 => p_line_rec.item_identifier_type,
		p_param5 => nvl(p_line_rec.pricing_uom,
		                p_line_rec.order_quantity_uom),
		p_param6 => p_line_rec.header_id,
		x_return_status => x_return_status );
        END IF;

    END IF;
    -- 11i10 Pricing Changes End


   END IF; --bug 3443777, need to call validate entity for reasons capture

    if l_debug_level > 0 then
    --  Done validating entity
      oe_debug_pub.add('Exit OE_BLANKET_UTIL.Validate ENTITY- Line',1);
    end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate Entity'
            );
        END IF;

END Validate_Entity;

PROCEDURE Validate_Entity
(   p_header_rec           IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
,   p_old_header_rec       IN OE_Blanket_PUB.Header_rec_type := OE_Blanket_PUB.g_miss_header_rec
,   x_return_status        OUT NOCOPY VARCHAR2
)IS
    l_return_status varchar2(1);
    l_dummy varchar2(30);
    l_old_header_rec OE_Blanket_PUB.Header_rec_type := p_old_header_rec;
    l_db_version_number    NUMBER;
    -- 11i10 Pricing Changes
    l_list_header_id       NUMBER;
    l_new_pl_name          VARCHAR2(240);
    l_site_use_code        VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if l_debug_level > 0 then
      oe_debug_pub.add('Enter OE_BLANKET_UTIL.Validate_ENTITY- Header',1);
      oe_debug_pub.add('Operation :'||p_header_rec.operation);
      oe_debug_pub.add('new end date :'||p_header_rec.end_date_active);
      oe_debug_pub.add('old end date :'||l_old_header_rec.end_date_active);
    end if;

    IF p_header_rec.operation = oe_globals.g_opr_update THEN
         if l_old_header_rec.header_id is null THEN
              Query_Header(
                          p_header_id => p_header_rec.header_id,
                          x_header_rec => l_old_header_Rec,
                          x_return_status => l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
              END IF;
         end if;
    END IF;

-- Validate Last Updated By valued issue
    -- Added for a bug #6270818.
    IF p_header_rec.operation = oe_globals.g_opr_update
    THEN
       If p_header_rec.last_updated_by <> FND_GLOBAL.USER_ID or
           l_old_header_rec.last_updated_by <> FND_GLOBAL.USER_ID
       THEN
          p_header_rec.last_updated_by := FND_GLOBAL.USER_ID;
          l_old_header_rec.last_updated_by := FND_GLOBAL.USER_ID;
       END IF;
          p_header_rec.last_update_date := sysdate;
          l_old_header_rec.last_update_date := sysdate;
     END IF;

    g_header_rec := p_header_rec;


    -- Validate Transaction Phase
    -- Added for Pack -j Srini.
    IF p_header_rec.operation = oe_globals.g_opr_create and
       oe_code_control.get_code_release_level >= '110510'
    THEN
       If p_header_rec.TRANSACTION_PHASE_CODE is null and
           l_old_header_rec.TRANSACTION_PHASE_CODE is null
       THEN
          p_header_rec.TRANSACTION_PHASE_CODE := 'F';
          l_old_header_rec.TRANSACTION_PHASE_CODE := 'F';
       END IF;
    END IF;

    g_header_rec := p_header_rec;

    -- Get Blanket Number
    IF NOT OE_GLOBALS.EQUAL(p_header_rec.order_type_id,
            l_old_header_rec.order_type_id) THEN
       IF p_header_rec.order_number is null or
          p_header_rec.order_number = FND_API.G_MISS_NUM
       Then
          get_order_number(   p_x_header_rec => p_header_rec,
                               x_return_status => l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
              END IF;
       End if;
    END IF;

    -- Get Blanket Agreement Name For Null values
    -- Added for Pack -j Srini.
    IF oe_code_control.get_code_release_level >= '110510'
    THEN
       If p_header_rec.sales_document_name is null and
           l_old_header_rec.sales_document_name is null
       THEN
          p_header_rec.sales_document_name := p_header_rec.order_number;
          l_old_header_rec.sales_document_name := p_header_rec.order_number;
       END IF;
    END IF;

    g_header_rec := p_header_rec;

    -- Versioning/Reasons changes (moved to beginning for bug 3775937
    if OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
       OE_GLOBALS.G_CAPTURED_REASON = 'V' THEN
        OE_GLOBALS.G_REASON_CODE := p_header_rec.revision_change_reason_code;
        OE_GLOBALS.G_REASON_COMMENTS := p_header_rec.revision_change_comments;
        OE_GLOBALS.G_CAPTURED_REASON := 'Y';
    end if;

    -- Check Required attributes
    IF  p_header_rec.header_id IS NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('header_id'));
        OE_MSG_PUB.Add;
    END IF;

    IF  p_header_rec.order_number IS NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('BLANKET_NUMBER'));
        OE_MSG_PUB.Add;
    END IF;
    --Enabling Pricing Agreements for pack J
    IF OE_CODE_CONTROL.Get_Code_Release_Level < '110510' THEN
       IF  p_header_rec.sold_to_org_id IS NULL THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('SOLD_TO_ORG_ID'));
           OE_MSG_PUB.Add;
       END IF;
    END IF;

    IF  p_header_rec.transactional_curr_code IS NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
         OE_Order_UTIL.Get_Attribute_Name('TRANSACTIONAL_CURR_CODE'));
         OE_MSG_PUB.Add;
    END IF;

    IF  p_header_rec.start_date_active IS NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Activation Date');
         OE_MSG_PUB.Add;
    END IF;

    ---------------------------------------------------------------------
    -- Bug 3193220
    -- Expiration Date cannot be less than sysdate
    ---------------------------------------------------------------------
--Changes made for Bug No 5528599 start
    if (NOT OE_GLOBALS.EQUAL(trunc(p_header_rec.end_date_active),
                           trunc(l_old_header_rec.end_date_active))
       AND trunc(p_header_rec.end_date_active) < trunc(sysdate))
    then

          if ( nvl(p_header_rec.source_document_type_id,0) = 2) --bug#5528507
               AND p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
             then
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
              OE_MSG_PUB.ADD;
              oe_debug_pub.add('3: Not Setting Error',1);

            else
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
              OE_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              oe_debug_pub.add('3: Setting Error',1);
           end if;
    end if;
--Changes made for Bug No 5528599 start
    -- End Expiration Date < sysdate check

    -- Validate Ship to
    IF p_header_rec.ship_to_org_id IS NOT NULL AND
             ( NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id ,l_old_header_rec.ship_to_org_id) OR
               NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id ,l_old_header_rec.sold_to_org_id)) THEN
               -- ER 5743580
              IF ( NOT Validate_Ship_To_Org(p_header_rec.ship_to_org_id,
                                            p_header_rec.sold_to_org_id )) THEN
                  if l_debug_level > 0 then
                   oe_debug_pub.add ('Blanket In: No data found',2);
                  end if;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE'
                      , OE_Order_Util.Get_Attribute_Name('ship_to_org_id'));
                   OE_MSG_PUB.Add;
               END IF;

    END IF; -- Ship to


-- hashraf start of pack J

    --  Customer Location depends on Sold To Org

    IF p_header_rec.sold_to_site_use_id IS NOT NULL AND
      ( NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_site_use_id
                            ,p_old_header_rec.sold_to_site_use_id) OR
        NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                            ,p_old_header_rec.sold_to_org_id))
    THEN

      BEGIN

        SELECT  'VALID'
        INTO    l_dummy
        FROM
             HZ_CUST_SITE_USES   SITE,
             HZ_CUST_ACCT_SITES  ACCT_SITE
        WHERE
             SITE.SITE_USE_ID = p_header_rec.sold_to_site_use_id
             AND  SITE.SITE_USE_CODE = 'SOLD_TO'
             AND  SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
             AND  ACCT_SITE.CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
             AND  SITE.STATUS = 'A'
             AND  ACCT_SITE.STATUS='A';

        --  Valid Customer Location

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('SOLD_TO_SITE_USE_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN

         IF OE_MSG_PUB.Check_Msg_Level
         (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN

           OE_MSG_PUB.Add_Exc_Msg
           (  G_PKG_NAME ,
             'Record - Customer Location'
           );
         END IF;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END;

    END IF;

-- hashraf end of pack J

      if l_debug_level > 0 then
             oe_debug_pub.add('Validating deliver_to_org_id :'|| to_char(p_header_rec.deliver_to_org_id),2);
             oe_debug_pub.add(' Customer Relations :'|| g_customer_relations, 1);
            end if;
    IF p_header_rec.deliver_to_org_id IS NOT NULL AND
         ( NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_org_id,l_old_header_rec.deliver_to_org_id) OR
           NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id ,l_old_header_rec.sold_to_org_id)) THEN
          -- ER 5743580
       IF NOT (Validate_Deliver_To_Org(p_header_rec.deliver_to_org_id,
                                            p_header_rec.sold_to_org_id )) THEN

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                  OE_Order_Util.Get_Attribute_Name('deliver_to_org_id'));
                  OE_MSG_PUB.Add;
        END IF;

    END if; -- Deliver to

    --  Invoice to Org id depends on sold to org.
    IF p_header_rec.invoice_to_org_id IS NOT NULL AND
          ( NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id ,l_old_header_rec.invoice_to_org_id) OR
            NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id ,l_old_header_rec.sold_to_org_id)) THEN
               -- ER 5743580
            IF NOT ( Validate_Invoice_To_Org ( p_header_rec.invoice_to_org_id,
                                               p_header_rec.sold_to_org_id )) THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                  OE_Order_Util.Get_Attribute_Name('invoice_to_org_id'));
                  OE_MSG_PUB.Add;
                END IF;

    END IF; -- Invoice to org

    --  Sold to contact depends on Sold To Org
    IF p_header_rec.sold_to_contact_id IS NOT NULL AND
      ( NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_contact_id ,l_old_header_rec.sold_to_contact_id) OR
        NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id ,l_old_header_rec.sold_to_org_id)) THEN
         BEGIN

             SELECT 'VALID'
             INTO   l_dummy
             FROM   HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
             WHERE  ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.sold_to_contact_id
             AND    ACCT_ROLE.CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
             AND    ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  ROWNUM = 1;

         --  Valid Sold To Contact
         EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_Util.Get_Attribute_Name('SOLD_TO_CONTACT_ID'));
                    OE_MSG_PUB.Add;
               WHEN OTHERS THEN
                    IF OE_MSG_PUB.Check_Msg_Level ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                         OE_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME , 'Record - Sold To Contact');
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END; -- BEGIN
    END IF; -- Sold to contact needed validation.

    if p_header_rec.start_date_active is not NULL and
       p_header_rec.end_date_active is not NULL and
       p_header_rec.start_date_active  > p_header_rec.end_date_active then
         FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
         OE_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
    end if;

    -- 11i10 Pricing Changes Start
    -- In prior releases, existing price list ID would store either
    -- the standard price list or new price list
    IF OE_CODE_CONTROL.Get_Code_Release_Level < '110510' THEN

    IF p_header_rec.price_list_id IS NULL AND
       p_header_rec.price_list_name IS NOT NULL THEN
      BEGIN
       if l_debug_level > 0 then
        oe_debug_pub.add('Derive price_list_id',1);
       end if;
       -- <R12.MOAC> START Need to check why we need to pass ORG_ID?
        SELECT list_header_id
        INTO   p_header_rec.price_list_id
        FROM   qp_list_headers_vl
        WHERE  list_type_code in ('PRL' ,'AGR')
        AND    p_header_rec.price_list_name = name
        AND    (((nvl(global_flag,'Y') = 'Y'
           OR     orig_org_id = mo_global.get_current_org_id)
           AND    qp_security.security_on = 'Y') or  qp_security.security_on = 'N');
        -- <R12.MOAC> END
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         if l_debug_level > 0 then
          oe_debug_pub.add('New price list needs to be created',1);
         end if;
          g_new_price_list := true;
      END;
    END IF;

    ELSE

    -- In 11i10, new price list field will store the new blanket specific
    -- price list and existing price list ID will store the standard price
    -- list.

    if l_debug_level > 0 then
       oe_debug_pub.add('pl name :'||p_header_rec.new_price_list_name);
       oe_debug_pub.add('old pl name :'||p_old_header_rec.new_price_list_name);
       oe_debug_pub.add('pl id :'||p_header_rec.new_price_list_id);
       oe_debug_pub.add('old pl id :'||p_old_header_rec.new_price_list_id);
       oe_debug_pub.add('ml name :'||p_header_rec.new_modifier_list_name);
       oe_debug_pub.add('old ml name :'||p_old_header_rec.new_modifier_list_name);
       oe_debug_pub.add('ml id :'||p_header_rec.new_modifier_list_id);
       oe_debug_pub.add('old ml id :'||p_old_header_rec.new_modifier_list_id);
    end if;

       IF NOT OE_GLOBALS.EQUAL(p_header_rec.new_price_list_id,
                              p_old_header_rec.new_price_list_id)
       THEN

          -- Cannot enter ID for a new price list, only name
          fnd_message.set_name('ONT','OE_BLKT_CANT_ENTER_NEW_PL_ID');
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;

       ELSIF p_header_rec.new_price_list_name IS NOT NULL
         -- Bug 3213174
         -- Changes from null to not null will be allowed
         AND p_old_header_rec.new_price_list_name IS NULL
         AND NOT OE_GLOBALS.EQUAL(p_header_rec.new_price_list_name
                                  ,p_old_header_rec.new_price_list_name
                                 )
       THEN

          BEGIN

          -- Check if name already exists
          SELECT list_header_id
            INTO l_list_header_id
            FROM qp_list_headers_vl
           WHERE name = p_header_rec.new_price_list_name
             AND rownum = 1;

          fnd_message.set_name('ONT','OE_BLKT_PRICE_LIST_EXISTS');
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            g_new_price_list := true;
          END;

       END IF;

       IF NOT OE_GLOBALS.EQUAL(p_header_rec.new_modifier_list_id,
                              p_old_header_rec.new_modifier_list_id)
       THEN

          -- Cannot enter ID for a new modifier list, only name
          fnd_message.set_name('ONT','OE_BLKT_CANT_ENTER_MOD_LIST_ID');
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;

       ELSIF p_header_rec.new_modifier_list_name IS NOT NULL
         -- Bug 3213174
         -- Changes from null to not null will be allowed
         AND p_old_header_rec.new_modifier_list_name IS NULL
         AND NOT OE_GLOBALS.EQUAL(p_header_rec.new_modifier_list_name
                                  ,p_old_header_rec.new_modifier_list_name
                                 )
       THEN

         oe_debug_pub.add('check if ml exists');

          BEGIN

          -- Check if name already exists
          SELECT list_header_id
            INTO l_list_header_id
            FROM qp_list_headers_vl
           WHERE name = p_header_rec.new_modifier_list_name
             AND rownum = 1;

          fnd_message.set_name('ONT','OE_BLKT_MOD_LIST_EXISTS');
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            g_new_modifier_list := true;
          END;

       END IF;

    END IF; -- End of code release level check
    -- 11i10 Pricing Changes End


    -- Apending Time component to End Date Active for Create or Update Operation.
    -- Pack J
    IF (p_header_rec.operation = oe_globals.g_opr_create) OR
       (p_header_rec.operation = oe_globals.g_opr_update)
      THEN
               IF NOT OE_GLOBALS.EQUAL(p_header_rec.end_date_active
                           ,l_old_header_rec.end_date_active)
        THEN
           p_header_rec.end_date_active :=
                trunc(p_header_rec.end_date_active,'DD') +
                                          ((24*60*60)-1)/(24*60*60);
        END IF;


    END IF; -- End of WF time component changes


    Validate_Min_Max_Range(p_min_value => p_header_rec.Blanket_Min_amount,
        p_max_value => p_header_rec.Blanket_Max_amount,
        p_attribute => 'BLANKET_HEADER_AMOUNT', x_return_status => x_return_status);

    IF p_header_rec.operation = oe_globals.g_opr_update THEN
       --validate for updates


      --commented because waiting for message
      --not allowed to change any attributes on a previously closed blanket
    IF p_header_rec.end_date_active < trunc(sysdate) and
       l_old_header_rec.end_date_active < trunc(sysdate) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_ATTR_CLOSED');
                 OE_MSG_PUB.Add;
    END IF;


      --display warning if we haven't fulfilled minimum requirements
    IF NOT OE_GLOBALS.Equal(p_header_rec.end_date_active, l_old_header_rec.end_date_active) AND
       p_header_rec.end_date_active <= trunc(sysdate) AND
       nvl(p_header_rec.released_amount,0) < p_header_rec.blanket_min_amount THEN
         if l_debug_level > 0 then
           oe_debug_pub.add('Blanket header close min amount ');
         end if;
         FND_MESSAGE.SET_NAME('ONT','OE_BLKT_CLOSE_MIN_VALUES');
         OE_MSG_PUB.ADD;
    END IF;


               IF NOT OE_GLOBALS.Equal (p_header_rec.header_id,
                                l_old_header_rec.header_id) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('HEADER_ID'));
                 OE_MSG_PUB.Add;
               END IF;

               IF NOT OE_GLOBALS.Equal (p_header_rec.order_number,
                                l_old_header_rec.order_number) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('BLANKET_NUMBER'));
                 OE_MSG_PUB.Add;
               END IF;

               IF NOT OE_GLOBALS.Equal (p_header_rec.order_category_code,
                                l_old_header_rec.order_category_code) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('ORDER_CATEGORY_CODE'));
                 OE_MSG_PUB.Add;
               END IF;

               IF NOT OE_GLOBALS.Equal (p_header_rec.org_id,
                                l_old_header_rec.org_id) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('ORG_ID'));
                 OE_MSG_PUB.Add;
               END IF;

             --restricted from changing if releases exist
             IF p_header_rec.released_amount > 0 THEN
               IF NOT OE_GLOBALS.Equal (p_header_rec.sold_to_org_id,
                                l_old_header_rec.sold_to_org_id) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('SOLD_TO_ORG_ID'));
                 OE_MSG_PUB.Add;
               END IF;

               IF NOT OE_GLOBALS.Equal (p_header_rec.transactional_curr_code,
                                l_old_header_rec.transactional_curr_code) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE',
                   OE_Order_UTIL.Get_Attribute_Name('TRANSACTIONAL_CURR_CODE'));
                 OE_MSG_PUB.Add;
               END IF;

               IF NOT OE_GLOBALS.Equal (p_header_rec.start_date_active,
                                l_old_header_rec.start_date_active) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE','Activation Date');
                 OE_MSG_PUB.Add;
               END IF;
             END IF; --if releases exist

               IF NOT OE_GLOBALS.Equal (p_header_rec.released_amount,
                                l_old_header_rec.released_amount) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE','Released Amount');
                 OE_MSG_PUB.Add;
               END IF;

               IF NOT OE_GLOBALS.Equal (p_header_rec.returned_amount,
                                l_old_header_rec.returned_amount) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE', 'Returned Amount');
                 fnd_message.set_token('new amount', p_header_rec.returned_amount);
                 fnd_message.set_token('old amount', l_old_header_rec.returned_amount);
                 OE_MSG_PUB.Add;
               END IF;

               IF NOT OE_GLOBALS.Equal (p_header_rec.fulfilled_amount,
                                l_old_header_rec.fulfilled_amount) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_HDR_ATTRIBUTE');
                 fnd_message.set_token('ATTRIBUTE','Fulfilled Amount');
                 fnd_message.set_token('new amount', p_header_rec.fulfilled_amount);
                 fnd_message.set_token('old amount', l_old_header_rec.fulfilled_amount);
                 OE_MSG_PUB.Add;
               END IF;


      -- Date Validations

               IF p_header_rec.end_date_active IS NOT NULL
                  AND NOT OE_GLOBALS.EQUAL(p_header_rec.end_date_active
                                       ,l_old_header_rec.end_date_active)
               THEN

                  IF (l_old_header_rec.end_date_active IS NOT NULL
                      AND p_header_rec.end_date_active <
                             l_old_header_rec.end_date_active)
                      OR l_old_header_rec.end_date_active IS NULL
                  THEN

                  -- check for conflicting end dates on blanket lines
                     BEGIN

                     SELECT 'ERROR'
                     INTO l_dummy
                     FROM OE_BLANKET_LINES_EXT
                     WHERE ORDER_NUMBER = p_header_rec.order_number
                       AND END_DATE_ACTIVE > p_header_rec.end_date_active
                       AND ROWNUM = 1;

                     IF l_dummy = 'ERROR' THEN
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       fnd_message.set_name('ONT', 'OE_BLKT_END_DATE_CONFLICT');
                       OE_MSG_PUB.Add;
                     END IF;

                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            NULL;
                     END;

                  -- check for existing releases that are not within these
                  -- effectivity dates
                     BEGIN

                     SELECT /* MOAC_SQL_NO_CHANGE */ 'ERROR'
                       INTO l_dummy
                       FROM OE_ORDER_LINES
                      WHERE trunc(request_date) > trunc(p_header_rec.end_date_active)
                        AND BLANKET_NUMBER = p_header_rec.order_number
                        AND ROWNUM = 1;
                      IF l_dummy = 'ERROR' THEN
                         x_return_status := FND_API.G_RET_STS_ERROR;
                         fnd_message.set_name('ONT', 'OE_BLKT_RELEASE_END_DATE');
                         OE_MSG_PUB.Add;
                      END IF;

                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            NULL;
                     END;

                  END IF;

               --check to see if we are cascading end dates to lines
                  IF l_old_header_rec.end_date_active IS NULL
                     AND x_return_status = FND_API.G_RET_STS_SUCCESS
                  THEN
                    BEGIN
                       SELECT 'CASCADE'
                       INTO l_dummy
                       FROM OE_BLANKET_LINES_EXT
                       WHERE ORDER_NUMBER = p_header_rec.order_number
                       AND END_DATE_ACTIVE IS NULL
                       AND ROWNUM = 1;

                       IF l_dummy = 'CASCADE' THEN
                         OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

                         --if cascading, check to see if minimum values are satisfied
                         IF (p_header_rec.end_date_active <= trunc(sysdate)) THEN
                           SELECT 'WARNING'
                           INTO   l_dummy
                           FROM   OE_BLANKET_LINES_EXT OLX, OE_BLANKET_LINES OL
                           WHERE  OLX.LINE_ID = OL.LINE_ID
                           AND    OLX.ORDER_NUMBER = p_header_rec.order_number
                           AND    END_DATE_ACTIVE IS NULL
                           AND    OVERRIDE_BLANKET_CONTROLS_FLAG = 'N'
                           AND   (BLANKET_LINE_MIN_AMOUNT < RELEASED_AMOUNT
                           OR     BLANKET_MIN_QUANTITY < RELEASED_QUANTITY)
                           AND    ROWNUM = 1;

                           IF l_dummy = 'WARNING' THEN
                             fnd_message.set_name('ONT', 'OE_BLKT_CLOSE_MIN_VALUES');
                             OE_MSG_PUB.Add;
                           END IF;
                         END IF;
                       END IF;

                    EXCEPTION
                       WHEN OTHERS THEN
                          NULL;
                    END;
                  END IF;
               END IF;


       --verify max limits

               IF NOT OE_GLOBALS.Equal (p_header_rec.blanket_max_amount,
                    l_old_header_rec.blanket_max_amount)
                  AND p_header_rec.blanket_max_amount < p_header_rec.released_amount
                  AND nvl(p_header_rec.override_amount_flag, 'N') = 'N' THEN
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     fnd_message.set_name('ONT', 'OE_BLKT_UPDATE_MAX_LIMIT');
                     OE_MSG_PUB.Add;
               END IF;

      -- Version Change
      -- Validations and Record History

      IF NOT OE_GLOBALS.EQUAL(p_header_rec.version_number,
                            l_old_header_rec.version_number)
         AND OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110510'
      THEN

       SELECT  /* MOAC_SQL_CHANGE */ version_number
         INTO l_db_version_number
         FROM OE_BLANKET_HEADERS_ALL
        WHERE HEADER_ID = p_header_rec.header_id;

       if l_debug_level > 0 then
          oe_debug_pub.add('new version :'||p_header_rec.version_number);
          oe_debug_pub.add('old version :'||l_old_header_rec.version_number);
          oe_debug_pub.add('DB version :'||l_db_version_number);
       end if;

        IF p_header_rec.version_number
                  <= l_old_header_rec.version_number
        THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_REVISION_NUM');
          OE_MSG_PUB.ADD;

        ELSIF p_header_rec.revision_change_reason_code IS NULL THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Revision Reason');
          OE_MSG_PUB.ADD;

        ELSE

       --validate reason code
      /*
          BEGIN
           SELECT 'VALID'
             INTO l_dummy
             FROM OE_LOOKUPS
             WHERE LOOKUP_TYPE = 'REVISION_REASON'
             AND LOOKUP_CODE = p_header_rec.revision_change_reason_code;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME('ONT','OE_INVALID_REASON_CODE');
               FND_MESSAGE.SET_TOKEN('REASON_CODE', p_header_rec.revision_change_reason_code);
               OE_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_ERROR;
          END;

      */

          query_blanket(p_header_id => p_header_rec.header_id
                       ,p_x_header_rec => g_old_header_hist_Rec
                       ,p_x_line_tbl => g_old_line_hist_tbl
                       ,x_return_status => l_return_status
                      );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
           END IF;

           IF NOT OE_GLOBALS.Equal(x_return_status, FND_API.G_RET_STS_ERROR) THEN
             OE_Delayed_Requests_PVT.Log_Request
                  (p_entity_code  => OE_BLANKET_pub.G_ENTITY_BLANKET_HEADER
                  ,p_Entity_Id => p_header_rec.header_id
	          ,p_requesting_entity_code    =>
                           OE_BLANKET_pub.G_ENTITY_BLANKET_HEADER
                  ,p_requesting_entity_id  => p_header_rec.header_id
                  ,p_request_type => 'RECORD_BLANKET_HISTORY'
                  ,p_param1=> p_header_rec.revision_change_reason_code
                  ,p_long_param1  => p_header_rec.revision_change_comments
                  ,x_return_status => l_return_status);
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             IF p_header_rec.revision_change_date IS NULL THEN
               p_header_rec.revision_change_date := sysdate;
             END IF;

           END IF; --if no errors then log request

        END IF; --if version number less than old

      END IF; -- if version number is not equal

     -- Validate WF STATUS for Start and End Date for a BSA. For Pack J
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    THEN
       if (NOT OE_GLOBALS.Equal(p_header_rec.start_date_active,l_old_header_rec.start_date_active) OR
           NOT OE_GLOBALS.Equal(p_header_rec.end_date_active,l_old_header_rec.end_date_active))
       THEN
             OE_Delayed_Requests_PVT.Log_Request
                  (p_entity_code  => OE_BLANKET_pub.G_ENTITY_BLANKET_HEADER
                  ,p_Entity_Id => p_header_rec.header_id
                  ,p_requesting_entity_code    =>
                           OE_BLANKET_pub.G_ENTITY_BLANKET_HEADER
                  ,p_requesting_entity_id  => p_header_rec.header_id
                  ,p_request_type => 'BLANKET_DATE_CHANGE'
                  ,x_return_status => l_return_status);
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
       end if;
    END IF; -- Validate WF STATUS for  Start and End date for a BSA


    END IF; -- if update operation

    -- For bug #4447494
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    THEN
       if (NOT OE_GLOBALS.Equal(p_header_rec.sold_to_org_id,l_old_header_rec.sold_to_org_id) and
               p_header_rec.operation = oe_globals.g_opr_update) THEN
           OE_Delayed_Requests_PVT.Log_Request
                  (p_entity_code  => OE_BLANKET_pub.G_ENTITY_BLANKET_HEADER
                  ,p_Entity_Id => p_header_rec.header_id
                  ,p_param1 => p_header_rec.sold_to_org_id
                  ,p_requesting_entity_code    =>
                           OE_BLANKET_pub.G_ENTITY_BLANKET_HEADER
                  ,p_requesting_entity_id  => p_header_rec.header_id
                  ,p_request_type => 'VALIDATE_BLANKET_SOLD_TO'
                  ,x_return_status => l_return_status);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
       end if;
    END IF; -- For bug #4447494

     IF g_new_price_list THEN
        if l_debug_level > 0 then
          oe_debug_pub.add('logging request to create blanket price list',1);
        end if;
        if oe_code_control.get_code_release_level >= '110510' then
           l_new_pl_name := p_header_rec.new_price_list_name;
        else
           l_new_pl_name := p_header_rec.price_list_name;
        end if;
        oe_delayed_requests_pvt.Log_request(p_Entity_Code =>
			 OE_BLANKET_pub.G_ENTITY_BLANKET_HEADER,
                     p_Entity_Id => p_header_rec.header_id,
                     p_requesting_entity_code    =>
                 OE_BLANKET_pub.G_ENTITY_BLANKET_HEADER,
                p_requesting_entity_id      => p_header_rec.header_id,
                     p_request_type => 'CREATE_BLANKET_PRICE_LIST',
                     -- 11i10 Pricing Changes
                     p_param1 => l_new_pl_name,
                     p_param2 => nvl(p_header_rec.price_list_currency_code,
                     p_header_rec.transactional_curr_code),
                     p_long_param1  => p_header_rec.price_list_description,
                     -- 11i10 Pricing Changes
                     -- Add header_id and sold_to_org parameters
                     p_param6 => p_header_rec.header_id,
                     p_param7 => p_header_rec.sold_to_org_id,
		     x_return_status => l_return_status);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END IF;

    -- 11i10 Pricing Changes
    -- Log request to create new modifier
    IF g_new_modifier_list THEN
	oe_delayed_requests_pvt.Log_request
	       (p_entity_code => oe_blanket_pub.g_entity_blanket_header,
		p_Entity_Id => p_header_rec.header_id,
                p_requesting_entity_code    =>
                  oe_blanket_pub.g_entity_blanket_header,
                p_requesting_entity_id  => p_header_rec.header_id,
		p_request_type => 'CREATE_MODIFIER_LIST',
		p_param1 => p_header_rec.new_modifier_list_name,
                p_param2 => p_header_rec.transactional_curr_code,
		x_return_status => x_return_status );
    END IF;

    g_header_rec := p_header_rec;

   if l_debug_level > 0 then
    oe_debug_pub.add('Exit OE_BLANKET_UTIL.Validate_ENTITY- Header',1);
   end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME ,   'Validate_Entity');
         END IF;
END Validate_Entity;

PROCEDURE Insert_Row
(p_header_rec        IN  OE_Blanket_PUB.Header_rec_type
,x_return_status     OUT NOCOPY VARCHAR2)
IS
	l_org_id	NUMBER;
	l_upgraded_flag varchar2(1) ;
        l_lock_control  NUMBER := 1;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if l_debug_level > 0 then
     oe_debug_pub.add('Entering OE_BLANKET_UTIL.INSERT_ROW - Header ID :'||
                       p_header_rec.header_id);
    end if;
    --bug 7139169
    OE_GLOBALS.Set_Context;
    l_org_id := OE_GLOBALS.G_ORG_ID;

    --l_org_id := to_number(FND_PROFILE.VALUE('ORG_ID'));
    -- for bug 3342548. Added column CONTEXT
    INSERT  INTO OE_BLANKET_HEADERS
    (       ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    , 	    CONTEXT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORDER_NUMBER
    ,       ORDER_TYPE_ID
    ,       PAYMENT_TERM_ID
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SOLD_TO_CONTACT_ID
    ,       SOLD_TO_ORG_ID
    ,       TRANSACTIONAL_CURR_CODE
    ,       conversion_type_code
    ,       lock_control
    ,       open_flag
    ,       booked_flag
    ,       VERSION_NUMBER
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       ORG_ID
    ,       SALES_DOCUMENT_TYPE_CODE
    ,       ORDER_CATEGORY_CODE
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       SOURCE_DOCUMENT_ID
-- hashraf start of Pack J
    ,	    SALES_DOCUMENT_NAME
    ,	    TRANSACTION_PHASE_CODE
    ,	    USER_STATUS_CODE
    ,	    flow_status_code
    ,	    SUPPLIER_SIGNATURE
    ,	    SUPPLIER_SIGNATURE_DATE
    ,	    CUSTOMER_SIGNATURE
    ,	    CUSTOMER_SIGNATURE_DATE
    ,	    SOLD_TO_SITE_USE_ID
    ,	    DRAFT_SUBMITTED_FLAG
    ,	    SOURCE_DOCUMENT_VERSION_NUMBER
    )  -- end of Pack J
    VALUES
    (       p_header_rec.accounting_rule_id
    ,       p_header_rec.agreement_id
    ,	    p_header_rec.context
    ,       p_header_rec.attribute1
    ,       p_header_rec.attribute10
    ,       p_header_rec.attribute11
    ,       p_header_rec.attribute12
    ,       p_header_rec.attribute13
    ,       p_header_rec.attribute14
    ,       p_header_rec.attribute15
    ,       p_header_rec.attribute16
    ,       p_header_rec.attribute17
    ,       p_header_rec.attribute18
    ,       p_header_rec.attribute19
    ,       p_header_rec.attribute20
    ,       p_header_rec.attribute2
    ,       p_header_rec.attribute3
    ,       p_header_rec.attribute4
    ,       p_header_rec.attribute5
    ,       p_header_rec.attribute6
    ,       p_header_rec.attribute7
    ,       p_header_rec.attribute8
    ,       p_header_rec.attribute9
    ,       p_header_rec.created_by
    ,       p_header_rec.creation_date
    ,       p_header_rec.cust_po_number
    ,       p_header_rec.deliver_to_org_id
    ,       p_header_rec.freight_terms_code
    ,       p_header_rec.header_id
    ,       p_header_rec.invoice_to_org_id
    ,       p_header_rec.invoicing_rule_id
    ,       p_header_rec.last_updated_by
    ,       p_header_rec.last_update_date
    ,       p_header_rec.last_update_login
    ,       p_header_rec.order_number
    ,       p_header_rec.order_type_id
    ,       p_header_rec.payment_term_id
    ,       p_header_rec.price_list_id
    ,       p_header_rec.program_application_id
    ,       p_header_rec.program_id
    ,       p_header_rec.program_update_date
    ,       p_header_rec.request_id
    ,       p_header_rec.salesrep_id
    ,       p_header_rec.shipping_method_code
    ,       p_header_rec.ship_from_org_id
    ,       p_header_rec.ship_to_org_id
    ,       p_header_rec.sold_to_contact_id
    ,       p_header_rec.sold_to_org_id
    ,       p_header_rec.transactional_curr_code
    ,       p_header_rec.conversion_type_code
    ,       l_lock_control
    ,       'Y'
    ,       'N'
    ,       p_header_rec.version_number
    ,	    p_header_rec.shipping_instructions
    ,	    p_header_rec.packing_instructions
    ,       mo_global.get_current_org_id
    ,       'B'
    ,       'ORDER'
    ,       p_header_rec.source_document_type_id
    ,       p_header_rec.source_document_id
    ,       p_header_rec.SALES_DOCUMENT_NAME -- hashraf ... start of pack J
    ,       p_header_rec.TRANSACTION_PHASE_CODE
    ,       p_header_rec.USER_STATUS_CODE
    ,       p_header_rec.FLOW_STATUS_CODE
    ,       p_header_rec.SUPPLIER_SIGNATURE
    ,       p_header_rec.SUPPLIER_SIGNATURE_DATE
    ,       p_header_rec.CUSTOMER_SIGNATURE
    ,       p_header_rec.CUSTOMER_SIGNATURE_DATE
    ,       p_header_rec.sold_to_site_use_id
    ,       p_header_rec.draft_submitted_flag
    ,       p_header_rec.source_document_version_number
    );
-- hashraf ... end of pack J

    INSERT  INTO OE_BLANKET_HEADERS_EXT
    (       ORDER_NUMBER
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       on_hold_flag
    ,       ENFORCE_PRICE_LIST_FLAG
    ,   enforce_ship_to_flag
    ,   enforce_invoice_to_flag
    ,   enforce_freight_term_flag
    ,   enforce_shipping_method_flag
    ,   enforce_payment_term_flag
    ,   enforce_accounting_rule_flag
    ,   enforce_invoicing_rule_flag
    ,       OVERRIDE_AMOUNT_FLAG
    ,       BLANKET_MAX_AMOUNT
    ,       BLANKET_MIN_AMOUNT
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       REVISION_CHANGE_REASON_CODE
    ,       REVISION_CHANGE_COMMENTS
    ,       REVISION_CHANGE_DATE
    -- 11i10 Pricing Changes
    ,       NEW_PRICE_LIST_ID
    ,       NEW_MODIFIER_LIST_ID
    ,       DEFAULT_DISCOUNT_PERCENT
    ,       DEFAULT_DISCOUNT_AMOUNT
)
VALUES
    (       p_header_rec.order_number
    ,       p_header_rec.START_DATE_ACTIVE
    ,       p_header_rec.END_DATE_ACTIVE
    ,       p_header_rec.on_hold_flag
    ,       p_header_rec.ENFORCE_PRICE_LIST_FLAG
    ,       p_header_rec.enforce_ship_to_flag
    ,       p_header_rec.enforce_invoice_to_flag
    ,       p_header_rec.enforce_freight_term_flag
    ,       p_header_rec.enforce_shipping_method_flag
    ,       p_header_rec.enforce_payment_term_flag
    ,       p_header_rec.enforce_accounting_rule_flag
    ,       p_header_rec.enforce_invoicing_rule_flag
    ,       p_header_rec.OVERRIDE_AMOUNT_FLAG
    ,       p_header_rec.Blanket_Max_Amount
    ,       p_header_rec.Blanket_Min_Amount
    ,       p_header_rec.RELEASED_AMOUNT
    ,       p_header_rec.FULFILLED_AMOUNT
    ,       p_header_rec.REVISION_CHANGE_REASON_CODE
    ,       p_header_rec.REVISION_CHANGE_COMMENTS
    ,       p_header_rec.REVISION_CHANGE_DATE
    -- 11i10 Pricing Changes
    ,       p_header_rec.NEW_PRICE_LIST_ID
    ,       p_header_rec.NEW_MODIFIER_LIST_ID
    ,       p_header_rec.default_DISCOUNT_PERCENT
    ,       p_header_rec.default_DISCOUNT_AMOUNT
);

   OE_Blanket_Header_Security.g_check_all_cols_constraint := 'Y'; /* Bug # 5516348 */
   if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_BLANKET_UTIL.INSERT_ROW- Header', 1);
   end if;

EXCEPTION

    WHEN OTHERS THEN
        OE_Blanket_Header_Security.g_check_all_cols_constraint := 'Y'; /* Bug # 5516348 */
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Insert_Row;

PROCEDURE Update_Row
(   p_header_rec       IN   OE_Blanket_PUB.Header_rec_type
,   x_return_status    OUT  NOCOPY VARCHAR2
)
IS
l_return_status VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Versioning changes
    IF OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
       NOT g_old_version_captured THEN
          query_blanket(p_header_id => p_header_rec.header_id
                       ,p_x_header_rec => g_old_header_hist_Rec
                       ,p_x_line_tbl => g_old_line_hist_tbl
                       ,x_return_status => l_return_status
                      );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
           END IF;
           g_old_version_captured := TRUE;
    END IF;
    -- for bug 3342548. Added column CONTEXT
    UPDATE  OE_BLANKET_HEADERS
    SET     ACCOUNTING_RULE_ID             = p_header_rec.accounting_rule_id
    ,       AGREEMENT_ID                   = p_header_rec.agreement_id
    , 	    CONTEXT			   = p_header_rec.context
    ,       ATTRIBUTE1                     = p_header_rec.attribute1
    ,       ATTRIBUTE10                    = p_header_rec.attribute10
    ,       ATTRIBUTE11                    = p_header_rec.attribute11
    ,       ATTRIBUTE12                    = p_header_rec.attribute12
    ,       ATTRIBUTE13                    = p_header_rec.attribute13
    ,       ATTRIBUTE14                    = p_header_rec.attribute14
    ,       ATTRIBUTE15                    = p_header_rec.attribute15
    ,       ATTRIBUTE16                    = p_header_rec.attribute16
    ,       ATTRIBUTE17                    = p_header_rec.attribute17
    ,       ATTRIBUTE18                    = p_header_rec.attribute18
    ,       ATTRIBUTE19                    = p_header_rec.attribute19
    ,       ATTRIBUTE20                    = p_header_rec.attribute20
    ,       ATTRIBUTE2                     = p_header_rec.attribute2
    ,       ATTRIBUTE3                     = p_header_rec.attribute3
    ,       ATTRIBUTE4                     = p_header_rec.attribute4
    ,       ATTRIBUTE5                     = p_header_rec.attribute5
    ,       ATTRIBUTE6                     = p_header_rec.attribute6
    ,       ATTRIBUTE7                     = p_header_rec.attribute7
    ,       ATTRIBUTE8                     = p_header_rec.attribute8
    ,       ATTRIBUTE9                     = p_header_rec.attribute9
  --  ,       CREATED_BY                     = p_header_rec.created_by
  --  ,       CREATION_DATE                  = p_header_rec.creation_date
    ,       CUST_PO_NUMBER                 = p_header_rec.cust_po_number
    ,       DELIVER_TO_ORG_ID              = p_header_rec.deliver_to_org_id
    ,       FREIGHT_TERMS_CODE             = p_header_rec.freight_terms_code
    ,       INVOICE_TO_ORG_ID              = p_header_rec.invoice_to_org_id
    ,       INVOICING_RULE_ID              = p_header_rec.invoicing_rule_id
    ,       LAST_UPDATED_BY                = nvl(p_header_rec.last_updated_by, FND_GLOBAL.USER_ID)
    ,       LAST_UPDATE_DATE               = nvl(p_header_rec.last_update_date, sysdate)
    ,       LAST_UPDATE_LOGIN              = p_header_rec.last_update_login
    ,       ORDER_TYPE_ID                  = p_header_rec.order_type_id
    ,       PAYMENT_TERM_ID                = p_header_rec.payment_term_id
    ,       PRICE_LIST_ID                  = p_header_rec.price_list_id
    ,       PROGRAM_APPLICATION_ID         = p_header_rec.program_application_id
    ,       PROGRAM_ID                     = p_header_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_header_rec.program_update_date


    ,       REQUEST_ID                     = p_header_rec.request_id
    ,       salesrep_id                    = p_header_rec.salesrep_id
    ,       SHIPPING_METHOD_CODE           = p_header_rec.shipping_method_code
    ,       ship_from_org_id               =    p_header_rec.ship_from_org_id
    ,       SHIP_TO_ORG_ID                 = p_header_rec.ship_to_org_id
    ,       SOLD_TO_CONTACT_ID             = p_header_rec.sold_to_contact_id
    ,       SOLD_TO_ORG_ID                 = p_header_rec.sold_to_org_id
    ,       TRANSACTIONAL_CURR_CODE        = p_header_rec.transactional_curr_code
    ,       CONVERSION_TYPE_CODE        = p_header_rec.CONVERSION_TYPE_CODE
    ,       LOCK_CONTROL        = LOCK_CONTROL + 1
    ,       VERSION_NUMBER                 = p_header_rec.version_number
    ,       SHIPPING_INSTRUCTIONS       = p_header_rec.shipping_instructions
    ,       PACKING_INSTRUCTIONS        = p_header_rec.packing_instructions
    ,       SOURCE_DOCUMENT_TYPE_ID = p_header_rec.source_document_type_id
    ,       SOURCE_DOCUMENT_ID     = p_header_rec.source_document_id
-- hashraf ... start of pack J
    ,       SALES_DOCUMENT_NAME		= p_header_rec.SALES_DOCUMENT_NAME
    ,       TRANSACTION_PHASE_CODE      = p_header_rec.TRANSACTION_PHASE_CODE
    ,       USER_STATUS_CODE		= p_header_rec.USER_STATUS_CODE
    ,       FLOW_STATUS_CODE		= p_header_rec.FLOW_STATUS_CODE
    ,       SUPPLIER_SIGNATURE 		= p_header_rec.SUPPLIER_SIGNATURE
    ,       SUPPLIER_SIGNATURE_DATE	= p_header_rec.SUPPLIER_SIGNATURE_DATE
    ,       CUSTOMER_SIGNATURE		= p_header_rec.CUSTOMER_SIGNATURE
    ,       CUSTOMER_SIGNATURE_DATE	= p_header_rec.CUSTOMER_SIGNATURE_DATE
    ,       sold_to_site_use_id         = p_header_rec.sold_to_site_use_id
    ,       draft_submitted_flag	= p_header_rec.draft_submitted_flag
    ,       source_document_version_number      = p_header_rec.source_document_version_number
-- hashraf ... end of pack J

    WHERE   header_id = p_header_rec.header_id;

    UPDATE  OE_BLANKET_HEADERS_EXT
    SET
            START_DATE_ACTIVE = p_header_rec.START_DATE_ACTIVE
    ,       END_DATE_ACTIVE = p_header_rec.END_DATE_ACTIVE
    ,       on_hold_flag = p_header_rec.on_hold_flag
    ,       ENFORCE_PRICE_LIST_FLAG = p_header_rec.ENFORCE_PRICE_LIST_FLAG
    ,   enforce_ship_to_flag = p_header_rec.enforce_ship_to_flag
    ,   enforce_invoice_to_flag = p_header_rec.enforce_invoice_to_flag
    ,   enforce_freight_term_flag = p_header_rec.enforce_freight_term_flag
    ,   enforce_shipping_method_flag = p_header_rec.enforce_shipping_method_flag
    ,   enforce_payment_term_flag = p_header_rec.enforce_payment_term_flag
    ,   enforce_accounting_rule_flag = p_header_rec.enforce_accounting_rule_flag
    ,   enforce_invoicing_rule_flag = p_header_rec.enforce_invoicing_rule_flag
    ,       OVERRIDE_AMOUNT_FLAG = p_header_rec.OVERRIDE_AMOUNT_FLAG
    ,       blanket_max_amount = p_header_rec.Blanket_Max_Amount
    ,       blanket_min_amount = p_header_rec.Blanket_Min_Amount
--    ,       released_amount = p_header_rec.released_amount
--    ,       fulfilled_amount = p_header_rec.fulfilled_amount
--    ,       returned_amount = p_header_rec.returned_amount
    ,       REVISION_CHANGE_REASON_CODE     = p_header_rec.revision_change_reason_code
    ,       REVISION_CHANGE_COMMENTS        = p_header_rec.revision_change_comments
    ,       REVISION_CHANGE_DATE                   = p_header_rec.revision_change_date
    -- 11i10 Pricing Changes
    ,       new_price_list_id = p_header_rec.new_price_list_id
    ,       new_modifier_list_id = p_header_rec.new_modifier_list_id
    ,       default_discount_percent = p_header_rec.default_discount_percent
    ,       default_discount_amount = p_header_rec.default_discount_amount
    WHERE   order_number = p_header_rec.order_number;

    UPDATE OE_BLANKET_LINES_EXT
    SET
            END_DATE_ACTIVE = p_header_rec.end_date_active
    WHERE   order_number = p_header_rec.order_number
    AND     END_DATE_ACTIVE IS NULL;

   OE_Blanket_Header_Security.g_check_all_cols_constraint := 'Y'; /* Bug # 5516348 */
   if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_BLANKET_UTIL.UPDATE_ROW', 1);
   end if;

EXCEPTION

    WHEN OTHERS THEN

        OE_Blanket_Header_Security.g_check_all_cols_constraint := 'Y'; /* Bug # 5516348 */
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Update_Row;

PROCEDURE Delete_Row
(   p_header_id      IN   NUMBER
, x_return_status OUT NOCOPY VARCHAR2)

IS
--
l_transaction_phase_code VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status          VARCHAR2(1);
-- added for delete articles
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
--
--for bug 3348870
l_order_number		Number;
l_line_id		Number;
Cursor c_line_id is
       SELECT	line_id
       FROM 	OE_BLANKET_LINES
       WHERE 	header_id=p_header_id;
--

BEGIN
-- hashraf ... start of pack J
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   if l_debug_level > 0 then
     oe_debug_pub.add('Entering OE_BLANKET_UTIL.DELETE_ROW - HEADER ID :'||
                       p_header_id);
   end if;

  BEGIN

   SELECT   /* MOAC_SQL_CHANGE */ transaction_phase_code
   INTO l_transaction_phase_code
   FROM oe_blanket_headers_all
   WHERE header_id = p_header_id;

  --for bug 3348870
  SELECT order_number
  INTO l_order_number
  FROM OE_BLANKET_HEADERS_ALL
  WHERE header_id=p_header_id;

  EXCEPTION
         WHEN OTHERS THEN
	 null;
  END;


  IF l_transaction_phase_code IS NOT NULL THEN

    IF l_transaction_phase_code = 'N' THEN
     oe_debug_pub.add('OE_BLANKET_UTIL.Delete_Row WF negotiate');
     OE_Order_WF_Util.delete_row(p_type=>'NEGOTIATE', p_id => p_header_id);
    ELSE
     oe_debug_pub.add('OE_BLANKET_UTIL.Delete_Row WF blanket');
     OE_Order_WF_Util.delete_row(p_type=>'BLANKET', p_id => p_header_id);
    END IF;

  END IF;
     oe_debug_pub.add('OE_BLANKET_UTIL.Delete_Row after WF delete');

   -- 11i10 Pricing Changes
   OE_Blanket_Pricing_Util.Deactivate_Pricing
                     (p_blanket_header_id => p_header_id
                     ,x_return_status => l_return_status
                     );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- added for delete attachments
    OE_Atchmt_Util.Delete_Attachments
               ( p_entity_code	=> OE_GLOBALS.G_ENTITY_HEADER
               , p_entity_id      	=> p_header_id
               , x_return_status   => l_return_status
               );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

	 OE_CONTRACTS_UTIL.delete_articles
        (
        p_api_version    =>1,
        p_doc_type       => OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE,
        p_doc_id         =>p_header_id,
        x_return_status  =>l_return_status,
        x_msg_count      =>l_msg_count,
        x_msg_data       =>l_msg_data);

   --for bug 3348870
   For r_line_id in c_line_id
   Loop
        OE_Blanket_Util.Delete_Row(p_line_id => r_line_id.line_id
				,x_return_status => X_RETURN_STATUS);
   End Loop;

   --End bug

   DELETE FROM OE_BLANKET_HEADERS
   WHERE header_id = p_header_id;

   DELETE FROM OE_BLANKET_HEADERS_HIST
   WHERE header_id = p_header_id;

   --for bug 3348870
   DELETE FROM OE_BLANKET_HEADERS_EXT
   WHERE order_number=l_order_number;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_BLANKET_UTIL.DELETE_ROW', 1);
   end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    --added for delete articles
    OE_MSG_PUB.Count_And_Get
     (
       p_count       => l_msg_count,
       p_data        => l_msg_data
      );
		RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --added for delete articles
    OE_MSG_PUB.Count_And_Get
     (
       p_count       => l_msg_count,
       p_data        => l_msg_data
     );
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Delete_Row;

PROCEDURE Insert_Row
( p_line_rec IN OE_Blanket_PUB.Line_rec_type
, x_return_status OUT NOCOPY VARCHAR2)
IS
l_org_id 	NUMBER ;
l_sold_from_org NUMBER;
l_upgraded_flag varchar2(1);
l_lock_control  NUMBER:= 1;
l_index         NUMBER;
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   if l_debug_level > 0 then
     oe_debug_pub.add('Entering OE_BLANKET_UTIL.INSERT_ROW - Line ID :'||
                       p_line_rec.line_id);
   end if;

    --Versioning changes
    IF OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
       NOT g_old_version_captured THEN
          query_blanket(p_header_id => p_line_rec.header_id
                       ,p_x_header_rec => g_old_header_hist_Rec
                       ,p_x_line_tbl => g_old_line_hist_tbl
                       ,x_return_status => l_return_status
                      );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
           END IF;
           g_old_version_captured := TRUE;
    END IF;

    INSERT  INTO OE_BLANKET_LINES
    (       ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       inventory_item_id
    ,       SOLD_TO_ORG_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       item_identifier_type
    ,       lock_control
    ,       open_flag
    ,       ORDERED_ITEM
    ,       ITEM_TYPE_CODE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       line_id
    ,       line_type_id
    ,       line_number
    ,       ORG_ID
    ,       PAYMENT_TERM_ID
    ,       PREFERRED_GRADE             --OPM Added 02/JUN/00
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       ship_to_org_id
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       ORDER_QUANTITY_UOM
    ,       SALES_DOCUMENT_TYPE_CODE
    ,       SHIPMENT_NUMBER
    ,       LINE_CATEGORY_CODE
    ,       BOOKED_FLAG
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_LINE_ID
    ,       transaction_phase_code -- hashraf pack J
    ,       source_document_version_number
    )
    VALUES
    (       p_line_rec.accounting_rule_id
    ,       p_line_rec.agreement_id
    ,       p_line_rec.attribute1
    ,       p_line_rec.attribute10
    ,       p_line_rec.attribute11
    ,       p_line_rec.attribute12
    ,       p_line_rec.attribute13
    ,       p_line_rec.attribute14
    ,       p_line_rec.attribute15
    ,       p_line_rec.attribute16
    ,       p_line_rec.attribute17
    ,       p_line_rec.attribute18
    ,       p_line_rec.attribute19
    ,       p_line_rec.attribute20
    ,       p_line_rec.attribute2
    ,       p_line_rec.attribute3
    ,       p_line_rec.attribute4
    ,       p_line_rec.attribute5
    ,       p_line_rec.attribute6
    ,       p_line_rec.attribute7
    ,       p_line_rec.attribute8
    ,       p_line_rec.attribute9
    ,       p_line_rec.context
    ,       p_line_rec.created_by
    ,       p_line_rec.creation_date
    ,       p_line_rec.cust_po_number
    ,       p_line_rec.deliver_to_org_id
    ,       p_line_rec.freight_terms_code
    ,       p_line_rec.header_id
    ,       p_line_rec.inventory_item_id
    ,       p_line_rec.sold_to_org_id
    ,       p_line_rec.invoice_to_org_id
    ,       p_line_rec.invoicing_rule_id
    ,       p_line_rec.ordered_item_id
    ,       p_line_rec.item_identifier_type
    ,       l_lock_control
    ,       'Y'
    ,       p_line_rec.ordered_item
    ,       p_line_rec.item_type_code
    ,       p_line_rec.last_updated_by
    ,       p_line_rec.last_update_date
    ,       p_line_rec.last_update_login
    ,       p_line_rec.line_id
    ,       p_line_rec.line_type_id
    ,       p_line_rec.line_number
    ,       MO_GLOBAL.GET_CURRENT_ORG_ID
    ,       p_line_rec.payment_term_id
    ,       p_line_rec.preferred_grade            --OPM 02/JUN/00
    ,       p_line_rec.price_list_id
    ,       p_line_rec.program_application_id
    ,       p_line_rec.program_id
    ,       p_line_rec.program_update_date
    ,       p_line_rec.request_id
    ,       p_line_rec.salesrep_id
    ,       p_line_rec.shipping_method_code
    ,       p_line_rec.ship_from_org_id
    ,       p_line_rec.ship_to_org_id
    ,       p_line_rec.shipping_instructions
    ,       p_line_rec.packing_instructions
    ,       p_line_rec.ORDER_QUANTITY_UOM
    ,       'B'
    ,       1
    ,       'ORDER'
    ,       'N'
    ,       p_line_rec.source_document_type_id
    ,       p_line_rec.source_document_id
    ,       p_line_rec.source_document_line_id
    ,       p_line_rec.transaction_phase_code -- hashraf pack J
    ,       p_line_rec.source_document_version_number
    );

    INSERT  INTO OE_BLANKET_LINES_EXT
    (       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       MAX_RELEASE_AMOUNT
    ,       MIN_RELEASE_AMOUNT
    ,       min_release_quantity
    ,       max_release_quantity
    ,       BLANKET_LINE_MAX_AMOUNT
    ,       BLANKET_LINE_MIN_AMOUNT
    ,       BLANKET_MAX_QUANTITY
    ,       BLANKET_MIN_QUANTITY
    ,       OVERRIDE_BLANKET_CONTROLS_FLAG
    ,       OVERRIDE_RELEASE_CONTROLS_FLAG
    ,       ENFORCE_PRICE_LIST_FLAG
    ,   enforce_ship_to_flag
    ,   enforce_invoice_to_flag
    ,   enforce_freight_term_flag
    ,   enforce_shipping_method_flag
    ,   enforce_payment_term_flag
    ,   enforce_accounting_rule_flag
    ,   enforce_invoicing_rule_flag
    ,       RELEASED_QUANTITY
    ,       FULFILLED_QUANTITY
    ,       RETURNED_QUANTITY
    ,       ORDER_NUMBER
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       line_id
    ,       line_number
)
VALUES
(           p_line_rec.START_DATE_ACTIVE
    ,       p_line_rec.END_DATE_ACTIVE
    ,       p_line_rec.MAX_RELEASE_AMOUNT
    ,       p_line_rec.MIN_RELEASE_AMOUNT
    ,       p_line_rec.min_release_quantity
    ,       p_line_rec.max_release_quantity
    ,       p_line_rec.BLANKET_MAX_AMOUNT
    ,       p_line_rec.BLANKET_MIN_AMOUNT
    ,       p_line_rec.BLANKET_MAX_QUANTITY
    ,       p_line_rec.BLANKET_MIN_QUANTITY
    ,       p_line_rec.OVERRIDE_BLANKET_CONTROLS_FLAG
    ,       p_line_rec.OVERRIDE_RELEASE_CONTROLS_FLAG
    ,       p_line_rec.ENFORCE_PRICE_LIST_FLAG
    ,       p_line_rec.enforce_ship_to_flag
    ,       p_line_rec.enforce_invoice_to_flag
    ,       p_line_rec.enforce_freight_term_flag
    ,       p_line_rec.enforce_shipping_method_flag
    ,       p_line_rec.enforce_payment_term_flag
    ,       p_line_rec.enforce_accounting_rule_flag
    ,       p_line_rec.enforce_invoicing_rule_flag
    ,       p_line_rec.RELEASED_QUANTITY
    ,       p_line_rec.FULFILLED_QUANTITY
    ,       p_line_rec.RETURNED_QUANTITY
    ,       p_line_rec.ORDER_NUMBER
    ,       p_line_rec.RELEASED_AMOUNT
    ,       p_line_rec.FULFILLED_AMOUNT
    ,       p_line_rec.line_id
    ,       p_line_rec.line_number
    );

   OE_Blanket_Line_Security.g_check_all_cols_constraint := 'Y'; /* Bug # 5516348 */
   if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_blanket_UTIL.INSERT_ROW', 1);
   end if;

EXCEPTION

    WHEN OTHERS THEN

        OE_Blanket_Line_Security.g_check_all_cols_constraint := 'Y'; /* Bug # 5516348 */
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        x_return_status          := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Insert_Row;

PROCEDURE Update_Row
(   p_line_rec       IN   OE_Blanket_PUB.Line_rec_type
,   x_return_status  OUT NOCOPY VARCHAR2)
IS
l_return_status VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_Blanket_UTIL.UPDATE_ROW - LINE', 1);
   end if;
    x_return_status          := FND_API.G_RET_STS_SUCCESS;

    --Versioning changes
    IF OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
       NOT g_old_version_captured THEN
          query_blanket(p_header_id => p_line_rec.header_id
                       ,p_x_header_rec => g_old_header_hist_Rec
                       ,p_x_line_tbl => g_old_line_hist_tbl
                       ,x_return_status => l_return_status
                      );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
           END IF;
           g_old_version_captured := TRUE;
    END IF;

    UPDATE  OE_BLANKET_LINES
    SET     ACCOUNTING_RULE_ID             = p_line_rec.accounting_rule_id
    ,       AGREEMENT_ID                   = p_line_rec.agreement_id
    ,       ATTRIBUTE1                     = p_line_rec.attribute1
    ,       ATTRIBUTE10                    = p_line_rec.attribute10
    ,       ATTRIBUTE11                    = p_line_rec.attribute11
    ,       ATTRIBUTE12                    = p_line_rec.attribute12
    ,       ATTRIBUTE13                    = p_line_rec.attribute13
    ,       ATTRIBUTE14                    = p_line_rec.attribute14
    ,       ATTRIBUTE15                    = p_line_rec.attribute15
    ,       ATTRIBUTE16                    = p_line_rec.attribute16
    ,       ATTRIBUTE17                    = p_line_rec.attribute17
    ,       ATTRIBUTE18                    = p_line_rec.attribute18
    ,       ATTRIBUTE19                    = p_line_rec.attribute19
    ,       ATTRIBUTE20                    = p_line_rec.attribute20
    ,       ATTRIBUTE2                     = p_line_rec.attribute2
    ,       ATTRIBUTE3                     = p_line_rec.attribute3
    ,       ATTRIBUTE4                     = p_line_rec.attribute4
    ,       ATTRIBUTE5                     = p_line_rec.attribute5
    ,       ATTRIBUTE6                     = p_line_rec.attribute6
    ,       ATTRIBUTE7                     = p_line_rec.attribute7
    ,       ATTRIBUTE8                     = p_line_rec.attribute8
    ,       ATTRIBUTE9                     = p_line_rec.attribute9
    ,       CONTEXT                        = p_line_rec.context
 --   ,       CREATED_BY                     = p_line_rec.created_by
 --   ,       CREATION_DATE                  = p_line_rec.creation_date
    ,       CUST_PO_NUMBER                 = p_line_rec.cust_po_number
    ,       DELIVER_TO_ORG_ID              = p_line_rec.deliver_to_org_id
    ,       FREIGHT_TERMS_CODE             = p_line_rec.freight_terms_code
    ,       header_id              = p_line_rec.header_id
    ,       inventory_item_id              = p_line_rec.inventory_item_id
    ,       INVOICE_TO_ORG_ID              = p_line_rec.invoice_to_org_id
    ,       INVOICING_RULE_ID              = p_line_rec.invoicing_rule_id
    ,       ORDERED_ITEM_ID                        = p_line_rec.ordered_item_id
    ,       item_identifier_type           = p_line_rec.item_identifier_type
    ,       lock_control           = lock_control + 1

    ,       ORDERED_ITEM                     = p_line_rec.ordered_item
    ,       ITEM_TYPE_CODE                 = p_line_rec.item_type_code
    ,       LAST_UPDATED_BY                = nvl(p_line_rec.last_updated_by, FND_GLOBAL.USER_ID)
    ,       LAST_UPDATE_DATE               = nvl(p_line_rec.last_update_date, sysdate)
    ,       LAST_UPDATE_LOGIN              = p_line_rec.last_update_login
    ,       line_number            = p_line_rec.line_number
    ,       PAYMENT_TERM_ID                = p_line_rec.payment_term_id
    ,       PREFERRED_GRADE                = p_line_rec.preferred_grade
    ,       PRICE_LIST_ID                  = p_line_rec.price_list_id
    ,       PROGRAM_APPLICATION_ID         = p_line_rec.program_application_id
    ,       PROGRAM_ID                     = p_line_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_line_rec.program_update_date
    ,       REQUEST_ID                     = p_line_rec.request_id
    ,       SALESREP_ID                    = p_line_rec.salesrep_id
    ,       SHIPPING_METHOD_CODE           = p_line_rec.shipping_method_code
    ,       ship_from_org_id               = p_line_rec.ship_from_org_id
    ,       SHIP_TO_ORG_ID                 = p_line_rec.ship_to_org_id
    ,       SHIPPING_INSTRUCTIONS          = p_line_rec.shipping_instructions
    ,       PACKING_INSTRUCTIONS           = p_line_rec.packing_instructions
    ,       ORDER_QUANTITY_UOM = p_line_rec.ORDER_QUANTITY_UOM
-- hashraf ... start of pack J
    ,       transaction_phase_code         = p_line_rec.transaction_phase_code
    ,       source_document_version_number         = p_line_rec.source_document_version_number
-- hashraf ... end of pack J
    WHERE   line_id		  = p_line_rec.line_id
      AND   header_id	  = p_line_rec.header_id ;

	IF SQL%NOTFOUND THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    UPDATE OE_BLANKET_LINES_EXT
    SET
           min_release_quantity              = p_line_rec.min_release_quantity
    ,       max_release_quantity              = p_line_rec.max_release_quantity
    ,       START_DATE_ACTIVE = p_line_rec.START_DATE_ACTIVE
    ,       END_DATE_ACTIVE = p_line_rec.END_DATE_ACTIVE
    ,       MAX_RELEASE_AMOUNT = p_line_rec.MAX_RELEASE_AMOUNT
    ,       MIN_RELEASE_AMOUNT = p_line_rec.MIN_RELEASE_AMOUNT

    ,       BLANKET_LINE_MAX_AMOUNT = p_line_rec.BLANKET_MAX_AMOUNT
    ,       BLANKET_LINE_MIN_AMOUNT = p_line_rec.BLANKET_MIN_AMOUNT
    ,       BLANKET_MAX_QUANTITY = p_line_rec.BLANKET_MAX_QUANTITY
    ,       BLANKET_MIN_QUANTITY = p_line_rec.BLANKET_MIN_QUANTITY
    ,       OVERRIDE_BLANKET_CONTROLS_FLAG = p_line_rec.OVERRIDE_BLANKET_CONTROLS_FLAG
    ,       OVERRIDE_RELEASE_CONTROLS_FLAG = p_line_rec.OVERRIDE_RELEASE_CONTROLS_FLAG
    ,       ENFORCE_PRICE_LIST_FLAG = p_line_rec.ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag = p_line_rec.enforce_ship_to_flag
    ,       enforce_invoice_to_flag = p_line_rec.enforce_invoice_to_flag
    ,       enforce_freight_term_flag = p_line_rec.enforce_freight_term_flag
    ,       enforce_shipping_method_flag = p_line_rec.enforce_shipping_method_flag
    ,       enforce_payment_term_flag = p_line_rec.enforce_payment_term_flag
    ,       enforce_accounting_rule_flag = p_line_rec.enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag = p_line_rec.enforce_invoicing_rule_flag
--    ,       RELEASED_QUANTITY = p_line_rec.RELEASED_QUANTITY
--    ,       FULFILLED_QUANTITY = p_line_rec.FULFILLED_QUANTITY
--    ,       RETURNED_QUANTITY = p_line_rec.RETURNED_QUANTITY
--    ,       released_amount = p_line_rec.released_amount
--    ,       fulfilled_amount = p_line_rec.fulfilled_amount
--    ,       returned_amount = p_line_rec.returned_amount
      ,       line_number = p_line_rec.line_number  --bug5894169
    WHERE   line_id = p_line_rec.line_id;

   OE_Blanket_Line_Security.g_check_all_cols_constraint := 'Y'; /* Bug # 5516348 */
   if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_Blanket_UTIL.UPDATE_ROW - LINE', 1);
   end if;

EXCEPTION


    WHEN OTHERS THEN
        OE_Blanket_Line_Security.g_check_all_cols_constraint := 'Y'; /* Bug # 5516348 */
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        x_return_status          := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Update_Row;

PROCEDURE Delete_Row
(   p_line_id      IN   NUMBER
, x_return_status OUT NOCOPY VARCHAR2
)
IS
l_header_id   NUMBER := g_header_rec.header_id;
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
-- hashraf ... start of pack J
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   if l_debug_level > 0 then
     oe_debug_pub.add('Entering OE_BLANKET_UTIL.DELETE_ROW - LINE ID :'||
                       p_line_id);
   end if;

   IF l_header_id IS NULL or
      l_header_id = FND_API.G_MISS_NUM THEN
    SELECT  /* MOAC_SQL_CHANGE */ header_id into l_header_id
    FROM OE_BLANKET_LINES_all
    WHERE line_id = p_line_id;
   END IF;

    --Versioning changes
    IF OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
       NOT g_old_version_captured THEN
          query_blanket(p_header_id => l_header_id
                       ,p_x_header_rec => g_old_header_hist_Rec
                       ,p_x_line_tbl => g_old_line_hist_tbl
                       ,x_return_status => l_return_status
                      );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
           END IF;
           g_old_version_captured := TRUE;
    END IF;

   --for bug 3348870
   OE_Blanket_Pricing_Util.Deactivate_Pricing
                     (p_blanket_header_id => l_header_id
   		     ,p_blanket_line_id => p_line_id
                     ,x_return_status => l_return_status
                     );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OE_Atchmt_Util.Delete_Attachments
               ( p_entity_code	=> OE_GLOBALS.G_ENTITY_LINE
               , p_entity_id      	=> p_line_id
               , x_return_status   => l_return_status
               );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End bug

   DELETE FROM OE_BLANKET_LINES
   WHERE line_id = p_line_id;

   --for bug 3348870

   DELETE FROM OE_BLANKET_LINES_EXT
   WHERE line_id = p_line_id;

   DELETE FROM OE_BLANKET_LINES_HIST
   WHERE line_id = p_line_id;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_BLANKET_UTIL.DELETE_ROW', 1);
   end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    	RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Delete_Row;


PROCEDURE Query_Header
( p_header_id          IN   NUMBER
, p_version_number     IN   NUMBER := NULL
, p_phase_change_flag  IN VARCHAR2 := NULL
, x_header_rec         IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
, x_return_status      OUT NOCOPY VARCHAR2
)IS

CURSOR l_hdr_csr IS
    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       bh.ORDER_NUMBER
    ,       ORDER_TYPE_ID
    ,       ORG_ID
    ,       PAYMENT_TERM_ID
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SOLD_TO_CONTACT_ID
    ,       SOLD_TO_ORG_ID
    ,       TRANSACTIONAL_CURR_CODE
    ,       conversion_type_code
    ,       LOCK_CONTROL
    ,       VERSION_NUMBER
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       on_hold_flag
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       OVERRIDE_AMOUNT_FLAG
    ,       BLANKET_MAX_AMOUNT
    ,       BLANKET_MIN_AMOUNT
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       source_document_id
    ,       source_document_type_id
    ,       SALES_DOCUMENT_NAME -- hashraf ... start of pack J
    ,       TRANSACTION_PHASE_CODE
    ,       USER_STATUS_CODE
    ,       FLOW_STATUS_CODE
    ,	    SUPPLIER_SIGNATURE
    ,	    SUPPLIER_SIGNATURE_DATE
    ,	    CUSTOMER_SIGNATURE
    ,	    CUSTOMER_SIGNATURE_DATE
    ,       sold_to_site_use_id
    ,       draft_submitted_flag
    ,       source_document_version_number -- hashraf ... end of pack J
    -- 11i10 Pricing Changes
    ,       new_price_list_id
    ,       new_modifier_list_id
    ,       default_discount_percent
    ,       default_discount_amount
    FROM    OE_BLANKET_HEADERS bh, OE_BLANKET_HEADERS_EXT bhx
    WHERE   bh.order_number = bhx.order_number
      AND   bh.header_id = p_header_id
      AND   bh.sales_document_type_code = 'B';

CURSOR l_hdr_hist_csr IS
    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       bh.ORDER_NUMBER
    ,       ORDER_TYPE_ID
    ,       ORG_ID
    ,       PAYMENT_TERM_ID
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SOLD_TO_CONTACT_ID
    ,       SOLD_TO_ORG_ID
    ,       TRANSACTIONAL_CURR_CODE
    ,       conversion_type_code
    ,       NULL                         --    ,       LOCK_CONTROL
    ,       VERSION_NUMBER
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       on_hold_flag
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       OVERRIDE_AMOUNT_FLAG
    ,       BLANKET_MAX_AMOUNT
    ,       BLANKET_MIN_AMOUNT
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       source_document_id
    ,       source_document_type_id
    ,       SALES_DOCUMENT_NAME -- hashraf ... start of pack J
    ,       TRANSACTION_PHASE_CODE
    ,       USER_STATUS_CODE
    ,       FLOW_STATUS_CODE
    ,	    SUPPLIER_SIGNATURE
    ,	    SUPPLIER_SIGNATURE_DATE
    ,	    CUSTOMER_SIGNATURE
    ,	    CUSTOMER_SIGNATURE_DATE
    ,       sold_to_site_use_id
    ,       draft_submitted_flag
    ,       source_document_version_number -- hashraf ... end of pack J
    -- 11i10 Pricing Changes
    ,       new_price_list_id
    ,       new_modifier_list_id
    ,       default_discount_percent
    ,       default_discount_amount
    FROM    OE_BLANKET_HEADERS_HIST bh
    WHERE   bh.header_id = p_header_id
      AND   bh.sales_document_type_code = 'B'
      AND   bh.version_number = p_version_number
     AND    (PHASE_CHANGE_FLAG = p_phase_change_flag
     OR     (nvl(p_phase_change_flag, 'NULL') <> 'Y'));

l_org_id		      NUMBER;
l_current_version_number      NUMBER := NULL;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_BLANKET_UTIL.QUERY_ROW', 1);
   end if;

   IF p_version_number IS NOT NULL THEN
    SELECT  /* MOAC_SQL_CHANGE */ version_number INTO l_current_version_number FROM OE_BLANKET_HEADERS_ALL WHERE header_id = p_header_id;
   END IF;

   IF p_version_number IS NULL OR
      p_version_number = l_current_version_number THEN

      --Fetch from blanket tables
      OPEN l_hdr_csr;
      FETCH l_hdr_csr
    INTO    x_header_rec.accounting_rule_id
    ,       x_header_rec.agreement_id
    ,       x_header_rec.attribute1
    ,       x_header_rec.attribute10
    ,       x_header_rec.attribute11
    ,       x_header_rec.attribute12
    ,       x_header_rec.attribute13
    ,       x_header_rec.attribute14
    ,       x_header_rec.attribute15
    ,       x_header_rec.attribute16
    ,       x_header_rec.attribute17
    ,       x_header_rec.attribute18
    ,       x_header_rec.attribute19
    ,       x_header_rec.attribute20
    ,       x_header_rec.attribute2
    ,       x_header_rec.attribute3
    ,       x_header_rec.attribute4
    ,       x_header_rec.attribute5
    ,       x_header_rec.attribute6
    ,       x_header_rec.attribute7
    ,       x_header_rec.attribute8
    ,       x_header_rec.attribute9
    ,       x_header_rec.context
    ,       x_header_rec.created_by
    ,       x_header_rec.creation_date
    ,       x_header_rec.cust_po_number
    ,       x_header_rec.deliver_to_org_id
    ,       x_header_rec.freight_terms_code
    ,       x_header_rec.header_id
    ,       x_header_rec.invoice_to_org_id
    ,       x_header_rec.invoicing_rule_id
    ,       x_header_rec.last_updated_by
    ,       x_header_rec.last_update_date
    ,       x_header_rec.last_update_login
    ,       x_header_rec.order_number
    ,       x_header_rec.order_type_id
    ,       x_header_rec.org_id
    ,       x_header_rec.payment_term_id
    ,       x_header_rec.price_list_id
    ,       x_header_rec.program_application_id
    ,       x_header_rec.program_id
    ,       x_header_rec.program_update_date
    ,       x_header_rec.request_id
    ,       x_header_rec.salesrep_id
    ,       x_header_rec.shipping_method_code
    ,       x_header_rec.ship_from_org_id
    ,       x_header_rec.ship_to_org_id
    ,       x_header_rec.sold_to_contact_id
    ,       x_header_rec.sold_to_org_id
    ,       x_header_rec.transactional_curr_code
    ,       x_header_rec.conversion_type_code
    ,       x_header_rec.LOCK_CONTROL
    ,       x_header_rec.version_number
    ,       x_header_rec.shipping_instructions
    ,       x_header_rec.packing_instructions
    ,       x_header_rec.START_DATE_ACTIVE
    ,       x_header_rec.END_DATE_ACTIVE
    ,       x_header_rec.on_hold_flag
    ,       x_header_rec.ENFORCE_PRICE_LIST_FLAG
    ,       x_header_rec.enforce_ship_to_flag
    ,       x_header_rec.enforce_invoice_to_flag
    ,       x_header_rec.enforce_freight_term_flag
    ,       x_header_rec.enforce_shipping_method_flag
    ,       x_header_rec.enforce_payment_term_flag
    ,       x_header_rec.enforce_accounting_rule_flag
    ,       x_header_rec.enforce_invoicing_rule_flag
    ,       x_header_rec.OVERRIDE_AMOUNT_FLAG
    ,       x_header_rec.Blanket_Max_Amount
    ,       x_header_rec.Blanket_Min_Amount
    ,       x_header_rec.RELEASED_AMOUNT
    ,       x_header_rec.FULFILLED_AMOUNT
    ,       x_header_rec.RETURNED_AMOUNT
    ,       x_header_rec.source_document_id
    ,       x_header_rec.source_document_type_id
    ,       x_header_rec.SALES_DOCUMENT_NAME -- hashraf ... start of pack J
    ,       x_header_rec.TRANSACTION_PHASE_CODE
    ,       x_header_rec.USER_STATUS_CODE
    ,       x_header_rec.FLOW_STATUS_CODE
    ,       x_header_rec.SUPPLIER_SIGNATURE
    ,       x_header_rec.SUPPLIER_SIGNATURE_DATE
    ,       x_header_rec.CUSTOMER_SIGNATURE
    ,       x_header_rec.CUSTOMER_SIGNATURE_DATE
    ,       x_header_rec.sold_to_site_use_id
    ,       x_header_rec.draft_submitted_flag
    ,       x_header_rec.source_document_version_number -- hashraf ... end of pack J
    -- 11i10 Pricing Changes
    ,       x_header_rec.new_price_list_id
    ,       x_header_rec.new_modifier_list_id
    ,       x_header_rec.default_discount_percent
    ,       x_header_rec.default_discount_amount
    ;
      IF x_header_rec.new_price_list_id IS NOT NULL THEN
         SELECT name
           INTO x_header_rec.new_price_list_name
           FROM qp_list_headers_vl
          WHERE list_header_id = x_header_rec.new_price_list_id;
      END IF;
      IF x_header_rec.new_modifier_list_id IS NOT NULL THEN
         SELECT name
           INTO x_header_rec.new_modifier_list_name
           FROM qp_list_headers_vl
          WHERE list_header_id = x_header_rec.new_modifier_list_id;
      END IF;
      CLOSE l_hdr_csr;
   ELSE
     --Fetch from history table
      OPEN l_hdr_hist_csr;
      FETCH l_hdr_hist_csr
    INTO    x_header_rec.accounting_rule_id
    ,       x_header_rec.agreement_id
    ,       x_header_rec.attribute1
    ,       x_header_rec.attribute10
    ,       x_header_rec.attribute11
    ,       x_header_rec.attribute12
    ,       x_header_rec.attribute13
    ,       x_header_rec.attribute14
    ,       x_header_rec.attribute15
    ,       x_header_rec.attribute16
    ,       x_header_rec.attribute17
    ,       x_header_rec.attribute18
    ,       x_header_rec.attribute19
    ,       x_header_rec.attribute20
    ,       x_header_rec.attribute2
    ,       x_header_rec.attribute3
    ,       x_header_rec.attribute4
    ,       x_header_rec.attribute5
    ,       x_header_rec.attribute6
    ,       x_header_rec.attribute7
    ,       x_header_rec.attribute8
    ,       x_header_rec.attribute9
    ,       x_header_rec.context
    ,       x_header_rec.created_by
    ,       x_header_rec.creation_date
    ,       x_header_rec.cust_po_number
    ,       x_header_rec.deliver_to_org_id
    ,       x_header_rec.freight_terms_code
    ,       x_header_rec.header_id
    ,       x_header_rec.invoice_to_org_id
    ,       x_header_rec.invoicing_rule_id
    ,       x_header_rec.last_updated_by
    ,       x_header_rec.last_update_date
    ,       x_header_rec.last_update_login
    ,       x_header_rec.order_number
    ,       x_header_rec.order_type_id
    ,       x_header_rec.org_id
    ,       x_header_rec.payment_term_id
    ,       x_header_rec.price_list_id
    ,       x_header_rec.program_application_id
    ,       x_header_rec.program_id
    ,       x_header_rec.program_update_date
    ,       x_header_rec.request_id
    ,       x_header_rec.salesrep_id
    ,       x_header_rec.shipping_method_code
    ,       x_header_rec.ship_from_org_id
    ,       x_header_rec.ship_to_org_id
    ,       x_header_rec.sold_to_contact_id
    ,       x_header_rec.sold_to_org_id
    ,       x_header_rec.transactional_curr_code
    ,       x_header_rec.conversion_type_code
    ,       x_header_rec.LOCK_CONTROL
    ,       x_header_rec.version_number
    ,       x_header_rec.shipping_instructions
    ,       x_header_rec.packing_instructions
    ,       x_header_rec.START_DATE_ACTIVE
    ,       x_header_rec.END_DATE_ACTIVE
    ,       x_header_rec.on_hold_flag
    ,       x_header_rec.ENFORCE_PRICE_LIST_FLAG
    ,       x_header_rec.enforce_ship_to_flag
    ,       x_header_rec.enforce_invoice_to_flag
    ,       x_header_rec.enforce_freight_term_flag
    ,       x_header_rec.enforce_shipping_method_flag
    ,       x_header_rec.enforce_payment_term_flag
    ,       x_header_rec.enforce_accounting_rule_flag
    ,       x_header_rec.enforce_invoicing_rule_flag
    ,       x_header_rec.OVERRIDE_AMOUNT_FLAG
    ,       x_header_rec.Blanket_Max_Amount
    ,       x_header_rec.Blanket_Min_Amount
    ,       x_header_rec.RELEASED_AMOUNT
    ,       x_header_rec.FULFILLED_AMOUNT
    ,       x_header_rec.RETURNED_AMOUNT
    ,       x_header_rec.source_document_id
    ,       x_header_rec.source_document_type_id
    ,       x_header_rec.SALES_DOCUMENT_NAME -- hashraf ... start of pack J
    ,       x_header_rec.TRANSACTION_PHASE_CODE
    ,       x_header_rec.USER_STATUS_CODE
    ,       x_header_rec.FLOW_STATUS_CODE
    ,       x_header_rec.SUPPLIER_SIGNATURE
    ,       x_header_rec.SUPPLIER_SIGNATURE_DATE
    ,       x_header_rec.CUSTOMER_SIGNATURE
    ,       x_header_rec.CUSTOMER_SIGNATURE_DATE
    ,       x_header_rec.sold_to_site_use_id
    ,       x_header_rec.draft_submitted_flag
    ,       x_header_rec.source_document_version_number -- hashraf ... end of pack J
    -- 11i10 Pricing Changes
    ,       x_header_rec.new_price_list_id
    ,       x_header_rec.new_modifier_list_id
    ,       x_header_rec.default_discount_percent
    ,       x_header_rec.default_discount_amount
    ;
      IF x_header_rec.new_price_list_id IS NOT NULL THEN
         SELECT name
           INTO x_header_rec.new_price_list_name
           FROM qp_list_headers_vl
          WHERE list_header_id = x_header_rec.new_price_list_id;
      END IF;
      IF x_header_rec.new_modifier_list_id IS NOT NULL THEN
         SELECT name
           INTO x_header_rec.new_modifier_list_name
           FROM qp_list_headers_vl
          WHERE list_header_id = x_header_rec.new_modifier_list_id;
      END IF;
     CLOSE l_hdr_hist_csr;
   END IF;

   if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_BLANKET_UTIL.QUERY_ROW -Header', 1);
   end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
	   RAISE NO_DATA_FOUND;

    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Header;

PROCEDURE Query_Lines
(p_line_id              IN NUMBER := NULL
,p_header_id            IN NUMBER := NULL
,p_version_number       IN NUMBER := NULL
,p_phase_change_flag    IN VARCHAR2 := NULL
,x_line_tbl             IN OUT NOCOPY OE_Blanket_PUB.line_tbl_type
,x_return_status        OUT NOCOPY VARCHAR2
)IS

l_org_id 		      	NUMBER;
l_count				NUMBER;
l_entity				VARCHAR2(1);
l_current_version_number        NUMBER;

CURSOR l_line_csr IS
    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       min_release_quantity
    ,       max_release_quantity
    ,       inventory_item_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       item_identifier_type
    ,       lock_control
    ,       ORDERED_ITEM
    ,       ITEM_TYPE_CODE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       bl.line_id
    ,       bl.line_number
    ,       PAYMENT_TERM_ID
    ,       PREFERRED_GRADE                --OPM 02/JUN/00
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       MAX_RELEASE_AMOUNT
    ,       MIN_RELEASE_AMOUNT
    ,       BLANKET_LINE_MAX_AMOUNT
    ,       BLANKET_LINE_MIN_AMOUNT
    ,       BLANKET_MAX_QUANTITY
    ,       BLANKET_MIN_QUANTITY
    ,       OVERRIDE_BLANKET_CONTROLS_FLAG
    ,       OVERRIDE_RELEASE_CONTROLS_FLAG
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       ORDER_QUANTITY_UOM
    ,       RELEASED_QUANTITY
    ,       blx.FULFILLED_QUANTITY
    ,       RETURNED_QUANTITY
    ,       ORDER_NUMBER
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       TRANSACTION_PHASE_CODE -- hashraf ... start of pack J
    ,       source_document_version_number
    -- 11i10 Pricing Changes
    ,       modifier_list_line_id
    ,       blx.qp_list_line_id
    FROM    OE_BLANKET_LINES bl, OE_BLANKET_LINES_EXT blx
    WHERE   bl.line_id = blx.line_id
      AND   bl.sales_document_type_code = 'B'
      AND  ( bl.line_id = p_line_id OR
	    header_id = p_header_id) ;

CURSOR l_line_hist_csr IS
    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       min_release_quantity
    ,       max_release_quantity
    ,       inventory_item_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       item_identifier_type
    ,       NULL                           --    ,       lock_control
    ,       ORDERED_ITEM
    ,       ITEM_TYPE_CODE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       bl.line_id
    ,       bl.line_number
    ,       PAYMENT_TERM_ID
    ,       PREFERRED_GRADE                --OPM 02/JUN/00
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       MAX_RELEASE_AMOUNT
    ,       MIN_RELEASE_AMOUNT
    ,       BLANKET_LINE_MAX_AMOUNT
    ,       BLANKET_LINE_MIN_AMOUNT
    ,       BLANKET_MAX_QUANTITY
    ,       BLANKET_MIN_QUANTITY
    ,       OVERRIDE_BLANKET_CONTROLS_FLAG
    ,       OVERRIDE_RELEASE_CONTROLS_FLAG
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       ORDER_QUANTITY_UOM
    ,       RELEASED_QUANTITY
    ,       FULFILLED_QUANTITY
    ,       RETURNED_QUANTITY
    ,       ORDER_NUMBER
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       TRANSACTION_PHASE_CODE -- hashraf ... start of pack J
    ,       source_document_version_number
    -- 11i10 Pricing Changes
    ,       modifier_list_line_id
    ,       qp_list_line_id
    FROM    OE_BLANKET_LINES_HIST bl
    WHERE   bl.sales_document_type_code = 'B'
      AND  ( bl.line_id = p_line_id OR
	    header_id = p_header_id)
      AND   version_number = p_version_number
     AND    (PHASE_CHANGE_FLAG = p_phase_change_flag
     OR     (nvl(p_phase_change_flag, 'NULL') <> 'Y'));

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF
    (p_line_id IS NOT NULL
     AND
    p_header_id IS NOT NULL)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: line_id = '|| p_line_id || ',
header_id = '|| p_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

   IF p_version_number IS NOT NULL THEN
    SELECT  /* MOAC_SQL_CHANGE */ version_number INTO l_current_version_number FROM OE_BLANKET_HEADERS_ALL WHERE (header_id = p_header_id OR header_id = (select header_id from oe_blanket_lines_ALL where line_id = p_line_id));
   END IF;


 IF p_version_number IS NULL OR
    p_version_number = l_current_version_number THEN

    --  Loop over fetched records

    l_count := 1;

    FOR l_rec IN l_line_csr LOOP

        x_line_tbl(l_count).accounting_rule_id  := l_rec.ACCOUNTING_RULE_ID;
        x_line_tbl(l_count).agreement_id        := l_rec.AGREEMENT_ID;
        x_line_tbl(l_count).attribute1          := l_rec.ATTRIBUTE1;
        x_line_tbl(l_count).attribute10         := l_rec.ATTRIBUTE10;
        x_line_tbl(l_count).attribute11         := l_rec.ATTRIBUTE11;
        x_line_tbl(l_count).attribute12         := l_rec.ATTRIBUTE12;
        x_line_tbl(l_count).attribute13         := l_rec.ATTRIBUTE13;
        x_line_tbl(l_count).attribute14         := l_rec.ATTRIBUTE14;
        x_line_tbl(l_count).attribute15         := l_rec.ATTRIBUTE15;
        x_line_tbl(l_count).attribute16         := l_rec.ATTRIBUTE16;
        x_line_tbl(l_count).attribute17         := l_rec.ATTRIBUTE17;
        x_line_tbl(l_count).attribute18         := l_rec.ATTRIBUTE18;
        x_line_tbl(l_count).attribute19         := l_rec.ATTRIBUTE19;
        x_line_tbl(l_count).attribute20         := l_rec.ATTRIBUTE20;
        x_line_tbl(l_count).attribute2          := l_rec.ATTRIBUTE2;
        x_line_tbl(l_count).attribute3          := l_rec.ATTRIBUTE3;
        x_line_tbl(l_count).attribute4          := l_rec.ATTRIBUTE4;
        x_line_tbl(l_count).attribute5          := l_rec.ATTRIBUTE5;
        x_line_tbl(l_count).attribute6          := l_rec.ATTRIBUTE6;
        x_line_tbl(l_count).attribute7          := l_rec.ATTRIBUTE7;
        x_line_tbl(l_count).attribute8          := l_rec.ATTRIBUTE8;
        x_line_tbl(l_count).attribute9          := l_rec.ATTRIBUTE9;
        x_line_tbl(l_count).context             := l_rec.CONTEXT;

        x_line_tbl(l_count).created_by          := l_rec.CREATED_BY;
        x_line_tbl(l_count).creation_date       := l_rec.CREATION_DATE;
        x_line_tbl(l_count).cust_po_number      := l_rec.CUST_PO_NUMBER;
        x_line_tbl(l_count).deliver_to_org_id   := l_rec.DELIVER_TO_ORG_ID;
        x_line_tbl(l_count).freight_terms_code  := l_rec.FREIGHT_TERMS_CODE;
        x_line_tbl(l_count).header_id  := l_rec.header_id;
        x_line_tbl(l_count).min_release_quantity  := l_rec.min_release_quantity;
        x_line_tbl(l_count).max_release_quantity  := l_rec.max_release_quantity;
        x_line_tbl(l_count).inventory_item_id   := l_rec.INVENTORY_ITEM_ID;
        x_line_tbl(l_count).invoice_to_org_id   := l_rec.INVOICE_TO_ORG_ID;
        x_line_tbl(l_count).invoicing_rule_id   := l_rec.INVOICING_RULE_ID;
        x_line_tbl(l_count).ordered_item_id             := l_rec.ORDERED_ITEM_ID;
        x_line_tbl(l_count).item_identifier_type := l_rec.item_identifier_type;
        x_line_tbl(l_count).lock_control := l_rec.lock_control;

        x_line_tbl(l_count).ordered_item          := l_rec.ORDERED_ITEM;
        x_line_tbl(l_count).item_type_code      := l_rec.ITEM_TYPE_CODE;
        x_line_tbl(l_count).last_updated_by     := l_rec.LAST_UPDATED_BY;
        x_line_tbl(l_count).last_update_date    := l_rec.LAST_UPDATE_DATE;
        x_line_tbl(l_count).last_update_login   := l_rec.LAST_UPDATE_LOGIN;
        x_line_tbl(l_count).line_id := l_rec.line_id;
        x_line_tbl(l_count).line_number  := l_rec.line_number;
        x_line_tbl(l_count).payment_term_id     := l_rec.PAYMENT_TERM_ID;
        x_line_tbl(l_count).preferred_grade     := l_rec.PREFERRED_GRADE;  -- OPM
        x_line_tbl(l_count).price_list_id       := l_rec.PRICE_LIST_ID;
        x_line_tbl(l_count).program_application_id := l_rec.PROGRAM_APPLICATION_ID;
        x_line_tbl(l_count).program_id          := l_rec.PROGRAM_ID;
        x_line_tbl(l_count).program_update_date := l_rec.PROGRAM_UPDATE_DATE;
        x_line_tbl(l_count).request_id          := l_rec.REQUEST_ID;
         x_line_tbl(l_count).salesrep_id      := l_rec.SALESREP_ID;
         x_line_tbl(l_count).released_amount  := l_rec.released_amount;
        x_line_tbl(l_count).shipping_method_code := l_rec.SHIPPING_METHOD_CODE;
        x_line_tbl(l_count).ship_from_org_id    := l_rec.ship_from_org_id;
        x_line_tbl(l_count).ship_to_org_id      := l_rec.SHIP_TO_ORG_ID;
        x_line_tbl(l_count).shipping_instructions := l_rec.shipping_instructions;
        x_line_tbl(l_count).packing_instructions := l_rec.packing_instructions;
    x_line_tbl(l_count).start_Date_active :=   l_rec.START_DATE_ACTIVE;
    x_line_tbl(l_count).END_DATE_ACTIVE :=   l_rec.END_DATE_ACTIVE;
    x_line_tbl(l_count).MAX_RELEASE_AMOUNT :=
               l_rec.MAX_RELEASE_AMOUNT;
    x_line_tbl(l_count).MIN_RELEASE_AMOUNT :=
                 l_rec.MIN_RELEASE_AMOUNT;

    x_line_tbl(l_count).BLANKET_MAX_AMOUNT :=
          l_rec.Blanket_Line_Max_Amount;
    x_line_tbl(l_count).BLANKET_MIN_AMOUNT :=
                 l_rec.Blanket_Line_Min_Amount;
    x_line_tbl(l_count).Blanket_Max_Quantity :=
                       l_rec.Blanket_Max_Quantity;
    x_line_tbl(l_count).Blanket_Min_Quantity :=
                      l_rec.Blanket_Min_Quantity;
    x_line_tbl(l_count).OVERRIDE_BLANKET_CONTROLS_FLAG :=
          l_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
    x_line_tbl(l_count).OVERRIDE_RELEASE_CONTROLS_FLAG :=
          l_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
    x_line_tbl(l_count).ENFORCE_PRICE_LIST_FLAG :=
                      l_rec.ENFORCE_PRICE_LIST_FLAG;
    x_line_tbl(l_count).enforce_ship_to_flag :=
                      l_rec.enforce_ship_to_flag;
    x_line_tbl(l_count).enforce_invoice_to_flag :=
                      l_rec.enforce_invoice_to_flag;
    x_line_tbl(l_count).enforce_freight_term_flag :=
                      l_rec.enforce_freight_term_flag;
    x_line_tbl(l_count).enforce_shipping_method_flag :=
                      l_rec.enforce_shipping_method_flag;
    x_line_tbl(l_count).enforce_payment_term_flag :=
                      l_rec.enforce_payment_term_flag;
    x_line_tbl(l_count).enforce_accounting_rule_flag :=
                      l_rec.enforce_accounting_rule_flag;
    x_line_tbl(l_count).enforce_invoicing_rule_flag :=
                      l_rec.enforce_invoicing_rule_flag;
    x_line_tbl(l_count).ORDER_QUANTITY_UOM :=   l_rec.ORDER_QUANTITY_UOM;
    x_line_tbl(l_count).RELEASED_QUANTITY :=  l_rec.RELEASED_QUANTITY;
    x_line_tbl(l_count).FULFILLED_QUANTITY  :=  l_rec.FULFILLED_QUANTITY;
    x_line_tbl(l_count).RETURNED_QUANTITY :=  l_rec.RETURNED_QUANTITY;
    x_line_tbl(l_count).order_number :=  l_rec.order_number;
    x_line_tbl(l_count).fulfilled_amount :=  l_rec.fulfilled_amount;
    x_line_tbl(l_count).returned_amount := l_rec.returned_amount;
-- hashraf ... start of pack J
    x_line_tbl(l_count).transaction_phase_code := l_rec.transaction_phase_code;
    x_line_tbl(l_count).source_document_version_number := l_rec.source_document_version_number;
-- hashraf ... end of pack J
    x_line_tbl(l_count).qp_list_line_id :=  l_rec.qp_list_line_id;
    -- 11i10 Pricing Changes Start
    x_line_tbl(l_count).modifier_list_line_id :=  l_rec.modifier_list_line_id;
    IF x_line_tbl(l_count).modifier_list_line_id IS NOT NULL THEN

        --For bug 3553063.Catching No_Data_Found for the query
        BEGIN
           select decode(arithmetic_operator,'%',operand,null)
                ,decode(arithmetic_operator,'AMT',operand,null)
           into x_line_tbl(l_count).discount_percent
               ,x_line_tbl(l_count).discount_amount
           from qp_list_lines
           where list_line_id = x_line_tbl(l_count).modifier_list_line_id;
        EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 Null;
        END;
    END IF;
    -- 11i10 Pricing Changes End
	   x_line_tbl(l_count).db_flag 		:= FND_API.G_TRUE;
	   l_count := l_count + 1;

    END LOOP;

  ELSE

    --  Loop over fetched records

    l_count := 1;

    FOR l_rec IN l_line_hist_csr LOOP

        x_line_tbl(l_count).accounting_rule_id  := l_rec.ACCOUNTING_RULE_ID;
        x_line_tbl(l_count).agreement_id        := l_rec.AGREEMENT_ID;
        x_line_tbl(l_count).attribute1          := l_rec.ATTRIBUTE1;
        x_line_tbl(l_count).attribute10         := l_rec.ATTRIBUTE10;
        x_line_tbl(l_count).attribute11         := l_rec.ATTRIBUTE11;
        x_line_tbl(l_count).attribute12         := l_rec.ATTRIBUTE12;
        x_line_tbl(l_count).attribute13         := l_rec.ATTRIBUTE13;
        x_line_tbl(l_count).attribute14         := l_rec.ATTRIBUTE14;
        x_line_tbl(l_count).attribute15         := l_rec.ATTRIBUTE15;
        x_line_tbl(l_count).attribute16         := l_rec.ATTRIBUTE16;
        x_line_tbl(l_count).attribute17         := l_rec.ATTRIBUTE17;
        x_line_tbl(l_count).attribute18         := l_rec.ATTRIBUTE18;
        x_line_tbl(l_count).attribute19         := l_rec.ATTRIBUTE19;
        x_line_tbl(l_count).attribute20         := l_rec.ATTRIBUTE20;
        x_line_tbl(l_count).attribute2          := l_rec.ATTRIBUTE2;
        x_line_tbl(l_count).attribute3          := l_rec.ATTRIBUTE3;
        x_line_tbl(l_count).attribute4          := l_rec.ATTRIBUTE4;
        x_line_tbl(l_count).attribute5          := l_rec.ATTRIBUTE5;
        x_line_tbl(l_count).attribute6          := l_rec.ATTRIBUTE6;
        x_line_tbl(l_count).attribute7          := l_rec.ATTRIBUTE7;
        x_line_tbl(l_count).attribute8          := l_rec.ATTRIBUTE8;
        x_line_tbl(l_count).attribute9          := l_rec.ATTRIBUTE9;
        x_line_tbl(l_count).context             := l_rec.CONTEXT;

        x_line_tbl(l_count).created_by          := l_rec.CREATED_BY;
        x_line_tbl(l_count).creation_date       := l_rec.CREATION_DATE;
        x_line_tbl(l_count).cust_po_number      := l_rec.CUST_PO_NUMBER;
        x_line_tbl(l_count).deliver_to_org_id   := l_rec.DELIVER_TO_ORG_ID;
        x_line_tbl(l_count).freight_terms_code  := l_rec.FREIGHT_TERMS_CODE;
        x_line_tbl(l_count).header_id  := l_rec.header_id;
        x_line_tbl(l_count).min_release_quantity  := l_rec.min_release_quantity;
        x_line_tbl(l_count).max_release_quantity  := l_rec.max_release_quantity;
        x_line_tbl(l_count).inventory_item_id   := l_rec.INVENTORY_ITEM_ID;
        x_line_tbl(l_count).invoice_to_org_id   := l_rec.INVOICE_TO_ORG_ID;
        x_line_tbl(l_count).invoicing_rule_id   := l_rec.INVOICING_RULE_ID;
        x_line_tbl(l_count).ordered_item_id             := l_rec.ORDERED_ITEM_ID;
        x_line_tbl(l_count).item_identifier_type := l_rec.item_identifier_type;
        x_line_tbl(l_count).lock_control := NULL; --l_rec.lock_control;

        x_line_tbl(l_count).ordered_item          := l_rec.ORDERED_ITEM;
        x_line_tbl(l_count).item_type_code      := l_rec.ITEM_TYPE_CODE;
        x_line_tbl(l_count).last_updated_by     := l_rec.LAST_UPDATED_BY;
        x_line_tbl(l_count).last_update_date    := l_rec.LAST_UPDATE_DATE;
        x_line_tbl(l_count).last_update_login   := l_rec.LAST_UPDATE_LOGIN;
        x_line_tbl(l_count).line_id := l_rec.line_id;
        x_line_tbl(l_count).line_number  := l_rec.line_number;
        x_line_tbl(l_count).payment_term_id     := l_rec.PAYMENT_TERM_ID;
        x_line_tbl(l_count).preferred_grade     := l_rec.PREFERRED_GRADE;  -- OPM
        x_line_tbl(l_count).price_list_id       := l_rec.PRICE_LIST_ID;
        x_line_tbl(l_count).program_application_id := l_rec.PROGRAM_APPLICATION_ID;
        x_line_tbl(l_count).program_id          := l_rec.PROGRAM_ID;
        x_line_tbl(l_count).program_update_date := l_rec.PROGRAM_UPDATE_DATE;
        x_line_tbl(l_count).request_id          := l_rec.REQUEST_ID;
         x_line_tbl(l_count).salesrep_id      := l_rec.SALESREP_ID;
         x_line_tbl(l_count).released_amount  := l_rec.released_amount;
        x_line_tbl(l_count).shipping_method_code := l_rec.SHIPPING_METHOD_CODE;
        x_line_tbl(l_count).ship_from_org_id    := l_rec.ship_from_org_id;
        x_line_tbl(l_count).ship_to_org_id      := l_rec.SHIP_TO_ORG_ID;
        x_line_tbl(l_count).shipping_instructions := l_rec.shipping_instructions;
        x_line_tbl(l_count).packing_instructions := l_rec.packing_instructions;
    x_line_tbl(l_count).start_Date_active :=   l_rec.START_DATE_ACTIVE;
    x_line_tbl(l_count).END_DATE_ACTIVE :=   l_rec.END_DATE_ACTIVE;
    x_line_tbl(l_count).MAX_RELEASE_AMOUNT :=
               l_rec.MAX_RELEASE_AMOUNT;
    x_line_tbl(l_count).MIN_RELEASE_AMOUNT :=
                 l_rec.MIN_RELEASE_AMOUNT;

    x_line_tbl(l_count).BLANKET_MAX_AMOUNT :=
          l_rec.Blanket_Line_Max_Amount;
    x_line_tbl(l_count).BLANKET_MIN_AMOUNT :=
                 l_rec.Blanket_Line_Min_Amount;
    x_line_tbl(l_count).Blanket_Max_Quantity :=
                       l_rec.Blanket_Max_Quantity;
    x_line_tbl(l_count).Blanket_Min_Quantity :=
                      l_rec.Blanket_Min_Quantity;
    x_line_tbl(l_count).OVERRIDE_BLANKET_CONTROLS_FLAG :=
          l_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
    x_line_tbl(l_count).OVERRIDE_RELEASE_CONTROLS_FLAG :=
          l_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
    x_line_tbl(l_count).ENFORCE_PRICE_LIST_FLAG :=
                      l_rec.ENFORCE_PRICE_LIST_FLAG;
    x_line_tbl(l_count).enforce_ship_to_flag :=
                      l_rec.enforce_ship_to_flag;
    x_line_tbl(l_count).enforce_invoice_to_flag :=
                      l_rec.enforce_invoice_to_flag;
    x_line_tbl(l_count).enforce_freight_term_flag :=
                      l_rec.enforce_freight_term_flag;
    x_line_tbl(l_count).enforce_shipping_method_flag :=
                      l_rec.enforce_shipping_method_flag;
    x_line_tbl(l_count).enforce_payment_term_flag :=
                      l_rec.enforce_payment_term_flag;
    x_line_tbl(l_count).enforce_accounting_rule_flag :=
                      l_rec.enforce_accounting_rule_flag;
    x_line_tbl(l_count).enforce_invoicing_rule_flag :=
                      l_rec.enforce_invoicing_rule_flag;
    x_line_tbl(l_count).ORDER_QUANTITY_UOM :=   l_rec.ORDER_QUANTITY_UOM;
    x_line_tbl(l_count).RELEASED_QUANTITY :=  l_rec.RELEASED_QUANTITY;
    x_line_tbl(l_count).FULFILLED_QUANTITY  :=  l_rec.FULFILLED_QUANTITY;
    x_line_tbl(l_count).RETURNED_QUANTITY :=  l_rec.RETURNED_QUANTITY;
    x_line_tbl(l_count).order_number :=  l_rec.order_number;
    x_line_tbl(l_count).fulfilled_amount :=  l_rec.fulfilled_amount;
    x_line_tbl(l_count).returned_amount := l_rec.returned_amount;
-- hashraf ... start of pack J
    x_line_tbl(l_count).transaction_phase_code := l_rec.transaction_phase_code;
    x_line_tbl(l_count).source_document_version_number := l_rec.source_document_version_number;
-- hashraf ... end of pack J
    x_line_tbl(l_count).qp_list_line_id :=  l_rec.qp_list_line_id;
    -- 11i10 Pricing Changes Start
    x_line_tbl(l_count).modifier_list_line_id :=  l_rec.modifier_list_line_id;
    IF x_line_tbl(l_count).modifier_list_line_id IS NOT NULL THEN

       --For bug 3553063.Catching No_Data_Found for the query
       BEGIN
          select decode(arithmetic_operator,'%',operand,null)
                ,decode(arithmetic_operator,'AMT',operand,null)
          into x_line_tbl(l_count).discount_percent
               ,x_line_tbl(l_count).discount_amount
          from qp_list_lines
          where list_line_id = x_line_tbl(l_count).modifier_list_line_id;
       EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 Null;
       END;
    END IF;
    -- 11i10 Pricing Changes End
	   x_line_tbl(l_count).db_flag 		:= FND_API.G_TRUE;
	   l_count := l_count + 1;

    END LOOP;

  END IF;

    --  PK sent and no rows found

    IF
    p_line_id IS NOT NULL
    AND
    x_line_tbl.COUNT = 0
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table
   if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_LINE_UTIL.QUERY_ROWS', 1);
   end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
	   RAISE NO_DATA_FOUND;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Lines;

PROCEDURE Query_blanket
(p_header_id           IN NUMBER
,p_version_number      IN NUMBER := NULL
,p_phase_change_flag   IN VARCHAR2 := NULL
,p_x_header_rec        IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
,p_x_line_tbl          IN OUT NOCOPY OE_Blanket_PUB.line_tbl_type
,x_return_status       OUT NOCOPY VARCHAR2
)IS
l_return_status varchar2(1);
l_version_number NUMBER := p_version_number;
l_current_version_number NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_version_number IS NOT NULL THEN
    SELECT  /* MOAC_SQL_CHANGE */ version_number INTO l_current_version_number FROM OE_BLANKET_HEADERS_ALL WHERE header_id = p_header_id;

    IF l_version_number >= l_current_version_number THEN
      l_version_number := NULL;
    END IF;
   END IF;

   Query_Header(P_header_id => p_header_id ,
                p_version_number => l_version_number,
                p_phase_change_flag => p_phase_change_flag,
		x_header_rec => p_x_header_rec,
                x_return_status => l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
   END IF;

   Query_Lines(P_header_id => p_header_id ,
               p_version_number => l_version_number,
               p_phase_change_flag => p_phase_change_flag,
	       x_line_tbl => p_x_line_tbl ,
               x_return_status => l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Blanket'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Blanket;

FUNCTION Query_Row
(   p_line_id                       NUMBER
   ,p_version_number                NUMBER := NULL
   ,p_phase_change_flag             VARCHAR2 := NULL
) RETURN OE_Blanket_PUB.Line_Rec_Type
IS
l_return_status varchar2(1);
l_line_tbl               OE_Blanket_PUB.Line_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    Query_Lines
        (   p_line_id                     => p_line_id
           ,   p_version_number             => p_version_number
           ,   p_phase_change_flag          => p_phase_change_flag
           ,   x_line_tbl                    => l_line_tbl
           ,   x_return_status              => l_return_status
        );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      RETURN l_line_tbl(1);
    END IF;
END Query_Row;

--Currently lock row will lock blanket values by blanket only
PROCEDURE Lock_Row
(   x_return_status             OUT NOCOPY VARCHAR2
,   p_blanket_id                IN NUMBER
,   p_blanket_line_id           IN NUMBER
,   p_x_lock_control            IN OUT NOCOPY NUMBER
,   x_msg_count                 OUT NOCOPY NUMBER
,   x_msg_data                  OUT NOCOPY VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_BLANKET_UTIL.LOCK_ROW', 1);
   end if;

    OE_MSG_PUB.initialize;

    Lock_Blanket
    (   x_return_status      => l_return_status
    ,   p_blanket_id         => p_blanket_id
    ,   p_blanket_line_id    => p_blanket_line_id
    ,   p_x_lock_control     => p_x_lock_control
    );

    --  Set return status.

    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

   if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_BLANKET_UTIL.LOCK_ROW', 1);
   end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
         );
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Row;



--Currently lock blanket will lock blanket values by blanket only
PROCEDURE Lock_Blanket
(   x_return_status             OUT NOCOPY VARCHAR2
,   p_blanket_id                IN NUMBER
,   p_blanket_line_id           IN NUMBER
,   p_x_lock_control            IN OUT NOCOPY NUMBER
)
IS
     l_blanket_id		      NUMBER;
     l_blanket_line_id                NUMBER;
     l_is_line_lock_control           BOOLEAN;
     l_lock_control                   NUMBER;
     l_db_lock_control                NUMBER;
     l_temp_lock_control              NUMBER;

CURSOR c_blanket_header IS
  SELECT  /* MOAC_SQL_CHANGE */ bh.lock_control
    FROM OE_BLANKET_HEADERS_ALL BH, OE_BLANKET_HEADERS_EXT BHX
   WHERE BH.ORDER_NUMBER = BHX.ORDER_NUMBER
     AND BH.ORDER_NUMBER = p_blanket_id
     AND ORG_ID = MO_GLOBAL.get_current_org_id
     AND BH.SALES_DOCUMENT_TYPE_CODE = 'B'
     FOR UPDATE NOWAIT;

CURSOR c_blanket_lines IS
  SELECT   /* MOAC_SQL_CHANGE */ bl.line_id, bl.lock_control
    FROM OE_BLANKET_LINES_ALL BL, OE_BLANKET_LINES_EXT BLX
   WHERE BL.LINE_ID = BLX.LINE_ID
     AND BLX.ORDER_NUMBER = l_blanket_id
     AND BL.ORG_ID = MO_GLOBAL.GET_CURRENT_ORG_ID
     AND BL.SALES_DOCUMENT_TYPE_CODE = 'B'
     FOR UPDATE NOWAIT;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


   if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_BLANKET_UTIL.LOCK_BLANKET', 1);
   end if;

    OE_MSG_PUB.initialize;

    SAVEPOINT Lock_Blanket;

    -- Retrieve the primary key.
    IF 	p_blanket_id <> FND_API.G_MISS_NUM THEN
		l_blanket_id := p_blanket_id;
                l_is_line_lock_control := FALSE;
    ELSE
        SELECT ORDER_NUMBER
        INTO   l_blanket_id
        FROM   OE_BLANKET_LINES_EXT
        WHERE  LINE_ID = p_blanket_line_id;

        l_is_line_lock_control := TRUE;
    END IF;

        l_lock_control := p_x_lock_control;

    -- Lock blanket header
    OPEN c_blanket_header;
    FETCH c_blanket_header INTO l_temp_lock_control;
    CLOSE c_blanket_header;

    IF l_is_line_lock_control = FALSE THEN
       l_db_lock_control := l_temp_lock_control;
    END IF;

    -- Lock blanket lines
    OPEN c_blanket_lines;
    LOOP
    FETCH c_blanket_lines INTO l_blanket_line_id, l_temp_lock_control;

    IF l_is_line_lock_control AND
       p_blanket_line_id = l_blanket_line_id THEN
       l_db_lock_control := l_temp_lock_control;
    END IF;
    EXIT WHEN (C_BLANKET_LINES%NOTFOUND);
    END LOOP;
    CLOSE c_blanket_lines;

--    p_x_lock_control := l_db_lock_control;

   if l_debug_level > 0 then
    oe_debug_pub.add('p_x_lock_control'||p_x_lock_control, 3);
--    oe_debug_pub.add('is line lock control'||l_is_line_lock_control, 3);
    oe_debug_pub.add('l_db_lock_control'||l_db_lock_control, 3);
   end if;

   if l_debug_level > 0 then
    oe_debug_pub.add('selected for update, now compare', 3);
   end if;


    -- If lock_control is not passed(is null or missing), then return the locked record.

    IF l_lock_control is null OR
       l_lock_control = FND_API.G_MISS_NUM
    THEN

        --  Set out NOCOPY /* file.sql.39 change */ parameter, out NOCOPY /* file.sql.39 change */ rec is already set by query row.

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;

	RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare the value of lock_control column to DB value.

-- following constants are used to debug lock_order,
-- please do not use them for any other purpose.
-- set G_LOCK_TEST := 'Y', for debugging.

--    OE_GLOBALS.G_LOCK_CONST  := 0;
    --OE_GLOBALS.G_LOCK_TEST := 'Y';
--    OE_GLOBALS.G_LOCK_TEST   := 'N';

    IF OE_GLOBALS.Equal(p_x_lock_control,
                        l_db_lock_control)
      THEN

   if l_debug_level > 0 then
        oe_debug_pub.add('done comparison, success', 1);
   end if;
        --  Row has not changed. Set out NOCOPY /* file.sql.39 change */ parameter.

        --  Set return status

        x_return_status                  := FND_API.G_RET_STS_SUCCESS;

    ELSE

   if l_debug_level > 0 then
        oe_debug_pub.add('row changed by other user', 1);
   end if;

        --  Row has changed by another user.

        x_return_status                  := FND_API.G_RET_STS_ERROR;

	    -- Release the lock

            fnd_message.set_name('ONT','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

    END IF;

   if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_BLANKET_UTIL.LOCK_BLANKET', 1);
   end if;

    OE_GLOBALS.G_LOCK_TEST := 'N';


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;

   if l_debug_level > 0 then
        oe_debug_pub.add('no data found in blanket lock_blanket', 1);
   end if;

            fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        OE_GLOBALS.G_LOCK_TEST := 'N';

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;

   if l_debug_level > 0 then
        oe_debug_pub.add('record_lock in blanket lock_blanket', 1);
   end if;

            fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        OE_GLOBALS.G_LOCK_TEST := 'N';

    WHEN OTHERS THEN

   if l_debug_level > 0 then
        oe_debug_pub.add('others in blanket lock_blanket', 1);
   end if;
        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Blanket'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        OE_GLOBALS.G_LOCK_TEST := 'N';

END Lock_Blanket;


PROCEDURE Default_Attributes
(p_x_header_rec        IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
,x_return_status       OUT NOCOPY VARCHAR2
) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

CURSOR c_contract_template_exist (cp_trans_type_id NUMBER) IS
       SELECT contract_template_id
       FROM   oe_transaction_types_all
       WHERE  transaction_type_id = cp_trans_type_id;

   l_order_type_id                 NUMBER := NULL;
   l_deflt_contract_template_id    NUMBER := NULL;

BEGIN
     x_return_status                := FND_API.G_RET_STS_SUCCESS;

     if l_debug_level > 0 then
        oe_debug_pub.add('Enter Default_Attributes - Header');
        oe_debug_pub.add('operation is : '||p_x_header_rec.operation);
     end if;

     -- Default Blanket Header ID
     IF p_x_header_rec.header_id IS NULL THEN
        SELECT  OE_ORDER_HEADERS_S.NEXTVAL
        INTO    p_x_header_rec.header_id
        FROM    DUAL;
     END IF;

     -- Default Start Date Active
     IF p_x_header_rec.start_Date_active IS NULL THEN
        p_x_header_rec.start_Date_active := trunc(sysdate);
     END IF;

     -- Default Who Columns
     IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
        p_x_header_rec.creation_Date := sysdate;
        p_x_header_rec.created_by := FND_GLOBAL.USER_ID;
     END IF;

     p_x_header_rec.last_update_date := sysdate;
     p_x_header_rec.last_updated_by := FND_GLOBAL.USER_ID;

     -- Default Currency Code
     IF p_x_header_rec.transactional_curr_code IS NULL THEN
     BEGIN
          SELECT CURRENCY_CODE
          INTO    p_x_header_rec.transactional_curr_code
          FROM    OE_GL_SETS_OF_BOOKS_V
          WHERE SET_OF_BOOKS_ID = OE_Sys_Parameters.VALUE('SET_OF_BOOKS_ID');
     EXCEPTION
          WHEN OTHERS THEN
              NULL;
     END;
     END IF;

     -- Default Flags
     IF p_x_header_rec.on_hold_flag IS NULL OR
        p_x_header_rec.on_hold_flag NOT IN ('Y','N') THEN
        p_x_header_rec.on_hold_flag := 'N';
     END IF;
     IF p_x_header_rec.enforce_price_list_flag IS NULL OR
        p_x_header_rec.enforce_price_list_flag NOT IN ('Y','N') THEN
        p_x_header_rec.enforce_price_list_flag := 'N';
     END IF;
     IF p_x_header_rec.enforce_ship_to_flag IS NULL OR
        p_x_header_rec.enforce_ship_to_flag NOT IN ('Y','N') THEN
        p_x_header_rec.enforce_ship_to_flag := 'N';
     END IF;
     IF p_x_header_rec.enforce_invoice_to_flag IS NULL OR
        p_x_header_rec.enforce_invoice_to_flag NOT IN ('Y','N') THEN
        p_x_header_rec.enforce_invoice_to_flag := 'N';
     END IF;
     IF p_x_header_rec.enforce_freight_term_flag IS NULL OR
        p_x_header_rec.enforce_freight_term_flag NOT IN ('Y','N') THEN
        p_x_header_rec.enforce_freight_term_flag := 'N';
     END IF;
     IF p_x_header_rec.enforce_shipping_method_flag IS NULL OR
        p_x_header_rec.enforce_shipping_method_flag NOT IN ('Y','N') THEN
        p_x_header_rec.enforce_shipping_method_flag := 'N';
     END IF;
     IF p_x_header_rec.enforce_payment_term_flag IS NULL OR
        p_x_header_rec.enforce_payment_term_flag NOT IN ('Y','N') THEN
        p_x_header_rec.enforce_payment_term_flag := 'N';
     END IF;
     IF p_x_header_rec.enforce_accounting_rule_flag IS NULL OR
        p_x_header_rec.enforce_accounting_rule_flag NOT IN ('Y','N') THEN
        p_x_header_rec.enforce_accounting_rule_flag := 'N';
     END IF;
     IF p_x_header_rec.enforce_invoicing_rule_flag IS NULL OR
        p_x_header_rec.enforce_invoicing_rule_flag NOT IN ('Y','N') THEN
        p_x_header_rec.enforce_invoicing_rule_flag := 'N';
     END IF;

     IF p_x_header_rec.override_amount_flag IS NULL OR
        p_x_header_rec.override_amount_flag NOT IN ('Y','N') THEN
        p_x_header_rec.override_amount_flag := 'N';
     END IF;

     IF p_x_header_rec.order_type_id IS NULL THEN
        p_x_header_rec.order_type_id := FND_PROFILE.VALUE('OE_DEFAULT_BLANKET_ORDER_TYPE');
     END IF;

     IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
        -- Revision Number
        p_x_header_rec.version_number := 0.0;
        -- Operating unit
        -- <R12.MOAC> START
        --p_x_header_rec.org_id := to_number(FND_PROFILE.VALUE('ORG_ID'));
        -- <R12.MOAC> END

        -- Default of Transaction Phase.
        IF oe_code_control.get_code_release_level >= '110510' THEN

           IF p_x_header_rec.transaction_phase_code IS NULL THEN
              p_x_header_rec.transaction_phase_code :=
                      fnd_profile.value('ONT_DEF_BSA_TRANSACTION_PHASE');
              IF p_x_header_rec.transaction_phase_code IS NULL  AND
                 p_x_header_rec.order_type_id IS NOT NULL THEN
                 -- Get The Transaciton Phase from the Order Type if any.
                 Begin
                    Select  /* MOAC_SQL_CHANGE */ DEF_TRANSACTION_PHASE_CODE
                    INTO   p_x_header_rec.transaction_phase_code
                    from  oe_transaction_types_all
                    where TRANSACTION_TYPE_ID = p_x_header_rec.order_type_id;
                 Exception
                    when no_data_found then
                       null;
                    when OTHERS then
                       null;
                 End;
              END IF;
           END IF; -- End of Default Transaction Phase

           p_x_header_rec.draft_submitted_flag := 'N';

        END IF;  -- End of Code Level Check


        --ABH
        --default the contract template id
         IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
            NULL;
            -- << place logic here  >>
            -- << p_x_header_rec.contract_template_id := <defaulted contract_template_id >        >>
            l_order_type_id := p_x_header_rec.order_type_id;

            IF c_contract_template_exist%ISOPEN THEN
               CLOSE c_contract_template_exist;
            END IF;
            OPEN c_contract_template_exist (l_order_type_id);
            FETCH c_contract_template_exist INTO l_deflt_contract_template_id;
            CLOSE c_contract_template_exist;

            p_x_header_rec.contract_template_id := l_deflt_contract_template_id;


         END IF;
        --ABH

     END IF; -- End if operation = CREATE

EXCEPTION
     WHEN OTHERS THEN
     x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes - Header'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Default_Attributes;

PROCEDURE Default_Attributes
(p_x_line_rec               IN OUT NOCOPY OE_Blanket_PUB.line_rec_type
,p_default_from_header      IN BOOLEAN
,x_return_status            OUT NOCOPY VARCHAR2
) IS
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     x_return_status                := FND_API.G_RET_STS_SUCCESS;

     -- Load Header
     Load_Header(p_header_id => p_x_line_rec.header_id
                 ,x_return_status => l_return_status);
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Get Blanket Line
     IF p_x_line_rec.line_id IS NULL THEN
       SELECT  OE_ORDER_LINES_S.NEXTVAL
       INTO    p_x_line_rec.line_id
       FROM    DUAL;
     END IF;

     -- Get Blanket Line Number
     IF p_x_line_rec.line_number IS NULL THEN
          SELECT  NVL(MAX(line_number)+1,1)
          INTO    p_x_line_rec.line_number
          FROM    OE_BLANKET_LINES
          WHERE   header_id = p_x_line_rec.header_id;
     END IF;

     -- Constant Defaults
     IF p_x_line_rec.override_blanket_controls_flag IS NULL OR
        p_x_line_rec.override_blanket_controls_flag NOT IN ('Y','N') THEN
        p_x_line_rec.override_blanket_controls_flag := 'N';
     END IF;

     IF p_x_line_rec.override_release_controls_flag IS NULL OR
        p_x_line_rec.override_release_controls_flag NOT IN ('Y','N') THEN
        p_x_line_rec.override_release_controls_flag := 'N';
     END IF;

     IF p_x_line_rec.item_identifier_type is  NULL THEN
        p_x_line_rec.item_identifier_type := 'INT';
     END IF;

     IF p_x_line_rec.order_quantity_uom is NULL AND
        p_x_line_rec.item_identifier_type NOT IN ('ALL', 'CAT') THEN
          BEGIN
            SELECT PRIMARY_UOM_CODE
            INTO   p_x_line_rec.order_quantity_uom
            FROM   MTL_SYSTEM_ITEMS_B
            WHERE  INVENTORY_ITEM_ID = p_x_line_rec.inventory_item_id
            AND    ORGANIZATION_ID = g_header_rec.org_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
             if l_debug_level > 0 then
              oe_debug_pub.add('no inventory item exists for this organization');
             end if;
          END;
     END IF;

     IF p_x_line_rec.pricing_uom is NULL AND
        p_x_line_rec.order_quantity_uom is NOT NULL THEN
        p_x_line_rec.pricing_uom := p_x_line_rec.order_quantity_uom;
     END IF;

     IF p_x_line_rec.item_identifier_type = 'ALL' THEN
        p_x_line_rec.inventory_item_id := NULL;
     END IF;

     --Always default order_number
     IF p_x_line_rec.order_number IS NULL THEN
        p_x_line_rec.order_number:= g_header_rec.order_number;
     END IF;

  IF p_default_from_header THEN

     -- Default from header
     IF p_x_line_rec.cust_po_number IS NULL THEN
        p_x_line_rec.cust_po_number := g_header_rec.cust_po_number;
     END IF;
     IF p_x_line_rec.price_list_id IS NULL THEN
        p_x_line_rec.price_list_id := g_header_rec.price_list_id;
     END IF;

     IF p_x_line_rec.enforce_price_list_flag IS NULL OR
        p_x_line_rec.enforce_price_list_flag NOT IN ('Y','N') THEN
        p_x_line_rec.enforce_price_list_flag :=
                            g_header_rec.enforce_price_list_flag;
     END IF;
     IF p_x_line_rec.enforce_ship_to_flag IS NULL OR
        p_x_line_rec.enforce_ship_to_flag NOT IN ('Y','N') THEN
        p_x_line_rec.enforce_ship_to_flag :=
                            g_header_rec.enforce_ship_to_flag;
     END IF;
     IF p_x_line_rec.enforce_invoice_to_flag IS NULL OR
        p_x_line_rec.enforce_invoice_to_flag NOT IN ('Y','N') THEN
        p_x_line_rec.enforce_invoice_to_flag :=
                            g_header_rec.enforce_invoice_to_flag;
     END IF;
     IF p_x_line_rec.enforce_freight_term_flag IS NULL OR
        p_x_line_rec.enforce_freight_term_flag NOT IN ('Y','N') THEN
        p_x_line_rec.enforce_freight_term_flag :=
                            g_header_rec.enforce_freight_term_flag;
     END IF;
     IF p_x_line_rec.enforce_shipping_method_flag IS NULL OR
        p_x_line_rec.enforce_shipping_method_flag NOT IN ('Y','N') THEN
        p_x_line_rec.enforce_shipping_method_flag :=
                            g_header_rec.enforce_shipping_method_flag;
     END IF;
     IF p_x_line_rec.enforce_payment_term_flag IS NULL OR
        p_x_line_rec.enforce_payment_term_flag NOT IN ('Y','N') THEN
        p_x_line_rec.enforce_payment_term_flag :=
                            g_header_rec.enforce_payment_term_flag;
     END IF;
     IF p_x_line_rec.enforce_accounting_rule_flag IS NULL OR
        p_x_line_rec.enforce_accounting_rule_flag NOT IN ('Y','N') THEN
        p_x_line_rec.enforce_accounting_rule_flag :=
                            g_header_rec.enforce_accounting_rule_flag;
     END IF;
     IF p_x_line_rec.enforce_invoicing_rule_flag IS NULL OR
        p_x_line_rec.enforce_invoicing_rule_flag NOT IN ('Y','N') THEN
        p_x_line_rec.enforce_invoicing_rule_flag :=
                            g_header_rec.enforce_invoicing_rule_flag;
     END IF;
     IF p_x_line_rec.ship_from_org_id IS NULL THEN
        p_x_line_rec.ship_from_org_id := g_header_rec.ship_from_org_id;
     END IF;
     --sold to org is defaulted for org validations (ship to, deliver to, bill to)
     IF p_x_line_rec.sold_to_org_id IS NULL THEN
        p_x_line_rec.sold_to_org_id := g_header_rec.sold_to_org_id;
     END IF;
     IF p_x_line_rec.ship_to_org_id IS NULL THEN
        p_x_line_rec.ship_to_org_id := g_header_rec.ship_to_org_id;
     END IF;
     IF p_x_line_rec.invoice_to_org_id IS NULL THEN
        p_x_line_rec.invoice_to_org_id := g_header_rec.invoice_to_org_id;
     END IF;
     IF p_x_line_rec.deliver_to_org_id IS NULL THEN
        p_x_line_rec.deliver_to_org_id := g_header_rec.deliver_to_org_id;
     END IF;
     IF p_x_line_rec.payment_term_id IS NULL THEN
        p_x_line_rec.payment_term_id := g_header_rec.payment_term_id;
     END IF;
     IF p_x_line_rec.invoicing_rule_id IS NULL THEN
        p_x_line_rec.invoicing_rule_id := g_header_rec.invoicing_rule_id;
     END IF;
     IF p_x_line_rec.shipping_method_code IS NULL THEN
        p_x_line_rec.shipping_method_code := g_header_rec.shipping_method_code;
     END IF;
     IF p_x_line_rec.accounting_rule_id IS NULL THEN
        p_x_line_rec.accounting_rule_id := g_header_rec.accounting_rule_id;
     END IF;
     IF p_x_line_rec.shipping_instructions IS NULL THEN
        p_x_line_rec.shipping_instructions :=
                     g_header_rec.shipping_instructions;
     END IF;
     IF p_x_line_rec.packing_instructions IS NULL THEN
        p_x_line_rec.packing_instructions := g_header_rec.packing_instructions;
     END IF;
     IF p_x_line_rec.freight_terms_code IS NULL THEN
        p_x_line_rec.freight_terms_code := g_header_rec.freight_terms_code;
     END IF;
     IF p_x_line_rec.salesrep_id IS NULL THEN
        p_x_line_rec.salesrep_id := g_header_rec.salesrep_id;
     END IF;
     IF p_x_line_rec.start_date_active IS NULL THEN
        p_x_line_rec.start_date_active := g_header_rec.start_date_active;
     END IF;
     IF p_x_line_rec.end_date_active IS NULL THEN
        p_x_line_rec.end_date_active := g_header_rec.end_date_active;
     END IF;
     -- Start of Transaction Phase changes for 11i10.
     IF p_x_line_rec.Transaction_Phase_code IS NULL THEN
        p_x_line_rec.Transaction_Phase_code := g_header_rec.Transaction_Phase_code;
     END IF;
     -- End of Transaction Phase changes.
     -- 11i10 Pricing Changes Start
     IF p_x_line_rec.discount_percent IS NULL THEN
        p_x_line_rec.discount_percent := g_header_rec.default_discount_percent;
     END IF;
     IF p_x_line_rec.discount_amount IS NULL THEN
        p_x_line_rec.discount_amount := g_header_rec.default_discount_amount;
     END IF;
     -- 11i10 Pricing Changes End
   END IF; --if default from header

     -- WHO columns
     IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
        p_x_line_rec.creation_Date := sysdate;
        p_x_line_rec.created_by := FND_GLOBAL.USER_ID;
     END IF;
     p_x_line_rec.last_update_date := sysdate;
     p_x_line_rec.last_updated_by := FND_GLOBAL.USER_ID;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN OTHERS THEN
        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes - Line'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Default_Attributes;

PROCEDURE Load_Header(p_header_id IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2)
IS
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF g_header_rec.header_id is NULL
           OR g_header_rec.header_id <> p_header_id
        THEN
		Query_Header(p_header_id => p_header_id,
			     x_header_rec => g_header_rec,
                             x_return_status => l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
              END IF;

        END IF;
EXCEPTION
     WHEN OTHERS THEN
        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Load Header'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Header;

PROCEDURE GET_ORDER_NUMBER(
          p_x_header_rec     IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
	  x_return_status    OUT NOCOPY varchar2)
IS

	l_order_number    		VARCHAR2(30):= NULL;
	x_doc_sequence_value     	NUMBER;
	x_doc_category_code      	VARCHAR(30);
	X_doc_sequence_id       	NUMBER;
	X_db_sequence_name      	VARCHAR2(50);
	x_doc_sequence_type 		CHAR(1);
	X_doc_sequence_name 		VARCHAR2(240);
	X_Prd_Tbl_Name			VARCHAR2(240) ;
	X_Aud_Tbl_Name 			VARCHAR2(240);
	X_Msg_Flag 			VARCHAR2(240);
	X_set_Of_Books_id       	NUMBER;
	seqassid                	INTEGER;
	l_ord_num_src_id    		NUMBER	:= NULL;
	l_order_number_csr  		INTEGER;
	l_result	  		INTEGER;
	l_select_stmt	   	 	VARCHAR2(240);
	l_column_name	    		VARCHAR2(80);
	t 		   		VARCHAR2(240);
	l_return_status	    		VARCHAR2(30);
	X_trx_date         		DATE;
	lcount 				NUMBER;
	x_result 			NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
	oe_debug_pub.add('Entering OR_BLANKET_UTIL.Get_Order_Number',1);
   end if;

	--x_header_rec := p_header_rec;
	 x_return_status     := FND_API.G_RET_STS_SUCCESS;

	x_Set_Of_Books_Id := OE_Sys_Parameters.VALUE('SET_OF_BOOKS_ID');

    	IF p_x_header_rec.order_type_id IS NOT NULL THEN
		x_doc_category_code := p_x_header_rec.order_type_id;

   if l_debug_level > 0 then
    	oe_debug_pub.ADD('before calling get_seq_info ', 2);
 	oe_debug_pub.ADD('Category Code'||x_doc_category_code, 3);
    	oe_debug_pub.ADD('Set of Books'||x_set_of_books_id, 3);
   end if;
        x_result :=   fnd_seqnum.get_seq_info(
                                             660,
                                             x_doc_category_code,
                                             x_set_of_books_id,
                                             null,
                                             sysdate,
                                             X_doc_sequence_id,
					     x_doc_sequence_type,
					     x_doc_sequence_name,
                                             X_db_sequence_name,
        				     seqassid,
					     X_Prd_Tbl_Name,
					     X_Aud_Tbl_Name,
					     X_Msg_Flag
					 );

   if l_debug_level > 0 then
    	oe_debug_pub.ADD('after calling get_seq_info ', 2);
   end if;

   		IF x_result <>  FND_SEQNUM.SEQSUCC   THEN
    		IF x_result = FND_SEQNUM.NOTUSED THEN
    			fnd_message.set_name('ONT','OE_MISS_DOC_SEQ');
    			OE_MSG_PUB.Add;
    			RAISE FND_API.G_EXC_ERROR;
    		END IF;

   		END IF;
		t := x_doc_sequence_type;

    	  IF ( t = 'A')  THEN --automatic numbering


             X_result := fnd_seqnum.get_seq_val(
                                                660,
                                                x_doc_category_code,
                                                x_set_of_books_id,
                                                null,
                                                sysdate,
                                                x_doc_sequence_value,
                                                X_doc_sequence_id,
					        'Y',
					        'Y');
   			IF x_result <>  0   THEN
    			RAISE FND_API.G_EXC_ERROR;
   			END IF;

   if l_debug_level > 0 then
    		oe_debug_pub.ADD('fndseqresult'||to_char(x_result), 2);
    		oe_debug_pub.ADD('fndseqtype'||x_doc_sequence_value, 2);
   end if;
    		p_x_header_rec.order_number :=  x_doc_sequence_value;
   		--ELSIF (t = 'M') THEN
	  ELSE
                SELECT meaning
                INTO l_column_name
                FROM fnd_lookups
                WHERE lookup_type = 'SEQUENCE_METHOD'
                AND lookup_code = t;
	 		fnd_message.set_name('ONT','OE_BLKT_INVALID_DOC_SEQ');
                        fnd_message.set_token('Document Sequence', l_column_name);
          	  	OE_MSG_PUB.Add;

	 		RAISE FND_API.G_EXC_ERROR;
	--	x_doc_sequence_value := p_x_header_rec.order_number;
	--   	     	NULL;
   	  END IF;

		Select Count(header_id) into
		lcount  From
		OE_BLANKET_HEADERS_ALL
		WHERE order_number =  X_doc_sequence_value;

		IF  lcount > 0 THEN
	 		fnd_message.set_name('ONT','OE_BLKT_NUM_EXISTS');
       	  	OE_MSG_PUB.Add;
	 		RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF; -- Blanket category code not null

   if l_debug_level > 0 then
	oe_debug_pub.add('Exiting OR_BLANKET_UTIL.Get_Order_Number',1);
   end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	 x_return_status     := FND_API.G_RET_STS_ERROR;
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Get blanket Number-Exp exception ', 1);
   end if;
     RAISE FND_API.G_EXC_ERROR;


    WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Get blanket Number-exception ', 1);
   end if;

	 x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Order_Number'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Order_Number;

PROCEDURE Process_Object(x_return_status OUT NOCOPY VARCHAR2) IS
l_valid varchar2(1);
lcount number ;
I number;
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

lx_return_status         VARCHAR2(1)           := FND_API.G_RET_STS_SUCCESS;
lx_msg_count             NUMBER                := 0;
lx_msg_data              VARCHAR2(2000);


BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Process Header requests

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_BLANKET_PUB.G_ENTITY_BLANKET_HEADER
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

-- Process Line Level Request

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_BLANKET_PUB.G_ENTITY_BLANKET_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


     IF oe_code_control.get_code_release_level >= '110510' and
          G_Header_Rec.operation = OE_GLOBALS.G_OPR_CREATE  THEN
                   oe_debug_pub.ADD('Create and Start Flow srini : '||G_Header_Rec.operation) ;
                        oe_blanket_wf_util.create_and_start_flow(
                                            p_header_id => G_header_rec.header_id,
                                            p_transaction_phase_code => G_header_rec.transaction_phase_code,
                                            p_blanket_number => G_header_rec.order_number,
                                            x_return_status => l_return_status,
                                            x_msg_count     => lx_msg_count,
                                            x_msg_data      => lx_msg_Data);
             IF lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.ADD('OE_Blanket_Util.Process_Object unexp error in  Create and Start flow ', 1);
                 end if;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF lx_return_status = FND_API.G_RET_STS_ERROR THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.ADD('OE_Blanket_Util.Process_Object exc error in Create and Start Flow ', 1);
                 end if;
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

     end if;

-- moved instantiate call after create_and_start_flow procedure for bug 3691452

-- Instantiate the contract template id against the BSA if new record      --ABH
     IF G_Header_Rec.operation = OE_GLOBALS.G_OPR_CREATE AND
        OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
        -- Do not instantiate for copied orders
        AND nvl(g_header_rec.source_document_type_id,-1) <> 2
     THEN

        OE_CONTRACTS_UTIL.instantiate_doc_terms (
             p_api_version         =>  1.0,
             p_commit              => FND_API.G_TRUE,

             p_template_id         => G_Header_Rec.contract_template_id,
             p_doc_type            => 'B',
             p_doc_id              => G_Header_Rec.header_id,
             p_doc_start_date      => G_Header_Rec.start_date_active,
             p_doc_number          => G_Header_Rec.order_number,

             x_return_status       => lx_return_status,
             x_msg_count           => lx_msg_count,
             x_msg_data            => lx_msg_data
        );

       IF lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.ADD('OE_Blanket_Util.Process_Object unexp error in inst. doc terms ', 1);
                 end if;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF lx_return_status = FND_API.G_RET_STS_ERROR THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.ADD('OE_Blanket_Util.Process_Object exc error in inst. doc terms ', 1);
                 end if;
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     IF OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
        OE_GLOBALS.G_ROLL_VERSION <> 'N' AND
        Not OE_GLOBALS.Equal(G_Header_Rec.operation, OE_GLOBALS.G_OPR_CREATE) THEN
           OE_Versioning_Util.Perform_Versioning(p_header_id => g_header_rec.header_id,
                                   p_document_type => 'BLANKETS',
                                   x_msg_count => lx_msg_count,
                                   x_msg_data => lx_msg_data,
                                   x_return_status => l_return_status);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.ADD('OE_Blanket_Util.Process_Object unexp error in perform versioning ', 1);
                 end if;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.ADD('OE_Blanket_Util.Process_Object exc error in perform versioning ', 1);
                 end if;
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

             OE_Contracts_Util.Version_Articles(p_api_version => 1.0,
                          p_doc_type => OE_Contracts_Util.G_BSA_DOC_TYPE,
                          p_doc_id => g_old_header_hist_rec.header_id,
                          p_version_number => g_old_header_hist_rec.version_number,
                          x_return_status => lx_return_status,
                          x_msg_data => lx_msg_data,
                          x_msg_count => lx_msg_count);


       IF lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.ADD('OE_Blanket_Util.Process_Object unexp error in perform versioning ', 1);
                 end if;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF lx_return_status = FND_API.G_RET_STS_ERROR THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.ADD('OE_Blanket_Util.Process_Object exc error in perform versioning ', 1);
                 end if;
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     g_old_version_captured := FALSE;
     G_Header_Rec.operation := OE_GLOBALS.G_OPR_NONE;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     OE_Delayed_Requests_PVT.Clear_Request(lx_return_status); --bug 4691643
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    OE_Delayed_Requests_PVT.Clear_Request(lx_return_status); --bug 4691643
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
    OE_Delayed_Requests_PVT.Clear_Request(lx_return_status); --bug 4691643
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
           ,'Process Object'
         );
      END IF;

END Process_Object;

PROCEDURE VALIDATE_LINE_NUMBER
(p_req_ind                IN NUMBER
,x_return_status          OUT NOCOPY VARCHAR2
)
IS
l_valid varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param2 < 1 THEN
      l_valid := 'N';
  ELSE
	BEGIN
           SELECT 'N'
           INTO   l_valid
           FROM   oe_blanket_lines L
           WHERE  L.line_number =
		oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param2
           AND    L.header_id =
		 oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param1
           AND    L.line_id <>
	 oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).entity_id;

          EXCEPTION
                WHEN no_data_found THEN
                   l_valid := 'Y';
                WHEN too_many_rows THEN
                   l_valid := 'N';
	END;

  END IF;
	  IF l_valid = 'N' THEN
                FND_MESSAGE.SET_NAME('ONT','OE_BLKT_LINE_NUMBER_EXISTS');
                OE_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Validate line Number-Exp exception ', 1);
   end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;


    WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Validate line Number-exception ', 1);
   end if;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Validate Line NUmber'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END VALIDATE_LINE_NUMBER;

PROCEDURE VALIDATE_ITEM_UNIQUENESS
(p_req_ind             IN NUMBER
,x_return_status       OUT NOCOPY VARCHAR2
)
IS
l_valid varchar2(1);
lcount number;

  l_line_id               NUMBER;
  l_header_id             NUMBER;
  l_item_id               NUMBER;
  l_item_identifier_type  VARCHAR2(30);
  l_start_date_active     DATE;
  l_end_date_active       DATE;
  l_ordered_item_id       NUMBER; --bug6826787
  l_ordered_item          VARCHAR2(2000);--bug6826787


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_line_id :=
     oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).entity_id;
   l_item_id :=
     oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param1;
   l_header_id :=
     oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param2;
   l_item_identifier_type :=
     oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param3;

   l_ordered_item_id :=
     oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param4;

   l_ordered_item :=
    oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).param5;



   l_start_date_active :=
     oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).date_param1;
   l_end_date_active :=
     oe_delayed_requests_pvt.g_delayed_requests(p_req_ind).date_param2;

   if l_debug_level > 0 then
     oe_debug_pub.add('In validate Item Uniqueness');
     oe_debug_pub.add('item identifier type :'|| l_item_identifier_type);
     oe_debug_pub.add('inventory item id :'|| l_item_id);
     oe_debug_pub.add('header id :'|| l_header_id);
     oe_debug_pub.add('line id :'|| l_line_id);
     oe_debug_pub.add('start date :'|| l_start_date_active);
     oe_debug_pub.add('end date :'|| l_end_date_active);
    end if;

     --modified the following sql to check for uiqueness of
   -- (inventory_item_id,item_idenitfier_type,ordered_item_id) for bug6826787

    select count(1) into lcount
    from OE_BLANKET_LINES L, OE_BLANKET_LINES_EXT LX
    where L.line_id = LX.line_id
      AND L.header_id = l_header_id
      AND L.line_id <> l_line_id
      AND ( ( l_item_identifier_type NOT IN ('ALL','CAT')
              AND L.item_identifier_type NOT IN ('ALL','CAT')
             )
           OR (L.item_identifier_type = l_item_identifier_type)
          )
      AND nvl(L.inventory_item_id,-1) = nvl(l_item_id,-1)
      AND L.item_identifier_type = l_item_identifier_type
      AND  NVL( to_char(L.ordered_item_id),
                decode (L.item_identifier_type,'INT', to_char(NVL(L.inventory_item_id,-1)),
		                               'ALL', to_char(NVL(L.inventory_item_id,-1)),
					       'CAT', to_char(NVL(L.inventory_item_id,-1)),
					       'CUST', to_char(NVL(L.ordered_item_id, NVL(L.inventory_item_id,-1) )),
					        NVL(L.Ordered_item,'XXXX') ) ) = decode ( l_item_identifier_type , 'INT', to_char(nvl(l_item_id,-1))
														 , 'ALL',  to_char(nvl(l_item_id,-1))
														 , 'CAT' , to_char(nvl(l_item_id,-1))
														 , 'CUST', to_char(nvl(l_ordered_item_id,-1))
														 ,  to_char(nvl(l_ordered_item,'XXXX') ))
      AND (  (l_end_date_active IS NULL
              -- Duplicate blanket line date cannot be effective
              -- beyond the start date of this blanket line
              AND l_start_date_active <=
                    nvl(LX.end_date_active,l_start_date_active)
             )
          OR (l_end_date_active IS NOT NULL
              -- Dates for this line cannot be between effectivity dates
              -- for duplicate blanket line
              AND (l_end_date_active BETWEEN
                    LX.start_date_active AND
                    nvl(LX.end_date_active,l_end_date_active + 1)
                  OR l_start_date_active BETWEEN
                    LX.start_date_active AND
                    nvl(LX.end_date_active,l_end_date_active + 1)
                  )
             )
          );

      if (lcount > 0) then
          -- ERROR: date overlap problem.  Show error and
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_UNIQUE_ITEM_VIOLATION');
          OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Validate item uniqr-Exp exception ', 1);
   end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Validate item uniqueness-exception ', 1);
   end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Validate item uniqueness'
            );
      END IF;
END VALIDATE_ITEM_UNIQUENESS;


FUNCTION IS_BLANKET_PRICE_LIST(p_price_list_id NUMBER
                               -- 11i10 Pricing Change
                               ,p_blanket_header_id NUMBER DEFAULT NULL)
RETURN BOOLEAN IS
l_dummy VARCHAR2(30);
l_result   BOOLEAN;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     -- 11i10 pricing change - source code is BSO in 11i10.
     -- Select from qp tables with source as blanket
     -- if exist then return true otherwise false

     IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN

        SELECT 'VALID'
        INTO l_dummy
        FROM QP_LIST_HEADERS
        WHERE LIST_HEADER_ID = p_price_list_id
        AND LIST_SOURCE_CODE = 'BLKT';

     ELSE

        l_result := OE_Blanket_Pricing_Util.Is_Blanket_Price_List
                (p_price_list_id            => p_price_list_id
                ,p_blanket_header_id        => p_blanket_header_id
                );

        RETURN l_result;

/*
        SELECT 'VALID'
        INTO l_dummy
        FROM QP_LIST_HEADERS
        WHERE LIST_HEADER_ID = p_price_list_id
        AND LIST_SOURCE_CODE = 'BSO'
        AND orig_system_header_ref = p_blanket_header_id
        ;
*/

     END IF;

        RETURN TRUE;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   if l_debug_level > 0 then
     oe_debug_pub.ADD('Not a blanket price list', 1);
   end if;
     RETURN FALSE;

END IS_BLANKET_PRICE_LIST;

PROCEDURE RECORD_BLANKET_HISTORY
          (p_version_flag in varchar2 := null,
           p_phase_change_flag in varchar2 := null,
           x_return_status        OUT NOCOPY VARCHAR2
          )
IS
   l_return_status            VARCHAR2(1);
   l_new_version_number       NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
     oe_debug_pub.ADD('Entering Record_Blanket_History from delayed req', 1);
   end if;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT  /* MOAC_SQL_CHANGE */ version_number
    INTO l_new_version_number
    FROM oe_blanket_headers_all
   WHERE header_id = g_old_header_hist_rec.header_id;

  if l_debug_level > 0 then
     oe_debug_pub.ADD('old versn :'||g_old_header_hist_rec.version_number);
     oe_debug_pub.ADD('new versn :'||l_new_version_number);
  end if;

  -- This check is needed as user could change version number multiple times
  -- but in the end, latest version number could be same as the old version
  -- number. If that occurs, we need not record history.

  -- For 11i10, version update occurs after history is inserted
  IF OE_CODE_CONTROL.Code_Release_Level < '110510' AND
     l_new_version_number <= g_old_header_hist_rec.version_number THEN
     RETURN;
  END IF;

  Insert_History_Records
      (p_header_rec             => g_old_header_hist_rec
      ,p_line_tbl               => g_old_line_hist_tbl
      ,p_version_flag             => p_version_flag
      ,p_phase_change_flag        => p_phase_change_flag
      ,x_return_status          => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := l_return_status;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Record Blanket History Exception ', 1);
   end if;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Record Blanket History'
            );
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END RECORD_BLANKET_HISTORY;

PROCEDURE Copy_Blanket (p_header_id IN NUMBER,
                        p_version_number IN NUMBER,
                        x_header_id OUT NOCOPY NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT NOCOPY VARCHAR2)
IS

l_header_rec  OE_Blanket_Pub.header_rec_type;
l_line_tbl    OE_Blanket_Pub.line_tbl_type;
l_control_rec OE_Blanket_Pub.control_rec_type;
x_header_rec  OE_Blanket_Pub.header_rec_type;
x_line_tbl    OE_Blanket_Pub.line_tbl_type;
l_return_status VARCHAR2(1);
l_header_id   NUMBER;
l_count       NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering Copy_blanket ', 1);
   end if;

    OE_MSG_PUB.initialize;

  SAVEPOINT Copy_Blanket;

    OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'BLANKET_HEADER'
  	,p_entity_id         		=> p_header_id
    	,p_header_id         		=> p_header_id
    	,p_line_id           		=> null
    	,p_orig_sys_document_ref	=> null
    	,p_orig_sys_document_line_ref	=> null
        ,p_change_sequence              => null
    	,p_source_document_id		=> null
    	,p_source_document_line_id	=> null
	,p_order_source_id            => null
	,p_source_document_type_id    => null);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Set message context

  -- Step One: Populate header record and line table with desired
  -- attributes. Refer Blankets HLD for specific attributes to be copied.

  Query_Blanket(p_header_id => p_header_id
               , p_version_number => p_version_number
               ,p_x_header_rec        => l_header_rec
               ,p_x_line_tbl          => l_line_tbl
               ,x_return_status       => x_return_status);

  -- Prepare control record
  l_control_rec.UI_CALL := FALSE;
  l_control_rec.validate_attributes := TRUE;
  l_control_rec.validate_entity := TRUE;
  l_control_rec.check_security := TRUE;

  -- Prepare attributes for new blanket
  l_header_rec.source_document_type_id := 2; --Copy source
  l_header_rec.source_document_id := l_header_rec.header_id;
  l_header_rec.source_document_version_number := l_header_rec.version_number;

    -- Pre-default header_id for proper message display
    SELECT OE_ORDER_HEADERS_S.NEXTVAL
    INTO l_header_rec.header_id
    FROM DUAL;

  l_header_rec.order_number := NULL;
  l_header_rec.version_number := 0;
  l_header_rec.operation := oe_globals.g_opr_create;
  --l_header_rec.start_date_active := trunc(SYSDATE);
  --l_header_rec.end_date_active := NULL;
  l_header_rec.revision_change_date := NULL;
  l_header_rec.revision_change_reason_code := NULL;
  l_header_rec.revision_change_comments := NULL;
  l_header_rec.released_amount := NULL;
  l_header_rec.returned_amount := NULL;
  l_header_rec.fulfilled_amount := NULL;

  l_header_rec.sales_document_name := null;
  --clear out NOCOPY /* file.sql.39 change */ signature columns here
  l_header_rec.customer_signature := null;
  l_header_rec.customer_signature_date := null;
  l_header_rec.supplier_signature := null;
  l_header_rec.supplier_signature_date := null;
  l_header_rec.transaction_phase_code := null;
  l_header_rec.user_status_code := null;
  l_header_rec.flow_status_code := null;
  l_header_rec.draft_submitted_flag := null;

  --Null out NOCOPY /* file.sql.39 change */ price list if it's a blanket price list, repeat for header and each line:
  -- 11i10 Pricing changes, pass header id to is_blanket_price_list
  If Is_Blanket_Price_List(p_price_list_id => l_header_rec.price_list_id
                           ,p_blanket_header_id => p_header_id) Then
      l_header_rec.price_list_id := NULL;
      l_header_rec.enforce_price_list_flag := NULL;
  End If;
  -- 11i10 Pricing Changes
  -- Always null out NOCOPY /* file.sql.39 change */ new price list/modifier/discount fields when copying
  l_header_rec.new_price_list_id := NULL;
  l_header_rec.new_modifier_list_id := NULL;
  l_header_rec.default_discount_percent := NULL;
  l_header_rec.default_discount_amount := NULL;
  l_header_rec.new_price_list_name := NULL;
  l_header_rec.new_modifier_list_name := NULL;

  FOR l_count in 1..l_line_tbl.COUNT LOOP
    l_line_tbl(l_count).source_document_type_id := 2; --Copy source
    l_line_tbl(l_count).source_document_id := l_header_rec.source_document_id;
    l_line_tbl(l_count).source_document_version_number := l_header_rec.source_document_version_number;
    l_line_tbl(l_count).source_document_line_id := l_line_tbl(l_count).line_id;
    l_line_tbl(l_count).header_id := l_header_rec.header_id;
    l_line_tbl(l_count).order_number := NULL;

    -- Pre-default header_id for proper message display
    SELECT OE_ORDER_LINES_S.NEXTVAL
    INTO l_line_tbl(l_count).line_id
    FROM DUAL;

    l_line_tbl(l_count).operation := oe_globals.g_opr_create;
    l_line_tbl(l_count).order_number := NULL;
    l_line_tbl(l_count).line_number := NULL;
    --l_line_tbl(l_count).start_date_active := NULL;
    --l_line_tbl(l_count).end_date_active := NULL;
    l_line_tbl(l_count).released_amount := NULL;
    l_line_tbl(l_count).released_quantity := NULL;
    l_line_tbl(l_count).returned_amount := NULL;
    l_line_tbl(l_count).returned_quantity := NULL;
    l_line_tbl(l_count).fulfilled_amount := NULL;
    l_line_tbl(l_count).fulfilled_quantity := NULL;
    l_line_tbl(l_count).transaction_phase_code := null;

    -- 11i10 Pricing changes, pass header id to is_blanket_price_list
    If Is_Blanket_Price_List(p_price_list_id => l_line_tbl(l_count).price_list_id,
                             p_blanket_header_id => p_header_id) Then
      l_line_tbl(l_count).price_list_id := NULL;
      l_line_tbl(l_count).qp_list_line_id := NULL;
      l_line_tbl(l_count).enforce_price_list_flag := NULL;
    End If;
    -- 11i10 Pricing Changes
    -- Always null out NOCOPY /* file.sql.39 change */ new modifier/discount fields when copying
    l_line_tbl(l_count).modifier_list_line_id := NULL;
    l_line_tbl(l_count).discount_percent := NULL;
    l_line_tbl(l_count).discount_amount := NULL;
  END LOOP;

  OE_BLANKET_PVT.Process_Blanket
  (   p_api_version_number            => 1.0
  ,   p_validation_level              => OE_GLOBALS.G_VALID_LEVEL_PARTIAL
  ,   x_return_status                 => x_return_status
  ,   x_msg_count                     => x_msg_count
  ,   x_msg_data                      => x_msg_data
  ,   p_header_rec            => l_header_rec
  ,   p_line_tbl              => l_line_tbl
  ,   p_control_rec        =>  l_control_rec
  ,   x_header_rec           => x_header_rec
  ,   x_line_tbl             => x_line_tbl
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        fnd_message.set_name('ONT','OE_CPY_COPY_FAILED');
        OE_MSG_PUB.Add;
        ROLLBACK TO SAVEPOINT Copy_Blanket;
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- copy articles
  OE_Contracts_Util.copy_articles(p_api_version => 1.0,
                      p_doc_type => 'B',
                      p_copy_from_doc_id => p_header_id,
                      p_version_number => p_version_number,
                      p_copy_to_doc_id => x_header_rec.header_id,
                      p_copy_to_doc_number => x_header_rec.order_number,
                      x_return_status => l_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data
                      );


  IF NOT OE_GLOBALS.EQUAL(l_return_status, FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := nvl(l_return_status, x_return_status);
  END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        fnd_message.set_name('ONT','OE_CPY_COPY_FAILED');
        OE_MSG_PUB.Add;
        ROLLBACK TO SAVEPOINT Copy_Blanket;
        RAISE FND_API.G_EXC_ERROR;
  ELSE
    	fnd_message.set_name('ONT','OE_BL_COPY_SUCCESS');
        -- Bug 3337297
        -- Set blanket number token
        fnd_message.set_token('BLANKET_NUMBER',x_header_rec.order_number);
    	OE_MSG_PUB.Add;
        x_header_id := x_header_rec.header_id;
  END IF;


  --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Copy Blanket Exception ', 1);
   end if;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Copy Blanket'
            );
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Copy_Blanket;

Procedure Validate_Min_Max_Range (
p_min_value IN NUMBER,
p_max_value IN NUMBER,
p_attribute IN VARCHAR2,
x_return_status IN OUT NOCOPY VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


  IF (p_min_value IS NOT NULL)
    AND (p_max_value IS NOT NULL)
    AND (p_min_value > p_max_value) THEN
       if l_debug_level > 0 then
          oe_debug_pub.add('Invalid min/max for attribute :'||p_attribute);
       end if;
       FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_MIN_MAX_RANGE');
       FND_MESSAGE.SET_TOKEN('MIN', p_min_value);
       FND_MESSAGE.SET_TOKEN('MAX', p_max_value);
       OE_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION

    WHEN OTHERS THEN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Validate min max range - U exeception  ', 1);
   end if;

        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Validate min max range'
            );
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Min_Max_Range;


PROCEDURE Insert_History_Records
          (p_header_rec           IN OUT NOCOPY OE_Blanket_PUB.Header_Rec_Type
          ,p_line_tbl             IN OUT NOCOPY OE_Blanket_PUB.Line_Tbl_Type
          ,p_version_flag in varchar2 := null
          ,p_phase_change_flag in varchar2 := null
          ,x_return_status        IN OUT NOCOPY VARCHAR2
)
IS
    l_org_id                 NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    -- <R12.MOAC> START
    --l_org_id := to_number(FND_PROFILE.VALUE('ORG_ID'));
    -- <R12.MOAC> END

   if l_debug_level > 0 then
    oe_debug_pub.ADD('Before inserting blanket history header_id  ' || p_header_rec.header_id, 5);
   end if;

    INSERT  INTO OE_BLANKET_HEADERS_HIST
    (       ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
--adding context  since it was missing
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORDER_NUMBER
    ,       ORDER_TYPE_ID
    ,       PAYMENT_TERM_ID
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SOLD_TO_CONTACT_ID
    ,       SOLD_TO_ORG_ID
    ,       TRANSACTIONAL_CURR_CODE
    ,       conversion_type_code
    ,       VERSION_NUMBER
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       on_hold_flag
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       OVERRIDE_AMOUNT_FLAG
    ,       BLANKET_MAX_AMOUNT
    ,       BLANKET_MIN_AMOUNT
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       ORG_ID
    ,       REVISION_CHANGE_REASON_CODE
    ,       REVISION_CHANGE_COMMENTS
    ,       REVISION_CHANGE_DATE
    ,       RESPONSIBILITY_ID
    ,       HIST_TYPE_CODE
    ,       HIST_CREATION_DATE
    ,       HIST_CREATED_BY
    ,       SALES_DOCUMENT_TYPE_CODE
    ,       source_document_id
    ,       source_document_type_id
    ,       SALES_DOCUMENT_NAME -- hashraf ... start of pack J
    ,       TRANSACTION_PHASE_CODE
    ,       USER_STATUS_CODE
    ,       FLOW_STATUS_CODE
    ,	    SUPPLIER_SIGNATURE
    ,	    SUPPLIER_SIGNATURE_DATE
    ,	    CUSTOMER_SIGNATURE
    ,	    CUSTOMER_SIGNATURE_DATE
    ,       sold_to_site_use_id
    ,       draft_submitted_flag
    ,       source_document_version_number -- hashraf ... end of pack J
    ,       version_flag
    ,       phase_change_flag
    ,       new_modifier_list_id
    ,       new_price_list_id
    ,       default_discount_amount
    ,       default_discount_percent
    )
    VALUES
    (       p_header_rec.accounting_rule_id
    ,       p_header_rec.agreement_id
    ,       p_header_rec.attribute1
    ,       p_header_rec.attribute10
    ,       p_header_rec.attribute11
    ,       p_header_rec.attribute12
    ,       p_header_rec.attribute13
    ,       p_header_rec.attribute14
    ,       p_header_rec.attribute15
    ,       p_header_rec.attribute16
    ,       p_header_rec.attribute17
    ,       p_header_rec.attribute18
    ,       p_header_rec.attribute19
    ,       p_header_rec.attribute20
    ,       p_header_rec.attribute2
    ,       p_header_rec.attribute3
    ,       p_header_rec.attribute4
    ,       p_header_rec.attribute5
    ,       p_header_rec.attribute6
    ,       p_header_rec.attribute7
    ,       p_header_rec.attribute8
    ,       p_header_rec.attribute9
--added context ,since it was missing
    ,       p_header_rec.context
    ,       p_header_rec.created_by
    ,       p_header_rec.creation_date
    ,       p_header_rec.cust_po_number
    ,       p_header_rec.deliver_to_org_id
    ,       p_header_rec.freight_terms_code
    ,       p_header_rec.header_id
    ,       p_header_rec.invoice_to_org_id
    ,       p_header_rec.invoicing_rule_id
    ,       p_header_rec.last_updated_by
    ,       p_header_rec.last_update_date
    ,       p_header_rec.last_update_login
    ,       p_header_rec.order_number
    ,       p_header_rec.order_type_id
    ,       p_header_rec.payment_term_id
    ,       p_header_rec.price_list_id
    ,       p_header_rec.program_application_id
    ,       p_header_rec.program_id
    ,       p_header_rec.program_update_date
    ,       p_header_rec.request_id
    ,       p_header_rec.salesrep_id
    ,       p_header_rec.shipping_method_code
    ,       p_header_rec.ship_from_org_id
    ,       p_header_rec.ship_to_org_id
    ,       p_header_rec.sold_to_contact_id
    ,       p_header_rec.sold_to_org_id
    ,       p_header_rec.transactional_curr_code
    ,       p_header_rec.conversion_type_code
    ,       p_header_rec.version_number
    ,	    p_header_rec.shipping_instructions
    ,	    p_header_rec.packing_instructions
    ,       p_header_rec.START_DATE_ACTIVE
    ,       p_header_rec.END_DATE_ACTIVE
    ,       p_header_rec.on_hold_flag
    ,       p_header_rec.ENFORCE_PRICE_LIST_FLAG
    ,       p_header_rec.enforce_ship_to_flag
    ,       p_header_rec.enforce_invoice_to_flag
    ,       p_header_rec.enforce_freight_term_flag
    ,       p_header_rec.enforce_shipping_method_flag
    ,       p_header_rec.enforce_payment_term_flag
    ,       p_header_rec.enforce_accounting_rule_flag
    ,       p_header_rec.enforce_invoicing_rule_flag
    ,       p_header_rec.OVERRIDE_AMOUNT_FLAG
    ,       p_header_rec.Blanket_Max_Amount
    ,       p_header_rec.Blanket_Min_Amount
    ,       p_header_rec.RELEASED_AMOUNT
    ,       p_header_rec.FULFILLED_AMOUNT
    ,       p_header_rec.RETURNED_AMOUNT
    ,       p_header_rec.ORG_ID
    ,       p_header_rec.REVISION_CHANGE_REASON_CODE
    ,       p_header_rec.REVISION_CHANGE_COMMENTS
    ,       p_header_rec.REVISION_CHANGE_DATE
    ,       nvl(FND_GLOBAL.RESP_ID,-1)
    ,       'UPDATE'
    ,       sysdate
    ,       nvl(FND_GLOBAL.USER_ID, -1)
    ,       'B'
    ,       p_header_rec.source_document_id
    ,       p_header_rec.source_document_type_id
    ,       p_header_rec.SALES_DOCUMENT_NAME -- hashraf ... start of pack J
    ,       p_header_rec.TRANSACTION_PHASE_CODE
    ,       p_header_rec.USER_STATUS_CODE
    ,       p_header_rec.FLOW_STATUS_CODE
    ,       p_header_rec.SUPPLIER_SIGNATURE
    ,       p_header_rec.SUPPLIER_SIGNATURE_DATE
    ,       p_header_rec.CUSTOMER_SIGNATURE
    ,       p_header_rec.CUSTOMER_SIGNATURE_DATE
    ,       p_header_rec.sold_to_site_use_id
    ,       p_header_rec.draft_submitted_flag
    ,       p_header_rec.source_document_version_number -- hashraf ... end of pack J
    ,       p_version_flag
    ,       p_phase_change_flag
    ,       p_header_rec.new_modifier_list_id
    ,       p_header_rec.new_price_list_id
    ,       p_header_rec.default_discount_amount
    ,       p_header_rec.default_discount_percent
    );


    FOR I IN 1..p_line_tbl.COUNT LOOP

   if l_debug_level > 0 then
    oe_debug_pub.ADD('Before inserting blanket line history line_id  ' || p_line_tbl(I).line_id, 5);
   end if;

        INSERT  INTO OE_BLANKET_LINES_HIST
        (       ACCOUNTING_RULE_ID
        ,       AGREEMENT_ID
        ,       ATTRIBUTE1
        ,       ATTRIBUTE10
        ,       ATTRIBUTE11
        ,       ATTRIBUTE12
        ,       ATTRIBUTE13
        ,       ATTRIBUTE14
        ,       ATTRIBUTE15
        ,       ATTRIBUTE16
        ,       ATTRIBUTE17
        ,       ATTRIBUTE18
        ,       ATTRIBUTE19
        ,       ATTRIBUTE20
        ,       ATTRIBUTE2
        ,       ATTRIBUTE3
        ,       ATTRIBUTE4
        ,       ATTRIBUTE5
        ,       ATTRIBUTE6
        ,       ATTRIBUTE7
        ,       ATTRIBUTE8
        ,       ATTRIBUTE9
        ,       CONTEXT
        ,       CREATED_BY
        ,       CREATION_DATE
        ,       CUST_PO_NUMBER
        ,       DELIVER_TO_ORG_ID
        ,       FREIGHT_TERMS_CODE
        ,       header_id --header_id
        ,       min_release_quantity
        ,       max_release_quantity
        ,       inventory_item_id
        ,       INVOICE_TO_ORG_ID
        ,       INVOICING_RULE_ID
        ,       ORDERED_ITEM_ID
        ,       item_identifier_type
        ,       ORDERED_ITEM
        ,       ITEM_TYPE_CODE
        ,       LAST_UPDATED_BY
        ,       LAST_UPDATE_DATE
        ,       LAST_UPDATE_LOGIN
        ,       line_id --line_id
        ,       line_number --blanket_line_number
        ,       PAYMENT_TERM_ID
        ,       PREFERRED_GRADE             --OPM Added 02/JUN/00
        ,       PRICE_LIST_ID
        ,       PROGRAM_APPLICATION_ID
        ,       PROGRAM_ID
        ,       PROGRAM_UPDATE_DATE
        ,       REQUEST_ID
        ,       SALESREP_ID
        ,       SHIPPING_METHOD_CODE
        ,       ship_from_org_id
        ,       ship_to_org_id
        ,       SHIPPING_INSTRUCTIONS
        ,       PACKING_INSTRUCTIONS
        ,       START_DATE_ACTIVE
        ,       END_DATE_ACTIVE
        ,       MAX_RELEASE_AMOUNT
        ,       MIN_RELEASE_AMOUNT
        ,       BLANKET_LINE_MAX_AMOUNT
        ,       BLANKET_LINE_MIN_AMOUNT
        ,       BLANKET_MAX_QUANTITY
        ,       BLANKET_MIN_QUANTITY
        ,       OVERRIDE_BLANKET_CONTROLS_FLAG
        ,       OVERRIDE_RELEASE_CONTROLS_FLAG
        ,       ENFORCE_PRICE_LIST_FLAG
        ,   enforce_ship_to_flag
        ,   enforce_invoice_to_flag
        ,   enforce_freight_term_flag
        ,   enforce_shipping_method_flag
        ,   enforce_payment_term_flag
        ,   enforce_accounting_rule_flag
        ,   enforce_invoicing_rule_flag
        ,       ORDER_QUANTITY_UOM
        ,       RELEASED_QUANTITY
        ,       FULFILLED_QUANTITY
        ,       RETURNED_QUANTITY
        ,       ORDER_NUMBER
        ,       RELEASED_AMOUNT
        ,       FULFILLED_AMOUNT
        ,       RETURNED_AMOUNT
        ,       RESPONSIBILITY_ID
        ,       HIST_TYPE_CODE
        ,       HIST_CREATION_DATE
        ,       HIST_CREATED_BY
        ,       VERSION_NUMBER
        ,       SALES_DOCUMENT_TYPE_CODE
    	,       TRANSACTION_PHASE_CODE -- hashraf ... start of pack J
        ,       source_document_version_number
        ,       version_flag
        ,       phase_change_flag
        ,       modifier_list_line_id
        )
        VALUES
        (       p_line_tbl(I).accounting_rule_id
        ,       p_line_tbl(I).agreement_id
        ,       p_line_tbl(I).attribute1
        ,       p_line_tbl(I).attribute10
        ,       p_line_tbl(I).attribute11
        ,       p_line_tbl(I).attribute12
        ,       p_line_tbl(I).attribute13
        ,       p_line_tbl(I).attribute14
        ,       p_line_tbl(I).attribute15
        ,       p_line_tbl(I).attribute16
        ,       p_line_tbl(I).attribute17
        ,       p_line_tbl(I).attribute18
        ,       p_line_tbl(I).attribute19
        ,       p_line_tbl(I).attribute20
        ,       p_line_tbl(I).attribute2
        ,       p_line_tbl(I).attribute3
        ,       p_line_tbl(I).attribute4
        ,       p_line_tbl(I).attribute5
        ,       p_line_tbl(I).attribute6
        ,       p_line_tbl(I).attribute7
        ,       p_line_tbl(I).attribute8
        ,       p_line_tbl(I).attribute9
        ,       p_line_tbl(I).context
        ,       p_line_tbl(I).created_by
        ,       p_line_tbl(I).creation_date
        ,       p_line_tbl(I).cust_po_number
        ,       p_line_tbl(I).deliver_to_org_id
        ,       p_line_tbl(I).freight_terms_code
        ,       p_line_tbl(I).header_id
        ,       p_line_tbl(I).min_release_quantity
        ,       p_line_tbl(I).max_release_quantity
        ,       p_line_tbl(I).inventory_item_id
        ,       p_line_tbl(I).invoice_to_org_id
        ,       p_line_tbl(I).invoicing_rule_id
        ,       p_line_tbl(I).ordered_item_id
        ,       p_line_tbl(I).item_identifier_type

        ,       p_line_tbl(I).ordered_item
        ,       p_line_tbl(I).item_type_code
        ,       p_line_tbl(I).last_updated_by
        ,       p_line_tbl(I).last_update_date
        ,       p_line_tbl(I).last_update_login
        ,       p_line_tbl(I).line_id
        ,       p_line_tbl(I).line_number
        ,       p_line_tbl(I).payment_term_id
        ,       p_line_tbl(I).preferred_grade            --OPM 02/JUN/00
        ,       p_line_tbl(I).price_list_id
        ,       p_line_tbl(I).program_application_id
        ,       p_line_tbl(I).program_id
        ,       p_line_tbl(I).program_update_date
        ,       p_line_tbl(I).request_id
        ,       p_line_tbl(I).salesrep_id
        ,       p_line_tbl(I).shipping_method_code
        ,       p_line_tbl(I).ship_from_org_id
        ,       p_line_tbl(I).ship_to_org_id
        ,       p_line_tbl(I).shipping_instructions
        ,       p_line_tbl(I).packing_instructions
        ,       p_line_tbl(I).START_DATE_ACTIVE
        ,       p_line_tbl(I).END_DATE_ACTIVE
        ,       p_line_tbl(I).MAX_RELEASE_AMOUNT
        ,       p_line_tbl(I).MIN_RELEASE_AMOUNT
        ,       p_line_tbl(I).BLANKET_MAX_AMOUNT
        ,       p_line_tbl(I).BLANKET_MIN_AMOUNT
        ,       p_line_tbl(I).BLANKET_MAX_QUANTITY
        ,       p_line_tbl(I).BLANKET_MIN_QUANTITY
        ,       p_line_tbl(I).OVERRIDE_BLANKET_CONTROLS_FLAG
        ,       p_line_tbl(I).OVERRIDE_RELEASE_CONTROLS_FLAG
        ,       p_line_tbl(I).ENFORCE_PRICE_LIST_FLAG
        ,       p_line_tbl(I).enforce_ship_to_flag
        ,       p_line_tbl(I).enforce_invoice_to_flag
        ,       p_line_tbl(I).enforce_freight_term_flag
        ,       p_line_tbl(I).enforce_shipping_method_flag
        ,       p_line_tbl(I).enforce_payment_term_flag
        ,       p_line_tbl(I).enforce_accounting_rule_flag
        ,       p_line_tbl(I).enforce_invoicing_rule_flag
        ,       p_line_tbl(I).ORDER_QUANTITY_UOM
        ,       p_line_tbl(I).RELEASED_QUANTITY
        ,       p_line_tbl(I).FULFILLED_QUANTITY
        ,       p_line_tbl(I).RETURNED_QUANTITY
        ,       p_line_tbl(I).ORDER_NUMBER
        ,       p_line_tbl(I).RELEASED_AMOUNT
        ,       p_line_tbl(I).FULFILLED_AMOUNT
        ,       p_line_tbl(I).RETURNED_AMOUNT
        ,       nvl(FND_GLOBAL.RESP_ID,-1)
        ,       'UPDATE'
        ,       sysdate
        ,       nvl(FND_GLOBAL.USER_ID, -1)
        ,       p_header_rec.version_number
        ,       'B'
    	,       p_line_tbl(I).TRANSACTION_PHASE_CODE -- hashraf ... start of pack J
    	,       p_line_tbl(I).source_document_version_number
        ,       p_version_flag
        ,       p_phase_change_flag
        ,       p_line_tbl(I).modifier_list_line_id
        );

    END LOOP;

   if l_debug_level > 0 then
    oe_debug_pub.ADD('After inserting blanket history', 1);
   end if;

END Insert_History_Records;

Procedure Return_Lines_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER ) IS

l_blanket_number number;
l_blanket_line_number number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if l_debug_level > 0 then
	oe_debug_pub.add('Enter OE_Blanket_Util.Returns_Exist');
    end if;

  If p_validation_entity_short_name = 'BLANKET_LINE' Then
     l_blanket_number := oe_blanket_line_security.g_record.order_number;
     l_blanket_line_number := oe_blanket_line_security.g_record.line_number;

    BEGIN
       Select 1 into p_result
       from oe_order_lines
       where blanket_number = l_blanket_number
       and blanket_line_number = l_blanket_line_number
       and line_category_code = 'RETURN'
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  Else
     l_blanket_number := oe_blanket_header_security.g_record.order_number;

    BEGIN
       Select 1 into p_result
       from oe_order_lines
       where blanket_number = l_blanket_number
       and line_category_code = 'RETURN'
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  End If;

END Return_Lines_Exist;

Procedure Release_Lines_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER ) IS

l_blanket_number number;
l_blanket_line_number number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if l_debug_level > 0 then
	oe_debug_pub.add('Enter OE_Blanket_Util.Release_Lines_Exist');
    end if;

  If p_validation_entity_short_name = 'BLANKET_LINE' Then
     l_blanket_number := oe_blanket_line_security.g_record.order_number;
     l_blanket_line_number := oe_blanket_line_security.g_record.line_number;

    BEGIN
       Select 1 into p_result
       from oe_order_lines
       where blanket_number = l_blanket_number
       and blanket_line_number = l_blanket_line_number
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  Else
     l_blanket_number := oe_blanket_header_security.g_record.order_number;

    BEGIN
       Select 1 into p_result
       from oe_order_lines
       where blanket_number = l_blanket_number
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  End If;

END Release_Lines_Exist;

Procedure Release_Headers_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER ) IS

l_blanket_number number;
l_blanket_line_number number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if l_debug_level > 0 then
	oe_debug_pub.add('Enter OE_Blanket_Util.Release_Lines_Exist');
    end if;

  If p_validation_entity_short_name = 'BLANKET_LINE' Then
     l_blanket_number := oe_blanket_line_security.g_record.order_number;

    BEGIN
       Select 1 into p_result
       from oe_order_headers_all
       where blanket_number = l_blanket_number
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  Else
     l_blanket_number := oe_blanket_header_security.g_record.order_number;

    BEGIN
       Select 1 into p_result
       from oe_order_headers_all
       where blanket_number = l_blanket_number
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  End If;

END Release_Headers_Exist;

Procedure Open_Release_Lines_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER ) IS

l_blanket_number number;
l_blanket_line_number number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if l_debug_level > 0 then
	oe_debug_pub.add('Enter OE_Blanket_Util.Open_Release_Lines_Exist');
    end if;

  If p_validation_entity_short_name = 'BLANKET_LINE' Then
     l_blanket_number := oe_blanket_line_security.g_record.order_number;
     l_blanket_line_number := oe_blanket_line_security.g_record.line_number;

    BEGIN
       Select 1 into p_result
       from oe_order_lines
       where blanket_number = l_blanket_number
       and blanket_line_number = l_blanket_line_number
       and open_flag = 'Y'
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  Else
     l_blanket_number := oe_blanket_header_security.g_record.order_number;

    BEGIN
       Select 1 into p_result
       from oe_order_lines
       where blanket_number = l_blanket_number
       and open_flag = 'Y'
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  End If;

END Open_Release_Lines_Exist;

Procedure Open_Release_Headers_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER ) IS

l_blanket_number number;
l_blanket_line_number number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if l_debug_level > 0 then
	oe_debug_pub.add('Enter OE_Blanket_Util.Open_Release_Lines_Exist');
    end if;

  If p_validation_entity_short_name = 'BLANKET_LINE' Then
     l_blanket_number := oe_blanket_line_security.g_record.order_number;

    BEGIN
       Select 1 into p_result
       from oe_order_headers_all
       where blanket_number = l_blanket_number
       and open_flag = 'Y'
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  Else
     l_blanket_number := oe_blanket_header_security.g_record.order_number;

    BEGIN
       Select 1 into p_result
       from oe_order_headers_all
       where blanket_number = l_blanket_number
       and open_flag = 'Y'
       and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_result := 0;
    END;

  End If;

END Open_Release_Headers_Exist;

Procedure Is_Expired( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER ) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if l_debug_level > 0 then
	oe_debug_pub.add('Enter OE_Blanket_Util.Is_Expired');
    end if;

  If p_validation_entity_short_name = 'BLANKET_LINE' Then
    If (trunc(sysdate) >= OE_Blanket_Line_Security.g_record.start_date_active
       AND trunc(sysdate) <= trunc(nvl(OE_Blanket_Line_Security.g_record.end_date_active, sysdate)))
    Then
       p_result := 0;
    Else
       p_result := 1;
    End If;
  Else
    If (trunc(sysdate) >= OE_Blanket_Header_Security.g_record.start_date_active
       AND trunc(sysdate) <= trunc(nvl(OE_Blanket_Header_Security.g_record.end_date_active, sysdate)))
    Then
       p_result := 0;
    Else
       p_result := 1;
    End If;

  End If;

END Is_Expired;

FUNCTION G_MISS_OE_AK_BLKT_HEADER_REC
RETURN OE_AK_BLANKET_HEADERS_V%ROWTYPE IS
	l_rowtype_rec					OE_AK_BLANKET_HEADERS_V%ROWTYPE;
BEGIN

	l_rowtype_rec.ACCOUNTING_RULE_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.CONVERSION_TYPE_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CUST_PO_NUMBER				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.DELIVER_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.END_DATE_ACTIVE				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.FREIGHT_TERMS_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.HEADER_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.INVOICE_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.INVOICING_RULE_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.LAST_UPDATED_BY				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.LAST_UPDATE_DATE				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.LAST_UPDATE_LOGIN				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ORDER_NUMBER					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ORDER_TYPE_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ORG_ID						:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PACKING_INSTRUCTIONS			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.PAYMENT_TERM_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PRICE_LIST_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PROGRAM_APPLICATION_ID		:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PROGRAM_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PROGRAM_UPDATE_DATE			:= FND_API.G_MISS_DATE;
	l_rowtype_rec.SALESREP_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SHIPPING_INSTRUCTIONS			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SHIPPING_METHOD_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SHIP_FROM_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SHIP_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOLD_TO_CONTACT_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOLD_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.START_DATE_ACTIVE				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.TRANSACTIONAL_CURR_CODE		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.VERSION_NUMBER				:= FND_API.G_MISS_NUM;

	l_rowtype_rec.CREATED_BY           := FND_API.G_MISS_NUM;
	l_rowtype_rec.CREATION_DATE           := FND_API.G_MISS_DATE;
	l_rowtype_rec.REVISION_CHANGE_DATE           := FND_API.G_MISS_DATE;
	l_rowtype_rec.REVISION_CHANGE_REASON_CODE           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.REVISION_CHANGE_COMMENTS           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_SHIP_TO_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_FREIGHT_TERM_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_SHIPPING_METHOD_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_PRICE_LIST_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_PAYMENT_TERM_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_INVOICE_TO_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_INVOICING_RULE_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_ACCOUNTING_RULE_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.BLANKET_MIN_AMOUNT           := FND_API.G_MISS_NUM;
	l_rowtype_rec.BLANKET_MAX_AMOUNT           := FND_API.G_MISS_NUM;
	l_rowtype_rec.OVERRIDE_AMOUNT_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ON_HOLD_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.SUPPLIER_SIGNATURE            := FND_API.G_MISS_CHAR;
	l_rowtype_rec.SUPPLIER_SIGNATURE_DATE            := FND_API.G_MISS_DATE;
	l_rowtype_rec.CUSTOMER_SIGNATURE            := FND_API.G_MISS_CHAR;
	l_rowtype_rec.CUSTOMER_SIGNATURE_DATE            := FND_API.G_MISS_DATE;
	l_rowtype_rec.FLOW_STATUS_CODE            := FND_API.G_MISS_CHAR;
	l_rowtype_rec.SOURCE_DOCUMENT_TYPE_ID            := FND_API.G_MISS_NUM;
	l_rowtype_rec.NEW_MODIFIER_LIST_ID            := FND_API.G_MISS_NUM;
	l_rowtype_rec.NEW_PRICE_LIST_ID            := FND_API.G_MISS_NUM;
	l_rowtype_rec.DEFAULT_DISCOUNT_PERCENT            := FND_API.G_MISS_NUM;
	l_rowtype_rec.DEFAULT_DISCOUNT_AMOUNT            := FND_API.G_MISS_NUM;
	l_rowtype_rec.CONTRACT_TERMS            := FND_API.G_MISS_CHAR;
	l_rowtype_rec.OPEN_FLAG            := FND_API.G_MISS_CHAR;

    --QUOTING changes
	l_rowtype_rec.TRANSACTION_PHASE_CODE       		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.USER_STATUS_CODE       			:= FND_API.G_MISS_CHAR;
--	l_rowtype_rec.QUOTE_NUMBER       			:= FND_API.G_MISS_NUM;
--	l_rowtype_rec.QUOTE_DATE     				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.SALES_DOCUMENT_NAME       		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SOLD_TO_SITE_USE_ID       		:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOURCE_DOCUMENT_VERSION_NUMBER   		:= FND_API.G_MISS_NUM;
	l_rowtype_rec.DRAFT_SUBMITTED_FLAG       		:= FND_API.G_MISS_CHAR;
        -- QUOTING changes END

	RETURN l_rowtype_rec;

EXCEPTION

	WHEN OTHERS THEN
		IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'G_MISS_OE_AK_HEADER_REC'
			);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END G_MISS_OE_AK_BLKT_HEADER_REC;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_HEADER_rec                    IN  OE_Blanket_PUB.HEADER_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_BLANKET_HEADERS_V%ROWTYPE
) IS
BEGIN

	x_rowtype_rec.ACCOUNTING_RULE_ID       := p_header_rec.ACCOUNTING_RULE_ID;
	x_rowtype_rec.CONVERSION_TYPE_CODE     := p_header_rec.CONVERSION_TYPE_CODE;
	x_rowtype_rec.CUST_PO_NUMBER           := p_header_rec.CUST_PO_NUMBER;
	x_rowtype_rec.DELIVER_TO_ORG_ID        := p_header_rec.DELIVER_TO_ORG_ID;
	x_rowtype_rec.END_DATE_ACTIVE          := p_header_rec.END_DATE_ACTIVE;
	x_rowtype_rec.FREIGHT_TERMS_CODE       := p_header_rec.FREIGHT_TERMS_CODE;
	x_rowtype_rec.HEADER_ID       := p_header_rec.HEADER_ID;
	x_rowtype_rec.INVOICE_TO_ORG_ID        := p_header_rec.INVOICE_TO_ORG_ID;
	x_rowtype_rec.INVOICING_RULE_ID        := p_header_rec.INVOICING_RULE_ID;
	x_rowtype_rec.LAST_UPDATED_BY          := p_header_rec.LAST_UPDATED_BY;
	x_rowtype_rec.LAST_UPDATE_DATE         := p_header_rec.LAST_UPDATE_DATE;
	x_rowtype_rec.LAST_UPDATE_LOGIN        := p_header_rec.LAST_UPDATE_LOGIN;
	x_rowtype_rec.ORDER_NUMBER             := p_header_rec.ORDER_NUMBER;
	x_rowtype_rec.ORDER_TYPE_ID            := p_header_rec.ORDER_TYPE_ID;
	x_rowtype_rec.ORG_ID                   := p_header_rec.ORG_ID;
	x_rowtype_rec.PACKING_INSTRUCTIONS     := p_header_rec.PACKING_INSTRUCTIONS;
	x_rowtype_rec.PAYMENT_TERM_ID          := p_header_rec.PAYMENT_TERM_ID;
	x_rowtype_rec.PRICE_LIST_ID            := p_header_rec.PRICE_LIST_ID;
	x_rowtype_rec.PROGRAM_APPLICATION_ID   := p_header_rec.PROGRAM_APPLICATION_ID;
	x_rowtype_rec.PROGRAM_ID               := p_header_rec.PROGRAM_ID;
	x_rowtype_rec.PROGRAM_UPDATE_DATE      := p_header_rec.PROGRAM_UPDATE_DATE;
	x_rowtype_rec.SALESREP_ID              := p_header_rec.SALESREP_ID;
	x_rowtype_rec.SHIPPING_INSTRUCTIONS    := p_header_rec.SHIPPING_INSTRUCTIONS;
	x_rowtype_rec.SHIPPING_METHOD_CODE     := p_header_rec.SHIPPING_METHOD_CODE;
	x_rowtype_rec.SHIP_FROM_ORG_ID         := p_header_rec.SHIP_FROM_ORG_ID;
	x_rowtype_rec.SHIP_TO_ORG_ID           := p_header_rec.SHIP_TO_ORG_ID;
	x_rowtype_rec.SOLD_TO_CONTACT_ID       := p_header_rec.SOLD_TO_CONTACT_ID;
	x_rowtype_rec.SOLD_TO_ORG_ID           := p_header_rec.SOLD_TO_ORG_ID;
	x_rowtype_rec.START_DATE_ACTIVE        := p_header_rec.START_DATE_ACTIVE;
	x_rowtype_rec.TRANSACTIONAL_CURR_CODE  := p_header_rec.TRANSACTIONAL_CURR_CODE;
	x_rowtype_rec.VERSION_NUMBER           := p_header_rec.VERSION_NUMBER;

	x_rowtype_rec.CREATED_BY           := p_header_rec.CREATED_BY;
	x_rowtype_rec.CREATION_DATE           := p_header_rec.CREATION_DATE;
	x_rowtype_rec.REVISION_CHANGE_DATE           := p_header_rec.REVISION_CHANGE_DATE;
	x_rowtype_rec.REVISION_CHANGE_REASON_CODE           := p_header_rec.REVISION_CHANGE_REASON_CODE;
	x_rowtype_rec.REVISION_CHANGE_COMMENTS           := p_header_rec.REVISION_CHANGE_COMMENTS;
	x_rowtype_rec.ENFORCE_SHIP_TO_FLAG           := p_header_rec.ENFORCE_SHIP_TO_FLAG;
	x_rowtype_rec.ENFORCE_FREIGHT_TERM_FLAG           := p_header_rec.ENFORCE_FREIGHT_TERM_FLAG;
	x_rowtype_rec.ENFORCE_SHIPPING_METHOD_FLAG           := p_header_rec.ENFORCE_SHIPPING_METHOD_FLAG;
	x_rowtype_rec.ENFORCE_PRICE_LIST_FLAG           := p_header_rec.ENFORCE_PRICE_LIST_FLAG;
	x_rowtype_rec.ENFORCE_PAYMENT_TERM_FLAG           := p_header_rec.ENFORCE_PAYMENT_TERM_FLAG;
	x_rowtype_rec.ENFORCE_INVOICE_TO_FLAG           := p_header_rec.ENFORCE_INVOICE_TO_FLAG;
	x_rowtype_rec.ENFORCE_INVOICING_RULE_FLAG           := p_header_rec.ENFORCE_INVOICING_RULE_FLAG;
	x_rowtype_rec.ENFORCE_ACCOUNTING_RULE_FLAG           := p_header_rec.ENFORCE_ACCOUNTING_RULE_FLAG;
	x_rowtype_rec.BLANKET_MIN_AMOUNT           := p_header_rec.BLANKET_MIN_AMOUNT;
	x_rowtype_rec.BLANKET_MAX_AMOUNT           := p_header_rec.BLANKET_MAX_AMOUNT;
	x_rowtype_rec.OVERRIDE_AMOUNT_FLAG           := p_header_rec.OVERRIDE_AMOUNT_FLAG;
	x_rowtype_rec.ON_HOLD_FLAG           := p_header_rec.ON_HOLD_FLAG;
	x_rowtype_rec.SUPPLIER_SIGNATURE            := p_header_rec.SUPPLIER_SIGNATURE;
	x_rowtype_rec.SUPPLIER_SIGNATURE_DATE            := p_header_rec.SUPPLIER_SIGNATURE_DATE;
	x_rowtype_rec.CUSTOMER_SIGNATURE            := p_header_rec.CUSTOMER_SIGNATURE;
	x_rowtype_rec.CUSTOMER_SIGNATURE_DATE            := p_header_rec.CUSTOMER_SIGNATURE_DATE;
--	x_rowtype_rec.QUOTE_NUMBER            := p_header_rec.QUOTE_NUMBER;
--	x_rowtype_rec.QUOTE_DATE            := p_header_rec.QUOTE_DATE;
	x_rowtype_rec.FLOW_STATUS_CODE            := p_header_rec.FLOW_STATUS_CODE;
	x_rowtype_rec.SOURCE_DOCUMENT_TYPE_ID            := p_header_rec.SOURCE_DOCUMENT_TYPE_ID;
	x_rowtype_rec.NEW_MODIFIER_LIST_ID            := p_header_rec.NEW_MODIFIER_LIST_ID;
	x_rowtype_rec.NEW_PRICE_LIST_ID            := p_header_rec.NEW_PRICE_LIST_ID;
	x_rowtype_rec.DEFAULT_DISCOUNT_PERCENT            := p_header_rec.DEFAULT_DISCOUNT_PERCENT;
	x_rowtype_rec.DEFAULT_DISCOUNT_AMOUNT            := p_header_rec.DEFAULT_DISCOUNT_AMOUNT;
	x_rowtype_rec.CONTRACT_TERMS            := p_header_rec.CONTRACT_TEMPLATE_ID;
	x_rowtype_rec.OPEN_FLAG            := p_header_rec.OPEN_FLAG;
           --bug 6531947
           x_rowtype_rec.CONTEXT               := p_header_rec.CONTEXT;
	   x_rowtype_rec.ATTRIBUTE1            := p_header_rec.ATTRIBUTE1;
	   x_rowtype_rec.ATTRIBUTE2            := p_header_rec.ATTRIBUTE2;
	   x_rowtype_rec.ATTRIBUTE3            := p_header_rec.ATTRIBUTE3;
	   x_rowtype_rec.ATTRIBUTE4            := p_header_rec.ATTRIBUTE4;
	   x_rowtype_rec.ATTRIBUTE5            := p_header_rec.ATTRIBUTE5;
	   x_rowtype_rec.ATTRIBUTE6            := p_header_rec.ATTRIBUTE6;
	   x_rowtype_rec.ATTRIBUTE7            := p_header_rec.ATTRIBUTE7;
	   x_rowtype_rec.ATTRIBUTE8            := p_header_rec.ATTRIBUTE8;
	   x_rowtype_rec.ATTRIBUTE9            := p_header_rec.ATTRIBUTE9;
	   x_rowtype_rec.ATTRIBUTE10            := p_header_rec.ATTRIBUTE10;
	   x_rowtype_rec.ATTRIBUTE11            := p_header_rec.ATTRIBUTE11;
	   x_rowtype_rec.ATTRIBUTE12            := p_header_rec.ATTRIBUTE12;
	   x_rowtype_rec.ATTRIBUTE13            := p_header_rec.ATTRIBUTE13;
	   x_rowtype_rec.ATTRIBUTE14            := p_header_rec.ATTRIBUTE14;
	   x_rowtype_rec.ATTRIBUTE15            := p_header_rec.ATTRIBUTE15;
	   x_rowtype_rec.ATTRIBUTE16            := p_header_rec.ATTRIBUTE16;
	   x_rowtype_rec.ATTRIBUTE17            := p_header_rec.ATTRIBUTE17;
	   x_rowtype_rec.ATTRIBUTE18            := p_header_rec.ATTRIBUTE18;
	   x_rowtype_rec.ATTRIBUTE19            := p_header_rec.ATTRIBUTE19;
	   x_rowtype_rec.ATTRIBUTE20            := p_header_rec.ATTRIBUTE20;

     -- QUOTING changes
        x_rowtype_rec.sales_document_name      := p_header_rec.sales_document_name;
        x_rowtype_rec.transaction_phase_code   := p_header_rec.transaction_phase_code;
        x_rowtype_rec.user_status_code         := p_header_rec.user_status_code;
        x_rowtype_rec.draft_submitted_flag     := p_header_rec.draft_submitted_flag;
        x_rowtype_rec.source_document_version_number := p_header_rec.source_document_version_number;
        x_rowtype_rec.sold_to_site_use_id      := p_header_rec.sold_to_site_use_id;
        -- QUOTING changes END


EXCEPTION

	WHEN OTHERS THEN
 		IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   			OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'API_Rec_To_RowType_Rec'
         	);
     	END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END API_Rec_To_RowType_Rec;

PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Blanket_PUB.HEADER_Rec_Type
) IS
BEGIN

	x_api_rec.ACCOUNTING_RULE_ID       := p_record.ACCOUNTING_RULE_ID;
	x_api_rec.CONVERSION_TYPE_CODE     := p_record.CONVERSION_TYPE_CODE;
	x_api_rec.CUST_PO_NUMBER           := p_record.CUST_PO_NUMBER;
	x_api_rec.DELIVER_TO_ORG_ID        := p_record.DELIVER_TO_ORG_ID;
        x_api_rec.END_DATE_ACTIVE          := p_record.END_DATE_ACTIVE;
	x_api_rec.FREIGHT_TERMS_CODE       := p_record.FREIGHT_TERMS_CODE;
	x_api_rec.HEADER_ID       := p_record.HEADER_ID;
	x_api_rec.INVOICE_TO_ORG_ID        := p_record.INVOICE_TO_ORG_ID;
	x_api_rec.INVOICING_RULE_ID        := p_record.INVOICING_RULE_ID;
	x_api_rec.ORDER_NUMBER             := p_record.ORDER_NUMBER;
	x_api_rec.ORDER_TYPE_ID            := p_record.ORDER_TYPE_ID;
	x_api_rec.PACKING_INSTRUCTIONS     := p_record.PACKING_INSTRUCTIONS;
	x_api_rec.PAYMENT_TERM_ID          := p_record.PAYMENT_TERM_ID;
	x_api_rec.PRICE_LIST_ID            := p_record.PRICE_LIST_ID;
	x_api_rec.SALESREP_ID              := p_record.SALESREP_ID;
	x_api_rec.SHIPPING_INSTRUCTIONS    := p_record.SHIPPING_INSTRUCTIONS;
	x_api_rec.SHIPPING_METHOD_CODE     := p_record.SHIPPING_METHOD_CODE;
	x_api_rec.SHIP_FROM_ORG_ID         := p_record.SHIP_FROM_ORG_ID;
	x_api_rec.SHIP_TO_ORG_ID           := p_record.SHIP_TO_ORG_ID;
	x_api_rec.SOLD_TO_CONTACT_ID       := p_record.SOLD_TO_CONTACT_ID;
	x_api_rec.SOLD_TO_ORG_ID           := p_record.SOLD_TO_ORG_ID;
        x_api_rec.START_DATE_ACTIVE        := p_record.START_DATE_ACTIVE;
	x_api_rec.TRANSACTIONAL_CURR_CODE  := p_record.TRANSACTIONAL_CURR_CODE;
	x_api_rec.VERSION_NUMBER           := p_record.VERSION_NUMBER;

	x_api_rec.CREATED_BY           := p_record.CREATED_BY;
	x_api_rec.CREATION_DATE           := p_record.CREATION_DATE;
	x_api_rec.REVISION_CHANGE_DATE           := p_record.REVISION_CHANGE_DATE;
	x_api_rec.REVISION_CHANGE_REASON_CODE           := p_record.REVISION_CHANGE_REASON_CODE;
	x_api_rec.REVISION_CHANGE_COMMENTS           := p_record.REVISION_CHANGE_COMMENTS;
	x_api_rec.ENFORCE_SHIP_TO_FLAG           := p_record.ENFORCE_SHIP_TO_FLAG;
	x_api_rec.ENFORCE_FREIGHT_TERM_FLAG           := p_record.ENFORCE_FREIGHT_TERM_FLAG;
	x_api_rec.ENFORCE_SHIPPING_METHOD_FLAG           := p_record.ENFORCE_SHIPPING_METHOD_FLAG;
	x_api_rec.ENFORCE_PRICE_LIST_FLAG           := p_record.ENFORCE_PRICE_LIST_FLAG;
	x_api_rec.ENFORCE_PAYMENT_TERM_FLAG           := p_record.ENFORCE_PAYMENT_TERM_FLAG;
	x_api_rec.ENFORCE_INVOICE_TO_FLAG           := p_record.ENFORCE_INVOICE_TO_FLAG;
	x_api_rec.ENFORCE_INVOICING_RULE_FLAG           := p_record.ENFORCE_INVOICING_RULE_FLAG;
	x_api_rec.ENFORCE_ACCOUNTING_RULE_FLAG           := p_record.ENFORCE_ACCOUNTING_RULE_FLAG;
	x_api_rec.BLANKET_MIN_AMOUNT           := p_record.BLANKET_MIN_AMOUNT;
	x_api_rec.BLANKET_MAX_AMOUNT           := p_record.BLANKET_MAX_AMOUNT;
	x_api_rec.OVERRIDE_AMOUNT_FLAG           := p_record.OVERRIDE_AMOUNT_FLAG;
	x_api_rec.ON_HOLD_FLAG           := p_record.ON_HOLD_FLAG;
	x_api_rec.SUPPLIER_SIGNATURE            := p_record.SUPPLIER_SIGNATURE;
	x_api_rec.SUPPLIER_SIGNATURE_DATE            := p_record.SUPPLIER_SIGNATURE_DATE;
	x_api_rec.CUSTOMER_SIGNATURE            := p_record.CUSTOMER_SIGNATURE;
	x_api_rec.CUSTOMER_SIGNATURE_DATE            := p_record.CUSTOMER_SIGNATURE_DATE;
--	x_api_rec.QUOTE_NUMBER            := p_record.QUOTE_NUMBER;
--	x_api_rec.QUOTE_DATE            := p_record.QUOTE_DATE;
	x_api_rec.FLOW_STATUS_CODE            := p_record.FLOW_STATUS_CODE;
	x_api_rec.SOURCE_DOCUMENT_TYPE_ID            := p_record.SOURCE_DOCUMENT_TYPE_ID;
	x_api_rec.NEW_MODIFIER_LIST_ID            := p_record.NEW_MODIFIER_LIST_ID;
	x_api_rec.NEW_PRICE_LIST_ID            := p_record.NEW_PRICE_LIST_ID;
	x_api_rec.DEFAULT_DISCOUNT_PERCENT            := p_record.DEFAULT_DISCOUNT_PERCENT;
	x_api_rec.DEFAULT_DISCOUNT_AMOUNT            := p_record.DEFAULT_DISCOUNT_AMOUNT;
	x_api_rec.CONTRACT_TEMPLATE_ID            := p_record.CONTRACT_TERMS;
	x_api_rec.OPEN_FLAG            := p_record.OPEN_FLAG;
        --bug 6531947

          x_api_rec.CONTEXT               := p_record.CONTEXT;
	  x_api_rec.ATTRIBUTE1            := p_record.ATTRIBUTE1;
	  x_api_rec.ATTRIBUTE2            := p_record.ATTRIBUTE2;
	  x_api_rec.ATTRIBUTE3            := p_record.ATTRIBUTE3;
	  x_api_rec.ATTRIBUTE4            := p_record.ATTRIBUTE4;
	  x_api_rec.ATTRIBUTE5            := p_record.ATTRIBUTE5;
	  x_api_rec.ATTRIBUTE6            := p_record.ATTRIBUTE6;
	  x_api_rec.ATTRIBUTE7            := p_record.ATTRIBUTE7;
	  x_api_rec.ATTRIBUTE8            := p_record.ATTRIBUTE8;
	  x_api_rec.ATTRIBUTE9            := p_record.ATTRIBUTE9;
	  x_api_rec.ATTRIBUTE10            := p_record.ATTRIBUTE10;
	  x_api_rec.ATTRIBUTE11            := p_record.ATTRIBUTE11;
	  x_api_rec.ATTRIBUTE12            := p_record.ATTRIBUTE12;
	  x_api_rec.ATTRIBUTE13            := p_record.ATTRIBUTE13;
	  x_api_rec.ATTRIBUTE14            := p_record.ATTRIBUTE14;
	  x_api_rec.ATTRIBUTE15            := p_record.ATTRIBUTE15;
	  x_api_rec.ATTRIBUTE16            := p_record.ATTRIBUTE16;
	  x_api_rec.ATTRIBUTE17            := p_record.ATTRIBUTE17;
	  x_api_rec.ATTRIBUTE18            := p_record.ATTRIBUTE18;
	  x_api_rec.ATTRIBUTE19            := p_record.ATTRIBUTE19;
	  x_api_rec.ATTRIBUTE20            := p_record.ATTRIBUTE20;

        -- QUOTING changes
	x_api_rec.sales_document_name      := p_record.sales_document_name;
	x_api_rec.transaction_phase_code   := p_record.transaction_phase_code;
	x_api_rec.user_status_code         := p_record.user_status_code;
	x_api_rec.draft_submitted_flag     := p_record.draft_submitted_flag;
	x_api_rec.source_document_version_number := p_record.source_document_version_number;
	x_api_rec.sold_to_site_use_id      := p_record.sold_to_site_use_id;
        -- QUOTING changes END

EXCEPTION

	WHEN OTHERS THEN
	IF	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'Rowtype_Rec_To_API_Rec'
         	);
	END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Rowtype_Rec_To_API_Rec;

FUNCTION G_MISS_OE_AK_BLKT_LINE_REC
RETURN OE_AK_BLANKET_LINES_V%ROWTYPE IS
	l_rowtype_rec					OE_AK_BLANKET_LINES_V%ROWTYPE;
BEGIN

	l_rowtype_rec.ACCOUNTING_RULE_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.CUST_PO_NUMBER				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.DELIVER_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.END_DATE_ACTIVE				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.FREIGHT_TERMS_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.INVOICE_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.INVOICING_RULE_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.LINE_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ORDER_NUMBER					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PACKING_INSTRUCTIONS			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.PAYMENT_TERM_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PRICE_LIST_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SALESREP_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SHIPPING_INSTRUCTIONS			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SHIPPING_METHOD_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SHIP_FROM_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SHIP_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.START_DATE_ACTIVE				:= FND_API.G_MISS_DATE;

	l_rowtype_rec.LINE_NUMBER					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PREFERRED_GRADE					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ITEM_IDENTIFIER_TYPE              := FND_API.G_MISS_CHAR;
	l_rowtype_rec.INVENTORY_ITEM_ID              := FND_API.G_MISS_NUM;
	l_rowtype_rec.ORDER_QUANTITY_UOM              := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_SHIP_TO_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_FREIGHT_TERM_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_SHIPPING_METHOD_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_PRICE_LIST_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_PAYMENT_TERM_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_INVOICE_TO_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_INVOICING_RULE_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.ENFORCE_ACCOUNTING_RULE_FLAG           := FND_API.G_MISS_CHAR;
	l_rowtype_rec.BLANKET_LINE_MIN_AMOUNT           := FND_API.G_MISS_NUM;
	l_rowtype_rec.BLANKET_LINE_MAX_AMOUNT           := FND_API.G_MISS_NUM;

	l_rowtype_rec.BLANKET_MIN_QUANTITY              := FND_API.G_MISS_NUM;
	l_rowtype_rec.BLANKET_MAX_QUANTITY              := FND_API.G_MISS_NUM;
	l_rowtype_rec.MIN_RELEASE_AMOUNT              := FND_API.G_MISS_NUM;
	l_rowtype_rec.MAX_RELEASE_AMOUNT              := FND_API.G_MISS_NUM;
	l_rowtype_rec.MIN_RELEASE_QUANTITY              := FND_API.G_MISS_NUM;
	l_rowtype_rec.MAX_RELEASE_QUANTITY              := FND_API.G_MISS_NUM;
	l_rowtype_rec.OVERRIDE_BLANKET_CONTROLS_FLAG              := FND_API.G_MISS_CHAR;
	l_rowtype_rec.OVERRIDE_RELEASE_CONTROLS_FLAG              := FND_API.G_MISS_CHAR;
	l_rowtype_rec.SOURCE_DOCUMENT_TYPE_ID              := FND_API.G_MISS_NUM;
	l_rowtype_rec.MODIFIER_LIST_LINE_ID              := FND_API.G_MISS_NUM;

    -- QUOTING changes
    l_rowtype_rec.TRANSACTION_PHASE_CODE          := FND_API.G_MISS_CHAR;
    l_rowtype_rec.SOURCE_DOCUMENT_VERSION_NUMBER  := FND_API.G_MISS_NUM;

        l_rowtype_rec.unit_list_price := fnd_api.g_miss_num;
        l_rowtype_rec.pricing_quantity_uom := fnd_api.g_miss_char;
        l_rowtype_rec.discount_percent := fnd_api.g_miss_num;
        l_rowtype_rec.discount_amount := fnd_api.g_miss_num;

	RETURN l_rowtype_rec;

EXCEPTION

	WHEN OTHERS THEN
		IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'G_MISS_OE_AK_LINE_REC'
			);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END G_MISS_OE_AK_BLKT_LINE_REC;

PROCEDURE Line_API_Rec_To_Rowtype_Rec
(   p_LINE_rec                    IN  OE_Blanket_PUB.LINE_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_BLANKET_LINES_V%ROWTYPE
) IS
BEGIN

	x_rowtype_rec.ACCOUNTING_RULE_ID       := p_line_rec.ACCOUNTING_RULE_ID;
	x_rowtype_rec.CUST_PO_NUMBER           := p_line_rec.CUST_PO_NUMBER;
	x_rowtype_rec.DELIVER_TO_ORG_ID        := p_line_rec.DELIVER_TO_ORG_ID;
	x_rowtype_rec.END_DATE_ACTIVE          := p_line_rec.END_DATE_ACTIVE;
	x_rowtype_rec.FREIGHT_TERMS_CODE       := p_line_rec.FREIGHT_TERMS_CODE;
	x_rowtype_rec.INVOICE_TO_ORG_ID        := p_line_rec.INVOICE_TO_ORG_ID;
	x_rowtype_rec.INVOICING_RULE_ID        := p_line_rec.INVOICING_RULE_ID;
	x_rowtype_rec.LINE_ID             := p_line_rec.LINE_ID;
	x_rowtype_rec.ORDER_NUMBER             := p_line_rec.ORDER_NUMBER;
	x_rowtype_rec.PACKING_INSTRUCTIONS     := p_line_rec.PACKING_INSTRUCTIONS;
	x_rowtype_rec.PAYMENT_TERM_ID          := p_line_rec.PAYMENT_TERM_ID;
	x_rowtype_rec.PRICE_LIST_ID            := p_line_rec.PRICE_LIST_ID;
	x_rowtype_rec.SALESREP_ID              := p_line_rec.SALESREP_ID;
	x_rowtype_rec.SHIPPING_INSTRUCTIONS    := p_line_rec.SHIPPING_INSTRUCTIONS;
	x_rowtype_rec.SHIPPING_METHOD_CODE     := p_line_rec.SHIPPING_METHOD_CODE;
	x_rowtype_rec.SHIP_FROM_ORG_ID         := p_line_rec.SHIP_FROM_ORG_ID;
	x_rowtype_rec.SHIP_TO_ORG_ID           := p_line_rec.SHIP_TO_ORG_ID;
	x_rowtype_rec.START_DATE_ACTIVE          := p_line_rec.START_DATE_ACTIVE;

	x_rowtype_rec.LINE_NUMBER             := p_line_rec.LINE_NUMBER;
	x_rowtype_rec.PREFERRED_GRADE              := p_line_rec.PREFERRED_GRADE;
	x_rowtype_rec.ITEM_IDENTIFIER_TYPE              := p_line_rec.ITEM_IDENTIFIER_TYPE;
	x_rowtype_rec.INVENTORY_ITEM_ID              := p_line_rec.INVENTORY_ITEM_ID;
	x_rowtype_rec.ORDER_QUANTITY_UOM              := p_line_rec.ORDER_QUANTITY_UOM;
	x_rowtype_rec.ENFORCE_SHIP_TO_FLAG           := p_line_rec.ENFORCE_SHIP_TO_FLAG;
	x_rowtype_rec.ENFORCE_FREIGHT_TERM_FLAG           := p_line_rec.ENFORCE_FREIGHT_TERM_FLAG;
	x_rowtype_rec.ENFORCE_SHIPPING_METHOD_FLAG           := p_line_rec.ENFORCE_SHIPPING_METHOD_FLAG;
	x_rowtype_rec.ENFORCE_PRICE_LIST_FLAG           := p_line_rec.ENFORCE_PRICE_LIST_FLAG;
	x_rowtype_rec.ENFORCE_PAYMENT_TERM_FLAG           := p_line_rec.ENFORCE_PAYMENT_TERM_FLAG;
	x_rowtype_rec.ENFORCE_INVOICE_TO_FLAG           := p_line_rec.ENFORCE_INVOICE_TO_FLAG;
	x_rowtype_rec.ENFORCE_INVOICING_RULE_FLAG           := p_line_rec.ENFORCE_INVOICING_RULE_FLAG;
	x_rowtype_rec.ENFORCE_ACCOUNTING_RULE_FLAG           := p_line_rec.ENFORCE_ACCOUNTING_RULE_FLAG;
	x_rowtype_rec.BLANKET_LINE_MIN_AMOUNT           := p_line_rec.BLANKET_MIN_AMOUNT;
	x_rowtype_rec.BLANKET_LINE_MAX_AMOUNT           := p_line_rec.BLANKET_MAX_AMOUNT;

	x_rowtype_rec.BLANKET_MIN_QUANTITY              := p_line_rec.BLANKET_MIN_QUANTITY;
	x_rowtype_rec.BLANKET_MAX_QUANTITY              := p_line_rec.BLANKET_MAX_QUANTITY;
	x_rowtype_rec.MIN_RELEASE_AMOUNT              := p_line_rec.MIN_RELEASE_AMOUNT;
	x_rowtype_rec.MAX_RELEASE_AMOUNT              := p_line_rec.MAX_RELEASE_AMOUNT;
	x_rowtype_rec.MIN_RELEASE_QUANTITY              := p_line_rec.MIN_RELEASE_QUANTITY;
	x_rowtype_rec.MAX_RELEASE_QUANTITY              := p_line_rec.MAX_RELEASE_QUANTITY;
	x_rowtype_rec.OVERRIDE_BLANKET_CONTROLS_FLAG              := p_line_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
	x_rowtype_rec.OVERRIDE_RELEASE_CONTROLS_FLAG              := p_line_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
	x_rowtype_rec.SOURCE_DOCUMENT_TYPE_ID              := p_line_rec.SOURCE_DOCUMENT_TYPE_ID;
	x_rowtype_rec.MODIFIER_LIST_LINE_ID              := p_line_rec.MODIFIER_LIST_LINE_ID;
        --bug6531947
           x_rowtype_rec.CONTEXT               := p_line_rec.CONTEXT;
	   x_rowtype_rec.ATTRIBUTE1            := p_line_rec.ATTRIBUTE1;
	   x_rowtype_rec.ATTRIBUTE2            := p_line_rec.ATTRIBUTE2;
	   x_rowtype_rec.ATTRIBUTE3            := p_line_rec.ATTRIBUTE3;
	   x_rowtype_rec.ATTRIBUTE4            := p_line_rec.ATTRIBUTE4;
	   x_rowtype_rec.ATTRIBUTE5            := p_line_rec.ATTRIBUTE5;
	   x_rowtype_rec.ATTRIBUTE6            := p_line_rec.ATTRIBUTE6;
	   x_rowtype_rec.ATTRIBUTE7            := p_line_rec.ATTRIBUTE7;
	   x_rowtype_rec.ATTRIBUTE8            := p_line_rec.ATTRIBUTE8;
	   x_rowtype_rec.ATTRIBUTE9            := p_line_rec.ATTRIBUTE9;
	   x_rowtype_rec.ATTRIBUTE10            := p_line_rec.ATTRIBUTE10;
	   x_rowtype_rec.ATTRIBUTE11            := p_line_rec.ATTRIBUTE11;
	   x_rowtype_rec.ATTRIBUTE12            := p_line_rec.ATTRIBUTE12;
	   x_rowtype_rec.ATTRIBUTE13            := p_line_rec.ATTRIBUTE13;
	   x_rowtype_rec.ATTRIBUTE14            := p_line_rec.ATTRIBUTE14;
	   x_rowtype_rec.ATTRIBUTE15            := p_line_rec.ATTRIBUTE15;
	   x_rowtype_rec.ATTRIBUTE16            := p_line_rec.ATTRIBUTE16;
	   x_rowtype_rec.ATTRIBUTE17            := p_line_rec.ATTRIBUTE17;
	   x_rowtype_rec.ATTRIBUTE18            := p_line_rec.ATTRIBUTE18;
	   x_rowtype_rec.ATTRIBUTE19            := p_line_rec.ATTRIBUTE19;
	   x_rowtype_rec.ATTRIBUTE20            := p_line_rec.ATTRIBUTE20;

    -- QUOTING changes
    x_rowtype_rec.transaction_phase_code := p_line_rec.transaction_phase_code;
    x_rowtype_rec.source_document_version_number :=
                                p_line_rec.source_document_version_number;
    x_rowtype_rec.unit_list_price := p_line_rec.unit_list_price;
    x_rowtype_rec.pricing_quantity_uom := p_line_rec.pricing_uom;
    x_rowtype_rec.discount_percent := p_line_rec.discount_percent;
    x_rowtype_rec.discount_amount := p_line_rec.discount_amount;

EXCEPTION

	WHEN OTHERS THEN
 		IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   			OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'API_Rec_To_RowType_Rec'
         	);
     	END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Line_API_Rec_To_RowType_Rec;

PROCEDURE Line_Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Blanket_PUB.LINE_Rec_Type
) IS
BEGIN

	x_api_rec.ACCOUNTING_RULE_ID       := p_record.ACCOUNTING_RULE_ID;
	x_api_rec.CUST_PO_NUMBER           := p_record.CUST_PO_NUMBER;
	x_api_rec.DELIVER_TO_ORG_ID        := p_record.DELIVER_TO_ORG_ID;
	x_api_rec.END_DATE_ACTIVE          := p_record.END_DATE_ACTIVE;
	x_api_rec.FREIGHT_TERMS_CODE       := p_record.FREIGHT_TERMS_CODE;
	x_api_rec.INVOICE_TO_ORG_ID        := p_record.INVOICE_TO_ORG_ID;
	x_api_rec.INVOICING_RULE_ID        := p_record.INVOICING_RULE_ID;
	x_api_rec.LINE_ID        := p_record.LINE_ID;
	x_api_rec.ORDER_NUMBER             := p_record.ORDER_NUMBER;
	x_api_rec.PACKING_INSTRUCTIONS     := p_record.PACKING_INSTRUCTIONS;
	x_api_rec.PAYMENT_TERM_ID          := p_record.PAYMENT_TERM_ID;
	x_api_rec.PRICE_LIST_ID            := p_record.PRICE_LIST_ID;
	x_api_rec.SALESREP_ID              := p_record.SALESREP_ID;
	x_api_rec.SHIPPING_INSTRUCTIONS    := p_record.SHIPPING_INSTRUCTIONS;
	x_api_rec.SHIPPING_METHOD_CODE     := p_record.SHIPPING_METHOD_CODE;
	x_api_rec.SHIP_FROM_ORG_ID         := p_record.SHIP_FROM_ORG_ID;
	x_api_rec.SHIP_TO_ORG_ID           := p_record.SHIP_TO_ORG_ID;
	x_api_rec.START_DATE_ACTIVE          := p_record.START_DATE_ACTIVE;

	x_api_rec.LINE_NUMBER             := p_record.LINE_NUMBER;
	x_api_rec.PREFERRED_GRADE              := p_record.PREFERRED_GRADE;
	x_api_rec.ITEM_IDENTIFIER_TYPE              := p_record.ITEM_IDENTIFIER_TYPE;
	x_api_rec.INVENTORY_ITEM_ID              := p_record.INVENTORY_ITEM_ID;
	x_api_rec.ORDER_QUANTITY_UOM              := p_record.ORDER_QUANTITY_UOM;
	x_api_rec.ENFORCE_SHIP_TO_FLAG           := p_record.ENFORCE_SHIP_TO_FLAG;
	x_api_rec.ENFORCE_FREIGHT_TERM_FLAG           := p_record.ENFORCE_FREIGHT_TERM_FLAG;
	x_api_rec.ENFORCE_SHIPPING_METHOD_FLAG           := p_record.ENFORCE_SHIPPING_METHOD_FLAG;
	x_api_rec.ENFORCE_PRICE_LIST_FLAG           := p_record.ENFORCE_PRICE_LIST_FLAG;
	x_api_rec.ENFORCE_PAYMENT_TERM_FLAG           := p_record.ENFORCE_PAYMENT_TERM_FLAG;
	x_api_rec.ENFORCE_INVOICE_TO_FLAG           := p_record.ENFORCE_INVOICE_TO_FLAG;
	x_api_rec.ENFORCE_INVOICING_RULE_FLAG           := p_record.ENFORCE_INVOICING_RULE_FLAG;
	x_api_rec.ENFORCE_ACCOUNTING_RULE_FLAG           := p_record.ENFORCE_ACCOUNTING_RULE_FLAG;
	x_api_rec.BLANKET_MIN_AMOUNT           := p_record.BLANKET_LINE_MIN_AMOUNT;
	x_api_rec.BLANKET_MAX_AMOUNT           := p_record.BLANKET_LINE_MAX_AMOUNT;

	x_api_rec.BLANKET_MIN_QUANTITY              := p_record.BLANKET_MIN_QUANTITY;
	x_api_rec.BLANKET_MAX_QUANTITY              := p_record.BLANKET_MAX_QUANTITY;
	x_api_rec.MIN_RELEASE_AMOUNT              := p_record.MIN_RELEASE_AMOUNT;
	x_api_rec.MAX_RELEASE_AMOUNT              := p_record.MAX_RELEASE_AMOUNT;
	x_api_rec.MIN_RELEASE_QUANTITY              := p_record.MIN_RELEASE_QUANTITY;
	x_api_rec.MAX_RELEASE_QUANTITY              := p_record.MAX_RELEASE_QUANTITY;
	x_api_rec.OVERRIDE_BLANKET_CONTROLS_FLAG              := p_record.OVERRIDE_BLANKET_CONTROLS_FLAG;
	x_api_rec.OVERRIDE_RELEASE_CONTROLS_FLAG              := p_record.OVERRIDE_RELEASE_CONTROLS_FLAG;
	x_api_rec.SOURCE_DOCUMENT_TYPE_ID              := p_record.SOURCE_DOCUMENT_TYPE_ID;
	x_api_rec.MODIFIER_LIST_LINE_ID              := p_record.MODIFIER_LIST_LINE_ID;
        --bug6531947
          x_api_rec.CONTEXT               := p_record.CONTEXT;
	  x_api_rec.ATTRIBUTE1            := p_record.ATTRIBUTE1;
	  x_api_rec.ATTRIBUTE2            := p_record.ATTRIBUTE2;
	  x_api_rec.ATTRIBUTE3            := p_record.ATTRIBUTE3;
	  x_api_rec.ATTRIBUTE4            := p_record.ATTRIBUTE4;
	  x_api_rec.ATTRIBUTE5            := p_record.ATTRIBUTE5;
	  x_api_rec.ATTRIBUTE6            := p_record.ATTRIBUTE6;
	  x_api_rec.ATTRIBUTE7            := p_record.ATTRIBUTE7;
	  x_api_rec.ATTRIBUTE8            := p_record.ATTRIBUTE8;
	  x_api_rec.ATTRIBUTE9            := p_record.ATTRIBUTE9;
	  x_api_rec.ATTRIBUTE10            := p_record.ATTRIBUTE10;
	  x_api_rec.ATTRIBUTE11            := p_record.ATTRIBUTE11;
	  x_api_rec.ATTRIBUTE12            := p_record.ATTRIBUTE12;
	  x_api_rec.ATTRIBUTE13            := p_record.ATTRIBUTE13;
	  x_api_rec.ATTRIBUTE14            := p_record.ATTRIBUTE14;
	  x_api_rec.ATTRIBUTE15            := p_record.ATTRIBUTE15;
	  x_api_rec.ATTRIBUTE16            := p_record.ATTRIBUTE16;
	  x_api_rec.ATTRIBUTE17            := p_record.ATTRIBUTE17;
	  x_api_rec.ATTRIBUTE18            := p_record.ATTRIBUTE18;
	  x_api_rec.ATTRIBUTE19            := p_record.ATTRIBUTE19;
	  x_api_rec.ATTRIBUTE20            := p_record.ATTRIBUTE20;

    -- QUOTING changes
    x_api_rec.transaction_phase_code := p_record.transaction_phase_code;
    x_api_rec.source_document_version_number :=
                                p_record.source_document_version_number;

    x_api_rec.unit_list_price := p_record.unit_list_price;
    x_api_rec.pricing_uom := p_record.pricing_quantity_uom;
    x_api_rec.discount_percent := p_record.discount_percent;
    x_api_rec.discount_amount := p_record.discount_amount;

EXCEPTION

	WHEN OTHERS THEN
	IF	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'Rowtype_Rec_To_API_Rec'
         	);
	END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Line_Rowtype_Rec_To_API_Rec;

PROCEDURE Get_Inventory_Item
(p_x_line_rec       IN OUT NOCOPY    OE_Blanket_Pub.Line_Rec_Type
,x_return_status    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_attribute_value             VARCHAR2(2000);
l_address_id                  VARCHAR2(2000):= NULL;
l_cust_id                     NUMBER:= NULL;
l_update_inventory_item       VARCHAR2(1) := FND_API.G_FALSE;
l_inventory_item_id           NUMBER;
l_error_code                  VARCHAR2(2000);
l_error_flag                  VARCHAR2(2000);
l_error_message               VARCHAR2(2000);
BEGIN
 /*
         1.call  INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value
           to get the inventory_item_id
           given the customer_item_id, and the new ship_from_org_id.

         2.check the value of the inventory_item_id returned:
           if internal item number return is not null, then
           assign the inventory_item_id to the out NOCOPY  {file.sql.39 change } parameter
           otherwise
           post  message OE_INVALIDATES_CUSTOMER_ITEM
           set return status to error.
          */
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    oe_debug_pub.add('Entering Oe_blanket_util Get_Inventory_Item', 1);
    IF (p_x_line_rec.ship_to_org_id IS NOT NULL AND
        p_x_line_rec.ship_to_org_id <> FND_API.G_MISS_NUM) THEN

        SELECT  u.cust_acct_site_id,s.cust_account_id
        INTO  l_address_id,
              l_cust_id
        FROM  HZ_CUST_SITE_USES u,HZ_CUST_ACCT_SITES s
        WHERE  u.cust_acct_site_id = s.cust_acct_site_id
           AND u.site_use_id = p_x_line_rec.ship_to_org_id
           AND u.site_use_code = 'SHIP_TO';
        oe_debug_pub.add('ship to address:' || l_address_id||' - Customer:'||to_char(l_cust_id));

        IF l_cust_id <> p_x_line_rec.sold_to_org_id  THEN
          oe_debug_pub.add('Sold-To Customer:'||to_char(p_x_line_rec.sold_to_org_id));
          l_address_id := NULL;
        END IF;

    END IF;

    oe_debug_pub.add('INVENTORY_ITEM_ID Before calling CI_Attribute_Value '
	||to_char(p_x_line_rec.inventory_item_id), 1);
    INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                     Z_Customer_Item_Id => p_x_line_rec.ordered_item_id
                   , Z_Customer_Id => p_x_line_rec.sold_to_org_id
                   , Z_Address_Id => l_address_id
                   , Z_Organization_Id => nvl(p_x_line_rec.ship_from_org_id, OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'))
                   , Z_Inventory_Item_Id => p_x_line_rec.inventory_item_id
                   , Attribute_Name => 'INVENTORY_ITEM_ID'
                   , Error_Code => l_error_code
                   , Error_Flag => l_error_flag
                   , Error_Message => l_error_message
                   , Attribute_Value => l_attribute_value
                     );

    oe_debug_pub.add('INVENTORY_ITEM_ID After call is '||l_attribute_value, 1);
    IF (l_attribute_value IS NOT NULL AND
       to_number(l_attribute_value) <> p_x_line_rec.inventory_item_id) THEN
       oe_debug_pub.add('Assigning new inventory_item_id', 1);
       l_update_inventory_item := FND_API.G_TRUE;
       l_inventory_item_id := TO_NUMBER(l_attribute_value);
    ELSIF to_number(l_attribute_value) = p_x_line_rec.inventory_item_id THEN
       NULL;
    ELSE
       oe_debug_pub.add('Issue error message', 1);
       fnd_message.set_name('ONT','OE_INVALIDATES_CUSTOMER_ITEM');
       OE_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
END Get_Inventory_Item;

-- for bug 4447494
PROCEDURE validate_sold_to(p_header_id      IN NUMBER,
                           p_sold_to_org_id IN NUMBER,
                           x_return_status  OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
L_DUMMY VARCHAR2(30) := 'VALID';
l_invoice_to_org_id number;
l_deliver_to_org_id number;
l_ship_To_org_id    number;
L_LINE_ID           number;
--
cursor c1 is
select sold_to_org_id,
       line_id,
       ship_to_org_id,
       deliver_to_org_id,
       invoice_to_org_id
from
    oe_blanket_lines_all where header_id = p_header_id;
 mc1x c1%ROWTYPE;

BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Blanket_util.validate_sold_to:');
       oe_debug_pub.add('DB Line ID : '|| TO_CHAR (mc1x.line_id) ,1);
       oe_debug_pub.add('DB Sold To Org ID : '|| TO_CHAR (mc1x.sold_to_org_id) ,1);
       oe_debug_pub.add('actual Hdr Sold To Org ID : '|| TO_CHAR (p_sold_to_org_id) ,1);
    END IF;

    -- Open the cursor
    OPEN c1;
    loop
      FETCH c1 into mc1x;
      exit when c1%NOTFOUND;
       oe_debug_pub.add('DB Line To : '|| TO_CHAR (mc1x.Line_id) ,1);
       oe_debug_pub.add('DB Ship To : '|| TO_CHAR (mc1x.ship_to_org_id) ,1);
       oe_debug_pub.add('DB Del ID  : '|| TO_CHAR (mc1x.deliver_to_org_id) ,1);
       oe_debug_pub.add('DB Invo ID : '|| TO_CHAR (mc1x.invoice_to_org_id) ,1);
       if mc1x.ship_to_org_id is not null then
         --Ship to
         BEGIN
             SELECT 'VALID' INTO   l_dummy
             FROM   oe_ship_to_orgs_v
             WHERE  customer_id = p_sold_to_org_id
             AND    site_use_id = mc1x.ship_to_org_id
             AND    status = 'A'
             and    address_status='A';
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  if l_debug_level > 0 then
                   oe_debug_pub.add ('OE_blanket_util.validate_sold_to Blanket In ship to No data found',2);
                  end if;
                  l_dummy := 'INVALID';
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE'
                      , OE_Order_Util.Get_Attribute_Name('ship_to_org_id'));
                   OE_MSG_PUB.Add;
             WHEN OTHERS THEN
                  if l_debug_level > 0 then
                   oe_debug_pub.add ('OE_blanket_util.validate_sold_to WOE Blanket In Ship No data found',2);
                  end if;
                 l_dummy := 'INVALID';
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                      OE_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME , 'Record - Ship To');
                 END IF;
                 --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END ;
       end if;
       if mc1x.deliver_to_org_id is not null then
         -- Deliver to
         BEGIN
             SELECT 'VALID' INTO   l_dummy
             FROM   oe_deliver_to_orgs_v
             WHERE  customer_id = p_sold_to_org_id
             AND    site_use_id = mc1x.deliver_to_org_id
             AND     status = 'A'
             and    address_status='A'; --2752321

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  if l_debug_level > 0 then
                   oe_debug_pub.add ('OE_blanket_util.validate_sold_to Blanket In deliver No data found',2);
                  end if;
                 l_dummy := 'INVALID';
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                 OE_Order_Util.Get_Attribute_Name('deliver_to_org_id'));
                 OE_MSG_PUB.Add;
             WHEN OTHERS THEN
                 if l_debug_level > 0 then
                   oe_debug_pub.add ('OE_blanket_util.validate_sold_to WOE Blanket In Deliver No data found',2);
                 end if;
                 l_dummy := 'INVALID';
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                      OE_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME , 'Record - Deliver To');
                 END IF;
                 --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
       end if;
       if mc1x.invoice_to_org_id is not null then
         -- Invoice To
         BEGIN
             Select 'VALID' Into   l_dummy
             from   oe_invoice_to_orgs_v
             Where  customer_id = p_sold_to_org_id
             AND    site_use_id = mc1x.invoice_to_org_id;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  if l_debug_level > 0 then
                   oe_debug_pub.add ('OE_blanket_util.validate_sold_to Blanket In invoice  No data found',2);
                  end if;
                  l_dummy := 'INVALID';
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                  OE_Order_Util.Get_Attribute_Name('invoice_to_org_id'));
                  OE_MSG_PUB.Add;
            WHEN OTHERS THEN
                  if l_debug_level > 0 then
                   oe_debug_pub.add ('OE_blanket_util.validate_sold_to WOE Blanket In Invoice  No data found',2);
                  end if;
                  l_dummy := 'INVALID';
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                         OE_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME , 'Record - Invoice To');
                  END IF;
                  --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
       end if;
    END LOOP;
    CLOSE C1;
    if l_debug_level > 0 then
       oe_debug_pub.add ('OE_blanket_util.validate_sold_to After Close  In Invoice '||x_return_status,2);
    end if;

    if x_return_status = FND_API.G_RET_STS_ERROR then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    elsif l_dummy = 'VALID' then
       update oe_blanket_lines_all set sold_to_org_id = p_sold_to_org_id
       where header_id = p_header_id;
    end if;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('EXISTING OE_Blanket_util.validate_sold_to: '|| TO_CHAR (p_header_id) ,1);
    END IF;
END  validate_sold_to;

-- New procedure added for 5528599 start
PROCEDURE  valid_blanket_dates
( p_header_id                 IN NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2)

IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_header_rec  OE_Blanket_Pub.header_rec_type;
l_line_tbl    OE_Blanket_Pub.line_tbl_type;
K             NUMBER :=1;
BEGIN
 --bug#5528507
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    oe_debug_pub.add('In the valid_blanket_dates',1);

    Query_Blanket(p_header_id           => p_header_id
                 ,p_x_header_rec        => l_header_rec
                 ,p_x_line_tbl          => l_line_tbl
                 ,x_return_status       => x_return_status);


     if ( x_return_status = 'S')
       then
            oe_debug_pub.add('End Date :'||trunc(l_header_rec.end_date_active),1);
            oe_debug_pub.add('Sysdate :'||trunc(sysdate),1);

       OE_MSG_PUB.set_msg_context(
            p_entity_code                  => 'BLANKET_HEADER'
           ,p_entity_id                    => l_header_rec.header_id
           ,p_header_id                    => l_header_rec.header_id
           ,p_line_id                      => null
           ,p_orig_sys_document_ref        => null
           ,p_orig_sys_document_line_ref   => null
           ,p_change_sequence              => null
           ,p_source_document_id           => null
           ,p_source_document_line_id      => null
           ,p_order_source_id            => null
           ,p_source_document_type_id    => null);

          if (trunc(l_header_rec.end_date_active) < trunc(sysdate))
             then
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
              OE_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
           end if;


   K := l_line_tbl.FIRST;
             oe_debug_pub.add('validating Lines ',1);
  WHILE K IS NOT NULL
   LOOP

    OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'BLANKET_LINE'
        ,p_entity_id                    => l_line_tbl(K).line_id
        ,p_header_id                    => l_line_tbl(K).header_id
        ,p_line_id                      => l_line_tbl(K).line_id
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => null
        ,p_source_document_line_id      => null
        ,p_order_source_id            => null
        ,p_source_document_type_id    => null);

          oe_debug_pub.add('start date active:'|| l_line_tbl(K).start_date_active,1);
          oe_debug_pub.add('end_date_active :'|| l_line_tbl(K).end_date_active,1);
          oe_debug_pub.add('SYSDATE :'|| trunc(sysdate),1);

       if (l_line_tbl(K).end_date_active is not NULL and
          (l_line_tbl(K).start_date_active)
              > (l_line_tbl(K).end_date_active)) THEN
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
              OE_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
       end if;

       if( trunc(l_line_tbl(K).end_date_active) < trunc(sysdate))
         then
              FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_DATE_RANGE');
              OE_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

     K:= l_line_tbl.next(K);
   END LOOP;

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

 END IF;

  EXCEPTION
    when others then
    null;

END valid_blanket_dates;
-- New procedure added for 5528599 end
Procedure IS_Batch_Call( p_application_id IN NUMBER,
                                        p_entity_short_name in VARCHAR2,
                                        p_validation_entity_short_name in VARCHAR2,
                                        p_validation_tmplt_short_name in VARCHAR2,
                                        p_record_set_tmplt_short_name in VARCHAR2,
                                        p_scope in VARCHAR2,
                                        p_result OUT NOCOPY NUMBER ) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if l_debug_level > 0 then
        oe_debug_pub.add('Enter OE_Blanket_Util.Batch_Call');
    end if;

  if OE_GLOBALS.G_UI_FLAG THEN
     oe_debug_pub.add(' UI Call ');
   ELSE
     oe_debug_pub.add(' Batch call' );
  end if;
     IF NOT (OE_GLOBALS.G_UI_FLAG ) THEN
     p_result :=1;
    ELSE
    p_result :=0;
   END IF;
--END IF;
END Is_Batch_Call;



END OE_Blanket_UTIL;

/
